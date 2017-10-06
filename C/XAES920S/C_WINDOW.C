/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <mintbind.h>

#include "xa_types.h"
#include "xa_globl.h"
#include "c_window.h"
#include "rectlist.h"
#include "objects.h"
#include "scrlobjc.h"
#include RSCHNAME
#include "widgets.h"
#include "app_man.h"
#include "xa_graf.h"

#define MIN(x,y)	(((x) < (y)) ? (x) : (y))

/*
 *	Window Stack Management Functions
 */

/* HR: I hated the kind of runaway behaviour (return wind_handle++)
		So here is my solution:
   Window handle bit array (used to generate unique window handles)
   As this fills up, there may be a problem if a user opens
   more than 32767 windows concurrently :-)
 */
static
unsigned long wind_handle[MAX_WINDOWS/LBITS];

static
short new_wind_handle(void)
{
	unsigned long *j = wind_handle, l;
	while (*j == 0xffffffff) j++;
	l = (j - wind_handle)/LBITS;
	while (btst(wind_handle,l)) l++;
	bset(wind_handle,l);
	return l;
}

static
void free_wind_handle(short h)
{
	bclr(wind_handle,h);
}

global
void clear_wind_handles(void)
{
	short f;
	for (f = 0; f < (MAX_WINDOWS/LBITS); f++)
		wind_handle[f]=0;
}

/*
 * Check if a new menu and/or desktop is needed
 */
static
void check_menu_desktop(LOCK lock, XA_WINDOW *old_top, XA_WINDOW *new_top)
{
/* If we're getting a new top window, we may need to swap menu bars... */
/* HR */
	if (old_top->pid != new_top->pid)	/* If we're getting a new top window, we may need */
	{
		if unlocked(desk)
			Sema_Up(ROOT_SEMA);

DIAG((D.menu,-1,"check_menu_desktop from %s to %s\n", old_top->owner->name, new_top->owner->name));
		swap_menu(lock|desk, new_top->pid, true);

		if unlocked(desk)
			Sema_Dn(ROOT_SEMA);
	}
}

static SendMessage no_messages {}

static
RECT wa_to_curr(XA_WINDOW *wi, short d, RECT r)
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
void inside_root(RECT *r)
{
	if (r->y < root_window->wa.y)
		r->y = root_window->wa.y;
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


/* HR 090801 */
void send_untop(LOCK lock, XA_WINDOW *wind)
{
	if (!(wind->active_widgets & NO_MESSAGES))
		wind->send_message(true, wind, wind->pid, WM_UNTOPPED, 0, wind->handle, 0, 0, 0, 0);
}

/* HR 060801 */
void send_ontop(LOCK lock)
{
	if (!(window_list->active_widgets & NO_MESSAGES))
		window_list->send_message(lock, window_list, window_list->pid, WM_ONTOP, 0, window_list->handle, 0, 0, 0, 0);
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
						short pid,
						bool nolist,
						XA_WIND_ATTR tp,
						short frame,
						RECT r,
						RECT *max,
						RECT *remember)
{
	XA_CLIENT *client = pid > 0 ? Pid2Client(pid) : nil;
	XA_WINDOW *new = xcalloc(1, sizeof(XA_WINDOW),104);		/* HR: Use calloc */

#if GENERATE_DIAGS
	if (max)
	{
		DIAG((D.wind, pid, "create_window for %s(%d): 0x%lx r:%d,%d/%d,%d  max:%d,%d/%d,%d\n",
				client ? client->name : "?", pid, new,r.x,r.y,r.w,r.h,max->x,max->y,max->w,max->h));
	othw
		DIAG((D.wind, pid, "create_window for %s(%d): 0x%lx r:%d,%d/%d,%d  no max\n",
				client ? client->name : "?", pid, new,r.x,r.y,r.w,r.h));
	}
#endif
	if (!new)				/* Unable to allocate memory for window? */
		return nil;

/* HR: avoid confusion: if only 1 specified give both (fail safe!) */
	if ((tp&UPARROW) or (tp&DNARROW))
		tp|=UPARROW|DNARROW;
	if ((tp&LFARROW) or (tp&RTARROW))
		tp|=LFARROW|RTARROW;

	new->max = max ? *max : root_window->wa;		/* HR: implement maximum rectangle (needed for at least TosWin2) */
		
	new->r  = r;
	new->pr = new->r;

	new->frame = frame;
	new->behalf = pid; /* The pid ob behalf of which the window is created. */
						/* Default same as pid. Windowed dialogues must set behalf to client pid. */
	new->pid = pid;
	new->owner = client;			/* HR */
	new->rect_user = new->rect_list = new->rect_start = nil;
	new->handle = -1;
	new->window_status = XAWS_CLOSED;
	new->remember = remember;
	new->nolist = nolist;
	/* HR */
	new->send_message = message_handler ? message_handler : no_messages;
	if (nolist)				/* HR: Dont put in the windowlist */
		standard_widgets(new, tp, false);		/* Attach the appropriate widgets to the window */
	else
	{
		/* HR */
#if !DRAW_TEST
		if unlocked(winlist)
			Sema_Up(WIN_LIST_SEMA);
#endif
		new->handle = new_wind_handle();			/* HR */
		DIAG((D.wind,pid," allocated handle = %d\n", new->handle));

		wi_put_first(&S.closed_windows, new);
		DIAG((D.wind,pid," inserted in closed_windows list\n"));

#if !DRAW_TEST
		if unlocked(winlist)
			Sema_Dn(WIN_LIST_SEMA);
#endif
	
		standard_widgets(new, tp,false);		/* Attach the appropriate widgets to the window */
	
#if PRESERVE_DIALOG_BGD
		if (tp & STORE_BACK)	/* If STORE_BACK extended attribute is used, window preserves its own background */
		{
			DIAG((D.wind,pid," allocating background storage buffer\n"));
			new->background = xmalloc(calc_back(&r, screen.planes),6);			/* HR */
			new->bgx = -1;
		}
		else
#endif
		{
			new->background = nil;
		}
	}

	calc_work_area(new);

	if (remember)						/* HR */
		*remember = new->r;

	return new;
}

/* HR: separate function now, to ease draw testing */
global
short open_window(LOCK lock, short clnt_pid, short wh, RECT r)
{
	XA_WINDOW *w, *wl;
	RECT clip, our_win;

	w = get_wind_by_handle(lock, wh);		/* Get the window */

	DIAG((D.wind,w?w->pid:-1,"open_window %d for %d to %d/%d,%d/%d\n",
						wh, w?w->pid:-1, r.x,r.y,r.w,r.h));

	if (w == nil)
	{	DIAGS(("WARNING:wind_open:Invalid window handle\n"));
		return 0;			/* Invalid window handle, return error */
	}
	
	if (w->nolist)		/* HR: dont open unlisted windows */
		return 0;

	if (w->is_open == true)		/* The window is already open, no need to do anything */
	{	DIAGS(("WARNING: Attempt to open window when it was already open\n"));
		return 0;
	}

	/* New top window - change the cursor to this client's choice */
	graf_mouse(w->owner->client_mouse, w->owner->client_mouse_form);

	if (w != root_window)
		inside_root(&r);		/* HR */

	w->r = r;				/* Change the window coords */
	w->is_open = true;				/* Flag window as open */
	w->window_status = XAWS_OPEN;

	if unlocked(winlist)
		Sema_Up(WIN_LIST_SEMA);

	wi_remove   (&S.closed_windows, w);
	wi_put_first(&S.open_windows, w);
	C.focus = window_list;
	check_menu_desktop(lock|winlist, window_list, w);

	if unlocked(winlist)
		Sema_Dn(WIN_LIST_SEMA);

	our_win = w->r;

	wl = window_list;
	while (wl)
	{
		clip = wl->r;
		if (rc_intersect(&our_win, &clip))
			generate_rect_list(lock, wl);
		wl = wl->next;
	}

	calc_work_area(w);

	swap_menu(lock, window_list->pid, true);			/* HR 040401 */
/* HR: streamlining the topping */
	after_top(lock, true);

	display_non_topped_window(lock, 10, w, nil);		/* Display the window (use the non-topped method as it sets clipping rectangles) */
	w->send_message(lock, w, clnt_pid, WM_REDRAW, 0, w->handle, w->r.x, w->r.y, w->r.w, w->r.h);
	return 1;
}

static
void if_bar(short pnt[4])
{
	if ((pnt[2] - pnt[0]) !=0 and (pnt[3] - pnt[1]) != 0)
		v_bar(C.vh, pnt);
}

/*
 * Display a window
 */

global
void display_window(LOCK lock,XA_WINDOW *wind)
{
	WidgetBehaviour *wc;

	if (!wind->is_open)
	{
		DIAG((D.wind,wind->pid,"window %d for %s(%d) not open\n", wind->handle, wind->owner->name, wind->pid));
		return;
	}

	hidem();

#if 0
	if ((window_list == wind) and (wind->active_widgets & STORE_BACK))	/* Is this a 'preserve own background' window? */
	{
/* HR: I cannot find the place where this background is actually restored. ???
		Moreover: This is not the correct place, this function can be called
		many times for the same window over the rectangle list.
*/
		wind->background = form_save(0, wind->r, nil);
		if (wind->background)
		{
			wind->bgx = wind->r.x;
			wind->bgy = wind->r.y;
		}
		else
			wind->bgx = -1;
	}
	else
#endif
		wind->bgx = -1;		/* HR: And so this is never used */

	if (wind != root_window)		/* HR: Dont waste precious CRT glass */
	{
		RECT cl = wind->r,
		     wa = wind->wa;

		/* Display the window backdrop (borders only, GEM style) */
	
		f_color(screen.dial_colours.bg_col);
		f_interior(FIS_SOLID);
	
		if MONO
		{
			l_color(BLACK);
			wr_mode(MD_REPLACE);
		}

		cl.w-=SHADOW_OFFSET;
		cl.h-=SHADOW_OFFSET;
#if 0
		if (wind->active_widgets & NO_WORK)
		{							/* whole plane */
			if (wind->frame > 0)
				if (MONO)
					p_gbar(0, &cl);
				else
					gbar  (0, &cl);		
		}
		else
#endif
		{
			if ((wind->active_widgets & V_WIDG) == 0)
				gbox(0, &cl);
			else
			{
				short pnt[8];
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
				} else
				{
					wa.w++;
					wa.h++;
					br_hook(2, &wa, screen.dial_colours.shadow_col);
					tl_hook(2, &wa, screen.dial_colours.lit_col);
					br_hook(1, &wa, screen.dial_colours.lit_col);
					tl_hook(1, &wa, screen.dial_colours.shadow_col);
				}
			}
		}

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
		wc = wind->widgets[XAW_TITLE].behaviour[XACB_DISPLAY];
		(*wc)(lock, wind, &wind->widgets[XAW_TITLE]);
		wc = wind->widgets[XAW_ICONIFY].behaviour[XACB_DISPLAY];
		(*wc)(lock, wind, &wind->widgets[XAW_ICONIFY]);
	} else
	{
		short f;
		for (f = 0; f < XA_MAX_WIDGETS; f++)
		{
			if (wind->widgets[f].stuff and wind->owner->killed)
				continue;
			wc = wind->widgets[f].behaviour[XACB_DISPLAY];
			if (wc)
				(*wc)(lock, wind, &wind->widgets[f]);
		}
	}

	showm();
}

/* HR */
global
XA_WINDOW *wind_find(LOCK lock, short x, short y)
{
	XA_WINDOW *w;

	if unlocked(winlist)
		Sema_Up(WIN_LIST_SEMA);

	w = window_list;
	while(w)
	{
		if ( m_inside(x, y, &w->r) )
			break;
		w = w->next;
	}

	if unlocked(winlist)
		Sema_Dn(WIN_LIST_SEMA);
	return w;
}

global
XA_WINDOW *get_wind_by_handle(LOCK lock, short h)
{
	XA_WINDOW *w;

	if unlocked(winlist)
		Sema_Up(WIN_LIST_SEMA);

	w = window_list;
	while(w)
	{
		if (w->handle == h)
			break;
		w = w->next;
	}

	if (!w)
	{
		w = S.closed_windows.first;
		while(w)
		{
			if (w->handle == h)
				break;
			w = w->next;
		}
	}

	if unlocked(winlist)
		Sema_Dn(WIN_LIST_SEMA);
	return w;
}

/*
 *  HR: Handle windows after topping
 */
global
void after_top(LOCK lock, bool untop)
{
	XA_WINDOW *below;


	if unlocked(winlist)
		Sema_Up(WIN_LIST_SEMA);
		
	below = window_list->next;
	
	if (below)		/* Refresh the previous top window as being 'non-topped' */
	{
		if (below != root_window)
			display_non_topped_window(lock, 11, below, nil);

		if (untop)
			send_untop(lock, below);
	}

	if unlocked(winlist)
		Sema_Dn(WIN_LIST_SEMA);
}

/*
 *	Pull this window to the head of the window list
 */
XA_WINDOW * pull_wind_to_top(LOCK lock, XA_WINDOW *w)
{
	LOCK wlock = lock|winlist;
	XA_WINDOW *wl = w->prev;
	RECT clip, r;

	DIAG((D.wind,w->pid,"pull_wind_to_top %d for %s(%d)\n", w->handle, w->owner->name, w->pid));

	if unlocked(winlist)
		Sema_Up(WIN_LIST_SEMA);

	check_menu_desktop(wlock, window_list, w);

	wl = w->prev;
	r = w->r;

	if (w != root_window and w != window_list)		/* HR: just a safeguard */
	{
		wi_remove   (&S.open_windows, w);
		wi_put_first(&S.open_windows, w);
	}

	while(wl)
	{
		clip = wl->r;
		if (rc_intersect(&r, &clip))
			generate_rect_list(wlock, wl);
		wl = wl->prev;
	}

	generate_rect_list(wlock, w);

	if unlocked(winlist)
		Sema_Dn(WIN_LIST_SEMA);

	return w;
}

void send_wind_to_bottom(LOCK lock, XA_WINDOW *w)
{
	XA_WINDOW *wl = w->next;
	XA_WINDOW *old_top = window_list;

	RECT r, clip;

	if (   w->next == root_window				/* Can't send to the bottom a window that's already there */
		or w == root_window					/* HR: just a safeguard */
		or w->is_open == false			/* HR */
		)
		return;

	if unlocked(winlist)
		Sema_Up(WIN_LIST_SEMA);

	r = w->r;

	wi_remove   (&S.open_windows, w);
	wi_put_blast(&S.open_windows, w);		/* put before last; last = root_window. */

	while (wl)
	{
		clip = wl->r;
		if (rc_intersect(&r, &clip))
			generate_rect_list(lock|winlist, wl);
		wl = wl->next;
	}

	generate_rect_list(lock|winlist, w);

/* HR */
	check_menu_desktop(lock|winlist, old_top, window_list);

	if unlocked(winlist)
		Sema_Dn(WIN_LIST_SEMA);
}

/*
 * Change an open window's coordinates, updating rectangle lists as appropriate
 */
void move_window(LOCK lock, XA_WINDOW *wind, short newstate, short x, short y, short w, short h)
{
	LOCK wlock = lock|winlist;
	XA_WINDOW *wl;
	RECT old, new, clip, oldw, pr;
	short blit_mode;

	if unlocked(winlist)
		Sema_Up(WIN_LIST_SEMA);

DIAG((D.wind,wind->pid,"move %s window %d for %s(%d) from %d/%d,%d/%d to %d/%d,%d,%d\n",
	wind->is_open ? "open" : "closed",
	wind->handle, wind->owner->name, wind->pid, wind->r.x,wind->r.y,wind->r.w,wind->r.h, x,y,w,h));

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

		inside_root(&wind->r);			/* HR */

		new = wind->r;

		blit_mode =(    wind == window_list
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
			generate_rect_list(wlock, wind);			/* Update the window's rectangle list, it will be out of date now */
				
		/*	clear_clip();
		*/	
			if (blit_mode)	/* If window is being blit mode transferred, do the blit instead of redrawing */
			{
				DIAG((D.wind,wind->pid,"blit\n"));
				form_copy(&pr, &new);
			}
			else
			{
				display_non_topped_window(wlock, 12, wind, nil);
				if ( ! (wind->active_widgets & NO_MESSAGES))	/* Does this window's application want messages? If so send it a redraw */
				{
					/* moved? */
					if ((new.x != pr.x) or (new.y != pr.y))
					{
						DIAG((D.wind,wind->pid,"moved\n"));
						wind->send_message(wlock, wind, wind->pid, WM_REDRAW, 0, wind->handle,
							wind->wa.x, wind->wa.y, wind->wa.w, wind->wa.h);
					}
					else	/* sized */
					{
						DIAG((D.wind,wind->pid,"sized\n"));
						if (wind->wa.w > oldw.w)
						{
							DIAG((D.wind,wind->pid,"wider\n"));
							wind->send_message(wlock, wind, wind->pid, WM_REDRAW, 0, wind->handle,
								wind->wa.x + oldw.w, wind->wa.y, wind->wa.w - oldw.w, MIN(oldw.h, wind->wa.h));
						}
						if (wind->wa.h > oldw.h)
						{
							DIAG((D.wind,wind->pid,"higher\n"));
							wind->send_message(wlock, wind, wind->pid, WM_REDRAW, 0, wind->handle,
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
				DIAG((D.wind,wl->pid,"redisplay %d\n", wl->handle));
				clip = wl->r;
				if (rc_intersect(&old, &clip))		/* Check for newly exposed windows */
				{			
					generate_rect_list(wlock, wl);
					display_non_topped_window(wlock, 13, wl, &clip);
					if ( ! (wl->active_widgets & NO_MESSAGES))	/* Does this window's application want messages? If so send it a redraw */
						wl->send_message(wlock, wl, wl->pid, WM_REDRAW, 0, wl->handle, clip.x, clip.y, clip.w, clip.h);
				} else
				{
					clip = wl->r;
					if (rc_intersect(&new, &clip))		/* Check for newly covered windows */
						generate_rect_list(wlock, wl);			/* We don't need to send a redraw to these windows, we just have to update their rect lists */
				}
				wl = wl->next;
			}
	/* HR removed root_window stuff, that perfectly worked within the loop. */
		}
	}

	if (wind->remember)						/* HR */
		*wind->remember = wind->r;

	if unlocked(winlist)
		Sema_Dn(WIN_LIST_SEMA);
}

#if 1
/*
 * Close an open window and re-display any windows underneath it.
 * Also places window in the closed_windows list but does NOT delete it
 * - the window will still exist after this call.
 */
bool close_window(LOCK lock, XA_WINDOW *wind)
{
	XA_WINDOW *wl;
	RECT r, clip;
	bool is_top;
	short pid = wind->pid;
	XA_CLIENT *client = wind->owner;
	
	if (wind == nil)
	{
		DIAG((D.wind,-1,"close_window: null window pointer\n"));
		return false;					/* Invalid window handle, return error */
	}

	DIAG((D.wind,wind->pid,"close_window: %d, open? %d\n", wind->handle, wind->is_open));

	if (wind->is_open == false or wind->nolist)
		return false;
	
	if unlocked(winlist)
		Sema_Up(WIN_LIST_SEMA);

	is_top = (wind == window_list);
	r = wind->r;

	wi_remove   (&S.open_windows, wind);
	wi_put_first(&S.closed_windows, wind);
	
	wind->is_open = false;					/* Tag window as closed */
	wind->window_status = XAWS_CLOSED;

	wl = window_list;

	if (is_top)
	{
		XA_WINDOW *w, *napp = nil;
 		w = window_list;

/*	HR: v_hide/show_c now correctly done in display_window()  */
/*  HR: if you want point_to_type, handle that in do_keyboard */

/* First: find a window of the owner */
		while (w)
		{
			if (w != root_window)
			{ 
				if (w->pid == pid)		/* gotcha */
				{
					top_window(lock|winlist, w, w->pid);		/* HR */
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
	while(wl)
	{
		clip = wl->r;
		if (rc_intersect(&r, &clip))
		{
			generate_rect_list(lock|winlist, wl);			/* If a new focus was pulled up, some of these are not needed */
			display_non_topped_window(lock|winlist, 14, wl, &clip);
			if ( ! (wl->active_widgets & NO_MESSAGES))	/* Does this window's application want messages? If so send it a redraw */
				wl->send_message(lock|winlist, wl, wl->pid, WM_REDRAW, 0, wl->handle, clip.x, clip.y, clip.w, clip.h);
		}
		wl = wl->next;
	}

	if (window_list)						/* HR 060101 */
		if (    window_list->pid != pid
			and client->std_menu.tree == nil
			)
		{
	/* HR: get the menu bar right (only if the pid has no menu bar
		and no more open windows for pid. */
			DIAG((D.menu,-1,"close_window: swap_menu to %d\n", window_list->pid));
			swap_menu(lock|winlist, window_list->pid, true);
		}

	if unlocked(winlist)
		Sema_Dn(WIN_LIST_SEMA);

	return true;
}
#else
#include "obsolete/closewi2.h"
#endif

static
void free_widg(XA_WINDOW *wind, short widg)
{
	if (wind->widgets[widg].stuff)
	{
		free(wind->widgets[widg].stuff);
		wind->widgets[widg].stuff = nil;
	}
}

static
void free_standard_widgets(XA_WINDOW *wind)		/* HR: 060101 slider widgets leaked. */
{
	free_widg(wind, XAW_MENU);		/* HR: fix memory leak */
	free_widg(wind, XAW_HSLIDE);
	free_widg(wind, XAW_VSLIDE);
}

void delete_window(LOCK lock, XA_WINDOW *wind)
{
	if (!wind)
	{
		DIAG((D.wind,wind->pid,"delete_window: null window pointer\n"));
		return;					/* Invalid window handle, return error */
	}

	if (!wind->nolist)		/* HR */
	{
		if (wind->is_open)			/* We must be sure it is in the correct list. */
		{
			DIAG((D.wind,wind->pid,"delete_window %d: not closed\n", wind->handle));
			return;					/* open window, return error */
		}

		DIAG((D.wind,wind->pid,"delete_window %d for %s(%d): open? %d\n", wind->handle, wind->owner->name, wind->pid, wind->is_open));
	
		if unlocked(winlist)
			Sema_Up(WIN_LIST_SEMA);

		free_standard_widgets(wind);				/* HR: 060101 slider widgets leaked. */

		if (wind->destructor)
			(*(wind->destructor))(lock|winlist, wind);			/* Call the window destructor if any */
		
		free_wind_handle(wind->handle);				/* HR */
	
		if (wind->background)
			free(wind->background);
		
		if (wind->rect_start)
			free(wind->rect_start);

		wi_remove(&S.closed_windows, wind);
		
		if unlocked(winlist)
			Sema_Dn(WIN_LIST_SEMA);
	} else
	{
		free_standard_widgets(wind);
	
		if (wind->destructor)
			(*(wind->destructor))(lock, wind);
	}

	free(wind);
}

/*
 * Display a window that isn't on top, respecting clipping
 * - Pass clip == nil to redraw whole window, otherwise clip is a pointer to a GRECT that
 * defines the clip rectangle.
 */
void display_non_topped_window(LOCK lock, short which, XA_WINDOW *w, RECT *clip)
{
	if (w->is_open)
	{
		DIAG((D.wind,w->pid,"[%d]display_non_topped_window %d for '%s'(%d) to %d/%d,%d/%d\n",
				which, w->handle, w->owner->name, w->pid, w->r.x, w->r.y, w->r.w, w->r.h));
		{
			XA_RECT_LIST *rl = rect_get_system_first(w);
			while(rl)
			{			
				if (clip)
				{
					RECT target = rl->r;				
					if (rc_intersect(clip, &target))
					{
						set_clip(&target);  DIAG((D.rect,w->pid,"clip: %d/%d,%d/%d\n",target.x,target.y,target.w,target.h));
						display_window(lock, w);
					}
				} else
				{
					set_clip(&rl->r);
					display_window(lock, w);
				}
				rl = rect_get_system_next(w);
			}
		}
		clear_clip();
	}
}

/*
 * Display windows below a given rectangle, starting with window w.
 * HR: at the time only called for form_dial(FMD_FINISH)
 */
void display_windows_below(LOCK lock, RECT *r, XA_WINDOW *wl)
{
	RECT win_r;
	;

	while (wl)
	{
		XA_RECT_LIST *rl = rect_get_system_first(wl);
		while (rl)
		{
			win_r = rl->r;		
			if (rc_intersect(r, &win_r))
			{
				set_clip(&win_r);
				display_window(lock, wl);		/* Display the window */
										/* Send a redraw message to the owner of the window for this rectangle */
				if (!(wl->active_widgets & NO_REDRAWS))
					wl->send_message(lock, wl, wl->pid, WM_REDRAW, 0, wl->handle, win_r.x, win_r.y, win_r.w, win_r.h);
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
void calc_window(short pid, short request, unsigned long tp, RECT *r, RECT *o)
{
	XA_WINDOW *w_temp;

	DIAG((D.wind,pid,"calc %s from %d/%d,%d/%d\n", request ? "work" : "border", r->x, r->y, r->w, r->h));

	/* Create a temporary window with the required widgets */
	w_temp = create_window(NOLOCKING, nil, pid, true, tp, MG, *r, nil, nil);	/* HR */

	switch(request)
	{
	case WC_BORDER:						/* We have to work out the border size ourselves here */
		Xpolate(o, &w_temp->r, &w_temp->wa);
		break;
	case WC_WORK:					/* Work area was calculated when the window was created */
		*o = w_temp->wa;
		break;
	default:
		DIAG((D.wind,pid,"wind_calc request %d\n", request));
		*o = *r;	/* HR: return something */
	}
	DIAG((D.wind,pid,"calc returned: %d/%d,%d/%d\n", o->x, o->y, o->w, o->h));
	delete_window(NOLOCKING, w_temp);				/* Dispose of the temporary window we created */
}
