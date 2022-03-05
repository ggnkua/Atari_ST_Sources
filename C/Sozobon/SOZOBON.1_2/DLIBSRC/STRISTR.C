#include <stddef.h>

char *stristr(string, pattern)
	register char *string, *pattern;
	{
	register int plen;

	plen = strlen(pattern);
	while(*string)
		{
		if(strnicmp(string, pattern, plen) == 0)
			return(string);
		++string;
		}
	return(NULL);
	}
