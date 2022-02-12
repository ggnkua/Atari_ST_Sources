/*
  (c) copyright 1988 by the Vrije Universiteit, Amsterdam, The Netherlands.
  See the copyright notice in the ACK home directory, in the file "Copyright".
*/

/* $Header: ngf4.c,v 1.7 93/01/05 12:05:57 ceriel Exp $ */

/*
		NEGATE A FLOATING POINT (NGF 4)
*/
/********************************************************/

#include "FP_types.h"
#include "get_put.h"

#define OFF ((FL_MSW_AT_LOW_ADDRESS ? 0 : 2) + (FL_MSB_AT_LOW_ADDRESS ? 0 : 1))
void
ngf4(f)
SINGLE	f;
{
	unsigned char *p;

	if (f != (SINGLE) 0) {
		p = (unsigned char *) &f + OFF;
		*p ^= 0x80;
	}
}
