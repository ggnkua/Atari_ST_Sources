char *lmemmove(dest, source, len)
	register char *dest;
	register char *source;
	register long len;
	{
	register char *p = dest;

	if(source < dest)
		{
		dest += len;
		source += len;
		while(len--)
			*--dest = *--source;
		}
	else
		{
		while(len--)
			*dest++ = *source++;
		}
	return(p);
	}
