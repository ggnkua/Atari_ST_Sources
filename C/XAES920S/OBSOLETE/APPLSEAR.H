/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

AESroutine XA_appl_search	/* XA_CLIENT *client, AESPB *pb */
{
	XA_CLIENT *next = NULL;
	short cpid, mpid = MAX_PID;
	bool lang = false;
	char *fname = (char *)pb->addrin[0];
	short *o = pb->intout, f = pb->intin[0];

DIAG((D.appl,-1,"appl_search for %d: ii=%d\n", client->pid, f));

	o[0] = 1;

	if (f < 0)
	{
		cpid = -f;
		if (cpid < 1 || cpid > MAX_PID)
			cpid = 1;
		mpid = cpid + 1;
		lang = true;
	} else
	{
		switch(f)
		{
		case APP_FIRST:
			cpid = 1;		/* HR: simply the first */
			break;
		case APP_NEXT:
			cpid = (short)(client->temp) + 1;	 /* HR */
			break;
		case APP_DESK:		/* N.aes  short name of desktop program */
			cpid = DSKpid;
			mpid = cpid + 1;
			break;
		default:			/* HR: safety */
			o[0] = 0;
			return XAC_DONE;
		}
	}

	/* find next active client */

	while (cpid < mpid)
	{
		next = Pid2Client(cpid);		/* HR */
		if (next)
			if (next->client_end)
				break;
		cpid++;
	}
	
	if (!next || (next && !next->client_end))
		o[0] = 0;	/* No more clients or no active clients */
	else
	{
/* HR: replies according to the compendium */		
		if (cpid == AESpid)
			o[1] = APP_SYSTEM;
		else if (cpid == DSKpid)	/* HR: :-) */
			o[1] = APP_APPLICATION | APP_SHELL;
		else if (next->client_type == XA_CT_ACC)
			o[1] = APP_ACCESSORY;
		else
			o[1] = APP_APPLICATION;

		o[2] = cpid;

		if (lang)
			strcpy(fname, next->name);
		else
		{
			strncpy(fname, next->proc_name, 8); /* HR */
			fname[8] = '\0';
		}
		
		client->temp = (void *)cpid;	/* HR */
DIAG((D.appl,-1,"       0x%x  %d '%s'\n", o[1], o[2], fname));
	}

	return XAC_DONE;
}
