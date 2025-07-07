/* malloc.c last updated 26 feb 90 by mt */
/* Supplied to A.M.Pennell 12 November 1990 */

/*#define ARNOR*/

#include "mon.h"
#include "osbind.h"
#include "basepage.h"
extern long _base,_STACK;			// in startup code

/* this was unsigned int in Arnor-speak */
#define uint unsigned long

/*

Notes on malloc/free/Malloc/Mfree/Mshrink
-----------------------------------------
It is well known that the gemdos Malloc/Free routines are severely bugged 
and should be called as few times as possible.

It is therefore a good idea not to directly map C's malloc/free routines 
onto gemdos's Malloc/Mfree routines.

The program memory segment cannot shrink and grow in MS-DOS type fashion
because gemdos appears to only allow shrinking of memory blocks (except in
the most trivial of cases). Also, a Malloced memory block can only be shrunk
in size, and not grown.

The best method which appears to be left, then, is to Malloc the largest 
possible area (except for a little bit), and reduce this as much as possible 
when an external program is run from within protext (or any other program).

*/

/* provides the following routines :-

extern void *malloc(size_t n);
extern void free(void *p);
extern void *calloc(size_t n,size_t size);
extern void *realloc(void *ptr,size_t size);
*/

/* set minimum heap size such that none is allocated by startup code */
long _MNEED = 100;

/* space left free (eg for screen driver) */
#define	SPARE_RAM	20000

bool lockmem;			/* TRUE means dont Malloc or MFree */

#define dos_Malloc(x)	((long)Malloc(x))

typedef struct nodep
{
	uint size;
	struct nodep *next;
} memnode;

memnode *_heapgrow(long);

memnode _basenode={0,NULL};
memnode *_heapstart=NULL;
memnode *_realheapstart=NULL;		/* the first heapstart */
uint _heapsize=0;

long end_of_world;			/* points to last area used in memory */

#if _DEBUG

char malloc_debug_flag=TRUE;

void HELP(void)
{
	memnode *p;
	short count=5000;
	
	p=&_basenode;
	for(;;)
		{
		if (p->next==NULL)
			return;
		if (--count==0)
			ILLEGAL;
		p=p->next;
		}
}
#else
#define	HELP()
char malloc_debug_flag=FALSE;
#endif

void *_malloc(size_t n)
{
	memnode *p, *q, *r;

	if (n&1) ++n;
	n += sizeof(uint);
	if (n<sizeof(memnode)) n=sizeof(memnode);

	p = &_basenode;
	if (p->next==NULL)
	{
		if (_heapgrow(n) == NULL) return NULL;
		/* _heapgrow increase malloced area and frees the extra, so p->next ok */
	}

	while (p->next->size < n)
	{
		if (p->next->next==NULL)
		{
			q=_heapgrow(n);
			if (q == NULL) return NULL;
			/* if (q < p->next) */
			p=&_basenode;
			continue;
			/* _heapgrow will free a large enough area */
		}
		p=p->next;
	}
	if (p->next->size < n+sizeof(memnode))
	{	/* fits, can't split into 2 */
		q=p->next;
		p->next=p->next->next;
		return (char *)&q->next;
	}
	else
	{	/* needs splitting into 2 chunks */
		q=p->next;
		r=(memnode *)((char *)q+n);
		r->size=q->size-n;
		q->size=n;
		r->next=p->next->next;
		p->next=r;
		return (char *)&q->next;
	}
}

void _free(char *ptr)
{
	memnode *p, *q;

	if (ptr==NULL) return;
	ptr -= sizeof(uint);
	q=(memnode *) ptr;
	p=&_basenode;
	while (p->next < q)
	{
		if (p->next==NULL)
		{
			p->next=q;
			p->next->next=NULL;
			return;
		}
		p=p->next;
	}
	q->next=p->next;
	p->next=q;
	if ((char *)p+p->size==(char *)p->next)
	{
		p->size+=q->size;
		p->next=q->next;
		if ((char *)p+p->size==(char *)p->next)
		{
			p->size+=p->next->size;
			p->next=p->next->next;
		}
		return;
	}
	if ((char *)q+q->size==(char *)q->next)	/* joins following block */
	{
		q->size += q->next->size;
		q->next = q->next->next;
	}
}



memnode *_heapgrow(long n)			/* Arnor was int */
{
long m;
//long x;

	memnode *p;

	if (lockmem)
		return NULL;			/* cannot allocate any as not allowed */

	if (loaded_high)
		{
		lockmem = TRUE;			/* never alloc again */
		m = (long)(_pbase->p_hitpa) - _base + _STACK;		/* see c.s for reference */
		}
	else
		{
		m =dos_Malloc(-1);			/* returns max free space */
		//x =(long)Mxalloc(-1,0)+(long)Mxalloc(-1,1);
		}

	if (n+SPARE_RAM > m) return NULL;	/* allow a bit of space for gem */
	m-=SPARE_RAM;
	if (loaded_high)
		p = (memnode*)(_base+_STACK);
	else
		p = (memnode*)dos_Malloc(m);
	
	if (p==NULL) return NULL;

	if (_realheapstart==0L)
		_realheapstart = p;			/* remember the very first block */
		
	_heapsize = m;
	_heapstart = p;

	p->size=m;
	_free((char*)(&p->next));			/* mark new area as free */

	return p;
}

// we have been loaded high, so init heap to spare space
// spare = _base to 
void init_high_heap(void)
{

}


void _heapshrink(void)
{

	memnode *p;

	if (lockmem)
		return;				/* shouldnt ever happen */

	lockmem=TRUE;

	if (_heapstart==NULL) return;
#if 0
	{
		p=&_basenode;
		if (p->next!=NULL)
		{
			do
			{
/*testescape();*/
printf("\np=%p, p->size=%04x, p->next=%p",p,p->size,p->next);
				p=p->next;
			}
			while (p!=NULL);
		}
	}
#endif

	p = &_basenode;
	if (p->next==NULL) return;		/* no free space at all */

	/* scan through all free slots til we get the last one */
	while (p->next->next != NULL) p=p->next;

/*printf("\nheapstart=%p, heapsize=%04x",_heapstart,_heapsize);*/
/*printf("\np->next=%p, p->next->size=%04x",p->next,p->next->size);*/

	/* if end of last free slot coincides with end of heap, ret to o/s */
	if ((char *)p->next+p->next->size==(char *)_heapstart+_heapsize)
	{
		long n = _heapsize - p->next->size;
		if (n==0)
		{
/*printf("\nreleasing whole heap");*/
			Mfree(_heapstart);
			_heapstart=NULL; /* _heapsize=0; */
			p->next = NULL;
		}
		else if (n>0)
		{
/*printf("\nreleasing %04x bytes",_heapsize-n);*/
			Mshrink(_heapstart,n);
			_heapsize = n;
			p->next = NULL;
		}
	}
}

/* call this before Pexecing another program */
/* also handles keepheap value */
void heapshrink(void)
{
char *temp;
long oldworld;

	oldworld=end_of_world;
	temp=malloc(keepheap);
	end_of_world=oldworld;		/* so our block isn't marked as such */
	_heapshrink();
	free(temp);					/* free can cope with NULL */
}

void unheapshrink(void)
{
	if (am_auto==0)
		lockmem=FALSE;			/* back to normal */
}

#if 0

int rlsmem(p,u) char *p; uint u;	{	return free(p); }
void *getmem(u) uint u;				{	return malloc(u); }


static void memerr(char *s)
{
	printf("\n%s: Possible mem-alloc error. Press ESC.",s);
	while (waitchar()!=esc);
}

void *realloc(p,n) char *p; uint n;	{	memerr("REALLOC"); return NULL; }

int	allmem()						{	memerr("ALLMEM"); return -1; }
int bldmem(i) int i;				{	memerr("BLDMEM"); return -1; }

long chkml()						{	memerr("CHKML"); return -1;}
void *getml(l) long l;				{	return malloc((uint)l); }
int rlsml(p,l) void *p; long l;		{	memerr("RLSML"); return free(p); }
void rstmem()						{	memerr("RSTMEM"); }
void *sbrk(u) uint u;				{	memerr("SBRK"); return NULL; }
void *lsbrk(l) long l;				{	memerr("LSBRK"); return NULL; }
long sizmem()						{	memerr("SIZMEM"); return -1; }
#endif


static bool near shrinkinprogress=FALSE;

void *malloc(size_t n)
{
	long ret;
	
	HELP();

	if (n&1) ++n;
	ret = (long)_malloc(n);
	if (ret <= 0 && !shrinkinprogress)
	{
		shrinkinprogress=TRUE;
#ifdef ARNOR
		/* call routines here to defragment memory that is being used */
		/* shrinkcopystrings is provided as an example at the end */

		releasedicts();
		shrinkexpansions();
		shrinkcopystrings();
		shrinkback();
#endif
		shrinkinprogress=FALSE;
		ret = (long)_malloc(n);
	}
	if (ret>0)
		{ /* remember our last block */
		if ( (ret+n)>end_of_world )
			end_of_world=ret+n-1;		/* last used byte */
		}
	return (ret <= 0) ? (char *)NULL : (char *)ret;
}


void free(void *p)
{
	HELP();

	_free(p);
}     


void *calloc(size_t n,size_t size)
{
	size_t t;
	char *p=malloc(t=n*size);
	HELP();
	if (p!=NULL) memset(p,'\0',t);
	return p;
}


void *realloc(void *ptr,size_t size)
{
	memnode *q, *q2;
	char *p = ptr;

	if (size&1) ++size;		/* force odd value to even value */
	if (ptr==NULL) return malloc(size);
	if (size==0) return free(ptr);

	size += sizeof(uint);	/* size incl overhead */
	p = (char *)ptr - sizeof(uint);
	q = (memnode *) p;

	if (q->size >= size + sizeof(memnode))
	{
		/* enough room to split into two  - quite a lot smaller */
		p += size;
		q2 = (memnode *)p;
		q2->size = q->size - size;
		q->size = size;
		free(&q2->next);
		return ptr;
	}
	if (q->size >= size) return ptr;	/* same or only just smaller */

	/* a larger size */

	size -= sizeof(uint);
	p = malloc(size);
	if (p != NULL)
	{
		memcpy(p,ptr,q->size-sizeof(uint));
		free(ptr);
	}
	return p;
}


/* returns 0 for ST RAM, 1 for anything else */
/* DUBIOUS but there is no other way! The magic 00A00000 based on TT h/w manual */
word typeofmem(ulong x)
{
	if (xmalloc)
//		return (x<0x00A00000L) ? 0 : 1;			// fails after Mxaddalt
		return (x<end_st_ram) ? 0 : 1;			// new 1.02
	else
		return 0;			/* if no xmalloc, no choice */
}

#include <basepage.h>

/* return block of video memory, zeroed */
/* called during startup so (unless AUTO) doesnt have to go in main memlist */
char *getvideomem(long n)
{
	if (xmalloc)
		{
		/* this box can have both types of memory. If we have
			been loaded into ST RAM, then just malloc as normal.
			If we have been loaded into TT RAM, then
				If we are AUTO we're in trouble!
				Else Mxalloc some ST RAM
		*/
		if (typeofmem((ulong)_pbase))
			{
			char *v;
			if (am_auto)
				return NULL;				/* abort if AUTO in fast RAM */
			v=Mxalloc(n,0);
			if (v)
				memset(v,0,n);
			return v;
			}
		}
	return getzmem(n);
}


/* exiting as a TSR so shrink & exit. If we cannot then return RET code, else return 0 */
word finish_tsr(void)
{
long free,it;

	if (am_auto==-1)
		return 0;				/* dont TSR twice */
	/* TT can only TSR if loaded into ST RAM */
	if (typeofmem((ulong)_pbase))
		return RET_BADMEM;
	if (loaded_high==FALSE)
		{
		heapshrink();				/* also locks memory */
		free=dos_Malloc(-1);		/* get size of free mem */
		if ( (free<0x40000) || ((it=dos_Malloc(free))==0L) )
			return RET_NOMEM;
		Mfree(it);
		}
	else
		lockmem=TRUE;
	am_auto=-1;
	execute_prog(EM_TSR,(word*)(it-(long)_pbase),0 );
	return 0;
}

#if 0

void mallinfo(char *tail)
{
	memnode * fn, *un;		/* free and used node pointers */
	bool done;
	long totused=0;

	fn = &_basenode;	/* first free node */
	un = _realheapstart;		/* probably points to a used node */
								/* else its the same as fn */
	done=FALSE;
	while (!done)
	{
		fn = fn->next;
		if (fn==NULL) break;
		while (un != fn)		/* run through all adjacent used nodes */
		{
			totused += un->size-4;

			if (toupper(*tail)=='U')
			{
				printf("\n%04x (%u) bytes USED at %08lx",un->size-4,
				                                           un->size-4,&un->next);
				dump(&un->next,16);
			}
			if (testescape()) { done=TRUE; break; }
			un = (memnode *)((char *)un + un->size);
		}
		/* a single free node must now follow, since they get joined up */
		if (fn->size)
			col1printf("%04x (%u) bytes free at %08lx",fn->size, fn->size, fn);
		if (testescape()) break;
		/* a used node must follow unless fn->next==NULL */
		un = (memnode *)((char *)fn + fn->size);		
	}
	if (totused)
		col1printf("\nTotal bytes allocated = %08lx (%lu)",totused,totused);
}
#endif

/* debug routine to dump memory based on above */

word list_internal(char *tail)
{
	memnode * fn, *un;		/* free and used node pointers */
	long totused=0;
	word err;

	fn = &_basenode;	/* first free node */
	un = _realheapstart;		/* probably points to a used node */
							/* else its the same as fn */
	while (1)
	{
		fn = fn->next;
		if (fn==NULL) break;
		while (un != fn)		/* run through all adjacent used nodes */
		{
			totused += un->size-4;

			if (toupper(*tail)=='U')
			{
				sprintf(linebuf,"%08lx (%ld) bytes USED at %08lx\n",un->size-4,
				                                           un->size-4,&un->next);
				if (err=list_print(linebuf))
					return err;
				/* dump(&un->next,16); */
			}
			un = (memnode *)((char *)un + un->size);
		}
		/* a single free node must now follow, since they get joined up */
		if (fn->size)
			{
			sprintf(linebuf,"%08lx (%ld) bytes free at %08lx\n",fn->size, fn->size, fn);
			if (err=list_print(linebuf))
				return err;
			}
		/* a used node must follow unless fn->next==NULL */
		un = (memnode *)((char *)fn + fn->size);		
	}
	if (totused)
		{
		sprintf(linebuf,"Total bytes allocated = %08lx (%lu)\n",totused,totused);
		if (err=list_print(linebuf))
			return err;
		}
	sprintf(linebuf,"Heap=$%08lx (1st=$%08lx)\n",_heapstart,_realheapstart);
	return list_print(linebuf);
}

/* return free bytes in debugger heap, based on debug code! */
void heap_free(long *usedx,long *freex)
{
long used,free;
memnode * fn, *un;		/* free and used node pointers */

	used=free=0L;

	fn = &_basenode;			/* first free node */
	un = _realheapstart;		/* probably points to a used node */
								/* else its the same as fn */
	while (1)
	{
		fn = fn->next;
		if (fn==NULL) break;
		while (un != fn)		/* run through all adjacent used nodes */
		{
			used += un->size-4;
			un = (memnode *)((char *)un + un->size);
		}
		/* a single free node must now follow, since they get joined up */
		free+=fn->size;
		/* a used node must follow unless fn->next==NULL */
		un = (memnode *)((char *)fn + fn->size);		
	}
	if (usedx) *usedx=used;
	if (freex) *freex=free;	
}

#if 0		/* example only of a memory shrinking routine - prog. specific */
#ifdef IBMORATARI
/*
go through all mallocked copystrings in turn
try to malloc an equal area for each one, and free the higher value
*/
void shrinkcopystrings(void)
{
	int i;
	bool changed;
	do
	{
		changed=FALSE;
		for (i=0; i<20; ++i)
		{
			if (shrink(&copystrings[i],strlen(copystrings[i])+1))
				changed = TRUE;
		}
	}
	while (changed);
}

bool shrink(void **p,uint size)
{
	char *newp = malloc(size);
	if (newp)
	{
		if (TOLONG(newp) < TOLONG(*p))
		{
			memcpy(newp,*p,size);
			free(*p);
			*p = newp;
			return TRUE;
		}
		else free(newp);
	}
	return FALSE;
}
#endif
#endif
