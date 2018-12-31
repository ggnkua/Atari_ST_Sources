/************************************************************************
 * This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  *
 * provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is *
 * included in all the files.                                           *
 ************************************************************************/

/* Contains commands for C mode.  Paren matching routines are in here. */

#include "jove.h"
#include "re.h"
#include "c.h"
#include "jctype.h"
#include "disp.h"
#include "delete.h"
#include "insert.h"
#include "fmt.h"
#include "marks.h"
#include "misc.h"
#include "move.h"
#include "paragraph.h"

private void
	FindMatch proto((int));

private bool
backslashed(lp, cpos)
register char	*lp;
register int	cpos;
{
	register int	cnt = 0;

	while (cpos > 0 && lp[--cpos] == '\\')
		cnt += 1;
	return (cnt % 2) != 0;
}

private char	*p_types = "(){}[]";
private int	mp_kind;
#define MP_OKAY		0
#define MP_MISMATCH	1
#define MP_UNBALANCED	2
#define MP_INCOMMENT	3

void
mp_error()
{
	switch (mp_kind) {
	case MP_MISMATCH:
		message("[Mismatched parentheses]");
		break;

	case MP_UNBALANCED:
		message("[Unbalanced parenthesis]");
		break;

	case MP_INCOMMENT:
		message("[Inside a comment]");
		break;

	case MP_OKAY:
	default:
		return;
	}
	rbell();
}

/* Search from the current position for the paren that matches p_type.
   Search in the direction dir.  If can_mismatch is YES then it is okay
   to have mismatched parens.  If stop_early is YES then when an open
   paren is found at the beginning of a line, it is assumed that there
   is no point in backing up further.  This is so when you hit tab or
   LineFeed outside, in-between procedure/function definitions, it won't
   sit there searching all the way to the beginning of the file for a
   match that doesn't exist.  {forward,backward}-s-expression are the
   only ones that insist on getting the "true" story. */

Bufpos *
m_paren(p_type, dir, can_mismatch, can_stop)
char	p_type;
register int	dir;
bool	can_mismatch;
bool	can_stop;
{
	static Bufpos	ret;
	Bufpos	savedot;
	struct RE_block	re_blk;
	int	count = 0;
	register char	c = '\0';	/* avoid uninitialized complaint from gcc -W */
	char
		p_match,	/* kind of paren matching p_type */
		quote_c = '\0';
	register int	c_char;
	int	in_comment = -1;	/* -1, YES, or NO */
	bool	stopped = NO;

	REcompile(MajorMode(CMODE)? "[(){}[\\]/\"']" : "[(){}[\\]\"]",
		YES, &re_blk);
	{
		char	*cp = strchr(p_types, p_type);

		if (cp == NULL)
			complain("[Cannot match %c's]", p_type);
		p_match = cp[dir];
	}
	DOTsave(&savedot);

	/* To make things a little faster I avoid copying lines into
	   linebuf by setting curline and curchar by hand.  Warning:
	   this is slightly to very risky.  When I did this there were
	   lots of problems with procedures that expect the contents of
	   curline to be in linebuf. */
	do {
		Bufpos	*sp = docompiled(dir, &re_blk);
		register char	*lp;

		if (sp == NULL)
			break;
		lp = lbptr(sp->p_line);

		curline = sp->p_line;
		curchar = sp->p_char;	/* here's where I cheat */

		c_char = curchar;
		if (dir == FORWARD)
			c_char -= 1;
		if (backslashed(lp, c_char))
			continue;
		c = lp[c_char];
		/* check if this is a comment (if we're not inside quotes) */
		if (quote_c == '\0' && c == '/') {
			int	new_ic = in_comment;	/* -1, YES, or NO */

			/* close comment */
			if ((c_char != 0) && lp[c_char - 1] == '*') {
				new_ic = (dir == FORWARD) ? NO : YES;
				if (new_ic == NO && in_comment == -1) {
					count = 0;
					quote_c = '\0';
				}
			} else if (lp[c_char + 1] == '*') {
				new_ic = (dir == FORWARD) ? YES : NO;
				if (new_ic == NO && in_comment == -1) {
					count = 0;
					quote_c = '\0';
				}
			}
			in_comment = new_ic;
		}
		if (in_comment == YES)
			continue;
		if (c == '"' || c == '\'') {
			if (quote_c == c)
				quote_c = '\0';
			else if (quote_c == '\0')
				quote_c = c;
		}
		if (quote_c != '\0')
			continue;
		if (jisopenp(c)) {
			count += dir;
			if (c_char == 0 && can_stop && count >= 0) {
				stopped = YES;
				break;
			}
		} else if (jisclosep(c)) {
			count -= dir;
		}
	} while (count >= 0);

	ret.p_line = curline;
	ret.p_char = curchar;

	curline = savedot.p_line;
	curchar = savedot.p_char;	/* here's where I undo it */

	if (count >= 0)
		mp_kind = MP_UNBALANCED;
	else if (c != p_match)
		mp_kind = MP_MISMATCH;
	else
		mp_kind = MP_OKAY;

	/* If we stopped (which means we were allowed to stop) and there
	   was an error, we clear the error so no error message is printed.
	   An error should be printed ONLY when we are sure about the fact,
	   namely we didn't stop prematurely HOPING that it was the right
	   answer. */
	if (stopped && mp_kind != MP_OKAY) {
		mp_kind = MP_OKAY;
		return NULL;
	}
	if (mp_kind == MP_OKAY || (mp_kind == MP_MISMATCH && can_mismatch))
		return &ret;
	return NULL;
}

private void
do_expr(dir, skip_words)
register int	dir;
bool	skip_words;
{
	register char	syntax = (dir == FORWARD) ? C_BRA : C_KET;

	if (dir == BACKWARD)
		b_char(1);
	for (;;) {
		char	c = linebuf[curchar];

		if (!skip_words && jisident(c)) {
			for (;;) {
				if (dir == FORWARD? c == '\0' : bolp())
						break;
				curchar += dir;
				if (!jisident(linebuf[curchar])) {
					if (dir == BACKWARD)
						curchar += 1;
					break;
				}
			}
		    break;
		}
/*
 * BUG ALERT! The following test ought not to recognise brackets inside
 * comments or quotes
 */
		if (has_syntax(c, syntax)) {
			FindMatch(dir);
			break;
		}
		f_char(dir);
		if (eobp() || bobp())
			return;
	}
}

void
FSexpr()
{
	register int	num = arg_value();

	if (num < 0) {
		negate_arg();
		BSexpr();
	}
	while (--num >= 0)
		do_expr(FORWARD, NO);
}

void
FList()
{
	register int	num = arg_value();

	if (num < 0) {
		negate_arg();
		BList();
	}
	while (--num >= 0)
		do_expr(FORWARD, YES);
}

void
BSexpr()
{
	register int	num = arg_value();

	if (num < 0) {
		negate_arg();
		FSexpr();
	}
	while (--num >= 0)
		do_expr(BACKWARD, NO);
}

void
BList()
{
	register int	num = arg_value();

	if (num < 0) {
		negate_arg();
		FList();
	}
	while (--num >= 0)
		do_expr(BACKWARD, YES);
}

void
BUpList()
{
	register int	num = arg_value();
	Bufpos	*mp;

	if (num < 0) {
		negate_arg();
		FDownList();
	}
	while (--num >= 0) {
		mp = m_paren(')', BACKWARD, YES, YES);
		if (mp == NULL)
			mp_error();
		else
			SetDot(mp);
	}
}

void
FDownList()
{
	register int	num = arg_value();
	Bufpos	*sp;
	char	*sstr = "[{([\\])}]";

	if (num < 0) {
		negate_arg();
		BUpList();
	}
	while (--num >= 0) {
/*
 * BUG ALERT! The following test ought not to recognise brackets inside
 * comments or quotes
 */
		sp = dosearch(sstr, FORWARD, YES);
		if (sp == NULL || jisclosep(lcontents(sp->p_line)[sp->p_char - 1]))
			complain("[No contained expression]");
		SetDot(sp);
	}
}

/* Move to the matching brace or paren depending on the current position
   in the buffer. */

private void
FindMatch(dir)
int	dir;
{
	register Bufpos	*bp;
	register char	c = linebuf[curchar];

	if (strchr(p_types, c) == NULL || backslashed(linebuf, curchar))
		complain((char *)NULL);
	if (dir == FORWARD)
		f_char(1);
	bp = m_paren(c, dir, YES, NO);
	if (dir == FORWARD)
		b_char(1);
	if (bp != NULL)
		SetDot(bp);
	mp_error();	/* if there is an error the user wants to
			   know about it */
}

#define ALIGN_ARGS	(-1)

/* If CArgIndent == ALIGN_ARGS then the indentation routine will
   indent a continued line by lining it up with the first argument.
   Otherwise, it will indent CArgIndent characters past the indent
   of the first line of the procedure call. */

int	CArgIndent = ALIGN_ARGS;	/* VAR: how to indent arguments to C functions */

/* indent for C code */
Bufpos *
c_indent(brace)
bool	brace;
{
	Bufpos	*bp;
	int	new_indent = 0,
		current_indent,
		increment = brace? 0 : CIndIncrmt;

	/* Find matching paren, which may be a mismatch now.  If it
	   is not a matching curly brace then it is a paren (most likely).
	   In that case we try to line up the arguments to a procedure
	   or inside an of statement. */
	if ((bp = m_paren('}', BACKWARD, YES, YES)) != NULL) {
		Bufpos	save;
		int	matching_indent;

		DOTsave(&save);
		SetDot(bp);		/* go to matching paren */
		ToIndent();
		matching_indent = calc_pos(linebuf, curchar);
		SetDot(bp);
		switch (linebuf[curchar]) {
		case '{':
			new_indent = matching_indent;
			if (!bolp()) {
				b_char(1);
				/* If we're not within the indent then we
				   can assume that there is either a C keyword
				   line DO on the line before the brace, or
				   there is a parenthesized expression.  If
				   that's the case we want to go backward
				   over that to the beginning of the expression
				   so that we can get the correct indent for
				   this matching brace.  This handles wrapped
				   if statements, etc. */
				if (!within_indent()) {
					Bufpos	savematch;

					savematch = *bp;

					do_expr(BACKWARD, NO);
					ToIndent();
					new_indent = calc_pos(linebuf, curchar);

					/* do_expr() calls b_paren, which
					   returns a pointer to a structure,
					   and that pointer is in BP so we
					   have to save away the matching
					   paren and restore it in the
					   following line ... sigh */
					*bp = savematch;
				}
			}
			if (!brace)
				new_indent += (increment - (new_indent % increment));
			break;

		case '(':
			if (CArgIndent == ALIGN_ARGS) {
				f_char(1);
				new_indent = calc_pos(linebuf, curchar);
			} else
				new_indent = matching_indent + CArgIndent;
			break;
		}
		SetDot(&save);
	}

	/* new_indent is the "correct" place to indent.  Now we check to
	   see if what we consider as the correct place to indent is to
	   the LEFT of where we already are.  If it is, and we are NOT
	   handling a brace, then we assume that the person wants to tab
	   in further than what we think is right (for some reason) and
	   so we allow that. */

	ToIndent();
	current_indent = calc_pos(linebuf, curchar);
	if (!brace && new_indent <= current_indent)
		new_indent = current_indent + (increment - (current_indent % increment));
	Bol();
	DelWtSpace();			/* nice uniform Tabs*Space* */
	n_indent(new_indent);

	return bp;
}

private void
re_indent(incr)
int	incr;
{
	LinePtr	l1, l2, lp;
	int	c1, c2;
	Mark	*m = CurMark();
	Bufpos	savedot;

	DOTsave(&savedot);
	l1 = curline;
	c1 = curchar;
	l2 = m->m_line;
	c2 = m->m_char;
	(void) fixorder(&l1, &c1, &l2, &c2);
	for (lp = l1; lp != l2->l_next; lp = lp->l_next) {
		int	indent;

		SetLine(lp);
		ToIndent();
		indent = calc_pos(linebuf, curchar);
		if (indent != 0 || linebuf[0] != '\0')
			n_indent(indent + incr);
	}
	SetDot(&savedot);
}

void
LRShift()
{
	re_indent(-arg_or_default(CIndIncrmt));
}

void
RRShift()
{
	re_indent(arg_or_default(CIndIncrmt));
}

#ifdef CMT_FMT

char	CmtFmt[80] = "/*%n%! * %c%!%n */";	/* VAR: comment format */

/* Strip leading and trailing white space.  Skip over any imbedded '\n's. */

private void
strip_c(from, to)
char	*from,
	*to;
{
	register char
		*fr_p = from,
		*to_p = to,
		c;

	while ((c = *fr_p) == '\n' || jiswhite(c))
		fr_p += 1;
	while ((c = *fr_p) != '\0') {
		if (c != '\n')
			*to_p++ = c;
		fr_p += 1;
	}
	while (to_p > to && jiswhite(to_p[-1]))
		to_p -= 1;
	*to_p = '\0';
}

# define CMT_STR_BOUND	20

private char	open_c[CMT_STR_BOUND],	/* the open comment format string */
		open_pat[CMT_STR_BOUND],	/* the search pattern for open comment */
		l_header[CMT_STR_BOUND],	/* the prefix for each comment line */
		l_trailer[CMT_STR_BOUND],	/* the suffix ... */
		close_c[CMT_STR_BOUND],
		close_pat[CMT_STR_BOUND];

private bool	nl_in_close_c;

/* Fill in the data structures above from the format string.  Don't return
   if there's trouble. */

private void
parse_cmt_fmt()
{

	static char	*const component[] = {
		open_c,
		l_header,
		l_trailer,
		close_c
	};
	register char	*fmtp = CmtFmt;
	register char	*const *c_body = component,
			*body_p = *c_body,
			*body_limit = body_p + CMT_STR_BOUND - 1;
	char	c;
	int	comp_no = 0;

	/* pick apart the comment string */
	nl_in_close_c = NO;
	while ((c = *fmtp++) != '\0') {
		if (c == '%') {
			switch(c = *fmtp++) {
			case 'n':
				switch (comp_no) {
				case 0:
					break;
				case 3:
					nl_in_close_c = YES;
					break;
				default:
					complain("%%n not allowed in line header or trailer: %s",
						fmtp - 2);
					/* NOTREACHED */
				}
				c = '\n';
				break;
			case 't':
				c = '\t';
				break;
			case '%':
				break;
			case '!':
			case 'c':
				if (++comp_no == elemsof(component))
					complain("too many components");
				if ((c=='c') != (comp_no==2))
					complain("wrong separator: %%%c", c);
				*body_p++ = '\0';
				body_p = *++c_body;
				body_limit = body_p + CMT_STR_BOUND - 1;
				continue;
			default:
				complain("[Unknown comment escape: %%%c]", c);
				/*NOTREACHED*/
			}
		}
		if (body_p >= body_limit)
			complain("component too long");
		*body_p++ = c;
	}
	*body_p = '\0';
	while (++comp_no != elemsof(component))
		**++c_body = '\0';
	/* make search patterns */
	strip_c(open_c, open_pat);
	strip_c(close_c, close_pat);
}

void
Comment()
{
	int	saveRMargin,
		indent_pos;
	bool	found_close;
	size_t	header_len,
		trailer_len;
	register char	*cp;
	Bufpos	open_c_pt,
		close_c_pt,
		tmp_bp,
		*match_o,
		*match_c;
	Mark	*entry_mark,	/* end of comment (we may terminate it) */
		*open_c_mark,	/* start of comment (reference to curmark) */
		*savedot;

	parse_cmt_fmt();
	/* Figure out if we're "inside" a comment.
	 * First look back for opening comment symbol.
	 */
	if ((match_o = dosearch(open_pat, BACKWARD, NO)) == NULL)
		complain("No opening %s to match to.", open_pat);
	open_c_pt = *match_o;
	if ((match_c = dosearch(close_pat, BACKWARD, NO)) != NULL
	&& inorder(open_c_pt.p_line, open_c_pt.p_char,
		    match_c->p_line, match_c->p_char))
		complain("[Must be between %s and %s to re-format]",
			open_pat, close_pat);

	/* Now look forward for closing comment symbol.
	 * This involves looking forward for the next opening too.
	 */
	if ((match_o = dosearch(open_pat, FORWARD, NO)) != NULL) {
		tmp_bp = *match_o;
		match_o = &tmp_bp;
	}
	match_c = dosearch(close_pat, FORWARD, NO);

	/* If we found the right close comment symbol, we format
	 * up to it; otherwise we format up to dot.  We have found the
	 * close if we found (looking forward) a close not preceded by
	 * an open.
	 */
	found_close = match_c != NULL
		&& (match_o == NULL
			|| inorder(match_c->p_line, match_c->p_char,
				match_o->p_line, match_o->p_char));

	if (found_close) {
		close_c_pt = *match_c;
	} else {
		close_c_pt.p_line = curline;
		close_c_pt.p_char = curchar;
	}

	SetDot(&open_c_pt);
	set_mark();	/* user visible mark! */
	open_c_mark = curmark;
	indent_pos = calc_pos(linebuf, curchar);

	/* move to end; delete close if it exists */
	SetDot(&close_c_pt);
	CopyRegion();
	if (found_close)
		del_char(BACKWARD, (int)strlen(close_pat), NO);
	entry_mark = MakeMark(curline, curchar);

	/* always separate the comment body from anything preceeding it */
	ToMark(open_c_mark);
	LineInsert(1);
	DelWtSpace();
	Bol();

	/* insert comment open string */
	for (cp = open_c; *cp!='\0'; cp++) {
		if (*cp == '\n') {
			if (!eolp())
				LineInsert(1);
			else
				line_move(FORWARD, 1, NO);
		} else if (jiswhite(*cp)) {
			if (linebuf[curchar] != *cp)
				insert_c(*cp, 1);
		} else {
			/* Since we matched the open comment string
			 * on this line, we don't need to worry about
			 * crossing line boundaries.
			 */
			curchar += 1;
		}
	}
	savedot = MakeMark(curline, curchar);

	/* We need to strip the line header pattern of leading
	 * white space since we need to match the line after all of
	 * its leading whitespace is gone.
	 */
	for (cp = l_header; *cp && (jiswhite(*cp)); cp++)
		;
	header_len = strlen(cp);
	trailer_len = strlen(l_trailer);

	/* Strip each comment line of the open and close comment strings
	   before reformatting it. */

	do {
		Bol();
		DelWtSpace();
		if (header_len && strncmp(linebuf, cp, header_len)==0)
			del_char(FORWARD, (int)header_len, NO);
		if (trailer_len) {
			Eol();
			if ((size_t)curchar > trailer_len
			&& strncmp(&linebuf[curchar - trailer_len],
				      l_trailer, trailer_len)==0)
				del_char(BACKWARD, (int)trailer_len, NO);
		}
		if (curline->l_next != NULL)
			line_move(FORWARD, 1, NO);
		else
			break;
	} while (curline != entry_mark->m_line->l_next);

	/* Now that comment decoration is gone, use normal fill
	 * routine to format body.
	 */

	do_set_mark(savedot->m_line, savedot->m_char);	/* user visible mark! */
	DelMark(savedot);
	ToMark(entry_mark);
	saveRMargin = RMargin;
	RMargin = saveRMargin - strlen(l_header) -
		  strlen(l_trailer) - indent_pos + 2;
	do_rfill(NO);	/* justify from mark through point */
	RMargin = saveRMargin;
	PopMark();	/* get back to the start of the comment; discard mark */

	/* redecorate newly filled comment text */

	do {
		if (curline != open_c_mark->m_line->l_next) {
			Bol();
			n_indent(indent_pos);
			ins_str(l_header);
		}
		Eol();
		if (nl_in_close_c || (curline != entry_mark->m_line))
			ins_str(l_trailer);
		if (curline->l_next != NULL)
			line_move(FORWARD, 1, NO);
		else
			break;
	} while (curline != entry_mark->m_line->l_next);

	/* handle the close comment symbol */
	if (curline == entry_mark->m_line->l_next) {
		line_move(BACKWARD, 1, NO);
		Eol();
	}
	DelMark(entry_mark);
	DelWtSpace();
	/* if the addition of the close symbol would cause the line
	 * to be too long, put the close symbol on the next line.
	 */
	if (!nl_in_close_c
	&& (int)strlen(close_c) + calc_pos(linebuf, curchar) > RMargin)
	{
		LineInsert(1);
		n_indent(indent_pos);
	}
	for (cp = close_c; *cp; cp++) {
		if (*cp == '\n') {
			LineInsert(1);
			n_indent(indent_pos);
		} else
			insert_c(*cp, 1);
	}
	ExchPtMark();
	Eol();
	del_char(FORWARD, 1, NO);
	this_cmd = UNDOABLECMD;	/* allow yank-pop to undo */
}

#endif /* CMT_FMT */
