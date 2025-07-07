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
#include "xgem.h"
#include <stdlib.h>

#define CLEARED 2		/* redrawing a cleared area */

int default_height = 10;	/* default font height (points) */
int default_font = 1;		/* default font (pixels) */
int align_windows = 0;		/* align windows on byte boundaries */

/* if a font doesn't define a character, use this one instead */
#define DEFAULT_CHAR '?'

static void set_cwidths __PROTO((TEXTWIN *));

/* functions for converting x, y pixels to/from character coordinates */
/* NOTES: these functions give the upper left corner; to actually draw
 * a character, they must be adjusted down by t->cbase
 * Also: char2pixel accepts out of range character/column combinations,
 * but pixel2char never will generate such combinations.
 */
void
char2pixel(t, col, row, xp, yp)
	TEXTWIN *t;
	int col, row;
	int *xp, *yp;
{
	short *WIDE = t->cwidths;
	int x;

	*yp = t->win->wi_y - t->offy + row * t->cheight;
	if (!WIDE) {
		*xp = t->win->wi_x - t->offx + col * t->cmaxwidth;
	} else if (col >= t->maxx) {
		*xp = t->win->wi_x + t->win->wi_w;
	} else {
		x = t->win->wi_x - t->offx;
		while(--col >= 0) {
			x += WIDE[t->data[row][col]];
		}
		*xp = x;
	}
}

void
pixel2char(t, x, y, colp, rowp)
	TEXTWIN *t;
	int x, y, *colp, *rowp;
{
	int col, row, count, nextcount;
	short *WIDE = t->cwidths;

	row = (y - t->win->wi_y + t->offy) / t->cheight;
	x = x - t->win->wi_x + t->offx;

	if (WIDE == 0) {
		col = x / t->cmaxwidth;
	} else {
		count = 0;
		for (col = 0; col < t->maxx - 1; col++) {
			nextcount = count + WIDE[t->data[row][col]];
			if (count <= x && x < nextcount) break;
			count = nextcount;
		}
	}
	*rowp = row;
	*colp = col;
}

static void set_scroll_bars __PROTO((TEXTWIN *));

/*
 * draw a (part of a) line on screen, with certain attributes (e.g.
 * inverse video) indicated by "flag". (x, y) is the upper left corner
 * of the box which will contain the line.
 * If "force" is 1, we may assume that the screen is already cleared
 * (this is done in update_screen() for us).
 * SPECIAL CASE: if buf is an empty string, we clear from "x" to
 * the end of the window.
 */
static void
draw_buf(t, buf, x, y, flag, force)
	TEXTWIN *t;
	char *buf;
	int x, y, flag, force;
{
	char *s, *lastnonblank;
	int x2, fillcolor, textcolor;
	int texteffects;
	short *WIDE = t->cwidths;
	int temp[4];

	fillcolor = flag & CBGCOL;
	textcolor = (flag & CFGCOL) >> 4;
	texteffects = (flag & CEFFECTS) >> 8;

#ifdef STIPPLE_SELECT
	if (flag & CINVERSE) {	/* swap foreground and background */
		x2 = fillcolor; fillcolor = textcolor; textcolor = x2;
	}
#else
	if (flag & (CINVERSE|CSELECTED)) {	/* swap foreground and background */
		x2 = fillcolor; fillcolor = textcolor; textcolor = x2;
	}
#endif
	x2 = x;
	s = buf;
	if (*s) {
		lastnonblank = s-1;
		while (*s) {
			if (*s != ' ') lastnonblank = s;
			if (WIDE)
				x2 += WIDE[*s];
			else
				x2 += t->cmaxwidth;
			s++;
		}
		lastnonblank++;
		if (!(flag & CE_UNDERLINE))
			*lastnonblank = 0;
	} else {
		x2 = t->win->wi_x + t->win->wi_w;
	}

	set_wrmode(2);		/* transparent text */
	if (fillcolor != 0 || (force != CLEARED)) {
	/* the background may not be set correctly, so we do it here */
		temp[0] = x;
		temp[1] = y;
		temp[2] = x2 - 1;
		temp[3] = y + t->cheight - 1;
		set_fillcolor(fillcolor);
		set_fillstyle(1, 1);		/* fill the area completely */
		v_bar(vdi_handle, temp);
	}

/* skip leading blanks -- we don't need to draw them again! */
	if (!(flag & CE_UNDERLINE)) {
		while (*buf == ' ') {
			buf++;
			x += WIDE ? WIDE[' '] : t->cmaxwidth;
		}
	}

	if (*buf) {
		set_textcolor(textcolor);
		set_texteffects(texteffects);
		v_gtext(vdi_handle, x, y + t->cbase, buf);
	}

#ifdef STIPPLE_SELECT
	if (flag & CSELECTED) {		/* put in the pattern */
		set_wrmode(2);		/* 'OR' the pattern */
		set_fillstyle(2, 2);
		set_fillcolor(textcolor);
		v_bar(vdi_handle, temp);
	}
#endif
}

/*
 * update the characters on screen between "firstline,firstcol" and 
 * "lastline-1,lastcol-1" (inclusive)
 * if force == 1, the redraw must occur, otherwise it occurs only for
 * "dirty" characters. Note that we assume here that clipping
 * rectanges and wind_update() have already been set for us.
 */

static void
update_chars(t, firstcol, lastcol, firstline, lastline, force)
	TEXTWIN *t;
	int firstcol, lastcol, firstline, lastline, force;
{
#define CBUFSIZ 127
	UCHAR buf[CBUFSIZ+1], c;
	int px, py, ax, i, cnt, flag, bufwidth;
	short *WIDE = t->cwidths;
	int lineforce = 0;
	int curflag;

#define flushbuf()	\
	{    buf[i] = 0;	\
	     draw_buf(t, buf, px, py, flag, lineforce); \
	     px += bufwidth; \
	     i = bufwidth = 0; \
	}

/* make sure the font is set correctly */
	set_font(t->cfont, t->cpoints);

/* find the place to start writing */
	char2pixel(t, firstcol, firstline, &ax, &py);

/* now write the characters we need to */
	while (firstline < lastline) {
/* if no characters on the line need re-writing, skip the loop */
		if (!force && t->dirty[firstline] == 0) {
			py += t->cheight;
			firstline++;
			continue;
		}
		px = ax;
/*
 * now, go along collecting characters to write into the buffer
 * we add a character to the buffer if and only if (1) the
 * character's attributes (inverse video, etc.) match the
 * attributes of the character already in the buffer, and
 * (2) the character needs redrawing. Otherwise, if there are
 * characters in the buffer, we flush the buffer.
 */
		i = bufwidth = 0;
		cnt = firstcol;
		flag = 0;
		lineforce = force;
		if (!lineforce && (t->dirty[firstline] & ALLDIRTY))
			lineforce = 1;
		while (cnt < lastcol) {
		    c = t->data[firstline][cnt];
		    if (lineforce ||
		       (t->cflag[firstline][cnt] & (CDIRTY|CTOUCHED))) {
/* yes, this character needs drawing */
/* if the font is proportional and the character has really changed,
 * then all remaining characters will have to be redrawn, too
 */
			if (WIDE && (lineforce == 0) &&
			    (t->cflag[firstline][cnt] & CDIRTY))
				lineforce = 1;
/* watch out for characters that can't be drawn in this font */
			if (c < t->minADE || c > t->maxADE)
				c = DEFAULT_CHAR;
			curflag = t->cflag[firstline][cnt] & ~(CDIRTY|CTOUCHED);
			if (flag == curflag) {
			    buf[i++] = c;
			    bufwidth += (WIDE ? WIDE[c] : t->cmaxwidth);
			    if (i == CBUFSIZ) {
				flushbuf();
			    }
			} else {
			    if (i) {
				flushbuf();
			    }
			    flag = curflag;
			    buf[i++] = c;
			    bufwidth += (WIDE ? WIDE[c] : t->cmaxwidth);
			}
		    } else {
			if (i) {
			    flushbuf();
			}
			px += (WIDE ? WIDE[c] : t->cmaxwidth);
		    }
		    cnt++;
		}
		if (i) {
			flushbuf();
		}
		if (WIDE) {		/* the line's 'tail' */
			draw_buf(t, "", px, py, t->cflag[firstline][t->maxx-1],
				lineforce);
		}
		py += t->cheight;
		firstline++;
	}
}

/*
 * mark_clean: mark a window as having been completely updated
 */

void
mark_clean(t)
	TEXTWIN *t;
{
	int line, col;

	for (line = 0; line < t->maxy; line++) {
		if (t->dirty[line] == 0)
			continue;
		for (col = 0; col < t->maxx; col++) {
			t->cflag[line][col] &= ~(CDIRTY|CTOUCHED);
		}
		t->dirty[line] = 0;
	}
}

/*
 * redraw all parts of window v which are contained within the
 * given rectangle. Assumes that the clipping rectange has already
 * been set correctly.
 * NOTE: more than one rectangle may cover the same area, so we
 * can't mark the window clean during the update; we have to do
 * it in a separate routine (mark_clean)
 */

static MFDB scr_mfdb;	/* left NULL so it refers to the screen by default */

static void
update_screen(t, xc, yc, wc, hc, force)
	TEXTWIN *t;
	int xc, yc, wc, hc;
	int force;
{
	int firstline, lastline, firstscroll;
	int firstcol, lastcol;
	int pxy[8];
	int scrollht = 0;

/* if t->scrolled is set, then the output routines faked the "dirty"
 * flags on the scrolled lines under the assumption that we would
 * do a blit scroll; so we do it here.
 */
	if ((force == 0) && t->scrolled &&
	    (scrollht = t->scrolled * t->cheight) < hc) {
		pxy[0] = xc;
		pxy[1] = yc + scrollht;
		pxy[2] = xc + wc - 1;
		pxy[3] = yc + hc - 1;
		pxy[4] = xc;
		pxy[5] = yc;
		pxy[6] = pxy[2];
#if 0
		pxy[7] = pxy[1]-1;
#else
		pxy[7] = pxy[3] - scrollht;
#endif
#define FM_COPY 3
#define FM_CLEAR 0
		vro_cpyfm(vdi_handle, FM_COPY, pxy, &scr_mfdb, &scr_mfdb);
	}

/* if `force' is set, clear the area to be redrawn -- it looks better */
	if (force == CLEARED) {
#ifdef WWA_TRUECOLOUR
/* In truecolour, filling raster with 0's is not equivalent to filling
 * it with colour 0 (unless colour 0 is black - but usually it's white!).
 */
		set_fillcolor(0);
		set_fillstyle(1, 1);
		pxy[0] = xc;
		pxy[1] = yc;
		pxy[2] = xc + wc - 1;
		pxy[3] = yc + hc - 1;
		vr_recfl(vdi_handle, pxy);
#else
		pxy[4] = pxy[0] = xc;
		pxy[5] = pxy[1] = yc;
		pxy[6] = pxy[2] = xc + wc - 1;
		pxy[7] = pxy[3] = yc + hc - 1;
		vro_cpyfm(vdi_handle, FM_CLEAR, pxy, &scr_mfdb, &scr_mfdb);
#endif
	}

/* convert from on-screen coordinates to window rows & columns */
	pixel2char(t, xc, yc, &firstcol, &firstline);

	if (firstline < 0) firstline = 0;
	else if (firstline >= t->maxy) firstline = t->maxy - 1;

	lastline = 1 + firstline + (hc + t->cheight - 1) / t->cheight;
	if (lastline > t->maxy) lastline = t->maxy;

/* kludge for proportional fonts */
	if (t->cwidths) {
		firstcol = 0;
		lastcol = t->maxx;
	} else {
		pixel2char(t, xc+wc+t->cmaxwidth-1, yc, &lastcol, &firstline);
	}

/* if t->scrolled is set, the last few lines *must* be updated */
	if (t->scrolled && force == 0) {
		firstscroll = firstline + (hc - scrollht)/t->cheight;
		if (firstscroll <= firstline) {
		    force = TRUE;
		} else {
		    update_chars(t, firstcol, lastcol, firstscroll, lastline, TRUE);
		    lastline = firstscroll;
		}
	}
	update_chars(t, firstcol, lastcol, firstline, lastline, force);
}

/*
 * redraw all parts of a window that need redrawing; this is called
 * after, for example, writing some text into the window
 */

void
refresh_textwin(t)
	TEXTWIN *t;
{
	WINDOW *v = t->win;
	GRECT	t1, t2;

	if (v->wi_handle < 0) return;	/* window not visible */
	wind_update(TRUE);
	hide_mouse();
	t2.g_x = t->win->wi_x;
	t2.g_y = t->win->wi_y;
	t2.g_w = t->win->wi_w;
	t2.g_h = t->win->wi_h;
	wind_get(v->wi_handle, WF_FIRSTXYWH,
		 &t1.g_x, &t1.g_y, &t1.g_w, &t1.g_h);

	while (t1.g_w && t1.g_h) {
		if (rc_intersect(&t2, &t1)) {
			set_clip(t1.g_x, t1.g_y, t1.g_w, t1.g_h);
			update_screen(t, t1.g_x, t1.g_y, t1.g_w, t1.g_h, FALSE);
	  	}
		wind_get(v->wi_handle, WF_NEXTXYWH, &t1.g_x, &t1.g_y,
			 &t1.g_w, &t1.g_h);
	}
	t->scrolled = t->nbytes = t->draw_time = 0;
	show_mouse();
	mark_clean(t);
	wind_update(FALSE);
}

/*
 * Methods for reacting to user events
 */


/* draw part of a window */

static void
draw_textwin(v, x, y, w, h)
	WINDOW *v;
	int x, y, w, h;
{
	TEXTWIN *t = v->extra;

	t->scrolled = 0;
	update_screen(v->extra, x, y, w, h, CLEARED);
	t->nbytes = t->draw_time = 0;
}

/* close a window (called when the closed box is clicked on) */

static void
close_textwin(v)
	WINDOW *v;
{
	void destroy_textwin();

	destroy_textwin(v->extra);
}

/* resize a window to its "full" size */

static void
full_textwin(v)
	WINDOW *v;
{
	int newx, newy, neww, newh;

	if (v->flags & WFULLED) {
		wind_get(v->wi_handle, WF_PREVXYWH, &newx, &newy, &neww,
			 &newh);
	} else {
		wind_get(v->wi_handle, WF_FULLXYWH, &newx, &newy, &neww,
			&newh);
	}

	wind_calc(WC_WORK, v->wi_kind, newx, newy, neww, newh,
		  &v->wi_x, &v->wi_y, &v->wi_w, &v->wi_h);
	if (align_windows && (v->wi_x & 7)) {
		v->wi_x &= ~7;
		wind_calc(WC_BORDER, v->wi_kind, v->wi_x, v->wi_y, v->wi_w,
			v->wi_h, &newx, &newy, &neww, &newh);
	}
	wind_set(v->wi_handle, WF_CURRXYWH, newx, newy, neww, newh);
	v->flags ^= WFULLED;
	set_scroll_bars(v->extra);
}

/* resize a window */

static void redo __PROTO(( TEXTWIN * ));

static void
move_textwin(v, x, y, w, h)
	WINDOW *v;
	int x, y, w, h;
{
	int fullx, fully, fullw, fullh;

	wind_get(v->wi_handle, WF_FULLXYWH, &fullx, &fully, &fullw, &fullh);

	if (w > fullw) w = fullw;
	if (h > fullh) h = fullh;
	wind_calc(WC_WORK, v->wi_kind, x, y, w, h, &v->wi_x,
		&v->wi_y, &v->wi_w, &v->wi_h);
	if (align_windows) {
		v->wi_x &= ~7;
		wind_calc(WC_BORDER, v->wi_kind, v->wi_x, v->wi_y, v->wi_w, v->wi_h,
			&x, &y, &w, &h);
	}
	wind_set(v->wi_handle, WF_CURRXYWH, x, y, w, h);
	if (w != fullw || h != fullh)
		v->flags &= ~WFULLED;
}

static void
size_textwin(v, x, y, w, h)
	WINDOW *v;
	int x, y, w, h;
{
	TEXTWIN *t = v->extra;

	(*v->moved)(v, x, y, w, h);
	set_scroll_bars(t);
}

/*
 * handle an arrow event to a window
 */

static void
newxoff(t, x)
	TEXTWIN *t;
	int x;
{
	t->offx = x;
	set_scroll_bars(t);
}

static void
newyoff(t, y)
	TEXTWIN *t;
	int y;
{
	t->offy = y;
	set_scroll_bars(t);
}

/*
 * redisplay a text window in its entirety, but without pre-clearing
 * areas: this looks better when arrowing and paging
 */

static void
redo(t)
	TEXTWIN *t;
{
	WINDOW *v;
	int xc, yc, wc, hc;
	GRECT	t1, t2;

	v = t->win;
	xc = v->wi_x; yc = v->wi_y; wc = v->wi_w; hc = v->wi_h;

	wind_update(TRUE);
	hide_mouse();
	t2.g_x = xc;
	t2.g_y = yc;
	t2.g_w = wc;
	t2.g_h = hc;
	wind_get(v->wi_handle, WF_FIRSTXYWH,
		 &t1.g_x, &t1.g_y, &t1.g_w, &t1.g_h);

	while (t1.g_w && t1.g_h) {
		if (rc_intersect(&t2, &t1)) {
			set_clip(t1.g_x, t1.g_y, t1.g_w, t1.g_h);
			update_screen(t, t1.g_x, t1.g_y, t1.g_w, t1.g_h, TRUE);
	  	}
		wind_get(v->wi_handle, WF_NEXTXYWH, &t1.g_x, &t1.g_y,
			 &t1.g_w, &t1.g_h);
	}
	t->scrolled = t->nbytes = t->draw_time = 0;
	show_mouse();
	mark_clean(t);
	wind_update(FALSE);
}

#define UP 0
#define DOWN 1

#define scrollup(t, off) scrollupdn(t, off, UP)
#define scrolldn(t, off) scrollupdn(t, off, DOWN)

static void
scrollupdn(t, off, direction)
	TEXTWIN *t;
	int off;
	int direction;
{
	WINDOW *v;
	int xc, yc, wc, hc;
	GRECT	t1, t2;
	int pxy[8];

	v = t->win;
	xc = v->wi_x; yc = v->wi_y; wc = v->wi_w; hc = v->wi_h;

	if (off <= 0) {
		return;
	}

	wind_update(TRUE);
	hide_mouse();
	t2.g_x = xc;
	t2.g_y = yc;
	t2.g_w = wc;
	t2.g_h = hc;
	wind_get(v->wi_handle, WF_FIRSTXYWH,
		 &t1.g_x, &t1.g_y, &t1.g_w, &t1.g_h);

	while (t1.g_w && t1.g_h) {
		if (rc_intersect(&t2, &t1)) {
			set_clip(t1.g_x, t1.g_y, t1.g_w, t1.g_h);
			if (off >= t1.g_h) {
				update_screen(t, t1.g_x, t1.g_y, t1.g_w, t1.g_h, TRUE);
			} else {
				if (direction  == UP) {
					pxy[0] = t1.g_x;	/* "from" address */
					pxy[1] = t1.g_y + off;
					pxy[2] = t1.g_x + t1.g_w - 1;
					pxy[3] = t1.g_y + t1.g_h - 1;
					pxy[4] = t1.g_x;	/* "to" address */
					pxy[5] = t1.g_y;
					pxy[6] = t1.g_x + t1.g_w - 1;
					pxy[7] = t1.g_y + t1.g_h - off - 1;
				} else {
					pxy[0] = t1.g_x;
					pxy[1] = t1.g_y;
					pxy[2] = t1.g_x + t1.g_w - 1;
					pxy[3] = t1.g_y + t1.g_h - off - 1;
					pxy[4] = t1.g_x;
					pxy[5] = t1.g_y + off;
					pxy[6] = t1.g_x + t1.g_w - 1;
					pxy[7] = t1.g_y + t1.g_h - 1;
				}
				vro_cpyfm(vdi_handle, FM_COPY, pxy, &scr_mfdb, &scr_mfdb);
				if (direction == UP)
					update_screen(t, t1.g_x, pxy[7], t1.g_w, off, TRUE);
				else
					update_screen(t, t1.g_x, t1.g_y, t1.g_w, off, TRUE);
			}
	  	}
		wind_get(v->wi_handle, WF_NEXTXYWH, &t1.g_x, &t1.g_y,
			 &t1.g_w, &t1.g_h);
	}
	show_mouse();
	wind_update(FALSE);
}

#define LEFT 0
#define RIGHT 1

#define scrolllf(t, off) scrollleftright(t, off, LEFT)
#define scrollrt(t, off) scrollleftright(t, off, RIGHT)

static void
scrollleftright(t, off, direction)
	TEXTWIN *t;
	int off;
	int direction;
{
	WINDOW *v;
	int xc, yc, wc, hc;
	GRECT	t1, t2;
	int pxy[8];

	v = t->win;
	xc = v->wi_x; yc = v->wi_y; wc = v->wi_w; hc = v->wi_h;

	if (off <= 0) {
		return;
	}

	wind_update(TRUE);
	hide_mouse();
	t2.g_x = xc;
	t2.g_y = yc;
	t2.g_w = wc;
	t2.g_h = hc;
	wind_get(v->wi_handle, WF_FIRSTXYWH,
		 &t1.g_x, &t1.g_y, &t1.g_w, &t1.g_h);

	while (t1.g_w && t1.g_h) {
		if (rc_intersect(&t2, &t1)) {
			set_clip(t1.g_x, t1.g_y, t1.g_w, t1.g_h);
			if (off >= t1.g_w) {
				update_screen(t, t1.g_x, t1.g_y, t1.g_w, t1.g_h, TRUE);
			} else {
				if (direction == LEFT) {
					pxy[0] = t1.g_x + off;	/* "from" address */
					pxy[1] = t1.g_y;
					pxy[2] = t1.g_x + t1.g_w - 1;
					pxy[3] = t1.g_y + t1.g_h - 1;
					pxy[4] = t1.g_x;	/* "to" address */
					pxy[5] = t1.g_y;
					pxy[6] = t1.g_x + t1.g_w - off - 1;
					pxy[7] = t1.g_y + t1.g_h - 1;
				} else {
					pxy[0] = t1.g_x;
					pxy[1] = t1.g_y;
					pxy[2] = t1.g_x + t1.g_w - off - 1;
					pxy[3] = t1.g_y + t1.g_h;
					pxy[4] = t1.g_x + off;
					pxy[5] = t1.g_y;
					pxy[6] = t1.g_x + t1.g_w - 1;
					pxy[7] = t1.g_y + t1.g_h - 1;
				}
				vro_cpyfm(vdi_handle, FM_COPY, pxy, &scr_mfdb, &scr_mfdb);
				if (direction == LEFT)
					update_screen(t, pxy[6], t1.g_y, off, t1.g_h, TRUE);
				else
					update_screen(t, t1.g_x, t1.g_y, off, t1.g_h, TRUE);
			}
	  	}
		wind_get(v->wi_handle, WF_NEXTXYWH, &t1.g_x, &t1.g_y,
			 &t1.g_w, &t1.g_h);
	}
	show_mouse();
	wind_update(FALSE);
}

static void
arrow_textwin(v, msg)
	WINDOW *v;
	int msg;
{
	TEXTWIN *t = (TEXTWIN *)v->extra;
	int oldoff;

	refresh_textwin(t);

	switch(msg) {
	case WA_UPPAGE:
		newyoff(t, t->offy - v->wi_h);
		break;
	case WA_DNPAGE:
		newyoff(t, t->offy + v->wi_h);
		break;
	case WA_UPLINE:
		oldoff = t->offy;
		newyoff(t, t->offy - t->cheight);
		scrolldn(t, oldoff - t->offy);
		return;
	case WA_DNLINE:
		oldoff = t->offy;
		newyoff(t, t->offy + t->cheight);
		scrollup(t, t->offy - oldoff);
		return;
	case WA_LFPAGE:
		newxoff(t, t->offx - v->wi_w);
		break;
	case WA_RTPAGE:
		newxoff(t, t->offx + v->wi_w);
		break;
	case WA_LFLINE:
		oldoff = t->offx;
		newxoff(t, t->offx - t->cmaxwidth);
		scrollrt(t, oldoff - t->offx);
		return;
	case WA_RTLINE:
		oldoff = t->offx;
		newxoff(t, t->offx + t->cmaxwidth);
		scrolllf(t, t->offx - oldoff);
		return;
	}
	redo(t);
}

/*
 * handle horizontal and vertical slider events for a window
 */

static void
hslid_textwin(v, hpos)
	WINDOW *v;
	int hpos;
{
	TEXTWIN *t = (TEXTWIN *)v->extra;
	long width;
	int oldoff;

	width = t->cmaxwidth * t->maxx - v->wi_w;
	oldoff = t->offx;
	newxoff(t, (int)( (hpos * width) / 1000 ));
	oldoff -= t->offx;
	if (oldoff < 0)
		scrolllf(t, -oldoff);
	else
		scrollrt(t, oldoff);
}

static void
vslid_textwin(v, vpos)
	WINDOW *v;
	int vpos;
{
	TEXTWIN *t = (TEXTWIN *)v->extra;
	long height;
	int oldoff;

	height = t->cheight * t->maxy - v->wi_h;
	oldoff = t->offy;
	newyoff(t, (int)( (vpos * height) / 1000));
	oldoff -= t->offy;
	if (oldoff < 0)
		scrollup(t, -oldoff);
	else
		scrolldn(t, oldoff);
}

/*
 * correctly set up the horizontal and vertical scroll bars for TEXTWIN
 * t
 */

static void
set_scroll_bars(t)
	TEXTWIN *t;
{
	WINDOW *v = t->win;
	int hsize, vsize;
	int hpos, vpos;
	long width, height;

	width = t->cmaxwidth * t->maxx;
	height = t->cheight * t->maxy;

/* see if the new offset is too big for the window */
	if (t->offx + v->wi_w > width) {
		t->offx  = width - v->wi_w;
	}
	if (t->offx < 0) t->offx = 0;

	if (t->offy + v->wi_h > height) {
		t->offy = height - v->wi_h;
	}
	if (t->offy < 0) t->offy = 0;

	hsize = 1000L * v->wi_w / width;
	if (hsize > 1000) hsize = 1000;
	else if (hsize < 1) hsize = 1;

	vsize = 1000L * v->wi_h / height;
	if (vsize > 1000) vsize = 1000;
	else if (vsize < 1) vsize = 1;

	if (width > v->wi_w)
		hpos = 1000L * t->offx / (width - v->wi_w);
	else
		hpos = 1;

	if (height > v->wi_h)
		vpos = 1000L * t->offy / (height - v->wi_h);
	else
		vpos = 1;

	if (hpos < 1) hpos = 1;
	else if (hpos > 1000) hpos = 1000;

	if (vpos < 1) vpos = 1;
	else if (vpos > 1000) vpos = 1000;

	if (v->wi_kind & HSLIDE) {
		wind_set(v->wi_handle, WF_HSLIDE, hpos, 0, 0, 0);
		wind_set(v->wi_handle, WF_HSLSIZE, hsize, 0, 0, 0);
	}
	if (v->wi_kind & VSLIDE) {
		wind_set(v->wi_handle, WF_VSLIDE, vpos, 0, 0, 0);
		wind_set(v->wi_handle, WF_VSLSIZE, vsize, 0, 0, 0);
	}
}

static void
output_textwin(t, c)
	TEXTWIN *t;
	int c;
{
	c &= 0x00ff;
	if (!c) return;

	if (c == '\r') {
		t->cx = 0; return;
	}
	if (c == '\n') {
		t->cx = 0;
		if (t->cy < t->maxy - 1)
			t->cy++;
		return;
	}
	t->data[t->cy][t->cx] = c;
	t->cflag[t->cy][t->cx] = CDIRTY | ((c>='A' && c<='Z') ? CINVERSE : 0)
					| COLORS(1, 0);

	t->dirty[t->cy] |= SOMEDIRTY;
	t->cx++;
	if (t->cx >= t->maxx) {
		if (t->term_flags & FWRAP) {
			t->cx = 0;
			t->cy++;
			if (t->cy >= t->maxy)
				t->cy = t->maxy - 1;
		} else {
			t->cx = t->maxx - 1;
		}
	}
	refresh_textwin(t);
}

/*
 * Create a new text window with title t, w columns, and h rows,
 * and place it at x, y on the screen; the new window should have the
 * set of gadgets specified by "kind", and should provide "s"
 * lines of scrollback.
 */

TEXTWIN *
create_textwin(title, x, y, w, h, s, kind)
	char *title;
	int x, y, w, h, s, kind;
{
	WINDOW *v;
	TEXTWIN *t;
	int firstchar, lastchar, distances[5], maxwidth, effects[3];
	int width, height;
	extern int default_height;	/* in main.c */
	int i, j;

	extern void normal_putch();

	t = malloc(sizeof(TEXTWIN));
	if (!t) return t;

	t->maxx = w;
	t->maxy = h+s;
	t->miny = s;
	t->cx = 0;
	t->cy = t->miny;

/* we get font data from the VDI */
	set_font(default_font, default_height);
	vqt_fontinfo(vdi_handle, &firstchar, &lastchar, distances, &maxwidth,
		     effects);
	t->cfont = default_font;
	t->cpoints = default_height;
	t->cmaxwidth = maxwidth;
	t->cheight = distances[0]+distances[4]+1;
	t->cbase = distances[4];
	t->minADE = firstchar;
	t->maxADE = lastchar;
	t->cwidths = 0;
	set_cwidths(t);

/* initialize the window data */
	t->data = malloc(sizeof(char *) * t->maxy);
	t->cflag = malloc(sizeof(short *) * t->maxy);
	t->dirty = malloc((size_t)t->maxy);

	if (!t->dirty || !t->cflag || !t->data) return 0;

	for (i = 0; i < t->maxy; i++) {
		t->dirty[i] = 0; /* the window starts off clear */
		t->data[i] = malloc((size_t)t->maxx+1);
		t->cflag[i] = malloc(sizeof(short) * (size_t)(t->maxx+1));
		if (!t->cflag[i] || !t->data[i]) return 0;
		for (j = 0; j < t->maxx; j++) {
			t->data[i][j] = ' ';
			t->cflag[i][j] = COLORS(1, 0);
		}
	}

	t->scrolled = t->nbytes = t->draw_time = 0;

/* calculate max. window size, and initialize the WINDOW struct */
	width = t->maxx * t->cmaxwidth;
	height = h * t->cheight;
	v = create_window(title, kind, x, y, width, height);
	if (!v) {
		free(t);
		return 0;
	}

	v->extra = t;
	v->wtype = TEXT_WIN;
	t->win = v;

/* initialize all the methods for v */
	v->draw = draw_textwin;
	v->closed = close_textwin;
	v->fulled = full_textwin;
	v->moved = move_textwin;
	v->sized = size_textwin;
	v->arrowed = arrow_textwin;
	v->hslid = hslid_textwin;
	v->vslid = vslid_textwin;

	t->offx = 0;
	t->offy = s * t->cheight;

	t->output = output_textwin;
	t->term_cattr = COLORS(1, 0);
	t->term_flags = FWRAP;
	t->fd = t->pgrp = 0;

	t->prog = t->cmdlin = t->progdir = 0;
	t->flashtimer = t->flashperiod = 0;
	return t;
}

/*
 * destroy a text window
 */

#include <osbind.h>
#include <mintbind.h>
#include <signal.h>

void
destroy_textwin(t)
	TEXTWIN *t;
{
	int i;

	destroy_window(t->win);
	for (i = 0; i < t->maxy; i++) {
		free(t->data[i]);
		free(t->cflag[i]);
	}
	if (t->prog) free(t->prog);
	if (t->cmdlin) free(t->cmdlin);
	if (t->progdir) free(t->progdir);

	free(t->cflag);
	free(t->data);
	free(t->dirty);
	if (t->cwidths) free(t->cwidths);
	free(t);

	if (t->fd > 0)
		(void)Fclose(t->fd);
	if (t->pgrp > 0)
		(void)Pkill(-t->pgrp, SIGHUP);
}

/*
 * reset a window's font: this involves resizing the window, too
 */

void
textwin_setfont(t, font, points)
	TEXTWIN *t;
	int font;
	int points;
{
	extern int win_flourishes;	/* in window.c */
	WINDOW *w;
	int firstchar, lastchar, distances[5], maxwidth, effects[3];
	int width, height;
	int dummy;
	int oldflourishes = win_flourishes;
	int reopen = 0;

	w = t->win;

	if (t->cfont == font && t->cpoints == points)
		return;		/* no real change happens */

	win_flourishes = 0;	/* no silly effects, thank you */
	if (w->wi_handle >= 0) {
		wind_close(w->wi_handle);
		wind_delete(w->wi_handle);
		reopen = 1;
	}
	w->wi_handle = -1;

	t->cfont = font;
	t->cpoints = points;
	set_font(font, points);
	vqt_fontinfo(vdi_handle, &firstchar, &lastchar, distances, &maxwidth,
		     effects);
	t->cmaxwidth = maxwidth;
	t->cheight = distances[0]+distances[4]+1;
	t->cbase = distances[4];
	t->minADE = firstchar;
	t->maxADE = lastchar;
	set_cwidths(t);

	width = NCOLS(t) * t->cmaxwidth;
	height = NROWS(t) * t->cheight;

	wind_calc(WC_BORDER, w->wi_kind, w->wi_fullx, w->wi_fully, width,
		height, &dummy, &dummy, &w->wi_fullw, &w->wi_fullh);
	if (w->wi_fullw > wdesk) w->wi_fullw = wdesk;
	if (w->wi_fullh > hdesk) w->wi_fullh = hdesk;

	if (w->wi_fullx + w->wi_fullw > xdesk + wdesk)
		w->wi_fullx = xdesk + (wdesk - w->wi_fullw)/2;
	if (w->wi_fully + w->wi_fullh > ydesk + hdesk)
		w->wi_fully = ydesk + (hdesk - w->wi_fullh)/2;

	wind_calc(WC_WORK, w->wi_kind, w->wi_fullx, w->wi_fully, w->wi_fullw, w->wi_fullh,
		&dummy, &dummy, &width, &height);

	if (w->wi_w > width) w->wi_w = width;
	if (w->wi_h > height) w->wi_h = height;

	if (reopen)
		open_window(w);
	win_flourishes = oldflourishes;
}

/*
 * make a text window have a new number of rows and columns, and
 * a new amount of scrollback
 */

void
resize_textwin(t, cols, rows, scrollback)
	TEXTWIN *t;
	int cols, rows, scrollback;
{
	extern int win_flourishes;	/* in window.c */
	WINDOW *w = t->win;
	int i, j, mincols;
	int delta;
	UCHAR **newdata;
	short **newcflag;
	char *newdirty;
	int width, height, dummy;
	int oldflourishes = win_flourishes;
	int reopen = 0;

	if (t->maxx == cols && t->miny == scrollback &&
	    t->maxy == rows+scrollback)
		return;		/* no change */
	newdata = malloc(sizeof(char *) * (rows+scrollback));
	newcflag = malloc(sizeof(short *) * (rows+scrollback));
	newdirty = malloc((size_t)(rows+scrollback));
	if (!newdata || !newcflag || !newdirty)
		return;

	mincols = (cols < t->maxx) ? cols : t->maxx;

/* first, initialize the new data to blanks */
	for (i = 0; i < rows+scrollback; i++) {
		newdirty[i] = 0;
		newdata[i] = malloc((size_t)cols+1);
		newcflag[i] = malloc(sizeof(short)*(cols+1));
		if (!newcflag[i] || !newdata[i])
			return;
		for(j = 0; j < cols; j++) {
			newdata[i][j] = ' '; newcflag[i][j] = COLORS(1, 0);
		}
	}

/* now, copy as much scrollback as we can */

	if (rows+scrollback >= t->maxy) {
		delta = rows+scrollback - t->maxy;
		for (i = 0; i < t->maxy;i++) {
			for (j = 0; j < mincols; j++) {
				newdata[i+delta][j] = t->data[i][j];
				newcflag[i+delta][j] = t->cflag[i][j];
			}
		}
	} else {
		delta = t->maxy - (rows+scrollback);
		for (i = 0; i < rows+scrollback; i++) {
			for (j = 0; j < mincols; j++) {
				newdata[i][j] = t->data[i+delta][j];
				newcflag[i][j] = t->cflag[i+delta][j];
			}
		}
	}

/* finally, free the old data and flags */
	for(i=0; i < t->maxy; i++) {
		free(t->data[i]); free(t->cflag[i]);
	}
	free(t->dirty);
	free(t->cflag);
	free(t->data);

	t->dirty = newdirty;
	t->cflag = newcflag;
	t->data = newdata;
	t->cy = t->cy - SCROLLBACK(t) + scrollback;
	t->maxx = cols;
	t->maxy = rows+scrollback;
	t->miny = scrollback;
	if (t->cx >= cols) t->cx = 0;
	if (t->cy >= t->maxy) t->cy = t->maxy-1;
	if (t->cy < scrollback) t->cy = scrollback;
	if (t->offy < scrollback * t->cheight)
		t->offy = scrollback * t->cheight;

	win_flourishes = 0;
	if (w->wi_handle >= 0) {
		wind_close(w->wi_handle);
		wind_delete(w->wi_handle);
		reopen = 1;
	}
	w->wi_handle = -1;

	width = t->maxx * t->cmaxwidth;
	height = rows * t->cheight;

	wind_calc(WC_BORDER, w->wi_kind, w->wi_fullx, w->wi_fully, width,
		height, &dummy, &dummy, &w->wi_fullw, &w->wi_fullh);
	if (w->wi_fullw > wdesk) w->wi_fullw = wdesk;
	if (w->wi_fullh > hdesk) w->wi_fullh = hdesk;

	if (w->wi_fullx + w->wi_fullw > xdesk + wdesk)
		w->wi_fullx = xdesk + (wdesk - w->wi_fullw)/2;
	if (w->wi_fully + w->wi_fullh > ydesk + hdesk)
		w->wi_fully = ydesk + (hdesk - w->wi_fullh)/2;

	wind_calc(WC_WORK, w->wi_kind, w->wi_fullx, w->wi_fully, w->wi_fullw, w->wi_fullh,
		&dummy, &dummy, &width, &height);

	if (w->wi_w > width) w->wi_w = width;
	if (w->wi_h > height) w->wi_h = height;

	if (reopen)
		open_window(w);
	win_flourishes = oldflourishes;
}

/* set the "cwidths" array for the given window correctly;
 * this function may be called ONLY when the font & height are already
 * set correctly, and only after t->cmaxwidth is set
 */

static void
set_cwidths(t)
	TEXTWIN *t;
{
	int i, status, dummy, wide;
	int widths[256];
	int monospaced = 1;
	int dfltwide;

	if (t->cwidths) {
		free(t->cwidths);
		t->cwidths = 0;
	}
	vqt_width(vdi_handle, DEFAULT_CHAR, &dfltwide, &dummy, &dummy);

	for (i = 0; i < 255; i++) {
		status = vqt_width(vdi_handle, i, &wide, &dummy, &dummy);
		if (status == -1) wide = dfltwide;
		if (wide != t->cmaxwidth)
			monospaced = 0;
		widths[i] = wide;
	}
	if (!monospaced) {
		t->cwidths = malloc(256 * sizeof(short));
		if (!t->cwidths) return;
		for (i = 0; i < 255; i++)
			t->cwidths[i] = widths[i];
	}
}
