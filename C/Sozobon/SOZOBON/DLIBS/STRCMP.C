int strcmp(str1, str2)
	register char *str1, *str2;
	{
	for(; *str1 == *str2; ++str1, ++str2)
		if(*str1 == '\0')
			return(0);
	return(*str1 - *str2);
	}
