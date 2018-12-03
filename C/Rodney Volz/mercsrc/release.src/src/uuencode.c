/* 
 *   Copyright (c) 1990 Rodney Volz
 *   ALL RIGHTS RESERVED 
 * 
 *   THIS SOFTWARE PRODUCT CONTAINS THE
 *   UNPUBLISHED SOURCE CODE OF RODNEY VOLZ
 *
 *   The copyright notices above do not evidence
 *   intended publication of such source code.
 *
 */

/*
 * MERCURY UUCP SOURCECODE [uuencode.c]
 */


#include <stdio.h>

#define SUMSIZE 64  /* 6 bits */
/* ENC is the basic 1 character encode function to make a char printing */
/* Each output character represents 6 bits of input */
#define ENC(c) ((c) ? ((c) & 077) + ' ': '`')
long	totalsize=0;	/* Used to count the file size because ftell() does
			   not return sane results for pipes */

main(argc, argv)
char **argv;
{
    FILE *in,*out;
    int mode;
#ifdef unix
    struct stat sbuf;
#endif
#ifdef AMIGA_LATTICE_OBSOLETE
    extern int Enable_Abort;	/* Enable CTRL-C for Lattice */
    Enable_Abort=1;
#endif

	if (!((argc < 3) || (argc > 4)))
	{
		if ((in = fopen(argv[1], "rb")) == NULL)
		{
			fprintf(stderr, "uuencode: can't find %s\n", argv[1]);
			exit(10);
		}

		if ((out = fopen(argv[2],"wb")) == NULL)
		{
			fprintf(stderr, "uuencode: can't write to %s\n", argv[2]);
			exit(10);
		}
	}
	else
	{
		fprintf(stderr, "USAGE: uuencode infile outfile [name]\n");
		exit(11);
	}

#ifdef unix
	/* figure out the input file mode */
	fstat(fileno(in), &sbuf);
	mode = sbuf.st_mode & 0777;
#else
	mode = 0644;	    /* Default permissions */
#endif

#if 1	/* Provide a table? */
	fprintf(out,"\ntable\n");
	fprintf(out," !\"#$\%&'()*+,-./0123456789:;<=>?\n");
	fprintf(out,"@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_\n");
#else
	fprintf(out,"\n");
#endif


	if (argc == 4)
		fprintf(out,"begin %o %s\n", mode, argv[3]);
	else
		fprintf(out,"begin %o %s\n", mode, argv[1]);
	
	encode(in, out);

	fprintf(out,"end\n");
	fprintf(out,"size %ld\n",totalsize);
	exit(0);
}

/*
 * copy from in to out, encoding as you go along.
 */
encode(in, out)
FILE *in;
FILE *out;
{
#ifndef unix
extern errno;
#endif
	char buf[80];
	int i, n, checksum;

	for (;;) {
		/* 1 (up to) 45 character line */
		n = fr(in, buf, 45);
		putc(ENC(n), out);

		checksum = 0;
		for (i=0; i<n; i += 3)
		    checksum = (checksum+outdec(&buf[i], out)) % SUMSIZE;

		putc(ENC(checksum), out);

#ifndef ST
		putc('\n', out);
#else ST
		putc(10,out);
#endif ST

#ifndef unix
		/* Error checking under UNIX?? You must be kidding! */
		if (errno) {
		    fprintf(stderr, "ERROR: error writing to output\n");
			exit(12);
		    }
#endif
		if (n <= 0)
			break;
	}
}

/*
 * output one group of 3 bytes, pointed at by p, on file f.
 * return the checksum increment.
 */
int outdec(p, f)
char *p;
FILE *f;
{
	int c1, c2, c3, c4;

	c1 = *p >> 2;
	c2 = (*p << 4) & 060 | (p[1] >> 4) & 017;
	c3 = (p[1] << 2) & 074 | (p[2] >> 6) & 03;
	c4 = p[2] & 077;
	putc(ENC(c1), f);
	putc(ENC(c2), f);
	putc(ENC(c3), f);
	putc(ENC(c4), f);

	return((p[0]+p[1]+p[2]) % SUMSIZE);
}



/* fr: like read but stdio */
int
fr(fd, buf, cnt)
FILE *fd;
char *buf;
int cnt;
{
	int c, i;

	for (i=0; i<cnt; i++) {
#ifndef ST
		c = getc(fd);
#else
		c = bingetc(fd);
#endif
		if (c == EOF)
			return(i);
		totalsize++;
		buf[i] = c;
	}
	return (cnt);
}
