/*
 * Rlist.c -  Handling rectangle lists for the Window Manager
 *
 * Jun 19 1991	ml.	Created this.
 * Feb 16, 1993 cgee	Converted to Lattice C 5.51
 * Feb 23, 1993 cgee	Force the use of prototypes
 * Jun 01, 1993 cgee	Modified genrlist() to work with WF_TOOLBAR requests
 *
 */
#include "pgem.h"
#include "pmisc.h"

#include "machine.h"
#include "dispvars.h"
#include "windlib.h"
#include "mintbind.h"

/*	-----------------------------------------------------------
*	AES Version 4.0	MultiTOS version is written by Derek M. Mui
*	Copyright (C) 1992 
*	Atari (U.S.) Corp
*	All Rights Reserved
*	-----------------------------------------------------------
*/	

EXTERN	MEMHDR	*rmhead, *rmtail;   /* rect lists memory linked list */

/*
 * newrect() - allocate a RLIST structure for a new rectangle
 *	     - return a pointer to an available RLIST structure 
 *	       or return NULLPTR if none is available.
 *
 */
	RLIST
*newrect( VOID )
{
    REG RLIST	*rp;	/* pointer to RLIST structure */
    MEMHDR  	*mp;	/* pointer to memory header */
    REG WORD	i;	/* counter */

    for (mp = rmhead; mp && mp->numused == NUMRECT; mp = mp->mnext)
	;
	
    if (!mp) 
    {
	if ((mp = (MEMHDR *)
		dos_xalloc((LONG)(NUMRECT*sizeof(RLIST)+sizeof(MEMHDR)),3 )) 
	    == ( MEMHDR *)NULLPTR) 
	{
	    Debug1( "NO MEMORY for rlist!\r\n" );
	    return( ( RLIST *)NULLPTR);
	} 
	else 
	{
	    /* init RLIST structures as available */

	    for (rp = (RLIST *)(mp+1), i = 0; i < NUMRECT; i++, rp++) 
	    {
		rp->rstatus.rused = FALSE;
		rp->rwhere = mp;
	    }

	    rmtail->mnext = mp;
	    mp->mnext = ( MEMHDR *)NULLPTR;
	    rmtail = mp;
	    rmtail->numused = 1;
	    rp = (RLIST *)(rmtail+1);
	}
    }
    else 
    {
	for (rp = (RLIST *)(mp+1); rp->rstatus.rused == TRUE; rp++)
	    ;

	mp->numused += 1;
    }

    rp->rstatus.rused = TRUE;
    rp->rnext = ( RLIST *)NULLPTR;
    return(rp);
}



/*
 * delrect() - if a pointer to a rectangle is given, delete 
 *		that rectangle from the rectangle list.
 *		(rlist would be of type RLIST *).
 *	     - if no pointer to a particular rectangle is 
 *		given, delete the entire rectangle list.
 *		(rlist would be of type RLIST **).
 *
 */
VOID
delrect(rp, rlist)
RLIST	*rp;	    /* ptr to rectangle to be deleted */
char	*rlist;	    /* ptr (or address of ptr) to head of rect. list */
{
    REG	MEMHDR  *prvmp, *curmp, *nxtmp;	/* memory blocks pointers */
    REG	RLIST	*currp;			/* ptr into current rectangle */
    RLIST	**rl1;			/* addr of ptr to rect. list head */

    if (rp) {		    /* delete one rectangle */
	/*
	 * If rectangle to be deleted is head of list, update head
	 * of list.  If it is not the head of list, just unlink it
	 * from the list.
	 */
	rl1 = (RLIST **)rlist;
	if (rp == *rl1)
	    *rl1 = rp->rnext;
	else {
	    for (currp = *rl1; currp->rnext != rp; currp = currp->rnext)
		;
	    currp->rnext = rp->rnext;
	}
	currp = rp;
    } else {			    /* delete entire rectangle list */
	currp = (RLIST *)rlist;	    /* so start at beginning of list */
    }


    /* mark the RLIST structure(s) as available */
    do {
	currp->rstatus.rused = FALSE;
	(currp->rwhere)->numused -= 1;
	if (rp)			    /* if only delete one rectangle */
	    currp = 0L;		    /* terminate loop		    */
	else
	    currp = currp->rnext;   /* else go to next rectangle    */
    } while (currp);


    /* delete unused memory blocks */

    if (rmhead != rmtail) {
	prvmp = nxtmp = ( MEMHDR *)NULLPTR;
	curmp = rmhead;

	while (curmp != ( MEMHDR *)NULLPTR) {

	    nxtmp = curmp->mnext;

	    if (!curmp->numused) {

		if (prvmp) {
		    prvmp->mnext = nxtmp;
		} else {
		    rmhead = nxtmp;
		}
		dos_free( ( LONG )curmp);

	    } else {
		prvmp = curmp;
	    }

	    curmp = nxtmp;
	}

	if (prvmp != rmtail)
	    rmtail = prvmp;
    }
#if 0
    return TRUE;
#endif

}


#if 0
/*
 * delrect() - if a pointer to a rectangle is given, delete 
 *		that rectangle from the rectangle list.
 *		(rlist would be of type RLIST *).
 *	     - if no pointer to a particular rectangle is 
 *		given, delete the entire rectangle list.
 *		(rlist would be of type RLIST **).
 *
 */
	VOID
delrect(rp, rlist)
	RLIST	*rp;	    /* ptr to rectangle to be deleted */
	char	*rlist;	    /* ptr (or address of ptr) to head of rect. list */
{
	REG	MEMHDR  *mp, *mp1;	/* ptrs to rectangle list memory header */
	REG	RLIST	*currp;		/* ptr into current rectangle */
	RLIST	**rl1;		/* addr of ptr to rect. list head */

    if (rp) {		    /* delete one rectangle */
	/*
	 * If rectangle to be deleted is head of list, update head
	 * of list.  If it is not the head of list, just unlink it
	 * from the list.
	 */
	rl1 = (RLIST **)rlist;
	if (rp == *rl1)
	    *rl1 = rp->rnext;
	else {
	    for (currp = *rl1; currp->rnext != rp; currp = currp->rnext)
		;
	    currp->rnext = rp->rnext;
	}
	currp = rp;
    } else {			    /* delete entire rectangle list */
	currp = (RLIST *)rlist;	    /* so start at beginning of list */
    }


    /* mark the RLIST structure(s) as available */
    do {
	currp->rstatus.rused = FALSE;
	(currp->rwhere)->numused -= 1;
	if (rp)			    /* if only delete one rectangle */
	    currp = 0L;		    /* terminate loop		    */
	else
	    currp = currp->rnext;   /* else go to next rectangle    */
    } while (currp);


    /* delete empty memory blocks except for head of list */
    if (rmhead != rmtail) {
	for (mp = rmhead; mp != NULLPTR; mp = mp->mnext) {
	    if ((mp1 = mp->mnext) != NULLPTR) {
		if (!mp1->numused) {	    /* if memory block is empty */
		    mp->mnext = mp1->mnext; /* unlink it from list */
		    dos_free(mp1);		    /* and free the memory */

		    if (rmtail == mp1)	    /* if tail of list is freed */
			rmtail = mp;	    /* update tail of list */
		}
	    }	
	}
    }

    return TRUE;
}
#endif


/*
 * Genrlist() - generate (non-optimized) rectangle list for given window.
 *	      - return pointer to rectangle list if successful.
 *	      - return NULLPTR if an error occurred.
 */
	RLIST
*genrlist(handle, area)
	UWORD	handle;	    /* window handle */
	WORD	area;	    /* WF_WORKXYWH: generate rectangle list of work area */
		    /* WF_CURRXYWH: generate rectangle list of whole window */
		    /* WF_TOOLBAR: generate rectangle list for TOOLBAR area */
{
    WINDOW	*wp;	    /* ptr to current window structure */
    GRECT	wrect;	    /* rectangle of current window */
    RLIST	*rlist;	    /* ptr to beginning of rectangle list */
    RLIST	*rnextrp;   /* ptr to next rectangle in rectangle list */
    REG RLIST   *currp;	    /* ptr to current rectangle in rectangle list */
    UWORD	hv_piece;   /* flag for new rectangles found */

    /*
     * if cannot locate window in database, or no RLIST 
     * structure is available, return with an error. 
     */
    if ((wp = srchwp(handle)) == ( WINDOW *)NULLPTR || 
	(rlist = newrect()) == ( RLIST *)NULLPTR)
	return(  ( RLIST *)NULLPTR );

    /* initialize rectangle list */
    if( area == WF_TOOLBAR ) {	/* cjg 06/01/93 */
	WORD x, y;
#if 0
	  ob_actxywh( ( LONG )wp->ad_tools, ROOT, &rlist->rect );
#else
	  ob_gclip( ( LONG )wp->ad_tools, ROOT, &x, &y, 
		&rlist->rect.g_x, &rlist->rect.g_y, 
		&rlist->rect.g_w, &rlist->rect.g_h );
#endif
     } else {
    
      if (area == WF_WORKXYWH)
	  rlist->rect = *(GRECT *)&(wp->obj[W_WORK].ob_x);
      else { /* if (area == WF_CURRXYWH) */
	  rlist->rect = wp->curr;
	  rlist->rect.g_w += SHADOW;    /* add thickness for drop shadow */
	  rlist->rect.g_h += SHADOW;    /* add thickness for drop shadow */
      }
    }

    /* process all windows that are on top of the given window */
    while ((handle = wp->ontop) != NIL && rlist) {
	wp = srchwp(handle);	/* find next window to be processed */
	wrect = wp->curr;	/* find its current rectangle */
	wrect.g_w += SHADOW;	/* add thickness for drop shadow */
	wrect.g_h += SHADOW;

	rnextrp = rlist;	/* start from beginning of rect list */
	while ((currp = rnextrp) != ( RLIST *)NULLPTR) {
	    rnextrp = currp->rnext;
	    if (brkrect(&wrect, &(currp->rect), &hv_piece)) {
		chgrlist(hv_piece, &wrect, currp, &rlist);
	    }
	}
    }

    /* optimize the rectangle list */
    for (currp = rlist; 
	currp != ( RLIST *)NULLPTR; 
	currp = currp->rnext) {

	rnextrp = currp->rnext;
	while (rnextrp) {
	    if (mrgrect(currp, rnextrp)) {  /* try to merge 2 rects */
		delrect(rnextrp, ( BYTE *)&rlist);
		rnextrp = currp->rnext;
	    } else {
		rnextrp = rnextrp->rnext;   /* progress to the next rect */
	    }
	}
    }

    return rlist;
}
 


/*
 * Brkrect() - check if the top rect breaks the bottom rect
 *	     - return TRUE if the top rect breaks the bottom
 *	       rect and set up mask to reveal how the bottom
 *	       rect is broken down
 *	     - return FALSE if the top rect does not break 
 *	       the bottom rect
 */
	WORD
brkrect(trect, brect, hv_pc)
	GRECT	*trect, *brect;	    /* ptrs to top and bottom rectangles */
	UWORD	*hv_pc;
{
    /* check if the top rect breaks the bottom rect */
    if ((trect->g_x < brect->g_x + brect->g_w) &&
	(trect->g_x + trect->g_w > brect->g_x) &&
	(trect->g_y < brect->g_y + brect->g_h) &&
	(trect->g_y + trect->g_h > brect->g_y)) {

	*hv_pc = 0;	/* assume brect is entirely covered */

	/* brect may be broken down into smaller pieces */
	if (trect->g_y > brect->g_y)
	    *hv_pc |= TOP;
	if (trect->g_x > brect->g_x)
	    *hv_pc |= LEFT;
	if (trect->g_x + trect->g_w < brect->g_x + brect->g_w)
	    *hv_pc |= RIGHT;
	if (trect->g_y + trect->g_h < brect->g_y + brect->g_h)
	    *hv_pc |= BOTTOM; 

	return TRUE;
    }
    return FALSE;
}



/*
 * Chgrlist() - change the rectangle list according to the 
 *		given mask by replacing the given rectangle
 *		with the rectangles specified by the mask
 *		and the cutting rectangle
 *	      - return TRUE if everything is fine or
 *		return FALSE if there is an error
 */
	WORD
chgrlist(hv_pc, cutrect, oldrp, rlist)
	UWORD	hv_pc;		/* mask */
	GRECT	*cutrect;	/* ptr to the cutting rectangle */
	RLIST	*oldrp;		/* ptr to rectangle to be replaced */
	RLIST	**rlist;	/* addr of ptr to beginning of rectangle list */
{
    GRECT   *old;	/* ptr to old rectangle */
    RLIST   *xrlist;	/* ptr to the rectangle list expansion */
    RLIST   *nrp;	/* ptr to new rectangle generated */
    RLIST   *currp;	/* ptr to current rectangle in expansion */
    UWORD   pc;		/* counter */

    /*
     * If given rectangle is entirely covered, just delete it 
     * from the rectangle list, and free the RLIST structure.
     */

    if (hv_pc) {
	/*
	 * Given rectangle is being broken into smaller pieces.
	 * Replace the given rectangle with a list of rectangles
	 * to represent the smaller pieces.
	 */

	old = (GRECT *)&(oldrp->rect);
	currp = xrlist = ( RLIST *)NULLPTR;

	/* generate a rectangle for each piece */
	for (pc = TOP; pc <= BOTTOM; pc <<= 1) {
	    if (hv_pc & pc) {
		if ((nrp = mkrect(pc, cutrect, old)) == ( RLIST *)NULLPTR)
		    return FALSE;

		if (xrlist)
		    currp->rnext = nrp;
		else
		    xrlist = nrp;

		currp = nrp;
	    }
	}

	/* add extension to rectangle list */
	currp->rnext = oldrp->rnext;
	oldrp->rnext = xrlist;
    }
    delrect(oldrp, ( BYTE *)rlist);
    return TRUE;
}



/*
 * Mkrect() - make a rectangle out of the exposed area of the
 *	      bottom window specified by the flag
 *	    - return pointer to RLIST structure that contains
 *	      the rectangle
 *	    - return NULLPTR if no RLIST structure is available
 */
	RLIST
*mkrect(pc, trect, brect)
	UWORD	    pc;		/* flag */
	REG GRECT   *trect;	/* ptr to rectangle of window on top */
	REG GRECT   *brect;	/* ptr to rectangle of window at the bottom */
{
    RLIST	*rp;	/* ptr to RLIST strucuture of new rectangle */
    REG GRECT	*nrect;	/* ptr to new rectangle */

    if ((rp = newrect()) == ( RLIST *)NULLPTR)
	return( ( RLIST *)NULLPTR );

    nrect = (GRECT *)&(rp->rect);

    /* do common calculations */
    nrect->g_x = brect->g_x;
    nrect->g_y = max(brect->g_y, trect->g_y);
    nrect->g_w = brect->g_w;
    nrect->g_h = min(brect->g_y + brect->g_h, trect->g_y + trect->g_h)
		    - nrect->g_y;

    switch(pc) {
	case TOP:
	    nrect->g_y = brect->g_y;
	    nrect->g_h = trect->g_y - brect->g_y;
	    break;

	case LEFT:
	    nrect->g_w = trect->g_x - brect->g_x;
	    break;

	case RIGHT:
	    nrect->g_x = trect->g_x + trect->g_w;
	    nrect->g_w = (brect->g_x+brect->g_w) - (trect->g_x+trect->g_w);
	    break;

	case BOTTOM:
	    nrect->g_y = trect->g_y + trect->g_h;
	    nrect->g_h = (brect->g_y+brect->g_h) - (trect->g_y+trect->g_h);
	    break;
    }
    return rp;
}



/*
 * Mrgrect() - merge the 2 rectangles vertically if possible, and 
 *		save the result in the first rectangle
 *	     - return TRUE if there is a merge
 *	     - return FALSE if there is no merge
 */
	WORD
mrgrect(rp1, rp2)
	RLIST	*rp1, *rp2;	/* ptrs to the 2 rectangles */
{
	GRECT   *gr1, *gr2;

    gr1 = (GRECT *)&(rp1->rect);
    gr2 = (GRECT *)&(rp2->rect);

    if (gr1->g_x == gr2->g_x && gr1->g_w == gr2->g_w &&
	gr1->g_y + gr1->g_h == gr2->g_y) {
	
	gr1->g_h += gr2->g_h;		/* rect1 = rect1 merge rect2 */
	return TRUE;
    }

    return FALSE;
}
