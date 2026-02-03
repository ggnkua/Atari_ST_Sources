/* from Henry Spencer's stringlib */

#include <stddef.h>
#include <string.h>

/*
 * memchr - search for a byte
 */

void *
memchr(s, ucharwanted, size)
const void * s;
int ucharwanted;
size_t size;
{
	register const char *scan;
	register size_t n;

	scan = (const char *) s;
	for (n = size; n > 0; n--)
		if (*scan == (char) ucharwanted)
			return((void *)scan);
		else
			scan++;

	return(NULL);
}
