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
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include "toswin_w.h"
#include "twdefs.h"
#include "twproto.h"

extern char *read_scrap();
extern void write_scrap();

/* shift key states */
#define KLSHIFT	0x1
#define KRSHIFT	0x2
#define KCTRL	0x4
#define KALT	0x8
#define KANY	(0xf)

/* what to add at the end of lines */
#define CR	1
#define LF	2
#define CRLF	3
#ifdef NONE
#undef NONE
#endif

#define NONE	0
int paste_options = CR;

/* how to cut lines */
#define STRIPBLANKS	1
#define OBEYLINES	2
int cut_options = STRIPBLANKS;


void
setcutoptions()
{
	int xclip, yclip, wclip, hclip;
	int ret;

	cutdialog[ADDCRLF].ob_state = 
	cutdialog[ADDLF].ob_state =
	cutdialog[ADDCR].ob_state = 
	cutdialog[ADDNONE].ob_state = NORMAL;

	switch(paste_options) {
	case CR:
		ret = ADDCR; break;
	case LF:
		ret = ADDLF; break;
	case CRLF:
		ret = ADDCRLF; break;
	default:
		ret = ADDNONE; break; /* WWA - was "NONE" */
	}
	cutdialog[ret].ob_state = SELECTED;

	cutdialog[STRIPEOL].ob_state = (cut_options & STRIPBLANKS) ? SELECTED :
			NORMAL;
	cutdialog[OBEYEOL].ob_state = (cut_options & OBEYLINES) ? SELECTED :
			NORMAL;

	wind_update(1);
	form_center(cutdialog, &xclip, &yclip, &wclip, &hclip);
	form_dial(FMD_START, 0, 0, 32, 32, xclip, yclip, wclip, hclip);
	if (win_flourishes)
		form_dial(FMD_GROW, 0, 0, 32, 32, xclip, yclip, wclip, hclip);
	objc_draw(cutdialog, 0, 2, xclip, yclip, wclip, hclip);
	ret = form_do(cutdialog,  0);
	if (win_flourishes)
		form_dial(FMD_SHRINK, 0, 0, 32, 32, xclip, yclip, wclip, hclip);
	form_dial(FMD_FINISH, 0, 0, 32, 32, xclip, yclip, wclip, hclip);
	wind_update(0);

	cutdialog[ret].ob_state = NORMAL;
	if (ret == EDOK) {
		cut_options = NONE;
		if (cutdialog[STRIPEOL].ob_state == SELECTED)
			cut_options |= STRIPBLANKS;
		if (cutdialog[OBEYEOL].ob_state == SELECTED)
			cut_options |= OBEYLINES;

		if (cutdialog[ADDCR].ob_state == SELECTED)
			paste_options = CR;
		else if (cutdialog[ADDLF].ob_state == SELECTED)
			paste_options = LF;
		else if (cutdialog[ADDCRLF].ob_state == SELECTED)
			paste_options = CRLF;
		else
			paste_options = NONE;

	}
}

/* unselect all text in the indicated window */

void
unselect(t)
	TEXTWIN *t;
{
	int i, j;

	for (i = 0; i < t->maxy; i++)
		for (j = 0; j < t->maxx; j++) {
			if (t->cflag[i][j] & CSELECTED) {
				t->cflag[i][j] &= ~CSELECTED;
				t->cflag[i][j] |= CTOUCHED;
				t->dirty[i] |= SOMEDIRTY;
			    }
		}
	refresh_textwin(t);
}

/* cut selected text from a window */

char *cliptext = 0;

void
cut(w)
	WINDOW *w;
{
	TEXTWIN *t;
	int i, j, numchars, numlines;
	int linedone;
	int needcrlf;
	char *s, c;

	if (w->wtype != TEXT_WIN) return;
	t = w->extra;

	if (cliptext) {
		free(cliptext);
		cliptext = 0;
	}

	numchars = numlines = 0;
	for (i = 0; i < t->maxy; i++) {
		linedone = 0;
		for (j = 0; j < t->maxx; j++) {
			if (t->cflag[i][j] & CSELECTED) {
				numchars++;
				if (!linedone) {
					numlines++;
					linedone = 1;
				}
			}
		}
	}
	if (!numchars) {
		form_alert(1, AlertStrng(NOTEXT));
		return;
	}
/*
 * The cut strategy is a little complicated, but here it is:
 * A "line" is a continuous stream of characters. If the "Obey Lines"
 * option is set, lines always end at end-of-line; otherwise, they
 * end at eol only if there are 2 or more spaces after them.
 * If "Strip Blanks" is set, then any trailing blanks are deleted.
 */
	cliptext = malloc(numchars+numlines+numlines+1);
	if (!cliptext) {
		form_alert(1, AlertStrng(NOMEM));
		return;
	}

	s = cliptext;

	needcrlf = 0;
	for (i = 0; i < t->maxy; i++) {
		linedone = 0;
		for (j = 0; j < t->maxx; j++) {
			if (t->cflag[i][j] & CSELECTED) {
				c = t->data[i][j];
				if (!c) c = ' ';
				*s++ = c;
				needcrlf = 1;
				if ( (cut_options & OBEYLINES) ||

					/* WWA - this was incorrect */
				    /* (j < t->maxy-2) || */
				     ((j > 0) &&

				     ((c == ' ') && t->data[i][j-1] == ' ')))
					linedone = 1;
				else
					linedone = 0;
			}
		}
		if (linedone) {
			if (cut_options & STRIPBLANKS) {
				while (s > cliptext && s[-1] == ' ')
					--s;
			}
			*s++ = '\r'; *s++ = '\n';
			needcrlf = 0;
		}
	}

#ifndef WWA_X_SELECT
/* tie off cliptext */
	if (needcrlf) {
		*s++ = '\r'; *s++ = '\n';
	}
#endif
	*s++ = 0;

#ifndef WWA_X_SELECT
	unselect(t);
#endif
}

/* paste text into a window */

void
paste(w)
	WINDOW *w;
{
	char *s;
	int c;

	if (!cliptext) {
		form_alert(1, AlertStrng(NOCUT));
		return;
	}
	for (s = cliptext; *s; s++) {
		c = *(unsigned char *)s;
		if (c == '\r' && s[1] == '\n') {
			s++;
			switch(paste_options) {
			case CRLF:
				(*w->keyinp)(w, '\r', 0);
			case LF:
				(*w->keyinp)(w, '\n', 0);
				break;
			case CR:
				(*w->keyinp)(w, '\r', 0);
				break;
			case NONE:
				break;
			}
		} else 
			(*w->keyinp)(w, c, 0);
	}
}

void
redraw_screen(x, y, w, h)
	int x, y, w, h;
{
	form_dial(0, x, y, w, h, x, y, w, h);
	form_dial(3, x, y, w, h, x, y, w, h);
}

/* cut text from the desktop */

void
cut_from_desk(x, y)
	int x, y;
{
	int i;
	int width, height, x1, y1, x2, y2, dummy;
	WINDOW *w;

	i = objc_find(deskobj, 0, 1, x, y);
	if (i != CLIPICN) {
		if (gl_topwin && gl_topwin->wtype == TEXT_WIN)
			unselect(gl_topwin->extra);
		return;
	}
	width = deskobj[i].ob_width; height = deskobj[i].ob_height;
	objc_offset(deskobj, i, &x1, &y1);

/* drag the icon around */
	wind_update(BEG_MCTRL);
	graf_mouse(FLAT_HAND, 0L);
	graf_dragbox(width, height, x1, y1, xdesk, ydesk, wdesk, hdesk,
		&x2, &y2);

	graf_mkstate(&x, &y, &dummy, &dummy);
	graf_mouse(ARROW, 0L);
	wind_update(END_MCTRL);

/* did we actually move anywhere? */
	if (x >= x1 && x <= x1+width && y >= y1 && y <= y1+height) {
		return;
	}
	w = find_window(x, y);
	if (w && w->wtype == TEXT_WIN) {
		if (cliptext)
			free(cliptext);

		cliptext = read_scrap("SCRAP.TXT");
		if (!cliptext) {
			form_alert(1, AlertStrng(SCRAPDAT));
			return;
		}
		paste(w);
#if 0
	} else {		/* just move the icon */
		hide_mouse();
		deskobj[i].ob_x += x2 - x1;
		deskobj[i].ob_y += y2 - y1;
		redraw_screen(x1, y1, width, height);
		redraw_screen(x2, y2, width, height);
		show_mouse();
#endif
	}
}

/* paste text onto the desktop */

void
paste_to_desk(x, y)
	int x, y;
{
	int i;
	int x1, y1;
	WINDOW *w;

	w = find_window(x, y);
	i = objc_find(deskobj, 0, 1, x, y);
	if (i == CLIPICN) {
		objc_offset(deskobj, CLIPICN, &x1, &y1);
		objc_change(deskobj, CLIPICN, 0, xdesk, ydesk, wdesk, hdesk,
			SELECTED, 0);
		if (w == toolwindow) {
			redraw_window(toolwindow, x1, y1,
			    deskobj[i].ob_width, deskobj[i].ob_height);
		}
		write_scrap("SCRAP.TXT", cliptext, (int)strlen(cliptext));
		objc_change(deskobj, CLIPICN, 0, xdesk, ydesk, wdesk, hdesk,
			NORMAL, 0);
		if (w == toolwindow) {
			redraw_window(toolwindow, x1, y1,
			    deskobj[i].ob_width, deskobj[i].ob_height);
		}
	}
}

static void
lightbox(plin, numpoints)
	int *plin;
	int numpoints;
{
	static int vtbl[4] = { 0x5555, 0xaaaa, 0xaaaa, 0x5555 };
	static int htbl[2] = { 0x5555, 0xaaaa };
	int style, *linexy, i;
	int attrib[6];

	vql_attribute(vdi_handle, attrib);

	vsl_color(vdi_handle, 1);

	for (i = 1; i < numpoints; i++) {
		if (plin[0] == plin[2])
			style = vtbl[(plin[0] & 1) | ((plin[1] & 1) << 1)];
		else {
			linexy = (plin[0] < plin[2]) ? plin : plin+2;
			style = htbl[ linexy[1] & 1 ];
		}
		vsl_udsty(vdi_handle, style);
		vsl_type(vdi_handle, 7);
		v_pline(vdi_handle, 2, plin);
		plin += 2;
	}

	vsl_type(vdi_handle, attrib[0]);
	vsl_color(vdi_handle, attrib[1]);
}

void
hot_dragbox(plin, numpoints, lastx, lasty)
	int *plin;
	int numpoints;
	int *lastx, *lasty;
{
	int boxx, boxy;
	int msx, msy, mbutton, dummy, event;
	int newx, newy;
	int oldbx, oldby;
	int deltax, deltay;
	int width, height;
	int clipx, clipy, clipw, cliph;	/* box holding the clipboard
						   icon */

	int inclip = 0;
	int i;

/* find the biggest rectangle that will enclose the region */
	boxx = plin[0]; boxy = plin[1];
	clipx = boxx; clipy = boxy;

	for (i = 2; i < numpoints + numpoints; i += 2) {
		if (plin[i] < boxx) boxx = plin[i];
		if (plin[i] > clipx) clipx = plin[i];
		if (plin[i+1] < boxy) boxy = plin[i+1];
		if (plin[i+1] > clipy) clipy = plin[i+1];
	}
	width = clipx - boxx + 1;
	height = clipy - boxy + 1;

	set_wrmode(3);		/* XOR */

	if (showtools) {
		objc_offset(deskobj, CLIPICN, &clipx, &clipy);
		clipw = deskobj[CLIPICN].ob_width;
		cliph = deskobj[CLIPICN].ob_height;

		graf_mkstate(&msx, &msy, &mbutton, &dummy);
		if (msx >= clipx && msx < clipx+clipw && 
		    msy >= clipy && msy < clipy+cliph)
			inclip = 1;
	} else {
		graf_mkstate(&msx, &msy, &mbutton, &dummy);
		clipx = clipy = clipw = cliph = -1;
		inclip = 0;
	}

	hide_mouse();
	lightbox(plin, numpoints);
	show_mouse();

	reset_clip();
	for(;;) {
		oldbx = boxx; oldby = boxy;
		event = evnt_multi(MU_BUTTON|MU_M1|MU_M2,
			1, 0x0001, 0x0000,
			1, msx, msy, 1, 1,
			inclip, clipx, clipy, clipw, cliph,
			0L, 0L,
			&newx, &newy, &mbutton, &dummy,
			&dummy, &dummy);
		if (showtools && (event & MU_M2)) {
			inclip = !inclip;
			hide_mouse();
			lightbox(plin, numpoints);
			objc_change(deskobj, CLIPICN, 0, clipx, clipy, clipw,
				cliph, inclip ? SELECTED : NORMAL, 0);
			redraw_window(toolwindow, clipx, clipy,
				clipw, cliph);
/* note: redraw_window turns the mouse back on and changes the clipping
 * rectangle
 */
			reset_clip();
			hide_mouse();
			lightbox(plin, numpoints);
			show_mouse();
		}
		if (event & MU_M1) {
			boxx = boxx + (newx - msx);
			if (boxx < xdesk)
				boxx = xdesk;
			else if (boxx + width > xdesk + wdesk)
				boxx = xdesk+wdesk - width;
			boxy = boxy + (newy - msy);
			if (boxy < ydesk)
				boxy = ydesk;
			else if (boxy + height > ydesk + hdesk)
				boxy = ydesk + hdesk - height;
			if (oldbx != boxx || oldby != boxy) {
				hide_mouse();
				lightbox(plin, numpoints);
				deltax = boxx - oldbx;
				deltay = boxy - oldby;
				for (i = 0; i < numpoints + numpoints; i += 2) {
					plin[i] += deltax;
					plin[i+1] += deltay;
				}
				lightbox(plin, numpoints);
				oldbx = boxx;
				oldby = boxy;
				show_mouse();
			} 
		}
		msx = newx;
		msy = newy;
		if (event & MU_BUTTON)
			break;
	}
	hide_mouse();
	lightbox(plin, numpoints);
	show_mouse();
	*lastx = boxx;
	*lasty = boxy;
}

/*
 * debounce the mouse, so that we can distinguish single-clicks, double-clicks,
 * and drags
 */

#ifndef WWA_X_SELECT
static int
debounce(time, x, y, kshift, buttons)
	long time;
	int *x, *y, *kshift, *buttons;
{
	int clicks = 0;
	int event, dummy;

	if (time > 0) {
		event = evnt_multi(MU_BUTTON | MU_TIMER,
			0x0102, 0x0003, *buttons,
			0, 0, 0, 0, 0,
			0, 0, 0, 0, 0,
			(void *)0,
			time,		/* milliseconds */
			x, y, buttons, kshift,
			&dummy, &clicks);
	} else {
		event = MU_TIMER;
	}
	graf_mkstate(x, y, buttons, kshift);

	return (event & MU_BUTTON) ? clicks : 1;
}
#endif

#ifdef GLOBAL_APPL_MENUS

void
togglemenu()
{
	WINDOW *w = gl_topwin;
	ENTRY *e;

	for (e = globalmenu->contents; e; e = e->next) {
		if (e->func == togglemenu) {
			break;
		}
	}

	if (!sys_menu) {
		sys_menu = 1;
		appl_menus = 0;
		show_menu(sysbar);
	} else {
		appl_menus = !appl_menus;
		if (w && w->wtype == TEXT_WIN) {
			if (w->menu && appl_menus) {
				sys_menu = 0;
				show_menu(w->menu);
			}
		}
	}
	if (e) {
		if (appl_menus)
			check_entry(globalmenu, e);
		else
			uncheck_entry(globalmenu, e);
	}
}

#endif

static void pixpoint __PROTO((TEXTWIN *, int, int, int *, int *));
static void dragtext __PROTO((TEXTWIN *, int, int));
static void selectfrom __PROTO((TEXTWIN *, int, int, int, int));
#ifdef WWA_X_SELECT
static int select __PROTO((TEXTWIN *, int, int, int));
#else
static void select __PROTO((TEXTWIN *, int, int, int));
#endif

static void
pixpoint(t, col, row, xp, yp)
	TEXTWIN *t;
	int col, row, *xp, *yp;
{
	int x, y;
	WINDOW *w = t->win;

	char2pixel(t, col, row, &x, &y);

	if (x < w->wi_x)
		x = w->wi_x;
	else if (x > w->wi_x + w->wi_w)
		x = w->wi_x + w->wi_w;

	if (y < w->wi_y)
		y = w->wi_y;
	else if (y > w->wi_y + w->wi_h)
		y = w->wi_y + w->wi_h;

	*xp = x;
	*yp = y;
}

static void
dragtext(t, x, y)
	TEXTWIN *t;
	int x, y;
{
	static int plin[20];
	int numpoints;
	int i, j;
	int firstx, firsty, lastx, lasty;
	WINDOW *newwin, *w = t->win;
	int buttons, kshift;

	firstx = firsty = lastx = lasty = -1;
	/* find edges of region */
	for (j = 0; j < t->maxy; j++) {
		for (i = 0; i < t->maxx; i++) {
			if (t->cflag[j][i] & CSELECTED) {
				if (firstx == -1) {
					firstx = i;
					firsty = j;
				}
				lastx = i;
				lasty = j;
			}
		}
	}

	if (firstx == -1) return;

	pixpoint(t, firstx, firsty, &plin[0], &plin[1]);

	if (firsty == lasty) {
		numpoints = 5;
		pixpoint(t, lastx+1, firsty, &plin[2], &plin[3]);
		plin[4] = plin[2]; plin[5] = plin[3] + t->cheight;
		if (plin[5] > w->wi_y + w->wi_h)
			plin[5] = w->wi_y + w->wi_h;
		plin[6] = plin[0]; plin[7] = plin[5];
		plin[8] = plin[0]; plin[9] = plin[1];
	} else {
		numpoints = 9;
		pixpoint(t, t->maxx, firsty, &plin[2], &plin[3]);
		pixpoint(t, t->maxx, lasty, &plin[4], &plin[5]);
		pixpoint(t, lastx+1, lasty, &plin[6], &plin[7]);
		plin[8] = plin[6]; plin[9] = plin[7] + t->cheight;
		if (plin[9] > w->wi_y + w->wi_h)
			plin[9] = w->wi_y + w->wi_h;
		plin[10] = w->wi_x; plin[11] = plin[9];
		pixpoint(t, 0, firsty+1, &plin[12], &plin[13]);
		plin[14] = plin[0]; plin[15] = plin[13];
		plin[16] = plin[0]; plin[17] = plin[1];
	}

/* drag text */
	wind_update(BEG_MCTRL);
	graf_mouse(FLAT_HAND, 0L);
	hot_dragbox(plin, numpoints, &x, &y);
	graf_mkstate(&x, &y, &buttons, &kshift);
	graf_mouse(ARROW, 0L);
	wind_update(END_MCTRL);
/* did we actually move anywhere? */
	newwin = find_window(x, y);
	if (newwin == t->win) {
		pixel2char(t, x, y, &x, &y);
		if (t->cflag[y][x] & CSELECTED)
			return;
	}

/* yes, we did move; do a cut and paste */
	cut(w);
	if (newwin) {
		if (newwin->wtype == TEXT_WIN)
			paste(newwin);
		else
			paste_to_desk(x, y);
	} else {
		form_alert(1, AlertStrng(NOTDESK)); 
	}
}

static void
selectfrom(t, x1, y1, x2, y2)
	TEXTWIN *t;
	int x1, y1, x2, y2;
{
	int i, j;
	int first, last;

/* first, normalize coordinates */
	if ( (y1 > y2) || (y1 == y2 && x1 > x2) ) {
		i = x1; j = y1;
		x1 = x2; y1 = y2;
		x2 = i; y2 = j;
	}

	for (j = 0; j <= y1; j++) {
		last = (j == y1) ? x1 : t->maxx;
		for (i = 0; i < last; i++) {
			if (t->cflag[j][i] & CSELECTED) {
				t->cflag[j][i] &= ~CSELECTED;
				t->cflag[j][i] |= CTOUCHED;
				t->dirty[j] |= SOMEDIRTY;
			}
		}
	}
	for (j = y1; j <= y2; j++) {
		first = (j == y1) ? x1 : 0;
		last = (j == y2) ? x2+1 : t->maxx;
		for (i = first; i < last; i++) {
			if (!(t->cflag[j][i] & CSELECTED)) {
				t->cflag[j][i] |= (CTOUCHED|CSELECTED);
				t->dirty[j] |= SOMEDIRTY;
			}
		}
	}
	for (j = y2; j < t->maxy; j++) {
		first = (j == y2) ? x2+1 : 0;
		for (i = first; i < t->maxx; i++) {
			if (t->cflag[j][i] & CSELECTED) {
				t->cflag[j][i] &= ~CSELECTED;
				t->cflag[j][i] |= CTOUCHED;
				t->dirty[j] |= SOMEDIRTY;
			}
		}
	}
	refresh_textwin(t);
}

#ifdef WWA_X_SELECT

void release_button(b)
	int b;
{
	int event, dummy, msx, msy, mbutton;

	wind_update(BEG_MCTRL);

	for(;;) {
		event = evnt_multi(MU_BUTTON, 1, b, 0,
			1, 0, 0, 0, 0,
			0, 0, 0, 0, 0,
			0L, 0L,
			&msx, &msy, &mbutton, &dummy,
			&dummy, &dummy);
		if (event & MU_BUTTON)
			break;
	}

	wind_update(END_MCTRL);
}

int CharClass(ch)
	char ch;
{
	/* Hard wire */

	/* Filename/emailaddres/identifier class */
	if (isalnum(ch) || ch=='/' || ch=='.' || ch=='_' || ch=='@')
		return 1;
	else if (iswhite(ch))
		return 2;
	else
		return 1000+ch; /* One class per character */
}

int /* 0==none selected, 1==non-line selected 2==line selected */
expand_selection(t, curcol, currow, kshift)
	TEXTWIN *t;
	int curcol, currow, kshift;
{
	int curclass=CharClass(t->data[currow][curcol]);

	refresh_textwin(t);

	if (t->cflag[currow][curcol]&CSELECTED) {
		int second=1;
		if (curcol>0) {
			if (t->cflag[currow][curcol-1]&CSELECTED
			&& CharClass(t->data[currow][curcol-1])==curclass) {
				second=0;
			}
		}
		if (curcol<t->maxx) {
			if (t->cflag[currow][curcol+1]&CSELECTED
			&& CharClass(t->data[currow][curcol+1])==curclass) {
				second=0;
			}
		}
		if (second) {
			/* Second click - class */

			int lcol=curcol;
			int rcol=curcol;

			while (lcol>0 && CharClass(t->data[currow][lcol])==curclass) {
				lcol--;
			}
			if (CharClass(t->data[currow][lcol])!=curclass)
				lcol++;

			while (rcol<t->maxx && CharClass(t->data[currow][rcol])==curclass) {
				rcol++;
			}
			if (CharClass(t->data[currow][rcol])!=curclass)
				rcol--;

			selectfrom(t, lcol, currow, rcol, currow);
		} else {
			/* Third click - line */
			if (t->cflag[currow][0]&CSELECTED && t->cflag[currow][t->maxx-1]&CSELECTED) {
				/* Fourth click - nothing */
				unselect(t);
				return 0;
			} else {
				selectfrom(t, 0, currow, t->maxx, currow);
				return 2;
			}
		}
	} else {
		/* First click - character */
		selectfrom(t, curcol, currow, curcol, currow);
	}

	return 1;
}
#endif

#ifdef WWA_X_SELECT
int
#else
void
#endif
select(t, curcol, currow, kshift)
	TEXTWIN *t;
	int curcol, currow, kshift;
{
	WINDOW *v = t->win;
	int x, y, firstx, firsty;
	int event, dummy, msx, msy, mbutton;
	int anchorcol, anchorrow;
	short *WIDE = t->cwidths;
	int cboxw;

	refresh_textwin(t);

/* shift+select adds to existing text; regular select replaces */
	anchorrow = currow; anchorcol = curcol;

	if (kshift & 3) {
		for (y = 0; y < t->maxy; y++)
			for (x = 0; x < t->maxx; x++) {
				if (t->cflag[y][x] & CSELECTED) {
					anchorrow = y;
					anchorcol = x;
					if (y < currow ||
					    (y == currow && x < curcol)) {
						goto foundselect;
					}
						
				}
			}
	} else {
		unselect(t);
	}

foundselect:

	char2pixel(t, curcol, currow, &x, &y);
	firstx = msx = x; firsty = msy = y;

	wind_update(BEG_MCTRL);
	graf_mouse(POINT_HAND, 0L);

	selectfrom(t, anchorcol, anchorrow, curcol, currow);

	cboxw = t->cmaxwidth;
	for(;;) {
		if (WIDE)
			cboxw = WIDE[t->data[currow][curcol]];

		event = evnt_multi(MU_M1 | MU_BUTTON, 
			0x101, 0x0003, 0x0001,
			1, x, y, cboxw, t->cheight,
			0, 0, 0, 0, 0,
			0L, 0L,
			&msx, &msy, &mbutton, &dummy,
			&dummy, &dummy);
		if (event & MU_M1) {
			if (msx < v->wi_x)
				msx = v->wi_x;
			else if (msx >= v->wi_x + v->wi_w)
				msx = v->wi_x + v->wi_w - 1;
			if (msy < v->wi_y)
				msy = v->wi_y;
			else if (msy >= v->wi_y + v->wi_h)
				msy = v->wi_y + v->wi_h - 1;
			pixel2char(t, msx, msy, &curcol, &currow);
			char2pixel(t, curcol, currow, &x, &y);
			selectfrom(t, anchorcol, anchorrow, curcol, currow);
		}
		if (event & MU_BUTTON)
			break;
	}

	graf_mouse(ARROW, 0L);
	wind_update(END_MCTRL);

	if ( ((msx - firstx) < 3) && ((msx - firstx) > -3) &&
	     ((msy - firsty) < 3) && ((msy - firsty > -3)) ) {
		unselect(t);
#ifdef WWA_X_SELECT
		return 0;
#else
		return;
#endif
	}

#ifdef WWA_X_SELECT
	return 1;
#else
	return;
#endif
}

#define BOXSIZE 8

int
win_ctrl(v, x, y)
	WINDOW *v;
	int x, y;
{
	int wx, wy, ww, wh;

	wind_update(BEG_MCTRL);
	wind_get(v->wi_handle, WF_CURRXYWH, &wx, &wy, &ww, &wh);

	if ((x >= v->wi_x + v->wi_w - BOXSIZE) &&
	    (y >= v->wi_y + v->wi_h - BOXSIZE)) {
		graf_mouse(POINT_HAND, 0L);
		graf_rubberbox(wx, wy, 8, 8, &ww, &wh);
		(*v->sized)(v, wx, wy, ww, wh);
	} else if ((x >= v->wi_x + v->wi_w - BOXSIZE) &&
		   (y <= v->wi_y + BOXSIZE) ) {
		do {
			graf_mkstate(&x, &y, &ww, &wh);
		} while (ww);
		(*v->fulled)(v);
	} else {
		graf_mouse(FLAT_HAND, 0L);
		graf_dragbox(ww, wh, wx, wy, xdesk, ydesk, wdesk, hdesk,
			&wx, &wy);
		(*v->moved)(v, wx, wy, ww, wh);
	}
	graf_mouse(ARROW, 0L);
	wind_update(END_MCTRL);
	return 1;
}

int
win_click(w, clicks, x, y, kshift, buttons)
	WINDOW *w;
	int clicks, x, y, kshift, buttons;
{
	TEXTWIN *t;
	int x1, y1;
	int ret = 0;

	t = w->extra;
	
#ifndef WWA_X_SELECT
	if (clicks == 1) {
		int i, j;
		clicks = debounce(300L - gl_timer, &x, &y, &i, &j);
	}

	if (clicks == 1 && buttons == 1) {  /* left click */
	/* is the button still down?; if so, select some text */
		graf_mkstate(&x, &y, &buttons, &kshift);
		if (buttons != 1 && !(kshift&(KLSHIFT|KRSHIFT))) {
	/* just a single click -- unselect old text */
			unselect(t);
			return 1;
		}
#else
	if (buttons == 1) {  /* left click(s) */
#endif

		if (kshift & KCTRL) {
			return win_ctrl(w, x, y);
		}
	/* convert to character coordinates */
		pixel2char(t, x, y, &x1, &y1);

#ifdef WWA_X_SELECT
		if (! (t->cflag[y1][x1] & CSELECTED)) {
			if (select(t, x1, y1, kshift))
				cut(w);
			clicks--;
		}

		while (clicks--) {
			switch (expand_selection(t, x1, y1, kshift)) {
			 case 0:
				/* No selection */
			break; case 1:
				cut(w);
			break; case 2:
				cut(w);
			}
		}

		release_button(1);
#else
		if (t->cflag[y1][x1] & CSELECTED) {
			dragtext(t, x1, y1);
		} else {
			select(t, x1, y1, kshift);
		}
#endif

		return 1;
#ifdef WWA_X_SELECT
	} else if (buttons == 2) {
		paste(w);
		release_button(2);
		ret = 1;
#endif
#ifdef GLOBAL_APPL_MENUS
	} else if (buttons == 2) {
		togglemenu();
		ret = 1;
#endif
	}

	return ret;
}

void
desk_mouse(clicks, x, y, kshift, buttons)
	int clicks, x, y, kshift, buttons;
{
	if (clicks == 1 && buttons == 1) {  /* left click */
	/* is the button still down?; if so, select some text */
		graf_mkstate(&x, &y, &buttons, &kshift);
		if (buttons == 1) {	/* still down */
			cut_from_desk(x, y);
		}
#ifdef GLOBAL_APPL_MENUS
	} else if (buttons == 2) {	/* right mouse click */
		togglemenu();
#endif
	}
}
