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
#include <string.h>

static
void _vdi_esc(short handle, short esc)
{
	SETVCTL(handle, 5, 0, 0, esc);
	TRPVPB(0L, 0L, 0L, 0L);
}

void V_decl v_exit_cur(short handle)
{
	_vdi_esc(handle, 2);
}
void V_decl v_enter_cur(short handle)
{
	_vdi_esc(handle, 3);
}
void V_decl v_curup(short handle)
{
	_vdi_esc(handle, 4);
}
void V_decl v_curdown(short handle)
{
	_vdi_esc(handle, 5);
}
void V_decl v_curright(short handle)
{
	_vdi_esc(handle, 6);
}
void V_decl v_curleft(short handle)
{
	_vdi_esc(handle, 7);
}
void V_decl v_curhome(short handle)
{
	_vdi_esc(handle, 8);
}
void V_decl v_eeos (short handle)
{
	_vdi_esc(handle, 9);
}
void V_decl v_eeol (short handle)
{
	_vdi_esc(handle, 10);
}
void V_decl v_rvon (short handle)
{
	_vdi_esc(handle, 13);
}
void V_decl v_rvoff (short handle)
{
	_vdi_esc(handle, 14);
}
void V_decl v_rmcur (short handle)
{
	_vdi_esc(handle, 19);
}
void V_decl v_form_adv(short handle)
{
	_vdi_esc(handle, 20);
}
void V_decl v_hardcopy (short handle)
{
	_vdi_esc(handle, 17);
}
void V_decl v_clear_disp(short handle)
{
	_vdi_esc(handle, 22);
}

#define MAX_FN 128

void V_decl vm_filename(short handle, const char *fn)
{
	SETVCTL(handle, 5, 0, 0, 100);

	c.nintin += vdi_string(fn, v_tii, MAX_FN);
	TRPVPB(v_tii, 0L, 0L, 0L);
}

void V_decl vs_curaddress(short handle, short row, short col)
{
	short ii[2];
	SETVCTL(handle, 5, 2, 0, 11);

	ii[0] = row;
	ii[1] = col;
	TRPVPB(ii, 0L, 0L, 0L);
}

void V_decl v_bit_image (short handle, const char *fn, short asp,
                         short x_sca,   short y_sca,
                         short h_align, short v_align,
                         short *pxy)
{
	SETVCTL(handle, 5, 5, 2, 23);

	v_tii[0] = asp;
	v_tii[1] = x_sca;
	v_tii[2] = y_sca;
	v_tii[3] = h_align;
	v_tii[4] = v_align;

	c.nintin += vdi_string(fn, v_tii + 5, MAX_FN);
	TRPVPB(v_tii, pxy, 0L, 0L);
}

void V_decl v_curtext(short handle, const char *str)
{
	SETVCTL(handle, 5, 0, 0, 12);

	c.nintin += vdi_string(str, v_tii, MAX_TXT);
	TRPVPB(v_tii, 0L, 0L, 0L);
}

void V_decl v_dspcur(short handle, short x, short y)
{
	short pi[2];
	SETVCTL(handle, 5, 0, 1, 18);

	pi[0] = x;
	pi[1] = y;
	TRPVPB(0L, pi, 0L, 0L);
}

void V_decl v_fontinit (short handle, short fh, short fl)
{
	short ii[2];
	SETVCTL(handle, 5, 2, 0, 102);

	ii[0] = fh;
	ii[1] = fl;
	TRPVPB(ii, 0L, 0L, 0L);
}

void V_decl v_meta_extents (short handle, short min_x, short min_y,
                                          short max_x, short max_y)
{
	short pi[4];
	SETVCTL(handle, 5, 0, 2, 98);

	pi[0] = min_x;
	pi[1] = min_y;
	pi[2] = max_x;
	pi[3] = max_y;
	TRPVPB(0L, pi, 0L, 0L);
}

void V_decl v_offset(short handle, short offset)
{
	SETVCTL(handle, 5, 1, 0, 101);
	TRPVPB(&offset, 0L, 0L, 0L);
}

void V_decl v_output_window (short handle, short *pxy)
{
	SETVCTL(handle, 5, 0, 2, 21);
	TRPVPB(0L, pxy, 0L, 0L);
}

void V_decl v_write_meta (short handle, short nii, short ii[],
                          short npi, short pi[])
{
	SETVCTL(handle, 5, nii, npi, 99);
	TRPVPB(ii, pi, 0L, 0L);
}
