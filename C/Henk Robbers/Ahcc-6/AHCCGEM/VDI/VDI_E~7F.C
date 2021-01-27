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

#include "vdipb.h"

short V_decl vqt_devinfo( int handle, int devnum, int *devexists, char *devstr )
{
	short io[32], po;
	SETVCTL(handle, 248,  1, 0, 0);
	TRPVPB(&devnum, io, 0L, &po);
	if (devexists)
	{
		short i;
		*devexists = po;
		for (i=0; i < c.nintout; i++)
			devstr[i] = io[i];
	}
	return io[0];
}


short V_decl vst_arbpt( int handle, int point, int *chwd, int *chht, int *cellwd, int *cellht )
{
	STVCTL(handle, 246, 1, 0, 0);
	TRPVPB(&point
	return 0;
}

long V_decl vst_arbpt32( int handle, long point, int *chwd, int *chht, int *cellwd, int *cellht )
{
	return 0;
}

void V_decl vq_scrninfo(short handle, short *workout)
{
	short ii = 2;
	SETVCTL(handle, 102, 1, 0, 1);
	TRPVPB(&ii, 0L, workout, 0L);
}

void v_ext_opnwk(short *workin, short *handle, short *workout)
{
	SETVCTL(*handle, 1, 11, 6, 0);
	c.nintout = 45;
	TRPVPB(workin, 0L, workout, workout+45);
	*handle = c.handle;
}

/* leicht verndertes Binding, file_path und file_name werden nicht durchgereicht */
short vq_ext_devinfo(short handle, short device, short *dev_exists, char *name)
{
	short io[2], ii[7];
	SETVCTL(handle, 248, 7, 0, 4242);
	ii[0]=device;
	*(char **)&ii[1] = (char *)v_tii;
	*(char **)&ii[3] = (char *)v_tii+33;
	*(char **)&ii[5] = name;
	TRPVPB(ii, io, 0L, 0L);
	if (dev_exists)
		*dev_exists = io[1];
	return io[0];
}

void v_opnbm(int *workin, void *bitmap, int *handle, int *workout)
{
	SETVCTL(*handle, 100, 20, 0, 1);
	TRPVPB(workin, 0L, workout, workout+45);
	c.x.lp.src = bitmap;
	*handle = c.handle;
}

void v_clsbm(short handle)
{
	SETVCTL(handle, 101, 0, 0, 1);
	TRPVPB(0L, 0L, 0L, 0L);
}
