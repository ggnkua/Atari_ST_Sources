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

void V_decl vr_recfl(short handle, short *pxy)
{
	SETVCTL(handle, 114, 0, 2, 0);
	TRPVPB(0L, pxy, 0L, 0L);
}

static
void _Bar(short handle, short *pxy, short fu)
{
	SETVCTL(handle, 11, 0, 2, fu);
	TRPVPB(0L, pxy, 0L, 0L);
}

void V_decl v_bar  (short handle, short *pxy) { _Bar(handle, pxy, 1); }
void V_decl v_rbox (short handle, short *pxy) { _Bar(handle, pxy, 8); }
void V_decl v_rfbox(short handle, short *pxy) { _Bar(handle, pxy, 9); }


void V_decl v_pieslice( short handle, short x, short y, short radius,
                                 short begang, short endang )
{
	short ii[2], pi[8];
	SETVCTL(handle, 11, 2, 4, 3);

	ii[0]=begang;
	ii[1]=endang;
	pi[0]=x;
	pi[1]=y;
	pi[2]=0;
	pi[3]=0;
	pi[4]=0;
	pi[5]=0;
	pi[6]=radius;
	pi[7]=0;
	TRPVPB(ii, pi, 0L, 0L);
}

void V_decl v_arc( short handle, short x, short y, short radius,
                                 short begang, short endang )
{
	short ii[2], pi[8];
	SETVCTL(handle, 11, 2, 4, 2);

	ii[0]=begang;
	ii[1]=endang;
	pi[0]=x;
	pi[1]=y;
	pi[2]=0;
	pi[3]=0;
	pi[4]=0;
	pi[5]=0;
	pi[6]=radius;
	pi[7]=0;
	TRPVPB(ii, pi, 0L, 0L);
}

void V_decl v_circle( short handle, short x, short y, short radius)
{
	short pi[6];
	SETVCTL(handle, 11, 0, 3, 4);

	pi[0]=x;
	pi[1]=y;
	pi[2]=0;
	pi[3]=0;
	pi[4]=radius;
	pi[5]=0;
	TRPVPB(0L, pi, 0L, 0L);
}

void V_decl v_ellipse( short handle, short x, short y,
                          short xradius, short yradius)
{
	short pi[4];
	SETVCTL(handle, 11, 0, 2, 5);

	pi[0]=x;
	pi[1]=y;
	pi[2]=xradius;
	pi[3]=yradius;
	TRPVPB(0L, pi, 0L, 0L);
}

void V_decl v_ellarc( short handle, short x, short y,
                      short xradius, short yradius,
                      short begang, short endang)
{
	short ii[2], pi[4];
	SETVCTL(handle, 11, 2, 2, 6);

	ii[0]=begang;
	ii[1]=endang;
	pi[0]=x;
	pi[1]=y;
	pi[2]=xradius;
	pi[3]=yradius;
	TRPVPB(ii, pi, 0L, 0L);
}

void V_decl v_ellpie( short handle, short x, short y,
                      short xradius, short yradius,
                      short begang, short endang)
{
	short ii[2], pi[4];
	SETVCTL(handle, 11, 2, 2, 7);

	ii[0]=begang;
	ii[1]=endang;
	pi[0]=x;
	pi[1]=y;
	pi[2]=xradius;
	pi[3]=yradius;
	TRPVPB(ii, pi, 0L, 0L);
}

void V_decl v_cellarray( short handle, short *pxyarray,
                         short row_length, short el_used,
                         short num_rows, short wrt_mode,
                         short *colarray )
{
	SETVCTL(handle, 10, row_length*num_rows, 2, 0);

	c.x.ii[0]=row_length;
	c.x.ii[1]=el_used;
	c.x.ii[2]=num_rows;
	c.x.ii[3]=wrt_mode;
	TRPVPB(colarray, pxyarray, 0L, 0L);
}

void V_decl v_contourfill(short handle, short x, short y, short index)
{
	short pi[2];
	SETVCTL(handle, 103, 1, 1, 0);

	pi[0] = x;
	pi[1] = y;
	TRPVPB(&index, pi, 0L, 0L);
}

void V_decl v_fillarea(short handle, short ct, short *pxy)
{
	SETVCTL(handle, 9, 0, ct, 0);
	TRPVPB(0L, pxy, 0L, 0L);
}

/* needed for Emutos 8.3 */

void V_decl v_gtext(short handle, short x, short y, const char *text)
{
	short pi[2];
	SETVCTL(handle, 8, 0, 1, 0);

	pi[0] = x;
	pi[1] = y;
	c.nintin += vdi_string(text, v_tii, MAX_TXT);
	TRPVPB(v_tii, pi, 0L, 0L);
}

static
void _Poly(short handle, short ct, short *pxy, short fu)
{
	SETVCTL(handle, fu, 0, ct, 0);
	TRPVPB(0L, pxy, 0L, 0L);
}

void V_decl v_pline  (short handle, short ct, short *pxy) { _Poly(handle, ct, pxy, 6); }
void V_decl v_pmarker(short handle, short ct, short *pxy) { _Poly(handle, ct, pxy, 7); }

void V_decl v_justified( short handle, short x, short y, const char *text,
                      short length, short word_space, short char_space )
{
	short pi[4];
	SETVCTL(handle, 11, 2, 2, 10);

	pi[0]=x;
	pi[1]=y;
	pi[2]=length;
	pi[3]=0;
	v_tii[0]=word_space;
	v_tii[1]=char_space;
	c.nintin += vdi_string(text, v_tii+2, MAX_TXT);
	TRPVPB(v_tii, pi, 0L, 0L);
}
