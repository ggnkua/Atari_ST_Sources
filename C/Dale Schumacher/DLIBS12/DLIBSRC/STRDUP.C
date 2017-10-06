char *strdup(string)
	register char *string;
	{
	register char *p;
	char *malloc();

	if(p = malloc(strlen(string) + 1))
		strcpy(p, string);
	return(p);
	}
