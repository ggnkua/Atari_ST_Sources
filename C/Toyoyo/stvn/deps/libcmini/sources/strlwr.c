#include <ctype.h>
#include <string.h>

char *strlwr(char *str)
{
	char *p = str;

	if (p)
	{
		while (*str)
		{
			*str = tolower((unsigned char)*str);
			++str;
		}
	}
	return p;
}
