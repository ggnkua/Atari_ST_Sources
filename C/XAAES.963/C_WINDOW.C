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
#include "c_window.h"
#include "rectlist.h"
#include "objects.h"
#include "scrlobjc.h"
#include "widgets.h"
#include "app_man.h"
#include "xa_graf.h"
#include "menuwidg.h"

#define MIN(x,y)	(((x) < (y)) ? (x) : (y))

/*
 *	Window Stack Management Functions
 */

/* HR: I hated the kind of runaway behaviour (return wind_handle++)
		So here is my solution:
   Window handle bit array (used to generate unique window handles)
   As this fills up, there may be a problem if a user opens
   more than MAX_WINDOWS windows concurrently :-)
 */
static
unsigned long wind_handle[MAX_WINDOWS/LBITS];

static
int new_wind_handle(void)
{
	unsigned long *j = wind_handle, l;
	while (*j == LFULL) j++;
	l = (j - wind_handle)/LBITS;
	while (btst(wind_handle,l)) l++;
	bset(wind_handle,l);
	return l;
}

static
void free_wind_handle(int h)
{
	bclr(wind_handle,h);
}

global
void clear_wind_handles(void)
{
	int f;
	for (f = 0; f < (MAX_WINDOWS/LBITS); f++)
		wind_handle[f]=0;
}

/*
 * Find first free position for iconification.
 */

RECT free_icon_pos(LOCK lock)
{
	RECT ic;
	int i = 0;

	IFWL(Sema_Up(winlist);)

	do					
	{
		XA_WINDOW *w = window_list;
		ic = iconify_grid(i++);
		
		while (w)			/* HR: find first unused position. */
		{
			if (w->window_status == XAWS_ICONIFIED)
				if (w->r.x == ic.x and w->r.y == ic.y)
					break;			/* position occupied; advance with next position in grid. */
			w = w->next;
		}
		if (!w)
			break;		/* position not in list of iconified windows, so it is free. */
	}
	od

	IFWL(Sema_Dn(winlist);)
	return ic;
}

/*
 * Check if a new menu and/or desktop is needed
 */
static
void check_menu_desktop(LOCK lock, XA_WINDOW *old_top, XA_WINDOW *new_top)
{
/* If we're getting a new top window, we may need to swap menu bars... */
/* HR */
	if (old_top)
	if (old_top->owner != new_top->owner)	/* If we're getting a new top window, we may need */
	{
		Sema_Up(desk);

DIAG((D_appl,nil,"check_menu_desktop from %s to %s\n", old_top->owner->name, new_top->owner->name));
		swap_menu(lock|desk, new_top->owner, true, 2);

		Sema_Dn(desk);
	}
}

static
RECT wa_to_curr(XA_WINDOW *wi, int d, RECT r)
{
	r.x += wi->bd.x - d;
	r.y += wi->bd.y - d;
	r.w += wi->bd.w + d+d;
	r.h += wi->bd.h + d+d;
	return r;
}

static
RECT bound_inside(RECT r, RECT o)
{
	if (r.x       < o.x      ) r.x  = o.x;
	if (r.y       < o.y      ) r.y  = o.y;
	if (r.x + r.w > o.x + o.w) r.w -= (r.x + r.w) - (o.x + o.w);
	if (r.y + r.h > o.y + o.h) r.h -= (r.y + r.h) - (o.y + o.h);
	return r;
}

global
XA_WIND_ATTR hide_move(OPT *o)
{
	XA_WIND_ATTR kind = 0;
	if (!o->xa_nohide)
		kind |= HIDE;
	if (!o->xa_nomove)
		kind |= MOVE;
	return kind;
}

global
void inside_root(RECT *r, OPT *o)		/* HR */
{
	if (r->y < root_window->wa.y)
		r->y = root_window->wa.y;
	if (o->noleft)						/* HR 240901 */
		if (r->x < root_window->wa.x)
			r->x = root_window->wa.x;
}

static
void wi_put_first(WIN_BASE *b, XA_WINDOW *w)
{
	if (b->first)
	{
		w->next = b->first;
		w->prev = nil;
		b->first->prev = w;
	othw
		b->last = w;
		w->next = w->prev = nil;
	}
	b->first = w;
#if 0
	w = b->first;
	while (w)
		display("pf: %d pr:%d\n", w->handle, w->prev ? w->prev->handle : -1), w = w->next;
#endif
}

static
void wi_put_last(WIN_BASE *b, XA_WINDOW *w)
{
	if (b->last)
	{
		w->prev = b->last;
		b->last->next = w;
		b->last = w;
		w->next = nil;
	othw
		b->first = b->last = w;
		w->next = w->prev = nil;
	}
#if 0
	w = b->first;
	while (w)
		display("pl: %d pr:%d\n", w->handle, w->prev ? w->prev->handle : -1), w = w->next;
#endif
}

/* This a special version of put last; it puts w just befor last. */
static
void wi_put_blast(WIN_BASE *b, XA_WINDOW *w)
{
	if (b->last)
	{
		XA_WINDOW *l = b->last;
		w->next = l;
		w->prev = l->prev;
		if (l->prev)
			l->prev->next = w;
		l->prev = w;
	othw
		b->first = b->last = w;
		w->next = w->prev = nil;
	}
#if 0
	w = b->first;
	while (w)
		display("pl: %d pr:%d\n", w->handle, w->prev ? w->prev->handle : -1), w = w->next;
#endif
}

static
void wi_remove(WIN_BASE *b, XA_WINDOW *w)
{
	if (w->prev)
		w->prev->next = w->next;
	if (w->next)
		w->next->prev = w->prev;
	if (w == b->first)
		b->first = w->next;
	if (w == b->last)
		b->last = w->prev;
	w->next = nil;
	w->prev = nil;
#if 0
	w = b->first;
	while (w)
		display("rem: %d pr:%d\n", w->handle, w->prev ? w->prev->handle : -1), w = w->next;
#endif
}

static
void wi_insert(WIN_BASE *b, XA_WINDOW *w, XA_WINDOW *after)
{
	if (after)
	{
		if (after != b->last)
		{
			w->next = after->next;
			w->prev = after;
			if (after->next)
			{
				if (after->next == b->last)
					b->last = w;
				after->next->prev = w;
			}
			after->next = w;
		}
	}
	else
		wi_put_first(b, w);
#if 0
	w = b->first;
	while (w)
		display("rem: %d pr:%d\n", w->handle, w->prev ? w->prev->handle : -1), w = w->next;
#endif
}

/* HR 190801 */
global
XA_WINDOW *get_top(void)
{
	return S.open_windows.first;
}

/* HR 210801 */
global
bool is_hidden(XA_WINDOW *wind)
{
	RECT d = root_window->r;
	return !rc_intersect(wind->r, &d);
}

global
bool unhide(XA_WINDOW *wind, G_i *x, G_i *y)
{
	RECT r = wind->r;
	bool done = false;

	if (is_hidden(wind))
	{
		RECT d = root_window->r;

		while (r.x + r.w < d.x)
			r.x += d.w;
		while (r.y + r.h < d.y)
			r.y += d.h;
		if (r.y < root_window->wa.y)
			r.y = root_window->wa.y;	/* HR 241101: make shure the mover becomes visible. */
		while (r.x > d.x + d.w)
			r.x -= d.w;
		while (r.y > d.y + d.h)
			r.y -= d.h;
		done = true;
	}
	*x = r.x;
	*y = r.y;
	return done;
}

global
void unhide_window(LOCK lock, XA_WINDOW *wind)
{
	RECT r = wind->r;
	if (unhide(wind, &r.x, &r.y))
		if (wind->send_message)
			wind->send_message(lock, wind, nil,
				WM_MOVED, 0, 0, wind->handle,
				r.x, r.y, r.w, r.h);
		else
			move_window(lock, wind, -1, r.x, r.y, r.w, r.h);
}

/* SendMessage */
/* HR 090801 */
void send_untop(LOCK lock, XA_WINDOW *wind)
{
	XA_CLIENT *client = wind->owner;

	if (wind->send_message and !client->fmd.wind)
		wind->send_message(lock, wind, nil,
				WM_UNTOPPED, 0, 0, wind->handle,
				0, 0, 0, 0);
}

/* HR 060801 */
global
void send_ontop(LOCK lock)
{
	XA_WINDOW *top = window_list;
	XA_CLIENT *client = top->owner;

	if (top->send_message and !client->fmd.wind)
		top->send_message(lock, top, nil,
				WM_ONTOP, 0, 0, top->handle,
				0, 0, 0, 0);
}

/*
 * Create a window
 *
 * HR: introduced pid -1 for temporary windows created basicly only to be able to do
 *     calc_work_area and center.
 */
/* HR: needed a dynamiccally sized frame */
global
XA_WINDOW *create_window(LOCK lock,
						SendMessage *message_handler,
						XA_CLIENT *client,
						bool nolist,
						XA_WIND_ATTR tp,
						WINDOW_TYPE dial,
						int frame,
						int thinframe,
						bool thinwork,
						RECT r,
						RECT *max,
						RECT *remember)
{
	XA_WINDOW *new;

#if GENERATE_DIAGS
	if (max)
	{
		DIAG((D_wind, client, "create_window for %s: r:%d,%d/%d,%d  max:%d,%d/%d,%d\n",
				c_owner(client), r.x,r.y,r.w,r.h,max->x,max->y,max->w,max->h));
	othw
		DIAG((D_wind, client, "create_window for %s: r:%d,%d/%d,%d  no max\n",
				c_owner(client), r.x,r.y,r.w,r.h));
	}
#endif

	new = xcalloc(1, sizeof(XA_WINDOW),104);		/* HR: Use calloc */
	if (!new)				/* Unable to allocate memory for window? */
		return nil;

/* HR: avoid confusion: if only 1 specified, give both (fail safe!) */
	if ((tp&UPARROW) or (tp&DNARROW))
		tp|=UPARROW|DNARROW;
	if ((tp&LFARROW) or (tp&RTARROW))
		tp|=LFARROW|RTARROW;
/* HR 210801: cant hide a window that cannot be moved. */
	if ((tp&MOVE) == 0)
		tp&=~HIDE;
	if (tp&MENUBAR)			/* HR 190202: temporary until solved. */
		tp |= XaMENU;

	new->max = max ? *max : root_window->wa;		/* HR: implement maximum rectangle (needed for at least TosWin2) */
		
	new->r  = r;
	new->pr = new->r;

	if (!MONO and frame > 0)
		if (thinframe < 0)		/* HR 270901 */
			frame = 1;
			
/*	if ((tp & (SIZE|MOVE)) == (SIZE|MOVE))		/* HR 280102: implement border sizing. */
*/		if (frame > 0 and thinframe > 0)
			frame += thinframe;					/* see how well it performs. */

	new->frame = frame;
	new->thinwork = thinwork;
	new->owner = client;			/* HR */
	new->rect_user = new->rect_list = new->rect_start = nil;
	new->handle = -1;
	new->window_status = XAWS_CLOSED;
	new->remember = remember;
	new->nolist = nolist;
	new->dial = dial;		/* HR */
	new->send_message = message_handler;	/* HR */
	get_widget(new, XAW_TITLE)->stuff = client->name;		/* HR 271101 */

	if (nolist)				/* HR: Dont put in the windowlist */
		standard_widgets(new, tp, false);		/* Attach the appropriate widgets to the window */
	else
	{
		/* HR */
		IFWL(Sema_Up(winlist);)

		new->handle = new_wind_handle();			/* HR */
		DIAG((D_wind,client," allocated handle = %d\n", new->handle));

		wi_put_first(&S.closed_windows, new);
		DIAG((D_wind,client," inserted in closed_windows list\n"));

		IFWL(Sema_Dn(winlist);)
	
		standard_widgets(new, tp,false);		/* Attach the appropriate widgets to the window */
	
		if (tp & STORE_BACK)	/* If STORE_BACK extended attribute is used, window preserves its own background */
		{
			DIAG((D_wind,client," allocating background storage buffer\n"));
			new->background = xmalloc(calc_back(&r, screen.planes),6);			/* HR */
		}
		else
			new->background = nil;

	}

	calc_work_area(new);

	if (remember)						/* HR */
		*remember = new->r;

	return new;
}

/* HR: separate function now, to ease draw testing */
global
int open_window(LOCK lock, XA_WINDOW *wind, RECT r)
{
	IFDIAG(XA_CLIENT *client = wind->owner;)
	XA_WINDOW *wl = window_list;
	RECT clip, our_win;

	DIAG((D_wind,client,"open_window %d for %s to %d/%d,%d/%d status %x\n",
						wind->handle, c_owner(client), r.x,r.y,r.w,r.h, wind->window_status));

#if 0
	if (r.w <= 0) r.w = 6*cfg.widg_w;
	if (r.h <= 0) r.h = 6*cfg.widg_h;
#endif

	if (wind->nolist)		/* HR: dont open unlisted windows */
		return 0;

	if (wind->is_open == true)		/* The window is already open, no need to do anything */
	{	DIAGS(("WARNING: Attempt to open window when it was already open\n"));
		return 0;
	}

	IFWL(Sema_Up(winlist);)

	wi_remove   (&S.closed_windows, wind);
	wi_put_first(&S.open_windows, wind);

	C.focus = wind;

	/* New top window - change the cursor to this client's choice */
	graf_mouse(wind->owner->mouse, wind->owner->mouse_form);

	if (wind->window_status == XAWS_ICONIFIED)			/* HR 310302 */
	{
		if (r.w != -1 and r.h != -1)
			wind->r = r;
		if (wind != root_window)
			inside_root(&wind->r, &wind->owner->options);		/* HR */
	} else
	{
		wind->r = r;				/* Change the window coords */
	
		wind->window_status = XAWS_OPEN;
	}

	wind->is_open = true;				/* Flag window as open */

	calc_work_area(wind);

	check_menu_desktop(lock|winlist, wl, wind);

	if (wind->active_widgets & STORE_BACK)		/* Is this a 'preserve own background' window? */
	{
		wind->background = form_save(0, wind->r, nil);
		draw_window(lock|winlist, wind);		/* This is enough, it is only for TOOLBAR windows. */
	othw
		our_win = wind->r;
	
		wl = wind;
		while (wl)
		{
			clip = wl->r;
			if (rc_intersect(our_win, &clip))
				generate_rect_list(lock|winlist, wl, 1);
			wl = wl->next;
		}

/* HR: streamlining the topping */
		after_top(lock|winlist, true);

		display_window(lock|winlist, 10, wind, nil);		/* Display the window using clipping rectangles from the rectangle list */
	
		via (wind->send_message)(lock|winlist, wind, nil,
					WM_REDRAW, 0, 0, wind->handle,
					wind->r.x, wind->r.y, wind->r.w, wind->r.h);
	}

	IFWL(Sema_Dn(winlist);)
	return 1;
}

static
void if_bar(G_i pnt[4])
{
	if ((pnt[2] - pnt[0]) !=0 and (pnt[3] - pnt[1]) != 0)
		v_bar(C.vh, pnt);
}

/*
 * Display a window
 */

global
void draw_window(LOCK lock,XA_WINDOW *wind)
{
	if (!wind->is_open)
	{
		DIAG((D_wind,wind->owner,"window %d for %s not open\n", wind->handle, w_owner(wind)));
		return;
	}

	l_color(BLACK);
	hidem();

	if (wind != root_window)		/* HR: Dont waste precious CRT glass */
	{
		RECT cl = wind->r,
		     wa = wind->wa;

		/* Display the window backdrop (borders only, GEM style) */

		cl.w-=SHADOW_OFFSET;
		cl.h-=SHADOW_OFFSET;
#if 0
		if (wind->active_widgets & TOOLBAR)
		{							/* whole plane */
			if (wind->frame > 0)
				if (MONO)
					p_gbar(0, &cl);
				else
					gbar  (0, &cl);		
		}
		else
#endif
		if ((wind->active_widgets & V_WIDG) == 0)
		{
			if (wind->frame > 0)
				gbox(0, &cl);
		othw
			G_i pnt[8];

			f_color(screen.dial_colours.bg_col);
			f_interior(FIS_SOLID);

			pnt[0] = cl.x;
			pnt[1] = cl.y;
			pnt[2] = cl.x + cl.w - 1;
			pnt[3] = wa.y - 1;
			if_bar(pnt);				/* top */
			pnt[1] = wa.y + wa.h;
			pnt[3] = cl.y + cl.h - 1;
			if_bar(pnt);				/* bottom */
			pnt[0] = cl.x;
			pnt[1] = cl.y;
			pnt[2] = wa.x - 1;
			if_bar(pnt);				/* left */
			pnt[0] = wa.x + wa.w;
			pnt[2] = cl.x + cl.w - 1;
			if_bar(pnt);				/* right */

			/* Display the work area */

			if (MONO)
			{
				if (wind->frame > 0)
					gbox(0, &cl);
				gbox(1, &wa);
			othw
				if (wind->thinwork)		/* HR 270901 */
					gbox(1, &wa);
				else
				{
					RECT nw = wa;
					nw.w++;
					nw.h++;
					br_hook(2, &nw, screen.dial_colours.shadow_col);
					tl_hook(2, &nw, screen.dial_colours.lit_col);
					br_hook(1, &nw, screen.dial_colours.lit_col);
					tl_hook(1, &nw, screen.dial_colours.shadow_col);
				}
			}
		}

/*		if (wind->outline_adjust)		/* HR 250602: for outlined windowed objects */
		{
			l_color(screen.dial_colours.bg_col);
			gbox( 0, &wa);
			gbox(-1, &wa);
			gbox(-2, &wa);
		}
*/
		if (wind->frame > 0)
		{
			shadow_object(0, SHADOWED, &cl, BLACK, SHADOW_OFFSET/2);

#if 0		/* only usefull if we can distinguish between
				top left margin and bottom right margin, which currently is
					  not the case */
			if (!MONO)
				tl_hook(0, &cl, screen.dial_colours.lit_col);
#endif
		}
	}

	/* If the window has an auto-redraw function, call it */
	/* HR: do this before the widgets. (some programs supply x=0, y=0) */

	if (wind->redraw) /*  and !wind->owner->killed */
		wind->redraw(lock, wind);

	/* Go through and display the window widgets using their display behaviour */
	if (wind->window_status == XAWS_ICONIFIED)
	{
		XA_WIDGET *widg = get_widget(wind, XAW_TITLE);
		widg->display(lock, wind, widg);
		widg = get_widget(wind, XAW_ICONIFY);
		widg->display(lock, wind, widg);
	} else
	{
		int f;
		for (f = 0; f < XA_MAX_WIDGETS; f++)
		{
			XA_WIDGET *widg = get_widget(wind, f);
			if (widg->stuff and wind->owner->killed)
				continue;
			via (widg->display)(lock, wind, widg);
		}
	}

	showm();
}

/* HR */
global
XA_WINDOW *find_window(LOCK lock, int x, int y)
{
	XA_WINDOW *w;

	IFWL(Sema_Up(winlist);)

	w = window_list;
	while(w)
		if (m_inside(x, y, &w->r))
			break;
		else
			w = w->next;

	IFWL(Sema_Dn(winlist);)
	return w;
}

global
XA_WINDOW *get_wind_by_handle(LOCK lock, int h)
{
	XA_WINDOW *w;

	IFWL(Sema_Up(winlist);)

	w = window_list;
	while(w)
		if (w->handle != h)
			w = w->next;
		else
			break;

	if (!w)
	{
		w = S.closed_windows.first;
		while(w)
			if (w->handle != h)
				w = w->next;
			else
				break;
	}

	IFWL(Sema_Dn(winlist);)
	return w;
}

/*
 *  HR: Handle windows after topping
 */
global
void after_top(LOCK lock, bool untop)
{
	XA_WINDOW *below;

	IFWL(Sema_Up(winlist);)
		
	below = window_list->next;
	
	if (below)		/* Refresh the previous top window as being 'non-topped' */
	if (below != root_window)
	{
		display_window(lock, 11, below, nil);

		if (untop)
			send_untop(lock, below);
	}

	IFWL(Sema_Dn(winlist);)
}

/*
 *	Pull this window to the head of the window list
 */
XA_WINDOW * pull_wind_to_top(LOCK lock, XA_WINDOW *w)
{
	LOCK wlock = lock|winlist;
	XA_WINDOW *wl;
	RECT clip, r;

	DIAG((D_wind,w->owner,"pull_wind_to_top %d for %s\n", w->handle, w_owner(w)));

	IFWL(Sema_Up(winlist);)

	check_menu_desktop(wlock, window_list, w);

	if (w == root_window)			/* HR: just a safeguard */
		generate_rect_list(wlock, w, 3);
	else
	{	
		wl = w->prev;
		r = w->r;

	/* HR 251002: Very small change in logic for was_visible() optimization.
	              It eliminates a spurious generate_rect_list() call, which
	              spoiled the setting of rect_prev.                          */

		if (w != window_list)	
		{
			wi_remove   (&S.open_windows, w);
			wi_put_first(&S.open_windows, w);

			while(wl)
			{
				clip = wl->r;
				DIAG((D_r, wl->owner, "wllist %d\n", wl->handle));
				if (rc_intersect(r, &clip))
					generate_rect_list(wlock, wl, 2);
				wl = wl->prev;
			}
		}
		else			/* already on top */
			generate_rect_list(wlock, w, 3);
	}

	IFWL(Sema_Dn(winlist);)

	return w;
}

void send_wind_to_bottom(LOCK lock, XA_WINDOW *w)
{
	XA_WINDOW *wl;
	XA_WINDOW *old_top = window_list;

	RECT r, clip;

	if (   w->next == root_window		/* Can't send to the bottom a window that's already there */
		or w       == root_window		/* HR: just a safeguard */
		or w->is_open == false			/* HR */
		)
		return;

	IFWL(Sema_Up(winlist);)

	wl = w->next;
	r = w->r;

	wi_remove   (&S.open_windows, w);
	wi_put_blast(&S.open_windows, w);		/* put before last; last = root_window. */

	while (wl)
	{
		clip = wl->r;
		if (rc_intersect(r, &clip))
			generate_rect_list(lock|winlist, wl, 4);
		wl = wl->next;
	}

	generate_rect_list(lock|winlist, w, 5);

/* HR */
	check_menu_desktop(lock|winlist, old_top, window_list);

	IFWL(Sema_Dn(winlist);)
}

/*
 * Change an open window's coordinates, updating rectangle lists as appropriate
 */
void move_window(LOCK lock, XA_WINDOW *wind, int newstate, int x, int y, int w, int h)
{
	LOCK wlock = lock|winlist;
	IFDIAG(XA_CLIENT *client = wind->owner;)
	XA_WINDOW *wl;
	RECT old, new, clip, oldw, pr;
	bool blit_mode;

	IFWL(Sema_Up(winlist);)

DIAG((D_wind,client,"move_window(%s) %d for %s from %d/%d,%d/%d to %d/%d,%d,%d\n",
	wind->is_open ? "open" : "closed",
	wind->handle, c_owner(client), wind->r.x,wind->r.y,wind->r.w,wind->r.h, x,y,w,h));

/*	temporary commented out, because I dont know exactly the consequences.
	if (x != wind->r.x or y != wind->r.y or w != wind->r.w or h != wind->r.h)	/* HR: avoid spurious moves or sizings */
*/	{
		pr = wind->r;

		if (newstate >= 0)
		{
			wind->window_status = newstate;
			if (newstate == XAWS_ICONIFIED)
				wind->ro = wind->r;
		}
		else
			wind->pr = wind->r;				/* Save windows previous coords */
		old = wind->r;
		oldw = wind->wa;

		wind->r.x = x;					/* Change the window coords */
		wind->r.y = y;
		wind->r.w = w;
		wind->r.h = h;

		inside_root(&wind->r, &wind->owner->options);			/* HR */

		new = wind->r;

		blit_mode =(    wind == window_list
					and (wind->active_widgets&TOOLBAR) == 0		/* HR 290702: temporary slist workarea hack */
					and (pr.x != new.x or pr.y != new.y)
					and pr.w == new.w
					and pr.h == new.h
					and pr.x >= 0		/* HR 210501 */
					and pr.y >= 0
					and pr.x + pr.w < screen.r.w
					and pr.y + pr.h < screen.r.h
					and new.x + new.w < screen.r.w
					and new.y + new.h < screen.r.h
					);

		calc_work_area(wind);	/* Recalculate the work area (as well as moving, */
								/*  it might have changed size). */
	
		if (wind->is_open)		/* HR: Is it allowed to move a closed window? */
		{
			XA_WIDGET *widg = get_widget(wind, XAW_TOOLBAR);
			XA_TREE *wt = widg->stuff;
			
			if (wt)				/* Temporary hack 070702 */
				if (wt->tree)
					wt->tree->r.x = wind->wa.x,
					wt->tree->r.y = wind->wa.y;

			generate_rect_list(wlock, wind, 6);			/* Update the window's rectangle list, it will be out of date now */

			if (blit_mode)	/* If window is being blit mode transferred, do the blit instead of redrawing */
			{
				DIAG((D_wind,client,"blit\n"));
				form_copy(&pr, &new);
			}
			else
			{
				display_window(wlock, 12, wind, nil);
				if (wind->send_message)		/* Does this window's application want messages? If so send it a redraw */
				{
					/* moved? */
					if (new.x != pr.x or new.y != pr.y)
					{
						DIAG((D_wind,client,"moved\n"));
						wind->send_message(wlock, wind, nil,
									WM_REDRAW, 0, 0, wind->handle,
									wind->wa.x, wind->wa.y, wind->wa.w, wind->wa.h);
					}
					else	/* sized */
					{
						DIAG((D_wind,client,"sized\n"));
						if (wind->wa.w > oldw.w)
						{
							DIAG((D_wind,client,"wider\n"));
							wind->send_message(wlock, wind, nil,
										WM_REDRAW, 0, 0, wind->handle,
										wind->wa.x + oldw.w, wind->wa.y, wind->wa.w - oldw.w, MIN(oldw.h, wind->wa.h));
						}
						if (wind->wa.h > oldw.h)
						{
							DIAG((D_wind,client,"higher\n"));
							wind->send_message(wlock, wind, nil,
										WM_REDRAW, 0, 0, wind->handle,
										wind->wa.x, wind->wa.y + oldw.h, wind->wa.w, wind->wa.h - oldw.h);
						}
					}
				}
			}
		
			wl = wind->next;

/* HR: For some reason the open window had got behind root!!! This was caused by the
   problems with the SIGCHILD stuff (the root window was pulled to top!)
   I've put a safeguard there, so that all the below kind of loops can be trusted.
*/
			while (wl)
			{
				DIAG((D_wind,wl->owner,"[1]redisplay %d\n", wl->handle));
				clip = wl->r;
				if (rc_intersect(old, &clip))		/* Check for newly exposed windows */
				{			
					generate_rect_list(wlock, wl, 7);
					display_window(wlock, 13, wl, &clip);
					via (wl->send_message)(wlock, wl, nil,
							WM_REDRAW, 0, 0, wl->handle,
							clip.x, clip.y, clip.w, clip.h);
				} else
				{
					clip = wl->r;
					if (rc_intersect(new, &clip))		/* Check for newly covered windows */
						generate_rect_list(wlock, wl, 8);			/* We don't need to send a redraw to these windows, we just have to update their rect lists */
				}
				wl = wl->next;
			}
	/* HR removed rootwindow stuff, that perfectly worked within the loop. */
		}
	}

	if (wind->remember)						/* HR */
		*wind->remember = wind->r;

	IFWL(Sema_Dn(winlist);)
}

/*
 * Close an open window and re-display any windows underneath it.
 * Also places window in the closed_windows list but does NOT delete it
 * - the window will still exist after this call.
 */
bool close_window(LOCK lock, XA_WINDOW *wind)
{
	XA_WINDOW *wl;
	XA_CLIENT *client = wind->owner;
	RECT r, clip;
	bool is_top;
	
	if (wind == nil)
	{
		DIAGS(("close_window: null window pointer\n"));
		return false;					/* Invalid window handle, return error */
	}

	DIAG((D_wind,wind->owner,"close_window: %d (%s)\n", wind->handle, wind->is_open ? "open" : "closed"));

	if (wind->is_open == false or wind->nolist)
		return false;
	
	IFWL(Sema_Up(winlist);)

	is_top = (wind == window_list);
	r = wind->r;

	if (wind->rect_start)				/* HR 211002 */
		free(wind->rect_start);
	wind->rect_user = wind->rect_list = wind->rect_start = nil;
	wi_remove   (&S.open_windows, wind);
	wi_put_first(&S.closed_windows, wind);
	
	wind->is_open = false;					/* Tag window as closed */
	wind->window_status = XAWS_CLOSED;

	wl = window_list;

	if (is_top)
	{
		XA_WINDOW *w, *napp = nil;

		if (wind->active_widgets&STORE_BACK)		/* HR 250602 */
		{
			form_restore(0, wind->r, wind->background);
			free(wind->background);
			wind->background = nil;
			return true;
		}

 		w = window_list;

/*	HR: v_hide/show_c now correctly done in draw_window()  */
/*  HR: if you want point_to_type, handle that in do_keyboard */

/* First: find a window of the owner */
		while (w)
		{
			if (w != root_window)
			{ 
				if (w->owner == client)		/* gotcha */
				{
					top_window(lock|winlist, w, client);		/* HR */
					send_ontop(lock);	/* HR 060801: send WM_ONTOP to just topped window. */
					wl = w->next;
					break;
				}
				else
				if (!napp)
					napp = w;	/* remember the first window of another app. */
			}

			w = w->next;

			if (w == nil and napp)
			{
/* Second: If none: top any other open window  */
/* HR: this is the one I was really missing */
				top_window(lock|winlist, napp, menu_owner());
				send_ontop(lock);	/* HR 060801: send WM_ONTOP to just topped window. */
				wl = window_list->next;
				break;
			}
		}
	}

/* Redisplay any windows below the one we just have closed
   or just have topped
*/
#if 0
	display_windows_below(lock|winlist, &r, wl);
#else
	while(wl)
	{
		clip = wl->r;
		DIAG((D_wind, client, "[2]redisplay %d\n", wl->handle));
		if (rc_intersect(r, &clip))
		{
			DIAG((D_wind, client, "   --   clip %d/%d,%d/%d\n", clip));
			generate_rect_list(lock|winlist, wl, 9);			/* If a new focus was pulled up, some of these are not needed */
			display_window(lock|winlist, 14, wl, &clip);
			via (wl->send_message)(lock|winlist, wl, nil,
					WM_REDRAW, 0, 0, wl->handle,
					clip.x, clip.y, clip.w, clip.h);
		}
		wl = wl->next;
	}
#endif
	if (window_list)						/* HR 060101 */
		if (    window_list->owner != client
			and client->std_menu.tree == nil
			)
		{
	/* HR: get the menu bar right (only if the pid has no menu bar
		and no more open windows for pid. */
			DIAG((D_menu,nil,"close_window: swap_menu to %s\n", w_owner(window_list)));
			swap_menu(lock|winlist, window_list->owner, true, 3);
		}

	IFWL(Sema_Dn(winlist);)

	return true;
}

static
void free_widg(XA_WINDOW *wind, int n)
{
	XA_WIDGET *widg = get_widget(wind, n);
	if (widg->stuff)
	{
		free(widg->stuff);
		widg->stuff = nil;
	}
}

static
void free_standard_widgets(XA_WINDOW *wind)		/* HR: 060101 slider widgets leaked. */
{
/*	free_widg(wind, XAW_MENU);
	free_widg(wind, XAW_TOOLBAR);		stuff is now in XA_WINDOW. */
	free_widg(wind, XAW_HSLIDE);
	free_widg(wind, XAW_VSLIDE);
}

void delete_window(LOCK lock, XA_WINDOW *wind)
{
	IFDIAG(XA_CLIENT *client = wind->owner;)

	if (!wind->nolist)		/* HR */
	{
		if (wind->is_open)			/* We must be sure it is in the correct list. */
		{
			DIAG((D_wind,client,"delete_window %d: not closed\n", wind->handle));
			return;					/* open window, return error */
		}

		DIAG((D_wind,client,"delete_window %d for %s: open? %d\n", wind->handle, w_owner(wind), wind->is_open));
	
		IFWL(Sema_Up(winlist);)

		free_standard_widgets(wind);				/* HR: 060101 slider widgets leaked. */

		if (wind->destructor)
			wind->destructor(lock|winlist, wind);			/* Call the window destructor if any */
		
		free_wind_handle(wind->handle);				/* HR */
	
		if (wind->background)
			free(wind->background);
		
		if (wind->rect_start)
			free(wind->rect_start);

		wi_remove(&S.closed_windows, wind);
		
		IFWL(Sema_Dn(winlist);)
	} else
	{
		free_standard_widgets(wind);
	
		if (wind->destructor)
			wind->destructor(lock, wind);
	}

	free(wind);
}

/*
 * Display a window that isn't on top, respecting clipping
 * - Pass clip == nil to redraw whole window, otherwise clip is a pointer to a GRECT that
 * defines the clip rectangle.
 */
void display_window(LOCK lock, int which, XA_WINDOW *wind, RECT *clip)
{
	if (wind->is_open)
	{
		DIAG((D_wind,wind->owner,"[%d]display_window%s %d for %s to %d/%d,%d/%d\n",
				which, wind->nolist ? "(no_list)" : "", wind->handle, w_owner(wind),
				wind->r.x, wind->r.y, wind->r.w, wind->r.h));
		if (wind->nolist)
			draw_window(lock, wind);
		else
		{
			XA_RECT_LIST *rl;
			rl = rect_get_system_first(wind);
			while(rl)
			{			
				if (clip)
				{
					RECT target = rl->r;				
					if (rc_intersect(*clip, &target))
					{
						set_clip(&target);
DIAG((D_rect,wind->owner,"clip: %d/%d,%d/%d\n",target.x,target.y,target.w,target.h));
						draw_window(lock, wind);
					}
				} else
				{
					set_clip(&rl->r);
					draw_window(lock, wind);
				}
				rl = rect_get_system_next(wind);
			}
			clear_clip();
		}
	}
}

/*
 * Display windows below a given rectangle, starting with window w.
 * HR: at the time only called for form_dial(FMD_FINISH)
 */
void display_windows_below(LOCK lock, RECT *r, XA_WINDOW *wl)
{
	RECT win_r;

	while (wl)
	{
		XA_RECT_LIST *rl = rect_get_system_first(wl);
		while (rl)
		{
			win_r = rl->r;		
			if (rc_intersect(*r, &win_r))
			{
				set_clip(&win_r);
				draw_window(lock, wl);		/* Display the window */
				via (wl->send_message)(lock, wl, nil,
					WM_REDRAW, 0, 0, wl->handle,
					win_r.x, win_r.y, win_r.w, win_r.h);
			}
			rl = rect_get_system_next(wl);
		}
		wl = wl->next;
	}
	clear_clip();
}

/*
 * Calculate window sizes
 *
 *   HR: first intruduction of the use of a fake window (pid=-1) for calculations.
 *         (heavily used by multistrip, as an example.)
 */

static
void Xpolate(RECT *r,RECT *o, RECT *i)
{
/* If you want to prove the maths here, draw two boxes one inside */
/*  the other, then sit and think about it for a while... */
/* HR: very clever :-)   */
	r->x = 2 * o->x - i->x;
	r->y = 2 * o->y - i->y;
	r->w = 2 * o->w - i->w;
	r->h = 2 * o->h - i->h;	
}

global
RECT calc_window(LOCK lock, XA_CLIENT *client, int request, unsigned long tp, int mg, int thinframe, bool thinwork, RECT r)
{
	XA_WINDOW *w_temp;
	RECT o;

	DIAG((D_wind,client,"calc %s from %d/%d,%d/%d\n", request ? "work" : "border", r));

	/* Create a temporary window with the required widgets */
	w_temp = create_window(lock, nil, client, true, tp, 0, mg, thinframe, thinwork, r, nil, nil);	/* HR */

	switch(request)
	{
	case WC_BORDER:						/* We have to work out the border size ourselves here */
		Xpolate(&o, &w_temp->r, &w_temp->wa);
		break;
	case WC_WORK:					/* Work area was calculated when the window was created */
		o = w_temp->wa;
		break;
	default:
		DIAG((D_wind, client, "wind_calc request %d\n", request));
		o = w_temp->wa;	/* HR: return something usefull*/
	}
	DIAG((D_wind,client,"calc returned: %d/%d,%d/%d\n", o));
	delete_window(lock, w_temp);				/* Dispose of the temporary window we created */
	return o;
}
