#include <ec_gem.h>
#include "io.h"
#include "ioglobal.h"
#include "indexer.h"

/* In TEXTUTIL.C: */
extern char	*lstrchr(char *s, char c);

int wind_gtop(void)
{
	int wh, dum;
	
	wind_get(0, WF_TOP, &wh, &dum, &dum, &dum);
	return(wh);
}

/* -------------------------------------- */

void w_ibut_unsel(int ob)
{
	w_wo_ibut_unsel(&wdial, ob);
}

void w_wo_ibut_unsel(WINDOW *wdial, int ob)
{
	OBJECT *odial=wdial->dinfo->tree;
	if(obj_type(odial, ob)==G_CICON) --ob;
	odial[ob+1].ob_x--;
	odial[ob+1].ob_y--;
	odial[ob].ob_state &= (~SELECTED);
	w_objc_draw(wdial, ob, 8, sx,sy,sw,sh);
}

/* -------------------------------------- */

int w_ibut_sel(int ob)
{
	return(w_wo_ibut_sel(&wdial, ob));
}

int w_wo_ibut_sel(WINDOW *wdial, int ob)
{
	 OBJECT *odial=wdial->dinfo->tree;
	int mx, my, mb, dum;
	int	ox, oy, ow, oh;
	int	o_state=0, n_state;

	wind_update(BEG_MCTRL);
		
	if(obj_type(odial, ob)==G_CICON) --ob;
	objc_offset(odial, ob, &ox, &oy);
	ow=odial[ob].ob_width;
	oh=odial[ob].ob_height;
	
	graf_mkstate(&mx, &my, &mb, &dum);
	if(!(mb & 3)) /* Per Tastatur ausgelîst */
	{
		n_state=1;
		odial[ob].ob_state |= SELECTED;
		odial[ob+1].ob_x++;
		odial[ob+1].ob_y++;
		w_objc_draw(wdial, ob, 8, sx,sy,sw,sh);
	}
	while(mb & 3)
	{
		graf_mkstate(&mx, &my, &mb, &dum);
		if((mx >= ox) && (my >= oy) && (mx < ox+ow) && (my < oy+oh))
			n_state=1;
		else
			n_state=0;

		if(o_state != n_state)
		{
			o_state=n_state;
			if(n_state)
			{
				odial[ob].ob_state |= SELECTED;
				odial[ob+1].ob_x++;
				odial[ob+1].ob_y++;
			}
			else
			{
				odial[ob].ob_state &= (~SELECTED);
				odial[ob+1].ob_x--;
				odial[ob+1].ob_y--;
			}
			w_objc_draw(wdial, ob, 8, sx,sy,sw,sh);
		}		
	}
	wind_update(END_MCTRL);
	
	return(n_state);
}

/* -------------------------------------- */

int cdecl user_ob(PARMBLK	*pblk)
{
/* Userdef's */
	if(pblk->pb_parm == 1)
		return(usr_liste(pblk));
	else if(pblk->pb_parm == 2)
		return(usr_mail(pblk));
	else if(pblk->pb_parm == 3)
		return(col_field(pblk));
	else /* Bei Editor-Fenstern ist der Zeiger auf das Fenster der pb_parm */
		return(usr_editor(pblk));
}

/* -------------------------------------- */

int check_clip(int *src, int *dst)
{/* PrÅft, ob pxyarray src in dst liegt, paût src ggf. an und
    gibt 0 oder 1 zurÅck. PrÅft nur auf x-Ebene */
   
	if((src[0] < dst[0]) && (src[2] < dst[0])) return(0);
	if((src[0] > dst[2]) && (src[2] > dst[2])) return(0);
	if(src[0] < dst[0]) src[0]=dst[0];
	if(src[2] > dst[2]) src[2]=dst[2];
	return(1);
}

/* -------------------------------------- */

int cdecl usr_liste(PARMBLK *pblk)
{
	GRECT	g_ob, g_clip;
	MFDB m2;
	int	a, y, txy[4], pxy[4], cabs[4], cbtr[4], cdat[4], extnd[8];
	int	*col, dabs, dbtr, ddat, base_ico, ico_add_y, wcol, text_off;
	int	anh_ob, awd_ob, itr_ob;
	long ix=ios.list_off;

	col=&(ios.lsndcol);
	
	for(a=VSND16; a<=VGSD8; ++a)
		ovorl[a].ob_x=pblk->pb_x+2;
	for(a=VAWD16; a<=VAWD8; ++a)
		ovorl[a].ob_x=pblk->pb_x+2+4;
	for(a=VANH16; a<=VANH8; ++a)
		ovorl[a].ob_x=pblk->pb_x+2+16+2;
	for(a=ITR16; a<=ITR8; ++a)
		ovorl[a].ob_x=pblk->pb_x+2+4;
	
	text_off=4;
	if(db_mode) text_off=20;
	
	base_ico=VSND16; anh_ob=VANH16; awd_ob=VAWD16; itr_ob=ITR16;
	if(ios.lfhi < 16)
	{	base_ico=VSND12; anh_ob=VANH12; awd_ob=VAWD12; itr_ob=ITR12;}
	if(ios.lfhi < 12)
	{	base_ico=VSND8; anh_ob=VANH8; awd_ob=VAWD8; itr_ob=ITR8;}
	ico_add_y=(ios.lfhi-ovorl[base_ico].ob_height)/2;

	if(ico_add_y < 0) ico_add_y=0;
	g_ob.g_x=pblk->pb_x;	g_ob.g_y=pblk->pb_y;	g_ob.g_w=pblk->pb_w;	g_ob.g_h=pblk->pb_h;
	g_clip.g_x=pblk->pb_xc;	g_clip.g_y=pblk->pb_yc;	g_clip.g_w=pblk->pb_wc;	g_clip.g_h=pblk->pb_hc;
	if(rc_intersect(&g_ob, &g_clip)==0) return(0);
	pxy[0]=g_clip.g_x;
	pxy[1]=g_clip.g_y;
	pxy[2]=g_clip.g_x+g_clip.g_w-1;
	pxy[3]=g_clip.g_y+g_clip.g_h-1;
	
	cabs[1]=cbtr[1]=cdat[1]=pxy[1];
	cabs[3]=cbtr[3]=cdat[3]=pxy[3];
	cabs[0]=pblk->pb_x; cabs[2]=cabs[0]+ios.from_len-3; 
	cbtr[0]=cabs[2]+3; cbtr[2]=cbtr[0]+ios.subj_len-3;
	cdat[0]=cbtr[2]+3; cdat[2]=pblk->pb_x+pblk->pb_w-1;
	dabs=check_clip(cabs, pxy);
	dbtr=check_clip(cbtr, pxy);
	ddat=check_clip(cdat, pxy);

	vs_clip(handle, 1, pxy);
	vswr_mode(handle, MD_REPLACE);
	vsf_color(handle, ios.lcol);
	vsf_interior(handle, FIS_SOLID);
	vsf_perimeter(handle, 0);
	if(lst_img.fd_addr==NULL)
	{
		v_bar(handle, pxy);
	}
	else
	{ /* Hintergrund pflastern */
		/* Offset des nicht sichtbaren oberen Listenbereichs */
		ix=ix*ios.lfhi; ix=-ix+pblk->pb_y;
		while( (ix+lst_img.fd_h-1) < pblk->pb_y) ix+=lst_img.fd_h-1;
		extnd[0]=0; extnd[1]=0;
		extnd[2]=lst_img.fd_w; extnd[3]=lst_img.fd_h;
		extnd[5]=(int)ix-(lst_img.fd_h-1);
		extnd[7]=(int)ix;
		m2=lst_img;
		m2.fd_addr=NULL;
		do
		{
			extnd[4]=pblk->pb_x-(lst_img.fd_w-1);
			extnd[6]=pblk->pb_x;
			extnd[5]+=lst_img.fd_h-1;
			extnd[7]+=lst_img.fd_h-1;
			do
			{
				extnd[4]+=lst_img.fd_w-1;
				extnd[6]+=lst_img.fd_w-1;
				vro_cpyfm(handle, 3, extnd, &lst_img, &m2);
			}while(extnd[6] < pblk->pb_x+pblk->pb_w);
		}while(extnd[7] < pblk->pb_y+pblk->pb_h);
	}
	ix=ios.list_off;
	
	vst_font(handle, ios.lfid);
	vst_point(handle, ios.lfsiz, &a, &a, &a, &a);
	vst_color(handle, wcol=ios.lubkcol);
	vst_effects(handle, 0);
	vst_alignment(handle, 0, 3, &a, &a);	/* Bottom Line Alignment */
	vswr_mode(handle, MD_TRANS);
	y=pblk->pb_y;
	while(y+ios.lfhi < pblk->pb_yc)
	{ y+=ios.lfhi, ++ix;}

	while((y < pblk->pb_yc+pblk->pb_hc) && (ix < fld_c))
	{
		ovorl[base_ico+fld[ix].ftype].ob_y=y+ico_add_y;
		if(fld[ix].ftype <= FLD_BAK)
			vst_color(handle, wcol=col[(fld[ix].ftype < FLD_BAK) ? fld[ix].ftype : FLD_NON]);
		/* Selektions-Balken zeichenen */
		if(ios.list_sel==ix)
		{
			vs_clip(handle, 1, pxy);
			vswr_mode(handle, MD_REPLACE);
			vsf_color(handle, wcol);
			txy[0]=pblk->pb_x; txy[1]=y; 
			txy[2]=pblk->pb_x+pblk->pb_w-1; 
			txy[3]=y+ios.lfhi;
			v_bar(handle, txy);
			vst_color(handle, ios.lcol);
			vswr_mode(handle, MD_TRANS);
		}
		/* Icon zeichnen */
		if((fld[ix].ftype == FLD_SND) && (fld[ix].loc_flags & LF_DELAYED))
			ovorl[base_ico+FLD_SND].ob_state |= DISABLED;
		objc_draw(ovorl, base_ico+fld[ix].ftype, 8, g_clip.g_x, g_clip.g_y, g_clip.g_w, g_clip.g_h);
		ovorl[base_ico+FLD_SND].ob_state &= (~DISABLED);
		if(db_mode)
		{ /* Ggf. "beantwortet" "interessant" und "Anhang"-Icon zeichnen */
			if((fld[ix].ftype > FLD_SND) && (fld[ix].ftype < FLD_NON) && (fld[ix].fspec.finfo.flags & FF_ITR))
			{/* zuerst "interessant" */
				ovorl[itr_ob].ob_y=y+ico_add_y;
				objc_draw(ovorl, itr_ob, 8, g_clip.g_x, g_clip.g_y, g_clip.g_w, g_clip.g_h);
			}
			if((fld[ix].ftype == FLD_RED) && (fld[ix].fspec.finfo.flags & FF_ANS))
			{/* darÅber ggf. beantwortet-HÑkchen */
				ovorl[awd_ob].ob_y=y+ico_add_y;
				objc_draw(ovorl, awd_ob, 8, g_clip.g_x, g_clip.g_y, g_clip.g_w, g_clip.g_h);
			}
			if((fld[ix].ftype > FLD_SND) && (fld[ix].ftype < FLD_NON) && (fld[ix].fspec.finfo.flags & FF_ATX))
			{
				ovorl[anh_ob].ob_y=y+ico_add_y;
				objc_draw(ovorl, anh_ob, 8, g_clip.g_x, g_clip.g_y, g_clip.g_w, g_clip.g_h);
			}
		}
		/* Text schreiben */
		if(fld[ix].ftype > FLD_BAK)	/* Ordner und Gruppen */
		{
			if(((fld[ix].ftype==FLD_FLD)||(fld[ix].ftype==FLD_GRP)||(fld[ix].ftype==FLD_GSD))&&(fld[ix].loc_flags & LF_UNREAD))
				vst_effects(handle, 1);
			v_gtext(handle, pblk->pb_x+ovorl[base_ico].ob_width+4, y+ios.lfhi-1, fld[ix].from);
			vst_effects(handle, 0);
		}
		else if(fld[ix].ftype == FLD_BAK)	/* .. */
		{
			vs_clip(handle, 1, pxy);
			v_gtext(handle, pblk->pb_x+ovorl[base_ico].ob_width+4, y+ios.lfhi-1, fld[ix].from);
		}
		else	/* Der Rest */
		{
			if(dabs)
			{vs_clip(handle, 1, cabs); v_gtext(handle, pblk->pb_x+ovorl[base_ico].ob_width+text_off, y+ios.lfhi-1, fld[ix].from);}
			if(dbtr)
			{vs_clip(handle, 1, cbtr); v_gtext(handle, pblk->pb_x+ios.from_len+1, y+ios.lfhi-1, fld[ix].subj);}
			if(ddat)
			{vs_clip(handle, 1, cdat); v_gtext(handle, pblk->pb_x+ios.from_len+ios.subj_len+1, y+ios.lfhi-1, fld[ix].date);}
		}
		if(ios.list_sel==ix) vst_color(handle, wcol);
		++ix;
		y+=ios.lfhi;
	}

	/* Trennstriche zeichnen */
	if(fld && (fld[0].ftype < FLD_FLD))	/* Nicht bei Ordner und Gruppen */
	{
		vs_clip(handle, 1, pxy);
		if((ios.list_off==0) && (fld[0].ftype==FLD_BAK))
		{/* Erster Eintrag ist .., keine Trennstriche durch */
			if(pxy[1] > pblk->pb_y + ios.lfhi) goto line_draw;
			/* Strich quer zeichnen */
			pxy[0]=pblk->pb_x;pxy[1]=pxy[3]=pblk->pb_y+ios.lfhi-1;
			pxy[2]=pblk->pb_x+pblk->pb_w-1;
			v_pline(handle, 2, pxy);
			
			pxy[1]=pblk->pb_y+ios.lfhi;
			pxy[3]=g_clip.g_y+g_clip.g_h-1;
			if(pxy[3] <= pxy[1]) goto no_draw;
		}
line_draw:
		vswr_mode(handle, MD_REPLACE);
		vsl_color(handle, 1);
		pxy[0]=pxy[2]=pblk->pb_x+ios.from_len-1;
		v_pline(handle, 2, pxy);
		pxy[0]=pxy[2]=pblk->pb_x+ios.from_len+ios.subj_len-1;
		v_pline(handle, 2, pxy);
	}
no_draw:
	vs_clip(handle, 0, pxy);

	/* AES-VDI-Workstation wieder auf Åbregebenes Objekt-Clipping
		zurÅcksetzen. (Wurde durch Icon-Zeichnen verÑndert).
	*/
	objc_draw(ovorl, HIDDEN, 8, pblk->pb_xc, pblk->pb_yc, pblk->pb_wc, pblk->pb_hc);
	return(0);
}

/* -------------------------------------- */

void v_lbar(int handle, long *bar, int *wclip)
{
	long	clip[4];
	int		pxy[4];
	
	clip[0]=wclip[0]; clip[1]=wclip[1]; clip[2]=wclip[2]; clip[3]=wclip[3];
	
	if((bar[1] < clip[1]) && (bar[3] < clip[1])) return;
	if((bar[1] > clip[3]) && (bar[3] > clip[3])) return;
	pxy[0]=(int)bar[0];
	if(bar[1] < clip[1]) 
		pxy[1]=(int)clip[1];
	else
		pxy[1]=(int)bar[1];
	pxy[2]=(int)bar[2];
	if(bar[3] > clip[3]) 
		pxy[3]=(int)clip[3];
	else
		pxy[3]=(int)bar[3];
	v_bar(handle, pxy);
}


/* -------------------------------------- */

int cdecl usr_mail(PARMBLK *pblk)
{
	GRECT	g_ob, g_clip;
	MFDB 	m2;
	int		a, y, pxy[4], extnd[8], xtoff, lreal=1, fcolor;
	long	wlen=0, cnt=0, lpxy[4], ix;
	char	*w=loaded, *mc, mem;
	
	g_ob.g_x=pblk->pb_x;	g_ob.g_y=pblk->pb_y;	g_ob.g_w=pblk->pb_w;	g_ob.g_h=pblk->pb_h;
	g_clip.g_x=pblk->pb_xc;	g_clip.g_y=pblk->pb_yc;	g_clip.g_w=pblk->pb_wc;	g_clip.g_h=pblk->pb_hc;
	if(rc_intersect(&g_ob, &g_clip)==0) return(0);
	pxy[0]=g_clip.g_x;
	pxy[1]=g_clip.g_y;
	pxy[2]=g_clip.g_x+g_clip.g_w-1;
	pxy[3]=g_clip.g_y+g_clip.g_h-1;
	
	vs_clip(handle, 1, pxy);
	vswr_mode(handle, MD_REPLACE);

	vsf_color(handle, ios.mcol);
	vsf_interior(handle, FIS_SOLID);
	vsf_perimeter(handle, 0);

	if(msg_img.fd_addr==NULL)
	{
		/* FlÑche zeichnen */
		v_bar(handle, pxy);
	}
	else
	{ /* Hintergrund pflastern */
		/* Offset des nicht sichtbaren oberen Listenbereichs */
		ix=lloff*ios.mfhi; ix=-ix+pblk->pb_y;
		while( (ix+msg_img.fd_h-1) < pblk->pb_y) ix+=msg_img.fd_h-1;
		extnd[0]=0; extnd[1]=0;
		extnd[2]=msg_img.fd_w; extnd[3]=msg_img.fd_h;
		extnd[5]=(int)ix-(msg_img.fd_h-1);
		extnd[7]=(int)ix;
		m2=msg_img;
		m2.fd_addr=NULL;
		do
		{
			extnd[4]=pblk->pb_x-(msg_img.fd_w-1);
			extnd[6]=pblk->pb_x;
			extnd[5]+=msg_img.fd_h-1;
			extnd[7]+=msg_img.fd_h-1;
			do
			{
				extnd[4]+=msg_img.fd_w-1;
				extnd[6]+=msg_img.fd_w-1;
				vro_cpyfm(handle, 3, extnd, &msg_img, &m2);
			}while(extnd[6] < pblk->pb_x+pblk->pb_w);
		}while(extnd[7] < pblk->pb_y+pblk->pb_h);
	}
	
	if(w==NULL) 
	{
		vs_clip(handle, 0, pxy);
		return(0);
	}
		
	vst_font(handle, ios.mfid);
	vst_point(handle, ios.mfsiz, &a, &a, &a, &a);
	vst_effects(handle, 0);
	vst_alignment(handle, 0, 3, &a, &a);	/* Bottom Line Alignment */
	vswr_mode(handle, MD_TRANS);
	y=pblk->pb_y;
	/* Offset-Block durchhecheln und qoute-Zustand merken */

	lreal=1;
	while(cnt < lloff)
	{
		if(lreal && ((w[0]=='>')||(w[1]=='>')||(w[2]=='>')||(w[3]=='>')))
			fcolor=ios.quotecol;
		else if(lreal)
			fcolor=ios.mtextcol;
		if(w[lstrlen(w)] <= RP_CRLF) lreal=1;
		else lreal=0;

		wlen+=lstrlen(w)+1;
		w+=lstrlen(w)+1;
		++cnt;
	}

	while(y+ios.mfhi < pblk->pb_yc)
	{
		if(lreal && ((w[0]=='>')||(w[1]=='>')||(w[2]=='>')||(w[3]=='>')))
			fcolor=ios.quotecol;
		else if(lreal)
			fcolor=ios.mtextcol;
		if(w[lstrlen(w)] <= RP_CRLF) lreal=1;
		else lreal=0;

		y+=ios.mfhi; 
		wlen+=lstrlen(w)+1; 
		w+=lstrlen(w)+1; 
	}
	vst_color(handle, fcolor);
	
	while((y < pblk->pb_yc+pblk->pb_hc) && (wlen < llen))
	{
		if(lreal && ((w[0]=='>')||(w[1]=='>')||(w[2]=='>')||(w[3]=='>')))
			vst_color(handle, fcolor=ios.quotecol);
		else if(lreal)
			vst_color(handle, fcolor=ios.mtextcol);
		if(w[lstrlen(w)] <= RP_CRLF) lreal=1;
		else lreal=0;
		xtoff=0;
		if((w > loaded) && (w[0]==RP_CRLF))
		{/* Header-Trennstrich zeichnen */
			vswr_mode(handle, MD_REPLACE);
			vsl_color(handle, 1);
			extnd[0]=pblk->pb_x;extnd[1]=extnd[3]=y+ios.mfhi/2;
			extnd[2]=pblk->pb_x+pblk->pb_w-1;
			v_pline(handle, 2, extnd);
			vswr_mode(handle, MD_TRANS);
		}
		do
		{
			if((mc=lstrchr(w, 9))!=NULL){mem=1; *mc=0;}
			else mem=0;
			lv_gtext(handle, pxy, xtoff+pblk->pb_x+MESSAGE_OFFSET, y+ios.mfhi, w, fcolor);
			mail_extent(w, extnd);
			xtoff+=extnd[2];
			if(mem) { *mc=9; wlen+=mc-w+1; w=mc+1; xtoff+=ios.mcwidth[9];}
			else {wlen+=lstrlen(w); w+=lstrlen(w);}
		}while(*w > RP_TAB);
		wlen+=lstrlen(w)+1; w+=lstrlen(w)+1;
		y+=ios.mfhi;
	}
	/* Selektion invertieren */
	if((sel_sl > -1) && (loaded!=NULL))
	{/* Startzeile bestimmen */
		vswr_mode(handle, MD_XOR);
		vsf_color(handle, 1);
		w=loaded; cnt=0;
		while(cnt < sel_sl)
		{	w+=lstrlen(w)+1;	++cnt;}
		if(sel_sc)	/* Kann 0 oder 1 sein, ist aber das gleiche */
		{
			mem=w[sel_sc-1]; w[sel_sc-1]=0;
			mail_extent(w, extnd); w[sel_sc-1]=mem;
		}
		else extnd[2]=0;
		lpxy[0]=extnd[2]+pblk->pb_x+MESSAGE_OFFSET; 
		lpxy[1]=(sel_sl-lloff)*(long)(ios.mfhi)+pblk->pb_y;
		if(sel_el==sel_sl)
		{/* Startzeile=Endezeile */
			mem=w[sel_ec]; w[sel_ec]=0;
			mail_extent(w, extnd); w[sel_ec]=mem;
			lpxy[2]=extnd[2]+pblk->pb_x+MESSAGE_OFFSET-1; lpxy[3]=lpxy[1]+ios.mfhi-1;
			v_lbar(handle, lpxy, pxy);
			goto _end_sel;
		}
		/* Startzeile Zeichnen */
		lpxy[2]=pblk->pb_x+MESSAGE_OFFSET+pblk->pb_w-1; 
		lpxy[3]=lpxy[1]+ios.mfhi-1;
		v_lbar(handle, lpxy, pxy);
		/* Mittelteil */
		if(sel_el-sel_sl > 1)
		{
			lpxy[0]=pblk->pb_x+MESSAGE_OFFSET; lpxy[1]+=ios.mfhi;
			lpxy[2]=pblk->pb_x+MESSAGE_OFFSET+pblk->pb_w-1;
			lpxy[3]=lpxy[1]+ios.mfhi*(sel_el-sel_sl-1)-1;
			v_lbar(handle, lpxy, pxy);
		}
		/* Endzeile */
		if(sel_ec==0) goto _end_sel;	/* Kein Zeichen in letzter Zeile */
		if(w) while(cnt < sel_el)
		{	w+=lstrlen(w)+1;	++cnt;}
		mem=w[sel_ec]; w[sel_ec]=0;
		mail_extent(w, extnd); w[sel_ec]=mem;
		lpxy[0]=pblk->pb_x+MESSAGE_OFFSET;
		lpxy[2]=pblk->pb_x+MESSAGE_OFFSET+extnd[2]-1;
		lpxy[1]=lpxy[3]+1; lpxy[3]+=ios.mfhi;
		v_lbar(handle, lpxy, pxy);
	}

_end_sel:	
	vs_clip(handle, 0, pxy);
	/* AES-VDI-Workstation wieder auf Åbregebenes Objekt-Clipping
		zurÅcksetzen. (Wurde durch Icon-Zeichnen verÑndert).
	*/
	objc_draw(ovorl, HIDDEN, 8, pblk->pb_xc, pblk->pb_yc, pblk->pb_wc, pblk->pb_hc);
	return(0);
}

/* -------------------------------------- */

int cdecl usr_editor(PARMBLK *pblk)
{
	MFDB	mdst;
	GRECT	g_ob, g_clip;
	EDIT_OB	*edob=(EDIT_OB*)( ((WINDOW*)(pblk->pb_parm))->user);
	ED_LIN	*el;
	long	cnt=0, lpxy[4], ix;
	int		y, pxy[4], a, extnd[8], xoff, xtoff, xmoff, fcolor;
	int		croff;
	char	mem, *c, *mc;

	mdst.fd_addr=NULL;

	croff=(ios.efhi-8)/2;
	g_ob.g_x=pblk->pb_x;	g_ob.g_y=pblk->pb_y;	g_ob.g_w=pblk->pb_w;	g_ob.g_h=pblk->pb_h;
	g_clip.g_x=pblk->pb_xc;	g_clip.g_y=pblk->pb_yc;	g_clip.g_w=pblk->pb_wc;	g_clip.g_h=pblk->pb_hc;
	if(rc_intersect(&g_ob, &g_clip)==0) return(0);
	pxy[0]=g_clip.g_x;
	pxy[1]=g_clip.g_y;
	pxy[2]=g_clip.g_x+g_clip.g_w-1;
	pxy[3]=g_clip.g_y+g_clip.g_h-1;
	
	vs_clip(handle, 1, pxy);

	vswr_mode(handle, MD_REPLACE);
	vsf_color(handle, ios.ecol);
	vsf_interior(handle, FIS_SOLID);
	vsf_perimeter(handle, 0);
	vst_font(handle, ios.efid);
	vst_point(handle, ios.efsiz, &a, &a, &a, &a);
	vst_color(handle, ios.etextcol);
	vst_effects(handle, 0);
	vst_alignment(handle, 0, 3, &a, &a);	/* Bottom Line Alignment */
	xoff=ios.eqwi;
	if(edob->cur_only==1) goto _crsr_only;

	/* Hintergrundfarbe */
	if(ed_img.fd_addr==NULL)
	{
		v_bar(handle, pxy);
	}
	else
	{ /* Hintergrund pflastern */
		/* Offset des nicht sichtbaren oberen Listenbereichs */
		ix=(edob->offset)*ios.efhi; ix=-ix+pblk->pb_y;
		while( (ix+ed_img.fd_h-1) < pblk->pb_y) ix+=ed_img.fd_h-1;
		extnd[0]=0; extnd[1]=0;
		extnd[2]=ed_img.fd_w; extnd[3]=ed_img.fd_h;
		extnd[5]=(int)ix-(ed_img.fd_h-1);
		extnd[7]=(int)ix;
		do
		{
			extnd[4]=pblk->pb_x-(ed_img.fd_w-1);
			extnd[6]=pblk->pb_x;
			extnd[5]+=ed_img.fd_h-1;
			extnd[7]+=ed_img.fd_h-1;
			do
			{
				extnd[4]+=ed_img.fd_w-1;
				extnd[6]+=ed_img.fd_w-1;
				vro_cpyfm(handle, 3, extnd, &ed_img, &mdst);
			}while(extnd[6] < pblk->pb_x+pblk->pb_w);
		}while(extnd[7] < pblk->pb_y+pblk->pb_h);
	}
		
	/* Text schreiben */
	vswr_mode(handle, MD_TRANS);

	y=pblk->pb_y;
	cnt=0; el=edob->first;
	while((el) && (cnt < edob->offset)) {el=el->next; ++cnt;}
	while(y+ios.efhi < pblk->pb_yc)
	{ y+=ios.efhi; if(el) el=el->next; ++cnt;}

	while((y < pblk->pb_yc+pblk->pb_hc) && (el))
	{
		if(el->line)
		{
			if(cnt==edob->cur_y)
				c=edob->buf_line;
			else
				c=el->line;
			if(el->quoted)
			{
				vst_color(handle, fcolor=ios.quotecol);
				v_gtext(handle, pblk->pb_x+MESSAGE_OFFSET, y+ios.efhi-1, ">");
				xtoff=xoff;
			}
			else
			{
				vst_color(handle, fcolor=ios.etextcol);
				xtoff=0;
			}
			
			do
			{
				if((mc=strchr(c, 9))!=NULL){mem=2; *mc=0;}
				else if(*(mc=&(c[strlen(c)-1]))==13) {mem=1; *mc=0;}
				else mem=0;
				url_v_gtext(handle, pxy, xtoff+pblk->pb_x+MESSAGE_OFFSET, y+ios.efhi, c, fcolor, ed_extent);
				ed_extent(c, extnd); xmoff=extnd[2];
				if(edob->crvis && mem)
				{
					extnd[4]=xtoff+extnd[2]+pblk->pb_x+MESSAGE_OFFSET;
					extnd[5]=y+croff;
					extnd[6]=extnd[4]+15;
					extnd[7]=extnd[5]+7;
					extnd[0]=extnd[1]=0;
					extnd[2]=15; extnd[3]=7;
					if(mem==1)
						vrt_cpyfm(handle, MD_TRANS, extnd, &crmfdb, &mdst, &(ios.etextcol));
					else
						vrt_cpyfm(handle, MD_TRANS, extnd, &tabmfdb, &mdst, &(ios.etextcol));
				}
				xtoff+=xmoff;
				if(mem==1) {*mc=13; c=mc+1; xtoff+=ios.ecwidth[13];}
				else if(mem==2) { *mc=9; c=mc+1; xtoff+=ios.ecwidth[9];}
				else c+=strlen(c);
			}while(*c);
		}
		el=el->next;
		y+=ios.efhi;
		++cnt;
	}

_crsr_only:
	/* Cursor zeichnen */
	if(edob->sel_sx > -1) goto _sel_edit;
	if(edob->cur_only==2) goto _sel_edit;	/* Cursor nicht zeichnen */
	if(((WINDOW*)(pblk->pb_parm))->dinfo->dedit!=0) goto _sel_edit;
	if(edob->cur_y < edob->offset) goto _sel_edit;
	if(edob->cur_y > edob->offset+pblk->pb_h/ios.efhi+1) goto _sel_edit;
	
	vswr_mode(handle, MD_XOR);
	vsf_color(handle, 1);

	mem=edob->buf_line[edob->cur_x]; edob->buf_line[edob->cur_x]=0;
	ed_extent(edob->buf_line, extnd); edob->buf_line[edob->cur_x]=mem;
	lpxy[0]=extnd[2]+pblk->pb_x+MESSAGE_OFFSET; 
	if(get_ed_lin(edob)->quoted) lpxy[0]+=xoff;
	lpxy[1]=(edob->cur_y-edob->offset)*(long)(ios.efhi)+pblk->pb_y;
	lpxy[2]=lpxy[0]+1;
	lpxy[3]=lpxy[1]+ios.efhi-1;
	v_lbar(handle, lpxy, pxy);

_sel_edit:
	/* Selektion invertieren */
	if(edob->sel_sx == -1) goto _end_edit;
	/* Startzeile bestimmen */
	vswr_mode(handle, MD_XOR);
	vsf_color(handle, 1);

	cnt=0; el=edob->first;
	while((el) && (cnt < edob->sel_sy)) {el=el->next; ++cnt;}
	c=el->line;
	if(edob->sel_sx)
	{
		mem=c[edob->sel_sx]; c[edob->sel_sx]=0;
		ed_extent(c, extnd); c[edob->sel_sx]=mem;
	}
	else extnd[2]=0;
	lpxy[0]=extnd[2]+pblk->pb_x+MESSAGE_OFFSET;
	if(el->quoted) lpxy[0]+=xoff;
	lpxy[1]=(edob->sel_sy-edob->offset)*(long)(ios.efhi)+pblk->pb_y;
	if(edob->sel_ey==edob->sel_sy)
	{/* Startzeile=Endezeile */
		mem=c[edob->sel_ex]; c[edob->sel_ex]=0;
		ed_extent(c, extnd); c[edob->sel_ex]=mem;
		lpxy[2]=extnd[2]+pblk->pb_x+MESSAGE_OFFSET-1; lpxy[3]=lpxy[1]+ios.efhi-1;
		if(el->quoted) lpxy[2]+=xoff;
		v_lbar(handle, lpxy, pxy);
		goto _end_edit;
	}
	/* Startzeile Zeichnen */
	lpxy[2]=pblk->pb_x+MESSAGE_OFFSET+pblk->pb_w-1; 
	lpxy[3]=lpxy[1]+ios.efhi-1;
	v_lbar(handle, lpxy, pxy);
	/* Mittelteil */
	if(edob->sel_ey-edob->sel_sy > 1)
	{
		lpxy[0]=pblk->pb_x+MESSAGE_OFFSET; lpxy[1]+=ios.efhi;
		lpxy[2]=pblk->pb_x+MESSAGE_OFFSET+pblk->pb_w-1;
		lpxy[3]=lpxy[1]+ios.efhi*(edob->sel_ey-edob->sel_sy-1)-1;
		v_lbar(handle, lpxy, pxy);
	}
	/* Endzeile */
	if(edob->sel_ex==0) goto _end_edit;	/* Kein Zeichen in letzter Zeile */
	while(cnt < edob->sel_ey)
	{	el=el->next;	++cnt;} c=el->line;
	mem=c[edob->sel_ex]; c[edob->sel_ex]=0;
	ed_extent(c, extnd); c[edob->sel_ex]=mem;
	lpxy[0]=pblk->pb_x+MESSAGE_OFFSET;
	lpxy[2]=pblk->pb_x+MESSAGE_OFFSET+extnd[2]-1;
	if(el->quoted) lpxy[2]+=xoff;
	lpxy[1]=lpxy[3]+1; lpxy[3]+=ios.efhi;
	v_lbar(handle, lpxy, pxy);

_end_edit:
	vs_clip(handle, 0, pxy);
	return(0);
}

/* -------------------------------------- */

int cdecl col_field(PARMBLK *pblk)
{
	int		pxy[10];
	
	pxy[0]=pblk->pb_xc;
	pxy[1]=pblk->pb_yc;
	pxy[2]=pblk->pb_xc+pblk->pb_wc-1;
	pxy[3]=pblk->pb_yc+pblk->pb_hc-1;
	vs_clip(handle, 1, pxy);

	/* Rahmen zeichnen */
	vswr_mode(handle, MD_REPLACE);
	vsl_width(handle, 1);

	/* Farbfeld bekommt innen schwarzen+weiûen Rand */
	vsl_color(handle, 1);
	pxy[8]=pxy[6]=pxy[0]=pblk->pb_x;
	pxy[9]=pxy[3]=pxy[1]=pblk->pb_y;
	pxy[4]=pxy[2]=pblk->pb_x+pblk->pb_w-1;
	pxy[7]=pxy[5]=pblk->pb_y+pblk->pb_h-1;
	v_pline(handle, 5, pxy);
	vsl_color(handle, 0);
	pxy[8]=pxy[6]=pxy[0]=pblk->pb_x+1;
	pxy[9]=pxy[3]=pxy[1]=pblk->pb_y+1;
	pxy[4]=pxy[2]=pblk->pb_x+pblk->pb_w-2;
	pxy[7]=pxy[5]=pblk->pb_y+pblk->pb_h-2;
	v_pline(handle, 5, pxy);
	
	/* Farbfeld zeichnen */
	pxy[0]=pblk->pb_x+2;
	pxy[1]=pblk->pb_y+2;
	pxy[2]=pxy[0]+pblk->pb_w-4;
	pxy[3]=pxy[1]+pblk->pb_h-4;

	vsf_color(handle, ext_type(pblk->pb_tree, pblk->pb_obj));
	vsf_interior(handle, FIS_SOLID);
	vsf_perimeter(handle, 0);
	v_bar(handle, pxy);

	/* Selektiert? */
	if(pblk->pb_currstate & SELECTED)
	{
		vsf_color(handle, 1);
		vswr_mode(handle, MD_XOR);
		pxy[8]=pxy[6]=pxy[0]=pblk->pb_x+1;
		pxy[9]=pxy[3]=pxy[1]=pblk->pb_y+1;
		pxy[4]=pxy[2]=pblk->pb_x+pblk->pb_w-2;
		pxy[7]=pxy[5]=pblk->pb_y+pblk->pb_h-2;
		v_pline(handle, 5, pxy);
	}
	vs_clip(handle, 0, pxy);
	
	return(0);
}
