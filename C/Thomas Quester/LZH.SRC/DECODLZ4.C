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

/********** Larc-Decompression **********/

#define N		4096	/* buffer size */
#define F		18	/* lookahead buffer size */
#define THRESHOLD	2
#define NIL	N	/* leaf of tree */
#define FOLD		18   /* upper limit for match_length */

typedef unsigned char uchar;

from unsigned char  text_buf[N + F - 1];
unsigned long 	    printcount;

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
#ifdef _shell_
			setcrc(c);
			if (done-- == 0) {
			  if (!flg_n) putchar('*'); done=N;}
#endif
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


