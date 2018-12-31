/************************************************************************
 * This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  *
 * provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is *
 * included in all the files.                                           *
 ************************************************************************/

/* This creates/deletes/divides/grows/shrinks windows.  */

#include "jove.h"
#include "chars.h"
#include "disp.h"
#include "ask.h"
#include "extend.h"
#include "commands.h"	/* for FindCmd and ExecCmd */
#include "mac.h"
#include "reapp.h"
#include "wind.h"
#include "screen.h"

private const char
	onlyone[] = "You only have one window!",
	toosmall[] = "Resulting window would be too small.";

#ifdef HIGHLIGHTING
bool	ScrollBar = NO;	/* VAR: whether the scrollbar is used */
#endif

Window
	*curwind,
	*fwind = NULL;

/* First line in a Window */

int
FLine(w)
register Window	*w;
{
	register Window	*wp = fwind;
	register int	lineno = -1;

	while (wp != w) {
		lineno += wp->w_height;
		wp = wp->w_next;
		if (wp == fwind)
			complain("window?");
	}
	return lineno + 1;
}

/* Delete `wp' from the screen.  If it is the only window left
   on the screen, then complain.  It gives its body
   to the next window if there is one, otherwise the previous
   window gets the body.  */

void
del_wind(wp)
register Window	*wp;
{
	register Window
		*prev = wp->w_prev,
		*heir = prev;	/* default: previous window inherits space */

	if (one_windp())
		complain(onlyone);

	prev->w_next = wp->w_next;
	wp->w_next->w_prev = prev;

	if (fwind == wp) {
		heir = fwind = wp->w_next;	/* no window above: next inherits */
		/* Here try to do something intelligent for redisplay() */
		SetTop(fwind, prev_line(fwind->w_top, wp->w_height));
	}
	heir->w_height += wp->w_height;
	if (curwind == wp)
		SetWind(heir);
#ifdef MAC
	RemoveScrollBar(wp);
	Windchange = YES;
#endif
	free((UnivPtr) wp);
}

/* Divide the window WP N times, or at least once.  Complains if WP is too
   small to be split into that many pieces.  It returns the new window. */

Window *
div_wind(wp, n)
register Window	*wp;
int	n;
{
	Window	*latest = wp;
	int	amt;

	if (n < 1)
		n = 1;
	amt = wp->w_height / (n + 1);
	if (amt < 2)
		complain(toosmall);

	do {
		register Window	*new = (Window *) emalloc(sizeof (Window));

		new->w_flags = 0;
		new->w_LRscroll = 0;

		new->w_height = amt;
		wp->w_height -= amt;

		/* set the lines such that w_line is the center in
		   each Window */
		new->w_line = wp->w_line;
		new->w_char = wp->w_char;
		new->w_bufp = wp->w_bufp;
		new->w_top = prev_line(new->w_line, WSIZE(new)/2);

		/* Link the new window into the list */
		new->w_prev = latest;
		new->w_next = latest->w_next;
		new->w_next->w_prev = latest->w_next = new;
		latest = new;
#ifdef MAC
		new->w_control = NULL;
#endif
	} while (--n > 0);
#ifdef MAC
	Windchange = YES;
#endif
	return latest;
}

/* Initialze the first window setting the bounds to the size of the
   screen.  There is no buffer with this window.  See parse for the
   setting of this window. */

void
winit()
{
	register Window	*w;

	w = curwind = fwind = (Window *) emalloc(sizeof (Window));
	w->w_line = w->w_top = NULL;
	w->w_LRscroll = 0;
	w->w_flags = 0;
	w->w_char = 0;
	w->w_next = w->w_prev = fwind;
	w->w_height = ILI;
	w->w_bufp = NULL;
#ifdef MAC
	w->w_control = NULL;
	Windchange = YES;
#endif
}

void
tiewind(w, bp)
register Window	*w;
register Buffer	*bp;
{
	bool	not_tied = (w->w_bufp != bp);

	UpdModLine = YES;	/* kludge ... but speeds things up considerably */
	w->w_line = bp->b_dot;
	w->w_char = bp->b_char;
	w->w_bufp = bp;
	if (not_tied)
		CalcWind(w);	/* ah, this has been missing since the
				   beginning of time! */
}

/* Change to previous window. */

void
PrevWindow()
{
	register Window	*new = curwind->w_prev;

	if (Asking)
		complain((char *)NULL);
	if (one_windp())
		complain(onlyone);
	SetWind(new);
}

/* Make NEW the current Window */

void
SetWind(new)
register Window	*new;
{
	if (!Asking && curbuf!=NULL) {		/* can you say kludge? */
		curwind->w_line = curline;
		curwind->w_char = curchar;
		curwind->w_bufp = curbuf;
	}
	if (new == curwind)
		return;
	SetBuf(new->w_bufp);
	if (!inlist(new->w_bufp->b_first, new->w_line)) {
		new->w_line = curline;
		new->w_char = curchar;
	}
	DotTo(new->w_line, new->w_char);
	if (curchar > (int)strlen(linebuf))
		new->w_char = curchar = strlen(linebuf);
	curwind = new;
}

/* delete the current window if it isn't the only one left */

void
DelCurWindow()
{
	SetABuf(curwind->w_bufp);
	del_wind(curwind);
}

/* put the current line of `w' in the middle of the window */

void
CentWind(w)
register Window	*w;
{
	SetTop(w, prev_line(w->w_line, WSIZE(w)/2));
}

int	ScrollStep = 0;	/* VAR: how should we scroll (full scrolling) */

/* Calculate the new topline of the window.  If ScrollStep == 0
   it means we should center the current line in the window. */

void
CalcWind(w)
register Window	*w;
{
	register int	up;
	int	scr_step;
	LinePtr	newtop;

	if (ScrollStep == 0) {	/* Means just center it */
		CentWind(w);
	} else {
		up = inorder(w->w_line, 0, w->w_top, 0);
		if (up == -1) {
			CentWind(w);
			return;
		}
		scr_step = (ScrollStep < 0) ? WSIZE(w) + ScrollStep :
			   ScrollStep - 1;
		/* up: point is above the screen */
		newtop = prev_line(w->w_line, up?
			scr_step : (WSIZE(w) - 1 - scr_step));
		if (LineDist(newtop, w->w_top) >= WSIZE(w) - 1)
			CentWind(w);
		else
			SetTop(w, newtop);
	}
}

/* This is bound to ^X 4 [BTF].  To make the screen stay the
   same we have to remember various things, like the current
   top line in the current window.  It's sorta gross, but it's
   necessary because of the way this is implemented (i.e., in
   terms of do_find(), do_select() which manipulate the windows. */

void
WindFind()
{
	register Buffer
		*obuf = curbuf,
		*nbuf;
	LinePtr	ltop = curwind->w_top;
	Bufpos
		odot,
		ndot;
	void	(*cmd) ptrproto((void));

	DOTsave(&odot);

	switch (waitchar()) {
	case 't':
	case 'T':
		cmd = FindTag;
		break;

	case CTL('T'):
		cmd = FDotTag;
		break;

	case 'b':
	case 'B':
		cmd = BufSelect;
		break;

	case 'f':
	case 'F':
		cmd = FindFile;
		break;

	default:
		cmd = NULL;	/* avoid uninitialized complaint from gcc -W */
		complain("T: find-tag, ^T: find-tag-at-point, F: find-file, B: select-buffer.");
		/*NOTREACHED*/
	}
	ExecCmd((data_obj *) FindCmd(cmd));

	nbuf = curbuf;
	DOTsave(&ndot);
	SetBuf(obuf);
	SetDot(&odot);
	SetTop(curwind, ltop);	/* there! it's as if we did nothing */

	if (one_windp())
		(void) div_wind(curwind, 1);

	tiewind(curwind->w_next, nbuf);
	SetWind(curwind->w_next);
	SetDot(&ndot);
}

/* Go into one window mode by deleting all the other windows */

void
OneWindow()
{
	while (curwind->w_next != curwind)
		del_wind(curwind->w_next);
}

Window *
windbp(bp)
register Buffer	*bp;
{

	register Window	*wp = fwind;

	if (bp == NULL)
		return NULL;
	do {
		if (wp->w_bufp == bp)
			return wp;
		wp = wp->w_next;
	} while (wp != fwind);
	return NULL;
}

/* Change window into the next window.  Curwind becomes the new window. */

void
NextWindow()
{
	register Window	*new = curwind->w_next;

	if (Asking)
		complain((char *)NULL);
	if (one_windp())
		complain(onlyone);
	SetWind(new);
}

/* Scroll the next Window */

void
PageNWind()
{
	if (one_windp())
		complain(onlyone);
	NextWindow();
	NextPage();
	PrevWindow();
}

private Window *
w_nam_typ(name, type)
register char	*name;
int	type;
{
	register Window *w;
	register Buffer	*b;

	b = buf_exists(name);
	w = fwind;
	if (b != NULL) {
		do {
			if (w->w_bufp == b)
				return w;
		} while ((w = w->w_next) != fwind);
	}

	w = fwind;
	do {
		if (w->w_bufp->b_type == type)
			return w;
	} while ((w = w->w_next) != fwind);

	return NULL;
}

/* Put a window with the buffer `name' in it.  Erase the buffer if
   `clobber' is YES. */

void
pop_wind(name, clobber, btype)
register char	*name;
bool	clobber;
int	btype;
{
	register Window	*wp;
	register Buffer	*newb;

	if ((newb = buf_exists(name)) != NULL)
		btype = -1;	/* if the buffer exists, don't change
				   it's type */
	if ((wp = w_nam_typ(name, btype)) == NULL) {
		if (one_windp())
			SetWind(div_wind(curwind, 1));
		else
			PrevWindow();
	} else
		SetWind(wp);

	newb = do_select((Window *)NULL, name);
	if (clobber)
		buf_clear(newb);
	tiewind(curwind, newb);
	if (btype != -1)
		newb->b_type = btype;
	SetBuf(newb);
}

void
GrowWindowCmd()
{
	WindSize(curwind, abs(arg_value()));
}

void
ShrWindow()
{
	WindSize(curwind, -abs(arg_value()));
}

/* Change the size of the window by inc.  First arg is the window,
   second is the increment. */

void
WindSize(w, inc)
register Window	*w;
register int	inc;
{
	if (one_windp())
		complain(onlyone);

	if (inc == 0)
		return;
	else if (inc < 0) {	/* Shrinking this Window. */
		if (w->w_height + inc < 2)
			complain(toosmall);
		w->w_height += inc;
		w->w_prev->w_height -= inc;
	} else {		/* Growing the window. */
		/* Change made from original code so that growing a window
		   exactly offsets effect of shrinking a window, i.e.
		   doing either followed by the other restores original
		   sizes of all affected windows. */
		if (w->w_prev->w_height - inc < 2)
			complain(toosmall);
		w->w_height += inc;
		w->w_prev->w_height -= inc;
	}
#ifdef MAC
	Windchange = YES;
#endif
}

/* Set the topline of the window, calculating its number in the buffer.
   This is for numbering the lines only. */

void
SetTop(w, line)
Window	*w;
register LinePtr	line;
{
#ifdef HIGHLIGHTING
	if (ScrollBar)
		UpdModLine = YES;
#endif
	w->w_top = line;
	if (w->w_flags & W_NUMLINES)
		w->w_topnum = LinesTo(w->w_bufp->b_first, line) + 1;
}

void
WNumLines()
{
	curwind->w_flags ^= W_NUMLINES;
	SetTop(curwind, curwind->w_top);
}

void
WVisSpace()
{
	curwind->w_flags ^= W_VISSPACE;
	ClAndRedraw();
}

/* If `line' is in `windes', return its screen line number;
   otherwise return -1. */

int
in_window(windes, line)
register Window	*windes;
register LinePtr	line;
{
	register int	i;
	register LinePtr	lp = windes->w_top;

	for (i = 0; lp != NULL && i < windes->w_height - 1; i++, lp = lp->l_next)
		if (lp == line)
			return FLine(windes) + i;
	return -1;
}

void
SplitWind()
{
	SetWind(div_wind(curwind, arg_or_default(2) - 1));
}

/* Goto the window with the named buffer.  If no such window
   exists, pop one and attach the buffer to it. */
void
GotoWind()
{
	char	*bname = ask_buf(lastbuf, ALLOW_OLD | ALLOW_INDEX | ALLOW_NEW);
	Window	*w;

	w = curwind->w_next;
	do {
		if (w->w_bufp->b_name == bname) {
			SetABuf(curbuf);
			SetWind(w);
			return;
		}
		w = w->w_next;
	} while (w != curwind);
	SetABuf(curbuf);
	pop_wind(bname, NO, -1);
}

void
ScrollRight()
{
	int	amt = arg_or_default(ScrollWidth);

	if (curwind->w_LRscroll - amt < 0)
		curwind->w_LRscroll = 0;
	else
		curwind->w_LRscroll -= amt;
	UpdModLine = YES;
}

void
ScrollLeft()
{
	int	amt = arg_or_default(ScrollWidth);

	curwind->w_LRscroll += amt;
	UpdModLine = YES;
}

LineEffects
WindowRange(w)
Window *w;
{
#ifdef HIGHLIGHTING
	static struct LErange range = {0-0, 0-0, SO_effect, US_effect};

	range.start = range.width = 0;	/* default: no highlighting */
	if (ScrollBar) {
		register int	/* line counts of various portions -- slow! */
			above = LinesTo(w->w_bufp->b_first, w->w_top),
			below = LinesTo(w->w_top, (LinePtr)NULL),
			total = above + below,
			in = min(below, WSIZE(w));

		if (above == -1 || below == -1)
			return &range;	/* something fishy */
		below -= in;	/* correction */
		if (in != total) {
			/* Window shows only part of the buffer: highlight "thumb".
			 *
			 * Required properties:
			 * - proportionality of "below", "in", and "above" segments
			 * - monotonicity and smoothness of representation
			 * - a segment vanishes iff it is empty (but "in" is never empty)
			 * - extreme L & R ends of modeline must indicate presence/absence
			 *   of first/last line of buffer; hence some non-linearity
			 *   thereabouts.
			 *
			 * Implementation:
			 * - Use unsigned long to prevent overflow.
			 * - Allocate space to "above" and "below", rounding to nearest
			 *   for best proportionality.
			 * - Allocate the rest to "in".
			 * - Ensure "in" not empty by ensuring total space allocated
			 *   to above and below must leave at least one col.  This
			 *   is done fiddling the rounding term when "in" is small.
			 *
			 * - The first (last) char in the modeline represents the
			 *   first (last) line in the buffer.
			 *
			 * - That leaves the rest of the modeline to represent
			 *   (linearly) the remaining (total-2) lines of the buffer,
			 *   of which (above-1) should be represented by highlighting
			 *   from char position 2 onwards and (below-1) should be
			 *   represented by highlighting from (totalcols-1) backwards.
			 *
			 * - Rounding is applied in this region, and is fiddled to
			 *   ensure that the white bit in the middle never shrinks to
			 *   zero.
			 */
			int
				totalcols_2 = CO - 1 - (4 * SG) - 2,
				total_2 = total - 2,
				rounding = (in < total_2/totalcols_2) ? (totalcols_2*in)/2 : total_2/2,
				abovecols = (above == 0) ? 0 :
					1 + ((long)(above-1)*totalcols_2 + rounding) / total_2,
				belowcols = (below == 0) ? 0 :
					1 + ((long)(below-1)*totalcols_2 + rounding) / total_2;

			range.start = abovecols;
			range.width = totalcols_2 + 2 - abovecols - belowcols;
		}
	}
	return &range;
#else /* !HIGHLIGHTING */
	return YES;	/*  modeline always stands out */
#endif /* !HIGHLIGHTING */
}
