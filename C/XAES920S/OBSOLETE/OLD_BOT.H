		if (!(wind->active_widgets & STORE_BACK))	/* Don't bottom STORE_BACK windows */
		{
			if (wind->active_widgets & NO_MESSAGES)
			{
				v_hide_c(V_handle);
				Psemaphore(2, WIN_LIST_SEMAPHORE, -1L);

				send_wind_to_bottom(wind);		/* Send it to the back */
						
				display_non_topped_window(wind, NULL);		/* Re-display new top window */

				v_show_c(V_handle, 1);

				our_win.g_x = wind->x;
				our_win.g_y = wind->y;
				our_win.g_w = wind->w;
				our_win.g_h = wind->h;
			
				for(wl = wind->prev; wl->prev; wl = wl->prev)
				{
					clip.g_x = wl->x;
					clip.g_y = wl->y;
					clip.g_w = wl->w;
					clip.g_h = wl->h;
				
					if (rc_intersect(&our_win, &clip))
					{
						display_non_topped_window(wl, &clip);		/* Re-display any revealed windows */			
						send_app_message(wl->owner, WM_REDRAW, 0, wl->handle, clip.g_x, clip.g_y, clip.g_w, clip.g_h);
					}
				}
				display_non_topped_window(wl, NULL);		/* Re-display new top window */

			} else
			{

				send_app_message(wind->owner, WM_BOTTOMED, 0, wind->handle, 0, 0, 0, 0);

			}
		}
