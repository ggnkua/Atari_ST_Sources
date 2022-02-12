/*
 * (c) copyright 1987 by the Vrije Universiteit, Amsterdam, The Netherlands.
 * See the copyright notice in the ACK home directory, in the file "Copyright".
 */
/* $Header: strchr.c,v 1.3 90/08/28 13:53:00 eck Exp $ */

#include	<string.h>

char *
strchr(register const char *s, register int c)
{
	c = (char) c;

	while (c != *s) {
		if (*s++ == '\0') return NULL;
	}
	return (char *)s;
}
