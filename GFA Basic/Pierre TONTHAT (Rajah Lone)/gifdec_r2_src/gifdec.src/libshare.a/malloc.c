/*
 *  libshare: a dirty patch to make LDG compiled against mintlib shareable
 *
 *  by Arnaud BERCEGEAY (Feb 2004)
 */

/* from the TOS GCC library */
/* malloc, free, realloc: dynamic memory allocation */
/* ERS: added mlalloc, relalloc, etc. for 16 bit compilers. Changed
   argument of malloc, etc.,  to size_t (per ANSI draft). */
/* 5/2/92 sb -- modified for Heat-n-Serve C to accomodate its 16-bit size_t */
/* 5/5/92 sb -- split off realloc() & calloc() to reduce library drag */

#include <compiler.h>
#include <stddef.h>	/* for size_t */
#include <stdlib.h>
#include <memory.h>
#include <string.h>
#include <assert.h>
#include <unistd.h>
#include <osbind.h>
#include "lib.h"

#include <ldg.h>


/* CAUTION: use _mallocChunkSize() to tailor to your environment,
 *          do not make the default too large, as the compiler
 *          gets screwed on a 1M machine otherwise (stack/heap clash)
 */
/* minimum chunk to ask OS for */
static size_t MINHUNK =	8192L;	/* default */
static size_t MAXHUNK = 32 * 1024L; /* max. default */

/* tune chunk size */
void _mallocChunkSize(size_t siz) { MAXHUNK = MINHUNK = siz; }

/* flag to control zero'ing of malloc'ed chunks */
static int ZeroMallocs = 0;

/* Set zero block after malloc flag */
void _malloczero(int yes) { ZeroMallocs = yes; }

/* linked list of free blocks struct defined in lib.h */
/* [libshare] nota: the name will be replaced by libshare_mchunk...
 * see libshare/lib.h */
struct mem_chunk _mchunk_free_list = { VAL_FREE, NULL, 0L };

/* [libshare] */
#define SIZEOF_STATIC_MBLOCK 16384L
char static_mblock[SIZEOF_STATIC_MBLOCK];
static int static_block_returned = 0;

/* [libshare] debug */
int __ind_lst_malloc = 0;
long __lst_malloc_size[40];
void *__lst_malloc_addr[40];
static void __lst_add_malloc(long size, void *addr) {
	if (__ind_lst_malloc<40) {
		__lst_malloc_size[__ind_lst_malloc] = size;
		__lst_malloc_addr[__ind_lst_malloc] = addr;
		__ind_lst_malloc++;
	}
}

/* [libshare] debug */
int __ind_lst_free = 0;
void *__lst_free[40];
static void __lst_add_free(void *addr) {
	if (__ind_lst_free<40)
		__lst_free[__ind_lst_free++] = addr;
}



void *
malloc(size_t n)
{
	struct mem_chunk *p, *q;
	long sz;

	/* add a mem_chunk to required size and round up */
	n = (n + sizeof(struct mem_chunk) + 7) & ~7;

	/* look for first block big enough in free list */
	p = &_mchunk_free_list;
	q = _mchunk_free_list.next;
	while (q && (q->size < n || q->valid == VAL_BORDER))
	{
		p = q;
		q = q->next;
	}

	/* if not enough memory, get more from the system */
	if (q == NULL) 
	{
		if (((!_split_mem) && (_heapbase != NULL))
		    || n + BORDER_EXTRA > MINHUNK)
		{
			sz = n;
			if (_heapbase == NULL)
				sz += BORDER_EXTRA;
		}
		else
		{
			sz = MINHUNK;
			if (MINHUNK < MAXHUNK)
				MINHUNK *= 2;
		}
		if (_split_mem || _heapbase == NULL)
		{
			static int page_size = 0;
			
			if (!page_size)
				page_size = getpagesize ();
			
			sz = (sz + page_size - 1) & -page_size;
		}
		
		/* [libshare] */
		if (!static_block_returned) 
		{
			static_block_returned = 1;
			sz = SIZEOF_STATIC_MBLOCK;
			q = (struct mem_chunk * )static_mblock;
		}
		else 
		{
			q = (struct mem_chunk * ) sbrk(sz);
		}

		if (((long) q) == -1) /* can't alloc any more? */
			return NULL;

		/* Note: q may be below the highest allocated chunk */
		p = &_mchunk_free_list;
		while (p->next && q > p->next)
			p = p->next;

		if (_heapbase == NULL)
		{
			q->size = BORDER_EXTRA;
			sz -= BORDER_EXTRA;
			q->valid = VAL_BORDER;
			ALLOC_SIZE (q) = sz;
			q->next = (struct mem_chunk *) ((long) q + BORDER_EXTRA);
			q->next->next = p->next;
			p = p->next = q;
			q = q->next;
		}
		else
		{
			q->next = p->next;
			p->next = q;
		}

		q->size = sz;
		q->valid = VAL_FREE;
	}

	if (q->size > n + sizeof(struct mem_chunk))
	{
		/* split, leave part of free list */
		q->size -= n;
		q = (struct mem_chunk * )(((long) q) + q->size);
		q->size = n;
		q->valid = VAL_ALLOC;
	}
	else
	{
		/* just unlink it */
		p->next = q->next;
		q->valid = VAL_ALLOC;
	}

	q->next = NULL;	
	q++; /* hand back ptr to after chunk desc */

	if (ZeroMallocs)
		bzero(q, (size_t)(n - sizeof(struct mem_chunk)));

	/* libshare debug */
	__lst_add_malloc(n,q);

	return (void *) q;
}

void
free(void *param)
{
	struct mem_chunk *o, *p, *q, *s;
	struct mem_chunk *r = (struct mem_chunk *) param;

	/* free(NULL) should do nothing */
	if (r == NULL)
		return;

	/* libshare debug */
	__lst_add_free(param);

	/* move back to uncover the mem_chunk */
	r--; /* there it is! */

	if (r->valid != VAL_ALLOC)
		return;

	r->valid = VAL_FREE;

	/* stick it into free list, preserving ascending address order */
	o = NULL;
	p = &_mchunk_free_list;
	q = _mchunk_free_list.next;
	while (q && q < r) 
	{
		o = p;
		p = q;
		q = q->next;
	}

	/* merge after if possible */
	s = (struct mem_chunk *)(((long) r) + r->size);
	if (q && s >= q && q->valid != VAL_BORDER)
	{
		assert(s == q);
		r->size += q->size;
		q = q->next;
		s->size = 0;
		s->next = NULL;
	}
	r->next = q;

	/* merge before if possible, otherwise link it in */
	s = (struct mem_chunk * )(((long) p) + p->size);
	if (s >= r && p != &_mchunk_free_list)
	{
		/* remember: r may be below &_mchunk_free_list in memory */
		assert(s == r);

		if (p->valid == VAL_BORDER)
		{
			if (ALLOC_SIZE(p) == r->size)
			{
				o->next = r->next;
				if ((long)p != (long)static_mblock) {
					ldg_Free (p);
					/* add SHM stuff here */
				}
			}
			else
				p->next = r;

			return;
		}

		p->size += r->size;
		p->next = r->next;
		r->size = 0;
		r->next = NULL;

		s = (struct mem_chunk *)(((long) p) + p->size);
		if ((!_split_mem) && _heapbase != NULL &&
		    s >= (struct mem_chunk *) _heapbase &&
		    s < (struct mem_chunk *) ((char *)_heapbase + _stksize))
		{
			assert(s == (struct mem_chunk *) _heapbase);

			_heapbase = (void *) p;
			_stksize += p->size;
			o->next = p->next; /* o is always != NULL here */
		}
		else if (o->valid == VAL_BORDER && ALLOC_SIZE(o) == p->size)
		{
			q = &_mchunk_free_list;
			s = q->next;
			while (s && s < o)
			{
				q = s;
				s = q->next;
			}
			if (s)
			{
				assert (s == o);
				q->next = p->next;
				if ( (long)o != (long)static_mblock) {
					ldg_Free (o);
					/* add SHM stuff here */
				}
			}
		}
	}
	else
        {
		s = (struct mem_chunk * )(((long) r) + r->size);
		if ((!_split_mem) && _heapbase != NULL &&
		    s >= (struct mem_chunk *) _heapbase &&
		    s < (struct mem_chunk *) ((char *)_heapbase + _stksize))
		{
			assert(s == (struct mem_chunk *) _heapbase);

			_heapbase = (void *) r;
			_stksize += r->size;

			p->next = r->next;
		}
		else
			p->next = r;
	}
}
