#include <string.h>

char *strrchr(const char *s, int c)
{
	const char *cp = s + strlen(s);

	do
	{
		if (*cp == (char) c)
			return (char*)cp;
	} while (--cp >= s);

	return NULL;
}
