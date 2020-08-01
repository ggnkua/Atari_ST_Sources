#pragma warn -use
static char 	*sccsid = "@(#)TIFF/tif_next.c 1.09, Copyright (c) Sam Leffler, Dieter Linde, "__DATE__;
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
 * NeXT 2-bit Grey Scale Compression Algorithm Support
 */
#include "tiffio.h"

#define SETPIXEL(op, v)	{ \
        			switch (npixels++ & 3) { \
        				case 0: \
        					op[0]  = (v) << 6; \
        					break; \
        				case 1: \
        					op[0] |= (v) << 4; \
        					break; \
        				case 2: \
        					op[0] |= (v) << 2; \
        					break; \
        				case 3: \
        					*op++ |= (v); \
        					break; \
        			} \
        		}

#define LITERALROW     	0x00
#define LITERALSPAN     0x40
#define WHITE           ((1 << 2) - 1)

#pragma warn -par
/****************************************************************************
 *
 */
static int
NeXTEncode(
       	TIFF 	*tif,
        u_char 	*pp,
        int 	cc
        )
{
        TIFFError(tif->tif_name, "NeXT encoding is not implemented");
        return (-1);
}
#pragma warn .par

/****************************************************************************
 *
 */
static int
NeXTDecode(
       	TIFF 	*tif,
        u_char 	*buf,
        int 	occ
        )
{
        register u_char	*bp, *op;
        register int 	n;
        register long	cc;
        u_char 		*row;
        int 		scanline;

        /*
         * Each scanline is assumed to start off as all white (we assume a PhotometricInterpretation of ``min-is-black'').
         */
        for (op = buf, cc = occ; cc-- > 0;)
                *op++ = 0xff;

        bp = (u_char *)tif->tif_rawcp;
        cc = tif->tif_rawcc;
        scanline = tif->tif_scanlinesize;
        for (row = buf; occ > 0; occ -= scanline, row += scanline) {
                n = *bp++, cc--;
                switch (n) {
                	case LITERALROW:	/* the entire scanline is given as literal values */
                        	if (cc < scanline)
                                	goto bad;
                        	bcopy(bp, row, scanline);
                        	bp += scanline;
                        	cc -= scanline;
                        	break;

                	case LITERALSPAN:	/* the scanline has a literal span that begins at some offset */
                	{
                        	int 	off;

                        	off = (bp[0] * 256) + bp[1];
                        	n = (bp[2] * 256) + bp[3];
                        	if (cc < 4 + n)
                                	goto bad;
                        	bcopy(bp + 4, row + off, n);
                        	bp += 4 + n;
                        	cc -= 4 + n;
                        	break;
                	}
                	default: 
                	{
                        	register int	npixels = 0;
                        	register int	grey;
                        	int 		imagewidth = tif->tif_dir.td_imagewidth;

  	/*
         * The scanline is composed of a sequence of constant color "runs".  We shift into "run mode" and interpret bytes
         * as codes of the form <color><npixels> until we've filled the scanline.
         */
                        	op = row;
                        	for (;;) {
                                	grey = (n >> 6) & 0x3;
                                	n &= 0x3f;
                                	while (n-- > 0)
                                        	SETPIXEL(op, grey);
                                	if (npixels >= imagewidth)
                                        	break;
                                	if (cc == 0)
                                        	goto bad;
                                	n = *bp++, cc--;
                        	}
                        	break;
                	}
                }
        }
        tif->tif_rawcp = (u_char *)bp;
        tif->tif_rawcc = cc;
        return(1);
bad:
        TIFFError(tif->tif_name, "NeXTDecode: Not enough data for scanline %d", tif->tif_row);
        return(0);
}

/****************************************************************************
 *
 */
int
TIFFInitNeXT(
       	TIFF 	*tif
       	)
{
        tif->tif_decoderow = NeXTDecode;
        tif->tif_encoderow = NeXTEncode;
        return(1);
}
