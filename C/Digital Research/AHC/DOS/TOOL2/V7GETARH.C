/*
	Copyright 1983
	Alcyon Corporation
	8716 Production Ave.
	San Diego, CA  92121

	@(#)getarhd.c	2.1	7/10/84
	modified for cpm by bv
*/

/*
	I/O independent mapping routine.  Machine specific.  Independent
	of structure padding.  Buffer must contain at least as many
	characters as is required for structure.
 */


/** mra-- put in code for our VAX */

#include <stdio.h>
#include "ar68.h"

/*
 * getarhd - fills the archive header structure from the buffer int
 *		the manner which will be understood on the current machine.
 */
int
getarhd(fp,arptr)				/* returns -1 for failure, 0 for success */
register FILE *fp;
struct libhdr *arptr;
{
	register int i,j;
	char *lp;

	for (i = 0, lp = arptr->lfname; i < LIBNSIZE; i++)
		if ((lp[i]=getc(fp)) == -1 )

			return(-1);
#ifdef DRI
	if (*lp == '\0')
		return( -1 );
#endif
	if ((lgetl(&(arptr->lmodti),fp)) == -1)
		return(-1);
	if ((lp[(i++)+4] = getc(fp)) == -1 )
		return(-1);
	if ((lp[(i++)+4] = getc(fp)) == -1 )
		return(-1);
	if ((lgetw(&(arptr->lfimode),fp)) == -1)
		return(-1);
	if ((lgetl(&(arptr->lfsize),fp)) == -1)
		return(-1);
#ifdef DRI
	if ((lgetw(&(arptr->ljunk),fp)) == -1)
		return(-1);
#endif
	return(0);
}
