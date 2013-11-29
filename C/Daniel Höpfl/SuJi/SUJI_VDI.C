#include "SuJi_glo.h"

int vdi_h;
int zahl_der_fonts;
int screen_font;
int screen_font_height;
int screen_font_color;
int line_height;
int top_height;

MFORM mausform;

int init_vwork(void)
{
	int attrib[10];
	int wi[]={1,1,1,1,1,0,1,FIS_SOLID,0,WHITE,2};
	int wo[60];

	vdi_h=mt_graf_handle(&i,&i,&i,&i,&global);
	v_opnvwk(wi,&vdi_h,wo);
	if(vdi_h==0)
		return vdi_h;

	if(vq_gdos())
		zahl_der_fonts=vst_load_fonts(vdi_h,0)+wo[10];
	else
		zahl_der_fonts=wo[10];

	vst_font(vdi_h,1);
	vqt_attributes(vdi_h,attrib);

	if(!mt_appl_getinfo(0,&screen_font_height,&screen_font,NULL,NULL,&global))
	{
		screen_font=attrib[0];
		screen_font_height=attrib[7];
	}
	screen_font_color=attrib[1];

	line_height=attrib[9];
	top_height=line_height+4;

	return vdi_h;
}

void exit_vwork(void)
{
	if(vq_gdos())
		vst_unload_fonts(vdi_h,0);
	v_clsvwk(vdi_h);
}

int test_max_breite(FILE_INFO *fi)
{
	int ext[8];
	int li,re;
	char mein[11];
	int old[6];

	for(li=0;li<6;li++)
		old[li]=max_breite[li];

	vqt_extent(vdi_h,fi->name,ext);

	li=(ext[0]<ext[6]) ? ext[0] : ext[6];
	re=(ext[4]>ext[2]) ? ext[4] : ext[2];
	max_breite[BR_FILE]=((((li>re) ? 8+li-re : 8+re-li)>max_breite[BR_FILE]) ? 
					((li>re) ? 8+li-re : 8+re-li) : max_breite[BR_FILE]);

	sprintf(mein,"%ld",fi->size);
	vqt_extent(vdi_h,mein,ext);

	li=(ext[0]<ext[6]) ? ext[0] : ext[6];
	re=(ext[4]>ext[2]) ? ext[4] : ext[2];
	max_breite[BR_SIZE]=((((li>re) ? 8+li-re : 8+re-li)>max_breite[BR_SIZE]) ? 
					((li>re) ? 8+li-re : 8+re-li) : max_breite[BR_SIZE]);

	sprintf(mein,"%02d:%02d:%02d",
			(fi->time & 0xf800)/0x0800,
			(fi->time & 0x07e0)/0x0020,
			(fi->time & 0x001f)*2);
	vqt_extent(vdi_h,mein,ext);

	li=(ext[0]<ext[6]) ? ext[0] : ext[6];
	re=(ext[4]>ext[2]) ? ext[4] : ext[2];
	max_breite[BR_TIME]=((((li>re) ? 8+li-re : 8+re-li)>max_breite[BR_TIME]) ? 
					((li>re) ? 8+li-re : 8+re-li) : max_breite[BR_TIME]);

	{ /* PrÅfen, ob Tag oder Monat vorne stehen soll */
		OBJECT *tree;
		char trenner;

		mt_rsrc_gaddr(0,LANGUAGE_SETTING,&tree,&global);
		trenner=tree[LS_DM_TRENNER].ob_spec.tedinfo->te_ptext[0];

		if(tree[LS_DAY_MONTH].ob_state & SELECTED)
		{
			sprintf(mein,"%02d%c%02d%c%04d",
				(fi->date & 0x001f),
				trenner,
				(fi->date & 0x01e0)/0x0020,
				trenner,
				(fi->date & 0xfe00)/0x0200+1980);
		}
		else
		{
			sprintf(mein,"%02d%c%02d%c%04d",
				(fi->date & 0x01e0)/0x0020,
				trenner,
				(fi->date & 0x001f),
				trenner,
				(fi->date & 0xfe00)/0x0200+1980);
		}
	}
	vqt_extent(vdi_h,mein,ext);

	li=(ext[0]<ext[6]) ? ext[0] : ext[6];
	re=(ext[4]>ext[2]) ? ext[4] : ext[2];
	max_breite[BR_DATE]=((((li>re) ? 8+li-re : 8+re-li)>max_breite[BR_DATE]) ? 
					((li>re) ? 8+li-re : 8+re-li) : max_breite[BR_DATE]);

	sprintf(mein,"%c%c%c%c%c",
		(fi->attrib & FA_READONLY) ? 'R' : '-',
		(fi->attrib & FA_HIDDEN) ? 'H' : '-',
		(fi->attrib & FA_SYSTEM) ? 'S' : '-',
		(fi->attrib & FA_VOLUME) ? 'V' : '-',
		(fi->attrib & FA_ARCHIVE) ? 'A' : '-');
	vqt_extent(vdi_h,mein,ext);

	li=(ext[0]<ext[6]) ? ext[0] : ext[6];
	re=(ext[4]>ext[2]) ? ext[4] : ext[2];
	max_breite[BR_ATTR]=((((li>re) ? 8+li-re : 8+re-li)>max_breite[BR_ATTR]) ? 
					((li>re) ? 8+li-re : 8+re-li) : max_breite[BR_ATTR]);

	vqt_extent(vdi_h,fi->pfad,ext);

	li=(ext[0]<ext[6]) ? ext[0] : ext[6];
	re=(ext[4]>ext[2]) ? ext[4] : ext[2];
	max_breite[BR_PATH]=((((li>re) ? 8+li-re : 8+re-li)>max_breite[BR_PATH]) ? 
					((li>re) ? 8+li-re : 8+re-li) : max_breite[BR_PATH]);

	for(li=0;li<6;li++)
	{
		if(old[li]!=max_breite[li])
		{
			full.g_w=full.g_h=-1;
			return 1;
		}
	}

	return 0;
}

void init_max_breite(void)
{
	int ext[8];
	int li,re;

	vst_effects(vdi_h,9);

	mt_rsrc_gaddr(5,TIT_FILE,&alert,&global);
	vqt_extent(vdi_h,alert,ext);

	li=(ext[0]<ext[6]) ? ext[0] : ext[6];
	re=(ext[4]>ext[2]) ? ext[4] : ext[2];
	max_breite[BR_FILE]=8+((li>re) ? li-re : re-li);

	mt_rsrc_gaddr(5,TIT_SIZE,&alert,&global);
	vqt_extent(vdi_h,alert,ext);

	li=(ext[0]<ext[6]) ? ext[0] : ext[6];
	re=(ext[4]>ext[2]) ? ext[4] : ext[2];
	max_breite[BR_SIZE]=8+((li>re) ? li-re : re-li);

	mt_rsrc_gaddr(5,TIT_TIME,&alert,&global);
	vqt_extent(vdi_h,alert,ext);

	li=(ext[0]<ext[6]) ? ext[0] : ext[6];
	re=(ext[4]>ext[2]) ? ext[4] : ext[2];
	max_breite[BR_TIME]=8+((li>re) ? li-re : re-li);

	mt_rsrc_gaddr(5,TIT_DATE,&alert,&global);
	vqt_extent(vdi_h,alert,ext);

	li=(ext[0]<ext[6]) ? ext[0] : ext[6];
	re=(ext[4]>ext[2]) ? ext[4] : ext[2];
	max_breite[BR_DATE]=8+((li>re) ? li-re : re-li);

	mt_rsrc_gaddr(5,TIT_ATTR,&alert,&global);
	vqt_extent(vdi_h,alert,ext);

	li=(ext[0]<ext[6]) ? ext[0] : ext[6];
	re=(ext[4]>ext[2]) ? ext[4] : ext[2];
	max_breite[BR_ATTR]=8+((li>re) ? li-re : re-li);

	mt_rsrc_gaddr(5,TIT_PATH,&alert,&global);
	vqt_extent(vdi_h,alert,ext);

	li=(ext[0]<ext[6]) ? ext[0] : ext[6];
	re=(ext[4]>ext[2]) ? ext[4] : ext[2];
	max_breite[BR_PATH]=8+((li>re) ? li-re : re-li);

	vst_effects(vdi_h,0);

	/* Zuschlag fÅr den "Sortierrichtungsanzeiger" */
	for(i=0;i<6;i++)
		max_breite[i]+=7;
}

void set_new_font(int id,int size)
{
	int old_id,old_size;

	old_id=screen_font;
	old_size=screen_font_height;

	if(vst_font(vdi_h,id)==id)
	{
		FILE_INFO *par;
		long nr;

		vst_point(vdi_h,size,&dummy,&dummy,&dummy,&line_height);
		screen_font=id;
		screen_font_height=size;
		top_height=line_height+4;

		init_max_breite();

		nr=1;
		do {
			par=get_from_list(nr);
			nr++;
			if(par)
				test_max_breite(par);
		} while(par);
	}
	else
	{
		vst_font(vdi_h,1);
		mt_rsrc_gaddr(5,ERR_WRONG_FONT,&alert,&global);
		mt_form_alert(1,alert,&global);
	}

	if(window_handle>=0 && (old_id!=screen_font || old_size!=screen_font_height))
	{
		int msg[8];

		msg[1]=ap_id;
		msg[2]=0;
		msg[3]=window_handle;
		mt_wind_get_grect(window_handle,WF_WORKXYWH,(GRECT *)&msg[4],&global);

		msg[0]=WM_REDRAW;
		mt_appl_write(ap_id,16,msg,&global);

		mt_wind_calc_grect(WC_BORDER,WIND_KIND,(GRECT *)&msg[4],(GRECT *)&msg[4],&global);
		msg[0]=WM_SIZED;
		mt_appl_write(ap_id,16,msg,&global);
	}
}

void anpass_bmp(OBJECT *tree,int obj)
{
	MFDB quell={0};
	MFDB ziel={0};
	void *doppel;

	if((tree[obj].ob_type & 0x00ff)==G_ICON)
	{
		doppel=Malloc(((((tree[obj].ob_spec.iconblk->ib_wicon+15)/16)*16)/8)*tree[obj].ob_spec.iconblk->ib_hicon);
	
		quell.fd_addr=tree[obj].ob_spec.iconblk->ib_pmask;
		quell.fd_w=(((tree[obj].ob_spec.iconblk->ib_wicon+15)/16)*16);
		quell.fd_h=tree[obj].ob_spec.iconblk->ib_hicon;
		quell.fd_wdwidth=((tree[obj].ob_spec.iconblk->ib_wicon+15)/16);
		quell.fd_stand=0;
		quell.fd_nplanes=1;
	
		if(doppel)
			ziel.fd_addr=doppel;
		else
			ziel.fd_addr=tree[obj].ob_spec.iconblk->ib_pmask;
		ziel.fd_w=quell.fd_w;
		ziel.fd_h=quell.fd_h;
		ziel.fd_wdwidth=quell.fd_wdwidth;
		ziel.fd_stand=1;
		ziel.fd_nplanes=1;
	
		vr_trnfm(vdi_h,&quell,&ziel);
	
		if(doppel)
		{
			memcpy(tree[obj].ob_spec.iconblk->ib_pmask,doppel,(((((tree[obj].ob_spec.iconblk->ib_wicon+15)/16)*16)/8)*tree[obj].ob_spec.iconblk->ib_hicon));
			Mfree(doppel);
		}
	
		doppel=Malloc(((((tree[obj].ob_spec.iconblk->ib_wicon+15)/16)*16)/8)*tree[obj].ob_spec.iconblk->ib_hicon);
	
		quell.fd_addr=tree[obj].ob_spec.iconblk->ib_pdata;
		quell.fd_w=(((tree[obj].ob_spec.iconblk->ib_wicon+15)/16)*16);
		quell.fd_h=tree[obj].ob_spec.iconblk->ib_hicon;
		quell.fd_wdwidth=((tree[obj].ob_spec.iconblk->ib_wicon+15)/16);
		quell.fd_stand=0;
		quell.fd_nplanes=1;
	
		if(doppel)
			ziel.fd_addr=doppel;
		else
			ziel.fd_addr=tree[obj].ob_spec.iconblk->ib_pdata;
		ziel.fd_w=quell.fd_w;
		ziel.fd_h=quell.fd_h;
		ziel.fd_wdwidth=quell.fd_wdwidth;
		ziel.fd_stand=1;
		ziel.fd_nplanes=1;
	
		vr_trnfm(vdi_h,&quell,&ziel);
	
		if(doppel)
		{
			memcpy(tree[obj].ob_spec.iconblk->ib_pdata,doppel,(((((tree[obj].ob_spec.iconblk->ib_wicon+15)/16)*16)/8)*tree[obj].ob_spec.iconblk->ib_hicon));
			Mfree(doppel);
		}
	}
	else if((tree[obj].ob_type & 0x00ff)==G_IMAGE)
	{
		doppel=Malloc(tree[obj].ob_spec.bitblk->bi_wb*tree[obj].ob_spec.bitblk->bi_hl);
	
		quell.fd_addr=tree[obj].ob_spec.bitblk->bi_pdata;
		quell.fd_w=tree[obj].ob_spec.bitblk->bi_wb*8;
		quell.fd_h=tree[obj].ob_spec.bitblk->bi_hl;
		quell.fd_wdwidth=tree[obj].ob_spec.bitblk->bi_wb/2;
		quell.fd_stand=0;
		quell.fd_nplanes=1;
	
		if(doppel)
			ziel.fd_addr=doppel;
		else
			ziel.fd_addr=tree[obj].ob_spec.bitblk->bi_pdata;
		ziel.fd_w=tree[obj].ob_spec.bitblk->bi_wb*8;
		ziel.fd_h=tree[obj].ob_spec.bitblk->bi_hl;
		ziel.fd_wdwidth=tree[obj].ob_spec.bitblk->bi_wb/2;
		ziel.fd_stand=1;
		ziel.fd_nplanes=1;
	
		vr_trnfm(vdi_h,&quell,&ziel);
	
		if(doppel)
		{
			memcpy(tree[obj].ob_spec.bitblk->bi_pdata,doppel,tree[obj].ob_spec.bitblk->bi_wb*tree[obj].ob_spec.bitblk->bi_hl);
			Mfree(doppel);
		}
	}
}

void icons_anpassen(void)
{
	OBJECT *tree;
	int wo[60];

	mt_rsrc_gaddr(0,MASKE_ICONIFY,&tree,&global);

	anpass_bmp(tree,SU_ICON1);
	anpass_bmp(tree,SU_ICON2);
	anpass_bmp(tree,SU_ICON3);

	tree[SU_ICON3].ob_flags |= HIDETREE;
	tree[SU_ICON].ob_width=tree[SU_ICON1].ob_width;
	tree[SU_ICON].ob_height=tree[SU_ICON1].ob_height;

	tree[SU_ICON1].ob_x=0;
	tree[SU_ICON3].ob_x=0;
	tree[SU_ICON1].ob_y=0;
	tree[SU_ICON3].ob_y=0;

	mt_rsrc_gaddr(0,MASKE_DIALOG,&tree,&global);

	anpass_bmp(tree,MASKE_INFO1);
	anpass_bmp(tree,MASKE_INFO2);
	anpass_bmp(tree,MASKE_INFO3);
	anpass_bmp(tree,MASKE_INFO4);
	anpass_bmp(tree,MASKE_INFO_FARBE);

	anpass_bmp(tree,MASKE_INFO_SW);

	anpass_bmp(tree,MASKE_HELP1);
	anpass_bmp(tree,MASKE_HELP2);
	anpass_bmp(tree,MASKE_HELP3);
	anpass_bmp(tree,MASKE_HELP4);
	anpass_bmp(tree,MASKE_HELP_FARBE);

	anpass_bmp(tree,MASKE_HELP_SW);

	vq_extnd(vdi_h,1,wo);

	if(wo[4]>=4)
	{
		tree[MASKE_INFO_SW].ob_flags |= HIDETREE;
		tree[MASKE_HELP_SW].ob_flags |= HIDETREE;
	}
	else
	{
		tree[MASKE_INFO1].ob_flags |= HIDETREE;
		tree[MASKE_HELP1].ob_flags |= HIDETREE;
	}

	anpass_bmp(tree,OPEN_LIST);
	anpass_bmp(tree,CLOSE_LIST);

		/* Slider leicht verschieben */
	tree[VSL_DOWN].ob_y--;
	tree[VSL_UP].ob_y--;

	tree[HSL_LEFT].ob_x--;
	tree[HSL_RIGHT].ob_x--;

		/* Aussehen an 3D-Look anpassen */
	reform_3d();
}

void reform_3d(void)
{
	OBJECT *tree;
	int wo[60];
	int h3d;

	mt_rsrc_gaddr(0,MASKE_DIALOG,&tree,&global);

	if(!mt_appl_getinfo(13,&h3d,NULL,NULL,NULL,&global))
		h3d=FALSE;

	vq_extnd(vdi_h,1,wo);

	if(!h3d || wo[4]<4)
	{
		tree[VSL_BACK].ob_spec.obspec.interiorcol = 1;			/* Farbe schwarz */
		tree[VSL_BACK].ob_spec.obspec.fillpattern = 1;			/* Muster */

		tree[HSL_BACK].ob_spec.obspec.interiorcol = 1;			/* Farbe schwarz */
		tree[HSL_BACK].ob_spec.obspec.fillpattern = 1;			/* Muster */

		tree[VSL_SLIDER].ob_spec.obspec.framesize = 1;			/* innen 1 Pixel Rahmen */
		tree[VSL_DOWN].ob_spec.obspec.framesize = 1;			/* innen 1 Pixel Rahmen */
		tree[VSL_UP].ob_spec.obspec.framesize = 1;				/* innen 1 Pixel Rahmen */
	
		tree[HSL_SLIDER].ob_spec.obspec.framesize = 1;			/* innen 1 Pixel Rahmen */
		tree[HSL_LEFT].ob_spec.obspec.framesize = 1;			/* innen 1 Pixel Rahmen */
		tree[HSL_RIGHT].ob_spec.obspec.framesize = 1;			/* innen 1 Pixel Rahmen */

		tree[SLBOX_ECKE].ob_spec.obspec.framesize = 1;			/* innen 1 Pixel Rahmen */
	}
	else
	{
		tree[VSL_BACK].ob_spec.obspec.interiorcol = 9;			/* Farbe schwarz */
		tree[VSL_BACK].ob_spec.obspec.fillpattern = 7;			/* Muster */

		tree[HSL_BACK].ob_spec.obspec.interiorcol = 9;			/* Farbe schwarz */
		tree[HSL_BACK].ob_spec.obspec.fillpattern = 7;			/* Muster */

		tree[VSL_SLIDER].ob_spec.obspec.framesize = 2;			/* innen 1 Pixel Rahmen */
		tree[VSL_DOWN].ob_spec.obspec.framesize = 2;			/* innen 1 Pixel Rahmen */
		tree[VSL_UP].ob_spec.obspec.framesize = 2;				/* innen 1 Pixel Rahmen */
	
		tree[HSL_SLIDER].ob_spec.obspec.framesize = 2;			/* innen 1 Pixel Rahmen */
		tree[HSL_LEFT].ob_spec.obspec.framesize = 2;			/* innen 1 Pixel Rahmen */
		tree[HSL_RIGHT].ob_spec.obspec.framesize = 2;			/* innen 1 Pixel Rahmen */

		tree[SLBOX_ECKE].ob_spec.obspec.framesize = 2;			/* innen 1 Pixel Rahmen */
	}
}


void set_mouse(int type)
{
	if(type==ARROW)
	{
		if(searching)
		{
			OBJECT *tree;

			mt_rsrc_gaddr(0,MAUSZEIGER,&tree,&global);

			mausform.mf_xhot=0;
			mausform.mf_yhot=0;
			mausform.mf_nplanes=1;
			mausform.mf_fg=WHITE;
			mausform.mf_bg=BLACK;
			for(i=0;i<16;i++)
			{
				mausform.mf_mask[i]=tree[MAUS_OBJ].ob_spec.iconblk->ib_pmask[i];
				mausform.mf_data[i]=tree[MAUS_OBJ].ob_spec.iconblk->ib_pdata[i];
			}
			mt_graf_mouse(USER_DEF,&mausform,&global);
		}
		else
		{
			mt_graf_mouse(ARROW,NULL,&global);
		}
	}
	else
	{
		mt_graf_mouse(type,NULL,&global);
	}
}
