#if 0	/* Only for reading */
	stdl_close   = {LT, 2,          2,           ICON_W, ICON_H},
	stdl_full    = {RT, SO,         2,           ICON_W, ICON_H},
	stdl_iconify = {RT, SO,         2,           ICON_W, ICON_H},
	stdl_title   = {LT, ICON_W + SO,2,           ICON_W, ICON_H},
	stdl_resize  = {RB, SO,         SO,          ICON_W, ICON_H},
	stdl_rscroll = {RB, ICON_W + SO,SO,          ICON_W, ICON_H},
	stdl_lscroll = {LB, 2,          SO,          ICON_W, ICON_H},
	stdl_uscroll = {RT, SO,         2,           ICON_W, ICON_H},
	stdl_dscroll = {RB, SO,         ICON_H + SO, ICON_W, ICON_H},
	stdl_vslide  = {RT, SO,         ICON_H + 2,  ICON_W, ICON_H},
	stdl_hslide  = {LB, ICON_W+2,   SO,          ICON_W, ICON_H},
	stdl_info    = {LT, 2,          2,           ICON_W, ICON_H},
	stdl_menu    = {LT, 1,      WIDGET_SIZE + 5, ICON_W, ICON_H}
#endif

void calc_work_area(XA_WINDOW *wind)
{
	XA_WIDGET *widg;
	XA_WIDGET_LOCATION rt;		/* HR */
	WidgetCallback *disp;
	short x0, y0;
	short x1, y1;
	short tx0,tx1;
	short slx0, slx1, sly0, sly1;
	short f;

	x0 = wind->r.x + 3;
	y0 = wind->r.y + 2;
	x1 = wind->r.x + wind->r.w - 4;
	y1 = wind->r.y + wind->r.h - 4;
	
	slx0 = x0;
	slx1 = x1 - ICON_W - 1;
	sly0 = y0;
	sly1 = y1 - ICON_H - 1;
	tx0 = wind->r.x + 3;
	tx1 = wind->r.x + wind->r.w -6;
	
	for (f = 0; f < XA_MAX_WIDGETS; f++)
	{
		widg = wind->widgets + f;
		disp = widg->behaviour[XACB_DISPLAY];		/* Get the redraw function for this widget */
		if (disp)					/* If the widget is displayed, include it in the calculation */
		{
			RECT r;
			rp_2_ap(wind, widg, &r);
			rt = widg->loc;					/*  HR */
			switch(widg->loc.relative_type)
			{
			case LT:
				if (r.y + r.h > y0)
					y0 = r.y + r.h;
				if (   (f != XAW_TITLE)
					&& (r.x + r.w + 3 > tx0)
					&& (rt.r.y <= wind->widgets[XAW_TITLE].loc.r.y + wind->widgets[XAW_TITLE].loc.r.h)
					)
					tx0 = r.x + r.w + 3;
				break;
			case LB:
				if (r.y < y1)
					y1 = r.y;
				if ((f != XAW_HSLIDE) && (r.x + r.w + 2 > slx0))
					slx0 = r.x + r.w + 1;
				break;
			case RT:
				if (   (f != XAW_VSLIDE)
					&& (r.y + r.h + 2 > sly0)
					)
					sly0 = r.y + r.h + 1;
				if (   (r.x < x1)
					&& (r.y + r.h > y0)
					)
				{
					x1 = r.x;
					y0 = r.y + r.h;
				}
				if (r.x - 3 < tx1)
					tx1 = r.x - 3;
				break;
			case RB:
				if ((r.x < x1) && (r.y < y1))
				{
					x1 = r.x;
					y1 = r.y;
				}
				if ((f != XAW_HSLIDE) && (r.x < slx1 + 1))
					slx1 = r.x - 1;
				if ((f != XAW_VSLIDE) && (r.y < sly1 + 1))
					sly1 = r.y - 1;
				break;
			case CT:
				if (r.y + r.h > y0)
					y0 = r.y + r.h;
				break;
			case CB:
				if (r.y < y1)
					y1 = r.y;
				break;
			}
		}
	}

#define WMARGIN 3		/* general margin */
#if CORRECT_WORKAREA_SMALL_MISFITS
	{
		void work_area(XA_WINDOW *wi);
		work_area(wind);
	}
#else
	wind->wa.x = x0;		/* Update work area */
	wind->wa.y = y0 + WMARGIN;
	wind->wa.w = x1 - wind->wa.x - SHADOW_OFFSET;
	wind->wa.h = y1 - wind->wa.y - SHADOW_OFFSET;
#endif

	if (!MONO)					/* HR: a simple adjustement */
		wind->wa.x += 1,
		wind->wa.w -= 1;

	wind->widgets[XAW_TITLE].loc.r.w = tx1 - tx0 + 3;		/* Update title bar length  HR: pixel correction */
	wind->widgets[XAW_TITLE].loc.r.x = tx0 - wind->r.x - 1 ;
	if (wind->active_widgets & HSLIDE)						/* Update horizontal slider */
		wind->widgets[XAW_HSLIDE].loc.r.w = slx1 - slx0;
	if (wind->active_widgets & VSLIDE)						/* Update vertical slider */
		wind->widgets[XAW_VSLIDE].loc.r.h = sly1 - sly0;

}
