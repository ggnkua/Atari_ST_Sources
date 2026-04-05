/*  strcasestr.c -- MiNTLib.
    Copyright (C) 2000 Guido Flohr <guido@freemint.de>

    This file is part of the MiNTLib project, and may only be used
    modified and distributed under the terms of the MiNTLib project
    license, COPYMINT.  By continuing to use, modify, or distribute
    this file you indicate that you have read the license and
    understand and accept it fully.
*/

#include <string.h>
#include <ctype.h>

/* Similar to `strstr' but this function ignores the case of both strings.  */

char*				/* Found string, or NULL if none.  */
strcasestr(const char* s, const char* wanted)
{
	register const char* scan;
	register size_t len;
	register char firstc;

	if (!*s) {
		if (*wanted)
			return NULL;
		else
			return (char*) s;
	} else if (!*wanted) {
		return (char*) s;
	}

	/*
	 * The odd placement of the two tests is so "" is findable.
	 * Also, we inline the first char for speed.
	 * The ++ on scan has been moved down for optimization.
	 */
	firstc = *wanted;
	len = strlen (wanted);
	for (scan = s;
	     toupper (*scan) != toupper (firstc) || strncasecmp(scan, wanted, len) != 0; )
		if (*scan++ == '\0')
			return NULL;
	return (char*) scan;
}
