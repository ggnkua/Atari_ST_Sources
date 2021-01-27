/* This file is part of the AHCC GEM Library.

   The AHCC GEM Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Library General Public License as
   published by the Free Software Foundation; either version 2 of the
   License, or (at your option) any later version.

   The AHCC GEM Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Library General Public
   License along with the GNU C Library; see the file COPYING.LIB.  If not,
   write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
   Boston, MA 02111-1307, USA.

   Copyright (c) 2008 by Henk Robbers @ Amsterdam.
*/

#include "aespb.h"

short G_decl shel_read(char *cmd, char *tail)
{
	short io;
	void *ai[2];
	SETACTL(120, 0, 1, 2, 0);

	ai[0] = cmd, ai[1] = tail;
	G_trap(c, pglob, 0L, &io, ai, 0L);
	return io;
}

short G_decl shel_write(short doex, short isgr, short iscr,
                             char *cmd, char *tail)
{
	short ii[3], io;
	void *ai[2];
	SETACTL(121, 3, 1, 2, 0);

	ai[0] = cmd, ai[1] = tail;
	ii[0] = doex, ii[1] = isgr, ii[2] = iscr;
	G_trap(c, pglob, ii, &io, ai, 0L);
	return io;
}

short G_decl shel_get(char *gaddr, short len)
{
	short io;
	SETACTL(122, 1, 1, 1, 0);
	G_trap(c, pglob, &len, &io, &gaddr, 0L);
	return io;
}

short G_decl shel_put(char *paddr, short len)
{
	short io;
	SETACTL(123, 1, 1, 1, 0);
	G_trap(c, pglob, &len, &io, &paddr, 0L);
	return io;
}

short G_decl shel_envrn(char **val, char *name)
{
	short io;
	void *ai[2];
	SETACTL(125, 0, 1, 2, 0);

	ai[0] = val, ai[1] = name;
	G_trap(c, pglob, 0L, &io, ai, 0L);
	return io;
}

short G_decl shel_find(const char *path)
{
	short io;
	SETACTL(124, 0, 1, 1, 0);
	G_trap(c, pglob, 0L, &io, &path, 0L);
	return io;
}

