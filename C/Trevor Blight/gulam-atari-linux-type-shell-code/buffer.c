/*
	buffer.c of uE/Gulam -- Buffer management of uE

This module is considerably different from the original microEmacs
version (3.5 and up).

*/

#include        "ue.h"

#ifdef STANC
# define P_(s) s
#else
# define P_(s) ()
#endif
local killbf P_((BUFFER *bp));
local showbuffer P_((BUFFER *bp, WINDOW *wp, int flags));
local bufitoa P_((uchar buf[], int width, long num));
local makelist P_((void));
#undef P_

extern	uchar	Bufferlist[];

extern int insertborf(); /* insert file or buffer */

int bclear();            /* clear buffer */

BUFFER  *bheadp; 			/* BUFFER listhead              */
BUFFER  *curbp;                         /* Current buffer               */
BUFFER  *listbp; 			/* Buffer list BUFFER           */
BUFFER  *minibp;                        /* mini buffer                  */
BUFFER	*gulambp;

#ifdef	DM				/* see ue.h */

void cpdotmark(p, q)
register long	*p, *q;
{
	*p++ = *q++; *p++ = *q++; *p = *q;
}

#else
void wwdotmark(wp2, wp)				/* pm */
register WINDOW	*wp2, *wp;
{
	wp2->w_dotp  = wp->w_dotp;
	wp2->w_doto  = wp->w_doto;
	wp2->w_markp = wp->w_markp;
	wp2->w_marko = wp->w_marko;
}

wbdotmark(wp, bp)				/* pm */
register BUFFER	*bp;
register WINDOW	*wp;
{
	wp->w_dotp  = bp->b_dotp;
	wp->w_doto  = bp->b_doto;
	wp->w_markp = bp->b_markp;
	wp->w_marko = bp->b_marko;
}

(void) bwdotmark(bp, wp)				/* pm */
register BUFFER	*bp;
register WINDOW	*wp;
{
	bp->b_dotp  = wp->w_dotp;
	bp->b_doto  = wp->w_doto;
	bp->b_markp = wp->w_markp;
	bp->b_marko = wp->w_marko;
}
#endif

/* Prompt for a buffer name using the given promt string and the default name;
does tenex style name completion.
*/

getbufname(fps, defnm, bnm)				/* pm */
uchar *fps, *defnm, *bnm;
{	register uchar	*blst, *ps, c;
        register BUFFER *bp;
	register WS	*ws;
	register int	n;

	ws = NULL;
	ps = str3cat(fps, defnm, "]: "); if (ps == NULL) ps = fps;
	mlmesg(ps);  if (ps != fps) gfree(ps); 	else goto EBLST;

	ws = initws();	/* make a list of buffer names */
	for (n=0, bp=bheadp; bp; bp = bp->b_bufp)
		strwcat(ws, bp->b_bname, 1);
	blst = ws->ps;

	EBLST:	 *bnm = '\000';	/* TENEX style buffer name expansion */
	while ((c = getuserinput(bnm, NBUFN)) == '\033')
	{	nameexpand(blst, bnm, 1);
		mlmesg(NULL);
	}
	mlmesg(ES);  freews(ws);
	if (*bnm == '\000') strcpy(bnm, defnm);
	if (c == '\007') return ABORT;
	return (c == '\r' || c == '\n');
}


/* Get next regular buffer; the returned buffer pointer is never NULL.
Make a real effort to return a bp != curbp; this is not always
possible.  Note that bheadp != NULL.  The next buffer got CAN be the
>>buflist<<, or >>minibuf<<.  -pm */

	BUFFER *
nextbuffer()				/* pm */
{
	register  BUFFER *bp;

	bp = curbp->b_bufp;
	if (bp == NULL || bp == minibp || bp == listbp)
		for (bp = bheadp;
			bp && ((bp == minibp) || (bp == listbp));)
				bp = bp->b_bufp;
	if (bp == NULL) bp = bheadp;

	return bp;
}

#if 000
	BUFFER *
nextbuffer()				/* pm */
{
  register  BUFFER *bp;

  bp = curbp->b_bufp;
  if (bp == NULL) bp = bheadp;
  if (bp == minibp || bp == listbp) bp = bp->b_bufp;
  if (bp == NULL) bp = bheadp;	/* #buffers can be 1 */
  return bp;
}
#endif


/* Attach a buffer to a window.  The values of dot and mark come from
the buffer if the use count is 0.  Otherwise, they come from some
other window.  */

usebuffer()
{
        register BUFFER *bp;
        register int    s;
        uchar            bufn[NBUFN];

	bp = nextbuffer(); 
	s = getbufname("Switch to buffer [", bp->b_bname, bufn);
	if (s == ABORT)	  return(ABORT);
	if (s == TRUE && (bp = bfind(bufn, TRUE, 0, REGKB, BMCREG)) == NULL) 
		return FALSE;
	return switchbuffer(bp);
}

switchbuffer(bp)
register BUFFER *bp;
{
        register WINDOW *wp;

        if (--curbp->b_nwnd == 0) bwdotmark(curbp, curwp);
        curbp = bp;                             /* Switch.              */
        curwp->w_bufp  = bp;
        curwp->w_linep = bp->b_linep;
        curwp->w_flag |= WFMODE|WFFORCE|WFHARD; /* Quite nasty.         */
        if (bp->b_nwnd++ == 0)
	{	wbdotmark(curwp, bp);		/* First use.           */
                return TRUE;
        }                            /* Look for old.        */
	for (wp = wheadp; wp; wp = wp->w_wndp)
	{	if (wp!=curwp && wp->w_bufp==bp)
		{	wwdotmark(curwp, wp);
                        break;
	}	}
        return TRUE;
}


bufinsert(bufn)
register uchar	*bufn;
{	register BUFFER *bp;
	register LINE	*clp, *lp;
	register int	n;
   extern	int	lnn;
	extern	long	ntotal;

	bp = bfind(bufn, FALSE, 0, REGKB, 0);
	if (bp == NULL) return FALSE;
	if (bp == curbp)
	{	mlwrite("Cannot insert buffer into self");
		return FALSE;
	}
	lp = curwp->w_dotp; lnn = 0; ntotal = 0L;
	for (clp = lforw(bp->b_linep); clp != bp->b_linep; clp = lforw(clp))
	{	n = llength(clp);
		if (lnlink(lp, clp->l_text, n) == NULL) return FALSE;
		lnn++; ntotal += n;
	}
	curbp->b_flag |= BFCHG;
	return TRUE;
}

/* Insert another buffer at dot.  Very useful. */

bufferinsert()
{
	register BUFFER *bp;
	register int	s;
	uchar		bufn[NBUFN];

	bp = nextbuffer();
	s = getbufname("Insert buffer [", bp->b_bname, bufn);
	if (s == ABORT) return (s);
	if (s == TRUE) 	s = insertborf(bufn, 1);
	curwp->w_flag |= WFMODE | WFHARD;
	return s;
}

	local
killbf(bp)
register BUFFER *bp;
{
        register BUFFER *bp1, *bp2;
        register int    s;

        if ((s=bclear(bp)) != TRUE) return s;
        free((uchar *) bp->b_linep);	/* Release header line. */
 					/* Find the header.     */
	for (bp1 = NULL, bp2 = bheadp; bp2 != bp; bp2 = bp2->b_bufp)
                bp1 = bp2;
        bp2 = bp2->b_bufp; 		/* Next one in chain.   */
        if (bp1) bp1->b_bufp = bp2;
        else     bheadp = bp2;
	if (curbp == bp) curbp = bheadp;
        free((uchar *) bp); 		/* Release buffer block */
	mlerase();
	if (bp == gulambp) gulambp = NULL; else
	if (bp == minibp)  minibp  = NULL; else
	if (bp == listbp)  listbp  = NULL;
        return TRUE;
}

/* Kill buffer pted by bp, and switch to another.  If there is no
other buffer to switch to, we switch to Gulam.  */

bufkill(bp)
register BUFFER *bp;
{
        register BUFFER *bp1;
        register WINDOW *wp;

	if (bp == NULL) return TRUE;
	bp1 = nextbuffer();
	if (bp1 == bp) bp1 = setgulambp(TRUE);
	if (bp1 && bp1 != bp) switchbuffer(bp1); else return FALSE;
	for (wp = wheadp; wp; wp = wp->w_wndp)
	    if (wp->w_bufp == bp)
	    {	wp->w_bufp  = bp1; wbdotmark(wp, bp1);
		wp->w_linep = bp1->b_linep;
		wp->w_flag |= WFMODE|WFFORCE|WFHARD;
		bp1->b_nwnd++;
	    }
	return killbf(bp);
}

/* Dispose of a buffer, by name.  Ask for the name.  Look it up.  Ok
if if it isn't there at all.  Kill the buffer.  Bound to "C-X K".
Default buffer to kill added by -pm */

killbuffer()
{	register int	s;
	register BUFFER *bp;
	uchar            bufn[NBUFN];

	s = getbufname("Kill buffer [", curbp->b_bname, bufn);
	if (s == ABORT)	  return(ABORT);
	bp = (s == FALSE? curbp : bfind(bufn, FALSE, 0, REGKB, 0));
	return bufkill(bp);
}

/* Display the given buffer in the given window.  Flags indicated
action on redisplay.  */

	local
showbuffer(bp, wp, flags)
register BUFFER *bp;
register WINDOW *wp;
{
	register BUFFER	*obp;
	register WINDOW	*owp;

	if (wp->w_bufp == bp)			/* Easy case!	*/
	{	wp->w_flag |= flags;
		return TRUE ;
	}

	/* First, dettach the old buffer from the window */
	if ((obp = wp->w_bufp) != NULL && --obp->b_nwnd == 0)
		bwdotmark(obp, wp);

	/* Now, attach the new buffer to the window */
	wp->w_bufp = bp;

	if (bp->b_nwnd++ == 0)	wbdotmark(wp, bp);
	else
	{	/* already on screen, steal values from other window */
		for (owp = wheadp; owp != NULL; owp = wp->w_wndp)
			if (wp->w_bufp == bp && owp != wp)
			{	wwdotmark(wp, owp);
				break;
	}		}
	wp->w_flag |= WFMODE|flags;
	return TRUE;
}

/* Pop the buffer we got passed onto the screen.  */

	WINDOW *
popbuf(bp)
register BUFFER *bp;
{	register WINDOW	*wp;

	if (bp == NULL) return NULL;
	if (bp->b_nwnd == 0)		/* Not on screen yet.	*/
	{	if ((wp = wpopup())
		&&   showbuffer(bp, wp, WFHARD) != TRUE)  return NULL;
	} else	/* bp must be == some wp->w_bufp because bp is on screen */
		for (wp = wheadp; wp; wp = wp->w_wndp)
			if (wp->w_bufp == bp)
			{	wp->w_flag |= WFHARD|WFFORCE;
				break;
			}
	return wp;
}


	local
bufitoa(buf, width, num)
register uchar   buf[];
register int    width;
register long   num;
{
        while (num >= 10)			/* Conditional digits.  */
	{	buf[--width] = (num%10) + '0';
                num /= 10;
        }
        buf[--width] = num + '0';		/* Always 1 digit.      */
        while (width > 0)			/* Pad with blanks.     */
                buf[--width] = ' ';
}

/* This routine rebuilds the text in the special secret buffer that
holds the buffer list.  It is called by the list buffers command.
Return TRUE if everything works.  Return FALSE if there is an error
(if there is no memory).  */

	local
makelist()
{
        register uchar   *p, *q;
        register BUFFER *bp;
        register LINE   *lp;
        register long   nbytes;
        register int    c, s;
        uchar            line[128];

 	listbp = bfind(Bufferlist, TRUE, BFTEMP, REGKB, BMCTMP);
 	if (listbp == NULL) return FALSE;
 	listbp->b_flag &= ~BFCHG;               /* Don't complain!      */
	if ((s=bclear(listbp)) != TRUE)         /* Blow old text away   */
		return (s);
	strcpy(listbp->b_fname, ES);
        if (addline(listbp, "trc         Size Buffer           File") == FALSE
        ||  addline(listbp, "--- ------------ ------           ----") == FALSE)
                return (FALSE);
	for (bp = bheadp; bp; bp = bp->b_bufp)
	{	p = &line[0];                 /* Start at left edge   */
		*p++ = (bp->b_flag&BFTEMP? 't' : '-');
		*p++ = (bp->b_flag&BFRDO ? 'r' : '-');
		*p++ = (bp->b_flag&BFCHG ? '*' : '-');
		*p++ = ' ';  nbytes = 0L;
		for (lp = lforw(bp->b_linep); lp != bp->b_linep;lp = lforw(lp))
			nbytes += llength(lp)+2;  /* cr+lf	*/
                bufitoa(p, 12, nbytes);	/* 12 digit buffer size	*/
		p += 12; *p++ = ' ';
                for (q = &bp->b_bname[0]; (*p++ = *q++););
		p --; q = &bp->b_fname[0];
                if (*q)
		{	while (p < &line[1+1+12+1+NBUFN+1]) *p++ = ' ';
                        while (c = *q++)
                        	if (p < &line[128-1]) *p++ = c;
                }
                *p = 0;
		if (addline(listbp, line) == FALSE) return (FALSE);
        }
        return TRUE;
}

/* List all buffers.  First update the special buffer that holds the
list.  Next make sure at least 1 window is displaying the buffer list,
splitting the screen if this is what it takes.  Lastly, repaint all of
the windows that are displaying the list.  Bound to "C-X C-B".  */

listbuffers()
{	register WINDOW *wp;

	if (makelist() != TRUE || (wp=popbuf(listbp)) == NULL) return FALSE;
	wp->w_dotp = listbp->b_dotp;	/* fix up if window already on screen */
	wp->w_doto = listbp->b_doto;
	return TRUE;
}

/* Apennd the line given by text to the buffer bp.  Return TRUE if it
worked and FALSE if you ran out of room.  */

addline(bp, text)
register BUFFER	*bp;
register uchar	*text;
{
        register LINE   *lp;

	if (bp == NULL || text == NULL) return FALSE;
	if (lp = lnlink(bp->b_linep, text, ((int)strlen(text))))
	    if (bp->b_dotp == bp->b_linep)	/* If dot is at the end */
                bp->b_dotp = lp; 		/* move it to new line  */
        return (lp != NULL);
}


/* Look through the list of buffers.  Return TRUE if there are any
changed buffers.  Buffers that hold magic internal stuff (BFTEMP) are
not considered.  Return FALSE if no buffers have been changed.  */

anycb()
{
        register BUFFER *bp;

	for (bp = bheadp; bp; bp = bp->b_bufp)
		if ((bp->b_flag&BFTEMP)==0 && (bp->b_flag&BFCHG)!=0)
                        return TRUE;
        return FALSE;
}

/* Find a buffer, by name.  Return a pointer to the BUFFER structure
associated with it.  If the buffer is not found and the cflag is TRUE,
create it.  */

	BUFFER  *
bfind(bname, cflag, bflag, keybinds, bmodec)
register uchar   *bname, bmodec;
unsigned int	cflag, bflag;
int		keybinds;
{
        register BUFFER *bp;
        register LINE   *lp;

	for (bp = bheadp; bp; bp = bp->b_bufp)
		if (strcmp(bname, bp->b_bname) == 0) return (bp);
        if (cflag != FALSE)
        {	bp = (BUFFER *) malloc((uint)sizeof(BUFFER));
		if (bp == NULL) return (NULL);
                if ((lp=lalloc(0)) == NULL)
		{	free((uchar *) bp);
                        return (NULL);
                }
		lp->l_fp    = lp;		lp->l_bp    = lp;	
		bp->b_linep = lp;		bp->b_kbn   = keybinds;
		bp->b_dotp  = lp;		bp->b_markp = NULL;
		bp->b_doto  = 0;		bp->b_marko = 0;
                bp->b_nwnd  = 0;                bp->b_flag  = bflag;
		strcpy(bp->b_fname, ES);	strcpy(bp->b_bname, bname);
		bp->b_bufp  = bheadp;		bp->b_modec = bmodec;
		bheadp = bp;
        }
        return bp;
}

/* This routine blows away all of the text in a buffer.  If the buffer
is marked as changed then we ask if it is ok to blow it away; this is
to save the user the grief of losing text.  The window chain is nearly
always wrong if this gets called; the caller must arrange for the
updates that are required.  The last dummy line (pted by bp->b_linep) is
not lfreed.  Return TRUE if everything looks good.  */

bclear(bp)
register BUFFER *bp;
{
        register LINE   *lp;
        register int    s;

        if ((bp->b_flag & BFTEMP) == 0		/* Not scratch buffer.  */
        &&  (bp->b_flag & BFCHG)  != 0		/* Something changed    */
        &&  (s = mlyesno(sprintp
		("Discard changed buffer \257%s\256?", bp->b_bname))) != TRUE
	)  return s;

        while ((lp=lforw(bp->b_linep)) != bp->b_linep)
                lfree(lp);
        bp->b_dotp  = bp->b_linep;              /* Fix "."              */
        bp->b_doto  = 0;
        bp->b_markp = NULL;                     /* Invalidate "mark"    */
        bp->b_marko = 0;
        bp->b_flag  &= ~BFCHG;                  /* Not changed          */
	return  TRUE;
}

/* Save some buffers.  Save all if flag == TRUE.  Return ABORT is user
aborted it; return TRUE if either there is nothing to save, or if all
buffers were saved; return FALSE if user did not want to save a
changed buffer.  */

savebuffers(f)
{	register BUFFER	*bp;
	register int	s, nsave;

	nsave = 0;
	if (anycb() == FALSE) mlwrite("(No changed buffers)");
	else
	{	listbuffers();	update();
		for (bp = bheadp; bp; bp = bp->b_bufp)
		{	if (bp->b_fname[0] && (bp->b_flag&BFCHG))
			{	s = (f? f :
				mlyesno(sprintp("Save file %s?", bp->b_fname)));
				if (s == TRUE &&  flsave(bp) == TRUE)
				{	bp->b_flag &= ~BFCHG;
					wupdatemodeline(bp);
				} else	nsave++;
				if (s == ABORT) return s;
		}	}
		killwindow(popbuf(listbp));
		bufkill(listbp);
	}
	return (nsave == 0);
}

extern	uchar	Completions[];

killcompletions()		/* pm */
{	register BUFFER	*bp;

	bp  = bfind(Completions, FALSE, BFTEMP, REGKB, 0);
	if (bp)
	{	killwindow(popbuf(bp));
		bufkill(bp);
}	}

void showcompletions(text)		/* pm */
uchar *text;
{	register WINDOW *wp;
	register BUFFER	*bp;

        bp = bfind(Completions, TRUE, BFTEMP, REGKB, BMCTMP);
	if (bp == NULL) return;
	bclear(bp);
	streachline(text, addline, bp);
	if ((wp=popbuf(bp)) == NULL) return;
	wp->w_dotp = bp->b_dotp;	/* fix up if window already on screen */
	wp->w_doto = bp->b_doto;
	update();
}

bufinit()
{
	bheadp	= listbp = NULL;
	curbp	= setgulambp(TRUE);
	if (curbp == NULL) outofroom();
}

/* -eof- */
