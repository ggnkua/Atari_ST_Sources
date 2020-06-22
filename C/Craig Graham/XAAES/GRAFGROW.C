/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <VDI.H>
#include <OSBIND.H>
#include "XA_DEFS.H"
#include "XA_TYPES.H"
#include "XA_GLOBL.H"
#include "OBJECTS.H"

unsigned long XA_graf_growbox(short clnt_pid, AESPB *pb)
{
	short x=pb->intin[0];
	short y=pb->intin[1];
	short w=pb->intin[2];
	short h=pb->intin[3];
	short xe=pb->intin[4];
	short ye=pb->intin[5];
	short we=pb->intin[6];
	short he=pb->intin[7];
	short dx,dy,dw,dh;
	short f;
	
	dx=(xe-x)/GRAF_STEPS;
	dy=(ye-y)/GRAF_STEPS;
	dw=(we-w)/GRAF_STEPS;
	dh=(he-h)/GRAF_STEPS;

	vswr_mode(V_handle, MD_XOR);

	v_hide_c(V_handle);

	for(f=0; f<GRAF_STEPS; f++)			/* Draw initial growing outline */
	{
		draw_2d_box(x, y, w, h, 1, BLACK);
		x+=dx; y+=dy;
		w+=dw; h+=dh;
		if (f%2) Vsync();
	}
	
	x=pb->intin[0];						/* reset to initial area */
	y=pb->intin[1];
	w=pb->intin[2];
	h=pb->intin[3];

	for(f=0; f<GRAF_STEPS; f++)			/* Erase growing outline */
	{
		draw_2d_box(x, y, w, h, 1, BLACK);
		x+=dx; y+=dy;
		w+=dw; h+=dh;
		if (f%2) Vsync();
	}

	v_show_c(V_handle, 1);

	vswr_mode(V_handle,MD_TRANS);
	
	pb->intout[0]=1;
	
	return XAC_DONE;
}

unsigned long XA_graf_movebox(short clnt_pid, AESPB *pb)
{
	short w=pb->intin[0];
	short h=pb->intin[1];
	short x=pb->intin[2];
	short y=pb->intin[3];
	short xe=pb->intin[4];
	short ye=pb->intin[5];
	short dx,dy;
	short f;
	
	dx=(xe-x)/GRAF_STEPS;
	dy=(ye-y)/GRAF_STEPS;

	vswr_mode(V_handle, MD_XOR);

	v_hide_c(V_handle);

	for(f=0; f<GRAF_STEPS; f++)		/* Draw initial images */
	{
		draw_2d_box(x, y, w, h, 1, BLACK);
		x+=dx; y+=dy;
		if (f%2) Vsync();
	}
	
	x=pb->intin[2];					/* Reset to go back over same area */
	y=pb->intin[3];

	for(f=0; f<GRAF_STEPS; f++)		/* Erase them again */
	{
		draw_2d_box(x, y, w, h, 1, BLACK);
		x+=dx; y+=dy;
		if (f%2) Vsync();
	}

	v_show_c(V_handle, 1);

	vswr_mode(V_handle,MD_TRANS);
	
	pb->intout[0]=1;
	
	return XAC_DONE;
}
