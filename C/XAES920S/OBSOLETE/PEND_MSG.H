static
short pending_msgs(LOCK lock, XA_CLIENT *client, AESPB *pb, short type)
{
	short rtn;

	if unlocked(clients)				/* I dont think these are needed. */
		Sema_Up(CLIENTS_SEMA);

	/* Is there a widget active (like a scroll arrow)? If so, check with the action first
	 * as it may result in some messages (just in case we've not got any already)
	 */
	/* The reason why it is done in here is that this way it works in sort of a feed back mode.
	   The widget is only actioned in case of a MESAG event wait from the client.
	   Otherwise every pixel slider move would result in a message sent.
	*/

	if (!client->msg)
	{
		if (widget_active.widg)		/* HR 050601: This is NOT a fail save! The whole mechanism depends on this. */
		{
			XA_WINDOW *wind = widget_active.wind;
			XA_WIDGET *widg = widget_active.widg;
			DIAG((D.mouse,-1,"pending_msgs: do pending action\n"));
			rtn = (*widget_active.action)(lock|clients, wind, widg);	/* Call the pending action */

			if (rtn)	/* If the widget click/drag function returned true we reset the state of the widget */
			{
/* HR: 050601: if the pending widget is canceled, its state is undefined!!!!!! */
				DIAG((D.mouse,-1,"Deselect pending widget\n"));
				redisplay_widget(lock|clients, wind, widg, NONE); /* Flag the widget as de-selected */
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
		return true;		/* Return true to unblock the client */
	}
	
	client->waiting_for = MU_MESAG;		/* Mark the client as waiting for messages */
	client->waiting_pb = pb;
	if unlocked(clients)
		Sema_Dn(CLIENTS_SEMA);
	return false;
}
