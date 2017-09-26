#include <ec_gem.h>
#include <gscript.h>
#include "io.h"
#include "ioglobal.h"
#include "imgload.h"
#include "anhang.h"
#include "indexer.h"
#include "gscript.h"
#include "atarierr.h"
#include "addrbook.h"
/* -------------------------------------- */
/* Globals */

int	sx,sy,sw,sh;

WINDOW	wdial, wfolder, waddress, wgroup, wfilter;
DINFO		ddial, dfolder, daddress, dgroup, dfilter;
OBJECT	*odial, *omenu, *ovorl, *ofolder, *oaddress, *ogroup, *ofilter;

MFDB		crmfdb, tabmfdb;

MFDB 		msg_img={NULL,0,0,0,0,0,0,0,0},
				lst_img={NULL,0,0,0,0,0,0,0,0},
				ed_img={NULL,0,0,0,0,0,0,0,0};

char		db_path[256];
char		act_fold[16];

FLD				*fld=NULL, *fld_bak=NULL;
long			fld_c=0, fld_c_bak=0;
long			sel_sl, sel_sc, sel_el, sel_ec; /* Selektion in Message-Anzeige. lines fangen bei 0 an, Zeichen bei 1. 
																							Zeichen 0 bedeutet: Kein Zeichen in Endzeile selektiert. FÅr Startzeile sind c 0 und 1 das gleiche */
LOADED_MAIL	loadm={NULL, 0, NULL, 0, NULL};
char			*loaded=NULL;
long			llen=0, llines=0, lloff=0;

IO_SETUP	ios;
int				sw_mode, db_mode, param_start=0;

int				autotausch_on_startup;

FOLDER_DIAL		fld_inf={0,0,NULL,0};
ADDRESS_DIAL	adr_inf={0,0,NULL,0,0};
GROUP_DIAL    grp_inf={0,NULL,0,NULL,0,0};
FILTER_DIAL		fil_inf={0,0,NULL,0,0,0};
/* -------------------------------------- */

extern void show_info(void);
extern void spec_funcs(void);
extern int rform_alert(int def_but, const char *alert);
extern void add_file_as_anhang(WINDOW *win, char *path);
extern int count_anhang(WINDOW *win);
extern int Check_folders(void);

/* Protos */

void	dial_win(void);
void	double_click(int x, int y);
void	do_double(int ob);
void	double_text(void);
void	do_dial(int ob);
void	marrowed(WINDOW *win, int *pbuf);	
void	mvslid(WINDOW *win, int *pbuf);
void	msized(WINDOW *win, int *pbuf);
void	mfulled(WINDOW *win);
void	up_liste(void);
void	down_liste(void);
void	slide_liste(void);
void	page_liste(void);

void	list_popup(void);
void	ganze_liste(void);
void	ganze_nachricht(void);
void	set_teiler(int mx);
void	teilen(void);
int		set_width(void);
void	set_max_abswidth(void);
void	set_max_btrwidth(void);
void	set_max_datwidth(void);
void	double_liste(void);
void	open_list_ob(long newsel);
void	new_select(void);
void	new_mark(void);
void	new_list_sel(long newsel);

void	fold_view(void);
void	list_view(void);

void	other_message(int *pbuf); 				/* Unbekannte Messages */
void	menu_dispatch(int title, int ob);	/* MN_SELECTED */

/* -------------------------------------- */

int run_shutdown(void)
{
	WINDOW *win;
	int a, mem;
	
	if(globalmodal) {Bell(); return(0);}
	
	/* Editoren schlieûen */
	a=0;
	while((win=w_list(a))!=NULL)
	{
		a=1;
		if(ext_type(win->dinfo->tree, 0)!=1) continue;
		win->topped(win);
		w_redraw(win, sx,sy,sw,sh, 0);
		eclosed(win);
		if(win->open) return(0);
	}
	
	/* Dialoge schlieûen (Adreûbuch etc.) */
	a=0; mem=ios.anh_open;
	while((win=w_list(a))!=NULL)
	{
		a=1;
		if(win==&wdial) continue;
		win->closed(win);
		if(win->open) return(0);
	}
	ios.anh_open=mem;
	
	/* Fertig */
	return(1);
}

void show_logo(int mode)
{/* 1=On, 0=Off */
	OBJECT *tree;

	rsrc_gaddr(0, INFOTREE, &tree);
	tree[0].ob_x=sx+(sw/2-tree[1].ob_width/2-tree[1].ob_x);
	tree[0].ob_y=sy+(sh/2-tree[1].ob_height/2-tree[1].ob_y);
	switch(mode)
	{
		case 0:	/* Aus */
			form_dial(FMD_FINISH, tree[0].ob_x, tree[0].ob_y, tree[1].ob_width, tree[1].ob_height, tree[0].ob_x, tree[0].ob_y, tree[1].ob_width, tree[1].ob_height);
			wind_update(END_UPDATE);
		break;
		case 1:
			wind_update(BEG_UPDATE);
			form_dial(FMD_START, tree[0].ob_x, tree[0].ob_y, tree[1].ob_width, tree[1].ob_height, tree[0].ob_x, tree[0].ob_y, tree[1].ob_width, tree[1].ob_height);
			objc_draw(tree, 1, 8, sx,sy,sw,sh);
		break;
		case 2:	/* Nochmal drÅber malen */
			objc_draw(tree, 1, 8, sx,sy,sw,sh);
		break;
	}
}

/* -------------------------------------- */

int main(int argc, const char *argv[])
{
	/*long	dum;
	if(find_cookie('MagX', &dum)==0)
	{
		rform_alert(1, "[3][ASH Emailer needs MagiC!][Cancel]");
		return(0);
	}
	*/

	Pdomain(1);
	e_start_as(ACC|PRG,"ASH Emailer");
	va_init("Emailer");
	gemscript=gemscript_init();
	ap_info.gunknown=other_message;
	ap_info.menu=menu_dispatch;
	if(ap_type & (ACC|PRG))
	{
		uses_vdi();
		uses_txwin();
		/* S/W-Modus? */
		if(wwork_out[13] < 16) sw_mode=1;
		else	sw_mode=0;
	
		if(rsrc_load("emailer.rsc")==0)
		{
			rform_alert(1,"[3][Error reading RSC.|File not found or|insufficient memory.][Cancel]");
			goto fin;
		}
		if(check_reg()==0) goto fin;
		init_info_rsrc();

		wind_get(0,WF_WORKXYWH,&sx,&sy,&sw,&sh);
		show_logo(1);
		if(init_dbase())
		{
			ios.magic=0;
			init_setup();
			load_setup();
			sel_sl=-1;
			if(vq_gdos())	vst_load_fonts(handle, 0);
			if((argc > 1) && (!strnicmp((char*)(argv[1]), "mailto:", 7)))
			{
				pbuf[0]=VA_START;
				pbuf[1]=ap_id; pbuf[2]=0;
				*(char**)&(pbuf[3])=(char*)(argv[1]);
				appl_write(ap_id, 16, pbuf);
				param_start=1;
			}
			dial_win();
			if(vq_gdos()) vst_unload_fonts(handle, 0);
		}
		else
			show_logo(0);
		
	}

fin:
	rsrc_free();
	e_quit();
	return(0);
}

/* -------------------------------------- */

void set_abs_btr_dat(void)
{
	odial[ABSWIDTH].ob_width=ios.from_len;
	odial[BTRWIDTH].ob_x=ios.from_len;
	odial[DATWIDTH].ob_x=ios.from_len+ios.subj_len;

	odial[BTRWIDTH].ob_width=odial[DATWIDTH].ob_width=0;
	odial[BTRWIDTH].ob_flags|=HIDETREE;
	odial[DATWIDTH].ob_flags|=HIDETREE;
	if(odial[ABSWIDTH].ob_width > odial[LISTE].ob_width)
	{ odial[ABSWIDTH].ob_width=odial[LISTE].ob_width; return;}
	
	odial[BTRWIDTH].ob_width=ios.subj_len;
	if(odial[BTRWIDTH].ob_x + odial[BTRWIDTH].ob_width > odial[LISTE].ob_width)
	{
		odial[BTRWIDTH].ob_width=odial[LISTE].ob_width-odial[BTRWIDTH].ob_x;
		if(odial[BTRWIDTH].ob_width < 0)
			odial[BTRWIDTH].ob_width=0;
		else
			odial[BTRWIDTH].ob_flags &= (~HIDETREE);
		return;
	}
	odial[BTRWIDTH].ob_flags &= (~HIDETREE);
	odial[DATWIDTH].ob_width=odial[LISTE].ob_width-odial[DATWIDTH].ob_x;
	if(odial[DATWIDTH].ob_width < 0)
		odial[DATWIDTH].ob_width=0;
	else
		odial[DATWIDTH].ob_flags &= (~HIDETREE);
}

/* -------------------------------------- */

void prev_comment(void)
{
	long ix, slen;
	char	*c, *d;

	if(fld==NULL) return;
	if(fld[0].ftype > FLD_BAK) return; 	/* Nicht fÅr Ordner- und Gruppenlisten! */
	c=fld[ios.list_sel].subj;
	if(!strnicmp(c, "Re:", 3)) {c+=3; while(*c==' ')++c;}
	slen=strlen(c); while(c[slen-1]==' ') --slen;
	ix=ios.list_sel-1;
	while(ix >= 0)
	{
		d=fld[ix].subj;
		if(!strnicmp(d, "Re:", 3)) {d+=3; while(*d==' ')++d;}
		if(!strnicmp(d, c, slen))
		{new_list_sel(ix); return;}
		--ix;
	}
	Bell();
}

void next_comment(void)
{
	long ix, slen;
	char	*c, *d;

	if(fld==NULL) return;
	if(fld[0].ftype > FLD_BAK) return; 	/* Nicht fÅr Ordner- und Gruppenlisten! */
	c=fld[ios.list_sel].subj;
	if(!strnicmp(c, "Re:", 3)) {c+=3; while(*c==' ')++c;}
	slen=strlen(c); while(c[slen-1]==' ') --slen;
	ix=ios.list_sel+1;
	while(ix < fld_c)
	{
		d=fld[ix].subj;
		if(!strnicmp(d, "Re:", 3)) {d+=3; while(*d==' ')++d;}
		if(!strnicmp(d, c, slen))
		{new_list_sel(ix); return;}
		++ix;
	}
	Bell();
}

void main_keys(int swt, int key)
{	
	long ix;
	
	/* Nachrichten scrollen */
	/* Home / Shift Home ? */
	if((key>>8)==71)
	{
		if(swt&3)	/* Mit Shift -> Textende */
			pbuf[4]=1000;
		else	/* Ohne Shift -> Textanfang*/
			pbuf[4]=0;
		mvslid(&wdial, pbuf);
	}

	/* Oben? [8] */
	if( ((key>>8)==72) || ((key>>8)==104))
	{
		if(swt & 3) 	/* Mit Shift */
			pbuf[4]=WA_UPPAGE;
		else					/* Ohne Shift */
			pbuf[4]=WA_UPLINE;
		marrowed(&wdial, pbuf);
	}
	
	/* Unten? [2] */
	if(((key>>8)==80) || ((key>>8)==110))
	{
		if(swt & 3) 	/* Mit Shift */
			pbuf[4]=WA_DNPAGE;
		else					/* Ohne Shift */
			pbuf[4]=WA_DNLINE;
		marrowed(&wdial, pbuf);
	}

	/* Andere Funktionen */	
	
	/* F1-F4 */
	if(((key>>8)>=59)&&((key>>8)<=62))
	{/* Popup 1-4 */
		switch_list((key>>8)-59);
	}
	
	/* Backspace */
	if((key&255)==8)
	{/* ZurÅck zu öbersicht */
		if(fld && fld[0].ftype==FLD_BAK)
			new_list_sel(0);		
	}

	/* CTRL+Links? */
	if((key>>8)==115)
	{
		if(odial[FTEXT].ob_flags & HIDETREE) /* Nachricht wieder sichtbar machen */
			ganze_liste();
		else if(!(odial[ALISTE].ob_flags & HIDETREE)) /* Liste verstecken */
			ganze_nachricht();
		else
			Bell();
	}
	/* CTRL+Rechts? */
	if((key>>8)==116)
	{
		if(odial[ALISTE].ob_flags & HIDETREE) /* Liste wieder sichtbar machen */
			ganze_nachricht();
		else if(!(odial[FTEXT].ob_flags & HIDETREE)) /* Nachricht verstecken */
			ganze_liste();
		else
			Bell();
	}

	/* Links? [4] */
	if(((key>>8)==75)||((key>>8)==106))
	{/* Vorherige Nachricht */
		if(ios.list_sel <= 0) {return;}
		if(fld && fld[ios.list_sel-1].ftype==FLD_BAK) {return;}
		new_list_sel(ios.list_sel-1);
	}
	/* Rechts? [6] */
	if(((key>>8)==77)||((key>>8)==108))
	{/* NÑchste Nachricht */
		if(ios.list_sel >= fld_c) {Bell(); return;}
		new_list_sel(ios.list_sel+1);
	}
	
	/* Delete? */
	if((key&255)==127)
	{/* Selektion lîschen */
		loeschen();
	}
	
	/* Return? */
	if((key&255)==13)
	{/* Ordner/Gruppe oder sonstwas îffnen */
		open_list_ob(ios.list_sel);
	}
	
	/* Space? */
	if((key&255)==' ')
	{/* NÑchste ungelesene */
		if(fld==NULL) return;
		ix=ios.list_sel+1;
		if(fld[0].ftype > FLD_BAK)
		{/* In Ordnern und Gruppen zu erster gehen, die ungelesene Nachrichten enthÑlt */
			while(ix < fld_c)
			{
				if(fld[ix].loc_flags & LF_UNREAD)
				{ new_list_sel(ix); return;}
				++ix;
			}
		}
		else while(ix < fld_c)
		{
			if(fld[ix].ftype==FLD_NEW)
			{ new_list_sel(ix); return;}
			++ix;
		}
		Bell();
	}
	
	/* Plus? */
	if((key&255)=='+')
	{/* NÑchster Kommentar */
		next_comment();
	}

	/* Minus? */
	if((key&255)=='-')
	{/* Vorheriger Kommentar */
		prev_comment();
	}
}

/* -------------------------------------- */

void main_closed(WINDOW *win)
{
	/* Ist schon ein Alert offen? (Oder modales Dialogfenster) */
	if(globalmodal) {Bell(); return;}

	if(form_alert(1, gettext(REALQUIT))==2) return;
	if(run_shutdown()==0) return;
	w_close(win);
}

/* -------------------------------------- */

void dial_win(void)
{
	int evnt, dum, mx, my, but, klicks, swt, key, oswt, okey;
	long mem_sel;
	WINDOW	*twin;
			
	rsrc_gaddr(0, READ, &odial);
	rsrc_gaddr(0, MENU, &omenu);
	rsrc_gaddr(0, VORLAGE, &ovorl);
	
	menu_bar(omenu, 1);
	/* Leider fÅhlt sich MagiC hier genîtigt, die
		 Fensterrahmen neu zu zeichnen */
	show_logo(2);
	
	rsrc_init();
	win_init();
	if(load_inf_folders()==-1) {menu_bar(omenu, 0); show_logo(0); return;}
	if(load_addrbook()==-1) {menu_bar(omenu, 0); show_logo(0); return;}
	if(load_grouplist()==-1) {menu_bar(omenu, 0); show_logo(0); return;}
	if(load_filters()==-1) {menu_bar(omenu, 0); show_logo(0); return;}
	reload_filter_folders();
	/* Default-Liste laden */
	mem_sel=ios.list_sel;
	load_act_list();
	sort_by_sel();
	view_by_sel();
	list_slide_set();
	list_view();
	ios.list_sel=mem_sel;
	load_mail();
	if(!loaded) ios.list_sel=-1;
	act_mail_list_view();

	show_logo(0);
 	
	w_dinit(&wdial);
	ddial.tree=odial;
	ddial.support=0;
	ddial.osmax=0;
	ddial.odmax=8;
	wdial.dinfo=&ddial;
	w_kdial(&wdial, D_CENTER, MOVE|NAME|BACKDROP|CLOSE|FULL|SIZE|UPARROW|DNARROW|VSLIDE);
	wdial.closed=main_closed;
	wdial.sized=msized;
	wdial.arrowed=marrowed;
	wdial.vslid=mvslid;
	wdial.fulled=mfulled;
	ddial.dservice=do_dial;
	ddial.dedit=0;

	if((ios.wy > 0) && (ios.ww > 0) && (ios.wh > 0))
	{/* Fensterpos gespeichert */
		if((ios.wx+ios.ww <= sx+sw) && (ios.wy+ios.wh <= sy+sh))	/* Paût */
		{	wdial.wx=ios.wx; wdial.wy=ios.wy; wdial.ww=ios.ww; wdial.wh=ios.wh; }
		else if((ios.ww < sw) && (ios.wh < sh)) /* Passend machen */
		{
			if(ios.wx+ios.ww > sx+sw) ios.wx=(sx+sw-ios.ww)/2;
			if(ios.wy+ios.wh > sy+sh) ios.wy=(sy+sh-ios.wh)/2;
			wdial.wx=ios.wx; wdial.wy=ios.wy; wdial.ww=ios.ww; wdial.wh=ios.wh;
		}
		/* Ansonsten zu groû, tja */
	}

	if((ios.wy > 0) && (ios.ww > 0) && (ios.wh > 0))
		if((ios.wx+ios.ww <= sx+sw) && (ios.wy+ios.wh <= sy+sh))
		{
			pbuf[0]=WM_MOVED; pbuf[1]=ap_id; pbuf[2]=0; pbuf[3]=wdial.whandle;
			pbuf[4]=ios.wx; pbuf[5]=ios.wy; pbuf[6]=ios.ww; pbuf[7]=ios.wh;
			w_dialmoved(&wdial, pbuf);
			msized(&wdial, pbuf);
		}
	if(ios.teiler > 0)	set_teiler(ios.teiler);
	if(ios.hide_list) ganze_nachricht();
	else if(ios.hide_msg) ganze_liste();
	w_open(&wdial);
	
	format_loaded(odial[TEXT].ob_width);
	mail_slide_set();

	if(ios.anh_open) 
	{
		anhang_win();
		w_top(&wdial);
	}

	if(ios.autotausch && (!param_start))
	{
		w_redraw(&wdial, sx, sy, sw, sh, 0);
		autotausch_on_startup=1; /* Flag setzen, damit kein Dialog angezeigt wird */
		online();
		autotausch_on_startup=0;
	}
	else if(db_mode && ios.auto_import)	/* Bei online() wird sowieso importiert */
	{
		Import_files(1);
		reload_actual();
	}
		
	while(wdial.open)
		if(!w_ddevent(&evnt,&mx,&my,&but,&swt,&key,&klicks))
		{
			if((evnt & MU_BUTTON) && (klicks==2))
				double_click(mx, my);
			while(evnt & MU_KEYBD)
			{
				oswt=swt; okey=key;
				if(menu_key(omenu, (int)((uint)key>>8), swt, &mx, &my))
				{
					menu_tnormal(omenu, mx, 0);
					menu_dispatch(mx, my);
					goto key_killer;
				}
				dum=wind_gtop();
				twin=w_find(dum);
				if(twin && (ext_type(twin->dinfo->tree,0)==1))
					w_edit_input(w_find(dum), swt, key);
				else if(twin==&wdial)
					main_keys(swt, key);

key_killer:
				while( ((evnt=evnt_multi(MU_KEYBD|MU_TIMER,0,0,0,
									0,0,0,0,0,0,0,0,0,0,
									&dum,0,0,&dum,&dum,&dum,&swt,&key,&dum))
									 & MU_KEYBD)
								&&
								((key==okey) && (swt==oswt))
							);
			}
		}

	save_setup();
			
	w_kill(&wdial);

	menu_bar(omenu, 0);
}

/* -------------------------------------- */

void double_click(int x, int y)
{
	WINDOW *win;
	int wh, ob;

	ob=wind_gtop();	
	/* Falls nicht Anhang-Fenster muû Doppelgeklicktes
	   das oberste sein (sonst Theater mit objc_draw falls
	   irgendwas verdeckt ist) */
	if(((wh=wind_find(x,y))!=ob) && (wh != anh_win.whandle))return;
	if(wh!=wdial.whandle)
	{
		/* Editor-Fenster? */
		win=w_find(wh);
		if(win && (ext_type(win->dinfo->tree, 0)==1))
			ed_do_double(win);
		/* Adressbuch? */
		else if((waddress.open)&&(wh==waddress.whandle))
		{
			if((ob=objc_find(oaddress, 0, 8, x,y)) > -1)
				do_adr_double(ob);
		}
		else if((anh_win.open)&&(wh==anh_win.whandle))
		{
			if((ob=objc_find(anh_win.dinfo->tree, 0, 8, x,y)) > -1)
				do_anh_double(ob);
		}
		return;
	} 
	if((ob=objc_find(odial, 0, 8, x,y)) > -1)
		do_double(ob);
}

/* -------------------------------------- */

void do_double(int ob)
{
	switch(ob)
	{
		case LISTE:
			double_liste();
		break;
		case ABSWIDTH:
			set_max_abswidth();
		break;
		case BTRWIDTH:
			set_max_btrwidth();
		break;
		case DATWIDTH:
			set_max_datwidth();
		break;
		case TEXT:
			double_text();
		break;
	}
}

/* -------------------------------------- */

void	do_dial(int ob)
{
	int mx, my, ox, oy, dum;
		
	switch(ob)
	{
		case NEU: case INEU:
			if(w_ibut_sel(ob))
			{
				ed_new_file();
				w_ibut_unsel(ob);
			}
		break;
		case ANTWORT: case IANTWORT:
			if(w_ibut_sel(ob))
			{
				beantworten();
				w_ibut_unsel(ob);
			}
		break;
		case BEITRAG: case IBEITRAG:
			if(w_ibut_sel(ob))
			{
				beitrag();
				w_ibut_unsel(ob);
			}
		break;

		case LOESCHEN: case ILOESCHEN:
			if(w_ibut_sel(ob))
			{
				loeschen();
				w_ibut_unsel(ob);
			}
		break;

		case ORDNEN: case IORDNEN:
			if(w_ibut_sel(ob))
			{
				verschieben();
				w_ibut_unsel(ob);
			}
		break;
				
		case SUCHEN: case ISUCHEN:
			if(w_ibut_sel(ob))
			{
				lock_menu(omenu);
				dbsearch();
				unlock_menu(omenu);
				w_ibut_unsel(ob);
			}
		break;

		case POPUP:
		case IPOPUP:
			list_popup();
		break;
				
		case TEILER:
			teilen();
		break;
		case LINKS:
			ganze_nachricht();
			w_unsel(&wdial, ob);
		break;
		case RECHTS:
			ganze_liste();
			w_unsel(&wdial, ob);
		break;
		
		case ABSWIDTH: case ABSSORT:
		case BTRWIDTH: case BTRSORT:
		case DATWIDTH: case DATSORT:
			if(set_width()) break; 
			/* Nicht auf Teiler geklickt */
			if(obj_type(odial, ob)==G_IMAGE) --ob;
			if(w_ibut_sel(ob)==0) break;
			switch(ob)
			{
				case ABSWIDTH: sort_by_from(); break;
				case BTRWIDTH: sort_by_subj(); break;
				case DATWIDTH: sort_by_date(); break;
			}
			w_ibut_unsel(ob);
			w_objc_draw(&wdial, ALISTE, 8, sx,sy,sw,sh);
		break;
		
		case LISTE:
		/* Neue Selektion */
			new_select();
		break;
		case UP:
			up_liste();
		break;
		case DOWN:
			down_liste();
		break;
		case SLIDE:
			slide_liste();
		break;
		case BAR:
			page_liste();
		break;

		case ANHANG:
			atx_select();
		break;
		
		case SHOWORG:

			graf_mouse(BUSYBEE, NULL);
			graf_mouse(ARROW, NULL);
		break;
		
		case SWAP_IGN_CRLF:
			if(ios.ignore_crlf)
			{
				ios.ignore_crlf=0;
				load_mail();
			}
			else ios.ignore_crlf=1;
			format_loaded(odial[TEXT].ob_width);
			mail_slide_set();
			w_objc_draw(&wdial, FTEXT, 8, sx,sy,sw,sh);
			if(!sw_mode)
			{
				if(ios.ignore_crlf)
					odial[SWAP_IGN_CRLF].ob_state |= SELECTED;
				else
					odial[SWAP_IGN_CRLF].ob_state &= (~SELECTED);
				w_objc_draw(&wdial, SWAP_IGN_CRLF, 8, sx,sy,sw,sh);
			}
			do
			{
				graf_mkstate(&mx, &my, &ox, &dum);
			}while(ox & 1);
		break;

		/* "Windrose" */
		case ROSE:	/* Mittenrein... */
			graf_mkstate(&mx, &my, &dum, &dum);
			objc_offset(odial, ROSE, &ox, &oy);
			mx-=ox; my-=oy;
			if(my > mx) /* unten/links Dreieck */
			{
				if(my > -mx+odial[ROSE].ob_height)	/* Unten */
					next_comment();
				else																/* Links */
				{	if(ios.list_sel <= 0) break;
					if(fld && fld[ios.list_sel-1].ftype==FLD_BAK) break;
					new_list_sel(ios.list_sel-1);
				}
			}
			else /* oben/rechts Dreieck */
			{
				if(my > -mx+odial[ROSE].ob_height)	/* Rechts */
				{	if(ios.list_sel >= fld_c) {Bell(); break;}
					new_list_sel(ios.list_sel+1);
				}
				else																/* Oben */
					prev_comment();
			}
		break;

		case PUT_ADR:
		/* Absender ins Adreûbuch */
			put_abs_to_adrbook();
		break;
				
		case TEXT:
		/* Neue Markierung */
			new_mark();
		break;
	}
}

/* -------------------------------------- */

int get_char(long line, int x_pix)
{
	int		a, extnd[8];
	long	cnt=0;
	char	*w=loaded, mem;

	if(x_pix < 0) return(0);
		
	if(w) while(cnt < line)
	{	w+=lstrlen(w)+1;	++cnt;}
	
	a=-1;
	do
	{
		++a;
		if((w[a]<=RP_TAB)&&(w[a]>=0)) break;	/* > 127 ist wegen char < 0 */
		mem=w[a]; w[a]=0;
		mail_extent(w, extnd);
		w[a]=mem;
	}while(extnd[2] < x_pix);
	return(a);
}

/* -------------------------------------- */

void new_mark(void)
{
	int 	mx, memx, my, mb, kb, ox, oy, vis_line, ry1, ry2;
	long	ol=-1, oc=-1, ml, mc, il, ic;

	if(loaded==NULL) return;

	pbuf[0]=WM_ARROWED; pbuf[3]=wdial.whandle;	
	objc_offset(odial, TEXT, &ox, &oy);
	ox+=MESSAGE_OFFSET;
	vis_line=(odial[TEXT].ob_height/ios.mfhi)*ios.mfhi;
	graf_mkstate(&mx, &my, &mb, &kb);
		mx-=ox; my-=oy;
	if((kb & 3) && (sel_sl > -1))
	{
		il=sel_sl;
		ic=sel_sc;
	}
	else
	{
		il=lloff+(long)my/ios.mfhi;
		if(il >= llines) il=llines-1;
		ic=get_char(il, mx);
	}

	memx=mx;

	do
	{
		graf_mkstate(&mx, &my, &mb, &kb);
		mx-=ox; my-=oy;
		if(my < 0) { my=0;  pbuf[4]=WA_UPLINE; marrowed(&wdial, pbuf);}
		if(my > vis_line) { my=vis_line;  pbuf[4]=WA_DNLINE; marrowed(&wdial, pbuf);}
		ml=lloff+(long)my/ios.mfhi;
		if(ml >= llines) ml=llines-1;
		if(mx > odial[TEXT].ob_width) mx=odial[TEXT].ob_width;
		mc=get_char(ml, mx);
		if((ml==ol) && (mc==oc)) continue;
		if(ml < il)
		{
			sel_sl=ml; sel_sc=mc; sel_el=il; sel_ec=ic;
		}
		else if(ml > il)
		{
			sel_sl=il; sel_sc=ic; sel_el=ml; sel_ec=mc;
		}
		else	/* ml==il */
		{
			if((memx==mx)||((mc==0)&&(ic==0)))
				sel_sl=-1;
			else
			{
				sel_sl=sel_el=il;
				if(mc < ic)
				{ sel_sc=mc; sel_ec=ic; }
				else
				{ sel_sc=ic; sel_ec=mc; }
			}
		}
		ry1=(int)(ol-lloff)*ios.mfhi+oy;
		ry2=(int)(ml-lloff)*ios.mfhi+oy;
		if(ry2 < ry1) {my=ry2;ry2=ry1;ry1=my;}
		if(ol==-1)
			w_objc_draw(&wdial, TEXT, 8, sx,sy,sw,sh);
		else
			w_objc_draw(&wdial, TEXT, 8, sx,ry1,sw,ry2-ry1+ios.mfhi);
		ol=ml; oc=mc;
	}while(mb & 3);
}

/* -------------------------------------- */
void main_url_check(void)
{
	long		cnt, mss=sel_sc, mse=sel_ec;
	char		*w;

	if(sel_sl == -1) return;

	w=loaded; cnt=0;
	if(w) while(cnt < sel_sl)
	{	w+=lstrlen(w)+1;	++cnt;}
	w+=sel_sc; if(sel_sc) --w;
	
	if(strnicmp(w, "http://", 7) && strnicmp(w+1, "http://", 7) &&
		 strnicmp(w, "ftp://", 6) && strnicmp(w+1, "ftp://", 6) &&
		 strnicmp(w, "mailto:", 7) && strnicmp(w+1, "mailto:", 7)) return;
	if( (!strnicmp(w+1, "http://", 7)) || (!strnicmp(w+1, "ftp://", 6)) || (!strnicmp(w+1, "mailto:", 7)))
		++sel_sc;
	if(*(w+sel_ec-1) == ')') --sel_ec;
	if((sel_sc!=mss)||(sel_ec!=mse))
		w_objc_draw(&wdial, TEXT, 8, sx,sy,sw,sh);

	mail_copy();
	clip_url();
}

void double_text(void)
{
	int 	mx, my, dum, ox, oy;
	int		x1, x2;
	int		a, extnd[8];
	long	il, cnt=0, slen=0;
	char	*w=loaded, mem;

	if(loaded==NULL) return;

	objc_offset(odial, TEXT, &ox, &oy);
	ox+=MESSAGE_OFFSET;
	graf_mkstate(&mx, &my, &dum, &dum);
		mx-=ox; my-=oy;

	/* Zeile feststellen */
	il=lloff+(long)my/ios.mfhi;
	if(il >= llines) return;
	if(mx < 0) return;

	/* Pointer auf Zeile holen */		
	if(w) while(cnt < il)
	{	slen+=lstrlen(w)+1; w+=lstrlen(w)+1;	++cnt;}
	
	/* Zeichen feststellen */
	a=-1;
	do
	{
		++a;
		if((w[a]<=RP_TAB)&&(w[a]>=0)) break;	/* > 127 ist wegen char < 0 */
		mem=w[a]; w[a]=0;
		mail_extent(w, extnd);
		w[a]=mem;
	}while(extnd[2] < mx);

	/* Wortanfang */
	if(a < 0) a=0;
	x1=a;
	while((x1>0) && (w[x1-1]!=' ') && (w[x1-1]!=9)) --x1;
	/* Wortende */
	x2=a;
	while((w[x2+1]!=' ') && (w[x2+1]!=9))
	{
		if(w[x2+1]==RP_MIN)
		{
			if(slen < llen) {x2=0; slen+=lstrlen(w)+1; w+=lstrlen(w)+1; continue;}
			else break;
		}
		if((w[x2+1]==RP_CRLF)||(w[x2+1]==RP_CR)||(w[x2+1]==RP_SPC)||(w[x2+1]==RP_TAB)) break;
		++slen; ++x2;
	}

	++x1; ++x2;	/* Markierung zÑhlt ab 1 */

	sel_sl=sel_el=il;
	sel_sc=x1;
	sel_ec=x2;
	
	w_objc_draw(&wdial, TEXT, 8, sx,sy,sw,sh);
	
	main_url_check();
}

/* -------------------------------------- */

void double_liste(void)
{
	int 	my, oy, dum;
	long	newsel;

	graf_mkstate(&dum, &my, &dum, &dum);
	objc_offset(odial, LISTE, &dum, &oy);
	my-=oy;
	if(my < 0) return;
	my/=ios.lfhi;
	newsel=(long)my+ios.list_off;
	if(newsel >= fld_c) return;
	open_list_ob(newsel);
}

void open_list_ob(long newsel)
{
	static char	wname[128];

	if((fld==NULL)||(newsel < 0)||(newsel >= fld_c)) return;

	switch(fld[newsel].ftype)
	{
		case FLD_SND:
			new_list_sel(newsel);
			if(ed_check_open()==1) return;
			edit_nachricht();
		return;
		case FLD_NEW: case FLD_RED: case FLD_NON: case FLD_SNT:
			new_list_sel(newsel);
			show_original();
		return;
		case FLD_BAK:
			new_list_sel(newsel);
		return;
	}
	/* Default: Ordner/Gruppen */
	ios.list_sel=newsel;	
	strcpy(wname, "[ASH Emailer] ");
	strcat(wname, fld[ios.list_sel].from);
	wdial.name=wname;
	w_set(&wdial, NAME);
	list_view();
	load_new_list();
	ios.list_off=0;
	ios.list_sel=1; /* 0 ist ".." */
	sel_sl=-1;
	load_mail();
	if(!loaded) 
		ios.list_sel=-1;	/* Damit ".." angeklickt werden kann */
	else
		format_loaded(odial[TEXT].ob_width);
	mail_slide_set();
	list_slide_set();
	act_mail_list_view();
	s_redraw(&wdial);
}

/* -------------------------------------- */
void but_state(int su)
{	/* su=0: store state, su=1: update state by redraw*/
	static int state[10];
	int	x,y,w,h;
	
	if(su==0)
	{
		state[0]=odial[SUCHEN].ob_state;
		state[1]=odial[ORDNEN].ob_state;
		state[2]=odial[LOESCHEN].ob_state;
		state[3]=odial[ANTWORT].ob_state;
		state[4]=odial[BEITRAG].ob_state;
		state[5]=odial[NEU].ob_state;
		state[6]=odial[ANHANG].ob_flags;
		state[7]=odial[PUT_ADR].ob_flags;
		state[8]=odial[SWAP_IGN_CRLF].ob_flags;
		state[9]=odial[ANZANHANG].ob_flags+odial[ANZANHANG].ob_spec.tedinfo->te_ptext[0]+odial[ANZANHANG].ob_spec.tedinfo->te_ptext[1];
		return;
	}
	
	/* su=1 */
	if(odial[SUCHEN].ob_state != state[0]) w_objc_draw(&wdial, SUCHEN, 8, sx,sy,sw,sh);
	if(odial[ORDNEN].ob_state != state[1]) w_objc_draw(&wdial, ORDNEN, 8, sx,sy,sw,sh);
	if(odial[LOESCHEN].ob_state != state[2]) w_objc_draw(&wdial, LOESCHEN, 8, sx,sy,sw,sh);
	if(odial[ANTWORT].ob_state != state[3]) w_objc_draw(&wdial, ANTWORT, 8, sx,sy,sw,sh);
	if(odial[BEITRAG].ob_state != state[4]) w_objc_draw(&wdial, BEITRAG, 8, sx,sy,sw,sh);
	if(odial[NEU].ob_state != state[5]) w_objc_draw(&wdial, NEU, 8, sx,sy,sw,sh);
	if(odial[ANHANG].ob_flags != state[6])
	{
		objc_offset(odial, ANHANG, &x, &y);
		w=odial[ANHANG].ob_width;
		h=odial[ANHANG].ob_height;
		w_objc_draw(&wdial, 0, 8, x,y,w,h);
	}
	if(odial[PUT_ADR].ob_flags != state[7])
	{
		objc_offset(odial, PUT_ADR, &x, &y);
		w=odial[PUT_ADR].ob_width;
		h=odial[PUT_ADR].ob_height;
		w_objc_draw(&wdial, 0, 8, x,y,w,h);
	}
	if(odial[SWAP_IGN_CRLF].ob_flags != state[8])
	{
		objc_offset(odial, SWAP_IGN_CRLF, &x, &y);
		w=odial[SWAP_IGN_CRLF].ob_width;
		h=odial[SWAP_IGN_CRLF].ob_height;
		w_objc_draw(&wdial, 0, 8, x,y,w,h);
	}
	if(odial[ANZANHANG].ob_flags+odial[ANZANHANG].ob_spec.tedinfo->te_ptext[0]+odial[ANZANHANG].ob_spec.tedinfo->te_ptext[1] != state[9])
	{
		objc_offset(odial, ANZANHANG, &x, &y);
		w=odial[ANZANHANG].ob_width;
		h=odial[ANZANHANG].ob_height;
		w_objc_draw(&wdial, 0, 8, x,y,w,h);
	}
}

void check_draw_list(int slider)
{/* slider mitzeichnen (1) oder nicht (0) */
	if(odial[ALISTE].ob_flags & HIDETREE) return;
	w_objc_draw(&wdial, FLISTE, 8, sx,sy,sw,sh);
	if(slider) w_objc_draw(&wdial, BAR, 8, sx,sy,sw,sh);
}

void check_draw_mail(void)
{
	if(odial[FTEXT].ob_flags & HIDETREE) return;
	w_objc_draw(&wdial, ABSENDER, 8, sx,sy,sw,sh);
	w_objc_draw(&wdial, BETREFF, 8, sx,sy,sw,sh);
	w_objc_draw(&wdial, TEXT, 8, sx,sy,sw,sh);
}

void new_list_sel(long newsel)
{
	long	l, oof, ix;
	int		new_off=0;
	
	if(newsel==ios.list_sel) return;
	if(newsel >= fld_c) return;
	ios.list_sel=newsel;

	oof=ios.list_off;
	/* Ggf. Listenoffset korrigieren */
	l=odial[LISTE].ob_height/ios.lfhi;	/* Sichtbare Zeilen */
	if(ios.list_off+l <= newsel) ios.list_off=newsel-l+1;
	if(newsel < ios.list_off) ios.list_off=newsel;
	if(ios.list_off+l > fld_c)	ios.list_off=fld_c-l;
	if(ios.list_off < 0) 				ios.list_off=0;

	if(oof!=ios.list_off) {new_off=1; list_slide_set();}

	if( (ext_type(odial, POPUP)==0) || (fld && (fld[newsel].ftype < FLD_BAK)))
	{/* Mail Laden */
		sel_sl=-1;
		but_state(0);
		load_mail();
		format_loaded(odial[TEXT].ob_width);
		act_mail_list_view();
		mail_slide_set();
		but_state(1);
		check_draw_list(new_off);
		check_draw_mail();
		/*w_objc_draw(&wdial, 0, 8, sx,sy,sw,sh);*/
	}
	else if((ext_type(odial, POPUP)==1) && (fld[newsel].ftype==FLD_BAK)) /* .. */
	{
		switch_list(1);
		/* act_fold bleibt erhalten, enthÑlt Dateiname des Ordners
		   aus dem wir kommen. Diesen in der Liste selektieren */
		if(fld!=NULL)
		{
			ix=0;
			while(ix < fld_c)
			{
				if(!strcmp(fld[ix].fspec.fname, act_fold))
				{
					new_list_sel(ix);
					break;
				}
				++ix;
			}
		}
	}
	else if((ext_type(odial, POPUP)==2) && (fld[newsel].ftype==FLD_BAK)) /* .. */
	{
		switch_list(2);
		/* act_fold bleibt erhalten, enthÑlt Dateiname des Ordners
		   aus dem wir kommen. Diesen in der Liste selektieren */
		if(fld!=NULL)
		{
			ix=0;
			while(ix < fld_c)
			{
				if(!strcmp(fld[ix].fspec.fname, act_fold))
				{
					new_list_sel(ix);
					break;
				}
				++ix;
			}
		}
	}
	else	/* Nur neuen Ordner/Gruppe gewÑhlt */
		check_draw_list(new_off);
}

/* -------------------------------------- */

void new_select(void)
{
	int 	my, oy, dum;
	long	newsel;
	
	graf_mkstate(&dum, &my, &dum, &dum);
	objc_offset(odial, LISTE, &dum, &oy);
	my-=oy;
	if(my < 0) return;
	my/=ios.lfhi;
	newsel=(long)my+ios.list_off;
	new_list_sel(newsel);
}

/* -------------------------------------- */

int actize_mail(char *path)
{/* Falls die aktuell angezeigte Mail <path> ist, dann aktualisieren */
	/* return: 1=aktualisiert, 0=Nix gemacht */
	char	bpath[256];
	
	if(fld==NULL) return(0);
	if((ios.list_sel >= fld_c)||(ios.list_sel < 0)) return(0);
	if(fld[ios.list_sel].ftype==FLD_BAK) return(0);

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
	if(stricmp(path, bpath)) return(0);
	/* Mail neu laden */
	sel_sl=-1;
	but_state(0);
	load_mail();
	format_loaded(odial[TEXT].ob_width);
	act_mail_list_view();
	mail_slide_set();
	but_state(1);
	check_draw_mail();
	return(1);
}

/* -------------------------------------- */

void actize_om_sndlst(void)
{/* Falls die aktuelle Ansicht=Liste îffentliche ist, wird
		der erste Eintrag "Zu sendende" aktualisiert */
	long	snd_files;
	char	bpath[256];
	DTA		*old=Fgetdta(), sub_dta;

	if(ios.list != 1) return;
	if((fld==NULL)||(fld_c==0)) return;
	if(fld[0].ftype!=FLD_GSD) return;

	strcpy(bpath, db_path);
	strcat(bpath, "\\OM\\SEND\\*.SND");
	snd_files=0;
	graf_mouse(BUSYBEE, NULL);
	Fsetdta(&sub_dta);
	if(!Fsfirst(bpath, 0))	do
	{++snd_files;}while(!Fsnext());
	Fsetdta(old);
	graf_mouse(ARROW, NULL);
	strcpy(fld[0].from, gettext(MAILSTOSEND));
	if(snd_files) 
	{
		strcat(fld[0].from, " (");
		ltoa(snd_files, &(fld[0].from[strlen(fld[0].from)]), 10);
		strcat(fld[0].from, ")");
		fld[0].loc_flags=LF_UNREAD;
	}
	else fld[0].loc_flags=0;
	if((ios.list_off==0) && !(odial[ALISTE].ob_flags & HIDETREE))
		w_objc_draw(&wdial, LISTE, 8, sx,sy,sw,sh);
}

/* -------------------------------------- */

char *rtrim(char *c)
{
	static char buf[256];
	int			l=(int)strlen(c);
	
	if(l > 255) return(c);
	strcpy(buf, c);
	while(buf[l-1]==' ')
	{
		buf[l-1]=0;
		--l;
	}
	return(buf);
}

/* -------------------------------------- */

void set_max_abswidth(void)
{
	int a, max=0, extend[8];
	
	vst_font(handle, ios.lfid);
	vst_point(handle, ios.lfsiz, &a, &a, &a, &a);

	for(a=0; a < fld_c; ++a)
	{
		vqt_extent(handle, rtrim(fld[a].from), extend);
		if(extend[2] > max)	 max=extend[2];
	}
	max+=ovorl[VSND16].ob_width+4+2;
	ios.from_len=max;
	set_abs_btr_dat();
	w_objc_draw(&wdial, ALISTE, 8, sx,sy,sw,sh);
}
void set_max_btrwidth(void)
{
	int a, max=0, extend[8];
	
	vst_font(handle, ios.lfid);
	vst_point(handle, ios.lfsiz, &a, &a, &a, &a);

	for(a=0; a < fld_c; ++a)
	{
		vqt_extent(handle, rtrim(fld[a].subj), extend);
		if(extend[2] > max)	 max=extend[2];
	}
	max+=2;
	ios.subj_len=max;
	set_abs_btr_dat();
	w_objc_draw(&wdial, ALISTE, 8, sx,sy,sw,sh);
}
void set_max_datwidth(void)
{
	int a, max=0, extend[8];
	
	vst_font(handle, ios.lfid);
	vst_point(handle, ios.lfsiz, &a, &a, &a, &a);

	for(a=0; a < fld_c; ++a)
	{
		vqt_extent(handle, rtrim(fld[a].date), extend);
		if(extend[2] > max)	 max=extend[2];
	}
	max+=2;
	ios.subj_len=odial[LISTE].ob_width-ios.from_len-max;
	set_abs_btr_dat();
	w_objc_draw(&wdial, ALISTE, 8, sx,sy,sw,sh);
}

/* -------------------------------------- */

int set_width(void)
{
	int mx, mb, dum;
	int	ox, min, max, sub, *change;
	
	
	graf_mkstate(&mx, &dum, &dum, &dum);
	objc_offset(odial, ABSWIDTH, &ox, &dum);
	if((mx <= ox+odial[ABSWIDTH].ob_width+8) && (mx >= ox+odial[ABSWIDTH].ob_width-8))
	{
		change=&(ios.from_len);
		sub=ox;
		min=ox+getlen(ABSLEN);
		max=ox+odial[LISTE].ob_width;
		goto _size;
	}

	if(odial[BTRLEN].ob_flags & HIDETREE) return(0);
	objc_offset(odial, BTRWIDTH, &ox, &dum);
	if((mx <= ox+odial[BTRWIDTH].ob_width+8) && (mx >= ox+odial[BTRWIDTH].ob_width-8))
	{
		change=&(ios.subj_len);
		sub=ox;
		min=ox+getlen(BTRLEN);
		max=ox+odial[LISTE].ob_width;
		goto _size;
	}
	return(0);
	
_size:
	ox=-1;
	wind_update(BEG_MCTRL);
	graf_mouse(POINT_HAND, NULL);
	do
	{
		graf_mkstate(&mx, &dum, &mb, &dum);
		if(mx < min) mx=min;
		if(mx > max) mx=max;
		if(mx != ox)
		{
			ox=mx;
			mx-=sub;
			*change=mx;
			set_abs_btr_dat();
			w_objc_draw(&wdial, ALISTE, 8, sx,sy,sw,sh);
		}
	}while(mb & 3);
	graf_mouse(ARROW, NULL);
	wind_update(END_MCTRL);
	return(1);
}

/* -------------------------------------- */

void list_slide_set(void)
{
	long	t, l;

	/* Ggf. Listenoffset korrigieren */
	l=odial[LISTE].ob_height/ios.lfhi;	/* Sichtbare Zeilen */
	if(ios.list_off+l > fld_c)	ios.list_off=fld_c-l;
	if(ios.list_off < 0) 				ios.list_off=0;
	
	if(fld_c <= odial[LISTE].ob_height/ios.lfhi)
	{
		odial[SLIDE].ob_y=0;
		odial[SLIDE].ob_height=odial[BAR].ob_height;
		return;
	}
	
	/* Slidergrîûe */
	t=(long)fld_c*(long)(ios.lfhi);	/* Gesamte Liste in Pixeln */
	odial[SLIDE].ob_height=(int)(((long)odial[BAR].ob_height*(long)odial[LISTE].ob_height)/t);
	if(odial[SLIDE].ob_height < odial[SLIDE].ob_width)
		odial[SLIDE].ob_height=odial[SLIDE].ob_width;
	
	/* Sliderpos. */
	odial[SLIDE].ob_y=(int)(
				((long)(odial[BAR].ob_height-odial[SLIDE].ob_height)*
				 (long)(ios.list_off)) 
				 / 
				 (fld_c-l));
}

/* -------------------------------------- */

void mail_slide_set(void)
{
	long	t, l;

	if(!loaded) goto _m_full_slide;
	/* Ggf. Listenoffset korrigieren */
	l=odial[TEXT].ob_height/ios.mfhi;	/* Sichtbare Zeilen */
	if(lloff+l > llines)	lloff=llines-l;
	if(lloff < 0) 				lloff=0;

	if((llines <= odial[TEXT].ob_height/ios.mfhi) || (odial[FTEXT].ob_flags & HIDETREE))
	{
_m_full_slide:
		wdial.vpos=0;
		wdial.vsiz=1000;
		w_set(&wdial, VSLIDE);
		return;
	}

	/* Slidergrîûe */
	t=(long)llines*(long)(ios.mfhi);	/* Gesamte Liste in Pixeln */
	wdial.vsiz=(int)(((long)1000*(long)odial[TEXT].ob_height)/t);
	
	/* Sliderpos. */
	wdial.vpos=(int)((long)(1000*lloff) / (long)(llines-l));
	w_set(&wdial, VSLIDE);
}

/* -------------------------------------- */

void list_popup(void)
{
	int			mx, my, ox, oy, dum, res;
	OBJECT *tree;
	
	rsrc_gaddr(0, LISTPOPUP, &tree);
	graf_mkstate(&mx, &my, &dum, &dum);
	objc_offset(odial, POPUP, &ox, &oy);
	if(mx > ox+tree[0].ob_width)
		ox=mx-tree[0].ob_width/2;
	oy-=ext_type(odial, POPUP)*tree[1].ob_height;	
	
	if(oy < sy) oy=sy;
	if(ox < sx) ox=sx;
	if(oy+tree[0].ob_height > sy+sh) oy=sy+sh-tree[0].ob_height;
	if(ox+tree[0].ob_width > sx+sw) ox=sx+sw-tree[0].ob_width;
	
	res=form_popup(tree, ox, oy);
	if(res < 0) return;
	res=(res-1)/2;
	if(ext_type(odial, POPUP)==res) return;
	switch_list(res);
}

void switch_list(int res)
{/* 0=PMs, 1=Groups, 2=Folder, 3=Deletet */
	OBJECT *tree;
	
	rsrc_gaddr(0, LISTPOPUP, &tree);
	set_ext_type(odial, POPUP, ios.list=res);
	res=(res*2)+1;
	strcpy(odial[POPUP].ob_spec.free_string, &(tree[res].ob_spec.free_string[2]));
	odial[IPOPUP].ob_spec.ciconblk=tree[res+1].ob_spec.ciconblk;
	
	ios.list_off=ios.list_sel=0;
	switch(ext_type(odial, POPUP))
	{
		case 0:	/* PMs */
		case 3:	/* Gelîschte */
			list_view();
			load_new_list();
			sel_sl=-1;
			load_mail();
			if(!loaded) ios.list_sel=-1;
			else format_loaded(odial[TEXT].ob_width);
			mail_slide_set();
			act_mail_list_view();
		break;
		case 1:
			load_groups();
			free_loaded_mail();
			loaded=NULL;
			fold_view();
			mail_slide_set();	/* Auf volle Grîûe */
		break;
		case 2:
			load_folders(1);
			free_loaded_mail();
			loaded=NULL;
			fold_view();
			mail_slide_set();	/* Auf volle Grîûe */
		break;
	}
	list_slide_set();
	mail_slide_set();
	s_redraw(&wdial);
	wdial.name="ASH Emailer";
	w_set(&wdial, NAME);
}

/* -------------------------------------- */

void ganze_liste(void)
{
	if(odial[FTEXT].ob_flags & HIDETREE)
	{ /* Wieder sichtbar machen */
		strcpy(odial[RECHTS].ob_spec.tedinfo->te_ptext, ">");
		odial[FTEXT].ob_flags &= (~HIDETREE);
		odial[TEILER].ob_x=odial[LINKS].ob_x=odial[RECHTS].ob_x=ios.teiler;
		odial[LINKS].ob_state &= (~DISABLED);
		odial[TEILER].ob_state &= (~DISABLED);
		format_loaded(odial[TEXT].ob_width);
		mail_slide_set();
	}
	else	
	{	/* Liste auf ganze Breite */
		strcpy(odial[RECHTS].ob_spec.tedinfo->te_ptext, "<");
		odial[FTEXT].ob_flags |= HIDETREE;
		ios.teiler=odial[TEILER].ob_x;
		odial[TEILER].ob_x=odial[LINKS].ob_x=odial[RECHTS].ob_x=odial[0].ob_width-2*odial[TEILER].ob_width;
		odial[LINKS].ob_state |= DISABLED;
		odial[TEILER].ob_state |= DISABLED;
		wdial.vsiz=1000;
		w_set(&wdial, VSLIDE);
	}

	odial[POPUP].ob_width=odial[ALISTE].ob_width=odial[TEILER].ob_x-odial[TEILER].ob_width-odial[POPUP].ob_x;
	odial[FLISTE].ob_width=odial[LISTE].ob_width=odial[ALISTE].ob_width-2-odial[BAR].ob_width-3;
	odial[UP].ob_x=odial[BAR].ob_x=odial[DOWN].ob_x=odial[FLISTE].ob_width+4;
	set_abs_btr_dat();
	w_objc_draw(&wdial, 0, 8, sx,sy,sw,sh);
}

/* -------------------------------------- */

void ganze_nachricht(void)
{
	if(odial[ALISTE].ob_flags & HIDETREE)
	{ /* Liste Wieder sichtbar machen */
		strcpy(odial[LINKS].ob_spec.tedinfo->te_ptext, "<");
		odial[ALISTE].ob_flags &= (~HIDETREE);
		odial[POPUP].ob_flags &= (~HIDETREE);
		odial[RECHTS].ob_state &= (~DISABLED);
		odial[TEILER].ob_state &= (~DISABLED);
		odial[TEILER].ob_x=odial[LINKS].ob_x=odial[RECHTS].ob_x=ios.teiler;
	}
	else	
	{	/* Nachricht auf ganze Breite */
		strcpy(odial[LINKS].ob_spec.tedinfo->te_ptext, ">");
		odial[ALISTE].ob_flags |= HIDETREE;
		odial[POPUP].ob_flags |= HIDETREE;
		ios.teiler=odial[TEILER].ob_x;
		odial[RECHTS].ob_state |= DISABLED;
		odial[TEILER].ob_state |= DISABLED;
		odial[TEILER].ob_x=odial[LINKS].ob_x=odial[RECHTS].ob_x=odial[ALISTE].ob_x;
	}

	odial[FTEXT].ob_x=odial[TEILER].ob_x+odial[TEILER].ob_width;
	odial[FTEXT].ob_width=odial[KOPF].ob_width=odial[TEXT].ob_width=odial[0].ob_width-odial[TEILER].ob_x-2*odial[TEILER].ob_width;
	odial[ABSENDER].ob_width=odial[KOPF].ob_width-odial[ABSENDER].ob_x-odial[UP].ob_width-8;
	odial[BETREFF].ob_width=odial[KOPF].ob_width-odial[BETREFF].ob_x-odial[UP].ob_width-8;
	odial[PUT_ADR].ob_x=odial[SWAP_IGN_CRLF].ob_x=odial[KOPF].ob_width-(odial[PUT_ADR].ob_width+4);
	format_loaded(odial[TEXT].ob_width);
	mail_slide_set();
	w_objc_draw(&wdial, 0, 8, sx,sy,sw,sh);
}

/* -------------------------------------- */

void set_teiler(int mx)
{
	odial[TEILER].ob_x=odial[LINKS].ob_x=odial[RECHTS].ob_x=mx;
	odial[POPUP].ob_width=odial[ALISTE].ob_width=odial[TEILER].ob_x-odial[TEILER].ob_width-odial[POPUP].ob_x;
	odial[FLISTE].ob_width=odial[LISTE].ob_width=odial[ALISTE].ob_width-2-odial[BAR].ob_width-3;
	odial[UP].ob_x=odial[BAR].ob_x=odial[DOWN].ob_x=odial[FLISTE].ob_width+4;
	set_abs_btr_dat();
	
	odial[FTEXT].ob_x=odial[TEILER].ob_x+odial[TEILER].ob_width;
	odial[FTEXT].ob_width=odial[KOPF].ob_width=odial[TEXT].ob_width=odial[0].ob_width-odial[TEILER].ob_x-2*odial[TEILER].ob_width;
	odial[ABSENDER].ob_width=odial[KOPF].ob_width-odial[ABSENDER].ob_x-odial[UP].ob_width-8;
	odial[BETREFF].ob_width=odial[KOPF].ob_width-odial[BETREFF].ob_x-odial[UP].ob_width-8;
	odial[PUT_ADR].ob_x=odial[SWAP_IGN_CRLF].ob_x=odial[KOPF].ob_width-(odial[PUT_ADR].ob_width+4);
	format_loaded(odial[TEXT].ob_width);
	mail_slide_set();
}

void teilen(void)
{
	int mx, mb, dum;
	int ox, ofs;
	
	wind_update(BEG_MCTRL);
	graf_mouse(FLAT_HAND, NULL);
	
	odial[TEILER].ob_state |= SELECTED;
	w_objc_draw(&wdial, TEILER, 8, sx,sy,sw,sh);	
	objc_offset(odial, TEILER, &ofs, &dum);
	graf_mkstate(&mx, &dum, &mb, &dum); ox=mx;
	ofs-=mx;
	ox+=ofs;
	ox-=odial[0].ob_x;
	do
	{
		graf_mkstate(&mx, &dum, &mb, &dum);
		mx+=ofs;
		mx-=odial[0].ob_x;
		if(mx < odial[POPUP].ob_x+ext_type(odial,ALISTE))
			mx=odial[POPUP].ob_x+ext_type(odial, ALISTE);
		if(mx > odial[0].ob_width-5*odial[ROSE].ob_width)
			mx=odial[0].ob_width-5*odial[ROSE].ob_width;
		if(mx != ox)
		{
			ox=mx;
			set_teiler(mx);
			w_objc_draw(&wdial, 0, 8, sx,sy,sw,sh);
		}
	}while(mb & 3);
	
	ios.teiler=odial[TEILER].ob_x;
	odial[TEILER].ob_state &= (~SELECTED);	
	w_objc_draw(&wdial, TEILER, 8, sx,sy,sw,sh);	

	graf_mouse(ARROW, NULL);
	wind_update(END_MCTRL);
}

/* -------------------------------------- */

void blit_y(WINDOW *win, int ob, long old_y, long new_y)
{
	GRECT scr, rect, todo, mouse;
	int		ms, d, wid=win->whandle;
	int		blit_dif, blit_dir, xywh[4];
	int		pxy[8];
	MFDB	src, dst;
	
	if(old_y < new_y)
	{
		blit_dir=1; /* Nach oben blitten */
		blit_dif=(int)(new_y-old_y);
	}
	else
	{
		blit_dir=0; /* Nach unten blitten */
		blit_dif=(int)(old_y-new_y);
	}

	objc_offset(win->dinfo->tree, ob, &todo.g_x, &todo.g_y);
	todo.g_w=win->dinfo->tree[ob].ob_width;
	todo.g_h=win->dinfo->tree[ob].ob_height;
	
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
	wind_get(wid, WF_FIRSTXYWH, &rect.g_x, &rect.g_y, &rect.g_w, &rect.g_h);

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
				pxy[0]=pxy[4]=rect.g_x;
				pxy[2]=pxy[6]=rect.g_x+rect.g_w-1;

				if(rect.g_h > blit_dif)
				{
					if(blit_dir)
					{/* Nach oben */
						pxy[1]=rect.g_y+blit_dif; pxy[5]=rect.g_y;
						pxy[3]=rect.g_y+rect.g_h-1; pxy[7]=rect.g_y+rect.g_h-1+blit_dif;
						rect.g_y=rect.g_y+rect.g_h-blit_dif; rect.g_h=blit_dif;
					}
					else
					{/* Nach unten */
						pxy[1]=rect.g_y; pxy[5]=rect.g_y+blit_dif;
						pxy[3]=rect.g_y+rect.g_h-1-blit_dif; pxy[7]=rect.g_y+rect.g_h-1;
						rect.g_h=blit_dif;
					}
					src.fd_addr=dst.fd_addr=NULL;
					vro_cpyfm(handle, 3, pxy, &src, &dst);
				}
				if(rect.g_h > 0)
				{
					objc_draw(win->dinfo->tree, ob, 8, rect.g_x, rect.g_y, rect.g_w, rect.g_h);
				}
				if (handle > -1)
					vs_clip(handle, 0, xywh);
			}
		}
		wind_get(wid, WF_NEXTXYWH, &rect.g_x, &rect.g_y, &rect.g_w, &rect.g_h);

	}

	if (ms)
		graf_mouse(M_ON, NULL);

	wind_update(END_UPDATE);
}

/* -------------------------------------- */

void up_liste(void)
{
	long	oloff=ios.list_off;
	
	--ios.list_off;
	if(ios.list_off < 0) ios.list_off=0;
	list_slide_set();
	if(ios.list_off == oloff) return;
	w_objc_draw(&wdial, BAR, 8, sx,sy,sw,sh);
	blit_y(&wdial, LISTE, oloff*ios.lfhi, ios.list_off*ios.lfhi);
}

void down_liste(void)
{
	long	oloff=ios.list_off;
	
	++ios.list_off;
	list_slide_set();
	if(ios.list_off == oloff) return;
	w_objc_draw(&wdial, BAR, 8, sx,sy,sw,sh);
	blit_y(&wdial, LISTE, oloff*ios.lfhi, ios.list_off*ios.lfhi);
}

void slide_liste(void)
{
	int		mb, my, oy=-1, miny, maxy, offy, dum;
	long	l, off, mo;

	maxy=odial[BAR].ob_height-odial[SLIDE].ob_height;
	if(maxy==0) return;
	
	wind_update(BEG_MCTRL);
	graf_mouse(FLAT_HAND, NULL);

	objc_offset(odial, SLIDE, &dum, &offy);
	graf_mkstate(&dum, &my, &dum, &dum);
	offy=my-offy;
	objc_offset(odial, BAR, &dum, &miny);
	
	do
	{
		graf_mkstate(&dum, &my, &mb, &dum);
		my-=miny+offy;
		if(my < 0) my=0;
		if(my > maxy) my=maxy;
		if(my==oy) continue;	
		
		/* Neuen Offset ausrechnen */
		l=odial[LISTE].ob_height/ios.lfhi;		/* Sichtbare Zeilen */
		off=(int)(((long)my*(fld_c-l))/(long)maxy);
		if(off!=ios.list_off)
		{
			mo=ios.list_off*ios.lfhi;
			ios.list_off=off;
			list_slide_set();
			w_objc_draw(&wdial, BAR, 8, sx,sy,sw,sh);
			blit_y(&wdial, LISTE, mo, off*ios.lfhi);
		}	
	}while(mb & 3);
	
	graf_mouse(ARROW, NULL);
	wind_update(END_MCTRL);
}

void page_liste(void)
{
	int		oy, my, dum;
	
	long	oloff=ios.list_off;
	long	psize=odial[LISTE].ob_height/ios.lfhi;

	graf_mkstate(&dum, &my, &dum, &dum);
	objc_offset(odial, SLIDE, &dum, &oy);
	if(my < oy)
		ios.list_off-=psize;
	else
		ios.list_off+=psize;
	if(ios.list_off < 0) ios.list_off=0;
	list_slide_set();
	if(ios.list_off == oloff) return;
	w_objc_draw(&wdial, ALISTE, 8, sx,sy,sw,sh);
}

/* -------------------------------------- */

void	marrowed(WINDOW *win, int *pbuf)
{
	long	oloff=lloff, mo=lloff*ios.mfhi;
	long	psize=odial[TEXT].ob_height/ios.mfhi;
	
	if(win != &wdial) return;
	
	switch(pbuf[4])
	{
		case WA_UPPAGE:	lloff-=psize;	break;
		case WA_DNPAGE: lloff+=psize; break;
		case WA_UPLINE:	--lloff; break;
		case WA_DNLINE:	++lloff; break;
	}
	if(lloff < 0) lloff=0;
	mail_slide_set();
	if(lloff == oloff) return;
	if(!(win->dinfo->tree[FTEXT].ob_flags & HIDETREE))
		blit_y(&wdial, TEXT, mo, lloff*ios.mfhi);
}

/* -------------------------------------- */

void	mvslid(WINDOW *win, int *pbuf)
{
	long	l, off, mo=lloff*ios.mfhi;
	
	if(win != &wdial) return;

	/* Neuen Offset ausrechnen */
	l=odial[TEXT].ob_height/ios.mfhi;		/* Sichtbare Zeilen */
	off=(int)(((long)(pbuf[4])*(llines-l))/(long)1000);
	if(off!=lloff)
	{
		lloff=off;
		mail_slide_set();
		if(!(win->dinfo->tree[FTEXT].ob_flags & HIDETREE))
			blit_y(&wdial, TEXT, mo, lloff*ios.mfhi);
	}	
}

/* -------------------------------------- */

void	msized(WINDOW *win, int *pbuf)
{
	int dum, aw, ah, ow, tx, nx, lx;
	
	if(win != &wdial) return;
	
	/* pbuf[6]=Breite, pbuf[7]=Hîhe */
	wind_calc(WC_WORK, wdial.kind, wdial.wx, wdial.wy, pbuf[6], pbuf[7], &dum, &dum, &aw, &ah);
	if(aw < odial[NEU].ob_x+odial[NEU].ob_width+odial[SUCHEN].ob_x)
		aw=odial[NEU].ob_x+odial[NEU].ob_width+odial[SUCHEN].ob_x;
	if(ah < odial[FTEXT].ob_y+3*odial[KOPF].ob_height)
		ah=odial[FTEXT].ob_y+3*odial[KOPF].ob_height;

	if( (aw-2==odial[0].ob_width) && (ah-2==odial[0].ob_height)) return;
	
	ow=odial[0].ob_width;
	odial[0].ob_width=aw-2;
	odial[0].ob_height=ah-2;
	
	/* Objekthîhen setzen */
	odial[ALISTE].ob_height=odial[0].ob_height-odial[ALISTE].ob_y-odial[NEU].ob_y;
	odial[FLISTE].ob_height=odial[ALISTE].ob_height-2;
	odial[LISTE].ob_height=odial[FLISTE].ob_height-odial[ABSWIDTH].ob_height;
	odial[BAR].ob_height=odial[FLISTE].ob_height-2-2*odial[UP].ob_height-6+2;
	odial[DOWN].ob_y=odial[FLISTE].ob_height-odial[DOWN].ob_height+1;
	
	odial[FTEXT].ob_height=odial[0].ob_height-odial[FTEXT].ob_y-odial[NEU].ob_y;
	odial[TEXT].ob_height=odial[FTEXT].ob_height-odial[KOPF].ob_height;

	odial[RECHTS].ob_y=odial[LINKS].ob_y+odial[LINKS].ob_height;
	odial[TEILER].ob_y=odial[RECHTS].ob_y+odial[RECHTS].ob_height;
	odial[TEILER].ob_height=odial[FTEXT].ob_height-2*odial[LINKS].ob_height;

	
	/* Objektbreiten setzen */
	/* Teiler neu setzen */
	if((odial[ALISTE].ob_flags & HIDETREE)||(odial[FTEXT].ob_flags & HIDETREE))
		tx=ios.teiler;
	else
		tx=odial[TEILER].ob_x;
	/* Neues x/Neuer Breite = Altes x/Alter Breite */
	tx=(int)((long)((long)tx*(long)aw)/(long)ow);

	if(tx < odial[POPUP].ob_x+ext_type(odial,ALISTE))
			tx=odial[POPUP].ob_x+ext_type(odial, ALISTE);
	if(tx > odial[0].ob_width-5*odial[ROSE].ob_width)
		tx=odial[0].ob_width-5*odial[ROSE].ob_width;

	if(odial[ALISTE].ob_flags & HIDETREE)
	{/* Ganze Nachricht */
		ios.teiler=tx;
		nx=odial[TEILER].ob_x;
		lx=tx;
	}
	else if(odial[FTEXT].ob_flags & HIDETREE)
	{ /* Ganze Liste */
		ios.teiler=tx;
		odial[TEILER].ob_x=odial[LINKS].ob_x=odial[RECHTS].ob_x=odial[0].ob_width-2*odial[TEILER].ob_width;
		nx=tx;
		lx=odial[TEILER].ob_x;
	}
	else
	{/* Normal */
		odial[TEILER].ob_x=odial[LINKS].ob_x=odial[RECHTS].ob_x=tx;
		nx=lx=tx;
	}

	odial[FTEXT].ob_x=nx+odial[TEILER].ob_width;
	odial[FTEXT].ob_width=odial[KOPF].ob_width=odial[TEXT].ob_width=odial[0].ob_width-nx-2*odial[TEILER].ob_width;		
	odial[ABSENDER].ob_width=odial[KOPF].ob_width-odial[ABSENDER].ob_x-odial[UP].ob_width-8;
	odial[BETREFF].ob_width=odial[KOPF].ob_width-odial[BETREFF].ob_x-odial[UP].ob_width-8;
	odial[PUT_ADR].ob_x=odial[SWAP_IGN_CRLF].ob_x=odial[KOPF].ob_width-(odial[PUT_ADR].ob_width+4);

	odial[POPUP].ob_width=odial[ALISTE].ob_width=lx-odial[TEILER].ob_width-odial[POPUP].ob_x;
	odial[FLISTE].ob_width=odial[LISTE].ob_width=odial[ALISTE].ob_width-2-odial[BAR].ob_width-3;
	odial[UP].ob_x=odial[BAR].ob_x=odial[DOWN].ob_x=odial[FLISTE].ob_width+4;
	set_abs_btr_dat();
	
	list_slide_set();
	format_loaded(odial[TEXT].ob_width);
	mail_slide_set();
	
	w_calc(win);
	win->aw=aw;
	win->ah=ah;
	w_wcalc(win);
	w_set(win, CURR);
	w_objc_draw(win, 0, 8, sx,sy,sw,sh);
}

/* -------------------------------------- */

void	mfulled(WINDOW *win)
{
	int wx,wy,ww,wh;
	
	if(win != &wdial) return;

	if((wdial.wx!=sx)||(wdial.wy!=sy)||(wdial.ww!=sw)||(wdial.wh!=sh))
	{
		wx=sx; wy=sy; ww=sw; wh=sh;
	}
	else
		wind_get(win->whandle, WF_PREVXYWH, &wx, &wy, &ww, &wh);

	win->wx=wx;
	win->wy=wy;
	win->ww=ww;
	win->wh=wh;
	w_calc(win);
	win->dinfo->tree[0].ob_x=win->ax+win->dinfo->xdif;
	win->dinfo->tree[0].ob_y=win->ay+win->dinfo->ydif;

	pbuf[6]=ww; pbuf[7]=wh;
	msized(win, pbuf);
}

/* -------------------------------------- */

void nochmal(void)
{
	char p1[256], p2[256], new_fname[32];
	long res;
	
	if((fld==NULL)||(fld_c <= ios.list_sel)||(ios.list_sel<0)) return;
	if(fld[ios.list_sel].ftype!=FLD_SNT) return;

	/* Quelle bestimmen: Im Datenbankmodus keine, sonst nach p1 */
	if(db_mode==0)
	{
		strcpy(p1, db_path);
		switch(ios.list)
		{
			case 0:	strcat(p1, "\\PM\\");	break;
			case 1:	strcat(p1, "\\OM\\");	strcat(p1, act_fold);	strcat(p1, "\\");	break;
			case 2:	strcat(p1, "\\ORD\\"); strcat(p1, act_fold); strcat(p1, "\\"); break;
			case 3:	strcat(p1, "\\DEL\\"); break;
		}
		strcat(p1, fld[ios.list_sel].fspec.fname);
	}
	
	/* Ziel bestimmen: */
	/* Falls aktuell in PM bleiben Pfad und Datei gleich, nur neue
		 Endung. (Nur falls nicht in DB-Mode, sonst gibt es die
		 Quelldatei ja garnicht) */
	if((ios.list==0) && (db_mode==0))	/* PM */
	{
		strcpy(p2, p1);
		p2[strlen(p2)-1]='D'; /* SNT->SND */
		strcpy(new_fname, fld[ios.list_sel].fspec.fname);
		new_fname[strlen(new_fname)-1]='D'; /* SNT->SND */
	}
	else /* Neues Ziel per get_free_file bestimmen */
	{	/* Wohin? */
		if(fld[ios.list_sel].loc_flags & LF_OM)
		{	strcpy(p2, db_path); strcat(p2, "\\OM\\SEND\\");}
		else
		{	strcpy(p2, db_path); strcat(p2, "\\PM\\");}
		strcpy(new_fname, get_free_file(p2));
		strcat(new_fname, ".SND");
		strcat(p2, new_fname); 
	}

	/* Datei erzeugen */	
	if(db_mode)
	{
		Idx_detach_to(fld[ios.list_sel].idx, p2);
	}
	else
	{
		res=Frename(0, p1, p2);
		if(res < 0)
		{
			gemdos_alert("Fehler beim éndern", res);
			return;
		}
	}

	/* Listenansicht ggf. aktualisieren */
	if((ios.list==0) && (!(fld[ios.list_sel].loc_flags & LF_OM))) /* PM */
	{
		fld[ios.list_sel].ftype=FLD_SND;
		strcpy(fld[ios.list_sel].fspec.fname, new_fname);
		if(fld_bak)
		{
			strcpy(fld_bak[fld[ios.list_sel].root_index].fspec.fname, fld[ios.list_sel].fspec.fname);
			fld_bak[fld[ios.list_sel].root_index].ftype=fld[ios.list_sel].ftype;
		}
		act_mail_list_view();
	}
	else
		remove_sel_from_list();
	w_objc_draw(&wdial, ALISTE, 8, sx,sy,sw,sh);
}

/* -------------------------------------- */

void change_font(int ob, int id, int siz)
{/* ob: 0=LISTE, 1=TEXT, 2=EDITOR
		id=0 oder Font-ID
		siz=0 oder Font-Size in Punkten 
	*/

	int		a, dum, phbox, extend[8];
	uchar	cw[2];
	WINDOW	*win;

	switch(ob)
	{
		case 0:
			if(id) ios.lfid=id;
			if(siz)ios.lfsiz=siz;
			ios.lfid=vst_font(handle, ios.lfid);
			ios.lfsiz=vst_point(handle, ios.lfsiz, &dum, &dum, &dum, &phbox);
			ios.lfhi=phbox;
			list_slide_set();
			w_objc_draw(&wdial, ALISTE, 8, sx,sy,sw,sh);
		break;
		case 1:
			if(Kbshift(-1) & 8)
			{
				ios.mf2id=ios.mfid;
				ios.mf2siz=ios.mfsiz;
			}
			if(id) ios.mfid=id;
			if(siz)ios.mfsiz=siz;
			ios.mfid=vst_font(handle, ios.mfid);
			ios.mfsiz=vst_point(handle, ios.mfsiz, &dum, &dum, &dum, &phbox);
			ios.mfhi=phbox;
			mail_slide_set();
			w_objc_draw(&wdial, TEXT, 8, sx,sy,sw,sh);
			vst_font(handle, ios.mfid);
			vst_point(handle, ios.mfsiz, &dum, &dum, &dum, &dum);
			cw[1]=0;
			for(a=0; a < 256; ++a)
			{
				cw[0]=a;
				vqt_extent(handle, (char*)cw, extend);
				ios.mcwidth[a]=extend[2];
			}
			ios.mcwidth[0]=ios.mcwidth[1]=ios.mcwidth[FIRST_FAT]=0;
			ios.mcwidth[9]=ios.m_tabspc*P_TABWIDTH;
		break;
		case 2:
			if(Kbshift(-1) & 8)
			{
				ios.ef2id=ios.efid;
				ios.ef2siz=ios.efsiz;
			}
			if(id) ios.efid=id;
			if(siz)ios.efsiz=siz;
			ios.efid=vst_font(handle, ios.efid);
			ios.efsiz=vst_point(handle, ios.efsiz, &dum, &dum, &dum, &phbox);
			vst_effects(handle, 0);
			vst_alignment(handle, 0, 3, &dum, &dum);	/* Bottom Line Alignment */
			ios.efhi=phbox;
			vqt_extent(handle, ">", extend);
			ios.eqwi=extend[2];
			cw[1]=0;
			for(a=0; a < 256; ++a)
			{
				cw[0]=a;
				vqt_extent(handle, (char*)cw, extend);
				ios.ecwidth[a]=extend[2];
			}
			ios.ecwidth[13]=8;	/* Bitblock fÅr CR */
			ios.ecwidth[9]=ios.ed_tabspc*P_TABWIDTH;
			/* Alle Editor-Fenster neu zeichnen */
			a=0;
			while((win=w_list(a))!=NULL)
			{
				a=1;
				if(ext_type(win->dinfo->tree, 0)!=1) continue;
				umbrechen(win);
				editor_slide_set(win);
				s_redraw(win);
			}
		break;
	}
}

/* -------------------------------------- */

void swap_font(int ob)
{	/* ob: 1=TEXT, 2=EDITOR */
	int sid, ssiz;
	
	switch(ob)
	{
		case 1:
			sid=ios.mf2id; ssiz=ios.mf2siz;
			ios.mf2id=ios.mfid; ios.mf2siz=ios.mfsiz;
		break;
		case 2:
			sid=ios.ef2id; ssiz=ios.ef2siz;
			ios.ef2id=ios.efid; ios.ef2siz=ios.efsiz;
		break;
		default:
			return;
	}
	change_font(ob, sid, ssiz);
}

int dequote(int nr,char *arglist,char **file) 
{ 
#ifndef TRUE 
#define FALSE (0) 
#define TRUE  (!FALSE) 
#endif 
 
  long pos,file_start,outpos,l; 
  int gequotet; 
  char *datei; 
 
  pos=0l; 
  while(nr) 
  { /* Dateien Åberspringen */ 
    int dateiende; 
 
    gequotet=FALSE; 
    if(arglist[pos]=='\'') 
    { 
      gequotet=TRUE; 
      pos++; 
    } 
 
    dateiende=FALSE; 
    do { 
      if(arglist[pos]=='\0' || 
        (arglist[pos]==' ' && !gequotet)) 
      { 
        dateiende=TRUE; 
      } 
      if(arglist[pos]=='\'' && 
        gequotet) 
      { 
        pos++; 
 
        if(arglist[pos]!='\'') 
          dateiende=TRUE; 
      } 
 
      if(!dateiende) 
        pos++; 
    } while(!dateiende); 
 
    if(arglist[pos]) 
      pos++; 
 
    nr--; 
  } 
 
  if(arglist[pos]=='\0') 
    return EFILNF; 
 
  file_start=pos; 
 
  gequotet=FALSE; 
  if(arglist[pos]=='\'') 
  { 
    gequotet=TRUE; 
    pos++; 
    file_start++; 
  } 
 
  *file=NULL; 
  datei=NULL; 
  do { 
    if(arglist[pos]=='\0' || 
      (arglist[pos]==' ' && !gequotet)) 
    { 
      datei=(char *)malloc(pos-file_start+1); 
      if(!datei) 
        return ENSMEM; 
    } 
    if(arglist[pos]=='\'' && 
      gequotet) 
    { 
      if(arglist[pos+1]!='\'') 
      { 
        datei=(char *)malloc(pos-file_start+1); 
        if(!datei) 
          return ENSMEM; 
      } 
      else 
        pos++; 
    } 
 
    pos++; 
  } while(!datei); 
 
  outpos=0; 
  for(l=file_start;;l++) 
  { 
    if(arglist[l]=='\'' && 
      gequotet) 
    { 
      if(arglist[l+1]=='\'') 
      { 
        datei[outpos++]='\''; 
        l++; 
      } 
      else 
      { 
        datei[outpos]='\0'; 
        *file=datei; 
        return E_OK; 
      } 
    } 
    else if(arglist[l]=='\0') 
    { 
      if(!gequotet) 
      { 
        datei[outpos]='\0'; 
        *file=datei; 
        return E_OK; 
      } 
      else 
      { 
        datei[outpos]='\0'; 
        free(datei); 
        return ERANGE; 
      } 
    } 
    else if(arglist[l]==' ') 
    { 
      if(!gequotet) 
      { 
        datei[outpos]='\0'; 
        *file=datei; 
        return E_OK; 
      } 
      else 
      { 
        datei[outpos++]=arglist[l]; 
      } 
    } 
    else 
    { 
      datei[outpos++]=arglist[l]; 
    } 
  } 
} 

void add_anhaengsel(WINDOW *win, char *files)
{	
	int		nr=0;
	char	*file;
	
	while(!dequote(nr++, files, &file))
	{
		if(count_anhang(win)==9)
		{
			form_alert(1, gettext(EDMAXANHANG));
			free(file);
			break;
		}
		add_file_as_anhang(win, file);
		free(file);
	}
}

/* -------------------------------------- */

void	other_message(int *pbuf)
{
	char	*cmd, *x, *cc, *bcc, *subj;
	int dum, mx, my;
	WINDOW *win;
		
	switch(pbuf[0])
	{
		case ADDRBOOK_CHANGED:
			if(pbuf[3]==1)	/* Hier wird nur Neueinlesen behandelt, ACKs werden ignoriert */
				address_reload(pbuf[1]);
		break;
		
		case AP_TERM:
			if(run_shutdown()==0) break;
			w_close(&wdial);
		break;

		case GS_REQUEST:
			process_gs_request(pbuf);
		break;
		
		case GS_COMMAND:
			process_gs_command(pbuf);
		break;
		
		case 0x7a18:		/* FONT_CHANGED */
			if(pbuf[3] < 0) break;
			if(pbuf[3]==wdial.whandle)
			{
				graf_mkstate(&mx, &my, &dum, &dum);
				if(objc_find(odial, 0, 8, mx, my)==LISTE)
					change_font(0, pbuf[4], pbuf[5]);
				else
					change_font(1, pbuf[4], pbuf[5]);
				break;
			}
			if(w_find(pbuf[3])==NULL) break;
			if(ext_type(w_find(pbuf[3])->dinfo->tree, 0)!=1) break;
			change_font(2, pbuf[4], pbuf[5]);
		break;
		
		case VA_START:
			cmd=*(char**)(&(pbuf[3]));
			if(cmd==NULL) goto _av_reply;
			if(strnicmp(cmd, "mailto:", 7)) goto _av_reply;
			subj=stristr(cmd, "?Subject=");
			cc=stristr(cmd, "?cc=");
			bcc=stristr(cmd, "?bcc=");
			if(subj!=NULL) { *subj=0;	subj+=9;}
			if(cc!=NULL) { *cc=0; cc+=4;}
			if(bcc!=NULL) { *bcc=0; bcc+=5;}
			nachricht_an(&(cmd[7]), cc, bcc, subj);
_av_reply:
			if(pbuf[1]!=ap_id)
			{
				pbuf[0]=AV_STARTED;
				dum=pbuf[1];
				pbuf[1]=ap_id;
				appl_write(dum, 16, pbuf);
			}
		break;
		
		case VA_DRAGACCWIND:
			x=*((char**)&(pbuf[6]));
			if(pbuf[3]==wdial.whandle)
			{/* Auf Hauptfenster nur IMG-Dateien erlaubt */
				if(stricmp(&(x[strlen(x)-3]), "IMG")) break;
				dum=objc_find(odial, 0,8,pbuf[4], pbuf[5]);
				if(dum==TEXT)
				{
					if(msg_img.fd_addr) {free(msg_img.fd_addr);msg_img.fd_addr=NULL;}
					if(load_img(&msg_img, *((char**)&(pbuf[6])))==0)
					{
						ios.msg_img_path[0]=0;
						msg_img.fd_addr=NULL;
					}
					else
						strcpy(ios.msg_img_path, *((char**)&(pbuf[6])));
					w_objc_draw(&wdial, TEXT, 8, sx,sy,sw,sh);
				}
				else if(dum==LISTE)
				{
					if(lst_img.fd_addr) {free(lst_img.fd_addr);lst_img.fd_addr=NULL;}
					if(load_img(&lst_img, *((char**)&(pbuf[6])))==0)
					{
						ios.lst_img_path[0]=0;
						lst_img.fd_addr=NULL;
					}
					else
						strcpy(ios.lst_img_path, *((char**)&(pbuf[6])));
					w_objc_draw(&wdial, LISTE, 8, sx,sy,sw,sh);
				}
				break;
			}
			if((win=w_find(pbuf[3]))==NULL) break;
			if(ext_type(win->dinfo->tree, 0)!=1) break;
			/* Auf Editorfenster */
			if(objc_find(win->dinfo->tree, 0,8,pbuf[4], pbuf[5])==EDANHANG)
			{/* Auf BÅroklammer */
				add_anhaengsel(win, *((char**)&(pbuf[6])));
				break;
			}
			/* Nicht auf Klammer, dann nur IMG erlaubt */
			if(stricmp(&(x[strlen(x)-3]), "IMG")) break;
			if(ed_img.fd_addr){free(ed_img.fd_addr);ed_img.fd_addr=NULL;}
			if(load_img(&ed_img, *((char**)&(pbuf[6])))==0)
			{
				ios.ed_img_path[0]=0;
				ed_img.fd_addr=NULL;
			}
			else
				strcpy(ios.ed_img_path, *((char**)&(pbuf[6])));
			/* Alle Editor-Fenster neu zeichnen */
			dum=0;
			while((win=w_list(dum))!=NULL)
			{
				dum=1;
				if(ext_type(win->dinfo->tree, 0)!=1) continue;
				s_redraw(win);
			}
		break;

	}
}

/* -------------------------------------- */

void window_cycle(void)
{
	WINDOW *win;
	int low_handle, wh, owner, dum, above;
	
	low_handle=0;
	above=0;
	do
	{
		wh=above;
		wnd_get(wh, WF_OWNER, &owner, &dum, &above, &dum);
		if(owner==ap_id)
		{
			low_handle=wh;
			break;
		}
	}while(above > 0);
	if(low_handle)
	{
		if((win=w_find(wh))==NULL) return;
		w_top(win);
	}
}

/* -------------------------------------- */

void jetzt_senden(void)
{
	char p1[256];
	
	if((fld==NULL)||(fld_c <= ios.list_sel)||(ios.list_sel < 0)) {Bell(); return;}
	if(fld[ios.list_sel].ftype!=FLD_SND) {Bell(); return;}

	strcpy(p1, db_path);

	switch(ios.list)
	{
		case 0:	strcat(p1, "\\PM\\");	break;
		case 1:	strcat(p1, "\\OM\\");	strcat(p1, act_fold);	strcat(p1, "\\");	break;
		case 2:	strcat(p1, "\\ORD\\"); strcat(p1, act_fold); strcat(p1, "\\"); break;
		case 3:	strcat(p1, "\\DEL\\"); break;
	}
	strcat(p1, fld[ios.list_sel].fspec.fname);
	send_now(p1);
}

/* -------------------------------------- */

void	menu_dispatch(int title, int ob)
{
	int 		wh;
	WINDOW *win;
	
	switch(ob)
	{
		/* Desk */
		case MINFO:
			lock_menu(omenu);
			show_info();
			unlock_menu(omenu);
		break;
		
		/* Datei */
		case MNEW: case MMNEW:
			ed_new_file();
		break;
		case MOPEN:
			ed_open_file();
		break;
		case MMERGE:
			/* Oberstes Fenster ist Editor? */
			wh=wind_gtop();
			win=w_find(wh);
			if(win==NULL) break;
			if(ext_type(win->dinfo->tree, 0)!=1) break;
			w_ed_merge(win);
		break;
		case MCLOSE:
			/* Oberstes Fenster holen */
			wh=wind_gtop();
			win=w_find(wh);
			if(win==NULL) break;
			win->closed(win);
		break;
		case MSAVE:
			/* Oberstes Fenster ist Editor? */
			wh=wind_gtop();
			win=w_find(wh);
			if(win==NULL) break;
			if(ext_type(win->dinfo->tree, 0)!=1) break;
			if(!(win->kind & SIZE)) break;	/* Signature window */
			do_editor(win, EDSAVE);
		break;
		case MSAVEAS:
			/* Oberstes Fenster ist Editor? */
			wh=wind_gtop();
			win=w_find(wh);
			if(win==NULL) break;
			if(win==&wdial) save_original_as();
			else if(ext_type(win->dinfo->tree, 0)==1) 
				ed_save_as(win);
		break;
		case MQUIT:
			if(run_shutdown()==0) break;
			w_close(&wdial);
		break;
		
		/* Bearbeiten */
		case MUNDO:
			/* Oberstes Fenster ist Editor? */
			wh=wind_gtop();
			win=w_find(wh);
			if(win==NULL) break;
			if(ext_type(win->dinfo->tree, 0)!=1) break;
			w_edit_input(win, 0, 97<<8);	/* Undo unterjubeln */
		break;
		
		case MQUOTE:
			quote();
		break;
		
		case MCUT:
		case MCOPY:
		case MPASTE:
			/* Oberstes Fenster ist Editor? */
			wh=wind_gtop();
			win=w_find(wh);
			if(win==NULL) break;
			if(win==&wdial) mail_copy();
			if(ext_type(win->dinfo->tree, 0)!=1) break;
			switch(ob)
			{
				case MCUT: w_ed_cut(win); break;
				case MCOPY: w_ed_copy(win); break;
				case MPASTE: w_ed_paste(win); break;
			}
		break;

		case MALL:
			/* Oberstes Fenster ist Editor? */
			wh=wind_gtop();
			win=w_find(wh);
			if(win==NULL) break;
			if(win==&wdial) mail_selall();
			if(ext_type(win->dinfo->tree, 0)!=1) break;
			w_ed_selall(win);
		break;
		
		case MSEARCH:
			lock_menu(omenu);
			suchen();
			unlock_menu(omenu);
		break;
		case MSAGAIN:
			asuchen();
		break;

		/* Ansicht */
		case MWCYCLE:
			window_cycle();
		break;

		case MWANHANG:
			if(anh_win.open) w_top(&anh_win);
			else anhang_win();
		break;
		
		case MVFROM: case MVSUBJ: case MVDATE:
			switch(ob)
			{
				case MVFROM: sort_by_from(); break;
				case MVSUBJ: sort_by_subj(); break;
				case MVDATE: sort_by_date(); break;
			}
			w_objc_draw(&wdial, ALISTE, 8, sx,sy,sw,sh);
		break;

		case MVALLE: 
		case MVSNDSNT: case MVSND: case MVSNT:
		case MVNEWRED: case MVRED: case MVNEW:
			if(omenu[ob].ob_state & CHECKED) break; /* Ist schon aktuell */
			if(fld_bak)
			{
				if(ios.list_sel > -1)
					ios.list_sel=fld[ios.list_sel].root_index;
				if(fld) free(fld);
				fld=fld_bak; fld_bak=NULL;
				fld_c=fld_c_bak; fld_c_bak=0;
			}
			switch(ob)
			{
				case MVALLE: 
					wh=1; sort_by_sel();
					if((ios.list_sel==-1) && (fld_c > 0))
					{
						wh=2;
						ios.list_sel=0;
						if(fld[0].ftype==FLD_BAK) ios.list_sel=1;
					}
				break;
				case MVSNDSNT: wh=view_own(); break;
				case MVSND:	wh=view_snd(); break;
				case MVSNT: wh=view_snt(); break;
				case MVNEWRED: wh=view_rcv(); break;
				case MVRED: wh=view_red(); break;
				case MVNEW: wh=view_new(); break;	
			}
			clear_view_obs();
			if(wh==0)
				menu_icheck(omenu, MVALLE, 1);
			else
				menu_icheck(omenu, ob, 1);
			list_slide_set();
			w_objc_draw(&wdial, ALISTE, 8, sx,sy,sw,sh);
			if(wh!=2) break;
			sel_sl=-1;
			but_state(0);
			load_mail();
			if(!loaded)  /* In einer '..'-Liste wurde Index 1 gesetzt, obwohl sie leer ist */
				ios.list_sel=-1;	/* Damit ".." angeklickt werden kann */
			else
				format_loaded(odial[TEXT].ob_width);
			mail_slide_set();
			act_mail_list_view();
			but_state(1);
			w_objc_draw(&wdial, FTEXT, 8, sx,sy,sw,sh);
		break;

		case MALTFONT:
			/* Oberstes Fenster ist ? */
			wh=wind_gtop();
			win=w_find(wh);
			if(win==NULL) break;
			if(win==&wdial) /* Hauptfenster */
			{
				if(ios.mf2id==-1)
				{
					form_alert(1, gettext(NO_ALT_FONT));
					break;
				}
				swap_font(1);
				break;
			}
			if(ext_type(win->dinfo->tree, 0)!=1) break;
			/* Editor */
			if(ios.ef2id==-1)
			{
				form_alert(1, gettext(NO_ALT_FONT));
				break;
			}
			swap_font(2);
		break;
		
		/* Nachricht */
		case MANSWER:
			beantworten();
		break;
		case MWEITER:
			lock_menu(omenu);
			weiterleiten();
			unlock_menu(omenu);
		break;
		case MCOMMENT:
			beitrag();
		break;
		case MEDIT:	
			/* Oberstes Fenster ist Editor? */
			wh=wind_gtop();
			win=w_find(wh);
			if(win==NULL) break;
			if(win==&wdial)
			{/* Nachricht im Editor îffnen */
				edit_nachricht();
			}
			else if(ext_type(win->dinfo->tree, 0)==1)
			{/* Cursor ggf. in Editor-Bereich setzen */
				if(win->dinfo->dedit > 0)
					do_editor(win, UEDITOR);
			}
		break;
		case MJETZT:
			/* Oberstes Fenster ? */
			wh=wind_gtop();
			win=w_find(wh);
			if(win==NULL) break;
			if(win==&wdial)
			{/* Hauptfenster */
				lock_menu(omenu);
				jetzt_senden();
				unlock_menu(omenu);
				switch_list(0);
			}
			else if(ext_type(win->dinfo->tree, 0)==1)
			{/* Editor */
				do_editor(win, EDSEND);
			}
		break;
		case MNOCHMAL:
			nochmal();
		break;
		case MDELAY:
			zurueckhalten();
		break;
		case MSORT:
			verschieben();
		break;
		case MORDBYFIL:
			ord_by_filter();
		break;
		case MKILL:
			loeschen();
		break;
		case MINTEREST:
			interessant();
		break;
		case MORGFILE:
			show_orgfile();
		break;
		case MORIGINAL:
			show_original();
		break;
				
		/* Datenbank */		
		case MFULLSEARCH:
			lock_menu(omenu);
			dbsearch();
			unlock_menu(omenu);
		break;
		case MEXCHANGE:
			lock_menu(omenu);
			online();
			unlock_menu(omenu);
			switch_list(0);
		break;
		case MFILTERS:
			filter_dial();
		break;
		case MADRBOOK:
			address_dial(&wdial);
		break;
		case MGROUPS:
			group_dial();
		break;
		case MFOLDER:
			folder_dial();
		break;
		case MCLEANUP:
			lock_menu(omenu);
			aufraeumen();
			unlock_menu(omenu);
		break;
		case MIMPORT:
			if(db_mode==0) {form_alert(1,gettext(NOIMPORT)); break;}
			if(form_alert(1, gettext(NOWIMPORT))==2) break;
			menu_tnormal(omenu, title, 1);
			Import_files(1);
			reload_actual();
		break;
		case MDBCHECK:
			if(db_mode==0) {form_alert(1,gettext(NODBCHECK)); break;}
			if(form_alert(1, gettext(DBASECHECK))==2) break;
			menu_tnormal(omenu, title, 1);
			if(Check_folders())
			{
				refresh_folders();
				switch_list(0);
			}
			if(Check_dbase())	reload_actual();
		break;

		/* Optionen */
		case MANZEIGE:
			menu_tnormal(omenu, title, 1);
			lock_menu(omenu);
			set_anzeige();
			unlock_menu(omenu);
		break;
		case MFARBEN:
			menu_tnormal(omenu, title, 1);
			lock_menu(omenu);
			set_farbe();
			unlock_menu(omenu);
		break;
		case MINTERNET:
			menu_tnormal(omenu, title, 1);
			lock_menu(omenu);
			set_internet();
			unlock_menu(omenu);
		break;
		case MDBASEOPT:
			menu_tnormal(omenu, title, 1);
			lock_menu(omenu);
			set_dbase();
			unlock_menu(omenu);
		break;
		case MSIG:
			set_sig();
		break;
		case MADRESSES:
			menu_tnormal(omenu, title, 1);
			lock_menu(omenu);
			set_adresses();
			unlock_menu(omenu);
		break;
		
		/*
		case MSPECIAL:
			spec_funcs();
		break;
		*/
	}
	
	menu_tnormal(omenu, title, 1);
}

