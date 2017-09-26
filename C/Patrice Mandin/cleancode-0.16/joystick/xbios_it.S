/*
	XBIOS joystick interrupt

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

	.text

	.globl	_XbiosInstall
	.globl	_XbiosJoystickVector

	.globl	_Xbios_joystick

/*--- Vector installer ---*/

_XbiosInstall:
	movel	sp@(4),a0

	/* Stop interrupts */

	movew	#0x2700,sr

	/* Save old joystick vector, set our routine */

	movel	sp@(12),d0
	beqs	no_new_joystick_vector
	movel	a0@(24),oldjoystickvector
	movel	d0,a0@(24)
no_new_joystick_vector:

	/* Restart interrupts */

	movew	#0x2300,sr

	rts

/*--- Our joystick vector ---*/

	.text
	.even
	.ascii "XBRA"
	.ascii "LSDL"
	.comm	oldjoystickvector,4*1
_XbiosJoystickVector:
	moveml	d0/a1,sp@-

	/* New joystick state */
	moveb	a0@(1),d0
	andw	#0x8f,d0
	movew	d0,_Xbios_joystick

	/* Jump through old vector */
	movel	oldjoystickvector,a1
	jsr	(a1)

	moveml	sp@+,d0/a1
	rts

	.data
	.even
	.comm	_Xbios_joystick,2*1

