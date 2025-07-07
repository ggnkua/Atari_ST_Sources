char *strpcpy(dest, start, end)
	register char *dest, *start, *end;
	{
	char *p = dest;

	while((start <= end) && (*dest++ = *start++))
		;
	return(p);
	}
