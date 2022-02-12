/*
  (c) copyright 1988 by the Vrije Universiteit, Amsterdam, The Netherlands.
  See the copyright notice in the ACK home directory, in the file "Copyright".
*/

/* $Header: zrf4.c,v 1.5 93/01/05 12:06:46 ceriel Exp $ */

/*
	return a zero float (ZRF 4)
*/

#include "FP_types.h"

void
zrf4(l)
SINGLE	*l;
{
	*l = 0L;
}
