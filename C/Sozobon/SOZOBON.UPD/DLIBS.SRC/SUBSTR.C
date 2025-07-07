char *substr(dest, source, start, end)
	register char *dest, *source;
	register int start, end;
	{
	register char *p = dest;
	register int n;

	n = strlen(source);
	if(start > n)
		start = n - 1;
	if(end > n)
		end = n - 1;
	source += start;
	while(start++ <= end)
		*p++ = *source++;
	*p = '\0';
	return(dest);
	}

char *subnstr(dest, source, start, length)
	register char *dest, *source;
	register int start, length;
	{
	register char *p = dest;
	register int n;

	n = strlen(source);
	if(start > n)
		start = n - 1;
	source += start;
	while(*source && (length--))
		*p++ = *source++;
	*p = '\0';
	return(dest);
	}
