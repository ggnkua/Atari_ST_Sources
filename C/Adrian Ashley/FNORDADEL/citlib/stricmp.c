/*
 * Stolen from dLibs 1.2 by Dale Schumacher
 */

int stricmp(str1, str2)
	register char *str1, *str2;
	{
	register char c1, c2;

	while((c1 = tolower(*str1++)) == (c2 = tolower(*str2++)))
		if(c1 == '\0')
			return(0);
	return(c1 - c2);
	}
