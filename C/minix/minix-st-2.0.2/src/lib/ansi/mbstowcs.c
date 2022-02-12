/*
 * (c) copyright 1987 by the Vrije Universiteit, Amsterdam, The Netherlands.
 * See the copyright notice in the ACK home directory, in the file "Copyright".
 */
/* $Header: mbstowcs.c,v 1.2 89/12/18 15:12:59 eck Exp $ */

#include	<stdlib.h>

size_t
mbstowcs(register wchar_t *pwcs, register const char *s, size_t n)
{
	register int i = n;

	while (--i >= 0) {
		if (!(*pwcs++ = *s++))
			return n - i - 1;
	}
	return n - i;
}

