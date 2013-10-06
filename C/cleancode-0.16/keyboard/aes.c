/*
	Atari keyboard manager, using Aes

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

#include <gem.h>
#include <mint/osbind.h>

/*--- Defines ---*/

#define SCANCODE_ESC	0x01

/*--- Functions ---*/

int main(int argc, char **argv)
{
	int quit;
	short apid;

	/* Availability: all systems, no test */

	/* Open AES */
	apid = appl_init();
	if (apid == -1) {
		printf("Can not open AES\n");
		exit(1);
	}

	/* Wait till ESC key pressed */
	printf("Press ESC to quit\n");

	quit = 0;
	while (!quit) {

		unsigned char scancode;
		int resultat;
		short buffer[8], kc, ks, dummy;
		
		resultat = evnt_multi(
			MU_KEYBD,
			0,0,0,
			0,0,0,0,0,
			0,0,0,0,0,
			buffer,
			10,
			&dummy,&dummy,&dummy,&ks,&kc,&dummy
		);
		
		/* Keyboard event ? */
		if (resultat & MU_KEYBD) {
			scancode = (kc>>8) & 0xff;
			printf("Scancode=0x%02x, ascii code=0x%02x, special keys=0x%02x\n",
				scancode, kc & 0xff, ks);
			quit = (scancode == SCANCODE_ESC);
		}
	}

	/* Close AES */
	appl_exit();
}
