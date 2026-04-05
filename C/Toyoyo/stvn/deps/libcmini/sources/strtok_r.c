/*  strtok.c -- MiNTLib.
    Copyright (C) 2000 Guido Flohr <guido@freemint.de>

    This file is part of the MiNTLib project, and may only be used
    modified and distributed under the terms of the MiNTLib project
    license, COPYMINT.  By continuing to use, modify, or distribute
    this file you indicate that you have read the license and
    understand and accept it fully.
*/


#include <string.h>


char *strtok_r(char *s, const char *delim, char **scanpoint)
{
	char *scan;
	char *tok;

	if (s == NULL && *scanpoint == NULL)
		return NULL;

	if (s != NULL)
		scan = s;
	else
		scan = *scanpoint;

	/*
	 * Scan leading delimiters.
	 */
	for (; *scan != '\0'; scan++) 
	{
		const char *dscan;

		for (dscan = delim; *dscan != '\0'; ++dscan)
		{
			if (*scan == *dscan)
				break;
		}

		if (*dscan == '\0')
			break;
	}

	if (*scan == '\0')
	{
		*scanpoint = NULL;
		return NULL;
	}

	tok = scan;

	/*
	 * Scan token.
	 */
	for (; *scan != '\0'; scan++)
	{
		const char *dscan = delim;

		while (*dscan != '\0')  /* ++ moved down. */
		{
			if (*scan == *dscan++)
			{
				*scanpoint = scan + 1;
				*scan = '\0';

				return tok;
			}
		}
	}

	/*
	 * Reached end of string.
	 */
	*scanpoint = NULL;

	return tok;
}
