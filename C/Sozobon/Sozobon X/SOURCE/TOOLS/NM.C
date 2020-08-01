/* Copyright (c) 1988,89,91 by Sozobon, Limited.  Author: Johann Ruegg
 *
 * Permission is granted to anyone to use this software for any purpose
 * on any computer system, and to redistribute it freely, with the
 * following restrictions:
 * 1) No charge may be made other than reasonable charges for reproduction.
 * 2) Modified versions must be clearly marked as such.
 * 3) The authors are not responsible for any harmful consequences
 *    of using this software, even if they result from defects in it.
 *
 *	Alternative ST symbol table lister.
 */

#include <stdio.h>
#ifndef UNIXHOST
#include <ar.h>
#else
#include "crossar.h"
long crossl();
#endif

#ifdef	MINIX

#define	RMODE	"r"		/* binary file "read" mode for fopen */
#define MAGIC0	0x410
#define MAGIC	0x0301	/* magic number for an executable */

struct hdr_x {
	long magic2;
	long tsize, dsize, bsize;
	long fill;
	long totsize;
	long nsyms;
} h;
#define HDRXLEN	28
#define HDRLONGS	7

#else

#ifndef UNIXHOST
#define	RMODE	"rb"		/* binary file "read" mode for fopen */
#else
#define RMODE	"r"
#endif
#define MAGIC	0x601a		/* magic number for an executable */

/*
 * Executable file header
 */
struct hdr_x {
	long	tsize, dsize, bsize;
	long	nsyms;
	long	f1, f2;		/* filler */
	short	f3;
} h;
#define HDRXLEN	26
#define HDRLONGS	4
#endif

#ifndef UNIXHOST
#define SWAPW(a,b)
#define SWAPL(a,b)
#else
#define SWAPW(a,b)	swapw(a,b)
#define SWAPL(a,b)	swapl(a,b)
#endif

struct sym {
	char name[8];
	char flags, mode;
	long value;
};
#define SYMSIZE	14
#define SYMVOFFS 10

int gflag;
int only8;

#define XNAME	"SozobonX"
#define XVALUE	0x87654321
#define XFLAGS	0x42
int havex;

main(argc, argv)
char **argv;
{
	int many;

	many = argc > 2;

	while (--argc) {
		argv++;
		if (*argv[0] == '-')
			doopt(argv[0]);
		else
			doname(argv[0], many);
	}
	exit(0);
}

doopt(s)
char *s;
{
	while (*++s)
		switch (*s) {
		case 'g':
		case 'G':
			gflag++;
			break;
		case '8':
			only8++;
			break;
		}
}

doname(s, many)
char *s;
{
	FILE *fd, *fopen();
	int i;

	fd = fopen(s, RMODE);
	if (fd == NULL) {
		fprintf(stderr, "Can't open %s\n", s);
		return;
	}

	if (many)
		printf("\n%s:\n", s);

	if (i = dohdr(fd)) {
		if (i == -1)
			doarch(fd);
		else {
			havex = -1;
			while (i)
				i -= dosym(fd);
		}
	}
		
	fclose(fd);
}

dohdr(fd)
FILE *fd;
{
	unsigned short magic = 0;
	int i;
	long len;

	fread(&magic, 2, 1, fd);
	SWAPW(&magic, 1);
	if (magic == ARMAG1)
		return -1;

#ifdef MINIX
	if (magic != MAGIC0) {
		printf("Bad header\n");
		return 0;
	}
	fread(&magic, 2, 1, fd);
	SWAPW(&magic, 1);
#endif

	i = fread(&h, HDRXLEN, 1, fd);
	SWAPL(&h, HDRLONGS);
	if (i != 1 || magic != MAGIC) {
		printf("Bad header\n");
		return 0;
	}

	len = h.tsize + h.dsize;
	fseek(fd, len, 1);
	return h.nsyms / SYMSIZE;
}

dosym(fd)
FILE *fd;
{
	static struct sym s;
	static int reuse = 0;
	int i, x;
	int n;

	if (reuse)
		reuse = 0;
	else {
		i = fread(&s, SYMSIZE, 1, fd);
		if (i != 1)
			return 1;
#ifdef UNIXHOST
		s.value = crossl((char *)&s + SYMVOFFS);
#endif
	}

	if (havex == -1) {	/* first symbol */
		if (s.flags == XFLAGS && s.value == XVALUE &&
		    strncmp(s.name, XNAME, 8) == 0 && !only8) {
			havex = 1;
			return 1;
		} else
			havex = 0;
	}

	if (gflag && not_glob(s.flags))
		return 1;

	printf("%8lx ", s.value);
	n = sflags(s.flags) + 1;
	fill8(n);

	printf("%.8s", s.name);

	if (havex) {
	    x = 0;
	    for (;;) {
		i = fread(&s, SYMSIZE, 1, fd);
		if (i != 1)
			break;
#ifdef UNIXHOST
		s.value = crossl((char *)&s + SYMVOFFS);
#endif
		if (s.flags != XFLAGS || s.value != XVALUE) {
			reuse = 1;
			break;
		}
		x++;
		printf("%.8s", s.name);
	    }
	} else
		x = 0;

	putchar('\n');
	return x+1;
}

#define MAXTYPE 16

fill8(n)
{
	int i;

	for (i=n; i<MAXTYPE; i++)
		putchar(' ');
}

char *fname[] = {
	"?0?", "bss", "text", "?3?", "data",
	"?5?", "?6?", "?7?"
};

not_glob(x)
{
	x &= 0xff;
	if (x & 0x20)
		return 0;
	x &= ~0x20;
	if (x == 0x88)
		return 0;
	return 1;
}

sflags(x)
{
	int n = 0;

	x &= 0xff;
	if (x & 0x20) {
		printf("glb ");
		n += 4;
	}
	x &= ~0x20;
	if (x == 0x88) {
		printf("ext abs");
		n += 7;
	} else if (x == 0xc0) {
		printf("equ abs");
		n += 7;
	} else if (x == 0xd0) {
		printf("equ reg abs");
		n += 11;
	} else {
		x &= 7;
		printf(fname[x]);
		n += strlen(fname[x]);
	}
	return n;
}

doarch(fd)
FILE *fd;
{
	struct ar_hdr a;
	int i;
	long len, ftell();

more:
	i = fread(&a, sizeof(a), 1, fd);
	if (i != 1)
		return;
	printf("\n(%.18s):\n", a.ar_name);
#ifndef UNIXHOST
	len = a.ar_size + ftell(fd);
#else
	len = crossl(a.ar_size) + ftell(fd);
#endif

	i = dohdr(fd);
	if (i <= 0)
		return;

	havex = -1;
	while (i)
		i -= dosym(fd);
	fseek(fd, len, 0);
	goto more;
}

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
}
#endif
