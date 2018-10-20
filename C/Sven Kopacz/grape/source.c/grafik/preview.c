#include <grape_h.h>
#include "grape.h"
#include "preview.h"
#include "layer.h"
#include "mask.h"
#include "scale.h"
#include "xrsrc.h"

int BIG_X, BIG_Y, BIG_W, BIG_H, DETAIL_X, DETAIL_Y;

void show_preview(void)
{
	if(!wpreview.open)
	{
		/* Fenster initialisieren */
		xrsrc_gaddr(0, PREVIEW, &opreview, xrsrc);
		wpreview.dinfo=&dpreview;
		dpreview.tree=opreview;

		w_kdial(&wpreview, D_CENTER, MOVE|NAME|BACKDROP|CLOSE|SIZE|FULL);
		wpreview.closed=preview_closed;
		wpreview.sized=preview_sized;
		wpreview.fulled=preview_fulled;

		wpreview.name="[Grape] Preview";
		w_set(&wpreview, NAME);
		if(init_preview_by_size())
		{
			init_preview();
			w_open(&wpreview);
		}
		else
			form_alert(1,"[3][Grape:|FÅr das Preview-Fenster|steht nicht genug Speicher|zur VerfÅgung!][Abbruch]");
	}
	else
		w_top(&wpreview);
}

void new_preview_sel(void)
{/* Aufrufen, wenn Rahmen geÑndert oder umgeschaltet wurde */
	if(wpreview.open)
	{
		init_preview();
		s_redraw(&wpreview);
	}
}

void update_prev_if_in(int x, int y, int w, int h)
{ /* Preview neu darstellen, wenn dieser den Bereich
			mx,my,mw,mh Åebrschneidet */
	GRECT a, b;
	
	if(wpreview.open)
	{
		a.g_x=x; a.g_y=y; a.g_w=w; a.g_h=h;
		b.g_x=BIG_X; b.g_y=BIG_Y; b.g_w=BIG_W; b.g_h=BIG_H;
		if(rc_intersect(&a, &b))
			new_preview_sel();
	}
}

void update_preview(void)
{/* Die Preview-Objekte neu darstellen */
	if(wpreview.open)
	{
		make_nbig();
		make_ndetail();
		w_objc_draw(&wpreview, P_NBIG, 2, sx ,sy, sw, sh);
		w_objc_draw(&wpreview, P_NDETAIL, 2, sx ,sy, sw, sh);
	}
}

void preview_closed(WINDOW *win)
{
	free_preview();
	w_close(win);
	w_kill(win);
}

void preview_fulled(WINDOW *win)
{
	int wx, wy, ww, wh, ow, oh, ax, ay, aw, ah, nochmal;
	
	w_get(win);
	
	/* Maximale Fenstergrîûe */
	ow=BIG_W, oh=BIG_H;

	do
	{
		if(ow < 48) ow=48; if(oh < 48) oh=48;
		ax=win->ax; ay=win->ay;
		aw=ow*2+3*16;
		ah=oh*2+4*16+opreview[P_ACTIZE].ob_height;
		wind_calc(WC_BORDER, win->kind, ax, ay, aw, ah, &wx, &wy, &ww, &wh);
		nochmal=0;
		if(wx+ww > sx+sw) wx=sx+sw-ww;
		if(wy+wh > sy+sh) wy=sy+sh-wh;
		if((wx < sx) || (wy < sy))
		{
			nochmal=1;
			ow/=2;
			oh/=2;
		}
	}while(nochmal);

	if((wx==win->wx) && (wy==win->wy) && (ww==win->ww) && (wh==win->wh))
	{/* Bin schon Fulla */
		wind_get(win->whandle, WF_PREVXYWH, &wx, &wy, &ww, &wh);
		wind_calc(WC_WORK, win->kind, wx, wy, ww, wh, &ax, &ay, &aw, &ah);
		ow=(aw-3*16)/2;
		oh=(ah-(4*16+opreview[P_ACTIZE].ob_height))/2;
	}
	
	if(!new_ob_size(ow, oh))
		return;
	/* Alles klar->Fenstergrîûe anpassen */
	win->wx=wx; win->wy=wy;
	win->ww=ww; win->wh=wh;
	w_set(win, CURR);
	
	/* Objektinhalte anpassen */
	fix_big_start();
	fix_detail();
	make_vbig();
	make_nbig();
	make_vdetail();
	make_ndetail();			
		
	/* Redraw veranlassen */
	s_redraw(win);
}

void preview_sized(WINDOW *win, int *pbuf)
{
	int	dum, nw, nh, ow, oh;
	
	/* Breite/Hîhe geradzahlig machen */
	wind_calc(WC_WORK, win->kind, pbuf[4], pbuf[5], pbuf[6], pbuf[7], &dum, &dum, &nw, &nh);
	nw=(nw>>1)<<1;
	nh=(nh>>1)<<1;

	/* Objektbreite /-hîhe */
	ow=(nw-3*16)/2;
	oh=(nh-(4*16+opreview[P_ACTIZE].ob_height))/2;
	/* Minimal 48x48 */
	if(ow < 48) ow=48;
	if(oh < 48) oh=48;
	
	if(!new_ob_size(ow, oh))
		return;
	/* Alles klar->Fenstergrîûe anpassen */
	win->aw=opreview[0].ob_width;
	win->ah=opreview[0].ob_height;
	w_wcalc(win);
	w_set(win, CURR);
	
	/* Objektinhalte anpassen */
	fix_big_start();
	fix_detail();
	make_vbig();
	make_nbig();
	make_vdetail();
	make_ndetail();			
		
	/* Redraw veranlassen */
	s_redraw(win);
}

int new_ob_size(int w, int h)
{/* Versucht, die Previewobjekte auf die Grîûe w/h zu bringen */
 /* Return: 0=es wurde nix gemacht (z.B. kein Speicher, Alert wurde
 							dann schon gezeigt)
            1=alles ok
 */

	uchar	*m1;
	long	*m2;
	int		ow, oh;
	
	if((w==opreview[P_VBIG].ob_width) && (h==opreview[P_VBIG].ob_height))
		return(0); /* Gleiche Grîûe wie bisher */

	/* Alte Werte merken */
	ow=opreview[P_VBIG].ob_width;
	oh=opreview[P_VBIG].ob_height;
	m1=((U_OB*)(opreview[P_VBIG]_UP_))->color.r;
	m2=((U_OB*)(opreview[P_VBIG]_UP_))->color.table_offset;

	/* Neue Werte setzen */
	set_objects(w, h);
	if(init_preview_by_size())
	{ /* Alte Speicher freigeben */
		free(m1);
		free(m2);
		return(1);
	}
	
	/* Kein Speicher->alten Zustand wieder herstellen */
	set_objects(ow, oh);
	form_alert(1,"[3][Grape:|Nicht genug Speicher um|die Preview-Grîûe zu Ñndern!][Abbruch]");
	return(0);	
}

void set_objects(int w, int h)
{ /* Setzt die Preview-Dialoggrîûen entsprechend der Objekt
     breiten w/h (w,h=Grîûe eines einzelnen Previews!) */
    
	opreview[0].ob_width=w*2+3*16;
	opreview[0].ob_height=h*2+4*16+opreview[P_ACTIZE].ob_height;
	opreview[P_VBIG].ob_x=opreview[P_NBIG].ob_x=16;
	opreview[P_VBIG].ob_y=opreview[P_VDETAIL].ob_y=16;
	opreview[P_VDETAIL].ob_x=opreview[P_NDETAIL].ob_x=w+2*16;
	opreview[P_NBIG].ob_y=opreview[P_NDETAIL].ob_y=h+2*16;

	opreview[P_VBIG].ob_width=opreview[P_VDETAIL].ob_width=
	opreview[P_NBIG].ob_width=opreview[P_NDETAIL].ob_width=w;
	opreview[P_VBIG].ob_height=opreview[P_VDETAIL].ob_height=
	opreview[P_NBIG].ob_height=opreview[P_NDETAIL].ob_height=h;
	
	opreview[P_VTEXT].ob_x=opreview[P_NTEXT].ob_x=0;
	opreview[P_VTEXT].ob_width=opreview[P_NTEXT].ob_width=
	 opreview[0].ob_width;	
	opreview[P_NTEXT].ob_y=h+16;

	opreview[P_ACTIZE].ob_x=(opreview[0].ob_width-opreview[P_ACTIZE].ob_width)/2;
	opreview[P_ACTIZE].ob_y=2*h+3*16;
}

void dial_preview(int ob)
{
	switch(ob)
	{
		case P_ACTIZE:
			if((main_win.id >=0) && first_lay)
				new_preview_sel();
			w_unsel(&wpreview, ob);
		break;
		case P_VBIG:
		case P_FRAME:
			if((main_win.id >=0) && first_lay)
				move_frame();
		break;
		case P_VDETAIL:
			if((main_win.id >=0) && first_lay)
				move_detail();
		break;
	}
}

void init_preview(void)
{
	if((main_win.id >=0) && first_lay)
	{
		init_big_start();
		init_detail();
	}
	else
	{
		opreview[P_FRAME].ob_x=0;
		opreview[P_FRAME].ob_y=0;
		opreview[P_FRAME].ob_width=opreview[P_VBIG].ob_width;
		opreview[P_FRAME].ob_height=opreview[P_VBIG].ob_height;
	}
	make_vbig();
	make_nbig();
	make_vdetail();
	make_ndetail();
}

void move_detail(void)
{
	int mx, my, ox, oy, k, dum;
	int cx, cy;
	int	odx=DETAIL_X, ody=DETAIL_Y;
	
	wind_update(BEG_UPDATE);
	wind_update(BEG_MCTRL);
	graf_mouse(FLAT_HAND, NULL);
	
	
	graf_mkstate(&ox, &oy, &dum, &dum);
	do
	{
		graf_mkstate(&mx, &my, &k, &dum);
		if((my != oy) || (mx != ox))
		{
			cx=DETAIL_X-(mx-ox);
			cy=DETAIL_Y-(my-oy);
			ox=mx; oy=my;
			detail_moved(cx, cy);
		}
	}while(k &3);
	
	graf_mouse(ARROW, NULL);
	wind_update(END_MCTRL);
	wind_update(END_UPDATE);
	
	if((odx != DETAIL_X) || (ody != DETAIL_Y))
	{
		make_ndetail();
		w_objc_draw(&wpreview, P_NDETAIL, 2, sx ,sy, sw, sh);
	}
}

void detail_moved(int x, int y)
{
	int ox, oy, nx, ny, uw, uh;
	long s1;
	
	used_size(&uw, &uh);
	
	if(x+opreview[P_VDETAIL].ob_width > BIG_W)
		x=BIG_W-opreview[P_VDETAIL].ob_width;
	if(y+opreview[P_VDETAIL].ob_height > BIG_H)
		y=BIG_H-opreview[P_VDETAIL].ob_height;
	if(x < 0) x=0; if(y < 0) y=0;
	if((x == DETAIL_X) && (y == DETAIL_Y))
		return;

	DETAIL_X=x;
	DETAIL_Y=y;
	make_vdetail();
	w_objc_draw(&wpreview, P_VDETAIL, 2, sx,sy,sw,sh);	

	objc_offset(opreview, P_FRAME, &ox, &oy);
	/* Frame-Koordinaten */	
	s1=((long)DETAIL_X*uw*10)/(long)BIG_W;
	opreview[P_FRAME].ob_x=(int)((s1+5)/10);	
	s1=((long)DETAIL_Y*uh*10)/(long)BIG_H;
	opreview[P_FRAME].ob_y=(int)((s1+5)/10);	
	objc_offset(opreview, P_FRAME, &nx, &ny);

	if((nx != ox) || (ny != oy))
	{
		/* Alten Frame lîschen */
		w_objc_draw(&wpreview, P_VBIG, 2, ox, oy, opreview[P_FRAME].ob_width, opreview[P_FRAME].ob_height);
		/* Neuen zeichnen */
		w_objc_draw(&wpreview, P_VBIG, 2, nx, ny, opreview[P_FRAME].ob_width, opreview[P_FRAME].ob_height);
	}
}

void move_frame(void)
{
	int mx, my, ox, oy, k, dum;
	int px, py, cx, cy;
	int	odx=DETAIL_X, ody=DETAIL_Y;
	
	wind_update(BEG_UPDATE);
	wind_update(BEG_MCTRL);
	graf_mouse(FLAT_HAND, NULL);
	
	objc_offset(opreview, P_VBIG, &px, &py);
	
	ox=0; oy=0;
	do
	{
		graf_mkstate(&mx, &my, &k, &dum);
		if((my != oy) || (mx != ox))
		{
			ox=mx; oy=my;
			cx=mx-opreview[P_FRAME].ob_width/2-px;
			cy=my-opreview[P_FRAME].ob_height/2-py;
			frame_moved(cx, cy);
		}
	}while(k &3);
	
	graf_mouse(ARROW, NULL);
	wind_update(END_MCTRL);
	wind_update(END_UPDATE);

	if((odx != DETAIL_X) || (ody != DETAIL_Y))
	{
		make_ndetail();
		w_objc_draw(&wpreview, P_NDETAIL, 2, sx ,sy, sw, sh);
	}
}

void frame_moved(int x, int y)
{
	int ox, oy, uw, uh;
	long s1;
	
	used_size(&uw, &uh);
	
	if(x+opreview[P_FRAME].ob_width > uw)
		x=uw-opreview[P_FRAME].ob_width;
	if(y+opreview[P_FRAME].ob_height > uh)
		y=uh-opreview[P_FRAME].ob_height;
	if(x < 0) x=0; if(y < 0) y=0;
	if((x == opreview[P_FRAME].ob_x) && (y==opreview[P_FRAME].ob_y))
		return;

	objc_offset(opreview, P_FRAME, &ox, &oy);
	opreview[P_FRAME].ob_x=x;	
	opreview[P_FRAME].ob_y=y;
	/* Alten Frame lîschen */
	w_objc_draw(&wpreview, P_VBIG, 2, ox, oy, opreview[P_FRAME].ob_width, opreview[P_FRAME].ob_height);
	/* Neuen zeichnen */
	objc_offset(opreview, P_FRAME, &ox, &oy);
	w_objc_draw(&wpreview, P_VBIG, 2, ox, oy, opreview[P_FRAME].ob_width, opreview[P_FRAME].ob_height);

	/* Detail-Koordinaten */
	s1=((long)opreview[P_FRAME].ob_x*(long)BIG_W)/(long)uw;
	if(s1+opreview[P_VDETAIL].ob_width > BIG_W)
		s1=BIG_W-opreview[P_VDETAIL].ob_width;
	if(s1 < 0) s1=0;
	DETAIL_X=(int)s1;
	s1=((long)opreview[P_FRAME].ob_y*(long)BIG_H)/(long)uh;
	if(s1+opreview[P_VDETAIL].ob_height > BIG_H)
		s1=BIG_H-opreview[P_VDETAIL].ob_height;
	if(s1 < 0) s1=0;
	DETAIL_Y=(int)s1;
	make_vdetail();
	w_objc_draw(&wpreview, P_VDETAIL, 2, sx,sy,sw,sh);	
}

void used_size(int *nw, int *nh)
{ /* Die im Preview-BIG-Fenster ausgenutzte Breite/Hîhe */
	int		 hw, hh;
	double h_zu_w;
	
	/* VerhÑltnis */
	h_zu_w=(double)BIG_H/(double)BIG_W;
	
	hw=opreview[P_VBIG].ob_width;
	hh=opreview[P_VBIG].ob_height;
	*nw=BIG_W;
	*nh=BIG_H;

	if(*nw > hw)
	{/* Zuviele Breiten-Pixel */
		*nw=hw;
		*nh=(int)((double)hw*h_zu_w);
	}
	if(*nh > hh)
	{/* Zuviele Hîhenpixel */
		*nh=hh;
		*nw=(int)((double)hh/h_zu_w);
	}
}

void make_vbig(void)
{
	uchar	*sc, *sm, *sy;
	register int		x,y,w;
	register uchar	*dc, *dm, *dy;
	register long		doff;

	int			uw, uh;
	
	/* Inhalt lîschen */	
	w=opreview[P_VBIG].ob_width;
	doff=(long)((U_OB*)(opreview[P_VBIG]_UP_))->color.w-w;

	dc=((U_OB*)(opreview[P_VBIG]_UP_))->color.b;
	dm=((U_OB*)(opreview[P_VBIG]_UP_))->color.r;
	dy=((U_OB*)(opreview[P_VBIG]_UP_))->color.g;

	
	for(y=opreview[P_NBIG].ob_height; y > 0; --y)
	{
		for(x=w; x > 0; --x)
		{
			*dc++=128;
			*dm++=128;
			*dy++=128;
		}
		dc+=doff; dm+=doff; dy+=doff;
	}

	/* War's das schon? */
	if((main_win.id < 0) || (!first_lay)) return;

	used_size(&uw, &uh);

	/* Skalieren */
	doff=(long)((U_OB*)(opreview[P_VBIG]_UP_))->color.w-opreview[P_VBIG].ob_width;
	doff+=opreview[P_VBIG].ob_width-uw;
	dc=((U_OB*)(opreview[P_VBIG]_UP_))->color.b;
	dm=((U_OB*)(opreview[P_VBIG]_UP_))->color.r;
	dy=((U_OB*)(opreview[P_VBIG]_UP_))->color.g;

	if(otoolbar[MASK_ED-1].ob_state & SELECTED)
	{
		sc=sm=sy=act_mask->this.mask;
		if(!(mask_col_tab[act_mask->this.col] & 1))
			sm=NULL;
		if(!(mask_col_tab[act_mask->this.col] & 2))
			sy=NULL;
		if(!(mask_col_tab[act_mask->this.col] & 4))
			sc=NULL;
	}
	else
	{
		sc=act_lay->this.blue;
		sm=act_lay->this.red;
		sy=act_lay->this.yellow;
	}

	if(sc)
		simple_scale_one(sc, dc, BIG_W, BIG_H, uw, uh, 
							 doff, first_lay->this.word_width, BIG_X, BIG_Y);
	else
		ob_clear(dc, uw, uh, doff);
		
	if(sm)						 
		simple_scale_one(sm, dm, BIG_W, BIG_H, uw, uh, 
							 doff, first_lay->this.word_width, BIG_X, BIG_Y);
	else
		ob_clear(dm, uw, uh, doff);

	if(sy)
		simple_scale_one(sy, dy, BIG_W, BIG_H, uw, uh, 
							 doff, first_lay->this.word_width, BIG_X, BIG_Y);
	else
		ob_clear(dy, uw, uh, doff);
}
void ob_clear(uchar *dest, int uw, int uh, long doff)
{
	int x, y;
	
	for(y=uh; y > 0; --y)
	{
		for(x=uw; x > 0; --x)
			*dest++=0;
		dest+=doff;
	}		
}

void make_nbig(void)
{
	register int		x,y,w;
	register uchar	*dc, *dm, *dy, *sc, *sm, *sy;
	register long		doff;
	int			 ww, hh;
	GRECT		 area;
	int			uw, uh;
	
	w=opreview[P_NBIG].ob_width;
	doff=(long)((U_OB*)(opreview[P_NBIG]_UP_))->color.w-w;

	dc=((U_OB*)(opreview[P_NBIG]_UP_))->color.b;
	dm=((U_OB*)(opreview[P_NBIG]_UP_))->color.r;
	dy=((U_OB*)(opreview[P_NBIG]_UP_))->color.g;
	sc=((U_OB*)(opreview[P_VBIG]_UP_))->color.b;
	sm=((U_OB*)(opreview[P_VBIG]_UP_))->color.r;
	sy=((U_OB*)(opreview[P_VBIG]_UP_))->color.g;

	
	for(y=opreview[P_NBIG].ob_height; y > 0; --y)
	{
		for(x=w; x > 0; --x)
		{
			*dc++=*sc++;
			*dm++=*sm++;
			*dy++=*sy++;
		}
		dc+=doff; dm+=doff; dy+=doff;
		sc+=doff; sm+=doff; sy+=doff;
	}

	dc=((U_OB*)(opreview[P_NBIG]_UP_))->color.b;
	dm=((U_OB*)(opreview[P_NBIG]_UP_))->color.r;
	dy=((U_OB*)(opreview[P_NBIG]_UP_))->color.g;
	
	if((prev_func) && (main_win.id >= 0) && (first_lay))
	{
		used_size(&uw, &uh);
		area.g_x=area.g_y=0;
		area.g_w=uw;
		area.g_h=uh;
		ww=((U_OB*)(opreview[P_NBIG]_UP_))->color.w;
		hh=opreview[P_NBIG].ob_height;
		prev_func(dc, dm, dy, ww, hh, &area, 0);
	}
}
void make_vdetail(void)
{
	int				pre_fill=0;
	register int		x,y,w,h;
	register uchar	*sc, *sm, *sy, *dc, *dm, *dy;
	register long		start, soff, doff;

	w=opreview[P_VDETAIL].ob_width;
	h=opreview[P_VDETAIL].ob_height;
	
	dc=((U_OB*)(opreview[P_VDETAIL]_UP_))->color.b;
	dm=((U_OB*)(opreview[P_VDETAIL]_UP_))->color.r;
	dy=((U_OB*)(opreview[P_VDETAIL]_UP_))->color.g;

	/* Keine Hauptdatei? */
	if((main_win.id < 0) || (!first_lay))
	{pre_fill=1; goto MVD_NO_DATA;}

	if(w > BIG_W) {w=BIG_W; pre_fill=1;}
	if(h > BIG_H) {h=BIG_H; pre_fill=1;}
	
	start=(long)((long)(BIG_X+DETAIL_X)+(long)(DETAIL_Y+BIG_Y)*(long)first_lay->this.word_width);
	soff=(long)first_lay->this.word_width-w;
	doff=(long)((U_OB*)(opreview[P_VDETAIL]_UP_))->color.w-w;

	if(otoolbar[MASK_ED-1].ob_state & SELECTED)
	{
		sc=sm=sy=act_mask->this.mask;
		if(!(mask_col_tab[act_mask->this.col] & 1))
			sm=NULL;
		if(!(mask_col_tab[act_mask->this.col] & 2))
			sy=NULL;
		if(!(mask_col_tab[act_mask->this.col] & 4))
			sc=NULL;
	}
	else
	{
		sc=act_lay->this.blue;
		sm=act_lay->this.red;
		sy=act_lay->this.yellow;
	}
	if(sc)sc+=start;
	if(sm)sm+=start;
	if(sy)sy+=start;
	
MVD_NO_DATA:
	if(pre_fill)
	{ /* Es wird nicht alles genutzt->erstmal grau fÅllen */
		w=opreview[P_VDETAIL].ob_width;
		doff=(long)((U_OB*)(opreview[P_VDETAIL]_UP_))->color.w-w;
		for(y=opreview[P_VDETAIL].ob_height; y > 0; --y)
		{
			for(x=w; x > 0; --x)
			{
				*dc++=128;
				*dm++=128;
				*dy++=128;
			}
			dc+=doff; dm+=doff; dy+=doff;
		}
		/* War's das ? */
		if((main_win.id < 0) || (!first_lay)) return;

		if(w > BIG_W) {w=BIG_W; pre_fill=1;}
		doff=(long)((U_OB*)(opreview[P_VDETAIL]_UP_))->color.w-w;
		dc=((U_OB*)(opreview[P_VDETAIL]_UP_))->color.b;
		dm=((U_OB*)(opreview[P_VDETAIL]_UP_))->color.r;
		dy=((U_OB*)(opreview[P_VDETAIL]_UP_))->color.g;
	}
	
	for(y=h; y > 0; --y)
	{
		if(sc)
			for(x=w; x > 0; --x)
				*dc++=*sc++;
		else
			for(x=w; x > 0; --x)
				*dc++=0;

		if(sm)
			for(x=w; x > 0; --x)
				*dm++=*sm++;
		else
			for(x=w; x > 0; --x)
				*dm++=0;

		if(sy)
			for(x=w; x > 0; --x)
				*dy++=*sy++;
		else
			for(x=w; x > 0; --x)
				*dy++=0;

		dc+=doff; dm+=doff; dy+=doff;
		if(sc)sc+=soff;
		if(sm)sm+=soff;
		if(sy)sy+=soff;
	}
}
void make_ndetail(void)
{
	register int		x,y,w;
	register uchar	*dc, *dm, *dy, *sc, *sm, *sy;
	register long		doff;
	GRECT			area;
	int				ww,hh,uw,uh;

	if((main_win.id < 0)||(!first_lay)) goto MND_NO_DATA;
	
	uw=opreview[P_NDETAIL].ob_width;
	uh=opreview[P_NDETAIL].ob_height;
	if(uw > BIG_W) uw=BIG_W;
	if(uh > BIG_H) uh=BIG_H;
	
MND_NO_DATA:
	w=opreview[P_NDETAIL].ob_width;
	doff=(long)((U_OB*)(opreview[P_NDETAIL]_UP_))->color.w-w;

	dc=((U_OB*)(opreview[P_NDETAIL]_UP_))->color.b;
	dm=((U_OB*)(opreview[P_NDETAIL]_UP_))->color.r;
	dy=((U_OB*)(opreview[P_NDETAIL]_UP_))->color.g;
	sc=((U_OB*)(opreview[P_VDETAIL]_UP_))->color.b;
	sm=((U_OB*)(opreview[P_VDETAIL]_UP_))->color.r;
	sy=((U_OB*)(opreview[P_VDETAIL]_UP_))->color.g;
	
	for(y=opreview[P_NDETAIL].ob_height; y > 0; --y)
	{
		for(x=w; x > 0; --x)
		{
			*dc++=*sc++;
			*dm++=*sm++;
			*dy++=*sy++;
		}
		dc+=doff; dm+=doff; dy+=doff;
		sc+=doff; sm+=doff; sy+=doff;
	}

	dc=((U_OB*)(opreview[P_NDETAIL]_UP_))->color.b;
	dm=((U_OB*)(opreview[P_NDETAIL]_UP_))->color.r;
	dy=((U_OB*)(opreview[P_NDETAIL]_UP_))->color.g;
	
	if((prev_func) && (main_win.id >= 0) && (first_lay))
	{
		area.g_x=area.g_y=0;
		area.g_w=uw;
		area.g_h=uh;
		ww=((U_OB*)(opreview[P_NBIG]_UP_))->color.w;
		hh=opreview[P_NDETAIL].ob_height;
		prev_func(dc, dm, dy, ww, hh, &area, 1);
	}
}

void init_detail(void)
{
	DETAIL_X=DETAIL_Y=0;
	opreview[P_FRAME].ob_x=0;
	opreview[P_FRAME].ob_y=0;
	fix_detail();
}

void fix_detail(void)
{ /* Setzt die Auswahlgrîûe so, daû sie dem Anteil 
		 im Detail-Fenster entspricht */
	long	s1, sq;
	int		 uw, uh, x, y;

	x=DETAIL_X;
	y=DETAIL_Y;
	
	if(x+opreview[P_VDETAIL].ob_width > BIG_W)
		x=BIG_W-opreview[P_VDETAIL].ob_width;
	if(y+opreview[P_VDETAIL].ob_height > BIG_H)
		y=BIG_H-opreview[P_VDETAIL].ob_height;
	if(x < 0) x=0; if(y < 0) y=0;

	DETAIL_X=x;
	DETAIL_Y=y;
	
	used_size(&uw, &uh);
	
	/* Framebreite */
	sq=opreview[P_VBIG].ob_width;
	sq*=(long)uw*10;
	sq/=(long)BIG_W;
	sq+=5; sq/=10;
	opreview[P_FRAME].ob_width=(int)sq;
	/* Framehîhe */
	sq=opreview[P_VBIG].ob_height;
	sq*=(long)uh*10;
	sq/=(long)BIG_H;
	sq+=5; sq/=10;
	opreview[P_FRAME].ob_height=(int)sq;

	/* Frame-Koordinaten */	
	s1=((long)DETAIL_X*uw)/(long)BIG_W;
	opreview[P_FRAME].ob_x=(int)s1;
	s1=((long)DETAIL_Y*uh)/(long)BIG_H;
	opreview[P_FRAME].ob_y=(int)s1;	
}

void init_big_start(void)
{ /* Setzt Preview-Anfang auf 0,0 oder Frame */
	int x, y, w, h;
	
	if(frame_data.vis && frame_data.ok)
	{
		x=frame_data.x; y=frame_data.y;
		w=frame_data.w; h=frame_data.h;
	}
	else
	{
		x=y=0;
		w=first_lay->this.width;
		h=first_lay->this.height;
	}

	BIG_X=x; BIG_Y=y;
	BIG_W=w; BIG_H=h;
	fix_big_start();
}

void fix_big_start(void)
{ /* PrÅft, ob Preview nach links/oben versetzt werden muû */
	int x, y;

	x=BIG_X; y=BIG_Y;

	if(x+opreview[P_VBIG].ob_width > first_lay->this.width)
		x=first_lay->this.width-opreview[P_VBIG].ob_width;
	if(y+opreview[P_VBIG].ob_height > first_lay->this.height)
		x=first_lay->this.height-opreview[P_VBIG].ob_height;

	BIG_X=x;
	BIG_Y=y;
}

int init_preview_by_size(void)
{/* Versucht fÅr die Userdef's Speicher entsprechend
    der aktuellen Grîûe zu reservieren
    Return: 1=geklappt
     				0=kein Speicher 
  */
  uchar	*m1, *m2, *m3, *m4, *m5, *m6;
  uchar *m7, *m8, *m9, *m10, *m11, *m12;
	long	*t1, size, a, w;
	
	w=((opreview[P_VBIG].ob_width/16)+1)*16; 
	size=w*(long)opreview[P_VBIG].ob_height;

	t1=(long*)malloc((long)((long)opreview[P_VBIG].ob_height*(long)sizeof(long)));
	m1=malloc(size*12);	
	
	m2=m1+size;	m3=m2+size;	m4=m3+size;	m5=m4+size;	m6=m5+size;
	m7=m6+size;	m8=m7+size;	m9=m8+size;	m10=m9+size; m11=m10+size;
	m12=m11+size;
	
	if((!m1)||(!t1))
	{
		if(m1) free(m1);
		if(t1) free(t1);
		return(0);
	}
	

	for(a=0; a < opreview[P_VBIG].ob_height; ++a)
	{
		t1[a]=(long)((long)w*(long)a);
	}

	((U_OB*)(opreview[P_VBIG]_UP_))->color.w=(int)w;
	((U_OB*)(opreview[P_VBIG]_UP_))->color.r=m1;
	((U_OB*)(opreview[P_VBIG]_UP_))->color.g=m2;
	((U_OB*)(opreview[P_VBIG]_UP_))->color.b=m3;
	((U_OB*)(opreview[P_VBIG]_UP_))->color.table_offset=t1;

	((U_OB*)(opreview[P_VDETAIL]_UP_))->color.w=(int)w;
	((U_OB*)(opreview[P_VDETAIL]_UP_))->color.r=m4;
	((U_OB*)(opreview[P_VDETAIL]_UP_))->color.g=m5;
	((U_OB*)(opreview[P_VDETAIL]_UP_))->color.b=m6;
	((U_OB*)(opreview[P_VDETAIL]_UP_))->color.table_offset=t1;

	((U_OB*)(opreview[P_NBIG]_UP_))->color.w=(int)w;
	((U_OB*)(opreview[P_NBIG]_UP_))->color.r=m7;
	((U_OB*)(opreview[P_NBIG]_UP_))->color.g=m8;
	((U_OB*)(opreview[P_NBIG]_UP_))->color.b=m9;
	((U_OB*)(opreview[P_NBIG]_UP_))->color.table_offset=t1;

	((U_OB*)(opreview[P_NDETAIL]_UP_))->color.w=(int)w;
	((U_OB*)(opreview[P_NDETAIL]_UP_))->color.r=m10;
	((U_OB*)(opreview[P_NDETAIL]_UP_))->color.g=m11;
	((U_OB*)(opreview[P_NDETAIL]_UP_))->color.b=m12;
	((U_OB*)(opreview[P_NDETAIL]_UP_))->color.table_offset=t1;
   
   return(1);
}

void free_preview(void)
{
	free(((U_OB*)(opreview[P_VBIG]_UP_))->color.r);
	free(((U_OB*)(opreview[P_VBIG]_UP_))->color.table_offset);
}