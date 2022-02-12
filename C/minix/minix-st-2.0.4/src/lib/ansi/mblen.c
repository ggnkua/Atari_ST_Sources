/*
 * (c) copyright 1987 by the Vrije Universiteit, Amsterdam, The Netherlands.
 * See the copyright notice in the ACK home directory, in the file "Copyright".
 */
/* $Header: mblen.c,v 1.2 89/12/18 15:12:50 eck Exp $ */

#include	<stdlib.h>
#include	<limits.h>

#define	CHAR_SHIFT	8

int
mblen(const char *s, size_t n)
{
	if (s == (const char *)NULL) return 0;	/* no state dependent codings */
	if (n <= 0) return 0;
	return (*s != 0);
}
