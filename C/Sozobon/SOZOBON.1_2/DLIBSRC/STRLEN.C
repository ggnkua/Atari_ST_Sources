int strlen(string)
	register char *string;
	{
	register int n = 0;

	while(*string++)
		++n;
	return(n);
	}
