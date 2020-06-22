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
	XaAES's current appl_write() only works for standard 16 byte messages
*/
unsigned long XA_appl_write(short clnt_pid, AESPB *pb)
{
	XA_AESMSG_LIST *new_msg,*ml;
	XA_CLIENT *dest_client;
	char *clnt_buf;
	unsigned long retv=XA_OK;
	short dest_id=pb->intin[0];
	short msg_len=pb->intin[1],f;
	char *msg=(char*)pb->addrin[0];

	DIAGS(("appl_write():dest=%d,msg_len=%d,msg=%lx\n",dest_id,msg_len,msg));
	
	pb->intout[1]=0;
	
	if (dest_id==AESpid) 	/* Just a precaution - we don't want to send messages to ourselves..... */
		return XAC_DONE;

	if (msg_len>16)
		return XAC_DONE;

	dest_client=Pid2Client(dest_id);

	if (!dest_client)
	{
		DIAGS(("WARNING: Invalid target pid [%d] for appl_write()\n",dest_id));
		return XAC_DONE;
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
		
		clnt_buf=(char*)(dest_client->waiting_pb->addrin[0]);
		for(f=0; f<msg_len; f++)
			clnt_buf[f]=msg[f];			/* Fill in the clients message buffer */

		Fwrite(dest_client->clnt_pipe_wr, (long)sizeof(unsigned long),&retv);	/* Write success to clients reply pipe to unblock the process */
	}else{	/* Create a new entry in the destination client's pending messages list */
		new_msg=(XA_AESMSG_LIST*)malloc(sizeof(XA_AESMSG_LIST));
		
		if (new_msg)
		{
			pb->intout[1]=1;

			clnt_buf=(char*)new_msg->message;
			
			for(f=0; f<msg_len; f++)
				clnt_buf[f]=msg[f];			/* Fill in the new pending list entry with the message */
		
			new_msg->next=NULL;

			if (dest_client->msg)	/* There are already some pending messages */
			{
				for(ml=dest_client->msg; ml->next; ml=ml->next);
				ml->next=new_msg;	/* Append the new message to the list */
			}else{					/* First entry in the clients pending message list */
				dest_client->msg=new_msg;
			}

		}
	}
	
	Psemaphore(3,CLIENTS_SEMAPHORE,0L);
	
	return XAC_DONE;

}
