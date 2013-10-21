/*
 * XaAES - XaAES Ain't the AES (c) 1992 - 1998 C.Graham
 *                                 1999 - 2003 H.Robbers
 *
 * A multitasking AES replacement for MiNT
 *
 * This file is part of XaAES.
 *
 * XaAES is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * XaAES is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with XaAES; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include <mintbind.h>

#include "xa_types.h"
#include "xa_globl.h"

#include "xalloc.h"
#include "scrlobjc.h"
#include "rectlist.h"
#include "objects.h"
#include "widgets.h"		/* HR */
#include "xa_fsel.h"		/* HR */
#include "xa_form.h"
#include "c_window.h"

static
scrl_widget sliders /* SCROLL_INFO *list */		/* HR */
{
	XA_slider(	list->wi, XAW_VSLIDE,
				list->n - 1,
				list->s,
				list->top ? list->top->n - 1 : 0);
	
	XA_slider(	list->wi, XAW_HSLIDE,
				list->max,
				list->v,
				list->left);
}

global
void free_scrollist(SCROLL_INFO *list)
{
	while (list->start)
	{
		SCROLL_ENTRY *next = list->start->next;
		free(list->start);
		list->start = next;
	}
	list->start = nil;
	list->cur = nil;
	list->top = nil;
	list->last = nil;
}

int max(int n, int m);

static
void visible(SCROLL_INFO *list, SCROLL_ENTRY *s)
{
	if (   (list->top and s->n < list->top->n)
	    or (list->bot and s->n > list->bot->n)		/* HR 250202: must check bot as well. */
	   )
	{
		int n = list->s/2;
		list->top = s;

		while (n-- and list->top->prev)		/* move to the middle */
			list->top = list->top->prev;

		n = list->s - (list->last->n - list->top->n + 1);

		if (n > 0)
			while (n-- and list->top->prev)
				list->top = list->top->prev;
	}

	list->slider(list);

/* HR 290702 (do without parent window; A listbox is a OBJECT and part of a object tree.) */
	draw_object_tree(list->lock, list->wt, list->wi->winob, list->wi->winitem, 2, 200);
}

/*
 *	Setup a scrolling list structure for an object
 *	- I've provided this as I don't expect any resource editor to support
 *	XaAES' extensions to the object types...
 */

/* HR: title set by set_slist_object() */
global
int set_scroll(XA_CLIENT *client, OBJECT *form, int item)
{
	OBJECT *ob = form + item;
	SCROLL_INFO *sinfo = XA_calloc(&client->base, 1, sizeof(SCROLL_INFO),105, 0);	/* HR: use calloc! */

	if (!sinfo)
		return FALSE;
/* HR: colours are those for windows */
	set_ob_spec(form, item, (unsigned long)sinfo);
	ob->ob_type = G_SLIST;
	ob->ob_flags |= TOUCHEXIT;		/* HR */
	sinfo->tree = form;				/* HR: very convenient */
	sinfo->item = item;
	return TRUE;
}

SendMessage slist_msg_handler;

/* HR: preparations for windowed list box widget;
       most important is to get the drawing smooth and simple.
       get rid of all those small (confolded) constant value's.
*/
global
SCROLL_INFO *set_slist_object(
			LOCK lock,
            XA_TREE *wt,
			OBJECT *form,
			int item,
			scrl_widget *closer,
			scrl_widget *fuller,
			scrl_click *dclick,
			scrl_click *click,
			char *title,
			char *info,
			int lmax		/* Used to determine whether a horizontal slider is needed. */
			)
{
	RECT r;
	XA_WIND_ATTR wkind = UPARROW|VSLIDE|DNARROW;
	OBJECT *ob = form + item;
	SCROLL_INFO *list = get_ob_spec(ob)->listbox;

	list->wt = wt;					/* HR 290702 */

	list->dclick = dclick;			/* Pass the scroll list's double click function */
	list->click = click;			/* Pass the scroll list's click function */

	list->title = title;
	/* rp_2_ap; it is an OBJECT, not a widget */
	r = ob->r;
	/* We want to use the space normally occupied by the shadow;
	    so we do a little cheat here. */
	r.w += SHADOW_OFFSET;
	r.h += SHADOW_OFFSET;
	object_offset(form, item, 0, 0, &r.x, &r.y);
	if (title)
		wkind |= NAME;
	if (info)
		wkind |= INFO;
	if (closer)
		wkind |= CLOSE;
	if (fuller)
		wkind |= FULL;
	if (lmax*screen.c_max_w + ICON_W > r.w - 24)
		wkind |= LFARROW|HSLIDE|RTARROW;
	wkind |= TOOLBAR;

	list->wi = create_window(lock, slist_msg_handler,
									wt->owner,				/* HR 290702 */
								 	true, 					/* nolist */
								 	wkind,
								 	created_for_AES,
								 	0, false, false,r,nil,nil);
	if (list->wi)
	{
		int dh;
		get_widget(list->wi, XAW_TITLE)->stuff = title;
		if (info)
			get_widget(list->wi, XAW_INFO)->stuff = info;
		list->wi->winob = form;		/* The parent object of the windowed list box */
		list->wi->winitem = item;
		list->wi->is_open = true;
		r = list->wi->wa;
		r.h /= screen.c_max_h;
		r.h *= screen.c_max_h;		/* snap the workarea hight */
		list->s = r.h / screen.c_max_h;
		dh = list->wi->wa.h - r.h;
		ob->r.h -= dh;
		list->wi->r.h -= dh;
		list->slider = sliders;
		list->closer = closer;
		list->fuller = fuller;
		list->vis = visible;
		list->lock = lock;

		list->v = (r.w - cfg.widg_w) / screen.c_max_w;
		list->max = lmax;

		calc_work_area(list->wi);	/* recalc for aligned work area */
	}
	return list;
}

/* HR: better control over the content of scroll_entry. */
global
bool add_scroll_entry(OBJECT *form, int item,
					  OBJECT *icon, void *text,
					  SCROLL_ENTRY_TYPE flag)
{
	SCROLL_INFO *list;
	SCROLL_ENTRY *last, *new;
	OBJECT *ob = form + item;
	
	list = get_ob_spec(ob)->listbox;

	new = xmalloc(sizeof(SCROLL_ENTRY),5);
	
	if (!new)
	{
		return false;
	}

	new->next = nil;
	last = list->start;
	if (last)
	{
		while(last->next)
			last = last->next;
		last->next = new;
		new->prev = last;
		new->n = last->n + 1;			/* HR */
	} else
	{
		new->prev = nil;
		list->start = list->top = new;	/* HR cur is left zero, which means no current : no selection. */
		new->n = 1;						/* HR */
	}
	new->text = text;
	new->icon = icon;
	new->flag = flag;					/* HR */
	if (icon)
		icon->r.x = icon->r.y = 0;

	list->n = new->n;
	return true;
}

/* HR: Modified such that a choise can be made. */
global
void empty_scroll_list(OBJECT *form, int item, SCROLL_ENTRY_TYPE flag)
{
	SCROLL_INFO *list;
	SCROLL_ENTRY *this, *next, *prior = nil;
	OBJECT *ob = form + item;
	int n = 0;
	list = get_ob_spec(ob)->listbox;
	this = next = list->start;
	
	while(this)
	{
		next = this->next;
		if ((this->flag&flag) or flag == -1)			/* HR */
		{
			if (this->flag&FLAG_MAL)		/* HR */
				free(this->text);
			if (this == list->start)
				list->start = next;
			if (prior)
				prior->next = next;
			free(this);
		} else
		{
			this->n = ++n;
			prior = this;
		}
		this = next;
	}

	list->n = n;
	list->top = list->start;
	list->cur = nil;		/* HR: This does nothing more than inhibit the selection of a line. */
}

/* HR: The application point of view of the list box */
/* HR: Immensely cleanup of the code by using a window and it's mechanisms for the list box.
       Including fully functional sliders and all arrows.
*/
static
SendMessage slist_msg_handler
/* LOCK lock, struct xa_window *wind, struct xa_client *to,
	G_i mp0, G_i mp1, G_i mp2, G_i mp3,
	G_i mp4, G_i mp5, G_i mp6, G_i mp7 */
{
	void set_button_timer(LOCK lock, XA_WINDOW *wind);
	SCROLL_INFO *list;
	SCROLL_ENTRY *old;
	OBJECT *ob;
	int p,ol;

	ob = wind->winob + wind->winitem;
	list = get_ob_spec(ob)->listbox;
	old = list->top;
	ol  = list->left;

	switch (mp0)		/* message number */
	{
	case WM_ARROWED:
		if (mp4 < WA_LFPAGE)
		{
			p = list->s;
			if (p < list->n)
				switch (mp4)
				{
				case WA_UPLINE:
					if (list->top->prev)
						list->state = SCRLSTAT_UP,
						list->top = list->top->prev;
				break;
				case WA_DNLINE:
					if (list->bot->next)
						list->state = SCRLSTAT_DOWN,
						list->top = list->top->next;
				break;
				case WA_UPPAGE:
					while (--p and list->top->prev) 
						list->top = list->top->prev;
				break;
				case WA_DNPAGE:
					while (--p and list->bot->next)
						list->bot = list->bot->next,
						list->top = list->top->next;
				}
		} else
		{
			p = list->v;
			if (p < list->max)
			{
				switch (mp4)
				{
				case WA_LFLINE:
					list->left--;
				break;
				case WA_RTLINE:
					list->left++;
				break;
				case WA_LFPAGE:
					list->left -= p-1;
				break;
				case WA_RTPAGE:
					list->left += p-1;
				}
				if (list->left < 0)
					list->left = 0;
				if (list->left > list->max - p)
					list->left = list->max - p;
			}
		}
	break;
	case WM_VSLID:
		p = list->s;
		if (p < list->n)
		{
			int new = sl_to_pix(list->n - (p-1), mp4);
			if (list->top->n > new)			/* go up */
				while (list->top->n > new and list->top->prev)
					list->top = list->top->prev;
			else							/* go down */
				while (list->top->n < new and list->bot->next)
					list->bot = list->bot->next,
					list->top = list->top->next;
		}		
	break;
	case WM_HSLID:
		p = list->v;
		if (p < list->max)
			list->left = sl_to_pix(list->max - p, mp4);
	break;
	case WM_CLOSED:
		if (list->closer)
			list->closer(list);
	break;
	case WM_FULLED:
		if (list->fuller)
			list->fuller(list);
	default:
		return;
	}

/* HR: next step is to take the scrolling out of d_g_slist and make it a seperate
       generalized function, using the difference between old and list->top.
       list->state would disappear.
*/
	if (old != list->top or ol != list->left)
	{
		list->slider(list);
/* HR 290702 (do without parent window; A listbox is a OBJECT and part of a object tree.) */
	draw_object_tree(lock, list->wt, list->wi->winob, list->wi->winitem, 2, 200);

	}

	/* Because we are not really sending something, but just immediately act,
	   we wont be woken up after this. So instead we set up a small timer for
	   the kernel to wake us up;
	   This is immensely better then the original Fselect in it's own loop.
	*/
	set_button_timer(lock, wind);
}

global
int scrl_cursor(SCROLL_INFO *list, G_u keycode)
{
	SCROLL_ENTRY *save = list->cur;
	if (!list->cur)
		list->cur = list->top;

	switch (keycode)
	{
	case 0x4800:			/* up arrow */
		if (list->cur->prev)
			list->cur = list->cur->prev;
	break;
	case 0x5000:			/* down arrow */
		if (list->cur->next)
			list->cur = list->cur->next;
	break;
	case 0x4900:			/* page up */
	case 0x4838:			/* shift + up arrow */
		slist_msg_handler(list->lock, list->wi, nil,
					WM_ARROWED, 0, 0, list->wi->handle,
					WA_UPPAGE,  0, 0, 0);
		return keycode;
	case 0x5032:			/* shift + down arrow */
	case 0x5100:			/* page down */
		slist_msg_handler(list->lock, list->wi, nil,
					WM_ARROWED, 0, 0, list->wi->handle,
					WA_DNPAGE,  0, 0, 0);
		return keycode;
	case 0x4700:			/* home */
		list->cur = list->start;
	break;
	case 0x4737:			/* shift + home */
		list->cur = list->last;
	break;
	default:
		list->cur = save;	/* Only change cur if a valid cursor key
		                       was pressed. See fs_dclick() */
		return -1;
	}

	list->vis(list,list->cur);
	return keycode;
}

/* HR 181201: pass all mouse data to these functions using MOOSE_DATA. */
global
void click_scroll_list(LOCK lock, OBJECT *form, int item, MOOSE_DATA *md)
{
	SCROLL_INFO *list;
	SCROLL_ENTRY *this;
	OBJECT *ob = form + item;
	G_i cy = md->y;

	list = get_ob_spec(ob)->listbox;

	if (!do_widgets(lock, list->wi, 0, md))		/* HR 161101: mask */
	{
		G_i y = screen.c_max_h;

		cy -= list->wi->wa.y;

		this = list->top;
		while(this and y < cy)
		{
			this = this->next;
			y += screen.c_max_h;
		}

		if (this)
		{
			list->cur = this;			

/* HR 290702 (do without parent window; A listbox is a OBJECT and part of a object tree.) */
/* HR 111102 Nasty bug :-(  list->click can close the whole window containing the list.
            So the below draw is moved from the end of this function to here. */

			draw_object_tree(lock, list->wt, form, item, 2, 200);

			if (list->click)			/* Call the new object selected function */
				(*list->click)(lock, form, item);
		}
	}
}

global
void dclick_scroll_list(LOCK lock, OBJECT *form, int item, MOOSE_DATA *md)
{
	SCROLL_INFO *list;
	SCROLL_ENTRY *this;
	OBJECT *ob = form + item;
	G_i y = screen.c_max_h, cx = md->x, cy = md->y;	

	list = get_ob_spec(ob)->listbox;

	if (!do_widgets(lock, list->wi, 0, md))		/* HR 161101: mask */
	{
		if (!m_inside(cx, cy, &list->wi->wa))
			return;
	
		cy -= list->wi->wa.y;
	
		this = list->top;
		while(this and y < cy)
		{
			this = this->next;
			y += screen.c_max_h;
		}
	
		if (this)
			list->cur = this;
		
		if (list->dclick)
			(*list->dclick)(lock, form, item);
	}
}
