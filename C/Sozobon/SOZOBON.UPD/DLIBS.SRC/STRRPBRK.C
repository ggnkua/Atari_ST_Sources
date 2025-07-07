#include <stddef.h>

char *strrpbrk(string, set)
	register char *string, *set;
	{
	register char *p;
	char *strrchr(), *strchr();

	p = strrchr(string, '\0');		/* start at EOS */
	while(string != p)
		{
		if(strchr(set, *--p))
			return(p);
		}
	return(NULL);
	}
