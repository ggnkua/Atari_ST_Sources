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

short G_decl objc_add(void *tree, short parent, short child)
{
	short ii[2], io;
	SETACTL(40, 2, 1, 1, 0);

	ii[0] = parent, ii[1] = child;
	G_trap(c, pglob, ii, &io, &tree, 0L);
	return io;
}

short G_decl objc_delete(void *tree, short item)
{
	short io;
	SETACTL(41, 1, 1, 1, 0);

	G_trap(c, pglob, &item, &io, &tree, 0L);
	return io;
}

short G_decl objc_draw(void *tree, short startob, short depth,
                       short xc, short yc, short wc, short hc)
{
	short ii[6], io;
	SETACTL(42, 6, 1, 1, 0);

	ii[0] = startob, ii[1] = depth, ii[2] = xc,
	ii[3] = yc, ii[4] = wc, ii[5] = hc;
	G_trap(c, pglob, ii, &io, &tree, 0L);
	return io;
}

short G_decl objc_find(void *tree, short startob, short depth,
                       short mx, short my)
{
	short ii[4], io;
	SETACTL(43, 4, 1, 1, 0);

	ii[0] = startob, ii[1] = depth, ii[2] = mx, ii[3] = my;
	G_trap(c, pglob, ii, &io, &tree, 0L);
	return io;
}

short G_decl objc_offset(void *tree, short item,
                         short *xoff, short *yoff)
{
	short io[3], ii = item;
	SETACTL(44, 1, 3, 1, 0);

	G_trap(c, pglob, &ii, io, &tree, 0L);
	*xoff=io[1];
	*yoff=io[2];
	return io[0];
}

short G_decl objc_order(void *tree, short item, short newpos)
{
	short ii[2], io;
	SETACTL(45, 2, 1, 1, 0);

	ii[0] = item, ii[1] = newpos;
	G_trap(c, pglob, ii, &io, &tree, 0L);
	return io;
}

short G_decl objc_edit(void *tree, short item, short edchar,
                       short *idx, short kind)
{
	short io[2];
	short ii[4];
	SETACTL(46, 4, 2, 1, 0);

	ii[0] = item, ii[1] = edchar, ii[2] = *idx, ii[3] = kind;
	G_trap(c, pglob, ii, io, &tree, 0L);
	*idx=io[1];
	return io[0];
}

short G_decl objc_change(void *tree, short item, short resvd,
                         short xc, short yc,
                         short wc, short hc,
                         short newst, short redraw)
{
	short ii[8], io;
	SETACTL(47, 8, 1, 1, 0);

	ii[0] = item, ii[1] = resvd,
	ii[2] = xc, ii[3] = yc, ii[4] = wc, ii[5] = hc,
	ii[6] = newst, ii[7] = redraw;
	G_trap(c, pglob, ii, &io, &tree, 0L);
	return io;
}

short G_decl objc_sysvar(short mode, short which, short ival1,
                         short ival2, short *oval1, short *oval2)
{
	short ii[4]; short io[3];
	SETACTL(48, 4, 3, 0, 0);

	ii[0] = mode, ii[1] = which, ii[2] = ival1, ii[3] = ival2;
	G_trap(c, pglob, ii, io, 0L, 0L);
	*oval1 = io[1];
	*oval2 = io[2];
	return io[0];
}
