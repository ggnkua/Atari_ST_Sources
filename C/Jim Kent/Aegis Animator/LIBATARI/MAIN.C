
#include "..\\include\\lists.h"
#include <osbind.h>

struct mb
{
int length;
char *pt;
};

#define MSIZE 1024
struct mb marray[MSIZE];

mem_panic()
{
exit(-1);
}

free_access(access)
register struct mb *access;
{
if (access->length)
	mfree(access->pt, access->length);
access->length = 0;
access->pt = NULL;
}

main()
{
register long i;
register int length;
register char *pt, c;
register struct mb *access;

printf("testing memory\n");
init_mem();

for (i=0;i<1000000; i++)
	{
	length = Random() % MSIZE;
	free_access(marray + (length%MSIZE));
	access = marray + (i%MSIZE);
	free_access(access);
	pt = (char *)alloc(length);
	if (pt != NULL)
		{
		access->length = length;
		access->pt = pt;
	/*	block_stuff(pt, 0xfe, length); */
		pt[0] = 0xaa;
		pt[length-1] = 0x55;
		}
	if ( (i&1023) == 0)
		printf("%ld alloc(%d) = %lx\n", i, length, pt);
	if ( (i & 63) == 0)
		{
		if (Cconis())
			{
			c = Cconin();
			switch (c)
				{
				case 'q':
					exit(0);
				case 'f':
					dump_frags(0);
					break;
				}
			}
		}
	}
}

block_stuff(pt, val, len)
register char *pt, val;
register int len;
{
while (--len >= 0)
	*pt++ = val;
}
