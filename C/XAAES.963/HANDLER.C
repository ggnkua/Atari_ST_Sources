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

/*
 *	Main AES trap handler routine
 *	-----------------------------
 *	This module replaces the AES trap 2 vector to provide an interface to the
 *	XaAES pipe based client/server AES, for normal GEM applications.
 *	
 *	It works by first creating a pair of XaAES reply pipes for the application
 *	in response to the appl_init() call, then using these to communicate with the
 *	AES server kernal. When an AES trap occurs, the handler drops the pointer to the
 *	parameter block into the XaAES.cmd pipe.
 *	
 *	There are then 3 modes that the AES could have been called in.
 *	
 *	If standard GEM emulation mode the handler then drops back into user mode and
 *	blocks whilst reading on the current process's reply pipe. This allows other
 *	processes to execute whilst XaAES is performing AES functions (the XaAES server
 *	runs wholely in user mode so it's more MiNT-friendly than MultiTOS). The server
 *	writes back to the clients reply pipe with the reply when it has serviced
 *	the command - this unblocks the client which then returns from the exception.
 *	
 *	If NOREPLY mode is used, the AES doesn't block the calling process to wait
 *	for a reply - and indeed, won't generate one.
 *	
 *	If NOBLOCK mode is used, the AES doesn't block the calling process - but does
 *	place the results in the client's reply pipe. The client is then expected to
 *	handle it's own reply pipe. This allows multiple AES calls to be made without
 *	blocking a process, so an app could make all it's GEM initialisation calls
 *	at one go, then go on to do it's internal initialisation before coming back
 *	to see if the AES has serviced it's requests (less blocking in the client,
 *	and better multitasking).
 *
 *	[13/2/96]
 *	Included Martin Koehling's patches - this nicely does away with the 'far' data
 *	kludges & register patches I had in before.....
 *
 *	[18/2/96]
 *	New timeout stuff to replace the SIGALRM stuff.
 *
 *	[18/12/00]
 *  HR: The 4 functions that must always be called direct, and hence run under
 *  the client pid are moved to this file. This way it is easier to detect any
 *  data area's that are shared between the server and the client processes.
 *  These functions are: appl_init, appl_exit, appl_yield and wind_update.
 *
 *  [05/12/01]
 *  Unclumsified the timeout value passing.
 */

#include <mintbind.h>
#include <fcntl.h>
#include <ctype.h>			/* We use the version without macros!! */
#include <string.h>

#include "xa_types.h"
#include "xa_globl.h"

#include "handler.h"
#include "xa_codes.h"
#include "xa_evnt.h"
#include "xa_clnt.h"
#include "taskman.h"

#define AES_MAGIC			12345

global
far SHARED S;				/* Area's shared between server and client, subject to locking. */

/*
 * Note: since XA_handler now properly loads the global base register,
 *	`far' data is no longer needed! <mk>
 * (Except if the 64 K limit is reached, of course...)
 */

/* <beta4>
 *  New approach here - the XaAES.cmd pipe is no longer a global handle
 * (there were problems re-opening it after a shutdown), so we have to open it
 * especially - this is in fact the only place it's used. Clients introduce themselves
 * via the XaAES.cmd pipe, then do everything else via their individual pipes.
 * <craig>
 */


/*
 *	Application initialise - appl_init()
 *	Remember that this executes under the CLIENT pid, not the kernal.
 *	(Hence the semaphore locking on the routine)
 */

/* HR 230301:  new_client_contrl
               client_exit_contrl
               new_client_packet
               new_client_pb;
   moved these areas to the client structure   !!!!!!!
   Solved many problems with GEM-init of Ulrich Kayser.
   Solved problems with proper shutdown. (Many apps issue appl_exit concurrently.
   Sigh of relief. :-)
*/


global
AES_function XA_appl_init  /* LOCK lock, XA_CLIENT *client, AESPB *pb */
{
	int drv,pid = Pgetpid();
	long AES_in;		/* HR removed r */

	CONTROL(0,1,0)

	if unlocked(appl)
	{
		#if DEBUG_SEMA
			DIAGS(("For %d:\n", pid));
		#endif
		Sema_Up(appl);
	}

/* HR: dynamic client pool */
	if (!client)			/* must be a foreign client. */
	{
		if unlocked(clients)
		{
			#if DEBUG_SEMA
				DIAGS(("For %d:\n", pid));
			#endif
			Sema_Up(clients);
		}

		IFDIAG (if (D.debug_file > 0)
			       Fforce(1, D.debug_file);)			/* Redirect console output */

		/* New client, but not spawned by XaAES's shell_write */
		client = NewClient(pid);
		if (client)
		{
			strcpy(client->proc_name, "FOREIGN ");
			/* We could get the proc_name I suppose by reading u:\proc. */
			client->parent = Pgetppid();
			client->type = APP_APPLICATION;
	DIAG((D_appl,client,"Alloc client; Foreign %d\n", client->pid));
		}
		if unlocked(clients)
		{
			#if DEBUG_SEMA
				DIAGS(("For %d:\n", pid));
			#endif
			Sema_Dn(clients);
		}
	}

DIAG((D_appl,client,"appl_init for %d\n", client->pid));

/* In XaAES, AESid == MiNT process id : this makes error tracking easier */
/* HR 150501:
   At last give in to the fact that it is a struct, NOT an array */
	pb->intout[0] = -1;
	pb->globl->version = 0x0401;		/* Emulate AES4.1 */
	pb->globl->count = -1;				/* Unlimited applications (well, not really) HR: only 32??? */
	pb->globl->id = client->pid;		/* appid==pid */
	pb->globl->pprivate = nil;
	pb->globl->ptree = nil;	/* Atari: pointer to pointerarray of trees in rsc. */
	pb->globl->rshdr = nil;	/* Pointer to resource header. */
	pb->globl->nplanes = screen.planes;
	pb->globl->res1 = 0;
	pb->globl->client_end = 0;
	pb->globl->c_max_h = screen.c_max_h;	/* AES4.0 extensions */
	pb->globl->bvhard = 4;

	client->globl_ptr = pb->globl;		/* Preserve the pointer to the global array */
											/* so we can fill in the resource address later */
	AES_in = Fopen(C.cmd_name, O_RDWR);
	DIAG((D_appl,client,"Open command_pipe %s to %ld\n",C.cmd_name,AES_in));
	if (AES_in > 0)
	{
		pb->intout[0] = client->pid;

	/* Create a new client reply pipe */
		sdisplay(client->app.pipe, "u:" sbslash "pipe" sbslash "XaClnt.%d", client->pid);
		
		/* For some reason, a pipe created with mode O_RDONLY does *not* go
			away when all users have closed it (or were terminated) - apparently
			a MiNT bug?!?! */
		/* BTW: if *this* end of the pipe was created with O_RDWR, the *other*
			end cannot be O_WRONLY, or strange things will happen when the
			pipe is closed... */
	
		/* HR: dynamic client pool: This is normal, end occurs when a program issues
				multiple pairs of appl_init/exit, which many old atari programs do. */
		if (!client->client_end)
		{
			client->client_end = Fopen(client->app.pipe, O_CREAT|O_RDWR);	/* Client's end of pipe */
	
			DIAG((D_appl, nil,"pipe '%s' is client_end %d\n", client->app.pipe, client->client_end));
		}
	
		pb->globl->client_end = client->client_end;	/* XaAES extension */
	
	/* Get the client's home directory (where it was started) - we use this later to load
	   resource files, etc */
		if (!*client->home_path)		/* HR: else already filled out by launch() */
		{
			drv = Dgetdrv();
			client->home_path[0] = (char)drv + 'A';
			client->home_path[1] = ':';
		#if 1
			Dgetcwd(client->home_path + 2, drv + 1, sizeof(client->home_path) - 3);
		#else  /* HR: ??? */
			client->home_path[2] = bslash;
			Dgetcwd(client->home_path + 3, drv + 1, sizeof(client->home_path) - 4);
		#endif
			DIAG((D_appl,client,"[1]Client %d home path = '%s'\n",client->pid,client->home_path));
		} else
		{
			DIAG((D_appl,client,"[2]Client %d home path = '%s'\n",client->pid,client->home_path));
		}

	/* Reset the AES messages pending list for our new application */
		client->msg = nil;
	/* Initially, client isn't waiting on any event types */
		cancel_evnt_multi(client,0);
	/* Initial settings for the clients mouse cursor */
		client->mouse = ARROW;		/* Default client mouse cursor is an arrow */
		client->mouse_form = nil;
		client->save_mouse      = client->mouse;	/* HR 100302 */
		client->save_mouse_form = client->mouse_form;

	/* Build a 'register new client' packet and send it to the kernal
	   - The kernal will respond by opening its end of the reply pipe ready for use */
		client->app.ctrl[0] = XA_NEW_CLIENT;
		client->app.pb.contrl = client->app.ctrl;
		client->app.packet.pid = client->pid;			/* Client pid */
		client->app.packet.cmd = AESCMD_STD;			/* No reply */
		client->app.packet.pb = &client->app.pb;		/* Pointer to AES parameter block */

	/* HR removed r = ... */
	
		DIAG((D_appl,client,"Send command %d to %ld\n",client->app.ctrl[0],AES_in));
		Fwrite(AES_in, sizeof(K_CMD_PACKET), &client->app.packet);	/* Send packet */
		Fclose(AES_in);
		DIAG((D_appl,client,"%ld written & closed\n",AES_in));
	}

	if unlocked(appl)
	{
		#if DEBUG_SEMA
			DIAGS(("For %d:\n", pid));
		#endif
		Sema_Dn(appl);
	}

	return XAC_BLOCK;	/* Block the client until the server get's it's act together */
}


/*
 *	Application Exit
 *	This also executes under the CLIENT pid.
 *	This closes the clients end of the reply pipe, and sends a message to the kernal
 *	to tell it to close its end as well - the client tidy-up is done at the server 
 *	end when the XA_CLIENT_EXIT op-code is recieved, not here.
 */
global
AES_function XA_appl_exit	/* LOCK lock, XA_CLIENT *client, AESPB *pb */
{
	CONTROL(0,1,0)

DIAG((D_appl,client,"appl_exit for %d client_end %d\n", client->pid, client->client_end));

	pb->intout[0] = client->pid;						/* Which process are we? It'll be a client pid */

	if (strnicmp(client->proc_name,"wdialog",7) == 0)
		return XAC_DONE;	
	
/* Build a 'client is exiting' packet and send it to the kernal
   - The kernal will respond by closing its end of the clients reply pipe. */
	client->app.ctrl[0] = XA_CLIENT_EXIT;
	client->app.pb.contrl = client->app.ctrl;
	client->app.packet.pid = pb->intout[0];			/* Client pid */
	client->app.packet.cmd = AESCMD_STD;			/* No reply */
	client->app.packet.pb = &client->app.pb;		/* Pointer to AES parameter block */

	Fwrite(client->client_end, sizeof(K_CMD_PACKET), &client->app.packet);	/* Send packet */

#if 0		/* HR: indeed, this should not be done here, because a Fread on that handle
                           is still needed to achieve the blocking. ;-) */
	Fclose(client->client_end);
	client->client_end = 0;
#endif

#if 1
 	return XAC_BLOCK;
#else
	return XAC_EXIT;				/* Block the client until the server has closed down it's end of things
									   HR 111201: and then close the clients end.
									              the return is maintained to cleanup the stack. */
#endif
}

/*
 * Free timeslice.		Runs (of course) under the clients pid.
 */
AES_function XA_appl_yield
{
	CONTROL(0,1,0)
	
	Syield();
	
	pb->intout[0] = 1;		/* OK */
	return XAC_DONE;

}

#define	EACCESS	36					/* Access denied */

/*
 * Wind_update handling
 *
 **  XA_wind_update runs under the client pid.
 *
 * This handles locking for the update and mctrl flags.
 * !!!!New version - uses semphores for locking...
 */

global
bool lock_screen(XA_CLIENT *client, long time_out, G_i *ret, int which)		/* HR 050201: internal function. */
{
	DIAG((D_sema, nil,"[%d]lock_screen for %s, state: %d for %d\n", which, c_owner(client), S.update_cnt, S.update_lock));
	if (S.update_lock == client->pid)	/* Already owning it? */
		S.update_cnt++ ;
	else
	{
		long r;
		DIAG((D_sema, nil,"Sema U up\n"));
		r = Psemaphore(2, UPDATE_LOCK, time_out);
		if (r == -EACCESS)
		{
			DIAG((D_sema, nil,"    -36\n"));
			if (ret)
				*ret = 0;		/* Screen locked by different process */
			return false;
		}
		else if (r < -1)
		{
			DIAG((D_sema, nil,"    -1\n"));
			return false;
		}
		else
		{
			S.update_lock = client->pid,
			S.update_cnt = 1;
			DIAG((D_sema, nil,"    %ld\n", r));
		}
	}

	return true;
}

global
long unlock_screen(XA_CLIENT *client, int which)		/* HR 050201: internal function. */
{
	long r;
	DIAG((D_sema, nil,"[%d]unlock_screen for %s, state: %d for %d\n", which, c_owner(client), S.update_cnt, S.update_lock));
	if (S.update_lock == client->pid)
	{
		S.update_cnt--;
		if (S.update_cnt == 0)
		{
			r = Psemaphore(3,UPDATE_LOCK,0);
			S.update_lock = 0;
			client->fmd.lock = false;	/* HR 250602 */
			DIAG((D_sema, nil,"Sema U down\n"));
		}
	}
	return r;
}

global
bool lock_mouse(XA_CLIENT *client, long time_out, G_i *ret, int which)		/* HR 081102: internal function. */
{
	DIAG((D_sema, nil,"[%d]lock_mouse for %s, state: %d for %d\n", which, c_owner(client), S.mouse_cnt, S.mouse_lock));
	if (S.mouse_lock == client->pid)	/* Already owning it? */
		S.mouse_cnt++ ;
	else
	{
		long r;
		DIAG((D_sema, nil,"Sema M up\n"));
		r = Psemaphore(2, MOUSE_LOCK, time_out);
		if (r == -EACCESS)
		{
			DIAG((D_sema, nil,"    -36\n"));
			if (ret)
				*ret = 0;		/* Mouse locked by different process */
			return false;
		}
		else if (r < 0)
		{
			DIAG((D_sema, nil,"    -1\n"));
			return false;
		}
		else
		{
			S.mouse_lock = client->pid;
			S.mouse_cnt = 1 ;
			DIAG((D_sema, nil,"    %ld\n", r));
		}
	}

	return true;
}

global
long unlock_mouse(XA_CLIENT *client, int which)		/* HR 081102: internal function. */
{
	long r;
	DIAG((D_sema, nil,"[%d]unlock_mouse for %s, state: %d for %d\n", which, c_owner(client), S.mouse_cnt, S.mouse_lock));
	if (S.mouse_lock == client->pid)
	{
		S.mouse_cnt--;
		if (S.mouse_cnt == 0)
		{
			S.mouse_lock = 0;
			r = Psemaphore(3,MOUSE_LOCK,0);
			client->fmd.lock = false;	/* HR 311002 */
			DIAG((D_sema, nil,"Sema M down\n"));
		}
	}
	return r;
}

global
AES_function XA_wind_update	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	G_i op = pb->intin[0];
	long time_out = (op & 0x100) ? 0L : -1L;		/* Test for check-and-set mode */
	IFDIAG(long r = 0;)

	CONTROL(1,1,0)	

	DIAG((D_sema, nil,"XA_wind_update for %s %s\n", c_owner(client), time_out ? "" : "RESPONSE"));
	
	pb->intout[0] = 1;

	switch(op&0xff)
	{
	case BEG_UPDATE:				/* Grab the update lock */
		DIAG((D_sema, nil,">> Sema U: lock %d, cnt %d\n", S.update_lock,S.update_cnt));
		lock_screen(client, time_out, pb->intout, 1);
		client->fmd.lock = true;	/* HR 250602 */
		break;
	case END_UPDATE:
		IFDIAG(r = )
		unlock_screen(client, 1);
		DIAG((D_sema, nil,"<< Sema U: lock %d, cnt %d r:%ld\n", S.update_lock,S.update_cnt,r));
		break;
	case BEG_MCTRL:					/* Grab the mouse lock */
		DIAG((D_sema, nil,">> Sema M: lock %d, cnt %d\n", S.mouse_lock,S.mouse_cnt));
		lock_mouse(client, time_out, pb->intout, 1);
		client->fmd.lock = true;	/* HR 311002 */
		break;
	case END_MCTRL:
		IFDIAG(r = )
		unlock_mouse(client, 1);
		DIAG((D_sema, nil,"<< Sema M: lock %d, cnt %d r:%ld\n", S.mouse_lock,S.mouse_cnt,r));
		break;
	default:
		DIAG((D_sema, nil,"WARNING! Invalid opcode for wind_update: 0x%04x\n", op));
	}
	return XAC_DONE;
}

static
void timer_intout(G_i *o)	/* HR */
{
	vq_mouse(C.vh, o+3, o+1, o+2);
	vq_key_s(C.vh, o+4);

	o[0] = MU_TIMER;
	o[5] = 0;
	o[6] = 0;
}

extern XA_FTAB Ktab[KtableSize];		/* The main AES kernal command jump table */

static
XA_CLIENT *Sema_Pid2Client(LOCK lock, int clnt_pid)
{
	XA_CLIENT *client;
#if DEBUG_SEMA
	DIAGS(("For %d:\n", clnt_pid));
#endif
	Sema_Up(clients);	/* HR: wait until the client_pool is consistently updated */
	client = Pid2Client(clnt_pid);
#if DEBUG_SEMA
	DIAGS(("For %d:\n", clnt_pid));
#endif
	Sema_Dn(clients);	/* HR */
	return client;
}

/*
 *	Trap exception handler
 *	- This routine executes under the client application's pid
 *	- I've semaphore locked any sensitive bits
 *
 *	NOTE: the keyword `__saveds' causes the compiler to load the global base
 *	register automatically - no need for `far' data kludges here!!!
 */

global
far __saveds __regargs G_i XA_handler(G_u c, AESPB *pb)
{
	LOCK lock = NOLOCKS;
	int clnt_pid = Pgetpid();		/* We must know who we are so we can get our client structure. */
	XA_CLIENT *client;
	unsigned long cmd_rtn;
	unsigned long reply_s;
	int cmd;
	
	if (!pb)		/* HR: let the client bomb out */
	{
		DIAGS(("No Parameter Block!!!! pid %d\n",clnt_pid));
		return AES_MAGIC;
	}

	if (clnt_pid == C.AESpid)
	{
		DIAGS(("XA_handler for XaAES!!?? pid %d\n",C.AESpid));
		pb->intout[0] = 0;
		return AES_MAGIC;
	}

	cmd = pb->contrl[0];

	if (   cmd == XA_NEW_CLIENT		/* HR: Only need this semaphore immediately after NewClient() */
		or cmd == XA_APPL_INIT
	   )	  
		client = Sema_Pid2Client(lock, clnt_pid);		/* HR 071201 */
	else
		client = Pid2Client(clnt_pid);

/* HR 090901: default paths are kept per process by MiNT ?? */
/*            so we need to get them here when we run under the process id. */
	if (client)
		if (   cmd == XA_RSRC_LOAD
		    or cmd == XA_SHELL_FIND
		   )
		{
			client->xdrive = Dgetdrv();
			Dgetpath(client->xpath,0);
		}

	if ((cmd >= 0) and (cmd < KtableSize))	/* HR: better check this first */
	{
		if (    (   cfg.fsel_cookie
		         or cfg.no_xa_fsel         )
		    and (   cmd == XA_FSEL_INPUT
		         or cmd == XA_FSEL_EXINPUT )
		    )
		{
DIAG((D_fsel,client,"Redirected fsel call: %d\n", clnt_pid));
			return -1;		/* This causes call via the old vector */
		}

		if (   Ktab[cmd].d				/* Call direct? */
#if NOSEMA_CALL_DIRECT
		    or (Ktab[cmd].p&NO_SEMA)
#endif
		   )
		{
			AES_function *cmd_routine = Ktab[cmd].f;

			IFDIAG (extern char *op_code_names[];)
			DIAG((D_trap,client,">>DIRECT: pid=%d, %s[%d] @%lx\n", clnt_pid, op_code_names[cmd], cmd, &Ktab[cmd].d));

			if (cmd_routine)			/* If opcode was implemented, call it */
			{
			/* This is now done only once per AES call */
			
/* HR: The root of all locking under client pid. */
#if USE_CALL_DIRECT
				LOCK lock = cfg.direct_call ? NOLOCKS : (winlist|envstr);

/* The pending sema is only needed if the evnt_... functions are called direct. */
				if (!Ktab[XA_EVNT_MULTI].d)
					lock |= pending;
#else

				LOCK lock = winlist|envstr|pending;		/* HR: how about this? It means that these
	                                   semaphores are not needed and are effectively skipped.         */
#endif
				vq_mouse(C.vh, &button.b, &button.x, &button.y);
				vq_key_s(C.vh, &button.ks);

				if (Ktab[cmd].p & LOCKSCREEN)
					lock_screen(client, -1, nil, 2);		/* HR 210202 */

/* ---->  */	cmd_rtn = (*cmd_routine)(lock, client, pb);

				
				if (Ktab[cmd].p & LOCKSCREEN)
					unlock_screen(client, 2);		/* HR 210202 */

				if (!client)
				{
					if (cmd == XA_APPL_INIT)
						client = Sema_Pid2Client(lock, clnt_pid);		/* HR 071201 */
					if (!client)
						return AES_MAGIC;
				}

				switch(cmd_rtn)
				{
				case XAC_DONE:			/* Command completed, do nothing & return */
					break;
				case XAC_BLOCK:			/* Block indefinitely (like for evnt_mesag) */
					Fread(client->client_end, sizeof(unsigned long), &cmd_rtn);
					break;
				case XAC_EXIT:		/* Block and the close the pipe (for appl_exit) */
					DIAG((D_trap,nil,"Direct blocking exit command; client_end is %d\n", client ? client->client_end : -999));
					Fread(client->client_end, sizeof(unsigned long), &cmd_rtn);
					Fclose(client->client_end);
					client->client_end = 0;
					break;
#if USE_CALL_DIRECT					/* HR */
				case XAC_TIMER:
					reply_s = 1L << client->client_end;
					
					if (!client->timer_val)
						cmd_rtn = 0;	/* Immediate timeout */
					else
						cmd_rtn = Fselect(client->timer_val, (long *)&reply_s, nil, nil);

					Sema_Up(clients);

					if (!cmd_rtn)		/* Timed out */
					{
						if (client->waiting_for & XAWAIT_MULTI)
							timer_intout(client->waiting_pb->intout);		/* HR: fill out mouse data!!! */
						else
							client->waiting_pb->intout[0] = 1;		/* evnt_timer() always returns 1 */
						cancel_evnt_multi(client,4);
					}

					Sema_Dn(clients);

					break;
#endif
				}
				
				return AES_MAGIC;			/* HR */
			}   /*  else   pb->intout[0] = 0;  HR: proceed to error exit */
		}
		else if (client)					/* Nope, go through the pipes messaging system instead... */
		{
			bool isfsel =    cmd == XA_FSEL_INPUT
			              or cmd == XA_FSEL_EXINPUT;	/* HR */

			if (isfsel)
				Sema_Up(fsel);	/* Wait for access to the fileselector */
			
			if (Ktab[cmd].p & LOCKSCREEN)
				lock_screen(client, -1, nil, 3);		/* HR 210202 */

			/* HR 220501: Use client structures */
			client->app.packet.pid = clnt_pid;		/* Build command packet */
			client->app.packet.cmd = c;
			client->app.packet.pb = pb;

#if GENERATE_DIAGS
			if (cmd == 107)			/* strange spurious wind_update	call. */
			{	DIAGS((" ???? wind_update @%lx\n", &Ktab[cmd].d)); }
#endif

			Fwrite(client->client_end, sizeof(K_CMD_PACKET), &client->app.packet);	/* Send command packet */

			if (c != AESCMD_STD) 				/* Unless we are doing standard GEM style AES calls, */
			{
				DIAGS(("non standard command: %d, client->end %d\n", c, client->client_end));
				return client->client_end;		/*  return here. */
			}
	
			/* OK, here we are in blocking AES call mode (standard GEM)
			 * - so we handle the reply pipe on behalf of the client.
			 */
	
			Fread(client->client_end, sizeof(unsigned long), &cmd_rtn);
	
			if (Ktab[cmd].p & LOCKSCREEN)
				unlock_screen(client, 3);		/* HR 210202 */

			if (isfsel)
				Sema_Dn(fsel);		/* Release the file selector */

			switch(cmd_rtn)
			{				/* New timeout stuff */
			case XA_OK:					/* Standard stuff, operation completed, etc */
			case XA_ILLEGAL:
			case XA_UNIMPLEMENTED:
				break;
			case XA_UNLOCK:				/* HR 250202: Read again. */
				Fread(client->client_end, sizeof(unsigned long), &cmd_rtn);
				break;
			/* HR 051201: Unclumsify the timer value passing. */
			case XA_TIMER:				/* Ahh - block again, with a timeout */

				reply_s = 1L << client->client_end;

				if (!client->timer_val)
					cmd_rtn = 0;	/* Immediate timeout */
				else
					cmd_rtn = Fselect(client->timer_val, (long *)&reply_s, nil, nil);

/*					#if DEBUG_SEMA
					DIAGS(("For %d:\n", clnt_pid));
				#endif
				Sema_Up(CLIENTS_SEMA);
*/	
				if (!cmd_rtn)		/* Timed out */
				{
					if (client->waiting_for & XAWAIT_MULTI)
						timer_intout(client->waiting_pb->intout);		/* HR: fill out mouse data!!! */
					else
						client->waiting_pb->intout[0] = 1;		/* evnt_timer() always returns 1 */

					cancel_evnt_multi(client,3);
					DIAG((D_kern,client,"[20]Unblocked timer for %s\n",c_owner(client)));
				} else			/* Second dummy read until unblock */
				{
					DIAG((D_kern,client,"Timer block for %s\n",c_owner(client)));
					Fread(client->client_end, sizeof(unsigned long), &cmd_rtn);
				}

/*					#if DEBUG_SEMA
					DIAGS(("For %d:\n", clnt_pid));
				#endif
				Sema_Dn(CLIENTS_SEMA);
*/	
				break;
			}
			return AES_MAGIC;
		} else
		{
			DIAGS(("No XaAES! Client!!   pid %d, cmd %d\n", clnt_pid, cmd));
			pb->intout[0] = 0;
			return AES_MAGIC;
		}
	}

	/* HR: error exit */
	DIAGS(("Unimplemented AES code: %d\n",cmd));
	pb->intout[0] = 0;

	return AES_MAGIC;
}

void hook_into_vector(void)
{
	void *old_ssp;

	old_ssp = (void *)Super((void *)nil);			/* Enter Supervisor mode*/
	
	asm_hook_into_vector();
	
	/* We want to do this with task switching disabled in order
	 * to prevent a possible race condition...
	 */
	 
	/* Dummy access to the critical error handler
	 * (make Selectric, FSELECT and other AES extenders happy...)
	 */
	 
	Setexc(0x101, (ExchangeVec *)-1L);
	Super(old_ssp);						/* Back to User Mode */
}

typedef struct xbra
{
	long xbra_id;
	long app_id;
	ExchangeVec *oldvec;
} XBRA;

#define XBRA_ID 0x58425241L
#define XAPP_ID 0x58614145L

/*
 * New unhook, pays attention to XBRA unhook procedure
 */
global
void unhook_from_vector(void)
{
	void *old_ssp;
	XBRA *rx;
	long vecadr, *stepadr;
 
 	vecadr = Setexc(0x20 + AES_TRAP, (ExchangeVec *)-1L); 	
 	rx = (XBRA *)(vecadr - sizeof(XBRA));

	old_ssp = (void *)Super((void *)nil);

	if ((rx->xbra_id == XBRA_ID) and (rx->app_id == XAPP_ID))	/* 'XBRA' and 'XaAE' */
	{
		Setexc(0x20 + AES_TRAP, rx->oldvec);
		return;
	}
	
	stepadr = (long *)&rx->oldvec;
	rx = (XBRA *)((long)rx->oldvec - sizeof(XBRA));
	while(rx->xbra_id == XBRA_ID)
	{
		if (rx->app_id == XAPP_ID)
		{
			*stepadr = (long)rx->oldvec;
			break;
		}
		stepadr = (long*)&rx->oldvec;
		rx = (XBRA *)((long)rx->oldvec - sizeof(XBRA));
	}
	Super(old_ssp);
}
