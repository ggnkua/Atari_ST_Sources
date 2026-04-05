#include <stddef.h>	/* for size_t */
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include "mallint.h"
#include "lib.h"


void *realloc(void *r, size_t n)
{
	struct mem_chunk *p;
	size_t sz;

	/* obscure features:
	 *
	 * realloc(NULL,n) is the same as malloc(n)
	 * realloc(p, 0) is the same as free(p)
	 */
	if (!r)
		return malloc(n);

	if (n == 0)
	{
		free(r);

        /* errno must be set to 0, because NULL will be returned
         * and this does not indicate an error
         */
        __set_errno(0);

		return NULL;
	}

	p = (struct mem_chunk *)(((char *) r) - ALLOC_EXTRA);

	if (p->valid != VAL_ALLOC)
	{
        __set_errno(EINVAL);
		return NULL;
	}

	sz = ALLOC_EXTRA + ((n + MALLOC_ALIGNMENT - 1) & ~(MALLOC_ALIGNMENT - 1));

	if (p->size > (sz + 2 * ALLOC_EXTRA))
	{
		/* resize down */
		void *newr;

		newr = malloc(n);
		if (newr)
		{
			memcpy(newr, r, n);
		    free(r);
			r = newr;
		}
		/* else
		 * malloc failed; can be safely ignored as the new block
		 * is smaller
		 */
	} else if (p->size < sz)
	{
		/* block too small, get new one */
		struct mem_chunk *head, *s, *next;

		head = &_mchunk_free_list;
		next = head->next;
		while (next != head && next < p)
		{
			next = next->next;
		}

		/* merge after if possible */
		s = (struct mem_chunk *)(((char *) p) + p->size);
		if (s == next && (p->size + next->size) >= sz && next->valid == VAL_FREE)
		{
			struct mem_chunk *prev;

			p->size += next->size;
			/*
			 * disconnect 'next' from free list.
			 * remember that 'p' is currently alloced
			 * and therefore not on the free list
			 */
			prev = next->prev;
			prev->next = next->next;
			next->next->prev = prev;
		} else
		{
			void *newr;

			newr = malloc(n);
			if (newr)
			{
				memcpy(newr, r, p->size - ALLOC_EXTRA);
			    free(r);
			}
			r = newr;
		}
	}

	return (void *) r;
}
