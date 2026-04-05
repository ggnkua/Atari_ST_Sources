#include "lib.h"
#include <string.h>

void *memchr(const void *s, int ucharwanted, size_t size)
{
	const char *scan;
	size_t n;

	scan = (const char *) s;
	for (n = size; n > 0; n--)
	{
		if (*scan == (char) ucharwanted)
			return NO_CONST(scan);
		else
			scan++;
	}

	return NULL;
}
