int memcmp(mem1, mem2, len)
	register char *mem1, *mem2;
	register int len;
	{
	while((--len) && (*mem1 == *mem2))
		{
		++mem1;
		++mem2;
		}
	return(*mem1 - *mem2);
	}
