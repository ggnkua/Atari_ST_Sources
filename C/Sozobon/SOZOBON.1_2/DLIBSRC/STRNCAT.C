char *strncat(dest, source, limit)
	register char *dest, *source;
	register int limit;
	{
	register char *p = dest;

	while(*dest)
		++dest;
	while((limit--) && (*dest++ = *source++))
		;
	*dest = '\0';
	return(p);
	}
