
/* malloc, free, realloc: dynamic memory allocation */

/* minimum chunk to ask OS for */
#define MINHUNK	4096

#define NULL 0

struct mem_chunk 
	{
	struct mem_chunk *next;
	unsigned size;
	};

/* linked list of free blocks */

struct mem_chunk _mchunk_free_list = { NULL, 0 };

char * malloc(n)
unsigned n; 
{
  struct mem_chunk *p, *q;
  long sz;

/* add a mem_chunk to required size and round up */
  n = n + sizeof(struct mem_chunk);
  n = (7 + n) & ~7;
/*
	sprintf(dbgbuf, "Malloc: size=%d \r\n", n);
	_ps(dbgbuf);
*/
/* look for first block big enough in free list */
  p = &_mchunk_free_list;
/*
	sprintf(dbgbuf, "  _mchunk_free_list=%lx\r\n", p);
	_ps(dbgbuf);
*/
  q = _mchunk_free_list.next;
/*
	sprintf(dbgbuf, "  q=%lx\r\n", q);
	_ps(dbgbuf);
*/
  while ((q != NULL) && (q->size < n))
	{
	p = q;
	q = q->next;
/*
	sprintf(dbgbuf, "  next@ %lx\r\n", q);
	_ps(dbgbuf);
*/
		}

/* if not enough memory, get more from the system */
  if (q == NULL) 
	{
	sz = (n > MINHUNK ? n : MINHUNK);
/*
	sprintf(dbgbuf, "  sz %d -> ", sz);
	_ps(dbgbuf);
*/
	q = (struct mem_chunk * )trap_1_wlww(0x48, sz);
/*
	sprintf(dbgbuf, "%lx\r\n", q);
	_ps(dbgbuf);
*/
	if (((long)q) <= 0) 		/* can't alloc any more? */
		return(NULL);
/*
	_ps("  Ok\r\n");
*/
	p->next = q;
	q->size = sz;
	q->next = NULL;
	}
		
  if (q->size > n + sizeof(struct mem_chunk))
	{				/* split, leave part of free list */
	q->size -= n;
	q = (struct mem_chunk * )(((long) q) + q->size);
	q->size = n;
	}
    else
	{				/* just unlink it */
	p->next = q->next;
	}
	
	/* hand back ptr to after chunk desc */
/*
	sprintf(dbgbuf, "  ---> %lx\r\n", q);
	_ps(dbgbuf);
*/
  return((char * )++q);
}

free(r)
struct mem_chunk *r;	/* not really, but it will be soon... */
{
  struct mem_chunk *p, *q, *t;

/* move back to uncover the mem_chunk */
  r--;			/* there it is! */
/*
	sprintf(dbgbuf, "Mfree: %lx\r\n", r);
	_ps(dbgbuf);
*/
/* stick it into free list, preserving ascending address order */
  p = &_mchunk_free_list;
  q = _mchunk_free_list.next;
  while (q != NULL && q < r) 
	{
	p = q;
	q = q->next;
	}

/* merge after if possible */
  t = (struct mem_chunk * )(((long) r) + r->size);
  if (q != NULL && t >= q) 
	{
	r->size += q->size;
	q = q->next;
	}
  r->next = q;
	
/* merge before if possible, otherwise link it in */
  t = (struct mem_chunk * )(((long) p) + p->size);
  if (t >= r) 
	{
	p->size += r->size;
	p->next = r->next;
	}
    else
	p->next = r;
}

char * realloc(r, n)
struct mem_chunk *r;
unsigned n;
{
  struct mem_chunk *p, *q;
  long *src, *dst;
  unsigned sz;

  p = r - 1;
  sz = (n + sizeof(struct mem_chunk) + 7) & ~7;

  if (p->size > sz) 
	{			/* block too big, split in two */
	q = (struct mem_chunk * )(((long) p) + sz);
	q->size = p->size - sz;
	free(q + 1);
	p->size = sz;
	}
    else 
  if (p->size < sz)
	{			/* block too small, get new one */
	dst = q = (struct mem_chunk * )malloc(n);
	if (q != NULL)
		{
		src = (long * )r;
		n = p->size - sizeof(struct mem_chunk);
		while (n > 0) 
			{
			*dst++ = *src++;
			n -= sizeof(long);
			}
		}
	free(r);
	r = q;
	}
	/* else current block will do just fine */
  return((char * )r);
}

char * calloc(n, sz)
unsigned n, sz;
{
  char *r, *s;
  unsigned total;

  total = n * sz;
  if ((r = s = malloc(total)) != NULL)
	{
	while (total--)
		*s++ = 0;
	}
  return(r);
}

