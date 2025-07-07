#include <ctype.h>

char *strupr(string)
	register char *string;
	{
	register char *p = string;

	while(*string)
		{
		if(islower(*string))
			*string ^= 0x20;
		++string;
		}
	return(p);
	}
