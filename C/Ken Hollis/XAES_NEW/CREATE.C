/********************************************************************
 *																2.01*
 *	XAES: Window creation routines									*
 *	Code by Ken Hollis, GNU C Extensions by Sascha Blank			*
 *																	*
 *	Copyright (c) 1994, Bitgate Software.  All Rights Reserved.		*
 *																	*
 *	Again, most of these routines were taken from WinLIB PRO, but	*
 *	they have been revamped and greatly optimized.  Any convoluted	*
 *	code is my fault.  :-)											*
 *																	*
 ********************************************************************/

#include <string.h>
#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>

#include "xaes.h"
#include "treecopy.h"

GRECT desk;
WINDOW *WindowChain;
int Life, Return, VDIhandle, Ap_ID;
OBJECT *wl_menubar = NULL;

int gr_cw, gr_ch, gr_bw, gr_bh;
int small_font, large_font, color_font;
int num_colors, num_planes;
int image_w, image_h, big_img;
char *prgnameheader;

WOWNERS	owned_winds[MAX_WINDOWS];

#ifdef TURBO_C
#pragma warn -pia
#endif

/*
 *	A complete replacement for wind_set, only smarter.
 */
GLOBAL int WWindSet(WINDOW *win, int wi_sfield, ...)
{
	va_list	argptr;
	int wi_sw1, wi_sw2, wi_sw3, wi_sw4;
	long wi_sl1;

	switch (wi_sfield) {
		case WF_TOP:
			wind_set(win->handle, WF_TOP);
			if (win->prev)									/* Bring window to top of WindowChain */
				win->prev->next = win->next;

			win->next->prev = win->prev;
		
			if (WindowChain == win)
				WindowChain = win->next;
		
			WindowChain->prev = win;
			win->next = WindowChain;
			win->prev = NULL;
			WindowChain = win;
			return TRUE;

		case WF_BEVENT:
		case WF_MINIMIZE:
		case WF_UNUNTOPPABLE:
			va_start(argptr, wi_sfield);
			wi_sw1 = va_arg(argptr, int);
			va_end(argptr);

			if (win)
				switch (wi_sfield) {
					case WF_BEVENT:
						if (AES_VERSION >= 0x0400)
							wind_set(win->handle, WF_BEVENT, wi_sw1 ? 1 : 0);

						if (xaes.config2 & X_BACKGROUND) {
							if (wi_sw1)
								win->state |= W_BEVENT;
							else
								win->state &= ~W_BEVENT;
							return TRUE;
						} else
							return FALSE;

					case WF_MINIMIZE:
						if (wi_sw1)
							win->state |= W_MINIMIZED;
						else
							win->state &= ~W_MINIMIZED;

						WWindSet(win, WF_CURRXYWH, -1, -1, -1, win->size.g_h);
						return TRUE;

					case WF_UNUNTOPPABLE:
						if (wi_sw1)
							win->state |= W_UNUNTOPPABLE;
						else
							win->state &= ~W_UNUNTOPPABLE;

						WWindSet(win, WF_TOP);
						return TRUE;
				}

		case WF_TIMER:
			va_start(argptr, wi_sfield);
			wi_sw1 = va_arg(argptr, int);
			va_end(argptr);

			if ((wi_sw1) && (win))
				win->state |= W_TIMER;
			else
				win->state &= ~W_TIMER;

			return TRUE;

		case WF_DIALOG:
			va_start(argptr, wi_sfield);
			wi_sw1 = va_arg(argptr, int);
			va_end(argptr);

			if ((wi_sw1) && (win))
				win->state |= W_DIALOG;
			else
				win->state &= ~W_DIALOG;

			return TRUE;

		case WF_UNSIZABLE:
			va_start(argptr, wi_sfield);
			wi_sw1 = va_arg(argptr, int);
			va_end(argptr);

			if ((wi_sw1) && (win))
				win->state |= W_UNSIZABLE;
			else
				win->state &= ~W_UNSIZABLE;

			return TRUE;

		case WF_CUSTOMWIN:
			va_start(argptr, wi_sfield);
			wi_sw1 = va_arg(argptr, int);
			va_end(argptr);

			if ((wi_sw1) && (win))
				win->style |= W_CUSTOMWINDOW;
			else
				win->style &= ~W_CUSTOMWINDOW;

			return TRUE;

		case WF_ICONIFIED:
			va_start(argptr, wi_sfield);
			wi_sw1 = va_arg(argptr, int);
			va_end(argptr);

			if ((wi_sw1) && (win) && (win->iconify)) {
				win->size.g_w = win->iconify->ob_width;
				win->size.g_h = win->iconify->ob_height;

				win->oldstate = win->state;
				win->oldstyle = win->style;
				win->oldkind = win->kind;

				win->style = 0;
				win->state = W_OPEN | W_BEVENT | W_DIALOG | W_ICONIFIED;
				win->kind = NAME|MOVER;

				win->iconify->ob_x = win->tree->ob_x;
				win->iconify->ob_y = win->tree->ob_y;

				win->oldsize.g_x = win->size.g_x;
				win->oldsize.g_y = win->size.g_y;
				win->oldsize.g_w = win->size.g_w;
				win->oldsize.g_h = win->size.g_h;

				WMoveWindow(win, -1, -1, -1, -1);

				WGrafMouse(ARROW);
				wind_close(win->handle);
				wind_delete(win->handle);

				wind_create(win->kind, win->size.g_x, win->size.g_y, win->iconify->ob_width, win->iconify->ob_height + 13);

				WWindSet(win, WF_KIND, win->kind);
				wind_open(win->handle, win->size.g_x, win->size.g_y, win->iconify->ob_width, win->iconify->ob_height + 13);

				WWindSet(win, WF_CURRXYWH, win->size.g_x, win->size.g_y, win->iconify->ob_width, win->iconify->ob_height + 13);
				WWindSet(win, WF_BEVENT, 1);
				WWindSet(win, WF_DIALOG, 1);

				WRedrawWindow(win, win->size.g_x, win->size.g_y, win->iconify->ob_width, win->iconify->ob_height + 13);
				vswr_mode(VDIhandle, MD_XOR);
			}

			return TRUE;

		case WF_UNICONIFIED:
			va_start(argptr, wi_sfield);
			wi_sw1 = va_arg(argptr, int);
			va_end(argptr);

			if ((wi_sw1) && (win) && (win->iconify)) {
				win->size.g_w = win->tree->ob_width;
				win->size.g_h = win->tree->ob_height;

				win->state = win->oldstate;
				win->style = win->oldstyle;
				win->kind = win->oldkind;

				win->state &= ~W_ICONIFIED;

				win->tree->ob_x = win->iconify->ob_x;
				win->tree->ob_y = win->iconify->ob_y;

				WGrafMouse(ARROW);
				wind_close(win->handle);
				wind_delete(win->handle);

				win->size.g_x = win->oldsize.g_x;
				win->size.g_y = win->oldsize.g_y;
				win->size.g_w = win->oldsize.g_w;
				win->size.g_h = win->oldsize.g_h;

				if (win->style & W_CUSTOMWINDOW)
					wind_create(0, win->wind->ob_x, win->wind->ob_y, win->wind->ob_width, win->wind->ob_height);
				else
					wind_create(win->kind, win->size.g_x, win->size.g_y, win->size.g_w, win->size.g_h);

				if (!(win->style & W_CUSTOMWINDOW))
					WWindSet(win, WF_KIND, win->kind);

				wind_open(win->handle, win->size.g_x, win->size.g_y, win->size.g_w, win->size.g_h);

				WWindSet(win, WF_CURRXYWH, win->size.g_x, win->size.g_y, win->size.g_w, win->size.g_h);
				WWindSet(win, WF_BEVENT, 1);
				WWindSet(win, WF_DIALOG, 1);

				vswr_mode(VDIhandle, MD_XOR);
			}

			return TRUE;

		case WF_NAME:
		case WF_INFO:
			va_start(argptr, wi_sfield);
			wi_sl1 = va_arg(argptr, long);
			va_end(argptr);

			if (win)
				switch (wi_sfield) {
					case WF_NAME:
						if (win->state & W_DIALOG)
							sprintf(win->title, "[ %s%s ]", prgnameheader, wi_sl1);
						else
							sprintf(win->title, "%s%s", prgnameheader, wi_sl1);

						return wind_set(win->handle, WF_NAME, win->title);

					case WF_INFO:
						if (wi_sl1 != 0L)
							strncpy(win->info, (char *) wi_sl1, 128);
						else
							strncpy(win->info, " ", 128);

						return wind_set(win->handle, WF_INFO, win->info);
				}

		default:
			va_start(argptr, wi_sfield);
			wi_sw1 = va_arg(argptr, int);
			wi_sw2 = va_arg(argptr, int);
			wi_sw3 = va_arg(argptr, int);
			wi_sw4 = va_arg(argptr, int);
			va_end(argptr);

			if (win)
				switch (wi_sfield) {
					case WF_CURRXYWH:
						WMoveWindow(win, wi_sw1, wi_sw2, wi_sw3, wi_sw4);
						return TRUE;

					case WF_WORKXYWH:		/* Can't set work! */
						return FALSE;

					default:
						return wind_set(win->handle, wi_sfield, wi_sw1, wi_sw2, wi_sw3, wi_sw4);
				}
	}

	return FALSE;
}

/*
 *	A replacement for wind_get, only better.
 */
GLOBAL int WWindGet(WINDOW *win, int wi_gfield, ...)
{
	va_list	argptr;
	int ret, *wi_gw1, *wi_gw2, *wi_gw3, *wi_gw4;
	
	va_start(argptr, wi_gfield);
	wi_gw1 = va_arg(argptr, int *);
	wi_gw2 = va_arg(argptr, int *);
	wi_gw3 = va_arg(argptr, int *);
	wi_gw4 = va_arg(argptr, int *);
	va_end(argptr);

	if (win)
		switch (wi_gfield) {
			case WF_WORKXYWH:
				{
					int x, y, w, h;

					if ((win->handle == 0) && (win->state & W_OPEN) && !(win->style & W_CUSTOMWINDOW))
						ret = wind_get(win->handle, WF_WORKXYWH, wi_gw1, wi_gw2, wi_gw3, wi_gw4);
					else
						if (win->state & W_OPEN)
							if (ret = wind_get(win->handle, WF_WORKXYWH, &x, &y, &w, &h)) {
								if (win->style & W_CUSTOMWINDOW) {
									x += (win->wind_type == WC_WINDOW) ? win->wind[25].ob_x : win->wind[32].ob_x;
									y += (win->wind_type == WC_WINDOW) ? win->wind[25].ob_y : win->wind[32].ob_y;
									w = (win->wind_type == WC_WINDOW) ? win->wind[25].ob_width : win->wind[32].ob_width;
									h = (win->wind_type == WC_WINDOW) ? win->wind[25].ob_height : win->wind[32].ob_height;
								}

								wi_gw1 = (int *) x;
								wi_gw2 = (int *) y;
								wi_gw3 = (int *) w;
								wi_gw4 = (int *) h;

								ret = TRUE;
							}
				}

				return ret;

			default:
				if (win->state & W_OPEN)
					return wind_get(win->handle, wi_gfield, wi_gw1, wi_gw2, wi_gw3, wi_gw4);
		}

	return FALSE;
}

/*
 *	This reserves screen memory for the window about to be opened,
 *	and checks internal handles to make sure it can be opened.
 */
GLOBAL int WOpenWindow(WINDOW *win)
{
	if (win) {
		if (!(win->state & W_OPEN) && !(wind_open(win->handle, win->size.g_x, win->size.g_y, win->size.g_w, win->size.g_h)))
			return FALSE;
		else
			win->state |= W_OPEN;				/* Set state to "open" */

		owned_winds[win->handle].handle = win->handle;
		owned_winds[win->handle].owner  = Ap_ID;

		return TRUE;
	} else
		return FALSE;
}

/*
 *	This closes a window without killing it.
 */
GLOBAL void WCruelCloseWindow(WINDOW *win, BOOL icon)
{
	UNUSED(icon);

	if (!win)
		win = WindowChain;

	if (win)
		if (win->next && win->state & W_OPEN && wind_close(win->handle)) {
			WGrafMouse(ARROW);
			win->state &= ~W_OPEN;

			if ((win->state & W_ICONIFIED) && (win->iconify)) {
				graf_shrinkbox(desk.g_w / 2, desk.g_h / 2, 2, 2, win->size.g_x, win->size.g_y, win->iconify->ob_width, win->iconify->ob_height + 13);
				vswr_mode(VDIhandle, MD_XOR);
			} else {
				graf_shrinkbox(desk.g_w / 2, desk.g_h / 2, 2, 2, win->size.g_x, win->size.g_y, win->size.g_w, win->size.g_h);
				vswr_mode(VDIhandle, MD_XOR);
			}

			return;
		}
}

/*
 *	This gives the signal to kill (delete) a window.
 */
GLOBAL void WKillWindow(WINDOW *win)
{
	int msg_buf[8];

	if (!win)
		win = WindowChain;

	if (win)
		if (win->next) {
			msg_buf[0] = WM_KILL;
			msg_buf[1] = Ap_ID;
			msg_buf[2] = 0;
			msg_buf[3] = win->handle;
	
			WMsgWindow(win, msg_buf);
		}
}

/*
 *	This creates the window on the screen, but does not draw it.
 */
GLOBAL int WWindCreate(WINDOW *win)
{
	if (win)
		if (win->style & W_CUSTOMWINDOW) {
			WWindAdjust(win);
			return (wind_create(0, win->size.g_x, win->size.g_y, win->size.g_w, win->size.g_h));
		} else
			return (wind_create(win->kind, win->size.g_x, win->size.g_y, win->size.g_w, win->size.g_h));
	else
		return FALSE;
}

/*
 *	This creates an object as defined in the XAES documentation, and
 *	online help.  I'm not about to document every feature of this
 *	routine; it would take a chapter in a book.
 */
GLOBAL void *WCreateObject(int type, ...)
{
	va_list	argptr;
	WINDOW *ptr;

	if (type == WC_WINDOW) {
		int state, style, kind, x, y, w, h, edobject, icon;
		void *WndDispatcher;
		char *title, *info, *icontext;
		OBJECT *object, *iconify;
		CALLS *callbacks;

		va_start(argptr, wi_gfield);
		state = va_arg(argptr, int);
		style = va_arg(argptr, int);
		kind = va_arg(argptr, int);
		title = va_arg(argptr, char *);
		info = va_arg(argptr, char *);
		object = va_arg(argptr, OBJECT *);
		WndDispatcher = va_arg(argptr, void *);
		x = va_arg(argptr, int);
		y = va_arg(argptr, int);
		w = va_arg(argptr, int);
		h = va_arg(argptr, int);
		edobject = va_arg(argptr, int);
		iconify = va_arg(argptr, OBJECT *);
		icon = va_arg(argptr, int);
		icontext = va_arg(argptr, char *);
		callbacks = va_arg(argptr, CALLS *);
		va_end(argptr);

		UNUSED(style);

		if (ptr = (WINDOW *) malloc(sizeof(WINDOW))) {
			int msg_buf[8];

			ptr->wind_type = type;
			ptr->state = 0;
			ptr->style = 0;
			ptr->kind = kind;
			ptr->editmode = EDIT_INSERT;
			ptr->edobject = edobject;

			ptr->timer.clock = 0L;
			ptr->timer.ev_mtcount = 0;
			ptr->timer.user = NULL;
			ptr->timer.status = T_NOTEXIST;
			ptr->timer.tick_count = 0;
			ptr->infpos = 0;
			ptr->infend = 0;

			ptr->callbacks = NULL;

			if (callbacks != NULL)
				ptr->callbacks = callbacks;

			if (ptr->edobject != 0) {
				ptr->edpos = 0;
				ptr->has_edit = TRUE;
				ptr->edit_disp = TRUE;
			} else {
				ptr->edpos = 0;
				ptr->has_edit = FALSE;
				ptr->edit_disp = FALSE;
			}

			ptr->WndDispatcher = malloc(sizeof(WndDispatcher));
			ptr->WndDispatcher = WndDispatcher;

			if (style & W_CUSTOMWINDOW)
				WWindSet(ptr, WF_CUSTOMWIN, 1);

			if (iconify) {
				ptr->iconify = tree_copy(iconify, C_ICONBLKPOINTER);

				if (icontext) {
					ptr->iconify[icon].ob_spec.iconblk->ib_ptext = icontext;
					ptr->icon_num = icon;
					ptr->icon_text = icontext;
				} else {
					ptr->iconify[icon].ob_spec.iconblk->ib_ptext = NULL;
					ptr->icon_num = icon;
					ptr->icon_text = NULL;
				}
			} else {
				ptr->iconify = NULL;
				ptr->icon_num = 0;
				ptr->icon_text = NULL;
			}

			{
				int x2, y2, w2, h2;

				ptr->tree = tree_copy(object, C_TEDINFOPOINTER|C_ICONBLKPOINTER|C_BITBLKPOINTER|C_TITLEBUTTONSTRING);
				fix_object(ptr->tree, FALSE, FALSE);

				if (ptr->style & W_CUSTOMWINDOW) {
					ptr->wind = tree_copy(WINDTREE, C_TEDINFOPOINTER|C_ICONBLKPOINTER|C_BITBLKPOINTER|C_TITLEBUTTONSTRING);

					fix_object(ptr->wind, TRUE, FALSE);
					form_center(ptr->wind, &x2, &y2, &w2, &h2);

					x2 += abs(ptr->wind->ob_spec.obspec.framesize);
					y2 += abs(ptr->wind->ob_spec.obspec.framesize);
					w2 -= abs(ptr->wind->ob_spec.obspec.framesize) * 2;
					h2 -= abs(ptr->wind->ob_spec.obspec.framesize) * 2;

					wind_calc(WC_BORDER, /*ptr->kind,*/ 0, x2, y2, w2, h2, &x2, &y2, &w2, &h2);
				} else {
					form_center(ptr->tree, &x2, &y2, &w2, &h2);

					x2 += abs(ptr->tree->ob_spec.obspec.framesize);
					y2 += abs(ptr->tree->ob_spec.obspec.framesize);
					w2 -= abs(ptr->tree->ob_spec.obspec.framesize) * 2;
					h2 -= abs(ptr->tree->ob_spec.obspec.framesize) * 2;

					wind_calc(WC_BORDER, ptr->kind, x2, y2, w2, h2, &x2, &y2, &w2, &h2);
				}

				x = (x != -1) ? x : x2;
				y = (y != -1) ? y : y2;
				w = (w != -1) ? w : w2;
				h = (h != -1) ? h : h2;
			}

			ptr->size.g_x = x;
			ptr->size.g_y = y;
			ptr->size.g_w = w;
			ptr->size.g_h = h;

			ptr->size.g_x += 1;
			ptr->size.g_y += 1;
			ptr->size.g_w -= 2;
			ptr->size.g_h -= 2;

			if ((ptr->handle = WWindCreate(ptr)) < 0) {
				free(ptr);
#ifdef DEBUG
				form_alert(1, "[3][Cannot create window:| |No free window handles.][ OK ]");
#endif
				return NULL;
			}

			if ((xaes.wind_center == XW_SCREENCENTER) ||
				(xaes.wind_center == XW_PHYSICCENTER)) {
				ptr->size.g_x = (((desk.g_w) - (ptr->size.g_w)) / 2);
				ptr->size.g_y = (((desk.g_h) - (ptr->size.g_h)) / 2);
			}

			if (xaes.wind_center == XW_MOUSECENTER) {
				int x, y, d;

				graf_mkstate(&x, &y, &d, &d);
				ptr->size.g_x = x - (ptr->size.g_w / 2);
				ptr->size.g_y = y - (ptr->size.g_h / 2);

				if (ptr->size.g_x < 0)
					ptr->size.g_x = 0;

				if (ptr->size.g_y < 0)
					ptr->size.g_y = 0;
			}

			ptr->size.g_x += desk.g_x;
			ptr->size.g_y += desk.g_y;

			WindowChain->prev = ptr;					/* Insert window in chain */
			ptr->next = WindowChain;
			ptr->prev = NULL;
			WindowChain = ptr;

			graf_growbox(desk.g_w / 2, desk.g_h / 2, 2, 2, ptr->size.g_x, ptr->size.g_y, ptr->size.g_w, ptr->size.g_h);

			if (info)
				WWindSet(ptr, WF_INFO, info);

			if (state & W_OPEN)
				if (!(WOpenWindow(ptr)))
					return NULL;

			{
				int x, y, w, h;

				WWindGet(ptr, WF_WORKXYWH, &x, &y, &w, &h);

				ptr->tree->ob_x = x;
				ptr->tree->ob_y = y;
			}

			if (state & W_UNUNTOPPABLE)
				WWindSet(ptr, WF_UNUNTOPPABLE, 1);

			if (state & W_BEVENT)
				WWindSet(ptr, WF_BEVENT, 1);

			if (state & W_TIMER)
				WWindSet(ptr, WF_TIMER, 1);

			if (state & W_DIALOG)
				WWindSet(ptr, WF_DIALOG, 1);

			if (state & W_UNSIZABLE)
				WWindSet(ptr, WF_UNSIZABLE, 1);

			if (title)
				WWindSet(ptr, WF_NAME, title);

			ptr->minimum.g_x = ptr->size.g_x;
			ptr->minimum.g_y = ptr->size.g_y;
			ptr->minimum.g_w = ptr->size.g_w;
			ptr->minimum.g_h = ptr->size.g_h;

			if (!(ptr->state & W_UNSIZABLE)) {
				ptr->maximum.g_w = desk.g_w;
				ptr->maximum.g_h = desk.g_h;
			} else {
				ptr->maximum.g_w = ptr->minimum.g_w;
				ptr->maximum.g_h = ptr->minimum.g_h;
			}

			if (style & W_CUSTOMWINDOW) {
				WCreateObject(WC_SLIDER, ptr->wind, 0, 150, 10, SLIDER_VER, 16, 28, 27, 26);
				WCreateObject(WC_SLIDER, ptr->wind, 0, 150, 10, SLIDER_HOR, 31, 30, 29, 12);
			}

			vsl_color(VDIhandle, BLACK);

			msg_buf[0] = WM_CREATED;
			msg_buf[1] = Ap_ID;
			msg_buf[2] = 0;
			msg_buf[3] = ptr->handle;
			WMsgWindow(ptr, msg_buf);

			ptr->user = NULL;

			msg_buf[0] = WM_COPIED;
			msg_buf[1] = Ap_ID;
			msg_buf[2] = 0;
			msg_buf[3] = ptr->handle;
			WMsgWindow(ptr, msg_buf);

			return ptr;
		} else {
#ifdef DEBUG
			form_alert(1, "[3][Cannot create window:| |No free memory.][ OK ]");
#endif
			return NULL;
		}
	}

	if (type == WC_SLIDER) {
		SLIDER slider;
		OBJECT *obj;
		EXTINFO *ex;

		va_start(argptr, wi_gfield);
		obj = va_arg(argptr, OBJECT *);
		slider.slide_pos = va_arg(argptr, int);
		slider.slide_max = va_arg(argptr, int);
		slider.slide_tstep = va_arg(argptr, int);
		slider.slide_type = va_arg(argptr, int);
		slider.slide_increase = va_arg(argptr, int);
		slider.slide_slider = va_arg(argptr, int);
		slider.slide_track = va_arg(argptr, int);
		slider.slide_decrease = va_arg(argptr, int);
		va_end(argptr);

		if (((obj[slider.slide_increase].ob_type & 0xFF) == G_USERDEF) &&
			((obj[slider.slide_decrease].ob_type & 0xFF) == G_USERDEF) &&
			((obj[slider.slide_slider].ob_type & 0xFF) == G_USERDEF) &&
			((obj[slider.slide_track].ob_type & 0xFF) == G_USERDEF)) {
			double sldperc = ((slider.slide_type == SLIDER_HOR) ? (double)(obj[slider.slide_slider].ob_width) : (double)(obj[slider.slide_slider].ob_height)) /
							 ((slider.slide_type == SLIDER_HOR) ? (double)(obj[slider.slide_track].ob_width) : (double)(obj[slider.slide_track].ob_height));
			int newpos     = (int)((double)(sldperc) * (double)(slider.slide_max));

			ex = (EXTINFO *)(obj[slider.slide_increase].ob_spec.userblk->ub_parm);
			ex->te_slider = slider;
			ex = (EXTINFO *)(obj[slider.slide_decrease].ob_spec.userblk->ub_parm);
			ex->te_slider = slider;
			ex = (EXTINFO *)(obj[slider.slide_slider].ob_spec.userblk->ub_parm);
			ex->te_slider = slider;
			ex = (EXTINFO *)(obj[slider.slide_track].ob_spec.userblk->ub_parm);
			ex->te_slider = slider;

			if (slider.slide_type == SLIDER_HOR) {
				obj[slider.slide_slider].ob_x = 0;
				obj[slider.slide_slider].ob_width = obj[slider.slide_track].ob_width - (newpos + slider.slide_max);

				if (obj[slider.slide_slider].ob_width < (gr_cw * 4))
					obj[slider.slide_slider].ob_width = (gr_cw * 4);
			} else {
				obj[slider.slide_slider].ob_y = 0;
				obj[slider.slide_slider].ob_height = obj[slider.slide_track].ob_height - (newpos + slider.slide_max);

				if (obj[slider.slide_slider].ob_height < gr_ch)
					obj[slider.slide_slider].ob_height = gr_ch;
			}

			slider.slide_pos = 0;
			slider.slide_step = ((long)((slider.slide_type == SLIDER_HOR) ? obj[slider.slide_track].ob_width : obj[slider.slide_track].ob_height) -
									   (((slider.slide_type == SLIDER_HOR) ? obj[slider.slide_slider].ob_width : obj[slider.slide_slider].ob_height) << 16)) /
										(long) slider.slide_max;
			slider.slide_acc = 0;

			ex = (EXTINFO *)(obj[slider.slide_increase].ob_spec.userblk->ub_parm);
			ex->te_slider = slider;
			ex = (EXTINFO *)(obj[slider.slide_decrease].ob_spec.userblk->ub_parm);
			ex->te_slider = slider;
			ex = (EXTINFO *)(obj[slider.slide_slider].ob_spec.userblk->ub_parm);
			ex->te_slider = slider;
			ex = (EXTINFO *)(obj[slider.slide_track].ob_spec.userblk->ub_parm);
			ex->te_slider = slider;

			return ((void *) TRUE);
		}

#ifdef DEBUG
		form_alert(1, "[3][Slider not created:| |One or more objects are|not G_USERDEF type.][ OK ]");
#endif
		return ((void *) FALSE);
	}

	if (type == WC_POPUP) {
		POPUP popup;
		OBJECT *obj;
		EXTINFO *ex;
		int object;

		va_start(argptr, wi_gfield);
		obj = va_arg(argptr, OBJECT *);
		object = va_arg(argptr, int);
		popup.curr_sel = 0;
		popup.sel_text = va_arg(argptr, char *);

		if ((obj[object].ob_type & 0xFF) == G_USERDEF) {
			ex = (EXTINFO *)(obj[object].ob_spec.userblk->ub_parm);

			ex->te_popup = popup;

			return ((void *) TRUE);
		}

#ifdef DEBUG
		form_alert(1, "[3][Cannot create popup:| |One or more objects|are not G_USERDEF][ OK ]");
#endif
		return ((void *) FALSE);
	}

	if (type == WC_LISTBOX) {
	}

	return ((void *) FALSE);
}

/*
 *	This is a routine to let you top a window.
 */
GLOBAL void WTopWindow(WINDOW *win)
{
	if (!win) {
		if ((win = WindowChain)->next)
			while (win->next->next)
				win = win->next;
		else
			return;
	}

	WWindSet(win, WF_TOP, win->handle);
}

/*
 *	This lets you manually specify the area of a window to be redrawn
 */
GLOBAL void WRedrawWindow(WINDOW *win, int x, int y, int w, int h)
{
	int msg_buf[8];

	if (win) {
		msg_buf[0] = WM_REDRAW;
		msg_buf[1] = Ap_ID;
		msg_buf[2] = 0;
		msg_buf[3] = win->handle;
		msg_buf[4] = x;
		msg_buf[5] = y;
		msg_buf[6] = w;
		msg_buf[7] = h;

		WMsgWindow(win, msg_buf);
	}
}

/*
 *	This closes, deletes and frees all windows in the WindowChain.
 */
GLOBAL void WKillAllWindows(int check)
{
	WINDOW *win = WindowChain;
	int msg_buf[8] = {WM_CLOSEALL, 0, 0, 0, 0, 0, 0, 0};
	int msg_buf2[8] = {WM_PROGEND, 0, 0, 0, 0, 0, 0, 0};

	msg_buf[3] = check;

	if (win)
		if ((WCallEtcDispatcher(msg_buf)) || check == K_NO_STOP) {
			while (win->next) {
				win = win->next;
				WCloseWindow(win->prev, WC_NOTOBJECTABLE, K_NO_STOP);
			}

			while (WindowChain->next)
				WKillWindow(WindowChain);

			WCallEtcDispatcher(msg_buf2);
		}

	vswr_mode(VDIhandle, MD_XOR);
}

/*
 *	This closes a window, with a specific type of priority.
 */
GLOBAL void WCloseWindow(WINDOW *win, int message, int priority)
{
	int msg_buf[8];

	if (!win)
		win = WindowChain;

	if (win)
		if (win->next) {
			msg_buf[0] = WM_CLOSED;
			msg_buf[1] = Ap_ID;
			msg_buf[2] = 0;
			msg_buf[3] = win->handle;
			msg_buf[4] = message;
			msg_buf[5] = priority;

			WMsgWindow(win, msg_buf);
		}
}