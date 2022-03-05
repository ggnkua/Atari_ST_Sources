/* Copyright (c) 1988 by Sozobon, Limited.  Author: Tony Andrews
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
"size: version 1.01  Copyright (c) 1988 by Sozobon, Limited.";

#include <stdio.h>
#include <fcntl.h>
#include <ar.h>

/*
 * Object file header
 */
struct hdr {
	int	magic;
	long	tsize;
	long	dsize;
	long	bsize;
	long	ssize;
	long	stksize;
	long	entrypt;
	int	rlbflg;
};

#define	OMAGIC	0x601a		/* object module magic number */

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
			oflag++; break;
		case 'x':
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
	struct	hdr	h;
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

	switch (magic) {

	case OMAGIC:	/* object module */
		lseek(fd, 0L, 0);
		if (read(fd, &h, sizeof(h)) != sizeof(h)) {
			fprintf(stderr, "size: '%s' not an object module\n", f);
			close(fd);
			return;
		}
		showit(NULL, f, &h);
		break;

	case ARMAG1:	/* libraries */
	case ARMAG2:
		dolib(f, fd);
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
	struct	hdr	h;
	long	next;
	long	ts, ds, bs;

	ts = ds = bs = 0;

	while (gethdr(fd, &a)) {
		next = lseek(fd, 0L, 1) + a.ar_size;
		if (read(fd, &h, sizeof(h)) != sizeof(h) || h.magic != OMAGIC) {
			fprintf(stderr, "size: '%s' not an object module\n", f);
			break;
		}
		ts += h.tsize;
		ds += h.dsize;
		bs += h.bsize;

		showit(f, a.ar_name, &h);

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
struct	hdr	*h;
{
	if (l != NULL)
		printf("%s(%.14s): ", l, f);
	else
		printf("%.14s: ", f);

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
