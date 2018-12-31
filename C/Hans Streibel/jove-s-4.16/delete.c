/************************************************************************
 * This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  *
 * provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is *
 * included in all the files.                                           *
 ************************************************************************/

/* Routines to perform all kinds of deletion.  */

#include "jove.h"
#include "jctype.h"
#include "disp.h"
#include "delete.h"
#include "insert.h"
#include "marks.h"
#include "move.h"

/* Assumes that either line1 or line2 is actually the current line, so it can
   put its result into linebuf. */

private void
patchup(line1, char1, line2, char2)
LinePtr	line1,
	line2;
register int	char1,
		char2;
{
	if (line1 != line2)
		ChkWindows(line1, line2);
	DotTo(line1, char1);
	modify();
	linecopy(linebuf, curchar, lcontents(line2) + char2);

	/* The following is a redisplay optimization. */
	if (line1 != line2 && (char1 == 0 && char2 == 0))
		line1->l_dline = line2->l_dline;

	DFixMarks(line1, char1, line2, char2);
	makedirty(curline);
}

/* Deletes the region by unlinking the lines in the middle,
   and patching things up.  The unlinked lines are still in
   order.  */

LinePtr
reg_delete(line1, char1, line2, char2)
LinePtr	line1,
	line2;
int	char1,
	char2;
{
	register LinePtr	retline;

	if ((line1 == line2 && char1 == char2) || line2 == NULL)
		complain((char *)NULL);
	(void) fixorder(&line1, &char1, &line2, &char2);

	retline = nbufline();	/* New buffer line */

	(void) ltobuf(line1, genbuf);
	if (line1 == line2)
		genbuf[char2] = '\0';

	retline->l_prev = NULL;
	retline->l_dline = putline(&genbuf[char1]);
	patchup(line1, char1, line2, char2);

	if (line1 == line2)
		retline->l_next = NULL;
	else {
		retline->l_next = line1->l_next;
		(void) ltobuf(line2, genbuf);
		genbuf[char2] = '\0';
		line2->l_dline = putline(genbuf);
		/* Shorten this line */
	}

	if (line1 != line2) {
		line1->l_next = line2->l_next;
		if (line1->l_next)
			line1->l_next->l_prev = line1;
		else
			curbuf->b_last = line1;
		line2->l_next = NULL;
	}

	return retline;
}

private void
lremove(line1, line2)
register LinePtr	line1,
		line2;
{
	LinePtr	next = line1->l_next;

	if (line1 == line2)
		return;
	line1->l_next = line2->l_next;
	if (line1->l_next)
		line1->l_next->l_prev = line1;
	else
		curbuf->b_last = line1;
	lfreereg(next, line2);	/* Put region at end of free line list. */
}

/* delete character forward */

void
DelNChar()
{
	del_char(FORWARD, arg_value(), YES);
}

/* Delete character backward */

void
DelPChar()
{
	if (MinorMode(OverWrite) && !eolp()) {
		/* Overwrite with spaces.
		 * Some care is exercised to overwrite tabs reasonably,
		 * but control characters displayed as two are not handled.
		 */
		int	rightcol = calc_pos(linebuf, curchar);
		int	charcount = min(arg_value(), curchar);
		int	colcount = rightcol - calc_pos(linebuf, curchar-charcount);

		b_char(charcount);
		overwrite(' ', colcount);
		b_char(colcount);
	} else {
		del_char(BACKWARD, arg_value(), YES);
	}
}

/* Delete some characters.  If deleting forward then call for_char
   to the final position otherwise call back_char.  Then delete the
   region between the two with patchup(). */

void
del_char(dir, num, OK_kill)
int	dir,
	num;
bool	OK_kill;
{
	Bufpos	before,
		after;
	bool	killp = (OK_kill && (abs(num) > 1));

	DOTsave(&before);
	if (dir == FORWARD)
		f_char(num);
	else
		b_char(num);
	if (before.p_line == curline && before.p_char == curchar)
		complain((char *)NULL);
	if (killp)
		reg_kill(before.p_line, before.p_char, YES);
	else {
		DOTsave(&after);
		(void) fixorder(&before.p_line, &before.p_char, &after.p_line, &after.p_char);
		patchup(before.p_line, before.p_char, after.p_line, after.p_char);
		lremove(before.p_line, after.p_line);
	}
}

/* The kill ring.
 * Newest entry is at killptr; second newest is at killptr-1, etc.
 * All empty slots are at the end of the array.
 */

LinePtr	killbuf[NUMKILLS];
int	killptr = 0;	/* index of newest entry (if any) */

void
DelKillRing()	/* delete newest entry */
{
	int	i;

	lfreelist(killbuf[killptr]);	/* free entry */

	/* move space to end */
	for (i = killptr; i != NUMKILLS-1; i++)
		killbuf[i] = killbuf[i+1];
	killbuf[i] = NULL;

	/* make killptr index predecessor (if any) */
	killptr = (killptr + NUMKILLS - 1) % NUMKILLS;
	while (killbuf[killptr] == NULL && killptr != 0)
		killptr -= 1;
}

private void
AddKillRing(text)	/* add a new entry */
LinePtr	text;
{
	if (killbuf[killptr] != NULL) {
		killptr = (killptr +1) % NUMKILLS;
		if (killbuf[NUMKILLS-1] == NULL) {
			/* there is space: move one slot here */
			int	i;

			for (i = NUMKILLS-1; i != killptr; i--)
				killbuf[i] = killbuf[i-1];
		} else {
			/* no free slots: delete oldest element */
			lfreelist(killbuf[killptr]);
		}
	}
	killbuf[killptr] = text;
}

/* This kills a region between point, and line1/char1 and puts it on
   the kill-ring.  If the last command was one of the kill commands,
   the region is appended (prepended if backwards) to the last entry.  */

void
reg_kill(line2, char2, dot_moved)
LinePtr	line2;
int	char2;
bool	dot_moved;
{
	LinePtr	nl,
		line1 = curline;
	int	char1 = curchar;
	bool	backwards;

	backwards = !fixorder(&line1, &char1, &line2, &char2);
	/* This is a kludge!  But it possible for commands that don't
	   know which direction they are deleting in (e.g., delete
	   previous word could have been called with a negative argument
	   in which case, it wouldn't know that it really deleted
	   forward. */

	if (!dot_moved)
		backwards = !backwards;

	DotTo(line1, char1);

	nl = reg_delete(line1, char1, line2, char2);

	if (last_cmd != KILLCMD) {
		AddKillRing(nl);
	} else {
		LinePtr	lastln = lastline(nl);

		if (backwards) {
			(void) DoYank(nl, 0, lastln, length(lastln), killbuf[killptr], 0, (Buffer *)NULL);
		} else {
			LinePtr	olastln = lastline(killbuf[killptr]);

			(void) DoYank(nl, 0, lastln, length(lastln), olastln, length(olastln), (Buffer *)NULL);
		}
	}
	this_cmd = KILLCMD;
}

void
DelReg()
{
	register Mark	*mp = CurMark();

	reg_kill(mp->m_line, mp->m_char, NO);
}

/* Save a region.  A pretend kill. */

void
CopyRegion()
{
	register LinePtr	nl;
	register Mark	*mp;
	register int	status;

	mp = CurMark();
	if (mp->m_line == curline && mp->m_char == curchar)
		complain((char *)NULL);

	nl = nbufline();
	AddKillRing(nl);
	SavLine(nl, NullStr);
	nl->l_next = nl->l_prev = NULL;

	status = inorder(mp->m_line, mp->m_char, curline, curchar);
	if (status == -1)
		return;

	if (status)
		(void) DoYank(mp->m_line, mp->m_char, curline, curchar,
				nl, 0, (Buffer *)NULL);
	else
		(void) DoYank(curline, curchar, mp->m_line, mp->m_char,
				nl, 0, (Buffer *)NULL);
}

void
DelWtSpace()
{
	register char	*ep = &linebuf[curchar],
			*sp = &linebuf[curchar];

	while (jiswhite(*ep))
		ep += 1;
	while (sp > linebuf && jiswhite(sp[-1]))
		sp -= 1;
	if (sp != ep) {
		curchar = sp - linebuf;
		DFixMarks(curline, curchar, curline, curchar + (ep - sp));
		strcpy(sp, ep);
		makedirty(curline);
		modify();
	}
}

void
DelBlnkLines()
{
	register Mark	*dot;
	bool	all;

	if (!blnkp(&linebuf[curchar]))
		return;
	dot = MakeMark(curline, curchar);
	all = !blnkp(linebuf);
	while (blnkp(linebuf) && curline->l_prev)
		SetLine(curline->l_prev);
	all |= firstp(curline);
	Eol();
	DelWtSpace();
	line_move(FORWARD, 1, NO);
	while (blnkp(linebuf) && !eobp()) {
		DelWtSpace();
		del_char(FORWARD, 1, NO);
	}
	if (!all && !eobp())
		open_lines(1);
	ToMark(dot);
	DelMark(dot);
}

private void
dword(forward)
bool	forward;
{
	Bufpos	savedot;

	DOTsave(&savedot);
	if (forward)
		ForWord();
	else
		BackWord();
	reg_kill(savedot.p_line, savedot.p_char, YES);
}

void
DelNWord()
{
	dword(YES);
}

void
DelPWord()
{
	dword(NO);
}
