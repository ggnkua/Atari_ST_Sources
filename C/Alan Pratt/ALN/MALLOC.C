/*
******************* Revision Control System *****************************
*
* $Author: apratt $
* =======================================================================
*
* $Date: 88/08/23 14:20:26 $
* =======================================================================
*
* $Locker:  $
* =======================================================================
*
* $Log:	malloc.c,v $
* Revision 1.1  88/08/23  14:20:26  apratt
* Initial revision
* 
* =======================================================================
*
* $Revision: 1.1 $
* =======================================================================
*
* $Source: /u/apratt/work/aln/RCS/malloc.c,v $
* =======================================================================
*
*************************************************************************
*/
/********************************************************************
*	lmalloc, lfree - long-valued memory allocator mechanism
*	lrealloc, lcalloc, lblkfill, lsbrk
*
*	9/83: fixed free bug, added check int   whf
*	10/83: added debugging features: DEBUGMEM and MALLOCND hooks   whf
*	08/86: made ints into longs, removed debugging features	akp
*	09/86: added malloc(-1L) returns size of largest block akp
*	       placed lcalloc, lzalloc, lblkfill in this source file akp
*
* char *lmalloc(numchars) 
*		long numchars		AKP
*	Returns a pointer to an area of memory at least 'numchars'
*	in length.  Returns NULL if out of memory or corrupted freelist.
*	Warning: the size of the area is right below the region: 
*	do not overwrite!
*
*
* int lfree(mptr)
*		char *mptr
*	Frees the region pointed to by 'mptr'.  Returns 0 (SUCCESS) if ok,
*	FAILURE (-1) if corrupted freelist (or if mptr was not previously
*	allocated by malloc).
*
*
* char *lrealloc(mptr,numchars)
*		char *mptr
*		long numchars		AKP
*	Returns a pointer to a (probably different) region of memory
*	(numchars long) containing the same data as the old region 
*	pointed to by mptr. Returns NULL if not enough memory, or
*	if freelist was corrupted.
*
* char *lsbrk(amount)
*		long amount;		AKP
*	Returns a pointer to new memory, allocated from the operating system.
*
************************************************************************/

/********************************************************************
*
*	lcalloc.c - memory allocator for sets of elements
*	lzalloc	 - memory allocator like malloc only zeros storage.
*
*	char *lcalloc(nelem,sizelem)
*		long nelem, sizelem;
*
*	Returns a pointer to a region of (zero filled) memory large
*	enough to hold 'nelem' items each of size 'sizelem'.
*	Returns NULL if not enough memory.
*	(removed 8086 range checking -akp)
*
*	char *lzalloc(nbytes)
*		long	nbytes;
*
*	Returns a pointer to a region of zero filled memory nbytes long.
*	Returns NULL if not enough memory.
*
*********************************************************************/

#define FB_HDR struct hdr			/* free block header type   */
#define NULLFBH ((FB_HDR *)0)			/* Null of above struct     */
#define NULL (char *)0				/*			    */

FB_HDR {					/* mem_block header	    */
	struct hdr *ptr;			/* ptr next blk (when freed)*/
	long size;				/* block size (always) AKP  */
};						/****************************/
						/*			    */
static FB_HDR _afreebase = {&_afreebase,0 };	/* initial (empty) block    */
static FB_HDR *_aflistptr = &_afreebase;	/* ptr into ring of freeblks*/
						/*			    */
#define AOFFS 1L                /* alignment offset: 0=char, 1=int, 3=quad */
#define AMASK(c) ((char *)((long)(c) & ~AOFFS))	/* mask alignment bits	    */
#define AFUDGE 4	 		  /* leeway for passing block as is */
#define ACHUNKS 64 				/* chunks to alloc from O.S.*/
						/*			    */
						/*** end of "malloc.h" ******/
/****************************************************************************/
/* lmalloc - general purpose memory allocator
* This function allocates the requested number of chars (nchars) and returns
*	a pointer to this space to the calling function.
*	The memory is requested from the O.S. in larger chunks, and
*	free space is managed as a ring of free blocks.  Each block
*	contains a pointer to the next block (s.ptr), a block size (s.size),
*	and the space itself.
*	Alignment is handled by assuming that sizeof(FB_HDR) is an aligned
*	quantity, and allocating in multiples of that size.
**************************************************			    */
char *	lmalloc(nchars)				/* CLEAR FUNCTION ***********/
register long nchars;				/* number chars requested   */
{						/****************************/
    register	long nmults;			/* multiples of FB_HDR size */
    register	FB_HDR *pp;			/* temporary ptr	    */
	FB_HDR *findblock();			/* find free block	    */
	char *cutup();				/* cut free block to fit    */
						/*			    */
    /* special case: malloc(-1L) returns size of largest block AKP */
	if (nchars == -1) {
		/* return size of largest block */
		register FB_HDR *cp = _aflistptr->ptr;
		register long largest = _aflistptr->size;
		cp = _aflistptr->ptr;
		while (cp != _aflistptr) {
			if (cp->size > largest) largest = cp->size;
			cp = cp->ptr;
		}
		return (char *)(largest * sizeof(FB_HDR));
	}

	nmults = (nchars+sizeof(FB_HDR)-1)/sizeof(FB_HDR)+1; /*		    */
	if( (pp=findblock(nmults)) == NULLFBH )	/* find ptr to ptr to block */
		return NULL;			/*	no luck...	    */
	return cutup(pp,nmults);		/* cut block to fit & return*/
}						/****************************/

/****************************************************************************/
/* findblock - local subr to find a free block that's big enough.	    */
/*	It returns a pointer to the freeblock BEFORE the desired freeblock, */
/*	in order to fix the pointer of the this freeblock.		    */
/*************************************************			    */
    static FB_HDR *				/*			    */
findblock(units)				/* find a free block	    */
register long units;				/* at least this big	    */
{						/****************************/
    register	FB_HDR	*cp;			/* ptr to current block	    */
    register	FB_HDR	*pp;			/* ptr to previous block    */
	FB_HDR	*getmemory();			/* get from OS, add to list */
						/*			    */
	pp = _aflistptr;			/* start search here	    */
	cp = pp->ptr;				/* init current ptr	    */
	while(1)				/* do forever		    */
	{					/*			    */
	    if( cp->size >= units )		/* is this block big enough?*/
		return pp;			/* yes! NOTE: return prevptr*/
	    if( cp == _aflistptr )		/* end of list?		    */
		if( (cp=getmemory(units)) == NULLFBH ) /* is there more?    */
		{				/*			    */
		    return NULLFBH;		/*	no more memory...   */
		}				/*			    */
	    pp = cp;				/*			    */
	    cp = cp->ptr;			/* move on down the list    */ 
	}					/*			    */
}						/****************************/

/****************************************************************************/
/* cutup - a local fn to cut up the free block (if its much bigger than the */
/*	number of units requested), and to convert blk ptr to char ptr.     */
/*************************************************			    */
    static char *				/*			    */
cutup(pp,units)					/* cut the block to fit	    */
register FB_HDR *pp;				/* ptr to ptr to block	    */
register long units;				/* num units to cut to	    */
{						/****************************/
    register	FB_HDR *cp;			/* cur ptr		    */
    register	FB_HDR *np;			/* new ptr (if needed)	    */
						/*			    */
	cp = pp->ptr;				/* get ptr to big block	    */
	if( cp->size <= units+AFUDGE )		/* is size close enough?    */
	    pp->ptr = cp->ptr;			/*   yes: cut cp from list  */
	else {					/* o.w. cut block up	    */
	    np = cp + units;			/* where it starts	    */
	    np->size = cp->size - units;	/* how big it is	    */
	    np->ptr = cp->ptr;			/* it's linked into freelist*/
	    pp->ptr = np;			/* from both sides	    */
	    cp->size = units;			/* new size for cur block   */
	}					/****************************/
	_aflistptr = pp;			/* search from here next tim*/
	return (char *)(cp+1);			/* point to after header    */
}						/****************************/


/****************************************************************************/
/* getmemory - gets memory from O.S. 					    */
/* This function requests memory from the O.S. in multiples (ACHUNKS)	    */
/*	of the requested number of units (numu), in order to minimize	    */
/*	the number of calls to the O.S.					    */
/*	Function cleans up pointer alignment and adds to free list.	    */
/*************************************************			    */
	static FB_HDR *
getmemory(numu)
register long numu;			          /* number of units */
{
	char *lsbrk();				  /* obtain memory from O.S. */
	register char *mmp;			      /* more memory pointer */
	register FB_HDR *fbp;			       /* free block pointer */
	register long utg;				     /* units to get */

	utg = ((numu+(ACHUNKS-1)) / ACHUNKS) * ACHUNKS;

	mmp = lsbrk(utg * sizeof(FB_HDR));     /* sbrk wants number of chars */

	if( mmp == (char *)-1 )       /* sbrk = -1 means no memory available */
		return( NULLFBH );
	mmp = AMASK(mmp + AOFFS);    /* alignment handling: nop if good sbrk */
	fbp = (FB_HDR *)mmp;
	fbp->size = utg;
	lfree( (char *)(fbp+1) );                        /* add to free list */
	return(_aflistptr);				    /* set in 'free' */
}


/****************************************************************************/
/* lfree - adds memory back to free block list.
* This function assumes freed memory pointer (fmp) points to free space
*	preceeded by a FB_HDR structure.
*	Note that free block is inserted in memory address order,
*	to facilitate compaction.
*	Fails (-1 return) if you link in a random ptr.
*************************************************			    */
int	lfree(fmp)				/* CLEAR FUNCTION ***********/
register char *fmp;				/* freed memory ptr	    */
{						/****************************/
	register FB_HDR *cp,			/* current freeblk ptr	    */
		   *pp;				/* previous freeblk ptr	    */
						/****************************/
	cp = (FB_HDR *)fmp - 1;			/* ptr to (hdr of) freed blk*/
	for( pp=_aflistptr; ; pp=pp->ptr )	/* start through the list   */
	{					/*			    */
	    if( cp >= pp  &&  cp < pp->ptr )	/* are we at correct place? */
		break;				/*	yes...		    */
	    if( pp >= pp->ptr  &&  		/* at end of list? and	    */
		(cp <= pp->ptr  ||  cp >= pp) )	/*   blk is off either end? */
		break;		 		/*	yes...		    */
	}					/****************************/
	if( cp>=pp  &&  cp+cp->size <= pp+pp->size )/* block already freed? */
	{					/*			    */
		_aflistptr = pp;		/* search from here next    */
		return 0;			/* and do no more	    */
	}					/****************************/
/*************************************************			    */
/* Insert freed block back into list.  Try to coalesce (merge) adjacent	    */
/*	registerions.							    */
/*************************************************			    */
	if( cp+cp->size == pp->ptr )		/* end freed blk==start nxt?*/
	{					/*	then merge with nxt */
		cp->size += pp->ptr->size;	/*			    */
		cp->ptr = pp->ptr->ptr;		/*			    */
	} else					/*****			    */
		cp->ptr = pp->ptr;		/* else just point to nxt   */
						/****************************/
	if( pp+pp->size == cp )			/* end prev plk==start cur? */
	{					/*	then merge with prev*/
		pp->size += cp->size;		/*			    */
		pp->ptr = cp->ptr;		/*			    */
	} else					/*****			    */
		pp->ptr = cp;			/* else point prev to cur   */
						/****************************/
	_aflistptr = pp;			/* search from here next time*/
	return 0;				/* say its ok		    */
}						/****************************/


/****************************************************************************/
/* lrealloc - free memory, allocate again (with changed size maybe),	    */
/*		preserve contents.					    */
/*************************************************			    */
char *	lrealloc(ptr,siz)			/* CLEAR FUNCTION ***********/
register	char *ptr;			/* ptr to (prev malloc'd)mem*/
register	long siz;			/* size of mem		    */
{						/****************************/
register	char *np;			/* ptr to new allocation    */
register	long nmults;			/* multiples if FB_HDR size */
	FB_HDR *pp, *findblock();		/* find free block	    */
	char *cutup();				/* cut free block to fit    */
						/*			    */
	lfree(ptr);	/* stuff back into free list: any coalesce will not */
			/* affect original data registerion 		    */

	nmults = (siz+sizeof(FB_HDR)-1)/sizeof(FB_HDR)+1; /*		    */
	if( (pp=findblock(nmults)) == NULLFBH )	/* find ptr to ptr to block */
		return NULL;			/*	no luck...	    */
	np = (char *)((pp->ptr)+1);		/* convert to char ptr	    */
	if( ptr != np ) {			/* if ptr changed	    */
		if( np < ptr )			/* if new ptr in lower mem  */
		    for( ; siz; siz-- )		/* copy up		    */
			*np++ = *ptr++;		/*			    */
		else				/* if new ptr in higher mem */
		    for( np+=siz, ptr+=siz; siz; siz-- ) /* copy down	    */
			*--np = *--ptr;		/*			    */
	}					/****************************/
	return cutup(pp,nmults);		/* cut block to fit & return*/
}						/****************************/


/***************************/
/* lsbrk which takes a LONG increment, calls gemstart's brk() function */
/***************************/

char *lsbrk(incr)
register long incr;
{
    extern char *_break;
    char *oldbreak = _break;

    if (incr & 1) incr++;
    if (brk(_break+incr) != 0) return -1;
    return oldbreak;
}

/***********************************/

char *	lzalloc(nbytes)				/* CLEAR FUNCTION ***********/
	long nbytes;		/* number of bytes */
{
register char *rp;		/* pointer to region */

	if( (rp = lmalloc(nbytes)) == NULL) return(NULL);
	lblkfill( rp, 0, nbytes );
	return(rp);
}

char *	lcalloc(nelem,sizelem)			/* CLEAR FUNCTION ***********/
	long nelem,		/* number of elements */
	     sizelem;		/* size of element */
{
	register long size;

	size = sizelem*nelem;
	return lzalloc(size);
}

lblkfill(ptr,byte,len)
register char *ptr;
register char byte;
register long len;
{
    while (len--) *ptr++ = byte;
}

