/* Copyright (c) 1990,91 by Sozobon, Limited.  Authors: Johann Ruegg, Don Dugger
 *
 * Permission is granted to anyone to use this software for any purpose
 * on any computer system, and to redistribute it freely, with the
 * following restrictions:
 * 1) No charge may be made other than reasonable charges for reproduction.
 * 2) Modified versions must be clearly marked as such.
 * 3) The authors are not responsible for any harmful consequences
 *    of using this software, even if they result from defects in it.
 *
 *	adb1.c
 */

#include <setjmp.h>
#include "adb.h"

#define IN_ADB1
#include "lang.h"

extern struct file binary;

extern long dot;
extern int dotoff;
extern long maxoff;
extern int ibase;

extern int lastc;
extern char sign;

extern jmp_buf jmpb;


getfmt(fmt)
char *fmt;
{
	char c;

	while ((*fmt = getchr()) != '\n')
		fmt++;
	*fmt = '\0';
	pushc('\n');
	return;
}

long getdot(d, n)
long d;
int n;
{
	long l;

	l = dot;
	if (n == 2)
		l &= 0xffff;
	else if (n == 1)
		l &= 0xff;
	return(l);
}

unsigned char
getb(fp)
struct file *fp;
{
	long getn();

	return(getn(dot + dotoff, 1));
}

unsigned int
getwd()
{
	long getn();

	return(getn(dot + dotoff, 2));
}

putn(v, d, n)
long v, d;
int n;
{
	union {
		int i;
		long l;
	} no, val;
	long b;
	register int o;
	char *p, *s;

	b = d >> LOGBS;
	o = d & (BSIZE - 1);
	switch (n) {

	case 2:
		p = (char *)(&no.i);
		val.i = v;
		s = (char *)(&val.i);
		break;
	case 4:
		p = (char *)(&no.l);
		val.l = v;
		s = (char *)(&val.l);
		break;

	}
	rdsub(d, p, n, 0);
	dotoff += n;
	switch (n) {

	case 2:
		bcopy(s, p, n);
		break;
	case 4:
		bcopy(s, p, n);
		break;

	}
	wrsub(p, d, n, 0);
	return;
}

long
getn(d, n)
unsigned long d;
int n;
{
	unsigned long b, no;
	register unsigned int o;
	char *p;

	b = d >> LOGBS;
	o = d & (BSIZE - 1);
	rdsub(d, &b, n, 0);
	p = (char *)&b;
	dotoff += n;
	switch (n) {

	case 1:
		no = *p;
		break;
	case 2:
		no = *(int *)p;
		break;
	case 4:
		no = *(long *)p;
		break;

	}
	return(no);
}

puto(n, s)
unsigned long n;
int s;
{

	if (n > 0)
		puto((n >> 3) & 0x1fffffff, --s);
	else
		while (s-- > 0)
			putchr(' ');
	putchr((char)((n & 7) + '0'));
	return;
}

putd(n, s)
long n;
int s;
{

	if (n < 0) {
		s--;
		n = -n;
		if (n < 0) {
			while (s-- > 0)
				putchr(' ');
			putchr('?');
			return;
		} else
			sign = '-';
	}
	if (n > 9)
		putd(n / 10, --s);
	else
		while (s-- > 0)
			putchr(' ');
	if (sign) {
		putchr(sign);
		sign = 0;
	}
	putchr((char)((n % 10) + '0'));
	return;
}

putx(n, s)
unsigned long n;
int s;
{

	if (n > 0xf)
		putx((n >> 4) & 0xfffffff, --s);
	else {
		while (s-- > 0)
			putchr(' ');
	}
	putchr("0123456789abcdef"[n & 0xf]);
	return;
}

prtn(n, s)
long n;
int s;
{

	switch (ibase) {

	case 8:
		puto(n, s);
		break;
	case 10:
		putd(n, s);
		break;
	default:
	case 16:
		putx(n, s);
		break;

	}
	return;
}

prt(s)
char *s;
{

	while (*s)
		putchr(*s++);
	return;
}

putchr(c)
char c;
{
	putchar(c);
}

relsym()
{
	register struct symbol *sp;
	extern struct basepg *bpage;

	sp = binary.symptr;
	while (sp) {
		sp->value += (long)bpage->p_tbase;
		sp = sp->next;
	}
}

setsym(fd, n)
struct file *fd;
int n;
{
	static struct filsym sym;
	int rv;
	char sname[NAMEMAX+1];
	int slen;

	symstart(n, fd->fid);
	for (;;) {
		rv = sread(&sym);
		if (rv != 1)
			return rv;
		if ((sym.flag & S_EXT) && 
		    (sym.flag & (S_DATA|S_TEXT|S_BSS))) {
			if (sym.name[7]) {
				bcopy(sym.name, sname, 8);
				slen = 8;
				while (slen+8 <= NAMEMAX) {
					rv = sread(&sym);
					if (rv < 0)
						return rv;
					else if (rv == 0)
						break;
					if (sym.flag == S_EXTEND) {
						if (sym.name[7]) {
						    bcopy(sym.name,
							  &sname[slen], 8);
						    slen += 8;
						} else {
						    strcpy(&sname[slen],
							   sym.name);
						    slen += strlen(sym.name);
						}
					} else {
						unsread();
						break;
					}
				}
				sname[slen] = 0;
			} else {
				slen = strlen(sym.name);
				strcpy(sname, sym.name);
			}
			addsym(&binary.symptr, &sym, sname, slen);
		}
	}
	return 0;
}

int sreuse = 0;
int sleft = 0;
int sfd = 0;

symstart(n, fd)
{
	sleft = n;
	sfd = fd;
}

sread(ptr)
char *ptr;
{
	static struct filsym old;

	if (sreuse) {
		sreuse = 0;
		bcopy(&old, ptr, sizeof(old));
		return 1;
	}
	if (sleft == 0)
		return 0;
	if (read(sfd, &old, sizeof(old)) != sizeof(old)) {
		sleft = 0;
		return -1;
	}
	sleft--;
	bcopy(&old, ptr, sizeof(old));
	return 1;
}

unsread()
{
	sreuse = 1;
}

addsym(spp, sym, name, slen)
struct symbol **spp;
struct filsym *sym;
char *name;
{
	char *malloc();
	register long v;
	register int i;
	struct symbol *p;
	register struct symbol *sp;

	v = sym->value;
	sp = *spp;
	while (sp)
		if (sp->value > v)
			break;
		else {
			spp = &sp->next;
			sp = *spp;
		}
	if ((p = (struct symbol *)malloc(sizeof(*p)+slen)) == 0) {
/*		prtf("can't allocate %i bytes for symbol\n", sizeof(*p)); */
		prtf(M1, sizeof(*p));
		return;
	}
	p->next = sp;
	*spp = p;
	p->value = v;
	bcopy(name, p->name, slen+1);
	return;
}

struct symbol *
findnam(cp, sp)
char *cp;
struct symbol *sp;
{
	struct symbol *best;
	int bestlen, newlen;

	best = 0;
	bestlen = 0;
	while (sp) {
		if (strncmp(cp, sp->name, 8) == 0) {
			newlen = matchlen(cp, sp->name);
			if (newlen > bestlen) {
				best = sp;
				bestlen = newlen;
			}
		}
		sp = sp->next;
	}
	return(best);
}

matchlen(p, q)
char *p, *q;
{
	int n = 0;

	while (*p) {
		if (*p++ != *q++)
			return n;
		n++;
	}
	return n;
}

struct symbol *
findsym(v, sp)
unsigned long v;
struct symbol *sp;
{
	struct symbol *lp;
	unsigned long val;

	lp = sp;
	while (sp) {
		val = sp->value;
		if (val > v)
			break;
		else {
			lp = sp;
			sp = sp->next;
		}
	}
	if (lp && v >= lp->value && v < lp->value + maxoff)
		return(lp);
	return(0);
}

htoi(cp)
char *cp;
{
	int n;
	char c;

	n = 0;
	while (type(c = *cp++) & HEXDIG) {
		if (c >= 'a' && c <= 'f')
			c -= 'a' - '9' - 1;
		else if (c >= 'A' && c <= 'F')
			c -= 'A' - '9' - 1;
		n = (n << 4) + (c - '0');
	}
	return(n);
}

prtsym(v, sp)
unsigned long v;
struct symbol *sp;
{

	prt(sp->name);
	if (v != sp->value) {
		putchr('+');
		prtn(v - sp->value, 0);
	}
	return;
}

rdsub(from, to, n, pid)
char *from, *to;
int n, pid;
{
	long l[2];
	register int off;

	off = (int)from & (sizeof(l[0]) - 1);
	from -= off;
	l[0] = ptrace(RD_DATA, pid, from, 0);
	if ((off + n) > sizeof(l[0]))
		l[1] = ptrace(RD_DATA, pid, from + sizeof(l[0]), 0);
	bcopy((char *)l + off, to, n);
	return;
}

wrsub(from, to, n, pid)
char *from, *to;
int n, pid;
{
	long l[2];
	register int off;

	off = (int)to & (sizeof(l[0]) - 1);
	to -= off;
	if (off || n != sizeof(l[0]))
		l[0] = ptrace(RD_DATA, pid, to, 0);
	if ((off + n) > sizeof(l[0]))
		l[1] = ptrace(RD_DATA, pid, to + sizeof(l[0]), 0);
	bcopy(from, (char *)l + off, n);
	ptrace(WR_DATA, pid, to, l[0]);
	if ((off + n) > sizeof(l[0]))
		ptrace(WR_DATA, pid, to + sizeof(l[0]), l[1]);
	return;
}

cmdsreg(c,fmt,get)
int c;
char *fmt;
long (*get)();
{
	char buf[10], *cp, c;
	int i;
	struct regs *rp, *findreg();	

	cp = buf;
	i = 0;
	while (i<5 && (c = getchr()) != '\n') {
		i++;
		*cp++ = c;
	}
	*cp = '\0';
	if (c == '\n')
		pushc('\n');

	if (rp = findreg(buf)) {
		*rp->value = dot;
		return;
	}
	error(BADRNAME);
}
