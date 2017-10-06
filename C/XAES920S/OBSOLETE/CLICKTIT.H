	short is_top, is_focus;
#if 0
	if (    (window_list != wind) 									/* If window isn't on top, */
	    || ((window_list == wind) && (focus.window != wind)))	/*  or is but not focused - top it */
#else
	if (wind != window_list)		/* HR: if not on top */
#endif
	{
		old_focus = window_list;  /* focus.window; */

		if (wind->active_widgets & NO_MESSAGES)		/* Just top these windows, they can handle it... */
		{
			pull_wind_to_top(lock, wind);			/* Top the window */
#if 0
			if (old_focus)
#endif
				display_non_topped_window(lock, old_focus, NULL);

			display_non_topped_window(lock, wind, NULL);		/* Display the window */
		}
		else
			wind->send_message(lock, wind->owner, WM_TOPPED, 0, wind->handle, 0, 0, 0, 0);
	
	}
