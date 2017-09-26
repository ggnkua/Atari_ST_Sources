/*
	Metados CD-ROM demo program

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

#include "metados.h"
#include "param.h"

/*--- Defines ---*/

#define SCANCODE_ESC	0x01

/*--- Functions prototypes ---*/

void ListMetadosDrives(metainit_t *metainit);

void DemoLoop(void);

/*--- Functions ---*/

int main(int argc, char **argv)
{
	metainit_t metainit={0,0,0,0};

	PAR_TestRedirect(argc, argv);
	if (output_to_file) {
		PAR_RedirectStdout();
	}

	Minit(&metainit);
	if (metainit.version == NULL) {
		fprintf(output_handle, "Metados not installed\n");
	} else {
		fprintf(output_handle, "Metados driver installed:\n %s\n", metainit.version);
		if (metainit.drives_map) {
			ListMetadosDrives(&metainit);
		} else {
			fprintf(output_handle, "List of Metados drives empty\n");
		}
	}

	if (!output_to_file) {
		DemoLoop();
	} else {
		fclose(output_handle);
	}
}

void ListMetadosDrives(metainit_t *metainit)
{
	metaopen_t metaopen;
	int handle, i;

	fprintf(output_handle, "List of Metados drives: 0x%08x\n", metainit->drives_map);
	for (i='A'; i<='Z'; i++) {
		if (metainit->drives_map & (1<<(i-'A'))) {
			fprintf(output_handle, "  Drive %c:", i);
			handle = Mopen(i, &metaopen); 
			if (handle==0) {
				fprintf(output_handle, " %s\n", metaopen.name);

				Mclose(i);
			} else {
				fprintf(output_handle, " Can not open drive\n");
			}
		}
	}
}

/*--- Little demo loop ---*/

void DemoLoop(void)
{
	unsigned long key_pressed;
	unsigned char scancode;

	printf("Press ESC to quit\n");

	key_pressed = scancode = 0;
	while (scancode != SCANCODE_ESC) {

		/* Read key pressed, if needed */
		if (Cconis()) {
			key_pressed = Cnecin();
			scancode = (key_pressed >>16) & 0xff;

			/* Wait key release */
			while (Cconis()!=0) { }
		}
	}
}
