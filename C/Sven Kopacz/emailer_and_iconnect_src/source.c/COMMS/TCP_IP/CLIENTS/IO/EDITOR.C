#include <ec_gem.h>
#include <atarierr.h>
#include "io.h"
#include "ioglobal.h"
#include "indexer.h"

int eds_opened=0;
int	no_at_warning;

extern void clip_url(void);
extern void blit_y(WINDOW *win, int ob, long old_y, long new_y);
extern void check_draw_list(int slider);

extern OBJECT	 *omenu;

long	get_cur_x(char *line, int pix);
int		new_cur_y(EDIT_OB *eo, long ny, int ob_hi);
long	count_lines(EDIT_OB	*eo);
int		insert_line(EDIT_OB *eo);
int		store_buf(EDIT_OB *edob);
int		store_undo(EDIT_OB *edob);
void	fwd_mx_umbrechen(WINDOW *win, int x);
void	usr_umbrechen(EDIT_OB *edob, int max_width);
int		ed_file_insert(int fh, EDIT_OB *edob, int width, int quoting);
int		count_anhang(WINDOW *win);
void 	w_ed_quote(WINDOW *win);

void	do_crsr_check(WINDOW *win, int oob, int nob);
void	ed_kill_win(WINDOW *win);
void	ed_kill_file(EDIT_OB *edob);
void	eclosed(WINDOW *win);
void	efulled(WINDOW *win);
void	esized(WINDOW *win, int *pbuf);
void	evslid(WINDOW *win, int *pbuf);
void	earrowed(WINDOW *win, int *pbuf);

int		ed_copy(EDIT_OB *edob);

int ehead_sel(WINDOW *win)
{/* Editor-Header ist eingeklappt (0) oder ausgeklappt (1) */
	if(sw_mode)
	{
		if(win->dinfo->tree[EHEAD].ob_spec.iconblk==ovorl[ESWHEADSEL].ob_spec.iconblk)
			return(1);
		else
			return(0);
	}
	else return(win->dinfo->tree[EHEAD].ob_state & SELECTED);
}

void set_file(EDIT_OB *edob, int pm_om)
{/* Legt die Editor-Datei an. 
		pm_om=-1: Aktuell selektierte Nachricht eintragen 
		pm_om=0 fÅr PM oder 1 fÅr Gruppe, dann
		fname= Name des Gruppenordners */
long	fhl;

	strcpy(edob->file, db_path);
	strcat(edob->file, "\\");
	if(pm_om==-1)
	{
		switch(ios.list)
		{
			case 0: strcat(edob->file, "PM\\");	break;
			case 1:
				strcat(edob->file, "OM\\");
				strcat(edob->file, act_fold);
				strcat(edob->file, "\\");
			break;
			case 2:
				strcat(edob->file, "ORD\\");
				strcat(edob->file, act_fold);
				strcat(edob->file, "\\");
			break;
			case 3:
				strcat(edob->file, "DEL\\");
			break;
		}
		strcat(edob->file, fld[ios.list_sel].fspec.fname);
	}
	else if(pm_om)
	{
		strcat(edob->file, "OM\\SEND\\");
		strcat(edob->file, get_free_file(edob->file));
		strcat(edob->file, ".SND");
		fhl=Fcreate(edob->file, 0);
		if(fhl < 0) {gemdos_alert(gettext(CREATEERR), fhl); return;}
		Fclose((int)fhl);
	}
	else
	{
		strcat(edob->file, "PM\\");
		strcat(edob->file, get_free_file(edob->file));
		strcat(edob->file, ".SND");
		fhl=Fcreate(edob->file, 0);
		if(fhl < 0) {gemdos_alert(gettext(CREATEERR), fhl); return;}
		Fclose((int)fhl);
	}
}

int dedkeybd(WINDOW *win, int key, int swt)
{
	if(((key>>8) == 80) || ((key&0xff)==9))	/* Cursor runter oder Tab */
	{
		if(((key&0xff)==9) && (swt&3)) /* Tab mit Shift */
		{
			if(win->dinfo->dedit!=0) return(0);	/* Mir doch egal */
			((EDIT_OB*)(win->user))->cur_only=1;
			w_objc_draw(win, ((EDIT_OB*)(win->user))->edob, 8, sx,sy,sw,sh);
			((EDIT_OB*)(win->user))->cur_only=0;
			if(ehead_sel(win))
			{
				if(((EDIT_OB*)(win->user))->pm_om)
					win->dinfo->dedit=ESUBJECT;	
				else
					win->dinfo->dedit=EBCC;
			}
			else
				win->dinfo->dedit=ETO;
			win->dinfo->cpos=0;
			w_dialcursor(win, D_CURON);
			return(1);
		}
		else /* Cursor runter oder TAB ohne Shift */
		{
			if(ehead_sel(win))
			{
				if(((EDIT_OB*)(win->user))->pm_om)
				{
					if(win->dinfo->dedit != ESUBJECT) return(0);
				}
				else if(win->dinfo->dedit != EBCC) return(0);
			}
			else if(win->dinfo->dedit != ETO) return(0);
			w_dialcursor(win, D_CUROFF);
			win->dinfo->dedit=0;
			win->dinfo->cpos=0;
			((EDIT_OB*)(win->user))->cur_only=1;
			w_objc_draw(win, ((EDIT_OB*)(win->user))->edob, 8, sx,sy,sw,sh);
			((EDIT_OB*)(win->user))->cur_only=0;
			return(1);
		}
	}
	else if(key&0xff)
	{/* Wenn Ascii-Code, dann als énderung vermerken, falls in Edit-Objekt */
		if(win->dinfo->dedit)
			((EDIT_OB*)(win->user))->changed=1;
	}
	
	return(0);
}

WINDOW *open_editor(void)
{
	OBJECT	*src, *dst;
	TEDINFO	*ted;
	USERBLK	*ublk;
	EDIT_OB	*edob, *undoedob;
	ED_LIN	*el;
	WINDOW	*win;
	DINFO		*ddial;
	long		a=0, b;
	char		*c, *ibt;
	
	/* Editor-Resource kopieren */
	rsrc_gaddr(0, EDITOR, &src);
	while(!(src[a++].ob_flags & LASTOB));
	dst=malloc(a*sizeof(OBJECT)+4*sizeof(TEDINFO)+2*sizeof(EDIT_OB)+sizeof(WINDOW)+sizeof(DINFO)+sizeof(USERBLK)+4+4*32);
	c=malloc(2);
	el=malloc(sizeof(ED_LIN));
	if((dst==NULL)||(c==NULL)||(el==NULL))
	{
		form_alert(1, gettext(NOMEM));
		if(dst) free(dst);
		if(c) free(c);
		if(el) free(el);
		return(NULL);
	}
	ted=(TEDINFO*)&(dst[a]);
	edob=(EDIT_OB*)&(ted[4]);
	undoedob=&(edob[1]);
	win=(WINDOW*)&(undoedob[1]);
	ddial=(DINFO*)&(win[1]);
	ublk=(USERBLK*)&(ddial[1]);
	ibt=(char*)&(ublk[1]);
	edob->first=el;
	edob->first->line=c; c[0]=0;
	edob->first->quoted=0;
	edob->first->next=NULL;
	c=&(ibt[4]);
	for(b=0; b < a; ++b)
		dst[b]=src[b];
		
	/* TEDINFO-Objekte ersetzen */
	dst[ETO].ob_spec.tedinfo=&(ted[0]);
	dst[ECC].ob_spec.tedinfo=&(ted[1]);
	dst[EBCC].ob_spec.tedinfo=&(ted[2]);
	dst[ESUBJECT].ob_spec.tedinfo=&(ted[3]);
	/* TEDINFO kopieren */
	*(dst[ETO].ob_spec.tedinfo)=*(src[ETO].ob_spec.tedinfo);
	*(dst[ECC].ob_spec.tedinfo)=*(src[ECC].ob_spec.tedinfo);
	*(dst[EBCC].ob_spec.tedinfo)=*(src[EBCC].ob_spec.tedinfo);
	*(dst[ESUBJECT].ob_spec.tedinfo)=*(src[ESUBJECT].ob_spec.tedinfo);
	/* Eigenen Textpointer einsetzen */
	dst[ETO].ob_spec.tedinfo->te_ptext=c; *c=0; c+=32;
	dst[ECC].ob_spec.tedinfo->te_ptext=c; *c=0; c+=32;
	dst[EBCC].ob_spec.tedinfo->te_ptext=c; *c=0; c+=32;
	dst[ESUBJECT].ob_spec.tedinfo->te_ptext=c; *c=0; c+=32;
	/* Xted draus machen */
	objc_xted(dst, ETO, 256, 0);
	objc_xted(dst, ECC, 256, 0);
	objc_xted(dst, EBCC, 256, 0);
	objc_xted(dst, ESUBJECT, 256, 0);
	/* Userblock ersetzen */
	dst[UEDITOR].ob_spec.userblk=ublk;
	/* Userblock kopieren */
	*ublk=*(src[UEDITOR].ob_spec.userblk);

	/* Defaults eintragen */	
	dst[UEDITOR].ob_spec.userblk->ub_parm=(long)win;
	dst[EDSIG].ob_spec.iconblk->ib_ptext=ibt; 
	dst[EDSIG].ob_spec.iconblk->ib_wtext=6;
	dst[EDANHANG].ob_spec.iconblk->ib_ptext=&(ibt[2]); 
	dst[EDANHANG].ob_spec.iconblk->ib_wtext=6;
	ibt[0]='1'; ibt[1]=0;
	ibt[2]='0'; ibt[3]=0;
	edob->undo=undoedob;
	edob->undo->first=NULL;
	edob->pm_om=0;
	edob->references[0]=0;
	edob->reply_to[0]=0;
	edob->changed=0;
	edob->buf_line[0]=0;
	edob->head_height=dst[HEADFRAME].ob_height;	
	edob->cur_x=edob->cur_y=edob->offset=edob->max_x=edob->cur_only=0;
	edob->sel_sx=-1;
	edob->edob=UEDITOR;
	edob->crvis=ios.eyes_on;
	edob->atx_first=NULL;
	
	if(sw_mode)
	{
		dst[EHEAD].ob_spec.iconblk=ovorl[ESWHEADSEL].ob_spec.iconblk;
		dst[EHEAD].ob_type=G_ICON;
		dst[EDSIG].ob_spec.iconblk=ovorl[ED_SW_SIG].ob_spec.iconblk;
		dst[EDSIG].ob_type=G_ICON;
		dst[EDREPLYTO].ob_spec.iconblk=ovorl[ED_NOREPLY].ob_spec.iconblk;
		dst[EDREPLYTO].ob_type=G_ICON;
		if(edob->crvis)
			dst[CRVIS].ob_spec.iconblk=ovorl[CRSWVISUNSEL].ob_spec.iconblk;
		else
			dst[CRVIS].ob_spec.iconblk=ovorl[CRSWVISSEL].ob_spec.iconblk;
		dst[CRVIS].ob_type=G_ICON;
	}
	else
	{
		dst[EHEAD].ob_state |= SELECTED;
		if(edob->crvis)
			dst[CRVIS].ob_state |= SELECTED;
		else
			dst[CRVIS].ob_state &= (~SELECTED);
	}
	w_dinit(win);
	ddial->tree=dst;
	ddial->support=0;
	ddial->osmax=0;
	ddial->odmax=8;
	win->dinfo=ddial;
	w_kdial(win, D_CENTER, MOVE|NAME|BACKDROP|CLOSE|FULL|SIZE|UPARROW|DNARROW|VSLIDE);
	win->closed=eclosed;
	win->sized=esized;
	win->arrowed=earrowed;
	win->vslid=evslid;
	win->fulled=efulled;
	ddial->dservice=NULL;
	ddial->dwservice=do_editor;
	ddial->dwfocus=do_crsr_check;
	ddial->dwkeydispatch=dedkeybd;
	ddial->dedit=ETO;
	win->user=edob;

	if((ios.ewy > 0) && (ios.eww > 0) && (ios.ewh > 0))
		if((ios.ewx+ios.eww <= sx+sw)&&(ios.ewy+ios.ewh <= sy+sh))
		{win->wx=ios.ewx; win->wy=ios.ewy; win->ww=ios.eww; win->wh=ios.ewh;
		if(eds_opened & 1)
		{win->wx+=16; win->wy+=16;
			if(win->wx>=sx+sw) win->wx-=32;
			if(win->wy>=sy+sh) win->wy-=32;}
	}
	w_open(win);

	if((ios.ewy > 0) && (ios.eww > 0) && (ios.ewh > 0))
		if((ios.ewx+ios.eww <= sx+sw)&&(ios.ewy+ios.ewh <= sy+sh))
		{
			pbuf[0]=WM_MOVED; pbuf[1]=ap_id; pbuf[2]=0; pbuf[3]=win->whandle;
			pbuf[4]=ios.ewx; pbuf[5]=ios.ewy; pbuf[6]=ios.eww; pbuf[7]=ios.ewh;
			if(eds_opened & 1)
			{pbuf[4]+=16; pbuf[5]+=16;
				if(pbuf[4]>=sx+sw) pbuf[4]-=32;
				if(pbuf[5]>=sy+sh) pbuf[5]-=32;}
			w_dialmoved(win, pbuf);
			esized(win, pbuf);
		}
	++eds_opened;
	return(win);
}

void objc_xted255cpy(OBJECT *tree, int ob, char *c)
{
	char buf[256];
	
	strncpy(buf, c, 255);
	buf[255]=0;
	objc_xtedcpy(tree, ob, buf);
}

void make_group_editor(WINDOW *win)
{
	((EDIT_OB*)(win->user))->pm_om=1;
	win->dinfo->tree[TO].ob_spec.free_string=ovorl[IN].ob_spec.free_string;
	win->dinfo->tree[ITO].ob_spec.iconblk=ovorl[IIN].ob_spec.iconblk;
	win->dinfo->tree[CC].ob_state|=DISABLED; win->dinfo->tree[ICC].ob_state|=DISABLED; win->dinfo->tree[ECC].ob_state|=DISABLED;
	win->dinfo->tree[BCC].ob_state|=DISABLED; win->dinfo->tree[IBCC].ob_state|=DISABLED; win->dinfo->tree[EBCC].ob_state|=DISABLED;
}

void alert_new_sig(void)
{
	OBJECT *dial;
	int			px,py,dx,dy;

	if(ios.show_sig_warning	== 0) return;
	
	rsrc_gaddr(0,NEW_SIG_ALERT,&dial);
	dial[NEW_SIG_HIDE].ob_state &= (~SELECTED);
	dial[SIGHIDEOK].ob_state &= (~SELECTED);

	wind_update(BEG_MCTRL);
	wind_update(BEG_UPDATE);	

	form_center(dial, &px,&py,&dx,&dy);
	form_dial(FMD_START,px,py,dx,dy,px,py,dx,dy);
	objc_draw(dial,0,8,px,py,dx,dy);
	
	while(form_do(dial,0)!=SIGHIDEOK);
	
	form_dial(FMD_FINISH,px,py,dx,dy,px,py,dx,dy);
	
	wind_update(END_MCTRL);
	wind_update(END_UPDATE);	
	
	if(dial[NEW_SIG_HIDE].ob_state & SELECTED)
		ios.show_sig_warning=0;
}

void ed_open_file(void)
{
	WINDOW	*win;
	char path[256];
	char	name[64];
	long	fhl;	
	EDIT_OB	*edob;

	name[0]=0;
	if(f_sinput(gettext(FILE_OPEN),ios.file_merge_path, name)==0) return;
	make_path(path, ios.file_merge_path, name);

	fhl=Fopen(path, FO_READ);
	if(fhl < 0) {gemdos_alert(gettext(NOOPEN), fhl); return;}

	win=open_editor();
	if(win==NULL) return;
	set_file((EDIT_OB*)(win->user), 0);
	edob=win->user;

	if(ed_file_insert((int)fhl, edob, win->dinfo->tree[edob->edob].ob_width-MESSAGE_OFFSET, 0)==0) return;
	if(edob->offset > edob->cur_y) edob->offset=edob->cur_y; 
	if(edob->offset+win->dinfo->tree[edob->edob].ob_height/ios.efhi <= edob->cur_y) edob->offset=edob->cur_y-win->dinfo->tree[edob->edob].ob_height/ios.efhi+1;
	editor_slide_set(win);
}

void ed_new_file(void)
{
	WINDOW	*win;

	if((win=open_editor())==NULL) return;
	if(ext_type(odial, POPUP)!=1)
	{
		set_file((EDIT_OB*)(win->user), 0);
		if(ios.permanent_reply && (ios.perm_reply_adr[0]))
		{
			strncpy(((EDIT_OB*)(win->user))->reply_to, ios.perm_reply_adr, 63); 
			((EDIT_OB*)(win->user))->reply_to[63]=0;
			if(sw_mode)
				win->dinfo->tree[EDREPLYTO].ob_spec.iconblk=ovorl[ED_REPLY].ob_spec.iconblk;
			else
				win->dinfo->tree[EDREPLYTO].ob_state |= SELECTED;
		}
	}
	else
	{/* In Gruppe */
		set_file((EDIT_OB*)(win->user), 1);
		make_group_editor(win);
		alert_new_sig();
		/* Default-Sig fÅr News ist 2 */
		win->dinfo->tree[EDSIG].ob_spec.iconblk->ib_ptext[0]='2';

		if((fld==NULL)||(fld[0].ftype!=FLD_BAK)) /* In öbersicht */
		{
			if(fld[ios.list_sel].ftype!=FLD_GSD)
				objc_xted255cpy(win->dinfo->tree, ETO, fld[ios.list_sel].from);
			else
				objc_xtedcpy(win->dinfo->tree, ETO, "");
		}
		else if(strcmp(act_fold, "SEND"))	/* In Gruppe */
		{
			fld[0].from[strlen(fld[0].from)-1]=0;
			objc_xted255cpy(win->dinfo->tree, ETO, &((fld[0].from)[4]));
			fld[0].from[strlen(fld[0].from)]=']';
		}
		else
			objc_xtedcpy(win->dinfo->tree, ETO, "");

		if(ios.permanent_reply && (ios.perm_reply_adr[0]) && ios.perm_reply_in_groups)
		{
			strncpy(((EDIT_OB*)(win->user))->reply_to, ios.perm_reply_adr, 63); 
			((EDIT_OB*)(win->user))->reply_to[63]=0;
			if(sw_mode)
				win->dinfo->tree[EDREPLYTO].ob_spec.iconblk=ovorl[ED_REPLY].ob_spec.iconblk;
			else
				win->dinfo->tree[EDREPLYTO].ob_state |= SELECTED;
		}
	}
}

int ed_check_open(void)
{/* PrÅft, ob die zu îffnende Nachricht bereits in einem Editor
 		bearbeitet wird. Wenn ja, wird dieser getoppt und 1 geliefert,
 		sonst 0 */
	WINDOW	*win;
	int a;
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

	/* Alle Editor-Fenster ÅberprÅfen */
	a=0;
	while((win=w_list(a))!=NULL)
	{
		a=1;
		if(ext_type(win->dinfo->tree, 0)!=1) continue;
		if(! stricmp(bpath, ((EDIT_OB*)(win->user))->file))
		{
			w_top(win);
			return(1);
		}
	}
	return(0);
}

void ed_adr_compress(char *buf)
{/* Entfernt alle '<''>` und Texte in Klammern */
	char *c=buf, *d, *e;

	while(*c)
	{
		if((*c=='<') || (*c=='>'))
		{
			d=c+1; e=c;
			while(*d) *e++=*d++;
			*e=0;
		}
		else if(*c=='(')
		{
			e=c; while(*e && (*e!=')')) ++e; 
			if(*e)
			{
				d=c;
				++e; while(*e) *d++=*e++;
				*d=0;
			}
			else *c=0;
		}
		else ++c;
	}
}

void edit_nachricht(void)
{
	EDIT_OB	*edob;
	WINDOW	*win;
	LOADED_MAIL	loadm;
	MAIL_ATX	*atx;
	char		*c, buf[256];
	
	if(load_mail_to(&loadm)==0) return;
	
	win=open_editor();
	if(win==NULL) {free_mail(&loadm); return;}
	edob=win->user;
	set_file((EDIT_OB*)(win->user), -1);

	atx=loadm.first;
	while(atx)
	{
		if(atx->encoding==3)
		{
			atx->atx_len=decode_base_64(atx->atx);
			atx->encoding=4;
		}
		else if(atx->encoding==5)
		{
			decode_quoted_printable(atx->atx);
			atx->atx_len=strlen(atx->atx);
			atx->encoding=0;
		}
		else if(atx->encoding==2)
		{
			decode_iso_8859_1(atx->atx);
			atx->encoding=0;
		}
		atx=atx->next;
	}
	edob->atx_first=loadm.first;
	win->dinfo->tree[EDANHANG].ob_spec.iconblk->ib_ptext[0]=count_anhang(win)+'0';

	/* Keine Signatur */
	if(sw_mode)
		win->dinfo->tree[EDSIG].ob_spec.iconblk=ovorl[ED_SW_NOSIG].ob_spec.iconblk;
	else
		win->dinfo->tree[EDSIG].ob_state |= SELECTED;
	win->dinfo->tree[EDSIG].ob_spec.iconblk->ib_ptext[0]=0;
	win->dinfo->tree[EDSIG].ob_spec.iconblk->ib_wtext=0;
	
	free(loadm.header);	

	if(loadm.body)
	{
		free(edob->first->line);
		edob->first->line=loadm.body;
	}

	if((c=get_head_field("References:"))!=NULL)
		strncpy(edob->references, c, 255);

	buf[0]=buf[255]=0;
	if((c=get_head_field("To:"))!=NULL)
	{
		strncpy(buf, c, 255);
/*		
	if(((c=strchr(buf, '<'))!=NULL) && ((d=strchr(c, '>'))!=NULL))
	{++c; *d=0;}
	else
		c=buf;
	if((d=strchr(buf, '('))!=NULL) *d=0;
*/
		ed_adr_compress(buf);
		c=adr_match(buf);
		objc_xted255cpy(win->dinfo->tree, ETO, c);
	}
	else if((c=get_head_field("Newsgroups:"))!=NULL)
	{
		strncpy(buf, c, 255);
		make_group_editor(win);
		objc_xted255cpy(win->dinfo->tree, ETO, c);
	}

	if((c=get_head_field("Subject:"))!=NULL)
		objc_xted255cpy(win->dinfo->tree, ESUBJECT, c);
	if((c=get_head_field("Cc:"))!=NULL)
		objc_xted255cpy(win->dinfo->tree, ECC, c);
	if((c=get_head_field("Bcc:"))!=NULL)
		objc_xted255cpy(win->dinfo->tree, EBCC, c);

	if((c=get_head_field("Reply-To:"))!=NULL)
	{
		strncpy(edob->reply_to, c, 63); edob->reply_to[63]=0;
		if(sw_mode)
			win->dinfo->tree[EDREPLYTO].ob_spec.iconblk=ovorl[ED_REPLY].ob_spec.iconblk;
		else
			win->dinfo->tree[EDREPLYTO].ob_state |= SELECTED;
	}


	/* Da noch kein Redraw stattgefunden hat, genÅgt das Neusetzen
			des Cursors ins Editor-Feld */
	win->dinfo->cpos=0;
	win->dinfo->dedit=0;
	win->dinfo->curon=0;

	usr_umbrechen(edob, win->dinfo->tree[((EDIT_OB*)(win->user))->edob].ob_width-MESSAGE_OFFSET);
	if(edob->first->line)
		strcpy(edob->buf_line, edob->first->line);
	editor_slide_set(win);
}

void	nachricht_an(char *to, char *cc, char *bcc, char *subj)
{
	WINDOW	*win=open_editor();
	
	if(win==NULL) return;
	set_file((EDIT_OB*)(win->user), 0);
	if(to)
		objc_xted255cpy(win->dinfo->tree, ETO, to);
	if(cc)
		objc_xted255cpy(win->dinfo->tree, ECC, cc);
	if(bcc)
		objc_xted255cpy(win->dinfo->tree, EBCC, bcc);
	if(subj)
		objc_xted255cpy(win->dinfo->tree, ESUBJECT, subj);

	if(ios.permanent_reply && (ios.perm_reply_adr[0]))
	{
		strncpy(((EDIT_OB*)(win->user))->reply_to, ios.perm_reply_adr, 63); 
		((EDIT_OB*)(win->user))->reply_to[63]=0;
		if(sw_mode)
			win->dinfo->tree[EDREPLYTO].ob_spec.iconblk=ovorl[ED_REPLY].ob_spec.iconblk;
		else
			win->dinfo->tree[EDREPLYTO].ob_state |= SELECTED;
	}

	/* Da noch kein Redraw stattgefunden hat, genÅgt das Neusetzen
			des Cursors ins Editor-Feld */
	win->dinfo->cpos=0;
	win->dinfo->dedit=ETO;
	if(to||cc||bcc)
	{
		win->dinfo->dedit=ESUBJECT;
		if(subj)
		{
			win->dinfo->dedit=0;	/* Editor */
			win->dinfo->curon=0;
		}
	}
}

void beantworten(void)
{
	OBJECT 	*tree;
	WINDOW	*win=open_editor();
	char		*c, *d, buf[256];
	
	if(win==NULL) return;

	set_file((EDIT_OB*)(win->user), 0);

	/* Ursprungsnachricht als beantwortet markieren */
	if(db_mode)
	{
		Idx_setflag(fld[ios.list_sel].idx, FF_ANS);
		fld[ios.list_sel].fspec.finfo.flags |= FF_ANS;
		check_draw_list(0);
	}
	
	/* Da noch kein Redraw stattgefunden hat, genÅgt das Neusetzen
			des Cursors ins Editor-Feld */
	win->dinfo->cpos=0;
	win->dinfo->dedit=0;
	win->dinfo->curon=0;

	if(ios.permanent_reply && (ios.perm_reply_adr[0]))
	{
		strncpy(((EDIT_OB*)(win->user))->reply_to, ios.perm_reply_adr, 63); 
		((EDIT_OB*)(win->user))->reply_to[63]=0;
		if(sw_mode)
			win->dinfo->tree[EDREPLYTO].ob_spec.iconblk=ovorl[ED_REPLY].ob_spec.iconblk;
		else
			win->dinfo->tree[EDREPLYTO].ob_state |= SELECTED;
	}

	if((c=get_head_field("Message-ID:"))!=NULL)
		strncpy(((EDIT_OB*)(win->user))->references, c, 255);
	buf[0]=buf[255]=0;
	if((c=get_head_field("Reply-To:"))!=NULL)
		strncpy(buf, c, 255);
	else if((c=get_head_field("Resent-From:"))!=NULL)
		strncpy(buf, c, 255);
	else if((c=get_head_field("From:"))!=NULL)
		strncpy(buf, c, 255);
	if(((c=strchr(buf, '<'))!=NULL) && ((d=strchr(c, '>'))!=NULL))
	{++c; *d=0;}
	else
		c=buf;
	if((d=strchr(buf, '('))!=NULL) *d=0;
	objc_xted255cpy(win->dinfo->tree, ETO, c);
	if((c=get_head_field("Subject:"))!=NULL)
	{
		if(strnicmp(c, "Re:", 3))
		{
			strcpy(buf, "Re: ");
			strncat(buf, c, 252);
		}
		else
			strncpy(buf, c, 255);
		buf[255]=0;
		objc_xted255cpy(win->dinfo->tree, ESUBJECT, buf);
	}
	if((c=get_head_field("Cc:"))!=NULL)
	{
		rsrc_gaddr(0, TAKECC, &tree);
		lock_menu(omenu);
		if(w_do_dial(tree)==CCBOTH)
		{
			objc_xted255cpy(win->dinfo->tree, ECC, c);
			w_objc_draw(win, ECC, 8, sx,sy,sw,sh);
		}
		tree[CCBOTH].ob_state &= (~SELECTED);
		tree[CCABSONLY].ob_state &= (~SELECTED);
		unlock_menu(omenu);
	}
	/* Bcc nicht Åbernehmen
	if((c=get_head_field("Bcc:"))!=NULL)
		objc_xted255cpy(win->dinfo->tree, EBCC, c);
	*/
	
}

void beitrag(void)
{
	OBJECT	*tree;
	WINDOW	*win=open_editor();
	char		*c, *d, buf[256];
	
	if(win==NULL) return;
	/* "To:"=Newsgroup */
	make_group_editor(win);
	alert_new_sig();
	/* Default-Sig fÅr News ist 2 */
	win->dinfo->tree[EDSIG].ob_spec.iconblk->ib_ptext[0]='2';
	set_file((EDIT_OB*)(win->user), 1);

	if(ios.permanent_reply && (ios.perm_reply_adr[0]) && ios.perm_reply_in_groups )
	{
		strncpy(((EDIT_OB*)(win->user))->reply_to, ios.perm_reply_adr, 63); 
		((EDIT_OB*)(win->user))->reply_to[63]=0;
		if(sw_mode)
			win->dinfo->tree[EDREPLYTO].ob_spec.iconblk=ovorl[ED_REPLY].ob_spec.iconblk;
		else
			win->dinfo->tree[EDREPLYTO].ob_state |= SELECTED;
	}

	/* Da noch kein Redraw stattgefunden hat, genÅgt das Neusetzen
			des Cursors ins Editor-Feld */
	win->dinfo->cpos=0;
	win->dinfo->dedit=0;
	win->dinfo->curon=0;

	buf[0]=buf[255]=0;
	if((c=get_head_field("References:"))!=NULL)
	{
		d=get_head_field("Message-ID:");
		if(d==NULL) d="";
		while(strlen(c)+strlen(d)+1 > 255)
		{
			while(*c && (*c!='>') && (*(c+1) != ' ')) ++c;
			if(c) c+=2;
			else break;
		}
		strcpy(buf, c);
		if(strlen(d))
		{
			if(strlen(c)) strcat(buf, " ");
			strncat(buf, d, 254);
		}
	}
	else if((c=get_head_field("Message-ID:"))!=NULL)
		strncpy(buf, c, 255);
	strcpy(((EDIT_OB*)(win->user))->references, buf);

	buf[0]=buf[255]=0;
	if((c=get_head_field("Followup-To:"))!=NULL)
		strncpy(buf, c, 255);
	else
	{
		fld[0].from[strlen(fld[0].from)-1]=0;
		strcpy(buf, &((fld[0].from)[4]));
		fld[0].from[strlen(fld[0].from)]=']';
	}
	objc_xted255cpy(win->dinfo->tree, ETO, buf);
	buf[0]=buf[255]=0;
	if((c=get_head_field("Subject:"))!=NULL)
	{
		if(strnicmp(c, "Re:", 3))
		{
			strcpy(buf, "Re: ");
			strncat(buf, c, 252);
		}
		else
		{
			strncpy(buf, c, 255);
		}
		buf[255]=0;
		objc_xted255cpy(win->dinfo->tree, ESUBJECT, buf);
	}
	if((c=get_head_field("Cc:"))!=NULL)
	{
		rsrc_gaddr(0, TAKECC, &tree);
		lock_menu(omenu);
		if(w_do_dial(tree)==CCBOTH)
		{
			objc_xted255cpy(win->dinfo->tree, ECC, c);
			w_objc_draw(win, ECC, 8, sx,sy,sw,sh);
		}
		tree[CCBOTH].ob_state &= (~SELECTED);
		tree[CCABSONLY].ob_state &= (~SELECTED);
		unlock_menu(omenu);
	}
	/* Bcc nicht Åbernehmen 
	if((c=get_head_field("Bcc:"))!=NULL)
		objc_xted255cpy(win->dinfo->tree, EBCC, c);
	*/
}

/* -------------------------------------- */

void edit_sel_search_string(EDIT_OB *edob)
{
	OBJECT 	*tree;
	long		cnt, xoff=0;
	ED_LIN	*el=edob->first;
	char		*w, *c;

	rsrc_gaddr(0, SEARCH, &tree);

	cnt=0;
	if(edob->sel_sx > -1)
	{
		while((el) && (cnt < edob->sel_sy))
		{	el=el->next;	++cnt;}
		if(!el) {edob->sel_sx=-1; return;}
		w=el->line;
		/* Sel-Start+1 dazuzÑhlen, damit nicht nochmal gleiche Fundstelle */
		w+=edob->sel_sx+1;
		xoff=edob->sel_sx+1;
	}
	else if(el) w=el->line;

	if((!el) || (el->line==NULL)) {edob->sel_sx=-1; return;}

	while(el)
	{
		if(tree[SEGRKL].ob_state & SELECTED)
		{/* GROSS=klein (stristr) */
			if((c=stristr(w, tree[SEARCHSTRING].ob_spec.tedinfo->te_ptext))!=NULL)
			{
				edob->sel_sy=edob->sel_ey=cnt;
				edob->sel_sx=(c-w)+xoff;
				edob->sel_ex=edob->sel_sx+strlen(tree[SEARCHSTRING].ob_spec.tedinfo->te_ptext);
				return;
			}
		}
		else
		{
			if((c=strstr(w, tree[SEARCHSTRING].ob_spec.tedinfo->te_ptext))!=NULL)
			{
				edob->sel_sy=edob->sel_ey=cnt;
				edob->sel_sx=(c-w)+xoff;
				edob->sel_ex=edob->sel_sx+strlen(tree[SEARCHSTRING].ob_spec.tedinfo->te_ptext);
				return;
			}
		}
		xoff=0;
		el=el->next;
		if(el) w=el->line;
		++cnt;
	}
	edob->sel_sx=-1;
}

/* -------------------------------------- */

void edit_search(WINDOW *win)
{
	EDIT_OB	*edob=win->user;
	
	if(store_buf(edob)==0) {Bell(); return;}
	edit_sel_search_string(edob);
	if(edob->sel_sx==-1)
		Bell(); 
	else	/* Anzeige auf Sel-Offset bringen */
	{
		edob->cur_x=edob->sel_sx;
		edob->cur_y=edob->sel_sy;
		edob->offset=edob->sel_sy;
		strcpy(edob->buf_line, get_ed_lin(edob)->line);
	}
	editor_slide_set(win);
	w_objc_draw(win, edob->edob, 8, sx,sy,sw,sh);
}

/* -------------------------------------- */

void ed_extent(char *c, int *ex)
{
	ex[2]=0;
	while(*c)
		ex[2]+=ios.ecwidth[(uchar)(*c++)];
}

int store_buf(EDIT_OB *edob)
{/* Schreibt buf_line in die aktuelle Zeile. 1=Ok, 0=Kein Speicher */
	char 		*ss;
	ED_LIN	*el;
	
	ss=malloc(strlen(edob->buf_line)+1);
	if(ss==NULL) return(0);
	strcpy(ss, edob->buf_line);
	el=get_ed_lin(edob);
	free(el->line); el->line=ss;
	return(1);
}

long ed_get_char(EDIT_OB	*edob, long line, int x_pix)
{
	long	cnt=0;
	char	*w;
	ED_LIN	*el=edob->first;

	if(x_pix < 0) return(0);
		
	while((cnt < line) && (el))
	{	el=el->next;	++cnt;}

	if(el==NULL) return(0);
	if((w=el->line)==NULL) return(0);
	if(el->quoted) x_pix-=ios.eqwi;
	return(get_cur_x(w, x_pix));
}

void ed_cur_sel(WINDOW *win)
{
	EDIT_OB	*edob=win->user;
	ED_LIN	*el;
	char	*c;
	int 	mx, my, mb, kb, ox, oy, vis_line, ry1, ry2;
	long	ol=-1, oc=-1, mty, mtx, ity, itx, llines;

	/* Buffer in Edob kopieren */
	c=malloc(strlen(edob->buf_line)+1);
	if(c==NULL) {Bell(); return;}
	el=get_ed_lin(edob);
	free(el->line);
	el->line=c;
	strcpy(c, edob->buf_line);
	
	llines=count_lines(edob);
	pbuf[0]=WM_ARROWED; pbuf[3]=win->whandle;	
	objc_offset(win->dinfo->tree, edob->edob, &ox, &oy);
	ox+=MESSAGE_OFFSET;
	vis_line=(win->dinfo->tree[edob->edob].ob_height/ios.efhi)*ios.efhi;
	graf_mkstate(&mx, &my, &mb, &kb);
	mx-=ox; my-=oy;
	if(kb & 3)
	{
	 	if(edob->sel_sx > -1)
	 	{
			ity=edob->sel_sy;
			itx=edob->sel_sx;
		}
		else
		{
			ity=edob->cur_y;
			itx=edob->cur_x;
		}
	}
	else
	{
		ity=edob->offset+(long)my/ios.efhi;
		if(ity >= llines) ity=llines-1;
		itx=ed_get_char(edob, ity, mx);
	}

	edob->cur_x=itx;
	edob->cur_y=ity;
	el=get_ed_lin(edob);
	strcpy(edob->buf_line, el->line);
	if(edob->buf_line[edob->cur_x-1]==13) --edob->cur_x;

	do
	{
		graf_mkstate(&mx, &my, &mb, &kb);
		mx-=ox; my-=oy;
		if(my < 0) { my=0;  pbuf[4]=WA_UPLINE; earrowed(win, pbuf);}
		if(my > vis_line) { my=vis_line;  pbuf[4]=WA_DNLINE; earrowed(win, pbuf);}
		mty=edob->offset+(long)my/ios.efhi;
		if(mty >= llines) mty=llines-1;
		if(mx > win->dinfo->tree[edob->edob].ob_width) mx=win->dinfo->tree[edob->edob].ob_width;
		mtx=ed_get_char(edob, mty, mx);
		if((mty==ol) && (mtx==oc)) continue;
		if(mty < ity)
		{
			edob->sel_sy=mty; edob->sel_sx=mtx; edob->sel_ey=ity; edob->sel_ex=itx;
		}
		else if(mty > ity)
		{
			edob->sel_sy=ity; edob->sel_sx=itx; edob->sel_ey=mty; edob->sel_ex=mtx;
		}
		else	/* mty==ity */
		{
			if(mtx==itx)
			{
				edob->sel_sx=-1;
			}
			else
			{
				edob->sel_sy=edob->sel_ey=ity;
				if(mtx < itx)
				{ edob->sel_sx=mtx; edob->sel_ex=itx; }
				else
				{ edob->sel_sx=itx; edob->sel_ex=mtx; }
			}
		}
		ry1=(int)(ol-edob->offset)*ios.efhi+oy;
		ry2=(int)(mty-edob->offset)*ios.efhi+oy;
		if(ry2 < ry1) {my=ry2;ry2=ry1;ry1=my;}
		if(ol==-1)
		{
			w_objc_draw(win, edob->edob, 8, sx,sy,sw,sh);
		}
		else
			w_objc_draw(win, edob->edob, 8, sx,ry1,sw,ry2-ry1+ios.efhi);
		ol=mty; oc=mtx;
	}while(mb & 3);
}

void ed_url_check(WINDOW *win)
{
	EDIT_OB	*edob=win->user;
	ED_LIN *el;
	long		a;
	char		*w;

	if(edob->sel_sx == -1) return;

	el=edob->first;
	a=edob->sel_sy;
	while(a--) el=el->next;
	w=&(el->line[edob->sel_sx]);

	if(strnicmp(w, "http://", 7) && strnicmp(w+1, "http://", 7) &&
		 strnicmp(w, "ftp://", 6) && strnicmp(w+1, "ftp://", 6) &&
		 strnicmp(w, "mailto:", 7) && strnicmp(w+1, "mailto:", 7)) return;
		 
	ed_copy(edob);
	clip_url();
}

void ed_do_double(WINDOW *win)
{
	EDIT_OB	*edob=win->user;
	ED_LIN	*el, *bel;
	char	*c;
	long	cnt=0;
	int 	mx, my, dum, ox, oy;
	long	ity, itx, esx, esy, eex, eey, llines;

	/* Buffer in Edob kopieren */
	if(store_buf(edob)==0) {Bell(); return;}
	
	llines=count_lines(edob);
	objc_offset(win->dinfo->tree, edob->edob, &ox, &oy);
	ox+=MESSAGE_OFFSET;
	graf_mkstate(&mx, &my, &dum, &dum);
	mx-=ox; my-=oy;

	/* Startzeile */
	ity=edob->offset+(long)my/ios.efhi;
	if(ity >= llines) return;

	/* Startzeichen */
	if(mx < 0) return;

	el=edob->first;		
	while((cnt < ity) && (el))
	{	el=el->next;	++cnt;}

	if(el==NULL) return;
	if((c=el->line)==NULL) return;
	if(el->quoted) mx-=ios.eqwi;
	itx=get_cur_x(c, mx);

	esy=ity; esx=itx;
	while(esy >= 0)
	{
		if(esx)
		{
			if((c[esx-1]==' ')||(c[esx-1]==9)) break;
			--esx;
		}
		else
		{
			bel=edob->first; --esy; cnt=0;
			while((cnt < esy) && (bel))
			{	bel=bel->next;	++cnt;}
			if((c=bel->line)==NULL) return;
			esx=strlen(c);
			if((c[esx-1]==13)||(c[esx-1]==' ')||(c[esx-1]==9)) {++esy; esx=0; break;}
		}
	}
	if(esy < 0) {esy=0; esx=0;}

	eey=ity; eex=itx; c=el->line;
	while(eey < llines)
	{
		if(c[eex+1])
		{
			if((c[eex+1]==13)||(c[eex+1]==' ')||(c[eex+1]==9)) break;
			++eex;
		}
		else
		{
			if((el=el->next)==NULL) break;
			if((c=el->line)==NULL) return;
			if((c[eex]==13)||(c[eex]==' ')||(c[eex]==9)) {--eey; break;}
			++eey; eex=0;
		}
	}
	++eex;
	edob->sel_sy=esy; edob->sel_sx=esx; edob->sel_ey=eey; edob->sel_ex=eex;
	w_objc_draw(win, edob->edob, 8, sx,sy,sw,sh);
	
	ed_url_check(win);
}

int count_anhang(WINDOW *win)
{
	int				c=0;
	MAIL_ATX *ma=((EDIT_OB*)(win->user))->atx_first;
	
	while(ma){++c; ma=ma->next;}
	return(c);
}

void add_file_as_anhang(WINDOW *win, char *path)
{
	char	name[64];
	long fhl, flen;
	int	fh, mx, my;
	char	*c;
	MAIL_ATX	**patx, *atx;

	c=&(path[strlen(path)]);
	while((c > path) && (*c != '\\')) --c;
	if(*c == '\\') ++c;
	strncpy(name, c, 63);
	name[63]=0;
	
	fhl=Fopen(path, FO_READ); fh=(int)fhl;
	if(fhl < 0) {gemdos_alert(gettext(NOOPEN), fhl); return;}
	graf_mouse(BUSYBEE, NULL);
	flen=Fseek(0, fh, 2); Fseek(0, fh, 0);
	if(flen < 1){graf_mouse(ARROW, NULL); form_alert(1, gettext(EMPTYFILE)); Fclose(fh); return;}
	c=malloc(flen);
	if(c==NULL){graf_mouse(ARROW, NULL);form_alert(1, gettext(NOMEM)); Fclose(fh); return;}
	Fread(fh, flen, c);
	Fclose(fh);

	patx=&(((EDIT_OB*)(win->user))->atx_first);
	while(*patx) patx=&((*patx)->next);
	atx=*patx=malloc(sizeof(MAIL_ATX));
	if(atx==NULL) {graf_mouse(ARROW, NULL); form_alert(1, gettext(NOMEM)); free(c); return;}
	((EDIT_OB*)(win->user))->changed=1;
	atx->atx=c;
	atx->atx_len=flen;
	atx->next=NULL;
	strcpy(atx->file_name, name);
	c=suffix(name); 
	if(c)
	{
		++c;
		if(!stricmp(c, "TXT"))
			strcpy(atx->mime_type, "text/plain");
		else if(!stricmp(c, "RTF"))
			strcpy(atx->mime_type, "text/richtext");
		else if(!stricmp(c, "HTM"))
			strcpy(atx->mime_type, "text/html");
		else if(!stricmp(c, "TXT"))
			strcpy(atx->mime_type, "message/");
		else if(!stricmp(c, "BIN"))
			strcpy(atx->mime_type, "application/octet-stream");
		else if(!stricmp(c, "PS"))
			strcpy(atx->mime_type, "application/postscript");
		else if(!stricmp(c, "ZIP"))
			strcpy(atx->mime_type, "application/zip");
		else if(!stricmp(c, "DOC"))
			strcpy(atx->mime_type, "msword");
		else if(!stricmp(c, "JPG"))
			strcpy(atx->mime_type, "image/jpeg");
		else if(!stricmp(c, "GIF"))
			strcpy(atx->mime_type, "image/gif");
		else if(!stricmp(c, "IEF"))
			strcpy(atx->mime_type, "image/ief");
		else if(!stricmp(c, "TIF"))
			strcpy(atx->mime_type, "image/tiff");
		else if(!stricmp(c, "SMP"))
			strcpy(atx->mime_type, "audio/basic");
		else if(!stricmp(c, "MPG"))
			strcpy(atx->mime_type, "video/mpeg");
		else if(!stricmp(c, "MOV"))
			strcpy(atx->mime_type, "video/quicktime");
		else
			strcpy(atx->mime_type, "application/octet-stream");
	}
	else
		strcpy(atx->mime_type, "application/octet-stream");

	win->dinfo->tree[EDANHANG].ob_spec.iconblk->ib_ptext[0]=count_anhang(win)+'0';
	objc_offset(win->dinfo->tree, EDANHANG, &mx, &my);
	w_objc_draw(win, 0, 8, mx, my, win->dinfo->tree[EDANHANG].ob_width, win->dinfo->tree[EDANHANG].ob_height);
	graf_mouse(ARROW, NULL);
}

void add_anhang(WINDOW *win)
{
	char path[256];
	char	name[64];

	name[0]=0;

	if(count_anhang(win)==9)
	{
		form_alert(1, gettext(EDMAXANHANG));
		return;
	}
	if(f_sinput(gettext(ATX_OPEN),ios.atx_load_path, name)==0) return;
	make_path(path, ios.atx_load_path, name);
	add_file_as_anhang(win, path);
}

void del_anhang(WINDOW *win)
{
	OBJECT 	*tree, *root;
	MAIL_ATX	*atx=((EDIT_OB*)(win->user))->atx_first, **patx;
	char		*strings, *titel;
	int			a, num=count_atx(atx), mx, my, kbs;
	long		slen;

	if(count_anhang(win)==0) {Bell(); return;}

	if(num==0) return;
	++num;	/* FÅr Titel */	
	graf_mkstate(&mx, &my, &a, &kbs);
	titel=gettext(ATX_DEL);
	
	rsrc_gaddr(0, POPVORL, &root);
	slen=atx_maxlen(atx)+4; /* Zwei Space vorne, eins hinten, eine 0 */
	if(slen < strlen(titel)+1)
		slen=strlen(titel)+1;
	
	tree=malloc((num+1)*sizeof(OBJECT)+num*slen);
	if(tree==NULL) {form_alert(1, gettext(NOMEM)); return;}
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
		if(atx->file_name[0])
			strcat(strings, atx->file_name);
		else
			strcat(strings, atx->mime_type);
		strings+=slen;
		tree[a].ob_y=root[1].ob_height*(a-1);
		if(a > 1) atx=atx->next;
	}
	tree[num].ob_next=0;
	tree[num].ob_flags|=LASTOB;
	/* Titel */
	strcpy(tree[1].ob_spec.free_string, titel);
	tree[1].ob_flags &= (~SELECTABLE);
	a=form_popup(tree, mx, my-(tree[1].ob_height*3)/2);
	free(tree);

	if(a < 2) return;
	a-=2;

	((EDIT_OB*)(win->user))->changed=1;
	patx=&(((EDIT_OB*)(win->user))->atx_first);
	while(a--) patx=&((*patx)->next);
	atx=*patx;
	*patx=(*patx)->next;
	free(atx->atx);
	free(atx);

	win->dinfo->tree[EDANHANG].ob_spec.iconblk->ib_ptext[0]=count_anhang(win)+'0';
	objc_offset(win->dinfo->tree, EDANHANG, &mx, &my);
	w_objc_draw(win, 0, 8, mx, my, win->dinfo->tree[EDANHANG].ob_width, win->dinfo->tree[EDANHANG].ob_height);
}

void anh_popup(WINDOW *win)
{
	OBJECT *tree;
	int		 res, mx, my;

	if(Kbshift(-1) & 4)	/* CTRL=Anhang lîschen */
		res=4;
	else if(Kbshift(-1) & 8) /* Alt=Anhang hinzufÅgen */
		res=2;
	else /* Auswahl per Popup */
	{
		rsrc_gaddr(0, EDANHPOP, &tree);
		graf_mkstate(&mx, &my, &res, &res);
		res=form_popup(tree, mx, my);
	}

	if(res < 1) return;
	if(res < 3) add_anhang(win);
	else del_anhang(win);
}

void sig_popup(WINDOW *win)
{
	OBJECT *tree;
	int		 res, mx, my;
	
	rsrc_gaddr(0, SIGPOP, &tree);
	graf_mkstate(&mx, &my, &res, &res);
	res=form_popup(tree, mx, my);
	if((res==2)||(res==3)||(res==4)||(res==6))
	{
		if(res < 6)
		{
			if(sw_mode)
				win->dinfo->tree[EDSIG].ob_spec.iconblk=ovorl[ED_SW_SIG].ob_spec.iconblk;
			else
				win->dinfo->tree[EDSIG].ob_state &= ~SELECTED;
			win->dinfo->tree[EDSIG].ob_spec.iconblk->ib_ptext[0]=res+'0'-1;
			win->dinfo->tree[EDSIG].ob_spec.iconblk->ib_wtext=6;
		}
		else
		{
			if(sw_mode)
				win->dinfo->tree[EDSIG].ob_spec.iconblk=ovorl[ED_SW_NOSIG].ob_spec.iconblk;
			else
				win->dinfo->tree[EDSIG].ob_state |= SELECTED;
			win->dinfo->tree[EDSIG].ob_spec.iconblk->ib_ptext[0]=0;
			win->dinfo->tree[EDSIG].ob_spec.iconblk->ib_wtext=0;
		}
		((EDIT_OB*)(win->user))->changed=1;
	}
	objc_offset(win->dinfo->tree, EDSIG, &mx, &my);
	w_objc_draw(win, 0, 8, mx, my, win->dinfo->tree[EDSIG].ob_width, win->dinfo->tree[EDSIG].ob_height);
}

void set_reply_to(WINDOW *win)
{
	OBJECT *tree;
	int		 mx, my;
	
	rsrc_gaddr(0, REPLYTO, &tree);
	tree[ERTOK].ob_state &= (~SELECTED);
	tree[ERTABBRUCH].ob_state &= (~SELECTED);
	
	objc_xtedcpy(tree, EREPLYTO, ((EDIT_OB*)(win->user))->reply_to);

	lock_menu(omenu);
	if(w_do_dial(tree)==ERTABBRUCH) {unlock_menu(omenu); return;}
	unlock_menu(omenu);
	strcpy(((EDIT_OB*)(win->user))->reply_to, xted(tree, EREPLYTO)->te_ptext);
	if(((EDIT_OB*)(win->user))->reply_to[0])
	{
		if(sw_mode)
			win->dinfo->tree[EDREPLYTO].ob_spec.iconblk=ovorl[ED_REPLY].ob_spec.iconblk;
		else
			win->dinfo->tree[EDREPLYTO].ob_state |= SELECTED;
	}
	else
	{
		if(sw_mode)
			win->dinfo->tree[EDREPLYTO].ob_spec.iconblk=ovorl[ED_NOREPLY].ob_spec.iconblk;
		else
			win->dinfo->tree[EDREPLYTO].ob_state &= (~SELECTED);
	}
	objc_offset(win->dinfo->tree, EDREPLYTO, &mx, &my);
	w_objc_draw(win, 0, 8, mx, my, win->dinfo->tree[EDREPLYTO].ob_width, win->dinfo->tree[EDREPLYTO].ob_height);
}

void ed_save_as(WINDOW *win)
{
	EDIT_OB *edob=win->user;
	long	fhl;
	char path[256];
	char	name[64];

	name[0]=0;
	if(f_sinput(gettext(FILE_SAVE_AS),ios.file_save_as_path, name)==0) return;
	make_path(path, ios.file_save_as_path, name);
	fhl=Fopen(path, FO_READ);
	if(fhl > -1)
	{
		Fclose((int)fhl);
		if(form_alert(1,gettext(FILE_EXIST))==2) return;
	}	
	if(store_buf(edob)==0)
	{
		Fclose((int)fhl);
		form_alert(1, gettext(NOMEM)); 
		return;
	}
	if(xted(win->dinfo->tree, ETO)->te_ptext[0]==0)
	{	
		Fclose((int)fhl);
		form_alert(1, gettext(NORCP)); 
		return;
	}
	if((edob->atx_first==NULL) && ((edob->first==NULL)||(edob->first->line[0]==0)))
	{
		Fclose((int)fhl);
		form_alert(1, gettext(NOCNT)); 
		return;
	}
	no_at_warning=0;
	save_mail_as(path, win);
	if(no_at_warning) form_alert(1, gettext(NOATADDRESS));
}

int mail_path_is_act_path(char *mpath)
{
	char	bpath[256];
	
	strcpy(bpath, db_path);

	switch(ios.list)
	{
		case 0:
			strcat(bpath, "\\PM\\");
		break;
		case 1:
			if((fld==NULL)||(fld_c==0)) return(0);
			if(fld[0].ftype!=FLD_BAK) return(0);
			strcat(bpath, "\\OM\\");
			strcat(bpath, act_fold);
			strcat(bpath, "\\");
		break;
		case 2:
			if((fld==NULL)||(fld_c==0)) return(0);
			if(fld[0].ftype!=FLD_BAK) return(0);
			strcat(bpath, "\\ORD\\");
			strcat(bpath, act_fold);
			strcat(bpath, "\\");
		break;
		case 3:
			strcat(bpath, "\\DEL\\");
		break;
	}
	if(strnicmp(mpath, bpath, strlen(bpath))) return(0);
	return(1);
}

int ed_save_mail(WINDOW *win)
{
	EDIT_OB *edob=win->user;
	char	*c;	
	
	if(store_buf(edob)==0)
	{
		form_alert(1, gettext(NOMEM)); 
		return(0);
	}
	if(xted(win->dinfo->tree, ETO)->te_ptext[0]==0)
	{	
		form_alert(1, gettext(NORCP)); 
		return(0);
	}
	if((edob->atx_first==NULL) && ((edob->first==NULL)||(edob->first->line[0]==0)))
	{
		form_alert(1, gettext(NOCNT)); 
		return(0);
	}
	no_at_warning=0;
	if(save_mail(win)==0) return(0);
	if(no_at_warning) form_alert(1, gettext(NOATADDRESS));

	edob->changed=0;
	c=&(edob->file[strlen(edob->file)-1]);
	while(*(c-1)!='\\')--c;
	if(mail_path_is_act_path(edob->file))
		add_to_fld(c, Tgettime(), Tgetdate(), xted(win->dinfo->tree,ETO)->te_ptext, xted(win->dinfo->tree,ESUBJECT)->te_ptext);

	actize_mail(edob->file);
	if(edob->pm_om) actize_om_sndlst();

	return(1);
}

void ed_remove_from_fld(char *file)
{/* file mit ganzem Pfad! */
	char *fname, buf[30];
	
	fname=&(file[strlen(file)-1]);
	while(*(fname-1)!='\\')--fname;
	
	if(strstr(file, "\\DATABASE\\PM\\") && (ios.list==0))
	{/* PMs */
		remove_from_fld(fname);
		return;
	}

	if(strstr(file, "\\DATABASE\\OM\\") && (ios.list==1) && (fld) && (fld[0].ftype==FLD_BAK))
	{
		strcpy(buf, "\\DATABASE\\OM\\");
		strcat(buf, act_fold);
		strcat(buf, "\\");
		if(strstr(file, buf))
			remove_from_fld(fname);
	}
}

void	do_editor(WINDOW *win, int ob)
{
	char		send_file[256];
	EDIT_OB	*edob=win->user;
	int evnt, mx, my, klicks, dum;
	
	switch(ob)
	{
		case EDSAVE: case IEDSAVE:
			if(ehead_sel(win))
				if(!w_wo_ibut_sel(win, ob)) break;
			ed_save_mail(win);
			if(ehead_sel(win))
				w_wo_ibut_unsel(win, ob);
		break;
		
		case EDSEND: case IEDSEND:
			if(ehead_sel(win))
				if(!w_wo_ibut_sel(win, ob)) break;
			if(ed_save_mail(win)==1)
			{
				strcpy(send_file, edob->file);
				ed_kill_win(win);
				lock_menu(omenu);
				send_now(send_file);
				unlock_menu(omenu);
				switch_list(0);
			}
			if(ehead_sel(win))
				w_wo_ibut_unsel(win, ob);
		break;
		
		case EDKILL: case IEDKILL:
			if(ehead_sel(win))
				if(!w_wo_ibut_sel(win, ob)) break;
			if(form_alert(1, gettext(EDVERWERF))==1)
			{/* Ok */
/*				ed_remove_from_fld(edob->file);*/
				ed_kill_file(edob);
				ed_kill_win(win);
				return;
			}
			if(ehead_sel(win))
				w_wo_ibut_unsel(win, ob);
		break;
		
		case EHEAD:
			if(ehead_sel(win))	/* Ist bereits selektiert (aufgeklappt) */
			{/* Zuklappen */
				if(sw_mode)
					win->dinfo->tree[EHEAD].ob_spec.iconblk=ovorl[ESWHEADUNSEL].ob_spec.iconblk;
				else
					win->dinfo->tree[EHEAD].ob_state &= (~SELECTED);
				win->dinfo->tree[HIDEFRAME].ob_flags |= HIDETREE;
				win->dinfo->tree[HEADFRAME].ob_height=win->dinfo->tree[HIDEFRAME].ob_y;
				if(win->dinfo->dedit > ETO)
				{
					w_dialcursor(win, D_CUROFF);
					win->dinfo->cpos=0;
					win->dinfo->dedit=ETO;
					w_dialcursor(win, D_CURON);
				}
			}
			else
			{/* Aufklappen */
				if(sw_mode)
					win->dinfo->tree[EHEAD].ob_spec.iconblk=ovorl[ESWHEADSEL].ob_spec.iconblk;
				else
					win->dinfo->tree[EHEAD].ob_state |= SELECTED;
				win->dinfo->tree[HIDEFRAME].ob_flags &= (~HIDETREE);
				win->dinfo->tree[HEADFRAME].ob_height=((EDIT_OB*)(win->user))->head_height;
			}
			w_objc_draw(win, ob, 8, sx,sy,sw,sh);
			win->dinfo->tree[EDFRAME].ob_y=win->dinfo->tree[HEADFRAME].ob_height;
			win->dinfo->tree[EDFRAME].ob_height=win->dinfo->tree[0].ob_height-win->dinfo->tree[HEADFRAME].ob_height;
			win->dinfo->tree[FEDFRAME].ob_height=win->dinfo->tree[edob->edob].ob_height=win->dinfo->tree[EDFRAME].ob_height-2*win->dinfo->tree[FEDFRAME].ob_y;
			editor_slide_set(win);
			s_redraw(win);
		break;

		case TO: case ITO: case CC: case ICC: case BCC: case IBCC:
			if(!w_wo_ibut_sel(win, ob)) break;
			w_wo_ibut_unsel(win, ob);
			if(edob->pm_om && ((ob==TO)||(ob==ITO)))
			{/* Gruppen-Popup */
				dum=group_popup(grp_inf.addr, grp_inf.addr_c);
				if(dum < 1) return;
				w_dialcursor(win, D_CUROFF);
				objc_xtedcpy(win->dinfo->tree, ETO, get_group_name(dum-1));
				w_objc_draw(win, ETO, 8, sx,sy,sw,sh);
				w_dialcursor(win, D_CURON);
				return;
			}
			lock_menu(omenu);
			address_dial(win);
			if(!waddress.open) {unlock_menu(omenu); break;}
			w_modal(&waddress, MODAL_ON);
			while(waddress.open) 
				if(!w_ddevent(&evnt,&mx,&my,&dum,&dum,&dum,&klicks))
				{
					if((evnt & MU_BUTTON) && (klicks==2))
						double_click(mx, my);
				}
			w_modal(&waddress, MODAL_OFF);
			if(waddress.user) {unlock_menu(omenu); break;}
			w_dialcursor(win, D_CUROFF);
			switch(ob)
			{
				case TO: case ITO:
					objc_xtedcpy(win->dinfo->tree, ETO, get_adrname(adr_inf.sel));
					w_objc_draw(win, ETO, 8, sx,sy,sw,sh);
				break;
				case CC: case ICC:
					objc_xtedcpy(win->dinfo->tree, ECC, get_adrname(adr_inf.sel));
					w_objc_draw(win, ECC, 8, sx,sy,sw,sh);
				break;
				case BCC: case IBCC:
					objc_xtedcpy(win->dinfo->tree, EBCC, get_adrname(adr_inf.sel));
					w_objc_draw(win, EBCC, 8, sx,sy,sw,sh);
				break;
			}
			w_dialcursor(win, D_CUROFF);
			unlock_menu(omenu);
		break;
		
		case UEDITOR:
			if(win->dinfo->dedit > 0)
			{/* Cursor einschalten */
				w_dialcursor(win, D_CUROFF);
				win->dinfo->cpos=0;
				win->dinfo->dedit=0;
				((EDIT_OB*)(win->user))->cur_only=1;
				w_objc_draw(win, edob->edob, 8, sx,sy,sw,sh);
				((EDIT_OB*)(win->user))->cur_only=0;
				break;
			}
			/* Cursor positionieren oder neue Selektion */
			ed_cur_sel(win);
		break;
		
		case CRVIS:
			if(sw_mode)
			{
				if(win->dinfo->tree[ob].ob_spec.iconblk==ovorl[CRSWVISSEL].ob_spec.iconblk)
				{
					win->dinfo->tree[ob].ob_spec.iconblk=ovorl[CRSWVISUNSEL].ob_spec.iconblk;
					edob->crvis=0;
				}
				else
				{
					win->dinfo->tree[ob].ob_spec.iconblk=ovorl[CRSWVISSEL].ob_spec.iconblk;
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
		
		case EDSIG:
			sig_popup(win);
		break;

		case EDREPLYTO:
			set_reply_to(win);
		break;
				
		case EDANHANG:
			if((edob->pm_om==1)&&(!stristr(xted(win->dinfo->tree, ETO)->te_ptext, "binar")))
				form_alert(1, gettext(NOBINARY));
			anh_popup(win);
		break;
	}
}

void	do_crsr_check(WINDOW *win, int oob, int nob)
{
	if((oob==0) && (nob!=0))
		w_objc_draw(win, ((EDIT_OB*)(win->user))->edob, 8, sx,sy,sw,sh);
}

void editor_slide_set(WINDOW *win)
{
	long	t, l;
	long	lloff=((EDIT_OB*)(win->user))->offset;
	long	llines=count_lines((EDIT_OB*)(win->user));
	
	/* Ggf. Listenoffset korrigieren */
	l=win->dinfo->tree[((EDIT_OB*)(win->user))->edob].ob_height/ios.efhi;	/* Sichtbare Zeilen */
	if(lloff+l > llines)	lloff=llines-l;
	if(lloff < 0) 				lloff=0;

	((EDIT_OB*)(win->user))->offset=lloff;
	if(llines <= l)
	{
		win->vpos=0;
		win->vsiz=1000;
		w_set(win, VSLIDE);
		return;
	}

	/* Slidergrîûe */
	t=(long)llines*(long)(ios.efhi);	/* Gesamte Liste in Pixeln */
	win->vsiz=(int)(((long)1000*(long)(win->dinfo->tree[((EDIT_OB*)(win->user))->edob].ob_height))/t);
	
	/* Sliderpos. */
	win->vpos=(int)((long)(1000*lloff) / (long)(llines-l));
	w_set(win, VSLIDE);
}

void ed_kill_file(EDIT_OB *edob)
{
	Fdelete(edob->file);
	if(edob->pm_om) actize_om_sndlst();
	remove_file_from_list(edob->file);
}

void ed_kill_win(WINDOW *win)
{
	EDIT_OB	*eb=win->user;
	ED_LIN	*el, *mel;
	MAIL_ATX	*atx, *matx;

	el=eb->first;
	while(el)
	{
		mel=el->next;
		if(el->line) free(el->line);
		free(el);
		el=mel;
	}
	atx=eb->atx_first;
	while(atx)
	{
		matx=atx->next;
		if(atx->atx) free(atx->atx);
		free(atx);
		atx=matx;
	}
	free(eb);

	w_close(win);
	w_kill(win);
	--eds_opened;
}

void	eclosed(WINDOW *win)
{
	EDIT_OB	*eb=win->user;
	long fhl, len;
	
	if(eb->changed)
	{ /* Ist schon ein Alert offen? (Oder modales Dialogfenster) */
		if(globalmodal) {Bell(); return;}
		
		if((fhl=form_alert(1, gettext(EDCLOSE)))==3) return; 	/* Abbruch */
		if(fhl==1)
			if(ed_save_mail(win)==0) return;
	}

	/* Vielleicht wurde die Nachricht inzwischen gelîscht? */
	if((fhl=Fopen(eb->file, FO_READ))==EFILNF)
		if(form_alert(1, gettext(EDKILLED))==1)
			if(ed_save_mail(win)==0) return;
	
	/* Nachricht ist leer? */
	if(fhl > -1)
	{
		len=Fseek(0, (int)fhl, 2);
		Fclose((int)fhl);
		if(len==0)
			ed_kill_file(eb);
	}

	ios.ewx=win->wx;
	ios.ewy=win->wy;
	ios.eww=win->ww;
	ios.ewh=win->wh;
	ios.eyes_on=eb->crvis;
	
	ed_kill_win(win);	
}
void	esized(WINDOW *win, int *pbuf)
{
	int dum, aw, ah;
	OBJECT	*odial;
	
	odial=win->dinfo->tree;
	if(ext_type(odial, 0) != 1) return;
	
	/* pbuf[6]=Breite, pbuf[7]=Hîhe */
	/* Minimum festlegen */
	wind_calc(WC_WORK, win->kind, win->wx, win->wy, pbuf[6], pbuf[7], &dum, &dum, &aw, &ah);
/*	if(aw < odial[HIDEFRAME].ob_width)
		aw=odial[HIDEFRAME].ob_width;*/
	if(aw < odial[ETO].ob_x + odial[ETO].ob_width+8)
		aw=odial[ETO].ob_x + odial[ETO].ob_width+8;
	if(ah < odial[HEADFRAME].ob_height+3*ios.efhi)
		ah=odial[HEADFRAME].ob_height+3*ios.efhi;

	if((aw==odial[0].ob_width) && (ah==odial[0].ob_height)) return;
	
	odial[0].ob_width=aw;
	odial[0].ob_height=ah;
	
	/* Objekthîhen setzen */
	odial[EDFRAME].ob_height=odial[0].ob_height-odial[EDFRAME].ob_y;
	odial[((EDIT_OB*)(win->user))->edob].ob_height=odial[FEDFRAME].ob_height=
		odial[EDFRAME].ob_height-2*odial[FEDFRAME].ob_y;
	/* Objektbreiten */
	odial[HEADFRAME].ob_width=odial[EDFRAME].ob_width=
		odial[0].ob_width;
	odial[((EDIT_OB*)(win->user))->edob].ob_width=odial[FEDFRAME].ob_width=
		odial[EDFRAME].ob_width-2*odial[FEDFRAME].ob_x;
	
	umbrechen(win);
	editor_slide_set(win);
	
	w_calc(win);
	win->aw=aw;
	win->ah=ah;
	w_wcalc(win);
	w_set(win, CURR);
	w_objc_draw(win, 0, 8, sx,sy,sw,sh);
}
void	efulled(WINDOW *win)
{
	int wx,wy,ww,wh;

	if(ext_type(win->dinfo->tree, 0) != 1) return;
	
	if((win->wx!=sx)||(win->wy!=sy)||(win->ww!=sw)||(win->wh!=sh))
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
	esized(win, pbuf);
}
void	evslid(WINDOW *win, int *pbuf)
{
	long	l, off, mo;
	
	if(ext_type(win->dinfo->tree, 0) != 1) return;

	/* Neuen Offset ausrechnen */
	l=win->dinfo->tree[((EDIT_OB*)(win->user))->edob].ob_height/ios.efhi;	/* Sichtbare Zeilen */
	off=(int)(((long)(pbuf[4])*(count_lines((EDIT_OB*)(win->user))-l))/(long)1000);
	if(off!=((EDIT_OB*)(win->user))->offset)
	{
		mo=((EDIT_OB*)(win->user))->offset*ios.efhi;
		((EDIT_OB*)(win->user))->offset=off;
		editor_slide_set(win);
		blit_y(win, ((EDIT_OB*)(win->user))->edob, mo, off*ios.efhi);
	}	
}
void	earrowed(WINDOW *win, int *pbuf)
{
	long	lloff=((EDIT_OB*)(win->user))->offset;
	long	oloff=lloff;
	long	psize=win->dinfo->tree[((EDIT_OB*)(win->user))->edob].ob_height/ios.efhi;
	
	if(ext_type(win->dinfo->tree, 0) != 1) return;
	
	switch(pbuf[4])
	{
		case WA_UPPAGE:	lloff-=psize;	break;
		case WA_DNPAGE: lloff+=psize; break;
		case WA_UPLINE:	--lloff; break;
		case WA_DNLINE:	++lloff; break;
	}
	if(lloff < 0) lloff=0;
	((EDIT_OB*)(win->user))->offset=lloff;
	editor_slide_set(win);
	lloff=((EDIT_OB*)(win->user))->offset;
	if(lloff == oloff) return;
	blit_y(win, ((EDIT_OB*)(win->user))->edob, oloff*ios.efhi, lloff*ios.efhi);
}


ED_LIN *get_ed_lin(EDIT_OB *eo)
{
	long 		a=eo->cur_y;
	ED_LIN	*el=eo->first;
	
	while(el && (a--)) el=el->next;
	return(el);
}

ED_LIN **get_p_ed_lin(EDIT_OB *eo)
{
	long 		a=eo->cur_y;
	ED_LIN	**el=&(eo->first);
	
	while((*el) && (a--)) el=&((*el)->next);
	return(el);
}

int test_from_to(char *from, char *to)
{/* PrÅft ob der Absender <from> der einen Nachricht gleich dem
    EmpfÑnger <to> einer anderen Nachricht ist. <to> und <from>
    werden dabei Åber das Areûbuch aufgelîst. 
  	Return: 1=sind gleich, 0=sind nicht gleich
  */
	char *adr_to, *adr_from, lto[256], lfrom[256];
	int	ret=0;

	strcpy(lto, to); strcpy(lfrom, from);
	while((lto[strlen(lto)-1]==' ') && strlen(lto)) lto[strlen(lto)-1]=0;
	while((lfrom[strlen(lfrom)-1]==' ') && strlen(lfrom)) lfrom[strlen(lfrom)-1]=0;
	if(adr_resolve(lto, &adr_to) && adr_to)
	{
		if(adr_resolve(lfrom, &adr_from) && adr_from)
		{
			if(stristr(adr_from, adr_to)) ret=1;
			free(adr_from);
		}
		free(adr_to);
	}
	return(ret);  
}

void quote(void)
{
	int 	wh, umbr;
	long	a, cnt;
	char	*w, mem;
	WINDOW *win;
	EDIT_OB	*edob;
	ED_LIN	**el, *ml, *nl;

	/* Oberstes Fenster ist Editor? */
	wh=wind_gtop();
	win=w_find(wh);
	if(win==NULL) return;
	if(ext_type(win->dinfo->tree, 0)!=1) return;
	edob=win->user;
	/* Selektion aus Hauptfenster? */
	if((sel_sl < 0)||(loaded==NULL)) 
	{/* Aus Clipboard quoten */
		w_ed_quote(win);
		return;
	}
	else	/* Selektion aus Nachricht */
	{	/* Ursprungsnachricht als beantwortet markieren, falls es
	     sich um empfangene Nachricht handelt und Absender gleich
	     EmpfÑnger der aktuellen Edit-Nachricht ist */
		if(db_mode && (test_from_to(get_head_field("From:"), xted(win->dinfo->tree, ETO)->te_ptext)) && ((fld[ios.list_sel].ftype==FLD_NEW)||(fld[ios.list_sel].ftype==FLD_RED)) && (!(fld[ios.list_sel].fspec.finfo.flags & FF_ANS)))
		{
			Idx_setflag(fld[ios.list_sel].idx, FF_ANS);
			fld[ios.list_sel].fspec.finfo.flags |= FF_ANS;
			check_draw_list(0);
		}
	}
	/* UNDO-Aktion */
	store_undo(edob);	
	edob->changed=1;
	/* CR einfÅgen, falls Cursor nicht am Anfang steht */
	if(edob->cur_x > 0) 
	{
		if(strlen(edob->buf_line)==1023) {Bell(); return;}
		a=strlen(edob->buf_line);
		do
		{
			edob->buf_line[a+1]=edob->buf_line[a];
		}while(a-- >= edob->cur_x);
		edob->buf_line[edob->cur_x]=13;
		++edob->cur_x;
		if(insert_line(edob)==0) return;
		/* Neuen Pointer merken */
		++edob->cur_y;
	}
	/* Sonst ggf. CR an vorherige Zeile anhÑngen, falls Cursor
		nicht in leerer CR-Zeile steht */
	else if((edob->cur_y > 0) && (edob->buf_line[0]!=13))
	{
		ml=edob->first; a=edob->cur_y-1; while(a--) ml=ml->next;
		if(ml->line[strlen(ml->line)-1]!=13)
		{
			w=malloc(strlen(ml->line)+2);
			if(w==NULL) {Bell(); return;}
			strcpy(w, ml->line);
			strcat(w, "\r");
			free(ml->line);
			ml->line=w;
		}
	}
	umbr=1;
	el=get_p_ed_lin(edob);
	ml=*el;
	w=loaded; cnt=0;
	edob->cur_x=0;
	if(w) while(cnt < sel_sl)
	{	w+=lstrlen(w)+1;	++cnt;}
	w+=sel_sc; if(sel_sc) --w;
	while(cnt < sel_el)
	{
		nl=malloc(sizeof(ED_LIN)); if(nl==NULL) {Bell();return;}
		/* w+3 wegen: 1 fÅr ggf. Umbruchzeichen, 1 fÅr ggf. CR, 1 fÅr 0 */
		nl->line=malloc(lstrlen(w)+3); if(nl->line==NULL) {Bell(); return;}
		if(lstrcpy(nl->line, w))
			strcat(nl->line, "\r");
		nl->quoted=1;
		nl->next=ml;
		*el=nl;
		el=&(nl->next);
		++edob->cur_y;
		w+=lstrlen(w)+1; ++cnt;
		++umbr;
	}
	if(sel_ec)
	{
		if(sel_el==sel_sl)
		{mem=w[sel_ec-sel_sc+1]; w[sel_ec-sel_sc+1]=0;}
		else
		{mem=w[sel_ec]; w[sel_ec]=0;}
		nl=malloc(sizeof(ED_LIN)); if(nl==NULL) {Bell();return;}
		/* w+4 wegen: 1 fÅr ggf. Umbruchzeichen, 1 fÅr ggf. CR, 1 ggf. fÅr Smiley falls nicht ganz selektiert, 1 fÅr 0 */
		nl->line=malloc(lstrlen(w)+4); if(nl->line==NULL) {Bell(); return;}
		if(lstrcpy(nl->line, w))
			strcat(nl->line, "\r");
		if(sel_el==sel_sl) w[sel_ec-sel_sc+1]=mem;
		else w[sel_ec]=mem;
		nl->quoted=1;
		nl->next=ml;
		*el=nl;
		++edob->cur_y;
		++umbr;
	}
	fwd_mx_umbrechen(win, umbr);
	if(edob->offset > edob->cur_y) edob->offset=edob->cur_y; 
	if(edob->offset+win->dinfo->tree[edob->edob].ob_height/ios.efhi <= edob->cur_y) edob->offset=edob->cur_y-win->dinfo->tree[edob->edob].ob_height/ios.efhi+1;
	editor_slide_set(win);
	s_redraw(win);
}

long	count_lines(EDIT_OB	*eo)
{
	long 		a=0;
	ED_LIN	*el=eo->first;
	
	while(el)
	{
		++a;
		el=el->next;
	}
	return(a);
}

long get_cur_x(char *line, int pix)
{/* Liefert die X-Position (ab 0) eines Zeichens, 
		line=Zeile, pix=gesuchte X-Position in Pixeln */
	long	a;
	int		extnd[8];
	char	mem;

	a=0;
	do{
		mem=line[a];
		line[a]=0;
		ed_extent(line, extnd);
		line[a]=mem;
		if(extnd[2] >= pix)
		{
			if(a) --a;
			return(a);
		}
	}while(line[a++]);
	return(a-1);
}

int new_cur_y(EDIT_OB *eo, long ny, int ob_hi)
{/* Gibt 0 zurÅck, wenn nur der Cursor neu gezeichnet werden
		muû, 1 wenn das ganze Edit-Objekt neu gezeichnet werden muû */
	if(ny < 0) ny=0;
	if(ny > count_lines(eo)-1) ny=count_lines(eo)-1;

	if(store_buf(eo)==0) { form_alert(1, gettext(NOMEM)); return(0);}

	eo->cur_y=ny;
	strcpy(eo->buf_line, get_ed_lin(eo)->line);
	if(eo->offset > ny) {eo->offset=ny; return(1);}
	if(eo->offset+ob_hi/ios.efhi <= ny) {eo->offset=ny-ob_hi/ios.efhi+1; return(1);}
	return(0);
}

int insert_line(EDIT_OB *eo)
{/* FÅgt eine Zeile hinter cur_x/cur_y ein. 
		Rest ab cur_x wird dabei in die Neue Zeile Åbernommen
		1=OK, 0=Kein Speicher */
	ED_LIN	*el=malloc(sizeof(ED_LIN)), *al=get_ed_lin(eo);
	char		mem, *nc, *nl;
	
	if(eo->cur_x==1)	/* Zeichen 0 ist bereits CR */
	{/* Evtl. Platz vor Quote schaffen? */
		el->quoted=al->quoted;
		al->quoted=0;
	}
	else if((eo->cur_x==strlen(eo->buf_line))||(eo->buf_line[eo->cur_x]==13))
		el->quoted=0;	/* Neue Zeile nach Quote */
	else
		el->quoted=al->quoted;

	mem=eo->buf_line[eo->cur_x];
	eo->buf_line[eo->cur_x]=0;
	nc=malloc(strlen(eo->buf_line)+1);
	nl=malloc(strlen(&(eo->buf_line[eo->cur_x+1]))+2);
	
	if((el==NULL)||(nc==NULL)||(nl==NULL))
	{
		form_alert(1, gettext(NOMEM));
		return(0);
	}
	strcpy(nc, eo->buf_line);
	free(al->line);
	al->line=nc;
	el->next=al->next;
	al->next=el;
	el->line=nl;
	eo->buf_line[eo->cur_x]=mem;
	strcpy(nl, &(eo->buf_line[eo->cur_x]));
	strcpy(eo->buf_line, nl);
	return(1);
}

void usr_umbrechen(EDIT_OB *edob, int max_width)
{
	ED_LIN	*el, *root, *src, *lsrc, *start;
	char		buf_line[1024], *ss, *lss;
	int			extnd[8], bfill, lbfill, qlen, char_count;

	qlen=ios.eqwi;
	
	/* Neue Line-Kette aufbauen */
	root=el=malloc(sizeof(ED_LIN)); 
	if(root==NULL) {form_alert(1,gettext(NOMEM));	return;}

	el->line=malloc(2); 
	if(el->line==NULL) {form_alert(1,gettext(NOMEM));	return;}
	el->line[0]=0;
	el->quoted=0;
	el->next=NULL;
	src=edob->first;
	ss=src->line;
	while(src)
	{
		/* Eine Zeile erzeugen */
		start=src;
		buf_line[0]=0;
		bfill=0;
		char_count=0;
		do
		{
			lsrc=src; lss=ss; lbfill=bfill;
			if(src==NULL) break;
			while((*ss!=9) && (*ss!=' ') && (*ss!='-') && (*ss!=13))
			{
				if(!*ss)
				{
					src=src->next; 
					if(bfill==0)	/* Kopie fÑngt erst in neuer Zeile an */
						start=src;
					if(src)
					{
						ss=src->line;
						continue;
					}
					break;
				}
				buf_line[bfill++]=*ss++; ++char_count;
				if(!(edob->pm_om) && ios.cut_pers && (ios.cut_pnum < char_count))
					break;
				if(edob->pm_om && ios.cut_oeff && (ios.cut_onum < char_count))
					break;
			}
			/* Umbruch-Zeichen mitkopieren */
			if(*ss)	buf_line[bfill++]=*ss;
			buf_line[bfill]=0;
			ed_extent(buf_line, extnd);
			if(*ss==13)	/* Muû umbrechen */
			{
				++ss;
				if(extnd[2]+qlen*start->quoted < max_width)
				{lbfill=bfill; lss=ss; lsrc=src;}
				break;
			}
			++ss;
			if(!(edob->pm_om) && ios.cut_pers && (ios.cut_pnum < char_count))
				break;
			if(edob->pm_om && ios.cut_oeff && (ios.cut_onum < char_count))
				break;
		}while(start && (extnd[2]+qlen*start->quoted < max_width));
		/* Zeile ablegen */
		bfill=lbfill; ss=lss; src=lsrc;	/* Nur bis l* kopieren */
		if(lbfill==0)	/* Wort lÑnger als Zeilenmaximum, nochmal von vorne */
		{
			buf_line[bfill]=0;
			char_count=0;
			do
			{
				lsrc=src; lss=ss; lbfill=bfill;
				start=src;
				if(src==NULL) break;
				if(!*ss)
				{
					src=src->next; 
					if(src) ss=src->line; 
				}
				buf_line[bfill++]=*ss++;
				buf_line[bfill]=0;
				++char_count;
				ed_extent(buf_line, extnd);
				if(!(edob->pm_om) && ios.cut_pers && (ios.cut_pnum < char_count))
					break;
				if(edob->pm_om && ios.cut_oeff && (ios.cut_onum < char_count))
					break;
			}while(extnd[2] < max_width);
			bfill=lbfill; ss=lss; src=lsrc;	
		}
		buf_line[lbfill]=0;
		el->line=malloc(strlen(buf_line)+1);
		if(el->line==NULL) {form_alert(1,gettext(NOMEM));	return;}
		if((start) && (start->quoted))
			el->quoted=1;
		else
			el->quoted=0;
		strcpy(el->line, buf_line);
		if(src)
		{
			/* NÑchste Zeile vorbereiten */
			el->next=malloc(sizeof(ED_LIN));
			if(el->next==NULL) {form_alert(1,gettext(NOMEM));	return;}
			el=el->next;
			/* el->line wird in der Schleife alloziert */
			el->next=NULL;
		}
	}
	
	src=edob->first;
	while(src)
	{
		free(src->line);
		lsrc=src->next;
		free(src);
		src=lsrc;
	}
	edob->first=root;
}

void absolute_cursor(int store, EDIT_OB *edob)
{/* store=1: Pos sichern
		store=0: Pos abrufen */
	ED_LIN	*el, *mel;
	long		count;
	static long cur_car, cur_end;

	if(store)
	{
		cur_car=cur_end=0;
		/* Absolute Cursorposition oder Selektion */
		el=edob->first;
		if(edob->sel_sx > -1) count=edob->sel_sy;
		else count=edob->cur_y;
		while(count--)
		{	cur_car+=strlen(el->line);el=el->next;}
		if(edob->sel_sx > -1)
		{	
			cur_end=cur_car;
			cur_car+=edob->sel_sx;
			count=edob->sel_ey-edob->sel_sy;
			while(count--)
			{	cur_end+=strlen(el->line);el=el->next;}
			cur_end+=edob->sel_ex;
		}
		else cur_car+=edob->cur_x;
		return;
	}	

	/* Restore */
	/*Cursor/Selektion wieder herstellen */
	el=edob->first;	count=0;
	while(strlen(el->line) < cur_car)
	{
		cur_car-=strlen(el->line);cur_end-=strlen(el->line);
		el=el->next;++count;
	}
	if(edob->sel_sx > -1)
	{
		edob->cur_y=edob->sel_sy=count;
		edob->cur_x=edob->sel_sx=cur_car;
		mel=el;
		while(strlen(el->line) < cur_end)
		{	cur_end-=strlen(el->line);el=el->next;++count;}
		edob->sel_ey=count;
		edob->sel_ex=cur_end;
		el=mel;
	}
	else
	{edob->cur_y=count;edob->cur_x=cur_car;}
	
	if(el->line[cur_car-1]==13)	/* Cursor hinter CR gelandet. */
	{
		++edob->cur_y; edob->cur_x=0;
		if(edob->sel_sx > -1)	{++edob->sel_sy; edob->sel_sx=0;}
		el=el->next;
	}
	strcpy(edob->buf_line, el->line);
}

void eo_umbrechen(EDIT_OB	*edob, int width)
{/* Gesamten Text umbrechen */
	/* Buffer Åbernehmen */
	if(store_buf(edob)==0) {form_alert(1,gettext(NOMEM));	return;}

	absolute_cursor(1, edob);

	/* Umbrechen */	
	usr_umbrechen(edob, width);
	absolute_cursor(0, edob);
}

void umbrechen(WINDOW *win)
{
	eo_umbrechen(win->user, win->dinfo->tree[((EDIT_OB*)(win->user))->edob].ob_width-MESSAGE_OFFSET);
}

void eo_mx_umbrechen(EDIT_OB *eb, int x, int width)
{/* Nur ab aktueller Cursorzeile -x umbrechen */
	EDIT_OB	teb;
	ED_LIN	**elp, *ebl;
	long		a;

	/* Buffer Åbernehmen */
	if(store_buf(eb)==0) {form_alert(1,gettext(NOMEM));	return;}
	
	absolute_cursor(1, eb);
	
	/* Neues Ed-Ob nur mit umzubrechenden Zeilen tÅrken */	
	if(eb->cur_y < x+1) {eo_umbrechen(eb, width); return;}
	a=eb->cur_y-x;
	ebl=eb->first;
	while(a--) ebl=ebl->next;
	teb.first=ebl;

	/* Umbrechen */
	usr_umbrechen(&teb, width);

	/* Neues Ed-Ob in altes einfÅgen */
	a=eb->cur_y-x;
	elp=&(eb->first);
	while(a--) elp=&((*elp)->next);
	*elp=teb.first;

	absolute_cursor(0, eb);
}

void fwd_mx_umbrechen(WINDOW *win, int x)
{
	eo_mx_umbrechen(win->user, x, win->dinfo->tree[((EDIT_OB*)(win->user))->edob].ob_width-MESSAGE_OFFSET);
}

void fwd_umbrechen(WINDOW *win)
{/* Nur ab aktueller Cursorzeile umbrechen */
	fwd_mx_umbrechen(win, 0);
}

void fwd_m1_umbrechen(WINDOW *win)
{/* Nur ab aktueller Cursorzeile -1 umbrechen */
	fwd_mx_umbrechen(win, 1);
}

uchar prev_char(EDIT_OB *eo)
{/* Liefert Zeichen vor Cursor zurÅck. Falls Cursor auf Textanfang
		wird 0 geliefert */
	ED_LIN	*el;
	long		c;
	
	if(eo->cur_x)
		return((uchar)(eo->buf_line[eo->cur_x-1]));
	if(eo->cur_y==0) return(0);
	c=eo->cur_y-1;
	el=eo->first;
	while(c--) el=el->next;
	return((uchar)(el->line[strlen(el->line)-1]));
}

int ed_unsel(EDIT_OB *edob)
{
	ED_LIN	*el;
	
	if(edob->sel_sx == -1) return(0);
	if(store_buf(edob)==0) return(0);
	
	edob->cur_x=edob->sel_sx; edob->sel_sx=-1;
	edob->cur_y=edob->sel_sy;
	el=get_ed_lin(edob);
	strcpy(edob->buf_line, el->line);
	if(edob->buf_line[edob->cur_x-1]==13) --edob->cur_x;
	return(1);
}

int store_undo(EDIT_OB *edob)
{
	ED_LIN	*el, *ml, **pl;

	el=edob->undo->first;
	while(el)
	{
		free(el->line);
		ml=el->next;
		free(el);
		el=ml;
	}
	edob->undo->first=NULL;
	
	*(edob->undo)=*edob;
	pl=&(edob->undo->first);
	el=edob->first;
	while(el)
	{
		*pl=malloc(sizeof(ED_LIN));
		if(*pl==NULL) return(0);
		(*pl)->next=NULL;
		(*pl)->quoted=el->quoted;
		(*pl)->line=malloc(strlen(el->line)+1);
		if((*pl)->line==NULL) {free(*pl); *pl=NULL; return(0);}
		strcpy((*pl)->line, el->line);
		pl=&((*pl)->next);
		el=el->next;
	}
	return(1);
}

void swap_undo(EDIT_OB *edob)
{
	EDIT_OB	buf;
	
	buf=*(edob->undo);
	buf.undo=edob->undo;
	*(edob->undo)=*edob;
	*edob=buf;
}

int ed_cut(EDIT_OB *edob)
{
	ED_LIN *el, *ml;
	long		a;
	char		*c, *d;
	
	if(edob->sel_sx == -1) return(0);
	if(store_buf(edob)==0) return(0);

	el=edob->first;
	a=edob->sel_sy;
	while(a--) el=el->next;
	el->line[edob->sel_sx]=0;
	a=edob->sel_ey-edob->sel_sy;
	if(a==0)
	{/* Startzeile=Endzeile */
		c=&(el->line[edob->sel_sx]);
	}
	else
	{
		while(--a)
		{
			ml=el->next;
			el->next=el->next->next;
			free(ml->line);
			free(ml);
		}
		el=el->next;
		c=el->line;
	}
	d=&(el->line[edob->sel_ex]);
	while(*d) *c++=*d++;
	*c=0;

	edob->cur_x=edob->sel_sx; edob->sel_sx=-1;
	edob->cur_y=edob->sel_sy;
	el=get_ed_lin(edob);
	strcpy(edob->buf_line, el->line);
	if(edob->buf_line[edob->cur_x-1]==13) --edob->cur_x;
	return(1);
}

int ed_copy(EDIT_OB *edob)
{/* Return: 1=Ok, 0=Fehler */
	ED_LIN *el;
	long		a, xoff=0;
	int			fh;
	char		*c, mem;

	if(edob->sel_sx == -1) return(0);
	if(store_buf(edob)==0) return(0);

	fh=write_clipboard("SCRAP.TXT");
	if(fh < 0) {gemdos_alert(gettext(CREATEERR), fh); return(0);}

	el=edob->first;
	a=edob->sel_sy;
	while(a--) el=el->next;
	c=&(el->line[edob->sel_sx]);
	a=edob->sel_ey-edob->sel_sy;
	if(a==0) xoff=edob->sel_sx;
	while(a--)
	{
		if((el->quoted)&&(ios.ed_qcopy)) Fwrite(fh, 1, ">");
		Fwrite(fh, strlen(c), c);
		if(c[strlen(c)-1]==13) Fwrite(fh, 1, "\n");
		el=el->next;
		c=el->line;
	}
	mem=c[edob->sel_ex-xoff]; c[edob->sel_ex-xoff]=0;
	if((ios.ed_qcopy) && (!xoff) && el->quoted) Fwrite(fh, 1, ">");
	Fwrite(fh, strlen(c), c);
	c[edob->sel_ex-xoff]=mem;
	Fclose(fh);
	return(1);
}

int ed_file_insert(int fh, EDIT_OB *edob, int width, int quoting)
{
	int 	umbr;
	long	a, b, cnt;
	char	*w, *scrap;
	ED_LIN	*el, *ml;

	cnt=Fseek(0, fh, 2);
	Fseek(0, fh, 0);
	if(cnt==0) return(0);
	scrap=malloc(cnt+2);
	if(scrap==NULL) {Fclose(fh); return(0);}
	cnt=Fread(fh, cnt, scrap); Fclose(fh);
	if(cnt < 0) {gemdos_alert(gettext(READERR), cnt); return(0);}
	scrap[cnt]=0; (uchar)(scrap[cnt+1])=0xff;
	
	if(insert_line(edob)==0) {free(scrap);return(0);}
	edob->changed=1;
	el=get_ed_lin(edob);
	++edob->cur_y; edob->cur_x=0;
	umbr=2;
	
	w=scrap; a=0;
	while(a < cnt)
	{
		if(((uchar)(w[a])<32)&&(w[a]!=13)&&(w[a]!=10)&&(w[a]!=9)) w[a]=' ';
		else
		{
			if(w[a]==13)
			{
				w[a]=0;
				if(w[a+1]==10)
				{
					b=a+2; 
					while(b <= cnt)	w[b-1]=w[b++];
					--cnt;
				}
			}
			if(w[a]==10) w[a]=0;
		}
		++a;
	}
	
	a=0;
	while(a < cnt)
	{
		ml=malloc(sizeof(ED_LIN));
		if(ml==NULL) {free(scrap); Bell(); return(1);}
		ml->line=malloc(strlen(w)+2);
		ml->quoted=quoting;
		if(ml->line==NULL) {free(scrap); free(ml); Bell(); return(1);}
		strcpy(ml->line, w);
		if((uchar)(w[strlen(w)+1])!=0xff)
			strcat(ml->line, "\r");
		ml->next=el->next;
		el->next=ml;
		el=ml;
		a+=strlen(w)+1;
		w+=strlen(w)+1;
		++edob->cur_y;
		++umbr;
	}	

	eo_mx_umbrechen(edob, umbr, width);
	return(1);
}

int ed_paste(EDIT_OB *edob, int width, int quoting)
{
	int 	fh;

	fh=sread_clipboard("SCRAP.TXT");
	if(fh < 0) return(0);
	return(ed_file_insert(fh, edob, width, quoting));
}

void w_ed_paste(WINDOW *win)
{
	EDIT_OB	*edob=win->user;

	store_undo(edob);
	if(ed_cut(edob))	fwd_m1_umbrechen(win);
	if(ed_paste(edob, win->dinfo->tree[edob->edob].ob_width-MESSAGE_OFFSET, 0)==0) return;
	if(edob->offset > edob->cur_y) edob->offset=edob->cur_y; 
	if(edob->offset+win->dinfo->tree[edob->edob].ob_height/ios.efhi <= edob->cur_y) edob->offset=edob->cur_y-win->dinfo->tree[edob->edob].ob_height/ios.efhi+1;
	editor_slide_set(win);
	w_objc_draw(win, edob->edob, 8, sx,sy,sw,sh);
}
void w_ed_quote(WINDOW *win)
{
	EDIT_OB	*edob=win->user;

	store_undo(edob);
	if(ed_paste(edob, win->dinfo->tree[edob->edob].ob_width-MESSAGE_OFFSET, 1)==0) return;
	if(edob->offset > edob->cur_y) edob->offset=edob->cur_y; 
	if(edob->offset+win->dinfo->tree[edob->edob].ob_height/ios.efhi <= edob->cur_y) edob->offset=edob->cur_y-win->dinfo->tree[edob->edob].ob_height/ios.efhi+1;
	editor_slide_set(win);
	w_objc_draw(win, edob->edob, 8, sx,sy,sw,sh);
}

void w_ed_merge(WINDOW *win)
{
	char path[256];
	char	name[64];
	long	fhl;	
	EDIT_OB	*edob=win->user;

	name[0]=0;
	if(f_sinput(gettext(MERGE_OPEN),ios.file_merge_path, name)==0) return;
	make_path(path, ios.file_merge_path, name);

	fhl=Fopen(path, FO_READ);
	if(fhl < 0) {gemdos_alert(gettext(NOOPEN), fhl); return;}

	store_undo(edob);
	if(ed_cut(edob))	fwd_m1_umbrechen(win);
	if(ed_file_insert((int)fhl, edob, win->dinfo->tree[edob->edob].ob_width-MESSAGE_OFFSET, 0)==0) return;
	if(edob->offset > edob->cur_y) edob->offset=edob->cur_y; 
	if(edob->offset+win->dinfo->tree[edob->edob].ob_height/ios.efhi <= edob->cur_y) edob->offset=edob->cur_y-win->dinfo->tree[edob->edob].ob_height/ios.efhi+1;
	editor_slide_set(win);
	w_objc_draw(win, edob->edob, 8, sx,sy,sw,sh);
}

void w_ed_copy(WINDOW *win)
{
	store_undo(win->user);
	ed_copy(win->user);
}

void w_ed_cut(WINDOW *win)
{
	EDIT_OB	*edob=win->user;

	store_undo(edob);	
	if(ed_copy(edob)==0) return;
	ed_cut(edob);
	fwd_m1_umbrechen(win);
	if(edob->offset > edob->cur_y) edob->offset=edob->cur_y; 
	if(edob->offset+win->dinfo->tree[edob->edob].ob_height/ios.efhi <= edob->cur_y) edob->offset=edob->cur_y-win->dinfo->tree[edob->edob].ob_height/ios.efhi+1;
	editor_slide_set(win);
	w_objc_draw(win, edob->edob, 8, sx,sy,sw,sh);
}

void w_ed_selall(WINDOW *win)
{
	EDIT_OB	*edob=win->user;
	ED_LIN	*el;
	
	if(store_buf(edob)==0) return;
	edob->cur_x=edob->cur_y=edob->sel_sx=edob->sel_sy=edob->sel_ey=0;
	el=edob->first;
	while(el->next)
	{
		el=el->next;
		++edob->sel_ey;
	}
	edob->sel_ex=strlen(el->line);
	strcpy(edob->buf_line, edob->first->line);
	w_objc_draw(win, edob->edob, 8, sx,sy,sw,sh);
}

void w_edit_sequenz(WINDOW *win, char *text)
{
	while(*text)
	{
		w_edit_input(win, 0, *text++);
	}
}

void w_edit_input(WINDOW *win, int swt, int key)
{
	int			x, y, extnd[8], unseld=0;
	EDIT_OB	*edob=win->user;
	long		a, b, m;
	char		mem;

	/* Shift+ESC ? */
	if(((key&0xff)==27)&&(swt&3))
	{/* Header ein/ausklappen */
		do_editor(win, EHEAD);
		return;
	}
	
	/* Cursor im Editfeld? */
	if(win->dinfo->dedit!=0) return;


	/* Special-Keys (Smiley) ? */
	if(swt==10)	/* Shift+alt */
	{
		switch(key>>8)
		{
			case 8:		w_edit_sequenz(win, ":-/"); break; /* 7 */
			case 9:		w_edit_sequenz(win, ":-("); break; /* 8 */
			case 10:	w_edit_sequenz(win, ":-)"); break; /* 9 */

			case 51:	w_edit_sequenz(win, ";-)"); break;	/* ; */
			case 52:	w_edit_sequenz(win, ":-)"); break; /* : */
			default: goto _no_smiley;
		}
		return;
	}	

_no_smiley:

	/* Cur/Copy/Paste/Select All */
	/* Wird zwar Åber MenÅ abgefangen, aber nicht im SIG-Dialog */
	if(swt==4)
	{
		if((key>>8)==45) {w_ed_cut(win); return;}
		if((key>>8)==46) {w_ed_copy(win); return;}
		if((key>>8)==47) {w_ed_paste(win); return;}
		if((key>>8)==30) {w_ed_selall(win); return;}
	}
	
	vst_font(handle, ios.efid);
	vst_point(handle, ios.efsiz, &x, &x, &x, &x);
	vst_effects(handle, 0);
	vst_alignment(handle, 0, 3, &x, &x);	/* Bottom Line Alignment */
		
	/* Cursor ausschalten */
	edob->cur_only=1;
	w_objc_draw(win, edob->edob, 8, sx,sy,sw,sh);
	edob->cur_only=0;

	/* Home / Shift Home ? */
	if((key>>8)==71)
	{
		if(swt&3)	/* Mit Shift -> Textende */
		{
			unseld=ed_unsel(edob);
			a=new_cur_y(edob, count_lines(edob)-1, win->dinfo->tree[edob->edob].ob_height);
			edob->cur_x=strlen(edob->buf_line);
			/* CR-PrÅfung fÅr cur_x nicht nîtig, kann nÑmlich in letzter Zeile nicht sein */
			if(a) goto _redraw;
			goto _cur_on;
		}
		else	/* Ohne Shift -> Textanfang*/
		{
			unseld=ed_unsel(edob);
			a=new_cur_y(edob, 0, win->dinfo->tree[edob->edob].ob_height);
			edob->cur_x=0;
			if(a) goto _redraw;
			goto _cur_on;
		}
	}
	
	/* Oben? */
	if((key>>8)==72)
	{
		unseld=ed_unsel(edob);
		if(edob->max_x < edob->cur_x) edob->max_x=edob->cur_x;
		if(edob->cur_y==0) goto _cur_on;	/* Schon oben */
		if(swt & 3) 	/* Mit Shift */
			a=new_cur_y(edob, edob->cur_y-win->dinfo->tree[edob->edob].ob_height/ios.efhi, win->dinfo->tree[edob->edob].ob_height);
		else					/* Ohne Shift */
			a=2*new_cur_y(edob, edob->cur_y-1, win->dinfo->tree[edob->edob].ob_height);
		/* X Neu setzen */
		edob->cur_x=edob->max_x;
		if(edob->cur_x > strlen(edob->buf_line))
			edob->cur_x=strlen(edob->buf_line);
		if(edob->buf_line[edob->cur_x-1]==13)
			--edob->cur_x;
		if(a==1) goto _redraw;	/* Seite geblÑttert */
		if(a==2) goto _bd_redraw; /* Zeile runter blitten */
		goto _cur_on;
	}
	
	/* Unten? */
	if((key>>8)==80)
	{
		unseld=ed_unsel(edob);
		if(edob->max_x < edob->cur_x) edob->max_x=edob->cur_x;
		if(get_ed_lin(edob)->next==NULL) goto _cur_on;	/* Schon unten */
		if(swt & 3) 	/* Mit Shift */
			a=new_cur_y(edob, edob->cur_y+win->dinfo->tree[edob->edob].ob_height/ios.efhi, win->dinfo->tree[edob->edob].ob_height);
		else					/* Ohne Shift */
			a=2*new_cur_y(edob, edob->cur_y+1, win->dinfo->tree[edob->edob].ob_height);
		/* X Neu setzen */
		edob->cur_x=edob->max_x;
		if(edob->cur_x > strlen(edob->buf_line))
			edob->cur_x=strlen(edob->buf_line);
		if(edob->buf_line[edob->cur_x-1]==13)
			--edob->cur_x;
		if(a==1) goto _redraw;
		if(a==2) goto _bu_redraw;
		goto _cur_on;
	}

	edob->max_x=0;	/* Reset */		
	/* Links? */
	if(((key>>8)==75) && (swt==0))
	{
		unseld=ed_unsel(edob);
		/* Cursor ganz links ? */
		if(edob->cur_x==0)
		{
			if(edob->cur_y==0) goto _cur_on;	/* Linkser geht's net */
			a=new_cur_y(edob, edob->cur_y-1, win->dinfo->tree[edob->edob].ob_height);
			edob->cur_x=strlen(edob->buf_line);
			if(edob->buf_line[edob->cur_x-1]==13) --edob->cur_x;
			if(a) goto _redraw;
			goto _cur_on;
		}
		/* Cursor nur eins nach links setzen */
		--edob->cur_x;
		goto _cur_on;
	}

	/* Rechts? */
	if(((key>>8)==77) && (swt==0))
	{
		unseld=ed_unsel(edob);
		/* Schon auf letztem Buchstaben? */
		if( (edob->cur_x==strlen(edob->buf_line)) || (edob->buf_line[edob->cur_x]==13))
		{
			if(get_ed_lin(edob)->next==NULL) goto _cur_on;	/* Schon am Textende */
			edob->cur_x=0;
			if(new_cur_y(edob, edob->cur_y+1, win->dinfo->tree[edob->edob].ob_height))
				goto _redraw;
			goto _cur_on;
		}
		/* Cursor nur eins nach rechts setzen */
		++edob->cur_x;
		goto _cur_on;
	}

	/* Shift links? */
	if( ((key>>8)==71) || (((key>>8)==75) && (swt & 3)) )
	{
		unseld=ed_unsel(edob);
		edob->cur_x=0;
		goto _cur_on;
	}
	
	/* Shift rechts? */
	if(((key>>8)==54) ||  (((key>>8)==77) && (swt & 3)))
	{
		unseld=ed_unsel(edob);
		edob->cur_x=strlen(edob->buf_line);
		if(edob->buf_line[edob->cur_x-1]==13) --edob->cur_x;
		goto _cur_on;
	}
	
	/* Control links ? */
	if(((key>>8)==115) || (((key>>8)==75) && (swt & 4)) )
	{
		unseld=ed_unsel(edob);
		a=0;
		while(((edob->cur_x > 0)||(edob->cur_y>0)) && 
					((prev_char(edob)<'0')||(prev_char(edob)>'9')) &&
					((prev_char(edob)<'A')||(prev_char(edob)>'Z')) &&
					((prev_char(edob)<'a')||(prev_char(edob)>'z')) &&
					(prev_char(edob)<128)
					)
					{
						--edob->cur_x;
						if((edob->cur_x <= 0) && (edob->cur_y > 0))
						{
							a|=new_cur_y(edob, edob->cur_y-1, win->dinfo->tree[edob->edob].ob_height);
							edob->cur_x=strlen(edob->buf_line)+1;
							if(edob->buf_line[edob->cur_x-1]==13) --edob->cur_x;
						}
					}
		while(((edob->cur_x > 0)||(edob->cur_y>0)) && 
					(((prev_char(edob)>='0')&&(prev_char(edob)<='9')) ||
					((prev_char(edob)>='A')&&(prev_char(edob)<='Z')) ||
					((prev_char(edob)>='a')&&(prev_char(edob)<='z')) ||
					(prev_char(edob)>127))
					)
					{
						--edob->cur_x;
						if((edob->cur_x <= 0) && (edob->cur_y > 0))
						{
							a|=new_cur_y(edob, edob->cur_y-1, win->dinfo->tree[edob->edob].ob_height);
							edob->cur_x=strlen(edob->buf_line)+1;
							if(edob->buf_line[edob->cur_x-1]==13) --edob->cur_x;
						}
					}
		if(edob->cur_x > strlen(edob->buf_line))
		{
			a|=new_cur_y(edob, edob->cur_y+1, win->dinfo->tree[edob->edob].ob_height);
			edob->cur_x=0;
		}
		if(a) goto _redraw;
		goto _cur_on;
	}

	/* Control rechts ? */
	if(((key>>8)==116) || (((key>>8)==77) && (swt & 4)) )
	{
		unseld=ed_unsel(edob);
		a=0;
		while(((edob->cur_x < strlen(edob->buf_line))||(get_ed_lin(edob)->next!=NULL)) && 
					((((uchar)(edob->buf_line[edob->cur_x])>='0')&&((uchar)(edob->buf_line[edob->cur_x])<='9')) ||
					(((uchar)(edob->buf_line[edob->cur_x])>='A')&&((uchar)(edob->buf_line[edob->cur_x])<='Z')) ||
					(((uchar)(edob->buf_line[edob->cur_x])>='a')&&((uchar)(edob->buf_line[edob->cur_x])<='z')) ||
					((uchar)(edob->buf_line[edob->cur_x])>127))
					)
					{
						++edob->cur_x;
						if((edob->cur_x>=strlen(edob->buf_line)) && (get_ed_lin(edob)->next!=NULL))
						{
							a|=new_cur_y(edob, edob->cur_y+1, win->dinfo->tree[edob->edob].ob_height);
							edob->cur_x=0;
						}
					}
		while(((edob->cur_x < strlen(edob->buf_line))||(get_ed_lin(edob)->next!=NULL)) && 
					(((uchar)(edob->buf_line[edob->cur_x])<'0')||((uchar)(edob->buf_line[edob->cur_x])>'9')) &&
					(((uchar)(edob->buf_line[edob->cur_x])<'A')||((uchar)(edob->buf_line[edob->cur_x])>'Z')) &&
					(((uchar)(edob->buf_line[edob->cur_x])<'a')||((uchar)(edob->buf_line[edob->cur_x])>'z')) &&
					((uchar)(edob->buf_line[edob->cur_x])<128)
					)
					{
						++edob->cur_x;
						if((edob->cur_x>=strlen(edob->buf_line)) && (get_ed_lin(edob)->next!=NULL))
						{
							a|=new_cur_y(edob, edob->cur_y+1, win->dinfo->tree[edob->edob].ob_height);
							edob->cur_x=0;
						}
					}
		if(edob->buf_line[edob->cur_x-1]==13)
			--edob->cur_x;
		if(a) goto _redraw;
		goto _cur_on;
	}

	edob->changed=1;
	
	/* CTRL+Y ? */
	if(((key>>8)==44) && (swt==4))
	{
		store_undo(edob);
		edob->sel_sx=0; edob->sel_ex=strlen(edob->buf_line);
		edob->sel_sy=edob->sel_ey=edob->cur_y;
		if(ed_copy(edob)==0) {edob->sel_sx=-1; goto _cur_on;}
		ed_cut(edob);
		fwd_m1_umbrechen(win);
		goto _redraw;
	}
	
	/* UNDO? */
	if((key>>8)==97)
	{
		if(edob->undo->first==NULL) goto _cur_on;
		swap_undo(edob);
		umbrechen(win);
		goto _redraw;
	}
	
	if(edob->sel_sx > -1) store_undo(edob);
	
	/* Backspace? */
	if((key>>8)==14)
	{
		x=0;
		if(ed_cut(edob)) {fwd_m1_umbrechen(win); goto _redraw;}
		/* Schon ganz links? */
		if(edob->cur_x==0)
		{
			if(edob->cur_y==0) goto _cur_on;
			x=new_cur_y(edob, edob->cur_y-1, win->dinfo->tree[edob->edob].ob_height);
			edob->cur_x=strlen(edob->buf_line);
		} 
		a=edob->cur_x;
		do
		{
			edob->buf_line[a-1]=edob->buf_line[a];
		}while(edob->buf_line[a++]);
		--edob->cur_x;
		a=edob->cur_x; b=edob->cur_y; m=strlen(edob->buf_line);
		fwd_m1_umbrechen(win); 
		if(x||(a!=edob->cur_x)||(b!=edob->cur_y)||(m!=strlen(edob->buf_line)))
			goto _redraw;
		goto _redraw_line;
	}

	/* Delete? */
	if((key>>8)==83)
	{
		if(ed_cut(edob)) {fwd_m1_umbrechen(win); goto _redraw;}
		/* Cursor schon hinter letztem Buchstaben? */
		if(edob->cur_x==strlen(edob->buf_line)) goto _cur_on;
		/* String eins nach links kopieren */
		a=edob->cur_x;
		do
		{
			edob->buf_line[a]=edob->buf_line[a+1];
		}while(edob->buf_line[a++]);
		a=edob->cur_x; b=edob->cur_y; m=strlen(edob->buf_line);
		fwd_m1_umbrechen(win); 
		if((a!=edob->cur_x)||(b!=edob->cur_y)||(m!=strlen(edob->buf_line)))
			goto _redraw;
		goto _redraw_line;
	}
	
	/* EinzufÅgendes Zeichen? */
	if(((key & 0xff) == 13) || ((key & 0xff) == 9) || ((uchar)(key & 0xff) > 31))
	{/* Kein Platz mehr? */
		if(strlen(edob->buf_line)==1023) {Bell(); goto _cur_on;}
		unseld=ed_cut(edob);
		/* Zeichen einfÅgen */
		a=strlen(edob->buf_line);
		do
		{
			edob->buf_line[a+1]=edob->buf_line[a];
		}while(a-- >= edob->cur_x);
		edob->buf_line[edob->cur_x]=key & 0xff;
		++edob->cur_x;
		/* CR? */
		if((key & 0xff)==13)
		{/* Neue Zeile */
			if(insert_line(edob)==0) goto _cur_on;
			++edob->cur_y;
			edob->cur_x=0;
			fwd_mx_umbrechen(win, 2);
			goto _redraw;
		}
		/* Selektion gelîscht? */
		if(unseld)
		{
			fwd_m1_umbrechen(win);
			goto _redraw;
		}
		/* Zeile zu lang? */
		ed_extent(edob->buf_line, extnd);
		if((extnd[2] > win->dinfo->tree[edob->edob].ob_width-MESSAGE_OFFSET)
		   ||((!edob->pm_om) && (ios.cut_pers) && (edob->cur_x >= ios.cut_pnum))
			 ||((edob->pm_om) && (ios.cut_oeff) && (edob->cur_x >= ios.cut_onum)))
		{/* Umbruch erzwingen */
			fwd_m1_umbrechen(win); /* fwd_u reicht nicht, da durch SPC z.B. Wîrter getrennt werden kînnen, so daû eines in die vorherige Zeile paût */
			goto _redraw;
		}
		/* Trennbares Zeichen eingefÅgt? */
		if(((key & 0xff)==' ')||((key&0xff)=='-'))
		{
			a=edob->cur_x; b=edob->cur_y;
			fwd_m1_umbrechen(win); /* fwd_u reicht nicht, da durch SPC z.B. Wîrter getrennt werden kînnen, so daû eines in die vorherige Zeile paût */
			if((a!=edob->cur_x)||(b!=edob->cur_y))
				goto _redraw;
		}
		goto _redraw_line;
	}
	
_cur_on:
	if(unseld) goto _redraw;
	if(edob->offset > edob->cur_y) goto _redraw;
	if(edob->offset+(win->dinfo->tree[edob->edob].ob_height)/ios.efhi <= edob->cur_y) goto _redraw;
	edob->cur_only=1;
	w_objc_draw(win, edob->edob, 8, sx,sy,sw,sh);
	edob->cur_only=0;
	return;

_redraw:
	if(edob->offset > edob->cur_y) edob->offset=edob->cur_y; 
	if(edob->offset+(win->dinfo->tree[edob->edob].ob_height)/ios.efhi <= edob->cur_y) edob->offset=edob->cur_y-(win->dinfo->tree[edob->edob].ob_height)/ios.efhi+1;
	editor_slide_set(win);
	w_objc_draw(win, edob->edob, 8, sx,sy,sw,sh);
	return;

_bu_redraw:
	/* Nach oben blitten und letzte Zeile zeichnen */
	editor_slide_set(win);
	/* Problem: Wenn in letzter Zeile noch Reste sichtbar sind
	   wird halbe letzte Zeile plus halbe Allerletzte gezeichnet
	   und daher Cursor nur zum Teil */
	edob->cur_only=2;
	blit_y(win, edob->edob, 0, ios.efhi);
	edob->cur_only=1;
	w_objc_draw(win, edob->edob, 8, sx,sy,sw,sh);
	edob->cur_only=0;
	return;
_bd_redraw:
	/* Nach unten blitten und erste Zeile zeichnen */
	editor_slide_set(win);
	blit_y(win, edob->edob, ios.efhi, 0);
	return;

_redraw_line:
	if(edob->offset > edob->cur_y) goto _redraw;
	if(edob->offset+(win->dinfo->tree[edob->edob].ob_height)/ios.efhi <= edob->cur_y) goto _redraw;
	objc_offset(win->dinfo->tree, edob->edob, &x, &y);
	y+=(int)(edob->cur_y-edob->offset)*ios.efhi;
	/* Falls nicht am Zeilenende eingefÅgt wurde oder Zeile leer ist */
	/* oder Backspace gedrÅckt wurde oder */
	/* falls Zeichen URL oder Smiley ergeben kînnte, dann ganze Zeile */
	/* neu zeichnen */
	if( ((key>>8)==14) ||								/* Backspace ? */
			(strlen(edob->buf_line)==0) ||	/* Zeile leer ? */
			(edob->cur_x != strlen(edob->buf_line)) ||	/* Nich am Ende? */
			((key & 0xff)==':')||((key & 0xff)==')')||((key & 0xff)=='/')||((key & 0xff)=='(')
		)
	{	w_objc_draw(win, edob->edob, 8, x,y,win->dinfo->tree[edob->edob].ob_width, ios.efhi+1);}
	/* ansonsten nur letztes Zeichen neu zeichnen */
	else
	{
		mem=edob->buf_line[strlen(edob->buf_line)-1];
		edob->buf_line[strlen(edob->buf_line)-1]=0;
		ed_extent(edob->buf_line, extnd);
		a=extnd[2];
		edob->buf_line[strlen(edob->buf_line)]=mem;
		ed_extent(edob->buf_line, extnd);
		edob->cur_only=2; /* Cursor nicht zeichnen */
		w_objc_draw(win, edob->edob, 8, x+(int)a+MESSAGE_OFFSET,y,extnd[2]-(int)a+MESSAGE_OFFSET, ios.efhi+1);
		edob->cur_only=1;	/* Nur Cursor zeichnen */
		w_objc_draw(win, edob->edob, 8, sx,sy,sw,sh);
		edob->cur_only=0;
	}
	return;
}