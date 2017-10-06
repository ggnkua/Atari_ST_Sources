
#include <time.h>
#include <string.h>
#include "proto.h"
#ifdef DEBUG
#include <stdio.h>
#endif

#ifdef __MINT_LIB__
#include <mintbind.h>
#endif

#include "image.c"

#define DEFAULT_ERR		"[1][ Zu viele DEFAULT-Schalter! | Nur ein DEFAULT-Schalter | pro Baum m”glich! ][ Ok ]"
#define INDDEFAULT_ERR	"[1][ Zu viele INDDEFAULT-Objekte! | Nur ein INDDEFAULT-Objekt | pro Baum m”glich! ][ Ok ]"
#define HELP_ERR		"[1][ Zu viele HELP-Objekte! | Nur ein HELP-Objekt | pro Baum m”glich! ][ Ok ]"
#define UNDO_ERR		"[1][ Zu viele UNDO-Objekte! | Nur ein UNDO-Objekt | pro Baum m”glich! ][ Ok ]"
#define ESC_ERR			"[1][ Zu viele ESCAPE-Objekte! | Nur ein ESCAPE-Objekt | pro Baum m”glich! ][ Ok ]"

#define CHKHOTKEY_ERR_A	"[1][ CHKHOTKEY-Fehler: | Das Text-Objekt fehlt! | (Objekt-Nummer %d) ][ Ok ]"
#define CHKHOTKEY_ERR_B "[1][ CHKHOTKEY-Fehler: | Das HOTKEY-Objekt fehlt! | (Objekt-Nummer %d) ][ Ok ]"
#define RBHOTKEY_ERR_A	"[1][ RBHOTKEY-Fehler: |  Das Text-Objekt fehlt! | (Objekt-Nummer %d) ][ Ok ]"
#define RBHOTKEY_ERR_B	"[1][ RBHOTKEY-Fehler: | Das HOTKEY-Objekt fehlt! | (Objekt-Nummer %d) ][ Ok ]"

#define HOTKEY_ERR		"[1][ HOTKEY-Fehler: | doppelter HOTKEY '%c'! | (Objekt-Nummer %d) ][ Ok ]"

const char __ident_e_gem[] = "$Id: "E_GEM" v"E_GEM_VERSION", "E_GEM_DATE" $";

int ap_id, multi, aes_version, winx, magx , mtos, mint, grhandle, x_handle;
int gr_cw, gr_ch, gr_bw, gr_bh, gr_sw, gr_sh;
int max_w, max_h, colors, colors_available, planes, bevent, bottom;
int small_font, small_font_id, ibm_font, ibm_font_id, fonts_loaded, speedo;
int search, work_out[57],ext_work_out[57];

#ifndef SMALL_NO_MENU
int menu_available;
#endif

unsigned int gemdos_version;

GRECT desk;
VRECT clip;
MFDB scr_mfdb;
OBJECT *iconified;
MFDB *screen = &scr_mfdb;
int menu_id = -1,has_3d,owner;

#ifndef SMALL_NO_MENU
OBJECT	*_menu;
#endif

int 	_opened,_ac_close,_min_timer;
char	*_win_id;

boolean _back_win,_nonsel_fly,_dial_round=TRUE,_app_mouse;
int		_up_test,_rc_handle,_untop,_ibm_hot,_small_hot;

#ifndef SMALL_EDIT
int		_ascii,_ascii_digit;
#endif
#ifndef SMALL_NO_HZ
int		_crs_hz;
#endif
#if !defined(SMALL_NO_CLIPBRD) && !defined(SMALL_EDIT)
int		_edit_clip=TRUE;
#endif

static	MITEM mitems[] = 
{{FAIL,key(0,'U'),K_CTRL,W_CLOSE,FAIL},{FAIL,key(0,'U'),K_CTRL|K_SHIFT,W_CLOSEALL,FAIL},
 {FAIL,key(0,'W'),K_CTRL,W_CYCLE,FAIL},{FAIL,key(0,'W'),K_CTRL|K_SHIFT,W_INVCYCLE,FAIL},
 {FAIL,key(0,'W'),K_CTRL|K_ALT,W_GLOBALCYCLE,FAIL},
 {FAIL,key(0x66,0),K_CTRL,W_FULL,FAIL},{FAIL,key(0x65,0),K_CTRL,W_BOTTOM,FAIL}
#ifndef SMALL_NO_ICONIFY
 ,{FAIL,key(0x39,0),K_CTRL,W_ICONIFY,FAIL},{FAIL,key(0x39,0),K_CTRL|K_SHIFT,W_ICONIFYALL,FAIL}
#endif
};
#ifndef SMALL_NO_ICONIFY
MITEM	_menu_items[9];
int		_mitems_cnt=9;
#else
MITEM	_menu_items[7];
int		_mitems_cnt=7;
#endif

MITEM	*_xmenu_items;
int		_xitems_cnt;

DIAINFO	*_dia_list[MAX_DIALS+1];
int		_dia_len,_win_len,_alert_color;

#ifndef SMALL_NO_ICONIFY
int cdecl (*_icfs)(int,...);
#endif

static char *c_arrow[] = {"\x04","\x03","\x01","\x02"},*cycle_char = "\xf0";

static int		*cycle_but,*box_on,*box_off,*radio_on,*radio_off;
static int		*arrow_up,*arrow_up_sel,*arrow_down,*arrow_down_sel;
static int		*arrow_left,*arrow_left_sel,*arrow_right,*arrow_right_sel;
static int		cycle_back,check_back,radio_back,arrow_back,gdos_fonts;
static int		gr_dcw,win_modal,toMouse,usual,draw_3d,edit_3d,indmove,actmove,indselect=1,actselect=1;
static boolean	always_keys,return_default=RETURN_DEFAULT;
#ifndef SMALL_NO_MENU
static int		menu_inst,menu_test;
#endif

#ifndef SMALL_NO_XTEXT
#define MAX_XOBJ	64

static X_TEXT xtext[MAX_XOBJ],*x_text = xtext;
static int xtext_cnt=MAX_XOBJ;
#endif

static DIAINFO *win_list[MAX_DIALS+1];
static int dial_pattern,dial_color,dial_frame,image_w,image_h,big_img;
static int hdr_bpattern = IP_SOLID,hdr_bcolor,hdr_tcolor = BLACK,hdr_fcolor = BLACK,hdr_transp=1;
static boolean hdr_set,hdr_center,hdr_frame = TRUE,hdr_small,dial_title;
static boolean menu_nice = TRUE;

static int cdecl draw_fly(PARMBLK *);
#ifndef SMALL_NO_XTEXT
static int cdecl draw_text(PARMBLK *);
#endif
static int cdecl draw_line(PARMBLK *);
static int cdecl draw_underline(PARMBLK *);
static int cdecl draw_hotkey(PARMBLK *);
static int cdecl draw_cyclebutton(PARMBLK *);
static int cdecl draw_box(PARMBLK *);
static int cdecl draw_radiobutton(PARMBLK *);
static int cdecl draw_arrows(PARMBLK *);
static int cdecl draw_menu(PARMBLK *);

static USERBLK	cycleblk = {draw_cyclebutton,1};
static USERBLK	flyblk = {draw_fly,0};
static USERBLK	hotkeyblk = {draw_hotkey,1};
static USERBLK	checkblk = {draw_box,1};
static USERBLK	rbuttblk = {draw_radiobutton,1};
static USERBLK	unlnblk = {draw_underline,0x0002l};
static USERBLK	arrows = {draw_arrows,1};
static USERBLK  menublk = {draw_menu,0};

static boolean	open_windialog(OBJECT *,DIAINFO *,char *,char *,OBJECT *,int,boolean,boolean);

static DIAINFO	*get_info(int *);
static void 	dial_center(OBJECT *,boolean,int,int);
static void 	dial_pos(OBJECT *,int,int);
static void 	find_fly(DIAINFO *);
static void 	test_inddefault(DIAINFO *);

static void 	vdi_trans(int,int,void *);
static void 	scale_img(int *,int,int,int,int,int);

static boolean	klickobj(DIAINFO *,XEVENT *,int *,int,int);
static int		key_handler(DIAINFO *,int,int,XEVENT *);
static int		objekt_handler(DIAINFO *,int,int,int,int,boolean);

static int		is_rb_chk(OBJECT *,int);

static void 	do_jump_fly(DIAINFO *,int,int);

static void 	get_image(IMAGES *,int,BUTTON *,int **,int **);
static void 	set_images(IMAGES *,int **,int **);

void header_options(boolean set,boolean center,boolean frame,boolean small,boolean transp,int tcolor,int fcolor,int bcolor,int bpattern)
{
	hdr_set = set;
	hdr_center = center;
	hdr_bpattern = bpattern & 7;
	hdr_bcolor = bcolor & 15;
	hdr_fcolor = fcolor & 15;
	hdr_tcolor = tcolor & 15;
	hdr_transp = transp ? 0 : 1;
	hdr_frame = frame;
	hdr_small = small;
}

void dial_options(boolean round,boolean niceline,boolean xobjs_norm,boolean ret,boolean back,boolean nonsel,boolean keys,boolean mouse,boolean clipboard,int hz)
{
	reg int old_back = _back_win;

	always_keys = keys;
	_dial_round = round;
	menu_nice = niceline;
	usual = xobjs_norm;
	return_default	= ret;
	_nonsel_fly = nonsel;
	toMouse = mouse;
	_back_win = ((bevent && back!=NO_BACK) || back==ALWAYS_BACK) ? 1 : 0;

#ifndef SMALL_NO_HZ
	_crs_hz = hz;
	_inform(CURSOR_INIT);
#endif
#if !defined(SMALL_NO_CLIPBRD) && !defined(SMALL_EDIT)
	_edit_clip = clipboard;
#endif

	if (_back_win!=old_back && bevent)
	{
		reg WIN **wins=_window_list,*window;

		while ((window=*wins++)!=NULL)
		#ifndef SMALL_NO_ICONIFY
			if (!win_iconified(window))
		#endif
				wind_set(window->handle,WF_BEVENT,_back_win);
	}
}

int objc_sysvar(int ob_smode,int ob_swhich,int ob_sival1,int ob_sival2,int *ob_soval1,int *ob_soval2)
{
	if (has_3d)
	{
		INTIN[0] = ob_smode;
		INTIN[1] = ob_swhich;
		INTIN[2] = ob_sival1;
		INTIN[3] = ob_sival2;
		_aes(0,0x30040300L);

		if (ob_soval1)
			*ob_soval1 = INTOUT[1];
		if (ob_soval2)
			*ob_soval2 = INTOUT[2];	
		return (INTOUT[0]);
	}
	else
		return (FALSE);
}

void dial_colors(int d_pattern,int d_color,int d_frame,int hotkey,int alert,int popup,int check,int radio,int arrow,int popup_bgrnd,int check_bgrnd,int radio_bgrnd,int arrow_bgrnd,int edit_ddd,int draw_ddd)
{
	if (d_color<0)
	{
		d_color = colors>=LWHITE ? LWHITE : WHITE;
		d_pattern = IP_SOLID;
		objc_sysvar(OB_GETVAR,BACKGRCOL,0,0,&d_color,NULL);
	}

	edit_3d = (has_3d && edit_ddd);
	draw_3d = (has_3d && draw_ddd);

	dial_color = d_color & 15;
	dial_pattern = d_pattern;
	dial_frame = d_frame & 15;

	cycleblk.ub_parm = popup;
	hotkeyblk.ub_parm = hotkey;
	checkblk.ub_parm = check;
	rbuttblk.ub_parm = radio;
	arrows.ub_parm = arrow;

	if (!has_3d)
		d_color = WHITE;

	cycle_back = (popup_bgrnd<0) ? d_color : popup_bgrnd;
	check_back = (check_bgrnd<0) ? d_color : check_bgrnd;
	radio_back = (radio_bgrnd<0) ? d_color : radio_bgrnd;
	arrow_back = (arrow_bgrnd<0) ? d_color : arrow_bgrnd;

	_alert_color = alert;
}

void title_options(boolean title,int color,int size)
{
	dial_title	= title;
	unlnblk.ub_parm = (size<<8)|color;
}

static void get_image(IMAGES *img,int index,BUTTON *but,int **img_on,int **img_off)
{
	reg int *on = NULL,*off;

	if (index>=0 && index<img->count)
	{
		on	= img->image[index].hi_on;
		off = img->image[index].hi_off;
	}
	else if (but)
	{
		on = but->but_on;
		off = but->but_off;
	}

	if (on)
	{
		*img_on = on;
		if (img_off)
			*img_off= off;
	}
}

void radio_image(int index,BUTTON *radio)
{
	get_image(&_radios,index,radio,&radio_on,&radio_off);
}

void check_image(int index,BUTTON *check)
{
	get_image(&_checks,index,check,&box_on,&box_off);
}

void arrow_image(int index,BUTTON *down,BUTTON *up,BUTTON *left,BUTTON *right)
{
	get_image(&_arrows_left,index,left,&arrow_left_sel,&arrow_left);
	get_image(&_arrows_right,index,right,&arrow_right_sel,&arrow_right);
	get_image(&_arrows_down,index,down,&arrow_down_sel,&arrow_down);
	get_image(&_arrows_up,index,up,&arrow_up_sel,&arrow_up);
}

void cycle_image(int index,BUTTON *cycle,char c)
{
	get_image(&_cycles,index,cycle,&cycle_but,NULL);
	if (c)
		cycle_char[0] = c;
}

#undef open_rsc

boolean open_rsc(char *rscname,char *win_id,char *m_entry,char *x_name,char *a_name,int av_msgs,int va_msgs,int xacc_msgs)
{
	if (init_gem(win_id,m_entry,x_name,a_name,av_msgs,va_msgs,xacc_msgs)==TRUE)
	{
		if (rsrc_load(rscname))
		{
			reg OBJECT *obj;
			reg int index;
			OBJECT *tree=NULL;
			RSHDR *rsc=*((RSHDR **) &GLOBAL[7]);

			index = rsc->rsh_ntree;
			while (--index>=0 && rsrc_gaddr(R_TREE,index,&tree) && tree!=NULL)
			{
				for (obj=tree;;)
				{
					if (obj->ob_x==0 && obj->ob_width>max_w)
						obj->ob_width = max_w;
					if (obj->ob_flags & LASTOB)
						break;
					else
						obj++;
				}

				tree = NULL;
			}
			return(TRUE);
		}
		else
		{
			exit_gem(FALSE,0);
			return(FAIL);
		}
	}
	else
		return(FALSE);
}

void close_rsc(boolean all,int result)
{
	rsrc_free();
	exit_gem(all,result);
}

static boolean init_flag;

#undef init_gem

boolean init_gem(char *win_id,char *m_entry,char *x_name,char *a_name,int av_msgs,int va_msgs,int xacc_msgs)
{
	if (init_flag)
		return(TRUE);
#ifndef SMALL_NO_XACC_AV
	else if (x_name==NULL || a_name==NULL)
		return (FALSE);
#endif

	AES_VERSION = 0;
	if ((ap_id=appl_init())>=0 && (aes_version=AES_VERSION)>0)
	{
	#ifndef SMALL_NO_DD
		X_ATTR xattr;
	#endif
		int dummy,info1,info2;

		if (!_app)
			beg_update(FALSE,FALSE);
		grhandle = graf_handle(&gr_cw,&gr_ch,&gr_bw,&gr_bh);
		gr_dcw = gr_cw<<1;

		if (open_work(&_rc_handle,work_out) && open_work(&x_handle,work_out))
		{
			GDOS_INFO *gdos;
			int pxy[5],eff[3],d;
			long value;

			if (m_entry && *m_entry && (!_app || aes_version>=0x0400))
			{
				menu_id = menu_register(ap_id,m_entry);
				if (_app)
					menu_id = -1;
			}
			else
				menu_id = -1;

			_win_id = win_id;
			multi = (GLOBAL[1]!=1);

			max_w = work_out[0]+1;
			max_h = work_out[1]+1;
			colors = work_out[13];
			colors_available = work_out[39];

			if (get_cookie(COOKIE_FSMC,(long *) &gdos))
			{
				if (gdos->type==COOKIE_SPEEDO)
					speedo = gdos->version>=0x0500 ? 3 : 2;
				else if (gdos->type==COOKIE_FSM)
					speedo = 1;
				else
					speedo = 0;
			}

			fonts_loaded = work_out[10];
			if (vq_gdos())
				fonts_loaded += vst_load_fonts(x_handle,0);

			vq_extnd(x_handle,1,ext_work_out);
			planes = ext_work_out[4];

			vs_attr();
			vst_alignment(x_handle,0,5,&dummy,&dummy);

		#ifndef SMALL_NO_FONT
			if (!_InitFont())
			{
				if (vq_gdos())
					vst_unload_fonts(x_handle,0);
				close_work(x_handle);
				goto _init_error;
			}
		#endif

			gemdos_version = Sversion();
			gemdos_version = (gemdos_version>>8)|(gemdos_version<<8);

			if (get_cookie(COOKIE_MAGX,&value) && value!=0l)
			{
				magx = ((int **) value)[2][24];
				if (magx<0x0200)
					magx = 0;
			}

			if (get_cookie(COOKIE_MINT,&value))
				mint = (int) value;

			mtos = (aes_version>=0x0400 && multi && mint && !magx && !get_cookie(COOKIE_GENEVA,NULL));

			Pdomain(multi ? 1 : 0);

		#ifndef SMALL_NO_DD
			_dd_available = ((Dsetdrv(Dgetdrv()) & (1l<<('U'-'A'))) && Fxattr(0,"U:\\PIPE",(void *) &xattr)==0);
		#endif

			if (wind_xget(0,WF_RETURN,&dummy,&dummy,&dummy,&dummy) ||
				wind_xget(0,WF_WINX,&winx,&dummy,&dummy,&dummy)!=WF_WINX ||
				(winx&=0x0fff)<0x0210)
				winx = 0;

			appl_xgetinfo(13,&info1,&info2,&gdos_fonts,&dummy);
			has_3d = (aes_version>=0x332 && (!magx || magx>=0x0300)) || (info1 && info2);

			objc_sysvar(OB_GETVAR,LK3DIND,0,0,&indmove,&indselect);
			objc_sysvar(OB_GETVAR,LK3DACT,0,0,&actmove,&actselect);

		#ifndef SMALL_NO_ICONIFY
			appl_xgetinfo(12,&info1,&dummy,&dummy,&dummy);
			if ((info1 & 384)!=384)
				if (!get_cookie(COOKIE_ICFS,(long *) &_icfs) || _icfs==NULL)
					_icfs = _default_icfs;
		#endif
			_untop = (aes_version>=0x0330 || winx || (info1 & 6)==6);

			appl_xgetinfo(11,&info1,&dummy,&dummy,&info2);
			bottom = (aes_version>=0x0331 || winx || (info1 & 64));
			bevent = (aes_version>=0x0331 || winx || (info1 & 32));
			_up_test = (aes_version>=0x0400 || magx || info2);
			owner = (aes_version>=0x0330 || winx || (info1 & 16));
			_min_timer = (aes_version>=0x0140) ? 0 : 1;

			appl_xgetinfo(6,&dummy,&dummy,&info1,&info2);

		#ifndef SMALL_NO_MENU
			menu_available = (_app || magx);
			menu_inst = (magx || info2);
			menu_test = (aes_version>=0x0400 || info1);
		#endif

			search = (aes_version>=0x0400 || magx || (appl_xgetinfo(4,&dummy,&dummy,&info1,&dummy) && info1>0));

			appl_getfontinfo(0,&ibm_font,&ibm_font_id,&dummy);
			v_set_text(ibm_font_id,ibm_font,FAIL,0,0,NULL);
			vqt_fontinfo(x_handle,&d,&d,pxy,&d,eff);
			_ibm_hot = min(gr_ch-1,pxy[4]+1);

			appl_getfontinfo(1,&small_font,&small_font_id,&dummy);
			v_set_text(small_font_id,small_font,FAIL,FAIL,FAIL,pxy);
			gr_sw = pxy[2];
			gr_sh = pxy[3];

			vqt_fontinfo(x_handle,&d,&d,pxy,&d,eff);
			_small_hot = pxy[4]+1;

			if (gr_cw<8 || gr_ch<8)
			{
				image_w = min(gr_dcw,16);
				image_h = min(gr_ch,16);
				big_img = FAIL;
			}
			else if (gr_ch>15)
			{
				image_w = image_h = 16;
				big_img = TRUE;
			}
			else
			{
				image_w = 16;
				image_h = 8;
				big_img = FALSE;
			}

			set_images(&_radios,&radio_on,&radio_off);
			set_images(&_checks,&box_on,&box_off);
			set_images(&_arrows_left,&arrow_left_sel,&arrow_left);
			set_images(&_arrows_right,&arrow_right_sel,&arrow_right);
			set_images(&_arrows_up,&arrow_up_sel,&arrow_up);
			set_images(&_arrows_down,&arrow_down_sel,&arrow_down);
			set_images(&_cycles,&cycle_but,NULL);

			wind_xget(0,WF_WORKXYWH,&desk.g_x,&desk.g_y,&desk.g_w,&desk.g_h);
			rc_grect_to_array(&desk,(int *) &clip);

			pxy[0] = pxy[1] = 0;
			pxy[2] = max_w - 1;
			pxy[3] = max_h - 1;
			vs_clip(_rc_handle,1,pxy);

			MenuItems(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0);
			dial_colors(FAIL,FAIL,BLACK,RED,RED,BLACK,BLACK,BLACK,BLACK,FAIL,FAIL,FAIL,FAIL,TRUE,TRUE);

		#ifndef SMALL_NO_CLIPBRD
			_scrp_init();
		#endif

			_app_mouse = (magx || (appl_xgetinfo(8,&dummy,&info1,&dummy,&dummy) && info1));

			MouseArrow();
			if (aes_version>=0x0400 || (appl_xgetinfo(10,&info1,&dummy,&dummy,&dummy) && (info1 & 0xff)>=9))
				shel_write(9,0x01,0x01,NULL,NULL);

			if (!_app)
				end_update(FALSE);
			init_flag = TRUE;

		#ifndef SMALL_NO_XACC_AV
			_XAccSendStartup(x_name,a_name,av_msgs,va_msgs,xacc_msgs);
		#endif

			return(TRUE);
		}
		else
		{
		#ifndef SMALL_NO_FONT
			_init_error:
		#endif
			if (_rc_handle>0)
				close_work(_rc_handle);
			if (!_app)
				end_update(FALSE);
			if (_app)
				appl_exit();
			else
				evnt_timer(0,32000);
		}
	}

	return(FALSE);
}

#ifdef __PUREC__
int wind_xget(int w_handle, int w_field, int *w1, int *w2, int *w3,int *w4)
{
	INTIN[0] = w_handle;
	INTIN[1] = w_field;
	_aes(0,0x68020500l);

	*w1 = INTOUT[1];
	*w2 = INTOUT[2];
	*w3 = INTOUT[3];
	*w4 = INTOUT[4];

	return(INTOUT[0]);
}
#endif

int appl_search(int ap_smode,char *ap_sname,int *ap_stype,int *ap_sid)
{
	INTIN[0] = ap_smode;
	ADDRIN[0] = ap_sname;
	_aes(0,0x12010301L);

	*ap_stype = INTOUT[1];
	*ap_sid = INTOUT[2];

	return (INTOUT[0]);
}

int appl_getinfo(int ap_gtype,int *ap_gout1,int *ap_gout2,int *ap_gout3,int *ap_gout4)
{
	reg int *array;

	INTIN[0] = ap_gtype;
	_aes(0,0x82010500L);

	array = &INTOUT[5];
	*ap_gout4 = *--array;
	*ap_gout3 = *--array;
	*ap_gout2 = *--array;
	*ap_gout1 = *--array;
	return(*--array);
}

int appl_xgetinfo(int type,int *out1,int *out2,int *out3,int *out4)
{
	static int has_agi = -1;
	int back = 0;

	if (has_agi<0)
		has_agi = (aes_version>=0x400 || magx || winx || appl_find("?AGI\0\0\0\0")==0) ? 1 : 0;

	if (has_agi>0)
		back = appl_getinfo(type,out1,out2,out3,out4);

	if (back==0)
		*out1 = *out2 = *out3 = *out4 = 0;

	return (back);
}

int appl_getfontinfo(int ap_gtype,int *height,int *id,int *type)
{
	int dummy,attrib[10];

	if (appl_xgetinfo(ap_gtype,height,id,type,&dummy))
	{
		if (*id==-12124)
			*id = 1;

		return (TRUE);
	}

	vqt_attributes(grhandle,attrib);
	*id = attrib[0];

	if (ap_gtype==1)
	{
		v_set_text(*id,-1,FAIL,FAIL,FAIL,NULL);
		vqt_attributes(x_handle,attrib);
	}

	*height = attrib[7];
	*type = 0;

	return (TRUE);
}

void exit_gem(boolean all,int result)
{
	if (init_flag)
	{
	#ifndef SMALL_NO_MENU
		if (_menu)
			menu_install(_menu,FALSE);
	#endif

		close_all_windows();
	#ifndef SMALL_NO_XACC_AV
		_XAccAvExit();
	#endif

		if (vq_gdos())
			vst_unload_fonts(x_handle,0);

		close_work(x_handle);
		close_work(_rc_handle);

		if (_app)
			appl_exit();
		else if (all)
			evnt_timer(0,32000);
	}

	if (all)
		exit (result);
}

static void set_images(IMAGES *images,int **on,int **off)
{
	if (big_img!=FAIL)
	{
		reg IMAGE *im = images->image;
		reg int i;

		for (i=0;i<images->count;i++,im++)
		{
			if (big_img==FALSE)
			{
				if (im->lo_on!=NULL)
					im->hi_on = im->lo_on;
				if (im->lo_off!=NULL)
					im->hi_off = im->lo_off;

				vdi_trans(image_w,image_h,im->hi_on);
				vdi_trans(image_w,image_h,im->hi_off);

				if (im->lo_on==NULL)
					scale_img(im->hi_on,16,16,image_w,image_h,DARK_SCALING);
				if (im->lo_off==NULL)
					scale_img(im->hi_off,16,16,image_w,image_h,DARK_SCALING);
			}
			else
			{
				vdi_trans(image_w,image_h,im->hi_on);
				vdi_trans(image_w,image_h,im->hi_off);
			}
		}

		if (images->count>0)
		{
			*on = images->image->hi_on;
			if (off)
				*off = images->image->hi_off;
		}
	}
}

#define scale_coords(x,y,ow,oh)	{ x = (x*gr_cw)/ow; y = y*gr_ch/oh; }

void scale_image(OBJECT *obj,int scaling,int orig_cw,int orig_ch)
{
	reg unsigned char type = (unsigned char) obj->ob_type,ow,oh,nw,nh;

	if (type!=G_ICON && type!=G_IMAGE)
		return;

	if (orig_cw<=1)
		orig_cw = 8;

	if (orig_ch<=1)
		orig_ch = 16;

	if (scaling & TEST_SCALING)
	{
		if (orig_cw==gr_cw && orig_ch==gr_ch)
			scaling = 0;
		else
			scaling |= SCALING;
	}

	if (scaling & SCALING)
	{
		if (gr_cw>=orig_cw && gr_ch>=orig_ch)
		{
			obj->ob_x += (obj->ob_width-(nw=(obj->ob_width*orig_cw)/gr_cw))>>1;
			obj->ob_y += (obj->ob_height-(nh=(obj->ob_height*orig_ch)/gr_ch))>>1;
			obj->ob_width = nw;
			obj->ob_height = nh;
		}
		else if (type==G_ICON)
		{
			ICONBLK *icn = obj->ob_spec.iconblk;

			if (icn->ib_hicon>3)
			{
				ow = nw = icn->ib_wicon;
				oh = nh = icn->ib_hicon;

				scale_coords(icn->ib_xicon,icn->ib_yicon,orig_cw,orig_ch);
				scale_coords(nw,nh,orig_cw,orig_ch);
				icn->ib_hicon = nh;
				scale_coords(icn->ib_xtext,icn->ib_ytext,orig_cw,orig_ch);
				scale_coords(icn->ib_xchar,icn->ib_ychar,orig_cw,orig_ch);

				scale_img(icn->ib_pdata,ow,oh,nw,nh,scaling);
				scale_img(icn->ib_pmask,ow,oh,nw,nh,scaling);
			}
		}
		else
		{
			BITBLK *blk = obj->ob_spec.bitblk;

			if (blk->bi_hl>3)
			{
				ow = nw = blk->bi_wb<<3;
				oh = nh = blk->bi_hl;

				scale_coords(nw,nh,orig_cw,orig_ch);
				blk->bi_hl = nh;
				scale_coords(blk->bi_x,blk->bi_y,orig_cw,orig_ch);

				scale_img((int *) blk->bi_pdata,ow,oh,nw,nh,scaling);
			}
		}
	}

	if (type==G_ICON)
	{
		ICONBLK *icn = obj->ob_spec.iconblk;
		nw = max(max(icn->ib_xicon+icn->ib_wicon,icn->ib_xchar+gr_sw),icn->ib_xtext+gr_sw * (int) strlen(icn->ib_ptext));
		nh = max(max(icn->ib_yicon+icn->ib_hicon,icn->ib_ychar+gr_sh),icn->ib_ytext+gr_sh);
	}
	else
	{
		BITBLK *blk = obj->ob_spec.bitblk;
		nw = blk->bi_x+(blk->bi_wb<<3);
		nh = blk->bi_y+blk->bi_hl;
	}

	Max(&obj->ob_width,nw);
	Max(&obj->ob_height,nh);
}

static void scale_img(int *source,int w,int h,int n_w, int n_h, int scaling)
{
	if (source!=NULL)
	{
		reg int pxy[8],dark = (scaling & DARK_SCALING),vr_mode = (dark) ? 7 : 3;
		reg MFDB image;

		mfdb(&image,source,w,h,0,1);

		if (n_h<h)
		{
			reg int y,n_y,l_y,flag=TRUE;

			pxy[0] = pxy[4] = l_y = n_y = y = 0;
			pxy[2] = pxy[6] = w-1;

			for (;y<h;y++)
			{
				if (n_y>=h || dark || y==(h-1))
				{
					pxy[1] = pxy[3] = y;
					pxy[5] = pxy[7] = l_y;
					vro_cpyfm(x_handle,(flag) ? 3 : vr_mode,pxy,&image,&image);
					if (n_y>=h)
					{
						n_y -= h;
						l_y++;
						flag = TRUE;
					}
					else
						flag = FALSE;
				}
				n_y += n_h;
			}

			for (y=n_h-1;y<h;y++)
			{
				pxy[1] = pxy[3] = pxy[5] = pxy[7] = y;
				vro_cpyfm(x_handle,0,pxy,&image,&image);
			}
			h = n_h;
		}

		if (n_w<w)
		{
			reg int x,n_x,l_x,flag = TRUE;

			pxy[1] = pxy[5] = l_x = n_x = x = 0;
			pxy[3] = pxy[7] = h-1;

			for (;x<w;x++)
			{
				if (n_x>=w || dark || x==(w-1))
				{
					pxy[0] = pxy[2] = x;
					pxy[4] = pxy[6] = l_x;
					vro_cpyfm(x_handle,(flag) ? 3 : vr_mode,pxy,&image,&image);
					if (n_x>=w)
					{
						n_x -= w;
						l_x++;
						flag = TRUE;
					}
					else
						flag = FALSE;
				}
				n_x += n_w;
			}

			for (x=n_w-1;x<w;x++)
			{
				pxy[0] = pxy[2] = pxy[4] = pxy[6] = x;
				vro_cpyfm(x_handle,0,pxy,&image,&image);
			}
		}
	}
}

static void vdi_trans(int w,int h,void *data)
{
	if (data)
	{
		reg MFDB src,dst;

		mfdb(&src,(int *) data,w,h,1,1);
		mfdb(&dst,(int *) data,w,h,0,1);
		vr_trnfm(x_handle,&src,&dst);
	}
}

void trans_image(OBJECT *obj)
{
	if ((unsigned char) obj->ob_type==G_ICON)
	{
		reg ICONBLK *icn=obj->ob_spec.iconblk;
		vdi_trans(icn->ib_wicon,icn->ib_hicon,icn->ib_pmask);
		vdi_trans(icn->ib_wicon,icn->ib_hicon,icn->ib_pdata);
	}
	else
	{
		reg BITBLK *img=obj->ob_spec.bitblk;
		vdi_trans(img->bi_wb<<3,img->bi_hl,img->bi_pdata);
	}
}

static void vrt_copy(int *image,PARMBLK *pb,int color,int back,int selected)
{
	reg MFDB src;
	reg int pxy[8],col[2],off = (big_img==FAIL) ? 1:0;

	pxy[0] = pxy[1] = 0;
	pxy[2] = image_w - 1;
	pxy[3] = image_h - 1;
	pxy[4] = pb->pb_x + (gr_cw-(image_w>>1)) + off;
	pxy[5] = pb->pb_y + ((gr_ch-image_h)>>1) + off;
	pxy[6] = pxy[4] + pxy[2];
	pxy[7] = pxy[5] + pxy[3];

	if (selected)
	{
		col[1] = color;
		col[0] = back;
	}
	else
	{
		col[0] = color;
		col[1] = back;
	}
	mfdb(&src,image,16,image_h,0,1);
	vrt_cpyfm(x_handle,1,pxy,&src,screen,col);
}

void _get_font_size(OBJECT *obj,int *cw, int *ch,int *hy)
{
	reg TEDINFO *ted = obj->ob_spec.tedinfo;
	int pxy[6],eff[3],d;

	switch (ted->te_font)
	{
	default:
		if (gdos_fonts)
		{
			v_set_text(ted->te_fontid,-ted->te_fontsize,FAIL,0,0,pxy);
			*cw = pxy[2];
			*ch = pxy[3];
			if (hy)
			{
				vqt_fontinfo(x_handle,&d,&d,pxy,&d,eff);
				*hy = pxy[4]+1;
			}
			break;
		}
		else
			ted->te_font = IBM;
	case IBM:
		*cw = gr_cw;
		*ch = gr_ch;
		if (hy)
			*hy = _ibm_hot;
		break;
	case SMALL:
		*cw = gr_sw;
		*ch = gr_sh;
		if (hy)
			*hy = _small_hot;
		break;
	}
}

void rsrc_calc(OBJECT *tree,int scaling,int orig_cw,int orig_ch)
{
	reg OBJECT *obj;
	reg int index = 0,low_byte = 0x00ff,scale = FALSE,static_size = (scaling & STATIC_SCALING);
	int rest_x,rest_y,rest_w,rest_h;

	if (orig_cw>1 && orig_ch>1 && (orig_cw!=gr_cw || orig_ch!=gr_ch))
		for (scale=TRUE,obj=tree;;obj++)
		{
			if (obj->ob_type==G_TITLE)
			{
				scale = FALSE;
				break;
			}
			else if (obj->ob_flags & LASTOB)
				break;
		}

	for (obj=tree;;obj++,index++)
	{
		if (scale)
		{
			rest_x = *((signed char *) &obj->ob_x);
			rest_y = *((signed char *) &obj->ob_y);
			rest_w = *((signed char *) &obj->ob_width);
			rest_h = *((signed char *) &obj->ob_height);

			obj->ob_x &= low_byte;
			obj->ob_y &= low_byte;
			obj->ob_width &= low_byte;
			obj->ob_height &= low_byte;

			if (static_size)
			{
				obj->ob_x = obj->ob_x*orig_cw+rest_x;
				obj->ob_y = obj->ob_y*orig_ch+rest_y;
				obj->ob_width = obj->ob_width*orig_cw+rest_w;
				obj->ob_height = obj->ob_height*orig_ch+rest_h;
			}
			else
			{
 				rsrc_obfix(tree,index);

				if (rest_x)
					obj->ob_x += (rest_x*gr_cw)/orig_cw;
				if (rest_y)
					obj->ob_y += (rest_y*gr_ch)/orig_ch;
				if (rest_w)
					obj->ob_width += (rest_w*gr_cw)/orig_cw;
				if (rest_h)
					obj->ob_height += (rest_h*gr_ch)/orig_ch;
			}
		}
		else
			rsrc_obfix(tree,index);

		if (obj->ob_x==0 && obj->ob_width>max_w)
			obj->ob_width = max_w;

		if (obj->ob_flags & LASTOB)
			break;
	}

	if (scale && static_size)
		scaling = NO_SCALING;

	fix_objects(tree,scaling,orig_cw,orig_ch);
}

void rsrc_init(int n_tree,int n_obs,int n_frstr,int n_frimg,int scaling,char **rs_strings,long *rs_frstr,BITBLK *rs_bitblk,
			   long *rs_frimg,ICONBLK *rs_iconblk,TEDINFO *rs_tedinfo,OBJECT *rs_object,OBJECT **rs_trindex,RS_IMDOPE *rs_imdope,int orig_cw,int orig_ch)
{
	reg TEDINFO *ted;
	reg ICONBLK *icon;
	reg OBJECT *obj;
	reg BITBLK *img;
	reg char **str = rs_strings;
	reg int i,index;

	for (obj=rs_object,i=n_obs;--i>=0;obj++)
	{
		index = (int) obj->ob_spec.index;
		switch((unsigned char) obj->ob_type)
		{
		case G_TEXT:
		case G_BOXTEXT:
		case G_FTEXT:
		case G_FBOXTEXT:
			obj->ob_spec.tedinfo = ted = &rs_tedinfo[index];
			ted->te_ptext = str[(int) ted->te_ptext];
			ted->te_ptmplt = str[(int) ted->te_ptmplt];
			ted->te_pvalid = str[(int) ted->te_pvalid];
			break;
		case G_BUTTON:
		case G_STRING:
		case G_TITLE:
			obj->ob_spec.free_string = str[index];
			break;
		case G_IMAGE:
			obj->ob_spec.bitblk = img = &rs_bitblk[index];
			img->bi_pdata = (void *) rs_imdope[(int) img->bi_pdata].image;
			break;
		case G_ICON:
			obj->ob_spec.iconblk = icon = &rs_iconblk[index];
			icon->ib_pmask = rs_imdope[(int) icon->ib_pmask].image;
			icon->ib_pdata = rs_imdope[(int) icon->ib_pdata].image;
			icon->ib_ptext = str[(int) icon->ib_ptext];
		}
	}

	for (i=n_frstr;--i>=0;)
		rs_frstr[i] = (long) str[(int) rs_frstr[i]];

	for (i=n_frimg;--i>=0;)
	{
		rs_frimg[i] = (long) (img = &rs_bitblk[(int) rs_frimg[i]]);
		img->bi_pdata = (void *) rs_imdope[(int) img->bi_pdata].image;
	}

	for (i=n_tree;--i>=0;)
		rsrc_calc(rs_trindex[i]=&rs_object[(int) rs_trindex[i]],scaling,orig_cw,orig_ch);
}

void fix_objects(OBJECT *tree,int scaling,int orig_cw,int orig_ch)
{
	reg OBJECT *par,*org=tree;
	reg int type,xtype,modal,i,index;
	int d,h,yo;

	for (index=0;;tree++,index++)
	{
		switch (type=(unsigned char) tree->ob_type)
		{
		case G_ICON:
		case G_IMAGE:
			trans_image(tree);
			scale_image(tree,scaling,orig_cw,orig_ch);
			break;
		default:
			{
				modal = tree->ob_type & (G_MODAL|G_UNMODAL);
				xtype = (tree->ob_type & G_TYPE)>>8;

				switch (xtype)
				{
				case HEADER:
				case FIX_HEADER:
					par = &org[ob_get_parent(org,index)];
					i = par->ob_spec.obspec.framesize;
					tree->ob_type = (FIX_HEADER<<8)|type;
					tree->ob_y -= (tree->ob_height>>1) + (1 - i);
					if (i<0)
						tree->ob_y++;
					if (par->ob_state & OUTLINED)
						tree->ob_y--;
					break;
				case CHECKBOX:
				case CHKHOTKEY:
					tree->ob_type = (xtype==CHKHOTKEY) ? G_CHK : G_USERDEF;
					tree->ob_spec.userblk = &checkblk;
					break;
				case UNDERLINE:
					tree->ob_type = G_USERDEF;
					tree->ob_state &= 0x00ff;
					tree->ob_state |= tree->ob_spec.obspec.framesize<<8;
					tree->ob_spec.userblk = &unlnblk;
					tree->ob_height = 1;
					break;
				case CYCLE_BUTTON:
					tree->ob_type = G_USERDEF;
					tree->ob_spec.userblk = &cycleblk;
					tree->ob_x--;
					tree->ob_y--;
					tree->ob_width = gr_dcw + 4;
					tree->ob_height = gr_ch + 4;
					break;
				case RADIO:
				case RBHOTKEY:
					tree->ob_type = (xtype==RBHOTKEY) ? G_RB : G_USERDEF;
					tree->ob_spec.userblk = &rbuttblk;
					break;
				case ARROW_LEFT:
				case ARROW_RIGHT:
				case ARROW_DOWN:
				case ARROW_UP:
					tree->ob_spec.userblk = &arrows;
					tree->ob_type = (xtype<<8)|G_USERDEF;
					break;
				case HOTKEY:
				case INDHOTKEY:
					par = &org[ob_get_parent(org,index)];
					h = gr_ch;

					switch ((unsigned char) par->ob_type)
					{
					case G_BOXTEXT:
					case G_FBOXTEXT:
						_get_font_size(par,&d,&h,&yo);break;
					case G_BUTTON:
					case G_BOXCHAR:
						yo = _ibm_hot;break;
					default:
						yo = 0;
					}

					if (yo)
					{
						yo = max(yo+3,h);
						if ((yo-=par->ob_height)>0)
						{
							par->ob_y -= yo;
							par->ob_height += yo<<1;
						}
					}

					tree->ob_type = (xtype==INDHOTKEY) ? G_IND : G_HOTKEY;
					tree->ob_height = 1;
					_set_hotkey(tree,par,tree->ob_spec.obspec.character);
					tree->ob_spec.userblk = &hotkeyblk;
					break;
				case FLYDIAL:
					tree->ob_spec.userblk = &flyblk;
					tree->ob_type = G_FLY;
					tree->ob_x = org->ob_width - gr_dcw - 1;
					tree->ob_y = -3;
					tree->ob_width = gr_dcw + 4;
					tree->ob_height = gr_ch + 4;
					break;
			#ifndef SMALL_NO_XTEXT
				case ATTR_TEXT:
					{
						reg char *string = NULL;
						reg TEDINFO *ted;
						reg int font_id,font_size,color,center,mode;

						switch ((unsigned char) tree->ob_type)
						{
						case G_TITLE:
						case G_BUTTON:
						case G_STRING:
							string = tree->ob_spec.free_string;
							color = BLACK;
							font_id = ibm_font_id;
							font_size = ibm_font;
							center = 0;
							mode = MD_TRANS;
							break;
						case G_FTEXT:
						case G_FBOXTEXT:
						case G_TEXT:
						case G_BOXTEXT:
							ted = tree->ob_spec.tedinfo;
							switch (ted->te_font)
							{
							case SMALL:
								font_id = small_font_id;
								font_size = small_font;
								break;
							case IBM:
								font_id = ibm_font_id;
								font_size = ibm_font;
								break;
							default:
								font_id = ted->te_fontid;
								font_size = -ted->te_fontsize;
							}

							string = ted->te_ptext;
							color = (ted->te_color>>8) & 15;
							mode = (ted->te_color & 128) ? MD_REPLACE : MD_TRANS;
							center = ted->te_just;
						}

						if (string)
						{
							if (xtext_cnt<=0)
							{
								x_text = (X_TEXT *) calloc(MAX_XOBJ,sizeof(X_TEXT));
								xtext_cnt = (x_text==NULL) ? -1 : MAX_XOBJ;
							}

							if (--xtext_cnt>=0)
							{
								reg int effect = 0,state = tree->ob_state;

								x_text->text_blk.ub_code = draw_text;
								x_text->text_blk.ub_parm = (long) x_text;

								if (state & SELECTED)
									effect |= X_FAT;
								if (state & CHECKED)
									effect |= X_UNDERLINED;
								if (state & CROSSED)
									effect |= X_ITALICS;
								if (state & DISABLED)
									effect |= X_LIGHT;
								if (state & OUTLINED)
									effect |= X_OUTLINED;
								if (state & SHADOWED)
									effect |= X_SHADOWED;
								if (state & DRAW3D)
									effect |= X_3D;
								if (state & WHITEBAK)
									effect |= X_TITLE;

								x_text->font_id	= font_id;
								x_text->font_size = font_size;
								x_text->color = color;
								x_text->center = center;
								x_text->mode = mode;
								x_text->effect = effect;
								x_text->string = string;

								tree->ob_type = G_XTEXT;
								tree->ob_flags &= ~EDITABLE;
								tree->ob_state = NORMAL;
								tree->ob_spec.userblk = &x_text->text_blk;
								x_text++;
							}
						}
					}
					break;
			#endif
				default:
					if (tree->ob_type==G_STRING && (tree->ob_state & DISABLED) && tree->ob_spec.free_string[0]=='-')
					{
						tree->ob_type = G_USERDEF;
						tree->ob_spec.userblk = &menublk;
					}
				}
				tree->ob_type |= modal;
			}
		}
		if (tree->ob_flags & LASTOB)
			break;
	}
}

static void find_fly(DIAINFO *info)
{
	reg OBJECT *tree=info->di_tree;
	reg int type;

	info->di_fly = FALSE;
	do
	{
		tree++;
		type = tree->ob_type & G_TYPE;
		if (type==G_FLY || (type>>8)==USERFLY)
		{
			tree->ob_state &= ~DISABLED;
			tree->ob_flags &= ~HIDETREE;

			switch (info->di_flag)
			{
			case OPENED:
				tree->ob_state |= DISABLED;
				break;
			case WINDOW:
			case WIN_MODAL:
				tree->ob_flags |= HIDETREE;
				break;
			case FLYING:
				info->di_fly = TRUE;
				break;
			}
		}
	}
	while (!(tree->ob_flags & LASTOB));
}

static void dial_center(OBJECT *tree,boolean center,int xy,int wh)
{
	INFOVSCR *vscr;
	int x,y,w,h;

	switch (center)
	{
	case DIA_MOUSEPOS:
		mouse(&x,&y);
		tree->ob_x = x - (tree->ob_width>>1);
		tree->ob_y = y - (tree->ob_height>>1);
		break;
	case DIA_LASTPOS:
		Min(&tree->ob_x,clip.v_x2-tree->ob_width);
		Min(&tree->ob_y,clip.v_y2-tree->ob_height);
		if (rc_inside(tree->ob_x,tree->ob_y,&desk))
			break;
	default:
		form_center(tree,&x,&y,&w,&h);
		if (get_cookie(COOKIE_VSCR,(long *) &vscr) && vscr->cookie==COOKIE_VSCR)
		{
			tree->ob_x = vscr->x + ((vscr->w - w)>>1);
			tree->ob_y = vscr->y + ((vscr->h - h)>>1);
		}
	}
	dial_pos(tree,xy,wh);
}

static void dial_pos(OBJECT *tree,int xy,int wh)
{
	reg int d;

	if ((d=(tree->ob_x+tree->ob_width+wh))>=max_w)
		tree->ob_x -= d - max_w;

	if (_dial_round)
	{
		tree->ob_x &= 0xFFF8;
		if (tree->ob_x<(desk.g_x+xy))
			tree->ob_x = (desk.g_x+xy+7) & 0xFFF8;
	}
	else
		Max(&tree->ob_x,desk.g_x+xy);

	if ((d=(tree->ob_y+tree->ob_height+wh))>=max_h)
		tree->ob_y -= d - max_h;
	Max(&tree->ob_y,desk.g_y+xy);
}

static WIN fly;

static boolean open_flydialog(OBJECT *tree, DIAINFO *info, boolean center,boolean box)
{
	if (_dia_len<MAX_DIALS && (_dia_len==0 || _dia_list[_dia_len-1]->di_flag!=OPENED))
	{
		beg_ctrl(FALSE,FALSE,FALSE);
		
		dial_center(tree,center,4,4);
		_rc_sc_savetree(tree,&info->di_rc);

		if (info->di_rc.valid)
			info->di_flag = FLYING;
		else
		{
			info->di_flag = OPENED;
			form_dial(FMD_START,0,0,0,0,tree->ob_x-3,tree->ob_y-3,tree->ob_width+6,tree->ob_height+6);
		}

		info->di_tree = tree;
		info->di_win = &fly;
		fly.handle = -1;

		find_fly(info);

		if (box)
			graf_growbox (max_w>>1,max_h>>1,1,1,tree->ob_x,tree->ob_y,tree->ob_width,tree->ob_height);
		_dia_list[_dia_len++] = info;

		_inform(MOUSE_INIT);

		return (TRUE);
	}
	else
		return (FALSE);
}

int close_dialog(DIAINFO *info,boolean box)
{
	reg ALERT *al;
	reg OBJECT *tree;
	reg int i;

	if (info==NULL)
		return(FALSE);
#ifndef SMALL_NO_HZ
	else if (info==_last_cursor)
		_last_cursor = NULL;
#endif

	tree = info->di_tree;

	switch (info->di_flag)
	{
	case WINDOW:
	case WIN_MODAL:
		if (!output)
			return(FALSE);

		for (i=0;i<_win_len;i++)
			if (win_list[i]==info)
				break;

		for (_win_len--;i<_win_len;i++)
			win_list[i] = win_list[i+1];

		close_window(info->di_win,box);
	#ifndef SMALL_NO_MENU
		if (info->di_flag==WIN_MODAL && (win_modal=max(win_modal-1,0))==0)
			menu_enable(TRUE);
	#endif
		break;
	case OPENED:
	case FLYING:
		if (_no_output || info!=_dia_list[_dia_len-1])
			return(FALSE);
		_dia_len--;
		if (box)
			graf_shrinkbox (max_w>>1,max_h>>1,1,1,tree->ob_x,tree->ob_y,tree->ob_width,tree->ob_height);
		if (info->di_flag==OPENED)
			form_dial(FMD_FINISH,0,0,0,0,tree->ob_x-3,tree->ob_y-3,tree->ob_width+6,tree->ob_height+6);
		else
		{
			MouseOff();
			rc_sc_restore(info->di_rc.area.g_x,info->di_rc.area.g_y,&info->di_rc,TRUE);
			MouseOn();
		}
	#ifndef SMALL_EDIT
		_ascii = _ascii_digit = 0;
	#endif
		end_ctrl(FALSE,FALSE);
		break;
	default:
		return(FALSE);
	}

	#ifndef SMALL_EDIT
		_insert_history(info);
	#endif

	#ifndef SMALL_NO_GRAF
	{
		reg SLINFO **slider;
		if ((slider=info->di_slider)!=NULL)
			while (*slider!=NULL)
				(*slider++)->sl_info = NULL;
	}
	#endif

	#ifndef SMALL_NO_POPUP
	{
		reg XPOPUP **pop;
		if ((pop=info->di_popup)!=NULL)
			while (*pop!=NULL)
				(*pop++)->popup.p_info = NULL;
	}
	#endif

	if ((al=info->di_alert)!=NULL && al->valid)
	{
		free(al->tree);
		memset(al,0,sizeof(ALERT));
		free(al->mem);
	}

	if (info->di_mem)
		free(info->di_mem);

	memset(info,0,sizeof(INFO));
	free(info);

	return (TRUE);
}

#ifdef DEBUG

void _check_hotkeys(OBJECT *tree)
{
	reg OBJECT *obj=tree;
	reg char hotkeys[128],*p=hotkeys,c;
	reg int index = 0;
	char msg[128];

	do
	{
		obj++;
		index++;

		switch (obj->ob_type & G_TYPE)
		{
		case G_IND:
		case G_HOTKEY:
			c = obj->ob_state>>8;
			if (c && !(tree[ob_get_parent(tree,index)].ob_flags & HIDETREE))
			{
				*p = '\0';
				if (strchr(hotkeys,c)==NULL)
					*p++ = c;
				else
				{
					sprintf(msg,HOTKEY_ERR,c,index);
					form_alert(1,msg);
				}
			}
		}
	}
	while (!(obj->ob_flags & LASTOB));
}

#endif

int window_output(void)
{
	return (output);
}

int get_dialog_info(int *fly_dials,int *win_dials,int *wins,DIAINFO **top)
{
	if (fly_dials)
		*fly_dials = _dia_len;
	if (win_dials)
		*win_dials = _win_len;
	if (wins)
		*wins = _opened;

	if (_no_output)
		return (FAIL);
	else if (_dia_len>0)
	{
		if (top)
			*top = _dia_list[_dia_len-1];
		return (FALSE);
	}
	else
		return (TRUE);
}

#ifndef SMALL_NO_EDIT
static void ed_init(DIAINFO *info,int edit,int index)
{
	reg OBJECT *tree=info->di_tree,*obj=tree;
	reg int i=0,eobjc,iobjc;

	eobjc = iobjc = info->di_inddef = info->di_ed_obj = info->di_ed_index = FAIL;
	info->di_ed_cnt = 0;

	do
	{
		obj++;
		i++;

		if ((obj->ob_flags & (EDITABLE|HIDETREE))==EDITABLE && !_is_hidden(tree,i))
		{
			info->di_ed_cnt++;

			if (((obj->ob_type & G_TYPE)>>8)==TXTDEFAULT)
			{
			#ifdef DEBUG
				if (iobjc>0)
					form_alert(1,INDDEFAULT_ERR);
				else
			#endif
					iobjc = i;
			}
			if (eobjc<0 || i==edit)
				eobjc = i;
		}
	}
	while (!(obj->ob_flags & LASTOB));

	if (eobjc>0)
		ob_set_cursor(info,eobjc,eobjc==edit ? index : 0x1000,FAIL);

	if (iobjc>0 && info->di_default>0)
	{
		info->di_inddef = iobjc;
		test_inddefault(info);
	}
}

void ob_edit_init(DIAINFO *info,int edit)
{
	int index;

	if (edit<=0)
	{
		edit = info->di_ed_obj;
		index = info->di_ed_index;
	}
	else
		index = 0x1000;

	_cursor_off(info);
	ed_init(info,edit,index);
#ifndef SMALL_EDIT
	_ascii = _ascii_digit = 0;
#endif
	_inform(MOUSE_INIT);
}
#endif

DIAINFO *open_dialog(OBJECT *tree,char *win_name,char *icon_name,OBJECT *icon,
                    boolean center,boolean box,int mode,int edit,SLINFO **slider,XPOPUP **pop)
{
	reg DIAINFO *info;
	reg OBJECT *obj;
	reg TEDINFO *ted;
	reg char *text;
	reg int i,modal,type,flg;

	if ((info=(DIAINFO *) calloc(1,sizeof(DIAINFO)))==NULL)
		return (NULL);

	if (win_modal>0)
		mode |= MODAL;

	for (obj=tree,i=0;!(obj->ob_flags & LASTOB);)
	{
		obj++;i++;
		if (hdr_set && ((obj->ob_type & G_TYPE)>>8)==FIX_HEADER)
		{
			modal = obj->ob_type & (G_MODAL|G_UNMODAL);
			switch((unsigned char) obj->ob_type)
			{
			case G_BUTTON:
				text = obj->ob_spec.free_string;
				obj->ob_width = (int) strlen(text);
				if (*text!=' ')
					obj->ob_width += 2;
				obj->ob_width *= (obj->ob_x=gr_cw);
				if (hdr_center)
					obj->ob_x = (tree[ob_get_parent(tree,i)].ob_width - obj->ob_width)>>1;
				break;
			case G_TEXT:
			case G_BOXTEXT:
				if (hdr_frame)
					obj->ob_type = G_BOXTEXT;
				else
					obj->ob_type = G_TEXT;
				ted = obj->ob_spec.tedinfo;
				text = ted->te_ptext;
				goto _set_title;
			case G_FTEXT:
			case G_FBOXTEXT:
				if (hdr_frame)
					obj->ob_type = G_FBOXTEXT;
				else
					obj->ob_type = G_FTEXT;
				ted = obj->ob_spec.tedinfo;
				text = ted->te_ptmplt;
				_set_title:
				obj->ob_width = (int) strlen(text);
				if (*text!=' ')
					obj->ob_width += 2;
				if (hdr_small)
				{
					obj->ob_width *= (obj->ob_x=gr_sw);
					ted->te_font = SMALL;
				}
				else
				{
					obj->ob_width *= (obj->ob_x=gr_cw);
					ted->te_font = IBM;
				}
				if (hdr_center)
					obj->ob_x = (tree[ob_get_parent(tree,i)].ob_width - obj->ob_width)>>1;
				obj->ob_type |= (FIX_HEADER<<8);
				ted->te_just = TE_CNTR;
				ted->te_color = (hdr_fcolor<<12)|(hdr_tcolor<<8)|(hdr_transp<<7)|(hdr_bpattern<<4)|(hdr_bcolor);
				break;
			}
			obj->ob_type |= modal;
		}
		if (edit_3d && (obj->ob_flags & EDITABLE) && (colors>4 || ((unsigned char) obj->ob_type==G_FBOXTEXT && obj->ob_spec.tedinfo->te_thickness)))
		{
			obj->ob_state = (obj->ob_state|SELECTED) & ~OUTLINED;
			obj->ob_flags |= FL3DACT;
		}
		else if (draw_3d && (obj->ob_state & DRAW3D))
		{
			obj->ob_state = (obj->ob_state|SELECTED) & ~DRAW3D;
			obj->ob_flags |= FL3DACT;
		}
	}

	tree->ob_state |= OUTLINED;
	tree->ob_state &= ~SHADOWED;

	tree->ob_spec.obspec.interiorcol = dial_color;
	tree->ob_spec.obspec.fillpattern = dial_pattern;
	tree->ob_spec.obspec.framecol = dial_frame;
	if (mode & DDD_DIAL)
		tree->ob_flags &= ~FL3DMASK;

	if ((mode & WIN_DIAL)==0 || _dia_len>0 || open_windialog(tree,info,win_name,icon_name,icon,mode,center,box)==FALSE)
		if (mode & FLY_DIAL)
		{
			tree->ob_state |= OUTLINED;
			if (mode & DDD_DIAL)
				tree->ob_flags |= FL3DBAK;
			open_flydialog(tree,info,center,box);
		}

	if (info->di_flag>CLOSED)
	{
		info->di_mode = mode;

	#ifndef SMALL_NO_GRAF
		if (slider!=NULL && *slider!=NULL)
		{
			reg SLINFO *sl;

			info->di_slider = slider;
			while ((sl=*slider++)!=NULL)
			{
				sl->sl_info = NULL;
				graf_set_slider(sl,tree,GRAF_SET);
				sl->sl_info = info;
			}
		}
	#endif

	#ifndef SMALL_NO_POPUP
		if (pop!=NULL && *pop!=NULL)
		{
			reg XPOPUP *p;
			info->di_popup = pop;
			while ((p=*pop++)!=NULL)
			{
				p->popup.p_info = info;
				p->opened = 0;
			}
		}
	#endif

		info->di_default = info->di_help = info->di_undo = info->di_esc = FAIL;

		modal = (info->di_flag!=WINDOW);
		obj = tree;
		i = 0;

		do
		{
			obj++;
			i++;

			type = obj->ob_type;
			if (type & G_MODAL)
				ob_hide(tree,i,!modal);
			else if (type & G_UNMODAL)
				ob_hide(tree,i,modal);

			type &= G_TYPE;
			if (((flg=obj->ob_flags) & (DEFAULT|HIDETREE))==DEFAULT && !_is_hidden(tree,i))
			{
			#ifdef DEBUG
				if (info->di_default>0)
					form_alert(1,DEFAULT_ERR);
				else
			#endif
					info->di_default = i;
			}

		#ifndef SMALL_NO_EDIT
			if ((flg & EDITABLE) && ((unsigned char) type)!=G_FTEXT && ((unsigned char) type)!=G_FBOXTEXT)
				obj->ob_flags &= ~EDITABLE;
		#endif

		#ifdef DEBUG
			if (type==G_CHK || type==G_RB)
			{
				if (!_is_hidden(tree,i))
				{
					reg char *err=NULL,msg[40];

					switch (_get_hotkey(tree,i))
					{
					case FAIL:
						err = (type==G_RB) ? RBHOTKEY_ERR_A : CHKHOTKEY_ERR_A;
						break;
					case FALSE:
						err = (type==G_RB) ? RBHOTKEY_ERR_B : CHKHOTKEY_ERR_B;
					}

					if (err)
					{
						sprintf(msg,err,i);
						form_alert(1,msg);
					}
				}
			}
			else
		#endif
			{
				type >>= 8;
				if (type==HELP_BTN && !_is_hidden(tree,i))
				{
				#ifdef DEBUG
					if (info->di_help>0)
						form_alert(1,HELP_ERR);
					else
				#endif
						info->di_help = i;
				}
				else if (type==ESC_BTN && !_is_hidden(tree,i))
				{
				#ifdef DEBUG
					if (info->di_esc>0)
						form_alert(1,ESC_ERR);
					else
				#endif
						info->di_esc = i;
				}
				else if (type==UNDO_BTN && !_is_hidden(tree,i))
				{
				#ifdef DEBUG
					if (info->di_undo>0)
						form_alert(1,UNDO_ERR);
					else
				#endif
						info->di_undo = i;
				}
			}
		}
		while (!(flg & LASTOB));

		if (info->di_flag<WINDOW)
		{
			_ob_xdraw(tree,0,NULL);
			info->di_drawn = TRUE;
		}

	#ifdef DEBUG
		_check_hotkeys(tree);
	#endif

	#ifndef SMALL_NO_EDIT
		info->di_insert = TRUE;
		ed_init(info,edit,0x1000);

	#ifndef SMALL_EDIT
		if ((_dia_len+_win_len)>1)
			_ascii = _ascii_digit = 0;
	#endif
	#endif

		return (info);
	}

	free(info);
	return (NULL);
}

void dialog_mouse(DIAINFO *info,int (*mouse)(DIAINFO *,OBJECT *,int,int,int,int,GRECT *))
{
	info->di_mouse = mouse;
	info->di_last_obj = -2;
	info->di_last_mode = DIALOG_MOVEMENT;
	_inform(MOUSE_INIT);
}

void MenuItems(MITEM *close,MITEM *closeall,MITEM *cycle,MITEM *invcycle,MITEM *globcycle,
			   MITEM *full,MITEM *bottom, MITEM *iconify,MITEM *iconify_all,MITEM *menu,int menu_cnt)
{
	reg MITEM *org = mitems,*list = _menu_items;

	*list++ = (close!=NULL) ? *close : org[0];
	*list++ = (closeall!=NULL) ? *closeall : org[1];
	*list++ = (cycle!=NULL) ? *cycle : org[2];
	*list++ = (invcycle!=NULL) ? *invcycle : org[3];
	*list++ = (globcycle!=NULL) ? *globcycle : org[4];
	*list++ = (full!=NULL) ? *full : org[5];
	*list++ = (bottom!=NULL) ? *bottom : org[6];

#ifndef SMALL_NO_ICONIFY
	*list++ = (iconify!=NULL) ? *iconify : org[7];
	*list++ = (iconify_all!=NULL) ? *iconify_all : org[8];
#endif

	_xmenu_items = menu;
	_xitems_cnt = menu_cnt;

#ifndef SMALL_NO_MENU
	_inform_buffered(MENU_INIT);
#endif
}

void windial_calc(int calc_work,DIAINFO *info,GRECT *work)
{
	reg OBJECT *tree = info->di_tree;

	if (calc_work)
	{
		*work = *(GRECT *) &tree->ob_x;
		work->g_x -= info->di_xy_off;
		work->g_y -= info->di_xy_off;
		work->g_w += info->di_wh_off;
		work->g_h += info->di_wh_off;
	}
	else
	{
		*(long *) &tree->ob_x = *(long *) &work->g_x;
		tree->ob_x += info->di_xy_off;
		tree->ob_y += info->di_xy_off;

		if ((info->di_mode & (WD_SIZER|WD_TREE_SIZE|WD_SET_SIZE))==(WD_SIZER|WD_SET_SIZE))
		{
			*(long *) &tree->ob_width = *(long *) &work->g_w;
			tree->ob_width -= info->di_wh_off;
			tree->ob_height -= info->di_wh_off;
		}
	}
}

static void draw_dialog(int first,WIN *win,GRECT *area,GRECT *work,void *cursor)
{
	objc_draw(((DIAINFO *) win->dialog)->di_tree,ROOT,MAX_DEPTH,area->g_x,area->g_y,area->g_w,area->g_h);
#ifndef SMALL_NO_EDIT
	if (cursor!=NULL && rc_intersect((GRECT *) cursor,area))
		rc_sc_invert(area);
#endif
}

static boolean open_windialog(OBJECT *tree,DIAINFO *info,char *win_name,char *icon_name,OBJECT *icon,int mode,boolean center,boolean box)
{
	if (_win_len<MAX_DIALS)
	{
		GRECT area,max_area;
		int typ = NAME|MOVER;

		if (!(mode & MODAL) || (mode & WD_CLOSER))
			typ |= CLOSER;

	#ifndef SMALL_NO_ICONIFY
		if (!(mode & NO_ICONIFY))
			typ |= SMALLER;
	#endif

		if (mode & WD_HSLIDER)
			typ |= HSLIDE|LFARROW|RTARROW;

		if (mode & WD_VSLIDER)
			typ |= VSLIDE|UPARROW|DNARROW;

		if (mode & WD_SIZER)
			typ |= SIZER;

		if (mode & WD_FULLER)
			typ |= FULLER;

		if (mode & WD_INFO)
			typ |= INFO;

		if ((mode&SMART_FRAME)==SMART_FRAME)
		{
			info->di_xy_off = 1;
			info->di_wh_off = 2;
		}
		else if (mode & SMALL_FRAME)
		{
			info->di_xy_off = -1;
			info->di_wh_off = -3;
		}
		else if (mode & FRAME)
		{
			info->di_xy_off = 3;
			info->di_wh_off = 5;
		}
		else
		{
			info->di_xy_off = -2;
			info->di_wh_off = -4;
			tree->ob_state &= ~OUTLINED;
		}

		dial_center(tree,center,0,info->di_wh_off-info->di_xy_off+3);

		info->di_tree = tree;
		windial_calc(TRUE,info,&area);
		window_calc(WC_BORDER,typ,&area,&area);

		if (_dial_round)
			while (area.g_x<desk.g_x)
			{
				tree->ob_x += 8;
				area.g_x += 8;
			}
		else if (area.g_x<desk.g_x)
		{
			tree->ob_x = desk.g_x - area.g_x;
			area.g_x = desk.g_x;
		}

		if (area.g_y<desk.g_y)
		{
			tree->ob_y += desk.g_y - area.g_y;
			area.g_y = desk.g_y;
		}

		max_area = desk;
		if (mode & WD_TREE_SIZE)
		{
			max_area.g_w = area.g_w;
			max_area.g_h = area.g_h;
		}

		if ((info->di_win=open_window(win_name,icon_name,NULL,icon,typ,box,0,0,&max_area,&area,NULL,(WIN_REDRAW) draw_dialog,NULL,0))!=NULL)
		{
			info->di_win->dialog = info;

			if (mode & WD_TREE_SIZE)
				info->di_win->fulled = TRUE;

			if (mode & MODAL)
			{
			#ifndef SMALL_NO_MENU
				menu_enable(FALSE);
			#endif
				info->di_flag = WIN_MODAL;
				win_modal++;
			}
			else
				info->di_flag = WINDOW;

			info->di_title = win_name;

			find_fly(info);
			win_list[_win_len++]=info;

			return(TRUE);
		}
	}
	return(FALSE);
}

static void move_dialog(DIAINFO *info,GRECT *area)
{
	reg WIN *win = info->di_win;
	reg int fulled = (*(long *) &area->g_w==*(long *) &win->max.g_w);

	if (_dial_round)
	{
		GRECT work;
		reg int x;

		window_calc(WC_WORK,win->gadgets,area,&work);
		x = work.g_x + info->di_xy_off;
		area->g_x -= x - (x & ~7);

		while (area->g_x<desk.g_x)
			area->g_x += 8;
	}

	window_size(win,area);
	win->fulled = fulled;
}

static int cdecl draw_hotkey(PARMBLK *pb)
{
	reg OBJECT *par = &pb->pb_tree[ob_get_parent(pb->pb_tree,pb->pb_obj)];
	reg int x1,x2,y = pb->pb_y,state = par->ob_state,mode = (state & SELECTED) ? MD_XOR : MD_REPLACE,move = 0;

	if (has_3d)
		switch (par->ob_flags&FL3DMASK)
		{
		case FL3DACT:
			move = actmove;
			if (!actselect)
				mode = MD_REPLACE;
			break;
		case FL3DIND:
			move = indmove;
			if (!indselect)
				mode = MD_REPLACE;
		}

	_vdi_attr(mode,1,(int) pb->pb_parm,(state & DISABLED) ? 7 : 1);
	if (state & DISABLED)
		vsl_udsty(x_handle,0x5555);

	x2 = (x1=pb->pb_x) + pb->pb_w;
	if (move && (state&SELECTED))
	{
		y++;
		v_line(x1+1,y,x2,y);
	}
	else
		v_line(x1,y,x2-1,y);
	return (0);
}

static int cdecl draw_underline(PARMBLK *pb)
{
	reg int d,x1,x2,y,state = pb->pb_currstate;

	if ((d=((int) pb->pb_parm)>>8)==0)
		d = state>>8;
	_vdi_attr(MD_REPLACE,d,(char) pb->pb_parm,1);

	y = pb->pb_y;
	if (dial_title)
	{
		x2 = (x1=pb->pb_tree->ob_x) + pb->pb_tree->ob_width - gr_cw;
		x1 += gr_cw;
	}
	else
		x2 = (x1=pb->pb_x) + pb->pb_w;

	v_line(x1,y,--x2,y);
	if (state & OUTLINED)
	{
		y += (d<<1);
		v_line(x1,y,x2,y);
	}
	return (0);
}

static int cdecl draw_box(PARMBLK *pb)
{
	reg OBJECT *obj = &pb->pb_tree[pb->pb_obj];
	reg int disabled = ((pb->pb_tree[obj->ob_next].ob_state)|obj->ob_state) & DISABLED, color = (int) pb->pb_parm;
	reg int x = pb->pb_x+1,y = pb->pb_y+1,w = pb->pb_w - 1,h = pb->pb_h - 1;

	if (big_img==TRUE)
	{
		w--;
		h--;
	}

	if (obj->ob_state & CHECKED)
	{
		v_set_mode(MD_REPLACE);
		_bar(x,y,w,h,2,1,color,1);
	}
	else if (usual || big_img==FAIL || (obj->ob_flags & TOUCHEXIT))
	{
		v_set_mode(MD_REPLACE);
		_bar(x,y,w,h,0,FAIL,color,1);

		if (pb->pb_currstate & SELECTED)
		{
			w += x-1;
			h += y-1;
			_vdi_attr(FAIL,1,color,1);
			v_line(x,y,w,h);
			v_line(w,y,x,h);
		}
	}
	else
		vrt_copy((pb->pb_currstate & SELECTED) ? box_on : box_off,pb,color,check_back,0);

	return (disabled);
}

static int cdecl draw_cyclebutton(PARMBLK *pb)
{
	GRECT work;
	reg int color = (int) pb->pb_parm,w,h;

	w = gr_dcw;
	h = gr_ch;
	if (big_img==FAIL)
		w--;

	pb->pb_x++;
	pb->pb_y++;
	pb->pb_w = w;
	pb->pb_h = h;

	v_set_mode(MD_REPLACE);
	if (pb->pb_currstate & SHADOWED)
		_bar(pb->pb_x+2,pb->pb_y+1,w+1,h+2,1,FAIL,color,1);

	if (usual || big_img==FAIL)
	{
		_bar(pb->pb_x-1,pb->pb_y-1,w+2,h+2,0,FAIL,color,1);
		v_set_text(ibm_font_id,ibm_font,color,0,0,NULL);
		v_gtext(x_handle,pb->pb_x+(gr_cw>>1),pb->pb_y,cycle_char);
		if (pb->pb_currstate & SELECTED)
		{
			work = *(GRECT *) &pb->pb_x;
			if (rc_intersect((GRECT *) &pb->pb_xc,&work))
				rc_sc_invert(&work);
		}
	}
	else
	{
		_vdi_attr(FAIL,1,color,1);
		v_rect(pb->pb_x-1,pb->pb_y-1,pb->pb_x+w,pb->pb_y+h);
		vrt_copy(cycle_but,pb,color,cycle_back,pb->pb_currstate & SELECTED);
	}

	return(pb->pb_currstate & DISABLED);
}

static int cdecl draw_radiobutton(PARMBLK *pb)
{
	reg OBJECT *obj = &pb->pb_tree[pb->pb_obj];

	if (big_img==FAIL)
	{
		reg int color = (int) pb->pb_parm;

		v_set_mode(MD_REPLACE);
		_bar(pb->pb_x+1,pb->pb_y+1,pb->pb_w-2,pb->pb_h-2,0,FAIL,color,1);
		if (pb->pb_currstate & SELECTED)
			_bar(pb->pb_x+4,pb->pb_y+4,pb->pb_w-8,pb->pb_h-8,1,FAIL,color,1);
	}
	else
		vrt_copy((pb->pb_currstate & SELECTED) ? radio_on : radio_off,pb,(int) pb->pb_parm,radio_back,0);

	return (((pb->pb_tree[obj->ob_next].ob_state)|obj->ob_state) & DISABLED);
}

static int cdecl draw_arrows(PARMBLK *pb)
{
	GRECT work;
	reg int type = (pb->pb_tree[pb->pb_obj].ob_type & G_TYPE)>>8,color = (int) pb->pb_parm;

	v_set_mode(MD_REPLACE);

	if (usual || big_img==FAIL)
	{
		_bar(pb->pb_x-1,pb->pb_y-1,gr_dcw+2,gr_ch+2,0,FAIL,(pb->pb_currstate & OUTLINED) ? color : 0,(pb->pb_currstate & OUTLINED));
		v_set_text(ibm_font_id,ibm_font,color,0,0,NULL);
		v_gtext(x_handle,pb->pb_x+(gr_cw>>1),pb->pb_y,c_arrow[type-ARROW_LEFT]);
		if (pb->pb_currstate & SELECTED)
		{
			work = *(GRECT *) &pb->pb_x;
			if (rc_intersect((GRECT *) &pb->pb_xc,&work))
				rc_sc_invert(&work);
		}
	}
	else
	{
		reg int *but,*sel;

		if (pb->pb_currstate & OUTLINED)
		{
			_vdi_attr(FAIL,1,color,1);
			v_rect(pb->pb_x-1,pb->pb_y-1,pb->pb_x+gr_dcw,pb->pb_y+gr_ch);
		}

		switch (type)
		{
		case ARROW_UP:
			but = arrow_up;
			sel = arrow_up_sel;
			break;
		case ARROW_DOWN:
			but = arrow_down;
			sel = arrow_down_sel;
			break;
		case ARROW_LEFT:
			but = arrow_left;
			sel = arrow_left_sel;
			break;
		default:
			but = arrow_right;
			sel = arrow_right_sel;
			break;
		}

		if (pb->pb_currstate & SELECTED)
			vrt_copy(sel ? sel : but,pb,color,arrow_back,sel==NULL);
		else
			vrt_copy(but,pb,color,arrow_back,0);
	}

	return(pb->pb_currstate & DISABLED);
}

static int cdecl draw_fly(PARMBLK *pb)
{
	reg int pxy[6],x=pb->pb_x,y=pb->pb_y,w=pb->pb_w,h=pb->pb_h;

	_vdi_attr(MD_REPLACE,1,dial_frame,1);
	_bar(x,y,w,h,0,FAIL,dial_frame,0);

	w += x - 1;
	h += y - 1;

	if (pb->pb_tree->ob_state & OUTLINED)
	{
		pxy[0] = x + 3;
		pxy[3] = pxy[1] = y + 3;
		pxy[4] = pxy[2] = w - 3;
		pxy[5] = h - 3;
		v_pline(x_handle,3,pxy);

		if (pb->pb_tree->ob_spec.obspec.framesize!=1)
		{
			if (big_img==TRUE)
				pxy[0]++;
			else
				pxy[0] += 2;
			pxy[1]++;
			pxy[2]--;
			pxy[3]++;
			pxy[4]--;
			if (big_img==TRUE)
				pxy[5]--;
			v_pline(x_handle,3,pxy);
		}
	}

	v_rect(x,y,w,h);
	v_line(x,y,w,h);

	return(pb->pb_currstate & DISABLED);
}

#ifndef SMALL_NO_XTEXT
static int cdecl draw_text(PARMBLK *pb)
{
	reg X_TEXT *text = (X_TEXT *) pb->pb_parm;
	reg int x = pb->pb_x,y = pb->pb_y,pxy[8],effect = text->effect & 31;

	if ((pb->pb_prevstate^pb->pb_currstate)&SELECTED)
	{
		GRECT work=*(GRECT *) &pb->pb_x;
		if (rc_intersect((GRECT *) &pb->pb_xc,&work))
			rc_sc_invert(&work);
		return (0);
	}

	v_set_text(text->font_id,text->font_size,text->color,effect,0,NULL);
	vqt_extent(x_handle,(char *) text->string,&pxy[0]);

	switch (text->center)
	{
	case TE_RIGHT:
		x += pb->pb_w - pxy[4];
		break;
	case TE_CNTR:
		x += (pb->pb_w - pxy[4])>>1;
	}
	y += (pb->pb_h - pxy[5])>>1;

	v_set_mode(text->mode);
	if (text->effect & X_TITLE)
	{
		reg int p,x1 = pb->pb_x,x2 = x1 + pb->pb_w - 1,h = pxy[5];

		if (h<=12)
		{
			p = y + 1;
			h -= 2;
		}
		else
		{
			p = y + 3;
			h -= 6;
		}

		v_set_line(text->color,1,1,0,0);
		for (;(h-=2)>=0;p+=2)
			v_line(x1,p,x2,p);
	}
	else if (text->effect & X_3D)
	{
		v_gtext(x_handle,x+2,y+2,text->string);
		v_set_mode((text->effect & X_INVERS) ? MD_ERASE : MD_TRANS);
		v_set_text(FAIL,FALSE,WHITE,FAIL,FAIL,NULL);
		v_gtext(x_handle,x+1,y+1,text->string);
		v_set_text(FAIL,FALSE,BLACK,FAIL,FAIL,NULL);
	}
	else if (text->effect & X_SHADOWED)
	{
		v_set_text(FAIL,FALSE,FAIL,effect|X_LIGHT,FAIL,NULL);
		v_gtext(x_handle,x+2,y+2,text->string);
		v_set_mode((text->effect & X_INVERS) ? MD_ERASE : MD_TRANS);
		v_set_text(FAIL,FALSE,FAIL,effect & (~X_LIGHT),FAIL,NULL);
	}
	else if (text->effect & X_INVERS)
		v_set_mode(MD_ERASE);
	v_gtext(x_handle,x,y,text->string);

	return (pb->pb_currstate & SELECTED);
}
#endif

static int cdecl draw_menu(PARMBLK *pb)
{
	int old[4];

	save_clipping(old);
	_clip_rect(NULL);

	v_set_mode(MD_REPLACE);
	_bar(pb->pb_x,pb->pb_y+(pb->pb_h>>1)-1,pb->pb_w,2,2,4,BLACK,0);

	restore_clipping(old);

	return (0);
}

#ifndef SMALL_NO_EDIT
static void test_inddefault(DIAINFO *info)
{
	reg char *text = ob_get_text(info->di_tree,info->di_inddef,0);
	if (text!=NULL)
		ob_disable(info,info->di_tree,info->di_default,*text=='\0',info->di_drawn);
}
#endif

void close_all_dialogs(void)
{
	while (_dia_len>0 && close_dialog(_dia_list[_dia_len-1],FALSE));
	while (_win_len>0 && close_dialog(win_list[_win_len-1],FALSE));
}

void close_all_windows(void)
{
	close_all_dialogs();
	while (_opened>0 && close_window(_window_list[0],FALSE));
}

static boolean find_windial(int hdl,DIAINFO **info)
{
	reg WIN *win = get_window(hdl);

	if (win && win->dialog)
	{
		*info = (DIAINFO *) win->dialog;
		return (TRUE);
	}		

	return(FALSE);
}

int _messag_handler(int form_do,XEVENT *event,int *obj,DIAINFO **back)
{
	int top;
	DIAINFO *info,*act_info = get_info(&top);
	reg WIN *window;
	reg int *mbuf = event->ev_mmgpbuf,msg = mbuf[0];
	reg boolean found = FALSE,win = FALSE;
	GRECT curr;

	if (act_info)
	{
		switch (msg)
		{
		case WIN_NEWTOP:
		case WIN_CHANGED:
		#ifndef SMALL_EDIT
			_ascii = _ascii_digit = 0;
		#endif
			if (msg!=WIN_NEWTOP && find_windial(mbuf[3],&info))
				event->ev_mwich &= ~MU_MESAG;
			break;
		case WM_CLOSED:
		case WM_TOPPED:
			win = win_modal;
		case WM_BOTTOMED:
		case WM_MOVED:
			found = find_windial(mbuf[3],&info);break;
		default:
			if ((act_info->di_mode & WD_SET_SIZE) && (msg==WM_FULLED || msg==WM_SIZED))
				found = find_windial(mbuf[3],&info);
			break;
		}

		if (found || win)
		{
			event->ev_mwich &= ~MU_MESAG;

			switch (msg)
			{
			case WM_BOTTOMED:
				if (!win_modal || info->di_flag!=WIN_MODAL || info!=act_info || _opened==1)
					window_bottom(info->di_win);
				break;
			case WM_TOPPED:
				window_top(win ? act_info->di_win : info->di_win);
				break;
			case WM_CLOSED:
				if (form_do && found && (!win_modal || info==act_info))
				{
					if (back)
						*back = info;
					if (obj)
						*obj = W_CLOSED;
					return (TRUE);
				}
				break;
			case WM_FULLED:
				if (info->di_win->fulled)
					*(GRECT *) &mbuf[4] = info->di_win->prev;
				else
				{
					*(GRECT *) &mbuf[4] = info->di_win->max;
					if (info->di_mode & WD_TREE_SIZE)
					{
						*(long *) &mbuf[4] = *(long *) &info->di_win->curr.g_x;
						Min(&mbuf[4],max_w-mbuf[6]-1);
						Min(&mbuf[5],max_h-mbuf[7]-1);
					}
				}
			case WM_SIZED:
			case WM_MOVED:
				move_dialog(info,(GRECT *) &mbuf[4]);
				_send_msg(info,0,OBJC_SIZED,0,0);
				if (msg!=WM_FULLED)
					info->di_win->fulled = FALSE;
				break;
			}
		}
	}

	if (event->ev_mwich & MU_MESAG)
		switch (msg)
		{
		#ifndef SMALL_NO_XACC_AV
		case ACC_TEXT:
		#ifndef SMALL_EDIT
			if (act_info && act_info->di_ed_obj>0 && (top || act_info->di_win==_window_list[0]))
			{
				reg char *text = *(char **) &mbuf[4];
				reg int cat = (strpbrk(text,"\r\n")==NULL);
				reg int ob = act_info->di_ed_obj;
	
				do
				{
					text += _insert_buf(act_info,text,cat);
				} while (*text!='\0' && _next_edit(act_info,FALSE));
	
				if (act_info->di_inddef>0 && act_info->di_default>0)
					test_inddefault(act_info);

				if (!cat)
					ob_set_cursor(act_info,ob,FAIL,FAIL);

				XAccSendAck(mbuf[1],1);
				_send_msg(act_info,FAIL,OBJC_EDITED,0,0);
				event->ev_mwich &= ~MU_MESAG;
			}
			else
		#endif
			if (!(_xacc_msgs & X_MSG_TEXT))
			{
				XAccSendAck(mbuf[1],0);
				event->ev_mwich &= ~MU_MESAG;
			}
			break;
		#endif
		case AC_CLOSE:
			_ac_close = TRUE;
		case AP_TERM:
			close_all_windows();
			if (form_do)
			{
				_call_event_handler(MU_MESAG,event,0);
				event->ev_mwich &= ~MU_MESAG;
			}
			_ac_close = FALSE;
			break;
		case WM_TOPPED:
		case WM_BOTTOMED:
		case WM_FULLED:
		case WM_SIZED:
		case WM_MOVED:
			if ((window=get_window(mbuf[3]))!=NULL && window->msgs)
				switch (msg)
				{
				case WM_TOPPED:
					if (window->msgs & XM_TOP)
					{
						window_top(window);
						event->ev_mwich &= ~MU_MESAG;
					}
					break;
				case WM_BOTTOMED:
					if (window->msgs & XM_BOTTOM)
					{
						window_bottom(window);
						event->ev_mwich &= ~MU_MESAG;
					}
					break;
				default:
					if (window->msgs & XM_SIZE)
					{
						curr = window->curr;
						window_size(window,msg!=WM_FULLED ? (GRECT *) &mbuf[4] : (window->fulled ? &window->prev : &window->max));
						if (!rc_equal(&curr,&window->curr))
							_send_msg(window,window->handle,WIN_SIZED,0,0);
						event->ev_mwich &= ~MU_MESAG;
					}
				}
		}

	if ((_win_len|_dia_len)==0)
	{
		if (obj)
			*obj = W_ABANDON;
		return (TRUE);
	}
	else
		return (FALSE);
}

#ifndef SMALL_NO_POPUP
static int test_popup(DIAINFO *info,int obj,int key)
{
	XPOPUP **list,*xpop;
	POPUP *pop;
	int double_click,select,mode,old;

	if (obj==W_CLOSED || obj==W_ABANDON || (list=info->di_popup)==NULL)
		return (FALSE);

	double_click = (obj & (DOUBLE_CLICK|RIGHT_CLICK));
	obj &= NO_CLICK;

	while ((xpop=*list++)!=NULL)
	{
		pop = &(xpop->popup);
		if (obj==pop->p_parent || obj==pop->p_button || obj==pop->p_cycle)
		{
			mode = (xpop->cycle_mode>=0 && (obj==pop->p_cycle || (double_click && key))) ? xpop->cycle_mode : xpop->mode;

			select = 0;
			switch (mode & (POPUP_CYCLE|POPUP_INVCYCLE))
			{
			case POPUP_INVCYCLE:
			case POPUP_CYCLE:
				select = POPUP_CYCLE|POPUP_INVCYCLE;break;
			case POPUP_INVCYCLE|POPUP_CYCLE:
				select = POPUP_INVCYCLE;
			}

			if (key ? (double_click & RIGHT_CLICK) : (obj==pop->p_cycle && double_click))
				mode ^= select;

			old = xpop->current;
			xpop->opened++;
			select = Popup(pop,mode,xpop->center,xpop->x,xpop->y,&xpop->index,xpop->current) & NO_CLICK;
			xpop->opened--;

			if (select)
			{
				xpop->current = select;
				if (mode & POPUP_MENU)
				{
					XEVENT event;
					reg int *msg = event.ev_mmgpbuf;

					*msg++ = MN_SELECTED;
					*msg++ = ap_id;
					*msg++ = 0;
					*msg++ = (xpop->id>0) ? -xpop->id : -0x7fff;
					*msg++ = select;
					*((long *) msg)++ = (long) pop->p_menu;
					*msg++ = pop->p_parent;

					_call_event_handler(MU_MESAG,&event,0);
				}
				else if (old!=select)
					_send_msg(xpop,select,POPUP_CHANGED,0,0);
			}
			return (TRUE);
		}
	}
	return (FALSE);
}
#endif

int FormObject(int ob)
{
	switch (ob)
	{
	case W_ABANDON:
	case W_CLOSED:
		return (-1);
	default:
		return (ob&NO_CLICK);
	}
}

int XFormObject(DIAINFO **back,int *obj)
{
	int exit = X_Form_Do(back);
	if (obj)
		*obj = exit;
	return (FormObject(exit));
}

int X_Form_Do(DIAINFO **back)
{
	int top,obj;
	XEVENT event;
	DIAINFO *act_info,*winfo;
	reg int events,do_event,handle;

	if (back)
		*back = NULL;

	if ((_dia_len|_win_len)==0)
		return (W_ABANDON);

	memset(&event,0,sizeof(XEVENT));
	event.ev_mbclicks = 258;
	event.ev_mbmask = 3;

#ifndef SMALL_EDIT
	_ascii = _ascii_digit = 0;
#endif
	event.ev_mflags = MU_KEYBD|MU_BUTTON|MU_MESAG|MU_NO_HANDLER;

	for(;;)
	{
		events = Event_Multi(&event);
		if (events & MU_MESAG)
		{
			if (_messag_handler(TRUE,&event,&obj,back))
				return (obj);
			else
				events = event.ev_mwich;
		}

		if (events & MU_KEYBD)
		{
			if (always_keys!=KEY_FIRST || _call_event_handler(MU_KEYBD,&event,FALSE)==0)
			{
				act_info = get_info(&top);
				do_event = (top || act_info->di_win==_window_list[0]);
	
				if (toMouse && act_info->di_flag==WINDOW &&
					(!top || !rc_inside(event.ev_mmox,event.ev_mmoy,&act_info->di_win->curr)) &&
				 	find_windial(wind_find(event.ev_mmox,event.ev_mmoy),&winfo) && !winfo->di_win->iconified)
				{
					if (winfo!=act_info)
						top = FALSE;
					act_info = winfo;
					do_event = TRUE;
				}
	
				act_info->di_taken = FALSE;
				if (do_event && !act_info->di_win->iconified)
				{
					if ((obj=key_handler(act_info,event.ev_mmokstate,event.ev_mkreturn,&event))!=FAIL)
					{
						if (event.ev_mmokstate & K_CTRL)
							obj |= RIGHT_CLICK;

					#ifndef SMALL_NO_POPUP
						if (!test_popup(act_info,obj,TRUE))
					#endif
						{
							if (back)
								*back = act_info;
							return (obj);
						}
					}
				}

			#ifndef SMALL_NO_MENU
				if (act_info->di_taken || (always_keys==KEY_STD && (act_info->di_flag!=WINDOW || menu_dropped())))	
			#else
				if (act_info->di_taken || (always_keys==KEY_STD && act_info->di_flag!=WINDOW))
			#endif
					events &= ~MU_KEYBD;
			}
			else
				events &= ~MU_KEYBD;

			if ((_dia_len|_win_len)==0)
				return (W_ABANDON);
		}

		if (events & MU_BUTTON)
		{
			do_event = FAIL;
			act_info = get_info(&top);

			if (act_info->di_flag<WINDOW || 
				(top && rc_inside(event.ev_mmox,event.ev_mmoy,&act_info->di_win->curr)) ||
				 act_info->di_win->handle==(handle=wind_find(event.ev_mmox,event.ev_mmoy)))
			{
				winfo = act_info;
				do_event = top;
			}
			else if ((_back_win || (event.ev_mmobutton & 3)==3) && find_windial(handle,&winfo))
			{
				if (win_modal)
					klickobj(winfo,&event,&obj,FALSE,FALSE);
				else
					do_event = FALSE;
			}

			handle = event.ev_mmobutton==2;
			if (do_event>=FALSE && !winfo->di_win->iconified && klickobj(winfo,&event,&obj,do_event,TRUE)==FALSE)
			{
				if (handle)
					obj |= RIGHT_CLICK;
			#ifndef SMALL_NO_POPUP
				if (!test_popup(winfo,obj,FALSE))
			#endif
				{
					if (back)
						*back = winfo;
					return (obj);
				}
			}

			events &= ~MU_BUTTON;
		}

		if (events && _call_event_handler(events,&event,TRUE) && (_dia_len|_win_len)==0)
			return (W_ABANDON);
	}
}

static DIAINFO *get_info(int *top)
{
	DIAINFO *winfo,*last;

	if (_dia_len>0)
	{
		*top = TRUE;
		return (_dia_list[_dia_len-1]);
	}
	else if (_win_len>0)
	{
		last = win_list[_win_len-1];
		*top = FALSE;
		if (_window_list[0]->dialog!=NULL)
		{
			reg int win_top = GetTop();

			if (win_modal || (!find_windial(win_top,&winfo) && !find_windial(_window_list[0]->handle,&winfo)))
				winfo = last;
			if (winfo->di_win->handle==win_top && !winfo->di_win->iconified)
				*top = TRUE;
		}
		else
			winfo = last;
		return (winfo);
	}
	else
	{
		*top = FALSE;
		return (NULL);
	}
}

static boolean klickobj(DIAINFO *info,XEVENT *event,int *obj,int top,int handle)
{
#ifndef SMALL_NO_GRAF
	reg SLINFO **sl_list = (SLINFO **) info->di_slider,*slider;
#endif
	reg int ob,dummy,ind=FALSE,button=event->ev_mmobutton;
	reg OBJECT *tree = info->di_tree,*ob_ptr;

	if (top || _back_win || !handle || (event->ev_mmobutton & 3)!=2)
	{
		if ((ob=objc_find(tree,ROOT,MAX_DEPTH,event->ev_mmox,event->ev_mmoy))>=0)
		{
			if (event->ev_mmobutton & 2)
			{
				event->ev_mbreturn = (event->ev_mmobutton & 1) ? 1 : 2;
				event->ev_mmobutton = 1;
			}

			ob_ptr = &tree[ob];
		#ifndef SMALL_NO_GRAF
			if (sl_list!=NULL && !(ob_ptr->ob_state & DISABLED))
			{
				while ((slider=*sl_list++)!=NULL)
				{
					if (ob==slider->sl_dec || ob==slider->sl_inc ||
						ob==slider->sl_parent || ob==slider->sl_slider)
					{
						if (handle)
						{
							int cursor = slider->sl_cursor;
							dummy = slider->sl_pos;
							graf_rt_slidebox(slider,ob,event->ev_mbreturn!=1,0,0);
							if (dummy!=slider->sl_pos || cursor!=slider->sl_cursor)
								_send_msg(slider,0,SLIDER_CHANGED,0,0);
						}
						return (TRUE);
					}
				}
			}
		#endif

			if (!(ob_ptr->ob_flags & (SELECTABLE|EDITABLE|EXIT|TOUCHEXIT)))
			{
				if (!(ob_ptr->ob_state & DISABLED) && (dummy=is_rb_chk(tree,ob))>=0)
				{
					ob = dummy;
					ind = TRUE;
				}
				else if (button==1)
				{
					button = mouse(&event->ev_mmox,&event->ev_mmoy) & 1;
					if (info->di_fly && _nonsel_fly && button)
					{
						do_jump_fly(info,FAIL,FAIL);
						return(TRUE);
					}
					else if (info->di_flag>=WINDOW)
					{
						WIN *win = info->di_win;
						int msg[8];

						msg[3] = win->handle;
						if (button && _nonsel_fly)
						{
							GRECT work=win->curr,bound;
							*(long *) &bound.g_x = *(long *) &win->max.g_x;
							bound.g_w = desk.g_w<<1;
							bound.g_h = desk.g_h<<1;
							graf_rt_dragbox(FALSE,&work,&bound,&work.g_x,&work.g_y,0l);
							move_dialog(info,&work);
							_send_msg(info,0,OBJC_SIZED,0,0);
							info->di_win->fulled = FALSE;
						}
						else if (!top && handle)
							_send_puf(TRUE,WIN_TOPPED,msg);
						return(TRUE);
					}
				}
			}

			if (handle && (dummy=objekt_handler(info,ob,event->ev_mbreturn,event->ev_mmox,event->ev_mmoy,ind))!=FAIL)
			{
				*obj = dummy;
				return(FALSE);
			}
			return(TRUE);
		}
		else if (handle && info->di_fly)
		{
			do_jump_fly(info,event->ev_mmox,event->ev_mmoy);
			NoClick();
			return(TRUE);
		}
	}
	return(FAIL);
}

int _send_msg(void *info, int id, int msg_id,int msg6,int msg7)
{
	XEVENT event;
	reg int *msg = event.ev_mmgpbuf;

	*msg++ = msg_id;
	*msg++ = ap_id;
	*msg++ = 0;
	*msg++ = id;
	*((long *) msg)++ = (long) info;
	*msg++ = msg6;
	*msg++ = msg7;

	return (_call_event_handler(MU_MESAG,&event,0));
}

static int key_handler(DIAINFO *info,int state,int scan,XEVENT *event)
{
#ifndef SMALL_NO_GRAF
	SLINFO **sl_list = (SLINFO **) info->di_slider,*slider;
	reg SLKEY *sl_keys;
	int cnt;
#endif
	reg OBJECT *tree = info->di_tree;
	reg int sn = (int) (((unsigned) scan)>>8),obj = FAIL,hot,shft;
	int ascii = scan_2_ascii(scan,state);
#ifndef SMALL_NO_EDIT
	int edited;
#endif

	shft = (state & K_SHIFT) ? TRUE : FALSE;

#ifndef SMALL_NO_GRAF
	if (sl_list!=NULL)
		while ((slider=*sl_list++)!=NULL)
			if ((sl_keys=slider->sl_keys)!=NULL)
				for (cnt=slider->sl_keys_cnt;--cnt>=0;sl_keys++)
					if (((state^sl_keys->state) & (K_ALT|K_CTRL))==0 && ((sn && (sl_keys->scan>>8)==sn) || (ascii && (char) sl_keys->scan==ascii)))
					{
						if ((sl_keys->state & K_SHIFT) ? shft : !shft)
						{
							ClrKeybd();
							hot = slider->sl_pos; cnt = slider->sl_cursor;
							graf_rt_slidebox(slider,sl_keys->cmd,FALSE,0,0);
							if (hot!=slider->sl_pos || cnt!=slider->sl_cursor)
								_send_msg(slider,0,SLIDER_CHANGED,0,0);
							info->di_taken = TRUE;
							return (FAIL);
						}
					}
#endif

	hot = shft ? 6 : 4;

	if (!state)
	{
		switch (sn)
		{
		case SCANRET:
		#ifdef SMALL_NO_EDIT
			obj = info->di_default;
		#else
			if (return_default==RETURN_DEFAULT || info->di_ed_obj<0)
				obj = info->di_default;

			if (obj<0 && info->di_ed_obj>0)
			{
				obj = info->di_default;
				if (_next_edit(info,(return_default==RETURN_NEXT_EDIT || obj<=0) ? TRUE : FALSE))
				{
					info->di_taken = TRUE;
					return (FAIL);
				}
			}
		#endif
			break;
		case SCANENTER:
		#ifndef SMALL_NO_EDIT
			if (info->di_ed_obj<0)
		#endif
				obj = info->di_default;
			break;
		case SCANESC:
			obj = info->di_esc;
			break;
		case SCANHELP:
			obj = info->di_help;
			break;
		case SCANUNDO:
			obj = info->di_undo;
			break;
		}

		if (obj>=0)
		{
			info->di_taken = TRUE;
			return (objekt_handler(info,obj,hot,0,0,FALSE));
		}
	}

#ifndef SMALL_NO_EDIT
	if ((state & K_ALT) || (info->di_flag!=WINDOW && info->di_ed_obj<0))
#else
	if ((state & K_ALT) || info->di_flag!=WINDOW)
#endif
	{
		if ((obj=_is_hotkey(tree,ascii))>=0 && !_is_hidden(tree,obj))
		{
			info->di_taken = TRUE;
		#ifndef SMALL_NO_EDIT
			if (!(hot & 2) && (tree[obj].ob_flags & EDITABLE))
			{
				ob_set_cursor(info,obj,0x1000,FAIL);
				return (FAIL);
			}
			else
		#endif
				return (objekt_handler(info,obj,hot,0,0,FALSE));
		}
	}

#ifndef SMALL_NO_EDIT
	if (info->di_ed_obj>0)
	{
		_objc_edit_handler(info,state,scan,event,&edited);
		if (edited && (info->di_ed_obj==info->di_inddef || (edited==FAIL && info->di_inddef>0)))
			test_inddefault(info);
		if (edited==TRUE)
			_send_msg(info,info->di_ed_obj,OBJC_EDITED,0,0);
	}
#endif

	return (FAIL);
}

static int is_rb_chk(reg OBJECT *tree,reg int obj)
{
	reg int index = 0;

	do
	{
		tree++;index++;
		if (tree->ob_next==obj)
			switch (tree->ob_type & G_TYPE)
			{
			case G_CHK:
			case G_RB:
				return(index);
			default:
				return(FAIL);
			}
	} while (!(tree->ob_flags & LASTOB));
	return (FAIL);
}

boolean _is_hidden(OBJECT *tree,int index)
{
	reg OBJECT *obj = &tree[index];
	reg int act = obj->ob_flags;

	if ((act & HIDETREE) || ((act & EDITABLE) && (obj->ob_state & DISABLED)))
		return(TRUE);
	else
		for (act=index;--act>=0;)
		{
			obj--;
			if (obj->ob_head<=index && obj->ob_tail>=index)
			{
				if (obj->ob_flags & HIDETREE)
					return(TRUE);
				else
					index = act;
			}
		}
	return(FALSE);
}

int _is_hotkey(OBJECT *tree,int ascii)
{
	reg OBJECT *obj = tree;
	reg int hot,index = 0;

	do
	{
		obj++;index++;
		switch (obj->ob_type & G_TYPE)
		{
		case G_HOTKEY:
			if (*((unsigned char *) &obj->ob_state)==ascii)
				return (ob_get_parent(tree,index));
			break;
		case G_CHK:
		case G_RB:
			if ((hot=_get_hotkey(tree,index))>0 && *((unsigned char *) &tree[hot].ob_state)==ascii)
				return(index);
		}
	}
	while (!(obj->ob_flags & LASTOB));

	return(FAIL);
}

static int objekt_handler(DIAINFO *info,int obj,int hot,int x,int y,boolean ind)
{
	reg OBJECT *tree = info->di_tree,*obptr = tree+obj;
	reg int flags = obptr->ob_flags, key = (hot&4);
	reg int state = obptr->ob_state, old_state = state;

#ifndef SMALL_NO_EDIT
	if ((hot & 6)==0 && (flags & EDITABLE))
	{
		int dummy;

		if (!(state & DISABLED))
		{
			GRECT *edit_box;
			EDINFO ed;
			reg char *edit,*p;
			reg int pos,index,len,old;

			edit = _edit_get_info(tree,obj,0,&ed);
			edit_box = (GRECT *) &ed.edit_x;
			edit_box->g_w += 2;

			if (rc_inside(x,y,edit_box))
			{
				len = (int) strlen(edit);
				old = -1;

				pos = min((x-ed.edit_x)/ed.cw,len);
				for (p=edit,index=pos;--index>=0;)
					if (*p++!='_')
						pos--;

				if (pos!=old)
					ob_set_cursor(info,obj,pos,FAIL);

				return(FAIL);
			}
		}

		if ((dummy=is_rb_chk(tree,obj))!=FAIL)
		{
			obj = dummy;
			obptr = tree+obj;
			flags = obptr->ob_flags;
			old_state = state = obptr->ob_state;
		}
	}
#endif

	if (!(state & DISABLED))
	{
		if ((obptr->ob_type & G_TYPE)==G_FLY || ((obptr->ob_type & G_TYPE)>>8)==USERFLY)
			do_jump_fly(info,FAIL,FAIL);
		else if (flags & (SELECTABLE|EXIT|TOUCHEXIT))
		{
			if (flags & SELECTABLE)
			{
				if ((flags & RBUTTON) && (state & SELECTED))
				{
					if (!key)
						NoClick();
				}
				else if (obptr->ob_spec.userblk==&checkblk && (flags & TOUCHEXIT))
				{
					state &= ~(CHECKED|SELECTED); 
					if (old_state & SELECTED)
						state |= CHECKED;
					else if (!(old_state & CHECKED))
						state |= SELECTED;

					obptr->ob_state = state;

					ob_draw(info,obj);
					_send_msg(info,obj,OBJC_CHANGED,0,0);

					if (!key)
						NoClick();
					return (FAIL);
				}
				else if (key || ind || (flags & (RBUTTON|TOUCHEXIT)))
				{
					ob_select(info,tree,obj,(obptr->ob_state&SELECTED)==0,TRUE);

					if (flags & RBUTTON)
					{
						reg int act = obj,lst,new;

						for(;;)
						{
							lst = act;
							new = obptr->ob_next;

							for(;;)
							{
								act = new;
								obptr = tree+act;

								if (obptr->ob_tail==lst)
								{
									new = obptr->ob_head;
									lst = act;
								}
								else
								{
									if (act==obj)
										goto do_exit;
									if ((obptr->ob_state & SELECTED) && (obptr->ob_flags & RBUTTON))
									{
										ob_select(info,tree,act,(obptr->ob_state&SELECTED)==0,TRUE);
										goto do_exit;
									}
									else
										break;
								}
							}
						}
					}
					else if (key && (flags&(EXIT|TOUCHEXIT))==EXIT)
						Event_Timer(50,0,TRUE);

					do_exit:
					if (!key && ((ind || (flags & RBUTTON)) && !(flags & TOUCHEXIT)))
						NoClick();

					if ((flags & (EXIT|TOUCHEXIT))==0)
						_send_msg(info,obj,OBJC_CHANGED,0,0);
				}
				else
				{
					XEVENT event;
					int events;

					beg_ctrl(FALSE,FALSE,TRUE);

					memset(&event,0,sizeof(XEVENT));
					event.ev_mflags = MU_BUTTON|MU_M1;
					event.ev_mbclicks = 1;
					event.ev_bmask = 3;

					ob_pos(tree,obj,(GRECT *) &event.ev_mm1x);
					if ((event.ev_mm1flags=rc_inside(x,y,(GRECT *) &event.ev_mm1x))!=0)
						ob_select(info,tree,obj,(obptr->ob_state&SELECTED)==0,TRUE);

					do
					{
						events = Event_Multi(&event);
						if (events & MU_M1)
						{
							event.ev_mm1flags ^= 1;
							ob_select(info,tree,obj,(obptr->ob_state&SELECTED)==0,TRUE);
						}
					} while (!(events & MU_BUTTON));

					end_ctrl(FALSE,TRUE);

					if (obptr->ob_state!=old_state)
					{
						if ((flags & (EXIT|TOUCHEXIT))==0)
							_send_msg(info,obj,OBJC_CHANGED,0,0);
					}
					else
						return (FAIL);
				}
			}
			else if (obptr->ob_spec.userblk==&checkblk && (flags & TOUCHEXIT))
				return (FAIL);
			else if (flags & EXIT)
				NoClick();

			if (flags & (EXIT|TOUCHEXIT))
			{
				if (hot & 2)
					return (obj|DOUBLE_CLICK);
				else
					return (obj);
			}
		}
	}
	return(FAIL);
}

static void do_jump_fly(DIAINFO *info,int x,int y)
{
	RC_RECT dial;
	reg OBJECT *tree = info->di_tree;
	reg GRECT *area = &info->di_rc.area,bound;

	_rc_sc_savetree(tree,&dial);

#ifndef SMALL_NO_EDIT
	if (!dial.valid)
		_cursor_off(info);
#endif

	MouseOff();
	rc_sc_restore(area->g_x,area->g_y,&info->di_rc,FALSE);
	MouseOn();

	if (x<0)
	{
		bound = desk;
		bound.g_x++;
		bound.g_y++;
		bound.g_w -= 2;
		bound.g_h -= 2;

		graf_rt_dragbox(FALSE,area,&bound,&tree->ob_x,&tree->ob_y,0l);
		tree->ob_x += 3;tree->ob_y += 3;
	}
	else
	{
		int ox = tree->ob_x,oy = tree->ob_y;
		tree->ob_x = x - (tree->ob_width>>1);
		tree->ob_y = y - (tree->ob_height>>1);
		graf_movebox(tree->ob_width,tree->ob_height,ox,oy,tree->ob_x,tree->ob_y);
		_inform(MOUSE_INIT);
	}

	dial_pos(tree,4,3);

	MouseOff();
	rc_sc_freshen(x=tree->ob_x-3,y=tree->ob_y-3,&info->di_rc);
	if (dial.valid)
		rc_sc_restore(x,y,&dial,TRUE);
	else
	{
		_ob_xdraw(tree,0,NULL);
	#ifndef SMALL_NO_EDIT
		ob_set_cursor(info,FAIL,FAIL,FAIL);
	#endif
	}
	MouseOn();

	_send_msg(info,0,OBJC_SIZED,0,0);
}

static void set_work_in(int dev,int *work_in)
{
	reg int i;
	*work_in++ = dev;
	for (i=9;--i>=0;*work_in++=1);
	*work_in = 2;
}

boolean open_device(int dev,int *handle,int *work_out)
{
	if (vq_gdos() && dev>=1 && dev<=99)
	{
		int work_in[11];

		*handle = grhandle;
		set_work_in(dev,work_in);
		v_opnwk(work_in,handle,work_out);
		if (*handle>0)
			return (TRUE);
	}
	return (FALSE);
}

void close_device(int handle)
{
	if (vq_gdos())
		v_clswk(handle);
}

boolean driver_avaiable(int dev)
{
	int handle,work_out[57];
	if (open_device(dev,&handle,work_out))
	{
		close_device(handle);
		return (TRUE);
	}
	return (FALSE);
}

boolean open_work(int *handle,int *work_out)
{
	int work_in[11];
	*handle = grhandle;
	set_work_in(1,work_in);
	v_opnvwk(work_in,handle,work_out);
	return((*handle>0) ? TRUE : FALSE);
}

void close_work(int handle)
{
	v_clsvwk(handle);
}

int xdialog(OBJECT *tree,char *name,char *icon_name,OBJECT *icon,boolean center,boolean shrgrw,int mode)
{
	reg DIAINFO *info;
	reg int exit=W_ABANDON;

	if ((info=open_dialog(tree,name,icon_name,icon,center,shrgrw,mode,0,NULL,NULL))!=NULL && (exit=X_Form_Do(NULL))!=W_ABANDON)
	{
		close_dialog(info,shrgrw);
		if (exit!=W_CLOSED)
			ob_undostate(tree,exit&NO_CLICK,SELECTED);
	}
	return (exit);
}

#ifndef SMALL_NO_MENU
int menu_install(OBJECT *tree,int show)
{
	if (tree!=_menu)
	{
		if (tree==NULL)
		{
			tree = _menu;
			show = 0;
		}
		else if (_menu)
			menu_install(_menu,0);
	}

	if (tree!=NULL && menu_available)
	{
		int succ;

		if (show)
		{
			show = (menu_inst && !_app) ? 100 : 1;
			_menu = tree;
			_inform_buffered(MENU_INIT);
		}
		else
			_menu = NULL;

		beg_update(FALSE,FALSE);
		succ = menu_bar(tree,show);
		end_update(FALSE);

		if (succ)
			return (TRUE);
	}

	_menu = NULL;
	return (FALSE);
}

void menu_item_enable(int obj,int enable)
{
	if (_menu)
	{
		int state = 1;
		if (_menu[obj&0x7fff].ob_state&DISABLED)
			state = 0;
		if (enable)
			enable = 1;
		if (state!=enable)
		{
			beg_update(FALSE,FALSE);
			menu_ienable(_menu,obj,enable);
			end_update(FALSE);
		}
	}
}

void menu_select(int titel,int select)
{
	if (_menu && titel>0)
	{
		beg_update(FALSE,FALSE);
		menu_tnormal(_menu,titel,(select) ? 0 : 1);
		end_update(FALSE);
	}
}

void menu_enable(boolean enable)
{
	if (_menu)
	{
		reg OBJECT *obj = _menu;
		reg int index,title,string;

		if (enable)
			enable = 1;

		beg_update(FALSE,FALSE);
		for (index=title=0,string=1;;obj++,index++)
		{
			switch (obj->ob_type)
			{
			case G_TITLE:
				if (title)
					menu_ienable(_menu,index|0x8000,enable);
				else
					title = 1;
				break;
			case G_STRING:
				if (string)
				{
					menu_ienable(_menu,index,enable);
					string = 0;
				}
			}
			if (obj->ob_flags & LASTOB)
				break;
		}
		end_update(FALSE);
	}
}

boolean menu_dropped(void)
{
	reg OBJECT *obj = _menu;

	if (obj!=NULL)
		do
		{
			obj++;
			if (obj->ob_state & SELECTED)
				return (TRUE);
		} while (!(obj->ob_flags & LASTOB));
	return (FALSE);
}
#endif
