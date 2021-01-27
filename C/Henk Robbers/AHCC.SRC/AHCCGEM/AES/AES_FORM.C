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

short G_decl form_do(void *tree,short item)
{
	short io;
	SETACTL(50,1,1,1,0);

	G_trap(c,pglob,&item,&io,&tree,0L);
	return io;
}

short G_decl form_dial(short flag,short lx,short ly,short lw,short lh,
                       short bx,short by,short bw,short bh)
{
	short ii[9], io;
	SETACTL(51,9,1,0,0);
	ii[0] = flag, ii[1] = lx, ii[2] = ly, ii[3] = lw, ii[4] = lh,
	ii[5] = bx,   ii[6] = by, ii[7] = bw, ii[8] = bh;

	G_trap(c,pglob,ii,&io,0L,0L);
	return io;
}

short G_decl form_alert(short button,const char *alstr)
{
	short io;
	SETACTL(52,1,1,1,0);

	G_trap(c,pglob,&button,&io,&alstr,0L);
	return io;
}

short G_decl form_error(short num)
{
	short io;
	SETACTL(53,1,1,0,0);

	G_trap(c,pglob,&num,&io,0L,0L);
	return io;
}

short G_decl form_center(void *tree,short *cx,short *cy,
                           short *cw,short *ch)
{
	short io[5];
	SETACTL(54,0,5,1,0);

	G_trap(c,pglob,0L,io,&tree,0L);
	*cx=io[1];
	*cy=io[2];
	*cw=io[3];
	*ch=io[4];
	return io[0];
}

short G_decl form_keybd(void *tree,short item,short next,short teken,
                            short *nextob,short *nextteken)
{
	short ii[3], io[3];
	SETACTL(55,3,3,1,0);

	io[0] = item, ii[1] = teken, ii[2] = next;
	G_trap(c,pglob,ii,io,&tree,0L);
	*nextob=io[1];
	*nextteken=io[2];
	return io[0];
}

short G_decl form_button(void *tree,short item,short clks,short *nextob)
{
	short ii[2], io[2];
	SETACTL(56,2,2,1,0);

	ii[0] = item, ii[1] = clks;
	G_trap(c,pglob,ii,io,&tree,0L);
	*nextob=io[1];
	return io[0];
}
