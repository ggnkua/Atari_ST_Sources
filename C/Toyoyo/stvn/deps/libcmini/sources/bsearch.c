/* from Dale Schumacher's dLibs library */

#include "lib.h"

/*
 * This routine is safe in the sense that it does not make
 * assumptions about sizeof(void *). Gcc assumes same as char *
 * when not -ansi, the "other" compiler just barfs.
 *
 * don't fail when key is NULL; it might be some integer value casted to void *
 */

void *bsearch(const void *key,	/* item to search for */
			  const void *base,	/* base address */
			  size_t num,				/* number of elements */
			  size_t size,		/* element size in bytes */
			  int (*cmp)(const void *, const void *))	/* comparison function */
{
	size_t a, b, c;
	int dir;
	const void *p;

	a = 0;
	b = num;
	while (a < b)
	{
		c = (a + b) >> 1;				/* == ((a + b) / 2) */
		p = (const void *) ((const char *) base + (c * size));
		dir = (*cmp) (key, p);
		if (dir < 0)
			b = c;
		else if (dir > 0)
			a = c + 1;
		else
			return NO_CONST(p);
	}
	return NULL;
}
