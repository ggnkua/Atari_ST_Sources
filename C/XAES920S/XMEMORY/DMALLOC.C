#include <hr.h>
#include <stdio.h>
#include <stddef.h>

/*
 *	Up to 64 heaps are allocated from the operating system as they are
 *	needed to fill requests for dynamic memory.  These heaps are them
 *	divided into blocks for parcelling out by the user-callable memory
 *	allocation routines.  If all the storage in a heap is freed, the heap
 *	will be freed to the OS.  Each heap begins with a pointer to the first
 *	free block, or NULL if there are no free blocks in this heap.  Each
 *	block begins with a 4-byte header which defines the number of bytes
 *	in the block, including the header.  Since blocks in a heap are known
 *	to be contiguous, this value also defines the beginning of the next
 *	block in the heap.  The high bit of the header is set if the block
 *	is used and clear if it is free.  The heaps ends with a block header
 *	which indicates a used block containing 0 bytes.  The is the constant
 *	value NULLBLK.  Free blocks contain an additional pointer field,
 *	immediatly following the header, which is a pointer to the header of
 *	the next free block, or NULL.
 */

#define	MAXBLK		64
#define	FREE		0x7FFFFFFFL
#define	USED		0x80000000L
#define	NULLBLK		0x80000000L

static bool init = TRUE;

typedef struct malloc_block
{
	long *pt;
	long sz;	
} M_BLK;

M_BLK  _mblk[MAXBLK];		/* system memory heaps */

#define  _BLKSIZ  8192L		/* Malloc() in 8K chunks of longs */

/*
 *	Get a new major block from the system that will hold at least
 *	<size> bytes.
 */
extern char inname[];
extern int lineno;
extern FILE *bugf;

static long *
makeblk(long size)
{
	int i;
	long *p;
	long n, minsiz, bsiz, *q;

	minsiz = (size + 0x80) & ~0x7F;	/* round up to nearest 128 longs */
	bsiz = minsiz < _BLKSIZ ? _BLKSIZ : minsiz;

	for(i=0; i<MAXBLK; ++i)
	{
		if (_mblk[i].pt eq NULL)		/* skip used heaps */
		{		
			n = (long)Malloc(-1L);
			n = ~0x7FL & (n - 0x80L);	/* system memory available */
			if (n < bsiz)
				if (n < minsiz)
					return NULL;
				else
					bsiz = minsiz;
			p = Mxalloc(bsiz*4,3);
#ifdef MONITOR
			fprintf(bugf,"allocated block %d, size:%ld -- %s(%d)\n",i,bsiz,inname ? inname : "~~",lineno);
#endif
			_mblk[i].pt = p;
			_mblk[i].sz = bsiz;

			*(p + bsiz - 1) = NULLBLK;	/* thread starting blocks */
			q = p + 1;
			q[-1] = (long)q;
			q[0] = bsiz - 2;
			q[1] = NULL;
			p[1] &= FREE;
			return p;
		}
	}
	return NULL;
}

/*
 *	Split block at *<addr> into a used block containing <size> bytes
 *	and a free block containing the remainder.
 */
static long *
splitblk(long **addr, long size)
{
	long n, *p, *q;

	n = *(p = *addr);			/* get actual block size */
	if (n > size + 2)			/* is it worth splitting? */
	{
		n -= size;
		/* calculate "break" point */
		q = p + size;
		p[0] = size;
		q[0] = n;
		q[1] = p[1];
		*addr = q;
	}
	else					/* not worth splitting */
		*addr = ((long *) p[1]);	/* remove from free list */
	*p |= USED;			/* mark block "used" */
	return p;
}

/*
 *	Find the smallest unused block containing at least <size> longs.
 *
static long *
findblk(long size)
{
	int i;
	long n, tsiz = 0x7FFFFFFFL, *p, *q, *tptr = NULL;

	for(i=0; i<MAXBLK; ++i)
		if ((p = _mblk[i].pt) ne NULL)	/* skip unavailable heaps */
		{
			while ( (q = *(long **)p) ne NULL)		/* free ptr */
			{
				n = *q;							/* free space */
				if (n >= size and n < tsiz)		/* it fits */
				{
					tsiz = n;
					tptr = p;
				}
				p = q + 1;
			}
		}
	return tptr;
}
*/

/*
 *	Find the first unused block containing at least <size> longs.
 */
static long *
findblk(long size)
{
	int i;
	long n, *p, *q;

	for(i=0; i<MAXBLK; ++i)
		if ((p = _mblk[i].pt) ne NULL)	/* skip unavailable heaps */
			while ( (q = *(long **)p) ne NULL)		/* free ptr */
			{
				n = *q;							/* free space */
				if (n >= size)		/* it fits */
					return p;
				p = q + 1;
			}
	return NULL;
}

static void
mergeblk(int i)

/*
 *	Merge adjacent "free" blocks in heap <i>.  Links in the free chain
 *	are guarenteed to be in forward order.
 */
{
	long n, *p, *q;

	p =  _mblk[i].pt;
	if( (p = ((long *) *p)) ne NULL)			/* empty chain */
	{
		while( (q = ((long *) p[1])) ne 0)
		{
			n = *p;
			if( p + n eq q ) 		/* adjacent free block */
				p[1] = q[1],		/* re-link free chain */
				*p += *q;			/* adjust block size */
			else
				p = q;
		}
		/* check to see if the entire heap can be returned to the OS */
		q = p + *p;
		if ( _mblk[i].pt eq (p - 1) and *q eq NULLBLK)
		{
			Mfree(_mblk[i].pt);
#ifdef MONITOR
			fprintf(bugf,"freed block %d, size %ld\n",i,_mblk[i].sz);
#endif
			_mblk[i].pt = NULL;
			_mblk[i].sz = 0;
		}
	}
}

/*--------------------- Documented Functions ---------------------------*/

void *
malloc(size_t size)
{
	long *p;
	int i;

	size = (size+3)/4;		/* make mult of 4 rounded up */

	if (init)
	{
		for(i=0; i<MAXBLK; ++i)
			_mblk[i].pt = NULL,
			_mblk[i].sz = 0;
		init = FALSE;
	}

	if (size <= 1)
		size = 1;
	size += 1;
	if ( (p = findblk(size)) == NULL)
		if (( p = makeblk(size)) == NULL)
			return(NULL);
	p = splitblk((long**)p, size);
	return p + 1;			/* skip over header */
}

void
free(void *pt)
{
	int i;
	long *addr = pt, *p, *q;

	if (addr--)				/* point to block header */
		for (i=0; i<MAXBLK; ++i)
			if ( (p = _mblk[i].pt) ne NULL)	/* skip unavailable blocks */
				if (addr >= p and addr < p + _mblk[i].sz)	/* block range check */
				{
					while( (q = ((long *) *p)) ne 0)
					{
						++q;
						if ( addr < q  and addr > p )
							break;
						p = q;
					}
					*addr &= FREE;		 /* link into free chain */
					addr[1] = *p;
					*p = (long)addr;
					mergeblk(i);
					return;
				}
}

long
msize(void *p)
{
	return (*((long *)p-1) - 1)*4;
}

void MfreeAll(void)
{
	int i;
	long *p, *q, *r;
	for (i=0; i<MAXBLK; ++i)
	{
		if ( (p=_mblk[i].pt) ne 0)
		{
#ifdef MONITOR
			fprintf(bugf,"not freed block %d,l:%ld\n",i,_mblk[i].sz);
			while( (q = ((long *) *p)) ne 0)
			{
				fprintf(bugf,"0x%lx-%ld,lf:%ld,l:%c%ld'%s'\n",
						p,
						(q-p),
						*q,
						(*(q+*q)&0x80000000) ? 'U' : 'F',
						*(q+*q)&0x7fffffff,
						q+*q+1);
				p = q+1;
			}
#endif
			Mfree(_mblk[i].pt);
		}
	}
}
