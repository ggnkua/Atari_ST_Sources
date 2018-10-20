#include <grape_h.h>
#include "grape.h"
#include "maininit.h"
#include "zoom.h"
#include "mforms.h"
#include "undo.h"

typedef struct
{
	uchar	*c,*m,*y; 		/* Source planes */
	uchar	*mask;				/* Mask plane */
	int		sx,sy,w,h;		/* Square */
	long	start,ldif;
}ST_MOVER;

static uchar buf1[16*16*3], buf2[16*16*3];
int 		wbuf;

void copy_to_buf(ST_MOVER *msk)
{
	register uchar *ss, *dd;
	register int	ww=msk->w, hh=msk->h;
	register long ldif=msk->ldif;
	register int xc,yc;

	if(wbuf < 2)		
		dd=buf1;
	else
		dd=buf2;
	ss=msk->c+msk->start;
	for(yc=hh; yc > 0; --yc)
	{
		for(xc=ww; xc > 0; --xc)
			*dd++=*ss++;
		ss+=ldif;
	}
	ss=msk->m+msk->start;
	for(yc=hh; yc > 0; --yc)
	{
		for(xc=ww; xc > 0; --xc)
			*dd++=*ss++;
		ss+=ldif;
	}
	ss=msk->y+msk->start;
	for(yc=hh; yc > 0; --yc)
	{
		for(xc=ww; xc > 0; --xc)
			*dd++=*ss++;
		ss+=ldif;
	}
}

void do_mover(ST_MOVER *msk)
{
	register uchar *dd, *ss;
	register int	ww=msk->w, hh=msk->h;
	register long ldif=msk->ldif, start=msk->start;
	register int xc,yc;
	_frame_data oframe=frame_data;
	
	frame_data.x=msk->sx; frame_data.y=msk->sy;
	frame_data.w=msk->w; frame_data.h=msk->h;
	if(!frame_to_undo_mouse(NULL, &(act_mask->this), 0))
		return;	/* Da kam nicht 1 ->Fehler bzw. Abbruch */
	frame_data=oframe;

	copy_to_buf(msk);
	
	/* Von wo zurÅckkopieren? */
	if(wbuf==0)
	{ ss=buf1; wbuf=2;}
	else if(wbuf==1)
	{	ss=buf2; wbuf=2;}
	else
	{	ss=buf1; wbuf=1;}
	
	dd=msk->c+start;
	for(yc=hh; yc > 0; --yc)
	{
		for(xc=ww; xc > 0; --xc)
		{	*dd=((*dd)>>1) + ((*ss++)>>1);++dd;}
		dd+=ldif;
	}
	dd=msk->m+start;
	for(yc=hh; yc > 0; --yc)
	{
		for(xc=ww; xc > 0; --xc)
		{	*dd=((*dd)>>1) + ((*ss++)>>1);++dd;}
		dd+=ldif;
	}
	dd=msk->y+start;
	for(yc=hh; yc > 0; --yc)
	{
		for(xc=ww; xc > 0; --xc)
		{	*dd=((*dd)>>1) + ((*ss++)>>1);++dd;}
		dd+=ldif;
	}
			
}

void mover(int wid)
{
	int				stx, sty, ox, oy, mx, my, k, dum, vx, vy, vw, vh;
	int				dsx, dsy, dex, dey;
	ST_MOVER			msk;
		
	if(!(act_lay))
	{/* Keine aktive Ebene */
		Bell();
		return;
	}

	msk.c=act_lay->this.blue;
	msk.m=act_lay->this.red;
	msk.y=act_lay->this.yellow;
	
	wind_get(wid, WF_WORKXYWH, &stx, &sty, &vw, &vh);
	sty+=(otoolbar[0].ob_height+OTBB);
	/* TatsÑchlich sichtbarer Bereich: */
	vx=main_win.ox*MZOP; vy=main_win.oy*MZOP;
	vw=vw*MZOP; vh=vh*MZOP;
	if(vw > first_lay->this.width) vw=first_lay->this.width;
	if(vh > first_lay->this.height) vh=first_lay->this.height;
	ox=oy=0;
	auto_reset(0);
	graf_mouse(USER_DEF, UD_SLASSO);
	wbuf=0;
	do
	{
		graf_mkstate(&mx, &my, &k, &dum);
		mx-=stx; mx+=main_win.ox;	mx=mx*MZOP;
		my-=sty; my+=main_win.oy;	my=my*MZOP;
		if((mx < vx) || (mx > vx+vw) || (my < vy) || (my > vy+vh))
		{mx=ox; my=oy;} /* AusfÅhrungsversuch vereiteln */
		if((mx != ox)||(my != oy))
		{
			ox=mx; oy=my;
			dsx=mx-8; dsy=my-8; dex=mx+8; dey=my+8;
			if(dsx < 0) dsx=0;
			if(dsy < 0) dsy=0;
			if(dex > vx+vw) dex=vx+vw;
			if(dey > vy+vh) dey=vy+vh;
			msk.sx=dsx; msk.sy=dsy;
			msk.w=dex-dsx; msk.h=dey-dsy;
			msk.ldif=(long)first_lay->this.word_width-(long)msk.w;
			msk.start=(long)first_lay->this.word_width*(long)msk.sy+(long)msk.sx;
			do_mover(&msk);
			area_redraw(msk.sx, msk.sy, msk.w, msk.h);
		}
	}while(k&2);
	graf_mouse(ARROW, NULL);
}
