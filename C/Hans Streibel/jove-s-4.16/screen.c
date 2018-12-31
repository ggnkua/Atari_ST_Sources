/************************************************************************
 * This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  *
 * provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is *
 * included in all the files.                                           *
 ************************************************************************/

#include "jove.h"
#include "fp.h"
#include "chars.h"
#include "jctype.h"
#include "disp.h"
#include "extend.h"
#include "fmt.h"
#include "term.h"
#include "mac.h"
#include "screen.h"
#include "wind.h"

int	AbortCnt,
	tabstop = 8;	/* VAR: expand tabs to this number of spaces */

struct scrimage
	*DesiredScreen = NULL,
	*PhysScreen = NULL;

private struct screenline   *Savelines = NULL;	/* scratch entries (LI of them) */

private void LEclear proto((struct screenline *));	/* free s_effects component */

private char	*cursor;			/* offset into current Line */

char	*cursend;

int	CapCol,
	CapLine;

private int
	i_line,
	i_col;

void
make_scr()
{
	register int	i;
	register struct screenline	*ns;
	register char	*nsp;
	static char	*screenchars = NULL;
	static volatile int	oldLI = 0;

	/* In case we are RESHAPING the window! */
	if (DesiredScreen != NULL)
		free((UnivPtr) DesiredScreen);
	if (PhysScreen != NULL)
		free((UnivPtr) PhysScreen);
	i = oldLI;
	oldLI = 0;
	if (Savelines != NULL) {
		/* Note: each screenline in Savelines has a null s_effects
		 * (or is uninitialized).  LEclear must not be applied.
		 */
		free((UnivPtr) Savelines);
	}
	if (Screen != NULL) {
#ifdef HIGHLIGHTING
		for (ns = Screen; ns != &Screen[i]; ns++)
			LEclear(ns);
#endif
		free((UnivPtr) Screen);
	}
	if (screenchars != NULL)
		free((UnivPtr) screenchars);	/* free all the screen data */

	DesiredScreen = (struct scrimage *) malloc((unsigned) LI * sizeof (struct scrimage));
	PhysScreen = (struct scrimage *) malloc((unsigned) LI * sizeof (struct scrimage));

	Savelines = (struct screenline *)
			malloc((unsigned) LI * sizeof(struct screenline));
	ns = Screen = (struct screenline *)
			malloc((unsigned) LI * sizeof(struct screenline));

	nsp = screenchars = (char *) malloc((unsigned)CO * LI);

	if (DesiredScreen == NULL
	|| PhysScreen == NULL
	|| Savelines == NULL
	|| ns == NULL
	|| nsp == NULL)
	{
		writef("\n\rCannot malloc screen!\n");
		finish(-1);	/* die! */
	}

	for (i = 0; i < LI; i++) {
		ns->s_line = nsp;
		/* End of Line (nsp[CO-1] is never used) */
		ns->s_roof = nsp + CO - 1;
		ns->s_effects = NOEFFECT;
		nsp += CO;
		ns += 1;

		/* ??? The following is a fudge to placate Purify.
		 * There is a real bug here, so we squash it with
		 * a sledge hammer.  What is the correct fix?
		 */
		{
			register struct scrimage	*p;

			p = &PhysScreen[i];
			p->s_offset = 0;
			p->s_flags = 0;
			p->s_vln = 0;
			p->s_id = NULL_DADDR;
			p->s_lp = NULL;
			p->s_window = NULL;

			p = &DesiredScreen[i];
			p->s_offset = 0;
			p->s_flags = 0;
			p->s_vln = 0;
			p->s_id = NULL_DADDR;
			p->s_lp = NULL;
			p->s_window = NULL;
		}
	}
	oldLI = LI;
	SO_off();
#ifdef HIGHLIGHTING
	US_effect(NO);
#endif
	cl_scr(NO);
}

void
clrline(cp1, cp2)
register char	*cp1,
		*cp2;
{
	while (cp1 < cp2)
		*cp1++ = ' ';
}


/* Output one character (if necessary) at the current position */

#ifdef MAC

/* Character output to bit-mapped screen is very expensive. It makes
   much more sense to write the entire line at once. So, we print all
   the characters, whether already there or not, once the line is
   complete. */

private unsigned char sput_buf[255];
private size_t sput_len = 0;

private void
sput_start()
{
/*	if (i_line != CapLine || i_col != CapCol) */
		NPlacur(i_line, i_col);
	sput_len = 0;
}

private void
sput_end()
{
	if (sput_len != 0) {
		writetext(sput_buf, sput_len);
		sput_len = 0;
	}
}

private void
sputc(c)
register char c;
{
	/* if line gets too long for sput_buf, ignore subsequent chars */
	if (sput_len < sizeof(sput_buf)) {
		*cursor++ = c;
		sput_buf[sput_len++] = (c == '0')? 0xAF /* slashed zero */ : c;
		CapCol++;
		i_col++;
	}
}

#else /* !MAC */

# ifdef HIGHLIGHTING
#  define	CharChanged(c)	(*cursor != (char) (c))
# else /* !HIGHLIGHTING */
private bool	ChangeEffect = NO;
#  define	CharChanged(c)	(ChangeEffect || *cursor != (char) (c))
# endif /* !HIGHLIGHTING */

# ifdef IBMPCDOS
/* On PC, we think that trying to avoid painting the character
 * is slower than just doing it.  I wonder if this is true.
 */
#  define	sputc(c)	do_sputc(c)
# else /* !IBMPCDOS */
#  define sputc(c)	{ \
	if (CharChanged(c)) { \
		do_sputc(c); \
	} else { \
		cursor += 1; \
		i_col += 1; \
	} \
}
# endif /* !IBMPCDOS */

private void
do_sputc(c)
register char	c;
{
	if (CharChanged(c)) {
# ifdef ID_CHAR
		INSmode(NO);
# endif
		if (i_line != CapLine || i_col != CapCol)
			Placur(i_line, i_col);
		*cursor++ = c;
# ifdef TERMCAP
		if (UL && c == '_' && *cursor != ' ')
			putstr(" \b");		/* Erase so '_' looks right. */
# endif
		scr_putchar(c);
		AbortCnt -= 1;
		CapCol += 1;
	} else {
		cursor += 1;
	}
	i_col += 1;
}
#endif /* !MAC */

#ifdef HIGHLIGHTING

private void	(*real_effect) ptrproto((bool));

private void
do_hlsputc(hl, oldhl, c)
register const struct LErange *hl;	/* desired highlighting */
register const struct LErange *oldhl;	/* previous highlighting */
char c;
{
	/* assert: hl != NULL && oldhl != NULL
	 * In other words, hl and oldhl must point to real LErange structs.
	 */

	/* The following two initializing expressions use the peculiar
	 * properties of unsigneds to make an efficient range test.
	 */
	void
		(*virtual_effect) ptrproto((bool)) =
			(unsigned)i_col - hl->start < hl->width? hl->high : hl->norm,
		(*underlying_effect) ptrproto((bool)) =
			(unsigned)i_col - oldhl->start < oldhl->width? oldhl->high : oldhl->norm;

	if (*cursor != c || virtual_effect != underlying_effect) {
# ifdef ID_CHAR
		INSmode(NO);
# endif
		if (i_line != CapLine || i_col != CapCol)
			Placur(i_line, i_col);
		if (virtual_effect != real_effect) {
			if (real_effect != NULL)
				real_effect(NO);
			/* instantaneously in neutral state */
			if (virtual_effect != NULL)
				virtual_effect(YES);
			real_effect = virtual_effect;
		}
# ifdef TERMCAP
		if (UL && c == '_' && *cursor != ' ')
			putstr(" \b");		/* Erase so '_' looks right. */
# endif
		*cursor++ = c;
		scr_putchar(c);
		AbortCnt -= 1;
		CapCol += 1;
	} else {
		cursor += 1;
	}
	i_col += 1;
}

#endif /* HIGHLIGHTING */

void
cl_eol()
{
	if (cursor == Curline->s_line)
		LEclear(Curline);	/* in case swrite was not called (hack!) */

	if (cursor < Curline->s_roof) {
#ifdef TERMCAP
		if (CE) {
			Placur(i_line, i_col);
			putpad(CE, 1);
			clrline(cursor, Curline->s_roof);
		} else {
			/* Ugh.  The slow way for dumb terminals. */
			register char *savecp = cursor;

			while (cursor < Curline->s_roof)
				sputc(' ');
			cursor = savecp;
		}
#else /* !TERMCAP */
		Placur(i_line, i_col);
		clr_eoln();	/* MAC and PCSCR define this */
		clrline(cursor, Curline->s_roof);
#endif /* !TERMCAP */
		Curline->s_roof = cursor;
	}
}

void
cl_scr(doit)
bool doit;
{
	register int	i;
	register struct screenline	*sp = Screen;

	for (i = 0; i < LI; i++, sp++) {
		LEclear(sp);
		clrline(sp->s_line, sp->s_roof);
		sp->s_roof = sp->s_line;
		PhysScreen[i].s_id = NULL_DADDR;
	}
	if (doit) {
		clr_page();
		CapCol = CapLine = 0;
		UpdMesg = YES;
	}
}

/* routines to manage a pool of LErange structs */

#ifdef HIGHLIGHTING

union LEspace {
	struct LErange	le;
	union LEspace	*next;
};

private union LEspace *LEfreeHead = NULL;

private struct LErange *
LEnew()
{
	struct LErange	*ret;

	if (LEfreeHead == NULL) {
		LEfreeHead = (union LEspace *) emalloc(sizeof(union LEspace));
		LEfreeHead->next = NULL;
	}
	ret = &LEfreeHead->le;
	LEfreeHead = LEfreeHead->next;
	return ret;
}

#endif /* HIGHLIGHTING */

private void
LEclear(sl)
struct screenline *sl;
{
#ifdef HIGHLIGHTING
	if (sl->s_effects != NOEFFECT) {
		((union LEspace *) sl->s_effects)->next = LEfreeHead;
		LEfreeHead = (union LEspace *) sl->s_effects;
	}
#endif /* HIGHLIGHTING */
	sl->s_effects = NOEFFECT;
}

/* Write `line' at the current position of `cursor'.  Stop when we
 * reach the end of the screen.  Aborts if there is a character
 * waiting.
 *
 * Note: All callers must have "DeTabed" "line", or processed
 * it equivalently -- it is presumed that line contains only
 * displayable characters.
 */

bool
swrite(line, hl, abortable)
register char	*line;
LineEffects	hl;
bool	abortable;
{
	register int	n = cursend - cursor;
	bool	aborted = NO;
	/* Unfortunately, neither of our LineEffects representation
	 * is suitable for representing the state of a partially
	 * updated line.  Consequently, this routine unconditionally
	 * replaces the old hl with the new.  To ensure that the new
	 * hl is correct, we compute MinCol to indicate how far in
	 * the line we must get, and will not abort until we have
	 * reached at least that column.
	 *
	 * This is unacceptably ugly.  We really must switch to a better
	 * representation
	 */
	int	MinCol = 0;
#ifdef HIGHLIGHTING
	/* If either the old line or the new line has effects,
	 * we know that some effects processing is necessary.
	 * If so, we ensure that the old line has an effect
	 * by adding a no-op effect if necessary: this is needed
	 * to ensure Placur does not get into trouble.  (UGLY!)
	 */
	struct LErange	*oldhl = Curline->s_effects;
	static const struct LErange	nohl = { 0, 0, NULL, NULL };

	if (oldhl != NOEFFECT) {
		int	w = Curline->s_roof - Curline->s_line;

		if (oldhl->norm != NULL)
			MinCol = w;
		if (oldhl->high != NULL && w > (int)oldhl->start)
			MinCol = max(MinCol, min(w, (int) (oldhl->start + oldhl->width)));
	}
	/* If either the old line or the new line has effects,
	 * we know that some effects processing is necessary.
	 * If so, we ensure that the old line has an effect
	 * by adding a no-op effect if necessary: this is needed
	 * to ensure Placur does not get into trouble.  (UGLY!)
	 */
	if (hl != NOEFFECT) {
		if (hl->high != NULL)
			MinCol = max(MinCol, (int) (hl->start + hl->width));
		if (oldhl == NOEFFECT) {
			oldhl = Curline->s_effects = LEnew();	/* keep Placur on-track */
			*oldhl = nohl;
		}
	}
	real_effect = NULL;
#else /* !HIGHLIGHTING */
	if (Curline->s_effects != hl)
		MinCol = Curline->s_roof - Curline->s_line;	/* must obliterate old */
#endif /* !HIGHLIGHTING */

	if (n > 0) {
		register ZXchar	c;
		int	col = i_col;

#ifdef HIGHLIGHTING
		/* nnhl: non-NULL version of hl (possibly
		 * a no-op) to reduce the cases handled.
		 */
		const struct LErange	*nnhl = hl == NOEFFECT? &nohl : hl;
#		define	spit(c)	{ if (oldhl != NULL) do_hlsputc(nnhl,oldhl,c); else sputc(c); }

#else /* !HIGHLIGHTING */

#		define	spit(c)	sputc(c)

# ifdef MAC
		sput_start();	/* Okay, because no interruption possible */
# else /* !MAC */
		if (hl != Curline->s_effects)
			ChangeEffect = YES;
# endif /* !MAC */

		if (hl != NOEFFECT)
			SO_effect(YES);
#endif /* !HIGHLIGHTING */

		while ((c = ZXC(*line++)) != '\0') {
			if (abortable && i_col >= MinCol && AbortCnt < 0) {
				AbortCnt = ScrBufSize;
				if (PreEmptOutput()) {
					aborted = YES;
					break;
				}
			}
#ifdef TERMCAP
			if (Hazeltine && c == '~')
				c = '`';
#endif
#ifdef CODEPAGE437
			/* ??? Some archane mapping of IBM PC characters.
			 * According to the appendix of the Microsoft MSDOS
			 * Operating System 5.0 User's Guide and Reference,
			 * in Code Page 437 (USA English) ' ', 0x00, and 0xFF are
			 * blank and 0x01 is a face.
			 */
			if (c == 0xFF)
				c = 1;
			else if (c == ' ' && hl != NOEFFECT)
				c = 0xFF;
#endif /* CODEPAGE437 */
			if (--n <= 0) {
				/* We've got one more column -- how will we spend it?
				 * ??? This is probably redundant -- callers do truncation.
				 */
				if (*line != '\0')
					c = '!';
				spit(c);
				break;
			}
			spit(c);
			col += 1;
		}
#ifdef HIGHLIGHTING
		if (real_effect != NULL)
			real_effect(NO);
#else /* !HIGHLIGHTING */
# ifdef MAC
		sput_end();	/* flush before reverting SO */
# else /* !MAC */
		ChangeEffect = NO;
# endif /* !MAC */
		if (hl != NOEFFECT)
			SO_off();
#endif /* !HIGHLIGHTING */
		if (cursor > Curline->s_roof)
			Curline->s_roof = cursor;
#		undef	spit
	}
#ifdef HIGHLIGHTING
	if (hl == NOEFFECT)
		LEclear(Curline);
	else
		*(Curline->s_effects) = *hl;
#else /* !HIGHLIGHTING */
	Curline->s_effects = hl;
#endif /* !HIGHLIGHTING */
	return !aborted;
}

void
i_set(nline, ncol)
register int	nline,
		ncol;
{
	Curline = &Screen[nline];
	cursor = Curline->s_line + ncol;
	cursend = &Curline->s_line[CO - 1];
	i_line = nline;
	i_col = ncol;
}

void
SO_off()
{
	SO_effect(NO);
}

#ifdef TERMCAP

void
SO_effect(on)
bool	on;
{
	/* If there are magic cookies, then WHERE the SO string is
	   printed decides where the SO actually starts on the screen.
	   So it's important to make sure the cursor is positioned there
	   anyway.  I think this is right. */
	if (SG != 0) {
		Placur(i_line, i_col);
		i_col += SG;
		CapCol += SG;
		cursor += SG;
	}
	putpad(on? SO : SE, 1);
}

# ifdef HIGHLIGHTING
void
US_effect(on)
bool	on;
{
	if (UG == 0)	/* not used if magic cookies */
		putpad(on? US : UE, 1);
}
# endif /* HIGHLIGHTING */

#endif /* TERMCAP */

/* Insert `num' lines at top, but leave all the lines BELOW `bottom'
   alone (at least they won't look any different when we are done).
   This changes the screen array AND does the physical changes. */

void
v_ins_line(num, top, bottom)
int num,
    top,
    bottom;
{
	register int	i;

	/* assert(num <= bottom-top+1) */

	/* Blank and save the screen pointers that will fall off the end. */

	for(i = 0; i < num; i++) {
		struct screenline	*sp = &Screen[bottom - i];

		clrline(sp->s_line, sp->s_roof);
		sp->s_roof = sp->s_line;
		LEclear(sp);
		Savelines[i] = *sp;
	}

	/* Num number of bottom lines will be lost.
	   Copy everything down num number of times. */

	for (i = bottom-num; i >= top; i--)
		Screen[i + num] = Screen[i];

	/* Insert the now-blank saved ones at the top. */

	for (i = 0; i < num; i++)
		Screen[top + i] = Savelines[i];
	i_lines(top, bottom, num);
}

/* Delete `num' lines starting at `top' leaving the lines below `bottom'
   alone.  This updates the internal image as well as the physical image.  */

void
v_del_line(num, top, bottom)
int num,
    top,
    bottom;
{
	register int	i;

	/* assert(num <= bottom-top+1) */

	/* Blank and save the lines to be deleted from the top. */

	for (i = 0; i < num; i++) {
		struct screenline	*sp = &Screen[top + i];

		clrline(sp->s_line, sp->s_roof);
		sp->s_roof = sp->s_line;
		LEclear(sp);
		Savelines[i] = *sp;
	}

	/* Copy everything up num number of lines. */

	for (i = top; i + num <= bottom; i++)
		Screen[i] = Screen[i + num];

	/* Restore the now-blank lost lines */

	for (i = 0; i < num; i++)
		Screen[bottom - i] = Savelines[i];
	d_lines(top, bottom, num);
}

#ifdef TERMCAP	/* remainder of this file */

/* The cursor optimization happens here.  You may decide that this
   is going too far with cursor optimization, or perhaps it should
   limit the amount of checking to when the output speed is slow.
   What ever turns you on ...   */

struct cursaddr {
	int	cm_numchars;
	void	(*cm_proc) ();
};

private char	*Cmstr;
private struct cursaddr	*HorMin,
			*VertMin,
			*DirectMin;

private void
	ForTab proto((int)),
	RetTab proto((int)),
	DownMotion proto((int)),
	UpMotion proto((int)),
	GoDirect proto((int, int)),
	HomeGo proto((int, int)),
	BottomUp proto((int, int));


private struct cursaddr	WarpHor[] = {
	{ 0,	ForTab },
	{ 0,	RetTab }
};

private struct cursaddr	WarpVert[] = {
	{ 0,	DownMotion },
	{ 0,	UpMotion }
};

private struct cursaddr	WarpDirect[] = {
	{ 0,	GoDirect },
	{ 0,	HomeGo },
	{ 0,	BottomUp }
};

# define FORTAB		0	/* Forward using tabs */
# define RETFORTAB	1	/* Beginning of line and then tabs */
# define NUMHOR		2

# define DOWN		0	/* Move down */
# define UPMOVE		1	/* Move up */
# define NUMVERT		2

# define DIRECT		0	/* Using CM */
# define HOME		1	/* HOME	*/
# define LOWER		2	/* Lower Line */
# define NUMDIRECT	3

# define	home()		Placur(0, 0)
# define LowLine()	{ putpad(LL, 1); CapLine = ILI; CapCol = 0; }
# define PrintHo()	{ putpad(HO, 1); CapLine = CapCol = 0; }

private void
GoDirect(line, col)
register int	line,
		col;
{
	putpad(Cmstr, 1);
	CapLine = line;
	CapCol = col;
}

private void
RetTab(col)
register int	col;
{
	scr_putchar('\r');
	CapCol = 0;
	ForTab(col);
}

private void
HomeGo(line, col)
int line,
    col;
{
	PrintHo();
	DownMotion(line);
	ForTab(col);
}

private void
BottomUp(line, col)
register int	line,
		col;
{
	LowLine();
	UpMotion(line);
	ForTab(col);
}

/* Tries to move forward using tabs (if possible).  It tabs to the
   closest tabstop which means it may go past 'destcol' and backspace
   to it.
   Note: changes to this routine must be matched by changes in ForNum. */

private void
ForTab(to)
int	to;
{
	if ((to > CapCol+1) && TABS && (phystab > 0)) {
		register int	tabgoal,
				ntabs,
				pts = phystab;

		tabgoal = to + (pts / 2);
		tabgoal -= (tabgoal % pts);

		/* Don't tab to last place or else it is likely to screw up. */
		if (tabgoal >= CO)
			tabgoal -= pts;

		ntabs = (tabgoal / pts) - (CapCol / pts);
		/* If tabbing moves past goal, and goal is more cols back
		 * than we would have had to move forward from our original
		 * position, tab is counterproductive.  Notice that if our
		 * original motion would have been backwards, tab loses too,
		 * so we need not write abs(to-CapCol).
		 */
		if (tabgoal > to && tabgoal-to >= to-CapCol)
			ntabs = 0;
		while (--ntabs >= 0) {
			scr_putchar('\t');
			CapCol = tabgoal;	/* idempotent */
		}
	}

	if (to > CapCol) {
		register char	*cp = &Screen[CapLine].s_line[CapCol];

# ifdef ID_CHAR
		INSmode(NO);	/* we're not just a motion */
# endif
		while (to > CapCol) {
			scr_putchar(*cp++);
			CapCol++;
		}
	}

	while (to < CapCol) {
		putpad(BC, 1);
		CapCol--;
	}
}

private void
DownMotion(destline)
register int	destline;
{
	register int	nlines = destline - CapLine;

	while (--nlines >= 0) {
		putpad(DO, 1);
		CapLine = destline;	/* idempotent */
	}
}

private void
UpMotion(destline)
register int	destline;
{
	register int	nchars = CapLine - destline;

	while (--nchars >= 0) {
		putpad(UP, 1);
		CapLine = destline;	/* idempotent */
	}
}

private int ForNum proto((int from, int to));

void
Placur(line, col)
int line,
    col;
{
	int	dline,		/* Number of lines to move */
		dcol;		/* Number of columns to move */
	register int	best,
			i;
	register struct cursaddr	*cp;
	int	xtracost = 0;	/* Misc addition to cost. */

# define CursMin(which,addrs,max)	{ \
	for (best = 0, cp = &(addrs)[1], i = 1; i < (max); i++, cp++) \
		if (cp->cm_numchars < (addrs)[best].cm_numchars) \
			best = i; \
	(which) = &(addrs)[best]; \
}

	if (line == CapLine && col == CapCol)
		return;		/* We are already there. */

	dline = line - CapLine;
	dcol = col - CapCol;
# ifdef ID_CHAR
	if (IN_INSmode && MI)
		xtracost = EIlen + IMlen;
	/* If we're already in insert mode, it is likely that we will
	   want to be in insert mode again, after the insert. */
# endif

	/* Number of characters to move horizontally for each case.
	   1: Try tabbing to the correct place.
	   2: Try going to the beginning of the line, and then tab. */

	if (dcol == 1 || dcol == 0) {		/* Most common case. */
		HorMin = &WarpHor[FORTAB];
		HorMin->cm_numchars = dcol + xtracost;
	} else {
		WarpHor[FORTAB].cm_numchars = xtracost + ForNum(CapCol, col);
		WarpHor[RETFORTAB].cm_numchars = xtracost + 1 + ForNum(0, col);

		/* Which is the shortest of the bunch */

		CursMin(HorMin, WarpHor, NUMHOR);
	}

	/* Moving vertically is more simple. */

	WarpVert[DOWN].cm_numchars = dline >= 0 ? dline : INFINITY;
	WarpVert[UPMOVE].cm_numchars = dline < 0 ? ((-dline) * UPlen) : INFINITY;

	/* Which of these is simpler */
	CursMin(VertMin, WarpVert, NUMVERT);

	/* Homing first and lowering first are considered
	   direct motions.
	   Homing first's total is the sum of the cost of homing
	   and the sum of tabbing (if possible) to the right. */

	if (Screen[line].s_effects != NOEFFECT && CM != NULL) {
		/* We are going to a line with inversion or underlining;
		   Don't try any clever stuff */
		DirectMin = &WarpDirect[DIRECT];
		DirectMin->cm_numchars = 0;
		Cmstr = targ2(CM, col, line);
	} else if (VertMin->cm_numchars + HorMin->cm_numchars <= 3) {
		/* Since no direct method is ever shorter than 3 chars, don't try it. */
		DirectMin = &WarpDirect[DIRECT];	/* A dummy ... */
		DirectMin->cm_numchars = INFINITY;
	} else {
		WarpDirect[DIRECT].cm_numchars = CM != NULL ?
				strlen(Cmstr = targ2(CM, col, line)) : INFINITY;
		WarpDirect[HOME].cm_numchars = HOlen + line +
				WarpHor[RETFORTAB].cm_numchars;
		WarpDirect[LOWER].cm_numchars = LLlen + ((ILI - line) * UPlen) +
				WarpHor[RETFORTAB].cm_numchars;
		CursMin(DirectMin, WarpDirect, NUMDIRECT);
	}

	if (HorMin->cm_numchars + VertMin->cm_numchars < DirectMin->cm_numchars) {
		if (line != CapLine)
			(*(void (*)ptrproto((int)))VertMin->cm_proc)(line);
		if (col != CapCol) {
# ifdef ID_CHAR
			INSmode(NO);	/* We may use real characters ... */
# endif
			(*(void (*)ptrproto((int)))HorMin->cm_proc)(col);
		}
	} else {
# ifdef ID_CHAR
		if (IN_INSmode && !MI)
			INSmode(NO);
# endif
		(*(void (*)ptrproto((int, int)))DirectMin->cm_proc)(line, col);
	}
}


/* Figures out how many characters ForTab() would use to move forward
   using tabs (if possible).
   Note: changes to this routine must be matched by changes in ForTab.
   An exception is that any cost for leaving insert mode has been
   accounted for by our caller. */

private int
ForNum(from, to)
register int	from;
int to;
{
	register int	tabgoal,
			pts = phystab;
	int		ntabs = 0;

	if ((to > from+1) && TABS && (pts > 0)) {
		tabgoal = to + (pts / 2);
		tabgoal -= (tabgoal % pts);
		if (tabgoal >= CO)
			tabgoal -= pts;
		ntabs = (tabgoal / pts) - (from / pts);
		/* If tabbing moves past goal, and goal is more cols back
		 * than we would have had to move forward from our original
		 * position, tab is counterproductive.  Notice that if our
		 * original motion would have been backwards, tab loses too,
		 * so we need not write abs(to-from).
		 */
		if (tabgoal > to && tabgoal-to >= to-from)
			ntabs = 0;
		if (ntabs != 0)
			from = tabgoal;
	}
	return ntabs + (from>to? from-to : to-from);
}

void
i_lines(top, bottom, num)
int top,
    bottom,
    num;
{
	if (CS) {
		putpad(targ2(CS, bottom, top), 1);
		CapCol = CapLine = 0;
		Placur(top, 0);
		putmulti(SR, M_SR, num, bottom - top);
		putpad(targ2(CS, ILI, 0), 1);
		CapCol = CapLine = 0;
	} else {
		Placur(bottom - num + 1, 0);
		putmulti(DL, M_DL, num, ILI - CapLine);
		Placur(top, 0);
		putmulti(AL, M_AL, num, ILI - CapLine);
	}
}

void
d_lines(top, bottom, num)
int top,
    bottom,
    num;
{
	if (CS) {
		putpad(targ2(CS, bottom, top), 1);
		CapCol = CapLine = 0;
		Placur(bottom, 0);
		putmulti(SF, M_SF, num, bottom - top);
		putpad(targ2(CS, ILI, 0), 1);
		CapCol = CapLine = 0;
	} else {
		Placur(top, 0);
		putmulti(DL, M_DL, num, ILI - top);
		Placur(bottom + 1 - num, 0);
		putmulti(AL, M_AL, num, ILI - CapLine);
	}
}

#endif /* TERMCAP */
