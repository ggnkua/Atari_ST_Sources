/* Copyright (c) 1988 by Sozobon, Limited.  Author: Johann Ruegg
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
#include <ar.h>

struct hdr {
	int magic;
	long tsize, dsize, bsize;
	long syms;
	long f1,f2;
	int f3;
} h;

struct sym {
	char name[8];
	char flags;
	long value;
};

int gflag;

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
			gflag++;
		}
}

doname(s, many)
char *s;
{
	FILE *fd, *fopen();
	int i;

	fd = fopen(s, "rb");
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
			while (i--)
				dosym(fd);
		}
	}
		
	fclose(fd);
}

dohdr(fd)
FILE *fd;
{
	int i;
	long len;

	fread(&h, 2, 1, fd);
	if (h.magic == ARMAG1)
		return -1;
	i = fread((char *)&h + 2, sizeof(h) - 2, 1, fd);
	if (i != 1 || h.magic != 0x601a) {
		printf("Bad header\n");
		return 0;
	}
	len = h.tsize + h.dsize;
	fseek(fd, len, 1);
	return h.syms / sizeof(struct sym);
}

dosym(fd)
FILE *fd;
{
	struct sym s;
	int i;

	i = fread(&s, sizeof(s), 1, fd);
	if (i != 1)
		return;
	if (gflag && not_glob(s.flags))
		return;
	printf("%.8s", s.name);
	fill8(s.name);
	printf("\t%8lx", s.value);
	putchar(' ');
	sflags(s.flags);
	putchar('\n');
}

fill8(s)
char *s;
{
	int i;

	for (i=0; i<8; i++)
		if (s[i] == 0)
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
	x &= 0xff;
	if (x & 0x20)
		printf("global ");
	x &= ~0x20;
	if (x == 0x88)
		printf("external abs");
	else if (x == 0xc0)
		printf("equ abs");
	else if (x == 0xd0)
		printf("equ reg abs");
	else {
		x &= 7;
		printf(fname[x]);
	}
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
	len = a.ar_size + ftell(fd);

	i = dohdr(fd);
	if (i <= 0)
		return;

	while (i--)
		dosym(fd);
	fseek(fd, len, 0);
	goto more;
}
