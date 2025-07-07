#include <osbind.h>
#include <stddef.h>
#include <malloc.h>

#define	MAXBLK		16
#define	FREE		0x00
#define	USED		0x80
#define	NULLBLK		0x80000000L

char	*_mblk[MAXBLK] =		/* system memory heaps */
	{
	NULL, NULL, NULL, NULL,
	NULL, NULL, NULL, NULL,
	NULL, NULL, NULL, NULL,
	NULL, NULL, NULL, NULL
	};

long	_msiz[MAXBLK] =			/* allocated heap sizes */
	{
	0L, 0L, 0L, 0L,
	0L, 0L, 0L, 0L,
	0L, 0L, 0L, 0L,
	0L, 0L, 0L, 0L
	};

/*
 *	Up to 16 heaps are allocated from the operating system as they are
 *	needed to fill requests for dynamic memory.  These heaps are them
 *	divided into blocks for parcelling out by the user-callable memory
 *	allocation routines.  If all the storage in a heap is freed, the heap
 *	will be freed to the OS.  Each heap beings with a pointer to the first
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

static char *makeblk(size)
	long size;
/*
 *	Get a new major block from the system that will hold at least
 *	<size> bytes.
 */
	{
	register int i;
	register char *p;
	register long n, minsiz, bsiz, *q;

	minsiz = (size + 0x200L) & ~0x1FFL;	/* round up to nearest 512 */
	if(minsiz < _BLKSIZ)
		bsiz = _BLKSIZ;
	else
		bsiz = minsiz;
	for(i=0; i<MAXBLK; ++i)
		{
		if(_mblk[i] != NULL)
			continue;		/* skip used heaps */
		n = Malloc(-1L);
		n = ~0x1FFL & (n - 512L);	/* system memory available */
		if(n < bsiz)
			{
			if(n < minsiz)
				return(NULL);
			else
				bsiz = minsiz;
			}
		_mblk[i] = p = ((char *) Malloc(bsiz));
		_msiz[i] = bsiz;
		q = ((long *) (p + bsiz));	/* thread starting blocks */
		q[-1] = NULLBLK;
		q = ((long *) (p + 4L));
		q[-1] = (long) q;
		q[0] = (bsiz - 8L);
		q[1] = NULL;
		p[4] = FREE;
		return(p);
		}
	return(NULL);
	}

static char *splitblk(addr, size)
	register long **addr;
	register long size;
/*
 *	Split block at *<addr> into a used block containing <size> bytes
 *	and a free block containing the remainder.
 */
	{
	register long n, *p, *q;

	n = *(p = *addr);			/* get actual block size */
	if(n > (size + 8L))			/* is it worth splitting? */
		{
		n -= size;
		/* calculate "break" point */
		q = ((long *) (((char *) p) + size));
		p[0] = size;
		q[0] = n;
		q[1] = p[1];
		*addr = q;
		}
	else					/* not worth splitting */
		*addr = ((long *) p[1]);	/* remove from free list */
	*((char *) p) = USED;			/* mark block "used" */
	return(p);
	}

static char *findblk(size)
	register long size;
/*
 *	Find the smallest unused block containing at least <size> bytes.
 */
	{
	register int i;
	register long n, tsiz = 0x7FFFFFFFL, **p, *q, *tptr = NULL;

	for(i=0; i<MAXBLK; ++i)
		{
		if((p = ((long **) _mblk[i])) == NULL)
			continue;		/* skip unavailable heaps */
		while(q = *p)
			{
			n = *q;
			if((n >= size) && (n < tsiz))		/* it fits */
				{
				tsiz = n;
				tptr = ((long *) p);
				}
			p = ((long **) (q + 1));
			}
		}
	return(tptr);
	}

/*--------------------- Documented Functions ---------------------------*/

char *lalloc(size)
	register long size;
	{
	register char *p;

	if (size <= 4L)
		size = 8L;			/* minimum allocation */
	else
		size = (size + 5L) & ~1L;	/* header & alignment */
	if((p = findblk(size)) == NULL)
		if((p = makeblk(size)) == NULL)
			return(NULL);
	p = splitblk(p, size);
	return(p + 4);			/* skip over header */
	}

char *malloc(size)
	unsigned int size;
	{
	return(lalloc((long) size));
	}

char *calloc(n, size)
	unsigned int n;
	size_t size;
	{
	register long total;
	register char *p, *q;

	total = (((long) n) * ((long) size));
	if(p = lalloc(total))
		for(q=p; total--; *q++ = 0)
			;
	return(p);
	}
