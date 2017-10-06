/*
 * This is run as a thread

	HR:-(   So may spurious parenthesis', and the only pair that matters is missing !!!!
		    if (flag & 1 == 0)  --> ((flag & 1) == 0)
	Only after I tidied up the lines using vertically aligned parenthesis', I saw it.
	in C binary & is weaker than ==     (I know this bad, it is as it is)
	this result in implicit bracing: if (flag & (1 == 0))
	1 == 0 yields 0, so setting the flag is never detected. Voila ;-)
	Now I must check every & in the whole source tree.
	
 */

/* HR */
ThreadableFunction
check_mouse_rectangle  /* (void *parm) */
{
	XA_CLIENT *client = parm;
	short mb, x, y;
	short kstate;
	long wake_up = 0;
	unsigned long retv = XA_OK;
	char buf[30];

	client = parm;
	if (!client)
		return;

/* if a client is killed in the meantime, waiting_for will become 0 
	and the thread will kill itself */

	while(client->waiting_for & (XAWAIT_MOUSE1|XAWAIT_MOUSE2))
	{
		Psemaphore(2, CLIENTS_SEMAPHORE, -1L);
		vq_mouse(V_handle, &mb, &x, &y);		/* After the sema ???? */
		if (client->em.flags & 4)
		{
			if (   (   ((client->em.flags & 1) == 0)			/* HR:-\ */
			        && (x >= client->em.m1.x)
			        && (x <  client->em.m1.x + client->em.m1.w)
			        && (y >= client->em.m1.y)
			        && (y <  client->em.m1.y + client->em.m1.h)
			        )
				|| (   ((client->em.flags & 1) == 1)			/* HR:-\ */
				    && (   (x <  client->em.m1.x)
				        || (x >= client->em.m1.x + client->em.m1.w)
				        || (y <  client->em.m1.y)
				        || (y >= client->em.m1.y + client->em.m1.h)
				       )
				    )
				)
			{
				vq_key_s(V_handle, &kstate);		/* Get the current keyboard state */
				if (client->waiting_for & XAWAIT_MULTI)		/* If the client is waiting on a multi, the response is  */
				{							/*  slightly different to the evnt_mouse() response. */
					client->waiting_pb->intout[0] = MU_M1;
					client->waiting_pb->intout[1] = x;
					client->waiting_pb->intout[2] = y;
					client->waiting_pb->intout[3] = mb;
					client->waiting_pb->intout[4] = kstate;
					client->waiting_pb->intout[6] = 0;
				} else {
					client->waiting_pb->intout[0] = 1;
					client->waiting_pb->intout[1] = x;
					client->waiting_pb->intout[2] = y;
					client->waiting_pb->intout[3] = 0;
					client->waiting_pb->intout[4] = kstate;
				}
				client->waiting_for = 0;			/* Now client isn't waiting for anything */
				wake_up = 1;
			}
		}

		if (client->em.flags & 8)
		{
			if(    (   ((client->em.flags & 2) == 0)			/* HR:-\ */
			        && (x >= client->em.m2.x)
			        && (x <  client->em.m2.x + client->em.m2.w)
			        && (y >= client->em.m2.y)
			        && (y <  client->em.m2.y + client->em.m2.h)
			        )
				|| (   ((client->em.flags & 2) == 2)			/* HR:-\ */
				    && (   (x <  client->em.m2.x)
				        || (x >= client->em.m2.x + client->em.m2.w)
				        || (y <  client->em.m2.y)
				        || (y >= client->em.m2.y + client->em.m2.h)
				        )
				    )
				)
			{
				vq_key_s(V_handle, &kstate);				/* Get the current keyboard state */
				if (client->waiting_for & XAWAIT_MULTI)		/* If the client is waiting on a multi, the response is  */
				{							/*  slightly different to the evnt_mouse() response. */
					client->waiting_pb->intout[0] = MU_M2;
					client->waiting_pb->intout[1] = x;
					client->waiting_pb->intout[2] = y;
					client->waiting_pb->intout[3] = mb;
					client->waiting_pb->intout[4] = kstate;
					client->waiting_pb->intout[6] = 0;
					client->waiting_for = 0;
					wake_up = 1;
				}
			}
		}

		if(wake_up)
		{
			client->em.flags = 0;
			sprintf(buf,"u:\\pipe\\XaClnt.%d", Client2Pid(client));
			wake_up = Fopen(buf, O_RDWR);
			Fwrite(wake_up, sizeof(unsigned long), &retv);
			Fclose(wake_up);
			return;
		}
		
		Psemaphore(3, CLIENTS_SEMAPHORE, -1L);
		Syield();
	}	/* thread's main loop */

	return;
}

