#pragma warn -use
static char 	*sccsid = "@(#)TIFF/tif_compress.c 1.15, Copyright (c) Sam Leffler, Dieter Linde, "__DATE__;
#pragma warn .use
/*
 * Copyright (c) 1988, 1990 by Sam Leffler, Oct 8 1990
 * All rights reserved.
 *
 * This file is provided for unrestricted use provided that this legend is included on all tape media and as a part of the
 * software program in whole or part.  Users may copy, modify or distribute this file at will.
 *
 * TIFF Library
 *
 * Compression Scheme Configuration Support.
 */
#include "tiffio.h"

static  struct	cscheme {
       	u_short	scheme;
        int     (*init)(TIFF *);
} CompressionSchemes[] = {
    	{ COMPRESSION_NONE, TIFFInitDumpMode },
    	{ COMPRESSION_LZW, TIFFInitLZW },
    	{ COMPRESSION_PACKBITS, TIFFInitPackBits },

#ifdef 	PICIO_SUPPORT
    	{ COMPRESSION_PICIO, TIFFInitPicio },
#endif	/* PICIO_SUPPORT */

#ifdef 	THUNDER_SUPPORT
    	{ COMPRESSION_THUNDERSCAN, TIFFInitThunderScan },
#endif	/* THUNDER_SUPPORT */

#ifdef 	NEXT_SUPPORT
    	{ COMPRESSION_NEXT, TIFFInitNeXT },
#endif	/* NEXT_SUPPORT */

#ifdef 	SGI_SUPPORT
    	{ COMPRESSION_SGIRLE, TIFFInitSGI },
#endif	/* SGI_SUPPORT */

    	{ COMPRESSION_CCITTRLE, TIFFInitCCITTRLE },
    	{ COMPRESSION_CCITTRLEW, TIFFInitCCITTRLEW },
    	{ COMPRESSION_CCITTFAX3, TIFFInitCCITTFax3 },
    	{ COMPRESSION_CCITTFAX4, TIFFInitCCITTFax4 },
};

#define NSCHEMES	(sizeof(CompressionSchemes) / sizeof(CompressionSchemes[0]))

/****************************************************************************
 *
 */
int
TIFFSetCompressionScheme(
	TIFF 	*tif,
	u_short	scheme
	)
{
        register struct cscheme	*c;

        for (c = CompressionSchemes; c < &CompressionSchemes[NSCHEMES]; c++)
                if (c->scheme == scheme) {
                        tif->tif_stripdecode = NULL;
                        tif->tif_stripencode = NULL;
                        tif->tif_encodestrip = NULL;
                        tif->tif_close = NULL;
                        tif->tif_seek = NULL;
                        tif->tif_cleanup = NULL;
                        tif->tif_flags &= ~TIFF_NOBITREV;
                        tif->tif_options = 0;
                        return((*c->init)(tif));
                }
        TIFFError("TIFFSetCompressionScheme", "unknown data compression algorithm %u", tif->tif_name, scheme);
        return(0);
}
