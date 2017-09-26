/*
	Copyright 1983
	Alcyon Corporation
	8716 Production Ave.
	San Diego, CA  92121

	@(#)putarhd.c	2.1	7/10/84
*/


/*
	I/O independent mapping routine.  Machine specific.  Independent
	of structure padding.  Buffer must contain at least as many
	characters as is required for structure.
 */

#include <stdio.h>
#include "ar68.h"

/*
 * putarhd - fills the buffer from the archive header structure in
 *		the byte orientation of the target machine (68000).
 */
int
putarhd(fp,arptr)		/* returns 0 for success, -1 for error */
register FILE *fp;
struct libhdr *arptr;
{
	register int i;
	register char *p, *lp;

	for (i=0, lp = arptr->lfname; i<LIBNSIZE; i++, lp++)
		if (putc(*lp,fp) == -1)
			return(-1);
	if (lputl(&arptr->lmodti,fp) == -1)
		return(-1);
	if (putc(arptr->luserid,fp) == -1)
		return(-1);
	if (putc(arptr->lgid,fp) == -1)
		return(-1);
	if (lputw(&arptr->lfimode,fp) == -1)
		return(-1);
	if (lputl(&arptr->lfsize,fp) == -1)
		return(-1);
#ifdef DRI
	if (lputw(&arptr->ljunk,fp) == -1)
		return(-1);
#endif
	return(0);
}
