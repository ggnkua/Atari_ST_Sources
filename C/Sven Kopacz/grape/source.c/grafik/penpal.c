#include <grape_h.h>
#include "grape.h"
#include "penedit.h"
#include "penpal.h"
#include "maininit.h"
#include "xrsrc.h"
#include "gpenic.h"

void sel_pen_up(void);
void sel_pen_down(void);
PEN_LIST *find_pen_list(int num);

/*

 Werkzeugpalette

*/
void sel_psel(void)
{ /* Selektiert das Stiftwerkzeug */
	int a;
	
	for(a=SDRAW; a <= SZOOM; ++a)
		ospecial[a].ob_state &= (~SELECTED);
		
	ospecial[SDRAW].ob_state |= SELECTED;
	dial_special(SDRAW);
	if(wspecial.open)
		s_redraw(&wspecial);
}

void dial_pens(int ob)
{
	int elm, dif, pbuf[8];
	PEN_LIST *pl, *mpl;
	char	alert[250];
	
	dif=GPS2-GPS1;

	if((ob >= GPS1) && (ob <= pens_obs.last))
	{/* Klick in Liste */
		elm=(ob-GPS1)/(dif); /* Listenelement */
		if(elm+pens_obs.off != pens_obs.sel)
		{/* Was neues selektiert */
			if((pens_obs.sel > -1) && 
				(pens_obs.sel >= pens_obs.off) && 
				(pens_obs.sel-pens_obs.off < pens_obs.len))
			{ /* Altes Element deselektieren */
				opens[dif*(pens_obs.sel-pens_obs.off)+GPS1].ob_state &= (~SELECTED);
				opens[dif*(pens_obs.sel-pens_obs.off)+GPSN].ob_state &= (~SELECTED);
				((TED_COLOR*)&(opens[dif*(pens_obs.sel-pens_obs.off)+GPSN].ob_spec.tedinfo->te_color))->pattern=0;
				((TED_COLOR*)&(opens[dif*(pens_obs.sel-pens_obs.off)+GPSN].ob_spec.tedinfo->te_color))->pat_color=0;
				w_objc_draw(&wpens, dif*(pens_obs.sel-pens_obs.off)+GPS1, 8, sx, sy, sw, sh);
				w_objc_draw(&wpens, dif*(pens_obs.sel-pens_obs.off)+GPSN, 8, sx, sy, sw, sh);
			}
			pens_obs.sel=elm+pens_obs.off;
			opens[elm*dif+GPSN].ob_state |= SELECTED;
			opens[elm*dif+GPS1].ob_state |= SELECTED;
			((TED_COLOR*)&(opens[elm*dif+GPSN].ob_spec.tedinfo->te_color))->pattern=7;
			((TED_COLOR*)&(opens[elm*dif+GPSN].ob_spec.tedinfo->te_color))->pat_color=13;
			w_objc_draw(&wpens, elm*dif+GPS1, 8, sx, sy, sw, sh);
			w_objc_draw(&wpens, elm*dif+GPSN, 8, sx, sy, sw, sh);
			/* Passenden Pen aktivieren, falls nicht Alt gedrÅckt */
			if(!(Kbshift(-1) & 8))
			{
				wind_update(BEG_MCTRL);
				graf_mouse(BUSYBEE, NULL);
				make_pen(find_pen(elm+pens_obs.off));
				graf_mouse(ARROW, NULL);
				wind_update(END_MCTRL);
				/* Werkzeug auf Stift umschalten */
				sel_psel();
			}
		}
	}
	else switch(ob)
	{
		case GPSNEU:
			/* Neuen Pen anhÑngen */
			elm=0;
			pl=&first_pen;
			while(pl->next)
			{ pl=pl->next; ++elm;}
			pl->next=(PEN_LIST*)malloc(sizeof(PEN_LIST));
			if(!pl->next)
			{
				form_alert(1,"[3][Nicht genug Speicher!][Abbruch]");
				return;
			}
			pl->next->prev=pl;
			pl=pl->next;
			pl->this=default_pen;
			pl->next=NULL;
			++elm;
			/* Liste neu aufbauen */
			pens_obs.off=elm-pens_obs.len+1;
			pens_obs.sel=elm;
			init_pens();
			s_redraw(&wpens);
			w_unsel(&wpens, GPSNEU);
		break;
		case GPSEDIT:
			if(pens_obs.sel > -1)
			{
				pgp=*find_pen(pens_obs.sel);
				init_pened();
				if(wpened.open)
				{
					w_top(&wpened);
					s_redraw(&wpened);
				}
				else
					w_open(&wpened);
			}
			w_unsel(&wpens, GPSEDIT);
		break;
		case GPSDEL:
			if(pens_obs.sel == -1)
			{
				form_alert(1,"[3][Grape:|Es ist kein Stift zum|Lîschen selektiert.][Abbruch]");
				w_unsel(&wpens, GPSDEL);
				break;
			}
			pl=find_pen_list(pens_obs.sel);
			if((pl->next==NULL) && (pl->prev==NULL))
			{/* Einziger Stift soll gelîscht werden, geht nicht! */
				form_alert(1,"[3][Grape:|Es muû mindestens ein Stift|erhalten bleiben.][Abbruch]");
				w_unsel(&wpens, GPSDEL);
				break;
			}
			if(pl==NULL) break;	/* Komisch, sollte nicht passieren */
			strcpy(alert, "[2][Grape:|Soll der Stift|");
			strcat(alert, pl->this.name);
			strcat(alert,"|wirklich gelîscht werden?][OK|Abbruch]");
			if(form_alert(1,alert)==2)
			{
				w_unsel(&wpens, GPSDEL);
				break;
			}
			/* Stift lîschen */
			if(pl->prev==NULL) /* Stift ist erster Stift */
			{
				mpl=pl->next;	/* FÅrs lîschen merken! */
				first_pen=*(pl->next);	/* first_pen ist kein Zeiger! */
				first_pen.prev=NULL;
				if(first_pen.next)
					first_pen.next->prev=&first_pen;
				pl=mpl;
			}
			else
			{
				pl->prev->next=pl->next;
				if(pl->next != NULL)
					pl->next->prev=pl->prev;
			}
			free(pl);
			pens_obs.sel=-1;
			init_pens();
			wind_get(wpens.whandle, WF_CURRXYWH, &pbuf[4], &pbuf[5], &pbuf[6], &pbuf[7]);
			pens_sized(&wpens, pbuf);
			s_redraw(&wpens);
			w_unsel(&wpens, GPSDEL);
		break;
		
		case GPENSLS:
			pens_load_save();
		break;
		
		case GPUP:
			if(pens_obs.sel > 0)
				sel_pen_up();
		break;
		case GPDOWN:
			if((pens_obs.sel > -1) && (pens_obs.sel < count_pens()-1))
				sel_pen_down();
		break;
	}
}

void sel_pen_up(void)
{ /* Selektierten Stift in Liste eins nach oben */
	PEN_LIST *act;
	PEN_PARAMETER buf;
	
	act=find_pen_list(pens_obs.sel);

	/* Parameter vertauschen */
	buf=act->this;
	act->this=act->prev->this;
	act->prev->this=buf;
	
	/* Selektion anpassen */
	--pens_obs.sel;
	if(pens_obs.sel < pens_obs.off)
		pens_obs.off=pens_obs.sel;
	
	/* Redraw veranlassen */
	init_pens();
	s_redraw(&wpens);
}

void sel_pen_down(void)
{ /* Selektierten Stift in Liste eins nach unten */
	PEN_LIST *act;
	PEN_PARAMETER buf;
	
	act=find_pen_list(pens_obs.sel);

	/* Parameter vertauschen */
	buf=act->this;
	act->this=act->next->this;
	act->next->this=buf;
	
	/* Selektion anpassen */
	++pens_obs.sel;
	if(pens_obs.sel >= pens_obs.off+pens_obs.len)
		pens_obs.off=pens_obs.sel-pens_obs.len+1;
	/* Redraw veranlassen */
	init_pens();
	s_redraw(&wpens);
}

void pens_load_save(void)
{
	int fh;
	
	fh=quick_io("Stift-Palette", paths.pens_path, NULL, NULL, 0, magics.pens);
	if(fh>0)
	{
		if(!(form_alert(1,"[1][Grape:|Die vorhandenen Werkzeuge|werden Åberschrieben!][OK|Abbruch]")-1))
			pens_load(fh);
	}
	else if(fh < 0)
		pens_save(-fh);
}

void pens_load(int fh)
{
	int	a,l, pbuf[8], not_l=-1;
	PEN_LIST	*p=&first_pen, *np;
	
	wind_update(BEG_MCTRL);
	graf_mouse(BUSYBEE, NULL);
	
	/* Zum letzten Werkzeug */
	while(p->next) p=p->next;

	/* Alte Werkzeuge freigeben */
	while(p->prev)
	{
		p=p->prev;
		free(p->next);
	}
	
	/* Anzahl laden */
	Fread(fh, sizeof(int), &a);
	/* Pens laden */
	for(l=0; l<a; ++l)
	{
		Fread(fh, sizeof(PEN_PARAMETER), &p->this);
		if(l < (a-1))
		{/* Speicher fÅr's nÑchste Reservieren */
			p->next=(PEN_LIST*)malloc(sizeof(PEN_LIST));
			if(!p->next)
			{
				form_alert(1,"[3][Grape:|Nicht genug Speicher, um|die Stiftpalette zu laden!][Abbruch]");
				not_l=l-1;
				break;
			}
			
			p->next->prev=p;
			p=p->next;
		}
		else
			p->next=NULL;
	}

	Fread(fh, sizeof(pens_obs), &pens_obs);
	
	Fclose(fh);
	
	graf_mouse(ARROW, NULL);
	wind_update(END_MCTRL);

	if(not_l > -1)
	{
		np=p;
		while(np->next) np=np->next;
		while(np->prev)
		{
			np=np->prev;
			free(np->next);
		}
		
		first_pen.this=default_pen;
		pens_obs.off=0; pens_obs.sel=-1;
		pens_obs.len=1; pens_obs.last=0;
		init_pens();
		wind_get(wpens.whandle, WF_CURRXYWH, &pbuf[4], &pbuf[5], &pbuf[6], &pbuf[7]);
		pens_sized(&wpens, pbuf);
	}
	else
	{	
		if(T_WINPOS)
		{
			wpens.wx=pens_obs.wx;
			wpens.wy=pens_obs.wy;
			wpens.ww=pens_obs.ww;
			wpens.wh=pens_obs.wh;
			w_set(&wpens, CURR);
		}
		else
		{
			init_pens();
			wind_get(wpens.whandle, WF_CURRXYWH, &pbuf[4], &pbuf[5], &pbuf[6], &pbuf[7]);
			pens_sized(&wpens, pbuf);
		}
	}
	
	init_pens();
	s_redraw(&wpens);
	if(pens_obs.sel > -1)
		make_pen(find_pen(pens_obs.sel));
}

void pens_save(int fh)
{
	int a, l;
	
	wind_update(BEG_MCTRL);
	graf_mouse(BUSYBEE, NULL);

	a=count_pens();
	Fwrite(fh, sizeof(int), &a);
	
	for(l=0; l<a; ++l)
		Fwrite(fh, sizeof(PEN_PARAMETER), find_pen(l));
	
	pens_obs.wx=wpens.wx;
	pens_obs.wy=wpens.wy;
	pens_obs.ww=wpens.ww;
	pens_obs.wh=wpens.wh;
	
	Fwrite(fh, sizeof(pens_obs), &pens_obs);
	Fclose(fh);

	graf_mouse(ARROW, NULL);
	wind_update(END_MCTRL);
}

PEN_PARAMETER *find_pen(int num)
{/* Sucht aus Liste den pen nr. num und gibt PEN_PARAMETER zurÅck */
 /* Gibts garnicht so viele, wird default_pen geliefert */
	PEN_LIST	*p;
	
	p=&first_pen;
	while((num--) && p->next)
		p=p->next;
	
	if(num > -1)
		return(&default_pen);

	return(&p->this);
}

PEN_LIST *find_pen_list(int num)
{ /* Wie find_pen(), liefert aber den Zeiger auf den Listeneintrag 
     und bei Nichtvorhanden NULL */
     
  PEN_LIST *p=&first_pen;

	while((num--) && p->next)
		p=p->next;
	
	if(num > -1)
		return(NULL);

	return(p);
}

int count_pens(void)
{ /* ZÑhlt die Pens in der Liste */

	PEN_LIST *p;
	int	a=1;

	p=&first_pen;
	while(p->next)
	{
		p=p->next;
		++a;
	}

	return(a);
}

void init_pen(int num)
{
	/* Setzt die Objekte des Pens num neu */
	PEN_PARAMETER *p;
	int a;
	
	p=find_pen(num);
	a=num-pens_obs.off;
	if((a >= 0) && (a < pens_obs.len))
	{
		/* Objekt belegen */
		/* Icon */
		opens[GPS1+a*(GPS2-GPS1)].ob_spec.iconblk=oicons[p->oicon+ICON_1].ob_spec.iconblk;
		/* Merker */
		opens[GPSM1+a*(GPS2-GPS1)].ob_spec.bitblk=omerk[p->om1+MERK_1].ob_spec.bitblk;
		opens[GPSM2+a*(GPS2-GPS1)].ob_spec.bitblk=omerk[p->om2+MERK_1].ob_spec.bitblk;
		/* Name */
		strcpy(opens[GPSN+a*(GPS2-GPS1)].ob_spec.tedinfo->te_ptext, p->name);
		/* Taste */
		strcpy(opens[GPSK+a*(GPS2-GPS1)].ob_spec.tedinfo->te_ptext, p->keyname);
		/* Umschalttasten */
		opens[GPSA+a*(GPS2-GPS1)].ob_state &= (~SELECTED);
		opens[GPSC+a*(GPS2-GPS1)].ob_state &= (~SELECTED);
		opens[GPSS+a*(GPS2-GPS1)].ob_state &= (~SELECTED);
		if(p->okbs)
			opens[GPSA+a*(GPS2-GPS1)-1+p->okbs].ob_state |= SELECTED;
		s_redraw(&wpens);
	}
}

void init_pens(void)
{/* Setzt die ganze Werkzeugliste neu */
	int a, ix, y_off=osrcpens[GPSHEAD].ob_height;
	long	l;
	PEN_PARAMETER *p;
	OBJECT	*ntree;
	TEDINFO *tdi;	
	char		*text;
	
	l=(GPS2-GPS1)*pens_obs.len+GPS1;	/* Anzahl Objekte */
	l*=sizeof(OBJECT);	/* Speicherbedarf */
	l+=(long)pens_obs.len*sizeof(TEDINFO)*5;	/* 5 textobjekte pro Stift */
	l+=(long)pens_obs.len*20;	/* 20 Textbytes pro Stift */
	
	ntree=(OBJECT*)realloc(opens, l);
	if(ntree==NULL)
	{
		form_alert(1,"[3][Grape:|Nicht genug Speicher um die|Stiftpalette neu aufzubauen!][Abbruch]");
		return;
	}
	opens=ntree;
	dpens.tree=opens;
	tdi=(TEDINFO*)(&(opens[(GPS2-GPS1)*pens_obs.len+GPS1]));
	text=(char*)(&(tdi[5*pens_obs.len]));
	for(a=0; a < pens_obs.len; ++a)
	{
		p=find_pen(a+pens_obs.off);
		/* Objekt belegen */
		ix=GPS1+a*(GPS2-GPS1);
		/* Icon */
		opens[ix]=osrcpens[GPS1];	opens[ix].ob_next=ix+1;
		opens[ix].ob_spec.iconblk=oicons[p->oicon+ICON_1].ob_spec.iconblk;
		opens[ix].ob_y=y_off+a*osrcpens[GPS1].ob_height;
		/* Merker-Parent */
		++ix;
		opens[ix]=osrcpens[GPS1+1];	opens[ix].ob_next=ix+3;
		opens[ix].ob_head=ix+1; opens[ix].ob_tail=ix+2;
		opens[ix].ob_y=y_off+a*osrcpens[GPS1].ob_height;
		/* Merker 1 */
		++ix;
		opens[ix]=osrcpens[GPSM1];	opens[ix].ob_next=ix+1;
		opens[ix].ob_head=opens[ix].ob_tail=-1;
		opens[ix].ob_y=0;
		opens[ix].ob_spec.bitblk=omerk[p->om1+MERK_1].ob_spec.bitblk;
		/* Merker 2 */
		++ix;
		opens[ix]=osrcpens[GPSM2];	opens[ix].ob_next=ix-2;
		opens[ix].ob_head=opens[ix].ob_tail=-1;
		opens[ix].ob_y=osrcpens[GPSM1].ob_height;
		opens[ix].ob_spec.bitblk=omerk[p->om2+MERK_1].ob_spec.bitblk;
		/* Name */
		++ix;
		opens[ix]=osrcpens[GPSN];	opens[ix].ob_next=ix+1;
		opens[ix].ob_y=y_off+a*osrcpens[GPS1].ob_height;
		opens[ix].ob_spec.tedinfo=&(tdi[a*5]);
		tdi[a*5]=*(osrcpens[GPSN].ob_spec.tedinfo);
		opens[ix].ob_spec.tedinfo->te_ptext=text;
		text+=16;
		strcpy(opens[ix].ob_spec.tedinfo->te_ptext, p->name);
		/* Umschalttasten */
		/* Alt */
		++ix;
		opens[ix]=osrcpens[GPSA];	opens[ix].ob_next=ix+1;
		opens[ix].ob_y=y_off+a*osrcpens[GPS1].ob_height;
		opens[ix].ob_spec.tedinfo=&(tdi[a*5+1]);
		tdi[a*5+1]=*(osrcpens[GPSA].ob_spec.tedinfo);
		/* Ctrl */
		++ix;
		opens[ix]=osrcpens[GPSC];	opens[ix].ob_next=ix+1;
		opens[ix].ob_y=y_off+a*osrcpens[GPS1].ob_height;
		opens[ix].ob_spec.tedinfo=&(tdi[a*5+2]);
		tdi[a*5+2]=*(osrcpens[GPSC].ob_spec.tedinfo);
		/* Shift */
		++ix;
		opens[ix]=osrcpens[GPSS];	opens[ix].ob_next=ix+1;
		opens[ix].ob_y=y_off+a*osrcpens[GPS1].ob_height;
		opens[ix].ob_spec.tedinfo=&(tdi[a*5+3]);
		tdi[a*5+3]=*(osrcpens[GPSS].ob_spec.tedinfo);

		if(p->okbs)
			opens[ix-1+p->okbs].ob_state |= SELECTED;

		/* Taste */
		++ix;
		opens[ix]=osrcpens[GPSK];	opens[ix].ob_next=ix+1;
		opens[ix].ob_y=y_off+a*osrcpens[GPS1].ob_height+osrcpens[GPS1+5].ob_height;
		opens[ix].ob_spec.tedinfo=&(tdi[a*5+4]);
		tdi[a*5+4]=*(osrcpens[GPSK].ob_spec.tedinfo);
		opens[ix].ob_spec.tedinfo->te_ptext=text;
		text+=4;
		strcpy(opens[ix].ob_spec.tedinfo->te_ptext, p->keyname);
	}
	opens[ix].ob_next=0;
	opens[ix].ob_flags |= LASTOB;
	opens[0].ob_tail=ix;
	opens[0].ob_height=osrcpens[GPSHEAD].ob_height+pens_obs.len*osrcpens[GPS1].ob_height;
	
	if((pens_obs.sel >= pens_obs.off) && (pens_obs.sel-pens_obs.off < pens_obs.len))
	{
		opens[(pens_obs.sel-pens_obs.off)*(GPS2-GPS1)+GPSN].ob_state |= SELECTED;
		((TED_COLOR*)&(opens[(pens_obs.sel-pens_obs.off)*(GPS2-GPS1)+GPSN].ob_spec.tedinfo->te_color))->pattern=7;
		((TED_COLOR*)&(opens[(pens_obs.sel-pens_obs.off)*(GPS2-GPS1)+GPSN].ob_spec.tedinfo->te_color))->pat_color=13;
		opens[(pens_obs.sel-pens_obs.off)*(GPS2-GPS1)+GPS1].ob_state |= SELECTED;
	}
	
	/* Fensterelemente anpassen */
	a=count_pens();
	l=(long)((long)pens_obs.len*(long)1000);
	l/=(long)a;
	wpens.vsiz=(int)l;
	l=(long)((long)pens_obs.off*(long)1000);
	a-=pens_obs.len;
	if(!a)
		l=1000;
	else
		l/=(long)a;
	wpens.vpos=(int)l;
	w_set(&wpens, VSLIDE);
}

void pens_arrowed(WINDOW *win, int *pbuf)
{
	int r=0;
	
	switch(pbuf[4])
	{
		case WA_UPLINE:
			if(pens_obs.off)
			{
				--pens_obs.off;
				r=1;
			}
		break;
		case WA_DNLINE:
			if(pens_obs.off < (count_pens()-pens_obs.len))
			{
				++pens_obs.off;
				r=1;
			}
		break;
		
		case WA_UPPAGE:
			if(pens_obs.off)
			{
				pens_obs.off-=pens_obs.len;
				if(pens_obs.off < 0) pens_obs.off=0;
				r=1;
			}
		break;
		case WA_DNPAGE:
			if(pens_obs.off < (count_pens()-pens_obs.len))
			{
				pens_obs.off+=pens_obs.len;
				if(pens_obs.off > count_pens()-pens_obs.len)
					pens_obs.off=count_pens()-pens_obs.len;
				r=1;
			}
		break;
	}
	
	if(r)
	{
		init_pens();
		s_redraw(win);
	}
}

void pens_vslid(WINDOW *win, int *pbuf)
{
	long	l;
	
	l=pbuf[4];
	l*=(long)((long)count_pens()-(long)pens_obs.len);
	l/=1000l;
	
	if(l != pens_obs.off)
	{
		pens_obs.off=(int)l;
		init_pens();
		s_redraw(win);
	}
}

void pens_sized(WINDOW *win, int *pbuf)
{
	int	a, r=0;

	/* Aktuelle Hîhe bestimmen */
	/* (ist wichtig falls neue Liste geladen wird, die kÅrzer ist
	    und die gespeicherten Koordinaten ignoriert werden) */
	w_get(win);
	pens_obs.len=(win->ah-opens[GPSHEAD].ob_height)/opens[GPS1].ob_height;
	
	/* Neue Grîûe berechnen */
	wind_calc(WC_WORK, win->kind, pbuf[4], pbuf[5], pbuf[6], pbuf[7], &pbuf[4], &pbuf[5], &pbuf[6], &pbuf[7]);
	a=(pbuf[7]-opens[GPSHEAD].ob_height	)/opens[GPS1].ob_height;
	
	if(a < 1) a=1;
	if(a > 20) a=20;
	if(a > count_pens()) a=count_pens();
	if(pbuf[6] > opens[0].ob_width+2) pbuf[6]=opens[0].ob_width+2;
	if(pbuf[6] < opens[GPS1].ob_width) pbuf[6]=opens[GPS1].ob_width;
	if((a != pens_obs.len) || (pbuf[6] != win->aw))
	{
		w_calc(win);
		win->ah=opens[GPSHEAD].ob_height+opens[GPS1].ob_height*a;
		win->aw=pbuf[6];
		w_wcalc(win);
		w_set(win, CURR);
		pens_obs.last=GPSK+(a-1)*(GPS2-GPS1);

		if(a <= pens_obs.len)
		{ /* Kleiner->auf Redraw verzichten */
			pens_obs.len=a;
			init_pens();
		}
		else
		{ /* Grîûer->evtl. pos. etc. neu setzen */
			pens_obs.len=a;
			if(pens_obs.off+pens_obs.len > count_pens())
			{
				pens_obs.off=count_pens()-pens_obs.len;
				r=1;
			}
			init_pens();
			if(r)
				s_redraw(win);
		}
	}
}

