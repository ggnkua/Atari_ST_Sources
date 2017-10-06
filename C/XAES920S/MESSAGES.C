/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <mintbind.h>
#include <osbind.h>

#include "xa_types.h"
#include "xa_globl.h"
#include "xa_evnt.h"

#if GENERATE_DIAGS
static
char *xmsgs[] =
{
	"WM_REDRAW",
	"WM_TOPPED",
	"WM_CLOSED",
	"WM_FULLED",
	"WM_ARROWED",
	"WM_HSLID",
	"WM_VSLID",
	"WM_SIZED",
	"WM_MOVED",
	"WM_NEWTOP",
	"WM_UNTOPPED",
	"WM_ONTOP",
	"WM_OFFTOP",
	"WM_BOTTOMED",
	"WM_ICONIFY	",
	"WM_UNICONIFY",
	"WM_ALLICONIFY",
	"37",
	"38",
	"39",
	"AC_OPEN",
	"AC_CLOSE",
	"42",
	"43",
	"44",
	"45",
	"46",
	"47",
	"48",
	"49",
	"AP_TERM",
	"AP_TFAIL",
	"52",
	"53",
	"54",
	"55",
	"56",
	"AP_RESCHG",
	"58",
	"59",
	"SHUT_COMPLETED",
	"RESCH_COMPLETED",
	"62                          "
};

global
char *pmsg(short m)
{
	if (m >= 20 and m <= 61)
		return xmsgs[m-20];
	sdisplay(xmsgs[42],"%d(%x)",m,m);
	return xmsgs[42];
}
#endif

#if 1
/*
 *	Send an AES message to a client application.
 *  HR: generalized version, which now can be used by appl_write. :-)
 */
global
void send_a_message(LOCK lock, short dest, MSG_BUF *msg)
{
	XA_CLIENT *dest_client;
	MSG_BUF *clnt_buf;
	
	if (dest == C.AESpid) 	/* Just a precaution - we don't want to send app messages to ourselves... */
		return;					/* HR: indeed; messages to the AES itself are switched through the appropriate vector */

	dest_client = Pid2Client(dest);

/* HR static pid array */
	if (dest_client == nil)
	{
		DIAG((D.appl,-1,"WARNING: Invalid target pid [%d] for send_a_message()\n", dest));
		return;
	}

	if (dest_client->killed)	/* HR 100701 */
		return;

	if (C.shutdown)			/* HR 250501 Temporary until proper shutdown implememnted. */
		return;

	if unlocked(clients)
		Sema_Up(CLIENTS_SEMA);
	
/* Is the dest client waiting for a message at the moment? */
	if (dest_client->waiting_for & MU_MESAG)
	{
		if (dest_client->waiting_for & XAWAIT_MULTI)	/* If the client is waiting on a multi, the response is  */
		{												/* slightly different to the evnt_mesag() response. */
			multi_intout(dest_client->waiting_pb->intout, MU_MESAG);		/* HR: fill out the mouse data!!! */
			cancel_evnt_multi(dest_client);
		} else
		{
			dest_client->waiting_pb->intout[0] = 1;
			cancel_evnt_multi(dest_client);
		}

		clnt_buf = (MSG_BUF *)(dest_client->waiting_pb->addrin[0]);
		
		if (!clnt_buf)
		{
			DIAG((D.appl,-1,"WARNING: Invalid target message buffer\n"));
			return;
		}
		
		*clnt_buf = *msg;			/* Fill in the client's message buffer */

		DIAG((D.m,-1,"Send message %s to %s(%d)\n", pmsg(msg->m[0]), dest_client->name, dest_client->pid));
			/* Write success to client's reply pipe to unblock the process */
		Unblock(dest_client, XA_OK, 12);

	} else	/* Create a new entry in the destination client's pending messages list */
	{
		XA_AESMSG_LIST *new_msg = xmalloc(sizeof(XA_AESMSG_LIST),3);

		if (new_msg)
		{
			new_msg->message = *msg;	/* Fill in the new pending list entry with the message */
			new_msg->next = nil;

			if (dest_client->msg)	/* There are already some pending messages */
			{
				XA_AESMSG_LIST *ml = dest_client->msg;
				while (ml->next)
					 ml = ml->next;
				ml->next = new_msg;	/* Append the new message to the list */
			} else	/* First entry in the client's pending message list */
				dest_client->msg = new_msg;
		DIAG((D.m,-1,"Queued message %s for %s(%d)\n", pmsg(msg->m[0]), dest_client->name, dest_client->pid));
		}
	}

	if unlocked(clients)
		Sema_Dn(CLIENTS_SEMA);
}

/* AES internal msgs (All standard) */
global
SendMessage send_app_message /* LOCK lock, XA_WINDOW *w,
      short dest_pid, short msg, short source_pid,
      short mp3, short mp4, short mp5, short mp6, short mp7 */
{
	MSG_BUF m; short *p = m.m;
	*p++ =msg;
	*p++ =source_pid > 0 ? source_pid : C.AESpid;
	*p++ =0;
	*p++ =mp3;
	*p++ =mp4;
	*p++ =mp5;
	*p++ =mp6;
	*p++ =mp7;
	send_a_message(lock, dest_pid, &m);
}

#else
#include "obsolete/app_msg.h"
#endif