/*
	Video demo, using Aes

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

/* vs_clip() params */
enum {
	CLIP_OFF=0,
	CLIP_ON
};

/*--- Variables ---*/

short winhandle;

framebuffer_t vdifb;
framebuffer_t indirectfb;

/* Window title */
unsigned char *GEM_title_name="AES video test";
int GEM_win_fulled;

/* Desktop size */
short deskx,desky,deskw,deskh;

/* indirect buffer length */
unsigned long screensize;

/*--- Functions prototypes ---*/

int CreateWindow(void);
void DestroyWindow(void);

void DrawDemoLoop(void);
int DrawDemoMessages(short *message);
void DrawDemoRedraw(int winhandle, short *inside);

void DrawDemo(int winhandle, short *rect);

/*--- Functions ---*/

int main(int argc, char **argv)
{
	int dummy;

	PAR_TestRedirect(argc, argv);
	if (output_to_file) {
		PAR_RedirectStdout();
	}

	if (appl_init() == -1) {
		fprintf(stderr, "Can not open AES\n");
		exit(1);
	}

	if (VDI_OpenWorkstation(gl_apid)== -1) {
		appl_exit();
		exit(1);
	}

	VDI_ReadInfos(&vdifb);

	if (!output_to_file) {
		/* Singletasking AES: wait the keypress */
		if (aes_params.global[1]==1) {
			printf("Press a key to continue\n");
			while (Cconis()==0) { }
			while (Cconis()!=0) { dummy = Cnecin(); }
		}

		if (CreateWindow()) {
			printf("Can not create window\n");
			appl_exit();
			VDI_CloseWorkstation(gl_apid);
			exit(1);
		}

		VDI_SavePalette(&vdifb);
		VDI_InitPalette(&vdifb);

		memcpy(&indirectfb, &vdifb, sizeof(framebuffer_t));
		screensize = VDI_AllocateIndirectBuffer(&indirectfb);

		DrawDemoLoop();

		VDI_FreeIndirectBuffer(&indirectfb);
		VDI_RestorePalette(&vdifb);

		DestroyWindow();
	} else {
		fclose(output_handle);
	}

	appl_exit();

	VDI_CloseWorkstation(gl_apid);
}

int CreateWindow(void)
{
	int wintype;
	int posx,posy, width, height;
	short x2,y2,w2,h2;

	/* Read desktop size and position */
	if (!wind_get(DESKTOP_HANDLE, WF_WORKXYWH, &deskx, &desky, &deskw, &deskh)) {
		fprintf(stderr,"Can not read desktop properties\n");
		return 1;
	}

	/* Set mouse cursor to arrow */
	graf_mouse(ARROW, NULL);

	width=deskw>>1;
	height=deskh>>1;
	wintype = NAME|MOVER|CLOSER|SIZER|FULLER;

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

	GEM_win_fulled = 0;
	
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

/*--- Drawing demo loop ---*/

void DrawDemoLoop(void)
{
	int quit;
	
	quit = 0;
	while (!quit) {

		unsigned char scancode;
		int resultat;
		short buffer[8], kc, ks, dummy;
		
		resultat = evnt_multi(
			MU_KEYBD|MU_MESAG,
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
			quit = (scancode == SCANCODE_ESC);
			/* Do not test following events */
			if (quit) {
				continue;
			}
		}

		/* Window event ? */
		if (resultat & MU_MESAG) {
			quit = DrawDemoMessages(buffer);
		}
	}
}

int DrawDemoMessages(short *message)
{
	int quit;
	short newmsg[8];
	
	quit=0;
	switch (message[0]) {
		case WM_CLOSED:
		case AP_TERM:    
			quit=1;
			break;
		case WM_MOVED:
			{
				wind_set(message[3],WF_CURRXYWH,message[4],message[5],message[6],message[7]);

				newmsg[0] = WM_REDRAW;
				newmsg[1] = message[1];
				newmsg[2] = message[2];
				newmsg[3] = message[3];
				newmsg[4] = message[4];
				newmsg[5] = message[5];
				newmsg[6] = message[6];
				newmsg[7] = message[7];

				appl_write(gl_apid, sizeof(newmsg), newmsg);
			}
			break;
		case WM_TOPPED:
			{
				wind_set(message[3],WF_TOP,message[4],0,0,0);

				newmsg[0] = WM_REDRAW;
				newmsg[1] = message[1];
				newmsg[2] = message[2];
				newmsg[3] = message[3];
				newmsg[4] = message[4];
				newmsg[5] = message[5];
				newmsg[6] = message[6];
				newmsg[7] = message[7];

				appl_write(gl_apid, sizeof(newmsg), newmsg);
			}
			break;
		case WM_REDRAW:
			if (message[3]==winhandle) {
				DrawDemoRedraw(message[3], &message[4]);
			}
			break;
		case WM_SIZED:
			{
				short wind_pxy[8];
				int redraw_event=0;
				
				/* Generate redraw event if new resized window smaller */
				wind_get(message[3], WF_CURRXYWH, &wind_pxy[0], &wind_pxy[1], &wind_pxy[2], &wind_pxy[3]);

				redraw_event=((wind_pxy[2]>message[6]) || (wind_pxy[3]>message[7]));

				wind_set (message[3], WF_CURRXYWH, message[4], message[5], message[6], message[7]);
				GEM_win_fulled = 0;

				if (redraw_event) {
					newmsg[0] = WM_REDRAW;
					newmsg[1] = message[1];
					newmsg[2] = message[2];
					newmsg[3] = message[3];
					newmsg[4] = message[4];
					newmsg[5] = message[5];
					newmsg[6] = message[6];
					newmsg[7] = message[7];

					appl_write(gl_apid, sizeof(newmsg), newmsg);
				}
			}
			break;
		case WM_FULLED:
			{
				short x,y,w,h;

				if (GEM_win_fulled) {
					wind_get (message[3], WF_PREVXYWH, &x, &y, &w, &h);
					GEM_win_fulled = 0;
				} else {
					x = deskx;
					y = desky;
					w = deskw;
					h = deskh;
					GEM_win_fulled = 1;
				}
				wind_set (message[3], WF_CURRXYWH, x, y, w, h);
			}
			break;
	}

	return quit;
}

void DrawDemoRedraw(int winhandle, short *inside)
{
	short todo[4];

	v_hide_c(vdi_handle);

	/* Tell AES we are going to update */
	wind_update(BEG_UPDATE);

	/* Browse the rectangle list to redraw */
	wind_get(winhandle, WF_FIRSTXYWH, &todo[0], &todo[1], &todo[2], &todo[3]);

	while (todo[2] && todo[3]) {

		if (rc_intersect((GRECT *)inside,(GRECT *)todo)) {
			todo[2] += todo[0]-1;
			todo[3] += todo[1]-1;
			DrawDemo(winhandle, todo);
		}

		wind_get(winhandle, WF_NEXTXYWH, &todo[0], &todo[1], &todo[2], &todo[3]);
	}

	/* Update finished */
	wind_update(END_UPDATE);

	v_show_c(vdi_handle,1);
}

/*--- Example drawing demo ---*/

void DrawDemo(int winhandle, short *rect)
{
	int sizex, sizey, posx, posy;
	short	wind_pxy[8];
	fbrect_t drawrect, indrect;

	wind_get(winhandle, WF_WORKXYWH, &wind_pxy[0], &wind_pxy[1], &wind_pxy[2], &wind_pxy[3]);

	/* Clear screen */
	vs_clip(vdi_handle, CLIP_ON, rect);
	VDI_ClearScreen(&vdifb);
	vs_clip(vdi_handle, CLIP_OFF, rect);

	memset(indirectfb.buffer, 0, screensize);

	/* Calculate size of rectangles */
	posx = wind_pxy[0] + BORDER;
	posy = wind_pxy[1] + BORDER;
	sizex = (wind_pxy[2]/3)-(BORDER<<1);
	sizey = (wind_pxy[3]/3)-(BORDER<<1);

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

	indrect.x = wind_pxy[0] + wind_pxy[2]/3;
	indrect.y = wind_pxy[1] + 0;
	indrect.w = wind_pxy[2]/3;
	indrect.h = wind_pxy[3];
	VDI_DrawBars_vrocpyfm(&indirectfb, &indrect);

	/* Draw R,G,B bars on the right, using VDI */
	vs_clip(vdi_handle, CLIP_ON, rect);
	drawrect.x = posx+((sizex+(BORDER<<1))<<1);
	drawrect.y = posy;
	VDI_DrawBars_vbar(&vdifb, &drawrect, COMPONENT_RED);
	drawrect.x = posx+((sizex+(BORDER<<1))<<1);
	drawrect.y = posy+sizey+(BORDER<<1);
	VDI_DrawBars_vbar(&vdifb, &drawrect, COMPONENT_GREEN);
	drawrect.x = posx+((sizex+(BORDER<<1))<<1);
	drawrect.y = posy+((sizey+(BORDER<<1))<<1);
	VDI_DrawBars_vbar(&vdifb, &drawrect, COMPONENT_BLUE);
	vs_clip(vdi_handle, CLIP_OFF, rect);
}
