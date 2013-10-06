/*
	Vdi interrupt routine

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

#ifndef _VDI_S_H
#define _VDI_S_H

/* Variables */

extern unsigned short	Vdi_mouseb;		/* Mouse buttons */
extern unsigned short	Vdi_mousex;		/* Mouse X position */
extern unsigned short 	Vdi_mousey;		/* Mouse Y position */

extern void *Vdi_oldmotionvector;
extern void *Vdi_oldbuttonvector;

/* Functions */ 
extern void VdiMotionVector(unsigned short mx, unsigned short my);
extern void VdiButtonVector(unsigned short buttons);

#endif /* _VDI_S_H */
