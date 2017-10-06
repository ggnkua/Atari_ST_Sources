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
#include "xa_nkcc.h"		/* Harald Siehmunds NKCC with XaAES reductions. */

#include "xa_input.h"
#include "xa_evnt.h"

#include "c_window.h"
#include "widgets.h"
#include "menuwidg.h"
#include "app_man.h"
#include "desktop.h"
#include "objects.h"

global
BUT_QUEU pending_button = {nil};			/* HR: for evnt fall thru */

/*
 *	Mouse button click handler 
 *	- MOUSESRV server process passes us click events
 *	  No, it's the Moose device driver via the kernel nowadays.
 *
 * The real button click handler is here :)
 * Excerpt from nkcc.doc, courtesy Harald Siegmund:

	Note: the NKCC button event handler supports the (undocumented)
	negation flag, which is passed in bit 8 of the parameter <bclicks>
	(maximum # of mouse clicks to wait for). You don't know this flag?
	I found an article about it in the c't magazine (I think it was
	issue 3/90, or maybe 4/90??) - and I damned Atari for their bad
	documentation. This flag opens the way to check BOTH mouse buttons
	at the same time without any problems. When set, the return
	condition is inverted. Let's have a look at an example:
	
	mask = evnt_multi(MU_BUTTON,2,3,3,...
	
	This doesn't work the way we want: the return condition is
	"button #0 pressed AND button #1 pressed". But look at this:
	
	mask = evnt_multi(MU_BUTTON,0x102,3,0,...
	
	Now the condition is "NOT (button #0 released AND button #1
	released)". Or in other words: "button #0 pressed OR button #1
	pressed". Nice, isn't it?!

 */
global
bool is_bevent(short got, short gotcl, short clks, short msk, short st, short which)
{
	bool ev;
	short clicks = clks&0xff;

	if (clks&0x100)
	{
		ev = (got&msk) != st;
	} else
	{
		ev = (got&msk) == st;
	}

	ev = ev && gotcl <= clicks;

DIAG((D.mouse,-1,"[%d]is_bevent? %s; gotb %d; gotc %d; clks 0x%x, msk %d, st %d\n", which,
					ev ? "Yes" : "No", got, gotcl, clks, msk, st));
	return ev;
}

global
short XA_button_event(LOCK lock, MOOSE_DATA *md)		/* HR */
{
	XA_CLIENT *client;
	XA_WINDOW *w;
	short kstate;
	unsigned long retv = XA_OK;
	short target_pid = 0;

/* HR: 19 october 2000; switched over to VMOOSE, the vdi vector based moose. */

	DIAG((D.mouse,-1,"MOUSE_EVENT: %d/%d, state=0x%x, clicks=%d\n", md->x, md->y, md->state, md->clicks));

	if (C.menu_base && md->state)		/* any button down */
	{
		Tab *tab = C.menu_base;
		if (tab->ty)
		{
			MENU_TASK *k = &tab->task_data.menu;
			if (k->entry)
			{
				k->x = md->x;
				k->y = md->y;
				k->entry(tab);
				return false;
			}
		}
	}

	w = wind_find(lock, md->x, md->y);				/* Try for a window */
    if (!w)
    {
		DIAG((D.mouse,-1,"click not in window\n"));
		return false;
	}

	target_pid = w->pid;

/* HR 040401: left click on root object of root_window. */
	if (   w == root_window && md->state == 1 && S.mouse_lock == 0)
    {
    	short b,x,y;
		DIAG((D.mouse,-1,"click on root_window, owner = %d\n",root_window->pid));
		vq_mouse(C.vh, &b, &x, &y);
		if (   b == 0			/* button must be released!! */
		    && target_pid != menu_owner()
			&& find_object(get_desktop(), 0, 1, md->x, md->y) == 0
		   )
		{
			app_in_front(lock, target_pid);
			return false;	/* click is used */
		}
	}

	if (S.mouse_lock == 0)					/* If mouse isn't locked, do a widgets test first */
	{
		if (md->state)
		{
			DIAG((D.mouse,-1,"calling do_widgets (wind owner=%d)\n", w->pid));
			if (do_widgets(lock, w, md))
				return false;	/* Window widgets prrocessed. */
		}
	} else
	{
		target_pid = S.mouse_lock;			/* Mouse is locked - clicks go to owner of mouse */
		DIAG((D.mouse,-1,"mouse is locked by %d\n", target_pid));

		DIAG((D.mouse,-1,"w=%lx,st=%d,own=%d,tapp=%d,nowork=%d\n",w,
				md->state,w->pid,target_pid,(w->active_widgets & NO_WORK) != 0));
		if (w->pid == target_pid && (w->active_widgets & NO_WORK))
			if (md->state)
			{
				DIAG((D.mouse,-1,"calling do_widgets no_work (target_pid=%d)\n", target_pid));
				if (do_widgets(lock, w, md))
					return false;	/* Process window widgets for no-work windows (this'll deal with alerts) */
			}
	}

	if unlocked(clients)
		Sema_Up(CLIENTS_SEMA);

	client = Pid2Client(target_pid);

/* If the client owning was waiting for a button event, send it */ 
/* - otherwise forget it, 'coz we don't want delayed clicks (they are confusing to the user [ie. me] ) */

/* HR: Very annoying not getting WM_TOPPED if you click a workarea	*/
	if (   md->state == 1
		&& w != window_list
		&& w != root_window
	    && (client->waiting_for & MU_MESAG)
	    && (w->active_widgets&NO_TOPPED) == 0			/* WF_BEVENT set */
	    )
	{
		DIAG((D.wind,-1,"send WM_TOPPED to %d\n", w->pid));
		w->send_message(lock|clients, w, w->pid, WM_TOPPED, 0, w->handle, 0, 0, 0, 0);
	}
	else
	if (client->waiting_for & MU_BUTTON)	
	{
		DIAG((D.mouse,-1,"XAWAIT_BUTTON for %d\n", target_pid));
		vq_key_s(C.vh, &kstate);			/* Get the current keyboard state */
		if ((client->waiting_pb) && (client->client_end))
		{
			short *to = client->waiting_pb->intout,
			      *ti = client->waiting_pb->intin;

			if (client->waiting_for & XAWAIT_MULTI)		/* If the client is waiting on a multi, the response is  */
			{							/*  slightly different to the evnt_button() response. */
				DIAG((D.mouse,-1,"MU_BUTTON\n"));
				if (is_bevent(md->state, md->clicks, ti[1], ti[2], ti[3],11))
				{
					*to++ = MU_BUTTON;
					*to++ = md->x;
					*to++ = md->y;
					*to++ = md->state;
					*to++ = kstate;
					*to++ = 0;				/* HR: ?? */
					*to++ = md->clicks;
					cancel_evnt_multi(client);
					Fwrite(client->kernel_end, sizeof(unsigned long), &retv);	/* Write success to clients reply pipe to unblock the process */
					DIAG((D.mouse,-1," - written\n"));
				}
			} else
			{
				DIAG((D.mouse,-1,"evnt_button\n"));
				if (is_bevent(md->state, md->clicks, ti[0], ti[1], ti[2],12))
				{
/* HR: exchanged return of clicks & state */
					*to++ = md->clicks;
					*to++ = md->x;
					*to++ = md->y;
					*to++ = md->state;
					*to   = kstate;
					cancel_evnt_multi(client);
					Fwrite(client->kernel_end, sizeof(unsigned long), &retv);	/* Write success to clients reply pipe to unblock the process */
					DIAG((D.mouse,-1," - written\n"));
				}
			}
		}
	} else
	{
		if unlocked(pending)
			Sema_Up(PENDING_SEMA);
		pending_button.client = client;
		pending_button.state = md->state;
		pending_button.clicks = md->clicks;			/* HR 310501: Oof! bad omission fixed. */
		/* A pending button is a single shot. */
		DIAG((D.mouse,-1,"button queued %d\n", pending_button.state));
		if unlocked(pending)
			Sema_Dn(PENDING_SEMA);
	}

	if unlocked(clients)
		Sema_Dn(CLIENTS_SEMA);

	return false;
}

global
bool is_rect(short x, short y, short fl, RECT *o)
{
	bool in = m_inside(x, y, o),
		 f = fl == 0;
	return f == in;
}

/* HR: now it is implemented quite equivalent to button events */
global
short XA_move_event(LOCK lock, MOOSE_DATA *md)
{
	XA_CLIENT *client;
	unsigned long retv = XA_OK;
	short x, y;
	short kstate;

/*	short mb = md->state;
*/	x = md->x;
	y = md->y;

/* XaAES internal move event handling */
	if (C.menu_base)		/* Any part of a menu pulled? */
	{
		MENU_TASK *k = &C.menu_base->task_data.menu;
#ifdef MU_MX							/* XaAES internal flag: report any mouse movement. */
		if (k->em.flags & MU_MX)
		{
			k->em.flags = 0;
			k->x = x;
			k->y = y;
			k->em.t1(C.menu_base);	/* call the function */
		}
		else
#endif
		if (k->em.flags & MU_M1)
		{
			if (is_rect(x, y, k->em.flags & 1, &k->em.m1))
			{
				k->em.flags = 0;
				k->x = x;
				k->y = y;
				k->em.t1(C.menu_base);	/* call the function */
			}
#ifndef MU_MX
			else
					/* HR: MU_M2 not used for menu's anymore, replaced by MU_MX */
					/* I leave the text in, because one never knows. */
			if (k->em.flags & MU_M2)
			{
				if (is_rect(x, y, k->em.flags & 2, &k->em.m2))
				{
					k->em.flags = 0;
					k->x = x;
					k->y = y;
					k->em.t2(C.menu_base);
				}
			}
#endif
		}
		return false;
	}

	if unlocked(clients)
		Sema_Up(CLIENTS_SEMA);

	/* Moving the mouse into the menu bar is outside
		Tab handling, because the bar itself is not for popping.
	*/
	{
		XA_CLIENT *aes = C.Aes;		/* HR: watch the menu bar as a whole */
		if (   (aes->waiting_for & XAWAIT_MENU)
			&& (aes->em.flags & MU_M1)
			)
		{
			if (   cfg.menu_behave != PUSH
				&& (S.update_lock == C.AESpid || S.update_lock == 0)
				&& (aes->waiting_for & XAWAIT_MENU)
				&& is_rect(x, y, aes->em.flags & 1, &aes->em.m1)
				)
			{
				XA_WIDGET *widg = &root_window->widgets[XAW_MENU];
				DIAG((D.menu,-1,"mouse into menu_bar\n"));
				cancel_evnt_multi(aes);
				if unlocked(clients)
					Sema_Dn(CLIENTS_SEMA);
	/* This the root function for the menu tasks */
				(*widg->behaviour[XACB_CLICK])(lock, root_window,widg);
				return false;
			}
		}
	}


/* HR: internalized the client loop */
	client = S.client_list;
	while(client)
	{
		if (   client->client_end
			&& (client->waiting_for & (MU_M1|MU_M2|MU_MX))
			)
		{
			client->waiting_pb->intout[0] = 0;		/* HR 220501: combine mouse events. */

			if (   (client->em.flags & MU_M1)
			    && is_rect(x, y, client->em.flags & 1, &client->em.m1)
			   )
			{
				if (client->waiting_for & XAWAIT_MULTI)
				{
					DIAG((D.mouse,client->pid,"MU_M1 for %s(%d)\n", client->name, client->pid)); 
					multi_intout(client->waiting_pb->intout, client->waiting_pb->intout[0] | MU_M1, -1);
				othw
					multi_intout(client->waiting_pb->intout, 0, -1);
					client->waiting_pb->intout[0] = 1;
				}
			}

			if (   (client->em.flags & MU_M2)		/* M2 in evnt_multi only */
			    && is_rect(x, y, client->em.flags & 2, &client->em.m2)
			   )
			{
				DIAG((D.mouse,client->pid,"MU_M2 for %s(%d)\n", client->name, client->pid)); 
				multi_intout(client->waiting_pb->intout, client->waiting_pb->intout[0] | MU_M2, -1);
			}

			if (client->em.flags & MU_MX)			/* MX: any movement. */
			{
				DIAG((D.mouse,client->pid,"MU_MX for %s(%d)\n", client->name, client->pid)); 
				multi_intout(client->waiting_pb->intout, client->waiting_pb->intout[0] | MU_MX, -1);
			}

			if (client->waiting_pb->intout[0])
			{
				cancel_evnt_multi(client);
					/* Write success to clients reply pipe to unblock the process */
				Fwrite(client->kernel_end, sizeof(unsigned long), &retv);
			}
		}

		client = client->next;
	}

	if unlocked(clients)
		Sema_Dn(CLIENTS_SEMA);

	return false;
}


/*
 * HR: Generalization of focus determination.
 *      Each step checks XAWAIT_KEY except the first.
 *		The top or focus window can have a keypress handler in stead of the XAWAIT_KEY flag.
 *
 *       first:    check focus keypress handler (no XAWAIT_KEY or update_lock needed)
 *       second:   check update lock
 *       third:    check top or focus window
 *       last:     check root menu_bar owner
 *
 *  240401: Interesting bug found and killed:
 *       If the update lock is set, then the key must go to that client,
 *          If that client is not yet waiting, the key must be queued,
 *          the routine MUST pass the client pointer, so there is a pid to be
 *          checked later.
 *       In other words: There can always be a client returned. So we must only
 *          if that client is already waiting. Hence the ref bool.
 */
static
XA_CLIENT *find_focus(XA_WINDOW *w, bool *waiting)
{
	XA_CLIENT *client;
	short mpid;

	if (w == C.focus && w->keypress)		/* HR: this is for forms who dont set the update lock. */
	{
		*waiting = true;
		return w->owner;
	}

	if (S.update_lock > 0 && S.update_lock < MAX_PID)
	{
		client = Pid2Client(S.update_lock);
		*waiting = (client->waiting_for & MU_KEYBD) || w->keypress;			
		return client;
	}

	mpid = menu_owner();			/* HR */

	/* If C.focus == root_window, then the top_window owner is not the menu owner;
	                 the menu has prcedence, and the top window isnt drawn bold. */
	client = Pid2Client(C.focus == root_window ?  mpid : w->pid);
	if ((client->waiting_for & MU_KEYBD) || w->keypress)
	{
		*waiting = true;
		return client;
	}

	client = Pid2Client(mpid);
	*waiting = (client->waiting_for & MU_KEYBD) != 0;
	return client;
}

/*
 	Keyboard input handler
    ======================

   Courtesy Harald Siegmund:

   nkc_tconv: TOS key code converter
   # G R

   This is the most important function within NKCC: it takes a key code
   returned by TOS and converts it to the sophisticated normalized format.

   Note: the raw converter does no deadkey handling, ASCII input or
         Control key emulation.

   In:   D0.L           key code in TOS format:
                                    0                    1
                        bit 31:     ignored              ignored
                        bit 30:     ignored              ignored
                        bit 29:     ignored              ignored
                        bit 28:     no CapsLock          CapsLock
                        bit 27:     no Alternate         Alternate pressed
                        bit 26:     no Control           Control pressed
                        bit 25:     no left Shift key    left Shift pressed
                        bit 24:     no right Shift key   right Shift pressed

                        bits 23...16: scan code
                        bits 15...08: ignored
                        bits 07...00: ASCII code (or rubbish in most cases
                           when Control or Alternate is pressed ...)

   Out:  D0.W           normalized key code:
                        bits 15...08: flags:
                                    0                    1
                        NKF?_FUNC   printable char       "function key"
                        NKF?_RESVD  ignore it            ignore it
                        NKF?_NUM    main keypad          numeric keypad
                        NKF?_CAPS   no CapsLock          CapsLock
                        NKF?_ALT    no Alternate         Alternate pressed
                        NKF?_CTRL   no Control           Control pressed
                        NKF?_LSH    no left Shift key    left Shift pressed
                        NKF?_RSH    no right Shift key   right Shift pressed

                        bits 07...00: key code
                        function (NKF?_FUNC set):
                           < 32: special key (NK_...)
                           >=32: printable char + Control and/or Alternate
                        no function (NKF?_FUNC not set):
                           printable character (0...255!!!)
 */


global
KEY_QUEU pending_keys = {0,0,{0}};

global
void XA_keyboard_event(LOCK lock, KEY *key)
{
	unsigned long retv = XA_OK;
	bool waiting;
	XA_WINDOW *w = window_list;
	XA_CLIENT *client = find_focus(w, &waiting);		/* HR */

DIAG((D.keybd,-1,"keyhandler:update_lock:%d,client_pid=%d, top_window_owner=%d is waiting? %d\n",
			S.update_lock, client->pid, w ? w->pid : -1, waiting));

	if (waiting)		/* Found either XAWAIT_KEY or keypress handler. */
	{
		if (w->keypress)		/* Does the top&focus window have a keypress handler callback? */
		{
			(*(w->keypress))(lock, w, key->aes, key->norm, key->raw);
			return;
		}

		if unlocked(clients)
			Sema_Up(CLIENTS_SEMA);
		
		if (client->waiting_for & XAWAIT_MULTI)		/* If the client is waiting on a multi, the response is  */
		{								/*  slightly different to the evnt_keybd() response. */
			multi_intout(client->waiting_pb->intout, MU_KEYBD, key->raw.conin.state);
/* HR 300501: XaAES extension: return normalized keycode for MU_NORMKEY */
			if (client->waiting_for & MU_NORMKEY)
			{
				if (key->norm == 0)
					key->norm = nkc_tconv(key->raw.bcon);
				client->waiting_pb->intout[5] = key->norm;
			}
			else
				client->waiting_pb->intout[5] = key->aes;
			cancel_evnt_multi(client);
DIAG((D.k,-1,"evnt_multi key to %s(%d): 0x%04x\n", client->name, client->pid, key->aes));	
		} else
		{
			client->waiting_pb->intout[0] = key->aes;
			cancel_evnt_multi(client);
DIAG((D.k,-1,"evnt_keybd keyto %s(%d): 0x%04x\n", client->name, client->pid, key->aes));	
		}

		Fwrite(client->kernel_end, sizeof(unsigned long), &retv);	/* Write success to client's reply pipe to unblock the process */
		if unlocked(clients)
			Sema_Dn(CLIENTS_SEMA);
	} else
	{
		if unlocked(pending)
			Sema_Up(PENDING_SEMA);
		DIAG((D.keybd,-1,"pending key cur=%d\n", pending_keys.cur));
		/* If there are pending keys and the top window owner has changed, throw them away. */
		if (   pending_keys.cur != pending_keys.end
			&& window_list->pid != pending_keys.q[pending_keys.cur].pid
		   )		
			pending_keys.cur = pending_keys.end = 0;
		else
		if (pending_keys.end == KEQ_L)
			pending_keys.end = 0;

		DIAG((D.keybd,-1," -     key %x to %d\n", key->aes, pending_keys.end));
		pending_keys.q[pending_keys.end].k   = *key;			/* HR 240401: all of key */
		pending_keys.q[pending_keys.end].pid = client->pid;		/* HR 240401: see find_focus() */
		pending_keys.end++;
		
		if unlocked(pending)
			Sema_Dn(PENDING_SEMA);
	}
}
