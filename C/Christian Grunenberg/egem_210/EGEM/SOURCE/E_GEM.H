#ifndef __E_GEM_LIB__
#define __E_GEM_LIB__

#define E_GEM_VERSION	"2.10"

#ifdef __GNUC__
/* Anpassung der Enhanced GEM-Library an GNU CC + MiNT-Lib */

#ifndef __MINT_LIB__
#define __MINT_LIB__    /* MiNT-Lib wird beim GCC verwendet! */
#endif	/* !__MINT_LIB__ */

#ifdef __CREATE_E_GEM_LIB__
#define __TCC_COMPAT__
#endif	/* __CREATE_E_GEM_LIB__ */

#define reg			/* Keine register Variablen */
#define cdecl		/* Kein `cdecl' unter GCC */

extern short _global[];

#define AES_VERSION	gl_ap_version   /* EnhÑlt unter GCC die AES-Version */
#define GLOBAL		_global
#define INTIN		_intin
#define INTOUT		_intout
#define ADDRIN		((void **)(&_ptsin[0]))

#define vq_gdos		vq_vgdos
 
int __aes__(unsigned long);		/* Def. aus der GemLib. */
#define _aes(a, b) __aes__(b)

extern short _app;
#endif	/* __GNUC__ */


#ifdef LATTICE
/* Anpassung der Enhanced GEM-Library an Lattice C + MiNT-Lib */

#ifndef __MINT_LIB__
#define __MINT_LIB__        /* MiNT-Lib wird bei Lattice verwendet! */
#endif	/* !__MINT_LIB__ */

#ifdef __CREATE_E_GEM_LIB__
#define __TCC_COMPAT__
#endif	/* __CREATE_E_GEM_LIB__ */

#define __TCC_GEMLIB__

#define reg					/* Keine register Variablen */
#define cdecl	__stdargs	/* `__stdargs' entspricht `cdecl' in Lattice C */

extern short _AESglobal[];
#define AES_VERSION	_AESglobal[0]   /* EnhÑlt unter Lattice C die AES-Version */
#define GLOBAL		_AESglobal
#define INTIN		_AESintin
#define INTOUT		_AESintout
#define ADDRIN		_AESaddrin

extern short _app;
#endif	/* LATTICE */


#ifdef __PUREC__
/* Anpassung an Pure C */

#define reg register

#ifdef __MINT_LIB__
#define __TCC_COMPAT__
#define __TCC_GEMLIB__

typedef struct
{
	int		contrl[15];
	int		global[15];
	int		intin[132];
	int		intout[140];
	void	*addrin[16];
	void	*addrout[16];
} GEMPARBLK;

extern GEMPARBLK _GemParBlk;

#endif	/* __MINT_LIB__ */

#define GLOBAL			_GemParBlk.global
#define AES_VERSION		GLOBAL[0]
#define INTIN			_GemParBlk.intin
#define INTOUT			_GemParBlk.intout
#define ADDRIN			_GemParBlk.addrin

extern int _app;
extern void _aes(int dummy,long);

#endif	/* __PUREC__ */

#include <stdlib.h>

#ifdef __MINT_LIB__
#ifdef __PUREC__
#define short		int
#endif	/* __PUREC__ */

#include <unistd.h>
#include <fcntl.h>
#include <osbind.h>
#include <aesbind.h>
#include <vdibind.h>

#define DTA			_DTA
#define	d_attrib	dta_attribute
#define d_fname		dta_name
#define d_length	dta_size

/* Macros zum Umsetzen geringer MiNT-GEM-Lib-Abweichungen von der
   Pure C und Lattice C GEM-Lib. */

#if (defined(__GNUC__) || defined(LATTICE)) && defined(__CREATE_E_GEM_LIB__)
#define evnt_timer(a,b) evnt_timer(((unsigned long)b << 16) + (unsigned short)a)
#endif	/* (__GNUC__ || LATTICE) && __CREATE_E_GEM_LIB__ */

#else	/* __MINT_LIB__ */

#ifdef __PUREC__
#include <tos.h>
#include <aes.h>
#include <vdi.h>
#endif	/* __PUREC__ */
#endif	/* !__MINT_LIB__ */

#undef CH_EXIT
#define CH_EXIT				90

#ifndef WF_BEVENT /* MTOS-1.01-Erweiterungen bereits definiert ? */

#define WF_BEVENT 			24
#define WM_UNTOPPED 		30
#define WM_ONTOP 			31

#define AP_TERM 			50

#endif	/* WF_BEVENT */

#ifndef WF_ICONIFY /* MTOS-1.08-Erweiterungen bereits definiert ? */

#define WF_ICONIFY			26
#define WF_UNICONIFY		27
#define WF_UNICONIFYXYWH	28

#define WM_ICONIFY			34
#define WM_UNICONIFY		35
#define WM_ALLICONIFY		36

#define SMALLER				0x4000

#define AP_DRAGDROP			63

#define NO_DD			-100
#define NO_RECEIVER		-101

#define	DD_OK			0
#define DD_NAK			1
#define DD_EXT			2
#define DD_LEN			3
#define DD_TRASH		4
#define DD_PRINTER		5
#define DD_CLIPBOARD	6

#define DD_TIMEOUT		3000			/* timeout in milliseconds */

#define DD_NUMEXTS		8
#define DD_EXTSIZE		32L
#define DD_NAMEMAX		128				/* max size of a drag&drop item name */

#define DD_HDRMAX		(8+DD_NAMEMAX)	/* max length of a drag&drop header */

int appl_search(int,char*,int*,int*);
int appl_getinfo(int,int *,int *,int *,int *);

#endif	/* WF_BEVENT */

#ifdef __MINT_LIB__

typedef struct
{
	int ev_mflags,ev_mbclicks,ev_bmask,ev_mbstate,ev_mm1flags,
		ev_mm1x,ev_mm1y,ev_mm1width,ev_mm1height,ev_mm2flags,
		ev_mm2x,ev_mm2y,ev_mm2width,ev_mm2height;
	unsigned int ev_mtlocount,ev_mthicount;
	int ev_mwich,ev_mmox,ev_mmoy,ev_mmobutton,ev_mmokstate,
		ev_mkreturn,ev_mbreturn;
	int ev_mmgpbuf[8];
} EVENT;

int 	EvntMulti(EVENT *evnt_struct);

#endif	/* __MINT_LIB__ */

#ifndef GDOS_PROP

#define GDOS_PROP       0			/* Speedo GDOS font */
#define GDOS_MONO       1			/* Speedo GDOS font, force monospace output */
#define GDOS_BITM       2			/* GDOS bit map font */

#define te_fontid       te_junk1	/* GDOS font id */
#define te_fontsize     te_junk2	/* GDOS font size in points */

#endif

#ifndef WHITEBAK
#define WHITEBAK	64
#endif

#ifndef DRAW3D
#define DRAW3D		128
#endif

typedef struct
{
	int ev_mflags;
	int ev_mb1clicks,ev_mb1mask,ev_mb1state;
	int ev_mm1flags,ev_mm1x,ev_mm1y,ev_mm1width,ev_mm1height;
	int ev_mm2flags,ev_mm2x,ev_mm2y,ev_mm2width,ev_mm2height;
	unsigned int ev_mt1locount,ev_mt1hicount;
	int ev_mwich,ev_mmox,ev_mmoy,ev_mmobutton,ev_mmokstate,ev_mkreturn,ev_mb1return;
	int ev_mmgpbuf[8];
	int ev_mb2clicks,ev_mb2mask,ev_mb2state;
	int ev_mm3flags,ev_mm3x,ev_mm3y,ev_mm3width,ev_mm3height;
	int ev_mm4flags,ev_mm4x,ev_mm4y,ev_mm4width,ev_mm4height;
	long ev_mt2count,ev_mt3count,ev_mt4count;
	long ev_mt1last,ev_mt2last,ev_mt3last,ev_mt4last;
	int ev_mb2return;
} XEVENT;

#ifndef __RC_OBJ_C__
#define ev_mbclicks		ev_mb1clicks
#define ev_mbmask		ev_mb1mask
#define ev_bmask		ev_mb1mask
#define ev_mbstate		ev_mb1state
#define ev_mbreturn		ev_mb1return

#define ev_mtlocount	ev_mt1locount
#define ev_mthicount	ev_mt1hicount
#define ev_mtlast		ev_mt1last
#endif	/* __RC_OBJ_C__ */

#define MU_TIMER1		MU_TIMER
#define	MU_TIMER2		0x0040
#define MU_TIMER3		0x0080
#define MU_TIMER4		0x0100

#define MU_M3			0x0200
#define MU_M4			0x0400

#define MU_BUTTON1		MU_BUTTON
#define MU_BUTTON2		0x0800

#define MU_GET_MESSAG	0x4000
#define	MU_NO_HANDLER	0x8000

#define WF_RETURN		1
#define WF_WINX			22360
#define	WF_WINXCFG		22361

#ifndef WF_OWNER
#define WF_OWNER		20
#endif

#ifndef WF_BOTTOM
#define WF_BOTTOM		25
#define WM_BOTTOMED		33
#endif

#ifndef WM_M_BDROPPED
#define BACKDROP		0x2000
#define WM_M_BDROPPED	100
#endif

#define WM_SHADED		22360
#define WM_UNSHADED		22361

#define COOKIE_XBRA		0x58425241L		/* `XBRA' */
#define COOKIE_VSCR		0x56534352L		/* `VSCR' */
#define COOKIE_MAGX		0x4D616758L		/* `MagX' */
#define COOKIE_MINT		0x4d694e54L		/* 'MiNT' */
#define COOKIE_ICFS		0x49434653L		/* 'ICFS' */

#define ICF_GETSIZE		0x0000
#define ICF_GETPOS		0x0001
#define ICF_FREEPOS		0x0002
#define ICF_FREEALL		0x0100
#define ICF_INFO		0x0200
#define ICF_CONFIG		0x0201
#define ICF_SETSIZE		0x0202
#define ICF_SETSPACE	0x0203

#define OBJC_EDITED		0x7a00
#define OBJC_CHANGED	0x7a01
#define OBJC_SIZED		0x7a02
#define OBJC_DRAGGED	0x7a03

#define XACC_AV_INIT	0x7a10
#define XACC_AV_EXIT	0x7a11

#define WIN_CHANGED		0x7a21
#define WIN_SCROLLED	0x7a22
#define WIN_TOPPED		0x7a23
#define WIN_CLOSED		0x7a24
#define WIN_VSLSIZE		0x7a25
#define WIN_HSLSIZE		0x7a26
#define WIN_NAME		0x7a27
#define WIN_INFO		0x7a28
#define WIN_HSLIDE		0x7a29
#define WIN_VSLIDE		0x7a2a

#define CENTER			1
#define MOUSEPOS		2
#define XPOS			3
#define YPOS			4
#define XYPOS			5
#define OBJPOS			6

#define POPUP_BTN		0
#define POPUP_CYCLE		1
#define POPUP_CHECK		2
#define POPUP_BTN_CHK	(POPUP_BTN|POPUP_CHECK)
#define POPUP_CYCLE_CHK	(POPUP_CYCLE|POPUP_CHECK)
#define POPUP_RADIO		POPUP_BTN_CHK
#define POPUP_SELECT	POPUP_BTN

#define FLY_DIAL		1
#define WIN_DIAL		2
#define AUTO_DIAL		(FLY_DIAL|WIN_DIAL)
#define MODAL			4
#define FRAME			8
#define NO_ICONIFY		16

#define	WD_HSLIDER		256
#define	WD_VSLIDER		512
#define WD_SIZER		1024
#define WD_FULLER		2048
#define WD_INFO			4096
#define WD_SET_SIZE		8192

#define W_ABANDON		-1
#define W_CLOSED		-2

#define CHECKBOX		1
#define HEADER			2
#define RADIO			3
#define UNDERLINE		4
#define HOTKEY			5
#define CHKHOTKEY		6
#define RBHOTKEY		7
#define INDHOTKEY		8
#define FLYDIAL			9
#define TXTDEFAULT		10
#define USERFLY			11
#define HELP_BTN		12
#define ATTR_TEXT		13
#define CYCLE_BUTTON	14
#define ARROW_LEFT		15
#define ARROW_RIGHT		16
#define ARROW_UP		17
#define ARROW_DOWN		18
#define UNDO_BTN		19

#define G_HOTKEY		(0x0100|G_USERDEF)
#define G_IND			(0x0200|G_USERDEF)
#define G_RB			(0x0300|G_USERDEF)
#define G_CHK			(0x0400|G_USERDEF)
#define G_FLY			(0x0500|G_USERDEF)
#define G_XTEXT			(0x0600|G_USERDEF)

#define G_UNMODAL		0x4000
#define G_MODAL			0x8000

#define G_TYPE			(~(G_MODAL|G_UNMODAL))

#define NO_SCALING		0
#define SCALING			1
#define TEST_SCALING	2
#define DARK_SCALING	4

#undef	NULL
#define NULL			((void *)0)

#define BOOLEAN		boolean
#define DIALMODE	dialmode

typedef struct
{
	char			*string;
	USERBLK 		text_blk;
	int 			font_id,font_size,color,center,mode;
} X_TEXT;

typedef struct
{
	long	cookie;
	long	product;
	int		version;
	int		x,y,w,h;
} INFOVSCR;

typedef struct
{
	long	cookie_id;
	long	cookie_value;
} COOKIE;

typedef enum
{
	FAIL=-1,
	FALSE,
	TRUE
} boolean;

typedef enum
{
	CLOSED,
	OPENED,
	FLYING,
	WINDOW,
	WIN_MODAL
} dialmode;

#define LINE_START	-5
#define LINE_END	-4
#define WIN_START	-3
#define WIN_END		-2
#define WIN_SCROLL	-1

#define PAGE_LEFT	WA_LFPAGE
#define PAGE_UP		WA_UPPAGE
#define	PAGE_RIGHT	WA_RTPAGE
#define PAGE_DOWN	WA_DNPAGE
#define LINE_LEFT	WA_LFLINE
#define LINE_UP		WA_UPLINE
#define LINE_RIGHT	WA_RTLINE
#define LINE_DOWN	WA_DNLINE

typedef struct
{
	int scroll,obj,tbar_l,tbar_r,tbar_u,tbar_d;
	int px_hpos,px_vpos,px_hline,px_vline;
	int	hpos,vpos,hsize,vsize,hpage,vpage,hscroll,vscroll;
} SCROLL;

#define ICONIFIED	1
#define SHADE		2
#define ICFS		4

typedef struct
{
	MFORM	*mouse_inform,*mouse_outform;
	int		handle,gadgets,mouse_in,mouse_out,inside,vdi_handle;
	char	iconified,fulled,opened,av_win;
	int		posnr,min_w,min_h;
	GRECT	max,curr,prev,work,icf_work;
	int		sl_hpos,sl_vpos,sl_hsize,sl_vsize;
	char	*name,*info,*icon_name;
	OBJECT	*icon;
	void	*redraw,*dialog;
	SCROLL	*scroll;
} WIN;

#define AV_DRAG		0
#define AV_START	1
#define MINT_DRAG	2

typedef struct
{
	int		dd_type,dd_originator;
	int		dd_mx,dd_my,dd_kstate;
	char	*dd_name,*dd_args,*dd_mem,dd_ext[4];
	long	dd_size;
	WIN		*dd_win;
} DRAG_DROP;

typedef struct
{
	char	*text,*masc,*valid;
	int		text_x,text_y,text_w,text_h;
	int		edit_x,edit_y,edit_w,edit_h;
	int		crs_x,crs_y,cw,ch;
} EDINFO;

#define MAX_PATH	256
#define MAX_EDIT	256

typedef struct
{
	int		valid;
    GRECT	area;
    MFDB	mfdb;
    void	*mem;
} RC_RECT;

typedef struct
{
	DIALMODE	di_flag;
	OBJECT		*di_tree;
	RC_RECT		di_rc;
	int			di_fly,di_drawn,di_mode;
	int			di_ed_obj,di_ed_index,di_cursor,di_insert;
	int			di_default,di_inddef,di_help,di_undo,di_ed_cnt,di_taken;
	int			di_xy_off,di_wh_off;
	char		*di_title,di_undobuff[MAX_EDIT];
	void		*di_slider;
	GRECT		di_edit;
	WIN			*di_win;
} DIAINFO;

typedef struct
{
	int scan,state,cmd;
} SLKEY;

typedef struct
{
	DIAINFO		*sl_info;
	int			sl_parent;
	int			sl_slider;
	int			sl_dec,sl_inc,sl_pos,sl_page,sl_max;
	char		sl_vh,sl_mode;
	int			sl_delay,sl_speed;
	void		(*sl_do)(OBJECT*,int,int,int,int);
	SLKEY		*sl_keys;
	int			sl_keys_cnt;
} SLINFO;

#define SL_UP		-1
#define SL_DOWN		-2
#define SL_PG_UP	-3
#define SL_PG_DN	-4
#define SL_START	-5
#define SL_END		-6

typedef struct
{
	DIAINFO		*p_info;
	OBJECT		*p_menu;
	int			p_parent;
	int 		p_button;
	int			p_cycle;
	boolean		p_wrap,p_set;
} POPUP;

#ifndef __MINT_LIB__
typedef struct
{
	int			v_x1;
	int			v_y1;
	int			v_x2;
	int			v_y2;
} VRECT;
#endif	/* !__MINT_LIB__ */

#ifdef __MINT_LIB__
typedef struct
{
	char		*unshift;
	char		*shift;
	char		*capslock;
} KEYTAB;

#ifdef __PUREC__
#define Keytbl	(KEYTAB *) Keytbl
#endif	/* __PUREC__ */
#endif	/* __MINT_LIB__ */

typedef struct
{
	int			dummy;
	int			*image;
} RS_IMDOPE;

typedef struct
{
	int			*but_on,*but_off;
} BUTTON;

typedef struct
{
	int			*hi_on,*hi_off,*lo_on,*lo_off;
} IMAGE;

typedef struct
{
	int			count;
	IMAGE 		*image;
} IMAGES;

extern	int	ap_id,menu_id,grhandle,x_handle;
extern	int	gr_cw,gr_ch,gr_bw,gr_bh,gr_sw,gr_sh;
extern	int	max_w,max_h,planes,colors,colors_available;
extern	int multi,aes_version,winx,magx,mint,AvServer;
extern  int small_font,small_font_id,ibm_font,ibm_font_id,fonts_loaded;
extern	int menu_available,search;

extern	GRECT	desk;
extern	VRECT	clip;
extern	MFDB	*screen;
extern	OBJECT	*iconified;

void	ob_dostate(OBJECT*,int,int);
void	ob_undostate(OBJECT*,int,int);
int		ob_isstate(OBJECT*,int,int);

#define ob_setstate(t,o,s)	t[o].ob_state = s

int		ob_disable(DIAINFO *,OBJECT *,int,int,int);
int		ob_select(DIAINFO *,OBJECT *,int,int,int);

#define SET_STATE	1
#define CLEAR_STATE	0
#define FLIP_STATE	-1

void	ob_doflag(OBJECT*,int,int);
void	ob_undoflag(OBJECT*,int,int);
int		ob_isflag(OBJECT*,int,int);

#define ob_setflags(t,o,f)	t[o].ob_flags = f

void	ob_xywh(OBJECT*,int,GRECT*);

char	*ob_get_text(OBJECT*,int,int);
void	ob_set_text(OBJECT*,int,char*);
void	ob_clear_edit(OBJECT *);

int		ob_set_hotkey(OBJECT*,int,char);
char	ob_get_hotkey(OBJECT*,int);

int		ob_draw(DIAINFO*,int);
int		ob_draw_chg(DIAINFO*,int,GRECT*,int,boolean);
int		ob_draw_list(DIAINFO*,int*,GRECT*);

void	ob_draw_dialog(OBJECT*,int,int,int,int);
void	ob_undraw_dialog(OBJECT*,int,int,int,int);

int		ob_radio(OBJECT*,int,int);
int		ob_get_parent(OBJECT*,int);

#ifdef __GNUC__
int		rc_inside(int,int,GRECT*);
#define rc_grect_to_array grect_to_array
#else	/* __GNUC__ */
void	rc_grect_to_array(GRECT*,int*);
#ifdef __PUREC__
int		rc_copy(GRECT*,GRECT*);
int		rc_equal(GRECT*,GRECT*);
int		rc_intersect(GRECT*,GRECT*);
int		rc_inside(int,int,GRECT*);
#else
#define rc_inside(a,b,c)	(rc_inside(a,b,c) ? 1 : 0)
#endif	/* __PUREC__ */
#endif	/* !__GNUC__ */

void	rc_array_to_grect(int*,GRECT*);

void	rc_sc_copy(GRECT*,int,int,int);
void	rc_sc_clear(GRECT*);
void	rc_sc_invert(GRECT*);
int		rc_sc_scroll(GRECT*,int,int,GRECT*);
int		rc_sc_save(GRECT*,RC_RECT*);
int		rc_sc_freshen(int,int,RC_RECT*);
int		rc_sc_restore(int,int,RC_RECT*,int);

void	scrp_clear(int);
long	scrp_length(void);
int		scrp_find(char*,char*);
int		scrp_path(char*,char*);
void	scrp_changed(int,long);

/* Definition des Clipboard-Protokolls */

#ifndef SC_CHANGED
#define	SC_CHANGED	80

#define	SCF_INDEF	0x0000
#define SCF_DBASE	0x0001
#define SCF_TEXT	0x0002
#define SCF_VECTOR	0x0004
#define SCF_RASTER	0x0008
#define SCF_SHEET	0x0010
#define SCF_SOUND	0x0020
#endif

int		menu_install(OBJECT*,int);
void	menu_enable(boolean);
void	menu_item_enable(int,int);
void	menu_select(int,int);
boolean menu_dropped(void);

void 	graf_busy_mouse(void);
void	graf_set_slider(SLINFO*,OBJECT*,int);

#define HOR_SLIDER			0
#define	VERT_SLIDER			1

#define GRAF_SET_ARROWS		1
#define GRAF_SET_SIZE_POS	2
#define GRAF_DRAW_SLIDER	4

#define GRAF_SET			(GRAF_SET_ARROWS|GRAF_SET_SIZE_POS)
#define GRAF_DRAW			(GRAF_SET|GRAF_DRAW_SLIDER)

#define SL_STEP				0
#define SL_LINEAR			1
#define SL_LOG				2
#define SL_EXP				3

void	graf_arrows(SLINFO*,OBJECT*,int);
void	graf_rt_slidebox(SLINFO*,int,int);

int		graf_rt_rubberbox(int,int,GRECT*,int*,int*,void(*foo)(int*));

int		Event_Multi(XEVENT*);
void	Event_Timer(int,int);
void	Event_Handler(int (*init)(XEVENT *,int),int (*handler)(XEVENT *));

int		X_Form_Do(DIAINFO**);

int		appl_xgetinfo(int,int *,int *,int *,int *);
int		appl_getfontinfo(int,int *,int *,int *);

#ifdef  __PUREC__
int		wind_xget(int, int, int *, int *, int *,int *);
#else
#define	wind_xget(hdl,field,p1,p2,p3,p4)	wind_get(hdl,field,p1,p2,p3,p4)
#endif

boolean	init_gem(char*,char*,char*,int,int,int);
void	exit_gem(int);

boolean open_work(int*,int*);
void 	close_work(int);

boolean	open_rsc(char*,char*,char*,char*,int,int,int);
void	close_rsc(int);

void	rsrc_calc(OBJECT*,int,int,int);
void	rsrc_init(int,int,int,int,int,char**,long*,BITBLK*,long*,ICONBLK*,TEDINFO*,OBJECT*,OBJECT**,RS_IMDOPE*,int,int);

void	fix_objects(OBJECT*,int,int,int);
void	scale_image(OBJECT*,int,int,int);
void	trans_image(OBJECT*);

void	vsf_aespattern(int,int,int,int);

void	vs_attr(void);
void	v_set_text(int,int,int,int*);
void	v_set_mode(int);
void	v_set_line(int,int);
void	v_set_fill(int,int,int);
void	v_aespattern(int,int,int);

void	save_clipping(int *);
void	restore_clipping(int *);

boolean open_dialog(OBJECT*,DIAINFO*,char*,char*,OBJECT*,boolean,boolean,int,int,SLINFO **);
void	close_dialog(DIAINFO*,boolean);
void 	close_all_dialogs(void);

WIN 	*open_window(char *,char *,char *,OBJECT *,int,int,int,int,GRECT*,GRECT*,SCROLL*,void (*foo)(WIN *,GRECT *));
void	window_reinit(WIN *,char *,char *,char *,int);
void	window_top(WIN *);
void	window_bottom(WIN *);
void	window_size(WIN *,GRECT *);
void	window_slider(WIN *,int,int,int);
void	window_name(WIN *,char *,char *);
void	window_set_mouse(WIN *,int,int,MFORM *,MFORM *);
void	window_mouse(WIN *);
void	window_info(WIN *,char *);
void	window_border(int,int,int,int,int,GRECT *);
void	window_calc(int,int,GRECT *,GRECT *);
WIN		*window_find(int,int);
void	redraw_window(WIN *,GRECT *);
void	scroll_window(WIN *,int,GRECT*);
void	window_scroll_slider(WIN *,int);
int		close_window(WIN *,int);
void	close_all_windows(void);

WIN		*get_window(int);
WIN		*get_top_window(void);

int		window_first(WIN *,GRECT *);
int		window_next(WIN *,GRECT *);

void	CycleCloseWindows(char,char,int,int);

int		get_dialog_info(int *,int *,int *,DIAINFO **);

int		xdialog(OBJECT*,char*,char*,OBJECT*,boolean,boolean,int);
int		xalert(int,int,int,BITBLK *,int,int,int,char *,char *,char *);

/* System-/Applikations-modale Alert-Box */

#define SYS_MODAL			0
#define APPL_MODAL			1

/* Ausrichtung der Buttons */

#define BUTTONS_CENTERED	0
#define BUTTONS_LEFT		1
#define BUTTONS_RIGHT		2

/* Definition der wichtigsten Alert-Icons als Makros */

#define	X_ICN_NONE		-1
#define X_ICN_MAX		17

#define	X_ICN_STOP		12
#define	X_ICN_QUESTION	10
#define X_ICN_ALERT		14

#define X_ICN_DISC_ERR	5
#define X_ICN_ERROR		6
#define X_ICN_FLOPPY	9
#define X_ICN_DISC		8
#define X_ICN_INFO		13
#define	X_ICN_PRT_ERR	15

int		Popup(POPUP*,int,int,int,int,int *,int);

void	dial_colors(int,int,int,int,int,int,int,int);
void	dial_options(boolean,boolean,boolean,boolean,boolean,boolean,boolean,boolean,boolean);

void	title_options(boolean,int,int);

void	radio_image(int,BUTTON*);
void	check_image(int,BUTTON*);
void	arrow_image(int,BUTTON*,BUTTON*,BUTTON*,BUTTON*);
void	cycle_image(int,BUTTON*);

void	create_cookie(COOKIE*,long,long);
boolean	new_cookie(COOKIE*);
boolean	get_cookie(long,long*);
void	remove_cookie(long);
void	move_cookiejar(long*,long);
long	cookie_size(void);

#ifndef SH_WDRAW
#define SH_WDRAW	72
#endif

void	drive_changed(int);
int		FileSelect(char *,char *,char *,char *,int);
char	*GetFilename(char *);
char	*GetExtension(char *);
char	*GetPath(char *);
int		GetDrive(char *);
char	*MakeFullpath(char *,char *, char *);

#ifdef __PUREC__
char	*getenv(const char*);	/* Funktionen gibt es in stdlib.h */
int		putenv(const char*);
#endif	/* __PUREC__ */

int		scan_2_ascii(int,int);
char	UpperChar(char);
char	LowerChar(char);
char	ascii_box(char *);

int		min(int,int);
int		max(int,int);
void	Min(int*,int);
void	Max(int*,int);

void	mfdb(MFDB*,int*,int,int,int,int);
long	mfdb_size(MFDB*);

/* Drag & Drop */

int		SendDragDrop(int,int,int,char*,char*,long,char *);
void	SetDragDrop(int,char*);

/* XAcc-2- und AV-Protokoll */

#define XACC		1

#define MSGGROUP1	0x01
#define MSGGROUP2	0x02

#define XACCVERSION	0x21
#define XACC_LEVEL	(MSGGROUP1|MSGGROUP2)

#ifndef ACC_ID
#define ACC_ID		0x400
#define ACC_OPEN	0x401
#define ACC_CLOSE	0x402
#define ACC_ACC		0x403
#define ACC_EXIT	0x404

#define ACC_ACK		0x500
#define ACC_TEXT	0x501
#define ACC_KEY		0x502
#define ACC_META	0x503
#define ACC_IMG		0x504
#endif

#define	X_MSG_TEXT	0x1
#define	X_MSG_META	0x2
#define	X_MSG_IMG	0x4

#define AV			2

#define MSG_SETSTATUS		0x001
#define MSG_START			0x002

#define	MSG_SENDKEY			0x001
#define MSG_ASKFILEFONT		0x002
#define MSG_ASKCONFONT		0x004
#define MSG_ASKOBJECT		0x008
#define MSG_OPENWIND		0x010
#define MSG_STARTPROG		0x020
#define MSG_ACCWINDOPEN		0x040
#define	MSG_STATUS			0x080
#define MSG_COPY_DRAGGED	0x100
#define MSG_PATH_UPDATE		0x200
#define MSG_EXIT			0x400

#ifndef AV_PROTOKOLL
#define AV_PROTOKOLL		0x4700
#define AV_GETSTATUS		0x4703
#define AV_STATUS			0x4704
#define AV_SENDKEY			0x4710
#define AV_ASKFILEFONT		0x4712
#define AV_ASKCONFONT		0x4714
#define AV_ASKOBJECT		0x4716
#define AV_OPENCONSOLE		0x4718
#define AV_OPENWIND			0x4720
#define AV_STARTPROG		0x4722
#define AV_ACCWINDOPEN		0x4724
#define AV_ACCWINDCLOSED	0x4726
#define AV_COPY_DRAGGED		0x4728
#define AV_PATH_UPDATE		0x4730
#define AV_WHAT_IZIT		0x4732
#define AV_DRAG_ON_WINDOW	0x4734
#define AV_EXIT				0x4736

#define VA_PROTOSTATUS		0x4701
#define VA_SETSTATUS		0x4705
#define VA_START			0x4711
#define VA_FILEFONT			0x4713
#define VA_CONFONT			0x4715
#define VA_OBJECT			0x4717
#define VA_CONSOLEOPEN		0x4719
#define VA_WINDOPEN			0x4721
#define VA_PROGSTART		0x4723
#define VA_DRAGACCWIND		0x4725
#define VA_COPY_COMPLETE	0x4729
#define VA_THAT_IZIT		0x4733
#define VA_DRAG_COMPLETE	0x4735

#define	VA_OB_UNKNOWN		0
#define VA_OB_TRASHCAN  	1
#define VA_OB_SHREDDER  	2
#define VA_OB_CLIPBOARD 	3
#define VA_OB_FILE      	4
#define VA_OB_FOLDER		5
#define VA_OB_DRIVE			6
#define VA_OB_WINDOW    	7
#endif

#define MAX_XACCS	32

typedef struct
{
	int		flag,id,version,menu_id,av_msgs,va_msgs;
	char	name[10],*xname,*xdsc;
} XAcc;

void 		*GetMsgBuffer(long);

XAcc		*find_xacc_xdsc(int,char*);
XAcc		*find_id(int);
XAcc		*find_app(int);

void		XAccBroadCast(int *);
int			XAccSendAck(int,int);
int			XAccSendKey(int,int,int);
int			XAccSendText(int,char *);
int			XAccSendMeta(int,int,char*,long);
int			XAccSendImg(int,int,char*,long);

int			AvSendMsg(int,int,int*);

int 		AppLoaded(char *);

/* MenÅ-Protokoll */

#ifndef WM_CLOSED
#define WM_CLOSED		0x0016
#endif

#ifndef WM_FULLED
#define WM_FULLED		0x0017
#endif

#ifndef WM_SAVE
#define WM_SAVE			0x1000
#define WM_SAVEAS		0x1001
#define WM_PRINT		0x1002
#define WM_UNDO			0x1003
#define WM_CUT			0x1004
#define WM_COPY			0x1005
#define WM_PASTE		0x1006
#define WM_SELECTALL	0x1007
#define WM_FIND			0x1008
#define WM_REPLACE		0x1009
#define WM_FINDNEXT		0x100a
#define WM_HELP			0x100b
#define WM_DELETE       0x100c
#endif

/* View-Protokoll */

#ifndef VIEW_FILE
#define VIEW_FILE		0x5600
#define VIEW_FAILED		0x5601
#define VIEW_OPEN		0x5602
#define VIEW_CLOSED		0x5603
#define VIEW_DATA		0x5604
#define VIEW_GETMFDB	0x5610#define VIEW_SETMFDB	0x5611#define VIEW_MFDB		0x5612

#define VIEWERR_ERROR	0
#define VIEWERR_SIZE	1
#define VIEWERR_COLOR	2
#define VIEWERR_WID		3
#define VIEWERR_MEM		4
#endif

/* wichtige Scan-Codes */

#define sl_key(s,a)	((s<<8)|a)

#define SCANESC		1
#define SCANTAB		15
#define SCANRET 	28
#define SCANDEL 	83
#define SCANBS		14
#define SCANENTER	114

#define SCANHELP	98
#define SCANUNDO	97
#define SCANINS 	82
#define SCANHOME	71

#define SCANUP		72
#define SCANDOWN	80

#define SCANLEFT	75
#define SCANRIGHT	77

#define CTRLLEFT	115
#define CTRLRIGHT	116

#define SCANF1		59
#define SCANF2		60
#define SCANF3		61
#define SCANF4		62
#define SCANF5		63
#define SCANF6		64
#define SCANF7		65
#define SCANF8		66
#define SCANF9		67
#define SCANF10		68

#define CTRLF1		84
#define CTRLF2		85
#define CTRLF3		86
#define CTRLF4		87
#define CTRLF5		88
#define CTRLF6		89
#define CTRLF7		90
#define CTRLF8		91
#define CTRLF9		92
#define CTRLF10		93

/* Makros fÅr Mauszeiger */

#define MouseArrow()		graf_mouse(ARROW,NULL)
#define MouseCursor()		graf_mouse(TEXT_CRSR,NULL)
#define MouseBee()			graf_mouse(BUSYBEE,NULL)
#define MouseHourGlass()	graf_mouse(HOURGLASS,NULL)
#define MousePointHand()	graf_mouse(POINT_HAND,NULL)
#define MouseFlatHand()		graf_mouse(FLAT_HAND,NULL)
#define MouseThinCross()	graf_mouse(THIN_CROSS,NULL)
#define MouseThickCross()	graf_mouse(THICK_CROSS,NULL)
#define MouseOutlineCross()	graf_mouse(OUTLN_CROSS,NULL)

void MouseOn(void);
void MouseOff(void);

#endif	/* __E_GEM_LIB__ */
