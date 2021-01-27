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

short G_decl wind_create(short kind, short x, short y, short w, short h)
{
	short ii[5], io;
	SETACTL(100, 5, 1, 0, 0);

	ii[0] = kind, ii[1] = x, ii[2] = y, ii[3] = w, ii[4] = h;
	G_trap(c, pglob, ii, &io, 0L, 0L);
	return io;
}

short G_decl wind_open(short whl, short x, short y, short w, short h)
{
	short ii[5], io;
	SETACTL(101, 5, 1, 0, 0);

	ii[0] = whl, ii[1] = x, ii[2] = y, ii[3] = w, ii[4] = h;
	G_trap(c, pglob, ii, &io, 0L, 0L);
	return io;
}

short G_decl wind_close(short whl)
{
	short io;
	SETACTL(102, 1, 1, 0, 0);

	G_trap(c, pglob, &whl, &io, 0L, 0L);
	return io;
}

short G_decl wind_delete(short whl)
{
	short io;
	SETACTL(103, 1, 1, 0, 0);

	G_trap(c, pglob, &whl, &io, 0L, 0L);
	return io;
}

#if __WGS_ELLIPSISD__

#include <stdarg.h>

/* zero value: intout[0] only */
unsigned char wind_get_table[] =
{
    0,0,0,0,4,4,4,4,
    1,1,
    1,                  /* 10  WF_TOP (was 1, 3 since AES 3.3) (HR: alas, incompatible) */
    4,4,0,
    2,                  /* 14  WF_NEWDESK   */
    1,1,4,
    1,                  /* 18  WF_COLOR     (since AES 3.3) */
    4,                  /* 19  WF_DCOLOR    (since AES 3.3) */
    1,                  /* 20  WF_OWNER     */
    0,0,0,
    1,                  /* 24  WF_BEVENT    */
    1,                  /* 25  WF_BOTTOM    */
    3,                  /* 26  WF_ICONIFY   */
    4,                  /* 27  WF_UNICONIFY */
    0,0,
    2,                  /* 30  WF_TOOLBAR   */
    4,                  /* 31  WF_FTOOLBAR  */
    4,                  /* 32  WF_NTOOLBAR  */
    2,                  /* 33  WF_MENU      */
    0,0,0,0,0,0,0,
    4,                  /* 41  WF_OPTS      */
    0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0
};

short G_decl wind_get_nargs(short field)
{
	if(field > 0 && field < sizeof(wind_get_table))
		return wind_get_table[field];
	else
		return 4;
}

short G_decl wind_get(short whl, short srt, ...)	/* in assembler */
{
	va_list a;
	short io[5], ii[3], *w, i, j;
	SETACTL(104, 2, 5, 0, 0);

	va_start(a, srt);
	ii[0] = whl;
	ii[1] = srt;

	w = va_arg(a, short *);
	if (w)
		ii[2] = *w;

	G_trap(c, pglob, ii, io, 0L, 0L);

	i = wind_get_table[srt & 63];
	j = 1;
	while (i)
	{
		if (w)
			*w = io[j];

		j++, i--;
		w = va_arg(a, short *);
	}

	return io[0];
}

short G_decl wind_set(short whl, short srt, ...)	/* in assembler */
{
	va_list a;
	short ii[6], io;
	SETACTL(105, 6, 1, 0, 0);
	va_start(a, srt);

	ii[0] = whl;
	ii[1] = srt;
	ii[2] = va_arg(a, short);
	ii[3] = va_arg(a, short);
	ii[4] = va_arg(a, short);
	ii[5] = va_arg(a, short);
	G_trap(c, pglob, ii, &io, 0L, 0L);
	return io;
}

#endif

#if SMURF
#if !__WGS_ELLIPSISD__
short G_decl wind_get
#else
short G_decl SM_wind_get
#endif
        (short whl, short srt, short *w1, short *w2, short *w3, short *w4)
{
	short io[5], ii[3];
	SETACTL(104, 2, 5, 0, 0);

	ii[0] = whl, ii[1] = srt;
	if (w1)
		ii[2] = *w1;

	G_trap(c, pglob, ii, io, 0L, 0L);
	if (w1) *w1=io[1];
	if  ( srt < 8 || srt == 11 || srt == 12 )
	{
		if (w2) *w2=io[2];
		if (w3) *w3=io[3];
		if (w4) *w4=io[4];
	}
	return io[0];
}

#if ! __WGS_ELLIPSISD__
short G_decl wind_set
#else
short G_decl SM_wind_set
#endif
        (short whl, short srt,
               short x, short y, short w, short h)
{
	short ii[6], io;
	SETACTL(105, 6, 1, 0, 0);

	ii[0] = whl;
	ii[1] = srt;
	ii[2] = x;
	ii[3] = y;
	ii[4] = w;
	ii[5] = h;
	G_trap(c, pglob, ii, &io, 0L, 0L);
	return io;
}
#endif

short G_decl wind_find(short x, short y)
{
	short ii[2], io;
	SETACTL(106, 2, 1, 0, 0);

	ii[0] = x, ii[1] = y;
	G_trap(c, pglob, ii, &io, 0L, 0L);
	return io;
}

short G_decl wind_update(short begend)
{
	short io;
	SETACTL(107, 1, 1, 0, 0);

	G_trap(c, pglob, &begend, &io, 0L, 0L);
	return io;
}

short G_decl wind_calc(short ty, short srt,
                            short   x, short   y, short   w, short   h,
                            short *bx, short *by, short *bw, short *bh)
{
	short ii[6], io[5];
	SETACTL(108, 6, 5, 0, 0);

	ii[0] = ty, ii[1] = srt, ii[2] = x, ii[3] = y, ii[4] = w, ii[5] = h;
	G_trap(c, pglob, ii, io, 0L, 0L);
	if (bx) *bx=io[1];
	if (by) *by=io[2];
	if (bw) *bw=io[3];
	if (bh) *bh=io[4];
	return io[0];
}

short G_decl wind_new(void)
{
	short io;
	SETACTL(109, 0, 1, 0, 0);
	G_trap(c, pglob, 0L, &io, 0L, 0L);
	return io;
}
