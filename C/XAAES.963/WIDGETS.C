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

#include "xa_types.h"
#include "xa_globl.h"

#include "xalloc.h"
#include "widgets.h"
#include "c_window.h"
#include "rectlist.h"
#include WIDGHNAME
#include "objects.h"
#include "xa_graf.h"
#include "xa_form.h"
#include "widgets.h"
#include "menuwidg.h"
#include "xa_rsrc.h"
#include "app_man.h"

static
OBJECT *def_widgets;

/*
 *	WINDOW WIDGET SET HANDLING ROUTINES
 *	This module handles the behaviour of the window widgets.
 */

global
int pix_to_sl(long p, int s)
{
	return (p * SL_RANGE) / s;
}

global
int sl_to_pix(long s, int p)
{
	return (s * p) / SL_RANGE;
}

global
void XA_slider(XA_WINDOW *w, int which, int total, int visible, int start)
{
	XA_WIDGET *widg = get_widget(w, which);

	if (w->active_widgets & widg->loc.mask)
	{
		XA_SLIDER_WIDGET *sl = widg->stuff;

		if (visible < total)
			sl->length = pix_to_sl(visible, total);
		else
			sl->length = SL_RANGE;
	
		if (total - visible < 0 or start == 0)
			sl->position = 0;
		else
			if (start + visible >= total)
				sl->position = SL_RANGE;
			else
				sl->position = pix_to_sl(start, total - visible);
	}
}

static
void fix_widg(OBJECT *widg)
{
	widg->r.x = 0;
	widg->r.y = 0;
}

/* Standard Widget Set from widget resource file */
global
void fix_default_widgets(void *rsc)
{
	int i;	
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

#ifndef get_widget
global
XA_WIDGET *get_widget(XA_WINDOW *wind, int n)
{
	return &wind->widgets[n];
}
#endif

global
bool m_inside(G_i x, G_i y, RECT *o)
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
void set_widget_active(XA_WINDOW *wind, XA_WIDGET *widg, WidgetBehaviour *wc, int i)
{
	widget_active.wind = wind;
	widget_active.widg = widg;
	widget_active.action = wc;
/*	widget_active.cont =true; */
}

/*
 * Cancel the active/pending widget for a client
 */
static
void cancel_widget_active(XA_WINDOW *wind, int i)
{
	widget_active.widg = nil;
	widget_active.cont = false;
/* HR 160102 */
/* Restore the mouse now we've finished the action */
	graf_mouse(wind->owner->mouse, wind->owner->mouse_form);
}


/* check slider value */
global
int bound_sl(int p)
{
	return p < 0 ? 0 : (p > SL_RANGE ? SL_RANGE : p);
}

/*
 * Convert window relative widget coords to absolute screen coords
 */
global
void *rp_2_ap(XA_WINDOW *wind, XA_WIDGET *widg, RECT *r)		/* HR use a RECT */
{
	RECT dr;
	G_i rtx, rty, ww, wh;
	int frame = wind->frame;

	if (frame < 0)				/* HR 151101 */
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

		if (wind != root_window)		/* HR 280801 */
		{
			form->r.x = r->x;
			form->r.y = r->y;
		}
		return form;		/* If want to get informed */
	}

	return nil;
}

global
void display_widget(LOCK lock, XA_WINDOW *wind, XA_WIDGET *widg)
{
	if (widg->display)			/* HR 100701: if removed or lost */
	{
/* HR 260501: Some programs do this! */
		if (!(   wind->window_status == XAWS_ICONIFIED
			  and widg->type != XAW_TITLE
			  and widg->type != XAW_ICONIFY
		   ) )
		{
			XA_RECT_LIST *rl;

			IFWL(Sema_Up(winlist);)
			hidem();
			rl = rect_get_system_first(wind);
			while (rl)
			{		/* Walk the rectangle list */
				set_clip(&rl->r);
				widg->display(lock|winlist, wind, widg);
				rl = rect_get_system_next(wind);
			}
			clear_clip();
			showm();
			IFWL(Sema_Dn(winlist);)
		}
	}
}

global
void redraw_menu(LOCK lock)
{
	display_widget(lock, root_window, get_widget(root_window, XAW_MENU) );
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
	XA_WIDGET *widg;
	XA_WIND_ATTR k = wi->active_widgets;
	int   thin = wi->thinwork,
	      frame = wi->frame,
	      bottom = 0, right = 0,
	      tl_margin, br_margin, wa_margins,
	      winside /* , hinside */;

	wi->wa = r;

	if ((k&V_WIDG) == 0)
	{
		wi->ba = r;
		if (frame >= 0)
		{
			wi->wa.x += 1;
			wi->wa.y += 1;
			wi->wa.w -= 2 + SHADOW_OFFSET;
			wi->wa.h -= 2 + SHADOW_OFFSET;
		}
	othw
	/* a colour work area frame is larger to allow for the fancy borders :-)
	        unless thinwork has been specified
	   a color work area frame consists of a grey, a light and a dark line.   */
	
		tl_margin = (MONO or thin) ? 1 : 2;	/* in color aligning is on the top & left light line of tha wa */
		br_margin = (MONO or thin) ? 1 : 3;	/* The visual thing :-) */
		wa_margins = tl_margin + br_margin;
	
	/* This is the largest work area possible */
		if (frame >= 0)
		{
			wi->wa.x +=   frame + tl_margin;
			wi->wa.y +=   frame + tl_margin;
			wi->wa.w -= 2*frame + wa_margins + SHADOW_OFFSET;
			wi->wa.h -= 2*frame + wa_margins + SHADOW_OFFSET;
		}

		wi->ba = wi->wa;	/* HR 280102: For use by border sizing. */

		winside = wi->wa.w + wa_margins;
	/*	hinside = wi->wa.h + wa_margins; */
	
		if (k & (CLOSE|NAME|MOVE|ICONIFY|FULL))	/* top bar */
			wi->wa.y+= cfg.widg_h + 2,
			wi->wa.h-= cfg.widg_h + 2;
		
		rt = &get_widget(wi, XAW_TITLE)->loc.r;
		rt->w = winside;
		if (k & CLOSE)
			rt->w -= cfg.widg_w+1;				/* + space between name and closer */
											/*   name has a inside border */
		if (k & (ICONIFY|FULL|HIDE))
		{
			rt->w -=  MONO ? 1 : 2;	/* Due to pushbutton behaviour in color, in mono its a rectangle. */
			if (k & FULL)
				rt->w -= cfg.widg_w;
			if (k & ICONIFY)
				rt->w -= cfg.widg_w;
			if (k & HIDE)
				rt->w -= cfg.widg_w;
		}

		if (wi->window_status != XAWS_ICONIFIED)
		{
			if (k & INFO)							/* fatter topbar */
				wi->wa.y+= cfg.widg_h,
				wi->wa.h-= cfg.widg_h;
			if (k & XaMENU)							/* HR: menu is a standard widget! */
				wi->wa.y+= MENU_H + 1,				/*     Now I can specify the desktop window w/o dummy name. :-) */
				wi->wa.h-= MENU_H + 1;				/*     the +1 is for the menu_line */
	
			if (k & (UPARROW|DNARROW|VSLIDE))		/* right bar */
				right = 1;
			if (k & (LFARROW|RTARROW|HSLIDE))		/* bottom bar */
				wi->wa.h-= cfg.widg_h+WASP,				/* + spacer */
				bottom = 1;
	
			if (right or ((k&SIZE) and !(right or bottom)))	/* sizer only retain right bar */
				wi->wa.w-= cfg.widg_w+WASP;				/* + spacer */
	
			if (k & INFO)							/* Update info bar */
				get_widget(wi, XAW_INFO)->loc.r.w = winside;	/* full width inside standard borders */
			if (k & XaMENU)
				get_widget(wi, XAW_MENU)->loc.r.w = winside;	

		/* Sliders are completely oriented on the work area */
			if (k & HSLIDE)							/* Update horizontal slider */
			{
				widg = get_widget(wi, XAW_HSLIDE);
				sl = widg->stuff;
				sl->r.w = 0;						/* initializes slider draw */
	
				rt = &widg->loc.r;
				rt->w = wi->wa.w + wa_margins;
				if (k & LFARROW)					/* includes RTARROW */
					rt->w -= 2*cfg.widg_w;
				if ((k & SIZE) and !right)
					rt->w -= cfg.widg_h;
			}
			if (k & VSLIDE)							/* Update vertical slider */
			{
				widg = get_widget(wi, XAW_VSLIDE);
				sl = widg->stuff;
				sl->r.h = 0;						/* initializes slider draw */

				rt = &widg->loc.r;
				rt->h = wi->wa.h + wa_margins;
				if (k & DNARROW)					/* includes UPARROW */
					rt->h -= 2*cfg.widg_h;
				if ((k & SIZE) and !bottom)
					rt->h -= cfg.widg_h;
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
	DIAG((D_widg,wi->owner,"workarea %d: %d/%d,%d/%d\n", wi->handle, wi->wa));
}

/*
 * Define the widget locations using window relative coordinates.
 */

/* HR: needed a dynamic margin (for windowed list boxes) */
/* eliminated both margin and shadow sizes from this table */
/* HR 260901: put some extra data there as well. */
static
XA_WIDGET_LOCATION
/* HR better spacing    defaults     index        mask     rsc         */
	stdl_close   = {LT, 0, 0, 1, 1,  XAW_CLOSE,   CLOSE,   WIDG_CLOSER  },
	stdl_full    = {RT, 0, 0, 1, 1,  XAW_FULL,    FULL,    WIDG_FULL    },
	stdl_iconify = {RT, 0, 0, 1, 1,  XAW_ICONIFY, ICONIFY, WIDG_ICONIFY },
	stdl_hide    = {RT, 0, 0, 1, 1,  XAW_HIDE,    HIDER,   WIDG_HIDE    },
	stdl_title   = {LT, 0, 0, 1, 1,  XAW_TITLE,   NAME,    0            },
	stdl_notitle = {LT, 0, 0, 1, 1,  XAW_TITLE,   0,       0            },
	stdl_resize  = {RB, 0, 0, 1, 1,  XAW_RESIZE,  SIZE,    WIDG_SIZE    },
	stdl_uscroll = {RT, 0, 0, 1, 1,  XAW_UPLN,    UPARROW, WIDG_UP      },
	stdl_upage   = {RT, 0, 1, 1, 1,  XAW_UPPAGE,  UPARROW, 0},
	stdl_vslide  = {RT, 0, 1, 1, 1,  XAW_VSLIDE,  VSLIDE,  0},
	stdl_dpage   = {RT, 0, 1, 1, 1,  XAW_DNPAGE,  DNARROW, 0},
	stdl_dscroll = {RB, 0, 1, 1, 1,  XAW_DNLN,    DNARROW, WIDG_DOWN    },
	stdl_lscroll = {LB, 0, 0, 1, 1,  XAW_LFLN,    LFARROW, WIDG_LEFT    },
	stdl_lpage   = {LB, 1, 0, 1, 1,  XAW_LFPAGE,  LFARROW, 0},
	stdl_hslide  = {LB, 1, 0, 1, 1,  XAW_HSLIDE,  HSLIDE,  0},
	stdl_rpage   = {LB, 1, 0, 1, 1,  XAW_RTPAGE,  RTARROW, 0},
	stdl_rscroll = {RB, 1, 0, 1, 1,  XAW_RTLN,    RTARROW, WIDG_RIGHT   },
	stdl_info    = {LT, 0, 0, 1, 1,  XAW_INFO,    INFO,    0},
	stdl_menu    = {LT, 0, 0, 0, 0,  XAW_MENU,    XaMENU,  0},
	stdl_pop     = {LT, 0, 0, 0, 0,  XAW_MENU,    XaPOP,   0},
	stdl_border  = {0,  0, 0, 0, 0,  XAW_BORDER,  0,       0}	/* HR 280102: implement border sizing. */
	;


static
XA_WIDGET *make_widget(XA_WINDOW *wind, XA_WIDGET_LOCATION *loc,
	WidgetBehaviour *display, WidgetBehaviour *click, WidgetBehaviour *drag)
{
	XA_WIDGET *widg = get_widget(wind, loc->n);
	widg->display = display;
	widg->click   = click;
	widg->drag    = drag;
	widg->loc     = *loc;
	widg->loc.r.x *= cfg.widg_w;
	widg->loc.r.y *= cfg.widg_h;
	widg->loc.r.w *= cfg.widg_w;
	widg->loc.r.h *= cfg.widg_h;
	if (widg->loc.rsc_index and (cfg.widg_dw or cfg.widg_dh))
		switch(widg->loc.relative_type)
		{
		case LT:
			widg->loc.r.x -= cfg.widg_dw;
			widg->loc.r.y -= cfg.widg_dh;
			break;
		case RT:
			widg->loc.r.x += cfg.widg_dw;
			widg->loc.r.y -= cfg.widg_dh;
			break;
		case LB:
			widg->loc.r.x -= cfg.widg_dw;
			widg->loc.r.y += cfg.widg_dh;
			break;
		case RB:
			widg->loc.r.x += cfg.widg_dw;
			widg->loc.r.y += cfg.widg_dh;
			break;
		}

	return widg;
}

/* HR: Establish iconified window position from a simple ordinal. */
global
RECT iconify_grid(int i)
{
	RECT ic = {0,0,ICONIFIED_W,ICONIFIED_H};
	int j, w = screen.r.w/ic.w;

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
	RECT r; int i = widg->loc.rsc_index;

	rp_2_ap(wind, widg, &r);

	if (widg->state & SELECTED)
		def_widgets[i].ob_state |= SELECTED;
	else
		def_widgets[i].ob_state &= ~SELECTED;

/*
DIAG((D_widg, wind->owner, "display_def_widget %d: state %d, global clip: %d:%d,%d:%d r: %d:%d/%d:%d\n",
				wind->handle, (widg->state & SELECTED) != 0,
				C.global_clip[0],C.global_clip[1],C.global_clip[2],C.global_clip[3],
				r.x,r.y,r.x+r.w-1,r.y+r.h-1
				));
*/
	display_object(lock, &wind->widg_info, i, r.x, r.y, 0);

	return true;
}

/*======================================================
	TITLE WIDGET BEHAVIOUR
========================================================*/
static
WidgetBehaviour display_title	/* (LOCK lock, XA_WINDOW *wind, XA_WIDGET *widg) */
{
	OPT *o = &wind->owner->options;
	char temp[256],
	     tn[256];
	RECT r;
	int effect = 0;			/* HR 220801 */
	bool dial = (wind->dial&(created_for_FORM_DO|created_for_FMD_START)) != 0;

	rp_2_ap(wind, widg, &r);			/* Convert relative coords and window location to absolute screen location */

	wr_mode(MD_TRANS);

#if DISPLAY_LOGO_IN_TITLE_BAR				/* HR: It ressembles too much a closer */
	if (widg->stat & SELECTED)
		def_widgets[WIDG_LOGO].ob_state |= SELECTED;
	else
		def_widgets[WIDG_LOGO].ob_state &= ~SELECTED;

	wind->wt.tree = def_widgets;
	display_object(lock, wind->wt, WIDG_LOGO, r.x, r.y, 1);

/* HR: tiny pixel correction (better spacing) */
	r.x += cfg.widg_w + 2;
	r.w -= cfg.widg_w + 2;
#endif

	if MONO
	{
		f_color(WHITE);
		t_color(BLACK);

		if (wind == window_list and wind == C.focus)	/* HR */
			effect = cfg.topname;			/* Highlight the title bar of the top window */
		else
			effect = cfg.backname;

		p_gbar(0, &r);								/* with inside border */
	} else
	{
		if (wind == window_list and wind == C.focus)	/* HR */
			t_color(BLACK);				/* Highlight the title bar of the top window */
		else
			t_color(WHITE);

		if (wind->active_widgets & MOVE)		/* HR 231002: no move, no 3D */
			d3_pushbutton(-2,&r,nil,widg->state,0,0);
		else
		{
			f_color(screen.dial_colours.bg_col);
			l_color(screen.dial_colours.shadow_col);
			p_gbar(0, &r);
		}
	}

	if (o->windowner and wind->owner and !wind->winob and !dial)
	{
		char *ow = nil;
		if (o->windowner == 1)
			ow = wind->owner->proc_name;
		else
		if (o->windowner == 2)
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
			sdisplay(tn, "(%d) %s", wind->owner->pid, widg->stuff);
	}
	else
		strcpy(tn, widg->stuff);

	cramped_name(tn, temp, r.w/screen.c_max_w);

	if (*temp ne ' ')		/* HR 080501: avoid inner border. */
		++r.x;

	if (dial)
		effect |= ITALIC;

	vst_effects(C.vh, effect);
	r.y += (r.h-screen.c_max_h)/2;		/* HR 251201 */
	v_gtext(C.vh, r.x, r.y, temp);
	vst_effects(C.vh, 0);		/* normal */

	return true;
}

/*
 * Click & drag on the title bar - does a move window
 */
static
WidgetBehaviour drag_title	/* (LOCK lock, XA_WINDOW *wind, XA_WIDGET *widg) */
{
	if (wind->active_widgets & MOVE)		/* You can only move a window if its MOVE attribute is set */
	{
		RECT r = wind->r, d;

#if PRESERVE_DIALOG_BGD
		{
			XA_WINDOW *scan_wind;
			IFWL(Sema_Up(winlist);)		/* HR */

			if (wind != window_list)		/* Don't allow windows below a STORE_BACK to move */
				for (scan_wind = wind->prev; scan_wind; scan_wind = scan_wind->prev)
					if (scan_wind->active_widgets & STORE_BACK)
					{
						IFWL(Sema_Dn(winlist);)		/* HR */
						return true;
					}
			IFWL(Sema_Dn(winlist);)
		}
#endif
		if (!widget_active.cont)
		{
			widget_active.cont = true;
			graf_mouse(XACRS_MOVER, nil);		/* Always have a nice consistent MOVER when dragging a box */
		}

		if (   widg->s == 2
		    or wind->send_message == nil		/* If right button is used, do a classic outline drag. */
		    or !wind->owner->options.live
		   )
		{
			RECT bound;
			
			bound.x = wind->owner->options.noleft		/* HR 240901 */
			           ? 0
			           : -root_window->r.w;
			bound.y = root_window->wa.y;
			bound.w = root_window->r.w*3;
			bound.h = root_window->r.h*2;

			drag_box(r, &bound, rect_dist(&r, &d), &r);
			
			if (r.x != wind->r.x or r.y != wind->r.y)
				if (wind->send_message)
					wind->send_message(lock, wind, nil,
								WM_MOVED, 0,.0,  wind->handle,
								r.x, r.y, r.w, r.h);
				else
						/* Just move these windows, they can handle it... */
					move_window(lock, wind, -1, r.x, r.y, r.w, r.h);
	
		} else
		{
			G_i pmx, pmy, mx, my, mb;

			vq_mouse(C.vh, &mb, &pmx, &pmy);  /* need to do this anyhow, for mb */

			if (widget_active.widg)		/* pending widget: take that */
			{
				pmx = widget_active.x;
				pmy = widget_active.y;
				d   = widget_active.d;
			}
			else
				rect_dist(&r, &d);

			if (mb)		/* Drag title */
			{
				vq_mouse(C.vh, &mb, &mx, &my);
				set_widget_active(wind, widg, drag_title,1);
				widget_active.x = mx;
				widget_active.y = my;
				widget_active.d.x = d.x;
				widget_active.d.y = d.y;

				if (mx != pmx or my != pmy)			/* Has the mouse moved? */
					r = move_rectangle(mx, my, r, &d);

				if (wind->owner->options.noleft)
					if (r.x < 0)
						r.x = 0;

				if (r.y < root_window->wa.y)
					r.y = root_window->wa.y;

				if (r.x != wind->r.x or r.y != wind->r.y)
					wind->send_message(lock, wind, nil,
								WM_MOVED, 0, 0, wind->handle,
								r.x, r.y, r.w, r.h);
				else		/* HR 191201: Send a dummy message. */
					wind->send_message(lock, wind, nil, 0, 0, 0, 0, 0, 0, 0, 0);

				return false;	/* We return false here so the widget display status stays selected whilst it repeats */
			}
		}
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
	if (       wind != window_list		/* HR: if not on top or on top and not focus */
		or (   wind == window_list
		    and wind != C.focus
		   )
	   )
		if (wind->send_message)
			wind->send_message(lock, wind, nil,
							WM_TOPPED, 0, 0, wind->handle,
							0, 0, 0, 0);
		else
				/* Just top these windows, they can handle it... */
			top_window(lock, wind, nil);		/* Top the window */
	else	/* If window is already top, then send it to the back */
		if ( ! (   (wind->active_widgets & STORE_BACK) != 0		/* Don't bottom STORE_BACK windows */
		        or (wind->active_widgets & BACKDROP) == 0		/* Don/t bottom NO BACKDROP windows */
		       )
		   )
			if (wind->send_message)
				wind->send_message(lock, wind, nil,
							WM_BOTTOMED, 0, 0, wind->handle,
							0, 0, 0, 0);
			else
				/* Just bottom these windows, they can handle it... */
				bottom_window(lock, wind);
	return true;
}

/*
 * Double click title bar of iconified window - sends a restore message
 */
static
WidgetBehaviour dclick_title	/* (LOCK lock, XA_WINDOW *wind, XA_WIDGET *widg) */
{
	if (wind->send_message == nil)
		return false;
	
	/* If window is iconified - send request to restore it */

	if (wind->window_status == XAWS_ICONIFIED)
		wind->send_message(lock, wind, nil,
					WM_UNICONIFY, 0, 0, wind->handle,
					wind->pr.x, wind->pr.y, wind->pr.w, wind->pr.h);
	
	return true;
}

/*======================================================
	INFO BAR WIDGET BEHAVIOUR
========================================================*/
static
WidgetBehaviour display_info		/* (LOCK lock, XA_WINDOW *wind, XA_WIDGET *widg) */
{
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
	r.y += (r.h-screen.c_max_h)/2;		/* HR 251201 */
	v_gtext(C.vh, r.x + 4, r.y, clipped_name(widg->stuff, t, (r.w/screen.c_max_w)-1));

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
	if (wind->send_message)
	{
		wind->send_message(lock, wind, nil,
					WM_CLOSED, 0, 0, wind->handle,
					0, 0, 0, 0);
		return true; /* Redisplay.... */
	}
	else
	{	/* Just close these windows, they can handle it... */
		close_window (lock, wind);
		delete_window(lock, wind);
		return false;	/* Don't redisplay in the do_widgets() routine as window no longer exists */
	}
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
	via (wind->send_message)(lock, wind, nil,
					WM_FULLED, 0, 0, wind->handle,
					0, 0, 0, 0);
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
	RECT ic;

	if (wind->send_message == nil)
		return false;

	switch(wind->window_status)
	{
	case XAWS_OPEN:			/* Window is open - send request to iconify it */
		IFWL(Sema_Up(winlist);)

		ic = free_icon_pos(lock|winlist);

	/* Could the whole screen be covered by iconified windows? That would be an achievement, wont it? */
		if (ic.y > root_window->wa.y)
			wind->send_message(lock|winlist, wind, nil,
					WM_ICONIFY, 0, 0, wind->handle,
					ic.x, ic.y, ic.w, ic.h);

		IFWL(Sema_Dn(winlist);)
	break;	

	case XAWS_ICONIFIED:	/* Window is already iconified - send request to restore it */
		wind->send_message(lock, wind, nil,
					WM_UNICONIFY, 0, 0, wind->handle,
					wind->ro.x, wind->ro.y, wind->ro.w, wind->ro.h);
		break;
	}
	
	return true; /* Redisplay.... */
}

/* HR 210801 */
/*======================================================
	HIDER WIDGET BEHAVIOUR
========================================================*/
/* Displayed by display_def_widget */

/*
 * click the hider widget
 */
static
WidgetBehaviour click_hide	/* (LOCK lock, XA_WINDOW *wind, XA_WIDGET *widg) */
{
	hide_app(lock, wind->owner);

	return true; /* Redisplay.... (Unselect basically.) */
}

/* HR 150202 helper functions for sizing. */
static
WidgetBehaviour display_border	/* (LOCK lock, XA_WINDOW *wind, XA_WIDGET *widg) */
{
	return true; 	/* Dummy; no draw, no selection status. */
}

static
int border_mouse[CDV] =
{
	XACRS_SE_SIZER,
	XACRS_VERTSIZER,
	XACRS_NE_SIZER,
	XACRS_HORSIZER,
	XACRS_SE_SIZER,
	XACRS_VERTSIZER,
	XACRS_NE_SIZER,
	XACRS_HORSIZER
};

static
COMPASS compass(int d, G_i x, G_i y, RECT r)
{
	r.x += d;
	r.y += d;
	r.w -= d+d;
	r.h -= d+d;

	r.w += r.x - 1;
	r.h += r.y - 1;

	if (x < r.x)
	{
		if (y < r.y)	return NW;
		if (y > r.h)	return SW;
		return W_;
	}
	if (x > r.w)
	{
		if (y < r.y)	return NE;
		if (y > r.h)	return SE;
		return E_;
	}
	if (y < r.y)	return N_;
	return S_;
}

/* HR 150202: make rubber_box omnidirectional
              and use it here for outline sizing. */

static
bool size_window(LOCK lock, XA_WINDOW *wind, XA_WIDGET *widg, bool sizer, WidgetBehaviour next)
{
	COMPASS xy;
	bool move, size;
	RECT r = wind->r, d;
	
	bool use_max = (wind->active_widgets&USE_MAX) != 0;

	if (   widg->s == 2
		or wind->send_message == nil
		or !wind->owner->options.live
	   )
	{
		int xy = sizer ? SE : compass(10, widg->mx, widg->my, r);

		graf_mouse(border_mouse[xy], nil);		/* Always have a nice consistent SIZER when resizing a window */

		rubber_box( xy,
		            r,
					rect_dist(&r, &d),
					6*cfg.widg_w, 4*cfg.widg_h,			/* HR: minimum */
					use_max
					 ? wind->max.w
					 : root_window->wa.w,
					use_max
					 ? wind->max.h
					 : root_window->wa.h,
					&r);

		move = r.x != wind->r.x or r.y != wind->r.y,
		size = r.w != wind->r.w or r.h != wind->r.h;

		if (move or size)
		{
			if (move)
				if (wind->send_message)
					wind->send_message(lock, wind, nil,
								WM_MOVED, 0, 0, wind->handle,
								r.x, r.y, r.w, r.h);
				else
						/* Just move these windows, they can handle it... */
					move_window(lock, wind, -1, r.x, r.y, r.w, r.h);
			if (size)
				wind->send_message(lock, wind, nil,
								WM_SIZED, 0, 0, wind->handle,
								r.x, r.y, r.w, r.h);
		}
	} else
	{
		G_i pmx, pmy, mx, my, mb;
		
		vq_mouse(C.vh, &mb, &pmx, &pmy);  /* need to do this anyhow, for mb */

		if (widget_active.widg)		/* pending widget: take that */
		{
			pmx = widget_active.x;
			pmy = widget_active.y;
			d = widget_active.d;
			xy = widget_active.xy;
		othw
			xy = sizer ? SE : compass(10, pmx, pmy, r);
			rect_dist(&r, &d);
		}
	
		if (mb)		/* Drag border */
		{
			vq_mouse(C.vh, &mb, &mx, &my);
			set_widget_active(wind, widg, next, 6);
	
			widget_active.x = mx;
			widget_active.y = my;
			widget_active.d = d;
			widget_active.xy = xy;
	
			if (!widget_active.cont)
			{
				widget_active.cont = true;
				graf_mouse(border_mouse[xy], nil);		/* Always have a nice consistent SIZER when resizing a window */
			}
		
			
			if (mx != pmx or my != pmy)			/* Has the mouse moved? */
				r = widen_rectangle(xy, mx, my, r, &d);  /* HR 150202: in xa_graf.c */
	
			if (use_max)
			{
				if (r.w > wind->max.w)
					r.w = wind->max.w;
				if (r.h > wind->max.h)
					r.h = wind->max.h;
			}
	
			if (r.w < 6*cfg.widg_w)
				r.w = 6*cfg.widg_w;
			if (r.h < 6*cfg.widg_h)
				r.h = 6*cfg.widg_h;
	
			move = r.x != wind->r.x or r.y != wind->r.y,
			size = r.w != wind->r.w or r.h != wind->r.h;
			
			if (move or size)
			{
				if (move)
					wind->send_message(lock, wind, nil,
								WM_MOVED, 0, 0, wind->handle,
								r.x, r.y, r.w, r.h);
				if (size)
					wind->send_message(lock, wind, nil,
								WM_SIZED, 0, 0, wind->handle,
								r.x, r.y, r.w, r.h);
			}
			else		/* HR 191201: Send a dummy message. */
				wind->send_message(lock, wind, nil, 0, 0, 0, 0, 0, 0, 0, 0);
			return false;	/* We return false here so the widget display status stays selected whilst it repeats */
		}
	}

	cancel_widget_active(wind, 5);
	return true;
}

/*======================================================
	RESIZE WIDGET BEHAVIOUR
========================================================*/
/* Displayed by display_def_widget */

/* HR: use the distance from the mouse to the lower right corner.
	just like WINX & MagiC */
/* HR 150202: make rubber_box omnidirectional. */

static
WidgetBehaviour drag_resize	/* (LOCK lock, XA_WINDOW *wind, XA_WIDGET *widg) */
{
	return size_window(lock, wind, widg, true, drag_resize);
}
static
WidgetBehaviour drag_border	/* (LOCK lock, XA_WINDOW *wind, XA_WIDGET *widg) */
{
	return size_window(lock, wind, widg, false, drag_border);
}


/*
 *	Scroll bar & Slider handlers
 */

#if 1			/* HR: Grand unification */

/*======================================================
	SCROLL WIDGET BEHAVIOUR
========================================================*/
/* Displayed by display_def_widget */

/* HR 181201: use widg->state (right/left click) to determine the direction of the arrow effect.
 *            double click on an arrow sends WM_xSLIDE with the apropriate limit.
 */

static
WidgetBehaviour click_scroll	/* (LOCK lock, XA_WINDOW *wind, XA_WIDGET *widg) */
{
	bool reverse = widg->s == 2;
	G_i mx, my, mb;
	XA_WIDGET *slider = &wind->widgets[widg->slider_type];

	if (!(   widget_active.widg
		  and slider
		  and slider->stuff
		  and ((XA_SLIDER_WIDGET *)slider->stuff)->position == (reverse ? widg->xlimit : widg->limit)
		 )
	   )
	{
		if (widg->clicks > 1)
		{
			wind->send_message(lock, wind, nil,
							widg->slider_type == XAW_VSLIDE ? WM_VSLID : WM_HSLID, 
							   0, 0, wind->handle,
							widg->limit, 0, 0, 0);
		othw		
			wind->send_message(lock, wind, nil,
					WM_ARROWED, 0, 0, wind->handle,
					reverse ? widg->xarrow : widg->arrowx, 0, 0, 0);
			vq_mouse(C.vh, &mb, &mx, &my);
	
			if (mb)	/* If the button has been held down, set a pending/active widget for the client */
			{
				set_widget_active(wind, widg, widg->drag, 2);		/* function itself */
				return false;	/* We return false here so the widget display status stays selected whilst it repeats */
			}
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
	int len, offs;
	XA_SLIDER_WIDGET *sl = widg->stuff;
	RECT r, cl;

	rp_2_ap(wind, widg, &r);	/* Convert relative coords and window location to absolute screen location */

	if (sl->length >= SL_RANGE)
	{
		sl->r = r;
		slider_back(&r);
		return true;
	}

	wr_mode(MD_REPLACE);

	len = sl_to_pix(r.h, sl->length);
	if (len < cfg.widg_h-3)				/* HR: not too small please */
		len = cfg.widg_h-3;
	offs = r.y + sl_to_pix(r.h - len, sl->position);

	if (offs < r.y)
		offs = r.y;
	if (offs + len > r.y + r.h)
		len = r.y + r.h - offs;

	if (   sl->r.h == 0		/* if initial, or after sizing or off top */
		or wind != window_list)
	{
		sl->r = r;
		slider_back(&r);	/* whole background */
	}
	else
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
		int thick = 1, mode = 3;
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
	RECT r; int len, offs;
	XA_SLIDER_WIDGET *sl = widg->stuff;
	RECT cl;

	rp_2_ap(wind, widg, &r);

	if (sl->length >= SL_RANGE)
	{
		sl->r = r;
		slider_back(&r);
		return true;
	}

	wr_mode(MD_REPLACE);

	len = sl_to_pix(r.w, sl->length);
	if (len < cfg.widg_w-3)
		len = cfg.widg_w-3;
	offs = r.x + sl_to_pix(r.w - len, sl->position);

	if (offs < r.x)
		offs = r.x;
	if (offs + len > r.x + r.w)
		len = r.x + r.w - offs;

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
		int thick = 1, mode = 3;
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
   I immensely hate that behaviour, as it seems to be the standard for certain
   operating systems nowadays.
   It is unnatural and unintelligent.
		Note, that the stuff for clicking on page arrows has completely vanished,
		as that is mow unified with the line arrows.
*/

static
WidgetBehaviour drag_vslide	/* (LOCK lock, XA_WINDOW *wind, XA_WIDGET *widg) */
{
	XA_SLIDER_WIDGET *sl = widg->stuff;
	G_i pmx, pmy, mx, my, mb;
	int offs;

	vq_mouse(C.vh, &mb, &pmx, &pmy);  /* need to do this anyhow, for mb */

	if (!widget_active.cont)
	{
		widget_active.cont = true;
		graf_mouse(XACRS_VERTSIZER, nil);		/* Always have a nice consistent sizer when dragging a box */
	}

	if (widget_active.widg)		/* pending widget: take that */
	{
		pmy = widget_active.y;
		offs = widget_active.offs;
	}
	else
		offs = sl->position;

	if (mb)		/* Drag slider */
	{
		vq_mouse(C.vh, &mb, &mx, &my);
		if (my != pmy)			/* Has the mouse moved? */
			offs = bound_sl(offs + pix_to_sl(my - pmy, widg->loc.r.h - sl->r.h) );
		set_widget_active(wind, widg, drag_vslide,3);
		widget_active.y = my;
		widget_active.offs = offs;
		wind->send_message(lock, wind, nil,
				WM_VSLID, 0, 0, wind->handle,
				offs,     0, 0, 0);
		return false;	/* We return false here so the widget display status stays selected whilst it repeats */
	}

	cancel_widget_active(wind, 3);
	return true;
}

static
WidgetBehaviour drag_hslide	/* (LOCK lock, XA_WINDOW *wind, XA_WIDGET *widg) */
{
	XA_SLIDER_WIDGET *sl = widg->stuff;
	G_i pmx, pmy, mx, my, mb;
	int offs;

	vq_mouse(C.vh, &mb, &pmx, &pmy);  /* need to do this anyhow, for mb */

	if (!widget_active.cont)
	{
		widget_active.cont = true;
		graf_mouse(XACRS_HORSIZER, nil);		/* Always have a nice consistent sizer when dragging a box */
	}

	if (widget_active.widg)		/* pending widget: take that */
	{
		pmx = widget_active.x;
		offs = widget_active.offs;
	}
	else
		offs = sl->position;

	if (mb)		/* Drag slider */
	{
		vq_mouse(C.vh, &mb, &mx, &my);
		if (mx != pmx)			/* Has the mouse moved? */
			offs = bound_sl(offs + pix_to_sl(mx - pmx, widg->loc.r.w - sl->r.w) );
		set_widget_active(wind, widg, drag_hslide,4);
		widget_active.x = mx;
		widget_active.offs = offs;
		wind->send_message(lock, wind, nil,
				WM_HSLID, 0, 0, wind->handle,
				offs, 0, 0, 0);
		return false;	/* We return false here so the widget display status stays selected whilst it repeats */
	}

	cancel_widget_active(wind, 4);
	return true;
}

/*
 *	Generic Object Tree Widget display
 */
global
WidgetBehaviour display_object_widget	/* (LOCK lock, XA_WINDOW *wind, XA_WIDGET *widg) */
{
	XA_TREE *wt = widg->stuff;
	IFDIAG(OBJECT *root;)

	if (wind->owner->killed or wt->owner->killed)
		return false;

	IFDIAG(root =)
	rp_2_ap(wind, widg, nil);	/* Convert relative coords and window location to absolute screen location */

	DIAG((D_form,wind->owner,"display_object_widget(wind=%d), is_edit=%d, form: %d/%d\n", wind->handle,wt->edit_obj, root->r.x, root->r.y));

	/* HR: */
	if (wind->nolist and (wind->dial&created_for_POPUP))		/* clip work area */
	{
		set_clip(&wind->wa);
		draw_object_tree(lock, wt, nil, widg->start ,100,123);
		clear_clip();
	}
	else
		draw_object_tree(lock, wt, nil, widg->start ,100,3);

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
void shift_from_top(XA_WINDOW *wind, XA_WIDGET *widg, long tp, int xtra)
{
	int wd;

	for (wd = 0; wd < XA_MAX_WIDGETS; wd++)	/* Shift any widgets we might interfere with */
	{
		XA_WIDGET *tw = wind->widgets + wd;
		if (tp & tw->loc.mask)
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
	int wd, bottom = 0, right = 0;

	wind->active_widgets = tp;			/* Fill in the active widgets summary */

	wind->widg_info.tree = def_widgets;		/* HR 300801: Increases stability (a permenent widget tree of its own). */
	wind->widg_info.owner = wind->owner;

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

/* HR 260901: function make_widget().
              The function is not only to spare some bytes.
              Most important is to keep the organization and the access mechanisms
              of the widgets out of sight and centralized.
              And, of course, remove duplication of trivial text.
              Such things make life easier for a maintainer.
              widgets_on_top has become obsolete and is removed.
*/
	if (tp & CLOSE)
		make_widget(wind, &stdl_close, display_def_widget, click_close, 0);
	if (tp & FULL)
		make_widget(wind, &stdl_full, display_def_widget, click_full, 0);
	if (tp & ICONIFY)
	{
		widg = make_widget(wind, &stdl_iconify, display_def_widget, click_iconify, 0);
		if (tp & FULL)
			widg->loc.r.x += get_widget(wind, XAW_FULL)->loc.r.w;
	}
	if (tp & HIDE)
	{
		widg = make_widget(wind, &stdl_hide, display_def_widget, click_hide, 0);
		if (tp & FULL)
			widg->loc.r.x += get_widget(wind, XAW_FULL)->loc.r.w;
		if (tp & ICONIFY)
			widg->loc.r.x += get_widget(wind, XAW_ICONIFY)->loc.r.w;
	}
	if (tp & SIZE)
		widg = make_widget(wind, &stdl_resize, display_def_widget, 0, drag_resize);

	if ((tp & (SIZE|MOVE)) == (SIZE|MOVE))		/* HR 280102: implement border sizing. */
		widg = make_widget(wind, &stdl_border, display_border, drag_border, drag_border);

	if (tp & UPARROW)
	{
		widg = make_widget(wind, &stdl_uscroll, display_def_widget, click_scroll, click_scroll);
		widg->arrowx = WA_UPLINE;
		widg->xarrow = WA_DNLINE;				/* HR 181201 */
		widg->xlimit = SL_RANGE;
		widg->slider_type = XAW_VSLIDE;
		if (tp & VSLIDE)
		{
			widg = make_widget(wind, &stdl_upage, display_arrow, click_scroll, click_scroll);
			widg->arrowx = WA_UPPAGE;
			widg->xarrow = WA_DNPAGE;				/* HR 181201 */
			widg->xlimit = SL_RANGE;
			widg->slider_type = XAW_VSLIDE;
		}
	}
	if (tp & DNARROW)
	{
		widg = make_widget(wind, &stdl_dscroll, display_def_widget, click_scroll, click_scroll);
		if ( ! (tp & SIZE) and !bottom)			/* HR */
			widg->loc.r.y -= cfg.widg_h;
		else if (bottom)
			widg->loc.r.y += WASP;
		widg->arrowx = WA_DNLINE;
		widg->xarrow = WA_UPLINE;				/* HR 181201 */
		widg->limit = SL_RANGE;
		widg->slider_type = XAW_VSLIDE;
		if (tp & VSLIDE)
		{
			widg = make_widget(wind, &stdl_dpage, display_arrow, click_scroll, click_scroll);
			widg->arrowx = WA_DNPAGE;
			widg->xarrow = WA_UPPAGE;				/* HR 181201 */
			widg->limit = SL_RANGE;
			widg->slider_type = XAW_VSLIDE;
		}
	}
	if (tp & LFARROW)
	{
		widg = make_widget(wind, &stdl_lscroll, display_def_widget, click_scroll, click_scroll);
		widg->arrowx = WA_LFLINE;
		widg->xarrow = WA_RTLINE;				/* HR 181201 */
		widg->xlimit = SL_RANGE;
		widg->slider_type = XAW_HSLIDE;
		if (tp & HSLIDE)
		{
			widg = make_widget(wind, &stdl_lpage, display_arrow, click_scroll, click_scroll);
			widg->arrowx = WA_LFPAGE;
			widg->xarrow = WA_RTPAGE;				/* HR 181201 */
			widg->xlimit = SL_RANGE;
			widg->slider_type = XAW_HSLIDE;
		}
	}
	if (tp & RTARROW)
	{
		widg = make_widget(wind, &stdl_rscroll, display_def_widget, click_scroll, click_scroll);
		if ( ! (tp & SIZE) and !right)				/* HR */
			widg->loc.r.x -= cfg.widg_h;
		else if (right)
			widg->loc.r.x += WASP;
		widg->arrowx = WA_RTLINE;
		widg->xarrow = WA_LFLINE;				/* HR 181201 */
		widg->limit = SL_RANGE;
		widg->slider_type = XAW_HSLIDE;
		if (tp & HSLIDE)
		{
			widg = make_widget(wind, &stdl_rpage, display_arrow, click_scroll, click_scroll);
			widg->arrowx = WA_RTPAGE;
			widg->xarrow = WA_LFPAGE;				/* HR 181201 */
			widg->limit = SL_RANGE;
			widg->slider_type = XAW_HSLIDE;
		}
	}
	if (tp & VSLIDE)
	{
		widg = make_widget(wind, &stdl_vslide, display_vslide, 0, drag_vslide);
		if (!keep_stuff)					/* HR 210801 */
		{
			XA_SLIDER_WIDGET *sl = xcalloc(1,sizeof(*sl),100);
			widg->stuff = sl;
			sl->length = SL_RANGE;
		}
	}
	if (tp & HSLIDE)
	{
		widg = make_widget(wind, &stdl_hslide, display_hslide, 0, drag_hslide);
		if (!keep_stuff)					/* HR 210801 */
		{
			XA_SLIDER_WIDGET *sl = xcalloc(1,sizeof(*sl),101);
			widg->stuff = sl;
			sl->length = SL_RANGE;
		}
	}

	if (tp & XaPOP)		/* HR: popups in a window */
		make_widget(wind, &stdl_pop, 0, 0, 0);

	if (tp & XaMENU)
	{
		widg = make_widget(wind, &stdl_menu, 0, 0, 0);
		widg->loc.r.h = screen.c_max_h + 3;			/* HR 251201 */
		/* Remainder of widg is provided by set_menu_widget() */		
		
		if (tp & (NAME|CLOSE|FULL|ICONIFY|HIDE))
			widg->loc.r.y += cfg.widg_h + 1;

		if (tp & INFO)
			widg->loc.r.y += cfg.widg_h + 1;

		shift_from_top(wind, widg, tp & (~(XaMENU|INFO|NAME|CLOSE|FULL|ICONIFY|HIDE)), 3);
	}

	if (tp & INFO)
	{
		widg = make_widget(wind, &stdl_info, display_info, 0, 0);

		if (!keep_stuff)					/* HR 210801 */
			widg->stuff = "Info Bar";	/* Give the window a default info line until the client changes it */
		
		if (tp & (NAME|CLOSE|FULL|ICONIFY))
			widg->loc.r.y += cfg.widg_h + 1;

		shift_from_top(wind, widg, tp & (~(XaMENU|INFO|NAME|CLOSE|FULL|ICONIFY|HIDE)), 2);
	}

	if (tp & NAME)
	{
		widg = make_widget(wind, &stdl_title, display_title, click_title, drag_title);
		widg->dclick = dclick_title;
		if (widg->stuff == nil and !keep_stuff)				/* HR &  HR 210801 */
			widg->stuff = "XaAES Window";	/* Give the window a default title if not already set */

		if (tp&CLOSE)
			widg->loc.r.x += cfg.widg_w + 1;
			
		shift_from_top(wind, widg, tp & (~(XaMENU|INFO|NAME|CLOSE|FULL|ICONIFY|HIDE)), (tp & INFO) ? 0 : 2);
	}
	else
		widg = make_widget(wind, &stdl_notitle, 0, 0, 0);

	widg->loc.r.h = cfg.widg_h;

	if ((tp&VSLIDE) and !(tp&UPARROW))
	{
		get_widget(wind, XAW_UPPAGE)->loc.r.y -= cfg.widg_h;
		get_widget(wind, XAW_VSLIDE)->loc.r.y -= cfg.widg_h;
	}
	if ((tp&HSLIDE) and !(tp&LFARROW))
	{
		get_widget(wind, XAW_LFPAGE)->loc.r.x -= cfg.widg_w;
		get_widget(wind, XAW_HSLIDE)->loc.r.x -= cfg.widg_w;
	}
}

/*
 * Attach a toolbar to a window...probably let this be accessed via wind_set one day
 */
global
XA_TREE *set_toolbar_widget(LOCK lock, XA_WINDOW *wind, OBJECT *form, int item)		/* HR: item */
{
	XA_TREE *wt;
	XA_WIDGET *widg;
	XA_WIDGET_LOCATION loc;
	
	wt = &wind->toolbar;
	widg = get_widget(wind, XAW_TOOLBAR);
	wt->tree = form;
	wt->widg = widg;					/* HR 070702 */
	wt->owner = wind->owner;  /* Nakijken!!! */

	init_form_do(lock, wt, form, item, false);		/* HR 060702 */

	if (has_default(form) or wt->edit_obj >= 0)
		wind->keypress = handle_form_key;
	if (wind->dial&created_for_FORM_DO)		/* HR 250602 */
		wt->exit_form = exit_form_do;
	else
		wt->exit_form = exit_form_dial;

	loc.relative_type = LT;
	loc.r.x = wind->wa.x - wind->r.x - wind->frame;
	loc.r.y = wind->wa.y - wind->r.y - wind->frame;
	loc.r.w = form->r.w;
	loc.r.h = form->r.h;
	loc.mask = TOOLBAR;

	widg->display = display_object_widget;
	widg->click = click_object_widget;
	/* HR 280801: clicks are now put in the widget struct.
	      NB! use this property only when there is very little difference between the 2 */
	widg->dclick = click_object_widget;
	widg->drag = click_object_widget;
	widg->loc = loc;
	widg->state = NONE;
	widg->stuff = wt;
	widg->start = 0;
	wind->tool = widg;
	return wt;
}

/* HR 120201 & 100701 */
void remove_widget(LOCK lock, XA_WINDOW *wind, int tool)
{
	XA_WIDGET *widg = get_widget(wind, tool);
	XA_TREE *wt = widg->stuff;
DIAG((D_form,nil,"remove_widget %d: %ld\n", tool, wt));
	if (wt)
	{
		if (wt->extra)					/* HR 210501 */
			free(wt->extra);
		if (    wt != &wind->menu_bar
		    and wt != &wind->toolbar
		    and wt != &wind->widg_info
		   )
			free(wt);
	}
	wind->keypress = nil;

	widg->stuff   = nil;
 	widg->display = nil;
	widg->click   = nil;
	widg->dclick  = nil;
	widg->drag    = nil;
}

static
bool is_page(int f)
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
int is_H_arrow(XA_WINDOW *w, XA_WIDGET *widg, int click)
{
	XA_SLIDER_WIDGET *sl = widg->stuff;			/* but are we in the slider itself, the slidable one :-) */

	if (click > sl->r.x and click < sl->r.x + sl->r.w)
		return 0;

	if (w->active_widgets&LFARROW)			/* outside slider, arrows must be defined */
	{										/* outside has 2 sides :-) */
		if (sl->position > 0        and click < sl->r.x)				/* up arrow */
			return 1;						/* add to slider index */
		if (sl->position < SL_RANGE and click > sl->r.x + sl->r.w)	/* dn arrow */
			return 2;
	}

	return -1;		/* no active widget, skip */
}

/* same as above, but for vertical slider */
static
int is_V_arrow(XA_WINDOW *w, XA_WIDGET *widg, int click)
{
	XA_SLIDER_WIDGET *sl = widg->stuff;

	if (click > sl->r.y and click < sl->r.y + sl->r.h)
		return 0;

 	if (w->active_widgets&UPARROW)
	{
		if (sl->position > 0        and click < sl->r.y)	
			return 1;
		if (sl->position < SL_RANGE and click > sl->r.y + sl->r.h)
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

/* HR 161101: possibility to mask out certain widgets. */
global
int do_widgets(LOCK lock, XA_WINDOW *w, XA_WIND_ATTR mask, MOOSE_DATA *md)		/* HR */
{
	XA_WIDGET *widg;
	int f, clicks;

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

		if (widg->display)						/* Is the widget in use? */
		{
			if (    widg->loc.mask       == 0			/* not maskable */
			    or (widg->loc.mask&mask) == 0			/* masked */
			   )
			{
				bool inside;

				if (f != XAW_BORDER)					/* HR 280102: implement border sizing. */
				{										/* Normal widgets */
					rp_2_ap(w, widg, &r);				/* Convert relative coords and window location to absolute screen location */
					inside = m_inside(md->x, md->y, &r);
				} else
				{
					r = w->r;						/* Inside window and outside border area = border. */
					inside = !m_inside(md->x, md->y, &w->ba);
				}

				if (inside)
				{
					bool rtn = false;
					int ax = 0;
		
					widg->x = md->x - r.x; 			/* Mark where the click occurred (relative to the widget) */
					widg->y = md->y - r.y;
					widg->mx = md->x;				/* HR 150202 */
					widg->my = md->y;
					widg->s = md->state;			/* HR 280801: we need the state also some time (desktop widget) */
					vq_key_s(C.vh, &widg->k);		/* HR 190202: for convenience. */
					widg->clicks = clicks;

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
						widg->x = md->x - r.x; 			/* Mark where the click occurred (relative to the widget) */
						widg->y = md->y - r.y;
						widg->mx = md->x;				/* HR 150202 */
						widg->my = md->y;
						widg->s = md->state;			/* HR 280801: we need the state also some time (desktop widget) */
						vq_key_s(C.vh, &widg->k);		/* HR 190202: for convenience. */
						widg->clicks = clicks;
						rtn = widg->drag(lock, w, widg);		/* we know there is only 1 behaviour for these arrows */
					}
					else /* normal widget */
					{
						G_i b, rx, ry;
	
						/* We don't auto select & pre-display for a menu or toolbar widget */
						if (f != XAW_MENU and f != XAW_TOOLBAR)
							redisplay_widget(lock, w, widg, SELECTED);
		
						vq_mouse(C.vh, &b, &rx, &ry);
						if ((b) and widg->drag) 	/* If the mouse button is still down do a drag (if the widget has a drag behaviour) */
							rtn = widg->drag(lock, w, widg);
						else					/*  otherwise, process as a mouse click(s) */
						{
							while (b)				/* Wait for the mouse to be released */
								vq_mouse(C.vh, &b, &rx, &ry);
						
							if (m_inside(rx, ry, &r))
								if (widg->click)				/* If the widget has a click behaviour, call it */
									rtn = widg->click(lock, w, widg);
								else
									rtn = true;
							else
								rtn = true;		/* HR 060601: released outside widget: reset its state. */
	
							if (w->winob)		/* HR 060601: a little bit of hack, until checking widget_active
							                                  is moved from pending_msg() to the kernel. */
								cancel_widget_active(w, 5);
						}
					}
	
					if (rtn)	/* If the widget click/drag function returned true we reset the state of the widget */
					{
						DIAG((D_button,nil,"Deselect widget\n"));
						redisplay_widget(lock, w, widg, NONE);	/* Flag the widget as de-selected */
					}
					else
					if (w == root_window and f == XAW_TOOLBAR)		/* HR: 280801 a little bit special. */
						return false;		/* pass click to desktop owner */
	
					return true;			/* click devoured by widget */
				}						/*if m)inside */
			}						/* if not masked */
		}						/* if there */
	}						/* for f */

	return false;				/* Button click can be passed on to applications as we didn't use it for a widget */
}

global
void redisplay_widget(LOCK lock, XA_WINDOW *wind, XA_WIDGET *widg, int state)
{

	widg->state = state;

	if (wind->nolist)		/* No rectangle list. */
	{
		hidem();
		widg->display(lock, wind, widg);		/* Not on top, but visible */
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
			int rtn;
			XA_WINDOW *wind = widget_active.wind;
			XA_WIDGET *widg = widget_active.widg;

			rtn = (*widget_active.action)(lock, wind, widg);	/* Call the pending action */
	
	/* HR: 050601: if the pending widget is canceled, its state is undefined!!!!!! */
			if (rtn)	/* If the widget click/drag function returned true we reset the state of the widget */
				redisplay_widget(lock, wind, widg, NONE); /* Flag the widget as de-selected */
		}
}
