/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <MINTBIND.H>
#include <OSBIND.H>
#include <memory.h>
#include "XA_DEFS.H"
#include "XA_TYPES.H"
#include "XA_GLOBL.H"
#include "K_DEFS.H"
#include "EVNT_MUL.H"

/*
	Send an AES message to a client application
*/
void send_app_message(short dest_id, short mesg, short source_id, short a, short b, short c, short d, short e)
{
	XA_AESMSG_LIST *new_msg,*ml;
	XA_CLIENT *dest_client;
	short *clnt_buf;
	unsigned long retv=XA_OK;
	
	if (dest_id==AESpid) 	/* Just a precaution - we don't want to send messages to ourselves..... */
		return;

	dest_client=Pid2Client(dest_id);

	if (!dest_client)
	{
		DIAGS(("WARNING: Invalid target pid [%d] for send_app_message()\n",dest_id));
		return;
	}

	Psemaphore(2,CLIENTS_SEMAPHORE,-1L);
	
	if (dest_client->waiting_for&XAWAIT_MESSAGE)	/* Is the dest client waiting for a message at the moment? */
	{

		if (dest_client->waiting_for&XAWAIT_MULTI)	/* If the client is waiting on a multi, the response is  */
		{												/* slightly different to the evnt_mesag() response. */

			dest_client->waiting_pb->intout[0]=MU_MESAG;
			cancel_evnt_multi(dest_id);
		}else{
		
			dest_client->waiting_pb->intout[0]=1;
			dest_client->waiting_for=0;	/* flag client as not waiting for anything */
		}

		clnt_buf=(short*)(dest_client->waiting_pb->addrin[0]);
		
		if (!clnt_buf)
		{
			DIAGS(("WARNING: Invalid target message buffer\n"));
			return;
		}
		
		clnt_buf[0]=mesg;			/* Fill in the clients message buffer */
		clnt_buf[1]=source_id;
		clnt_buf[2]=0;
		clnt_buf[3]=a;
		clnt_buf[4]=b;
		clnt_buf[5]=c;
		clnt_buf[6]=d;
		clnt_buf[7]=e;

		Fwrite(dest_client->clnt_pipe_wr, (long)sizeof(unsigned long),&retv);	/* Write success to clients reply pipe to unblock the process */
	}else{	/* Create a new entry in the destination client's pending messages list */
		new_msg=(XA_AESMSG_LIST*)malloc(sizeof(XA_AESMSG_LIST));
		
		if (new_msg)
		{
		
			new_msg->message[0]=mesg;			/* Fill in the new pending list entry with the message */
			new_msg->message[1]=source_id;
			new_msg->message[2]=0;
			new_msg->message[3]=a;
			new_msg->message[4]=b;
			new_msg->message[5]=c;
			new_msg->message[6]=d;
			new_msg->message[7]=e;
			new_msg->next=NULL;

			if (dest_client->msg)	/* There are already some pending messages */
			{

				for(ml=dest_client->msg; ml->next; ml=ml->next);
				ml->next=new_msg;	/* Append the new message to the list */
		
			}else{	/* First entry in the clients pending message list */
			
				dest_client->msg=new_msg;
		
			}
		}
	}
	
	Psemaphore(3,CLIENTS_SEMAPHORE,0L);
	
}
