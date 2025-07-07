/*
 * Copyright 1992 Eric R. Smith. All rights reserved.
 * Redistribution is permitted only if the distribution
 * is not for profit, and only if all documentation
 * (including, in particular, the file "copying")
 * is included in the distribution in unmodified form.
 * THIS PROGRAM COMES WITH ABSOLUTELY NO WARRANTY, NOT
 * EVEN THE IMPLIED WARRANTIES OF MERCHANTIBILITY OR
 * FITNESS FOR A PARTICULAR PURPOSE. USE AT YOUR OWN
 * RISK.
 */
/*
 * VT52 emulator for a GEM text window (with type TEXTWIN)
 */

#include "xgem.h"
#include <osbind.h>
#include <stdlib.h>
#include "twdefs.h"
#include "twproto.h"

void vt52_putch();

/*
 * paint(v, c): put character 'c' at the current (x, y) coordinates
 * of window v. If insert mode is on, this involves moving all the
 * other characters one space to the left, first.
 */

static void
paint(v, c)
	TEXTWIN *v;
	int c;
{
	int i;
	int line = v->cy;

	if (v->term_flags & FINSERT) {
		for (i = v->maxx-1; i > v->cx; --i) {
			v->data[line][i] = v->data[line][i-1];
			v->cflag[line][i] = v->cflag[line][i-1] | CDIRTY;
		}
	}
	if (v->data[line][v->cx] != c) {
		v->data[line][v->cx] = c;
		v->cflag[line][v->cx] = CDIRTY | v->term_cattr;
	}
	else
		v->cflag[line][v->cx] = (CTOUCHED | v->term_cattr);
	v->dirty[line] |= SOMEDIRTY;
}

/*
 * gotoxy (v, x, y): move current cursor address of window v to (x, y)
 * verifies that (x,y) is within range
 */

static void
gotoxy(v, x, y)
	TEXTWIN *v;
	int x, y;
{
	if (x < 0) x = 0;
	else if (x >= v->maxx) x = v->maxx - 1;
	if (y < v->miny) y = v->miny;
	else if (y >= v->maxy) y = v->maxy - 1;

	v->cx = x;
	v->cy = y;
}

/*
 * clrline(v, r): clear line r of window v
 */

static void
clrline(v, r)
	TEXTWIN *v;
	int r;
{
	int i;

	for (i = v->maxx-1; i >= 0; --i) {
		v->data[r][i] = ' ';
		v->cflag[r][i] = v->term_cattr & (CBGCOL|CFGCOL);
	}
	v->dirty[r] = ALLDIRTY;
}
	
/*
 * clear(v): clear the whole window v
 */

static void
clear(v)
	TEXTWIN *v;
{
	int y;

	for (y = v->miny; y < v->maxy; y++)
		clrline(v, y);
}

/*
 * clrchar(v, x, y): clear the (x,y) position on window v
 */

static void
clrchar(v, x, y)
	TEXTWIN *v;
	int x, y;
{
	if (v->data[y][x] != ' ') {
		v->data[y][x] = ' ';
		v->cflag[y][x] = CDIRTY | (v->term_cattr & (CBGCOL|CFGCOL));
	} else {
		v->cflag[y][x] = CTOUCHED |
			(v->term_cattr & (CBGCOL|CFGCOL));
	}
	v->dirty[y] |= SOMEDIRTY;
}

/*
 * clrfrom(v, x1, y1, x2, y2): clear window v from position (x1,y1) to
 * position (x2, y2) inclusive. It is assumed that y2 >= y1.
 */

static void
clrfrom(v, x1, y1, x2, y2)
	TEXTWIN *v;
	int x1,y1,x2,y2;
{
	int i;

	for (i = x1; i < v->maxx; i++)
		clrchar(v, i, y1);
	if (y2 > y1) {
		for (i = 0; i <= x2; i++)
			clrchar(v, i, y2);
		for (i = y1+1; i < y2; i++)
			clrline(v, i);
	}
}

/*
 * delete_char(v, x, y): delete the character at position (x, y) on
 * the screen; the rest of the line is scrolled left, and a blank is
 * inserted at the end of the line.
 */

static void
delete_char(v, x, y)
	TEXTWIN *v;
	int x, y;
{
	int i;

	for (i = x; i < v->maxx-1; i++) {
		v->data[y][i] = v->data[y][i+1];
		v->cflag[y][i] = v->cflag[y][i+1] | CDIRTY;
	}
	v->data[y][v->maxx-1] = ' ';
	v->cflag[y][v->maxx-1] = CDIRTY | (v->term_cattr & (CBGCOL|CFGCOL));
	v->dirty[y] |= SOMEDIRTY;
}

/*
 * delete_line(v, r): delete line r of window v. The screen below this
 * line is scrolled up, and the bottom line is cleared.
 */

#define scroll(v) delete_line(v, 0)

static void
delete_line(v, r)
	TEXTWIN *v;
	int r;
{
	int y;
	int doscroll = (r == 0);
	UCHAR *oldline;
	short *oldflag;

	oldline = v->data[r];
	oldflag = v->cflag[r];
	for (y = r; y < v->maxy-1; y++) {
		v->data[y] = v->data[y+1];
		v->cflag[y] = v->cflag[y+1];
		v->dirty[y] = doscroll ? v->dirty[y+1] : ALLDIRTY;
	}

	v->data[y] = oldline;
	v->cflag[y] = oldflag;

/* clear the last line */
	clrline(v, v->maxy - 1);
	if (doscroll) {
		v->scrolled++;
	}
}

/*
 * insert_line(v, r): scroll all of the window from line r down,
 * and then clear line r.
 */

static void
insert_line(v, r)
	TEXTWIN *v;
	int r;
{
	int i, limit;
	UCHAR *oldline;
	short *oldflag;

	limit = v->maxy - 1;
	oldline = v->data[limit];
	oldflag = v->cflag[limit];

	for (i = limit-1; i >= r ; --i) {
	/* move line i to line i+1 */
		v->data[i+1] = v->data[i];
		v->cflag[i+1] = v->cflag[i];
		v->dirty[i+1] = ALLDIRTY;
	}

	v->cflag[r] = oldflag;
	v->data[r] = oldline;
/* clear line r */
	clrline(v, r);
}

/*
 * assorted callback functions
 */

static void
set_title(v)
	TEXTWIN *v;
{
	WINDOW *w = v->win;

	title_window(w, v->captbuf);
}

static void
set_size(v)
	TEXTWIN *v;
{
	int rows, cols;
	char *s;
	s = v->captbuf;
	while (*s && *s != ',') s++;
	if (*s) *s++ = 0;
	cols = decval(v->captbuf);
	rows = decval(s);
	if (rows == 0) rows = v->maxy;
	else if (rows < MINROWS) rows = MINROWS;
	else if (rows > MAXROWS) rows = MAXROWS;
	if (cols == 0) cols = v->maxx;
	else if (rows < MINCOLS) rows = MINCOLS;
	else if (cols > MAXCOLS) cols = MAXCOLS;
	resize_textwin(v, cols, rows, v->miny);
}

/* capture(v, c): put character c into the capture buffer
 * if c is '\r', then we're finished and we call the callback
 * function
 */

static void
capture(v, c)
	TEXTWIN *v;
	int c;
{
	int i = v->captsiz;

	if (c == '\r') c = 0;

	if (i < CAPTURESIZE || c == 0) {
		v->captbuf[i++] = c;
		v->captsiz = i;
	}
	if (c == 0) {
		v->output = vt52_putch;
		(*v->callback)(v);
	}
}

/*
 * paint a character, even if it's a graphic character
 */

static void
quote_putch(v, c)
	TEXTWIN *v;
	int c;
{
	if (c == 0) c = ' ';
	curs_off(v);
	paint(v, c);
	v->cx++;
	if (v->cx == v->maxx) {
		if (v->term_flags & FWRAP) {
			v->cx = 0;
			vt52_putch(v, '\n');
		} else {
			v->cx = v->maxx - 1;
		}
	}
	curs_on(v);
	v->output = vt52_putch;
}

static void
fgcol_putch(v, c)
	TEXTWIN *v;
	int c;
{
	v->term_cattr = (v->term_cattr & ~CFGCOL) | ((c & 0x000f) << 4);
	v->output = vt52_putch;
}

static void
bgcol_putch(v, c)
	TEXTWIN *v;
	int c;
{
	v->term_cattr = (v->term_cattr & ~CBGCOL) | (c & 0x000f);
	v->output = vt52_putch;
}

/* set special effects */
static void
seffect_putch(v, c)
	TEXTWIN *v;
	int c;
{
	v->term_cattr |= ((c & 0x1f) << 8);
	v->output = vt52_putch;
}

/* clear special effects */
static void
ceffect_putch(v, c)
	TEXTWIN *v;
	int c;
{
	v->term_cattr &= ~((c & 0x1f) << 8);
	v->output = vt52_putch;
}

/* set cursor flash time */
static void
timer_putch(v, c)
	TEXTWIN *v;
	int c;
{
	c -= ' ';
	if (c < 0) c = 0;
	v->flashperiod = v->flashtimer = c;
	v->output = vt52_putch;
}

/*
 * putesc(v, c): handle the control sequence ESC c
 */

static void
putesc(v, c)
	TEXTWIN *v;
	int c;
{
	int cx, cy;
	static void escy_putch();

	curs_off(v);

	cx = v->cx; cy = v->cy;

	switch (c) {
	case 'A':		/* cursor up */
		gotoxy(v, cx, cy-1);
		break;
	case 'B':		/* cursor down */
		gotoxy(v, cx, cy+1);
		break;
	case 'C':		/* cursor right */
		gotoxy(v, cx+1, cy);
		break;
	case 'D':		/* cursor left */
		gotoxy(v, cx-1, cy);
		break;
	case 'E':		/* clear home */
		clear(v);
		/* fall through... */
	case 'H':		/* cursor home */
		gotoxy(v, 0, v->miny);
		break;
	case 'I':		/* cursor up, insert line */
		if (cy == v->miny)
			insert_line(v, v->miny);
		else
			gotoxy(v, cx, cy-1);
		break;
	case 'J':		/* clear below cursor */
		clrfrom(v, cx, cy, v->maxx-1, v->maxy-1);
		break;
	case 'K':		/* clear remainder of line */
		clrfrom(v, cx, cy, v->maxx-1, cy);
		break;
	case 'L':		/* insert a line */
		insert_line(v, cy);
		gotoxy(v, 0, cy);
		break;
	case 'M':		/* delete line */
		delete_line(v, cy);
		gotoxy(v, 0, cy);
		break;
	case 'Q':		/* MW extension: quote next character */
		v->output = quote_putch;
		curs_on(v);
		return;
	case 'R':		/* TW extension: set window size */
		v->captsiz = 0;
		v->output = capture;
		v->callback = set_size;
		curs_on(v);
		return;
	case 'S':		/* MW extension: set title bar */
		v->captsiz = 0;
		v->output = capture;
		v->callback = set_title;
		curs_on(v);
		return;
	case 'T':		/* TW extension: send termcap string */
		output_termcap(v);
		break;
	case 'Y':
		v->output = escy_putch;
		curs_on(v);
		return;
	case 'a':		/* MW extension: delete character */
		delete_char(v, cx, cy);
		break;
	case 'b':		/* set foreground color */
		v->output = fgcol_putch;
		curs_on(v);
		return;		/* `return' to avoid resetting v->output */
	case 'c':		/* set background color */
		v->output = bgcol_putch;
		curs_on(v);
		return;
	case 'd':		/* clear to cursor position */
		clrfrom(v, 0, v->miny, cx, cy);
		break;
	case 'e':		/* enable cursor */
		v->term_flags |= FCURS;
		break;
	case 'f':		/* cursor off */
		v->term_flags &= ~FCURS;
		break;
	case 'h':		/* MW extension: enter insert mode */
		v->term_flags |= FINSERT;
		break;
	case 'i':		/* MW extension: leave insert mode */
		v->term_flags &= ~FINSERT;
		break;
	case 'j':		/* save cursor position */
		v->savex = v->cx;
		v->savey = v->cy;
		break;
	case 'k':		/* restore saved position */
		gotoxy(v, v->savex, v->savey);
		break;
	case 'l':		/* clear line */
		clrline(v, cy);
		gotoxy(v, 0, cy);
		break;
	case 'o':		/* clear from start of line to cursor */
		clrfrom(v, 0, cy, cx, cy);
		break;
	case 'p':		/* reverse video on */
		v->term_cattr |= CINVERSE;
		break;
	case 'q':		/* reverse video off */
		v->term_cattr &= ~CINVERSE;
		break;
	case 't':		/* TW extension: set cursor timer */
		v->flashtimer = v->flashperiod = 0;
		v->output = timer_putch;
		curs_on(v);
		return;
	case 'u':		/* TW extension: cursor flashing OFF */
		v->flashtimer = v->flashperiod = 0;
		break;
	case 'v':		/* wrap on */
		v->term_flags |= FWRAP;
		break;
	case 'w':
		v->term_flags &= ~FWRAP;
		break;
	case 'y':		/* TW extension: set special effects */
		v->output = seffect_putch;
		curs_on(v);
		return;
	case 'z':		/* TW extension: clear special effects */
		v->output = ceffect_putch;
		curs_on(v);
		return;
	}
	v->output = vt52_putch;
	curs_on(v);
}

/*
 * escy1_putch(v, c): for when an ESC Y + char has been seen
 */

static void
escy1_putch(v, c)
	TEXTWIN *v;
	int c;
{
	static void vt52_putch();

	curs_off(v);
	gotoxy(v, c - ' ', v->miny + v->escy1 - ' ');
	v->output = vt52_putch;
	curs_on(v);
}

/*
 * escy_putch(v, c): for when an ESC Y has been seen
 */
static void
escy_putch(v, c)
	TEXTWIN *v;
	int c;
{
	curs_off(v);
	v->escy1 = c;
	v->output = escy1_putch;
	curs_on(v);
}

/*
 * vt52_putch(v, c): put character 'c' on screen 'v'. This is the default
 * for when no escape, etc. is active
 */

void
vt52_putch(v, c)
	TEXTWIN *v;
	int c;
{
	int cx, cy;

	cx = v->cx; cy = v->cy;
	curs_off(v);

	c &= 0x00ff;

/* control characters */
	if (c < ' ') {
		switch (c) {
		case '\r':
			gotoxy(v, 0, cy);
			curs_on(v);
			return;
		case '\n':
			if (cy == v->maxy - 1) {
				curs_off(v);
				scroll(v);
			}
			else
				gotoxy(v, cx, cy+1);
			curs_on(v);
			return;
		case '\b':
			gotoxy(v, cx-1, cy);
			curs_on(v);
			return;
		case '\007':		/* BELL */
			(void)Bconout(2, 7);
			curs_on(v);
			return;
		case '\033':		/* ESC */
			v->output = putesc;
			curs_on(v);
			return;
		case '\t':
			gotoxy(v, (v->cx +8) & ~7, v->cy); 
			/* fall through */
		default:
			curs_on(v);
			return;
		}
	}

	paint(v, c);
	v->cx++;
	if (v->cx == v->maxx) {
		if (v->term_flags & FWRAP) {
			v->cx = 0;
			vt52_putch(v, '\n');
		} else {
			v->cx = v->maxx - 1;
		}
	}
	curs_on(v);
}

/* routines for setting the cursor state in window v */

void
set_curs(v, on)
	TEXTWIN *v;
	int on;
{
	if (on && (v->term_flags & FCURS) && !(v->term_flags & FFLASH)) {
		if (focuswin && v == focuswin->extra)
			v->cflag[v->cy][v->cx] ^= CINVERSE;
		else
			v->cflag[v->cy][v->cx] ^= CE_UNDERLINE;
		v->cflag[v->cy][v->cx] |= CTOUCHED;
		v->dirty[v->cy] |= SOMEDIRTY;
		v->term_flags |= FFLASH;
	} else if ( (!on) && (v->term_flags & FFLASH)) {
		if (focuswin && v == focuswin->extra)
			v->cflag[v->cy][v->cx] ^= CINVERSE;
		else
			v->cflag[v->cy][v->cx] ^= CE_UNDERLINE;
		v->cflag[v->cy][v->cx] |= CTOUCHED;
		v->dirty[v->cy] |= SOMEDIRTY;
		v->term_flags &= ~FFLASH;
	}
	v->flashtimer = v->flashperiod;
}

/* flash the cursor in the indicated window */

void
curs_flash(v)
	TEXTWIN *v;
{
	if (v->term_flags & FCURS) {
		if (focuswin && v == focuswin->extra)
			v->cflag[v->cy][v->cx] ^= CINVERSE;
		else
			v->cflag[v->cy][v->cx] ^= CE_UNDERLINE;
		v->dirty[v->cy] |= SOMEDIRTY;
		v->cflag[v->cy][v->cx] |= CTOUCHED;
		v->term_flags ^= FFLASH;
	}
	v->flashtimer = v->flashperiod;
}
