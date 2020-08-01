
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
#include <ar.h>
#define SWAPW(a,b)
#define SWAPL(a,b)
#else
#include "crossar.h"
long crossl();
#define SWAPW(a,b)	swapw(a,b)
#define SWAPL(a,b)	swapl(a,b)
#endif

#include "syms.h"
#include "structs.h"

struct finfo *fhead;
struct oinfo *ohead;
struct ainfo *ahead;
char *mmalloc();

extern int tb, db, trelb, drelb;
extern int vflag;

pass1(s)
char *s;
{
	struct finfo *fp;
	int fd;

	fp = (struct finfo *)mmalloc(strlen(s) + sizeof(struct finfo));
	listadd(&fhead, fp);
	strcpy(fp->name, s);

	fd = open(s, 0);
	if (vflag)
		printf("process %s:\n", fp->name);
	process(fd, fp);
	close(fd);
}

process(fd, fp)
struct finfo *fp;
{
	unsigned short magic;

	magic = 0;
	rread(fd, &magic, 2);
	SWAPW(&magic, 1);
	if (magic == OMAGIC)
		doobj(fd, fp);
	else if (magic == AMAGIC)
		doarch(fd, fp);
	else {
		fatals("Bad magic", fp->name);
	}
}

doarch(fd, fp)
struct finfo *fp;
{
	struct ar_hdr a;
	long size, ostart, tell();
	struct ainfo *ap;
	int reuse;

	ostart = 2;
	reuse = 0;
	while (read(fd, &a, sizeof(a)) == sizeof(a) && a.ar_name[0]) {
#ifndef UNIXHOST
		size = a.ar_size;
#else
		size = crossl(a.ar_size);
#endif
		if (vflag > 2)
			printf("\n%.14s size %lx\n", a.ar_name, size);

		if (reuse == 0) {
			ap = (struct ainfo *)mmalloc(sizeof(struct ainfo));
			listadd(&ahead, ap);
		}

		ap->aoffs = ostart + sizeof(a);
		ap->used = 0;
		ap->sp = 0;
		bcopy(a.ar_name, ap->aname, 14);

		reuse = ahdsyms(fd, ap, size);
		ostart += size + sizeof(a);
		llseek(fd, ostart, 0);
	}

	ascan(fd, fp);
	afree();
}

ahdsyms(fd, ap, size)
struct ainfo *ap;
long size;
{
	char skip[HDRFILL];
	short magic;
	long tdlen;

	rread(fd, &magic, 2);
	SWAPW(&magic, 1);
	if (magic != OMAGIC)
		return 1;
	rread(fd, &ap->ah, sizeof(struct hdr_l));
	SWAPL(&ap->ah, sizeof(struct hdr_l)/4);
	rread(fd, skip, HDRFILL);

	tdlen = ap->ah.tsize + ap->ah.dsize;
	llseek(fd, tdlen, 1);
	getsyms(fd, ap->ah.syms, &ap->sp);
	ap->havex = chkx(ap->sp);
	return 0;
}

ascan(fd, fp)
struct finfo *fp;
{
	struct ainfo *ap;
	int some = 0;
	struct oinfo *op;

again:
	for (ap = ahead; ap != 0; ap = ap->next) {
		if (ap->used)
			continue;
		if (needed(ap->sp, ap->havex) == 0)
			continue;
		some = 1;

		op = (struct oinfo *)mmalloc(sizeof(struct oinfo));
		listadd(&ohead, op);

		op->oh = ap->ah;

		if (vflag > 1) {
			printf("%s(%.14s): ", fp->name, ap->aname);
		printf("T %lx D %lx B %lx S %lx\n",
			op->oh.tsize, op->oh.dsize, op->oh.bsize,
			op->oh.syms);
		}

		bcopy(ap->aname, op->aname, 14);
		op->finfo = fp;

		llseek(fd, ap->aoffs+HDRSIZE, 0);
		fbcopy(fd, tb, op->oh.tsize);
		fbcopy(fd, db, op->oh.dsize);
		llseek(fd, op->oh.syms, 1);
		fbcopy(fd, trelb, op->oh.tsize);
		fbcopy(fd, drelb, op->oh.dsize);

		ap->used = 1;
		op->sp = ap->sp;
		op->havex = ap->havex;

		p1syms(op->sp, op->havex, op);
	}

	if (some) {
		some = 0;
		goto again;
	}
}

afree()
{
	struct ainfo *ap, *next;

	for (ap=ahead; ap != 0; ap = next) {
		if (ap->used == 0) {
			if (ap->sp)
				symfree(ap->sp);
		}
		next = ap->next;
		free(ap);
	}
	ahead = 0;
}

doobj(fd, fp)
struct finfo *fp;
{
	struct oinfo *op;
	char skip[HDRFILL];

	op = (struct oinfo *)mmalloc(sizeof(struct oinfo));
	listadd(&ohead, op);

	rread(fd, &op->oh, sizeof(struct hdr_l));
	SWAPL(&op->oh, sizeof(struct hdr_l)/4);
	rread(fd, skip, HDRFILL);
	op->aname[0] = 0;
	op->finfo = fp;

	if (vflag > 1) {
		printf("%s: ", fp->name);
		printf("T %lx D %lx B %lx S %lx\n",
			op->oh.tsize, op->oh.dsize, op->oh.bsize,
			op->oh.syms);
	}

	fbcopy(fd, tb, op->oh.tsize);
	fbcopy(fd, db, op->oh.dsize);
	getsyms(fd, op->oh.syms, &op->sp);
	fbcopy(fd, trelb, op->oh.tsize);
	fbcopy(fd, drelb, op->oh.dsize);
	op->havex = chkx(op->sp);

	p1syms(op->sp, op->havex, op);
}
