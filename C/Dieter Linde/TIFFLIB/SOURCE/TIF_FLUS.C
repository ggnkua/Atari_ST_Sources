#pragma warn -use
static char 	*sccsid = "@(#)TIFF/tif_flush.c 1.07, Copyright (c) Sam Leffler, Dieter Linde, "__DATE__;
#pragma warn .use
/*
 * Copyright (c) 1988, 1990 by Sam Leffler, Oct 8 1990
 * All rights reserved.
 *
 * This file is provided for unrestricted use provided that this legend is included on all tape media and as a part of the
 * software program in whole or part.  Users may copy, modify or distribute this file at will.
 *
 * TIFF Library.
 */
#include "tiffio.h"

/****************************************************************************
 *
 */
int
TIFFFlush(
        TIFF 	*tif
        )
{
        if (tif->tif_mode != O_RDONLY) {
                if (tif->tif_rawcc > 0 && !TIFFFlushData(tif))
                        return(0);
                if ((tif->tif_flags & TIFF_DIRTYDIRECT) && !TIFFWriteDirectory(tif))
                        return(0);
        }
        return(1);
}
