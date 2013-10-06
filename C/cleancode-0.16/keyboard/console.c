/*
	Atari keyboard manager, using /dev/console

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

#define DEVICE_NAME	"/dev/console"

/*--- Functions ---*/

int main(int argc, char **argv)
{
	int handle;
	unsigned char buffer;

	/* Availability: multitasking OS */

	/* Open device */
	handle = open(DEVICE_NAME, 0);
	if (handle<0) {
		printf("Can not open " DEVICE_NAME "\n");
	}

	/* Loop */
	printf("Press CTRL-C to quit\n");

	for (;;) {
		/* Print received input */
		while (read(handle, &buffer, 1)>0) {
			if ((buffer<32) || (buffer>127)) {
				printf("Key with asciicode 0x%02x pressed\n",buffer);
			} else {
				printf("Key with asciicode 0x%02x ('%c') pressed\n",buffer,buffer);
			}
		}
	}

	/* Close device */
	close(handle);
}
