/*
	Atari keyboard manager, using /dev/mouse

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

/*--- Defines ---*/

#define DEVICE_NAME	"/dev/mouse"

/*--- Variables ---*/

short mousex, mousey;
unsigned short mouseb;

short prev_mousex, prev_mousey;
unsigned short prev_mouseb;

/*--- Functions ---*/

int main(int argc, char **argv)
{
	int handle;
	unsigned char buffer[3];

	/* Availability: multitasking OS */

	/* Open device */
	handle = open(DEVICE_NAME, 0);
	if (handle<0) {
		printf("Can not open " DEVICE_NAME "\n");
	}

	/* Loop */
	printf("Press CTRL-C to quit\n");

	mousex = mousey = 0;
	prev_mousex = prev_mousey = 0;
	mouseb = prev_mouseb = 0x07;

	for (;;) {
		/* Read new mouse info */
		if (read(handle, buffer, 3)>0) {
			mouseb = buffer[0];
			mousex += (short) ((char) buffer[1]);
			mousey += (short) ((char) buffer[2]);
		}

		/* Mouse motion ? */
		if ((mousex!=prev_mousex) || (mousey!=prev_mousey)) {
			printf("Mouse: X=%d, Y=%d\n",mousex, mousey); 
			prev_mousex = mousex;
			prev_mousey = mousey;
		}

		/* Mouse button ? */
		if (mouseb != prev_mouseb) {
			int i;

			for (i=0;i<3;i++) {
				int curbutton, prevbutton;

				curbutton = mouseb & (1<<i);
				prevbutton = prev_mouseb & (1<<i);
			
				if (curbutton && !prevbutton) {
					printf("Mouse: button %d released\n", i);
				}
				if (!curbutton && prevbutton) {
					printf("Mouse: button %d pressed\n", i);
				}
			}

			prev_mouseb = mouseb;
		}
	}

	/* Close device */
	close(handle);
}
