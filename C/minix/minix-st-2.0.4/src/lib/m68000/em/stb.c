/*
 * (c) copyright 1987 by the Vrije Universiteit, Amsterdam, The Netherlands.
 * See the copyright notice in the ACK home directory, in the file "Copyright".
 */
/* $Header: /fs/cvs/MinixCVS/src/lib/m68000/em/stb.c,v 1.1 2013/11/16 21:50:19 volker Exp $ */
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
