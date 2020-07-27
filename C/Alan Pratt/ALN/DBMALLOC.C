/*
******************* Revision Control System *****************************
*
* $Author: apratt $
* =======================================================================
*
* $Date: 88/08/23 14:20:21 $
* =======================================================================
*
* $Locker:  $
* =======================================================================
*
* $Log:	dbmalloc.c,v $
* Revision 1.1  88/08/23  14:20:21  apratt
* Initial revision
* 
* =======================================================================
*
* $Revision: 1.1 $
* =======================================================================
*
* $Source: /u/apratt/work/aln/RCS/dbmalloc.c,v $
* =======================================================================
*
*************************************************************************
*/
/*
 * debugging malloc:
 * Don't do anything if aln.h doesn't redefine malloc.
 * Otherwise, display the args and return value from calls to
 * malloc, realloc, calloc, and free.
 */

#include "aln.h"

#ifdef malloc

#undef malloc
#undef calloc
#undef realloc
#undef free

#ifdef ATARIST
extern char *lmalloc(), *lcalloc(), *lrealloc();
#else
extern char *malloc(), *calloc(), *realloc();
#endif ATARIST

extern int twoflag, fourflag;

char *mymalloc(amt)
register long amt;
{
    register char *temp;
#ifdef ATARIST
    temp = lmalloc(amt);
#else
    temp = malloc(amt);
#endif ATARIST

    if (twoflag) printf("Malloc(%lx) => %lx\n",amt,temp);

    return temp;
}

char *mycalloc(size,count)
register long size,count;
{
    register char *temp;
#ifdef ATARIST
    temp = lcalloc(size,count);
#else
    temp = calloc(size,count);
#endif ATARIST

    if (twoflag) printf("Calloc(%lx,%lx) => %lx\n",size,count,temp);

    return temp;
}

char *myrealloc(ptr,size)
register char *ptr;
register long size;
{
    register char *temp;

#ifdef ATARIST
    temp = lrealloc(ptr,size);
#else
    temp = realloc(ptr,size);
#endif ATARIST

    if (twoflag) printf("REalloc(%lx,%lx) => %lx\n",ptr,size,temp);

    return temp;
}

myfree(ptr)
register char *ptr;
{
    register int temp;
    if (twoflag) printf("Free(%lx) => ",ptr);

    if (fourflag) temp = 0;
    else {
#ifdef ATARIST
	temp = lfree(ptr);
#else
	temp = free(ptr);
#endif ATARIST
    }

    return temp;
}

#endif malloc
