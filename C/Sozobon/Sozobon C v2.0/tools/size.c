/* Copyright (c) 1988,89,91 by Sozobon, Limited.  Author: Tony Andrews
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
"size: version 2.00  Copyright (c) 1988,89,91 by Sozobon, Limited.";

#include <stdio.h>
#ifndef UNIXHOST
#include <ar.h>
#else
#include "crossar.h"
#endif

#ifdef	MINIX
#define	O_RDONLY	0
#else
#include <fcntl.h>
#endif

#ifndef UNIXHOST
#define SWAPW(a,b)
#define SWAPL(a,b)
#else
#define SWAPW(a,b)	swapw(a,b)
#define SWAPL(a,b)	swapl(a,b)
long crossl();
#endif

/*
 * Object file header
 */
struct hdr_l {
	long	tsize;
	long	dsize;
	long	bsize;
	long	ssize;
	long	stksize;
	long	entrypt;
};

#define	OMAGIC	0x601a		/* object module magic number */

#ifdef MINIX

#define MMAGIC	0x4100301L
#define MMAGIC2	0x20

struct mhdr {
	long magic;
	long magic2;
	long tsize, dsize, bsize;
	long fill;
	long totsize;
	long syms;
};
#endif

extern	long	lseek();

int	oflag = 0;
int	xflag = 0;

usage()
{
	fprintf(stderr, "usage: size [-o|-x] [-V] file ...\n");
	exit(1);
}

main(argc, argv)
int	argc;
char	*argv[];
{
	for (argv++; *argv != NULL && argv[0][0] == '-' ;argv++) {
		switch (argv[0][1]) {

		case 'o':
		case 'O':
			oflag++; break;
		case 'x':
		case 'X':
			xflag++; break;
		case 'V':
		case 'v':
			printf("%s\n", Version);
			break;
		default:
			usage();
		}
	}

	for (; *argv != NULL; argv++)
		dofile(*argv);

	exit(0);
}

dofile(f)
char	*f;
{
	int	fd;
	struct	hdr_l	h;
	int	magic;

	if ((fd = open(f, O_RDONLY)) < 0) {
		fprintf(stderr, "size: can't open file '%s'\n", f);
		return;
	}

	if (read(fd, &magic, 2) != 2) {
		fprintf(stderr, "size: '%s' not an object module\n", f);
		close(fd);
		return;
	}

	SWAPW(&magic, 1);
	switch (magic) {

	case OMAGIC:	/* object module */
		if (read(fd, &h, sizeof(h)) != sizeof(h)) {
			fprintf(stderr, "size: '%s' not an object module\n", f);
			close(fd);
			return;
		}
		showit((char *) 0, f, &h);
		break;

	case ARMAG1:	/* libraries */
	case ARMAG2:
		dolib(f, fd);
		break;

	default:

#ifdef	MINIX
		{
		long	lmagic;
		struct	mhdr	mh;

		lseek(fd, 0L, 0);

		if (read(fd, &lmagic, 4) == 4 && 
#ifdef UNIXHOST
		    (SWAPL(&lmagic, 1) == 0) &&
#endif
		    lmagic == MMAGIC) {
			lseek(fd, 0L, 0);
			if (read(fd, &mh, sizeof(mh)) != sizeof(mh) ||
#ifdef UNIXHOST
			    SWAPL(&mh, sizeof(mh)/4) ||
#endif
			    mh.magic2 != MMAGIC2) {
				fprintf(stderr,
					"size: '%s' not an object module\n", f);
				close(fd);
				return;
			}
			mshowit((char *) 0, f, &mh);
			close(fd);
			return;
		}
		}
#endif
		fprintf(stderr, "size: unknown file type '%s'\n", f);
		break;

	}

	close(fd);
}

/*
 * gethdr(fd, a) - read an archive header at the current file position
 *
 * Returns TRUE on success, FALSE at eof.
 */
int
gethdr(fd, a)
int	fd;
struct	ar_hdr	*a;
{
	if (read(fd, a, ARHSZ) == ARHSZ)
		return (a->ar_name[0] != '\0');
	else
		return 0;
}

/*
 * dolib(f, fd) - show the size of all object modules in a library
 */
dolib(f, fd)
char	*f;
int	fd;
{
	struct	ar_hdr	a;
	struct	hdr_l	h;
	short magic;
	long	next;
	long	ts, ds, bs;

	ts = ds = bs = 0;

	while (gethdr(fd, &a)) {
#ifndef UNIXHOST
		next = lseek(fd, 0L, 1) + a.ar_size;
#else
		next = lseek(fd, 0L, 1) + crossl(a.ar_size);
#endif
		if (read(fd, &magic, sizeof(magic)) != sizeof(magic) || 
#ifdef UNIXHOST
			SWAPW(&magic, 1) ||
#endif
			magic != OMAGIC) {
			fprintf(stderr, "size: '%s' not an object module\n", f);
			break;
		}
		read(fd, &h, sizeof(h));
		showit(f, a.ar_name, &h);

		ts += h.tsize;
		ds += h.dsize;
		bs += h.bsize;

		if (lseek(fd, next, 0) < 0)
			break;
	}

	printf("%s(TOTAL): ", f);

	if (oflag)
		printf("%lo + %lo + %lo = %lo\n", ts, ds, bs, ts+ds+bs);
	else if (xflag)
		printf("0x%lx + 0x%lx + 0x%lx = 0x%lx\n", ts, ds, bs, ts+ds+bs);
	else /* decimal */
		printf("%ld + %ld + %ld = %ld\n", ts, ds, bs, ts+ds+bs);
}

showit(l, f, h)
char	*l;
char	*f;
struct	hdr_l	*h;
{
	if (l != (char *) 0)
		printf("%s(%.14s): ", l, f);
	else
		printf("%s: ", f);

	SWAPL(h, 6);
	if (oflag)
		printf("%lo + %lo + %lo = %lo\n",
			h->tsize, h->dsize, h->bsize,
			h->tsize + h->dsize + h->bsize);
	else if (xflag)
		printf("0x%lx + 0x%lx + 0x%lx = 0x%lx\n",
			h->tsize, h->dsize, h->bsize,
			h->tsize + h->dsize + h->bsize);
	else /* decimal */
		printf("%ld + %ld + %ld = %ld\n",
			h->tsize, h->dsize, h->bsize,
			h->tsize + h->dsize + h->bsize);
}

#ifdef	MINIX
mshowit(l, f, mh)
char	*l;
char	*f;
struct	mhdr	*mh;
{
	if (l != (char *) 0)
		printf("%s(%.14s): ", l, f);
	else
		printf("%s: ", f);

	if (oflag)
		printf("%lo + %lo + %lo = %lo\n",
			mh->tsize, mh->dsize, mh->bsize,
			mh->tsize + mh->dsize + mh->bsize);
	else if (xflag)
		printf("0x%lx + 0x%lx + 0x%lx = 0x%lx\n",
			mh->tsize, mh->dsize, mh->bsize,
			mh->tsize + mh->dsize + mh->bsize);
	else /* decimal */
		printf("%ld + %ld + %ld = %ld\n",
			mh->tsize, mh->dsize, mh->bsize,
			mh->tsize + mh->dsize + mh->bsize);
}
#endif

#ifdef UNIXHOST
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
	return 0;
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
	return 0;
}

#endif
