	if (is_top)
 		window_list = wl;

#if 1
/*	HR: v_hide/show_c now correctly done in display_window() */
	if (wind == focus.window)	/* New focus? */
	{
		XA_WINDOW *w = window_list;
		while (w != wind)
		{
			if (w->owner == focus.pid)
				break;
			w = w->next;
		}

		if (w == wind)
	#if 1
			top_next_window();		/* HR: There is some duplication, have to sort that out */
	#else
			focus.window = NULL;			/* Couldn't find anything to focus */
	#endif
		else
		{
	#if 1
			top_window(w);
	#else
			is_top = 1;				/* May not have been that before (?)*/
			pull_wind_to_top(w);	/* Doesnt send redraws, but sets focus.window */
			display_non_topped_window(w, NULL);
			if (!(w->active_widgets & NO_MESSAGES))
				send_app_message(w->owner, WM_REDRAW, 0, focus.window->handle, w->r.x, w->r.y, w->r.w, w->r.h);
	#endif
			wl = w->next;
		}
	}
#endif

/* Redisplay any windows below the one we are closing */
	while(wl != wind)
	{
		clip = wl->r;
		if (rc_intersect(&r, &clip))
		{
			generate_rect_list(wl);			/* If a new focus was pulled up, some of these are not needed */
			display_non_topped_window(wl, &clip);
			if (!(wl->active_widgets & NO_MESSAGES))	/* Does this window's application want messages? If so send it a redraw */
				send_app_message(wl->owner, WM_REDRAW, 0, wl->handle, clip.x, clip.y, clip.w, clip.h);
		}
		wl = wl->next;
	}

#if 1			/* HR: some generalization */
	{
		XA_WIDGET_TREE *menu_bar = (XA_WIDGET_TREE *)(root_window->widgets[XAW_MENU].stuff);
		swap_menu_in_root(menu_bar, focus.window->owner);
	}
#else
	#if 0
		if ((is_top) && (window_list != root_window))	/* New top window should be displayed in its entirety */
		{
			display_non_topped_window(window_list, NULL);
			if(!(window_list->active_widgets & NO_MESSAGES))
			{
				send_app_message(window_list->owner, WM_ONTOP, 0, window_list->handle, 0, 0, 0, 0);
				send_app_message(window_list->owner, WM_REDRAW, 0, window_list->handle, r.x, r.y, r.w, r.h);
			}
		}
	
		check_menu_desktop(wind, window_list);
	#else
		if ((is_top) && (window_list != root_window))	/* New top window should be displayed in its entirety */
		{
			if(!(window_list->active_widgets & NO_MESSAGES))
			{
				send_app_message(window_list->owner, WM_ONTOP, 0, window_list->handle, 0, 0, 0, 0);
			}
		}
	#endif

	v_show_c(V_handle, 1);

	client = Pid2Client(window_list->owner);

	/* New top window - change the cursor to this client's choice */

	graf_mouse(client->client_mouse, client->client_mouse_form);
#endif
