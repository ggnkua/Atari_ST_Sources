
#include <time.h>
#include <string.h>
#include "proto.h"

#ifdef __MINT_LIB__
#include <mintbind.h>
#endif

#define DEFAULT_ERR		"[1][ Zu viele DEFAULT-Schalter! | Nur ein DEFAULT-Schalter | pro Baum m”glich! ][ Ok ]"
#define INDDEFAULT_ERR	"[1][ Zu viele INDDEFAULT-Objekte! | Nur ein INDDEFAULT-Objekt | pro Baum m”glich! ][ Ok ]"
#define HELP_ERR		"[1][ Zu viele HELP-Objekte! | Nur ein HELP-Objekt | pro Baum m”glich! ][ Ok ]"
#define UNDO_ERR		"[1][ Zu viele UNDO-Objekte! | Nur ein UNDO-Objekt | pro Baum m”glich! ][ Ok ]"

#define CHKHOTKEY_ERR_A	"[1][ CHKHOTKEY-Fehler: | Das Text-Objekt fehlt! | (Objekt-Nummer %d) ][ Ok ]"
#define CHKHOTKEY_ERR_B "[1][ CHKHOTKEY-Fehler: | Das HOTKEY-Objekt fehlt! | (Objekt-Nummer %d) ][ Ok ]"
#define RBHOTKEY_ERR_A	"[1][ RBHOTKEY-Fehler: |  Das Text-Objekt fehlt! | (Objekt-Nummer %d) ][ Ok ]"
#define RBHOTKEY_ERR_B	"[1][ RBHOTKEY-Fehler: | Das HOTKEY-Objekt fehlt! | (Objekt-Nummer %d) ][ Ok ]"

#define HOTKEY_ERR		"[1][ HOTKEY-Fehler: | doppelter HOTKEY '%c'! | (Objekt-Nummer %d) ][ Ok ]"

typedef struct _list
{
	X_TEXT			*start;
	int 			index;
	struct _list	*next;
} V_LIST;

const char __ident_e_gem[] = "$Id: EnhancedGEM v" E_GEM_VERSION " $";

int ap_id, multi, aes_version, winx, magx, mint, grhandle, x_handle;
int gr_cw, gr_ch, gr_bw, gr_bh, gr_sw, gr_sh;
int max_w, max_h, colors, colors_available, planes;
int small_font, small_font_id, ibm_font, ibm_font_id, fonts_loaded = FAIL;
int menu_available, search;

GRECT desk;
VRECT clip;
MFDB scr_mfdb;
OBJECT *iconified;
MFDB *screen = &scr_mfdb;
int menu_id = -1;

OBJECT	*_menu;

WIN		_windows[MAX_WINDOWS+1];
int 	_opened,_ac_close,_min_timer,_last_top;

boolean _back_win,_nonsel_fly,_dial_round=TRUE;
int		_bevent,_bottom,_ascii,_ascii_digit,_popup;

char	_cycle_hot='W',_close_hot='U';
int		_cycle,_close,_alert_color=BLACK,_no_av_win;

DIAINFO	*_dia_list[MAX_DIALS+1];
int		_dia_len;

int cdecl (*_icfs)(int,...);

static char *c_arrow[] = {"\x04","\x03","\x01","\x02"};

static int		*cycle_but,*box_on,*box_off,*radio_on,*radio_off;
static int		*arrow_up,*arrow_up_sel,*arrow_down,*arrow_down_sel;
static int		*arrow_left,*arrow_left_sel,*arrow_right,*arrow_right_sel;
static int		mouse_flag,gr_dcw;
static boolean	always_keys,toMouse,return_default=TRUE;
static int		menu_inst,menu_test;

static X_TEXT	v_text[128];
static V_LIST	v_list = {v_text,0,NULL};

static DIAINFO *win_list[MAX_DIALS+1];
static int		win_len = 0, dial_pattern = 0,dial_color = BLACK;
static int		image_w,image_h,big_img;
static boolean	dial_tframe = TRUE,dial_tsmall = FALSE,dial_title = FALSE;
static boolean  menu_nice = TRUE;

static int cdecl draw_fly(PARMBLK *);
static int cdecl draw_text(PARMBLK *);
static int cdecl draw_underline(PARMBLK *);
static int cdecl draw_cyclebutton(PARMBLK *);
static int cdecl draw_box(PARMBLK *);
static int cdecl draw_radiobutton(PARMBLK *);
static int cdecl draw_arrows(PARMBLK *);
static int cdecl draw_menu(PARMBLK *);

static USERBLK	cycleblk = {draw_cyclebutton,1};
static USERBLK	flyblk = {draw_fly,0};
static USERBLK	hotkeyblk = {draw_underline,1};
static USERBLK	checkblk = {draw_box,1};
static USERBLK	rbuttblk = {draw_radiobutton,1};
static USERBLK	unlnblk = {draw_underline,0x0101l};
static USERBLK	arrows = {draw_arrows,1};
static USERBLK  menublk = {draw_menu,0};

static boolean 	open_flydialog(OBJECT *,DIAINFO *,boolean,boolean);
static boolean	open_windialog(OBJECT *,DIAINFO *,char *,char *,OBJECT *,int,boolean,boolean);

static void		redraw_dialog(DIAINFO *,GRECT *,GRECT *);

static DIAINFO	*get_info(int *);
static void 	dial_center(OBJECT *,boolean,int,int);
static void 	dial_pos(OBJECT *,int,int);
static void 	find_fly(DIAINFO *);
static void 	test_inddefault(DIAINFO *);

static void 	vdi_trans(int,int,void *);
static void 	scale_img(int *,int,int,int,int,int);

static void 	mouse_cursor(DIAINFO *,XEVENT *);
static int		klickobj(DIAINFO *,XEVENT *,int *,boolean);
static int		key_handler(DIAINFO *,int,int,XEVENT *);
static int		objekt_handler(DIAINFO *,int,int,int,int,boolean);

static int		is_rb_chk(OBJECT *,int);

static void 	do_jump_fly(DIAINFO *,int,int);

static void 	get_image(IMAGES *,int,BUTTON *,int **,int **);
static void 	set_images(IMAGES *,int **,int **);

static int		do_func(DIAINFO *,int,int,XEVENT *);
static void 	vrt_copy(int *,PARMBLK *,int,int);

void dial_options(boolean round,boolean t_frame,boolean t_small,boolean niceline,boolean ret,boolean back,boolean nonsel,boolean keys,boolean mouse)
{
	reg int old_back = _back_win;

	always_keys = keys;
	_dial_round = round;
	dial_tframe = t_frame;
	dial_tsmall = t_small;
	menu_nice = niceline;
	return_default	= ret;
	_nonsel_fly = nonsel;
	toMouse = mouse;
	_back_win = (back) ? 1 : 0;

	if (_back_win!=old_back && _bevent)
	{
		reg int i;
		reg WIN *wins=_windows;

		for (i=MAX_WINDOWS;--i>=0;wins++)
			if (wins->handle>0 && !(wins->iconified & ICFS))
				wind_set(wins->handle,WF_BEVENT,_back_win);
	}
}

void dial_colors(int d_pattern,int d_color,int popup,int hotkey,int check,int radio,int arrow,int alert)
{
	dial_color	 = d_color;
	dial_pattern = d_pattern;

	cycleblk.ub_parm = popup;
	hotkeyblk.ub_parm = hotkey;
	checkblk.ub_parm = check;
	rbuttblk.ub_parm = radio;
	arrows.ub_parm = arrow;
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

void cycle_image(int index,BUTTON *cycle)
{
	get_image(&_cycles,index,cycle,&cycle_but,NULL);
}

static boolean init_flag;

boolean init_gem(char *m_entry,char *x_name,char *a_name,int av_msgs,int va_msgs,int xacc_msgs)
{
	if (init_flag)
		return(TRUE);
	else if (x_name==NULL || a_name==NULL)
		return (FALSE);

	AES_VERSION = 0;
	if ((ap_id = appl_init())>=0 && (aes_version = AES_VERSION)>0)
	{
		X_ATTR xattr;
		int dummy,info1,info2,work_out[57];

		wind_update(BEG_UPDATE);
		grhandle = graf_handle(&gr_cw,&gr_ch,&gr_bw,&gr_bh);
		gr_dcw = gr_cw<<1;

		if (open_work(&x_handle,work_out))
		{
			long value;

			multi = (GLOBAL[1]!=1);

			max_w = work_out[0]+1;
			max_h = work_out[1]+1;
			colors = work_out[13];
			colors_available = work_out[39];

			vq_extnd(x_handle,1,work_out);
			planes = work_out[4];

			if (get_cookie(COOKIE_MAGX,&value) && value!=0l)
			{
				magx = ((int **) value)[2][24];
				if (magx<0x0200)
					magx = 0;
			}

			if (get_cookie(COOKIE_MINT,&value))
				mint = (int) value;

		#ifndef __MINT_LIB__
			Pdomain(1);
		#endif

			_dd_available = ((Dsetdrv(Dgetdrv()) & (1l<<('U'-'A'))) && Fxattr(0,"U:\\PIPE",(void *) &xattr)==0);

			if (wind_xget(0,WF_RETURN,&dummy,&dummy,&dummy,&dummy)==0)
		    {
		    	int version;
				wind_xget(0,WF_WINX,&version,&dummy,&dummy,&dummy);
				winx = (version & 0x0fff);
				if (winx<0x0210)
					winx = 0;
			}

			appl_xgetinfo(12,&info1,&dummy,&dummy,&dummy);
			if ((info1 & 384)!=384)
				if (!get_cookie(COOKIE_ICFS,(long *) &_icfs) || _icfs==NULL)
					_icfs = _default_icfs;

			appl_xgetinfo(11,&info1,&dummy,&dummy,&dummy);
			_bottom = (aes_version>=0x0331 || winx || (info1 & 64));
			_bevent = (aes_version>=0x0331 || winx || (info1 & 32));
			_min_timer = (aes_version>=0x0140) ? 0 : 1;

			appl_xgetinfo(6,&dummy,&dummy,&info1,&info2);
			menu_available = (_app || magx);
			menu_inst = (magx || info2);
			menu_test = (aes_version>=0x0400 || info1);

			search = (aes_version>=0x0400 || magx || (appl_xgetinfo(4,&dummy,&dummy,&info1,&dummy) && info1>0));

			if (m_entry && m_entry[0] && (!_app || aes_version>=0x0400))
			{
				menu_id = menu_register(ap_id,m_entry);
				if (_app)
					menu_id = -1;
			}
			else
				menu_id = -1;

			appl_getfontinfo(0,&ibm_font,&ibm_font_id,&dummy);
			appl_getfontinfo(1,&small_font,&small_font_id,&dummy);

			vst_font(x_handle,small_font_id);
			vst_height(x_handle,small_font,&dummy,&dummy,&gr_sw,&gr_sh);

			vs_attr();
			v_set_text(ibm_font_id,ibm_font,BLACK,NULL);
			vst_alignment(x_handle,0,5,&dummy,&dummy);

			v_set_mode(MD_REPLACE);
			v_set_line(BLACK,1);
			vsl_type(x_handle,1);
			vsl_ends(x_handle,0,0);
			vsl_udsty(x_handle,0x5555);

			v_set_fill(BLACK,1,1);
			vsf_perimeter(x_handle,1);

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
			_clip_rect(&desk);

			_scrp_init();
			MouseArrow();
			if (aes_version>=0x0400 || (appl_xgetinfo(10,&info1,&dummy,&dummy,&dummy) && (info1 & 0xff)>=9))
				shel_write(9,0,0x01,NULL,NULL);

			_XAccSendStartup(x_name,a_name,av_msgs,va_msgs,xacc_msgs);

			wind_update(END_UPDATE);
			init_flag = TRUE;
			return(TRUE);
		}
		else
		{
			wind_update(END_UPDATE);
			appl_exit();
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

static int has_agi = FAIL;

int appl_xgetinfo(int type,int *out1,int *out2,int *out3,int *out4)
{
	int back = 0;

	if (has_agi==FAIL)
		has_agi = (aes_version>=0x400 || magx || winx || appl_find("?AGI")==0) ? TRUE : FALSE;

	if (has_agi)
		back = appl_getinfo(type,out1,out2,out3,out4);

	if (back==0)
		*out1 = *out2 = *out3 = *out4 = 0;

	return (back);
}

int appl_getfontinfo(int ap_gtype,int *height,int *id,int *type)
{
	int dummy,attrib[10];

	vs_attr();

	if (appl_xgetinfo(ap_gtype,height,id,type,&dummy))
	{
		if (*id==-12124)
			*id = 1;

		if (vst_font(x_handle,*id)!=*id && fonts_loaded<0 && vq_gdos())
			fonts_loaded = vst_load_fonts(x_handle,0);

		return (TRUE);
	}

	vqt_attributes(grhandle,attrib);
	*id = attrib[0];

	if (vst_font(x_handle,*id)!=*id && fonts_loaded<0 && vq_gdos())
		fonts_loaded = vst_load_fonts(x_handle,0);

	if (ap_gtype==1)
	{
		vst_font(x_handle,*id);
		vst_point(x_handle,1,&dummy,&dummy,&dummy,&dummy);
		vqt_attributes(x_handle,attrib);
	}

	*height = attrib[7];
	*type = 0;

	return(TRUE);
}

void exit_gem(int result)
{
	if (init_flag)
	{
		if (_menu)
			menu_install(_menu,FALSE);

		close_all_windows();
		_XAccAvExit();

		if (fonts_loaded>=0)
		{
			vst_unload_fonts(x_handle,0);
			fonts_loaded = FAIL;
		}

		close_work(x_handle);
		if (_app)
			appl_exit();
		else
			evnt_timer(0,32000);
	}

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
	reg unsigned char type = (unsigned char) obj->ob_type;

	if (type!=G_ICON && type!=G_IMAGE)
		return;

	if (orig_cw<=1)
		orig_cw = 8;

	if (orig_ch<=1)
		orig_ch = 16;

	if (scaling & TEST_SCALING)
	{
		if (orig_cw==gr_cw && orig_ch==gr_ch)
			return;
		else
			scaling |= SCALING;
	}

	if (scaling & SCALING)
	{
		if (gr_cw>=orig_cw && gr_ch>=orig_ch)
		{
			obj->ob_x += (obj->ob_width-(obj->ob_width*orig_cw)/gr_cw)>>1;
			obj->ob_y += (obj->ob_height-(obj->ob_height*orig_ch)/gr_ch)>>1;
		}
		else if (type==G_ICON)
		{
			ICONBLK *icn = obj->ob_spec.iconblk;

			if (icn->ib_hicon>3)
			{
				reg int ow,oh,nw,nh;

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
				reg int ow,oh,nw,nh;

				ow = nw = blk->bi_wb<<3;
				oh = nh = blk->bi_hl;

				scale_coords(nw,nh,orig_cw,orig_ch);
				blk->bi_hl = nh;
				scale_coords(blk->bi_x,blk->bi_y,orig_cw,orig_ch);

				scale_img((int *) blk->bi_pdata,ow,oh,nw,nh,scaling);
			}
		}
	}
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

static void vrt_copy(int *image,PARMBLK *pb,int color,int selected)
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
		col[0] = 0;
	}
	else
	{
		col[0] = color;
		col[1] = 0;
	}
	mfdb(&src,image,16,image_h,0,1);
	vrt_cpyfm(x_handle,1,pxy,&src,screen,col);
}

void rsrc_calc(OBJECT *tree,int scaling,int orig_cw,int orig_ch)
{
	reg OBJECT *obj=tree;
	reg int index=0,low_byte=0x00ff,scale=FALSE;
	int rest_x,rest_y,rest_w,rest_h;

	if (orig_cw>1 && orig_ch>1)
		if (orig_cw!=gr_cw || orig_ch!=gr_ch)
		{
			scale = TRUE;

			do
			{
				obj++;

				if (obj->ob_type==G_TITLE)
				{
					scale = FALSE;
					break;
				}
			} while (!(obj->ob_flags & LASTOB));

			obj = tree;
		}

	for (;;)
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

			rsrc_obfix(tree,index++);

			if (rest_x)
				obj->ob_x += (rest_x*gr_cw)/orig_cw;
			if (rest_y)
				obj->ob_y += (rest_y*gr_ch)/orig_ch;
			if (rest_w)
				obj->ob_width += (rest_w*gr_cw)/orig_cw;
			if (rest_h)
				obj->ob_height += (rest_h*gr_ch)/orig_ch;
		}
		else
			rsrc_obfix(tree,index++);

		if (obj->ob_x==0 && obj->ob_width>max_w)
			obj->ob_width = max_w;

		if (obj->ob_flags & LASTOB)
			break;

		obj++;
	}

	fix_objects(tree,scaling,orig_cw,orig_ch);
}

void rsrc_init(int n_tree,int n_obs,int n_frstr,int n_frimg,int scaling,char **rs_strings,long *rs_frstr,BITBLK *rs_bitblk,
			   long *rs_frimg,ICONBLK *rs_iconblk,TEDINFO *rs_tedinfo,OBJECT *rs_object,OBJECT **rs_trindex,RS_IMDOPE *rs_imdope,int orig_cw,int orig_ch)
{
	reg OBJECT  *obj;
	reg int tree,obi,index;

	for (obj = rs_object; obj < (rs_object+n_obs); obj++)
	{
		switch((unsigned char) obj->ob_type)
		{
		case G_TEXT:
		case G_BOXTEXT:
		case G_FTEXT:
		case G_FBOXTEXT:
			obj->ob_spec.tedinfo = &rs_tedinfo[obj->ob_spec.index];
			obj->ob_spec.tedinfo->te_ptext = rs_strings[(int) obj->ob_spec.tedinfo->te_ptext];
			obj->ob_spec.tedinfo->te_ptmplt = rs_strings[(int) obj->ob_spec.tedinfo->te_ptmplt];
			obj->ob_spec.tedinfo->te_pvalid = rs_strings[(int) obj->ob_spec.tedinfo->te_pvalid];
			break;
		case G_BUTTON:
		case G_STRING:
		case G_TITLE:
			obj->ob_spec.free_string = rs_strings[(int) obj->ob_spec.index];
			break;
		case G_IMAGE:
			index = (int) obj->ob_spec.index,
			rs_bitblk[index].bi_pdata = (void *) rs_imdope[(int) rs_bitblk[index].bi_pdata].image;
			obj->ob_spec.bitblk = &rs_bitblk[index];
			break;
		case G_ICON:
			index = (int) obj->ob_spec.index,
			rs_iconblk[index].ib_pmask = rs_imdope[(int) rs_iconblk[index].ib_pmask].image;
			rs_iconblk[index].ib_pdata = rs_imdope[(int) rs_iconblk[index].ib_pdata].image;
			rs_iconblk[index].ib_ptext = rs_strings[(int) rs_iconblk[index].ib_ptext];
			obj->ob_spec.iconblk = &rs_iconblk[index];
			break;
		}
	}

	for (obi=0;obi<n_frstr;obi++)
		rs_frstr[obi] = (long) rs_strings[(int) rs_frstr[obi]];

	for (obi=0;obi<n_frimg;obi++)
	{
		index = (int) rs_frimg[obi];
		rs_bitblk[index].bi_pdata = (void *) rs_imdope[(int) rs_bitblk[index].bi_pdata].image;
		rs_frimg[obi] = (long) &rs_bitblk[index];
	}

	for (tree = 0; tree < n_tree; tree++)
	{
		rs_trindex[tree] = &rs_object[(int) rs_trindex[tree]];
		rsrc_calc(rs_trindex[tree],scaling,orig_cw,orig_ch);
	}
}

void fix_objects(OBJECT *tree,int scaling,int orig_cw,int orig_ch)
{
	reg OBJECT *org=tree;
	reg int xtype,modal,index=0;

	do
	{
		tree++;index++;

		switch ((unsigned char) tree->ob_type)
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

				switch(xtype)
				{
				case HEADER:
					{
						reg OBJECT *par = &org[ob_get_parent(org,index)];
						reg int frame = par->ob_spec.obspec.framesize;
						tree->ob_y -= (tree->ob_height>>1) + (1 - frame);
						if (frame<0)
							tree->ob_y++;
						if (par->ob_state & OUTLINED)
							tree->ob_y--;
					}
					break;
				case CHECKBOX:
				case CHKHOTKEY:
					if (xtype==CHKHOTKEY)
						tree->ob_type = G_CHK;
					else
						tree->ob_type = G_USERDEF;
					tree->ob_spec.userblk=&checkblk;
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
					if (xtype == RBHOTKEY)
						tree->ob_type = G_RB;
					else
						tree->ob_type = G_USERDEF;
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
					{
						reg OBJECT *par = &org[ob_get_parent(org,index)];

						if (xtype == INDHOTKEY)
							tree->ob_type = G_IND;
						else
							tree->ob_type = G_HOTKEY;

						tree->ob_state &= 0x00ff;
						tree->ob_state |= UpperChar(tree->ob_spec.obspec.character)<<8;
						tree->ob_height = 1;
						tree->ob_spec.userblk = &hotkeyblk;

						switch((unsigned char) par->ob_type)
						{
						case G_TEXT:
						case G_FTEXT:
							if (par->ob_spec.tedinfo->te_font==SMALL)
								tree->ob_y = ((par->ob_height+gr_sh)>>1)+2;
							else
								tree->ob_y = ((par->ob_height+gr_ch)>>1) - 1;
							break;
						case G_BOXTEXT:
						case G_FBOXTEXT:
							if (par->ob_spec.tedinfo->te_font==SMALL)
							{
								tree->ob_y = ((par->ob_height+gr_sh)>>1)+2;
								break;
							}
						case G_BUTTON:
						case G_BOXCHAR:
							if (par->ob_height==gr_ch)
							{
								if (big_img==TRUE)
								{
									par->ob_height += 3;
									par->ob_y--;
								}
								else
									par->ob_height++;
							}

							tree->ob_y = (par->ob_height>>1)+(gr_ch>>1);
							break;
						default:
							tree->ob_y = gr_ch - 1;
						}
					}
					break;
				case FLYDIAL:
					tree->ob_spec.userblk = &flyblk;
					tree->ob_type = G_FLY;

					tree->ob_x = org->ob_width - gr_dcw - 1;
					tree->ob_y = -3;
					tree->ob_width = gr_dcw + 4;
					tree->ob_height = gr_ch + 4;
					break;
				case ATTR_TEXT:
					{
						reg char *string = NULL;
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
							{
								TEDINFO *ted = tree->ob_spec.tedinfo;

								string = ted->te_ptext;

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
									if (font_id!=small_font_id && font_id!=ibm_font_id && fonts_loaded<0 && vq_gdos())
										fonts_loaded = vst_load_fonts(x_handle,0);
								}

								color = (ted->te_color>>8) & 15;
								mode = (ted->te_color & 128) ? MD_REPLACE : MD_TRANS;
								center = ted->te_just;
							}
							break;
						}

						if (string)
						{
							reg V_LIST *list = &v_list;
							reg X_TEXT *v_text;

							for (;;)
							{
								if (list->index<128)
								{
									v_text = list->start + list->index;
									list->index++;
									break;
								}
								else if (list->next)
									list = list->next;
								else
								{
									list->next = (V_LIST *) calloc(1,sizeof(V_LIST));
									if ((list = list->next)!=NULL)
									{
										if ((v_text = list->start = (X_TEXT *) calloc(128,sizeof(X_TEXT)))==NULL)
											Mfree(list);
									}
									else
										v_text = NULL;
									break;
								}
							}

							if (v_text)
							{
								v_text->text_blk.ub_code = draw_text;
								v_text->text_blk.ub_parm = (long) v_text;

								v_text->font_id	= font_id;
								v_text->font_size = font_size;
								v_text->color = color;
								v_text->center = center;
								v_text->mode = mode;
								v_text->string = string;

								tree->ob_type = G_XTEXT;
								tree->ob_flags &= ~EDITABLE;
								tree->ob_spec.userblk = &v_text->text_blk;
							}
						}
					}
					break;
				default:
					if (tree->ob_type==G_STRING && (tree->ob_state & DISABLED))
						if (tree->ob_spec.free_string[0]=='-')
						{
							tree->ob_type = G_USERDEF;
							tree->ob_spec.userblk = &menublk;
						}
				}
				tree->ob_type |= modal;
			}
		}
	}
	while(!(tree->ob_flags & LASTOB));
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
	int x,y,w,h;

	switch (center)
	{
	case TRUE:
		{
			_mouse_pos(&x,&y);
			tree->ob_x = x - (tree->ob_width>>1);
			tree->ob_y = y - (tree->ob_height>>1);
			break;
		}
	case FAIL:
		if (tree->ob_x>=desk.g_x && tree->ob_y>=desk.g_y)
			break;
	case FALSE:
		{
			INFOVSCR *vscr;

			form_center(tree,&x,&y,&w,&h);
			if (get_cookie(COOKIE_VSCR,(long *) &vscr) && (vscr->cookie==COOKIE_XBRA))
			{
				tree->ob_x = vscr->x + ((vscr->w - w)>>1);
				tree->ob_y = vscr->y + ((vscr->h - h)>>1);
			}
		}
	}
	dial_pos(tree,xy,wh);
}

static void dial_pos(OBJECT *tree,int xy,int wh)
{
	reg int d;

	if ((d=(tree->ob_x + tree->ob_width + wh)) > clip.v_x2)
		tree->ob_x -= d - clip.v_x2;

	if (_dial_round)
	{
		tree->ob_x &= 0xFFF8;
		if (tree->ob_x < (clip.v_x1+xy))
			tree->ob_x = (clip.v_x1+xy+7) & 0xFFF8;
	}
	else
		Max(&tree->ob_x,clip.v_x1+xy);

	if ((d=(tree->ob_y + tree->ob_height + wh)) > clip.v_y2)
		tree->ob_y -= d - clip.v_y2;
	Max(&tree->ob_y,clip.v_y1+xy);
}

static WIN fly={0,0,0,0,0,0,0,0};

static boolean open_flydialog(OBJECT *tree, DIAINFO *info, boolean center,boolean box)
{
	if (_dia_len<MAX_DIALS && (_dia_len==0 || _dia_list[_dia_len-1]->di_flag!=OPENED))
	{
		_beg_ctrl();
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
		find_fly(info);

		if (box)
			graf_growbox (max_w>>1,max_h>>1,1,1,tree->ob_x,tree->ob_y,tree->ob_width,tree->ob_height);
		_dia_list[_dia_len++] = info;

		return (TRUE);
	}
	else
		return (FALSE);
}

void close_dialog(DIAINFO *info,boolean box)
{
	reg OBJECT *tree=info->di_tree;

	switch (info->di_flag)
	{
	case WINDOW:
	case WIN_MODAL:
		{
			reg int i;

			for (i=0;i<win_len;i++)
				if (win_list[i]==info)
					break;

			if (i>=win_len)
				return;

			win_len = max(win_len-1,0);
			for (;i<win_len;i++)
				win_list[i] = win_list[i+1];

		#ifndef SMALL_EGEM
			_insert_history(info);
		#endif

			close_window(info->di_win,box);

			if (info->di_flag==WIN_MODAL && _menu!=NULL)
			{
				for (i=win_len;--i>=0;)
					if (win_list[i]->di_flag==WIN_MODAL)
						break;
				if (i<0)
					menu_enable(TRUE);
			}
		}
		break;
	case OPENED:
	case FLYING:
		{
			if (_dia_len==0 || info!=_dia_list[_dia_len-1])
				return;

			_dia_len = max(_dia_len-1,0);

		#ifndef SMALL_EGEM
			_insert_history(info);
		#endif

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

			_end_ctrl();
			_reset_mouse();
		}
	}

	memset(info,0,sizeof(DIAINFO));
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

int get_dialog_info(int *fly_dials,int *win_dials,int *wins,DIAINFO **top)
{
	if (fly_dials)
		*fly_dials = _dia_len;
	if (win_dials)
		*win_dials = win_len;
	if (wins)
		*wins = _opened;

	if (_popup)
		return (FAIL);
	else if (_dia_len>0)
	{
		if (top)
			*top = _dia_list[_dia_len-1];
		return (FALSE);
	}
	else if (menu_dropped())
		return (FAIL);
	else
		return (TRUE);
}

boolean open_dialog(OBJECT *tree,DIAINFO *info,char *win_name,char *icon_name,OBJECT *icon,
                    boolean center,boolean box,int mode,int edit,SLINFO **slider)
{
	reg OBJECT *obj = tree;
#ifdef SMALL_EGEM
	reg int i,modal,type,flg;
#else
	reg int i,eobjc,iobjc,modal,type,flg;
	int old_ed = info->di_ed_obj,old_index = info->di_ed_index;
	int edit_rect[4],ob_x,ob_y;
#endif
	memset((void *) info,0,sizeof(DIAINFO));
	for (i=0;i<win_len;i++)
		if (win_list[i]->di_flag==WIN_MODAL)
		{
			mode |= MODAL;
			break;
		}

	do
	{
		obj++;
		modal = obj->ob_type & (G_MODAL|G_UNMODAL);
		if (((obj->ob_type & G_TYPE)>>8)==HEADER)
		{
			switch((unsigned char) obj->ob_type)
			{
			case G_TEXT:
			case G_BOXTEXT:
				if (dial_tframe)
					obj->ob_type = G_BOXTEXT|modal;
				else
					obj->ob_type = G_TEXT|modal;
				goto _set_title;
			case G_FTEXT:
			case G_FBOXTEXT:
				if (dial_tframe)
					obj->ob_type = G_FBOXTEXT|modal;
				else
					obj->ob_type = G_FTEXT|modal;
				_set_title:
				obj->ob_type |= (HEADER<<8);
				obj->ob_spec.tedinfo->te_font = (dial_tsmall) ? SMALL : IBM;
				obj->ob_spec.tedinfo->te_just = (dial_tframe) ? 2 : 0;
				break;
			}
		}
	}
	while (!(obj->ob_flags & LASTOB));

	tree->ob_state |= OUTLINED;
	tree->ob_state &= ~SHADOWED;

	tree->ob_spec.obspec.interiorcol = dial_color;
	tree->ob_spec.obspec.fillpattern = dial_pattern;
	tree->ob_spec.obspec.framecol	 = BLACK;

	if ((mode & WIN_DIAL)==0 || _dia_len>0 || open_windialog(tree,info,win_name,icon_name,icon,mode,center,box)==FALSE)
		if (mode & FLY_DIAL)
			open_flydialog(tree,info,center,box);

	if (info->di_flag>CLOSED)
	{
		if (slider!=NULL && *slider!=NULL)
		{
			info->di_slider = (void *) slider;
			while (*slider!=NULL)
				(*slider++)->sl_info = info;
		}

	#ifndef SMALL_EGEM
		edit_rect[0] = max_w;
		edit_rect[1] = max_h;
		edit_rect[2] = edit_rect[3] = 0;

		if (edit<=0)
			edit = old_ed;

		eobjc = iobjc = FAIL;
	#endif

		info->di_insert = TRUE;
		info->di_inddef = info->di_ed_obj = info->di_ed_index = info->di_default = info->di_help = info->di_undo = FAIL;

		modal = (info->di_flag!=WINDOW);
		obj = tree;
		i = 0;

		do
		{
			obj++;
			i++;

			type = obj->ob_type;
			if (type & G_MODAL)
			{
				if (modal)
					obj->ob_flags &= ~HIDETREE;
				else
					obj->ob_flags |= HIDETREE;
			}
			else if (type & G_UNMODAL)
			{
				if (modal)
					obj->ob_flags |= HIDETREE;
				else
					obj->ob_flags &= ~HIDETREE;
			}

			type &= G_TYPE;
			if ((flg = obj->ob_flags) & DEFAULT)
			{
				if (!_is_hidden(tree,i))
				{
				#ifdef DEBUG
					if (info->di_default>0)
						form_alert(1,DEFAULT_ERR);
					else
				#endif
						info->di_default = i;
				}
			}

		#ifndef SMALL_EGEM
			if (flg & EDITABLE)
			{
				if ((unsigned char) type!=G_FTEXT && (unsigned char) type!=G_FBOXTEXT)
					obj->ob_flags &= ~EDITABLE;
				else if (!_is_hidden(tree,i))
				{
					objc_offset(tree,i,&ob_x,&ob_y);

					Min(&edit_rect[0],ob_x);
					Min(&edit_rect[1],ob_y);
					Max(&edit_rect[2],ob_x+obj->ob_width-1);
					Max(&edit_rect[3],ob_y+obj->ob_height-1);

					info->di_ed_cnt++;

					if ((type>>8)==TXTDEFAULT)
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
			{
				type >>= 8;
				if (type==HELP_BTN && !_is_hidden(tree,i))
				{
					if (info->di_help>0)
						form_alert(1,HELP_ERR);
					else
						info->di_help = i;
				}
				else if (type==UNDO_BTN && !_is_hidden(tree,i))
				{
					if (info->di_undo>0)
						form_alert(1,UNDO_ERR);
					else
						info->di_undo = i;
				}
			}
		#else
			type >>= 8;
			if (type==HELP_BTN && !_is_hidden(tree,i))
				info->di_help = i;
			else if (type==UNDO_BTN && !_is_hidden(tree,i))
				info->di_undo = i;
		#endif
		}
		while (!(flg & LASTOB));

	#ifndef SMALL_EGEM
		rc_array_to_grect(edit_rect,&info->di_edit);
		info->di_edit.g_x -= tree->ob_x;
		info->di_edit.g_y -= tree->ob_y;
	#endif

		if (info->di_flag<WINDOW)
		{
			objc_draw(tree,ROOT,MAX_DEPTH,desk.g_x,desk.g_y,desk.g_w,desk.g_h);
			info->di_drawn = TRUE;
		}

	#ifdef DEBUG
		_check_hotkeys(tree);
	#endif

	#ifndef SMALL_EGEM
		if (eobjc>0)
			_set_cursor(info,eobjc,(eobjc==old_ed && old_index>=0) ? old_index : 0x1000);

		if (iobjc>0 && info->di_default>0 && iobjc!=info->di_default)
		{
			info->di_inddef = iobjc;
			test_inddefault(info);
		}
	#endif

		return(TRUE);
	}
	else
		return(FALSE);
}

void _set_menu(void)
{
	if (_cycle>0)
		menu_item_enable(_cycle,(_opened>1) ? 1 : 0);
	if (_close>0)
		menu_item_enable(_close,(_opened>0) ? 1 : 0);
}

static void dial_calc(DIAINFO *info,OBJECT *tree,GRECT *out)
{
	*out = *(GRECT *) &tree->ob_x;
	out->g_x -= info->di_xy_off;
	out->g_y -= info->di_xy_off;
	out->g_w += info->di_wh_off;
	out->g_h += info->di_wh_off;
}

static boolean open_windialog(OBJECT *tree,DIAINFO *info,char *win_name,char *icon_name,OBJECT *icon,int mode,boolean center,boolean box)
{
	if (win_len<MAX_DIALS)
	{
		GRECT in,area;
		int typ = NAME|MOVER;

		info->di_mode = mode;

		if (!(mode & MODAL))
			typ |= CLOSER;

		if (!(mode & NO_ICONIFY))
			typ |= SMALLER;

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

		if (mode & FRAME)
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
		dial_calc(info,tree,&in);
		window_calc(WC_BORDER,typ,&in,&area);

		if (_dial_round)
			while (area.g_x<clip.v_x1)
			{
				tree->ob_x += 8;
				area.g_x += 8;
			}
		else if (area.g_x<clip.v_x1)
		{
			tree->ob_x = clip.v_x1 - area.g_x;
			area.g_x = clip.v_x1;
		}

		if (area.g_y<clip.v_y1)
		{
			tree->ob_y += clip.v_y1 - area.g_y;
			area.g_y = clip.v_y1;
		}

		_no_av_win = (tree==_alert_tree);
		if ((info->di_win=open_window(win_name,icon_name,NULL,icon,typ,box,0,0,NULL,&area,NULL,(R_PROC) redraw_dialog))!=NULL)
		{
			info->di_win->dialog = (void *) info;

			if (mode & MODAL)
			{
				menu_enable(FALSE);
				info->di_flag = WIN_MODAL;
			}
			else
				info->di_flag = WINDOW;

			info->di_title = win_name;
			info->di_tree = tree;

			find_fly(info);
			win_list[win_len++]=info;
			return(TRUE);
		}
	}
	return(FALSE);
}

static void move_dialog(DIAINFO *info,GRECT *area)
{
	reg WIN *win = info->di_win;
	reg int fulled = rc_equal(area,&win->max);

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

static void redraw_dialog(DIAINFO *info,GRECT *area,GRECT *cursor)
{
	objc_draw(info->di_tree,ROOT,MAX_DEPTH,area->g_x,area->g_y,area->g_w,area->g_h);
	if (info->di_cursor && rc_intersect(cursor,area))
		rc_sc_invert(area);
}

static int cdecl draw_underline(PARMBLK *pb)
{
	reg OBJECT *tree = pb->pb_tree,*obj = tree + pb->pb_obj;
	reg int d,x1,x2,disabled,type = ((obj->ob_type & G_TYPE)==G_USERDEF);

	if (type)
	{
		if ((d=(int) (pb->pb_parm>>8))==0)
			d = obj->ob_state>>8;
		_vdi_attr(MD_REPLACE,d,(char) pb->pb_parm);
		disabled = 0;
	}
	else
	{
		disabled = tree[ob_get_parent(tree,pb->pb_obj)].ob_state;
		_vdi_attr((disabled & SELECTED) ? MD_XOR : MD_REPLACE,d=1,(char) (pb->pb_parm));

		if ((disabled &= DISABLED)!=0)
			vsl_type(x_handle,7);
	}

	if (type && dial_title)
	{
		x1 = tree->ob_x + gr_cw;
		x2 = tree->ob_x + tree->ob_width - gr_cw - 1;
	}
	else
	{
		x1 = pb->pb_x;
		x2 = pb->pb_x + pb->pb_w - 1;
	}
	_line(x1,pb->pb_y,x2,pb->pb_y);

	if (type && (obj->ob_state & OUTLINED))
	{
		d += d;
		_line(x1,pb->pb_y+d,x2,pb->pb_y+d);
	}

	if (disabled)
		vsl_type(x_handle,1);
	return (0);
}

static int cdecl draw_box(PARMBLK *pb)
{
	reg OBJECT *obj = &pb->pb_tree[pb->pb_obj];
	reg int disabled = ((pb->pb_tree[obj->ob_next].ob_state)|obj->ob_state) & DISABLED;
	reg int color = (int) pb->pb_parm;

	if (obj->ob_state & CHECKED)
	{
		_vdi_attr(MD_REPLACE,1,color);
		_bar(pb->pb_x+1,pb->pb_y+1,pb->pb_w-3,pb->pb_h-3,2,4,color);
	}
	else if (big_img==FAIL)
	{
		reg int x = pb->pb_x+1,y = pb->pb_y+1,w = pb->pb_w-3,h=pb->pb_w-3;

		_vdi_attr(MD_REPLACE,1,color);
		_bar(x,y,w,h,0,FAIL,color);

		if (pb->pb_currstate & SELECTED)
		{
			_line(x,y,x+w,y+h);
			_line(x+w,y,x,y+h);
		}
	}
	else if (pb->pb_currstate & SELECTED)
		vrt_copy(box_on,pb,color,0);
	else
		vrt_copy(box_off,pb,color,0);
	return (disabled);
}

static int cdecl draw_cyclebutton(PARMBLK *pb)
{
	reg int color = (int) pb->pb_parm,w,h;

	w = gr_dcw;
	h = gr_ch;
	if (big_img==FAIL)
		w--;

	pb->pb_x++;
	pb->pb_y++;
	pb->pb_w = w;
	pb->pb_h = h;

	_vdi_attr(MD_REPLACE,1,color);
	_bar(pb->pb_x+2,pb->pb_y+2,w,h,1,FAIL,color);

	if (big_img==FAIL)
	{
		_bar(pb->pb_x-1,pb->pb_y-1,w+1,h+1,0,FAIL,color);
		v_set_text(ibm_font_id,ibm_font,color,NULL);
		v_gtext(x_handle,pb->pb_x+(gr_cw>>1),pb->pb_y,"\x02");
		if (pb->pb_currstate & SELECTED)
			rc_sc_invert((GRECT *) &pb->pb_x);
	}
	else
	{
		_rectangle(pb->pb_x-1,pb->pb_y-1,pb->pb_x+w,pb->pb_y+h);
		vrt_copy(cycle_but,pb,color,pb->pb_currstate & SELECTED);
	}

	return(pb->pb_currstate & DISABLED);
}

static int cdecl draw_radiobutton(PARMBLK *pb)
{
	reg OBJECT *obj = &pb->pb_tree[pb->pb_obj];
	reg int disabled = ((pb->pb_tree[obj->ob_next].ob_state)|obj->ob_state) & DISABLED;

	if (big_img==FAIL)
	{
		reg int color = (int) pb->pb_parm;

		_vdi_attr(MD_REPLACE,1,color);
		_bar(pb->pb_x+1,pb->pb_y+1,pb->pb_w-3,pb->pb_h-3,0,FAIL,color);
		if ((pb->pb_currstate & SELECTED) && !disabled)
			_bar(pb->pb_x+4,pb->pb_y+4,pb->pb_w-9,pb->pb_h-9,1,FAIL,color);
	}
	else if (pb->pb_currstate & SELECTED)
		vrt_copy(radio_on,pb,(int) pb->pb_parm,0);
	else
		vrt_copy(radio_off,pb,(int) pb->pb_parm,0);
	return(disabled);
}

static int cdecl draw_arrows(PARMBLK *pb)
{
	reg int type = (pb->pb_tree[pb->pb_obj].ob_type & G_TYPE)>>8,color = (int) pb->pb_parm;

	_vdi_attr(MD_REPLACE,1,color);
	if (big_img==FAIL)
	{
		_bar(pb->pb_x-1,pb->pb_y-1,gr_dcw+1,gr_ch+1,0,FAIL,(pb->pb_currstate & OUTLINED) ? color : 0);
		v_set_text(ibm_font_id,ibm_font,color,NULL);
		v_gtext(x_handle,pb->pb_x+(gr_cw>>1),pb->pb_y,c_arrow[type-ARROW_LEFT]);
		if (pb->pb_currstate & SELECTED)
			rc_sc_invert((GRECT *) &pb->pb_x);
	}
	else
	{
		reg int *but,*sel;

		if (pb->pb_currstate & OUTLINED)
			_rectangle(pb->pb_x-1,pb->pb_y-1,pb->pb_x+gr_dcw,pb->pb_y+gr_ch);

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
		{
			if (sel)
				vrt_copy(sel,pb,color,0);
			else
				vrt_copy(but,pb,color,1);
		}
		else
			vrt_copy(but,pb,color,0);
	}
	return(pb->pb_currstate & DISABLED);
}

static int cdecl draw_fly(PARMBLK *pb)
{
	reg int pxy[6],w=pb->pb_w-1,h=pb->pb_h-1;

	_vdi_attr(MD_REPLACE,1,BLACK);
	_bar(pb->pb_x,pb->pb_y,w,h,0,FAIL,BLACK);

	if (pb->pb_tree->ob_state & OUTLINED)
	{
		pxy[0] = pb->pb_x + 3;
		pxy[3] = pxy[1] = pb->pb_y + 3;
		pxy[4] = pxy[2] = pb->pb_x + pb->pb_w - 4;
		pxy[5] = pb->pb_y + pb->pb_h - 4;
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

	_line(pb->pb_x,pb->pb_y,pb->pb_x + w,pb->pb_y + h);
	return(pb->pb_currstate & ~SELECTED);
}

static int cdecl draw_text(PARMBLK *pb)
{
	reg X_TEXT *text = (X_TEXT *) pb->pb_parm;
	reg int state = pb->pb_tree[pb->pb_obj].ob_state,effect = 0,color = text->color,x=pb->pb_x,y=pb->pb_y;
	reg int pxy[8];

	v_set_mode(text->mode);
	v_set_text(text->font_id,text->font_size,color,NULL);

	if (state & SELECTED)
		effect |= 1;
	if (state & CHECKED)
		effect |= 8;
	if (state & CROSSED)
		effect |= 4;
	if (state & DISABLED)
		effect |= 2;
	if (state & OUTLINED)
		effect |= 16;

	if (state & SHADOWED)
	{
		vst_effects(x_handle,effect|2);

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

		v_gtext(x_handle,x+2,y+2,(char *) text->string);
		vst_effects(x_handle,effect);
	}
	else
	{
		vst_effects(x_handle,effect);

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
	}

	v_gtext(x_handle,x,y,(char *) text->string);

	if (effect)
		vst_effects(x_handle,0);

	return(FALSE);
}

static int cdecl draw_menu(PARMBLK *pb)
{
	reg int pxy[4];

	v_set_mode(MD_REPLACE);
	v_set_fill(BLACK,2,4);

	pxy[0] = pb->pb_x;
	pxy[1] = pb->pb_y + (pb->pb_h>>1) - 1;
	pxy[2] = pxy[0] + pb->pb_w - 1;
	pxy[3] = pxy[1] + 1;
	vr_recfl(x_handle,pxy);

	return(FALSE);
}

#ifndef SMALL_EGEM
static void test_inddefault(DIAINFO *info)
{
	reg char *text = ob_get_text(info->di_tree,info->di_inddef,0);
	if (text!=NULL)
		ob_disable(info,info->di_tree,info->di_default,(*text!='\0') ? CLEAR_STATE : SET_STATE,info->di_drawn);
}
#endif

void _init_xformdo(XEVENT *event,DIAINFO *info,int top)
{
	if (_dia_len>0)
		event->ev_mflags = MU_KEYBD|MU_BUTTON|MU_NO_HANDLER;
	else
		event->ev_mflags = MU_KEYBD|MU_BUTTON|MU_MESAG|MU_NO_HANDLER;

#ifndef SMALL_EGEM
	if (info==NULL)
	{
		int dummy;

		info = get_info(&dummy);
		top = dummy;
	}

	_ascii = _ascii_digit = 0;

	if (!info->di_win->iconified && info->di_ed_obj>0)
	{
		_set_cursor(info,FAIL,FAIL);

		if (info->di_inddef>0)
			test_inddefault(info);

		if (top)
		{
			mouse_flag = FAIL;
			_mouse_pos(&event->ev_mmox,&event->ev_mmoy);
			mouse_cursor(info,event);
			event->ev_mflags |= MU_M1;
			return;
		}
	}
#endif

	if (top)
	{
		MouseArrow();
		mouse_flag = FALSE;
	}
}

void close_all_dialogs(void)
{
	while (_dia_len>0)
		close_dialog(_dia_list[_dia_len-1],FALSE);

	while (win_len>0)
		close_dialog(win_list[win_len-1],FALSE);
}

void close_all_windows(void)
{
	reg WIN *window = _windows;
	reg int i;

	close_all_dialogs();
	if (_opened>0)
		for (i=MAX_WINDOWS;--i>=0;window++)
			if (window->handle>0)
				close_window(window,FALSE);
}

static boolean find_windial(reg int hdl,DIAINFO **info)
{
	reg DIAINFO **list=win_list;
	reg int index;

	if (hdl>0)
		for (index=win_len;--index>=0;)
		{
			if ((*list++)->di_win->handle==hdl)
			{
				*info = *--list;
				return(TRUE);
			}
		}

	return(FALSE);
}

static int do_func(DIAINFO *info,int top,int msg,XEVENT *event)
{
	reg DIAINFO *new_info;
	reg int used;
	int new_top;

	used = _call_event_handler(msg,event,TRUE);
	if ((_dia_len+win_len)==0)
		return (TRUE);
	else if (used && info && (info!=(new_info=get_info(&new_top)) || new_top!=top))
		_init_xformdo(event,new_info,new_top);

	return (FALSE);
}

int _messag_handler(int form_do,XEVENT *event,int *obj,DIAINFO **back)
{
	int top;
	DIAINFO *info,*act_info = get_info(&top);
	WIN *window;
	reg int *mbuf = event->ev_mmgpbuf,msg = mbuf[0];
	reg boolean found = FALSE,win = FALSE, modal = FALSE;

	if (act_info)
	{
		switch (msg)
		{
		case WIN_CHANGED:
			win = TRUE;
			window = *(WIN **) &mbuf[4];
			if (window!=NULL)
				found = find_windial(window->handle,&info);
			break;
		case WM_BOTTOMED:
		case WM_CLOSED:
		case WM_TOPPED:
			if (act_info->di_flag==WIN_MODAL)
				modal = win = TRUE;
		case WM_UNTOPPED:
		case WM_ONTOP:
		case WM_NEWTOP:
		case WM_MOVED:
			found = find_windial(mbuf[3],&info);
			break;
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
			case WIN_CHANGED:
				if (form_do)
				{
					_init_xformdo(event,act_info,top);
					if (!found)
						do_func(act_info,top,MU_MESAG,event);
				}
				else if (!found)
					event->ev_mwich |= MU_MESAG;
				break;
			case WM_BOTTOMED:
				if (!modal)
				{
					window_bottom(info->di_win);
					if (info==act_info)
						_init_xformdo(event,NULL,FAIL);
				}
				break;
			case WM_ONTOP:
			case WM_NEWTOP:
			case WM_UNTOPPED:
				if (form_do)
					_init_xformdo(event,act_info,top);
				break;
			case WM_TOPPED:
				if (modal)
					info = act_info;
				window_top(info->di_win);
				if (form_do)
					_init_xformdo(event,info,TRUE);
				break;
			case WM_CLOSED:
				if (!modal && found)
				{
					if (back)
						*back = info;
					if (obj)
						*obj = W_CLOSED;
					return (TRUE);
				}
				break;
			case WM_FULLED:
				*(GRECT *) &mbuf[4] = (info->di_win->fulled) ? info->di_win->prev : info->di_win->max;
			case WM_SIZED:
			case WM_MOVED:
				move_dialog(info,(GRECT *) &mbuf[4]);
				_send_msg(info,0,OBJC_SIZED,0,0);
			#ifndef SMALL_EGEM
				if (form_do && info==act_info && top)
					mouse_cursor(info,event);
			#endif
				break;
			}
		}
	}

	switch (msg)
	{
	case ACC_TEXT:
	#ifndef SMALL_EGEM
		if (act_info!=NULL && act_info->di_ed_obj>0 && (top || _opened==1 || act_info->di_win->handle==_last_top))
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
				_set_cursor(act_info,ob,FAIL);

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
	case AC_CLOSE:
		_ac_close = TRUE;
	case AP_TERM:
		close_all_windows();
		if (form_do)
			do_func(act_info,top,MU_MESAG,event);
		else
			event->ev_mwich |= MU_MESAG;
		_ac_close = FALSE;
	}

	if ((win_len+_dia_len)<=0)
	{
		if (obj)
			*obj = W_ABANDON;
		return (TRUE);
	}
	else
		return (FALSE);
}

int X_Form_Do(DIAINFO **back)
{
	XEVENT event;
	DIAINFO *act_info,*winfo;
	reg int events,do_event,handle;
	int top,obj;

	if (back)
		*back = NULL;

	if (_dia_len==0 && win_len==0)
		return (W_ABANDON);

	memset(&event,0,sizeof(XEVENT));

	event.ev_mbclicks = 258;
	event.ev_mbmask = 3;

	_init_xformdo(&event,NULL,FAIL);

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

		if (events & MU_BUTTON)
		{
			do_event = FAIL;
			act_info = get_info(&top);

			if (act_info->di_flag<WINDOW || act_info->di_win->handle==(handle=wind_find(event.ev_mmox,event.ev_mmoy)))
			{
				winfo = act_info;
				do_event = top;
			}
			else if ((_back_win || (event.ev_mmobutton & 3)==3) && act_info->di_flag!=WIN_MODAL && find_windial(handle,&winfo))
				do_event = FALSE;

			if (do_event>=FALSE && !winfo->di_win->iconified && klickobj(winfo,&event,&obj,do_event)==FALSE)
			{
				if (back)
					*back = winfo;
				return (obj);
			}

			events &= ~MU_BUTTON;
		}

		if (events & MU_KEYBD)
		{
			act_info = get_info(&top);
			do_event = (top || act_info->di_win->handle==_last_top);

			if (toMouse && act_info->di_flag==WINDOW && find_windial(wind_find(event.ev_mmox,event.ev_mmoy),&winfo) && !winfo->di_win->iconified)
			{
				if (winfo!=act_info)
					top = FALSE;
				act_info = winfo;
				do_event = TRUE;
			}

			act_info->di_taken = FALSE;
			if (do_event && !act_info->di_win->iconified)
			{
				obj = key_handler(act_info,event.ev_mmokstate,event.ev_mkreturn,&event);
				if (obj!=FAIL && obj)
				{
					if (back)
						*back = act_info;
					return (obj);
				}
			}

			if (act_info->di_taken || (!always_keys && (act_info->di_flag!=WINDOW || menu_dropped())))
				events &= ~MU_KEYBD;
		}

		if (events)
		{
			act_info = get_info(&top);
		#ifndef SMALL_EGEM
			if (events & MU_M1)
			{
				if (top)
					mouse_cursor(act_info,&event);
				else
					event.ev_mflags &= ~MU_M1;
				events &= ~MU_M1;
			}
		#endif

			if (events && do_func(act_info,top,events,&event))
				return (W_ABANDON);
		}
	}
}

static DIAINFO *get_info(int *top)
{
	DIAINFO *winfo,*last;

	if (top)
		*top = FALSE;

	if (_dia_len>0)
	{
		if (top)
			*top = TRUE;
		return (_dia_list[_dia_len-1]);
	}
	else if (win_len>0)
	{
		int win_top;

		wind_update(BEG_UPDATE);
		win_top = _get_top();
		last = win_list[win_len-1];
		if (last->di_flag==WIN_MODAL || (!find_windial(win_top,&winfo) && !find_windial(_last_top,&winfo)))
			winfo = last;

		if (winfo->di_win->handle==win_top && !winfo->di_win->iconified)
			*top = TRUE;
		wind_update(END_UPDATE);

		return (winfo);
	}
	else
		return (NULL);
}

#ifndef SMALL_EGEM
static void mouse_cursor(DIAINFO *info,XEVENT *ev)
{
	reg GRECT area;
	reg OBJECT *tree=info->di_tree,*ob_ptr;
	reg int edit=FALSE,obj,x=ev->ev_mmox,y=ev->ev_mmoy;

	area = info->di_edit;
	area.g_x += tree->ob_x;
	area.g_y += tree->ob_y;

	if (rc_inside(x,y,&area) && (obj=objc_find(tree,ROOT,MAX_DEPTH,x,y))>=0)
	{
		ob_ptr = &tree[obj];

		ev->ev_mm1flags = 1;
		if ((ob_ptr->ob_flags & EDITABLE) && !(ob_ptr->ob_state & DISABLED))
		{
			EDINFO ed;

			edit = TRUE;
			_edit_get_info(tree,obj,0,&ed);
			if (rc_inside(x,y,(GRECT *) &ed.edit_x))
			{
				if (mouse_flag!=TRUE)
				{
					MouseCursor();
					mouse_flag = TRUE;
				}

				ev->ev_mm1x = ed.edit_x;
				ev->ev_mm1y = ed.edit_y;
				ev->ev_mm1width = ed.edit_w;
				ev->ev_mm1height = ed.edit_h;
				return;
			}
		}

		if (!edit && ob_ptr->ob_head<0)
		{
			objc_offset(tree,obj,&ev->ev_mm1x,&ev->ev_mm1y);
			ev->ev_mm1width = ob_ptr->ob_width;
			ev->ev_mm1height = ob_ptr->ob_height;
		}
		else
		{
			ev->ev_mm1x = x;
			ev->ev_mm1y = y;
			ev->ev_mm1width = ev->ev_mm1height = 1;
		}
	}
	else
	{
		ev->ev_mm1flags = 0;
		*(GRECT *) &ev->ev_mm1x = area;
	}

	if (mouse_flag!=FALSE)
	{
		MouseArrow();
		mouse_flag = FALSE;
	}
}
#endif

static int klickobj(DIAINFO *info,XEVENT *event,int *obj,boolean top)
{
	reg SLINFO **sl_list = (SLINFO **) info->di_slider,*slider;
	reg int ob,dummy,ind=FALSE;
	reg OBJECT *tree = info->di_tree,*ob_ptr;

	if (top || _back_win || (event->ev_mmobutton & 3)!=2)
	{
		if ((ob = objc_find(tree,ROOT,MAX_DEPTH,event->ev_mmox,event->ev_mmoy))>=0)
		{
			if (event->ev_mmobutton & 2)
			{
				event->ev_mbreturn = (event->ev_mmobutton & 1) ? 1 : 2;
				event->ev_mmobutton = 1;
			}

			ob_ptr = &tree[ob];
			if (sl_list!=NULL && !(ob_ptr->ob_state & DISABLED))
			{
				while ((slider=*sl_list++)!=NULL)
				{
					if (ob==slider->sl_dec || ob==slider->sl_inc ||
					    ob==slider->sl_parent || ob==slider->sl_slider)
					{
						dummy = slider->sl_pos;
						graf_rt_slidebox(slider,ob,event->ev_mbreturn!=1);
						if (dummy!=slider->sl_pos)
							_send_msg(info,slider->sl_slider,OBJC_CHANGED,0,0);
						return (TRUE);
					}
				}
			}

			if (!(ob_ptr->ob_flags & (SELECTABLE|EDITABLE|EXIT|TOUCHEXIT)))
			{
				if (!(ob_ptr->ob_state & DISABLED) && (dummy = is_rb_chk(tree,ob))>=0)
				{
					ob = dummy;
					ind = TRUE;
				}
				else if (info->di_fly && _nonsel_fly)
				{
					Event_Timer(50,0);
					if (_mouse_but() & 1)
					{
						do_jump_fly(info,FAIL,FAIL);
						return(TRUE);
					}
				}
			}

			dummy = objekt_handler(info,ob,event->ev_mbreturn,event->ev_mmox,event->ev_mmoy,ind);
			if (dummy && dummy!=FAIL)
			{
				*obj = dummy;
				return(FALSE);
			}
		}
		else if (info->di_fly)
		{
			do_jump_fly(info,event->ev_mmox,event->ev_mmoy);
		#ifndef SMALL_EGEM
			mouse_cursor(info,event);
		#endif
			_no_click();
		}
		else
			return(FAIL);

		return(TRUE);
	}

	return(FAIL);
}

void _send_msg(void *info, int id, int msg_id,int msg6,int msg7)
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
	_call_event_handler(MU_MESAG,&event,FALSE);
}

static int key_handler(DIAINFO *info,int state,int scan,XEVENT *event)
{
	SLINFO **sl_list = (SLINFO **) info->di_slider,*slider;
	reg SLKEY *sl_keys;
	reg OBJECT *tree = info->di_tree;
	reg int sn=(int) (((unsigned) scan)>>8),obj,hot,shft;
	int ascii = scan_2_ascii(scan,state),cnt;
#ifndef SMALL_EGEM
	int edited;
#endif

	shft = (state & (K_RSHIFT|K_LSHIFT)) ? TRUE : FALSE;
	hot = shft ? 6 : 4;

	if (sl_list!=NULL)
		while ((slider=*sl_list++)!=NULL)
			if ((sl_keys=slider->sl_keys)!=NULL)
				for (cnt=slider->sl_keys_cnt;--cnt>=0;sl_keys++)
					if (((state^sl_keys->state) & (K_ALT|K_CTRL))==0)
					{
						if (sl_keys->state & (K_RSHIFT|K_LSHIFT))
						{
							if ((shft) && ((sl_keys->scan>>8)==sn || (ascii && (char) sl_keys->scan==ascii)))
							{
								info->di_taken = TRUE;
								hot = slider->sl_pos;
								graf_rt_slidebox(slider,sl_keys->cmd,FALSE);
								if (hot!=slider->sl_pos)
									_send_msg(info,slider->sl_slider,OBJC_CHANGED,0,0);
								return (FAIL);
							}
						}
						else if ((!shft) && ((sl_keys->scan>>8)==sn || (ascii && (char) sl_keys->scan==ascii)))
						{
							info->di_taken = TRUE;
							graf_rt_slidebox(slider,sl_keys->cmd,FALSE);
							return (FAIL);
						}
					}

	if (!state)
	{
		obj = FAIL;

		switch (sn)
		{
		case SCANRET:
		#ifdef SMALL_EGEM
			obj = info->di_default;
		#else
			if (return_default==TRUE || info->di_ed_obj<0)
				obj = info->di_default;

			if (obj<=0 && info->di_ed_obj>0)
			{
				obj = info->di_default;
				if (_next_edit(info,(return_default==FALSE || obj<=0) ? TRUE : FALSE))
				{
					info->di_taken = TRUE;
					return (FAIL);
				}
			}
		#endif
			break;
		case SCANENTER:
		#ifndef SMALL_EGEM
			if (info->di_ed_obj<0)
		#endif
				obj = info->di_default;
			break;
		case SCANHELP:
			obj = info->di_help;
			break;
		case SCANUNDO:
			obj = info->di_undo;
			break;
		}

		if (obj>0)
		{
			info->di_taken = TRUE;
			return(objekt_handler(info,obj,hot,FAIL,FAIL,FALSE));
		}
	}

#ifndef SMALL_EGEM
	if ((state & K_ALT) || (info->di_ed_obj<0 && !(state & K_CTRL)))
#else
	if (!(state & K_CTRL))
#endif
	{
		if ((obj = _is_hotkey(tree,ascii))>=0)
		{
			info->di_taken = TRUE;

			if (!_is_hidden(tree,obj))
			{
			#ifndef SMALL_EGEM
				if (!(hot & 2) && (tree[obj].ob_flags & EDITABLE))
					_set_cursor(info,obj,0x1000);
				else
			#endif
					return(objekt_handler(info,obj,hot,FAIL,FAIL,FALSE));
			}

			return(FAIL);
		}
	}

#ifndef SMALL_EGEM
	if (info->di_ed_obj>0)
	{
		obj = _objc_edit_handler(info,state,scan,event,&edited);
		if (edited && (info->di_ed_obj==info->di_inddef || (edited==FAIL && info->di_inddef>0)))
			test_inddefault(info);
		if (edited==TRUE)
			_send_msg(info,info->di_ed_obj,OBJC_EDITED,0,0);
	}
#endif

	return (obj);
}

static int is_rb_chk(reg OBJECT *tree,reg int obj)
{
	reg int index = 0;

	for (;;)
	{
		if (tree->ob_next==obj)
		{
			switch (tree->ob_type & G_TYPE)
			{
			case G_CHK:
			case G_RB:
				return(index);
			default:
				return(FAIL);
			}
		}

		if (tree->ob_flags & LASTOB)
			return (FAIL);

		tree++;
		index++;
	}
}

boolean _is_hidden(OBJECT *tree,int index)
{
	reg OBJECT *obj = tree+index;

	if ((obj->ob_flags & HIDETREE) || ((obj->ob_flags & EDITABLE) && (obj->ob_state & DISABLED)))
		return(TRUE);
	else
	{
		reg int act;

		for (act=index;--act>=0;)
		{
			obj--;
			if (obj->ob_head<=index && obj->ob_tail>=index)
				if (obj->ob_flags & HIDETREE)
					return(TRUE);
				else
					index = act;
		}

		return(FALSE);
	}
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
				return(ob_get_parent(tree,index));
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
	reg int flags = obptr->ob_flags;
	reg int state = obptr->ob_state, old_state = state;

#ifndef SMALL_EGEM
	if (!(hot & 2) && (x!=FAIL) && (flags & EDITABLE))
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
					_set_cursor(info,obj,pos);

				return(FALSE);
			}
		}

		if ((dummy=is_rb_chk(tree,obj))!=FAIL)
		{
			obj = dummy;
			obptr = tree+obj;
			flags = obptr->ob_flags;
			old_state = state = obptr->ob_state;

			if (state & DISABLED)
				return(FAIL);
		}
		goto object_handle;
	}
	else
#endif
	if (!(state & DISABLED))
	{
	#ifndef SMALL_EGEM
		object_handle:
	#endif
		if ((obptr->ob_type & G_TYPE)==G_FLY || ((obptr->ob_type & G_TYPE)>>8)==USERFLY)
			do_jump_fly(info,FAIL,FAIL);
		else if (flags & (SELECTABLE|EXIT|TOUCHEXIT))
		{
			if (flags & SELECTABLE)
			{
				if ((flags & RBUTTON) && (state & SELECTED))
					_no_click();
				else if (obptr->ob_spec.userblk==&checkblk && (flags & TOUCHEXIT))
				{
					state &= ~(CHECKED|SELECTED); 
					if (old_state & SELECTED)
						state |= CHECKED;
					else if (!(old_state & CHECKED))
						state |= SELECTED;

					obptr->ob_state = state;

					ob_draw(info,obj);
					_no_click();

					_send_msg(info,obj,OBJC_CHANGED,0,0);
					return (FALSE);
				}
				else
				{
					state ^= SELECTED;

					if ((hot & 4) || ind || (flags & (RBUTTON|TOUCHEXIT)))
					{
						ob_select(info,tree,obj,FLIP_STATE,TRUE);

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
									obptr  = tree+act;

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
											ob_select(info,tree,act,CLEAR_STATE,TRUE);
											goto do_exit;
										}
										else
											break;
									}
								}
							}
						}

						do_exit:
						if ((ind || (flags & RBUTTON)) && !(flags & TOUCHEXIT))
							_no_click();

						if ((flags & (EXIT|TOUCHEXIT))==0)
							_send_msg(info,obj,OBJC_CHANGED,0,0);
					}
					else
					{
						XEVENT event;
						int x,y,events;

						_beg_ctrl();

						memset(&event,0,sizeof(XEVENT));
						event.ev_mflags = MU_BUTTON|MU_M1;
						event.ev_mbclicks = 1;
						event.ev_bmask = 3;

						objc_offset(tree,obj,&event.ev_mm1x,&event.ev_mm1y);
						event.ev_mm1width = obptr->ob_width;
						event.ev_mm1height = obptr->ob_height;

						_mouse_pos(&x,&y);
						if (rc_inside(x,y,(GRECT *) &event.ev_mm1x))
						{
							event.ev_mm1flags = 1;
							ob_select(info,tree,obj,FLIP_STATE,TRUE);
						}
						else
							event.ev_mm1flags = 0;

						do
						{
							_no_button++;
							events = Event_Multi(&event);
							_no_button--;
							if (events & MU_M1)
							{
								event.ev_mm1flags = 1 - event.ev_mm1flags;
								ob_select(info,tree,obj,FLIP_STATE,TRUE);
							}
						} while (!(events & MU_BUTTON));

						_end_ctrl();

						if (obptr->ob_state!=old_state)
						{
							if ((flags & (EXIT|TOUCHEXIT))==0)
								_send_msg(info,obj,OBJC_CHANGED,0,0);
						}
						else
							return (FALSE);
					}
				}
			}
			else if (flags & EXIT)
				_no_click();

			if (flags & (EXIT|TOUCHEXIT))
			{
				if (hot & 2)
					return(obj|0x8000);
				else
					return(obj);
			}
			else
				return(FALSE);
		}
	}

	return(FAIL);
}

static void do_jump_fly(DIAINFO *info,int x,int y)
{
	RC_RECT dial;
	reg OBJECT *tree = info->di_tree;
	reg GRECT *area = &info->di_rc.area;

	_rc_sc_savetree(tree,&dial);

#ifndef SMALL_EGEM
	if (!dial.valid)
		_cursor_off(info);
#endif

	MouseOff();
	rc_sc_restore(area->g_x,area->g_y,&info->di_rc,FALSE);
	MouseOn();

	if (x<0)
	{
		MouseFlatHand();
		graf_dragbox(area->g_w,area->g_h,area->g_x,area->g_y,desk.g_x+1,desk.g_y+1,desk.g_w-2,desk.g_h-2,&tree->ob_x,&tree->ob_y);
		MouseArrow();
		tree->ob_x += 3;tree->ob_y += 3;
	}
	else
	{
		int ox = tree->ob_x,oy = tree->ob_y;
		tree->ob_x = x - (tree->ob_width>>1);
		tree->ob_y = y - (tree->ob_height>>1);
		graf_movebox(tree->ob_width,tree->ob_height,ox,oy,tree->ob_x,tree->ob_y);
	}

	dial_pos(tree,4,3);

	MouseOff();
	rc_sc_freshen(x=tree->ob_x-3,y=tree->ob_y-3,&info->di_rc);
	if (dial.valid)
		rc_sc_restore(x,y,&dial,TRUE);
	else
	{
		objc_draw(tree,ROOT,MAX_DEPTH,desk.g_x,desk.g_y,desk.g_w,desk.g_h);
	#ifndef SMALL_EGEM
		_set_cursor(info,FAIL,FAIL);
	#endif
	}
	MouseOn();
}

boolean open_rsc(char *rscname,char *m_entry,char *x_name,char *a_name,int av_msgs,int va_msgs,int xacc_msgs)
{
	if (init_gem(m_entry,x_name,a_name,av_msgs,va_msgs,xacc_msgs)==TRUE)
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
			exit_gem(FAIL);
			return(FAIL);
		}
	}
	else
		return(FALSE);
}

void close_rsc(int result)
{
	rsrc_free();
	exit_gem(result);
}

boolean open_work(int *handle,int *work_out)
{
	reg int i,work_in[11];

	*handle = grhandle;
	for (i = 0; i <= 9; work_in[i++] = 1);work_in[i] = 2;
	v_opnvwk(work_in, handle, work_out);

	return((*handle>0) ? TRUE : FALSE);
}

void close_work(int handle)
{
	v_clsvwk(handle);
}

int xdialog(OBJECT *tree,char *name,char *icon_name,OBJECT *icon,boolean center,boolean shrgrw,int mode)
{
	DIAINFO info;
	int exit;

	open_dialog(tree,&info,name,icon_name,icon,center,shrgrw,mode,0,NULL);
	exit = X_Form_Do(NULL);
	if (exit!=W_ABANDON && exit!=W_CLOSED)
	{
		exit &= 0x7fff;
		ob_undostate(tree,exit,SELECTED);
	}
	close_dialog(&info,shrgrw);

	return(exit);
}

int menu_install(OBJECT *tree,int show)
{
	if (tree!=NULL && menu_available)
	{
		if (show)
		{
			show = (menu_inst && !_app) ? 100 : 1;
			_menu = tree;

			_set_menu();
		}
		else
			_menu = NULL;

		if (menu_bar(tree,show))
			return (TRUE);
	}

	_menu = NULL;
	return (FALSE);
}

void menu_item_enable(int object,int enable)
{
	if (_menu)
		menu_ienable(_menu,object,(enable) ? 1 : 0);
}

void menu_select(int titel,int select)
{
	if (_menu)
		menu_tnormal(_menu,titel,(select) ? 0 : 1);
}

void menu_enable(boolean enable)
{
	if (_menu)
	{
		reg OBJECT *tree = _menu, *obj = _menu;
		reg int index = 0,title = 0,string = 1;
		reg int min_x = max_w,max_x = 0;
		int x,d,act;

		wind_update(BEG_UPDATE);
		if (menu_test && menu_bar(tree,-1)==ap_id)
			act = TRUE;
		else if (get_top_window()!=NULL)
			act = TRUE;
		else
			act = FALSE;
		menu_bar(tree,0);

		for (;;)
		{
			switch (obj->ob_type)
			{
			case G_TITLE:
				objc_offset(tree,index,&x,&d);
				x += obj->ob_width;

				min_x = min(min_x,x);
				max_x = max(max_x,x);

				if (title)
					menu_item_enable(index,enable);
				else
					title = 1;
				break;
			case G_STRING:
				if (string)
				{
					menu_item_enable(index,enable);
					string = 0;
				}
			}

			if (obj->ob_flags & LASTOB)
				break;
			else
			{
				obj++;
				index++;
			}
		}

		objc_offset(tree,2,&x,&d);
		if (enable)
			tree[2].ob_width = max_x - x;
		else
			tree[2].ob_width = min_x - x;

		menu_bar(tree,(!act && menu_inst) ? 100 : 1);
		wind_update(END_UPDATE);
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
