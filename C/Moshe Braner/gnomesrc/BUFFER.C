/*
 * Buffer management.
 * Some of the functions are internal,
 * and some are actually attached to user
 * keys. Like everyone else, they set hints
 * for the display system.
 */
#include	<stdio.h>
#include	"ed.h"

extern update();
extern int ctrlg();

/*
 * mb: code common to usebuffer() and killbuf().
 */
int
choosebuf(prompt, bufn)
	char	*prompt, *bufn;
{
	int	s;
	BUFFER	*bp, *bp2;
	char	*dflt;

	bp = oldbp;
	if (bp != curbp && bp != NULL)
		dflt = bp->b_bname;
	else {
		bp = curbp;
		dflt = NULL;
	}
again:
	s = mlreply(prompt, dflt, bufn, NBUFN, FALSE);

	if (bheadp==curbp && curbp->b_bufp==NULL)	/* only one buffer */
		goto only;

	if (s == UP) {
upup:		if (bp == bheadp) {
			while (bp->b_bufp != NULL)
				bp = bp->b_bufp;
		} else {
			bp2 = bp;
			bp = bheadp;
			while (bp->b_bufp != bp2)
				bp = bp->b_bufp;
		}
		if (bp==curbp || bp==blistp || bp==bhelpp)
			goto upup;
		dflt = bp->b_bname;
		goto again;
	}
	if (s == DOWN) {
dndn:		bp = bp->b_bufp;
		if (bp == NULL)
			bp = bheadp;
		if (bp==curbp || bp==blistp || bp==bhelpp)
			goto dndn;
		dflt = bp->b_bname;
		goto again;
	}
only:
	if (s != TRUE && s != FALSE)
		return (ABORT);
	return (TRUE);
}

/*
 * Attach a buffer to a window. The values of dot and
 * mark come from the buffer if the use count is 0.
 * Otherwise, they come from some other window.
 * mb: added the prompt, oldbp stuff; only allow lowercase
 * in bufnames, and put the meat in choosebuf() and gotobuf().
 */
usebuffer(f, n)
{
	BUFFER	*bp;
	char	bufn[NBUFN];

	if (choosebuf("Use buffer", bufn) != TRUE)
		return (ctrlg());
	if ((bp=bfind(bufn, TRUE, BFEDIT)) == NULL)
		return (FALSE);
	gotobuf(bp);
	curwp->w_flag |= (WFMODE|WFFORCE|WFHARD);	/* Quite nasty. */
	return (TRUE);
}

/* mb: split off usebuf() */
gotobuf(bp)
	BUFFER *bp;
{
	WINDOW	*wp;

	if (--curbp->b_nwnd == 0) {		/* Last use.		*/
		curbp->b_dotp  = curwp->w_dotp;
		curbp->b_doto  = curwp->w_doto;
		curbp->b_markp = curwp->w_markp;
		curbp->b_marko = curwp->w_marko;
	}
	oldbp = curbp;				/* mb: added		*/
	curbp = bp;				/* Switch.		*/
	curwp->w_bufp = bp;
	curwp->w_flag |= WFMOVE;		/* force a reframe CHECK */
	if (bp->b_nwnd++ == 0) {		/* First use.		*/
		curwp->w_linep = bp->b_linep;
		curwp->w_dotp  = bp->b_dotp;
		curwp->w_doto  = bp->b_doto;
		curwp->w_markp = bp->b_markp;
		curwp->w_marko = bp->b_marko;
		curwp->w_force = 0;	/* mb: attempt frame to middle */
		return;
	}
	wp = wheadp;				/* Look for old.	*/
	while (wp != NULL) {
		if (wp!=curwp && wp->w_bufp==bp) {
			curwp->w_linep = wp->w_linep;
			curwp->w_dotp  = wp->w_dotp;
			curwp->w_doto  = wp->w_doto;
			curwp->w_markp = wp->w_markp;
			curwp->w_marko = wp->w_marko;
			break;
		}
		wp = wp->w_wndp;
	}
	return;
}

/*
 * Dispose of a buffer, by name.
 * Ask for the name. Look it up (don't get too
 * upset if it isn't there at all!). Get quite upset
 * if the buffer is being displayed. Clear the buffer (ask
 * if the buffer has been changed). Then free the header
 * line and the buffer header. Bound to "C-X K".
 * mb: call choosebuf().
 */
killbuffer(f, n)
{
	register BUFFER	*bp;
	register int	s;
	char		bufn[NBUFN], *dflt;

	if (choosebuf("Buffer to kill", bufn) != TRUE)
		return (ctrlg());

	if ((bp=bfind(bufn,FALSE,0))==NULL || bp==blistp || bp==bhelpp) {
		mlwrite("Buffer not found");
		return (FALSE);
	}
	if (bp->b_nwnd != 0) {			/* Error if on screen.	*/
		mlwrite("Buffer is being displayed");
		return (FALSE);
	}
	if (bclear(bp) != TRUE)
		return (FALSE);
	freebuf(bp);
	mlwrite("[killed]");
	return (TRUE);
}

freebuf(bp)			/* must bclear() the text first! */
	register BUFFER *bp;
{
	register BUFFER *bp2;
	register BUFFER *bp1;

	free((char *) bp->b_linep);		/* Release header line.	*/
	bp1 = NULL;				/* Find the header.	*/
	bp2 = bheadp;
	while (bp2 != bp) {
		bp1 = bp2;
		bp2 = bp2->b_bufp;
	}
	bp2 = bp2->b_bufp;			/* Next one in chain.	*/
	if (bp1 == NULL)			/* Unlink it.		*/
		bheadp = bp2;
	else
		bp1->b_bufp = bp2;
	free((char *) bp);			/* Release buffer block	*/
	if (oldbp == bp)
		oldbp = NULL;
	return;
}

/* mb: added function to toggle edit/view */

int editog(f,n)
{
	register WINDOW *wp;

	if (curbp->b_flag & BFEDIT) {
		mlwrite("[view only]");
		curbp->b_flag &= ~BFEDIT;
	} else {
		mlwrite("[edit]");
		curbp->b_flag |= BFEDIT;
	}
	wp = wheadp;
	while (wp != NULL) {
		if (wp->w_bufp == curbp)
			wp->w_flag |= WFMODE;
		wp = wp->w_wndp;
	}
	return (TRUE);
}

/*
 * Show a temporary buffer in a pop-up window.
 * First update the temporary buffer, next make
 * sure at least 1 window is displaying the
 * buffer, splitting the screen if this is what
 * it takes. Lastly, repaint all of the windows
 * that are displaying it. (by mb:)
 */
make_popup(buffer, prepare, data)
	BUFFER	*buffer;		/* which temp buffer	*/
	int	(*prepare)();		/* function pointer	*/
	char	*data[];     		/* array of strings	*/
{
	register WINDOW	*wp;
	register BUFFER	*bp;
	register int	s;

	if ((s=(*prepare)(buffer, data)) != TRUE)
		return (s);

	if (buffer->b_nwnd == 0) {		/* Not on screen yet.	*/
		if ((wp=wpopup()) == NULL)
			return (FALSE);
		bp = wp->w_bufp;
		if (--bp->b_nwnd == 0) {
			bp->b_dotp  = wp->w_dotp;
			bp->b_doto  = wp->w_doto;
			bp->b_markp = wp->w_markp;
			bp->b_marko = wp->w_marko;
		}
		bp = buffer;
		wp->w_bufp  = bp;
		++bp->b_nwnd;
	}
	bp = buffer;
	wp = wheadp;
	while (wp != NULL) {
		if (wp->w_bufp == bp) {
			wp->w_linep = lforw(bp->b_linep);
			wp->w_dotp  = lforw(bp->b_linep);
			wp->w_doto  = 0;
			wp->w_markp = NULL;
			wp->w_marko = 0;
			wp->w_flag |= (WFMODE|WFHARD|WFFORCE);
		}
		wp = wp->w_wndp;
	}
#if (AtST | MSDOS)
	mlwrite("[Alt-1 returns to one window]");
#else
	mlwrite("[^X 1 returns to one window]");
#endif
	return (TRUE);
}

/*
 * This routine rebuilds the
 * text in the special secret buffer
 * that holds the buffer list. It is called
 * by the list buffers command. Return TRUE
 * if everything works. Return FALSE if there
 * is an error (if there is no memory).
 */
makelist(buffer, data)
	BUFFER	*buffer;
	char	*data[];	/* not used */
{
	register char	*cp1;
	register char	*cp2;
	register int	c;
	register long	nbytes;
	register BUFFER	*bp;
	register LINE	*lp;
	register int	i;
	register int	type;
	char		b[8];
	char		line[128];

	bp = buffer;
	bbclear(bp);				/* Blow old text away	*/
	if (addline("\tC   Size Buffer           File", bp) == FALSE
	||  addline("\t-   ---- ------           ----", bp) == FALSE)
		return (FALSE);
	for (bp=bheadp; bp!=NULL; bp=bp->b_bufp) {  /* For all buffers	*/
		if (bp==blistp || bp==bhelpp)	/* mb: list other temps	*/
			continue;
		cp1 = &line[0];
		*cp1++ = '\t';
		if (bp->b_flag&BFCHG)
			*cp1++ = '*';		/* "*" if changed	*/
		else
			*cp1++ = ' ';
		*cp1++ = ' ';
		nbytes = 0;			/* Count bytes in buf.	*/
		lp = lforw(bp->b_linep);
		while (lp != bp->b_linep) {
#if V7
			nbytes += llength(lp)+1;
#else
			nbytes += llength(lp)+2;
#endif
			lp = lforw(lp);
		}
		pltoa(b, 6, nbytes);		/* 6 digit buffer size.	*/
		cp2 = &b[0];
		while ((c = *cp2++) != 0)
			*cp1++ = c;
		*cp1++ = ' ';
		cp2 = &bp->b_bname[0];		/* Buffer name		*/
		for (i=0; (c = *cp2++) && i<15; i++)
			*cp1++ = c;
		if (c)  *cp1++ = '$';
		cp2 = &bp->b_fname[0];		/* File name		*/
		if (*cp2 != 0) {
			while (cp1 < &line[27])
				*cp1++ = ' ';		
			i = 35;
			while ( (c = *cp2++)
				   && ++i < term.t_ncol
				   && cp1 < &line[125]  ) {
				*cp1++ = c;
			}
		}
		if (c)  *cp1++ = '$';
		*cp1 = 0;			/* Add to the buffer.	*/
		if (addline(line, buffer) == FALSE)
			return (FALSE);
	}
	return (TRUE);				/* All done		*/
}

pltoa(buf, width, num)
	register char	buf[];
	register int	width;
	register long	num;
{
	buf[width] = 0;				/* End of string.	*/
	while (num >= 10) {			/* Conditional digits.	*/
		buf[--width] = (num%10) + '0';
		num /= 10;
	}
	buf[--width] = num + '0';		/* Always 1 digit.	*/
	while (width != 0)			/* Pad with blanks.	*/
		buf[--width] = ' ';
}

/*
 * List all of the active buffers. Bound to "C-X ?".
 */
listbuffers(f, n)
{
	return (make_popup (blistp, makelist, (char **) NULL));
}


/*
 * The argument "text" points to a string.
 * Append this line to the buffer *bp.
 * Handcraft the EOL on the end.
 * Return TRUE if it worked and
 * FALSE if you ran out of room.
 */
addline(text, bp)
	char *text;
	register BUFFER	*bp;
{
	register LINE	*lp;
	register int	i;
	register int	ntext;

	ntext = strlen(text);
	if ((lp=lalloc(ntext)) == NULL)
		return (FALSE);
	for (i=0; i<ntext; ++i)
		lputc(lp, i, text[i]);
	bp->b_linep->l_bp->l_fp = lp;		/* Hook onto the end	*/
	lp->l_bp = bp->b_linep->l_bp;
	bp->b_linep->l_bp = lp;
	lp->l_fp = bp->b_linep;
	if (bp->b_dotp == bp->b_linep)		/* If "." is at the end	*/
		bp->b_dotp = lp;		/* move it to new line	*/
	return (TRUE);
}

/*
 * Look through the list of
 * buffers. Return TRUE if there
 * are any changed buffers. Buffers
 * that hold magic internal stuff are
 * not considered; who cares if the
 * list of buffer names is hacked.
 * Return FALSE if no buffers
 * have been changed.
 */
anycb()
{
	register BUFFER	*bp;

	bp = bheadp;
	while (bp != NULL) {
		if ((bp->b_flag&BFTEMP)==0 && (bp->b_flag&BFCHG)!=0)
			return (TRUE);
		bp = bp->b_bufp;
	}
	return (FALSE);
}

/*
 * mb: delete the text of temporary buffers.
 * Called by lalloc() and enlrg_kbuf if needed.
 */
dtmpbufs()
{
	register BUFFER	*bp;

	bp = bheadp;
	while (bp != NULL) {
		if (bp->b_flag&BFTEMP)
			bbclear(bp);
		bp = bp->b_bufp;
	}
}

/*
 * Find a buffer, by name. Return a pointer
 * to the BUFFER structure associated with it. If
 * the named buffer is found, but is a TEMP buffer (like
 * the buffer list) conplain. If the buffer is not found
 * and the "cflag" is TRUE, create it. The "bflag" is
 * the settings for the flags in in buffer.
 */
BUFFER	*
bfind(bname, cflag, bflag)
register char	*bname;
{
	register BUFFER	*bp;
	register LINE	*lp;

	bp = bheadp;
	while (bp != NULL) {
		if (strcmp(bname, bp->b_bname) == 0)
			return (bp);	/* mb: even if BFTEMP */
		bp = bp->b_bufp;
	}
	if (cflag != FALSE) {
		if ((bp=(BUFFER *)malloc(sizeof(BUFFER))) == NULL)
			return (NULL);
		if ((lp=lalloc(0)) == NULL) {
			free((char *) bp);
			return (NULL);
		}
		bp->b_bufp  = bheadp;
		bheadp = bp;
		bp->b_dotp  = lp;
		bp->b_doto  = 0;
		bp->b_markp = NULL;
		bp->b_marko = 0;
		bp->b_flag  = bflag;
		bp->b_nwnd  = 0;
		bp->b_linep = lp;
		strcpy(bp->b_fname, "");
		strcpy(bp->b_bname, bname);
		lp->l_fp = lp;
		lp->l_bp = lp;
		return (bp);
	} else
		return (NULL);
}

/*
 * This routine blows away all of the text
 * in a buffer. If the buffer is marked as changed
 * then we ask if it is ok to blow it away; this is
 * to save the user the grief of losing text. The
 * window chain is nearly always wrong if this gets
 * called; the caller must arrange for the updates
 * that are required. Return TRUE if everything
 * looks good.
 */
bclear(bp)
	register BUFFER	*bp;
{	
	if ((bp->b_flag&BFTEMP) == 0		/* Not scratch buffer.	*/
	 && (bp->b_flag&BFCHG) != 0		/* Something changed	*/
	 && mlyesno("Discard changes") != TRUE) {
		return (ctrlg());
	}
	bbclear(bp);
	update(TRUE);	/* mb: user feedback */
	return (TRUE);
}

/*
 * mb: separated from bclear()
 */
bbclear(bp)
	register BUFFER	*bp;
{
	register WINDOW	*wp;
	register LINE	*lp;

	bp->b_flag  &= ~BFCHG;			/* Not changed		*/
	while ((lp=lforw(bp->b_linep)) != bp->b_linep)
		lfree(lp);
	bp->b_dotp  = bp->b_linep;		/* Fix "."		*/
	bp->b_doto  = 0;
	bp->b_markp = NULL;			/* Invalidate "mark"	*/
	bp->b_marko = 0;

	/* mb: added here - was in readin(): */

        for (wp=wheadp; wp!=NULL; wp=wp->w_wndp) {
		if (wp->w_bufp == bp) {
			wp->w_linep = bp->b_linep;
			wp->w_dotp  = bp->b_linep;
			wp->w_doto  = 0;
			wp->w_flag |= (WFMODE|WFHARD|WFFORCE);
		}
	}
}

/*
 * mb: added.
 */
renambuf(f, n)
{
	register WINDOW	*wp;
	register char   *cp1;
	register char   *cp2;
	register char	c;
	int	s;
	char	bufn[NBUFN], dfltbuf[NBUFN], *dflt;

	dflt = NULL;
	if (curbp->b_fname[0] != '\0') {
		makename (dfltbuf, curbp->b_fname);
		dflt = dfltbuf;
	}
	s = mlreply("New buffer name", dflt, bufn, NBUFN, FALSE);
	if (s!=TRUE && s!=FALSE)
		return (ctrlg());
	curbp->b_flag &= (~BFTEMP);	/* not TEMP any more */
	cp1 = bufn;
	cp2 = curbp->b_bname;
	do {
		c = *cp1++;
		if (c>='A' && c<='Z')
			c += 'a' - 'A';
		*cp2++ = c;
	} while (c != '\0');
	wp = wheadp;
	while (wp != NULL) {
		if (wp->w_bufp == curbp)
			wp->w_flag |= WFMODE;
		wp = wp->w_wndp;
	}
	return(TRUE);
}
