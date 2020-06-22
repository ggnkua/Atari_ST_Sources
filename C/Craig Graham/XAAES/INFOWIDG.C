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
	INFO BAR WIDGET BEHAVIOUR
========================================================*/
short display_info(XA_WINDOW *wind, XA_WIDGET *widg)
{
	short x,y,pnt[6];

	rp_2_ap(wind, widg, &x, &y);	/* Convert relative coords and window location to absolute screen location */

	vsl_color(V_handle,display.dial_colours.b_r_col);

	pnt[0]=x+3; pnt[1]=y+widg->h-1;
	pnt[2]=x+3; pnt[3]=y+1;
	pnt[4]=x+wind->w-4; pnt[5]=y+1;
	v_pline(V_handle,3,pnt);
	
	vsl_color(V_handle,display.dial_colours.t_l_col);

	pnt[0]=x+wind->w-4; pnt[1]=y+2;
	pnt[2]=x+wind->w-4; pnt[3]=y+widg->h-1;
	pnt[4]=x+4; pnt[5]=y+widg->h-1;
	v_pline(V_handle,3,pnt);
	
	vst_color(V_handle,BLACK);

	v_gtext(V_handle, x+5,y+3, (char*)widg->stuff);

	return TRUE;
}
