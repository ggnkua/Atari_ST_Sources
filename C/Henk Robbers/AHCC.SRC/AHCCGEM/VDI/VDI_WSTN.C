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

VDIPARBLK _VDIParBlk;

/* needed for Emutos & firetos */
short v_tii[MAX_TXT];

void vdi(VDIPB *vdipb)
{
	VDI(vdipb);
}

short V_decl __asm__ vq_gdos(void)
{
	pea 	(a2)
	moveq	#-2,d0
	trap	#2
	addq.l	#2,d0
	movea.l	(sp)+,a2
	rts
}

short V_decl __asm__ vq_vgdos(void)
{
	pea 	(a2)
	moveq	#-2,d0
	trap	#2
	movea.l	(sp)+,a2
	rts
}
static
void _vopn(short fu, short *workin, short *handle, short *workout)
{
	SETVCTL(*handle, fu, 11, 0, 0);
	TRPVPB(workin, 0L, workout, workout+45);
	*handle = c.handle;
}

static
void _wst(short handle, short fu)
{
	SETVCTL(handle, fu, 0, 0, 0);
	TRPVPB(0L, 0L, 0L, 0L);
}

void V_decl v_opnwk(short *workin, short *handle, short *workout)
{ _vopn(1, workin, handle, workout); }
void V_decl v_opnvwk(short *workin, short *handle, short *workout)
{ _vopn(100, workin, handle, workout); }

void V_decl v_clswk (short handle) { _wst(handle, 2); }
void V_decl v_clrwk (short handle) { _wst(handle, 3); }
void V_decl v_updwk (short handle) { _wst(handle, 4); }
void V_decl v_clsvwk(short handle) { _wst(handle, 101); }


void V_decl vs_clip(short handle, short flag, short *pxy)
{
	SETVCTL(handle, 129, 1, 2, 0);
	TRPVPB(&flag, pxy, 0L, 0L);
}

short V_decl vst_load_fonts(short handle, short select)
{
	short io;
	SETVCTL(handle, 119, 1, 0, 0);
	TRPVPB(&select, 0L, &io, 0L);
	return io;
}

void V_decl vst_unload_fonts(short handle, short select)
{
	SETVCTL(handle, 120, 1, 0, 0);
	TRPVPB(&select, 0L, 0L, 0L);
	VDI(&pb);
}

short vdi_string(const char *fro, short *to, short max)
{
	short i = 0;
	while (i < max && *fro)
		*to++ = *(const unsigned char *)fro++, i++;
	return i;
}
