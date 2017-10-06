#pragma warn -use
static char 	*sccsid = "@(#)TIFF/tif_lzw.c 1.20, Copyright (c) Sam Leffler, Dieter Linde, "__DATE__;
#pragma warn .use
/*
 * Copyright (c) 1988, 1990 by Sam Leffler, Oct 8 1990
 * All rights reserved.
 *
 * This file is provided for unrestricted use provided that this legend is included on all tape media and as a part of the
 * software program in whole or part.  Users may copy, modify or distribute this file at will.
 *
 * TIFF Library.
 *
 * Rev 5.0 Lempel-Ziv & Welch Compression Support
 *
 * Copyright (c) 1985, 1986 The Regents of the University of California.
 * All rights reserved.
 *
 * This code is derived from software contributed to Berkeley by James A. Woods, derived from original work by Spencer Thomas
 * and Joseph Orost.
 *
 * Redistribution and use in source and binary forms are permitted provided that the above copyright notice and this paragraph are
 * duplicated in all such forms and that any documentation, advertising materials, and other materials related to such
 * distribution and use acknowledge that the software was developed by the University of California, Berkeley.  The name of the
 * University may not be used to endorse or promote products derived from this software without specific prior written permission.
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
 * WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
 */
#include <stdio.h>
#include <assert.h>
#include "tiffio.h"

#define MAXCODE(n)	((1 << (n)) - 1)

/*
 * The TIFF spec specifies that encoded bit strings range from 9 to 12 bits.  This is somewhat unfortunate in that
 * experience indicates full color RGB pictures often need ~14 bits for reasonable compression.
 */
#define BITS_MIN   	9               /* start with 9 bits */
#define BITS_MAX     	12            	/* max of 12 bit strings */
/*** predefined codes ***/
#define CODE_CLEAR     	256             /* code to clear string table */
#define CODE_EOI        257             /* end-of-information code */
#define CODE_FIRST      258             /* first free code entry */
#define CODE_MAX        MAXCODE(BITS_MAX)
#if 0
#define HSIZE           9001            /* 91% occupancy */
#define HSHIFT          (8 - (16 - 13))
#else
#define HSIZE           5003            /* 80% occupancy */
#define HSHIFT          (8 - (16 - 12))
#endif

/*
 * NB: The 5.0 spec describes a different algorithm than Aldus implements.  Specifically, Aldus does code length transitions
 *     one code earlier than should be done (for real LZW).  Earlier versions of this library implemented the correct
 *     LZW algorithm, but emitted codes in a bit order opposite to the TIFF spec.  Thus, to maintain compatibility w/ Aldus
 *     we interpret MSB-LSB ordered codes to be images written w/ old versions of this library, but otherwise adhere to the
 *     Aldus "off by one" algorithm.
 *
 * Future revisions to the TIFF spec are expected to "clarify this issue".
 */
#define SetMaxCode(sp, v)	{ \
        				(sp)->lzw_maxcode = (v) - 1; \
        				if ((sp)->lzw_flags & LZW_COMPAT) \
                				(sp)->lzw_maxcode++; \
				}

/*
 * Decoding-specific state.
 */
struct decode {
       	short  	prefixtab[HSIZE];      		/* prefix(code) */
        u_char  suffixtab[CODE_MAX + 1];  	/* suffix(code) */
        u_char  stack[HSIZE - (CODE_MAX + 1)];
        u_char  *stackp;                	/* stack pointer */
        int     firstchar;              	/* of string associated w/ last code */
};

/*
 * Encoding-specific state.
 */
struct encode {
        long   	checkpoint;             	/* point at which to clear table */
#define	CHECK_GAP	10000           	/* enc_ratio check interval */
        long    ratio;                  	/* current compression ratio */
        long    incount;                	/* (input) data bytes encoded */
        long    outcount;               	/* encoded (output) bytes */
        long    htab[HSIZE];            	/* hash table */
        short   codetab[HSIZE];         	/* code table */
};

/*
 * State block for each open TIFF file using LZW compression/decompression.
 */
typedef struct {
        int     lzw_oldcode;            	/* last code encountered */
        u_char  lzw_hordiff;
#define LZW_HORDIFF4	0x01            	/* hor. diff w/ 4-bit samples */
#define LZW_HORDIFF8    0x02            	/* hor. diff w/ 8-bit samples */
#define LZW_HORDIFF16   0x04            	/* hor. diff w/ 16-bit samples */
#define LZW_HORDIFF32   0x08            	/* hor. diff w/ 32-bit samples */
        u_char  lzw_flags;
#define LZW_RESTART     0x01            	/* restart interrupted decode */
#define LZW_COMPAT      0x02            	/* read old bit-reversed codes */
        u_short lzw_nbits;              	/* number of bits/code */
        u_short lzw_stride;             	/* horizontal diferencing stride */
        int     lzw_maxcode;            	/* maximum code for lzw_nbits */
        long    lzw_bitoff;             	/* bit offset into data */
        long    lzw_bitsize;            	/* size of strip in bits */
        int     lzw_free_ent;           	/* next free entry in hash table */
        union {
                struct decode	dec;
                struct encode 	enc;
        } u;
} LZWState;

#define dec_prefix     	u.dec.prefixtab
#define dec_suffix      u.dec.suffixtab
#define dec_stack       u.dec.stack
#define dec_stackp      u.dec.stackp
#define dec_firstchar   u.dec.firstchar

#define enc_checkpoint  u.enc.checkpoint
#define enc_ratio       u.enc.ratio
#define enc_incount     u.enc.incount
#define enc_outcount    u.enc.outcount
#define enc_htab        u.enc.htab
#define enc_codetab     u.enc.codetab

/*
 * Masks for extracting/inserting variable length bit codes.
 */
static u_char	rmask[9] = { 0x00, 0x01, 0x03, 0x07, 0x0f, 0x1f, 0x3f, 0x7f, 0xff };
static u_char 	lmask[9] = { 0x00, 0x80, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc, 0xfe, 0xff };

/****************************************************************************
 *
 */
static int
LZWCheckPredictor(
       	TIFF 		*tif,
        LZWState	*sp
        )
{
        TIFFDirectory *td = &tif->tif_dir;

        switch (td->td_predictor) {
	        case 1:
        	        break;
	        case 2:
        	        sp->lzw_stride = (td->td_planarconfig == PLANARCONFIG_CONTIG ? td->td_samplesperpixel : 1);
	                if (td->td_bitspersample == 8) {
        	                sp->lzw_hordiff = LZW_HORDIFF8;
                	        break;
	                }
        	        if (td->td_bitspersample == 16) {
                	        sp->lzw_hordiff = LZW_HORDIFF16;
	                        break;
        	        }
                	TIFFError(tif->tif_name, "Horizontal differencing \"Predictor\" not supported with %d-bit samples", td->td_bitspersample);
	                return(0);
	        default:
        	        TIFFError(tif->tif_name, "\"Predictor\" value %d not supported", td->td_predictor);
                	return(0);
        }
        return(1);
}

/*
 * LZW Decoder.
 */

/****************************************************************************
 * Setup state for decoding a strip.
 */
static int
LZWPreDecode(
       	TIFF 	*tif
       	)
{
        register LZWState	*sp = (LZWState *)tif->tif_data;
        register int 		code;

        if (sp == NULL) {
                if ((tif->tif_data = malloc(sizeof(LZWState))) == NULL) {
                        TIFFError("LZWPreDecode", "No space for LZW state block");
                       	return(0);
                }
                sp = (LZWState *)tif->tif_data;
                sp->lzw_flags = 0;
                sp->lzw_hordiff = 0;
                if (!LZWCheckPredictor(tif, sp))
                        return(0);
        } 
        else
                sp->lzw_flags &= ~LZW_RESTART;
        sp->lzw_nbits = BITS_MIN;

        /*
         * Pre-load the table.
         */
        for (code = 255; code >= 0; code--)
               	sp->dec_suffix[code] = (u_char)code;
        sp->lzw_free_ent = CODE_FIRST;
        sp->lzw_bitoff = 0;

        /* 
         * Calculate data size in bits.
         */
        sp->lzw_bitsize = tif->tif_rawdatasize;
        sp->lzw_bitsize = (sp->lzw_bitsize << 3) - (BITS_MAX - 1);
        sp->dec_stackp = sp->dec_stack;
        sp->lzw_oldcode = -1;
        sp->dec_firstchar = -1;

        /*
         * Check for old bit-reversed codes.  All the flag manipulations are to insure only one warning is
         * given for a file.
         */
        if (tif->tif_rawdata[0] == 0 && (tif->tif_rawdata[1] & 0x1)) {
               	if ((sp->lzw_flags & LZW_COMPAT) == 0)
                       	TIFFWarning(tif->tif_name, "Old-style LZW codes, convert file");
                sp->lzw_flags |= LZW_COMPAT;
        } 
        else
                sp->lzw_flags &= ~LZW_COMPAT;
        SetMaxCode(sp, MAXCODE(BITS_MIN));
        return(1);
}

#define REPEAT4(n, op)	switch (n) { \
    				default: { \
    					int 	i; \
					\
    					for (i = n - 4; i > 0; i--) { \
    						op; \
    					} \
    				} \
    				case 4: \
    					op; \
    				case 3: \
    					op; \
 				case 2: \
 					op; \
    				case 1: \
    					op; \
    				case 0: \
    					; \
    			}

/****************************************************************************
 *
 */
static void
horizontalAccumulate8(
       	register char	*cp,
        register int 	cc,
        register int 	stride
        )
{
        if (cc > stride) {
                cc -= stride;
                do {
                        REPEAT4(stride, cp[stride] += cp[0]; cp++)
                        cc -= stride;
                } while (cc > 0);
        }
}

/****************************************************************************
 *
 */
static void
horizontalAccumulate16(
        register short	*wp,
        register int 	wc,
        register int 	stride
        )
{
        if (wc > stride) {
               	wc -= stride;
                do {
                       	REPEAT4(stride, wp[stride] += wp[0]; wp++)
                        wc -= stride;
                } while (wc > 0);
        }
}

/****************************************************************************
 * Get the next code from the raw data buffer.
 */
static int
GetNextCode(
        TIFF 	*tif
        )
{
        register LZWState	*sp = (LZWState *)tif->tif_data;
        register int 		code, bits;
        register long 		r_off;
        register u_char 	*bp;

        /*
         * This check shouldn't be necessary because each strip is suppose to be terminated with CODE_EOI.
         * At worst it's a substitute for the CODE_EOI that's supposed to be there (see calculation of lzw_bitsize
         * in LZWPreDecode()).
         */
        if (sp->lzw_bitoff > sp->lzw_bitsize) {
                TIFFWarning(tif->tif_name, "LZWDecode: Strip %d not terminated with EOI code", tif->tif_curstrip);
                return(CODE_EOI);
        }
        r_off = sp->lzw_bitoff;
        bits = sp->lzw_nbits;

        /*
         * Get to the first byte.
         */
        bp = (u_char *)tif->tif_rawdata + (r_off >> 3);
        r_off &= 7;
        if (sp->lzw_flags & LZW_COMPAT) {

	/* 
	 * Get first part (low order bits).
	 */
                code = (*bp++ >> r_off);
                r_off = 8 - r_off;             	/* now, offset into code word */
                bits -= (int)r_off;

	/* 
	 * Get any 8 bit parts in the middle (<=1 for up to 16 bits). 
	 */
                if (bits >= 8) {
                        code |= (*bp++ << r_off);
                        r_off += 8;
                        bits -= 8;
                }

	/* 
	 * High order bits. 
	 */
                code |= ((*bp & rmask[bits]) << r_off);
        } 
        else {
                r_off = 8 - r_off;             	/* convert offset to count */
                code = *bp++ & rmask[r_off];   	/* high order bits */
                bits -= (int)r_off;
                if (bits >= 8) {
                        code = (code << 8) | *bp++;
                        bits -= 8;
                }

	/* 
	 * Low order bits.
	 */
                code = (code << bits) | ((*bp & lmask[bits]) >> (8 - bits));
        }
        sp->lzw_bitoff += sp->lzw_nbits;
        return(code);
}

/****************************************************************************
 * Decode the next scanline.
 */
static int
LZWDecode(
       	TIFF	*tif,
        u_char 	*op0,
        int	occ0
        )
{
        register char		*op = (char *)op0;
        register int 		occ = occ0;
        register LZWState 	*sp = (LZWState *)tif->tif_data;
        register int 		code;
        register u_char 	*stackp;
        int 			firstchar, oldcode, incode;

        stackp = sp->dec_stackp;

        /*
         * Restart interrupted unstacking operations.
         */
        if (sp->lzw_flags & LZW_RESTART) {
                do {
                        if (--occ < 0) {       	/* end of scanline */
                                sp->dec_stackp = stackp;
                                return(1);
                        }
                        *op++ = *--stackp;
                } while (stackp > sp->dec_stack);
                sp->lzw_flags &= ~LZW_RESTART;
        }
        oldcode = sp->lzw_oldcode;
        firstchar = sp->dec_firstchar;
        while (occ > 0 && (code = GetNextCode(tif)) != CODE_EOI) {
                if (code == CODE_CLEAR) {
                        bzero(sp->dec_prefix, sizeof(sp->dec_prefix));
                        sp->lzw_free_ent = CODE_FIRST;
                        sp->lzw_nbits = BITS_MIN;
                        SetMaxCode(sp, MAXCODE(BITS_MIN));
                        if ((code = GetNextCode(tif)) == CODE_EOI)
                                break;
                        *op++ = code;
                        occ--;
                        oldcode = firstchar = code;
                        continue;
                }
                incode = code;

	/*
         * When a code is not in the table we use (as spec'd):  StringFromCode(oldcode) + FirstChar(StringFromCode(oldcode))
         */
                if (code >= sp->lzw_free_ent) {	/* code not in table */
                        *stackp++ = firstchar;
                        code = oldcode;
                }

	/*
         * Generate output string (first in reverse).
         */
                for (; code >= 256; code = sp->dec_prefix[code])
                        *stackp++ = sp->dec_suffix[code];
                *stackp++ = firstchar = sp->dec_suffix[code];
                do {
                        if (--occ < 0) {       	/* end of scanline */
                                sp->lzw_flags |= LZW_RESTART;
                                break;
                        }
                        *op++ = *--stackp;
                } while (stackp > sp->dec_stack);

	/*
         * Add the new entry to the code table.
         */
                if ((code = sp->lzw_free_ent) < CODE_MAX) {
                        sp->dec_prefix[code] = (u_short)oldcode;
                        sp->dec_suffix[code] = firstchar;
                        sp->lzw_free_ent++;

	/*
         * If the next entry is too big for the current code size, then increase the
         * size up to the maximum possible.
         */
                        if (sp->lzw_free_ent > sp->lzw_maxcode) {
                                sp->lzw_nbits++;
                                if (sp->lzw_nbits > BITS_MAX)
                                        sp->lzw_nbits = BITS_MAX;
                                SetMaxCode(sp, MAXCODE(sp->lzw_nbits));
                        }
                }
                oldcode = incode;
        }
        sp->dec_stackp = stackp;
        sp->lzw_oldcode = oldcode;
        sp->dec_firstchar = firstchar;
        switch (sp->lzw_hordiff) {
	        case LZW_HORDIFF8:
        	        horizontalAccumulate8((char *)op0, occ0, sp->lzw_stride);
                	break;
	        case LZW_HORDIFF16:
        	        horizontalAccumulate16((short *)op0, occ0 / 2, sp->lzw_stride);
                	break;
        }
        if (occ > 0) {
                TIFFError(tif->tif_name, "LZWDecode: Not enough data for scanline %d (decode %d bytes)", tif->tif_row, occ);
                return(0);
        }
        return(1);
}

/*
 * LZW Encoding.
 */

/****************************************************************************
 * Reset code table.
 */
static void
cl_hash(
       	LZWState	*sp
       	)
{
        register long	*htab_p = sp->enc_htab + HSIZE;
        register long 	i;
        register long	m1 = -1;

        i = HSIZE - 16;
        do {
                *(htab_p - 16) = m1;
                *(htab_p - 15) = m1;
                *(htab_p - 14) = m1;
                *(htab_p - 13) = m1;
                *(htab_p - 12) = m1;
                *(htab_p - 11) = m1;
                *(htab_p - 10) = m1;
                *(htab_p - 9) = m1;
                *(htab_p - 8) = m1;
                *(htab_p - 7) = m1;
                *(htab_p - 6) = m1;
                *(htab_p - 5) = m1;
                *(htab_p - 4) = m1;
                *(htab_p - 3) = m1;
                *(htab_p - 2) = m1;
                *(htab_p - 1) = m1;
                htab_p -= 16;
        } while ((i -= 16) >= 0);
        for (i += 16; i > 0; i--)
                *--htab_p = m1;
}

/****************************************************************************
 * Reset encoding state at the start of a strip.
 */
static int
LZWPreEncode(
        TIFF 	*tif
        )
{
        register LZWState	*sp = (LZWState *)tif->tif_data;

        if (sp == NULL) {
                if ((tif->tif_data = malloc(sizeof(LZWState))) == NULL) {
                        TIFFError("LZWPreEncode", "No space for LZW state block");
                        return(0);
                }
                sp = (LZWState *)tif->tif_data;
                sp->lzw_flags = 0;
                sp->lzw_hordiff = 0;
                if (!LZWCheckPredictor(tif, sp))
                        return(0);
        }
        sp->enc_ratio = 0;
        sp->enc_checkpoint = CHECK_GAP;
        SetMaxCode(sp, MAXCODE(sp->lzw_nbits = BITS_MIN) + 1);
        sp->lzw_free_ent = CODE_FIRST;
        sp->lzw_bitoff = 0;
        sp->lzw_bitsize = (tif->tif_rawdatasize << 3) - (BITS_MAX - 1);
        cl_hash(sp);           		/* clear hash table */
        sp->lzw_oldcode = -1;   	/* generates CODE_CLEAR in LZWEncode */
        return(1);
}

/****************************************************************************
 *
 */
static void
horizontalDifference8(
        register char	*cp,
        register int 	cc,
        register int 	stride
        )
{
        if (cc > stride) {
                cc -= stride;
                cp += cc - 1;
                do {
                        REPEAT4(stride, cp[stride] -= cp[0]; cp--)
                        cc -= stride;
                } while (cc > 0);
        }
}

/****************************************************************************
 *
 */
static void
horizontalDifference16(
        register short	*wp,
        register int 	wc,
        register int 	stride
        )
{
        if (wc > stride) {
                wc -= stride;
                wp += wc - 1;
                do {
                        REPEAT4(stride, wp[stride] -= wp[0]; wp--)
                        wc -= stride;
                } while (wc > 0);
        }
}

/****************************************************************************
 *
 */
static void
PutNextCode(
        TIFF 	*tif,
        int 	c
        )
{
        register LZWState	*sp = (LZWState *)tif->tif_data;
        register long 		r_off;
        register int 		bits;
        register int		code = c;
        register u_char 	*bp;

        r_off = sp->lzw_bitoff;
        bits = sp->lzw_nbits;

	/*
         * Flush buffer if code doesn't fit.
         */
        if (r_off + bits > sp->lzw_bitsize) {

	/*
         * Calculate the number of full bytes that can be written and save anything else for the next write.
         */
                if (r_off & 7) {
                        tif->tif_rawcc = r_off >> 3;
                        bp = tif->tif_rawdata + tif->tif_rawcc;
                      	TIFFFlushData1(tif);
                        tif->tif_rawdata[0] = *bp;
                } 
                else {

   	/*
         * Otherwise, on a byte boundary (in which tiff_rawcc is already correct).
         */
                     	TIFFFlushData1(tif);
                }
                bp = tif->tif_rawdata;
                sp->lzw_bitoff = (r_off &= 7);
        } 
        else {

	/*
         * Get to the first byte.
         */
                bp = tif->tif_rawdata + (r_off >> 3);
                r_off &= 7;
        }

        /*
         * Note that lzw_bitoff is maintained as the bit offset into the buffer w/ a right-to-left orientation (i.e.
         * lsb-to-msb).  The bits, however, go in the file in an msb-to-lsb order.
         */
        bits -= (int)(8 - r_off);
        *bp = (*bp & lmask[r_off]) | (code >> bits);
        bp++;
        if (bits >= 8) {
                bits -= 8;
                *bp++ = (code >> bits);
        }
        if (bits)
                *bp = (code & rmask[bits]) << (8 - bits);

        /*
         * enc_outcount is used by the compression analysis machinery which resets the compression tables when the compression
         * ratio goes up.  lzw_bitoff is used here (in PutNextCode) for inserting codes into the output buffer.  tif_rawcc must
         * be updated for the mainline write code in TIFFWriteScanline() so that data is flushed when the end of a strip is reached.
         * Note that the latter is rounded up to ensure that a non-zero byte count is present.
         */
        sp->enc_outcount += sp->lzw_nbits;
        sp->lzw_bitoff += sp->lzw_nbits;
        tif->tif_rawcc = (sp->lzw_bitoff + 7) >> 3;
}

/****************************************************************************
 * Check compression ratio and, if things seem to be slipping, clear the hash table and reset state.
 */
static void
cl_block(
        TIFF 	*tif
        )
{
        register LZWState	*sp = (LZWState *)tif->tif_data;
        register long 		rat;

        sp->enc_checkpoint = sp->enc_incount + CHECK_GAP;
        if (sp->enc_incount > 0x007fffffL) {		/* shift will overflow */
                rat = sp->enc_outcount >> 8;
                rat = (rat == 0 ? 0x7fffffffL : sp->enc_incount / rat);
        } 
        else
                rat = (sp->enc_incount << 8) / sp->enc_outcount;	/* 8 fract bits */
        if (rat <= sp->enc_ratio) {
                sp->enc_ratio = 0;
                cl_hash(sp);
                sp->lzw_free_ent = CODE_FIRST;
                PutNextCode(tif, CODE_CLEAR);
                SetMaxCode(sp, MAXCODE(sp->lzw_nbits = BITS_MIN) + 1);
        } 
        else
                sp->enc_ratio = rat;
}

#pragma warn -aus
/****************************************************************************
 * Encode a scanline of pixels.
 *
 * Uses an open addressing double hashing (no chaining) on the prefix code/next character combination.  We do a variant of
 * Knuth's algorithm D (vol. 3, sec. 6.4) along with G. Knott's relatively-prime secondary probe.  Here, the modular division
 * first probe is gives way to a faster exclusive-or manipulation.  Also do block compression with an adaptive reset, whereby the
 * code table is cleared when the compression ratio decreases, but after the table fills.  The variable-length output codes
 * are re-sized at this point, and a CODE_CLEAR is generated for the decoder.
 */
static int
LZWEncode(
        TIFF 	*tif,
        u_char 	*bp,
        int 	cc
        )
{
        static char		module[] = "LZWEncode";
        register LZWState	*sp;
        register long 		fcode;
        register int 		h, c, ent, disp;

        if ((sp = (LZWState *)tif->tif_data) == NULL)
                return(0);
	/*** XXX horizontal differencing alters user's data XXX ***/
        switch (sp->lzw_hordiff) {
	        case LZW_HORDIFF8:
        	        horizontalDifference8((char *)bp, cc, sp->lzw_stride);
                	break;
	        case LZW_HORDIFF16:
        	        horizontalDifference16((short *)bp, cc / 2, sp->lzw_stride);
	                break;
        }
        ent = sp->lzw_oldcode;
        if (ent == -1 && cc > 0) {
                PutNextCode(tif, CODE_CLEAR);
                ent = *bp++; 
                cc--; 
                sp->enc_incount++;
        }
        while (cc > 0) {
                c = *bp++; 
                cc--; 
                sp->enc_incount++;
                fcode = ((long)c << BITS_MAX) + ent;
                h = (c << HSHIFT) ^ ent;       	/* xor hashing */
                if (sp->enc_htab[h] == fcode) {
                        ent = sp->enc_codetab[h];
                        continue;
                }
                if (sp->enc_htab[h] >= 0) {

	/*
         * Primary hash failed, check secondary hash.
         */
                        disp = HSIZE - h;
                        if (h == 0)
                                disp = 1;
                        do {
                                if ((h -= disp) < 0)
                                        h += HSIZE;
                                if (sp->enc_htab[h] == fcode) {
                                        ent = sp->enc_codetab[h];
                                        goto hit;
                                }
                        } while (sp->enc_htab[h] >= 0);
                }

	/*
         * New entry, emit code and add to table.
         */
                PutNextCode(tif, ent);
                ent = c;
                sp->enc_codetab[h] = sp->lzw_free_ent++;
                sp->enc_htab[h] = fcode;
                if (sp->lzw_free_ent == CODE_MAX - 1) {
                        /*** table is full, emit clear code and reset ***/
                        sp->enc_ratio = 0;
                        cl_hash(sp);
                        sp->lzw_free_ent = CODE_FIRST;
                        PutNextCode(tif, CODE_CLEAR);
                        SetMaxCode(sp, MAXCODE(sp->lzw_nbits = BITS_MIN) + 1);
                } 
                else {
                        if (sp->enc_incount >= sp->enc_checkpoint)
                                cl_block(tif);

	/*
         * If the next entry is going to be too big for the code size, then increase it, if possible.
         */
                        if (sp->lzw_free_ent > sp->lzw_maxcode) {
                                sp->lzw_nbits++;
                                assert(sp->lzw_nbits <= BITS_MAX);
                                SetMaxCode(sp, MAXCODE(sp->lzw_nbits) + 1);
                        }
                }
hit:
                ;
        }
        sp->lzw_oldcode = ent;
        return(1);
}
#pragma warn .aus

/****************************************************************************
 * Finish off an encoded strip by flushing the last string and tacking on an End Of Information code.
 */
static int
LZWPostEncode(
        TIFF 	*tif
        )
{
        LZWState	*sp = (LZWState *)tif->tif_data;

        if (sp->lzw_oldcode != -1)
                PutNextCode(tif, sp->lzw_oldcode);
        PutNextCode(tif, CODE_EOI);
        return(1);
}

/****************************************************************************
 *
 */
static void
LZWCleanup(
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
TIFFInitLZW(
       	TIFF	*tif
       	)
{
        tif->tif_stripdecode = LZWPreDecode;
        tif->tif_decoderow = LZWDecode;
        tif->tif_stripencode = LZWPreEncode;
        tif->tif_encoderow = LZWEncode;
        tif->tif_encodestrip = LZWPostEncode;
        tif->tif_cleanup = LZWCleanup;
        return(1);
}
