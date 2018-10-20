#include <grape_h.h>
#include "magicmac.h"
#include "grape.h"
#include "module.h" 
#include "undo.h"
#include "ple.h"
#include "penedit.h"
#include "penpal.h"
#include "dithtab.h"
#include "layer.h"
#include "mask.h"
#include "file_i_o.h"
#include "maininit.h"
#include "new.h"
#include "coled.h"
#include "ctcppt.h"
#include "main_win.h"
#include "ass_dith.h"
#include "preview.h"
#include "greydith.h"
#include "jobs.h"
#include "xrsrc.h"
#include "gpenic.h"
#include "mforms.h"
#include "print.h"
#include "zoom.h"
#include "export.h"
#include "fiomod.h"
#include "stempel.h"

extern void right_on(int wid);

/* Letzte Mausform ist -1 oder sel_tool */
int last_form=0;

void main(void)
{
	e_start_as(PRG,"Grape" );	

	if(ap_type & PRG)
	{
		uses_vdi();
		mmain();
	}
	
	e_quit();
}


/*

 Init 
 
 */

int graf_mouse(int form, MFORM *mf)
{
	AESPB	c;

	last_form=-form;

	c.contrl=_GemParBlk.contrl;
	c.global=_GemParBlk.global;
	c.intin=_GemParBlk.intin;
	c.intout=_GemParBlk.intout;
	c.addrin=(int*)_GemParBlk.addrin;
	c.addrout=(int*)_GemParBlk.addrout;
	
	_GemParBlk.contrl[0]=78;
	_GemParBlk.contrl[1]=1;
	_GemParBlk.contrl[2]=1;
	_GemParBlk.contrl[3]=1;
	_GemParBlk.contrl[4]=0;
	
	_GemParBlk.intin[0]=form;
	_GemParBlk.addrin[0]=mf;

	_crystal(&c);
	
	return(_GemParBlk.intout[0]);
}

void memtest(void *p)
{
	if(!p)
	{
		form_alert(1,"[3][Nicht genug Speicher!][Quit]");
		exit(0);
	}
}

void usdef_mem(OBJECT *tree, int ob)
{
	int w, a;
	
	w=((U_OB*)(tree[ob]_UP_))->color.w=((tree[ob].ob_width/16)+1)*16;
	((U_OB*)(tree[ob]_UP_))->color.r=(unsigned char*)malloc(w*tree[ob].ob_height);
	((U_OB*)(tree[ob]_UP_))->color.g=(unsigned char*)malloc(w*tree[ob].ob_height);
	((U_OB*)(tree[ob]_UP_))->color.b=(unsigned char*)malloc(w*tree[ob].ob_height);
	((U_OB*)(tree[ob]_UP_))->color.table_offset=(long*)malloc((long)((long)tree[ob].ob_height*(long)sizeof(long)));
	memtest(((U_OB*)(tree[ob]_UP_))->color.r);
	memtest(((U_OB*)(tree[ob]_UP_))->color.g);
	memtest(((U_OB*)(tree[ob]_UP_))->color.b);
	memtest(((U_OB*)(tree[ob]_UP_))->color.table_offset);
	for(a=0; a < tree[ob].ob_height; ++a)
	{
		((U_OB*)(tree[ob]_UP_))->color.table_offset[a]=(long)((long)w*(long)a);
	}
}

void make_new_colpal(void)
{/* Spart Objekte in der RSC */
	OBJECT *npal;
	USERBLK *ublk;
	int		 a, b, ix;
	
	npal=(OBJECT*)malloc((COL1+260)*sizeof(OBJECT)+260*sizeof(USERBLK));
	memtest(npal);
	ublk=(USERBLK*)(&(npal[COL1+260]));
	/* Bereits vorhande Objekte kopieren */
	for(a=0; a < COL1; ++a)
		npal[a]=ocolpal[a];

	/* Userdefs erzeugen und Userblk setzen */
	for(a=0; a < 26; ++a)
	{
		for(b=0; b < 10; ++b)
		{
			ix=COL1+a*10+b;
			npal[ix]=ocolpal[COL1];
			npal[ix].ob_next=ix+1;
			npal[ix].ob_head=npal[ix].ob_tail=-1;
			npal[ix].ob_flags=TOUCHEXIT;
			npal[ix].ob_spec.userblk=&(ublk[a*10+b]);
			npal[ix].ob_spec.userblk->ub_parm=3;
			npal[ix].ob_x=b*ocolpal[COL1].ob_width;
			npal[ix].ob_y=a*ocolpal[COL1].ob_height;
		}
	}
	npal[COL1+259].ob_next=COLPARENT;
	npal[COL1+259].ob_flags|=LASTOB;
	npal[COLPARENT].ob_tail=COL1+259;

	/* Zeiger vertauschen */ 
	((long*)((*(long*)(&_GemParBlk.global[7]))+(*(RSHDR**)(&_GemParBlk.global[7]))->rsh_trindex))[COLPAL]=(long)npal;
	ocolpal=npal;
}

void make_new_penpal(void)
{/* Spart Objekte in der RSC */
	OBJECT *npal;
	int		 a;
	
	npal=(OBJECT*)malloc(GPS2*sizeof(OBJECT));
	memtest(npal);
	opens=npal;
	/* Objekte kopieren */
	for(a=0; a < GPS2; ++a)
		opens[a]=osrcpens[a];

	opens[GPS2-1].ob_next=0;
	opens[GPS2-1].ob_flags|=LASTOB;
	opens[0].ob_tail=GPS2-1;

	opens[0].ob_height=osrcpens[GPSHEAD].ob_height+osrcpens[GPS1].ob_height;
}

void mform_center(OBJECT *tree, int *x, int *y, int *w, int *h)
{/* Nur um den Info-Dial unabhÑngig von form_center in die Bildschirm-
		mitte zu kriegen */
	
	*w=tree[0].ob_width+8;
	*h=tree[0].ob_height+8;
	*x=tree[0].ob_x=(sw-sx-*w)/2+sx+4;
	*y=tree[0].ob_y=(sh-sy-*h)/2+sy+4;
	*x-=4;
	*y-=4;
	
}

void mmain(void)
{
	OBJECT *odummod;
	int	vdirgb[256][3];
	int ox, a, dum, x, y, w, h;
	int	dx, dy, dw, dh;
	long l;
	GRECT	desk;
	
	zoomout=zoomin=0;

	vq_extnd(handle, 1, work_out);
	
	planes=work_out[4];
		
	wind_update(BEG_UPDATE);
	if(!test_resolution(planes))
	{
		wind_update(END_UPDATE);
		form_alert(1,"[3][Grape:|FÅr dieses Bildschirmformat|existiert kein Treiber!][Abbruch]");
		return;
	}
	
	wind_update(BEG_MCTRL);
	graf_mouse(BUSYBEE, NULL);

	main_win.id=-1;	
	
	magics.poly='GPLY';
	magics.penpar='GPPR';
	magics.pens='GPPL';
	magics.col='GCOL';
	magics.colpal='GCPL';
	magics.stempel='GSTP';
	
	layers_off=0;

	table_offset=(long*)malloc(32768l*sizeof(long));
	if(!table_offset)
	{
		form_alert(1,"[3][Nicht genug Speicher!][Quit]");
		exit(0);
	}
	
	red_list=NULL;
	yellow_list=NULL;
	blue_list=NULL;
		
	physbase=Physbase();
	lsb_c=malloc(66*66);
	lsb_m=malloc(66*66);
	lsb_y=malloc(66*66);
	
	Setexc(258,term); /* FÅr Timer-Routine */
	install();
	
	ap_info.menu=do_menu;
	
	ful=NULL;

	wind_get(0,WF_WORKXYWH, &x, &y, &w, &h);
	desk.g_x=sx=x; desk.g_y=sy=y; desk.g_w=sw=w; desk.g_h=sh=h;
	mgmc_extend_base();
	
	init_xrsrc(handle, &desk, pwchar, phchar);
	xrsrc_load("GPENIC.RSC", xrsrc);
	xrsrc_gaddr(0,GPICONS, &oicons, xrsrc);
	xrsrc_gaddr(0,GPMERK, &omerk, xrsrc);
	fix_icontext();
	
	xrsrc_load("GRAPE.RSC", xrsrc);
	
	xrsrc_gaddr(0,GMENU,&mmenu, xrsrc);
	xrsrc_gaddr(0,MKEYCMD, &keycmds, xrsrc);
	xrsrc_gaddr(0,GNEW,&onew, xrsrc);
	xrsrc_gaddr(0,NEWSIZE,&osize, xrsrc);
	xrsrc_gaddr(0,GUNDO, &oundo, xrsrc);
	xrsrc_gaddr(0,GPEN, &opened, xrsrc);
	xrsrc_gaddr(0,GPLEDIT, &opledit, xrsrc);
	xrsrc_gaddr(0,GPPALETTE, &otool, xrsrc);
	xrsrc_gaddr(0,GCOLED, &ocoled, xrsrc);
	xrsrc_gaddr(0,GPENS, &osrcpens, xrsrc);
	xrsrc_gaddr(0,TOOLBAR, &otoolbar, xrsrc);
	xrsrc_gaddr(0,NEWLAY, &onewlay, xrsrc);
	xrsrc_gaddr(0,COPYLAY, &ocopylay, xrsrc);
	xrsrc_gaddr(0,SPECIAL, &ospecial, xrsrc);
	xrsrc_gaddr(0,OFRAME, &oframe, xrsrc);
	xrsrc_gaddr(0,NEWMASK, &onewmask, xrsrc);
	xrsrc_gaddr(0,COLPAL, &ocolpal, xrsrc);
	xrsrc_gaddr(0,COL_D_D, &ocoldd, xrsrc);
	xrsrc_gaddr(0,PASTEMODE, &opmode, xrsrc);
	xrsrc_gaddr(0,STARTUP, &ostartup, xrsrc);
	xrsrc_gaddr(0,AOPTIONS, &oaopt, xrsrc);
	xrsrc_gaddr(0,UNDOOPTS, &ounopt, xrsrc);
	xrsrc_gaddr(0,LAYCLEAR, &oclear, xrsrc);
	xrsrc_gaddr(0,PRINT, &oprint, xrsrc);
	xrsrc_gaddr(0,SETZOOM, &ozoom, xrsrc);
	xrsrc_gaddr(0,FZOOMS, &ofzooms, xrsrc);
	xrsrc_gaddr(0,EXPORT, &oexport, xrsrc);
	xrsrc_gaddr(0,FEXPORT, &ofexport, xrsrc);
	xrsrc_gaddr(0,FEXSAVE, &ofxsave, xrsrc);
	xrsrc_gaddr(0,MODULOPT, &omodopt, xrsrc);
	xrsrc_gaddr(0,STAMPOPT, &ostampopt, xrsrc);
	/* Farbpalette neu im Speicher erzeugen (um Objekte in der RSC zu sparen) */
	make_new_colpal();
	make_new_penpal();
	
	omodule=NULL;
	
	/* Mode-Popups auf Pixel setzen */
	set_ext_type(osize,NSMODE,1);
	set_ext_type(onew,ONMODE,1);
	set_ext_type(oprint,PRMODE,1);

	oaopt[OAWINPOS].ob_state |= SELECTED;
	oaopt[OAPRESS].ob_state |= SELECTED;

	oaopt[OACCP].ob_state &= (~SELECTED);
	oaopt[OACCDIR].ob_state &= (~SELECTED);

	oaopt[OAGEMCLIP].ob_state |= SELECTED;
	set_ext_type(oaopt,OAFORMPOP, 0);
	
	oaopt[OAKOOR].ob_state &= (~SELECTED);
	oaopt[OAOPCLOS].ob_state |= SELECTED;
	
	oaopt[OAMMAIN].ob_state |= SELECTED;
	oaopt[OAQUIT].ob_state &= (~SELECTED);

	oaopt[OAFORM].ob_y=oaopt[OAFORMPOP].ob_y+=oaopt[OAFORMPOP].ob_height/3;
	ofxsave[FXSPOP].ob_y=ofxsave[FXSNUM].ob_y+=ofxsave[FXSNUM].ob_height/3;

	ounopt[UORES1].ob_state |= SELECTED;
	ounopt[UORES2].ob_state &= (~SELECTED);
	ounopt[UORES3].ob_state &= (~SELECTED);
	ounopt[UORES4].ob_state &= (~SELECTED);
	ounopt[UORES5].ob_state |= SELECTED;
	ounopt[UORES6].ob_state |= SELECTED;
	ounopt[UORES7].ob_state |= SELECTED;
	ounopt[UOFULL].ob_state &= (~SELECTED);
	ounopt[UOMEM].ob_state |= DISABLED;
	ounopt[UOMEM].ob_spec.tedinfo->te_ptext=(char*)malloc(8);
	if(!ounopt[UOMEM].ob_spec.tedinfo->te_ptext)
	{
		form_alert(1,"[3][Nicht genug Speicher!][Quit]");
		exit(0);
	}
	ounopt[UOMEM].ob_spec.tedinfo->te_ptext[0]=0;
	ounopt[UOKBMB].ob_state |= DISABLED;
	ounopt[UOFULL1].ob_state |= DISABLED;
	ounopt[UOFULL2].ob_state |= DISABLED|SELECTED;
	
	mmenu[MCOLOR].ob_state|=CHECKED;
	mmenu[MGREYS].ob_state&=(~CHECKED);
	col_or_grey=0;
	
	/* Selektionsfarbe merken (fÅr Umschaltung Farbe/Grausstufen) */
	vq_color(handle, 248, 0, rgb248);
	/* Alle VDI-Farben merken */
	for(a=0; a < 256; ++a)
		vq_color(handle, a, 0, vdirgb[a]);

	set_vdi_colors();
	
	mform_center(ostartup, &dx, &dy, &dw, &dh);
	form_dial(FMD_START, dx, dy, dw, dh, dx, dy, dw, dh);
	
	ostartup[STINIT].ob_flags&=(~HIDETREE);
	ostartup[ST_TEXT].ob_flags&=(~HIDETREE);
	ostartup[STOK].ob_flags|=HIDETREE;
	
	objc_draw(ostartup, 0, 8, sx, sy, sw, sh);
		
	start_text("Tabellen...");
	
	strcpy(paths.pic_path,"X:");
	Dgetpath(&paths.pic_path[2], 0);
	paths.pic_path[0]=(char)(Dgetdrv()+65);
	strcpy(paths.module_path, paths.pic_path);
	strcat(paths.module_path, "\\MODULE\\*.*");
	strcat(paths.pic_path, "\\*.*");
	strcpy(paths.penpar_path, paths.pic_path);
	strcpy(paths.pens_path, paths.pic_path);
	strcpy(paths.poly_path, paths.pic_path); 
	strcpy(paths.col_path, paths.pic_path); 
	strcpy(paths.colpal_path, paths.pic_path); 
	strcpy(paths.stempel_path, paths.pic_path); 
	strcpy(paths.main_load_path, paths.pic_path); 
	strcpy(paths.main_save_path, paths.pic_path); 
	strcpy(paths.main_import_path, paths.pic_path); 
	strcpy(paths.main_export_path, paths.pic_path); 
	strcpy(paths.layer_import_path, paths.pic_path); 
	strcpy(paths.layer_export_path, paths.pic_path); 
	strcpy(paths.mask_import_path, paths.pic_path); 
	strcpy(paths.mask_export_path, paths.pic_path); 
	paths.main_load_name[0]=0;
	paths.main_save_name[0]=0;
	paths.main_import_name[0]=0;
	paths.main_export_name[0]=0;
	paths.layer_import_name[0]=0;
	paths.layer_export_name[0]=0;
	paths.mask_import_name[0]=0;
	paths.mask_export_name[0]=0;
	

	for(a=0; a < 1000; ++a)
		square_root[a]=sqrt(a);
	
	for(a=0; a < 11; ++a)
 	{
	 	for(l=0; l<254; ++l)
			lay_store[a].lm[l].id=-1;
		mask_store[a].mask_id=-1;
	}

	start_text("Objekte...");

	strcpy(onew[ONPX].ob_spec.tedinfo->te_ptext, "00500");
	strcpy(onew[ONPY].ob_spec.tedinfo->te_ptext, "00500");
	strcpy(onew[ONPCNT].ob_spec.tedinfo->te_ptext, "0100");
	strcpy(onew[ONDPI].ob_spec.tedinfo->te_ptext, "0120");
	onew[ONPROP].ob_state&=(~SELECTED);

	fix_icontext();

	colpal_obs.off=0;
	colpal_obs.len=26;
	
	otoolbar[0].ob_height+=4;
	otoolbar[TB_LOLIN].ob_y+=4;

	frame_data.ok=frame_data.vis=0;

	oframe[FLO].ob_width=oframe[FLO].ob_height=
	oframe[FRO].ob_width=oframe[FRO].ob_height=
	oframe[FRU].ob_width=oframe[FRU].ob_height=
	oframe[FLU].ob_width=oframe[FLU].ob_height=
	oframe[FO].ob_width=oframe[FO].ob_height=
	oframe[FU].ob_width=oframe[FU].ob_height=
	oframe[FL].ob_width=oframe[FL].ob_height=
	oframe[FR].ob_width=oframe[FR].ob_height=
	8;

	dum=LAY2-LAY1;
	TB_IMG_X=(otoolbar[LAYVIS-1].ob_width-otoolbar[LAYVIS].ob_width)/2;
	TB_M_IMG_X=(otoolbar[MASK_ON-1].ob_width-otoolbar[MASK_ON].ob_width)/2;
	otoolbar[MASK_ON].ob_x=TB_M_IMG_X;
	opledit[GEUP].ob_x=TB_M_IMG_X;
	opledit[GEDOWN].ob_x=TB_M_IMG_X;
	opledit[GEVMIR].ob_x=TB_M_IMG_X;
	opledit[GEHMIR].ob_x=TB_M_IMG_X;


	if(opledit[GPLEDIT].ob_width > 512)
	{
		form_alert(1,"[3][Grape:|Der Systemzeichensatz ist zu groû!][Abbruch]");
		exit(0);
	}

	ocoled[GCECMY].ob_state |= SELECTED;
	strcpy(ocoled[CCOLVAL].ob_spec.tedinfo->te_ptext, "0");
	strcpy(ocoled[MCOLVAL].ob_spec.tedinfo->te_ptext, "0");
	strcpy(ocoled[YCOLVAL].ob_spec.tedinfo->te_ptext, "0");

	ospecial[SDRAW].ob_state |= SELECTED;
	ospecial[SOTOL].ob_flags |= HIDETREE;
	ospecial[SOZOOM].ob_flags |= HIDETREE;
	strcpy(ospecial[SOFAK].ob_spec.tedinfo->te_ptext, "3");
	/* Toleranz-FÑhigkeiten */
	for(a=0; a <8; ++a)
		tool_tol[a][0]=tool_tol[a][1]=tool_tol[a][2]=0;
		
	strcpy(ospecial[STOLNUM].ob_spec.tedinfo->te_ptext, "---");
	ospecial[STOLS].ob_y=ospecial[STOLB].ob_height-ospecial[STOLS].ob_height;
	ospecial[STOLLED].ob_spec.bitblk->bi_color=11; /* 11= dunkelgrÅn */

	ostampopt[SOLAS].ob_state |= SELECTED;
	ostampopt[SONWHITE].ob_state &= (~SELECTED);
	ostampopt[SOWWHITE].ob_state &= (~SELECTED);
	
	/* Speicher fÅr Userdef's */
	usdef_mem(otool, GPPCOL);
	usdef_mem(ocoled, GCECOL);
	usdef_mem(ocoldd, COLDDOB);
	usdef_mem(osize, NSPREVIEW);
	usdef_mem(ospecial, STOLC);
	usdef_mem(oprint, PRPREVIEW);
	usdef_mem(ostampopt, SOVDATA);
	usdef_mem(ostampopt, SOVMASK);
	/* Farbpalette: Erstes Objekt separat */
	usdef_mem(ocolpal, COL1);
	for(a=1; a < 260; ++a)
	{ /* und bei allen anderen den Offsettable sparen */
		w=((U_OB*)(ocolpal[COL1+a]_UP_))->color.w=((ocolpal[COL1].ob_width/16)+1)*16;
		((U_OB*)(ocolpal[COL1+a]_UP_))->color.r=(unsigned char*)malloc(w*ocolpal[COL1].ob_height);
		((U_OB*)(ocolpal[COL1+a]_UP_))->color.g=(unsigned char*)malloc(w*ocolpal[COL1].ob_height);
		((U_OB*)(ocolpal[COL1+a]_UP_))->color.b=(unsigned char*)malloc(w*ocolpal[COL1].ob_height);
		memtest(((U_OB*)(ocolpal[COL1+a]_UP_))->color.r);
		memtest(((U_OB*)(ocolpal[COL1+a]_UP_))->color.g);
		memtest(((U_OB*)(ocolpal[COL1+a]_UP_))->color.b);
		
		((U_OB*)(ocolpal[COL1+a]_UP_))->color.table_offset=
			((U_OB*)(ocolpal[COL1]_UP_))->color.table_offset;
	}

	onewlay[NLNAME].ob_spec.tedinfo->te_ptext[0]=0;
	onewmask[NMNAME].ob_spec.tedinfo->te_ptext[0]=0;
	onewlay[NLTYP2].ob_state |= SELECTED;
	strcpy(onewmask[NMCOL2].ob_spec.tedinfo->te_ptext, " Schwarz");
	onewmask[NMCOL1].ob_spec.obspec.interiorcol=1;

	opmode[PM1].ob_state &= (~SELECTED);	
	opmode[PM2].ob_state|=SELECTED;
	opmode[PM3].ob_state &= (~SELECTED);	

	oexport[EXALL].ob_state |=SELECTED;
	oexport[EXVISSEL].ob_state &=(~SELECTED);
	oexport[EXEDSEL].ob_state &=(~SELECTED);

	omodopt[MOPT1].ob_state|=SELECTED;
	omodopt[MOPT2].ob_state &= (~SELECTED);	

	omodopt[POPT1].ob_state &= (~SELECTED);	
	omodopt[POPT2].ob_state|=SELECTED;
	omodopt[POPT3].ob_state &= (~SELECTED);	
	
	for(a=FXTX1; a<=FXTXL; ++a)
		ofexport[a].ob_width=ofexport[FXTXFRAME].ob_width-ofexport[FXBAR].ob_width-3;
		
	ofxsave[FXS1].ob_state |= SELECTED;
	ofxsave[FXS2].ob_state &= (~SELECTED);
	
	menu_to_fzooms();

	strcpy(otoolbar[TBZOOM].ob_spec.tedinfo->te_ptext, "1:1");
	
	start_text("Interface...");

	dundorec.tree=oundo;
	dundorec.support=0;
	dundorec.dservice=dial_undo;
	dundorec.osmax=0;
	dundorec.odmax=8;
	dpened.tree=opened;
	dpened.support=0;
	dpened.dservice=dial_pened;
	dpened.osmax=0;
	dpened.odmax=8;
	dpledit.tree=opledit;
	dpledit.support=0;
	dpledit.dservice=dial_pledit;
	dpledit.osmax=0;
	dpledit.odmax=8;
	dtool.tree=otool;
	dtool.support=0;
	dtool.dservice=dial_tool;
	dtool.osmax=0;
	dtool.odmax=8;
	dcoled.tree=ocoled;
	dcoled.support=0;
	dcoled.dservice=dial_coled;
	dcoled.osmax=0;
	dcoled.odmax=8;
	dpens.tree=opens;
	dpens.support=0;
	dpens.dservice=dial_pens;
	dpens.osmax=0;
	dpens.odmax=8;
	dnewlay.tree=onewlay;
	dnewlay.support=0;
	dnewlay.dservice=dial_newlay;
	dnewlay.osmax=0;
	dnewlay.odmax=8;
	dnewmask.tree=onewmask;
	dnewmask.support=0;
	dnewmask.dservice=dial_newmask;
	dnewmask.osmax=0;
	dnewmask.odmax=8;
	dcopylay.tree=ocopylay;
	dcopylay.support=0;
	dcopylay.dservice=dial_copylay;
	dcopylay.osmax=0;
	dcopylay.odmax=8;
	dnew.tree=onew;
	dnew.support=0;
	dnew.dservice=dial_new;
	dnew.osmax=0;
	dnew.odmax=8;
	dsize.tree=osize;
	dsize.support=0;
	dsize.dservice=dial_size;
	dsize.osmax=0;
	dsize.odmax=8;
	dspecial.tree=ospecial;
	dspecial.support=0;
	dspecial.dservice=dial_special;
	dspecial.osmax=0;
	dspecial.odmax=8;
	dcolpal.tree=ocolpal;
	dcolpal.support=0;
	dcolpal.dservice=dial_colpal;
	dcolpal.osmax=0;
	dcolpal.odmax=8;
	dpmode.tree=opmode;
	dpmode.support=0;
	dpmode.dservice=dial_pmode;
	dpmode.osmax=0;
	dpmode.odmax=8;
	dinfo.tree=ostartup;
	dinfo.support=0;
	dinfo.dservice=dial_info;
	dinfo.osmax=0;
	dinfo.odmax=8;
	dunopt.tree=ounopt;
	dunopt.support=0;
	dunopt.dservice=dial_unopt;
	dunopt.osmax=0;
	dunopt.odmax=8;
	daopt.tree=oaopt;
	daopt.support=0;
	daopt.dservice=dial_aopt;
	daopt.osmax=0;
	daopt.odmax=8;
	dmodule.tree=omodule;
	dmodule.support=0;
	dmodule.dservice=dial_module;
	dmodule.osmax=0;
	dmodule.odmax=8;
	dpreview.tree=opreview;
	dpreview.support=0;
	dpreview.dservice=dial_preview;
	dpreview.osmax=0;
	dpreview.odmax=8;
	dclear.tree=oclear;
	dclear.support=0;
	dclear.dservice=dial_clear;
	dclear.osmax=0;
	dclear.odmax=8;
	dprint.tree=oprint;
	dprint.support=0;
	dprint.dservice=dial_print;
	dprint.osmax=0;
	dprint.odmax=8;
	dzoom.tree=ozoom;
	dzoom.support=0;
	dzoom.dservice=dial_zoom;
	dzoom.osmax=0;
	dzoom.odmax=8;
	dfzooms.tree=ofzooms;
	dfzooms.support=0;
	dfzooms.dservice=dial_fzooms;
	dfzooms.osmax=0;
	dfzooms.odmax=8;
	dexport.tree=oexport;
	dexport.support=0;
	dexport.dservice=dial_export;
	dexport.osmax=0;
	dexport.odmax=8;
	dfexport.tree=ofexport;
	dfexport.support=0;
	dfexport.dservice=dial_fexport;
	dfexport.osmax=0;
	dfexport.odmax=8;
	dfxsave.tree=ofxsave;
	dfxsave.support=0;
	dfxsave.dservice=dial_fxsave;
	dfxsave.osmax=0;
	dfxsave.odmax=8;
	dmodopt.tree=omodopt;		
	dmodopt.support=0;
	dmodopt.dservice=dial_modopt;
	dmodopt.osmax=0;
	dmodopt.odmax=8;
	dstampopt.tree=ostampopt;		
	dstampopt.support=0;
	dstampopt.dservice=dial_stampopt;
	dstampopt.osmax=0;
	dstampopt.odmax=8;
	
	otool[GPLGROB].ob_state|=SELECTED;
	otool[GPOPAQUE].ob_state|=SELECTED;
	otool[GPLED].ob_spec.bitblk->bi_color=11; /* 3= hell */
	otool[GPFSS].ob_x=0;
	opened[GPRND].ob_state|=SELECTED;
	oundo[UALL].ob_state|=SELECTED;
	oundo[UON].ob_state|=SELECTED;
	oundo[ULED].ob_spec.bitblk->bi_color=3; /* 3=HellgrÅn, 11=DunkelgrÅn */
	oundo[URLED].ob_spec.bitblk->bi_color=6; /* 6=Hellgelb, 14=Dunkelgelb */
	 /* auûerdem :2=Hellrot, 10=Dunkelrot */
	undo_start=NULL;
	
	w_dinit(&wundorec);
	w_dinit(&wpened);
	w_dinit(&wpledit);
	w_dinit(&wtool);
	w_dinit(&wcoled);
	w_dinit(&wpens);
	w_dinit(&wnewlay);
	w_dinit(&wcopylay);
	w_dinit(&wnew);
	w_dinit(&wsize);
	w_dinit(&wspecial);
	w_dinit(&wnewmask);
	w_dinit(&wcolpal);
	w_dinit(&wpmode);
	w_dinit(&winfo);
	w_dinit(&wunopt);
	w_dinit(&waopt);
	w_dinit(&wmodule);
	w_dinit(&wpreview);
	w_dinit(&wclear);
	w_dinit(&wprint);
	w_dinit(&wzoom);
	w_dinit(&wfzooms);
	w_dinit(&wexport);
	w_dinit(&wfexport);
	w_dinit(&wfxsave);
	w_dinit(&wmodopt);
	w_dinit(&wstampopt);
	
	wind_calc(WC_BORDER, MOVE|CLOSE|UPARROW|DNARROW|VSLIDE,10,10,opens[0].ob_width, 10, &dum, &dum, &w, &dum);

	xrsrc_gaddr(0,DIRECTMOD, &odummod, xrsrc);
	odummod[0].ob_width=w;
	odummod[DUMNAME].ob_width=w;
	
	ospecial[0].ob_width=w;
	ospecial[SOPEN].ob_width=ospecial[SOTOL].ob_width=ospecial[SOZOOM].ob_width=
	ostampopt[0].ob_width=ospecial[0].ob_width-ospecial[SOPEN].ob_y;
	ospecial[SOTOL].ob_x=ospecial[SOZOOM].ob_x=ospecial[SOPEN].ob_x;
	wspecial.dinfo=&dspecial;
	w_kdial(&wspecial, D_CENTER, MOVE|NAME|BACKDROP|CLOSE);
	wspecial.closed=closed;
	wspecial.name="[Grape] Werkzeug";
	w_set(&wspecial, NAME);
	dspecial.dedit=SOFAK;
	wspecial.wx=sx+10; wspecial.wy=sy+20;

	wpledit.dinfo=&dpledit;
	w_kdial(&wpledit, D_CENTER, MOVE|NAME|BACKDROP|CLOSE);
	wpledit.closed=closed;
	wpledit.name="[Grape] Polynom-Editor";
	w_set(&wpledit, NAME);
	
	wtool.dinfo=&dtool;
	w_kdial(&wtool, D_CENTER, MOVE|NAME|BACKDROP|CLOSE);
	wtool.closed=closed;
	wtool.name="[Grape] Stift-Parameter";
	w_set(&wtool, NAME);
	wtool.wx=wspecial.wx+wspecial.ww+8; wtool.wy=sy+20;
	
	wcoled.dinfo=&dcoled;
	w_kdial(&wcoled, D_CENTER, MOVE|NAME|BACKDROP|CLOSE);
	wcoled.closed=closed;
	wcoled.name="[Grape] Farb-Editor";
	w_set(&wcoled, NAME);
	wcoled.wx=wtool.wx+wtool.ww+8; wcoled.wy=sy+20;
		
	wundorec.dinfo=&dundorec;
	w_kdial(&wundorec, D_CENTER, MOVE|NAME|BACKDROP|CLOSE);
	wundorec.closed=closed;
	wundorec.name="[Grape] Undo-Recorder";
	w_set(&wundorec, NAME);
	
	wpens.dinfo=&dpens;
	w_kdial(&wpens, D_CENTER, MOVE|NAME|BACKDROP|CLOSE|UPARROW|DNARROW|VSLIDE|SIZE);
	wpens.closed=closed;
	wpens.arrowed=pens_arrowed;
	wpens.vslid=pens_vslid;
	wpens.sized=pens_sized;
	wpens.name="[Grape] Stifte";
	wpens.vpos=1; wpens.vsiz=1000;
	w_set(&wpens, NAME|VSLIDE);
	wpens.wx=sx+10; wpens.wy=wtool.wy+wtool.wh+8;
	wind_calc(WC_BORDER, wpens.kind,10,10,opens[0].ob_width, opens[GPSHEAD].ob_height+opens[GPS1].ob_height, &dum, &dum, &dum, &wpens.wh);

	wpened.dinfo=&dpened;
	w_kdial(&wpened, D_CENTER, MOVE|NAME|BACKDROP|CLOSE);
	wpened.closed=closed;
	dpened.dedit=GPNAME;
	wpened.name="[Grape] Werkzeug-Editor";
	w_set(&wpened, NAME);
	wpened.wx=sx+wpens.ww+10; wpened.wy=wtool.wy+wtool.wh+8;

	wcolpal.dinfo=&dcolpal;
	w_kdial(&wcolpal, D_CENTER, MOVE|NAME|BACKDROP|CLOSE|UPARROW|DNARROW|VSLIDE|SIZE);
	wcolpal.closed=closed;
	wcolpal.arrowed=colpal_arrowed;
	wcolpal.vslid=colpal_vslid;
	wcolpal.sized=colpal_sized;
	wcolpal.vpos=1; wcolpal.vsiz=1000;
	wcolpal.name="[Grape] Palette";
	w_set(&wcolpal, NAME|VSLIDE);
	wcolpal.wx=sx+10; wcolpal.wy=wpens.wy+wpens.wh+8;
	wind_calc(WC_BORDER, wcolpal.kind,10,10,10, ocolpal[GCPHEAD].ob_height+ocolpal[COL1].ob_height*26, &dum, &dum, &dum, &wcolpal.wh);
	

	artpad=find_cookie('asGT', (long*)&asgc);
	if(!artpad)
	{
		oaopt[OAPRESS].ob_state &= (~SELECTED);
		asgc=&default_tablet;
	}


	for(l=0; l < 2000; ++l)
		screen_offset[l]=(long)((long)l*(long)roff);

	start_text("Dithermatrix...");

	fill_table();

	start_text("Paletten...");
	
	fill_col_pal();

	start_text("Werkzeug...");

	for(a=0; a < 256; ++a)
		pen.tip[a]=NULL;
		
	/* Default-Pen */
	
	pgp.form=1;
	pgp.d_type=0;

	pgp.plp.x1=0; pgp.plp.x3=255; pgp.plp.y1=0; pgp.plp.y3=16;
	pgp.plp.x2=128; pgp.plp.y2=128;
	pgp.plp.curve_type=2;
	ple=pgp.plp;
	curve_to_free();
	pgp.plp=ple;
	pgp.plr=pgp.plp;
	pgp.plr.y3=255;
	ple=pgp.plr;
	curve_to_free();
	pgp.plr=pgp.plg=pgp.plb=ple;
	
	pgp.verlust=0;
	pgp.wischen=0;
	pgp.randhell=0;
	pgp.rauschen=0;
	pgp.rs_bunt=0;

	pgp.q_opt=0;
	
	pgp.col_ok=1;
	pgp.las_ok=1;
	pgp.col.red=255;
	pgp.col.yellow=255;
	pgp.col.blue=255;
	pgp.col.lasur=0;

	pgp.line=1;
	pgp.step=2;
	pgp.f_speed=0;

	pgp.kbs=-1;
	pgp.kcode=-1;
	
	pgp.oicon=0;
	pgp.om1=pgp.om2=0;
	pgp.okbs=0;

	strcpy(pgp.keyname, "NON");
	strcpy(pgp.name,"Default");
	pen.source_lay_id=-1;
	make_pen(&pgp);

	/* Default-Pen-Parameter */
	pens_obs.off=0;
	pens_obs.sel=-1;
	pens_obs.len=1;
	pens_obs.last=GPSK;
	
	default_pen=pgp;

	default_pen.col_ok=0;
	default_pen.las_ok=0;
	default_pen.line=-1;
	default_pen.step=-1;
	default_pen.f_speed=-1;

	first_pen.prev=NULL;
	first_pen.this=default_pen;
	first_pen.next=NULL;
	/* Objekt belegen */
	/* Icon */
	opens[GPS1].ob_spec.iconblk=oicons[default_pen.oicon+ICON_1].ob_spec.iconblk;
	/* Merker */
	opens[GPSM1].ob_spec.bitblk=omerk[default_pen.om1+MERK_1].ob_spec.bitblk;
	opens[GPSM2].ob_spec.bitblk=omerk[default_pen.om2+MERK_1].ob_spec.bitblk;
	/* Name */
	strcpy(opens[GPSN].ob_spec.tedinfo->te_ptext, default_pen.name);
	/* Taste */
	strcpy(opens[GPSK].ob_spec.tedinfo->te_ptext, default_pen.keyname);
	/* Umschalttasten */
	if(default_pen.okbs)
		opens[GPSA-1+default_pen.okbs].ob_state |= SELECTED;
	

	start_text("Diverses...");

	fill_col_ob();
	fill_ed_col_ob(0,0,0);
	fill_usr_col_ob(ospecial, STOLC, 0, 0, 0);
	
	ple.x1=0; ple.x2=128; ple.x3=255;
	ple.y1=0; ple.y2=128; ple.y3=255;
	ple.curve_type=3;
	for(ox=0; ox < 512; ++ox)
		ple.y[ox]=-1;
	ple.y[0]=0; ple.y[opledit[GEGRAPH].ob_width-1]=0;
	
	init_undo();
	if(undo_ok)
		undo_on=1;

	no_dither=0;
	
	start_text("Module...");
	init_grape_mod_info();
	scan_modules();
	scan_fio_modules();
	
	form_dial(FMD_FINISH, dx, dy, dw, dh, dx, dy, dw, dh);
	graf_mouse(ARROW, NULL);
	wind_update(END_MCTRL);
	wind_update(END_UPDATE);

	ostartup[STINIT].ob_flags|=HIDETREE;
	ostartup[ST_TEXT].ob_flags|=HIDETREE;
	ostartup[STOK].ob_flags&=(~HIDETREE);
		
	menu_bar(mmenu, 1);
	event_loop();

	/* VDI-Farben zurÅcksetzen */
	for(a=0; a < 256; ++a)
		vs_color(handle, a, vdirgb[a]);
	
	if(main_win.id > -1)
	{
		free_undo();
		clear_undo();
		while(first_lay)
		{
			free(first_lay->this.blue);
			free(first_lay->this.yellow);
			free(first_lay->this.red);
			free(&(first_lay->this));
			first_lay=first_lay->next;
		}
		wind_close(main_win.id);
		wind_delete(main_win.id);
	}
	w_kill(&wundorec);
	w_kill(&wpledit);
	
	menu_bar(mmenu, 0);
	xrsrc_free(xrsrc);
}

void init_grape_mod_info()
{ /* Den Grape-Info-Block ausfÅllen */
	grape_mod_info.undo_buf=undo_buf;
	grape_mod_info.resize=((int cdecl(*)(int w, int h))0);
	grape_mod_info.do_me=do_module;
	grape_mod_info.update_preview=update_preview;
	
	grape_mod_info.d_unsel=d_unsel;
	grape_mod_info.d_objc_draw=d_objc_draw;
	
	grape_mod_info.mod_quit=term_module;

	grape_mod_info.slide=modslide;
	grape_mod_info.bar=modbar;
	grape_mod_info.set_slide=mod_set_slide;
	grape_mod_info.get_prev_opt=mod_get_prev_opt;
	grape_mod_info.set_pal_col=set_pal_col;
	grape_mod_info.set_pal_cols=set_pal_cols;
	grape_mod_info.get_pal_col=get_pal_col;
	grape_mod_info.get_pal_cols=get_pal_cols;

	grape_mod_info.set_col_pal=fio_set_pal;
	
	module_id=0;
	prev_func=NULL;
	
	grape_fiomod_info.set_col_pal=fio_set_pal;
	grape_fiomod_info.get_col_pal=fio_get_pal;
	grape_fiomod_info.store_block=fio_store_block;
	grape_fiomod_info.get_block=fio_get_block;
	
	grape_fiomod_info.form_alert=fio_form_alert;
	grape_fiomod_info.malloc=fio_malloc;
	grape_fiomod_info.calloc=fio_calloc;
	grape_fiomod_info.realloc=fio_realloc;
	grape_fiomod_info.free=fio_free;
	
	expf_id=0;
}

void start_text(char *text)
{
	if(strlen(text) > 17)
		text[17]=0;
	strcpy(ostartup[ST_TEXT].ob_spec.tedinfo->te_ptext, text);
	objc_draw(ostartup, ST_TEXT, 8, sx, sy, sw, sh);
}

int test_resolution(int planes)
{ /* PrÅft ob Treiber fÅr den Screen vorhanden sind */
	/* RÅckgabe: 1=Ja, 0=Nein */

	int a, ret=0;
	unsigned char pls[64], pld[64];
	MFDB src, dst;
	
	src.fd_addr=pls;
	src.fd_w=16;
	src.fd_h=1;
	src.fd_wdwidth=1;
	src.fd_stand=0;
	src.fd_nplanes=planes;
	
	dst.fd_addr=pld;
	dst.fd_w=16;
	dst.fd_h=1;
	dst.fd_wdwidth=1;
	dst.fd_stand=1;
	dst.fd_nplanes=planes;
	
	if(planes == 8)
	{
		for(a=0; a < 8; ++a) pls[a]=1;
		for(a=8; a < 64; ++a) pls[a]=0;
		
		vr_trnfm(handle, &src, &dst);

		if(pld[0]==255) ret=1;
	}
	
	return(ret);
}

void	fix_icontext(void)
{
	int	a, tree_num;
	OBJECT	*tree;
	
	tree_num=(*(RSHDR**)(&_GemParBlk.global[7]))->rsh_ntree;

	for(a=0; a < tree_num; ++a)
	{
		xrsrc_gaddr(0,a,&tree, xrsrc);
		fix_ob(tree);
	}
}

void fix_ob(OBJECT *tree)
{
#define NO_TEXT 0x800
	int 	ob=0;
	long	opar;
	
	do
	{
		/* Standard-Objekte finden */
		
		if( ((tree[ob].ob_type & 255) == G_CICON) &&
				(tree[ob].ob_state & NO_TEXT))
			((CICONBLK*)(tree[ob].ob_spec.iconblk))->monoblk.ib_wtext=0;
		else if((tree[ob].ob_type & 255) == G_USERDEF)
		{
			tree[ob].ob_spec.userblk->ub_code=user_ob;
			opar=tree[ob]_UP_;
			tree[ob]_UP_=(long)malloc(sizeof(U_OB));
			memtest((void*)tree[ob]_UP_);
			((U_OB*)(tree[ob]_UP_))->type=(int)opar;
		}
		
	}while(!(tree[ob++].ob_flags & LASTOB));
}

void set_grey_pal(void)
{
	int e[3], a;

	/* VDI-Farben auf Graustufen setzen */
	/* FÅr énderung der Anzahl auch GREYDITH.S anpassen! */
	/* Fast 256 Graustufen (0-15 sind gleich)*/
/*	for(a=16; a < 256; ++a)
	{
		e[0]=e[1]=e[2]=1020-a*4;
		vs_color(handle, a, e);
	}*/

	/* 128 Graustufen */
	for(a=0; a < 128; ++a)
	{
		e[0]=e[1]=e[2]=1016-a*8;
		vs_color(handle, a+16, e);
	}

}

void set_vdi_colors(void)
{
	int e[3], r, g, b;

	/* VDI-Farben setzen */
	for(r=5; r > -1; --r)
	{
		for(g=5; g > -1; --g)
		{
			for(b=5; b > -1; --b)
			{
				e[0]=1000-b*200;
				e[1]=1000-r*200;
				e[2]=1000-g*200;
				vs_color(handle, 36*r+6*g+b+16, e);
			}
		}
	}
	vs_color(handle, 248, rgb248);
}


void fill_colpal_ob(int ob, int re, int ye, int bl)
{
	int a, b;

	b=((U_OB*)(ocolpal[ob]_UP_))->color.w*ocolpal[COL1].ob_height;
	
	for(a=0; a < b; ++a)
	{
		((U_OB*)(ocolpal[ob]_UP_))->color.r[a]=re;
		((U_OB*)(ocolpal[ob]_UP_))->color.g[a]=ye;
		((U_OB*)(ocolpal[ob]_UP_))->color.b[a]=bl;
	}
}

void fill_col_pal(void)
{
	/* Standardfarben in Farbpalette schreiben */
	
	int a, b, c, i1, i2;
	

	for(a=0; a < 5; ++a)
		for(b=0; b < 5; ++b)
			for(c=0; c < 5; ++c)
			{
				if((a==1) || (a==3))
				{
					i1=a*50+(4-b)*10+c;
					i2=i1+5;
				}
				else
				{
					i1=a*50+b*10+c;
					i2=i1+5;
				}
				fill_colpal_ob(i1+COL1, b*51, c*51, a*51);
				fill_colpal_ob(i2+COL1, b*63+3, (4-c)*63+3, a*63+3);
			}
	/* Graustufenpalette erzeugen */
/*	for(a=0; a < 250; ++a)
		fill_colpal_ob(COL1+a, a, a, a);*/

	/* Graustufen in letzte Zeile */
	for(a=0; a < 10; ++a)
		fill_colpal_ob(250+a+COL1, a*28, a*28, a*28);
		
}

void fill_table(void)
{
	int c, d, r, g;
	unsigned int m,n;
	long l;
	
	/* Erzeugt Dither-Tabellen und Mul/Div-Tabellen */
	
	/* 24->8Bit Table erzeugen */
	/*	n=16+(color.red/51)*36+(color.yellow/51)*6+color.blue/51;*/
	for(r=0; r < 256; ++r)
	{
		r_table[r]=(r/51)*36;
		g_table[r]=(r/51)*6;
		b_table[r]=(r/51);
	}
	
	/* Dither-Table erzeugen */
	make_fifdith();

	for(c=0; c < 256; ++c)
	{
		d=c+51;
		if(d > 255)
			d=255;
		r_dither[c].prev=r_table[c];
		r_dither[c].next=r_table[d];
		g_dither[c].prev=g_table[c];
		g_dither[c].next=g_table[d];
		b_dither[c].prev=b_table[c];
		b_dither[c].next=b_table[d];
	}
	
	/* Auf Byte-Tabellen Åbertragen */
	for(c=0; c < 256; ++c)
	{
		for (d=0; d < 8 ; ++d)
		{
			g=128;
			for(r=0; r < 8; ++r)
			{
				rr_dither[c].field[d*8+r]=(r_dither[c].field[d] & g) ? r_dither[c].next : r_dither[c].prev;
				gg_dither[c].field[d*8+r]=(g_dither[c].field[d] & g) ? g_dither[c].next : g_dither[c].prev;
				bb_dither[c].field[d*8+r]=(b_dither[c].field[d] & g) ? b_dither[c].next : b_dither[c].prev;
				g/=2;
			}
		}
	}
	
	/* Zeiger ablegen */
	for(c=0; c < 256; ++c)
	{
		r_dither_table[c]=&rr_dither[c];
		g_dither_table[c]=&gg_dither[c];
		b_dither_table[c]=&bb_dither[c];
	}
	
	/* IntensitÑts-Tabelle erzeugen */
	for(c=0; c < 256; ++c) /* IntensitÑt */
	{
		for (d=0; d < 256; ++d) /* Farbwert */
		{
			intensity[(long)((long)d*(long)256+(long)c)]=(unsigned char)((long)(((long)d*(long)c)/(long)255));
		}
	}

	/* Multiplikationstabelle erzeugen */
	for(m=0; m < 256; ++m)
	{
		for(n=0; n < 256; ++n)
			mul_tab[(long)((long)m*(long)256+(long)n)]=m*n;
	}
	
	/* Divisionstabelle erzeugen */
	for(l=0; l < 131072l; ++l)
		div_tab[l]=(unsigned char)((long)((long)l/(long)255));
		

	/* Adress-Offset fÅr Mul-Tabelle erzeugen */
	for(l=0; l < 256l; ++l)
		mul_adr[l]=(unsigned int*) ((long)((255-l)*512+(long)&mul_tab[0]));
		
	/* Mul-Tabellen fÅr Grey-Dither erzeugen */
	for(m=0; m < 256; ++m)
	{
		r_mul_table[m]=m*151;
		g_mul_table[m]=m*28;
		b_mul_table[m]=m*77;
	}
}



/* Event-Schleife */

void set_mouse(void)
{
	int	mx, my, id, wx, wy, ww, wh;

	if(main_win.id > -1)
	{
		graf_mkstate(&mx, &my, &id, &id);
		id=wind_find(mx, my);
		if(id == main_win.id)
		{
			wind_get(main_win.id, WF_WORKXYWH, &wx, &wy, &ww, &wh);
			wy+=otoolbar[0].ob_height+OTBB; wh-=otoolbar[0].ob_height+OTBB;
			if(ww > first_lay->this.width/DZOP-main_win.ox)
				ww=first_lay->this.width/DZOP-main_win.ox;
			if(wh > first_lay->this.height/DZOP-main_win.oy)
				wh=first_lay->this.height/DZOP-main_win.oy;
			if((mx >= wx) && (mx < wx+ww) && (my > wy) && (my < wy+wh))
			{
				wind_get(0, WF_TOP, &id, NULL, NULL, NULL);
				if(id==main_win.id)
				{
					/* Arbeitsbereich->Mausform zeichnen */
					if(last_form != sel_tool)
					{
						switch(sel_tool)
						{
							case SDRAW:
								graf_mouse(USER_DEF, UD_STIFT);
							break;
							case SSELECT:
								graf_mouse(THIN_CROSS, NULL);
							break;
							case SFILL:
								graf_mouse(USER_DEF, UD_FILL);
							break;
							case SSTICK:
								graf_mouse(USER_DEF, UD_STICK);
							break;
							case SSTAMP:
								graf_mouse(USER_DEF, UD_STEMPEL);
							break;
							case SZOOM:
								graf_mouse(USER_DEF, UD_ZOOM_IN);
							break;
						}
						last_form=sel_tool;
					}
					return;
				}
			}
		}
	}
	/* Nicht im Arbeitsbereich->ggf. Arrow zeichnen */
	if(last_form!=ARROW)
	{
		graf_mouse(ARROW, NULL);
		last_form=ARROW;;
	}
}

void event_loop(void)
{
	int	evnt, o, p, x, y, dum, win, but, swt, kbs, klicks, tc=0, wx, wy, res;
	unsigned int	scan;
	
	do
	{
	
		res=w_ddtevent(&evnt, &x, &y, &but, &swt, &kbs, &klicks, 100, 0);
  	if(evnt & MU_MESAG) switch(pbuf[0]) 
    { 
    	case WM_SIZED:
    		if(pbuf[3] == main_win.id)
    			new_wsize(pbuf);
    	break;
    	case WM_FULLED:
    		if(pbuf[3] == main_win.id)
    			full_wsize(main_win.id);
    	break;
    	case WM_HSLID:
    		if(pbuf[3] == main_win.id)
    			new_wslidx(pbuf[4]);
    	break;
    	case WM_VSLID:
    		if(pbuf[3] == main_win.id)
    			new_wslidy(pbuf[4]);
    	break;
    	case WM_ARROWED:
    		if(pbuf[3] == main_win.id)
    			new_warrow(pbuf);
    	break;
     
      case WM_CLOSED: 
        if(pbuf[3] == main_win.id) 
        { 
        	close_main_win();
        } 
      break; 
     
      case WM_MOVED: 
      	if(pbuf[4] < 0) pbuf[4]=0;
        wind_set(pbuf[3], WF_CURRXYWH, pbuf[4], pbuf[5], pbuf[6], pbuf[7]); 
        if(pbuf[3] == main_win.id)
        {/* Toolbar-Koordinaten anpassen */
        	wind_get(pbuf[3], WF_WORKXYWH, &x, &y, &dum, &dum);
        	otoolbar[0].ob_x=x; otoolbar[0].ob_y=y;
        }
      break; 
     
      case WM_TOPPED: 
      	if(pbuf[3]==main_win.id)
      	{
      		if(col_or_grey==0)
        		set_vdi_colors();
        	else
        		set_grey_pal();
      	}
        wind_set(pbuf[3], WF_TOP,0,0,0,0); 
      break; 
 
      case WM_REDRAW: 
       	if(pbuf[3]==main_win.id)
	        pic_redraw(pbuf[3], pbuf[4], pbuf[5], pbuf[6], pbuf[7]); 
      break; 
    }
		if(evnt & MU_TIMER)
		{
			++tc;
			if(tc==10)
			{
				if(painted_mask != NULL)
				{
					mask_changed(painted_mask);
					painted_mask=NULL;
				}
				if(painted_lay != NULL)
				{
					layer_changed(painted_lay);
					painted_lay=NULL;
				}
				tc=0;
			}
			set_mouse();
		}

		if(!res)
		{
			if(evnt & MU_KEYBD)
			{
				scan=kbs;
				scan=scan>>8;
				if(menu_key(mmenu, scan, swt, &x, &y))
				{
					menu_tnormal(mmenu, x, 0);
					do_menu(x, y);
				}
				else if(menu_key(keycmds, scan, swt, &x, &y))
					do_key_cmd(x, y);
			}
			if(evnt & MU_BUTTON)
			{
				win=wind_find(x, y);
				if(win == main_win.id)
				{
					if((y < otoolbar[0].ob_y+otoolbar[0].ob_height+OTBB) && (but & 1))
					{
						o=objc_find(otoolbar, 0, 8, x, y);
						if (o > 0)
						{/* Nur falls nicht in Object 0 geklickt */
							p=form_button(otoolbar, o, 1, &dum);
							if (!p)
								dial_layer(o, klicks);
						}
					}
					else /* Ins Hauptfenster geklickt */
					{/* Mausposition im Bildbereich? */
						wind_get(main_win.id, WF_WORKXYWH, &wx, &wy, &dum, &dum);
						wy+=otoolbar[0].ob_height+OTBB;
						if( (x <= first_lay->this.width/DZOP+wx-main_win.ox) &&
								(y <= first_lay->this.height/DZOP+wy-main_win.oy))
						{
							if(but & 1)
								work_on(main_win.id);
							else
								right_on(main_win.id);
						}
					}
				}
				else my_klick_dispatch(x, y, but, klicks, swt);
			}
		}
	}while(!quit);
}

void	my_klick_dispatch(int x, int y, int but, int klicks, int swt)
{/* PrÅft Doppel-Linksklick und Rechtsklick auf
    Fenstern auûer Main-Win */
  
  int				wid, ob, dif,elm, ox, oy, ix;
  WINDOW		*win;
	OBJECT		*tree;
	CMY_COLOR	col;
	
  wid=wind_find(x, y);
  win=w_find(wid);
  if(!win)
    return;
  /* Fenster von mir verwaltet */
 	if(!win->dialog)
 		return;
 	/* Ist Dialog_Fenster */
 	ob=objc_find(win->dinfo->tree, 0, 8, x, y);
 	if(ob < 1)
 		return;
 	/* öber Root-Objekt getroffen */
 	tree=win->dinfo->tree;
 	if(tree[ob].ob_state & DISABLED)
 		return;
 	if(tree == opens)
 	{ /* Stiftpalette getroffen */
 		if((but & 1) && (klicks > 1))
 		{/* Linker Doppelklick -> Editor aufrufen */
		 	dif=GPS2-GPS1;
			if((ob >= GPS1) && (ob <= pens_obs.last))
			{/* Klick in Liste */
				elm=(ob-GPS1)/(dif); /* Listenelement */
				pgp=*find_pen(elm+pens_obs.off);
				init_pened();
				if(wpened.open)
				{
					w_top(&wpened);
					s_redraw(&wpened);
				}
				else
					w_open(&wpened);
			}				
		}
 	}
 	if((tree[ob].ob_type & 255) != G_USERDEF)
 		return;
 	/* Userdef getroffen */
 	if( (((U_OB*)(tree[ob]_UP_))->type != 3) &&
	 		(((U_OB*)(tree[ob]_UP_))->type != 4) )
 		return;
 	/* Farbfeld getroffen */
 	/* Offset berechnen */
 	objc_offset(tree, ob, &ox, &oy);
 	/* Koordinaten im Farbfeld berechnen */
 	ox=x-ox; oy=y-oy;
 	/* Rahmen getroffen ? */
 	if((ox < 2) || (oy < 2))
 		return;
 	if((ox > tree[ob].ob_width-2) || (oy > tree[ob].ob_height-2))
 		return;
 	ix=ox+oy*((U_OB*)(tree[ob]_UP_))->color.w;
 	if(but & 1)
 	{/* Linksklick */
 		if(klicks > 1)
 		{/* Farbeditor îffnen */
 			if(tree == ocoled) /* Auûer das war der Farbeditor */
 				return;
 			fetz_her(&wcoled);
 			col.red=((U_OB*)(tree[ob]_UP_))->color.r[ix];
 			col.yellow=((U_OB*)(tree[ob]_UP_))->color.g[ix];
 			col.blue=((U_OB*)(tree[ob]_UP_))->color.b[ix];
 			set_col_ed(&col);
 		}
 	}
 	else if(but & 2)
 	{/* Rechtsklick->als Stiftfarbe setzen */
		cont_get_color();
 	}
 	
}

void	do_key_cmd(int title, int ob)
{
	int a;
	
	switch(ob)
	{
		case KDRAW:
		case KSELECT:
		case KFILL:
		case KSTICK:
		case KSTAMP:
		case KZOOM:
/*
		case KSLASSO:
		case KRULER:
*/
			for(a=SDRAW; a <= SZOOM; ++a)
				ospecial[a].ob_state &= (~SELECTED);
				
			ospecial[SDRAW+ob-KDRAW].ob_state |= SELECTED;
			dial_special(SDRAW+ob-KDRAW);
			if(wspecial.open)
				s_redraw(&wspecial);
		break;

		case KPLAUS:
		case KPLGROB:
		case KPLFEIN:
			otool[GPLAUS].ob_state &= (~SELECTED);
			otool[GPLGROB].ob_state &= (~SELECTED);
			otool[GPLFEIN].ob_state &= (~SELECTED);
			otool[GPLAUS+ob-KPLAUS].ob_state |= SELECTED;
			if(wtool.open)
				w_objc_draw(&wtool, GPLAUS-1, 8, sx, sy, sw, sh);
			dial_tool(GPLAUS+ob-KPLAUS);
		break;
		
		case KPOPAQUE:
		case KPLASUR:
			otool[GPOPAQUE].ob_state &= (~SELECTED);
			otool[GPLASUR].ob_state &= (~SELECTED);
			otool[GPOPAQUE+ob-KPOPAQUE].ob_state |= SELECTED;
			if(wtool.open)
				w_objc_draw(&wtool, GPOPAQUE-1, 8, sx, sy, sw, sh);
			dial_tool(GPOPAQUE+ob-KPOPAQUE);
		break;
		
		case KTBS1:		case KTBS2:
		case KTBS3:		case KTBS4:
		case KTBS5:		case KTBS6:
		case KTBS7:		case KTBS8:
		case KTBS9:		case KTBS0:
			if(main_win.id > -1)
				dial_layer(ob-KTBS1+TBS1, 1);
		break;
		
		case KKEYCOL:
			key_col_sel();
		break;

		case KDEL:
			if(main_win.id == -1)
			{
				form_alert(1,"[3][Grape:|Es ist keine Hauptdatei geîffnet!|WÑhlen Sie \'Neu\' oder \'ôffnen\' aus|dem Datei-MenÅ.][Abbruch]");
				break;
			}
			del();
		break;
				
		case KFLOYD:
			special_redraw(1);
		break;
	}
}

/* "Rest"-Funktionen */
void check_aopt_export(void)
{
	EXP_FORM	*ep=first_expf;
	int				ix, x,y,w,h;
	
	objc_offset(oaopt, OAGEMCLIP, &x, &y);
	w=oaopt[OAGEMCLIP].ob_width;
	h=oaopt[OAGEMCLIP].ob_height;

	/* Wieviele definierte Exportformate? */
	while(ep)
	{
		if(ep->base_id) break;
		ep=ep->next;
	}
	
	if(ep==NULL)
	{
		oaopt[OAGEMCLIP].ob_state &= (~SELECTED);
		oaopt[OAGEMCLIP].ob_state |= DISABLED;
		oaopt[OAFORMPOP].ob_state |= DISABLED;
		strcpy(oaopt[OAFORMPOP].ob_spec.free_string, "nicht definiert");
		if(waopt.open)
		{
			w_objc_draw(&waopt, 0, 8, x, y, w, h);
			w_objc_draw(&waopt, OAFORMPOP, 8, sx, sy, sw, sh);
		}
		return;
	}
	
	ix=oaopt[OAFORMPOP].ob_type >> 8;
	ep=first_expf;
	while(ep && (ep->f_id != ix))
		ep=ep->next;
	if(ep==NULL)
	{
		ep=first_expf;
		while(!(ep->base_id)) ep=ep->next;
	}

	oaopt[OAFORMPOP].ob_state &= (~DISABLED);
	oaopt[OAGEMCLIP].ob_state &= (~DISABLED);
	strcpy(oaopt[OAFORMPOP].ob_spec.free_string, ep->name);
	if(waopt.open)
	{
		w_objc_draw(&waopt, 0, 8, x, y, w, h);
		w_objc_draw(&waopt, OAFORMPOP, 8, sx, sy, sw, sh);
	}
}

void	a_options(void)
{
	if(!waopt.open)
	{
		/* Dialog initialisieren */
		/* d.h. Childs von OACCP ggf disablen */
		if(!(oaopt[OACCP].ob_state & SELECTED))
			oaopt[OACCDIR].ob_state |= DISABLED;

		check_aopt_export();
		
		/* Alte Einstellung merken */
		memo_abbruch(oaopt);
		
		/* Fenster initialisieren */
		waopt.dinfo=&daopt;
		w_dial(&waopt, D_CENTER);
		waopt.name="[Grape] Allgemeine Optionen";
		w_set(&waopt, NAME);
		w_open(&waopt);
	}
	else
		w_top(&waopt);
}

void	dial_aopt(int ob)
{
	switch(ob)
	{
		case OACCP:
			if(oaopt[OACCP].ob_state & SELECTED)
				oaopt[OACCDIR].ob_state &= (~DISABLED);
			else
				oaopt[OACCDIR].ob_state |= DISABLED;
			w_objc_draw(&waopt, OACCDIR, 8, sx, sy, sw, sh);
		break;
		case OAGEMCLIP:
		break;
		case OAFORM:
			w_unsel(&waopt, ob);
			fexport_window();
		break;
		case OAFORMPOP:
			exp_form_popup(&waopt, ob);
		break;
		
		case OAABBRUCH:
			recall_abbruch(oaopt);
		case OAOK:
			w_unsel(&waopt, ob);
			w_close(&waopt);
			w_kill(&waopt);
		break;
	}
}

void set_tol_slider(CMY_COLOR *col)
{/* Wird von Color-D&D aufgerufen, falls was ins Farbfeld gedragged wurde */
	char num[32];
	int	 val=col->grey;
	
	/* Nummer setzen */
	itoa(val, num, 10);
	
	ospecial[STOLNUM].ob_spec.tedinfo->te_ptext[0]=0;
	if(val < 100)
		strcpy(ospecial[STOLNUM].ob_spec.tedinfo->te_ptext, " ");
	if(val < 10)
		strcat(ospecial[STOLNUM].ob_spec.tedinfo->te_ptext, " ");

	strcat(ospecial[STOLNUM].ob_spec.tedinfo->te_ptext, num);

	/* Farbe setzen */
	fill_usr_col_ob(ospecial, STOLC, col->blue, col->red, col->yellow);

	if(val)
		ospecial[STOLLED].ob_spec.bitblk->bi_color=3; /* 3= hell */
	else
		ospecial[STOLLED].ob_spec.bitblk->bi_color=11; /* 11= dunkel */

	ospecial[STOLS].ob_y=((255-val)*(ospecial[STOLB].ob_height-ospecial[STOLS].ob_height))/256;
	if(wspecial.open)
		w_objc_draw(&wspecial, SOTOL, 8, sx, sy, sw, sh);
}

void memo_toleranz(void)
{/* Merkt sich die aktuelle Toleranz im zugehîrigen Tool */
	int ob; 
	
	ob=ospecial[STOLNUM].ob_type >> 8;
	if(ob == 0)
		return; /* Es war noch kein Toleranztool aktiv */
	
	ob-=SDRAW;	/* tool_tol-Index beginnt bei 0 */
	tool_tol[ob][0]=((U_OB*)(ospecial[STOLC]_UP_))->color.b[0];
	tool_tol[ob][1]=((U_OB*)(ospecial[STOLC]_UP_))->color.r[0];
	tool_tol[ob][2]=((U_OB*)(ospecial[STOLC]_UP_))->color.g[0];
}

void init_toleranz(int ob)
{/* Setzt die neue Toleranz, wenn Tool zu ob gewechselt wird */
	CMY_COLOR col;
	char	num[10];

	/* Neues Toleranz-Objekt merken */
	set_ext_type(ospecial,STOLNUM,ob);
	
	col.blue=tool_tol[ob-SDRAW][0];
	col.red=tool_tol[ob-SDRAW][1];
	col.yellow=tool_tol[ob-SDRAW][2];
	set_grey(&col);

	/* Nummer setzen */
	itoa(col.grey, num, 10);
		
	/* Farbe setzen */
	fill_usr_col_ob(ospecial, STOLC, col.blue, col.red, col.yellow);
	ospecial[STOLNUM].ob_spec.tedinfo->te_ptext[0]=0;
	if(col.grey < 100)
		strcpy(ospecial[STOLNUM].ob_spec.tedinfo->te_ptext, " ");
	if(col.grey < 10)
		strcat(ospecial[STOLNUM].ob_spec.tedinfo->te_ptext, " ");

	strcat(ospecial[STOLNUM].ob_spec.tedinfo->te_ptext, num);
	if(col.grey)
		ospecial[STOLLED].ob_spec.bitblk->bi_color=3; /* 3= hell */
	else
		ospecial[STOLLED].ob_spec.bitblk->bi_color=11; /* 11= dunkel */

	ospecial[STOLS].ob_y=((255-col.grey)*(ospecial[STOLB].ob_height-ospecial[STOLS].ob_height))/256;
	
	if(wspecial.open)
		s_redraw(&wspecial);
}

void sl_toleranz(int a)
{
	char	num[10];
	a=255-a;	
	/* LED setzen */
	if(!a)
		ospecial[STOLLED].ob_spec.bitblk->bi_color=11; /* 11=dunkel */
	else
		ospecial[STOLLED].ob_spec.bitblk->bi_color=3; /* 3= hell */
	w_objc_draw(&wspecial, STOLLED, 2, sx, sy, sw, sh);

	/* Nummer setzen */
	itoa(a, num, 10);
	/* Farbe setzen */
	fill_usr_col_ob(ospecial, STOLC, a, a, a);
	
	ospecial[STOLNUM].ob_spec.tedinfo->te_ptext[0]=0;
	if(a < 100)
		strcpy(ospecial[STOLNUM].ob_spec.tedinfo->te_ptext, " ");
	if(a < 10)
		strcat(ospecial[STOLNUM].ob_spec.tedinfo->te_ptext, " ");
	strcat(ospecial[STOLNUM].ob_spec.tedinfo->te_ptext, num);
	
	w_objc_draw(&wspecial, STOLNUM, 2, sx, sy, sw, sh);
	w_objc_draw(&wspecial, STOLC, 2, sx, sy, sw, sh);
}

void big_tol_bar(void)
{
	OBJECT *tolbar;
	char	 num[10];
	int x, y, dum;
	int	oy, my, k, sval, oldval;
	
	graf_mkstate(&x, &my, &dum, &dum);
	oy=my;
	
	xrsrc_gaddr(0,TOLSLIDE,&tolbar, xrsrc);
	
	tolbar[0].ob_height=256+16+3*tolbar[TOLNUM].ob_height;
	tolbar[TOLB].ob_y=2*tolbar[TOLNUM].ob_height;
	tolbar[TOLS].ob_height=16;
	tolbar[TOLB].ob_height=256+16;
	sval=255-atoi(ospecial[STOLNUM].ob_spec.tedinfo->te_ptext);
	if(my-sval-2*tolbar[TOLNUM].ob_height < sy+4)
		sval=my-2*tolbar[TOLNUM].ob_height-(sy+4);
	if(my-sval-2*tolbar[TOLNUM].ob_height+tolbar[0].ob_height > sy+sh-4)
		sval=my-2*tolbar[TOLNUM].ob_height+tolbar[0].ob_height-(sy+sh-4);
	
	tolbar[0].ob_y=my-sval-2*tolbar[TOLNUM].ob_height;
	if(sval < 0) sval=0;
	if(sval > 255) sval=255;
	
	tolbar[0].ob_x=x-tolbar[0].ob_width/2;
	if(tolbar[0].ob_x < sx)
		tolbar[0].ob_x=sx;
	if(tolbar[0].ob_x+tolbar[0].ob_width > sx+sw)
		tolbar[0].ob_x=sx+sw-tolbar[0].ob_width;
		
	tolbar[TOLS].ob_y=sval;
	itoa(255-sval, tolbar[TOLNUM].ob_spec.tedinfo->te_ptext, 10);
		
	wind_update(BEG_UPDATE);
	wind_update(BEG_MCTRL);
	graf_mouse(FLAT_HAND, NULL);
	form_dial(FMD_START, tolbar[0].ob_x-4, tolbar[0].ob_y-4, tolbar[0].ob_width+8, tolbar[0].ob_height+8,
						tolbar[0].ob_x-4, tolbar[0].ob_y-4, tolbar[0].ob_width+8, tolbar[0].ob_height+8);
	
	objc_draw(tolbar, 0, 8, sx, sy, sw, sh);
	objc_offset(tolbar, TOLB, &dum, &y);
	oldval=sval;
	do
	{
		graf_mkstate(&dum, &my, &k, &dum);
		if(my != oy)
		{
			oy=my;
			sval=my-y;
			if(sval < 0) sval=0;
			if(sval > 255) sval=255;
			if(sval != oldval)
			{
				oldval=sval;
				tolbar[TOLS].ob_y=sval;
				itoa(255-sval, tolbar[TOLNUM].ob_spec.tedinfo->te_ptext, 10);
				objc_draw(tolbar, TOLNUM, 8, sx, sy, sw, sh);
				objc_draw(tolbar, TOLB, 8, sx, sy, sw, sh);
			}
		}
	}while(k);
	
	
	form_dial(FMD_FINISH, tolbar[0].ob_x-4, tolbar[0].ob_y-4, tolbar[0].ob_width+8, tolbar[0].ob_height+8,
						tolbar[0].ob_x-4, tolbar[0].ob_y-4, tolbar[0].ob_width+8, tolbar[0].ob_height+8);
	graf_mouse(ARROW, NULL);
	wind_update(END_MCTRL);
	wind_update(END_UPDATE);

	sval=255-tolbar[TOLS].ob_y;
	
	/* Nummer setzen */
	itoa(sval, num, 10);
	/* Farbe setzen */
	fill_usr_col_ob(ospecial, STOLC, sval, sval, sval);
	
	ospecial[STOLNUM].ob_spec.tedinfo->te_ptext[0]=0;
	if(sval < 100)
		strcpy(ospecial[STOLNUM].ob_spec.tedinfo->te_ptext, " ");
	if(sval < 10)
		strcat(ospecial[STOLNUM].ob_spec.tedinfo->te_ptext, " ");
	strcat(ospecial[STOLNUM].ob_spec.tedinfo->te_ptext, num);

	if(sval)
		ospecial[STOLLED].ob_spec.bitblk->bi_color=3; /* 3= hell */
	else
		ospecial[STOLLED].ob_spec.bitblk->bi_color=11; /* 11= dunkel */

	ospecial[STOLS].ob_y=((255-sval)*(ospecial[STOLB].ob_height-ospecial[STOLS].ob_height))/256;
	
	if(wspecial.open)
		s_redraw(&wspecial);
}

void init_parafield(int ob)
{/* Zeigt das zum Werkzeug ob gehîrige Parameterfeld an */
	int a, b, c;
	
	b=ospecial[ob].ob_type >> 8;
	
	a=SZOOM;
	
	memo_toleranz();
	
	do
	{
		++a;
		if((ospecial[a].ob_state & 256) && ((ospecial[a].ob_type & 255) == G_IBOX))
		{/* Parentbox */
			if((ospecial[a].ob_type >> 8) == b)
			{
				ospecial[a].ob_flags &= (~HIDETREE);
				c=a;
			}
			else
				ospecial[a].ob_flags |= HIDETREE;
		}
	}while(!(ospecial[a].ob_flags & LASTOB));
	
	if(c==SOTOL)
		init_toleranz(ob);		/* Zeichnet sowieso das Fenster neu */
	else if(wspecial.open)
		s_redraw(&wspecial);
}

void dial_special(int ob)
{
	CMY_COLOR	c;

	if((ob > 0) && (ob <= SZOOM)) /* Werkzeug angeklickt */
	{
		init_parafield(ob);	
		sel_tool=ob;
		
		if(ob == SSELECT)
		{
			if(!frame_data.vis && frame_data.ok)
			{
				draw_win_frame();
				frame_data.vis=1;
				new_preview_sel();
				if(wexport.open)
					check_what_export();
			}
		}
		else
		{
			if(frame_data.vis)
			{
				draw_win_frame();
				frame_data.vis=0;
				new_preview_sel();
				if(wexport.open)
					check_what_export();
			}
		}
	}
	else
	{
		switch(ob)
		{
			/* "..."-Button */
			case SOPETC:
				if(sel_tool==SDRAW)
					fetz_her(&wtool);
				else if(sel_tool==SSTAMP)
					stampopt_window();
				w_unsel(&wspecial, ob);
			break;
			
			/* Toleranz-Slider */
			case STOLS:
				slide(ospecial, ob, 0, 255, 255-atoi(ospecial[STOLNUM].ob_spec.tedinfo->te_ptext), sl_toleranz);
			break;
			case STOLB:
				bar(&wspecial, ob, 0, 255, sl_toleranz);
			break;
			case STOLBIG:
				big_tol_bar();
			break;
			case STOLC:
				color_dd(ospecial, STOLC);		
			break;
			case -STOLC:	/* War Color-DD Ziel */
				c.red=((U_OB*)(ospecial[STOLC]_UP_))->color.r[0];
				c.yellow=((U_OB*)(ospecial[STOLC]_UP_))->color.g[0];
				c.blue=((U_OB*)(ospecial[STOLC]_UP_))->color.b[0];
				set_grey(&c);
				set_tol_slider(&c);
			break;
		}
	}
}

void dial_tool(int ob)
{
	CMY_COLOR c;
	
	switch(ob)
	{
		case GPPEN:
		case GPPNAME:
		case GPMERK1:
		case GPMERK2:
			if(wpens.open)
				w_top(&wpens);
			else
				w_open(&wpens);
		break;
		case GPPCOL:
			color_dd(otool, GPPCOL);
		break;
		case -GPPCOL: /* Color-DD Ziel->Farbe als Stiftfarbe setzen */
			c.red=((U_OB*)(otool[GPPCOL]_UP_))->color.r[0];
			c.yellow=((U_OB*)(otool[GPPCOL]_UP_))->color.g[0];
			c.blue=((U_OB*)(otool[GPPCOL]_UP_))->color.b[0];
			set_pen_col(&c);
		break;
		case GPLAUS:
			pen.line=0;
		break;
		case GPLGROB:
			pen.line=1;
			pen.step=2;
		break;
		case GPLFEIN:
			pen.line=1;
			pen.step=4;
		break;
		case GPLASUR:
		case GPOPAQUE:
			pen.col.lasur=otool[GPLASUR].ob_state & SELECTED;
		break;

		case GPFSS:
			slide(otool, ob, 0, 32, pen.f_speed, sl_fspeed);
		break;
		case GPFSB:
			bar(&wtool, ob, 0, 32, sl_fspeed);
		break;
	}
}

int close_main_win(void)
{
	/* Return-Wert: 
		 -1=Abbrechen
		 0=ok
		 1=Fehler, z.B. Sichern fehlgeschlagen
	*/

	LAY_LIST	*ll=first_lay, *ln;
	MASK_LIST	*ml=first_mask, *mn;
	int				a=0;
	
	/* Wurde irgendwo was an einer Ebene geÑndert? */
	do
	{
		if(ll->this.changes)
			a=1;
		ll=ll->next;
	}while(ll);
	
	/* Oder sonstwas geÑndet & '*' in den Titel gesetzt? */
	if(main_win.name[0] == '*')
		a=1;
		
	if(a)
	{
		a=form_alert(1,"[2][Grape:|Sollen die énderungen vor dem|Schlieûen gesichert werden?][Sichern|Nicht sichern|Abbruch]");
		switch(a)
		{
			case 1:
				if(main_save())
					a=0;
			break;
			case 2:
				a=0;
			break;
			case 3:
				return(-1);
		}
	}
	
	if(!a)
	{	
		wind_close(main_win.id); 
		wind_delete(main_win.id); 
		main_win.id=-1; 
		ll=first_lay;

		do
		{
			ln=ll->next;
			free(ll->this.red);
			free(ll->this.yellow);
			free(ll->this.blue);
			free(&ll->this);
			free(ll);
			ll=ln;
		}while(ll);
		first_lay=NULL;
		
		while(ml)
		{
			mn=ml->next;
			free(ml->this.mask);
			free(&ml->this);
			free(ml);
			ml=mn;
		}
		first_mask=NULL;
		
		/* Undo-Puffer lîschen */
		free_undo();
		clear_undo();
		init_undo();
		if(wundorec.open)
			w_objc_draw(&wundorec, UCL,1, sx,sy,sw,sh);
			
		/* Alle mit Ebene/Maske verknÅpften Fenster schlieûen */
		if(wcopylay.open)
			dial_copylay(CLABBRUCH);
		if(wnewlay.open)
			dial_newlay(NLABBRUCH);
		if(wnewmask.open)
			dial_newmask(NMABBRUCH);
		if(wzoom.open)
			wzoom.closed(&wzoom);
		if(wexport.open)
			dial_export(EXABBRUCH);
			
		/* Grîûen- und Drucker-Fenster schlieûen */
		if(wnew.open)
			dial_new(ONABBRUCH);
		if(wsize.open)
			dial_size(NSABBRUCH);
		if(wprint.open)
			dial_print(PRABBRUCH);
			

		new_preview_sel();

		/* Ggf. Source-Farben-Ebene entfernen */
		if(pen.source_lay_id != -1)
			del_source_lay(pen.source_lay_id);
				
		prev_func=NULL;
		
		/* Zoom auf 1:1 setzen */
		zoomout=zoomin=0;
		strcpy(otoolbar[TBZOOM].ob_spec.tedinfo->te_ptext, "1:1");
	}

	return(a);
	
}

void actize_win_name(void)
{
	char	nm[256];
	unsigned long np;
	
	if(main_win.name[0] != '*')
	{
		strcpy(nm, main_win.name);
		main_win.name[0]='*';
		main_win.name[1]=0;
		strcat(main_win.name, nm);
		np=(unsigned long)(main_win.name);
		wind_set(main_win.id, WF_NAME, (int)(np>>16), (int)(np & 0xffff), 0,0);
	}
}


void grape_info(void)
{
	if(!winfo.open)
	{
		/* Fenster initialisieren */
		winfo.dinfo=&dinfo;
		w_dial(&winfo, D_CENTER);
		winfo.name="[Grape]";
		w_set(&winfo, NAME);
		w_open(&winfo);
	}
	else
		w_top(&winfo);
}

void dial_info(int ob)
{
	if(ob == STOK)
	{
		w_unsel(&winfo, ob);
		w_close(&winfo);
		w_kill(&winfo);
	}
}

/* System */

void term(void)
{
	d_vector(1);
}

int d_vector(int del)
{
	/* FÅr 1:Lîscht FÅr 0:PrÅft den XBRA-Eintrag im Timer */
	/* Bei Erfolg wird 1, sonst 0 geliefert */
	XBRA					*check;
	long					*origin;
	char					nofound, nolost, count;
	const long		xbconst=0x58425241l; /*XBRA*/
	
	nofound=1;
	nolost=1;
	count=0;
	
	/* Gemdos Vektor zurÅck */
	origin=(long*)(Setexc(256,(void(*)()) -1L));
	check=(XBRA*)((long)(origin)-12);

	do
	{
		if( xbconst==*((long*) &(check->xb_magic[0])) )
		{
			if( my_id== *((long*)&(check->xb_id[0])) )
			{ /* Mein Vektor gefunden, lîschen  falls del=1*/
				if(del)
				{
					if (count)
						*origin=check->xb_oldvec;
					else
						Setexc(256, (void(*)())(check->xb_oldvec));
				}
				nofound=0;
			}
			else
			{
				origin=(long*)((long)(check)+8);
				check=(XBRA*)(*origin-12);
				count++;
			}
		}
		else
		{ /* Eintrag kein XBRA */
			nolost=0;
		}
	}while(nofound && nolost);
	if (nofound)
		return(0);
	else
		return(1);
}






void draw_test(void)
{
	int wx,wy,ww,wh, bench[10];
	int	b;
	TIP	*ttip;
	char	result[512], num[10];
	
	wind_update(BEG_UPDATE);
	wind_update(BEG_MCTRL);
	graf_mouse(M_OFF, NULL);
	wind_get(main_win.id, WF_WORKXYWH, &wx, &wy, &ww, &wh);
	for(b=0; b < 4; ++b)
	{
		*(unsigned char*)((long)&c_red+(long)b)=pen.col.red;
		*(unsigned char*)((long)&c_yellow+(long)b)=pen.col.yellow;
		*(unsigned char*)((long)&c_blue+(long)b)=pen.col.blue;
	}
	c_lasur=0;
	p_red=first_lay->this.red;
	p_yellow=first_lay->this.yellow;
	p_blue=first_lay->this.blue;
	p_screen=(void*)((long)((long)physbase+(long)wy*(long)sw+(long)wx));
	
	p_width=(long)first_lay->this.word_width;
	screen_width=sw;

	ttip=pen.tip[255];
	pen_r=ttip->red;
	pen_g=ttip->yellow;
	pen_b=ttip->blue;

	rel_start_x=start_x=256-ttip->dl;
	rel_start_y=start_y=256-ttip->du;	
	
	end_x=256+ttip->dr;
	end_y=256+ttip->dd;

	free_undo();
	clear_undo();
	init_undo();
	undo_ok=1;
c_solo=1;
  counter=0;
  for(b=0; b < 500; ++b)
  {
		paint_it();
		if(undo_end >= undo_maxend)
			resize_undo();
		do_dither();
	}
  bench[0]=counter;

	undo_ok=0;
  counter=0;
  for(b=0; b < 500; ++b)
  {
		paint_it();
		do_dither();
	}
  bench[1]=counter;

/*
	undo_ok=0;
  counter=0;
  for(b=0; b < 500; ++b)
  {
		do_dither();
	}
  bench[2]=counter;
*/
  
	c_lasur=1;
  
	free_undo();
	clear_undo();
	init_undo();
	undo_ok=1;

  counter=0;
  for(b=0; b < 500; ++b)
  {
		paint_it();
		if(undo_end >= undo_maxend)
			resize_undo();
		do_dither();
	}
  bench[3]=counter;

	undo_ok=0;
  counter=0;
  for(b=0; b < 500; ++b)
  {
		paint_it();
		do_dither();
	}
  bench[4]=counter;

	undo_ok=0;
  counter=0;
  for(b=0; b < 500; ++b)
  {
		do_dither();
	}
  bench[5]=counter;
	
	strcpy(result, "[1][Ergebnis:|");
	strcat(result, "Alt mit Undo: ");
	strcat(result, itoa(bench[0], num, 10));
	strcat(result, " ohne: ");
	strcat(result, itoa(bench[1], num, 10));
/*	strcat(result, " Dith: ");
	strcat(result, itoa(bench[2], num, 10));*/
	strcat(result, "|Neu mit Undo: ");
	strcat(result, itoa(bench[3], num, 10));
	strcat(result, " ohne: ");
	strcat(result, itoa(bench[4], num, 10));
	strcat(result, " Dith: ");
	strcat(result, itoa(bench[5], num, 10));
	strcat(result, "][OK]");
	form_alert(1, result);


		*undo_end++=0;
		*undo_end++=255; /* Typ nÑchstes Zeigerpaar */
		*(unsigned long*)undo_end=0; /* Zeiger auf Blockanfang ist Null*/
		undo_end+=4;
		*(unsigned long*)undo_end=0; /* Zeiger auf letzten Eintrag ist Null*/
		undo_end+=4;
		*undo_end++=0;
		*undo_end++=12; /* GesamtlÑnge */

		undo_end-=12; /* ZurÅcksetzen auf Eintrag */

	graf_mouse(M_ON, NULL);
	wind_update(END_MCTRL);
	wind_update(END_UPDATE);
	display_undo();

}



void debug_display(unsigned char *src, int ssw, int ssh)
{
	/* src=Plane-adresse, ssw=Breite, ssh=Hîhe */
	/* Ausgabe erfolgt einfach von oben links auf den Screen */
		p_red=src;
		p_yellow=src;
		p_blue=src;
		p_screen=(void*)((long)((long)physbase+(long)sy*(long)sw+(long)sx));
		p_width=(long)ssw;
		screen_width=sw;
		rel_start_x=0;
		rel_start_y=0;
		start_x=0;
		start_y=0;
		end_x=ssw-1;
		end_y=ssh-1;
		c_solo=1;
			
		do_dither();
}
void set_ppix(unsigned char *b, unsigned char *c)
{
	/* b=0,0-Adresse der Plane, c=x,y-Adresse des Pixels */
	/* setzt entsprechend einen Pixel auf dem Screen */
	
	long h, w, p, q;
	unsigned char *x;
	
	h=((long)c-(long)b)/(long)first_lay->this.word_width;
	w=(long)c-(long)b-h*(long)first_lay->this.word_width;

	q=(long)Physbase();
	p=h*(long)sw+w;
	x=(unsigned char*)(p+q);
	*x=*x+1;

}
void set_kpix(int x, int y)
{
	/* Setzt an x,y einen Pixel auf den Screen */
	
	(*(uchar*)((uchar*)Physbase()+(long)y*(long)sw+x))+=1;
}


