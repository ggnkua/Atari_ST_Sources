/*
	EdDI extension for VDI

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

#ifndef _EDDI_S_H
#define _EDDI_S_H

/*--- EdDI defines ---*/

/* EdDI versions */
#define EDDI_10	(0x0100)
#define EDDI_11 (0x0110)

/* EdDI screen format */
enum {
	FORMAT_BITPLANES=0,
	FORMAT_VDI,
	FORMAT_PACKED
};

/* EdDI CLUT types */
enum {
	CLUT_NONE=0,
	CLUT_HARDWARE,
	CLUT_SOFTWARE
};

/*--- Functions prototypes ---*/

unsigned long get_EdDI_version(void *function_pointer);

#endif /* _EDDI_S_H */
