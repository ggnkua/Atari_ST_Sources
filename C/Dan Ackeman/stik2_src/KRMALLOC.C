/* *  Memory allocation routines based on K&R pp175-177 *  Originally by Steve Adam. Revised by Martin Mitchell. * *  STiKrealloc(), STiKgetfree() added by Steve Adam. * *  All these routines work on a buffer of a configured length. */
#if 0
#define	uint32 unsigned#endif
#include "lattice.h"#include <tos.h>     /* For Malloc() */#include <stdio.h>
#include <stdlib.h>#include "krmalloc.h"#include "display.h"

#include "globdefs.h"#include "globdecl.h"	/* for uint32 */

#ifndef NULL#define   NULL   ( (void*) 0L )#endifstatic int mem_initialised = 0;

static HEADER *freep = NULL;#define	MINALLOC	(4)#define	ALLOCUNIT	(sizeof(HEADER) + MINALLOC)#define ALLOCMAGIC	0xfeedbeadL#define PREMAGIC	0xeadebedeL
#define POSTMAGIC	0xd00dc0deL
#define BOUNDSIZE	2

#define	FLPROTBEGIN	if(set_flag(FL_malloc)==FALSE)
#define FLPROTEND	clear_flag(FL_malloc)
#define BEGB		{
#define ENDB		}

/*#define	FLPROTBEGIN	while (set_flag(FL_malloc)==FALSE)
#define FLPROTEND	clear_flag(FL_malloc)*/

/*#define	FLPROTBEGIN	while (set_flag(FL_housekeep)==FALSE)
#define FLPROTEND	clear_flag(FL_housekeep)*/
#if MEMDEBUG

	typedef struct stikmemdebug
	{
		char *start;
		char *file;
		int	line;
		unsigned long size;
	} SKMD;

	typedef char *STiKListKeyType;
	typedef SKMD *STiKListValType;

	#include "stiklist.c"

	#undef STiKmalloc
	#undef STiKrealloc
	#undef STiKfree

	static STiKList	md;

	typedef struct {
		char *file;
		UWORD line;
		char *loc;
	} BUF_HIST_BUF;
	static BUF_HIST_BUF memdebughist[100];

static void memdebugreport(void)
{
	STiKListNode ln;
	SKMD		*skmd;
	
	disp_info("Memory leaks:");
	if (STiKListEmpty(md))
	{
		disp_info("No leaks.");
		return;
	}
	while (!STiKListEmpty(md))
	{
		ln=STiKListGetAnyNode(md);
		skmd=ln->val;
		disp_info("Address: %p : %ld bytes at line %d of %s",skmd->start,skmd->size,skmd->line,skmd->file);
		md=STiKListRemoveNode(md,ln->key);
	}
}

static void memlistshow(void){	if (freep == NULL)	{		disp_info("freep is NULL");	}	else	{		HEADER *hp = freep;		do		{			disp_info("free block at %p, size %lu units, size %lu bytes, next %p",hp,hp->size,hp->size*ALLOCUNIT,hp->ptr);			hp=hp->ptr;		} while ( hp != freep );	}}

static int checkblockbounds( char *ap, uint32 size )
{
	int i;
	int er=0;

	for (i = BOUNDSIZE ; i >= 1 ; i-- )
	{
		if (*(unsigned long *)(ap - (i*4)) != PREMAGIC)
		{
			disp_info("STiKblockcheck: premagic phase %d invalid",i);
			er=1;
		}
	}
	for (i = BOUNDSIZE-1 ; i >= 0 ; i-- )
	{
		if (*(unsigned long *)(ap + size + (i*4)) != POSTMAGIC)
		{
			disp_info("STiKblockcheck: postmagic phase %d invalid",i);
			er=1;
		}
	}
	return er;
}

static int memintegritycheck(void)
{
	STiKListNode ln;
	SKMD *skmd;
	HEADER *p=freep;
	int er=0;
	
	if ( STiKListEmpty(md) )
	{
		return er;
	}
	
	ln = STiKListGetAnyNode(md);
	
	do
	{
		skmd = (SKMD *) ln->val;
	
		if (checkblockbounds(ln->key,skmd->size) != 0 )
		{
			disp_info("memintegritycheck failed on block:");
			disp_info("%p allocated from %s:%d size %ld",skmd->start,skmd->file,skmd->line,skmd->size);
			er = 1;
		}
	
	} while( ( ln = STiKListGetNextNode(md, ln) ) != NULL );

	do
	{
		p=p->ptr;
	} while (p != freep);

	return er;
}

char * cdecl STiKmalloc(unsigned long size, const char *file, int line )
{
	char *s;
	STiKListNode	ln;
	SKMD	*skmd;
	int i;

	/*disp_info("STiKmalloc: called from %s:%d with request for %ld bytes",file,line,size);*/

	if (memintegritycheck()!=0)
	{
		disp_info("STiKmalloc: beginning integrity check failed");
		disp_info("STiKmalloc: called from %s:%d with request for %ld bytes",file,line,size);
	}
	
	if ( ( s = STiKintmalloc( (unsigned long) sizeof(struct stik_lnde) + sizeof(SKMD) + sizeof(char) + (BOUNDSIZE * 8) + size ) ) == NULL )
	{
		disp_info("STiKmalloc: out of memory");
		return NULL;
	}
	ln = (STiKListNode) s;
	ln->key = (s + sizeof(struct stik_lnde) + sizeof(SKMD) + (BOUNDSIZE * 4) );
	ln->val = skmd = (SKMD *) (s + sizeof(struct stik_lnde) );
	ln->next = NULL;
	skmd->start = s;
	skmd->size = size;
	skmd->file = (char *) file;
	skmd->line = line;
	for (i = 1 ; i <= BOUNDSIZE ; i++ )
	{
		*(unsigned long *)(ln->key - (i*4)) = PREMAGIC;
	}
	for (i = 0 ; i < BOUNDSIZE ; i++ )
	{
		*(unsigned long *)(ln->key + size + (i*4)) = POSTMAGIC;
	}
	md=STiKListInsertNode(md,ln);
	/*disp_info("STiKmalloc: %p : %ld(%ld) bytes at line %d of %s",ln->key,size,skmd->size,skmd->line,skmd->file);*/
	if (memintegritycheck()!=0)
	{
		disp_info("STiKmalloc: ending integrity check failed");
		disp_info("STiKmalloc: called from %s:%d with request for %ld bytes",file,line,size);
	}
	return ln->key;
}


void cdecl STiKfree(char *ap, const char *file, int line){
	SKMD	*skmd = STiKListFindKey(md, ap);
	static UBYTE hist_cnt = 0;
	UBYTE this_hist;

	/* disp_info("STiKfree: called from %s:%d with request to free %p",file,line,ap); */

	if (memintegritycheck()!=0)
	{
		disp_info("STiKfree: beginning integrity check failed");
		disp_info("STiKfree: called from %s:%d with request to free %p",file,line,ap);
	}
	
	if (skmd == NULL)
	{
		disp_info("STiKfree: error deallocating block - called from %d of %s",line,file);
		disp_info("STiKfree: trying to free block %p, not in allocated list!",ap);
		/* Loop through to find if it's been used before */
		for(this_hist=0; this_hist<100; this_hist++)
			if (memdebughist[this_hist].loc == ap)
				disp_info("STiKfree: last freed by %s:%d",
						memdebughist[this_hist].file,
						memdebughist[this_hist].line);
		memdebugreport();
		md = STiKListRemoveNode(md, ap);
		return;
	}
	/* boundary checking */
	
	if (checkblockbounds(ap,skmd->size) != 0 )
	{
		disp_error("STiKfree: memory error in block of size %ld allocated from line %d of %s",skmd->size,skmd->line,skmd->file);
		disp_error("STiKfree called from %d of %s",line,file);
	}
	
	md = STiKListRemoveNode(md, ap);

	memdebughist[hist_cnt].file = (char *)file;
	memdebughist[hist_cnt].line = line;
	memdebughist[hist_cnt].loc = ap;
	hist_cnt = (hist_cnt + 1) % 100;

	STiKintfree(skmd->start);
	if (memintegritycheck()!=0)
	{
		disp_info("STiKfree: ending integrity check failed");
		disp_info("STiKfree: called from %s:%d with request to free %p",file,line,ap);
	}
}

#endif /* MEMDEBUG */

/* STiKmeminit() is basically morecore(), but is only called ONCE * before any allocated blocks are returned. */
int STiKmeminit(unsigned long nbytes){
#if MEMDEBUG
	UBYTE i;
#endif
	if (mem_initialised)	{		disp_info("STiKmeminit called twice");		return 0;	}
#if MEMDEBUG

	md=STiKListInit(md);
	for (i=0; i<100; i++)
	{
		memdebughist[i].file = NULL;
		memdebughist[i].line = 0;
		memdebughist[i].loc = NULL;
	}
#endif
	/* Round nbytes up to a multiple of ALLOCUNIT size */	if ( (nbytes % ALLOCUNIT) != 0 )	{		nbytes += (ALLOCUNIT - (nbytes % ALLOCUNIT));	}	/* Create new free list - One block pointing to itself */	freep = (HEADER *) Malloc(nbytes);	if ( freep == NULL )	{		return 0;		/* not enough memory */	}	freep->size = nbytes / ALLOCUNIT;	freep->ptr = freep;	/*printf("STiKmeminit - nbytes is %lu\n",nbytes);	memlistshow();*/	mem_initialised = 1;	return 1;             /* return 1 for success */}/* K&R p 175    */
#if MEMDEBUG
char * cdecl STiKintmalloc(unsigned long reqsize)
#elsechar * cdecl STiKintmalloc(unsigned long reqsize) /* was STiKmalloc */#endif
{	register HEADER *p = freep;
	register HEADER *prevp = freep;	register unsigned long nunits;
	if (!mem_initialised)	{		disp_info("STiKalloc - not initialised");		return NULL;	}
	if ( reqsize < MINALLOC )
		reqsize = MINALLOC;
	nunits = 1L + ( ( (reqsize - MINALLOC) % ALLOCUNIT ) != 0L ) + ( ( reqsize - MINALLOC ) /ALLOCUNIT );	/*disp_info("STiKintmalloc: nunits is %lu for %lu bytes of memory.\n",nunits,reqsize);*/	if (prevp == NULL)	{		disp_info("STiKalloc - critical error - free list pointer is NULL");		return NULL;	}
	/* Start at the second block, not the first.  Otherwise, if the first block
		is used, we can't wrap around the linked list */	do	{
		p = p->ptr;
		/*disp_info("STiKintmalloc: found free block size %lx nunits is %lx at %p",p->size,nunits,p);*/
		if ( p->size >= nunits )		{			if ( p->size == nunits )			{				/* allocation fits exactly - take out of free list */				/*disp_info("exact alloc");*/				prevp->ptr = p->ptr;

				/* See if we grabbed the first block */
				if (p == freep)					freep = prevp->ptr;			}			else			{				/* current block too large, chop it down to size */				/* need cast for correct pointer arithmetic */				p->size -= nunits;				(char *) p += ( p->size * ALLOCUNIT );				p->size = nunits;			}
			/*disp_info("SA: freep->size is %lu freep->ptr->size is %lu",freep->size, freep->ptr->size);*/

			p->ptr = (HEADER *)ALLOCMAGIC;
			/*memlistshow();*/
			/*disp_info("STiKintalloc %lu(%lu) bytes %p",reqsize,p->size,(char *) p+sizeof(HEADER));*/

			return (char *) p+sizeof(HEADER);		}
		prevp = p;	} while ( p != freep );	/* No block found, deny allocation request */	/*memlistshow();*/

	return NULL;}#if 0    for (p = prevp->ptr; ; prevp = p, p = p->ptr)     {        /*if ((long)p->size & (long)FREE_MASK)         {            disp_info("STiK STiKmalloc() - Free list corrupt!");            return((char *)0);        }*/        if (p->size >= nunits)         {            if (p->size == nunits)                prevp->ptr = p->ptr;    /* Maintain free link.  */            else             {                p->size -= nunits;                p += p->size;                p->size = nunits;            }            freep = prevp;            p->ptr = (HEADER *)ALLOCMAGIC; /* Magic in otherwise useless ptr */            return ((char *)&p[1]);        }        if (p == freep)    /* We've wrapped, without finding a block   */            return ((char *)0); /* No morecore() for us!!  That's it!   */    }}#endif/* K&R p 177    */
#if MEMDEBUGint cdecl STiKintfree(char *ap)#else
int cdecl STiKfree(char *ap)#endif
{	register HEADER *bp = (HEADER *) ap;	register HEADER *p;
	int		mergebefore=FALSE;
	int		mergeafter=FALSE;

	FLPROTBEGIN
	BEGB
	(char *) bp = ap - sizeof(HEADER);
	
	/*disp_info("bp->size is %lu at %p",bp->size,ap);*/	if ( (unsigned long) bp->ptr != ALLOCMAGIC)	{
 		disp_info("STiKfree - memory corruption detected");

#if MEMDEBUG		disp_info("when trying to free %p",ap);
		disp_info("data sample: %p %p %p %p %p %p %p %p", (ap-8), (ap-4), ap, (ap+4), (ap+8), (ap+12), (ap+16), (ap+20));
 		memdebugreport();
 		memlistshow();
 		getchar();
#endif

 		FLPROTEND;
 		return(E_NORMAL);	}

	/* First check to see if it's before the first block */
	if ((char *) bp < (char *)freep)
	{
		/* Can we merge it with the first block? */
		if ((char *) bp + (ALLOCUNIT * bp->size) == (char *) freep)
		{
			bp->size += freep->size;
			bp->ptr = freep->ptr;
		}
		else
			bp->ptr = freep;

		freep = bp;
		FLPROTEND;
		return(E_NORMAL);
	}
	/* Find where the block should go */
	p = freep;
	while ((bp > p->ptr) && (p->ptr != freep))
		p = p->ptr;

	if ((char *) bp + (ALLOCUNIT * bp->size) == (char *) p->ptr)
	{
		mergeafter=TRUE;
	}
	
	if ((char *) p + (ALLOCUNIT * p->size) == (char *) bp)
	{
		mergebefore=TRUE;
	}

	if (mergebefore && mergeafter)
	{
		p->size += p->ptr->size + bp->size;
		/*disp_info("set size %lu",bp->size);*/
		p->ptr = p->ptr->ptr;
	}
	else if (mergebefore)
	{
		p->size += bp->size;
		/*disp_info("set size %lu",bp->size);*/
	}
	else if (mergeafter)
	{
		bp->ptr = p->ptr->ptr;
		bp->size += p->ptr->size;
		/*disp_info("set size %lu",bp->size);*/
		p->ptr = bp;
	}
	else /* no merge, put in list */
	{
		bp->ptr = p->ptr;
		p->ptr = bp;
	}

#if 0
	/* Merge bp with block after p->ptr */
	if ((char *) bp + (ALLOCUNIT * bp->size) == (char *) p->ptr) 	{		bp->size += p->ptr->size;		bp->ptr = p->ptr->ptr;	}	else	/* non free block between bp and p->ptr */	{		bp->ptr = p->ptr;	}	if ((char *) p + (ALLOCUNIT * p->size) == (char *) bp) 	{		p->size += bp->size;		p->ptr = bp->ptr;	}	else	{		p->ptr = bp;	}#endif

	/*disp_info("SF: freep->size is %lu freep->ptr->size is %lu mergebefore %d mergeafter %d atend %d",freep->size, freep->ptr->size,mergebefore,mergeafter,atend);*/

	/*disp_info("STiKfree %p",ap);*/

	/*memlistshow();*/	FLPROTEND;
	ENDB
	else
	{
		disp_info("Routine Locked - STiK Free");
		return(E_LOCKED);
	}
	
	return(E_NORMAL);
}
static void STiKmemclr(uint32 *to, uint32 count){    unsigned long cnt = count / 4;    if (count % 4)        cnt += 1;    while (cnt--)        *to++ = 0L;}static voidSTiKmemcpy(uint32 *to, uint32 *from, unsigned long count){    register unsigned long cnt = count / 4;    if (count % 4)        cnt += 1;    while (cnt--)        *to++ = *from++;}/* STiKrealloc()  Change the size of an allocated block of memory. *              If newsize < oldsize, simply trim off the excess *              Otherwise, allocate a new block, and copy the old *              data into it. *              If called with newsize = 0, free the block and return NULL *              If called with newsize > 0, and Old block == (char *)NULL *              The malloc() a new block, but clear it before returning it. */
#if MEMDEBUG
char * cdecl STiKrealloc(char *ob, unsigned long newsize, const char *file, int line)
#elsechar * cdecl STiKrealloc(char *ob, unsigned long newsize)#endif
{	HEADER *p;	unsigned long nunits, oldunits, newunits;	char *newp;/*	FLPROTBEGIN
	BEGB
*/

#if MEMDEBUG	
	disp_info("STiKrealloc %p to %lu bytes %s:%d",ob,newsize,file,line);
#endif
	/* For ANSI compatability (I think).  If the old buffer is 	(char *)NULL, then treat this realloc as a new STiKmalloc() */	if ( ob == NULL )	{

#if MEMDEBUG
		ob = STiKmalloc(newsize,file,line);
#else		ob = STiKintmalloc(newsize);#endif

		if ( ob != NULL )		{			STiKmemclr((uint32 *)ob, (uint32)newsize);		}

/*		FLPROTEND;*/		return ob;	}	else if ( newsize == 0 )	{#if MEMDEBUG
		STiKfree(ob,file,line);
#else
		STiKfree(ob);
#endif
/*		FLPROTEND;*/		return NULL;	}#if MEMDEBUG
	(char *) p = ob - sizeof(HEADER) - ( sizeof(struct stik_lnde) + sizeof(SKMD) + (BOUNDSIZE * 4) );
#else
	(char *) p = ob - sizeof(HEADER);#endif

	oldunits = p->size;
#if MEMDEBUG
	{
		unsigned long debugsize = (unsigned long) sizeof (struct stik_lnde) + sizeof(SKMD) + sizeof(char) + (BOUNDSIZE * 8);
		oldunits -= ( ( debugsize % ALLOCUNIT ) != 0L ) + ( debugsize / ALLOCUNIT );
	}
#endif

	if ( newsize < MINALLOC )
	{
		newsize = MINALLOC;
	}

#if MEMDEBUG
	newsize += (unsigned long) sizeof(struct stik_lnde) + sizeof(SKMD) + sizeof(char) + (BOUNDSIZE * 8);
#endif
	nunits = 1L + ( ( (newsize - MINALLOC) % ALLOCUNIT ) != 0L ) + ( ( newsize - MINALLOC ) /ALLOCUNIT );	/* If oldsize in units is equal to new size, or the difference	 is only 1 header size, do nothing.	 (There's no point creating a zero sized block) */
#if MEMDEBUG
	disp_info("STiKrealloc: oldunits %ld newunits %ld",oldunits,nunits);
#endif
	if ( (oldunits >= nunits) && ((oldunits - nunits) < 2))	{
/*		FLPROTEND;*/		return (ob);	}	/* If new size is greater than oldsize, then STiKmalloc() a new	block, and copy the data from the old block */	if (nunits > oldunits)	{
#if MEMDEBUG
		if ((newp = STiKmalloc(newsize,file,line)) == NULL)
#else		if ((newp = STiKintmalloc(newsize)) == NULL)#endif
		{
/*			FLPROTEND;*/
			return NULL;		}

#if MEMDEBUG
		disp_info("STiKrealloc: calling STiKmemcpy with %ld",((oldunits -1L) * ALLOCUNIT) );#endif
		STiKmemcpy((uint32 *)newp, (uint32 *)ob, ((oldunits - 1L) * ALLOCUNIT) );
#if MEMDEBUG
		disp_info("STiKrealloc: STiKmemcpy complete, freeing old block");
		STiKfree(ob,file,line);
#else
		STiKfree(ob);#endif

#if MEMDEBUG
		disp_info("STiKrealloc: old block freed");
#endif
/*		FLPROTEND;*/
		return newp;	}	/* Otherwise, the new size is smaller than the old size	so all we have to do is split off the empty part,	which will be at least 1 header followed by a	header sized block */#if MEMDEBUG
	disp_info("STiKrealloc: shrinking block");
#endif
	newunits = oldunits - nunits;	p->size = nunits;   /* Update existing block    */	/* Setup new block */	(char *) p += ( nunits * ALLOCUNIT );	p->size = newunits;	p->ptr = (HEADER *)ALLOCMAGIC;#if MEMDEBUG
	STiKfree( (char *)p + sizeof(HEADER), file, line);
#else
	STiKfree( (char *)p + sizeof(HEADER) );#endif
/*	FLPROTEND;
	ENDB
	else
		disp_info("Routine Locked - STiK Realloc");
*/	
	return ob;}unsigned long cdecl STiKgetfree(int flag){	HEADER *p;	unsigned long len = 0, bsize;	p = freep;	do	{		bsize = (p->size * ALLOCUNIT) - sizeof(HEADER);		if (flag)
		{
			if (bsize > len)			{				len = bsize;
			}		}		else		{			len += bsize;		}		p = p->ptr;	} while (p != freep);  /* Stop when we've circled back to the start    */	return len;}

char * cdecl STiKmalloc(unsigned long nbytes)
{
	char *tmp;
	FLPROTBEGIN
	BEGB

#if MEMDEBUG
	disp_info("STiKextmalloc %ld bytes",nbytes);
	tmp = STiKmalloc((unsigned long) nbytes, __FILE__, __LINE__);
#else
	tmp = STiKintmalloc((unsigned long) nbytes);
#endif

	FLPROTEND;
	ENDB
	else
/*	{*/
		disp_info("Routine Locked - STiKmalloc");
/*		return(E_LOCKED);
	}*/
	
	return tmp;
}

char * cdecl STiKextmalloc(long nbytes)
{
	char *tmp;

#if MEMDEBUG
	disp_info("STiKextmalloc %ld bytes",nbytes);
	tmp = STiKmalloc((unsigned long) nbytes, __FILE__, __LINE__);
#else
	tmp = STiKmalloc((unsigned long) nbytes);
#endif

	return tmp;
}

char * cdecl STiKextrealloc(char *ob, long bytes)
{
	char *tmp;

#if MEMDEBUG
	disp_info("STiKextrealloc %p to %ld bytes",ob,bytes);

	tmp = STiKrealloc(ob, (unsigned long) bytes, __FILE__, __LINE__);
#else
	tmp = STiKrealloc(ob, (unsigned long) bytes);
#endif

	return tmp;
}
void cdecl STiKextfree(char *ap)
{

#if MEMDEBUG
	disp_info("STiKextfree %p",ap);

	STiKfree(ap, __FILE__, __LINE__);
#else
	STiKfree(ap);
#endif
}

long cdecl STiKextgetfree(int flag)
{
	return (long) STiKgetfree(flag);
}