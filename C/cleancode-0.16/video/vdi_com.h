/*
	Vdi common code, used by AES and VDI demo programs

	Copyright (C) 2002	Patrice Mandin

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

#ifndef _VDI_COM_H
#define _VDI_COM_H

#include "rgb.h"

/*--- Variables ---*/

extern short vdi_workin[12], vdi_workout[272];
extern short vdi_handle;

/* Hardware -> vdi palette mapping */
extern unsigned char vdi_index[256];

/* Current VDI palette */
extern short vdi_palette[256][3];

/*--- Functions prototypes ---*/

int VDI_OpenWorkstation(int apid);
void VDI_CloseWorkstation(int apid);

void VDI_SavePalette(framebuffer_t *framebuffer);
void VDI_RestorePalette(framebuffer_t *framebuffer);

void VDI_ReadInfos(framebuffer_t *framebuffer);

void VDI_ClearScreen(framebuffer_t *framebuffer);
void VDI_InitPalette(framebuffer_t *framebuffer);

unsigned long VDI_AllocateIndirectBuffer(framebuffer_t *framebuffer);
void VDI_FreeIndirectBuffer(framebuffer_t *framebuffer);

void VDI_DrawBars_vrocpyfm(framebuffer_t *framebuffer, fbrect_t *rect);
void VDI_DrawBars_vbar(framebuffer_t *framebuffer, fbrect_t *rect, int component);

#endif /* _VDI_COM_H */
