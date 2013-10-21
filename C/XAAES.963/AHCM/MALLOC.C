/* from the TOS GCC library */
/* malloc, free, realloc: dynamic memory allocation */
/* ERS: added mlalloc, relalloc, etc. for 16 bit compilers. Changed
   argument of malloc, etc.,  to size_t (per ANSI draft). */
/* 5/2/92 sb -- modified for Heat-n-Serve C to accomodate its 16-bit size_t */
/* 5/5/92 sb -- split off realloc() & calloc() to reduce library drag */

#include <prelude.h>
#include <compiler.h>
#include <stddef.h>	/* for size_t */
#include <stdlib.h>
#include <string.h>
#include <tos.h>

#define MX_STRAM 		0
#define MX_TTRAM		1
#define MX_PREFSTRAM		2
#define MX_PREFTTRAM 		3

struct mem_chunk 
	{
	long valid;
#define VAL_FREE  0xf4ee0abcL
#define VAL_ALLOC 0xa11c0abcL
#define VAL_BORDER 0xb04d0abcL

	struct mem_chunk *next;
	unsigned long size;
	};
#define ALLOC_SIZE(ch) (*(long *) ((char *) (ch) + sizeof (*(ch))))
#define BORDER_EXTRA ((sizeof (struct mem_chunk) + sizeof (long) + 7) & ~7)

long _stksize;
void *_malloc(unsigned long);

/* minimum chunk to ask OS for */
static size_t MINHUNK =	8192L;	/* default */
static size_t MAXHUNK = 32*1024L; /* max. default */

	/* CAUTION: use _mallocChunkSize() to tailor to your environment,
		    do not make the default too large, as the compiler
		    gets screwed on a 1M machine otherwise (stack/heap clash)
	 */

/* linked list of free blocks struct defined in lib.h */

struct mem_chunk _mchunk_free_list = { VAL_FREE, NULL, 0L };
void *_heapbase = 0;
short _split_mem = 0;

long getpagesize(void)
{ return 8192;
}

void * _malloc(
unsigned long n) 
{
  struct mem_chunk *p, *q;
  long sz;
  extern void *_heapbase;
  extern short _split_mem;

/* add a mem_chunk to required size and round up */
  n = n + sizeof(struct mem_chunk);
  n = (7 + n) & ~7;
/* look for first block big enough in free list */
  p = &_mchunk_free_list;
  q = _mchunk_free_list.next;

  while ((q != NULL) && (q->size < n || q->valid == VAL_BORDER))
	{
	p = q;
	q = q->next;
	}

/* if not enough memory, get more from the system */
  if (q == NULL) 
	{
	sz = MAXHUNK;
	q = (struct mem_chunk * )Mxalloc(sz,MX_PREFTTRAM);

	if (!q) 		/* can't alloc any more? */
		return(NULL);

	/* Note: q may be below the highest allocated chunk */
	p = &_mchunk_free_list;
	while (p->next != NULL && q > p->next)
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
	{				/* split, leave part of free list */
	q->size -= n;
	q = (struct mem_chunk * )(((long) q) + q->size);
	q->size = n;
	q->valid = VAL_ALLOC;
	}
    else
	{				/* just unlink it */
	p->next = q->next;
	q->valid = VAL_ALLOC;
	}

  q->next = NULL;	
  q++;	/* hand back ptr to after chunk desc */
  
  return((void * )q);
}

void free(
	void *param)
{
  struct mem_chunk *o, *p, *q, *s;
  struct mem_chunk *r = (struct mem_chunk *) param;

/* free(NULL) should do nothing */
  if (r == 0)
     return;

/* move back to uncover the mem_chunk */
  r--;			/* there it is! */

  if (r->valid != VAL_ALLOC)
	return;

  r->valid = VAL_FREE;

/* stick it into free list, preserving ascending address order */
  o = NULL;
  p = &_mchunk_free_list;
  q = _mchunk_free_list.next;
  while (q != NULL && q < r) 
	{
	o = p;
	p = q;
	q = q->next;
	}

/* merge after if possible */
  s = (struct mem_chunk * )(((long) r) + r->size);
  if (q != NULL && s >= q && q->valid != VAL_BORDER)
	{
	r->size += q->size;
	q = q->next;
	s->size = 0;
	s->next = NULL;
	}
  r->next = q;
	
/* merge before if possible, otherwise link it in */
  s = (struct mem_chunk * )(((long) p) + p->size);
  if (s >= r && p != &_mchunk_free_list)
    /* remember: r may be below &_mchunk_free_list in memory */
	{
	if (p->valid == VAL_BORDER)
	  {
	    if (ALLOC_SIZE (p) == r->size)
	      {
		o->next = r->next;
		Mfree (p);
	      }
	    else
	      p->next = r;
	    return;
	  }
	p->size += r->size;
	p->next = r->next;
	r->size = 0;
	r->next = NULL;
	s = (struct mem_chunk * )(((long) p) + p->size);
	if ((!_split_mem) && _heapbase != NULL &&
	    s >= (struct mem_chunk *) _heapbase &&
	    s < (struct mem_chunk *) ((char *)_heapbase + _stksize))
	{
	  _heapbase = (void *) p;
	  _stksize += p->size;
	  o->next = p->next;	/* o is always != NULL here */
	}
	else if (o->valid == VAL_BORDER && ALLOC_SIZE (o) == p->size)
	  {
	    q = &_mchunk_free_list;
	    s = q->next;
	    while (s != NULL && s < o)
	      {
		q = s;
		s = q->next;
	      }
	    if (s)
	      {
		q->next = p->next;
		Mfree (o);
	      }
	  }
	}
    else
        {
	  s = (struct mem_chunk * )(((long) r) + r->size);
	  if ((!_split_mem) && _heapbase != NULL &&
	      s >= (struct mem_chunk *) _heapbase &&
	      s < (struct mem_chunk *) ((char *)_heapbase + _stksize)) {
	    _heapbase = (void *) r;
	    _stksize += r->size;
	    p->next = r->next;
	  } else p->next = r;
	}
}

/*
 * tune chunk size
 */
void _mallocChunkSize (size_t siz)
{
    MAXHUNK = MINHUNK = siz;
}

#ifndef __GNUC__
void * malloc(size_t n) 
{
  return _malloc((unsigned long) n);
}
#endif
