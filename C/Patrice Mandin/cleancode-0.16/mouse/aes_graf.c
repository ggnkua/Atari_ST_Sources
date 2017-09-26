/*
	Atari mouse manager, using Aes (graf_mkstate method)

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
	int i;
	unsigned long key_pressed;
	unsigned char scancode;

	unsigned short prev_mousex, prev_mousey, prev_mouseb;
	unsigned short Aes_mousex, Aes_mousey, Aes_mouseb, kstate;

	short apid;

	/* Reset variables */
	Aes_mousex = Aes_mousey = Aes_mouseb = 0;
	prev_mousex = prev_mousey = prev_mouseb;

	/* Open AES */
	apid = appl_init();
	if (apid == -1) {
		printf("Can not open AES\n");
		exit(1);
	}

	/* Wait till ESC key pressed */
	key_pressed = scancode = 0;

	printf("Press ESC to quit\n");

	while (scancode != SCANCODE_ESC) {

		/* Read key pressed, if needed */
		if (Cconis()) {
			key_pressed = Cnecin();
			scancode = (key_pressed >>16) & 0xff;
		}

		graf_mkstate(&Aes_mousex, &Aes_mousey, &Aes_mouseb, &kstate);

		/* Mouse motion ? */
		if ((Aes_mousex!=prev_mousex) || (Aes_mousey!=prev_mousey)) {
			printf("Mouse: X=%d, Y=%d\n",Aes_mousex, Aes_mousey); 
			prev_mousex = Aes_mousex;
			prev_mousey = Aes_mousey;
		}

		/* Mouse button ? */
		if (Aes_mouseb != prev_mouseb) {
			for (i=0;i<2;i++) {
				int curbutton, prevbutton;

				curbutton = Aes_mouseb & (1<<i);
				prevbutton = prev_mouseb & (1<<i);
			
				if (curbutton && !prevbutton) {
					printf("Mouse: button %d pressed\n", i);
				}
				if (!curbutton && prevbutton) {
					printf("Mouse: button %d released\n", i);
				}
			}

			prev_mouseb = Aes_mouseb;
		}
	}

	appl_exit();
}
