/*
	IKBD 6301 interrupt routine

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

#ifndef _IKBD_H
#define _IKBD_H

/* Const */

#define IKBD_JOY_UP		(1<<0)
#define IKBD_JOY_DOWN	(1<<1)
#define IKBD_JOY_LEFT	(1<<2)
#define IKBD_JOY_RIGHT	(1<<3)
#define IKBD_JOY_FIRE	(1<<7)

/* Variables */

extern unsigned char	Ikbd_keyboard[128];	/* Keyboard table */
extern unsigned short	Ikbd_mouseb;		/* Mouse on port 0, buttons */
extern short 			Ikbd_mousex;		/* Mouse X relative motion */
extern short 			Ikbd_mousey;		/* Mouse Y relative motion */
extern unsigned short	Ikbd_joystick;		/* Joystick on port 1 */
										
/* Functions */ 
extern void IkbdInstall(void);
extern void IkbdUninstall(void);

#endif /* _IKBD_H */
