/*
	Video demo, using VDI

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
#include <mint/cookie.h>

#include "eddi_s.h"
#include "rgb.h"
#include "mxalloc.h"
#include "vdi_com.h"
#include "param.h"

/*--- Defines ---*/

#define SCANCODE_ESC	0x01

#define BORDER 8

/*--- Variables ---*/

framebuffer_t vdifb;
framebuffer_t indirectfb;

/*--- Functions prototypes ---*/

void DrawDemo(void);

/*--- Functions ---*/

int main(int argc, char **argv)
{
	short my_apid;

	unsigned long key_pressed;
	unsigned char scancode;
	int dummy;

	PAR_TestRedirect(argc, argv);
	if (output_to_file) {
		PAR_RedirectStdout();
	}

	/* Ask AES what workstation it has opened (if any) */
	my_apid = appl_init();
	if (VDI_OpenWorkstation(my_apid)==-1) {
		exit(1);
	}
	if (my_apid == -1) {
		appl_exit();
	}

	VDI_ReadInfos(&vdifb);

	if (!output_to_file) {
		/* Read a key press, empty buffer */
		printf("Press a key to continue\n");
		while (Cconis()==0) { }
		while (Cconis()!=0) { dummy = Cnecin(); }

		VDI_SavePalette(&vdifb);
		VDI_InitPalette(&vdifb);

		memcpy(&indirectfb, &vdifb, sizeof(framebuffer_t));
		VDI_AllocateIndirectBuffer(&indirectfb);
	
		DrawDemo();

		/* Wait till a key pressed */
		while (Cconis()==0) { }

		VDI_FreeIndirectBuffer(&indirectfb);
		VDI_RestorePalette(&vdifb);
	} else {
		fclose(output_handle);
	}

	VDI_CloseWorkstation(my_apid);
}

/*--- Example drawing demo ---*/

void DrawDemo(void)
{
	int sizex, sizey, posx, posy;
	fbrect_t drawrect, indrect;

	/* Hide mouse cursor */
	v_hide_c(vdi_handle);

	VDI_ClearScreen(&vdifb);
	
	/* Calculate size of rectangles */
	sizex = (vdifb.width/3)-(BORDER<<1);
	sizey = (vdifb.height/3)-(BORDER<<1);
	posx = posy = BORDER;

	drawrect.w = sizex;
	drawrect.h = sizey;

	/* Draw R,G,B bars on the left, using direct rendering */
	if ((vdifb.buffer!=NULL) && (vdifb.pitch!=0)) {
		drawrect.x = posx;
		drawrect.y = posy;
		RGB_DrawBar(&vdifb, &drawrect, COMPONENT_RED);
		drawrect.x = posx;
		drawrect.y = posy+sizey+(BORDER<<1);
		RGB_DrawBar(&vdifb, &drawrect, COMPONENT_GREEN);
		drawrect.x = posx;
		drawrect.y = posy+((sizey+(BORDER<<1))<<1);
		RGB_DrawBar(&vdifb, &drawrect, COMPONENT_BLUE);
	}

	/* Draw R,G,B bars on the middle, using vro_cpyfm() */
	drawrect.x = posx+sizex+(BORDER<<1);
	drawrect.y = posy;
	RGB_DrawBar(&indirectfb, &drawrect, COMPONENT_RED);
	drawrect.x = posx+sizex+(BORDER<<1);
	drawrect.y = posy+sizey+(BORDER<<1);
	RGB_DrawBar(&indirectfb, &drawrect, COMPONENT_GREEN);
	drawrect.x = posx+sizex+(BORDER<<1);
	drawrect.y = posy+((sizey+(BORDER<<1))<<1);
	RGB_DrawBar(&indirectfb, &drawrect, COMPONENT_BLUE);

	indrect.x = indirectfb.width/3;
	indrect.y = 0;
	indrect.w = indirectfb.width/3;
	indrect.h = indirectfb.height;
	VDI_DrawBars_vrocpyfm(&indirectfb, &indrect);

	/* Draw R,G,B bars on the right, using VDI */
	drawrect.x = posx+((sizex+(BORDER<<1))<<1);
	drawrect.y = posy;
	VDI_DrawBars_vbar(&vdifb, &drawrect, COMPONENT_RED);
	drawrect.x = posx+((sizex+(BORDER<<1))<<1);
	drawrect.y = posy+sizey+(BORDER<<1);
	VDI_DrawBars_vbar(&vdifb, &drawrect, COMPONENT_GREEN);
	drawrect.x = posx+((sizex+(BORDER<<1))<<1);
	drawrect.y = posy+((sizey+(BORDER<<1))<<1);
	VDI_DrawBars_vbar(&vdifb, &drawrect, COMPONENT_BLUE);

	/* Show mouse cursor */
	v_show_c(vdi_handle, 1);
}

