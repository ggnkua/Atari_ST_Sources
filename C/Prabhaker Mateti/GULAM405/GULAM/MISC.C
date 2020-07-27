/*
	misc.c -- miscellaneous things re uE interface with gulam

	(c) 1986 pm@Case		11/13/86
*/

#include "ue.h"

#ifdef	TOS
#include "keynames.h"
#endif

extern	uchar	*getprompt(), *prevhist(), *gmalloc();
extern	uchar	GulamLogo[], Mini[];

uchar	msginit[] = "ue as adapted by pm@cwru.edu  03/04/86";

	BUFFER *
setgulambp(f) 		/* gulambp := shell buffer   */
register int	f;
{
	return gulambp = bfind(GulamLogo, f, BFTEMP, GUKB, BMCGUL);

}

setminibp()		/* minibp := minibuffer	*/
{
	minibp = bfind(Mini, TRUE, BFTEMP, MINKB, BMCREG);
}

togulambuf()
{
	switchwindow(wheadp);
	if (setgulambp(TRUE))
	{	switchbuffer(gulambp);
		if (exitue != 0) refresh(FALSE, 1);
		exitue = 0;
}	}

/* Swicth to mesgln window, and to mini buffer.  Then, add the prompt
string to the buffer.  */

tominibuf()		/* called only from main.c of gulam	*/
{
	register uchar *p;

	switchwindow(mlwp);
	setminibp();
	switchbuffer(minibp);	/* minibuf always exists */
	igotoeob();
	p = getprompt(); if (p) {mlmesg(p); gfree(p);} /* add prompt	*/
}

semireset()
{
	bufkill(minibp);	/* flush mini buf */
	tominibuf();
	freewtbl();
}

help()
{
	register KEY	c;

	if (curbp == minibp) {gulamhelp(); return TRUE;}

	mlwrite("help: press B for wall-chart;  C for describe-key: ");
	c = getkey();
	if (c == 'b' || c == 'B') return wallchart();
	if (c == 'c' || c == 'C') return desckey();
	return FALSE;
}

/* Give user feed back by displaying s, which does not contain \r or \n.
Do this only when verbosity is at least the given level.
*/

userfeedback(s, n)
register uchar	*s;
register int	n;
{	extern	uchar	Verbosity[];
	register uchar	c;

	if (varnum(Verbosity) < n) return;
	if (exitue == 0) mlwrite(s);
	else
	{	gputs(s);
		c = s[strlen(s)-1];
		if (c != ':' && c != '?') gputs(CRLF);
}	}

/* Output a string so the user can see it.  If we are in ue, append
"text" to gulam buffer.  Text may contain several lines.  Even if
there is no \r\n at the end treat it as a whole line.  We update() the
buffer because outstr() is invoked often in the middle of a long
computation; it will be quite a while before the update() of uebody()
is done.  */

outstr(text)
uchar *text;
{
	register int	(*fn)();
	extern int	doout(), addline();

	if (text && *text)	/* so we don't make useless updates */
	{	fn = (outisredir() || exitue != 0?  doout : addline);
		if (fn == addline) setgulambp(TRUE);
		streachline(text, fn, gulambp);
		if (fn == addline) {lbpchange(gulambp, WFHARD); update();}
}	}

/* Open a temporary buffer containg file p.  Called by cs.c of Gulam.
*/
	BUFFER *
opentempbuf(p)
register uchar	*p;
{	flvisit(p);
	curbp->b_flag |= (BFTEMP | BFRDO);
	return curbp;
}

/* Close a buffer opened by the above rtn.  We can delete it only if
the nesting level of batch files is zero; o.w.  it may still be in use
by prev levels.  It is thus possible that there are several *.g
buffers hanging around after a batch/source cmd; but that's ok, since
you can enter ue and exit causing all buffers to get killed.  */

closebuf(bp)
register BUFFER *bp;
{
	if (!inbatchfile()) bufkill(bp);
}

addcurbuf(p)
register uchar *p;
{	register uchar c;

	while (c = *p++)
	{	if (c == '\r') {c = '\n'; if (*p == '\n') p++;}
		if (c == '\n') newline(TRUE, 1);
		else	linsert(1, c);
}	}

/* Make a string out of LINE lp.  There is an extra byte in our LINE
structs; see lalloc() in line.c.  Fails if user inserted a \0; but
what the heck!  */
	uchar *
makelnstr(lp)
register LINE * lp;
{	register uchar	*q;

	q = lp->l_text;
	q[llength(lp)] = '\000';
	return q;
}

/* Make a string from the text of the line lp for use as a gulam cmd
line.  Ignore the prompt prefix.  */

	local	uchar *
makecmdstr(lp)
register LINE * lp;
{	register int	n, i;
	register uchar	*p, *q;

	q = gmalloc(1 + (n = lp->l_used)); if (q == NULL) return q;
	cpymem(q, lp->l_text, n); q[n] = '\000';
	p = getprompt();
	if (p)
	{	i = strlen(p);
		if (strncmp(q, p, i) == 0) cpymem(q, q + i, n-i+1);
		gfree(p);
	}
	return q;
}


/*		char terminating getuserinput()				*/
local	int	cgetuserinput;	/* set by miniterm()			*/

/* Get a line of input from kbd, and stuff it into buf[sx..nbuf]. Index
sx == strlen(given buf).  The reply is terminated by one of esc, help,
undo, \r, \n.  The buffer will contain chars upto but not incl this char
followed by \0 at the end.  Handle erase, kill, and abort keys.  Returns the
char that terminated the input.
*/
	uchar
getuserinput(buf, nbuf)
uchar	*buf;
int	nbuf;				/* length of buffer	*/
{
	register WINDOW *wp;
	register BUFFER *bp;
	register int	savedxue, n;
	register LINE * lp;

	setminibp();
	wp = curwp;	switchwindow(mlwp);
	bp = curbp;	if (curbp != minibp) switchbuffer(minibp);
	igotoeob();
	addcurbuf(buf);		/* add the given start string, if any */

	savedxue = exitue; exitue = -1;
	uebody();
	exitue = savedxue;

	lp = curwp->w_dotp;  n = llength(lp);  if (n > nbuf-1) n = nbuf-1;
	cpymem(buf, lp->l_text, n); buf[n] = '\000';
	igotoeob();
	if (bp != curbp) switchbuffer(bp);
	switchwindow(wp);
	return cgetuserinput;
}

/* Insert the corresponding control-char and terminate the
getuserinput() call made using minibuffer.  */

miniterm(f, n, c)
register int c;
{
	cgetuserinput = c & 077;
	exitue = 1;
	return TRUE;
}

escesc(f, n, dummy)	{miniterm(f, n, '\033' );}
escctrld(f, n, dummy)	{miniterm(f, n, '\004' );}

/* TENEX style xpand the current line.  If flag != 0, show the
possible completions.  */

	local
gxp(flag)
register int	flag;
{
	uchar		*p, *q, *r;
	register LINE	*lp;
	extern uchar	*pscolumnize();

	if (curbp != setgulambp(FALSE)) return;
	lp = curwp->w_dotp;
	p  = makecmdstr(lp);
	fnmexpand(&p, &q, 0, 1); /* 1 ==> TENEX */
	if (flag)
	{	r = pscolumnize(q, -1, -1);
		if (r) {outstr(r); gfree(r);}
		igotoeob();
		lp = curwp->w_dotp;
	}
	gfree(q);
	if (p)
	{	curwp->w_doto = 0;
		ldelete(llength(lp), 0);
		q = getprompt(); if (q) {addcurbuf(q); gfree(q);}
		addcurbuf(p);	gfree(p);
}	}

gxpand()	{gxp(0);}
gxpshow()	{gxp(1);}

/* Replace the current line with the previous command obtained from
history */

gforwline(f, n, kk)
{
	if (curbp == setgulambp(FALSE) || curbp == minibp)
	{	register LINE	*lp1, *lp2;
		lp1 = curbp->b_linep;
		lp2 = curwp->w_dotp;
		if ((lp2 == lp1 && backchar(TRUE, 1))
		||   lp2 == lp1->l_bp) goto showhist;
	}
	return (forwline(f, n, kk));

	showhist:
	{ register uchar	*p, *q, *r;
	  q = prevhist();
	  if (q)
	  {	curwp->w_doto = 0;
		kill(TRUE, 1);
		if (curbp == gulambp)
		{	p = str3cat(r = getprompt(), q, ES);
			if (r) gfree(r); gfree(q);
		} else	p = q;
		addline(curbp, p); gfree(p);
		return (backchar(TRUE, 1));
	} }
}

/* Execute the lines of current buffer as Gulam cmds.  If the buffer
is gulam-buffer, output of cmds also will also be considered as cmds.
*/

execbuf()
{
        register BUFFER *bp;
        register int    s;
        char            bufn[NBUFN];

	bp = (curbp != setgulambp(TRUE)? curbp : nextbuffer());
	s = getbufname("Execute cmds in buffer [", bp->b_bname, bufn);
	if (s == ABORT)	  return(ABORT);
	if (s == TRUE && (bp = bfind(bufn, TRUE, 0, REGKB, BMCREG)) == NULL)
		return(FALSE);
	if (bp != gulambp)
	{	switchbuffer(bp);
		mlwrite("(cmd output will be in \257gul\204m\256 buffer)");
		csexecbuf(bp);
}	}

/* Execute one Gulam cmd, and return to where we were.  Output does no
get deposited in any buffer.  */

spawn()
{
	register WINDOW	*wp;
	register int	savedxue;

	savedxue = exitue; exitue = -1; wp = curwp;
	getcmdanddoit();			/* see main.c of gulam */
	exitue = savedxue; sgarbf = TRUE;
	getkey();				/* await a key press	*/
	switchwindow(wp);
	mlmesg(ES);
}

#if	MYTRAPS

/* Called via mytrap handlers.  Similar to Bconout(), Cconout()	*/

gconout(c)
register int	c;
{
	linsert(1, c); update();
}

gcconws(p)
register char	*p;
{
	addcurbuf(p); update();
}

gfwrite(n, s)
register long	n;
register char	*s;
{	register char	c;

	while (n--)
	{	c = *s++;
		if (c == '\r') continue;
		if (c == '\n') lnewline();
		else linsert(1, c);
	}
	update();
}


long	oldp1, oldp13;
extern	int	mytrap1(), mytrap13();

	local
planttraps113()
{	register long	n;

#if 00
	n = Super(0L);	/* 0x84, and 0xb4 are std MC680x0 vectors */
	oldp1  = *((long *) 0x84L); *((long *) 0x84L) = (long) mytrap1;
/*	oldp13 = *((long *) 0xb4L); *((long *) 0xb4L) = (long) mytrap13; */
	Super(n);
#endif
	oldp1 = Setexc(33, mytrap1);

}

	local
unplanttraps113()
{	register long	n;

#if 00
	n = Super(0L);
	*((long *) 0x84L) = oldp1;
/*	*((long *) 0xb4L) = oldp13; */
	Super(n);
#endif
	Setexc(33, oldp1);

}

#else		/* ! MYTRAPS */
#define planttraps113() 
#define unplanttraps113()
#endif

/* Execute a shell command given on the current line */


gulam()
{
	register uchar	*p, *q, *r, c;
	register LINE	*lp;

	lp = curwp->w_dotp;
	q = makecmdstr(lp);
	if (lp != gulambp->b_linep->l_bp)
	{	/*invoked cmd was not the last line */
		p = str3cat(r = getprompt(), q, ES);   if (r) gfree(r);
		outstr(p);
		gfree(p);
	} else	{gotoeol(FALSE, 1); newline(FALSE, 1);}

	planttraps113();
	processcmd(q, 1);	/* q is gfreed by processcmd */
	unplanttraps113();

	igotoeob();
	p = getprompt(); if (p) {addcurbuf(p); gfree(p);} /* add prompt */
	wupdatemodeline(curbp);
	return TRUE;
}

#if 00
gnewline(f, n, kk)
{
	if (curbp == setgulambp(FALSE)) {gulam(); return TRUE;}
	if (curbp == minibp) {exitue = 1; return TRUE;}
	else return(newline(f, n, kk));
}
#endif

/* -eof- */
