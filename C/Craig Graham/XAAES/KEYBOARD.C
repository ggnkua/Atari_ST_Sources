/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <MINTBIND.H>
#include <OSBIND.H>
#include <FILESYS.H>
#include <MINTBIND.H>
#include "XA_DEFS.H"
#include "XA_TYPES.H"
#include "XA_GLOBL.H"
#include "APP_MAN.H"
#include "C_WINDOW.H"
#include "EVNT_MUL.H"

/*
	Keyboard input handler
*/

void do_keyboard(void)
{
	long key;
	unsigned short AESkey;
	short shift_state;
	XA_WINDOW *w=NULL;
	XA_CLIENT *client;
	short client_id;
	short mx,my,mb,kstate;
	unsigned long retv=XA_OK;
	
	vq_mouse(V_handle, &mb,&mx,&my);

	vq_key_s(V_handle,&shift_state);
	kstate=shift_state;
	
#if ALT_CTRL_APP_OPS
/* Check for control+alt+tab, and do an app swap if valid.... */
	shift_state&=12;
	if (shift_state==12)
	{
		key=Crawcin();
		AESkey=(short)((key&0xff)|((key>>8)&0xff00));	/* translate the GEMDOS raw data into AES format*/

		switch(AESkey)
		{
			case 0xf09:			/* CTRL+ALT+TAB switches menu bars */
				next_app_menu();
				return;
				break;
			case 0x1312:		/* Attempt to recover a hung system */
				recover();
				return;
				break;
			case 0x260c:		/* Output a list of current clients via DIAGS */
				list_apps();
				return;
				break;
			case 0x250b:		/* Tidy up after any clients that have died without calling appl_exit() */
				find_dead_clients();
				return;
				break;
			case 0x2004:		/* Dump the current system status */
				status_dump();
				return;
				break;
		}
	}
#endif

	
#if POINT_TO_TYPE
/* Keyboard input goes to the application whose window is under the mouse */
	w=wind_find(mx,my); 

/* If there is no window under the mouse, send to the top window instead */
	if (!w)
	{
		w=window_list;
	}else{
		
		if (!(w->owner->waiting_for&XAWAIT_KEY))	/* If window under mouse isn't waiting for keys, maybe the top window is? */
			w=window_list;
	}
#else

/* Keyboard input always goes to the application whose window is on top */
	w=window_list;
	client_id=w->owner;
	
#endif

	if (update_lock)
	{
		client_id=update_lock;
	}

	client=Pid2Client(client_id);

	if (!client)
		return;

	DIAGS(("keyhandler:client_id=%d, window_owner=%d\n",client_id,w->owner));

	if ((w)&&(w->owner==client_id))
	{
		if (w->keypress)	/* Does the target window have a keypress handler callback? */
		{
			key=Crawcin();
			AESkey=(short)((key&0xff)|((key>>8)&0xff00));	/* translate the GEMDOS raw data into AES format*/
			(*(w->keypress))(w,AESkey);
			return;
		}
	}

	Psemaphore(2,CLIENTS_SEMAPHORE,-1L);

	if (client->waiting_for&XAWAIT_KEY)	/* If the client owning the window was waiting for a keyboard event, send it */
	{
		key=Crawcin();
		AESkey=(short)((key&0xff)|((key>>8)&0xff00));	/* translate the GEMDOS raw data into AES format*/

		if (client->waiting_for&XAWAIT_MULTI)	/* If the client is waiting on a multi, the response is  */
		{												/* slightly different to the evnt_keybd() response. */
			client->waiting_pb->intout[0]=MU_KEYBD;
			client->waiting_pb->intout[1]=mx;
			client->waiting_pb->intout[2]=my;
			client->waiting_pb->intout[3]=mb;
			client->waiting_pb->intout[4]=kstate;
			client->waiting_pb->intout[5]=AESkey;
			client->waiting_pb->intout[6]=0;
			cancel_evnt_multi(client_id);
		}else{
			client->waiting_pb->intout[0]=AESkey;
			client->waiting_for=0;	/* Now client isn't waiting for anything */
		}
		
		Fwrite(client->clnt_pipe_wr,sizeof(unsigned long),&retv);	/* Write success to clients reply pipe to unblock the process */
		
	}
		
	Psemaphore(3,CLIENTS_SEMAPHORE,0L);

}
