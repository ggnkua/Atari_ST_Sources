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

static	char	Version[] =
"ld Version 1.01  Copyright (c) 1988 by Sozobon, Limited.";

#include <stdio.h>
#include "ld.h"

int mflag, vflag, bflag;
int symout = 0;
int multipass = 0;

char *oname = NULL;

main(argc, argv)
char **argv;
{
	int i, j, k;
	struct oinfo *op;
	struct sinfo *sp;

	for (i=1; i<argc; i++) {
		if (argv[i][0] == '-') {
			if (doopt(&argv[i][1], argv[i+1]))
				i++;
		} else
			pass0(argv[i]);
	}

	if (nfiles < 1)
		exit(0);
	/*
	 * If no output name was given, form it based on the name
	 * of the first file name on the command line.
	 */
	if (oname == NULL) {		/* no name assigned */
		char	*p, *strchr(), *strrchr(), *myalloc();

		if ((p = strrchr(files[0].fname, '\\')) != NULL)
			p++;
		else
			p = files[0].fname;

		oname = myalloc(14L);		/* max. file name size */

		strcpy(oname, p);		/* copy the base name */

		/*
		 * Truncate any existing suffix and add our own.
		 */
		if ((p = strchr(oname, '.')) != NULL)
			*p = '\0';

		strcat(oname, ".ttp");
	}

	for (i=0; i<nfiles; i++)
		pass1(i);

	obj_rel();
	sym_chk();

	if (mflag)
	for (i=0; i<nobj; i++) {
		op = &obj[i];
		onm_pr(i, stdout);
		if (op->oh.tsize)
		printf("\tT %lx @%lx", op->oh.tsize, op->tbase);
		if (op->oh.dsize)
		printf("\tD %lx @%lx", op->oh.dsize, op->dbase);
		if (op->oh.bsize)
		printf("\tB %lx @%lx", op->oh.bsize, op->bbase);
		putchar('\n');
	}

	pass2();

	exit(0);
}

onm_pr(i, fd)
FILE *fd;
{
	struct oinfo *op;
	struct finfo *fp;

	if (i < 0) {
		fprintf(fd, "CMD LINE");
		return;
	}
	op = &obj[i];
	fp = &files[op->fno];
	fprintf(fd, "%.8s", fp->fname);
	if (op->aname[0])
		fprintf(fd, "(%.14s)", op->aname);
}

doopt(s, s2)
char *s, *s2;
{
	char *myalloc();

	while (*s) {
		switch (*s) {
		case 'm':	/* print load map */
			mflag++;	break;
		case 'V':
			fprintf(stderr, "%s\n", Version);
			break;
		case 'v':	/* verbose */
			vflag++;	break;
		case 't':	/* put symbol table in obj */
			symout = 1;	break;
		case 'b':	/* big, so dont pre-read td & rel */
			bflag++;
			if (lbuf == NULL) {
				lbuf = (short *)myalloc(
					(long)(LBUFCNT+1) *
					sizeof(short));
				rbuf = (short *)myalloc(
					(long)(LBUFCNT+1) *
					sizeof(short));
			}
			break;
		case 'p':	/* go through libs multi times */
			multipass = 1;
			if (skip == NULL)
				skip = (struct skipstr *)myalloc(
						(long)MAXLIB *
						sizeof(*skip));
			break;
		case 'f':	/* file of objects */
			fpass1(s2);
			return 1;
		case 'o':	/* object file name */
			oname = s2;
			return 1;
		case 'u':	/* undefine name */
			undef(s2);
			return 1;
		}
		s++;
	}
	return 0;
}

char *
savestr(s)
char *s;
{
	int i;
	char *rets, *myalloc();

	i = strlen(s);
	rets = myalloc((long)i+1);
	strcpy(rets, s);
	return rets;
}

char *
myalloc(n)
long n;
{
	char *retv, *malloc();

	if (n > 64000L) {
		fprintf(stderr, "Chunk too big %ld\n", n);
		exit(1);
	}
	retv = malloc((unsigned)n);
	if (retv == NULL) {
		fprintf(stderr, "Malloc failure\n");
		exit(1);
	}
	return retv;
}

struct sinfo *
hashlst(s)
char *s;
{
	return hashs[hfun(s)];
}

hashins(sp)
struct sinfo *sp;
{
	register i;

	i = hfun(sp->sy.name);
	sp->hchain = hashs[i];
	hashs[i] = sp;
}

hfun(s)
register char *s;
{
	register char i;

	i = *s;
	i += *++s;
	i += *++s;
	i += *++s;
	return i & HMASK;
}

myncmp(p, q)
register long *p, *q;
{
	if (p[0] == q[0] && p[1] == q[1])
		return 0;
	return 1;
}

struct sinfo *
lookup(s)
char *s;
{
	register struct sinfo *sp;

	for (sp = hashlst(s); sp; sp = sp->hchain)
		if (myncmp(s, sp->sy.name) == 0)
			return sp;

	return NULL;
}

obj_rel()
{
	register i;
	register struct oinfo *p;

	p = obj;
	for (i=0; i<nobj; i++) {
		p->dbase += textsize;
		p->bbase += textsize+datasize;
		p++;
	}
}

sym_chk()
{
	register i, fl;
	register struct sinfo *sp;
	register struct oinfo *p;
	long offs, base;

	base = textsize+datasize+bsssize;
	sp = sym;
	for (i=0; i<nsym; i++) {
		fl = sp->sy.flags & 0xff;
		if (fl == 0x88) {
			fprintf(stderr, "Undef %.8s from ", sp->sy.name);
			onm_pr(sp->onum, stderr);
			fputc('\n', stderr);
		}
		else if (fl == 0xa8) {
			offs = sp->sy.value;
			sp->sy.value = base;
			sp->sy.flags = 0xa1;
			base += offs;
		} else {
			p = &obj[sp->onum];
			switch (fl & 7) {
			case 1:
				offs = p->bbase;	break;
			case 2:
				offs = p->tbase;	break;
			case 4:
				offs = p->dbase;	break;
			default:
				offs = 0;
			}
			sp->sy.value += offs;
		}
		sp++;
	}
	comsize = base - (textsize+datasize+bsssize);
}

int symnum;
struct sym *symptr;

symabs(iptr)
char *iptr;
{
	symptr = (struct sym *)iptr;
	symnum = 0;
}

symread(sp)
struct sym *sp;
{
	int i, fl;

	*sp = symptr[symnum++];

	fl = sp->flags & 0xff;
	if (fl == 0xa8 && sp->value == 0)
		sp->flags = 0x88;
	return 1;
}
