/* Eigene Speicherverwaltung. Kein Mfree(). L„uft instabil oder Bug in 7UP */
/*****************************************************************************
*
*                                   7UP
*                              Modul: MEMORY.C
*                            from GNU C-Library
*                   Best-/Lastfit Extension (c) TheoSoft '92
*
*****************************************************************************/
#include <portab.h>
#include <stdio.h>
#include <string.h>
#include <tos.h>

/* malloc, free, realloc: dynamic memory allocation */
/* msize, coreleft: size of memory */

#define GET 0
#define SET 1

#define FFIT 0
#define BFIT 1
#define LFIT 2

struct mem_chunk
{
   struct mem_chunk *next;
   unsigned long size;
};

int GetSetAllocationStrategy(int mode, int newstrategy, unsigned long *blksize);
static char *_ffmalloc(unsigned long n);
static char *_bfmalloc(unsigned long n);
static char *_lfmalloc(unsigned long n);
static char *_ffrealloc(struct mem_chunk *r, unsigned long n);
static char *_blfrealloc(struct mem_chunk *r, unsigned long n);

/* linked list of free blocks */
static struct mem_chunk _mchunk_free_list = { NULL, 0L };

/* minimum chunk to ask OS for (originally 4096Bytes) */
static unsigned long DEFAULT_BLKSIZE=32*1024L;
static int memallocstrat = FFIT;

int GetSetAllocationStrategy(int mode, int newstrategy, unsigned long *blksize)
{
   switch(mode)
   {
      case GET:
         *blksize=DEFAULT_BLKSIZE;
         return(memallocstrat);
      case SET:
         switch(newstrategy)
         {
            case FFIT:
            case BFIT:
            case LFIT:
               if(*blksize>=4*1024L)
               {
                  DEFAULT_BLKSIZE=*blksize;
                  return(memallocstrat=newstrategy);
               }
         }
   }
   return(memallocstrat);
}

static char *_ffmalloc(register unsigned long n) /* first fit allocation */
{
   register struct mem_chunk *p, *q;
   register unsigned long sz;

/* add a mem_chunk to required size and round up */
   n = n + sizeof(struct mem_chunk);
   n = (7L + n) & ~7L;

/* look for first block big enough in free list */
   p = &_mchunk_free_list;
   q = _mchunk_free_list.next;

   while ((q != NULL) && (q->size < n))
   {
      p = q;
      q = q->next;
   }

/* if not enough memory, get more from the system */
   if (q == NULL)
   {
      sz = (n > DEFAULT_BLKSIZE ? n : DEFAULT_BLKSIZE);
      q = (struct mem_chunk * )Malloc(sz);
      if(!q)     /* can't alloc any more? */
         return(NULL);
      p->next = q;
      q->size = sz;
      q->next = NULL;
   }

   if (q->size > (n + sizeof(struct mem_chunk)))
   {           /* split, leave part of free list */
      q->size -= n;
      q = (struct mem_chunk * )(((unsigned long) q) + q->size);
      q->size = n;
   }
   else
   {           /* just unlink it */
      p->next = q->next;
   }

/* hand back ptr to after chunk desc */
   return((char * )++q);
}

static char *_bfmalloc(register unsigned long n) /* best fit allocation */
{
   register struct mem_chunk *p, *q, *bf = NULL;
   register unsigned long sz, bfsize = 0xFFFFFFFF;

/* add a mem_chunk to required size and round up */
   n = n + sizeof(struct mem_chunk);
   n = (7L + n) & ~7L;

/* look for first block big enough in free list */
   p = &_mchunk_free_list;
   q = _mchunk_free_list.next;

   while ((q != NULL) && (q->size != (n + sizeof(struct mem_chunk))))
   {
      if(q->size > n)
      {
         if((q->size - n) < bfsize)
         {
            bf = q;
            bfsize = q->size - n;
         }
      }
      p = q;
      q = q->next;
   }

   if(q != NULL)   /* just unlink it */
   {
/* exactly found, what we want */

      p->next = q->next;
   }
   else
   {
      if(bf != NULL)
      {
/* this is our nearest block */

         q = bf;
      }
      else
      {
/* no smaller block available, allocate new one from OS */

         sz = (n > DEFAULT_BLKSIZE ? n : DEFAULT_BLKSIZE);
         q = (struct mem_chunk * )Malloc(sz);
         if(!q)     /* can't alloc any more? */
            return(NULL);
         p->next = q;
         q->size = sz;
         q->next = NULL;
      }

      if (q->size > (n + sizeof(struct mem_chunk)))
      {           /* split, leave part of free list */
         q->size -= n;
         q = (struct mem_chunk * )(((unsigned long) q) + q->size);
         q->size = n;
      }
      else
      {           /* just unlink it */
         p->next = q->next;
      }
   }

/* hand back ptr to after chunk desc */
   return((char * )++q);
}

static char *_lfmalloc(register unsigned long n) /* last fit alloaction */
{
   register struct mem_chunk *p, *q, *lf = NULL;
   register unsigned long sz;

/* add a mem_chunk to required size and round up */
   n = n + sizeof(struct mem_chunk);
   n = (7L + n) & ~7L;

/* look for last block big enough in free list */
   p = &_mchunk_free_list;
   q = _mchunk_free_list.next;

   while (q != NULL)
   {
      if(q->size > n)
         lf = p;
      p = q;
      q = q->next;
   }

   if (lf != NULL)
   {
/* this is our last block */

      p = lf;
      q = lf->next;
   }
   else
   {
/* no smaller block available, allocate new one from OS */

      sz = (n > DEFAULT_BLKSIZE ? n : DEFAULT_BLKSIZE);
      q = (struct mem_chunk * )Malloc(sz);
      if(!q)     /* can't alloc any more? */
         return(NULL);
      p->next = q;
      q->size = sz;
      q->next = NULL;
   }

   if (q->size > (n + sizeof(struct mem_chunk)))
   {           /* split, leave part of free list */
      q->size -= n;
      q = (struct mem_chunk * )(((unsigned long) q) + q->size);
      q->size = n;
   }
   else
   {           /* just unlink it */
      p->next = q->next;
   }

/* hand back ptr to after chunk desc */
   return((char * )++q);
}

char *malloc(register unsigned long n)
{
   if(n==0L) /* klar */
      return(NULL);
   switch(memallocstrat)
   {
      case FFIT:
         return(_ffmalloc(n));
      case BFIT:
         return(_bfmalloc(n));
      case LFIT:
         return(_lfmalloc(n));
   }
}

void free(register struct mem_chunk *r)
{
   register struct mem_chunk *p, *q, *t;

   if(r == NULL)
      return;

/* move back to uncover the mem_chunk */
   r--;         /* there it is! */

/* stick it into free list, preserving ascending address order */
   p = &_mchunk_free_list;
   q = _mchunk_free_list.next;
   while (q != NULL && q < r)
   {
      p = q;
      q = q->next;
   }

/* merge after if possible */
   t = (struct mem_chunk * )(((unsigned long) r) + r->size);
   if (q != NULL && t >= q)
   {
      r->size += q->size;
      q = q->next;
   }
   r->next = q;

/* merge before if possible, otherwise link it in */
   t = (struct mem_chunk * )(((unsigned long) p) + p->size);
   if (t >= r)
   {
      p->size += r->size;
      p->next = r->next;
   }
   else
      p->next = r;
}

static char *_ffrealloc(struct mem_chunk *r, register unsigned long n) /* first fit */
{
   register struct mem_chunk *p, *q;
   unsigned long *src, *dst;
   register unsigned long sz;

   p = r - 1;
   sz = (n + sizeof(struct mem_chunk) + 7L) & ~7L;

   if (p->size > sz)
   {        /* block too big, split in two */
      q = (struct mem_chunk * )(((unsigned long) p) + sz);
      q->size = p->size - sz;
      free(q + 1);
      p->size = sz;
   }
   else
   {
      if (p->size < sz)
      {        /* block too small, get new one */
         dst = q = (struct mem_chunk * )malloc(n);
         if (q != NULL)
         {
            src = (unsigned long * )r;
            n = p->size - sizeof(struct mem_chunk);
            while (n > 0)
            {
               *dst++ = *src++;
               n -= sizeof(unsigned long);
            }
         }
         free(r);
         r = q;
      }
   }

/* else current block will do just fine */
   return((char * )r);
}

static char *_blfrealloc(struct mem_chunk *r, register unsigned long n) /* best fit */
{
   register struct mem_chunk *p, *q;
   unsigned long *src, *dst;
   register unsigned long sz;

   p = r - 1;
   sz = (n + sizeof(struct mem_chunk) + 7L) & ~7L;

   if (p->size != sz)
   {
/* get new, best or last fit block */
      dst = q = (struct mem_chunk * )malloc(n);
      if (q != NULL)
      {
         src = (unsigned long * )r;
         n = p->size - sizeof(struct mem_chunk);
         memmove(dst, src, n);
      }
      free(r);
      r = q;
   }

/* else current block will do just fine */
   return((char * )r);
}

char *realloc(struct mem_chunk *r, register unsigned long n)
{
   switch(memallocstrat)
   {
      case FFIT:
         return(_ffrealloc(r, n));
      case BFIT:
      case LFIT:
         return(_blfrealloc(r, n));
   }
}

char *calloc(register unsigned long n, register unsigned long sz)
{
   register char *r;

   if ((r = malloc(n * sz)) != NULL)
   {
      memset(r, 0, n * sz);
   }
   return(r);
}

unsigned long msize(register struct mem_chunk *r) /* size of allocated block */
{
   return(r?(--r)->size - sizeof(struct mem_chunk):0L);
}

unsigned long coreleft(void) /* size of free mem */
{
   register struct mem_chunk *p, *q;
   register unsigned long freemem=0L;

   p = &_mchunk_free_list;
   q = _mchunk_free_list.next;

   freemem+=p->size;
   while (q != NULL)
   {
      freemem+=q->size;
      p = q;
      q = q->next;
   }
   return(freemem+(long)Malloc(-1L));
}
