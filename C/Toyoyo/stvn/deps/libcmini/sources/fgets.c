/* Copyright (C) 1991, 92, 95, 96, 97, 98 Free Software Foundation, Inc.
   This file is part of the GNU C Library.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Library General Public License as
   published by the Free Software Foundation; either version 2 of the
   License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Library General Public
   License along with the GNU C Library; see the file COPYING.LIB.  If not,
   write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
   Boston, MA 02111-1307, USA.  */

/* Modified for MiNTLib by Guido Flohr <guido@freemint.de>.  */

#include <stdio.h>
#include "lib.h"

/* Reads characters from STREAM into S, until either a newline character
   is read, N - 1 characters have been read, or EOF is seen.  Returns
   the newline, unlike gets.  Finishes by appending a null character and
   returning S.  If EOF is seen before any characters have been written
   to S, the function returns NULL without appending the null character.
   If there is a file error, always return NULL.  */


char*
fgets(char* s, int n, FILE* stream)
{
	if (ferror(stream)) {
		s = NULL;
	} else {
		register char* p = s;
		register int   c = 0;

		while (--n > 0 && (c = fgetc(stream)) != EOF) {
			if (stream->__mode.__binary) {
				static int last_char = '\0';

				if (c == '\n' && last_char == '\r') {
					--p;
				}

				last_char = c;
			}

            if (c == '\r' && FILE_GET_HANDLE(stream) == 0) {
                // stdin
                c = '\n';
            }

			*p++ = c;

            if (c == '\n') {
				break;
			}
		}

		if (c == EOF && (p == s || ferror(stream))) {
			s = NULL;
		} else {
			*p = '\0';
		}
	}

	return s;
}
