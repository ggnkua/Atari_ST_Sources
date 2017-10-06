#pragma warn -use
static char	*sccsid = "@(#)TIFF/tif_warning.c 1.08, Copyright (c) Sam Leffler, Dieter Linde, "__DATE__;
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
#include <stdio.h>
#include "tiffio.h"

/****************************************************************************
 *
 */
void
TIFFWarning(
	char 	*module, 
	char 	*fmt, 
	...
	)
{
        va_list	ap;

        if (module != NULL)
                fprintf(stderr, "%s: ", module);
        fprintf(stderr, "Warning, ");
        va_start(ap, fmt);
        vfprintf(stderr, fmt, ap);
        va_end(ap);
        fprintf(stderr, ".\n");
}
