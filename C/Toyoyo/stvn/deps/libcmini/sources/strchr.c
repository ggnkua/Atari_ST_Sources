#include <string.h>

#ifndef NO_CONST
#  ifdef __GNUC__
#    define NO_CONST(p) __extension__({ union { const void *cs; void *s; } x; x.cs = p; x.s; })
#  else
#    define NO_CONST(p) ((void *)(p))
#  endif
#endif

char *strchr(const char *str, int charwanted)
{
	const char *p = str;
	char c;

	do
	{
		if ((c = *p++) == (char) charwanted)
			return NO_CONST(--p);
	} while (c);

	return NULL;
}
