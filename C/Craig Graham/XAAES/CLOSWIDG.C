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
	CLOSE WIDGET BEHAVIOUR
========================================================*/
/* Display the closer widget */
short display_close_widget(XA_WINDOW *wind, XA_WIDGET *widg)
{
	short x,y;

	rp_2_ap(wind, widg, &x, &y);

	if (widg->stat==XAW_PLAIN)
		display_widget_bitmap(x, y, widget_bitmap_close);
	else
		display_widget_bitmap(x, y, widget_bitmap_close_s);
		
	return TRUE;
}

/* 
 Default close widget behaviour - just send a WM_CLOSED message to the client that
 owns the window.
*/
short click_close(XA_WINDOW *wind, XA_WIDGET *widg)
{
	if (wind->active_widgets&NO_MESSAGES)	/* Just close these windows, they can handle it.... */
	{
		v_hide_c(V_handle);

		display_windows_below(wind);
		send_wind_to_bottom(wind);

		v_show_c(V_handle,1);
		
		delete_window(wind);
		
		return FALSE;	/* Don't redisplay in the do_widgets() routine */
	}
	
	send_app_message(wind->owner, WM_CLOSED, 0, wind->handle, 0, 0, 0, 0);

	return TRUE; /* Redisplay.... */
}
