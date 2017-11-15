/* Copyright (c) 1990 by Sozobon, Limited.  Authors: Johann Ruegg, Don Dugger
 *
 * Permission is granted to anyone to use this software for any purpose
 * on any computer system, and to redistribute it freely, with the
 * following restrictions:
 * 1) No charge may be made other than reasonable charges for reproduction.
 * 2) Modified versions must be clearly marked as such.
 * 3) The authors are not responsible for any harmful consequences
 *    of using this software, even if they result from defects in it.
 *
 *	help.c
 */

#include <setjmp.h>
#include "adb.h"

#define IN_HELP
#include "lang.h"

char **helplist[] = {
	help3,
	help2,
	help1,
	0
};

help()
{
	char ***p;
	char **q;
	int i;

	w_help(0);
	for (p=helplist; *p; ) {
		q = *p++;
		helpscr(q, *p != 0);
		if (*p) {
			i = gemdos(7) & 0xff;
			if (i == 'q' || i == 'Q')
				break;
		}
	}
	w_help(1);
}

helpscr(p, more)
char **p;
{
	int nlines = 0;

	for (nlines = 0; nlines < 24; nlines++) {
		if (*p)
			helpline(*p++, nlines, 40);
		else
			helpline("", nlines, 40);
	}
/*	helpline(more ? "   q - quit  <space> - more" : "", nlines, 39); */
	helpline(more ? M1 : "", nlines, 39);
}

helpline(p, line, n)
char *p;
{
	int i;

	w_hline(line);
	for (i=0; i<n; i++)
		if (*p)
			w_hchr(*p++);
		else
			w_hchr(' ');
}
