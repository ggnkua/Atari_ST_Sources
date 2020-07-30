/*
 * file basic.c:
 *
 * The routines in this file
 * move the cursor around on the screen.
 * They compute a new value for the cursor, then
 * adjust ".". The display code always updates the
 * cursor location, so only moves between lines,
 * or functions that adjust the top line in the window
 * and invalidate the framing, are hard.
 */
#include	<stdio.h>
#include	"ed.h"

extern int enlrg_kbuf();	/* mb: added, it's in line.c */

static char nms[] = "No mark set in this window";
static char nem[] = "Not enough memory. Try a smaller region";

/*
 * Move the cursor to the
 * beginning of the current line.
 * Trivial.
 */
gotobol(f, n)
{
	curwp->w_doto  = 0;
	return (TRUE);
}

/*
 * Move the cursor backwards by
 * "n" characters. If "n" is less than
 * zero call "forwchar" to actually do the
 * move. Otherwise compute the new cursor
 * location. Error if you try and move
 * out of the buffer. Set the flag if the
 * line pointer for dot changes.
 */
backchar(f, n)
register int	n;
{
	register LINE	*lp;

	if (n < 0)
		return (forwchar(f, -n));
	while (n--) {
		if (curwp->w_doto == 0) {
			if ((lp=lback(curwp->w_dotp)) == curbp->b_linep)
				return (FALSE);
			curwp->w_dotp  = lp;
			curwp->w_doto  = llength(lp);
			curwp->w_flag |= WFMOVE;
		} else
			curwp->w_doto--;
	}
	return (TRUE);
}

/*
 * Move the cursor to the end
 * of the current line. Trivial.
 * No errors.
 */
gotoeol(f, n)
{
	curwp->w_doto  = llength(curwp->w_dotp);
	return (TRUE);
}

/*
 * Move the cursor forwwards by
 * "n" characters. If "n" is less than
 * zero call "backchar" to actually do the
 * move. Otherwise compute the new cursor
 * location, and move ".". Error if you
 * try and move off the end of the
 * buffer. Set the flag if the line pointer
 * for dot changes.
 */
forwchar(f, n)
register int	n;
{
	if (n < 0)
		return (backchar(f, -n));
	while (n--) {
		if (curwp->w_doto == llength(curwp->w_dotp)) {
			if (curwp->w_dotp == curbp->b_linep)
				return (FALSE);
			curwp->w_dotp  = lforw(curwp->w_dotp);
			curwp->w_doto  = 0;
			curwp->w_flag |= WFMOVE;
		} else
			curwp->w_doto++;
	}
	return (TRUE);
}

/*
 * Goto the beginning of the buffer.
 * Massive adjustment of dot. This is considered
 * to be hard motion; it really isn't if the original
 * value of dot is the same as the new value of dot.
 * Normally bound to "M-<".
 */
gotobob(f, n) {
	curwp->w_dotp  = lforw(curbp->b_linep);
	curwp->w_doto  = 0;
	curwp->w_flag |= WFHARD;
	return (TRUE);
}

/*
 * Move to the end of the buffer.
 * Dot is always put at the end of the
 * file (ZJ). The standard screen code does
 * most of the hard parts of update. Bound to 
 * "M->".
 */
gotoeob(f, n) {
	curwp->w_dotp  = curbp->b_linep;
	curwp->w_doto  = 0;
	curwp->w_flag |= WFHARD;
	return (TRUE);
}

/*
 * Move forward by full lines.
 * The last command controls how
 * the goal column is set.
 * Bound to "C-N". No errors are possible.
 */
forwline(f, n)
	register int n;
{
	register LINE	*dlp;
	register int	offset;

	if (n == 0)
		return (TRUE);
	offset = curwp->w_offset;
	if ((lastflag&CFCPCN) == 0) {
		if (offset)
			curgoal = curcol - 1 + offset;	/* mb: */
		else
			curgoal = curcol;
	}
	thisflag |= CFCPCN;
	dlp = curwp->w_dotp;
	if (n > 0)				/* mb: generalized	*/
		while (n-- && dlp!=curbp->b_linep)
			dlp = lforw(dlp);
	else
		while (n++ && lback(dlp)!=curbp->b_linep)
			dlp = lback(dlp);
	curwp->w_dotp  = dlp;
	curwp->w_doto  = getgoal(dlp);
	curwp->w_flag |= WFMOVE;
	return (TRUE);
}

/*
 * mb: drastically simplified!
 */
backline(f, n)
{
	return (forwline(f, -n));
}

/*
 * mb: added.
 */
gotolinum(f, n)
{
	int s;

	if ((s = gotobob(FALSE,1)) != TRUE)
		return(s);
	return (forwline(f, n-1));
}

/*
 * This routine, given a pointer to
 * a LINE, and the current cursor goal
 * column, return the best choice for the
 * offset. The offset is returned.
 * Used by "C-N" and "C-P".
 */
int
getgoal(dlp)
register LINE	*dlp;
{
	register int	c;
	register int	col;
	register int	newcol;
	register int	dbo;

	col = 0;
	dbo = 0;
	while (dbo < llength(dlp)) {
		c = lgetc(dlp, dbo);
		newcol = col;
		if (c == '\t')
			newcol += tabsize-(newcol%tabsize)-1;  /* mb: */
		else if (c<0x20 || c==0x7F)
			++newcol;
		++newcol;
		if (newcol > curgoal)
			break;
		col = newcol;
		++dbo;
	}
	return (dbo);
}

/*
 * Scroll forward by a specified number
 * of lines, or by a full page if no argument.
 * Bound to "C-V". The "2" in the arithmetic on
 * the window size is the overlap; this value is
 * the default overlap value in ITS EMACS.
 * Because this zaps the top line in the display
 * window, we have to do a hard update.
 */
forwpage(f, n) 
	register int	n;
{
	register LINE	*lp;
	register int	i;

	if (f==FALSE || n==(-1)) {
		i = curwp->w_ntrows - 2;	/* Default scroll.	*/
		if (i <= 0)			/* Forget the overlap	*/
			i = 1;			/* if tiny window.	*/
		n *= i;				/* mb: n may be <0	*/
	}
#if	CVMVAS
	else					/* Convert from pages	*/
		n *= curwp->w_ntrows;		/* to lines.		*/
#endif
	lp = curwp->w_linep;
	for (i=1; lp!=curwp->w_dotp; ++i)	/* mb: changed so that  */
		lp = lforw(lp);			/* cursor moves with	*/
	curwp->w_force = i;			/* window - i is offset */
	curwp->w_flag |= WFFORCE;
	return (forwline(FALSE, n));		/* mb: works forw&back  */
}

/*
 * mb: drastically simplified.
 */
backpage(f, n)
	register int	f;
	register int	n;
{
	return (forwpage(f, -n));
}

/*
 * Set the mark in the current window
 * to the value of "." in the window. No errors
 * are possible. Bound to "M-.".
 */
setmark(f, n)
{
	curwp->w_markp = curwp->w_dotp;
	curwp->w_marko = curwp->w_doto;
	mlwrite("[Mark set]");
	return (TRUE);
}

/*
 * Swap the values of "." and "mark" in
 * the current window. This is pretty easy, bacause
 * all of the hard work gets done by the standard routine
 * that moves the mark about. The only possible error is
 * "no mark". Bound to "C-X C-X".
 */
swapmark(f, n)
{
	register LINE	*odotp;
	register int	odoto;

	if (curwp->w_markp == NULL) {
		mlwrite(nms);
		return (FALSE);
	}
	odotp = curwp->w_dotp;
	odoto = curwp->w_doto;
	curwp->w_dotp  = curwp->w_markp;
	curwp->w_doto  = curwp->w_marko;
	curwp->w_markp = odotp;
	curwp->w_marko = odoto;
	curwp->w_flag |= WFMOVE;
	return (TRUE);
}


/* file region.c:
 *
 * The routines in this file
 * deal with the region, that magic space
 * between "." and mark. Some functions are
 * commands. Some functions are just for
 * internal use.
 */


/*
 * Kill the region. Ask "getregion"
 * to figure out the bounds of the region.
 * Move "." to the start, and kill the characters.
 * Bound to "C-W".
 */
killregion(f, n)
{
	register int	s;
	REGION		region;

	if ((s=getregion(&region)) != TRUE)
		return (s);
	if (region.r_size > 512)
		mlwrite("[killing...]");
	if ((lastflag&CFKILL) == 0)		/* This is a kill type	*/
		kdelete();			/* command, so do magic	*/
	thisflag |= CFKILL;			/* kill buffer stuff.	*/
	if (enlrg_kbuf(region.r_size) == FALSE ) {
		mlwrite(nem);
		return (FALSE);
	}
	curwp->w_dotp = region.r_linep;
	curwp->w_doto = region.r_offset;
	ldelete(region.r_size, TRUE);
	mlwrite("[killed]");
	return (TRUE);
}

/*
 * Copy all of the characters in the
 * region to the kill buffer. Don't move dot
 * at all. This is a bit like a kill region followed
 * by a yank. Bound to "M-W".
 */
copyregion(f, n)
{
	register LINE	*linep;
	register int	loffs;
	register int	s;
	REGION		region;

	if ((s=getregion(&region)) != TRUE)
		return (s);
	if (region.r_size > 512)
		mlwrite("[copying...]");
	if ((lastflag&CFKILL) == 0)		/* Kill type command.	*/
		kdelete();
	thisflag |= CFKILL;
	if (enlrg_kbuf(region.r_size) == FALSE ) {
		mlwrite(nem);
		return (FALSE);
	}
	linep = region.r_linep;			/* Current line.	*/
	loffs = region.r_offset;		/* Current offset.	*/
	while (region.r_size-- > 0) {
		if (loffs == llength(linep)) {	/* End of line.		*/
			kinsert('\n');
			linep = lforw(linep);
			loffs = 0;
		} else {			/* Middle of line.	*/
			kinsert(lgetc(linep, loffs));
			++loffs;
		}
	}
	mlwrite("[copied]");
	return (TRUE);
}

#if EXTRA
/* mb: collapsed ucregion & lcregion.
 * Lower case region. Zap all of the upper
 * case characters in the region to lower case. Use
 * the region code to set the limits. Scan the buffer,
 * doing the changes. Call "lchange" to ensure that
 * redisplay is done in all buffers. Bound to 
 * "C-X C-L".
 */
lowerregion(f, n) {
	return (caseregion(FALSE));
}

upperregion(f, n) {
	return (caseregion(TRUE));
}

/* mb: the common portion of the two: */
caseregion(f) {

	register LINE	*linep;
	register int	loffs;
	register int	c;
	register int	s;
	REGION		region;

	if ((s=getregion(&region)) != TRUE)
		return (s);
	lchange(WFHARD);
	linep = region.r_linep;
	loffs = region.r_offset;
	while (region.r_size-- > 0) {
		if (loffs == llength(linep)) {
			linep = lforw(linep);
			loffs = 0;
		} else {
			c = lgetc(linep, loffs);
			if (f) {	/* mb: uppercase region */
				if (c>='a' && c<='z')
					lputc(linep, loffs, c-0x20);
			} else {
				if (c>='A' && c<='Z')
					lputc(linep, loffs, c+0x20);
			}
			++loffs;
		}
	}
	return (TRUE);
}
#endif

/*
 * This routine figures out the
 * bounds of the region in the current window, and
 * fills in the fields of the "REGION" structure pointed
 * to by "rp". Because the dot and mark are usually very
 * close together, we scan outward from dot looking for
 * mark. This should save time. Return a standard code.
 * Callers of this routine should be prepared to get
 * an "ABORT" status; we might make this have the
 * conform thing later.
 */
getregion(rp)
	REGION	*rp;
{
	register LINE	*flp;
	register LINE	*blp;
	register int	fsize;
	register int	bsize;

	if (curwp->w_markp == NULL) {
		mlwrite(nms);
	return (FALSE);
	}
	if (curwp->w_dotp == curwp->w_markp) {
		rp->r_linep = curwp->w_dotp;
		if (curwp->w_doto < curwp->w_marko) {
			rp->r_offset = curwp->w_doto;
			rp->r_size = curwp->w_marko-curwp->w_doto;
		} else {
			rp->r_offset = curwp->w_marko;
			rp->r_size = curwp->w_doto-curwp->w_marko;
		}
		return (TRUE);
	}
	blp = curwp->w_dotp;
	bsize = curwp->w_doto;
	flp = curwp->w_dotp;
	fsize = llength(flp)-curwp->w_doto+1;
	while (flp!=curbp->b_linep || lback(blp)!=curbp->b_linep) {
		if (flp != curbp->b_linep) {
			flp = lforw(flp);
			if (flp == curwp->w_markp) {
				rp->r_linep = curwp->w_dotp;
				rp->r_offset = curwp->w_doto;
				rp->r_size = fsize+curwp->w_marko;
				return (TRUE);
			}
			fsize += llength(flp)+1;
		}
		if (lback(blp) != curbp->b_linep) {
			blp = lback(blp);
			bsize += llength(blp)+1;
			if (blp == curwp->w_markp) {
				rp->r_linep = blp;
				rp->r_offset = curwp->w_marko;
				rp->r_size = bsize - curwp->w_marko;
			return (TRUE);
			}
		}
	}
	mlwrite("Bug: lost mark");
	return (FALSE);
}
