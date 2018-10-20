#include <grape_h.h>
#include "magicmac.h"
#include "grape.h"
#include "undo.h"
#include "penedit.h"
#include "layer.h"
#include "mask.h"
#include "fill.h"
#include "ctcppt.h"
#include "maininit.h"
#include "ass_dith.h"
#include "mforms.h"
#include "zoom.h"
#include "stempel.h"

int	same_tip=0;
LAYER	*source_col;

/* Aktionsauswahl bei Klick ins Arbeitsfenster */
/* (Get-Color (Rechtsklick) oder Draw */
/* Bei Draw: Setzt alle Parameter fÅr den Draw-Aufruf */
/* Einmal normal, einmal fÅr solo */

/* Linksklick */
void work_on(int wid)
{/* Ruft je nach selektiertem Werkzeug die passende Routine */

	if(act_lay || (otoolbar[MASK_ED-1].ob_state & SELECTED))
	{
		switch(sel_tool)
		{
			case SDRAW:
				draw(wid);
			break;
			case SSELECT:
				frame(wid);
			break;
			case SFILL:
				fill(wid);
			break;
			case SSTICK:
				stick(wid);
			break;
			case SSTAMP:
				stempel(wid);
			break;
			case SZOOM:
				free_zoom_in(wid);
			break;
		}
	}
	else
		Bell();
}

/* Rechtsklick */
void right_on(int wid)
{
	if(act_lay || (otoolbar[MASK_ED-1].ob_state & SELECTED))
	{
		switch(sel_tool)
		{
			case SDRAW:
			case SFILL:
				cont_get_color();
			break;
			case SSELECT:
				object_frame(wid);
			break;
			case SSTICK:
				magic_mask(wid);
			break;
			case SSTAMP:
				get_stempel(wid);
			break;
			case SZOOM:
				free_zoom_out(wid);
			break;
		}
	}
	else
		Bell();
}


void del_source_lay(int id)
{/* Gibt Info, daû Layer ID entfernt wird. Funktion prÅft, ob
    dies die Zeichenfarbe-Source ist und setzt Farbe ggf. auf
    normal zurÅck */
   
	if(pen.source_lay_id==id)
		set_source_lay(-1);
}

void set_source_lay(int id)
{/* Setzt layer id als Source-Ebene fÅr Zeichenfarbe */
 /* ID kann auch -1 sein, dann wird die Ebene gelîscht */
 /* und die letzte aktive Zeichenfarbe gesetzt */

	/* Zeiger von setpix verwendet. Falls id=-1 muû Zeiger
		 gelîscht werden. Ansonsten wÅrde zwar mit Zeichenfarbe
		 gemalt aber immer noch aus source kopiert.
		 Wird eh von draw() neu gesetzt */
	source_col=NULL;
	
	pen.source_lay_id=id;
	pen.col.red=0;
	pen.col.yellow=0;
	pen.col.blue=0;
	fill_col_ob();
	if(wtool.open)
		w_objc_draw(&wtool, GPPCOL, 2, sx, sy, sw, sh);
	if(undo_on && (oundo[UALL].ob_state & SELECTED) && (ounopt[UORES3].ob_state & SELECTED))
	{
		free_undo();
		clear_undo();
		init_undo();
	}
}

void set_pen_col(CMY_COLOR *c)
{
	source_col=NULL;
	/* Farbe Åbernehmen */
	pen.col.red=c->red;
	pen.col.yellow=c->yellow;
	pen.col.blue=c->blue;
	pen.source_lay_id=-1;
	fill_col_ob();
	if(wtool.open)
		w_objc_draw(&wtool, GPPCOL, 2, sx, sy, sw, sh);
	if(undo_on && (oundo[UALL].ob_state & SELECTED) && (ounopt[UORES3].ob_state & SELECTED))
	{
		free_undo();
		clear_undo();
		init_undo();
	}
}

void get_color(int x, int y)
{/* Holt Farbe aus edit-Ebene an Stelle x,y */
	long			ad;
	CMY_COLOR col;
	
	ad=(long)((long)y*(long)act_lay->this.word_width+(long)x);
	if((act_lay) && !(otoolbar[MASK_ED-1].ob_state & SELECTED))
	{
		/* Farbe Åbernehmen */
		col.red=*(unsigned char*)((long)act_lay->this.red+ad);
		col.yellow=*(unsigned char*)((long)act_lay->this.yellow+ad);
		col.blue=*(unsigned char*)((long)act_lay->this.blue+ad);
	}
	else if((act_mask) && (otoolbar[MASK_ED-1].ob_state & SELECTED))
	{
		col.red=col.yellow=col.blue=*(unsigned char*)((long)act_mask->this.mask+ad);
	}
	else
	{
		Bell();
		return;
	}
 	if((Kbshift(-1) & 15) && (!(ospecial[STOLC].ob_state & DISABLED)))
 	{/* Umschalttaste->Toleranzfarbfeld fÅllen */
		set_grey(&col);
		set_tol_slider(&col);
	}
	else
		set_pen_col(&col);
}

int other_color(int x, int y)
{/* PrÅft, ob vielleicht ein col_ob getroffen wurde.
		Ja->1, Nein->0 */
  int				wid, ob, ox, oy, ix;
  WINDOW		*win;
	OBJECT		*tree;
	CMY_COLOR	col;
	
  wid=wind_find(x, y);
  win=w_find(wid);
  if(!win)
    return(0);
  /* Fenster von mir verwaltet */
 	if(!win->dialog)
 		return(0);
 	/* Ist Dialog_Fenster */
 	ob=objc_find(win->dinfo->tree, 0, 8, x, y);
 	if(ob < 1)
 		return(0);
 	/* öber Root-Objekt getroffen */
 	tree=win->dinfo->tree;
 	if(tree[ob].ob_state & DISABLED)
 		return(0);
 	if((tree[ob].ob_type & 255) != G_USERDEF)
 		return(0);
 	/* Userdef getroffen */
 	if( (((U_OB*)(tree[ob]_UP_))->type != 3) &&
	 		(((U_OB*)(tree[ob]_UP_))->type != 4) )
 		return(0);
 	/* Farbfeld getroffen */
 	/* Offset berechnen */
 	objc_offset(tree, ob, &ox, &oy);
 	/* Koordinaten im Farbfeld berechnen */
 	ox=x-ox; oy=y-oy;
 	/* Rahmen getroffen ? */
 	if((ox < 2) || (oy < 2))
 		return(0);
 	if((ox > tree[ob].ob_width-2) || (oy > tree[ob].ob_height-2))
 		return(0);
 	ix=ox+oy*((U_OB*)(tree[ob]_UP_))->color.w;
 	/* Voll rein->als Stiftfarbe setzen */
	if(tree == otool) /* Auûer das war die Stiftfarbe */
		return(0);
	col.red=((U_OB*)(tree[ob]_UP_))->color.r[ix];
	col.yellow=((U_OB*)(tree[ob]_UP_))->color.g[ix];
	col.blue=((U_OB*)(tree[ob]_UP_))->color.b[ix];
 	if((Kbshift(-1) & 15) && (!(ospecial[STOLC].ob_state & DISABLED)) &&
 			((tree!=ospecial)||(ob!=STOLC)))
 	{/* Umschalttaste->Toleranzfarbfeld fÅllen */
		set_grey(&col);
		set_tol_slider(&col);
	}
	else
		set_pen_col(&col);
	return(1);
}

void cont_get_color(void)
{
	int wx, wy, ww, wh, mx, my, ox=0, oy=0, but, dum;
	
	wind_update(BEG_UPDATE);
	wind_update(BEG_MCTRL);
	graf_mouse(USER_DEF, UD_PIPETTE);
	
	wind_get(main_win.id, WF_WORKXYWH, &wx, &wy, &ww, &wh);
	wy+=(otoolbar[0].ob_height+OTBB);
	wh-=(otoolbar[0].ob_height+OTBB);
	if(ww > (first_lay->this.width/DZOP-main_win.ox))
		ww=(first_lay->this.width/DZOP-main_win.ox);
	if(wh > (first_lay->this.height/DZOP-main_win.oy))
		wh=(first_lay->this.height/DZOP-main_win.oy);
	
	do
	{
		graf_mkstate(&mx, &my, &but, &dum);

		if((mx != ox) || (my != oy))
		{
			if((mx >= wx) && (mx < wx+ww) && (my >= wy) && (my < wy+wh))
			{
				graf_mouse(USER_DEF, UD_PIPETTE);
				get_color((mx-wx+main_win.ox)*MZOP, (my-wy+main_win.oy)*MZOP);
			}
			else
			{
				if(other_color(mx, my))
					graf_mouse(USER_DEF, UD_PIPETTE);
				else
					graf_mouse(USER_DEF, UD_CROSS);
			}

			ox=mx;
			oy=my;
		}
	}while(but & 2);
	
	graf_mouse(ARROW, NULL);
	wind_update(END_MCTRL);
	wind_update(END_UPDATE);
}

/*
**
 Zeichnen 
** 
*/
/* Linien/Punkt-Aufruf */

void solo_line_draw(int x1, int y1, int x2, int y2, int pres1, int pres2)
{
	int	x, y, ox=-1, oy=-1, wx, wy, ww, wh;
	int	dx, dy, step, opres=0, pres;
	int wid=main_win.id;
	register int px, py, sex, ssx, sey, ssy;
	double c, cdif, tpres, spres;
	

	same_tip=0;
	wind_update(BEG_UPDATE);
	wind_update(BEG_MCTRL);
	wind_get(wid, WF_WORKXYWH, &wx, &wy, &ww, &wh);
	wy+=otoolbar[0].ob_height+OTBB; wh-=otoolbar[0].ob_height+OTBB;
	/* Mit Screen blitten */
	if(wx < sx)
		wx=sx;
	if(wy < sy)
		wy=sy;
	if((wx+ww) > (sx+sw))
		ww=sx+sw-wx;
	if((wy+wh) > (sy+sh))
		wh=sy+sh-wy;
		
	c_lasur=pen.col.lasur;
	if(pen.d_type > 1)
		c_plusminus=pen.d_type;
	else
		c_plusminus=0;
	c_add=pen.d_type;
	p_red=act_lay->this.red;
	p_yellow=act_lay->this.yellow;
	p_blue=act_lay->this.blue;
	p_screen=(void*)((long)((long)physbase+(long)wy*(long)roff+(long)wx));

	if(otoolbar[MASK_ON-1].ob_state & SELECTED)
	{
		mask_activ=1;
		p_mask=act_mask->this.mask;
	}
	else
		mask_activ=0;

	p_width=(long)first_lay->this.word_width;
	screen_width=roff;

	/* Tabellen-Farbe nehmen */
	c_red=pen.col.red;
	c_yellow=pen.col.yellow;
	c_blue=pen.col.blue;

	if(otoolbar[MASK_ED-1].ob_state & SELECTED)
	{
		p_edmask=act_mask->this.mask;
		painted_mask=act_mask;
		mask_edit=1;
		c_mask=pen.col.grey;
		undo_id=act_mask->this.id | 512;
	}
	else
	{
		mask_edit=0;
		painted_lay=act_lay;
		undo_id=act_lay->this.id;
		act_lay->this.changes=1;
		actize_win_name();
	}

	if(undo_on && (oundo[UALL].ob_state & SELECTED) && (ounopt[UORES1].ob_state & SELECTED))
	{
		free_undo();
		clear_undo();
		init_undo();
	}

	x1-=main_win.ox; x2-=main_win.ox;
	y1-=main_win.oy; y2-=main_win.oy;
	x1+=wx; x2+=wx;
	y1+=wy; y2+=wy;
	
	if(x1 < wx) x1=wx;
	if(x2 < wx) x2=wx;
	if(x1 > wx+ww) x1=wx+ww;
	if(x2 > wx+ww) x2=wx+ww;
	if(y1 < wy) y1=wy;
	if(y2 < wy) y2=wy;
	if(y1 > wy+wh) y1=wy+wh;
	if(y2 > wy+wh) y2=wy+wh;

	ox=x1;
	oy=y1;
	opres=pres1;
	x=x2;
	y=y2;
	pres=pres2;
	step=pen.tip[pres]->max/pen.step;
	if(!step)
		step=1;
	if(!pen.line)
		step=pen.tip[max(pres2,pres1)]->dl;
			
	graf_mouse(M_OFF, NULL);


	ssx=ox-wx;
	ssy=oy-wy;
	sex=x-wx;
	sey=y-wy;
	dx=abs(sex-ssx);
	dy=abs(sey-ssy);

	tpres=opres;
	
	if(!dx && !dy)
	{
		solo_setpix(sex,sey,ww,wh,pres);
	}
	else if(dx < dy)
	{ /* Y-Lauf */
		if(!dx)
		{
			spres=(double)(((double)pres-(double)opres)*(double)step)/(fabs((double)sey-(double)ssy));
			if(sey < ssy)
			{
				for(py = ssy; py >=sey; py-=step)
				{
					solo_setpix(sex, py, ww, wh, tpres);
					tpres+=spres;
				}
			}
			else
			{
				for(py = ssy; py <=sey; py+=step)
				{
					solo_setpix(sex, py, ww, wh, tpres);
					tpres+=spres;
				}
			}
		}
		else
		{
			/* Steigung */
			cdif=(double)(((double)sex-(double)ssx))/((double)sey-(double)ssy);
			spres=(double)(((double)pres-(double)opres)*(double)step)/(fabs((double)sey-(double)ssy));
			if(sey < ssy)
			{
				for(py = ssy; py >=sey; py-=step)
				{
					px=py-ssy;
					c=((double)px)*cdif;
					px=c+ssx;
					solo_setpix(px, py, ww, wh, tpres);
					tpres+=spres;
				}
			}
			else
			{
				for(py = ssy; py <=sey; py+=step)
				{
					px=py-ssy;
					c=((double)px)*cdif;
					px=c+ssx;
					solo_setpix(px, py, ww, wh, tpres);
					tpres+=spres;
				}
			}
		}
	}
	else
	{ /* X-Lauf */
		if(!dy)
		{
			spres=(double)(((double)pres-(double)opres)*(double)step)/(fabs((double)sex-(double)ssx));
			if(sex < ssx)
			{
				for(px = ssx; px >=sex; px-=step)
				{
					solo_setpix(px, sey, ww, wh, tpres);
					tpres+=spres;
				}
			}
			else
			{
				for(px = ssx; px <=sex; px+=step)
				{
					solo_setpix(px, sey, ww, wh, tpres);
					tpres+=spres;
				}
			}
		}
		else
		{
			/* Steigung */
			cdif=(double)(((double)sey-(double)ssy))/((double)sex-(double)ssx);
			spres=(double)(((double)pres-(double)opres)*(double)step)/(fabs((double)sex-(double)ssx));
			if(sex < ssx)
			{
				for(px = ssx; px >=sex; px-=step)
				{
					py=px-ssx;
					c=((double)py)*cdif;
					py=c+ssy;
					solo_setpix(px, py, ww, wh, tpres);
					tpres+=spres;
				}
			}
			else
			{
				for(px = ssx; px <=sex; px+=step)
				{
					py=px-ssx;
					c=((double)py)*cdif;
					py=c+ssy;
					solo_setpix(px, py, ww, wh, tpres);
					tpres+=spres;
				}
			}
		}
	}

	graf_mouse(M_ON, NULL);
	
	/* Endemarkierung in Undopuffer schreiben */
	
		*undo_end++=0;
		*undo_end++=255; /* Typ nÑchstes Zeigerpaar */
		*(unsigned long*)undo_end=0; /* Zeiger auf Blockanfang ist Null*/
		undo_end+=4;
		*(unsigned long*)undo_end=0; /* Zeiger auf letzten Eintrag ist Null*/
		undo_end+=4;
		*(unsigned long*)undo_end=14; /* Zeiger auf Grîûe*/
		undo_end+=4;

		undo_end-=14; /* ZurÅcksetzen auf Eintrag */
			
	wind_update(END_MCTRL);
	wind_update(END_UPDATE);
	display_undo();
}

void line_draw(int x1, int y1, int x2, int y2, int pres1, int pres2)
{
	int	a, x, y, ox=-1, oy=-1, wx, wy, ww, wh;
	int	dx, dy, step, opres=0, pres;
	int wid=main_win.id;
	register int px, py, sex, ssx, sey, ssy;
	double c, cdif, spres, tpres;
	LAY_LIST *l=first_lay;

	if(pen.source_lay_id > -1)
		source_col=find_layer_id(pen.source_lay_id);
			
	if((otoolbar[LAYLED].ob_spec.bitblk->bi_color==3) &&
			!(otoolbar[MASK_VIS-1].ob_state & SELECTED))
	{/* Solo an */
		c_solo=1;
		solo_line_draw(x1, y1, x2, y2, pres1, pres2);
		return;
	}

	c_solo=0;
	
	same_tip=0;
	wind_update(BEG_UPDATE);
	wind_update(BEG_MCTRL);
	wind_get(wid, WF_WORKXYWH, &wx, &wy, &ww, &wh);
	wy+=otoolbar[0].ob_height+OTBB; wh-=otoolbar[0].ob_height+OTBB;
	/* Mit Screen blitten */
	if(wx < sx)
		wx=sx;
	if(wy < sy)
		wy=sy;
	if((wx+ww) > (sx+sw))
		ww=sx+sw-wx;
	if((wy+wh) > (sy+sh))
		wh=sy+sh-wy;
		
	c_lasur=pen.col.lasur;
	if(pen.d_type > 1)
		c_plusminus=pen.d_type;
	else
		c_plusminus=0;
	c_add=pen.d_type;

	/* Layer-Listen vorbereiten */
	a=count_layers();
	if(red_list) free(red_list);
	if(yellow_list) free(yellow_list);
	if(blue_list) free(blue_list);
	if(type_list) free(type_list);
	red_list=(void**)malloc((a+1)*sizeof(unsigned char*));
	yellow_list=(void**)malloc((a+1)*sizeof(unsigned char*));
	blue_list=(void**)malloc((a+1)*sizeof(unsigned char*));
	type_list=(int*)malloc((a+1)*sizeof(int));
	if((!red_list)||(!yellow_list)||(!blue_list)||(!type_list))
	{
		form_alert(1,"[3][Nicht genug Speicher|fÅr Redraw!][Abbruch]");
		if(red_list) free(red_list);
		if(yellow_list) free(yellow_list);
		if(blue_list) free(blue_list);
		if(type_list) free(type_list);
		return;
	}
	
  /* Letzte Plane finden, die nicht incl. weiû-deckend ist */
	while(l->next && ((l->this.type != 2) ||
				((l->this.type == 2)	&& !(l->this.visible)))
			 ) l=l->next;

	a=0;
	while(l)
	{
		if(l->this.visible)
		{
			red_list[a]=l->this.red;
			yellow_list[a]=l->this.yellow;
			blue_list[a]=l->this.blue;
			type_list[a]=0;
			if(l->this.type)
				type_list[a]|=1;
			if(l->this.visible & DISABLED)
				type_list[a]|=2;
			++a;
		}
		l=l->prev;
	}

	if(otoolbar[MASK_VIS-1].ob_state & SELECTED)
	{
		if(mask_col_tab[act_mask->this.col] & 1)
			red_list[a]=act_mask->this.mask; 
		else
			red_list[a]=NULL;
		if(mask_col_tab[act_mask->this.col] & 2)
			yellow_list[a]=act_mask->this.mask; 
		else
			yellow_list[a]=NULL;
		if(mask_col_tab[act_mask->this.col] & 4)
			blue_list[a]=act_mask->this.mask; 
		else
			blue_list[a]=NULL;

		type_list[a]=0;
		++a;
	}
		
	type_list[a]=-1;
	red_list[a]=NULL;
	yellow_list[a]=NULL;
	blue_list[a]=NULL;

	if(otoolbar[MASK_ON-1].ob_state & SELECTED)
	{ /* Maske ist aktiv */
		p_mask=act_mask->this.mask;
		mask_activ=1;
	}
	else
		mask_activ=0;
		

	c_layers=a; /* Anzahl der Ebenen, falls 0 passiert nix */

	p_red=act_lay->this.red;
	p_yellow=act_lay->this.yellow;
	p_blue=act_lay->this.blue;
	p_screen=(void*)((long)((long)physbase+(long)wy*(long)roff+(long)wx));
	p_width=(long)first_lay->this.word_width;
	screen_width=roff;

	dst_blue=lsb_c;
	dst_red=lsb_m;
	dst_yellow=lsb_y;
	
	/* Tabellen-Farbe nehmen */
	c_red=pen.col.red;
	c_yellow=pen.col.yellow;
	c_blue=pen.col.blue;

	if(otoolbar[MASK_ED-1].ob_state & SELECTED)
	{
		p_edmask=act_mask->this.mask;
		painted_mask=act_mask;
		mask_edit=1;
		c_mask=pen.col.grey;
		undo_id=act_mask->this.id | 512;
	}
	else
	{
		act_lay->this.changes=1;
		painted_lay=act_lay;
		actize_win_name();
		mask_edit=0;
		undo_id=act_lay->this.id;
	}
	
	if(undo_on && (oundo[UALL].ob_state & SELECTED) && (ounopt[UORES1].ob_state & SELECTED))
	{
		free_undo();
		clear_undo();
		init_undo();
	}
	

	x1-=main_win.ox; x2-=main_win.ox;
	y1-=main_win.oy; y2-=main_win.oy;
	x1+=wx; x2+=wx;
	y1+=wy; y2+=wy;
	
	if(x1 < wx) x1=wx;
	if(x2 < wx) x2=wx;
	if(x1 > wx+ww) x1=wx+ww;
	if(x2 > wx+ww) x2=wx+ww;
	if(y1 < wy) y1=wy;
	if(y2 < wy) y2=wy;
	if(y1 > wy+wh) y1=wy+wh;
	if(y2 > wy+wh) y2=wy+wh;

	ox=x1;
	oy=y1;
	opres=pres1;
	x=x2;
	y=y2;
	pres=pres2;
	step=pen.tip[pres]->max/pen.step;
	if(!step)
		step=1;
	if(!pen.line)
		step=pen.tip[max(pres2,pres1)]->dl;
			
	graf_mouse(M_OFF, NULL);


	ssx=ox-wx;
	ssy=oy-wy;
	sex=x-wx;
	sey=y-wy;
	dx=abs(sex-ssx);
	dy=abs(sey-ssy);

	tpres=opres;
	
	if(!dx && !dy)
	{
		setpix(sex,sey,ww,wh,pres);
	}
	else if(dx < dy)
	{ /* Y-Lauf */
		if(!dx)
		{
			spres=(double)(((double)pres-(double)opres)*(double)step)/(fabs((double)sey-(double)ssy));
			if(sey < ssy)
			{
				for(py = ssy; py >=sey; py-=step)
				{
					setpix(sex, py, ww, wh, (int)tpres);
					tpres+=spres;
				}
			}
			else
			{
				for(py = ssy; py <=sey; py+=step)
				{
					setpix(sex, py, ww, wh, (int)tpres);
					tpres+=spres;
				}
			}
		}
		else
		{
			/* Steigung */
			cdif=(double)(((double)sex-(double)ssx))/((double)sey-(double)ssy);
			spres=(double)(((double)pres-(double)opres)*(double)step)/(fabs((double)sey-(double)ssy));
			if(sey < ssy)
			{
				for(py = ssy; py >=sey; py-=step)
				{
					px=py-ssy;
					c=((double)px)*cdif;
					px=c+ssx;
					setpix(px, py, ww, wh, (int)tpres);
					tpres+=spres;
				}
			}
			else
			{
				for(py = ssy; py <=sey; py+=step)
				{
					px=py-ssy;
					c=((double)px)*cdif;
					px=c+ssx;
					setpix(px, py, ww, wh, (int)tpres);
					tpres+=spres;
				}
			}
		}
	}
	else
	{ /* X-Lauf */
		if(!dy)
		{
			spres=(double)(((double)pres-(double)opres)*(double)step)/(fabs((double)sex-(double)ssx));
			if(sex < ssx)
			{
				for(px = ssx; px >=sex; px-=step)
				{
					setpix(px, sey, ww, wh, (int)tpres);
					tpres+=spres;
				}
			}
			else
			{
				for(px = ssx; px <=sex; px+=step)
				{
					setpix(px, sey, ww, wh, (int)tpres);
					tpres+=spres;
				}
			}
		}
		else
		{
			/* Steigung */
			cdif=(double)(((double)sey-(double)ssy))/((double)sex-(double)ssx);
			spres=(double)(((double)pres-(double)opres)*(double)step)/(fabs((double)sex-(double)ssx));
			if(sex < ssx)
			{
				for(px = ssx; px >=sex; px-=step)
				{
					py=px-ssx;
					c=((double)py)*cdif;
					py=c+ssy;
					setpix(px, py, ww, wh, (int)tpres);
					tpres+=spres;
				}
			}
			else
			{
				for(px = ssx; px <=sex; px+=step)
				{
					py=px-ssx;
					c=((double)py)*cdif;
					py=c+ssy;
					setpix(px, py, ww, wh, (int)tpres);
					tpres+=spres;
				}
			}
		}
	}

	graf_mouse(M_ON, NULL);
	
	/* Endemarkierung in Undopuffer schreiben */
	
		*undo_end++=0;
		*undo_end++=255; /* Typ nÑchstes Zeigerpaar */
		*(unsigned long*)undo_end=0; /* Zeiger auf Blockanfang ist Null*/
		undo_end+=4;
		*(unsigned long*)undo_end=0; /* Zeiger auf letzten Eintrag ist Null*/
		undo_end+=4;
		*(unsigned long*)undo_end=14; /* Zeiger auf Grîûe*/
		undo_end+=4;

		undo_end-=14; /* ZurÅcksetzen auf Eintrag */
			
	wind_update(END_MCTRL);
	wind_update(END_UPDATE);
	display_undo();
}


/* Event-Aufruf */

void draw(int wid)
{
	int	a, b, x, y, ox=-1, oy=-1, omax=0, wx, wy, ww, wh, dum;
	int	dx, dy, step, opres=0, pres, again=0, again_count=0, orgwx, orgwy;
	register int px, py, tpres, spres, sex, ssx, sey, ssy;
	double c, cdif;
	LAY_LIST *l=first_lay;

	if(zoomin)
	{/* Parameter fÅr Redrawroutine */
		first_zix=first_ziy=zoomin; /* Zeichen-Redraw findet immer auf ganzen Pixeln statt */
		add_x=add_y=zoomin;
	}
	
	if(pen.source_lay_id > -1)
		source_col=find_layer_id(pen.source_lay_id);
			
	if((otoolbar[LAYLED].ob_spec.bitblk->bi_color==3) &&
			!(otoolbar[MASK_VIS-1].ob_state & SELECTED))
	{/* Solo an */
		c_solo=1;
		solo_draw(wid);
		return;
	}

	c_solo=0;
	
	same_tip=0;
	wind_update(BEG_UPDATE);
	wind_update(BEG_MCTRL);
	wind_get(wid, WF_WORKXYWH, &wx, &wy, &ww, &wh);
	wy+=otoolbar[0].ob_height+OTBB; wh-=otoolbar[0].ob_height+OTBB;
	if(ww > (first_lay->this.width/DZOP-main_win.ox))
		ww=(first_lay->this.width/DZOP-main_win.ox);
	if(wh > (first_lay->this.height/DZOP-main_win.oy))
		wh=(first_lay->this.height/DZOP-main_win.oy);
	/* Mit Screen blitten */
	if(wx < sx)
		wx=sx;
	if(wy < sy)
		wy=sy;
	if((wx+ww) > (sx+sw))
		ww=sx+sw-wx;
	if((wy+wh) > (sy+sh))
		wh=sy+sh-wy;
		
	c_lasur=pen.col.lasur;
	if(pen.d_type > 1)
		c_plusminus=pen.d_type;
	else
		c_plusminus=0;
	c_add=pen.d_type;

	/* Layer-Listen vorbereiten */
	a=count_layers();
	if(red_list) free(red_list);
	if(yellow_list) free(yellow_list);
	if(blue_list) free(blue_list);
	if(type_list) free(type_list);
	red_list=(void**)malloc((a+1)*sizeof(unsigned char*));
	yellow_list=(void**)malloc((a+1)*sizeof(unsigned char*));
	blue_list=(void**)malloc((a+1)*sizeof(unsigned char*));
	type_list=(int*)malloc((a+1)*sizeof(int));
	if((!red_list)||(!yellow_list)||(!blue_list)||(!type_list))
	{
		form_alert(1,"[3][Nicht genug Speicher|fÅr Redraw!][Abbruch]");
		if(red_list) free(red_list);
		if(yellow_list) free(yellow_list);
		if(blue_list) free(blue_list);
		if(type_list) free(type_list);
		return;
	}
	
  /* Letzte Plane finden, die nicht incl. weiû-deckend ist */
	while(l->next && ((l->this.type != 2) ||
				((l->this.type == 2)	&& !(l->this.visible)))
			 ) l=l->next;

	a=0;
	while(l)
	{
		if(l->this.visible)
		{
			red_list[a]=l->this.red;
			yellow_list[a]=l->this.yellow;
			blue_list[a]=l->this.blue;
			type_list[a]=0;
			if(l->this.type)
				type_list[a]|=1;
			if(l->this.visible & DISABLED)
				type_list[a]|=2;
			++a;
		}
		l=l->prev;
	}

	if(otoolbar[MASK_VIS-1].ob_state & SELECTED)
	{
		if(mask_col_tab[act_mask->this.col] & 1)
			red_list[a]=act_mask->this.mask; 
		else
			red_list[a]=NULL;
		if(mask_col_tab[act_mask->this.col] & 2)
			yellow_list[a]=act_mask->this.mask; 
		else
			yellow_list[a]=NULL;
		if(mask_col_tab[act_mask->this.col] & 4)
			blue_list[a]=act_mask->this.mask; 
		else
			blue_list[a]=NULL;

		type_list[a]=0;
		++a;
	}
		
	type_list[a]=-1;
	red_list[a]=NULL;
	yellow_list[a]=NULL;
	blue_list[a]=NULL;

	if(otoolbar[MASK_ON-1].ob_state & SELECTED)
	{ /* Maske ist aktiv */
		p_mask=act_mask->this.mask;
		mask_activ=1;
	}
	else
		mask_activ=0;
		

	c_layers=a; /* Anzahl der Ebenen, falls 0 passiert nix */

	p_red=act_lay->this.red;
	p_yellow=act_lay->this.yellow;
	p_blue=act_lay->this.blue;
	p_screen=(void*)((long)((long)physbase+(long)wy*(long)roff+(long)wx));
	p_width=(long)first_lay->this.word_width;
	screen_width=roff;

	dst_blue=lsb_c;
	dst_red=lsb_m;
	dst_yellow=lsb_y;
	
	/* Tabellen-Farbe nehmen */
	c_red=pen.col.red;
	c_yellow=pen.col.yellow;
	c_blue=pen.col.blue;

	if(otoolbar[MASK_ED-1].ob_state & SELECTED)
	{
		p_edmask=act_mask->this.mask;
		painted_mask=act_mask;
		mask_edit=1;
		c_mask=pen.col.grey;
		undo_id=act_mask->this.id | 512;
	}
	else
	{
		act_lay->this.changes=1;
		painted_lay=act_lay;
		actize_win_name();
		mask_edit=0;
		undo_id=act_lay->this.id;
	}
	
	if(undo_on && (oundo[UALL].ob_state & SELECTED) && (ounopt[UORES1].ob_state & SELECTED))
	{
		free_undo();
		clear_undo();
		init_undo();
	}
	
	orgwx=wx;
	orgwy=wy;
	wx=wx*MZOP;
	wy=wy*MZOP;
	ww=ww*MZOP;
	wh=wh*MZOP;
	do
	{
		graf_mkstate(&x, &y, &b, &dum);
		x=(x-orgwx)*MZOP+wx;
		y=(y-orgwy)*MZOP+wy;
		pres=(int)asgc->pressure;
		step=pen.tip[pres]->max/pen.step;
		if(!step)
			step=1;
		if(!pen.line)
			step=10000;
			
		if( ((x != ox) || (y != oy)) &&
				((x-(pen.tip[pres]->dl|1) <= ox-omax) ||
				 (x+pen.tip[pres]->dr >= ox+omax) ||
				 (y-(pen.tip[pres]->du|1) <= oy-omax) ||
				 (y+pen.tip[pres]->dd >= oy+omax) 
				) ||
				again
			)
		{
			if(again)
				again=0;
			graf_mouse(M_OFF, NULL);


			if((ox == -1) && (oy == -1))
				{ox=x; oy=y; opres=pres;}
				
			if((x >= wx) && (x < (wx+ww)) && (y >= wy) && (y < (wy+wh)))
			{
				ssx=ox-wx;
				ssy=oy-wy;
				sex=x-wx;
				sey=y-wy;
				dx=abs(sex-ssx);
				dy=abs(sey-ssy);

				tpres=opres;
				
				if(!dx && !dy)
				{
					setpix(sex,sey,ww,wh,pres);
				}
				else if(dx < dy)
				{ /* Y-Lauf */
					if(!dx)
					{
						spres=((pres-opres)*step)/(abs(sey-ssy));
						if(sey < ssy)
						{
							for(py = ssy; py >=sey; py-=step)
							{
								setpix(sex, py, ww, wh, tpres);
								tpres+=spres;
							}
						}
						else
						{
							for(py = ssy; py <=sey; py+=step)
							{
								setpix(sex, py, ww, wh, tpres);
								tpres+=spres;
							}
						}
					}
					else
					{
						/* Steigung */
						cdif=(double)(((double)sex-(double)ssx))/((double)sey-(double)ssy);
						spres=((pres-opres)*step)/(abs(sey-ssy));
						if(sey < ssy)
						{
							for(py = ssy; py >=sey; py-=step)
							{
								px=py-ssy;
								c=((double)px)*cdif;
								px=c+ssx;
								setpix(px, py, ww, wh, tpres);
								tpres+=spres;
							}
						}
						else
						{
							for(py = ssy; py <=sey; py+=step)
							{
								px=py-ssy;
								c=((double)px)*cdif;
								px=c+ssx;
								setpix(px, py, ww, wh, tpres);
								tpres+=spres;
							}
						}
					}
				}
				else
				{ /* X-Lauf */
					if(!dy)
					{
						spres=((pres-opres)*step)/(abs(sex-ssx));
						if(sex < ssx)
						{
							for(px = ssx; px >=sex; px-=step)
							{
								setpix(px, sey, ww, wh, tpres);
								tpres+=spres;
							}
						}
						else
						{
							for(px = ssx; px <=sex; px+=step)
							{
								setpix(px, sey, ww, wh, tpres);
								tpres+=spres;
							}
						}
					}
					else
					{
						/* Steigung */
						cdif=(double)(((double)sey-(double)ssy))/((double)sex-(double)ssx);
						spres=((pres-opres)*step)/(abs(sex-ssx));
						if(sex < ssx)
						{
							for(px = ssx; px >=sex; px-=step)
							{
								py=px-ssx;
								c=((double)py)*cdif;
								py=c+ssy;
								setpix(px, py, ww, wh, tpres);
								tpres+=spres;
							}
						}
						else
						{
							for(px = ssx; px <=sex; px+=step)
							{
								py=px-ssx;
								c=((double)py)*cdif;
								py=c+ssy;
								setpix(px, py, ww, wh, tpres);
								tpres+=spres;
							}
						}
					}
				}

			}
			else
			{ x=-1; y=-1; }
			ox=x;
			oy=y;
			omax=pen.tip[pres]->max;
			opres=pres;

			graf_mouse(M_ON, NULL);
		}
		else if(pen.d_type == 1)
		{
			again_count+=pen.f_speed;
			if(again_count > 1000)
			{
				again_count=0;
				again=1;
			}
		}
	}while(b);
	
	/* Endemarkierung in Undopuffer schreiben */
	
		*undo_end++=0;
		*undo_end++=255; /* Typ nÑchstes Zeigerpaar */
		*(unsigned long*)undo_end=0; /* Zeiger auf Blockanfang ist Null*/
		undo_end+=4;
		*(unsigned long*)undo_end=0; /* Zeiger auf letzten Eintrag ist Null*/
		undo_end+=4;
		*(unsigned long*)undo_end=14; /* Zeiger auf Grîûe*/
		undo_end+=4;

		undo_end-=14; /* ZurÅcksetzen auf Eintrag */
			
	wind_update(END_MCTRL);
	wind_update(END_UPDATE);
	display_undo();
}

void solo_draw(int wid)
{
	int	b, x, y, ox=-1, oy=-1, omax=0, wx, wy, ww, wh, dum;
	int	dx, dy, step, opres=0, pres, again=0, again_count=0, orgwx, orgwy;
	register int px, py, tpres, spres, sex, ssx, sey, ssy;
	double c, cdif;
	

	same_tip=0;
	wind_update(BEG_UPDATE);
	wind_update(BEG_MCTRL);
	wind_get(wid, WF_WORKXYWH, &wx, &wy, &ww, &wh);
	wy+=otoolbar[0].ob_height+OTBB; wh-=otoolbar[0].ob_height+OTBB;
	if(ww > (first_lay->this.width/DZOP-main_win.ox))
		ww=(first_lay->this.width/DZOP-main_win.ox);
	if(wh > (first_lay->this.height/DZOP-main_win.oy))
		wh=(first_lay->this.height/DZOP-main_win.oy);
	/* Mit Screen blitten */
	if(wx < sx)
		wx=sx;
	if(wy < sy)
		wy=sy;
	if((wx+ww) > (sx+sw))
		ww=sx+sw-wx;
	if((wy+wh) > (sy+sh))
		wh=sy+sh-wy;
		
	c_lasur=pen.col.lasur;
	if(pen.d_type > 1)
		c_plusminus=pen.d_type;
	else
		c_plusminus=0;
	c_add=pen.d_type;
	p_red=act_lay->this.red;
	p_yellow=act_lay->this.yellow;
	p_blue=act_lay->this.blue;
	p_screen=(void*)((long)((long)physbase+(long)wy*(long)roff+(long)wx));

	if(otoolbar[MASK_ON-1].ob_state & SELECTED)
	{
		mask_activ=1;
		p_mask=act_mask->this.mask;
	}
	else
		mask_activ=0;

	p_width=(long)first_lay->this.word_width;
	screen_width=roff;

	/* Tabellen-Farbe nehmen */
	c_red=pen.col.red;
	c_yellow=pen.col.yellow;
	c_blue=pen.col.blue;

	if(otoolbar[MASK_ED-1].ob_state & SELECTED)
	{
		p_edmask=act_mask->this.mask;
		painted_mask=act_mask;
		mask_edit=1;
		c_mask=pen.col.grey;
		undo_id=act_mask->this.id | 512;
	}
	else
	{
		mask_edit=0;
		painted_lay=act_lay;
		undo_id=act_lay->this.id;
		act_lay->this.changes=1;
		actize_win_name();
	}

	if(undo_on && (oundo[UALL].ob_state & SELECTED) && (ounopt[UORES1].ob_state & SELECTED))
	{
		free_undo();
		clear_undo();
		init_undo();
	}
	
	/* Fensterkoordinaten in 1:1 sichtbaren Ausschnitt umrechnen */
	orgwx=wx;
	orgwy=wy;
	wx=wx*MZOP;
	wy=wy*MZOP;
	ww=ww*MZOP;
	wh=wh*MZOP;
	do
	{
		graf_mkstate(&x, &y, &b, &dum);
		x=(x-orgwx)*MZOP+wx;
		y=(y-orgwy)*MZOP+wy;
		pres=(int)asgc->pressure;
		step=pen.tip[pres]->max/pen.step;
		if(!step)
			step=1;
		if(!pen.line)
			step=10000;
			
		if( ((x != ox) || (y != oy)) &&
				((x-(pen.tip[pres]->dl|1) <= ox-omax) ||
				 (x+pen.tip[pres]->dr >= ox+omax) ||
				 (y-(pen.tip[pres]->du|1) <= oy-omax) ||
				 (y+pen.tip[pres]->dd >= oy+omax) 
				) ||
				again
			)
		{
			if(again)
				again=0;
			graf_mouse(M_OFF, NULL);


			if((ox == -1) && (oy == -1))
				{ox=x; oy=y; opres=pres;}
				
			if((x >= wx) && (x < (wx+ww)) && (y >= wy) && (y < (wy+wh)))
			{
				ssx=(ox-wx);
				ssy=(oy-wy);
				sex=(x-wx);
				sey=(y-wy);
				dx=abs(sex-ssx);
				dy=abs(sey-ssy);

				tpres=opres;
				
				if(!dx && !dy)
				{
					solo_setpix(sex,sey,ww,wh,pres);
				}
				else if(dx < dy)
				{ /* Y-Lauf */
					if(!dx)
					{
						spres=((pres-opres)*step)/(abs(sey-ssy));
						if(sey < ssy)
						{
							for(py = ssy; py >=sey; py-=step)
							{
								solo_setpix(sex, py, ww, wh, tpres);
								tpres+=spres;
							}
						}
						else
						{
							for(py = ssy; py <=sey; py+=step)
							{
								solo_setpix(sex, py, ww, wh, tpres);
								tpres+=spres;
							}
						}
					}
					else
					{
						/* Steigung */
						cdif=(double)(((double)sex-(double)ssx))/((double)sey-(double)ssy);
						spres=((pres-opres)*step)/(abs(sey-ssy));
						if(sey < ssy)
						{
							for(py = ssy; py >=sey; py-=step)
							{
								px=py-ssy;
								c=((double)px)*cdif;
								px=c+ssx;
								solo_setpix(px, py, ww, wh, tpres);
								tpres+=spres;
							}
						}
						else
						{
							for(py = ssy; py <=sey; py+=step)
							{
								px=py-ssy;
								c=((double)px)*cdif;
								px=c+ssx;
								solo_setpix(px, py, ww, wh, tpres);
								tpres+=spres;
							}
						}
					}
				}
				else
				{ /* X-Lauf */
					if(!dy)
					{
						spres=((pres-opres)*step)/(abs(sex-ssx));
						if(sex < ssx)
						{
							for(px = ssx; px >=sex; px-=step)
							{
								solo_setpix(px, sey, ww, wh, tpres);
								tpres+=spres;
							}
						}
						else
						{
							for(px = ssx; px <=sex; px+=step)
							{
								solo_setpix(px, sey, ww, wh, tpres);
								tpres+=spres;
							}
						}
					}
					else
					{
						/* Steigung */
						cdif=(double)(((double)sey-(double)ssy))/((double)sex-(double)ssx);
						spres=((pres-opres)*step)/(abs(sex-ssx));
						if(sex < ssx)
						{
							for(px = ssx; px >=sex; px-=step)
							{
								py=px-ssx;
								c=((double)py)*cdif;
								py=c+ssy;
								solo_setpix(px, py, ww, wh, tpres);
								tpres+=spres;
							}
						}
						else
						{
							for(px = ssx; px <=sex; px+=step)
							{
								py=px-ssx;
								c=((double)py)*cdif;
								py=c+ssy;
								solo_setpix(px, py, ww, wh, tpres);
								tpres+=spres;
							}
						}
					}
				}

			}
			else
			{ x=-1; y=-1; }
			ox=x;
			oy=y;
			omax=pen.tip[pres]->max;
			opres=pres;

			graf_mouse(M_ON, NULL);
		}
		else if(pen.d_type == 1)
		{
			again_count+=pen.f_speed;
			if(again_count > 1000)
			{
				again_count=0;
				again=1;
			}
		}
	}while(b);
	
	/* Endemarkierung in Undopuffer schreiben */
	
		*undo_end++=0;
		*undo_end++=255; /* Typ nÑchstes Zeigerpaar */
		*(unsigned long*)undo_end=0; /* Zeiger auf Blockanfang ist Null*/
		undo_end+=4;
		*(unsigned long*)undo_end=0; /* Zeiger auf letzten Eintrag ist Null*/
		undo_end+=4;
		*(unsigned long*)undo_end=14; /* Zeiger auf Grîûe*/
		undo_end+=4;

		undo_end-=14; /* ZurÅcksetzen auf Eintrag */
			
	wind_update(END_MCTRL);
	wind_update(END_UPDATE);
	display_undo();
}

void ppaint_it(int w, int h)
{
	register int x_dif, y_dif;
	
	if(end_x < start_x)
		end_x=start_x;
	if(end_y < start_y)
		end_y=start_y;
	if(start_x >=w)
		start_x=w-1;
	if(end_x>=w)
		end_x=w-1;
	if(start_y >= h)
		start_y = h-1;
	if(end_y >= h)
		end_y = h-1;
	rel_start_x=start_x/DZOP;
	rel_start_y=start_y/DZOP;
	start_x+=main_win.ox*MZOP;
	start_y+=main_win.oy*MZOP;
	end_x+=main_win.ox*MZOP;
	end_y+=main_win.oy*MZOP;

	
	ls_width=((end_x-start_x)/6+1)*6;
	dst_lines=end_y-start_y+1;
	dst_width=ls_width/6;
	dst_2width=ls_width/2;
	src_offset=first_lay->this.word_width-ls_width;
	lsb_used=(long)((long)ls_width*(long)dst_lines)/2;
	lsb_offset=(long)(start_y)*(long)first_lay->this.word_width;
	lsb_offset+=(long)(start_x);

	/* Koordinaten fÅr das EInkopieren der Bufferplane so
	   hinbescheiûen, daû der Bufferstart auf 8er-Position liegt
	   und damit das Raster stimmt */
	/* Vorhergehende Koordinaten im 8er-Raster */
	x_dif=start_x-((start_x>>3)<<3);
	y_dif=start_y-((start_y>>3)<<3);

	ls_start_x=x_dif;
	ls_start_y=y_dif;
	ls_end_x=end_x-start_x+x_dif;
	ls_end_y=(int)dst_lines-1+y_dif;
	ls_dif=(long)(y_dif)*(ls_width+(long)x_dif)+(long)x_dif;
	ls_table=&(table_offset[y_dif]);
	ls_entry=ls_dif-x_dif;

	if(zoomin)
	{
		off8_x=start_x*ZIP;
		off8_y=start_y*ZIP;
	}
	
	paint_it();

	if(undo_ok && undo_on && (undo_end >= undo_maxend))
	{
		graf_mouse(M_ON, NULL);
		resize_undo();
		graf_mouse(M_OFF, NULL);
	}

}

void solo_ppaint_it(int w, int h)
{
	if(end_x < start_x)
		end_x=start_x;
	if(end_y < start_y)
		end_y=start_y;
	if(start_x >=w)
		start_x=w-1;
	if(end_x>=w)
		end_x=w-1;
	if(start_y >= h)
		start_y = h-1;
	if(end_y >= h)
		end_y = h-1;
	rel_start_x=start_x/DZOP;
	rel_start_y=start_y/DZOP;
	start_x+=main_win.ox*MZOP;
	start_y+=main_win.oy*MZOP;
	end_x+=main_win.ox*MZOP;
	end_y+=main_win.oy*MZOP;
	if(zoomin)
	{
		off8_x=start_x*ZIP;
		off8_y=start_y*ZIP;
	}
	paint_it();

	if(undo_ok && undo_on && (undo_end >= undo_maxend))
	{
		graf_mouse(M_ON, NULL);
		resize_undo();
		graf_mouse(M_OFF, NULL);
	}

}

int setpix(int x, int y, int w, int h, int pres)
{/* x/y = Stiftpos, w/h=Fenstermaûe */
	TIP	*ttip;
	int	sx,bx,sy,by, n_red, n_yellow, n_blue, n_mask;
	int	ofoy=0, oflx=0;
	long ad, mwox, mwoy;
	static int	ox, oy, ex, ey, sub=0;
	static TIP *otip;
	
	mwox=(long)((long)main_win.ox*(long)MZOP);
	mwoy=(long)((long)main_win.oy*(long)MZOP);
	
	ttip=pen.tip[pres];

	/* Koordinaten fÅr Zeichnung */
	sy=y-ttip->du;
	if(sy < 0)
	{
		ofoy=-sy;
		sy=0;
	}
	by=y+ttip->dd;
	if(by > (h-1))
		by=h-1;


	sx=x-ttip->dl;
	if(sx < 0)
	{
		oflx=-sx;
		sx=0;
	}
	bx=x+ttip->dr;
	if(bx > w-1)
		bx=w-1;
	/* Ggf. Quellfarbe holen */
	if(source_col != NULL)
	{
		ad=(long)((long)y+(long)mwoy)*(long)act_lay->this.word_width+(long)x+(long)mwox;
		c_red=*(unsigned char*)((long)source_col->red+ad);
		c_yellow=*(unsigned char*)((long)source_col->yellow+ad);
		c_blue=*(unsigned char*)((long)source_col->blue+ad);
	}
	
	if(mask_edit)
	{
		if(pen.wischen)
		{/* Pos.-Farbe aus Umkreis nehmen */
			/* Mittelpunkt */
			ad=(long)((long)y+(long)mwoy)*(long)act_lay->this.word_width+(long)x+(long)mwox;
			n_mask=*(unsigned char*)((long)act_mask->this.mask+ad);
	
			/* Links/Rechts/Oben/Unten */
			ad=(long)((long)y+(long)mwoy)*(long)act_lay->this.word_width+(long)sx+(long)mwox;
			n_mask+=*(unsigned char*)((long)act_lay->this.red+ad);
			ad=(long)((long)y+(long)mwoy)*(long)act_lay->this.word_width+(long)bx+(long)mwox;
			n_mask+=*(unsigned char*)((long)act_lay->this.red+ad);
			ad=(long)((long)sy+(long)mwoy)*(long)act_lay->this.word_width+(long)x+(long)mwox;
			n_mask+=*(unsigned char*)((long)act_lay->this.red+ad);
			ad=(long)((long)by+(long)mwoy)*(long)act_lay->this.word_width+(long)x+(long)mwox;
			n_mask+=*(unsigned char*)((long)act_lay->this.red+ad);
	
			
			n_mask/=5;
	
			if(n_mask < c_mask/2)
				n_mask=c_mask/2;
			
			c_mask=(c_mask*(32-pen.wischen)+n_mask*pen.wischen)/32;
	
			if(!pen.verlust)
				if(c_mask < pen.col.grey)
					c_mask=pen.col.grey;
		}
	
		if(pen.verlust)
		{
			--sub;
			if(sub <= pen.verlust)
			{
				sub=pen.verlust;
				if(c_mask > sub)
					c_mask-=sub;
				else
					c_mask=0;
				sub=32-pen.verlust;
			}
		}
	}
	else
	{
		if(pen.wischen)
		{/* Pos.-Farbe aus Umkreis nehmen */
			/* Mittelpunkt */
			ad=(long)((long)y+(long)mwoy)*(long)act_lay->this.word_width+(long)x+(long)mwox;
			n_red=*(unsigned char*)((long)act_lay->this.red+ad);
			n_yellow=*(unsigned char*)((long)act_lay->this.yellow+ad);
			n_blue=*(unsigned char*)((long)act_lay->this.blue+ad);
	
			/* Links/Rechts/Oben/Unten */
			ad=(long)((long)y+(long)mwoy)*(long)act_lay->this.word_width+(long)sx+(long)mwox;
			n_red+=*(unsigned char*)((long)act_lay->this.red+ad);
			n_yellow+=*(unsigned char*)((long)act_lay->this.yellow+ad);
			n_blue+=*(unsigned char*)((long)act_lay->this.blue+ad);
			ad=(long)((long)y+(long)mwoy)*(long)act_lay->this.word_width+(long)bx+(long)mwox;
			n_red+=*(unsigned char*)((long)act_lay->this.red+ad);
			n_yellow+=*(unsigned char*)((long)act_lay->this.yellow+ad);
			n_blue+=*(unsigned char*)((long)act_lay->this.blue+ad);
			ad=(long)((long)sy+(long)mwoy)*(long)act_lay->this.word_width+(long)x+(long)mwox;
			n_red+=*(unsigned char*)((long)act_lay->this.red+ad);
			n_yellow+=*(unsigned char*)((long)act_lay->this.yellow+ad);
			n_blue+=*(unsigned char*)((long)act_lay->this.blue+ad);
			ad=(long)((long)by+(long)mwoy)*(long)act_lay->this.word_width+(long)x+(long)mwox;
			n_red+=*(unsigned char*)((long)act_lay->this.red+ad);
			n_yellow+=*(unsigned char*)((long)act_lay->this.yellow+ad);
			n_blue+=*(unsigned char*)((long)act_lay->this.blue+ad);
	
			
			n_red/=5; n_yellow/=5; n_blue/=5;
	
			if((n_red < c_red/2) || (n_yellow < c_yellow/2) || (n_blue < c_blue/2))
			{
				n_red=c_red/2;
				n_yellow=c_yellow/2;
				n_blue=c_blue/2;
			}
			
			c_red=(c_red*(32-pen.wischen)+n_red*pen.wischen)/32;
			c_blue=(c_blue*(32-pen.wischen)+n_blue*pen.wischen)/32;
			c_yellow=(c_yellow*(32-pen.wischen)+n_yellow*pen.wischen)/32;
	
			if(!pen.verlust)
			{
				if(c_red < pen.col.red)
					c_red=pen.col.red;
				if(c_yellow < pen.col.yellow)
					c_yellow=pen.col.yellow;
				if(c_blue < pen.col.blue)
					c_blue=pen.col.blue;
			}
	
		}
	
		if(pen.verlust)
		{
			--sub;
			if(sub <= pen.verlust)
			{
				sub=pen.verlust;
				if(c_red > sub)
					c_red-=sub;
				else
					c_red=0;
				if(c_yellow > sub)
					c_yellow-=sub;
				else
				c_yellow=0;
				if(c_blue > sub)
					c_blue-=sub;
				else
					c_blue=0;
				sub=32-pen.verlust;
			}
		}
	}
	
	pen_r=ttip->red+ofoy*pen_width+oflx;
	pen_g=ttip->yellow+ofoy*pen_width+oflx;
	pen_b=ttip->blue+ofoy*pen_width+oflx;

	if(pen.q_opt && (ttip->square) && (ttip == otip) && same_tip)
	{
		c_qopt=1;
		if((sx < ox) && (bx > ox))
		{
			start_x=sx;
			start_y=sy;
			if(oy == sy)
			{
				end_x=ox-1;
				end_y=by;
				ppaint_it(w,h);
			}
			else if((sy < oy) && (by > oy))
			{
				end_x=bx;
				end_y=oy-1;
				ppaint_it(w,h);
				start_y=oy;
				start_x=sx;
				end_x=ox-1;
				end_y=by;
				ppaint_it(w,h);
			}
			else if((sy > oy) && (sy < ey))
			{
				end_x=ox-1;
				end_y=ey;
				ppaint_it(w,h);
				start_y=ey+1;
				start_x=sx;
				end_x=bx;
				end_y=by;
				ppaint_it(w,h);
			}
			else
			{
				end_x=bx;
				end_y=by;
				ppaint_it(w,h);
			}
		}
		else if ((sx > ox) && (sx < ex))
		{
			start_y=sy;
			if(oy == sy)
			{
				start_x=ex+1;
				end_x=bx;
				end_y=by;
				ppaint_it(w,h);
			}
			else if((sy < oy) && (by > oy))
			{
				start_x=sx;
				end_x=bx;
				end_y=oy-1;
				ppaint_it(w,h);
				start_y=oy;
				start_x=ex+1;
				end_x=bx;
				end_y=by;
				ppaint_it(w,h);
			}
			else if((sy > oy) && (sy < ey))
			{
				start_x=ex+1;
				end_x=bx;
				end_y=ey;
				ppaint_it(w,h);
				start_x=sx;
				start_y=ey+1;
				end_x=bx;
				end_y=by;
				ppaint_it(w,h);
			}
			else
			{
				start_x=sx;
				end_x=bx;
				end_y=by;
				ppaint_it(w,h);
			}
			
		}
		else if(sx == ox)
		{
			start_x=sx;
			end_x=bx;
			if((sy < oy) && (by >= oy))
			{
				start_y=sy;
				end_y=oy-1;
				ppaint_it(w,h);
			}
			else if((sy > oy) && (by >= ey))
			{
				start_y=ey+1;
				end_y=by;
				ppaint_it(w,h);
			}
			else if(sy == oy)
			{
			}
			else
			{
				start_y=sy;
				end_y=by;
				ppaint_it(w,h);
			}
			
		}
		else
		{
			start_x=sx;
			start_y=sy;
			end_x=bx;
			end_y=by;
			ppaint_it(w,h);
		}
	}
	else
	{
		c_qopt=0;
		start_x=sx;
		start_y=sy;
		end_x=bx;
		end_y=by;
		ppaint_it(w,h);
	}

	ox=sx; ex=bx; oy=sy; ey=by;
	otip=ttip;
	same_tip=1;

	return(ttip->max);
}

int solo_setpix(int x, int y, int w, int h, int pres)
{/* x/y = Stiftpos, w/h=Fenstermaûe */
	TIP	*ttip;
	int	sx,bx,sy,by, n_red, n_yellow, n_blue, n_mask;
	int	ofoy=0, oflx=0;
	long ad, mwox, mwoy;
	static int	ox, oy, ex, ey, sub=0;
	static TIP *otip;
	
	ttip=pen.tip[pres];

	mwox=(long)((long)main_win.ox*(long)MZOP);
	mwoy=(long)((long)main_win.oy*(long)MZOP);

	/* Koordinaten fÅr Zeichnung */
	sy=y-ttip->du;
	if(sy < 0)
	{
		ofoy=-sy;
		sy=0;
	}
	by=y+ttip->dd;
	if(by > (h-1))
		by=h-1;


	sx=x-ttip->dl;
	if(sx < 0)
	{
		oflx=-sx;
		sx=0;
	}
	bx=x+ttip->dr;
	if(bx > w-1)
		bx=w-1;
	/* Ggf. Quellfarbe holen */
	if(source_col != NULL)
	{
		ad=(long)((long)y+(long)mwoy)*(long)act_lay->this.word_width+(long)x+(long)mwox;
		c_red=*(unsigned char*)((long)source_col->red+ad);
		c_yellow=*(unsigned char*)((long)source_col->yellow+ad);
		c_blue=*(unsigned char*)((long)source_col->blue+ad);
	}

	if(mask_edit)
	{
		if(pen.wischen)
		{/* Pos.-Farbe aus Umkreis nehmen */
			/* Mittelpunkt */
			ad=(long)((long)y+(long)mwoy)*(long)act_lay->this.word_width+(long)x+(long)mwox;
			n_mask=*(unsigned char*)((long)act_mask->this.mask+ad);
	
			/* Links/Rechts/Oben/Unten */
			ad=(long)((long)y+(long)mwoy)*(long)act_lay->this.word_width+(long)sx+(long)mwox;
			n_mask+=*(unsigned char*)((long)act_lay->this.red+ad);
			ad=(long)((long)y+(long)mwoy)*(long)act_lay->this.word_width+(long)bx+(long)mwox;
			n_mask+=*(unsigned char*)((long)act_lay->this.red+ad);
			ad=(long)((long)sy+(long)mwoy)*(long)act_lay->this.word_width+(long)x+(long)mwox;
			n_mask+=*(unsigned char*)((long)act_lay->this.red+ad);
			ad=(long)((long)by+(long)mwoy)*(long)act_lay->this.word_width+(long)x+(long)mwox;
			n_mask+=*(unsigned char*)((long)act_lay->this.red+ad);
	
			
			n_mask/=5;
	
			if(n_mask < c_mask/2)
				n_mask=c_mask/2;
			
			c_mask=(c_mask*(32-pen.wischen)+n_mask*pen.wischen)/32;
	
			if(!pen.verlust)
				if(c_mask < pen.col.grey)
					c_mask=pen.col.grey;
		}
	
		if(pen.verlust)
		{
			--sub;
			if(sub <= pen.verlust)
			{
				sub=pen.verlust;
				if(c_mask > sub)
					c_mask-=sub;
				else
					c_mask=0;
				sub=32-pen.verlust;
			}
		}
	}
	else
	{
		if(pen.wischen)
		{/* Pos.-Farbe aus Umkreis nehmen */
			/* Mittelpunkt */
			ad=(long)((long)y+(long)mwoy)*(long)act_lay->this.word_width+(long)x+(long)mwox;
			n_red=*(unsigned char*)((long)act_lay->this.red+ad);
			n_yellow=*(unsigned char*)((long)act_lay->this.yellow+ad);
			n_blue=*(unsigned char*)((long)act_lay->this.blue+ad);
	
			/* Links/Rechts/Oben/Unten */
			ad=(long)((long)y+(long)mwoy)*(long)act_lay->this.word_width+(long)sx+(long)mwox;
			n_red+=*(unsigned char*)((long)act_lay->this.red+ad);
			n_yellow+=*(unsigned char*)((long)act_lay->this.yellow+ad);
			n_blue+=*(unsigned char*)((long)act_lay->this.blue+ad);
			ad=(long)((long)y+(long)mwoy)*(long)act_lay->this.word_width+(long)bx+(long)mwox;
			n_red+=*(unsigned char*)((long)act_lay->this.red+ad);
			n_yellow+=*(unsigned char*)((long)act_lay->this.yellow+ad);
			n_blue+=*(unsigned char*)((long)act_lay->this.blue+ad);
			ad=(long)((long)sy+(long)mwoy)*(long)act_lay->this.word_width+(long)x+(long)mwox;
			n_red+=*(unsigned char*)((long)act_lay->this.red+ad);
			n_yellow+=*(unsigned char*)((long)act_lay->this.yellow+ad);
			n_blue+=*(unsigned char*)((long)act_lay->this.blue+ad);
			ad=(long)((long)by+(long)mwoy)*(long)act_lay->this.word_width+(long)x+(long)mwox;
			n_red+=*(unsigned char*)((long)act_lay->this.red+ad);
			n_yellow+=*(unsigned char*)((long)act_lay->this.yellow+ad);
			n_blue+=*(unsigned char*)((long)act_lay->this.blue+ad);
	
			
			n_red/=5; n_yellow/=5; n_blue/=5;
	
			if((n_red < c_red/2) || (n_yellow < c_yellow/2) || (n_blue < c_blue/2))
			{
				n_red=c_red/2;
				n_yellow=c_yellow/2;
				n_blue=c_blue/2;
			}
			
			c_red=(c_red*(32-pen.wischen)+n_red*pen.wischen)/32;
			c_blue=(c_blue*(32-pen.wischen)+n_blue*pen.wischen)/32;
			c_yellow=(c_yellow*(32-pen.wischen)+n_yellow*pen.wischen)/32;

			if(!pen.verlust)
			{
				if(c_red < pen.col.red)
					c_red=pen.col.red;
				if(c_yellow < pen.col.yellow)
					c_yellow=pen.col.yellow;
				if(c_blue < pen.col.blue)
					c_blue=pen.col.blue;
			}
	
		}

		if(pen.verlust)
		{
			--sub;
			if(sub <= pen.verlust)
			{
				sub=pen.verlust;
				if(c_red > sub)
					c_red-=sub;
				else
					c_red=0;
				if(c_yellow > sub)
					c_yellow-=sub;
				else
				c_yellow=0;
				if(c_blue > sub)
					c_blue-=sub;
				else
					c_blue=0;
				sub=32-pen.verlust;
			}
		}
	}
	
	pen_r=ttip->red+ofoy*pen_width+oflx;
	pen_g=ttip->yellow+ofoy*pen_width+oflx;
	pen_b=ttip->blue+ofoy*pen_width+oflx;

	if(pen.q_opt && (ttip->square) && (ttip == otip) && same_tip)
	{
		c_qopt=1;
		if((sx < ox) && (bx > ox))
		{
			start_x=sx;
			start_y=sy;
			if(oy == sy)
			{
				end_x=ox-1;
				end_y=by;
				solo_ppaint_it(w,h);
			}
			else if((sy < oy) && (by > oy))
			{
				end_x=bx;
				end_y=oy-1;
				solo_ppaint_it(w,h);
				start_y=oy;
				start_x=sx;
				end_x=ox-1;
				end_y=by;
				solo_ppaint_it(w,h);
			}
			else if((sy > oy) && (sy < ey))
			{
				end_x=ox-1;
				end_y=ey;
				solo_ppaint_it(w,h);
				start_y=ey+1;
				start_x=sx;
				end_x=bx;
				end_y=by;
				solo_ppaint_it(w,h);
			}
			else
			{
				end_x=bx;
				end_y=by;
				solo_ppaint_it(w,h);
			}
		}
		else if ((sx > ox) && (sx < ex))
		{
			start_y=sy;
			if(oy == sy)
			{
				start_x=ex+1;
				end_x=bx;
				end_y=by;
				solo_ppaint_it(w,h);
			}
			else if((sy < oy) && (by > oy))
			{
				start_x=sx;
				end_x=bx;
				end_y=oy-1;
				solo_ppaint_it(w,h);
				start_y=oy;
				start_x=ex+1;
				end_x=bx;
				end_y=by;
				solo_ppaint_it(w,h);
			}
			else if((sy > oy) && (sy < ey))
			{
				start_x=ex+1;
				end_x=bx;
				end_y=ey;
				solo_ppaint_it(w,h);
				start_x=sx;
				start_y=ey+1;
				end_x=bx;
				end_y=by;
				solo_ppaint_it(w,h);
			}
			else
			{
				start_x=sx;
				end_x=bx;
				end_y=by;
				solo_ppaint_it(w,h);
			}
			
		}
		else if(sx == ox)
		{
			start_x=sx;
			end_x=bx;
			if((sy < oy) && (by >= oy))
			{
				start_y=sy;
				end_y=oy-1;
				solo_ppaint_it(w,h);
			}
			else if((sy > oy) && (by >= ey))
			{
				start_y=ey+1;
				end_y=by;
				solo_ppaint_it(w,h);
			}
			else if(sy == oy)
			{
			}
			else
			{
				start_y=sy;
				end_y=by;
				solo_ppaint_it(w,h);
			}
			
		}
		else
		{
			start_x=sx;
			start_y=sy;
			end_x=bx;
			end_y=by;
			solo_ppaint_it(w,h);
		}
	}
	else
	{
		c_qopt=0;
		start_x=sx;
		start_y=sy;
		end_x=bx;
		end_y=by;
		solo_ppaint_it(w,h);
	}

	ox=sx; ex=bx; oy=sy; ey=by;
	otip=ttip;
	same_tip=1;

	return(ttip->max);
}

