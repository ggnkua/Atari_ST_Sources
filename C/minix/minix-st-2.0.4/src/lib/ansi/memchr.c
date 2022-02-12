/*
 * (c) copyright 1987 by the Vrije Universiteit, Amsterdam, The Netherlands.
 * See the copyright notice in the ACK home directory, in the file "Copyright".
 */
/* $Header: memchr.c,v 1.3 90/08/28 13:52:11 eck Exp $ */

#include	<string.h>

void *
memchr(const void *s, register int c, register size_t n)
{
	register const unsigned char *s1 = s;

	c = (unsigned char) c;
	if (n) {
		n++;
		while (--n > 0) {
			if (*s1++ != c) continue;
			return (void *) --s1;
		}
	}
	return NULL;
}
