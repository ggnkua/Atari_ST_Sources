/*
	Atari mouse manager, using Aes (evnt_multi method)

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

/*--- Variables ---*/

short work_in[12], work_out[272];
short vdihandle;
int vdiwidth, vdiheight, vdibpp;
unsigned short deskx, desky, deskw, deskh;
int winhandle;

unsigned char *GEM_title_name="AES test";

/*--- Functions prototypes ---*/

int OpenWorkstation(void);
void CloseWorkstation(void);

int CreateWindow(void);
void DestroyWindow(void);

/*--- Functions ---*/

int main(int argc, char **argv)
{
	int i, quit;

	unsigned short prev_mousex, prev_mousey, prev_mouseb;
	unsigned short Aes_mousex, Aes_mousey, Aes_mouseb, kstate;
	unsigned short dummy;

	short apid;

	/* Open AES */
	apid = appl_init();
	if (apid == -1) {
		printf("Can not open AES\n");
		exit(1);
	}

	/* We need a window to get mouse clicks
	  (specially with a multitasking AES) */
	if (OpenWorkstation()) {
		printf("Can not open workstation\n");
		appl_exit();
		exit(1);
	}

	if (CreateWindow()) {
		printf("Can not create window\n");
		CloseWorkstation();
		appl_exit();
		exit(1);
	}

	/* Wait till ESC key pressed */
	printf("Press ESC to quit\n");

	/* Read current mouse position */
	graf_mkstate(&Aes_mousex, &Aes_mousey, &Aes_mouseb, &dummy);
	prev_mousex = Aes_mousex;
	prev_mousey = Aes_mousey;
	prev_mouseb = Aes_mouseb;

	quit = 0;
	while (!quit) {

		unsigned char scancode;
		int resultat;
		short buffer[8], kc, ks;
		
		/* Watch mouse leaving its current position */
		resultat = evnt_multi(
			MU_KEYBD|MU_M1|MU_BUTTON,
			0x101, 3, (~Aes_mouseb) & 3,
			MO_LEAVE,Aes_mousex,Aes_mousey,1,1,
			0,0,0,0,0,
			buffer,
			10,
			&Aes_mousex,&Aes_mousey,&Aes_mouseb,&ks,&kc,&dummy
		);
		
		/* Keyboard event ? */
		if (resultat & MU_KEYBD) {
			scancode = (kc>>8) & 0xff;
			quit = (scancode == SCANCODE_ESC);
		}

		/* Mouse motion ? */
		if (resultat & MU_M1) {
			if ((Aes_mousex!=prev_mousex) || (Aes_mousey!=prev_mousey)) {
				printf("Mouse: X=%d, Y=%d\n",Aes_mousex, Aes_mousey); 
				prev_mousex = Aes_mousex;
				prev_mousey = Aes_mousey;
			}
		}

		if (resultat & MU_BUTTON) {
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
	}

	DestroyWindow();
	appl_exit();
	CloseWorkstation();
}

int OpenWorkstation(void)
{
	unsigned short dummy;
	int i;

	/* Ask VDI physical workstation handle opened by AES */
	vdihandle = graf_handle(&dummy, &dummy, &dummy, &dummy);
	if (vdihandle<1) {
		fprintf(stderr,"Wrong VDI handle %d returned by AES\n",vdihandle);
		return 1;
	}

	/* Open virtual VDI workstation */
	work_in[0]=Getrez()+2;
	for(i = 1; i < 10; i++)
		work_in[i] = 1;
	work_in[10] = 2;

	v_opnvwk(work_in, &vdihandle, work_out);
	if (vdihandle == 0) {
		fprintf(stderr,"Can not open VDI virtual workstation\n");
		return 1;
	}

	/* Read fullscreen size */
	vdiwidth = work_out[0] + 1;
	vdiheight = work_out[1] + 1;

	vq_extnd(vdihandle, 1, work_out);
	vdibpp = work_out[4];

	printf("VDI screen: %dx%dx%d\n",vdiwidth, vdiheight, vdibpp);
	return 0;
}

void CloseWorkstation(void)
{
	if (vdihandle) {
		v_clsvwk(vdihandle);
	}
}

int CreateWindow(void)
{
	int posx,posy, width, height;
	int wintype;
	short x2,y2,w2,h2;

	/* Read desktop size and position */
	if (!wind_get(DESKTOP_HANDLE, WF_WORKXYWH, &deskx, &desky, &deskw, &deskh)) {
		fprintf(stderr,"Can not read desktop properties\n");
		return 1;
	}

	/* Set mouse cursor to arrow */
	graf_mouse(ARROW, NULL);

	width=160;
	height=100;
	wintype = NAME|MOVER;

	/* Center our window */
	posx = deskx;
	posy = desky;
	if (width<deskw)
		posx += (deskw - width) >> 1;
	if (height<deskh)
		posy += (deskh - height) >> 1;

	if (!wind_calc(0, wintype, posx, posy, width, height, &x2, &y2, &w2, &h2)) {
		fprintf(stderr,"Can not calculate window attributes\n");
		return 1;
	}

	/* Create window */
	winhandle=wind_create(wintype, x2, y2, w2, h2);
	if (winhandle<0) {
		fprintf(stderr,"Can not create window\n");
		return 1;
	}

	/* Setup window name */
	wind_set(winhandle,WF_NAME,(short)(((unsigned long)GEM_title_name)>>16),(short)(((unsigned long)GEM_title_name) & 0xffff),0,0);
	
	/* Open the window */
	wind_open(winhandle,x2,y2,w2,h2);
	
	return 0;
}

void DestroyWindow(void)
{
	/* Destroy window */
	if (winhandle>=0) {
		wind_close(winhandle);
		wind_delete(winhandle);
	}
}
