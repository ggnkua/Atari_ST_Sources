/*
 * Teradesk. Copyright (c) 1993, 1994, 2002 W. Klaren.
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

#include <np_aes.h>			/* HR 151102: modern */
#include <stdlib.h>
#include <string.h>
#include <vdi.h>
#include <boolean.h>
#include <mint.h>
#include <xdialog.h>

#include "sprintf.h"		/* HR 240203: get rid of stream io */
#include "copy.h"
#include "desk.h"
#include "error.h"
#include "events.h"
#include "resource.h"
#include "open.h"
#include "showinfo.h"
#include "slider.h"
#include "xfilesys.h"
#include "dir.h"
#include "file.h"
#include "icon.h"
#include "screen.h"
#include "viewer.h"
#include "video.h"
#include "window.h"
#include "applik.h"

typedef enum
{
	ICN_NO_UPDATE,
	ICN_REDRAW,
	ICN_DELETE
} icn_upd_type;

typedef struct
{
	int x;
	int y;
	ITMTYPE item_type;
	int icon_index;
	boolean selected;
	boolean newstate;
	SNAME label;		/* label of assigned icon */ /* HR 240203 */
	union
	{
		int drv;
		const char *name;
	} icon_dat;
	icn_upd_type update;
	SNAME icon_name;	/* HR 151102: name of icon in resource */ /* HR 240203 */
} ICON;

typedef struct
{
	int icon_index;
	unsigned int type:4;
	unsigned int drv:6;
	int resvd1:6;
	unsigned char x;
	unsigned char y;
	int resvd2;
	SNAME label;		/* label of assigned icon */ /* HR 240203 */
	SNAME icon_name;	/* HR 151102: name of icon in resource */ /* HR 240203 */
} ICONINFO;

typedef struct
{
	ITM_INTVARS;
} DSK_WINDOW;

static ICON *desk_icons;
OBJECT *desktop;
static int icon_width, icon_height, m_icnx, m_icny, max_icons;

static int dsk_hndlkey(WINDOW *w, int scancode, int keystate);
static void dsk_hndlbutton(WINDOW *w, int x, int y, int n, int button_state, int keystate);
static void dsk_top(WINDOW *w);

static WD_FUNC dsk_functions =
{
	dsk_hndlkey,
	dsk_hndlbutton,
	0L,
	0L,
	0L,
	0L,
	0L,
	0L,
	0L,
	0L,
	0L,
	0L,
	0L,
	dsk_top
};

static int icn_find(WINDOW *w, int x, int y);
static boolean icn_state(WINDOW *w, int icon);
static ITMTYPE icn_type(WINDOW *w, int icon);
static int icn_icon(WINDOW *w, int icon);
static char *icn_name(WINDOW *w, int icon);
static char *icn_fullname(WINDOW *w, int icon);
static int icn_attrib(WINDOW *w, int icon, int mode, XATTR *attrib);
static long icn_info(WINDOW *w, int icon, int which);
static boolean icn_open(WINDOW *w, int item, int kstate);
static boolean icn_copy(WINDOW *dw, int dobject, WINDOW *sw, int n, int *list, ICND *icns, int x, int y, int kstate);
static boolean icn_userdef(WINDOW *dw, int dobject, WINDOW *sw, int n, int *list, int kstate);
static void icn_select(WINDOW *w, int selected, int mode, boolean draw);
static void icn_rselect(WINDOW *w, int x, int y);
static void icn_nselected(WINDOW *w, int *n, int *sel);
static boolean icn_xlist(WINDOW *w, int *nselected, int *nvisible, int **sel_list, ICND **icnlist, int mx, int my);
static boolean icn_list(WINDOW *w, int *nselected, int **sel_list);
static void icn_set_update(WINDOW *w, wd_upd_type type, const char *fname1, const char *fname2);
static void icn_do_update(WINDOW *w);

static ITMFUNC itm_func =
{
	icn_find,					/* itm_find */
	icn_state,					/* itm_state */
	icn_type,					/* itm_type */
	icn_icon,					/* itm_icon */
	icn_name,					/* itm_name */
	icn_fullname,				/* itm_fullname */
	icn_attrib,					/* itm_attrib */
	icn_info,					/* itm_info */

	icn_open,					/* itm_open */
	icn_copy,					/* itm_copy */
	item_showinfo,				/* itm_showinfo */

	icn_select,					/* itm_select */
	icn_rselect,				/* itm_rselect */
	icn_xlist,					/* itm_xlist */
	icn_list,					/* itm_list */

	0,							/* wd_path */
	icn_set_update,				/* wd_set_update */
	icn_do_update,				/* wd_do_update */
	0,							/* wd_filemask */
	0,							/* wd_newfolder */
	0,							/* wd_disp_mode */
	0,							/* wd_sort */
	0,							/* wd_attrib */
	0							/* wd_seticons */
};

void *icon_buffer;

OBJECT *icons;			/* HR 151202: use rsrc_load for icons. */
int *icon_data, n_icons;
WINDOW *desk_window;

SNAME iname; 			/* DjV 024 140103 */ /* HR 240203 */

MFORM icnm =
{8, 8, 1, 1, 0,
 0x1FF8,
 0x1008,
 0x1008,
 0x1008,
 0x1008,
 0x1008,
 0x1008,
 0x1008,
 0x1008,
 0x1008,
 0x1008,
 0x1008,
 0xF00F,
 0x8001,
 0x8001,
 0xFFFF,
 0x0000,
 0x0FF0,
 0x0FF0,
 0x0FF0,
 0x0FF0,
 0x0FF0,
 0x0FF0,
 0x0FF0,
 0x0FF0,
 0x0FF0,
 0x0FF0,
 0x0FF0,
 0x0FF0,
 0x7FFE,
 0x7FFE,
 0x0000};


/********************************************************************
 *																	*
 * Funktie voor het opnieuw tekenen van de desktop.					*
 *																	*
 ********************************************************************/

void dsk_draw(void)
{
	form_dial(FMD_START, 0, 0, 0, 0, screen_info.dsk.x, screen_info.dsk.y,
			  screen_info.dsk.w, screen_info.dsk.h);
	form_dial(FMD_FINISH, 0, 0, 0, 0, screen_info.dsk.x, screen_info.dsk.y,
			  screen_info.dsk.w, screen_info.dsk.h);
}

/********************************************************************
 *																	*
 * Hulp funkties.													*
 *																	*
 ********************************************************************/

static boolean isfile(ITMTYPE type)
{
	if ((type == ITM_FOLDER) || (type == ITM_FILE) || (type == ITM_PROGRAM))
		return TRUE;
	else
		return FALSE;
}

#define WF_OWNER	20

static void redraw_desk(RECT *r1)
{
	RECT r2, d;
	int owner;
	boolean redraw;

	wind_update(BEG_UPDATE);

	if  (_GemParBlk.glob.version >= 0x400)
	{
		xw_get(NULL, WF_OWNER, &owner);

		redraw = (ap_id != owner) ? FALSE : TRUE;
	}
	else
		redraw = TRUE;

	if (redraw)
	{
		xw_get(NULL, WF_FIRSTXYWH, &r2);

		while ((r2.w != 0) && (r2.h != 0))
		{
			if (xd_rcintersect(r1, &r2, &d) == TRUE)
				objc_draw(desktop, ROOT, MAX_DEPTH, d.x, d.y, d.w, d.h);
			xw_get(NULL, WF_NEXTXYWH, &r2);
		}
	}

	wind_update(END_UPDATE);
}

/* Wis een icoon van het beeldscherm. Deze routine wist
   niet de informatie van het icoon. Deze funktie is nodig als
   een icoon veranderd is. */

static void erase_icon(int object)
{
	RECT r;

	xd_objrect(desktop, object + 1, &r);

	desktop[object + 1].ob_flags = HIDETREE;
	redraw_desk(&r);
	desktop[object + 1].ob_flags = NORMAL;
}

static void draw_icon(int i)
{
	RECT r;

	xd_objrect(desktop, i + 1, &r);
	redraw_desk(&r);
}

/* routines voor selecteren/deselecteren van iconen */
/* mode = 0 : deselecteer alles, selecteer selected */
/*        1 : toggle selected */
/*        2 : deselect selected */
/*        3 : select selected */

static void dsk_setnws(void)
{
	int i;

	for (i = 0; i < max_icons; i++)
		if (desk_icons[i].item_type != ITM_NOTUSED)
			desk_icons[i].selected = desk_icons[i].newstate;
}

static void dsk_drawsel(void)
{
	int i, x, y;
	RECT r = {-1, -1, -1, -1};

	desktop[0].ob_type = G_IBOX;

	for (i = 0; i < max_icons; i++)
	{
		if (desk_icons[i].item_type != ITM_NOTUSED)
		{
			if (desk_icons[i].selected == desk_icons[i].newstate)
				desktop[i + 1].ob_flags |= HIDETREE;
			else
			{
				desktop[i + 1].ob_state = (desk_icons[i].newstate) ? SELECTED : NORMAL;
				objc_offset(desktop, i + 1, &x, &y);
				if ((x < r.x) || (r.x < 0))
					r.x = x;
				if ((y < r.y) || (r.y < 0))
					r.y = y;
				x += desktop[i + 1].r.w - 1;
				y += desktop[i + 1].r.h - 1;
				if (x > r.w)
					r.w = x;
				if (y > r.h)
					r.h = y;
			}
		}
	}

	if (r.x >= 0)
	{
		r.w -= r.x + 1;
		r.h -= r.y + 1;
		redraw_desk(&r);
	}

	for (i = 0; i < max_icons; i++)
		if (desk_icons[i].selected == desk_icons[i].newstate)

			desktop[i + 1].ob_flags &= ~HIDETREE;

	desktop[0].ob_type = G_BOX;
}

/********************************************************************
 *																	*
 * Rubberbox funktie met scrolling window.							*
 *																	*
 ********************************************************************/

static void rubber_box(int x, int y, RECT *r)
{
	int x1 = x, y1 = y, x2 = x, y2 = y, ox = x, oy = y, kstate, h;
	boolean released;

	set_rect_default();

	wind_update(BEG_MCTRL);
	graf_mouse(POINT_HAND, NULL);

	draw_rect(x1, y1, x2, y2);

	do
	{
		released = xe_mouse_event(0, &x2, &y2, &kstate);

		if (y2 < screen_info.dsk.y)
			y2 = screen_info.dsk.y;

		if ((released != FALSE) || (x2 != ox) || (y2 != oy))
		{
			draw_rect(x1, y1, ox, oy);
			if (released == FALSE)
			{
				draw_rect(x1, y1, x2, y2);
				ox = x2;
				oy = y2;
			}
		}
	}
	while (released == FALSE);

	graf_mouse(ARROW, NULL);
	wind_update(END_MCTRL);

	if ((h = x2 - x1) < 0)
	{
		r->x = x2;
		r->w = -h + 1;
	}
	else
	{
		r->x = x1;
		r->w = h + 1;
	}

	if ((h = y2 - y1) < 0)
	{
		r->y = y2;
		r->h = -h + 1;
	}
	else
	{
		r->y = y1;
		r->h = h + 1;
	}
}

/********************************************************************
 *																	*
 * Externe funkties voor iconen.									*
 *																	*
 ********************************************************************/

#pragma warn -par

static void icn_select(WINDOW *w, int selected, int mode, boolean draw)
{
	int i;

	switch (mode)
	{
	case 0:
		for (i = 0; i < max_icons; i++)
			if (desk_icons[i].item_type != ITM_NOTUSED)
				desk_icons[i].newstate = (i == selected) ? TRUE : FALSE;
		break;
	case 1:
		for (i = 0; i < max_icons; i++)
			if (desk_icons[i].item_type != ITM_NOTUSED)
				desk_icons[i].newstate = desk_icons[i].selected;
		desk_icons[selected].newstate = (desk_icons[selected].selected) ? FALSE : TRUE;
		break;
	case 2:
		for (i = 0; i < max_icons; i++)
			if (desk_icons[i].item_type != ITM_NOTUSED)
				desk_icons[i].newstate = (i == selected) ? FALSE : desk_icons[i].selected;
		break;
	case 3:
		for (i = 0; i < max_icons; i++)
			if (desk_icons[i].item_type != ITM_NOTUSED)
				desk_icons[i].newstate = (i == selected) ? TRUE : desk_icons[i].selected;
		break;
	}
	if (draw == TRUE)
		dsk_drawsel();
	dsk_setnws();
}

static void icn_rselect(WINDOW *w, int x, int y)
{
	int i;
	RECT r1, r2;
	CICONBLK *h;		/* HR 151102: ciconblk (the largest) */

	rubber_box(x, y, &r1);

	for (i = 0; i < max_icons; i++)
	{
		if (desk_icons[i].item_type != ITM_NOTUSED)
		{
			h = desktop[i + 1].ob_spec.ciconblk;
			r2.x = desktop[0].r.x + desktop[i + 1].r.x + h->monoblk.ic.x;
			r2.y = desktop[0].r.y + desktop[i + 1].r.y + h->monoblk.ic.y;
			r2.w = h->monoblk.ic.w;
			r2.h = h->monoblk.ic.h;

			if (rc_intersect2(&r1, &r2))
				desk_icons[i].newstate = (desk_icons[i].selected) ? FALSE : TRUE;
			else
			{
				r2.x = desktop[0].r.x + desktop[i + 1].r.x + h->monoblk.tx.x;
				r2.y = desktop[0].r.y + desktop[i + 1].r.y + h->monoblk.tx.y;
				r2.w = h->monoblk.tx.w;
				r2.h = h->monoblk.tx.h;
				if (rc_intersect2(&r1, &r2))
					desk_icons[i].newstate = (desk_icons[i].selected) ? FALSE : TRUE;
				else
					desk_icons[i].newstate = desk_icons[i].selected;
			}
		}
	}
	dsk_drawsel();
	dsk_setnws();
}

static void icn_nselected(WINDOW *w, int *n, int *sel)
{
	int i, s, c = 0;
	ITMTYPE t;

	for (i = 0; i < max_icons; i++)
	{
		t = desk_icons[i].item_type;
		if ((t != ITM_NOTUSED) && (desk_icons[i].selected == TRUE))
		{
			c++;
			s = i;
		}
	}

	*n = c;
	*sel = (c == 1) ? s : -1;
}

static boolean icn_state(WINDOW *w, int icon)
{
	return desk_icons[icon].selected;
}

static ITMTYPE icn_type(WINDOW *w, int icon)
{
	return desk_icons[icon].item_type;
}

static int icn_icon(WINDOW *w, int icon)
{
	return desk_icons[icon].icon_index;
}

static char *icn_name(WINDOW *w, int icon)
{
	ICON *icn = &desk_icons[icon];
	static char name[16];

	if (isfile(icn->item_type) == TRUE)
		return fn_get_name(icn->icon_dat.name);
	else
	{
		if (icn->item_type == ITM_DRIVE)
		{
			char *s;

			rsrc_gaddr(R_STRING, MDRVNAME, &s);

			sprintf(name, s, (char) icn->icon_dat.drv);
			return name;
		}
		else
			return NULL;
	}
}

static char *icn_fullname(WINDOW *w, int icon)
{
	ICON *icn = &desk_icons[icon];
	char *s;

	if ((isfile(icn->item_type) == FALSE) && (icn->item_type != ITM_DRIVE))
		return NULL;

	if (icn->item_type == ITM_DRIVE)
	{
		if ((s = strdup("A:\\")) == NULL)
			xform_error(ENSMEM);
		else
			s[0] = icn->icon_dat.drv;
	}
	else
	{
		if ((s = strdup(icn->icon_dat.name)) == NULL)
			xform_error(ENSMEM);
	}
	return s;
}

static int icn_attrib(WINDOW *w, int icon, int mode, XATTR *attr)
{
	int error;
	ICON *icn = &desk_icons[icon];

	if (isfile(icn->item_type) == TRUE)
	{
		error = (int) x_attr(mode, icn->icon_dat.name, attr);
		return error;
	}
	else
		return 0;
}

static long icn_info(WINDOW *w, int icon, int which)
{
	ICON *icn = &desk_icons[icon];
	const char *path = icn->icon_dat.name, *h;
	ITMTYPE type = icn->item_type;

	if (type == ITM_DRIVE)
	{
		char *s;

		rsrc_gaddr(R_STRING, MDRVNAME, &s);

		if (which == ITM_NAMESIZE)
			return (strlen(s) - 1);
		else
			return 3L;
	}

	if (isfile(type))
	{
		switch (which)
		{
		case ITM_FNAMESIZE:
			return strlen(path);
		case ITM_NAMESIZE:
			return strlen(fn_get_name(path));
		case ITM_PATHSIZE:
			if ((h = strrchr(path, '\\')) == NULL)
				return 0L;
			if (*(h - 1) == ':')
				h++;
			return (h - path);
		}
	}
	return 0L;
}

static void get_icnd(int object, ICND *icnd, int mx, int my)
{
	int tx, ty, tw, th, ix, iy, iw, obj = object + 1;
	CICONBLK *h;			/* HR 151102: ciconblk (the largest) */

	icnd->item = object;
	icnd->np = 9;
	icnd->m_x = desktop[obj].r.x + desktop[obj].r.w / 2 - mx + screen_info.dsk.x;
	icnd->m_y = desktop[obj].r.y + desktop[obj].r.h / 2 - my + screen_info.dsk.y;
	h = desktop[obj].ob_spec.ciconblk;
	tx = desktop[obj].r.x + h->monoblk.tx.x - mx + screen_info.dsk.x;
	ty = desktop[obj].r.y + h->monoblk.tx.y - my + screen_info.dsk.y;
	tw = h->monoblk.tx.w - 1;
	th = h->monoblk.tx.h - 1;
	ix = desktop[obj].r.x + h->monoblk.ic.x - mx + screen_info.dsk.x;
	iy = desktop[obj].r.y + h->monoblk.ic.y - my + screen_info.dsk.y;
	iw = h->monoblk.ic.w - 1;

	icnd->coords[0] = tx;
	icnd->coords[1] = ty;
	icnd->coords[2] = ix;
	icnd->coords[3] = ty;
	icnd->coords[4] = ix;
	icnd->coords[5] = iy;
	icnd->coords[6] = ix + iw;
	icnd->coords[7] = iy;
	icnd->coords[8] = ix + iw;
	icnd->coords[9] = ty;
	icnd->coords[10] = tx + tw;
	icnd->coords[11] = ty;
	icnd->coords[12] = tx + tw;
	icnd->coords[13] = ty + th;
	icnd->coords[14] = tx;
	icnd->coords[15] = ty + th;
	icnd->coords[16] = tx;
	icnd->coords[17] = ty + 1;
}

static boolean icn_list(WINDOW *w, int *nselected, int **sel_list)
{
	int i, j = 0, n = 0, *list;

	for (i = 0; i < max_icons; i++)
		if ((desk_icons[i].item_type != ITM_NOTUSED) && (desk_icons[i].selected == TRUE))
			n++;

	if ((*nselected = n) == 0)
	{
		*sel_list = NULL;
		return TRUE;
	}

	list = malloc((long) n * sizeof(int));

	*sel_list = list;

	if (list == NULL)
	{
		xform_error(ENSMEM);
		return FALSE;
	}
	else
	{
		for (i = 0; i < max_icons; i++)
			if ((desk_icons[i].item_type != ITM_NOTUSED) && (desk_icons[i].selected == TRUE))
				list[j++] = i;

		return TRUE;
	}
}

/* Routine voor het maken van een lijst met geseleketeerde iconen. */

static boolean icn_xlist(WINDOW *w, int *nsel, int *nvis, int **sel_list, ICND **icns, int mx, int my)
{
	int i, *list, n;
	ICND *icnlist;

	if (icn_list(desk_window, nsel, sel_list) == FALSE)
		return FALSE;

	n = *nsel;
	*nvis = n;

	if (n == 0)
	{
		*icns = NULL;
		return TRUE;
	}

	icnlist = malloc((long) n * sizeof(ICND));
	*icns = icnlist;

	if (icnlist == NULL)
	{
		xform_error(ENSMEM);
		free(*sel_list);
		return FALSE;
	}
	else
	{
		list = *sel_list;

		for (i = 0; i < n; i++)
			get_icnd(list[i], &icnlist[i], mx, my);

		return TRUE;
	}
}

static int icn_find(WINDOW *w, int x, int y)
{
	int ox, oy, ox2, oy2, i, object = -1;
	CICONBLK *p;		/* HR 151102: ciconblk (the largest) */

	objc_offset(desktop, 0, &ox, &oy);

	if ((i = desktop[0].ob_head) == -1)
		return -1;

	while (i != 0)
	{
		if (   desktop[i].ob_type == G_ICON
		    || desktop[i].ob_type == G_CICON		/* HR 151102 */
		   )
		{
			RECT h;

			ox2 = ox + desktop[i].r.x;
			oy2 = oy + desktop[i].r.y;
			p = desktop[i].ob_spec.ciconblk;

			h.x = ox2 + p->monoblk.ic.x;
			h.y = oy2 + p->monoblk.ic.y;
			h.w = p->monoblk.ic.w;
			h.h = p->monoblk.ic.h;

			if (inrect(x, y, &h) == TRUE)
				object = i - 1;
			else
			{
				h.x = ox2 + p->monoblk.tx.x;
				h.y = oy2 + p->monoblk.tx.y;
				h.w = p->monoblk.tx.w;
				h.h = p->monoblk.tx.h;

				if (inrect(x, y, &h) == TRUE)
					object = i - 1;
			}
		}
		i = desktop[i].ob_next;
	}
	return object;
}

#pragma warn .par

/********************************************************************
 *																	*
 * Funkties voor het verversen van de desktop.						*
 *																	*
 ********************************************************************/

void remove_icon(int object, boolean draw)
{
	ITMTYPE type = icn_type(desk_window, object);

	if (draw == TRUE)
		erase_icon(object);
	objc_delete(desktop, object + 1);

	free(desktop[object + 1].ob_spec.ciconblk);			/* HR 151102 */
	if (isfile(type) == TRUE)
		free(desk_icons[object].icon_dat.name);

	desk_icons[object].item_type = ITM_NOTUSED;
}

static void icn_set_name(ICON *icn, char *newname)
{
	if (strncmp(icn->label, fn_get_name(icn->icon_dat.name), 12) == 0)
		strsncpy(icn->label, fn_get_name(newname), sizeof(icn->label));		/* HR 120203: secure cpy */
	free(icn->icon_dat.name);
	icn->icon_dat.name = newname;
}

#pragma warn -par

static void icn_set_update(WINDOW *w, wd_upd_type type, const char *fname1, const char *fname2)
{
	int i;
	ICON *icon;
	char *new;

	for (i = 0;i < max_icons;i++)
	{
		icon = &desk_icons[i];

		if (isfile(icon->item_type) == TRUE)
		{
			if (strcmp(icon->icon_dat.name, fname1) == 0)
			{
				if (type == WD_UPD_DELETED)
					icon->update = ICN_DELETE;

				if (type == WD_UPD_MOVED)
				{
					if (strcmp(fname2, icon->icon_dat.name) != 0)
					{
						if ((new = strdup(fname2)) == NULL)
						{
							alert_printf(1, MICNPMEM, icon->label);
							return;
						}
						else
						{
							icon->update = ICN_REDRAW;
							icn_set_name(icon, new);
						}
					}
				}
			}
		}
	}
}

static void icn_do_update(WINDOW *w)
{
	int i;

	for (i = 0; i < max_icons; i++)
	{
		if (desk_icons[i].item_type != ITM_NOTUSED)
		{
			if (desk_icons[i].update == ICN_DELETE)
				remove_icon(i, TRUE);

			if (desk_icons[i].update == ICN_REDRAW)
			{
				erase_icon(i);
				draw_icon(i);
				desk_icons[i].update = ICN_NO_UPDATE;
			}
		}
	}
}

#pragma warn .par

/********************************************************************
 *																	*
 * Funktie voor het openen van iconen.								*
 *																	*
 ********************************************************************/

static boolean icn_open(WINDOW *w, int item, int kstate)
{
	ICON *icn = &desk_icons[item];
	ITMTYPE type = icn->item_type;

	if (isfile(type))
	{
		char *new;
		int button;

		if (x_exist(icn->icon_dat.name, EX_FILE | EX_DIR) == FALSE)
		{
			if ((button = alert_printf(1, MICNNFND, icn->label)) == 3)
				return FALSE;
			else if (button == 2)
			{
				remove_icon(item, TRUE);
				return FALSE;
			}
			else if ((new = locate(icn->icon_dat.name, (type == ITM_FOLDER) ? L_FOLDER : L_FILE)) == NULL)
				return FALSE;
			else
			{
				icn_set_name(icn, new);
				erase_icon(item);
				draw_icon(item);
			}
		}
	}

	return item_open(w, item, kstate);
}

/********************************************************************
 *																	*
 * Funkties voor het verwijderen en toevoegen van iconen.			*
 * HR 151102: locate icons in resource by name, not by index		*
 *																	*
 ********************************************************************/

int rsrc_icon(const char *name)
{
	int i = 0;
	do
	{
		OBJECT *ic = icons + i;
		if (ic->ob_type == G_ICON || ic->ob_type == G_CICON)
		{
			CICONBLK *h = ic->ob_spec.ciconblk;
			if (strnicmp(h->monoblk.ib_ptext, name, 12) == 0)
				return i;
		}
	}
	while ((icons[i++].ob_flags&LASTOB) == 0);

	return -1;
}

/* DjV 024 140103 ---vvv--- */
/* This routine gets icon id from name defined in desktop.rsc */
int rsrc_icon_rscid ( int id, char *name )
{
	char *nnn;
	xd_gaddr( R_STRING, id, &nnn );
	strcpy ( name, nnn );
	return rsrc_icon( name );
}
/* DjV 024 140103 ---^^^--- */

static int add_icon(ITMTYPE type, int icon, const char *text, int ch,
					int x, int y, boolean draw, const char *fname)
{
	int i = 0, ix, iy, icon_no;
	CICONBLK *h;			/* HR 151102: ciconblk (the largest) */
	
	if (icon < 0)
		return -1;

	icon_no = min(n_icons - 1, icon);

	while ((desk_icons[i].item_type != ITM_NOTUSED) && (i < max_icons - 1))
		i++;

	if (desk_icons[i].item_type != ITM_NOTUSED)
	{
		alert_printf(1, MTMICONS);
		if (isfile(type) == TRUE)
			free(fname);
		return -1;
	}

	ix = min(x, m_icnx);
	iy = min(y, m_icny);
	desk_icons[i].x = ix;
	desk_icons[i].y = iy;
	desk_icons[i].item_type = (type == ITM_PROGRAM) ? ITM_FILE : type;
	desk_icons[i].icon_index = icon_no;
	desk_icons[i].selected = FALSE;
	desk_icons[i].update = ICN_NO_UPDATE;

	desktop[i + 1].ob_head = -1;
	desktop[i + 1].ob_tail = -1;
	desktop[i + 1].ob_type = icons[icon_no].ob_type;	/* HR 151102 */
	desktop[i + 1].ob_flags = NONE;
	desktop[i + 1].ob_state = NORMAL;
	desktop[i + 1].r.x = ix * icon_width;
	desktop[i + 1].r.y = iy * icon_height;
	desktop[i + 1].r.w = ICON_W;
	desktop[i + 1].r.h = ICON_H;

	if ((h = malloc(sizeof(CICONBLK))) == NULL)		/* HR 151102: ciconblk (the largest) */
	{
		xform_error(ENSMEM);
		desk_icons[i].item_type = ITM_NOTUSED;
		if (isfile(type) == TRUE)
			free(fname);
		return -1;
	}

	desktop[i + 1].ob_spec.ciconblk = h;		/* HR 151102 */
	*h = *icons[icon_no].ob_spec.ciconblk;

	strsncpy(desk_icons[i].label, text, sizeof(SNAME));	/* HR 120203: secure cpy */
	strsncpy(desk_icons[i].icon_name,
	        icons[icon_no].ob_spec.ciconblk->monoblk.ib_ptext,
	        sizeof(SNAME));							/* HR 151102: maintain rsrc icon name, 120203: secure cpy */

	h->monoblk.ib_char &= 0xFF00;

	switch (type)
	{
	case ITM_DRIVE:
		desk_icons[i].icon_dat.drv = ch;
		h->monoblk.ib_ptext = desk_icons[i].label;
		h->monoblk.ib_char |= ch;
		break;
	case ITM_TRASH:
	case ITM_PRINTER:
		h->monoblk.ib_ptext = desk_icons[i].label;
		h->monoblk.ib_char |= 0x20;
		break;
	case ITM_FOLDER:
	case ITM_PROGRAM:
	case ITM_FILE:
		desk_icons[i].icon_dat.name = fname;
		h->monoblk.ib_ptext = desk_icons[i].label;
		h->monoblk.ib_char |= 0x20;
		break;
	}

	objc_add(desktop, 0, i + 1);

	if (draw == TRUE)
		draw_icon(i);

	return i;
}

static void comp_icnxy(int mx, int my, int *x, int *y)
{
	*x = (mx - screen_info.dsk.x) / icon_width;
	*x = min(*x, m_icnx);
	*y = (my - screen_info.dsk.y) / icon_height;
	*y = min(*y, m_icny);
}

static void get_iconpos(int *x, int *y)
{
	int dummy, mx, my;

	wind_update(BEG_MCTRL);
	graf_mouse(USER_DEF, &icnm);
	evnt_button(1, 1, 1, &mx, &my, &dummy, &dummy);
	graf_mouse(ARROW, NULL);
	wind_update(END_MCTRL);
	comp_icnxy(mx, my, x, y);
}

static ITMTYPE get_icntype(void)
{
	int object;

	object = xd_get_rbutton(addicon, AIPARENT);

	switch (object)
	{
	case ATRASH:
		return ITM_TRASH;
	case APRINTER:
		return ITM_PRINTER;
	default:
		return ITM_DRIVE;
	}
}

static void set_drvtype(ITMTYPE type)
{
	int object;

	switch (type)
	{
	case ITM_TRASH:
		object = ATRASH;
		break;
	case ITM_PRINTER:
		object = APRINTER;
		break;
	default:
		object = ADISK;
		break;
	}

	xd_set_rbutton(addicon, AIPARENT, object);
}

static void disable_icntype(void)
{
	addicon[ADISK].ob_state |= DISABLED;		/* HR 151102: | */
	addicon[ATRASH].ob_state |= DISABLED;
	addicon[APRINTER].ob_state |= DISABLED;
	addicon[DRIVEID].ob_state |= DISABLED;
	addicon[DRIVEID].ob_flags &= ~EDITABLE;
}

static void enable_icntype(void)
{
	addicon[ADISK].ob_state &= ~DISABLED;		/* HR 151102: ~DISABLED */
	addicon[ATRASH].ob_state &= ~DISABLED;
	addicon[APRINTER].ob_state &= ~DISABLED;
	addicon[DRIVEID].ob_state &= ~DISABLED;
	addicon[DRIVEID].ob_flags |= EDITABLE;
}

/* static DjV 040 160203 */
void set_selector(SLIDER *slider, boolean draw, XDINFO *info)
{
	OBJECT *h1, *ic;				/* HR 151102 */

	ic = icons + slider->line;
	h1 = addicon + ICONDATA;

	h1->ob_type = ic->ob_type;
	h1->ob_spec = ic->ob_spec;

	h1->r.x = (addicon[ICONBACK].r.w - ic->r.w) / 2;
	h1->r.y = (addicon[ICONBACK].r.h - ic->r.h) / 2;

	if ( currez < 2 ) 			/* DjV 014 160203 */
		h1->r.y = h1->r.y / 2;	/* DjV 034 160203 */

	if (draw == TRUE)
		xd_draw(info, ICONBACK, 1);
}

static int icn_dialog(int *icon_no, int startobj)
{
	int button;
	SLIDER sl_info;

	sl_info.type = 0;
	sl_info.up_arrow = ICNUP;
	sl_info.down_arrow = ICNDWN;
	sl_info.slider = ICSLIDER;
	sl_info.sparent = ICPARENT;
	sl_info.lines = 1;
	sl_info.n = n_icons;
	sl_info.line = *icon_no;
	sl_info.set_selector = set_selector;
	sl_info.first = 0;
	sl_info.findsel = 0;

	button = sl_dialog(addicon, startobj, &sl_info);

	*icon_no = sl_info.line;

	return button;
}

/* DjV 034 050203 ---vvv--- */
/* Not needed anymore  */
/*
static void hide_children(OBJECT *tree, int parent)
{
	int i;

	tree[parent].ob_flags |= HIDETREE;

	if ((i = tree[parent].ob_head) == -1)
		return;

	while (i != parent)
	{
		tree[i].ob_flags |= HIDETREE;
		i = tree[i].ob_next;
	}
}

static void unhide_children(OBJECT *tree, int parent)
{
	int i;

	tree[parent].ob_flags &= ~HIDETREE;

	if ((i = tree[parent].ob_head) == -1)
		return;

	while (i != parent)
	{
		tree[i].ob_flags &= ~HIDETREE;
		i = tree[i].ob_next;
	}
}
*/
/* DjV 034 050203 ---^^^--- */

void dsk_insticon(void)
{
	int x, y, button, icon_no = 0;
	ITMTYPE type;

	get_iconpos(&x, &y);

	rsc_title(addicon, AITITLE, DTADDICN);
	/* hide_children(addicon, CHNBUTT);   DjV 034 050203 */
	/* unhide_children(addicon, ADDBUTT); DjV 034 050203 */

	addicon[CHNBUTT].ob_flags |= HIDETREE;	/* DjV 034 050203 */
	addicon[ADDBUTT].ob_flags &= ~HIDETREE;	/* DjV 034 050203 */
	addicon[ICBTNS ].ob_flags &= ~HIDETREE;	/* DjV 034 050203 */
	addicon[ICNTYPE].ob_flags |= HIDETREE; 	/* DjV 034 050203 */
	addicon[DRIVEID].ob_flags &= ~HIDETREE;	/* DjV 034 050203 */
	addicon[ICSHFIL].ob_flags |= HIDETREE;	/* DJV 034 050203 */
	addicon[ICSHFLD].ob_flags |= HIDETREE;	/* DjV 034 050203 */
	addicon[ICNLABEL].ob_flags &= ~HIDETREE;/* DjV 034 090203 */

	button = icn_dialog(&icon_no, DRIVEID);

	if (button == ADDICNOK)
	{
		type = get_icntype();
		if (type != ITM_DRIVE)
			*drvid = 0;
		add_icon(type, icon_no, iconlabel, *drvid & 0xDF, x, y, TRUE, NULL);			/* HR 151102 */
	}
}

static boolean chng_icon(int object)
{
	int button, icon_no;
	ITMTYPE type;

	type = desk_icons[object].item_type;

	rsc_title(addicon, AITITLE, DTCHNICN);
	/* hide_children(addicon, ADDBUTT); DjV 034 050203 */
	/* unhide_children(addicon, CHNBUTT); DjV 034 050203 */
	addicon[ADDBUTT].ob_flags |= HIDETREE;	/* DJV 034 050203 */
	addicon[CHNBUTT].ob_flags &= ~HIDETREE;	/* DJV 034 050203 */

	if ((type == ITM_DRIVE) || (type == ITM_TRASH) || (type == ITM_PRINTER))
	{
		set_drvtype(desk_icons[object].item_type);
		*drvid = (char) desk_icons[object].icon_dat.drv;
		strcpy(iconlabel, desk_icons[object].label);
		icon_no = desk_icons[object].icon_index;

		button = icn_dialog(&icon_no, DRIVEID);

		if (button == CHNICNOK)
		{
			CICONBLK *h = desktop[object + 1].ob_spec.ciconblk;		/* HR 151102: ciconblk (the largest) */

			desk_icons[object].item_type = get_icntype();
			if (desk_icons[object].item_type != ITM_DRIVE)
				*drvid = 0;

			desktop[object + 1].ob_type = icons[icon_no].ob_type;		/* HR 151102: icons may change colours ;-) */
			desk_icons[object].icon_index = icon_no;
			strsncpy(desk_icons[object].label, iconlabel, sizeof(SNAME));		/* HR 120203: secure cpy */
			strsncpy(desk_icons[object].icon_name,
			        icons[icon_no].ob_spec.ciconblk->monoblk.ib_ptext,
			        sizeof(SNAME));							/* HR 151102: maintain rsrc icon name, HR 120203: secure cpy */

			desk_icons[object].icon_dat.drv = *drvid & 0xDF;
			*h = *icons[icon_no].ob_spec.ciconblk;
			h->monoblk.ib_ptext = desk_icons[object].label;
			h->monoblk.ib_char &= 0xFF00;
			h->monoblk.ib_char |= (int) (*drvid) & 0xDF;
		}
	}
	else
	{
		disable_icntype();
		*drvid = 0;
		strcpy(iconlabel, desk_icons[object].label);
		icon_no = desk_icons[object].icon_index;

		button = icn_dialog(&icon_no, ICNLABEL);

		if (button == CHNICNOK)
		{
			CICONBLK *h = desktop[object + 1].ob_spec.ciconblk;	/* HR 151102: ciconblk (the largest) */

			desktop[object + 1].ob_type = icons[icon_no].ob_type;		/* HR 151102: icons may change colours ;-) */
			desk_icons[object].icon_index = icon_no;
			strsncpy(desk_icons[object].label, iconlabel, sizeof(SNAME));		/* HR 120203: secure cpy */
			strsncpy(desk_icons[object].icon_name,
			        icons[icon_no].ob_spec.ciconblk->monoblk.ib_ptext,
			        sizeof(SNAME));							/* HR 151102: maintain rsrc icon name, HR 120203: secure cpy */

			*h = *icons[icon_no].ob_spec.ciconblk;
			h->monoblk.ib_ptext = desk_icons[object].label;
			h->monoblk.ib_char &= 0xFF00;
			h->monoblk.ib_char |= 0x20;
		}
		enable_icntype();
	}

	return (button == CHNICNAB) ? TRUE : FALSE;
}

static void mv_icons(ICND *icns, int n, int mx, int my)
{
	int i, x, y, obj;

	for (i = 0; i < n; i++)
	{
		obj = icns[i].item;
		erase_icon(obj);
		x = (mx + icns[i].m_x - screen_info.dsk.x) / icon_width;
		y = (my + icns[i].m_y - screen_info.dsk.y) / icon_height;
		x = min(x, m_icnx);
		y = min(y, m_icny);
		desk_icons[obj].x = x;
		desk_icons[obj].y = y;
		desktop[obj + 1].r.x = x * icon_width;
		desktop[obj + 1].r.y = y * icon_height;
		draw_icon(obj);
	}
}

static boolean icn_copy(WINDOW *dw, int dobject, WINDOW *sw, int n,
						int *list, ICND *icns, int x, int y, int kstate)
{
	int item, ix, iy, icon;
	const char *fname;
	ITMTYPE type;

	if (dobject != -1)
	{
		type = itm_type(dw, dobject);

		return item_copy(dw, dobject, sw, n, list, kstate);
	}
	else
	{
		if (sw == desk_window)
		{
			mv_icons(icns, n, x, y);
			return FALSE;
		}
		else
		{
			if (n > 1)
			{
				alert_printf(1, MMULITEM);
				return FALSE;
			}
			else
			{
				item = list[0];
				type = itm_type(sw, item);
				icon = itm_icon(sw, item);
				if ((fname = itm_fullname(sw, item)) != NULL)
				{
					comp_icnxy(x, y, &ix, &iy);
					add_icon(type, icon, fn_get_name(fname), 0, ix, iy, TRUE, fname);			/* HR 151102 */
				}

				return TRUE;
			}
		}
	}
}

/* funkties voor het laden en opslaan van de posities van
   de iconen. */

static void rem_all_icons(void)
{
	int i;

	for (i = 0; i < max_icons; i++)
		if (desk_icons[i].item_type != ITM_NOTUSED)
			remove_icon(i, FALSE);
}

static void set_dsk_background(int pattern, int color)
{
	options.dsk_pattern = (unsigned char) pattern;
	options.dsk_color = (unsigned char) color;
	desktop[0].ob_spec.obspec.fillpattern = pattern;
	desktop[0].ob_spec.obspec.interiorcol = color;
}

#pragma warn -par

static int dsk_hndlkey(WINDOW *w, int scancode, int keystate)
{
	return 0;
}

/*
 * Button event handler voor directory windows.
 *
 * Parameters:
 *
 * w			- Pointer naar window
 * x			- x positie muis
 * y			- y positie muis
 * n			- aantal muisklikken
 * button_state	- Toestand van de muisknoppen
 * keystate		- Toestand van de SHIFT, CONTROL en ALTERNATE toets
 */

static void dsk_hndlbutton(WINDOW *w, int x, int y, int n,
						   int button_state, int keystate)
{
	wd_hndlbutton(w, x, y, n, button_state, keystate);
}

static void dsk_top(WINDOW *w)
{
	menu_ienable(menu, MCLOSE, 0);
	menu_ienable(menu, MDELETE, 0);			/* HR 151102 */
	menu_ienable(menu, MCLOSEW, 0);
	menu_ienable(menu, MNEWDIR, 0);
	menu_ienable(menu, MSELALL, 0);
	/* menu_ienable(menu, MSETMASK, 0); DjV 004 290103 */
	menu_ienable(menu, MCYCLE, 0);
}

#pragma warn .par

int dsk_save(XFILE *file)
{
	ICONINFO iconinfo;
	int i, error;
	ITMTYPE type;
	long n;

	for (i = 0; i < max_icons; i++)
	{
		memset(&iconinfo, 0, sizeof(ICONINFO));

		type = desk_icons[i].item_type;

		if (type == ITM_NOTUSED)
			continue;

		iconinfo.type = (unsigned int) desk_icons[i].item_type;
		iconinfo.icon_index = desk_icons[i].icon_index;
		iconinfo.x = desk_icons[i].x;
		iconinfo.y = desk_icons[i].y;

		strsncpy(iconinfo.label, desk_icons[i].label, sizeof(SNAME));		/* HR 120203: secure cpy */
		strsncpy(iconinfo.icon_name, desk_icons[i].icon_name, sizeof(SNAME));	/* HR 151102, HR 120203: secure cpy */

		if (desk_icons[i].item_type == ITM_DRIVE)
			iconinfo.drv = desk_icons[i].icon_dat.drv - 'A';
		else
			iconinfo.drv = 0;

		iconinfo.resvd1 = 0;
		iconinfo.resvd2 = 0;

		if ((n = x_fwrite(file, &iconinfo, sizeof(ICONINFO))) < 0)
			return (int) n;

		if (isfile(desk_icons[i].item_type))
		{
			if ((error = x_fwritestr(file, desk_icons[i].icon_dat.name)) < 0)
				return error;
		}
	}

	memset(&iconinfo, 0, sizeof(ICONINFO));

	if ((n = x_fwrite(file, &iconinfo, sizeof(ICONINFO))) < 0)
		return (int) n;

	return 0;
}

int dsk_load(XFILE *file)
{
	ICONINFO iconinfo;
	char *fname;
	long n;
	int error;

	rem_all_icons();

	if (options.version < 0x125)
		set_dsk_background((ncolors > 2) ? 7 : 4, 3);
	else
		set_dsk_background(options.dsk_pattern, options.dsk_color);

	do
	{
		if ((n = x_fread(file, &iconinfo, sizeof(ICONINFO))) != sizeof(ICONINFO))
			return (n < 0) ? (int) n : EEOF;

		if (iconinfo.type != 0)
		{
			int icon;
	
			if (isfile(iconinfo.type))
			{
				if ((fname = x_freadstr(file, NULL, sizeof(LNAME), &error)) == NULL)		/* HR 240103: max l */ /* HR 240203 */
					return error;
			}
			else
				fname = NULL;
			
			icon = rsrc_icon(iconinfo.icon_name);			/* HR 151102: find by name */
			if (icon < 0)
				icon = rsrc_icon_rscid ( FIINAME, iname ); /* DjV 024 140103 */ 
			if (icon >= 0)
				if (add_icon((ITMTYPE) iconinfo.type, icon,			/* HR 151102 */
							 iconinfo.label, iconinfo.drv + 'A', iconinfo.x,
							 iconinfo.y, FALSE, fname) < 0)
					return ERROR;
			
		}
	}
	while (iconinfo.type != 0);

	wind_set(0, WF_NEWDESK, desktop, 0);

	dsk_draw();

	return 0;
}

/*
 * Load the icon file.
 *
 * Result: FALSE if no error, TRUE if error.
 */

/* HR 151102: Use standard functions of the AES */

static
void **svicntree, *svicnrshdr;

boolean load_icons(void)
{
	void **svtree = _GemParBlk.glob.ptree;
	void *svrshdr = _GemParBlk.glob.rshdr;

	/* if (rsrc_load(colour_icons ? "cicons.rsc" : "icons.rsc") == 0) DjV 030 010203 */
	if (rsrc_load( ( colour_icons && (ncolors > 2) ) ? "cicons.rsc" : "icons.rsc") == 0) /* DjV 030 010203 */
		return alert_printf(1, MICNFNF), TRUE;
	else
	{
		int i = 0;

		rsrc_gaddr(R_TREE, 0, &icons);		/* That's all you need. */
		svicntree = _GemParBlk.glob.ptree;
		svicnrshdr = _GemParBlk.glob.rshdr;

		n_icons = 0;
		icons++;

		do n_icons++; while ( (icons[i++].ob_flags&LASTOB) == 0 );
	}

	_GemParBlk.glob.ptree = svtree;
	_GemParBlk.glob.rshdr = svrshdr;

	return FALSE;
}

void free_icons(void)
{
	void **svtree = _GemParBlk.glob.ptree;
	void *svrshdr = _GemParBlk.glob.rshdr;

	_GemParBlk.glob.ptree = svicntree;
	_GemParBlk.glob.rshdr = svicnrshdr;

	rsrc_free();

	_GemParBlk.glob.ptree = svtree;
	_GemParBlk.glob.rshdr = svrshdr;
}

/* Routine voor het initialiseren van de desktop. */

boolean dsk_init(void)
{
	int i, error;

	if ((desk_window = xw_open_desk(DESK_WIND, &dsk_functions,
									sizeof(DSK_WINDOW), &error)) == NULL)
	{
		if (error == XDNSMEM)
			xform_error(ENSMEM);

		return TRUE;
	}

	((DSK_WINDOW *) desk_window)->itm_func = &itm_func;

	m_icnx = screen_info.dsk.w / ICON_W - 1;
	m_icny = screen_info.dsk.h / ICON_H - 1;

	if ((max_icons = (m_icnx + 1) * (m_icny + 1)) < 64)
		max_icons = 64;

	if (   ((desktop    = malloc((long)(max_icons + 1) * sizeof(OBJECT))) == NULL)
	    || ((desk_icons = malloc((long) max_icons      * sizeof(ICON  ))) == NULL)
	   )
	{
		xform_error(ENSMEM);
		return TRUE;
	}

	/* DjV 002 241202 ---vvv--- */

	/*   
	 *  When using nonstandard resolutions (i.e. like with overscan)
	 *  unpleasant effects occur- icon positions shift;
	 *  as a brute-force fix: always replace calculated icon width and height
	 *  with initial values- in standard resolutions the result should probably
	 *  be the same anyway. Perhaps overscan software should be looked into,
	 *  as it does not properly inform GEM of the change (can it?)
	 */

	/* 
	icon_width = screen_info.dsk.w / (m_icnx + 1);
	icon_height = screen_info.dsk.h / (m_icny + 1);
	*/ 
	icon_width  = ICON_W; 
	icon_height = ICON_H; 
	/* DjV 002 241202 ---^^^--- */

	desktop[0].ob_next = -1;
	desktop[0].ob_head = -1;
	desktop[0].ob_tail = -1;
	desktop[0].ob_type = G_BOX;
	desktop[0].ob_flags = NORMAL;
	desktop[0].ob_state = NORMAL;
	desktop[0].ob_spec.obspec.framesize = 0;
	desktop[0].ob_spec.obspec.textmode = 1;
	desktop[0].r = screen_info.dsk;

	for (i = 0; i < max_icons; i++)
		desk_icons[i].item_type = ITM_NOTUSED;

#ifdef MEMDEBUG
	atexit(rem_all_icons);
#endif
	return FALSE;
}

void dsk_close(void)
{
	xw_close_desk();
}

static void incr_pos(int *x, int *y)
{
	if ((*x += 1) > m_icnx)
	{
		*x = 0;
		*y += 1;
	}
}

void dsk_default(void)
{
	int i, x = 2, y = 0, ic;	 /* DjV 024 140103 */
	long drives = drvmap();

	rem_all_icons();

	set_dsk_background((ncolors > 2) ? 7 : 4, 3);

/* HR 151102: icons by name, not index DjV 024 140103 use names from rsc file. */

	ic = rsrc_icon_rscid( FLINAME, iname );
	add_icon(ITM_DRIVE, ic, iname, 'A', 0, 0, FALSE, NULL);
	add_icon(ITM_DRIVE, ic, iname, 'B', 1, 0, FALSE, NULL);
	
	ic = rsrc_icon_rscid ( HDINAME, iname );

	for (i = 2; i < 32; i++)
	{
		if (btst(drives, i) == TRUE)
		{
			add_icon(ITM_DRIVE, ic, iname, i < 26 ? 'A' + i : '0' + i - 26, x, y, FALSE, NULL); /* DjV 024 140103 */
			incr_pos(&x, &y);
		}
	}

	ic = rsrc_icon_rscid ( TRINAME, iname );
	add_icon(ITM_TRASH, ic, iname, 0, x, y, FALSE, NULL);	/* HR 151102 DjV 024 140103 */
	incr_pos(&x, &y);
	ic = rsrc_icon_rscid ( PRINAME, iname );
	add_icon(ITM_PRINTER, ic, iname, 0, x, y, FALSE, NULL);	/* HR 151102 DjV 024 140103 */

	wind_set(0, WF_NEWDESK, desktop, 0);
	dsk_draw();
}

void dsk_remicon(void)
{
	int button, i, n, *list;

	button = alert_printf(1, MREMICNS);

	if (button == 1)
	{
		if ((icn_list(desk_window, &n, &list) == TRUE) && (n > 0))
		{
			for (i = 0; i < n; i++)
				remove_icon(list[i], TRUE);
			wd_reset(desk_window);
			free(list);
		}
	}
}

void dsk_chngicon(void)
{
	int i = 0, n, *list, oldmode;
	boolean currpos = FALSE, abort = FALSE;

	if ((icn_list(desk_window, &n, &list) == TRUE) && (n > 0))
	{
		while ((i < n) && (abort == FALSE))
		{
			if (i == 1)
			{
				oldmode = xd_setposmode(XD_CURRPOS);
				currpos = TRUE;
			}
			abort = chng_icon(list[i++]);
		}

		if (currpos == TRUE)
			xd_setposmode(oldmode);

		for (i = 0; i < n; i++)
		{
			erase_icon(list[i]);
			draw_icon(list[i]);
		}

		free(list);
	}
}

int arrow_form_do ( XDINFO *info, int *oldbutton ); /* DjV 039 090203 */

void dsk_options(void)
{
	int button, oldmode, color, pattern;
	int wcolor, wpattern;    /* DjV 011 251202 */
	int oldbutton = -1; 	/* DjV 039 090203 aux for arrow_form_do */
	XDINFO info;
	boolean stop = FALSE, draw = FALSE;

	wdoptions[DSKPAT].ob_spec.obspec.fillpattern = desktop[0].ob_spec.obspec.fillpattern;
	wdoptions[DSKCOLOR].ob_spec.obspec.interiorcol = desktop[0].ob_spec.obspec.interiorcol;

	/* DjV 011 251202 ---vvv--- */
	wdoptions[WINPAT].ob_spec.obspec.fillpattern = options.V2_2.win_pattern;
	wdoptions[WINCOLOR].ob_spec.obspec.interiorcol = options.V2_2.win_color;

	/*
	 * Note: only the first 8 patterns (#0:7) are taken into account for fill
	 */

	/* DjV 011 251202 ---^^^--- */

	xd_open(wdoptions, &info);

	button = 0;		/* DjV 039 090203 */

	while (stop == FALSE)
	{
		/* DjV 039 090203 ---vvv--- */
		/*
		 * the only way to return here with oldbutton !=0 is to
		 * press an arrow; therefore any button pressed is
		 * assumed to be arrow and action is taken
		 */
		/* button = xd_form_do(&info, 0) & 0x7FFF; */
		button = arrow_form_do ( &info, &oldbutton );

		/* DJV 039 090203 ---^^^--- */

		switch (button)
		{
		case WOVIEWER:
		case WODIR:
			xd_close(&info);

			if (button == WOVIEWER)
				txt_setfont();
			else
				dir_setfont();

			oldmode = xd_setposmode(XD_CURRPOS);
			xd_open(wdoptions, &info);
			xd_setposmode(oldmode);
			break;
		case DSKCUP:
			if (wdoptions[DSKCOLOR].ob_spec.obspec.interiorcol < (ncolors - 1)) /* DjV 011 180103 */
			{
				wdoptions[DSKCOLOR].ob_spec.obspec.interiorcol++;
				xd_draw(&info, DSKCOLOR, 1);
			}
			break;
		case DSKCDOWN:
			if (wdoptions[DSKCOLOR].ob_spec.obspec.interiorcol > 0)
			{
				wdoptions[DSKCOLOR].ob_spec.obspec.interiorcol--;
				xd_draw(&info, DSKCOLOR, 1);
			}
			break;
		case DSKPUP:
			if (wdoptions[DSKPAT].ob_spec.obspec.fillpattern < min(7,(npatterns - 1))) /* DjV 011 180103 */
			{
				wdoptions[DSKPAT].ob_spec.obspec.fillpattern++;
				xd_draw(&info, DSKPAT, 1);
			}
			break;
		case DSKPDOWN:
			if (wdoptions[DSKPAT].ob_spec.obspec.fillpattern > 0) /* DjV 011 180103 */
			{
				wdoptions[DSKPAT].ob_spec.obspec.fillpattern--;
				xd_draw(&info, DSKPAT, 1);
			}
			break;
			
		/* DjV 011 251202 180103 ---vvv--- */	
			
		case WINCUP:
			if (wdoptions[WINCOLOR].ob_spec.obspec.interiorcol < (ncolors - 1))
			{
				wdoptions[WINCOLOR].ob_spec.obspec.interiorcol++;
				xd_draw(&info, WINCOLOR, 1);
			}
			break;
		case WINCDOWN:
			if (wdoptions[WINCOLOR].ob_spec.obspec.interiorcol > 0)
			{
				wdoptions[WINCOLOR].ob_spec.obspec.interiorcol--;
				xd_draw(&info, WINCOLOR, 1);
			}
			break;
		case WINPUP:
			if (wdoptions[WINPAT].ob_spec.obspec.fillpattern < min(7,(npatterns - 1)))
			{
				wdoptions[WINPAT].ob_spec.obspec.fillpattern++;
				xd_draw(&info, WINPAT, 1);
			}
			break;
		case WINPDOWN:
			if (wdoptions[WINPAT].ob_spec.obspec.fillpattern > 0)
			{
				wdoptions[WINPAT].ob_spec.obspec.fillpattern--;
				xd_draw(&info, WINPAT, 1);
			}
			break;
			
    /* DjV 011 251202 180103 ---^^^--- */			
						
		case WOPTOK:
			color = wdoptions[DSKCOLOR].ob_spec.obspec.interiorcol;
			pattern = wdoptions[DSKPAT].ob_spec.obspec.fillpattern;

			if ((options.dsk_pattern != (unsigned char) pattern) ||
				(options.dsk_color != (unsigned char) color))
			{
				set_dsk_background(pattern, color);
				draw = TRUE;
			}
			/* DjV 011 251202 ---vvv--- */
      
			wcolor = wdoptions[WINCOLOR].ob_spec.obspec.interiorcol; 
			wpattern = wdoptions[WINPAT].ob_spec.obspec.fillpattern;

			if ((options.V2_2.win_pattern != (unsigned char) wpattern) ||
				(options.V2_2.win_color != (unsigned char) wcolor))
			{
				options.V2_2.win_pattern= (unsigned char) wpattern;
				options.V2_2.win_color= (unsigned char) wcolor; 

				/* update all windows... */

				wd_fields(); /* HR 050303 */
			}

			/* DjV 011 251202 ---^^^--- */
						
		default:
			stop = TRUE;
			break;
		}
		/* xd_change(&info, button, NORMAL, 1); DjV 039 090203 */
	}

	xd_change(&info, button, NORMAL, 0);
	xd_close(&info);

	if (draw != FALSE)
		redraw_desk(&screen_info.dsk);
}
