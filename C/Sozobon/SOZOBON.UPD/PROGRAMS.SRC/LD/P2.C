/* Copyright (c) 1988 by Sozobon, Limited.  Author: Johann Ruegg
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
#include "ld.h"

extern int vflag, symout, bflag;
extern char *oname;

int ifd, ofd;

pass2()
{
	register struct oinfo *op;
	int i;

	ofd = OPENBW(oname);
	if (ofd < 0) {
		fprintf(stderr, "Cant open output %s\n", oname);
		exit(1);
	}

	h.magic = OMAGIC;
	h.tsize = textsize;
	h.dsize = datasize;
	h.bsize = bsssize+comsize;
	if (symout)
		h.syms = nsym * sizeof(struct sym);
	else
		h.syms = 0;
	wwrite(ofd, &h, sizeof(h));

	relstart();
	for (op=obj; op < &obj[nobj]; op++)
		if (bflag)
			blink(op, 0);
		else
			mlink(op, 0);
	for (op=obj; op < &obj[nobj]; op++)
		if (bflag)
			blink(op, 1);
		else
			mlink(op, 1);

	if (symout)
		for (i=0; i<nsym; i++)
			wwrite(ofd, &sym[i].sy, sizeof(struct sym));

	relend();
}

long
findx(x, symp, relp)
struct sym *symp;
short *relp;
{
	register struct sym *sp;
	register struct sinfo *lp, *lookup();

	x >>= 3;
	sp = &symp[x];
	if (sp->mark == 0) {
		lp = lookup(sp->name);
		if (lp == NULL) {
			fprintf(stderr, "Cant find symbol %.8s\n",
				sp->name);
			exit(1);
		}
		switch (lp->sy.flags & 7) {
		case 1:
			sp->mark = 3;	break;
		case 2:
			sp->mark = 2;	break;
		case 4:
			sp->mark = 1;	break;
		default:
			fprintf(stderr, "Bad sym type\n");
			exit(1);
		}
		sp->value = lp->sy.value;
	}
	*relp = sp->mark;
	return sp->value;
}

blink(op, dat)
register struct oinfo *op;
{
	register long n, i;
	register long tdat, rat;

	n = dat ? op->oh.dsize : op->oh.tsize;
	if (n == 0)
		return;

	if (vflag >1) {
		printf("%c-", dat ? 'D' : 'T');
		onm_pr(op-obj, stdout);
		putchar('\n');
	}
		
	ifd = files[op->fno].fd;

	tdat = op->im_td;
	rat = op->im_rel;
	if (dat) {
		tdat += op->oh.tsize;
		rat += op->oh.tsize;
	}

	while (n) {
		i = n;
		if (i > LBUFSZ)
			i = LBUFSZ;
		llseek(ifd, rat, 0);
		rread(ifd, rbuf, (int)i);
		if (i<n && rbuf[LBUFCNT-1] == 5) {
			rread(ifd, &rbuf[LBUFCNT], 2);
			i += 2;
		}
		llseek(ifd, tdat, 0);
		rread(ifd, lbuf, (int)i);

		link(op, i, op->im_sym, lbuf, rbuf);
		wwrite(ofd, lbuf, (int)i);
		relout(i, rbuf);

		tdat += i;
		rat += i;
		n -= i;
	}
}

mlink(op, dat)
register struct oinfo *op;
{
	register long n, i;
	register long tdat, rat;

	n = dat ? op->oh.dsize : op->oh.tsize;
	if (n == 0)
		return;

	if (vflag >1) {
		printf("%c-", dat ? 'D' : 'T');
		onm_pr(op-obj, stdout);
		putchar('\n');
	}

	tdat = op->im_td;
	rat = op->im_rel;
	if (dat) {
		tdat += op->oh.tsize;
		rat += op->oh.tsize;
	}

	link(op, n, op->im_sym, tdat, rat);
	relout(n, rat);
	wlwrite(ofd, tdat, n);

	if (dat) {
		free(op->im_td);
		free(op->im_rel);
	}
}

link(hp, size, symp, textp, relp)
struct oinfo *hp;
struct sym *symp;
long size;
register short *textp;
register short *relp;
{
	long num, i, v;
	short x;
	short bufs;
	long bufl;

	num = size/sizeof(short);

	for (i=0; i<num; i++) {
		x = *relp++;

		switch (x) {
		case 7:
		case 0:
			textp++;
			break;
		case 5:
			x = *relp;
			if ((x & 7) == 4) {
				v = findx(x, symp, relp);
			} else
			switch (x) {
			case 0:
				goto skip;
				break;
			case 1:
				v = hp->dbase;
				break;
			case 2:
				v = hp->tbase;
				break;
			case 3:
				v = hp->bbase;
				break;
			default:
				fprintf(stderr, "Bad reloc\n");
				exit(1);
			}

			*(long *)textp += v;
skip:
			textp += 2;
			relp++;
			i++;
			break;
		default:
			fprintf(stderr, "Bad reloc\n");
			exit(1);
		}
	}
}

long reloffs;
int relbeg;

relstart()
{
	reloffs = 0;
	relbeg = 1;
	rinit();
}

relout(n, relp)
long n;
register short *relp;
{
	short x;
	register long i, cnt;
	long lasti;

	lasti = -reloffs;
	cnt = n/sizeof(short);
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
				break;
			case 1:
			case 2:
			case 3:
				seerel(i-lasti);
				lasti = i;
				break;
			default:
				fprintf(stderr, "Bad reloc\n");
				exit(1);
			}

skip:
			relp++;
			i++;
			break;
		default:
			fprintf(stderr, "?%x? ", x);
			exit(1);
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
	rdump();
}

#define RBSZ	512

struct rbuf {
	struct rbuf *next;
	char buf[RBSZ];
} *rbp, *rblast;
char *rbcur;
int rbleft;

rinit()
{
	char *myalloc();

	rbp = (struct rbuf *)myalloc((long)sizeof(struct rbuf));
	rblast = rbp;
	rbcur = rbp->buf;
	rbleft = RBSZ;
}

rputc(c)
char c;
{
	char *myalloc();
	struct rbuf *new;

	if (rbleft == 0) {
	    new = (struct rbuf *)myalloc((long)sizeof(struct rbuf));
	    rblast->next = new;
	    rblast = new;
	    rbcur = rblast->buf;
	    rbleft = RBSZ;
	}
	*rbcur++ = c;
	rbleft--;
}

rdump()
{
	register struct rbuf *rp;

	for (rp = rbp; rp != rblast; rp = rp->next)
		wwrite(ofd, rp->buf, RBSZ);
	wwrite(ofd, rblast->buf, RBSZ-rbleft);
}

rread(fd, buf, n)
char *buf;
{
	if (read(fd, buf, n) != n) {
		fprintf(stderr, "Read failure\n");
		exit(1);
	}
	return n;
}

wwrite(fd, buf, n)
char *buf;
{
	if (write(fd, buf, n) != n) {
		fprintf(stderr, "Write failure\n");
		exit(1);
	}
	return n;
}

wlwrite(fd, buf, n)
char *buf;
long n;
{
	long lwrite();

	if (lwrite(fd, buf, n) != n) {
		fprintf(stderr, "Write failure\n");
		exit(1);
	}
	return n;
}

llseek(fd, ln, how)
long ln;
{
	long lseek(), rv;

	rv = lseek(fd, ln, how);
	if (rv < 0) {
		fprintf(stderr, "Lseek error\n");
		exit(1);
	}
}
