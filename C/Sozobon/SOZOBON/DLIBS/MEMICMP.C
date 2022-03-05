int memicmp(mem1, mem2, len)
	register char *mem1, *mem2;
	register int len;
	{
	register char c1, c2;

	while(((c1 = tolower(*mem1++)) == (c2 = tolower(*mem2++))) && (--len))
		;
	return(c1 - c2);
	}
