/*
	display.c of ue/Gulam

The functions in this file handle redisplay.  There are two halves,
the ones that update the virtual display screen, and the ones that
make the physical display screen the same as the virtual display
screen.  These functions use hints that are left in the windows by the
commands.

prabhaker mateti, 11-14-86, many improvements
prabhaker mateti, 1-1-86, ST520 changes
Steve Wilhite, 1-Dec-85  - massive cleanup on code.

*/

#include        "ue.h"
#define	local	static

#ifdef STANC
# define P_(s) s
#else
# define P_(s) ()
#endif
local vtputln P_((int n, LINE *lp));
local vteeol P_((void));
local erasepscrln P_((int i));
local reframe P_((WINDOW *wp));
local int curlnupdate P_((WINDOW *wp));
local int hardupdate P_((WINDOW *wp));
local computerowcol P_((void));
local makemodeline P_((uchar *md, BUFFER *bp));
#undef P_

#define WFDEBUG 0                       /* Window flag debug. */
#define VFCHG   0x0001                  /* Changed. */
#define MDLIN   0x0002                  /* Mode line indicator. */


TERM    term;

int     mpresf;				/* TRUE if message in last line */
int     sgarbf;				/* TRUE if screen is garbage */
int     currow;                         /* Working cursor row           */
int     curcol;                         /* Working cursor column        */
int	screenwidth;

local	int     vtrow;			/* Row location of SW cursor	*/
local	int     vtcol;			/* Column location of SW cursor */
local	int     ttrow;			/* Row location of HW cursor	*/
local	int     ttcol;			/* Column location of HW cursor */


local	uchar	*mcp	= NULL;
local	LINE	*mdlp;			/* spare LINE for mode line	*/
local	uchar	*ms;			/* area used by mlwrite		*/
local	uchar	*mlstr;			/* holds the mesg line message	*/
local	int	mloff;			/* == strlen(mlstr)		*/
local	VIDEO   **vscreen;		/* Virtual screen		*/
local	VIDEO   **pscreen;		/* Physical screen		*/


/* Initialize the data structures used by the display code.  The edge
vectors used to access the screens are set up.  pm: (1+term.t_nrow)
because message line is now a window for minibuffer.  Gets called
initially, and then every time we change nrows, or ncols. */

vtinit()				/* redone by pm */
{
	register int nc, j, nr;
	register uchar	*p;

	gfree(NULL);			/* reqd not to bomb on NULL */
	if (mcp) free(mcp);
	sgarbf	= TRUE;	mpresf = FALSE;
	vtrow 	= vtcol	= 0;
	ttrow	= ttcol	= HUGE;

	topen();	
	term.t_nrow = nr = getnrow() - 1;
	screenwidth =
	term.t_ncol = nc = getncol();
	j = 2*(1+nr)*(((uint)sizeof(VIDEO *)) + ((uint)sizeof(VIDEO)) + nc);
	p = mcp = malloc(((uint)sizeof(LINE)) + 6*nc + 2 + 2 + nc + j);
	if (p == NULL) outofroom(); /* which exits */

	mdlp	= (LINE *)(p);  p += ((uint)sizeof(LINE)) + 3*nc + 2;
	ms	= p;            p += 3*nc;
	mlstr	= p; *p = '\0'; p += nc+2; mloff = 0;
	vscreen	= (VIDEO **) p; p += (1+nr)*((uint)sizeof(VIDEO *));
	pscreen = (VIDEO **) p; p += (1+nr)*((uint)sizeof(VIDEO *));
	for (j = 0; j <= nr; ++j)
	{    vscreen[j] = (VIDEO *) p; p += (((uint)sizeof(VIDEO))+nc);
	     pscreen[j] = (VIDEO *) p; p += (((uint)sizeof(VIDEO))+nc);
}	}

uefreeall()	{freeall(); mcp = NULL;}

/* Write a line to the virtual screen.  The virtual row and column are
updated.  If the line is too long put a "$" in the last column.  This
routine only puts printing characters into the virtual terminal
buffers.  Only column overflow is checked.  pm.  */

	local
vtputln(n, lp)
register int	n;	/* row# on the virtual screen */
LINE	*lp;		/* show lp->l_text on the above row */
{
	register uchar		*p, *q, *r;
	register unsigned int	c;

	q = vscreen[vtrow = n]->v_text;
	r = q + term.t_ncol;
	p = lp->l_text;			n = llength(lp);
	while (n-- > 0)			/* invariant: q <= r */
	{	c = *p++;
		isqLTr: if (q == r) {r[-1] = '$'; break;}
		if (c == '\t')
		{	do {	*q++ = ' ';	/* not nec to test q < r */
			} while ((q - r + term.t_ncol) & 0x07);
			continue;
		}				/* display a control char */
		if (c < 0x20) {*q++ = '^'; c += '@'; goto isqLTr;}
		*q++ = c;
	}
	vtcol = q - r + term.t_ncol;
}

/* Erase from the end of the software cursor to the end of the line on
which the software cursor is located.  */

	local
vteeol()
{
	register char	*p, c;
	register int	i, j;

	i = vtcol; j = vtcol = term.t_ncol; c = ' ';
	p = &vscreen[vtrow]->v_text[i];
	while (i++ < j) *p++ = c;
}

/* Erase the physical screen line #i */

	local
erasepscrln(i)
register int	i;
{	register uchar	*p, c;

	p = pscreen[i]->v_text;  c = '\000';
	for (i = term.t_ncol; --i >= 0;)  *p++ = c;
}

/* Refresh the screen.  With no argument, it just does the refresh.
With an argument it recenters "." in the current window.  Bound to
"C-L".  */

refresh(f)
{	if (f == FALSE) sgarbf = TRUE;
	else
	{	curwp->w_force = 0;             /* Center dot. */
		curwp->w_flag |= WFFORCE;
	}
	keysetup();
	return TRUE;
}

/* Winodw framing is not acceptable, compute a new value for the line
at the top of the window.  Then set the "WFHARD" flag to force full
redraw.  */

	local
reframe(wp)
register WINDOW *wp;
{
	register LINE *lp;
	register int	i;

	i = wp->w_force;
	if (i > 0) { --i; if (i >= wp->w_ntrows)  i = wp->w_ntrows-1;}
	else  if (i < 0)  { i += wp->w_ntrows;  if (i < 0) i = 0; }
        else i = wp->w_ntrows/2;
	lp = wp->w_dotp;
	while (i>0 && lback(lp)!=wp->w_bufp->b_linep) {--i;lp = lback(lp);}
	wp->w_linep = lp;
	wp->w_flag |= WFHARD;       /* Force full. */
}

	local int
curlnupdate(wp)
register WINDOW *wp;
{
	register LINE *lp;
	register int	i;

	i = wp->w_toprow;
	for (lp = wp->w_linep; lp != wp->w_dotp; lp = lforw(lp)) ++i;
        vscreen[i]->v_flag |= VFCHG;
	vtputln(i, lp);
        vteeol();
}
	local int
hardupdate(wp)
register WINDOW *wp;
{
	register LINE *lp;
	register int	i, j;

	lp = wp->w_linep; j = wp->w_toprow + wp->w_ntrows;
	for (i = wp->w_toprow; i < j; i++)
	{	vscreen[i]->v_flag |= VFCHG;
		vscreen[i]->v_flag &= ~MDLIN;
		vtrow = i;    vtcol = 0;	/* vtmove(i, 0); */
		if (lp != wp->w_bufp->b_linep)
		{	vtputln(i, lp);
			lp = lforw(lp);
		}
		vteeol();
}	}


/* Always recompute the row and column number of the hardware cursor.
This is the only update for simple moves.  */

	local
computerowcol()
{
	register LINE	*lp;
	register uchar	*p, *q;
	register int	c;

 	currow = curwp->w_toprow;
 	for (lp=curwp->w_linep; lp != curwp->w_dotp; lp=lforw(lp)) ++currow; 
 	curcol = 0;  if (currow == term.t_nrow) curcol = mloff;
 	p = lp->l_text; q = (uchar *) ((long) p + (long) curwp->w_doto);
 	while (p < q)
 	{	c = *p++;
 		if (c == '\t') curcol |= 0x07;
	 	else if (c < 0x20) ++curcol;
 		++curcol;
 	} 
	if (curcol >= term.t_ncol) curcol = term.t_ncol-1;
}

/* Special hacking if the screen is garbage.  Clear the hardware
screen, and update your copy to agree with it.  Set all the virtual
screen change bits, to force a full update.  */

scrgarb()
{
	register int	i;

        for (i = 0; i <= term.t_nrow; ++i)
	{	vscreen[i]->v_flag |= VFCHG;
 		erasepscrln(i);
        }
        sgarbf = FALSE;                 /* Erase-page clears */
        mpresf = FALSE;                 /* the message area. */
	screenerase();
}

/* Make sure that the display is right.  This is a three part process.
First, scan through all of the windows looking for dirty ones.  Check
the framing, and refresh the screen.  Second, make sure that "currow"
and "curcol" are correct for the current window.  Third, make the
virtual and physical screens the same.  */

update()
{
    register WINDOW *wp;
    register LINE *lp;
    register VIDEO *vp1;
    register VIDEO *vp2;
    register int i;

    for (wp = wheadp; wp; wp = wp->w_wndp)
    {   if (wp->w_flag)
 	{   /* If not force reframe, check the framing. */
            if ((wp->w_flag & WFFORCE) == 0)
	    {   lp = wp->w_linep;
                for (i = 0; i < wp->w_ntrows; ++i)
 		{   if (lp == wp->w_dotp)    goto out;
                    if (lp == wp->w_bufp->b_linep)  break;
                    lp = lforw(lp);
            }   }
	    reframe(wp);

out:        if ((wp->w_flag & ~WFMODE) == WFEDIT) curlnupdate(wp);
            else
                if (wp->w_flag & (WFEDIT | WFHARD)) hardupdate(wp);
            if (wp->w_flag&WFMODE) modeline(wp);
            wp->w_flag  = 0;
            wp->w_force = 0;
        }           
    }
    computerowcol();
    if (sgarbf != FALSE) scrgarb();

    /* Make sure that the physical and virtual displays agree. */
    invisiblecursor();
    i = (exitue == -1? term.t_nrow : 0);	/* kludge, for now! */
    for (; i <= term.t_nrow; ++i)
    {   vp1 = vscreen[i];
        if (vp1->v_flag & VFCHG)
        {   vp1->v_flag &= ~VFCHG;
            vp2 = pscreen[i];
            updateline(i, vp1->v_text, vp2->v_text);
    }    }

    /* Finally, update the hardware cursor and flush out buffers. */
    visiblecursor();
    movecursor(currow, curcol);
}

/* Update a single line.  This does not know how to use insert or
delete character sequences; we are using VT52 functionality.  Update
the physical row and column variables.  It does try and exploit erase
to end of line.  */



updateline(row, vline, pline)
uchar *vline;
uchar *pline;
{
	register uchar *vp, *pp, *vq, *pq, *vr, *vs, c;
	register int nbflag, ncol;
 
	if (vscreen[row]->v_flag & MDLIN) onreversevideo();
	ncol = term.t_ncol;
	if (row == term.t_nrow)
 	{	if (mpresf) goto ret;	/* let the mesg stay on screen	*/
		else
		{	vq = ms;
			cpymem(vq, mlstr, mloff); vq += mloff;
			cpymem(vq, vline, ncol);
			vline = ms;
	} 	}

	vp = &vline[0]; vs = vp + ncol;
	pp = &pline[0];

	/* Compute left match.  */
	while (vp < vs && vp[0] == pp[0]) {++vp; ++pp;}
	/*
	This can still happen, even though we only call this routine on changed
	lines. A hard update is always done when a line splits, a massive
	change is done, or a buffer is displayed twice. This optimizes out most
	of the excess updating. A lot of computes are used, but these tend to
	be hard operations that do a lot of update, so I don't really care.
	*/
 	if (vp == vs) goto ret;	/* All equal. */

 	nbflag = FALSE;
 	vq = vs;			/* Compute right match. */
 	pq = &pline[ncol];

 	/* Note if any nonblank in right match. */
 	while (vq[-1] == pq[-1])
 	{	--vq;	--pq;
 		if (vq[0] != ' ') nbflag = TRUE;
        }

 	vr = vq;

 	if (nbflag == FALSE)
	{	while (vr != vp && vr[-1] == ' ') --vr;
		if ((int)(vq-vr) <= 3) vr = vq;
		/* Use only if erase is fewer characters. */
        }

 	movecursor(row, (int)(vp - &vline[0]));
	ttcol += (int) (vr - vp);
 	while (vp < vr)
	{	*pp++ = c = *vp++;
		gputchar(c);
        }

 	if (vr != vq)
        {	toeolerase();
 		while (vp++ != vq)  *pp++ = ' ';
        }
 	ret:
	if (vscreen[row]->v_flag & MDLIN) offreversevideo();
}

#if 00
updateline(row, vline, pline)
uchar *vline;
uchar *pline;
{
	register uchar *cp1, *cp2, *cp3, *cp4, *cp5, c;
	register int nbflag, ncol;
 
	if (vscreen[row]->v_flag & MDLIN) onreversevideo();
	ncol = term.t_ncol;
	if (row == term.t_nrow)
 	{	if (mpresf) goto ret;	/* let the mesg stay on screen	*/
		else
		{	cp3 = ms;
			cpymem(cp3, mlstr, mloff); cp3 += mloff;
			cpymem(cp3, vline, ncol);
			vline = ms;
	} 	}

	cp1 = &vline[0];
	cp2 = &pline[0];

	/* Compute left match.  */
	while (cp1!=&vline[ncol] && cp1[0]==cp2[0]) {++cp1; ++cp2;}
	/*
	This can still happen, even though we only call this routine on changed
	lines. A hard update is always done when a line splits, a massive
	change is done, or a buffer is displayed twice. This optimizes out most
	of the excess updating. A lot of computes are used, but these tend to
	be hard operations that do a lot of update, so I don't really care.
	*/
 	if (cp1 == &vline[ncol]) goto ret;	/* All equal. */

 	nbflag = FALSE;
 	cp3 = &vline[ncol];          /* Compute right match. */
 	cp4 = &pline[ncol];

 	/* Note if any nonblank */             /* in right match. */
 	while (cp3[-1] == cp4[-1])
 	{	--cp3;	--cp4;
 		if (cp3[0] != ' ') nbflag = TRUE;
        }

 	cp5 = cp3;

 	if (nbflag == FALSE)                /* Erase to EOL ? */
        {        while (cp5!=cp1 && cp5[-1]==' ')
 		--cp5;
 		if ((int)(cp3-cp5) <= 3)	/* Use only if erase is */
 			cp5 = cp3;		/* fewer characters. */
        }

 	movecursor(row, (int)(cp1-&vline[0]));	/* Go to start of line. */
 	while (cp1 != cp5)			/* Ordinary. */
	{	*cp2++ = c = *cp1++;
		++ttcol;
		gputchar(c);
        }

 	if (cp5 != cp3)				/* Erase. */
        {	toeolerase();
 		while (cp1 != cp3)  *cp2++ = *cp1++;
        }
 	ret:
	if (vscreen[row]->v_flag & MDLIN) offreversevideo();
}
#endif

/* Make a modeline for a regular/gulam buffer */

	local
makemodeline(md, bp)
BUFFER *bp;
uchar *md;
{
	register uchar	*cp, *mp, patc;
	register uchar	*p1, *p2, *tp, *pmdncol;
	extern   uchar	GulamLogo[], uE[];

	if (bp == setgulambp(FALSE))
	{	tp = GulamLogo;		/* looks: >>gulam<<	*/ 
		p1 = " cwd: "; p2 = gfgetcwd();    
	} else
	{	tp = uE;
		p1 = " buf: "; p2 = bp->b_bname;
	}
	patc = bp->b_modec; pmdncol = &md[term.t_ncol];
	for (mp = md; mp < pmdncol;) *mp++ = patc;
	if ((bp->b_flag&BFCHG) != 0) md[1] = md[2] = '*';

	mp = &md[4]; *mp++ = ' ';
	while (*mp++ = *tp++);		/* title	*/
	*--mp = ' ';  mp += 5;
	if ((bp->b_flag&BFTEMP)!= 0) *mp++ = 't';
	if ((bp->b_flag&BFRDO) != 0) *mp++ = 'r';
	for (mp += 2;     (*mp++ = *p1++););	/* cwd/buf	*/
	for (mp--;        (*mp++ = *p2++););	/* cwd/buf	*/
	*--mp = ' ';
	if (bp->b_fname[0])			/* File name	*/
	{	cp = &bp->b_fname[0];
		for (mp += 4; (*mp++ = *cp++););
		mp[-1] = ' ';
	}
}

/* Redisplay the mode line for the window pointed to by the "wp".
This is the only routine that has any idea of how the modeline is
formatted.  You can change the modeline format by hacking at this
routine.  Called by "update" any time there is a dirty window.  */

modeline(wp)			/* rewritten by pm */
WINDOW *wp;
{
	register uchar	*md;
	register int	n;
	LINE		*lp;
	uchar		mdbuf[sizeof(LINE)+2*150];

	if (wp == mlwp) return;
					/* tired of range checks!	*/
        lp = (LINE *) mdbuf;
	if (lp == NULL) return;
	md = lp->l_text;	lp->l_used = term.t_ncol;
	makemodeline(md, wp->w_bufp);
	n = wp->w_toprow+wp->w_ntrows;              /* Location. */
	vscreen[n]->v_flag |= VFCHG | MDLIN;        /* Redraw next time. */
	vtputln(n, lp);
}

/* Send a command to the terminal to move the hardware cursor to row
"row" and column "col".  The row and column arguments are origin 0.
Optimize out random calls.  Update "ttrow" and "ttcol".  */

movecursor(row, col)
register int	row, col;
{
 	if (row!=ttrow || col!=ttcol)
 	{	mvcursor(row, col);
		ttrow = row;
 		ttcol = col;
}	}

/* Erase the message line. */

mlerase()
{
	movecursor(term.t_nrow, 0);
	toeolerase();
	mpresf = FALSE;
	vscreen[term.t_nrow]->v_flag |= VFCHG;
	erasepscrln(term.t_nrow);
}

/* Ask a yes or no question in the message line.  Return either TRUE,
FALSE, or ABORT.  The ABORT status is returned if the user bumps out
of the question with a ^G.  Used any time a confirmation is required.
*/

mlyesno(prompt)
uchar *prompt;
{
    register int s;
    uchar buf[4];

    for (;;)
    {   buf[0] = '\000';
        s = mlreply(prompt, buf, ((uint)sizeof(buf)));
        if (s == '\007') return (ABORT);
        return (buf[0]=='y' || buf[0]=='Y');
}   }


/* Write a prompt into the message line, then read back a response.
Keep track of the physical position of the cursor.  If we are in a
keyboard macro throw the prompt away, and return the remembered
response.  This lets macros run at full speed.  The reply is always
terminated by a carriage return.  Handle erase, kill, and abort keys.
Returns the terminating char.  */

mlreply(prompt, buf, nbuf)
 	uchar *prompt;
 	uchar *buf;
{ 	register uchar	c;

    mlmesg(prompt);
    c = getuserinput(buf, nbuf);  mlmesg(ES);
    if (c == '\007')	ctrlg(FALSE, 0);
    return c;
}

/* Write a message into the message line.  Keep track of the physical
cursor position.  A small class of printf like format items is
handled.  Set the "message line" flag TRUE.  Should merge with sprintp()
of util.c */

#ifndef	STKGDN
%% we assume run time stack grow down; ckeck it!
%% (see ap += ... in the argument scan loop).
#endif

mlwrite(fmt, arg)			/* rewritten by pm */
uchar *fmt;
long arg;
{
	register int c, r;
	register uchar *ap, *p;

	ap = (uchar *) &arg;	p = ms;
	while (c = *fmt++)
	{  if (c != '%') {*p++ = c; continue;}
           c = *fmt++;	r = 0;
           switch (c)
           {  case 'x': r += 6;
              case 'd': r += 2;
              case 'o': r += 8;
		strcpy(p, itoar((long)(*(int *)ap), r)); p += strlen(p);
		ap += ((uint)sizeof(int));
		break;
              case 'X': r += 6;
              case 'D': r += 2;
              case 'O': r += 8;
		strcpy(p, itoar(*((long *)ap), r)); p += strlen(p);
		ap += ((uint)sizeof(long));
		break;
              case 's':
                    strcpy(p, *(uchar **)ap); p += strlen(p);
                    ap += ((uint)sizeof(uchar *));
                    break;
              default: *p++ = c;
            }
        }
	*p = '\000';

	ttcol = HUGE;
	mlerase();
	offreversevideo();	/* to be sure!! */
	gputs(ms);
	mpresf = TRUE;
}

/* Display in the message line area the string pted by p.  p can == NULL,
which means display the old mlstr again. The new mesg actually gets
seen by the user because there is an update() happening soon after
calling this rtn. */

mlmesg(p)
register uchar *p;
{
	if (p) strcpy(mlstr, p);
	mloff = strlen(mlstr);
	mlerase();
}

/* As above, but with no erase.  We explicitly update() because otherwise
it does not get seen by the user. */

mlmesgne(p)
register uchar *p;
{	register int	n;

	if (p) strcpy(mlstr, p);
	mloff = strlen(mlstr);
	vscreen[term.t_nrow]->v_flag |= VFCHG;
	n = exitue; exitue = -1; update(); exitue = n;
}

/* -eof- */
