#include <stddef.h>

char *lfind(key, base, num, size, cmp)
	register char *key, *base;
	unsigned int *num;
	register unsigned int size;
	register int (*cmp)();
	{
	register int n = *num;

	while(n--)
		{
		if((*cmp)(base, key) == 0)
			return(base);
		base += size;
		}
	return(NULL);
	}

char *lsearch(key, base, num, size, cmp)
	char *key, *base;
	register unsigned int *num;
	register unsigned int size;
	int (*cmp)();
	{
	register char *p;
	char *memcpy();

	if((p = lfind(key, base, num, size, cmp)) == NULL)
		{
		p = memcpy((base + (size * (*num))), key, size);
		++(*num);
		}
	return(p);
	}
