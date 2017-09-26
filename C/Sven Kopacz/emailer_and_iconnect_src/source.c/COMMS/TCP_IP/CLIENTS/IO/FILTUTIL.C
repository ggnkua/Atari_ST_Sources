#include <ec_gem.h>
#include <atarierr.h>
#include "io.h"
#include "ioglobal.h"

void	fil_set_dial(void);
void	sel_fil_to_dial(void);

void draw_filframe(void)
{
	w_objc_draw(&wfilter, FILFRAME, 8, sx,sy,sw,sh);
	w_objc_draw(&wfilter, FILBAR, 8, sx,sy,sw,sh);
	w_objc_draw(&wfilter, FILTITEL, 8, sx,sy,sw,sh);
}

/* -------------------------------------- */
void ord_filter_move(long ix)
{
	long a=0;
	
	while(a < fld_inf.flds_c)
	{
		if(!strcmp(fil_inf.addr[ix].fname, fld_inf.flds[a].from))
			goto _fld_found;
		++a;
	}
	return;

_fld_found:
	ord_act_mail((int)a);
}

void ord_by_filter(void)
{/* Aktuelle Nachricht nach Filter ordnen */
	long a=0;
	char	*f, *c;

	if((fld_inf.flds==NULL)||(fil_inf.addr==NULL)||
		 (fld_inf.flds_c==0) || (fil_inf.addr_c==0)) return;

	graf_mouse(BUSYBEE, NULL);
	while(a < fil_inf.addr_c)
	{/* Online und Offline-Filter (2 und 3) auswerten */
		if((fil_inf.addr[a].action==2) || (fil_inf.addr[a].action==3))
		{
			switch(fil_inf.addr[a].field)
			{
				case 1:	f="From:"; break;
				case 2: f="To:"; break;
				case 3: f="Subject:"; break;
			}
			c=get_head_field(f);
			if(c)
			{
				f=stristr(c, fil_inf.addr[a].is);
				if(f)
				{	
					ord_filter_move(a); 
					graf_mouse(ARROW, NULL);
					return;
				}
			}
		}
		++a;
	}
	Bell();
	graf_mouse(ARROW, NULL);
}

/* -------------------------------------- */

void reload_filter_folders(void)
{
	long a, b;
	
	if((fld_inf.flds==NULL)||(fil_inf.addr==NULL)||
		 (fld_inf.flds_c==0) || (fil_inf.addr_c==0)) return;
	a=0;
	while(a < fil_inf.addr_c)
	{
		if((fil_inf.addr[a].action & 2)==2)
		{
			for(b=0; b < fld_inf.flds_c; ++b)
			{
				if(!strcmp(fil_inf.addr[a].fname, fld_inf.flds[b].from))
				{
					fil_inf.addr[a].subact=b;
					goto _fil_found;
				}
			}
			/* Nix gefunden, Name aus Index nehmen oder leer setzen */
			if(fil_inf.addr[a].subact >= fld_inf.flds_c)
			{
				fil_inf.addr[a].subact=0;
				strcpy(fil_inf.addr[a].fname, "<Kein Ordner>");
			}
			else
			{
				strcpy(fil_inf.addr[a].fname, fld_inf.flds[fil_inf.addr[a].subact].from);
			}
		}
_fil_found:
		++a;
	}
	
	if(!wfilter.open) return;
	fil_set_dial();
	draw_filframe();
}

/* -------------------------------------- */

int load_filters(void)
{/* -1=Kein Speicher, 0=Keine Filter, 1=ok */
	char path[256];
	long	fhl;
	int		fh;
	
	if(fil_inf.addr) free(fil_inf.addr);
	fil_inf.addr=NULL; fil_inf.addr_c=0; fil_inf.changes=0;
	strcpy(path, db_path);
	strcat(path, "\\FILTERS.CFG");
	fhl=Fopen(path, FO_READ);
	if(fhl < 0)
	{
		if(fhl != EFILNF) gemdos_alert(gettext(FILTEROPEN_ERR), fhl);
		return(0);
	}
	fh=(int)fhl;
	fhl=Fseek(0, fh, 2);
	Fseek(0,fh,0);
	fil_inf.addr=malloc(fhl+1);
	if(fil_inf.addr==NULL)
	{
		form_alert(1, gettext(NO_FILMEM));
		Fclose(fh);
		return(-1);
	}
	Fread(fh, fhl, fil_inf.addr);
	Fclose(fh);
	fil_inf.addr_c=fhl/sizeof(S_FILTER);
	return(1);
}

/* -------------------------------------- */

void save_filters(void)
{
	char path[256];
	long	fhl;
	int		fh;
	
	strcpy(path, db_path);
	strcat(path, "\\FILTERS.CFG");
	if((fil_inf.addr==NULL) || (fil_inf.addr_c==0))
	{
		Fdelete(path);
		return;
	}
	fhl=Fcreate(path, 0);
	if(fhl < 0)
	{
		gemdos_alert(gettext(FILTERMAKE_ERR), fhl);
		return;
	}
	fh=(int)fhl;
	Fwrite(fh, fil_inf.addr_c*sizeof(S_FILTER), fil_inf.addr);
	Fclose(fh);
	fil_inf.changes=0;
}

/* -------------------------------------- */

int cmp_filters(S_FILTER *s1, S_FILTER *s2)
{
	if(s1->field != s2->field) return(0);
	if(strcmp(s1->is, s2->is)) return(0);
	if(s1->action != s2->action) return(0);
	if(s1->subact != s2->subact) return(0);
	if(strcmp(s1->fname, s2->fname)) return(0);
	return(1);
}

int add_filter(void)
{
	S_FILTER *n;
	long	 l;

	/* Speicher fr alle Filter+1 */	
	n=malloc((fil_inf.addr_c+1)*sizeof(S_FILTER));
	if(n==NULL) {form_alert(1, gettext(NOMEM)); return(0);}

	/* Letzter Filter=Neuer Filter */
	l=fil_inf.addr_c;
	n[l].field=ext_type(ofilter, FILPOP1);
	strcpy(n[l].is, ofilter[FILTEXT].ob_spec.tedinfo->te_ptext);
	n[l].action=ext_type(ofilter, FILPOP2);
	if(n[l].action==2)
		if(!(ofilter[ONLINE_FIL].ob_state & SELECTED)) n[l].action=3;
	n[l].subact=fil_inf.pop3ex;
	if((n[l].action & 2)==2)	/* Einordnen */
	{
		--n[l].subact;
		if((fld_inf.flds) && (fld_inf.flds_c > n[l].subact))
			strcpy(n[l].fname, fld_inf.flds[n[l].subact].from);
		else
			strcpy(n[l].fname, "<Kein Ordner>");
	}

	/* Gibt es diesen Filter schon? */
	l=0;
	while(l < fil_inf.addr_c)
	{
		if(cmp_filters(&(fil_inf.addr[l++]),&(n[fil_inf.addr_c])))
		{
			form_alert(1,gettext(DBL_FILTER));
			free(n);
			return(0);
		}
	}

	/* Alte Filter bernehmen */
	fil_inf.changes=1;

	l=0;
	if(fil_inf.addr)
	{
		while(l < fil_inf.addr_c)
		{	n[l]=fil_inf.addr[l]; ++l;}
		free(fil_inf.addr);
	}
	fil_inf.addr=n;
	++fil_inf.addr_c;

	return(1);
}

/* -------------------------------------- */

void rename_filter(void)
{
	S_FILTER *n=fil_inf.addr, temp_sf;
	long	l;

	if((fil_inf.addr==NULL)||(fil_inf.addr_c==0)) return;
	
	fil_inf.changes=1;

	temp_sf.field=ext_type(ofilter, FILPOP1);
	strcpy(temp_sf.is, ofilter[FILTEXT].ob_spec.tedinfo->te_ptext);
	temp_sf.action=ext_type(ofilter, FILPOP2);
	if((temp_sf.action==2) && (!(ofilter[ONLINE_FIL].ob_state & SELECTED)))
		temp_sf.action=3;
	temp_sf.subact=fil_inf.pop3ex;
	if((temp_sf.action & 2)==2)	/* Einordnen */
	{
		--temp_sf.subact;
		if((fld_inf.flds) && (fld_inf.flds_c > temp_sf.subact))
			strcpy(temp_sf.fname, fld_inf.flds[temp_sf.subact].from);
		else
			strcpy(temp_sf.fname, "<Kein Ordner>");
	}
	
	/* Filter schon vorhanden? */
	l=0;
	while(l < fil_inf.addr_c)
	{
		if(cmp_filters(&(fil_inf.addr[l++]), &temp_sf))
		{
			form_alert(1,gettext(DBL_FILTER));
			return;
		}
	}
	
	l=fil_inf.sel;
	n[l]=temp_sf;
}

/* -------------------------------------- */

void delete_filter(void)
{
	long	l=fil_inf.sel;
	
	if((fil_inf.addr==NULL)||(fil_inf.addr_c==0)) return;
	
	fil_inf.changes=1;
	
	--fil_inf.addr_c;
	if(fil_inf.addr_c==0)
	{
		free(fil_inf.addr);
		fil_inf.addr=NULL;
		return;
	}
	while(l < fil_inf.addr_c)
	{
		fil_inf.addr[l]=fil_inf.addr[l+1];
		++l;
	}
}

/* -------------------------------------- */

void fil_init_inf(void)
{
	fil_inf.offset=fil_inf.sel=0;
	if(fil_inf.addr==NULL) load_filters();
}

/* -------------------------------------- */

void fil_set_dial(void)
{
	long	a;
	long	t, l, xo;
	
	/* Slider setzen */

	/* Ggf. Listenoffset korrigieren */
	l=(FILLAST-FIL1)/(FIL2-FIL1)+1;	/* Sichtbare Zeilen */
	if(fil_inf.offset+l > fil_inf.addr_c)	fil_inf.offset=fil_inf.addr_c-l;
	if(fil_inf.offset < 0) 	fil_inf.offset=0;
	
	a=fil_inf.offset;
	
	if(fil_inf.addr_c <= l)
	{
		ofilter[FILSLIDE].ob_y=0;
		ofilter[FILSLIDE].ob_height=ofilter[FILBAR].ob_height;
		goto _fil_text;
	}
	
	/* Slidergr”že */
	t=(long)fil_inf.addr_c*(long)(ofilter[FIL1].ob_height);	/* Gesamte Liste in Pixeln */
	ofilter[FILSLIDE].ob_height=(int)( ((long)ofilter[FILBAR].ob_height*(long)(l*(long)ofilter[FIL1].ob_height))/t);
	if(ofilter[FILSLIDE].ob_height < ofilter[FILSLIDE].ob_width)
		ofilter[FILSLIDE].ob_height=ofilter[FILSLIDE].ob_width;
	
	/* Sliderpos. */
	ofilter[FILSLIDE].ob_y=(int)(
				((long)(ofilter[FILBAR].ob_height-ofilter[FILSLIDE].ob_height)*
				 (long)(fil_inf.offset)) 
				 / 
				 (fil_inf.addr_c-l));

_fil_text:
	a=fil_inf.offset;
	while((a < fil_inf.addr_c) && (a-fil_inf.offset <= (FILLAST-FIL1)/(FIL2-FIL1)))
	{
		xo=(a-fil_inf.offset)*(FIL2-FIL1);
		/* Erstes Icon */
		ofilter[IFIL1+xo].ob_flags &= (~HIDETREE);
		switch(fil_inf.addr[a].field)
		{
			case 1:	/* Absender */
				ofilter[IFIL1+xo].ob_spec.iconblk=ovorl[IC_ABSENDER].ob_spec.iconblk;
			break;
			case 2: /* Empf„nger */
				ofilter[IFIL1+xo].ob_spec.iconblk=ovorl[IC_EMPFAENGER].ob_spec.iconblk;
			break;
			case 3: /* Betreff */
				ofilter[IFIL1+xo].ob_spec.iconblk=ovorl[IC_BETREFF].ob_spec.iconblk;
			break;
		}
		/* Zwischenstring */
		ofilter[ZT1+xo].ob_spec.tedinfo->te_ptext[0]=':';
		/* Text */
		strcpy(ofilter[FIL1+xo].ob_spec.tedinfo->te_ptext, fil_inf.addr[a].is);
		/* Zwischenstring */
		ofilter[ZT2+xo].ob_spec.tedinfo->te_ptext[0]='\x03';
		/* Zweites Icon und hinterer Text */
		ofilter[IIFIL1+xo].ob_flags &= (~HIDETREE);
		switch(fil_inf.addr[a].action)
		{
			case 1:	/* Nicht abholen */
				ofilter[IIFIL1+xo].ob_spec.iconblk=ovorl[IC_NGET].ob_spec.iconblk;
				strcpy(ofilter[TFIL1+xo].ob_spec.tedinfo->te_ptext, ovorl[IT_SA1+fil_inf.addr[a].subact-1].ob_spec.free_string);
			break;
			case 2: /* Einordnen online */
				ofilter[IIFIL1+xo].ob_spec.iconblk=ovorl[IC_ONORD].ob_spec.iconblk;
				strncpy(ofilter[TFIL1+xo].ob_spec.tedinfo->te_ptext, fil_inf.addr[a].fname, 14);
				ofilter[TFIL1+xo].ob_spec.tedinfo->te_ptext[14]=0;
			break;
			case 3: /* Einordnen offline */
				ofilter[IIFIL1+xo].ob_spec.iconblk=ovorl[IC_OFFORD].ob_spec.iconblk;
				strncpy(ofilter[TFIL1+xo].ob_spec.tedinfo->te_ptext, fil_inf.addr[a].fname, 14);
				ofilter[TFIL1+xo].ob_spec.tedinfo->te_ptext[14]=0;
			break;
		}
		if(a==fil_inf.sel)
		{
			ofilter[FIL1+xo].ob_state |= SELECTED;
			ofilter[TFIL1+xo].ob_state |= SELECTED;
		}
		else
		{
			ofilter[FIL1+xo].ob_state &= (~SELECTED);
			ofilter[TFIL1+xo].ob_state &= (~SELECTED);
		}
		++a;
	}
	while(a-fil_inf.offset <= (FILLAST-FIL1)/(FIL2-FIL1))
	{
		xo=(a-fil_inf.offset)*(FIL2-FIL1);
		/* Erstes Icon */
		ofilter[IFIL1+xo].ob_flags |= HIDETREE;
		/* Zwischenstring */
		ofilter[ZT1+xo].ob_spec.tedinfo->te_ptext[0]=0;
		/* Text */
		ofilter[FIL1+xo].ob_spec.tedinfo->te_ptext[0]=0;
		ofilter[FIL1+xo].ob_state &= (~SELECTED);
		/* Zwischenstring */
		ofilter[ZT2+xo].ob_spec.tedinfo->te_ptext[0]=0;
		/* Zweites Icon und hinterer Text */
		ofilter[IIFIL1+xo].ob_flags |= HIDETREE;
		ofilter[TFIL1+xo].ob_spec.tedinfo->te_ptext[0]=0;
		ofilter[TFIL1+xo].ob_state &= (~SELECTED);
		++a;
	}
	
	/* Buttons aktiv/inaktiv */
	if((!(ofilter[FILRENAME].ob_state & DISABLED)) && ((fil_inf.addr==NULL)||(fil_inf.addr_c==0)))
	{
		ofilter[FILRENAME].ob_state |= DISABLED;
		ofilter[IFILRENAME].ob_state |= DISABLED;
		ofilter[FILDEL].ob_state |= DISABLED;
		ofilter[IFILDEL].ob_state |= DISABLED;
		w_objc_draw(&wfilter, FILRENAME, 8, sx,sy,sw,sh);
		w_objc_draw(&wfilter, FILDEL, 8, sx,sy,sw,sh);
	}
	else if((ofilter[FILRENAME].ob_state & DISABLED) && (fil_inf.addr!=NULL) && (fil_inf.addr_c > 0))
	{
		ofilter[FILRENAME].ob_state &= (~DISABLED);
		ofilter[IFILRENAME].ob_state &= (~DISABLED);
		ofilter[FILDEL].ob_state &= (~DISABLED);
		ofilter[IFILDEL].ob_state &= (~DISABLED);
		w_objc_draw(&wfilter, FILRENAME, 8, sx,sy,sw,sh);
		w_objc_draw(&wfilter, FILDEL, 8, sx,sy,sw,sh);
	}
}

/* -------------------------------------- */

void filtclosed(WINDOW *win)
{
	if(fil_inf.changes)
		save_filters();
	w_close(win);
	w_kill(win);
}

/* -------------------------------------- */

void	filter_dial(void)
{
	OBJECT *tree;

	if(wfilter.open)
	{
		w_top(&wfilter);
		return;
	}

	fil_init_inf();
	fil_set_dial();
	if(fil_inf.addr)
		sel_fil_to_dial();
	else
	{
		ofilter[FILTEXT].ob_spec.tedinfo->te_ptext[0]=0;
		ofilter[IFILPOP1].ob_spec.iconblk=ovorl[IC_ABSENDER].ob_spec.iconblk;
		strcpy(ofilter[FILPOP1].ob_spec.free_string, ovorl[IT_P11].ob_spec.free_string);
		set_ext_type(ofilter, FILPOP1, 1);
		ofilter[IFILPOP2].ob_spec.iconblk=ovorl[IC_NGET].ob_spec.iconblk;
		strcpy(ofilter[FILPOP2].ob_spec.free_string, ovorl[IT_P21].ob_spec.free_string);
		set_ext_type(ofilter, FILPOP2, 1);
		rsrc_gaddr(0, FIL3POPUP, &tree);
		strcpy(ofilter[FILPOP3].ob_spec.free_string, &(tree[1].ob_spec.free_string[2]));
		fil_inf.pop3ex=1;
	}
	wfilter.dinfo=&dfilter;
	w_kdial(&wfilter, D_CENTER, MOVE|NAME|BACKDROP|CLOSE);
	wfilter.closed=filtclosed;
	/*wfilter.name="";
	w_set(&wfilter, NAME);*/
	dfilter.dedit=FILTEXT;
	w_open(&wfilter);
}

/* -------------------------------------- */

void slide_filter(void)
{
	int		mb, my, oy=-1, miny, maxy, offy, dum;
	long	l, off;

	maxy=ofilter[FILBAR].ob_height-ofilter[FILSLIDE].ob_height;
	if(maxy==0) return;
	
	wind_update(BEG_MCTRL);
	graf_mouse(FLAT_HAND, NULL);

	objc_offset(ofilter, FILSLIDE, &dum, &offy);
	graf_mkstate(&dum, &my, &dum, &dum);
	offy=my-offy;
	objc_offset(ofilter, FILBAR, &dum, &miny);
	
	do
	{
		graf_mkstate(&dum, &my, &mb, &dum);
		my-=miny+offy;
		if(my < 0) my=0;
		if(my > maxy) my=maxy;
		if(my==oy) continue;	
		
		/* Neuen Offset ausrechnen */
		l=(FILLAST-FIL1)/(FIL2-FIL1)+1;		/* Sichtbare Zeilen */
		off=(int)(((long)my*(fil_inf.addr_c-l))/(long)maxy);
		if(off!=fil_inf.offset)
		{
			fil_inf.offset=off;
			fil_set_dial();
			draw_filframe();
		}	
	}while(mb & 3);
	
	graf_mouse(ARROW, NULL);
	wind_update(END_MCTRL);
}

/* -------------------------------------- */

void popfil1(void)
{
	OBJECT *tree;
	int			mx, my, dum;
	
	rsrc_gaddr(0, FIL1POPUP, &tree);
	objc_offset(ofilter, FILPOP1, &mx, &my);
	dum=form_popup(tree, mx, my);
	if(dum < 1) return;
	dum/=2;
	if(dum+1 == ext_type(ofilter, FIL1POPUP)) return;
	ofilter[IFILPOP1].ob_spec.iconblk=ovorl[IC_ABSENDER+dum].ob_spec.iconblk;
	strcpy(ofilter[FILPOP1].ob_spec.free_string, ovorl[IT_P11+dum].ob_spec.free_string);
	set_ext_type(ofilter, FILPOP1, dum+1);
	w_objc_draw(&wfilter, FILPOP1, 8, sx,sy,sw,sh);
}

/* -------------------------------------- */

void popfil2(void)
{
	OBJECT *tree;
	int			mx, my, dum;
	
	rsrc_gaddr(0, FIL2POPUP, &tree);
	objc_offset(ofilter, FILPOP2, &mx, &my);
	dum=form_popup(tree, mx, my);
	if(dum < 1) return;
	dum/=2;
	if(dum+1 == ext_type(ofilter, FIL2POPUP)) return;
	if(dum==1)
		ofilter[IFILPOP2].ob_spec.iconblk=ovorl[IC_OFFORD].ob_spec.iconblk;
	else /* 0 */
		ofilter[IFILPOP2].ob_spec.iconblk=ovorl[IC_NGET].ob_spec.iconblk;
	strcpy(ofilter[FILPOP2].ob_spec.free_string, ovorl[IT_P21+dum].ob_spec.free_string);
	set_ext_type(ofilter, FILPOP2, dum+1);
	if(dum==1) /* Ordner-Popup vorbereiten */
	{
		if(fld_inf.flds)
		{
			strncpy(ofilter[FILPOP3].ob_spec.free_string, fld_inf.flds[0].from, 14);
			ofilter[FILPOP3].ob_spec.free_string[14]=0;
		}
		else			
			strcpy(ofilter[FILPOP3].ob_spec.free_string, "<Kein Ordner>");
		ofilter[ONLINE_FIL].ob_state &= (~DISABLED);
	}
	else	/* Server l”schen-Popup */
	{
		rsrc_gaddr(0, FIL3POPUP, &tree);
		strcpy(ofilter[FILPOP3].ob_spec.free_string, &(tree[1].ob_spec.free_string[2]));
		ofilter[ONLINE_FIL].ob_state |= DISABLED;
	}
	fil_inf.pop3ex=1;
	w_objc_draw(&wfilter, FILPOP2, 8, sx,sy,sw,sh);
	w_objc_draw(&wfilter, FILPOP3, 8, sx,sy,sw,sh);
	w_objc_draw(&wfilter, ONLINE_FIL, 8, sx,sy,sw,sh);
}

/* -------------------------------------- */

void popfil3(void)
{
	OBJECT *tree;
	int			mx, my, dum;
	
	if(ext_type(ofilter, FILPOP2)==1)
	{
		rsrc_gaddr(0, FIL3POPUP, &tree);
		objc_offset(ofilter, FILPOP3, &mx, &my);
		dum=form_popup(tree, mx, my);
		if(dum < 1) return;
		if(dum==fil_inf.pop3ex) return;
		strcpy(ofilter[FILPOP3].ob_spec.free_string, &(tree[dum].ob_spec.free_string[2]));
		fil_inf.pop3ex=dum;
	}
	else if(fld_inf.flds)
	{
		dum=fld_popup(fld_inf.flds, fld_inf.flds_c);
		if(dum < 1) return;
		strncpy(ofilter[FILPOP3].ob_spec.free_string, fld_inf.flds[dum-1].from, 14);
		ofilter[FILPOP3].ob_spec.free_string[14]=0;
		fil_inf.pop3ex=dum;
	}
	else Bell();
	w_objc_draw(&wfilter, FILPOP3, 8, sx,sy,sw,sh);
}

/* -------------------------------------- */

void sel_fil_to_dial(void)
{
	OBJECT *tree;
	
	if((fil_inf.addr==NULL) || (fil_inf.sel >= fil_inf.addr_c)) return;
	
	/* Wichtig: Der Ordner-Index in subact z„hlt zwar ab Null,
			im ext_type des Popups aber ab 1. Erst bei Rename
			und new wird eins abgezogen! */
	ofilter[IFILPOP1].ob_spec.iconblk=ovorl[IC_ABSENDER+fil_inf.addr[fil_inf.sel].field-1].ob_spec.iconblk;
	strcpy(ofilter[FILPOP1].ob_spec.free_string, ovorl[IT_P11+fil_inf.addr[fil_inf.sel].field-1].ob_spec.free_string);
	set_ext_type(ofilter, FILPOP1, fil_inf.addr[fil_inf.sel].field);
	strcpy(ofilter[FILTEXT].ob_spec.tedinfo->te_ptext, fil_inf.addr[fil_inf.sel].is);
	if(fil_inf.addr[fil_inf.sel].action==1)
	{
		ofilter[IFILPOP2].ob_spec.iconblk=ovorl[IC_NGET].ob_spec.iconblk;
		strcpy(ofilter[FILPOP2].ob_spec.free_string, ovorl[IT_P21].ob_spec.free_string);
		set_ext_type(ofilter, FILPOP2, 1);

		rsrc_gaddr(0, FIL3POPUP, &tree);
		strcpy(ofilter[FILPOP3].ob_spec.free_string, &(tree[fil_inf.addr[fil_inf.sel].subact].ob_spec.free_string[2]));
		fil_inf.pop3ex=fil_inf.addr[fil_inf.sel].subact;
		ofilter[ONLINE_FIL].ob_state |= DISABLED;
	}
	else
	{
		ofilter[IFILPOP2].ob_spec.iconblk=ovorl[IC_OFFORD].ob_spec.iconblk;
		strcpy(ofilter[FILPOP2].ob_spec.free_string, ovorl[IT_P21+1].ob_spec.free_string);
		set_ext_type(ofilter, FILPOP2, 2);

		if(fld_inf.flds && (fld_inf.flds_c > fil_inf.addr[fil_inf.sel].subact))
		{
			strncpy(ofilter[FILPOP3].ob_spec.free_string, fld_inf.flds[fil_inf.addr[fil_inf.sel].subact].from, 14);
			ofilter[FILPOP3].ob_spec.free_string[14]=0;
			fil_inf.pop3ex=fil_inf.addr[fil_inf.sel].subact+1;
		}
		else
		{
			strcpy(ofilter[FILPOP3].ob_spec.free_string, "<Kein Ordner>");
			fil_inf.pop3ex=1;
		}
		ofilter[ONLINE_FIL].ob_state &= (~DISABLED);
		if(fil_inf.addr[fil_inf.sel].action==2)
			ofilter[ONLINE_FIL].ob_state |= SELECTED;
		else
			ofilter[ONLINE_FIL].ob_state &= (~SELECTED);
	}
	w_objc_draw(&wfilter, FILEDFRAME, 8, sx,sy,sw,sh);
}

/* -------------------------------------- */

void dial_filter(int ob)
{
	long	a;
	int		my,oy,dum;
	
	switch(ob)
	{
		case FILNEU: case IFILNEU:
			if(!w_wo_ibut_sel(&wfilter, ob)) break;
			if(strlen(ofilter[FILTEXT].ob_spec.tedinfo->te_ptext)==0)
			{
				form_alert(1,gettext(FIL_NOTEXT));
				w_wo_ibut_unsel(&wfilter, ob);
				break;
			}
			if(add_filter()==0)
			{
				w_wo_ibut_unsel(&wfilter, ob);
				break;
			}
			fil_inf.sel=fil_inf.addr_c-1;
			fil_set_dial();
			draw_filframe();
			w_wo_ibut_unsel(&wfilter, ob);
		break;
		case FILRENAME: case IFILRENAME:
			if(!w_wo_ibut_sel(&wfilter, ob)) break;
			if(strlen(ofilter[FILTEXT].ob_spec.tedinfo->te_ptext)==0)
			{
				form_alert(1,gettext(FIL_NOTEXT));
				w_wo_ibut_unsel(&wfilter, ob);
				break;
			}
			rename_filter();
			fil_set_dial();
			draw_filframe();
			w_wo_ibut_unsel(&wfilter, ob);
		break;
		case FILDEL: case IFILDEL:
			if(!w_wo_ibut_sel(&wfilter, ob)) break;
			delete_filter();
			if(fil_inf.sel >= fil_inf.addr_c)
			{	--fil_inf.sel; if(fil_inf.sel < 0) fil_inf.sel=0;}
			sel_fil_to_dial();
			fil_set_dial();
			draw_filframe();
			w_objc_draw(&wfilter, FILEDFRAME, 8, sx,sy,sw,sh);			
			w_wo_ibut_unsel(&wfilter, ob);
		break;
		
		case FILPOP1: case IFILPOP1:
			popfil1();
		break;
		case FILPOP2: case IFILPOP2:
			popfil2();
		break;
		case FILPOP3:
			popfil3();
		break;
		
		case FILUP:
			a=fil_inf.offset-1;
		goto _new_fil_offset;
		case FILDOWN:
			a=fil_inf.offset+1;
		goto _new_fil_offset;
		case FILSLIDE:
			slide_filter();
		break;
		case FILBAR:
			graf_mkstate(&dum, &my, &dum, &dum);
			objc_offset(ofilter, FILSLIDE, &dum, &oy);
			if(my < oy)
				a=fil_inf.offset-((FILLAST-FIL1)/(FIL2-FIL1)+1);
			else
				a=fil_inf.offset+((FILLAST-FIL1)/(FIL2-FIL1)+1);
		goto _new_fil_offset;
	}
	
	if((ob >= IFIL1)&&(ob <= TFILLAST))
	{
		a=ob-IFIL1; a/=(FIL2-FIL1); a+=fil_inf.offset;
		if(a >= fil_inf.addr_c) a=fil_inf.addr_c-1;
		if(a==fil_inf.sel) return;
		fil_inf.sel=a;
		fil_set_dial();
		sel_fil_to_dial();
		draw_filframe();
		w_objc_draw(&wfilter, FILEDFRAME, 8, sx,sy,sw,sh);
	}
	return;

_new_fil_offset:
	if(a+(FILLAST-FIL1)/(FIL2-FIL1)+1 > fil_inf.addr_c)	a=fil_inf.addr_c-((FILLAST-FIL1)/(FIL2-FIL1)+1);
	if(a < 0) a=0;
	if(a==fil_inf.offset) return;
	fil_inf.offset=a;
	fil_set_dial();
	draw_filframe();
}