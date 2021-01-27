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

short  G_decl menu_bar(void *tree, short show)
{
	short io;
	SETACTL(30, 1, 1, 1, 0);

	G_trap(c, pglob, &show, &io, &tree, 0L);
	return io;
}

short  G_decl menu_icheck(void *tree, short item, short check)
{
	short ii[2], io;
	SETACTL(31, 2, 1, 1, 0);

	ii[0] = item, ii[1] = check;
	G_trap(c, pglob, ii, &io, &tree, 0L);
	return io;
}

short  G_decl menu_ienable(void *tree, short item, short enable)
{
	short ii[2], io;
	SETACTL(32, 2, 1, 1, 0);

	ii[0] = item, ii[1] = enable;
	G_trap(c, pglob, ii, &io, &tree, 0L);
	return io;
}

short  G_decl menu_tnormal(void *tree, short item, short normal)
{
	short ii[2], io;
	SETACTL(33, 2, 1, 1, 0);

	ii[0] = item, ii[1] = normal;
	G_trap(c, pglob, ii, &io, &tree, 0L);
	return io;
}

short  G_decl menu_text(void *tree, short item, const char *text)
{
	void *ai[2]; short io;
	SETACTL(34, 1, 1, 2, 0);

	ai[0]=tree;
	ai[1]=text;
	G_trap(c, pglob, &item, &io, ai, 0L);
	return io;
}

short  G_decl menu_register(short apid, const char *rstr)
{
	short io;
	SETACTL(35, 1, 1, 1, 0);

	G_trap(c, pglob, &apid, &io, &rstr, 0L);
	return io;
}

short  G_decl menu_popup(void *mn, short x, short y, void *data)
{
	void *ai[2]; short io, ii[2];
	SETACTL(36, 2, 1, 2, 0);

	ii[0] = x;
	ii[1] = y;
	ai[0]=mn;
	ai[1]=data;
	G_trap(c, pglob, ii, &io, ai, 0L);
	return io;
}

short  G_decl menu_attach(short flg, void *tree, short item, void *mn)
{
	short io, ii[2]; void *ai[2];
	SETACTL(37, 2, 1, 2, 0);

	ii[0] = flg;
	ii[1] = item;
	ai[0] = tree;
	ai[1] = mn;
	G_trap(c, pglob, ii, &io, ai, 0L);
	return io;
}

short  G_decl menu_istart(short flg, void *tree, short item, void *mn)
{
	short io;
	SETACTL(38, 1, 1, 1, 0);

	G_trap(c, pglob, &item, &io, &tree, 0L);
	return io;
}

short  G_decl menu_settings(short flg, void *values)
{
	short io;
	SETACTL(39, 1, 1, 1, 0);
	G_trap(c, pglob, &flg, &io, &values, 0L);
	return io;
}
