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

void V_decl vro_cpyfm( short handle, short wr_mode, short *pxyarray,
				long *psrcMFDB, long *pdesMFDB )
{
	SETVCTL(handle, 109, 1, 4, 0);
	c.x.lp.src=psrcMFDB;
	c.x.lp.des=pdesMFDB;
	TRPVPB(&wr_mode, pxyarray, 0L, 0L);
}

void V_decl vrt_cpyfm( short handle, short wr_mode, short *pxy,
				long *psrcMFDB, long *pdesMFDB, short *color_index )
{
	short ii[3];
	SETVCTL(handle, 121, 3, 4, 0);

	ii[0]=wr_mode;
	ii[1]=color_index[0];
	ii[2]=color_index[1];
	c.x.lp.src=psrcMFDB;
	c.x.lp.des=pdesMFDB;
	TRPVPB(ii, pxy, 0L, 0L);
}

void V_decl vr_trnfm( short handle,
				long *psrcMFDB, long *pdesMFDB )
{
	SETVCTL(handle, 110, 0, 0, 0);

	c.x.lp.src=psrcMFDB;
	c.x.lp.des=pdesMFDB;
	TRPVPB(0L, 0L, 0L, 0L);
}

void V_decl v_get_pixel( short handle, short x, short y,
				short *pel, short *index )
{
	short io[2],pi[2];
	SETVCTL(handle, 105, 2, 1, 0);

	pi[0] = x;
	pi[1] = y;
	TRPVPB(0L, pi, io, 0L);
	if (pel)   *pel  =io[0];
	if (index) *index=io[1];
}

#if SMURF
typedef struct {short p[4];} pi4;

void V_decl vr_transfer_bits(short handle, long *src_bm, long *dst_bm, pi4 *src_rect, pi4 *dst_rect, short mode)
{
	short ii[4];
	pi4 pi[2];
	SETVCTL(handle, 170, 4, 4, 0);
	c.x.lp.src = src_bm;
	c.x.lp.des = dst_bm;
	ii[0] = mode;
	ii[1] = 0;
	ii[2] = 0;
	ii[3] = 0;
	pi[0] = *src_rect;
	pi[1] = *dst_rect;
	TRPVPB(ii, (short *)pi, 0L, 0L);
}

long vq_px_format(short handle, unsigned long *px_format)
{
	long io[2];
	SETVCTL(handle, 204, 0, 0, 3);
	c.nintout = 4;
	TRPVPB(0L, 0L, (short *)io, 0L);
	*px_format = io[1];
	return io[0];
}

long v_get_ctab_id(short handle)
{
	long io;
	SETVCTL(handle, 206, 0, 0, 6);
	c.nintout = 2;
	TRPVPB(0L, 0L, (short *)&io, 0L);
	return io;
}

void * v_create_ctab(short handle, long color_space, unsigned long px_format)
{
	long ii[2];
	void *io;
	SETVCTL(handle, 206, 4, 0, 8);
	c.nintout = 2;
	TRPVPB((short *)ii, 0L, (short *)&io, 0L);
	return io;
}

short v_delete_ctab(short handle, void *ctab)
{
	short io;
	SETVCTL(handle, 206, 2, 0, 9);
	c.nintout = 2;
	TRPVPB((short *)&ctab, 0L, &io, 0L);
	return io;
}


#endif
