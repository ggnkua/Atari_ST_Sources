/*
 *  Memory allocation
 *
 *  This is a mess because the memory models of UNIX and
 *  the ST have some differences.
 *
 */
#include "as.h"

LONG amemtot;			/* amem() total of requests */
char *lowbrk;			/* initial value of the break */


/* ---------------- ST specific ---------------- */
#ifdef ST
extern LONG sbrk();
#define NALLOC 128
#define ALIGN long		/* force alignment on 68000 */
#define HEADER union _header

HEADER {			/* free block header */
	struct {
		HEADER *ptr;
		unsigned size;
	} s;
	ALIGN x;
};

static HEADER base;
static HEADER *allocp;
#endif


/* ---------------- UNIX specific ---------------- */

/*
 *  Under UNIX sbrk() is an expensive call,
 *  so for small amounts of memory we allocate
 *  from a previously allocated buffer.
 */
#ifndef ST
#define	A_AMOUNT	1024	/* amount to sbrk() at a time */
#define	A_THRESH	64	/* use sbrk() anyway for amounts >= A_THRESH */

static LONG a_amount;		/* = amount left at a_ptr */
static char *a_ptr;		/* -> next free chunk */
#endif




/*
 *  Initialize memory manager;
 *
 *  If `freeze' is 1, then set permanent low break to
 *  current break value.
 *
 *  If `freeze' is 0, return to low break value.
 *
 */
imem(freeze)
int freeze;
{
	amemtot = 0;
	if (freeze)
		lowbrk = (char *)sbrk(0L);
	else
		brk(lowbrk);

#ifdef ST
	allocp = NULL;		/* initialize allocator */
#endif

#ifndef ST
	a_amount = 0;
#endif
}


/*
 *  Allocate memory;
 *  panic and quit if we run out.
 *
 */
/*$SPEEDY$*/
char *amem(amount)
register LONG amount;
{
	register char *p;

	if (amount & 1)		/* keep word alignment */
		++amount;

#ifndef ST
	if (amount < A_THRESH)
	{				/* honor *small* request on BSD */
		if (a_amount < amount)
		{
			a_ptr = amem(A_AMOUNT);
			a_amount = A_AMOUNT;
		}
		p = a_ptr;
		a_ptr += amount;
		a_amount -= amount;
	}
	else
	{
		amemtot += amount;	/* bump total alloc */
		p = (char *)sbrk(amount);	/* get memory from break */
		if ((LONG)p == -1L)
			fatal("memory exhausted");
	}
#else
	amemtot += amount;		/* bump total alloc */
	p = (char *)sbrk(amount);	/* get memory from break */
	if ((LONG)p == -1L)
		fatal("memory exhausted");
#endif

	return p;
}


/*
 *  Allocate (and return pointer to a copy of) a string.
 *
 */
/*$SPEEDY$*/
char *nstring(str)
register char *str;
{
	register long i;
	register char *s, *d;

	for (i = 0; str[i]; ++i)
		;
	s = d = amem(i + 1);
	while (*str)
		*d++ = *str++;
	*d++ = '\0';
	return s;
}


/* -------------------------------- */


#ifdef ST
/*
 *  This is the K&R allocator from "The C Programming Language,"
 *  hacked slightly for the 68000.
 *
 */

/*
 *  Allocate some storage
 *
 */
char *malloc(nbytes)
LONG nbytes;
{
	HEADER *morecore();
	register HEADER *p, *q;
	register LONG nunits;

	nunits = 1 + (nbytes + sizeof(HEADER)-1)/sizeof(HEADER);

	if ((q = allocp) == NULL)
	{				/* no free list yet */
		base.s.ptr = allocp = q = &base;
		base.s.size = 0;
	}

	for (p = q->s.ptr; q=p, p=p->s.ptr; )
	{
		if (p->s.size >= nunits)
		{
			if (p->s.size == nunits)
				q->s.ptr = p->s.ptr;	/* exactly */
			else
			{			/* free tail */
				p->s.size -= nunits;
				p += p->s.size;
				p->s.size = nunits;
			}
			allocp = q;
			return ((char *)(p+1));
		}
		if (p == allocp)
			if ((p = morecore(nunits)) == NULL)
				return (NULL);
	}
}


/*
 *  Ask for more core
 */
static HEADER *morecore(nu)
LONG nu;
{
	char *sbrk();
	register char *cp;
	register HEADER *up;
	register LONG rnu;

	rnu = NALLOC * ((nu+NALLOC-1)/NALLOC);
	cp = sbrk(rnu * sizeof(HEADER));
	if ((LONG)cp == -1L)
		return NULL;

	up = (HEADER *)cp;
	up->s.size = rnu;
	free ((char *)(up+1));
	return allocp;
}


/*
 *  Free a block
 *
 */
free(ap)
char *ap;
{
	register HEADER *p, *q;

	p = (HEADER *)ap - 1;
	for (q = allocp; !(p > q && p < q->s.ptr); q=q->s.ptr)
		if (q >= q->s.ptr &&
			  (p > q || p < q->s.ptr))
			break;

	if (p+p->s.size == q->s.ptr)
	{
		p->s.size += q->s.ptr->s.size;
		p->s.ptr = q->s.ptr->s.ptr;
	}
	else
		p->s.ptr = q->s.ptr;

	if (q+q->s.size == p)
	{
		q->s.size += p->s.size;
		q->s.ptr = p->s.ptr;
	}
	else
		q->s.ptr = p;

	allocp = q;
}
#endif


/* -------------------------------- */


/*
 *  Copy stuff around, return pointer to dest+count+1
 *  (doesn't handle overlap)
 *  re-code in assembly for speed...
 *
 */
/*$SPEEDY$*/
char *copy(dest, src, count)
register char *dest;
register char *src;
register LONG count;
{
	while (count--)
		*dest++ = *src++;
	return dest;
}


#ifndef ST
/*
 *  Clear a region of memory
 *  re-code in assembly for speed...
 *
 *  This is written in assembly on the ST (see clear.s)
 *
 */
clear(dest, count)
register char *dest;
register LONG count;
{
	while (count--)
		*dest++ = 0;
}
#endif
