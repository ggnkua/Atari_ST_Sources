/*======================================================
	LEFT SCROLL WIDGET BEHAVIOUR
========================================================*/
/* Displayed by display_def_widget */

static
WidgetCallback click_lscroll	/* (XA_WINDOW *wind, XA_WIDGET *widg) */
{
	short mx, my, mb;
	XA_WIDGET *slider = &wind->widgets[XAW_HSLIDE];
	XA_CLIENT *client = Pid2Client(wind->owner);

	if ((client->widget_active) && slider && slider->stuff
		&& (((XA_SLIDER_WIDGET *)slider->stuff)->position == 0))
	{
		cancel_widget_active(wind);
		return TRUE;
	}	
	
	send_app_message(wind->owner, WM_ARROWED, 0, wind->handle, WA_LFLINE, 0, 0, 0);
	vq_mouse(V_handle, &mb, &mx, &my);

	if (mb)	/* If the button has been held down, set a pending/active widget for the client */
	{
		set_widget_active(wind, widg, &click_lscroll);
		return FALSE;	/* We return false here so the widget display status stays selected whilst it repeats */
	}
	cancel_widget_active(wind);
	return TRUE;
}


/*======================================================
	RIGHT SCROLL WIDGET BEHAVIOUR
========================================================*/
/* Displayed by display_def_widget */

static
WidgetCallback click_rscroll	/* (XA_WINDOW *wind, XA_WIDGET *widg) */
{
	short mx, my, mb;
	XA_WIDGET *slider = &wind->widgets[XAW_HSLIDE];
	XA_CLIENT *client = Pid2Client(wind->owner);

	if ((client->widget_active) && slider && slider->stuff
		&& (((XA_SLIDER_WIDGET *)slider->stuff)->position == 1000))
	{
		cancel_widget_active(wind);
		return TRUE;
	}	
	
	send_app_message(wind->owner, WM_ARROWED, 0, wind->handle, WA_RTLINE, 0, 0, 0);
	vq_mouse(V_handle, &mb, &mx, &my);

	if (mb)	/* If the button has been held down, set a pending/active widget for the client */
	{
		set_widget_active(wind, widg, &click_rscroll);
		return FALSE;	/* We return false here so the widget display status stays selected whilst it repeats */
	}
	cancel_widget_active(wind);
	return TRUE;
}

/*======================================================
	UP SCROLL WIDGET BEHAVIOUR
========================================================*/
/* Displayed by display_def_widget */

static
WidgetCallback click_uscroll	/* (XA_WINDOW *wind, XA_WIDGET *widg) */
{
	short mx, my, mb;
	XA_WIDGET *slider = &wind->widgets[XAW_VSLIDE];
	XA_CLIENT *client = Pid2Client(wind->owner);

	if ((client->widget_active) && slider && slider->stuff
		&& (((XA_SLIDER_WIDGET *)slider->stuff)->position == 0))
	{
		cancel_widget_active(wind);
		return TRUE;
	}	
	send_app_message(wind->owner, WM_ARROWED, 0, wind->handle, WA_UPLINE, 0, 0, 0);
	vq_mouse(V_handle, &mb, &mx, &my);

	if (mb)	/* If the button has been held down, set a pending/active widget for the client */
	{
		set_widget_active(wind, widg, &click_uscroll);
		return FALSE;	/* We return false here so the widget display status stays selected whilst it repeats */
	}
	cancel_widget_active(wind);
	return TRUE;
}

/*======================================================
	DOWN SCROLL WIDGET BEHAVIOUR
========================================================*/
/* Displayed by display_def_widget */

static
WidgetCallback click_dscroll	/* (XA_WINDOW *wind, XA_WIDGET *widg) */
{
	short mx, my, mb;
	XA_WIDGET *slider = &wind->widgets[XAW_VSLIDE];
	XA_CLIENT *client = Pid2Client(wind->owner);

	if ((client->widget_active) && slider && slider->stuff
		&& (((XA_SLIDER_WIDGET *)slider->stuff)->position == 1000))
	{
		cancel_widget_active(wind);
		return TRUE;
	}	
	send_app_message(wind->owner, WM_ARROWED, 0, wind->handle, WA_DNLINE, 0, 0, 0);
	vq_mouse(V_handle, &mb, &mx, &my);

	if (mb)	/* If the button has been held down, set a pending/active widget for the client */
	{
		set_widget_active(wind, widg, &click_dscroll);
		return FALSE;	/* We return false here so the widget display status stays selected whilst it repeats */
	}
	cancel_widget_active(wind);
	return TRUE;
}
