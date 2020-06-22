/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <MINTBIND.H>
#include <OSBIND.H>
#include <memory.h>
#include "K_DEFS.H"
#include "KERNAL.H"
#include "XA_DEFS.H"
#include "XA_TYPES.H"
#include "XA_GLOBL.H"
#include "MOUSE_CL.H"
#include "EVNT_BTN.H"
#include "C_WINDOW.H"
#include "EVNT_MUL.H"
#include "std_widg.h"

/*
	Mouse button click handler 
	- MOUSESRV sever process passes us click events
*/

/* The real button click handler is here :) */
short XA_button_event(MOUSE_DATA *md)
{
	XA_CLIENT *client;
	XA_WINDOW *w;
	short kstate;
	unsigned long retv=XA_OK;
	short target_app=0;
	
	DIAGS(("MOUSE_CLICK EVENT: \n   loc=(%d,%d), state=%d, count=%d\n",md->mx,md->my,md->state, md->clicks));
	
	w=wind_find(md->mx, md->my);	/* Try for a window */
	target_app=w->owner;
	
	if (mouse_lock)					/* Mouse is locked - clicks go to owner of mouse */
	{
		target_app=mouse_lock;
	}else{
		if (update_lock)			/* Screen is locked - clicks go to owner of screen */
		{
			target_app=update_lock;
		}
	}
	
	if ((w)&&(w->owner==target_app))
	{
		if (do_widgets(w,md))
			return FALSE;	/* Process window widgets */
	}

	Psemaphore(2,CLIENTS_SEMAPHORE,-1L);

	client=Pid2Client(target_app);

	if (client->waiting_for&XAWAIT_BUTTON)	/* If the client owning was waiting for a button event, send it */
	{										/* - otherwise forget it, 'coz we don't want delayed clicks (they are confusing to the user [ie. me] ) */
		vq_key_s(V_handle, &kstate);		/* get the current keyboard state */

		if (client->waiting_for&XAWAIT_MULTI)			/* If the client is waiting on a multi, the response is  */
		{												/* slightly different to the evnt_button() response. */
			client->waiting_pb->intout[0]=MU_BUTTON;
			client->waiting_pb->intout[1]=md->mx;
			client->waiting_pb->intout[2]=md->my;
			client->waiting_pb->intout[3]=md->state;
			client->waiting_pb->intout[4]=kstate;
			client->waiting_pb->intout[6]=md->clicks;
			cancel_evnt_multi(target_app);
		}else{
			client->waiting_pb->intout[0]=md->state;
			client->waiting_pb->intout[1]=md->mx;
			client->waiting_pb->intout[2]=md->my;
			client->waiting_pb->intout[3]=md->clicks;
			client->waiting_pb->intout[4]=kstate;
			client->waiting_for=0;			/* Now client isn't waiting for anything */
		}
		Fwrite(client->clnt_pipe_wr,sizeof(unsigned long),&retv);	/* Write success to clients reply pipe to unblock the process */
	}

	Psemaphore(3,CLIENTS_SEMAPHORE,0L);

	return FALSE;
}

