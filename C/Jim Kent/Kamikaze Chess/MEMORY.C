
#include <osbind.h>
#include "kamikaze.h"


static struct mblock *free_list = NULL;
long mem_free;


wait_a_jiffy(j)
int j;
{
while (--j >= 0)
	Vsync();
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
size -= 16*1024;   		/*leave 16 for GEM */
if (size < 64000L)		/*if not enough left abort */
	{
	not_enough();
	return(0);
	}
while ((pool = (char *)Malloc(size)) == NULL)
	{
	if (size < 64000L)
		{
		not_enough();
		return(0);
		}
	size = size*15/16;
	}
free_list = (struct mblock *)pool;
free_list->next = NULL;
mem_free = free_list->size = size;
return(1);
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
		free_list = mb->next;
		mem_free -= nbytes;
		return((long *)mb);
		}
	else if (mb->size > nbytes)
		{
#ifdef DEBUG1
		printf("alloc first %lx\n", mb);
#endif DEBUG1
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
		lb->next = mb->next;
		mem_free -= nbytes;
		return((long *)mb);
		}
	else if (mb->size > nbytes)
		{
#ifdef DEBUG1
		printf("alloc middle %lx\n", mb);
#endif DEBUG1
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
nomem_exit:
flash_color(0x707);
return(NULL);
}

void *
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




void *
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



void *
clone_structure(s, size)
void *s;
unsigned size;
{
register void *d;

if ((d = askmem(size)) != NULL)
	copy_structure(s, d, size);
return(d);
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
return;
}

