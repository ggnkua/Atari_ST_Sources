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
#include "KERNAL.H"
#include "GRAF_MOU.H"
#include "C_WINDOW.H"
#include "RECTLIST.H"
#include "ALL_WIDG.H"
#include "SCRLWIDG.H"
#include "CLOSWIDG.H"
#include "RESZWIDG.H"
#include "TITLWIDG.H"
#include "FULLWIDG.H"
#include "INFOWIDG.H"
#include "OBJCWIDG.H"
#include "ICONWIDG.H"
#include "FORM_DO.H"
#include "OBJECTS.H"

/*
	WINDOW WIDGET SET HANDLING ROUTINES
	This module handles the behaviour of the window widgets.
*/

MFDB widget_bm;

/* Convert widget bitmaps (16*16*4bit device independant format) to device specific format */
/* for the current screen device. */
/* Asides from looking pretty, this should make the default widget set work with any */
/* colour screen mode and any graphics card (right up to 24 bits/pixel). */
void fix_bitmaps(void)
{
	MFDB dest;

	widget_bm.fd_w=ICON_W;
	widget_bm.fd_h=ICON_H;
	widget_bm.fd_wdwidth=1;
#if MONO_WIDGETS
	widget_bm.fd_nplanes=1;
#else
	widget_bm.fd_nplanes=4;
#endif
	widget_bm.fd_stand=1;
	dest=widget_bm;
	dest.fd_stand=0;

/* Transform the XaAES logo */
	widget_bm.fd_addr=(void*)bitmap_xaaes16_s;
	dest.fd_addr=(void*)bitmap_xaaes16_s;
	vr_trnfm(V_handle,&widget_bm,&dest);
	widget_bm.fd_addr=(void*)bitmap_xaaes16;
	dest.fd_addr=(void*)bitmap_xaaes16;
	vr_trnfm(V_handle,&widget_bm,&dest);
	
/* Transform the actual window widgets */
	widget_bm.fd_addr=(void*)widget_bitmap_close;
	dest.fd_addr=(void*)widget_bitmap_close;
	vr_trnfm(V_handle,&widget_bm,&dest);
	widget_bm.fd_addr=(void*)widget_bitmap_close_s;
	dest.fd_addr=(void*)widget_bitmap_close_s;
	vr_trnfm(V_handle,&widget_bm,&dest);
	widget_bm.fd_addr=(void*)widget_bitmap_size;
	dest.fd_addr=(void*)widget_bitmap_size;
	vr_trnfm(V_handle,&widget_bm,&dest);
	widget_bm.fd_addr=(void*)widget_bitmap_size_s;
	dest.fd_addr=(void*)widget_bitmap_size_s;
	vr_trnfm(V_handle,&widget_bm,&dest);
	widget_bm.fd_addr=(void*)widget_bitmap_full;
	dest.fd_addr=(void*)widget_bitmap_full;
	vr_trnfm(V_handle,&widget_bm,&dest);
	widget_bm.fd_addr=(void*)widget_bitmap_full_s;
	dest.fd_addr=(void*)widget_bitmap_full_s;
	vr_trnfm(V_handle,&widget_bm,&dest);

	widget_bm.fd_addr=(void*)widget_bitmap_left;
	dest.fd_addr=(void*)widget_bitmap_left;
	vr_trnfm(V_handle,&widget_bm,&dest);
	widget_bm.fd_addr=(void*)widget_bitmap_left_s;
	dest.fd_addr=(void*)widget_bitmap_left_s;
	vr_trnfm(V_handle,&widget_bm,&dest);

	widget_bm.fd_addr=(void*)widget_bitmap_right;
	dest.fd_addr=(void*)widget_bitmap_right;
	vr_trnfm(V_handle,&widget_bm,&dest);
	widget_bm.fd_addr=(void*)widget_bitmap_right_s;
	dest.fd_addr=(void*)widget_bitmap_right_s;
	vr_trnfm(V_handle,&widget_bm,&dest);

	widget_bm.fd_addr=(void*)widget_bitmap_up;
	dest.fd_addr=(void*)widget_bitmap_up;
	vr_trnfm(V_handle,&widget_bm,&dest);
	widget_bm.fd_addr=(void*)widget_bitmap_up_s;
	dest.fd_addr=(void*)widget_bitmap_up_s;
	vr_trnfm(V_handle,&widget_bm,&dest);
	
	widget_bm.fd_addr=(void*)widget_bitmap_down;
	dest.fd_addr=(void*)widget_bitmap_down;
	vr_trnfm(V_handle,&widget_bm,&dest);
	widget_bm.fd_addr=(void*)widget_bitmap_down_s;
	dest.fd_addr=(void*)widget_bitmap_down_s;
	vr_trnfm(V_handle,&widget_bm,&dest);

	widget_bm.fd_addr=(void*)widget_bitmap_iconify;
	dest.fd_addr=(void*)widget_bitmap_iconify;
	vr_trnfm(V_handle,&widget_bm,&dest);
	widget_bm.fd_addr=(void*)widget_bitmap_iconify_s;
	dest.fd_addr=(void*)widget_bitmap_iconify_s;
	vr_trnfm(V_handle,&widget_bm,&dest);

	widget_bm=dest;
}

/* Set the active/pending widget behaviour for a client */
void set_widget_active(XA_WINDOW *wind, XA_WIDGET *widg, WidgetCallback wc)
{
	XA_PENDING_WIDGET *pw;
	short clnt_pid=wind->owner;
		
	pw=(XA_PENDING_WIDGET*)malloc(sizeof(XA_PENDING_WIDGET));
	if (!pw)
		return;

	if (clients[clnt_pid].widget_active)
		free(clients[clnt_pid].widget_active);

	pw->wind=wind;
	pw->widg=widg;
	pw->action=wc;
	clients[clnt_pid].widget_active=pw;
}

/* Cancel the active/pending widget for a client */
void cancel_widget_active(XA_WINDOW *wind)
{
	XA_PENDING_WIDGET *pw;
	short clnt_pid=wind->owner;
	
	pw=clients[clnt_pid].widget_active;
	clients[clnt_pid].widget_active=NULL;
	if (pw) free(pw);
}

/* Convert window relative widget coords to absolute screen coords */
void rp_2_ap(XA_WINDOW *wind, XA_WIDGET *widg, short *x, short *y)
{
	XA_WIDGET_LOCATION rp=widg->loc;
	XA_RELATIVE rt;

	rt=rp.relative_type;

	*x=wind->x;
	*y=wind->y;
	
	switch(rt)
	{
		case LT:
			*x+=rp.x;
			*y+=rp.y;
			break;
		case LB:
			*x+=rp.x;
			*y+= (wind->h - widg->h - rp.y);
			break;
		case RT:
			*x+= (wind->w - widg->w - rp.x);
			*y+=rp.y;
			break;
		case RB:
			*x+= (wind->w - widg->w - rp.x);
			*y+= (wind->h - widg->h - rp.y);
			break;
		case CT:
			*x+= (wind->w/2 - widg->w/2);
			*y+=rp.y;
			break;
		case CB:
			*x+= (wind->w/2 - widg->w/2);
			*y+= (wind->h - widg->h - rp.y);
			break;
	}
}

/*
	Display a 16*16 (16 colour) bitmap for use as a widget.
	I use 16*16 as you've gotta keep icons word aligned, and I use Interface's
	icon editor to design them. It's a nice size......not to big, not to small :)
*/
void display_widget_bitmap(short x, short y, unsigned short *addr)
{
	MFDB screen;
	short p[8];
#if MONO_WIDGETS
	short cols[]={BLACK,WHITE};
#endif

	screen.fd_addr=NULL;
	widget_bm.fd_addr=(void*)addr;

	p[0]=p[1]=0;
	p[2]=ICON_W-1; p[3]=ICON_H-1;
	p[4]=x;	p[5]=y;
	p[6]=x+ICON_W-1; p[7]=y+ICON_H-1;

#if MONO_WIDGETS
	vrt_cpyfm(V_handle,MD_REPLACE,p,&widget_bm,&screen,cols);
#else
	vro_cpyfm(V_handle,S_ONLY,p,&widget_bm,&screen);
#endif
}

/* Calculate the size of the work area for a window and store it */
/* - this is needed because the locations of widgets are relative and */
/*   can be modified. */
/* Actually, this updates all the dynamic sized elements from the standard widget set... */
/* (namely: work area, sliders and title bar) */
void calc_work_area(XA_WINDOW *wind)
{
	XA_WIDGET *widg;
	XA_RELATIVE rt;
	WidgetCallback disp;
	short x0, y0;
	short x1, y1;
	short tx0,tx1;
	short slx0,slx1,sly0,sly1;
	short wx,wy;
	short f;

	x0=wind->x+4; y0=wind->y+4;
	x1=wind->x+wind->w-8; y1=wind->y+wind->h-8;
	
	slx0=x0; slx1=x1-ICON_W-1;
	sly0=y0; sly1=y1-ICON_H-1;
	tx0=wind->x+3; tx1=wind->x+wind->w-6;
	
	for (f=0; f<XA_MAX_WIDGETS; f++)
	{
		widg=wind->widgets+f;
		disp=widg->behaviour[XACB_DISPLAY];		/* get the redraw function for this widget */
		if (disp)	/* If the widget is displayed, include it in the calculation */
		{
			rp_2_ap(wind, widg, &wx, &wy);
			rt=widg->loc.relative_type;
			switch(rt)
			{
				case LT:
					if (wy+widg->h+2>y0)
						y0=wy+widg->h+2;
					if (((f!=XAW_TITLE)&&(wx+widg->w+3>tx0))
						&&(widg->loc.y<=wind->widgets[XAW_TITLE].loc.y+wind->widgets[XAW_TITLE].h))
					{
						tx0=wx+widg->w+3;
					}
					break;
				case LB:
					if (wy<y1+2)
						y1=wy-2;
					if ((f!=XAW_HSLIDE)&&(wx+widg->w+2>slx0))
						slx0=wx+widg->w+1;
					break;
				case RT:
					if ((f!=XAW_VSLIDE)&&(wy+widg->h+2>sly0))
						sly0=wy+widg->h+1;
					if ((wx<x1+2)&&(wy+widg->h+2>y0))
					{
						x1=wx-2;
						y0=wy+widg->h+2;
					}
					if (wx-3<tx1)
						tx1=wx-3;
					break;
				case RB:
					if ((wx<x1+2)&&(wy<y1+2))
					{
						x1=wx-2;
						y1=wy-2;
					}
					if ((f!=XAW_HSLIDE)&&(wx<slx1+1))
						slx1=wx-1;
					if ((f!=XAW_VSLIDE)&&(wy<sly1+1))
						sly1=wy-1;
					break;
				case CT:
					if (wy+widg->h+2>y0)
						y0=wy+widg->h+2;
					break;
				case CB:
					if (wy<y1+2)
						y1=wy-2;
					break;
			}
		}
	}
	wind->wx=x0;							/* Update work area */
	wind->wy=y0;
	wind->ww=x1-x0;
	wind->wh=y1-y0;
	wind->widgets[XAW_TITLE].w=tx1-tx0;		/* Update title bar length */
	wind->widgets[XAW_TITLE].loc.x=tx0-wind->x;
	if (wind->active_widgets&HSLIDE)		/* Update horizontal slider */
	{
		wind->widgets[XAW_HSLIDE].w=slx1-slx0;
	}
	if (wind->active_widgets&VSLIDE)		/* Update vertical slider */
	{
		wind->widgets[XAW_VSLIDE].h=sly1-sly0;
	}
}

/* Define the widget locations using window relative coordinates. */
const XA_WIDGET_LOCATION stdl_close={LT,1,1};
const XA_WIDGET_LOCATION stdl_full={RT,3,1};
const XA_WIDGET_LOCATION stdl_iconify={RT,3,1};
const XA_WIDGET_LOCATION stdl_title={LT,23,3};
const XA_WIDGET_LOCATION stdl_resize={RB,3,3};
const XA_WIDGET_LOCATION stdl_rscroll={RB,ICON_W+3,3};
const XA_WIDGET_LOCATION stdl_lscroll={LB,1,3};
const XA_WIDGET_LOCATION stdl_uscroll={RT,3,1};
const XA_WIDGET_LOCATION stdl_dscroll={RB,3,ICON_H+3};
const XA_WIDGET_LOCATION stdl_vslide={RT,3,ICON_H+2};
const XA_WIDGET_LOCATION stdl_hslide={LB,ICON_W+1,3};
const XA_WIDGET_LOCATION stdl_info={LT,1,1};
const XA_WIDGET_LOCATION stdl_menu={LT,1,WIDGET_SIZE+5};

/* Setup the required 'standard' widgets for a window. These are the ordinary GEM */
/* behaviours. These can be changed for any given window if you want special behaviours. */
void standard_widgets(XA_WINDOW *wind, long tp)
{
	short wd,bh,top_w=wind->w;
	long bit_mask;
	
	wind->active_widgets=tp;				/* Fill in the active widgets summary */
	wind->widgets_on_top=0;
	
	for (wd=0; wd<XA_MAX_WIDGETS; wd++)		/* Initially tag all behaviours as NULL so we can tell */
	{										/* which ones we have actually attatched. */
		for(bh=0; bh<COUNT_XACB; bh++)
		{
			wind->widgets[wd].behaviour[bh]=NULL;
		}
		wind->widgets[wd].stuff=NULL;
	}

	if (tp&CLOSE)
	{
		wind->widgets[XAW_CLOSE].behaviour[XACB_DISPLAY]=&display_close_widget;
		wind->widgets[XAW_CLOSE].behaviour[XACB_CLICK]=&click_close;
		wind->widgets[XAW_CLOSE].behaviour[XACB_DCLICK]=NULL;
		wind->widgets[XAW_CLOSE].behaviour[XACB_DRAG]=NULL;
		wind->widgets[XAW_CLOSE].loc=stdl_close;
		wind->widgets[XAW_CLOSE].stat=XAW_PLAIN;
		wind->widgets[XAW_CLOSE].w=ICON_W;
		wind->widgets[XAW_CLOSE].h=ICON_H;
		top_w-=WIDGET_SIZE;
		wind->widgets_on_top++;
	}

	if (tp&FULLER)
	{
		wind->widgets[XAW_FULL].behaviour[XACB_DISPLAY]=&display_full;
		wind->widgets[XAW_FULL].behaviour[XACB_CLICK]=&click_full;
		wind->widgets[XAW_FULL].behaviour[XACB_DCLICK]=NULL;
		wind->widgets[XAW_FULL].behaviour[XACB_DRAG]=NULL;
		wind->widgets[XAW_FULL].loc=stdl_full;
		wind->widgets[XAW_FULL].stat=XAW_PLAIN;
		wind->widgets[XAW_FULL].w=ICON_W;
		wind->widgets[XAW_FULL].h=ICON_H;
		top_w-=WIDGET_SIZE;
		wind->widgets_on_top++;
	}

	if (tp&SMALLER)
	{
		DIAGS(("SETTING ICONIFY WIDGET\n"));
		wind->widgets[XAW_ICONIFY].behaviour[XACB_DISPLAY]=&display_iconify;
		wind->widgets[XAW_ICONIFY].behaviour[XACB_CLICK]=&click_iconify;
		wind->widgets[XAW_ICONIFY].behaviour[XACB_DCLICK]=NULL;
		wind->widgets[XAW_ICONIFY].behaviour[XACB_DRAG]=NULL;
		wind->widgets[XAW_ICONIFY].loc=stdl_iconify;
		if (tp&FULLER)
		{
			wind->widgets[XAW_ICONIFY].loc.x+=wind->widgets[XAW_FULL].w;
			DIAGS(("shifting for fuller\n"));
		}
		wind->widgets[XAW_ICONIFY].stat=XAW_PLAIN;
		wind->widgets[XAW_ICONIFY].w=ICON_W;
		wind->widgets[XAW_ICONIFY].h=ICON_H;
		top_w-=WIDGET_SIZE;
		wind->widgets_on_top++;
	}

	if (tp&SIZER)
	{
		wind->widgets[XAW_RESIZE].behaviour[XACB_DISPLAY]=&display_resize;
		wind->widgets[XAW_RESIZE].behaviour[XACB_CLICK]=NULL;
		wind->widgets[XAW_RESIZE].behaviour[XACB_DCLICK]=NULL;
		wind->widgets[XAW_RESIZE].behaviour[XACB_DRAG]=&drag_resize;
		wind->widgets[XAW_RESIZE].loc=stdl_resize;
		wind->widgets[XAW_RESIZE].stat=XAW_PLAIN;
		wind->widgets[XAW_RESIZE].w=ICON_W;
		wind->widgets[XAW_RESIZE].h=ICON_H;
	}
	
	if (tp&UPARROW)
	{
		wind->widgets[XAW_UP].behaviour[XACB_DISPLAY]=&display_uscroll;
		wind->widgets[XAW_UP].behaviour[XACB_CLICK]=&click_uscroll;
		wind->widgets[XAW_UP].behaviour[XACB_DCLICK]=NULL;
		wind->widgets[XAW_UP].behaviour[XACB_DRAG]=&click_uscroll;
		wind->widgets[XAW_UP].loc=stdl_uscroll;
		wind->widgets[XAW_UP].stat=XAW_PLAIN;
		wind->widgets[XAW_UP].w=ICON_W;
		wind->widgets[XAW_UP].h=ICON_H;
	}
	if (tp&DNARROW)
	{
		wind->widgets[XAW_DOWN].behaviour[XACB_DISPLAY]=&display_dscroll;
		wind->widgets[XAW_DOWN].behaviour[XACB_CLICK]=&click_dscroll;
		wind->widgets[XAW_DOWN].behaviour[XACB_DCLICK]=NULL;
		wind->widgets[XAW_DOWN].behaviour[XACB_DRAG]=&click_dscroll;
		wind->widgets[XAW_DOWN].loc=stdl_dscroll;
		wind->widgets[XAW_DOWN].stat=XAW_PLAIN;
		wind->widgets[XAW_DOWN].w=ICON_W;
		wind->widgets[XAW_DOWN].h=ICON_H;
	}
	if (tp&LFARROW)
	{
		wind->widgets[XAW_LEFT].behaviour[XACB_DISPLAY]=&display_lscroll;
		wind->widgets[XAW_LEFT].behaviour[XACB_CLICK]=&click_lscroll;
		wind->widgets[XAW_LEFT].behaviour[XACB_DCLICK]=NULL;
		wind->widgets[XAW_LEFT].behaviour[XACB_DRAG]=&click_lscroll;
		wind->widgets[XAW_LEFT].loc=stdl_lscroll;
		wind->widgets[XAW_LEFT].stat=XAW_PLAIN;
		wind->widgets[XAW_LEFT].w=ICON_W;
		wind->widgets[XAW_LEFT].h=ICON_H;
	}
	if (tp&RTARROW)
	{
		wind->widgets[XAW_RIGHT].behaviour[XACB_DISPLAY]=&display_rscroll;
		wind->widgets[XAW_RIGHT].behaviour[XACB_CLICK]=&click_rscroll;
		wind->widgets[XAW_RIGHT].behaviour[XACB_DCLICK]=NULL;
		wind->widgets[XAW_RIGHT].behaviour[XACB_DRAG]=&click_rscroll;
		wind->widgets[XAW_RIGHT].loc=stdl_rscroll;
		wind->widgets[XAW_RIGHT].stat=XAW_PLAIN;
		wind->widgets[XAW_RIGHT].w=ICON_W;
		wind->widgets[XAW_RIGHT].h=ICON_H;
	}

	if (tp&VSLIDE)
	{
		wind->widgets[XAW_VSLIDE].behaviour[XACB_DISPLAY]=&display_vslide;
		wind->widgets[XAW_VSLIDE].behaviour[XACB_CLICK]=&drag_vslide;
		wind->widgets[XAW_VSLIDE].behaviour[XACB_DCLICK]=NULL;
		wind->widgets[XAW_VSLIDE].behaviour[XACB_DRAG]=&drag_vslide;
		wind->widgets[XAW_VSLIDE].loc=stdl_vslide;
		wind->widgets[XAW_VSLIDE].stat=XAW_PLAIN;
		wind->widgets[XAW_VSLIDE].w=ICON_W;
		wind->widgets[XAW_VSLIDE].h=ICON_H;
		wind->widgets[XAW_VSLIDE].stuff=(void*)malloc(sizeof(XA_SLIDER_WIDGET));
		((XA_SLIDER_WIDGET*)wind->widgets[XAW_VSLIDE].stuff)->position=0;
		((XA_SLIDER_WIDGET*)wind->widgets[XAW_VSLIDE].stuff)->length=500;
	}
	
	if (tp&HSLIDE)
	{
		wind->widgets[XAW_HSLIDE].behaviour[XACB_DISPLAY]=&display_hslide;
		wind->widgets[XAW_HSLIDE].behaviour[XACB_CLICK]=&drag_hslide;
		wind->widgets[XAW_HSLIDE].behaviour[XACB_DCLICK]=NULL;
		wind->widgets[XAW_HSLIDE].behaviour[XACB_DRAG]=&drag_hslide;
		wind->widgets[XAW_HSLIDE].loc=stdl_hslide;
		wind->widgets[XAW_HSLIDE].stat=XAW_PLAIN;
		wind->widgets[XAW_HSLIDE].w=ICON_W;
		wind->widgets[XAW_HSLIDE].h=ICON_H;
		wind->widgets[XAW_HSLIDE].stuff=(void*)malloc(sizeof(XA_SLIDER_WIDGET));
		((XA_SLIDER_WIDGET*)wind->widgets[XAW_HSLIDE].stuff)->position=0;
		((XA_SLIDER_WIDGET*)wind->widgets[XAW_HSLIDE].stuff)->length=500;
	}

	if (tp&INFO)
	{
		wind->widgets[XAW_INFO].behaviour[XACB_DISPLAY]=&display_info;
		wind->widgets[XAW_INFO].behaviour[XACB_CLICK]=NULL;
		wind->widgets[XAW_INFO].behaviour[XACB_DCLICK]=NULL;
		wind->widgets[XAW_INFO].behaviour[XACB_DRAG]=NULL;
		wind->widgets[XAW_INFO].loc=stdl_info;
		wind->widgets[XAW_INFO].stat=XAW_PLAIN;
		wind->widgets[XAW_INFO].w=top_w;
		wind->widgets[XAW_INFO].h=display.c_max_h+4;
		wind->widgets[XAW_INFO].stuff=(void*)"Info Bar";		/* Give the window a default info line until the client changes it */
		
		if (tp&(NAME|CLOSE|FULLER))
		{
			if (display.c_max_h+6>ICON_H+2)
				wind->widgets[XAW_INFO].loc.y+=display.c_max_h+6;
			else
				wind->widgets[XAW_INFO].loc.y+=ICON_H+2;
		}
		
		bit_mask=tp&(~(INFO|NAME|CLOSE|FULLER));
		for (wd=0; wd<XA_MAX_WIDGETS; wd++)	/* Shift any widgets we might interfere with */
		{
			if (bit_mask&1L)
			{
				if (((wind->widgets[wd].loc.relative_type==LT)
					||(wind->widgets[wd].loc.relative_type==RT))
					||(wind->widgets[wd].loc.relative_type==CT))
				{
					wind->widgets[wd].loc.y+=wind->widgets[XAW_INFO].h+2;
				}
			}
			bit_mask=bit_mask>>1;
		}
	}

/* do this last as it's a variable size depending on which widgets are on the top bar */
	if (tp&NAME)
	{
		wind->widgets[XAW_TITLE].behaviour[XACB_DISPLAY]=&display_title;
		wind->widgets[XAW_TITLE].behaviour[XACB_CLICK]=&click_title;
		wind->widgets[XAW_TITLE].behaviour[XACB_DCLICK]=&dclick_title;
		wind->widgets[XAW_TITLE].behaviour[XACB_DRAG]=&drag_title;
		wind->widgets[XAW_TITLE].loc=stdl_title;
		wind->widgets[XAW_TITLE].stat=XAW_PLAIN;
		wind->widgets[XAW_TITLE].w=top_w;						/* Actually, this is re-calculated anyway... */
		wind->widgets[XAW_TITLE].h=display.c_max_h+2;
		wind->widgets[XAW_TITLE].stuff=(void*)"XaAES Window";	/* Give the window a default title until the client changes it */
		
		bit_mask=tp&(~(INFO|NAME|CLOSE|FULLER));
		for (wd=0; wd<XA_MAX_WIDGETS; wd++)	/* Shift any widgets we might interfere with */
		{
			if (bit_mask&1L)
			{
				if (((wind->widgets[wd].loc.relative_type==LT)
					||(wind->widgets[wd].loc.relative_type==RT))
					||(wind->widgets[wd].loc.relative_type==CT))
				{
					wind->widgets[wd].loc.y+=wind->widgets[XAW_TITLE].h+2;
				}
			}
			bit_mask=bit_mask>>1;
		}
	}
	
}

/*
	Attach a menu to a window....probably let this be access via wind_set one day
*/
void set_menu_widget(XA_WINDOW *wind, XA_WIDGET_LOCATION loc, OBJECT *obj)
{
	XA_WIDGET_TREE *nt=(XA_WIDGET_TREE*)malloc(sizeof(XA_WIDGET_TREE));

	if (!nt)
		return;

#if GENERATE_DIAGS
	if (!nt)
	{
		DIAGS(("set_menu_widget - unable to allocate widget.\n"));
	}
#endif

	nt->tree=obj;
	
	wind->widgets[XAW_MENU].behaviour[XACB_DISPLAY]=&display_menu_widget;
	wind->widgets[XAW_MENU].behaviour[XACB_CLICK]=&click_menu_widget;
	wind->widgets[XAW_MENU].behaviour[XACB_DCLICK]=NULL;
	wind->widgets[XAW_MENU].behaviour[XACB_DRAG]=NULL;
	wind->widgets[XAW_MENU].loc=loc;
	wind->widgets[XAW_MENU].stat=XAW_PLAIN;
	wind->widgets[XAW_MENU].w=wind->w-4;
	wind->widgets[XAW_MENU].h=display.c_max_h;
	wind->widgets[XAW_MENU].stuff=(void*)nt;

	calc_work_area(wind);			/* Recalculate the work area to include the new menu widget */
}

/*
	Attach a toolbar to a window....probably let this be access via wind_set one day
*/
void set_toolbar_widget(XA_WINDOW *wind, XA_WIDGET_LOCATION loc, OBJECT *obj)
{
	XA_WIDGET_TREE *nt=(XA_WIDGET_TREE*)malloc(sizeof(XA_WIDGET_TREE));

#if GENERATE_DIAGS
	if (!nt)
	{
		DIAGS(("set_toolbar_widget - unable to allocate widget.\n"));
	}
#endif

	nt->tree=obj;
	nt->edit_obj=0;
	
	wind->widgets[XAW_TOOLBAR].behaviour[XACB_DISPLAY]=&display_object_widget;
	wind->widgets[XAW_TOOLBAR].behaviour[XACB_CLICK]=&click_object_widget;
	wind->widgets[XAW_TOOLBAR].behaviour[XACB_DCLICK]=NULL;
	wind->widgets[XAW_TOOLBAR].behaviour[XACB_DRAG]=&click_object_widget;
	wind->widgets[XAW_TOOLBAR].loc=loc;
	wind->widgets[XAW_TOOLBAR].stat=XAW_TOOLBARSTATE;	/* Special status value for toolbars */
	wind->widgets[XAW_TOOLBAR].w=obj->ob_width;
	wind->widgets[XAW_TOOLBAR].h=obj->ob_height;
	wind->widgets[XAW_TOOLBAR].stuff=(void*)nt;

	calc_work_area(wind);			/* Recalculate the work area to include the new menu widget */
}

/* Process widget clicks, and call the appropriate handler routines */
/* This is the main routine for handling window interaction from a users perspective. */
/* Each widget has a set of behaviours (display, drag, click, etc) for each of it's widgets. */
/* - these can be changed on an individual basis, so the close widget of one window might */
/*   call a that sends a 'go back up a directory' message to the desktop, where-as on another */
/*   it may just take the GEM default and send a WM_CLOSED message to the application. */
/* NOTE: If a widget has no XACB_DISPLAY behaviour, it will not recieve clicks (this is */
/* deliberate as it's not a good idea to have invisible widgets that still get clicked */
/* on. */
short do_widgets(XA_WINDOW *w, MOUSE_DATA *md)
{
#if JOHAN_RECTANGLES
	XA_RECT_LIST *rl, *drl;
#else
	XA_RECT_LIST *rl=generate_rect_list(w);
	XA_RECT_LIST *drl;
#endif
	XA_WIDGET *widg, *this_widget=NULL;
	WidgetCallback wc,disp,wdrag;
	short f, clicks, rtn=TRUE;
	short x,y,rx,ry,b;
	
#if JOHAN_RECTANGLES
	if (!(rl = w->rl_full))
		rl = w->rl_full = generate_rect_list(w);
#endif

	clicks=md->clicks;
	if (clicks>2) clicks=2;

	for(f=0; (f<XA_MAX_WIDGETS)&&(this_widget==NULL); f++)		/* Scan through widgets to find the one we clicked on */
	{
		widg=w->widgets+f;
		disp=widg->behaviour[XACB_DISPLAY];		/* get the redraw function for this widget */
		if (disp)
		{
			rp_2_ap(w, widg, &x, &y);	/* Convert relative coords and window location to absolute screen location */

			if ((((md->mx>x)&&(md->my>y))&&(md->mx<x+widg->w))&&(md->my<y+widg->h))
			{
				this_widget=widg;			/* Found a widget - this_widget acts as a flag that says to absorb the click */

				widg->click_x=md->mx-x; 	/* Mark where the click occurred (relative to the widget) */
				widg->click_y=md->my-y;	

											/* We don't auto select & pre-display for a menu or toolbar widget */
				if ((f!=XAW_MENU)&&(f!=XAW_TOOLBAR))
				{
					widg->stat=XAW_SELECTED;	/* Flag the widget as selected */
				
					v_hide_c(V_handle);
					for(drl=rl; drl; drl=drl->next)				/* Walk the rectangle list */
					{
						set_clip(drl->x, drl->y, drl->w, drl->h);
						(*disp)(w, this_widget);	/* display the selected widget */
					}
					v_show_c(V_handle, 1);
				}

				wdrag=this_widget->behaviour[XACB_DRAG];	/* get the click-drag function for this widget */

				vq_mouse(V_handle, &b,&rx,&ry);
				if ((b)&&(wdrag))	/* If the mouse button is still down do a drag (if the widget has a drag behaviour) */
				{
					rtn=(*wdrag)(w, this_widget);
				}else{							/* otherwise, process as a mouse click(s) */
	
					while (b)					/* wait for the mouse to be released */
						vq_mouse(V_handle, &b,&rx,&ry);
				
					if ((((rx>x)&&(ry>y))&&(rx<x+widg->w))&&(ry<y+widg->h))
					{
						wc=this_widget->behaviour[clicks];
						if (wc)							/* If the widget has a click behaviour, call it */
						{
							rtn=(*wc)(w, this_widget);
						}
					}
				}
				
				if (rtn)	/* If the widget click/drag function returned TRUE we reset the state of the widget */
				{
					widg->stat=XAW_PLAIN;			/* Flag the widget as de-selected */
			
					v_hide_c(V_handle);
					for(drl=rl; drl; drl=drl->next)	/* Walk the rectangle list */
					{
						set_clip(drl->x, drl->y, drl->w, drl->h);
						(*disp)(w, this_widget);	/* display the selected widget */
					}
					v_show_c(V_handle, 1);
				}
			}
		}
	}

#if JOHAN_RECTANGLES
#else
	while(rl)	/* Dispose of rectangle list */
	{
		drl=rl;
		rl=rl->next;
		free(drl);
	}
#endif

	if (this_widget) return TRUE;	/* Button click was used up by the GUI */
	
	return FALSE;					/* Button click can be passed on to applications as we didn't use it for a widget */
}
