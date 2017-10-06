/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <mintbind.h>
#include <osbind.h>
#include <signal.h>

#include "xa_types.h"
#include "xa_globl.h"

#include "c_window.h"
#include "xa_codes.h"
#include "signals.h"
#include "new_clnt.h"

/*
 *	SIGNAL HANDLERS
 */

#define WIFSTOPPED(x)	(((int)((x) & 0xff) == 0x7f) && ((int)(((x) >> 8) & 0xff) != 0))
#define WSTOPSIG(x)		((int)(((x) >> 8) & 0xff))

/*
 * Spot dead children
 */
global
HandleSIG HandleSIGCHLD /* (long signo) */
{
	long r;
	short pid,x;
	XA_CLIENT *client,*parent;

	if (C.shutdown)		/* Psignal(x,0L) problems. */
	{
/*		IFDIAG(D.all.point = 3;)		/* Shutting down always chances of messing up. */
*/		DIAGS(("SIGCHLD *AND* shutdown\n"));
		return;
	}

	while((r = Pwaitpid(-1, 1, nil)) > 0)	/* ENOENT (See MiNT sources) */
	{
		pid = r >> 16;
		x = r;

		client = Pid2Client(pid);

		DIAGS(("Pwaitpid(%d) for '%s'(%d), code %d(0x%04x)\n",Pgetpid(), client ? client->proc_name : "?", pid,x,x));

		if (!client)		/* Not a AES client,  */
			continue;

		if (client->parent != C.AESpid)				/* Send a CH_EXIT message if the client */
		{											/* is not an AES child of the XaAES system */
			parent = Pid2Client(client->parent);
			
			if (parent and parent->client_end)  	/* HR: is the parent a active AES client? */
			{
				if (parent->waiting_for & XAWAIT_CHILD)		/* Wake up the parent if it's waiting */
					Unblock(parent, XA_OK, 13);
				
				DIAGS(("sending CH_EXIT to %d for '%s'(%d)\n", client->parent, client->proc_name, client->pid));

				send_app_message(NOLOCKS, nil, client->parent, CH_EXIT, C.AESpid, pid, x, 0, 0, 0);
			}
		}

		if (!client->init)		/* HR: Now this is explicitely cleared in XA_client_exit itself (not!! in appl_exit!!) */
			close_client(NOLOCKS, client);		/* HR 230501 */
		else
		{
			/* The client didnt call appl_exit. Tragically died in a accident. */
			DIAGS(("Closing %s(%d), pipe_rd: %d\n", client->proc_name, pid, client->client_end));
#if 0
		/* - Gone back to calling directly, as the global command pipe has gone away */
			/* HR: 230501 cant do this here! This code interrupts operation on structures that cannot
			       be semaphore locked (This code runs under XaAES's pid!!!!!!!!!! */
			XA_client_exit(NOLOCKS, client, nil);	/* Run the application exit cleanup */
#else
			remove_refs(client, false);		/* HR 100701 */
			pending_client_exit(client);	/* HR 230501 */
#endif
		}
	}
}

/*
 *	Catch CTRL+C and exit gracefully from the kernal loop
 */
global
HandleSIG HandleSIGINT
{
/*	IFDIAG(D.all.point = 3;)		/* Shutting down always chances of messing up. */
*/	DIAGS(("shutdown by CtlAltC\n"));
	C.shutdown = true;
}

/*
 *	Catch CTRL+\ and exit gracefully from the kernal loop
 */
global
HandleSIG HandleSIGQUIT
{
/*	IFDIAG(D.all.point = 3;)		/* Shutting down always chances of messing up. */
*/	DIAGS(("shutdown by CtlAlt'\'\n"));
	C.shutdown = true;
}
