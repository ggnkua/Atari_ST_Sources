
#include <osbind.h>
#include "flicker.h"


static struct mblock *free_list = NULL;
long cel_mem_alloc;
long mem_free;

flash_nomem()
{
int ocolor;

ocolor =  Setcolor(0, -1);
Setcolor(0, 0x700);
wait_a_jiffy(8);
Setcolor(0, ocolor);
}

static
not_enough()
{
puts("not enough memory to run, sorry");
}


init_mem()
{
register long size;
char *pool;
char *sc1, *sc2, *sc3;

size = Malloc((long)-1);	/*see what's available */
size -= 24*1024;   		/*leave 24 for GEM */
if (size < 96000L)		/*if not enough left abort flicker */
	{
	not_enough();
	return(0);
	}
while ((pool = (char *)Malloc(size)) == NULL)
	{
	if (size < 96000L)
		{
		not_enough();
		return(0);
		}
	size = size*15/16;
	}
free_list = (struct mblock *)pool;
free_list->next = NULL;
mem_free = free_list->size = size;
ram_dlt_start = ram_dlt = (WORD *)pool;
ram_dlt += size/sizeof(WORD);
rd_alloc = size - sizeof(struct mblock);
ram_dlt_start += sizeof(struct mblock)/sizeof(WORD);
return(1);
}

long
largest_frag()
{
register struct mblock *mb= free_list;
register long longest;
register long size;

longest = 0;
while (mb)
	{
	size = mb->size;
	if (mb->next == NULL)
		size -= rd_count+sizeof(struct mblock);
	if (size > longest)
		longest = size;
	mb = mb->next;
	}
return(longest);
}

#ifdef SLUFFED
dump_frags()
{
register struct mblock *mb= free_list;

while (mb)
	{
	printf("%lx %lx\n", mb, mb->size);
	mb = mb->next;
	}
}
#endif SLUFFED

check_rd_alloc(mb, nbytes)
register struct mblock *mb;
long nbytes;
{
if (mb->next != NULL)	/* only the last block concerns us */
	return(1);
if (rd_alloc - rd_count - 16L >= nbytes)
	{
	rd_alloc -= nbytes;
	return(1);
	}
return(0);
}

static long *
lalloc(nbytes)
register long nbytes;
{
register struct mblock *mb, *nb, *lb;

#ifdef DEBUG
printf("alloc(%d)\n", nbytes);
#endif DEBUG

if (mb = free_list)
	{
	if (mb->size == nbytes)
		{
#ifdef DEBUG1
		printf("alloc first exact %lx\n", mb);
#endif DEBUG1
		if (!check_rd_alloc(mb, nbytes) )
			goto nomem_exit;
		free_list = mb->next;
		mem_free -= nbytes;
		return((long *)mb);
		}
	else if (mb->size > nbytes)
		{
#ifdef DEBUG1
		printf("alloc first %lx\n", mb);
#endif DEBUG1
		if (!check_rd_alloc(mb, nbytes) )
			goto nomem_exit;
		nb = (struct mblock *)(((char *)mb)+nbytes);
		nb->next = mb->next;
		nb->size = mb->size - (long)nbytes;
		free_list = nb;
		mem_free -= nbytes;
		return((long *)mb);
		}
	else
		{
		lb = mb;
		mb = mb->next;
		}
	}

while (mb)
	{
	if (mb->size == nbytes)
		{
#ifdef DEBUG1
		printf("alloc exact %lx\n", mb);
#endif DEBUG1
		if (!check_rd_alloc(mb, nbytes) )
			goto nomem_exit;
		lb->next = mb->next;
		mem_free -= nbytes;
		return((long *)mb);
		}
	else if (mb->size > nbytes)
		{
#ifdef DEBUG1
		printf("alloc middle %lx\n", mb);
#endif DEBUG1
		if (!check_rd_alloc(mb, nbytes) )
			goto nomem_exit;
		nb = (struct mblock *)(((char *)mb)+nbytes);
		nb->next = mb->next;
		nb->size = mb->size - (long)nbytes;
		lb->next = nb;
		mem_free -= nbytes;
		return((long *)mb);
		}
	else
		{
		lb = mb;
		mb = mb->next;
		}
	}
#ifdef SLUFFED
if (mb != NULL)
	{
	if (mb->next == NULL)	/* last block is shared with ram_dlt stack... */
		{
		if (rd_alloc - rd_count - 32 < nbytes)
			{
			mb = NULL;
			}
		else
			{
			rd_alloc -= nbytes;
			ram_dlt_start += nbytes/sizeof(WORD);
			}
		}
	}
#endif SLUFFED
nomem_exit:
flash_nomem();
return(NULL);
}

int *
askmem(nbytes)
unsigned nbytes;
{
long *pt;

nbytes += 11;
nbytes &= 0xfff8;
if ((pt = lalloc( (long)nbytes )) == NULL)
	return(NULL);
*pt++ = nbytes;
return((int *)pt);
}

int *
begmem(nbytes)
unsigned nbytes;
{
int *pt;

if ((pt = askmem(nbytes)) == NULL)
	outta_memory();
return(pt);
}

int *
lbegmem(nbytes)
long nbytes;
{
int *pt;

if ((pt = laskmem(nbytes)) == NULL)
	outta_memory();
return(pt);
}


int *
laskmem(nbytes)
long nbytes;
{
long *pt;

nbytes += 11;
nbytes &= 0xfffffff8;
if ((pt = lalloc( nbytes )) == NULL)
	return(NULL);
*pt++ = nbytes;
return((int *)pt);
}

#ifdef SLUFFED
int *
alloc_biggest_chunk(size)
long *size;
{
long s;

s = largest_frag();
s += 11;
s &= 0xfffffff8;
if (s  >= mem_free - 42000L )
	s = mem_free - 42000L;
*size = s;
return((int *)laskmem(s) );
}
#endif SLUFFED

gentle_free(pt)
long *pt;
{
if (pt != NULL)
	freemem(pt);
}


freemem(pt)
long *pt;
{
register struct mblock *mb;
register struct mblock *lb;
register struct mblock *nb;
register long amount;

#ifdef DEBUG
printf("mfree(%lx, %d)\n", nb, amount);
#endif DEBUG

amount = *(--pt);
nb = (struct mblock *)pt;
mem_free += amount;

if ( (mb = free_list) == NULL)
	{
#ifdef DEBUG1
	printf("new free_list\n");
#endif DEBUG1
	mb = free_list = nb;
	mb->next = NULL;
	mb->size = amount;
	goto adjust_rd_alloc;
	}
if ( nb < mb)
	{
	free_list = nb;
	nb->next = mb;
	nb->size = amount;
	if ( (char *)nb+amount == (char *)mb)	/*coalesce into first block*/
		{
		nb->next = mb->next;
		nb->size += mb->size;
#ifdef DEBUG1
		printf("coalescing into first chunk\n");
#endif DEBUG1
		}		
#ifdef DEBUG1
	else
		printf("new first chunk\n");	
#endif DEBUG1
	goto adjust_rd_alloc;
	}
for (;;)
	{
	lb = mb;
	if ( (mb = mb->next) == NULL)
		break;
	if ((char *)nb - lb->size == (char *)lb)	/*coalesce into previous block*/
		{
		lb->size += amount;
		if ((char *)nb + amount == (char *)mb)
			{
			lb->size += mb->size;
			lb->next = mb->next;
#ifdef DEBUG1
			printf("coalescing both sides\n");
#endif DEBUG1
			}
#ifdef DEBUG1
		else
			printf("coalescing into previous block\n");
#endif DEBUG1
		goto adjust_rd_alloc;
		}
	if ((char *)nb+amount == (char *)mb)	/*coalesce into next block*/
		{
		nb->size = mb->size + amount;
		nb->next = mb->next;
		lb->next = nb;
#ifdef DEBUG1
		printf("coalescing into next block\n");
#endif DEBUG1
		goto adjust_rd_alloc;
		}
	if (nb < mb)
		{
#ifdef DEBUG1
		printf("adding block in middle\n");
#endif DEBUG1
		nb->next = mb;
		lb->next = nb;
		nb->size = amount;
		goto adjust_rd_alloc;
		}
	}
if ((char *)nb-lb->size == (char *)lb)	/*a rare case ... */
	{
#ifdef DEBUG1
	printf("coalescing into end of last block\n");
#endif DEBUG1
	lb->size += amount;
	goto adjust_rd_alloc;
	}
#ifdef DEBUG1
printf("adding last block\n");
#endif DEBUG1
lb->next = nb;
nb->next = NULL;
nb->size = amount;
adjust_rd_alloc:
mb = free_list;
while ((nb = mb->next) != NULL)
	mb = nb;
rd_alloc = mb->size - sizeof(struct mblock);
ram_dlt_start = ram_dlt - rd_alloc/sizeof(WORD);
}

