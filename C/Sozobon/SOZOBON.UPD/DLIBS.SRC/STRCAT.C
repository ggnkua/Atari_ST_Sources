char *strcat(dest, source)
	register char *dest, *source;
	{
	register char *p = dest;

	while(*dest)
		++dest;
	while(*dest++ = *source++)
		;
	return(p);
	}
