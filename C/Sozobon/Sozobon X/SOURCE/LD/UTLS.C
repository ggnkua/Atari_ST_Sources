
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

extern int vflag;
#define FBSIZE	1000

fbcopy(fr, to, cnt)
long cnt;
{
	char buf[FBSIZE];
	int k;

	while (cnt > 0) {
		if (cnt > FBSIZE)
			k = FBSIZE;
		else
			k = cnt;
		rread(fr, buf, k);
		t_write(to, buf, k);
		cnt -= k;
	}
}

bfcopy(fr, to, cnt)
long cnt;
{
	char buf[FBSIZE];
	int k;

	while (cnt > 0) {
		if (cnt > FBSIZE)
			k = FBSIZE;
		else
			k = cnt;
		t_read(fr, buf, k);
		wwrite(to, buf, k);
		cnt -= k;
	}
}

char *
mmalloc(size)
{
	char *rv, *malloc();

again:
	rv = malloc(size);
	if (rv == 0) {
		if (t_frees())
			goto again;
		fatal("out of memory");
	}
	if (vflag > 2)
		printf("M %x rets %lx ", size, rv);
	return rv;
}

char *
mlmalloc(size)
long size;
{
	char *rv, *malloc();

	if (size > 65000L)
		fatal("malloc chunk too big");
again:
	rv = malloc((unsigned)size);
	if (rv == 0) {
		if (t_frees())
			goto again;
		fatal("out of memory");
	}
	if (vflag > 2)
		printf("M %lx rets %lx ", size, rv);
	return rv;
}

rread(fd, buf, cnt)
char *buf;
{
	if (read(fd, buf, cnt) != cnt)
		fatal("read error");
	if (vflag > 2)
		printf("R %d %lx %d ", fd, buf, cnt);
	return cnt;
}

wwrite(fd, buf, cnt)
char *buf;
{
	if (write(fd, buf, cnt) != cnt)
		fatal("write error");
	if (vflag > 2)
		printf("W %d %lx %d ", fd, buf, cnt);
	return cnt;
}

long
llseek(fd, ofs, how)
long ofs;
{
	long rv, lseek();

	rv = lseek(fd, ofs, how);
	if (rv < 0)
		fatal("lseek error");
	if (vflag > 2)
		printf("S %d %lx %d ", fd, ofs, how);
	return rv;
}

#ifdef UNIXHOST
#define lread read
#else
long lread();
#endif

long
rlread(fd, buf, lcnt)
char *buf;
long lcnt;
{
	if (lread(fd, buf, lcnt) != lcnt)
		fatal("read error");
	if (vflag > 2)
		printf("R %d %lx %ld ", fd, buf, lcnt);
	return lcnt;
}

strnlen(s, max)
char *s;
{
	int i;

	for (i=0; i<max; i++)
		if (*s++ == 0)
			return i;
	return max;
}

struct generic {
	struct generic *next;
};

listins(hpp, np)
struct generic **hpp, *np;
{
	np->next = *hpp;
	*hpp = np;
}

listadd(hpp, np)
struct generic **hpp, *np;
{
	struct generic *tp;

	np->next = 0;

	if (*hpp == 0) {
		*hpp = np;
	} else {
		tp = *hpp;
		while (tp->next)
			tp = tp->next;
		tp->next = np;
	}
}

listdel(hpp, np)
struct generic **hpp, *np;
{
	struct generic *tp;

	if (*hpp == np) {
		*hpp = np->next;
		np->next = 0;
	} else {
		tp = *hpp;
		while (tp->next) {
			if (tp->next == np) {
				tp->next = np->next;
				np->next = 0;
				return;
			}
			tp = tp->next;
		}
		fatal("listdel error");
	}
}
