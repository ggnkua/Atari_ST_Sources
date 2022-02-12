/*
 * (c) copyright 1987 by the Vrije Universiteit, Amsterdam, The Netherlands.
 * See the copyright notice in the ACK home directory, in the file "Copyright".
 */
/* $Header: atoi.c,v 1.4 90/05/22 12:22:25 ceriel Exp $ */

#include	<ctype.h>
#include	<stdlib.h>

int
atoi(register const char *nptr)
{
	return strtol(nptr, (char **) NULL, 10);
}
