#include <ctype.h>

char *strlwr(string)
	register char *string;
	{
	register char *p = string;

	while(*string)
		{
		if(isupper(*string))
			*string ^= 0x20;
		++string;
		}
	return(p);
	}
