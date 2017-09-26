/*
	CentScreen definitions

	Copyright (C) 2002	Patrice Mandin

	This library is free software; you can redistribute it and/or
	modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.

	This library is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	Lesser General Public License for more details.

	You should have received a copy of the GNU Lesser General Public
	License along with this library; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
*/

#ifndef _CSCREEN_H
#define _CSCREEN_H

#include <mint/falcon.h>	/* for trap_14_xxx macros */

/*--- Defines ---*/

#define C_CNTS 0x434e5453L

/*--- Structures ---*/

typedef struct {
	unsigned short handle;	/* handle du mode video */
	unsigned short mode;	/* mode video falcon */
	unsigned short physx;	/* largeur physique */
	unsigned short physy;	/* hauteur physique */
	unsigned short plan;	/* nombre de plan */
	unsigned short logx;	/* largeur virtuelle */
	unsigned short logy;	/* hauteur virtuelle */
	unsigned short eco;		/* delai de l'economiseur */
	unsigned short eco2;	/* delai pour l'energy star */
	unsigned short wsize;	/* largeur en mm de l'ecran (1.1) */
	unsigned short hsize;	/* hauteur en mm de l'ecran (1.1) */
	unsigned short dummy[21];
	unsigned char name[32];	/* nom du mode video */
} centscreen_mode_t;

/*--- Functions prototypes ---*/

#define Vread(current_mode)	\
	(void)trap_14_wl((short)0x41,(long)(current_mode))
#define Vwrite(init_vdi, inparam, outparam)	\
	(long)trap_14_wwll((short)0x42,(short)(init_vdi),(long)(inparam),(long)(outparam))
#define Vattrib(inparam, outparam)	\
	(void)trap_14_wll((short)0x43,(long)(inparam),(long)(outparam))
#define Vcreate(inparam, outparam)	\
	(void)trap_14_wll((short)0x44,(long)(inparam),(long)(outparam))
#define Vdelete(handle)	\
	(long)trap_14_ww((short)0x45,(short)(handle))
#define Vfirst(mask,mode)	\
	(long)trap_14_wll((short)0x46,(long)(mask),(long)(mode))
#define Vnext(mask,mode)	\
	(long)trap_14_wll((short)0x47,(long)(mask),(long)(mode))
#define Vvalid(handle)	\
	(long)trap_14_ww((short)0x48,(short)(handle))
#define Vload()	\
	(long)trap_14_w((short)0x49)
#define Vsave()	\
	(long)trap_14_w((short)0x4a)
#define Vopen()	\
	(long)trap_14_w((short)0x4b)
#define Vclose()	\
	(long)trap_14_w((short)0x4c)
#define Vscroll(scrollmode)	\
	(long)trap_14_ww((short)0x4d,(short)(scrollmode))
#define Voffset()	\
	(long)trap_14_w((short)0x4e)
#define Vseek()	\
	(long)trap_14_w((short)0x4f)
#define Vlock(cmd)	\
	(long)trap_14_ww((short)0x50,(short)(cmd))
#define SetMon(montype)	\
	(long)trap_14_ww((short)0x51,(short)(montype))
#define MultiMon(cmd)	\
	(long)trap_14_ww((short)0x52,(short)(cmd))
#define VSizeComp()	\
	(long)trap_14_w((short)0x53)
#define Vsize(mode)	\
	(long)trap_14_wl((short)0x54,(long)(mode))

#endif /* _CSCREEN_H */
