/************************************************************************
 * This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  *
 * provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is *
 * included in all the files.                                           *
 ************************************************************************/

#include "jove.h"
#include "jctype.h"
#include "chars.h"
#include "fp.h"
#include "disp.h"
#include "ask.h"
#include "extend.h"
#include "fmt.h"
#include "insert.h"
/* #include "io.h" */	/* for pwd() */
#ifdef IPROCS
# include "sysprocs.h"
# include "iproc.h"
#endif
#include "move.h"
#include "macros.h"
#include "screen.h"
#include "term.h"
#include "wind.h"

#ifdef MAC
# include "mac.h"
#else
# include <sys/stat.h>
#endif

/* define a couple of unique daddrs */
#define	NOWHERE_DADDR	(~NULL_DADDR | DDIRTY)	/* not in tmp file */
#define	UNSAVED_CURLINE_DADDR	((NOWHERE_DADDR - 1) | DDIRTY)	/* not yet in tmp file */

struct screenline
	*Screen = NULL,	/* the screen (a bunch of screenline) */
	*Curline = NULL;	/* current line */

private void
	DeTab proto((char *, int, char *, char *, bool)),
	DoIDline proto((int)),
	do_cl_eol proto((int)),
	ModeLine proto((Window *, char *, int)),
	GotoDot proto((void)),
	UpdLine proto((int)),
	UpdWindow proto((Window *, int));

#ifdef ID_CHAR
private void
	DelChar proto((int, int, int)),
	InsChar proto((int, int, int, char *));

private bool
	IDchar proto ((char *, int)),
	OkayDelete proto ((int, int, bool)),
	OkayInsert proto ((int, int));

private int
	NumSimilar proto ((char *, char *, int)),
	IDcomp proto ((char *, char *, int));
#endif /* ID_CHAR */

private bool
	AddLines proto((int, int)),
	DelLines proto((int, int));

bool	DisabledRedisplay = NO;

/* Kludge windows gets called by the routines that delete lines from the
   buffer.  If the w->w_line or w->w_top are deleted and this procedure
   is not called, the redisplay routine will barf. */

void
ChkWindows(line1, line2)
LinePtr	line1,
	line2;
{
	register Window	*w = fwind;
	register LinePtr	lp,
			lend = line2->l_next;

	do {
		if (w->w_bufp == curbuf) {
			for (lp = line1->l_next; lp != lend; lp = lp->l_next) {
				if (lp == w->w_top)
					w->w_flags |= W_TOPGONE;
				if (lp == w->w_line)
					w->w_flags |= W_CURGONE;
			}
		}
		w = w->w_next;
	} while (w != fwind);
}


#ifdef WINRESIZE

volatile bool
	ResizePending = NO;	/* asynch request for screen resize */

private void
resize()
{
	bool	oldDisabledRedisplay = DisabledRedisplay;
	int
		oldILI = ILI,
		oldCO = CO;

	DisabledRedisplay = YES;	/* prevent tragedy */
	ResizePending = NO;	/* early & safe */
	ttsize();	/* update line (LI and ILI) and col (CO) info. */

	if (oldILI != ILI || oldCO != CO) {
		register int	total;
		register Window	*wp;

		/* Go through the window list, changing each window size in
		 * proportion to the resize.  If the window would become too
		 * small, we delete it.
		 *
		 * Actually, we must do the deletion in
		 * a separate pass because del_wind donates the space to either
		 * neighbouring window.  We test the windows in a funny order:
		 * top-most, then bottom-up.  Although it isn't necessary
		 * for correctness, it means that we consider any donated
		 * space, cutting down the number of windows we decide to delete.
		 * Loop termination is tricky: fwind may have changed due to a
		 * del_wind.  As a simple fix, we start over whenever we
		 * delete a window.  Although this is O(n**2), it can't
		 * really be expensive.
		 *
		 * After scaling all the windows, we
		 * give any space remaining to the current window (which would
		 * have changed if the old current window had been deleted).
		 *
		 * This seems fairer than just resizing the current window.
		 */
		wp = fwind;
		for (;;) {
			int	newsize = ILI * wp->w_height / oldILI;

			if (newsize < 2) {
				del_wind(wp);
				wp = fwind;
			} else {
				wp = wp->w_prev;
				if (wp == fwind)
					break;
			}
		}

		total = 0;
		do {
			int	newsize = ILI * wp->w_height / oldILI;

			wp->w_height = newsize;
			total += newsize;
			wp = wp->w_next;
		} while (wp != fwind);

		curwind->w_height += ILI - total;

		/* Make a new screen structure */
		make_scr();

		/* Do a 'hard' update on the screen - clear and redraw */
		ClAndRedraw();
#ifdef WIN32
		ResizeWindow();
#endif
	}
	DisabledRedisplay = oldDisabledRedisplay;
}

#endif /* WINRESIZE */

private bool	RingBell;	/* So if we have a lot of errors ...
				  ring the bell only ONCE */

void
redisplay()
{
	if (DisabledRedisplay)
		return;
#ifdef WINRESIZE
	do
#endif
	{
		register Window	*w;
		int
			lineno,
			i;
		bool
			done_ID = NO,
			old_UpdModLine;
		register struct scrimage
			*des_p,
			*phys_p;

#ifdef WINRESIZE
		if (ResizePending)
			resize();
#endif
		curwind->w_line = curwind->w_bufp->b_dot;
		curwind->w_char = curwind->w_bufp->b_char;
#ifdef MAC
		/* To avoid calling redisplay() recursively,
		 * we must avoid calling CheckEvent(),
		 * so we must avoid calling charp().
		 */
		InputPending = NO;
#else
		if (PreEmptOutput())
			return;
#endif
		if (RingBell) {
			dobell(1);
			RingBell = NO;
		}
		AbortCnt = ScrBufSize;		/* initialize this now */
		if (UpdMesg)
			DrawMesg(YES);

		for (lineno = 0, w = fwind; lineno < ILI; w = w->w_next) {
			UpdWindow(w, lineno);
			lineno += w->w_height;
		}

		/* Now that we've called update window, we can
		   assume that the modeline will be updated.  But
		   if while redrawing the modeline the user types
		   a character, ModeLine() is free to set this on
		   again so that the modeline will be fully drawn
		   at the next redisplay.  Furthermore, if output
		   is preempted, we'll restore the old value because
		   we can't be sure that the updating has happened. */

		old_UpdModLine = UpdModLine;
		UpdModLine = NO;

		des_p = DesiredScreen;
		phys_p = PhysScreen;
		for (i = 0; i < ILI; i++, des_p++, phys_p++) {
			if (!done_ID && (des_p->s_id != phys_p->s_id)) {
				DoIDline(i);
				done_ID = YES;
			}
			if ((des_p->s_flags & (s_DIRTY | s_L_MOD))
			|| des_p->s_id != phys_p->s_id
			|| des_p->s_vln != phys_p->s_vln
			|| des_p->s_offset != phys_p->s_offset)
				UpdLine(i);
			if (CheapPreEmptOutput()) {
				if (old_UpdModLine)
					UpdModLine = YES;
				goto suppress;
			}
		}

		if (Asking) {
			Placur(ILI, min(CO - 2, calc_pos(mesgbuf, AskingWidth)));
				/* Nice kludge */
			flushscreen();
		} else {
			GotoDot();
		}
suppress: ;
	}
#ifdef WINRESIZE
	/**/ while (ResizePending);
#endif
#ifdef MAC
	if (Windchange)
		docontrols();
#endif
}

/* find_pos() returns the position on the line, that C_CHAR represents
   in LINE */

private int
find_pos(line, c_char)
LinePtr	line;
int	c_char;
{
	return calc_pos(lcontents(line), c_char);
}

/* calc_pos calculates the screen column of character c_char.
 *
 * Note: the calc_pos, how_far, and DeTab must be in synch --
 * each thinks it knows how characters are displayed.
 */

int
calc_pos(lp, c_char)
register char	*lp;
register int	c_char;
{
	register int	pos = 0;
	register ZXchar	c;

	while ((--c_char >= 0) && (c = ZXC(*lp++)) != 0) {
		if (c == '\t' && tabstop != 0) {
			pos += TABDIST(pos);
		} else if (jisprint(c)) {
			pos += 1;
		} else {
			if (c <= DEL)
				pos += 2;
			else
				pos += 4;
		}
	}
	return pos;
}

volatile bool	UpdModLine = NO;
bool	UpdMesg = NO;

private void
DoIDline(start)
int	start;
{
	register struct scrimage	*des_p = &DesiredScreen[start];
	struct scrimage	*phys_p = &PhysScreen[start];
	register int	i,
			j;

	/* Some changes have been made.  Try for insert or delete lines.
	   If either case has happened, Addlines and/or DelLines will do
	   necessary scrolling, also CONVERTING PhysScreen to account for the
	   physical changes.  The comparison continues from where the
	   insertion/deletion takes place; this doesn't happen very often,
	   usually it happens with more than one window with the same
	   buffer. */

#ifdef TERMCAP
	if (!CanScroll)
		return;		/* We should never have been called! */
#endif

	for (i = start; i < ILI; i++, des_p++, phys_p++)
		if (des_p->s_id != phys_p->s_id)
			break;

	for (; i < ILI; i++) {
		for (j = i + 1; j < ILI; j++) {
			des_p = &DesiredScreen[j];
			phys_p = &PhysScreen[j];
			if (des_p->s_id != NULL_DADDR && des_p->s_id == phys_p->s_id)
				break;
			if (des_p->s_id == PhysScreen[i].s_id) {
				if (des_p->s_id == NULL_DADDR)
					continue;
				if (AddLines(i, j - i)) {
					DoIDline(j);
					return;
				}
				break;
			}
			if ((des_p = &DesiredScreen[i])->s_id == phys_p->s_id) {
				if (des_p->s_id == NULL_DADDR)
					continue;
				if (DelLines(i, j - i)) {
					DoIDline(i);
					return;
				}
				break;
			}
		}
	}
}

/* Make DesiredScreen reflect what the screen should look like when we are done
   with the redisplay.  This deals with horizontal scrolling.  Also makes
   sure the current line of the Window is in the window. */

bool	ScrollAll = NO;	/* VAR: when current line scrolls, scroll whole window? */
int	ScrollWidth = 10;	/* VAR: unit of horizontal scrolling */

private void
UpdWindow(w, start)
register Window	*w;
int	start;
{
	LinePtr	lp;
	int	i,
		upper,		/* top of window */
		lower,		/* bottom of window */
		strt_col,	/* starting print column of current line */
		ntries = 0;	/* # of tries at updating window */
	register struct scrimage	*des_p,
					*phys_p;
	Buffer	*bp = w->w_bufp;

	do {
		if (w->w_flags & W_CURGONE) {
			w->w_line = bp->b_dot;
			w->w_char = bp->b_char;
		}
		if (w->w_flags & W_TOPGONE)
			CentWind(w);	/* reset topline of screen */
		w->w_flags &= ~(W_CURGONE | W_TOPGONE);

		/* make sure that the current line is in the window */
		upper = start;
		lower = upper + WSIZE(w);
		for (i = upper, lp = w->w_top; ; lp = lp->l_next, i++) {
			if (i == lower || lp == NULL) {
				/* we've run out of window without finding dot */
				ntries += 1;
				if (ntries == 1) {
					CalcWind(w);
				} else if (ntries == 2) {
					w->w_top = w->w_line = w->w_bufp->b_first;
					writef("\rERROR in redisplay: I got hopelessly lost!");
					dobell(2);
				} else {
					writef("\n\rOops, still lost, quitting ...\r\n");
					finish(-1);	/* die! */
					/*NOTREACHED*/
				}
				break;
			}
			if (lp == w->w_line) {
				ntries = 0;	/* happiness: dot is in window */
				break;
			}
		}
	} while (ntries != 0);

	/* first do some calculations for the current line */
	{
		int
			nw = W_NUMWIDTH(w),
			dot_col,
			end_col;

		strt_col = ScrollAll? w->w_LRscroll : PhysScreen[i].s_offset;
		end_col = strt_col + (CO - 1) - (nw + SIWIDTH(strt_col));
		/* Right now we are displaying from strt_col to
		 * end_col of the buffer line.  These are PRINT
		 * columns, not actual characters.
		 */
		dot_col = w->w_dotcol = find_pos(w->w_line, w->w_char);
		/* if the new dotcol is out of range, reselect
		 * a horizontal window
		 */
		if (PhysScreen[i].s_offset == -1
	    || !(strt_col <= dot_col && dot_col < end_col))
		{
			/* If dot_col is within first step left of screen, step left.
			 * Otherwise, if ditto for right.
			 * Otherwise, if it is in first screenwidth, start from begining.
			 * Otherwise, center dot_col.
			 * Fudge: if a scroll left would work except for the necessary
			 * appearance of an ! on the left, we scroll an extra column.
			 */
			int
				step = min(ScrollWidth, end_col - strt_col);

			strt_col =
				strt_col > dot_col && strt_col - step <= dot_col
					? max(strt_col - step, 0)
				: dot_col >= end_col && dot_col < end_col + step
					? min(strt_col + step
					  + (strt_col == 0 && dot_col == end_col + step - 1? 1 : 0)
					  , dot_col)
				: dot_col < ((CO - 1) - nw)
					? 0
				: dot_col - ((CO - nw) / 2);

			if (ScrollAll) {
				if (w->w_LRscroll != strt_col)
					UpdModLine = YES;
				w->w_LRscroll = strt_col;
			}
		}
		w->w_dotline = i;
		w->w_dotcol = dot_col + nw + SIWIDTH(strt_col);
	}

	lp = w->w_top;
	des_p = &DesiredScreen[upper];
	phys_p = &PhysScreen[upper];
	for (i = upper; i < lower; i++, des_p++, phys_p++) {
		if (lp != NULL) {
			des_p->s_offset = (lp == w->w_line)? strt_col : w->w_LRscroll;
			des_p->s_flags = isdirty(lp) ? s_L_MOD : 0;
			des_p->s_vln = (w->w_flags & W_NUMLINES)?
				w->w_topnum + (i - upper) : 0;
			des_p->s_id = (lp == curline && DOLsave)?
				UNSAVED_CURLINE_DADDR : lp->l_dline & ~DDIRTY;
			des_p->s_lp = lp;
			lp = lp->l_next;
		} else {
			/* display line beyond end of buffer */
			static const struct scrimage
				clean_plate = { 0, 0, 0, NULL_DADDR, NULL, NULL };

			*des_p = clean_plate;
			if (phys_p->s_id != NULL_DADDR)
				des_p->s_flags = s_DIRTY;
		}
		des_p->s_window = w;
	}

	/* mode line: */

	/* ??? The following assignment to des_p->s_id is very questionable:
	 * it stores a pointer in a daddr variable!
	 *
	 * We count on the cast pointer value being distinct from
	 * any other daddr, but equal to itself.  Turning
	 * the "DDIRTY" bit on should ensure that it is distinct
	 * from legitimate daddr values (except for NOWHERE_DADDR
	 * and UNSAVED_CURLINE_DADDR).
	 * If sizeof(Buffer *)>sizeof(daddr), nothing ensures that
	 * these pointers are even distinct from each other.
	 *
	 * There also seems to be an assumption that every modeline
	 * for a particular buffer will be the same.  This is not
	 * always the case: the last modeline on the screen is usually
	 * different from any other modeline, even for the same buffer.
	 * Currently, I think that only very contrived cases could cause
	 * problems (probably involving window resizing).
	 * Further problems will arise if JOVE is changed so that there are
	 * other ways in which a modeline can reflect the window state
	 * (instead of just the buffer state).
	 *
	 * -- DHR
	 */
	des_p->s_window = w;
	des_p->s_id = (daddr) w->w_bufp | DDIRTY;
	des_p->s_flags = (des_p->s_id != phys_p->s_id || UpdModLine)?
		s_MODELINE | s_DIRTY : 0;
	des_p->s_offset = 0;
	des_p->s_vln = 0;
	des_p->s_lp = NULL;

#ifdef MAC
	if (UpdModLine)
		Modechange = YES;
	if (w == curwind && w->w_control != NULL)
		SetScrollBar(w);
#endif
}

/* Write whatever is in mesgbuf (maybe we are Asking, or just printed
   a message).  Turns off the UpdateMesg line flag. */

void
DrawMesg(abortable)
bool	abortable;
{
	char	outbuf[MAXCOLS + PPWIDTH];	/* assert(CO <= MAXCOLS); */

#ifndef MAC		/* same reason as in redisplay() */
	if (PreEmptOutput())
		return;
#endif
	i_set(ILI, 0);
	DeTab(mesgbuf, 0, outbuf, outbuf + CO, NO);
	if (swrite(outbuf, NOEFFECT, abortable)) {
		cl_eol();
		UpdMesg = NO;
	}
	flushscreen();
}

/* Goto the current position in the current window.  Presumably redisplay()
   has already been called, and curwind->{w_dotline,w_dotcol} have been set
   correctly. */

private void
GotoDot()
{
	if (!CheapPreEmptOutput()) {
		Placur(curwind->w_dotline,
			curwind->w_dotcol - PhysScreen[curwind->w_dotline].s_offset);
		flushscreen();
	}
}

private int
UntilEqual(start)
register int	start;
{
	register struct scrimage	*des_p = &DesiredScreen[start],
					*phys_p = &PhysScreen[start];

	while ((start < ILI) && (des_p->s_id != phys_p->s_id)) {
		des_p += 1;
		phys_p += 1;
		start += 1;
	}

	return start;
}

/* Calls the routine to do the physical changes, and changes PhysScreen to
   reflect those changes. */

private bool
AddLines(at, num)
register int	at,
		num;
{
	register int	i;
	int	bottom = UntilEqual(at + num);

	if (num == 0 || num >= ((bottom - 1) - at))
		return NO;				/* we did nothing */
	v_ins_line(num, at, bottom - 1);

	/* Now change PhysScreen to account for the physical change. */

	for (i = bottom - 1; i - num >= at; i--)
		PhysScreen[i] = PhysScreen[i - num];
	for (i = 0; i < num; i++)
		PhysScreen[at + i].s_id = NULL_DADDR;
	return YES;					/* we did something */
}

private bool
DelLines(at, num)
register int	at,
		num;
{
	register int	i;
	int	bottom = UntilEqual(at + num);

	if (num == 0 || num >= ((bottom - 1) - at))
		return NO;
	v_del_line(num, at, bottom - 1);

	for (i = at; num + i < bottom; i++)
		PhysScreen[i] = PhysScreen[num + i];
	for (i = bottom - num; i < bottom; i++)
		PhysScreen[i].s_id = NULL_DADDR;
	return YES;
}

bool	MarkHighlighting = YES;	/* VAR: highlight mark when visible */

/* Update line linenum in window w.  Only set PhysScreen to DesiredScreen
   if the swrite or cl_eol works, that is nothing is interrupted by
   characters typed. */

private void
UpdLine(linenum)
register int	linenum;
{
	register struct scrimage	*des_p = &DesiredScreen[linenum];
	register Window	*w = des_p->s_window;
	char	outbuf[MAXCOLS + PPWIDTH];	/* assert(CO <= MAXCOLS); */

	i_set(linenum, 0);
	if (des_p->s_flags & s_MODELINE) {
		ModeLine(w, outbuf, linenum);
	} else if (des_p->s_id != NULL_DADDR) {
		char	*lptr;
		int	fromcol = W_NUMWIDTH(w);
#ifdef HIGHLIGHTING
		static struct LErange lr = {0, 0, NULL, US_effect};
		Mark	*mark = b_curmark(w->w_bufp);
		bool	marked_line = (MarkHighlighting
# ifdef TERMCAP
			       && US != NULL
# endif
			       && mark != NULL
			       && mark->m_line == des_p->s_lp);
#endif /* HIGHLIGHTING */

		des_p->s_lp->l_dline &= ~DDIRTY;
		des_p->s_flags &= ~(s_DIRTY | s_L_MOD);

		if (w->w_flags & W_NUMLINES)
			swritef(outbuf, sizeof(outbuf), "%6d  ", des_p->s_vln);
		if (des_p->s_offset != 0) {
			outbuf[fromcol++] = '!';
			outbuf[fromcol] = '\0';
		}
		lptr = lcontents(des_p->s_lp);
		DeTab(lptr, des_p->s_offset, outbuf + fromcol,
		      outbuf + CO, (w->w_flags & W_VISSPACE) != 0);
#ifdef HIGHLIGHTING
		if (marked_line) {
		    lr.start = calc_pos(lptr, mark->m_char)
				    - des_p->s_offset + fromcol;
		    lr.width = 1;
			if (lr.start < sizeof(outbuf) - 1 && outbuf[lr.start] == '\0') {
				outbuf[lr.start] = ' ';
				outbuf[lr.start + 1] = '\0';
			}
		}
#endif /* HIGHLIGHTING */
#ifdef ID_CHAR
		/* REMIND: This code, along with the rest of the
		   ID_CHAR, belongs in the screen driver for
		   termcap based systems.  mac and pc's and other
		   window-based drivers don't give a hoot about
		   ID_CHAR. */

		/* attempt to exploit insert or delete character capability
		 * but only if not highlighting some part of the line
		 */
		if (UseIC && Curline->s_effects == NOEFFECT
# ifdef HIGHLIGHTING
		&& !marked_line
# endif /* HIGHLIGHTING */
		) {
			if (IDchar(outbuf, linenum)) {
				/* success: clean up and go home */
				PhysScreen[linenum] = *des_p;
				return;
			}
			/* failure: re-initialize various cursors */
			i_set(linenum, 0);
		}
#endif /* ID_CHAR */

		if (swrite(outbuf,
#ifdef HIGHLIGHTING
			marked_line ? &lr : NOEFFECT,
#else
			NOEFFECT,
#endif
			YES))
		{
			do_cl_eol(linenum);
		} else {
			/* interrupted: mark indeterminate state */
			PhysScreen[linenum].s_id = NOWHERE_DADDR;
		}
	} else if (PhysScreen[linenum].s_id != NULL_DADDR) {
		/* not the same ... make sure */
		do_cl_eol(linenum);
	}
}

private void
do_cl_eol(linenum)
register int	linenum;
{
	cl_eol();
	PhysScreen[linenum] = DesiredScreen[linenum];
}

/* Expand tabs (and other funny characters) of a section of "buf"
 * into "outbuf".
 *
 * Note: outbuf must allow for at least PPWIDTH extra characters.
 * This is sufficient room for one extra character to be displayed,
 * streamlining the code.
 *
 * Note: the calc_pos, how_far, and DeTab must be in synch --
 * each thinks it knows how characters are displayed.
 */

private void
DeTab(src, start_offset, dst, dst_limit, visspace)
char	*src;
int	start_offset;
char	*dst;
char	*dst_limit;
bool	visspace;
{
	ZXchar	c;
	int	offset = start_offset;

	/* At any time, the number of characters we've output is
	   start_offset - offset.  This is needed to correctly
	   calculate TABDIST() without having to add another
	   variable (pos) to be incremented for each call to addc. */

#define addc(ch) { if (--offset < 0) *dst++ = (ch); }

	while ((c = ZXC(*src++)) != '\0') {
		if (c == '\t' && tabstop != 0) {
			int	nchars = TABDIST(start_offset - offset);

			c = visspace? '>' : ' ';
			while (--nchars > 0 && dst < dst_limit) {
				addc(c);
				c = ' ';
			}
		} else if (jisprint(c)) {
			if (visspace && c == ' ')
				c = '_';
		} else {
			char	buf[PPWIDTH];
			char	*p;

			PPchar(c, buf);
			/* assert(buf[0] != '\0'); */
			for (p = buf; (c = *p++), *p != '\0'; )
				addc(c);
		}
		if (--offset < 0) {
			*dst++ = c;
			if (dst >= dst_limit) {
				/* we've run out of real estate: truncate and flag it */
				dst = dst_limit-1;
				*dst++ = '!';
				break;
			}
		}
	}
#undef	addc
	*dst = '\0';
}


#ifdef ID_CHAR

/* From here to the end of the file is code that tries to utilize the
   insert/delete character feature on some terminals.  It is very confusing
   and not so well written code, AND there is a lot of it.  You may want
   to use the space for something else. */

bool	IN_INSmode = NO;

void
INSmode(on)
bool	on;
{
	if (on != IN_INSmode) {
		putpad(on? IM : EI, 1);
		IN_INSmode = on;
	}
}

/* ID character routines full of special cases and other fun stuff like that.
   It actually works though ...

	Returns Non-Zero if you are finished (no differences left). */

private bool
IDchar(new, lineno)
register char	*new;
int	lineno;
{
	register int	col = 0;
	struct screenline	*sline = &Screen[lineno];
	register char	*old = sline->s_line;
	int	newlen = strlen(new);

	for (;;) {
		int	oldlen = sline->s_roof - old;
		int	i;

		for (; ; col++) {
			if (col == oldlen || col == newlen)
				return oldlen == newlen;	/* one ended; happy if both ended */

			if (old[col] != new[col])
				break;
		}

		/* col now is first difference, and not the end of either */

		/* see if an insertion will help */

		for (i = col + 1; i < newlen; i++) {
			if (new[i] == old[col]) {
				/* The number of saved characters is (roughly)
				 * the number of characters we can retain after
				 * the insertion, minus the number that we
				 * could have salvaged without moving them.
				 */
				int	NumSaved = IDcomp(new + i, old + col, oldlen-col)
						- NumSimilar(new + col, old + col, min(i, oldlen)-col);

				if (OkayInsert(NumSaved, i - col)) {
					InsChar(lineno, col, i - col, new);
					col = i;
					break;
				}
			}
		}
		if (i != newlen)
			continue;

		/* see if a deletion will help */

		for (i = col + 1; i < oldlen; i++) {
			if (new[col] == old[i]) {
				int	NumSaved = IDcomp(new + col, old + i, oldlen - i);

				if (OkayDelete(NumSaved, i - col, newlen == oldlen)) {
					DelChar(lineno, col, i - col);
					break;
				}
			}
		}
		if (i != oldlen)
			continue;
		return NO;
	}
}

private int
NumSimilar(s, t, n)
register char	*s,
		*t;
int	n;
{
	register int	num = 0;

	while (n--)
		if (*s++ == *t++)
			num += 1;
	return num;
}

private int
IDcomp(s, t, len)
register char	*s,	/* NUL terminated */
		*t;	/* len chars */
int	len;
{
	register int	i;
	int	num = 0,
		nonspace = 0;

	for (i = 0; i < len; i++) {
		char	c = *s++;

		if (c == '\0' || c != *t++)
			break;
		if (c != ' ')
			nonspace = 1;
		num += nonspace;
	}

	return num;
}

private bool
OkayDelete(Saved, num, samelength)
int	Saved,
	num;
bool	samelength;
{
	/* If the old and the new have different lengths, then the competition
	 * will have to clear to end of line.  We take that into consideration.
	 */
	return Saved + (samelength ? 0 : CElen) > min(MDClen, DClen * num);
}

private bool
OkayInsert(Saved, num)
int	Saved,
	num;
{
	register int	n = 0;

	/* Note: the way termcap/terminfo is defined, we must use *both*
	 * IC and IM to insert, but normally only one will be defined.
	 * See terminfo(5), under the heading "Insert/Delete Character".
	 */
	if (IC != NULL)		/* Per character prefixes */
		n = min(num * IClen, MIClen);

	if (!IN_INSmode)
		n += IMlen;

	n += num;	/* The characters themselves */

	return Saved > n;
}

private void
DelChar(lineno, col, num)
int	lineno,
	col,
	num;
{
	register char	*from,
			*to;
	struct screenline *sp = (&Screen[lineno]);

	Placur(lineno, col);
	putmulti(DC, M_DC, num, 1);

	to = sp->s_line + col;
	from = to + num;

	byte_copy(from, to, (size_t) (sp->s_roof - from));
	clrline(sp->s_roof - num, sp->s_roof);
	sp->s_roof -= num;
}

private void
InsChar(lineno, col, num, new)
int	lineno,
	col,
	num;
char	*new;
{
	register char	*sp1,
			*sp2,	/* To push over the array. */
			*sp3;	/* Last character to push over. */
	int	i;

	i_set(lineno, 0);
	sp2 = Curline->s_roof + num;

	if (sp2 > cursend) {
		i_set(lineno, CO - num - 1);
		cl_eol();
		sp2 = cursend;
	}
	Curline->s_roof = sp2;
	sp1 = sp2 - num;
	sp3 = Curline->s_line + col;

	while (sp1 > sp3)
		*--sp2 = *--sp1;

	new += col;
	byte_copy(new, sp3, (size_t) num);

	/* The internal screen is correct, and now we have to do
	   the physical stuff. */

	Placur(lineno, col);

	/* Note: the way termcap/terminfo is defined, we must use *both*
	 * IC and IM, but normally only one will be defined.
	 * See terminfo(5), under the heading "Insert/Delete Character".
	 */
	if (IC != NULL)
		putmulti(IC, M_IC, num, 1);
	if (IM != NULL)
		INSmode(YES);

	for (i = 0; i < num; i++) {
		scr_putchar(new[i]);
		if (IN_INSmode)
			putpad(IP, 1);
	}
	CapCol += num;
}

#endif /* ID_CHAR */

#ifdef UNIX		/* obviously ... no mail today if not Unix*/

/* chkmail() returns YES if there is new mail since the
   last time we checked. */

char	Mailbox[FILESIZE];	/* VAR: mailbox name */
int	MailInt = 60;		/* VAR: mail check interval (seconds) */

bool
chkmail(force)
bool	force;
{
	time_t	now;
	static bool	state = NO;	/* assume unknown */
	static time_t	last_chk = 0,
			mbox_time = 0;
	struct stat	stbuf;

	if (MailInt == 0 || Mailbox[0] == '\0')
		return NO;
	time(&now);
	if ((force == NO) && (now < last_chk + MailInt))
		return state;
	last_chk = now;
	if (stat(Mailbox, &stbuf) < 0) {
		state = NO;		/* no mail */
		return NO;
	}
	if ((stbuf.st_atime > stbuf.st_mtime && stbuf.st_atime > mbox_time)
	|| stbuf.st_size == 0)
	{
		mbox_time = stbuf.st_atime;
		state = NO;
	} else if (stbuf.st_mtime > mbox_time) {
		if (mbox_time > 0)
			dobell(2);		/* announce the change */
		mbox_time = stbuf.st_mtime;
		state = YES;
	}
	return state;
}

#endif /* UNIX */

/* Print the mode line. */

private char	*mode_p,
		*mend_p;
bool	BriteMode = YES;		/* VAR: make the mode line inverse? */

private void
mode_app(str)
register const char	*str;
{
	ZXchar	c;

	while (mode_p < mend_p && (c = ZXC(*str++)) != '\0') {
		/* don't expand tabs: treat them as suspects */
		if (jisprint(c)) {
			*mode_p++ = c;
		} else {
			char	buf[PPWIDTH];

			PPchar(c, buf);
			mode_app(buf);
		}
	}

}

/* VAR: mode line format string */
char	ModeFmt[120] = "%3c %w %[%sJOVE (%M)   Buffer: %b  \"%f\" %]%s%i#-%m*- %((%t)%s%)%e";

private void
ModeLine(w, line, linenum)
register Window	*w;
char	*line;	/* scratch space of at least CO chars */
int	linenum;
{
	int	n,
		glue = 0;
	bool	ign_some = NO;
	bool	td = NO;	/* is time (kludge: or mail status) displayed? */
	char
		*fmt = ModeFmt,
		fillc,
		c;
	register Buffer	*thisbuf = w->w_bufp;
	register Buffer *bp;
	LineEffects highlighting;

	mode_p = line;
	mend_p = &line[CO - 1];

#ifdef TERMCAP
	if (SO == NULL)
		BriteMode = NO;	/* we can't do it */
#endif
	/* ??? On Mac, perhaps '_' looks better than '-' */
	fillc = BriteMode? ' ' : '-';

	while ((c = *fmt++)!='\0' && mode_p<mend_p) {
		if (c != '%') {
			if (c == '\\')
				if ((c = *fmt++) == '\0')
					break;
			if (!ign_some) {
				static char	x[] = "x";

				x[0] = c;
				mode_app(x);
			}
			continue;
		}
		if ((c = *fmt++) == '\0')	/* char after the '%' */
			break;
		if (ign_some && c != ')')
			continue;
		n = 1;
		if (c >= '0' && c <= '9') {
			n = 0;
			while (c >= '0' && c <= '9') {
				n = n * 10 + (c - '0');
				c = *fmt++;
			}
			if (c == '\0')
				break;
		}
		switch (c) {
		case '%':
			mode_app("%");
			break;

		case '(':
			if (w->w_next != fwind)	/* Not bottom window. */
				ign_some = YES;
			break;

		case ')':
			ign_some = NO;
			break;

		case '[':
		case ']':
			for (n=RecDepth; n>0 && mode_p<mend_p; n--)
				*mode_p++ = c;
			break;

#ifdef UNIX
		case 'C':	/* check mail here */
			td = YES;	/* kludge: reflect old behaviour where alarm could trigger mail check */
			if (chkmail(NO))
				mode_app("[New mail]");
			break;
#endif /* UNIX */

		case 'M':
		    {
			static const char	*const mmodes[] = {
				"Fundamental ",
				"Text ",
				"C ",
#ifdef LISP
				"Lisp ",
#endif
				NULL
			};

			mode_app(mmodes[thisbuf->b_major]);

			if (BufMinorMode(thisbuf, Fill))
				mode_app("Fill ");
			if (BufMinorMode(thisbuf, Abbrev))
				mode_app("Abbrev ");
			if (BufMinorMode(thisbuf, OverWrite))
				mode_app("OvrWt ");
			if (BufMinorMode(thisbuf, Indent))
				mode_app("Indent ");
			if (BufMinorMode(thisbuf, ReadOnly))
				mode_app("RO ");
			if (InMacDefine)
				mode_app("Def ");
			mode_p -= 1;	/* Back over the extra space. */
			break;
		    }

		case 'c':
			while (--n>=0 && mode_p<mend_p)
				*mode_p++ = fillc;
			break;

		case 'd':	/* print working directory */
			mode_app(pr_name(pwd(), YES));
			break;

		case 'e':	/* stretchable glue */
			*mode_p++ = '\0';	/* glue marker */
			glue++;
			break;

		case 'b':
			mode_app(thisbuf->b_name);
			break;

		case 'f':
		case 'F':
			if (thisbuf->b_fname == NULL)
				mode_app("[No file]");
			else {
				if (c == 'f')
					mode_app(pr_name(thisbuf->b_fname, YES));
				else
					mode_app(basename(thisbuf->b_fname));
			}
			break;

		case 'i':
		    {
			char	yea = (*fmt == '\0') ? '#' : *fmt++;
			char	nay = (*fmt == '\0') ? ' ' : *fmt++;

			*mode_p++ = w->w_bufp->b_diverged ? yea : nay;
			break;
		    }

		case 'm':
		    {
			char	yea = (*fmt == '\0') ? '*' : *fmt++;
			char	nay = (*fmt == '\0') ? ' ' : *fmt++;

			*mode_p++ = IsModified(w->w_bufp) ? yea : nay;
			break;
		    }

		case 'n':
		    {
			char	tmp[16];

			for (bp = world, n = 1; bp != NULL; bp = bp->b_next, n++)
				if (bp == thisbuf)
					break;

			swritef(tmp, sizeof(tmp), "%d", n);
			mode_app(tmp);
			break;
		    }

#ifdef IPROCS
		case 'p':
			if (thisbuf->b_type == B_PROCESS) {
				char	tmp[40];
				Process	p = thisbuf->b_process;

				swritef(tmp, sizeof(tmp), "(%s%s)",
					dbxness(p), pstate(p));
				mode_app(tmp);
			}
			break;
#endif

		case 's':
			if (mode_p[-1] != ' ')
				*mode_p++ = ' ';
			break;

		case 't':
		    {
			char	timestr[12];

			td = YES;
			mode_app(get_time((time_t *)NULL, timestr, 11, 16));
			break;
		    }

		case 'w':
			if (w->w_LRscroll > 0)
				mode_app(">");
			break;

		default:
			mode_app("?");
			break;
		}
	}

	/* Glue (Knuth's term) is a field that expands to fill
	 * any leftover space.  Multiple glue fields compete
	 * on an equal basis.  This is a generalization of a
	 * mechanism to allow centring and right-justification.
	 * The original meaning of %e (fill the rest of the
	 * line) has also been generalized.  %e can now
	 * meaningfully be used 0 or more times.
	 */

	if  (glue) {
		/* 1 space unused, plus padding for magic cookies */
		register char	*to = &line[CO - 1 - (4 * SG)],
				*from = mode_p;

		if (to < from)
			to = from;
		mode_p = to;
		while (from != line) {
			if ((*--to = *--from) == '\0') {
				register int	portion = (to-from) / glue;

				glue--;
				*to = fillc;
				while (--portion >= 0)
					*--to = fillc;
			}
		}
	} else {
		while (mode_p < &line[CO - 1 - (4 * SG)])
			*mode_p++ = fillc;
	}

	*mode_p = '\0';

	/* Highlight mode line. */
	highlighting = NOEFFECT;
	if (BriteMode) {
		highlighting = WindowRange(w);
#ifdef HIGHLIGHTING
		{
			char
				*p = &line[highlighting->start],
				*e = p + highlighting->width;

			for (; p != e; p++)
				if (*p == ' ')
					*p = '-';
		}
#endif
	}
	if (w->w_next == fwind && TimeDisplayed != td) {
		TimeDisplayed = td;
#ifdef UNIX
		SetClockAlarm(YES);
#endif
	}
#ifdef ID_CHAR
	INSmode(NO);
#endif
	if (swrite(line, highlighting, YES))
		do_cl_eol(linenum);
	else
		UpdModLine = YES;
}

/* This tries to place the current line of the current window in the
   center of the window, OR to place it at the arg'th line of the window.
   This also causes the horizontal position of the line to be centered,
   if the line needs scrolling, or moved all the way back to the left,
   if that's possible. */
void
RedrawDisplay()
{
	int	line;
	LinePtr	newtop = prev_line((curwind->w_line = curline),
				arg_or_default(WSIZE(curwind)/2));

	if ((line = in_window(curwind, curwind->w_line)) != -1)
		PhysScreen[line].s_offset = -1;
	if (newtop == curwind->w_top)
		ClAndRedraw();
	else
		SetTop(curwind, newtop);
}

void
ClAndRedraw()
{
	cl_scr(YES);
}

void
NextPage()
{
	LinePtr	newline;

	if (Asking) {
		/* don't do it */
	} else if (arg_value() < 0) {
		negate_arg();
		PrevPage();
	} else if (is_non_minus_arg()) {
		UpScroll();
	} else {
		if (in_window(curwind, curwind->w_bufp->b_last) != -1) {
			rbell();
			return;
		}
		newline = next_line(curwind->w_top, max(1, WSIZE(curwind) - 1));
		SetTop(curwind, curwind->w_line = newline);
		if (curwind->w_bufp == curbuf)
			SetLine(newline);
	}
}

void
PrevPage()
{
	LinePtr	newline;

	if (Asking) {
		/* don't do it */
	} else if (arg_value() < 0) {
		negate_arg();
		NextPage();
	} else if (is_non_minus_arg()) {
		DownScroll();
	} else {
		newline = prev_line(curwind->w_top, max(1, WSIZE(curwind) - 1));
		SetTop(curwind, curwind->w_line = newline);
		if (curwind->w_bufp == curbuf)
			SetLine(newline);
	}
}

void
UpScroll()
{
	SetTop(curwind, next_line(curwind->w_top, arg_value()));
	if (curwind->w_bufp == curbuf
	&& in_window(curwind, curline) == -1)
		SetLine(curwind->w_top);
}

void
DownScroll()
{
	SetTop(curwind, prev_line(curwind->w_top, arg_value()));
	if (curwind->w_bufp == curbuf
	&& in_window(curwind, curline) == -1)
		SetLine(curwind->w_top);
}

bool	VisBell = NO;	/* VAR: use visible bell (if possible) */

void
rbell()
{
	RingBell = YES;
}

/* Message prints the null terminated string onto the bottom line of the
   terminal. */

void
message(str)
char	*str;
{
	if (InJoverc)
		return;
	UpdMesg = YES;
	stickymsg = NO;
	if (str != mesgbuf)
		null_ncpy(mesgbuf, str, (sizeof mesgbuf) - 1);
}

/* End of Window */

void
Eow()
{
	if (Asking)
		return;
	SetLine(next_line(curwind->w_top, WSIZE(curwind) - 1 -
			min(WSIZE(curwind) - 1, arg_value() - 1)));
	if (!is_an_arg())
		Eol();
}

/* Beginning of Window */

void
Bow()
{
	if (Asking)
		return;
	SetLine(next_line(curwind->w_top, min(WSIZE(curwind) - 1, arg_value() - 1)));
}

/* Typeout Mechanism */

bool	UseBuffers = NO,	/* VAR: use buffers with Typeout() */
	TOabort = NO;

private int	LineNo;	/* screen line for Typeout (if not UseBuffers) */

private Window	*old_wind;	/* curwind before preempted by typeout to buffer */

/* This initializes the typeout.  If send-typeout-to-buffers is set
   the buffer NAME is created (emptied if it already exists) and output
   goes to the buffer.  Otherwise output is drawn on the screen and
   erased by TOstop() */

void
TOstart(name)
char	*name;
{
	if (UseBuffers) {
		old_wind = curwind;
		pop_wind(name, YES, B_SCRATCH);
	} else
		DisabledRedisplay = YES;
	TOabort = NO;
	LineNo = 0;
}

private void
TOlineFits(s)
char	*s;
{
	i_set(LineNo, 0);
	(void) swrite(s, NOEFFECT, NO);
	PhysScreen[LineNo].s_id = NOWHERE_DADDR;
	cl_eol();
	flushscreen();
}

private void
TOprompt(s)
char	*s;
{
	if (!TOabort) {
		register ZXchar	c;

		TOlineFits(s);
		c = kbd_getch();
		TOlineFits("");
		if (c != ' ') {
			TOabort = YES;
			if (c != AbortChar)
				kbd_ungetch(c);
		}
	}
}

#ifdef STDARGS
void
Typeout(char *fmt, ...)
#else
/*VARARGS1*/ void
Typeout(fmt, va_alist)
	char	*fmt;
	va_dcl
#endif
{
	char	string[MAX_TYPEOUT+1];
	va_list	ap;

	va_init(ap, fmt);
	format(string, sizeof string, fmt, ap);
	va_end(ap);
	if (UseBuffers) {
		ins_str(string);
		ins_str("\n");
	} else {
		char	outbuf[MAXCOLS + PPWIDTH];	/* assert(CO <= MAXCOLS); */

		if (LineNo == ILI - 2) {
			TOprompt("--more--");
			LineNo = 0;
		}
		if (!TOabort) {
			DeTab(string, 0, outbuf, outbuf + CO, NO);
			TOlineFits(outbuf);
			LineNo += 1;
		}
	}
}

void
TOstop()
{
	if (UseBuffers) {
		ToFirst();
		SetWind(old_wind);
	} else {
		TOprompt("--end--");
		DisabledRedisplay = NO;
	}
}
