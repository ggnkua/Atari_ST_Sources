#include <stddef.h>
#include <malloc.h>

#define	MAXBLK		16
#define	FREE		0x00
#define	USED		0x80
#define	NULLBLK		0x80000000L

extern	char	*_mblk[];		/* memory heap pointers */
extern	long	_msiz[];		/* memory heap sizes */

static long *unlinkblk(addr)
	register long *addr;
/*
 *	Unlink memory block at <addr> from free memory chain.
 */
	{
	register int i;
	register long *p, *q;

	for(i=0; i<MAXBLK; ++i)
		{
		if((q = p = ((long *) _mblk[i])) == NULL)
			continue;		/* skip unavailable blocks */
		if((addr < p) || (addr > ((long *) (((char *) p)+_msiz[i]))))
			continue;		/* block range check */
		while(p = ((long *) *q))
			{
			if(p == addr)		/* found the right block */
				{
				q[0] = p[1];	/* unlink it */
				return(p);
				}
			q = p + 1;
			}
		}
	return(NULL);
	}

char *realloc(addr, size)
	register long *addr;
	unsigned int size;
	{
	register long n, m, d, *p, *q;
	char *lalloc();

	if(addr == NULL)
		return(lalloc((long) size));
	if(size == 0)
		{
		free(addr);
		return(addr);
		}
	p = addr - 1;
	n = p[0] & 0x00FFFFFFL;			/* get actual block size */
	m = (((long) size) + 5L) & ~1L;		/* calculate new block size */
	if(m <= n)			/* shrink... */
		{
		if((n -= m) >= 8L)		/* big enough to shrink */
			{
			/* calculate new break */
			q = ((long *) (((char *) p) + m));
			p[0] = m;
			*((char *) p) = USED;
			q[0] = n;
			*((char *) q) = USED;
			free(q + 1);		/* free remainder */
			}
		}
	else					/* grow... */
		{
		d = *(q = ((long *) (((char *) p) + n)));
		if((d > 0) &&			/* next block is free */
		   (m <= (n + d)) &&		/* combination is big enough */
		   (unlinkblk(q)))		/* block can be unlinked */
		   	{
			p[0] = (n + d);
			*((char *) p) = USED;	/* extend in place */
			return(realloc(addr, size));
			}
		if(p = ((long *) lalloc(m-4L)))	/* allocate bigger block */
			{
			lmemcpy(p, addr, n-4L);	/* copy old data */
			free(addr);		/* free old block */
			addr = p;
			}
		else
			addr = NULL;
		}
	return(addr);
	}
