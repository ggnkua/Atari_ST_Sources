#include <grape_h.h>
#include "grape.h"
#include "new.h"
#include "layer.h"
#include "mask.h"
#include "xrsrc.h"
#include "scale.h"
#include "undo.h"
#include "main_win.h"
#include "print.h"
#include "preview.h"

/* 

Datei Neu anlegen

*/


double	propx, propy;
int			new_w, new_h;
void prop_calc_y(void);
void prop_calc_x(void);
void new_mcalc(void);

int mode_popup(OBJECT *tree, int ob)
{/* ôffnet das Mode-Popup an x/y von tree[ob] */
 /* ext_type von tree[ob] muû auûerdem bisherigen Modus fÅr
    Checked enthalten 
    Ist ob vom Typ BUTTON, wird der Textzeiger auf den neuen Text 
    gesetzt */
    
	OBJECT *mpop;
	int 	x,y,a,b;
	
	xrsrc_gaddr(0, MODEPOP, &mpop, xrsrc);
	b=tree[ob].ob_type >> 8;
	a=0;
	do
	{
		++a;
		mpop[a].ob_state &= (~CHECKED);
	}while(!(mpop[a].ob_flags & LASTOB));
	mpop[b].ob_state |= CHECKED;
	
	objc_offset(tree, ob, &x, &y);
	y-=(b-1)*mpop[1].ob_height;
	if(y < sy) y=sy;
	if(y+mpop[0].ob_height > sy+sh)
		y=sy+sh-mpop[0].ob_height;
	if(x < sx) x=sx;
	if(x+mpop[0].ob_width > sx+sw)
		x=sx+sw-mpop[0].ob_width;
	a=form_popup(mpop, x, y);
	if((a > 0) && ((tree[ob].ob_type & 255) == G_BUTTON))
		tree[ob].ob_spec.free_string=&((mpop[a].ob_spec.free_string)[2]);
	return(a);
}

int get_dpi(void)
{
	return(atoi(onew[ONDPI].ob_spec.tedinfo->te_ptext));
}

int num_to_pix(long num, int mode, long dpi)
{ /* Rechnet die mode-Zahl num unter dpi in Pixel um */
	switch(mode)
	{
		case 1: /* Pixel */
			return((int)num);

		case 2:	/* mm */
			num*=dpi;			/* In Pixel umrechnen */
			num*=100;			/* In Inch umrechnen */
			num/=254;
			num=(num+5)/10/*0*/;		/* Korrektur / 100 */
			/* Overflow? */
			if(num > 32767) num=32767;
			return((int)num);

		case 3: /* cm */
			num*=dpi;			/* In Pixel umrechnen */
			num*=100;			/* In Inch umrechnen */
			num/=254;
			num=(num+5)/*/10*/;		/* Korrektur / 10 */
			/* Overflow? */
			if(num > 32767) num=32767;
			return((int)num);

		case 4: /* Inch */
			num*=dpi;		/* In Pixel umrechnen */
			if(num > 32767) num=32767;
			return((int)num);
			
		default:
			return(0);
	}
}

int ob_num_to_pix(OBJECT *tree, int v_ob, int m_ob, long dpi)
{/* Rechnet Zahl in Pixel um
		tree: Objektbaum
		v_ob: Textobjekt, daû die Zahl enthÑlt
		m_ob: Objekt, das im ext_type den Modus enthÑlt
					1=Pixel, 2=mm, 3=cm, 4=Inch
		dpi:  Auflîsung
*/
	long 	num=atoi(tree[v_ob].ob_spec.tedinfo->te_ptext);
	
	return(num_to_pix(num, tree[m_ob].ob_type >> 8, dpi));
}

int pix_to_num(long num, int mode, long dpi)
{
	/* Rechnet die Pixelzahl num unter dpi in die mode-Zahl um */

	switch(mode)
	{
		case 1: /* Pixel */
			return((int)num);

		case 2:	/* mm */
			num*=254;	/* In Pixel / cm *100 umrechnen */
			num/=dpi;		/* In Pixel / Inch *100 umrechnen */
			num=(num+5)/10;		
			/* Overflow? */
			if(num > 32767) num=32767;
			return((int)num);

		case 3: /* cm */
			num*=254;	/* In Pixel / cm *100 umrechnen */
			num/=dpi;		/* In Pixel / Inch *100 umrechnen */		
			num=(num+50)/100;		/* Korrektur / 100 */
			/* Overflow? */
			if(num > 32767) num=32767;
			return((int)num);

		case 4: /* Inch */
			num/=dpi;		/* In Inch umrechnen */
			return((int)num);

		default:
			return(0);
	}
}

int ob_pix_to_num(OBJECT *tree, int v_ob, int m_ob, long dpi, int n_mode)
{/* Rechnet Pixel in Zahl um
		tree: Objektbaum
		v_ob: Textobjekt, daû die Zahl enthÑlt
		m_ob: Objekt, das im ext_type den Modus der Zahl enthÑlt
					1=Pixel, 2=mm, 3=cm, 4=Inch
		dpi:  Auflîsung
		n_mode: Modus, in dem die neue Zahl umgerechnet werden soll
*/
	long 	num;

	/* Zahl erstmal in Pixel umrechnen */
	num=ob_num_to_pix(tree, v_ob, m_ob, dpi);

	return(pix_to_num(num, n_mode, dpi));
}

void p_used_size(int *nw, int *nh)
{ /* Die im Fenster ausgenutzte Breite/Hîhe fÅr's Farbfeld*/
	int		 hw, hh;
	double h_zu_w;
	
	/* VerhÑltnis */
	h_zu_w=(double)new_h/(double)new_w;
	
	hw=osize[NSPREVIEW].ob_width;
	hh=osize[NSPREVIEW].ob_height;
	*nw=new_w;
	*nh=new_h;

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

void fit_source(int dw, int dh, int *nw, int *nh)
{/* dw, dh=Neue Grîûe. Berechnet wird first_lay/width/height so,
		daû proportional in dw/dh skaliert wird. RÅckgabe in nw/nh */
		
	int		hw, hh;
	double h_zu_w;
	
	hw=first_lay->this.width;
	hh=first_lay->this.height;
	h_zu_w=(double)hh/(double)hw;
	/* Skalierung berechnen */

	*nw=dw;
	*nh=(int)((double)dw*h_zu_w);

	if(*nh > dh)
	{/* Zuviele Hîhenpixel */
		*nh=dh;
		*nw=(int)((double)dh/h_zu_w);
	}
	if(*nw > dw)
	{/* Zuviele Breiten-Pixel */
		*nw=dw;
		*nh=(int)((double)dw*h_zu_w);
	}
}

void same_scale(int uw, int uh, int *nw, int *nh, int *ofx, int *ofy)
{
	double o_zu_s;
	
	if(uh > uw)
		o_zu_s=(double)new_h/(double)uh;
	else
		o_zu_s=(double)new_w/(double)uw;
	
	*nw=(int)((double)first_lay->this.width/o_zu_s);
	*nh=(int)((double)first_lay->this.height/o_zu_s);
	*ofx=(int)((double)*ofx/o_zu_s);
	*ofy=(int)((double)*ofy/o_zu_s);
}

void fill_ns_preview(void)
{/* FÅllt das Preview-Feld im Newsize-Fenster */
	uchar	*sc, *sm, *sy;
	register int		x,y,w;
	register uchar	*dc, *dm, *dy;
	register long		doff;

	int			uw, uh, nw, nh, ofx, ofy, sox, soy, scw, sch;
	
	p_used_size(&uw, &uh);
	
	/* Inhalt komplett grau */	
	w=osize[NSPREVIEW].ob_width;
	doff=(long)((U_OB*)(osize[NSPREVIEW]_UP_))->color.w-w;
	dc=((U_OB*)(osize[NSPREVIEW]_UP_))->color.b;
	dm=((U_OB*)(osize[NSPREVIEW]_UP_))->color.r;
	dy=((U_OB*)(osize[NSPREVIEW]_UP_))->color.g;
	for(y=osize[NSPREVIEW].ob_height; y > 0; --y)
	{
		for(x=w; x > 0; --x)
		{
			*dc++=128;*dm++=128;*dy++=128;
		}
		dc+=doff; dm+=doff; dy+=doff;
	}
	/* Neu-Bereich weiû */	
	w=uw;
	doff=(long)((U_OB*)(osize[NSPREVIEW]_UP_))->color.w-w;
	dc=((U_OB*)(osize[NSPREVIEW]_UP_))->color.b;
	dm=((U_OB*)(osize[NSPREVIEW]_UP_))->color.r;
	dy=((U_OB*)(osize[NSPREVIEW]_UP_))->color.g;
	for(y=uh; y > 0; --y)
	{
		for(x=w; x > 0; --x)
		{
			*dc++=0;*dm++=0;*dy++=0;
		}
		dc+=doff; dm+=doff; dy+=doff;
	}

	/* Skalieren */
	if((osize[NSTYP1].ob_state | osize[NSTYP2].ob_state) & SELECTED)
	{/* uw/uh sind ok fÅr TYP2=Auf neue Grîûe skalieren */
		if(osize[NSTYP1].ob_state & SELECTED)
		{/* Proportional skalieren->uw/uh neu berechnen */
			fit_source(uw, uh, &nw, &nh);
			uw=nw; uh=nh;
		}
		doff=(long)((U_OB*)(osize[NSPREVIEW]_UP_))->color.w-osize[NSPREVIEW].ob_width;
		doff+=osize[NSPREVIEW].ob_width-uw;
		dc=((U_OB*)(osize[NSPREVIEW]_UP_))->color.b;
		dm=((U_OB*)(osize[NSPREVIEW]_UP_))->color.r;
		dy=((U_OB*)(osize[NSPREVIEW]_UP_))->color.g;
	
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

		if(sc) simple_scale_one(sc, dc, first_lay->this.width, first_lay->this.height, uw, uh, 
								 doff, first_lay->this.word_width, 0, 0);
			
		if(sm) simple_scale_one(sm, dm, first_lay->this.width, first_lay->this.height, uw, uh, 
								 doff, first_lay->this.word_width, 0, 0);
	
		if(sy) simple_scale_one(sy, dy, first_lay->this.width, first_lay->this.height, uw, uh, 
								 doff, first_lay->this.word_width, 0, 0);
	}
	else
	{/* Typ 3 */
		sox=ofx=ob_num_to_pix(osize,NSXOFF,NSMODE,get_dpi());
		soy=ofy=ob_num_to_pix(osize,NSYOFF,NSMODE,get_dpi());
		/* Wieviel Platz nimmt Original bei gleicher Skalierung ein? */
		/* (Offsets gleich mit Skalieren) */
		same_scale(uw, uh, &nw, &nh, &ofx, &ofy);
		/* Zugehîrige Originalmaûe bestimmen */
		scw=first_lay->this.width;
		sch=first_lay->this.height;
		/* Ergebnis einpassen */
		if(new_w > first_lay->this.width)
		{/* Breitenoffset gilt fÅr Reinsetzen in Dest */
			if(ofx > uw) /* Durch Offset rausverschoben */
				return;
			if(ofx+nw > uw)
				nw=uw-ofx;
			if(sox+scw > new_w)
				scw=new_w-sox;
			sox=0;
		}
		else
		{/* Breitenoffset gilt fÅr Holen aus Source */
			if(sox >= first_lay->this.width) /* Durch Offset rausverschoben */
				return;
			nw-=ofx;
			if(nw > uw)
				nw=uw;
			scw-=sox;
			if(scw > new_w)
				scw=new_w;
			ofx=0;
		}
		
		if(new_h > first_lay->this.height)
		{/* Hîhenoffset gilt fÅr Reinsetzen in Dest */
			if(ofy > uh) /* Durch Offset rausverschoben */
				return;
			if(ofy+nh > uh)
				nh=uh-ofy;
			if(soy+sch > new_h)
				sch=new_h-soy;
			soy=0;
		}
		else
		{/* Hîhenoffset gilt fÅr Holen aus Source */
			if(soy >= first_lay->this.height) /* Durch Offset rausverschoben */
				return;
			nh-=ofy;
			if(nh > uh)
				nh=uh;
			sch-=soy;
			if(sch > new_h)
				sch=new_h;
			ofy=0;
		}

		dc=((U_OB*)(osize[NSPREVIEW]_UP_))->color.b;
		dm=((U_OB*)(osize[NSPREVIEW]_UP_))->color.r;
		dy=((U_OB*)(osize[NSPREVIEW]_UP_))->color.g;
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

		/* Reinsetz-Offset addieren */
		dc+=ofx; dm+=ofx; dy+=ofx;
		doff=(long)((long)((U_OB*)(osize[NSPREVIEW]_UP_))->color.w*(long)ofy);
		dc+=doff; dm+=doff; dy+=doff;

		doff=(long)((U_OB*)(osize[NSPREVIEW]_UP_))->color.w-osize[NSPREVIEW].ob_width;
		doff+=osize[NSPREVIEW].ob_width-nw;
	
		if(sc) simple_scale_one(sc, dc, scw, sch, nw, nh, 
								 doff, first_lay->this.word_width, sox, soy);
			
		if(sm) simple_scale_one(sm, dm, scw, sch, nw, nh, 
								 doff, first_lay->this.word_width, sox, soy);
	
		if(sy) simple_scale_one(sy, dy, scw, sch, nw, nh, 
								 doff, first_lay->this.word_width, sox, soy);
	}	
}

void num_stretch(char *num, int len)
{/* VerlÑngert die Zahl im String num durch fÅhrende Nullen auf
		len Stellen */
	
	int a;

	while(strlen(num) < len)
	{
		for(a=(int)strlen(num)+1; a ; --a)
			num[a]=num[a-1];
		num[0]='0';
	}
}

void offset_copy(uchar *sorc, int sw, int sh, int sww, uchar *dest, int nw, int nh, int nww, int xoff, int yoff)
{
	int				srxo, sryo, dsxo, dsyo;
	register int cpw, cph, x;
	register uchar *src=sorc, *dst=dest;
	register long	sadd, dadd;
	
	if(nw > sw) /* Neue Breite grîûer->Offset auf Dest, d.h Source einrÅcken */
	{
		if(xoff > nw) return; /* Rausgeoffsettet */
		dsxo=xoff;
		srxo=0;
		cpw=sw;
		if(dsxo+cpw > nw)
			cpw=nw-dsxo;
	}
	else /* Alte Breite grîûer->Offset auf Source */
	{
		if(xoff > sw) return; /* Raugeoffsettet */
		srxo=xoff;
		dsxo=0;
		cpw=nw;
		if(srxo+cpw > sw)
			cpw=sw-srxo;
	}
	
	if(nh > sh) /* Neue Hîhe grîûer->Offset auf Dest, d.h Source einrÅcken */
	{
		if(yoff > nh) return; /* Rausgeoffsettet */
		dsyo=yoff;
		sryo=0;
		cph=sh;
		if(dsyo+cph > nh)
			cph=nh-dsyo;
	}
	else /* Alte Hîhe grîûer->Offset auf Source */
	{
		if(yoff > sh) return; /* Raugeoffsettet */
		sryo=yoff;
		dsyo=0;
		cph=nh;
		if(sryo+cph > sh)
			cph=sh-sryo;
	}
	
	/* Offsets auf Source und Dest */
	sadd=(long)((long)sryo*(long)sww+(long)srxo);
	dadd=(long)((long)dsyo*(long)nww+(long)dsxo);
	src+=sadd;
	dst+=dadd;
	
	/* Offsets zwischen den Zeilen */
	sadd=sww-cpw;
	dadd=nww-cpw;
	
	/* Kopieren */
	while(cph--)
	{
		for(x=cpw; x > 0; --x)
			*dst++=*src++;
		dst+=dadd;
		src+=sadd;
	}
}

void	change_file(int nw, int nh, int type, int xoff, int yoff)
{/* nw/nh: neue Breite/Hîhe
		type:  1=Prop. skalieren
					 2=Komplett skalieren
					 3=Unskaliert auf xoff/yoff Åbernehmen
 */
	int		width, pbuf[8];
	int		old_w, old_h, old_ww, dum, fw, fh;
	int		scal_w, scal_h;
	long	siz, total, p, *new_t_offset;
	LAY_LIST*l=first_lay;
	MASK_LIST*m=first_mask;
	uchar	*all_mem, *b1, *b2, *b3;
	
	width=((nw/16)+1)*16;
	siz=(long)((long)width*(long)nh);
	total=siz*3*(long)count_layers()+siz*(long)count_masks();
	all_mem=calloc(total, 1);
	new_t_offset=malloc(nh*sizeof(long));
	if((all_mem==NULL)||(new_t_offset==NULL))
	{/* Das ganze Åber Auslagerung lîsen? */
		if(all_mem) free(all_mem);
		if(new_t_offset) free(new_t_offset);
		form_alert(1,"[3][Nicht genug Speicher!][Abbruch]");
		return;
	}

	/* Speicher hammer, Undo-Warnung ausspucken */
	if((*(unsigned char**)(undo_end+2) != NULL) || ((long)undo_end-(long)undo_start != 14))
	{/* Undo-Puffer ist nicht leer */
		if(form_alert(1,"[2][Grape:|Der Inhalt des Undo-Puffers|geht verloren!][OK|Abbruch]")==2)
		{
			free(all_mem);
			free(new_t_offset);
			return;
		}
	}
	
	/* Skalierungsmaûe fÅr Typ 1 berechnen */
	fit_source(nw, nh, &scal_w, &scal_h);
	free(table_offset);
	table_offset=new_t_offset;
	for(p=0; p < (long)nh; ++p)
		table_offset[p]=(long)((long)p*(long)width);
	
	old_w=l->this.width;
	old_ww=l->this.word_width;
	old_h=l->this.height;
	
	busy(ON);
	graf_mouse(BUSYBEE, NULL);
	
	while(l)
	{
		b1=l->this.red; l->this.red=all_mem; all_mem+=siz;
		b2=l->this.yellow; l->this.yellow=all_mem; all_mem+=siz;
		b3=l->this.blue; l->this.blue=all_mem; all_mem+=siz;
		l->this.width=nw;
		l->this.height=nh;
		l->this.word_width=width;
		
		switch(type)
		{
			case 1:
				simple_scale_one(b1, l->this.red, old_w, old_h, scal_w, scal_h, width-scal_w, old_ww, 0, 0);
				simple_scale_one(b2, l->this.yellow, old_w, old_h, scal_w, scal_h, width-scal_w, old_ww, 0, 0);
				simple_scale_one(b3, l->this.blue, old_w, old_h, scal_w, scal_h, width-scal_w, old_ww, 0, 0);
			break;
			case 2:
				simple_scale_one(b1, l->this.red, old_w, old_h, nw, nh, width-nw, old_ww, 0, 0);
				simple_scale_one(b2, l->this.yellow, old_w, old_h, nw, nh, width-nw, old_ww, 0, 0);
				simple_scale_one(b3, l->this.blue, old_w, old_h, nw, nh, width-nw, old_ww, 0, 0);
			break;
			case 3:
				offset_copy(b1, old_w, old_h, old_ww, l->this.red, nw, nh, width, xoff, yoff);
				offset_copy(b2, old_w, old_h, old_ww, l->this.yellow, nw, nh, width, xoff, yoff);
				offset_copy(b3, old_w, old_h, old_ww, l->this.blue, nw, nh, width, xoff, yoff);
			break;
		}
		free(b1);
		free(b2);
		free(b3);
				
		l=l->next;
	}
	
	while(m)
	{
		b1=m->this.mask; m->this.mask=all_mem; all_mem+=siz;

		switch(type)
		{
			case 1:
				simple_scale_one(b1, m->this.mask, old_w, old_h, scal_w, scal_h, width-scal_w, old_ww, 0, 0);
			break;
			case 2:
				simple_scale_one(b1, m->this.mask, old_w, old_h, nw, nh, width-nw, old_ww, 0, 0);
			break;
			case 3:
				offset_copy(b1, old_w, old_h, old_ww, m->this.mask, nw, nh, width, xoff, yoff);
			break;
		}
		free(b1);
		m=m->next;
	}

	graf_mouse(ARROW, NULL);
	busy(OFF);
	
	/* Fenstergrîûe und Slider anpassen */
	pbuf[0]=ap_id;
	pbuf[1]=0;
	pbuf[2]=ap_id;
	pbuf[3]=WM_SIZED;
	wind_get(main_win.id, WF_CURRXYWH, &pbuf[4], &pbuf[5], &pbuf[6], &pbuf[7]);
	wind_get(main_win.id, WF_WORKXYWH, &dum, &dum, &fw, &fh);
	fh-=otoolbar[0].ob_height+OTBB;
	/* Offset im Fenster ggf. korrigieren */
	if(main_win.ox+fw > nw)
	{
		main_win.ox=nw-fw;
		if(main_win.ox < 0) main_win.ox=0;
	}
	if(main_win.oy+fh > nh)
	{
		main_win.oy=nh-fh;
		if(main_win.oy < 0) main_win.oy=0;
	}
	new_wsize(pbuf);
	/* Redraw */
	redraw_pic();
	/* Undo-Puffer lîschen */
	free_undo();
	clear_undo();
	init_undo();
	
	actize_win_name();

	new_pr_preview();
}


void new_ns_preview(void)
{
	if(wsize.open)
	{
		fill_ns_preview();
		w_objc_draw(&wsize, NSPREVIEW, 8, sx, sy, sw, sh);
	}
}

void change_offset(int x, int y)
{/* x und y in Pixeln */
	x=pix_to_num(x, osize[NSMODE].ob_type >> 8, get_dpi());
	y=pix_to_num(y, osize[NSMODE].ob_type >> 8, get_dpi());
	itoa(x, osize[NSXOFF].ob_spec.tedinfo->te_ptext, 10);
	num_stretch(osize[NSXOFF].ob_spec.tedinfo->te_ptext, 5);
	itoa(y, osize[NSYOFF].ob_spec.tedinfo->te_ptext, 10);
	num_stretch(osize[NSYOFF].ob_spec.tedinfo->te_ptext, 5);
	w_objc_draw(&wsize, NSXOFF, 8, sx, sy, sw, sh);
	w_objc_draw(&wsize, NSYOFF, 8, sx, sy, sw, sh);
	if(osize[NSTYP3].ob_state & SELECTED)
		new_ns_preview();
}

void move_offset(int x, int y)
{
	int ox, oy, scroll_val;
	
	if(artpad) /* Arrows per Wacom bedienen? */
		scroll_val=((int)asgc->pressure+20)/20;
	else
		scroll_val=1;
	ox=atoi(osize[NSXOFF].ob_spec.tedinfo->te_ptext);
	oy=atoi(osize[NSYOFF].ob_spec.tedinfo->te_ptext);
	x*=scroll_val;
	y*=scroll_val;
	x+=ox;
	y+=oy;
	if(x < 0) x=0;
	if(y < 0) y=0;
	if((x != ox) || (y != oy))
	{
		itoa(x, osize[NSXOFF].ob_spec.tedinfo->te_ptext, 10);
		num_stretch(osize[NSXOFF].ob_spec.tedinfo->te_ptext, 5);
		itoa(y, osize[NSYOFF].ob_spec.tedinfo->te_ptext, 10);
		num_stretch(osize[NSYOFF].ob_spec.tedinfo->te_ptext, 5);
		w_objc_draw(&wsize, NSXOFF, 8, sx, sy, sw, sh);
		w_objc_draw(&wsize, NSYOFF, 8, sx, sy, sw, sh);
		if(osize[NSTYP3].ob_state & SELECTED)
			new_ns_preview();
	}
}

void unsel_typ3(void)
{/* Falls von 2 nach 1 oder 1 nach 2 gewechselt wird nix machen */
	if(osize[NSXOFF].ob_state & DISABLED) return;

	osize[NSOF1].ob_state|=DISABLED; osize[NSOF2].ob_state |= DISABLED;
	osize[NSXOFF].ob_state=osize[NSYOFF].ob_state |= DISABLED;
	osize[NSLO].ob_state=osize[NSO].ob_state=osize[NSRO].ob_state=
	osize[NSL].ob_state=osize[NSM].ob_state=osize[NSR].ob_state=
	osize[NSLU].ob_state=osize[NSU].ob_state=osize[NSRU].ob_state
	|=DISABLED;
	w_objc_draw(&wsize, NST3DRAW, 8, sx, sy, sw, sh);
}

void sel_typ3(void)
{
	osize[NSOF1].ob_state&=(~DISABLED);
	osize[NSOF2].ob_state&=(~DISABLED);
	osize[NSXOFF].ob_state=osize[NSYOFF].ob_state &= (~DISABLED);
	osize[NSLO].ob_state=osize[NSO].ob_state=osize[NSRO].ob_state=
	osize[NSL].ob_state=osize[NSM].ob_state=osize[NSR].ob_state=
	osize[NSLU].ob_state=osize[NSU].ob_state=osize[NSRU].ob_state
	&=(~DISABLED);
	w_objc_draw(&wsize, NST3DRAW, 8, sx, sy, sw, sh);
}

void dial_size(int ob)
{
	int a,x,y,type;
	int	ow=first_lay->this.width;
	int oh=first_lay->this.height;
	int	mov=osize[NSOF1].ob_state & SELECTED;
	
	switch(ob)
	{
		case NSTYP1:
		case NSTYP2:
			unsel_typ3();
			new_ns_preview();
		break;
		case NSTYP3:
			sel_typ3();
			new_ns_preview();
		break;

		case NSMODE:
			a=mode_popup(osize, NSMODE);
			if(a > 0)
			{
				x=ob_pix_to_num(osize, NSXOFF, NSMODE, get_dpi(), a);
				y=ob_pix_to_num(osize, NSYOFF, NSMODE, get_dpi(), a);
				set_ext_type(osize, NSMODE, a);
				itoa(x, osize[NSXOFF].ob_spec.tedinfo->te_ptext, 10);
				itoa(y, osize[NSYOFF].ob_spec.tedinfo->te_ptext, 10);
				num_stretch(osize[NSXOFF].ob_spec.tedinfo->te_ptext, 5);
				num_stretch(osize[NSYOFF].ob_spec.tedinfo->te_ptext, 5);
				w_objc_draw(&wsize, NSXOFF, 8, sx,sy,sw,sh);
				w_objc_draw(&wsize, NSYOFF, 8, sx,sy,sw,sh);				
				w_objc_draw(&wsize, NSMODE, 8, sx,sy,sw,sh);				
			}
		break;

		/* Offsetvorgaben */
		case NSLO:
			if(mov)	move_offset(-1,-1);
			else change_offset(0, 0);
		break;
		case NSO:
			if(mov)	move_offset(0,-1);
			else change_offset(abs(ow-new_w)/2, 0);
		break;
		case NSRO:
			if(mov)	move_offset(1,-1);
			else change_offset(abs(ow-new_w), 0);
		break;
		case NSL:
			if(mov) move_offset(-1,0);
			else change_offset(0, abs(oh-new_h)/2);
		break;
		case NSM:
			if(!mov)
				change_offset(abs(ow-new_w)/2, abs(oh-new_h)/2);
		break;
		case NSR:
			if(mov) move_offset(1,0);
			else change_offset(abs(ow-new_w), abs(oh-new_h)/2);
		break;
		case NSLU:
			if(mov) move_offset(-1,1);
			else change_offset(0, abs(oh-new_h));
		break;
		case NSU:
			if(mov) move_offset(0,1);
			else change_offset(abs(ow-new_w)/2, abs(oh-new_h));
		break;
		case NSRU:
			if(mov) move_offset(1,1);
			else change_offset(abs(ow-new_w), abs(oh-new_h));
		break;
		
		
		
		/* Buttons */
		case NSBACK:
			w_unsel(&wsize, ob);
			w_close(&wsize);
			w_kill(&wsize);
			change_window(1);
		break;
		case NSOK:
			if(osize[NSTYP1].ob_state & SELECTED)
				type=1;
			else if(osize[NSTYP2].ob_state & SELECTED)
				type=2;
			else if(osize[NSTYP3].ob_state & SELECTED)
				type=3;
			change_file(new_w, new_h, type,
									atoi(osize[NSXOFF].ob_spec.tedinfo->te_ptext), atoi(osize[NSYOFF].ob_spec.tedinfo->te_ptext));
			new_preview_sel();
		case NSABBRUCH:
			w_unsel(&wsize, ob);
			w_close(&wsize);
			w_kill(&wsize);
		break;
	}
}

void prev_keybd(int key, int swt)
{
	key&=255;
	swt&=15;
 	if((key == 27) || (key == 8) || (key ==  127) ||
 			 ((key >= 48) && (key <= 57))
 		)
 		new_ns_preview();
}

void calc_keybd(int key, int swt)
{
	key&=255;
	swt&=15;
 	if((key == 27) || (key == 8) || (key ==  127) ||
 			 ((key >= 48) && (key <= 57))
 		)
	{
 		if(onew[ONPROP].ob_state & SELECTED)
 		{
 			switch(dnew.dedit)
 			{
 				case ONPX:
 					prop_calc_y();
					w_objc_draw(&wnew, ONPY, 8, sx ,sy, sw, sh);
 				break;
 				case ONPY:
 					prop_calc_x();
					w_objc_draw(&wnew, ONPX, 8, sx ,sy, sw, sh);
 				break;
 			}
 		}
		switch(dnew.dedit)
		{
			case ONPX:
			case ONPY:
			case ONDPI:
				new_mcalc();
				w_objc_draw(&wnew, ONMEM, 8, sx ,sy, sw, sh);
			break;
		}
	}
}

void	newsize_window(int ww, int height)
{/* ôffnet Dialog fÅr DatenÅbername bei neuer Dateigrîûe
		oder kehrt zurÅck (Grîûe beibehalten)*/
	
	char text[32], num[32];
	
	if((ww==first_lay->this.width) && (height==first_lay->this.height))
		return;

	new_w=ww;
	new_h=height;
	strcpy(osize[NSXOFF].ob_spec.tedinfo->te_ptext, "00000");
	strcpy(osize[NSYOFF].ob_spec.tedinfo->te_ptext, "00000");
	osize[NSTYP1].ob_state|=SELECTED;
	osize[NSTYP2].ob_state&=(~SELECTED);
	osize[NSTYP3].ob_state&=(~SELECTED);
	osize[NSOF1].ob_state&=(~SELECTED);
	osize[NSOF2].ob_state|=SELECTED;
	osize[NSOF1].ob_state|=DISABLED; osize[NSOF2].ob_state |= DISABLED;
	osize[NSXOFF].ob_state=osize[NSYOFF].ob_state |= DISABLED;
	osize[NSLO].ob_state=osize[NSO].ob_state=osize[NSRO].ob_state=
	osize[NSL].ob_state=osize[NSM].ob_state=osize[NSR].ob_state=
	osize[NSLU].ob_state=osize[NSU].ob_state=osize[NSRU].ob_state
	|=DISABLED;
	
	strcpy(text, "VORHER:  ");
	strcat(text, itoa(first_lay->this.width, num, 10));
	strcat(text, " x ");
	strcat(text, itoa(first_lay->this.height, num, 10));
	strcpy(osize[NSPRE].ob_spec.tedinfo->te_ptext, text);

	strcpy(text, "NACHHER: ");
	strcat(text, itoa(ww, num, 10));
	strcat(text, " x ");
	strcat(text, itoa(height, num, 10));
	strcpy(osize[NSPOST].ob_spec.tedinfo->te_ptext, text);
		
	if(!wsize.open)
	{
		/* Fenster initialisieren */
		fill_ns_preview();
		wsize.dinfo=&dsize;
		w_dial(&wsize, D_CENTER);
		wsize.name="[Grape]";
		w_set(&wsize, NAME);
		dsize.dakeybd=prev_keybd;
		w_open(&wsize);
	}
	else
		w_top(&wsize);
}

void change_window(int let_be)
{/* let_be=0: Aktuelle Datei-Daten in Grîûenfelder eintragen
		let_be=1: Nix eintragen */

	int x;
	
	if(wsize.open)
	{
		w_top(&wsize);
		return;
	}
	strcpy(onew[ONTITEL].ob_spec.tedinfo->te_ptext, "Dateigrîûe Ñndern");
	strcpy(onew[ONOK].ob_spec.free_string, "Weiter >");
	if(let_be==0)	
	{/* Aktuelle Daten eintragen */
		x=pix_to_num(first_lay->this.width, onew[ONMODE].ob_type >> 8, get_dpi());
		itoa(x, onew[ONPX].ob_spec.tedinfo->te_ptext, 10);
		num_stretch(onew[ONPX].ob_spec.tedinfo->te_ptext, 5);
		x=pix_to_num(first_lay->this.height, onew[ONMODE].ob_type >> 8, get_dpi());
		itoa(x, onew[ONPY].ob_spec.tedinfo->te_ptext, 10);
		num_stretch(onew[ONPY].ob_spec.tedinfo->te_ptext, 5);
		new_mcalc();
	}
	
	if(!wnew.open)
	{
		wnew.dinfo=&dnew;
		w_dial(&wnew, D_CENTER);
		wnew.name="[Grape]";
		w_set(&wnew, NAME);
		dnew.dedit=ONPX;
		dnew.dakeybd=calc_keybd;
		w_open(&wnew);
	}
	else
	{
		w_top(&wnew);
		s_redraw(&wnew);
	}
}

void new_window(void)
{
	strcpy(onew[ONTITEL].ob_spec.tedinfo->te_ptext, "Neue Datei anlegen");
	strcpy(onew[ONOK].ob_spec.free_string, "OK");
	new_mcalc();
	
	if(!wnew.open)
	{
		onew[ONGRAF].ob_spec.bitblk->bi_color=9; /* 9=DGrau */
		onew[ONPROP].ob_state &= (~SELECTED);
		wnew.dinfo=&dnew;
		w_dial(&wnew, D_CENTER);
		wnew.name="[Grape]";
		w_set(&wnew, NAME);
		dnew.dedit=ONPX;
		dnew.dakeybd=calc_keybd;
		w_open(&wnew);
	}
	else
	{
		w_top(&wnew);
		s_redraw(&wnew);
	}
}

void prop_calc_x(void)
{
	/* Aus Y per prop X berechnen */
	double	q=propx/propy;
	double	x, y;
	long		nx;	

	y=atoi(onew[ONPY].ob_spec.tedinfo->te_ptext);
	x=y*q;
	nx=(long)x;
	if(nx > 32767) nx=32767;
	/* Eintragen */
	itoa((int)nx, onew[ONPX].ob_spec.tedinfo->te_ptext, 10);
	num_stretch(onew[ONPX].ob_spec.tedinfo->te_ptext, 5);
}
void prop_calc_y(void)
{
	/* Aus X per prop Y berechnen */
	double	q=propx/propy;
	double	x, y;
	long		ny;	

	x=atoi(onew[ONPX].ob_spec.tedinfo->te_ptext);
	y=x/q;
	ny=(long)y;
	if(ny > 32767) ny=32767;
	/* Eintragen */
	itoa((int)ny, onew[ONPY].ob_spec.tedinfo->te_ptext, 10);
	num_stretch(onew[ONPY].ob_spec.tedinfo->te_ptext, 5);
}

void new_mcalc(void)
{
	/* Berechnet den Speicherbedarf neu */
	int m1,m2;
	double x, y, mem;
	char	fac[2], num[5];
	
	
	/* Speicherverbrauch */
	x=(double)ob_num_to_pix(onew,ONPX,ONMODE,get_dpi());
	y=(double)ob_num_to_pix(onew,ONPY,ONMODE,get_dpi());
	
	mem=x*y*3; /* 3 Planes */
	fac[0]=fac[1]=0;
	if(mem > 1024)
	{
		mem/=1024;
		fac[0]='K';
	}
	if(mem > 1024)
	{
		mem/=1024;
		fac[0]='M';
	}
	if(mem > 1024)
	{
		mem/=1024;
		fac[0]='G';
	}
	m1=(int)mem;
	itoa(m1, onew[ONMEM].ob_spec.tedinfo->te_ptext, 10);
	
	/* Erste Nachkommastelle */
	mem*=10;
	m2=(int)mem;
	m2-=10*m1;
	if(m2)
	{
		strcat(onew[ONMEM].ob_spec.tedinfo->te_ptext, ".");
		strcat(onew[ONMEM].ob_spec.tedinfo->te_ptext, itoa(m2, num, 10));
	}

	strcat(onew[ONMEM].ob_spec.tedinfo->te_ptext, " ");
	strcat(onew[ONMEM].ob_spec.tedinfo->te_ptext, fac);
	strcat(onew[ONMEM].ob_spec.tedinfo->te_ptext, "Byte");
	
}

int percent_calc(void)
{/* énderungen->1, sonst 0 */
	long prc, x, y, ox, oy;
	
	prc=atoi(onew[ONPCNT].ob_spec.tedinfo->te_ptext);

	ox=atoi(onew[ONPX].ob_spec.tedinfo->te_ptext);
	oy=atoi(onew[ONPY].ob_spec.tedinfo->te_ptext);
	x=(ox*prc)/100;
	y=(oy*prc)/100;
	/* Overflow? */
	if(x > 32767) x=32767;
	if(y > 32767) y=32767;
	
	if((x==ox) && (y==oy))
		return(0);
	/* Eintragen */
	itoa((int)x, onew[ONPX].ob_spec.tedinfo->te_ptext, 10);
	num_stretch(onew[ONPX].ob_spec.tedinfo->te_ptext, 5);
	itoa((int)y, onew[ONPY].ob_spec.tedinfo->te_ptext, 10);
	num_stretch(onew[ONPY].ob_spec.tedinfo->te_ptext, 5);
	strcpy(onew[ONPCNT].ob_spec.tedinfo->te_ptext, "0100");
	new_mcalc();
	return(1);
}

void dial_new(int ob)
{
	OBJECT	*dinpop;
	int 		a, r, x, y;
	
	switch(ob)
	{
		case ONDIN:
			xrsrc_gaddr(0, DINPOP, &dinpop, xrsrc);
			objc_offset(onew, ONDIN, &x, &y);
			a=form_popup(dinpop, x, y);
			r=0;
			if(a >= DINA0H)
			{/* din_x/din_y enthalten LÑngen in mm */
				x=num_to_pix(din_x[a-DINA0H], 2, get_dpi());
				x=pix_to_num(x, onew[ONMODE].ob_type >> 8, get_dpi());
				y=num_to_pix(din_y[a-DINA0H], 2, get_dpi());
				y=pix_to_num(y, onew[ONMODE].ob_type >> 8, get_dpi());
				itoa(x, onew[ONPX].ob_spec.tedinfo->te_ptext, 10);
				itoa(y, onew[ONPY].ob_spec.tedinfo->te_ptext, 10);
				num_stretch(onew[ONPX].ob_spec.tedinfo->te_ptext, 5);
				num_stretch(onew[ONPY].ob_spec.tedinfo->te_ptext, 5);
				r=1;
			}
			else if(a >= DINA0Q)
			{/* Querformat -> x und y vertauschen */
				x=num_to_pix(din_y[a-DINA0Q], 2, get_dpi());
				x=pix_to_num(x, onew[ONMODE].ob_type >> 8, get_dpi());
				y=num_to_pix(din_x[a-DINA0Q], 2, get_dpi());
				y=pix_to_num(y, onew[ONMODE].ob_type >> 8, get_dpi());
				itoa(x, onew[ONPX].ob_spec.tedinfo->te_ptext, 10);
				itoa(y, onew[ONPY].ob_spec.tedinfo->te_ptext, 10);
				num_stretch(onew[ONPX].ob_spec.tedinfo->te_ptext, 5);
				num_stretch(onew[ONPY].ob_spec.tedinfo->te_ptext, 5);
				r=1;
			}
			if(r)
			{
				w_objc_draw(&wnew, ONPX, 8, sx,sy,sw,sh);
				w_objc_draw(&wnew, ONPY, 8, sx,sy,sw,sh);
				new_mcalc();
				w_objc_draw(&wnew, ONMEM, 8, sx ,sy, sw, sh);
			}
		break;
		case ONMODE:
			a=mode_popup(onew, ONMODE);
			if(a > 0)
			{
				x=ob_pix_to_num(onew, ONPX, ONMODE, get_dpi(), a);
				y=ob_pix_to_num(onew, ONPY, ONMODE, get_dpi(), a);
				set_ext_type(onew, ONMODE, a);
				itoa(x, onew[ONPX].ob_spec.tedinfo->te_ptext, 10);
				itoa(y, onew[ONPY].ob_spec.tedinfo->te_ptext, 10);
				num_stretch(onew[ONPX].ob_spec.tedinfo->te_ptext, 5);
				num_stretch(onew[ONPY].ob_spec.tedinfo->te_ptext, 5);
				w_objc_draw(&wnew, ONPX, 8, sx,sy,sw,sh);
				w_objc_draw(&wnew, ONPY, 8, sx,sy,sw,sh);				
				w_objc_draw(&wnew, ONMODE, 8, sx,sy,sw,sh);				
			}
		break;
		case ONPROP:
			if(onew[ONPROP].ob_state & SELECTED)
			{
				propx=atoi(onew[ONPX].ob_spec.tedinfo->te_ptext);
				propy=atoi(onew[ONPY].ob_spec.tedinfo->te_ptext);
				onew[ONGRAF].ob_spec.bitblk->bi_color=1; /* 1=Schwarz */
				w_objc_draw(&wnew, ONGRAF, 8, sx, sy, sw, sh);
			}
			else
			{
				onew[ONGRAF].ob_spec.bitblk->bi_color=9; /* 9=DGrau */
				w_objc_draw(&wnew, ONGRAF, 8, sx, sy, sw, sh);
			}
		break;
		case ONCALC:
			if(percent_calc())
				s_redraw(&wnew);
			w_unsel(&wnew, ONCALC);
		break;
		case ONOK:
			if( (ob_num_to_pix(onew, ONPX, ONMODE, get_dpi()) < 32) ||
					(ob_num_to_pix(onew, ONPY, ONMODE, get_dpi()) < 32)
				)
			{
				form_alert(1,"[3][Grape:|Die Mindestgrîûe betrÑgt 32*32 Pixel.|WÑhlen Sie eine grîûere Breite/Hîhe|oder erhîhen Sie die Auflîsung.][Abbruch]");
				w_unsel(&wnew, ONOK);
				break;
			}
			if(onew[ONOK].ob_spec.free_string[0]=='W')
			{/* Als Datei Ñndern aufgerufen */
				newsize_window(ob_num_to_pix(onew, ONPX, ONMODE, get_dpi()), ob_num_to_pix(onew, ONPY, ONMODE, get_dpi()));
			}
			else
			{/* Als Datei neu aufgerufen */
				new_file(ob_num_to_pix(onew, ONPX, ONMODE, get_dpi()), ob_num_to_pix(onew, ONPY, ONMODE, get_dpi()));
				new_preview_sel();
			}
		case ONABBRUCH:
			w_unsel(&wnew, ob);
			w_close(&wnew);
			w_kill(&wnew);
		break;
	}
}

int new_win_make(int ww, int height)
{
	int sx, sy, sw, sh, ox, oy, ow, oh, width;
	long l;
	unsigned long np;
	
	main_win.gadget=MOVE|NAME|CLOSE|HSLIDE|UPARROW|DNARROW|VSLIDE|LFARROW|RTARROW|FULL|SIZE;
	
	width=((ww/16)+1)*16;
	
	wind_get(0,WF_WORKXYWH, &sx, &sy, &sw, &sh);
	for(l=0; l < (long)height; ++l)
		table_offset[l]=(long)((long)l*(long)width);
	main_win.id=wind_create(main_win.gadget, sx, sy, sw, sh);
	if(main_win.id < 0)
		return(main_win.id);

	/* Offset */
	main_win.ox=0; main_win.oy=0;
	wind_set(main_win.id, WF_HSLIDE, 1,0,0,0); wind_set(main_win.id, WF_VSLIDE, 1,0,0,0);
	/* Position & Grîûe */
	strcpy(main_win.name, "[Grape] Unbenannt");
	np=(unsigned long)(main_win.name);
	wind_set(main_win.id, WF_NAME, (int)(np>>16), (int)(np & 0xffff),0,0);
	wind_calc(WC_BORDER, main_win.gadget, 100, 100, ww, height+otoolbar[0].ob_height+OTBB, &ox, &oy, &ow, &oh);
	ox=sx+64; oy=sy+64;
	if((ox+ow) > (sx+sw)) ow=sx+sw-ox-16;
	if(oy+oh > sy+sh-1) oh=sy+sh-1-oy;
	wind_open(main_win.id, ox, oy, ow, oh);
	wind_get(main_win.id, WF_WORKXYWH, &ox, &oy, &ow, &oh);
	oh-=otoolbar[0].ob_height+OTBB;
	l=(long)((long)ow*(long)1000); l/=(long)ww;
	wind_set(main_win.id, WF_HSLSIZE, (int)l,0,0,0); 
	l=(long)((long)oh*(long)1000); l/=(long)height;
 	wind_set(main_win.id, WF_VSLSIZE, (int)l,0,0,0);

	if(frame_data.ok)
	{
		if(frame_data.w > ww) frame_data.w=ww;
		if(frame_data.h > height) frame_data.h=height;
		if(frame_data.x > ww) frame_data.x=ww-frame_data.w;
		if(frame_data.y > height) frame_data.y=height-frame_data.h;
		if(frame_data.x+frame_data.w > ww)
			frame_data.x=ww-frame_data.w;
		if(frame_data.y+frame_data.h > height)
			frame_data.y=height-frame_data.h;
	}
		
	return(main_win.id);
}

int	new_file(int ww, int height)
{
	/* Gibt Fenster-ID oder -1 zurÅck (=kein Speicher) */
	
	int		width;
	long	siz;

	width=((ww/16)+1)*16;
	
	if(new_win_make(ww, height) < 0)
		return(main_win.id);
		
	siz=(long)((long)width*(long)height);
	
	first_lay=(LAY_LIST*)malloc(sizeof(LAY_LIST));
	first_mask=(MASK_LIST*)malloc(sizeof(MASK_LIST));
	if((!first_lay) || (!first_mask))
	{
		form_alert(1,"[3][Nicht genug Speicher!][Abbruch]");
		if(first_lay) free(first_lay);
		if(first_mask) free(first_mask);
		wind_close(main_win.id); 
		wind_delete(main_win.id); 
		main_win.id=-1; 
		return(-1);
	}

	first_lay->this.red=(void*)calloc(siz,1);
	first_lay->this.yellow=(void*)calloc(siz,1);
	first_lay->this.blue=(void*)calloc(siz,1);
	first_mask->this.mask=(void*)calloc(siz, 1);
	if((!first_lay->this.red) || (!first_lay->this.yellow) ||
		 (!first_lay->this.blue) || (!first_mask->this.mask))
	{
		form_alert(1,"[3][Nicht genug Speicher!][Abbruch]");
		if(first_lay->this.red) free(first_lay->this.red);
		if(first_lay->this.yellow) free(first_lay->this.yellow);
		if(first_lay->this.blue) free(first_lay->this.blue);
		if(first_mask->this.mask) free(first_mask->this.mask);
		wind_close(main_win.id); 
		wind_delete(main_win.id); 
		main_win.id=-1; 
		return(-1);
	}
	
	first_lay->this.width=ww;
	first_lay->this.height=height;
	first_lay->this.word_width=width;
	
	first_lay->this.id=layer_id=0;
	first_mask->this.id=mask_id=0;
	first_lay->this.changes=0;
	strcpy(first_lay->this.name, "Unbenannt");
	strcpy(first_mask->this.name, "Unbenannt");
	first_lay->this.selected=1;
	first_lay->this.type=1;
	first_lay->this.visible=1;
	first_lay->this.draw=1;
	first_lay->this.solo=1;
	first_mask->this.col=1;

	first_lay->prev=NULL;
	first_lay->next=NULL;
	
	first_mask->prev=NULL;
	first_mask->next=NULL;
	
	act_lay=first_lay;
	act_mask=first_mask;

	/* Maskenschalter aus */
	otoolbar[MASK_ON-1].ob_state &= (~SELECTED);
	otoolbar[MASK_VIS-1].ob_state &= (~SELECTED);
	otoolbar[MASK_ED-1].ob_state &= (~SELECTED);
	
	init_layob();

	return(main_win.id);
}


