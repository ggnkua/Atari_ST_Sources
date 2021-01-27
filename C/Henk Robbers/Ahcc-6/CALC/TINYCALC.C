/*  Copyright (c) 2013 - present by Henk Robbers Amsterdam.
 *
 * This file is part of TINYCALC.
 *
 * TINYCALC is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * TINYCALC is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with TINYCALC; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

/*
 *	TINYCALC.C
 *
 *  use F_x in a console
 */

#define SHOW 1

#if SHOW
#include <stddef.h>			/* for offsetof */
#endif
#include <string.h>
#include <stdio.h>
#include <ctype.h>

#include "../common/f_x.h"

#if __AHCC__			/* That is: on my ATARI */
#define V "2.03"
#else
#define V "3.4"
#define __AHCC__ 0
#endif

#define Built "V60"

enum
{
	hmax = 25,
	smax = 80
} EN;

static
char inp[smax];
typedef void VpV(void);

#define global

global
int main(void)
{
	Token val; char *s;
	double x = 10, y = 2;

	printf("Tiny calculator %s\n"
	       "x = %g, y = %g\n"
#if __APPLE__
	       "__APPLE__ = %d"
#else
		   "__AHCC__  = %d"
#endif
		   "\n"
	       "Enter formula:\n", Built, x, y,
#if __APPLE__
	       __APPLE__
#else
		   __AHCC__
#endif
	       );
#if SHOW
	printf(
		   "offsetof val = %ld, "
		   "size of double = %ld, "
		   "size of float = %ld, "
		   "size of enum = %ld\n",
		   offsetof(Token, v),
		   sizeof(double),
		   sizeof( float),
		   sizeof(EN)
		  );
#endif

/* being able to go back in history is good when you can actually edit in a line */
	do{
		printf(">");
		s = inp;
		*s = 0;
		fgets(s, sizeof(inp)-1, stdin);
		if ((*s eq 'e' and *(s+1) eq 'x') or *s eq 'q')
			return 0;
		val = F_x(x, y, s);
		if (val.t eq NUM)
			printf("%g\n", val.v);
		else
			printf("error at: '%s'\n", val.name);
	}od
}
