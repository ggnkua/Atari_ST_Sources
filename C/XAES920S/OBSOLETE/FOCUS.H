short find_focus(XA_WINDOW **wind)
{
	short pid;
	XA_WINDOW *w = NULL;
	XA_CLIENT *client;

	if (update_lock)
	{
		client = Pid2Client(update_lock);
		if (
	}
	else
	{
#if POINT_TO_TYPE
		/* Keyboard input goes to the application whose window is under the mouse */
	
		w = wind_find(mx, my); 
	
		/* If there is no window under the mouse, send to the top window instead */
		
		if (!w)
		{
#if 0
			w = window_list;
#else
			w = focus.window;
#endif
		} else
		{
			/*  HR   ?????????????? */
			if (!(w->owner->waiting_for & XAWAIT_KEY))	/* If window under mouse isn't waiting for keys, maybe the top window is? */
#if 0
				w = window_list;
#else
				w = focus.window;
#endif
		}
	
		pid =  w->owner;

#else		/* ! POINT_TO_TYPE */

	/* Keyboard input always goes to the application whose window is on top */
	
#if 0
		w = window_list;
		pid =  w->owner;
#else
		w = focus.window;
		pid = focus.pid;
		if (!w && focus.menu_bar)			/* HR */
			pid = focus.menu_bar->owner;
#endif
	
#endif
	}
	if (wind)
		*wind = w;
	client = Pid2Client(pid);

	return client;
}