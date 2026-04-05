#include <ctype.h>
#include <string.h>

char *strupr(char *str)
{
	char *p = str;

	if (p)
	{
		while (*str)
		{
			*str = toupper((unsigned char)*str);
			++str;
		}
	}
	return p;
}
