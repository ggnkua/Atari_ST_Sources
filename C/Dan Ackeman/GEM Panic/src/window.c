/*
 * Window.C
 *  v. 1.1
 */

#include <stdio.h>
#include "global.h"


/* a couple of GRECTs that are only used in this file
 */
GRECT clip;
GRECT full;


/* get_topwindow()
 *
 * A routine for getting the top window simply for tests 
 */

int
get_topwindow(int window)
{
	int top_window;
	int junk;
	
	wind_get(window,WF_TOP,&top_window,&junk,&junk,&junk);
	
	return(top_window);
}

/* close_all_windows()
 *
 * Walks the list of program windows and closes them
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

/* -------------------------------------------------------------------- */
/*       boolean rc_intersect( GRECT *r1, GRECT *r2 );                  */
/*                                                                      */
/*       Berechnung der Schnittfl„che zweier Rechtecke.                 */
/*                                                                      */
/*       -> r1, r2               Pointer auf Rechteckstruktur.          */
/*                                                                      */
/*       <-                      == 0  falls sich die Rechtecke nicht   */
/*                                     schneiden,                       */
/*                               != 0  sonst.                           */
/* -------------------------------------------------------------------- */


#ifndef _GEMLIB_H_
int rc_intersect( GRECT *r1, GRECT *r2 )
{
   int x, y, w, h;

   x = max( r2->g_x, r1->g_x );
   y = max( r2->g_y, r1->g_y );
   w = min( r2->g_x + r2->g_w, r1->g_x + r1->g_w );
   h = min( r2->g_y + r2->g_h, r1->g_y + r1->g_h );

   r2->g_x = x;
   r2->g_y = y;
   r2->g_w = w - x;
   r2->g_h = h - y;

   return ( ((w > x) && (h > y) ) );
}
#endif

/* handle_win()
 *
 * This brings a window to the top 
 * if the window is not open it is opened
 * if it is iconified it is uniconified
 *
 * Basically this handles the lifting
 * so that other parts of the code don't
 * need to worry if the window was already open etc
 */
 
void
handle_win(int wind, void *handler)
{
   void (*whandler)(void) = handler;

	if (win[wind].handle == NO_WINDOW)
	{
		whandler();
		return;
	}

	if (win[wind].status == 3) /* iconified */
	{
		un_iconify(wind,(GRECT *)&win[wind].current);
		wind_set(win[wind].handle, WF_TOP, win[wind].handle,0,0,0);
	}
	else if (win[wind].status == 1) /* normal */
	{
		wind_set(win[wind].handle, WF_TOP, win[wind].handle,0,0,0);
	}
	else
		whandler();

	return;
}

/* get_wininfo_from_handle()
 *
 * gets the system window handle from
 * our internal window list
 */
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

/* new_window()
 * 
 * handles window creation for a window that fits a specified
 * dialog box
 */
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
		#ifdef _GEMLIB_H_
			wind_set_str(wh, WF_NAME, title);
		#else
			wind_set(wh, WF_NAME, title);
		#endif

		wind_open(wh, ELTS(p));
	}
	return wh;
}

/* redraw()
 *
 * a simplified window redraw routine
 * only handles dialog windows
 */
 
int
redraw(int wh, GRECT *area) 
{
	/* wh = window handle from msg[3] */
	/* area = pointer to redraw rect- */
    /*   tangle in msg[4] thru msg[7] */

	GRECT	box;

    HIDE_MOUSE;

    wind_update(BEG_UPDATE);

	wind_get(wh, WF_FIRSTXYWH, &box.g_x, &box.g_y, &box.g_w, &box.g_h);

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
						objc_draw(win[wh].window_obj, ROOT, MAX_DEPTH, box.g_x, box.g_y, box.g_w, box.g_h);
						break;
										
					case 2:
						/* rolled up */
						objc_draw(win[wh].window_obj, ROOT, MAX_DEPTH, box.g_x, box.g_y, box.g_w, box.g_h);
						break;
										
					case 3:
						/* iconified */
						objc_draw(win[wh].icon_obj, ROOT, MAX_DEPTH, box.g_x, box.g_y, box.g_w, box.g_h);
						break;
				}
           	}
       }
       wind_get(wh, WF_NEXTXYWH, &box.g_x, &box.g_y, &box.g_w,
             &box.g_h);
    }

	wind_update(END_UPDATE);

	SHOW_MOUSE;
	
	return(1);
}

/* do_wind_redraw()
 *
 * a more complex window redrawing routine
 * handles dialogs and graphics contained
 * in dialogs.  If you've wondered how I put
 * those XIMG files into the About dialog
 * this is the routine that makes it possible
 */
int
do_wind_redraw(int wh, GRECT *p)
{
	GRECT new;
	GRECT rect;
	int cliparray[] = {1,1,1,1};
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
	
	/* Get the first rectangle of the windows list */

	wind_get(wh, WF_FIRSTXYWH, ELTR(rect));

	while (rect.g_w && rect.g_h) 
	{
		if( rc_intersect(p, &rect) )
		{
			cliparray[0]=rect.g_x; 
			cliparray[1]=rect.g_y;
			cliparray[2]=cliparray[0]+rect.g_w-1;
			cliparray[3]=cliparray[1]+rect.g_h-1;
			
			vs_clip(vdi_handle, 1, cliparray);

			Vsync();
			
			switch (win[w_info].status)
			{
				case 1:
					objc_draw(win[w_info].window_obj,ROOT,MAX_DEPTH, ELTS(rect));

					if ((w_info == ABOUT_WIN)||(w_info == LOADING_WIN)
						||(w_info == GAME_WIN))
					{
						if (w_info == ABOUT_WIN)
							objc_offset(about_dial,RTITLE,&x,&y);
						else if (w_info == LOADING_WIN)
							objc_offset(loading_dial,LTITLE,&x,&y);					
						else if (w_info == GAME_WIN)
							objc_offset(game_dial,0,&x,&y);
						
						temp.g_x = x;
						temp.g_y = y;
						temp.g_w = win[w_info].image.fd_w;
						temp.g_h = win[w_info].image.fd_h;

						if (temp.g_x < 0) 
							temp.g_x = 0;

						if ((temp.g_x+temp.g_w) > desk.g_w)
							temp.g_w = desk.g_w - temp.g_x;
						if ((temp.g_y+temp.g_h) > maxy)
							temp.g_h =maxy-temp.g_y;

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

							vro_cpyfm(vdi_handle,S_ONLY,pxy,&win[w_info].image,&screen);
						}
					}

					break;
					
				case 3:
					objc_draw(win[w_info].icon_obj, ROOT, MAX_DEPTH, ELTS(rect));
					break;
			}
						
			if((win[w_info].cur_item != -1)&&(win[w_info].edit == 1))
			{
				objc_edit(win[w_info].window_obj,win[w_info].cur_item,0,&win[w_info].edit_pos,ED_INIT);
				win[w_info].edit = 0;
			}

			vs_clip(vdi_handle, 0, cliparray);
		}

		wind_get(wh, WF_NEXTXYWH, ELTR(rect));
	}

	/* show mouse */

	SHOW_MOUSE;

	wind_update(END_UPDATE);

	return 1;
}

/* custom_redraw()
 *
 * can be used for forcing a redraw of a small area
 * of the window
 */

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

	wind_get(wh,WF_WORKXYWH,&new.g_x,&new.g_y,&new.g_w,&new.g_h);

	win[wh].window_obj[ROOT].ob_x = new.g_x;
	win[wh].window_obj[ROOT].ob_y = new.g_y;

	if (rc_intersect(p, &new))
	{
		current_obj = objc_find(win[wh].window_obj,ROOT,MAX_DEPTH,new.g_x,new.g_y);

		objc_draw(win[wh].window_obj,current_obj,MAX_DEPTH, new.g_x, new.g_y, new.g_w, new.g_h);
	}

	/* show mouse */
	SHOW_MOUSE;

	/*wind_update(END_UPDATE);*/

	return 1;
}


