/*
 * $Header: arcunp.c,v 1.7 88/06/18 03:12:36 hyc Locked $
 */

/*
 * ARC - Archive utility - ARCUNP
 * 
 * Version 3.17, created on 02/13/86 at 10:20:08
 * 
 * (C) COPYRIGHT 1985 by System Enhancement Associates; ALL RIGHTS RESERVED
 * 
 * By:  Thom Henderson
 * 
 * Description: This file contains the routines used to expand a file when
 * taking it out of an archive.
 * 
 * Language: Computer Innovations Optimizing C86
 */
#include <stdio.h>
#include "arc.h"
#if	MTS
#include <ctype.h>
#endif

void	setcode(), init_usq(), init_ucr(), decomp(), sqdecomp();
void	abort(), putc_tst();
int	getc_usq(), getc_ucr(), addcrc();

/* stuff for repeat unpacking */

#define DLE 0x90		/* repeat byte flag */

static int      state;		/* repeat unpacking state */

/* repeat unpacking states */

#define NOHIST 0		/* no relevant history */
#define INREP 1			/* sending a repeated value */

static short    crcval;		/* CRC check value */
static long     size;		/* bytes to read */
#if	!DOS
static int	gotcr;		/* got a carriage return? */
#endif

int
unpack(f, t, hdr)		/* unpack an archive entry */
	FILE           *f, *t;	/* source, destination */
	struct heads   *hdr;	/* pointer to file header data */
{
	int             c;	/* one char of stream */
	void            putc_unp();
	void            putc_ncr();
	int             getc_unp();

	/* setups common to all methods */
#if	!DOS
	gotcr = 0;
#endif
	crcval = 0;		/* reset CRC check value */
	size = hdr->size;	/* set input byte counter */
	state = NOHIST;		/* initial repeat unpacking state */
	setcode();		/* set up for decoding */

	/* use whatever method is appropriate */

	switch (hdrver) {	/* choose proper unpack method */
	case 1:		/* standard packing */
	case 2:
		while ((c = getc_unp(f)) != EOF)
			putc_unp((char) c, t);
		break;

	case 3:		/* non-repeat packing */
		while ((c = getc_unp(f)) != EOF)
			putc_ncr((unsigned char) c, t);
		break;

	case 4:		/* Huffman squeezing */
		init_usq(f);
		while ((c = getc_usq(f)) != EOF)
			putc_ncr((unsigned char) c, t);
		break;

	case 5:		/* Lempel-Zev compression */
		init_ucr(0);
		while ((c = getc_ucr(f)) != EOF)
			putc_unp((char) c, t);
		break;

	case 6:		/* Lempel-Zev plus non-repeat */
		init_ucr(0);
		while ((c = getc_ucr(f)) != EOF)
			putc_ncr((unsigned char) c, t);
		break;

	case 7:		/* L-Z plus ncr with new hash */
		init_ucr(1);
		while ((c = getc_ucr(f)) != EOF)
			putc_ncr((unsigned char) c, t);
		break;

	case 8:		/* dynamic Lempel-Zev */
		decomp(f, t);
		break;

	case 9:		/* Squashing */
		sqdecomp(f, t);
		break;

	default:		/* unknown method */
		if (warn) {
			printf("I don't know how to unpack file %s\n", hdr->name);
			printf("I think you need a newer version of ARC\n");
			nerrs++;
		}
		fseek(f, hdr->size, 1);	/* skip over bad file */
		return 1;	/* note defective file */
	}

	/* cleanups common to all methods */

	if (crcval != hdr->crc) {
		if (warn || kludge) {
			printf("WARNING: File %s fails CRC check\n", hdr->name);
			nerrs++;
		}
		return 1;	/* note defective file */
	}
	return 0;		/* file is okay */
}

/*
 * This routine is used to put bytes in the output file.  It also performs
 * various housekeeping functions, such as maintaining the CRC check value.
 */

void
putc_unp(c, t)			/* output an unpacked byte */
	char            c;	/* byte to output */
	FILE           *t;	/* file to output to */
{
	crcval = addcrc(crcval, c);	/* update the CRC check value */
#if	MTS
	if (!image)
		atoe(&c, 1);
#endif
#if	DOS
	putc_tst(c, t);
#else
	if (image)
		putc_tst(c, t);
	else {
		if (gotcr) {
			gotcr = 0;
			if (c != '\n')
				putc_tst('\r', t);
		}
		if (c == '\r')
			gotcr = 1;
		else
			putc_tst(c, t);
	}
#endif
}

/*
 * This routine is used to decode non-repeat compression.  Bytes are passed
 * one at a time in coded format, and are written out uncoded. The data is
 * stored normally, except that runs of more than two characters are
 * represented as:
 * 
 * <char> <DLE> <count>
 * 
 * With a special case that a count of zero indicates a DLE as data, not as a
 * repeat marker.
 */

void
putc_ncr(c, t)			/* put NCR coded bytes */
	unsigned char   c;	/* next byte of stream */
	FILE           *t;	/* file to receive data */
{
	static int      lastc;	/* last character seen */

	switch (state) {	/* action depends on our state */
	case NOHIST:		/* no previous history */
		if (c == DLE)	/* if starting a series */
			state = INREP;	/* then remember it next time */
		else
			putc_unp(lastc = c, t);	/* else nothing unusual */
		return;

	case INREP:		/* in a repeat */
		if (c)		/* if count is nonzero */
			while (--c)	/* then repeatedly ... */
				putc_unp(lastc, t);	/* ... output the byte */
		else
			putc_unp(DLE, t);	/* else output DLE as data */
		state = NOHIST;	/* back to no history */
		return;

	default:
		abort("Bad NCR unpacking state (%d)", state);
	}
}

/*
 * This routine provides low-level byte input from an archive.  This routine
 * MUST be used, as end-of-file is simulated at the end of the archive entry.
 */

int
getc_unp(f)			/* get a byte from an archive */
	FILE           *f;	/* archive file to read */
{
	register int    xx;
	unsigned char		code();

	if (!size)		/* if no data left */
		return EOF;	/* then pretend end of file */

	size--;			/* deduct from input counter */
	xx = getc(f);
	return code(xx);	/* and return next decoded byte */
}
