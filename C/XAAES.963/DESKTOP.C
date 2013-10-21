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

#include "xa_types.h"
#include "xa_globl.h"

#include "xalloc.h"
#include "objects.h"
#include "desktop.h"
#include "xa_rsrc.h"
#include "widgets.h"
#include "menuwidg.h"
#include "app_man.h"

/*
 *	Desktop Handling Routines
 */

global
XA_TREE *get_desktop(void)
{
	return get_widget(root_window, XAW_TOOLBAR)->stuff;
}

global
WidgetBehaviour click_desktop_widget	/* (LOCK lock, XA_WINDOW *wind, XA_WIDGET *widg) */
{
	XA_CLIENT *mowner = menu_owner(),
	          *client = desktop_owner();

DIAG((D_button,nil,"click_desktop_widget, desktop owner: %s\n", c_owner(client) ));
DIAG((D_button,nil,"                         menu owner: %s\n", c_owner(mowner) ));

	if (    S.mouse_lock == 0
	    and mowner       != client)		/* HR 280801!!!! menu, desktop and rootwindow ownership are all different!!! */
    {
    	G_i b,x,y;
    	int item;
    	
		vq_mouse(C.vh, &b, &x, &y);
		item = find_object(get_desktop()->tree, 0, 1, widg->x, widg->y, 0, 0);

		DIAG((D_button,nil,"  --  bs %d, item %d\n", b, item));
	/* button must be released on the root object. */
		if (b == 0 and item == 0)
		{
			app_in_front(lock, client);			/* Also unhides the windows. */
			DIAG((D_button,nil,"click_desktop_widget done\n"));
			return true;	/* click is used */
		}
	}

	return false;			/* pass click to be used by evnt manager. */
}

/* HR 270801
 * Attach a desktop to a window
 */
global
void set_desktop_widget(XA_WINDOW *wind,
					    XA_TREE *desktop)		/* HR tree --> widget */
{
	XA_TREE *nt = xcalloc(1,sizeof(XA_TREE),103);		/* HR: use calloc */
	XA_WIDGET *wi = get_widget(wind, XAW_TOOLBAR);		/* HR */
	XA_WIDGET_LOCATION loc;

	DIAG((D_widg,nil,"set_desktop_widget(wind=%d):new@%lx\n", wind->handle, nt));

	if (!nt)
	{
		DIAG((D_widg,nil," - unable to allocate widget.\n"));
		return;
	}

	*nt = *desktop;			/* HR desktop widget.tree */

	loc.relative_type = LT;
	loc.r = wind->r;
	loc.r.y += MENU_H + 1;
	loc.r.w -= MENU_H + 1;

	wi->display = display_object_widget;
	wi->click   = click_desktop_widget;
	wi->dclick  = click_desktop_widget;
	wi->drag    = click_desktop_widget;
	wi->loc   = loc;
	wi->state = NONE;
	wi->stuff = nt;
	wi->start = 0;
}


/*
 * Redraw the desktop object tree
 * - Blindingly simple or what?
 * HR 270801: now a widget, so it is drawn in the standard widget way. :-)
 *            this function only for non standard drawing (cleanup) 
 */
global
WindowDisplay redraw_desktop		/* HR */
{
	XA_TREE *desktop = get_desktop();
	
	if (desktop == nil)
		return false;
	if (desktop->tree == nil)
		return false;

	draw_object_tree(lock, nil, desktop->tree, 0, MAX_DEPTH, 10);
	return true;
}

/*
 * Set a new object tree for the desktop 
 */
global
void set_desktop(XA_TREE *new_desktop)
{
	OBJECT *ob; RECT r;
	XA_WIDGET *wi = get_widget(root_window, XAW_TOOLBAR);		/* HR */
	XA_TREE *desktop = wi->stuff;

/* Set the desktop */
	*desktop = *new_desktop;

	ob = desktop->tree;
	r = ob->r;

/* Now use the root window's auto-redraw function to redraw it */
/* HR: 110601 fixed erroneous use owner->wt.
       The desktop can of course be handled by tool_bar widget stuff!!! */

	DIAGS(("desktop: %d/%d,%d/%d\n",r.x,r.y,r.w,r.h));
/* HR 010501: general fix */
	if (root_window->r.h > r.h)
		wi->loc.r.y = ob->r.y = root_window->r.h - r.h;
}

global
XA_CLIENT *desktop_owner(void)
{
	return get_desktop()->owner;
}

global
OBJECT *get_xa_desktop(void)
{
	return ResourceTree(C.Aes_rsc, DEF_DESKTOP);
}
