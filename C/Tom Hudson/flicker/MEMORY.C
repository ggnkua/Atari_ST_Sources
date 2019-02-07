
#include <osbind.h>

#define NULL 0L	

struct mblock
	{
	struct mblock *next;
	long size;
	};

static struct mblock *free_list = NULL;
long cel_mem_alloc;
long mem_free;

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
if ( (pool = (char  *)Malloc(size)) == NULL)
	{
	not_enough();
	return(0);
	}
free_list = (struct mblock *)pool;
free_list->next = NULL;
mem_free = free_list->size = size;
return(1);
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

int *
alloc(nbytes)
register int nbytes;
{
register struct mblock *mb, *nb, *lb;

#ifdef DEBUG
printf("alloc(%d)\n", nbytes);
#endif DEBUG

if (nbytes <= 0)
	return(NULL);

nbytes = (nbytes+7) & 0xfff8;

if (mb = free_list)
	{
	if (mb->size == nbytes)
		{
#ifdef DEBUG1
		printf("alloc first exact %lx\n", mb);
#endif DEBUG1
		free_list = mb->next;
		mem_free -= nbytes;
		return((int *)mb);
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
		return((int *)mb);
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
		return((int *)mb);
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
		return((int *)mb);
		}
	else
		{
		lb = mb;
		mb = mb->next;
		}
	}
return(NULL);
}


mfree(nb, amount)
struct mblock *nb;
register int amount;
{
register struct mblock *mb;
register struct mblock *lb;

#ifdef DEBUG
printf("mfree(%lx, %d)\n", nb, amount);
#endif DEBUG

if (amount <= 0)
	return;

amount = (amount+7)&0xfff8;
mem_free += amount;

if ( (mb = free_list) == NULL)
	{
#ifdef DEBUG1
	printf("new free_list\n");
#endif DEBUG1
	mb = free_list = nb;
	mb->next = NULL;
	mb->size = amount;
	return;
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
	return;
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
		return;
		}
	if ((char *)nb+amount == (char *)mb)	/*coalesce into next block*/
		{
		nb->size = mb->size + amount;
		nb->next = mb->next;
		lb->next = nb;
#ifdef DEBUG1
		printf("coalescing into next block\n");
#endif DEBUG1
		return;
		}
	if (nb < mb)
		{
#ifdef DEBUG1
		printf("adding block in middle\n");
#endif DEBUG1
		nb->next = mb;
		lb->next = nb;
		nb->size = amount;
		return;
		}
	}
if ((char *)nb-lb->size == (char *)lb)	/*a rare case ... */
	{
#ifdef DEBUG1
	printf("coalescing into end of last block\n");
#endif DEBUG1
	lb->size += amount;
	return;
	}
#ifdef DEBUG1
printf("adding last block\n");
#endif DEBUG1
lb->next = nb;
nb->next = NULL;
nb->size = amount;
}

