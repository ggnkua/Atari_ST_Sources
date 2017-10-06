/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <string.h>
#include "mintbind.h"

#include "xa_types.h"
#include "xa_globl.h"

#include "xa_nkcc.h"
#include "xa_evnt.h"
#include "c_window.h"
#include "rectlist.h"
#include "app_man.h"
#include "desktop.h"
#include "objects.h"
#include "widgets.h"

/* HR 050601: The active widgets are intimately connected to the mouse.
              There is only 1 mouse, so there is only need for 1 global structure.
*/
XA_PENDING_WIDGET widget_active = {nil};	/* Pending active widget (if any) */


/* HR: Keystrokes must be put in a queue if no apps are waiting yet.
   There also may be an error in the timer event code.
   A queue like this is pretty anyhow, even if it is almost never needed.
*/

#define KEQ_L 16

typedef struct key_q
{
	short pid;
	KEY k;
} KEY_Q;

typedef struct key_queue
{
	short cur,end;
	KEY_Q q[KEQ_L];
} KEY_QUEU;

static
KEY_QUEU pending_keys = {0,0,{0}};

global
BUTTON pending_button = {nil};			/* HR: for evnt fall thru */

global
void cancel_pending_button(void)
{
	if (pending_button.client)
	{
		pending_button.client = nil;
		DIAG((D.mouse,-1,"cancel_pending_button\n"));
	}
}

/* HR 180601: Now use the global (once) set values in the button structure */
global
void multi_intout(short *o, short evnt)
{
	get_mouse();
	*o++ = evnt;
	*o++ = button.x;
	*o++ = button.y;
	*o++ = button.b;
	*o++ = button.ks;
	if (evnt)
	{
		*o++ = 0;
		*o++ = 0;
	}
}


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
static
bool is_bevent(short gotbut, short gotcl, short *o, short which)
{
	bool ev;
	short clks = o[0], msk = o[1], st = o[2];
	short clicks = clks&0xff;

	if (clks&0x100)
		ev = (gotbut&msk) != st;
	else
		ev = (gotbut&msk) == st;

	ev = ev and gotcl <= clicks;

DIAG((D.mouse,-1,"[%d]is_bevent? %s; gotb %d; gotc %d; clks 0x%x, msk %d, st %d\n", which,
					ev ? "Yes" : "No", gotbut, gotcl, clks, msk, st));
	return ev;
}


global
short XA_button_event(LOCK lock, MOOSE_DATA *md, bool widgets)		/* HR */
{
	XA_CLIENT *client;
	XA_WINDOW *w;
	short target_pid = 0;

/* HR: 19 october 2000; switched over to VMOOSE, the vdi vector based moose. */

	DIAG((D.mouse,-1,"BUTTON_EVENT: %d/%d, state=0x%x, clicks=%d\n", md->x, md->y, md->state, md->clicks));

	if (C.menu_base and md->state)		/* any button down */
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
	if (   w == root_window and md->state == 1 and S.mouse_lock == 0)
    {
    	short b,x,y;
		DIAG((D.mouse,-1,"click on root_window, owner = %d\n",root_window->pid));
		vq_mouse(C.vh, &b, &x, &y);
		if (   b == 0			/* button must be released!! */
		    and target_pid != menu_owner()
		    and find_object(get_desktop(), 0, 1, md->x, md->y) == 0
		   )
		{
			app_in_front(lock, target_pid);
			return false;	/* click is used */
		}
	}

	if (S.mouse_lock == 0)					/* If mouse isn't locked, do a widgets test first */
	{
		if (md->state and widgets)
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
		if (w->pid == target_pid and (w->active_widgets & NO_WORK))
			if (md->state and widgets)
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
	if (    md->state == 1
	    and w->pid == target_pid						/* HR 150601: Mouse lock !!! */
		and w != window_list
		and w != root_window
	    and (client->waiting_for & MU_MESAG)
	    and (w->active_widgets&NO_TOPPED) == 0			/* WF_BEVENT set */
	    )
	{
		DIAG((D.wind,w->pid,"send WM_TOPPED to %d\n", w->pid));
		w->send_message(lock|clients, w, w->pid, WM_TOPPED, 0, w->handle, 0, 0, 0, 0);
	}
	else
	if (    w == window_list
	    and C.focus == root_window				/* HR 100801 */
	   )
	{
		C.focus = window_list;
		DIAG((D.menu,-1,"Click on unfocused top_window on %d\n", root_window->pid));
		display_non_topped_window(lock, 112, window_list, nil);   /* Redisplay titles */
		send_ontop(lock|clients);
		swap_menu(lock|clients, window_list->pid, true);
	}
	else
	if (client->waiting_for & MU_BUTTON)	
	{
		DIAG((D.mouse,-1,"XAWAIT_BUTTON for %d\n", target_pid));

		if ((client->waiting_pb) and (client->client_end))
		{
			short *to = client->waiting_pb->intout;
	
			if (client->waiting_for & XAWAIT_MULTI)		/* If the client is waiting on a multi, the response is  */
			{							/*  slightly different to the evnt_button() response. */
				DIAG((D.mouse,-1," -- XAWAIT_MULTI\n"));
				if (is_bevent(md->state, md->clicks, client->waiting_pb->intin + 1, 11))
				{
					*to++ = MU_BUTTON;
					*to++ = md->x;
					*to++ = md->y;
					*to++ = md->state;
					*to++ = button.ks;
					*to++ = 0;				/* HR: ?? */
					*to++ = md->clicks;
					cancel_evnt_multi(client);
						/* Write success to clients reply pipe to unblock the process */
					Unblock(client, XA_OK, 3);
					DIAG((D.mouse,-1," - written\n"));
				}
			} else
			{
				DIAG((D.mouse,-1," -- evnt_button\n"));
				if (is_bevent(md->state, md->clicks, client->waiting_pb->intin, 12))
				{
/* HR: exchanged return of clicks & state */
					*to++ = md->clicks;
					*to++ = md->x;
					*to++ = md->y;
					*to++ = md->state;
					*to   = button.ks;
					cancel_evnt_multi(client);
						/* Write success to clients reply pipe to unblock the process */
					Unblock(client, XA_OK, 4);
					DIAG((D.mouse,-1," - written\n"));
				}
			}
		}
	}
	else
	{
		if unlocked(pending)
			Sema_Up(PENDING_SEMA);
		pending_button.client = client;
		pending_button.b = md->state;
		pending_button.clicks = md->clicks;			/* HR 310501: Oof! bad omission fixed. */
		/* A pending button is a single shot. */
		DIAG((D.mouse,-1,"button queued st:%d\n", pending_button.b));
		if unlocked(pending)
			Sema_Dn(PENDING_SEMA);
	}

	if unlocked(clients)
		Sema_Dn(CLIENTS_SEMA);

	return false;
}

static
bool mouse_ok(XA_CLIENT *client)
{
	if (S.mouse_lock <= 0 or S.mouse_lock >= MAX_PID)
		return true;
	if (S.mouse_lock == client->pid)
		return true;
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
	short x = md->x,
	      y = md->y;

/* XaAES internal move event handling */
	if (C.menu_base)		/* Any part of a menu pulled? */
	{
		MENU_TASK *k = &C.menu_base->task_data.menu;

		if (k->em.flags & MU_MX)	/* XaAES internal flag: report any mouse movement. */
		{
			k->em.flags = 0;
			k->x = x;
			k->y = y;
			k->em.t1(C.menu_base);	/* call the function */
		}
		else
		if (k->em.flags & MU_M1)
		{
			if (is_rect(x, y, k->em.flags & 1, &k->em.m1))
			{
				k->em.flags = 0;
				k->x = x;
				k->y = y;
				k->em.t1(C.menu_base);	/* call the function */
			}
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
		if (    (aes->waiting_for & XAWAIT_MENU)
			and (aes->em.flags & MU_M1)
			)
		{
			if (    cfg.menu_behave != PUSH
				and (S.update_lock == C.AESpid or S.update_lock == 0)
				and (aes->waiting_for & XAWAIT_MENU)
				and is_rect(x, y, aes->em.flags & 1, &aes->em.m1)
				)
			{
				XA_WIDGET *widg = &root_window->widgets[XAW_MENU];
				DIAG((D.menu,-1,"mouse into menu_bar :: dbgmenu_up\n"));
				cancel_evnt_multi(aes);
				if unlocked(clients)
					Sema_Dn(CLIENTS_SEMA);
	/* This is the root function for the menu tasks. (could be click_menu_widget) */
				DIAG((D.menu,-1,"root_window owner %s(%d), killed %d, menu_owner %d\n",
					root_window->owner->name,
					root_window->owner->pid,
					root_window->owner->killed,
					menu_owner()));
				(*widg->behaviour[XACB_CLICK])(lock, root_window,widg);
				return false;
			}
		}
	}


	if (S.mouse_lock)			/* HR 150601: mouse lock is also for rectangle events! */
		client = Pid2Client(S.mouse_lock);
	else
		client = S.client_list;

/* HR: internalized the client loop */
	while(client)
	{
		if (    client->client_end
			and (client->waiting_for & (MU_M1|MU_M2|MU_MX))
			)
		{
			AESPB *pb = client->waiting_pb;
			
			pb->intout[0] = 0;		/* HR 220501: combine mouse events. */

			if (   (client->em.flags & MU_M1)
			    and is_rect(x, y, client->em.flags & 1, &client->em.m1)
			   )
			{
				if (client->waiting_for & XAWAIT_MULTI)
				{
					DIAG((D.mouse,client->pid,"MU_M1 for %s(%d)\n", client->name, client->pid)); 
					multi_intout(pb->intout, pb->intout[0] | MU_M1);
				othw
					multi_intout(pb->intout, 0);
					pb->intout[0] = 1;
				}
			}

			if (   (client->em.flags & MU_M2)		/* M2 in evnt_multi only */
			    and is_rect(x, y, client->em.flags & 2, &client->em.m2)
			   )
			{
				DIAG((D.mouse,client->pid,"MU_M2 for %s(%d)\n", client->name, client->pid)); 
				multi_intout(pb->intout, pb->intout[0] | MU_M2);
			}

			if (client->em.flags & MU_MX)			/* MX: any movement. */
			{
				DIAG((D.mouse,client->pid,"MU_MX for %s(%d)\n", client->name, client->pid)); 
				multi_intout(pb->intout, pb->intout[0] | MU_MX);
			}

			if (pb->intout[0])
			{
				cancel_evnt_multi(client);
					/* Write success to clients reply pipe to unblock the process */
				Unblock(client, XA_OK, 5);
			}
		}

		if (client->pid == S.mouse_lock)			/* HR 150601: mouse lock is also for rectangle events! */
			break;
		else
			client = client->next;
	}

	if unlocked(clients)
		Sema_Dn(CLIENTS_SEMA);

	return false;
}


/*
 * HR: Generalization of focus determination.
 *      Each step checks MU_KEYBD except the first.
 *		The top or focus window can have a keypress handler in stead of the XAWAIT_KEY flag.
 *
 *       first:    check focus keypress handler (no MU_KEYBD or update_lock needed)
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

	if (w == C.focus and w->keypress)		/* HR: this is for forms who dont set the update lock. */
	{
		*waiting = true;
		return w->owner;
	}

	if (S.update_lock > 0 and S.update_lock < MAX_PID)
	{
		client = Pid2Client(S.update_lock);
		*waiting = (client->waiting_for & MU_KEYBD) or w->keypress;			
		return client;
	}

	mpid = menu_owner();			/* HR */

	/* If C.focus == root_window, then the top_window owner is not the menu owner;
	                 the menu has prcedence, and the top window isnt drawn bold. */
	client = Pid2Client(C.focus == root_window ?  mpid : w->pid);
	if ((client->waiting_for & MU_KEYBD) or w->keypress)
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
void XA_keyboard_event(LOCK lock, KEY *key)
{
	bool waiting;
	XA_WINDOW *w = window_list;
	XA_CLIENT *client;
	AESPB *pb;

	client = find_focus(w, &waiting);		/* HR */
	pb     = client->waiting_pb;

DIAG((D.keybd,-1,"XA_keyboard_event: update_lock:%d,client_pid=%d, top_window_owner=%d is waiting? %d\n",
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
			get_mouse();
			button.ks =  key->raw.conin.state;
			multi_intout(pb->intout, MU_KEYBD);
/* HR 300501: XaAES extension: return normalized keycode for MU_NORMKEY */
			if (client->waiting_for & MU_NORMKEY)
			{
				if (key->norm == 0)
					key->norm = nkc_tconv(key->raw.bcon);
				pb->intout[5] = key->norm;
DIAG((D.k,-1,"evnt_multi normkey to %s(%d): 0x%04x\n", client->name, client->pid, key->norm));	
			}
			else
			{
				pb->intout[5] = key->aes;
DIAG((D.k,-1,"evnt_multi key to %s(%d): 0x%04x\n", client->name, client->pid, key->aes));	
			}
			cancel_evnt_multi(client);
		} else
		{
			pb->intout[0] = key->aes;
			cancel_evnt_multi(client);
DIAG((D.k,-1,"evnt_keybd keyto %s(%d): 0x%04x\n", client->name, client->pid, key->aes));	
		}

			/* Write success to client's reply pipe to unblock the process */
		Unblock(client, XA_OK, 6);

		if unlocked(clients)
			Sema_Dn(CLIENTS_SEMA);
	} else
	{
		if unlocked(pending)
			Sema_Up(PENDING_SEMA);
		DIAG((D.keybd,-1,"pending key cur=%d\n", pending_keys.cur));
		/* If there are pending keys and the top window owner has changed, throw them away. */

		if unlocked(winlist)
			Sema_Up(WIN_LIST_SEMA);

		if (    pending_keys.cur != pending_keys.end
			and window_list->pid != pending_keys.q[pending_keys.cur].pid
		   )		
			pending_keys.cur = pending_keys.end = 0;
		else
		if (pending_keys.end == KEQ_L)
			pending_keys.end = 0;

		if unlocked(winlist)
			Sema_Dn(WIN_LIST_SEMA);

		DIAG((D.keybd,-1," -     key %x to %d\n", key->aes, pending_keys.end));
		pending_keys.q[pending_keys.end].k   = *key;			/* HR 240401: all of key */
		pending_keys.q[pending_keys.end].pid = client->pid;		/* HR 240401: see find_focus() */
		pending_keys.end++;
		
		if unlocked(pending)
			Sema_Dn(PENDING_SEMA);
	}
}

#if 1
static
short pending_msgs(LOCK lock, XA_CLIENT *client, AESPB *pb)
{
	short rtn;

	/* Is there a widget active (like a scroll arrow)? If so, check with the action first
	 * as it may result in some messages (just in case we've not got any already)
	 */
	/* The reason why it is done in here is that this way it works in sort of a feed back mode.
	   The widget is only actioned in case of a MESAG event wait from the client.
	   Otherwise every pixel slider move would result in a message sent.
	*/

	if unlocked(clients)
		Sema_Up(CLIENTS_SEMA);

	if (!client->msg)
		do_active_widget(lock|clients, client);			/* HR 230601: now a function; used in woken_slist as well. */

	rtn = client->msg != nil;
	if (rtn)	/* Are there any messages pending? */
	{
		MSG_BUF *buf = (MSG_BUF *)(pb->addrin[0]);
		XA_AESMSG_LIST *msg = client->msg;

		client->msg = msg->next;
		*buf = msg->message;				/* Copy the message into the clients buffer */
		DIAG((D.m,-1,"Got pending message %s for %s(%d) from %d\n", pmsg(buf->m[0]), client->name, client->pid, buf->m[1]));
		free(msg);
	}

	if unlocked(clients)
		Sema_Dn(CLIENTS_SEMA);
	return rtn;
}
#else
#include "obsolete\pend_msg.h"
#endif

/* HR: Note that it might still be necessary to reorganize the kernel loop! */
static
bool pending_key_strokes(LOCK lock, AESPB *pb, short pid, short type)
{
	bool ok = false;

	if unlocked(pending)
		Sema_Up(PENDING_SEMA);

	if (pending_keys.cur != pending_keys.end)			/* HR: keys may be queued */
	{
		KEY key;
		DIAG((D.keybd, -1, "Got pending key: cur=%d,end=%d (%d::%d)\n",
					pending_keys.cur, pending_keys.end, pending_keys.q[pending_keys.cur].pid, pid));		
		if (pid == pending_keys.q[pending_keys.cur].pid)
		{
			key = pending_keys.q[pending_keys.cur++].k;
	
			if (type)
			{
				get_mouse();
				button.ks =  key.raw.conin.state;
		/*		multi_intout(pb->intout, type);
		*/		if (type&MU_NORMKEY)			/* HR 300501: XaAES extension: normalized key codes. */
				{
					if (key.norm == 0)
						key.norm = nkc_tconv(key.raw.bcon);
					pb->intout[5] = key.norm;
				}
				else
					pb->intout[5] = key.aes;
			}
			else
				pb->intout[0] = key.aes;
	
			DIAG((D.keybd, -1, "key 0x%x sent to %d\n", key.aes, pid));
	
			if (pending_keys.cur == KEQ_L)
				pending_keys.cur = 0;
			if (pending_keys.cur == pending_keys.end)
				pending_keys.cur = pending_keys.end = 0;
			ok = true;
		}
	}

	if unlocked(pending)
		Sema_Dn(PENDING_SEMA);
	return ok;
}

bool naes12 = false;

#if 0 /* BUTTONFIX */
bool still_button(XA_CLIENT *client, short *o)
{
	return
            !button.got			/* XA_event_button() has not been called */
	    and (   (o[2] == 0 and (o[0]&0x100) == 0)
			 or  o[2] != 0
		    )
		and C.menu_base == nil
		and widget_active.widg == nil
		and mouse_ok(client);
}
#else
bool still_button(XA_CLIENT *client, short *o)		/* up only version */
{
#if NAES12
	if (naes12)
		return 
			 o[2] == 0
		 and  o[0] <  2
		 and mouse_ok(client);
	else
#endif
		return 
			 o[2]        == 0
		 and (o[0]&0x100) == 0
		 and mouse_ok(client);
}
#endif

#if GENERATE_DIAGS
static
char *xev[] = {"KBD","BUT","M1","M2","MSG","TIM","MX","NKBD","8","9","10","11","12","13","14","15"};
#endif

#if GENERATE_DIAGS
void evnt_diag_output(void *pb, short pid, char *which)
{
	if (pb)
	{
		short *o = ((AESPB *)pb)->intout;
		char evx[128];
		show_bits(o[0], "", xev, evx);
		DIAG((D.multi,pid,"%sevnt_multi return: %s x%d, y%d, b%d, ks%d\n", which, evx, o[1], o[2], o[3], o[4]));
	}
}
#define diag_out(x,pid,y) evnt_diag_output(x,pid,y);
#else
#define diag_out(x,pid,y)
#endif

/* HR 070601: We really must combine events. especially for the button still down situation.
*/

/*
 *	The essential evnt_multi() call
 */

#if 1
AES_function XA_evnt_multi	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	short events = pb->intin[0];
	unsigned long ret = XAC_BLOCK;		/* HR: another example of choosing inconvenient default fixed. */
	short f,
	      rtn,
	      new_waiting_for = 0,
	      fall_through = 0;
	
	CONTROL(16,7,1)

	client->waiting_pb = pb;	/* Store a pointer to the AESPB to fill when the event(s) */
								/*  finally arrive. */
	pb->intout[0] = 0;
	pb->intout[5] = 0;
	pb->intout[6] = 0;
	client->waiting_for = 0;
	
/* HR */
#if GENERATE_DIAGS
	{
		char evtxt[128];
		show_bits(events, "evnt=", xev, evtxt);
		DIAG((D.multi,client->pid,"evnt_multi for %d, %s clks=0x%x, msk=0x%x, bst=x%x T:%d\n",
				client->pid,evtxt,pb->intin[1],pb->intin[2],pb->intin[3], (events&MU_TIMER) ? pb->intin[14] : -1));
	}
#endif

/*
	Excerpt from nkcc.doc, courtesy Harald Siegmund:

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

	if (events & MU_BUTTON)
	{
		if unlocked(pending)
			Sema_Up(PENDING_SEMA);

		if (pending_button.client == client)
		{
			DIAG((D.mouse,client->pid,"pending_button multi %d\n", pending_button.b));
			pending_button.client = nil;			/* is single shot. */
			if (is_bevent(pending_button.b, pending_button.clicks, pb->intin + 1, 1))
			{
				fall_through |= MU_BUTTON;
DIAG((D.mouse,client->pid,"fall_through |= MU_BUTTON\n"));
			}
		} else
		if (still_button(client, pb->intin + 1))
		{
			DIAG((D.mouse,client->pid,"still_button multi %d\n", pending_button.b));
			get_mouse();
			if (is_bevent(button.b, 0, pb->intin + 1, 2))
			{
DIAG((D.mouse,client->pid,"still button %d: fall_through |= MU_BUTTON (lock %d)\n",button.b, S.mouse_lock));
				fall_through |= MU_BUTTON;
				button.got = true;				/* Mark button state processed. */
			}
		}

		if unlocked(pending)
			Sema_Dn(PENDING_SEMA);

		if ((fall_through&MU_BUTTON) == 0)
		{
			new_waiting_for |= MU_BUTTON;		/* Flag the app as waiting for button changes */
			pb->intout[0] = 0;
DIAG((D.mouse,client->pid,"new_waiting_for |= MU_BUTTON\n"));
		}
	}

	if (events & MU_NORMKEY)
		events |= MU_KEYBD;

	if (events & MU_KEYBD)		
	{
		short ev = events&(MU_NORMKEY|MU_KEYBD);
		if (pending_key_strokes(lock, pb, client->pid, ev))			/* HR */
			fall_through    |= ev;
		else
			new_waiting_for |= ev;			/* Flag the app as waiting for keypresses */
	}

/* HR: event data are now in the client structure */
/*     040401: Implemented fall thru. */
	if (events & (MU_M1|MU_M2|MU_MX))
	{
		memset(&client->em,0,sizeof(XA_MOUSE_RECT));
		if (events & MU_M1)					/* Mouse rectangle tracking */
		{
			RECT *r = (RECT *)&pb->intin[5];
			client->em.m1 = *r;
			client->em.flags = pb->intin[4] | MU_M1;
DIAG((D.multi,client->pid,"    M1 rectangle: %d/%d,%d/%d, flag: 0x%x\n", r->x, r->y, r->w, r->h, client->em.flags));
			get_mouse();
			if (mouse_ok(client) and is_rect(button.x, button.y, client->em.flags & 1, &client->em.m1))
				fall_through    |= MU_M1;
			else
				new_waiting_for |= MU_M1;
		}

		if (events & MU_MX)					/* HR: XaAES extension: any mouse movement. */
		{
			client->em.flags = pb->intin[4] | MU_MX;
DIAG((D.multi,client->pid,"    MX\n"));
			new_waiting_for |= MU_MX;
		}

		if (events & MU_M2)
		{
			RECT *r = (RECT *)&pb->intin[10];
			client->em.m2 = *r;
			client->em.flags |= (pb->intin[9] << 1) | MU_M2;
DIAG((D.multi,client->pid,"    M2 rectangle: %d/%d,%d/%d, flag: 0x%x\n", r->x, r->y, r->w, r->h, client->em.flags));
			get_mouse();
			if (mouse_ok(client) and is_rect(button.x, button.y, client->em.flags & 2, &client->em.m2))
				fall_through    |= MU_M2;
			else
				new_waiting_for |= MU_M2;
		}
	}

	if (events & MU_MESAG)
		if (pending_msgs(lock, client, pb))		/* HR */
			fall_through    |= MU_MESAG;
		else
			new_waiting_for |= MU_MESAG;		/* Mark the client as waiting for messages */
	
	/* HR: a zero timer (immediate timout) is catered for in the kernel. */

	if (events & MU_TIMER)
	{
		if (pb->intin[15])			/* high part */
			ret = 0xffff0000L | XAC_M_TIMEOUT;
		else if (pb->intin[14])
			ret = ((long)pb->intin[14] << 16) | XAC_M_TIMEOUT;
		
		DIAG((D.i,client->pid,"Timer val: %d,%d ret: 0x%lx\n", pb->intin[14], pb->intin[15], ret));

		if (ret & XAC_M_TIMEOUT)			/* A non zere wait valuw */
			new_waiting_for |= MU_TIMER;	/* Flag the app as waiting for a timer */
		else
		{
		/* Is this the cause of loosing the key's at regular intervals? */
DIAG((D.i,client->pid,"Done timer for %d\n", client->pid));
			fall_through    |= MU_TIMER;
			ret = XAC_DONE;					/* HR 190601: to be able to combine fall thru events. */
		}
	}

	if (fall_through)
	{
		multi_intout(pb->intout, 0);		/* HR: fill out the mouse data */
		if ((fall_through&MU_TIMER) == 0)
			ret = XAC_DONE;
		if ((fall_through&MU_BUTTON) != 0)
			pb->intout[6] = pending_button.clicks;	/* HR 190601: Pphooo :-( This solves the Thing desk popup missing clicks. */
		pb->intout[0] = fall_through;
		diag_out(pb,client->pid,"fall_thru ");
	}
	else
	if (new_waiting_for)					/* If we actually recognised any of the codes, then set the multi flag */
		client->waiting_for = new_waiting_for | XAWAIT_MULTI;		/* Flag the app as waiting */

	return ret;
}
#else
#include "obsolete\evntmult.h"
#endif

/*
 *	Cancel an event_multi()
 *	- Called when any one of the events we were waiting for occurs
 */
global
void cancel_evnt_multi(XA_CLIENT *client)
{
	client->waiting_for = 0;
	client->em.flags = 0;
}

/*
 *	AES message handling
 */
AES_function XA_evnt_mesag	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
/* HR: static pid array */

	CONTROL(0,1,1)

	if (pending_msgs(lock, client, pb))		/* HR */
		return pb->intout[0] = 1, XAC_DONE;

	client->waiting_for = MU_MESAG;	/* Mark the client as waiting for messages */
	client->waiting_pb = pb;

	return XAC_BLOCK;
}

/*
 *	evnt_button() routine
 */
AES_function XA_evnt_button	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	CONTROL(3,5,1)

	DIAG((D.mouse,-1,"evnt_button for %d\n", client->pid));

	if (pending_button.client == client)
	{
		DIAG((D.mouse,-1,"pending_button %d\n", pending_button.b));
		pending_button.client = nil;			/* is single shot. */
		if (is_bevent(pending_button.b, pending_button.clicks, pb->intin, 3))
		{
			multi_intout(pb->intout, 0);
			pb->intout[0] = pending_button.clicks;
			return XAC_DONE;
		}
	} else
	if (still_button(client, pb->intin))
	{
		DIAG((D.mouse,client->pid,"still_button %d\n", pending_button.b));
		get_mouse();
		if (is_bevent(button.b, 0, pb->intin, 4))
		{
			DIAG((D.mouse,-1,"    --    implicit button %d (lock %d)\n",button.b, S.mouse_lock));
			multi_intout(pb->intout, 0);		/* 0 : for evnt_button */
			pb->intout[0] = 1;
			button.got = true;
			return XAC_DONE;
		}
	}

/* HR static pid array */

	client->waiting_for = MU_BUTTON;	/* Flag the app as waiting for messages */
	client->waiting_pb = pb;				/* Store a pointer to the AESPB to fill when the event */

	return XAC_BLOCK;	/* Returning false blocks the client app to wait for the event */
}

/*
 *	evnt_keybd() routine
 */
AES_function XA_evnt_keybd	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	CONTROL(0,1,0)

	if (pending_key_strokes(lock, pb, client->pid, 0))			/* HR */
		return XAC_DONE;

	client->waiting_for = MU_KEYBD;	/* Flag the app as waiting for messages */
	client->waiting_pb = pb;			/* Store a pointer to the AESPB to fill when the event */
												/* finally arrives. */
	return XAC_BLOCK;	/* Returning false blocks the client app to wait for the event */
}

/*
 *	Event Mouse
 */
AES_function XA_evnt_mouse	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	CONTROL(5,5,0)

	client->waiting_for = MU_M1;	/* Flag the app as waiting for mouse events */
	client->waiting_pb = pb;				/* Store a pointer to the AESPB to fill when the event */
										/*  finally arrives. */
	memset(&client->em,0,sizeof(XA_MOUSE_RECT));
	client->em.m1 = *((RECT *)&pb->intin[1]);
	client->em.flags = (long)(pb->intin[0]) | MU_M1;

	get_mouse();
	if (mouse_ok(client) and is_rect(button.x, button.y, client->em.flags & 1, &client->em.m1))
	{
		multi_intout(pb->intout, 0);
		pb->intout[0] = 1;
		return XAC_DONE;
	}
	return XAC_BLOCK;	/* Returning false blocks the client app to wait for the event */
}

/*
 *	Evnt_timer()
 */

AES_function XA_evnt_timer	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	union
	{
		unsigned long ul;
		unsigned short us[2];
	} ret;

	CONTROL(2,1,0)

	ret.us[1] = XAC_T_TIMEOUT;	
	if (pb->intin[1])
		ret.us[0] = 0xffff;
	else
		ret.us[0] = pb->intin[0];
		
	client->waiting_pb = pb;			/* Store a pointer to the AESPB to fill when the event */
												/*  finally arrives. */
	client->waiting_for = MU_TIMER;	/* Flag the app as waiting for a timer */

	return ret.ul;
}
