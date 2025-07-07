char *strset(string, c)
	char *string;
	register char c;
	{
	register char *p = string;

	while(*p)
		*p++ = c;
	return(string);
	}

char *strnset(string, c, n)
	char *string;
	register char c;
	register int n;
	{
	register char *p = string;

	while(n-- && *p)
		*p++ = c;
	return(string);
	}
