/*
 * Xdialog Library. Copyright (c) 1993, 1994, 2002 W. Klaren.
 *
 * This file is part of Teradesk.
 *
 * Teradesk is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * Teradesk is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Teradesk; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#ifdef __PUREC__
 #include <np_aes.h>
 #include <vdi.h>
#else
 #include <aesbind.h>
 #include <vdibind.h>
#endif

#include <stddef.h>

#include "xdialog.h"

#include "internal.h"

#define XD_NMWDFLAGS	(NAME | CLOSER | MOVER)

typedef struct
{
	XW_INTVARS;
	XDINFO *xd_info;
	int nkeys;
	KINFO kinfo[MAXKEYS];
} XD_NMWINDOW;

extern void __xd_redraw(WINDOW *w, RECT *area);
extern void __xd_moved(WINDOW *w, RECT *newpos);

static int __xd_hndlkey(WINDOW *w, int key, int kstate);
static void __xd_hndlbutton(WINDOW *w, int x, int y, int n, int bstate, int kstate);
static void __xd_topped(WINDOW *w);
static void __xd_closed(WINDOW *w);
static void __xd_hndlmenu(WINDOW *w, int title, int item);
static void __xd_top(WINDOW *w);

static WD_FUNC xd_wdfuncs =
{
	__xd_hndlkey,
	__xd_hndlbutton,
	__xd_redraw,
	__xd_topped,
	0L,
	__xd_closed,
	0L,
	0L,
	0L,
	0L,
	0L,
	__xd_moved,
	__xd_hndlmenu,
	__xd_top
};

/*
 * Funktie voor het afhandelen van een keyboard event in een
 * niet modale dialoogbox.
 */

#pragma warn -par

static int __xd_hndlkey(WINDOW *w, int key, int kstate)
{
	int next_obj, nkeys, kr;
	int cont, key_handled = TRUE;
	XDINFO *info = ((XD_NMWINDOW *)w)->xd_info;
	KINFO *kinfo;
	OBJECT *tree = info->tree;

	xd_wdupdate(BEG_UPDATE);

	nkeys = ((XD_NMWINDOW *)w)->nkeys;
	kinfo = ((XD_NMWINDOW *)w)->kinfo;

	if ((next_obj = xd_find_key(tree, kinfo, nkeys, key)) >= 0)
		cont = xd_form_button(info, next_obj, 1, &next_obj);
	else
	{
		cont = xd_form_keybd(info, 0, key, &next_obj, &kr);
		if (kr)
			key_handled = xd_edit_char(info, kr);
	}

	if (cont)
	{
		if (next_obj != 0)
			xd_edit_init(info, next_obj, -1);
		xd_wdupdate(END_UPDATE);
	}
	else
	{
		xd_wdupdate(END_UPDATE);
		info->func->dialbutton(info, next_obj);
	}

	return key_handled;
}

#pragma warn .par

/*
 * Funktie voor het afhandelen van een button event in een
 * niet modale dialoogbox.
 */

#pragma warn -par

static void __xd_hndlbutton(WINDOW *w, int x, int y, int n, int bstate, int kstate)
{
	XDINFO *info = ((XD_NMWINDOW *)w)->xd_info;
	int next_obj, cmode;
	int cont;

	if ((next_obj = objc_find(info->tree, ROOT, MAX_DEPTH, x, y)) != -1)
	{
		xd_wdupdate(BEG_UPDATE);

		if ((cont = xd_form_button(info, next_obj, n, &next_obj)) != FALSE)
			cmode = x;

		if (cont)
		{
			if (next_obj != 0)
				xd_edit_init(info, next_obj, cmode);
			xd_wdupdate(END_UPDATE);
		}
		else
		{
			xd_wdupdate(END_UPDATE);
			info->func->dialbutton(info, next_obj);
		}
	}
}

#pragma warn .par

/*
 * Funktie voor het afhandelen van een window topped event in een
 * niet modale dialoogbox.
 */

static void __xd_topped(WINDOW *w)
{
	xw_set(w, WF_TOP);
}

/*
 * Funktie voor het afhandelen van een window closed event in een
 * niet modale dialoogbox.
 */

static void __xd_closed(WINDOW *w)
{
	XDINFO *info = ((XD_NMWINDOW *)w)->xd_info;

	info->func->dialclose(info);
}

/*
 * Funktie die wordt aangeroepen als een menu van de niet-modale
 * dialoogbox geselekteerd is.
 */

static void __xd_hndlmenu(WINDOW *w, int title, int item)
{
	XDINFO *info = ((XD_NMWINDOW *)w)->xd_info;

	info->func->dialmenu(info, title, item);
}

/*
 * Funktie die wordt aangeroepen als een dialoogbox het bovenste
 * window van een applicatie is geworden.
 */

static void __xd_top(WINDOW *w)
{
	XDINFO *info = ((XD_NMWINDOW *)w)->xd_info;

	if(info->func->dialtop != 0L)
		info->func->dialtop(info);
}

/*
 * Create a non-modal dailogbox.
 *
 * Parameters:
 *
 * tree		- Object tree of the dialogbox
 * info		- Pointer to a XDINFO structure
 * funcs	- Pointer to a XD_NMFUNCS structure
 * start	- First edit object (as in form_do)
 * x		- x position where dialogbox should appear. If -1 the
 *			  library will calculate the position itself.
 * y		- y position where dialogbox should appear. If -1 the
 *			  library will calculate the position itself.
 * menu		- Optional pointer to a object tree, which should be used
 *			  as menu bar in the window. If NULL no menu bar will
 *			  appear in top of the window.
 * xywh		- Optional pointer to a RECT structure. If this pointer
 *			  is not NULL and zoom is not 0, the library will draw
 *			  a zoombox from the rectangle in xywh to the window.
 * zoom		- see xywh
 * title	- Optional title. If not NULL this string is used as the
 *			  title of the window. Otherwise the program name is used.
 *
 * Result: see xdialog.h.
 */

int xd_nmopen(OBJECT *tree, XDINFO *info, XD_NMFUNC *funcs,
			  int start, int x, int y, OBJECT *menu, RECT *xywh,
			  int zoom, const char *title)
{
	int error;
	RECT wsize;
	WINDOW *w;

	xd_wdupdate(BEG_UPDATE);

	info->tree = tree;
	info->dialmode = XD_WINDOW;
	info->edit_object = -1;
	info->cursor_x = 0;
	info->curs_cnt = 1;
	info->func = funcs;

	xd_calcpos(info, NULL, xd_posmode);
	xw_calc(WC_BORDER, XD_NMWDFLAGS, &info->drect, &wsize, menu);

	if ((x != -1) && (y != -1))
	{
		int dx, dy;

		dx = x - wsize.x;

		info->drect.x += dx;
		tree->ob_x += dx;
		wsize.x = x;

		dy = y - wsize.y;

		info->drect.y += dy;
		tree->ob_y += dy;
		wsize.y = y;
	}

	if (wsize.x < xd_desk.x)
	{
		int d = xd_desk.x - wsize.x;

		info->drect.x += d;
		tree->ob_x += d;
		wsize.x = xd_desk.x;
	}

	if (wsize.y < xd_desk.y)
	{
		int d = xd_desk.y - wsize.y;

		info->drect.y += d;
		tree->ob_y += d;
		wsize.y = xd_desk.y;
	}

	if ((w = xw_create(XW_NMDIALOG, &xd_wdfuncs, XD_NMWDFLAGS,
					   &wsize, sizeof(XD_NMWINDOW), menu, &error)) >= 0)
	{
		xw_set(w, WF_NAME, (title == NULL) ? xd_prgname : title);

		info->window = w;
		info->prev = xd_nmdialogs;
		xd_nmdialogs = info;

		((XD_NMWINDOW *)w)->xd_info = info;
		((XD_NMWINDOW *)w)->nkeys = xd_set_keys(tree, ((XD_NMWINDOW *)w)->kinfo);

		start = (start == 0) ? xd_find_obj(tree, 0, FMD_FORWARD) : start;
		xd_edit_init(info, start, -1);

		xw_open(w, &wsize);

		if (zoom && xywh)
		{
			graf_growbox(xywh->x, xywh->y, xywh->w, xywh->h,
						 wsize.x, wsize.y, wsize.w, wsize.h);
			zoom = FALSE;
		}
	}

	xd_wdupdate(END_UPDATE);

	return error;
}

void xd_nmclose(XDINFO *info, RECT *xywh, int zoom)
{
	XDINFO *h = xd_nmdialogs, *prev = NULL;
	WINDOW *w = info->window;

	while (h && (h != info))
	{
		prev = h;
		h = h->prev;	/* eigenlijk h->next. */
	}

	if (h != info)
		return;

	xd_wdupdate(BEG_UPDATE);

	xw_close(w);
	xw_delete(w);

	if (zoom && xywh)
	{
		graf_shrinkbox(xywh->x, xywh->y, xywh->w, xywh->h,
		info->drect.x, info->drect.y, info->drect.w, info->drect.h);
	}

	if (prev == NULL)
		xd_nmdialogs = info->prev;
	else
		prev->prev = info->prev;

	xd_wdupdate(END_UPDATE);
}
