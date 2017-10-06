static
WidgetCallback drag_vslide	/* (XA_WINDOW *wind, XA_WIDGET *widg) */
{
	short pmx, pmy, mx, my, mb, wcy, dy;
	short imx, imy, pnt[4], clip[4], offs, noffs, len, orig_offs, start_offs, last_offs;
	RECT r;
	XA_SLIDER_WIDGET *sl = widg->stuff;
	XA_RECT_LIST *rl;
	XA_CLIENT *client = Pid2Client(wind->owner);

	rp_2_ap(wind, widg, &r);	/* Convert relative coords and window location to absolute screen location */

	rtopxy(pnt, &r);
	len = ((long)widg->loc.r.h * sl->length) / 1000;
	orig_offs = offs = sl->position;

	vq_mouse(V_handle, &mb, &imx, &imy);
	if ((client->widget_active))
	{
		if (mb == 1)				/* L button down */
		{
			wcy = client->widget_active->info;
			if (wcy >= 0)	/* Drag in progress */
			{
				imy = client->widget_active->info;
				start_offs = client->widget_active->info2;
				offs = last_offs = client->widget_active->info3;
			} else	/* Page up/down in progress */
			{
				if ((wcy == -1) && (offs == 0))
					wcy = -3;	/* No more widget action once top reached */
				if ((wcy == -2) && (offs == 1000))
					wcy = -3;	/* No more widget action once bottom reached */
			}
		} else
			wcy = -3;		/* No more widget action once button lifted */
	} else
	{
		wcy = widg->click_y - (((long)widg->loc.r.h - len) * sl->position) / 1000;
		last_offs = start_offs = orig_offs;
		if (wcy < 0)
		{
			if (offs > 0)
				wcy = -1;
			else
				wcy = -3;	/* No more widget action once top reached */
		} else if (wcy >= len)
		{
			if (offs < 1000)
				wcy = -2;
			else
				wcy = -3;	/* No more widget action once bottom reached */
		}
	}
	pmx = imx; pmy = imy;
	
	if ((mb) && (wcy >= 0))
	{				/* Drag slider */
#if 0
		do
		{
#endif
			vq_mouse(V_handle, &mb, &mx, &my);
			if (my != pmy)	/* Has the mouse moved? */
			{
				dy = (1000L * (my - imy)) / (widg->loc.r.h - len);
				noffs = start_offs + dy;
				if (noffs < 0)
					noffs = 0;
				if (noffs > 1000)
					noffs = 1000;

				if (noffs != offs)	/* Has the slider moved? */
				{
					offs = noffs;
					sl->position = offs;
#if 0
					vsf_color(V_handle, display.dial_colours.bg_col);
					vsf_interior(V_handle, FIS_SOLID);

					v_hide_c(V_handle);
					for(rl = rect_get_system_first(wind); rl; rl = rect_get_system_next(wind))	/* Walk the rectangle list */
					{
						set_clip(&rl->r);
						v_bar(V_handle, pnt);
						display_vslide(wind, widg);
					}
					v_show_c(V_handle, 1);
#endif
				}
				pmy = my;
			}
#if REALTIME_SCROLL	
#if 0
		} while((mb == 2) || ((mb == 1) && (abs(offs - orig_offs) < RT_SCROLL_STEP)));
#endif

		if (mb == 1)	/* If the button has been held down, set a pending/active widget for the client */
		{
			sl->position = orig_offs;

	/* It would be nice not to send messages unless it's necessary.
	 * However, that doesn't work well now since this routine is only
	 * called on evnt_multi() or evnt_mesag(), rather than from the
	 * kernel loop or similar.
	 */
#if 0
#if 0
			if (offs != orig_offs)
#else
			if (offs != last_offs)
#endif
#endif
				send_app_message(wind->owner, WM_VSLID, 0, wind->handle, offs, 0, 0, 0);
			set_widget_active(wind, widg, &drag_vslide);
			client->widget_active->info = imy;
			client->widget_active->info2 = start_offs;
			client->widget_active->info3 = offs;		/* Not necessarily the same as the new sl->position */
			return FALSE;	/* We return false here so the widget display status stays selected whilst it repeats */
		}
		cancel_widget_active(wind);
#else
		} while(mb);
#endif
		sl->position = orig_offs;
		send_app_message(wind->owner, WM_VSLID, 0, wind->handle, offs, 0, 0, 0);

		vsf_color(V_handle, display.dial_colours.bg_col);
		vsf_interior(V_handle, FIS_SOLID);
	} else
	{
		vsf_color(V_handle, display.dial_colours.highlight_col);
		vsf_interior(V_handle, FIS_SOLID);
		if (wcy == -1)	/* Page up */
		{
			send_app_message(wind->owner, WM_ARROWED, 0, wind->handle, WA_UPPAGE, 0, 0, 0);
			pnt[3] = r.y + ((long)r.h - len) * sl->position / 1000;
		} else if (wcy == -2)	/* Page down */
		{
			send_app_message(wind->owner, WM_ARROWED, 0, wind->handle, WA_DNPAGE, 0, 0, 0);
			pnt[1] = r.y + ((long)r.h - len) * sl->position / 1000 + len;
		}

		v_hide_c(V_handle);
		for(rl = rect_get_system_first(wind); rl; rl = rect_get_system_next(wind))
		{				/* Walk the rectangle list */
			set_clip(&rl->r);
			v_bar(V_handle, pnt);
			display_vslide(wind, widg);
		}
		v_show_c(V_handle, 1);

		vsf_color(V_handle, display.dial_colours.bg_col);
		if (mb && !(wcy == -3))	/* If the button has been held down, set a pending/active widget for the client */
		{
			set_widget_active(wind, widg, &drag_vslide);
			client->widget_active->info = wcy;
			return FALSE;	/* We return false here so the widget display status stays selected whilst it repeats */
		}
		cancel_widget_active(wind);
	}
	
	v_hide_c(V_handle);
	for(rl = rect_get_system_first(wind); rl; rl = rect_get_system_next(wind))	/* Erase the dragged slider */
	{
		set_clip(&rl->r);
		v_bar(V_handle, pnt);
	}				/* We don't need to re-draw the slider as it get's redrawn by the  */
					/* standard widget handler anyway. */
	v_show_c(V_handle, 1);

	return TRUE;
}


static
WidgetCallback drag_hslide	/* (XA_WINDOW *wind, XA_WIDGET *widg) */
{
	short pmx, pmy, mx, my, mb, wcx, dx;
	short imx, imy, pnt[4], clip[4], offs, noffs, len, orig_offs, start_offs, last_offs;
	RECT r;
	XA_SLIDER_WIDGET *sl = widg->stuff;
	XA_RECT_LIST *rl;
	XA_CLIENT *client = Pid2Client(wind->owner);

	rp_2_ap(wind, widg, &r);	/* Convert relative coords and window location to absolute screen location */

	rtopxy(pnt, &r);
	len = ((long)widg->loc.r.w * sl->length) / 1000;
	orig_offs = offs = sl->position;

	vq_mouse(V_handle, &mb, &imx, &imy);
	if ((client->widget_active))
	{
		if (mb == 1)
		{
			wcx = client->widget_active->info;
			if (wcx >= 0)	/* Drag in progress */
			{
				imx = client->widget_active->info;
				start_offs = client->widget_active->info2;
				offs = last_offs = client->widget_active->info3;
			} else	/* Page left/right in progress */
			{
				if ((wcx == -1) && (offs == 0))
					wcx = -3;	/* No more widget action once left edge reached */
				if ((wcx == -2) && (offs == 1000))
					wcx = -3;	/* No more widget action once right edge reached */
			}
		} else
			wcx = -3;		/* No more widget action once button lifted */
	} else
	{
		wcx = widg->click_x - (((long)widg->loc.r.w - len) * sl->position) / 1000;
		last_offs = start_offs = orig_offs;
		if (wcx < 0)
		{
			if (offs > 0)
				wcx = -1;
			else
				wcx = -3;	/* No more widget action once left edge reached */
		} else if (wcx >= len)
		{
			if (offs < 1000)
				wcx = -2;
			else
				wcx = -3;	/* No more widget action once right edge reached */
		}
	}
	pmx = imx; pmy = imy;
	
	if ((mb) && (wcx >= 0))
	{				/* Drag slider */
#if 0
		do
		{
#endif
			vq_mouse(V_handle, &mb, &mx, &my);
			if (mx != pmx)	/* Has the mouse moved? */
			{
				dx = (1000L * (mx - imx)) / (widg->loc.r.w - len);
				noffs = start_offs + dx;
				if (noffs < 0)
					noffs = 0;
				if (noffs > 1000)
					noffs = 1000;

				if (noffs != offs)	/* Has the slider moved? */
				{
					offs = noffs;
					sl->position = offs;
#if 0
					vsf_color(V_handle, display.dial_colours.bg_col);
					vsf_interior(V_handle, FIS_SOLID);

					v_hide_c(V_handle);
					for(rl = rect_get_system_first(wind); rl; rl = rect_get_system_next(wind))	/* Walk the rectangle list */
					{
						set_clip(&rl->r);
						v_bar(V_handle, pnt);
						display_vslide(wind, widg);
					}
					v_show_c(V_handle, 1);
#endif
				}
				pmx = mx;
			}
#if REALTIME_SCROLL	
#if 0
		} while((mb == 2) || ((mb == 1) && (abs(offs - orig_offs) < RT_SCROLL_STEP)));
#endif

		if (mb == 1)	/* If the button has been held down, set a pending/active widget for the client */
		{
			sl->position = orig_offs;

	/* It would be nice not to send messages unless it's necessary.
	 * However, that doesn't work well now since this routine is only
	 * called on evnt_multi() or evnt_mesag(), rather than from the
	 * kernel loop or similar.
	 */
#if 0
#if 0
			if (offs != orig_offs)
#else
			if (offs != last_offs)
#endif
#endif
				send_app_message(wind->owner, WM_HSLID, 0, wind->handle, offs, 0, 0, 0);
			set_widget_active(wind, widg, &drag_hslide);
			client->widget_active->info = imx;
			client->widget_active->info2 = start_offs;
			client->widget_active->info3 = offs;		/* Not necessarily the same as the new sl->position */
			return FALSE;	/* We return false here so the widget display status stays selected whilst it repeats */
		}
		cancel_widget_active(wind);
#else
		} while(mb);
#endif
		sl->position = orig_offs;
		send_app_message(wind->owner, WM_HSLID, 0, wind->handle, offs, 0, 0, 0);

		vsf_color(V_handle, display.dial_colours.bg_col);
		vsf_interior(V_handle, FIS_SOLID);
	} else
	{
		vsf_color(V_handle, display.dial_colours.highlight_col);
		vsf_interior(V_handle, FIS_SOLID);
		if (wcx == -1)	/* Page left */
		{
			send_app_message(wind->owner, WM_ARROWED, 0, wind->handle, WA_LFPAGE, 0, 0, 0);
			pnt[2] = r.x + ((long)r.w - len) * sl->position / 1000;
		} else if (wcx == -2)	/* Page right */
		{
			send_app_message(wind->owner, WM_ARROWED, 0, wind->handle, WA_RTPAGE, 0, 0, 0);
			pnt[0] = r.x + ((long)r.w - len) * sl->position / 1000 + len;
		}
		v_hide_c(V_handle);
		for(rl = rect_get_system_first(wind); rl; rl = rect_get_system_next(wind))
		{				/* Walk the rectangle list */
			set_clip(&rl->r);
			v_bar(V_handle, pnt);
			display_hslide(wind, widg);		/* HR: was display_vslide ???? */
		}
		v_show_c(V_handle, 1);
		vsf_color(V_handle, display.dial_colours.bg_col);
		if (mb && !(wcx == -3))	/* If the button has been held down, set a pending/active widget for the client */
		{
			set_widget_active(wind, widg, &drag_hslide);
			client->widget_active->info = wcx;
			return FALSE;	/* We return false here so the widget display status stays selected whilst it repeats */
		}
		cancel_widget_active(wind);
	}
	
	v_hide_c(V_handle);
	for(rl = rect_get_system_first(wind); rl; rl = rect_get_system_next(wind))	/* Erase the dragged slider */
	{
		set_clip(&rl->r);
		v_bar(V_handle, pnt);
	}				/* We don't need to re-draw the slider as it get's redrawn by the  */
					/* standard widget handler anyway. */
	v_show_c(V_handle, 1);
	return TRUE;
}

#if 0
#include "hslide_c.h"			/* a cancelled version */
#endif
