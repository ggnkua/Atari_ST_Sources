/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <UNISTD.H>
#include <FILESYS.H>
#include <OSBIND.H>
#include <MINTBIND.H>
#include <stdio.h>
#include "XA_GLOBL.H"
#include "XA_TYPES.H"
#include "XA_DEFS.H"
#include "XA_CODES.H"
#include "K_DEFS.H"
#include "KERNAL.H"

/* Note: since XA_handler now properly loads the global base register,
	`far' data is no longer needed! <mk> */
/* (Except if the 64 K limit is reached, of course...) */

/* <beta4>
   New approach here - the XaAES.cmd pipe is no longer a global handle
   (there were problems re-opening it after a shutdown), so we have to open it
   especially - this is in fact the only place it's used. Clients introduce themselves
   via the XaAES.cmd pipe, then do everything else via their individual pipes.
  <craig>
*/

char r_pipe_name[50];
char r_fmt[]="u:\\pipe\\XaClnt.%d\0";
short new_client_contrl[]={XA_NEW_CLIENT,0,0,0,0};
short client_exit_contrl[]={XA_CLIENT_EXIT,0,0,0,0};
AESPB new_client_pb;
K_CMD_PACKET new_client_packet;

/*
	Application initialise - appl_init()
	Remember that this executes under the CLIENT pid, not the kernal.
	(Hence the semaphore locking on the routine)
*/
unsigned long XA_appl_init(short clnt_pid, AESPB *pb)
{
	XA_CLIENT *client=Pid2Client(clnt_pid);
	short drv;
	long AES_in_pipe;

	Psemaphore(2,APPL_INIT_SEMAPHORE,-1L);
	
/* In XaAES, AESid==MiNT process id : this makes error tracking easier */
	pb->intout[0]=clnt_pid;

#if EMULATE_AES4_1
	pb->globl[0]=0x0410;		/* Try to emulate AES4.1 */
#else
	pb->globl[0]=0x0140;		/* Try to emulate AES 1.4 (TOS 1.04/1.06) */
								/* (this is Martin's idea - I'm not sure about it myself, 
									so I've made it a compile time option */									
#endif

	pb->globl[1]=-1;			/* Unlimited applications (well, not really) */
	pb->globl[2]=clnt_pid;		/* appid==pid */
	pb->globl[5]=0;
	pb->globl[6]=0;
	pb->globl[7]=0;
	pb->globl[8]=0;
	pb->globl[9]=0;
	pb->globl[10]=display.planes;
	pb->globl[11]=0;
	pb->globl[12]=0;
	pb->globl[13]=display.c_max_h;		/* AES4.0 extensions */
	pb->globl[14]=4;

	client->globl_ptr=pb->globl;		/* Preserve the pointer to the global array */
											/* so we can fill in the resource address later */
	
	if (client->clnt_pipe_rd)
	{
		DIAGS(("client pipe already opened (handle=%d) in appl_init\n",client->clnt_pipe_rd));
		Psemaphore(3,APPL_INIT_SEMAPHORE,0);
		return XAC_DONE;
	}

	AES_in_pipe=Fopen("u:\\pipe\\XaAES.cmd",O_RDWR);

/* Create a new client reply pipe */
	sprintf(r_pipe_name,r_fmt,clnt_pid);
	
	/* For some reason, a pipe created with mode O_RDONLY does *not* go
		away when all users have closed it (or were terminated) - apparently
		a MiNT bug?!?! */
	/* BTW: if *this* end of the pipe was created with O_RDWR, the *other*
		end cannot be O_WRONLY, or strange things will happen when the
		pipe is closed... */
	client->clnt_pipe_rd=Fopen(r_pipe_name,O_CREAT|O_RDWR);	/* Client's end of pipe */
	
	pb->globl[12]=client->clnt_pipe_rd;	/* XaAES extension */

/* Get the client's home directory (where it was started) - we use this later to load
    resource files, etc */
	drv=Dgetdrv();
	client->home_path[0]=(char)drv+'a';
	client->home_path[1]=':';
	client->home_path[2]='\\';
	Dgetcwd(client->home_path+3,drv+1,(short)sizeof(client->home_path)-4);

/* Reset the AES messages pending list for our new application */
	client->msg=NULL;
/* No widgets have action pending on a new app */
	client->widget_active=NULL;
/* Initially, client isn't waiting on any event types */
	client->waiting_for=0;
	client->waiting_pb=NULL;
/* Initial settings for the clients mouse cursor */
	client->client_mouse=ARROW;		/* Default client mouse cursor is an arrow */
	client->client_mouse_form=NULL;

/* Build a 'register new client' packet and send it to the kernal
   - the kernal will respond by opening it's end of the reply pipe ready for use */
	new_client_pb.contrl=new_client_contrl;
	new_client_packet.pid=clnt_pid;				/* client pid */
	new_client_packet.cmd=AESCMD_STD;			/* no reply */
	new_client_packet.pb=&new_client_pb;		/* pointer to AES parameter block */

	Fwrite(AES_in_pipe, sizeof(K_CMD_PACKET), &new_client_packet);	/* Send packet */

	Fclose(AES_in_pipe);

	Psemaphore(3,APPL_INIT_SEMAPHORE,0);

	return XAC_BLOCK;	/* Block the client until the server get's it's act together */
}


/*
	Application Exit
	This also executes under the CLIENT pid.
	This closes the clients end of the reply pipe, and sends a message to the kernal
	to tell it to close it's end as well - the client tidy-up is done at the server 
	end when the XA_CLIENT_EXIT op-code is recieved, not here.
*/
unsigned long XA_appl_exit(short clnt_pid, AESPB *pb)
{
	short *intout=pb->intout;
	XA_CLIENT *client= Pid2Client(clnt_pid);

	intout[0]=clnt_pid;						/* Which process are we? It'll be a client pid */

/* Build a 'client is exiting' packet and send it to the kernal
   - the kernal will respond by closing it's end of the clients reply pipe. */
	new_client_pb.contrl=client_exit_contrl;
	new_client_packet.pid=intout[0];			/* client pid */
	new_client_packet.cmd=AESCMD_STD;			/* no reply */
	new_client_packet.pb=&new_client_pb;		/* pointer to AES parameter block */

	Fwrite(client->clnt_pipe_rd, sizeof(K_CMD_PACKET), &new_client_packet);	/* Send packet */

#if 0
	Fclose(client->clnt_pipe_rd);	/* Close the client end of client reply pipe */
	client->clnt_pipe_rd=0;
#endif

	return XAC_BLOCK;				/* Block the client until the server has closed down it's end of things */
}
