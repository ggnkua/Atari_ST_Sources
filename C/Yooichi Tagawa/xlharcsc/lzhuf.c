/*----------------------------------------------------------------------*/
/*              lzhuf.c : Encoding/Decoding module for LHarc            */
/*                                                                      */
/*      LZSS Algorithm                  Haruhiko.Okumura                */
/*      Adaptic Huffman Encoding        1989.05.27  Haruyasu.Yoshizaki  */
/*                                                                      */
/*                                                                      */
/*      Modified for UNIX LHarc V0.01   1989.05.28  Y.Tagawa            */
/*      Modified for UNIX LHarc V0.02   1989.05.29  Y.Tagawa            */
/*      Modified for UNIX LHarc V0.03   1989.07.02  Y.Tagawa            */
/*----------------------------------------------------------------------*/

#include <stdio.h>
#ifdef atarist
#include <stdlib.h>
#include <stddef.h>
#include <string.h>
#include <unixlib.h>
#include <memory.h>
#endif

#ifndef SELFMAIN
#include "lhio.h"
#else
#define EXIT_SUCCESS    0
#define EXIT_FAILURE    1
#endif

#include "proto.h"
static InitTree P((void ));
static InsertNode P((int r ));
static link P((int n , int p , int q ));
static linknode P((int p , int q , int r ));
static DeleteNode P((int p ));
static int GetBit P((void ));
static int GetByte P((void ));
static int GetNBits P((unsigned int n ));
static Putcode P((int l , unsigned int c ));
static StartHuff P((void ));
static reconst P((void ));
static update P((unsigned int c ));
static EncodeChar P((unsigned c ));
static EncodePosition P((unsigned c ));
static EncodeEnd P((void ));
static int DecodeChar P((void ));
static int DecodePosition P((void ));
static Encode P((void ));
static Decode P((void ));
static InitBuf P((void ));
static DecodeOld P((void ));
static start_indicator P((char *name , long size , char *msg ));
static finish_indicator2 P((char *name , char *msg , int pcnt ));
static finish_indicator P((char *name , char *msg ));

#undef P

static FILE     *infile, *outfile;
static long     textsize, codesize;


#define INDICATOR_THRESHOLD     4096L
#define MAX_INDICATOR_COUNT     64
static long             indicator_count;
static long             indicator_threshold;

#ifdef SELFMAIN
int                     quiet = 0;
#else
extern int              quiet;
#endif


#ifdef SELFMAIN
#define SETUP_PUTC_CRC(fp)      /* nothing */
#define SETUP_GETC_CRC(fp)      /* nothing */
#define PUTC_CRC(c)             putc((c),(outfile))
#define GETC_CRC()              getc(infile)
#define END_PUTC_CRC()
#define END_GETC_CRC()
#else
#define SETUP_PUTC_CRC(fp)      crc_outfile = fp
#define SETUP_GETC_CRC(fp)      crc_infile = fp
#define PUTC_CRC(c)             putc_crc(c)
#define GETC_CRC()              getc_crc()
#define END_PUTC_CRC()
#define END_GETC_CRC()
#endif




#ifdef SELFMAIN
void Error (message)
        char *message;
{
        printf("\n%s\n", message);
        exit(EXIT_FAILURE);
}
#endif

/*----------------------------------------------------------------------*/
/*                                                                      */
/*              LZSS ENCODING                                           */
/*                                                                      */
/*----------------------------------------------------------------------*/

#define N               4096    /* buffer size */
#define F               60      /* pre-sence buffer size */
#define THRESHOLD       2

#ifdef __ASM__INSDEL__
static unsigned char    text_buf[N+F];
static unsigned int     match_position = 0, match_length = 0;
static unsigned short   same[N+1];
static unsigned short	rson[N+1];
static unsigned short	lson[N+1];
static unsigned short	dad[N+1];
static unsigned short	roots[4096];
static unsigned short *adrs[] = { &dad[0], &lson[0], &rson[0], &roots[0],
				  (unsigned short *)&text_buf[-1] };
static unsigned short *adrs2[] = { &dad[0], &lson[0], &rson[0], &same[0],
		        (unsigned short *)&text_buf[-1] };
#else
#define NIL             N       /* term of tree */
static unsigned char    text_buf[N + F - 1];
static unsigned int     match_position, match_length;
#endif
#ifndef __ASM__INSDEL__
static int              lson[N + 1], rson[N + 1 + N], dad[N + 1];
static unsigned char    same[N + 1];
#endif

#ifndef __ASM__INSDEL__
/* Initialize Tree */
static InitTree () 
{
        register int *p, *e;

        for (p = rson + N + 1, e = rson + N + N; p <= e; )
                *p++ = NIL;
        for (p = dad, e = dad + N; p < e; )
                *p++ = NIL;
}


/* Insert to node */
static InsertNode (r)
        register int r;
{
        register int            p;
        int                     cmp;
        register unsigned char  *key;
        register unsigned int   c;
        register unsigned int   i, j;

        cmp = 1;
        key = &text_buf[r];
        i = key[1] ^ key[2];
        i ^= i >> 4;
        p = N + 1 + key[0] + ((i & 0x0f) << 8);
        rson[r] = lson[r] = NIL;
        match_length = 0;
        i = j = 1;
        for ( ; ; ) {
                if (cmp >= 0) {
                        if (rson[p] != NIL) {
                                p = rson[p];
                                j = same[p];
                        } else {
                                rson[p] = r;
                                dad[r] = p;
                                same[r] = i;
                                return;
                        }
                } else {
                        if (lson[p] != NIL) {
                                p = lson[p];
                                j = same[p];
                        } else {
                                lson[p] = r;
                                dad[r] = p;
                                same[r] = i;
                                return;
                        }
                }

                if (i > j) {
                        i = j;
                        cmp = key[i] - text_buf[p + i];
                } else
                if (i == j) {
                        for (; i < F; i++)
                                if ((cmp = key[i] - text_buf[p + i]) != 0)
                                        break;
                }

                if (i > THRESHOLD) {
                        if (i > match_length) {
                                match_position = ((r - p) & (N - 1)) - 1;
                                if ((match_length = i) >= F)
                                        break;
                        } else
                        if (i == match_length) {
                                if ((c = ((r - p) & (N - 1)) - 1) < match_position) {
                                        match_position = c;
                                }
                        }
                }
        }
        same[r] = same[p];
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
#endif /* __ASM__INSDEL__ */

#ifndef __ASM__INSDEL__
#ifdef __GNUC__
inline
#endif
static link (n, p, q)
        int n, p, q;
{
        register unsigned char *s1, *s2, *s3;
        if (p >= NIL) {
                same[q] = 1;
                return;
        }
        s1 = text_buf + p + n;
        s2 = text_buf + q + n;
        s3 = text_buf + p + F;
        while (s1 < s3) {
                if (*s1++ != *s2++) {
                        same[q] = s1 - 1 - text_buf - p;
                        return;
                }
        }
        same[q] = F;
}


#ifdef __GNUC__
inline
#endif
static linknode (p, q, r)
        int p, q, r;
{
        int cmp;

        if ((cmp = same[q] - same[r]) == 0) {
                link(same[q], p, r);
        } else if (cmp < 0) {
                same[r] = same[q];
        }
}
#endif /* __ASM__INSDEL__ */

#ifndef __ASM__INSDEL__
static DeleteNode (p)
        register int p;
{
        register int  q;

        if (dad[p] == NIL)
                return;                 /* has no linked */
        if (rson[p] == NIL) {
                if ((q = lson[p]) != NIL)
                        linknode(dad[p], p, q);
        } else
        if (lson[p] == NIL) {
                q = rson[p];
                linknode(dad[p], p, q);
        } else {
                q = lson[p];
                if (rson[q] != NIL) {
                        do {
                                q = rson[q];
                        } while (rson[q] != NIL);
                        if (lson[q] != NIL)
                                linknode(dad[q], q, lson[q]);
                        link(1, q, lson[p]);
                        rson[dad[q]] = lson[q];
                        dad[lson[q]] = dad[q];
                        lson[q] = lson[p];
                        dad[lson[p]] = q;
                }
                link(1, dad[p], q);
                link(1, q, rson[p]);
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
#endif /* __ASM__INSDEL__ */

/*----------------------------------------------------------------------*/
/*                                                                      */
/*              HUFFMAN ENCODING                                        */
/*                                                                      */
/*----------------------------------------------------------------------*/

#define N_CHAR          (256 - THRESHOLD + F) /* {code : 0 .. N_CHAR-1} */
#define T               (N_CHAR * 2 - 1)        /* size of table */
#define R               (T - 1)                 /* root position */
#define MAX_FREQ        0x8000  /* tree update timing from frequency */

typedef unsigned char uchar;



/* TABLE OF ENCODE/DECODE for upper 6bits position information */

/* for encode */
static uchar p_len[64] = {
        0x03, 0x04, 0x04, 0x04, 0x05, 0x05, 0x05, 0x05,
        0x05, 0x05, 0x05, 0x05, 0x06, 0x06, 0x06, 0x06,
        0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06, 0x06,
        0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07,
        0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07,
        0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07,
        0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08,
        0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08
};

static uchar p_code[64] = {
        0x00, 0x20, 0x30, 0x40, 0x50, 0x58, 0x60, 0x68,
        0x70, 0x78, 0x80, 0x88, 0x90, 0x94, 0x98, 0x9C,
        0xA0, 0xA4, 0xA8, 0xAC, 0xB0, 0xB4, 0xB8, 0xBC,
        0xC0, 0xC2, 0xC4, 0xC6, 0xC8, 0xCA, 0xCC, 0xCE,
        0xD0, 0xD2, 0xD4, 0xD6, 0xD8, 0xDA, 0xDC, 0xDE,
        0xE0, 0xE2, 0xE4, 0xE6, 0xE8, 0xEA, 0xEC, 0xEE,
        0xF0, 0xF1, 0xF2, 0xF3, 0xF4, 0xF5, 0xF6, 0xF7,
        0xF8, 0xF9, 0xFA, 0xFB, 0xFC, 0xFD, 0xFE, 0xFF
};

/* for decode */
static uchar d_code[256] = {
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

static uchar d_len[256] = {
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

static unsigned freq[T + 1];    /* frequency table */

static int prnt[T + N_CHAR];    /* points to parent node */
/* notes :
   prnt[T .. T + N_CHAR - 1] used by
   indicates leaf position that corresponding to code */

static int son[T];              /* points to son node (son[i],son[i+]) */

static unsigned getbuf = 0;
static uchar getlen = 0;


/* get one bit */
/* returning in Bit 0 */
#ifdef __GNUC__
inline
#endif
static int GetBit ()
{
        register unsigned int dx = getbuf;
        register unsigned int c;

        if (getlen <= 8)
                {
                        c = getc (infile);
                        if ((int)c < 0) c = 0;
                        dx |= c << (8 - getlen);
                        getlen += 8;
                }
        getbuf = dx << 1;
        getlen--;
        return (dx & 0x8000) ? 1 : 0;
}

/* get one byte */
/* returning in Bit7...0 */
#ifdef __GNUC__
inline
#endif
static int GetByte ()
{
        register unsigned int dx = getbuf;
        register unsigned c;

        if (getlen <= 8) {
                c = getc (infile);
                if ((int)c < 0) c = 0;
                dx |= c << (8 - getlen);
                getlen += 8;
        }
        getbuf = dx << 8;
        getlen -= 8;
        return (dx >> 8) & 0xff;
}

/* get N bit */
/* returning in Bit(N-1)...Bit 0 */
static int GetNBits (n)
        register unsigned int n;
{
        register unsigned int dx = getbuf;
        register unsigned int c;
        static int mask[17] = {
                0x0000,
                0x0001, 0x0003, 0x0007, 0x000f,
                0x001f, 0x003f, 0x007f, 0x00ff,
                0x01ff, 0x03ff, 0x07ff, 0x0fff,
                0x1fff, 0x3fff, 0x0fff, 0xffff };
        static int shift[17] = {
                16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0 };
        
        if (getlen <= 8)
                {
                        c = getc (infile);
                        if ((int)c < 0) c = 0;
                        dx |= c << (8 - getlen);
                        getlen += 8;
                }
        getbuf = dx << n;
        getlen -= n;
        return (dx >> shift[n]) & mask[n];
}

static unsigned putbuf = 0;
static uchar putlen = 0;

/* output C bits */
#ifdef __GNUC__
inline
#endif
static Putcode (l, c)
        register int l;
        register unsigned int c;
{
        register len = putlen;
        register unsigned int b = putbuf;
        b |= c >> len;
        if ((len += l) >= 8) {
                putc (b >> 8, outfile);
                if ((len -= 8) >= 8) {
                        putc (b, outfile);
                        codesize += 2;
                        len -= 8;
                        b = c << (l - len);
                } else {
                        b <<= 8;
                        codesize++;
                }
        }
        putbuf = b;
        putlen = len;
}


/* Initialize tree */

static StartHuff ()
{
        register int i, j;

        for (i = 0; i < N_CHAR; i++) {
                freq[i] = 1;
                son[i] = i + T;
                prnt[i + T] = i;
        }
        i = 0; j = N_CHAR;
        while (j <= R) {
                freq[j] = freq[i] + freq[i + 1];
                son[j] = i;
                prnt[i] = prnt[i + 1] = j;
                i += 2; j++;
        }
        freq[T] = 0xffff;
        prnt[R] = 0;
        putlen = getlen = 0;
        putbuf = getbuf = 0;
}


/* reconstruct tree */
static reconst ()
{
        register int i, j, k;
        register unsigned f;

        /* correct leaf node into of first half,
           and set these freqency to (freq+1)/2       */
        j = 0;
        for (i = 0; i < T; i++) {
                if (son[i] >= T) {
                        freq[j] = (freq[i] + 1) / 2;
                        son[j] = son[i];
                        j++;
                }
        }
        /* build tree.  Link sons first */
        for (i = 0, j = N_CHAR; j < T; i += 2, j++) {
                k = i + 1;
                f = freq[j] = freq[i] + freq[k];
                for (k = j - 1; f < freq[k]; k--);
                k++;
                {       register unsigned *p, *e;
                        for (p = &freq[j], e = &freq[k]; p > e; p--)
                                p[0] = p[-1];
                        freq[k] = f;
                }
                {       register int *p, *e;
                        for (p = &son[j], e = &son[k]; p > e; p--)
                                p[0] = p[-1];
                        son[k] = i;
                }
        }
        /* link parents */
        for (i = 0; i < T; i++) {
                if ((k = son[i]) >= T) {
                        prnt[k] = i;
                } else {
                        prnt[k] = prnt[k + 1] = i;
                }
        }
}


/* update given code's frequency, and update tree */

#ifdef __GNUC__
inline
#endif
static update (c)
        unsigned int    c;
{
        register unsigned *p;
        register int i, j, k, l;

        if (freq[R] == MAX_FREQ) {
                reconst();
        }
        c = prnt[c + T];
        do {
                k = ++freq[c];

                /* swap nodes when become wrong frequency order. */
                if (k > freq[l = c + 1]) {
                        for (p = freq+l+1; k > *p++; ) ;
                        l = p - freq - 2;
                        freq[c] = p[-2];
                        p[-2] = k;

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
        } while ((c = prnt[c]) != 0);   /* loop until reach to root */
}

/* static unsigned code, len; */

static EncodeChar (c)
        unsigned c;
{
        register int *p;
        register unsigned long i;
        register int j, k;

        i = 0;
        j = 0;
        p = prnt;
        k = p[c + T];

        /* trace links from leaf node to root */
        do {
                i >>= 1;

                /* if node index is odd, trace larger of sons */
                if (k & 1) i += 0x80000000;

                j++;
        } while ((k = p[k]) != R) ;
        if (j > 16) {
                Putcode(16, (unsigned int)(i >> 16));
                Putcode(j - 16, (unsigned int)i);
        } else {
                Putcode(j, (unsigned int)(i >> 16));
        }
/*      code = i; */
/*      len = j; */
        update(c);
}

static EncodePosition (c)
        unsigned c;
{
        unsigned i;

        /* output upper 6bit from table */
        i = c >> 6;
        Putcode((int)(p_len[i]), (unsigned int)(p_code[i]) << 8);

        /* output lower 6 bit */
        Putcode(6, (unsigned int)(c & 0x3f) << 10);
}

static EncodeEnd ()
{
        if (putlen) {
                putc(putbuf >> 8, outfile);
                codesize++;
        }
}

#ifdef __GNUC__
inline
#endif
static int DecodeChar ()
{
        register unsigned c;

        c = son[R];

        /* trace from root to leaf,
           got bit is 0 to small(son[]), 1 to large (son[]+1) son node */
        while (c < T) {
                c += GetBit();
                c = son[c];
        }
        c -= T;
        update(c);
        return c;
}

#ifdef __GNUC__
inline
#endif
static int DecodePosition ()
{
        unsigned i, j, c;

        /* decode upper 6bit from table */
        i = GetByte();
        c = (unsigned)d_code[i] << 6;
        j = d_len[i];

        /* get lower 6bit */
        j -= 2;
        return c | (((i << j) | GetNBits (j)) & 0x3f);
}


static Encode ()
{
        register int  i, c, len, r, s, last_match_length;

        if (textsize == 0)
                return;

        textsize = 0;
        StartHuff();
        InitTree();
        s = 0;
        r = N - F;
        for (i = s; i < r; i++)
                text_buf[i] = ' ';
        for (len = 0; len < F && (c = GETC_CRC()) != EOF; len++)
                text_buf[r + len] = c;
        textsize = len;
#ifndef __ASM__INSDEL__
        for (i = 1; i <= F; i++)
                InsertNode(r - i);
#else
        for (i = 1; i <= F; i++)
		InsertNoMatch(r - i);
#endif
        InsertNode(r);
#if 0
printf("%d %d\n", match_position, match_length);
#endif
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
#ifndef __ASM__INSDEL__
                for (i = 0; i < last_match_length &&
                                (c = GETC_CRC()) != EOF; i++) {
                        DeleteNode(s);
                        text_buf[s] = c;
                        if (s < F - 1)
                                text_buf[s + N] = c;
                        s = (s + 1) & (N - 1);
                        r = (r + 1) & (N - 1);
                        InsertNode(r);
                }
#else
		c = GETC_CRC();
		i = 0;
		if (i < last_match_length && c != EOF)
		{
		  loopNM:
                        DeleteNode(s);
                        text_buf[s] = c;
                        if (s < F - 1)
                                text_buf[s + N] = c;
                        s = (s + 1) & (N - 1);
                        r = (r + 1) & (N - 1);
			if (++i < last_match_length && (c =
			    GETC_CRC()) != EOF)
			{
			    InsertNoMatch (r);
			    goto loopNM;
			}
			else
			    InsertNode (r);
		    }

#endif

#if 0
printf("%d %d\n", match_position, match_length);
#endif

                textsize += i;
                if ((textsize > indicator_count) && !quiet) {
                        putchar ('o');
                        fflush (stdout);
                        indicator_count += indicator_threshold;
                }
                while (i++ < last_match_length) {
                        DeleteNode(s);
                        s = (s + 1) & (N - 1);
                        r = (r + 1) & (N - 1);
                        if (--len) InsertNode(r);
                }
        } while (len > 0);
        EncodeEnd();
        END_GETC_CRC ();
}

static Decode ()
{
        register int    i, j, k, r, c;
        register long   count;

#ifdef SELFMAIN
        if (textsize == 0)
                return;
#endif
        StartHuff();
        for (i = 0; i < N - F; i++)
                text_buf[i] = ' ';
        r = N - F;
        for (count = 0; count < textsize; ) {
                c = DecodeChar();
                if (c < 256) {
                        PUTC_CRC (c);
                        text_buf[r++] = c;
                        r &= (N - 1);
                        count++;
                } else {
                        i = (r - DecodePosition() - 1) & (N - 1);
                        j = c - 255 + THRESHOLD;
                        for (k = 0; k < j; k++) {
                                c = text_buf[(i + k) & (N - 1)];
                                PUTC_CRC (c);
                                text_buf[r++] = c;
                                r &= (N - 1);
                                count++;
                        }
                }

                if (!quiet && (count > indicator_count)) {
                        putchar ('o');
                        fflush (stdout);
                        indicator_count += indicator_threshold;
                }
        }
        END_PUTC_CRC ();
}


/*----------------------------------------------------------------------*/
/*                                                                      */
/*              LARC                                                    */
/*                                                                      */
/*----------------------------------------------------------------------*/

#define F_OLD   18      /* look ahead buffer size for LArc */

/* intialize buffer for LArc type 5 */
static InitBuf ()
{
        register unsigned char *p = text_buf;
        register int i, j;
        for (i = 0; i < 256; i ++)
                for (j = 0; j < 13; j ++)
                        *p ++ = i;
        for (i = 0; i < 256; i ++)
                *p ++ = i;
        for (i = 0; i < 256; i ++)
                *p ++ = 255 - i;
        for (i = 0; i < 128; i ++)
                *p ++ = 0;
        for (i = 0; i < 128; i ++)
                *p ++ = 0x20;
}

/* Decode LArc type 5 */
static DecodeOld ()
{
        register int si, di;
        register long count;
        int     dl, dh, al, cx;
        if (textsize == 0)
                return;
        
        InitBuf ();
        di = N - F_OLD;
        dl = 0x80;
        
        for (count = 0; count < textsize; ) {
                dl = ((dl << 1) | (dl >> 7)) & 0xff;
                if (dl & 0x01)
                        dh = getc (infile);
                al = getc (infile);
                if ((dh & dl) != 0) {
                        PUTC_CRC (al);
                        text_buf[di] = al;
                        di = (di + 1) & (N - 1);
                        count ++;
                } else {
                        cx = getc (infile);
                        si = (al & 0x00ff) | ((cx << 4) & 0x0f00);
                        cx = (cx & 0x000f) + 3;
                        count += cx;
                        do {
                                text_buf[di] = al = text_buf[si];
                                PUTC_CRC (al);
                                si = (si + 1) & (N - 1);
                                di = (di + 1) & (N - 1);
                        } while (--cx != 0) ;
                }

                if (!quiet && (count > indicator_count)) {
                        putchar ('o');
                        fflush (stdout);
                        indicator_count += indicator_threshold;
                }
        }
        END_PUTC_CRC ();
}



/*----------------------------------------------------------------------*/
/*                                                                      */
/*              Global Entries for Archiver Driver                      */
/*                                                                      */
/*----------------------------------------------------------------------*/


static start_indicator (name, size, msg)
        char *name;
        long size;
        char *msg;
{
        long    i;
        int     m;

        if (quiet)
                return;

        m = MAX_INDICATOR_COUNT - strlen (name);
        if (m < 0)
                m = 3;          /* (^_^) */

#ifndef atarist
        printf ("\r%s\t- %s :  ", name, msg);
#else
        printf ("\r%s\n", name);
#endif

        indicator_threshold =
                ((size  + (m * INDICATOR_THRESHOLD - 1)) /
                 (m * INDICATOR_THRESHOLD) *
                 INDICATOR_THRESHOLD);
        i = ((size + (indicator_threshold - 1)) / indicator_threshold);
#ifndef atarist
        while (i--)
                putchar ('.');
        indicator_count = 0;
        printf ("\r%s\t- %s :  ", name, msg);
        fflush (stdout);
#else
        printf ("%s :  ", msg);
        while (i--)
                putchar ('.');
        indicator_count = 0;
        printf ("\r%s :  ", msg);
        fflush (stdout);
#endif
}

static finish_indicator2 (name, msg, pcnt)
        char *name;
        char *msg;
        int pcnt;
{
        if (quiet)
                return;

        if (pcnt > 100) pcnt = 100;     /* (^_^) */
#ifndef atarist
        printf ("\r%s\t- %s(%d%%)\n", name, msg, pcnt);
#else
        printf ("\r%s(%d%%)\n", msg, pcnt);
#endif
        fflush (stdout);
}

static finish_indicator (name, msg)
        char *name;
        char *msg;
{
        if (quiet)
                return;

#ifndef atarist
        printf ("\r%s\t- %s\n", name, msg);
#else
        printf ("\r%s\n", msg);
#endif
        fflush (stdout);
}


#ifndef SELFMAIN
int encode_lzhuf (infp, outfp, size, original_size_var, packed_size_var, name)
        FILE *infp;
        FILE *outfp;
        long size;
        long *original_size_var;
        long *packed_size_var;
        char *name;
{
        infile = infp;
        outfile = outfp;
        SETUP_GETC_CRC(infp);
        textsize = size;
        codesize = 0;
        init_crc ();
        start_indicator (name, size, "Freezing");
        Encode ();
        finish_indicator2 (name, "Frozen",
                           (int)((codesize * 100L) / crc_size));
        *packed_size_var = codesize;
        *original_size_var = crc_size;
        return crc_value;
}

int decode_lzhuf (infp, outfp, original_size, name)
        FILE *infp;
        FILE *outfp;
        long original_size;
        char *name;
{
        infile = infp;
        outfile = outfp;
        SETUP_PUTC_CRC(outfp);
        textsize = original_size;
        init_crc ();
#ifndef atarist
        start_indicator (name, original_size, "Melting ");
        Decode ();
        finish_indicator (name, "Melted  ");
#else
        start_indicator (name, original_size, (tstflg ? "Testing " : "Melting "));
        Decode ();
        finish_indicator (name, (tstflg ? "Tested  " : "Melted  "));
#endif
        return crc_value;
}


int decode_larc (infp, outfp, original_size, name)
        FILE *infp, *outfp;
        long original_size;
        char *name;
{
        infile = infp;
        outfile = outfp;
        SETUP_PUTC_CRC(outfp);
        textsize = original_size;
        init_crc ();
        start_indicator (name, original_size, "Melting ");
        DecodeOld ();
        finish_indicator (name, "Melted  ");
        return crc_value;
}
#endif

#ifdef SELFMAIN
int main (argc, argv)
        int argc;
        char *argv[];
{
        char  *s;
        int i;

        indicator_count = 0;
        indicator_threshold = 1024;
        textsize = codesize = 0;
        if (argc != 4) {
                printf ("\
usage: lzhuf e in_file out_file (packing)\n\
       lzhuf d in_file out_file (unpacking)\n");
                return EXIT_FAILURE;
        }
        if ((s = argv[1], ((*s != 'e') && (*s != 'd')) || s[1] != '\0') ||
  #ifdef ultrix
 	    (s = argv[2], (infile  = fopen(s, "r")) == NULL) ||
 	    (s = argv[3], (outfile = fopen(s, "w")) == NULL)) {
  #else
            (s = argv[2], (infile  = fopen(s, "rb")) == NULL) ||
            (s = argv[3], (outfile = fopen(s, "wb")) == NULL)) {
  #endif
                printf("??? %s\n", s);
                return EXIT_FAILURE;
        }
        if (argv[1][0] == 'e') {
                /* Get original text size and output it */
                fseek(infile, 0L, 2);
                textsize = ftell(infile);
                rewind (infile);
                if (fwrite(&textsize, sizeof textsize, 1, outfile) < 1)
                        Error("cannot write");

                start_indicator (argv[2], textsize, "Freezing");
                Encode();
                finith_indicator2 (argv[2], "Frozen",
                                   (int)((codesize * 100L) / textsize));

                printf("input : %ld bytes\n", textsize);
                printf("output: %ld bytes\n", codesize);
        } else {
                /* Read original text size */
                if (fread(&textsize, sizeof textsize, 1, infile) < 1)
                        Error("cannot read");

                start_indicator (argv[2], textsize, "Melting ");
                Decode();
                finish_indicator (argv[2], "Melted  ");
        }
        fclose(infile);
        fclose(outfile);
        return EXIT_SUCCESS;
}
#endif


/* These lines are used in GNU-Emacs */
/* Local Variables: */
/* comment-column:40 */
/* tab-width:8 */
/* c-indent-level:8 */
/* c-continued-statement-offset:8 */
/* c-argdecl-indent:8 */
/* End: */

#ifdef __ASM__INSDEL__
#ifdef atarist
__asm__("
N	=	4096
F	=	60

	.text; .even
	| InitTree(void)
_InitTree:
	movel	_adrs+12,a1	| Roots
	moveq	#0,d0
	movew	#(N+1)*3+4095,d1
clrt:	movew	d0,a1@+
	dbf	d1,clrt
	rts

|----------
|- Delete -
|----------

D.doR:	movew	d1,d3		| Get to end of Lt tree
	movew	a4@(0,d3:w),d1
	bnes	D.doR
	movew	d1,a0@(_rson-_dad)	| Clear L & R
	movew	d1,a0@(_lson-_dad)

	movew	d4,a4@(0,d3:w)
	movew	d3,a2@(0,d4:w)
	movew	d4,d1		| Calc new _same value
	lsrw	#1,d1
	lea	a6@(1,d1:w),a0
	movew	d3,d1
	lsrw	#1,d1
	lea	a6@(1,d1:w),a1
	moveq	#0,d1
Lcmp3:	addqw	#1,d1
	cmpmb	a0@+,a1@+
	beqs	Lcmp3

put4d1:	movew	d1,a5@(0,d4:w)
	subaw	d1,a1
	movew	a3@(0,d3:w),d1	| _Lson of new
	movew	d0,a3@(0,d3:w)	| Move rest of old _lson tree to new,
	movew	d3,a2@(0,d0:w)	|and chg old _lson's _dad pointer
	movew	d0,d4
	lsrw	#1,d4
	lea	a6@(1,d4:w),a0
	moveq	#0,d4
Lcmp2:	addqw	#1,d4
	cmpmb	a0@+,a1@+
	beqs	Lcmp2

put0d4:	movew	d4,a5@(0,d0:w)
	movew	a2@(0,d3:w),d0	| Prev _dad of new
	movew	d0,a2@(0,d1:w)
	movew	d1,a4@(0,d0:w)	| Connect with prev _lson of new
	beqs	skplink
	movew	a5@(0,d3:w),d4
 	cmpw	a5@(0,d1:w),d4
 	bhis	skplink
	bnes	put1d4
	lsrw	#1,d0
	addw	d4,d0
	lea	a6@(0,d0:w),a0
	movew	d1,d0
	lsrw	#1,d0
	addw	d4,d0
	lea	a6@(0,d0:w),a1
	subqw	#1,d4
Lcmp1:	addqw	#1,d4
	cmpmb	a0@+,a1@+
	beqs	Lcmp1
put1d4:	movew	d4,a5@(0,d1:w)
skplink:	movew	d3,d4
	bras	Lcpy_dad

ret1:	moveml	sp@+,d2-d5/a2-a6
	rts
	
	.text; .even
	| DeleteNode(int p)
_DeleteNode:
	moveml d2-d5/a2-a6,sp@-
	moveml	_adrs2,a2-a6
	movew	a7@(40),d5
	addw	d5,d5
	lea	a2@(2,d5:w),a0
	movew	a0@,d2
	beqs	ret1		| Node empty (almost never)
	addqw	#2,d5
	movew	a0@(_rson-_dad),d4
	beqs	D.noR
	movew	a0@(_lson-_dad),d0
	beqs	cpy_dad0
|				| Has both sons: d4=_rson, d0=_lson
	movew	a4@(0,d0:w),d1
	bne	D.doR

copyL:	movew	d4,a4@(0,d0:w)
	movew	d0,a2@(0,d4:w)
	movew	d1,a0@(_rson-_dad)	| Clear L & R
	movew	d1,a0@(_lson-_dad)
	movew	d4,d3
	lsrw	#1,d3
	lea	a6@(1,d3:w),a0
	movew	d0,d3
	lsrw	#1,d3
	lea	a6@(1,d3:w),a1
	subqw	#1,d1
Lcmp4:	addqw	#1,d1
	cmpmb	a0@+,a1@+
	beqs	Lcmp4
	movew	d1,a5@(0,d4:w)
	movew	d0,d4

Lcpy_dad:	movew	d2,d0
	lsrw	#1,d0
	lea	a6@(1,d0:w),a0
	movew	d4,d0
	lsrw	#1,d0
	lea	a6@(1,d0:w),a1
	moveq	#0,d1
	bras	D.cmp

D.noR:	movew	a0@(_lson-_dad),d4
	beqs	cpy_dad
	moveq	#0,d0
	movew	d0,a0@(_lson-_dad)
cpy_dad0:	movew	d0,a0@(_rson-_dad)
 	movew	a5@(0,d5:w),d1
	cmpw	a5@(0,d4:w),d1
 	bhis	cpy_dad
	bnes	putd1
	movew	d2,d0
	lsrw	#1,d0
	addw	d1,d0
	lea	a6@(0,d0:w),a0
	movew	d4,d0
	lsrw	#1,d0
	addw	d1,d0
	lea	a6@(0,d0:w),a1
	subqw	#1,d1
D.cmp:	addqw	#1,d1
	cmpmb	a0@+,a1@+
	beqs	D.cmp
putd1:	movew	d1,a5@(0,d4:w)

cpy_dad: 	movew	d2,a2@(0,d4:w)
	bmis	rootd4
	cmpw	a4@(0,d2:w),d5
	beqs	D.rt
	movew	d4,a3@(0,d2:w)
	moveml	sp@+,d2-d5/a2-a6
	rts
D.rt:	movew	d4,a4@(0,d2:w)
	moveml	sp@+,d2-d5/a2-a6
	rts

rootd4:	lsrw	#1,d5		| Occurs 50% of deletes
	lea	a6@(0,d5:w),a0
	moveq	#0,d0
	moveq	#0,d1
	moveb	a0@+,d0
	moveb	a0@+,d1
	moveb	a0@,d2
	eorb	d2,d1
	movew	d1,d2
	lslb	#4,d1
	eorw	d2,d1
	lslw	#4,d1
	clrb	d1
	addw	d1,d0
	addw	d0,d0		|104 = .5 sec per 100K
	movel	_adrs+12,a5
	movew	d4,a5@(0,d0:w)	| Update starting ptr
	moveml	sp@+,d2-d5/a2-a6
	rts

|----------
|- Insert -
|----------

I.mt:	movew	d6,a5@(0,d1:w)	| Set starting pt of tree
	moveq	#-1,d1
	movew	d1,a2@(0,d6:w)	| -1 marks root
	movew	d7,_match_length	| d7=0, No match
	moveml	sp@+,d2-d7/a2-a6
	rts

Isam:	addqw	#1,d0
	cmpw	d7,d0
	blts	ILcmp
	bra	I.full

	.text; .even
	| InsertNode(int r)
_InsertNode:
	moveml d2-d7/a2-a6,sp@-
	moveml	_adrs,a2-a6
	movew	sp@(48),d6
	addqw	#1,d6
	lea	a6@(0,d6:w),a0
	addw	d6,d6
	moveq	#0,d0
	moveq	#0,d1
	moveb	a0@+,d0
	moveb	a0@+,d1
	moveb	a0@,d2
	eorb	d2,d1
	movew	d1,d2
	lslb	#4,d1
	eorw	d2,d1
	lslw	#4,d1
	clrb	d1
	addw	d0,d1
	addw	d1,d1
	movew	a5@(0,d1:w),d7	| Get starting pt of tree
	beqs	I.mt		| 1st time character has been seen
	movel	_adrs2+12,a5
	moveq	#0,d2		| Clear L & R match lengths
	moveq	#0,d5
	moveq	#1,d0
	movew	d7,d1

Isame:	lsrw	#1,d7
	addw	d0,d7
	lea	a6@(0,d7:w),a1
	subql	#1,a0
	moveq	#F,d7
ILcmp:	cmpmb	a1@+,a0@+
	beqs	Isam
	blss	I.low
I.Ragain:
	cmpw	d0,d2
	bnes	Rset
	cmpw	d1,d3
	bccs	d1d3
	cmpw	d6,d1
	bcss	Ruzd1
	cmpw	d6,d3
	bccs	Ruzd1
	bras	Ruzd3

I.ckR:	movew	d7,d1
	cmpw	a5@(0,d7:w),d0	| Ck # of bytes that are the SAME as _dad
	bcss	I.Ragain
	beqs	Isame
I.part:	subaw	d0,a0		| 6%
	movew	a5@(0,d7:w),d0
	addaw	d0,a0		| Point to just after SAME data
	bras	Isame

d1d3:	cmpw	d6,d1
	bccs	Ruzd3
	cmpw	d6,d3
	bcss	Ruzd3
Rset:	movew	d0,d2		| Last match length R
Ruzd1:	movew	d1,d3		|		pos R
Ruzd3:	movew	a4@(0,d1:w),d7	| Link to rt son
	bnes	I.ckR
	movew	d1,a2@(0,d6:w)	| Node was mt, insert d6
	movew	d6,a4@(0,d1:w)
	movew	d0,a5@(0,d6:w)
	cmpw	d0,d5
	bcss	I.uzd3
	beqs	I.ck34
I.uzd4:	subw	d4,d6
	lsrw	#1,d6
	andw	#N-1,d6
	subqw	#1,d6
	movew	d6,_match_position	| Last Lt turn was longer
	movew	d5,_match_length
	moveml	sp@+,d2-d7/a2-a6
	rts

I.ckL:	movew	d7,d1
	cmpw	a5@(0,d7:w),d0	| Ck # of bytes that are the SAME as _dad
	beqs	Isame
	bccs	I.part
|				| Fall through to do Left again
I.low:	cmpw	d0,d5
	bnes	Lset
	cmpw	d1,d4
	bccs	d1d4
	cmpw	d6,d1
	bcss	Luzd1
	cmpw	d6,d4
	bcss	Luzd4
Lset:	movew	d0,d5		| Len L
Luzd1:	movew	d1,d4		| Pos L
Luzd4:	movew	a3@(0,d1:w),d7	| Link to lt son
	bnes	I.ckL
	movew	d1,a2@(0,d6:w)
	movew	d6,a3@(0,d1:w)
	movew	d0,a5@(0,d6:w)
	cmpw	d0,d2
	bcss	I.uzd4
	beqs	I.ck34
I.uzd3:	subw	d3,d6
	lsrw	#1,d6
	andw	#N-1,d6
	subqw	#1,d6
	movew	d6,_match_position	| Last Rt turn was longer
	movew	d2,_match_length
	moveml	sp@+,d2-d7/a2-a6
	rts

d1d4:	cmpw	d6,d1
	bccs	Luzd4
	cmpw	d6,d4
	bccs	Luzd1
	bras	Luzd4

I.ck34:	movew	d6,d2
	subw	d4,d6
	lsrw	#1,d6
	andw	#N-1,d6
	subw	d3,d2
	lsrw	#1,d2
	andw	#N-1,d2
	cmpw	d2,d6
	bcss	I.uzd6		| 56,58 from I.ck34
	subqw	#1,d2
	movew	d2,_match_position	| Last Lt turn was longer
	movew	d0,_match_length
	moveml	sp@+,d2-d7/a2-a6
	rts

I.uzd6:	subqw	#1,d6
	movew	d6,_match_position
	movew	d0,_match_length
	moveml	sp@+,d2-d7/a2-a6
	rts

I.full:	lea	a2@(0,d1:w),a1
	lea	a2@(0,d6:w),a0
	movew	a1@(_lson-_dad),d3	| Replace old node with new one
	movew	d3,a0@(_lson-_dad)
	movew	d6,a2@(0,d3:w)		|and point old sons to new
	movew	a1@(_rson-_dad),d3
	movew	d3,a0@(_rson-_dad)
	movew	d6,a2@(0,d3:w)
	movew	a5@(0,d1:w),a5@(0,d6:w)	| Move SAME
	movew	a1@,d3
	clrw	a1@			| Delete old
	clrw	a1@(_lson-_dad)
	clrw	a1@(_rson-_dad)
	movew	d3,a0@
	bmis	I.root
	cmpw	a4@(0,d3:w),d1
	beqs	I.rt
	movel	a3,a4
I.rt:	movew	d6,a4@(0,d3:w)
	subw	d1,d6
	lsrw	#1,d6
	andw	#N-1,d6
	subqw	#1,d6
	movew	d6,_match_position
	movew	#F,_match_length
	moveml	sp@+,d2-d7/a2-a6
	rts
I.root:	movew	d6,d3		| Occurs almost never
	lsrw	#1,d3
	lea	a6@(0,d3:w),a0
	moveq	#0,d3
	moveq	#0,d0
	moveb	a0@+,d3
	moveb	a0@+,d0
	moveb	a0@,d2
	eorb	d2,d0
	movew	d0,d2
	lslb	#4,d0
	eorw	d2,d0
	lslw	#4,d0
	clrb	d0
	addw	d0,d3
	addw	d3,d3
	movel	_adrs+12,a4	| ROOTS
	bras	I.rt

|-------------------------
|Insert with No Match data
|-------------------------

NM.mt:	movew	d6,a5@(0,d1:w)	| Set starting pt of tree
	moveq	#-1,d1
	movew	d1,a2@(0,d6:w)	| -1 marks root
	moveml	sp@+,d6-d7/a2-a6
	rts

 	.text; .even
_InsertNoMatch:
	moveml d6-d7/a2-a6,sp@-
	moveml	_adrs,a2-a6
	movew	a7@(32),d6
	addqw	#1,d6
	lea	a6@(0,d6:w),a0
	addw	d6,d6
	moveq	#0,d0
	moveq	#0,d1
	moveb	a0@+,d0
	moveb	a0@+,d1
	moveb	a0@,d7
	eorb	d7,d1
	movew	d1,d7
	lslb	#4,d1
	eorw	d7,d1
	lslw	#4,d1
	clrb	d1
	addw	d0,d1
	addw	d1,d1
	movew	a5@(0,d1:w),d7	| Get starting pt of tree
	beqs	NM.mt		| 1st time character has been seen
	movel	_adrs2+12,a5
	moveq	#1,d0
	movew	d7,d1

NMsame:	lsrw	#1,d7
	addw	d0,d7
	lea	a6@(0,d7:w),a1
	subql	#1,a0
	moveq	#F,d7
NMLcmp:	cmpmb	a1@+,a0@+
	bnes	NM.dif
	addqw	#1,d0
	cmpw	d7,d0
	blts	NMLcmp
	bra	NM.full

NM.dif:
	blss	NM.low
NM.Ragain:
	movew	a4@(0,d1:w),d7	| Link to rt son
	bnes	NM.ckR
	movew	d1,a2@(0,d6:w)	| Node was mt, insert d6
	movew	d6,a4@(0,d1:w)
	movew	d0,a5@(0,d6:w)
	moveml	sp@+,d6-d7/a2-a6
	rts

NM.ckR:	movew	d7,d1
	cmpw	a5@(0,d7:w),d0	| Ck # of bytes that are the SAME as _dad
	bcss	NM.Ragain
	beqs	NMsame
NM.part:	subaw	d0,a0	| 6%
	movew	a5@(0,d7:w),d0
	addaw	d0,a0		| Point to just after SAME data
	bras	NMsame

NM.ckL:	movew	d7,d1
	cmpw	a5@(0,d7:w),d0	| Ck # of bytes that are the SAME as _dad
	beqs	NMsame
	bccs	NM.part
|				| Fall through to do Left again
NM.low:	movew	a3@(0,d1:w),d7	| Link to lt son
	bnes	NM.ckL
	movew	d1,a2@(0,d6:w)
	movew	d6,a3@(0,d1:w)
	movew	d0,a5@(0,d6:w)
	moveml	sp@+,d6-d7/a2-a6
	rts

NM.full:
	lea	a2@(0,d1:w),a1
	lea	a2@(0,d6:w),a0
	movew	a1@(_lson-_dad),d7	| Replace old node with new one
	movew	d7,a0@(_lson-_dad)
	movew	d6,a2@(0,d7:w)		|and point old sons to new
	movew	a1@(_rson-_dad),d7
	movew	d7,a0@(_rson-_dad)
	movew	d6,a2@(0,d7:w)
	movew	a5@(0,d1:w),a5@(0,d6:w)	| Move SAME
	movew	a1@,d7
	clrw	a1@			| Delete old
	clrw	a1@(_lson-_dad)
	clrw	a1@(_rson-_dad)
	movew	d7,a0@
	bmis	NM.root
	cmpw	a4@(0,d7:w),d1
	beqs	NM.rt
	movel	a3,a4
NM.rt:	movew	d6,a4@(0,d7:w)
	moveml	sp@+,d6-d7/a2-a6
	rts
NM.root:
	movew	d6,d7		| Occurs almost never
	lsrw	#1,d7
	lea	a6@(0,d7:w),a0
	moveq	#0,d7
	moveq	#0,d0
	moveb	a0@+,d7
	moveb	a0@+,d0
	moveb	a0@,d1
	eorb	d1,d0
	movew	d0,d1
	lslb	#4,d0
	eorw	d1,d0
	lslw	#4,d0
	clrb	d0
	addw	d0,d7
	addw	d7,d7
	movel	_adrs+12,a4	| ROOTS
	bras	NM.rt

");
#else
__asm__("
N	=	4096
F	=	60

	.text; .even
	| InitTree(void)
_InitTree:
	movel	_adrs+12,a1	| Roots
	moveq	#0,d0
	movew	#(N+1)*3+4095,d1
clrt:	movew	d0,a1@+
	dbf	d1,clrt
	rts

|----------
|- Delete -
|----------

D.doR:	movew	d1,d3		| Get to end of Lt tree
	movew	a4@(0,d3:w),d1
	bnes	D.doR
	movew	d1,a0@(_rson-_dad)	| Clear L & R
	movew	d1,a0@(_lson-_dad)

	movew	d4,a4@(0,d3:w)
	movew	d3,a2@(0,d4:w)
	movew	d4,d1		| Calc new _same value
	lsrw	#1,d1
	lea	a6@(1,d1:w),a0
	movew	d3,d1
	lsrw	#1,d1
	lea	a6@(1,d1:w),a1
	moveq	#0,d1
Lcmp3:	addqw	#1,d1
	cmpmb	a0@+,a1@+
	beqs	Lcmp3

put4d1:	movew	d1,a5@(0,d4:w)
	subaw	d1,a1
	movew	a3@(0,d3:w),d1	| _Lson of new
	movew	d0,a3@(0,d3:w)	| Move rest of old _lson tree to new,
	movew	d3,a2@(0,d0:w)	|and chg old _lson's _dad pointer
	movew	d0,d4
	lsrw	#1,d4
	lea	a6@(1,d4:w),a0
	moveq	#0,d4
Lcmp2:	addqw	#1,d4
	cmpmb	a0@+,a1@+
	beqs	Lcmp2

put0d4:	movew	d4,a5@(0,d0:w)
	movew	a2@(0,d3:w),d0	| Prev _dad of new
	movew	d0,a2@(0,d1:w)
	movew	d1,a4@(0,d0:w)	| Connect with prev _lson of new
	beqs	skplink
	movew	a5@(0,d3:w),d4
 	cmpw	a5@(0,d1:w),d4
 	bhis	skplink
	bnes	put1d4
	lsrw	#1,d0
	addw	d4,d0
	lea	a6@(0,d0:w),a0
	movew	d1,d0
	lsrw	#1,d0
	addw	d4,d0
	lea	a6@(0,d0:w),a1
	subqw	#1,d4
Lcmp1:	addqw	#1,d4
	cmpmb	a0@+,a1@+
	beqs	Lcmp1
put1d4:	movew	d4,a5@(0,d1:w)
skplink:	movew	d3,d4
	bras	Lcpy_dad

ret1:	moveml	sp@+,d2-d5/a2-a6
	rts
	
	.text; .even
	| DeleteNode(int p)
_DeleteNode:
	moveml d2-d5/a2-a6,sp@-
	moveml	_adrs2,a2-a6
	movel	a7@(40),d5
	addw	d5,d5
	lea	a2@(2,d5:w),a0
	movew	a0@,d2
	beqs	ret1		| Node empty (almost never)
	addqw	#2,d5
	movew	a0@(_rson-_dad),d4
	beqs	D.noR
	movew	a0@(_lson-_dad),d0
	beqs	cpy_dad0
|				| Has both sons: d4=_rson, d0=_lson
	movew	a4@(0,d0:w),d1
	bne	D.doR

copyL:	movew	d4,a4@(0,d0:w)
	movew	d0,a2@(0,d4:w)
	movew	d1,a0@(_rson-_dad)	| Clear L & R
	movew	d1,a0@(_lson-_dad)
	movew	d4,d3
	lsrw	#1,d3
	lea	a6@(1,d3:w),a0
	movew	d0,d3
	lsrw	#1,d3
	lea	a6@(1,d3:w),a1
	subqw	#1,d1
Lcmp4:	addqw	#1,d1
	cmpmb	a0@+,a1@+
	beqs	Lcmp4
	movew	d1,a5@(0,d4:w)
	movew	d0,d4

Lcpy_dad:	movew	d2,d0
	lsrw	#1,d0
	lea	a6@(1,d0:w),a0
	movew	d4,d0
	lsrw	#1,d0
	lea	a6@(1,d0:w),a1
	moveq	#0,d1
	bras	D.cmp

D.noR:	movew	a0@(_lson-_dad),d4
	beqs	cpy_dad
	moveq	#0,d0
	movew	d0,a0@(_lson-_dad)
cpy_dad0:	movew	d0,a0@(_rson-_dad)
 	movew	a5@(0,d5:w),d1
	cmpw	a5@(0,d4:w),d1
 	bhis	cpy_dad
	bnes	putd1
	movew	d2,d0
	lsrw	#1,d0
	addw	d1,d0
	lea	a6@(0,d0:w),a0
	movew	d4,d0
	lsrw	#1,d0
	addw	d1,d0
	lea	a6@(0,d0:w),a1
	subqw	#1,d1
D.cmp:	addqw	#1,d1
	cmpmb	a0@+,a1@+
	beqs	D.cmp
putd1:	movew	d1,a5@(0,d4:w)

cpy_dad: 	movew	d2,a2@(0,d4:w)
	bmis	rootd4
	cmpw	a4@(0,d2:w),d5
	beqs	D.rt
	movew	d4,a3@(0,d2:w)
	moveml	sp@+,d2-d5/a2-a6
	rts
D.rt:	movew	d4,a4@(0,d2:w)
	moveml	sp@+,d2-d5/a2-a6
	rts

rootd4:	lsrw	#1,d5		| Occurs 50% of deletes
	lea	a6@(0,d5:w),a0
	moveq	#0,d0
	moveq	#0,d1
	moveb	a0@+,d0
	moveb	a0@+,d1
	moveb	a0@,d2
	eorb	d2,d1
	movew	d1,d2
	lslb	#4,d1
	eorw	d2,d1
	lslw	#4,d1
	clrb	d1
	addw	d1,d0
	addw	d0,d0		|104 = .5 sec per 100K
	movel	_adrs+12,a5
	movew	d4,a5@(0,d0:w)	| Update starting ptr
	moveml	sp@+,d2-d5/a2-a6
	rts

|----------
|- Insert -
|----------

I.mt:	movew	d6,a5@(0,d1:w)	| Set starting pt of tree
	moveq	#-1,d1
	movew	d1,a2@(0,d6:w)	| -1 marks root
 	extl	d7
	movel	d7,_match_length	| d7=0, No match
	moveml	sp@+,d2-d7/a2-a6
	rts

Isam:	addqw	#1,d0
	cmpw	d7,d0
	blts	ILcmp
	bra	I.full

	.text; .even
	| InsertNode(int r)
_InsertNode:
	moveml d2-d7/a2-a6,sp@-
	moveml	_adrs,a2-a6
	movel	sp@(48),d6
	addqw	#1,d6
	lea	a6@(0,d6:w),a0
	addw	d6,d6
	moveq	#0,d0
	moveq	#0,d1
	moveb	a0@+,d0
	moveb	a0@+,d1
	moveb	a0@,d2
	eorb	d2,d1
	movew	d1,d2
	lslb	#4,d1
	eorw	d2,d1
	lslw	#4,d1
	clrb	d1
	addw	d0,d1
	addw	d1,d1
	movew	a5@(0,d1:w),d7	| Get starting pt of tree
	beqs	I.mt		| 1st time character has been seen
	movel	_adrs2+12,a5
	moveq	#0,d2		| Clear L & R match lengths
	moveq	#0,d5
	moveq	#1,d0
	movew	d7,d1

Isame:	lsrw	#1,d7
	addw	d0,d7
	lea	a6@(0,d7:w),a1
	subql	#1,a0
	moveq	#F,d7
ILcmp:	cmpmb	a1@+,a0@+
	beqs	Isam
	blss	I.low
I.Ragain:
	cmpw	d0,d2
	bnes	Rset
	cmpw	d1,d3
	bccs	d1d3
	cmpw	d6,d1
	bcss	Ruzd1
	cmpw	d6,d3
	bccs	Ruzd1
	bras	Ruzd3

I.ckR:	movew	d7,d1
	cmpw	a5@(0,d7:w),d0	| Ck # of bytes that are the SAME as _dad
	bcss	I.Ragain
	beqs	Isame
I.part:	subaw	d0,a0		| 6%
	movew	a5@(0,d7:w),d0
	addaw	d0,a0		| Point to just after SAME data
	bras	Isame

d1d3:	cmpw	d6,d1
	bccs	Ruzd3
	cmpw	d6,d3
	bcss	Ruzd3
Rset:	movew	d0,d2		| Last match length R
Ruzd1:	movew	d1,d3		|		pos R
Ruzd3:	movew	a4@(0,d1:w),d7	| Link to rt son
	bnes	I.ckR
	movew	d1,a2@(0,d6:w)	| Node was mt, insert d6
	movew	d6,a4@(0,d1:w)
	movew	d0,a5@(0,d6:w)
	cmpw	d0,d5
	bcss	I.uzd3
	beqs	I.ck34
I.uzd4:	subw	d4,d6
	lsrw	#1,d6
	andw	#N-1,d6
	subqw	#1,d6
 	extl	d6
	movel	d6,_match_position	| Last Lt turn was longer
 	extl	d5
	movel	d5,_match_length
	moveml	sp@+,d2-d7/a2-a6
	rts

I.ckL:	movew	d7,d1
	cmpw	a5@(0,d7:w),d0	| Ck # of bytes that are the SAME as _dad
	beqs	Isame
	bccs	I.part
|				| Fall through to do Left again
I.low:	cmpw	d0,d5
	bnes	Lset
	cmpw	d1,d4
	bccs	d1d4
	cmpw	d6,d1
	bcss	Luzd1
	cmpw	d6,d4
	bcss	Luzd4
Lset:	movew	d0,d5		| Len L
Luzd1:	movew	d1,d4		| Pos L
Luzd4:	movew	a3@(0,d1:w),d7	| Link to lt son
	bnes	I.ckL
	movew	d1,a2@(0,d6:w)
	movew	d6,a3@(0,d1:w)
	movew	d0,a5@(0,d6:w)
	cmpw	d0,d2
	bcss	I.uzd4
	beqs	I.ck34
I.uzd3:	subw	d3,d6
	lsrw	#1,d6
	andw	#N-1,d6
	subqw	#1,d6
 	extl	d6
	movel	d6,_match_position	| Last Rt turn was longer
 	extl	d2
	movel	d2,_match_length
	moveml	sp@+,d2-d7/a2-a6
	rts

d1d4:	cmpw	d6,d1
	bccs	Luzd4
	cmpw	d6,d4
	bccs	Luzd1
	bras	Luzd4

I.ck34:	movew	d6,d2
	subw	d4,d6
	lsrw	#1,d6
	andw	#N-1,d6
	subw	d3,d2
	lsrw	#1,d2
	andw	#N-1,d2
	cmpw	d2,d6
	bcss	I.uzd6		| 56,58 from I.ck34
	subqw	#1,d2
 	extl	d2
	movel	d2,_match_position	| Last Lt turn was longer
 	extl	d0
	movel	d0,_match_length
	moveml	sp@+,d2-d7/a2-a6
	rts

I.uzd6:	subqw	#1,d6
 	extl	d6
	movel	d6,_match_position
 	extl	d0
	movel	d0,_match_length
	moveml	sp@+,d2-d7/a2-a6
	rts

I.full:	lea	a2@(0,d1:w),a1
	lea	a2@(0,d6:w),a0
	movew	a1@(_lson-_dad),d3	| Replace old node with new one
	movew	d3,a0@(_lson-_dad)
	movew	d6,a2@(0,d3:w)		|and point old sons to new
	movew	a1@(_rson-_dad),d3
	movew	d3,a0@(_rson-_dad)
	movew	d6,a2@(0,d3:w)
	movew	a5@(0,d1:w),a5@(0,d6:w)	| Move SAME
	movew	a1@,d3
	clrw	a1@			| Delete old
	clrw	a1@(_lson-_dad)
	clrw	a1@(_rson-_dad)
	movew	d3,a0@
	bmis	I.root
	cmpw	a4@(0,d3:w),d1
	beqs	I.rt
	movel	a3,a4
I.rt:	movew	d6,a4@(0,d3:w)
	subw	d1,d6
	lsrw	#1,d6
	andw	#N-1,d6
	subqw	#1,d6
 	extl	d6
	movel	d6,_match_position
	movel	#F,_match_length
	moveml	sp@+,d2-d7/a2-a6
	rts
I.root:	movew	d6,d3		| Occurs almost never
	lsrw	#1,d3
	lea	a6@(0,d3:w),a0
	moveq	#0,d3
	moveq	#0,d0
	moveb	a0@+,d3
	moveb	a0@+,d0
	moveb	a0@,d2
	eorb	d2,d0
	movew	d0,d2
	lslb	#4,d0
	eorw	d2,d0
	lslw	#4,d0
	clrb	d0
	addw	d0,d3
	addw	d3,d3
	movel	_adrs+12,a4	| ROOTS
	bras	I.rt

|-------------------------
|Insert with No Match data
|-------------------------

NM.mt:	movew	d6,a5@(0,d1:w)	| Set starting pt of tree
	moveq	#-1,d1
	movew	d1,a2@(0,d6:w)	| -1 marks root
	moveml	sp@+,d6-d7/a2-a6
	rts

 	.text; .even
_InsertNoMatch:
	moveml d6-d7/a2-a6,sp@-
	moveml	_adrs,a2-a6
	movel	a7@(32),d6
	addqw	#1,d6
	lea	a6@(0,d6:w),a0
	addw	d6,d6
	moveq	#0,d0
	moveq	#0,d1
	moveb	a0@+,d0
	moveb	a0@+,d1
	moveb	a0@,d7
	eorb	d7,d1
	movew	d1,d7
	lslb	#4,d1
	eorw	d7,d1
	lslw	#4,d1
	clrb	d1
	addw	d0,d1
	addw	d1,d1
	movew	a5@(0,d1:w),d7	| Get starting pt of tree
	beqs	NM.mt		| 1st time character has been seen
	movel	_adrs2+12,a5
	moveq	#1,d0
	movew	d7,d1

NMsame:	lsrw	#1,d7
	addw	d0,d7
	lea	a6@(0,d7:w),a1
	subql	#1,a0
	moveq	#F,d7
NMLcmp:	cmpmb	a1@+,a0@+
	bnes	NM.dif
	addqw	#1,d0
	cmpw	d7,d0
	blts	NMLcmp
	bra	NM.full

NM.dif:
	blss	NM.low
NM.Ragain:
	movew	a4@(0,d1:w),d7	| Link to rt son
	bnes	NM.ckR
	movew	d1,a2@(0,d6:w)	| Node was mt, insert d6
	movew	d6,a4@(0,d1:w)
	movew	d0,a5@(0,d6:w)
	moveml	sp@+,d6-d7/a2-a6
	rts

NM.ckR:	movew	d7,d1
	cmpw	a5@(0,d7:w),d0	| Ck # of bytes that are the SAME as _dad
	bcss	NM.Ragain
	beqs	NMsame
NM.part:	subaw	d0,a0	| 6%
	movew	a5@(0,d7:w),d0
	addaw	d0,a0		| Point to just after SAME data
	bras	NMsame

NM.ckL:	movew	d7,d1
	cmpw	a5@(0,d7:w),d0	| Ck # of bytes that are the SAME as _dad
	beqs	NMsame
	bccs	NM.part
|				| Fall through to do Left again
NM.low:	movew	a3@(0,d1:w),d7	| Link to lt son
	bnes	NM.ckL
	movew	d1,a2@(0,d6:w)
	movew	d6,a3@(0,d1:w)
	movew	d0,a5@(0,d6:w)
	moveml	sp@+,d6-d7/a2-a6
	rts

NM.full:
	lea	a2@(0,d1:w),a1
	lea	a2@(0,d6:w),a0
	movew	a1@(_lson-_dad),d7	| Replace old node with new one
	movew	d7,a0@(_lson-_dad)
	movew	d6,a2@(0,d7:w)		|and point old sons to new
	movew	a1@(_rson-_dad),d7
	movew	d7,a0@(_rson-_dad)
	movew	d6,a2@(0,d7:w)
	movew	a5@(0,d1:w),a5@(0,d6:w)	| Move SAME
	movew	a1@,d7
	clrw	a1@			| Delete old
	clrw	a1@(_lson-_dad)
	clrw	a1@(_rson-_dad)
	movew	d7,a0@
	bmis	NM.root
	cmpw	a4@(0,d7:w),d1
	beqs	NM.rt
	movel	a3,a4
NM.rt:	movew	d6,a4@(0,d7:w)
	moveml	sp@+,d6-d7/a2-a6
	rts
NM.root:
	movew	d6,d7		| Occurs almost never
	lsrw	#1,d7
	lea	a6@(0,d7:w),a0
	moveq	#0,d7
	moveq	#0,d0
	moveb	a0@+,d7
	moveb	a0@+,d0
	moveb	a0@,d1
	eorb	d1,d0
	movew	d0,d1
	lslb	#4,d0
	eorw	d1,d0
	lslw	#4,d0
	clrb	d0
	addw	d0,d7
	addw	d7,d7
	movel	_adrs+12,a4	| ROOTS
	bras	NM.rt

");
#endif
#endif
