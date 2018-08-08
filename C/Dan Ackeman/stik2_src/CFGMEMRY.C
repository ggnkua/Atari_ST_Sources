/* *  Memory allocation routines based on K&R pp175-177 *  Originally by Steve Adam. Revised by Martin Mitchell. * *  All these routines work on a buffer of a configured length. * 
 *  This is basically KRMALLOC reworked for the config file
 * This will create a memory buffer for config information
 * and provide routines for manipulating it.
 */
#include "lattice.h"#include <tos.h>     /* For Malloc() */#include <stdio.h>
#include <stdlib.h>#include "krmalloc.h"#include "display.h"

#include "globdefs.h"#include "globdecl.h"	/* for uint32 */

#ifndef NULL#define   NULL   ( (void*) 0L )#endifstatic HEADER *cfgp = NULL;#define	MINALLOC	(4)#define	ALLOCUNIT	(sizeof(HEADER) + MINALLOC)#define ALLOCMAGIC	0xfeedbeadL#define PREMAGIC	0xeadebedeL
#define POSTMAGIC	0xd00dc0deL
#define BOUNDSIZE	2


/* CFGmeminit() is basically morecore(), but is only called ONCE * before any allocated blocks are returned. */
int CFGmeminit(unsigned long nbytes){
	/* Round nbytes up to a multiple of ALLOCUNIT size */	if ( (nbytes % ALLOCUNIT) != 0 )		nbytes += (ALLOCUNIT - (nbytes % ALLOCUNIT));	/* Create new free list - One block pointing to itself */	cfgp = (HEADER *) Malloc(nbytes);	if ( cfgp == NULL )		return 0;		/* not enough memory */
	cfgp->size = nbytes / ALLOCUNIT;	cfgp->ptr = cfgp;	return 1;             /* return 1 for success */}/* K&R p 175    */
char * cdecl 
CFGmalloc(unsigned long reqsize) /* was STiKmalloc */{	register HEADER *p = cfgp;
	register HEADER *prevp = cfgp;	register unsigned long nunits;
	if ( reqsize < MINALLOC )
		reqsize = MINALLOC;
	nunits = 1L + ( ( (reqsize - MINALLOC) % ALLOCUNIT ) != 0L ) + ( ( reqsize - MINALLOC ) /ALLOCUNIT );	if (prevp == NULL)	{		disp_info("CFGmalloc - critical error - free list pointer is NULL");		return NULL;	}
	/* Start at the second block, not the first.  Otherwise, if the first block
		is used, we can't wrap around the linked list */	do	{
		p = p->ptr;

		if ( p->size >= nunits )		{			if ( p->size == nunits )			{				/* allocation fits exactly - take out of free list */				/*disp_info("exact alloc");*/				prevp->ptr = p->ptr;

				/* See if we grabbed the first block */
				if (p == cfgp)					cfgp = prevp->ptr;			}			else			{				/* current block too large, chop it down to size */				/* need cast for correct pointer arithmetic */				p->size -= nunits;				(char *) p += ( p->size * ALLOCUNIT );				p->size = nunits;			}
			p->ptr = (HEADER *)ALLOCMAGIC;
			return (char *) p+sizeof(HEADER);		}
		prevp = p;	} while ( p != cfgp );	/* No block found, deny allocation request */
	return NULL;}/* K&R p 177    */
int cdecl CFGfree(char *ap){	register HEADER *bp = (HEADER *) ap;	register HEADER *p;
	int		mergebefore=FALSE;
	int		mergeafter=FALSE;

	(char *) bp = ap - sizeof(HEADER);
	
	if ( (unsigned long) bp->ptr != ALLOCMAGIC)	{
 		disp_info("CFGfree - memory corruption detected");

 		return(E_NORMAL);	}

	/* First check to see if it's before the first block */
	if ((char *) bp < (char *)cfgp)
	{
		/* Can we merge it with the first block? */
		if ((char *) bp + (ALLOCUNIT * bp->size) == (char *) cfgp)
		{
			bp->size += cfgp->size;
			bp->ptr = cfgp->ptr;
		}
		else
			bp->ptr = cfgp;

		cfgp = bp;

		return(E_NORMAL);
	}
	/* Find where the block should go */
	p = cfgp;
	while ((bp > p->ptr) && (p->ptr != cfgp))
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
		p->ptr = p->ptr->ptr;
	}
	else if (mergebefore)
	{
		p->size += bp->size;
	}
	else if (mergeafter)
	{
		bp->ptr = p->ptr->ptr;
		bp->size += p->ptr->size;
		p->ptr = bp;
	}
	else /* no merge, put in list */
	{
		bp->ptr = p->ptr;
		p->ptr = bp;
	}
	
	return(E_NORMAL);
}
static void CFGmemclr(uint32 *to, uint32 count){    unsigned long cnt = count / 4;    if (count % 4)        cnt += 1;    while (cnt--)        *to++ = 0L;}static voidCFGmemcpy(uint32 *to, uint32 *from, unsigned long count){    register unsigned long cnt = count / 4;    if (count % 4)        cnt += 1;    while (cnt--)        *to++ = *from++;}/* CFGrealloc()  Change the size of an allocated block of memory. *              If newsize < oldsize, simply trim off the excess *              Otherwise, allocate a new block, and copy the old *              data into it. *              If called with newsize = 0, free the block and return NULL *              If called with newsize > 0, and Old block == (char *)NULL *              The malloc() a new block, but clear it before returning it. */
char * cdecl CFGrealloc(char *ob, unsigned long newsize){	HEADER *p;	unsigned long nunits, oldunits, newunits;	char *newp;	/* For ANSI compatability (I think).  If the old buffer is 	(char *)NULL, then treat this realloc as a new STiKmalloc() */	if ( ob == NULL )	{

		ob = CFGmalloc(newsize);
		if ( ob != NULL )		{			CFGmemclr((uint32 *)ob, (uint32)newsize);		}

		return ob;	}	else if ( newsize == 0 )	{		CFGfree(ob);
		return NULL;	}	(char *) p = ob - sizeof(HEADER);
	oldunits = p->size;
	if ( newsize < MINALLOC )
	{
		newsize = MINALLOC;
	}

	nunits = 1L + ( ( (newsize - MINALLOC) % ALLOCUNIT ) != 0L ) + ( ( newsize - MINALLOC ) /ALLOCUNIT );	/* If oldsize in units is equal to new size, or the difference	 is only 1 header size, do nothing.	 (There's no point creating a zero sized block) */
	if ( (oldunits >= nunits) && ((oldunits - nunits) < 2))	{
		return (ob);	}	/* If new size is greater than oldsize, then STiKmalloc() a new	block, and copy the data from the old block */	if (nunits > oldunits)	{
		if ((newp = CFGmalloc(newsize)) == NULL)		{
			return NULL;		}

		CFGmemcpy((uint32 *)newp, (uint32 *)ob, ((oldunits - 1L) * ALLOCUNIT) );
		CFGfree(ob);		return newp;	}	/* Otherwise, the new size is smaller than the old size	so all we have to do is split off the empty part,	which will be at least 1 header followed by a	header sized block */	newunits = oldunits - nunits;	p->size = nunits;   /* Update existing block    */	/* Setup new block */	(char *) p += ( nunits * ALLOCUNIT );	p->size = newunits;	p->ptr = (HEADER *)ALLOCMAGIC;	CFGfree( (char *)p + sizeof(HEADER) );	
	return ob;}unsigned long cdecl CFGgetfree(int flag){	HEADER *p;	unsigned long len = 0, bsize;	p = cfgp;	do	{		bsize = (p->size * ALLOCUNIT) - sizeof(HEADER);		if (flag)
		{
			if (bsize > len)			{				len = bsize;
			}		}		else		{			len += bsize;		}		p = p->ptr;	} while (p != cfgp);  /* Stop when we've circled back to the start    */	return len;}
