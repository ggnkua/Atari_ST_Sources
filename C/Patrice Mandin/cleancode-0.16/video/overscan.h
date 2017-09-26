/*
	OverScan definitions

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

#ifndef _OVERSCAN_H
#define _OVERSCAN_H

#include <mint/falcon.h>	/* for trap_14_xxx macros */

/*--- Types ---*/

typedef struct
{
   unsigned short low_w, mid_w, high_w;	/* Breite in Pixeln */
   unsigned short low_h, mid_h, high_h;	/* Höhe   in Pixeln */
   unsigned long low_off, mid_off, high_off;	/* Offset Bildspeicher<>Logbase */
   unsigned long mono_add, color_add;	/* Zusätzlicher Speicherbedarf */
   unsigned char clear_scan;	/* Scancode  der Clear-Funktion */
   unsigned char clear_shift;	/* Shiftcode der Clear-Funktion */
   unsigned char setup_shift;	/* Shiftcode für Setup (Maske) */
   unsigned char invert_shift;	/* Shiftcode zum Invert. des Modus */
   unsigned char abort_shift;	/* Shiftcode zum Abbrechen */
} OVERPATCH __attribute__((packed));

/*--- Functions prototypes ---*/
/* FIXME: I don't have Overscan documentation, these bindings are WRONG */

#define Oscanis(void)	\
	(void)trap_14_w((short)0x1068)
#define Oscantab(void)	\
	(void)trap_14_w((short)0x1069)
#define Oscanphy(void)	\
	(void)trap_14_w((short)0x106a)
#define Oscanscr(void)	\
	(void)trap_14_w((short)0x106b)
#define Oscanvb(void)	\
	(void)trap_14_w((short)0x106c)
#define Oscanpatch(void)	\
	(void)trap_14_w((short)0x106d)
#define Oscanswitch(void)	\
	(void)trap_14_w((short)0x106e)

#endif /* _OVERSCAN_H */
