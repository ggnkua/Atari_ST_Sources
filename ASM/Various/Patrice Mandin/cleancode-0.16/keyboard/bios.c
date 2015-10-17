/*
	Atari keyboard manager, using Bios

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

/*--- Defines ---*/

#define SCANCODE_ESC	0x01

/*--- Functions ---*/

int main(int argc, char **argv)
{
	unsigned long key_pressed;
	unsigned char asciicode, scancode, specialkeys;

	/* Availability: all systems, no test */

	/* Wait till ESC key pressed */
	asciicode = scancode = specialkeys = key_pressed = 0;

	printf("Press ESC to quit\n");

	while (scancode != SCANCODE_ESC) {

		/* Wait till a key is pressed */
		while (Bconstat(_CON)==0) {
		}

		/* Read key infos */
		key_pressed = Bconin(_CON);

		asciicode = key_pressed & 0xff;
		scancode = (key_pressed >> 16) & 0xff;
		specialkeys = (key_pressed >>24) & 0xff;

		printf("Ascii code=0x%02x, scancode=0x%02x, special keys=0x%02x\n",
			asciicode, scancode, specialkeys);

		/* We can also have special keys with another function */
		specialkeys = Kbshift(-1) & 0xff;
		printf(" Kbshift() special keys=0x%02x\n",specialkeys);
	}
}
