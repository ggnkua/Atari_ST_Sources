/**************************************************************
	lzhuf.c
	written by Haruyasu Yoshizaki 11/20/1988
	some minor changes 4/6/1989
	comments translated by Haruhiko Okumura 4/7/1989

	reinserted with modifications into 'lharc.c'
	by J. Moeller 1/30/1990
**************************************************************/

#define _hufst_ 
#ifdef _hufst_
  #define from extern
#else
  #define from
#endif	  
#ifndef __TOS__
#error Please try assembling 'lzhuf.asm'!
#endif

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define RDERR		13
#define WTERR		14
#define MAXBLK		64

extern FILE *infile, *outfile;
extern char *infname, *outfname;
extern long textsize, codesize;
extern unsigned crc, crctbl [];
extern unsigned blkcnt;
extern unsigned char flg_n;
extern long blocksize;

extern void error (int errcode, char *p);

#define setcrc(ch) (crc = (crc >> 8) ^ crctbl [(crc ^ (ch)) & 0xff])
#ifndef _hufst_
int crc_getc (register FILE *stream)
{
	register int ch;

	if ((ch = getc (stream)) != EOF)
		setcrc (ch);

	return ch;
}
#else
 extern int crc_getc(register FILE *stream);
#endif

/********** LZSS compression **********/

#define N		4096	/* buffer size */
#define F		60	/* lookahead buffer size */
#define THRESHOLD	2
#define NIL	N	/* leaf of tree */
#define FOLD		18   /* upper limit for match_length */

from unsigned char	 text_buf[N + F - 1];
from int		 match_position, match_length,
			 lson[N + 1], rson[N + 257], dad[N + 1];

void InitTree(void)  /* initialize trees */
{
register	int  i, *rsonp, *dadp;

	rsonp=&rson[N+1];
	for (i = N + 1; i <= N + 256; i++)
		*rsonp++ = 2*NIL;		   /* root */
	dadp=dad;
	for (i = 0; i < N; i++)
		*dadp++ = 2*NIL;		   /* node */
}

#ifndef _hufst_
void InsertNode(int r)	/* insert to tree */
{
register	int  i, p, cmp;
	unsigned char  *key;
	unsigned c;

	cmp = 1;
	key = &text_buf[r];
	p = N + 1 + key[0];
	rson[r] = lson[r] = NIL;
	match_length = 0;
	for ( ; ; ) {
		if (cmp >= 0) {
			if (rson[p] != NIL)
				p = rson[p];
			else {
				rson[p] = r;
				dad[r] = p;
				return;
			}
		} else {
			if (lson[p] != NIL)
				p = lson[p];
			else {
				lson[p] = r;
				dad[r] = p;
				return;
			}
		}
		for (i = 1; i < F; i++)
			if ((cmp = key[i] - text_buf[p + i]) != 0)
				break;
		if (i > THRESHOLD) {
			if (i > match_length) {
				match_position = ((r - p) & (N - 1)) - 1;
				if ((match_length = i) >= F)
					break;
			}
			if (i == match_length) {
				if ((c = ((r - p) & (N - 1)) - 1) < match_position) {
					match_position = c;
				}
			}
		}
	}
	dad[r] = dad[p];
	lson[r] = lson[p];
	rson[r] = rson[p];
	dad[lson[p]] = r;
	dad[rson[p]] = r;
	if (rson[dad[p]] == p)
		rson[dad[p]] = r;
	else
		lson[dad[p]] = r;
	dad[p] = NIL;  /* remove p */
}

void DeleteNode(int p)	/* remove from tree */
{
register	int  q;

	if (dad[p] == NIL)
		return; 		/* not registered */
	if (rson[p] == NIL)
		q = lson[p];
	else
	if (lson[p] == NIL)
		q = rson[p];
	else {
		q = lson[p];
		if (rson[q] != NIL) {
			do {
				q = rson[q];
			} while (rson[q] != NIL);
			rson[dad[q]] = lson[q];
			dad[lson[q]] = dad[q];
			lson[q] = lson[p];
			dad[lson[p]] = q;
		}
		rson[q] = rson[p];
		dad[rson[p]] = q;
	}
	dad[q] = dad[p];
	if (rson[dad[p]] == p)
		rson[dad[p]] = q;
	else
		lson[dad[p]] = q;
	dad[p] = NIL;
}
#else
  extern void DeleteNode(int p);
#endif
/* Huffman coding */

#define N_CHAR		(256 - THRESHOLD + F)
				/* kinds of characters (character code = 0..N_CHAR-1) */
#define T		(N_CHAR * 2 - 1)	/* size of table */
#define R		(T - 1) 		/* position of root */
#define MAX_FREQ	0x8000		/* updates tree when the */
					/* root frequency comes to this value. */
typedef unsigned char uchar;


/* table for encoding and decoding the upper 6 bits of position */

/* for encoding */
uchar p_len[64] = {
	0x03, 0x04, 0x04, 0x04, 0x05, 0x05, 0x05, 0x05,
	0x05, 0x05, 0x05, 0x05, 0x06, 0x06, 0x06, 0x06,
	0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06,
	0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07,
	0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07,
	0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07,
	0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08,
	0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08
};

uchar p_code[64] = {
	0x00, 0x20, 0x30, 0x40, 0x50, 0x58, 0x60, 0x68,
	0x70, 0x78, 0x80, 0x88, 0x90, 0x94, 0x98, 0x9C,
	0xA0, 0xA4, 0xA8, 0xAC, 0xB0, 0xB4, 0xB8, 0xBC,
	0xC0, 0xC2, 0xC4, 0xC6, 0xC8, 0xCA, 0xCC, 0xCE,
	0xD0, 0xD2, 0xD4, 0xD6, 0xD8, 0xDA, 0xDC, 0xDE,
	0xE0, 0xE2, 0xE4, 0xE6, 0xE8, 0xEA, 0xEC, 0xEE,
	0xF0, 0xF1, 0xF2, 0xF3, 0xF4, 0xF5, 0xF6, 0xF7,
	0xF8, 0xF9, 0xFA, 0xFB, 0xFC, 0xFD, 0xFE, 0xFF
};

/* for decoding */
uchar d_code[256] = {
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01,
	0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01,
	0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02,
	0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02,
	0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03,
	0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03,
	0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04,
	0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05,
	0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06,
	0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07,
	0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08,
	0x09, 0x09, 0x09, 0x09, 0x09, 0x09, 0x09, 0x09,
	0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A,
	0x0B, 0x0B, 0x0B, 0x0B, 0x0B, 0x0B, 0x0B, 0x0B,
	0x0C, 0x0C, 0x0C, 0x0C, 0x0D, 0x0D, 0x0D, 0x0D,
	0x0E, 0x0E, 0x0E, 0x0E, 0x0F, 0x0F, 0x0F, 0x0F,
	0x10, 0x10, 0x10, 0x10, 0x11, 0x11, 0x11, 0x11,
	0x12, 0x12, 0x12, 0x12, 0x13, 0x13, 0x13, 0x13,
	0x14, 0x14, 0x14, 0x14, 0x15, 0x15, 0x15, 0x15,
	0x16, 0x16, 0x16, 0x16, 0x17, 0x17, 0x17, 0x17,
	0x18, 0x18, 0x19, 0x19, 0x1A, 0x1A, 0x1B, 0x1B,
	0x1C, 0x1C, 0x1D, 0x1D, 0x1E, 0x1E, 0x1F, 0x1F,
	0x20, 0x20, 0x21, 0x21, 0x22, 0x22, 0x23, 0x23,
	0x24, 0x24, 0x25, 0x25, 0x26, 0x26, 0x27, 0x27,
	0x28, 0x28, 0x29, 0x29, 0x2A, 0x2A, 0x2B, 0x2B,
	0x2C, 0x2C, 0x2D, 0x2D, 0x2E, 0x2E, 0x2F, 0x2F,
	0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37,
	0x38, 0x39, 0x3A, 0x3B, 0x3C, 0x3D, 0x3E, 0x3F,
};

uchar d_len[256] = {
	0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03,
	0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03,
	0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03,
	0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03,
	0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04,
	0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04,
	0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04,
	0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04,
	0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04,
	0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04,
	0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05,
	0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05,
	0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05,
	0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05,
	0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05,
	0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05,
	0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05,
	0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05,
	0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06,
	0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06,
	0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06,
	0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06,
	0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06,
	0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06,
	0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07,
	0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07,
	0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07,
	0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07,
	0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07,
	0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07,
	0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08,
	0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08,
};



from unsigned freq[T + 1];   /* frequency table */

from int prnt[T + N_CHAR];   /* pointers to parent nodes, except for the */
			/* elements [T..T + N_CHAR - 1] which are used to get */
			/* the positions of leaves corresponding to the codes. */

from int son[T];     /* pointers to child nodes (son[], son[] + 1) */

from unsigned getbuf;
from uchar getlen;

#ifndef _hufst_
int GetBit(void)	/* get one bit */
{
register	int i;

	while (getlen <= 8) {
		if ((i = getc(infile)) < 0) i = 0;
		getbuf |= i << (8 - getlen);
		getlen += 8;
	}
	i = getbuf;
	getbuf <<= 1;
	getlen--;
	return (i < 0);
}
#else
  int GetBit(void);
#endif

int GetByte(void)	/* get one byte */
{
register	int i;

	while (getlen <= 8) {
		if ((i = getc(infile)) < 0) i = 0;
		getbuf |= i << (8 - getlen);
		getlen += 8;
	}
	i = getbuf;
	getbuf <<= 8;
	getlen -= 8;
	return (unsigned) i >> 8;
}

extern unsigned putbuf;
extern uchar putlen;

#ifndef _hufst_
void Putcode(register int l, register unsigned c)	/* output c bits of code */
{
	putbuf |= c >> putlen;
	if ((putlen += l) >= 8) {
		putc(putbuf >> 8, outfile);
		if ((putlen -= 8) >= 8) {
			putc(putbuf, outfile);
			codesize += 2;
			putlen -= 8;
			putbuf = c << (l - putlen);
		} else {
			putbuf <<= 8;
			codesize++;
		}
	}
}
#else
 void Putcode(register int l, register unsigned c);
#endif

/* initialization of tree */

#ifndef _hufst_
void StartHuff(void)
{
register	int i, j, iT, *sonp, *prntp;
register unsigned *freqp;

	freqp=freq;
	sonp=son;
	prntp=&prnt[T];
	iT=T;
	for (i = 0; i < N_CHAR; i++) {
		*freqp++ = 1;
		*sonp++  = iT++;
		*prntp++ = i;
	}
	i = 0; j = N_CHAR;
	freqp=freq;
	sonp=&son[N_CHAR];
	prntp=prnt;
	while (j <= R) {
		freq[j] = *freqp++ + *freqp++;
		*sonp++ = i;
		*prntp++ = *prntp++ = j;
		i += 2; j++;
	}
	freq[T] = 0xffff;
	prnt[R] = 0;
}
/* reconstruction of tree */

void reconst(void)
{
register	int i, j, k;
	unsigned f, l;

	/* collect leaf nodes in the first half of the table */
	/* and replace the freq by (freq + 1) / 2. */
	j = 0;
	for (i = 0; i < T; i++) {
		if (son[i] >= T) {
			freq[j] = (freq[i] + 1) / 2;
			son[j] = son[i];
			j++;
		}
	}
	/* begin constructing tree by connecting sons */
	for (i = 0, j = N_CHAR; j < T; i += 2, j++) {
		k = i + 1;
		f = freq[j] = freq[i] + freq[k];
		for (k = j - 1; f < freq[k]; k--);
		k++;
		l = (j - k) * 2;
		memmove(&freq[k + 1], &freq[k], l);
		freq[k] = f;
		memmove(&son[k + 1], &son[k], l);
		son[k] = i;
	}
	/* connect prnt */
	for (i = 0; i < T; i++) {
		if ((k = son[i]) >= T) {
			prnt[k] = i;
		} else {
			prnt[k] = prnt[k + 1] = i;
		}
	}
}


/* increment frequency of given code by one, and update tree */

void update(int c)
{
register	int i, j, k, l;

	if (freq[R] == MAX_FREQ) {
		reconst();
	}
	c = prnt[c + T];
	do {
		k = ++freq[c];

		/* if the order is disturbed, exchange nodes */
		if (k > freq[l = c + 1]) {
			while (k > freq[++l]);
			l--;
			freq[c] = freq[l];
			freq[l] = k;

			i = son[c];
			prnt[i] = l;
			if (i < T) prnt[i + 1] = l;

			j = son[l];
			son[l] = i;

			prnt[j] = c;
			if (j < T) prnt[j + 1] = c;
			son[c] = j;

			c = l;
		}
	} while ((c = prnt[c]) != 0);	/* repeat up to root */
}

void EncodeChar(unsigned c)
{
register	unsigned i;
register	int j, k;

	i = 0;
	j = 0;
	k = prnt[c + T];

	/* travel from leaf to root */
	do {
		i >>= 1;

		/* if node's address is odd-numbered, choose bigger brother node */
		if (k & 1) i += 0x8000;

		j++;
	} while ((k = prnt[k]) != R);
	Putcode(j, i);
	update(c);
}

void EncodePosition(unsigned c)
{
register	unsigned i;

	/* output upper 6 bits by table lookup */
	i = c >> 6;
	Putcode(p_len[i], (unsigned)p_code[i] << 8);

	/* output lower 6 bits verbatim */
	Putcode(6, (c & 0x3f) << 10);
}
#endif


void EncodeEnd(void)
{
	if (putlen) {
		putc(putbuf >> 8, outfile);
		codesize++;
	}
}
#ifndef _hufst_
int DecodeChar(void)
{
register	unsigned c;

	c = son[R];

	/* travel from root to leaf, */
	/* choosing the smaller child node (son[]) if the read bit is 0, */
	/* the bigger (son[]+1} if 1 */
	while (c < T) {
		c += GetBit();
		c = son[c];
	}
	c -= T;
	update(c);
	return c;
}

int DecodePosition(void)
{
register	unsigned i, j, c;

	/* recover upper 6 bits from table */
	i = GetByte();
	c = (unsigned)d_code[i] << 6;
	j = d_len[i];

	/* read lower 6 bits verbatim */
	j -= 2;
	while (j--) {
		i = (i << 1) + GetBit();
	}
	return c | (i & 0x3f);
}
#else
 int DecodeChar(void);
 int DecodePosition(void);
 extern InsertNode(int r);
#endif

/* compression */

#ifndef _hufst_
void Encode(void)  /* compression */
{
register int i, r, s, c;
	int len, last_match_length;
	long printcount,
		 printsize;

	if (textsize == 0)
		return;
	putbuf = putlen = 0;
	printsize = textsize;
	printcount = printsize < blocksize ? printsize : blocksize;
	if (blkcnt > MAXBLK)
		blkcnt = MAXBLK;
	rewind(infile);
	textsize = 0;			/* rewind and re-read */
	StartHuff();
	InitTree();
	s = 0;
	r = N - F;
	for (i = s; i < r; i++)
		text_buf[i] = ' ';
	for (len = 0; len < F && (c = crc_getc(infile)) != EOF; len++)
		text_buf[r + len] = c;
	textsize = len;
	for (i = 1; i <= F; i++)
		InsertNode(r - i);
	InsertNode(r);
	do {
		if (match_length > len)
			match_length = len;
		if (match_length <= THRESHOLD) {
			match_length = 1;
			EncodeChar(text_buf[r]);
		} else {
			EncodeChar(255 - THRESHOLD + match_length);
			EncodePosition(match_position);
		}
		last_match_length = match_length;
		for (i = 0; i < last_match_length &&
				(c = crc_getc(infile)) != EOF; i++) {
			DeleteNode(s);
			text_buf[s] = c;
			if (s < F - 1)
				text_buf[s + N] = c;
			s = (s + 1) & (N - 1);
			r = (r + 1) & (N - 1);
			InsertNode(r);
		}
		if ((textsize += i) >= printcount && i > 0) {
			if (!flg_n) {
				if (blkcnt > 0) {
					putc ('*', stderr);
					blkcnt--;
				}
				printcount += blocksize;
				if (printcount > printsize)
					printcount = printsize;
			}
			if (ferror (outfile))
				break;
		}
		while (i++ < last_match_length) {
			DeleteNode(s);
			s = (s + 1) & (N - 1);
			r = (r + 1) & (N - 1);
			if (--len) InsertNode(r);
		}
	} while (len > 0);
	EncodeEnd();
	if (ferror (outfile)) {
		error (WTERR, outfname);
	}
}
#else
  void Encode(void);
#endif

#ifndef _hufst_
void Decode(void)  /* recover */
{
register int i, j, k, r, c;
	unsigned long int count;
	long printcount;

	if (textsize == 0)
		return;
	getbuf = getlen = 0;
	printcount = textsize < blocksize ? textsize : blocksize;
	if (blkcnt > MAXBLK)
		blkcnt = MAXBLK;
	StartHuff();
	for (i = 0; i < N - F; i++)
		text_buf[i] = ' ';
	r = N - F;
	for (count = 0; count < textsize; ) {
		c = DecodeChar();
		if (c < 256) {
			setcrc (c);
			if (outfile != NULL)
				putc (c, outfile);
			text_buf[r++] = c;
			r &= (N - 1);
			count++;
		} else {
			i = (r - DecodePosition() - 1) & (N - 1);
			j = c - 255 + THRESHOLD;
			for (k = 0; k < j; k++) {
				c = text_buf[(i + k) & (N - 1)];
				setcrc (c);
				if (outfile != NULL)
					putc (c, outfile);
				text_buf[r++] = c;
				r &= (N - 1);
				count++;
			}
		}
		if (count >= printcount) {
			if (!flg_n) {
				if (blkcnt > 0) {
					putc ('*', stderr);
					blkcnt--;
				}
				printcount += blocksize;
				if (printcount > textsize)
					printcount = textsize;
			}
			if (outfile != NULL && ferror (outfile))
				break;
		}
	}
	if (!flg_n && blkcnt > 0)
		putc ('*', stderr);
	if (outfile != NULL && ferror (outfile)) {
		error (WTERR, outfname);
	}
}
#else
  extern void Decode(void);
#endif

#define N		 4096	/* size of ring buffer */
#define F		   18	/* upper limit for match_length */
#define THRESHOLD	2   /* encode string into position and length
						   if match_length is greater than this */
#define NIL			N	/* index for root of binary search trees */

unsigned long printcount;

void InitTreeOld(void)	/* initialize trees */
{
	int  i;

	/* For i = 0 to N - 1, rson[i] and lson[i] will be the right and
	   left children of node i.  These nodes need not be initialized.
	   Also, dad[i] is the parent of node i.  These are initialized to
	   NIL (= N), which stands for 'not used.'
	   For i = 0 to 255, rson[N + i + 1] is the root of the tree
	   for strings that begin with character i.  These are initialized
	   to NIL.  Note there are 256 trees. */

#ifndef _hufst_
	for (i = N + 1; i <= N + 256; i++) rson[i] = NIL;
	for (i = 0; i < N; i++) dad[i] = NIL;
#else
	for (i = N + 1; i <= N + 256; i++) rson[i] = 2*NIL;
	for (i = 0; i < N; i++) dad[i] = 2*NIL;
#endif		      
}

void DecodeOld(void)	   /* Just the reverse of Encode(). */
{
	register int  i, j, k, r, c;
	register unsigned int  flags;
	long int todo=codesize,done=N;
	for (i = 0; i < N - F; i++) text_buf[i] = ' ';
	r = N - F;  flags = 0;
	for ( ; ; ) {
		if (((flags >>= 1) & 256) == 0) {
			c = getc(infile);
			if (todo-- == 0) break; 
			flags = c | 0xff00;		
				/* uses higher byte cleverly */
		}							/* to count eight */
		if (flags & 1) {
			if (todo-- == 0) break; 
			c = getc(infile);
			if (outfile !=NULL) putc(c, outfile);  text_buf[r++] = c; 
			setcrc(c);
			if (done-- == 0) {
			  if (!flg_n) putchar('*'); done=N;}
			r &= (N - 1);
		} else {
			if (todo-- == 0) break; 
			i = getc(infile);
			if (todo-- == 0) break; 
			j = getc(infile);
			i |= ((j & 0xf0) << 4);  
			j = (j & 0x0f) + THRESHOLD;
			for (k = 0; k <= j; k++) {
				c = text_buf[(i + k) & (N - 1)];
				if (outfile !=NULL) putc(c, outfile); 
				setcrc(c);
				text_buf[r++] = c;  r &= (N - 1);
				if (done-- == 0) {
				   if (!flg_n) putchar('*'); done=N;}
			}
		}
	}
}


