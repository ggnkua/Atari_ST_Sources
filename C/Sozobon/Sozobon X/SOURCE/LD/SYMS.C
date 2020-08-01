
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

#include <stdio.h>
#include "syms.h"
#include "structs.h"

char *mlmalloc(), *mmalloc();
extern int only8;

#ifdef NHASH
/* NHASH must be a power of 2 */
struct sinfo *ushead[NHASH];
struct sinfo *dshead[NHASH];
int hashv;
#define USHEAD	ushead[hashv]
#define DSHEAD	dshead[hashv]
#else
struct sinfo *ushead, *dshead;
#define USHEAD	ushead
#define DSHEAD	dshead
#endif

extern int vflag;

getsyms(fd, size, spp)
long size;
struct symchunk **spp;
{
	struct symchunk *chp;
	long n;
	int k;

	n = size / SYMSIZE;
	if (n == 0) {
		*spp = 0;
		return;
	}

	do {
		if (n > CHUNKMAX)
			k = CHUNKMAX;
		else
			k = n;

		chp = (struct symchunk *)mmalloc(sizeof(struct symchunk) +
				((k-1)*sizeof(struct sym)));
		rread(fd, &chp->s[0], k * SYMSIZE);
#ifdef UNIXHOST
		symhacki(&chp->s[0], k);
#endif
		commhack(&chp->s[0], k);
		chp->nsyms = k;
		*spp = chp;
		spp = &chp->next;
		n -= k;
	} while (n);

	chp->next = 0;
}

commhack(sp, n)
struct sym *sp;
{
	int i;

	/* Common def with value of 0 is really an external ref */

	for (i=0; i<n; i++) {
		if (sp->flags == COMMDEF && sp->value == 0)
			sp->flags = EXTREF;
		sp++;
	}
}

symfree(chp)
struct symchunk *chp;
{
	struct symchunk *next;

	while (chp) {
		next = chp->next;
		free(chp);
		chp = next;
	}
}

chkx(chp)
struct symchunk *chp;
{
	struct sym *sp;

	if (only8)
		return 0;
	if (chp == 0)
		return 0;
	sp = &chp->s[0];
	if (sp->flags == XFLAGS && sp->value == XVALUE &&
	    strncmp(sp->name, XNAME, 8) == 0)
		return 1;
	return 0;
}

struct sinfo *
xlookup(head, s, x)
struct sinfo *head;
char *s, *x;
{
	while (head) {
		if (smatch(head->name, s, x))
			return head;
		head = head->next;
	}
	return 0;
}

smatch(old, s, x)
char *old, *s, *x;
{
	int ol;

	ol = strlen(old);
	if (ol < 8)
		return strcmp(old, s) == 0;
	if (strncmp(old, s, 8) != 0)
		return 0;
	if (strcmp(&old[8], x) == 0)
		return 1;
	else if (x[0] == '*')
		return 1;
	else if (old[8] == '*')
		return 2;
	return 0;
}

struct sinfo *
newsinfo(s, xp)
char *s, *xp;
{
	int slen, xlen;
	struct sinfo *sp;

	slen = strnlen(s, 8);
	if (slen == 8 && xp)
		xlen = strlen(xp);
	else
		xlen = 0;
	sp = (struct sinfo *)mmalloc(slen+xlen+sizeof(struct sinfo));
	bcopy(s, sp->name, slen);
	sp->name[slen] = 0;
	if (xlen)
		strcpy(&sp->name[8], xp);

	sp->flags = sp->mark = 0;
	sp->value = 0;
	sp->obj = 0;
	return sp;
}

sundeff(s)
char *s;
{
	hashv = hash(s);
	if (strlen(s) > 8)
		undeff(s, &s[8], 0L);
	else
		undeff(s, 0L, 0L);
}

undeff(s, xp, op)	/* hashv set by caller */
char *s;
char *xp;
struct oinfo *op;
{
	struct sinfo *sp;

	sp = newsinfo(s, xp);
	sp->flags = EXTREF;
	sp->obj = op;
	listins(&USHEAD, sp);

	if (vflag > 1)
		printf("und %s\n", sp->name);
}

char *
exten(chp, sp)
struct symchunk *chp;
struct sym *sp;
{
	static int maxlen = 0;
	static char *cp = 0;
	int k, i, n, slen;
	struct symchunk *nchp;
	struct sym *nsp;

	if (maxlen == 0) {
		maxlen = 100;
		cp = mmalloc(maxlen);
	}

again:
	k = chp->nsyms;
	i = sp - &chp->s[0];
	slen = 0;
	cp[slen] = 0;
	nchp = chp;  nsp = sp;

	while (slen+9 < maxlen) {
		i++;
		if (i < k) {
			nsp++;
		} else if (nchp->next == NULL) {
			return cp;
		} else {
			nchp = nchp->next;
			k = nchp->nsyms;
			i = 0;
			nsp = &nchp->s[0];
		}

		if (nsp->flags != XFLAGS || nsp->value != XVALUE) {
			return cp;
		}
		n = strnlen(nsp->name, 8);
		bcopy(nsp->name, &cp[slen], n);
		slen += n;
		cp[slen] = 0;

		if (n != 8) {
			return cp;
		}
	}

	/* buffer is too small */
	free(cp);
	maxlen += 100;
	cp = mmalloc(maxlen);
	goto again;
}

needed(chp, havex)
struct symchunk *chp;
{
	unsigned i;
	int k;

	while (chp) {
		k = chp->nsyms;
		for (i=0; i<k; i++)
			if (need1(&chp->s[i], chp, havex))
				return 1;
		chp = chp->next;
	}
	return 0;
}

char *
getext(chp, sp, havex)
struct symchunk *chp;
struct sym *sp;
{
	char *extp;

	if (havex)
		extp = exten(chp, sp);
	else if (only8)
		extp = "";
	else
		extp = "*";
	return extp;
}

need1(sp, chp, havex)
struct sym *sp;
struct symchunk *chp;
{
	char *extp;
	struct sinfo *sip;

#ifdef NHASH
	hashv = hash(sp->name);
#endif

	if (notglob(sp->flags))
		return 0;
	if (sp->flags == EXTREF || sp->flags == COMMDEF)
		return 0;
	if (sp->name[7])
		extp = getext(chp, sp, havex);
	else
		extp = 0;

	if ((sip = xlookup(USHEAD, sp->name, extp))) {
		if (vflag > 1)
			printf("Needed %s\n", sip->name);
		return 1;
	}
	return 0;
}

p1syms(chp, havex, op)
struct symchunk *chp;
struct oinfo *op;
{
	unsigned i;
	int k;

	while (chp) {
		k = chp->nsyms;
		for (i=0; i<k; i++)
			ap1sym(&chp->s[i], chp, havex, op);
		chp = chp->next;
	}
	return 0;
}

ap1sym(sp, chp, havex, op)
struct sym *sp;
struct symchunk *chp;
struct oinfo *op;
{
	char *extp;
	struct sinfo *sip;

	if (notglob(sp->flags))
		return;
	if (sp->name[7])
		extp = getext(chp, sp, havex);
	else
		extp = 0;
#ifdef NHASH
	hashv = hash(sp->name);
#endif
	if (sp->flags == EXTREF) {
		if (xlookup(USHEAD, sp->name, extp))
			return;
		else if (xlookup(DSHEAD, sp->name, extp))
			;
		else
			undeff(sp->name, extp, op);
	} else {
		sip = xlookup(USHEAD, sp->name, extp);
		if (sip) {
			listdel(&USHEAD, sip);
			sip->flags = sp->flags;
			sip->value = sp->value;
			sip->obj = op;
			listins(&DSHEAD, sip);

			if (vflag > 1)
				printf("u->d %s\n", sip->name);
		} else {
			sip = xlookup(DSHEAD, sp->name, extp);
			if (sip)
				def2chk(sip, sp);
			else
				newdef(sp, extp, op);
		}
	}
	return 0;
}

def2chk(sip, sp)
struct sinfo *sip;
struct sym *sp;
{
	if (sip->flags == COMMDEF && sp->flags == COMMDEF) {
		if (sip->value != sp->value) {
			warns("common sizes differ for", sip->name);
			if (sp->value > sip->value)
				sip->value = sp->value;
		}
	} else
		fatals("double definition of", sip->name);
}

newdef(sp, extp, op)	/* hashv set by caller */
struct sym *sp;
char *extp;
struct oinfo *op;
{
	struct sinfo *sip;

	sip = newsinfo(sp->name, extp);
	sip->flags = sp->flags;
	sip->value = sp->value;
	sip->obj = op;
	listins(&DSHEAD, sip);

	if (vflag > 1)
		printf("def %s\n", sip->name);
}

notglob(flags)
{
	if (flags & F_GLBL)
		return 0;
	if (flags == EXTREF)
		return 0;
	return 1;
}

special(s)
char *s;
{
	if (strcmp(s, "_end") == 0)
		return 1;
	if (strcmp(s, "_etext") == 0)
		return 1;
	if (strcmp(s, "_edata") == 0)
		return 1;
	return 0;
}

end_sym(s, val, flag)
char *s;
long val;
{
	struct sinfo *sip;

#ifdef NHASH
	hashv = hash(s);
#endif

	sip = xlookup(USHEAD, s, 0L);
	if (sip) {
		listdel(&USHEAD, sip);
		sip->flags = flag;
		sip->value = val;
		sip->obj = 0;
		listins(&DSHEAD, sip);
	}
}

chk_undefs()
{
	struct sinfo *sp;
	int any = 0;

#ifdef NHASH
	for (hashv=0; hashv < NHASH; hashv++)
#endif
	{
	    sp = USHEAD;
	    while (sp) {
		if (!special(sp->name)) {
			any = 1;
			printf("undefined symbol %s", sp->name);
			if (sp->obj) {
				printf(" from %s", sp->obj->finfo->name);
				if (sp->obj->aname[0])
					printf("(%.14s)", sp->obj->aname);
			}
			putchar('\n');
		}
		sp = sp->next;
	    }
	}
	if (any)
		fatal("load aborted due to undefined symbols");
}

long
mkcomm(where)
long where;
{
	struct sinfo *sp;
	long size, base, obase;

	base = obase = where;
#ifdef NHASH
	for (hashv=0; hashv < NHASH; hashv++)
#endif
	{
	    sp = DSHEAD;
	    while (sp) {
		if (sp->flags == COMMDEF) {
			size = sp->value;
			sp->value = base;
			sp->flags = (F_BSS|F_GLBL|F_DEF);
			base += size;
		}
		sp = sp->next;
	    }
	}
	return base - obase;
}

adjsyms()
{
	struct sinfo *sp;

#ifdef NHASH
	for (hashv=0; hashv < NHASH; hashv++)
#endif
	{
	    sp = DSHEAD;
	    while (sp) {
		switch (sp->flags & 7) {
		case F_TEXT:
			sp->value += sp->obj->tbase;
			break;
		case F_DATA:
			sp->value += sp->obj->dbase;
			break;
		case F_BSS:
			sp->value += sp->obj->bbase;
			break;
		}
		sp = sp->next;
	    }
	}
}

long
countsyms()
{
	long n;
	struct sinfo *sp;

	if (only8)
		n = 0;
	else
		n = 1;

#ifdef NHASH
	for (hashv=0; hashv < NHASH; hashv++)
#endif
	{
	    sp = DSHEAD;
	    while (sp) {
		n += count1(sp);
		sp = sp->next;
	    }
	}
	return n * SYMSIZE;
}

count1(sp)
struct sinfo *sp;
{
	int n;

	if (only8)
		return 1;
	n = strlen(sp->name);
	if (n == 9 && sp->name[8] == '*')
		n = 8;
	if (n == 0)
		fatal("zero length name");
	return (n+7)/8;
}

char zname[8];
#ifndef UNIXHOST
#define FIXSYM(a)
#else
#define FIXSYM(a)	fixsym(a)
#endif

wrsyms(fd)
{
	struct sinfo *sp;
	struct sym s;

	if (!only8) {
		bcopy(zname, s.name, 8);
		strncpy(s.name, XNAME, 8);
		s.flags = XFLAGS;
		s.mark = 0;
		s.value = XVALUE;
		FIXSYM(&s);
		write(fd, &s, SYMSIZE);
	}

#ifdef NHASH
	for (hashv=0; hashv < NHASH; hashv++)
#endif
	{
	    sp = DSHEAD;
	    while (sp) {
		bcopy(zname, s.name, 8);
		strncpy(s.name, sp->name, 8);
		s.flags = sp->flags;
		s.mark = 0;
		s.value = sp->value;
		FIXSYM(&s);
		write(fd, &s, SYMSIZE);

		if (!only8) {
			int n, i;

			n = strlen(sp->name);
			if (n == 9 && sp->name[8] == '*')
				n = 8;
			i = 8;
			while (n > i) {
				bcopy(zname, s.name, 8);
				strncpy(s.name, &sp->name[i], 8);
				s.flags = XFLAGS;
				s.mark = 0;
				s.value = XVALUE;
				i += 8;

				FIXSYM(&s);
				write(fd, &s, SYMSIZE);
			}
		}

		sp = sp->next;
	    }
	}
}

struct sym *
chunki(x, chpp)
unsigned x;
struct symchunk **chpp;
{
	unsigned k, i;
	struct sym *sp;
	struct symchunk *chp;

	chp = *chpp;
	i = 0;
	while (chp) {
		k = chp->nsyms;
		if (x < i+k) {
			sp = &chp->s[x-i];
			*chpp = chp;
			return sp;
		}
		i += k;
		chp = chp->next;
	}
	fatal("bad relocation index");
}

long
findx(x, chp, havex, relp)
unsigned short x;
struct symchunk *chp;
short *relp;
{
	struct sinfo *sip;
	struct sym *sp;
	char *extp;

	x >>= 3;
	sp = chunki(x, &chp);
#ifdef NHASH
	hashv = hash(sp->name);
#endif
	if (sp->mark == 0) {
		if (sp->name[7])
			extp = getext(chp, sp, havex);
		else
			extp = 0;
		sip = xlookup(DSHEAD, sp->name, extp);
		if (sip == 0)
			fatal("Cant find symbol");
		switch (sip->flags & 7) {
		case 1:
			sp->mark = 3; break;
		case 2:
			sp->mark = 2; break;
		case 4:
			sp->mark = 1; break;
		default:
			fatal("Bad sym type");
		}
		sp->value = sip->value;
	}
	*relp = sp->mark;
	return sp->value;
}

#ifdef NHASH

/* only use 1st 8 chars for hash value! */

hash(s)
unsigned char *s;
{
	unsigned char c;
	register i, n = 0;

	for (i=1; i<5; i++) {
		c = s[i];
		if (!c)
			break;
		n = (n<<1)|c;
	}
	return n & (NHASH-1);
}
#endif
