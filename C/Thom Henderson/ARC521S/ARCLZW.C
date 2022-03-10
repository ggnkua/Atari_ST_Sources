/*
 * $Header: arclzw.c,v 1.6 88/07/31 18:49:49 hyc Exp $
 */

/*
 * ARC - Archive utility - ARCLZW
 * 
 * Version 2.03, created on 10/24/86 at 11:46:22
 * 
 * (C) COPYRIGHT 1985,86 by System Enhancement Associates; ALL RIGHTS RESERVED
 * 
 * By:  Thom Henderson
 * 
 * Description: This file contains the routines used to implement Lempel-Zev
 * data compression, which calls for building a coding table on the fly.
 * This form of compression is especially good for encoding files which
 * contain repeated strings, and can often give dramatic improvements over
 * traditional Huffman SQueezing.
 * 
 * Language: Computer Innovations Optimizing C86
 * 
 * Programming notes: In this section I am drawing heavily on the COMPRESS
 * program from UNIX.  The basic method is taken from "A Technique for High
 * Performance Data Compression", Terry A. Welch, IEEE Computer Vol 17, No 6
 * (June 1984), pp 8-19.  Also see "Knuth's Fundamental Algorithms", Donald
 * Knuth, Vol 3, Section 6.4.
 * 
 * As best as I can tell, this method works by tracing down a hash table of code
 * strings where each entry has the property:
 * 
 * if <string> <char> is in the table then <string> is in the table.
 */
#include <stdio.h>
#include "arc.h"

void	putc_pak(), abort(), putc_ncr();
int	getc_unp();
#if	MSDOS
char	*setmem();
#else
#ifndef __STDC__
char	*memset();
#endif
#endif

static void	putcode();
/* definitions for older style crunching */

#define FALSE    0
#define TRUE     !FALSE
#define TABSIZE  4096
#define NO_PRED  0xFFFF
#define EMPTY    0xFFFF
#define NOT_FND  0xFFFF

static unsigned short inbuf;	/* partial input code storage */
static int      sp;		/* current stack pointer */

struct entry {		/* string table entry format */
	char            used;	/* true when this entry is in use */
	unsigned char   follower;	/* char following string */
	unsigned short  next;	/* ptr to next in collision list */
	unsigned short  predecessor;	/* code for preceeding string */
};            /* string_tab[TABSIZE];	   the code string table */


/* definitions for the new dynamic Lempel-Zev crunching */

#define BITS   12		/* maximum bits per code */
#define HSIZE  5003		/* 80% occupancy */
#define INIT_BITS 9		/* initial number of bits/code */

static int      n_bits;		/* number of bits/code */
static int      maxcode;	/* maximum code, given n_bits */
#define MAXCODE(n)      ((1<<(n)) - 1)	/* maximum code calculation */
static int      maxcodemax = 1 << BITS;	/* largest possible code (+1) */

static char     buf[BITS];	/* input/output buffer */

static unsigned char lmask[9] =	/* left side masks */
{
 0xff, 0xfe, 0xfc, 0xf8, 0xf0, 0xe0, 0xc0, 0x80, 0x00
};
static unsigned char rmask[9] =	/* right side masks */
{
 0x00, 0x01, 0x03, 0x07, 0x0f, 0x1f, 0x3f, 0x7f, 0xff
};

static int      offset;		/* byte offset for code output */
static long     in_count;	/* length of input */
static long     bytes_out;	/* length of compressed output */
static long     bytes_ref;	/* output quality reference */
static long     bytes_last;	/* output size at last checkpoint */
static unsigned short ent;

/*
 * To save much memory (which we badly need at this point), we overlay the
 * table used by the previous version of Lempel-Zev with those used by the
 * new version.  Since no two of these routines will be used together, we can
 * safely do this.
 */

extern long     htab[HSIZE];		/* hash code table   (crunch) */
extern unsigned short codetab[HSIZE];	/* string code table (crunch) */
static struct	entry *string_tab=(struct entry *)htab;	/* old crunch string table */

static unsigned short *prefix=codetab;	/* prefix code table (uncrunch) */
static unsigned char *suffix=(unsigned char *)htab;	/* suffix table (uncrunch) */

static int      free_ent;	/* first unused entry */
static int      firstcmp;	/* true at start of compression */
extern unsigned char stack[HSIZE];	/* local push/pop stack */

/*
 * block compression parameters -- after all codes are used up, and
 * compression rate changes, start over.
 */

static int      clear_flg;
#define CHECK_GAP 2048		/* ratio check interval */
static long     checkpoint;
void            upd_tab();

/*
 * the next two codes should not be changed lightly, as they must not lie
 * within the contiguous general code space.
 */
#define FIRST   257		/* first free entry */
#define CLEAR   256		/* table clear output code */

/*
 * The cl_block() routine is called at each checkpoint to determine if
 * compression would likely improve by resetting the code table.  The method
 * chosen to determine this is based on empirical observation that, in
 * general, every 2k of input data should compress at least as well as the
 * first 2k of input.
 */

static          void
cl_block(t)			/* table clear for block compress */
	FILE           *t;	/* our output file */
{
	checkpoint = in_count + CHECK_GAP;

	if (bytes_ref) {
		if (bytes_out - bytes_last > bytes_ref) {
			setmem(htab, HSIZE * sizeof(long), 0xff);
			free_ent = FIRST;
			clear_flg = 1;
			putcode(CLEAR, t);
			bytes_ref = 0;
		}
	} else
		bytes_ref = bytes_out - bytes_last;

	bytes_last = bytes_out;	/* remember where we were */
}

/*****************************************************************
 *
 * Output a given code.
 * Inputs:
 *      code:   A n_bits-bit integer.  If == -1, then EOF.  This assumes
 *              that n_bits =< (LONG)wordsize - 1.
 * Outputs:
 *      Outputs code to the file.
 * Assumptions:
 *      Chars are 8 bits long.
 * Algorithm:
 *      Maintain a BITS character long buffer (so that 8 codes will
 * fit in it exactly).  When the buffer fills up empty it and start over.
 */

static          void
putcode(code, t)		/* output a code */
	int             code;	/* code to output */
	FILE           *t;	/* where to put it */
{
	int             r_off = offset;	/* right offset */
	int             bits = n_bits;	/* bits to go */
	char           *bp = buf;	/* buffer pointer */
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
		if (free_ent > maxcode || clear_flg > 0) {
			/*
			 * Write the whole buffer, because the input side
			 * won't discover the size increase until after
			 * it has read it. 
			 */
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

static          int
getcode(f)			/* get a code */
	FILE           *f;	/* file to get from */
{
	int             code;
	static int      offset = 0, size = 0;
	int             r_off, bits;
	unsigned char  *bp = (unsigned char *) buf;

	if (clear_flg > 0 || offset >= size || free_ent > maxcode) {
		/*
		 * If the next entry will be too big for the current code
		 * size, then we must increase the size. This implies
		 * reading a new buffer full, too. 
		 */
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
				buf[size] = (char) code;
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

	return code & MAXCODE(BITS);
}

/*
 * compress a file
 * 
 * Algorithm:  use open addressing double hashing (no chaining) on the prefix
 * code / next character combination.  We do a variant of Knuth's algorithm D
 * (vol. 3, sec. 6.4) along with G. Knott's relatively-prime secondary probe.
 * Here, the modular division first probe is gives way to a faster
 * exclusive-or manipulation.  Also do block compression with an adaptive
 * reset, where the code table is cleared when the compression ratio
 * decreases, but after the table fills.  The variable-length output codes
 * are re-sized at this point, and a special CLEAR code is generated for the
 * decompressor.
 */

void
init_cm(t)			/* initialize for compression */
	FILE           *t;	/* where compressed file goes */
{
	offset = 0;
	bytes_out = bytes_last = 1;
	bytes_ref = 0;
	clear_flg = 0;
	in_count = 1;
	checkpoint = CHECK_GAP;
	maxcode = MAXCODE(n_bits = INIT_BITS);
	free_ent = FIRST;
	setmem(htab, HSIZE * sizeof(long), 0xff);
	n_bits = INIT_BITS;	/* set starting code size */

	putc_pak(BITS, t);	/* note our max code length */

	firstcmp = 1;		/* next byte will be first */
}

void
putc_cm(c, t)			/* compress a character */
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
		hshift = 8 - hshift;	/* set hash code range bound */

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
	}
	if (in_count >= checkpoint)
		cl_block(t);	/* check for adaptive reset */
}

long
pred_cm(t)			/* finish compressing a file */
	FILE           *t;	/* where to put it */
{
	putcode(ent, t);	/* put out the final code */
	putcode(-1, t);		/* tell output we are done */

	return bytes_out;	/* say how big it got */
}

/*
 * Decompress a file.  This routine adapts to the codes in the file building
 * the string table on-the-fly; requiring no table to be stored in the
 * compressed file.  The tables used herein are shared with those of the
 * compress() routine.  See the definitions above.
 */

void
decomp(f, t)			/* decompress a file */
	FILE           *f;	/* file to read codes from */
	FILE           *t;	/* file to write text to */
{
	unsigned char  *stackp;
	int             finchar;
	int             code, oldcode, incode;

	if ((code = getc_unp(f)) != BITS)
		abort("File packed with %d bits, I can only handle %d", code, BITS);

	n_bits = INIT_BITS;	/* set starting code size */
	clear_flg = 0;

	/*
	 * As above, initialize the first 256 entries in the table. 
	 */
	maxcode = MAXCODE(n_bits = INIT_BITS);
	setmem(prefix, 256 * sizeof(short), 0);	/* reset decode string table */
	for (code = 255; code >= 0; code--)
		suffix[code] = (unsigned char) code;

	free_ent = FIRST;

	finchar = oldcode = getcode(f);
	if (oldcode == -1)	/* EOF already? */
		return;		/* Get out of here */
	putc_ncr((unsigned char) finchar, t);	/* first code must be 8 bits=char */
	stackp = stack;

	while ((code = getcode(f)) > -1) {
		if (code == CLEAR) {	/* reset string table */
			setmem(prefix, 256 * sizeof(short), 0);
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
			putc_ncr(*--stackp, t);
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


/*************************************************************************
 * Please note how much trouble it can be to maintain upwards            *
 * compatibility.  All that follows is for the sole purpose of unpacking *
 * files which were packed using an older method.                        *
 *************************************************************************/


/*
 * The h() pointer points to the routine to use for calculating a hash value.
 * It is set in the init routines to point to either of oldh() or newh().
 * 
 * oldh() calculates a hash value by taking the middle twelve bits of the square
 * of the key.
 * 
 * newh() works somewhat differently, and was tried because it makes ARC about
 * 23% faster.  This approach was abandoned because dynamic Lempel-Zev
 * (above) works as well, and packs smaller also.  However, inadvertent
 * release of a developmental copy forces us to leave this in.
 */

static unsigned short(*h) ();	/* pointer to hash function */

static unsigned short
oldh(pred, foll)		/* old hash function */
	unsigned short  pred;	/* code for preceeding string */
	unsigned char   foll;	/* value of following char */
{
	long            local;	/* local hash value */

	local = ((pred + foll) | 0x0800) & 0xFFFF; /* create the hash key */
	local *= local;		/* square it */
	return (local >> 6) & 0x0FFF;	/* return the middle 12 bits */
}

static unsigned short
newh(pred, foll)		/* new hash function */
	unsigned short  pred;	/* code for preceeding string */
	unsigned char   foll;	/* value of following char */
{
	return (((pred + foll) & 0xFFFF) * 15073) & 0xFFF; /* faster hash */
}

/*
 * The eolist() function is used to trace down a list of entries with
 * duplicate keys until the last duplicate is found.
 */

static unsigned short
eolist(index)			/* find last duplicate */
	unsigned short  index;
{
	int             temp;

	while (temp = string_tab[index].next)	/* while more duplicates */
		index = temp;

	return index;
}

/*
 * The hash() routine is used to find a spot in the hash table for a new
 * entry.  It performs a "hash and linear probe" lookup, using h() to
 * calculate the starting hash value and eolist() to perform the linear
 * probe.  This routine DOES NOT detect a table full condition.  That MUST be
 * checked for elsewhere.
 */

static unsigned short
hash(pred, foll)		/* find spot in the string table */
	unsigned short  pred;	/* code for preceeding string */
	unsigned char   foll;	/* char following string */
{
	unsigned short  local, tempnext;	/* scratch storage */
	struct entry   *ep;	/* allows faster table handling */

	local = (*h) (pred, foll);	/* get initial hash value */

	if (!string_tab[local].used)	/* if that spot is free */
		return local;	/* then that's all we need */

	else {			/* else a collision has occured */
		local = eolist(local);	/* move to last duplicate */

		/*
		 * We must find an empty spot. We start looking 101 places
		 * down the table from the last duplicate. 
		 */

		tempnext = (local + 101) & 0x0FFF;
		ep = &string_tab[tempnext];	/* initialize pointer */

		while (ep->used) {	/* while empty spot not found */
			if (++tempnext == TABSIZE) {	/* if we are at the end */
				tempnext = 0;	/* wrap to beginning of table */
				ep = string_tab;
			} else
				++ep;	/* point to next element in table */
		}

		/*
		 * local still has the pointer to the last duplicate, while
		 * tempnext has the pointer to the spot we found.  We use
		 * this to maintain the chain of pointers to duplicates. 
		 */

		string_tab[local].next = tempnext;

		return tempnext;
	}
}

/*
 * The init_tab() routine is used to initialize our hash table. You realize,
 * of course, that "initialize" is a complete misnomer.
 */

static          void
init_tab()
{				/* set ground state in hash table */
	unsigned int    i;	/* table index */

	setmem((char *) string_tab, sizeof(string_tab), 0);

	for (i = 0; i < 256; i++)	/* list all single byte strings */
		upd_tab(NO_PRED, i);

	inbuf = EMPTY;		/* nothing is in our buffer */
}

/*
 * The upd_tab routine is used to add a new entry to the string table. As
 * previously stated, no checks are made to ensure that the table has any
 * room.  This must be done elsewhere.
 */

void
upd_tab(pred, foll)		/* add an entry to the table */
	unsigned short  pred;	/* code for preceeding string */
	unsigned short  foll;	/* character which follows string */
{
	struct entry   *ep;	/* pointer to current entry */

	/* calculate offset just once */

	ep = &string_tab[hash(pred, foll)];

	ep->used = TRUE;	/* this spot is now in use */
	ep->next = 0;		/* no duplicates after this yet */
	ep->predecessor = pred;	/* note code of preceeding string */
	ep->follower = foll;	/* note char after string */
}

/*
 * This algorithm encoded a file into twelve bit strings (three nybbles). The
 * gocode() routine is used to read these strings a byte (or two) at a time.
 */

static          int
gocode(fd)			/* read in a twelve bit code */
	FILE           *fd;	/* file to get code from */
{
	unsigned short  localbuf, returnval;
	int             temp;

	if (inbuf == EMPTY) {	/* if on a code boundary */
		if ((temp = getc_unp(fd)) == EOF)	/* get start of next
							 * code */
			return EOF;	/* pass back end of file status */
		localbuf = temp & 0xFF;	/* mask down to true byte value */
		if ((temp = getc_unp(fd)) == EOF)
			/* get end of code, * start of next */
			return EOF;	/* this should never happen */
		inbuf = temp & 0xFF;	/* mask down to true byte value */

		returnval = ((localbuf << 4) & 0xFF0) + ((inbuf >> 4) & 0x00F);
		inbuf &= 0x000F;/* leave partial code pending */
	} else {		/* buffer contains first nybble */
		if ((temp = getc_unp(fd)) == EOF)
			return EOF;
		localbuf = temp & 0xFF;

		returnval = localbuf + ((inbuf << 8) & 0xF00);
		inbuf = EMPTY;	/* note no hanging nybbles */
	}
	return returnval;	/* pass back assembled code */
}

static          void
push(c)				/* push char onto stack */
	int             c;	/* character to push */
{
	stack[sp] = ((char) c);	/* coerce integer into a char */

	if (++sp >= TABSIZE)
		abort("Stack overflow\n");
}

static          int
pop()
{				/* pop character from stack */
	if (sp > 0)
		return ((int) stack[--sp]);	/* leave ptr at next empty
						 * slot */

	else
		return EMPTY;
}

/***** LEMPEL-ZEV DECOMPRESSION *****/

static int      code_count;	/* needed to detect table full */
static int      firstc;		/* true only on first character */

void
init_ucr(new)			/* get set for uncrunching */
	int             new;	/* true to use new hash function */
{
	if (new)		/* set proper hash function */
		h = newh;
	else
		h = oldh;

	sp = 0;			/* clear out the stack */
	init_tab();		/* set up atomic code definitions */
	code_count = TABSIZE - 256;	/* note space left in table */
	firstc = 1;		/* true only on first code */
}

int
getc_ucr(f)			/* get next uncrunched byte */
	FILE           *f;	/* file containing crunched data */
{
	int             code, newcode;
	static int      oldcode, finchar;
	struct entry   *ep;	/* allows faster table handling */

	if (firstc) {		/* first code is always known */
		firstc = FALSE;	/* but next will not be first */
		oldcode = gocode(f);
		return finchar = string_tab[oldcode].follower;
	}
	if (!sp) {		/* if stack is empty */
		if ((code = newcode = gocode(f)) == EOF)
			return EOF;

		ep = &string_tab[code];	/* initialize pointer */

		if (!ep->used) {/* if code isn't known */
			code = oldcode;
			ep = &string_tab[code];	/* re-initialize pointer */
			push(finchar);
		}
		while (ep->predecessor != NO_PRED) {
			push(ep->follower);	/* decode string backwards */
			code = ep->predecessor;
			ep = &string_tab[code];
		}

		push(finchar = ep->follower);	/* save first character also */

		/*
		 * The above loop will terminate, one way or another, with
		 * string_tab[code].follower equal to the first character in
		 * the string. 
		 */

		if (code_count) {	/* if room left in string table */
			upd_tab(oldcode, finchar);
			--code_count;
		}
		oldcode = newcode;
	}
	return pop();		/* return saved character */
}
