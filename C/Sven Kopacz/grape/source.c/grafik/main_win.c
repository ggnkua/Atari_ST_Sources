#include <grape_h.h>
#include "magicmac.h"
#include "grape.h"
#include "layer.h"
#include "mask.h"
#include "maininit.h"
#include "main_win.h"
#include "ctcppt.h"
#include "ass_dith.h"
#include "mforms.h"
#include "greydith.h"
#include "zoom.h"

typedef struct
{
        long     g_x;    /* x, obere linke Ecke des Rechtecks */
        long     g_y;    /* y, obere linke Ecke des Rechtecks */
        long     g_w;    /* Breite des Rechtecks              */
        long     g_h;    /* Hîhe des Rechtecks                */
} LGRECT;

void o_pic_dith(int wid, int x, int y, int w, int h);

/* Hauptfenster-Verwaltung (Slide/Move/Redraw etc..) */

void full_wsize(int wid)
{
	int pbuf[8], ox, oy, ow, oh, x, y, w, h, dum;
	int	ax, ay, aw, ah;
	
	wind_get(wid, WF_WORKXYWH, &x, &y, &w, &h);
	wind_get(wid, WF_CURRXYWH, &ox, &oy, &ow, &oh);
	
	w=first_lay->this.width/DZOP;
	h=first_lay->this.height/DZOP+otoolbar[0].ob_height+OTBB;

	wind_calc(WC_BORDER, main_win.gadget, x, y, w, h, &x, &y, &w, &h);
	if(x+w > sx+sw) x=sx+sw-w;
	if(x < sx)
	{x=sx; w=sw;}
	if(y+h > sy+sh) y=sy+sh-h;
	if(y < sy)
	{y=sy; h=sh;}
	
	/* Bin ich schon Fulla? */
	wind_get(wid, WF_CURRXYWH, &ax, &ay, &aw, &ah);
	if((x == ax)&&(y == ay)&&(w == aw)&&(h == ah))
	/* Ja..letzte Koordinaten holen */
		wind_get(wid, WF_PREVXYWH, &x, &y, &w, &h);
		
	if((x != ox) || (y != oy))
	{
/*    wind_set(wid, WF_CURRXYWH, x, y, ow, oh); */
    /* Toolbar-Koordinaten anpassen */
    wind_get(wid, WF_WORKXYWH, &(otoolbar[0].ob_x), &(otoolbar[0].ob_y), &dum, &dum);
	}

	pbuf[0]=WM_SIZED;
	pbuf[1]=ap_id;
	pbuf[2]=0;
	pbuf[3]=wid;
	pbuf[4]=x;
	pbuf[5]=y;
	pbuf[6]=w;
	pbuf[7]=h;
	new_wsize(pbuf);
}

void new_warrow(int *pbuf)
{
	int ofs, x,y,w,h, nx=0, ny=0, line_val;
	int	old_y=main_win.oy, old_x=main_win.ox;
	long new_val;


	wind_get(main_win.id, WF_WORKXYWH, &x, &y, &w, &h);
	y+=otoolbar[0].ob_height+OTBB; h-=otoolbar[0].ob_height+OTBB;
	if(w > first_lay->this.width/DZOP) w=first_lay->this.width/DZOP;
	if(h > first_lay->this.height/DZOP) h=first_lay->this.height/DZOP;
	if(T_PRESS) /* Arrows per Wacom bedienen? */
		line_val=((int)asgc->pressure+1)*ZIP;
	else
		line_val=16*ZIP;
		
	switch(pbuf[4])
	{
		case WA_UPPAGE:
			/* Neuer Offset */
			ofs=(main_win.oy < h) ? 0 : main_win.oy-h;
			ny=1;
		break;
		case WA_DNPAGE:
			ofs=main_win.oy+h;
			if(ofs > first_lay->this.height/DZOP-h) ofs=first_lay->this.height/DZOP-h;
			ny=1;
		break;
		case WA_LFPAGE:
			ofs=(main_win.ox < w) ? 0 : main_win.ox-w;
			nx=1;
		break;
		case WA_RTPAGE:
			ofs=main_win.ox+w;
			if(ofs > first_lay->this.width/DZOP-w) ofs=first_lay->this.width/DZOP-w;
			nx=1;
		break;
		
		case WA_UPLINE:
			ofs=(main_win.oy < line_val) ? 0 : main_win.oy-line_val;
			ny=1;
		break;
		case WA_DNLINE:
			ofs=main_win.oy+line_val;
			if(ofs > first_lay->this.height/DZOP-h) ofs=first_lay->this.height/DZOP-h;
			ny=1;
		break;
		case WA_LFLINE:
			ofs=(main_win.ox < line_val) ? 0 : main_win.ox-line_val;
			nx=1;
		break;
		case WA_RTLINE:
			ofs=main_win.ox+line_val;
			if(ofs > first_lay->this.width/DZOP-w) ofs=first_lay->this.width/DZOP-w;
			nx=1;
		break;
	}

	ofs/=ZIP;
	ofs*=ZIP;

	if(ny)
	{
		/* Neue Slider-Position durch Offset berechnen */
		if(ofs != main_win.oy)
		{
			new_val=(long)((long)ofs*(long)1000);
			new_val/=(long)((long)first_lay->this.height/DZOP-(long)h);
			wind_set(main_win.id, WF_VSLIDE, (int)new_val,0,0,0);
			main_win.oy=ofs;
			blit_y(old_y);
		}
	}
	else if(nx)
	{
		/* Neue Slider-Position durch Offset berechnen */
		if(ofs != main_win.ox)
		{
			new_val=(long)((long)ofs*(long)1000);
			new_val/=(long)((long)first_lay->this.width/DZOP-(long)w);
			wind_set(main_win.id, WF_HSLIDE, (int)new_val,0,0,0);
			main_win.ox=ofs;
			blit_x(old_x);
		}
	}

}

void new_wsize_red(int *pbuf, int redraw)
{/* Neue Fenstergrîûe festlegen 
		redraw=0 : OHNE um Inhalt kÅmmern
		redraw=1 : MIT Inhalt-Korrektur
	*/
	int wx, wy, ww, wh;
	int	old_x=main_win.ox; int old_y=main_win.oy, old_w, old_h, dum;
	long new_val;
	
	main_win.ox/=ZIP;main_win.ox*=ZIP;
	main_win.oy/=ZIP;main_win.oy*=ZIP;

	wind_get(main_win.id, WF_WORKXYWH, &dum, &dum, &old_w, &old_h);
	wind_calc(WC_WORK, main_win.gadget, pbuf[4], pbuf[5], pbuf[6], pbuf[7], &wx, &wy, &ww, &wh);
	ww=((ww+zoomin)/ZIP)*ZIP;
	wh=((wh-(+otoolbar[0].ob_height+OTBB)+zoomin)/ZIP)*ZIP+otoolbar[0].ob_height+OTBB;
	if(ww < 66)
		ww=66;
	if(wh < 66+otoolbar[0].ob_height+OTBB)
		wh=66+otoolbar[0].ob_height+OTBB;
	wind_calc(WC_BORDER, main_win.gadget, wx, wy, ww, wh, &pbuf[4], &pbuf[5], &pbuf[6], &pbuf[7]);
	wind_set(main_win.id, WF_CURRXYWH, pbuf[4], pbuf[5], pbuf[6], pbuf[7]);
	wy+=otoolbar[0].ob_height+OTBB; wh-=otoolbar[0].ob_height+OTBB;
	old_h-=otoolbar[0].ob_height+OTBB;
	/* Slider anpassen */
	/* Grîûe */
	new_val=(long)((long)ww*(long)1000); new_val/=(long)first_lay->this.width/(long)DZOP;
	wind_set(main_win.id, WF_HSLSIZE, (int)new_val,0,0,0); 
	new_val=(long)((long)wh*(long)1000); new_val/=(long)first_lay->this.height/(long)DZOP;
	wind_set(main_win.id, WF_VSLSIZE, (int)new_val,0,0,0);

	/* Position */
	new_val=(long)((long)main_win.ox*(long)1000);
	new_val/=(long)((long)first_lay->this.width/(long)DZOP-(long)ww);
	wind_set(main_win.id, WF_HSLIDE, (int)new_val,0,0,0);
	new_val=(long)((long)main_win.oy*(long)1000);
	new_val/=(long)((long)first_lay->this.height/(long)DZOP-(long)wh);
	wind_set(main_win.id, WF_VSLIDE, (int)new_val,0,0,0);
	
	/* Ggf. Offset */
	if(main_win.ox+ww > first_lay->this.width/DZOP)
	{
		main_win.ox=first_lay->this.width/DZOP-ww;
		if(main_win.ox < 0) main_win.ox=0;
		wind_set(main_win.id, WF_HSLIDE, 1000,0,0,0); 
		if(redraw && (main_win.ox != old_x))
			blit_x(old_x);
	}
	if(main_win.oy+wh > first_lay->this.height/DZOP)
	{
		main_win.oy=first_lay->this.height/DZOP-wh;
		if(main_win.oy < 0) main_win.oy=0;
		wind_set(main_win.id, WF_VSLIDE, 1000,0,0,0); 
		if(redraw && (main_win.oy != old_y))
			blit_y(old_y);
	}
	
	/* Layer-Leiste neu zeichnen */
	draw_layob();
}

void new_wsize(int *pbuf)
{
	new_wsize_red(pbuf, 1);
}

void new_wslidy(int sl_pos)
{
	int	 old_y=main_win.oy, x,y,w,h;
	long new_val;
	

	wind_get(main_win.id, WF_WORKXYWH, &x, &y, &w, &h);
	y+=otoolbar[0].ob_height+OTBB; h-=otoolbar[0].ob_height+OTBB;

	wind_set(main_win.id, WF_VSLIDE, sl_pos,0,0,0);
	new_val=(long)((long)first_lay->this.height/DZOP-(long)h); /* Maximal mîgliche Pos. */
	new_val=(long)((long)sl_pos*(long)new_val);
	new_val/=1000l;
	main_win.oy=(int)new_val;

	main_win.oy/=ZIP;main_win.oy*=ZIP;
	
	if(main_win.oy != old_y)
		blit_y(old_y);

}

void new_wslidx(int sl_pos)
{
	int	old_x=main_win.ox, x,y,w,h;
	long new_val;
	

	wind_get(main_win.id, WF_WORKXYWH, &x, &y, &w, &h);
	y+=otoolbar[0].ob_height+OTBB; h-=otoolbar[0].ob_height+OTBB;

	wind_set(main_win.id, WF_HSLIDE, sl_pos,0,0,0);
	new_val=(long)((long)first_lay->this.width/DZOP-(long)w); /* Maxmial mîgliche Pos. */
	new_val=(long)((long)sl_pos*(long)new_val);
	new_val/=1000;
	main_win.ox=(int)new_val;
	
	main_win.ox/=ZIP;main_win.ox*=ZIP;

	if(main_win.ox != old_x)
		blit_x(old_x);

}

void blit_x(int old_x)
{
	GRECT scr, rect, todo, mouse;
	int		ms, d, wid=main_win.id;
	int		blit_dif, blit_dir, xywh[4];
	int		pxy[8];
	MFDB	src, dst;
	
	if(old_x < main_win.ox)
	{
		blit_dir=1; /* Nach links blitten */
		blit_dif=main_win.ox-old_x;
	}
	else
	{
		blit_dir=0; /* Nach rechts blitten */
		blit_dif=old_x-main_win.ox;
	}

	wind_get(wid, WF_WORKXYWH, &todo.g_x, &todo.g_y, &todo.g_w, &todo.g_h);
	todo.g_y+=otoolbar[0].ob_height+OTBB;
	todo.g_h-=otoolbar[0].ob_height+OTBB;
	
	graf_mkstate(&(mouse.g_x), &(mouse.g_y), &d, &d);
	mouse.g_x-=16; /* da Hot-Spot unbekannt muû mit doppeltem */
	mouse.g_y-=16; /* Rechteck gerechnet werden */
	mouse.g_h=mouse.g_w=32;

	wind_update(BEG_UPDATE);
	if (rc_intersect(&todo, &mouse) || wid==main_win.id)
	{
		ms=1;
		graf_mouse(M_OFF, NULL);
	}
	else
		ms=0;


	/* Screen-Grîûe */
	wind_get(0, WF_WORKXYWH, &scr.g_x, &scr.g_y, &scr.g_w, &scr.g_h);
	/* erstes Redraw-Rechteck */
	wind_get(wid, WF_FIRSTXYWH, &rect.g_x, &rect.g_y, &rect.g_w, &rect.g_h);

	while (rect.g_w && rect.g_h)
	{
		if (rc_intersect(&scr, &rect))
		{ /* Liegt im Bildschirm */
			if (rc_intersect(&todo, &rect))
			{ /* Liegt im zu redrawenden Rechteck, rect enthÑlt jetzt */
				/* SchnittflÑche */
				xywh[0]=rect.g_x;
				xywh[1]=rect.g_y;
				xywh[2]=rect.g_x+rect.g_w-1;
				xywh[3]=rect.g_y+rect.g_h-1;

				vs_clip(handle, 1, xywh);
		
				pxy[1]=pxy[5]=rect.g_y;
				pxy[3]=pxy[7]=rect.g_y+rect.g_h-1;

				if(rect.g_w > blit_dif)
				{
					if(blit_dir)
					{/* Nach links */
						pxy[0]=rect.g_x+blit_dif; pxy[4]=rect.g_x;
						pxy[2]=rect.g_x+rect.g_w-1; pxy[6]=rect.g_x+rect.g_w-1+blit_dif;
						rect.g_x=rect.g_x+rect.g_w-blit_dif; rect.g_w=blit_dif;
					}
					else
					{/* Nach rechts */
						pxy[0]=rect.g_x; pxy[4]=rect.g_x+blit_dif;
						pxy[2]=rect.g_x+rect.g_w-1-blit_dif; pxy[6]=rect.g_x+rect.g_w-1;
						rect.g_w=blit_dif;
					}
					src.fd_addr=dst.fd_addr=NULL;
					vro_cpyfm(handle, 3, pxy, &src, &dst);
				}
				
				if(rect.g_w > 0)
				{/* Noch was zu tun */
					pic_dith(wid, rect.g_x, rect.g_y, rect.g_w, rect.g_h, 0);
					if((sel_tool == SSELECT) && (frame_data.vis))
						draw_frame_clip(&rect);
				}

				vs_clip(handle, 0, xywh);
			}
		}
		wind_get(wid, WF_NEXTXYWH, &rect.g_x, &rect.g_y, &rect.g_w, &rect.g_h);

	}

	if (ms)
		graf_mouse(M_ON, NULL);

	wind_update(END_UPDATE);
	
}

void blit_y(int old_y)
{
	GRECT scr, rect, todo, mouse;
	int		ms, d, wid=main_win.id;
	int		blit_dif, blit_dir, xywh[4];
	int		pxy[8];
	MFDB	src, dst;
	
	if(old_y < main_win.oy)
	{
		blit_dir=1; /* Nach oben blitten */
		blit_dif=main_win.oy-old_y;
	}
	else
	{
		blit_dir=0; /* Nach unten blitten */
		blit_dif=old_y-main_win.oy;
	}

	wind_get(wid, WF_WORKXYWH, &todo.g_x, &todo.g_y, &todo.g_w, &todo.g_h);
	todo.g_y+=otoolbar[0].ob_height+OTBB;
	todo.g_h-=otoolbar[0].ob_height+OTBB;
	
	graf_mkstate(&(mouse.g_x), &(mouse.g_y), &d, &d);
	mouse.g_x-=16; /* da Hot-Spot unbekannt muû mit doppeltem */
	mouse.g_y-=16; /* Rechteck gerechnet werden */
	mouse.g_h=mouse.g_w=32;

	wind_update(BEG_UPDATE);
	if (rc_intersect(&todo, &mouse) || wid==main_win.id)
	{
		ms=1;
		graf_mouse(M_OFF, NULL);
	}
	else
		ms=0;

	/* Screen-Grîûe */
	wind_get(0, WF_WORKXYWH, &scr.g_x, &scr.g_y, &scr.g_w, &scr.g_h);
	/* erstes Redraw-Rechteck */
	wind_get(wid, WF_FIRSTXYWH, &rect.g_x, &rect.g_y, &rect.g_w, &rect.g_h);

	while (rect.g_w && rect.g_h)
	{
		if (rc_intersect(&scr, &rect))
		{ /* Liegt im Bildschirm */
			if (rc_intersect(&todo, &rect))
			{ /* Liegt im zu redrawenden Rechteck, rect enthÑlt jetzt */
				/* SchnittflÑche */
				xywh[0]=rect.g_x;
				xywh[1]=rect.g_y;
				xywh[2]=rect.g_x+rect.g_w-1;
				xywh[3]=rect.g_y+rect.g_h-1;
				if (handle > -1)
					vs_clip(handle, 1, xywh);
				
				pxy[0]=pxy[4]=rect.g_x;
				pxy[2]=pxy[6]=rect.g_x+rect.g_w-1;

				if(rect.g_h > blit_dif)
				{
					if(blit_dir)
					{/* Nach oben */
						pxy[1]=rect.g_y+blit_dif; pxy[5]=rect.g_y;
						pxy[3]=rect.g_y+rect.g_h-1; pxy[7]=rect.g_y+rect.g_h-1+blit_dif;
						rect.g_y=rect.g_y+rect.g_h-blit_dif; rect.g_h=blit_dif;
					}
					else
					{/* Nach unten */
						pxy[1]=rect.g_y; pxy[5]=rect.g_y+blit_dif;
						pxy[3]=rect.g_y+rect.g_h-1-blit_dif; pxy[7]=rect.g_y+rect.g_h-1;
						rect.g_h=blit_dif;
					}
					src.fd_addr=dst.fd_addr=NULL;
					vro_cpyfm(handle, 3, pxy, &src, &dst);
				}
				
				if(rect.g_h > 0)
				{
					pic_dith(wid, rect.g_x, rect.g_y, rect.g_w, rect.g_h, 0);
					if((sel_tool == SSELECT) && (frame_data.vis))
						draw_frame_clip(&rect);
				}

				if (handle > -1)
					vs_clip(handle, 0, xywh);
			}
		}
		wind_get(wid, WF_NEXTXYWH, &rect.g_x, &rect.g_y, &rect.g_w, &rect.g_h);

	}

	if (ms)
		graf_mouse(M_ON, NULL);

	wind_update(END_UPDATE);
	
}

void pic_redraw(int wid, int x, int y, int w, int h)
{	/* Liest Rechteck-Liste aus, clipped mit xywh und Screen */
	/* setzt CLIP und dithert. Falls als Redraw-Force */
	/* sollte x,y,w,h auf Screen oder Window Grîûe gesetzt werden */

	GRECT scr, rect, todo, mouse;
	int		xywh[4], ms, d;

	
	todo.g_x=x;
	todo.g_y=y;
	todo.g_w=w;
	todo.g_h=h;
	
	graf_mkstate(&(mouse.g_x), &(mouse.g_y), &d, &d);
	mouse.g_x-=16; /* da Hot-Spot unbekannt muû mit doppeltem */
	mouse.g_y-=16; /* Rechteck gerechnet werden */
	mouse.g_h=mouse.g_w=32;

	wind_update(BEG_UPDATE);
	if (rc_intersect(&todo, &mouse) || (wid==main_win.id))
	{
		ms=1;
		graf_mouse(M_OFF, NULL);
	}
	else
		ms=0;

	/* Screen-Grîûe */
	wind_get(0, WF_WORKXYWH, &scr.g_x, &scr.g_y, &scr.g_w, &scr.g_h);
	/* erstes Redraw-Rechteck */
	wind_get(wid, WF_FIRSTXYWH, &rect.g_x, &rect.g_y, &rect.g_w, &rect.g_h);

	while (rect.g_w && rect.g_h)
	{
		if (rc_intersect(&scr, &rect))
		{ /* Liegt im Bildschirm */
			if (rc_intersect(&todo, &rect))
			{ /* Liegt im zu redrawenden Rechteck, rect enthÑlt jetzt */
				/* SchnittflÑche */
				xywh[0]=rect.g_x;
				xywh[1]=rect.g_y;
				xywh[2]=rect.g_x+rect.g_w-1;
				xywh[3]=rect.g_y+rect.g_h-1;

				vs_clip(handle, 1, xywh);
				
				pic_dith(wid, rect.g_x, rect.g_y, rect.g_w, rect.g_h, 0);
				if((sel_tool == SSELECT) && (frame_data.vis))
					draw_frame_clip(&rect);

				vs_clip(handle, 0, xywh);
			}
		}
		wind_get(wid, WF_NEXTXYWH, &rect.g_x, &rect.g_y, &rect.g_w, &rect.g_h);

	}

	if (ms)
		graf_mouse(M_ON, NULL);

	wind_update(END_UPDATE);
	
}

void floyd_dither(void)
{	/* Dithern mit Fehlerdiffusion */
	register uchar *dest, *c, *m, *y;
	register uchar err_tab[256];
	register unsigned int	 err_c, err_x, ix, *blin, *err_lin;
	register long	 ddif, sdif;
	register int	 xx, yy, dif_x, dif_y;
	long		 start_offset;

	for(xx=0; xx < 256; ++xx)
		err_tab[xx]=((xx-(xx/51)*51)*3)>>3;	

	start_offset=(long)p_width*(long)start_y+(long)start_x;
	c=(uchar*)p_blue+start_offset;
	m=(uchar*)p_red+start_offset;
	y=(uchar*)p_yellow+start_offset;
	
	
	dif_x=end_x-start_x;
	dif_y=end_y-start_y;
	
	sdif=(long)p_width-(long)dif_x-1;
	ddif=(long)screen_width-(long)dif_x-1;

	blin=calloc((p_width+1)*2,1);

	dest=(uchar*)p_screen+rel_start_y*screen_width+rel_start_x;
	for(yy=dif_y; yy > -1; --yy)
	{
		err_lin=blin;
		err_c=0;
		for(xx=dif_x; xx > -1; --xx)
		{
			ix=*c++ + err_c + *err_lin;
			if(ix > 255)
			{
				err_x=err_tab[ix-255];
				ix=255;
			}
			else
				err_x=0;
			err_x+=err_tab[ix];
			err_c=err_x+*err_lin/3;
			*err_lin++=err_x;
			
			*dest++=16+b_table[ix];
		}
		dest+=ddif;
		c+=sdif;
	}
	dest=(uchar*)p_screen+rel_start_y*screen_width+rel_start_x;
	err_lin=blin;
	for(xx=dif_x; xx > -1; --xx)
		*err_lin++=0;
	for(yy=dif_y; yy > -1; --yy)
	{
		err_lin=blin;
		err_c=0;
		for(xx=dif_x; xx > -1; --xx)
		{
			ix=*m++ + err_c + *err_lin;
			if(ix > 255)
			{
				err_x=err_tab[ix-255];
				ix=255;
			}
			else
				err_x=0;
			err_x+=err_tab[ix];
			err_c=err_x+*err_lin/3;
			*err_lin++=err_x;
			
			*dest++ +=r_table[ix];
		}
		dest+=ddif;
		m+=sdif;
	}
	dest=(uchar*)p_screen+rel_start_y*screen_width+rel_start_x;
	err_lin=blin;
	for(xx=dif_x; xx > -1; --xx)
		*err_lin++=0;
	for(yy=dif_y; yy > -1; --yy)
	{
		err_lin=blin;
		err_c=0;
		for(xx=dif_x; xx > -1; --xx)
		{
			ix=*y++ + err_c + *err_lin;
			if(ix > 255)
			{
				err_x=err_tab[ix-255];
				ix=255;
			}
			else
				err_x=0;
			err_x+=err_tab[ix];
			err_c=err_x+*err_lin/3;
			*err_lin++=err_x;
			
			*dest++ +=g_table[ix];
		}
		dest+=ddif;
		y+=sdif;
	}

	free(blin);
}

void near_dither(void)
{ /* éhnlichste Farbe darstellen */
	register uchar *dest, *c, *m, *y;
	register uchar *btable, *rtable, *gtable;
	register long ddif, sdif;
	register int		xx, yy, dif_x, dif_y;
	long		 start_offset;
	
	btable=b_table;
	rtable=r_table;
	gtable=g_table;
	
	start_offset=(long)p_width*(long)start_y+(long)start_x;
	c=(uchar*)p_blue+start_offset;
	m=(uchar*)p_red+start_offset;
	y=(uchar*)p_yellow+start_offset;
	
	dest=(uchar*)p_screen+rel_start_y*screen_width+rel_start_x;
	
	dif_x=end_x-start_x;
	dif_y=end_y-start_y;
	
	sdif=(long)p_width-(long)dif_x-1;
	ddif=(long)screen_width-(long)dif_x-1;

	/*	n=16+(color.red/51)*36+(color.yellow/51)*6+color.blue/51;*/
	for(yy=dif_y; yy > -1; --yy)
	{
		for(xx=dif_x; xx > -1; --xx)
		{
			*dest++=16+btable[*c++]+rtable[*m++]+gtable[*y++];
		}
		dest+=ddif;
		c+=sdif; m+=sdif; y+=sdif;
	}
}

void true_grey(void)
{ /* In Graustufen darstellen */
	register uchar *dest, *c, *m, *y;
	register unsigned int	cnst=255*77+255*151+255*28;
	register unsigned int mc;
	register long ddif, sdif;
	register int		xx, yy, dif_x, dif_y;
	long		 start_offset;
	
	start_offset=(long)p_width*(long)start_y+(long)start_x;
	c=(uchar*)p_blue+start_offset;
	m=(uchar*)p_red+start_offset;
	y=(uchar*)p_yellow+start_offset;
	
	dest=(uchar*)p_screen+rel_start_y*screen_width+rel_start_x;
	
	dif_x=end_x-start_x;
	dif_y=end_y-start_y;
	
	sdif=(long)p_width-(long)dif_x-1;
	ddif=(long)screen_width-(long)dif_x-1;

	/*	n=16+(color.red/51)*36+(color.yellow/51)*6+color.blue/51;*/
	for(yy=dif_y; yy > -1; --yy)
	{
		for(xx=dif_x; xx > -1; --xx)
		{
			mc=cnst-(b_mul_table[*c++]+
							 r_mul_table[*m++]+
							 g_mul_table[*y++]);
			mc=mc >> 8;
			mc=255-mc;
			mc+=16; if(mc > 255) mc=255;

			*dest++=(unsigned char)mc;
		}
		dest+=ddif;
		c+=sdif; m+=sdif; y+=sdif;
	}
}

void solo_pic_dith(int wid, int x, int y, int w, int h, int type)
{
	int	swx, swy, ww, wh, pxy[4];
	GRECT ob, soll;
	LAY_LIST	*l=act_lay;

	wind_get(wid, WF_WORKXYWH, &swx, &swy, &ww, &wh);
	otoolbar[0].ob_x=swx+OTBB/2; otoolbar[0].ob_y=swy+OTBB/2; otoolbar[0].ob_width=ww-OTBB;
	otoolbar[TBR].ob_x=swx+ww-otoolbar[TBR].ob_width-otoolbar[0].ob_x;
	otoolbar[LAYERS].ob_width=otoolbar[TBR].ob_x-otoolbar[TBL].ob_x-otoolbar[TBL].ob_width;
	otoolbar[TBDUM].ob_width=ww;
	swy+=otoolbar[0].ob_height+OTBB; wh-=otoolbar[0].ob_height+OTBB;
	ob.g_x=otoolbar[0].ob_x-OTBB/2; ob.g_y=otoolbar[0].ob_y-OTBB/2;
	ob.g_w=otoolbar[0].ob_width+OTBB; ob.g_h=otoolbar[0].ob_height+OTBB;
	soll.g_x=x; soll.g_y=y; soll.g_w=w; soll.g_h=h;
	/* Toolbar-Teile zeichnen? */
	if(rc_intersect(&soll, &ob))
		objc_draw(otoolbar, 0, 8, ob.g_x, ob.g_y, ob.g_w, ob.g_h);

	/* GrauflÑche rechts zeichnen? */
	ob.g_x=swx+first_lay->this.width/DZOP-main_win.ox;
	ob.g_y=swy;
	ob.g_w=sw;
	ob.g_h=sh;
	if(rc_intersect(&soll, &ob))
	{
		pxy[0]=ob.g_x; pxy[1]=ob.g_y;
		pxy[2]=ob.g_x+ob.g_w-1;
		pxy[3]=ob.g_y+ob.g_h-1;
		vr_recfl(handle, pxy);	
	}
	/* GrauflÑche unten zeichnen? */
	ob.g_x=swx;
	ob.g_y=swy+first_lay->this.height/DZOP-main_win.oy;
	ob.g_w=sw;
	ob.g_h=sh;
	if(rc_intersect(&soll, &ob))
	{
		pxy[0]=ob.g_x; pxy[1]=ob.g_y;
		pxy[2]=ob.g_x+ob.g_w-1;
		pxy[3]=ob.g_y+ob.g_h-1;
		vr_recfl(handle, pxy);	
	}
	
	ob.g_x=swx-main_win.ox; ob.g_w=first_lay->this.width/DZOP;
	ob.g_y=swy; ob.g_h=first_lay->this.height/DZOP;

	if(rc_intersect(&soll, &ob))
	{	
		p_red=l->this.red;
		p_yellow=l->this.yellow;
		p_blue=l->this.blue;
		p_screen=(void*)((long)((long)physbase+(long)swy*(long)roff+(long)swx));
		p_width=(long)l->this.word_width;
		screen_width=roff;
		rel_start_x=ob.g_x-swx;
		rel_start_y=ob.g_y-swy;
		start_x=(ob.g_x-swx+main_win.ox)*MZOP;
		start_y=(ob.g_y-swy+main_win.oy)*MZOP;
		end_x=start_x+(ob.g_w-1)*MZOP;
		end_y=start_y+(ob.g_h-1)*MZOP;
		if(zoomin)
		{
			first_zix=zoomin-(ob.g_x-swx+main_win.ox-start_x*ZIP);
			add_x=ob.g_w-(end_x-start_x)*ZIP-1;
			first_ziy=zoomin-(ob.g_y-swy+main_win.oy-start_y*ZIP);
			add_y=ob.g_h-(end_y-start_y)*ZIP-1;
			off8_x=start_x*ZIP+zoomin-first_zix;
			off8_y=start_y*ZIP+zoomin-first_ziy;
		}
		c_solo=1;
			
		switch(type)
		{
			case 0:
				do_dither();
			break;
			case 1:
				floyd_dither();
			break;
			case 2:
				near_dither();
			break;
			case 3:
				true_grey();
			break;
		}
	}
}

void pic_dith(int wid, int x, int y, int w, int h, int type)
{
	int	swx, swy, ww, wh, pxy[4], a;
	int	ax, ay, ex, ey, x_dif, y_dif;
	GRECT ob, soll, memo;
	LAY_LIST	*l=first_lay;
	unsigned char	*b_red, *b_blue, *b_yellow;
	long size, p_off, l_dif, t_buf;
	
	/* Nicht-Bild-Bereiche Grau hinterlegen->Attribute */
	vsf_interior(handle, 1);
	vsf_color(handle, 9);
	vswr_mode(handle, 1);
	
	if((otoolbar[LAYLED].ob_spec.bitblk->bi_color==3) &&
			!(otoolbar[MASK_VIS-1].ob_state & SELECTED))
	{	/* Nur Solo (ohne Maske) ist an */
		solo_pic_dith(wid, x, y, w, h, type);
		return;
	}

	
	wind_get(wid, WF_WORKXYWH, &swx, &swy, &ww, &wh);
	otoolbar[0].ob_x=swx+OTBB/2; otoolbar[0].ob_y=swy+OTBB/2; otoolbar[0].ob_width=ww-OTBB;
	otoolbar[TBR].ob_x=swx+ww-otoolbar[TBR].ob_width-otoolbar[0].ob_x;
	otoolbar[LAYERS].ob_width=otoolbar[TBR].ob_x-otoolbar[TBL].ob_x-otoolbar[TBL].ob_width;
	otoolbar[TBDUM].ob_width=ww;
	swy+=otoolbar[0].ob_height+OTBB; wh-=otoolbar[0].ob_height+OTBB;
	ob.g_x=otoolbar[0].ob_x-OTBB/2; ob.g_y=otoolbar[0].ob_y-OTBB/2;
	ob.g_w=otoolbar[0].ob_width+OTBB; ob.g_h=otoolbar[0].ob_height+OTBB;

	/* Toolbar-Teile zeichnen? */
	soll.g_x=x; soll.g_y=y; soll.g_w=w; soll.g_h=h;
	if(rc_intersect(&soll, &ob))
		objc_draw(otoolbar, 0, 8, ob.g_x, ob.g_y, ob.g_w, ob.g_h);

	/* GrauflÑche rechts zeichnen? */
	ob.g_x=swx+first_lay->this.width/DZOP-main_win.ox;
	ob.g_y=swy;
	ob.g_w=sw;
	ob.g_h=sh;
	if(rc_intersect(&soll, &ob))
	{
		pxy[0]=ob.g_x; pxy[1]=ob.g_y;
		pxy[2]=ob.g_x+ob.g_w-1;
		pxy[3]=ob.g_y+ob.g_h-1;
		vr_recfl(handle, pxy);	
	}
	/* GrauflÑche unten zeichnen? */
	ob.g_x=swx;
	ob.g_y=swy+first_lay->this.height/DZOP-main_win.oy;
	ob.g_w=sw;
	ob.g_h=sh;
	if(rc_intersect(&soll, &ob))
	{
		pxy[0]=ob.g_x; pxy[1]=ob.g_y;
		pxy[2]=ob.g_x+ob.g_w-1;
		pxy[3]=ob.g_y+ob.g_h-1;
		vr_recfl(handle, pxy);	
	}
	
	/* öberschneidung im aktuellen Zoom feststellen */
	ob.g_x=swx-main_win.ox; ob.g_w=first_lay->this.width/DZOP;
	ob.g_y=swy; ob.g_h=first_lay->this.height/DZOP;
	if(rc_intersect(&soll, &ob))
	{	
		memo=ob;

		/* Zu zeichnenden Bereich auf 1:1 umrechnen */
		ob.g_x=(ob.g_x-swx+main_win.ox)*MZOP;
		ob.g_y=(ob.g_y-swy+main_win.oy)*MZOP;
		if(zoomin)
		{/* Bei Zoomin muû mehr in die Temp-Plane kopiert werden
				weil durch Snappen auf vorletzten Pixel sonst nicht
				genug Daten da sind */
			ob.g_w=ob.g_w/ZIP+2;
			ob.g_h=ob.g_h/ZIP+2;
		}
		else
		{
			ob.g_w*=ZOP;
			ob.g_h*=ZOP;
		}

		/* Zielplanebreite auf 6faches (Kopierroutine arbeitet wegen
			 Optimierung mit 6er-Grenzen) */
		p_width=(((long)(ob.g_w+5))/6)*6;

		/* Nîtige Zielplanegrîûe */
		size=(long)ob.g_h*(long)p_width;
		b_red=(unsigned char*)calloc(size, 1);
		b_blue=(unsigned char*)calloc(size, 1);
		b_yellow=(unsigned char*)calloc(size, 1);
		if((!b_red)||(!b_blue)||(!b_yellow))
		{
			form_alert(1,"[3][Nicht genug Speicher|fÅr Redraw!][Abbruch]");
			if(b_red) free(b_red);
			if(b_blue) free(b_blue);
			if(b_yellow) free(b_yellow);
			return;
		}
		
	  /* Letzte Plane finden, die nicht incl. weiû-deckend ist */
		while(l->next && ((l->this.type != 2) ||
					((l->this.type == 2)	&& !(l->this.visible)))
				 ) l=l->next;

		a=0;
		/* Offset auf Quellplanes */
		p_off=(long)(ob.g_y)*(long)first_lay->this.word_width;
		p_off+=(long)(ob.g_x);

		/* Parameter fÅr Kopierroutine setzen */
		l_dif=first_lay->this.word_width-p_width;

		dst_lines=ob.g_h;
		dst_width=p_width/6;
		dst_2width=p_width/2;
		src_offset=l_dif;

		/* Quellplanes in Zielplane kopieren */ 		
		while(l)
		{
			if(l->this.visible)
			{
				(unsigned char*)src_red=(unsigned char*)l->this.red+p_off; 
				(unsigned char*)src_blue=(unsigned char*)l->this.blue+p_off;
				(unsigned char*)src_yellow=(unsigned char*)l->this.yellow+p_off;
				dst_red=b_red; dst_blue=b_blue; dst_yellow=b_yellow;
				layeradd_mode=0;
				if(l->this.type)
					layeradd_mode|=1;
				if(l->this.visible & DISABLED)
					layeradd_mode|=2;
				layer_add();
				++a;
			}
			l=l->prev;
		}
		
		/* Ggf. Maske dazukopieren */
		if(otoolbar[MASK_VIS-1].ob_state & SELECTED)
		{
			dst_red=b_red; dst_blue=b_blue; dst_yellow=b_yellow;
			if(mask_col_tab[act_mask->this.col] & 1)
				(unsigned char*)src_red=(unsigned char*)act_mask->this.mask+p_off; 
			else
				src_red=NULL;
			if(mask_col_tab[act_mask->this.col] & 2)
				(unsigned char*)src_yellow=(unsigned char*)act_mask->this.mask+p_off; 
			else
				src_yellow=NULL;
			if(mask_col_tab[act_mask->this.col] & 4)
				(unsigned char*)src_blue=(unsigned char*)act_mask->this.mask+p_off; 
			else
				src_blue=NULL;
			layeradd_mode=0;
			layer_add();
			++a;
		}

		ob=memo;

		if(a)
		{
			/* Echte Koordinaten in Source-Planes */
			ex=(ob.g_x-swx+main_win.ox)*MZOP;
			ey=(ob.g_y-swy+main_win.oy)*MZOP;
			/* Vorhergehende x/y-Koordinaten im 8er-Raster */
			ax=(ex>>3)<<3;
			ay=(ey>>3)<<3;
			
			/* Differenz bilden und Planeadressen so zurÅcksetzen, daû x,y
				 auf 8er Grenze beginnen. start_x/start_y werden so gesetzt,
				 daû Ditherroutine erst ab Puffer liest */
			x_dif=ex-ax;
			y_dif=ey-ay;
			/* Offset */
			l_dif=(long)(y_dif)*(p_width+(long)x_dif)+(long)x_dif;
			/* Solo-Dither aus Puffer, Parameter setzen */
			p_red=b_red-l_dif;
			p_yellow=b_yellow-l_dif;
			p_blue=b_blue-l_dif;

			start_x=x_dif;
			start_y=y_dif;
			end_x=start_x+(ob.g_w-1)*MZOP;
			end_y=start_y+(ob.g_h-1)*MZOP;
			c_solo=1;
			l_dif-=x_dif;
			t_buf=table_offset[y_dif];
			table_offset[y_dif]=l_dif;

			p_screen=(void*)((long)((long)physbase+(long)swy*(long)roff+(long)swx));
			screen_width=roff;
			rel_start_x=ob.g_x-swx;
			rel_start_y=ob.g_y-swy;

			if(zoomin)
			{/* Anpassungswerte setzen 
				first_zix/y: Schritte fÅr ersten Pixel (evtl. nicht voller
				Zoom, falls Redraw mitten durch einen Pixel stattfindet)
				add_x/y: Pixel, die hinten angehÑngt werden (falls Redraw
				nicht am Ende eines gezoomten Pixels endet)
				off8_x/y: Ditheroffset fÅr ersten Screen Screenpixel
			*/
				first_zix=zoomin-(rel_start_x-(rel_start_x/ZIP)*ZIP);
				add_x=ob.g_w-(end_x-start_x)*ZIP-1;
				first_ziy=zoomin-(rel_start_y-(rel_start_y/ZIP)*ZIP);
				add_y=ob.g_h-(end_y-start_y)*ZIP-1;
				off8_x=ex*ZIP+zoomin-first_zix;
				off8_y=ey*ZIP+zoomin-first_ziy;
			}

			switch(type)
			{
				case 0:
					do_dither();
				break;
				case 1:
					floyd_dither();
				break;
				case 2:
					near_dither();
				break;
				case 3:
					true_grey();
				break;
			}

			table_offset[y_dif]=t_buf;
			
		}
		else
		{
			/* Weiû hinterlegen */
			pxy[0]=ob.g_x; pxy[1]=ob.g_y;
			pxy[2]=ob.g_x+ob.g_w-1; pxy[3]=ob.g_y+ob.g_h-1;
			vsf_interior(handle, 1);
			vsf_color(handle, 0);
			vswr_mode(handle, 1);
			vr_recfl(handle, pxy);
		}

		free(b_yellow);
		free(b_blue);
		free(b_red);
	}
}

void redraw_pic(void)
{
	int x, y, w, h;

	busy(ON);

	wind_get(main_win.id, WF_WORKXYWH, &x, &y, &w, &h);
	y+=otoolbar[0].ob_height+OTBB; h-=otoolbar[0].ob_height+OTBB;
	pic_redraw(main_win.id, x, y, w, h);	

	busy(OFF);
}

long lmin(long a, long b)
{
	if(a > b) return(b);
	return(a);
}
long lmax(long a, long b)
{
	if(a > b) return(a);
	return(b);
}

int	rc_lintersect(LGRECT *p1, LGRECT *p2)
{ /* SchnittflÑche zweier Rechtecke, p2 wird mit SchnittflÑche */
  /* Åberschrieben, 1=Schnitt, 0=kein Schnitt */
  
	long tx, ty, tw, th;
	
	tw=lmin(p2->g_x+p2->g_w, p1->g_x+p1->g_w);
	th=lmin(p2->g_y+p2->g_h, p1->g_y+p1->g_h);
	tx=lmax(p2->g_x, p1->g_x);
	ty=lmax(p2->g_y, p1->g_y);
	p2->g_x=tx;
	p2->g_y=ty;
	p2->g_w=tw-tx;
	p2->g_h=th-ty;
	return((tw > tx) && (th > ty));
}

void area_redraw(int x, int y, int w, int h)
{
	/* x,y,w,h: Plane-Daten. Wenn irgendwas davon
		 im Fenster sichtbar ist wird ein entsprechender
		 Redraw ausgelîst.
	*/

	LGRECT todo, see;
	int		x2,y2,w2,h2;
	long	xl,yl;
	
	wind_get(main_win.id, WF_WORKXYWH, &x2, &y2, &w2, &h2);
	see.g_x=x2;see.g_y=y2;see.g_w=w2;see.g_h=h2;
	see.g_y+=otoolbar[0].ob_height+OTBB; see.g_h-=otoolbar[0].ob_height+OTBB;

	/* Plane auf Screen umrechnen */
	todo.g_w=(long)((long)w/(long)DZOP);
	todo.g_h=(long)((long)h/(long)DZOP);
	xl=x/DZOP;
	xl-=(long)main_win.ox;
	todo.g_x=xl+see.g_x;
	yl=y/DZOP;
	yl-=(long)main_win.oy;
	todo.g_y=yl+see.g_y;

	/* Clippen */	
	if(rc_lintersect(&see, &todo))
		pic_redraw(main_win.id, (int)todo.g_x, (int)todo.g_y, (int)todo.g_w, (int)todo.g_h);
}

void special_redraw(int type)
{	/* type=1 Floyd_steinberg, 2=NÑchste Farbe, 3=Graustufen*/
	/* Liest Rechteck-Liste aus, clipped mit xywh und Screen */
	/* setzt CLIP und dithert. Falls als Redraw-Force */
	/* sollte x,y,w,h auf Screen oder Window Grîûe gesetzt werden */

	GRECT scr, rect, todo, mouse;
	int		xywh[4], ms, d;

	
	int x, y, w, h, wid;

	busy(ON);
	graf_mouse(BUSYBEE, NULL);
		
	wid=main_win.id;
	
	wind_get(wid, WF_WORKXYWH, &x, &y, &w, &h);
	y+=otoolbar[0].ob_height+OTBB; h-=otoolbar[0].ob_height+OTBB;
	pic_redraw(main_win.id, x, y, w, h);	

	todo.g_x=x;
	todo.g_y=y;
	todo.g_w=w;
	todo.g_h=h;
	
	graf_mkstate(&(mouse.g_x), &(mouse.g_y), &d, &d);
	mouse.g_x-=16; /* da Hot-Spot unbekannt muû mit doppeltem */
	mouse.g_y-=16; /* Rechteck gerechnet werden */
	mouse.g_h=mouse.g_w=32;

	wind_update(BEG_UPDATE);
	if (rc_intersect(&todo, &mouse) || wid==main_win.id)
	{
		ms=1;
		graf_mouse(M_OFF, NULL);
	}
	else
		ms=0;

	/* Screen-Grîûe */
	wind_get(0, WF_WORKXYWH, &scr.g_x, &scr.g_y, &scr.g_w, &scr.g_h);
	/* erstes Redraw-Rechteck */
	wind_get(wid, WF_FIRSTXYWH, &rect.g_x, &rect.g_y, &rect.g_w, &rect.g_h);

	while (rect.g_w && rect.g_h)
	{
		if (rc_intersect(&scr, &rect))
		{ /* Liegt im Bildschirm */
			if (rc_intersect(&todo, &rect))
			{ /* Liegt im zu redrawenden Rechteck, rect enthÑlt jetzt */
				/* SchnittflÑche */
				xywh[0]=rect.g_x;
				xywh[1]=rect.g_y;
				xywh[2]=rect.g_x+rect.g_w-1;
				xywh[3]=rect.g_y+rect.g_h-1;
				if (handle > -1)
					vs_clip(handle, 1, xywh);
				pic_dith(wid, rect.g_x, rect.g_y, rect.g_w, rect.g_h, type);
				if((sel_tool == SSELECT) && (frame_data.vis))
					draw_frame_clip(&rect);

				if (handle > -1)
					vs_clip(handle, 0, xywh);
			}
		}
		wind_get(wid, WF_NEXTXYWH, &rect.g_x, &rect.g_y, &rect.g_w, &rect.g_h);

	}

	if (ms)
		graf_mouse(M_ON, NULL);

	wind_update(END_UPDATE);

	graf_mouse(ARROW, NULL);
	busy(OFF);	

	wait_click();
	redraw_pic();
}

void wait_click(void)
{
	int x, y, w, f;
	
	wind_update(BEG_UPDATE);
	wind_update(BEG_MCTRL);
	
	graf_mouse(USER_DEF, UD_CLICK1);
	
	x=0;
	w=0;
	f=0;
	while(!(x&3))
	{
		graf_mkstate(&y, &y, &x, &y);
		evnt_timer(100,0);
		++w;
		if(w==5)
		{
			w=0;
			if(!f)
			{
				f=1;
				graf_mouse(USER_DEF, UD_CLICK2);
			}
			else
			{
				f=0;
				graf_mouse(USER_DEF, UD_CLICK1);
			}
		}
	}

	graf_mouse(ARROW, NULL);
	
	wind_update(END_MCTRL);
	wind_update(END_UPDATE);
}
