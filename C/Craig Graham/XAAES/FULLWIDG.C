/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <OSBIND.H>
#include <VDI.H>
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

/*======================================================
	FULL WIDGET BEHAVIOUR
========================================================*/
/* Default full widget behaviour - just send a WM_FULLED message to the client that */
/* owns the window. */
short click_full(XA_WINDOW *wind, XA_WIDGET *widg)
{
	send_app_message(wind->owner, WM_FULLED, 0, wind->handle, 0, 0, 0, 0);
	return TRUE;
}

short display_full(XA_WINDOW *wind, XA_WIDGET *widg)
{
	short x,y;

	rp_2_ap(wind, widg, &x, &y);	/* Convert relative coords and window location to absolute screen location */

	if (widg->stat==XAW_PLAIN)
		display_widget_bitmap(x, y, widget_bitmap_full);
	else
		display_widget_bitmap(x, y, widget_bitmap_full_s);

	return TRUE;
}
