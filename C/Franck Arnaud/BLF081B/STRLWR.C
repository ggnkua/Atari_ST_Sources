/* strlwr compatibility - public domain: may be copied & sold freely */

#include <ctype.h>

char *strlwr(char *s)
{
	while(*s)
	{ 
		*s=tolower(*s);
		s++;
	}
	return s;
}
