/*
 *  libshare: a dirty patch to make LDG compiled against mintlib shareable
 *
 *  by Arnaud BERCEGEAY (Feb 2004)
 */

/* from the TOS GCC library */
/* malloc, free, realloc: dynamic memory allocation */
/* 5/2/92 sb -- modified for Heat-n-Serve C to accomodate its 16-bit size_t */
/* 5/5/92 sb -- calloc() gets its own file to reduce library drag */

#include <stdlib.h>
#include <string.h>

void *
calloc (size_t n, size_t sz)
{
	register void *r;
	register size_t total;

	total = n * sz;

	r = malloc (total);
	if (r != NULL)
		__bzero (r, total);

	return r;
}
