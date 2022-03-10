/*
 * $Header: arcsqs.c,v 1.3 88/07/31 18:54:14 hyc Exp $
 */

/*  ARC - Archive utility - SQUASH
 
(C) COPYRIGHT 1985 by System Enhancement Associates; ALL RIGHTS RESERVED
 
 This is a quick hack to ARCLZW to make it handle squashed archives.
 Dan Lanciani (ddl@harvard.*) July 87
 
*/

/*
 * $Header: arcsqs.c,v 1.3 88/07/31 18:54:14 hyc Exp $
 */

#include <stdio.h>
#include "arc.h"

#if	MSDOS
char	*setmem();
#else
#ifndef __STDC__
char	*memset();
#endif
#endif
int	getc_unp();
void	putc_pak(), putc_unp();
static void	putcode();

/* definitions for the new dynamic Lempel-Zev crunching */

#define BITS   13		/* maximum bits per code */
#define HSIZE  10007		/* 80% occupancy */
#define INIT_BITS 9		/* initial number of bits/code */
static int      n_bits;		/* number of bits/code */
static int      maxcode;	/* maximum code, given n_bits */
#define MAXCODE(n)      ((1<<(n)) - 1)	/* maximum code calculation */
static int      maxcodemax = 1 << BITS;	/* largest possible code (+1) */

static unsigned char buf[BITS];	/* input/output buffer */

static unsigned char lmask[9] =	/* left side masks */
{0xff, 0xfe, 0xfc, 0xf8, 0xf0, 0xe0, 0xc0, 0x80, 0x00};
static unsigned char rmask[9] =	/* right side masks */
{0x00, 0x01, 0x03, 0x07, 0x0f, 0x1f, 0x3f, 0x7f, 0xff};

static int      offset;		/* byte offset for code output */
static long     in_count;	/* length of input */
static long     bytes_out;	/* length of compressed output */
static unsigned short ent;

long     htab[HSIZE];	/* hash code table   (crunch) */
unsigned short codetab[HSIZE];	/* string code table (crunch) */

static unsigned short *prefix = codetab;  /* prefix code table (uncrunch) */
static unsigned char *suffix=(unsigned char *)htab;  /* suffix table (uncrunch) */
static int      free_ent;	/* first unused entry */
static int      firstcmp;	/* true at start of compression */
unsigned char stack[HSIZE];	/* local push/pop stack */

/*
 * block compression parameters -- after all codes are used up,
 * and compression rate changes, start over.
 */

static int      clear_flg;
static long     ratio;
#define CHECK_GAP 10000		/* ratio check interval */
static long     checkpoint;

/*
 * the next two codes should not be changed lightly, as they must not
 * lie within the contiguous general code space.
 */
#define FIRST   257		/* first free entry */
#define CLEAR   256		/* table clear output code */

static void
cl_block(t)			/* table clear for block compress */
	FILE           *t;	/* our output file */
{
	long            rat;

	checkpoint = in_count + CHECK_GAP;

	if (in_count > 0x007fffffL) {	/* shift will overflow */
		rat = bytes_out >> 8;
		if (rat == 0)	/* Don't divide by zero */
			rat = 0x7fffffffL;
		else
			rat = in_count / rat;
	} else
		rat = (in_count << 8) / bytes_out;	/* 8 fractional bits */

	if (rat > ratio)
		ratio = rat;
	else {
		ratio = 0;
		setmem(htab, HSIZE * sizeof(long), 0xff);
		free_ent = FIRST;
		clear_flg = 1;
		putcode(CLEAR, t);
	}
}

/*****************************************************************
 *
 * Output a given code.
 * Inputs:
 *      code:   A n_bits-bit integer.  If == -1, then EOF.  This assumes
 *              that n_bits =< (long)wordsize - 1.
 * Outputs:
 *      Outputs code to the file.
 * Assumptions:
 *      Chars are 8 bits long.
 * Algorithm:
 *      Maintain a BITS character long buffer (so that 8 codes will
 * fit in it exactly).  When the buffer fills up empty it and start over.
 */

static void
putcode(code, t)		/* output a code */
	int             code;	/* code to output */
	FILE           *t;	/* where to put it */
{
	int             r_off = offset;	/* right offset */
	int             bits = n_bits;	/* bits to go */
	unsigned char  *bp = buf;	/* buffer pointer */
	int             n;	/* index */
	register int	ztmp;

	if (code >= 0) {	/* if a real code *//* Get to the first byte. */
		bp += (r_off >> 3);
		r_off &= 7;

		/*
		 * Since code is always >= 8 bits, only need to mask the
		 * first hunk on the left. 
		 */
		ztmp = (code << r_off) & lmask[r_off];
		*bp = (*bp & rmask[r_off]) | ztmp;
		bp++;
		bits -= (8 - r_off);
		code >>= (8 - r_off);

		/* Get any 8 bit parts in the middle (<=1 for up to 16 bits). */
		if (bits >= 8) {
			*bp++ = code;
			code >>= 8;
			bits -= 8;
		}
		/* Last bits. */
		if (bits)
			*bp = code;

		offset += n_bits;

		if (offset == (n_bits << 3)) {
			bp = buf;
			bits = n_bits;
			bytes_out += bits;
			do
				putc_pak(*bp++, t);
			while (--bits);
			offset = 0;
		}
		/*
		 * If the next entry is going to be too big for the code
		 * size, then increase it, if possible. 
		 */
		if (free_ent > maxcode || clear_flg > 0) {	/* Write the whole
								 * buffer, because the
								 * input side won't
								 * discover the size
								 * increase until after
								 * it has read it. */
			if (offset > 0) {
				bp = buf;	/* reset pointer for writing */
				bytes_out += n = n_bits;
				while (n--)
					putc_pak(*bp++, t);
			}
			offset = 0;

			if (clear_flg) {	/* reset if clearing */
				maxcode = MAXCODE(n_bits = INIT_BITS);
				clear_flg = 0;
			} else {/* else use more bits */
				n_bits++;
				if (n_bits == BITS)
					maxcode = maxcodemax;
				else
					maxcode = MAXCODE(n_bits);
			}
		}
	} else {		/* dump the buffer on EOF */
		bytes_out += n = (offset + 7) / 8;

		if (offset > 0)
			while (n--)
				putc_pak(*bp++, t);
		offset = 0;
	}
}

/*****************************************************************
 *
 * Read one code from the standard input.  If EOF, return -1.
 * Inputs:
 *      cmpin
 * Outputs:
 *      code or -1 is returned.
 */

static int
getcode(f)			/* get a code */
	FILE           *f;	/* file to get from */
{
	int             code;
	static int      offset = 0, size = 0;
	int             r_off, bits;
	unsigned char  *bp = buf;

	if (clear_flg > 0 || offset >= size || free_ent > maxcode) {
		/* If the next entry will be too big for the current code
		 * size, then we must increase the size. This implies reading
		 * a new buffer full, too. */
		if (free_ent > maxcode) {
			n_bits++;
			if (n_bits == BITS)
				maxcode = maxcodemax;	/* won't get any bigger
							 * now */
			else
				maxcode = MAXCODE(n_bits);
		}
		if (clear_flg > 0) {
			maxcode = MAXCODE(n_bits = INIT_BITS);
			clear_flg = 0;
		}
		for (size = 0; size < n_bits; size++) {
			if ((code = getc_unp(f)) == EOF)
				break;
			else
				buf[size] = code;
		}
		if (size <= 0)
			return -1;	/* end of file */

		offset = 0;
		/* Round size down to integral number of codes */
		size = (size << 3) - (n_bits - 1);
	}
	r_off = offset;
	bits = n_bits;

	/*
	 * Get to the first byte. 
	 */
	bp += (r_off >> 3);
	r_off &= 7;

	/* Get first part (low order bits) */
	code = (*bp++ >> r_off);
	bits -= 8 - r_off;
	r_off = 8 - r_off;	/* now, offset into code word */

	/* Get any 8 bit parts in the middle (<=1 for up to 16 bits). */
	if (bits >= 8) {
		code |= *bp++ << r_off;
		r_off += 8;
		bits -= 8;
	}
	/* high order bits. */
	code |= (*bp & rmask[bits]) << r_off;
	offset += n_bits;

	return code;
}

/*
 * compress a file
 *
 * Algorithm:  use open addressing double hashing (no chaining) on the
 * prefix code / next character combination.  We do a variant of Knuth's
 * algorithm D (vol. 3, sec. 6.4) along with G. Knott's relatively-prime
 * secondary probe.  Here, the modular division first probe is gives way
 * to a faster exclusive-or manipulation.  Also do block compression with
 * an adaptive reset, where the code table is cleared when the compression
 * ratio decreases, but after the table fills.  The variable-length output
 * codes are re-sized at this point, and a special CLEAR code is generated
 * for the decompressor.
 */

void
sqinit_cm()			/* initialize for compression */
{
	offset = 0;
	bytes_out = 0;
	clear_flg = 0;
	ratio = 0;
	in_count = 1;
	checkpoint = CHECK_GAP;
	maxcode = MAXCODE(n_bits = INIT_BITS);
	free_ent = FIRST;
	setmem(htab, HSIZE * sizeof(long), 0xff);
	n_bits = INIT_BITS;	/* set starting code size */

	firstcmp = 1;		/* next byte will be first */
}

void
sqputc_cm(c, t)			/* compress a character */
	unsigned char   c;	/* character to compress */
	FILE           *t;	/* where to put it */
{
	static long     fcode;
	static int      hshift;
	int             i;
	int             disp;

	if (firstcmp) {		/* special case for first byte */
		ent = c;	/* remember first byte */

		hshift = 0;
		for (fcode = (long) HSIZE; fcode < 65536L; fcode *= 2L)
			hshift++;
		hshift = 8 - hshift;	/* set hash code range bund */

		firstcmp = 0;	/* no longer first */
		return;
	}
	in_count++;
	fcode = (long) (((long) c << BITS) + ent);
	i = (c << hshift) ^ ent;/* xor hashing */

	if (htab[i] == fcode) {
		ent = codetab[i];
		return;
	} else if (htab[i] < 0)	/* empty slot */
		goto nomatch;
	disp = HSIZE - i;	/* secondary hash (after G.Knott) */
	if (i == 0)
		disp = 1;

probe:
	if ((i -= disp) < 0)
		i += HSIZE;

	if (htab[i] == fcode) {
		ent = codetab[i];
		return;
	}
	if (htab[i] > 0)
		goto probe;

nomatch:
	putcode(ent, t);
	ent = c;
	if (free_ent < maxcodemax) {
		codetab[i] = free_ent++;	/* code -> hashtable */
		htab[i] = fcode;
	} else if ((long) in_count >= checkpoint)
		cl_block(t);
}

long 
sqpred_cm(t)			/* finish compressing a file */
	FILE           *t;	/* where to put it */
{
	putcode(ent, t);	/* put out the final code */
	putcode(-1, t);		/* tell output we are done */

	return bytes_out;	/* say how big it got */
}

/*
 * Decompress a file.  This routine adapts to the codes in the file
 * building the string table on-the-fly; requiring no table to be stored
 * in the compressed file.  The tables used herein are shared with those of
 * the compress() routine.  See the definitions above.
 */

void
sqdecomp(f, t)			/* decompress a file */
	FILE           *f;	/* file to read codes from */
	FILE           *t;	/* file to write text to */
{
	unsigned char  *stackp;
	int             finchar;
	int             code, oldcode, incode;

	n_bits = INIT_BITS;	/* set starting code size */
	clear_flg = 0;

	/*
	 * As above, initialize the first 256 entries in the table. 
	 */
	maxcode = MAXCODE(n_bits = INIT_BITS);
	for (code = 255; code >= 0; code--) {
		prefix[code] = 0;
		suffix[code] = (unsigned char) code;
	}
	free_ent = FIRST;

	finchar = oldcode = getcode(f);
	if (oldcode == -1)	/* EOF already? */
		return;		/* Get out of here */
	putc_unp((char) finchar, t);	/* first code must be 8 bits=char */
	stackp = stack;

	while ((code = getcode(f)) > -1) {
		if (code == CLEAR) {
			for (code = 255; code >= 0; code--)
				prefix[code] = 0;
			clear_flg = 1;
			free_ent = FIRST - 1;
			if ((code = getcode(f)) == -1)	/* O, untimely death! */
				break;
		}
		incode = code;
		/*
		 * Special case for KwKwK string. 
		 */
		if (code >= free_ent) {
			if (code > free_ent) {
				if (warn) {
					printf("Corrupted compressed file.\n");
					printf("Invalid code %d when max is %d.\n",
						code, free_ent);
				}
				nerrs++;
				return;
			}
			*stackp++ = finchar;
			code = oldcode;
		}
		/*
		 * Generate output characters in reverse order 
		 */
		while (code >= 256) {
			*stackp++ = suffix[code];
			code = prefix[code];
		}
		*stackp++ = finchar = suffix[code];

		/*
		 * And put them out in forward order 
		 */
		do
			putc_unp(*--stackp, t);
		while (stackp > stack);

		/*
		 * Generate the new entry. 
		 */
		if ((code = free_ent) < maxcodemax) {
			prefix[code] = (unsigned short) oldcode;
			suffix[code] = finchar;
			free_ent = code + 1;
		}
		/*
		 * Remember previous code. 
		 */
		oldcode = incode;
	}
}
