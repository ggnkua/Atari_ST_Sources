/* ex xa_fsel.c */

	t = (char *)pb->addrin[0];

	#if 0
		if((t[0] | 32) != 'u')
		{		
			if (t[1] == ':')
			{
		 		while(*t)
					t[3] = *t++;
				t = (char *)pb->addrin[0];
				t[3] = t[3] | 32;
			} else
			{
				while(*t)
					t[5] = *t++;
				t = (char *)pb->addrin[0];
				t[1] = ':';
				t[2] = slash;
				t[3] = (char)Dgetdrv() + 'a';
			}
			t[0] = 'u';
		}
	#else	
		if ((t[1] == ':') && ((t[0] | 32) != 'u'))
		{
			t[1] = t[0] | 32;
			t[0] = slash;
		}
	#endif

	for(; *t; t++)
	{
		if(*t == back_slash)
			*t = slash;
	}

	if (!Pdomain(-1))	/* For TOS domain programs, convert path to lower case */
	{
		for(t = (char *)pb->addrin[0]; *t; t++)
		{
			if((*t >= 'A') && (*t <= 'Z'))
				*t |= 32;
		}
		for(t = (char *)pb->addrin[1]; *t; t++)
		{
			if((*t >= 'A') && (*t <= 'Z'))
				*t |= 32;
		}
	}
	DIAG((D.fsel,-1,"modified path=%s\n", (char *)pb->addrin[0]));
