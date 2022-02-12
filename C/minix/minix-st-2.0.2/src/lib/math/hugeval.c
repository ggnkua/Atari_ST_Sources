/*
 * (c) copyright 1990 by the Vrije Universiteit, Amsterdam, The Netherlands.
 * See the copyright notice in the ACK home directory, in the file "Copyright".
 *
 * Author: Hans van Eck
 */
/* $Header: hugeval.c,v 1.1 90/10/24 14:29:42 eck Exp $ */
#include	<math.h>

double
__huge_val(void)
{
	return 1.0e+1000;	/* This will generate a warning */
}
