/* redraw.c */

/* Author:
 *	Steve Kirkendall
 *	16820 SW Tallac Way
 *	Beaverton, OR 97006
 *	kirkenda@jove.cs.pdx.edu, or ...uunet!tektronix!psueea!jove!kirkenda
 */


/* This file contains functions that draw text on the screen.  The major entry
 * points are:
 *	redrawrange()	- called from modify.c to give hints about what parts
 *			  of the screen need to be redrawn.
 *	redraw()	- redraws the screen (or part of it) and positions
 *			  the cursor where it belongs.
 *	idx2col()	- converts a markidx() value to a logical column number.
 */

#include "vi.h"

/* This variable contains the line number that smartdrawtext() knows best */
static long smartlno;

/* This function remebers where changes were made, so that the screen can be
 * redraw in a more efficient manner.
 */
redrawrange(after, pre, post)
	long	after;	/* lower bound of redrawafter */
	long	pre;	/* upper bound of redrawpre */
	long	post;	/* upper bound of redrawpost */
{
	long	l;

	if (after < redrawafter)
		redrawafter = after;

	l = redrawpre - redrawpost + pre - post;
	if (post > redrawpost)
		redrawpost = post;
	redrawpre = redrawpost + l;
}


/* This function is used in visual mode for drawing the screen (or just parts
 * of the screen, if that's all thats needed).  It also takes care of
 * scrolling.
 */
redraw(curs, inputting)
	MARK	curs;		/* where to leave the screen's cursor */
	int	inputting;	/* boolean: being called from input() ? */
{
	char		*text;		/* a line of text to display */
	static long	chgs;		/* previous changes level */
	long		l;
	int		i;

	/* if curs == MARK_UNSET, then we should reset internal vars */
	if (curs == MARK_UNSET)
	{
		if (topline < 1 || topline > nlines)
		{
			topline = 1L;
		}
		else
		{
			move(LINES - 1, 0);
			clrtoeol();
		}
		leftcol = 0;
		mustredraw = TRUE;
		redrawafter = INFINITY;
		redrawpre = 0L;
		redrawpost = 0L;
		chgs = 0;
		smartlno = 0L;
		return;
	}

#if 0
	/* if we must redraw without changes, then something funny may
	 * have happened to the smart line.  We had better reset it
	 */
	if (chgs == changes && mustredraw)
	{
		smartlno = 0L;
	}
#endif

	/* figure out which column the cursor will be in */
	l = markline(curs);
	text = fetchline(l);
	mark2phys(curs, text, inputting);

	/* adjust topline, if necessary, to get the cursor on the screen */
	if (l >= topline && l <= botline)
	{
		/* it is on the screen already */

		/* if the file was changed but !mustredraw, then redraw line */
		if (chgs != changes && !mustredraw)
		{
			smartdrawtext(text, l);
		}
	}
	else if (l < topline && l > topline - LINES && (SR || AL))
	{
		/* near top - scroll down */
		if (!mustredraw)
		{
			move(0,0);
			while (l < topline)
			{
				topline--;
				if (SR)
				{
					tputs(SR, 1, faddch);
				}
				else
				{
					insertln();
				}
				text = fetchline(topline);
				drawtext(text);
				tputs(UP, 1, faddch);
			}

			/* blank out the last line */
			move(LINES - 1, 0);
			clrtoeol();
		}
		else
		{
			topline = l;
			redrawafter = INFINITY;
			redrawpre = 0L;
			redrawpost = 0L;
		}
	}
	else if (l > topline && l < botline + LINES)
	{
		/* near bottom -- scroll up */
		if (!mustredraw
#if 1
		 || redrawafter == redrawpre && redrawpre == botline && redrawpost == l
#endif
		)
		{
			move(LINES - 1,0);
			clrtoeol();
			while (l > botline)
			{
				topline++; /* <-- also adjusts botline */
				text = fetchline(botline);
				drawtext(text);
			}
			mustredraw = FALSE;
		}
		else
		{
			topline = l - (LINES - 2);
			redrawafter = INFINITY;
			redrawpre = 0L;
			redrawpost = 0L;
		}
	}
	else
	{
		/* distant line - center it & force a redraw */
		topline = l - (LINES / 2) - 1;
		if (topline < 1)
		{
			topline = 1;
		}
		mustredraw = TRUE;
		redrawafter = INFINITY;
		redrawpre = 0L;
		redrawpost = 0L;
	}

	/* Now... do we really have to redraw? */
	if (mustredraw)
	{
		/* If redrawfter (and friends) aren't set, assume we should
		 * redraw everything.
		 */
		if (redrawafter == INFINITY)
		{
			redrawafter = 0L;
			redrawpre = redrawpost = INFINITY;
		}

		/* adjust smartlno to correspond with inserted/deleted lines */
		if (smartlno >= redrawafter)
		{
			if (smartlno < redrawpre)
			{
				smartlno = 0L;
			}
			else
			{
				smartlno += (redrawpost - redrawpre);
			}
		}

		/* should we insert some lines into the screen? */
		if (redrawpre < redrawpost && redrawpre <= botline)
		{
			/* lines were inserted into the file */

			/* decide where insertion should start */
			if (redrawpre < topline)
			{
				l = topline;
			}
			else
			{
				l = redrawpre;
			}

			/* insert the lines... maybe */
			if (l + redrawpost - redrawpre > botline || !AL)
			{
				/* Whoa!  a whole screen full - just redraw */
				redrawpre = redrawpost = INFINITY;
			}
			else
			{
				/* really insert 'em */
				move((int)(l - topline), 0);
				for (i = redrawpost - redrawpre; i > 0; i--)
				{
					insertln();
				}

				/* NOTE: the contents of those lines will be
				 * drawn as part of the regular redraw loop.
				 */

				/* clear the last line */
				move(LINES - 1, 0);
				clrtoeol();
			}
		}

		/* do we want to delete some lines from the screen? */
		if (redrawpre > redrawpost && redrawpost <= botline)
		{
			if (redrawpre > botline || !DL)
			{
				redrawpost = redrawpre = INFINITY;
			}
			else /* we'd best delete some lines from the screen */
			{
				/* clear the last line, so it doesn't look
				 * ugly as it gets pulled up into the screen
				 */
				move(LINES - 1, 0);
				clrtoeol();

				/* delete the lines */
				move((int)(redrawpost - topline), 0);
			 	for (l = redrawpost;
				     l < redrawpre && l <= botline;
				     l++)
				{
					deleteln();
				}

				/* draw the lines that are now newly visible
				 * at the bottom of the screen
				 */
				i = LINES - 1 + (redrawpost - redrawpre);
				move(i, 0);
				for (l = topline + i; l <= botline; l++)
				{
					/* clear this line */
					clrtoeol();

					/* draw the line, or ~ for non-lines */
					if (l <= nlines)
					{
						text = fetchline(l);
						drawtext(text);
					}
					else
					{
						addstr("~\n");
					}
				}
			}
		}

		/* redraw the current line */
		l = markline(curs);
		pfetch(l);
		smartdrawtext(ptext, l);

		/* decide where we should start redrawing from */
		if (redrawafter < topline)
		{
			l = topline;
		}
		else
		{
			l = redrawafter;
		}
		move((int)(l - topline), 0);

		/* draw the other lines */
		for (; l <= botline && l < redrawpost; l++)
		{
			/* handle the cursor's line later */
			if (l == markline(cursor))
			{
				qaddch('\n');
				continue;
			}

			/* clear this line */
			clrtoeol();

			/* draw the line, or ~ for non-lines */
			if (l <= nlines)
			{
				text = fetchline(l);
				drawtext(text);
			}
			else
			{
				addstr("~\n");
			}
		}

		mustredraw = FALSE;
	}

	/* force total (non-partial) redraw next time if not set */
	redrawafter = INFINITY;
	redrawpre = 0L;
	redrawpost = 0L;

	/* move the cursor to where it belongs */
	move((int)(markline(curs) - topline), physcol);
	wqrefresh(stdscr);

	chgs = changes;
}


/* This function converts a MARK to a column number.  It doesn't automatically
 * adjust for leftcol; that must be done by the calling function
 */
int idx2col(curs, text, inputting)
	MARK		curs;	/* the line# & index# of the cursor */
	register char	*text;	/* the text of the line, from fetchline */
	int		inputting;	/* boolean: called from input() ? */
{
	static MARK	pcursor;/* previous cursor, for possible shortcut */
	static MARK	pcol;	/* column number for pcol */
	static long	chgs;	/* previous value of changes counter */
	register int	col;	/* used to count column numbers */
	register int	idx;	/* used to count down the index */
	register int	i;

	/* for now, assume we have to start counting at the left edge */
	col = 0;
	idx = markidx(curs);

	/* if the file hasn't changed & line number is the same & it has no
	 * embedded character attribute strings, can we do shortcuts?
	 */
	if (chgs == changes
	 && !((curs ^ pcursor) & ~(BLKSIZE - 1))
#ifndef NO_CHARATTR
	 && !hasattr(markline(curs), text)
#endif
	)
	{
		/* no movement? */
		if (curs == pcursor)
		{
			/* return the column of the char; for tabs, return its last column */
			if (text[idx] == '\t' && !inputting && !*o_list)
			{
				return pcol + *o_tabstop - (pcol % *o_tabstop) - 1;
			}
			else
			{
				return pcol;
			}
		}

		/* movement to right? */
		if (curs > pcursor)
		{
			/* start counting from previous place */
			col = pcol;
			idx = markidx(curs) - markidx(pcursor);
			text += markidx(pcursor);
		}
	}

	/* count over to the char after the idx position */
	while (idx > 0 && (i = *text)) /* yes, ASSIGNMENT! */
	{
		if (i == '\t' && !*o_list)
		{
			col += *o_tabstop;
			col -= col % *o_tabstop;
		}
		else if (i >= '\0' && i < ' ' || i == '\177')
		{
			col += 2;
		}
#ifndef NO_CHARATTR
		else if (i == '\\' && text[1] == 'f' && text[2] && *o_charattr)
		{
			text += 2; /* plus one more at bottom of loop */
			idx -= 2;
		}			
#endif
		else
		{
			col++;
		}
		text++;
		idx--;
	}

	/* save stuff to speed next call */
	pcursor = curs;
	pcol = col;
	chgs = changes;

	/* return the column of the char; for tabs, return its last column */
	if (*text == '\t' && !inputting && !*o_list)
	{
		return col + *o_tabstop - (col % *o_tabstop) - 1;
	}
	else
	{
		return col;
	}
}


/* This function is similar to idx2col except that it takes care of sideways
 * scrolling - for the given line, at least.
 */
mark2phys(m, text, inputting)
	MARK	m;		/* a mark to convert */
	char	*text;		/* the line that m refers to */
	int	inputting;	/* boolean: caled from input() ? */
{
	int	i;

	i = idx2col(cursor, text, inputting);
	while (i < leftcol)
	{
		leftcol -= *o_sidescroll;
		mustredraw = TRUE;
		redrawrange(1L, INFINITY, INFINITY);
		qaddch('\r');
		drawtext(text);
	}
	while (i > rightcol)
	{
		leftcol += *o_sidescroll;
		mustredraw = TRUE;
		redrawrange(1L, INFINITY, INFINITY);
		qaddch('\r');
		drawtext(text);
	}
	physcol = i - leftcol;
	physrow = markline(m) - topline;

	return physcol;
}

/* This function draws a single line of text on the screen.  The screen's
 * cursor is assumed to be located at the leftmost column of the appropriate
 * row.
 */
drawtext(text)
	register char	*text;	/* the text to draw */
{
	register int	col;	/* column number */
	register int	i;
	register int	tabstop;	/* *o_tabstop */
	register int	limitcol;	/* leftcol or leftcol + COLS */
	int		abnormal;	/* boolean: charattr != A_NORMAL? */

	/* move some things into registers... */
	limitcol = leftcol;
	tabstop = *o_tabstop;
	abnormal = FALSE;

	/* skip stuff that was scrolled off left edge */
	for (col = 0;
	     (i = *text) && col < limitcol; /* yes, ASSIGNMENT! */
	     text++)
	{
		if (i == '\t' && !*o_list)
		{
			col = col + tabstop - (col % tabstop);
		}
		else if (i >= 0 && i < ' ' || i == '\177')
		{
			col += 2;
		}
#ifndef NO_CHARATTR
		else if (i == '\\' && text[1] == 'f' && text[2] && *o_charattr)
		{
			text += 2; /* plus one more as part of "for" loop */

			/* since this attribute might carry over, we need it */
			switch (*text)
			{
			  case 'R':
			  case 'P':
				attrset(A_NORMAL);
				abnormal = FALSE;
				break;

			  case 'B':
				attrset(A_BOLD);
				abnormal = TRUE;
				break;

			  case 'U':
				attrset(A_UNDERLINE);
				abnormal = TRUE;
				break;

			  case 'I':
				attrset(A_ALTCHARSET);
				abnormal = TRUE;
				break;
			}
		}
#endif
		else
		{
			col++;
		}
	}

	/* adjust for control char that was partially visible */
	while (col > limitcol)
	{
		qaddch(' ');
		limitcol++;
	}

	/* now for the visible characters */
	for (limitcol = leftcol + COLS;
	     (i = *text) && col < limitcol;
	     text++)
	{
		if (i == '\t' && !*o_list)
		{
			i = col + tabstop - (col % tabstop);
			if (i < limitcol)
			{
				if (PT && !((i - leftcol) & 7))
				{
					do
					{
						qaddch('\t');
						col += 8; /* not exact! */
					} while (col < i);
					col = i; /* NOW it is exact */
				}
				else
				{
					do
					{
						qaddch(' ');
						col++;
					} while (col < i);
				}
			}
			else
			{
				col = i;
			}
		}
		else if (i >= 0 && i < ' ' || i == '\177')
		{
			col += 2;
			if (col < limitcol)
			{
				qaddch('^');
				qaddch(i ^ '@');
			}
		}
#ifndef NO_CHARATTR
		else if (i == '\\' && text[1] == 'f' && text[2] && *o_charattr)
		{
			text += 2; /* plus one more as part of "for" loop */
			switch (*text)
			{
			  case 'R':
			  case 'P':
				attrset(A_NORMAL);
				abnormal = FALSE;
				break;

			  case 'B':
				attrset(A_BOLD);
				abnormal = TRUE;
				break;

			  case 'U':
				attrset(A_UNDERLINE);
				abnormal = TRUE;
				break;

			  case 'I':
				attrset(A_ALTCHARSET);
				abnormal = TRUE;
				break;
			}
		}
#endif
		else
		{
			col++;
			qaddch(i);
		}
	}

#ifndef NO_CHARATTR
	/* get ready for the next line */
	if (abnormal)
	{
		attrset(A_NORMAL);
	}
#endif
	if (*o_list && col < limitcol)
	{
		qaddch('$');
		col++;
	}
	if (!AM || col < limitcol)
	{
		qaddch('\r');
		qaddch('\n');
	}
}


static nudgecursor(same, scan, new, lno)
	int	same;	/* number of chars to be skipped over */
	char	*scan;	/* where the same chars end */
	char	*new;	/* where the visible part of the line starts */
	long	lno;	/* line number of this line */
{
	if (same > 0)
	{
		if (same < 5)
		{
			/* move the cursor by overwriting */
			while (same > 0)
			{
				qaddch(scan[-same]);
				same--;
			}
		}
		else
		{
			/* move the cursor by calling move() */
			move((int)(lno - topline), (int)(scan - new));
		}
	}
}

/* This function draws a single line of text on the screen, possibly with
 * some cursor optimization.  The cursor is repositioned before drawing
 * begins, so its position before doesn't really matter.
 */
smartdrawtext(text, lno)
	register char	*text;	/* the text to draw */
	long		lno;	/* line number of the text */
{
	static char	old[256];	/* how the line looked last time */
	char		new[256];	/* how it looks now */
	char		*build;		/* used to put chars into new[] */
	char		*scan;		/* used for moving thru new[] or old[] */
	char		*end;		/* last non-blank changed char */
	char		*shift;		/* used to insert/delete chars */
	int		same;		/* length of a run of unchanged chars */
	int		limitcol;
	int		col;
	int		i;

#ifndef NO_CHARATTR
	/* if this line has attributes, do it the dumb way instead */
	if (hasattr(lno, text))
	{
		move((int)(lno - topline), 0);
		clrtoeol();
		drawtext(text);
		return;
	}
#endif

	/* skip stuff that was scrolled off left edge */
	limitcol = leftcol;
	for (col = 0;
	     (i = *text) && col < limitcol; /* yes, ASSIGNMENT! */
	     text++)
	{
		if (i == '\t' && !*o_list)
		{
			col = col + *o_tabstop - (col % *o_tabstop);
		}
		else if (i >= 0 && i < ' ' || i == '\177')
		{
			col += 2;
		}
		else
		{
			col++;
		}
	}

	/* adjust for control char that was partially visible */
	build = new;
	while (col > limitcol)
	{
		*build++ = ' ';
		limitcol++;
	}

	/* now for the visible characters */
	for (limitcol = leftcol + COLS;
	     (i = *text) && col < limitcol;
	     text++)
	{
		if (i == '\t' && !*o_list)
		{
			i = col + *o_tabstop - (col % *o_tabstop);
			while (col < i && col < limitcol)
			{
				*build++ = ' ';
				col++;
			}
		}
		else if (i >= 0 && i < ' ' || i == '\177')
		{
			col += 2;
			*build++ = '^';
			if (col < limitcol)
			{
				*build++ = (i ^ '@');
			}
		}
		else
		{
			col++;
			*build++ = i;
		}
	}
	if (col < limitcol && *o_list)
	{
		*build++ = '$';
		col++;
	}
	end = build;
	while (col < limitcol)
	{
		*build++ = ' ';
		col++;
	}

	/* locate the last non-blank character */
	while (end > new && end[-1] == ' ')
	{
		end--;
	}

	/* can we optimize the displaying of this line? */
	if (lno != smartlno)
	{
		/* nope, can't optimize - different line */
		move((int)(lno - topline), 0);
		for (scan = new, build = old; scan < end; )
		{
			qaddch(*scan);
			*build++ = *scan++;
		}
		if (end < new + COLS)
		{
			clrtoeol();
			while (build < old + COLS)
			{
				*build++ = ' ';
			}
		}
		smartlno = lno;
		return;
	}

	/* skip any initial unchanged characters */
	for (scan = new, build = old; scan < end && *scan == *build; scan++, build++)
	{
	}
	move((int)(lno - topline), (int)(scan - new));

	/* The in-between characters must be changed */
	same = 0;
	while (scan < end)
	{
		/* is this character a match? */
		if (scan[0] == build[0])
		{
			same++;
		}
		else /* do we want to insert? */
		if (scan < end - 1 && scan[1] == build[0] && (*IC || IM))
		{
			nudgecursor(same, scan, new, lno);
			same = 0;

			insch(*scan);
			for (shift = old + COLS; --shift > build; )
			{
				shift[0] = shift[-1];
			}
			*build = *scan;
		}
		else /* do we want to delete? */
		if (build < old + COLS - 1 && scan[0] == build[1] && DC)
		{
			nudgecursor(same, scan, new, lno);
			same = 0;

			delch();
			same++;
			for (shift = build; shift < old + COLS - 1; shift++)
			{
				shift[0] = shift[1];
			}
			*shift = ' ';
		}
		else /* we must overwrite */
		{
			nudgecursor(same, scan, new, lno);
			same = 0;

			addch(*scan);
			*build = *scan;
		}

		build++;
		scan++;
	}

	/* maybe clear to EOL */
	while (build < old + COLS && *build == ' ')
	{
		build++;
	}
	if (build < old + COLS)
	{
		nudgecursor(same, scan, new, lno);
		same = 0;

		clrtoeol();
		while (build < old + COLS)
		{
			*build++ = ' ';
		}
	}
}


#ifndef NO_CHARATTR
/* see if a given line uses character attribute strings */
int hasattr(lno, text)
	long		lno;	/* the line# of the cursor */
	register char	*text;	/* the text of the line, from fetchline */
{
	static long	plno;	/* previous line number */
	static long	chgs;	/* previous value of changes counter */
	static int	panswer;/* previous answer */
	char		*scan;

	/* if charattr is off, then the answer is "no, it doesn't" */
	if (!*o_charattr)
	{
		chgs = 0; /* <- forces us to check if charattr is later set */
		return FALSE;
	}

	/* if we already know the answer, return it... */
	if (lno == plno && chgs == changes)
	{
		return panswer;
	}

	/* get the line & look for "\fX" */
	pfetch(lno);
	if (plen < 3)
	{
		panswer = FALSE;
	}
	else
	{
		for (scan = ptext; scan[2] && !(scan[0] == '\\' && scan[1] == 'f'); scan++)
		{
		}
		panswer = (scan[2] != '\0');
	}

	/* save the results */
	plno = lno;
	chgs = changes;

	/* return the results */
	return panswer;
}
#endif
