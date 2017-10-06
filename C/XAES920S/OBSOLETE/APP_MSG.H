/*
 *	Send an AES message to a client application
 */
SendMessage send_app_message /* LOCK lock, XA_WINDOW *w,
      short dest_pid, short msg, short source_pid,
      short mp3, short mp4, short mp5, short mp6, short mp7 */
{
	XA_AESMSG_LIST *new_msg, *ml;
	XA_CLIENT *dest_client;
	short *clnt_buf;
	unsigned long retv = XA_OK;
	
	if (dest_pid == AESpid) 	/* Just a precaution - we don't want to send app messages to ourselves... */
		return;					/* HR: indeed; messages to the AES itself are switched through the appropriate vector */

	dest_client = Pid2Client(dest_pid);

#if GENERATE_DIAGS
	if (msg == WM_REDRAW)
		DIAG((D.wind, -1, "WM_REDRAW send to %s(%d) %d/%d,%d/%d\n",dest_client->name, dest_pid, mp4, mp5, mp6, mp7));
	DIAG((D.a,source_pid,"send msg %d from %d to %d\n", msg, source_pid, dest_pid));
#endif

/* HR static pid array */
	if (dest_client->pid <= 0)
	{
		DIAG((D.appl,-1,"WARNING: Invalid target pid [%d] for send_app_message()\n", dest_pid));
		return;
	}

	if unlocked(clients)
		Sema_Up(CLIENTS_SEMA);
	
/* Is the dest client waiting for a message at the moment? */
	if (dest_client->waiting_for & XAWAIT_MESSAGE)
	{
		if (dest_client->waiting_for & XAWAIT_MULTI)	/* If the client is waiting on a multi, the response is  */
		{												/* slightly different to the evnt_mesag() response. */
			multi_intout(dest_client->waiting_pb->intout, MU_MESAG);		/* HR: fill out the mouse data!!! */
			cancel_evnt_multi(dest_client);
		} else
		{
			dest_client->waiting_pb->intout[0] = 1;
			dest_client->waiting_for = 0;	/* Flag client as not waiting for anything */
		}

		clnt_buf = (short *)(dest_client->waiting_pb->addrin[0]);
		
		if (!clnt_buf)
		{
			DIAG((D.appl,-1,"WARNING: Invalid target message buffer\n"));
			return;
		}

		*clnt_buf++ = msg;			/* Fill in the client's message buffer */
		*clnt_buf++ = source_pid;
		*clnt_buf++ = 0;
		*clnt_buf++ = mp3;
		*clnt_buf++ = mp4;
		*clnt_buf++ = mp5;
		*clnt_buf++ = mp6;
		*clnt_buf   = mp7;

		Fwrite(dest_client->kernel_end, (long)sizeof(unsigned long), &retv);	/* Write success to client's reply pipe to unblock the process */
	} else	/* Create a new entry in the destination client's pending messages list */
	{
		new_msg = malloc(sizeof(XA_AESMSG_LIST));
		
		if (new_msg)
		{
			clnt_buf = new_msg->message;

			*clnt_buf++ = msg;			/* Fill in the new pending list entry with the message */
			*clnt_buf++ = source_pid;
			*clnt_buf++ = 0;
			*clnt_buf++ = mp3;
			*clnt_buf++ = mp4;
			*clnt_buf++ = mp5;
			*clnt_buf++ = mp6;
			*clnt_buf   = mp7;
			new_msg->next = NULL;

			if (dest_client->msg)	/* There are already some pending messages */
			{
				for(ml = dest_client->msg; ml->next; ml = ml->next)
					;
				ml->next = new_msg;	/* Append the new message to the list */
			} else	/* First entry in the client's pending message list */
			{
				dest_client->msg = new_msg;
			}
		}
	}

	if unlocked(clients)
		Sema_Dn(CLIENTS_SEMA);
}
