
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

#include "syms.h"

/*
 * fix alignment and byte order problems in cross environment
 */

long
crossl(cp)
char *cp;
{
	union {
		long l;
		char c[4];
	} u;

#ifdef LITTLE_ENDIAN
	u.c[0] = cp[3];
	u.c[1] = cp[2];
	u.c[2] = cp[1];
	u.c[3] = cp[0];
#else
	u.c[0] = cp[0];
	u.c[1] = cp[1];
	u.c[2] = cp[2];
	u.c[3] = cp[3];
#endif
	return u.l;
}

pcrossl(l, cp)
long l;
char *cp;
{
	union {
		long l;
		char c[4];
	} u;

	u.l = l;
#ifdef LITTLE_ENDIAN
	cp[0] = u.c[3];
	cp[1] = u.c[2];
	cp[2] = u.c[1];
	cp[3] = u.c[0];
#else
	cp[0] = u.c[0];
	cp[1] = u.c[1];
	cp[2] = u.c[2];
	cp[3] = u.c[3];
#endif
}

swapw(cp, n)
char *cp;
{
#ifdef LITTLE_ENDIAN
	char t;

	while (n--) {
		t = cp[1];
		cp[1] = cp[0];
		cp[0] = t;
		cp += 2;
	}
#endif
}

swapl(cp, n)
char *cp;
{
#ifdef LITTLE_ENDIAN
	char t;

	while (n--) {
		t = cp[3];
		cp[3] = cp[0];
		cp[0] = t;

		t = cp[2];
		cp[2] = cp[1];
		cp[1] = t;
		cp += 4;
	}
#endif
}

symhacki(sp, n)
char *sp;
{
	struct fsym *fp;
	struct sym *tp;

	fp = (struct fsym *)sp + (n-1);
	tp = (struct sym *)sp + (n-1);

	while (n--) {
		tp->value = crossl(fp->value);
		if (n == 0)
			return;
		tp->mark = fp->mark;
		tp->flags = fp->flags;
		rbcopy(fp->name, tp->name, 8);

		fp--;
		tp--;
	}
}

fixsym(sp)
struct sym *sp;
{
	struct fsym *fp;

	fp = (struct fsym *)sp;
	fp->flags = sp->flags;
	fp->mark = 0;
	pcrossl(sp->value, fp->value);
}

rbcopy(fr, to, n)
char *fr, *to;
{
	fr += (n-1);
	to += (n-1);
	while (n--)
		*to-- = *fr--;
}

bcopy(fr,to, n)
char *fr, *to;
{
	while (n--)
		*to++ = *fr++;
}
