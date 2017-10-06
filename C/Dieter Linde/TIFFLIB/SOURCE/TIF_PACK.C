#pragma warn -use
static char 	*sccsid = "@(#)TIFF/tif_packbits.c 1.13, Copyright (c) Sam Leffler, Dieter Linde, "__DATE__;
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
 * PackBits Compression Algorithm Support
 */
/*#include "machdep.h"*/
#include "tiffio.h"

/****************************************************************************
 * Encode a scanline of pixels.
 */
static int
PackBitsEncode(
        TIFF 		*tif,
        u_char 		*bp,
        register int 	cc
        )
{
        register char 	*op, *lastliteral;
        register int 	n, b;
        enum { 
        	BASE, 
        	LITERAL, 
        	RUN, 
        	LITERAL_RUN 
        } state;
        char 		*ep;
        int 		slop;

        op = (char *)tif->tif_rawcp;
        ep = (char *)tif->tif_rawdata + tif->tif_rawdatasize;
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
                if (op + 2 >= ep) {          	/* insure space for new data */

	/*
         * Be careful about writing the last literal.  Must write up to that point
         * and then copy the remainder to the front of the buffer.
         */
                        if (state == LITERAL || state == LITERAL_RUN) {
                                slop = (int)(op - lastliteral);
                                tif->tif_rawcc += (u_char *)lastliteral - tif->tif_rawcp;
                                if (!TIFFFlushData(tif))
                                        return(-1);
                                op = (char *)tif->tif_rawcp;
                                for (; slop-- > 0; *op++ = *lastliteral++)
                                        ;
                                lastliteral = (char *)tif->tif_rawcp;
                        } 
                        else {
                                tif->tif_rawcc += (u_char *)op - tif->tif_rawcp;
                                if (!TIFFFlushData(tif))
                                        return(-1);
                                op = (char *)tif->tif_rawcp;
                        }
                }
                switch (state) {
	                case BASE:         	/* initial state, set run/literal */
                        	if (n > 1) {
                                	state = RUN;
	                                if (n > 128) {
        	                                *op++ = -127;
                	                        *op++ = b;
                        	                n -= 128;
                                	        goto again;
	                                }
        	                        *op++ = -(n - 1);
	                                *op++ = b;
        	                } 
        	                else {
                                	lastliteral = op;
                                	*op++ = 0;
                                	*op++ = b;
                                	state = LITERAL;
                        	}
                        	break;
	                case LITERAL:          	/* last object was literal string */
	                        if (n > 1) {
        	                        state = LITERAL_RUN;
                	                if (n > 128) {
                        	                *op++ = -127;
                                	        *op++ = b;
                                        	n -= 128;
	                                        goto again;
        	                        }
                	                *op++ = -(n - 1);	/* encode run */
	                                *op++ = b;
        	                } 
        	                else {                        	/* extend literal */
	                                if (++(*lastliteral) == 127)
        	                                state = BASE;
                	                *op++ = b;
                        	}
	                        break;
        	        case RUN:             	/* last object was run */
	                        if (n > 1) {
        	                        if (n > 128) {
                	                        *op++ = -127;
                        	                *op++ = b;
                                	        n -= 128;
                                        	goto again;
	                                }
        	                        *op++ = -(n - 1);
	                                *op++ = b;
        	                } 
        	                else {
                                	lastliteral = op;
	                                *op++ = 0;
        	                        *op++ = b;
                	                state = LITERAL;
                        	}
	                        break;
        	        case LITERAL_RUN:      	/* literal followed by a run */

	/*
         * Check to see if previous run should be converted to a literal, in which
         * case we convert literal-run-literal to a single literal.
         */
	                        if (n == 1 && op[-2] == (char)-1 && *lastliteral < 126) {
	                                state = (((*lastliteral) += 2) == 127 ? BASE : LITERAL);
	                                op[-2] = op[-1];      	/* replicate */
	                        } 
	                        else
                                	state = RUN;
	                        goto again;
                }
        }
        tif->tif_rawcc += ((u_char *)op - tif->tif_rawcp);
        tif->tif_rawcp = (u_char *)op;
        return(1);
}

/****************************************************************************
 *
 */
static int
PackBitsDecode(
        TIFF 		*tif,
        register u_char	*op,
        register int 	occ
        )
{
        register char 	*bp;
        register int 	n, b;
        long		cc;

        bp = (char *)tif->tif_rawcp; 
        cc = tif->tif_rawcc;
        while (cc > 0 && occ > 0) {
                n = *bp++;
                if (n == 128) {
                        cc--;
                        continue;
                }
                if (n < 0) {           	/* replicate next byte -n + 1 times */
                        n = -n + 1;
                        cc--;
                        occ -= n;
                        for (b = *bp++; n-- > 0;)
                                *op++ = b;
                } 
                else {                	/* copy next n + 1 bytes literally */
                        bcopy(bp, op, ++n);
                        op += n; 
                        occ -= n;
                        bp += n; 
                        cc -= n;
                }
        }
        tif->tif_rawcp = (u_char *)bp;
        tif->tif_rawcc = cc;
        if (occ > 0) {
                TIFFError(tif->tif_name, "PackBitsDecode: Not enough data for scanline %d", tif->tif_row);
                return(0);
        }

       	/* 
       	 * Check for buffer overruns? 
       	 */
        return(1);
}

/****************************************************************************
 *
 */
int
TIFFInitPackBits(
        TIFF 	*tif
        )
{
        tif->tif_decoderow = PackBitsDecode;
        tif->tif_encoderow = PackBitsEncode;
        return(1);
}
