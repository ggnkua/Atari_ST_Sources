#include <stdio.h>

int	_bsearch;	/* index of element found, or where to insert */

char *bsearch(key, base, num, size, cmp)
	register char *key;		/* item to search for */
	register char *base;		/* base address */
	int num;			/* number of elements */
	register int size;		/* element size in bytes */
	register int (*cmp)();		/* comparison function */
	{
	register int a, b, c, dir;

	a = 0;
	b = num - 1;
	while(a <= b)
		{
		c = (a + b) >> 1;	/* == ((a + b) / 2) */
		if (dir = (*cmp)((base + (c * size)), key))
			{
			if (dir > 0)
				b = c - 1;
			else /* (dir < 0) */
				a = c + 1;
			}
		else
			{
			_bsearch = c;
			return(base + (c * size));
			}
		}
	_bsearch = b;	
	return(NULL);
	}
