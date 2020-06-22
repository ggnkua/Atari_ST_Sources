/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <VDI.H>
#include "XA_TYPES.H"
#include "XA_GLOBL.H"

void XA_3D_rect(short x, short y, short w, short h, short b, short b1)
{
	short pnt[10];
	
	vsf_color(V_handle,display.dial_colours.bg_col);
	vsf_interior(V_handle,FIS_SOLID);		/* Select solid fills - maybe make this an option? */
	pnt[0]=x; pnt[1]=y; pnt[2]=x+w; pnt[3]=y+h;
	v_bar(V_handle,pnt);

	vsl_color(V_handle,display.dial_colours.b_r_col);

	pnt[0]=x+b; pnt[1]=y+h-b;
	pnt[2]=x+b; pnt[3]=y+b;
	pnt[4]=x+w-b; pnt[5]=y+b;
	v_pline(V_handle,3,pnt);
	
	pnt[0]=x+b+4; pnt[1]=y+h-b-1;
	pnt[2]=x+w-b-1; pnt[3]=y+h-b-1;
	pnt[4]=x+w-b-1; pnt[5]=y+b+1;
	v_pline(V_handle,3,pnt);
	
	vsl_color(V_handle,display.dial_colours.t_l_col);

	pnt[0]=x+w-b; pnt[1]=y+b+1;
	pnt[2]=x+w-b; pnt[3]=y+h-b;
	pnt[4]=x+b+1; pnt[5]=y+h-b;
	v_pline(V_handle,3,pnt);
	
	pnt[0]=x+b+1; pnt[1]=y+h-b-1;
	pnt[2]=x+b+1; pnt[3]=y+b+1;
	pnt[4]=x+w-b-1; pnt[5]=y+b+1;
	v_pline(V_handle,3,pnt);
	
	if (!b1) return;
	
	vsl_color(V_handle,display.dial_colours.border_col);
	pnt[0]=x; pnt[1]=y;
	pnt[2]=x+w; pnt[3]=y;
	pnt[4]=x+w; pnt[5]=y+h;
	pnt[6]=x; pnt[7]=y+h;
	pnt[8]=x; pnt[9]=y;
	v_pline(V_handle,5,pnt);
}

void XA_3D_pushbutton(short x, short y, short w, short h, short selected)
{
	short pnt[6];

	pnt[0]=x; pnt[1]=y;
	pnt[2]=x+w; pnt[3]=y+h;
	v_bar(V_handle, pnt);

	if (selected)
		vsl_color(V_handle,display.dial_colours.b_r_col);
	else
		vsl_color(V_handle,display.dial_colours.t_l_col);

	pnt[0]=x; pnt[1]=y+h;
	pnt[2]=x; pnt[3]=y;
	pnt[4]=x+w; pnt[5]=y;
	v_pline(V_handle,3,pnt);

	if (selected)
		vsl_color(V_handle,display.dial_colours.t_l_col);
	else
		vsl_color(V_handle,display.dial_colours.b_r_col);

	pnt[0]=x+1; pnt[1]=y+h;
	pnt[2]=x+w; pnt[3]=y+h;
	pnt[4]=x+w; pnt[5]=y+1;
	v_pline(V_handle,3,pnt);
}
