#pragma warn -use
static char 	*sccsid = "@(#)TIFF/tif_fax3.c 1.34, Copyright (c) Sam Leffler, Dieter Linde, "__DATE__;
#pragma warn .use
/*
 * Copyright (c) 1988, 1990 by Sam Leffler, Nov 24 1990
 * All rights reserved.
 *
 * This file is provided for unrestricted use provided that this legend is included on all tape media and as a part of the
 * software program in whole or part.  Users may copy, modify or distribute this file at will.
 *
 * TIFF Library.
 *
 * CCITT Group 3 Facsimile-compatible Compression Scheme Support.
 *
 * This stuff was derived from code by Jef Pozkanzer.
 */
#include <stdlib.h>
#include "tiffio.h"
#include "tif_fax3.h"
#include "t4.h"
#include "g3codes.h"

typedef struct {
       	Fax3BaseState	b;
} Fax3DecodeState;

typedef struct {
        Fax3BaseState	b;
        u_char  	*wruns;
        u_char  	*bruns;
        short   	k;                   	/* #rows left that can be 2d encoded */
        short   	maxk;			/* max #rows that can be 2d encoded */
} Fax3EncodeState;

/****************************************************************************
 *
 */
void
TIFFModeCCITTFax3(
	TIFF 	*tif, 
	int  	isClassF
	)
{
       	if (isClassF)
               	tif->tif_options |= FAX3_CLASSF;
        else
                tif->tif_options &= ~FAX3_CLASSF;
}

#define is2DEncoding(tif) 	(tif->tif_dir.td_group3options & GROUP3OPT_2DENCODING)
#define fetchByte(tif, sp)     	(sp)->b.bitmap[*(u_char *)(tif)->tif_rawcp++]

#define BITCASE(b)              case b: \
        				code <<= 1; \
        				if (data & b) \
            					code |= 1; \
        				len++; \
        				if (code > 0) { \
        					bit = (b >> 1);	\
        					break; \
        				}

/****************************************************************************
 * Skip over input until an EOL code is found.
 */
static void
skiptoeol(
	TIFF 	*tif
	)
{
        Fax3DecodeState *sp = (Fax3DecodeState *)tif->tif_data;
        register int	bit = sp->b.bit;
        register int 	data = sp->b.data;
        int 		code, len;

        do {
                code = len = 0;
                switch (bit) {
        		again:  
        			BITCASE(0x80);
                		BITCASE(0x40);
                		BITCASE(0x20);
                		BITCASE(0x10);
                		BITCASE(0x08);
                		BITCASE(0x04);
                		BITCASE(0x02);
                		BITCASE(0x01);
                	default:
                        	if (tif->tif_rawcc <= 0) {
                            		TIFFError("skiptoeol", "%s: premature EOF at scanline %d", tif->tif_name, tif->tif_row);
                                	return;
                        	}
                        	data = fetchByte(tif, sp);
                        	goto again;
                }
        } while (len < 12 || code != EOL);
        sp->b.bit = bit;
        sp->b.data = data;
}

/****************************************************************************
 * Setup G3-related compression/decompression state before data is processed.  This routine
 * is called once per image -- it sets up different state based on whether or not 2D encoding is used.
 */
static void *
Fax3SetupState(
	TIFF 	*tif, 
	int  	space
	)
{
        TIFFDirectory 	*td = &tif->tif_dir;
        Fax3BaseState 	*sp;
        int 		cc = space;

        if (td->td_bitspersample != 1) {
                TIFFError(tif->tif_name, "Bits/sample must be 1 for Group 3/4 encoding/decoding");
                return(0);
        }
        if (is2DEncoding(tif) || td->td_compression == COMPRESSION_CCITTFAX4)
                cc += tif->tif_scanlinesize;
        tif->tif_data = malloc(cc);
        if (tif->tif_data == NULL) {
                TIFFError(tif->tif_name, "No space for Fax3 state block");
                return(0);
        }
        sp = (Fax3BaseState *)tif->tif_data;
        sp->bitmap = (tif->tif_fillorder != td->td_fillorder ? TIFFBitRevTable : TIFFNoBitRevTable);
        sp->white = (td->td_photometric == PHOTOMETRIC_MINISBLACK);
        if (is2DEncoding(tif) || td->td_compression == COMPRESSION_CCITTFAX4) {

	/*
         * 2d encoding/decoding requires a scanline buffer for the ``reference line''; the
         * scanline against which delta encoding is referenced.  The referennce line must
         * be initialized to be ``white.''
         */
                sp->refline = tif->tif_data + space;
                bzero(sp->refline, tif->tif_scanlinesize);
                if (sp->white == 1)
                        TIFFReverseBits(sp->refline, tif->tif_scanlinesize);
        } 
        else
                sp->refline = 0;
        return(sp);
}

/****************************************************************************
 * Setup state for decoding a strip.
 */
static int
Fax3PreDecode(
        TIFF 	*tif
        )
{
        Fax3DecodeState	*sp = (Fax3DecodeState *)tif->tif_data;

        if (sp == NULL) {
                sp = (Fax3DecodeState *)Fax3SetupState(tif, (int)sizeof(*sp));
                if (!sp)
                        return(0);
        }
        sp->b.bit = 0;                         	/* force initial read */
        sp->b.data = 0;
        sp->b.tag = G3_1D;

        /*
         * Non-TIFF/F images have an initial blank line that we need to skip over.  Note that this
         * is only done at the beginning of the image, not at the start of each strip.
         */
        if (tif->tif_curstrip == 0 && (tif->tif_options & FAX3_CLASSF) == 0)
                skiptoeol(tif);
        return(1);
}

/****************************************************************************
 * Fill a span with ones.
 */
static void
fillspan(
       	register char	*cp,
        register int 	x, 
        register int	count
        )
{
        static u_char	masks[] = { 0, 0x80, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc, 0xfe, 0xff };

        cp += (x >> 3);
        if (x &= 7) {                  	/* align to byte boundary */
                if (count < 8 - x) {
                        *cp++ |= (masks[count] >> x);
                        return;
                }
                *cp++ |= (0xff >> x);
                count -= 8 - x;
        }
        while (count >= 8) {
                *cp++ = 0xff;
                count -= 8;
        }
        *cp |= masks[count];
}

/****************************************************************************
 * Process one row of 1d Huffman-encoded data.
 */
static int
Fax3Decode1DRow(
       	TIFF 	*tif,
        u_char	*buf,
        int 	npels
        )
{
        Fax3DecodeState	*sp = (Fax3DecodeState *)tif->tif_data;
        short 		bit = sp->b.bit;
        short 		data = sp->b.data;
        int 		x = 0;
        int 		count = 0;
        short 		len = 0;
        short 		code = 0;
        short 		color = sp->b.white;
        tableentry 	*te;
        static char 	module[] = "Fax3Decode1D";

        for (;;) {
                switch (bit) {
		        again:  
		        	BITCASE(0x80);
                		BITCASE(0x40);
		                BITCASE(0x20);
                		BITCASE(0x10);
		                BITCASE(0x08);
                		BITCASE(0x04);
		                BITCASE(0x02);
                		BITCASE(0x01);
	                default:
        	                if (tif->tif_rawcc <= 0) {
                			TIFFError(module, "%s: Premature EOF at scanline %d (x %d)", tif->tif_name, tif->tif_row, x);
                                	return(0);
                        	}
                        	data = fetchByte(tif, sp);
                        	goto again;
                }
                if (len >= 12) {
                        if (code == EOL) {
                                if (x == 0) {
                                        TIFFWarning(tif->tif_name, "%s: Ignoring null row at scanline %d", module, tif->tif_row);
                                        code = len = 0;
                                        continue;
                                }
                                sp->b.bit = bit;
                                sp->b.data = data;
                                TIFFWarning(tif->tif_name, "%s: Premature EOL at scanline %d (x %d)", module, tif->tif_row, x);
                                return(1);    	/* try to resynchronize... */
                        }
                        if (len > 13) {
                                TIFFError(tif->tif_name, "%s: Bad code word (len %d code 0x%x) at scanline %d (x %d)", module, len, code, tif->tif_row, x);
                                break;
                        }
                }
                if (color == sp->b.white) {
                        u_char 	ix = TIFFFax3wtab[code << (13 - len)];

                        if (ix == 0xff)
                                continue;
                        te = &TIFFFax3wcodes[ix];
                } 
                else {
                        u_char 	ix = TIFFFax3btab[code << (13 - len)];

                        if (ix == 0xff)
                                continue;
                        te = &TIFFFax3bcodes[ix];
                }
                if (te->length != len)
                        continue;
                count += te->count;
                if (te->tabid < 0) {           	/* terminating code */
                        if (x + count > npels)
                                count = npels - x;
                        if (count > 0) {
                                if (color)
                                        fillspan((char *)buf, x, count);
                                x += count;
                                if (x >= npels)
                                        break;
                        }
                        count = 0;
                        color = !color;
                }
                code = len = 0;
        }
        sp->b.data = data;
        sp->b.bit = bit;

        /*
         * Cleanup at the end of the row.  This convoluted logic is merely so that we can reuse the code with
         * two other related compression algorithms (2 & 32771).
         *
         * Note also that our handling of word alignment assumes that the buffer is at least word aligned.  This is
         * the case for most all versions of malloc (typically the buffer is returned longword aligned).
         */
        if ((tif->tif_options & FAX3_NOEOL) == 0)
                skiptoeol(tif);
        if (tif->tif_options & FAX3_BYTEALIGN)
                sp->b.bit = 0;
        if ((tif->tif_options & FAX3_WORDALIGN) && ((long)tif->tif_rawcp & 1)) {
                tif->tif_rawcp++;
                tif->tif_rawcc--;
       	}
        return(x == npels);
}

/****************************************************************************
 * Decode the requested amount of data.
 */
static int
Fax3Decode(
       	TIFF 	*tif,
        u_char 	*buf,
        int 	occ
        )
{
        Fax3DecodeState	*sp = (Fax3DecodeState *)tif->tif_data;
        int 		scanline = tif->tif_scanlinesize;
        int 		imagewidth = tif->tif_dir.td_imagewidth;

        bzero(buf, occ);               	/* decoding only sets non-zero bits */
        while (occ > 0) {
                if (sp->b.tag == G3_1D) {
                        if (!Fax3Decode1DRow(tif, buf, imagewidth))
                                return(0);
                } 
                else {
                        if (!Fax3Decode2DRow(tif, buf, imagewidth))
                                return(0);
                }
                if (is2DEncoding(tif)) {

	/*
         * Fetch the tag bit that indicates whether the next row is 1d or 2d
         * encoded.  If 2d-encoded, then setup the reference line from the decoded
         * scanline just completed.
         */
                        if (sp->b.bit == 0) {
                                if (tif->tif_rawcc <= 0) {
                                        TIFFError("Fax3Decode", "%s: Premature EOF at scanline %d", tif->tif_name, tif->tif_row);
                                        return(0);
                                }
                                sp->b.data = fetchByte(tif, sp);
                                sp->b.bit = 0x80;
                        }
                        sp->b.tag = (sp->b.data & sp->b.bit) ? G3_1D : G3_2D;
                        sp->b.bit >>= 1;
                        if (sp->b.tag == G3_2D)
                                bcopy(buf, sp->b.refline, scanline);
                }
                buf += scanline;
                occ -= scanline;
        }
        return(1);
}

/*
 * Group 3 2d Decoding support.
 *
 * NB: the order of the decoding modes is used below 
 */
#define MODE_HORIZ     	0      	/* horizontal mode, handling 1st runlen */
#define MODE_HORIZ1     1       /* horizontal mode, handling 2d runlen */
#define MODE_OTHER      2       /* !horizontal mode */

#define PACK(code, len)	(((len) << 2) + (code))

/*
 * Group 3 2d decoding modes 
 */
#define PASS           	1
#define HORIZONTAL      2
#define VERTICAL        3
#define EXTENSION       4
#define UNCOMPRESSED   	1

#define PACKINFO(mode, v)	(((v) << 4) + mode)
#define UNPACKMODE(v)           ((v) & 0xf)
#define UNPACKINFO(v)           ((v) >> 4)

static short	g32dtab[56] = {
	0,   0,   0,   0,   0,   3,   0,   0,   /* 0x00 - 0x07 */
       	0,   0,   0,   0,   0,   2, -13,  19,   /* 0x08 - 0x0f */
       	0,   1,   0,   0,   0,   0,   0,   0,   /* 0x10 - 0x17 */
       	0,   0, -29,  35,   0,   0, -45,  51,   /* 0x18 - 0x1f */
       	0,   0,   0,   0,   0,   0,   0,   0,   /* 0x20 - 0x27 */
       	0,   0,   0,   0,   0,   0,   0,   0,   /* 0x28 - 0x2f */
       	0,   0,   0,   0,   0,   0,   0,  20,	/* 0x30 - 0x37 */
};

#define	NG32D	(sizeof(g32dtab) / sizeof(g32dtab[0]))

/*
 * Bit handling utilities.
 */

static u_char	zeroruns[256] = {
    	8, 7, 6, 6, 5, 5, 5, 5, 4, 4, 4, 4, 4, 4, 4, 4,		/* 0x00 - 0x0f */
    	3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,     	/* 0x10 - 0x1f */
    	2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,     	/* 0x20 - 0x2f */
	2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,     	/* 0x30 - 0x3f */
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,     	/* 0x40 - 0x4f */
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,     	/* 0x50 - 0x5f */
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,     	/* 0x60 - 0x6f */
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,     	/* 0x70 - 0x7f */
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,     	/* 0x80 - 0x8f */
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,     	/* 0x90 - 0x9f */
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,     	/* 0xa0 - 0xaf */
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,     	/* 0xb0 - 0xbf */
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,     	/* 0xc0 - 0xcf */
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,     	/* 0xd0 - 0xdf */
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,     	/* 0xe0 - 0xef */
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,     	/* 0xf0 - 0xff */
};
static u_char	oneruns[256] = {
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,     	/* 0x00 - 0x0f */
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,     	/* 0x10 - 0x1f */
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,     	/* 0x20 - 0x2f */
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,     	/* 0x30 - 0x3f */
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,     	/* 0x40 - 0x4f */
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,     	/* 0x50 - 0x5f */
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,     	/* 0x60 - 0x6f */
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,     	/* 0x70 - 0x7f */
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,     	/* 0x80 - 0x8f */
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,     	/* 0x90 - 0x9f */
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,     	/* 0xa0 - 0xaf */
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,     	/* 0xb0 - 0xbf */
	2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,     	/* 0xc0 - 0xcf */
	2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,     	/* 0xd0 - 0xdf */
	3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,     	/* 0xe0 - 0xef */
	4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 6, 6, 7, 8,     	/* 0xf0 - 0xff */
};

/****************************************************************************
 * Find a span of ones or zeros using the supplied table.  The byte-aligned start of the bit string
 * is supplied along with the start+end bit indices.  The table gives the number of consecutive ones or
 * zeros starting from the msb and is indexed by byte value.
 */
static int
findspan(
        u_char 		**bpp,
        int 		bs, 
        int		be,
        register u_char	*tab
        )
{
        register u_char	*bp = *bpp;
        register int 	bits = be - bs;
        register int 	n, span;

        /*
         * Check partial byte on lhs.
         */
        if (bits > 0 && ((n = (bs & 7)) != 0)) {
                span = tab[(*bp << n) & 0xff];
                if (span > 8 - n)     	/* table value too generous */
                        span = 8 - n;
                if (n + span < 8)      	/* doesn't extend to edge of byte */
                        goto done;
                bits -= span;
                bp++;
        } 
        else
                span = 0;

        /*
         * Scan full bytes for all 1's or all 0's.
         */
        while (bits >= 8) {
                n = tab[*bp];
                span += n;
                bits -= n;
                if (n < 8)             	/* end of run */
                        goto done;
                bp++;
        }

        /*
         * Check partial byte on rhs.
         */
        if (bits > 0) {
                n = tab[*bp];
                span += (n > bits ? bits : n);
        }
done:
        *bpp = bp;
        return(span);
}

/****************************************************************************
 * Return the offset of the next bit in the range [bs..be] that is different from bs.  The end,
 * be, is returned if no such bit exists.
 */
static int
finddiff(
        u_char 	*cp,
        int 	bs, 
        int	be
        )
{
        cp += (bs >> 3);           	/* adjust byte offset */
        return(bs + findspan(&cp, bs, be, (*cp & (0x80 >> (bs & 7))) ? oneruns : zeroruns));
}

/****************************************************************************
 * Process one row of 2d encoded data.
 */
int
Fax3Decode2DRow(
        TIFF 	*tif,
        u_char 	*buf,
        int 	npels
        )
{
#define	PIXEL(buf, ix)	((((buf)[(ix) >> 3]) >> (7 - ((ix) & 7))) & 1)
        Fax3DecodeState	*sp = (Fax3DecodeState *)tif->tif_data;
        short 		bit = sp->b.bit;
        short 		data = sp->b.data;
        short 		len = 0;
        short 		code = 0;
        int 		a0 = 0;
        int 		b1 = 0;
        int 		b2 = 0;
        int 		count = 0;
        short 		mode = MODE_OTHER;
        short 		color = sp->b.white;
        static char 	module[] = "Fax3Decode2D";

        do {
                switch (bit) {
        		again:  
        			BITCASE(0x80);
                		BITCASE(0x40);
		                BITCASE(0x20);
                		BITCASE(0x10);
		                BITCASE(0x08);
                		BITCASE(0x04);
		                BITCASE(0x02);
                		BITCASE(0x01);
	                default:
        	                if (tif->tif_rawcc <= 0) {
                	            	TIFFError(module, "%s: Premature EOF at scanline %d", tif->tif_name, tif->tif_row);
                                	return(0);
                        	}
                        	data = fetchByte(tif, sp);
                        	goto again;
                }
                if (len >= 12) {
                        if (code == EOL) {
                                if (a0 == 0) {
                                       	TIFFWarning(tif->tif_name, "%s: Ignoring null row at scanline %d", module, tif->tif_row);
                                        code = len = 0;
                                        continue;
                                }
                                sp->b.bit = bit;
                                sp->b.data = data;
                                TIFFWarning(tif->tif_name, "%s: Premature EOL at scanline %d (x %d)", module, tif->tif_row, a0);
                                return(1);    	/* try to resynchronize... */
                        }
                        if (len > 13) {
                               	TIFFError(tif->tif_name, "%s: Bad code word (len %d code 0x%x) at scanline %d", module, len, code, tif->tif_row);
                                break;
                        }
                }
                if (mode != MODE_OTHER) {
                        tableentry	*te;

	/*
         * In horizontal mode, collect 1d code words that represent a0.a1 and a1.a2.
         */
                        if (color == sp->b.white) {
                                u_char ix = TIFFFax3wtab[code << (13 - len)];
                                if (ix == 0xff)
                                       	continue;
                                te = &TIFFFax3wcodes[ix];
                        } 
                        else {
                                u_char ix = TIFFFax3btab[code << (13 - len)];
                                if (ix == 0xff)
                                        continue;
                                te = &TIFFFax3bcodes[ix];
                        }
                        if (te->length != len)
                                continue;
                        count += te->count;
                        if (te->tabid < 0) {   	/* terminating code */
                                if (a0 + count > npels)
                                        count = npels - a0;
                                if (count > 0) {
                                        if (color)
                                                fillspan((char *)buf, a0, count);
                                        a0 += count;
                                }
                                mode++;        	/* NB: assumes state ordering */
                                count = 0;
                                color = !color;
                        }
                } 
                else {
                        int 	v = PACK(code, len);

                        if (v >= NG32D || ((v = g32dtab[v]) == 0)) {
                                continue;
                        }
                        switch (UNPACKMODE(v)) {
	                        case PASS:
        	                        b1 = (a0 || PIXEL(sp->b.refline, 0)) ? finddiff(sp->b.refline, a0, npels) : 0;
	                                if (color == PIXEL(sp->b.refline, b1))
                                        b1 = finddiff(sp->b.refline, b1, npels);
                                	b2 = finddiff(sp->b.refline, b1, npels);
	                                if (color)
        	                                fillspan((char *)buf, a0, b2 - a0);
                	                a0 += b2 - a0;
                        	        break;
	                        case HORIZONTAL:
        	                        mode = MODE_HORIZ;
                	                count = 0;
                        	        break;
	                        case VERTICAL:
        	                        b1 = (a0 || PIXEL(sp->b.refline, 0)) ? finddiff(sp->b.refline, a0, npels) : 0;
	                                if (color == PIXEL(sp->b.refline, b1))
        	                                b1 = finddiff(sp->b.refline, b1, npels);
                	                b1 += UNPACKINFO(v);
                        	        if (color)
                                	        fillspan((char *)buf, a0, b1 - a0);
	                                a0 += b1 - a0;
        	                        color = !color;
                	                break;
                        	case EXTENSION:
                                	/*** XXX fill in... ***/
                                	break;
                        }
                }
                code = len = 0;
        } while (a0 < npels);
        sp->b.data = data;
        sp->b.bit = bit;

        /*
         * Cleanup at the end of row.  We check for EOL separately so that this code can be
         * reused by the Group 4 decoding routine.
         */
        if ((tif->tif_options & FAX3_NOEOL) == 0)
                skiptoeol(tif);
        return(a0 >= npels);
#undef 	PIXEL
}

/*
 * CCITT Group 3 FAX Encoding.
 */

/****************************************************************************
 * Write a variable-length bit-value to the output stream.  Values are
 * assumed to be at most 16 bits.
 */
static void
putbits(
     	TIFF 	*tif,
        u_int 	bits, 
        u_int	length
        )
{
        Fax3BaseState	*sp = (Fax3BaseState *)tif->tif_data;
        static int 	mask[9] = { 0x00, 0x01, 0x03, 0x07, 0x0f, 0x1f, 0x3f, 0x7f, 0xff };

        while (length > sp->bit) {
                sp->data |= (bits >> (length - sp->bit));
                if (tif->tif_rawcc >= tif->tif_rawdatasize)
                       	TIFFFlushData1(tif);
                *tif->tif_rawcp++ = sp->bitmap[sp->data];
                tif->tif_rawcc++;
                length -= sp->bit;
                sp->data = 0;
                sp->bit = 8;
        }
        sp->data |= ((bits & mask[length]) << (sp->bit - length));
        sp->bit -= length;
        if (sp->bit == 0) {
                if (tif->tif_rawcc >= tif->tif_rawdatasize)
                       	TIFFFlushData1(tif);
                *tif->tif_rawcp++ = sp->bitmap[sp->data];
                tif->tif_rawcc++;
                sp->data = 0;
                sp->bit = 8;
        }
}

/****************************************************************************
 * Write a code to the output stream.
 */
static void
putcode(
       	TIFF 		*tif,
        tableentry 	*te
        )
{
        putbits(tif, te->code, te->length);
}

/****************************************************************************
 * Write the sequence of codes that describes the specified span of zero's or one's.  The
 * appropriate tables that hold the make-up and terminating codes are supplied.
 */
static void
putspan(
        TIFF 		*tif,
        int 		span,
        tableentry 	*mtab,
        tableentry 	*ttab
        )
{
        if (span >= 64) {
                tableentry	*te = &mtab[(span / 64) - 1];

                putcode(tif, te);
                span -= te->count;
        }
        putcode(tif, &ttab[span]);
}

/****************************************************************************
 * Write an EOL code to the output stream.  The zero-fill logic for byte-aligning encoded scanlines is handled
 * here.  We also handle writing the tag bit for the next scanline when doing 2d encoding.
 *
 * Note that when doing 2d encoding, we byte-align the combination of the EOL + tag bits.  It is unclear
 * (to me) from the documentation whether this is the correct behaviour, or whether the EOL should be
 * aligned and the tag bit should be the first bit in the next byte.  I've implemented what seems to make
 * the most sense.
 */
void
Fax3PutEOL(
       	TIFF 	*tif
       	)
{
        Fax3BaseState	*sp = (Fax3BaseState *)tif->tif_data;

        if (tif->tif_dir.td_group3options & GROUP3OPT_FILLBITS) {

	/*
         * Force bit alignment so EOL (+tag bit) will terminate on a byte boundary.  That is, force
         * the bit alignment to 16-12 = 4 (or 16-13 = 3 for 2d encoding) before putting out the EOL code.
         */
                int 	align = 8 - (is2DEncoding(tif) ? 3 : 4);

                if (align != sp->bit) {
                        if (align > sp->bit)
                                align = sp->bit + (8 - align);
                        else
                                align = sp->bit - align;
                        putbits(tif, 0, align);
                }
        }
        putbits(tif, EOL, 12);
        if (is2DEncoding(tif))
                putbits(tif, sp->tag == G3_1D, 1);
}

/****************************************************************************
 * Reset encoding state at the start of a strip.
 */
static int
Fax3PreEncode(
        TIFF 	*tif
        )
{
        Fax3EncodeState	*sp = (Fax3EncodeState *)tif->tif_data;

        if (sp == NULL) {
                sp = (Fax3EncodeState *)Fax3SetupState(tif, (int)sizeof(*sp));
                if (!sp)
                        return(0);
                if (sp->b.white == 0) {
                        sp->wruns = zeroruns;
                        sp->bruns = oneruns;
                } 
                else {
                        sp->wruns = oneruns;
                        sp->bruns = zeroruns;
                }
        }
        sp->b.bit = 8;
        sp->b.data = 0;
        sp->b.tag = G3_1D;
        if (is2DEncoding(tif)) {
                float res = tif->tif_dir.td_yresolution;

	/*
         * The CCITT spec says that when doing 2d encoding, you should only do it on K consecutive scanlines, where K
         * depends on the resolution of the image being encoded (2 for <= 200 lpi, 4 for > 200 lpi).  Since the directory
         * code initializes td_yresolution to 0, this code will select a K of 2 unless the YResolution tag is set
         * appropriately.  (Note also that we fudge a little here and use 150 lpi to avoid problems with units conversion.)
         */
                if (tif->tif_dir.td_resolutionunit == RESUNIT_CENTIMETER)
                        res = (res * .3937) / 2.54;    	/* convert to inches */
                sp->maxk = (res > 150 ? 4 : 2);
                sp->k = sp->maxk-1;
        } 
        else
                sp->k = sp->maxk = 0;
        if ((tif->tif_options & FAX3_CLASSF) == 0 && tif->tif_curstrip == 0)
                Fax3PutEOL(tif);
        return(1);
}

/****************************************************************************
 * 1d-encode a row of pixels.  The encoding is a sequence of all-white or all-black spans
 * of pixels encoded with Huffman codes.
 */
static void
Fax3Encode1DRow(
        TIFF 	*tif,
        u_char 	*bp,
        int 	bits
        )
{
        Fax3EncodeState	*sp = (Fax3EncodeState *)tif->tif_data;
        int 		bs = 0;
        int		span;

        for (;;) {
                span = findspan(&bp, bs, bits, sp->wruns);     	/* white span */
                putspan(tif, span, g3mwtab, g3twtab);
                bs += span;
                if (bs >= bits)
                        break;
                span = findspan(&bp, bs, bits, sp->bruns);      /* black span */
                putspan(tif, span, g3mbtab, g3tbtab);
                bs += span;
                if (bs >= bits)
                        break;
        }
}

static tableentry	horizcode = { 0x1, 3 };
static tableentry 	passcode = { 0x1, 4 };

static tableentry 	vcodes[7] = {
				{ 0x3, 7 }, 
				{ 0x3, 6 }, 
				{ 0x3, 3 },
    				{ 0x1, 1 },
    				{ 0x2, 3 }, 
    				{ 0x2, 6 }, 
    				{ 0x2, 7 },
};

/****************************************************************************
 * 2d-encode a row of pixels.  Consult the CCITT documentation for the algorithm.
 */
int
Fax3Encode2DRow(
        TIFF 	*tif,
        u_char 	*bp, 
        u_char	*rp,
        int 	bits
        )
{
#define PIXEL(buf, ix)	((((buf)[(ix) >> 3]) >> (7 - ((ix) & 7))) & 1)
        short	white = ((Fax3BaseState *)tif->tif_data)->white;
        int 	a0 = 0;
        int 	a1 = (PIXEL(bp, 0) != white ? 0 : finddiff(bp, 0, bits));
        int 	a2 = 0;
        int 	b1 = (PIXEL(rp, 0) != white ? 0 : finddiff(rp, 0, bits));
        int 	b2 = 0;

        for (;;) {
                b2 = finddiff(rp, b1, bits);
                if (b2 >= a1) {
                        int	d = b1 - a1;

                        if (!(-3 <= d && d <= 3)) {    	/* horizontal mode */
                                a2 = finddiff(bp, a1, bits);
                                putcode(tif, &horizcode);
                                if (a0 + a1 == 0 || PIXEL(bp, a0) == white) {
                                        putspan(tif, a1 - a0, g3mwtab, g3twtab);
                                        putspan(tif, a2 - a1, g3mbtab, g3tbtab);
                                } 
                                else {
                                        putspan(tif, a1 - a0, g3mbtab, g3tbtab);
                                        putspan(tif, a2 - a1, g3mwtab, g3twtab);
                                }
                                a0 = a2;
                        } 
                        else {                       	/* vertical mode */
                                putcode(tif, &vcodes[d + 3]);
                                a0 = a1;
                        }
                } 
                else {                                	/* pass mode */
                        putcode(tif, &passcode);
                        a0 = b2;
                }
                if (a0 >= bits)
                        break;
                a1 = finddiff(bp, a0, bits);
                b1 = finddiff(rp, a0, bits);
                if (PIXEL(rp, b1) == PIXEL(bp, a0))
                        b1 = finddiff(rp, b1, bits);
        }
        return(1);
#undef 	PIXEL
}

/****************************************************************************
 * Encode a buffer of pixels.
 */
static int
Fax3Encode(
        TIFF 	*tif,
        u_char 	*bp,
        int 	cc
        )
{
        Fax3EncodeState	*sp = (Fax3EncodeState *)tif->tif_data;
        int 		scanline = tif->tif_scanlinesize;
        int 		imagewidth = tif->tif_dir.td_imagewidth;

        while (cc > 0) {
                if (is2DEncoding(tif)) {
                        if (sp->b.tag == G3_1D) {
                               	Fax3Encode1DRow(tif, bp, imagewidth);
/*                             	if (!Fax3Encode1DRow(tif, bp, imagewidth))
                                        return(0);*/
                                sp->b.tag = G3_2D;
                        } 
                        else {
                               	if (!Fax3Encode2DRow(tif, bp, sp->b.refline, imagewidth))
                                        return(0);
                                sp->k--;
                        }
                        if (sp->k == 0) {
                                sp->b.tag = G3_1D;
                                sp->k = sp->maxk - 1;
                        } 
                        else
                                bcopy(bp, sp->b.refline, scanline);
                } 
                else {
                        Fax3Encode1DRow(tif, bp, imagewidth);
/*                      if (!Fax3Encode1DRow(tif, bp, imagewidth))
                                return(0);*/
                }
                Fax3PutEOL(tif);
                bp += scanline;
                cc -= scanline;
        }
        return(1);
}

/****************************************************************************
 *
 */
static int
Fax3PostEncode(
        TIFF 	*tif
        )
{
        Fax3EncodeState	*sp = (Fax3EncodeState *)tif->tif_data;

        if (sp->b.bit != 8) {
                if (tif->tif_rawcc >= tif->tif_rawdatasize && !TIFFFlushData1(tif))
                        return(0);
                *tif->tif_rawcp++ = sp->b.bitmap[sp->b.data];
                tif->tif_rawcc++;
        }
        return(1);
}

/****************************************************************************
 *
 */
static void
Fax3Close(
        TIFF 	*tif
        )
{
        if ((tif->tif_options & FAX3_CLASSF) == 0) {   	/* append RTC */
                int 	i;

                for (i = 0; i < 6; i++)
                        Fax3PutEOL(tif);
               	Fax3PostEncode(tif);
        }
}

/****************************************************************************
 *
 */
static void
Fax3Cleanup(
        TIFF 	*tif
        )
{
        if (tif->tif_data) {
                free(tif->tif_data);
                tif->tif_data = NULL;
        }
}

/****************************************************************************
 *
 */
int
TIFFInitCCITTFax3(
	TIFF 	*tif
	)
{
        tif->tif_stripdecode = Fax3PreDecode;
        tif->tif_decoderow = Fax3Decode;
        tif->tif_stripencode = Fax3PreEncode;
        tif->tif_encoderow = Fax3Encode;
        tif->tif_encodestrip = Fax3PostEncode;
        tif->tif_close = Fax3Close;
        tif->tif_cleanup = Fax3Cleanup;
        tif->tif_options |= FAX3_CLASSF;        /* default */
        tif->tif_flags |= TIFF_NOBITREV;        /* we handle bit reversal */
        return(1);
}
