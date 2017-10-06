char *strrev(string)
	char *string;
	{
	register char *p = string, *q, c;

	if(*(q = p))		/* non-empty string? */
		{
		while(*++q)
			;
		while(--q > p)
			{
			c = *q;
			*q = *p;
			*p++ = c;
			}
		}
	return(string);
	}
