#pragma warn -use
static char 	*sccsid = "@(#)TIFF/tif_sgi.c 1.06, Copyright (c) Sam Leffler, Dieter Linde, "__DATE__;
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
 * SGI RLE Compression Algorithm Support
 */
#include "tiffio.h"

#define MAXRUN 	126            	/* max length of a run */
#define LITBIT 	0x80           	/* bit indicating a literal string */

/****************************************************************************
 * Encode a scanline of pixels (this is basically the PackBits encoding).
 */
static int
SGIEncode(
       	TIFF		*tif,
        u_char 		*bp,
        register int 	cc
        )
{
        register char	*op, *lastliteral;
        register int 	n, b;
        enum { 
        	BASE, 
        	LITERAL, 
        	RUN, 
        	LITERAL_RUN
        } state;
        char 	*ep;
        int 	slop;

        /*** XXX 16 bits/sample case ***/
        op = (char *)tif->tif_rawcp;
        ep = (char *)(tif->tif_rawdata + tif->tif_rawdatasize);
        state = BASE;
        lastliteral = 0;
        while (cc > 0) {

	/*
         * Find the longest string of identical bytes.
         */
                b = *bp++;
                cc--;
                n = 1;
                for (; cc > 0 && b == *bp; cc--, bp++)
                        n++;
again:
                if (op + 2 >= ep) {            	/* insure space for new data */

	/*
         * Be careful about writing the last literal.  Must write up to that point
         * and then copy the remainder to the front of the buffer.
         */
                        if (state == LITERAL || state == LITERAL_RUN) {
                                slop = (int)(op - lastliteral);
                                tif->tif_rawcc += ((u_char *)lastliteral - tif->tif_rawcp);
                                if (!TIFFFlushData(tif))
                                        return(-1);
                                op = (char *)tif->tif_rawcp;
                                for (; slop-- > 0; *op++ = *lastliteral++)
                                        ;
                                lastliteral = (char *)tif->tif_rawcp;
                        } 
                        else {
                                tif->tif_rawcc += ((u_char *)op - tif->tif_rawcp);
                                if (!TIFFFlushData(tif))
                                        return(-1);
                                op = (char *)tif->tif_rawcp;
                        }
                }
                switch (state) {
                	case BASE:		/* initial state, set run/literal */
                        	if (n > 1) {
                                	state = RUN;
                                	if (n > MAXRUN) {
                                        	*op++ = MAXRUN;
                                        	*op++ = b;
                                        	n -= MAXRUN;
                                        	goto again;
                                	}
                                	*op++ = n;
                                	*op++ = b;
                        	} 
                        	else {
                                	lastliteral = op;
                                	*op++ = 1;
                                	*op++ = b;
                                	state = LITERAL;
                        	}
                        	break;
	                case LITERAL:          	/* last object was literal string */
	                        if (n > 1) {
        	                        state = LITERAL_RUN;
                	                if (n > MAXRUN) {
                        	                *op++ = MAXRUN;
                                	        *op++ = b;
                                        	n -= MAXRUN;
	                                        goto again;
        	                        }
                	                *op++ = n;            	/* encode run */
	                                *op++ = b;
        	                } 
        	                else {                        	/* extend literal */
	                                if (++(*lastliteral) == MAXRUN) {
        	                                *lastliteral |= LITBIT;
                	                        state = BASE;
                        	        }
                                	*op++ = b;
	                        }
        	                break;
                	case RUN:              	/* last object was run */
	                        if (n > 1) {
        	                        if (n > MAXRUN) {
                	                        *op++ = MAXRUN;
                        	                *op++ = b;
                                	        n -= MAXRUN;
                                        	goto again;
	                                }
        	                        *op++ = n;
                	                *op++ = b;
                        	} 
                        	else {
	                                lastliteral = op;
        	                        *op++ = 1;
                	                *op++ = b;
                        	        state = LITERAL;
	                        }
        	                break;
                	case LITERAL_RUN:      	/* literal followed by a run */

	/*
         * Check to see if previous run should be converted to a literal, in which
         * case we convert literal-run-literal to a single literal.
         */
                        	if (n == 1 && op[-2] == (char)-1 && *lastliteral < MAXRUN - 2) {
	                                if ((*lastliteral += 2) == MAXRUN) {
        	                                *lastliteral |= LITBIT;
                	                        state = BASE;
                        	        } 
                        	        else
                                        	state = LITERAL;
	                                op[-2] = op[-1];	/* replicate */
	                        } 
	                        else {
                                	*lastliteral |= LITBIT;
	                                state = RUN;
        	                }
                	        goto again;
                }
        }
        if (state == LITERAL || state == LITERAL_RUN)
                *lastliteral |= LITBIT;
        tif->tif_rawcc += ((u_char *)op - tif->tif_rawcp);
        tif->tif_rawcp = (u_char *)op;
        return(1);
}

#define	DECODE(cc, bp, occ, op, size)	while (cc > 0 && occ > 0) { \
                				pixel = *bp++; \
                				cc--; \
                				n = pixel &~ LITBIT; \
				                if (n == 0) \
			                        	continue; \
				                if (pixel & LITBIT) { \
				                        bcopy(bp, op, size * n); \
				                        op += size * n; \
				                        occ -= size * n; \
                        				bp += size * n; \
                        				cc -= size * n; \
                				} \
                				else { \
                        				pixel = *bp++; \
                        				cc--; \
                        				occ -= size * n; \
                        				while (n-- > 0) \
                                				*op++ = pixel; \
                				} \
        				}

/****************************************************************************
 *
 */
static int
SGIDecode(
       	TIFF 		*tif,
        u_char 		*buf,
        register int 	occ
        )
{
        register int 	n, pixel;
        register long	cc;

        cc = tif->tif_rawcc;
        if (tif->tif_dir.td_bitspersample <= 8) {
                register u_char	*bp, *op;

                bp = (u_char *)tif->tif_rawcp;
                op = buf;
                DECODE(cc, bp, occ, op, (int)sizeof(char));
                tif->tif_rawcp = bp;
        } 
        else {
                register u_short	*bp, *op;

                bp = (u_short *)tif->tif_rawcp;
                op = (u_short *)buf;
                DECODE(cc, bp, occ, op, (int)sizeof(short));
                tif->tif_rawcp = (u_char *)bp;
        }
        tif->tif_rawcc = cc;
        if (occ > 0) {
                TIFFError(tif->tif_name, "SGIDecode: Not enough data for scanline %d", tif->tif_row);
                return(0);
        }
        return(1);
}

/****************************************************************************
 *
 */
int
TIFFInitSGI(
       	TIFF	*tif
       	)
{
        tif->tif_decoderow = SGIDecode;
        tif->tif_encoderow = SGIEncode;
        return(1);
}
