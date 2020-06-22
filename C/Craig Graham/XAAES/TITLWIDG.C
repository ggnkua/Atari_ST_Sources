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
#include "drag_box.h"

/*======================================================
	TITLE WIDGET BEHAVIOUR
========================================================*/
short display_title(XA_WINDOW *wind, XA_WIDGET *widg)
{
	short x,y,pnt[4];

	rp_2_ap(wind, widg, &x, &y);	/* Convert relative coords and window location to absolute screen location */

#if DISPLAY_LOGO_IN_TITLE_BAR
	if (widg->stat==XAW_PLAIN)	/* display the XaAES logo on the title bar of each window */
		display_widget_bitmap(x, y, bitmap_xaaes16);
	else
		display_widget_bitmap(x, y, bitmap_xaaes16_s);

	x+=ICON_W+3;
	pnt[0]=x; pnt[1]=y; pnt[2]=x+widg->w-ICON_W-6; pnt[3]=y+widg->h;
#else
	pnt[0]=x; pnt[1]=y; pnt[2]=x+widg->w-3; pnt[3]=y+widg->h;
#endif

	if (window_list==wind)	/* Highlight the title bar of the top window */
	{
		vsf_color(V_handle,LBLUE);
		vsf_interior(V_handle,FIS_SOLID);
		v_bar(V_handle,pnt);
		vst_color(V_handle,WHITE);
	}else{
		vst_color(V_handle,BLACK);
	}

	v_gtext(V_handle, x+5,y+1, (char*)widg->stuff);

	return TRUE;
}

/* Click & drag on the title bar - does a move window */
short drag_title(XA_WINDOW *wind, XA_WIDGET *widg)
{
	short x,y;

	if (wind->active_widgets&MOVER)			/* You can only move a window if it's MOVER attribute is set */
	{
		vs_clip(V_handle, 0, NULL);

		graf_mouse(XACRS_MOVER, NULL);		/* Always have a nice consistent MOVER when dragging a box */
		drag_box(wind->w, wind->h, wind->x, wind->y, display.x, display.y, display.w, display.h, &x, &y);
		
		graf_mouse(clients[window_list->owner].client_mouse, clients[window_list->owner].client_mouse_form);	/* Restore the mouse now we've done the drag */

		if ((x!=wind->x)||(y!=wind->y))
		{
			if (wind->active_widgets&NO_MESSAGES)	/* Just move these windows, they can handle it.... */
			{
				v_hide_c(V_handle);
				
				display_windows_below(wind);

				wind->prev_x=wind->x;			/* Save windows previous coords */
				wind->prev_y=wind->y;
				wind->x=x;						/* Change the window coords */
				wind->y=y;
				
				if (!(wind->active_widgets&NO_WORK))
					calc_work_area(wind);
			
				display_non_topped_window(wind,NULL);
			
				v_show_c(V_handle,1);

			}else{	/* Send a message to a client to say that the AES would like the window moving (if the window has moved) */
				send_app_message(wind->owner, WM_MOVED, 0, wind->handle, x, y, wind->w, wind->h);
			}
		}
	}
	
	return TRUE;
}

/* Single click title bar sends window to the back */
short click_title(XA_WINDOW *wind, XA_WIDGET *widg)
{
	short clip[4];

	if (window_list!=wind)	/* If window isn't top then top it */
	{
	
		if (wind->active_widgets&NO_MESSAGES)	/* Just top these windows, they can handle it.... */
		{
			pull_wind_to_top(wind);	/* Top the window */

			clip[0]=wind->x; clip[1]=wind->y;
			clip[2]=wind->x+wind->w; clip[3]=wind->y+wind->h;
			vs_clip(V_handle,1,clip);
			
			v_hide_c(V_handle);
			display_window(wind);	/* Display the window (clip to it's size) */
			v_show_c(V_handle,1);
			
			vs_clip(V_handle,0,clip);
	
		}else{
	
			send_app_message(wind->owner, WM_TOPPED, 0, wind->handle, 0, 0, 0, 0);
	
		}
	
	}else{		/* If window is already top, then send it to the back */

		if (wind->owner==AESpid)
		{
			v_hide_c(V_handle);

			display_windows_below(wind);	/* Redisplay any windows below the one we are bottoming */
											/* (if they require it) */
			send_wind_to_bottom(wind);		/* Send it to the back */
			display_non_topped_window(wind,NULL);/* Re-display the window */

			v_show_c(V_handle,1);

		}else{

			send_app_message(wind->owner, WM_BOTTOMED, 0, wind->handle, 0, 0, 0, 0);

		}
	}
	
	return TRUE;
}

/* Double click title bar of iconified window - sends a restore message */
short dclick_title(XA_WINDOW *wind, XA_WIDGET *widg)
{
	if (wind->active_widgets&NO_MESSAGES)
	{
		return FALSE;
	}
	
/* If window is iconified - send request to restore it */
	if (wind->window_status==XAWS_ICONIFIED)
	{
		send_app_message(wind->owner, WM_UNICONIFY, 0, wind->handle, wind->prev_x, wind->prev_y, wind->prev_w, wind->prev_h);
	}
	
	return TRUE;
}

