/**
 *  Copyright 1984
 *  Alcyon Corporation
 *  8716 Production Ave.
 *  San Diego, Ca.  92121
 *
 *  @(#)v7getchd.c	2.1	7/10/84
 *  Modified by bv from getchd.c
**/
/*
	I/O independent mapping routine.  Machine specific.  Independent
	of structure padding.  Buffer must contain at least as many
	characters as is required for structure.
 */


#include <stdio.h>
#include "cout.h"

/*
 * getchd - fills the c.out header structure from the buffer in
 *		the manner which will be understood on the current machine.
 */
int
getchd(fp,arptr)		/* returns 0 for success, -1 for failure */
FILE *fp;
struct hdr2 *arptr;
{
	if (lgetw(&arptr->ch_magic,fp) == -1)
		return(-1);
	if (lgetl(&arptr->ch_tsize,fp) == -1)
		return(-1);
	if (lgetl(&arptr->ch_dsize,fp) == -1)
		return(-1);
	if (lgetl(&arptr->ch_bsize,fp) == -1)
		return(-1);
	if (lgetl(&arptr->ch_ssize,fp) == -1)
		return(-1);
	if (lgetl(&arptr->ch_stksize,fp) == -1)
		return(-1);
	if (lgetl(&arptr->ch_entry,fp) == -1)
		return(-1);
	if (lgetw(&arptr->ch_rlbflg,fp) == -1)
		return(-1);
	if (arptr->ch_magic == EX_ABMAGIC) {
		if (lgetl(&arptr->ch_dstart,fp) == -1)
			return(-1);
		if (lgetl(&arptr->ch_bstart,fp) == -1)
			return(-1);
	}
	return(0);
}
