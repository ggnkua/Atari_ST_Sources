#pragma warn -use
static char 	*sccsid = "@(#)TIFF/tif_ccittrle.c 1.06, Copyright (c) Sam Leffler, Dieter Linde, "__DATE__;
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
 * CCITT Group 3 1-D Modified Huffman Run Length Encoding Compression Support
 */
#include "tiffio.h"
#include "tif_fax3.h"

/****************************************************************************
 *
 */
int
TIFFInitCCITTRLE(
	TIFF	*tif
	)
{
       	TIFFInitCCITTFax3(tif);        	/* reuse G3 compression */
/*      tif->tif_stripencode = NULL;
        tif->tif_encoderow = NULL;
        tif->tif_encodestrip = NULL;
        tif->tif_close = NULL;*/

        /*
         * This magic causes the regular G3 decompression code to not skip to the EOL mark at the end of
         * a row, and to flush input data to a byte boundary at the end of each row.
         */
        tif->tif_options |= (FAX3_NOEOL | FAX3_BYTEALIGN);
        return(1);
}

/****************************************************************************
 *
 */
int
TIFFInitCCITTRLEW(
	TIFF 	*tif
	)
{
        TIFFInitCCITTFax3(tif);        	/* reuse G3 compression */
/*      tif->tif_stripencode = NULL;
        tif->tif_encoderow = NULL;
        tif->tif_encodestrip = NULL;
        tif->tif_close = NULL;*/

        /*
         * This magic causes the regular G3 decompression code to not skip to the EOL mark at the end of
         * a row, and to flush input data to a byte boundary at the end of each row.
         */
        tif->tif_options |= (FAX3_NOEOL | FAX3_WORDALIGN);
        return(1);
}
