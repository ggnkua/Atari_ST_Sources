short drag_hslide(XA_WINDOW *wind, XA_WIDGET *widg)
{
	short pmx,pmy,mx,my,mb,x,y,wcx;
	short imx,imy,pnt[4],clip[4],offs,noffs,len,dx,orig_offs;
	XA_SLIDER_WIDGET *sl=(XA_SLIDER_WIDGET*)(widg->stuff);
	XA_RECT_LIST *rl=rect_get_system_first(wind);
	XA_CLIENT *client=Pid2Client(wind->owner);
 
	rp_2_ap(wind, widg, &x, &y);	/* Convert relative coords and window location to absolute screen location */
	pnt[0]=x; pnt[1]=y;
	pnt[2]=x+widg->w; pnt[3]=y+widg->h;
	vsf_color(V_handle,display.dial_colours.bg_col);
	vsf_interior(V_handle,FIS_SOLID);

	len=(widg->w*sl->length)/1000;
	orig_offs=offs=sl->position;

	vq_mouse(V_handle, &mb, &imx, &imy);
	if ((mb==1)&&(client->widget_active))
	{
		imx=client->widget_active->info;
		wcx=1;
	}else{
		wcx=widg->click_x-((widg->w - len)*sl->position)/1000;
	}pmx=imx; pmy=imy;

	if ((mb)&&((wcx>0)&&(wcx<len)))			/* Drag slider */
	{
		do {
			vq_mouse(V_handle, &mb, &mx, &my);
			if (mx!=pmx)					/* Has mouse moved? */
			{
				dx=(1000*(mx-pmx))/(widg->w-len);
				noffs=offs+dx;
				if (noffs<0) noffs=0;
				if (noffs>1000) noffs=1000;

				if (noffs!=offs)			/* Has the slider moved? */
				{
					v_hide_c(V_handle);
					for(rl=rect_get_system_first(wind); rl; rl=rect_get_system_next(wind))				/* Walk the rectangle list */
					{
						set_clip(rl->r);
						v_bar(V_handle,pnt);
					}
					offs=noffs;
					sl->position=offs;
					for(rl=rect_get_system_first(wind); rl; rl=rect_get_system_next(wind))				/* Walk the rectangle list */
					{
						set_clip(rl->r);
						display_hslide(wind, widg);
					}
					v_show_c(V_handle, 1);
				}
				pmx=mx;
			}
#if REALTIME_SCROLL	
		} while((mb==2)||((mb==1)&&((abs(offs-orig_offs)<RT_SCROLL_STEP))));
		if (mb)		/* If the button has been held down, set a pending/active widget for the client */
		{
			set_widget_active(wind, widg, &drag_hslide);
			sl->position=orig_offs;
			client->widget_active->info=pmx;
			send_app_message(wind->owner, WM_HSLID, 0, wind->handle, offs, 0, 0, 0);
			return FALSE;	/* We return false here so the widget display status stays selected whilst it repeats */
		}
		cancel_widget_active(wind);
#else
		} while(mb);
#endif

		sl->position=orig_offs;
		send_app_message(wind->owner, WM_HSLID, 0, wind->handle, offs, 0, 0, 0);
	}else{
		vsf_color(V_handle,display.dial_colours.highlight_col);
		if (wcx<0)			/* Page left */
		{
			send_app_message(wind->owner, WM_ARROWED, 0, wind->handle, WA_LFPAGE, 0, 0, 0);
			pnt[0]=x; pnt[1]=y;
			pnt[2]=x+(widg->w - len)*sl->position/1000; pnt[3]=y+widg->h;
		}else{					/* Page right */
			send_app_message(wind->owner, WM_ARROWED, 0, wind->handle, WA_RTPAGE, 0, 0, 0);
			pnt[0]=x+(widg->w - len)*sl->position/1000+len; pnt[1]=y;
			pnt[2]=x+widg->w; pnt[3]=y+widg->h;
		}
		v_hide_c(V_handle);
		for(rl=rect_get_system_first(wind); rl; rl=rect_get_system_next(wind))				/* Walk the rectangle list */
		{
			set_clip(rl->r);
			v_bar(V_handle,pnt);
			display_hslide(wind, widg);
		}
		v_show_c(V_handle, 1);
		vsf_color(V_handle,display.dial_colours.bg_col);
		if (mb)	/* If the button has been held down, set a pending/active widget for the client */
		{
			set_widget_active(wind, widg, &drag_hslide);
			return FALSE;	/* We return false here so the widget display status stays selected whilst it repeats */
		}
		cancel_widget_active(wind);
	}
	
	v_hide_c(V_handle);
	for(rl=rect_get_system_first(wind); rl; rl=rect_get_system_next(wind))		/* erase the dragged slider */
	{
		set_clip(rl->r);
		v_bar(V_handle,pnt);
	}				/* We don't need to re-draw the slider as it get's redrawn by the  */
					/* standard widget handler anyway. */
	v_show_c(V_handle, 1);

	return TRUE;
}
