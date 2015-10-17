/*
	Atari mouse manager, using Xbios

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

#include <stdio.h>
#include <string.h>

#include <mint/osbind.h>

#include "xbios_it.h"
#include "ikbd.h" /* for IBKD_JOY_ */

/*--- Defines ---*/

#define SCANCODE_ESC	0x01

/*--- Variables ---*/

_KBDVECS *kbdvecs;		/* Pointer to access vectors */
_KBDVECS sys_kbdvecs;	/* Backup of system vectors */

unsigned short prev_joystick;

/*--- Functions ---*/

int main(int argc, char **argv)
{
	void *oldstack;
	unsigned long key_pressed;
	unsigned char scancode;
	int i;

	/* Availability: all systems */

	Xbios_joystick = 0;
	prev_joystick = 0;

	/* Read IKBD vectors base */
	kbdvecs=Kbdvbase();

	/* Go to supervisor mode */
	oldstack=(void *)Super(NULL);

	/* Backup system vectors */
	memcpy(&sys_kbdvecs, kbdvecs, sizeof(_KBDVECS));

	/* Install our asm handler */
	XbiosInstall(kbdvecs, XbiosJoystickVector);

	/* Back to user mode */
	Super(oldstack);

	/* Wait till ESC key pressed */
	key_pressed = scancode = 0;

	printf("Press ESC to quit\n");

	while (scancode != SCANCODE_ESC) {

		/* Read key pressed, if needed */
		if (Cconis()) {
			key_pressed = Cnecin();
			scancode = (key_pressed >>16) & 0xff;
		}

		if (Xbios_joystick != prev_joystick) {
			printf("Joystick: ");
			if (Xbios_joystick & IKBD_JOY_UP) {
				printf("up ");
			}
			if (Xbios_joystick & IKBD_JOY_DOWN) {
				printf("down ");
			}
			if (Xbios_joystick & IKBD_JOY_LEFT) {
				printf("left ");
			}
			if (Xbios_joystick & IKBD_JOY_RIGHT) {
				printf("right ");
			}
			if (Xbios_joystick & IKBD_JOY_FIRE) {
				printf("fire ");
			}
			printf("\n");

			prev_joystick = Xbios_joystick;
		}
	}

	/* Go to supervisor mode */
	oldstack=(void *)Super(NULL);

	/* Reinstall system vector */
	XbiosInstall(kbdvecs,sys_kbdvecs.joyvec);

	/* Back to user mode */
	Super(oldstack);
}
