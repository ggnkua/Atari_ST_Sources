/************************************************************************
 * This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  *
 * provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is *
 * included in all the files.                                           *
 ************************************************************************/

#include "jove.h"
#include "jctype.h"
#include "disp.h"
#include "ask.h"
#include "c.h"
#include "delete.h"
#include "insert.h"
#include "extend.h"
#include "fmt.h"
#include "marks.h"
#include "misc.h"
#include "move.h"
#include "paragraph.h"

void
prCTIME()
{
	f_mess(": %f %s", get_time((time_t *)NULL, (char *)NULL, 0, -1));
	stickymsg = YES;
}

void
ChrToOct()
{
	ZXchar	c = ask_ks();

	ins_str(sprint("\\%03o", c));
#ifdef PCNONASCII
	if (c == PCNONASCII) {
		c = waitchar();
		ins_str(sprint("\\%03o", c));
	}
#endif
}

void
StrLength()
{
	static const char	inquotes[] = "Where are the quotes?";
	char	*cp;
	int	numchars = 0;

	for (cp = linebuf+curchar; ; cp--) {
		if (*cp == '"' && (cp == linebuf || cp[-1] != '\\'))
			break;
		if (cp == linebuf)
			complain(inquotes);
	}

	cp += 1;	/* skip opening quote */
	for (;;) {
		switch (*cp++) {
		case '\0':
			complain(inquotes);
			/*NOTREACHED*/
		case '"':
			f_mess("%d characters", numchars);
			stickymsg = YES;
			return;
		case '\\':
			if (!jisdigit(*cp)) {
				if (*cp == '\0')
					complain(inquotes);
				cp += 1;
			} else {
				int	num = 3;

				do cp += 1; while (--num != 0 && jisdigit(*cp));
			}
			break;
		}
		numchars += 1;
	}
}

/* Transpose cur_char with cur_char - 1 */

void
TransChar()
{
	char	before;

	if (curchar == 0 || (eolp() && curchar == 1))
		complain((char *)NULL);	/* BEEP */
	if (eolp())
		b_char(1);
	before = linebuf[curchar - 1];
	del_char(BACKWARD, 1, NO);
	f_char(1);
	insert_c(before, 1);
}

/* Switch current line with previous one */

void
TransLines()
{
	daddr	old_prev;

	if (firstp(curline))
		return;
	lsave();
	/* Exchange l_dline values.
	 * CHEAT: this breaks the buffer abstraction.
	 * The getDOT unfools a few caching mechanisms.
	 */
	old_prev = curline->l_prev->l_dline;
	curline->l_prev->l_dline = curline->l_dline;
	curline->l_dline = old_prev;
	getDOT();

	if (!lastp(curline))
		line_move(FORWARD, 1, NO);
	else
		Eol();	/* can't move to next line, so we do the next best thing */
	modify();
	DOLsave = NO;	/* CHEAT: contents of linebuf need not override l_dline. */
}

void
Leave()
{
	longjmp(mainjmp, JMP_QUIT);
}

/* If argument is specified, kill that many lines down.  Otherwise,
   if we "appear" to be at the end of a line, i.e. everything to the
   right of the cursor is white space, we delete the line separator
   as if we were at the end of the line. */

void
KillEOL()
{
	LinePtr	line2;
	int	char2;
	int	num = arg_value();

	if (is_an_arg()) {
		if (num == 0) {	/* Kill to beginning of line */
			line2 = curline;
			char2 = 0;
		} else {
			line2 = next_line(curline, num);
			if ((LineDist(curline, line2) < num) || (line2 == curline))
				char2 = length(line2);
			else
				char2 = 0;
		}
	} else if (blnkp(&linebuf[curchar])) {
		line2 = next_line(curline, 1);
		if (line2 == curline)
			char2 = length(curline);
		else
			char2 = 0;
	} else {
		line2 = curline;
		char2 = length(curline);
	}
	reg_kill(line2, char2, NO);
}

/* kill to beginning of sentence */

void
KillBos()
{
	negate_arg();
	KillEos();
}

/* Kill to end of sentence */

void
KillEos()
{
	LinePtr	line1;
	int	char1;

	line1 = curline;
	char1 = curchar;
	Eos();
	reg_kill(line1, char1, YES);
}

void
KillExpr()
{
	LinePtr	line1;
	int	char1;

	line1 = curline;
	char1 = curchar;
	FSexpr();
	reg_kill(line1, char1, YES);
}

void
Yank()
{
	LinePtr	line,
		lp;
	Bufpos	*dot;

	if (killbuf[killptr] == NULL)
		complain("[Nothing to yank!]");
	lsave();
	line = killbuf[killptr];
	lp = lastline(line);
	dot = DoYank(line, 0, lp, length(lp), curline, curchar, curbuf);
	set_mark();
	SetDot(dot);
}

void
ToIndent()
{
	Bol();
	skip_wht_space();
}

void
skip_wht_space()
{
	register char	*cp = linebuf + curchar;

	while (jiswhite(*cp))
		cp += 1;
	curchar = cp - linebuf;
}

/* GoLine -- go to a line, usually wired to goto-line, ESC g or ESC G.
   If no argument is specified it asks for a line number. */
void
GoLine()
{
	LinePtr	newline;

	if (!is_an_arg())
		set_arg_value(ask_int("1", "Line: ", 10));
	if (arg_value() < 0)
		newline = prev_line(curbuf->b_last, -1 - arg_value());
	else
		newline = next_line(curbuf->b_first, arg_value() - 1);
	PushPntp(newline);
	SetLine(newline);
}

void
NotModified()
{
	unmodify();
}

void
SetLMargin()
{
	int	lmarg = calc_pos(linebuf, curchar);

	if (lmarg >= RMargin)
		complain("[Left margin must be left of right margin]");
	LMargin = lmarg;
}

void
SetRMargin()
{
	int	rmarg = calc_pos(linebuf, curchar);

	if (rmarg <= LMargin)
		complain("[Right margin must be right of left margin]");
	RMargin = rmarg;
}
