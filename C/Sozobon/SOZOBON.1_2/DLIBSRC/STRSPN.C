int strspn(string, set)
	register char *string, *set;
	{
	register int n = 0;
	char *strchr();

	while(*string && strchr(set, *string++))
		++n;
	return(n);
	}
