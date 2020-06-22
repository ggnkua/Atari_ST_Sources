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
	ICONIFY WIDGET BEHAVIOUR
========================================================*/
/* Display the iconify widget */
short display_iconify(XA_WINDOW *wind, XA_WIDGET *widg)
{
	short x,y;

	rp_2_ap(wind, widg, &x, &y);

	if (widg->stat==XAW_PLAIN)
		display_widget_bitmap(x, y, widget_bitmap_iconify);
	else
		display_widget_bitmap(x, y, widget_bitmap_iconify_s);

	return TRUE;
}

/* 
*/
short click_iconify(XA_WINDOW *wind, XA_WIDGET *widg)
{
	if (wind->active_widgets&NO_MESSAGES)
	{
		return FALSE;
	}
	
	switch(wind->window_status)
	{
		case XAWS_OPEN:			/* Window is open - send request to iconify it */
			send_app_message(wind->owner, WM_ICONIFY, 0, wind->handle, iconify_x, iconify_y, iconify_w, iconify_h);
		
			iconify_x+=iconify_w;
			if (iconify_x+iconify_w>display.x+display.w)
			{
				iconify_x=0;
				iconify_y-=iconify_h;
				if (iconify_y<0)
				{
					iconify_y=display.y+display.h-iconify_h-1;
				}
			}
			break;
			
		case XAWS_ICONIFIED:	/* Window is already iconified - send request to restore it */
			send_app_message(wind->owner, WM_UNICONIFY, 0, wind->handle, wind->prev_x, wind->prev_y, wind->prev_w, wind->prev_h);
			break;
	}
	
	return TRUE; /* Redisplay.... */
}
