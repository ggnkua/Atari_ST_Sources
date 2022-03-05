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
 *	Program to remove local symbols from Alcyon .o's or archives
 *
 * 02OCT88
 *	dal: fixed temp file rename problem using _splitpath/_makepath
 *	     and made several error handling changes.  Also added the
 *	     '-s' switch for "silent" operation.
 */

#include <stdio.h>
#include <ar.h>

#define MAXGL	2048

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

FILE		*outfd;
int		nnew;
int		s_flag = FALSE;		/* operate silently */
char		*filename = NULL;	/* current filename */
int		many = FALSE;		/* more than one source file */

usage()
{
	fprintf(stderr, "usage: globs [-s] file...\n");
	fprintf(stderr, "  remove non-essential symbols\n");
	exit(1);
}

main(argc, argv)
int argc;
char *argv[];
{
	while(--argc && (**++argv == '-'))
		doopt(*argv);

	if (argc < 1)
		usage();

	many = (argc > 1);

	while (argc--)
		doname(*argv++);

	putchar('\n');
}

doopt(s)
register char *s;
{
	while (*++s)
		switch (*s) {
#ifdef G_FLAG
		case 'g':
			g_flag = TRUE;
#endif
		case 's':
			s_flag = TRUE;
		default:
			fprintf(stderr, "globs: illegal option '%c'\n", *s);
			usage();
		}
	}

doname(s)
char *s;
{
	FILE *fd, *fopen();
	int i, n, nlost;
	char pbuf[128], drive[4], path[128];

	filename = s;
	fd = fopen(s, "rb");
	if (fd == NULL) {
		fprintf(stderr, "globs: can't open '%s'\n", s);
		return;
	}

	_splitpath(s, drive, path, NULL, NULL);
	_makepath(pbuf, drive, path, "_globs", "tmp");
	outfd = fopen(pbuf, "wb");
	if (outfd == NULL) {
		fprintf(stderr, "globs: can't open tmp file\n");
		fclose(fd);
		exit(EXIT_FAILURE);
	}

	if (many && !s_flag)
		printf("processing %s\n", s);

	if (i = dohdr(fd)) {
		if (i == -1)
			doarch(fd);
		else {
			startsyms();
			for (n=0; n<i; n++)
				dosym(fd, n);
			nlost = i - nnew;
			if (!s_flag)
				printf("removed %d symbols\n", nlost);
			if (nlost == 0) {
				fclose(fd);
				return;
			}
			rewind(fd);
			redo(fd);
			dorel(fd);
		}
	} else
		exit(1);
		
	fclose(fd);
	fclose(outfd);

	if (unlink(s) || rename(pbuf, s)) {
		fprintf(stderr, "globs: unlink/rename error on '%s'\n", s);
		exit(EXIT_FAILURE);
	}
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
		printf("globs: bad header on '%s'\n", filename);
		return 0;
	}
	len = h.tsize + h.dsize;
	fseek(fd, len, 1);
	return(h.syms / sizeof(struct sym));
}

struct newsym {
	int oldnum;
	struct sym sy;
} ns[MAXGL];

findx(x)
{
	register i;

	x >>= 3;
	for (i=0; i<nnew; i++)
		if (ns[i].oldnum == x) {
			x = i;
			goto okay;
		}
	printf("globs: can't find sym %d in '%s'\n", x, filename);
	exit(EXIT_FAILURE);
okay:
	x = (x<<3) + 4;
	return x;
}

redo(fd)
FILE *fd;
{
	register i;
	long oldsyms;

	fread(&h, sizeof(h), 1, fd);
	oldsyms = h.syms;
	h.syms = (long)nnew * sizeof(struct sym);
	fwrite(&h, sizeof(h), 1, outfd);

	lcopy(fd, h.tsize+h.dsize);
	fseek(fd, oldsyms, 1);
	for (i=0; i<nnew; i++)
		fwrite(&ns[i].sy, sizeof(struct sym), 1, outfd);	
}

#define BSIZE 1024

lcopy(fd, len)
FILE *fd;
long len;
{
	int n;
	char buf[BSIZE];

	while (len) {
		n = len > BSIZE ? BSIZE : len;
		fread(buf, n, 1, fd);
		fwrite(buf, n, 1, outfd);
		len -= n;
	}
}

startsyms()
{
	nnew = 0;
}

dosym(fd, oldn)
FILE *fd;
{
	struct sym s;
	int i;

	i = fread(&s, sizeof(s), 1, fd);
	if (i != 1)
		return;
	if (not_glob(s.flags))
		return;
	ns[nnew].sy = s;
	ns[nnew].oldnum = oldn;
	nnew++;
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

#ifdef NEVER
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
#endif

doarch(fd)
FILE *fd;
{
	struct ar_hdr a;
	int i, n, nlost, x;
	long astart, ostart, ftell();

	i = ARMAG1;
	fwrite(&i, sizeof(int), 1, outfd);
more:
	i = fread(&a, sizeof(a), 1, fd);
	if (i != 1)
		goto out;

	if (!s_flag)
		printf("\n(%.18s):\n", a.ar_name);
	ostart = ftell(fd);
	astart = ostart + a.ar_size;

	i = dohdr(fd);
	if (i <= 0)
		return;

	startsyms();
	for (n=0; n<i; n++)
		dosym(fd, n);

	nlost = i-nnew;
	if (!s_flag)
		printf("removed %d symbols\n", nlost);

	a.ar_size = sizeof(h) + 2*(h.tsize+h.dsize) +
			nnew*sizeof(struct sym);

	fwrite(&a, sizeof(a), 1, outfd);

	fseek(fd, ostart, 0);
	redo(fd);
	dorel(fd);

	fseek(fd, astart, 0);
	goto more;

out:
	x = ftell(outfd);
	x &= 0xff;
	if (x)
		zeroes(0x100 - x);
}

char zbuf[0x100];

zeroes(n)
{
	if (!s_flag)
		printf("fill %d\n", n);
	fwrite(zbuf, n, 1, outfd);
}

dorel(fd)
FILE *fd;
{
	long num, i;
	long here, ftell();
	int x;

	here = ftell(fd);
	num = (h.tsize + h.dsize)/((long) sizeof(int));
	if (!s_flag)
		printf("at %lx, %ld words\n", here, num);
	for (i=0; i<num; i++) {
		fread(&x, sizeof(int), 1, fd);
		fwrite(&x, sizeof(int), 1, outfd);
		switch (x) {
		case 7:
		case 0:
			break;
		case 5:
			fread(&x, sizeof(int), 1, fd);
			i++;
			if ((x & 7) == 4)
				x = findx(x);
			fwrite(&x, sizeof(int), 1, outfd);
			break;
		default:
			printf("?%x? ", x);
		}
	}
}
