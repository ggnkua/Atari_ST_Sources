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
#include "xa_input.h"
#include "rectlist.h"
#include "objects.h"
#include "widgets.h"

static
short pending_msgs(LOCK lock, XA_CLIENT *client, AESPB *pb, short type)
{
	short rtn;

	if unlocked(clients)				/* I dont think these are needed. */
		Sema_Up(CLIENTS_SEMA);

	/* Is there a widget still active (like a scroll arrow)? If so, check with the action first
	 * as it may result in some messages (just in case we've not got any already)
	 */
	 
	if (!client->msg)
	{
		if (client->widget_active)
		{
			XA_PENDING_WIDGET *pending = client->widget_active;
			rtn = (*pending->action)(lock|clients, pending->wind, pending->widg);	/* Call the pending action */

			if (rtn)	/* If the widget click/drag function returned TRUE we reset the state of the widget */
			{
				pending->widg->stat = NONE;					/* Flag the widget as de-selected */
				display_widget(lock|clients, pending->wind, pending->widg);
			}
		}
	}

	if (client->msg)	/* Are there any messages pending? */
	{
		MSG_BUF *buf = (MSG_BUF *)(pb->addrin[0]);
		XA_AESMSG_LIST *msg = client->msg;
		client->msg = msg->next;
	
		*buf = msg->message;				/* Copy the message into the clients buffer */
		DIAG((D.m,-1,"Got pending message %s for %s(%d)\n", pmsg(buf->m[0]), client->name, client->pid));
		multi_intout(pb->intout, type, -1);		/* HR: fill out mouse data!!! */
		free(msg);
		if unlocked(clients)
			Sema_Dn(CLIENTS_SEMA);
		return TRUE;		/* Return TRUE to unblock the client */
	}
	
	client->waiting_for = MU_MESAG;		/* Mark the client as waiting for messages */
	client->waiting_pb = pb;
	if unlocked(clients)
		Sema_Dn(CLIENTS_SEMA);
	return FALSE;
}

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
				multi_intout(pb->intout, type, key.raw.conin.state);
				if (type&MU_NORMKEY)			/* HR 300501: XaAES extension: normalized key codes. */
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

/*
 *	The essential evnt_multi() call
 */

#if GENERATE_DIAGS
static
char *xev[] = {"KBD","BUT","M1","M2","MSG","TIM","MX","NKBD","8","9","10","11","12","13","14","15"};
static
void show_ev(unsigned short ev, char *x)
{
	short i=0;
	*x=0;
	while(ev)
	{
		if (ev&1)
			strcat(x,xev[i]), strcat(x,"|");
		ev>>=1;
		i++;
	}
	i = strlen(x)-1;
	if (x[i] == '|')
		x[i] = 0;
}
#endif

AES_function XA_evnt_multi	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	short events = pb->intin[0];
	unsigned long ret = XAC_BLOCK;		/* HR: another example of choosing inconvenient default fixed. */
	short f, rtn, new_waiting_for = 0;

	CONTROL(16,7,1)

	client->waiting_pb = pb;	/* Store a pointer to the AESPB to fill when the event(s) */
								/*  finally arrive. */

/* HR */
#if GENERATE_DIAGS
	{
		char evtxt[128];
		show_ev(events,evtxt);
		DIAG((D.multi,client->pid,"evnt_multi for %d, evnt=%s, clks=0x%x, msk=0x%x, bst=x%x T:%d\n",
				client->pid,evtxt,pb->intin[1],pb->intin[2],pb->intin[3], (events&MU_TIMER) ? pb->intin[14] : -1));
	}
#endif

/*	if ((events&MU_TIMER) and pb->intin[14] == 0 and pb->intin[15] == 0)
		pb->intin[14] = 1;
*/
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
			DIAG((D.mouse,-1,"pending_button multi %d\n", pending_button.state));
			pending_button.client = nil;			/* is single shot. */
			multi_intout(pb->intout, MU_BUTTON, -1);
			if (is_bevent(pending_button.state, pending_button.clicks, pb->intin[1], pb->intin[2], pb->intin[3], 1))
			{
				if unlocked(pending)
					Sema_Dn(PENDING_SEMA);
				return XAC_DONE;
			}
			if unlocked(pending)
				Sema_Dn(PENDING_SEMA);
		}
		else
		{
			if unlocked(pending)
				Sema_Dn(PENDING_SEMA);
#if 0
			multi_intout(pb->intout, MU_BUTTON, -1);		/* HR: we need the vq_mouse anyhow, might as well do the rest. */
			if (is_bevent(pb->intout[3], 1, pb->intin[1], pb->intin[2], pb->intin[3], 2))
			{
				if (   !S.mouse_lock
					|| (S.mouse_lock && S.mouse_lock == client->pid)
					)
					return XAC_DONE;
			}
#else
			if (pb->intin[3] == 0 && pb->intin[1] < 2)
			{
				multi_intout(pb->intout, MU_BUTTON, -1);		/* HR: we need the vq_mouse anyhow, might as well do the rest. */
				if (is_bevent(pb->intout[3], 0, pb->intin[1], pb->intin[2], pb->intin[3], 2))
					return XAC_DONE;
			}
#endif
		}

		pb->intout[0] = 0;
		new_waiting_for |= MU_BUTTON;		/* Flag the app as waiting for button changes */
	}

	if (events & MU_NORMKEY)
		events |= MU_KEYBD;

	if (events & MU_KEYBD)		
	{
		short ev = events&(MU_NORMKEY|MU_KEYBD);
		if (pending_key_strokes(lock, pb, client->pid, ev))			/* HR */
			return XAC_DONE;
		else
			new_waiting_for |= ev;			/* Flag the app as waiting for keypresses */
	}

/* HR: event data are now in the client structure */
/*     040401: Implemented fall thru. */
	if (events & (MU_M1|MU_M2|MU_MX))
	{
		short b,x,y;
		vq_mouse(C.vh, &b, &x, &y);
		memset(&client->em,0,sizeof(XA_MOUSE_RECT));
		if (events & MU_M1)					/* Mouse rectangle tracking */
		{
			RECT *r = (RECT *)&pb->intin[5];
			client->em.m1 = *r;
			client->em.flags = pb->intin[4] | MU_M1;
DIAG((D.multi,client->pid,"    M1 rectangle: %d/%d,%d/%d, flag: 0x%x\n", r->x, r->y, r->w, r->h, client->em.flags));
			if (is_rect(x, y, client->em.flags & 1, &client->em.m1))
			{
				multi_intout(client->waiting_pb->intout, MU_M1, -1);
				return XAC_DONE;
			}

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
			if (is_rect(x, y, client->em.flags & 2, &client->em.m2))
			{
				multi_intout(client->waiting_pb->intout, MU_M2, -1);
				return XAC_DONE;
			}

			new_waiting_for |= MU_M2;
		}
	}

	if (events & MU_MESAG)
	{
		if (pending_msgs(lock, client, pb, MU_MESAG))		/* HR */
			return XAC_DONE;

		new_waiting_for |= MU_MESAG;		/* Mark the client as waiting for messages */
	}
	
	/* HR: a zero timer (immediate timout) is catered for in the kernel. */

	if (events & MU_TIMER)
	{
		if (pb->intin[15])			/* high part */
			ret = 0xffff0000L | XAC_M_TIMEOUT;
		else if (pb->intin[14])
			ret = ((long)pb->intin[14] << 16) | XAC_M_TIMEOUT;
		
		DIAG((D.i,-1,"Timer val: %d,%d ret: 0x%lx\n", pb->intin[14], pb->intin[15], ret));

		if (ret & XAC_M_TIMEOUT)
		{
			new_waiting_for |= MU_TIMER;	/* Flag the app as waiting for a timer */
		} elif (new_waiting_for == 0)			/* HR: Do not loose the other events */
		{
			multi_intout(pb->intout, MU_TIMER, -1);	/* HR: fill out the mouse data */

		/* Is this the cause of loosing the key's at regular intervals? */
			new_waiting_for = 0;
DIAG((D.i,-1,"Done timer for %d\n", client->pid));
			ret = XAC_DONE;
		} else
		{
			new_waiting_for |= MU_TIMER;	/* HR: make it 1 millisecond */
			ret = (1L << 16) | XAC_M_TIMEOUT;
		}
	}

	if (new_waiting_for)					/* If we actually recognised any of the codes, then set the multi flag */
		new_waiting_for |= XAWAIT_MULTI;
	
	client->waiting_for = new_waiting_for;			/* Flag the app as waiting */

	return ret;
}

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

	if (pending_msgs(lock, client, pb, 1))		/* HR */
		return XAC_DONE;
	
	client->waiting_for = MU_MESAG;	/* Mark the client as waiting for messages */
	client->waiting_pb = pb;

	return XAC_BLOCK;
}

/*
 *	evnt_button() routine
 */
AES_function XA_evnt_button	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	short mb, x, y;

	CONTROL(3,5,1)

	if (pending_button.client == client)
	{
		DIAG((D.mouse,-1,"pending_button %d\n", pending_button.state));
		pending_button.client = nil;			/* is single shot. */
		multi_intout(pb->intout, 0, -1);
		if (is_bevent(pending_button.state, pending_button.clicks, pb->intin[0], pb->intin[1], pb->intin[2], 3))
			return pb->intout[0] = 1, XAC_DONE;
	}
	else
	if (pb->intin[2] == 0 && pb->intin[0] < 2)
	{
		/* HR: multi_intout includes vq_mouse, keys if -1 */
		multi_intout(pb->intout, 0, -1);		/* 0 : for evnt_button */
		if (is_bevent(pb->intout[3], 0, pb->intin[0], pb->intin[1], pb->intin[2], 4))
			return pb->intout[0] = 1, XAC_DONE;
	}

/* HR static pid array */

	client->waiting_for = MU_BUTTON;	/* Flag the app as waiting for messages */
	client->waiting_pb = pb;				/* Store a pointer to the AESPB to fill when the event */

	return XAC_BLOCK;	/* Returning FALSE blocks the client app to wait for the event */
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
	return XAC_BLOCK;	/* Returning FALSE blocks the client app to wait for the event */
}

/*
 *	Event Mouse
 */
AES_function XA_evnt_mouse	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	short b,x,y;
	CONTROL(5,5,0)

	client->waiting_for = MU_M1;	/* Flag the app as waiting for mouse events */
	client->waiting_pb = pb;				/* Store a pointer to the AESPB to fill when the event */
										/*  finally arrives. */
	memset(&client->em,0,sizeof(XA_MOUSE_RECT));
	client->em.m1 = *((RECT *)&pb->intin[1]);
	client->em.flags = (long)(pb->intin[0]) | MU_M1;

	vq_mouse(C.vh, &b, &x, &y);
	if (is_rect(x, y, client->em.flags & 1, &client->em.m1))
	{
		multi_intout(pb->intout, 0, -1);
		pb->intout[0] = 1;
		return XAC_DONE;
	}
	return XAC_BLOCK;	/* Returning FALSE blocks the client app to wait for the event */
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
