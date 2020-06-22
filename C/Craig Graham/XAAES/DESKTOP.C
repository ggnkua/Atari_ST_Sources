/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include "K_DEFS.H"
#include "XA_TYPES.H"
#include "XA_DEFS.H"
#include "XA_GLOBL.H"
#include "OBJECTS.H"
#include "DESKTOP.H"

/*
	Desktop Handling Routines
*/

OBJECT *desktop=NULL;

/*
	Set a new object tree for the desktop
*/
void set_desktop(OBJECT *new_desktop)
{
	if (new_desktop)
	{
/* Size & position the desktop to fit the root window */
		new_desktop->ob_x=root_window->wx;
		new_desktop->ob_y=root_window->wy;
		new_desktop->ob_width=root_window->ww;
		new_desktop->ob_height=root_window->wh;
	}
	
/* Set the desktop */
	desktop=new_desktop;

/* Now use the root window's auto-redraw function to redraw it */
	root_window->redraw=&redraw_desktop;
}

/*
	Redraw the desktop object tree
	- blindingly simple or what?
*/
short redraw_desktop(XA_WINDOW *wind)
{
	if (!desktop)
		return FALSE;

/* We can ignore the wind parameter here, as the desktop window never actually moves
   or changes dimensions */
	draw_object_tree(desktop, 0, 100);

	return TRUE;
}
