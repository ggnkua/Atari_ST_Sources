#include <ec_gem.h>
#include <gscript.h>
#include <xvdi.h>

#include "ioglobal.h"
#include "io.h"

#define FONT_CHANGED 0x7a18

extern void save_cr_as_crlf(int fh, char *c);
extern int	aes_pixwidth(char *c);

extern char	aes_fw[256];	/* EC_GEM */

int gemscript;
int a_off=0, a_sel=-1;
WINDOW anh_win;
DINFO anh_dinf;

/* -------------------- */

#define set_ext_type(tree,ob,val)	{tree[ob].ob_type &=255; tree[ob].ob_type |= (((char)val)<<8);}
#define obj_type(a, b) ((int)(a[b].ob_type & 0xff))
#define ext_type(a, b) ((int)(a[b].ob_type >> 8))

/* -------------------- */

GS_INFO	ap_gi={sizeof(GS_INFO), 0x0100, 0, 0};
#define GS_ID	0x1224;
	
/* -------------------- */

void		rsrc_iconfix(OBJECT *tree);
void		rsrc_init(void);
OBJECT	*get_icon(char *file);
void		do_dial(WINDOW *win, int ob);
void		main_loop(void);
int			gemscript_init(void);
OBJECT *gs_geticon(char *name);

/* -------------------- */

char *make_quote(char *file)
{
	static char quoted[256];
	char	*c;
	
	if( (file[0]!='\'') && (!strchr(file, ' '))) return(file);

	c=quoted; *c++='\'';
	while(*file) if( (*c++=*file++)=='\'' ) *c++='\'';
	*c++='\'';
	*c=0;

	return(quoted);
}

/* -------------------- */

char *p_extract_atx(MAIL_ATX *atx, int save_show)
{ /* save_show: 0=save, 1=show, 2=save temp, don't show
		always returns save_path (or "")*/
	int		fh;
	long	fhl;
	static	char path[256];
	char	name[64], *c;

	name[0]=0;	
	
	if(save_show)
	{
		strcpy(path, db_path);
		strcat(path, "\\TMP\\");
		if(atx->file_name[0])	strcat(path, atx->file_name);
		else
		{
			strcat(path, get_free_file(path));
			strcat(path, ".");
			if(!strmnicmp(atx->mime_type, "text/plain"))
				strcat(path, "TXT");
			else if(!strmnicmp(atx->mime_type, "text/richtext"))
				strcat(path, "RTF");
			else if(!strmnicmp(atx->mime_type, "text/html"))
				strcat(path, "HTM");
			else if(!strmnicmp(atx->mime_type, "message/"))
				strcat(path, "TXT");
			else if(!strmnicmp(atx->mime_type, "application/octet-stream"))
				strcat(path, "BIN");
			else if(!strmnicmp(atx->mime_type, "application/postscript"))
				strcat(path, "PS");
			else if(!strmnicmp(atx->mime_type, "application/zip"))
				strcat(path, "ZIP");
			else if(!strmnicmp(atx->mime_type, "msword"))
				strcat(path, "DOC");
			else if(!strmnicmp(atx->mime_type, "image/jpeg"))
				strcat(path, "JPG");
			else if(!strmnicmp(atx->mime_type, "image/gif"))
				strcat(path, "GIF");
			else if(!strmnicmp(atx->mime_type, "image/ief"))
				strcat(path, "IEF");
			else if(!strmnicmp(atx->mime_type, "image/tiff"))
				strcat(path, "TIF");
			else if(!strmnicmp(atx->mime_type, "audio/basic"))
				strcat(path, "SMP");
			else if(!strmnicmp(atx->mime_type, "video/mpeg"))
				strcat(path, "MPG");
			else if(!strmnicmp(atx->mime_type, "video/quicktime"))
				strcat(path, "MOV");
		}
	}
	else
	{
		strcpy(name, atx->file_name);
		if(f_sinput(gettext(ATX_SAVE_AS),ios.atx_save_path, name)==0) return("");
		make_path(path, ios.atx_save_path, name);
		fhl=Fopen(path, FO_READ);
		if(fhl > -1)
		{
			Fclose((int)fhl);
			if(form_alert(1, gettext(FILE_EXIST))==2) return("");
		}
	}

	graf_mouse(BUSYBEE, NULL);
	/* Body decodieren */
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
	graf_mouse(ARROW, NULL);

	fhl=Fcreate(path, 0);
	if(fhl < 0)
	{
		gemdos_alert(gettext(CREATEERR), fhl);
		return("");
	}
	graf_mouse(BUSYBEE, NULL);
	fh=(int)fhl;
	if(atx->encoding==4) /* Binary */
		Fwrite(fh, atx->atx_len, atx->atx);
	else /* Alle CR durch CR/LF ersetzen */
	{
		c=atx->atx;
		save_cr_as_crlf(fh, c);
	}
	Fclose(fh);
	graf_mouse(ARROW, NULL);
	if(save_show!=1) return(path);
	pbuf[0]=AV_STARTPROG;
	pbuf[1]=ap_id;
	pbuf[2]=0;
	*((char**)(&pbuf[3]))=make_quote(path);
	pbuf[5]=pbuf[6]=0;
	appl_write(0, 16, pbuf);
	return(path);
}

void extract_atx(MAIL_ATX *atx, int save_show)
{
	p_extract_atx(atx, save_show);
}

/* -------------------- */

char *use_name(MAIL_ATX *atx)
{/* Gibt den Anteil von p zurck, der im Drop benutzt wird.
		Das ist bei *.APP/PRG/ACC nur der Name, sonst Name+Suffix */
	
	if(atx->file_name[0]) return(atx->file_name);
	return(atx->mime_type);
}

/* -------------------- */

int pixwidth(char *c)
{/* Pixelbreite in Systemfont */
	int w=0;
	
	while(*c) w+=aes_fw[*c++];
	return(w);
}

int maxwidth(MAIL_ATX *atx)
{
	OBJECT	*src;
	int			lead_space=0;
	int			width, max=0;

	rsrc_gaddr(0, L_ANHANG, &src);
	while(lead_space*aes_fw[' '] < src[A_ICO].ob_width+2) ++lead_space;
	while(atx)
	{
		if((width=pixwidth(use_name(atx))) > max) max=width;
		atx=atx->next;
	}
	return(max+aes_fw[' ']*(lead_space+1));
}

/* -------------------- */

OBJECT *get_icon(char *file)
{
	OBJECT *obj=NULL, *vorl;

	rsrc_gaddr(0, VORLAGE, &vorl);
	
	obj=&(vorl[VRED]);
	
	vorl=gs_geticon(file);
		
	if(vorl) obj=vorl;
	return(obj);
}

/* -------------------- */

OBJECT *create_anhang_rsc(MAIL_ATX *atx)
{
	OBJECT	*tree, *src, *ico;
	MAIL_ATX	*ma;
	CICONBLK	*iblk;
	CICON			*cico;
	TEDINFO		*tedi;
	int				*icobuf;
	char		*strings;
	int			a, ix, cop_x, cop_y, cop_int, counted=count_atx(atx)-a_off;
	int			lead_space=0;
	long		filelen;

	if(counted < 0) counted=0;
		
	rsrc_gaddr(0, L_ANHANG, &src);
	if(counted > src[ANH_FRAME].ob_height/(src[IASHOW].ob_height+2))
		counted=src[ANH_FRAME].ob_height/(src[IASHOW].ob_height+2);
	while(lead_space*aes_fw[' '] < src[A_ICO].ob_width+2) ++lead_space;

	filelen=0;
	ma=atx;
	a=a_off;
	while(a-- && ma) ma=ma->next;
	if(ma)
	{
		a=counted;
		while(a--)
		{
			filelen+=strlen(use_name(ma))+1+1+lead_space;	/* 0-Term, fhrende x Space, schliežendes 1 Space */
			ma=ma->next;
		}
	}

	tree=malloc(((counted*2)+A_STR)*sizeof(OBJECT) + (counted)*sizeof(CICONBLK)+ (counted)*sizeof(CICON) + counted*sizeof(TEDINFO)+(counted)*(2*32+2*4*32) + filelen);
	if(tree==NULL) return(NULL);
	iblk=(CICONBLK*)(&(tree[(counted*2)+A_STR]));
	cico=(CICON*)(&(iblk[counted]));
	tedi=(TEDINFO*)(&(cico[counted]));
	icobuf=(int*)(&(tedi[counted]));
	strings=(char*)(&(icobuf[(counted)*(32+4*32)]));

	for(a=0; a <= ANH_FRAME; ++a)	
		tree[a]=src[a];

	if(counted==0) 
	{
		tree[ANH_FRAME].ob_tail=tree[ANH_FRAME].ob_head=-1;
		tree[ANH_FRAME].ob_next=0; tree[ANH_FRAME].ob_flags|=LASTOB;
		return(tree);
	}

	ix=ANH_FRAME;
	ma=atx;
	a=a_off;
	while(a-- && ma) ma=ma->next;
	a=0;
	while(a < counted)
	{
		++ix;
		/* String */
		tree[ix]=src[A_STR];
		tree[ix].ob_y=(src[A_STR].ob_height+2)*a;
		tree[ix].ob_width=tree[ANH_FRAME].ob_width;
		tree[ix].ob_spec.tedinfo=tedi; ++tedi;
		*(tree[ix].ob_spec.tedinfo)=*(src[A_STR].ob_spec.tedinfo);
		tree[ix].ob_spec.tedinfo->te_ptext=strings;
		tree[ix].ob_head=tree[ix].ob_tail=ix+1;
		memset(strings, ' ', lead_space);
		strings[lead_space]=0;
		strcat(strings, use_name(ma));
		strcat(strings, " ");
		if((ix-A_STR)/2+a_off == a_sel) tree[ix].ob_state |= SELECTED;
		tree[ix].ob_next=ix+2;
		/* Icon */
		++ix;
		tree[ix]=src[A_ICO];
		tree[ix].ob_next=ix-1;	/* parent=String */

		ico=get_icon(use_name(ma));
		iblk[a]=*(src[A_ICO].ob_spec.ciconblk);
		tree[ix].ob_spec.ciconblk=&(iblk[a]);
		iblk[a].mainlist=NULL;
		iblk[a].monoblk.ib_pmask=icobuf; icobuf+=16;
		iblk[a].monoblk.ib_pdata=icobuf; icobuf+=16;
		tree[ix].ob_type=ico->ob_type;
		cop_x=tree[ix].ob_spec.iconblk->ib_wicon=ico->ob_spec.iconblk->ib_wicon;
		cop_y=tree[ix].ob_spec.iconblk->ib_hicon=ico->ob_spec.iconblk->ib_hicon;
		cop_int=cop_x*cop_y/16;		
		memcpy(tree[ix].ob_spec.iconblk->ib_pmask,ico->ob_spec.iconblk->ib_pmask,cop_int*2);
		memcpy(tree[ix].ob_spec.iconblk->ib_pdata,ico->ob_spec.iconblk->ib_pdata,cop_int*2);

		if((obj_type(tree, ix)==G_CICON) && (ico->ob_spec.ciconblk->mainlist))
		{
			iblk[a].mainlist=&(cico[a]);
			cico[a].num_planes=4; cico[a].sel_data=cico[a].sel_mask=NULL;
			cico[a].col_data=icobuf; icobuf+=4*16;
			cico[a].col_mask=icobuf; icobuf+=4*16;
			cico[a].next_res=NULL;
			memcpy(cico[a].col_data, ico->ob_spec.ciconblk->mainlist->col_data, 8*cop_int);
			memcpy(cico[a].col_mask, ico->ob_spec.ciconblk->mainlist->col_mask, 8*cop_int);
		}

		strings+=strlen(strings)+1;
		ma=ma->next;
		++a;
	}
	tree[ix].ob_flags |= LASTOB;
	tree[ix-1].ob_next=ANH_FRAME;
	tree[ANH_FRAME].ob_tail=ix-1;	/* ix ist immer Icon, tail immer dessen Parent */
	return(tree);
}

/* -------------------- */

void call_entry(int ix)
{
	int	 ob,a;

	ob=ix*2+A_STR;
	if(anh_win.dinfo->tree[ob].ob_state & SELECTED) return;
	
	a=ANH_FRAME;
	while(!(anh_win.dinfo->tree[a].ob_flags & LASTOB))
	{
		++a;
		if(anh_win.dinfo->tree[a].ob_state & SELECTED)
		{
			anh_win.dinfo->tree[a].ob_state &= (~SELECTED);
			w_objc_draw(&anh_win, a, 8, sx,sy,sw,sh);
		}
		if(a==ob)
		{
			anh_win.dinfo->tree[a].ob_state |=SELECTED;
			w_objc_draw(&anh_win, a, 8, sx,sy,sw,sh);
		}
	}	
	a_sel=a_off+ix;
}

/* -------------------- */

void desk_action(int mx, int my, int ix)
{
	MAIL_ATX *atx=loadm.first;
	int evt, dum, cnt;

	pbuf[0]=AV_WHAT_IZIT;
	pbuf[1]=ap_id;
	pbuf[2]=0;
	pbuf[3]=mx;
	pbuf[4]=my;
	appl_write(avs_id, 16, pbuf);

	cnt=0;
	do
	{
    evt=evnt_multi(MU_MESAG|MU_TIMER, 
                0,0,0,0,0,0,0,0,0,0,0,0,0,  
                pbuf,100,0,&dum,&dum,&dum,&dum,&dum,&dum); 
     if(evt & MU_MESAG)
     {
     	if(pbuf[0]==VA_THAT_IZIT)
     	{/* Auf Mll? */
     		if(pbuf[4]>2)
     		{
     			while(atx && ix--) atx=atx->next;
     			if(!atx) return;
     			pbuf[0]=AV_DRAG_ON_WINDOW;
    			pbuf[1]=ap_id;
    			pbuf[2]=0;
    			pbuf[3]=mx; pbuf[4]=my;
    			pbuf[5]=(int)Kbshift(-1);
    			if( (*(char**)(&(pbuf[6]))=make_quote(p_extract_atx(atx, 2)))[0]==0) return;
     			appl_write(avs_id, 16, pbuf);
     		}
     		else Bell();
     		return;
     	}
     	else
     		w_dispatch(pbuf);
     }
     else ++cnt;
	}while(cnt < 30);	/* Max 3 Sekunden */
	Bell();
}

/* -------------------- */

void drop_entry(int ix)
{
	MAIL_ATX	*atx=loadm.first;
	int		mx, my, dum, wh, owner, tix;
		
	graf_mkstate(&mx, &my, &dum, &dum);
	
	wh=wind_find(mx, my);
	
	/* In eigenes Fenster gezogen? */
	if(wh==anh_win.whandle) return;

	wnd_get(wh, WF_OWNER, &owner, &dum, &dum, &dum);
	/* Auf Desktop gezogen? */
	if(owner==avs_id) {desk_action(mx, my, ix+a_off); return;}
	
	/* Anderes Fenster */
	tix=a_off+ix; while(tix--) atx=atx->next;
	if(!atx) return;
	pbuf[0]=VA_DRAGACCWIND;
	pbuf[1]=ap_id;
	pbuf[2]=0;
	pbuf[3]=wh;
	pbuf[4]=mx;
	pbuf[5]=my;
	if( (*(char**)(&(pbuf[6]))=make_quote(p_extract_atx(atx, 2)))[0]==0) return;
	appl_write(owner, 16, pbuf);
}

/* -------------------- */

void screen_buf(int mode, int x, int y, int w, int h)
{
	static long *adr;
	static int init=0, planes;
	unsigned int hi, lo, dum;
	MFDB src, des;
	int	pxy[8];
	
	if(!init)
	{
		wind_get(0,WF_SCREEN,(int*)&hi, (int*)&lo,(int*)&dum,(int*)&dum);
		adr=(long*)(65536l*(unsigned long)hi+(unsigned long)lo);
		vq_extnd(handle, 1, work_out);
		planes=work_out[4];
		init=1;
	}

	if (mode == FMD_START)
	{
		src.fd_addr=NULL;
		src.fd_stand=0;
		des.fd_addr=adr;
		pxy[0]=x;
		pxy[1]=y;
		pxy[2]=x+w-1;
		pxy[3]=y+h-1;
		pxy[4]=0;
		pxy[5]=64;
		pxy[6]=w-1;
		pxy[7]=64+h-1;

		des.fd_w=w;
		des.fd_h=h+64;
		des.fd_wdwidth=(w+15)>>4;
		des.fd_stand=0;
		des.fd_nplanes=planes;
	}
	else if (mode == FMD_FINISH)
	{
		src.fd_addr=adr;
		des.fd_stand=0;
		des.fd_addr=NULL;
		pxy[4]=x;
		pxy[5]=y;
		pxy[6]=x+w-1;
		pxy[7]=y+h-1;

		pxy[0]=0;
		pxy[1]=64;
		pxy[2]=w-1;
		pxy[3]=64+h-1;

		src.fd_w=w;
		src.fd_h=h+64;
		src.fd_wdwidth=(w+15)>>4;
		src.fd_stand=0;
		src.fd_nplanes=planes;
	}
	graf_mouse(M_OFF,NULL);	
	vro_cpyfm(handle, 3, pxy, &src, &des);
	graf_mouse(M_ON,NULL);	
}

/* -------------------- */
char *no_space(char *c)
{
	while(*c==' ') ++c;
	return(c);
}

void drag_entry(int ix)
{
	OBJECT	*dd;
	int mx, my, ox, oy, obx, oby, ofx, ofy, mb, dum, tx_off;

	evnt_timer(100,0);	
	graf_mkstate(&mx, &my, &mb, &dum);
	call_entry(ix);
	if(!(mb & 3)) return;

	rsrc_gaddr(0, DRAG, &dd);
	tx_off=dd[3].ob_width+dd[3].ob_width/2;
	dd[1].ob_width=aes_pixwidth(anh_win.dinfo->tree[A_STR+ix*2].ob_spec.tedinfo->te_ptext);
	dd[1].ob_height=dd[3].ob_height;
	dd[1].ob_spec.tedinfo->te_ptext=no_space(anh_win.dinfo->tree[A_STR+ix*2].ob_spec.tedinfo->te_ptext);
	dd[2].ob_width=dd[1].ob_width;
	dd[2].ob_height=dd[1].ob_height;
	dd[1].ob_x=tx_off; dd[1].ob_y=0;
	dd[2].ob_x=-1; dd[2].ob_y=-1;
	dd[3].ob_x=dd[3].ob_y=0;
	dd[2].ob_spec.free_string=no_space(anh_win.dinfo->tree[A_STR+ix*2].ob_spec.tedinfo->te_ptext);
	dd[3].ob_spec.iconblk=anh_win.dinfo->tree[A_ICO+ix*2].ob_spec.iconblk;
	
	wind_update(BEG_UPDATE);	
	wind_update(BEG_MCTRL);	
	graf_mouse(FLAT_HAND, NULL);

	ox=oy=-1;
	objc_offset(anh_win.dinfo->tree, A_STR+ix*2, &obx, &oby);
	if(obx < sx) obx=sx; if(oby < sy) oby=sy;
	if(obx + dd[1].ob_width + tx_off > sx+sw) obx=sx+sw-dd[1].ob_width-tx_off;
	if(oby + dd[1].ob_height > sy+sh) oby=sy+sh-dd[1].ob_height;
	ofx=mx-obx;
	ofy=my-oby;	
	dd[0].ob_x=obx; dd[0].ob_y=oby;
	screen_buf(FMD_START, obx-1, oby-1, dd[1].ob_width+tx_off+2, dd[1].ob_height+2);
	objc_draw(dd, 1, 2, sx ,sy, sw, sh);
	objc_draw(dd, 3, 2, sx ,sy, sw, sh);
	while(mb & 3)
	{
		graf_mkstate(&mx, &my, &mb, &dum);
		mx-=ofx; my-=ofy;
		if((mx != ox)||(my!=oy))
		{
			ox=mx; oy=my;
			screen_buf(FMD_FINISH, obx-1, oby-1, dd[1].ob_width+tx_off+2, dd[1].ob_height+2);
			obx=mx; oby=my;
			if(obx < sx) obx=sx; if(oby < sy) oby=sy;
			if(obx + dd[1].ob_width > sx+sw) obx=sx+sw-dd[1].ob_width;
			if(oby + dd[1].ob_height > sy+sh) oby=sy+sh-dd[1].ob_height;
			dd[0].ob_x=obx; dd[0].ob_y=oby;
			screen_buf(FMD_START, obx-1, oby-1, dd[1].ob_width+tx_off+2, dd[1].ob_height+2);
			objc_draw(dd, 1, 2, sx ,sy, sw, sh);
			objc_draw(dd, 3, 2, sx ,sy, sw, sh);
		}
	}
	screen_buf(FMD_FINISH, obx-1, oby-1, dd[1].ob_width+tx_off+2, dd[1].ob_height+2);

	graf_mouse(ARROW, NULL);
	wind_update(END_MCTRL);	
	wind_update(END_UPDATE);	
	
	drop_entry(ix);
}

/* -------------------- */

int gemscript_init(void)
{	
	int count=0;
	
	pbuf[0]=GS_REQUEST;
	pbuf[1]=ap_id;
	pbuf[2]=0;
	*(GS_INFO**)(&(pbuf[3]))=&ap_gi;
	pbuf[5]=pbuf[6]=0;
	pbuf[7]=GS_ID;
	appl_write(0, 16, pbuf);

	/* 5 Sekunden warten */
	do
	{
		++count;
		if(count== 100) return(0);
		evnt_timer(50,0);
		appl_read(-1, 16, pbuf);	
	}while(pbuf[0]!=GS_REPLY);
	if(pbuf[6]!=0) return(0);	
	return(1);
}

/* -------------------- */

OBJECT *gs_geticon(char *name)
{
	typedef struct
	{
		int		ob_type;
		void	*iconblk;
		char	c;
	}GS_GETICON;
	GS_GETICON	*gsi;
	OBJECT	ob, *rob;
	CICONBLK	ib;
	CICON			ci, *sci;
	int	ibuf[2*16+8*16], *src, *dst, cop_x, cop_y, cop_int;
	char	cmd[128];
	int		count=0;

	ob.ob_spec.ciconblk=&ib;
	ib.mainlist=&ci;
	ib.monoblk.ib_pmask=ibuf;
	ib.monoblk.ib_pdata=&(ibuf[16]);
	ci.num_planes=4;
	ci.col_data=&(ibuf[32]);
	ci.col_mask=&(ibuf[32+4*16]);
	ci.sel_data=ci.sel_mask=NULL;
	ci.next_res=NULL;
	
	memcpy(cmd, "GetIcon\0-m\0", 11);
	strcpy(&(cmd[11]), name);
	cmd[11+strlen(name)+1]=0;

	pbuf[0]=GS_COMMAND;
	pbuf[1]=ap_id;
	pbuf[2]=0;
	*(char**)(&(pbuf[3]))=cmd;
	pbuf[5]=pbuf[6]=0;
	pbuf[7]=GS_ID;
	appl_write(0, 16, pbuf);
	/* 200 ms Sekunden warten */
	do
	{
		++count;
		if(count== 10) return(NULL);
		evnt_timer(20,0);
		appl_read(-1, 16, pbuf);	
		if(pbuf[0]!=GS_ACK) appl_write(ap_id, 16, pbuf);
	}while(pbuf[0]!=GS_ACK);
	if(pbuf[7]!=GSACK_OK) {rob=NULL;}
	else if((pbuf[5]==0) && (pbuf[6]==0)) {rob=NULL;}
	else
	{
		gsi=(GS_GETICON*)atol(*(char**)(&(pbuf[5])));
		if(gsi==NULL) {rob=NULL;}
		else if( (((ICONBLK*)(gsi->iconblk))->ib_wicon > 16)||
						 (((ICONBLK*)(gsi->iconblk))->ib_hicon > 16)) {rob=NULL;}
		else
		{
			rob=&ob;
			ob.ob_type=gsi->ob_type;
			cop_x=ib.monoblk.ib_wicon=((ICONBLK*)(gsi->iconblk))->ib_wicon;
			cop_y=ib.monoblk.ib_hicon=((ICONBLK*)(gsi->iconblk))->ib_hicon;
			cop_int=cop_x*cop_y/16;
			dst=ob.ob_spec.iconblk->ib_pmask;
			src=((ICONBLK*)(gsi->iconblk))->ib_pmask;
			memcpy(dst, src, cop_int*2);
			dst=ob.ob_spec.iconblk->ib_pdata;
			src=((ICONBLK*)(gsi->iconblk))->ib_pdata;
			memcpy(dst, src, cop_int*2);

			if(ob.ob_type==G_CICON)
			{
				sci=((CICONBLK*)(gsi->iconblk))->mainlist;
				while(sci && (sci->num_planes != 4)) sci=sci->next_res;
				if(sci==NULL) ob.ob_type=G_ICON;
				else
				{
					dst=ob.ob_spec.ciconblk->mainlist->col_data;
					src=sci->col_data;
					memcpy(dst, src, cop_int*8);
					dst=ob.ob_spec.ciconblk->mainlist->col_mask;
					src=sci->col_mask;
					memcpy(dst, src, cop_int*8);
				}
			}
		}
	}
	if(pbuf[5] || pbuf[6])
	{
		pbuf[1]=ap_id;
		pbuf[2]=pbuf[3]=pbuf[4]=pbuf[7]=0;
		appl_write(0, 16, pbuf);
	}
	return(rob);
}

void set_anh_slide(void)
{
	long	t, l, llines=count_atx(loadm.first), lloff=a_off;

	if(!loaded) goto _m_full_slide;
	if(llines==0) goto _m_full_slide;
	/* Ggf. Listenoffset korrigieren */
	l=anh_win.dinfo->tree[ANH_FRAME].ob_height/(anh_win.dinfo->tree[IASHOW].ob_height+2);	/* Sichtbare Zeilen */
	if(lloff+l > llines)	lloff=llines-l;
	if(lloff < 0) 				lloff=0;
	a_off=(int)lloff;
	
	if(llines <= l)
	{
_m_full_slide:
		anh_win.vpos=0;
		anh_win.vsiz=1000;
		w_set(&anh_win, VSLIDE);
		return;
	}

	/* Slidergr”že */
	t=(long)llines*(long)(anh_win.dinfo->tree[IASHOW].ob_height+2);	/* Gesamte Liste in Pixeln */
	anh_win.vsiz=(int)(((long)1000*(long)(anh_win.dinfo->tree[ANH_FRAME].ob_height))/t);
	
	/* Sliderpos. */
	anh_win.vpos=(int)((long)(1000*lloff) / (long)(llines-l));
	w_set(&anh_win, VSLIDE);
}

void	anh_sized(WINDOW *win, int *pbuf)
{
	int dum, aw, ah, a;
	OBJECT *tree=win->dinfo->tree, *src;
	
	rsrc_gaddr(0, L_ANHANG, &src);

	if(win != &anh_win) return;
	
	/* pbuf[6]=Breite, pbuf[7]=H”he */
	wind_calc(WC_WORK, win->kind, win->wx, win->wy, pbuf[6], pbuf[7], &dum, &dum, &aw, &ah);

	ah-=tree[ANH_FRAME].ob_y+tree[ANH_FRAME].ob_x;
	ah/=tree[IASHOW].ob_height+2;
	ah*=tree[IASHOW].ob_height+2;
	ah+=tree[ANH_FRAME].ob_y+tree[ANH_FRAME].ob_x;
	if(aw < tree[IASHOW].ob_x+tree[IASAVE].ob_x+tree[IASAVE].ob_width)
		aw=tree[IASHOW].ob_x+tree[IASAVE].ob_x+tree[IASAVE].ob_width;
	if(ah < tree[ANH_FRAME].ob_y+tree[ANH_FRAME].ob_x+2*(tree[IASHOW].ob_height+2))
		ah=tree[ANH_FRAME].ob_y+tree[ANH_FRAME].ob_x+2*(tree[IASHOW].ob_height+2);
	
	src[0].ob_width=tree[0].ob_width=aw;
	src[0].ob_height=tree[0].ob_height=ah;
	src[ANH_FRAME].ob_width=tree[ANH_FRAME].ob_width=aw-2*tree[ANH_FRAME].ob_x;
	src[ANH_FRAME].ob_height=tree[ANH_FRAME].ob_height=ah-tree[ANH_FRAME].ob_y-tree[ANH_FRAME].ob_x;
	a=ANH_FRAME;
	while(!(tree[a].ob_flags & LASTOB))
	{
		++a;
		tree[a].ob_width=tree[ANH_FRAME].ob_width;
		++a;
	}

	set_anh_slide();
	w_calc(win);
	win->aw=aw;
	win->ah=ah;
	w_wcalc(win);
	w_set(win, CURR);

	free(win->dinfo->tree);
	win->dinfo->tree=create_anhang_rsc(loadm.first);
	s_redraw(win);
}

void	anh_arrowed(WINDOW *win, int *pbuf)
{
	int	oloff=a_off, lloff=oloff;
	int	psize=anh_win.dinfo->tree[ANH_FRAME].ob_height/(anh_win.dinfo->tree[IASHOW].ob_height+2);
	
	switch(pbuf[4])
	{
		case WA_UPPAGE:	lloff-=psize;	break;
		case WA_DNPAGE: lloff+=psize; break;
		case WA_UPLINE:	--lloff; break;
		case WA_DNLINE:	++lloff; break;
	}
	if(lloff < 0) lloff=0;
	a_off=lloff;
	set_anh_slide();
	if(a_off == oloff) return;

	free(win->dinfo->tree);
	win->dinfo->tree=create_anhang_rsc(loadm.first);
	s_redraw(win);
}

void	anh_vslid(WINDOW *win, int *pbuf)
{
	long	l, off, llines=count_atx(loadm.first), lloff=a_off;
	
	/* Neuen Offset ausrechnen */
	l=anh_win.dinfo->tree[ANH_FRAME].ob_height/(anh_win.dinfo->tree[IASHOW].ob_height+2);		/* Sichtbare Zeilen */
	off=(int)(((long)(pbuf[4])*(llines-l))/(long)1000);
	if(off!=lloff)
	{
		a_off=(int)off;
		set_anh_slide();
		free(win->dinfo->tree);
		win->dinfo->tree=create_anhang_rsc(loadm.first);
		s_redraw(win);
	}	
}

void	anh_fulled(WINDOW *win)
{
	int wx=win->wx,wy=win->wy,ww=win->ww,wh=win->wh;
	OBJECT *tree=win->dinfo->tree;
	
	if(loaded==NULL) return;
	w_get(win);
	win->aw=maxwidth(loadm.first)+2*tree[ANH_FRAME].ob_x;
	win->ah=count_atx(loadm.first)*(tree[IASHOW].ob_height+2)+tree[ANH_FRAME].ob_x+tree[ANH_FRAME].ob_y;
	if(win->aw < tree[IASHOW].ob_x+tree[IASAVE].ob_x+tree[IASAVE].ob_width)
		win->aw=tree[IASHOW].ob_x+tree[IASAVE].ob_x+tree[IASAVE].ob_width;
	win->ah-=tree[ANH_FRAME].ob_y+tree[ANH_FRAME].ob_x;
	win->ah/=tree[IASHOW].ob_height+2;
	win->ah*=tree[IASHOW].ob_height+2;
	win->ah+=tree[ANH_FRAME].ob_y+tree[ANH_FRAME].ob_x;
	if(win->ah < tree[ANH_FRAME].ob_y+tree[ANH_FRAME].ob_x+2*(tree[IASHOW].ob_height+2))
		win->ah=tree[ANH_FRAME].ob_y+tree[ANH_FRAME].ob_x+2*(tree[IASHOW].ob_height+2);
	w_wcalc(win);
	
	if(win->wx+win->ww > sx+sw)
	{
		win->wx=sx+sw-win->ww;
		if(win->wx < sx) {win->wx=sx; win->ww=sw;}
	}
	if(win->wy+win->wh > sy+sh)
	{
		win->wy=sy+sh-win->wh;
		if(win->wy < sy) {win->wy=sy; win->wh=sh;}
	}
	
	if((win->wx==wx)&&(win->wy==wy)&&(win->ww==ww)&&(win->wh==wh))
	{
		wind_get(win->whandle, WF_PREVXYWH, &wx, &wy, &ww, &wh);
		if((wx==win->wx)&&(wy==win->wy))
		{
			win->ww=ww; win->wh=wh;
		}
		else return;
	}

	w_calc(win);
	win->dinfo->tree[0].ob_x=win->ax+win->dinfo->xdif;
	win->dinfo->tree[0].ob_y=win->ay+win->dinfo->ydif;

	pbuf[6]=win->ww; pbuf[7]=win->wh;
	anh_sized(win, pbuf);
}

void anh_closed(WINDOW *win)
{
	w_get(win);
	ios.anh_wx=win->wx; ios.anh_wy=win->wy;
	ios.anh_ww=win->dinfo->tree[0].ob_width;
	ios.anh_wh=win->dinfo->tree[0].ob_height;
	ios.anh_open=0;
	w_close(win);
	w_kill(win);
	free(win->dinfo->tree);
}

void do_anhang(int ob)
{
	MAIL_ATX *atx=loadm.first;
	int	 a;

	switch(ob)
	{
		case 0:
			w_top(&anh_win);
		break;
		case IASAVE:
			if(a_sel < 0) return;
			a=a_sel;
			while(atx && a--) atx=atx->next;
			if(!atx) return;
			extract_atx(atx, 0);
		break;
		case IASHOW:
			if(a_sel < 0) return;
			a=a_sel;
			while(atx && a--) atx=atx->next;
			if(!atx) return;
			extract_atx(atx, 1);
		break;
	}
	
	if(ob > ANH_FRAME)
	{
		drag_entry((ob-A_STR)/2);
		return;
	}

	if(ob==ANH_FRAME)
	{
		if(a_sel < 0) {w_top(&anh_win); return;}
		
		a=ANH_FRAME;
		while(!(anh_win.dinfo->tree[a].ob_flags & LASTOB))
		{
			++a;
			if(anh_win.dinfo->tree[a].ob_state & SELECTED)
			{
				anh_win.dinfo->tree[a].ob_state &= (~SELECTED);
				w_objc_draw(&anh_win, a, 8, sx,sy,sw,sh);
			}
		}	
		a_sel=-1;
	}
}

void do_anh_double(int ob)
{
	MAIL_ATX *atx=loadm.first;
	
	if(loaded==NULL) return;
	if(ob < A_STR) return;
	ob=(ob-A_STR)/2;
	call_entry(ob);
	ob=ob+a_off;
	while(atx && ob--) atx=atx->next;
	if(!atx) return;
	extract_atx(atx, 1);
}

void anhang_win(void)
{
	OBJECT *tree;
	WINDOW *win=&anh_win;
	DINFO		*dinf=&anh_dinf;

	ios.anh_open=1;

	if(ios.anh_wy > -1)
	{
		if(ios.anh_wx+ios.anh_ww > sx+sw)
			ios.anh_wx=sx+sw-ios.anh_ww;
		if(ios.anh_wx+ios.anh_ww > sx+sw)
			ios.anh_ww=sw-sx;
		if(ios.anh_wy+ios.anh_wh > sy+sh)
			ios.anh_wy=sy+sh-ios.anh_wh;
		if(ios.anh_wy+ios.anh_wh > sy+sh)
			ios.anh_wh=sh-sy;
	}
	
	a_sel=-1;
	if(win->open) 
	{
		a_off=0;
		free(win->dinfo->tree);
		win->dinfo->tree=create_anhang_rsc(loadm.first);
		if(win->dinfo->tree==NULL)
		{
			Bell(); anh_closed(win); return;
		}
		set_anh_slide();
		s_redraw(win);
		return;
	}
	
	w_dinit(win);
	if(ios.anh_wy > -1)
	{
		rsrc_gaddr(0, L_ANHANG, &tree);
		tree[0].ob_width=ios.anh_ww;
		tree[0].ob_height=ios.anh_wh;
		tree[ANH_FRAME].ob_width=ios.anh_ww-2*tree[ANH_FRAME].ob_x;
		tree[ANH_FRAME].ob_height=ios.anh_wh-tree[ANH_FRAME].ob_y-tree[ANH_FRAME].ob_x;
	}
	dinf->tree=create_anhang_rsc(loadm.first);
	if(dinf->tree==NULL) return;
	dinf->support=0;
	dinf->osmax=0;
	dinf->odmax=8;
	win->dinfo=dinf;
	w_kdial(win, D_CENTER, CLOSE|MOVE|NAME|FULL|VSLIDE|UPARROW|DNARROW|SIZE);
	win->closed=anh_closed;
	win->arrowed=anh_arrowed;
	win->vslid=anh_vslid;
	win->fulled=anh_fulled;
	win->sized=anh_sized;
	dinf->dservice=do_anhang;
	dinf->dedit=0;

	if(ios.anh_wy > -1)
	{	
		win->wx=ios.anh_wx; win->wy=ios.anh_wy;
	}
	w_open(win);

	wind_set(win->whandle, WF_BEVENT, 1,0,0,0);
	set_anh_slide();
}
