#include <stddef.h>	/* for size_t */
#include <stdlib.h>
#include <string.h>
#include <mint/osbind.h>
#include <errno.h>
#include "mallint.h"

/* CAUTION: use _mallocChunkSize() to tailor to your environment,
 *          do not make the default too large, as the compiler
 *          gets screwed on a 1M machine otherwise (stack/heap clash)
 */
/* minimum chunk to ask OS for */
static size_t MINHUNK =	8192L;	/* default */
static size_t MAXHUNK = 32 * 1024L; /* max. default */

/* tune chunk size */
void __mallocChunkSize(size_t siz) { MAXHUNK = MINHUNK = siz; }


void *malloc(size_t n)
{
	struct mem_chunk *head, *q, *p, *s;
	size_t sz;

#if MALLOC_DEBUG
	nf_debugprintf("malloc %lu -> ", n);
#endif
	/* add a mem_chunk to required size and round up */
	n = ALLOC_EXTRA + ((n + MALLOC_ALIGNMENT - 1) & ~(MALLOC_ALIGNMENT - 1));

	/* look for first block big enough in free list */
	head = &_mchunk_free_list;
	q = head->next;
	while (q != head && (q->size < n || q->valid == VAL_SBRK))
		q = q->next;

	/* if not enough memory, get more from the system */
	if (q == head)
	{
		size_t const page_size = 8192;
		if ((n + SBRK_EXTRA) > MINHUNK)
		{
			sz = n;
			sz += SBRK_EXTRA;
		} else
		{
			sz = MINHUNK;
			if (MINHUNK < MAXHUNK)
				MINHUNK <<= 1;
		}

		sz = (sz + page_size - 1) & -page_size;

		q = (struct mem_chunk *) Malloc(sz);
		if (q == NULL) /* can't alloc any more? */
		{
			errno = ENOMEM;
#if MALLOC_DEBUG
			nf_debugprintf("NULL\n");
#endif
			return NULL;
		}

		/* Note: q may be below the highest allocated chunk */
		p = head->next;
		while (p != head && q > p)
			p = p->next;
		
		q->size = SBRK_EXTRA;
		sz -= SBRK_EXTRA;
		q->valid = VAL_SBRK;
		SBRK_SIZE(q) = sz;
		q->next = s = (struct mem_chunk *) ((char *) q + SBRK_EXTRA);
		q->prev = p->prev;
		q->prev->next = q;
		q->next->prev = q;
		
		s->size = sz;
		s->valid = VAL_FREE;
		s->next = p;
		s->next->prev = s;
		
		q = s;
	}

	if (q->size > (n + ALLOC_EXTRA))
	{
		/* split, leave part of free list */
		q->size -= n;
		q = (struct mem_chunk *)(((char *) q) + q->size);
		q->size = n;
		q->valid = VAL_ALLOC;
	} else
	{
		/* just unlink it */
		q->next->prev = q->prev;
		q->prev->next = q->next;
		q->valid = VAL_ALLOC;
	}

	/* hand back ptr to after chunk desc */
	s = (struct mem_chunk *)(((char *) q) + ALLOC_EXTRA);

#if MALLOC_DEBUG
	nf_debugprintf("0x%08lx\n", (unsigned long)s);
#endif
	return (void *) s;
}
