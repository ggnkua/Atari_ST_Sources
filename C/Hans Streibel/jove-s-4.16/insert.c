/************************************************************************
 * This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  *
 * provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is *
 * included in all the files.                                           *
 ************************************************************************/

#include "jove.h"
#include "jctype.h"
#include "list.h"
#include "chars.h"
#include "disp.h"
#include "abbrev.h"
#include "ask.h"
#include "c.h"
#include "delete.h"
#include "insert.h"
#include "fmt.h"
#include "macros.h"
#include "marks.h"
#include "misc.h"
#include "move.h"
#include "paragraph.h"
#include "screen.h"	/* for tabstop */
#include "sysprocs.h"
#include "proc.h"
#include "wind.h"

private void
	DoNewline proto((bool indentp));

#ifdef LISP
private Bufpos
	*lisp_indent proto((void));
#endif

/* Make a new line after "after" in buffer "buf", unless "after" is NULL,
   in which case we insert the new line before first line. */

LinePtr
listput(buf, after)
register Buffer	*buf;
register LinePtr	after;
{
	register LinePtr	newline = nbufline();

	newline->l_prev = after;
	if (after == NULL) {	/* Before the first line */
		newline->l_next = buf->b_first;
		buf->b_first = newline;
	} else {
		newline->l_next = after->l_next;
		after->l_next = newline;
	}
	if (newline->l_next != NULL)
		newline->l_next->l_prev = newline;
	else if (buf != NULL)
		buf->b_last = newline;
	if (buf && buf->b_dot == NULL)
		buf->b_dot = newline;
	return newline;
}

/* Divide the current line and move the current line to the next one */

void
LineInsert(num)
register int	num;
{
	char	newline[LBSIZE];
	register LinePtr	newdot,
			olddot;
	int	oldchar;

	olddot = curline;
	oldchar = curchar;

	newdot = curline;
	while (--num >= 0) {
		newdot = listput(curbuf, newdot);
		SavLine(newdot, NullStr);
	}

	modify();
	if (curchar != 0) {
		strcpy(newline, &linebuf[curchar]);
		linebuf[curchar] = '\0';	/* Shorten this line */
		SavLine(curline, linebuf);
		strcpy(linebuf, newline);
	} else {	/* Redisplay optimization */
		newdot->l_dline = curline->l_dline;
		SavLine(curline, NullStr);
	}

	makedirty(curline);
	curline = newdot;
	curchar = 0;
	makedirty(curline);
	IFixMarks(olddot, oldchar, curline, curchar);
}

/* Inserts tabs and spaces to move the cursor to column GOAL.  It
   Uses the most optimal number of tabs and spaces no matter what
   was there before hand. */

void
n_indent(goal)
register int	goal;
{
	int	dotcol;

	DelWtSpace();
	dotcol = calc_pos(linebuf, curchar);

	if (tabstop != 0) {
		for (;;) {
			int	incrmt = TABDIST(dotcol);

			if (dotcol + incrmt > goal)
				break;
			insert_c('\t', 1);
			dotcol += incrmt;
		}
	}
	if (dotcol != goal)
		insert_c(' ', (goal - dotcol));
}

#ifdef ABBREV
void
MaybeAbbrevExpand()
{
	if (MinorMode(Abbrev) && !jisident(LastKeyStruck)
	&& !bolp() && jisident(linebuf[curchar - 1]))
		AbbrevExpand();
}
#endif

private void
Insert(c)
char	c;
{
	if (c == CTL('J'))
		LineInsert(arg_value());
	else
		insert_c(c, arg_value());
}

void
overwrite(c, n)
char	c;
int	n;
{
	register int	i;

	for (i = 0; i < n; i++) {
		/* Delete one *column* forward (except that we don't
		 * notice that control characters take two columns).
		 */
		if (!eolp() && (linebuf[curchar] != '\t' || tabstop == 0
		  || TABDIST(calc_pos(linebuf, curchar)) == 1))
		{
			del_char(FORWARD, 1, NO);
		}
		insert_c(c, 1);
	}
}

void
SelfInsert()
{
#ifdef ABBREV
	MaybeAbbrevExpand();
#endif
	if (LastKeyStruck != CTL('J') && MinorMode(OverWrite))
		overwrite(LastKeyStruck, arg_value());
	else
		Insert(LastKeyStruck);

	/* If we are in fill mode and at or beyond the right margin,
	 * we break the line.  However, we won't do this if the new
	 * character is whitespace and we are at the end of the line:
	 * DoJustify would discard the trailing space.
	 */
	if (MinorMode(Fill) && calc_pos(linebuf, curchar) >= RMargin
	&& !(jiswhite(LastKeyStruck) && eolp()))
	{
		int margin;
		Bufpos save;

		if (MinorMode(Indent)) {
			DOTsave(&save);
			ToIndent();
			margin = calc_pos(linebuf, curchar);
			SetDot(&save);
		} else {
			margin = LMargin;
		}
		DoJustify(curline, 0, curline,
			  curchar + (int)strlen(&linebuf[curchar]), YES, margin);
	}
}

/* insert character C N times at point */
void
insert_c(c, n)
char	c;
int	n;
{
	if (n > 0) {
		modify();
		makedirty(curline);
		ins_c(c, linebuf, curchar, n, LBSIZE);
		IFixMarks(curline, curchar, curline, curchar + n);
		curchar += n;
	}
}

/* Tab in to the right place for C mode */

void
Tab()
{
#ifdef LISP
	if (MajorMode(LISPMODE) && (bolp() || !eolp())) {
		int	dotchar = curchar;

		ToIndent();
		if (dotchar > curchar) {
			Mark	*m = MakeMark(curline, dotchar);

			(void) lisp_indent();
			ToMark(m);
			DelMark(m);
		} else {
			(void) lisp_indent();
			ToIndent();
		}
		return;
	}
#endif
	if (MajorMode(CMODE)) {
		if (within_indent())
			(void) c_indent(NO);
		else {
			int	curpos,
				tabbed_pos;

			skip_wht_space();
			curpos = calc_pos(linebuf, curchar);
			tabbed_pos = curpos + (CIndIncrmt - (curpos % CIndIncrmt));
			n_indent(tabbed_pos);
		}
	} else
		SelfInsert();
}

void
QuotChar()
{
	ZXchar	c = ask_ks();

	if (c == '\0') {
		int	n = arg_value();

		while (n-- > 0)
			ins_str("^@");
	} else {
		Insert(c);
#ifdef PCNONASCII
		if (c == PCNONASCII) {
			c = waitchar();
			if (c == '\0') {
				int	n = arg_value();

				while (n-- > 0)
					ins_str("^@");
			} else {
				Insert(c);
			}
		}
#endif
	}
}

/* Insert the paren.  If in C mode and c is a '}' then insert the
   '}' in the "right" place for C indentation; that is indented
   the same amount as the matching '{' is indented. */

int	PDelay = 5,		/* VAR: paren flash delay in tenths of a second */
	CIndIncrmt = 8;	/* VAR: how much each indentation level pushes over in C mode */

void
DoParen()
{
	Bufpos	*bp = NULL;	/* avoid uninitialized complaint from gcc -W */
	ZXchar	c = LastKeyStruck;
	bool	tried = NO;

	if (!jisclosep(c)) {
		SelfInsert();
		return;
	}

	if (MajorMode(CMODE) && c == '}' && within_indent()) {
		bp = c_indent(YES);
		tried = YES;
	}
#ifdef LISP
	if (MajorMode(LISPMODE) && c == ')' && blnkp(linebuf)) {
		bp = lisp_indent();
		tried = YES;
	}
#endif
	SelfInsert();

	if (MinorMode(ShowMatch)
#ifndef MAC
	&& !PreEmptOutput()
#endif
	&& !in_macro())
	{
		b_char(1);	/* Back onto the ')' */
		if (!tried)
			bp = m_paren(c, BACKWARD, NO, YES);
		f_char(1);
		if (bp != NULL) {
			int	nx = in_window(curwind, bp->p_line);

			if (nx != -1) {		/* is visible */
				Bufpos	b;

				DOTsave(&b);
				SetDot(bp);
				SitFor(PDelay);
				SetDot(&b);
			} else
				s_mess("%s", lcontents(bp->p_line));
		}
		mp_error();	/* display error message */
	}
}

void
LineAI()
{
	DoNewline(YES);
}

void
Newline()
{
	DoNewline(MinorMode(Indent));
}

private void
DoNewline(indentp)
bool	indentp;
{
	Bufpos	save;
	int	indent;

	/* first we calculate the indent of the current line */
	DOTsave(&save);
	ToIndent();
	indent = calc_pos(linebuf, curchar);
	SetDot(&save);

#ifdef ABBREV
	MaybeAbbrevExpand();
#endif
	if (
#ifdef LISP
	    MajorMode(LISPMODE) ||
#endif
	    indentp)
	{
		DelWtSpace();
	}

	/* If there is more than 2 blank lines in a row then don't make
	   a newline, just move down one. */
	if (arg_value() == 1 && eolp() && TwoBlank())
		SetLine(curline->l_next);
	else
		LineInsert(arg_value());

	if (indentp) {
#ifdef LISP
	    if (MajorMode(LISPMODE))
		(void) lisp_indent();
	    else
#endif
	    {
		Bol();
		n_indent((LMargin == 0) ? indent : LMargin);
	    }
	}
}

void
ins_str(str)
const char *str;
{
	ins_str_wrap(str, NO, LBSIZE-1);
}

void
ins_str_wrap(str, ok_nl, wrap_off)
const char *str;
bool ok_nl;
int wrap_off;
{
	register char c;
	Bufpos save;
	int llen;

	if (*str == '\0')
		return;		/* ain't nothing to insert! */
	if (wrap_off > LBSIZE-1)
		wrap_off = LBSIZE-1;
	DOTsave(&save);
	llen = strlen(linebuf);
	while ((c = *str++) != '\0') {
		if (c == '\n' || (ok_nl && llen >= wrap_off)) {
			IFixMarks(save.p_line, save.p_char, curline, curchar);
			modify();
			makedirty(curline);
			LineInsert(1);
			DOTsave(&save);
			llen = strlen(linebuf);
		}
		if (c != '\n') {
			ins_c(c, linebuf, curchar++, 1, LBSIZE);
			llen += 1;
		}
	}
	IFixMarks(save.p_line, save.p_char, curline, curchar);
	modify();
	makedirty(curline);
}

void
open_lines(n)
int	n;
{
	Bufpos	dot;

	DOTsave(&dot);
	LineInsert(n);	/* Open the lines... */
	SetDot(&dot);
}

void
OpenLine()
{
	open_lines(arg_value());
}

/* Take the region FLINE/FCHAR to TLINE/TCHAR and insert it at
   ATLINE/ATCHAR in WHATBUF. */

Bufpos *
DoYank(fline, fchar, tline, tchar, atline, atchar, whatbuf)
LinePtr	fline,
	tline,
	atline;
int	fchar,
	tchar,
	atchar;
Buffer	*whatbuf;
{
	register LinePtr	newline;
	static Bufpos	bp;
	char	save[LBSIZE],
		buf[LBSIZE];
	LinePtr	startline = atline;
	int	startchar = atchar;

	lsave();
	if (whatbuf != NULL)
		modify();
	(void) ltobuf(atline, genbuf);
	strcpy(save, &genbuf[atchar]);

	(void) ltobuf(fline, buf);
	if (fline == tline)
		buf[tchar] = '\0';

	linecopy(genbuf, atchar, &buf[fchar]);
	atline->l_dline = putline(genbuf);
	makedirty(atline);

	fline = fline->l_next;
	while (fline != tline->l_next) {
		newline = listput(whatbuf, atline);
		newline->l_dline = fline->l_dline;
		makedirty(newline);
		fline = fline->l_next;
		atline = newline;
		atchar = 0;
	}

	getline(atline->l_dline, genbuf);
	atchar += tchar;
	linecopy(genbuf, atchar, save);
	atline->l_dline = putline(genbuf);
	makedirty(atline);
	IFixMarks(startline, startchar, atline, atchar);
	bp.p_line = atline;
	bp.p_char = atchar;
	if (whatbuf != NULL)
		this_cmd = YANKCMD;
	getDOT();			/* Whatever used to be in linebuf */
	return &bp;
}

void
YankPop()
{
	Mark	*mp = CurMark();
	LinePtr	line,
		last;
	Bufpos	*dot;

	switch (last_cmd) {
	case YANKCMD:
		{
			/* Direction to rotate the ring */
			int	dir = arg_value() < 0? 1 : NUMKILLS - 1;

			/* Now must find a recently killed region. */
			do {
				killptr = (killptr+dir) % NUMKILLS;
			} while (killbuf[killptr] == NULL);
		}
		break;
	case UNDOABLECMD:
		break;
	default:
		complain("Yank something first!");
		/*NOTREACHED*/
	}
	lfreelist(reg_delete(mp->m_line, mp->m_char, curline, curchar));
	line = killbuf[killptr];
	last = lastline(line);
	dot = DoYank(line, 0, last, length(last), curline, curchar, curbuf);
	MarkSet(CurMark(), curline, curchar);
	SetDot(dot);
	if (last_cmd == UNDOABLECMD)
		this_cmd = OTHER_CMD;
}

/* This is an attempt to reduce the amount of memory taken up by each line.
   Without this each malloc of a line uses sizeof (line) + sizeof(HEADER)
   where line is 3 words and HEADER is 1 word.
   This is going to allocate memory in chucks of CHUNKSIZE * sizeof (line)
   and divide each chuck into Lines.  A line is free in a chunk when its
   line->l_dline == NULL_DADDR, so freeline sets l_dline to NULL_DADDR. */

#define CHUNKSIZE	300

#ifdef FAR_LINES
# ifdef __BORLANDC__
#  include <alloc.h>	/* Borland farmalloc() */
# else
#  ifdef __WATCOMC__
#   include <malloc.h>
#   define farmalloc(sz)	_fmalloc(sz)
#   define farfree(x)	_ffree(x)
#  else
#   include <dos.h>	/* Zortech farmalloc(), MSC (?) */
#  endif
# endif
typedef struct chunk _far	*ChunkPtr;
# define CHUNKMALLOC(s)	((ChunkPtr) farmalloc(s))
# define CHUNKFREE(c)	farfree((void _far *) (c))
#else
typedef struct chunk	*ChunkPtr;
# define CHUNKMALLOC(s)	((ChunkPtr) malloc(s))
# define CHUNKFREE(c)	free((UnivPtr) (c))
#endif

struct chunk {
	ChunkPtr	c_nextchunk;	/* Next chunk of lines */
	int	c_nlines;	/* Number of lines in this chunk (so they
				   don't all have to be CHUNKSIZE long). */
	struct line	c_block[1 /* or larger */];	/* Chunk of memory */
};

private ChunkPtr	fchunk = NULL;	/* first chunk */
private LinePtr	ffline = NULL;	/* First free line */
private LinePtr	faline = NULL;	/* First available line */

private void
freeline(line)
register LinePtr	line;
{
	line->l_dline = NULL_DADDR;
	line->l_next = ffline;
	if (ffline)
		ffline->l_prev = line;
	line->l_prev = NULL;
	ffline = line;
}

/* Make sure that there are no dangling references to lines in the free list,
 * then move them to the end of the avail list.
 */

private void
RecycleLines()
{
	if (ffline == NULL)
		return;	/* nothing to do */

	ChkErrorLines();
	/* ChkWindowLines(); -- nothing needs attention */
	/* ChkBufLines(); -- nothing needs attention */

	if (faline == NULL) {
		faline = ffline;
	} else {
		LinePtr	laline = lastline(faline);

		laline->l_next = ffline;
		ffline->l_prev = laline;
	}
	ffline = NULL;
}

void
lfreelist(first)
register LinePtr	first;
{
	if (first != NULL)
		lfreereg(first, lastline(first));
}

/* Append region from line1 to line2 onto the free list of lines */

void
lfreereg(line1, line2)
register LinePtr	line1,
		line2;
{
	register LinePtr	next,
			last = line2->l_next;

	while (line1 != last) {
		next = line1->l_next;
		freeline(line1);
		line1 = next;
	}
}

private bool
newchunk()
{
	register LinePtr	newline;
	register int	i;
	ChunkPtr	f;
	int	nlines = CHUNKSIZE;
	bool	done_gc = NO;

	for (;;) {
		f = CHUNKMALLOC(sizeof(struct chunk) + sizeof(struct line) * (nlines-1));
		if (f != NULL)
			break;
		if (!done_gc) {
			GCchunks();
			done_gc = YES;
		} else {
			nlines /= 2;
			if (nlines <= 0)
				return NO;
		}
	}

	f->c_nlines = nlines;
	for (i = 0, newline = f->c_block; i < nlines; newline++, i++) {
		newline->l_dline = NULL_DADDR;
		newline->l_next = faline;
		if (faline)
			faline->l_prev = newline;
		newline->l_prev = NULL;
		faline = newline;
	}
	f->c_nextchunk = fchunk;
	fchunk = f;
	return YES;
}

/* New BUFfer LINE */

LinePtr
nbufline()
{
	register LinePtr	newline;

	if (faline == NULL) {
		RecycleLines();
		if (faline == NULL) {
			if (!newchunk())
				complain("[Out of lines] ");
		}
	}
	newline = faline;
	faline = newline->l_next;
	if (faline)
		faline->l_prev = NULL;
	return newline;
}

/* Remove the free lines, in chunk c, from the free list because they are
   no longer free. */

private void
remfreelines(c)
register ChunkPtr	c;
{
	register LinePtr	lp;
	register int	i;

	for (lp = c->c_block, i = c->c_nlines; i != 0 ; lp++, i--) {
		if (lp->l_prev == NULL)
			faline = lp->l_next;
		else
			lp->l_prev->l_next = lp->l_next;
		if (lp->l_next != NULL)
			lp->l_next->l_prev = lp->l_prev;
	}
}

/* This is used to garbage collect the chunks of lines when malloc fails
   and we are NOT looking for a new buffer line.  This goes through each
   chunk, and if every line in a given chunk is not allocated, the entire
   chunk is `free'd by "free()". */

/* ??? I think that this WILL be called when we are looking for a new
 * buffer line: nbufline() => newchunk() => GCchunks() -- DHR
 */

void
GCchunks()
{
	register ChunkPtr	cp;
	ChunkPtr	prev = NULL,
			next;
	register int	i;
	register LinePtr	newline;

	RecycleLines();
	for (cp = fchunk; cp != NULL; cp = next) {
		next = cp->c_nextchunk;
		for (i = cp->c_nlines, newline = cp->c_block; ; newline++, i--) {
			if (i == 0) {
				/* Empty: unlink and free it!!! */
				if (prev == NULL)
					fchunk = cp->c_nextchunk;
				else
					prev->c_nextchunk = cp->c_nextchunk;
				remfreelines(cp);
				CHUNKFREE(cp);
				break;
			}
			if (newline->l_dline != NULL_DADDR) {
				/* it's a keeper */
				prev = cp;
				break;
			}
		}
	}
}

#ifdef LISP

#include "re.h"

/* Grind S-Expr */

void
GSexpr()
{
	Bufpos	dot,
		end;

	if (linebuf[curchar] != '(')
		complain((char *)NULL);
	DOTsave(&dot);
	FSexpr();
	DOTsave(&end);
	SetDot(&dot);
	for (;;) {
		if (curline == end.p_line)
			break;
		line_move(FORWARD, 1, NO);
		if (!blnkp(linebuf))
			(void) lisp_indent();
	}
	SetDot(&dot);
}

/* lisp_indent() indents a new line in Lisp Mode, according to where
   the matching close-paren would go if we typed that (sort of). */

private List	*specials = NULL;

private void
init_specials()
{
	static char *const words[] = {
		"case",
		"def",
		"dolist",
		"fluid-let",
		"lambda",
		"let",
		"lexpr",
		"macro",
		"named-l",	/* named-let and named-lambda */
		"nlambda",
		"prog",
		"selectq",
		NULL
	};
	char	*const *wordp = words;

	while (*wordp != NULL)
		list_push(&specials, (UnivPtr) *wordp++);
}

void
AddSpecial()
{
	char	*word;
	register List	*lp;

	if (specials == NULL)
		init_specials();
	word = ask((char *)NULL, ProcFmt);
	for (lp = specials; lp != NULL; lp = list_next(lp))
		if (strcmp((char *) list_data(lp), word) == 0)
			return;		/* already in list */
	(void) list_push(&specials, (UnivPtr) copystr(word));
}

private Bufpos *
lisp_indent()
{
	Bufpos	*bp,
		savedot;
	int	goal;

	bp = m_paren(')', BACKWARD, NO, YES);

	if (bp == NULL)
		return NULL;

	/* We want to end up

		(atom atom atom ...
		      ^ here.
	 */

	DOTsave(&savedot);
	SetDot(bp);
	f_char(1);
	if (linebuf[curchar] != '(') {
		register List	*lp;

		if (specials == NULL)
			init_specials();
		for (lp = specials; lp != NULL; lp = list_next(lp))
			if (caseeqn((char *) list_data(lp),
				     &linebuf[curchar],
				     strlen((char *) list_data(lp))))
				break;
		if (lp == NULL) {	/* not special */
			int	c_char = curchar;

			while (jisident(linebuf[curchar]))
				curchar += 1;
			if (LookingAt("[ \t]*;\\|[ \t]*$", linebuf, curchar)) {
				curchar = c_char;
			} else {
				while (linebuf[curchar] == ' ')
					curchar += 1;
			}
		} else {
			curchar += 1;
		}
	}
	goal = calc_pos(linebuf, curchar);
	SetDot(&savedot);
	Bol();
	n_indent(goal);

	return bp;
}
#endif /* LISP */
