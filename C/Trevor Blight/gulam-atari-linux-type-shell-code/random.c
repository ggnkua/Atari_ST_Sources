/*
 * This file contains the command processing functions for a number of random
 * commands. There is no functional grouping here, for sure.
 */

#include        "ue.h"
#include	"keynames.h"

#ifdef STANC
# define P_(s) s
#else
# define P_(s) ()
#endif
local sleep P_((int i));
local displaymatch P_((LINE *clp, int cbo));
local balance P_((int k));
#undef P_

int     tabsize;                        /* Tab size (0: use real tabs)  */

	local
sleep(i)
{	long	j;

	j = (long) varnum("delay"); if (j==0) j = 2000L;
	for(j = j*i*16; j--;);
}

/* Display matching character.   Matching characters that are not in the
 * current window are displayed in the echo line. If in the current
 * window, move dot to the matching character, sit there a while, then move
 * back.
 */
	local
displaymatch(clp, cbo)
register LINE *clp;
register int  cbo;
{
	register LINE	*tlp;
	register int	tbo;
	int		inwindow;

	/* Figure out if matching char is in current window by	*/
	/* searching from the top of the window to dot.		*/

	inwindow = FALSE;
	for (tlp = curwp->w_linep; tlp != lforw(curwp->w_dotp); tlp = lforw(tlp))
		if (tlp == clp)
			inwindow = TRUE;

	if (inwindow == TRUE) {
		tlp = curwp->w_dotp;	/* save current position */
		tbo = curwp->w_doto;

		curwp->w_dotp  = clp;	/* move to new position */
		curwp->w_doto  = cbo;
		curwp->w_flag |= WFMOVE;

		update();		/* show match */
		sleep(1);		/* wait a bit */

		curwp->w_dotp   = tlp;	/* return to old position */
		curwp->w_doto   = tbo;
		curwp->w_flag  |= WFMOVE;
	}
	else {	/* match not in this window so display line in echo area */
		mlmesg(makelnstr(clp));
		update(); sleep(1);
		mlmesg(ES);
	}
	update();
	return (TRUE);
}

/*
 * Search for and display a matching character.
 *
 * This routine does the real work of searching backward
 * for a balancing character.  If such a balancing character
 * is found, it uses displaymatch() to display the match.
 */
	local
balance(k)
int k;
{
	register LINE	*clp;
	register int	cbo;
	register char	*p;
	register int	c;
	int	rbal, lbal;
	int	depth;
	static	char	bal[] = ")(][}{";

	rbal = k & KCHAR;
	if ((k&CTRL)!=0 && rbal>='@' && rbal<='_') /* ASCII-ify.	*/
		rbal -= '@';

	/* See if there is a matching character -- default to the same */
	p = index(bal, rbal);
	lbal = (p? (int) p[1] : rbal);

	/* Move behind the inserted character.  We are always guaranteed    */
	/* that there is at least one character on the line, since one was  */
	/* just self-inserted by blinkparen.				    */

	clp = curwp->w_dotp;
	cbo = curwp->w_doto - 1;

	depth = 0;			/* init nesting depth		*/

	for (;;) {
		if (cbo == 0) {			/* beginning of line	*/
			clp = lback(clp);
			if (clp == curbp->b_linep) return (FALSE);
			cbo = llength(clp)+1;
		}
		c = (--cbo == llength(clp)? '\n' : lgetc(clp,cbo));

		/* Check for a matching character.  If still in a nested */
		/* level, pop out of it and continue search.  This check */
		/* is done before the nesting check so single-character	 */
		/* matches will work too.				 */
		if (c == lbal) {
			if (depth == 0) {
				displaymatch(clp,cbo);
				return (TRUE);
			}
			else
				depth--;
		}
		/* Check for another level of nesting.  */
		if (c == rbal)
			depth++;
	}
}


/*
 * Ordinary text characters are bound to this function,
 * which inserts them into the buffer. Characters marked as control
 * characters (using the CTRL flag) may be remapped to their ASCII
 * equivalent. This makes TAB (C-I) work right, and also makes the
 * world look reasonable if a control character is bound to this
 * this routine by hand. Any META or CTLX flags on the character
 * are discarded. This is the only routine that actually looks
 * the the "k" argument.
 */
/*ARGSUSED*/
selfinsert(f, n, k) {
	register int	c;

	if (n < 0)	return (FALSE);
	if (n == 0)	return (TRUE);
	c = k & KCHAR;
	if ((k&CTRL)!=0 && c>='@' && c<='_')	/* ASCII-ify.		*/
		c -= '@';
	return (linsert((RSIZE) n, c));
}

/* Self-insert character, then show matching character, if any.
*/

showmatch(f, n, k)
{
	register int  i, s;

	if (k == KRANDOM) return(FALSE);
	for (i = 0; i < n; i++)
	{	if ((s = selfinsert(f, 1, k)) != TRUE)	return(s);
		if (balance(k) != TRUE)	mlwrite("beep...");
	}
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
        for (i=0; i<curwp->w_doto; ++i)
	{	c = lgetc(curwp->w_dotp, i);
                if (c!=' ' && c!='\t' && bflg)  break;
                if (c == '\t')  col |= 0x07;
                else if (c<0x20 || c==0x7F)  ++col;
                ++col;
        }
        return(col);
}


/* Display a bunch of useful information about the current location of
dot: The character under the cursor (in octal), the current line, row,
and column, and approximate position of the cursor in the file (as a
percentage) is displayed.  The column position assumes an infinite
position display; it does not truncate just because the screen does.
This is normally bound to "C-X =".  */

showcpos()
{	register LINE	*clp;
	register long	nchar;
	long		cchar;
	register int	nline, row;
	int		cline, cbyte;	/* Current line/char/byte */
	int		ratio;
	KEY		keychar();

	clp = lforw(curbp->b_linep);		/* Collect the data.	*/
	nchar = 0;
	nline = 0;
	for (;;)
	{	++nline;			/* Count this line	*/
		if (clp == curwp->w_dotp)
		{	cline = nline;		/* Mark line		*/
			cchar = nchar + curwp->w_doto;
			if (curwp->w_doto == llength(clp))
				cbyte = '\n';
			else
				cbyte = lgetc(clp, curwp->w_doto);
		}
		nchar += llength(clp) + 1;	/* Now count the chars	*/
		if (clp == curbp->b_linep) break ;
		clp = lforw(clp);
	}
	row = curwp->w_toprow;			/* Determine row.	*/
	clp = curwp->w_linep;
	while (clp!=curbp->b_linep && clp!=curwp->w_dotp)
	{	++row;
		clp = lforw(clp);
	}
	++row;					/* Convert to origin 1.	*/
	/*NOSTRICT*/	
	/* nchar can't be zero (because of the "bonus" \n at end of file) */
	ratio = (100L*cchar) / nchar;
	mlwrite("Char=0%o  point=%D(%d%%)  line=%d  row=%d col=%d",
		 cbyte, cchar, ratio, cline, row, getccol(0));
	return (TRUE);
}

/* Twiddle the two characters on either side of dot.  If dot is at the
end of the line twiddle the two characters before it.  Return with an
error if dot is at the beginning of line; it seems to be a bit
pointless to make this work.  This fixes up a very common typo with a
single stroke.  Normally bound to "C-T".  This always works within a
line, so "WFEDIT" is good enough.  */

twiddle()
{	register LINE *dotp;
	register int	doto, odoto;
	register int	cl;
	register int	cr;

	dotp = curwp->w_dotp;
	odoto = doto = curwp->w_doto;
	if (doto==llength(dotp) && --doto<0)
		return (FALSE);
	cr = lgetc(dotp, doto);
	if (--doto < 0)
		return (FALSE);
	cl = lgetc(dotp, doto);
	lputc(dotp, doto+0, cr);
	lputc(dotp, doto+1, cl);
	if (odoto != llength(dotp)) ++(curwp->w_doto);
	lchange(WFEDIT);
	return (TRUE);
}

/*
 * Quote the next character, and insert it into the buffer. All the characters
 * are taken literally, with the exception of the newline, which always has
 * its line splitting meaning. The character is always read, even if it is
 * inserted 0 times, for regularity. Bound to "M-Q" (for me) and "C-Q" (for
 * Rich, and only on terminals that don't need XON-XOFF).
 */
quote(f, n, k)
{
        register int    s, c;

	c = inkey();	/*      c = (*term.t_getchar)();	*/
        if (n < 0)	return (FALSE);
        if (n == 0)	return (TRUE);
        if (c == '\n')
	{	do {
                        s = lnewline();
                } while (s==TRUE && --n);
                return (s);
        }
        return (linsert(n, c));
}

/*
 * Set tab size if given non-default argument (n <> 1).  Otherwise, insert a
 * tab into file.  If given argument, n, of zero, change to true tabs.
 * If n > 1, simulate tab stop every n-characters using spaces. This has to be
 * done in this slightly funny way because the tab (in ASCII) has been turned
 * into "C-I" (in 10 bit code) already. Bound to "C-I".
 */
tab(f, n, k)
{
        if (n < 0)	return (FALSE);
        if (n == 0 || n > 1) {tabsize = n;  return(TRUE); }
        if (! tabsize)	return(linsert(1, '\t'));
        return(linsert(tabsize - (getccol(FALSE) % tabsize), ' '));
}

/*
 * Open up some blank space. The basic plan is to insert a bunch of newlines,
 * and then back up over them. Everything is done by the subcommand
 * processors. They even handle the looping. Normally this is bound to "C-O".
 */
openline(f, n, k)
{
        register int    i;
        register int    s;

	if (n < 0)	return (FALSE);
	if (n == 0)	return (TRUE);
        i = n;                                  /* Insert newlines.     */
        do {
                s = lnewline();
        } while (s==TRUE && --i);
        if (s == TRUE) s = backchar(f, n, k);
        return (s);	/* Then back up overtop of them all. */
}

/*
 * Insert a newline. Bound to "C-M". If you are at the end of the line and the
 * next line is a blank line, just move into the blank line. This makes "C-O"
 * and "C-X C-O" work nicely, and reduces the ammount of screen update that
 * has to be done. This would not be as critical if screen update were a lot
 * more efficient.
 */
newline(f, n, k)
{
        register LINE   *lp;
        register int    s;

        if (n < 0) return (FALSE);
        while (n--) {
                lp = curwp->w_dotp;
                if (llength(lp) == curwp->w_doto
                && lp != curbp->b_linep
                && llength(lforw(lp)) == 0) {
                        if ((s=forwchar(FALSE, 1)) != TRUE)
                                return (s);
                } else if ((s=lnewline()) != TRUE)
                        return (s);
        }
        return (TRUE);
}

/* Delete any whitespace around dot (on that line), then insert a space. */

delwhite()
{	register int	i, j, c, d;
	register char	*p, *q, *r;
        register LINE   *lp;
 
	lp = curwp->w_dotp;  p = &(lp->l_text[0]); r = q = p+curwp->w_doto -1;
	while (p <= q && ((c = *q) == ' ' || c == '\t')) q--;
	i = r - q;  p += llength(lp);  q = r+1;
	while (q <  p && ((c = *q) == ' ' || c == '\t')) q++;
	j = q - r;
	if (d = i + j - 1)
	{	curwp->w_doto -= i;  llength(lp) -= d;
		cpymem(r-i+1, r+j, p-r-j);
	}
	return linsert((RSIZE) 1, ' ');
}

/*
 * Delete blank lines around dot. What this command does depends if dot is
 * sitting on a blank line. If dot is sitting on a blank line, this command
 * deletes all the blank lines above and below the current line. If it is
 * sitting on a non blank line then it deletes all of the blank lines after
 * the line. Normally this command is bound to "C-X C-O". Any argument is
 * ignored.
 */
deblank()
{
        register LINE   *lp1;
        register LINE   *lp2;
        register int    nld;

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
        return (ldelete(nld, 0));
}

/*
 * Insert a newline, then enough tabs and spaces to duplicate the indentation
 * of the previous line. Assumes tabs are every eight characters. Quite simple.
 * Figure out the indentation of the current line. Insert a newline by calling
 * the standard routine. Insert the indentation by inserting the right number
 * of tabs and spaces. Return TRUE if all ok. Return FALSE if one of the
 * subcomands failed. Normally bound to "C-J".
 */
/*ARGSUSED*/
indent(f, n, k) {
	register int	nicol;
	register int	c;
	register int	i;

	if (n < 0)
		return (FALSE);
	while (n--) {
		nicol = 0;
		for (i=0; i<llength(curwp->w_dotp); ++i) {
			c = lgetc(curwp->w_dotp, i);
			if (c!=' ' && c!='\t')
				break;
			if (c == '\t')
				nicol |= 0x07;
			++nicol;
		}
		if (lnewline() == FALSE
		|| ((i=nicol/8)!=0 && linsert((RSIZE) i, '\t')==FALSE)
		|| ((i=nicol%8)!=0 && linsert((RSIZE) i,  ' ')==FALSE))
			return (FALSE);
	}
	return (TRUE);
}

/*
 * Delete forward. This is real easy, because the basic delete routine does
 * all of the work. Watches for negative arguments, and does the right thing.
 * If any argument is present, it kills rather than deletes, to prevent loss
 * of text if typed with a big argument. Normally bound to "C-D".
 */
forwdel(f, n, k)
{
        if (n < 0)
                return (backdel(f, -n));
        if (f != FALSE) {                       /* Really a kill.       */
                if ((lastflag&CFKILL) == 0)
                        kdelete();
                thisflag |= CFKILL;
        }
        return (ldelete(n, KFORW));
}

/*
 * Delete backwards. This is quite easy too, because it's all done with other
 * functions. Just move the cursor back, and delete forwards. Like delete
 * forward, this actually does a kill if presented with an argument. Bound to
 * both "RUBOUT" and "C-H".
 */
backdel(f, n, k)
{
        register int    s;

        if (n < 0)
                return (forwdel(f, -n));
        if (f != FALSE) {                       /* Really a kill.       */
                if ((lastflag&CFKILL) == 0)
                        kdelete();
                thisflag |= CFKILL;
        }
        if ((s=backchar(f, n, k)) == TRUE)
                s = ldelete(n, KFORW);
        return (s);
}

/*
 * Line-delete-backwards: this is like backdel, but won't back up
 * past the beginning of the line.
 * Line-back-char is same thing w.r.t. backchar, and lforwchar and lforwdel.
 */
lbackdel(f,n,k)
{
	if (curwp->w_doto != 0) return backdel(f,n,k);
	else return TRUE;
}

lbackchar(f,n)
{
	if (curwp->w_doto != 0) return backchar(f,n);
	else return TRUE;
}

lforwdel(f,n)
{
	if (curwp->w_doto != curwp->w_dotp->l_used)
		return forwdel(f,n);
	else return TRUE;
}

lforwchar(f,n)
{
	if (curwp->w_doto != curwp->w_dotp->l_used)
		return forwchar(f,n);
	else return TRUE;
}

/* Kill text: If called with
 f==FALSE          => kill from dot to the end of the line, unless it is
                      at the end of the line, when it kills the newline.
 f==TRUE && n >  0 => kill from dot forward over that number of newlines.
 f==TRUE && n <= 0 => kill any text before dot on the current line, then
                      kill back |n| lines.
*/
killtext(f, n)
{
	register RSIZE	chunk;
	register LINE	*nextp;
	register int	i, len, c;

	if ((lastflag&CFKILL) == 0) kdelete();	/* Clear kill buffer 	*/
	len = llength(curwp->w_dotp);
	thisflag |= CFKILL;
	if (f == FALSE)
	{	for (i = curwp->w_doto; i < len; ++i)
			if ((c = lgetc(curwp->w_dotp, i)) != ' ' && c != '\t')
				break;
		chunk = len - curwp->w_doto;
		if (i == len) chunk++;
		else if (chunk == 0) chunk = 1;
	} else if (n > 0)
	{	chunk = len - curwp->w_doto + 1;
		nextp = lforw(curwp->w_dotp);
		for (i = n; --i;)
		{	if (nextp == curbp->b_linep) break;
			chunk += llength(nextp) + 1;
			nextp = lforw(nextp);
		}
	} else {				/* n <= 0		*/
		chunk = curwp->w_doto;  curwp->w_doto = 0;
		nextp = curwp->w_dotp;
		for (i = n; i++;)
		{	if (lback(nextp) == curbp->b_linep) break;
			nextp = lback(nextp);
			curwp->w_flag |= WFMOVE;
			chunk += llength(nextp) + 1;
		}
		curwp->w_dotp = nextp;
	}
	return ldelete(chunk,  KFORW);
}

killtobln()	{killtext(TRUE, 0);}

/*
 Yank text back from the kill buffer. This is really easy. All of the work
 is done by the standard insert routines. All you do is run the loop, and
 check for errors. Bound to "C-Y". The blank lines are inserted with a call
 to "newline" instead of a call to "lnewline" so that the magic stuff that
 happens when you type a carriage return also happens when a carriage return
 is yanked back from the kill buffer. An attempt has been made to fix the
 cosmetic bug associated with a yank when dot is on the top line of
 the window (nothing moves, because all of the new text landed off screen).
*/
yank(f, n)
{
	register int	c;
	register int	i;
	register LINE	*lp;
	register int	nline;

	if (n < 0) return FALSE;
	nline = 0;				/* Newline counting.	*/
	while (n--)
	{	isetmark();			/* mark around last yank */
		for (i = 0; 0 <= (c=kremove(i)); i++)
		{	if (c == '\n')
			{	if (newline(FALSE, 1) == FALSE)
					return FALSE;
				++nline;
			} else
				if (linsert((RSIZE) 1, c) == FALSE)
					return FALSE;
		}
	}
	lp = curwp->w_linep;			/* Cosmetic adjustment	*/
	if (curwp->w_dotp == lp)		/* if offscreen insert.	*/
	{	while (nline-- && lback(lp)!=curbp->b_linep) lp = lback(lp);
		curwp->w_linep = lp;		/* Adjust framing.	*/
		curwp->w_flag |= WFHARD;
	}
	return TRUE;
}

/* -eof- */
