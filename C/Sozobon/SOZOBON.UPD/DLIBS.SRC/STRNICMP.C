int strnicmp(str1, str2, limit)
	register char *str1, *str2;
	register int limit;
	{
	register char c1, c2;

	while(((c1 = tolower(*str1++)) == (c2 = tolower(*str2++))) && --limit)
		if(c1 == '\0')
			return(0);
	return(c1 - c2);
	}
