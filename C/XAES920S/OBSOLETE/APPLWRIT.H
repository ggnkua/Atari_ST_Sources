AES_function XA_appl_write 	/* LOCK lock, XA_CLIENT *client, AESPB *pb */
{
	XA_AESMSG_LIST *new_msg, *ml;
	XA_CLIENT *dest_client;
	char *clnt_buf;
	unsigned long retv = XA_OK;
	short dest_id = pb->intin[0];
	short msg_len = pb->intin[1], f;
	char *msg = (char *)pb->addrin[0];
	short *m = (short *)msg;

	CONTROL(2,1,1)

	DIAG((D.appl,client->pid,"appl_write: %d --> %d, len=%d msg = "
						 "%04x,%04x,%04x,%04x,%04x,%04x,%04x,%04x\n",
						client->pid, dest_id, msg_len,
						m[0],m[1],m[2],m[3],m[4],m[5],m[6],m[7] ));

	pb->intout[0] = 0;		/* HR: was [1] !! */
	
	if (dest_id == AESpid) 	/* Just a precaution - we don't want to send messages to ourselves..... */
		return XAC_DONE;

	if (msg_len < 0 || msg_len > 16)
	{
		DIAGS(("length error for %d\n", client->pid));
		msg_len = 16;		/* HR: dont just leave, make something of it. */
	}

	dest_client = Pid2Client(dest_id);

	if (!dest_client)
	{
		DIAGS(("WARNING: Invalid target pid [%d] for appl_write()\n", dest_id));
		return XAC_DONE;
	}
	else if (dest_client->client_end == 0)
		return XAC_DONE;

	if unlocked(clients)
		Sema_Up(CLIENTS_SEMA);
	
	if (dest_client->waiting_for & XAWAIT_MESSAGE)		/* Is the dest client waiting for a message at the moment? */
	{
		if (dest_client->waiting_for & XAWAIT_MULTI)	/* If the client is waiting on a multi, the response is  */
		{												/* slightly different to the evnt_mesag() response. */
			dest_client->waiting_pb->intout[0] = MU_MESAG;
			cancel_evnt_multi(dest_client);				/* HR */
		} else
		{
			dest_client->waiting_pb->intout[0] = 1;
			dest_client->waiting_for = 0;	/* flag client as not waiting for anything */
		}
		
		clnt_buf = (char *)(dest_client->waiting_pb->addrin[0]);
		for (f = 0; f < msg_len; f++)
			clnt_buf[f] = msg[f];			/* Fill in the clients message buffer */

DIAG((D.appl,client->pid,"appl_write: message awaited and written\n"));
		Fwrite(dest_client->kernel_end, (long)sizeof(unsigned long), &retv);	/* Write success to clients reply pipe to unblock the process */
	} else	/* Create a new entry in the destination client's pending messages list */
	{
		new_msg = malloc(sizeof(XA_AESMSG_LIST));
		
		if (new_msg)
		{
		/*	pb->intout[1] = 1;  HR   */

			clnt_buf = (char *)new_msg->message;
			
			for (f = 0; f < msg_len; f++)
				clnt_buf[f] = msg[f];			/* Fill in the new pending list entry with the message */
		
			new_msg->next = NULL;

			if (dest_client->msg)	/* There are already some pending messages */
			{
				for (ml = dest_client->msg; ml->next; ml = ml->next);
				ml->next = new_msg;	/* Append the new message to the list */
			}
			else					/* First entry in the clients pending message list */
				dest_client->msg = new_msg;

DIAG((D.appl,client->pid,"appl_write: message queued\n"));
		}
	}

	pb->intout[0] = 1;		/* HR */

	if unlocked(clients)
		Sema_Dn(CLIENTS_SEMA);
	
	return XAC_DONE;
}
