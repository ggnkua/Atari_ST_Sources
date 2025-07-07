#ifndef __E_GEM_LIB__
#define __E_GEM_LIB__

#define VERSION	"1.35"

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
#define AES_VERSION	gl_ap_version   /* EnhÑlt unter GCC die AES-Version */#define GLOBAL		_global[7]#define INTIN		_intin#define INTOUT		_intout#define vq_gdos		vq_vgdos int __aes__(unsigned long);		/* Def. aus der GemLib. */#define _aes(a, b) __aes__(b)
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
#define AES_VERSION	_AESglobal[0]   /* EnhÑlt unter Lattice C die AES-Version */#define GLOBAL		_AESglobal[7]#define INTIN		_AESintin#define INTOUT		_AESintout

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
	int		intin[132];
	int		intout[140];
	int		ptsin[145];
	int		ptsout[145];
} VDIPARBLK;

typedef struct
{
	int		*contrl;
	int		*intin;
	int		*ptsin;
	int		*intout;
	int		*ptsout;
} VDIPB;

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
extern VDIPARBLK _VDIParBlk;

void vdi(VDIPB *vdipb);

#endif	/* __MINT_LIB__ */

#define AES_VERSION		_GemParBlk.global[0]
#define GLOBAL			_GemParBlk.global#define INTIN			_GemParBlk.intin#define INTOUT			_GemParBlk.intout

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
#define d_fname		dta_name
#define d_length	dta_size

/* Macros zum Umsetzen geringer MiNT-GEM-Lib-Abweichungen von der
   Pure C und Lattice C GEM-Lib. */

#if (defined(__GNUC__) || defined(LATTICE)) && defined(__CREATE_E_GEM_LIB__)#define objc_edit(a,b,c,d,e) objc_edit(a,b,c,*d,e,d)#define evnt_timer(a,b) evnt_timer(((unsigned long)b << 16) + (unsigned short)a)#endif	/* (__GNUC__ || LATTICE) && __CREATE_E_GEM_LIB__ */

#else	/* __MINT_LIB__ */

#ifdef __PUREC__
#include <tos.h>
#include <aes.h>
#include <vdi.h>
#endif	/* __PUREC__ */
#endif	/* !__MINT_LIB__ */

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

#define	DD_OK			0
#define DD_NAK			1
#define DD_EXT			2
#define DD_LEN			3
#define DD_TRASH		4
#define DD_PRINTER		5
#define DD_CLIPBOARD	6

#define DD_TIMEOUT	4000			/* timeout in milliseconds */

#define DD_NUMEXTS	8
#define DD_EXTSIZE	32L
#define DD_NAMEMAX	128				/* max size of a drag&drop item name */

#define DD_HDRMAX	(8+DD_NAMEMAX)	/* max length of a drag&drop header */

int appl_getinfo(int,int *,int *,int *,int *);

#endif	/* WF_BEVENT */

#ifndef ED_INIT
#define ED_INIT 			EDINIT
#define ED_CHAR 			EDCHAR
#define ED_END 				EDEND
#endif	/* ED_INIT */

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

/* UnterstÅtzung von Winx 2.1 */
#define WF_RETURN		1
#define WF_WINX			22360
#define	WF_WINXCFG		22361
#define WF_OWNER		20
#define WF_BOTTOM		25
#define WM_BOTTOMED		33

#define COOKIE_XBRA		0x58425241L		/* `XBRA' */
#define COOKIE_VSCR		0x56534352L		/* `VSCR' */
#define COOKIE_MAGX		0x4D616758L		/* `MagX' */

#define	HOR_SLIDER		0
#define	VERT_SLIDER		1

#define GRAF_SET_ARROWS		1
#define GRAF_SET_SIZE_POS	2
#define GRAF_DRAW_SLIDER	4
#define GRAF_SET			(GRAF_SET_ARROWS|GRAF_SET_SIZE_POS)
#define GRAF_DRAW			(GRAF_SET|GRAF_DRAW_SLIDER)

#define OBJC_EDITED		31293

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

#define G_HOTKEY		(0x1000|G_USERDEF)
#define G_IND			(0x2000|G_USERDEF)
#define G_RB			(0x3000|G_USERDEF)
#define G_CHK			(0x4000|G_USERDEF)
#define G_FLY			(0x5000|G_USERDEF)
#define G_MODAL			0x8000

#define INDDEFAULT		0x8000

#undef	NULL
#define NULL			((void *)0)

#define SL_STEP			0
#define SL_LINEAR		1
#define SL_LOG			2
#define SL_EXP			3

#define W_ABANDON		-1
#define W_CLOSED		-2

#define NO_SCALING		0
#define SCALING			1
#define TEST_SCALING	2
#define DARK_SCALING	4

#define BOOLEAN		boolean
#define DIALMODE	dialmode

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

typedef struct
{
	long		di_mem;
	MFDB		di_mfdb;
	DIALMODE	di_flag;
	long		di_length;
	OBJECT		*di_tree;
	int			di_handle;
	int			di_fly;
	OBJECT		*di_ed_objptr;
	int			di_ed_obj,di_ed_index,di_cursor;
	int			di_default,di_help,di_undo;
	int			di_xy_off,di_wh_off,di_iconified;
	char		*di_title;
} DIAINFO;

typedef struct
{
	DIAINFO		*sl_info;
	int			sl_parent;
	int			sl_slider;
	int			sl_dec,sl_inc,sl_pos,sl_page,sl_max;
	char		sl_vh,sl_mode;
	int			sl_delay,sl_speed;
	void		(*sl_do)(OBJECT*,int,int,int);
} SLINFO;

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
extern	int	max_w,max_h,planes,colors,redraw;
extern	int aes_version,winx,magx;
extern  int small_font,small_font_id,ibm_font,ibm_font_id,fonts_loaded;

extern	GRECT	desk;
extern	VRECT	clip;
extern	MFDB	*screen;
extern	OBJECT	*menu,*iconified;
extern	DIAINFO	*dinfo;

void	ob_dostate(OBJECT*,int,int);
void	ob_undostate(OBJECT*,int,int);
int		ob_isstate(OBJECT*,int,int);
void	ob_doflag(OBJECT*,int,int);
void	ob_undoflag(OBJECT*,int,int);
int		ob_isflag(OBJECT*,int,int);
void	ob_xywh(OBJECT*,int,GRECT*);
char	*ob_get_text(OBJECT*,int,int);
void	ob_set_text(OBJECT*,int,char*);
int		ob_set_hotkey(OBJECT*,int,char);
char	ob_get_hotkey(OBJECT*,int);
void	ob_draw_chg(DIAINFO*,int,GRECT*,int,boolean);
void	ob_draw_list(DIAINFO*,int*,GRECT*);
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
#endif	/* __PUREC__ */
#endif	/* !__GNUC__ */

void	rc_array_to_grect(int*,GRECT*);
void	rc_sc_copy(GRECT*,int,int,int);
void	rc_sc_clear(GRECT*);
void	rc_sc_invert(GRECT*);

void	scrp_clear(int);
int		scrp_init(char*);
int		scrp_length(void);
int		scrp_find(char*,char*);

void	rsrc_calc(OBJECT*,int);
void	rsrc_init(int,int,int,int,int,char**,long*,BITBLK*,long*,ICONBLK*,TEDINFO*,OBJECT*,OBJECT**,RS_IMDOPE*);

void	menu_enable(OBJECT*,boolean,boolean);
boolean menu_dropped(OBJECT*);

void 	graf_busy_mouse(void);
void	graf_set_slider(SLINFO*,OBJECT*,int);
void	graf_arrows(SLINFO*,OBJECT*,int);
void	graf_rt_slidebox(SLINFO*,int);
int		graf_rt_rubberbox(int,int,GRECT*,int*,int*,void(*foo)(int*));

int		Event_Multi(EVENT*,long);

int		X_Form_Do(DIAINFO**,int,int(*foo1)(EVENT*),void(*foo2)(EVENT*));

int		appl_getfontinfo(int,int *,int *,int *);

boolean	init_gem(char*);
void	exit_gem(void);

boolean open_work(int*,int*);
void 	close_work(int);

boolean	open_rsc(char*,char*);
void	close_rsc(void);

void	fix_objects(OBJECT*,int);
void	scale_image(OBJECT*,int);
void	trans_image(OBJECT*);

void	save_clipping(int *);
void	restore_clipping(int *);

boolean open_dialog(OBJECT*,DIAINFO*,char*,boolean,boolean,int);
void	close_dialog(DIAINFO*,boolean);
void	redraw_dialog(DIAINFO*,GRECT*);
void	move_dialog(DIAINFO *info,GRECT *area);
void	redraw_iconified(int,OBJECT*,GRECT *);

int		xdialog(OBJECT*,char*,boolean,boolean,int,int(*foo1)(EVENT*),void(*foo2)(EVENT*));
int		xalert(int,int,int,BITBLK *,char *,char *,char *,int (*foo1)(EVENT*),void (*foo2)(EVENT *));

/* Definition der wichtigsten Alert-Icons als Makros */

#define	X_ICN_NONE		-1
#define X_ICN_MAX		17

#define	X_ICN_STOP		7
#define	X_ICN_QUESTION	10
#define X_ICN_ALERT		11

#define X_ICN_DISC_ERR	5
#define X_ICN_ERROR		6
#define X_ICN_FLOPPY	8
#define X_ICN_DISC		9
#define X_ICN_INFO		13
#define	X_ICN_PRT_ERR	15

int		Popup(POPUP*,int,int,int,int,int *,int);

void	dial_colors(int,int,int,int,int,int,int);
void	dial_options(boolean,boolean,boolean,boolean,boolean,boolean,boolean,boolean);
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

#ifdef __PUREC__
char	*getenv(const char*);	/* Funktionen gibt es in stdlib.h */
int		putenv(const char*);
#endif	/* __PUREC__ */

int		scan_2_ascii(int,int);
char	ascii_box(char *,int(*foo1)(EVENT*),void(*foo2)(EVENT*));

int		min(int,int);
int		max(int,int);
void	Min(int*,int);
void	Max(int*,int);

void	mfdb(MFDB*,int*,int,int,int,int);
long	mfdb_size(MFDB*);

#endif	/* __E_GEM_LIB__ */
