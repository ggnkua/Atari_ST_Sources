#include <ec_gem.h>
#include "io.h"
#include "ioglobal.h"
#include "indexer.h"

/* Die Ordner-Datei befindet sich unter data_path/ORD/ORD.IDX
   und enthÑlt fÅr jeden Ordner einen Descriptor vom Typ
   FLD (FileListDescriptor).
   Von diesem sind die Elemente
	 fspec.fname=Ordnername (Nummer)
	 ftype=FLD_FLD;
	 from=Klartextname
	 fspec.flags='Ig' -> Beim AufrÑumen ignorieren 
*/

int fld_check_ignore(long fld_nr)
{/* PrÅft, ob fÅr Ordner mit Filename "nr" das "Beim
    AufrÑumen ignorieren" Flag gesetzt ist.
    Return: 0=Nicht gesetzt, 1=gesetzt */
  long c=0;
  FLD	*fl=fld_inf.flds;
  
  if(fl==NULL) return(0);
  while(c < fld_inf.flds_c)
  {
		if(atol(fld_inf.flds[c].fspec.fname)==fld_nr) 
			if(fld_inf.flds[c].fspec.finfo.flags == 'Ig')
				return(1);
		++c;
	}
	return(0);
}

void draw_fldframe(void)
{
	w_objc_draw(&wfolder, FLDFRAME, 8, sx,sy,sw,sh);
	w_objc_draw(&wfolder, FLDBAR, 8, sx,sy,sw,sh);
	w_objc_draw(&wfolder, ORDTITEL, 8, sx,sy,sw,sh);
}

/* -------------------------------------- */

int Check_folders(void)
{/* Konsistenz-Check, ob Ordner-Nummern doppelt vergeben sind
    Kann in alter Version passiert sein, wenn im DB-Modus ein neuer
    Ordner angelegt wurde, vorher aber im ORD-Ordner ein paar Ordner
    gelîscht wurden. Es wurde dann immer die hîchste freie Nummer
    vergeben, unabhÑngig davon, ob die schon anderweitig vergeben war */
   
  long ix1=0, ix2, ix3, fhl;
  int	 problems=0, fh;
	char	path[256];
  
  while(ix1 < fld_inf.flds_c)
  {
 _next_after_correction:
  	ix2=0; /* PrÅfen, ob unter den vorhergehenden Ordnern ein gleichnamiger existiert */
  	while(ix2 < ix1)
  	{
  		if(!strcmp(fld_inf.flds[ix2].fspec.fname, fld_inf.flds[ix1].fspec.fname))
  		{
  			problems=1;
  			/* Overwrite the current ix1 entry with the following entries */
  			ix3=ix1;
  			while(ix3 < fld_inf.flds_c-1)
  			{
  				fld_inf.flds[ix3]=fld_inf.flds[ix3+1];
  				++ix3;
  			}
  			/* Now we have one folder less */
  			--fld_inf.flds_c;
  			/* Don't increase ix1, because it was overwritten by a new one which will be checked next */
  			if(ix1 < fld_inf.flds_c)
	  			goto _next_after_correction;
	  		goto _checks_done;
  		}
  		++ix2;
  	}
  	++ix1;
  }
  
 _checks_done:
 	if(problems)
	{	/* Neue Index-Datei schreiben */
		strcpy(path, db_path);
		strcat(path, "\\ORD\\ORD.IDX");
		fhl=Fcreate(path, 0);
		if(fhl < 0)
		{
			gemdos_alert("Kann Ordner-Index nicht aktualisieren.", fhl);
			return(0);
		}
		fh=(int)fhl;
		Fwrite(fh, fld_inf.flds_c*sizeof(FLD), fld_inf.flds);
		Fclose(fh);
		
		form_alert(1, gettext(ORD_ERR_DEL));
 	}
	return(problems);
}

/* -------------------------------------- */

void refresh_folders(void)
{
	load_inf_folders();	
	if(!(wfolder.open)) goto _main_rfolders;
	if(fld_inf.sel >= fld_inf.flds_c)
	{
		fld_inf.sel=fld_inf.flds_c-1;
		if(fld_inf.sel < 0) fld_inf.sel=0;
	}
	fld_set_dial();
	if(fld_inf.flds) 
	{
		objc_xtedcpy(ofolder, FLDNAME, fld_inf.flds[fld_inf.sel].from);
		if(fld_inf.flds[fld_inf.sel].fspec.finfo.flags=='Ig')
			ofolder[FLD_IGNORE].ob_state |= SELECTED;
		else
			ofolder[FLD_IGNORE].ob_state &= (~SELECTED);
		w_objc_draw(&wfolder, FLDNAME, 8, sx,sy,sw,sh);
		w_objc_draw(&wfolder, FLD_IGNORE, 8, sx,sy,sw,sh);
	}
	draw_fldframe();

_main_rfolders:
	if((ios.list!=2) || ((fld!=NULL)&&(fld[0].ftype!=FLD_FLD))) return;
	load_folders(1);
	if(ios.list_sel >= fld_c)
	{
		ios.list_sel=fld_c-1;
		if(ios.list_sel < 0) ios.list_sel=0;
	}
	fold_view();	/* Falls Liste leer, wird hier LôSCHEN-Button disabled */
	list_slide_set();
	w_objc_draw(&wdial, ALISTE, 8, sx,sy,sw,sh);
	w_objc_draw(&wdial, LOESCHEN, 8, sx,sy,sw,sh);
}

/* -------------------------------------- */

int load_inf_folders(void)
{
	if(fld_inf.flds) free(fld_inf.flds);
	return(get_folders(&(fld_inf.flds), &(fld_inf.flds_c)));
}

/* -------------------------------------- */

int delete_folder(FLD *fl, long fld_len, long sel)
{
	long	fhl;
	int		fh;
	char	path[256];
	DTA		*old=Fgetdta(), dta;

	strcpy(path, db_path);
	strcat(path, "\\ORD\\");
	strcat(path, fl[sel].fspec.fname);

	/* Alle Dateien im Ordner lîschen */
	if(db_mode)
		Idx_list_move(FF_ORD, atol(fl[sel].fspec.fname), FF_NON, -1);

	/* Auch im Datenbankmodus leerputzen. Vielleicht liegt was rum,
	   dann liese sich der Ordner nicht lîschen */
	Dsetpath(path);
	strcat(path, "\\*.*");
	Fsetdta(&dta);
	if(!Fsfirst(path, 0))	do
	{
		if((fhl=Fdelete(dta.d_fname)) < 0)
		{	form_alert(1, gettext(DELETE_ERR)); return(0);}
	}while(!Fsnext());
	Fsetdta(old);

	/* Ordner lîschen */
	path[strlen(path)-4]=0;	/* "\*.*" entfernen */
	fhl=Ddelete(path);
	if(fhl < 0)
	{
		gemdos_alert("Kann Ordner nicht lîschen.", fhl);
		return(0);
	}

	/* Neue Index-Datei schreiben */
	strcpy(path, db_path);
	strcat(path, "\\ORD\\ORD.IDX");
	fhl=Fcreate(path, 0);
	if(fhl < 0)
	{
		gemdos_alert("Kann Ordner-Index nicht aktualisieren.", fhl);
		return(0);
	}
	fh=(int)fhl;
	if(sel) Fwrite(fh, sel*sizeof(FLD), fl);
	if(sel < fld_len-1) Fwrite(fh, (fld_len-sel-1)*sizeof(FLD), &(fl[sel+1]));
	Fclose(fh);
	return(1);
}

/* -------------------------------------- */

int rename_folder(FLD *fl, long fld_len, long sel, char *name, int ignore)
{
	long	fhl;
	char	path[256];
	int		fh;

	strcpy(path, db_path);
	strcat(path, "\\ORD\\ORD.IDX");
	fhl=Fcreate(path, 0);
	if(fhl < 0)
	{
		gemdos_alert("Kann Ordner-Index nicht aktualisieren.", fhl);
		return(0);
	}
	strcpy(fl[sel].from, name);
	if(ignore)
		fl[sel].fspec.finfo.flags='Ig';
	else
		fl[sel].fspec.finfo.flags=0;
	fh=(int)fhl;
	Fwrite(fh, fld_len*sizeof(FLD), fl);
	Fclose(fh);
	return(1);
}

/* -------------------------------------- */

int make_folder(char *name, int ignore)
{	/* ignore: 0=nix, !=0: beim AufrÑumen ignorieren */
	long	free_num=0, fhl;
	char	path[256], bpath[256], num[8];
	int		fh;
	FLD		bfld;

	/* Freie Nummer finden */
	fhl=fld_inf.flds_c;
	while(fhl--)
		if(atol(fld_inf.flds[fhl].fspec.fname) >= free_num)
			free_num=atol(fld_inf.flds[fhl].fspec.fname)+1;

	strcpy(bpath, db_path);
	strcat(bpath, "\\ORD\\");
	strcpy(path, bpath);
	ltoa(free_num, num, 10);
	strcat(path, num);

	if(Dsetpath(path) < 0)
	{
		fhl=Dcreate(path);
		if(fhl < 0)
		{
			gemdos_alert("Kann Ordner nicht anlegen.", fhl);
			return(0);
		}
	}

	strcat(bpath, "ORD.IDX");
	fhl=Fopen(bpath, FO_WRITE);
	if(fhl < 0)
	{
		gemdos_alert("Kann Ordner-Index nicht aktualisieren.", fhl);
		Ddelete(path);
		return(0);
	}
	fh=(int)fhl;
	strcpy(bfld.fspec.fname, num);
	bfld.ftype=FLD_FLD;
	strcpy(bfld.from, name);
	if(ignore)
		bfld.fspec.finfo.flags='Ig';
	else
		bfld.fspec.finfo.flags=0;
	
	Fseek(0, fh, 2);
	Fwrite(fh, sizeof(FLD), &bfld);
	Fclose(fh);
	return(1);
}

/* -------------------------------------- */

void fld_init_inf(void)
{
	fld_inf.offset=fld_inf.sel=0;
	if(fld_inf.flds==NULL) load_inf_folders();
}

/* -------------------------------------- */

void fld_set_dial(void)
{
	long	a;
	long	t, l;
	
	/* Slider setzen */

	/* Ggf. Listenoffset korrigieren */
	l=FLDLAST-FLD1+1;	/* Sichtbare Zeilen */
	if(fld_inf.offset+l > fld_inf.flds_c)	fld_inf.offset=fld_inf.flds_c-l;
	if(fld_inf.offset < 0) 	fld_inf.offset=0;
	
	a=fld_inf.offset;
	
	if(fld_inf.flds_c <= l)
	{
		ofolder[FLDSLIDE].ob_y=0;
		ofolder[FLDSLIDE].ob_height=ofolder[FLDBAR].ob_height;
		goto _fld_text;
	}
	
	/* Slidergrîûe */
	t=(long)fld_inf.flds_c*(long)(ofolder[FLD1].ob_height);	/* Gesamte Liste in Pixeln */
	ofolder[FLDSLIDE].ob_height=(int)( ((long)ofolder[FLDBAR].ob_height*(long)(l*(long)ofolder[FLD1].ob_height))/t);
	if(ofolder[FLDSLIDE].ob_height < ofolder[FLDSLIDE].ob_width)
		ofolder[FLDSLIDE].ob_height=ofolder[FLDSLIDE].ob_width;
	
	/* Sliderpos. */
	ofolder[FLDSLIDE].ob_y=(int)(
				((long)(ofolder[FLDBAR].ob_height-ofolder[FLDSLIDE].ob_height)*
				 (long)(fld_inf.offset)) 
				 / 
				 (fld_inf.flds_c-l));

_fld_text:
	/* Strings setzen */
	while((a < fld_inf.flds_c) && (a-fld_inf.offset <= FLDLAST-FLD1))
	{
		strncpy(ofolder[FLD1+a-fld_inf.offset].ob_spec.tedinfo->te_ptext,
					fld_inf.flds[a].from, 33);
		ofolder[FLD1+a-fld_inf.offset].ob_spec.tedinfo->te_ptext[33]=0;
		if(a==fld_inf.sel)
			ofolder[FLD1+a-fld_inf.offset].ob_state |= SELECTED;
		else
			ofolder[FLD1+a-fld_inf.offset].ob_state &= (~SELECTED);
		++a;
	}
	while(a-fld_inf.offset <= FLDLAST-FLD1)
	{
		ofolder[FLD1+a-fld_inf.offset].ob_spec.tedinfo->te_ptext[0]=0;
		ofolder[FLD1+a-fld_inf.offset].ob_state &= (~SELECTED);
		++a;
	}
	
	/* Buttons aktiv/inaktiv */
	if((!(ofolder[FLDRENAME].ob_state & DISABLED)) && ((fld_inf.flds==NULL)||(fld_inf.flds_c==0)))
	{
		ofolder[FLDRENAME].ob_state |= DISABLED;
		ofolder[IFLDRENAME].ob_state |= DISABLED;
		ofolder[FLDDEL].ob_state |= DISABLED;
		ofolder[IFLDDEL].ob_state |= DISABLED;
		w_objc_draw(&wfolder, FLDRENAME, 8, sx,sy,sw,sh);
		w_objc_draw(&wfolder, FLDDEL, 8, sx,sy,sw,sh);
	}
	else if((ofolder[FLDRENAME].ob_state & DISABLED) && (fld_inf.flds!=NULL) && (fld_inf.flds_c > 0))
	{
		ofolder[FLDRENAME].ob_state &= (~DISABLED);
		ofolder[IFLDRENAME].ob_state &= (~DISABLED);
		ofolder[FLDDEL].ob_state &= (~DISABLED);
		ofolder[IFLDDEL].ob_state &= (~DISABLED);
		w_objc_draw(&wfolder, FLDRENAME, 8, sx,sy,sw,sh);
		w_objc_draw(&wfolder, FLDDEL, 8, sx,sy,sw,sh);
	}
}

/* -------------------------------------- */

void foldclosed(WINDOW *win)
{
	w_close(win);
	w_kill(win);
}

/* -------------------------------------- */

void	folder_dial(void)
{
	if(wfolder.open)
	{
		w_top(&wfolder);
		return;
	}

	fld_init_inf();
	fld_set_dial();
	if(fld_inf.flds) 
	{
		objc_xtedcpy(ofolder, FLDNAME, fld_inf.flds[fld_inf.sel].from);
		if(fld_inf.flds[fld_inf.sel].fspec.finfo.flags=='Ig')
			ofolder[FLD_IGNORE].ob_state |= SELECTED;
		else
			ofolder[FLD_IGNORE].ob_state &= (~SELECTED);
	}
	wfolder.dinfo=&dfolder;
	w_kdial(&wfolder, D_CENTER, MOVE|NAME|BACKDROP|CLOSE);
	wfolder.closed=foldclosed;
	/*wfolder.name="";
	w_set(&wfolder, NAME);*/
	dfolder.dedit=FLDNAME;
	w_open(&wfolder);
}

/* -------------------------------------- */

void slide_folders(void)
{
	int		mb, my, oy=-1, miny, maxy, offy, dum;
	long	l, off;

	maxy=ofolder[FLDBAR].ob_height-ofolder[FLDSLIDE].ob_height;
	if(maxy==0) return;
	
	wind_update(BEG_MCTRL);
	graf_mouse(FLAT_HAND, NULL);

	objc_offset(ofolder, FLDSLIDE, &dum, &offy);
	graf_mkstate(&dum, &my, &dum, &dum);
	offy=my-offy;
	objc_offset(ofolder, FLDBAR, &dum, &miny);
	
	do
	{
		graf_mkstate(&dum, &my, &mb, &dum);
		my-=miny+offy;
		if(my < 0) my=0;
		if(my > maxy) my=maxy;
		if(my==oy) continue;	
		
		/* Neuen Offset ausrechnen */
		l=FLDLAST-FLD1+1;		/* Sichtbare Zeilen */
		off=(int)(((long)my*(fld_inf.flds_c-l))/(long)maxy);
		if(off!=fld_inf.offset)
		{
			fld_inf.offset=off;
			fld_set_dial();
			draw_fldframe();
		}	
	}while(mb & 3);
	
	graf_mouse(ARROW, NULL);
	wind_update(END_MCTRL);
}

/* -------------------------------------- */

void dial_folder(int ob)
{
	long	a;
	int		my,oy,dum;
	char	buf[16];
	
	switch(ob)
	{
		case FLDNEU: case IFLDNEU:
			if(!w_wo_ibut_sel(&wfolder, ob)) break;
			if(strlen(xted(ofolder, FLDNAME)->te_ptext)==0)
			{
				form_alert(1,gettext(FLD_NONAME));
				w_wo_ibut_unsel(&wfolder, ob);
				break;
			}
			if(make_folder(xted(ofolder, FLDNAME)->te_ptext, ofolder[FLD_IGNORE].ob_state & SELECTED)==0)
			{
				w_wo_ibut_unsel(&wfolder, ob);
				break;
			}
			w_dialcursor(&wfolder, D_CUROFF);
			refresh_folders();
			w_dialcursor(&wfolder, D_CURON);
			w_wo_ibut_unsel(&wfolder, ob);
		break;
		case FLDRENAME: case IFLDRENAME:
			if(!w_wo_ibut_sel(&wfolder, ob)) break;
			if(strlen(xted(ofolder, FLDNAME)->te_ptext)==0)
			{
				form_alert(1,gettext(FLD_NONAME));
				w_wo_ibut_unsel(&wfolder, ob);
				break;
			}
			if(rename_folder(fld_inf.flds, fld_inf.flds_c, fld_inf.sel, xted(ofolder, FLDNAME)->te_ptext, ofolder[FLD_IGNORE].ob_state & SELECTED)==0)
			{
				w_wo_ibut_unsel(&wfolder, ob);
				break;
			}
			strcpy(fld_inf.flds[fld_inf.sel].from, xted(ofolder, FLDNAME)->te_ptext);
			fld_set_dial();
			draw_fldframe();
			if(ext_type(odial, POPUP)==2)
			{
				if((fld==NULL)||(fld[0].ftype==FLD_FLD))
				{/* In OrdnerÅbersicht */
					load_folders(1);
					list_slide_set();
					w_objc_draw(&wdial, ALISTE, 8, sx,sy,sw,sh);
				}
				else if((fld[0].ftype==FLD_BAK) && (!strcmp(act_fold, fld_inf.flds[fld_inf.sel].fspec.fname)))
				{/* Gerade in genau diesem Ordner */
					strcpy(fld[0].from, ".. ["); strcat(fld[0].from, fld_inf.flds[fld_inf.sel].from); strcat(fld[0].from, "]");
					w_objc_draw(&wdial, ALISTE, 8, sx,sy,sw,sh);
				}
			}
			w_wo_ibut_unsel(&wfolder, ob);
		break;
		case FLDDEL: case IFLDDEL:
			if(!w_wo_ibut_sel(&wfolder, ob)) break;
			if(form_alert(1, gettext(FLD_DELETE))==2)
			{
				w_wo_ibut_unsel(&wfolder, ob);
				break;
			}
			if(delete_folder(fld_inf.flds, fld_inf.flds_c, fld_inf.sel)==0)
			{
				w_wo_ibut_unsel(&wfolder, ob);
				break;
			}
			strcpy(buf, fld_inf.flds[fld_inf.sel].fspec.fname);
			w_dialcursor(&wfolder, D_CUROFF);
			refresh_folders();
			w_dialcursor(&wfolder, D_CURON);
			if((ios.list==2)&&(fld[0].ftype==FLD_BAK) && (!strcmp(act_fold, buf)))
			{/* Gerade in genau diesem Ordner -> In öbersicht wechseln */
				switch_list(2);
			}
			w_wo_ibut_unsel(&wfolder, ob);
		break;
		
		case FLDUP:
			a=fld_inf.offset-1;
		goto _new_fld_offset;
		case FLDDOWN:
			a=fld_inf.offset+1;
		goto _new_fld_offset;
		case FLDSLIDE:
			slide_folders();
		break;
		case FLDBAR:
			graf_mkstate(&dum, &my, &dum, &dum);
			objc_offset(ofolder, FLDSLIDE, &dum, &oy);
			if(my < oy)
				a=fld_inf.offset-(FLDLAST-FLD1+1);
			else
				a=fld_inf.offset+(FLDLAST-FLD1+1);
		goto _new_fld_offset;
	}
	
	if((ob >= FLD1)&&(ob <= FLDLAST))
	{
		a=ob-FLD1; a+=fld_inf.offset;
		if(a >= fld_inf.flds_c) a=fld_inf.flds_c-1;
		if(a==fld_inf.sel) return;
		fld_inf.sel=a;
		fld_set_dial();
		draw_fldframe();
		w_dialcursor(&wfolder, D_CUROFF);
		objc_xtedcpy(ofolder, FLDNAME, fld_inf.flds[a].from);
		if(fld_inf.flds[a].fspec.finfo.flags=='Ig')
			ofolder[FLD_IGNORE].ob_state |= SELECTED;
		else
			ofolder[FLD_IGNORE].ob_state &= (~SELECTED);
		w_objc_draw(&wfolder, FLDNAME, 8, sx,sy,sw,sh);
		w_objc_draw(&wfolder, FLD_IGNORE, 8, sx,sy,sw,sh);
		w_dialcursor(&wfolder, D_CURON);
	}
	return;

_new_fld_offset:
	if(a+FLDLAST-FLD1+1 > fld_inf.flds_c)	a=fld_inf.flds_c-(FLDLAST-FLD1+1);
	if(a < 0) a=0;
	if(a==fld_inf.offset) return;
	fld_inf.offset=a;
	fld_set_dial();
	draw_fldframe();
}