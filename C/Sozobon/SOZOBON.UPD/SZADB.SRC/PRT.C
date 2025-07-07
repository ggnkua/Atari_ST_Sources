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
 *	prt.c
 */

#include "adb.h"

prtf(fmt, ap)
char *fmt;
int ap;
{
	extern char *ccodes[], *sizes[];
	register long *lp, l;
	register int *p, opc;
	register char c, **cp;

	p = &ap;
	while (c = *fmt++)
		switch (c) {
		case '%':
			switch (c = *fmt++) {
			case 'i':
				l = (long)*p++;
				if (l < 0) {
					l = -l;
					putchr('-');
				}
				prtn(l, 0);
				break;
			case 'I':
				lp = (long *)p;
				if ((l = *lp++) < 0) {
					l = -l;
					putchr('-');
				}
				prtn(l, 0);
				p = (int *)lp;
				break;
			case 'A':
				lp = (long *)p;
				l = *lp++;
				prtad(l);
				p = (int *)lp;
				break;
			case 'd':
				putchr('d');
				putchr('0' + *p++);
				break;
			case 'a':
				if ((opc = *p++) == 7)
					prt("sp");
				else {
					putchr('a');
					putchr('0' + opc);
				}
				break;
			case 'c':
				putchr(*p++);
				break;
			case 's':
				cp = (char **)p;
				prt(*cp++);
				p = (int *)cp;
				break;
			}
			break;
		default:
			putchr(c);
			break;

		}
	return;
}
