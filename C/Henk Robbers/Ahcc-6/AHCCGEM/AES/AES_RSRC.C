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

short G_decl rsrc_load (const char *fname)
{
	short io;
	SETACTL(110, 0, 1, 1, 0);
	G_trap(c, pglob, 0L, &io, &fname, 0L);
	return io;
}

short G_decl rsrc_free(void)
{
	short io;
	SETACTL(111, 0, 1, 0, 0);
	G_trap(c, pglob, 0L, &io, 0L, 0L);
	return io;
}

short G_decl rsrc_gaddr (short type, short item, void **addr)
{
	short ii[2], io;
	SETACTL(112, 2, 1, 0, 1);

	ii[0] = type, ii[1] = item;
	G_trap(c, pglob, ii, &io, 0L, addr);
	return io;
}

short G_decl rsrc_saddr (short type, short item, void *addr)
{
	short ii[2], io;
	SETACTL(113, 2, 1, 1, 0);

	ii[0] = type, ii[1] = item;
	G_trap(c, pglob, ii, &io, &addr, 0L);
	return io;
}

short G_decl rsrc_obfix (void *tree, short item)
{
	short io;
	SETACTL(114, 1, 1, 1, 0);
	G_trap(c, pglob, &item, &io, &tree, 0L);
	return io;
}

short G_decl rsrc_rcfix( void *rsh)
{
	short io;
	SETACTL(115, 0, 1, 1, 0);
	G_trap(c, pglob, 0L, &io, &rsh, 0L);
	return io;
}
