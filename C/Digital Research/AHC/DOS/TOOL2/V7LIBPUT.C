
/**
 *  Copyright 1984
 *  Alcyon Corporation
 *  8716 Production Ave.
 *  San Diego, Ca.  92121
 *
 *  @(#)libput.c	2.1	7/10/84
**/
/*
	I/O independent mapping routine.  Machine specific.  Independent
	of structure padding.  Buffer must contain at least as many
	characters as is required for structure.
 */

#include <stdio.h>
#include "order.h"

#define doputc(byte,fp) if(putc(byte,fp) == -1) return(_FAILURE)

lputl(lp,f)			/* returns 0 for success, -1 for failure */
long *lp;			/* 32 bits */
FILE *f;
{
	doputc(lp->b1 & 0x0ff,f);
	doputc(lp->b2 & 0x0ff,f);
	doputc(lp->b3 & 0x0ff,f);
	doputc(lp->b4 & 0x0ff,f);
	return(_SUCCESS);
}

lputw(lp,f)			/* returns 0 for success, -1 for failure */
short *lp;			/* 16 bits */
FILE *f;
{
	doputc(lp->wb1 & 0x0ff,f);
	doputc(lp->wb2 & 0x0ff,f);
	return(_SUCCESS);
}
