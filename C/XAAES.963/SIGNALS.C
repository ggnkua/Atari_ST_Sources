/*
 * XaAES - XaAES Ain't the AES (c) 1992 - 1998 C.Graham
 *                                 1999 - 2003 H.Robbers
 *
 * A multitasking AES replacement for MiNT
 *
 * This file is part of XaAES.
 *
 * XaAES is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * XaAES is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with XaAES; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include <mintbind.h>
#include <signal.h>

#include "xa_types.h"
#include "xa_globl.h"

#include "c_window.h"
#include "xa_codes.h"
#include "signals.h"
#include "xa_clnt.h"
#include "taskman.h"

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
/*		IFDIAG(D.debug_level = 4;)		/* Shutting down always chances of messing up. */
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
					Unblock(parent, XA_OK, 23);
				
				DIAGS(("sending CH_EXIT to %d for %s\n", client->parent, c_owner(client)));

				send_app_message(NOLOCKS, nil, parent,
							CH_EXIT, 0, 0, pid,
							x,       0, 0, 0);
			}
		}

		if (!client->init)		/* HR: Now this is explicitely cleared in XA_client_exit itself (not!! in appl_exit!!) */
			close_client(NOLOCKS, client);		/* HR 230501 */
		else
		{
			/* The client didnt call appl_exit. Tragically died in a accident. */
			DIAGS(("Closing %s, pipe_rd: %d\n", c_owner(client), client->client_end));

			remove_refs(client, false);		/* HR 100701 */
			pending_client_exit(client);	/* HR 230501 */
		}
	}
}

#if 1
/*
 *	Catch CTRL+C and exit gracefully from the kernal loop
 */
global
HandleSIG HandleSIGINT
{
/*	IFDIAG(D.debug_level = 4;)	*/	/* Shutting down always chances of messing up. */
	DIAGS(("shutdown by CtlAltC\n"));
	shutdown(NOLOCKING);
}

/*
 *	Catch CTRL+\ and exit gracefully from the kernal loop
 */
global
HandleSIG HandleSIGQUIT
{
/*	IFDIAG(D.debug_level = 4;)	*/	/* Shutting down always chances of messing up. */
	DIAGS(("shutdown by CtlAlt'\'\n"));
	shutdown(NOLOCKING);
}
#endif