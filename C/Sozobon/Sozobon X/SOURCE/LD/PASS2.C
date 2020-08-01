
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

#ifndef UNIXHOST
#define SWAPW(a,b)
#define SWAPL(a,b)
#else
#define SWAPW(a,b)	swapw(a,b)
#define SWAPL(a,b)	swapl(a,b)
#endif
extern struct oinfo *ohead;
long textsize, datasize, bsssize, comsize;
extern int mflag, symout, only8, vflag;
extern char *oname;
extern int tb, db, trelb, drelb;

#define LBUFSZ	1000
#define LBUFCNT	(LBUFSZ/2)
short *lbuf, *rbuf;

int ofd;

pass2()
{
	long mkcomm();
	struct oinfo *op;

	if (ohead == 0)
		fatal("no objects included");

	chk_undefs();
	calc_sizes();
	sec_offs();
	if (mflag)
		see_map();

	adjsyms();
	comsize = mkcomm(textsize+datasize+bsssize);
	endsyms();

	ofd = open(oname, 1);
	if (ofd < 0)
		ofd = creat(oname, 0700);
	if (ofd < 0)
		fatals("Cant create", oname);

	wrhdr();

	rewinds();
	relstart();
	mkbufs();
	for (op = ohead; op; op = op->next) {
		flink(op, 0);
	}
	for (op = ohead; op; op = op->next) {
		flink(op, 1);
	}
	if (symout)
		wrsyms(ofd);
	relend();
}

mkbufs()
{
	char *mmalloc();

	rbuf = (short *)mmalloc(LBUFSZ+4);
	lbuf = (short *)mmalloc(LBUFSZ+4);
}

#ifndef MINIX

char fill[HDRFILL];

wrhdr()
{
	short magic;
	struct hdr_l h;
	long countsyms();

	magic = OMAGIC;
	SWAPW(&magic, 1);
	wwrite(ofd, &magic, 2);
	h.tsize = textsize;
	h.dsize = datasize;
	h.bsize = bsssize+comsize;
	if (symout) {
		h.syms = countsyms();
	} else
		h.syms = 0;
	SWAPL(&h, sizeof(h)/4);
	wwrite(ofd, &h, sizeof(h));
	wwrite(ofd, fill, HDRFILL);
}

#else

struct mhdr {
	long magic, magic2;
	long tsize, dsize, bsize;
	long fill;
	long totsize;
	long syms;
} mh;

#define MMAGIC	0x4100301L
#define MMAGIC2	0x20
#define MINSTK	4096

extern long mstack;

wrhdr()
{
	long countsyms();

	mh.magic = MMAGIC;
	mh.magic2 = MMAGIC2;
	mh.tsize = textsize;
	mh.dsize = datasize;
	mh.bsize = bsssize+comsize;
	if (symout)
		mh.syms = countsyms();
	else
		mh.syms = 0;
	if (mstack <= 0)
		mstack = 0x10000L - (mh.dsize+mh.bsize);
	if (mstack < MINSTK)
		mstack = MINSTK;
	mh.totsize = mstack + mh.tsize+mh.dsize+mh.bsize;
	SWAPL(&mh, sizeof(mh)/4);
	wwrite(ofd, &mh, sizeof(mh));
}

#endif

rewinds()
{
	t_rewind(tb);
	t_rewind(db);
	t_rewind(trelb);
	t_rewind(drelb);
}

endsyms()
{
	end_sym("_etext", textsize, (F_TEXT|F_GLBL|F_DEF));
	end_sym("_edata", textsize+datasize, (F_DATA|F_GLBL|F_DEF));
	end_sym("_end", textsize+datasize+bsssize+comsize,
			(F_BSS|F_GLBL|F_DEF));
}

calc_sizes()
{
	struct oinfo *op;

	op = ohead;
	while (op) {
		op->tbase = textsize;
		op->dbase = datasize;
		op->bbase = bsssize;

		textsize += op->oh.tsize;
		datasize += op->oh.dsize;
		bsssize += op->oh.bsize;

		op = op->next;
	}
}

sec_offs()
{
	struct oinfo *op;

	op = ohead;
	while (op) {
		op->dbase += textsize;
		op->bbase += textsize+datasize;

		op = op->next;
	}
}

see_map()
{
	struct oinfo *op;

	op = ohead;

	while (op) {
		printf("%s", op->finfo->name);
		if (op->aname[0])
			printf("(%.14s)", op->aname);
		printf(":\t");
		if (op->oh.tsize)
			printf("T %lx @%lx  ", op->oh.tsize,
				op->tbase);
		if (op->oh.dsize)
			printf("D %lx @%lx  ", op->oh.dsize,
				op->dbase);
		if (op->oh.bsize)
			printf("B %lx @%lx  ", op->oh.bsize,
				op->bbase);
		putchar('\n');

		op = op->next;
	}
}

flink(op, dat)
struct oinfo *op;
{
	long n;
	int i, stuff, relf;
	char *sec;

	n = dat ? op->oh.dsize : op->oh.tsize;
	if (n == 0)
		return;

	if (dat) {
		stuff = db;
		relf = drelb;
		sec = "data";
	} else {
		stuff = tb;
		relf = trelb;
		sec = "text";
	}

	if (vflag) {
		printf("load %s from %s", sec, op->finfo->name);
		if (op->aname[0])
			printf("(%.14s)", op->aname);
		putchar('\n');
	}

	while (n > 0) {
		if (n > LBUFSZ)
			i = LBUFSZ;
		else
			i = n;
		t_read(relf, rbuf, i);
		SWAPW(rbuf, i/2);
		if (i < n && rbuf[LBUFCNT-1] == 5) {
			t_read(relf, &rbuf[LBUFCNT], 2);
			SWAPW(&rbuf[LBUFCNT], 1);
			i += 2;
		}
		t_read(stuff, lbuf, i);

		link(op, i, lbuf, rbuf);

		wwrite(ofd, lbuf, i);
		relout(i, rbuf);

		n -= i;
	}
}

link(op, size, textp, relp)
struct oinfo *op;
short *textp, *relp;
{
	int num, i;
	long v, findx();
	short x, bufs;
#ifdef UNIXHOST
	long lv;
#endif

	num = size/2;

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
				v = findx(x, op->sp, op->havex, relp);
			} else
			switch (x) {
			case 0:
				goto skip;
				break;
			case 1:
				v = op->dbase;
				break;
			case 2:
				v = op->tbase;
				break;
			case 3:
				v = op->bbase;
				break;
			default:
				fatal("Bad relocation value");
			}

#ifndef UNIXHOST
			*(long *)textp += v;
#else
			lv = crossl(textp);
			lv += v;
			pcrossl(lv, textp);
#endif
skip:
			textp += 2;
			relp++;
			i++;
			break;
		default:
			fatal("bad relocation value");
		}
	}
}
