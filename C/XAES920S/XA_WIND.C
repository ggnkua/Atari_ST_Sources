/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <mintbind.h>
#include <osbind.h>
#include <sys\types.h>

#include "xa_types.h"
#include "xa_globl.h"

#include "c_window.h"
#include "rectlist.h"
#include RSCHNAME
#include "objects.h"
#include "widgets.h"
#include "desktop.h"
#include "xa_form.h"
#include "xa_graf.h"
#include "xa_rsrc.h"
#include "app_man.h"

/*
 *	AES window handling functions
 *	I've tried to support some of the AES4 extensions here as well as the plain
 *	single tasking GEM ones.
 */

AES_function XA_wind_create	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	XA_WINDOW *new_window;
	RECT r = *((RECT *)&pb->intin[1]);				/* HR */
	XA_WIND_ATTR kind = (unsigned short)pb->intin[0];

	CONTROL(5,1,0)	

	if (r.w < 3*ICON_W)						/* HR 16501 */
		r.w = screen.r.w;
	if (r.h < 4*ICON_H)
		r.h = screen.r.h;

	if (pb->intin[0] < 0 and pb->contrl[1] == 6)
		kind|=pb->intin[5];
	
	/* HR */
	new_window = create_window(	lock,
								send_app_message,
								client->pid,
								false,
								kind|BACKDROP,
								MG,
								r,
								&r,
								nil);	

	if (new_window)
		pb->intout[0] = new_window->handle;	/* Return the window handle in intout[0] */
	else
		pb->intout[0] = -1;			/* Fail to create window, return -ve number */

	return XAC_DONE;				/* Allow the kernal to wake up the client - we've done our bit */
}

/* HR: open_window: internal function */
AES_function XA_wind_open	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	XA_WINDOW *w;
	RECT r = *((RECT *)&pb->intin[1]);				/* HR */

	CONTROL(5,1,0)	

	w = get_wind_by_handle(lock, pb->intin[0]);		/* Get the window */
	
	if (r.w > w->max.w)								/* HR 160501: for convenience: adjust max */
		w->max.w = r.w;
	if (r.h > w->max.h)
		w->max.h = r.h;

	pb->intout[0] = open_window(lock, client->pid, pb->intin[0], r);

	return XAC_DONE;
}

AES_function XA_wind_close	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	XA_WINDOW *w;
	
	CONTROL(1,1,0)	

	DIAG((D.wind,client->pid,"XA_wind_close\n"));
	w = get_wind_by_handle(lock, pb->intin[0]);		/* Get the window */

	if (w == nil)
	{
		DIAGS(("WARNING:wind_close for %s(%d): Invalid window handle %d\n", client->name, client->pid, pb->intin[0]));
		pb->intout[0] = 0;
		return XAC_DONE;
	}

	if (w->pid != client->pid)	/* Clients can only close their own windows */
	{
		DIAGS(("WARNING: %s(%d) cannot close window %d (not owner)\n", client->name, client->pid, w->handle));
		pb->intout[0] = 0;
		return XAC_DONE;
	}
	
	pb->intout[0] = close_window(lock, w);
	
	return XAC_DONE;
}

AES_function XA_wind_find		/* (LOCK lock, XA_CLIENT *client,AESPB *pb) */
{
	XA_WINDOW *w = wind_find(lock, pb->intin[0], pb->intin[1]);	/* Is there a window under the mouse? */

	CONTROL(2,1,0)	

	pb->intout[0] = w ? w->handle : 0;

	return XAC_DONE;
}

void top_window(LOCK lock, XA_WINDOW *w, short menu_owner)			/* HR */
{
	short pid = w->pid;
	XA_WINDOW *old_focus, *new_focus;
	XA_CLIENT *client = w->owner;

	DIAG((D.wind,pid,"top_window %d for %s(%d)\n",  w->handle, client->name, pid));

	old_focus = window_list;

	pull_wind_to_top(lock, w);	/* New top window - change the cursor to this client's choice */

	C.focus = pid != menu_owner ? root_window : window_list;		/* HR */
	
	graf_mouse(client->client_mouse, client->client_mouse_form);
	display_non_topped_window(lock, 40, old_focus, nil);  /* redisplay title */
	if (old_focus != w)
		display_non_topped_window(lock, 41, w, nil);		/* Display the window */

	w->send_message(lock, w, pid, WM_REDRAW, 0, w->handle, w->r.x, w->r.y, w->r.w, w->r.h);
}

void bottom_window(LOCK lock, XA_WINDOW *w)
{
	short was_top = (w == window_list);
	RECT clip;
	XA_WINDOW *wl = w->next;

DIAG((D.wind,w->pid,"bottom_window %d\n", w->handle));

	if (wl == root_window)			/* Don't do anything if already bottom */
		return;

	send_wind_to_bottom(lock, w);			/* Send it to the back */

DIAG((D.wind,w->pid," - menu_owner %d, w_list_owner %d\n", menu_owner(), window_list->pid));
	C.focus = window_list->pid != menu_owner() ? root_window : window_list;		/* HR */

	display_non_topped_window(lock, 42, w, nil);			/* Redisplay titles */
	display_non_topped_window(lock, 43, window_list, nil);

	while (wl != w)			/* Our window is now right above root_window */
	{
		clip = wl->r;
		if (rc_intersect(&w->r, &clip))
		{
			display_non_topped_window(lock, 44, wl, &clip);		/* Re-display any revealed windows */
			if ( ! (wl->active_widgets & NO_MESSAGES))
				wl->send_message(lock, wl, wl->pid, WM_REDRAW, 0, wl->handle, clip.x, clip.y, clip.w, clip.h);
		}
		wl = wl->next;
	}

	if (was_top)
		send_ontop(lock);	/*  HR 060801: send WM_ONTOP to just topped window. */
}

#if GENERATE_DIAGS
static						/* Want to see quickly what app's are doing. */
char *setget_names[] =
{
	"0",
	"1",
	"WF_NAME(2)",
	"WF_INFO(3)",
	"WF_WORKXYWH(4)",
	"WF_CURRXYWH(5)",
	"WF_PREVXYWH(6)",
	"WF_FULLXYWH(7)",
	"WF_HSLIDE(8)",
	"WF_VSLIDE(9)",
	"WF_TOP(10)",
	"WF_FIRSTXYWH(11)",
	"WF_NEXTXYWH(12)",
	"13",
	"WF_NEWDESK(14)",
	"WF_HSLSIZE(15)",
	"WF_VSLSIZE(16)",
	"WF_SCREEN(17)",
	"WF_COLOR(18)",
	"WF_DCOLOR(19)",
	"WF_OWNER(20)",
	"21",
	"22",
	"23",
	"WF_BEVENT(24)",
	"WF_BOTTOM(25)",
	"WF_ICONIFY(26)",
	"WF_UNICONIFY(27)",
	"WF_UNICONIFYXYWH(28)",
	"29",
	"WF_TOOLBAR(30)",
	"WF_FTOOLBAR(31)",
	"WF_NTOOLBAR(32)",
	"      "
};

char *setget(short i)
{
	if (i < 0 or i >= WF_LAST)
	{
		sdisplay (setget_names[WF_LAST], "%d", i);
		return setget_names[WF_LAST];
	}
	return setget_names[i];
}

#endif

AES_function XA_wind_set	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	XA_WINDOW *w;
	XA_WIDGET *widg;
	OBJECT *ob;
	RECT clip;
	short wind = pb->intin[0], cmd = pb->intin[1];
	unsigned short *l;
	char *t;

	CONTROL(6,1,0)	

	w = get_wind_by_handle(lock, wind);

	DIAG((D.wind,client->pid,"wind_set: w%lx, h%d, %s\n",w,w ? w->handle : -1, setget(cmd)));

	if (w == nil)
	{
		switch(cmd)
		{
		case WF_NEWDESK:			/* Some functions may be allowed without a real window handle */
			break;
		default:
			DIAGS(("WARNING:wind_set for %s(%d): Invalid window handle %d\n", client->name, client->pid, w));
			pb->intout[0] = 0;		/* Invalid window handle, return error */
			return XAC_DONE;
		}
	} else
		if (     w->pid != client->pid		/* Clients can only change their own windows */
			and (   w   != root_window
			     or cmd != WF_NEWDESK
			    )
		   )
		{
			DIAGS(("WARNING: %s(%d) cannot change window %d (not owner)\n", client->name, client->pid, w->handle));
			pb->intout[0] = 0;		/* Invalid window handle, return error */
			return XAC_DONE;
		}
	
	switch(cmd) {
	case WF_HSLIDE:
		widg = w->widgets + XAW_HSLIDE;
		if (widg->stuff)
		{
			XA_SLIDER_WIDGET *slw = widg->stuff;
			slw->position = bound_sl(pb->intin[2]);		/* HR */
			display_widget(lock, w, widg);
		}
		break;
	case WF_VSLIDE:
		widg = w->widgets + XAW_VSLIDE;
		if (widg->stuff)
		{
			XA_SLIDER_WIDGET *slw = widg->stuff;
			slw->position = bound_sl(pb->intin[2]);		/* HR */
			display_widget(lock, w, widg);
		}
		break;
	case WF_HSLSIZE:
		widg = w->widgets + XAW_HSLIDE;
		if (widg->stuff)
		{
			XA_SLIDER_WIDGET *slw = widg->stuff;
			slw->length = bound_sl(pb->intin[2]);		/* HR */
			display_widget(lock, w, widg);
		}
		break;
	case WF_VSLSIZE:
		widg = w->widgets + XAW_VSLIDE;
		if (widg->stuff)
		{
			XA_SLIDER_WIDGET *slw = widg->stuff;
			slw->length = bound_sl(pb->intin[2]);		/* HR */
			display_widget(lock, w, widg);
		}
		break;
	case WF_NAME:
		l = (unsigned short *)(pb->intin);
		t = (char*)((long)l[2] << 16);
		t += l[3];
		if (t == nil)			/* HR */
			t = "";
		w->widgets[XAW_TITLE].stuff = t;

		DIAG((D.wind, w->pid, "    -   %s\n", t));
		if ((w->active_widgets & NAME) and w->is_open)
		{
			rp_2_ap(w, w->widgets + XAW_TITLE, &clip);
			display_non_topped_window(lock, 45, w, &clip);
		}
		break;
	case WF_INFO:
		l = (unsigned short *)(pb->intin);
		t = (char *)((long)l[2] << 16);
		t += l[3];
		if (t == nil)			/* HR */
			t = "";
		w->widgets[XAW_INFO].stuff = t;

		if ((w->active_widgets & INFO) and w->is_open)
		{
			rp_2_ap(w, w->widgets+XAW_INFO, &clip);
			display_non_topped_window(lock, 46, w, &clip);
		}
		break;

	case WF_CURRXYWH:				/* Move a window, HR: check sizes */
		{
			short mw = pb->intin[4],
			      mh = pb->intin[5];
			if (w->max.w and mw > w->max.w)
				mw = w->max.w;
			if (w->max.h and mh > w->max.h)
				mh = w->max.h;
			move_window(lock, w, -1, pb->intin[2], pb->intin[3], mw, mh);
		}
		break;
	case WF_BEVENT:					/* HR */
		if (pb->intin[2]&1)
			w->active_widgets |= NO_TOPPED;
		else
			w->active_widgets &= ~NO_TOPPED;
		break;
	case WF_BOTTOM:					/* Extension, send window to the bottom */
		if (w->is_open)
			bottom_window(lock, w);
		break;
			
	case WF_TOP:					/* Top the window */
		if (w->is_open)
		{
			if (        w != window_list
				or (    w == window_list
				    and w != C.focus
				   )		/* HR */
				)
			{
				top_window(lock, w, w->pid);
				swap_menu(lock, w->pid, true);		/* HR: needed because the changed behaviour in close_window. */
				after_top(lock, true);			/* HR: 310701 (forgotten) */
			}
		}
		break;
			
	case WF_NEWDESK:				/* Set a new desktop object tree */
		l = (unsigned short *)pb->intin;
		t = (char *)((long)l[2] << 16);
		t += l[3];
		ob = (OBJECT *)t;
			
		if (ob)
		{
			client->desktop = ob;
			set_desktop(ob);
			root_window->pid = client->pid;
			root_window->owner = client;
			DIAGS(("  desktop for %s(%d) to (%d/%d,%d/%d)\n", 
							client->name, client->pid, ob->r.x, ob->r.y, ob->r.w, ob->r.h));
			display_non_topped_window(lock, 47, root_window, nil);
		} else
		{
			if (client->desktop)
			{
				XA_CLIENT *new;
				client->desktop = nil;
				/* HR 100701: find a prev app's desktop. */
				new = find_desktop(lock);
				set_desktop(new->desktop);
				root_window->pid = new->pid;
				root_window->owner = new;
				DIAGS(("  desktop for %s(%d) removed\n", client->name, client->pid));
				display_non_topped_window(lock, 48, root_window, nil);
			}
		}
		break;
#if 0
	case WF_AUTOREDRAW:				/* Set an auto-redraw callback function for the window */
		l = (unsigned short *)pb->intin;
		t = (char *)((long)l[2] << 16);
		t += l[3];
		w->redraw = (WindowDisplay *)t;		/* HR: * */
		break;
#endif
#if 0
	case WF_STOREBACK:				/* Set the window's 'preserve own background' attribute */
		w->background = xmalloc(calc_back(&w->r,screen.planes),10);		/* HR: never used */
		w->bgx = -1;
		w->active_widgets |= STORE_BACK|NO_REDRAWS;
		break;
#endif

/* HR Psema.... already in move_window */
	case WF_ICONIFY:				/* Iconify a window */
		w->save_widgets = w->active_widgets;
		standard_widgets(w, NAME|MOVE|SMALLER, true);
		move_window(lock, w, XAWS_ICONIFIED, pb->intin[2], pb->intin[3], pb->intin[4], pb->intin[5]);
		break;

	case WF_UNICONIFY:				/* Un-Iconify a window */
		standard_widgets(w, w->save_widgets, true);
		move_window(lock, w, XAWS_OPEN, w->ro.x, w->ro.y, w->ro.w, w->ro.h);
		break;

	}

	pb->intout[0] = 1;
	return XAC_DONE;
}

/*
 * AES wind_get() function.
 * This includes support for most of the AES4 / AES4.1 extensions,
 * with the exception of WF_BEVENT (all XaAES windows get button events in the
 * background at the moment).
 */

#if MEASURE_LINES_APP
extern long wind_gets;
#endif

AES_function XA_wind_get	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	XA_WINDOW *w;
	XA_RECT_LIST *rl;
	XA_SLIDER_WIDGET *slw;
	short *o = pb->intout, hex_version(void);
	RECT *ro = (RECT *)&pb->intout[1];
	short wind = pb->intin[0], cmd = pb->intin[1];
	RECT s, d;
	
	CONTROL(2,5,0)	

#if MEASURE_LINES_APP
	wind_gets++;
#endif
	w = get_wind_by_handle(lock, wind);

DIAG((D.wind,client->pid,"wind_get: pid=%d, w=%lx, h:%d, %s\n",client->pid,w,wind,setget(cmd)));
	if (w == nil)
	{
		switch(cmd)
		{
		case WF_BOTTOM:			/* Some functions may be allowed without a real window handle */
		case WF_FULLXYWH:
		case WF_TOP:
		case WF_NEWDESK:
		case WF_SCREEN:				/* HR */
#ifdef __GNUC__
		case 0x5841:
#else
		case 'XA':						/* HR: idee stolen from WINX */
#endif
			break;
		default:
			DIAGS(("WARNING:wind_get for %s(%d): Invalid window handle %d\n", client->name, client->pid, wind));
			o[0] = 0;		/* Invalid window handle, return error */
			return XAC_DONE;
		}
	}

	o[0] = 1;

	switch(cmd)
	{
	case WF_FIRSTXYWH:				/* Generate a rectangle list and return the first entry */
		if unlocked(winlist)
			Sema_Up(WIN_LIST_SEMA);
		rl = rect_get_user_first(w);
/* HR: Oh, Oh  Leaving a intersect unchecked!! And forcing me to use a goto :-( */
		if (rl)
		{
			d = w->wa;
			if ( ! rc_intersect(&rl->r, &d))
				goto next;		
			*ro = d;		/* Return the first rectangle coords */
		} else
		{
			ro->x = w->r.x;		/* Totally obscured window, return w & h as 0 */
			ro->y = w->r.y;
			ro->w = 0;
			ro->h = 0;
		}
DIAG((D.wind,client->pid,"first for %s %d/%d,%d/%d\n", client->name, o[1], o[2], o[3], o[4]));
		if unlocked(winlist)
			Sema_Dn(WIN_LIST_SEMA);
		break;
			
	case WF_NEXTXYWH:				/* Get next entry from a rectangle list */
		if unlocked(winlist)
			Sema_Up(WIN_LIST_SEMA);
next:
		do{
			rl = rect_get_user_next(w);
			if (rl)
			{
				d = w->wa;
				if (rc_intersect(&rl->r, &d))
				{
					*ro = d;		/* Return the next rectangle coords */
					break;
				}
			} else
			{
				ro->x = w->r.x;		/* Totally obscured window, return w & h as 0 */
				ro->y = w->r.y;
				ro->w = 0;
				ro->h = 0;
				break;
			}
		}od
DIAG((D.wind,client->pid,"next for %s %d/%d,%d/%d\n", client->name, o[1], o[2], o[3], o[4]));
		if unlocked(winlist)
			Sema_Dn(WIN_LIST_SEMA);
		break;

/* The info given by these function is very important to app's
        hence the DIAG's */			
	case WF_CURRXYWH:				/* Get the current coords of the window */		
		*ro = w->r;
DIAG((D.w,-1,"get curr for %d: %d/%d,%d/%d\n",wind ,ro->x,ro->y,ro->w,ro->h));
		break;

	case WF_WORKXYWH:				/* Get the current coords of the window's user work area */
		*ro = w->wa;
DIAG((D.w,-1,"ro = 0x%lx\n", ro));	
DIAG((D.w,-1,"get work for %d: %d/%d,%d/%d\n",wind ,ro->x,ro->y,ro->w,ro->h));
		break;

	case WF_PREVXYWH:				/* Get previous window position */
		*ro = w->pr;
DIAG((D.w,-1,"get prev for %d: %d/%d,%d/%d\n",wind ,ro->x,ro->y,ro->w,ro->h));
		break;			

	case WF_FULLXYWH:				/* Get maximum window dimensions */
		if (!w)
		{
			ro->x = root_window->r.x; 
			ro->y = root_window->wa.y;	/* Ensure the windows don't overlay the menu bar */
			ro->w = root_window->r.w;
			ro->h = root_window->wa.h;
DIAG((D.w,-1,"get max full: %d/%d,%d/%d\n", ro->x,ro->y,ro->w,ro->h));
		othw
			*ro = w->max;				/* HR */
DIAG((D.w,-1,"get full for %d: %d/%d,%d/%d\n",wind ,ro->x,ro->y,ro->w,ro->h));
		}
		break;

	case WF_BEVENT:					/* HR */
		o[1] = ((w->active_widgets&NO_TOPPED) != 0)&1;
		break;	
	case WF_BOTTOM:					/* Extension, gets the bottom window */
		if unlocked(winlist)
			Sema_Up(WIN_LIST_SEMA);
#if 0
		for (w = window_list; w->next; w = w->next)
			;
#else
	/* HR!!! */
		w = root_window;
		if (w->prev)
			w = w->prev;
#endif
		if unlocked(winlist)
			Sema_Dn(WIN_LIST_SEMA);
		o[1] = w->handle;		/* Return the window handle of the bottom window */
		o[2] = w->pid;			/* Return the owner of the bottom window */
		break;
			
	case WF_TOP:
		if unlocked(winlist)
			Sema_Up(WIN_LIST_SEMA);
		w = window_list;
		if (w)
		{
/*			if (C.focus == root_window)		/* HR 100801: Do not report unfocused window as top. */
				w = root_window;
*/
			o[1] = w->handle;	/* Return the window handle */
			o[2] = w->pid;	/* AES4 specifies that you return the AESid of the owner here as well */
			if (w->next)	/* Is there a window below?  */
			{				/* If there is, then AES4 says return its handle here */
				o[3] = w->next->handle;
				o[4] = w->next->pid;		/* XaAES extention - return the AESid of the app that owns the window below */
			} else
			{
				o[3] = 0;
				o[4] = 0;
			}
		} else
		{
			DIAGS(("ERROR: empty window list!!\n"));
			o[1] = 0;		/* No windows open - return an error */
			o[0] = 0;
		}
		if unlocked(winlist)
			Sema_Dn(WIN_LIST_SEMA);		/* This should be at the end, because of prev, next */
		break;
			
	case WF_OWNER:					/* AES4 compatible stuff */
		if unlocked(winlist)
			Sema_Up(WIN_LIST_SEMA);					/* HR */

		o[1] = w->pid;			/* The window owners AESid (==app_id) */
		o[2] = w->is_open;		/* Is the window open? */
		if (w->prev)	/* If there is a window above, return its handle */
			o[3] = w->prev->handle;
		else
			o[3] = -1;		/* HR: dont return a valid window handle (root window is 0) */
							/*     Some programs (Multistrip!!) get in a loop */
		if (w->next)	/* If there is a window below, return its handle */
			o[4] = w->next->handle;
		else
			o[4] = -1;

		if unlocked(winlist)
			Sema_Dn(WIN_LIST_SEMA);					/* HR */
		break;

	case WF_VSLIDE:
		if (w->active_widgets&VSLIDE)
		{
			slw = w->widgets[XAW_VSLIDE].stuff;
			o[1] = slw->position;
		}
		else
			o[0] = o[1] = 0;
		break;
			
	case WF_HSLIDE:
		if (w->active_widgets&HSLIDE)
		{
			slw = w->widgets[XAW_HSLIDE].stuff;
			o[1] = slw->position;
		}
		else
			o[0] = o[1] = 0;
		break;
			
	case WF_HSLSIZE:
		if (w->active_widgets&HSLIDE)
		{
			slw = w->widgets[XAW_HSLIDE].stuff;
			o[1] = slw->length;
		}
		else
			o[0] = o[1] = 0;
		break;
			
	case WF_VSLSIZE:
		if (w->active_widgets & VSLIDE)
		{
			slw = w->widgets[XAW_VSLIDE].stuff;
			o[1] = slw->length;
		}
		else
			o[0] = o[1] = 0;
		break;

	case WF_SCREEN:		/* HR return a very small area :-) hope app's      */
						/*    then decide to allocate a buffer themselves. */
						/*    This worked for SELECTRIC.  */
#if HALFSCREEN
						/*   Alas!!!! not PS_CONTRL.ACC	  */
						/* So now its all become official */

		/* HR: make the half (or quarter) screen buffer for wind_get(WF_SCREEN) :-( :-( */
		/*    What punishment would be adequate for the bloke (or bird) who invented this? */

		if (cfg.half_screen_buffer == nil)
		{
			cfg.half_screen_buffer = Mxalloc(cfg.half_screen_size, MX_GLOBAL | MX_PREFTTRAM);
DIAGS(("half_screen_buffer for %s(%d): mode:%x, %ld(%lx) size %ld\n",
			client->name,client->pid,
			(short)(MX_GLOBAL | MX_PREFTTRAM), cfg.half_screen_buffer, cfg.half_screen_buffer, cfg.half_screen_size));
			client->half_screen = true;
		}

		*(char  **)&o[1] = cfg.half_screen_buffer;
		*(size_t *)&o[3] = cfg.half_screen_size;
#else
		o[0] = o[1] = o[2] = o[3] = o[4] = 0;
#endif
		break;

	case WF_NEWDESK:
		if unlocked(desk)
			Sema_Up(ROOT_SEMA);
		*(OBJECT **)&o[1] = get_desktop();
		if unlocked(desk)
			Sema_Dn(ROOT_SEMA);
		break;
	
	case WF_ICONIFY:
		if (w->window_status == XAWS_ICONIFIED)
		{
			o[1] = 1;
			o[2] = C.iconify.w;
			o[3] = C.iconify.h;
		}
		else
			o[1] = 0;
		break;

	case WF_UNICONIFY:
		*ro = w->pr;
		break;

#ifdef __GNUC__
	case 0x5841:
		o[0] = 0x5841;
#else
	case 'XA':						/* HR: idee stolen from WINX */
		o[0] = 'XA';
#endif
		o[1] = hex_version();
		DIAGS(("hex_version = %04x\n",o[1]));
		break;
	default:
		DIAG((D.wind,client->pid,"wind_get: %d\n",cmd));
		o[0] = 0;					/* HR */
	}
	
	return XAC_DONE;
}

AES_function XA_wind_delete	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	XA_WINDOW *w;
	
	CONTROL(1,1,0)	

	w = get_wind_by_handle(lock, pb->intin[0]);

	if (w and w->is_open == false)		/* HR: check if closed */
	{
		delete_window(lock, w);
		pb->intout[0] = 1;
	}
	else
		pb->intout[0] = 0;
	
	return XAC_DONE;
}

/*
 * Go through and check that all windows belonging to this client are
 * closed and deleted
 */

/* HR: This is an exemple of the use of the lock system.
       The function can be called by both server and client.

       If called by the server, lock will be preset to winlist,
         resulting in no locking (not needed).
       
       If called by the signal handler, it is unclear, so the
         lock is applied. (doesnt harm).
*/

void wind_new(LOCK lock, short pid)
{
	XA_WINDOW *wl, *nwl;

	DIAG((D.wind,pid,"wind_new for %d\n", pid));

	if unlocked(winlist)
		Sema_Up(WIN_LIST_SEMA);		/* HR */

	wl = window_list;
	while(wl)
	{
		nwl = wl->next;

		if (wl == root_window)		/* HR 250301 */
			break;
		if (wl->pid == pid)
		{
			close_window(lock|winlist, wl);		/* checks is_open */
			delete_window(lock|winlist, wl);
		}
		wl = nwl;
	}

	wl = S.closed_windows.first;
	while (wl)
	{
		nwl = wl->next;
		if (wl->pid == pid)
			delete_window(lock|winlist, wl);
		wl = nwl;
	}
	
	if unlocked(winlist)
		Sema_Dn(WIN_LIST_SEMA);
}

AES_function XA_wind_new	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	CONTROL(0,0,0)	

	wind_new(lock, client->pid);

	return XAC_DONE;
}


/*
 * wind_calc			/* HR: embedded function calc_window() */
 */
AES_function XA_wind_calc	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	CONTROL(6,5,0)	

	calc_window( client->pid,
				 pb->intin[0],		/* request */
				 pb->intin[1],		/* widget mask */
		(RECT *)&pb->intin[2],
		(RECT *)&pb->intout[1]);

	pb->intout[0] = 1;
	return XAC_DONE;
}
