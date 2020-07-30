/* Live scrolling des Fensterinhaltes */
/*****************************************************************************
*
*											  7UP
*									  Modul: WREALSCR.C
*									 (c) by TheoSoft '92
*
*****************************************************************************/
#include <portab.h>
#include <stdio.h>
#include <aes.h>

#include "windows.h"

#define VERTICAL	1
#define HORIZONTAL 2
#define notnull(a) ((a>0)?(a):(1))

#define EXOB_TYPE(x) (x>>8)
#define WP_YWORK(y) (wp->toolbar?(EXOB_TYPE(wp->toolbar->ob_type)==0?(y-wp->toolbar->ob_height):y):y)
#define WP_HWORK(h) (wp->toolbar?(EXOB_TYPE(wp->toolbar->ob_type)==0?(h+wp->toolbar->ob_height):h):h)
#define WP_XWORK(x) (wp->toolbar?(EXOB_TYPE(wp->toolbar->ob_type)==1?(x-wp->toolbar->ob_width ):x):x)
#define WP_WWORK(w) (wp->toolbar?(EXOB_TYPE(wp->toolbar->ob_type)==1?(w+wp->toolbar->ob_width ):w):w)

extern int boxw,boxh;

int isvertical(WINDOW *wp, int e_mx, int e_my)
{						  /* Slider kann links oder rechts sein */
	int x,y,w,h;
	wind_calc(WC_BORDER,wp->kind,
		wp->xwork,wp->ywork,wp->wwork,wp->hwork,
		&x,&y,&w,&h);
	if(((e_mx>WP_XWORK(wp->xwork)+WP_WWORK(wp->wwork) && e_mx<x+w) || /* rechts */
		 (e_mx>x && e_mx<WP_XWORK(wp->xwork))) &&				 /* links  */
		(e_my>WP_YWORK(wp->ywork)+boxh && e_my<WP_YWORK(wp->ywork)+WP_HWORK(wp->hwork)-boxh) &&
		wp->hsize>WP_HWORK(wp->hwork))
		return(TRUE);					 /* Maus im vert. Slider */
	else
		return(FALSE);
}

int ishorizontal(WINDOW *wp, int e_mx, int e_my)
{									 /* Slider kann nur unten sein */
	int x,y,w,h;
	wind_calc(WC_BORDER,wp->kind,
		wp->xwork,wp->ywork,wp->wwork,wp->hwork,
		&x,&y,&w,&h);
	if((e_my>WP_YWORK(wp->ywork)+WP_HWORK(wp->hwork) && e_my<y+h) &&
		(e_mx>WP_XWORK(wp->xwork)+boxw*2 && e_mx<WP_XWORK(wp->xwork)+WP_WWORK(wp->wwork)-boxw*2) &&
		wp->wsize>WP_WWORK(wp->wwork))
		return(TRUE);					  /* Maus im hor. Slider */
	else
		return(FALSE);
}

void Wrealscroll(WINDOW *wp, int e_mx, int e_my, int dir)
{
	int mouse_click,pos, ret, slsize;
	int mx,my,nx,ny;
	
	wind_update(BEG_MCTRL);
	graf_mouse(M_OFF,NULL);
	Wcursor(wp);
	graf_mouse(M_ON,NULL);
	graf_mouse(FLAT_HAND,NULL);
	nx=mx=e_mx;
	ny=my=e_my;
	if(dir==VERTICAL)
	{
		_wind_get(wp->wihandle,WF_VSLSIZE,&slsize,&ret,&ret,&ret);
/*
		pos=(int)((long)((my-max((boxh+2)/2,(long)(wp->hwork-2*(boxh+2))*slsize/1000L/2))-(wp->ywork+(boxh+2)))*1000L/(long)notnull((long)(wp->hwork-2*(boxh+2))-max((boxh+2),(long)(wp->hwork-2*(boxh+2))*slsize/1000L)));
*/
		pos=(int)((long)((my-max((boxh+2)/2,(long)(WP_HWORK(wp->hwork)-2*(boxh+2))*slsize/1000L/2))-(WP_YWORK(wp->ywork)+(boxh+2)))*1000L/(long)notnull((long)(WP_HWORK(wp->hwork)-2*(boxh+2))-max((boxh+2),(long)(WP_HWORK(wp->hwork)-2*(boxh+2))*slsize/1000L)));
		graf_mouse(M_OFF,NULL);
		Wslide(wp,min(max(0,pos),1000),VSLIDE); /* entsprechend Maus... */
		graf_mouse(M_ON,NULL);
		do
		{
			graf_mkstate(&mx,&my,&mouse_click,&ret); /* Position */
			if(ny!=my && my>WP_YWORK(wp->ywork) && my<WP_YWORK(wp->ywork)+WP_HWORK(wp->hwork))
			{
/*
				pos=(int)((long)((my-max((boxh+2)/2,(long)(wp->hwork-2*(boxh+2))*slsize/1000L/2))-(wp->ywork+(boxh+2)))*1000L/(long)notnull((long)(wp->hwork-2*(boxh+2))-max((boxh+2),(long)(wp->hwork-2*(boxh+2))*slsize/1000L)));
*/
				pos=(int)((long)((my-max((boxh+2)/2,(long)(WP_HWORK(wp->hwork)-2*(boxh+2))*slsize/1000L/2))-(WP_YWORK(wp->ywork)+(boxh+2)))*1000L/(long)notnull((long)(WP_HWORK(wp->hwork)-2*(boxh+2))-max((boxh+2),(long)(WP_HWORK(wp->hwork)-2*(boxh+2))*slsize/1000L)));
				graf_mouse(M_OFF,NULL);
				Wslide(wp,min(max(0,pos),1000),VSLIDE); /* einstellen */
				graf_mouse(M_ON,NULL);
				Wsetrcinfo(wp);
				nx=mx;
				ny=my;
			}
		}
		while(mouse_click); /* solange Maustaste gedrckt */
	}
	else
	{
		_wind_get(wp->wihandle,WF_HSLSIZE,&slsize,&ret,&ret,&ret);
		pos=(int)((long)((mx-max((boxw*2+2)/2,(long)(WP_WWORK(wp->wwork)-2*(boxw*2+2))*slsize/1000L/2))-(WP_XWORK(wp->xwork)+(boxw*2+2)))*1000L/(long)notnull((long)(WP_WWORK(wp->wwork)-2*(boxw*2+2))-max((boxw*2+2),(long)(WP_WWORK(wp->wwork)-2*(boxw*2+2))*slsize/1000L)));
		graf_mouse(M_OFF,NULL);
		Wslide(wp,min(max(0,pos),1000),HSLIDE); /* entsprechend Maus... */
		graf_mouse(M_ON,NULL);
		do
		{
			graf_mkstate(&mx,&my,&mouse_click,&ret); /* Position */
			if(nx!=mx && mx>WP_XWORK(wp->xwork) && mx<WP_XWORK(wp->xwork)+WP_WWORK(wp->wwork))
			{
				pos=(int)((long)((mx-max((boxw*2+2)/2,(long)(WP_WWORK(wp->wwork)-2*(boxw*2+2))*slsize/1000L/2))-(WP_XWORK(wp->xwork)+(boxw*2+2)))*1000L/(long)notnull((long)(WP_WWORK(wp->wwork)-2*(boxw*2+2))-max((boxw*2+2),(long)(WP_WWORK(wp->wwork)-2*(boxw*2+2))*slsize/1000L)));
				graf_mouse(M_OFF,NULL);
				Wslide(wp,min(max(0,pos),1000),HSLIDE); /* einstellen */
				graf_mouse(M_ON,NULL);
				Wsetrcinfo(wp);
				nx=mx;
				ny=my;
			}
		}
		while(mouse_click);
	}
	graf_mouse(ARROW,NULL);
	graf_mouse(M_OFF,NULL);
	Wcursor(wp);
	graf_mouse(M_ON,NULL);
	wind_update(END_MCTRL);
}
/*
		pos=(int)((long)((my-max((boxh+2)/2,(long)(WP_HWORK-2*(boxh+2))*slsize/1000L/2))-(WP_YWORK+(boxh+2)))*1000L/(long)notnull((long)(WP_HWORK-2*(boxh+2))-max((boxh+2),(long)(WP_HWORK-2*(boxh+2))*slsize/1000L)));
*/