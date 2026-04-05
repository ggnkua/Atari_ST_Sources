#include <string.h>
#include <ctype.h>

int strnicmp(const char *s1, const char *s2, size_t n)
{
	int c1, c2, d = 0;
	for ( ; n > 0; --n,++s1, ++s2)
	{
		c1 = toupper(*s1);
		c2 = toupper(*s2);
		if (((d = c1 - c2) != 0) || c2 == '\0')
			break;
	}
	return d;
}

#ifdef __GNUC__
int strncasecmp(const char *s1, const char *s2, size_t n) __attribute__((alias("strnicmp")));
#endif
