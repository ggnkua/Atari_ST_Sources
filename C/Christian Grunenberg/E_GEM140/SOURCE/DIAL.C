
#include <time.h>
#include <stdio.h>
#include <ctype.h>

#ifndef __MINT_LIB__
#include <stdlib.h>
#endif

#include <string.h>
#include "proto.h"

#define DEFAULT_ERR		"[1][ Zu viele DEFAULT-Schalter! | Nur ein DEFAULT-Schalter | pro Baum mîglich! ][ Ok ]"
#define INDDEFAULT_ERR	"[1][ Zu viele INDDEFAULT-Objekte! | Nur ein INDDEFAULT-Objekt | pro Baum mîglich! ][ Ok ]"
#define HELP_ERR		"[1][ Zu viele HELP-Objekte! | Nur ein HELP-Objekt | pro Baum mîglich! ][ Ok ]"
#define UNDO_ERR		"[1][ Zu viele UNDO-Objekte! | Nur ein UNDO-Objekt | pro Baum mîglich! ][ Ok ]"

#define CHKHOTKEY_ERR_A	"[1][ CHKHOTKEY-Fehler: | Das Text-Objekt fehlt! | (Objekt-Nummer %d) ][ Ok ]"
#define CHKHOTKEY_ERR_B "[1][ CHKHOTKEY-Fehler: | Das HOTKEY-Objekt fehlt! | (Objekt-Nummer %d) ][ Ok ]"
#define RBHOTKEY_ERR_A	"[1][ RBHOTKEY-Fehler: |  Das Text-Objekt fehlt! | (Objekt-Nummer %d) ][ Ok ]"
#define RBHOTKEY_ERR_B	"[1][ RBHOTKEY-Fehler: | Das HOTKEY-Objekt fehlt! | (Objekt-Nummer %d) ][ Ok ]"

#define HOTKEY_ERR		"[1][ HOTKEY-Fehler: | doppelter HOTKEY '%c'! | (Objekt-Nummer %d) ][ Ok ]"

#define SCANRET 	28
#define SCANENTER	114
#define SCANUNDO	97
#define SCANHELP	98
#define SCANUP		72
#define SCANDOWN	80
#define SCANLEFT	75
#define CTRLLEFT	115
#define CTRLRIGHT	116
#define SCANRIGHT	77
#define SCANTAB 	15
#define SCANHOME	71
#define SCANDEL 	83
#define SCANINS 	82

#define WIN_ELEMENTE NAME|MOVER

typedef struct
{
	char			*string;
	USERBLK 		text_blk;
	int 			font,color,center;
} V_TEXT;

typedef struct _list
{
	V_TEXT			*start;
	int 			index;
	struct _list	*next;
} V_LIST;

typedef struct
{
	long	type;
	long	what;
} APPLRECORD;

const char __ident_e_gem[] = "Id: $EnhancedGEM v" E_GEM_VERSION " $";

boolean _back_win;
DIAINFO *_dia_list[128],*dinfo;
int _dia_len,_bevent;

static char umlaute[] = "_ÑîÅéôöû";
static char string_0[] = " ASCII-Table ";
static char string_1[] = " \x01" "\x02" "\x03" "\x04" "\x05" "\x06" "\x07" "\x08" "\x09" "\x0a" "\x0b" "\x0c" "\x0d" "\x0e" "\x0f" "\x10" "\x11" "\x12" "\x13" "\x14" "\x15" "\x16" "\x17" "\x18" "\x19" "\x1a" "\x1b" "\x1c" "\x1d" "\x1e" "\x1f" "";
static char string_2[] = " !\"#$%&\'()*+,-./0123456789:;<=>?";
static char string_3[] = " ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_";
static char string_4[] = "`abcdefghijklmnopqrstuvwxyz{|}~\x7f" "";
static char string_5[] = "\x80" "Å\x82" "\x83" "Ñ\x85" "\x86" "\x87" "\x88" "\x89" "\x8a" "\x8b" "\x8c" "\x8d" "é\x8f" "\x90" "\x91" "\x92" "\x93" "î\x95" "\x96" "\x97" "\x98" "ôö\x9b" "\x9c" "\x9d" "û\x9f" "";
static char string_6[] = "\xa0" "\xa1" "\xa2" "\xa3" "\xa4" "\xa5" "\xa6" "\xa7" "\xa8" "\xa9" "\xaa" "\xab" "\xac" "\xad" "\xae" "\xaf" "\xb0" "\xb1" "\xb2" "\xb3" "\xb4" "\xb5" "\xb6" "\xb7" "\xb8" "\xb9" "\xba" "\xbb" "\xbc" "\xbd" "\xbe" "\xbf" "";
static char string_7[] = "\xc0" "\xc1" "\xc2" "\xc3" "\xc4" "\xc5" "\xc6" "\xc7" "\xc8" "\xc9" "\xca" "\xcb" "\xcc" "\xcd" "\xce" "\xcf" "\xd0" "\xd1" "\xd2" "\xd3" "\xd4" "\xd5" "\xd6" "\xd7" "\xd8" "\xd9" "\xda" "\xdb" "\xdc" "\xdd" "\xde" "\xdf" "";
static char string_8[] = "\xe0" "\xe1" "\xe2" "\xe3" "\xe4" "\xe5" "\xe6" "\xe7" "\xe8" "\xe9" "\xea" "\xeb" "\xec" "\xed" "\xee" "\xef" "\xf0" "\xf1" "\xf2" "\xf3" "\xf4" "\xf5" "\xf6" "\xf7" "\xf8" "\xf9" "\xfa" "\xfb" "\xfc" "\xfd" "\xfe" "\xff" "";
static char string_9[] = "Cancel";

static OBJECT ascii_tree[] = {
	{ -1, 1, 13, G_BOX, NONE, OUTLINED,CAST (0x21141L), 0,512, 36,14 },
	{ 11, 2, 10, G_BOX, NONE, NORMAL,CAST (0xFF1101L), 2,3073, 32,777 },
	{ 3, -1, -1, (HEADER<<8)+G_BUTTON, NONE, NORMAL,CAST string_0, 1,0, 13,1 },
	{ 4, -1, -1, G_STRING, TOUCHEXIT, NORMAL,CAST string_1, 0,1, 32,1 },
	{ 5, -1, -1, G_STRING, TOUCHEXIT, NORMAL,CAST string_2, 0,3, 32,1 },
	{ 6, -1, -1, G_STRING, TOUCHEXIT, NORMAL,CAST string_3, 0,2, 32,1 },
	{ 7, -1, -1, G_STRING, TOUCHEXIT, NORMAL,CAST string_4, 0,4, 32,1 },
	{ 8, -1, -1, G_STRING, TOUCHEXIT, NORMAL,CAST string_5, 0,5, 32,1 },
	{ 9, -1, -1, G_STRING, TOUCHEXIT, NORMAL,CAST string_6, 0,6, 32,1 },
	{ 10,-1, -1, G_STRING, TOUCHEXIT, NORMAL,CAST string_7, 0,7, 32,1 },
	{ 1, -1, -1, G_STRING, TOUCHEXIT, NORMAL,CAST string_8, 0,8, 32,1 },
	{ 13, 12, 12, G_BUTTON, SELECTABLE|DEFAULT|EXIT, NORMAL,CAST string_9, 22,3851, 12,1025 },
	{ 11, -1, -1, (HOTKEY<<8)+G_IBOX, NONE, NORMAL,CAST (0x43011100L), 3,512, 1,1 },
	{ 0, -1, -1, (FLYDIAL<<8)+G_IBOX, SELECTABLE|LASTOB, NORMAL,CAST (0x57011100L), 34,0, 2,1 },
};

#define ASC0	3
#define CANCEL	11

static char *c_arrow[] = {"\x04","\x03","\x01","\x02"};

static APPLRECORD record[] = {
{1l,0x10000l}, {0l,10l}, {1l,0x100001l}};

static int		*cycle_but,*box_on,*box_off,*radio_on,*radio_off;
static int		*arrow_up,*arrow_up_sel,*arrow_down,*arrow_down_sel;
static int		*arrow_left,*arrow_left_sel,*arrow_right,*arrow_right_sel;
static int		x_events,win_top,modal,mouse_flag,key_taken,ac_close,_asc,exit_obj,gr_dcw;
static boolean	init_flag,w_init,x_abort,dial,call_func,always_keys;
static char 	undobuff[128];
static EVENT	*_event;

static V_TEXT	v_text[128];
static V_LIST	v_list = {v_text,0,NULL};

static char 	history[20][80];
static int		hist_index;

static int 		(*xf_init)(EVENT *);
static void		(*xf_msg)(EVENT *);

static DIAINFO *win_list[128];
static int		win_len = 0,dial_pattern = 0,dial_color = BLACK;
static int		image_w,image_h,big_img;
static boolean	nonsel_fly = FALSE,dial_tframe = TRUE,dial_tsmall = FALSE,dial_round = TRUE,dial_title = FALSE;
static boolean  return_default = TRUE,menu_nice = TRUE;

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

static void 	open_flydialog(OBJECT *,DIAINFO *,boolean,boolean);
static boolean	open_windialog(OBJECT *,DIAINFO *,char *,int,boolean,boolean);
static void		close_dials(void);

static boolean	win_topped(DIAINFO *);
static void 	init_xformdo(int,EVENT *,boolean);
static void 	dial_center(OBJECT *,boolean,int,int);
static void 	dial_pos(OBJECT *,int,int);
static void 	find_fly(DIAINFO *);
static void 	test_inddefault(OBJECT *,OBJECT *);

static void 	vdi_trans(int,int,void *);
static void 	scale_img(int *,int,int,int,int *,int *);
static void 	scale_coords(int *,int *);

static void 	cursor(int);
static void 	edit_off(void);
static void 	edit_on(void);
static void 	sel_edit(OBJECT *,int,boolean);
static void 	first_edit(OBJECT *);
static void 	last_edit(OBJECT *);
static void 	next_edit(OBJECT *);
static void 	prev_edit(OBJECT *);
static void 	edit_pos(int,boolean);
static void 	edit_string(char *);
static void 	edit_objc(OBJECT *,int,int,int *,int);
static void 	edit_rect(OBJECT *,int,VRECT *,int *);

static void 	mouse_cursor(EVENT *);
static int		klickobj(DIAINFO *,EVENT *,int *,boolean);
static int		key_handler(OBJECT *,int,int,EVENT *);
static int		cursor_handler(OBJECT *,int,int,EVENT *);
static int		objekt_handler(DIAINFO *,int,int,int,int,boolean,boolean);

static int		is_rb_chk(OBJECT *,int);
static boolean	is_editable(OBJECT *,int,int);
static boolean	is_hidden(OBJECT *,int,boolean);

static void 	do_jump_fly(OBJECT *,int,int);
static boolean	word_ascii(char);
static void 	insert_history(char *);

static void 	clipbrd_load(boolean);
static boolean	clipbrd_save(int);

static boolean	find_window(int,DIAINFO **);
static void 	top_window(EVENT *,DIAINFO *);

static void 	get_image(IMAGES *,int,BUTTON *,int **,int **);
static void 	set_images(IMAGES *,int **,int **);

static int		do_func(int,EVENT *);
static void		re_init(EVENT *);
static void 	vrt_copy(int *,PARMBLK *,int,int);

void dial_options(boolean round,boolean t_frame,boolean t_small,boolean niceline,boolean ret,boolean back,boolean nonsel,boolean keys)
{
	always_keys = keys;
	dial_round	= round;
	dial_tframe = t_frame;
	dial_tsmall = t_small;
	menu_nice	= niceline;
	return_default	= ret;
	nonsel_fly	= nonsel;

	if (aes_version>0x0100)
		_back_win = back;
	else
		_back_win = FALSE;

	if (_back_win && _bevent)
	{
		reg int i;
		for (i=0;i<win_len;i++)
			wind_set(win_list[i]->di_handle,WF_BEVENT,back);
	}
}

void dial_colors(int d_pattern,int d_color,int popup,int hotkey,int check,int radio,int arrow)
{
	dial_color	 = d_color;
	dial_pattern = d_pattern;

	cycleblk.ub_parm	= popup;
	hotkeyblk.ub_parm	= hotkey;
	checkblk.ub_parm	= check;
	rbuttblk.ub_parm	= radio;
	arrows.ub_parm		= arrow;
}

void title_options(boolean title,int color,int size)
{
	dial_title	= title;
	unlnblk.ub_parm = (size<<8)|color;
}

void get_image(IMAGES *img,int index,BUTTON *but,int **img_on,int **img_off)
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
	get_image(&radios,index,radio,&radio_on,&radio_off);
}

void check_image(int index,BUTTON *check)
{
	get_image(&checks,index,check,&box_on,&box_off);
}

void arrow_image(int index,BUTTON *down,BUTTON *up,BUTTON *left,BUTTON *right)
{
	get_image(&arrows_left,index,left,&arrow_left_sel,&arrow_left);
	get_image(&arrows_right,index,right,&arrow_right_sel,&arrow_right);
	get_image(&arrows_down,index,down,&arrow_down_sel,&arrow_down);
	get_image(&arrows_up,index,up,&arrow_up_sel,&arrow_up);
}

void cycle_image(int index,BUTTON *cycle)
{
	get_image(&cycles,index,cycle,&cycle_but,NULL);
}

boolean init_gem(char *m_entry)
{
	if (init_flag)
		return(TRUE);

	AES_VERSION = 0;
	if ((ap_id = appl_init())>=0 && (aes_version = AES_VERSION)>0)
	{
		int dummy,work_out[57];

		grhandle = graf_handle(&gr_cw,&gr_ch,&gr_bw,&gr_bh);
		gr_dcw = gr_cw<<1;

		if (open_work(&x_handle,work_out))
		{
			long value;
			if (get_cookie(COOKIE_MAGX,&value))
			{
				magx = ((int **) value)[2][24];
				if (magx<0x0200)
					magx = 0;
			}

			if (m_entry && (!_app || aes_version>=0x0400))
				menu_id = menu_register(ap_id,m_entry);
			else
				menu_id = -1;

			max_w = work_out[0];
			max_h = work_out[1];
			colors = work_out[39];

			vq_extnd(x_handle,1,work_out);
			planes = work_out[4];

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

			set_images(&radios,&radio_on,&radio_off);
			set_images(&checks,&box_on,&box_off);
			set_images(&arrows_left,&arrow_left_sel,&arrow_left);
			set_images(&arrows_right,&arrow_right_sel,&arrow_right);
			set_images(&arrows_up,&arrow_up_sel,&arrow_up);
			set_images(&arrows_down,&arrow_down_sel,&arrow_down);
			set_images(&cycles,&cycle_but,NULL);

			if (wind_get(0,WF_RETURN,&dummy,&dummy,&dummy,&dummy)==0)
		    {
		    	int version;
				wind_get(0,WF_WINX,&version,&dummy,&dummy,&dummy);
				winx = (version & 0x0fff);
				if (winx<0x0210)
					winx = 0;
			}

			_bevent = (aes_version>0x0331 || winx || magx);
			wind_get(0,WF_WORKXYWH,&desk.g_x,&desk.g_y,&desk.g_w,&desk.g_h);
			rc_grect_to_array(&desk,(int *) &clip);
			_set_clip((int *) &clip);

			rsrc_calc(ascii_tree,SCALING);
			scrp_init(NULL);
			graf_mouse(ARROW,NULL);
			if (aes_version>=0x0400)
				shel_write(9,0,0x01,"","");

			init_flag = TRUE;
			return(TRUE);
		}
		else
		{
			appl_exit();
			return(FAIL);
		}
	}
	else
		return(FALSE);
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

static int has_agi = FAIL;

int appl_xgetinfo(int type,int *out1,int *out2,int *out3,int *out4)
{
	if (has_agi<0)
		has_agi = (aes_version>=0x400 || magx || winx || appl_find("?AGI")==0) ? TRUE : FALSE;

	if (has_agi)
		return (appl_getinfo(type,out1,out2,out3,out4));
	else
		return(0);
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

void exit_gem()
{
	close_dials();

	if (fonts_loaded>=0)
	{
		vst_unload_fonts(x_handle,0);
		fonts_loaded = FAIL;
	}

	close_work(x_handle);
	appl_exit();
}

void set_images(IMAGES *images,int **on,int **off)
{
	reg IMAGE *im = images->image;
	reg int i;
	int dummy;

	if (big_img>=0)
	{
		for (i=0;i<images->count;i++,im++)
		{
			if (!big_img)
			{
				if (im->lo_on)
					im->hi_on = im->lo_on;
				if (im->lo_off)
					im->hi_off = im->lo_off;
			}
			
			vdi_trans(16,image_h,im->hi_on);
			vdi_trans(16,image_h,im->hi_off);

			if (!big_img)
			{
				if (!im->lo_on)
					scale_img(im->hi_on,16,16,DARK_SCALING,&dummy,&dummy);
				if (!im->lo_off)
					scale_img(im->hi_off,16,16,DARK_SCALING,&dummy,&dummy);
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

void scale_image(OBJECT *obj,int mode)
{
	if (mode & SCALING)
	{
		int dummy;

		if (big_img>0)
		{
			obj->ob_x += ((gr_cw-(image_w>>1))*(obj->ob_width/gr_cw))>>1;
			obj->ob_y += ((gr_ch-image_h)*(obj->ob_height/gr_ch))>>1;
		}
		else if ((unsigned char) obj->ob_type==G_ICON)
		{
			ICONBLK *icn = obj->ob_spec.iconblk;

			if (icn->ib_hicon>3)
			{
				scale_img(icn->ib_pdata,icn->ib_wicon,icn->ib_hicon,mode,&dummy,&dummy);
				scale_img(icn->ib_pmask,icn->ib_wicon,icn->ib_hicon,mode,&dummy,&icn->ib_hicon);
				scale_coords(&icn->ib_xicon,&icn->ib_yicon);
				scale_coords(&icn->ib_xtext,&icn->ib_ytext);
				scale_coords(&icn->ib_xchar,&icn->ib_ychar);
			}
		}
		else
		{
			BITBLK *blk = obj->ob_spec.bitblk;

			if (blk->bi_hl>3)
			{
				scale_img((int *) blk->bi_pdata,blk->bi_wb<<3,blk->bi_hl,mode,&dummy,&blk->bi_hl);
				scale_coords(&blk->bi_x,&blk->bi_y);
			}
		}
	}
}

void scale_coords(int *w,int *h)
{
	*w = (((*w)*image_w)+7)>>4;
	*h = (((*h)*image_h)+7)>>4;
}

void scale_img(int *source,int w,int h,int mode,int *b_w,int *b_h)
{
	if (source && big_img<=0)
	{
		reg int pxy[8],dark = (mode & DARK_SCALING),vr_mode = (dark) ? 7 : 3;
		reg MFDB image;
		int n_w = w,n_h = h;

		scale_coords(&n_w,&n_h);
		mfdb(&image,source,w,h,0,1);

		*b_w = n_w;
		*b_h = n_h;

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

void vdi_trans(int w,int h,void *data)
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

void vrt_copy(int *image,PARMBLK *pb,int color,int selected)
{
	reg MFDB src;
	reg int pxy[8],col[2],off = (big_img<0) ? 1:0;

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

void rsrc_calc(OBJECT *tree,int images)
{
	reg OBJECT *obj=tree;
	reg int index=0;
	for (;;)
	{
		rsrc_obfix(tree,index++);
		if (obj->ob_x==0 && obj->ob_width>max_w)
			obj->ob_width = max_w;
		if (obj->ob_flags & LASTOB)
			break;
		obj++;
	}
	fix_objects(tree,images);
}

void rsrc_init(int n_tree,int n_obs,int n_frstr,int n_frimg,int images,char **rs_strings,long *rs_frstr,BITBLK *rs_bitblk,
			   long *rs_frimg,ICONBLK *rs_iconblk,TEDINFO *rs_tedinfo,OBJECT *rs_object,OBJECT **rs_trindex,RS_IMDOPE *rs_imdope)
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
		rsrc_calc(rs_trindex[tree],images);
	}
}

void fix_objects(OBJECT *tree,int images)
{
	reg OBJECT *org=tree;
	reg int xtype,modal,index=0;

	if ((images & TEST_SCALING) && (gr_cw!=8 || gr_ch!=16))
		images |= SCALING;
	else
		images = NO_SCALING;

	do
	{
		tree++;index++;
		switch((unsigned char) tree->ob_type)
		{
		case G_ICON:
			{
				ICONBLK *icn = tree->ob_spec.iconblk;
				trans_image(tree);
				scale_image(tree,images);
				tree->ob_height = icn->ib_ytext+icn->ib_htext;
			}
			break;
		case G_IMAGE:
			trans_image(tree);
			scale_image(tree,images);
			tree->ob_height = tree->ob_spec.bitblk->bi_hl;
			break;
		default:
			{
				modal = tree->ob_type & G_MODAL;
				xtype = (tree->ob_type ^ modal)>>8;
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
						tree->ob_state |= _upper(tree->ob_spec.obspec.character)<<8;
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
				case TXTDEFAULT:
					tree->ob_flags |= INDDEFAULT;
					break;
				case ATTR_TEXT:
					{
						reg char *string = NULL;
						reg int font,color,center;

						switch ((unsigned char) tree->ob_type)
						{
						case G_STRING:
							string	= tree->ob_spec.free_string;
							color	= BLACK;
							font	= IBM;
							center  = 0;
							break;
						case G_TEXT:
							{
								TEDINFO *ted = tree->ob_spec.tedinfo;

								string	= ted->te_ptext;
								font	= ted->te_font;
								color	= ted->te_color;
								center  = ted->te_just;
							}
							break;
						}

						if (string)
						{
							reg V_LIST *list = &v_list;
							reg V_TEXT *v_text;

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
										if ((v_text = list->start = (V_TEXT *) calloc(128,sizeof(V_TEXT)))==NULL)
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

								v_text->font	= font;
								v_text->color	= color;
								v_text->center	= center;
								v_text->string	= string;

								tree->ob_type	= (ATTR_TEXT<<8)|G_USERDEF;
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

void find_fly(DIAINFO *info)
{
	reg OBJECT *tree=info->di_tree;
	reg int type;

	info->di_fly = FALSE;
	do
	{
		tree++;
		type = tree->ob_type & (~G_MODAL);
		if (type==G_FLY || (type>>8)==USERFLY)
		{
			tree->ob_flags &= ~HIDETREE;
			switch (info->di_flag)
			{
			case OPENED:
				tree->ob_state |= DISABLED;
				break;
			case WINDOW:
			case WIN_MODAL:
				if (type==G_FLY)
					tree->ob_flags |= HIDETREE;
				break;
			case FLYING:
				tree->ob_state &= ~DISABLED;
				info->di_fly = TRUE;
				break;
			}
			break;
		}
	}
	while (!(tree->ob_flags & LASTOB));
}

void dial_center(OBJECT *tree,boolean center,int xy,int wh)
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
		if (tree->ob_x>desk.g_x && tree->ob_y>desk.g_y)
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

void dial_pos(OBJECT *tree,int xy,int wh)
{
	reg int d;

	if ((d=(tree->ob_x + tree->ob_width + wh)) > clip.v_x2)
		tree->ob_x -= d - clip.v_x2;

	if (dial_round)
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

void open_flydialog(OBJECT *tree, DIAINFO *info, boolean center,boolean box)
{
	if (call_func && dinfo->di_ed_obj>0)
		edit_off();

	_beg_ctrl();
	dial_center(tree,center,4,4);

	if ((tree->ob_width<=desk.g_w) && (tree->ob_height<=desk.g_h))
	{
		long len;

		mfdb(&info->di_mfdb,NULL,tree->ob_width+6,tree->ob_height+6,0,planes);
		info->di_length = len = mfdb_size(&info->di_mfdb);

		if ((long) Malloc(-1l)>(len+4096l))
		{
			if ((info->di_mem = (long) Malloc(len+256l))>0l)
			{
				info->di_mfdb.fd_addr	= (int *) ((info->di_mem & 0xfffffffel) + 2);
				info->di_flag = FLYING;
				_bitblt(tree,&info->di_mfdb,TRUE);
				goto draw_dialog;
			}
		}
	}
	info->di_mfdb.fd_addr = NULL;
	info->di_flag = OPENED;
	form_dial(FMD_START,0,0,0,0,tree->ob_x-3,tree->ob_y-3,tree->ob_width+6,tree->ob_height+6);

	draw_dialog:
	info->di_tree=tree;
	find_fly(info);
	if (box)
		graf_growbox (max_w>>1,max_h>>1,1,1,tree->ob_x,tree->ob_y,tree->ob_width,tree->ob_height);
	graf_mouse(ARROW,NULL);
	objc_draw(tree,ROOT,MAX_DEPTH,desk.g_x,desk.g_y,desk.g_w,desk.g_h);
	_dia_list[_dia_len++] = info;
}

void close_dialog(DIAINFO *info,boolean box)
{
	OBJECT	*tree=info->di_tree;

	graf_mouse(ARROW,NULL);

	switch (info->di_flag)
	{
	case WINDOW:
	case WIN_MODAL:
		{
			reg int i;

			if (box)
				graf_shrinkbox (max_w>>1,max_h>>1,1,1,tree->ob_x,tree->ob_y,tree->ob_width,tree->ob_height);

			if (!ac_close && wind_close(info->di_handle))
				wind_delete(info->di_handle);

			if (info->di_flag==WIN_MODAL && _app && menu)
			{
				for (i=win_len;--i>=0;)
					if (win_list[i]->di_flag==WIN_MODAL && win_list[i]!=info)
						break;
				if (i<0)
					menu_enable(menu,TRUE,TRUE);
			}

			for (i=0;i<win_len;i++)
				if (win_list[i]==info)
					break;
			win_len--;
			for (;i<win_len;i++)
				win_list[i] = win_list[i+1];
			w_init = FAIL;
		}
		break;
	case OPENED:
	case FLYING:
		{
			if (box)
				graf_shrinkbox (max_w>>1,max_h>>1,1,1,tree->ob_x,tree->ob_y,tree->ob_width,tree->ob_height);

			if (info->di_flag == OPENED)
				form_dial(FMD_FINISH,0,0,0,0,tree->ob_x-3,tree->ob_y-3,tree->ob_width+6, tree->ob_height+6);
			else
			{
				_bitblt(tree,&info->di_mfdb,FALSE);
				Mfree((void *) info->di_mem);
			}
			_end_ctrl();
			_dia_len--;
			w_init = FAIL;
		}
	}

	memset(info,0,sizeof(DIAINFO));
}

#ifdef DEBUG

void check_hotkeys(OBJECT *tree)
{
	reg OBJECT *obj=tree;
	reg char hotkeys[128],*p=hotkeys,c;
	reg int index = 0;
	char msg[128];

	do
	{
		obj++;
		index++;

		switch (obj->ob_type & (~G_MODAL))
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

boolean open_dialog(OBJECT *tree,DIAINFO *info,char *win_name,boolean center,boolean box,int mode)
{
	reg OBJECT *obj = tree;
	reg int i,modal;

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
		modal = obj->ob_type & G_MODAL;
		if (((obj->ob_type ^ modal)>>8)==HEADER)
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
	tree->ob_spec.obspec.framecol	 = 1;

	if (!(mode & WIN_DIAL) || _dia_len || !open_windialog(tree,info,win_name,mode,center,box))
		if (mode & FLY_DIAL)
		{
			obj = tree;	
			do
			{
				obj++;
				if (obj->ob_type & G_MODAL)
					obj->ob_flags &= ~HIDETREE;
			}
			while (!(obj->ob_flags & LASTOB));
			open_flydialog(tree,info,center,box);
		}

	if (info->di_flag>=WINDOW)
	{
		obj = tree;	
		do
		{
			obj++;
			if (obj->ob_type & G_MODAL)
			{
				if (info->di_flag==WINDOW)
					obj->ob_flags |= HIDETREE;
				else
					obj->ob_flags &= ~HIDETREE;
			}
		}
		while (!(obj->ob_flags & LASTOB));
	}

	if (info->di_flag>CLOSED)
	{
	#ifdef DEBUG
		check_hotkeys(tree);
	#endif
		w_init = TRUE;
		return(TRUE);
	}
	else
		return(FALSE);
}

boolean open_windialog(OBJECT *tree,DIAINFO *info,char *win_name,int mode,boolean center,boolean box)
{
	if (win_len<128)
	{
		int typ = WIN_ELEMENTE;

		if (!(mode & MODAL))
			typ |= CLOSER;

		if (!(mode & NO_ICONIFY))
			typ |= SMALLER;

		info->di_handle = wind_create(typ,desk.g_x,desk.g_y,desk.g_w,desk.g_h);
		if (info->di_handle>0)
		{
			int x,y,w,h;

			if (call_func && dinfo->di_ed_obj>0)
				edit_off();

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
			wind_calc(WC_BORDER,WIN_ELEMENTE,tree->ob_x-info->di_xy_off,tree->ob_y-info->di_xy_off,
					  tree->ob_width+info->di_wh_off,tree->ob_height+info->di_wh_off,&x,&y,&w,&h);

			if (dial_round)
				while (x<clip.v_x1)
				{
					tree->ob_x += 8;
					x += 8;
				}
			else if (x<clip.v_x1)
			{
				tree->ob_x = clip.v_x1 - x;
				x = clip.v_x1;
			}

			if (y<clip.v_y1)
			{
				tree->ob_y += clip.v_y1 - y;
				y = clip.v_y1;
			}

			if (mode & MODAL)
			{
				if (_app && menu)
					menu_enable(menu,FALSE,TRUE);
				info->di_flag = WIN_MODAL;
			}
			else
				info->di_flag = WINDOW;

			info->di_mfdb.fd_addr = NULL;
			info->di_tree = tree;
			find_fly(info);
			if (box)
				graf_growbox(max_w>>1,max_h>>1,1,1,tree->ob_x,tree->ob_y,tree->ob_width,tree->ob_height);
			info->di_title = win_name;
			wind_set(info->di_handle,WF_NAME,win_name);
			if (_back_win && _bevent)
				wind_set(info->di_handle,WF_BEVENT,1);
			graf_mouse(ARROW,NULL);
			wind_open(info->di_handle,x,y,w,h);
			win_list[win_len++]=info;
			return(TRUE);
		}
	}
	return(FALSE);
}

void move_dialog(DIAINFO *info,GRECT *area)
{
	reg OBJECT *tree = info->di_tree;
	reg int *rect = (int *) area;
	int d;

	if (!info->di_iconified)
	{
		wind_calc(WC_WORK,WIN_ELEMENTE,rect[0],rect[1],rect[2],rect[3],&tree->ob_x,&tree->ob_y,&d,&d);
		tree->ob_x += info->di_xy_off;
		tree->ob_y += info->di_xy_off;

		if (dial_round)
		{
			tree->ob_x &= 0xFFF8;
			wind_calc(WC_BORDER,WIN_ELEMENTE,tree->ob_x-info->di_xy_off,tree->ob_y-info->di_xy_off,
					  tree->ob_width+info->di_wh_off,tree->ob_height+info->di_wh_off,rect,rect+1,rect+2,rect+3);

			while (rect[0]<clip.v_x1)
			{
				tree->ob_x += 8;
				rect[0] += 8;
			}
		}
	}

	wind_set(info->di_handle,WF_CURRXYWH,rect[0],rect[1],rect[2],rect[3]);
}

void redraw_iconified(int handle,OBJECT *icon,GRECT *area)
{
	rc_sc_clear(area);

	if (icon!=NULL)
	{
		GRECT win;

		wind_get(handle,WF_WORKXYWH,&win.g_x,&win.g_y,&win.g_w,&win.g_h);

		icon->ob_x = win.g_x + ((win.g_w - icon->ob_width)>>1);
		icon->ob_y = win.g_y + ((win.g_h - icon->ob_height)>>1);
		objc_draw(icon,0,MAX_DEPTH,area->g_x,area->g_y,area->g_w,area->g_h);
	}
}

void redraw_dialog(DIAINFO *info,GRECT *area)
{
	GRECT work;
	reg OBJECT *tree=info->di_tree;
	reg boolean cursor=FALSE,clp=FALSE,icon=info->di_iconified;
	reg int	pxy[4],index;

	redraw++;
	wind_update(BEG_UPDATE);

	if (info->di_ed_obj>0)
	{
		if (info->di_cursor && win_topped(info))
		{
			edit_off();
			index = info->di_ed_index;
			cursor = TRUE;
		}
	}

	wind_get(info->di_handle,WF_FIRSTXYWH,&work.g_x,&work.g_y,&work.g_w,&work.g_h);
	while (work.g_w>0 && work.g_h>0)
	{
		if (rc_intersect(area,&work))
		{
			if (clp==FALSE)
			{
				graf_mouse(M_OFF,NULL);
				clp = TRUE;
			}

			if (icon)
				redraw_iconified(info->di_handle,iconified,&work);
			else
			{
				rc_grect_to_array(&work,pxy);
				_set_clip(pxy);
				objc_draw(tree,ROOT,MAX_DEPTH,work.g_x,work.g_y,work.g_w,work.g_h);
			}
		}
		wind_get(info->di_handle,WF_NEXTXYWH,&work.g_x,&work.g_y,&work.g_w,&work.g_h);
	}

	if (clp)
		_set_clip((int *) &clip);

	if (cursor)
		edit_pos(index,TRUE);

	if (clp)
		graf_mouse(M_ON,NULL);
	wind_update(END_UPDATE);

	redraw=0;
}

int cdecl draw_underline(PARMBLK *pb)
{
	reg OBJECT *tree = pb->pb_tree,*obj = tree + pb->pb_obj;
	reg int d,x1,x2,disabled,type = ((obj->ob_type & (~G_MODAL))==G_USERDEF);

	if (type)
	{
		_vdi_attr(MD_REPLACE,(d=(int) (pb->pb_parm>>8)),(char) pb->pb_parm);
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
	return(0);
}

int cdecl draw_box(PARMBLK *pb)
{
	reg OBJECT *obj = &pb->pb_tree[pb->pb_obj];
	reg int disabled = ((pb->pb_tree[obj->ob_next].ob_state)|obj->ob_state) & DISABLED;

	if (big_img<0)
	{
		reg int color = (int) pb->pb_parm;
		reg int x = pb->pb_x+1,y = pb->pb_y+1,w = pb->pb_w-3,h=pb->pb_w-3;

		_vdi_attr(MD_REPLACE,1,color);
		_bar(x,y,w,h,0,color);

		if (pb->pb_currstate & SELECTED)
		{
			_line(x,y,x+w,y+h);
			_line(x+w,y,x,y+h);
		}
	}
	else if (pb->pb_currstate & SELECTED)
		vrt_copy(box_on,pb,(int) pb->pb_parm,0);
	else
		vrt_copy(box_off,pb,(int) pb->pb_parm,0);
	return(disabled);
}

int cdecl draw_cyclebutton(PARMBLK *pb)
{
	reg int color = (int) pb->pb_parm,w,h;

	w = gr_dcw;
	h = gr_ch;
	if (big_img<0)
		w--;

	pb->pb_x++;
	pb->pb_y++;
	pb->pb_w = w;
	pb->pb_h = h;

	_vdi_attr(MD_REPLACE,1,color);
	_bar(pb->pb_x+2,pb->pb_y+2,w,h,1,color);

	if (big_img<0)
	{
		_bar(pb->pb_x-1,pb->pb_y-1,w+1,h+1,0,color);
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

int cdecl draw_radiobutton(PARMBLK *pb)
{
	reg OBJECT *obj = &pb->pb_tree[pb->pb_obj];
	reg int disabled = ((pb->pb_tree[obj->ob_next].ob_state)|obj->ob_state) & DISABLED;

	if (big_img<0)
	{
		reg int color = (int) pb->pb_parm;

		_vdi_attr(MD_REPLACE,1,color);
		_bar(pb->pb_x+1,pb->pb_y+1,pb->pb_w-3,pb->pb_h-3,0,color);
		if ((pb->pb_currstate & SELECTED) && !disabled)
			_bar(pb->pb_x+4,pb->pb_y+4,pb->pb_w-9,pb->pb_h-9,1,color);
	}
	else if (pb->pb_currstate & SELECTED)
		vrt_copy(radio_on,pb,(int) pb->pb_parm,0);
	else
		vrt_copy(radio_off,pb,(int) pb->pb_parm,0);
	return(disabled);
}

int cdecl draw_arrows(PARMBLK *pb)
{
	reg int type = (pb->pb_tree[pb->pb_obj].ob_type & (~G_MODAL))>>8,color = (int) pb->pb_parm;

	_vdi_attr(MD_REPLACE,1,color);
	if (big_img<0)
	{
		_bar(pb->pb_x-1,pb->pb_y-1,gr_dcw+1,gr_ch+1,0,(pb->pb_currstate & OUTLINED) ? color : 0);
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

int cdecl draw_fly(PARMBLK *pb)
{
	reg int pxy[6],w=pb->pb_w-1,h=pb->pb_h-1;

	_vdi_attr(MD_REPLACE,1,BLACK);
	_bar(pb->pb_x,pb->pb_y,w,h,0,BLACK);

	if (pb->pb_tree->ob_state & OUTLINED)
	{
		pxy[0] = pb->pb_x + 3;
		pxy[3] = pxy[1] = pb->pb_y + 3;
		pxy[4] = pxy[2] = pb->pb_x + pb->pb_w - 4;
		pxy[5] = pb->pb_y + pb->pb_h - 4;
		v_pline(x_handle,3,pxy);

		if (pb->pb_tree->ob_spec.obspec.framesize!=1)
		{
			if (big_img>0)
				pxy[0]++;
			else
				pxy[0] += 2;
			pxy[1]++;
			pxy[2]--;
			pxy[3]++;
			pxy[4]--;
			if (big_img>0)
				pxy[5]--;
			v_pline(x_handle,3,pxy);
		}
	}

	_line(pb->pb_x,pb->pb_y,pb->pb_x + w,pb->pb_y + h);
	return(pb->pb_currstate & ~SELECTED);
}

int cdecl draw_text(PARMBLK *pb)
{
	reg V_TEXT *text = (V_TEXT *) pb->pb_parm;
	reg int state = pb->pb_tree[pb->pb_obj].ob_state,effect = 0,color = text->color,x=pb->pb_x,y=pb->pb_y;
	reg int pxy[8];

	v_set_mode(MD_TRANS);
	if (text->font==SMALL)
		v_set_text(small_font_id,small_font,color,NULL);
	else
		v_set_text(ibm_font_id,ibm_font,color,NULL);

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

int cdecl draw_menu(PARMBLK *pb)
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

void init_xformdo(int ed_obj,EVENT *event,boolean top)
{
	reg OBJECT *tree = dinfo->di_tree,*obj = tree;
	reg int index = 0,eobjc,iobjc;
	reg unsigned short flg,type;

	dinfo->di_ed_obj = dinfo->di_default = dinfo->di_help = dinfo->di_undo = eobjc = iobjc = FAIL;
	dinfo->di_ed_objptr = NULL;
	w_init = FALSE;

	if (dinfo->di_flag>CLOSED)
	{
		do
		{
			obj++;index++;
			if ((flg = obj->ob_flags) & DEFAULT)
			{
				if (!is_hidden(tree,index,TRUE))
				{
				#ifdef DEBUG
					if (dinfo->di_default>=0)
						form_alert(1,DEFAULT_ERR);
					else
				#endif
						dinfo->di_default = index;
				}
			}
			else if (flg & EDITABLE)
			{
				if (!is_hidden(tree,index,FALSE))
				{
					if (flg & INDDEFAULT)
					{
					#ifdef DEBUG
						if (iobjc>=0)
							form_alert(1,INDDEFAULT_ERR);
						else
					#endif
							iobjc = index;
					}
	
					if ((eobjc<0) || (index==ed_obj))
						eobjc = index;
				}
			}
			else
			{
				type = obj->ob_type & (~G_MODAL);
			#ifdef DEBUG
				if (type==G_CHK || type==G_RB)
				{
					if (!is_hidden(tree,index,TRUE))
					{
						reg char *err=NULL,msg[40];
	
						switch (_get_hotkey(tree,index))
						{
						case FAIL:
							err = (type==G_RB) ? RBHOTKEY_ERR_A : CHKHOTKEY_ERR_A;
							break;
						case FALSE:
							err = (type==G_RB) ? RBHOTKEY_ERR_B : CHKHOTKEY_ERR_B;
						}
	
						if (err)
						{
							sprintf(msg,err,index);
							form_alert(1,msg);
						}
					}
				}
				else
				{
					type >>= 8;
	
					if (type==HELP_BTN && !is_hidden(tree,index,TRUE))
					{
						if (dinfo->di_help>=0)
							form_alert(1,HELP_ERR);
						else
							dinfo->di_help = index;
					}
					else if (type==UNDO_BTN && !is_hidden(tree,index,TRUE))
					{
						if (dinfo->di_undo>=0)
							form_alert(1,UNDO_ERR);
						else
							dinfo->di_undo = index;
					}
				}
			#else
				type >>= 8;
	
				if (type==HELP_BTN && !is_hidden(tree,index,TRUE))
					dinfo->di_help = index;
				else if (type==UNDO_BTN && !is_hidden(tree,index,TRUE))
					dinfo->di_undo = index;
			#endif
			}
		}
		while (!(flg & LASTOB));

		mouse_flag = 0;
		graf_mouse(ARROW,NULL);
	
		if (!dinfo->di_iconified && eobjc>0 && top)
		{
			hist_index = 0;
			sel_edit(tree,eobjc,FAIL);
	
			_mouse_pos(&event->ev_mmox,&event->ev_mmoy);
			mouse_cursor(event);
	
			if (iobjc>0)
				test_inddefault(tree,&dinfo->di_tree[iobjc]);
		}
	}

	{
		reg int *ev = (int *) event;

		*ev = MU_KEYBD|MU_BUTTON|MU_MESAG;
		if (dinfo->di_ed_obj>0 && !dinfo->di_iconified && win_topped(dinfo))
			*ev |= MU_M1;
		ev++;
		*ev++ = 2;
		*ev++ = 1;
		*ev++ = 1;
	}
}

void close_dials()
{
	while (_dia_len>0)
		close_dialog(_dia_list[_dia_len-1],FALSE);
	while (win_len>0)
		close_dialog(win_list[win_len-1],FALSE);
}

boolean find_window(reg int hdl,DIAINFO **info)
{
	reg int index;

	for (index=0;index<win_len;index++)
	{
		if (win_list[index]->di_handle == hdl)
		{
			*info = win_list[index];
			return(TRUE);
		}
	}
	return(FALSE);
}

void top_window(EVENT *event,DIAINFO *info)
{
	int index;

	if (info->di_ed_objptr)
		index=info->di_ed_index;
	else
		index=FAIL;

	dinfo = info;
	win_top = TRUE;
	dial = FALSE;
	wind_set(info->di_handle,WF_TOP);
	init_xformdo(info->di_ed_obj,event,TRUE);

	if (info->di_ed_obj>0)
	{
		if (index>=0)
			edit_pos(index,TRUE);
		else
			edit_on();
	}
}

int do_func(int msg,EVENT *event)
{
	if (xf_msg && (x_events & msg))
	{
		int old = event->ev_mwich,hdl,dummy;

		if (!_dia_len)
			wind_get(0,WF_TOP,&hdl,&dummy,&dummy,&dummy);

		call_func = TRUE;

		event->ev_mwich = msg;
		xf_msg(event);
		event->ev_mwich = old;

		call_func = FALSE;

		if (!_dia_len && !win_len)
		{
			exit_obj = W_ABANDON;
			x_abort = TRUE;
		}
		else if (w_init)
		{
			re_init(event);
			w_init = FALSE;
		}
		else if (!_dia_len)
		{
			wind_get(0,WF_TOP,&old,&dummy,&dummy,&dummy);
			if (old!=hdl)
				re_init(event);
		}
	}

	return (x_abort);
}

void re_init(EVENT *event)
{
	reg int init = w_init;

	if (_dia_len>0)
	{
		dial = TRUE;
		win_top = modal = FALSE;
		dinfo = _dia_list[_dia_len-1];

		init_xformdo(dinfo->di_ed_obj,event,TRUE);
		if (dinfo->di_ed_obj>0)
		{
			if (init==TRUE)
				edit_on();
			else
				cursor(TRUE);
		}
	}
	else if (win_len>0)
	{
		DIAINFO *winfo;
		int 	hdl,dummy;

		if (win_top)
			cursor(FALSE);

		dial = FALSE;
		wind_get(0,WF_TOP,&hdl,&dummy,&dummy,&dummy);
		if ((win_top=find_window(hdl,&winfo))>0)
		{
			if (win_list[win_len-1]->di_flag==WIN_MODAL)
				winfo = win_list[win_len-1];

			if (!winfo->di_iconified)
			{
				top_window(event,winfo);
				if (winfo->di_ed_obj>0 && init==FALSE)
					cursor(TRUE);
				modal = (winfo->di_flag==WIN_MODAL);
			}
			else
			{
				win_top = FALSE;
				wind_set(winfo->di_handle,WF_TOP);
				init_xformdo(winfo->di_ed_obj,event,FALSE);
			}
		}
		else
		{
			dinfo = win_list[win_len-1];
			init_xformdo(dinfo->di_ed_obj,event,FALSE);
		}
	}

	x_events = (xf_init) ? xf_init(event) : 0;
}

int X_Form_Do(DIAINFO **back,int edit,int (*init)(EVENT *),void (*call_func)(EVENT *))
{
	DIAINFO *info;
	EVENT	event;
	boolean back_click;
	long	last_time = clock();
	int		*mbuf = event.ev_mmgpbuf;

	mouse_flag = dial = back_click = x_abort = modal = FALSE;
	xf_init = init; xf_msg = call_func;

	if (_dia_len>0)
	{
		dinfo = _dia_list[_dia_len-1];
		dial = TRUE;
		win_top = FALSE;
	}
	else
	{
		DIAINFO *winfo;
		int 	hdl,dummy;

		wind_get(0,WF_TOP,&hdl,&dummy,&dummy,&dummy);
		if ((win_top = find_window(hdl,&winfo))>0)
			dinfo = winfo;
		else
			dinfo = win_list[win_len-1];
		if (dinfo->di_flag==WIN_MODAL)
			modal = TRUE;
	}

	if (edit>0)
	{
		init_xformdo(edit,&event,dial|win_top);
		if (dinfo->di_ed_obj>0)
			edit_on();
	}
	else
	{
		if (dinfo->di_ed_objptr)
		{
			int index = dinfo->di_ed_index;
			init_xformdo(dinfo->di_ed_obj,&event,dial|win_top);
			if (dinfo->di_ed_obj>0 && index>=0)
				edit_pos(index,TRUE);
		}
		else
		{
			init_xformdo(0,&event,dial|win_top);
			if (dinfo->di_ed_obj>0)
				edit_on();
		}
	}

	x_events = (init) ? init(&event) : 0;

	for(;;)
	{
		event.ev_mwich = Event_Multi(&event,last_time);
		if (event.ev_mwich & MU_MESAG)
		{
			DIAINFO  *winfo;
			reg int msg=mbuf[0];
			boolean  found,win;

			found = win = FALSE;

			switch (msg)
			{
			case AC_OPEN:
			case MN_SELECTED:
			case AP_DRAGDROP:
			case WM_ALLICONIFY:
				break;
			case AC_CLOSE:
			case AP_TERM:
				win = TRUE;
				break;
			case WM_NEWTOP:
			case WM_TOPPED:
			case WM_ONTOP:
				msg = WM_TOPPED;
				win = TRUE;
			default:
				if (msg<256)
					found = find_window(mbuf[3],&winfo);
				break;
			}

			if ((found && _dia_len==0) || win)
			{
				switch(msg)
				{
				case WM_REDRAW:
					redraw_dialog(winfo,(GRECT *) &mbuf[4]);
					break;
				case WM_ICONIFY:
					winfo->di_iconified = TRUE;
					if (winfo==dinfo)
						re_init(&event);
					wind_set(winfo->di_handle,WF_ICONIFY,mbuf[4],mbuf[5],mbuf[6],mbuf[7]);
					break;
				case WM_UNICONIFY:
					winfo->di_iconified = FALSE;
					wind_set(winfo->di_handle,WF_UNICONIFY,mbuf[4],mbuf[5],mbuf[6],mbuf[7]);
					if (winfo==dinfo)
						re_init(&event);
					break;
				case WM_BOTTOMED:
					if (!modal && win_top)
					{
						cursor(FALSE);
						wind_set(mbuf[3],WF_BOTTOM);
						win_top = FALSE;
					}
					break;
				case WM_UNTOPPED:
					if (winfo==dinfo && win_top)
					{
						cursor(FALSE);
						win_top = FALSE;
					}
					break;
				case WM_TOPPED:
					if (_bevent || !_back_win || (!found && (!(x_events & MU_BUTTON) || modal)) || (modal && winfo!=dinfo))
					{
						topped:
						if (win_top)
							cursor(FALSE);

						if (found || modal)
						{
							if (modal)
								winfo = win_list[win_len-1];
							top_window(&event,winfo);
							x_events = (init) ? init(&event) : 0;
						}
						else
							do_func(MU_MESAG,&event);
					}
					else if (!modal || winfo==dinfo || !found)
					{
						int x,y;
						GRECT win;

						_mouse_pos(&x,&y);
						wind_get(mbuf[3],WF_WORKXYWH,&win.g_x,&win.g_y,&win.g_w,&win.g_h);

						if (rc_inside(x,y,&win))
						{
							event.ev_mwich |= MU_BUTTON;
							event.ev_mbreturn = 1;
							event.ev_mmox = x;
							event.ev_mmoy = y;
							back_click = TRUE;
						}
						else
							goto topped;
					}
					break;
				case WM_CLOSED:
					if (!modal)
					{
						dinfo = winfo;
						exit_obj = W_CLOSED;
						x_abort = TRUE;
					}
					break;
				case AP_TERM:
				case AC_CLOSE:
					ac_close=(msg==AC_CLOSE);
					close_dials();
					do_func(MU_MESAG,&event);
					ac_close=0;
					break;
				case WM_MOVED:
					move_dialog(winfo,(GRECT *) &mbuf[4]);
					_mouse_pos(&event.ev_mmox,&event.ev_mmoy);
					mouse_cursor(&event);
					break;
				}
			}
			else if (!found)
				do_func(MU_MESAG,&event);
		}

		if (!_dia_len && !win_len && !x_abort)
		{
			exit_obj = W_ABANDON;
			x_abort = TRUE;
		}

		if (x_abort)
			break;

		if (event.ev_mwich & MU_BUTTON)
		{
			int klick=FAIL;

			if (dial)
				klick = klickobj(dinfo,&event,&exit_obj,TRUE);
			else
			{
				DIAINFO *winfo;
				int handle,dummy;

				if (!back_click)
				{
					if (_bevent || (event.ev_mmobutton & 2))
						handle = wind_find(event.ev_mmox,event.ev_mmoy);
					else
					{
						wind_get(0,WF_TOP,&handle,&dummy,&dummy,&dummy);
						back_click = FAIL;
					}
				}
				else
					handle = mbuf[3];

				if (win_top && dinfo->di_handle==handle)
				{
					if (back_click<0 || win_topped(dinfo))
						klick = klickobj(dinfo,&event,&exit_obj,TRUE);
					else
					{
						winfo = dinfo;
						goto back;
					}
				}
				else if (!modal && find_window(handle,&winfo))
				{
					back:
					if (back_click>0 && !_bevent && (_mouse_but() & 1))
						appl_tplay(record,3,100);

					if ((klick = klickobj(winfo,&event,&exit_obj,FALSE))==0)
					{
						x_abort = FAIL;
						info = winfo;
						break;
					}
				}
				back_click = FALSE;
			}

			if (!klick || (klick<0 && !modal && !dial && do_func(MU_BUTTON,&event)))
				break;
		}

		if (event.ev_mwich & MU_KEYBD)
		{
			key_taken = FALSE;
			if (win_top || dial)
			{
				exit_obj = key_handler(dinfo->di_tree,event.ev_mmokstate,event.ev_mkreturn,&event);
				if (exit_obj!=FAIL && exit_obj)
					break;
			}

			if (!key_taken && (always_keys || (!modal && !dial && !menu_dropped(NULL))) && do_func(MU_KEYBD,&event))
				break;
		}

		if (event.ev_mwich & MU_M1)
			if ((win_top || dial) && dinfo->di_ed_obj>0)
				mouse_cursor(&event);

		if (event.ev_mwich & (MU_M2|MU_TIMER))
		{
			if (do_func(event.ev_mwich & (MU_M2|MU_TIMER),&event))
				break;
			if (event.ev_mwich & MU_TIMER)
				last_time = clock();
		}
	}

	if (dinfo->di_ed_obj>0)
	{
		insert_history(dinfo->di_ed_objptr->ob_spec.tedinfo->te_ptext);
		if (x_abort!=TRUE && win_topped(dinfo))
			edit_off();
	}

	if (back)
	{
		if (exit_obj!=W_ABANDON)
		{
			if (x_abort<0)
				*back = info;
			else
				*back = dinfo;
		}
		else
			*back = NULL;
	}

	return (exit_obj);
}

boolean win_topped(DIAINFO *info)
{
	int top,dummy;

	if (info->di_flag<WINDOW)
		return(TRUE);

	wind_get(0,WF_TOP,&top,&dummy,&dummy,&dummy);
	if (info->di_handle==top)
		return(TRUE);
	else
		return(FALSE);
}

void cursor(int on_off)
{
	if (dinfo->di_ed_obj>0)
	{
		GRECT area;

		objc_offset(dinfo->di_tree,dinfo->di_ed_obj,&area.g_x,&area.g_y);
		area.g_x -= 2;
		area.g_y -= 4;
		area.g_w = dinfo->di_ed_objptr->ob_width+4;
		area.g_h = dinfo->di_ed_objptr->ob_height+8;
		ob_draw_chg(dinfo,ROOT,&area,FAIL,FALSE);
		dinfo->di_cursor = 0;

		if (on_off)
			edit_on();
	}
}

void mouse_cursor(EVENT *ev)
{
	reg OBJECT *tree=dinfo->di_tree,*ob_ptr;
	reg int obj,x=ev->ev_mmox,y=ev->ev_mmoy;

	if ((obj=objc_find(tree,ROOT,MAX_DEPTH,x,y))>=0)
	{
		ob_ptr = &tree[obj];

		ev->ev_mm1flags = 1;
		if ((ob_ptr->ob_flags & EDITABLE) && !(ob_ptr->ob_state & DISABLED))
		{
			VRECT	 edit;
			int 	 dummy;

			edit_rect(tree,obj,&edit,&dummy);
			if ((x>=edit.v_x1) && (y>=edit.v_y1) && (x<=edit.v_x2) && (y<=edit.v_y2))
			{
				if (!mouse_flag)
				{
					graf_mouse(TEXT_CRSR,NULL);
					mouse_flag = 1;
				}

				ev->ev_mm1x = edit.v_x1;
				ev->ev_mm1y = edit.v_y1;
				ev->ev_mm1width = (edit.v_x2 - edit.v_x1 + 1);
				ev->ev_mm1height = (edit.v_y2 - edit.v_y1 + 1);
				return;
			}
		}

		if (ob_ptr->ob_head<0)
		{
			objc_offset(tree,obj,&ev->ev_mm1x,&ev->ev_mm1y);
			ev->ev_mm1width = ob_ptr->ob_width;
			ev->ev_mm1height = ob_ptr->ob_height;
		}
		else
		{
			ev->ev_mm1x = x - 1;
			ev->ev_mm1y = y - 1;
			ev->ev_mm1width = 3;
			ev->ev_mm1height = 2;
		}
	}
	else
	{
		ev->ev_mm1flags = 0;
		*(GRECT *) &ev->ev_mm1x = *(GRECT *) &tree->ob_x;
	}

	if (mouse_flag)
	{
		graf_mouse(ARROW,NULL);
		mouse_flag = 0;
	}
}

int klickobj(DIAINFO *info,EVENT *event,int *obj,boolean top)
{
	OBJECT *tree = info->di_tree;

	if ((*obj = objc_find(tree,ROOT,MAX_DEPTH,event->ev_mmox,event->ev_mmoy))>=0)
	{
		int dummy,ind=FALSE;

		if ((dummy = is_rb_chk(tree,*obj))>=0)
		{
			if (event->ev_mbreturn!=2 && !(tree[*obj].ob_flags & EDITABLE) &&
				!(tree[*obj].ob_state & DISABLED))
			{
				*obj = dummy;
				ind = TRUE;
			}
		}
		else if (info->di_fly && nonsel_fly && !(tree[*obj].ob_flags & (SELECTABLE|EDITABLE|EXIT|TOUCHEXIT)))
		{
			evnt_timer(20,0);
			if (_mouse_but() & 1)
			{
				do_jump_fly(tree,FAIL,0);
				return(TRUE);
			}
		}

		dummy = objekt_handler(info,*obj,event->ev_mbreturn,event->ev_mmox,event->ev_mmoy,ind,top);

		if (dummy)
		{
			if (dummy!=FAIL)
			{
				*obj = dummy;
				return(FALSE);
			}
			else if (!top)
			{
				cursor(FALSE);
				top_window(event,info);
				x_events = (xf_init) ? xf_init(event) : 0;
			}
		}

		return(TRUE);
	}
	else if (info->di_fly)
	{
		do_jump_fly(tree,event->ev_mmox,event->ev_mmoy);
		mouse_cursor(event);
		_no_click();
		return(TRUE);
	}
	else
		return(FAIL);
}

int key_handler(OBJECT *tree,int state,int scan,EVENT *event)
{
	reg int sn=(int) (((unsigned) scan)>>8),obj,hot,shft;

	shft = (state & 3) ? TRUE : FALSE;
	hot = shft ? 6 : 4;

	if (!state)
	{
		obj = FAIL;

		switch (sn)
		{
		case SCANRET:
			if (return_default || dinfo->di_ed_obj<0)
			{
				key_taken = TRUE;
				if (dinfo->di_default>0)
					obj = dinfo->di_default;
				else
					return (FAIL);
			}
			break;
		case SCANENTER:
			if (dinfo->di_ed_obj<0 && dinfo->di_default>0)
				obj = dinfo->di_default;
			break;
		case SCANHELP:
			obj = dinfo->di_help;
			break;
		case SCANUNDO:
			obj = dinfo->di_undo;
		}

		if (obj>0)
		{
			key_taken = TRUE;
			return(objekt_handler(dinfo,obj,hot,FAIL,FAIL,FALSE,TRUE));
		}
	}

	if ((state & K_ALT) || (dinfo->di_ed_obj<0 && !(state & K_CTRL)))
	{
		if ((obj = _is_hotkey(tree,scan,state))>=0)
		{
			key_taken = TRUE;
			if (!(hot & 2) && is_editable(tree,obj,tree[obj].ob_flags))
			{
				sel_edit(tree,obj,TRUE);
				return(FAIL);
			}
			else if (!is_hidden(tree,obj,TRUE))
				return(objekt_handler(dinfo,obj,hot,FAIL,FAIL,FALSE,TRUE));
			else
				return(FAIL);
		}
	}

	if (dinfo->di_ed_obj>0)
	{
		key_taken = TRUE;

		if (!cursor_handler(tree,state,sn,event))
		{
			if (sn==SCANUNDO)
				edit_string(undobuff);
			else if (state & K_CTRL)
			{
				reg char *text = dinfo->di_ed_objptr->ob_spec.tedinfo->te_ptext;
				reg char *c	= text+dinfo->di_ed_index;

				switch(sn)
				{
				case CTRLLEFT:
					{
						while ((c>text) && (word_ascii(*(--c))));
						while ((c>text) && (!word_ascii(*(--c))));
						if (c>text)
							edit_pos((int) (c - text + 1),FALSE);
						else
							edit_pos(0,FALSE);
					}
					break;
				case CTRLRIGHT:
					{
						while (word_ascii(*c++));
						if (*(--c) != '\0')
						{
							while (!word_ascii(*c++));
							if (*(--c) != '\0')
								edit_pos((int) (c - text),FALSE);
						}
						else
							edit_pos((int) (c - text),FALSE);
					}
					break;
				case SCANUP:
					{
						int o_i = hist_index;
						insert_history(text);
						if (shft)
						{
							reg size_t n = strlen(text);
							if (n)
							{
								reg int i;
								for (i=(hist_index!=o_i) ? 1 : 0;i<20;i++)
									if (!strncmp(history[i],text,n))
									{
										edit_string(history[i]);
										hist_index = i;
										break;
									}
							}
						}
						else
						{
							if ((hist_index<19) && (history[hist_index+1][0]))
								hist_index++;
							edit_string(history[hist_index]);
						}
					}
					break;
				case SCANDOWN:
					{
						insert_history(text);
						if (shft)
						{
							reg size_t n = strlen(text);
							if (n)
							{
								reg int i;
								for (i=19;i>=0;i--)
									if (!strncmp(history[i],text,n))
									{
										edit_string(history[i]);
										hist_index = i;
										break;
									}
							}
						}
						else
						{
							if ((hist_index>0) && (history[hist_index-1][0]))
								hist_index--;
							edit_string(history[hist_index]);
						}
					}
					break;
				default:
					{
						int ascii = scan_2_ascii(scan,state),flag;

						switch (ascii)
						{
						case 'X':
						case 'C':
							if (shft)
								flag = clipbrd_save(O_WRONLY|O_APPEND|O_CREAT);
							else
							{
								scrp_clear(0);
								flag = clipbrd_save(O_WRONLY|O_CREAT);
							}

							if (flag && ascii=='X')
							{
								edit_off();
								*dinfo->di_ed_objptr->ob_spec.tedinfo->te_ptext = '\0';
								ob_draw_chg(dinfo,dinfo->di_ed_obj,NULL,FAIL,TRUE);
								edit_on();
							}
							break;
						case 'V':
							clipbrd_load((shft) ? TRUE : FALSE);
							break;
						default:
							key_taken = FALSE;
							break;
						}
					}
					break;
				}
			}
			else
			{
				char string[128],*text=dinfo->di_ed_objptr->ob_spec.tedinfo->te_ptext;

				strcpy(string,text);
				edit_objc(tree,dinfo->di_ed_obj,scan,&dinfo->di_ed_index,ED_CHAR);
				key_taken = strcmp(string,text);
			}
		}

		if (key_taken)
		{
			if ((dinfo->di_ed_objptr->ob_flags) & INDDEFAULT)
				test_inddefault(tree,dinfo->di_ed_objptr);

			event->ev_mmgpbuf[0]=OBJC_EDITED;
			do_func(MU_MESAG,event);
		}
	}
	return(FAIL);
}

boolean clipbrd_save(int mode)
{
	char path[256],buf[128],*text=dinfo->di_ed_objptr->ob_spec.tedinfo->te_ptext;
	long len;
	int handle;

	scrp_read(path);
	if (*path)
	{
		strmfp(path,NULL,"SCRAP.TXT");
		if ((handle = open(path,mode))>0)
		{
			len = strlen(text);
			strcpy(buf,text);
			buf[len++] = '\r';
			buf[len++] = '\n';
#ifdef __MINT_LIB__
			write(handle,buf,(unsigned) len);
#else
			write(handle,buf,len);
#endif
			close(handle);
			return(TRUE);
		}
	}
	return(FALSE);
}

void clipbrd_load(boolean flag)
{
	char path[256],buf[128];
	int handle;

	scrp_read(path);
	if (path[0]!='\0')
	{
		strmfp(path,NULL,"SCRAP.TXT");
		if ((handle = open(path,O_RDONLY))>0)
		{
			if (read(handle,buf,127)>0);
			{
				reg char *line;
				
				buf[127] = '\0';
				if ((line = strchr(buf,'\r'))!=NULL || (line = strchr(buf,'\n'))!=NULL)
					*line = '\0';

				if (flag)
				{
					char str[256];

					strcpy(str,dinfo->di_ed_objptr->ob_spec.tedinfo->te_ptext);
					strcat(str,buf);
					strncpy(buf,str,127);
				}

				edit_string(buf);
			}
			close(handle);
		}
	}
}

void edit_string(char *str)
{
	TEDINFO *ted=dinfo->di_ed_objptr->ob_spec.tedinfo;
	reg char *masc = ted->te_ptmplt;
	reg int len = 0;

	while (*masc)
		if (*masc++=='_') len++;

	edit_off();
	strncpy(ted->te_ptext,str,(long) len);
	ob_draw_chg(dinfo,dinfo->di_ed_obj,NULL,FAIL,TRUE);
	edit_on();
}

boolean word_ascii(char c)
{
	if (c)
	{
		if (isalnum(c))
			return(TRUE);
		else
		{
			reg char *ch = umlaute;

			while (*ch)
				if (*ch++==c)
					return(TRUE);
		}
	}
	return(FALSE);
}

void test_inddefault(OBJECT *tree,OBJECT *ind)
{
	reg OBJECT *obj = &tree[dinfo->di_default];
	reg int state;

	state = obj->ob_state;

	if ((*(ind->ob_spec.tedinfo->te_ptext))=='\0')
		state |= DISABLED;
	else
		state &= ~DISABLED;

	if (state!=(obj->ob_state))
	{
		obj->ob_state = state;
		ob_draw_chg(dinfo,dinfo->di_default,NULL,FAIL,FALSE);
	}
}

void insert_history(reg char *str)
{
	reg int i;

	if (strlen(str)>0l)
	{
		for (i=19;--i>=0;)
			if (!strcmp(history[i],str))
				return;

		for (i=19;i>=1;i--)
			strcpy(history[i],history[i-1]);
		strcpy(history[0],str);
		if ((hist_index < 19) && (history[hist_index+1][0]))
			hist_index++;
	}
}

int cursor_handler(OBJECT *tree,int state,int scan,EVENT *event)
{
	if (!(state & K_CTRL))
	{
		if (state & 3)
		{
			switch(scan)
			{
			case SCANDEL:
				{
					char *text = dinfo->di_ed_objptr->ob_spec.tedinfo->te_ptext;
					edit_off();
					text[dinfo->di_ed_index] = '\0';
					ob_draw_chg(dinfo,dinfo->di_ed_obj,NULL,FAIL,TRUE);
					edit_on();
				}
				break;
			case SCANRET:
			case SCANENTER:
			case SCANTAB:
				prev_edit(tree);
				break;
			case SCANUP:
				first_edit(tree);
				break;
			case SCANHOME:
			case SCANDOWN:
				last_edit(tree);
				break;
			case SCANLEFT:
				edit_pos(0,FALSE);
				break;
			case SCANRIGHT:
				edit_off();
				edit_on();
				break;
			case SCANINS:
				_asc=TRUE;
				_event=event;
				ascii_box(dinfo->di_title,xf_init,xf_msg);
				_asc=FALSE;
				break;
			default:
				return(FALSE);
			}
		}
		else
		{
			switch(scan)
			{
			case SCANHOME:
				{
					first_edit(tree);
					edit_pos(0,FALSE);
				}
				break;
			case SCANUP:
				prev_edit(tree);
				break;
			case SCANDOWN:
			case SCANTAB:
			case SCANENTER:
			case SCANRET:
				next_edit(tree);
				break;
			case SCANINS:
				edit_objc(tree,dinfo->di_ed_obj,' ',&dinfo->di_ed_index,ED_CHAR);
				break;
			default:
				return(FALSE);
			}
		}
		return(FAIL);
	}
	else
		return(FALSE);
}

char ascii_box(char *title,int (*init)(EVENT *),void (*call_func)(EVENT *))
{
	int exit;

	if (_asc)
		edit_off();
	exit = xdialog(ascii_tree,title,TRUE,FALSE,AUTO_DIAL|MODAL,init,call_func);

	if (exit>0)
	{
		if (exit!=CANCEL)
		{
			int x,ox,d,ascii;

			_mouse_pos(&x,&d);
			objc_offset(ascii_tree,exit,&ox,&d);
			_no_click();

			ascii = (exit - ASC0)<<5;
			if ((d = x-ox)>=0)
				ascii += d/gr_cw;

			if (_asc)
			{
				if (dinfo->di_flag>=WINDOW)
					wind_set(WF_TOP,dinfo->di_handle);
				re_init(_event);
				edit_objc(dinfo->di_tree,dinfo->di_ed_obj,ascii,&dinfo->di_ed_index,ED_CHAR);
				if ((dinfo->di_ed_objptr->ob_flags) & INDDEFAULT)
					test_inddefault(dinfo->di_tree,dinfo->di_ed_objptr);
			}
			else
				return(ascii);
		}
		else if (_asc)
			re_init(_event);
	}

	return(0);
}

void edit_off()
{
	int index = dinfo->di_ed_index;

	if (dinfo->di_cursor)
	{
		edit_objc(dinfo->di_tree,dinfo->di_ed_obj,0,&index,ED_END);
		dinfo->di_cursor = 0;
	}
}

void edit_on()
{
	if (dinfo->di_cursor==0)
	{
		edit_objc(dinfo->di_tree,dinfo->di_ed_obj,0,&dinfo->di_ed_index,ED_INIT);
		dinfo->di_cursor = 1;
	}
}

void sel_edit(OBJECT *tree,int obj,boolean off)
{
	if (off==TRUE)
		edit_off();

	if ((obj != dinfo->di_ed_obj) && (dinfo->di_ed_obj!=FAIL))
		insert_history(dinfo->di_ed_objptr->ob_spec.tedinfo->te_ptext);

	dinfo->di_ed_objptr = &tree[obj];

	if (obj != dinfo->di_ed_obj)
		strcpy(undobuff,dinfo->di_ed_objptr->ob_spec.tedinfo->te_ptext);

	dinfo->di_ed_obj = obj;

	if (off!=FAIL)
		edit_on();
}

boolean is_editable(OBJECT *tree,int obj,int flag)
{
	if ((flag & EDITABLE) && !is_hidden(tree,obj,FALSE))
		return(TRUE);
	else
		return(FALSE);
}

boolean is_hidden(OBJECT *tree,int index,boolean flag)
{
	reg OBJECT *obj = tree+index;

	if (obj->ob_flags & HIDETREE)
		return(TRUE);
	else if (flag || !(obj->ob_state & DISABLED))
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
	else
		return(TRUE);
}

void first_edit(OBJECT *tree)
{
	reg OBJECT *obj = tree;
	reg int index= 0;

	do
	{
		obj++;index++;
		if (is_editable(tree,index,obj->ob_flags))
		{
			sel_edit(tree,index,TRUE);
			break;
		}
	}
	while (!(obj->ob_flags & LASTOB));
}

void last_edit(OBJECT *tree)
{
	reg OBJECT *obj = tree;
	reg int index,last;

	index = last = 0;
	do
	{
		obj++;index++;
		if (is_editable(tree,index,obj->ob_flags))
			last = index;
	}
	while (!(obj->ob_flags & LASTOB));

	if (last)
		sel_edit(tree,last,TRUE);
}

void next_edit(OBJECT *tree)
{
	reg OBJECT *obj  = dinfo->di_ed_objptr;
	reg int index	  = dinfo->di_ed_obj;
	reg boolean flag = FALSE;

	if (!(obj->ob_flags & LASTOB))
	{
		do
		{
			obj++;index++;
			if (is_editable(tree,index,obj->ob_flags))
			{
				sel_edit(tree,index,TRUE);
				flag = TRUE;
				break;
			}
		}
		while (!(obj->ob_flags & LASTOB));
	}
	if (!flag)
		first_edit(tree);
}

void prev_edit(OBJECT *tree)
{
	reg OBJECT *obj = dinfo->di_ed_objptr;
	reg int index	 = dinfo->di_ed_obj;
	reg int flag	 = FALSE;
	do
	{
		obj--;index--;
		if (is_editable(tree,index,obj->ob_flags))
		{
			sel_edit(tree,index,TRUE);
			flag = TRUE;
			break;
		}
	} while (index>0);
	if (!flag)
		last_edit(tree);
}

void edit_pos(int index,boolean off)
{
	reg char c,*t=dinfo->di_ed_objptr->ob_spec.tedinfo->te_ptext;
	t += index;

	if (off==FALSE)
		edit_off();
	c = *t;
	*t = '\0';
	edit_on();
	*t = c;
}

int is_rb_chk(reg OBJECT *tree,reg int obj)
{
	reg int index = 0;

	for(;;)
	{
		if (tree->ob_next==obj)
			switch (tree->ob_type & (~G_MODAL))
			{
			case G_CHK:
			case G_RB:
				return(index);
			}

		if (tree->ob_flags & LASTOB)
			break;
		else
		{
			tree++;
			index++;
		}
	}
	return(FAIL);
}

int _is_hotkey(OBJECT *tree,int key,int state)
{
	reg OBJECT *obj  = tree;
	reg int hot,index = 0,ascii = scan_2_ascii(key,state);

	do
	{
		obj++;index++;
		switch (obj->ob_type & (~G_MODAL))
		{
		case G_HOTKEY:
			if ((obj->ob_state>>8)==ascii)
				return(ob_get_parent(tree,index));
			break;
		case G_CHK:
		case G_RB:
			if ((hot=_get_hotkey(tree,index))>0 && (tree[hot].ob_state>>8)==ascii)
				return(index);
		}
	}
	while (!(obj->ob_flags & LASTOB));

	return(FAIL);
}

void edit_rect(OBJECT *tree,int obj,VRECT *edit,int *cw)
{
	reg OBJECT *obptr=&tree[obj];
	reg TEDINFO *ted=obptr->ob_spec.tedinfo;
	reg char *m;
	reg int x,w,we;

	objc_offset(tree,obj,&edit->v_x1,&edit->v_y1);
	if (ted->te_font==SMALL)
	{
		w = gr_sw;
		edit->v_y2 = gr_sh;
	}
	else
	{
		w = gr_cw;
		edit->v_y2 = gr_ch;
	}

	m  = ted->te_ptmplt;
	we = ((int) strlen(m))*w;

	switch(ted->te_just)
	{
	case TE_RIGHT:
		edit->v_x1 += obptr->ob_width-we-1;
		break;
	case TE_CNTR:
		edit->v_x1 += (obptr->ob_width-we)>>1;
		break;
	}
	edit->v_y1 += (obptr->ob_height - edit->v_y2)>>1;
	edit->v_y2 += edit->v_y1;

	while (*m!='\0' && *m++!='_')
		edit->v_x1 += w;

	m--;
	x = edit->v_x2 = edit->v_x1;
	while (*m!='\0')
	{
		x += w;
		if (*m++=='_')
			edit->v_x2 = x;
	}
	*cw = w;
}

int objekt_handler(DIAINFO *info,int obj,int hot,int x,int y,boolean ind,boolean top)
{
	reg OBJECT *tree = info->di_tree,*obptr = tree+obj;
	reg int flags = obptr->ob_flags;
	reg int state = obptr->ob_state;

	if (!(hot & 2) && (x!=FAIL) && (flags & EDITABLE))
	{
		if (top)
		{
			VRECT	 edit;
			int 	 va;

			edit_rect(tree,obj,&edit,&va);
			if (!(obptr->ob_state & DISABLED) && (x>=edit.v_x1) && (y>=edit.v_y1) && (y<=edit.v_y2))
			{
				reg TEDINFO *ted=obptr->ob_spec.tedinfo;
				reg char *t=ted->te_ptext,*m=ted->te_ptmplt;
				reg int pos,index;

				while (*m!='\0' && *m++!='_');
				pos = min((x-edit.v_x1+1)/va,(int) strlen(m)+1);
				for (index=pos;--index>0;)
					if (*m!='\0' && *m++!='_')
						pos--;
				pos = min(pos,(int) strlen(t));
				
				index = dinfo->di_ed_obj;
				if (dinfo->di_ed_index!=pos || index!=obj)
				{
					t += pos;
					va = *t;
					*t = '\0';
					sel_edit(tree,obj,TRUE);
					*t = va;
					if (index!=obj)
						strcpy(undobuff,ted->te_ptext);
				}
				return(FALSE);
			}
		}

		{
			int dummy = is_rb_chk(tree,obj);

			if (dummy!=FAIL)
			{
				obj = dummy;
				obptr = tree+obj;
				flags = obptr->ob_flags;
				state = obptr->ob_state;

				if (obptr->ob_state & DISABLED)
					return(FAIL);
			}

			goto object_handle;
		}
	}
	else if (!(state & DISABLED))
	{
		object_handle:
		if ((obptr->ob_type & (~G_MODAL))==G_FLY || ((obptr->ob_type & (~G_MODAL))>>8)==USERFLY)
			do_jump_fly(tree,FAIL,0);
		else if (flags & (SELECTABLE|EXIT|TOUCHEXIT))
		{
			if (flags & SELECTABLE)
			{
				if ((flags & RBUTTON) && (state & SELECTED))
					_no_click();
				else
				{
					state ^= SELECTED;
					if ((hot & 4) || ind || (flags & (RBUTTON|TOUCHEXIT)))
					{
						obptr->ob_state = state;
						ob_draw_chg(info,obj,NULL,FAIL,FALSE);

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
											obptr->ob_state &= ~SELECTED;
											ob_draw_chg(info,act,NULL,FAIL,FALSE);
											goto do_exit;
										}
										else
											break;
									}
								}
							}
						}
						if ((ind || (flags & RBUTTON)) && !(flags & TOUCHEXIT))
							_no_click();
					}
					else
					{
						reg OBJECT *ob = tree+obj;
						EVENT event;
						int x,y,events;

						event.ev_mflags = MU_BUTTON|MU_M1;
						event.ev_mbclicks = event.ev_bmask = 1;
						event.ev_mbstate = 0;

						objc_offset(tree,obj,&event.ev_mm1x,&event.ev_mm1y);
						event.ev_mm1width = ob->ob_width;
						event.ev_mm1height = ob->ob_height;

						_mouse_pos(&x,&y);
						if (rc_inside(x,y,(GRECT *) &event.ev_mm1x))
						{
							event.ev_mm1flags = 1;
							ob->ob_state ^= SELECTED;
							ob_draw_chg(info,obj,NULL,FAIL,FALSE);
						}
						else
							event.ev_mm1flags = 0;

						do
						{
							events = Event_Multi(&event,0);
							if (events & MU_M1)
							{
								event.ev_mm1flags = 1 - event.ev_mm1flags;
								ob->ob_state ^= SELECTED;
								ob_draw_chg(info,obj,NULL,FAIL,FALSE);
							}
						} while (!(events & MU_BUTTON));

						if (!(ob->ob_state & SELECTED))
							return(FALSE);
					}
				}
			}
			else if (flags & EXIT)
				_no_click();

			do_exit:
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

void edit_objc(OBJECT *tree,int obj,int scan,int *index,int mode)
{
	wind_update(BEG_UPDATE);
	objc_edit(tree,obj,scan,index,mode);
	wind_update(END_UPDATE);
}

void do_jump_fly(OBJECT *tree,int x,int y)
{
	MFDB dst;
	long mem;

	_beg_ctrl();
	dst.fd_addr = NULL;

	if ((long) Malloc(-1l)>(dinfo->di_length + 4096l))
		if ((mem = (long) Malloc(dinfo->di_length + 256l))>0l)
		{
			dst = dinfo->di_mfdb;
			dst.fd_addr = (int *) ((mem & 0xfffffffel) + 2);
			_bitblt(tree,&dst,TRUE);
		}

	_bitblt(tree,&dinfo->di_mfdb,FALSE);

	if (x<0)
	{
		graf_mouse(FLAT_HAND,NULL);
		graf_dragbox(tree->ob_width + 6,tree->ob_height + 6,
					 tree->ob_x - 3,tree->ob_y - 3,desk.g_x + 1,desk.g_y + 1,desk.g_w - 2,desk.g_h - 2,&tree->ob_x,&tree->ob_y);
		graf_mouse(ARROW,NULL);
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
	_bitblt(tree,&dinfo->di_mfdb,TRUE);

	if (dst.fd_addr)
	{
		_bitblt(tree,&dst,FALSE);
		Mfree((void *) mem);
	}
	else
	{
		if (dinfo->di_ed_obj>0)
			edit_off();

		objc_draw(tree,ROOT,MAX_DEPTH,desk.g_x,desk.g_y,desk.g_w,desk.g_h);

		if (dinfo->di_ed_obj>0)
			edit_on();
	}
	_end_ctrl();
}

boolean open_rsc(char *rscname,char *m_entry)
{
	if (init_gem(m_entry)==TRUE)
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
			exit_gem();
			return(FAIL);
		}
	}
	else
		return(FALSE);
}

void close_rsc()
{
	rsrc_free();
	exit_gem();
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

int xdialog(OBJECT *tree,char *name,boolean center,boolean shrgrw,int mode,int (*init)(EVENT *),void (*call_func)(EVENT *))
{
	DIAINFO info,*old=dinfo;
	int exit;

	open_dialog(tree,&info,name,center,shrgrw,mode);
	exit = X_Form_Do(0l, 0, init, call_func);
	if ((exit != W_ABANDON) && (exit != W_CLOSED))
	{
		exit &= 0x7fff;
		tree[exit].ob_state &= ~SELECTED;
	}
	close_dialog(&info,shrgrw);
	dinfo = old;

	return(exit);
}

void menu_enable(OBJECT *tree,boolean enable,boolean show)
{
	if (_app)
	{
		reg OBJECT *obj = tree;
		reg int index = 0,title = 0,string = 1;

		for (;;)
		{
			switch (obj->ob_type)
			{
			case G_TITLE:
				if (title)
					menu_ienable(tree,index,enable);
				else
					title = 1;
				break;
			case G_STRING:
				if (string)
				{
					menu_ienable(tree,index,enable);
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

		if (show)
			menu_bar(tree,1);
	}
}

boolean menu_dropped(OBJECT *m_tree)
{
	reg OBJECT *obj = (m_tree) ? m_tree : menu;

	if (obj)
		do
		{
			obj++;
			if (obj->ob_state & SELECTED)
				return(TRUE);
		} while (!(obj->ob_flags & LASTOB));
	return(FALSE);
}
