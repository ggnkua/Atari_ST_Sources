/************************************************************************
 * This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  *
 * provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is *
 * included in all the files.                                           *
 ************************************************************************/

#include "jove.h"
#include "jctype.h"
#include "disp.h"
#include "delete.h"
#include "insert.h"
#include "fmt.h"
#include "marks.h"
#include "misc.h"
#include "move.h"
#include "paragraph.h"
#include "re.h"

private int	get_indent proto((LinePtr));

/* Thanks to Brian Harvey for this paragraph boundary finding algorithm.
   It's really quite hairy figuring it out.  This deals with paragraphs that
   are seperated by blank lines, lines beginning with a Period (assumed to
   be an nroff command), lines beginning with BackSlash (assumed to be Tex
   commands).  Also handles paragraphs that are separated by lines of
   different indent; and it deals with outdented paragraphs, too.  It's
   really quite nice.  Here's Brian's algorithm.

   Definitions:

   THIS means the line containing the cursor.
   PREV means the line above THIS.
   NEXT means the line below THIS.

   BLANK means empty, empty except for spaces and tabs, starts with a period
   or a backslash, or nonexistent (because the edge of the buffer is
   reached).  ((BH 12/24/85 A line starting with backslash is blank only if
   the following line also starts with backslash.  This is so that \noindent
   is part of a paragraph, but long strings of TeX commands don't get
   rearranged.  It still isn't perfect but it's better.))

   BSBLANK means BLANK or starts with a backslash.  (BH 12/24/85)

   HEAD means the first (nonblank) line of the paragraph containing THIS.
   BODY means all other (nonblank) lines of the paragraph.
   TAIL means the last (nb) line of the paragraph.  (TAIL is part of BODY.)

   HEAD INDENT means the indentation of HEAD.  M-J should preserve this.
   BODY INDENT means the indentation of BODY.  Ditto.

   Subprocedures:

   TAILRULE(BODYLINE)
   If BODYLINE is BLANK, the paragraph has only one line, and there is no
   BODY and therefore no TAIL.  Return.  Otherwise, starting from BODYLINE,
   move down until you find a line that either is BSBLANK or has a different
   indentation from BODYLINE.  The line above that different line is TAIL.
   Return.

   Rules:

   1.  If THIS is BLANK, which command are you doing?  If M-J or M-[, then go
   up to the first non-BLANK line and start over.  (If there is no non-BLANK
   line before THIS, ring the bell.)  If M-], then the first non-BLANK line
   below THIS is HEAD, and the second consecutive non-BSBLANK line (if any) is
   the beginning of BODY.  (If there is no non-BLANK line after THIS, ring
   the bell.)  Do TAILRULE(beginning-of-BODY).  Go to rule A.

   2.  If PREV is BLANK or THIS is BSBLANK, then THIS is HEAD, and NEXT (if
   not BSBLANK) is in BODY.  Do TAILRULE(NEXT).  Go to rule A.

   3.  If NEXT is BSBLANK, then THIS is TAIL, therefore part of BODY.  Go to
   rule 5 to find HEAD.

   4.  If either NEXT or PREV has the same indentation as THIS, then THIS is
   part of BODY.  Do TAILRULE(THIS).  Go to rule 5 to find HEAD.  Otherwise,
   go to rule 6.

   5.  Go up until you find a line that is either BSBLANK or has a different
   indentation from THIS.  If that line is BLANK, the line below it is HEAD;
   If that line is non-BLANK, then call that new line THIS for what follows.
   If THIS is BSBLANK (that is, THIS starts with backslash), THIS is HEAD;
   otherwise, if (the new) PREV has the same indent as THIS, then (the new)
   NEXT is HEAD; if PREV has a different indent from THIS, then THIS is
   HEAD.  Go to rule A.

   6.  If you got here, then both NEXT and PREV are nonblank and are
   differently indented from THIS.  This is a tricky case and there is no
   guarantee that you're going to win.  The most straightforward thing to do
   is assume that we are not using hanging indentation.  In that case:
   whichever of PREV and THIS is indented further is HEAD.  Do
   TAILRULE(HEAD+1).  Go to rule A.

   6+.  A more complicated variant would be this: if THIS is indented further
   than PREV, we are using regular indentation and rule 6 applies.  If PREV
   is indented further than THIS, look at both NEXT and the line after NEXT.
   If those two lines are indented equally, and more than THIS, then we are
   using hanging indent, THIS is HEAD, and NEXT is the first line of BODY.
   Do TAILRULE(NEXT).  Otherwise, rule 6 applies.

   A.  You now know where HEAD and TAIL are.  The indentation of HEAD is HEAD
   INDENT; the indentation of TAIL is BODY INDENT.

   B.  If you are trying to M-J, you are now ready to do it.

   C.  If you are trying to M-], leave point after the newline that ends
   TAIL.  In other words, leave the cursor at the beginning of the line
   after TAIL.  It is not possible for this to leave point where it started
   unless it was already at the end of the buffer.

   D.  If you are trying to M-[, if the line before HEAD is not BLANK, then
   leave point just before HEAD.  That is, leave the cursor at the beginning
   of HEAD.  If the line before HEAD is BLANK, then leave the cursor at the
   beginning of that line.  If the cursor didn't move, go up to the first
   earlier non-BLANK line and start over.


   End of Algorithm.  I implemented rule 6+ because it seemed nicer.  */

bool
	SpaceSent2 = YES;	/* VAR: space-sentence-2 */

int
	LMargin = 0,	/* VAR: left margin */
	RMargin = 78;	/* VAR: right margin */

char
	ParaDelim[sizeof(ParaDelim)] = "[ \t]*$\\|\\.\\|\\\\";	/* VAR: paragraph-delimiter-pattern */

private LinePtr
	para_head,
	para_tail;

private int
	head_indent,
	body_indent;

private bool	use_lmargin;

/* some defines for paragraph boundary checking */
#define I_DELIM		(-1)	/* line matched by paragraph-delimiter-pattern */
#define I_BUFEDGE	(-2)	/* line is nonexistent (edge of buffer) */

private bool	bslash;		/* Nonzero if get_indent finds line starting
				   with backslash */

private bool
i_blank(lp)
LinePtr	lp;
{
	return get_indent(lp) < 0;
}

private bool
i_bsblank(lp)
LinePtr	lp;
{
	return i_blank(lp) || bslash;
}

private int
get_indent(lp)
register LinePtr	lp;
{
	Bufpos	save;
	register int	indent;

	bslash = NO;
	if (lp == NULL)
		return I_BUFEDGE;
	DOTsave(&save);
	SetLine(lp);
	if (LookingAt(ParaDelim, linebuf, 0)) {
		indent = I_DELIM;
		if (linebuf[0] == '\\' && REeom == 1) {
			/* BH 12/24/85.  Backslash is delimiter only if next line
			   also starts with Backslash. */
			bslash = YES;
			SetLine(lp->l_next);
			if (linebuf[0] != '\\')
				indent = 0;
		}
	} else {
		ToIndent();
		indent = calc_pos(linebuf, curchar);
	}
	SetDot(&save);

	return indent;
}

private LinePtr
tailrule(lp)
register LinePtr	lp;
{
	int	i;

	i = get_indent(lp);
	if (i < 0)
		return lp;	/* one line paragraph */
	do {
		if ((get_indent(lp->l_next) != i) || bslash)
			/* BH line with backslash is head of next para */
			break;
	} while ((lp = lp->l_next) != NULL);
	if (lp == NULL)
		complain((char *) NULL);
	return lp;
}

/* Finds the beginning, end and indent of the current paragraph, and sets
   the above global variables.  HOW says how to behave when we're between
   paragraphs.  That is, it's either FORWARD or BACKWARD depending on which
   way we're favoring. */

private void
find_para(how)
int	how;
{
	LinePtr	this,
		prev,
		next,
		head = NULL,
		body = NULL,
		tail = NULL;
	int	this_indent;
	Bufpos	orig;		/* remember where we were when we started */

	DOTsave(&orig);
strt:
	this = curline;
	prev = curline->l_prev;
	next = curline->l_next;
	this_indent = get_indent(this);

	if (i_blank(this)) {		/* rule 1 */
		if (how == BACKWARD) {
			while (i_blank(curline))
				if (firstp(curline))
					complain((char *)NULL);
				else
					line_move(BACKWARD, 1, NO);
			goto strt;
		} else {
			while (i_blank(curline))
				if (lastp(curline))
					complain((char *)NULL);
				else
					line_move(FORWARD, 1, NO);
			head = curline;
			next = curline->l_next;
			body = !i_bsblank(next)? next : head;
		}
	} else if (i_bsblank(this) || i_blank(prev)) {	/* rule 2 */
		head = this;
		if (!i_bsblank(next))
			body = next;
	} else if (i_bsblank(next)) {	/* rule 3 */
		tail = this;
		body = this;
	} else if ((get_indent(next) == this_indent) ||	/* rule 4 */
		   (get_indent(prev) == this_indent)) {
		body = this;
	} else {		/* rule 6+ */
		if (get_indent(prev) > this_indent) {
			/* hanging indent maybe? */
			if (next != NULL
			&& get_indent(next) == get_indent(next->l_next))
			{
				head = this;
				body = next;
			}
		}
		/* Now we handle hanging indent else and the other
		   case of this_indent > get_indent(prev).  That is,
		   if we didn't resolve HEAD in the above if, then
		   we are not a hanging indent. */
		if (head == NULL) {	/* still don't know */
			head =  this_indent > get_indent(prev)? this : prev;
			body = head->l_next;
		}
	}
	/* rule 5 -- find the missing parts */
	if (head == NULL) {    /* haven't found head of paragraph so do so now */
		LinePtr	lp;
		int	i;

		lp = this;
		do {
			i = get_indent(lp->l_prev);
			if (i < 0)	/* is blank */
				head = lp;
			else if (bslash)
				head = lp->l_prev;
			else if (i != this_indent) {
				this = lp->l_prev;
				if (get_indent(this->l_prev) == i)
					head = this->l_next;
				else
					head = this;
			}
		} while (head == NULL && (lp = lp->l_prev) != NULL);
		if (lp == NULL)
			complain((char *)NULL);
	}
	if (body == NULL)		/* this must be a one line paragraph */
		body = head;
	if (tail == NULL)
		tail = tailrule(body);
	if (tail == NULL || head == NULL || body == NULL)
		complain("BUG! tail(%d),head(%d),body(%d)!", tail, head, body);
	para_head = head;
	para_tail = tail;
	head_indent = get_indent(head);
	body_indent = get_indent(body);

	SetDot(&orig);
}

void
Justify()
{
	use_lmargin = is_an_arg();
	find_para(BACKWARD);
	DoJustify(para_head, 0, para_tail, length(para_tail), NO,
		  use_lmargin ? LMargin : body_indent);
}

private LinePtr
max_line(l1, l2)
LinePtr	l1,
	l2;
{
	return inorder(l1, 0, l2, 0)? l2 : l1;
}

private LinePtr
min_line(l1, l2)
LinePtr	l1,
	l2;
{
	return inorder(l1, 0, l2, 0)? l1 : l2;
}

void
RegJustify()
{
	Mark	*mp = CurMark(),
		*tailmark;
	LinePtr	l1 = curline,
		l2 = mp->m_line;
	int	c1 = curchar,
		c2 = mp->m_char;
	LinePtr	rl1,
		rl2;

	use_lmargin = is_an_arg();
	(void) fixorder(&l1, &c1, &l2, &c2);
	do {
		DotTo(l1, c1);
		find_para(FORWARD);
		rl1 = max_line(l1, para_head);
		rl2 = min_line(l2, para_tail);
		tailmark = MakeMark(para_tail, 0);
		DoJustify(rl1, (rl1 == l1) ? c1 : 0, rl2,
			  (rl2 == l2) ? c2 : length(rl2),
			  NO, use_lmargin ? LMargin : body_indent);
		l1 = tailmark->m_line->l_next;
		DelMark(tailmark);
		c1 = 0;
	} while (l1 != NULL && l2 != rl2);
}

void
do_rfill(ulm)
bool	ulm;
{
	Mark	*mp = CurMark();
	LinePtr	l1 = curline,
		l2 = mp->m_line;
	int	c1 = curchar,
		c2 = mp->m_char;

	use_lmargin = ulm;
	(void) fixorder(&l1, &c1, &l2, &c2);
	DoJustify(l1, c1, l2, c2, NO, use_lmargin ? LMargin : 0);
}

private void
do_space()
{
	int
		c1,
		diff,
		nspace = 0;
	bool
		funny_space = NO;

	skip_wht_space();
	for (c1 = curchar; --c1 >= 0 && jiswhite(linebuf[c1]); )
		if (linebuf[c1] != ' ')
			funny_space = YES;
	c1 += 1;
	diff = (curchar - c1);

	if (diff != 0) {
		if (c1 > 0 && !eolp()) {
			nspace = 1;
			if (diff >= 2) {
				int	topunct = c1;

				do {
					topunct -= 1;;
				} while (topunct > 0 && strchr("\"')]", linebuf[topunct]) != NULL);

				if (SpaceSent2 && topunct > 0
				&& (linebuf[c1-1] == ':' || strchr("?!.", linebuf[topunct]) != NULL))
					nspace = 2;
			}
		}

		if (funny_space || diff > nspace) {
			del_char(BACKWARD, diff, NO);
			ins_str("  "+(2-nspace));
		}
	}
}

#ifdef MSDOS
/*#pragma loop_opt(off) */
#endif

void
DoJustify(l1, c1, l2, c2, scrunch, indent)
LinePtr	l1,
	l2;
int	c1,
	c2,
	indent;
bool
	scrunch;
{
	Mark	*savedot = MakeMark(curline, curchar),
		*endmark;
	int	okay_char,	/* end of what fits */
		start_char;	/* where we started the line */

	(void) fixorder(&l1, &c1, &l2, &c2);	/* l1/c1 will be before l2/c2 */
	DotTo(l1, c1);
	if (get_indent(l1) >= c1) {
		if (use_lmargin) {
			Bol();
			n_indent(indent + (head_indent - body_indent));
			use_lmargin = NO;	/* turn this off now */
		}
		ToIndent();
	}
	endmark = MakeMark(l2, c2);

	okay_char = start_char = curchar;
	for (;;) {
		/* for each word ... */

		/* skip to end of (possibly empty) input word */
		while (!eolp() && !jiswhite(linebuf[curchar]))
			curchar += 1;

		if (okay_char != start_char && calc_pos(linebuf, curchar) > RMargin) {
			/* This word won't fit in output line
			 * (the first word on a line is always considered to fit).
			 */
			curchar = okay_char;	/* go back to last success */
			if (eolp()) {
				/* no need to introduce a line break: we're already at one */
				if (lastp(curline))
					break;	/* ran out of buffer: stop */
				line_move(FORWARD, 1, NO);
			} else {
				/* break line here.  Note that we split the line before
				 * deleting the (possibly split) whitespace.  This way
				 * marks before and after the current whitespace character
				 * end up on the appropriate side of the newline that
				 * replaces it.
				 */
				LineInsert(1);
				b_char(1);
				DelWtSpace();
				f_char(1);
				DelWtSpace();
				if (scrunch && TwoBlank()) {
					Eol();
					del_char(FORWARD, 1, NO);
					Bol();
				}
			}
			n_indent(indent);
			okay_char = start_char = curchar;
		} else {
			/* this word fits (it might be empty, but that's OK) */
			okay_char = curchar;	/* nail down success */
			/* stop if we've run out of range */
			if (curline == endmark->m_line && curchar >= endmark->m_char)
				break;
			/* process word separator */
			if (eolp() && !lastp(curline)) {
				/* Replace line separator with TWO spaces: this
				 * allows sentence ends to end up with two spaces.
				 */
				del_char(FORWARD, 1, NO);
				ins_str("  ");
			}
			do_space();	/* compress space; advance past it */
		}
	}
	ToMark(savedot);	/* Back to where we were */
	DelMark(endmark);	/* Free up marks */
	DelMark(savedot);
	/* ??? why is the following necessary? -- DHR */
	this_cmd = last_cmd = OTHER_CMD;	/* So everything is under control */
	f_mess(NullStr);
}

#ifdef MSDOS
/*#pragma loop_opt() */
#endif

private void
DoPara(dir)
int	dir;
{
	register int	num = arg_value();
	bool	first_time = YES;

	if (num < 0) {
		num = -num;
		dir = -dir;
	}
	while (--num >= 0) {
tryagain:
		find_para(dir);		/* find paragraph bounderies */
		if (dir == BACKWARD
		&& (!first_time || (para_head == curline && bolp())))
		{
			if (bobp())
				complain((char *)NULL);
			b_char(1);
			first_time = !first_time;
			goto tryagain;
		}
		SetLine((dir == BACKWARD) ? para_head : para_tail);
		if (dir == BACKWARD && !firstp(curline)
		&& i_blank(curline->l_prev)) {
			line_move(BACKWARD, 1, NO);
		} else if (dir == FORWARD) {
			if (lastp(curline)) {
				Eol();
				break;
			}
			/* otherwise */
			line_move(FORWARD, 1, NO);
		}
	}
}

void
BackPara()
{
	DoPara(BACKWARD);
}

void
ForPara()
{
	DoPara(FORWARD);
}
