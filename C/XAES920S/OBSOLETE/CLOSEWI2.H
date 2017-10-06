/*
 * Close an open window and re-display any windows underneath it.
 * Also places window behind root window but does NOT delete it
 * - the window will still exist after this call.
 */
short close_window(LOCK lock, XA_WINDOW *wind)
{
	XA_WINDOW *wl;
	RECT r, clip;
	short is_top, pid = wind->pid;
	XA_CLIENT *client = wind->owner;
	
	if (wind == NULL)
	{
		DIAG((D.wind,-1,"close_window: null window pointer\n"));
		return 0;					/* Invalid window handle, return error */
	}

	DIAG((D.wind,wind->pid,"close_window: %d, open? %d\n", wind->handle, wind->is_open));

	if (wind->is_open == FALSE || wind->nolist)
		return 0;
	
	if unlocked(winlist)
		Sema_Up(WIN_LIST_SEMA);

	is_top = (wind == window_list);

	wl = wind->next;
	r = wind->r;

	wind->is_open = FALSE;					/* Tag window as closed */
	wind->window_status = XAWS_CLOSED;

	if (wind->prev)						/* Remove the window from the window list */
		wind->prev->next = wind->next;
	
	if (wind->next)
		wind->next->prev = wind->prev;
	
	wind->next = root_window->next;				/* Keep closed windows on the other side of the root window */
	wind->prev = root_window;
	if (root_window->next)
		root_window->next->prev = wind;
	root_window->next = wind;

#if 0
#include "obsolete/closewin.h"			/* heavily #if'd and dirty and wrong version */
#else

	if (is_top)
	{
		XA_WINDOW *w, *napp = nil;
 
 		window_list = wl;
 		w = window_list;

/*	HR: v_hide/show_c now correctly done in display_window()  */
/*	if (wind == focus.window)	/* New focus? */  HR: focus.window = window_list */
/*  if you want point_to_type, handle that in do_keyboard */


/* First: find a window of the owner */
		do{
			if (w != root_window && w->is_open)
			{ 
				if (w->pid == pid)		/* gotcha */
				{
					top_window(lock|winlist, w, w->pid);		/* HR */
					wl = w->next;
					break;
				}
				else
				if (!napp)
					napp = w;	/* remember the first window of another app. */
			}
			w = w->next;

			/* roundabout? */
			if (w == wind && napp)
			{
/* Second: If none: top any other open window  */
/* HR: this is the one I was really missing */
				top_window(lock|winlist, napp, menu_owner());
				wl = window_list->next;

				break;
			}
		} while (w);
	}

/* Redisplay any windows below the one we just have closed
   or just have topped
   Note: wind is now just behind root.
*/
	while(wl != wind)
	{
		clip = wl->r;
		if (rc_intersect(&r, &clip))
		{
			generate_rect_list(lock|winlist, wl);			/* If a new focus was pulled up, some of these are not needed */
			display_non_topped_window(lock|winlist, 14, wl, &clip);
			if (!(wl->active_widgets & NO_MESSAGES))	/* Does this window's application want messages? If so send it a redraw */
				wl->send_message(lock|winlist, wl, wl->pid, WM_REDRAW, 0, wl->handle, clip.x, clip.y, clip.w, clip.h);
		}
		wl = wl->next;
	}


#if 1
	if (   window_list->pid != pid
		&& client->std_menu.tree == nil
		)
#endif
	{
/* HR: get the menu bar right (only if the pid has no menu bar
	and no more open windows for pid. */
		DIAG((D.menu,-1,"close_window: swap_menu to %s(%d)\n", window_list->owner->name, window_list->pid));
		swap_menu(lock|winlist, window_list->pid);
	}

#endif

	if unlocked(winlist)
		Sema_Dn(WIN_LIST_SEMA);
	return 1;
}
