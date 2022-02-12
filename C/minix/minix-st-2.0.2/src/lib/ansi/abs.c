/*
 * (c) copyright 1987 by the Vrije Universiteit, Amsterdam, The Netherlands.
 * See the copyright notice in the ACK home directory, in the file "Copyright".
 */
/* $Header: abs.c,v 1.1 89/05/16 13:06:59 eck Exp $ */

#include	<stdlib.h>

int
abs(register int i)
{
	return i >= 0 ? i : -i;
}
