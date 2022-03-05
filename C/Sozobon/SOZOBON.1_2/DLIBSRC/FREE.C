#include <osbind.h>
#include <stdio.h>

#define	MAXBLK		16
#define	FREE		0x00
#define	USED		0x80
#define	NULLBLK		0x80000000L

extern	char	*_mblk[];		/* memory heap pointers */
extern	long	_msiz[];		/* memory heap sizes */

static mergeblk(i)
	int i;
/*
 *	Merge adjacent "free" blocks in heap <i>.  Links in the free chain
 *	are guarenteed to be in forward order.
 */
	{
	register long n, *p, *q;

	p = (long *) _mblk[i];
	if((p = ((long *) *p)) == NULL)			/* empty chain */
		return;
	while(q = ((long *) p[1]))
		{
		n = *p;
		if(((char *) p)+n == ((char *) q)) /* adjacent free block */
			{
			p[1] = q[1];		/* re-link free chain */
			*p += *q;		/* adjust block size */
			}
		else
			p = q;
		}
	/* check to see if the entire heap can be returned to the OS */
	q = ((long *) (((char *) p) + (*p)));
	if((((long *) _mblk[i]) == (p - 1)) && ((*q) == NULLBLK))
		{
		Mfree(_mblk[i]);
		_mblk[i] = NULL;
		_msiz[i] = 0L;
		}
	}

/*--------------------- Documented Functions ---------------------------*/

free(addr)
	register long *addr;
	{
	register int i;
	register long *p, *q;

	if(addr == NULL)
		return(TRUE);
	--addr;					/* point to block header */
	for(i=0; i<MAXBLK; ++i)
		{
		if((p = ((long *) _mblk[i])) == NULL)
			continue;		/* skip unavailable blocks */
		if((addr < p) || (addr > ((long *) (((char *) p)+_msiz[i]))))
			continue;		/* block range check */
		while(q = ((long *) *p))
			{
			++q;
			if((addr < q) && (addr > p))
				break;
			p = q;
			}
		*((char *) addr) = FREE;	/* link into free chain */
		addr[1] = *p;
		*p = ((long) addr);
		mergeblk(i);
		return(TRUE);
		}
	return(FALSE);
	}
