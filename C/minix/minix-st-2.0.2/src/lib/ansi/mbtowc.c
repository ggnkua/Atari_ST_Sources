/*
 * (c) copyright 1987 by the Vrije Universiteit, Amsterdam, The Netherlands.
 * See the copyright notice in the ACK home directory, in the file "Copyright".
 */
/* $Header: mbtowc.c,v 1.3 90/03/28 16:36:45 eck Exp $ */

#include	<stdlib.h>
#include	<limits.h>

int
mbtowc(wchar_t *pwc, register const char *s, size_t n)
{
	if (s == (const char *)NULL) return 0;
	if (n <= 0) return 0;
	if (pwc) *pwc = *s;
	return (*s != 0);
}
