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

/* GLOBAL aes_global; */

GEMPARBLK _GemParBlk;

short gl_apid, gl_version;

void _crystal(void *aespb)
{
	AES(aespb);
}

short  appl_init(void)
{
	short io = -1;
	SETACTL(10, 0, 1, 0, 0);

	gl_apid = -1;
	gl_version = 0;
	G_trap(c, pglob, 0L, &io, 0L, 0L);
	if (io >= 0)				/* 10'11 HR: > --> >= */
	{
		gl_apid = io;
		gl_version = pglob.version;
	}
	return io;
}

short  appl_read(short rid, short rl, void *rb)
{
	short ii[2], io;
	SETACTL(11, 2, 1, 1, 0);

	ii[0] = rid, ii[1] = rl;
	G_trap(c, pglob, ii, &io, &rb, 0L);
	return io;
}

short  appl_write(short wid, short wl, void *wb)
{
	short ii[2], io;
	SETACTL(12, 2, 1, 1, 0);

	ii[0] = wid, ii[1] = wl;
	G_trap(c, pglob, ii, &io, &wb, 0L);
	return io;
}

short  appl_tplay(void *mem, short num, short scale)
{
	short ii[2], io;
	SETACTL(14, 2, 1, 1, 0);

	ii[0] = num, ii[1] = scale;
	G_trap(c, pglob, ii, &io, &mem, 0L);
	return io;
}

short  appl_trecord(void *mem, short num)
{
	short ii = num, io;
	SETACTL(15, 1, 1, 1, 0);

	G_trap(c, pglob, &ii, &io, &mem, 0L);
	return io;
}

short  appl_search(short mode, char *name, short *type, short *id)
{
	short ii = mode, io[3];
	SETACTL(18, 1, 3, 0, 0);

	G_trap(c, pglob, &ii, io, &name, 0L);
	*type = io[1];
	*id   = io[2];
	return io[0];
}

short  appl_control(short id, int what, void *out)
{
	short ii[2], io;
	SETACTL(129, 2, 1, 1, 0);

	ii[0] = id;
	ii[1] = what;

	G_trap(c, pglob, ii, &io, &out, 0L);
	return io;
}

short  appl_getinfo(short ty,
                  short *o1, short *o2, short *o3, short *o4)
{
	short ii = ty, io[5];
	SETACTL(130, 1, 5, 0, 0);

	G_trap(c, pglob, &ii, io, 0L, 0L);
	if (o1) *o1 = io[1];
	if (o2) *o2 = io[2];
	if (o3) *o3 = io[3];
	if (o4) *o4 = io[4];
	return io[0];
}

short  appl_find(const char *name)
{
	short io;
	SETACTL(13, 0, 1, 1, 0);
	G_trap(c, pglob, 0L, &io, &name, 0L);
	return io;
}

short  appl_yield(void)
{
	short io;
	SETACTL(17, 0, 1, 0, 0);
	G_trap(c, pglob, 0L, &io, 0L, 0L);
	return io;
}

short  appl_exit(void)
{
	short io;
	SETACTL(19, 0, 1, 0, 0);
	G_trap(c, pglob, 0L, &io, 0L, 0L);
	return io;
}

