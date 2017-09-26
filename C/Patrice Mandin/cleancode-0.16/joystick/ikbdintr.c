/*
	Atari keyboard manager, using IKBD (interrupt method)

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

#include "ikbd.h"

/*--- Defines ---*/

#define SCANCODE_ESC	0x01

/*--- Variables ---*/

unsigned short prev_joystick;

/*--- Functions ---*/

int main(int argc, char **argv)
{
	int i;

	/* Availability: all Atari machines, Hades, Medusa */

	/* We do not change the IKBD setup, which is report
     * relative mouse motion, and joystick on port 1
	 */

	memset(Ikbd_keyboard, 0, 128);
	Ikbd_mousex = Ikbd_mousey = Ikbd_mouseb = Ikbd_joystick = 0;
	prev_joystick = 0;

	/* Install our asm handler */
	Supexec(IkbdInstall);

	printf("Press ESC to quit\n");

	/* Wait till ESC key pressed */
	while (Ikbd_keyboard[SCANCODE_ESC] == 0) {

		if (Ikbd_joystick != prev_joystick) {
			printf("Joystick: ");
			if (Ikbd_joystick & IKBD_JOY_UP) {
				printf("up ");
			}
			if (Ikbd_joystick & IKBD_JOY_DOWN) {
				printf("down ");
			}
			if (Ikbd_joystick & IKBD_JOY_LEFT) {
				printf("left ");
			}
			if (Ikbd_joystick & IKBD_JOY_RIGHT) {
				printf("right ");
			}
			if (Ikbd_joystick & IKBD_JOY_FIRE) {
				printf("fire ");
			}
			printf("\n");

			prev_joystick = Ikbd_joystick;
		}
	}

	/* Uninstall our asm handler */
	Supexec(IkbdUninstall);
}
