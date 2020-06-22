/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <OSBIND.H>
#include <VDI.H>
#include <memory.h>
#include "XA_TYPES.H"
#include "XA_DEFS.H"
#include "XA_GLOBL.H"
#include "KERNAL.H"
#include "K_DEFS.H"
#include "BOX3D.H"
#include "KERNAL.H"
#include "DRAG_BOX.H"
#include "GRAF_MOU.H"
#include "MESSAGES.H"
#include "C_WINDOW.H"
#include "RECTLIST.H"
#include "ALL_WIDG.H"
#include "STD_WIDG.H"

/*
	Scroll bar & Slider handlers
*/

/*======================================================
	LEFT SCROLL WIDGET BEHAVIOUR
========================================================*/
short display_lscroll(XA_WINDOW *wind, XA_WIDGET *widg)
{
	short x,y;

	rp_2_ap(wind, widg, &x, &y);	/* Convert relative coords and window location to absolute screen location */

	if (widg->stat==XAW_PLAIN)
		display_widget_bitmap(x, y, widget_bitmap_left);
	else
		display_widget_bitmap(x, y, widget_bitmap_left_s);

	return TRUE;
}

short click_lscroll(XA_WINDOW *wind, XA_WIDGET *widg)
{
	short mx,my,mb;
	
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
short display_rscroll(XA_WINDOW *wind, XA_WIDGET *widg)
{
	short x,y;

	rp_2_ap(wind, widg, &x, &y);	/* Convert relative coords and window location to absolute screen location */

	if (widg->stat==XAW_PLAIN)
		display_widget_bitmap(x, y, widget_bitmap_right);
	else
		display_widget_bitmap(x, y, widget_bitmap_right_s);

	return TRUE;
}

short click_rscroll(XA_WINDOW *wind, XA_WIDGET *widg)
{
	short mx,my,mb;
	
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
short display_uscroll(XA_WINDOW *wind, XA_WIDGET *widg)
{
	short x,y;

	rp_2_ap(wind, widg, &x, &y);	/* Convert relative coords and window location to absolute screen location */

	if (widg->stat==XAW_PLAIN)
		display_widget_bitmap(x, y, widget_bitmap_up);
	else
		display_widget_bitmap(x, y, widget_bitmap_up_s);

	return TRUE;
}

short click_uscroll(XA_WINDOW *wind, XA_WIDGET *widg)
{
	short mx,my,mb;
	
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
short display_dscroll(XA_WINDOW *wind, XA_WIDGET *widg)
{
	short x,y;

	rp_2_ap(wind, widg, &x, &y);	/* Convert relative coords and window location to absolute screen location */

	if (widg->stat==XAW_PLAIN)
		display_widget_bitmap(x, y, widget_bitmap_down);
	else
		display_widget_bitmap(x, y, widget_bitmap_down_s);

	return TRUE;
}

short click_dscroll(XA_WINDOW *wind, XA_WIDGET *widg)
{
	short mx,my,mb;
	
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

/*======================================================
	VERTICAL SLIDER WIDGET BEHAVIOUR
	The slider widgets are slightly more complex than other widgets
	as they have three seperate 'widgets' inside them.
	(I know GEM doesn't have these, but I think they're cool)
========================================================*/
short display_vslide(XA_WINDOW *wind, XA_WIDGET *widg)
{
	short x,y,pnt[6],offs,len;
	XA_SLIDER_WIDGET *sl=(XA_SLIDER_WIDGET*)(widg->stuff);

	rp_2_ap(wind, widg, &x, &y);	/* Convert relative coords and window location to absolute screen location */

	len=(widg->h*sl->length)/1000;
	offs=((widg->h - len)*sl->position)/1000;

	if (widg->stat==XAW_PLAIN)
		vsl_color(V_handle,display.dial_colours.t_l_col);
	else
		vsl_color(V_handle,display.dial_colours.b_r_col);
	
	pnt[0]=x+widg->w; pnt[1]=y+offs;
	pnt[2]=x; pnt[3]=y+offs;
	pnt[4]=x; pnt[5]=y+offs+len;
	v_pline(V_handle,3,pnt);

	if (widg->stat==XAW_PLAIN)
		vsl_color(V_handle,display.dial_colours.b_r_col);
	else
		vsl_color(V_handle,display.dial_colours.t_l_col);

	pnt[2]=x+widg->w; pnt[3]=y+offs+len;
	v_pline(V_handle,3,pnt);
	
	return TRUE;
}

short drag_vslide(XA_WINDOW *wind, XA_WIDGET *widg)
{
	short pmx,pmy,mx,my,mb,x,y,wcy,dy;
	short imx,imy,pnt[4],clip[4],offs,noffs,len,orig_offs;
	XA_SLIDER_WIDGET *sl=(XA_SLIDER_WIDGET*)(widg->stuff);
#if JOHAN_RECTANGLES
	XA_RECT_LIST *rl, *drl;
#else
	XA_RECT_LIST *rl=generate_rect_list(wind);
	XA_RECT_LIST *drl;
#endif

#if JOHAN_RECTANGLES
	if (!(rl = wind->rl_full))
		rl = wind->rl_full = generate_rect_list(wind);
#endif

	rp_2_ap(wind, widg, &x, &y);	/* Convert relative coords and window location to absolute screen location */
	pnt[0]=x; pnt[1]=y;
	pnt[2]=x+widg->w; pnt[3]=y+widg->h;
	vsf_color(V_handle,display.dial_colours.bg_col);
	vsf_interior(V_handle,FIS_SOLID);

	len=(widg->h*sl->length)/1000;
	orig_offs=offs=sl->position;
	wcy=widg->click_y-((widg->h - len)*sl->position)/1000;

	vq_mouse(V_handle, &mb, &imx, &imy);
	pmx=imx; pmy=imy;

	if ((mb)&((wcy>0)&&(wcy<len)))			/* Drag slider */
	{
		do {
			vq_mouse(V_handle, &mb, &mx, &my);
			if (my!=pmy)			/* Has mouse moved? */
			{
				dy=(1000*(my-pmy))/(widg->h-len);
				noffs=offs+dy;
				if (noffs<0) noffs=0;
				if (noffs>1000) noffs=1000;

				if (noffs!=offs)	/* Has the slider moved? */
				{
					v_hide_c(V_handle);
					for(drl=rl; drl; drl=drl->next)				/* Walk the rectangle list */
					{
						clip[0]=drl->x; clip[1]=drl->y;
						clip[2]=drl->x+drl->w; clip[3]=drl->y+drl->h;
						vs_clip(V_handle,1, clip);
						v_bar(V_handle,pnt);
					}
					offs=noffs;
					sl->position=offs;
					for(drl=rl; drl; drl=drl->next)				/* Walk the rectangle list */
					{
						clip[0]=drl->x; clip[1]=drl->y;
						clip[2]=drl->x+drl->w; clip[3]=drl->y+drl->h;
						vs_clip(V_handle,1, clip);
						display_vslide(wind, widg);
					}
					v_show_c(V_handle, 1);
				}
				pmy=my;
			}
		} while(mb);

		sl->position=orig_offs;
		send_app_message(wind->owner, WM_VSLID, 0, wind->handle, offs, 0, 0, 0);
	}else{
		vsf_color(V_handle,display.dial_colours.highlight_col);
		if (wcy<0)					/* Page left */
		{
			send_app_message(wind->owner, WM_ARROWED, 0, wind->handle, WA_UPPAGE, 0, 0, 0);
			pnt[0]=x; pnt[1]=y;
			pnt[2]=x+widg->w; pnt[3]=y+(widg->h - len)*sl->position/1000;
		}else{					/* Page right */
			send_app_message(wind->owner, WM_ARROWED, 0, wind->handle, WA_DNPAGE, 0, 0, 0);
			pnt[0]=x; pnt[1]=y+(widg->h - len)*sl->position/1000+len;
			pnt[2]=x+widg->w; pnt[3]=y+widg->h;
		}
		v_hide_c(V_handle);
		for(drl=rl; drl; drl=drl->next)				/* Walk the rectangle list */
		{
			clip[0]=drl->x; clip[1]=drl->y;
			clip[2]=drl->x+drl->w; clip[3]=drl->y+drl->h;
			vs_clip(V_handle,1, clip);
			v_bar(V_handle,pnt);
			display_vslide(wind, widg);
		}
		v_show_c(V_handle, 1);
		vsf_color(V_handle,display.dial_colours.bg_col);
		if (mb)	/* If the button has been held down, set a pending/active widget for the client */
		{
			set_widget_active(wind, widg, &drag_vslide);
			return FALSE;	/* We return false here so the widget display status stays selected whilst it repeats */
		}
		cancel_widget_active(wind);
	}
	
	v_hide_c(V_handle);
	while(rl)		/* Dispose of the rectangle list & erase the dragged slider */
	{
		drl=rl;
		clip[0]=drl->x; clip[1]=drl->y;
		clip[2]=drl->x+drl->w; clip[3]=drl->y+drl->h;
		vs_clip(V_handle,1, clip);
		v_bar(V_handle,pnt);
		rl=rl->next;
#if JOHAN_RECTANGLES
#else
		free(drl);
#endif
	}				/* We don't need to re-draw the slider as it get's redrawn by the  */
					/* standard widget handler anyway. */
	v_show_c(V_handle, 1);

	return TRUE;
}

/*======================================================
	HORIZONTAL SLIDER WIDGET BEHAVIOUR
	The slider widgets are slightly more complex than other widgets
	as they have three seperate 'widgets' inside them.
	(I know GEM doesn't have these, but I think they're cool)
========================================================*/

short display_hslide(XA_WINDOW *wind, XA_WIDGET *widg)
{
	short x,y,pnt[6],offs,len;
	XA_SLIDER_WIDGET *sl=(XA_SLIDER_WIDGET*)(widg->stuff);

	rp_2_ap(wind, widg, &x, &y);	/* Convert relative coords and window location to absolute screen location */

	len=(widg->w*sl->length)/1000;
	offs=((widg->w - len)*sl->position)/1000;

	if (widg->stat==XAW_PLAIN)
		vsl_color(V_handle,display.dial_colours.t_l_col);
	else
		vsl_color(V_handle,display.dial_colours.b_r_col);
	
	pnt[0]=x+offs; pnt[1]=y+widg->h;
	pnt[2]=x+offs; pnt[3]=y;
	pnt[4]=x+offs+len; pnt[5]=y;
	v_pline(V_handle,3,pnt);

	if (widg->stat==XAW_PLAIN)
		vsl_color(V_handle,display.dial_colours.b_r_col);
	else
		vsl_color(V_handle,display.dial_colours.t_l_col);

	pnt[2]=x+offs+len; pnt[3]=y+widg->h;
	v_pline(V_handle,3,pnt);
	
	return TRUE;
}

short drag_hslide(XA_WINDOW *wind, XA_WIDGET *widg)
{
	short pmx,pmy,mx,my,mb,x,y,wcx;
	short imx,imy,pnt[4],clip[4],offs,noffs,len,dx,orig_offs;
	XA_SLIDER_WIDGET *sl=(XA_SLIDER_WIDGET*)(widg->stuff);
#if JOHAN_RECTANGLES
	XA_RECT_LIST *rl, *drl;
#else
	XA_RECT_LIST *rl=generate_rect_list(wind);
	XA_RECT_LIST *drl;
#endif
 
#if JOHAN_RECTANGLES
	if (!(rl = wind->rl_full))
		rl = wind->rl_full = generate_rect_list(wind);
#endif

	rp_2_ap(wind, widg, &x, &y);	/* Convert relative coords and window location to absolute screen location */
	pnt[0]=x; pnt[1]=y;
	pnt[2]=x+widg->w; pnt[3]=y+widg->h;
	vsf_color(V_handle,display.dial_colours.bg_col);
	vsf_interior(V_handle,FIS_SOLID);

	len=(widg->w*sl->length)/1000;
	orig_offs=offs=sl->position;
	wcx=widg->click_x-((widg->w - len)*sl->position)/1000;

	vq_mouse(V_handle, &mb, &imx, &imy);
	pmx=imx; pmy=imy;

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
					for(drl=rl; drl; drl=drl->next)				/* Walk the rectangle list */
					{
						clip[0]=drl->x; clip[1]=drl->y;
						clip[2]=drl->x+drl->w; clip[3]=drl->y+drl->h;
						vs_clip(V_handle,1, clip);
						v_bar(V_handle,pnt);
					}
					offs=noffs;
					sl->position=offs;
					for(drl=rl; drl; drl=drl->next)				/* Walk the rectangle list */
					{
						clip[0]=drl->x; clip[1]=drl->y;
						clip[2]=drl->x+drl->w; clip[3]=drl->y+drl->h;
						vs_clip(V_handle,1, clip);
						display_hslide(wind, widg);
					}
					v_show_c(V_handle, 1);
				}
				pmx=mx;
			}
		} while(mb);

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
		for(drl=rl; drl; drl=drl->next)				/* Walk the rectangle list */
		{
			clip[0]=drl->x; clip[1]=drl->y;
			clip[2]=drl->x+drl->w; clip[3]=drl->y+drl->h;
			vs_clip(V_handle,1, clip);
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
	while(rl)		/* Dispose of the rectangle list & erase the dragged slider */
	{
		drl=rl;
		clip[0]=drl->x; clip[1]=drl->y;
		clip[2]=drl->x+drl->w; clip[3]=drl->y+drl->h;
		vs_clip(V_handle,1, clip);
		v_bar(V_handle,pnt);
		rl=rl->next;
#if JOHAN_RECTANGLES
#else
		free(drl);
#endif
	}				/* We don't need to re-draw the slider as it get's redrawn by the  */
					/* standard widget handler anyway. */
	v_show_c(V_handle, 1);

	return TRUE;
}
