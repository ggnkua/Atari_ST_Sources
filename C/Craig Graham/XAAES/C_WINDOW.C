/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <VDI.H>
#include <MINTBIND.H>
#include <memory.h>
#include "XA_TYPES.H"
#include "XA_DEFS.H"
#include "XA_GLOBL.H"
#include "STD_WIDG.H"
#include "BOX3D.H"
#include "C_WINDOW.H"
#include "RECTLIST.H"
#include "MESSAGES.H"
#include "OBJECTS.H"
#include "RESOURCE.H"
#include "SYSTEM.H"
#include "DESKTOP.H"

/*
	Low-level Window Stack Management Functions
*/

XA_WINDOW *window_list=NULL;		/* The global system window stack */
short wind_handle=0;				/* Window handle counter (used to generate unique window handles)
									   As this loops round, there may be a problem if a user opens
									   more than 32767 windows in one session :) */

/*
 	Create a window
*/
XA_WINDOW *create_window(short pid, long tp, short rx, short ry, short rw, short rh)
{
	XA_WINDOW *nw=(XA_WINDOW *)malloc(sizeof(XA_WINDOW));

	if (!nw)			/* Unable to allocate memory for window? */
		return NULL;

	nw->x=rx;
	nw->y=ry;
	nw->w=rw;
	nw->h=rh;
	nw->prev_x=rx;
	nw->prev_y=ry;
	nw->prev_w=rw;
	nw->prev_h=rh;
	nw->handle=wind_handle++;
	nw->owner=pid;
	nw->is_open=FALSE;
#if JOHAN_RECTANGLES
	nw->rl_full = NULL;
	nw->rl_work = NULL;
#else
	nw->rect_list=NULL;
#endif
	nw->redraw=NULL;
	nw->keypress=NULL;
	nw->window_status=XAWS_CLOSED;
	
	Psemaphore(2,WIN_LIST_SEMAPHORE,-1L);
	
	if (root_window)	/* Append window to back of window list, behind the root window (if it exists) */
	{
		nw->prev=root_window;
		nw->next=root_window->next;
		if (root_window->next)
			root_window->next->prev=nw;
		root_window->next=nw;
	}else{
		nw->next=NULL;
		nw->prev=NULL;
		window_list=nw;
	}
	
	Psemaphore(3,WIN_LIST_SEMAPHORE,0);
	
	standard_widgets(nw,tp);	/* Attatch the appropriate widgets to the window */

	if (tp&STORE_BACK)			/* If STORE_BACK extended attribute is used, window preserves it's own background */
	{
		nw->background=(void*)malloc(display.planes*((rw+35)>>2)*(rh+20));
		nw->bgx=-1;
	}else{
		nw->background=NULL;
	}
	
	calc_work_area(nw);			/* Calculate an initial work area */

	return nw;
}

/*
	Display a window
*/
void display_window(XA_WINDOW *wind)
{
	short f,pnt[8],x,y,w,h;
	WidgetCallback wc;

	if (wind->active_widgets&STORE_BACK)	/* Is this a 'preserve own background' window? */
	{
		MFDB Mscreen;
		MFDB Mpreserve;
		
		pnt[0]=wind->x; pnt[1]=wind->y; pnt[2]=wind->x+wind->w; pnt[3]=wind->y+wind->h;
		pnt[4]=0; pnt[5]=0; pnt[6]=wind->w; pnt[7]=wind->h;
		
		Mpreserve.fd_w=wind->w+20;
		Mpreserve.fd_h=wind->h+20;
		Mpreserve.fd_wdwidth=(Mpreserve.fd_w+15)>>4;
		Mpreserve.fd_nplanes=display.planes;
		Mpreserve.fd_stand=0;
		Mpreserve.fd_addr=wind->background;

		Mscreen.fd_addr=NULL;

		v_hide_c(V_handle);
		vro_cpyfm(V_handle, S_ONLY, pnt, &Mscreen, &Mpreserve);
		v_show_c(V_handle,1);
		
		wind->bgx=wind->x; wind->bgy=wind->y;
	}
	
	x=wind->wx;
	y=wind->wy;
	w=wind->ww;
	h=wind->wh;
	
/* Display the window backdrop (borders only, GEM style) */
	vsf_color(V_handle,display.dial_colours.bg_col);
	vsf_interior(V_handle,FIS_SOLID);
	pnt[0]=wind->x; pnt[1]=wind->y; pnt[2]=wind->x+wind->w-SHADOW_OFFSET; pnt[3]=y;
	v_bar(V_handle,pnt);
	pnt[1]=y+h; pnt[3]=wind->y+wind->h-SHADOW_OFFSET;
	v_bar(V_handle,pnt);
	pnt[0]=wind->x; pnt[1]=wind->y; pnt[2]=x;
	v_bar(V_handle,pnt);
	pnt[0]=x+w; pnt[2]=wind->x+wind->w-SHADOW_OFFSET;
	v_bar(V_handle,pnt);

/* Display drop shadow  */
	vsf_color(V_handle,display.dial_colours.border_col);
	pnt[0]=wind->x+wind->w-SHADOW_OFFSET+1; pnt[1]=wind->y+SHADOW_OFFSET; pnt[2]=wind->x+wind->w; pnt[3]=wind->y+wind->h;
	v_bar(V_handle,pnt);
	pnt[0]=wind->x+SHADOW_OFFSET; pnt[1]=wind->y+wind->h-SHADOW_OFFSET+1; pnt[2]=wind->x+wind->w-SHADOW_OFFSET; pnt[3]=wind->y+wind->h;
	v_bar(V_handle,pnt);

/* Display the work area */
	if (!(wind->active_widgets&NO_WORK))
	{
		vsl_color(V_handle,display.dial_colours.b_r_col);

		pnt[0]=x; pnt[1]=y+h;
		pnt[2]=x; pnt[3]=y;
		pnt[4]=x+w; pnt[5]=y;
		v_pline(V_handle,3,pnt);
	
		pnt[0]=x+2; pnt[1]=y+h-1;
		pnt[2]=x+w-1; pnt[3]=y+h-1;
		pnt[4]=x+w-1; pnt[5]=y+1;
		v_pline(V_handle,3,pnt);
	
		vsl_color(V_handle,display.dial_colours.t_l_col);

		pnt[0]=x+w; pnt[1]=y+1;
		pnt[2]=x+w; pnt[3]=y+h;
		pnt[4]=x+1; pnt[5]=y+h;
		v_pline(V_handle,3,pnt);
	
		pnt[0]=x+1; pnt[1]=y+h-1;
		pnt[2]=x+1; pnt[3]=y+1;
		pnt[4]=x+w-1; pnt[5]=y+1;
		v_pline(V_handle,3,pnt);
	}

/* Go through and display the window widgets using their display behaviour */
	if (wind->window_status==XAWS_ICONIFIED)
	{
		wc=wind->widgets[XAW_TITLE].behaviour[XACB_DISPLAY];
		(*wc)(wind, &(wind->widgets[XAW_TITLE]));
		wc=wind->widgets[XAW_ICONIFY].behaviour[XACB_DISPLAY];
		(*wc)(wind, &(wind->widgets[XAW_ICONIFY]));
	}else{
		for(f=0; f<XA_MAX_WIDGETS; f++)
		{
			wc=wind->widgets[f].behaviour[XACB_DISPLAY];
			if (wc)
				(*wc)(wind, &(wind->widgets[f]));
		}
	}

/* If the window has an auto-redraw function, call it */
	if (wind->redraw)
	{
		(*(wind->redraw))(wind);
	}

}

XA_WINDOW *wind_find(short x, short y)
{
	XA_WINDOW *w=window_list;

	Psemaphore(2,WIN_LIST_SEMAPHORE,-1L);
	
	while(w)
	{
		if ((w->is_open)&&((((x>=w->x)&&(y>=w->y))&&(x<w->x+w->w))&&(y<w->y+w->h)))
		{
			Psemaphore(3,WIN_LIST_SEMAPHORE,0L);
			return w;
		}
		w=w->next;
	}
	
	Psemaphore(3,WIN_LIST_SEMAPHORE,0L);
	
	return NULL;
}
	

XA_WINDOW *get_wind_by_handle(short h)
{
	XA_WINDOW *w;

	Psemaphore(2,WIN_LIST_SEMAPHORE,-1L);
	
	w=window_list;
	
	while(w)
	{
		if (w->handle==h)
		{
			Psemaphore(3,WIN_LIST_SEMAPHORE,0L);
			return w;
		}
		w=w->next;
	}
	
	Psemaphore(3,WIN_LIST_SEMAPHORE,0L);
	
	return NULL;
}

/*
	Pull this window to the head of the window list
*/
void pull_wind_to_top(XA_WINDOW *w)
{
	XA_CLIENT *owner;

	Psemaphore(2,WIN_LIST_SEMAPHORE,-1L);

	if (window_list->owner!=w->owner)	/* If we're getting a new top window, we may need */
	{									/* to swap menu bars..... */
		XA_WIDGET_TREE *menu_bar;

		Psemaphore(2,ROOT_SEMAPHORE,-1L);

		menu_bar=(XA_WIDGET_TREE*)(root_window->widgets[XAW_MENU].stuff);

		owner=Pid2Client(w->owner);
		menu_bar->tree=owner->std_menu;
		menu_bar->owner=w->owner;

		if ((owner->desktop)					/* Change desktops? */
			&&((owner->desktop!=desktop)&&(owner->desktop!=ResourceTree(system_resources,DEF_DESKTOP))))
		{
			set_desktop(owner->desktop);
			root_window->owner=w->owner;;

			v_hide_c(V_handle);
			display_non_topped_window(root_window,NULL);
			v_show_c(V_handle,1);
		}else{											/* No - just change menu bars */
			GRECT clip;

			rp_2_ap(root_window, root_window->widgets+XAW_MENU, &clip.g_x, &clip.g_y);

			clip.g_w=root_window->widgets[XAW_MENU].w;
			clip.g_h=root_window->widgets[XAW_MENU].h;

			v_hide_c(V_handle);
			display_non_topped_window(root_window,&clip);
			v_show_c(V_handle,1);
		}

		Psemaphore(3,ROOT_SEMAPHORE,0L);
	}

	if (w->prev)
	{
		w->prev->next=w->next;
	}else{
		window_list=w->next;
	}
	if (w->next)
		w->next->prev=w->prev;
	w->next=window_list;
	if (window_list) window_list->prev=w;
	w->prev=NULL;
	window_list=w;

	Psemaphore(3,WIN_LIST_SEMAPHORE,0L);

}

void send_wind_to_bottom(XA_WINDOW *w)
{
	XA_WINDOW *old_top=window_list;
	
	if (w->next==NULL) return;			/* Can't send to the bottom a window that's already there */
	
	Psemaphore(2,WIN_LIST_SEMAPHORE,-1L);
	
	if (w==window_list)					/* If this window was on top, change window list */
		window_list=w->next;
	
	if (w->next)						/* Remove window from window list */
		w->next->prev=w->prev;
	
	if (w->prev)
		w->prev->next=w->next;
		
	w->prev=root_window->prev;
	w->next=root_window;
	
	if (w->prev)						/* root window is always at the bottom */
	{
		w->prev->next=w;
	}else{
		window_list=w;					/* window is still on top (must be the only window */
	}

	root_window->prev=w;
	
	Psemaphore(3,WIN_LIST_SEMAPHORE,0L);

	if (window_list==old_top)			/* If no change in top window, we can return here */
	{
		return;
	}
	

	if (old_top->owner!=window_list->owner)	/* If we're getting a new top window, we may need */
	{										/* to swap menu bars..... */
		XA_WIDGET_TREE *menu_bar=(XA_WIDGET_TREE*)(root_window->widgets[XAW_MENU].stuff);
		XA_CLIENT *owner;
	
		Psemaphore(2,ROOT_SEMAPHORE,-1L);
			
		owner=Pid2Client(window_list->owner);
		menu_bar->tree=owner->std_menu;
		menu_bar->owner=window_list->owner;

		if (owner->desktop					/* Change desktops? */
			&&((owner->desktop!=desktop)&&(owner->desktop!=ResourceTree(system_resources,DEF_DESKTOP))))
		{
			set_desktop(owner->desktop);
			root_window->owner=window_list->owner;

			v_hide_c(V_handle);
			display_non_topped_window(root_window,NULL);
			v_show_c(V_handle,1);
		}else{											/* No - just change menu bars */
			GRECT clip;

			rp_2_ap(root_window, root_window->widgets+XAW_MENU, &clip.g_x, &clip.g_y);
		
			clip.g_w=root_window->widgets[XAW_MENU].w;
			clip.g_h=root_window->widgets[XAW_MENU].h;

			v_hide_c(V_handle);
			display_non_topped_window(root_window,&clip);
			v_show_c(V_handle,1);
		}

		Psemaphore(3,ROOT_SEMAPHORE,0L);
	}
}

void delete_window(XA_WINDOW *wind)
{
	if (!wind) return;

	Psemaphore(2,WIN_LIST_SEMAPHORE,-1L);
	
	if (wind==window_list)
		window_list=wind->next;

	if (wind->prev) wind->prev->next=wind->next;
	if (wind->next) wind->next->prev=wind->prev;

	if (wind->background)
		free(wind->background);
	
	Psemaphore(3,WIN_LIST_SEMAPHORE,0L);

	free(wind);
}

/*
	Display a window that isn't on top, respecting clipping
	- pass clip==NULL to redraw whole window, otherwise clip is a pointer to a GRECT that
	defines the clip rectangle.
*/
void display_non_topped_window(XA_WINDOW *w,GRECT *clip)
{
	GRECT target;
#if JOHAN_RECTANGLES
	XA_RECT_LIST *rl, *drl;
#else
	XA_RECT_LIST *drl;
	XA_RECT_LIST *rl=generate_rect_list(w);
#endif

#if JOHAN_RECTANGLES
	if (!(rl = w->rl_full))
		rl = w->rl_full = generate_rect_list(w);
#endif


	if (w->is_open)
	{
		while(rl)
		{
			drl=rl;
			
			if (clip)
			{
				target.g_x=rl->x;
				target.g_y=rl->y;
				target.g_w=rl->w;
				target.g_h=rl->h;
				
				if (rc_intersect(clip,&target))
				{
					set_clip(target.g_x, target.g_y, target.g_w, target.g_h);
					display_window(w);
				}
			}else{
				set_clip(rl->x, rl->y, rl->w, rl->h);
				display_window(w);
			}
			rl=rl->next;
#if JOHAN_RECTANGLES
#else
			free(drl);
#endif
		}
	}
	clear_clip();
}

/*
	Display all windows BELOW the current location of a window.
	- this has the effect of erasing the window.
*/
void display_windows_below(XA_WINDOW *w)
{
	GRECT old_r,win_r;
	XA_WINDOW *wl;
	XA_RECT_LIST *drl;
	XA_RECT_LIST *rl;
	short keep_is_open;

	keep_is_open=w->is_open;
	w->is_open=FALSE;					/* Flag this window as closed to allow rectangle list to
										   overwrite it */

	if (w->active_widgets&STORE_BACK)	/* Is this a 'preserve own background' window? */
	{
		MFDB Mscreen;
		MFDB Mpreserve;
		short pnt[8];
	
		if (window_list==w)
			clear_clip();
	
		pnt[0]=0; pnt[1]=0; pnt[2]=w->w; pnt[3]=w->h;
		pnt[4]=w->bgx; pnt[5]=w->bgy; pnt[6]=w->bgx+w->w; pnt[7]=w->bgy+w->h;
	
		Mpreserve.fd_w=w->w+20;
		Mpreserve.fd_h=w->h+20;
		Mpreserve.fd_wdwidth=(Mpreserve.fd_w+15)>>4;
		Mpreserve.fd_nplanes=display.planes;
		Mpreserve.fd_stand=0;
		Mpreserve.fd_addr=w->background;
		Mscreen.fd_addr=NULL;
	
		v_hide_c(V_handle);
		vro_cpyfm(V_handle, S_ONLY, pnt, &Mpreserve, &Mscreen);
		v_show_c(V_handle,1);
	}else{
		
		if (w->next)	/* We only need to do this bit if there are any windows lower than window */
		{	
			old_r.g_x=w->x;
			old_r.g_y=w->y;
			old_r.g_w=w->w;
			old_r.g_h=w->h;
	
			for(wl=root_window; wl!=w; wl=wl->prev)			/* Check for redraws of windows starting at the root*/
			{												/* and working up to our window, and redraw using */
															/* intersections with the rectangle of our window. */
				if (wl->is_open)
				{
#if JOHAN_RECTANGLES
					if (!(rl = wl->rl_full))
						rl = wl->rl_full = generate_rect_list(wl);
#else
					rl=generate_rect_list(wl);
#endif
					while(rl)
					{
					
						win_r.g_x=rl->x;
						win_r.g_y=rl->y;
						win_r.g_w=rl->w;
						win_r.g_h=rl->h;
					
						if (rc_intersect(&old_r, &win_r))
						{
							set_clip(win_r.g_x, win_r.g_y, win_r.g_w, win_r.g_h);

							display_window(wl);				/* Display the window */
							
											/* send a redraw message to the owner of the window for this rectangle */
							if (!(wl->active_widgets&NO_REDRAWS))
								send_app_message(wl->owner, WM_REDRAW, 0, wl->handle, win_r.g_x, win_r.g_y, win_r.g_w, win_r.g_h);
						}
						
						drl=rl;
						rl=rl->next;
#if JOHAN_RECTANGLES
#else
						free(drl);
#endif
					}
				}
			
			}
		
		}
	}
	
	clear_clip();

	w->is_open=keep_is_open;

}
