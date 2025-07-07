char *strstr(string, pattern)
	register char *string, *pattern;
	{
	register int plen;
	char *strchr();

	plen = strlen(pattern);
	while(string = strchr(string, *pattern))
		{
		if(strncmp(string, pattern, plen) == 0)
			break;
		++string;
		}
	return(string);
	}
