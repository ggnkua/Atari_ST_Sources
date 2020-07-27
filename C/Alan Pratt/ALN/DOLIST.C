/*
******************* Revision Control System *****************************
*
* $Author: apratt $
* =======================================================================
*
* $Date: 88/08/23 14:20:23 $
* =======================================================================
*
* $Locker:  $
* =======================================================================
*
* $Log:	dolist.c,v $
* Revision 1.1  88/08/23  14:20:23  apratt
* Initial revision
* 
* =======================================================================
*
* $Revision: 1.1 $
* =======================================================================
*
* $Source: /u/apratt/work/aln/RCS/dolist.c,v $
* =======================================================================
*
*************************************************************************
*/
/*
 * dolist.c: symbol-resolution for aln.c
 */

#include "aln.h"

/*
 * dolist():	remove elements from unresolved list which are resolvable
 *		(either a global or a common region)
 */

dolist()
{
    register struct HREC *uptr;
    register struct HREC *prev = NULL;
    register struct HREC *htemp;
    register struct OFILE *ptemp;

    while (plist != NULL) {
	if (doobj(plist->o_name,
		  plist->o_image,
		  plist->o_arname,
		  plist->o_flags)) return TRUE;
	ptemp = plist;
	plist = plist->o_next;
	free(ptemp);
    }

    for (uptr = unresolved; uptr != NULL; ) {
	DEBUG1("lookup(%s) => ",uptr->h_sym);
	if ((htemp = lookup(uptr->h_sym)) != NULL) {
	    DEBUG2(" %s in %s\n",
		   isglobal(htemp->h_type) ? "global" : "common",
		   htemp->h_ofile->o_name);
	    htemp->h_ofile->o_flags |= O_USED;
	    if (prev == NULL) {
		unresolved = uptr->h_next;
		free(uptr);
		uptr = unresolved;
	    }
	    else {
		prev->h_next = uptr->h_next;
		free(uptr);
		uptr = prev->h_next;
	    }
	}
	else {
	    DEBUG0("NULL\n");
	    prev = uptr;
	    uptr = uptr->h_next;
	}
    }
    return FALSE;
}

