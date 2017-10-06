/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include "xa_types.h"
#include "xa_globl.h"
#include "objects.h"
#include "desktop.h"
#include "xa_rsrc.h"

/*
 *	Desktop Handling Routines
 */

static
OBJECT *desktop;

/*
 * Redraw the desktop object tree
 * - Blindingly simple or what?
 */
static
WindowDisplay redraw_desktop		/* HR */
{
	if (!desktop)
		return false;

	draw_object_tree(lock, nil, desktop, 0, MAX_DEPTH, false,10);
	return true;
}

/*
 * Set a new object tree for the desktop
 */
global
void set_desktop(OBJECT *new_desktop)
{
/* Set the desktop */
	desktop = new_desktop;


/* Now use the root window's auto-redraw function to redraw it */
/* HR: 110601 fixed erroneous use owner->wt.
       The desktop can of course be handled by tool_bar widget stuff!!! */
	root_window->redraw = &redraw_desktop;
/* HR 010501: general fix */
	if (root_window->r.h > desktop->r.h)		
		desktop->r.y = root_window->r.h - desktop->r.h;
}

global
OBJECT *get_desktop(void)
{
	return desktop;
}

global
OBJECT *get_xa_desktop(void)
{
	return ResourceTree(C.Aes_rsc, DEF_DESKTOP);
}
