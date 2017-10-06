int strncmp(str1, str2, limit)
	register char *str1, *str2;
	register int limit;
	{
	for(; ((--limit) && (*str1 == *str2)); ++str1, ++str2)
		if(*str1 == '\0')
			return(0);
	return(*str1 - *str2);
	}
