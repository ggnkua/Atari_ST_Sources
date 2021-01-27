/*  Copyright (c) 2013 - present by Henk Robbers Amsterdam.
 *
 * This file is part of AHCC.
 *
 * AHCC is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * AHCC is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with AHCC; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

/*
 *	TINYCALC.C
 *
 *  use F_x in a console
 */

#include <string.h>
#include <stdio.h>

#if __AHCC__			/* That is: on my ATARI */
#include "common/F_x.h"
#define V "2.01"
#else
#include "f_x.h"
#define V "3.0"
#endif

static
char inp[80];

global
int main(void)
{
	Token val; char *s;
	double x = 10, y = 2;

	printf("Tiny calculator v" V "\n"
	       "x = %g, y = %g\n"
	       "Enter formula:\n", x, y);

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
