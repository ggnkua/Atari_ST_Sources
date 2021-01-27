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

short G_decl graf_rubberbox(short dx,short dy,short dw,short dh,
                   short *ex,short *ey)
{
	short io[3]; short ii[4];
	SETACTL(70,4,3,0,0);

	ii[0] = dx, ii[1] = dy, ii[2] = dw, ii[3] = dh;
	G_trap(c,pglob,ii,io,0L,0L);
	*ex=io[1];
	*ey=io[2];
	return io[0];
}

short G_decl graf_dragbox(short dw,short dh,short dx,short dy,
                 short bx,short by,short bw,short bh,
                 short *ex,short *ey)
{
	short io[3]; short ii[8];
	SETACTL(71,8,3,0,0);

	ii[0] = dw, ii[1] = dh, ii[2] = dx, ii[3] = dy,
	ii[4] = bx, ii[5] = by, ii[6] = bw, ii[7] = bh;
	G_trap(c,pglob,ii,io,0L,0L);
	*ex=io[1];
	*ey=io[2];
	return io[0];
}

short G_decl graf_movebox(short w,short h,short bx,short by,short ex,short ey)
{
	short ii[6], io;
	SETACTL(72,6,1,0,0);

	ii[0] = w,  ii[1] = h, ii[2] = bx, ii[3] = by,
	ii[4] = ex, ii[5] = ey;
	G_trap(c,pglob,ii,&io,0L,0L);
	return io;
}

short G_decl graf_growbox(short dx,short dy,short dw,short dh,
                 short bx,short by,short bw,short bh)
{
	short ii[8], io;
	SETACTL(73,8,1,0,0);

	ii[0] = dx, ii[1] = dy, ii[2] = dw, ii[3] = dh,
	ii[4] = bx, ii[5] = by, ii[6] = bw, ii[7] = bh;
	G_trap(c,pglob,ii,&io,0L,0L);
	return io;
}

short G_decl graf_shrinkbox(short dx,short dy,short dw,short dh,
                   short bx,short by,short bw,short bh)
{
	short ii[8], io;
	SETACTL(74,8,1,0,0);

	ii[0] = dx, ii[1] = dy, ii[2] = dw, ii[3] = dh,
	ii[4] = bx, ii[5] = by, ii[6] = bw, ii[7] = bh;
 	G_trap(c,pglob,ii,&io,0L,0L);
	return io;
}

short G_decl graf_watchbox(void *tree,short item,short inst,short uitst)
{
	short ii[4], io;
	SETACTL(75,4,1,1,0);

	ii[0] = 0, ii[1] = item, ii[2] = inst, ii[3] = uitst;
	G_trap(c,pglob,ii,&io,&tree,0L);
	return io;
}

short G_decl graf_slidebox(void *tree,short parent,short item,short hv)
{
	short ii[3], io;
	SETACTL(76,3,1,1,0);

	ii[0] = parent, ii[1] = item, ii[2] = hv;
	G_trap(c,pglob,ii,&io,&tree,0L);
	return io;
}

short G_decl graf_handle(short *wchar,short *hchar,short *wbox,short *hbox)
{
	short io[5];
	SETACTL(77,0,5,0,0);

	G_trap(c,pglob,0L,io,0L,0L);
	*wchar=io[1];
	*hchar=io[2];
	*wbox=io[3];
	*hbox=io[4];
	return io[0];
}

short G_decl graf_mouse(short mnum,void *maddr)
{
	short io;
	SETACTL(78,1,1,1,0);
	G_trap(c,pglob,&mnum,&io,(long *)&maddr,0L);
	return io;
}

short G_decl graf_mkstate(short *mx,short *my,short *bstate,short *kstate)
{
	short io[5];
	SETACTL(79,0,5,0,0);

	G_trap(c,pglob,0L,io,0L,0L);
	*mx=io[1];
	*my=io[2];
	*bstate=io[3];
	*kstate=io[4];
	return io[0];
}
