#pragma warn -use
static char	*sccsid = "@(#)TIFF/tif_close.c 1.01, Copyright (c) Sam Leffler, Dieter Linde, "__DATE__;
#pragma warn .use
/*
 * Copyright (c) 1988, 1990 by Sam Leffler.
 * All rights reserved.
 *
 * This file is provided for unrestricted use provided that this legend is included on all tape media and as a part of the
 * software program in whole or part.  Users may copy, modify or distribute this file at will.
 *
 * TIFF Library.
 */
#include <stdio.h>
#include <stdlib.h>
#include "tiffio.h"

/****************************************************************************
 *
 */
void
TIFFClose(
	TIFF 	*tif
	)
{
        if (tif->tif_mode != O_RDONLY)

      	/*
         * Flush buffered data and directory (if dirty).
         */
                TIFFFlush(tif);
        if (tif->tif_cleanup)
                (*tif->tif_cleanup)(tif);
        TIFFFreeDirectory(tif);
        if (tif->tif_rawdata)
                free(tif->tif_rawdata);
        close(tif->tif_fd);
        free(tif);
}
