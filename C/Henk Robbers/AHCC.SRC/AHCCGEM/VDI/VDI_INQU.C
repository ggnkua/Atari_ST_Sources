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

void V_decl vqf_attributes (short handle, short *attrib)
{
	SETVCTL(handle, 37, 0, 0, 0);
	TRPVPB(0L, 0L, attrib, 0L);
}

void V_decl vql_attributes (short handle, short *attrib)
{
	SETVCTL(handle, 35, 0, 0, 0);
	TRPVPB(0L, 0L, attrib, attrib+5);
}

void V_decl vqm_attributes (short handle, short *attrib)
{
	SETVCTL(handle, 36, 0, 0, 0);
	TRPVPB(0L, 0L, attrib, attrib+3);
}

void V_decl vqt_attributes (short handle, short *attrib)
{
	SETVCTL(handle, 38, 0, 0, 0);
	TRPVPB(0L, 0L, attrib, attrib+6);
}

void V_decl vqin_mode (short handle, short dty, short *imo)
{
	SETVCTL(handle, 115, 1, 0, 0);
	TRPVPB(&dty, 0L, imo, 0L);
}

/* needed for Emutos 8.3 */
void V_decl vqt_extent (short handle, char *str, short *extent)
{
	SETVCTL(handle, 116, 0, 0, 0);

	c.nintin += vdi_string(str, v_tii, MAX_TXT);
	TRPVPB(v_tii, 0L, 0L, extent);
}

void V_decl vqt_fontinfo(short handle, short *mia, short *maa,
                         short *dist,  short *maw, short *effe)
{
	short io[2], po[10];
	SETVCTL(handle, 131, 0, 0, 0);

	TRPVPB(0L, 0L, io, po);
	if (mia) *mia=io[0];
	if (maa) *maa=io[1];
	if (maw) *maw=po[0];
	if (dist)
	{
		dist[0]=po[1];
		dist[1]=po[3];
		dist[2]=po[5];
		dist[3]=po[7];
		dist[4]=po[9];
	}
	if (effe)
	{
		effe[0]=po[2];
		effe[1]=po[4];
		effe[2]=po[6];
	}
}

short V_decl vqt_name(short handle, short el, char *n)
{
	short io[33], i, *o = io + 1;
	SETVCTL(handle, 130, 1, 0, 0);

	TRPVPB(&el, 0L, io, 0L);

	for (i=0; i<32; i++)
		*n++ = *o++;
	*n = 0;

	return io[0];
}

short V_decl vqt_width (short handle, short ch, short *cw,
                         short *ld, short *rd)
{
	short io, po[6];
	SETVCTL(handle, 117, 1, 0, 0);

	TRPVPB(&ch, 0L, &io, po);
	if (cw) *cw=po[0];
	if (ld) *ld=po[2];
	if (rd) *rd=po[4];
	return io;
}

void V_decl vq_cellar (short handle, short *pxy, short rl,    short nr,
                       short *elu,   short *ru,  short *stat, short *ca )
{
	SETVCTL(handle, 27, 0, 2, 0);

	c.x.ii[0]=rl;
	c.x.ii[1]=nr;
	TRPVPB(0L, pxy, ca, 0L);
	if (elu) *elu =c.x.ii[2];
	if (ru)  *ru  =c.x.ii[3];
	if (stat)*stat=c.x.ii[4];
}

short V_decl vq_color (short handle, short ci, short sf, short *rgb)
{
	short ii[2], io[4];
	SETVCTL(handle, 26, 2, 0, 0);

	ii[0] = ci;
	ii[1] = sf;
	TRPVPB(ii, 0L, io, 0L);
	if (rgb)
	{
		rgb[0]=io[1];
		rgb[1]=io[2];
		rgb[2]=io[3];
	}
	return io[0];
}

void V_decl vq_extnd(short handle, short owflag, short *work_out)
{
	SETVCTL(handle, 102, 1, 0, 0);
	TRPVPB(&owflag, 0L, work_out, work_out+45);
}

void V_decl vq_chcell (short handle, short *rows, short *cols)
{
	short io[2];
	SETVCTL(handle, 5, 0, 0, 1);

	TRPVPB(0L, 0L, io, 0L);
	if (rows) *rows=io[0];
	if (cols) *cols=io[1];
}

void V_decl vq_curaddress (short handle, short *row, short *col)
{
	short io[2];
	SETVCTL(handle, 5, 0, 0, 15);

	TRPVPB(0L, 0L, io, 0L);
	if (row) *row=io[0];
	if (col) *col=io[1];
}

short V_decl vq_tabstat(short handle)
{
	short io;
	SETVCTL(handle, 5, 0, 0, 16);

	TRPVPB(0L, 0L, &io, 0L);
	return io;
}
