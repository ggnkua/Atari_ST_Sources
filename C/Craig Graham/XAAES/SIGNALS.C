/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <MINTBIND.H>
#include <OSBIND.H>
#include <SIGNAL.H>
#include <VDI.H>
#include "c_window.h"
#include "k_defs.h"
#include "xa_types.h"
#include "xa_globl.h"
#include "xa_defs.h"
#include "xa_codes.h"
#include "new_clnt.h"
#include "signals.h"
#include "messages.h"

/*
	SIGNAL HANDLERS
*/

#define WIFSTOPPED(x)	(((int)((x)&0xff)==0x7f)&&((int)(((x)>>8)&0xff)!=0))
#define WSTOPSIG(x)		((int)(((x)>>8)&0xff))

extern AESPB dead_client_pb;
extern short dead_exit_contrl[];

/*
	Spot dead children
*/
void __saveds HandleSIGCHLD(long signo)
{
	K_CMD_PACKET dead_client_packet;
	long r;
	short pid;
	XA_CLIENT *client,*parent;
	
	r=Pwait3(1,NULL);
	while(r)
	{
		pid=(r>>16)&0xffff;
		client=Pid2Client(pid);
		
		if (client->clnt_pipe_rd)
		{

			dead_client_pb.contrl=dead_exit_contrl;	/* If client is dead, send ourselves a message to clean up.... */
			dead_client_packet.pid=pid;				/* client pid */
			dead_client_packet.cmd=AESCMD_NOREPLY;	/* no reply */
			dead_client_packet.pb=&dead_client_pb;	/* pointer to AES parameter block */
			XA_client_exit(pid,&dead_client_pb);	/* Run the application exit cleanup 
													-gone back to calling directly, as the global command pipe has gone away */

			Fclose(client->clnt_pipe_wr);			/* Close the kernal end of client reply pipe */
			client_handle_mask&=~(1L<<client->clnt_pipe_wr);

			client->clnt_pipe_wr=client->clnt_pipe_rd=0;
		}

		if (client->parent!=AESpid)					/* Send a CH_EXIT message if the client */
		{											/* is not an AES child of the XaAES system */
			unsigned long retv=XA_OK;

			DIAGS(("sending CH_EXIT\n"));

			parent=Pid2Client(client->parent);
			if (parent->waiting_for&XAWAIT_CHILD)	/* Wake up the parent if it's waiting */
			{
				Fwrite(parent->clnt_pipe_wr, (long)sizeof(unsigned long),&retv);
			}
			
			send_app_message(client->parent, CH_EXIT, AESpid, pid, r&0xFFFFL, 0, 0, 0);
		
			client->parent=AESpid;
			
		}
		
		r=Pwait3(1,NULL);
	}
}

/*
	Catch CTRL+C and exit gracefully from the kernal loop
*/
void __saveds HandleSIGINT(long signo)
{
	shutdown=TRUE;
}
