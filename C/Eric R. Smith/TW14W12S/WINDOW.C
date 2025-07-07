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
#include <stdlib.h>
#include <gemfast.h>
#include <aesbind.h>
#include <vdibind.h>
#include <osbind.h>
#include <string.h>
#include "xgem.h"

#define WF_BEVENT	24

#define IM_RESERVE	12345
#define IM_RELEASE	12346

/*
 * global variables
 */

/* current top window */
WINDOW *gl_topwin;
extern WINDOW *focuswin;

/* list of all windows in system */
WINDOW *gl_winlist;

/* do we want graf_{grow,shrink}box effects? */
int win_flourishes = 1;

/*
 * some dummy functions for windows
 */

static void
clear_win(v, x, y, w, h)
	WINDOW *v;
	int x,y,w,h;
{
	int temp[4];

	vsf_color(vdi_handle, 0);
	temp[0] = x;
	temp[1] = y;
	temp[2] = x + w - 1;
	temp[3] = y + h - 1;
	v_bar(vdi_handle, temp);
	vsf_color(vdi_handle, 1);
}

static void
top_win(w)
	WINDOW *w;
{
	gl_topwin = w;
	wind_set(w->wi_handle, WF_TOP, 0, 0, 0, 0);
}

static void
close_win(w)
	WINDOW *w;
{
	destroy_window(w);
}

static void
full_win(v)
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

	wind_set(v->wi_handle, WF_CURRXYWH, newx, newy, neww, newh);
	wind_get(v->wi_handle, WF_WORKXYWH, &v->wi_x, &v->wi_y, &v->wi_w,
		&v->wi_h);

	v->flags ^= WFULLED;
}

static void
move_win(v, x, y, w, h)
	WINDOW *v;
	int x, y, w, h;
{
	int fullx, fully, fullw, fullh;

	wind_get(v->wi_handle, WF_FULLXYWH, &fullx, &fully, &fullw, &fullh);

	if (w > fullw) w = fullw;
	if (h > fullh) h = fullh;

	if (w != fullw || h != fullh)
		v->flags &= ~WFULLED;

	wind_set(v->wi_handle, WF_CURRXYWH, x, y, w, h);
	wind_get(v->wi_handle, WF_WORKXYWH, &v->wi_x, &v->wi_y,
		&v->wi_w, &v->wi_h);
}

static void
size_win(v, x, y, w, h)
	WINDOW *v;
	int x, y, w, h;
{
	move_win(v, x, y, w, h);
}

static void
noslid(w, m)
	WINDOW *w;
	int m;
{
}

static int
nokey(w, code)
	WINDOW *w;
	int code;
{
	return 0;
}

static int
nomouse(w, clicks, x, y, shift, mbuttons)
	WINDOW *w;
	int clicks, x, y, shift, mbuttons;
{
	return 0;
}

static int
iconmouse(v, clicks, x, y, shift, mbuttons)
	WINDOW *v;
	int clicks, x, y, shift, mbuttons;
{
	int w, h;

	if (mbuttons) {
/* wait for a little bit */
		evnt_timer(140L);
		graf_mkstate(&x, &y, &mbuttons, &shift);
		if (x < v->wi_x || x > v->wi_x + v->wi_w || y < v->wi_y ||
		    y > v->wi_y + v->wi_w)
			return 1;
		if (mbuttons) {		/* button still down */
			wind_update(BEG_MCTRL);
			graf_mouse(FLAT_HAND, 0L);
			wind_get(v->wi_handle, WF_CURRXYWH, &x, &y, &w, &h);
			graf_dragbox(w, h, x, y, xdesk, ydesk, wdesk, hdesk,
				&x, &y);
			graf_mouse(ARROW, 0L);
			wind_update(END_MCTRL);
			(*v->moved)(v, x, y, w, h);
			return 1;
		}
	}
	(*v->fulled)(v);	/* un-iconify the window */
	return 1;
}

/* turn a window into an icon */

static void
uniconify_win(v)
	WINDOW *v;
{
	static int mbuf[8];
	int newx, newy, neww, newh;
	int id = appl_find("ICONMGR ");

	if (!(v->flags & WICONIFIED)) return;
	if (id >= 0) {
		mbuf[0] = IM_RELEASE;
		mbuf[1] = gl_apid;
		mbuf[2] = 0;
		mbuf[3] = v->icon_slot;
		appl_write(id, 16, mbuf);
	}
	v->fulled = v->oldfulled;
	v->mouseinp = v->oldmouse;
	v->flags &= ~WICONIFIED;

	if (win_flourishes) {
		graf_growbox(v->wi_x, v->wi_y, v->wi_w, v->wi_h,
			     v->prevx, v->prevy, v->prevw, v->prevh);
	}
	wind_calc(WC_BORDER, v->old_wkind, v->prevx, v->prevy, v->prevw,
			v->prevh, &newx, &newy, &neww, &newh);
	change_window_gadgets(v, v->old_wkind);
	(*v->sized)(v, newx, newy, neww, newh);

/* button events should top the window */
	wind_set(v->wi_handle, WF_BEVENT, 0x0000, 0, 0, 0);
	(*v->topped)(v);
}

static void
iconify_win(v, slot, x, y, w, h)
	WINDOW *v;
	int slot, x, y, w, h;
{
	if (v->flags & WICONIFIED)
		return;
	v->flags &= ~WFULLED;
	v->flags |= WICONIFIED;
	v->oldfulled = v->fulled;
	v->oldmouse = v->mouseinp;
	v->icon_slot = slot;
	v->old_wkind = v->wi_kind;

	v->prevx = v->wi_x;
	v->prevy = v->wi_y;
	v->prevw = v->wi_w;
	v->prevh = v->wi_h;
	change_window_gadgets(v, 0);
	if (win_flourishes) {
		graf_shrinkbox(x, y, w, h, v->prevx, v->prevy, v->prevw,
				v->prevh);
	}
	(*v->sized)(v, x, y, w, h);

/* we don't want the window topped inadvertently */
	wind_set(v->wi_handle, WF_BEVENT, 0x0001, 0, 0, 0);
	v->fulled = uniconify_win;
	v->mouseinp = iconmouse;
	new_topwin(1);
}

/*
 * Create a new window with title "title," initial/full size x, y, w, h,
 * and gadgets given by "kind." Returns a pointer to the new window,
 * or NULL if an error occurs. The window is not actually opened,
 * however.
 */

/* used to "stagger" opening positions of windows */
#define WOFF_INC gl_hbox
#define WOFF_MAX 64

#ifdef WWA_EXT_TOSRUN
/* BUT, turn it off if TOSRUN pipe supports window positioning! */
# ifdef WWA_WIN_RUN
# undef WOFF_INC gl_hbox
# define WOFF_INC 0
# endif
#endif

static int winoff = 0;

WINDOW *
create_window(title, kind, wx, wy, ww, wh)
	const char *title;
	int kind, wx, wy, ww, wh;
{
	WINDOW *v;
	int fullx, fully, fullw, fullh;
	int centerwin = 0;

	if (title) {
		title = strdup(title);
	}

	v = malloc(sizeof(WINDOW));
	if (!v) return v;

	v->wi_handle = -1;	/* not open yet */
	v->wi_kind = kind;

	if (wx == 0 && wy == 0) centerwin = 1;
	if (wx < xdesk) wx = xdesk;
	if (wy < ydesk) wy = ydesk;

/* calculate max. window size needed for a working area of ww x wh */
	wind_calc(WC_WORK, v->wi_kind, wx, wy, wdesk, hdesk,
		 &v->wi_x, &v->wi_y, &v->wi_w, &v->wi_h);
	wind_calc(WC_BORDER, v->wi_kind, v->wi_x, v->wi_y, ww, wh,
		 &fullx, &fully, &fullw, &fullh);

	if (fullw > wdesk)
		fullw = wdesk;
	if (fullh > hdesk)
		fullh = hdesk;

	if (centerwin) {
		fullx = xdesk;
		fully = ydesk;
	}


	fullx += winoff;
	fully += winoff;
	winoff += WOFF_INC;
	if (winoff > WOFF_MAX) {
		winoff = 0;
	}

	v->wi_title = (char *)title;
	v->wi_fullx = fullx;
	v->wi_fully = fully;
	v->wi_fullw = fullw;
	v->wi_fullh = fullh;

	wind_calc(WC_WORK, v->wi_kind, fullx, fully, fullw, fullh,
		  &v->wi_x, &v->wi_y, &v->wi_w, &v->wi_h);

	v->wtype = GENERIC_WIN;
	v->extra = (void *)0;
	v->icon_slot = -1;
	v->flags = 0;

	v->draw = clear_win;
	v->topped = top_win;
	v->closed = close_win;
	v->fulled = full_win;
	v->sized = size_win;
	v->moved = move_win;
	v->arrowed = noslid;
	v->hslid = noslid;
	v->vslid = noslid;
	v->keyinp = nokey;
	v->mouseinp = nomouse;
	v->iconify = iconify_win;
	v->oldfulled = v->fulled;
	v->oldmouse = nomouse;

	v->menu = 0;
	v->infostr = 0;

	v->next = gl_winlist;
	gl_winlist = v;
	return v;
}

WINDOW *
open_window(v)
	WINDOW *v;
{
	int wx, wy, ww, wh;

	if (v->wi_handle >= 0)		/* already open?? */
		return v;

	v->wi_handle = wind_create(v->wi_kind, v->wi_fullx, v->wi_fully,
				v->wi_fullw, v->wi_fullh);

	if (v->wi_handle < 0)
		return 0;

	wind_set(v->wi_handle, WF_BEVENT, 0x0000, 0, 0, 0);
	if (v->wi_kind & NAME) {
		if (v->wi_title)
			wind_set(v->wi_handle, WF_NAME, v->wi_title);
		else
			wind_set(v->wi_handle, WF_NAME, "Untitled");
	}
	if (v->wi_kind & INFO) {
		if (v->infostr) {
			wind_set(v->wi_handle, WF_INFO, v->infostr);
		} else {
			wind_set(v->wi_handle, WF_INFO, "");
		}
	}

	wind_calc(WC_BORDER, v->wi_kind, v->wi_x, v->wi_y, v->wi_w, v->wi_h,
		&wx, &wy, &ww, &wh);

	if (win_flourishes)
		graf_growbox(wx + ww/2, wy + wh/2, gl_wbox ,gl_hbox,
			     wx, wy, ww, wh);

	wind_open(v->wi_handle, wx, wy, ww, wh);

	(*v->topped)(v);
/* set scroll bars, etc. correctly */
	(*v->sized)(v, wx, wy, ww, wh);
	return v;
}

void
close_window(v)
	WINDOW *v;
{
	int i, dummy;

	if (v->wi_handle < 0)	/* already closed? */
		return;

	wind_close(v->wi_handle);
	if (win_flourishes)
		graf_shrinkbox(v->wi_x + v->wi_w/2, v->wi_y + v->wi_h/2,
			gl_wbox, gl_hbox, v->wi_x, v->wi_y, v->wi_w, v->wi_h);
	wind_delete(v->wi_handle);
	v->wi_handle = -1;

/* reset gl_topwin */
	gl_topwin = 0;
	wind_get(0, WF_TOP, &i, &dummy, &dummy, &dummy);
	for (v = gl_winlist; v; v = v->next) {
		if (v->wi_handle == i)
			break;
	}
	if (v && !(v->flags & WICONIFIED))
		(*v->topped)(v);
}

/*
 * destroy a window
 */

void
destroy_window(v)
	WINDOW *v;
{
	WINDOW **ptr, *w;
	extern void unloadmenu();

	if (v->wi_handle >= 0) {
		close_window(v);
	}

	if (v->wi_title)
		free(v->wi_title);

	if (v->infostr)
		free(v->infostr);

/* find v in the window list, and unlink it */
	ptr = &gl_winlist;
	w = *ptr;
	while (w) {
		if (w == v) {
			*ptr = v->next;
			break;
		}
		ptr = &w->next;
		w = *ptr;
	}
/* maybe we should have an error here if v isn't found */

	free(v);
}

/*
 * redraw all parts of a window that lie within the rectangle
 * xc, yc, wc, hc
 */

void
redraw_window(v, xc, yc, wc, hc)
	WINDOW *v;
	int xc, yc, wc, hc;
{
	GRECT	t1, t2;
	int temp[4];

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
			temp[0] = t1.g_x;
			temp[1] = t1.g_y;
			temp[2] = temp[0]+t1.g_w-1;
			temp[3] = temp[1]+t1.g_h-1;
			vs_clip(vdi_handle, 1, temp);
			(*v->draw)(v, t1.g_x, t1.g_y, t1.g_w, t1.g_h);
	  	}
		wind_get(v->wi_handle, WF_NEXTXYWH, &t1.g_x, &t1.g_y,
			 &t1.g_w, &t1.g_h);
	}
	show_mouse();
	wind_update(FALSE);
}

/*
 * find a window
 */

WINDOW *
which_window(x)
	int x;
{
	WINDOW *w;

	if (x < 0) return 0;

	for (w = gl_winlist; w; w = w->next)
		if (w->wi_handle == x)
			return w;
	return 0;
}

/*
 * handle an evnt_multi message dealing with windows
 */

void
handle_window(msgbuff)
	int *msgbuff;
{
	WINDOW *v;

	v = which_window(msgbuff[3]);
	if (!v) {	/* hmmm, not our window? */
		return;
	}

	switch(msgbuff[0]) {
	case WM_REDRAW:
		redraw_window(v, msgbuff[4], msgbuff[5], msgbuff[6], msgbuff[7]);
		break;
	case WM_TOPPED:
		(*v->topped)(v);
		break;
	case WM_SIZED:
		(*v->sized)(v, msgbuff[4], msgbuff[5], msgbuff[6], msgbuff[7]);
		break;
	case WM_MOVED:
		(*v->moved)(v, msgbuff[4], msgbuff[5], msgbuff[6], msgbuff[7]);
		break;
	case WM_FULLED:
		(*v->fulled)(v);
		break;
	case WM_ARROWED:
		(*v->arrowed)(v, msgbuff[4]);
		break;
	case WM_HSLID:
		(*v->hslid)(v, msgbuff[4]);
		break;
	case WM_VSLID:
		(*v->vslid)(v, msgbuff[4]);
		break;
	case WM_CLOSED:
		(*v->closed)(v);
		break;
	}
}

int
window_key(keycode, shift)
	int keycode, shift;
{
	MENU *m;
	ENTRY *e;
	WINDOW *w;

	w = focuswin;	/* set in evnt_loop */

	if (w) {
/* first, check for window specific menu shortcut keys */
		for (m = w->menu; m; m = m->next) {
			for (e = m->contents; e; e = e->next) {
				if (e->keycode == keycode) {
					(*e->func)(e->arg);
					return 1;
				}
			}
		}

/* otherwise, pass the key along to the general window handling thing */
		return (*w->keyinp)(w, keycode, shift);
	}
	else
		return 0;
}

int
window_click(clicks, x, y, kshift, mbutton)
	int clicks, x, y, kshift, mbutton;
{
	WINDOW *w;

/* find the window that got clicked in (if any) */
	w = find_window(x, y);
	if (w) {
		return (*w->mouseinp)(w, clicks, x, y, kshift, mbutton);
	}
	return 0;
}

/*
 * close and delete all windows
 */

void
end_windows()
{
	WINDOW *v;

	v = gl_winlist;
	while (v) {
		gl_winlist = v->next;
		if (v->wi_handle >= 0) {
			wind_close(v->wi_handle);
			wind_delete(v->wi_handle);
		}
		free(v);
		v = gl_winlist;
	}
}

/*
 * force a redraw of a whole window
 */

void
force_redraw(v)
	WINDOW *v;
{
	redraw_window(v, v->wi_x, v->wi_y, v->wi_w, v->wi_h);
	if (v->wtype == TEXT_WIN)
		mark_clean(v->extra);
}

/*
 * find out which window lies under the point (x,y). Returns a pointer
 * to the window, or NULL
 */

WINDOW *
find_window(x, y)
	int x, y;
{
	int wx, wy, ww, wh;
	WINDOW *w;

	wind_update(1);	/* lock the screen -- we don't want it changing */
	for (w = gl_winlist; w; w = w->next) {
		if (w->wi_handle < 0) continue;
		wind_get(w->wi_handle, WF_FIRSTXYWH, &wx, &wy, &ww, &wh);
		while (ww && wh) {
			if (x >= wx && x <= wx + ww &&
			    y >= wy && y <= wy + wh)
				goto found_window;
			wind_get(w->wi_handle, WF_NEXTXYWH, &wx, &wy, &ww, &wh);
		}
	}
found_window:
	wind_update(0);
	return w;	/* w will be null if no window found */
}

void
change_window_gadgets(w, newkind)
	WINDOW *w;
	int newkind;
{
	int reopen = 0;
	int nx, ny, nw, nh;
	int oldflourishes;

	if (newkind == w->wi_kind) return;	/* no change */

	oldflourishes = win_flourishes;
	win_flourishes = 0;

	if (w->wi_handle >= 0) {
		wind_close(w->wi_handle);
		wind_delete(w->wi_handle);
		w->wi_handle = -1;
		reopen = 1;
	}

	wind_calc(WC_WORK, w->wi_kind, w->wi_fullx, w->wi_fully, w->wi_fullw,
			w->wi_fullh, &nx, &ny, &nw, &nh);
	wind_calc(WC_BORDER, newkind, nx, ny, nw, nh, &nx,
			&ny, &w->wi_fullw, &w->wi_fullh);

	if (w->wi_fullw > wdesk)
		w->wi_fullw = wdesk;
	if (w->wi_fullh > hdesk)
		w->wi_fullh = hdesk;

	if (w->wi_fullx < xdesk)
		w->wi_fullx = xdesk;
	if (w->wi_fully < ydesk)
		w->wi_fully = ydesk;

	wind_calc(WC_BORDER, w->wi_kind, w->wi_x, w->wi_y, w->wi_w, w->wi_h,
			&nx, &ny, &nw, &nh);
	if (nw > w->wi_fullw)
		nw = w->wi_fullw;
	if (nh > w->wi_fullh)
		nh = w->wi_fullh;

	wind_calc(WC_WORK, newkind, nx, ny, nw, nh, &w->wi_x, &w->wi_y,
			&w->wi_w, &w->wi_h);

	w->wi_kind = newkind;

	if (reopen) {
		open_window(w);
	}
	win_flourishes = oldflourishes;
}

/*
 * new_topwin: reset the top window so that it doesn't match the current
 * top window (if that's possible). If force == 0, then we allow the current
 * window to remain on top, otherwise we pretend that no window is on
 * top
 */

void
new_topwin(force)
	int force;
{
	WINDOW *w;
	int mbuf[8];

	w = gl_topwin;
	if (!w) return;
	for(;;) {
		w = w->next;
		if (!w) w = gl_winlist;
		if (w->wi_handle >= 0 && !(w->flags & WICONIFIED)) break;
		if (w == gl_topwin) break;
	}
	if (w != gl_topwin) {
		mbuf[0] = WM_TOPPED;
		mbuf[1] = gl_apid;
		mbuf[2] = 0;
		mbuf[3] = w->wi_handle;
		mbuf[4] = mbuf[5] = mbuf[6] = mbuf[7] = 0;
		appl_write(gl_apid, 16, mbuf);
	} else if (force) {
		gl_topwin = 0;
	}
}

/* set a window title */

void
title_window(w, title)
	WINDOW *w; char *title;
{
	if (w->wi_title)
		free(w->wi_title);
	w->wi_title = strdup(title);
	if (w->wi_handle >= 0 && (w->wi_kind & NAME)) {
		wind_set(w->wi_handle, WF_NAME, w->wi_title);
	}
}
