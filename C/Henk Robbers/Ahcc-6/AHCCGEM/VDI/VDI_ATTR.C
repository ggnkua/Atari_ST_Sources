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

static
short __1io(short handle, short index, short fu)
{
	short io;
	SETVCTL(handle, fu, 1, 0, 0);

	TRPVPB(&index, 0L, &io, 0L);
	return io;
}

short V_decl vsf_color    ( short handle, short index ) { return __1io(handle, index,  25); }
short V_decl vsf_interior ( short handle, short style ) { return __1io(handle, style,  23); }
short V_decl vsf_perimeter( short handle, short pvis  ) { return __1io(handle, pvis,  104); }
short V_decl vsf_style    ( short handle, short style ) { return __1io(handle, style,  24); }
short V_decl vsl_color    ( short handle, short index ) { return __1io(handle, index,  17); }
short V_decl vsl_type     ( short handle, short style ) { return __1io(handle, style,  15); }
short V_decl vsm_color    ( short handle, short index ) { return __1io(handle, index,  20); }
short V_decl vsm_type     ( short handle, short symbol) { return __1io(handle, symbol, 18); }
short V_decl vst_color    ( short handle, short index ) { return __1io(handle, index,  22); }
short V_decl vst_effects  ( short handle, short effect) { return __1io(handle, effect,106); }
short V_decl vst_font     ( short handle, short font  ) { return __1io(handle, font,   21); }
short V_decl vst_rotation ( short handle, short angle ) { return __1io(handle, angle,  13); }
short V_decl vswr_mode    ( short handle, short mode  ) { return __1io(handle, mode,   32); }

void V_decl vsf_udpat( short handle, short *pfill_pat, short planes )
{
	SETVCTL(handle, 112, 16*planes, 0, 0);
	TRPVPB (pfill_pat, 0L, 0L, 0L);
}

void V_decl vsl_ends( short handle, short beg_style, short end_style )
{
	short ii[2], io;		/* intout not according to PROFIBUCH !!! */
	SETVCTL(handle, 108, 2, 0, 0);

	ii[0] = beg_style;
	ii[1] = end_style;
	TRPVPB(ii, 0L, &io, 0L);
}

void V_decl vsl_udsty( short handle, short pattern )
{
	SETVCTL(handle, 113, 1, 0, 0);
	TRPVPB (&pattern, 0L, 0L, 0L);
}

short V_decl vsl_width( short handle, short width )
{
	short pi[2], po[2];
	SETVCTL(handle, 16, 0, 1, 0);

	pi[0]=width;
	pi[1]=0;
	TRPVPB(0L, pi, 0L, po);
	return po[0];
}

short V_decl vsm_height( short handle, short height )
{
	short pi[2], po[2];
	SETVCTL(handle, 19, 0, 1, 0);

	pi[0]=0;
	pi[1]=height;
	TRPVPB(0L, pi, 0L, po);
	return po[1];
}

void V_decl vst_alignment( short handle, short hor_in, short vert_in,
                           short *hor_out, short *vert_out )
{
	short ii[2], io[2];
	SETVCTL(handle, 39, 2, 0, 0);

	ii[0] = hor_in;
	ii[1] = vert_in;
	TRPVPB(ii, 0L, io, 0L);
	if (hor_out ) *hor_out =io[0];
	if (vert_out) *vert_out=io[1];
}

void V_decl vst_height( short handle, short height, short *char_width,
            short *char_height, short *cell_width, short *cell_height )
{
	short pi[2], po[4];
	SETVCTL(handle, 12, 0, 1, 0);

	pi[0]=0;
	pi[1]=height;
	TRPVPB(0L, pi, 0L, po);
	if (char_width ) *char_width =po[0];
	if (char_height) *char_height=po[1];
	if (cell_width ) *cell_width =po[2];
	if (cell_height) *cell_height=po[3];
}

short  V_decl vst_point ( short handle, short point, short *char_width,
             short *char_height, short *cell_width, short *cell_height )
{
	short po[4], io;
	SETVCTL(handle, 107, 1, 0, 0);

	TRPVPB(&point, 0L, &io, po);
	if (char_width ) *char_width =po[0];
	if (char_height) *char_height=po[1];
	if (cell_width ) *cell_width =po[2];
	if (cell_height) *cell_height=po[3];
	return io;
}

void V_decl vs_color( short handle, short index, short *rgb )
{
	short ii[4];
	SETVCTL(handle, 14, 4, 0, 0);

	ii[0]=index;
	ii[1]=rgb[0];
	ii[2]=rgb[1];
	ii[3]=rgb[2];
	TRPVPB(ii, 0L, 0L, 0L);
}

#if 0
short V_decl vsf_interior ( short handle, short style   ) { short c[7], io; setvdipb(handle,  23, 1, 0, c, &style,   0L, &io, 0L); return io; }
short V_decl vsf_perimeter( short handle, short per_vis ) { short c[7], io; setvdipb(handle, 104, 1, 0, c, &per_vis, 0L, &io, 0L); return io; }
short V_decl vsf_style    ( short handle, short style   ) { short c[7], io; setvdipb(handle,  24, 1, 0, c, &style,   0L, &io, 0L); return io; }
short V_decl vsl_color    ( short handle, short index   ) { short c[7], io; setvdipb(handle,  17, 1, 0, c, &index,   0L, &io, 0L); return io; }
short V_decl vsl_type     ( short handle, short style   ) { short c[7], io; setvdipb(handle,  15, 1, 0, c, &style,   0L, &io, 0L); return io; }
short V_decl vsm_color    ( short handle, short index   ) { short c[7], io; setvdipb(handle,  20, 1, 0, c, &index,   0L, &io, 0L); return io; }
short V_decl vsm_type     ( short handle, short symbol  ) { short c[7], io; setvdipb(handle,  18, 1, 0, c, &symbol,  0L, &io, 0L); return io; }
short V_decl vst_color    ( short handle, short index   ) { short c[7], io; setvdipb(handle,  22, 1, 0, c, &index,   0L, &io, 0L); return io; }
short V_decl vst_effects  ( short handle, short effect  ) { short c[7], io; setvdipb(handle, 106, 1, 0, c, &effect,  0L, &io, 0L); return io; }
short V_decl vst_font     ( short handle, short font    ) { short c[7], io; setvdipb(handle,  21, 1, 0, c, &font,    0L, &io, 0L); return io; }
short V_decl vst_rotation ( short handle, short angle   ) { short c[7], io; setvdipb(handle,  13, 1, 0, c, &angle,   0L, &io, 0L); return io; }
short V_decl vswr_mode    ( short handle, short mo      ) { short c[7], io; setvdipb(handle,  32, 1, 0, c, &mo,      0L, &io, 0L); return io; }

#endif
