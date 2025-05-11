/* append.c - - */

/* Copyright (C) 1987 Free Software Foundation, Inc.

This file is part of Gas, the GNU Assembler.

The GNU assembler is distributed in the hope that it will be
useful, but WITHOUT ANY WARRANTY.  No author or distributor
accepts responsibility to anyone for the consequences of using it
or for whether it serves any particular purpose or works at all,
unless he says so in writing.  Refer to the GNU Assembler General
Public License for full details.

Everyone is granted permission to copy, modify and redistribute
the GNU Assembler, but only under the conditions described in the
GNU Assembler General Public License.  A copy of this license is
supposed to have been given to you along with the GNU Assembler
so you can know your rights and responsibilities.  It should be
in a file named COPYING.  Among other things, the copyright
notice and this notice must be preserved on all copies.  */

/* JF:  This is silly.  Why not stuff this in some other file? */

void
append (charPP, fromP, length)
char	**charPP;
char	*fromP;
unsigned long length;
{
	if (length) {		/* Don't trust bcopy() of 0 chars. */
		bcopy (fromP, * charPP,(int) length);
		*charPP += length;
	}
}

/* end: append.c */
