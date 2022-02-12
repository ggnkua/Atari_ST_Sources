/*
 * (c) copyright 1987 by the Vrije Universiteit, Amsterdam, The Netherlands.
 * See the copyright notice in the ACK home directory, in the file "Copyright".
 */
/* $Header: stb.c,v 1.1 89/02/07 11:01:46 ceriel Exp $ */
/* library routine for copying structs */

#include <ansi.h>

_PROTOTYPE(int __stb, (int n, char *f, char *t ));
__stb(n, f, t)
register int n;
register char *f, *t;
{
	if (n > 0)
		do
			*t++ = *f++;
		while (--n);
}
