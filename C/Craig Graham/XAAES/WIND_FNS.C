/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <VDI.H>
#include <MINTBIND.H>
#include <OSBIND.H>
#include <memory.h>
#include "XA_DEFS.H"
#include "XA_TYPES.H"
#include "XA_GLOBL.H"
#include "K_DEFS.H"
#include "C_WINDOW.H"
#include "EVENTS.H"
#include "RECTLIST.H"
#include "SCRLWIDG.H"
#include "INFOWIDG.H"
#include "TITLWIDG.H"
#include "STD_WIDG.H"
#include "graf_mou.h"
#include "messages.h"
#include "desktop.h"
#include "RESOURCE.H"
#include "SYSTEM.H"
#include "OBJECTS.H"

/*
	AES window handling functions
	I've tried to support some of the AES4 extensions here as well as the plain
	single tasking GEM ones.
*/
unsigned long XA_wind_create(short clnt_pid, AESPB *pb)
{
	XA_WINDOW *new_window;
	long tp=0;
	
	tp=pb->intin[0];
	
	new_window=create_window(clnt_pid, tp, pb->intin[1], pb->intin[2], pb->intin[3], pb->intin[4]);

	if (new_window)
		pb->intout[0]=new_window->handle;	/* Return the window handle in intout[0] */
	else
		pb->intout[0]=-1;					/* Fail to create window, return -ve number */

	return XAC_DONE;	/* Allow the kernal to wake up the client - we've done our bit */
}

unsigned long XA_wind_open(short clnt_pid,AESPB *pb)
{
	XA_WINDOW *w,*wl;

	w=get_wind_by_handle(pb->intin[0]);	/* Get the window */

	if (w==NULL)
	{
		DIAGS(("WARNING:wind_open:Invalid window handle\n"));
		pb->intout[0]=0;			/* Invalid window handle, return error */
		return XAC_DONE;
	}
	
	pb->intout[0]=1;				/* return ok in intout[0] */
	
	if (w->is_open==TRUE)			/* the window is already open, no need to do anything */
	{
		DIAGS(("WARNING: Attempt to open window when it was already open\n"));
		return XAC_DONE;
	}

	/* New top window - change the cursor to this clients choice */
	graf_mouse(clients[clnt_pid].client_mouse, clients[clnt_pid].client_mouse_form);
	
	pull_wind_to_top(w);			/* Newly opened windows begin on top */

	wl=w->next;
#if JOHAN_RECTANGLES
	if (wl)		/* Refresh the previous top window as being 'non-topped' */
	{
		invalidate_rect_lists(wl);
		display_non_topped_window(wl,NULL);
 #if 0
		send_app_message(wl->owner, WM_REDRAW, 0, wl->handle, wl->x, wl->y, wl->w, wl->h);
 #endif
	}
#else
	if (wl)		/* Refresh the previous top window as being 'non-topped' */
	{
		display_non_topped_window(wl,NULL);
		send_app_message(wl->owner, WM_REDRAW, 0, wl->handle, wl->x, wl->y, wl->w, wl->h);
	}
#endif

	w->x=pb->intin[1];				/* Change the window coords */
	w->y=pb->intin[2];
	w->w=pb->intin[3];
	w->h=pb->intin[4];

	w->is_open=TRUE;				/* Flag window as open */
	w->window_status=XAWS_OPEN;

	calc_work_area(w);

	v_hide_c(V_handle);
	display_non_topped_window(w,NULL);	/* Display the window (use the non-topped method as it sets clipping rectangles) */
	send_app_message(clnt_pid, WM_REDRAW, 0, w->handle, w->x, w->y, w->w, w->h);
	v_show_c(V_handle,1);

	return XAC_DONE;
}

unsigned long XA_wind_close(short clnt_pid,AESPB *pb)
{
	XA_WINDOW *w;
	
	w=get_wind_by_handle(pb->intin[0]);	/* Get the window */

	if (w==NULL)
	{
		DIAGS(("WARNING:wind_close:Invalid window handle\n"));
		pb->intout[0]=0;			/* Invalid window handle, return error */
		return XAC_DONE;
	}

	if (w->owner!=clnt_pid)		/* Clients can only close their own windows */
	{
		DIAGS(("WARNING: clnt %d cannot close window %d (not owner)\n",clnt_pid,w->handle));
		pb->intout[0]=0;			/* Invalid window handle, return error */
		return XAC_DONE;
	}

#if JOHAN_RECTANGLES
	invalidate_rect_lists(w);
#endif
	v_hide_c(V_handle);

	display_windows_below(w);			/* Redisplay any windows below the one we are closing */

	Psemaphore(2,WIN_LIST_SEMAPHORE,-1L);

	if (w==window_list)
	{
 		window_list=w->next;
		display_non_topped_window(window_list, NULL);
	}

	v_show_c(V_handle,1);

	if (w->prev)						/* Remove the window from the window list */
		w->prev->next=w->next;
	
	if (w->next)
		w->next->prev=w->prev;
	
	w->next=root_window->next;			/* Keep closed windows on the other side of the root window */
	w->prev=root_window;
	if (root_window->next)
		root_window->next->prev=w;
	root_window->next=w;

	Psemaphore(3,WIN_LIST_SEMAPHORE,0L);
	
	w->is_open=FALSE;		/* tag window as closed */
	w->window_status=XAWS_CLOSED;

	/* New top window - change the cursor to this clients choice */
	graf_mouse(clients[window_list->owner].client_mouse, clients[window_list->owner].client_mouse_form);
	
	pb->intout[0]=1;
	
	return XAC_DONE;
}

unsigned long XA_wind_find(short clnt_pid,AESPB *pb)
{
	XA_WINDOW *w;
	
	w=wind_find(pb->intin[0], pb->intin[1]);	/* Is there a window under the mouse? */

	if (w==NULL)
	{
		pb->intout[0]=0;
		return XAC_DONE;
	}

	pb->intout[0]=w->handle;	/* Found a window, return the handle */

	return XAC_DONE;
}

void update_vslide(XA_WINDOW *wind)
{
#if JOHAN_RECTANGLES
	XA_RECT_LIST *rl, *drl;
#else
	XA_RECT_LIST *rl=generate_rect_list(wind),*drl;
#endif
	short x,y,pnt[4];
	XA_WIDGET *widg=wind->widgets;

#if JOHAN_RECTANGLES
	if (!(rl = wind->rl_full))
		rl = wind->rl_full = generate_rect_list(wind);
#endif

	widg+=XAW_VSLIDE;
	
	rp_2_ap(wind, widg, &x, &y);	/* Convert relative coords and window location to absolute screen location */
	pnt[0]=x; pnt[1]=y;
	pnt[2]=x+widg->w; pnt[3]=y+widg->h;
	vsf_color(V_handle,display.dial_colours.bg_col);
	vsf_interior(V_handle,FIS_SOLID);
	
	v_hide_c(V_handle);
	for(drl=rl; drl; drl=drl->next)				/* Walk the rectangle list */
	{
		set_clip(drl->x, drl->y, drl->w, drl->h);
		v_bar(V_handle,pnt);
		display_vslide(wind, widg);
	}
	v_show_c(V_handle,1);
}

void update_hslide(XA_WINDOW *wind)
{
#if JOHAN_RECTANGLES
	XA_RECT_LIST *rl, *drl;
#else
	XA_RECT_LIST *rl=generate_rect_list(wind),*drl;
#endif
	short x,y,pnt[4];
	XA_WIDGET *widg=wind->widgets;
	
#if JOHAN_RECTANGLES
	if (!(rl = wind->rl_full))
		rl = wind->rl_full = generate_rect_list(wind);
#endif
	
	widg+=XAW_HSLIDE;
	
	rp_2_ap(wind, widg, &x, &y);	/* Convert relative coords and window location to absolute screen location */
	pnt[0]=x; pnt[1]=y;
	pnt[2]=x+widg->w; pnt[3]=y+widg->h;
	vsf_color(V_handle,display.dial_colours.bg_col);
	vsf_interior(V_handle,FIS_SOLID);
	vsf_color(V_handle,display.dial_colours.bg_col);
	vsf_interior(V_handle,FIS_SOLID);
	
	v_hide_c(V_handle);
	for(drl=rl; drl; drl=drl->next)				/* Walk the rectangle list */
	{
		set_clip(drl->x, drl->y, drl->w, drl->h);
		v_bar(V_handle,pnt);
		display_hslide(wind, widg);
	}
	v_show_c(V_handle,1);
}

unsigned long XA_wind_set(short clnt_pid, AESPB *pb)
{
	XA_WINDOW *w,*wl;
	OBJECT *ob;
	GRECT clip,our_win;
	short wind=pb->intin[0],cmd=pb->intin[1];
	unsigned short *l;
	char *t;
	
	w=get_wind_by_handle(wind);

	if (w==NULL)
	{
		DIAGS(("WARNING:wind_set:Invalid window handle =%d\n",w));
		pb->intout[0]=0;			/* Invalid window handle, return error */
		return XAC_DONE;
	}

	if ((w->owner!=clnt_pid)		/* Clients can only change their own windows */
		&&((w!=root_window)||(cmd!=WF_NEWDESK)))
	{
		DIAGS(("WARNING: clnt %d cannot change window %d (not owner)\n",clnt_pid,w->handle));
		pb->intout[0]=0;			/* Invalid window handle, return error */
		return XAC_DONE;
	}
	
	switch(cmd)
	{
		case WF_HSLIDE:
			if (w->widgets[XAW_HSLIDE].stuff)
			{
				XA_SLIDER_WIDGET *slw=(XA_SLIDER_WIDGET*)(w->widgets[XAW_HSLIDE].stuff);
				short p=pb->intin[2];
				
				if (p<0) p=0;
				if (p>1000) p=1000;
				
				slw->position=p;
				
				update_hslide(w);
			}
			break;
		case WF_VSLIDE:
			if (w->widgets[XAW_VSLIDE].stuff)
			{
				XA_SLIDER_WIDGET *slw=(XA_SLIDER_WIDGET*)(w->widgets[XAW_VSLIDE].stuff);
				short p=pb->intin[2];
				
				if (p<0) p=0;
				if (p>1000) p=1000;
				
				slw->position=p;
				update_vslide(w);
			}
			break;
		case WF_HSLSIZE:
			if (w->widgets[XAW_HSLIDE].stuff)
			{
				XA_SLIDER_WIDGET *slw=(XA_SLIDER_WIDGET*)(w->widgets[XAW_HSLIDE].stuff);
				short p=pb->intin[2];
				
				if (p<0) p=0;
				if (p>1000) p=1000;
				
				slw->length=p;
				update_hslide(w);
			}
			break;
		case WF_VSLSIZE:
			if (w->widgets[XAW_VSLIDE].stuff)
			{
				XA_SLIDER_WIDGET *slw=(XA_SLIDER_WIDGET*)(w->widgets[XAW_VSLIDE].stuff);
				short p=pb->intin[2];
				
				if (p<0) p=0;
				if (p>1000) p=1000;
				
				slw->length=p;
				update_vslide(w);
			}
			break;
		case WF_NAME:
			l=(unsigned short*)(pb->intin);
			t=(char*)(l[2]<<16);
			t+=l[3];
			w->widgets[XAW_TITLE].stuff=(void*)t;

			v_hide_c(V_handle);
			if (w->is_open)
			{
				rp_2_ap(w, w->widgets+XAW_TITLE, &clip.g_x, &clip.g_y);
	
				clip.g_w=w->widgets[XAW_TITLE].w;
				clip.g_h=w->widgets[XAW_TITLE].h;

				display_non_topped_window(w,&clip);
			}
			v_show_c(V_handle,1);
			break;
		case WF_INFO:
			l=(unsigned short*)(pb->intin);
			t=(char*)(l[2]<<16);
			t+=l[3];
			w->widgets[XAW_INFO].stuff=(void*)t;

			v_hide_c(V_handle);
			if ((w->active_widgets&INFO)&&(w->is_open))
			{
				rp_2_ap(w, w->widgets+XAW_INFO, &clip.g_x, &clip.g_y);
	
				clip.g_w=w->widgets[XAW_INFO].w;
				clip.g_h=w->widgets[XAW_INFO].h;

				display_non_topped_window(w,&clip);
			}
			v_show_c(V_handle,1);
			break;
		case WF_CURRXYWH:			/* Move a window */
			w->prev_x=w->x;				/* Save windows previous coords */
			w->prev_y=w->y;
			w->prev_w=w->w;
			w->prev_h=w->h;

			our_win.g_x=w->x; our_win.g_y=w->y;
			our_win.g_w=w->w; our_win.g_h=w->h;
			
			w->x=pb->intin[2];			/* Change the window coords */
			w->y=pb->intin[3];
			w->w=pb->intin[4];
			w->h=pb->intin[5];

			calc_work_area(w);			/* Recalculate the work area (as well as moving, */
										/* it might have changed size). */
			
			v_hide_c(V_handle);
			
			Psemaphore(2,WIN_LIST_SEMAPHORE,-1L);

#if JOHAN_RECTANGLES
			invalidate_rect_lists(w);
			for(wl=w->next; wl; wl=wl->next)
#else
			for(wl=w; wl; wl=wl->next)
#endif
			{
				clip.g_x=wl->x; clip.g_y=wl->y;
				clip.g_w=wl->w; clip.g_h=wl->h;
				
				if (rc_intersect(&our_win,&clip))
				{
					display_non_topped_window(wl,&clip);
					send_app_message(wl->owner, WM_REDRAW, 0, wl->handle, clip.g_x, clip.g_y, clip.g_w, clip.g_h);
				}
			}
			
			Psemaphore(3,WIN_LIST_SEMAPHORE,0L);
			
			display_non_topped_window(w,NULL);	/* Re-display any revealed windows */
			
			v_show_c(V_handle,1);
			
			send_app_message(clnt_pid, WM_REDRAW, 0, w->handle, w->wx, w->wy, w->ww, w->wh);

			break;
		case WF_BOTTOM:				/* Extension, send window to the bottom */
			v_hide_c(V_handle);
#if JOHAN_RECTANGLES
			invalidate_rect_lists(w);	/* Must be done while we have the original */
#endif
			send_wind_to_bottom(w);			/* Send it to the back */
			
			Psemaphore(2,WIN_LIST_SEMAPHORE,-1L);

			our_win.g_x=w->x; our_win.g_y=w->y;
			our_win.g_w=w->w; our_win.g_h=w->h;
			
#if JOHAN_RECTANGLES
			if (w->prev) 
			{
				display_non_topped_window(w, NULL);

				for(wl=w->prev; wl->prev; wl=wl->prev)
#else
				for(wl=w->prev; wl; wl=wl->prev)
#endif
				{
					clip.g_x=wl->x; clip.g_y=wl->y;
					clip.g_w=wl->w; clip.g_h=wl->h;
				
					if (rc_intersect(&our_win,&clip))
					{
						display_non_topped_window(wl,&clip);	/* Re-display any revealed windows */
						send_app_message(wl->owner, WM_REDRAW, 0, wl->handle, clip.g_x, clip.g_y, clip.g_w, clip.g_h);
					}
				}
#if JOHAN_RECTANGLES

				display_non_topped_window(wl, NULL);	/* Re-display new top window */
				clip.g_x=wl->x; clip.g_y=wl->y;
				clip.g_w=wl->w; clip.g_h=wl->h;
				if (rc_intersect(&our_win,&clip))
					send_app_message(wl->owner, WM_REDRAW, 0, wl->handle, clip.g_x, clip.g_y, clip.g_w, clip.g_h);
			}
#endif
			
			Psemaphore(3,WIN_LIST_SEMAPHORE,0);

			v_show_c(V_handle,1);
			break;
		case WF_TOP:				/* Top the window */
			if (w->is_open)
			{
				pull_wind_to_top(w);
								/* New top window - change the cursor to this clients choice */
				graf_mouse(clients[clnt_pid].client_mouse, clients[clnt_pid].client_mouse_form);
								/* Display the previous top window as un-topped */
			
				v_hide_c(V_handle);
				Psemaphore(2,WIN_LIST_SEMAPHORE,-1L);

#if JOHAN_RECTANGLES
				invalidate_rect_lists(w);
#endif

				if ((window_list->next)&&(window_list->next->is_open))
					display_non_topped_window(window_list->next,NULL);
			
				Psemaphore(3,WIN_LIST_SEMAPHORE,0L);
				v_show_c(V_handle,1);

				display_non_topped_window(w,NULL);	/* Display the window */
				send_app_message(clnt_pid, WM_REDRAW, 0, w->handle, w->x, w->y, w->w, w->h);
			}
			
			break;
			
		case WF_NEWDESK:	/* Set a new desktop object tree */
			l=(unsigned short*)pb->intin;
			t=(char*)(l[2]<<16);
			t+=l[3];
			ob=(OBJECT*)t;
			
			if (ob)
			{
				clients[clnt_pid].desktop=ob;
				set_desktop(ob);
				root_window->owner=clnt_pid;
			}else{
				clients[clnt_pid].desktop=NULL;
				set_desktop((OBJECT*)ResourceTree(system_resources,DEF_DESKTOP));
			}
			
			v_hide_c(V_handle);
			display_non_topped_window(root_window,NULL);
			v_show_c(V_handle,1);
			
			break;
			
		case WF_AUTOREDRAW:		/* Set an auto-redraw callback function for the window */
			l=(unsigned short*)pb->intin;
			t=(char*)(l[2]<<16);
			t+=l[3];
			w->redraw=(WindowDisplayCallback)t;
			break;
			
		case WF_STOREBACK:		/* Set the window's 'preserve own background' attribute */
			w->background=(void*)malloc(display.planes*((w->w+35)>>2)*(w->h+20));
			w->bgx=-1;
			w->active_widgets|=STORE_BACK|NO_REDRAWS;
			
			break;
		
		case WF_ICONIFY:		/* Iconify a window */
			w->prev_x=w->x;				/* Save windows previous coords */
			w->prev_y=w->y;
			w->prev_w=w->w;
			w->prev_h=w->h;

			our_win.g_x=w->x; our_win.g_y=w->y;
			our_win.g_w=w->w; our_win.g_h=w->h;

			w->window_status=XAWS_ICONIFIED;
			w->x=pb->intin[2];			/* Change the window coords */
			w->y=pb->intin[3];
			w->w=pb->intin[4];
			w->h=pb->intin[5];
			
			v_hide_c(V_handle);
			
			Psemaphore(2,WIN_LIST_SEMAPHORE,-1L);

#if JOHAN_RECTANGLES
			invalidate_rect_lists(w);
#endif
			for(wl=w; wl; wl=wl->next)
			{
				clip.g_x=wl->x; clip.g_y=wl->y;
				clip.g_w=wl->w; clip.g_h=wl->h;
				
				if (rc_intersect(&our_win,&clip))
				{
					display_non_topped_window(wl,&clip);
					send_app_message(wl->owner, WM_REDRAW, 0, wl->handle, clip.g_x, clip.g_y, clip.g_w, clip.g_h);
				}
			}
			
			Psemaphore(3,WIN_LIST_SEMAPHORE,0L);
			
			display_non_topped_window(w,NULL);	/* Re-display any revealed windows */
			send_app_message(clnt_pid, WM_REDRAW, 0, w->handle, w->wx, w->wy, w->ww, w->wh);
			
			v_show_c(V_handle,1);
			
			break;

		case WF_UNICONIFY:		/* Un-Iconify a window */

			our_win.g_x=w->x; our_win.g_y=w->y;
			our_win.g_w=w->w; our_win.g_h=w->h;

			w->window_status=XAWS_OPEN;

			w->x=w->prev_x;		/* Restore window to previous position */
			w->y=w->prev_y;
			w->w=w->prev_w;
			w->h=w->prev_h;
			
			v_hide_c(V_handle);
			
			Psemaphore(2,WIN_LIST_SEMAPHORE,-1L);
#if JOHAN_RECTANGLES
			invalidate_rect_lists(w);
#endif
			for(wl=w; wl; wl=wl->next)
			{
				clip.g_x=wl->x; clip.g_y=wl->y;
				clip.g_w=wl->w; clip.g_h=wl->h;
				
				if (rc_intersect(&our_win,&clip))
				{
					display_non_topped_window(wl,&clip);
					send_app_message(wl->owner, WM_REDRAW, 0, wl->handle, clip.g_x, clip.g_y, clip.g_w, clip.g_h);
				}
			}
			
			Psemaphore(3,WIN_LIST_SEMAPHORE,0L);
			
			display_non_topped_window(w,NULL);	/* Re-display any revealed windows */
			
			v_show_c(V_handle,1);
			
			break;

	}

	pb->intout[0]=1;
	return XAC_DONE;
}

/* AES wind_get() function. */
/* This includes support for most of the AES4 / AES4.1 extensions, */
/* with the exception of WF_BEVENT (all XaAES windows get button events in the */
/* background at the moment). */
unsigned long XA_wind_get(short clnt_pid, AESPB *pb)
{
	XA_WINDOW *w;
	XA_RECT_LIST *rl,*drl;
	XA_SLIDER_WIDGET *slw;
	short wind=pb->intin[0],cmd=pb->intin[1];
	GRECT s,d;
	
	w=get_wind_by_handle(wind);

	if (w==NULL)
	{
		DIAGS(("WARNING:wind_get:Invalid window handle =%d\n",wind));
		pb->intout[0]=0;			/* Invalid window handle, return error */
		return XAC_DONE;
	}

	pb->intout[0]=1;

	switch(cmd)
	{
		case WF_FIRSTXYWH:			/* Generate a rectangle list and return the first entry */
#if JOHAN_RECTANGLES
			if (!w->rl_full)
				w->rl_full = generate_rect_list(w);	/* Call the internal rectangle list generator. */

#else
			for(rl=w->rect_list; rl; )	/* Dispose of any existing rectangle list */
			{
				drl=rl;
				rl=rl->next;
				free(rl);
			}
			w->rect_list=NULL;
			
			rl=generate_rect_list(w);	/* Call the internal rectangle list generator. */
			
			for(drl=rl; rl; drl=rl)		/* Fix the rectangle list to clip to the work area only */
			{
				s.g_x=rl->x;
				s.g_y=rl->y;
				s.g_w=rl->w;
				s.g_h=rl->h;
				d.g_x=w->wx;
				d.g_y=w->wy;
				d.g_w=w->ww;
				d.g_h=w->wh;
				rl=rl->next;
				if (rc_intersect(&s, &d))	/* Optimise the rectangle list to only do bit's  */
				{							/* that intersect the work area */
					drl->x=d.g_x;
					drl->y=d.g_y;
					drl->w=d.g_w+1;
					drl->h=d.g_h+1;
					drl->next=w->rect_list;
					w->rect_list=drl;
				}else{
					free(drl);
				}
			}
#endif

#if JOHAN_RECTANGLES
			if (!w->rl_work)
				w->rl_work = create_work_list(w);	/* Call the internal full->work clip routine. */

			if (rl = w->rl_work) {			/* Did we get any rectangles? */
				w->rl_work_cur = rl->next;
#else
			if (w->rect_list)			/* Did we get any rectangles? */
			{
				rl=w->rect_list;
				w->rect_list=rl->next;
#endif
				pb->intout[1]=rl->x;	/* Return the first rectangle coords */
				pb->intout[2]=rl->y;
				pb->intout[3]=rl->w;
				pb->intout[4]=rl->h;
#if JOHAN_RECTANGLES
#else
				free(rl);				/* Dispose the first entry in the rectangle list */
#endif
			}else{
				pb->intout[1]=w->wx;	/* Totally obscured window, return w & h as 0 */
				pb->intout[2]=w->wy;
				pb->intout[3]=0;
				pb->intout[4]=0;
#if JOHAN_RECTANGLES
#else
				w->rect_list=NULL;		/* Window has no rectangle list */
#endif
			}
			break;
		case WF_NEXTXYWH:			/* Get next entry from a rectangle list */
#if JOHAN_RECTANGLES
			if (rl = w->rl_work_cur) {	/* Are there any rectangles left in the list? */
				w->rl_work_cur = rl->next;
#else
			if (w->rect_list!=NULL)		/* Are there any rectangles left in the list ? */
			{
				rl=w->rect_list;
				w->rect_list=rl->next;
#endif
				pb->intout[1]=rl->x;	/* Return the next rectangle coords */
				pb->intout[2]=rl->y;
				pb->intout[3]=rl->w;
				pb->intout[4]=rl->h;
#if JOHAN_RECTANGLES
#else
				free(rl);				/* Dispose the entry in the rectangle list */
#endif
			}else{
				pb->intout[1]=0;		/* No rectangles left - return all zero */
				pb->intout[2]=0;
				pb->intout[3]=0;
				pb->intout[4]=0;
			}
			break;
		case WF_CURRXYWH:			/* Get the current coords of the window */
			pb->intout[1]=w->x;		/* Return the window coords */
			pb->intout[2]=w->y;
			pb->intout[3]=w->w;
			pb->intout[4]=w->h;
			break;
		case WF_WORKXYWH:			/* Get the current coords of the window's user work area */
			pb->intout[1]=w->wx+2;	
			pb->intout[2]=w->wy+2;
			pb->intout[3]=w->ww-4;
			pb->intout[4]=w->wh-4;
			break;
		case WF_PREVXYWH:			/* Get previous window position */
			pb->intout[1]=w->prev_x;
			pb->intout[2]=w->prev_y;
			pb->intout[3]=w->prev_w;
			pb->intout[4]=w->prev_h;
			break;			
		case WF_FULLXYWH:			/* Get maximum window dimensions */
			pb->intout[1]=root_window->x; 
			pb->intout[2]=root_window->wy;	/* ensure the windows don't overlay the menu bar */
			pb->intout[3]=root_window->w;
			pb->intout[4]=root_window->h-root_window->wy;
			break;
		case WF_BOTTOM:				/* Extension, gets the bottom window */
			Psemaphore(2,WIN_LIST_SEMAPHORE,-1L);
			for(w=window_list; w->next; w=w->next);
			Psemaphore(3,WIN_LIST_SEMAPHORE,0L);
			pb->intout[1]=w->handle;	/* Return the window handle of the bottom window */
			pb->intout[2]=w->owner;		/* Return the owner of the bottom window */
			break;
		case WF_TOP:
			Psemaphore(2,WIN_LIST_SEMAPHORE,-1L);
			w=window_list;
			Psemaphore(3,WIN_LIST_SEMAPHORE,0L);
			if (w)
			{
				pb->intout[1]=w->handle;	/* Return the window handle */
				pb->intout[2]=w->owner;		/* AES4 specifies that you return the AESid of the owner here as well */
				if (w->next)				/* Is there a window below?  */
				{							/* if there is, then AES4 says return it's handle here */
					pb->intout[3]=w->next->handle;
					pb->intout[4]=w->next->owner;	/* XaAES extentin - return the AESid of the app that owns the window below */
				}else{
					pb->intout[3]=0;
					pb->intout[4]=0;
				}
			}else{
				pb->intout[1]=0;	/* No windows open - return an error */
				pb->intout[0]=0;
				return XAC_DONE;
			}
			break;
		case WF_OWNER:				/* AES4 compatible stuff */
			pb->intout[1]=w->owner;		/* The window owners AESid (==app_id) */
			pb->intout[2]=w->is_open;	/* Is the window open? */
			if (w->prev)				/* If there is a window above, return it's handle */
			{
				pb->intout[3]=w->prev->handle;
			}else{
				pb->intout[3]=0;
			}
			
			if (w->next)				/* If there is a window below, return it's handle */
			{
				pb->intout[4]=w->next->handle;
			}else{
				pb->intout[4]=0;
			}
			break;
		case WF_VSLIDE:
			if (w->active_widgets&VSLIDE)
			{
				slw=(XA_SLIDER_WIDGET*)(w->widgets[XAW_VSLIDE].stuff);
				pb->intout[1]=slw->position;
			}else{
				pb->intout[0]=pb->intout[1]=0;
				return XAC_DONE;
			}
			break;
		case WF_HSLIDE:
			if (w->active_widgets&HSLIDE)
			{
				slw=(XA_SLIDER_WIDGET*)(w->widgets[XAW_HSLIDE].stuff);
				pb->intout[1]=slw->position;
			}else{
				pb->intout[0]=pb->intout[1]=0;
				return XAC_DONE;
			}
			break;
		case WF_HSLSIZE:
			if (w->active_widgets&HSLIDE)
			{
				slw=(XA_SLIDER_WIDGET*)(w->widgets[XAW_HSLIDE].stuff);
				pb->intout[1]=slw->length;
			}else{
				pb->intout[0]=pb->intout[1]=0;
				return XAC_DONE;
			}
			break;
		case WF_VSLSIZE:
			if (w->active_widgets&VSLIDE)
			{
				slw=(XA_SLIDER_WIDGET*)(w->widgets[XAW_VSLIDE].stuff);
				pb->intout[1]=slw->length;
			}else{
				pb->intout[0]=pb->intout[1]=0;
				return XAC_DONE;
			}
			break;
		case WF_NEWDESK:
			Psemaphore(2,ROOT_SEMAPHORE,-1L);
			pb->intout[1]=((unsigned long)desktop&0xffff0000L)>>16;
			pb->intout[2]=(unsigned long)desktop&0x0000ffffL;
			Psemaphore(3,ROOT_SEMAPHORE,0L);
			break;
		
		case WF_ICONIFY:
			if(w->window_status==XAWS_ICONIFIED)
			{
				pb->intout[1]=1;
				pb->intout[2]=iconify_w;
				pb->intout[3]=iconify_h;
			}else{
				pb->intout[1]=0;
			}
			break;

		case WF_UNICONIFY:
			pb->intout[1]=w->prev_x;
			pb->intout[2]=w->prev_y;
			pb->intout[3]=w->prev_w;
			pb->intout[4]=w->prev_h;
			break;
		
	}
	
	return XAC_DONE;
}

short update_lock=FALSE;
short mouse_lock=FALSE;
short update_cnt=0;
short mouse_cnt=0;

#define	EACCESS	36		/* access denied */

/* Wind_update handling */
/* This handles locking for the update and mctrl flags. */
/* !!!!New version - uses semphores to locking... */
unsigned long XA_wind_update(short clnt_pid, AESPB *pb)
{
	short op=pb->intin[0];
	long timeout=(op&0x100)?0L:-1L;	/* test for check-and-set mode */

	pb->intout[0]=1;

	switch(op)
	{
		case BEG_UPDATE:	/* Grab the update lock */
		case BEG_UPDATE|0x100:
			if (update_lock==clnt_pid)   /* Already owning it? */
			{
				update_cnt++ ;
				break ;
			}
			if ( Psemaphore(2,UPDATE_LOCK,timeout)==-EACCESS )
			{
				pb->intout[0]=0;	/* screen locked by different process */
				break ;
			}
			update_lock=clnt_pid;
			update_cnt=1 ;
			break;
		case END_UPDATE:
			if ((update_lock==clnt_pid)&&(--update_cnt==0))
			{
				update_lock=FALSE;
				Psemaphore(3,UPDATE_LOCK,0);
			}
			break;
		case BEG_MCTRL:		/* Grab the mouse lock */
		case BEG_MCTRL|0x100:
			if (mouse_lock==clnt_pid)   /* Already owning it? */
			{
				mouse_cnt++ ;
				break ;
			}
			if ( Psemaphore(2,MOUSE_LOCK,timeout)==-EACCESS )
			{
				pb->intout[0]=0;	/* mouse locked by different process */
				break ;
			}
			mouse_lock=clnt_pid;
			mouse_cnt=1 ;
			break;
		case END_MCTRL:
			if ((mouse_lock==clnt_pid)&&(--mouse_cnt==0))
			{
				mouse_lock=FALSE;
				Psemaphore(3,MOUSE_LOCK,0);
			}
			break;
	}
	return XAC_DONE;
}

unsigned long XA_wind_delete(short clnt_pid, AESPB *pb)
{
	XA_WINDOW *w=get_wind_by_handle(pb->intin[0]);

	if (w)
	{
		delete_window(w);
	}
	
	pb->intout[0]=1;
	
	return XAC_DONE;
}

/* Go through and check that all windows belonging to this client are */
/* closed and deleted  */
unsigned long XA_wind_new(short clnt_pid, AESPB *pb)
{
	XA_WINDOW *wl,*dwl;

	for(wl=window_list; wl;)
	{
		if ((wl->owner==clnt_pid)&&(wl!=root_window))
		{
			dwl=wl;

			v_hide_c(V_handle);
			display_windows_below(wl);				/* Redisplay any windows below the one we are closing */
			v_show_c(V_handle, 1);

			wl=wl->next;
			
			if (window_list==dwl)					/* Actually delete the window */
				window_list=dwl->next;

			if (dwl->prev) dwl->prev->next=dwl->next;
			if (dwl->next) dwl->next->prev=dwl->prev;

			free(dwl);
		}else{
			wl=wl->next;
		}
	}
	
	return XAC_DONE;
}

/*
	wind_calc
*/
unsigned long XA_wind_calc(short clnt_pid, AESPB *pb)
{
	XA_WINDOW *w_temp;
	short request=pb->intin[0];
	
/* Create a temporary window with the required widgets */
	w_temp=create_window(clnt_pid, pb->intin[1], pb->intin[2], pb->intin[3], pb->intin[4], pb->intin[5]);

	switch(request)
	{
		case WC_BORDER:					/* We have to work out the border size ourselves here */
			pb->intout[1]=2*w_temp->x - w_temp->wx;	/*if you want to prove the maths here, draw two boxes one inside */
			pb->intout[2]=2*w_temp->y - w_temp->wy;	/* the other, then sit and think about it for a while.... */
			pb->intout[3]=2*w_temp->w - w_temp->ww +1;
			pb->intout[4]=2*w_temp->h - w_temp->wh +1;
			break;
		case WC_WORK:					/* Work area was calculated when the window was created */
			pb->intout[1]=w_temp->wx;
			pb->intout[2]=w_temp->wy;
			pb->intout[3]=w_temp->ww+1;
			pb->intout[4]=w_temp->wh+1;
			break;
	}

	delete_window(w_temp);		/* Dispose of the temporary window we created */

	pb->intout[0]=1;
	
	return XAC_DONE;
}
