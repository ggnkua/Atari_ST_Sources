char *strncpy(dest, source, limit)
	register char *dest, *source;
	register int limit;
	{
	register char *p = dest;

	while((limit--) && (*dest++ = *source++))
		;
	return(p);
	}
