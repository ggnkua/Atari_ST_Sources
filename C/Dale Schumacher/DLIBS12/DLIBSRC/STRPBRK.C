#include <stddef.h>

char *strpbrk(string, set)
	register char *string, *set;
	{
	char *strchr();

	while(*string)
		{
		if(strchr(set, *string))
			return(string);
		++string;
		}
	return(NULL);
	}
