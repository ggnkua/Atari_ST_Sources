/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <VDI.H>
#include "XA_DEFS.H"
#include "XA_TYPES.H"
#include "K_DEFS.H"
#include "XA_GLOBL.H"
#include "DRAG_BOX.H"
#include "WATCHBOX.H"

/*
	INTERFACE TO INTERACTIVE BOX ROUTINES
*/

unsigned long XA_graf_dragbox(short clnt_pid, AESPB *pb)
{
	short x,y;
	
	drag_box(pb->intin[0],
				pb->intin[1],
				pb->intin[2],
				pb->intin[3],
				pb->intin[4],
				pb->intin[5],
				pb->intin[6],
				pb->intin[7],
				&x,&y);
	
	pb->intout[0]=1;
	pb->intout[1]=x;
	pb->intout[2]=y;
	
	return XAC_DONE;
}

unsigned long XA_graf_rubberbox(short clnt_pid, AESPB *pb)
{
	short w,h;
	
	rubber_box(pb->intin[0],
				pb->intin[1],
				pb->intin[2],
				pb->intin[3],
				&w,&h);

	pb->intout[0]=1;
	pb->intout[1]=w;
	pb->intout[2]=h;
	
	return XAC_DONE;
}

unsigned long XA_graf_watchbox(short clnt_pid, AESPB *pb)
{
	pb->intout[0]=watch_object((OBJECT*)pb->addrin[0], pb->intin[1], pb->intin[2], pb->intin[3]);
	return XAC_DONE;
}

