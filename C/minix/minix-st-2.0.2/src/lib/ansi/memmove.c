/*
 * (c) copyright 1987 by the Vrije Universiteit, Amsterdam, The Netherlands.
 * See the copyright notice in the ACK home directory, in the file "Copyright".
 */
/* $Header: memmove.c,v 1.3 90/08/28 13:52:42 eck Exp $ */

#include	<string.h>

void *
memmove(void *s1, const void *s2, register size_t n)
{
	register char *p1 = s1;
	register const char *p2 = s2;

	if (n>0) {
		if (p2 <= p1 && p2 + n > p1) {
			/* overlap, copy backwards */
			p1 += n;
			p2 += n;
			n++;
			while (--n > 0) {
				*--p1 = *--p2;
			}
		} else {
			n++;
			while (--n > 0) {
				*p1++ = *p2++;
			}
		}
	}
	return s1;
}
