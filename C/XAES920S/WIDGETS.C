/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <osbind.h>
#include <mintbind.h>
#include <stdlib.h>
#include <string.h>

#include "xa_types.h"
#include "xa_globl.h"

#include "widgets.h"
#include "c_window.h"
#include "rectlist.h"
#include RSCHNAME
#include WIDGHNAME
#include "objects.h"
#include "xa_graf.h"
#include "xa_form.h"
#include "menuwidg.h"
#include "xa_rsrc.h"

static
OBJECT *def_widgets;

/*
 *	WINDOW WIDGET SET HANDLING ROUTINES
 *	This module handles the behaviour of the window widgets.
 */

static
void fix_widg(OBJECT *widg)
{
	widg->r.x = widg->r.y = 0;
}

/* Standard Widget Set from widget resource file */
global
void fix_default_widgets(void *rsc)
{
	short i;	
	def_widgets = ResourceTree(rsc, WIDGETS);
	DIAGS(("widget set at %lx\n", def_widgets));

	for (i=1; i < WIDG_CFG; i++)
		fix_widg(def_widgets + i);
}

global
OBJECT *get_widgets(void)
{
	return def_widgets;
}

global
bool m_inside(short x, short y, RECT *o)
{
	return (    x >= o->x
			and y >= o->y
			and x <  o->x+o->w
			and y <  o->y+o->h );
}


/*
 * Set the active/pending widget behaviour for a client
 */
static
void set_widget_active(XA_WINDOW *wind, XA_WIDGET *widg, WidgetBehaviour *wc, short i)
{
	widget_active.wind = wind;
	widget_active.widg = widg;
	widget_active.action = wc;
	widget_active.wait =true;
DIAG((D.mouse,-1,"[%d]set_widget_active for %s(%d) %d\n",i, wind->owner->name, wind->pid, wind->handle));
}

/*
 * Cancel the active/pending widget for a client
 */
global
void cancel_widget_active(XA_WINDOW *wind, short i)
{
		widget_active.widg = nil;
DIAG((D.mouse,-1,"[%d]cancel_widget_active for %s(%d) %d\n",i, wind->owner->name, wind->pid, wind->handle));
}


/* check slider value */
global
short bound_sl(short p)
{
	return p < 0 ? 0 : (p > 1000 ? 1000 : p);
}

/*
 * Convert window relative widget coords to absolute screen coords
 */
global
void *rp_2_ap(XA_WINDOW *wind, XA_WIDGET *widg, RECT *r)		/* HR use a RECT */
{
	RECT dr;
	short rtx, rty, ww, wh;
	short frame = wind->frame;

	if (frame < 0)
		frame = 0;

	if (r == nil)				/* HR 190701 */
		r = &dr;

/* HR: window frame size dynamic */
/*     thanks to the good design these 2 additions are all there is :-) */
	rtx = widg->loc.r.x + frame;
	rty = widg->loc.r.y + frame;

	r->w = widg->loc.r.w;
	r->h = widg->loc.r.h;
	r->x = wind->r.x;
	r->y = wind->r.y;

	ww = wind->r.w - SHADOW_OFFSET;
	wh = wind->r.h - SHADOW_OFFSET;

	switch(widg->loc.relative_type)
	{
	case LT:
		r->x += rtx;
		r->y += rty;
		break;
	case LB:
		r->x += rtx;
		r->y += (wh - r->h - rty);
		break;
	case RT:
		r->x += (ww - r->w - rtx);
		r->y += rty;
		break;
	case RB:
		r->x += (ww - r->w - rtx);
		r->y += (wh - r->h - rty);
		break;
	case CT:
		r->x += (ww - r->w) / 2;
		r->y += rty;
		break;
	case CR:
		r->x += (ww - r->w - rtx);
		r->y += (wh - r->h) / 2;
	case CB:
		r->x += (ww - r->w) / 2;
		r->y += (wh - r->h - rty);
		break;
	case CL:
		r->x += rtx;
		r->y += (wh - r->h - rty);
		break;
	}
/* HR: for after moving: set form's x & y, otherwise find_object
		fails.
*/
	if (   widg->type == XAW_TOOLBAR
		or widg->type == XAW_MENU		/* HR: 091200 */
		)
	{
		XA_TREE *wt;
		OBJECT *form;
		
		wt = widg->stuff;
		form = wt->tree;
		form->r.x = r->x;
		form->r.y = r->y;

		return form;		/* If want to get informed */
	}

	return nil;
}

global
void display_widget(LOCK lock, XA_WINDOW *wind, XA_WIDGET *widg)
{
	WidgetBehaviour *disp = widg->behaviour[XACB_DISPLAY];

	if (disp)			/* HR 100701: if removed or lost */
	{
/* HR 260501: Some programs do this! */
		if (!(   wind->window_status == XAWS_ICONIFIED
			  and widg->type != XAW_TITLE
			  and widg->type != XAW_ICONIFY
		   ) )
		{
			XA_RECT_LIST *rl;

			if unlocked(winlist)
				Sema_Up(WIN_LIST_SEMA);
			hidem();
			rl = rect_get_system_first(wind);
			while (rl)
			{		/* Walk the rectangle list */
				set_clip(&rl->r);
				(*disp)(lock|winlist, wind, widg);
				rl = rect_get_system_next(wind);
			}
			clear_clip();
			showm();
			if unlocked(winlist)
				Sema_Dn(WIN_LIST_SEMA);
		}
	}
}

global
void redraw_menu(LOCK lock)
{
	display_widget(lock, root_window, root_window->widgets + XAW_MENU);
}


/*
 * Calculate the size of the work area for a window and store it
 * - This is needed because the locations of widgets are relative and
 *   can be modified.
 * Actually, this updates all the dynamic sized elements from the standard widget set...
 * (namely: work area, sliders and title bar)
 */

#define WASP 1	/* space between workarea and other widgets */

global
void calc_work_area(XA_WINDOW *wi)
{
	RECT r = wi->r, *rt;
	XA_SLIDER_WIDGET *sl;
	XA_WIND_ATTR k = wi->active_widgets;
	short bottom = 0, right = 0,
	      tl_margin, br_margin, wa_margins,
	      winside, hinside;

	wi->wa = r;

	if ((k&V_WIDG) == 0)
	{
		wi->wa.x += 1;
		wi->wa.y += 1;
		wi->wa.w -= 2 + SHADOW_OFFSET;
		wi->wa.h -= 2 + SHADOW_OFFSET;
	othw
	/* a colour work area frame is larger to allow for the fancy borders :-)
	   a color work area frame consists of a grey, a light and a dark line.   */
	
		tl_margin = MONO ? 1 : 2;	/* in color aligning is on the top & left light line of tha wa */
		br_margin = MONO ? 1 : 3;	/* The visual thing :-) */
		wa_margins = tl_margin + br_margin;
	
	/* This is the largest work area possible */
		if (wi->frame >= 0)
		{
			wi->wa.x += wi->frame + tl_margin;
			wi->wa.y += wi->frame + tl_margin;
			wi->wa.w -= 2*wi->frame + wa_margins + SHADOW_OFFSET;
			wi->wa.h -= 2*wi->frame + wa_margins + SHADOW_OFFSET;
		}
		winside = wi->wa.w + wa_margins;
	/*	hinside = wi->wa.h + wa_margins; */
	
		if (k & (CLOSE|NAME|MOVE|SMALLER|FULLER))	/* top bar */
			wi->wa.y+= ICON_H + 2,
			wi->wa.h-= ICON_H + 2;
		
		rt = &wi->widgets[XAW_TITLE].loc.r;
		rt->w = winside;

		if (k & CLOSER)
			rt->w -= ICON_W+1;				/* + space between name and closer */
											/*   name has a inside border */
		if (k & (SMALLER|FULLER))
		{
			rt->w -=  MONO ? 1 : 2;	/* Due to pushbutton behaviour in color, in mono its a rectangle. */
			if (k & FULLER)
				rt->w -= ICON_W;
			if (k & SMALLER)
				rt->w -= ICON_W;
		}

		if (wi->window_status != XAWS_ICONIFIED)
		{
			if (k & INFO)							/* fatter topbar */
				wi->wa.y+= ICON_H,
				wi->wa.h-= ICON_H;
			if (k & XaMENU)							/* HR: menu is a standard widget! */
				wi->wa.y+= ICON_H + 3,				/*     Now I can specify the desktop window w/o dummy name. :-) */
				wi->wa.h-= ICON_H + 3;
	
			if (k & (UPARROW|DNARROW|VSLIDE))		/* right bar */
				right = 1;
			if (k & (LFARROW|RTARROW|HSLIDE))		/* bottom bar */
				wi->wa.h-= ICON_H+WASP,				/* + spacer */
				bottom = 1;
	
			if (right or ((k&SIZER) and !(right or bottom)))	/* sizer only retain right bar */
				wi->wa.w-= ICON_W+WASP;				/* + spacer */
	
			if (k & INFO)							/* Update info bar */
				rt = &wi->widgets[XAW_INFO].loc.r,
				rt->w = winside;					/* full width inside standard borders */
			if (k & XaMENU)
				rt = &wi->widgets[XAW_MENU].loc.r,
				rt->w = winside;
	
		/* Sliders are completely oriented on the work area */
	
			if (k & HSLIDE)							/* Update horizontal slider */
			{
				sl = wi->widgets[XAW_HSLIDE].stuff;
				sl->r.w = 0;		/* initializes slider draw */
	
				rt = &wi->widgets[XAW_HSLIDE].loc.r;
				rt->w = wi->wa.w + wa_margins;
				if (k & LFARROW)					/* includes RTARROW */
					rt->w -= 2*ICON_W;
				if ((k & SIZER) and !right)
					rt->w -= ICON_H;
			}
			if (k & VSLIDE)							/* Update vertical slider */
			{
				sl = wi->widgets[XAW_VSLIDE].stuff;
				sl->r.h = 0;		/* initializes slider draw */
	
				rt = &wi->widgets[XAW_VSLIDE].loc.r;
				rt->h = wi->wa.h + wa_margins;
				if (k & DNARROW)					/* includes UPARROW */
					rt->h -= 2*ICON_H;
				if ((k & SIZER) and !bottom)
					rt->h -= ICON_H;
			}
		}
	}
/* HR: new */
	wi->bd.x = wi->r.x - wi->wa.x;	/* border displacement */
	wi->bd.y = wi->r.y - wi->wa.y;
	wi->bd.w = wi->r.w - wi->wa.w;
	wi->bd.h = wi->r.h - wi->wa.h;
	/* Add bd to toolbar->r to get window rectangle for create_window */
	/* Anyhow, always convenient, especially when snapping the workarea. */
	DIAG((D.widg,wi->pid,"workarea %d: %d/%d,%d/%d\n", wi->handle, wi->wa));
}

/*
 * Define the widget locations using window relative coordinates.
 */

/* HR: needed a dynamic margin (for windowed list boxes) */
/* eliminated both margin and shadow sizes from this table */
static
XA_WIDGET_LOCATION
/* HR better spacing                    defaults        */
	stdl_close   = {LT, 0,      0,      ICON_W, ICON_H},
	stdl_full    = {RT, 0,      0,      ICON_W, ICON_H},
	stdl_iconify = {RT, 0,      0,      ICON_W, ICON_H},
	stdl_title   = {LT, 0,      0,      ICON_W, ICON_H},
	stdl_resize  = {RB, 0,      0,      ICON_W, ICON_H},
	stdl_rscroll = {RB, ICON_W, 0,      ICON_W, ICON_H},
	stdl_lscroll = {LB, 0,      0,      ICON_W, ICON_H},
	stdl_uscroll = {RT, 0,      0,      ICON_W, ICON_H},
	stdl_dscroll = {RB, 0,      ICON_H, ICON_W, ICON_H},
	stdl_vslide  = {RT, 0,      ICON_H, ICON_W, ICON_H},
	stdl_hslide  = {LB, ICON_W, 0,      ICON_W, ICON_H},
	stdl_info    = {LT, 0,      0,      ICON_W, ICON_H},
	stdl_menu    = {LT, 0,      0, 		ICON_W, ICON_H+3}
	;

/* HR: Establish iconified window position from a simple ordinal. */
global
RECT iconify_grid(short i)
{
	RECT ic = {0,0,ICONIFIED_W,ICONIFIED_H};
	short j, w = screen.r.w/ic.w;

	ic.x = screen.r.x;
	ic.y = screen.r.y + screen.r.h - 1 - ic.h;

	j = i/w;
	i %= w;

	ic.x += i*ic.w;
	ic.y -= j*ic.h;

	return ic;
}

static
WidgetBehaviour display_def_widget	/* (LOCK lock, XA_WINDOW *wind, XA_WIDGET *widg) */
{
	RECT r; short i = widg->rsc_index;

	rp_2_ap(wind, widg, &r);

	if (widg->state & SELECTED)
		def_widgets[i].ob_state |= SELECTED;
	else
		def_widgets[i].ob_state &= ~SELECTED;
	
	wind->tree_info.tree = def_widgets;
	display_object(lock, &wind->tree_info, i, r.x, r.y, false);

	return true;
}

/*======================================================
	TITLE WIDGET BEHAVIOUR
========================================================*/
static
WidgetBehaviour display_title	/* (LOCK lock, XA_WINDOW *wind, XA_WIDGET *widg) */
{
	char t[256],tn[256];
	RECT r;

	rp_2_ap(wind, widg, &r);			/* Convert relative coords and window location to absolute screen location */

	wr_mode(MD_TRANS);

#if DISPLAY_LOGO_IN_TITLE_BAR				/* HR: It ressembles too much a closer */
	if (widg->stat & SELECTED)
		def_widgets[WIDG_LOGO].ob_state |= SELECTED;
	else
		def_widgets[WIDG_LOGO].ob_state &= ~SELECTED;

	wind->wt.tree = def_widgets;
	display_object(lock, wind->wt, WIDG_LOGO, x, y, false);

/* HR: tiny pixel correction (better spacing) */
	r.x += ICON_W + 2;
	r.w -= ICON_W + 2;
#endif

	if MONO
	{
		f_color(WHITE);
		t_color(BLACK);

		if (wind == window_list and wind == C.focus)	/* HR */
			vst_effects(C.vh, cfg.topname);			/* Highlight the title bar of the top window */
		else
			vst_effects(C.vh, cfg.backname);
		p_gbar(0, &r);								/* with inside border */
	} else
	{
		if (wind == window_list and wind == C.focus)	/* HR */
			t_color(BLACK);				/* Highlight the title bar of the top window */
		else
			t_color(WHITE);

		d3_pushbutton(-2,&r,nil,widg->state,0,0);
	}

	if (cfg.windowner and wind->owner and !wind->winob and !wind->dial)
	{
		char *ow = nil;
		if (cfg.windowner == 1)
			ow = wind->owner->proc_name;
		else
		if (cfg.windowner == 2)
			ow = wind->owner->name;

		if  (ow)
		{
			char ns[32];
			strip_name(ns, ow);
			if (*ns)
				sdisplay(tn, "(%s) %s", ns, widg->stuff);
			else
				ow = nil;
		}

		if (!ow)
			sdisplay(tn, "(%d) %s", wind->pid, widg->stuff);
	}
	else
		strcpy(tn, widg->stuff);

	if (*tn ne ' ')		/* HR 080501: avoid inner border. */
		r.x += 2;

	v_gtext(C.vh, r.x, r.y,
			cramped_name(	tn,
							t,
							(r.w/screen.c_max_w)-1
						)
			);

	if MONO
		vst_effects(C.vh, 0);		/* normal */

	return true;
}

/*
 * Click & drag on the title bar - does a move window
 */
static
WidgetBehaviour drag_title	/* (LOCK lock, XA_WINDOW *wind, XA_WIDGET *widg) */
{
	short x, y;

	if (wind->active_widgets & MOVER)		/* You can only move a window if its MOVER attribute is set */
	{
		if unlocked(winlist)
			Sema_Up(WIN_LIST_SEMA);		/* HR */

#if PRESERVE_DIALOG_BGD
		{
			XA_WINDOW *scan_wind;
			if (wind != window_list)		/* Don't allow windows below a STORE_BACK to move */
				for (scan_wind = wind->prev; scan_wind; scan_wind = scan_wind->prev)
					if (scan_wind->active_widgets & STORE_BACK)
					{
						if unlocked(winlist)
							Sema_Dn(WIN_LIST_SEMA);		/* HR */
						return true;
					}
		}
#endif
	/*	clear_clip();			/* FIX_PC avoid clashes with Pure C binding */
	*/	graf_mouse(XACRS_MOVER, nil);		/* Always have a nice consistent MOVER when dragging a box */

		drag_box(wind->r.w, wind->r.h, wind->r.x, wind->r.y,
					-root_window->r.w, root_window->wa.y,
					root_window->r.w*3, root_window->r.h*2,
					&x, &y);

/* HR: */
		/* Restore the mouse now we've done the drag */
		graf_mouse(wind->owner->client_mouse, wind->owner->client_mouse_form);

		if ((x != wind->r.x) or (y != wind->r.y))
			if (wind->active_widgets & NO_MESSAGES)		/* Just move these windows, they can handle it... */
				move_window(lock|winlist, wind, -1, x, y, wind->r.w, wind->r.h);
			else				/* Send a message to a client to say that the AES would like the window moving (if the window has moved) */
				wind->send_message(lock|winlist, wind, wind->pid, WM_MOVED, 0, wind->handle, x, y, wind->r.w, wind->r.h);
	
		if unlocked(winlist)
			Sema_Dn(WIN_LIST_SEMA);
	}

	cancel_widget_active(wind, 1);
	return true;
}

/*
 * Single click title bar sends window to the back
 */
static
WidgetBehaviour click_title	/* (LOCK lock, XA_WINDOW *wind, XA_WIDGET *widg) */
{
	XA_WINDOW *wl, *old_focus;
	RECT clip, our_win;
	if (       wind != window_list		/* HR: if not on top or on top and not focus */
		or (   wind == window_list
		    and wind != C.focus
		   )
	   )
		if (wind->active_widgets & NO_MESSAGES)		/* Just top these windows, they can handle it... */
			top_window(lock, wind, wind->pid);		/* Top the window */
		else
			wind->send_message(lock, wind, wind->pid, WM_TOPPED, 0, wind->handle, 0, 0, 0, 0);
	else	/* If window is already top, then send it to the back */
		if ( ! (   (wind->active_widgets & STORE_BACK) != 0		/* Don't bottom STORE_BACK windows */
		        or (wind->active_widgets & BACKDROP) == 0		/* Don/t bottom NO BACKDROP windows */
		       )
		   )
			if (wind->active_widgets & NO_MESSAGES)
				bottom_window(lock, wind);
			else
				wind->send_message(lock, wind, wind->pid, WM_BOTTOMED, 0, wind->handle, 0, 0, 0, 0);
	return true;
}

/*
 * Double click title bar of iconified window - sends a restore message
 */
static
WidgetBehaviour dclick_title	/* (LOCK lock, XA_WINDOW *wind, XA_WIDGET *widg) */
{
	if (wind->active_widgets & NO_MESSAGES)
		return false;
	
	/* If window is iconified - send request to restore it */

	if (wind->window_status == XAWS_ICONIFIED)
		wind->send_message(lock, wind, wind->pid, WM_UNICONIFY, 0, wind->handle, wind->pr.x, wind->pr.y, wind->pr.w, wind->pr.h);
	
	return true;
}

/*======================================================
	CLOSE WIDGET BEHAVIOUR
========================================================*/
/* Displayed by display_def_widget */

/* 
 * Default close widget behaviour - just send a WM_CLOSED message to the client that
 * owns the window.
 */
static
WidgetBehaviour click_close	/* (LOCK lock, XA_WINDOW *wind, XA_WIDGET *widg) */
{
	if (wind->active_widgets & NO_MESSAGES)
	{	/* Just close these windows, they can handle it... */
		close_window (lock, wind);
		delete_window(lock, wind);
		return false;	/* Don't redisplay in the do_widgets() routine as window no longer exists */
	}
	
	wind->send_message(lock, wind, wind->pid, WM_CLOSED, 0, wind->handle, 0, 0, 0, 0);

	return true; /* Redisplay.... */
}

/*======================================================
	FULLER WIDGET BEHAVIOUR
========================================================*/
/* Displayed by display_def_widget */

/* Default full widget behaviour - Just send a WM_FULLED message to the client that */
/* owns the window. */
static
WidgetBehaviour click_full	/* (LOCK lock, XA_WINDOW *wind, XA_WIDGET *widg) */
{
	wind->send_message(lock, wind, wind->pid, WM_FULLED, 0, wind->handle, 0, 0, 0, 0);
	return true;
}

/*======================================================
	ICONIFY WIDGET BEHAVIOUR
========================================================*/
/* Displayed by display_def_widget */

/*
 * click the iconify widget
 */
static
WidgetBehaviour click_iconify	/* (LOCK lock, XA_WINDOW *wind, XA_WIDGET *widg) */
{
	short i = 0;
	RECT ic;

	if (wind->active_widgets & NO_MESSAGES)
		return false;

	switch(wind->window_status)
	{
	case XAWS_OPEN:			/* Window is open - send request to iconify it */
		if unlocked(winlist)
			Sema_Up(WIN_LIST_SEMA);

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
	/* Could the whole screen be covered by iconified windows? That would be an achievement, wont it? */
		if (ic.y > root_window->wa.y)
			wind->send_message(lock|winlist, wind, wind->pid, WM_ICONIFY, 0, wind->handle, ic.x, ic.y, ic.w, ic.h);

		if unlocked(winlist)
			Sema_Up(WIN_LIST_SEMA);
	break;	

	case XAWS_ICONIFIED:	/* Window is already iconified - send request to restore it */
		wind->send_message(lock, wind, wind->pid, WM_UNICONIFY, 0, wind->handle, wind->ro.x, wind->ro.y, wind->ro.w, wind->ro.h);
		break;
	}
	
	return true; /* Redisplay.... */
}

/*======================================================
	INFO BAR WIDGET BEHAVIOUR
========================================================*/
static
WidgetBehaviour display_info		/* (LOCK lock, XA_WINDOW *wind, XA_WIDGET *widg) */
{
	short pnt[6];
	char t[160];
	RECT r;

	rp_2_ap(wind, widg, &r);	/* Convert relative coords and window location to absolute screen location */

	if (!MONO)	 			/* HR: in mono just leave unbordered */
	{
		tl_hook( 0, &r, screen.dial_colours.lit_col);
		br_hook( 0, &r, screen.dial_colours.shadow_col);
	}
	t_color(BLACK);
/* HR */
	v_gtext(C.vh, r.x + 4, r.y, clipped_name(widg->stuff, t, (r.w/screen.c_max_w)-1));

	return true;
}

/*======================================================
	RESIZE WIDGET BEHAVIOUR
========================================================*/
/* Displayed by display_def_widget */

/* HR: use the distance from the mouse to the lower right corner.
	just like WINX & MagiC */
static
WidgetBehaviour drag_resize	/* (LOCK lock, XA_WINDOW *wind, XA_WIDGET *widg) */
{
	short mb,x,y,w,h;
	RECT r = wind->r;

/*	clear_clip();
*/
	graf_mouse(XACRS_RESIZER, nil);		/* Always have a nice consistent SIZER when resizing a window */
	vq_mouse(C.vh, &mb, &x, &y);
	rubber_box(	r.x, r.y,
				6*ICON_W, 4*ICON_W,			/* HR: minimum */
				wind->max.w, wind->max.h,	/*     maximum */
				r.x + r.w - x, r.y + r.h - y,
				&w, &h);
/* HR:	*/
	/* Restore the mouse now we've done the drag */
	graf_mouse(window_list->owner->client_mouse, window_list->owner->client_mouse_form);

/* Send a message to the client to say that the AES would like the window re-sizing */
	if ((w != wind->r.w) or (h != wind->r.h))
		wind->send_message(lock, wind, wind->pid, WM_SIZED, 0, wind->handle, wind->r.x, wind->r.y, w, h);

	return true;
}


/*
 *	Scroll bar & Slider handlers
 */

#if 1			/* HR: Grand unification */

/*======================================================
	SCROLL WIDGET BEHAVIOUR
========================================================*/
/* Displayed by display_def_widget */

static
WidgetBehaviour click_scroll	/* (LOCK lock, XA_WINDOW *wind, XA_WIDGET *widg) */
{
	short mx, my, mb;
	XA_WIDGET *slider = &wind->widgets[widg->slider_type];

	if (!(   widget_active.widg
		  and slider
		  and slider->stuff
		  and ((XA_SLIDER_WIDGET *)slider->stuff)->position == widg->limit
		 )
	   )
	{
		wind->send_message(lock, wind, wind->pid, WM_ARROWED, 0, wind->handle, widg->arrowx, 0, 0, 0);
		vq_mouse(C.vh, &mb, &mx, &my);
	
		if (mb)	/* If the button has been held down, set a pending/active widget for the client */
		{
			set_widget_active(wind, widg, widg->behaviour[XACB_DRAG],1);		/* function itself */
			return false;	/* We return false here so the widget display status stays selected whilst it repeats */
		}
	}

	cancel_widget_active(wind, 2);
	return true;
}

#else
#include "obsolete/old_scro.h"		/* obsolete separate functions */
#endif

void slider_back(RECT *cl)
{
	f_color(screen.dial_colours.bg_col);
	f_interior(FIS_SOLID);
	gbar(0, cl);
}

/*======================================================
	VERTICAL SLIDER WIDGET BEHAVIOUR
	The slider widgets are slightly more complex than other widgets
	as they have three separate 'widgets' inside them.
	(I know GEM doesn't have these, but I think they're cool)

	HR: NO NO NO, they're NOT cool, they're unnecessarily ugly and complex!!
		They would have been cool though, if the widget structure had been nested,
		and the widget handling code recursive.
		Maybe once I'll implement such a thing.

	HR: code to safeguard the actual boundaries of the whole slider widget.
		We want to be independent of arithmatic rounding.

	Also: introduction of a slider rectangle in XA_SLIDER_WIDGET,
		  saves some arithmetic, but more important,
		  this was necessary since the introducion of a mimimum size.
	Optimization of drawing.
========================================================*/

/* Display now includes the background */
global
WidgetBehaviour display_vslide	/* (LOCK lock, XA_WINDOW *wind, XA_WIDGET *widg) */
{
	RECT r; short len, offs;
	XA_SLIDER_WIDGET *sl = widg->stuff;
	RECT cl;

	rp_2_ap(wind, widg, &r);	/* Convert relative coords and window location to absolute screen location */

	if (sl->length >= 1000)
	{
		sl->r = r;
		slider_back(&r);
		return true;
	}

	wr_mode(MD_REPLACE);

	len = ((long)r.h * sl->length) / 1000;
	if (len < ICON_H-3)				/* HR: not too small please */
		len = ICON_H-3;
	offs = r.y + (((long)r.h - len) * sl->position) / 1000;

#if ! DRAW_TEST						/* otherwise we dont see whats going wrong ;-) */
	if (offs < r.y)
		offs = r.y;
	if (offs + len > r.y + r.h)
		len = r.y + r.h - offs;;
#endif
	if (   sl->r.h == 0		/* if initial, or after sizing or off top */
		or wind != window_list)
	{
		sl->r = r;
		slider_back(&r);	/* whole background */
	} else
	{						/* should really use rc_intersect */
		cl = sl->r;				/* remove old slider or parts */
		if (   sl->r.h == len	/* parts work only when physical length didnt change */
			and !(offs + len < sl->r.y or offs > sl->r.y + sl->r.h)	/* if overlap */
			) 		
		{
			if (sl->r.y < offs)		/* down */
				cl.h = offs - sl->r.y;
			else					/* up */
			{
				cl.y = offs + len;
				cl.h = sl->r.y - offs;
			}
		}
		if (cl.h)
			slider_back(&cl);
	}

/* this rectangle to be used for click detection and drawing */
	sl->r.y = offs;
	sl->r.h = len;

/* HR: there are so much nice functions, use them!!! :-) */
/* The small corrections are needed because the slider sits in a enclosure,
the function is normally used for buttons that may be drawn a little larger
than there official size. the small negative numbers makes the button
exactly that amount smaller than the standard. (The standard is 1 outline border) */

	{
		short thick = 1, mode = 3;
		if (MONO)
			mode = 1;
		elif (wind != window_list)
			thick = 0;

		d3_pushbutton(-2, &sl->r, nil, widg->state, thick, mode);
	}

	wr_mode(MD_TRANS);
	return true;
}

/*======================================================
	HORIZONTAL SLIDER WIDGET BEHAVIOUR
	same as vertical, except for x,w & y,h
========================================================*/

global
WidgetBehaviour display_hslide
{
	RECT r; short len, offs;
	XA_SLIDER_WIDGET *sl = widg->stuff;
	RECT cl;

	rp_2_ap(wind, widg, &r);

	if (sl->length >= 1000)
	{
		sl->r = r;
		slider_back(&r);
		return true;
	}

	wr_mode(MD_REPLACE);

	len = ((long)r.w * sl->length) / 1000;
	if (len < ICON_W-3)
		len = ICON_W-3;
	offs = r.x + (((long)r.w - len) * sl->position) / 1000;

#if ! DRAW_TEST						/* otherwise we dont see whats going wrong ;-) */
	if (offs < r.x)
		offs = r.x;
	if (offs + len > r.x + r.w)
		len = r.x + r.w - offs;
#endif

	if (   sl->r.w == 0
		or wind != window_list)
	{
		sl->r = r;
		slider_back(&r);
	} else
	{
		cl = sl->r;
		if (	sl->r.w == len
			and !(offs + len < sl->r.x or offs > sl->r.x + sl->r.w)
			)
		{
			if (sl->r.x < offs)
				cl.w = offs - sl->r.x;
			else
			{
				cl.x = offs + len;
				cl.w = sl->r.x - offs;
			}
		}
		if (cl.w)
			slider_back(&cl);
	}

	sl->r.x = offs;
	sl->r.w = len;

	{
		short thick = 1, mode = 3;
		if (MONO)
			mode = 1;
		elif (wind != window_list)
			thick = 0;

		d3_pushbutton(-2, &sl->r, nil, widg->state, thick, mode);
	}

	wr_mode(MD_TRANS);
	return true;
}


/* HR 050601: Heavily cleaned up the code.
   As a reward the sliders do NOT behave sticky at the edges.
   I immensely hate that behaviour, as it seems to be standard.
   It is stupidly unnatural.
		Note, that the stuff for clicking on page arrows has completely vanished,
		as that is mow unified with the line arrows.
*/

static
WidgetBehaviour drag_vslide	/* (LOCK lock, XA_WINDOW *wind, XA_WIDGET *widg) */
{
	XA_SLIDER_WIDGET *sl = widg->stuff;
	short pmx, pmy, mx, my, mb;
	short offs, noffs, len;
	RECT r;

	rp_2_ap(wind, widg, &r);	/* Convert relative coords and window location to absolute screen location */

	len = sl->r.h;
	offs = sl->position;

	vq_mouse(C.vh, &mb, &pmx, &pmy);  /* need to do this anyhow, for mb */

	if (widget_active.widg)		/* pending widget: take that */
	{
		pmy = widget_active.y;
		offs = widget_active.offs;
	}

	noffs = offs;

	if (mb)		/* Drag slider */
	{
		vq_mouse(C.vh, &mb, &mx, &my);
		if (my != pmy)			/* Has the mouse moved? */
			noffs = bound_sl( offs + (1000L * (my - pmy)) / (widg->loc.r.h - len) );
		set_widget_active(wind, widg, drag_vslide,2);
		widget_active.y = my;
		widget_active.offs = noffs;

		wind->send_message(lock, wind, wind->pid, WM_VSLID, 0, wind->handle, noffs, 0, 0, 0);

		return false;	/* We return false here so the widget display status stays selected whilst it repeats */
	}

	cancel_widget_active(wind, 3);
	return true;
}

static
WidgetBehaviour drag_hslide	/* (LOCK lock, XA_WINDOW *wind, XA_WIDGET *widg) */
{
	XA_SLIDER_WIDGET *sl = widg->stuff;
	short pmx, pmy, mx, my, mb;
	short offs, noffs, len;
	RECT r;

	rp_2_ap(wind, widg, &r);	/* Convert relative coords and window location to absolute screen location */

	len = sl->r.w;
	offs = sl->position;

	vq_mouse(C.vh, &mb, &pmx, &pmy);  /* need to do this anyhow, for mb */

	if (widget_active.widg)		/* pending widget: take that */
	{
		pmx = widget_active.x;
		offs = widget_active.offs;
	}

	noffs = offs;

	if (mb)		/* Drag slider */
	{
		vq_mouse(C.vh, &mb, &mx, &my);
		if (mx != pmx)			/* Has the mouse moved? */
			noffs = bound_sl( offs + (1000L * (mx - pmx)) / (widg->loc.r.w - len) );

		set_widget_active(wind, widg, drag_hslide,3);
		widget_active.x = mx;
		widget_active.offs = noffs;
		wind->send_message(lock, wind, wind->pid, WM_HSLID, 0, wind->handle, noffs, 0, 0, 0);
		return false;	/* We return false here so the widget display status stays selected whilst it repeats */
	}

	cancel_widget_active(wind, 4);
	return true;
}

/*
 *	Generic Object Tree Widget display
 */
static
WidgetBehaviour display_object_widget	/* (LOCK lock, XA_WINDOW *wind, XA_WIDGET *widg) */
{
	XA_TREE *wt = widg->stuff;
	OBJECT *root;

	if (wind->owner->killed)
		return false;

	root = rp_2_ap(wind, widg, nil);	/* Convert relative coords and window location to absolute screen location */
	DIAG((D.form,wind->pid,"after rp_2_ap: %d/%d\n", root->r.x, root->r.y));

	DIAG((D.form,wind->pid,"display_object_widget(wind=%d), is_edit=%d, form: %d/%d\n", wind->handle,wt->edit_obj, root->r.x, root->r.y));
	/* HR: */
	draw_object_tree(lock, wt, nil, widg->start ,100, is_menu(root),3);

	return true;
}

static
WidgetBehaviour display_arrow
{
	return true;
}


/* HR : moved the following to the end of the file, this way all function that are referenced, are already defined */
/*      removed a very annoying & confusing connection between bit number of a mask and a enum value */
static
void shift_from_top(XA_WINDOW *wind, XA_WIDGET *widg, long tp, short xtra)
{
	short wd;

	for (wd = 0; wd < XA_MAX_WIDGETS; wd++)	/* Shift any widgets we might interfere with */
	{
		XA_WIDGET *tw = wind->widgets + wd;
		if (tp & tw->mask)
			if (   tw->loc.relative_type == LT
				or tw->loc.relative_type == RT
				or tw->loc.relative_type == CT
			   )
				tw->loc.r.y += widg->loc.r.h + xtra;
	}
}

/*
 * Setup the required 'standard' widgets for a window. These are the ordinary GEM
 * behaviours. These can be changed for any given window if you want special behaviours.
 */
global
void standard_widgets(XA_WINDOW *wind, XA_WIND_ATTR tp, bool keep_stuff)
{
	XA_WIDGET *widg;
	short wd, bottom = 0, right = 0;

	wind->active_widgets = tp;			/* Fill in the active widgets summary */
	wind->widgets_on_top = 0;

	if (tp&(LFARROW|HSLIDE|RTARROW))
		bottom = 1;
	if (tp&(UPARROW|VSLIDE|DNARROW))
		right = 1;

/* HR: saved some lines of code        loc.r.w & loc.r.h  are now in the stdl_... */
	if (keep_stuff)
	{
		for (wd = 0; wd < XA_MAX_WIDGETS; wd++)
		{
			void *stuff;
			widg = wind->widgets + wd;
			stuff = widg->stuff;
			memset(widg, 0, sizeof(XA_WIDGET));
			wind->widgets[wd].type = wd;
			widg->stuff = stuff;
		}
	othw
		memset(wind->widgets, 0, sizeof(XA_WIDGET)*XA_MAX_WIDGETS);
	
		for (wd = 0; wd < XA_MAX_WIDGETS; wd++)
			wind->widgets[wd].type = wd;
	}

	if (tp & CLOSE)
	{
		widg = wind->widgets + XAW_CLOSE;
		widg->mask = CLOSE;
		widg->behaviour[XACB_DISPLAY] = display_def_widget;
		widg->behaviour[XACB_CLICK  ] = click_close;
		widg->loc = stdl_close;
		widg->rsc_index = WIDG_CLOSER;
		wind->widgets_on_top++;
	}
	if (tp & FULLER)
	{
		widg = wind->widgets + XAW_FULL;
		widg->mask = FULLER;
		widg->behaviour[XACB_DISPLAY] = display_def_widget;
		widg->behaviour[XACB_CLICK  ] = click_full;
		widg->loc = stdl_full;
		widg->rsc_index = WIDG_FULL;
		wind->widgets_on_top++;
	}
	if (tp & SMALLER)
	{
		widg = wind->widgets + XAW_ICONIFY;
		widg->mask = SMALLER;
		widg->behaviour[XACB_DISPLAY] = display_def_widget;
		widg->behaviour[XACB_CLICK  ] = click_iconify;
		widg->loc = stdl_iconify;
		widg->rsc_index = WIDG_ICONIFY;
		if (tp & FULLER)
			widg->loc.r.x += wind->widgets[XAW_FULL].loc.r.w;
		wind->widgets_on_top++;
	}
	if (tp & SIZER)
	{
		widg = wind->widgets + XAW_RESIZE;
		widg->mask = SIZER;
		widg->behaviour[XACB_DISPLAY] = display_def_widget;
		widg->behaviour[XACB_DRAG] = drag_resize;
		widg->loc = stdl_resize;
		widg->rsc_index = WIDG_SIZE;
	}
	if (tp & UPARROW)
	{
		widg = wind->widgets + XAW_UPLN;
		widg->mask = UPARROW;
		widg->behaviour[XACB_DISPLAY] = display_def_widget;
		widg->behaviour[XACB_CLICK] = click_scroll;
		widg->behaviour[XACB_DRAG] = click_scroll;
		widg->loc = stdl_uscroll;
		widg->rsc_index = WIDG_UP;
		widg->arrowx = WA_UPLINE;
		widg->slider_type = XAW_VSLIDE;
		if (tp & VSLIDE)
		{
			widg = wind->widgets + XAW_UPPAGE;
			widg->mask = UPARROW;
			widg->behaviour[XACB_DISPLAY] = display_arrow;
			widg->behaviour[XACB_CLICK] = click_scroll;
			widg->behaviour[XACB_DRAG] = click_scroll;
			widg->loc = stdl_vslide;
			widg->arrowx = WA_UPPAGE;
			widg->slider_type = XAW_VSLIDE;
		}
	}
	if (tp & DNARROW)
	{
		widg = wind->widgets + XAW_DNLN;
		widg->mask = DNARROW;
		widg->behaviour[XACB_DISPLAY] = display_def_widget;
		widg->behaviour[XACB_CLICK] = click_scroll;
		widg->behaviour[XACB_DRAG] = click_scroll;
		widg->loc = stdl_dscroll;
		if ( ! (tp & SIZER) and !bottom)			/* HR */
			widg->loc.r.y -= ICON_H;
		else if (bottom)
			widg->loc.r.y += WASP;
		widg->rsc_index = WIDG_DOWN;
		widg->arrowx = WA_DNLINE;
		widg->limit = 1000;
		widg->slider_type = XAW_VSLIDE;
		if (tp & VSLIDE)
		{
			widg = wind->widgets + XAW_DNPAGE;
			widg->mask = DNARROW;
			widg->behaviour[XACB_DISPLAY] = display_arrow;
			widg->behaviour[XACB_CLICK] = click_scroll;
			widg->behaviour[XACB_DRAG] = click_scroll;
			widg->loc = stdl_dscroll;
			widg->arrowx = WA_DNPAGE;
			widg->limit = 1000;
			widg->slider_type = XAW_VSLIDE;
		}
	}
	if (tp & LFARROW)
	{
		widg = wind->widgets + XAW_LFLN;
		widg->mask = LFARROW;
		widg->behaviour[XACB_DISPLAY] = display_def_widget;
		widg->behaviour[XACB_CLICK] = click_scroll;
		widg->behaviour[XACB_DRAG] = click_scroll;
		widg->loc = stdl_lscroll;
		widg->rsc_index = WIDG_LEFT;
		widg->arrowx = WA_LFLINE;
		widg->slider_type = XAW_HSLIDE;
		if (tp & HSLIDE)
		{
			widg = wind->widgets + XAW_LFPAGE;
			widg->mask = LFARROW;
			widg->behaviour[XACB_DISPLAY] = display_arrow;
			widg->behaviour[XACB_CLICK] = click_scroll;
			widg->behaviour[XACB_DRAG] = click_scroll;
			widg->loc = stdl_hslide;
			widg->arrowx = WA_LFPAGE;
			widg->slider_type = XAW_HSLIDE;
		}
	}
	if (tp & RTARROW)
	{
		widg = wind->widgets + XAW_RTLN;
		widg->mask = RTARROW;
		widg->behaviour[XACB_DISPLAY] = display_def_widget;
		widg->behaviour[XACB_CLICK] = click_scroll;
		widg->behaviour[XACB_DRAG] = click_scroll;
		widg->loc = stdl_rscroll;
		if ( ! (tp & SIZER) and !right)				/* HR */
			widg->loc.r.x -= ICON_H;
		else if (right)
			widg->loc.r.x += WASP;
		widg->rsc_index = WIDG_RIGHT;
		widg->arrowx = WA_RTLINE;
		widg->limit = 1000;
		widg->slider_type = XAW_HSLIDE;
		if (tp & HSLIDE)
		{
			widg = wind->widgets + XAW_RTPAGE;
			widg->mask = RTARROW;
			widg->behaviour[XACB_DISPLAY] = display_arrow;
			widg->behaviour[XACB_CLICK] = click_scroll;
			widg->behaviour[XACB_DRAG] = click_scroll;
			widg->loc = stdl_rscroll;
			widg->arrowx = WA_RTPAGE;
			widg->limit = 1000;
			widg->slider_type = XAW_HSLIDE;
		}
	}
	if (tp & VSLIDE)
	{
		XA_SLIDER_WIDGET *sl = xcalloc(1,sizeof(XA_SLIDER_WIDGET),100);
		widg = wind->widgets + XAW_VSLIDE;
		widg->mask = VSLIDE;
		widg->behaviour[XACB_DISPLAY] =display_vslide;
/* sliders have no click behaviour */
		widg->behaviour[XACB_DRAG] = drag_vslide;
		widg->loc = stdl_vslide;
		widg->stuff = sl;
		sl->position = 0;
		sl->length = 1000;
	}
	if (tp & HSLIDE)
	{
		XA_SLIDER_WIDGET *sl = xcalloc(1,sizeof(XA_SLIDER_WIDGET),101);
		widg = wind->widgets + XAW_HSLIDE;
		widg->mask = HSLIDE;
		widg->behaviour[XACB_DISPLAY] = display_hslide;
/* sliders have no click behaviour */
		widg->behaviour[XACB_DRAG] = drag_hslide;
		widg->loc = stdl_hslide;
		widg->stuff = sl;
		sl->position = 0;
		sl->length = 1000;
	}

	if (tp & XaPOP)		/* HR: popups in a window */
	{
		XA_WIDGET_LOCATION loc = {LT, 0, 0, 0, 0};

		widg = wind->widgets + XAW_MENU;
		widg->mask = XaPOP;
		widg->loc = loc;
	}

	if (tp & XaMENU)
	{
		widg = wind->widgets + XAW_MENU;
		widg->mask = XaMENU;
		widg->loc = stdl_menu;
		/* Remainder of widg is provided by set_menu_widget() */		
		
		if (tp & (NAME|CLOSE|FULLER|SMALLER))
		{
			if (screen.c_max_h + 4 > ICON_H + 2)
				widg->loc.r.y += screen.c_max_h + 1;
			else
				widg->loc.r.y += ICON_H + 1;
		}
		if (tp & INFO)
		{
			if (screen.c_max_h + 4 > ICON_H + 2)
				widg->loc.r.y += screen.c_max_h + 1;
			else
				widg->loc.r.y += ICON_H + 1;
		}

		shift_from_top(wind, widg, tp & (~(XaMENU|INFO|NAME|CLOSE|FULLER|SMALLER)), 3);
	}

	if (tp & INFO)
	{
		widg = wind->widgets + XAW_INFO;
		widg->mask = INFO;
		widg->behaviour[XACB_DISPLAY] = display_info;
		widg->loc = stdl_info;
		widg->loc.r.h = screen.c_max_h;
		widg->stuff = "Info Bar";	/* Give the window a default info line until the client changes it */
		
		if (tp & (NAME|CLOSE|FULLER|SMALLER))
		{
			if (screen.c_max_h + 4 > ICON_H + 2)
				widg->loc.r.y += screen.c_max_h + 1;
			else
				widg->loc.r.y += ICON_H + 1;
		}

		shift_from_top(wind, widg, tp & (~(XaMENU|INFO|NAME|CLOSE|FULLER|SMALLER)), 2);
	}

	widg = wind->widgets + XAW_TITLE;
	widg->loc = stdl_title;
	widg->loc.r.h = screen.c_max_h;

	if (tp & NAME)
	{
		widg->mask = NAME;
		widg->behaviour[XACB_DISPLAY] = display_title;
		widg->behaviour[XACB_CLICK] = click_title;
		widg->behaviour[XACB_DCLICK] = dclick_title;
		widg->behaviour[XACB_DRAG] = drag_title;
		if (widg->stuff == nil)				/* HR */
			widg->stuff = "XaAES Window";	/* Give the window a default title if not already set */

		if (tp&CLOSER)
			widg->loc.r.x += ICON_W + 1;
			
		shift_from_top(wind, widg, tp & (~(XaMENU|INFO|NAME|CLOSE|FULLER|SMALLER)), (tp & INFO) ? 0 : 2);
	}

	if ((tp&VSLIDE) and !(tp&UPARROW))
	{
		wind->widgets[XAW_UPPAGE].loc.r.y -= ICON_H;
		wind->widgets[XAW_VSLIDE].loc.r.y -= ICON_H;
	}
	if ((tp&HSLIDE) and !(tp&LFARROW))
	{
		wind->widgets[XAW_LFPAGE].loc.r.x -= ICON_W;
		wind->widgets[XAW_HSLIDE].loc.r.x -= ICON_W;
	}
}

/*
 * Attach a toolbar to a window...probably let this be accessed via wind_set one day
 */
global
XA_TREE *set_toolbar_widget(LOCK lock, XA_WINDOW *wind, OBJECT *form, short item)		/* HR: item */
{
	XA_TREE *nt = xcalloc(1,sizeof(XA_TREE),8);
	XA_WIDGET *widg = &wind->widgets[XAW_TOOLBAR];
	XA_WIDGET_LOCATION loc;

#if GENERATE_DIAGS
	if (!nt)
	{
		DIAG((D.widg,-1,"set_toolbar_widget - unable to allocate widget.\n"));
	}
#endif

	nt->tree = form;
	nt->pid = C.AESpid;

	/*
	 * If there is an editable field, we'll need a keypress handler.
	 *  HR: We need a keypress handler for the default object as well
	 */
	if (item <= 0)
		item = find_flag(form, EDITABLE);
	if (has_default(form) or item >= 0)
		wind->keypress = handle_form_key;

	nt->edit_obj = item;
	
	if (item >= 0)
	{
		TEDINFO *ted = get_ob_spec(&form[item])->tedinfo;
		if (*(ted->te_ptext) eq '@')				/* HR 101200 */
			*(ted->te_ptext) =  0;
		wind->keypress = handle_form_key;
		nt->edit_pos = strlen(ted->te_ptext);
	}

	loc.relative_type = LT;
	loc.r.x = wind->wa.x - wind->r.x - wind->frame;
	loc.r.y = wind->wa.y - wind->r.y - wind->frame;
	loc.r.w = form->r.w;
	loc.r.h = form->r.h;

 	widg->behaviour[XACB_DISPLAY] = display_object_widget;
	widg->behaviour[XACB_CLICK] = click_object_widget;
	widg->behaviour[XACB_DCLICK] = dclick_object_widget;
	widg->behaviour[XACB_DRAG] = click_object_widget;
	widg->loc = loc;
	widg->state = NONE;
	widg->stuff = nt;
	widg->start = 0;
	return nt;
}

/* HR 120201 & 100701 */
void remove_widget(LOCK lock, XA_WINDOW *wind, short tool)
{
	XA_WIDGET *widg = &wind->widgets[tool];
	XA_TREE *wt = widg->stuff;
DIAG((D.form,-1,"remove_widget %d: %ld\n", tool, wt));
	if (wt)
	{
		if (wt->extra)					/* HR 210501 */
			free(wt->extra);
		free(wt);
	}
	wind->keypress = nil;

	widg->stuff = nil;
 	widg->behaviour[XACB_DISPLAY] = nil;
	widg->behaviour[XACB_CLICK] = nil;
	widg->behaviour[XACB_DCLICK] = nil;
	widg->behaviour[XACB_DRAG] = nil;
}

static
bool is_page(short f)
{
	switch (f)
	{
	case XAW_LFPAGE:
	case XAW_RTPAGE:
	case XAW_UPPAGE:
	case XAW_DNPAGE:
		return true;
	} 
	return false;
}

/* The mouse is inside the large slider bar */
static
short is_H_arrow(XA_WINDOW *w, XA_WIDGET *widg, short click)
{
	XA_SLIDER_WIDGET *sl = widg->stuff;			/* but are we in the slider itself, the slidable one :-) */

	if (click > sl->r.x and click < sl->r.x + sl->r.w)
		return 0;

	if (w->active_widgets&LFARROW)			/* outside slider, arrows must be defined */
	{										/* outside has 2 sides :-) */
		if (sl->position > 0    and click < sl->r.x)				/* up arrow */
			return 1;						/* add to slider index */
		if (sl->position < 1000 and click > sl->r.x + sl->r.w)	/* dn arrow */
			return 2;
	}

	return -1;		/* no active widget, skip */
}

/* same as above, but for vertical slider */
static
short is_V_arrow(XA_WINDOW *w, XA_WIDGET *widg, short click)
{
	XA_SLIDER_WIDGET *sl = widg->stuff;

	if (click > sl->r.y and click < sl->r.y + sl->r.h)
		return 0;

 	if (w->active_widgets&UPARROW)
	{
		if (sl->position > 0    and click < sl->r.y)	
			return 1;
		if (sl->position < 1000 and click > sl->r.y + sl->r.h)
			return 2;
	}

	return -1;
}

/*
 * Process widget clicks, and call the appropriate handler routines
 * This is the main routine for handling window interaction from a users perspective.
 * Each widget has a set of behaviours (display, drag, click, etc) for each of it's widgets.
 * - these can be changed on an individual basis, so the close widget of one window might
 *   call a that sends a 'go back up a directory' message to the desktop, where-as on another
 *   it may just take the GEM default and send a WM_CLOSED message to the application.
 * NOTE: If a widget has no XACB_DISPLAY behaviour, it isnt there.   HR 060601
 */
 
/* HR!!! This is NOT called when widget_active is handled in pending_msg()!!!
            that is making the stuff so weird.
         It is all about the sliders in the list boxes, who are not sending messages to a app,
         but call a XaAES internal routine.
   The problems arose when I removed the active_widget pointers out of the client and window
   structures and made it global.
   Another reason to have the active_widget handling in the kernel. */

global
short do_widgets(LOCK lock, XA_WINDOW *w, MOOSE_DATA *md)		/* HR */
{
	XA_WIDGET *widg;
	WidgetBehaviour *disp;
	short f, clicks;

	clicks = md->clicks;
	if (clicks > 2)
		clicks = 2;

	/* Scan through widgets to find the one we clicked on */
	for (f = 0; f < XA_MAX_WIDGETS; f++)
	{
		RECT r;

/* HR 060501: just skip page arrows. These are embedded in the slider background together with the slider itself. */
		while (is_page(f))
			f++;

		widg = w->widgets + f;
		disp = widg->behaviour[XACB_DISPLAY];		/* Get the redraw function for this widget */

		if (disp)								/* Is the widget in use */
		{
			rp_2_ap(w, widg, &r);				/* Convert relative coords and window location to absolute screen location */

			if (m_inside(md->x, md->y, &r))
			{
				bool rtn = false;
				short ax = 0;

				widg->click_x = md->x - r.x; 			/* Mark where the click occurred (relative to the widget) */
				widg->click_y = md->y - r.y;
/* In this version page arrows are separate widgets,
	they are overlapped by the slider widget, hence this kind of a hack.
	The real solution would be nested widgets and recursive handling. */

				if (f eq XAW_VSLIDE)
					ax = is_V_arrow(w,widg,md->y);
				else
				if (f eq XAW_HSLIDE)
					ax = is_H_arrow(w,widg,md->x);

				if (ax < 0)
					return true;	/* inside a page arrow, but not active */

				if (ax)
				{
					widg = w->widgets + f + ax;
					rtn = (*widg->behaviour[XACB_DRAG])(lock, w, widg);		/* we know there is only 1 behaviour for these arrows */
				}
				else /* normal widget */
				{
					WidgetBehaviour *wdrag;
					short b, rx, ry;

					/* We don't auto select & pre-display for a menu or toolbar widget */
					if (f != XAW_MENU and f != XAW_TOOLBAR)
						redisplay_widget(lock, w, widg, SELECTED);

					wdrag = widg->behaviour[XACB_DRAG];	/* Get the click-drag function for this widget */
	
					vq_mouse(C.vh, &b, &rx, &ry);
					if ((b) and (wdrag)) 	/* If the mouse button is still down do a drag (if the widget has a drag behaviour) */
						rtn = (*wdrag)(lock, w, widg);
					else					/*  otherwise, process as a mouse click(s) */
					{
						while (b)				/* Wait for the mouse to be released */
							vq_mouse(C.vh, &b, &rx, &ry);
					
						if (m_inside(rx, ry, &r))
						{
							WidgetBehaviour *wc = widg->behaviour[clicks];
							if (wc)				/* If the widget has a click behaviour, call it */
								rtn = (*wc)(lock, w, widg);
							else
								rtn = true;
						}
						else
							rtn = true;		/* HR 060601: released outside widget: reset its state. */
						if (w->winob)		/* HR 060601: a little bit of hack, until checking widget_active
						                                  is moved from pending_msg() to the kernel. */
							cancel_widget_active(w, 5);
					}
				}

				if (rtn)	/* If the widget click/drag function returned true we reset the state of the widget */
				{
					DIAG((D.mouse,-1,"Deselect widget\n"));
					redisplay_widget(lock, w, widg, NONE);	/* Flag the widget as de-selected */
				}

				return true;			/* click devoured by widget */
			}						/*if m)inside */
		}						/* if there */
	}						/* for f */

	return false;				/* Button click can be passed on to applications as we didn't use it for a widget */
}

global
void redisplay_widget(LOCK lock, XA_WINDOW *wind, XA_WIDGET *widg, short state)
{
	XA_RECT_LIST *rl;
	WidgetBehaviour *disp = widg->behaviour[XACB_DISPLAY];

	widg->state = state;

	if (wind->winob)
	{
		hidem();
		(*disp)(lock, wind, widg);		/* Not on top, but visible */
		showm();
	}
	else
		display_widget(lock, wind, widg);	/* Display the selected widget */
}

global
void do_active_widget(LOCK lock, XA_CLIENT *client)			/* HR 230601 */
{
	if (widget_active.widg)
		if (widget_active.wind->owner == client)		/* HR 060801 ;-) */
		{
			short rtn;
			XA_WINDOW *wind = widget_active.wind;
			XA_WIDGET *widg = widget_active.widg;
			DIAG((D.mouse,-1,"pending_msgs: do pending action\n"));
			rtn = (*widget_active.action)(lock, wind, widg);	/* Call the pending action */
	
			if (rtn)	/* If the widget click/drag function returned true we reset the state of the widget */
			{
	/* HR: 050601: if the pending widget is canceled, its state is undefined!!!!!! */
				DIAG((D.mouse,-1,"Deselect pending widget\n"));
				redisplay_widget(lock, wind, widg, NONE); /* Flag the widget as de-selected */
			}
		}
}
