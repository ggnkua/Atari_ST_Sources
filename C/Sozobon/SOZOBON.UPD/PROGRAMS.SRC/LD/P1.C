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

extern int vflag, multipass, bflag;

char *myalloc();
struct sinfo *lookup();

int ifd;

pass0(s)
char *s;
{
	register struct finfo *fp;

	if (nfiles >= MAXFI) {
		fprintf(stderr, "Too many files\n");
		exit(1);
	}
	fp = &files[nfiles++];
	fp->fname = s;	

	fp->fd = OPENBR(s);
	if (fp->fd < 0) {
		fprintf(stderr, "Cant open %s\n", s);
		exit(1);
	}
}
	
fpass1(fname)
char *fname;
{
	char buf[81], *s, *savestr();
	FILE *ffd;

	ffd = fopen(fname, "r");
	if (ffd == NULL) {
		fprintf(stderr, "Cant open %s\n", fname);
		exit(1);
	}
	while (fscanf(ffd, "%80s", buf) == 1) {
		s = savestr(buf);
		pass0(s);
	}
}

pass1(fn)
{
	register struct finfo *fp;
	int i, n, nlost;

	fp = &files[fn];
	if (vflag)
		printf("%s:\n", fp->fname);

	ifd = fp->fd;

	read(ifd, &i, sizeof(int));
	if (i == OMAGIC)
		doobj(fn);
	else if (i == AMAGIC)
		doarch(fn);
	else {
		fprintf(stderr,"File '%s' not a valid object file or library\n",
			fp->fname);
		exit(1);
	}
}

doarch(fn)
{
	struct arch a;
	int i;
	long astart, ostart, tell();

	nskip = 0;
more:
	i = read(ifd, &a, sizeof(a));
	if (i != sizeof(a) || a.anm[0] == 0)
		goto out;

	ostart = tell(ifd);
	astart = ostart + a.asize;

	doaobj(ostart, fn, a.anm);

	lseek(ifd, astart, 0);
	goto more;

out:

	if (multipass)
		m_redo(fn);
}

doobj(fn)
{
	int i;

	i = read(ifd, (char *)&h + 2, sizeof(h)-2);

	if (i != sizeof(h)-2) {
		fprintf(stderr, "File '%s' not a valid object file\n",
			files[fn].fname);
		return;
	}

	doreally(&h, fn, NULL, NULL);
}

doreally(hp, fn, aname, sptr)
struct hdr *hp;
char *aname, *sptr;
{
	register struct oinfo *p;
	char *iptr;
	long n, tell();

	if (nobj >= MAXOBJ) {
		fprintf(stderr, "Obj table overflow\n");
		exit(1);
	}

	p = &obj[nobj];
	p->fno = fn;
	if (aname) {
		strncpy(p->aname, aname, 14);
		if (vflag)
			printf("(%.14s)\n", aname);
	}

	p->oh = *hp;
	p->tbase = textsize;
	p->dbase = datasize;
	p->bbase = bsssize;

	n = hp->tsize+hp->dsize;
	if (bflag) {
		p->im_td = tell(ifd);
		lseek(ifd, n, 1);
	} else {
		p->im_td = (long)myalloc(n);
		lread(ifd, p->im_td, n);
	}

	if (sptr) {
		lseek(ifd, hp->syms, 1);
	} else {
		sptr = myalloc(hp->syms);
		lread(ifd, sptr, hp->syms);
	}
	p->im_sym = sptr;

	if (bflag) {
		p->im_rel = tell(ifd);
	} else {
		p->im_rel = (long)myalloc(n);
		lread(ifd, p->im_rel, n);
	}

	textsize += hp->tsize;
	datasize += hp->dsize;
	bsssize += hp->bsize;

	symabs(sptr);
	n = hp->syms/sizeof(struct sym);
	while (n--)
		p1sym();

	nobj++;
	return 1;
}

doaobj(offs, fn, aname)
long offs;
char *aname;
{
	long n;
	int i;
	char *iptr;

	lseek(ifd, offs, 0);
	i = read(ifd, &h, sizeof(h));

	if (i != sizeof(h) || h.magic != OMAGIC) {
		fprintf(stderr,
			"Member '%s' of library '%s' not a valid object file\n",
			aname, files[fn].fname);
		return;
	}

	n = h.syms;
	lseek(ifd, h.tsize+h.dsize, 1);
	iptr = myalloc(n);
	lread(ifd, iptr, n);

	symabs(iptr);

	if (norefs(h.syms)) {
		if (multipass)
			m_save(iptr, aname, offs);
		else
			free(iptr);
		return;
	} else {
		lseek(ifd, offs + sizeof(h), 0);
	}

	doreally(&h, fn, aname, iptr);
}

m_save(iptr, aname, offs)
char *iptr;
char *aname;
long offs;
{
	register struct skipstr *p;

	if (nskip >= MAXLIB) {
		fprintf(stderr, "Skip table overflow\n");
		exit(1);
	}
	p = &skip[nskip];
	strncpy(p->aname, aname, 14);
	p->oh = h;
	p->ims = iptr;
	p->offs = offs;
	nskip++;
}

m_redo(fn)
{
	register struct skipstr *p;
	int rescan, i;

	if (vflag)
		printf("Re-scan %s:\n", files[fn].fname);

	/* if need skipped objs
		doreally()
		p->ims = NULL
		rescan++
	*/
again:
	rescan = 0;
	p = skip;
	for (i=0; i<nskip; i++,p++) {
		if (p->ims == 0)
			continue;

		symabs(p->ims);
		if (norefs(p->oh.syms) == 0) {

			lseek(ifd, p->offs + sizeof(h), 0);

			doreally(&p->oh, fn, p->aname, p->ims);
			p->ims = 0;
			rescan++;
		}
	}

	if (rescan)
		goto again;
frees:
	p = skip;
	while (nskip--) {
		if (p->ims)
			free(p->ims);
		p++;
	}
}

norefs(sy)
long sy;
{
	long n, ftell();

	n = sy/sizeof(struct sym);
	while (n--)
		if (p1need())
			return 0;
	return 1;
}

p1sym()
{
	struct sym s;
	int i;

	i = symread(&s);
	if (i != 1)
		return;
	if (not_glob(s.flags))
		return;

	addsym(&s);
}

addsym(s)
struct sym *s;
{
	register struct sinfo *sp;

	if (oldsym(s))
		return;

	if (nsym >= MAXSYM) {
		fprintf(stderr, "Sym table overflow\n");
		exit(1);
	}

	sp = &sym[nsym];
	sp->onum = nobj;
	sp->sy = *s;
	hashins(sp);
	nsym++;
}

struct sym zsym;

undef(name)
char *name;
{
	struct sym s;
	int sv;

	sv = nobj;
	nobj = -1;

	s = zsym;
	strncpy(s.name, name, 8);
	s.flags = 0x88;
	s.value = 0;
	addsym(&s);

	nobj = sv;
}

p1need()
{
	struct sym s;
	int i;

	i = symread(&s);
	if (i != 1)
		return 0;
	if (not_glob(s.flags))
		return 0;
	if (needsym(&s))
		return 1;

	return 0;
}

needsym(sp)
struct sym *sp;
{
	struct sinfo *ip;
	int ofl, nfl;

	nfl = sp->flags & 0xff;
	if (nfl == 0x88 || nfl == 0xa8)
		return 0;

	ip = lookup(sp->name);
	if (ip == NULL)
		return 0;
	ofl = ip->sy.flags & 0xff;

	if (ofl == 0x88) {
		if (vflag > 1)
		printf("Needed %.8s\n", sp->name);
		return 1;
	}
	return 0;
}

oldsym(sp)
struct sym *sp;
{
	struct sinfo *ip;
	int ofl, nfl;

	ip = lookup(sp->name);
	if (ip == NULL)
		return 0;
	ofl = ip->sy.flags & 0xff;
	nfl = sp->flags & 0xff;
	if (ofl == 0x88) {
		ip->sy = *sp;
		ip->onum = nobj;
	} else if (nfl == 0x88) {
		;
	} else if (ofl == 0xa8 && nfl == 0xa8) {
		if (ip->sy.value != sp->value) {
			fprintf(stderr, "Common sizes differ %.8s %ld %ld\n",
				ip->sy.name,
				ip->sy.value, sp->value);
			if (sp->value > ip->sy.value)
				ip->sy.value = sp->value;
		}
	} else 
		fprintf(stderr, "Double def of %.8s %x %x\n", sp->name,
				ofl, nfl);
	return 1;
}

not_glob(x)
{
	x &= 0xff;
	if (x & 0x20)
		return 0;

	if (x == 0x88)
		return 0;
	return 1;
}
