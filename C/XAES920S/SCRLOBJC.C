/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <stdlib.h>
#include <osbind.h>
#include <mintbind.h>
#ifdef LATTICE
#undef abs		/* MiNTlib (PL46) #define is buggy! */
#define abs(i)	__builtin_abs(i)
#endif

#include "xa_types.h"
#include "xa_globl.h"

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
	XA_WINDOW *w = list->wi;
	XA_SLIDER_WIDGET *sl;
	short top, wr;

	if (w->active_widgets & VSLIDE)
	{
		sl = w->widgets[XAW_VSLIDE].stuff;

		top = list->top ? list->top->n : 1,
		wr  = list->n - list->s;		/* total - win size */
	
		if (list->s < list->n)
			sl->length = (1000L*list->s)/list->n;
		else
			sl->length = 1000;
	
		if (wr < 0 or top == 1)
			sl->position = 0;
		else
			if (top + list->s >= list->n)
				sl->position = 1000;
			else
				sl->position = (1000L*top)/wr;
	}

	if (w->active_widgets & HSLIDE)
	{
		sl = w->widgets[XAW_HSLIDE].stuff;

		wr = list->max - list->v;			/* max - visible */

		if (list->v < list->max)
			sl->length = (1000L*list->v)/list->max;
		else
			sl->length = 1000;

		if (wr < 0 or list->left == 0)
			sl->position = 0;
		else
			if (list->left + list->v >= list->max)
				sl->position = 1000;
			else
				sl->position = (1000L*list->left)/wr;
	}

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
	list->start = list->cur = list->top = list->last = nil;
}

short max(short n, short m);

static
void visible(SCROLL_INFO *list, SCROLL_ENTRY *s)
{
	if (list->top and (s->n < list->top->n or s->n > list->bot->n))
	{
		short n = list->s/2;
		list->top = s;
		while (n-- and list->top->prev)		/* move to the middle */
			list->top = list->top->prev;
		n = list->s - (list->last->n - list->top->n + 1);
		if (n > 0)
			while (n-- and list->top->prev)
				list->top = list->top->prev;
	}

	list->slider(list);
	display_toolbar(list->lock, list->pw, list->item);
}

/*
 *	Setup a scrolling list structure for an object
 *	- I've provided this as I don't expect any resource editor to support
 *	XaAES' extensions to the object types...
 */

/* HR: title set by set_slist_widget() */
global
short set_scroll(XA_CLIENT *client, OBJECT *form, short item)
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
XA_WINDOW *set_slist_widget(
			LOCK lock,
            short pid,
            XA_WINDOW *parent_window,
			OBJECT *form,
			short item,
			scrl_widget *closer,
			scrl_widget *fuller,
			scrl_click *dclick,
			scrl_click *click,
			char *title,
			char *info,
			short lmax		/* Used to determine whether a horizontal slider is needed. */
			)
{
	RECT r;
	XA_WIND_ATTR wkind = UPARROW|VSLIDE|DNARROW;
	OBJECT *ob = form + item;
	SCROLL_INFO *list = get_ob_spec(ob)->listbox;

	list->pw = parent_window;		/* Needed to be able to move */
	list->dclick = dclick;			/* Pass the scroll list's double click function */
	list->click = click;			/* Pass the scroll list's click function */

	list->title = title;
	/* rp_2_ap; it is an OBJECT, not a widget */
	r = ob->r;
	/* We want to use the space normally occupied by the shadow;
	    so we do a little cheat here. */
	r.w += SHADOW_OFFSET;
	r.h += SHADOW_OFFSET;
	object_offset(form, item, &r.x, &r.y);
	if (title)
		wkind |= NAME;
	if (info)
		wkind |= INFO;
	if (closer)
		wkind |= CLOSER;
	if (fuller)
		wkind |= FULLER;
	if (lmax*screen.c_max_w + ICON_W > r.w - 24)
		wkind |= LFARROW|HSLIDE|RTARROW;
	wkind |= NO_WORK;

	list->wi = create_window(lock, slist_msg_handler, pid,
								 	true, 					/* nolist */
								 	wkind, 0, r,nil,nil);
	if (list->wi)
	{
		short dh;
		list->wi->widgets[XAW_TITLE].stuff = title;
		if (info)
			list->wi->widgets[XAW_INFO].stuff = info;
		list->wi->winob = form;		/* The parent object of the windowed list box */
		list->wi->item = item;
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

		list->v = (r.w - ICON_W) / screen.c_max_w;
		list->max = lmax;

		calc_work_area(list->wi);	/* recalc for aligned work area */
	}
	return list->wi;
}

/* HR: better control over the content of scroll_entry. */
global
bool add_scroll_entry(OBJECT *form, short item,
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
void empty_scroll_list(OBJECT *form, short item, SCROLL_ENTRY_TYPE flag)
{
	SCROLL_INFO *list;
	SCROLL_ENTRY *this, *next, *prior = nil;
	OBJECT *ob = form + item;
	short n = 0;
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

static
TASK woken_slist		/* HR 230601: big simplification by constructing function do_active_widget() */
{						/*            This eliminates redrawing of the sliders when the mouse isnt moved. */
	C.active_timeout.timeout = 0;
	do_active_widget(tab->lock, tab->client);		/* HR 230601 see also pending_msgs */
}

#if 1
/* HR: The application point of view of the list box */
/* HR: Immensely cleanup of the code by using a window and it's mechanisms for the list box.
       Including fully functional sliders and all arrows.
*/
static
SendMessage slist_msg_handler
/* dest_pid, msg, source_pid, mp3, mp4, mp5, mp6, mp7 */
{
	SCROLL_INFO *list;
	SCROLL_ENTRY *old;
	OBJECT *ob;
	short p,ol;

	ob = w->winob + w->item;
	list = get_ob_spec(ob)->listbox;
	old = list->top;
	ol  = list->left;

	switch (msg)
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
			short new = (((long)list->n - (p-1)) * mp4) / 1000;
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
			list->left = (((long)list->max - p) * mp4) / 1000;
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
		display_toolbar(list->lock, list->pw, list->item);
	}

	/* Because we are not really sending something, but just immediately act,
	   we wont be woken up after this. So instead we set up a small timer for
	   the kernel to wake us up;
	   This is immensely better then the original Fselect in it's own loop.
	*/

	{
		Tab *t = &C.active_timeout;
		MENU_TASK *k = &t->task_data.menu;
		vq_mouse(C.vh,&k->exit_mb,&k->x,&k->y);
		if (k->exit_mb)						/* still down? */
		{
			t->timeout = 50;
			t->wind = w;
			t->client = w->owner;			/* HR 090801 :-) */
			t->task = woken_slist;
			t->lock = lock;
		}
	}
}

global
short scrl_cursor(SCROLL_INFO *list, short keycode)
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
		slist_msg_handler(true,list->wi,0,WM_ARROWED,0,list->wi->handle,WA_UPPAGE,1,0,0);
		return keycode;
	case 0x5032:			/* shift + down arrow */
	case 0x5100:			/* page down */
		slist_msg_handler(true,list->wi,0,WM_ARROWED,0,list->wi->handle,WA_DNPAGE,1,0,0);
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

global
void click_scroll_list(LOCK lock, OBJECT *form, short item, short cx, short cy)
{
	SCROLL_INFO *list;
	SCROLL_ENTRY *this;
	OBJECT *ob = form + item;
	MOOSE_DATA md;

	list = get_ob_spec(ob)->listbox;
	if (list->pw == window_list)
	{
		md.x = cx;
		md.y = cy;
		md.state = 0;
		md.clicks = 1;
	
		if (!do_widgets(lock, list->wi, &md))
		{
			short y = screen.c_max_h;
	
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
				if (list->click)			/* Call the new object selected function */
					(*list->click)(lock, form, item);
			}
	
			display_toolbar(list->lock, list->pw, list->item);
		}
	}
}

global
void dclick_scroll_list(LOCK lock, OBJECT *form, short item, short cx, short cy)
{
	SCROLL_INFO *list;
	SCROLL_ENTRY *this;
	OBJECT *ob = form + item;
	short y = screen.c_max_h;	

	list = get_ob_spec(ob)->listbox;

	if (list->pw == window_list)
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
#else
#include "obsolete/clckscrl.h"
#endif
