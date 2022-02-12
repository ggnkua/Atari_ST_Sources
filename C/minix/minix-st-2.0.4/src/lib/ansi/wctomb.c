/*
 * (c) copyright 1987 by the Vrije Universiteit, Amsterdam, The Netherlands.
 * See the copyright notice in the ACK home directory, in the file "Copyright".
 */
/* $Header: wctomb.c,v 1.4 91/01/15 11:55:33 ceriel Exp $ */

#include	<stdlib.h>
#include	<limits.h>

int
/* was: wctomb(char *s, wchar_t wchar) 
 * This conflicts with prototype, so it was changed to:
 */
wctomb(char *s, wchar_t wchar)
{
	if (!s) return 0;		/* no state dependent codings */

	*s = wchar;
	return 1;
}
