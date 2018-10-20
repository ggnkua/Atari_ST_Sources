#include <grape_h.h>
#include "magicmac.h"
#include "grape.h"
#include "penedit.h"
#include "maininit.h"
#include "coled.h"
#include "layer.h"
#include "scale.h"

/* Rechteck aufblinken lassen */
void form_blink(int times, int speed, int x, int y, int w, int h)
{
	int	pxy[4];
	
	vsf_interior(handle, 1);
	vsf_color(handle, 1);
	vsf_perimeter(handle, 0);
	vswr_mode(handle, 3);
	pxy[0]=x; pxy[1]=y;
	pxy[2]=x+w-1; pxy[3]=y+h-1;
	
	while(times--)
	{
		v_bar(handle, pxy);
		evnt_timer(speed,0);
		v_bar(handle, pxy);
		evnt_timer(speed,0);
	}
}

/* Userdef's und zusÑtzliche Ob-Fns (Slide, Bar) */

void c_used_size(int *nw, int *nh)
{ /* Die im Parameter-Fenster ausgenutzte Breite/Hîhe fÅr's Farbfeld*/
	int		 hw, hh;
	double h_zu_w;
	
	/* VerhÑltnis */
	h_zu_w=(double)first_lay->this.height/(double)first_lay->this.width;
	
	hw=otool[GPPCOL].ob_width;
	hh=otool[GPPCOL].ob_height;
	*nw=first_lay->this.width;
	*nh=first_lay->this.height;

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

void fill_col_by_lay(LAYER *l)
{/* FÅllt die Stiftfarbe im Parameter-Fenster mit skalierter
		Source-Ebene */
	uchar	*sc, *sm, *sy;
	register int		x,y,w;
	register uchar	*dc, *dm, *dy;
	register long		doff;

	int			uw, uh;
	
	c_used_size(&uw, &uh);
	
	/* Inhalt lîschen */	
	w=otool[GPPCOL].ob_width;
	doff=(long)((U_OB*)(otool[GPPCOL]_UP_))->color.w-w;

	dc=((U_OB*)(otool[GPPCOL]_UP_))->color.b;
	dm=((U_OB*)(otool[GPPCOL]_UP_))->color.r;
	dy=((U_OB*)(otool[GPPCOL]_UP_))->color.g;

	
	for(y=otool[GPPCOL].ob_height; y > 0; --y)
	{
		for(x=w; x > 0; --x)
		{
			*dc++=128;
			*dm++=128;
			*dy++=128;
		}
		dc+=doff; dm+=doff; dy+=doff;
	}

	/* Skalieren */
	doff=(long)((U_OB*)(otool[GPPCOL]_UP_))->color.w-otool[GPPCOL].ob_width;
	doff+=otool[GPPCOL].ob_width-uw;
	dc=((U_OB*)(otool[GPPCOL]_UP_))->color.b;
	dm=((U_OB*)(otool[GPPCOL]_UP_))->color.r;
	dy=((U_OB*)(otool[GPPCOL]_UP_))->color.g;

	sc=l->blue;
	sm=l->red;
	sy=l->yellow;

	simple_scale_one(sc, dc, first_lay->this.width, first_lay->this.height, uw, uh, 
							 doff, first_lay->this.word_width, 0, 0);
		
	simple_scale_one(sm, dm, first_lay->this.width, first_lay->this.height, uw, uh, 
							 doff, first_lay->this.word_width, 0, 0);

	simple_scale_one(sy, dy, first_lay->this.width, first_lay->this.height, uw, uh, 
							 doff, first_lay->this.word_width, 0, 0);
		
}

void fill_col_ob(void)
{/* FÅllt die Stiftfarbe im Parameter-Fenster */
	LAYER *l;
	int a, b;

	if(pen.source_lay_id > -1)
	{/* Source ist keine Farbe sondern Ebene */
		if((l=find_layer_id(pen.source_lay_id)) != NULL)
		{
			fill_col_by_lay(l);
			return;
		}
		/* Ebene gibts nicht mehr */
		pen.source_lay_id=-1;
	}
	
	b=((U_OB*)(otool[GPPCOL]_UP_))->color.w*otool[GPPCOL].ob_height;
	
	for(a=0; a < b; ++a)
	{
		((U_OB*)(otool[GPPCOL]_UP_))->color.r[a]=pen.col.red;
		((U_OB*)(otool[GPPCOL]_UP_))->color.g[a]=pen.col.yellow;
		((U_OB*)(otool[GPPCOL]_UP_))->color.b[a]=pen.col.blue;
	}
	
	set_grey(&pen.col);
}

void fill_ed_col_ob(int c, int m, int y)
{
	int a, b;

	b=((U_OB*)(ocoled[GCECOL]_UP_))->color.w*ocoled[GCECOL].ob_height;
	
	for(a=0; a < b; ++a)
	{
		((U_OB*)(ocoled[GCECOL]_UP_))->color.r[a]=m;
		((U_OB*)(ocoled[GCECOL]_UP_))->color.g[a]=y;
		((U_OB*)(ocoled[GCECOL]_UP_))->color.b[a]=c;
	}
}

void fill_usr_col_ob(OBJECT *tree, int ob, int c, int m, int y)
{
	int a, b;

	b=((U_OB*)(tree[ob]_UP_))->color.w*tree[ob].ob_height;
	
	for(a=0; a < b; ++a)
	{
		((U_OB*)(tree[ob]_UP_))->color.r[a]=m;
		((U_OB*)(tree[ob]_UP_))->color.g[a]=y;
		((U_OB*)(tree[ob]_UP_))->color.b[a]=c;
	}
}

int cdecl user_ob(PARMBLK	*pblk)
{
/* Userdef's */
	if(pblk->pb_parm==0) return(0);
	switch( ((U_OB*)pblk->pb_parm)->type)
	{
		case 1:
			return(plgraph(pblk));
		case 2:
			return(sm_graph(pblk));
		case 3:
		case 4:
			return(col_field(pblk));
		default:
			return(0);
	}
}

int cdecl col_field(PARMBLK *pblk)
{
	int			pxy[10];
	long		*o_off;
	GRECT 	todo, clip;
	COL_OB	*col_ob;

	col_ob=&(((U_OB*)pblk->pb_parm)->color);

	/* Rahmen zeichnen */
	vswr_mode(handle, 1);
	vsl_color(handle, 1);
	vsl_width(handle, 1);

	pxy[0]=pblk->pb_xc;
	pxy[1]=pblk->pb_yc;
	pxy[2]=pblk->pb_xc+pblk->pb_wc-1;
	pxy[3]=pblk->pb_yc+pblk->pb_hc-1;
	vs_clip(handle, 1, pxy);

	vsl_color(handle, 1);
	if(((U_OB*)pblk->pb_parm)->type==4)
	{
		/* Preview-Felder bekommen auûen schwarzen Rand */
		pxy[8]=pxy[6]=pxy[0]=pblk->pb_x-1;
		pxy[9]=pxy[3]=pxy[1]=pblk->pb_y-1;
		pxy[4]=pxy[2]=pblk->pb_x+pblk->pb_w;
		pxy[7]=pxy[5]=pblk->pb_y+pblk->pb_h;
		v_pline(handle, 5, pxy);
		todo.g_x=pblk->pb_x;
		todo.g_y=pblk->pb_y;
		todo.g_w=pblk->pb_w;
		todo.g_h=pblk->pb_h;
	}
	else
	{
		/* Farbfeld bekommt innen schwarzen+weiûen Rand */
		pxy[8]=pxy[6]=pxy[0]=pblk->pb_x;
		pxy[9]=pxy[3]=pxy[1]=pblk->pb_y;
		pxy[4]=pxy[2]=pblk->pb_x+pblk->pb_w-1;
		pxy[7]=pxy[5]=pblk->pb_y+pblk->pb_h-1;
		v_pline(handle, 5, pxy);
		vsl_color(handle, 0);
		pxy[8]=pxy[6]=pxy[0]=pblk->pb_x+1;
		pxy[9]=pxy[3]=pxy[1]=pblk->pb_y+1;
		pxy[4]=pxy[2]=pblk->pb_x+pblk->pb_w-2;
		pxy[7]=pxy[5]=pblk->pb_y+pblk->pb_h-2;
		v_pline(handle, 5, pxy);
		todo.g_x=pblk->pb_x+2;
		todo.g_y=pblk->pb_y+2;
		todo.g_w=pblk->pb_w-4;
		todo.g_h=pblk->pb_h-4;
	}
	
	vs_clip(handle, 0, pxy);

	/* FarbflÑche dithern */
	clip.g_x=pblk->pb_xc;
	clip.g_y=pblk->pb_yc;
	clip.g_w=pblk->pb_wc;
	clip.g_h=pblk->pb_hc;

	if(!rc_intersect(&clip, &todo))
		return(0);
	
	p_red=col_ob->r;
	p_yellow=col_ob->g;
	p_blue=col_ob->b;
	p_width=(long)col_ob->w;
	p_screen=(void*)((long)((long)physbase+(long)pblk->pb_y*(long)roff+(long)pblk->pb_x));
	screen_width=roff;

	start_x=rel_start_x=todo.g_x-(pblk->pb_x);
	start_y=rel_start_y=todo.g_y-(pblk->pb_y);
	end_x=start_x+todo.g_w-1;
	end_y=start_y+todo.g_h-1;

	o_off=table_offset;
	table_offset=col_ob->table_offset;
	do_harmless();
	table_offset=o_off;

	return(pblk->pb_currstate & DISABLED);
}

int cdecl sm_graph(PARMBLK *pblk)
{
	int	pxy[10], x, x0, step, *field, y;
	/* Kurve in kleinem Rahmen zeichnen */
	
	/* Rahmen zeichnen */
	switch(pblk->pb_obj)
	{
		case GPSIZE:
			field=pgp.plp.y;
		break;
		case GPCOL:
			field=NULL;
		break;
		case GPRED:
			field=pgp.plr.y;
		break;
		case GPYELLOW:
			field=pgp.plg.y;
		break;
		case GPBLUE:
			field=pgp.plb.y;
		break;
	}
		
	vswr_mode(handle, 1);
	vsl_color(handle, 1);
	vsl_width(handle, 1);

	vsf_color(handle, 8);
	vsf_interior(handle, 1);
	vsf_perimeter(handle, 0);

	pxy[0]=pblk->pb_xc;
	pxy[1]=pblk->pb_yc;
	pxy[2]=pblk->pb_xc+pblk->pb_wc-1;
	pxy[3]=pblk->pb_yc+pblk->pb_hc-1;
	vs_clip(handle, 1, pxy);

	pxy[0]=pblk->pb_x;
	pxy[1]=pblk->pb_y;
	pxy[2]=pblk->pb_x+pblk->pb_w-1;
	pxy[3]=pblk->pb_y+pblk->pb_h-1;
	++pxy[0]; ++pxy[1]; --pxy[2]; --pxy[3];
	vr_recfl(handle, pxy);
	--pxy[0]; --pxy[1]; ++pxy[2]; ++pxy[3];

	pxy[4]=pxy[2]; pxy[5]=pxy[3];
	pxy[3]=pxy[1];
	pxy[6]=pxy[0]; pxy[7]=pxy[5];
	pxy[8]=pxy[0]; pxy[9]=pxy[1];
	v_pline(handle, 5, pxy);
	
	/* Kurve zeichnen */
	if(field)
		y=field[0];
	else
		y=(pgp.plr.y[0]+pgp.plg.y[0]+pgp.plb.y[0])/3;
	y=(y*pblk->pb_h)/opledit[GEGRAPH].ob_height;
	pxy[2]=pblk->pb_x; pxy[3]=pblk->pb_y+pblk->pb_h-1-y;

	/* Sichtbar-Clipping */
	if(pxy[3] < pblk->pb_y+1) pxy[3]=pblk->pb_y+1;
	if(pxy[3] > pblk->pb_y+pblk->pb_h-2) pxy[3]=pblk->pb_y+pblk->pb_h-2;
	
	step=opledit[GEGRAPH].ob_width/pblk->pb_w;

	for(x=0, x0=0; x0 < pblk->pb_w; x+=step, ++x0)
	{
		if(x >= opledit[GEGRAPH].ob_width)
			x=opledit[GEGRAPH].ob_width-1;
		if(field)
			y=field[x];
		else
			y=(pgp.plr.y[x]+pgp.plg.y[x]+pgp.plb.y[x])/3;
		if(y > -1)
		{
			y=(y*pblk->pb_h)/opledit[GEGRAPH].ob_height;
			pxy[0]=pxy[2];
			pxy[1]=pxy[3];
			pxy[2]=pblk->pb_x+x0;
			pxy[3]=pblk->pb_y+pblk->pb_h-1-y;
			/* Sichtbar-Clipping */
			if(pxy[3] < pblk->pb_y+1) pxy[3]=pblk->pb_y+1;
			if(pxy[3] > pblk->pb_y+pblk->pb_h-2) pxy[3]=pblk->pb_y+pblk->pb_h-2;
			v_pline(handle, 2, pxy);
		}
	}

	vs_clip(handle, 0, pxy);
	
	return(0);
}

int cdecl plgraph(PARMBLK *pblk)
{
	int	pxy[10], x;
	double	z, x0, y0;
	
	
	/* Rahmen zeichnen */
	
	
	vswr_mode(handle, 1);
	vsl_color(handle, 1);
	vsl_width(handle, 1);

	vsf_color(handle, 8);
	vsf_interior(handle, 1);
	vsf_perimeter(handle, 0);

	pxy[0]=pblk->pb_xc;
	pxy[1]=pblk->pb_yc;
	pxy[2]=pblk->pb_xc+pblk->pb_wc-1;
	pxy[3]=pblk->pb_yc+pblk->pb_hc-1;
	vs_clip(handle, 1, pxy);

	pxy[0]=pblk->pb_x;
	pxy[1]=pblk->pb_y;
	pxy[2]=pblk->pb_x+pblk->pb_w-1;
	pxy[3]=pblk->pb_y+pblk->pb_h-1;
	++pxy[0]; --pxy[2];
	vr_recfl(handle, pxy);
	--pxy[0]; ++pxy[2];
	--pxy[1]; ++pxy[3];
	pxy[4]=pxy[2]; pxy[5]=pxy[3];
	pxy[3]=pxy[1];
	pxy[6]=pxy[0]; pxy[7]=pxy[5];
	pxy[8]=pxy[0]; pxy[9]=pxy[1];
	v_pline(handle, 5, pxy);
	
	/* Kurve zeichnen */
	if(ple.curve_type == 1)
	{/* Konstante */
		pxy[0]=(int)(pblk->pb_x);
		pxy[2]=(int)(pblk->pb_x+pblk->pb_w-1);
		pxy[1]=pxy[3]=pblk->pb_y+pblk->pb_h-1-ple.y1;
		v_pline(handle, 2, pxy);
	}
	else if(ple.curve_type == 2)
	{/* Linie */
		pxy[0]=(int)(pblk->pb_x);
		pxy[2]=(int)(pblk->pb_x+pblk->pb_w-1);
		pxy[1]=pblk->pb_y+pblk->pb_h-1-ple.y1;
		pxy[3]=pblk->pb_y+pblk->pb_h-1-ple.y3;
		v_pline(handle, 2, pxy);
	}
	else if(ple.curve_type == 3)
	{
		x0=ple.x1;
		y0=ple.y1;
		pxy[2]=(int)(pblk->pb_x+x0);
		pxy[3]=(int)pblk->pb_y+pblk->pb_h-1-y0;
	
		for(z=0; z<=1; z+=0.05)
		{
			x0=(1-z)*(1-z)*(1-z)*ple.x1;
			x0+=3*z*(1-z)*(1-z)*ple.x2;
			x0+=3*z*z*(1-z)*ple.x2;
			x0+=z*z*z*ple.x3;
			
			y0=pow(1-z,3)*ple.y1;
			y0+=3*z*(1-z)*(1-z)*ple.y2;
			y0+=3*z*z*(1-z)*ple.y2;
			y0+=z*z*z*ple.y3;
	
			pxy[0]=pxy[2];
			pxy[1]=pxy[3];
			pxy[2]=(int)(pblk->pb_x+x0);
			pxy[3]=(int)pblk->pb_y+pblk->pb_h-1-y0;
			v_pline(handle, 2, pxy);
		}
		pxy[0]=pxy[2];
		pxy[1]=pxy[3];
		pxy[2]=pblk->pb_x+ple.x3;
		pxy[3]=pblk->pb_y+pblk->pb_h-1-ple.y3;
		v_pline(handle, 2, pxy);
	}
	else if(ple.curve_type == 4)
	{
		pxy[2]=pblk->pb_x; pxy[3]=pblk->pb_y+pblk->pb_h-1-ple.y[0];
		
		for(x=0; x < pblk->pb_w; ++x)
		{
			if(ple.y[x] > -1)
			{
				pxy[0]=pxy[2];
				pxy[1]=pxy[3];
				pxy[2]=pblk->pb_x+x;
				pxy[3]=pblk->pb_y+pblk->pb_h-1-ple.y[x];
				v_pline(handle, 2, pxy);
			}
		}
	}

	vs_clip(handle, 0, pxy);
	
	return(0);
}

void w_unsel(WINDOW *win, int ob)
{
	win->dinfo->tree[ob].ob_state &= (~SELECTED);
	w_objc_draw(win, ob, 8, sx, sy, sw, sh);
}


void	bar(WINDOW *win, int ob, int min, int max, void(*newval)(int now2))
{/* Berechnet den Wert fÅr einen Direkt-Klick in den Slider */
 /* Setzt den Slider (als Objektnummer wird das erste Child des */
 /* Bars angenommen) und macht mit slide() weiter */
 
 OBJECT *tree=win->dinfo->tree;
 int	width, dif, mx, my, ox, oy, dum, val;
 float	ps, vl;
 
 	graf_mkstate(&mx, &my, &dum, &dum);
 	objc_offset(tree, ob, &ox, &oy);
 	mx-=ox; my-=oy;
 	mx-=tree[ob+1].ob_width/2;
 	my-=tree[ob+1].ob_height/2;
 	if(mx < 0) mx=0;
 	if(my < 0) my=0;
 	
	if(tree[ob].ob_width == tree[ob+1].ob_width)
	{
		width=tree[ob].ob_height-tree[ob+1].ob_height;
		if(my > width) my=width;
		/* Slider setzen */
		val=tree[ob+1].ob_y=my;
	}
	else
	{
		width=tree[ob].ob_width-tree[ob+1].ob_width;
		if(mx > width) mx=width;
		/* Slider setzen */
		val=tree[ob+1].ob_x=mx;
	}
	
	w_objc_draw(win, ob, 8, sx, sy, sw, sh);

	/* Position berechnen */
	dif=max-min;
	
	/* Wert berechnen */
	ps=(float)((float)dif/(float)width);
	vl=ps*(float)val; val=(int)vl;
	if(val > max) val=max;
	newval(val);
	
	slide(tree, ob+1, min, max, val, newval);
}

void	slide(OBJECT *tree, int ob, int min, int max, int now, void(*newval)(int now2))
{/* dir ist X oder Y, min und max sind min und max Werte (z.B.1,10)*/
 /* now ist der jetzige Wert (z.B.3), width ist die Breite/Hîhe*/
 /* des Parents abzÅglich des Sliders und dann noch die Funktion, */
 /* die einen neuen Wert bearbeitet */
	int		mx,my,ms,mk, mx2, my2, off, now2, width, dir;
	float	ps;

	if(tree[ob-1].ob_width == tree[ob].ob_width)
	{
		dir=Y;
		width=tree[ob-1].ob_height-tree[ob].ob_height;
	}
	else
	{
		dir=X;
		width=tree[ob-1].ob_width-tree[ob].ob_width;
	}
		
	if(width)
	{
		graf_mouse(FLAT_HAND,NULL);
		graf_mkstate(&mx,&my,&ms,&mk);
		ps=(float)((float)width/(float)((float)max-(float)min));
		if (dir == X)
			off=(int)((float)((float)mx-(float)ps*(float)now));
		else if (dir == Y)
			off=(int)((float)((float)my-(float)ps*(float)now));
		now2=now;
	
		while(ms & 1)
		{
			graf_mkstate(&mx2,&my2,&ms,&mk);
			if ((dir == X) && (mx2 != mx))
			{/* Ausrechnen, ob auch rel-pos neu ist */
				mx=mx2;
				mx=mx-off;
				now2=(int)((float)((float)mx/(float)ps));
			}
			else if ((dir == Y) && (my2 != my))
			{/* Ausrechnen, ob auch rel-pos neu ist */
				my=my2;
				my=my-off;
				now2=(int)((float)((float)my/(float)ps));
			}
			if (now2 < min)
				now2=min;
			if (now2 > max)
				now2=max;
			if (now2 != now)
			{
				now=now2;
				if(dir == X)
					tree[ob].ob_x=(int)((float)((float)now*(float)ps));
				else
					tree[ob].ob_y=(int)((float)((float)now*(float)ps));
				objc_draw(tree, ob-1, 2, sx, sy, sw, sh);
				newval(now2);
			}
		}
		graf_mouse(ARROW,NULL);
	}
}

void busy(int mode)
{
	GRECT scr, rect, todo, mouse;
	int		xywh[4], ms, d;
	
	/* Farbe der BUSY-LED setzen */
	
	if(mode)
	{ /* Anschalten */
		otoolbar[BUSYLED].ob_spec.bitblk->bi_color=2; /* 2=Rot, 10=dunkelrot */
		otoolbar[BUSYLED2].ob_spec.bitblk->bi_color=2; /* 2=Rot, 10=dunkelrot */
	}
	else
	{
		otoolbar[BUSYLED].ob_spec.bitblk->bi_color=10; /* 2=Rot, 10=dunkelrot */
		otoolbar[BUSYLED2].ob_spec.bitblk->bi_color=1; /* 2=Rot, 1=schwarz */
	}

	/* LED zeichnen */
	
	objc_offset(otoolbar, BUSYLED, &todo.g_x, &todo.g_y);
	todo.g_w=otoolbar[BUSYLED].ob_width;
	todo.g_h=otoolbar[BUSYLED].ob_height;
	
	graf_mkstate(&(mouse.g_x), &(mouse.g_y), &d, &d);
	mouse.g_x-=16; /* da Hot-Spot unbekannt muû mit doppeltem */
	mouse.g_y-=16; /* Rechteck gerechnet werden */
	mouse.g_h=mouse.g_w=32;

	wind_update(BEG_UPDATE);
	if (rc_intersect(&todo, &mouse))
	{
		ms=1;
		graf_mouse(M_OFF, NULL);
	}
	else
		ms=0;

	/* Screen-Grîûe */
	wind_get(0, WF_WORKXYWH, &scr.g_x, &scr.g_y, &scr.g_w, &scr.g_h);
	/* erstes Redraw-Rechteck */
	wind_get(main_win.id, WF_FIRSTXYWH, &rect.g_x, &rect.g_y, &rect.g_w, &rect.g_h);

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

				objc_draw(otoolbar, 0, 8, rect.g_x, rect.g_y, rect.g_w, rect.g_h);

				if (handle > -1)
					vs_clip(handle, 0, xywh);
			}
		}
		wind_get(main_win.id, WF_NEXTXYWH, &rect.g_x, &rect.g_y, &rect.g_w, &rect.g_h);

	}

	if (ms)
		graf_mouse(M_ON, NULL);

	wind_update(END_UPDATE);
}

void memo_abbruch(OBJECT *tree)
{
	/* HÑlt ob_state-Einstellungen von SELECTABLE-Objekten in deren
	   ext_ob_type fest
	*/
	
	int ob=0;
	
	do
	{
		/* SELECTABLE-Objekte finden */
		
		if(tree[ob].ob_flags & SELECTABLE)
			set_ext_type(tree, ob, tree[ob].ob_state);

	}while(!(tree[ob++].ob_flags & LASTOB));

}

void recall_abbruch(OBJECT *tree)
{
	/* Stellt die Einstellungen von SELECTABLE-Objekten anhand deren
	   ext_ob_type wieder her
	*/
	int ob=0;
	
	do
	{
		/* SELECTABLE-Objekte finden */
		
		if(tree[ob].ob_flags & SELECTABLE)
		{
			tree[ob].ob_state &= (~SELECTED);
			tree[ob].ob_state &= (~DISABLED);
			tree[ob].ob_state |= (tree[ob].ob_type >> 8);			
		}

	}while(!(tree[ob++].ob_flags & LASTOB));

}




