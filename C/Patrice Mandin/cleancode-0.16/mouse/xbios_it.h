/*
	Xbios interrupt routine

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

#ifndef _XBIOSINTERRUPT_S_H
#define _XBIOSINTERRUPT_S_H

#include <mint/osbind.h>

/* Variables */

extern unsigned short	Xbios_mouseb;		/* Mouse on port 0, buttons */
extern short 			Xbios_mousex;		/* Mouse X relative motion */
extern short 			Xbios_mousey;		/* Mouse Y relative motion */
										
/* Functions */ 
extern void XbiosInstall(_KBDVECS *kbdvecs,void *newmousevector);
extern void XbiosMouse(void *buf);

#endif /* _XBIOSINTERRUPT_S_H */
