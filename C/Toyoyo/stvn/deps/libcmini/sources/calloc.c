/* from the TOS GCC library */
/* malloc, free, realloc: dynamic memory allocation */
/* 5/2/92 sb -- modified for Heat-n-Serve C to accomodate its 16-bit size_t */
/* 5/5/92 sb -- calloc() gets its own file to reduce library drag */

#include <stdlib.h>
#include <string.h>
#include "mallint.h"

#ifdef __GNUC__
#pragma GCC optimize("-O1")
#endif

void *calloc(size_t n, size_t sz)
{
	void *r;
	size_t total;

	total = n * sz;

	r = malloc(total);
	if (r != NULL)
		bzero(r, total);

	return r;
}
