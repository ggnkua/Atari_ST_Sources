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
		show_bits(events, "evnt=", xev, evtxt);
		DIAG((D.multi,client->pid,"evnt_multi for %d, %s clks=0x%x, msk=0x%x, bst=x%x T:%d\n",
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
				diag_out(pb, "[1] ")
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
				{
					diag_out(pb, "[2] ")
					return XAC_DONE;
				}
			}
#else
			if (pb->intin[3] == 0 && pb->intin[1] < 2)
			{
				multi_intout(pb->intout, MU_BUTTON, -1);		/* HR: we need the vq_mouse anyhow, might as well do the rest. */
				if (is_bevent(pb->intout[3], 0, pb->intin[1], pb->intin[2], pb->intin[3], 2))
				{
					diag_out(pb, "[3] ")
					return XAC_DONE;
				}
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
		{
			diag_out(pb, "[4] ")
			return XAC_DONE;
		}
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
				multi_intout(pb->intout, MU_M1, -1);
				diag_out(pb, "[5] ")
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
				multi_intout(pb->intout, MU_M2, -1);
				diag_out(pb, "[6] ")
				return XAC_DONE;
			}

			new_waiting_for |= MU_M2;
		}
	}

	if (events & MU_MESAG)
	{
		if (pending_msgs(lock, client, pb, MU_MESAG))		/* HR */
		{
			diag_out(pb, "[7] ")
			return XAC_DONE;
		}
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
			diag_out(pb, "[8] ")
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
