
/* Balls! (PRG/ACC), (c) 1994/95 K. Koischwitz, C. Grunenberg */

#include "..\keys.c"
#include <float.h>
#include <math.h>
#include "eddilib.h"

#define CNT			15
#define MAXSIZE		320
#define	PXY			MAXSIZE-1
#define GADGETS		NAME|CLOSER|FULLER|MOVER|SIZER|UPARROW|DNARROW|VSLIDE|LFARROW|RTARROW|HSLIDE

WIN *win;
SCROLL scroll={AUTO_SCROLL,0,0,0,0,0,0,0,0,0,MAXSIZE,MAXSIZE,0,0,1,1,0,0,4,4};
GRECT winsize,winmax;

char entry[]="  Balls!\xbf",*title=&entry[2];

long balls_id;
int	bit_handle,pxy[]={0,0,PXY,PXY,0,0,PXY,PXY};
MFDB bitmap;

typedef struct
{
	double x,y,vx,vy;
	int rad,col;
} BALL;

BALL balls[CNT];

long MoveBalls(long p,long t,MKSTATE *m)
{
	BALL *b=balls;
	int i=CNT;
	for (vro_cpyfm(bit_handle,0,pxy,&bitmap,&bitmap);--i>=0;b++)
	{
		b->x += b->vx;
		b->y -= b->vy;
		if ((b->x<b->rad && b->vx<0.0) || (b->x>(double) MAXSIZE-b->rad && b->vx>0.0))
			b->vx =- b->vx;
		if ((b->y<b->rad && b->vy>0.0) || (b->y>(double) MAXSIZE-b->rad && b->vy<0.0))
			b->vy =- b->vy;
		else
			b->vy -= 1;
		if (colors>2)
			vsf_color(bit_handle,b->col);
		v_circle(bit_handle,(int) b->x,(int ) b->y,b->rad);
	}
	redraw_window(win,NULL);
	return(CONT_TIMER);
}

int Rnd(int min,int max)
{
	return(min+rand()%(max-min+1));
}

int	open_bitmap(MFDB *bitmap)
{
	int	cnt=1,handle,in[20],out[128];
	while (cnt<10)
		in[cnt++] = 1;
	in[0] = Getrez()+2;
	in[10] = 2;
	in[11] = in[12] = MAXSIZE;
	for (cnt=13;cnt<20;)
		in[cnt++] = 0;
	handle = grhandle;
	v_opnbm(in,bitmap,&handle,out);
	vs_clip(handle,1,pxy);
	return(handle);
}

void RedrawWindow(int first,WIN *win,GRECT *area)
{
	int x,y,w,h,pxy[8];
	pxy[0] = x = area->g_x-win->work.g_x+(int) scroll.hpos;
	pxy[1] = y = area->g_y-win->work.g_y+(int) scroll.vpos;
	pxy[2] = x+(w=min(MAXSIZE-x,area->g_w)-1);
	pxy[3] = y+(h=min(MAXSIZE-y,area->g_h)-1);
	pxy[4] = x = area->g_x;
	pxy[5] = y = area->g_y;
	pxy[6] = x+w;
	pxy[7] = y+h;
	vro_cpyfm(x_handle,S_ONLY,pxy,&bitmap,screen);
}

void CloseWindow(void)
{
	close_all_windows();
	win = NULL;

	if (balls_id)
		KillTimer(balls_id);
	balls_id = 0;

	if (bit_handle>0)
		v_clsbm(bit_handle);
	bit_handle = 0;

	if (_app)
		exit_gem(TRUE,0);
}

void Alert(char *msg)
{
	xalert(1,1,X_ICN_ERROR,NULL,SYS_MODAL,BUTTONS_RIGHT,TRUE,title,msg,NULL);
}

void OpenWindow(void)
{
	bitmap.fd_addr = 0;
	bitmap.fd_nplanes = 0;
	if ((bit_handle=open_bitmap(&bitmap))>0)
	{
		vswr_mode(bit_handle,MD_XOR);
		vsf_interior(bit_handle,FIS_SOLID);
		vsf_perimeter(bit_handle,0);
		if ((win=open_window(title,NULL,NULL,NULL,GADGETS,TRUE,0,0,&winmax,&winsize,&scroll,RedrawWindow,0,XM_TOP|XM_BOTTOM|XM_SIZE))!=NULL)
		{
			BALL *b=balls;
			int i=CNT;

			balls_id = NewTimer(50,0,MoveBalls);
			for(;--i>=0;b++)
			{
				b->rad = Rnd(5,12);
				b->col = Rnd(1,colors-1);
				b->x = Rnd(b->rad,MAXSIZE-b->rad);
				b->y = Rnd(b->rad,MAXSIZE-b->rad);
				b->vx = (double) Rnd(-30,30)/20.0*b->rad;
				b->vy = (double) Rnd(-30,30)/20.0*b->rad;
			}
			WindowItems(win,SCROLL_KEYS,scroll_keys);
			return;
		}
	}
	Alert("Keine Fenster oder|Offscreen-Bitmaps verfÅgbar!");
	CloseWindow();
}

int Init(XEVENT *e,int av)
{
	return(MU_MESAG);
}

int Messag(XEVENT *ev)
{
	switch (ev->ev_mmgpbuf[0])
	{
	case AC_OPEN:
		if (win==NULL)
			OpenWindow();
		break;
	case AC_CLOSE:
	case AP_TERM:
	case WM_CLOSED:
		CloseWindow();break;
	case WIN_SIZED:
		if (win)
			winsize = win->curr;
		break;
	default:
		return(0);
	}
	return(MU_MESAG);
}

void main()
{
	if (init_gem(NULL,entry,title,"BALLS",0,0,0)==TRUE)
	{
		if (!get_cookie('EdDI',NULL))
		{
			Alert("Benîtige ein VDI, das|Offscreen-Bitmaps unterstÅtzt!");
			exit_gem(TRUE,-1);
		}
		window_border(GADGETS,desk.g_x,desk.g_y,MAXSIZE,MAXSIZE,&winmax);
		winsize = winmax;
		Event_Handler(Init,Messag);
		if (_app)
			OpenWindow();
		Event_Multi(NULL);
	}
	exit(-1);
}
