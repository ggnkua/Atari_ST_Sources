#include <grape_h.h>
#include "grape.h"
#include "maininit.h"
#include "scale.h"
#include "zoom.h"
#include "mforms.h"
#include "undo.h"
#include "varycopy.h"
#include "stempel.h"
#include "ctcppt.h"

static 	STEMPEL stmp={0,0,0,NULL,NULL,NULL,NULL,0,0,0,0,0,0};
void reset_stamp_view(void);
void reset_data_view(void);
void fill_st_preview(int ob);

void smear_copy(uchar *pc, uchar *pm, uchar *py, long start, long sldif, long dldif, int w, int h)
{/* pc-py = Sourceplanes, start=Auf Planes addieren um Startpixeladresse
		zu erhalten. Ist nur deshalb nicht gleich in pc-py mit drin,
		weil an pm==NULL unterschieden wird, wie viele Planes kopiert
		werden sollen.
		sldif/dldif=Line-Diffs
		w/h=copy rect
		Dest ist buf1 oder 2 aus stmp
	*/
	register uchar *ss, *dd;
	register int	ww=w, hh=h;
	register long sdif=sldif, ddif=dldif;
	register int xc,yc;

	if(stmp.act_buf < 2)		
		dd=stmp.buf;
	else
		dd=stmp.buf2;
	ss=pc+start;
	for(yc=hh; yc > 0; --yc)
	{
		for(xc=ww; xc > 0; --xc)
			*dd++=*ss++;
		ss+=sdif; dd+=ddif;
	}
	if(pm==NULL) return;
	ss=pm+start;
	for(yc=hh; yc > 0; --yc)
	{
		for(xc=ww; xc > 0; --xc)
			*dd++=*ss++;
		ss+=sdif; dd+=ddif;
	}
	ss=py+start;
	for(yc=hh; yc > 0; --yc)
	{
		for(xc=ww; xc > 0; --xc)
			*dd++=*ss++;
		ss+=sdif; dd+=ddif;
	}
}

void do_stempel(uchar *pc, uchar *pm, uchar *py, int x, int y, int w, int h)
{/* Wenn m und y NULL sind, ist c Maskenadresse */
	long	start=(long)((long)first_lay->this.word_width*(long)y+(long)x);
	long	siz=stmp.siz;
	uchar	*srcbuf;
	COPY_DSCR	cd;
	_frame_data	oframe=frame_data;

	frame_data.x=x; frame_data.y=y;
	frame_data.w=w; frame_data.h=h;
	if(pm && py)
	{
		if(!frame_to_undo_mouse(&(act_lay->this),NULL, 0))
		{
			frame_data=oframe;
			return;	/* Da kam nicht 1 ->Fehler bzw. Abbruch */
		}
	}
	else
	{
		if(!frame_to_undo_mouse(NULL, &(act_mask->this), 0))
		{
			frame_data=oframe;
			return;	/* Da kam nicht 1 ->Fehler bzw. Abbruch */
		}
	}
	frame_data=oframe;

	
	if(ostampopt[SOSMEAR-1].ob_state & SELECTED)
	{
		stmp.stype=0;
		smear_copy(pc, pm, py, start, first_lay->this.word_width-w, stmp.w-w , w, h);
		/* Von wo zurÅckkopieren? */
		if(stmp.act_buf==0)
		{ srcbuf=stmp.buf; stmp.act_buf=2; stmp.sdef=0;}
		else if(stmp.act_buf==1)
		{	srcbuf=stmp.buf2; stmp.act_buf=2;}
		else
		{	srcbuf=stmp.buf; stmp.act_buf=1;}
	}
	else
		srcbuf=stmp.buf;

	cd.dc=pc+start;
	if(pm && py)
	{
		cd.dm=pm+start;
		cd.dy=py+start;
	}
	else
		cd.dm=cd.dy=NULL;
	cd.mode=0;
	cd.dw=w;
	cd.dh=h;
	cd.sldif=stmp.w-w;
	cd.dldif=first_lay->this.word_width-w;
	cd.sc=srcbuf;
	if(stmp.stype==0)
	{	/* Layer-Daten */
		cd.sm=srcbuf+siz;
		cd.sy=srcbuf+2*siz;
	}
	else
	{/* Grau-Daten */
		cd.sm=cd.sy=NULL;
	}
	/* Masken benutzen? */
	if((stmp.mdef==0)||(!(ostampopt[SOMASK-1].ob_state & SELECTED)))
	{/* Stempel hat keine oder soll nicht benutzt werden */
		if(otoolbar[MASK_ON-1].ob_state & SELECTED)
		{
			cd.mode|=1;
			cd.mask=(uchar*)act_mask->this.mask+start;
			cd.mldif=cd.dldif;
		}
	}
	else
	{
		cd.mode|=1;
		cd.mldif=cd.sldif;
		if(otoolbar[MASK_ON-1].ob_state & SELECTED)
		{/* Beide Masken aktiv */
			cd.mask=stmp.buf+4*siz;
			add_masks((uchar*)act_mask->this.mask+start, stmp.buf+3*siz, stmp.buf+4*siz, cd.dldif, cd.sldif, cd.sldif, w, h);
		}
		else
			cd.mask=stmp.buf+3*siz;
	}
	if(ostampopt[SOLAS].ob_state & SELECTED)
		cd.mode|=2;
	else if(ostampopt[SONWHITE].ob_state & SELECTED)
		cd.mode|=4;
	else
		cd.mode|=6;
	vary_copy(&cd);
}

void stempel(int wid)
{
	int				stx, sty, mx, my, k, ox, oy, dum, dw, dh;
	uchar			*c,*m,*y;
	if(stmp.buf==NULL)
	{
		Bell();
		return;
	}
	stmp.act_buf=0;	/* Smear-Reset bei neuem Aufsetzen */
				
	if(otoolbar[MASK_ED-1].ob_state & SELECTED)
	{/* In der Maske ist kein Smear erlaubt, Stempeldaten mÅssen 
			also gÅltig sein */
		if(stmp.sdef==0)
		{
			Bell();
			return;
		}
		c=act_mask->this.mask;
		m=y=NULL;
		painted_mask=act_mask;
	}
	else
	{
		if((stmp.sdef==0) && !(ostampopt[SOSMEAR-1].ob_state & SELECTED))
		{
			Bell();
			return;
		}
		c=act_lay->this.blue;
		m=act_lay->this.red;
		y=act_lay->this.yellow;
		painted_lay=act_lay;
	}
	
	wind_get(wid, WF_WORKXYWH, &stx, &sty, &dum, &dum);
	sty+=(otoolbar[0].ob_height+OTBB);

	graf_mkstate(&mx, &my, &dum, &dum);
	if(mx-stx > first_lay->this.width/DZOP) return;
	if(my-sty > first_lay->this.height/DZOP) return;
	mx-=stx; mx+=main_win.ox;	mx=mx*MZOP;
	my-=sty; my+=main_win.oy;	my=my*MZOP;
	mx-=stmp.w/2; my-=stmp.h/2;
	if(mx < 0) mx=0;
	if(my < 0) my=0;
	dw=stmp.w; dh=stmp.h;
	if(mx+dw > first_lay->this.width) dw=first_lay->this.width-mx;
	if(my+dh > first_lay->this.height) dh=first_lay->this.height-my;
	auto_reset(0);
	ox=oy=0;
	do
	{
		BACK:
		graf_mkstate(&mx, &my, &k, &dum);
		if(mx-stx > first_lay->this.width/DZOP) goto BACK;
		if(my-sty > first_lay->this.height/DZOP) goto BACK;

		mx-=stx; mx+=main_win.ox;	mx=mx*MZOP;
		my-=sty; my+=main_win.oy;	my=my*MZOP;
		mx-=stmp.w/2; my-=stmp.h/2;
		if(mx < 0) mx=0;
		if(my < 0) my=0;
		dw=stmp.w; dh=stmp.h;
		if(mx+dw > first_lay->this.width) dw=first_lay->this.width-mx;
		if(my+dh > first_lay->this.height) dh=first_lay->this.height-my;

		if((mx!=ox)||(my!=oy))
		{
			ox=mx; oy=my;
			do_stempel(c,m,y,mx,my,dw,dh);
			area_redraw(mx,my,dw,dh);
		}
	}while(k & 1);
	/* Stempelpreview ggf. Ñndern */
	/* WHITEBAK zeigt an, ob der Preview nach Datenvernichtung
		 durch Smear schon aktualisiert wurde */
	if(ostampopt[SOSMEAR-1].ob_state & SELECTED)
	{
		if(!(ostampopt[SOVDATA].ob_state & WHITEBAK))
		{
			ostampopt[SOVDATA].ob_state |= WHITEBAK;
			reset_data_view();
		}
	}
	else
		ostampopt[SOVDATA].ob_state &= (~WHITEBAK);
		
	actize_win_name();
}




/**************
*** GET STEMPEL 
***************/
void do_multi_getframe(_frame_data *f, int type)
{/* Type=0: Ebenendaten als Ebenendaten, 
				 3: Ebenendaten als Maskendaten */
	uchar	*sc, *sm, *sy;
	int		res;
	long	suw, sh, slw;
	COPY_DSCR cd;
	_frame_data	oldframe=frame_data;

	frame_data=*f;
	/* Daten holen */
	res=get_vis_frame(&sc, &sm, &sy, &sh, &slw, &suw);
	frame_data=oldframe;	
	if(res==0)
	{
		form_alert(1,"[3][Grape:|Nicht genug Pufferspeicher!][Abbruch]");
		free(stmp.buf);
		stmp.buf=stmp.mask=stmp.maskbuf=stmp.buf2=NULL;			
	}
	
	cd.sc=sc;
	cd.sm=sm;
	cd.sy=sy;
	cd.sldif=slw-suw;
	cd.dw=f->w;
	cd.dh=f->h;
	cd.dldif=0;
	cd.mode=6;
	cd.dc=stmp.buf;
	stmp.sdef=1;
	if(type==0)
	{
		cd.dm=stmp.buf+stmp.siz;
		cd.dy=stmp.buf+2*stmp.siz;
		stmp.stype=0;
	}
	else
	{
		cd.dm=cd.dy=NULL;
		stmp.stype=1;
	}
	vary_copy(&cd);
	free(sc); free(sm); free(sy);
}

void do_getframe(_frame_data *f, int type)
{/* Type=0: Ebenendaten als Ebenendaten, 
				 1: Maskendaten als Maskendaten,
				 2: Maskendaten als Ebenendaten
				 3: Ebenendaten als Maskendaten */
	long			ldif=first_lay->this.word_width-f->w;
	LAY_LIST	*ll=first_lay;
	COPY_DSCR cd;
	long		 	start=(long)((long)first_lay->this.word_width*(long)f->y+(long)f->x);
	
	if(((type==0)||(type==3)) && (count_vis_layers() > 1))
	{/* Mehrere Quellebenen kopieren */
		do_multi_getframe(f, type);
		return;
	}
	
	/* Erste sichtbare Ebene suchen */
	while(!(ll->this.visible)) ll=ll->next;
	
	switch(type)
	{
		case 0:
			cd.sc=(uchar*)ll->this.blue+start;
			cd.sm=(uchar*)ll->this.red+start;
			cd.sy=(uchar*)ll->this.yellow+start;
			cd.dc=stmp.buf;
			cd.dm=stmp.buf+stmp.siz;
			cd.dy=stmp.buf+2*stmp.siz;
			stmp.sdef=1;
			stmp.stype=0;
		break;
		case 1:
			cd.sc=(uchar*)act_mask->this.mask+start;
			cd.sm=cd.sy=NULL;
			cd.dc=stmp.mask;
			cd.dm=cd.dy=NULL;
			stmp.mdef=1;
		break;
		case 2:
			cd.sc=(uchar*)act_mask->this.mask+start;
			cd.sm=cd.sy=NULL;
			cd.dc=stmp.buf;
			cd.dm=stmp.buf+stmp.siz;
			cd.dy=stmp.buf+2*stmp.siz;
			stmp.sdef=1;
			stmp.stype=1;
		break;
		case 3:
			cd.sc=(uchar*)ll->this.blue+start;
			cd.sm=(uchar*)ll->this.red+start;
			cd.sy=(uchar*)ll->this.yellow+start;
			cd.dc=stmp.mask;
			cd.dm=cd.dy=NULL;
			stmp.mdef=1;
		break;
	}
	cd.dw=stmp.w;
	cd.dh=stmp.h;
	cd.sldif=ldif;
	cd.dldif=0;
	cd.mode=6;
	vary_copy(&cd);
}

void test_getframe(_frame_data *f, int type)
{/* Type=0: Ebenendaten
				 1: Maskendaten,
				 2: Alles sichtbare
		Ist Typ=2 oder keine Altdaten oder neue Grîûe <> alte Grîûe
		wird alles sichtbare kopiert und je nach Vorhandensein SMEAR
		und MASK gesetzt.
		Beim Neu-Anlegen:
		Typ=2:	Ist Ebene da?
						Ja: Diese als Clip nehmen, SMEAR OFF
					 			Ist Maske da?
					 			Ja: Diese als Maske nehmen, MASK ON
					 			Nein: MASK OFF
						Nein: MASK OFF, Ist Maske da?
								Ja: Diese als Clip nehmen, SMEAR OFF
								Nein: SMEAR ON
		Typ=0:	Wie Typ 2
		Typ=1:	Ist Maske da?
						Ja: Diese als Maske nehmen, MASK ON
								Ist Ebene da?
								Ja: Diese als Clip nehmen, SMEAR OFF
								Nein: SMEAR ON
						Nein: SMEAR ON, Ist Ebene da?
									Ja: Diese als Maske nehmen, MASK ON
									Nein: MASK OFF
					 
		
		Falls Altdaten ok:
		Typ=0:
		Sind sichtbare Ebenen da?
			Ja: Diese als Clip, SMEAR OFF
					Ist bereits eine gÅltige Maske da? 
					Ja: Ende
					Nein: Sind Maskendaten sichtbar?
								Ja: Diese nehmen und MASK ON
								Nein: MASK OFF
			Nein: Ist sichtbare Maske da?
						Ja: Diese als Grauclip nehmen, SMEAR OFF
								Sind interene Maskendaten gÅltig?
								Ja: Ende
								Nein: MASK OFF
						Nein: Bell()
	 FÅr Typ=1 alles wie Typ 0, nur Maske/Ebene vertauscht
	 
	 Ende: Previews neu zeichnen 
	*/
	
	long	siz;
	int		vis_lay=count_vis_layers(), vis_mask=otoolbar[MASK_VIS-1].ob_state & SELECTED;
	int		new=1;
	
	siz=(long)((long)(f->w)*(long)(f->h));
	if(siz==0) return; /* Auswahl hat Breite u/o Hîhe 0 */

	if((stmp.buf != NULL) && (f->w == stmp.w) && (f->h == stmp.h))
		new=0;
	else
	{
		if(stmp.buf != NULL) free(stmp.buf);
		stmp.buf=stmp.mask=stmp.maskbuf=stmp.buf2=NULL; /* am StÅck alloziert, d.h. kein extra-free */
		stmp.sdef=stmp.mdef=0;
		
		stmp.w=f->w;
		stmp.h=f->h;
		stmp.siz=siz;
		stmp.buf=malloc(siz*8);
	
		if(stmp.buf==NULL)
		{
			form_alert(1,"[3][Grape:|Nicht genug Speicher fÅr|Stempeldaten.][Abbruch]");
			reset_stamp_view();
			return;
		}
		stmp.mask=stmp.buf+siz*3;
		stmp.maskbuf=stmp.mask+siz;
		stmp.buf2=stmp.maskbuf+siz;
	}
	
	if(new || type==2)
	{	/* Neuer Stempel->alles mîgliche kopieren */
		stmp.sdef=stmp.mdef=0;
		if((type==2)||(type==0))
		{	if(vis_lay)
			{	do_getframe(f, 0);
				stamp_turn_off(SOSMEAR);
				if(vis_mask)
				{	do_getframe(f, 1);
					stamp_turn_on(SOMASK);
				}
				else stamp_turn_off(SOMASK);
			}	else 
			{	stamp_turn_off(SOMASK);
				if(vis_mask)
				{	do_getframe(f, 2);
					stamp_turn_off(SOSMEAR);
				}
				else	stamp_turn_on(SOSMEAR);
			}
		}
		else	/* TYP 1 */
		{	if(vis_mask)
			{	do_getframe(f, 1);
				stamp_turn_on(SOMASK);
				if(vis_lay)
				{	do_getframe(f, 0);
					stamp_turn_off(SOSMEAR);
				}
				else stamp_turn_on(SOSMEAR);
			}	else 
			{	stamp_turn_on(SOSMEAR);
				if(vis_lay)
				{	do_getframe(f, 3);
					stamp_turn_on(SOMASK);
				}
				else	stamp_turn_off(SOMASK);
			}
		}
		reset_stamp_view();
		return;
	}
	
	/* Vorhandene Daten ergÑnzen */
	if(type==0) /* Ebenen */
	{
		if(vis_lay)
		{
			do_getframe(f, 0);
			stamp_turn_off(SOSMEAR);
			if(stmp.mdef==0)
			{
				if(vis_mask)
				{
					do_getframe(f, 1);
					stamp_turn_on(SOMASK);
				}
				else
					stamp_turn_off(SOMASK);
			}
		}
		else if(vis_mask)
		{/* Falls nur Maske sichtbar, diese als Ausschnitt kopieren */
			do_getframe(f, 2);
			stamp_turn_off(SOSMEAR);
			if(stmp.mdef==0)
				stamp_turn_off(SOMASK);
		}
		else
		{
			Bell();
			free(stmp.buf);
			stmp.buf=stmp.mask=stmp.maskbuf=stmp.buf2=NULL;			
			stamp_turn_off(SOMASK);
		}
	}
	else				/* Masken */
	{
		if(vis_mask)
		{
			do_getframe(f, 1);
			stamp_turn_on(SOMASK);
			if(stmp.sdef==0)
			{
				if(vis_lay)
				{
					do_getframe(f, 0);
					stamp_turn_off(SOSMEAR);
				}
				else
					stamp_turn_on(SOSMEAR);
			}
		}
		else if(vis_lay)
		{
			do_getframe(f, 3);
			stamp_turn_on(SOMASK);
			if(stmp.sdef==0)
				stamp_turn_on(SOSMEAR);
		}
		else
		{
			Bell();
			free(stmp.buf);
			stmp.buf=stmp.mask=stmp.maskbuf=stmp.buf2=NULL;			
		}
	}
	reset_stamp_view();
}

void correct(_frame_data *f)
{/* Koordinaten so tauschen, daû nix negativ bleibt */
	int b;
	
	if(f->w < 0)
	{
		b=f->x+f->w;
		f->x=b;
		f->w=-f->w;
	}
	if(f->h < 0)
	{
		b=f->y+f->h;
		f->y=b;
		f->h=-f->h;
	}
}

void draw_getframe(int wx, int wy, _frame_data *fd)
{
	_frame_data frame_data;
	int					pxy[10];
	
	frame_data.x=fd->x/DZOP;
	frame_data.y=fd->y/DZOP;
	frame_data.w=fd->w/DZOP;
	frame_data.h=fd->h/DZOP;

	correct(&frame_data);
		
	pxy[0]=frame_data.x+wx-main_win.ox; pxy[1]=frame_data.y+wy-main_win.oy;
	pxy[2]=frame_data.x+wx+frame_data.w-1-main_win.ox; pxy[3]=frame_data.y+wy-main_win.oy;
	pxy[4]=frame_data.x+wx+frame_data.w-1-main_win.ox; pxy[5]=frame_data.y+wy+frame_data.h-1-main_win.oy;
	pxy[6]=frame_data.x+wx-main_win.ox; pxy[7]=frame_data.y+wy+frame_data.h-1-main_win.oy;
	pxy[8]=frame_data.x+wx-main_win.ox; pxy[9]=frame_data.y+wy-main_win.oy;
	
	graf_mouse(M_OFF, NULL);
	v_pline(handle, 5, pxy);
	graf_mouse(M_ON, NULL);
}

void get_stempel(int wid)
{
	int				stx, sty, ox, oy, mx, my, k, dum, vx, vy, vw, vh;
	int				wx,wy;
	_frame_data	getframe;
	
	/* Auswahl nur mîglich, wenn irgendwas sichtbar ist! */
	if((!(otoolbar[MASK_VIS-1].ob_state & SELECTED)) && (count_vis_layers()==0))
	{
		Bell();
		return;
	}

	wind_update(BEG_UPDATE);
	wind_update(BEG_MCTRL);
	
	vswr_mode(handle, 3);
	vsl_type(handle, 1);
  vsl_width(handle, 1);
  vsl_color(handle, 1);
  vsl_ends(handle, 0, 0);
  vsm_type(handle, 0);
  vsf_interior(handle, 1);
  vsf_color(handle, 1);
  vsf_perimeter(handle, 1);

	wind_get(wid, WF_WORKXYWH, &stx, &sty, &vw, &vh);
	sty+=(otoolbar[0].ob_height+OTBB); vh-=(otoolbar[0].ob_height+OTBB);
	wx=stx; wy=sty;
	/* TatsÑchlich sichtbarer Bereich: */
	vx=main_win.ox*MZOP; vy=main_win.oy*MZOP;
	vw=vw*MZOP; vh=vh*MZOP;
	if(vw > first_lay->this.width) vw=first_lay->this.width;
	if(vh > first_lay->this.height) vh=first_lay->this.height;
	ox=oy=0;
	graf_mouse(THIN_CROSS, NULL);
	graf_mkstate(&mx, &my, &k, &dum);
	mx-=stx; mx+=main_win.ox;	mx=mx*MZOP;
	my-=sty; my+=main_win.oy;	my=my*MZOP;
	if(mx < vx) mx=vx; if(mx > vx+vw)mx=vx+vw;
	if(my < vy) my=vy; if(my > vy+vh) my=vy+vh;
	getframe.x=mx; getframe.y=my; getframe.w=0; getframe.h=0;
	draw_getframe(wx,wy,&getframe);
	do
	{
		graf_mkstate(&mx, &my, &k, &dum);
		mx-=stx; mx+=main_win.ox;	mx=mx*MZOP;
		my-=sty; my+=main_win.oy;	my=my*MZOP;
		if(mx < vx) mx=vx; if(mx > vx+vw)mx=vx+vw;
		if(my < vy) my=vy; if(my > vy+vh) my=vy+vh;
		if((mx != ox)||(my != oy))
		{
			ox=mx; oy=my;
			draw_getframe(wx,wy,&getframe);
			getframe.w=mx-getframe.x;
			getframe.h=my-getframe.y;
			draw_getframe(wx,wy,&getframe);
		}
	}while(k&2);
	draw_getframe(wx, wy, &getframe);
	correct(&getframe);
	test_getframe(&getframe, 2);
	graf_mouse(ARROW, NULL);	
	wind_update(END_MCTRL);
	wind_update(END_UPDATE);
}

/* -------- */

void get_clip_stempel(int type)
{/* 0=Ebenen, 1=Maske */
	if((main_win.id < 0)||(first_lay==NULL))
	{
		form_alert(1,"[3][Grape:|Es ist keine Hauptdatei geîffnet!|WÑhlen Sie \'Neu\' oder \'ôffnen\' aus|dem Datei-MenÅ.][Abbruch]");
		return;
	}
	
	if(!frame_data.ok)
	{
		form_alert(1,"[3][Grape:|Es ist keine Auswahl definiert.|Wechseln Sie in den Rahmenmodus|und erstellen Sie eine Auswahl.][Abbruch]");
		return;
	}

	/* Rahmen anzeigen? */
	if(!frame_data.vis)
		draw_win_frame();
	
	test_getframe(&frame_data, type);
	if(!frame_data.vis)
		draw_win_frame();
}

/* -------- */
/* File I/O */

void load_stempel(int fh)
{/* Stempel aus geîffneter Datei fh laden, Magic muû schon Åbergangen sein */
	if(stmp.buf != NULL) free(stmp.buf);
	Fread(fh, sizeof(STEMPEL), &stmp);

	/* Buffer holen */
	stmp.buf=malloc(stmp.siz*8);

	if(stmp.buf==NULL)
	{
		form_alert(1,"[3][Grape:|Nicht genug Speicher fÅr|Stempeldaten.][Abbruch]");
		Fclose(fh);
		return;
	}
	stmp.mask=stmp.buf+stmp.siz*3;
	stmp.maskbuf=stmp.mask+stmp.siz;
	stmp.buf2=stmp.maskbuf+stmp.siz;

	graf_mouse(BUSYBEE, NULL);
	Fread(fh, stmp.siz*4, stmp.buf); /* Pufferdaten werden nicht gelesen */
	Fclose(fh);
	graf_mouse(ARROW, NULL);

	/* Objekte setzen */
	ostampopt[SOLAS].ob_state &=(~SELECTED);
	ostampopt[SONWHITE].ob_state &=(~SELECTED);
	ostampopt[SOWWHITE].ob_state &=(~SELECTED);
	ostampopt[SOLAS+stmp.save_type].ob_state |= SELECTED;
	w_objc_draw(&wstampopt, SOLAS, 8, sx,sy,sw,sh);
	w_objc_draw(&wstampopt, SONWHITE, 8, sx,sy,sw,sh);
	w_objc_draw(&wstampopt, SOWWHITE, 8, sx,sy,sw,sh);

	if(stmp.save_mode & 1)
		stamp_turn_on(SOSMEAR);
	else
		stamp_turn_off(SOSMEAR);
	if(stmp.save_mode & 2)
		stamp_turn_on(SOMASK);
	else
		stamp_turn_off(SOMASK);

	reset_stamp_view();
}

void save_stempel(int fh)
{/* Stempel in geîffnete Datei fh schreiben, Magic muû schon geschrieben sein */
	long tsiz;
	
	/* Buffergrîûe berechnen */
	tsiz=4*stmp.siz;	/* Puffermaske und Ebene werden natÅrlich nicht
												gespeichert */

	/* Type speichern */
	if(ostampopt[SOLAS].ob_state & SELECTED)
		stmp.save_type=0;
	else if(ostampopt[SONWHITE].ob_state & SELECTED)
		stmp.save_type=1;
	else
		stmp.save_type=2;
	
	/* Mask/Smearmode sichern */
	stmp.save_mode=0;
	if(ostampopt[SOSMEAR-1].ob_state & SELECTED)
		stmp.save_mode|=1;
	if(ostampopt[SOMASK-1].ob_state & SELECTED)
		stmp.save_mode|=2;
	
	graf_mouse(BUSYBEE, NULL);
	Fwrite(fh, sizeof(STEMPEL), &stmp);
	Fwrite(fh, tsiz, stmp.buf);
	Fclose(fh);
	graf_mouse(ARROW, NULL);
}

void stempel_io(void)
{
	int fh;
	
	if(stmp.buf == NULL)	
		fh=quick_io("Stempel", paths.stempel_path, NULL, NULL, -1, magics.stempel);
	else
		fh=quick_io("Stempel", paths.stempel_path, NULL, NULL, 0, magics.stempel);
	if(fh > 0)
		load_stempel(fh);
	else if(fh < 0)
		save_stempel(-fh);
}


/* Options-Fenster */

void stamp_turn_on(int ob)
{
	ostampopt[ob-1].ob_state |= SELECTED;
	ostampopt[ob].ob_x=ostampopt[ob].ob_y=1;
	if(wstampopt.open)
		w_objc_draw(&wstampopt, ob-1, 8, sx,sy,sw,sh);
}

void stamp_turn_off(int ob)
{
	ostampopt[ob-1].ob_state &= (~SELECTED);
	ostampopt[ob].ob_x=ostampopt[ob].ob_y=0;
	if(wstampopt.open)
		w_objc_draw(&wstampopt, ob-1, 8, sx,sy,sw,sh);
}

void	stampopt_closed(WINDOW *win)
{
	w_close(win);
	w_kill(win);
}

void stampopt_window(void)
{
	if(!wstampopt.open)
	{
		/* Fenster initialisieren */
		fill_st_preview(SOVDATA);
		fill_st_preview(SOVMASK);
		wstampopt.dinfo=&dstampopt;
		w_kdial(&wstampopt, D_CENTER, MOVE|NAME|BACKDROP|CLOSE);
		wstampopt.closed=stampopt_closed;
		wstampopt.name="[Grape] Stempel";
		w_set(&wstampopt, NAME);
		w_open(&wstampopt);
	}
	else
		w_top(&wstampopt);
}

void sp_switch(int ob)
{/* Schaltet Selektionzustand der Stempel-Buttons um 
		ob=Image-Nummer, Button ist also ob-1 */

	int dum, k;
	
	if(ostampopt[ob-1].ob_state & SELECTED)
	{/* deselektieren */
		ostampopt[ob-1].ob_state &= (~SELECTED);
		ostampopt[ob].ob_x=0;
		ostampopt[ob].ob_y=0;
	}
	else
	{/* Selektieren */
		ostampopt[ob-1].ob_state |= SELECTED;
		ostampopt[ob].ob_x=1;
		ostampopt[ob].ob_y=1;
	}
	if(wstampopt.open)
		w_objc_draw(&wstampopt, ob-1, 8, sx, sy, sw, sh);
	
	while((graf_mkstate(&dum, &dum, &k, &dum)!=1) || k);
}

void dial_stampopt(int ob)
{
	switch(ob)
	{
		case SOGDATA:
			get_clip_stempel(0);
		break;
		case SOGMASK:
			get_clip_stempel(1);
		break;
		case SOQIO:
			stempel_io();
		break;
		case SOSMEAR:
		case SOMASK:
			sp_switch(ob);
		break;
	}
}


/*

Preview

*/

void st_used_size(int *nw, int *nh, int ob)
{ /* Die im Fenster ausgenutzte Breite/Hîhe fÅr den Preview */
	int		 hw, hh;
	double h_zu_w;
	
	/* VerhÑltnis */
	h_zu_w=(double)stmp.h/(double)stmp.w;
	
	hw=ostampopt[ob].ob_width;
	hh=ostampopt[ob].ob_height;
	*nw=stmp.w;
	*nh=stmp.h;

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

void fill_st_preview(int ob)
{/* FÅllt das Previewfenster ob=SOVDATA oder SOVMASK */
	uchar	*sc, *sm, *sy;
	register int		x,y,w;
	register uchar	*dc, *dm, *dy;
	register long		doff;

	int			uw, uh;
	
	st_used_size(&uw, &uh, ob);
	
	/* Inhalt lîschen */	
	w=ostampopt[ob].ob_width;
	doff=(long)((U_OB*)(ostampopt[ob]_UP_))->color.w-w;

	dc=((U_OB*)(ostampopt[ob]_UP_))->color.b;
	dm=((U_OB*)(ostampopt[ob]_UP_))->color.r;
	dy=((U_OB*)(ostampopt[ob]_UP_))->color.g;

	
	for(y=ostampopt[ob].ob_height; y > 0; --y)
	{
		for(x=w; x > 0; --x)
		{
			*dc++=128;
			*dm++=128;
			*dy++=128;
		}
		dc+=doff; dm+=doff; dy+=doff;
	}

	if(stmp.buf==NULL) return;
	
	/* Skalieren */
	doff=(long)((U_OB*)(ostampopt[ob]_UP_))->color.w-ostampopt[ob].ob_width;
	doff+=ostampopt[ob].ob_width-uw;
	dc=((U_OB*)(ostampopt[ob]_UP_))->color.b;
	dm=((U_OB*)(ostampopt[ob]_UP_))->color.r;
	dy=((U_OB*)(ostampopt[ob]_UP_))->color.g;

	if(ob==SOVDATA)
	{/* Daten skalieren */
		if(stmp.sdef==0) return; /* UngÅltige Daten */
		sc=stmp.buf;
		sm=sc+stmp.siz;
		sy=sm+stmp.siz;
	}
	else
	{/* Maske skalieren */
		if(stmp.mdef==0) return; /* UngÅltige Daten */
		sc=sm=sy=stmp.buf+3*stmp.siz;
	}

	simple_scale_one(sc, dc, stmp.w, stmp.h, uw, uh, 
							 doff, stmp.w, 0, 0);
		
	simple_scale_one(sm, dm, stmp.w, stmp.h, uw, uh, 
							 doff, stmp.w, 0, 0);

	simple_scale_one(sy, dy, stmp.w, stmp.h, uw, uh, 
							 doff, stmp.w, 0, 0);
		
}

void reset_data_view(void)
{
	if(!wstampopt.open) return;

	fill_st_preview(SOVDATA);
	w_objc_draw(&wstampopt, SOVDATA, 8, sx,sy,sw,sh);
}

void reset_stamp_view(void)
{
	if(!wstampopt.open) return;

	fill_st_preview(SOVDATA);
	w_objc_draw(&wstampopt, SOVDATA, 8, sx,sy,sw,sh);
	ostampopt[SOVDATA].ob_state &= (~WHITEBAK);
	fill_st_preview(SOVMASK);
	w_objc_draw(&wstampopt, SOVMASK, 8, sx,sy,sw,sh);
}