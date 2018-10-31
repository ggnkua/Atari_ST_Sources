/*
 *  BLIT.C
 * May 1, 2000
 * Routines for manipulation of blitting in any screen depth
 * 
 * Dan Ackerman baldrick@columbus.rr.com
 * http://www.gemcandy.org/
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "global.h"

/* vro_notcpy()
 *
 * does a test on number of screen planes
 * if > 8 does NOTS_AND_D
 * else S_OR_D.  Just a common test for truecolor resolutions
 */
void
vro_notcpy(int *pxy, MFDB *source, MFDB *dest)
{
	if (planes > 8)
		vro_cpyfm(vdi_handle,S_AND_D,pxy,source,dest);
	else
		vro_cpyfm(vdi_handle,S_OR_D,pxy,source,dest);
}

/* clear_back()
 *
 * clears an area of our backing store.
 * basically copies an area of our background
 * image over the same area in the backing store
 * removes sprites etc
 */
 
void
clear_back(int *pxy)
{
	int array[8];
	int array2[8];

	if (pxy[5] < 0)
		pxy[5] = 0;
	
	array[0] = array[4] = pxy[4];
	array[1] = array[5] = pxy[5];
	array[2] = array[6] = pxy[6];

	if (pxy[7] > back_pic.fd_h)
		array[3] = array[7] = back_pic.fd_h-1;
	else
		array[3] = array[7] = pxy[7];

    /* clear out back */
	vro_cpyfm(vdi_handle,S_ONLY,array,&picsource,&back_pic);
	
    array2[0] = array[4];
    array2[1] = array[5];
    array2[2] = array[6];
    array2[3] = array[7];

    array2[4] = array[4] + win[GAME_WIN].window_obj[ROOT].ob_x;
    array2[5] = array[5] + win[GAME_WIN].window_obj[ROOT].ob_y;
    array2[6] = array[6] + win[GAME_WIN].window_obj[ROOT].ob_x;
    array2[7] = array[7] + win[GAME_WIN].window_obj[ROOT].ob_y;

	add_rect(array2[4],array2[5],array2[6],array2[7]);
}

/* cpy_2_back()
 *
 * copies a MFDB to our backing store
 * handles masking out the area first
 */
 
void
cpy_2_back(int *pxy, MFDB *source, MFDB *mask)
{
	int array[4];

	/* blit our mask into place */
	vrt_cpyfm(vdi_handle, MD_TRANS, pxy, mask, &back_pic, colors);	
		
	/* copy our object into the hole */
	vro_notcpy(pxy, source, &back_pic);

	array[0] = pxy[4];
	array[1] = pxy[5];
	array[2] = pxy[6];
	array[3] = pxy[7];


	if (win[GAME_WIN].handle != NO_WINDOW)
	{
		add_rect(array[0] + win[GAME_WIN].window_obj[ROOT].ob_x,
		array[1] + win[GAME_WIN].window_obj[ROOT].ob_y,
		array[2] + win[GAME_WIN].window_obj[ROOT].ob_x,
		array[3] + win[GAME_WIN].window_obj[ROOT].ob_y);
	}
}

/* cpy_2_dest()
 *
 * copies one MFDB into another
 * handles masking
 * but not redraws
 */
 
void
cpy_2_dest(int *pxy, MFDB *dest, MFDB *source, MFDB *mask)
{
	/* blit our mask into place */
	vrt_cpyfm(vdi_handle, MD_TRANS, pxy, mask, dest, colors);	
	
	/* copy our object into the hole */
	vro_notcpy(pxy, source, dest);
}

/* add_rect()
 * 
 * adds an area to our redraw list
 */
 
void
add_rect(int x,int y,int w,int h)
{
	register GRECT *p;

	/* this should never 'rarely' happen... */
	if (n_rects >= MAX_RECTS)
		return;

	p = &rect[n_rects];

	p->g_x = x;
	p->g_y = y;
	p->g_w = w;
	p->g_h = h;
	n_rects++;
}

/* rect_intersect()
 *
 * This is basically rc_interesect modified to handle
 * the window offsets to match against off screen buffer
 */
 
int
rect_intersect( GRECT *r1, GRECT *r2, int winx, int winy )
{
   int x, y, w, h;

   x = max( r2->g_x, r1->g_x);
   y = max( r2->g_y, r1->g_y);
   w = min( (r2->g_x + r2->g_w), r1->g_w );
   h = min( (r2->g_x + r2->g_h), r1->g_h );

   r2->g_x = x;
   r2->g_y = y;
   r2->g_w = w - x;
   r2->g_h = h - y;

   return ( ((w > x) && (h > y) ) );
}

int hidden;

/* update_rects()
 *
 * find and redraw all clipping rectangles	
 */
 
void
update_rects(void)
{
	register GRECT *p;
	GRECT t;
	register int i;
	int array[8];

	wind_update(TRUE);

	/* clip all regions to screen size */
	for (i=0; i<n_rects; i++)
	{
		p = &rect[i];

		if (p->g_x < 0) 
			p->g_x = 0;

		if (p->g_w > desk.g_w)
			p->g_w = desk.g_w;
			
		if (p->g_h > desk.g_h)
			p->g_h = desk.g_h;
	}

	wind_get(win[GAME_WIN].handle,WF_FIRSTXYWH,ELTR(t));

	while (t.g_w && t.g_h)
	{
		for (i=0; i<n_rects; i++)
		{
			p = &trect[i];
			*p = t;				/* copy this window rect */

			if (rect_intersect(&rect[i],p,win[GAME_WIN].window_obj[ROOT].ob_x,win[GAME_WIN].window_obj[ROOT].ob_y))
			/* tregion[i] clipped to my redraw region */
			{
				array[0] = p->g_x - win[GAME_WIN].window_obj[ROOT].ob_x;
				array[1] = p->g_y - win[GAME_WIN].window_obj[ROOT].ob_y;
				array[2] = array[0] + p->g_w - 1;
				array[3] = array[1] + p->g_h - 1;
	
				array[4] = p->g_x;
				array[5] = p->g_y;
				array[6] = p->g_x + p->g_w - 1;
				array[7] = p->g_y + p->g_h - 1;

				vro_cpyfm(vdi_handle,S_ONLY,array,&back_pic,&screen);
			}
		}
		wind_get(win[GAME_WIN].handle,WF_NEXTXYWH,ELTR(t));
	}

	wind_update(FALSE);
	
/*	printf("a0 %d a1%d\r\n",array[0],array[1]);*/
	n_rects = 0;
}

/* Special effects */

#define DISP_FX_FIELD_MELT_STEPSIZE	4	/* Size of each step in disp.c's fx. melt */

/* disp_fx_field_melt()
 *
 * Make the playing field "melt" and drop down slowly, 
 * with the centre going fastest, followed by the edges. 
 * - modified from mario becroft code 
 */

void 
disp_fx_field_melt( int target_win )
{
	int y,x1,x2;
	int pxy[8],pxy2[4];
	int top_window;
	
	top_window = get_topwindow(target_win);
	 
	/* Only do-able on top window, without extra effort */

	if (top_window == win[GAME_WIN].handle) /* don't do anything unless top window */
	{
		vsl_color( vdi_handle , BLACK );
		vsf_color( vdi_handle , BLACK );
		pxy[1]=win[GAME_WIN].current.g_y;	/* always grab from the top down */
		pxy[3]=win[GAME_WIN].current.g_y+win[GAME_WIN].current.g_h-1-DISP_FX_FIELD_MELT_STEPSIZE;
		pxy[5]=win[GAME_WIN].current.g_y+DISP_FX_FIELD_MELT_STEPSIZE;
		pxy[7]=win[GAME_WIN].current.g_y+win[GAME_WIN].current.g_h-1;
		pxy2[1]=win[GAME_WIN].current.g_y;
		pxy2[3]=win[GAME_WIN].current.g_y+DISP_FX_FIELD_MELT_STEPSIZE;
		wind_update(BEG_UPDATE);
		graf_mouse( M_OFF , NULL );
		for (y=0;y<win[GAME_WIN].current.g_h;y++)
		{
			x1 = random(win[GAME_WIN].current.g_w);
			x2 = random(win[GAME_WIN].current.g_w);

			/* Blit it down a bit */
			pxy2[0]=pxy[0]=pxy[4]=win[GAME_WIN].current.g_x+x1;	/* x doesn't move */
			pxy2[2]=pxy[2]=pxy[6]=win[GAME_WIN].current.g_x+x2;	/* x doesn't move */
			vro_cpyfm( vdi_handle, S_ONLY, pxy, &screen, &screen );
			/* Put black over top */
			#if (DISP_FX_FIELD_MELT_STEPSIZE==1)
				v_pline( vdi_handle , 2 , pxy2 );
			#else
				v_bar( vdi_handle , pxy2 );
			#endif
		}
		graf_mouse( M_ON , NULL );
		wind_update(END_UPDATE);
	}
}
