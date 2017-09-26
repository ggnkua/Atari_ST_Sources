#include <ec_gem.h>
#include "io.h"
#include "ioglobal.h"
#include "indexer.h"

long dbpop2ix=0;
WINDOW awin;
extern int	DB_ignore_interest;

void zurueckhalten(void)
{
	char	bpath[256];
	int		attrib;

	if((fld==NULL)||(fld_c==0)) return;

	if(fld[ios.list_sel].ftype != FLD_SND) return;
	
	strcpy(bpath, db_path);

	/* Zu versendende kînnen nur hier liegen: */
	switch(ios.list)
	{
		case 0:
			strcat(bpath, "\\PM\\");
		break;
		case 1:
			strcat(bpath, "\\OM\\SEND\\");
		break;
	}

	strcat(bpath, fld[ios.list_sel].fspec.fname);
	attrib=Fattrib(bpath, 0, 0);
	if(fld[ios.list_sel].loc_flags & LF_DELAYED)
	{
		fld[ios.list_sel].loc_flags &= (~LF_DELAYED);
		attrib&=(~FA_HIDDEN);
	}
	else
	{
		fld[ios.list_sel].loc_flags |= LF_DELAYED;
		attrib|=FA_HIDDEN;
	}
	Fattrib(bpath, 1, attrib);
	
	if(fld_bak)
	{
		fld_bak[fld[ios.list_sel].root_index].loc_flags=fld[ios.list_sel].loc_flags;
	}
	
	act_mail_list_view();
	
	if(!(odial[ALISTE].ob_flags & HIDETREE))
		w_objc_draw(&wdial, ALISTE, 8, sx,sy,sw,sh);
}

/* ------------------------------------------- */

void interessant(void)
{
	if(db_mode)
	{
		if(fld[ios.list_sel].fspec.finfo.flags & FF_ITR)
		{
			Idx_clearflag(fld[ios.list_sel].idx, FF_ITR);
			fld[ios.list_sel].fspec.finfo.flags &= (~FF_ITR);
		}
		else
		{
			Idx_setflag(fld[ios.list_sel].idx, FF_ITR);
			fld[ios.list_sel].fspec.finfo.flags |= FF_ITR;
		}
		act_mail_list_view();
		if(!(odial[ALISTE].ob_flags & HIDETREE))
			w_objc_draw(&wdial, ALISTE, 8, sx,sy,sw,sh);
	}
}

/* ------------------------------------------- */

void animate(int cont)
{
	static long ticker;
	static int dir, t_dir;
	long	ticker2;
	int ox, oy, ow, oh;
	#define ANIM_FREQ 10
	
	if(cont==0) /* Init */
	{
		ticker=clock();
		dir=0;
		t_dir=0;
		awin.dinfo->tree[BL0].ob_x=awin.dinfo->tree[0].ob_width+1;
		awin.dinfo->tree[TONNE].ob_x=awin.dinfo->tree[0].ob_width+70;
		awin.dinfo->tree[TONNE].ob_y=16;
		while(appl_read(-1, 16, pbuf)) w_dispatch(pbuf);
		return;
	}
	/* Animieren */
	while(appl_read(-1, 16, pbuf)) w_dispatch(pbuf);
	
	ticker2=clock();
	if(ticker2 - ticker < ANIM_FREQ) return;
	
	ticker=ticker2; 
	objc_offset(awin.dinfo->tree, 0, &ox, &oy);
	ow=awin.dinfo->tree[0].ob_width;
	oh=awin.dinfo->tree[0].ob_height;
	switch(dir)
	{
		case 0:
			awin.dinfo->tree[BL0].ob_spec.ciconblk=awin.dinfo->tree[BL1].ob_spec.ciconblk;
			dir=1;
		break;
		case 1:
			awin.dinfo->tree[BL0].ob_spec.ciconblk=awin.dinfo->tree[BL2].ob_spec.ciconblk;
			dir=2;
		break;
		case 2:
			awin.dinfo->tree[BL0].ob_spec.ciconblk=awin.dinfo->tree[BL3].ob_spec.ciconblk;
			dir=3;
		break;
		case 3:
			awin.dinfo->tree[BL0].ob_spec.ciconblk=awin.dinfo->tree[BL2].ob_spec.ciconblk;
			dir=0;
		break;
	}
	
	--awin.dinfo->tree[BL0].ob_x;
	--awin.dinfo->tree[TONNE].ob_x;
	if(t_dir==0)
	{
		--awin.dinfo->tree[TONNE].ob_y;
		if(awin.dinfo->tree[TONNE].ob_y < 8) t_dir=1;
	}
	else
	{
		++awin.dinfo->tree[TONNE].ob_y;
		if(awin.dinfo->tree[TONNE].ob_y > 15) t_dir=0;
	}
	
	if(awin.dinfo->tree[TONNE].ob_x+awin.dinfo->tree[TONNE].ob_width < 0)
	{
		dir=0;
		awin.dinfo->tree[BL0].ob_x=awin.dinfo->tree[0].ob_width+1;
		awin.dinfo->tree[TONNE].ob_x=awin.dinfo->tree[0].ob_width+70;
		awin.dinfo->tree[TONNE].ob_y=16;
	}
	
	w_objc_draw(&awin, BL0, 8, ox, oy, ow, oh);
	w_objc_draw(&awin, TONNE, 8, ox, oy, ow, oh);
}

/* ------------------------------------------- */

char *get_free_file(char *path)
{/* Gibt freien Dateinamen in <path> zurÅck. <path> muû mit "\"
		abgeschlossen sein, es wird kein suffix zurÅckgegeben. */
	long	free_num=0, act_num;
	static char	free_name[16];
	char	testpath[256], *c;
	DTA		*old=Fgetdta(), dta;

	strcpy(testpath, path);
	strcat(testpath, "*.*");
	/* Dateien abklappern */
	Fsetdta(&dta);
	if(!Fsfirst(testpath, FA_HIDDEN))	do
	{
		strcpy(free_name, dta.d_fname);
		if((c=strchr(free_name, '.'))!=NULL) *c=0;
		act_num=atol(free_name);
		if(act_num >= free_num) free_num=act_num+1;
	}while(!Fsnext());
	Fsetdta(old);

	ltoa(free_num, free_name, 10);
	return(free_name);	
}

char *suffix(char *filename)
{
	if(strchr(filename, '.')==NULL)
		return(&(filename[strlen(filename)]));	/* =0, also "" */
	return(strchr(filename, '.'));
}

/* ------------------------------------------- */

void remove_file_from_list(char *path)
{/* Die Nachricht in <path> aus der Anzeige nehmen, sofern
		sie Åberhaupt in der Liste ist */
	long a, found;
	char	bpath[256];

	if((fld==NULL)||(fld_c==0)) return;

	strcpy(bpath, db_path);

	switch(ios.list)
	{
		case 0:
			strcat(bpath, "\\PM\\");
		break;
		case 1:
			if(fld[0].ftype!=FLD_BAK) return;
			strcat(bpath, "\\OM\\");
			strcat(bpath, act_fold);
			strcat(bpath, "\\");
		break;
		case 2:
			if(fld[0].ftype!=FLD_BAK) return;
			strcat(bpath, "\\ORD\\");
			strcat(bpath, act_fold);
			strcat(bpath, "\\");
		break;
		case 3:
			strcat(bpath, "\\DEL\\");
		break;
	}

	/* Stimmt der Pfad? */
	if(strnicmp(path, bpath, strlen(bpath))) return;

	path+=strlen(bpath);	/* path jetzt auf Filename */
	a=0;
	while(a < fld_c)
	{
		if(!stricmp(fld[a].fspec.fname, path)) break;
		++a;
	}
	if(a==fld_c) return;
	found=a;
	
	if(found==ios.list_sel) {remove_sel_from_list(); return;}
	
	if(fld_bak)
	{/* Zuerst aus Hauptliste entfernen */
		a=fld[found].root_index;
		while(a < fld_c_bak)
		{	fld_bak[a]=fld_bak[a+1]; ++a;}
		--fld_c_bak;
	}
	/* Aus aktueller Ansicht entfernen */
	a=found;
	while(a < fld_c)
	{	fld[a]=fld[a+1]; ++a;}
	--fld_c;
	if(ios.list_sel > found)
		--ios.list_sel; /* Liste rutscht eins nach oben */
	list_slide_set();
	if(!(odial[ALISTE].ob_flags & HIDETREE))
		w_objc_draw(&wdial, ALISTE, 8, sx,sy,sw,sh);
}

void remove_sel_from_list(void)
{/* Die selektierte Nachricht aus der Anzeige nehmen */
	long a;
	
	if(fld_bak)
	{/* Zuerst aus Hauptliste entfernen */
		a=fld[ios.list_sel].root_index;
		while(a < fld_c_bak)
		{	fld_bak[a]=fld_bak[a+1]; ++a;}
		--fld_c_bak;
	}
	/* Aus aktueller Ansicht entfernen */
	a=ios.list_sel;
	while(a < fld_c)
	{	fld[a]=fld[a+1]; ++a;}
	--fld_c;
	if(ios.list_sel >= fld_c) --ios.list_sel; /* Letzte Nachricht gelîscht */
	list_slide_set();
	sel_sl=-1;
	load_mail();
	if(!loaded)
		ios.list_sel=-1;
	else
		format_loaded(odial[TEXT].ob_width);
	act_mail_list_view();
	mail_slide_set();
	w_objc_draw(&wdial, 0, 8, sx,sy,sw,sh);
}

/* ------------------------------------------- */

void endg_loeschen(char *file)
{/* Fragt nach, ob der User die Nachricht endgÅltig lîschen will */
	long res;
	
	if(form_alert(1,gettext(DEFDEL))==2) return;	/* Abbruch */

	res=Fdelete(file);

	if(res < 0)
	{
		gemdos_alert(gettext(DELETE_ERR), res);
		return;
	}

	/* Liste aktualisieren */
	remove_sel_from_list();
}

int delete_group(FLD *fl, long sel)
{
	long	fhl;
	char	path[256], dpath[256];
	DTA		*old=Fgetdta(), dta;

	if(db_mode)
		Idx_list_move(FF_OM, atol(fl[sel].fspec.fname), FF_NON, -1);

	/* Auch im Datenbankmodus alles lîschen, falls noch
	   Files rumdÅmpeln. Die wÅrden sonst das Lîschen des
	   Ordners verhindern */
	strcpy(path, db_path);
	strcat(path, "\\OM\\");
	strcat(path, fl[sel].fspec.fname);
	strcpy(dpath, path);
	Dsetpath(path);
	strcat(path, "\\*.*");
	/* Alle Dateien im Ordner lîschen */
	Fsetdta(&dta);
	if(!Fsfirst(path, 0))	do
	{
		if((fhl=Fdelete(dta.d_fname)) < 0)
		{	form_alert(1, gettext(DELETE_ERR)); return(0);}
	}while(!Fsnext());
	Fsetdta(old);

	strcpy(path, dpath);
	strcat(path, ".GRP");

	fhl=Fdelete(path);
	if(fhl < 0)
	{
		gemdos_alert("Kann Gruppendatei nicht lîschen.", fhl);
		return(0);
	}

	strcpy(path, dpath);
	strcat(path, ".IDX");
	Fdelete(path);	/* Ignore error, IDX might not yet exist */

	fhl=Ddelete(dpath);
	if(fhl < 0)
	{
		gemdos_alert("Kann Gruppe nicht lîschen.", fhl);
		return(0);
	}
	return(1);
}

void loesche_gruppe(void)
{
	if(fld[ios.list_sel].ftype==FLD_GSD) {form_alert(1, gettext(NOGSDDEL)); return;}
	if(form_alert(1, gettext(GRP_DELETE))==2) return;
	if(delete_group(fld, ios.list_sel)==0) return;

	load_groups();
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

void loesche_ordner(void)
{
	if(form_alert(1, gettext(FLD_DELETE))==2) return;
	if(delete_folder(fld, fld_c, ios.list_sel)==0) return;
	refresh_folders();
}

void loeschen(void)
{
	char src[256], dst[256], tmp[256], *c;
	long	res;
	
	if((fld==NULL)||(ios.list_sel < 0)) return;

	strcpy(src, db_path);

	switch(ios.list)
	{
		case 0:
			strcat(src, "\\PM\\");
		break;
		case 1:
			if((fld[0].ftype==FLD_GRP)||(fld[0].ftype==FLD_GSD))
			{
				loesche_gruppe();
				return;
			}
			strcat(src, "\\OM\\");
			strcat(src, act_fold);
			strcat(src, "\\");
		break;
		case 2:
			if(fld[0].ftype==FLD_FLD)
			{
				loesche_ordner();
				return;
			}
			strcat(src, "\\ORD\\");
			strcat(src, act_fold);
			strcat(src, "\\");
		break;
		case 3:
			strcat(src, "\\DEL\\");
		break;
	}
	strcat(src, fld[ios.list_sel].fspec.fname);

	if(db_mode && (fld[ios.list_sel].ftype != FLD_SND))
	{/* Datenbank-Modus */
		if(ios.list==3)
		{
			if(form_alert(1,gettext(DEFDEL))==2) return;	/* Abbruch */
			Idx_kill(fld[ios.list_sel].idx);
		}
		else
			Idx_delete(fld[ios.list_sel].idx);
		remove_sel_from_list();
		return;
	}


	if(ios.list==3)
	{/* Ist bereits im "Gelîscht"-Verzeichnis */
		endg_loeschen(src);
		return;
	}
			
	strcpy(dst, db_path);
	strcat(dst, "\\DEL\\");
	strcat(dst, c=get_free_file(dst));
	if(fld[ios.list_sel].ftype==FLD_SND)
		strcat(dst, ".SNT");
	else
		strcat(dst, suffix(fld[ios.list_sel].fspec.fname));

	strcpy(tmp, db_path);
	strcat(tmp, "\\");
	strcat(tmp, c);
	strcat(tmp, suffix(fld[ios.list_sel].fspec.fname));

	/* Grund fÅr den folgenden Aufstand: MagiC oder die Mac-Anbindung
		 hat Fehler beim Verschieben+Umbenennen. Es wird erst Verschoben
		 und dann umbenannt. Folge:
		 Geht nicht mit Dateien, die unter altem Namen schon im Ziel liegen.
		 Liegt aber schon eine Datei mit neuem Namen in Ziel, dann wird
		 trotzdem unter altem Namen verschoben und nur das abschlieûende
		 Umbenennen schlÑgt fehl (wird aber nur mit Fehler -36 gemeldet,
		 genau wie beim ersten Problem, bei dem nix passiert) */
	/* Zuerst mit neuem Namen im DATABASE-Root ablegen */
	Frename(0, src, tmp);
	/* Dann nach DEL kopieren */
	res=Frename(0, tmp, dst);
	if(res< 0) 
	{
		gemdos_alert(gettext(RENAME_ERR), res);
		return;
	}
	if(db_mode)
	{/* Falls SND->SNT jetzt importieren */
		Idx_import_file(FF_DEL, -1, dst);
	}
	remove_sel_from_list();
}

/* ------------------------------------------- */

long grp_maxlen(char *c)
{
	char *d, mem;
	long max=0;

	while(*c)
	{
		d=c;
		while(*c&&(*c!=13)&&(*c!=10))++c;
		mem=*c; *c=0;
		if(strlen(d) > max) max=strlen(d);
		*c=mem;
		while(*c&&((*c==13)||(*c==10)))++c;
	}
	return(max);
}

int group_popup(char *grp, long grp_c)
{/* Gibt Index ab 1 zurÅck */
	OBJECT 	*tree, *root;
	char		*strings, *d, *c=grp, mem;
	int			a, num=(int)grp_c, mx, my;
	long		slen;
	
	if(grp_c==0) return(-1);

	graf_mkstate(&mx, &my, &a, &a);
	
	rsrc_gaddr(0, POPVORL, &root);
	slen=grp_maxlen(grp)+4; /* Zwei Space vorne, eins hinten, eine 0 */
	
	tree=malloc((num+1)*sizeof(OBJECT)+num*slen);
	if(tree==NULL) {form_alert(1, gettext(NOMEM)); return(0);}
	strings=(char*)&(tree[num+1]);
	tree[0]=root[0];
	tree[0].ob_tail=num;
	tree[0].ob_height=root[1].ob_height*num;
	tree[0].ob_width=(int)slen*8;	/* *** Nix so doll *** */

	graf_mouse(BUSYBEE, NULL);
	for(a=1; a <= num; ++a)
	{
		tree[a]=root[1];
		tree[a].ob_next=a+1;
		tree[a].ob_flags &=(~LASTOB);
		tree[a].ob_spec.free_string=strings;
		tree[a].ob_width=tree[0].ob_width;
		strcpy(strings, "  ");
		d=c;
		while(*c&&(*c!=13)&&(*c!=10))++c;
		mem=*c; *c=0;
		strcat(strings, d);
		*c=mem;
		while(*c&&((*c==13)||(*c==10)))++c;
		strings+=slen;
		tree[a].ob_y=root[1].ob_height*(a-1);
	}
	graf_mouse(ARROW, NULL);
	tree[num].ob_next=0;
	tree[num].ob_flags|=LASTOB;
	a=form_popup(tree, mx, my);
	free(tree);

	return(a);
}

long maxlen(FLD *fl, long flc)
{
	long max=0, a=0;
	
	while(a < flc)
	{
		if(strlen(fl[a].from) > max) max=strlen(fl[a].from);
		++a;
	}
	return(max);
}

/* ------------------------------------------- */

int fld_spec_popup(FLD *fl, long flc)
{/* Gibt Index ab 1 zurÅck */
	OBJECT 	*tree, *root;
	char		*strings;
	int			a, num=(int)flc, mx, my;
	long		slen;
	
	if(flc < 1) {Bell(); return(-1);}	/* Popup ist leer */

	++num;	/* Ein Eintrag mehr fÅr "Ordnen per Filter" */

	graf_mkstate(&mx, &my, &a, &a);
	
	rsrc_gaddr(0, POPVORL, &root);
	slen=maxlen(fl, flc);
	if(strlen(gettext(ORD_BY_FIL)) > slen)
		slen=strlen(gettext(ORD_BY_FIL));
	slen+=4; /* Zwei Space vorne, eins hinten, eine 0 */
	
	tree=malloc((num+1)*sizeof(OBJECT)+num*slen);
	if(tree==NULL) {form_alert(1, gettext(NOMEM)); return(0);}
	strings=(char*)&(tree[num+1]);
	tree[0]=root[0];
	tree[0].ob_tail=num;
	tree[0].ob_height=root[1].ob_height*num;
	tree[0].ob_width=(int)slen*8;	/* *** Nix so doll *** */
	/* "Ordnen per Filter"-Eintrag */
	tree[1]=root[1];
	tree[1].ob_next=2;
	tree[1].ob_flags &=(~LASTOB);
	tree[1].ob_spec.free_string=strings;
	tree[1].ob_width=tree[0].ob_width;
	strcpy(strings, "  ");
	strcat(strings, gettext(ORD_BY_FIL));
	strings+=slen;
	tree[1].ob_y=0;
	for(a=2; a <= num; ++a)
	{
		tree[a]=root[1];
		tree[a].ob_next=a+1;
		tree[a].ob_flags &=(~LASTOB);
		tree[a].ob_spec.free_string=strings;
		tree[a].ob_width=tree[0].ob_width;
		strcpy(strings, "  ");
		strcat(strings, fl[a-2].from);
		strings+=slen;
		tree[a].ob_y=root[1].ob_height*(a-1);
	}
	tree[num].ob_next=0;
	tree[num].ob_flags|=LASTOB;
	a=form_popup(tree, mx, my);
	free(tree);

	return(a);
}

int fld_popup(FLD *fl, long flc)
{/* Gibt Index ab 1 zurÅck */
	OBJECT 	*tree, *root;
	char		*strings;
	int			a, num=(int)flc, mx, my;
	long		slen;
	
	if(flc < 1) {Bell(); return(-1);}	/* Popup ist leer */

	graf_mkstate(&mx, &my, &a, &a);
	
	rsrc_gaddr(0, POPVORL, &root);
	slen=maxlen(fl, flc)+4; /* Zwei Space vorne, eins hinten, eine 0 */
	
	tree=malloc((num+1)*sizeof(OBJECT)+num*slen);
	if(tree==NULL) {form_alert(1, gettext(NOMEM)); return(0);}
	strings=(char*)&(tree[num+1]);
	tree[0]=root[0];
	tree[0].ob_tail=num;
	tree[0].ob_height=root[1].ob_height*num;
	tree[0].ob_width=(int)slen*8;	/* *** Nix so doll *** */
	for(a=1; a <= num; ++a)
	{
		tree[a]=root[1];
		tree[a].ob_next=a+1;
		tree[a].ob_flags &=(~LASTOB);
		tree[a].ob_spec.free_string=strings;
		tree[a].ob_width=tree[0].ob_width;
		strcpy(strings, "  ");
		strcat(strings, fl[a-1].from);
		strings+=slen;
		tree[a].ob_y=root[1].ob_height*(a-1);
	}
	tree[num].ob_next=0;
	tree[num].ob_flags|=LASTOB;
	a=form_popup(tree, mx, my);
	free(tree);

	return(a);
}

int get_folders(FLD **fl, long *flc)
{/* -1=Kein Speicher, 0=Keine Ordner, 1=Ok */
	int ret;
	FLD	*b1=fld, *b2=fld_bak;
	long	bc1=fld_c, bc2=fld_c_bak;
	
	fld=NULL; fld_bak=NULL;
	ret=load_folders(0);
	*fl=fld; 
	*flc=fld_c;
	fld=b1; fld_bak=b2;
	fld_c=bc1; fld_c_bak=bc2;

	return(ret);
}

int get_groups(FLD **fl, long *flc)
{/* -1=Kein Speicher, 0=Keine Ordner, 1=Ok */
	int ret;
	FLD	*b1=fld, *b2=fld_bak;
	long	bc1=fld_c, bc2=fld_c_bak;
	
	fld=NULL; fld_bak=NULL;
	ret=load_groups();
	*fl=fld; 
	*flc=fld_c;
	fld=b1; fld_bak=b2;
	fld_c=bc1; fld_c_bak=bc2;

	return(ret);	
}

void verschieben(void)
{/* Popup aller Ordner anbieten und ggf. selektierte Verschieben */
	FLD		*fl;
	long	bc1, flc, same_found;
	int		sel;
	
	if((fld==NULL) || (ios.list_sel < 0)) return;
	
	if(fld_inf.flds_c==0)
	{
		form_alert(1, gettext(NOSORT));
		return;
	}

	fl=malloc(fld_inf.flds_c*sizeof(FLD));
	if(fl==NULL)
	{
		form_alert(1, gettext(NOMEM));
		return;
	}
	flc=fld_inf.flds_c;
	while(flc--)
		fl[flc]=fld_inf.flds[flc];
	flc=fld_inf.flds_c;
	
	same_found=flc+2;
	/* Falls Ansicht gerade in Ordner, aktuellen aus Popup entfernen */
	if(ios.list==2)
	{
		bc1=0;
		while(bc1 < flc)
		{
			if(!strcmp(act_fold, fl[bc1].fspec.fname))
			{/* Gefunden, Array-Rest eins zurÅck kopieren */
				same_found=bc1;
				while(bc1 < flc)
				{	fl[bc1]=fl[bc1+1];	++bc1;}
				--flc;
				break;
			}
			++bc1;
		}
	}
	
	if((sel=fld_spec_popup(fl, flc)) < 1) /* Abbruch */
	{
		free(fl);
		return;
	}
	
	/* Jetzt verschieben */	
	if(sel==1) /* Per Filter */
	{
		ord_by_filter();
		return;
	}
	
	sel-=2;	/* Erster Ordner=Index 0 */
	/* Falls Ordner nach rausgeschmissenem kommt, Index++ */
	if(sel >= (int)same_found) ++sel;
	
	ord_act_mail(sel);
	free(fl);
}

void ord_act_mail(int fold_ix)
{/* Aktuelle Mail nach Ordner <ix> sortieren */
	char src[256], dst[256], tmp[256], *c;
	long	res;

	if(fld[ios.list_sel].ftype == FLD_SND)
	{
		if(form_alert(1, gettext(SORTSNDSNT))==2) return;
	}
	else if(db_mode) /* Nicht bei FLD_SND! Wird unten nachtrÑglich importiert */
	{
		Idx_ord(fld[ios.list_sel].idx, atol(fld_inf.flds[fold_ix].fspec.fname));
		remove_sel_from_list();
		return;
	}

	strcpy(src, db_path);

	switch(ios.list)
	{
		case 0:
			strcat(src, "\\PM\\");
		break;
		case 1:
			strcat(src, "\\OM\\");
			strcat(src, act_fold);
			strcat(src, "\\");
		break;
		case 2:
			strcat(src, "\\ORD\\");
			strcat(src, act_fold);
			strcat(src, "\\");
		break;
		case 3:
			strcat(src, "\\DEL\\");
		break;
	}
	strcat(src, fld[ios.list_sel].fspec.fname);
		
	strcpy(dst, db_path);
	strcat(dst, "\\ORD\\");
	strcat(dst, fld_inf.flds[fold_ix].fspec.fname);
	strcat(dst, "\\");
	if(!strnicmp(src, dst, strlen(dst))) return;	/* Ziel=Quelle nix gut */
	strcat(dst, c=get_free_file(dst));
	if(fld[ios.list_sel].ftype==FLD_SND)
	{
		strcat(dst, ".SNT");
		fld[ios.list_sel].ftype=FLD_SNT;
	}
	else
		strcat(dst, suffix(fld[ios.list_sel].fspec.fname));
	strcpy(tmp, db_path);
	strcat(tmp, "\\");
	strcat(tmp, c);
	strcat(tmp, suffix(fld[ios.list_sel].fspec.fname));

	/* Zuerst mit neuem Namen im DATABASE-Root ablegen */
	Frename(0, src, tmp);
	/* Dann nach ORD kopieren */
	res=Frename(0, tmp, dst);
	if(res< 0) 
	{
		gemdos_alert(gettext(RENAME_ERR), res);
		return;
	}
	if(db_mode)
	{/* Aus SND wurde SNT, jetzt importieren */
		Idx_import_file(FF_ORD, atol(fld_inf.flds[fold_ix].fspec.fname), dst);
	}
	remove_sel_from_list();
}

/* -------------------------------------- */

void db_list_popup(WINDOW *win)
{
	int			ox, oy, res;
	OBJECT *tree, *root=win->dinfo->tree;
	
	rsrc_gaddr(0, LISTPOPUP, &tree);
	objc_offset(root, DBPOP1, &ox, &oy);
	oy-=ext_type(root, DBPOP1)*tree[1].ob_height;
	
	res=form_popup(tree, ox, oy);
	if(res < 0) return;
	strcpy(root[DBPOP1].ob_spec.free_string, &(tree[res].ob_spec.free_string[2]));
	root[IDBPOP1].ob_spec.ciconblk=tree[res+1].ob_spec.ciconblk;
	res=(res-1)/2;
	if(ext_type(root, DBPOP1)==res) return;
	set_ext_type(root, DBPOP1, res);
	switch(res)
	{
		case 0:	/* Persînliche */
		case 3:	/* Gelîschte */
			root[DBPOP2].ob_flags |= HIDETREE;
		break;
		case 1:	 /* ôffentliche */
			dbpop2ix=0;
			root[DBPOP2].ob_flags &= (~HIDETREE);
			if(grp_inf.flds_c)
			{
				strncpy(root[DBPOP2].ob_spec.free_string, grp_inf.flds[0].from, 18);
				root[DBPOP2].ob_spec.free_string[18]=0;
			}
			else			
				strcpy(root[DBPOP2].ob_spec.free_string, "<Keine Gruppen>");
		break;
		case 2:	/* Geordnete */
			dbpop2ix=0;
			root[DBPOP2].ob_flags &= (~HIDETREE);
			if(fld_inf.flds)
			{
				strncpy(root[DBPOP2].ob_spec.free_string, fld_inf.flds[0].from, 18);
				root[DBPOP2].ob_spec.free_string[18]=0;
			}
			else			
				strcpy(root[DBPOP2].ob_spec.free_string, "<Keine Ordner>");
		break;
	}
	w_objc_draw(win, DBPOPBOX, 8, sx,sy,sw,sh);
}

/* -------------------------------------- */

void	db_group_popup(WINDOW *win)
{
	OBJECT *root=win->dinfo->tree;
	long		dum;
	
	if(ext_type(root, DBPOP1)==1)	/* ôffentliche */
	{
		if((grp_inf.flds==NULL)||(grp_inf.flds_c==0)) {Bell(); return;}
		dum=fld_popup(grp_inf.flds, grp_inf.flds_c);
		if(dum < 1) return;
		strncpy(root[DBPOP2].ob_spec.free_string, grp_inf.flds[dum-1].from, 18);
		root[DBPOP2].ob_spec.free_string[18]=0;
		dbpop2ix=dum-1;
	}
	else	/* Geordnete */
	{
		if((fld_inf.flds==NULL)||(fld_inf.flds_c==0)) {Bell(); return;}
		dum=fld_popup(fld_inf.flds, fld_inf.flds_c);
		if(dum < 1) return;
		strncpy(root[DBPOP2].ob_spec.free_string, fld_inf.flds[dum-1].from, 18);
		root[DBPOP2].ob_spec.free_string[18]=0;
		dbpop2ix=dum-1;
	}
	w_objc_draw(win, DBPOP2, 8, sx,sy,sw,sh);
}

/* -------------------------------------- */

void db_34_popup(WINDOW *win, int src_ob, int dst_tree)
{
	OBJECT *root=win->dinfo->tree, *tree;
	int		ox, oy, res;
		
	rsrc_gaddr(0, dst_tree, &tree);
	tree[1].ob_flags &= (~CHECKED);
	tree[2].ob_flags &= (~CHECKED);
	objc_offset(root, src_ob, &ox, &oy);
	oy-=ext_type(root, src_ob)*tree[1].ob_height;
	tree[1+ext_type(root, src_ob)].ob_flags |= CHECKED;
	res=form_popup(tree, ox, oy);
	if(res < 1) return;
	strcpy(root[src_ob].ob_spec.free_string, &(tree[res].ob_spec.free_string[2]));
	set_ext_type(root, src_ob, res-1);
	w_objc_draw(win, src_ob, 8, sx,sy,sw,sh);
}

/* -------------------------------------- */

void do_dbsearch(WINDOW *win, int ob)
{
	switch(ob)
	{
		case IDBPOP1: case DBPOP1:
			db_list_popup(win);
		break;
		
		case DBPOP2:
			db_group_popup(win);
		break;
		
		case DBPOP3:
			db_34_popup(win, DBPOP3, DBPOPUP1);
		break;
		
		case DBPOP4:
			db_34_popup(win, DBPOP4, DBPOPUP2);
		break;
		
		case DPDATPOP:
			date_popup(win, DBTEXT5);
		break;
		
		case DBSTART: case IDBSTART:
			if(!w_wo_ibut_sel(win, ob)) break;
		case DBABBRUCH:
			*(int*)(win->user)=ob;
			w_close(win);
		break;
	}
}

/* ------------------------------------------- */
int cmp_dat(unsigned int d_date, int lohi, char *dat)
{/* Datum aus Datei (dta.d_date) Vergleichen mit ttmmyyy aus dat.
		lohi: 0=d_date muû kleiner als dat sein
					1=d_date muû grîûer als dat sein
		! 'GRôSSER' bedeutet éLTER! 
		return: 1=paût, 0=nix gut */
	uint	dd, mm, yy;
	uint	mdate;
	char mem;
	
	mem=dat[2]; dat[2]=0;
	dd=atoi(dat); dat[2]=mem;
	mem=dat[4]; dat[4]=0;
	mm=atoi(&(dat[2])); dat[4]=mem;
	yy=atoi(&(dat[4]))-1980;
	mdate=yy<<9;
	mdate|=mm<<5;
	mdate|=dd;
	if(lohi)
	{/* date muû Ñlter sein */
		if(d_date < mdate) return(1);
		return(0);
	}
	
	if(d_date > mdate) return(1);
	return(0);
}
int cmp_size(unsigned long d_length, int lohi, char *siz)
{/* Grîûe der Datei (dta.d_length) Vergleichen mit Grîûe in KB aus siz.
		lohi: 0=d_length muû kleiner als dat sein
					1=d_length muû grîûer als dat sein
		return: 1=paût, 0=nix gut */
	long	soll=atol(siz)*1024;
	
	if(lohi)
	{
		if(d_length > soll) return(1);
		return(0);
	}
	if(d_length < soll) return(1);
	return(0);
}

int find_head(char *field, char *search)
{/* Finde in geladener Mail den Eintrag search im Header-Feld field
		ret: 0=nicht gefunden, 1=gefunden */
	char *c=get_head_field(field);
	
	if(c==NULL) return(0);
	if(stristr(c, search)) return(1);
	return(0);
}
int find_mail(char *search)
{/* Finde im body von geladener Mail den Text search
		ret: 0=nicht gefunden, 1=gefunden */
	long	cnt;
	char	*c;
	
	c=loadm.body; cnt=loadm.body_len;
	if(c) while(cnt > 0)
	{
		if(stristr(c, search)) return(1);
		cnt-=strlen(c)+1;
		c+=strlen(c)+1;
	}
	return(0);
}

void do_search(void)
{
	OBJECT	*tree;
	long	files=0, fhl, list_id, f_lix;
	char	path[256], bpath[256], *c, *buf, sbuf[64];
	int		fh, location;
	DTA		*old=Fgetdta(), dta;
	INDEXER	*idx;
	
	rsrc_gaddr(0, DBSEARCH, &tree);

	free_loaded_mail();
		
	strcpy(bpath, db_path);
	switch(ext_type(tree, DBPOP1))
	{
		case 0:
			strcat(bpath, "\\PM");
			location=FF_PM;
		break;
		case 1:	/* ôffentliche */
			strcat(bpath, "\\OM\\");
			strcat(bpath, grp_inf.flds[dbpop2ix].fspec.fname);
			strcpy(act_fold, grp_inf.flds[dbpop2ix].fspec.fname);
			strcpy(sbuf, grp_inf.flds[dbpop2ix].from);
			++files;	/* FÅr ".." Eintrag */
			location=FF_OM; list_id=atol(act_fold);
		break;
		case 2:
			strcat(bpath, "\\ORD\\");
			strcat(bpath,  fld_inf.flds[dbpop2ix].fspec.fname);
			strcpy(act_fold,  fld_inf.flds[dbpop2ix].fspec.fname);
			strcpy(sbuf,  fld_inf.flds[dbpop2ix].from);
			++files;	/* FÅr ".." Eintrag */
			location=FF_ORD; list_id=atol(act_fold);
		break;
		case 3:
			strcat(bpath, "\\DEL");
			location=FF_DEL;
		break;
	}
	strcpy(path, bpath);
	/* Dateien zÑhlen */
	if(db_mode)
	{
		idx=Idx_scan(IDX_FIRST, location, list_id, NULL);
		while(idx)
		{ ++files; idx=Idx_scan(IDX_NEXT, location, list_id, NULL); }
		Idx_scan(IDX_LAST, 0, 0, NULL);
		/* Zu sendende dazu */
		strcat(path, "\\*.SND");
		Fsetdta(&dta);
		if(!Fsfirst(path, 0))	do
		{ ++files;}while(!Fsnext());
		Fsetdta(old);
	}
	else
	{
		strcat(path, "\\*.*");
		Fsetdta(&dta);
		if(!Fsfirst(path, 0))	do
		{ ++files;}while(!Fsnext());
		Fsetdta(old);
	}

	/* Array anlegen */
	if(fld) {free(fld); fld=NULL;}
	if((fld_c=files)==0) return;
	fld=malloc(files*sizeof(FLD));
	if(fld==NULL)
	{	form_alert(1, gettext(NOMEM)); return;}

	/* Passende Dateien laden */
	files=0;
	if((ext_type(tree, DBPOP1)!=0)&&(ext_type(tree, DBPOP1)!=3))	/* ".."-Eintrag einfÅgen */
	{
		fld[0].ftype=FLD_BAK;
		strcpy(fld[0].from, ".. ["); strcat(fld[0].from, sbuf); strcat(fld[0].from, "]");
		fld[0].subj[0]=0;
		fld[0].date[0]=0;
		files=1;
	}

	if(db_mode)
	{
		if((idx=Idx_scan(IDX_FIRST, location, list_id, &f_lix))!=NULL) do
		{
			if((!(tree[DBSNDSNT].ob_state & SELECTED)) && (idx->ftype < FLD_NEW))
				continue;
			if((!(tree[DBNEWRED].ob_state & SELECTED)) && (idx->ftype > FLD_SNT))
				continue;
	
			if(strlen(tree[DBTEXT5].ob_spec.tedinfo->te_ptext)==8)	/* Datum angegeben */
				if(!cmp_dat(idx->fdate, ext_type(tree, DBPOP3), tree[DBTEXT5].ob_spec.tedinfo->te_ptext))
					continue;
			if(tree[DBTEXT6].ob_spec.tedinfo->te_ptext[0])	/* Grîûe angegeben */
				if(!cmp_size((ulong)(idx->db_size-sizeof(INDEXER)), ext_type(tree, DBPOP4), tree[DBTEXT6].ob_spec.tedinfo->te_ptext))
					continue;
					
			if(tree[DBANHANG].ob_state & SELECTED)	/* Nachricht soll Anhang enthalten */
				if(!(idx->flags & FF_ATX)) continue;
			
			if(tree[DBTEXT1].ob_spec.tedinfo->te_ptext[0])	/* Absender angegeben */
				if(!stristr(idx->from, tree[DBTEXT1].ob_spec.tedinfo->te_ptext))
					continue;
			if(tree[DBTEXT2].ob_spec.tedinfo->te_ptext[0])	/* EmpfÑnger angegeben */
				if(!stristr(idx->to, tree[DBTEXT2].ob_spec.tedinfo->te_ptext))
					continue;
			if(tree[DBTEXT3].ob_spec.tedinfo->te_ptext[0])	/* Betreff angegeben */
				if(!stristr(idx->subj, tree[DBTEXT3].ob_spec.tedinfo->te_ptext))
					continue;
			
			if(tree[DBTEXT4].ob_spec.tedinfo->te_ptext[0])	/* Nachrichteninhalt angegeben */
			{	/* Nachricht laden */
				buf=malloc(idx->db_size-sizeof(INDEXER)+1);
				if(buf==NULL) continue;
				if(Idx_load_mail(idx, buf)==0)
				{free(buf); continue;}
				buf[idx->db_size-sizeof(INDEXER)]=0;
				if(!stristr(buf, tree[DBTEXT4].ob_spec.tedinfo->te_ptext))
				{free(buf); continue;}
				free(buf);
			}
			/* Nachricht gut, in FLD Åbernehmen */
			fld[files].fspec.finfo.offset=idx->db_offset;
			fld[files].fspec.finfo.size=idx->db_size;
			fld[files].fspec.finfo.flags=idx->flags;
			fld[files].ftime=idx->ftime;
			fld[files].fdate=idx->fdate;
			fld[files].ftype=idx->ftype;
			if(idx->ftype <= FLD_SNT)
				make_list_adr(fld[files].from, idx->to);
			else
				make_list_adr(fld[files].from, idx->from);
			strcpy(fld[files].subj, idx->subj);
			fld[files].idx=f_lix;
			memcpy(fld[files].msg_id, idx->msg_id, 3*66);
			make_ascii_fdate(fld[files].date, idx->fdate, idx->ftime);
			fld[files].loc_flags=0;
			if(idx->flags & FF_ISOM) fld[files].loc_flags|=LF_OM;
			++files;
		}while((idx=Idx_scan(IDX_NEXT, location, list_id, &f_lix))!=NULL);
		Idx_scan(IDX_LAST, location, list_id, NULL);
		/* Wenn keine eigenen gesucht werden sollen, war's das: */
		if(!(tree[DBSNDSNT].ob_state & SELECTED)) goto _search_done;
	}
	
	Dsetpath(bpath);
	strcpy(path, bpath);
	if(db_mode)
		strcat(path, "\\*.SND");
	else
		strcat(path, "\\*.*");
	Fsetdta(&dta);
	if(!Fsfirst(path, FA_HIDDEN))	do
	{
		strcpy(fld[files].fspec.fname, dta.d_fname);
		fld[files].ftime=dta.d_time;
		fld[files].fdate=dta.d_date;
		c=&(dta.d_fname[strlen(dta.d_fname)-3]);
		if(!strcmp(c, "SND")) fld[files].ftype=FLD_SND;
		else if(!strcmp(c, "SNT")) fld[files].ftype=FLD_SNT;
		else if(!strcmp(c, "NEW")) fld[files].ftype=FLD_NEW;
		else if(!strcmp(c, "RED")) fld[files].ftype=FLD_RED;
		else fld[files].ftype=FLD_NON;
		fld[files].loc_flags=0;
		if(dta.d_attrib & FA_HIDDEN)
			fld[files].loc_flags|=LF_DELAYED;
		if((!(tree[DBSNDSNT].ob_state & SELECTED)) && (fld[files].ftype < FLD_NEW))
			continue;
		if((!(tree[DBNEWRED].ob_state & SELECTED)) && (fld[files].ftype > FLD_SNT))
			continue;

		if(strlen(tree[DBTEXT5].ob_spec.tedinfo->te_ptext)==8)	/* Datum angegeben */
			if(!cmp_dat(dta.d_date, ext_type(tree, DBPOP3), tree[DBTEXT5].ob_spec.tedinfo->te_ptext))
				continue;
		if(tree[DBTEXT6].ob_spec.tedinfo->te_ptext[0])	/* Grîûe angegeben */
			if(!cmp_size(dta.d_length, ext_type(tree, DBPOP4), tree[DBTEXT6].ob_spec.tedinfo->te_ptext))
				continue;
			
		fhl=Fopen(dta.d_fname, FO_READ); fh=(int)fhl;
		if((fhl >= 0) && ((buf=malloc(dta.d_length+1))!=NULL))
		{
			fhl=Fread(fh, dta.d_length, buf);
			Fclose(fh);
			if(fhl>0)buf[fhl-1]=0;
			if(strstr(buf, "Newsgroups:")) fld[files].loc_flags |= LF_OM;
			extract_head(fld[files].ftype, buf, fld[files].from, fld[files].subj);
			make_ascii_fdate(fld[files].date, dta.d_date, dta.d_time);
			++files;
			loaded=buf;
			llen=dta.d_length;
			if(split_loaded(loaded, llen, &loadm, 1)==0) {--files; free(buf); continue;}
			if(tree[DBANHANG].ob_state & SELECTED)	/* Anhang gewÑhlt */
			{ if(loadm.first==NULL)
				{--files; goto _nix_gut;}	}
			if(tree[DBTEXT1].ob_spec.tedinfo->te_ptext[0])	/* Absender angegeben */
			{	if(!find_head("From:", tree[DBTEXT1].ob_spec.tedinfo->te_ptext))
				{--files; goto _nix_gut;}	}
			if(tree[DBTEXT2].ob_spec.tedinfo->te_ptext[0])	/* EmpfÑnger angegeben */
			{	if(!find_head("To:", tree[DBTEXT2].ob_spec.tedinfo->te_ptext))
				{--files; goto _nix_gut;}	}
			if(tree[DBTEXT3].ob_spec.tedinfo->te_ptext[0])	/* Betreff angegeben */
			{	if(!find_head("Subject:", tree[DBTEXT3].ob_spec.tedinfo->te_ptext))
				{--files; goto _nix_gut;}	}
			if(tree[DBTEXT4].ob_spec.tedinfo->te_ptext[0])	/* Nachricht angegeben */
			{	if(!find_mail(tree[DBTEXT4].ob_spec.tedinfo->te_ptext))
				{--files; goto _nix_gut;}	}
_nix_gut:
			free_loaded_mail();
		}
		else 
		{
			if(fhl >= 0) Fclose(fh);
			extract_head(FLD_NEW, "", fld[files].from, fld[files].subj);
			make_ascii_fdate(fld[files].date, dta.d_date, dta.d_time);
			++files;
		}
	}while(!Fsnext());
	Fsetdta(old);

_search_done:
	fld_c=files;
	if(fld_c==0)
	{
		free(fld);
		fld=NULL;
		fld_c=0;
	}
}

/* ------------------------------------------- */

void dbsearch(void)
{
	OBJECT *tree, *tmp;
	
	rsrc_gaddr(0, DBSEARCH, &tree);
	tree[IDBSTART].ob_x=tree[IDBSTART].ob_y=0;
	tree[DBSTART].ob_state &= (~SELECTED);
	tree[DBABBRUCH].ob_state &= (~SELECTED);
	if(w_do_opt_dial(tree, do_dbsearch)==DBABBRUCH) return;

	if(ext_type(tree, DBPOP1)==1)	/* Gruppen */
	{
		if(!strcmp(tree[DBPOP2].ob_spec.free_string, "<Keine Gruppen>"))
		{Bell(); return;}
	}
	if(ext_type(tree, DBPOP1)==2)	/* Ordner */
	{
		if(!strcmp(tree[DBPOP2].ob_spec.free_string, "<Keine Ordner>"))
		{Bell(); return;}
	}

	if(fld_bak)
	{
		if(fld) free(fld);
		fld=fld_bak; fld_bak=NULL;
		fld_c=fld_c_bak; fld_c_bak=0;
	}

	graf_mouse(BUSYBEE, NULL);
	do_search();
	graf_mouse(ARROW, NULL);

	sort_by_sel();
	view_by_sel();

	set_ext_type(odial, POPUP, ios.list=ext_type(tree, DBPOP1));
	rsrc_gaddr(0, LISTPOPUP, &tmp);
	strcpy(odial[POPUP].ob_spec.free_string, &(tmp[ext_type(tree, DBPOP1)*2+1].ob_spec.free_string[2]));
	odial[IPOPUP].ob_spec.ciconblk=tmp[ext_type(tree, DBPOP1)*2+2].ob_spec.ciconblk;
	
	ios.list_off=0;
	switch(ext_type(tree, DBPOP1))
	{
		case 0:	/* PMs */
		case 3:	/* Gelîschte */
			ios.list_sel=0;
		break;
		default:
			ios.list_sel=1;	/* 0 ist ".." */
		break;
	}
	list_view();
	sel_sl=-1;
	load_mail();
	if(!loaded) ios.list_sel=-1;
	else format_loaded(odial[TEXT].ob_width);
	mail_slide_set();
	list_slide_set();
	act_mail_list_view();
	s_redraw(&wdial);

	wdial.name="[ASH Emailer] Suchergebnis";
	w_set(&wdial, NAME);

	if(tree[DBTEXT4].ob_spec.tedinfo->te_ptext[0])	/* Nachricht angegeben */
	{/* Text in Suchen-Dialog kopieren */
		rsrc_gaddr(0, SEARCH, &tmp);
		strcpy(tmp[SEARCHSTRING].ob_spec.tedinfo->te_ptext,tree[DBTEXT4].ob_spec.tedinfo->te_ptext);
	}
}

/* ------------------------------------------- */

void do_wtrleiten(WINDOW *win, int ob)
{
	int evnt, mx, my, klicks, dum;

	switch(ob)
	{
		case WTO: case IWTO:
			if(!w_wo_ibut_sel(win, ob)) break;
			w_wo_ibut_unsel(win, ob);
			address_dial(win);
			if(!waddress.open) break;
			w_modal(&waddress, MODAL_ON);
			while(waddress.open) 
				if(!w_ddevent(&evnt,&mx,&my,&dum,&dum,&dum,&klicks))
				{
					if((evnt & MU_BUTTON) && (klicks==2))
						double_click(mx, my);
				}
			w_modal(win, MODAL_ON);
			if(waddress.user) break;
			w_dialcursor(win, D_CUROFF);
			objc_xtedcpy(win->dinfo->tree, EWTO, get_adrname(adr_inf.sel));
			w_objc_draw(win, EWTO, 8, sx,sy,sw,sh);
			w_dialcursor(win, D_CUROFF);
		break;
		
		case WTRABBRUCH:
		case WTROK:
			*(int*)(win->user)=ob;
			w_close(win);
		break;		
	}
}

/* ------------------------------------------- */

void weiterleiten(void)
{
	long	fhl, flen;
	int		fh, res;
	char	bpath[256], npath[256], fbuf[64], *c, *d, *e, *buf, *adr;
	OBJECT *tree;
	INDEXER idx;
	
	rsrc_gaddr(0, WEITERLEITEN, &tree);
	set_ext_type(tree, 0, 2);
_wtr_loop:
	tree[WTROK].ob_state &= (~SELECTED);
	tree[WTRABBRUCH].ob_state &= (~SELECTED);
	if(w_do_opt_dial(tree, do_wtrleiten)==WTRABBRUCH) return;
	if(tree[EWTO].ob_spec.tedinfo->te_ptext[0]==0) return;

	res=adr_resolve(tree[EWTO].ob_spec.tedinfo->te_ptext, &adr);
	if(res==-1) {form_alert(1, gettext(ADR_REKURS)); goto _wtr_loop;}
	if(res==0) {form_alert(1, gettext(NOMEM)); goto _wtr_loop;}
		
	if(db_mode)
	{/* Original-Nachricht LÑnge*/
		flen=fld[ios.list_sel].fspec.finfo.size-sizeof(INDEXER);
	}
	else
	{
		strcpy(bpath, db_path);
	
		switch(ios.list)
		{
			case 0:
				strcat(bpath, "\\PM\\");
			break;
			case 1:
				strcat(bpath, "\\OM\\");
				strcat(bpath, act_fold);
				strcat(bpath, "\\");
			break;
			case 2:
				strcat(bpath, "\\ORD\\");
				strcat(bpath, act_fold);
				strcat(bpath, "\\");
			break;
			case 3:
				strcat(bpath, "\\DEL\\");
			break;
		}
		strcat(bpath, fld[ios.list_sel].fspec.fname);
		fhl=Fopen(bpath, FO_READ);
		if(fhl < 0)
		{
			gemdos_alert(gettext(NOOPEN), fhl);
			if(adr) free(adr);
			return;
		}	
		fh=(int)fhl;
		flen=Fseek(0, fh, 2);
		Fseek(0, fh, 0);
	}

	buf=malloc(flen+1);
	if(buf==NULL) 
	{ form_alert(1, gettext(NOMEM)); if(adr) free(adr); return;}
	if(db_mode)
	{
		idx.db_offset=fld[ios.list_sel].fspec.finfo.offset;
		idx.db_size=fld[ios.list_sel].fspec.finfo.size;
		if(Idx_load_mail(&idx, buf)==0)
		{
			gemdos_alert(gettext(READERR), -1);
			free(buf); if(adr) free(adr);
			return;
		}
	}
	else
	{
		fhl=Fread(fh, flen, buf);
		Fclose(fh);
		if(fhl < 0)
		{
			gemdos_alert(gettext(READERR), fhl);
			free(buf); if(adr) free(adr);
			return;
		}
	}
	buf[flen]=0;

	strcpy(npath, db_path);
	strcat(npath, "\\PM\\");
	strcat(npath, strcpy(fbuf, get_free_file(npath)));
	strcat(npath, ".SND");

	fhl=Fcreate(npath, 0);
	if(fhl < 0)
	{gemdos_alert(gettext(CREATEERR), fhl); free(buf); if(adr) free(adr); return;}
	fh=(int)fhl;
	Fwrite(fh, strlen("Resent-From: <local>\r\n"), "Resent-From: <local>\r\n");
	Fwrite(fh, 4, "To: ");
	if(adr)
	{
		Fwrite(fh, strlen(adr), adr);
		free(adr);
	}
	else
		Fwrite(fh, strlen(tree[EWTO].ob_spec.tedinfo->te_ptext), tree[EWTO].ob_spec.tedinfo->te_ptext);
	Fwrite(fh, 2, "\r\n");
	/* Original-Mail kopieren, dabei "To:" und "Cc:" rauslassen */
	c=stristr(buf, "To:");
	d=stristr(buf, "Cc:");
	if(c||d)
	{
		if(d < c) {e=d; d=c; c=e;}
		if(c)
		{
			*c=0;
			Fwrite(fh, strlen(buf), buf); 
			flen-=strlen(buf);
			++c;
			while(1)
			{
				while(*c && (*c!=13)&&(*c!=10))	{++c; --flen;}
				while(*c && ((*c==13)||(*c==10))) {++c; --flen;}
				if((*c!=' ') && (*c!=9)) break;
			}
		}
		else
			c=buf;
		
		if(d)
		{
			*d=0;
			Fwrite(fh, strlen(c), c); 
			flen-=strlen(c);
			c=d;
			++c;
			while(1)
			{
				while(*c && (*c!=13)&&(*c!=10))	{++c; --flen;}
				while(*c && ((*c==13)||(*c==10))) {++c; --flen;}
				if((*c!=' ') && (*c!=9)) break;
			}
		}
	}
	else c=buf;

	Fwrite(fh, flen, c);
	Fclose(fh);
	free(buf);
	if(ext_type(odial, POPUP) > 0) return;	/* Keine PM-Anzeige */
	/* Aktuelle Liste = PM, neue Datei anfÅgen */
	strcat(fbuf, ".SND");
	strcpy(npath, fld[ios.list_sel].subj);	/* npath nur als Buffer */
	add_to_fld(fbuf, Tgettime(), Tgetdate(), tree[EWTO].ob_spec.tedinfo->te_ptext, npath);
}

void add_to_fld(char *fname, uint time, uint date, char *from, char *subj)
{/* Datei in FLD einfÅgen. fname=Dateiname incl. Suffix!  */
	char	old_sel_file[14];
	FLD	 *xfld;
	long flen, ix=0;
	char	*c;

	/* Aktuell selektierte merken */
	if(fld && fld_c)
		strcpy(old_sel_file, fld[ios.list_sel].fspec.fname);
	else
		old_sel_file[0]=0;
	
	if(fld_bak) {flen=fld_c_bak; xfld=fld_bak;}
	else	{flen=fld_c; xfld=fld;}
	
	/* PrÅfen, ob schon drin */
	while(ix < flen)	
		if(!strcmp(xfld[ix++].fspec.fname, fname)) 
		{/* Gibt's schon->aktualisieren */
			ix--;
			goto _add_entry;
		}
	
	xfld=malloc(sizeof(FLD)*(flen+1));
	if(xfld==NULL) {Bell(); return;}

	if(fld_bak)
	{
		if(fld) free(fld);
		fld=fld_bak; fld_bak=NULL;
		fld_c=fld_c_bak; fld_c_bak=0;
	}
	for(flen=0; flen < fld_c; ++flen)
		xfld[flen]=fld[flen];
	++fld_c;
	if(fld) free(fld);
	fld=xfld;

	ix=fld_c-1;

_add_entry:
	/* Neue Datei eintragen */
	strcpy(fld[ix].fspec.fname, fname);
	fld[ix].ftime=time;
	fld[ix].fdate=date;

	c=&(fname[strlen(fname)-3]);
	if(!strcmp(c, "SND")) fld[ix].ftype=FLD_SND;
	else if(!strcmp(c, "SNT")) fld[ix].ftype=FLD_SNT;
	else if(!strcmp(c, "NEW")) fld[ix].ftype=FLD_NEW;
	else if(!strcmp(c, "RED")) fld[ix].ftype=FLD_RED;
	else fld[ix].ftype=FLD_NON;

	if((c=adr_match(from))==NULL) c=from;
	strncpy(fld[ix].from, c, 64); fld[ix].from[64]=0;
	strcpy(fld[ix].subj, subj);
	make_ascii_fdate(fld[ix].date, fld[ix].fdate, fld[ix].ftime);
	fld[ix].loc_flags &= (~LF_DELAYED);
	fld[ix].root_index=ix;
	sort_by_sel();
	view_by_sel();
	list_slide_set();

	if(ios.list_sel >= fld_c) ios.list_sel=fld_c-1;
	if(ios.list_sel < 0) ios.list_sel=0;
	if(old_sel_file[0] && strcmp(fld[ios.list_sel].fspec.fname, old_sel_file))
	{/* Selektierte Nachricht hat sich geÑndert
		Bsp: Anzeige "Nur ungelesene". Durch hinzufÅgen dieser
		Datei und aktualisieren der Liste verschwinden gelesene */
		sel_sl=-1;
		load_mail();
		if(!loaded)
			ios.list_sel=-1;
		else
			format_loaded(odial[TEXT].ob_width);
		act_mail_list_view();
		mail_slide_set();
		w_objc_draw(&wdial, 0, 8, sx,sy,sw,sh);
	}
	else
		w_objc_draw(&wdial, ALISTE, 8, sx,sy,sw,sh);
}

/* ------------------------------------------- */

void remove_from_fld(char *fname)
{/* Datei aus FLD lîschen. fname=Dateiname incl. Suffix!  */
	FLD	 *xfld;
	long flen, ix=0;

	if(fld_bak) {flen=fld_c_bak; xfld=fld_bak;}
	else	{flen=fld_c; xfld=fld;}
	
	
	/* PrÅfen, ob auch wirklich drin */
	while(ix < flen)	if(!strcmp(xfld[ix++].fspec.fname, fname)) goto _rm_found;
	return;
	
_rm_found:
	/* ix steht jetzt auf Eintrag nach zu Åberschreibendem */
	if(fld_bak)
	{
		if(fld) free(fld);
		fld=fld_bak; fld_bak=NULL;
		fld_c=fld_c_bak; fld_c_bak=0;
	}
	for(flen=ix; flen < fld_c; ++flen)
		fld[flen-1]=fld[flen];
	--fld_c;

	for(flen=0; flen < fld_c; ++flen)
		fld[flen].root_index=flen;
		
	sort_by_sel();
	view_by_sel();
	list_slide_set();

	if(ios.list_sel >= fld_c) ios.list_sel=fld_c-1;
	if(ios.list_sel < 0) ios.list_sel=0;
	sel_sl=-1;
	load_mail();
	if(!loaded)
		ios.list_sel=-1;
	else
		format_loaded(odial[TEXT].ob_width);
	act_mail_list_view();
	mail_slide_set();
	w_objc_draw(&wdial, 0, 8, sx,sy,sw,sh);
}

/* ------------------------------------------- */

void do_aufraeumen(WINDOW *win, int ob)
{
	switch(ob)
	{
		case AFPERSPOP:
			date_popup(win, AFPERSDAT);
		break;
		case AFORDPOP:
			date_popup(win, AFORDDAT);
		break;
		case AFOMPOP:
			date_popup(win, AFOMDAT);
		break;
		
		case AFSTART:
			if(!w_wo_ibut_sel(win, ob)) break;
		case AFABBRUCH:
			*(int*)(win->user)=ob;
			w_close(win);
		break;
	}
}

void clear_path_ord(int check_ig, char *spath, uint olderthan)
{/* Lîscht Dateien *.SND|SNT|NEW|RED im Verzeichnis spath
		olderthan=Nur Dateien lîschen, die Ñlter als <olderthan>
		(im GEMDOS-Format) sind.
		Oder =0, dann alle Dateien lîschen 
		check_ig=0/1: Ordner ÅberprÅfen, ob er auf "Beim AufrÑumen ignorieren" steht
		*/
	DTA		*old=Fgetdta(), dta;
	char	path[256];

	strcpy(path, spath);
	strcat(path, "*.*");
	spath[strlen(spath)-1]=0;
	Dsetpath(spath);
	spath[strlen(spath)]='\\';
	/* Dateien lîschen */
	graf_mouse(BUSYBEE, NULL);
	Fsetdta(&dta);
	if(!Fsfirst(path, FA_SUBDIR))	do
	{ 
		animate(1);
		if((dta.d_attrib & FA_SUBDIR) && (strcmp(dta.d_fname, ".")) && (strcmp(dta.d_fname, "..")))
		{
			strcpy(path, spath);
			strcat(path, dta.d_fname);
			strcat(path, "\\");
			if(! (check_ig && (fld_check_ignore(atol(dta.d_fname)))))
				clear_path_ord(check_ig, path, olderthan);
			spath[strlen(spath)-1]=0;
			Dsetpath(spath);
			spath[strlen(spath)]='\\';
		}
		else if(!(dta.d_attrib & FA_SUBDIR))
		{
			if(((olderthan==0)||(dta.d_date < olderthan)) && ((strstr(dta.d_fname, ".SND"))||(strstr(dta.d_fname, ".SNT"))||(strstr(dta.d_fname, ".NEW"))||(strstr(dta.d_fname, ".RED"))))
			{
				Fdelete(dta.d_fname);
			}
		}
	}while(!Fsnext());
	Fsetdta(old);
	graf_mouse(ARROW, NULL);
}

void clear_path(char *spath, uint olderthan)
{
	clear_path_ord(0, spath, olderthan);
}

void clear_tmp_path(char *spath, uint olderthan)
{/* Lîscht alle Dateien im Verzeichnis spath
		olderthan=Nur Dateien lîschen, die Ñlter als <olderthan>
		(im GEMDOS-Format) sind.
		Oder =0, dann alle Dateien lîschen 
		Arbeitet mit neuen Datei-Funktionen,
		damit auch langnamige AnhÑnge etc. gelîscht werden.
	*/
	long	dhl, err, pl;
	char	file[64], *file2;
	char	path[256];
	XATTR xa;
	
	strcpy(path, spath);
	
	dhl=Dopendir(path, 0);
	if((dhl>>24) == 0xff)
	{/* Fehler beim ôffnen */
		Bell();
		return;
	}

	if(path[strlen(path)-1] != '\\')
		strcat(path, "\\");

	pl=strlen(path);

	do
	{
		animate(1);
		file[0]=0;
		err=Dreaddir(64, dhl, file);
		if(err==0)
		{
			file2=&(file[4]);
			strcpy(&(path[pl]), file2);
			Fxattr(1, path, &xa);
			if( ((xa.mode & S_IFMT)==S_IFDIR) && (strcmp(file2, ".")) && (strcmp(file2, "..")))
				clear_tmp_path(spath, olderthan);
			else if(!((xa.mode & S_IFMT)==S_IFDIR))
			{
				if((olderthan==0)||(xa.cdate < olderthan)) 
					Fdelete(path);
			}
		}
	}while(err==0);
	
	Dclosedir(dhl);
}

void Fmove(char *dst, char *src, char *file)
{
	char	dpath[256], spath[256], newname[64], *c;

	strcpy(newname, get_free_file(dst));
	c=&(file[strlen(file)-1]);
	while(*c!='.')--c;
	strcat(newname, c);
	/* Von src nach tmp unter neuem Namen, dazu src und dst -Name lîschen */	
	strcpy(dpath, db_path);
	strcat(dpath, "\\TMP\\");
	strcpy(spath, dpath);
	strcat(spath, file);
	strcat(dpath, newname);
	Fdelete(spath);
	Fdelete(dpath);
	strcpy(spath, src);
	strcat(spath, file);
	Frename(0, spath, dpath);

	strcpy(spath, dst);
	strcat(spath, newname);
	Frename(0, dpath, spath);
}

void move_path_ord(int check_ig, char *dst, char *spath, uint olderthan)
{/* Verschiebt Dateien *.SND|SNT|NEW|RED von spath nach dst.
		olderthan=Nur Dateien, die Ñlter als <olderthan>
		(im GEMDOS-Format) sind.
		Oder =0, dann alle Dateien
		check_ig=0/1: Ordner ÅberprÅfen, ob er auf "Beim AufrÑumen ignorieren" steht
	*/
		
	DTA		*old=Fgetdta(), dta;
	char	path[256];

	strcpy(path, spath);
	strcat(path, "*.*");
	/* Dateien verschieben */
	graf_mouse(BUSYBEE, NULL);
	Fsetdta(&dta);
	if(!Fsfirst(path, FA_SUBDIR))	do
	{ 
		animate(1);
		if((dta.d_attrib & FA_SUBDIR) && (strcmp(dta.d_fname, ".")) && (strcmp(dta.d_fname, "..")))
		{
			strcpy(path, spath);
			strcat(path, dta.d_fname);
			strcat(path, "\\");
			if(! (check_ig && (fld_check_ignore(atol(dta.d_fname)))))
				move_path_ord(check_ig, dst, path, olderthan);
		}
		else
		{
			if(((olderthan==0)||(dta.d_date < olderthan)) && ((strstr(dta.d_fname, ".SND"))||(strstr(dta.d_fname, ".SNT"))||(strstr(dta.d_fname, ".NEW"))||(strstr(dta.d_fname, ".RED"))))
				Fmove(dst, spath, dta.d_fname);
		}
	}while(!Fsnext());
	Fsetdta(old);
	graf_mouse(ARROW, NULL);
}

void move_path(char *dst, char *spath, uint olderthan)
{
	move_path_ord(0, dst, spath, olderthan);
}

uint text_to_gemdos(char *dat)
{/* dat (ddmmyyyy) in Gemdos-Format umrechnen */
	uint	dd,mm,yy;
	uint	mdate;
	char mem;

	if(strlen(dat)==0) return(0);	/* Kein Datum->ok */
	if(strlen(dat) != 8) return(0);
	mem=dat[2]; dat[2]=0;
	dd=atoi(dat); dat[2]=mem;
	mem=dat[4]; dat[4]=0;
	mm=atoi(&(dat[2])); dat[4]=mem;
	yy=atoi(&(dat[4]))-1980;
	if((dd==0)||(mm==0)||(yy==0)) return(0);
	mdate=yy<<9;
	mdate|=mm<<5;
	mdate|=dd;	
	return(mdate);
}

void db_anime(void)
{
	animate(1);
}

void jetzt_aufraeumen(void)
{
	OBJECT *tree, *anim;
	DINFO dinfo;
	char	bpath[256], npath[256];
	int		run_clearer;
	
	rsrc_gaddr(0, AUFRAEUMEN, &tree);
	rsrc_gaddr(0, AUFR_ANIM, &anim);

	anim[BL1].ob_flags|=HIDETREE;
	anim[BL2].ob_flags|=HIDETREE;
	anim[BL3].ob_flags|=HIDETREE;
	
	lock_menu(omenu);
	w_dinit(&awin);
	dinfo.tree=anim;
	dinfo.support=0;
	dinfo.osmax=0;
	dinfo.odmax=8;
	awin.dinfo=&dinfo;
	w_dial(&awin, D_CENTER);
	dinfo.dservice=NULL;
	dinfo.dedit=0;
	w_open(&awin);
	w_modal(&awin, MODAL_ON);

	animate(0);
	
	strcpy(bpath, db_path);

	/* TMP-Pfad lîschen */
	if(tree[AFTEMP].ob_state & SELECTED)
	{
		strcat(bpath, "\\TMP\\");
		clear_tmp_path(bpath, 0);
		strcpy(bpath, db_path);
	}
	
	if(db_mode)
	{
		DB_ignore_interest=1;
		run_clearer=0;
		if(tree[AFKILL].ob_state & SELECTED)	/* DEL lîschen */
		{
			Idx_list_move(FF_DEL, -1, FF_NON, -1);
			run_clearer=1;
		}
		if(tree[AFDEL].ob_state & SELECTED)
		{/* EndgÅltig lîschen */
			if(tree[AFPERS].ob_state & SELECTED)
				run_clearer|=Idx_move_if(FF_PM, FF_NON, text_to_gemdos(tree[AFPERSDAT].ob_spec.tedinfo->te_ptext), db_anime);
			if(tree[AFORD].ob_state & SELECTED)
				run_clearer|=Idx_move_if(FF_ORD, FF_NON, text_to_gemdos(tree[AFORDDAT].ob_spec.tedinfo->te_ptext), db_anime);
			if(tree[AFOM].ob_state & SELECTED)
				run_clearer|=Idx_move_if(FF_OM, FF_NON, text_to_gemdos(tree[AFOMDAT].ob_spec.tedinfo->te_ptext), db_anime);
			if(run_clearer) 
				Idx_clear(db_anime);
		}
		else
		{/* Nach DEL verschieben */
			/* Zuerst Idx_clear aufrufen (von AFKILL), sonst werden die
			   jetzt nach DEL verschobenen gleich gelîscht */
			if(run_clearer) Idx_clear(db_anime);
			if(tree[AFPERS].ob_state & SELECTED)
				Idx_move_if(FF_PM, FF_DEL, text_to_gemdos(tree[AFPERSDAT].ob_spec.tedinfo->te_ptext), db_anime);
			if(tree[AFORD].ob_state & SELECTED)
				Idx_move_if(FF_ORD, FF_DEL, text_to_gemdos(tree[AFORDDAT].ob_spec.tedinfo->te_ptext), db_anime);
			if(tree[AFOM].ob_state & SELECTED)
				Idx_move_if(FF_OM, FF_DEL, text_to_gemdos(tree[AFOMDAT].ob_spec.tedinfo->te_ptext), db_anime);
		}
		DB_ignore_interest=0;
	}
	else
	{
		if(tree[AFKILL].ob_state & SELECTED)
		{
			strcat(bpath, "\\DEL\\");
			clear_path(bpath, 0);
			strcpy(bpath, db_path);
		}
	
		if(tree[AFDEL].ob_state & SELECTED)
		{/* EndgÅltig lîschen */
			if(tree[AFPERS].ob_state & SELECTED)
			{
				strcat(bpath, "\\PM\\");
				clear_path(bpath, text_to_gemdos(tree[AFPERSDAT].ob_spec.tedinfo->te_ptext));
				strcpy(bpath, db_path);
			}
			if(tree[AFORD].ob_state & SELECTED)
			{
				strcat(bpath, "\\ORD\\");
				clear_path_ord(1, bpath, text_to_gemdos(tree[AFORDDAT].ob_spec.tedinfo->te_ptext));
				strcpy(bpath, db_path);
			}
			if(tree[AFOM].ob_state & SELECTED)
			{
				strcat(bpath, "\\OM\\");
				clear_path(bpath, text_to_gemdos(tree[AFOMDAT].ob_spec.tedinfo->te_ptext));
				strcpy(bpath, db_path);
			}
			goto _jl_done;
		}
		
		/* Verschieben */
		strcpy(npath, db_path);
		strcat(npath, "\\DEL\\");
		if(tree[AFPERS].ob_state & SELECTED)
		{
			strcat(bpath, "\\PM\\");
			move_path(npath, bpath, text_to_gemdos(tree[AFPERSDAT].ob_spec.tedinfo->te_ptext));
			strcpy(bpath, db_path);
		}
		if(tree[AFORD].ob_state & SELECTED)
		{
			strcat(bpath, "\\ORD\\");
			move_path_ord(1, npath, bpath, text_to_gemdos(tree[AFORDDAT].ob_spec.tedinfo->te_ptext));
			strcpy(bpath, db_path);
		}
		if(tree[AFOM].ob_state & SELECTED)
		{
			strcat(bpath, "\\OM\\");
			move_path(npath, bpath, text_to_gemdos(tree[AFOMDAT].ob_spec.tedinfo->te_ptext));
			strcpy(bpath, db_path);
		}
	}
	
_jl_done:
	while((Kbshift(-1) & (4|8))==(4|8))
	{
		animate(1);
		evnt_timer(50,0);
	}
	w_modal(&awin, MODAL_OFF);
	w_kill(&awin);
	unlock_menu(omenu);
}

int check_date(char *dat)
{/* dat (ddmmyyyy) in Gemdos-Format umrechnenbar 0=Nein/1=Ja */
	uint	dd,mm,yy;
	char mem;

	if(strlen(dat)==0) return(1);	/* Kein Datum->ok */
	if(strlen(dat) != 8) return(0);
	mem=dat[2]; dat[2]=0;
	dd=atoi(dat); dat[2]=mem;
	mem=dat[4]; dat[4]=0;
	mm=atoi(&(dat[2])); dat[4]=mem;
	if((atoi(&(dat[4]))-1980) < 0) return(0);
	yy=atoi(&(dat[4]))-1980;
	if((dd==0)||(mm==0)) return(0);
	if(dd>31) return(0);
	if(mm>12) return(0);
	if(yy> 119) return(0);	/* Gemdos kann nicht mehr */
	return(1);
}

int check_dates(OBJECT *tree)
{/* 0=Fehlerhafter Eintrag incl. Alert */
	if(tree[AFPERS].ob_state & SELECTED)
		if(check_date(tree[AFPERSDAT].ob_spec.tedinfo->te_ptext)==0)
		{
			form_alert(1, gettext(WRONG_DATE));
			return(0);
		}
	if(tree[AFORD].ob_state & SELECTED)
		if(check_date(tree[AFORDDAT].ob_spec.tedinfo->te_ptext)==0)
		{
			form_alert(1, gettext(WRONG_DATE));
			return(0);
		}
	if(tree[AFOM].ob_state & SELECTED)
		if(check_date(tree[AFOMDAT].ob_spec.tedinfo->te_ptext)==0)
		{
			form_alert(1, gettext(WRONG_DATE));
			return(0);
		}
	return(1);
}

void aufraeumen(void)
{
	OBJECT *tree;
	
	rsrc_gaddr(0, AUFRAEUMEN, &tree);
_auf_again:
	tree[AFSTART].ob_state &= (~SELECTED);
	tree[AFABBRUCH].ob_state &= (~SELECTED);
	if(w_do_opt_dial(tree, do_aufraeumen)==AFABBRUCH) return;

	if( (tree[AFPERS].ob_state & SELECTED)||
			(tree[AFORD].ob_state & SELECTED)||
			(tree[AFOM].ob_state & SELECTED)
		)
	{		if(tree[AFDEL].ob_state & SELECTED)
			{	if(form_alert(1, gettext(AFKILLSURE))==2) return;}
			else
			{	if(form_alert(1, gettext(AFDELSURE))==2) return;}
	}

	if(check_dates(tree)==0) goto _auf_again;
	
	jetzt_aufraeumen();
	
	reload_actual();
}

void reload_actual(void)
{
	/* Falls in Ordner/Gruppen-öbersicht, fertig */
	if(((ios.list==1)||(ios.list==2)) && ((fld==NULL)||(fld[0].ftype != FLD_BAK)))
		return;
	
	/* Aktuelle Liste neu Aufbauen */
	if(fld_bak)
	{
		ios.list_sel=fld_bak[ios.list_sel].root_index;
		if(fld) free(fld);
		fld=fld_bak; fld_bak=NULL;
		fld_c=fld_c_bak; fld_c_bak=0;
	}
	reload_act_list();
	sort_by_sel();
	view_by_sel();
	if(ios.list_sel >= fld_c) ios.list_sel=fld_c-1;
	if(ios.list_sel < 0) ios.list_sel=0;
	if(fld && (fld[0].ftype==FLD_BAK)) ios.list_sel=1;
	sel_sl=-1;
	load_mail();
	if(!loaded) ios.list_sel=-1;
	else format_loaded(odial[TEXT].ob_width);
	mail_slide_set();
	act_mail_list_view();
	list_slide_set();
	s_redraw(&wdial);
}
