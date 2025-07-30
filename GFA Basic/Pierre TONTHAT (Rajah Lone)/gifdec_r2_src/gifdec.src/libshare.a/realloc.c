/*
 *  libshare: a dirty patch to make LDG compiled against mintlib shareable
 *
 *  by Arnaud BERCEGEAY (Feb 2004)
 */

/* from the TOS GCC library */
/* malloc, free, realloc: dynamic memory allocation */
/* 5/2/92 sb -- modified for Heat-n-Serve C to accomodate its 16-bit size_t */
/* 5/5/92 sb -- realloc() gets its own file to reduce library drag */

#include <stddef.h>	/* for size_t */
#include <stdlib.h>
#include <memory.h>
#include <string.h>
#include <assert.h>
#include <unistd.h>
#include "lib.h"

void *
realloc (void *r, size_t n)
{
	struct mem_chunk *p;
	long sz;

	/* obscure features:
	 * 
	 * realloc(NULL,n) is the same as malloc(n)
	 * realloc(p, 0) is the same as free(p)
	 */
	if (!r)
		return malloc(n);

	if (n == 0) {
		free(r);
		return NULL;
	}

	p = ((struct mem_chunk *) r) - 1;
	sz = (n + sizeof(struct mem_chunk) + 7) & ~7;

	if (p->size > (sz + ((2 * sizeof(struct mem_chunk) + 7) & ~7)))
	{
		/* resize down */
		void *newr;

		newr = malloc(n);
		if (newr)
		{
			bcopy(r, newr, n);
		    free(r);

			r = newr;
		}
		/* else
		 * malloc failed; can be safely ignored as the new block
		 * is smaller
		 */
	}
	else if (p->size < sz)
	{
		/* block too small, get new one */
		struct mem_chunk *q, *s, *t;

		q = &_mchunk_free_list;
		t = _mchunk_free_list.next;
		while (t && t < p)
		{
			q = t;
			t = t->next;
		}

		/* merge after if possible */
		s = (struct mem_chunk * )(((long) p) + p->size);
		if (t && s >= t && p->size + t->size >= sz
		    && t->valid != VAL_BORDER)
		{
			assert(s == t);

			p->size += t->size;
			q->next = t->next;
			t->size = 0;
			t->next = NULL;
		}
		else
		{
			void *newr;

			newr = malloc(n);
			if (newr)
			{
				bcopy(r, newr, p->size - sizeof(struct mem_chunk));
			    free(r);
			}
			r = newr;
		}
	}

	return (void *) r;
}
