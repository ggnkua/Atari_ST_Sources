char *strtrim(string, junk)
	register char *string;
	register char *junk;
	{
	register char *p = string;
	char *strchr(), *strrchr();

	while(*p && strchr(junk, *p))
		++p;
	if(*p)
		{
		string = strrchr(p, '\0');
		while(strchr(junk, *--string))
			;
		*++string = '\0';
		}
	return(p);
	}
