/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <OSBIND.H>
#include <VDI.H>
#include <string.h>
#include "XA_TYPES.H"
#include "XA_DEFS.H"
#include "XA_GLOBL.H"
#include "KERNAL.H"
#include "K_DEFS.H"
#include "GRAF_MOU.H"
#include "MESSAGES.H"
#include "C_WINDOW.H"
#include "RECTLIST.H"
#include "ALL_WIDG.H"
#include "STD_WIDG.H"
#include "drag_box.h"
#include "OBJECTS.H"

/*======================================================
	RESIZE WIDGET BEHAVIOUR
========================================================*/
short drag_resize(XA_WINDOW *wind, XA_WIDGET *widg)
{
	short w,h;
	
	clear_clip();

	graf_mouse(XACRS_RESIZER, NULL);		/* Always have a nice consistent SIZER when resizing a window */
	rubber_box(wind->x, wind->y, WIDGET_SIZE+20, WIDGET_SIZE+20, &w, &h);
	graf_mouse(clients[window_list->owner].client_mouse, clients[window_list->owner].client_mouse_form);	/* Restore the mouse now we've done the drag */

/* Send a message to the client to say that the AES would like the window re-sizing */
	if ((w!=wind->w)||(h!=wind->h))
		send_app_message(wind->owner, WM_SIZED, 0, wind->handle, wind->x, wind->y, w, h);

	return TRUE;
}

short display_resize(XA_WINDOW *wind, XA_WIDGET *widg)
{
	short x,y;

	rp_2_ap(wind, widg, &x, &y);	/* Convert relative coords and window location to absolute screen location */

	if (widg->stat==XAW_PLAIN)
		display_widget_bitmap(x, y, widget_bitmap_size);
	else
		display_widget_bitmap(x, y, widget_bitmap_size_s);

	return TRUE;
}
