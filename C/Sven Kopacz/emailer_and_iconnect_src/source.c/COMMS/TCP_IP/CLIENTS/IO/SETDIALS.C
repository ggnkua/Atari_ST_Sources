#include <ec_gem.h>
#include "io.h"
#include "ioglobal.h"
#include "edspecl.h"
#include "indexer.h"

/* -------------------------------------- */

void redraw_edit_wins(void)
{
	WINDOW	*win;
	int a;
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
}

/* -------------------------------------- */

void col_popup(WINDOW *win, OBJECT *tree, int ob)
{
	OBJECT *ptree;
	int res, x, y;
	
	if(wwork_out[13] < 4) rsrc_gaddr(0, COL2POPUP, &ptree);
	else if(wwork_out[13] < 8) rsrc_gaddr(0, COL4POPUP, &ptree);
	else rsrc_gaddr(0, COL8POPUP, &ptree);
	
	objc_offset(tree, ob, &x, &y);
	
	res=form_popup(ptree, x, y);
	if(res < 1) return;
	--res;
	if(res == ext_type(tree, ob)) return;
	set_ext_type(tree, ob, res);
	w_objc_draw(win, ob, 8, sx,sy,sw,sh);
}

/* -------------------------------------- */

void do_farbe(WINDOW *win, int ob)
{
	WINDOW *edwin;
	int		dum;
	
	if(obj_type(win->dinfo->tree, ob) == G_USERDEF)
	{/* Das sind die Farbpopups */
		col_popup(win, win->dinfo->tree, ob);
	}

	if(ob==KILLPATT)
	{
		if(form_alert(1, gettext(REALKILLPATT))==1)
		{
			if(msg_img.fd_addr) free(msg_img.fd_addr);
			if(lst_img.fd_addr) free(lst_img.fd_addr);
			if(ed_img.fd_addr) free(ed_img.fd_addr);
			msg_img.fd_addr=lst_img.fd_addr=ed_img.fd_addr=NULL;
			strcpy(ios.msg_img_path, "");
			strcpy(ios.lst_img_path, "");
			strcpy(ios.ed_img_path, "");
			w_objc_draw(&wdial, TEXT, 8, sx,sy,sw,sh);
			w_objc_draw(&wdial, LISTE, 8, sx,sy,sw,sh);
			dum=0;
			while((edwin=w_list(dum))!=NULL)
			{
				dum=1;
				if(ext_type(edwin->dinfo->tree, 0)!=1) continue;
				s_redraw(edwin);
			}
		}
		w_unsel(win, ob);
	}
	else if(win->dinfo->tree[ob].ob_flags & EXIT)
	{
		*(int*)(win->user)=ob;
		w_close(win);
	}
}

/* -------------------------------------- */

void set_farbe(void)
{
	OBJECT *tree;
	
	rsrc_gaddr(0, SET_FARBE, &tree);
	tree[ESOK].ob_state &= (~SELECTED);
	tree[ESABBRUCH].ob_state &= (~SELECTED);

	set_ext_type(tree, IBACKCOL, ios.lcol);
	set_ext_type(tree, ISNDCOL, ios.lsndcol);
	set_ext_type(tree, ISNTCOL, ios.lsntcol);
	set_ext_type(tree, INEWCOL, ios.lnewcol);
	set_ext_type(tree, IREDCOL, ios.lredcol);
	set_ext_type(tree, IGRPCOL, ios.lubkcol);
	set_ext_type(tree, MBACKCOL, ios.mcol);
	set_ext_type(tree, MTEXTCOL, ios.mtextcol);
	set_ext_type(tree, MQUOTECOL, ios.quotecol);
	set_ext_type(tree, EBACKCOL, ios.ecol);
	set_ext_type(tree, ETEXTCOL, ios.etextcol);
	set_ext_type(tree, EURLCOL, ios.urlcol);

	if(w_do_opt_dial(tree, do_farbe)==ESABBRUCH) return;

	ios.lcol=ext_type(tree, IBACKCOL);
	ios.lsndcol=ext_type(tree, ISNDCOL);
	ios.lsntcol=ext_type(tree, ISNTCOL);
	ios.lnewcol=ext_type(tree, INEWCOL);
	ios.lredcol=ext_type(tree, IREDCOL);
	ios.lubkcol=ext_type(tree, IGRPCOL);
	ios.mcol=ext_type(tree, MBACKCOL);
	ios.mtextcol=ext_type(tree, MTEXTCOL);
	ios.quotecol=ext_type(tree, MQUOTECOL);
	ios.ecol=ext_type(tree, EBACKCOL);
	ios.etextcol=ext_type(tree, ETEXTCOL);
	ios.urlcol=ext_type(tree, EURLCOL);

	s_redraw(&wdial);
	redraw_edit_wins();
}

/* -------------------------------------- */

void set_internet(void)
{
	OBJECT *tree;
#define set_flag(a, b) if(a) tree[b].ob_state |= SELECTED; else tree[b].ob_state &= (~SELECTED);	
#define get_flag(a, b) if(tree[b].ob_state & SELECTED) a=1; else a=0;	

	rsrc_gaddr(0, SET_INTERNET, &tree);
	tree[ISOK].ob_state &= (~SELECTED);
	tree[ISABBRUCH].ob_state &= (~SELECTED);

	set_flag(ios.autotausch, ESAUTOTAUSCH);
	set_flag(ios.autoicon, ESAUTOICON);
	set_flag(ios.autodial, ESAUTODIAL);
	set_flag(ios.tausch_info, ESSHOWINFO);
	set_flag(ios.pllrequest,ESPLLREQUEST);
	itoa(ios.pllsize, tree[ESPLLSIZE].ob_spec.tedinfo->te_ptext, 10);
	set_flag(ios.server_del, ESERVERDEL);
	itoa(ios.newslist_days, tree[ESDAYS].ob_spec.tedinfo->te_ptext, 10);
/*	set_flag(ios.news_head, ESNEWSHEAD);*/
	set_flag(ios.news_new, ESNEWSNEW);
	itoa(ios.news_num, tree[ESNEWSNUM].ob_spec.tedinfo->te_ptext, 10);
	set_flag(ios.no_grp_msg_id, ENOMSGID);
	
	if(w_do_dial(tree)==ISABBRUCH) return;

	get_flag(ios.autotausch, ESAUTOTAUSCH);
	get_flag(ios.autoicon, ESAUTOICON);
	get_flag(ios.autodial, ESAUTODIAL);
	get_flag(ios.pllrequest,ESPLLREQUEST);
	get_flag(ios.tausch_info, ESSHOWINFO);
	ios.pllsize=atoi(tree[ESPLLSIZE].ob_spec.tedinfo->te_ptext);
	get_flag(ios.server_del, ESERVERDEL);
	ios.newslist_days=atoi(tree[ESDAYS].ob_spec.tedinfo->te_ptext);
/*	get_flag(ios.news_head, ESNEWSHEAD);*/
	get_flag(ios.news_new, ESNEWSNEW);
	ios.news_num=atoi(tree[ESNEWSNUM].ob_spec.tedinfo->te_ptext);
	get_flag(ios.no_grp_msg_id, ENOMSGID);

#undef set_flag
#undef get_flag
}

/* -------------------------------------- */

void set_anzeige(void)
{
	OBJECT *tree;
	rsrc_gaddr(0, SET_ANZEIGE, &tree);
	tree[ANZOK].ob_state &= (~SELECTED);
	tree[ANZABBRUCH].ob_state &= (~SELECTED);

	itoa(ios.m_tabspc, tree[ANZMSGTAB].ob_spec.tedinfo->te_ptext, 10);
	itoa(ios.ed_tabspc, tree[ANZEDTAB].ob_spec.tedinfo->te_ptext, 10);
	objc_xtedcpy(tree, ANZHEAD, ios.headinfo);
	if(ios.ignore_crlf) tree[IGNORE_CRLF].ob_state |= SELECTED;
	else tree[IGNORE_CRLF].ob_state &= (~SELECTED);
	if(ios.real_smile) tree[USE_REAL_SMILE].ob_state |= SELECTED;
	else tree[USE_REAL_SMILE].ob_state &= (~SELECTED);
	if(ios.all_text) tree[ALL_TEXT].ob_state |= SELECTED;
	else tree[ALL_TEXT].ob_state &= (~SELECTED);
	if(ios.cut_pers) tree[CUTPERS].ob_state |= SELECTED;
	else tree[CUTPERS].ob_state &=(~SELECTED);
	if(ios.cut_oeff) tree[CUTOEFF].ob_state |= SELECTED;
	else tree[CUTOEFF].ob_state &=(~SELECTED);
	itoa(ios.cut_pnum, tree[CUTPERSNUM].ob_spec.tedinfo->te_ptext, 10);
	itoa(ios.cut_onum, tree[CUTOEFFNUM].ob_spec.tedinfo->te_ptext, 10);

	do
	{
		if(atoi(tree[CUTPERSNUM].ob_spec.tedinfo->te_ptext)<20)
		{
			form_alert(1, gettext(ED_CUT_MIN));
			strcpy(tree[CUTPERSNUM].ob_spec.tedinfo->te_ptext, "20");
			/* Avoid duplicate alert */
			if(atoi(tree[CUTOEFFNUM].ob_spec.tedinfo->te_ptext)<20)
				strcpy(tree[CUTOEFFNUM].ob_spec.tedinfo->te_ptext, "20");
		}
		if(atoi(tree[CUTOEFFNUM].ob_spec.tedinfo->te_ptext)<20)
		{
			strcpy(tree[CUTOEFFNUM].ob_spec.tedinfo->te_ptext, "20");
			form_alert(1, gettext(ED_CUT_MIN));
		}
		
		if(w_do_dial(tree)==ANZABBRUCH) return;
	}while((atoi(tree[CUTPERSNUM].ob_spec.tedinfo->te_ptext)<20)||
					(atoi(tree[CUTOEFFNUM].ob_spec.tedinfo->te_ptext)<20));
	
	ios.m_tabspc=atoi(tree[ANZMSGTAB].ob_spec.tedinfo->te_ptext);
	if(ios.m_tabspc==0) ios.m_tabspc=1;
	ios.ed_tabspc=atoi(tree[ANZEDTAB].ob_spec.tedinfo->te_ptext);
	if(ios.ed_tabspc==0) ios.ed_tabspc=1;
	strcpy(ios.headinfo, xted(tree, ANZHEAD)->te_ptext);
	ios.mcwidth[9]=ios.m_tabspc*P_TABWIDTH;
	ios.ecwidth[9]=ios.ed_tabspc*P_TABWIDTH;
	if(tree[IGNORE_CRLF].ob_state & SELECTED) ios.ignore_crlf=1;
	else ios.ignore_crlf=0;
	if(tree[USE_REAL_SMILE].ob_state & SELECTED) ios.real_smile=1;
	else ios.real_smile=0;
	if(tree[ALL_TEXT].ob_state & SELECTED) ios.all_text=1;
	else ios.all_text=0;
	if(!sw_mode)
	{
		if(ios.ignore_crlf)
			odial[SWAP_IGN_CRLF].ob_state |= SELECTED;
		else
			odial[SWAP_IGN_CRLF].ob_state &= (~SELECTED);
	}
	if(tree[CUTPERS].ob_state & SELECTED) ios.cut_pers=1;
	else ios.cut_pers=0;
	if(tree[CUTOEFF].ob_state & SELECTED) ios.cut_oeff=1;
	else ios.cut_oeff=0;
	ios.cut_pnum=atoi(tree[CUTPERSNUM].ob_spec.tedinfo->te_ptext);
	ios.cut_onum=atoi(tree[CUTOEFFNUM].ob_spec.tedinfo->te_ptext);
	s_redraw(&wdial);
	redraw_edit_wins();
}

/* -------------------------------------- */

int ed_store(WINDOW *win)
{
	long l=0;
	char	*c;
	EDIT_OB	*edob=win->user;
	ED_LIN	*el=edob->first;
	
	store_buf(edob);
	while(el)
	{
		l+=strlen(el->line);
		el=el->next;

	}
	if(l+1 > 1024)
	{
		form_alert(1, gettext(SIGTOOLONG));
		return(0);
	}
	if(win->dinfo->tree[SIG1].ob_state & SELECTED)
		c=ios.sig1;
	else if(win->dinfo->tree[SIG2].ob_state & SELECTED)
		c=ios.sig2;
	else
		c=ios.sig3;
		
	c[0]=0;
	el=edob->first;
	while(el)
	{
		strcat(c, el->line);
		el=el->next;
	}
	return(1);
}

int ed_get(WINDOW *win)
{
	char	*c, *d;
	EDIT_OB	*edob=win->user;
	ED_LIN	*el, *mel;
	
	if(win->dinfo->tree[SIG1].ob_state & SELECTED)
		c=ios.sig1;
	else if(win->dinfo->tree[SIG2].ob_state & SELECTED)
		c=ios.sig2;
	else
		c=ios.sig3;

	d=malloc(strlen(c)+1);
	if(d==NULL) {form_alert(1, gettext(NOMEM)); return(0);}
		
	el=edob->first;
	if(el)
	{
		if(el->line) free(el->line);
		el=el->next;
		while(el)
		{
			if(el->line) free(el->line);
			mel=el;
			el=el->next;
			free(mel);
		}
	}
	else
	{
		edob->first=malloc(sizeof(ED_LIN));
		if(edob->first==NULL){form_alert(1, gettext(NOMEM)); return(0);}
	}
	el=edob->first;
	el->line=d;
	el->next=NULL;
	strcpy(d, c);
	strcpy(edob->buf_line, c);
	edob->cur_x=edob->cur_y=edob->offset=edob->max_x=edob->cur_only=0;
	edob->sel_sx=-1;
	umbrechen(win);
	editor_slide_set(win);
	return(1);
}

/* -------------------------------------- */

void	do_sigset(WINDOW *win, int ob)
{
	int			old_sel;
	EDIT_OB	*edob=win->user;
	
	switch(ob)
	{
		case SIGEDITOR:
			/* Cursor positionieren oder neue Selektion */
			ed_cur_sel(win);
		break;
		
		case SIGVIS:
			if(sw_mode)
			{
				if(win->dinfo->tree[ob].ob_spec.iconblk==ovorl[SIGSWVISSEL].ob_spec.iconblk)
				{
					win->dinfo->tree[ob].ob_spec.iconblk=ovorl[SIGSWVISUNSEL].ob_spec.iconblk;
					edob->crvis=0;
				}
				else
				{
					win->dinfo->tree[ob].ob_spec.iconblk=ovorl[SIGSWVISSEL].ob_spec.iconblk;
					edob->crvis=1;
				}
			}
			else
			{
				if(win->dinfo->tree[ob].ob_state & SELECTED)
				{
					win->dinfo->tree[ob].ob_state &= (~SELECTED);
					edob->crvis=0;
				}
				else
				{
					win->dinfo->tree[ob].ob_state |= SELECTED;
					edob->crvis=1;
				}
			}
			w_objc_draw(win, ob, 8, sx,sy,sw,sh);
			w_objc_draw(win, edob->edob, 8, sx,sy,sw,sh);
		break;
		
		case SIG1: case SIG2: case SIG3:
			if(ed_store(win)==0) break;
			if(win->dinfo->tree[SIG1].ob_state & SELECTED) old_sel=SIG1;
			else if(win->dinfo->tree[SIG2].ob_state & SELECTED) old_sel=SIG2;
			else old_sel=SIG3;
			win->dinfo->tree[SIG1].ob_state &= (~SELECTED);
			win->dinfo->tree[SIG2].ob_state &= (~SELECTED);
			win->dinfo->tree[SIG3].ob_state &= (~SELECTED);
			win->dinfo->tree[ob].ob_state |= SELECTED;
			if(ed_get(win)==0)
			{
				win->dinfo->tree[ob].ob_state &= (~SELECTED);
				win->dinfo->tree[old_sel].ob_state |= SELECTED;
			}
			w_objc_draw(win, SIG1, 8, sx,sy,sw,sh);
			w_objc_draw(win, SIG2, 8, sx,sy,sw,sh);
			w_objc_draw(win, SIG3, 8, sx,sy,sw,sh);
			w_objc_draw(win, SIGEDITOR, 8, sx,sy,sw,sh);
		break;
	}
}

/* -------------------------------------- */

void sigclosed(WINDOW *win)
{
	EDIT_OB *edob=win->user;
	ED_LIN	*el, *mel;
	
	if(ed_store(win)==0) return;

	el=edob->first;
	ios.sigeyes_on=edob->crvis;
	while(el)
	{
		if(el->line) free(el->line);
		mel=el;
		el=el->next;
		free(mel);
	}
	free(edob);

	w_close(win);
	w_kill(win);
}

/* -------------------------------------- */

void set_sig(void)
{
	EDIT_OB	*edob, *undoedob;
	ED_LIN	*el;
	OBJECT *tree;
	WINDOW	*win;
	DINFO		*ddial;
	char		*c;
	
	rsrc_gaddr(0, SET_SIG, &tree);
	tree[SIG1].ob_state |= SELECTED;
	tree[SIG2].ob_state &= (~SELECTED);
	tree[SIG3].ob_state &= (~SELECTED);
	if(sw_mode)
	{
		if(ios.sigeyes_on)
			tree[SIGVIS].ob_spec.iconblk=ovorl[SIGSWVISSEL].ob_spec.iconblk;
		else		
			tree[SIGVIS].ob_spec.iconblk=ovorl[SIGSWVISUNSEL].ob_spec.iconblk;
		tree[SIGVIS].ob_type=G_ICON;
	}
	else
	{
		if(ios.sigeyes_on)
			tree[SIGVIS].ob_state |= SELECTED;
		else
			tree[SIGVIS].ob_state &= (~SELECTED);
	}
		
	edob=malloc(2*sizeof(EDIT_OB)+sizeof(WINDOW)+sizeof(DINFO));
	el=malloc(sizeof(ED_LIN));
	c=malloc(strlen(ios.sig1)+1);
	if((el==NULL)||(edob==NULL)||(c==NULL))
	{
		form_alert(1, gettext(NOMEM));
		if(el) free(el);
		if(edob) free(edob);
		if(c) free(c);
		return;
	}
	undoedob=&(edob[1]);
	win=(WINDOW*)&(undoedob[1]);
	ddial=(DINFO*)&(win[1]);
	edob->first=el;
	edob->first->line=c; strcpy(c, ios.sig1);
	edob->first->quoted=0;
	edob->first->next=NULL;

	/* Defaults eintragen */	
	set_ext_type(tree, 0, 1);
	tree[SIGEDITOR].ob_spec.userblk->ub_parm=(long)win;
	edob->undo=undoedob;
	edob->undo->first=NULL;
	edob->changed=0;
	edob->buf_line[0]=0;
	edob->head_height=0;	
	edob->cur_x=edob->cur_y=edob->offset=edob->max_x=edob->cur_only=0;
	edob->sel_sx=-1;
	edob->edob=SIGEDITOR;
	edob->crvis=ios.sigeyes_on;
	
	w_dinit(win);
	ddial->tree=tree;
	ddial->support=0;
	ddial->osmax=0;
	ddial->odmax=8;
	win->dinfo=ddial;
	w_kdial(win, D_CENTER, MOVE|NAME|BACKDROP|CLOSE|UPARROW|DNARROW|VSLIDE);
	win->closed=sigclosed;
	win->arrowed=earrowed;
	win->vslid=evslid;
	ddial->dservice=NULL;
	ddial->dwservice=do_sigset;
	ddial->dedit=0;
	win->user=edob;

	strcpy(edob->buf_line, edob->first->line);
	umbrechen(win);
	editor_slide_set(win);

	w_open(win);
}

/* -------------------------------------- */

void set_dbase(void)
{
	OBJECT *tree;
	int		 but;
	
	rsrc_gaddr(0, SET_DBASE, &tree);
	tree[SDBOK].ob_state &= (~SELECTED);
	tree[SDBABBRUCH].ob_state &= (~SELECTED);
	tree[SDMODESWITCH].ob_state &= (~SELECTED);

	if(ios.auto_import)
		tree[SDAUTOIMPORT].ob_state |= SELECTED;
	else
		tree[SDAUTOIMPORT].ob_state &= (~SELECTED);
		
	if(db_mode)
	{
		tree[SDB_SINGLE].ob_state &= (~SELECTED);
		tree[SDB_COMM].ob_state |= SELECTED;
	}
	else
	{
		tree[SDB_SINGLE].ob_state |= SELECTED;
		tree[SDB_COMM].ob_state &= (~SELECTED);
	}
	
	but=w_do_dial(tree);
	
	if(but==SDBABBRUCH) return;
	if(but==SDBOK)
	{
		if(tree[SDAUTOIMPORT].ob_state & SELECTED)
			ios.auto_import=1;
		else
			ios.auto_import=0;
		return;
	}
	
	/* Modus umstellen */
	if(db_mode)
	{
		if(form_alert(1, gettext(REALSFMODE))==2) return;
		Export_files(1);
		db_mode=0;
		reload_actual();
	}
	else
	{
		if(form_alert(1, gettext(REALDBMODE))==2) return;
		Import_files(1);
		db_mode=1;
		reload_actual();
	}
}

/* -------------------------------------- */

void set_adresses(void)
{
	OBJECT *tree;
	rsrc_gaddr(0, SET_ADRESSES, &tree);
	tree[ADROK].ob_state &= (~SELECTED);
	tree[ADRABBRUCH].ob_state &= (~SELECTED);

	if(ios.permanent_reply) tree[PERM_REPLY].ob_state |= SELECTED;
	else tree[PERM_REPLY].ob_state &= (~SELECTED);
	objc_xtedcpy(tree, PERM_REPLY_ADR, ios.perm_reply_adr);
	if(ios.perm_reply_in_groups) tree[PERM_NEWS].ob_state |= SELECTED;
	else tree[PERM_NEWS].ob_state &= (~SELECTED);

	if(ios.fake_news_from) tree[USE_FAKE_ABS].ob_state |= SELECTED;
	else tree[USE_FAKE_ABS].ob_state &= (~SELECTED);
	objc_xtedcpy(tree, FAKE_ADR, ios.fake_news_adr);
	
	if(w_do_dial(tree)==ADRABBRUCH) return;
	
	if(tree[PERM_REPLY].ob_state & SELECTED) ios.permanent_reply=1;
	else ios.permanent_reply=0;
	strcpy(ios.perm_reply_adr, xted(tree, PERM_REPLY_ADR)->te_ptext);
	if(tree[PERM_NEWS].ob_state & SELECTED) ios.perm_reply_in_groups=1;
	else ios.perm_reply_in_groups=0;

	if(tree[USE_FAKE_ABS].ob_state & SELECTED) ios.fake_news_from=1;
	else ios.fake_news_from=0;
	strcpy(ios.fake_news_adr, xted(tree, FAKE_ADR)->te_ptext);
}
