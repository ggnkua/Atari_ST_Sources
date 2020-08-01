#pragma warn -use
static char 	*sccsid = "@(#)TIFF/tif_compat.c 1.05, Copyright (c) Sam Leffler, Dieter Linde, "__DATE__;
#pragma warn -use
/*
 * Copyright (c) 1988, 1990 by Sam Leffler, Oct 8 1990
 * All rights reserved.
 *
 * This file is provided for unrestricted use provided that this legend is included on all tape media and as a part of the
 * software program in whole or part.  Users may copy, modify or distribute this file at will.
 *
 * TIFF Library.
 *
 * Compatibility Routines.
 */
#include <ext.h>
#include "tiffio.h"

/****************************************************************************
 *
 */
long
TIFFGetFileSize(
	int 	fd
	)
{
        struct stat	sb;

        return(fstat(fd, &sb) == -1 ? 0 : sb.st_size);
}
