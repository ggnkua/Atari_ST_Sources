/*
	Atari mouse manager, using Vdi

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

#include "vdi_it.h"

/*--- Defines ---*/

#define SCANCODE_ESC	0x01

/*--- Functions ---*/

int main(int argc, char **argv)
{
	int i;
	unsigned long key_pressed;
	unsigned char scancode;

	unsigned short prev_mousex, prev_mousey, prev_mouseb;

	short work_in[12], work_out[272];
	short apid, vdi_handle, dummy;

	void *dummy_p;	

	/* Reset variables */
	Vdi_mousex = Vdi_mousey = Vdi_mouseb = 0;
	prev_mousex = prev_mousey = prev_mouseb = 0;

	/* For VDI open workstation */
	work_in[0]=Getrez()+2;
	for(i = 1; i < 10; i++)
		work_in[i] = 1;
	work_in[10] = 2;

	/* Ask GEM what workstation it has opened (if any) */
	apid = appl_init();
	if (apid == -1) {
		vdi_handle = -1;

		/* Open real workstation */
		v_opnwk(work_in, &vdi_handle, work_out);
		
	} else {
		vdi_handle = graf_handle(&dummy, &dummy, &dummy, &dummy);
		appl_exit();

		/* Open virtual workstation */
		v_opnvwk(work_in, &vdi_handle, work_out);
	}

	/* Install our vectors */
	vex_motv(vdi_handle, VdiMotionVector, &Vdi_oldmotionvector);
	vex_butv(vdi_handle, VdiButtonVector, &Vdi_oldbuttonvector);

	/* Wait till ESC key pressed */
	key_pressed = scancode = 0;

	printf("Press ESC to quit\n");

	while (scancode != SCANCODE_ESC) {

		/* Read key pressed, if needed */
		if (Cconis()) {
			key_pressed = Cnecin();
			scancode = (key_pressed >>16) & 0xff;
		}

		/* Mouse motion ? */
		if ((Vdi_mousex!=prev_mousex) || (Vdi_mousey!=prev_mousey)) {
			printf("Mouse: X=%d, Y=%d\n",Vdi_mousex, Vdi_mousey); 
			prev_mousex = Vdi_mousex;
			prev_mousey = Vdi_mousey;
		}

		/* Mouse button ? */
		if (Vdi_mouseb != prev_mouseb) {
			for (i=0;i<2;i++) {
				int curbutton, prevbutton;

				curbutton = Vdi_mouseb & (1<<i);
				prevbutton = prev_mouseb & (1<<i);
			
				if (curbutton && !prevbutton) {
					printf("Mouse: button %d pressed\n", i);
				}
				if (!curbutton && prevbutton) {
					printf("Mouse: button %d released\n", i);
				}
			}

			prev_mouseb = Vdi_mouseb;
		}
	}

	/* Restore old vectors */
	vex_motv(vdi_handle, Vdi_oldmotionvector, &dummy_p);
	vex_butv(vdi_handle, Vdi_oldbuttonvector, &dummy_p);

	/* Close workstation */
	if (apid == -1) {
		v_clswk(vdi_handle);
	} else {
		v_clsvwk(vdi_handle);
	}
}
