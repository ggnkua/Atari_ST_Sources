/*
 * Window.C
 *  v. 1.1
 */

#include <stdio.h>

#include "boink.h"

#ifndef ED_INIT
#define ED_INIT 1
#endif
 
GRECT clip;
GRECT full;

/* Close all windows
 *
 * Rewritten so it doesn't look so bad 
 */
 
int
close_all_windows(void)
{
	int i;
	
	for(i=0;i<MAX_WINDOWS;i++)
	{
		if (win[i].handle != NO_WINDOW)
		{
			wind_close(win[i].handle);
			wind_delete(win[i].handle);
			win[i].handle = NO_WINDOW;
		}
	}

	return(1);
}

int
get_wininfo_from_handle(int w_hand)
{
	int i;
	
	for(i = 0; i < MAX_WINDOWS; i++)
	{
		if (win[i].handle == w_hand)
			return (i);
	}

	return(-1); /* Didn't find the handle in our structures */
}

int	
new_window(OBJECT *tree, const char *title, int type)
{
	GRECT p;
	int wh;

	/* compute required size for window given object tree */

	form_center(tree,ELTR(clip));

	if (type == 0)
	{
		wind_calc(WC_BORDER, W_TYPE, PTRS((GRECT *)&clip),ELTR(p));
	
		wh = wind_create(W_TYPE, ELTS(p));
	}
	else if (type == 1)
	{
		wind_calc(WC_BORDER, W_T2, PTRS((GRECT *)&clip),ELTR(p));
	
		wh = wind_create(W_T2, ELTS(p));
	}
	else
	{
		wind_calc(WC_BORDER, W_T3, PTRS((GRECT *)&clip),ELTR(p));
	
		wh = wind_create(W_T3, ELTS(p));
	}
				
	if (wh >= 0) 
	{
#if OS_DOS
		wind_set(wh, WF_NAME, LLOWD(title), LHIWD(title),0,0);
#else
		wind_set(wh, WF_NAME, title);
#endif
		wind_open(wh, ELTS(p));
		
	}
	return wh;
}

int
redraw(int wh, GRECT *area) 
{
	/* wh = window handle from msg[3] */
	/* area = pointer to redraw rect- */
    /*   tangle in msg[4] thru msg[7] */

	GRECT	box;

    HIDE_MOUSE;

    wind_update(BEG_UPDATE);

	wind_get(wh, WF_FIRSTXYWH, ELTR(box));

	while ( box.g_w && box.g_h )
	{
		if (rc_intersect(&full, &box))       /* Full is entire screen */
		{
			if (rc_intersect(area, &box))
			{
				switch(win[wh].status)
				{
					case 1:
						/* normal */
						objc_draw(win[wh].window_obj, ROOT, MAX_DEPTH, ELTS(box));
						break;
										
					case 2:
						/* rolled up */
						objc_draw(win[wh].window_obj, ROOT, MAX_DEPTH, ELTS(box));
						break;
										
					case 3:
						/* iconified */
						objc_draw(win[wh].icon_obj, ROOT, MAX_DEPTH, ELTS(box));
						break;
				}
           	}
		}

        wind_get(wh, WF_NEXTXYWH, ELTR(box));
	}

	wind_update(END_UPDATE);

	SHOW_MOUSE;
	
	return(1);
}


int
do_wind_redraw(int wh, GRECT *p)
{
	GRECT new;
	GRECT rect;
 	int cliparray[4];	/* MAR -- [] war leer */
	int pxy[8];
	int x,y;
	GRECT temp;
	int w_info;

	/* Suspend menu */

	wind_update(BEG_UPDATE);

	/* turn off mouse */

	HIDE_MOUSE;

	/* Reset the window objects area */

	wind_get(wh,WF_WORKXYWH,ELTR(new));
	
	w_info = get_wininfo_from_handle(wh);
	
	/* If the window doesn't have an object don't try to
	 * manipulate a NULL
	 */
	 
	if (win[w_info].window_obj != (OBJECT *)NULL)
	{
		/* Don't reset if either width or height == 0 */
	
		if (new.g_w && new.g_h)
		{
			win[w_info].window_obj[ROOT].ob_x = new.g_x;
			win[w_info].window_obj[ROOT].ob_y = new.g_y;
			win[w_info].window_obj[ROOT].ob_width = new.g_w;
			win[w_info].window_obj[ROOT].ob_height = new.g_h;
		}
	}

	/* Get the first rectangle off the windows list */

	wind_get(wh, WF_FIRSTXYWH, ELTR(rect));

	while (rect.g_w && rect.g_h) 
	{
		if( rc_intersect(p, &rect) )
		{
			/*cliparray[0]=rect.g_x; 
			cliparray[1]=rect.g_y;
			cliparray[2]=rect.g_x + rect.g_w - 1;
			cliparray[3]=rect.g_y + rect.g_h - 1;

			vs_clip(vdi_handle, 1, cliparray);*/

			Vsync();

			switch (win[w_info].status)
			{
				case 1:
					objc_draw(win[w_info].window_obj,ROOT,MAX_DEPTH, ELTS(rect));

					if (w_info == OBJCOLOR_WIN)
					{
						cliparray[0]=rect.g_x; 
						cliparray[1]=rect.g_y;
						cliparray[2]=rect.g_x + rect.g_w - 1;
						cliparray[3]=rect.g_y + rect.g_h - 1;
		
						vs_clip(vdi_handle, 1, cliparray);

						redraw_objcolors();					

						vs_clip(vdi_handle, 0, cliparray);
					}
					else if (w_info == ABOUT_WIN)
					{
						objc_offset(about_dial,RTITLE,&x,&y);
						
						temp.g_x = x;
						temp.g_y = y;
						temp.g_w = tit_buf.fd_w;
						temp.g_h = tit_buf.fd_h;
			
						/* The following test is here for MagicPC
						 * if you draw the bottom of the screen with magicPC
						 * it crashes
						 */
						if ((temp.g_y+temp.g_h) > max.g_y)
							temp.g_h =max.g_y-temp.g_y;

						if ((temp.g_x+temp.g_w) > max.g_x)
							temp.g_w = max.g_x - temp.g_x;

						if (rc_intersect(&rect,&temp))
						{
							/* clip it to screen */
							/* Whole lot of manipulations going on here,
								might not all be necessary.  However it's 
								finally working so I'm going to be bad
								and not touch it anymore right now */

							pxy[0] = temp.g_x - x;
							pxy[1] = temp.g_y - y;
							pxy[2] = pxy[0] + temp.g_w - 1;
							pxy[3] = pxy[1] + temp.g_h - 1;
							pxy[4] = temp.g_x;
							pxy[5] = temp.g_y;
							pxy[6] = pxy[4] + temp.g_w - 1;
							pxy[7] = pxy[5] + temp.g_h - 1;

							/* Keep messy AES's from drawing off the left side of the screen */
							if (pxy[4] < 0)
								pxy[4] = 0;
								
							vro_cpyfm(vdi_handle,S_ONLY,pxy,&tit_buf,&screen_fdb);
						}
					}
					break;
							
				case 3:
					objc_draw(win[w_info].icon_obj, ROOT, MAX_DEPTH, ELTS(rect));
					break;
			}
						
			if((win[w_info].cur_item != -1)&&(win[w_info].edit == 1))
			{
				objc_edit(win[w_info].window_obj,win[w_info].cur_item,0,win[w_info].edit_pos,ED_INIT,&win[w_info].edit_pos);
				win[w_info].edit = 0;
			}

/*			vs_clip(vdi_handle, 0, cliparray);*/
		}

		wind_get(wh, WF_NEXTXYWH, ELTR(rect));
	}

	/* show mouse */

	SHOW_MOUSE;

	wind_update(END_UPDATE);

	return 1;
}

int
custom_redraw(int wh, GRECT *p)
{
	int current_obj = 0;
	GRECT new;
	
	/* Suspend menu */

	/*wind_update(BEG_UPDATE);*/

	/* turn off mouse */

	HIDE_MOUSE;

	/* Reset the window objects area */

	wind_get(wh,WF_WORKXYWH,ELTR(new));

	win[wh].window_obj[ROOT].ob_x = new.g_x;
	win[wh].window_obj[ROOT].ob_y = new.g_y;

	if (rc_intersect(p, &new))
	{
		current_obj = objc_find(win[wh].window_obj,ROOT,MAX_DEPTH,new.g_x,new.g_y);

		objc_draw(win[wh].window_obj,current_obj,MAX_DEPTH, ELTS(new));
	}

	/* show mouse */

	SHOW_MOUSE;

	/*wind_update(END_UPDATE);*/

	return 1;
}

/* A routine for getting the top window simply for tests */
int
get_topwindow(int window)
{
	int top_window;
	int junk;
	
	wind_get(window,WF_TOP,&top_window,&junk,&junk,&junk);
	
	return(top_window);
}
