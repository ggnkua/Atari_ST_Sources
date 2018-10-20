#include <grape_h.h>
#include <atarierr.h>
#include "grape.h"
#include "xrsrc.h"
#include "export.h"
#include "fiomod.h"
#include "file_i_o.h"
#include "layer.h"
#include "ctcppt.h"

int sel_exfo=0;	/* Selektiertes Exportformat in Liste */
int	list_off=0;	/* Offset in Liste */

void 	put_base_to_pop(void);

extern void check_aopt_export(void);
extern WINDOW waopt;
/* 
* EXPORT *
*/

int two_high(int exp)
{/* Gibt 2^exp zurÅck */
	int a=1;
	
	while(exp--)	a<<=1;
	return(a);
}

void get_vis_lay_data(unsigned char **c_buf, unsigned char **m_buf, unsigned char **y_buf, long *h, long *w, long *uw)
{/* Gibt Daten der ersten sichtbaren Ebene zurÅck */
	LAY_LIST	*l=first_lay;
	
	do
	{
		if(l->this.visible)
		{
			*c_buf=l->this.blue;
			*m_buf=l->this.red;
			*y_buf=l->this.yellow;
			*h=l->this.height;
			*w=l->this.width;
			*uw=l->this.word_width;
		}
		l=l->next;
	}while(l);
}

int export(void)
{/* ret: 1=ok, 0=nix gespeichert */
	EXP_FORM	*ep=first_expf;
	FIOMODBLK	*fb;
	char	npath[256], path[256], name[64], ext[16];
	long	fhl, w, h, uw;
	int		fh, id;
	uchar	*pc, *pm, *py;
	GRAPE_DSCR	gdd;
	FILE_DSCR	fdd;
	_frame_data old_frame=frame_data;

	strcpy(path, paths.main_export_path);
	strcpy(name, paths.main_export_name);

	if(f_sinput("Exportdatei wÑhlen", path, name)==0) return(0);

	strcpy(paths.main_export_path, path);
	strcpy(paths.main_export_name, name);
	make_path(npath, path, name);
	
	fhl=Fopen(npath, FO_READ);
	Fclose((int)fhl);
	if(fhl >= 0)/* Datei gibts schon */
		if(form_alert(1,"[2][Grape:|Soll die Datei Åberschrieben|werden?][OK|Abbruch]")==2)
			return(0);

	/* Quelldaten holen bzw. Pointer setzen */

	graf_mouse(BUSYBEE,NULL);
	if(oexport[EXALL].ob_state & SELECTED)
	{/* Alles kopieren */
		if(count_vis_layers()==0)
		{
			form_alert(1,"[3][Grape:|Es sind keine Ebenen sichtbar|geschaltet.][Abbruch]");
			return(0);
		}
		if(count_vis_layers()==1) /* Nur eine->Kopieren sparen */
			get_vis_lay_data(&pc, &pm, &py, &h, &w, &uw);
		else
		{
			frame_data.x=0; frame_data.y=0;
			frame_data.w=first_lay->this.width;
			frame_data.h=first_lay->this.height;
			if(get_vis_frame(&pc, &pm, &py, &h, &w, &uw)==0)
			{
				frame_data=old_frame;
				graf_mouse(ARROW,NULL);
				form_alert(1,"[3][Grape:|Nicht genug Pufferspeicher!][Abbruch]");
				return(0);
			}
			frame_data=old_frame;
		}
	}
	else if(oexport[EXVISSEL].ob_state & SELECTED)
	{/* Sichtbare Auswahl kopieren */
		if(count_vis_layers()==0)
		{
			form_alert(1,"[3][Grape:|Es sind keine Ebenen sichtbar|geschaltet.][Abbruch]");
			return(0);
		}
		if(count_vis_layers()==1) /* Nur eine->Kopieren sparen */
			get_vis_lay_data(&pc, &pm, &py, &h, &w, &uw);
		else
		{
			if(get_vis_frame(&pc, &pm, &py, &h, &w, &uw)==0)
			{
				graf_mouse(ARROW,NULL);
				form_alert(1,"[3][Grape:|Nicht genug Pufferspeicher!][Abbruch]");
				return(0);
			}
		}
	}
	else
	{/* Nur Auswahl aus Edit-Ebene kopieren */
		fhl=(long)((long)(frame_data.y)*(long)(first_lay->this.word_width));
		fhl+=(long)(frame_data.x);
		pc=(uchar*)(first_lay->this.blue)+fhl;
		pm=(uchar*)(first_lay->this.red)+fhl;
		py=(uchar*)(first_lay->this.yellow)+fhl;
		w=frame_data.w;
		h=frame_data.h;
		uw=first_lay->this.word_width;
	}
	gdd.height=(int)h;
	gdd.width=(int)w;
	gdd.line_width=(int)uw;
	gdd.c=pc;
	gdd.m=pm;
	gdd.y=py;
	gdd.mask=NULL;
	gdd.done_bytes=0;
	
	id=oexport[EXFORMPOP].ob_type >> 8;
	while(ep && (ep->f_id != id))
		ep=ep->next;
	if(!ep) return(0);	/* Kann eigentlich nie vorkommen */

	fb=find_fiomod_by_id(ep->base_id);
	if(!fb) return(0);	/* Kann eigentlich auch nie vorkommen */
				
	fhl=Fcreate(npath, 0);
	if(fhl < 0)
	{
		graf_mouse(ARROW,NULL);
		form_alert(1,"[3][Grape:|Fehler beim Anlegen der Datei.][Abbruch]");
		return(0);
	}
	
	fh=(int)fhl;

	fdd.fh=fh;
	fdd.path=path;
	fdd.name=name;
	fdd.ext=ext;
	/* Pfad hinter letztem '\' abschneiden */
	uw=strlen(path)-1;
	while((uw>0) && (path[uw]!='\\'))--uw;
	if(uw>0) path[uw+1]=0;
	/* Name am '.' abschneiden */
	uw=strlen(name)-1;
	while((uw>0) && (name[uw]!='.'))--uw;
	if(uw > 0)
	{
		strcpy(ext, &(name[uw]));
		name[uw]=0;
	}
	else
		ext[0]=0;
		
	id=fb->mod_fn->save_file(&fdd, &gdd, two_high(ep->depth), ep->compress, ep->opts);
	Fclose(fh);

	graf_mouse(ARROW,NULL);
	if(id < 0)
	{
		if(id==ENSMEM)
		{
			form_alert(1,"[3][Grape:|Nicht genug Pufferspeicher.][Abbruch]");
			Fdelete(npath);
		}
		else if(form_alert(1,"[3][Grape:|Fehler im Export-Modul.|Export-Datei lîschen?][Ja|Nein]")==2)
			Fdelete(npath);
	}
	return(1);
}

void check_ex_export(void)
{
	EXP_FORM	*ep=first_expf;
	int				id;

	id=oexport[EXFORMPOP].ob_type >> 8;
	while(ep && (ep->f_id != id))
		ep=ep->next;
	if(ep==NULL)
	{
		ep=first_expf;
		while(!(ep->base_id)) ep=ep->next;
	}

	strcpy(oexport[EXFORMPOP].ob_spec.free_string, ep->name);
	if(wexport.open)
		w_objc_draw(&wexport, EXFORMPOP, 8, sx, sy, sw, sh);
}

void check_what_export(void)
{
	if(frame_data.ok && frame_data.vis)
	{
		oexport[EXVISSEL].ob_state &=(~DISABLED);
		oexport[EXEDSEL].ob_state &=(~DISABLED);
		if(wexport.open)
			s_redraw(&wexport);
		return;
	}
	/* Frame nicht da */
	oexport[EXALL].ob_state |= SELECTED;
	oexport[EXVISSEL].ob_state &=(~SELECTED);
	oexport[EXEDSEL].ob_state &=(~SELECTED);
	oexport[EXVISSEL].ob_state |= DISABLED;
	oexport[EXEDSEL].ob_state |= DISABLED;
	if(wexport.open)
		s_redraw(&wexport);
}

void export_window(void)
{
	EXP_FORM	*ep=first_expf;
	
	if(!wexport.open)
	{
		while(ep)
		{
			if(ep->base_id) break;
			ep=ep->next;
		}
		
		if(ep==NULL)
		{
			if(form_alert(1,"[3][Grape:|Es sind keine Exportformate|definiert.][Definieren|Abbruch]")==1)
				fexport_window();
			return;
		}
		/* Fenster initialisieren */
		check_ex_export();
		check_what_export();
		wexport.dinfo=&dexport;
		w_dial(&wexport, D_CENTER);
		wexport.name="[Grape] Datei exportieren";
		w_set(&wexport, NAME);
		w_open(&wexport);
	}
	else
		w_top(&wexport);
}

void dial_export(int ob)
{
	switch(ob)
	{
		case EXFORM:
			w_unsel(&wexport, ob);
			fexport_window();
		break;
		case EXFORMPOP:
			exp_form_popup(&wexport, ob);
		break;
		case EXOK:
			if(export()==0)
			{
				w_unsel(&wexport, ob);
				break;
			}
		case EXABBRUCH:
			w_unsel(&wexport, ob);
			w_close(&wexport);
			w_kill(&wexport);
		break;
	}
}


/*
* EXPORT-FORMATE *
*/


void fexport_window(void)
{
	if(!wfexport.open)
	{
		if(first_fiomod==NULL)
		{
			form_alert(1,"[3][Grape:|Es wurden keine Im-/|Export-Module geladen.][Abbruch]");
			return;
		}
		if(count_fio_saveables()==0)
		{
			form_alert(1,"[3][Grape:|Es wurden keine Export-|fÑhigen Module geladen.][Abbruch]");
			return;
		}
		/* Fenster initialisieren */
		init_fexport();
		copy_list2set(sel_exfo);
		wfexport.dinfo=&dfexport;
		w_dial(&wfexport, D_CENTER);
		wfexport.name="[Grape] Exportformate definieren";
		w_set(&wfexport, NAME);
		dfexport.dedit=FXNAME;
		w_open(&wfexport);
	}
	else
		w_top(&wfexport);
}

void sl_fexlist(int n)
{/* Sliderservice */
	list_off=n;
	init_fexport();
	w_objc_draw(&wfexport, FXTXFRAME, 8, sx, sy, sw, sh);
}

void dial_fexport(int ob)
{
	switch(ob)
	{
		case FXSLIDE:
			set_act_sel();
			if(count_formats() > FXTXL-FXTX1+1)
				slide(ofexport, ob, 0, count_formats()-(FXTXL-FXTX1+1), list_off, sl_fexlist);
		break;
		case FXBAR:
			set_act_sel();
			bar(&wfexport, ob, 0, count_formats()-(FXTXL-FXTX1+1), sl_fexlist);
		break;
		
		case FXNEW:
			new_format();
			w_unsel(&wfexport, ob);
		break;
		case FXDEL:
			set_act_sel();
			delete_format();
			w_unsel(&wfexport, ob);
		break;
		case FXGET:
			set_act_sel();
			get_format(sel_exfo);
			w_unsel(&wfexport, ob);
		break;
		case FXSET:
			set_act_sel();
			set_format(sel_exfo);
			w_unsel(&wfexport, ob);
		break;
		
		case FXBASE:
			base_pop();
		break;
		case FXBIT:
			bit_pop();
		break;
		case FXCOMP:
			comp_pop();
		break;
		/* Option-Popups werden unten erledigt */
		
		case FXSAVE:
			w_unsel(&wfexport, ob);
			fxsave_window();
		break;
		case FXCLOSE:
			w_unsel(&wfexport, ob);
			w_close(&wfexport);
			w_kill(&wfexport);
		break;
	}
	if((ob >= FXO1) && (ob <= FXO8))
		opt_pop(ob-FXO1);
}

void set_act_sel(void)
{/* Sucht den ersten selektierten Eintrag und setzt sel_exfo */
	int n;
	
	for(n=FXTX1; n<=FXTXL; ++n)
	{
		if(ofexport[n].ob_state & SELECTED)
		{	sel_exfo=list_off+n-FXTX1; return;}
	}
}

int count_formats(void)
{
	EXP_FORM *el=first_expf;
	int				a=0;

	while(el)
	{
		el=el->next;
		++a;
	}
	
	return(a);
}

EXP_FORM *get_format_by_index(int ix)
{
	EXP_FORM *el=first_expf;

	while(el && ix)
	{
		el=el->next;
		--ix;
	}
	
	return(el);
}

void delete_format(void)
{
	EXP_FORM	*el=first_expf, **bl=&first_expf;
	int				a=sel_exfo;
	char			alert[256];
	if(sel_exfo >= count_formats())
	{
		form_alert(1,"[3][Grape:|Es ist kein Format selektiert.][Abbruch]");
		return;
	}
	while(a)
	{	
		--a;
		el=el->next;
		bl=&((*bl)->next);
	}

	if(el->base_id)
	{/* Nachfragen nur bei initialisierten Formaten */
		strcpy(alert,"[2][Grape:|Soll das Format|");
		strcat(alert, el->name);
		strcat(alert,"|wirklich gelîscht werden?][Ja|Nein]");
		if(form_alert(1,alert)==2) return;
	}
	
	*bl=el->next;
	free(el);
	if((sel_exfo >= count_formats()) && sel_exfo)
		--sel_exfo;
	if(list_off > count_formats()-(FXTXL-FXTX1+1))
	{
		list_off=count_formats()-(FXTXL-FXTX1+1);
		if(list_off < 0) list_off=0;
	}
	init_fexport();
	w_objc_draw(&wfexport, FXTXFRAME, 8, sx, sy, sw, sh);
	
	el=first_expf; a=0;
	while(el)
	{
		if(el->base_id) ++a;
		el=el->next;
	}
	if(a==0)
	{
		if(wexport.open)
			dial_export(EXABBRUCH);
		if(waopt.open)
			check_aopt_export();
		if(wfxsave.open)
			dial_fxsave(FXSABBRUCH);
	}
	
	if(wexport.open)
		check_ex_export();
			
	if(wfxsave.open)
	{
		put_base_to_pop();
		s_redraw(&wfxsave);
	}
	
}

void new_format(void)
{
	EXP_FORM *el, **ael=&first_expf;
		
	while(*ael) ael=&((*ael)->next);
	el=*ael=malloc(sizeof(EXP_FORM));
	if(el==NULL)
	{
		form_alert(1,"[3][Grape:|Nicht genug Speicher fÅr|neues Format.][Abbruch]");
		return;
	}
	el->f_id=expf_id++;
	strcpy(el->name, "Neues Format");
	el->base_id=0;
	el->depth=0;
	el->compress=-1;
	el->opts[0]=el->opts[1]=el->opts[2]=el->opts[3]=el->opts[4]=
	el->opts[5]=el->opts[6]=el->opts[7]=-1;
	el->next=NULL;
	sel_exfo=count_formats()-1;
	if(sel_exfo < list_off) list_off=sel_exfo;
	if(sel_exfo > list_off+(FXTXL-FXTX1)) list_off=sel_exfo-(FXTXL-FXTX1);
	init_fexport();
	w_objc_draw(&wfexport, FXTXFRAME, 8, sx, sy, sw, sh);

}

void init_fexport(void)
{
	EXP_FORM	*el=first_expf;
	int				n;
	long			m;

	/* Vorlagenobjekte verstecken */
	ofexport[FXOCHCK].ob_flags|=HIDETREE;
	ofexport[FXOPOP].ob_flags|=HIDETREE;

	/* Vorhandene Formate in Liste eintragen */
	n=0;
	while(el && (n < list_off))
	{el=el->next; ++n;}
	n=0;
	while(el && n <= (FXTXL-FXTX1))
	{
		strcpy(ofexport[FXTX1+n].ob_spec.tedinfo->te_ptext, el->name);
		ofexport[FXTX1+n].ob_state &= (~SELECTED);
		ofexport[FXTX1+n].ob_flags |= SELECTABLE;
		++n;
		el=el->next;
	}
	/* Ggf. restliche EintrÑge verstecken */
	while(n <= (FXTXL-FXTX1))
	{
		ofexport[FXTX1+n].ob_flags &= (~SELECTABLE);
		ofexport[FXTX1+n].ob_state &= (~SELECTED);
		ofexport[FXTX1+n].ob_spec.tedinfo->te_ptext[0]=0;	
		++n;
	}

	n=count_formats();
		
	/* Slider setzen */
	if(n <= (FXTXL-FXTX1+1))
	{
		ofexport[FXSLIDE].ob_height=ofexport[FXBAR].ob_height;
		ofexport[FXSLIDE].ob_y=0;
	}
	else
	{
		ofexport[FXSLIDE].ob_height=((FXTXL-FXTX1+1)*ofexport[FXBAR].ob_height)/n;
		m=ofexport[FXBAR].ob_height-ofexport[FXSLIDE].ob_height;
		m=m*(long)list_off;
		m/=(long)(count_formats()-(FXTXL-FXTX1+1));
		ofexport[FXSLIDE].ob_y=(int)m;
	}
		
	/* Falls es den Eintrag noch gibt und der sichtbar ist, selektieren */
	if((n > sel_exfo) && (sel_exfo >= list_off) && (sel_exfo <= list_off+(FXTXL-FXTX1)))
		ofexport[FXTX1+sel_exfo-list_off].ob_state |= SELECTED;
}

void get_format(int a)
{
	EXP_FORM *el=get_format_by_index(a);
	
	if(el==NULL)
	{
		form_alert(1,"[3][Grape:|Es ist kein Format selektiert.][Abbruch]");
		return;
	}
	copy_list2set(a);
	redraw_formatbox();
}

void redraw_formatbox(void)
{
	int x,y,w,h;
	
	objc_offset(ofexport, FXFORMFRAME, &x, &y);
	w=ofexport[FXFORMFRAME].ob_width;
	h=ofexport[FXFORMFRAME].ob_height;
	w_objc_draw(&wfexport, 0, 8, x, y, w, h);
		
}

void set_format(int a)
{/* Schreibe aktuelle Formateinstellungen in Listeneintrag mit
		Index ix */
	EXP_FORM *el=get_format_by_index(a);
	char			alert[256];
		
	if(el==NULL)
	{
		form_alert(1,"[3][Grape:|Es ist kein Format selektiert.][Abbruch]");
		return;
	}
	if(el->base_id != 0)
	{
		strcpy(alert,"[2][Grape:|Soll das Format|");
		strcat(alert, el->name);
		strcat(alert,"|wirklich Åberschrieben werden?][Ja|Nein]");
		if(form_alert(1,alert)==2) return;
	}
	copy_set2list(a);
	init_fexport();
	w_objc_draw(&wfexport, FXTXFRAME, 8, sx, sy, sw, sh);

	if(waopt.open)
		check_aopt_export();
	if(wexport.open)
		check_ex_export();
	if(wfxsave.open)
	{
		put_base_to_pop();
		s_redraw(&wfxsave);
	}
}

int first_support(uchar formats)
{/* Gibt das erste unterstÅtzte Exportformat im Bitfeld formats
		als Index (ab 0) zurÅck */
	int a=0;
	
	while(!(formats & (1<<a))) ++a;
	return(a);
}

void copy_list2set(int a)
{/* öbernimmt die Settings aus Format a, falls dieses existiert
		Wenn nicht, oder nicht initialisiert, wird das erste FIO-Modul
		eingetragen */

	EXP_FORM	*el=first_expf;
	FIOMODBLK	*fb;
	int				n, depth, compress, opts[8], sr, fbx;
	OBJECT		*dpop;
	
	xrsrc_gaddr(0,DEPTHPOP, &dpop, xrsrc);
	
	while(a && el)
	{		--a; el=el->next;	}

	/* Formatname */
	if(el)
		strcpy(ofexport[FXNAME].ob_spec.tedinfo->te_ptext, el->name);
	else
		(ofexport[FXNAME].ob_spec.tedinfo->te_ptext)[0]=0;

	if(el && el->base_id)
	{/* Moduldaten eintragen */
		fb=find_fiomod_by_id(el->base_id);
		fbx=find_fioidx_by_id(el->base_id);
		depth=el->depth;
		compress=el->compress;
		for(n=0; n <8; ++n)
			opts[n]=el->opts[n];
	}
	else
	{/* Defaultdaten aus erstem Modul eintragen */
		fb=first_fiomod->fblk;
		fbx=0;
		depth=first_support(fb->ex_formats);
		compress=-1;
		if(fb->cmp_num)
			compress=0;
		for(n=0; n <8; ++n)
		{
			if(n < fb->opt_num)
				opts[n]=0;
			else
				opts[n]=-1;
		}
	}
	
	/* Basisformat-Name */
	strncpy(ofexport[FXBASE].ob_spec.free_string, fb->name, 20);
	ofexport[FXBASE].ob_spec.free_string[20]=0;
	set_ext_type(ofexport, FXBASE, fbx);
	/* Farbtiefe */
	strcpy(ofexport[FXBIT].ob_spec.free_string, &((dpop[depth+1].ob_spec.free_string)[2]));
	set_ext_type(ofexport, FXBIT, depth);
	/* Kompression */
	if(compress > -1)
	{
		strncpy(ofexport[FXCOMP].ob_spec.free_string, fb->cmp_names[compress],20);
		ofexport[FXCOMP].ob_spec.free_string[20]=0;
		ofexport[FXCOMP].ob_state &= (~DISABLED);
	}
	else
	{
		strcpy(ofexport[FXCOMP].ob_spec.free_string, "nicht verfÅgbar");
		ofexport[FXCOMP].ob_state |= DISABLED;
	}
	set_ext_type(ofexport, FXCOMP, compress);
	
	for(n=0; n < 8; ++n)
	{
		if(opts[n] > -1)
		{
			if(fb->options[n].possibs > 1)
				sr=FXOPOP;	/* Popup */
			else
				sr=FXOCHCK;	/* Checkbox */
			
			ofexport[FXO1+n].ob_flags=ofexport[sr].ob_flags;
			ofexport[FXO1+n].ob_state=ofexport[sr].ob_state;

			ofexport[FXO1+n].ob_flags &= (~HIDETREE);
			strncpy(ofexport[FXO1+n].ob_spec.free_string, 
				fb->options[n].names[(sr==FXOCHCK) ? 0 : opts[n]],(sr==FXOCHCK) ? 13:16);
			ofexport[FXO1+n].ob_spec.free_string[(sr==FXOCHCK) ? 13:16]=0;
			if((fb->options[n].possibs < 2) && (opts[n])) /* Checked */
				ofexport[FXO1+n].ob_state |= SELECTED;
		}
		else
		{
			ofexport[FXO1+n].ob_flags |= HIDETREE;
			ofexport[FXO1+n].ob_state &= (~SELECTED);
		}
		set_ext_type(ofexport, FXO1+n, opts[n]);
	}
	
	/* Y-Verteilung fÅr Optionen */
	ofexport[FXO1+1].ob_y=ofexport[FXO1+1+4].ob_y=
		ofexport[FXO1].ob_y+ofexport[FXO1].ob_height+ofexport[FXO1].ob_height/4;
	ofexport[FXO1+2].ob_y=ofexport[FXO1+2+4].ob_y=
		ofexport[FXO1+1].ob_y+ofexport[FXO1].ob_height+ofexport[FXO1].ob_height/4;
	ofexport[FXO1+3].ob_y=ofexport[FXO1+3+4].ob_y=
		ofexport[FXO1+2].ob_y+ofexport[FXO1].ob_height+ofexport[FXO1].ob_height/4;
}

void new_baseform(void)
{/* Liest den neuen Baseform-Typ aus FXBASE.ext_type und stellt die
		anderen Felder auf Defaults des neuen Typs */

	FIOMODBLK	*fb;
	int				i, n, depth, compress, opts[8], sr;
	OBJECT		*dpop;
	
	xrsrc_gaddr(0,DEPTHPOP, &dpop, xrsrc);
	
	i=ofexport[FXBASE].ob_type >> 8;
	fb=find_fiomod_by_id(find_fiomodid_by_savindex(i));

	depth=first_support(fb->ex_formats);
	compress=-1;
	if(fb->cmp_num)
		compress=0;
	for(n=0; n <8; ++n)
	{
		if(n < fb->opt_num)
			opts[n]=0;
		else
			opts[n]=-1;
	}
	
	/* Farbtiefe */
	strcpy(ofexport[FXBIT].ob_spec.free_string, &((dpop[depth+1].ob_spec.free_string)[2]));
	set_ext_type(ofexport, FXBIT, depth);
	/* Kompression */
	if(compress > -1)
	{
		strncpy(ofexport[FXCOMP].ob_spec.free_string, fb->cmp_names[compress],20);
		ofexport[FXCOMP].ob_spec.free_string[20]=0;
		ofexport[FXCOMP].ob_state &= (~DISABLED);
	}
	else
	{
		strcpy(ofexport[FXCOMP].ob_spec.free_string, "nicht verfÅgbar");
		ofexport[FXCOMP].ob_state |= DISABLED;
	}
	set_ext_type(ofexport, FXCOMP, compress);
	
	for(n=0; n < 8; ++n)
	{
		if(opts[n] > -1)
		{
			if(fb->options[n].possibs > 1)
				sr=FXOPOP;	/* Popup */
			else
				sr=FXOCHCK;	/* Checkbox */
			
			ofexport[FXO1+n].ob_flags=ofexport[sr].ob_flags;
			ofexport[FXO1+n].ob_state=ofexport[sr].ob_state;

			ofexport[FXO1+n].ob_flags &= (~HIDETREE);
			strncpy(ofexport[FXO1+n].ob_spec.free_string, 
				fb->options[n].names[(sr==FXOCHCK) ? 0 : opts[n]],(sr==FXOCHCK) ? 13:16);
			ofexport[FXO1+n].ob_spec.free_string[(sr==FXOCHCK) ? 13:16]=0;
			if((fb->options[n].possibs < 2) && (opts[n])) /* Checked */
				ofexport[FXO1+n].ob_state |= SELECTED;
		}
		else
		{
			ofexport[FXO1+n].ob_flags |= HIDETREE;
			ofexport[FXO1+n].ob_state &= (~SELECTED);
		}
		set_ext_type(ofexport, FXO1+n, opts[n]);
	}
	
	/* Y-Verteilung fÅr Optionen */
	ofexport[FXO1+1].ob_y=ofexport[FXO1+1+4].ob_y=
		ofexport[FXO1].ob_y+ofexport[FXO1].ob_height+ofexport[FXO1].ob_height/4;
	ofexport[FXO1+2].ob_y=ofexport[FXO1+2+4].ob_y=
		ofexport[FXO1+1].ob_y+ofexport[FXO1].ob_height+ofexport[FXO1].ob_height/4;
	ofexport[FXO1+3].ob_y=ofexport[FXO1+3+4].ob_y=
		ofexport[FXO1+2].ob_y+ofexport[FXO1].ob_height+ofexport[FXO1].ob_height/4;
}


void copy_set2list(int a)
{
	EXP_FORM *el=get_format_by_index(a);
	int n;
	
	if(el==NULL) return;
	
	strcpy(el->name, ofexport[FXNAME].ob_spec.tedinfo->te_ptext);

	/* Basisformat */
	el->base_id=find_fiomodid_by_savindex(ofexport[FXBASE].ob_type>>8);
	
	/* Farbtiefe */
	el->depth=ofexport[FXBIT].ob_type >> 8;
	
	/* Kompression */
	el->compress=(int)((char)(ofexport[FXCOMP].ob_type >> 8));
	
	/* Optionen */
	for(n=0; n < 8; ++n)
	{
		if(ofexport[FXO1+n].ob_flags & HIDETREE)
			el->opts[n]=-1;
		else if(ofexport[FXO1+n].ob_state & SHADOWED) /* Popup */
			el->opts[n]=(int)((char)(ofexport[FXO1+n].ob_type >> 8));
		else if(ofexport[FXO1+n].ob_state & SELECTED) /* Checkbox */
			el->opts[n]=1;
		else
			el->opts[n]=0;
	}
}

/* popups */
void base_pop(void)
{
	FIO_LIST	*fl=first_fiomod;
	int 			num=count_fio_saveables(), i;
	char 			*troot;
	OBJECT 		*plpop, *mpop;
	
	/* Vorlage fÅr ob[0] */	
	xrsrc_gaddr(0, MODEPOP, &mpop, xrsrc);

	/* Popup basteln */
	plpop=(OBJECT*)malloc((num+1)*sizeof(OBJECT)+num*24);
	if(plpop==NULL) return;
	troot=(char*)(&(plpop[num+1]));
	
	plpop[0].ob_next=-1;
	plpop[0].ob_head=1;
	plpop[0].ob_tail=num;
	plpop[0].ob_type=G_BOX;
	plpop[0].ob_flags=mpop[0].ob_flags;
	plpop[0].ob_state=mpop[0].ob_state;
	plpop[0].ob_spec=mpop[0].ob_spec;
	plpop[0].ob_x=plpop[0].ob_y=0;
	plpop[0].ob_width=ofexport[FXBASE].ob_width+2*ofexport[FXBASE].ob_width/20;
	plpop[0].ob_height=ofexport[FXBASE].ob_height*num;
	
	for(i=1; i <= num; ++i)
	{
		while((fl->fblk->ex_formats==0) || (fl->fblk->mod_fn->save_file==NULL))
			fl=fl->next;
		plpop[i].ob_next=i+1;
		plpop[i].ob_head=-1;
		plpop[i].ob_tail=-1;
		plpop[i].ob_type=G_STRING;
		plpop[i].ob_flags=mpop[1].ob_flags;
		plpop[i].ob_state=mpop[1].ob_state;
		plpop[i].ob_spec.free_string=troot;
		strcpy(troot, "  ");
		strncat(troot, fl->fblk->name, 20);
		troot[23]=0;
		troot+=24;
		plpop[i].ob_x=0;
		plpop[i].ob_y=mpop[1].ob_height*(i-1);
		plpop[i].ob_width=plpop[0].ob_width;
		plpop[i].ob_height=mpop[1].ob_height;
		fl=fl->next;
	}
	
	plpop[num].ob_next=0;
	plpop[num].ob_flags|=LASTOB;
	
	i=do_popup(&wfexport, FXBASE, plpop);
	free(plpop);
	if(i)
	{
		new_baseform();
		redraw_formatbox();
	}
}

void bit_pop(void)
{
	OBJECT *pop;
	FIOMODBLK	*fb;
	int				i;
		
	xrsrc_gaddr(0, DEPTHPOP, &pop, xrsrc);
	
	i=ofexport[FXBASE].ob_type >> 8;
	fb=find_fiomod_by_id(find_fiomodid_by_savindex(i));
	for(i=0; i < 7; ++i)
	{
		if(fb->ex_formats & (1<<i))
			pop[i+1].ob_state &= (~DISABLED);
		else
			pop[i+1].ob_state |= DISABLED;
	}
	do_popup(&wfexport, FXBIT, pop);
}

void comp_pop(void)
{
	int 			num, i;
	char 			*troot, **textsrc;
	OBJECT 		*plpop, *mpop;
	FIOMODBLK	*fb;
		
	
	i=ofexport[FXBASE].ob_type >> 8;
	fb=find_fiomod_by_id(find_fiomodid_by_savindex(i));
	num=fb->cmp_num;
	textsrc=fb->cmp_names;
	
	/* Vorlage fÅr ob[0] */	
	xrsrc_gaddr(0, MODEPOP, &mpop, xrsrc);

	/* Popup basteln */
	plpop=(OBJECT*)malloc((num+1)*sizeof(OBJECT)+num*24);
	if(plpop==NULL) return;
	troot=(char*)(&(plpop[num+1]));
	
	plpop[0].ob_next=-1;
	plpop[0].ob_head=1;
	plpop[0].ob_tail=num;
	plpop[0].ob_type=G_BOX;
	plpop[0].ob_flags=mpop[0].ob_flags;
	plpop[0].ob_state=mpop[0].ob_state;
	plpop[0].ob_spec=mpop[0].ob_spec;
	plpop[0].ob_x=plpop[0].ob_y=0;
	plpop[0].ob_width=ofexport[FXBASE].ob_width+2*ofexport[FXBASE].ob_width/20;
	plpop[0].ob_height=ofexport[FXBASE].ob_height*num;
	
	for(i=1; i <= num; ++i)
	{
		plpop[i].ob_next=i+1;
		plpop[i].ob_head=-1;
		plpop[i].ob_tail=-1;
		plpop[i].ob_type=G_STRING;
		plpop[i].ob_flags=mpop[1].ob_flags;
		plpop[i].ob_state=mpop[1].ob_state;
		plpop[i].ob_spec.free_string=troot;
		strcpy(troot, "  ");
		strncat(troot, textsrc[i-1], 20);
		troot[23]=0;
		troot+=24;
		plpop[i].ob_x=0;
		plpop[i].ob_y=mpop[1].ob_height*(i-1);
		plpop[i].ob_width=plpop[0].ob_width;
		plpop[i].ob_height=mpop[1].ob_height;
	}
	
	plpop[num].ob_next=0;
	plpop[num].ob_flags|=LASTOB;
	
	do_popup(&wfexport, FXCOMP, plpop);
	free(plpop);
}

void opt_pop(int opt)
{/* opt = Option 0-7 */

	int 			num, i;
	char 			*troot, **textsrc;
	OBJECT 		*plpop, *mpop;
	FIOMODBLK	*fb;
		
	i=ofexport[FXBASE].ob_type >> 8;
	fb=find_fiomod_by_id(find_fiomodid_by_savindex(i));
	num=(fb->options[opt]).possibs;
	if(num < 2) return;	/* Das ist kein Popup sondern eine Checkbox */
	textsrc=(fb->options[opt]).names;
	
	/* Vorlage fÅr ob[0] */	
	xrsrc_gaddr(0, MODEPOP, &mpop, xrsrc);

	/* Popup basteln */
	plpop=(OBJECT*)malloc((num+1)*sizeof(OBJECT)+num*18);
	if(plpop==NULL) return;
	troot=(char*)(&(plpop[num+1]));
	
	plpop[0].ob_next=-1;
	plpop[0].ob_head=1;
	plpop[0].ob_tail=num;
	plpop[0].ob_type=G_BOX;
	plpop[0].ob_flags=mpop[0].ob_flags;
	plpop[0].ob_state=mpop[0].ob_state;
	plpop[0].ob_spec=mpop[0].ob_spec;
	plpop[0].ob_x=plpop[0].ob_y=0;
	plpop[0].ob_width=ofexport[FXO1+opt].ob_width+2*ofexport[FXO1+opt].ob_width/20;
	plpop[0].ob_height=ofexport[FXO1+opt].ob_height*num;
	
	for(i=1; i <= num; ++i)
	{
		plpop[i].ob_next=i+1;
		plpop[i].ob_head=-1;
		plpop[i].ob_tail=-1;
		plpop[i].ob_type=G_STRING;
		plpop[i].ob_flags=mpop[1].ob_flags;
		plpop[i].ob_state=mpop[1].ob_state;
		plpop[i].ob_spec.free_string=troot;
		strcpy(troot, "  ");
		strncat(troot, textsrc[i-1], 16);
		troot[17]=0;
		troot+=18;
		plpop[i].ob_x=0;
		plpop[i].ob_y=mpop[1].ob_height*(i-1);
		plpop[i].ob_width=plpop[0].ob_width;
		plpop[i].ob_height=mpop[1].ob_height;
	}
	
	plpop[num].ob_next=0;
	plpop[num].ob_flags|=LASTOB;
	
	do_popup(&wfexport, FXO1+opt, plpop);
	free(plpop);
}

int do_popup(WINDOW *root, int parent, OBJECT *pop)
{/* ôffnet das Popup pop an x/y von root->dinfo->dtree[PRPOP]
		Vorauswahl (Check) und Y-Pos. werden an root-ext_type
		angepaût.
		Wenn Auswahl getroffen wird, wird Text aus pop ohne die
		ersten zwei Zeichen nach root kopiert und fÅr dieses ein
		Redraw ausgelîst.
		Gibt 1 zurÅck, wenn énderung vorgenommen wurde, sonst 0
 */
    
	int 	x,y,a,b;
	OBJECT *oroot=root->dinfo->tree;
	
	b=oroot[parent].ob_type >> 8;
		
	a=0;
	do
	{
		++a;
		pop[a].ob_state &= (~CHECKED);
	}while(!(pop[a].ob_flags & LASTOB));

	pop[b+1].ob_state |= CHECKED;
	objc_offset(oroot, parent, &x, &y);
	y-=b*pop[1].ob_height;

	if(y < sy) y=sy;
	if(y+pop[0].ob_height > sy+sh)
		y=sy+sh-pop[0].ob_height;
	if(x < sx) x=sx;
	if(x+pop[0].ob_width > sx+sw)
		x=sx+sw-pop[0].ob_width;

	a=form_popup(pop, x, y)-1;
	if((a > -1) && (a != b))
	{
		strcpy(oroot[parent].ob_spec.free_string,	&(pop[a+1].ob_spec.free_string[2]));
		w_objc_draw(root, parent, 8, sx, sy, sw, sh);		
		set_ext_type(oroot,parent,a);
		return(1);
	}
	return(0);
}


/* 
 FXSAVE
*/

int count_used(FIOMODBLK *fb)
{/* ZÑhlt die Formate, die das Basisformat aus fb benutzen */
	EXP_FORM *el=first_expf;
	int a=0;
	
	while(el)
	{
		if(el->base_id == fb->id)
			++a;
		el=el->next;
	}
	return(a);
}

void set_used_num(void)
{/* TrÑgt die Anzahl der von Poproot.extype genutzen Formate in
		Dialog ein */
		
	int ix, num;

	ix=ofxsave[FXSPOP].ob_type >> 8;
	num=count_used(find_fiomod_by_id(find_fiomodid_by_savindex(ix)));
	itoa(num, &(ofxsave[FXSNUM].ob_spec.tedinfo->te_ptext[1]), 10);
	strcat(ofxsave[FXSNUM].ob_spec.tedinfo->te_ptext, ")");
}

void fxsbase_pop(void)
{
	FIO_LIST	*fl=first_fiomod;
	int 			num=count_fio_saveables(), i;
	char 			*troot;
	OBJECT 		*plpop, *mpop;
	
	/* Vorlage fÅr ob[0] */	
	xrsrc_gaddr(0, MODEPOP, &mpop, xrsrc);

	/* Popup basteln */
	plpop=(OBJECT*)malloc((num+1)*sizeof(OBJECT)+num*24);
	if(plpop==NULL) return;
	troot=(char*)(&(plpop[num+1]));
	
	plpop[0].ob_next=-1;
	plpop[0].ob_head=1;
	plpop[0].ob_tail=num;
	plpop[0].ob_type=G_BOX;
	plpop[0].ob_flags=mpop[0].ob_flags;
	plpop[0].ob_state=mpop[0].ob_state;
	plpop[0].ob_spec=mpop[0].ob_spec;
	plpop[0].ob_x=plpop[0].ob_y=0;
	plpop[0].ob_width=ofxsave[FXSPOP].ob_width+2*ofxsave[FXSPOP].ob_width/20;
	plpop[0].ob_height=ofxsave[FXSPOP].ob_height*num;
	
	for(i=1; i <= num; ++i)
	{
		while((fl->fblk->ex_formats==0) || (fl->fblk->mod_fn->save_file==NULL))
			fl=fl->next;
		plpop[i].ob_next=i+1;
		plpop[i].ob_head=-1;
		plpop[i].ob_tail=-1;
		plpop[i].ob_type=G_STRING;
		plpop[i].ob_flags=mpop[1].ob_flags;
		plpop[i].ob_state=mpop[1].ob_state;
		plpop[i].ob_spec.free_string=troot;
		strcpy(troot, "  ");
		strncat(troot, fl->fblk->name, 20);
		troot[23]=0;
		troot+=24;
		plpop[i].ob_x=0;
		plpop[i].ob_y=mpop[1].ob_height*(i-1);
		plpop[i].ob_width=plpop[0].ob_width;
		plpop[i].ob_height=mpop[1].ob_height;
		if(count_used(fl->fblk)==0)
			plpop[i].ob_state |= DISABLED;
		fl=fl->next;
	}
	
	plpop[num].ob_next=0;
	plpop[num].ob_flags|=LASTOB;
	
	i=do_popup(&wfxsave, FXSPOP, plpop);
	free(plpop);
	if(i)
	{
		set_used_num();
		w_objc_draw(&wfxsave, FXSNUM, 8, sx, sy, sw, sh);
		if(ofxsave[FXS1].ob_state & SELECTED)
		{
			ofxsave[FXS1].ob_state &= (~SELECTED);
			ofxsave[FXS2].ob_state |= SELECTED;
			w_objc_draw(&wfxsave, FXS1, 8, sx, sy, sw, sh);
			w_objc_draw(&wfxsave, FXS2, 8, sx, sy, sw, sh);
		}
	}
}

void put_base_to_pop(void)
{/* Ext-Type des Poproots oder erstes mit vorhandenen Definitionen
		und Zahl eintragen */
		
	int ix;
	FIOMODBLK	*fb;
	FIO_LIST	*fl=first_fiomod;

	ix=ofxsave[FXSPOP].ob_type >> 8;
	fb=find_fiomod_by_id(find_fiomodid_by_savindex(ix));
	
	if(count_used(fb)==0)
	{
		ix=0;
		while(count_used(fl->fblk)==0)
		{	fl=fl->next; ++ix; }
		fb=fl->fblk;
	}
	
	set_ext_type(ofxsave, FXSPOP, ix);
	strncpy(ofxsave[FXSPOP].ob_spec.free_string, fb->name, 20);
	ofxsave[FXSPOP].ob_spec.free_string[20]=0;
	
	set_used_num();
}

void fxsave_window(void)
{
	EXP_FORM	*ep=first_expf;

	if(!wfxsave.open)
	{
		while(ep)
		{
			if(ep->base_id)
				break;
			ep=ep->next;
		}
		
		if(ep==NULL)
		{
			form_alert(1,"[3][Grape:|Es sind keine Exportformate|definiert.][Abbruch]");
			return;
		}
		/* Fenster initialisieren */
		put_base_to_pop();
		wfxsave.dinfo=&dfxsave;
		w_dial(&wfxsave, D_CENTER);
		wfxsave.name="[Grape] Formate sichern";
		w_set(&wfxsave, NAME);
		w_open(&wfxsave);
	}
	else
		w_top(&wfxsave);
}

int save_formats(void)
{/* Return: 1=gespeichert, sonst 0 */
	EXP_FORM	*ep=first_expf;
	char	path[256], name[64];
	long	fhl, sid, l;
	int		fh, num=0, cont;
	
	if(ofxsave[FXS1].ob_state & SELECTED)
		sid=0;
	else
		sid=find_fiomodid_by_savindex(ofxsave[FXSPOP].ob_type >> 8);
	while(ep)
	{
		if((ep->base_id) && ((sid==0)||(ep->base_id==sid)))
			++num;
		ep=ep->next;
	}
	name[0]=0;
	do
	{
		cont=1;
		strcpy(path, paths.module_path);
		l=strlen(path)-1;
		while(path[l] != '\\')--l;
		path[l+1]=0;
		strcat(path, "FORMATE\\*.DEF");
		if(f_input("Formate speichern...", path, name)==0) return(0);
		if(stricmp(&(path[strlen(path)-4]), ".DEF"))
			if(form_alert(1,"[2][Grape:|Formatdateien ohne die Endung \'DEF\'|werden beim Start von Grape nicht|automatisch erkannt.][OK|éndern]")==2)
				cont=0;
	}while(!cont);
	
	fhl=Fopen(path, FO_READ);
	Fclose((int)fhl);
	if(fhl >= 0)/* Datei gibts schon */
		if(form_alert(1,"[2][Grape:|Die Datei existiert bereits.|Soll sie Åberschrieben werden?][OK|Abbruch]") == 2)
			return(0);
			
	fhl=Fcreate(path, 0);
	if(fhl < 0)
	{
		form_alert(1,"[3][Grape:|Fehler beim Anlegen der Datei.][Abbruch]");
		return(0);
	}
	fh=(int)fhl;
	Fwrite(fh, 4, "GDEF");	/* 0:4 Magic */
	Fwrite(fh, 4, "0100");	/* 4:4 Version */
	Fwrite(fh, 2, &num);		/* 8:2 Anzahl EintrÑge */
													/* 10:anz*sizeof(EXP_FORM) EintrÑge */
	ep=first_expf;
	while(ep)
	{
		if((ep->base_id) && ((sid==0)||(ep->base_id==sid)))
			Fwrite(fh, sizeof(EXP_FORM), ep);
		ep=ep->next;
	}
	Fclose(fh);
	return(1);
}

void dial_fxsave(int ob)
{
	switch(ob)
	{
		case FXSPOP:
			fxsbase_pop();
		break;
		case FXSSAVE:
			if(save_formats()==0)
			{
				w_unsel(&wfxsave, ob);
				break;
			}
		case FXSABBRUCH:
			w_unsel(&wfxsave, ob);
			w_close(&wfxsave);
			w_kill(&wfxsave);
		break;
	}
}


/*
* Formate-Popup *
*/

void exp_form_popup(WINDOW *root, int ob)
{/* Achtung, ex_type des root-ob ist ID, NICHT INDEX! */
	EXP_FORM	*ep=first_expf;
	int 			num, i, ix=0, id;
	char 			*troot;
	OBJECT 		*plpop, *mpop;
	
	num=0;
	while(ep)
	{
		if(ep->base_id) ++num;
		ep=ep->next;
	}

	id=(root->dinfo->tree)[ob].ob_type >> 8;
	
	if(num==0)
	{
		Bell();
		return;
	}
	
	ep=first_expf;
	
	/* Vorlage fÅr ob[0] */	
	xrsrc_gaddr(0, MODEPOP, &mpop, xrsrc);

	/* Popup basteln */
	plpop=(OBJECT*)malloc((num+1)*sizeof(OBJECT)+num*28);
	if(plpop==NULL) return;
	troot=(char*)(&(plpop[num+1]));
	
	plpop[0].ob_next=-1;
	plpop[0].ob_head=1;
	plpop[0].ob_tail=num;
	plpop[0].ob_type=G_BOX;
	plpop[0].ob_flags=mpop[0].ob_flags;
	plpop[0].ob_state=mpop[0].ob_state;
	plpop[0].ob_spec=mpop[0].ob_spec;
	plpop[0].ob_x=plpop[0].ob_y=0;
	plpop[0].ob_width=(root->dinfo->tree)[ob].ob_width+2*(root->dinfo->tree)[ob].ob_width/20;
	plpop[0].ob_height=(root->dinfo->tree)[ob].ob_height*num;
	
	for(i=1; i <= num; ++i)
	{
		while(!(ep->base_id)) ep=ep->next;
		if(ep->f_id == id) ix=i-1;
		plpop[i].ob_next=i+1;
		plpop[i].ob_head=-1;
		plpop[i].ob_tail=-1;
		plpop[i].ob_type=G_STRING;
		plpop[i].ob_flags=mpop[1].ob_flags;
		plpop[i].ob_state=mpop[1].ob_state;
		plpop[i].ob_spec.free_string=troot;
		strcpy(troot, "  ");
		strcat(troot, ep->name);
		troot+=28;
		plpop[i].ob_x=0;
		plpop[i].ob_y=mpop[1].ob_height*(i-1);
		plpop[i].ob_width=plpop[0].ob_width;
		plpop[i].ob_height=mpop[1].ob_height;
		ep=ep->next;
	}
	
	plpop[num].ob_next=0;
	plpop[num].ob_flags|=LASTOB;
	
	/* Vorauswahl eintragen (von ID nach Index gewandelt) */
	set_ext_type(root->dinfo->tree, ob, ix);	
	i=do_popup(root, ob, plpop);
	if(i)
	{/* Neue Vorauswahl von Index nach ID wandeln */
		ix=(root->dinfo->tree)[ob].ob_type >> 8;
		id=-1;
		ep=first_expf;
		do
		{
			while(!(ep->base_id)) ep=ep->next;
			if(ix){--ix; ep=ep->next;}
			else id=ep->f_id;
		}while(id==-1);
		set_ext_type(root->dinfo->tree, ob, id);
	}
	free(plpop);
}
