
/*
 * Copyright (c) 1991 by Sozobon, Limited.  Author: Johann Ruegg
 *
 * Permission is granted to anyone to use this software for any purpose
 * on any computer system, and to redistribute it freely, with the
 * following restrictions:
 * 1) No charge may be made other than reasonable charges for reproduction.
 * 2) Modified versions must be clearly marked as such.
 * 3) The authors are not responsible for any harmful consequences
 *    of using this software, even if they result from defects in it.
 */

#ifndef UNIXHOST
#define SWAPW(a,b)
#define SWAPL(a,b)
#else
#define SWAPW(a,b)	swapw(a,b)
#define SWAPL(a,b)	swapl(a,b)
#endif

extern int ofd;
extern int orelb;

long reloffs;
int relbeg;
long relsz = 0;

relstart()
{
	reloffs = 0;
	relbeg = 1;
}

relout(n, relp)
register short *relp;
{
	short x;
	register int i, cnt;
	long lasti;

	lasti = -reloffs;
	cnt = n / sizeof(short);
	for (i=0; i<cnt; i++) {

		x = *relp++;

		switch (x) {
		case 7:
		case 0:
			break;
		case 5:
			x = *relp;
			switch (x) {
			case 0:
				goto skip;
			case 1:
			case 2:
			case 3:
				seerel(i-lasti);
				lasti = i;
				break;
			default:
				fatal("Bad reloc");
			}
skip:
			relp++;
			i++;
			break;
		default:
			fatal("bad reloc");
		}
	}
	reloffs = i-lasti;
}

seerel(n)
long n;
{
	union {
		long ls;
		char bs[4];
	} lb;
	char c;
	int i;

	if (relbeg) {
		relbeg = 0;
		lb.ls = 2*n;
		SWAPL(&lb.ls, 1);
		for (i=0; i<4; i++)
			rputc(lb.bs[i]);
		return;
	}

	n *= 2;
	while (n > 254) {
		rputc(1);
		n -= 254;
	}
	c = n;
	rputc(c);
}

relend()
{
	rputc(0);

	t_rewind(orelb);
	bfcopy(orelb, ofd, relsz);
}

rputc(c)
char c;
{
	t_write(orelb, &c, 1);
	relsz++;
}
