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
void V_decl _1vex ( short handle, long usr_code, long *sav_code, short fu)
{
	SETVCTL(handle, fu, 0, 0, 0);

	c.x.ll.ct = usr_code;
	c.x.ll.co = 0L;
	TRPVPB(0L, 0L, 0L, 0L);
	if (sav_code) *sav_code = c.x.ll.co;
}

void V_decl vex_butv ( short handle, long usr_code, long *sav_code)
{ _1vex(handle, usr_code, sav_code, 125); }
void V_decl vex_motv ( short handle, long usr_code, long *sav_code)
{ _1vex(handle, usr_code, sav_code, 126); }
void V_decl vex_curv ( short handle, long usr_code, long *sav_code)
{ _1vex(handle, usr_code, sav_code, 127); }
void V_decl vex_whlv ( short handle, long usr_code, long *sav_code)
{ _1vex(handle, usr_code, sav_code, 134); }

void V_decl vex_timv ( short handle, long tim_addr, long *otim_addr, short  *tim_conv)
{
	short io;
	SETVCTL(handle, 118, 0, 0, 0);

	c.x.ll.ct=tim_addr;
	TRPVPB(0L, 0L, &io, 0L);
	if (otim_addr) *otim_addr = c.x.ll.co;
	if (tim_conv ) *tim_conv  = io;
}

void V_decl vq_key_s( short handle, short *status )
{
	SETVCTL(handle, 128, 0, 0, 0);
	TRPVPB(0L, 0L, status, 0L);
}

void V_decl vq_mouse( short handle, short *status, short *x, short *y)
{
	short po[2];
	SETVCTL(handle, 124, 0, 0, 0);

	TRPVPB(0L, 0L, status, po);
	if (x) *x = po[0];
	if (y) *y = po[1];
}

void V_decl vsc_form( short handle, short *cur_form )
{
	SETVCTL(handle, 111, 37, 0, 0);
	TRPVPB(cur_form, 0L, 0L, 0L);
}

void V_decl  v_hide_c( short handle)
{
	SETVCTL(handle, 123, 0, 0, 0);
	TRPVPB(0L, 0L, 0L, 0L);
}

void V_decl  v_show_c( short handle, short reset)
{
	SETVCTL(handle, 122, 1, 0, 0);
	TRPVPB(&reset, 0L, 0L, 0L);
}

#if VDI_INPUT	/* designed for the AES, nobody ever used it (maybe only ROM TOS?) */
void V_decl vrq_choice( short handle, short ch_in, short *ch_out )
{
	SETVCTL(handle, 30, 1, 0, 0);
	TRPVPB(&ch_in, 0L, ch_out, 0L);
}

void V_decl vrq_locator( short handle,
                         short  x,     short  y,
                         short *xout,  short *yout, short *term )
{
	short pi[2], po[2];
	SETVCTL(handle, 28, 0, 1, 0);

	pi[0] = x;
	pi[1] = y;
	TRPVPB(0L, pi, term, po);
	if (xout) *xout = po[0];
	if (yout) *yout = po[1];
}

void V_decl vrq_string( short handle, short max_length, short echo_mode,
                        short *echo_xy, char *string)
{
	short ii[2], io[MAX_TXT], i;
	SETVCTL(handle, 31, 2, 1, 0);

	ii[0] = max_length;
	ii[1] = echo_mode;
	TRPVPB(ii, echo_xy, io, 0L);
	if (string)
	{
		for (i=0; i < c.nintout && i < MAX_TXT; i++)
			*string++ = io[i];
		*string=0;
	}
}

void V_decl vrq_valuator( short handle, short vi, short *vo, short *term )
{
	short io[2];
	SETVCTL(handle, 29, 1, 0, 0);

	TRPVPB(&vi, 0L, io, 0L);
	if (vo  ) *vo   = io[0];
	if (term) *term = io[1];
}
#endif

#if notyet
short V_decl vsm_choice( short handle, short *choice)
{
	short c[7], io;

	setvdipb(handle, 30, 0, 0, c, 0L, 0L, choice, 0L);
	return c[4];
}

short V_decl vsm_locator( short handle, short x, short y, short *xout, short *yout, short *term )
{
	short c[7], po[2];

	setvdipb(handle, 28, 0, 1, c, 0L, &x, term, po);
	*xout=po[0];
	*yout=po[1];
	return ((c[4]<<1)|c[2]);
}

short V_decl vsm_string( short handle, short max_length, short echo_mode, short *echo_xy, char *string)
{
	short c[7], i;

	setvdipb(handle, 31, 2, echo_mode, c, &max_length, echo_xy, tii, 0L);
	for (i=0;i<c[4];i++)
		*string++=tii[i];
	*string=0;
	return c[4];
}

void V_decl vsm_valuator( short handle, short vi, short *vo, short *term, short *status )
{
	short c[7], io[2];

	setvdipb(handle, 29, 1, 0, c, &vi, 0L, io, 0L);
	*vo=io[0];
	*term=io[1];
	*status=c[4];
}

void V_decl vsin_mode( short handle, short dev_type, short mo )
{
	short c[7];

	setvdipb(handle, 33, 2, 0, c, &dev_type, 0L, 0L, 0L);
}
#endif
