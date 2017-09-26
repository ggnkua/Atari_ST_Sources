#include <ec_gem.h>
#include <stic.h>
#include "io.h"
#include "ioglobal.h"
#include "iversion.h"
#include "indexer.h"

extern int rform_alert(int def_but, const char *alert);

char	*reg_active="rMa*paTB*R#-n";
char	*reg_name="nnnnnnnnnnnnnnnnnnnnnnnnnnnnnn";
char	*reg_firma="ffffffffffffffffffffffffffffff";
char	*reg_serial="ssssssssss";

extern WINDOW anh_win;
/* -------------------------------------- */

void code_name(char *ps,char *name)
{
    int i, len;
    len = (int) strlen(name);
    for (i=0; i < len; i++)
    {
        ps[i] = 255 ^name[i];
    }
    ps[len] = 0;
}

int checkser(char *sernum)
{
    long ser,ch;
    char s[7];
    int i;
    for(i=2;i<8;i++)
        s[i-2]=sernum[i];
    s[6]='\0';
    ser=atol(s); ch=sernum[9]-48;
    if(((ser&5)==ch)&&
        (strncmp(sernum,"37",2)==0)&&
        (sernum[8]=='0')&&
        (strcmp(sernum+2,"00000000")!=0))
        return(1);

    return(0); 
}

int check_reg(void)
{
	OBJECT *tree;
	char	buf[20];

	if(reg_active[strlen(reg_active)-1]!='n')
	{
		rsrc_gaddr(0, INFOTREE, &tree);
	
		code_name(buf, reg_serial);
		if(!(checkser(buf)))
		{
			rform_alert(1,"[3][Not registered.][Cancel]");
			return(0);
		}
		
		code_name(tree[USERNAME].ob_spec.tedinfo->te_ptext, reg_name);
		code_name(tree[USERFIRMA].ob_spec.tedinfo->te_ptext, reg_firma);
	}
	else
	{
		rsrc_gaddr(0, INFOTREE, &tree);
	
		strcpy(tree[USERNAME].ob_spec.tedinfo->te_ptext, "BETAVERSION");
		strcpy(tree[USERFIRMA].ob_spec.tedinfo->te_ptext, "");
	}

	return(1);
}

/* -------------------------------------- */

void init_setup(void)
{
	int a, phbox, extnd[8];
	
	ios.magic='IOSU';

	ios.version=SETUP_VERSION;
	ios.set_size=sizeof(IO_SETUP);
	
	ios.wx=ios.wy=ios.ww=ios.wh=-1;
	ios.ewx=ios.ewy=ios.eww=ios.ewh=-1;

	ios.hide_list=ios.hide_msg=0;
	ios.from_len=150;
	ios.subj_len=150;
	
	ios.view_mask=0;
	ios.sort_by=2;	/* Datum */
	ios.s_up_down=0;
	ios.list=0;
	ios.list_off=0;
	ios.list_sel=0;
	ios.teiler=-1;

	strcpy(ios.atx_save_path, "x:\\");
	Dgetpath(&(ios.atx_save_path[3]), 0);
	ios.atx_save_path[0]=(char)Dgetdrv()+'A';
	if(ios.atx_save_path[strlen(ios.atx_save_path)-1]!='\\')
		strcat(ios.atx_save_path, "\\");
	strcat(ios.atx_save_path, "*.*");
	strcpy(ios.atx_load_path, ios.atx_save_path);
	strcpy(ios.file_open_path, ios.atx_save_path);
	strcpy(ios.file_merge_path, ios.atx_save_path);
	strcpy(ios.file_save_as_path, ios.atx_save_path);
	ios.autotausch=0;
	ios.autoicon=1;
	ios.autodial=1;
	ios.pllrequest=1;
	ios.pllsize=20;
	ios.server_del=1;
	ios.newslist_days=30;
	ios.news_head=1;
	ios.news_new=1;
	ios.news_num=20;
	strcpy(ios.headinfo, "Resent-From:, Resent-To:, From:, To:, Cc:, Date:");
	ios.efid=ios.mfid=ios.lfid=vst_font(handle, -1);	/* Sollte System-ID liefern... */
	ios.efsiz=ios.mfsiz=ios.lfsiz=vst_point(handle, 10, &a, &a, &a, &phbox);
	ios.efhi=ios.mfhi=ios.lfhi=phbox;
	vst_effects(handle, 0);
	vst_alignment(handle, 0, 3, &a, &a);	/* Bottom Line Alignment */
	vqt_extent(handle, ">", extnd);
	ios.eqwi=extnd[2];
	
	ios.lsndcol=ios.lsntcol=ios.lnewcol=ios.lredcol=ios.lubkcol=1;
	ios.mtextcol=ios.etextcol=1;
	ios.quotecol=15;
	ios.urlcol=4;
	ios.ecol=ios.mcol=0;
	if(sw_mode)
		ios.lcol=0;
	else
		ios.lcol=8;
	ios.ed_qcopy=1;
	ios.ed_tabspc=ios.m_tabspc=3;
	strcpy(ios.sig1, "");
	strcpy(ios.sig2, "");
	strcpy(ios.sig3, "");
	ios.eyes_on=0;
	ios.sigeyes_on=0;
	ios.om_exchange=1;
	ios.pm_exchange=1;
	ios.show_pm_list=0;
	
	ios.cut_pers=0;
	ios.cut_pnum=74;
	ios.cut_oeff=1;
	ios.cut_onum=74;
	
	ios.msg_img_path[0]=0;
	ios.lst_img_path[0]=0;
	ios.ed_img_path[0]=0;
	
	ios.ignore_crlf=0;
	
	ios.anh_open=0;
	ios.anh_wy=-1;
	
	ios.mf2id=-1;
	ios.mf2siz=ios.mfsiz;
	ios.ef2id=-1;
	ios.ef2siz=ios.efsiz;
	
	ios.tausch_info=1;

	ios.auto_import=0;
	
	ios.real_smile=1;
	
	ios.all_text=0;
	
	ios.no_grp_msg_id=0;
	
	ios.permanent_reply=0;
	ios.perm_reply_adr[0]=0;
	ios.perm_reply_in_groups=0;
	
	ios.fake_news_from=0;
	ios.fake_news_adr[0]=0;
	
	ios.show_sig_warning=1;
}	

/* -------------------------------------- */

void update_dbase(void)
{
	long	fhl;
	char	path[256], bpath[256];
	int		fh, fhout;
	DTA		*old=Fgetdta(), dta;
	FLD		fldb;

	/*  Erstens: */
	/*	Ordner-Datei anlegen, falls noch nicht vorhanden.
			Datei: db_path\ORD\ORD.IDX
			Aufbau: FLD_Array
			Belegte Felder: fld.fspec.fname=Ordnername im Filesystem
											fld.ftype=FLD_FLD
											fld.from=Ordnername als Text (Usereingabe)
	*/

	strcpy(path, db_path);
	strcat(path, "\\ORD\\ORD.IDX");
	fhl=Fopen(path, FO_READ);
	if(fhl >= 0) {Fclose((int)fhl); goto _update1_;}
	fhl=Fcreate(path, 0);
	fhout=(int)fhl;
	
	strcpy(bpath, db_path);
	strcat(bpath, "\\ORD");
	strcpy(path, bpath);
	strcat(path, "\\*.*");

	/* Dateien laden */
	Dsetpath(bpath);
	strcpy(path, bpath);
	strcat(path, "\\*.ORD");
	Fsetdta(&dta);
	if(!Fsfirst(path, 0))	do
	{
		strcpy(fldb.fspec.fname, dta.d_fname);
		if(strchr(fldb.fspec.fname, '.'))
			*(strchr(fldb.fspec.fname, '.'))=0;
		fldb.ftype=FLD_FLD;
		fhl=Fopen(dta.d_fname, FO_READ); fh=(int)fhl;
		if(fhl >= 0)
		{
			Fread(fh, 66, fldb.from);
			Fclose(fh);
			Fwrite(fhout, sizeof(FLD), &fldb);
			Fdelete(dta.d_fname);
		}
	}while(!Fsnext());
	Fsetdta(old);
	Fclose(fhout);

_update1_:
	return;
}

int exist(char *file)
{/* PrÅft, ob <file> in db_path liegt. Return: 0=Nein, 1=Ja */
	char	tp[256];
	long	ret;
	
	strcpy(tp, db_path); strcat(tp, "\\");
	strcat(tp, file);
	ret=Fopen(tp, FO_READ);
	if(ret > -1)
	{
		Fclose((int)ret);
		return(1);
	}
	return(0);
}

int init_dbase(void)
{
	long	ret;
	char	tp[256], np[256];
	
	strcpy(db_path, "x:\\");
	/* Mal wird der Pfad mit, mal ohne fÅhrenden '\' geliefert */
	Dgetpath(&(db_path[3]), 0);
	if(db_path[3]=='\\') Dgetpath(&(db_path[2]), 0);
	db_path[0]=(char)Dgetdrv()+'A';
	if(db_path[strlen(db_path)-1]!='\\')
		strcat(db_path, "\\");
	strcat(db_path, "DATABASE");

	if(Dsetpath(db_path) < 0)
		if((ret=Dcreate(db_path)) < 0)
		{
			gemdos_alert("Kann /DATABASE/ nicht anlegen.", ret);
			return(0);
		}
	if(Dsetpath(db_path) < 0)
	{
		gemdos_alert("Kann /DATABASE/ nicht îffnen.", ret);
		return(0);
	}
	/* Bîser Crash beim letzten Umsortieren? */
	/* Es wird von IDX nach NID und DAT nach NDT kopiert,
		 danach IDX und DAT gelîscht und NID und NDT umbenannt */
	/* Szenario 1: Mittendrin abgebrochen, alle vier existieren */
	if(exist("DBASE.IDX") && exist("DBASE.DAT"))
	{
		strcpy(tp, db_path); strcat(tp, "\\DBASE.NID");
		Fdelete(tp);
		strcpy(tp, db_path); strcat(tp, "\\DBASE.NDT");
		Fdelete(tp);
	}
	else
	{/* Szenario 2: Alte gelîscht, aber neue nicht umbenannt */
		/* Sichergehen, daû beide gelîscht: */
		if(exist("DBASE.NID") && exist("DBASE.NDT"))
		{
			strcpy(tp, db_path); strcat(tp, "\\DBASE.IDX");
			Fdelete(tp);
			strcpy(tp, db_path); strcat(tp, "\\DBASE.DAT");
			Fdelete(tp);
			strcpy(tp, db_path); strcat(tp, "\\DBASE.NID");
			strcpy(np, db_path); strcat(tp, "\\DBASE.IDX");
			Frename(0, tp, np);
			strcpy(tp, db_path); strcat(tp, "\\DBASE.NDT");
			strcpy(np, db_path); strcat(tp, "\\DBASE.DAT");
			Frename(0, tp, np);
		}
		else
		{
			/* Szenario 3: Alles Scheiûe, Kopier-Dateien lîschen */
			strcpy(tp, db_path); strcat(tp, "\\DBASE.NID");
			Fdelete(tp);
			strcpy(tp, db_path); strcat(tp, "\\DBASE.NDT");
			Fdelete(tp);
		}
	}
	
	/* IDX/DAT existiert schon? */
	db_mode=0;
	if(exist("DBASE.IDX") && exist("DBASE.DAT"))
		db_mode=1;
	else if(exist("DBASE.DAT"))
	{/* Kopier-Dateien lîschen und Reparatur-Versuch unternehmen */
		strcpy(tp, db_path); strcat(tp, "\\DBASE.NID");	Fdelete(tp);
		strcpy(tp, db_path); strcat(tp, "\\DBASE.NDT");	Fdelete(tp);
		if(Check_dbase() < 2) db_mode=1;	/* Datenbank ist ok oder wurde erfolgreich repariert */
	}
	else
	{
		/* Alles lîschen */
		strcpy(tp, db_path); strcat(tp, "\\DBASE.IDX");	Fdelete(tp);
		strcpy(tp, db_path); strcat(tp, "\\DBASE.DAT");	Fdelete(tp);
		strcpy(tp, db_path); strcat(tp, "\\DBASE.NID");	Fdelete(tp);
		strcpy(tp, db_path); strcat(tp, "\\DBASE.NDT");	Fdelete(tp);
	}
		
	/* Persînlicher Ordner */
	strcpy(tp, db_path);
	strcat(tp, "\\PM");
	if(Dsetpath(tp) < 0)
		if((ret=Dcreate(tp)) < 0)
		{
			gemdos_alert("Kann DATABASE/PM/ nicht anlegen.", ret);
			return(0);
		}
	if(Dsetpath(tp) < 0)
	{
		gemdos_alert("Kann DATABASE/PM/ nicht îffnen.", ret);
		return(0);
	}
	/* ôffentlicher Ordner */
	strcpy(tp, db_path);
	strcat(tp, "\\OM");
	if(Dsetpath(tp) < 0)
		if((ret=Dcreate(tp)) < 0)
		{
			gemdos_alert("Kann DATABASE/OM/ nicht anlegen.", ret);
			return(0);
		}
	if(Dsetpath(tp) < 0)
	{
		gemdos_alert("Kann DATABASE/OM/ nicht îffnen.", ret);
		return(0);
	}
	/* ôffentliche zu sendende Ordner */
	strcpy(tp, db_path);
	strcat(tp, "\\OM\\SEND");
	if(Dsetpath(tp) < 0)
		if((ret=Dcreate(tp)) < 0)
		{
			gemdos_alert("Kann DATABASE/OM/SEND/ nicht anlegen.", ret);
			return(0);
		}
	if(Dsetpath(tp) < 0)
	{
		gemdos_alert("Kann DATABASE/OM/SEND/ nicht îffnen.", ret);
		return(0);
	}
	/* Eingeordnet-Ordner */
	strcpy(tp, db_path);
	strcat(tp, "\\ORD");
	if(Dsetpath(tp) < 0)
		if((ret=Dcreate(tp)) < 0)
		{
			gemdos_alert("Kann DATABASE/ORD/ nicht anlegen.", ret);
			return(0);
		}
	if(Dsetpath(tp) < 0)
	{
		gemdos_alert("Kann DATABASE/ORD/ nicht îffnen.", ret);
		return(0);
	}
	/* Gelîscht-Ordner */
	strcpy(tp, db_path);
	strcat(tp, "\\DEL");
	if(Dsetpath(tp) < 0)
		if((ret=Dcreate(tp)) < 0)
		{
			gemdos_alert("Kann DATABASE/DEL/ nicht anlegen.", ret);
			return(0);
		}
	if(Dsetpath(tp) < 0)
	{
		gemdos_alert("Kann DATABASE/DEL/ nicht îffnen.", ret);
		return(0);
	}
	/* TMP-Ordner */
	strcpy(tp, db_path);
	strcat(tp, "\\TMP");
	if(Dsetpath(tp) < 0)
		if((ret=Dcreate(tp)) < 0)
		{
			gemdos_alert("Kann DATABASE/TMP/ nicht anlegen.", ret);
			return(0);
		}
	if(Dsetpath(tp) < 0)
	{
		gemdos_alert("Kann DATABASE/TMP/ nicht îffnen.", ret);
		return(0);
	}
	
	update_dbase();
	
	return(1);
}

/* -------------------------------------- */

void rsrc_iconfix(OBJECT *tree)
{/* Farbicons-Textlabel entfernen und Userdef setzen */
	int a=0;
	
	while(!(tree[a].ob_flags & LASTOB))
	{
		++a;
		if(obj_type(tree, a)==G_CICON)
			tree[a].ob_spec.ciconblk->monoblk.ib_wtext=0;
		else if(obj_type(tree, a) == G_USERDEF)
			tree[a].ob_spec.userblk->ub_code=user_ob;
		else if(obj_type(tree, a) == G_IBOX)
		{if(tree[a].ob_state & SELECTED) unselect_3d(tree, a);}
	}
}

/* -------------------------------------- */

void init_info_rsrc(void)
{
	OBJECT *tree;
	
	rsrc_gaddr(0, INFOTREE, &tree);
	rsrc_iconfix(tree);
	strcpy(tree[INFOVERSION].ob_spec.free_string, EMAILER_VERSION);
	strcpy(tree[INFODATE].ob_spec.free_string, __DATE__);

	rsrc_gaddr(0, CHECKDBASE, &tree);
	rsrc_iconfix(tree);
}

void rsrc_init(void)
{
	OBJECT *tree;
	int a, phbox, extend[8];
	uchar	cw[2];
	STIC		*cp;
		
	if(find_cookie('StIc', (long*)(&cp))==1)
	{
		rsrc_gaddr(0,STICICON,&tree);
		cp->ext_icon(ap_id, &(tree[BIGICON]), &(tree[SMALLICON]), 1);
	}

	/* Zeichensatzgrîûen feststellen */
	if(ios.magic=='IOSU')
	{
		ios.lfid=vst_font(handle, ios.lfid);
		ios.lfsiz=vst_point(handle, ios.lfsiz, &a, &a, &a, &phbox);
		ios.lfhi=phbox;
		ios.mfid=vst_font(handle, ios.mfid);
		ios.mfsiz=vst_point(handle, ios.mfsiz, &a, &a, &a, &phbox);
		ios.mfhi=phbox;
		ios.efid=vst_font(handle, ios.efid);
		ios.efsiz=vst_point(handle, ios.efsiz, &a, &a, &a, &phbox);
		ios.efhi=phbox;
	}
	/* Zeichenbreiten fÅr Nachrichtenfenster: */
	vst_font(handle, ios.mfid);
	vst_point(handle, ios.mfsiz, &a, &a, &a, &a);
	cw[1]=0;
	for(a=0; a < 256; ++a)
	{
		cw[0]=a;
		vqt_extent(handle, (char*)cw, extend);
		ios.mcwidth[a]=extend[2];
	}
	ios.mcwidth[0]=ios.mcwidth[1]=ios.mcwidth[FIRST_FAT]=0;
	ios.mcwidth[9]=ios.m_tabspc*P_TABWIDTH;
	/* Zeichenbreiten fÅr Editorfenster */
	vst_font(handle, ios.efid);
	vst_point(handle, ios.efsiz, &a, &a, &a, &a);
	for(a=0; a < 256; ++a)
	{
		cw[0]=a;
		vqt_extent(handle, (char*)cw, extend);
		ios.ecwidth[a]=extend[2];
	}
	ios.ecwidth[13]=8;	/* Bitblock fÅr CR */
	ios.ecwidth[9]=ios.ed_tabspc*P_TABWIDTH;
	
	odial[ABSWIDTH].ob_spec.tedinfo->te_ptext=ovorl[ABSLEN].ob_spec.tedinfo->te_ptext;
	odial[BTRWIDTH].ob_spec.tedinfo->te_ptext=ovorl[BTRLEN].ob_spec.tedinfo->te_ptext;
	odial[DATWIDTH].ob_spec.tedinfo->te_ptext=ovorl[DATLEN].ob_spec.tedinfo->te_ptext;
	set_abs_btr_dat();
	odial[ABSSORT].ob_x=getlen(ABSLEN);
	odial[BTRSORT].ob_x=getlen(BTRLEN);
	odial[DATSORT].ob_x=getlen(DATLEN);
	odial[ABSSORT].ob_flags |= HIDETREE;
	odial[BTRSORT].ob_flags |= HIDETREE;
	odial[DATSORT].ob_flags |= HIDETREE;
	if(ios.s_up_down)
	{
		odial[ABSSORT].ob_spec.bitblk=getob(ABSTEIGEND)->ob_spec.bitblk;
		odial[BTRSORT].ob_spec.bitblk=getob(ABSTEIGEND)->ob_spec.bitblk;
		odial[DATSORT].ob_spec.bitblk=getob(ABSTEIGEND)->ob_spec.bitblk;
	}
	else
	{
		odial[ABSSORT].ob_spec.bitblk=getob(AUFSTEIGEND)->ob_spec.bitblk;
		odial[BTRSORT].ob_spec.bitblk=getob(AUFSTEIGEND)->ob_spec.bitblk;
		odial[DATSORT].ob_spec.bitblk=getob(AUFSTEIGEND)->ob_spec.bitblk;
	}
	/* Slider einrÅcken */
	++odial[UP].ob_y; ++odial[BAR].ob_y; ++odial[DOWN].ob_y;
	++odial[UP].ob_x; ++odial[BAR].ob_x; ++odial[DOWN].ob_x;
	/* BAR verkleinern */
	odial[BAR].ob_y+=3; odial[BAR].ob_height-=6;
	/* Rahmen schmaler */
	odial[LISTE].ob_width-=3; odial[FLISTE].ob_width-=3;
	/* Index-Rahmen rundrum eins mehr weil Rahmen nur ein Pixel
	   haben sollte! */
	--odial[ALISTE].ob_x; --odial[ALISTE].ob_y;
	odial[ALISTE].ob_width+=2; odial[ALISTE].ob_height+=2;
	odial[FLISTE].ob_x=1; odial[FLISTE].ob_y=1;
	set_abs_btr_dat();

	odial[PUT_ADR].ob_x=odial[SWAP_IGN_CRLF].ob_x=odial[KOPF].ob_width-(odial[PUT_ADR].ob_width+4);
		
	/* Popup-Vorauswahl */	
	if(ios.magic=='IOSU')
	{
		set_ext_type(odial, POPUP, ios.list);
		rsrc_gaddr(0, LISTPOPUP, &tree);
		strcpy(odial[POPUP].ob_spec.free_string, &(tree[ios.list*2+1].ob_spec.free_string[2]));
		odial[IPOPUP].ob_spec.ciconblk=tree[ios.list*2+2].ob_spec.ciconblk;
	}
	else
		set_ext_type(odial, POPUP, 0);

	/* Debug-Akne verstecken */
	odial[SHOWORG].ob_flags |= HIDETREE;	
	
	/* Umbruch-Icon setzen */
	if(!sw_mode)
	{
		if(ios.ignore_crlf)
			odial[SWAP_IGN_CRLF].ob_state |= SELECTED;
		else
			odial[SWAP_IGN_CRLF].ob_state &= (~SELECTED);
	}

	/* Farbicon-Label entfernen und Userdef setzen */
	rsrc_iconfix(odial);

	unselect_3d(odial, ABSENDER);
	unselect_3d(odial, BETREFF);
	
	rsrc_gaddr(0, LISTPOPUP, &tree);
	rsrc_iconfix(tree);

	rsrc_gaddr(0, VORLAGE, &tree);
	rsrc_iconfix(tree);
	tree[0].ob_x=tree[0].ob_y=0;
	tree[LISTICONFRAME].ob_x=tree[LISTICONFRAME].ob_y=0;
	tree[SMILEFRAME].ob_x=tree[SMILEFRAME].ob_y=0;
	tree[ANHFRAME].ob_x=tree[ANHFRAME].ob_y=0;
	tree[AWDFRAME].ob_x=tree[AWDFRAME].ob_y=0;
	tree[ITRFRAME].ob_x=tree[ITRFRAME].ob_y=0;
	tree[HIDDEN].ob_spec.free_string[0]=0;
	tree[HIDDEN].ob_flags|=HIDETREE;
	
	rsrc_gaddr(0, SET_FARBE, &tree);
	rsrc_iconfix(tree);

	rsrc_gaddr(0, SET_ANZEIGE, &tree);
	rsrc_iconfix(tree);
	objc_xted(tree, ANZHEAD, 128, 0);

	rsrc_gaddr(0, SET_INTERNET, &tree);
	rsrc_iconfix(tree);

	rsrc_gaddr(0, SET_SIG, &tree);
	rsrc_iconfix(tree);

	rsrc_gaddr(0, EDITOR, &tree);
	rsrc_iconfix(tree);

	rsrc_gaddr(0, EDANHPOP, &tree);
	rsrc_iconfix(tree);

	rsrc_gaddr(0, MATXPOPUP, &tree);
	rsrc_iconfix(tree);
	
	rsrc_gaddr(0, L_ANHANG, &tree);
	rsrc_iconfix(tree);

	rsrc_gaddr(0, DOWNLOADS, &tree);
	rsrc_iconfix(tree);

	rsrc_gaddr(0, AUFR_ANIM, &tree);
	rsrc_iconfix(tree);

	rsrc_gaddr(0, WEITERLEITEN, &tree);
	rsrc_iconfix(tree);
	objc_xted(tree, EWTO, 256, 0);

	rsrc_gaddr(0, IMPORTING, &tree);
	rsrc_iconfix(tree);

	rsrc_gaddr(0, IMPORT_ERR, &tree);
	rsrc_iconfix(tree);

	rsrc_gaddr(0, SET_DBASE, &tree);
	rsrc_iconfix(tree);

	rsrc_gaddr(0, SPECFUNC, &tree);
	rsrc_iconfix(tree);

	rsrc_gaddr(0, FALERT, &tree);
	rsrc_iconfix(tree);

	rsrc_gaddr(0, REPLYTO, &tree);
	rsrc_iconfix(tree);
	objc_xted(tree, EREPLYTO, 63, 0);
	
	rsrc_gaddr(0, SET_ADRESSES, &tree);
	rsrc_iconfix(tree);
	objc_xted(tree, PERM_REPLY_ADR, 63, 0);
	objc_xted(tree, FAKE_ADR, 63, 0);

	rsrc_gaddr(0, NEW_SIG_ALERT, &tree);
	rsrc_iconfix(tree);
	
	rsrc_gaddr(0, ORDNER, &tree);
	rsrc_iconfix(tree);
	objc_xted(tree, FLDNAME, 64, 0);
	xted(tree, FLDNAME)->ascii_low=31;
	/* Slider eins EinrÅcken */
	--tree[FLDUP].ob_x; --tree[FLDBAR].ob_x; --tree[FLDDOWN].ob_x;
	/* BAR verkleinern */
	tree[FLDBAR].ob_y+=3; tree[FLDBAR].ob_height-=6;

	rsrc_gaddr(0, ONLINE, &tree);
	rsrc_iconfix(tree);
	unselect_3d(tree, CONFRAME);
	
	rsrc_gaddr(0, PREVONLINE, &tree);
	rsrc_iconfix(tree);
		
	rsrc_gaddr(0, PM_LIST, &tree);
	rsrc_iconfix(tree);
	/* Slider eins EinrÅcken */
	--tree[PMLUP].ob_x; --tree[PMLBAR].ob_x; --tree[PMLDOWN].ob_x;
	/* BAR verkleinern */
	tree[PMLBAR].ob_y+=3; tree[PMLBAR].ob_height-=6;
	
	rsrc_gaddr(0, SCROLLPOP, &tree);
	/* BAR verkleinern */
	tree[SPBAR].ob_y+=3; tree[SPBAR].ob_height-=6;
	
	rsrc_gaddr(0, ADRESSEN, &tree);
	rsrc_iconfix(tree);
	objc_xted(tree, ADRNAME, 64, 0);
	objc_xted(tree, ADRADR, 256, 0);
	xted(tree, ADRNAME)->ascii_low=31;
	xted(tree, ADRADR)->ascii_low=31;
	/* Slider eins EinrÅcken */
	--tree[ADRUP].ob_x; --tree[ADRBAR].ob_x; --tree[ADRDOWN].ob_x;
	/* BAR verkleinern */
	tree[ADRBAR].ob_y+=3; tree[ADRBAR].ob_height-=6;
	/* Icons auf Vorlage rooten */
	for(a=IADR1; a <= IADRLAST; a+=2)
		tree[a].ob_spec.iconblk=ovorl[IADR_SINGLE].ob_spec.iconblk;

	rsrc_gaddr(0, GRUPPEN, &tree);
	rsrc_iconfix(tree);
	/* Slider eins EinrÅcken */
	--tree[GRPUP].ob_x; --tree[GRPBAR].ob_x; --tree[GRPDOWN].ob_x;
	/* BAR verkleinern */
	tree[GRPBAR].ob_y+=3; tree[GRPBAR].ob_height-=6;
	/* Icons auf Vorlage rooten */
	for(a=IGRP1; a <= IGRPLAST; a+=2)
		tree[a].ob_spec.iconblk=ovorl[GRP_ABO].ob_spec.iconblk;
	
	rsrc_gaddr(0, FILTER, &tree);
	rsrc_iconfix(tree);
	/* Slider eins EinrÅcken */
	--tree[FILUP].ob_x; --tree[FILBAR].ob_x; --tree[FILDOWN].ob_x;
	/* BAR verkleinern */
	tree[FILBAR].ob_y+=3; tree[FILBAR].ob_height-=6;
	/* Icons auf Vorlage rooten */
	for(a=IFIL1; a <= IFILLAST; a+=(IFIL2-IFIL1))
		tree[a].ob_spec.iconblk=ovorl[IC_EMPFAENGER].ob_spec.iconblk;
	for(a=IIFIL1; a <= IIFILLAST; a+=(IFIL2-IFIL1))
		tree[a].ob_spec.iconblk=ovorl[IC_NGET].ob_spec.iconblk;
	tree[ONLINE_FIL].ob_state |= DISABLED;

	rsrc_gaddr(0, SEARCH, &tree);
	tree[SEARCHSTRING].ob_spec.tedinfo->te_ptext[0]=0;
	tree[SEGRKL].ob_state |= SELECTED;

	rsrc_gaddr(0, DBSEARCH, &tree);
	rsrc_iconfix(tree);
	tree[DBPOP2].ob_flags |= HIDETREE;
	/* Vor-Selektieren */
	tree[DBSNDSNT].ob_state |= SELECTED;
	tree[DBNEWRED].ob_state |= SELECTED;
	/* Edit-Felder leeren */
	tree[DBTEXT1].ob_spec.tedinfo->te_ptext[0]=0;
	tree[DBTEXT2].ob_spec.tedinfo->te_ptext[0]=0;
	tree[DBTEXT3].ob_spec.tedinfo->te_ptext[0]=0;
	tree[DBTEXT4].ob_spec.tedinfo->te_ptext[0]=0;
	tree[DBTEXT5].ob_spec.tedinfo->te_ptext[0]=0;
	tree[DBTEXT6].ob_spec.tedinfo->te_ptext[0]=0;

	rsrc_gaddr(0, AUFRAEUMEN, &tree);
	rsrc_iconfix(tree);
	tree[AFKILL].ob_state |= SELECTED;
	tree[AFTEMP].ob_state |= SELECTED;
	tree[AFDEL].ob_state |= SELECTED;
	tree[AFPERSDAT].ob_spec.tedinfo->te_ptext[0]=0;
	tree[AFORDDAT].ob_spec.tedinfo->te_ptext[0]=0;
	tree[AFOMDAT].ob_spec.tedinfo->te_ptext[0]=0;
	
	/* Farb-Popups */
	rsrc_gaddr(0, COL2POPUP, &tree);
	a=-1;
	do{	++a;
		if(obj_type(tree, a) == G_USERDEF)
		{	tree[a].ob_spec.userblk->ub_code=user_ob;
			set_ext_type(tree, a, a-1);}
	}while(!(tree[a].ob_flags & LASTOB));
	rsrc_gaddr(0, COL4POPUP, &tree);
	a=-1;
	do{	++a;
		if(obj_type(tree, a) == G_USERDEF)
		{	tree[a].ob_spec.userblk->ub_code=user_ob;
			set_ext_type(tree, a, a-1);}
	}while(!(tree[a].ob_flags & LASTOB));
	rsrc_gaddr(0, COL8POPUP, &tree);
	a=-1;
	do{	++a;
		if(obj_type(tree, a) == G_USERDEF)
		{	tree[a].ob_spec.userblk->ub_code=user_ob;
			set_ext_type(tree, a, a-1);}
	}while(!(tree[a].ob_flags & LASTOB));
	
	/* Minimale Breite des Popups wird im ext_type des Listen-
		 rahmens vermerkt */
	set_ext_type(odial, ALISTE, getlen(MINPOP));
	
	/* MenÅ */
	rsrc_gaddr(0, MENU, &tree);
	switch(ios.view_mask)
	{
		case 0:	menu_icheck(tree, MVALLE, 1); break;
		case 1:	menu_icheck(tree, MVSNDSNT, 1); break;
		case 2:	menu_icheck(tree, MVSND, 1); break;
		case 3:	menu_icheck(tree, MVSNT, 1); break;
		case 4:	menu_icheck(tree, MVNEWRED, 1); break;
		case 5:	menu_icheck(tree, MVRED, 1); break;
		case 6:	menu_icheck(tree, MVNEW, 1); break;
	}
	switch(ios.sort_by)
	{
		case 0: menu_icheck(tree, MVFROM, 1); break;
		case 1: menu_icheck(tree, MVSUBJ, 1); break;
		case 2: menu_icheck(tree, MVDATE, 1); break;
	}
	
	crmfdb.fd_addr=ovorl[CRIND].ob_spec.bitblk->bi_pdata;
	crmfdb.fd_w=16; crmfdb.fd_h=8;
	crmfdb.fd_wdwidth=1;
	crmfdb.fd_stand=0;
	crmfdb.fd_nplanes=1;
	crmfdb.fd_r1=crmfdb.fd_r2=crmfdb.fd_r3=0;

	tabmfdb=crmfdb;
	tabmfdb.fd_addr=ovorl[TABIND].ob_spec.bitblk->bi_pdata;
}

/* -------------------------------------- */

void win_init(void)
{
	rsrc_gaddr(0, ORDNER, &ofolder);
	dfolder.tree=ofolder;
	dfolder.support=0;
	dfolder.dservice=dial_folder;
	dfolder.osmax=0;
	dfolder.odmax=8;
	w_dinit(&wfolder);

	rsrc_gaddr(0, ADRESSEN, &oaddress);
	daddress.tree=oaddress;
	daddress.support=0;
	daddress.dservice=dial_address;
	daddress.osmax=0;
	daddress.odmax=8;
	w_dinit(&waddress);

	rsrc_gaddr(0, GRUPPEN, &ogroup);
	dgroup.tree=ogroup;
	dgroup.support=0;
	dgroup.dservice=dial_group;
	dgroup.osmax=0;
	dgroup.odmax=8;
	w_dinit(&wgroup);
	objc_xted(ogroup, GRPNAME, 64, 0);

	rsrc_gaddr(0, FILTER, &ofilter);
	dfilter.tree=ofilter;
	dfilter.support=0;
	dfilter.dservice=dial_filter;
	dfilter.osmax=0;
	dfilter.odmax=8;
	w_dinit(&wfilter);

	w_dinit(&anh_win);
}