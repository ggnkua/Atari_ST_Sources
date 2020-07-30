/*
 * This file contains the
 * command processing functions for
 * a number of random commands. There is
 * no functional grouping here, for sure.
 */
#include	<stdio.h>
#include	"ed.h"

extern int	kused;
extern int	gotobuf();

/* mb: added function to toggle insert/overstrike */

int
instog(f,n)
{
	ovrstrk = !ovrstrk;
	if (ovrstrk)
		mlwrite("[overstrike]");
	else
		mlwrite("[insert]");
	return (TRUE);
}

/* mb: added function to toggle case sensitivity of search */

int
casestog(f,n)
{
	casesens = !casesens;
	if (casesens)
		mlwrite("[searches case sensitive]");
	else
		mlwrite("[case ignored in searches]");
	return (TRUE);
}

/*
 * Set fill column to n.   mb: added the ifs.
 */
setfillcol(f, n)
{
	if (n==1)  n=0;
	if ( (n!=0) && (n < lmargin + tabsize) ) {
		mlwrite("fillcol must be >= leftmargin + tabsize");
		return(ABORT);
	}
	fillcol = n;
	if (n==0)  mlwrite("[no wrap]");
	else       mlwrite("[fill column: %d]", n);
	return(TRUE);
}

/*
 * Set lmargin to n. mb: added.
 */
setlmargin(f, n)
{
	if (n==1)  n=0;
	if ( (n!=0) && (n > fillcol - tabsize) ) {
		mlwrite("lmargin must be <= fillcol - tabsize");
		return(ABORT);
	}
	lmargin = n;
	if (n==0)  mlwrite("[no left margin]");
	else       mlwrite("[left margin: %d]", n);
	return(TRUE);
}

/*
 * Display the current position of the cursor,
 * in origin 1 X-Y coordinates, the character that is
 * under the cursor (in hex), and the fraction of the
 * text that is before the cursor. The displayed column
 * is not the current column, but the column that would
 * be used on an infinite width display. Normally this
 * is bound to "C-X =".
 */
showcpos(f, n)
{
	register LINE	*clp;
	register int	cbo;
	register long	nch;
	register long	nbc;
	register int	nli; 	/* mb: line-no. counter */
	int	cac, ratio, col;  /* mb: were register */
	/* mb: deleted i,c; */

	clp = lforw(curbp->b_linep);		/* Grovel the data.	*/
	cbo = 0;
	nch = 0;
	nbc = -1;		/* mb: not-at-cursor-yet flag */
	nli = 0;		/* mb: */
	while (clp != curbp->b_linep) {
		cbo = llength(clp);
		if (clp==curwp->w_dotp) {
			cac = curwp->w_doto;
			nbc = nch + cac;
			if (cac == cbo)
				cac = '\n';
			else
				cac = lgetc(clp, cac);
		}
		if (nbc < 0) ++nli;
#if V7
		nch += cbo + 1;
#else
		nch += cbo + 2;
#endif
		clp = lforw(clp);
	}
	if (nbc < 0)  nbc=nch;			/* at very end		*/
	col = getccol(FALSE);			/* Get real column.	*/
	ratio = 0;				/* Ratio before dot.	*/
	if (nch != 0)
		ratio = (100L*nbc) / nch;
	mlwrite("X=%d Y=%d CH=0x%x .=%D (%d%% of %D)",
		col+1, nli+1, cac, nbc, ratio, nch);
	return (TRUE);
}

/*
 * Return current column.  Stop at first non-blank given TRUE argument.
 */
getccol(bflg)
int bflg;
{
	register int c, i, col;
	col = 0;
	for (i=0; i<curwp->w_doto; ++i) {
		c = lgetc(curwp->w_dotp, i);
		if (c!=' ' && c!='\t' && bflg)
			break;
		if (c == '\t')
			col += tabsize-(col%tabsize)-1; /* mb: */
		else if (c<0x20 || c==0x7F)
			++col;
		++col;
	}
	return(col);
}

/*
 * Twiddle the two characters on either side of
 * dot. If dot is at the end of the line twiddle the
 * two characters before it. Return with an error if dot
 * is at the beginning of line; it seems to be a bit
 * pointless to make this work. This fixes up a very
 * common typo with a single stroke. Normally bound
 * to "C-T". This always works within a line, so
 * "WFEDIT" is good enough.
 */
twiddle(f, n)
{
	register LINE	*dotp;
	register int	doto;
	register int	cl;
	register int	cr;

	dotp = curwp->w_dotp;
	doto = curwp->w_doto;
	if (doto==llength(dotp) && --doto<0)
		return (FALSE);
	cr = lgetc(dotp, doto);
	if (--doto < 0)
		return (FALSE);
	cl = lgetc(dotp, doto);
	lputc(dotp, doto+0, cr);
	lputc(dotp, doto+1, cl);
	lchange(WFEDIT);
	return (TRUE);
}

/*
 * Set tab size if given non-default argument (n <> 1).  Otherwise, insert a
 * tab into file.  If given argument, n, of zero, change to true tabs.
 * This has to be done in this slightly funny way because the
 * tab (in ASCII) has been turned into "C-I" (in 10
 * bit code) already. Bound to "C-I".
 */
tab(f, n)		/* mb: simplified */
	register int n;
{
	if (n < 1)
		return (FALSE);
	if (n > 1) {
		if (n != tabsize) {
			tabsize = n;
			sgarbf = TRUE;
			update(FALSE);
		}
		mlwrite("[tabsize: %d]", n);
		return(TRUE);
	}
	/* if (n==1) */
		return(linsert(1, '\t', 0));
}

/*
 * Open up some blank space. The basic plan
 * is to insert a bunch of newlines, and then back
 * up over them. Everything is done by the subcommand
 * procerssors. They even handle the looping. Normally
 * this is bound to "C-O".
 */
openline(f, n)
{
	register int	i;
	register int	s;

	if (n < 0)
		return (FALSE);
	if (n == 0)
		return (TRUE);
	i = n;			/* Insert newlines. */
	do {
		s = lnewline();
	} while ((s==TRUE) && (--i));
	if (s == TRUE)				/* Then back up overtop	*/
		s = backchar(f, n);		/* of them all.		*/
	return (s);
}

/*
 * Insert a newline. Bound to "C-M".
 * If you are at the end of the line and the
 * next line is a blank line, just move into the
 * blank line. This makes "C-O" and "C-X C-O" work
 * nicely, and reduces the amount of screen
 * update that has to be done. This would not be
 * as critical if screen update were a lot
 * more efficient.
 */
newline(f, n)
{
	register int	nicol;
	register LINE	*lp;
	register int	s;

	if (n < 0)
		return (FALSE);
	while (n--) {
		lp = curwp->w_dotp;
		if ((llength(lp) == curwp->w_doto)
		 && (lp != curbp->b_linep)
		 && (llength(lforw(lp)) == 0)) {
			if ((s=forwchar(FALSE, 1)) != TRUE)
				return (s);
		} else if ((s=lnewline()) != TRUE)
			return (s);
	}
	return (TRUE);
}

#if EXTRA
/*
 * Delete blank lines around dot.
 * What this command does depends if dot is
 * sitting on a blank line. If dot is sitting on a
 * blank line, this command deletes all the blank lines
 * above and below the current line. If it is sitting
 * on a non blank line then it deletes all of the
 * blank lines after the line. Normally this command
 * is bound to "C-X C-O". Any argument is ignored.
 */
deblank(f, n)
{
	register LINE	*lp1;
	register LINE	*lp2;
	register int	nld;

	lp1 = curwp->w_dotp;
	while (llength(lp1)==0 && (lp2=lback(lp1))!=curbp->b_linep)
		lp1 = lp2;
	lp2 = lp1;
	nld = 0;
	while ((lp2=lforw(lp2))!=curbp->b_linep && llength(lp2)==0)
		++nld;
	if (nld == 0)
		return (TRUE);
	curwp->w_dotp = lforw(lp1);
	curwp->w_doto = 0;
	return (ldelete(nld, TRUE));
}
#endif

/*
 * Insert a newline, then enough
 * tabs and spaces to duplicate the indentation
 * of the previous line. Figure out the indentation
 * of the current line. Insert a newline by calling
 * the standard routine. Insert the indentation by
 * inserting the right number of tabs and spaces.
 * Return TRUE if all ok. Return FALSE if one
 * of the subcommands failed. Normally bound
 * to "C-J".
 */
indent(f, n)
{
	register int	nicol;
	register int	c;
	register int	i;

	if (n < 0)
		return (FALSE);
	while (n--) {
		nicol = getccol(TRUE); 	/* mb: instead of doing it here */
		/* mb: 'real' tabs always: */
		if (lnewline() == FALSE
		|| ((i=nicol/tabsize)!=0 && linsert(i, '\t', 0)==FALSE)
		|| ((i=nicol%tabsize)!=0 && linsert(i,  ' ', 0)==FALSE))
			return (FALSE);
	}
	return (TRUE);
}

/*
 * Delete forward. This is real
 * easy, because the basic delete routine does
 * all of the work. Watches for negative arguments,
 * and does the right thing. If any argument is
 * present, it kills rather than deletes, to prevent
 * loss of text if typed with a big argument.
 * Normally bound to "C-D".
 * mb: generalized for n<0.
 */
forwdel(f, n)
{
	int s;

	if (n < 0) {
		n = -n;
		if ((s=backchar(f, n)) != TRUE)
			return (s);
	}
	return (ldelete(n, f));
}

/*
 * mb: simplified.
 * Bound to "C-H" and also may be called by fbdel().
 */
backdel(f, n)
{
	return (forwdel(f, -n));
}

/*
 * Kill text. If called without an argument,
 * it kills from dot to the end of the line, unless it
 * is at the end of the line, when it kills the newline.
 * If called with an argument of 0, it kills from the
 * start of the line to dot. If called with a positive
 * argument, it kills from dot forward over that number
 * of newlines. If called with a negative argument it
 * kills backwards that number of newlines. Normally
 * bound to "C-K".
 */
kill(f, n)
{
	register int	chunk, s;
	register LINE	*nextp;

	if (f == FALSE) {
		chunk = llength(curwp->w_dotp)-curwp->w_doto;
		if (chunk <= 0)
			chunk = 1;
	} else if (n == 0) {
		chunk = curwp->w_doto;
		curwp->w_doto = 0;
	} else if (n > 0) {
		chunk = llength(curwp->w_dotp)-curwp->w_doto+1;
		nextp = lforw(curwp->w_dotp);
		while (--n) {
			if (nextp == curbp->b_linep)
				return (FALSE);
			chunk += llength(nextp)+1;
			nextp = lforw(nextp);
		}
	} else {
		mlwrite("neg kill?");
		return (FALSE);
	}
	s = ldelete (chunk, TRUE);
	if (f==TRUE && s==TRUE)
		mlwrite("[killed]");
	return (s);
}

/* mb: added.
 */
bkill(f, n)
{
	return (kill(TRUE, 0));
}

/*
 * Yank text back from the kill buffer. This
 * is really easy. All of the work is done by the
 * standard insert routines. All you do is run the loop,
 * and check for errors. Bound to "C-Y". The blank
 * lines are inserted with a call to "newline"
 * instead of a call to "lnewline" so that the magic
 * stuff that happens when you type a carriage
 * return also happens when a carriage return is
 * yanked back from the kill buffer.
 */
yank(f, n)
{
	register int	c, i, reframe;

	if (n <= 0)
		return (FALSE);
	if( kused > 512 )
		mlwrite("[yanking...]");
	reframe = (curwp->w_dotp == curwp->w_linep);
	/* reframe if we are at the top line of window */
	while (n--) {
		i = 0;
		while ((c=kremove(i++)) >= 0) {
			if (c == '\n') {
				if (newline(FALSE, 1) != TRUE)
					return (FALSE);
			} else {
				if (linsert(1, c, 0) != TRUE)
					return (FALSE);
			}
		}
	}
	thisflag |= CFYANK;
	if (reframe) {
		curwp->w_flag |= WFFORCE;
		curwp->w_force = 0;		/* mb: frame to middle */
	}
	mlwrite("[yanked]");
	return (TRUE);
}

/* mb: added.
 * Deletes backwards kused chars.
 * Bound to C-X C-Y.
 */
unyank(f, n)
{
	if ((lastflag&CFYANK) == 0)	/* If last command wasn't Yank */
		return (FALSE);
	return (backdel(TRUE, kused));
}

/* mb: added.
 * Bound to E-Y.
 */
flush_kbuf(f, n)
{
	register int s, wflag;
	BUFFER	*bp;
	BUFFER	*tbp;
	LINE	*wlinep;

	if ((bp=bfind("[]", TRUE, (BFTEMP|BFEDIT|BFCHG))) == NULL)
		return (FALSE);
	wlinep = curwp->w_linep;
	wflag  = curwp->w_flag;
	tbp = curbp;
	gotobuf(bp);
	s = yank(FALSE, 1);
	gotobuf(tbp);
	curwp->w_linep = wlinep;		/* mb: avoid reframe */
	curwp->w_flag  = wflag;
	if (s == TRUE) {
		kdelete();
		mlwrite("[flushed]");
	}
	return (s);
}
