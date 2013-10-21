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
#include <string.h>
#include <sys/types.h>

#include "xa_types.h"
#include "xa_globl.h"

#include "c_window.h"
#include "rectlist.h"
#include WIDGHNAME
#include "objects.h"
#include "widgets.h"
#include "menuwidg.h"
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
	XA_WIND_ATTR kind = (G_u)pb->intin[0];

	CONTROL(5,1,0)	

#if 0
	if (r.w < 6*cfg.widg_w)						/* HR 16501 */
		r.w = screen.r.w;
	if (r.h < 6*cfg.widg_h)
		r.h = screen.r.h;
#endif

	if (pb->intin[0] < 0 and pb->contrl[1] == 6)
		kind |= pb->intin[5]<<16;
	if (!client->options.nohide)
		kind |= HIDE;

	/* HR */
	new_window = create_window(	lock,
								send_app_message,
								client,
								false,
								kind|BACKDROP,
								created_for_CLIENT,
								MG,
								client->options.thinframe,
								client->options.thinwork,
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

	if (!w)
		pb->intout[0] = 0;
	else
	{
		if (w->active_widgets&USE_MAX)				/* HR 131101 */
		{
			if (r.w > w->max.w)								/* HR 160501: for convenience: adjust max */
				w->max.w = r.w;
			if (r.h > w->max.h)
				w->max.h = r.h;
		}	
		pb->intout[0] = open_window(lock, w, r);
	}

	return XAC_DONE;
}

AES_function XA_wind_close	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	XA_WINDOW *w;
	
	CONTROL(1,1,0)	

	DIAG((D_wind,client,"XA_wind_close\n"));
	w = get_wind_by_handle(lock, pb->intin[0]);		/* Get the window */

	if (w == nil)
	{
		DIAGS(("WARNING:wind_close for %s: Invalid window handle %d\n", c_owner(client), pb->intin[0]));
		pb->intout[0] = 1;
		return XAC_DONE;
	}

	if (w->owner != client)	/* Clients can only close their own windows */
	{
		DIAGS(("WARNING: %s cannot close window %d (not owner)\n", c_owner(client), w->handle));
		pb->intout[0] = 1;
		return XAC_DONE;
	}

	close_window(lock, w);
	pb->intout[0] = 1;
	
	return XAC_DONE;
}

AES_function XA_wind_find		/* (LOCK lock, XA_CLIENT *client,AESPB *pb) */
{
	XA_WINDOW *w = find_window(lock, pb->intin[0], pb->intin[1]);	/* Is there a window under the mouse? */

	CONTROL(2,1,0)	

	pb->intout[0] = w ? w->handle : 0;

DIAG((D_wind, client, "wind_find ---> %d\n", pb->intout[0]));

	return XAC_DONE;
}

void top_window(LOCK lock, XA_WINDOW *w, XA_CLIENT *menu_owner)			/* HR */
{
	XA_WINDOW *old_focus;
	XA_CLIENT *client = w->owner;
	
	if (menu_owner == nil)
		menu_owner = w->owner;

	DIAG((D_wind,client,"top_window %d for %s\n",  w->handle, c_owner(client)));

	old_focus = window_list;

	pull_wind_to_top(lock, w);	/* New top window - change the cursor to this client's choice */

	if (client != menu_owner)
		C.focus = root_window;		/* HR */
	else
		C.focus = window_list;
	
	graf_mouse(client->mouse, client->mouse_form);
	display_window(lock, 40, old_focus, nil);  /* redisplay title */

	if (old_focus != w)
		display_window(lock, 41, w, nil);		/* Display the window */

	if (    w->send_message
	    and !was_visible(w)				/* HR 251002: Small but effective optimization. */
	   )
		w->send_message(lock, w, nil,
				WM_REDRAW, 0, 0, w->handle,
				w->r.x, w->r.y, w->r.w, w->r.h);
}

void bottom_window(LOCK lock, XA_WINDOW *w)
{
	bool was_top = (w == window_list);
	RECT clip;
	XA_WINDOW *wl = w->next;

DIAG((D_wind,w->owner,"bottom_window %d\n", w->handle));

	if (wl == root_window)			/* Don't do anything if already bottom */
		return;

	send_wind_to_bottom(lock, w);			/* Send it to the back */

DIAG((D_wind,w->owner," - menu_owner %s, w_list_owner %s\n", t_owner(get_menu()), w_owner(window_list)));
	if (window_list->owner != menu_owner())
		C.focus = root_window;		/* HR */
	else
		C.focus = window_list;

	display_window(lock, 42, w, nil);			/* Redisplay titles */
	display_window(lock, 43, window_list, nil);

	while (wl != w)			/* Our window is now right above root_window */
	{
		clip = wl->r;
		if (rc_intersect(w->r, &clip))
		{
			display_window(lock, 44, wl, &clip);		/* Re-display any revealed windows */
			via (wl->send_message)(lock, wl, nil,
							WM_REDRAW, 0, 0, wl->handle,
							clip.x, clip.y, clip.w, clip.h);
		}
		wl = wl->next;
	}

	if (was_top)
		send_ontop(lock);	/*  HR 060801: send WM_ONTOP to just topped window. */
}

#if GENERATE_DIAGS
static						/* Want to see quickly what app's are doing. */
char setget_names[][32] =
{
	"0",
	"WF_KIND(1)",
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

static
char unknown[32];

char *setget(int i)
{
	if (i < 0 or i >= WF_LAST)
	{
		sdisplay (unknown, "%d", i);
		return unknown;
	}
	return setget_names[i];
}

#endif

AES_function XA_wind_set	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	XA_WINDOW *w;
	XA_WIDGET *widg;
	XA_TREE *wt;
	OBJECT *ob;
	RECT clip;
	int wind = pb->intin[0], cmd = pb->intin[1];
	G_u *l;
	char *t;

	CONTROL(6,1,0)	

	w = get_wind_by_handle(lock, wind);

	DIAG((D_wind,client,"wind_set for %s  w%lx, h%d, %s\n", c_owner(client),
		w,w ? w->handle : -1, setget(cmd)));

	if (!w or wind eq 0)			/* HR 191002: !!! wind 0 is the root window */
	{
		switch(cmd)
		{
		case WF_TOP:				/* 310302: MagiC 5: wind_get(-1, WF_TOP) */
		case WF_NEWDESK:			/* Some functions may be allowed without a real window handle */
		case WF_WHEEL:				/* HR 111002 */
			break;
		default:
			DIAGS(("WARNING:wind_set for %s: Invalid window handle %d\n", c_owner(client), w));
			pb->intout[0] = 0;		/* Invalid window handle, return error */
			return XAC_DONE;
		}
	} else
		if (     w->owner != client		/* Clients can only change their own windows */
			and (   w     != root_window
			     or cmd   != WF_NEWDESK
			    )
		   )
		{
			DIAGS(("WARNING: %s cannot change window %d (not owner)\n", c_owner(client), w->handle));
			pb->intout[0] = 0;		/* Invalid window handle, return error */
			return XAC_DONE;
		}
	
	pb->intout[0] = 1;				/* HR 010402 */

	switch(cmd)
	{
	default:						/* HR 010402 */
		pb->intout[0] = 0;
		break;
	case WF_WHEEL:					/* HR 111002 */
		if (wind eq 0)
			client->wa_wheel = pb->intin[2];
		elif (w)
			w->wa_wheel = pb->intin[2];
		DIAGS(("wind_set(%d,WF_WHEEL,%d) for %s, %d, %d\n",
				wind, pb->intin[2], c_owner(client), client->wa_wheel, w->wa_wheel ));
		break;
	case WF_HSLIDE:
		widg = get_widget(w, XAW_HSLIDE);
		if (widg->stuff)
		{
			XA_SLIDER_WIDGET *slw = widg->stuff;
			slw->position = bound_sl(pb->intin[2]);		/* HR */
			display_widget(lock, w, widg);
		}
		break;
	case WF_VSLIDE:
		widg = get_widget(w, XAW_VSLIDE);
		if (widg->stuff)
		{
			XA_SLIDER_WIDGET *slw = widg->stuff;
			slw->position = bound_sl(pb->intin[2]);		/* HR */
			display_widget(lock, w, widg);
		}
		break;
	case WF_HSLSIZE:
		widg = get_widget(w, XAW_HSLIDE);
		if (widg->stuff)
		{
			XA_SLIDER_WIDGET *slw = widg->stuff;
			slw->length = bound_sl(pb->intin[2]);		/* HR */
			display_widget(lock, w, widg);
		}
		break;
	case WF_VSLSIZE:
		widg = get_widget(w, XAW_VSLIDE);
		if (widg->stuff)
		{
			XA_SLIDER_WIDGET *slw = widg->stuff;
			slw->length = bound_sl(pb->intin[2]);		/* HR */
			display_widget(lock, w, widg);
		}
		break;
	case WF_NAME:
		widg = get_widget(w, XAW_TITLE);
		l = (G_u *)(pb->intin);
		t = (char*)((long)l[2] << 16);
		t += l[3];
		if (t == nil)			/* HR */
			t = "";
		widg->stuff = t;
/*		copy_max(widg->stuff, t, sizeof(Path));
*/
		DIAG((D_wind, w->owner, "    -   %s\n", t));
		if ((w->active_widgets & NAME) and w->is_open)
		{
			rp_2_ap(w, widg, &clip);
			display_window(lock, 45, w, &clip);
		}
		break;
	case WF_INFO:
		widg = get_widget(w, XAW_INFO);
		l = (G_u *)(pb->intin);
		t = (char *)((long)l[2] << 16);
		t += l[3];
		if (t == nil)			/* HR */
			t = "";
		widg->stuff = t;

		if ((w->active_widgets & INFO) and w->is_open)
		{
			rp_2_ap(w, widg, &clip);
			display_window(lock, 46, w, &clip);
		}
		break;

	case WF_CURRXYWH:				/* Move a window, HR: check sizes */
		{
			G_i mw = pb->intin[4],
			    mh = pb->intin[5];
			if (w->active_widgets&USE_MAX)				/* HR 131101 */
			{
				if (w->max.w and mw > w->max.w)
					mw = w->max.w;
				if (w->max.h and mh > w->max.h)
					mh = w->max.h;
			}
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
		IFWL(Sema_Up(winlist);)

		if (w == nil)
		{
			if (wind == -1)			/* HR 010402: (-1,WF_TOP,apid) */
			{
				XA_CLIENT *target;
				if (pb->intin[2] > 0)
					target = Pid2Client(pb->intin[2]);
				else
					target = C.focus == root_window ? menu_owner() : C.focus->owner;
				app_in_front(lock|winlist, target);
				DIAG((D_wind,nil,"-1,WF_TOP: Focus to %s\n", c_owner(target)));
			}
		}
		else if (w->is_open)		/* HR 220801 */
		{
			if (        w != window_list
				or (    w == window_list
				    and w != C.focus
				   )		/* HR */
				)
			{
				if (is_hidden(w))
					unhide_window(lock|winlist, w);
				top_window(lock|winlist, w, nil);
				swap_menu(lock|winlist, w->owner, true, 5);		/* HR: needed because the changed behaviour in close_window. */
				after_top(lock|winlist, true);			/* HR: 310701 (forgotten) */
			}
		}
		IFWL(Sema_Dn(winlist);)

		break;
			
	case WF_NEWDESK:				/* Set a new desktop object tree */
		l = (G_u  *)pb->intin;
		t = (char *)((long)l[2] << 16);
		t += l[3];
		ob = (OBJECT *)t;
			
		if (ob)
		{
			client->desktop.tree = ob;
			client->desktop.owner = client;
			set_desktop(&client->desktop);
			DIAGS(("  desktop for %s to (%d/%d,%d/%d)\n", 
							c_owner(client), ob->r.x, ob->r.y, ob->r.w, ob->r.h));
			display_window(lock, 47, root_window, nil);
		} else
		{
			if (client->desktop.tree)
			{
				XA_CLIENT *new;
				client->desktop.tree = nil;
				/* HR 100701: find a prev app's desktop. */
				new = find_desktop(lock);
				set_desktop(&new->desktop);
				DIAGS(("  desktop for %s removed\n", c_owner(client)));
				display_window(lock, 48, root_window, nil);
			}
		}
		break;

/* HR Psema.... already in move_window */
	case WF_ICONIFY:				/* Iconify a window */
	{
		RECT in = *((RECT *)&pb->intin[2]);
		if (in.w == -1 and in.h == -1)
			in = free_icon_pos(lock);
		w->save_widgets = w->active_widgets;
		standard_widgets(w, NAME|MOVE|ICONIFY, true);
		move_window(lock, w, XAWS_ICONIFIED, in.x, in.y, in.w, in.h);
		break;
	}
	case WF_UNICONIFY:				/* Un-Iconify a window */
		standard_widgets(w, w->save_widgets, true);
		move_window(lock, w, XAWS_OPEN, w->ro.x, w->ro.y, w->ro.w, w->ro.h);
		break;
	case WF_TOOLBAR:
		{
			OBJECT *have;

			ob = *(OBJECT **)&pb->intin[2];
			widg = get_widget(w, XAW_TOOLBAR);
			wt = widg->stuff;
			have = wt ? wt->tree : nil;

			if (have == nil and ob == nil)
				break;

			if (have and ob == nil)
				remove_widget(lock, w, XAW_TOOLBAR);
			else
			if (ob and have == nil)
			{
				wt = set_toolbar_widget(lock, w, ob, pb->intin[5]);
				wt->exit_form = exit_toolbar;		/* HR 250602 */
				w->dial |= created_for_TOOLBAR;
			}
			else
			if (ob and ob == have)
			{
				if (w->is_open)
				{
					widg->start = pb->intin[4];
					wt->edit_obj = pb->intin[5];
					display_widget(lock, w, widg);
					widg->start = 0;
				}
				break;
			}

			if (w->is_open)
				via (w->send_message)(lock, w, nil,
							WM_REDRAW, 0, 0, w->handle,
							w->r.x, w->r.y, w->r.w, w->r.h);
		}
		break;
	case WF_MENU:
		if (    !w->is_open
		    and w->handle != 0
		    and (w->active_widgets&XaMENU) != 0
		   )
		{
			OBJECT *have;

			ob = *(OBJECT **)&pb->intin[2];
			widg = get_widget(w, XAW_MENU);
			wt = widg->stuff;
			have = wt ? wt->tree : nil;

			if (have == nil and ob == nil)
				break;

			if (have and ob == nil)
			{
				remove_widget(lock, w, XAW_MENU);
				w->active_widgets &= ~(XaMENU|MENUBAR);
			}
			else
			if (ob and have == nil)
			{
				wt = &w->menu_bar;
				memset(wt, sizeof(*wt), 0);
				wt->tree = ob;
				wt->owner = client;
				fix_menu(ob, false);
				set_menu_widget(w, &w->menu_bar);
			}
		}
		break;
	}

	return XAC_DONE;
}

/* Convert GEM widget numbers to XaAES widget indices. */
/* -1 means it is not a GEM object. */
static
WIDGET_I GtoX[] =
{
	-1,				/* W_BOX,		*/
	-1, 			/* W_TITLE,		*/
	WIDG_CLOSER,	/* W_CLOSER,	*/
	-1,				/* W_NAME,		*/
	WIDG_FULL,		/* W_FULLER,	*/
	-1,				/* W_INFO,		*/
	-1,				/* W_DATA,		*/
	-1,				/* W_WORK,		*/
	WIDG_SIZE,		/* W_SIZER,		*/
	-1,				/* W_VBAR,		*/
	WIDG_UP,		/* W_UPARROW,	*/
	WIDG_DOWN,		/* W_DNARROW,	*/
	-1,				/* W_VSLlDE,	*/
	-1,				/* W_VELEV,		*/
	-1,				/* W_HBAR,		*/
	WIDG_LEFT,		/* W_LFARROW,	*/
	WIDG_RIGHT,		/* W_RTARROW,	*/
	-1,				/* W_HSLIDE,	*/
	-1,				/* W_HELEV,		*/
	WIDG_ICONIFY,	/* W_SMALLER,	*/
	WIDG_HIDE		/* W_HIDER		*/
};

/*
 * AES wind_get() function.
 * This includes support for most of the AES4 / AES4.1 extensions,
 */

#if MEASURE_LINES_APP
extern long wind_gets;
#endif

AES_function XA_wind_get	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	XA_WINDOW *w;
	XA_RECT_LIST *rl;
	XA_SLIDER_WIDGET *slw;
	G_i *o = pb->intout, hex_version(void);
	RECT d, *ro = (RECT *)&pb->intout[1];
	int wind = pb->intin[0], cmd = pb->intin[1];
	
	CONTROL(2,5,0)	

#if MEASURE_LINES_APP
	wind_gets++;
#endif
	w = get_wind_by_handle(lock, wind);

DIAG((D_wind,client,"wind_get for %s  w=%lx, h:%d, %s\n",
			                 c_owner(client),w,wind,setget(cmd)));
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
			DIAGS(("WARNING:wind_get for %s: Invalid window handle %d\n", c_owner(client), wind));
			o[0] = 0;		/* Invalid window handle, return error */
			o[1] = 0;		/* HR 020402: clear args */
			o[2] = 0;		/*            Prevents FIRST/NEXTXYWH loops with invalid handle from looping forever. */
			o[3] = 0;
			o[4] = 0;

			return XAC_DONE;
		}
	}

	o[0] = 1;

	switch(cmd)
	{
	case WF_KIND:		/* HR 230801: new since N.Aes */
		o[1] = w->active_widgets;
		break;
	case WF_NAME:		/* HR 230801: new since N.Aes */
	{
		char *s = *(char **)&pb->intin[2];
		if (s)
			strcpy(s, get_widget(w, XAW_TITLE)->stuff);
		break;
	}
	case WF_INFO:		/* HR 230801: new since N.Aes */
		if (w->active_widgets&INFO)
		{
			char *s = *(char **)&pb->intin[2];
			if (s)
				strcpy(s, get_widget(w, XAW_INFO)->stuff);
		}
		else
			o[0] = 0;
		break;

	case WF_FTOOLBAR:		/* HR 200202: suboptimal, but for the moment it is more important that it van be used. */
	case WF_FIRSTXYWH:				/* Generate a rectangle list and return the first entry */
		IFWL(Sema_Up(winlist);)

		rl = rect_get_user_first(w);
/* HR: Oh, Oh  Leaving a intersect unchecked!! And forcing me to use a goto :-( */
		if (rl)
		{
			d = w->wa;
			if ( ! rc_intersect(rl->r, &d))
				goto next;		
			*ro = d;		/* Return the first rectangle coords */
		} else
		{
			ro->x = w->r.x;		/* Totally obscured window, return w & h as 0 */
			ro->y = w->r.y;
			ro->w = 0;
			ro->h = 0;
		}
DIAG((D_wind,client,"first for %s %d/%d,%d/%d\n", client->name, o[1], o[2], o[3], o[4]));
		IFWL(Sema_Dn(winlist);)
		break;
			
	case WF_NTOOLBAR:		/* HR 200202: suboptimal, but for the moment it is more important that it van be used. */
	case WF_NEXTXYWH:				/* Get next entry from a rectangle list */
		IFWL(Sema_Up(winlist);)
next:
		do{
			rl = rect_get_user_next(w);
			if (rl)
			{
				d = w->wa;
				if (rc_intersect(rl->r, &d))
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
DIAG((D_wind,client,"next for %s %d/%d,%d/%d\n", client->name, o[1], o[2], o[3], o[4]));
		IFWL(Sema_Dn(winlist);)
		break;

	case WF_TOOLBAR:
		{
			OBJECT *ob = get_widget(w, XAW_TOOLBAR)->stuff,
			       **have = (OBJECT **)&pb->intout[1];

			*have = ob;
		}
		break;
	case WF_MENU:
		{
			OBJECT *ob = get_widget(w, XAW_MENU)->stuff,
			       **have = (OBJECT **)&pb->intout[1];

			*have = ob;
		}
		break;

/* The info given by these function is very important to app's
        hence the DIAG's */			
	case WF_CURRXYWH:				/* Get the current coords of the window */		
		*ro = w->r;
DIAG((D_w,w->owner,"get curr for %d: %d/%d,%d/%d\n",wind ,ro->x,ro->y,ro->w,ro->h));
		break;

	case WF_WORKXYWH:				/* Get the current coords of the window's user work area */
		*ro = w->wa;
		if (w == root_window and !taskbar(client))
			ro->h -= 24;
DIAG((D_w,w->owner,"get work for %d: %d/%d,%d/%d\n",wind ,ro->x,ro->y,ro->w,ro->h));
		break;

	case WF_PREVXYWH:				/* Get previous window position */
		*ro = w->pr;
DIAG((D_w,w->owner,"get prev for %d: %d/%d,%d/%d\n",wind ,ro->x,ro->y,ro->w,ro->h));
		break;			

	case WF_FULLXYWH:				/* Get maximum window dimensions */
									/* This is the way TosWin2 uses the feature. Get the info and behave accordingly.
									   Not directly under AES control.  */
		if (!w || w == root_window)
		{
			ro->x = root_window->r.x; 
			ro->y = root_window->wa.y;	/* Ensure the windows don't overlay the menu bar */
			ro->w = root_window->r.w;
			ro->h = root_window->wa.h;
			if (!taskbar(client))
				ro->h -= 24;
DIAG((D_w,nil,"get max full: %d/%d,%d/%d\n", ro->x,ro->y,ro->w,ro->h));
		othw
			*ro = w->max;				/* HR */
DIAG((D_w,w->owner,"get full for %d: %d/%d,%d/%d\n",wind ,ro->x,ro->y,ro->w,ro->h));
		}
		break;

	case WF_BEVENT:					/* HR */
		o[1] = ((w->active_widgets&NO_TOPPED) != 0)&1;
		break;	
	case WF_BOTTOM:					/* Extension, gets the bottom window */
		IFWL(Sema_Up(winlist);)
#if 0
		for (w = window_list; w->next; w = w->next)
			;
#else
	/* HR!!! */
		w = root_window;
		if (w->prev)
			w = w->prev;
#endif
		IFWL(Sema_Dn(winlist);)
		o[1] = w->handle;		/* Return the window handle of the bottom window */
		o[2] = w->owner->pid;			/* Return the owner of the bottom window */
		break;
			
	case WF_TOP:
		IFWL(Sema_Up(winlist);)
		w = window_list;

		while (is_hidden(w))	/* 220801 */
			w = w->next;

		if (w)
		{
/*			if (C.focus == root_window)		/* HR 100801: Do not report unfocused window as top. */
				w = root_window;
*/
			o[1] = w->handle;	/* Return the window handle */
			o[2] = w->owner->pid;	/* AES4 specifies that you return the AESid of the owner here as well */
			DIAG((D_wind, client,"top window is %d of %s [%d]\n", o[1], w_owner(w), o[2]));
			if (w->next)	/* Is there a window below?  */
			{				/* If there is, then AES4 says return its handle here */
				o[3] = w->next->handle;
				o[4] = w->next->owner->pid;		/* XaAES extention - return the AESid of the app that owns the window below */
				DIAG((D_wind, client,"   --   window below is %d of %s\n", o[3], w_owner(w->next)));
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
		IFWL(Sema_Dn(winlist);)
		break;
			
	case WF_OWNER:					/* AES4 compatible stuff */
		IFWL(Sema_Up(winlist);)

		if (wind == 0)					/* If it is the root window, things arent that easy. */
			o[1] = get_desktop()->owner->pid;
		else
			o[1] = w->owner->pid;			/* The window owners AESid (==app_id == MiNT pid) */
#if 0
		o[2] = is_hidden(w) ? 0 : 1;		/* Is the window hidden? */
#else
		o[2] = w->is_open ? 0 : 1;		/* Is the window open? */
#endif
		if (w->prev)	/* If there is a window above, return its handle */
			o[3] = w->prev->handle;
		else
			o[3] = -1;		/* HR: dont return a valid window handle (root window is 0) */
							/*     Some programs (Multistrip!!) get in a loop */
		if (w->next)	/* If there is a window below, return its handle */
			o[4] = w->next->handle;
		else
			o[4] = -1;

		DIAG((D_wind, client,"  --  owner: %d(%d), above: %d, below: %d\n", o[1], o[2], o[3], o[4]));
		IFWL(Sema_Dn(winlist);)
		break;

	case WF_VSLIDE:
		if (w->active_widgets&VSLIDE)
		{
			slw = get_widget(w, XAW_VSLIDE)->stuff;
			o[1] = slw->position;
		}
		else
			o[0] = o[1] = 0;
		break;
			
	case WF_HSLIDE:
		if (w->active_widgets&HSLIDE)
		{
			slw = get_widget(w, XAW_HSLIDE)->stuff;
			o[1] = slw->position;
		}
		else
			o[0] = o[1] = 0;
		break;
			
	case WF_HSLSIZE:
		if (w->active_widgets&HSLIDE)
		{
			slw = get_widget(w, XAW_HSLIDE)->stuff;
			o[1] = slw->length;
		}
		else
			o[0] = o[1] = 0;
		break;
			
	case WF_VSLSIZE:
		if (w->active_widgets & VSLIDE)
		{
			slw = get_widget(w, XAW_VSLIDE)->stuff;
			o[1] = slw->length;
		}
		else
			o[0] = o[1] = 0;
		break;

	case WF_SCREEN:		/* HR return a very small area :-) hope app's      */
						/*    then decide to allocate a buffer themselves. */
						/*    This worked for SELECTRIC.  */
#if HALF_SCREEN
						/*   Alas!!!! not PS_CONTRL.ACC	  */
						/* So now its all become official */

		/* HR: make the quarter screen buffer for wind_get(WF_SCREEN) :-( :-( */
		/*    What punishment would be adequate for the bloke (or bird) who invented this? */


		if (client->half_screen_buffer == nil)
		{
		/* HR 170102: removed from  boot.c */
			long sc = ((640L*400/2)*screen.planes)/8;
			DIAGS(("sc: %ld, cl: %ld\n",sc,client->options.half_screen));
			if (client->options.half_screen)		/* HR 170102: Use if specified. whether greater or smaller. */
				client->half_screen_size = client->options.half_screen;
			else
				client->half_screen_size = sc;
			client->half_screen_buffer = XA_alloc(&client->base, client->half_screen_size, 1, 1111);
DIAGS(("half_screen_buffer for %s: mode:%x, %ld(%lx) size %ld use %ld\n",
			c_owner(client),
			(G_i)(MX_GLOBAL | MX_PREFTTRAM), client->half_screen_buffer, client->half_screen_buffer, client->half_screen_size, client->options.half_screen));
		}

		*(char  **)&o[1] = client->half_screen_buffer;
		*(size_t *)&o[3] = client->half_screen_size;
#else
		o[0] = o[1] = o[2] = o[3] = o[4] = 0;
#endif
		break;
	case WF_DCOLOR:
		DIAGS(("WF_DCOLOR %d for %s, %d,%d\n", o[1], c_owner(client),o[2],o[3]));
		goto oeps;
	case WF_COLOR:
		DIAGS(("WF_COLOR %d for %s\n", o[1], c_owner(client)));
	oeps:
		if (o[1] < W_HIGHEST)
		{
			OBJECT *widg = get_widgets();
			int i = GtoX[o[1]];
			OBJC_COLOURS c;

			if (i > 0 and (widg[i].ob_type&0xff) == G_BOXCHAR)
			{
				c = get_ob_spec(widg + i)->this.colours;
			othw
				c.borderc = screen.dial_colours.border_col;
				c.textc = BLACK;
				c.pattern = IP_SOLID;
				if (o[1] == W_VELEV or o[1] == W_HELEV)
					c.fillc = screen.dial_colours.shadow_col;
				else
					c.fillc = screen.dial_colours.bg_col;
				c.opaque = 0;			/* transparant */
			}

			o[2] = *(G_i *)&c;
		othw
			o[2] = 0x1178;		/* CAB hack */
		}
		o[3] = o[2];
		o[4] = 0xf0f; 	/* HR 010402 mask and flags 3d */
		DIAGS(("   --   %04x\n", o[2]));
		break;
	case WF_NEWDESK:
		Sema_Up(desk);

		*(OBJECT **)&o[1] = get_desktop()->tree;

		Sema_Dn(desk);
		break;
	
	case WF_ICONIFY:
		o[1] = w->window_status == XAWS_ICONIFIED ? 1 : 0;	/* HR 310302 */
		o[2] = C.iconify.w;
		o[3] = C.iconify.h;
		break;

	case WF_UNICONIFY:
		*ro = w->window_status == XAWS_ICONIFIED ? w->ro : w->r;	/* HR 310302: w->ro : w->r */
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
		DIAG((D_wind,client,"wind_get: %d\n",cmd));
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

void remove_windows(LOCK lock, XA_CLIENT *client)
{
	XA_WINDOW *wl, *nwl;

	DIAG((D_wind,client,"remove_windows for %s\n", c_owner(client)));

	IFWL(Sema_Up(winlist);)

	wl = window_list;
	while(wl)
	{
		nwl = wl->next;

		if (wl == root_window)		/* HR 250301 */
			break;
		if (wl->owner == client)
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
		if (wl->owner == client)
			delete_window(lock|winlist, wl);
		wl = nwl;
	}

	IFWL(Sema_Dn(winlist);)
}

AES_function XA_wind_new	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	CONTROL(0,0,0)	

	remove_windows(lock, client);

	return XAC_DONE;
}


/*
 * wind_calc			/* HR: embedded function calc_window() */
 */
AES_function XA_wind_calc	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	CONTROL(6,5,0)	

	*(RECT *)&pb->intout[1] =
	calc_window( lock,
	             client,
				 pb->intin[0],		/* request */
				 pb->intin[1],		/* widget mask */
				 MG,
				 client->options.thinframe,
				 client->options.thinwork,
		*(RECT *)&pb->intin[2]);

	pb->intout[0] = 1;
	return XAC_DONE;
}
