/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

/*
	Main AES trap handler routine
	-----------------------------
	This module replaces the AES trap 2 vector to provide an interface to the
	XaAES pipe based client/server AES, for normal GEM applications.
	
	It works by first creating a pair of XaAES reply pipes for the application
	in response to the appl_init() call, then using these to communicate with the
	AES server kernal. When an AES trap occurs, the handler drops the pointer to the
	parameter block into the XaAES.cmd pipe.
	
	There are then 3 modes that the AES could have been called in.
	
	If standard GEM emulation mode the handler then drops back into user mode and
	blocks whilst reading on the current process's reply pipe. This allows other
	processes to execute whilst XaAES is performing AES functions (the XaAES server
	runs wholely in user mode so it's more MiNT-friendly than MultiTOS). The server
	writes back to the clients reply pipe with the reply when it has serviced
	the command - this unblocks the client which then returns from the exception.
	
	If NOREPLY mode is used, the AES doesn't block the calling process to wait
	for a reply - and indeed, won't generate one.
	
	If NOBLOCK mode is used, the AES doesn't block the calling process - but does
	place the results in the client's reply pipe. The client is then expected to
	handle it's own reply pipe. This allows multiple AES calls to be made without
	blocking a process, so an app could make all it's GEM initialisation calls
	at one go, then go on to do it's internal initialisation before coming back
	to see if the AES has serviced it's requests (less blocking in the client,
	and better multitasking).

	[13/2/96]
	Included Martin Koehling's patches - this nicely does away with the 'far' data
	kludges & register patches I had in before.....

	[18/2/96]
	New timeout stuff to replace the SIGALRM stuff.
*/


#include <OSBIND.H>
#include <MINTBIND.H>
#include <FILESYS.H>
#include <stdio.h>
#include "K_DEFS.H"
#include "HANDLER.H"
#include "XA_DEFS.H"
#include "XA_GLOBL.H"
#include "frm_alrt.h"
#include "XA_CODES.H"
#include "appl_ini.h"
#include "KERNAL.H"

__regargs short handler(unsigned short c, AESPB *pb);

#define AES_MAGIC			12345

static K_CMD_PACKET client_request;

/*
	Trap exception handler - this routine executes under the client applications pid
	- I've semaphore locked any sensitive bits

	NOTE: the keyword `__saveds' causes the compiler to load the global base
	register automatically - no need for `far' data kludges here!!!
*/
far __saveds __regargs short XA_handler(unsigned short c, AESPB *pb)
{
	short clnt_pid=Pgetpid();
	XA_CLIENT *client;
	unsigned long cmd_rtn;
	short rtn_mode;
	unsigned long reply_s;
	short timeout;
	
	client=Pid2Client(clnt_pid);	

	if (Kcall_direct[pb->contrl[0]])	/* Call direct? */
	{

		if ((pb->contrl[0]>=0)&&(pb->contrl[0]<300))
		{
			AESroutine cmd_routine=Ktable[pb->contrl[0]];

			if (cmd_routine)		/* If opcode was implemented, call it */
			{
				cmd_rtn=(*cmd_routine)(clnt_pid,pb);
				rtn_mode=cmd_rtn&0xf;
				
				switch(rtn_mode)
				{
					case XAC_BLOCK:		/* Block indefinitely (like for evnt_mesag) */
						Fread(client->clnt_pipe_rd,sizeof(unsigned long),&cmd_rtn);
						break;
					case XAC_T_TIMEOUT:	/* Block, with a timeout (evnt_timer format)*/
					case XAC_M_TIMEOUT:	/* Block, with a timeout (evnt_multi format)*/
						reply_s=1L<<client->clnt_pipe_rd;
						timeout=(cmd_rtn&XAC_TVAL)>>16;
						
						if (!timeout)
							timeout=1;
							
						cmd_rtn=Fselect(timeout,(long *)&reply_s,NULL,NULL);

						Psemaphore(2,CLIENTS_SEMAPHORE,-1L);
						
						if (!cmd_rtn)	/* timed out */
						{	
							if(client->waiting_for&XAWAIT_MULTI)
							{
								client->waiting_pb->intout[0]=MU_TIMER;	/* evnt_multi() returns MU_TIMER */
							}else{
								client->waiting_pb->intout[0]=1;	/* evnt_timer() always returns 1 */
							}
							client->waiting_for=0;
						}
						
						Psemaphore(3,CLIENTS_SEMAPHORE,0L);

						break;
					case XAC_DONE:		/* Command completed, do nothing & return */
						break;
				}
			}else{
				pb->intout[0]=0;
			}
		}

	}else{		/* Nope, go through the pipes messaging system instead... */

		Psemaphore(2,TRAP_HANDLER_SEMAPHORE,-1L);

		client_request.pid=clnt_pid;	/* Build command packet */
		client_request.cmd=c;
		client_request.pb=pb;

		Fwrite(client->clnt_pipe_rd, (long)sizeof(K_CMD_PACKET), &client_request);	/* Send command packet */

		Psemaphore(3,TRAP_HANDLER_SEMAPHORE,0);

		if (c!=AESCMD_STD) 				/* Unless we are doing standard GEM style AES calls, return  */
			return client->clnt_pipe_rd;	/* here. */

/* OK, here we are in blocking AES call mode (standard GEM) - so we handle the reply pipe */
/* on behalf of the client. */

		Fread(client->clnt_pipe_rd,sizeof(unsigned long),&cmd_rtn);
		
		timeout=cmd_rtn>>16;
		rtn_mode=cmd_rtn&0xf;
		
		switch(rtn_mode)	/* New timeout stuff */
		{
			case XA_OK:			/* Standard stuff, operation completed, etc */
			case XA_ILLEGAL:
			case XA_UNIMPLEMENTED:
				break;
			case XA_T_WAIT:		/* Ahh - block again, with a timeout */
			case XA_M_WAIT:
				{

					reply_s=1L<<client->clnt_pipe_rd;
					
					if (!timeout)
						timeout=1;
					
					cmd_rtn=Fselect(timeout,(long *)&reply_s,NULL,NULL);
					
					Psemaphore(2,CLIENTS_SEMAPHORE,-1L);

					if (!cmd_rtn)	/* timed out */
					{
						if (client->waiting_for&XAWAIT_MULTI)
						{
							client->waiting_pb->intout[0]=MU_TIMER;	/* evnt_multi() returns MU_TIMER */
						}else{
							client->waiting_pb->intout[0]=1;	/* evnt_timer() always returns 1 */
						}
						
						client->waiting_for=0;
						
					}else{	/* Second dummy read to unblock */
						Fread(client->clnt_pipe_rd,sizeof(unsigned long),&cmd_rtn);
					}
					
					Psemaphore(3,CLIENTS_SEMAPHORE,0L);

				}
				break;
		}
	}
	
	return AES_MAGIC;
}

extern void asm_hook_into_vector(void);

void hook_into_vector(void)
{
	void *old_ssp;

	old_ssp=(void *)Super((void*)NULL);		/* Enter Supervisor mode*/
	
	asm_hook_into_vector();
	
	/* We want to do this with task switching disabled in order
		to prevent a possible race condition... */
	/* Dummy access to the critical error handler (make Selectric,
		FSELECT and other AES extenders happy...) */
	(void)Setexc(0x101, (void*)-1L);
	Super(old_ssp);					/* Back to User Mode */
}

#if 0
extern void * far old_trap2_vector; /* defined in a_handler.s (TEXT segment!) */
/*
	HOOK INTO THE AES TRAP VECTOR
	- new version [13/2/96] by Martin Koehling.
*/
void hook_into_vector(void)
{
	void *old_ssp;

#if 0
	printf("- XaAES hooking into trap vector %d at location %lx\n",
			AES_TRAP, (0x20+AES_TRAP)*4L);
#endif

	old_ssp=(void *)Super((void*)NULL);		/* Enter Supervisor mode*/
	/* We want to do this with task switching disabled in order
		to prevent a possible race condition... */
	old_trap2_vector = Setexc(0x20+AES_TRAP, (void*)handler) ;
	/* Dummy access to the critical error handler (make Selectric,
		FSELECT and other AES extenders happy...) */
	(void)Setexc(0x101, (void*)-1L);
	Super(old_ssp);					/* Back to User Mode */
}
#endif

typedef struct xbra {
	long xbra_id;
	long app_id;
	void (*oldvec)();
} XBRA;

/* New unhook, pays attention to XBRA unhook procedure */
void unhook_from_vector(void)
{
	void *old_ssp;
	XBRA *rx;
	long vecadr, *stepadr;
 
 	vecadr=(long)Setexc(0x20+AES_TRAP,(void*)-1L); 	
 	rx=(XBRA*)(vecadr-sizeof(XBRA));

	old_ssp=(void*)Super((void*)NULL);

	if ((rx->xbra_id=='XBRA')&&(rx->app_id=='XaAE'))
	{
		Setexc(0x20+AES_TRAP, rx->oldvec);
		return;
	}
	
	stepadr=(long*)&rx->oldvec;
	rx=(XBRA*)((long)rx->oldvec - sizeof(XBRA));
	while(rx->xbra_id=='XBRA')
	{
		if (rx->app_id=='XaAE')
		{
			*stepadr=(long)rx->oldvec;
			break;
		}
		stepadr=(long*)&rx->oldvec;
		rx=(XBRA*)((long)rx->oldvec - sizeof(XBRA));
	}
	Super(old_ssp);
}
