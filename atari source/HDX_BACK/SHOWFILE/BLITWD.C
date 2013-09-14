/* blitwd.c */


#include "obdefs.h"
#include "gemdefs.h"

extern int handle;		 /* virtual workstation handle */


do_blit(wh, wdact, dir, pixel)	

int wh;			/* blit window handle */
GRECT *wdact;	/* the window to blit */
int dir;		/* the direction to blit */
int pixel;		/* number of pixel to blit */
{  

	GRECT wdrct;	/* the current window rectangle in rect list */ 

	wind_update(BEG_UPDATE);	/* lock screen */
	vsf_interior(handle, 1);	
	vsf_color(handle, 0);
	wind_get
		(wh, WF_FIRSTXYWH, &wdrct.g_x, &wdrct.g_y, &wdrct.g_w, &wdrct.g_h);
	while (wdrct.g_w && wdrct.g_h)	{	/* while it is not the last one */
		if (rc_intersect(wdact, &wdrct)) {/*check see if this one is damaged*/ 
			setclip(&wdrct);
			switch(dir)	{
				case 0:	blitup(wh, &wdrct, pixel);	/* blit arrow up */
						break;
				case 1:	blitdn(wh, &wdrct, pixel);	/* blit arrow down */
						break;
				case 2:	blitlf(wh, &wdrct, pixel);	/* blit arrow left */
						break;
				case 3:	blitrt(wh, &wdrct, pixel);	/* blit arrow right */
						break;
				default: break;
			}
		}
		wind_get
		  (wh, WF_NEXTXYWH, &wdrct.g_x, &wdrct.g_y, &wdrct.g_w, &wdrct.g_h);
	}
	wind_update(END_UPDATE);	/* unlock screen */
}


/* blit the window to left by # of pixel*/

blitlf(wh, box, pixel)
int wh;
GRECT *box;
int pixel;

{
	int pxyarray[8];
	int x[2]; 

	x[0] = 0;
	x[1] = 0;

	graf_mouse(M_OFF, 0L);
	pxyarray[0] = box->g_x;
	pxyarray[1] = box->g_y;
	pxyarray[2] = box->g_x+box->g_w-pixel;
	pxyarray[3] = box->g_y+box->g_h;
	pxyarray[4] = box->g_x+pixel;
	pxyarray[5] = box->g_y;
	pxyarray[6] = box->g_x+box->g_w;
	pxyarray[7] = box->g_y+box->g_h;
	vro_cpyfm(handle, 3, pxyarray, &x[0], &x[0]);
	ob_draw(wh, box->g_x, box->g_y, pixel, box->g_h);
	graf_mouse(M_ON, 0L);
}


/* blit the window to right by number of pixel */

blitrt(wh, box, pixel)
int wh;
GRECT *box;
int pixel;

{
	int pxyarray[8];
	int x[2]; 

	x[0] = 0;
	x[1] = 0;

	graf_mouse(M_OFF, 0L);
	pxyarray[0] = box->g_x+pixel;
	pxyarray[1] = box->g_y;
	pxyarray[2] = box->g_x+box->g_w;
	pxyarray[3] = box->g_y+box->g_h;
	pxyarray[4] = box->g_x;
	pxyarray[5] = box->g_y;
	pxyarray[6] = pxyarray[2]-pixel;
	pxyarray[7] = box->g_y+box->g_h;
	vro_cpyfm(handle, 3, pxyarray, &x[0], &x[0]);
	ob_draw(wh, box->g_x+box->g_w-pixel, box->g_y, pixel, box->g_h);
	graf_mouse(M_ON, 0L);
}



/* blit up the window by number of pixel */

blitup(wh, box, pixel)
int wh;
GRECT *box;
int pixel;

{
	int pxyarray[8];
	int x[2];

	x[0] = 0;
	x[1] = 0;

	graf_mouse(M_OFF, 0L);
	pxyarray[0] = box->g_x;
	pxyarray[1] = box->g_y;
	pxyarray[2] = box->g_x+box->g_w;
	pxyarray[3] = box->g_y+box->g_h-pixel;
	pxyarray[4] = box->g_x;
	pxyarray[5] = box->g_y+pixel;
	pxyarray[6] = box->g_x+box->g_w;
	pxyarray[7] = pxyarray[3]+pixel;
	vro_cpyfm(handle, 3, pxyarray, &x[0], &x[0]);
	ob_draw(wh, box->g_x, box->g_y, box->g_w, pixel);
	graf_mouse(M_ON, 0L);
}


/* blit down the window by number of pixel */

blitdn(wh, box, pixel)
int wh;
GRECT *box;
int pixel;

{
	int pxyarray[8];
	int x[2];

	x[0] = 0;
	x[1] = 0;

	graf_mouse(M_OFF, 0L);
	pxyarray[0] = box->g_x;
	pxyarray[1] = box->g_y+pixel;
	pxyarray[2] = box->g_x+box->g_w;
	pxyarray[3] = box->g_y+box->g_h;
	pxyarray[4] = box->g_x;
	pxyarray[5] = box->g_y;
	pxyarray[6] = box->g_x+box->g_w;
	pxyarray[7] = pxyarray[3]-pixel;
	vro_cpyfm(handle, 3, pxyarray, &x[0], &x[0]);
	ob_draw(wh, box->g_x, box->g_y+box->g_h-pixel, box->g_w, pixel);
	graf_mouse(M_ON, 0L);
}

/* set clip to specified rectangle */
setclip(p)	
GRECT *p;

{
	int ptr[4];

	ptr[0] = p->g_x;
	ptr[1] = p->g_y;
	ptr[2] = p->g_x + p->g_w - 1;
	ptr[3] = p->g_y + p->g_h - 1;
	vs_clip(handle, 1, ptr);
}

