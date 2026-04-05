#include <string.h>
#include <ctype.h>

int stricmp(const char *s1, const char *s2)
{
	int c1, c2, d = 0;
	for ( ; ; ++s1, ++s2)
	{
		c1 = toupper((unsigned char)*s1);
		c2 = toupper((unsigned char)*s2);
		if (((d = c1 - c2) != 0) || c2 == '\0')
			break;
	}
	return d;
}

#ifdef __GNUC__
int strcasecmp(const char *s1, const char *s2) __attribute__((alias("stricmp")));
#endif
