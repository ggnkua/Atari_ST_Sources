
overlay "reader"

#include <osbind.h>
#include "..\\include\\lists.h"
#include "..\\include\\script.h"
#include "..\\include\\story.h"


#define RIP_SIZE 2500
#define SCREEN_SIZE 32000L
#define ALLIGN	256
extern WORD *s1, *s2, *gem_screen;


struct mblock
	{
	struct mblock *next;
	long size;
	};

static struct mblock *free_list = NULL;
long ani_mem_alloc;
long mem_free;
char *rip_cord;

static char not_en_string[] =
"[1][ANI doesn't have enough|memory to run][SORRY]";

static
not_enough()
{
form_alert(1, not_en_string);
}

init_mem()
{
register long size;
char *pool;
char *sc1, *sc2, *sc3;

size = Malloc((long)-1);	/*see what's available */
size -= 5*1024;   		/*leave 32k for GEM */
if (size < 100000)		/*if not enough left abort ani */
	{
	not_enough();
	return(0);
	}
if ( (pool = (char  *)Malloc(size)) == NULL)
	{
	not_enough();
	return(0);
	}
ani_mem_alloc = size;

/*do some monkeying around to make sure screens are alligned nicely.
  The upper word of the 2 screens address should be the same to avoid
  flicker during double-buffering */
free_list = (struct mblock *)(pool + 3*SCREEN_SIZE + ALLIGN);
free_list->next = NULL;
size -= 3*SCREEN_SIZE + ALLIGN;
mem_free = free_list->size = size;

sc1 = (char *)(((long)pool+ALLIGN) & 0xffffff00);
sc2 = sc1 + SCREEN_SIZE;
sc3 = sc2 + SCREEN_SIZE;
if ( ((long)sc1 & 0xffff0000) == ((long)sc2 & 0xffff0000) )
	{
	mfree(sc3, (int)SCREEN_SIZE);
	s1 = (WORD *)sc1;
	s2 = (WORD *)sc2;
	}
else
	{
	mfree(sc1, (int)SCREEN_SIZE);
	s1 = (WORD *)sc2;
	s2 = (WORD *)sc3;
	}

/*allocate enough to clean up during panic */
rip_cord = (char *)alloc(RIP_SIZE);

/*set the system to our screen, and free the old screen up for RAM*/
gem_screen = (WORD *)Physbase();
Setscreen(s1, s1, -1);
mfree(gem_screen, (int)SCREEN_SIZE);

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

nbytes = (nbytes+15) & 0xfff0;

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
mem_panic();
}


mfree(pt, amount)
char *pt;
register int amount;
{
register struct mblock *mb, *nb, *lb;

#ifdef DEBUG
printf("mfree(%lx, %d)\n", pt, amount);
#endif DEBUG

if (amount <= 0)
	return;

amount = (amount+15)&0xfff0;
mem_free += amount;
nb = (struct mblock *)pt;

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
	if ( pt+amount == (char *)mb)	/*coalesce into first block*/
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
	if (pt-lb->size == (char *)lb)	/*coalesce into previous block*/
		{
		lb->size += amount;
		if (pt + amount == (char *)mb)
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
	if (pt+amount == (char *)mb)	/*coalesce into next block*/
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
if (pt-lb->size == (char *)lb)	/*a rare case ... */
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

mem_panic()
{
static char ptitle[] = "ANIPAN";
extern char *dot_script;
register char *true_name;
register Script *script;
register WORD i;

mfree(rip_cord, RIP_SIZE);	/*a little working space for the panic */
bottom_line("ANI PANIC - outta memory, sorry got to go");

#ifdef EDITOR
#ifndef NOSAVE
if (cur_sequence != NULL)
	{
	if (no_msv_confirm("save current script?") )
	{
	true_name = clone_string( lsprintf("%s%s", ptitle, dot_script) );
	sv_scr( true_name, cur_sequence );
	free_string(true_name);
	}
	}
if (no_msv_confirm("save story board?") )
	{
	for (i=0; i<STORY_COUNT; i++)
	{
	true_name = 
		clone_string( lsprintf("%s%d%s", ptitle, i, dot_script));
	if ((script = story_board[i].sequence) != NULL)
		if (script->tween_count > 0)
		sv_scr(true_name, script);
	free_string(true_name);
	}
	}
#endif NOSAVE
#endif EDITOR
ani_cleanup();
exit(-1);
}

