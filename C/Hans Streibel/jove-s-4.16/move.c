/************************************************************************
 * This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  *
 * provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is *
 * included in all the files.                                           *
 ************************************************************************/

#include "jove.h"
#include "re.h"
#include "chars.h"
#include "jctype.h"
#include "disp.h"
#include "move.h"
#include "screen.h"	/* for tabstop */

private int	line_pos;

void
f_char(n)
register int	n;
{
	if (n < 0) {
		b_char(-n);
		return;
	}
	while (--n >= 0) {
		if (eolp()) {			/* Go to the next Line */
			if (curline->l_next == NULL)
				break;
			SetLine(curline->l_next);
		} else
			curchar += 1;
	}
}

void
b_char(n)
register int	n;
{
	if (n < 0) {
		f_char(-n);
		return;
	}
	while (--n >= 0) {
		if (bolp()) {
			if (curline->l_prev == NULL)
				break;
			SetLine(curline->l_prev);
			Eol();
		} else
			curchar -= 1;
	}
}

void
ForChar()
{
	f_char(arg_value());
}

void
BackChar()
{
	b_char(arg_value());
}

void
NextLine()
{
	if ((curline == curbuf->b_last) && eolp())
		complain(NullStr);
	line_move(FORWARD, arg_value(), YES);
}

void
PrevLine()
{
	if ((curline == curbuf->b_first) && bolp())
		complain(NullStr);
	line_move(BACKWARD, arg_value(), YES);
}

/* moves to a different line in DIR; LINE_CMD says whether this is
   being called from NextLine() or PrevLine(), in which case it tries
   to line up the column with the column of the current line */

void
line_move(dir, n, line_cmd)
int	dir,
	n;
bool	line_cmd;
{
	LinePtr	(*proc) ptrproto((LinePtr, int)) =
		(dir == FORWARD) ? next_line : prev_line;
	LinePtr	line;

	line = (*proc)(curline, n);
	if (line == curline) {
		if (dir == FORWARD)
			Eol();
		else
			Bol();
		return;
	}

	if (line_cmd) {
		this_cmd = LINECMD;
		if (last_cmd != LINECMD)
			line_pos = calc_pos(linebuf, curchar);
	}
	SetLine(line);		/* curline is in linebuf now */
	if (line_cmd)
		curchar = how_far(curline, line_pos);
}

/* how_far returns what cur_char should be to be at or beyond col
 * screen columns in to the line.
 *
 * Note: if col indicates a position in the middle of a Tab or other
 * extended character, the result corresponds to that character
 * (as if col had indicated its start).
 *
 * Note: the calc_pos, how_far, and DeTab must be in synch --
 * each thinks it knows how characters are displayed.
 */

int
how_far(line, col)
LinePtr	line;
int	col;
{
	register char	*lp;
	register int	pos;
	register ZXchar	c;
	char	*base;

	base = lp = lcontents(line);
	pos = 0;

	do {
		if ((c = ZXC(*lp)) == '\t' && tabstop != 0) {
			pos += TABDIST(pos);
		} else if (jisprint(c)) {
			pos += 1;
		} else {
			if (c <= DEL)
				pos += 2;
			else
				pos += 4;
		}
		lp += 1;
	} while (pos <= col && c != '\0');

	return lp - base - 1;
}

void
Bol()
{
	curchar = 0;
}

void
Eol()
{
	curchar = length(curline);
}

void
Eof()
{
	PushPntp(curbuf->b_last);
	ToLast();
}

void
Bof()
{
	PushPntp(curbuf->b_first);
	ToFirst();
}

/* Move forward (if dir > 0) or backward (if dir < 0) a sentence.  Deals
   with all the kludgery involved with paragraphs, and moving backwards
   is particularly yucky. */

private void
to_sent(dir)
int	dir;
{
	for (;;) {
		Bufpos
			old,	/* where we started */
			*new;	/* where dosearch stopped */

		DOTsave(&old);

		new = dosearch(
			"^[ \t]*$\\|[?.!]\\{''\\|[\"')\\]]\\|\\}\\{$\\|[ \t]\\}",
			dir, YES);
		if (new == NULL) {
			if (dir == BACKWARD)
				ToFirst();
			else
				ToLast();
			break;
		}
		SetDot(new);
		if (dir < 0) {
			to_word(FORWARD);
			if ((old.p_line != curline || old.p_char > curchar)
			&& (!inorder(new->p_line, new->p_char, old.p_line, old.p_char)
			  || !inorder(old.p_line, old.p_char, curline, curchar)))
				break;
			SetDot(new);
		} else {
			if (blnkp(linebuf)) {
				Bol();
				b_char(1);
				if (old.p_line != curline || old.p_char < curchar)
					break;
				to_word(FORWARD);	/* Oh brother this is painful */
			} else {
				curchar = REbom + 1;	/* Just after the [?.!] */
				if (LookingAt("''\\|[\"')\\]]", linebuf, curchar))
					curchar = REeom;
				break;
			}
		}
	}
}

void
Bos()
{
	register int	num = arg_value();

	if (num < 0) {
		negate_arg();
		Eos();
	} else {
		while (--num >= 0) {
			to_sent(BACKWARD);
			if (bobp())
				break;
		}
	}
}

void
Eos()
{
	register int	num = arg_value();

	if (num < 0) {
		negate_arg();
		Bos();
	} else {
		while (--num >= 0) {
			to_sent(FORWARD);
			if (eobp())
				break;
		}
	}
}

void
f_word(num)
register int	num;
{
	if (num < 0) {
		while (++num <= 0) {
			to_word(BACKWARD);
			while (!bolp() && jisword(linebuf[curchar - 1]))
				curchar -= 1;
			if (bobp())
				break;
		}
	} else {
		while (--num >= 0) {
			register char	c;

			to_word(FORWARD);
			while ((c = linebuf[curchar]) != '\0' && jisword(c))
				curchar += 1;
			if (eobp())
				break;
		}
	}
	/* ??? why is the following necessary? -- DHR */
	this_cmd = OTHER_CMD;	/* Semi kludge to stop some unfavorable behavior */
}

void
ForWord()
{
	f_word(arg_value());
}

void
BackWord()
{
	f_word(-arg_value());
}
