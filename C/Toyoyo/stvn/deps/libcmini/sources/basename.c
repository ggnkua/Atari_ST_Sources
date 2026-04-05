/*  basename.c -- MiNTLib.
    Copyright (C) 1999, 2000 Guido Flohr <guido@freemint.de>

    This file is part of the MiNTLib project, and may only be used
    modified and distributed under the terms of the MiNTLib project
    license, COPYMINT.  By continuing to use, modify, or distribute
    this file you indicate that you have read the license and
    understand and accept it fully.
*/

#include "lib.h"
#include <string.h>

char *basename(const char *filename)
{
	char *slash = strrchr(filename, '/');
	char *backslash = strrchr(filename, '\\');

	if (slash > backslash)
		return slash + 1;
	if (backslash != NULL)
		return backslash + 1;
	return (char *) NO_CONST(filename);
}
