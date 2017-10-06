#ifndef __E_GEM_LIB__
#define __E_GEM_LIB__

#ifdef SMALL_LIGHT
#define SMALL_EGEM
#define SMALL_NO_XACC_AV
#define SMALL_NO_EDIT
#define SMALL_NO_DD
#define SMALL_NO_GRAF
#define SMALL_NO_POPUP
#define SMALL_NO_FONT
#define SMALL_NO_SCROLL
#define SMALL_NO_CLIPBRD
#define SMALL_NO_MENU
#define SMALL_ALERT
#define SMALL_NO_ICONIFY
#define SMALL_NO_XTEXT
#endif

#if defined(SMALL_NO_GRAF) || defined(SMALL_NO_POPUP) || defined(SMALL_NO_FONT)
#undef SMALL_NO_FSEL
#define SMALL_NO_FSEL
#endif

#if defined(SMALL_NO_XACC_AV)
#undef SMALL_NO_DD_FSEL
#define SMALL_NO_DD_FSEL
#undef SMALL_NO_PAULA
#define SMALL_NO_PAULA
#endif

#ifdef SMALL_NO_EDIT
#undef SMALL_EDIT
#define SMALL_EDIT
#endif

#ifdef SMALL_EDIT
#undef SMALL_NO_HZ
#define SMALL_NO_HZ
#endif

#define E_GEM			"EnhancedGEM"
#define E_GEM_VERSION	"2.20"
#define E_GEM_DATE		"Feb 03 1995"

#define XACCVERSION	0x22

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
#define AP_TFAIL			51

#endif	/* WF_BEVENT */

#ifndef FL3DMASK	/* 3D-Erweiterungen definiert? */
#define	FL3DMASK	0x0600
#define	FL3DNONE	0x0000
#define	FL3DIND		0x0200
#define	FL3DBAK		0x0400
#define	FL3DACT		0x0600
#endif

#ifndef WF_ICONIFY /* MTOS-1.08-Erweiterungen bereits definiert ? */

#define WF_ICONIFY			26
#define WF_UNICONIFY		27
#define WF_UNICONIFYXYWH	28

#define WM_ICONIFY			34
#define WM_UNICONIFY		35
#define WM_ALLICONIFY		36

#define SMALLER				0x4000

#define AP_DRAGDROP			63

#ifndef SMALL_NO_DD

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

#endif

int appl_search(int,char*,int*,int*);
int appl_getinfo(int,int *,int *,int *,int *);

#define	LK3DIND		1
#define LK3DACT		2
#define INDBUTCOL	3
#define ACTBUTCOL	4
#define BACKGRCOL	5
#define AD3DVALUE	6

#define OB_GETVAR	0
#define OB_SETVAR	1

int objc_sysvar(int,int,int,int,int *,int *);

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

#undef WHITEBAK
#define WHITEBAK	64

#undef DRAW3D
#define DRAW3D		128

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
#define MU_XTIMER		0x1000

#define MU_M3			0x0200
#define MU_M4			0x0400
#define	MU_MX			0x2000

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
#endif

#ifndef WM_BOTTOMED
#define WM_BOTTOMED		33
#endif

#ifndef WM_M_BDROPPED
#define BACKDROP		0x2000
#define WM_M_BDROPPED	100
#endif

#define WM_SHADED		22360
#define WM_UNSHADED		22361

#define COOKIE_VSCR			0x56534352L		/* `VSCR' */
#define COOKIE_MAGX			0x4D616758L		/* `MagX' */
#define COOKIE_MINT			0x4D694E54L		/* 'MiNT' */
#define COOKIE_ICFS			0x49434653L		/* 'ICFS' */
#define COOKIE_FSEL			0x4653454CL		/* 'FSEL' */
#define COOKIE_SELECTRIC	0x534C4354L		/* 'SLCT' */
#define COOKIE_FSMC			0x46534D43L		/* 'FSMC' */
#define COOKIE_FSM			0x5F46534DL		/* '_FSM' */
#define COOKIE_SPEEDO		0x5F535044L		/* '_SPD' */
#define COOKIE_GENEVA		0x476E7661L		/* 'Gnva' */

#define ICF_GETSIZE		0x0000
#define ICF_GETPOS		0x0001
#define ICF_FREEPOS		0x0002
#define ICF_FREEALL		0x0100
#define ICF_INFO		0x0200
#define ICF_CONFIG		0x0201
#define ICF_SETSIZE		0x0202
#define ICF_SETSPACE	0x0203

#ifndef SMALL_NO_EDIT
#define OBJC_EDITED		0x7a00
#endif

#ifndef SMALL_NO_HZ
#define CURSOR_INIT		0x7a01
#endif

#define OBJC_CHANGED	0x7a02
#define OBJC_SIZED		0x7a03

#ifndef SMALL_NO_DD
#define OBJC_DRAGGED	0x7a04
#endif

#ifndef SMALL_NO_MENU
#define MENU_INIT		0x7a05
#endif

#define MOUSE_INIT		0x7a06

#ifndef SMALL_NO_POPUP
#define POPUP_CHANGED	0x7a07
#endif

#ifndef SMALL_NO_GRAF
#define SLIDER_CHANGED	0x7a08
#endif

#ifndef SMALL_NO_XACC_AV
#define XACC_AV_INIT	0x7a10
#define XACC_AV_EXIT	0x7a11
#define XACC_AV_CLOSE	0x7a12
#endif

#define WIN_CHANGEFNT	30961

#define	FONT_CHANGED	0x7a18
#define	FONT_SELECT		0x7a19
#define FONT_ACK		0x7a1a

#define WIN_CHANGED		0x7a20
#ifndef SMALL_NO_SCROLL
#define WIN_SCROLLED	0x7a21
#endif
#define WIN_TOPPED		0x7a22
#define WIN_CLOSED		0x7a23
#define WIN_VSLSIZE		0x7a24
#define WIN_HSLSIZE		0x7a25
#define WIN_NAME		0x7a26
#define WIN_INFO		0x7a27
#define WIN_HSLIDE		0x7a28
#define WIN_VSLIDE		0x7a29
#define WIN_SIZED		0x7a2a
#define WIN_NEWTOP		0x7a2b

#define CENTER			1
#define MOUSEPOS		2
#define XPOS			3
#define YPOS			4
#define XYPOS			5
#define OBJPOS			6
#define MENUPOS			7

#define POPUP_BTN		0x00
#define POPUP_CYCLE		0x01
#define POPUP_CHECK		0x02
#define POPUP_INVCYCLE	0x04
#define POPUP_MENU		0x08
#define POPUP_PARENT	0x10
#define	POPUP_SUB		0x20
#define POPUP_3D		0x40
#define POPUP_NO_SHADOW	0x80
#define POPUP_BTN_CHK		(POPUP_BTN|POPUP_CHECK)
#define POPUP_CYCLE_CHK		(POPUP_CYCLE|POPUP_CHECK)
#define POPUP_INVCYCLE_CHK	(POPUP_INVCYCLE|POPUP_CHECK)

#define FLY_DIAL		0x0001
#define WIN_DIAL		0x0002
#define AUTO_DIAL		(FLY_DIAL|WIN_DIAL)
#define MODAL			0x0004
#define FRAME			0x0008
#define NO_ICONIFY		0x0010
#define SMALL_FRAME		0x0020
#define SMART_FRAME		(FRAME|SMALL_FRAME)
#define DDD_DIAL			0x0040

#define	WD_HSLIDER		0x0080
#define	WD_VSLIDER		0x0100
#define WD_SIZER		0x0200
#define WD_CLOSER		0x0400
#define WD_FULLER		0x0800
#define WD_INFO			0x1000
#define WD_SET_SIZE		0x2000
#define WD_TREE_SIZE	0x4000

#define W_ABANDON		-1
#define W_CLOSED		-2

#define CHECKBOX		0x01
#define HEADER			0x02
#define RADIO			0x03
#define UNDERLINE		0x04
#define HOTKEY			0x05
#define CHKHOTKEY		0x06
#define RBHOTKEY		0x07
#define INDHOTKEY		0x08
#define FLYDIAL			0x09
#define TXTDEFAULT		0x0a
#define USERFLY			0x0b
#define HELP_BTN		0x0c
#define ATTR_TEXT		0x0d
#define CYCLE_BUTTON	0x0e
#define ARROW_LEFT		0x0f
#define ARROW_RIGHT		0x10
#define ARROW_UP		0x11
#define ARROW_DOWN		0x12
#define UNDO_BTN		0x13
#define ESC_BTN			0x15
#define FIX_HEADER		0x16

#define G_HOTKEY		(0x2000|G_USERDEF)
#define G_IND			(0x2100|G_USERDEF)
#define G_RB			(0x2200|G_USERDEF)
#define G_CHK			(0x2300|G_USERDEF)
#define G_FLY			(0x2400|G_USERDEF)
#ifndef SMALL_NO_XTEXT
#define G_XTEXT			(0x2500|G_USERDEF)
#endif

#define G_UNMODAL		0x4000
#define G_MODAL			0x8000

#define G_TYPE			(~(G_MODAL|G_UNMODAL))

#define NO_SCALING		0
#define SCALING			1
#define TEST_SCALING	2
#define DARK_SCALING	4
#define STATIC_SCALING	8

#undef	NULL
#undef	NIL
#define NULL			((void *)0)
#define	NIL				((void *) -1l)

#define BOOLEAN		boolean
#define DIALMODE	dialmode

#ifndef SMALL_NO_XTEXT

typedef struct
{
	USERBLK text_blk;
	char	*string;
	int 	font_id,font_size,color,center,mode,effect;
} X_TEXT;

#ifdef __PUREC__
#define get_xtext(tree,obj) ((X_TEXT *)tree[obj].ob_spec.userblk->ub_parm)
#else
#define get_xtext(tree,obj) ((X_TEXT *)((*(USERBLK **) &tree[obj].ob_spec)->ub_parm))
#endif

#endif

#define	X_FAT			1
#define X_LIGHT			2
#define X_ITALICS		4
#define X_UNDERLINED	8
#define X_OUTLINED		16
#define X_SHADOWED		32
#define X_INVERS		64
#define X_3D			256
#define X_TITLE			512

typedef struct
{
	long	cookie;
	long	product;
	int		version;
	int		x,y,w,h;
} INFOVSCR;

typedef struct
{
	long			type;
	unsigned int	version;
	unsigned int	quality;
} GDOS_INFO;

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

#ifndef SMALL_NO_SCROLL
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

#define FAST_SCROLL	-1
#define NO_SCROLL	0
#define AUTO_SCROLL	1

typedef struct
{
	int scroll,obj,tbar_l,tbar_r,tbar_u,tbar_d;
	long px_hpos,px_vpos,hpos,vpos,hsize,vsize,hmax,vmax;
	int	px_hline,px_vline,hpage,vpage,hscroll,vscroll;
} SCROLL;
#else
#define SCROLL	void
#endif

#define SHADE		1
#define ICONIFIED	2
#define ICFS		4
#define SHUTDOWN	8

typedef struct
{
	int	menu,scan,state,mode,msg;
} MITEM;

#define MOUSE_FAIL		-2
#define MOUSE_OUT		-1
#define MOUSE_WORK		0
#define MOUSE_IN		1
#ifndef SMALL_NO_ICONIFY
#define MOUSE_IN_ICON	2
#endif
#ifndef SMALL_NO_EDIT
#define MOUSE_EDIT		3
#endif

typedef struct __win_info
{
#ifndef SMALL_NO_ICONIFY
	MFORM	*mouse_inform,*mouse_outform,*mouse_workform,*mouse_iconform;
	int		handle,gadgets,mouse_in,mouse_work,mouse_out,mouse_icon,inside,vdi_handle;
#else
	MFORM	*mouse_inform,*mouse_outform,*mouse_workform;
	int		handle,gadgets,mouse_in,mouse_work,mouse_out,inside,vdi_handle;
#endif
	char	iconified,fulled,opened;
#ifndef SMALL_NO_XACC_AV
	char	av_win;
#endif
	int		msgs,posnr,min_w,min_h;
	GRECT	max,curr,prev,work,first;
	int		sl_hpos,sl_vpos,sl_hsize,sl_vsize;
	char	*name,*info;
	char	name_buffer[256];
#ifndef SMALL_NO_ICONIFY
	GRECT	icon_work;
	OBJECT	*icon;
	char	*icon_name;
#endif
	void	(*redraw)(int,struct __win_info *,GRECT *);
	void	*dialog,*para;
#ifndef SMALL_NO_SCROLL
	SCROLL	*scroll;
#endif
	MITEM	*items;
	GRECT	mrect;
	int		mflag,items_cnt,index;
} WIN;

#define XM_TOP		0x01
#define XM_BOTTOM	0x02
#define XM_SIZE		0x04

#ifndef SMALL_NO_DD

#define AV_DRAG		0
#define AV_START	1
#define AV_OPEN		2
#define MINT_DRAG	3

typedef struct
{
	int		dd_type,dd_originator;
	int		dd_mx,dd_my,dd_kstate;
	char	*dd_name,*dd_args,*dd_mem,dd_ext[4];
	long	dd_size;
	WIN		*dd_win;
} DRAG_DROP;
#endif

#ifndef SMALL_NO_EDIT

typedef struct
{
	char	*text,*masc,*valid;
	int		text_x,text_y,text_w,text_h;
	int		edit_x,edit_y,edit_w,edit_h;
	int		crs_x,crs_y,cw,ch;
} EDINFO;

#define MAX_EDIT	128

#endif

#define MAX_WINDOWS	16
#define MAX_DIALS	16

#define MAX_PATH	256

typedef struct
{
	OBJECT 	*tree;
	void	*mem;
	int		buttons,valid;
} ALERT;

typedef struct
{
	int		valid;
    GRECT	area;
    MFDB	mfdb;
    void	*mem;
} RC_RECT;

typedef struct __dialog
{
	DIALMODE	di_flag;
	OBJECT		*di_tree;
	RC_RECT		di_rc;
	int			di_fly,di_drawn,di_mode;
#ifndef SMALL_NO_EDIT
	int			di_ed_obj,di_ed_index,di_cursor,di_insert,di_inddef,di_ed_cnt;
	char		di_undobuff[MAX_EDIT];
	GRECT		di_crsrect;
#endif
	int			di_default,di_help,di_undo,di_esc,di_taken,di_xy_off,di_wh_off;
	char		*di_title;
#ifndef SMALL_NO_GRAF
	void		*di_slider;
#endif
#ifndef SMALL_NO_POPUP
	void		*di_popup;
#endif
	WIN			*di_win;
	int 		(*di_mouse)(struct __dialog *,OBJECT *,int,int,int,int,GRECT *);
	int			di_last_obj,di_last_mode;
	ALERT		*di_alert;
	void		*di_mem;
} DIAINFO;

#ifndef SMALL_NO_POPUP

#define POPUP_EXIT	-1
#define POPUP_CONT	0

typedef struct __popup
{
	DIAINFO		*p_info;
	OBJECT		*p_menu;
	int			p_parent;
	int 		p_button;
	int			p_cycle;
	boolean		p_wrap,p_set;
	int			(*p_func)(struct __popup *,int,int);
} POPUP;

typedef struct
{
	POPUP		popup;
	int			id,mode,cycle_mode,center,x,y,index,current,opened;
} XPOPUP;

#else

#define XPOPUP	void

#endif

#ifndef SMALL_NO_GRAF

typedef struct
{
	int scan,state,cmd;
} SLKEY;

typedef struct __slinfo
{
	DIAINFO		*sl_info;
	int			sl_view,sl_line;
	int			sl_parent;
	int			sl_slider,sl_min_size;
	int			sl_dec,sl_inc,sl_pos,sl_page,sl_max,sl_cursor;
	char		sl_vh,sl_mode;
	int			sl_delay,sl_speed;
	void		(*sl_do)(struct __slinfo *,OBJECT *,int,int,int,int,int);
	SLKEY		*sl_keys;
	int			sl_keys_cnt;
} SLINFO;

#define SL_UP		-1
#define SL_DOWN		-2
#define SL_PG_UP	-3
#define SL_PG_DN	-4
#define SL_START	-5
#define SL_END		-6
#define SL_CRS_UP	-7
#define SL_CRS_DN	-8
#define SL_SET		-9

#else

#define SLINFO	void

#endif

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

extern	int	ap_id,menu_id,grhandle,x_handle,has_3d,bottom,bevent,owner;
extern	int	gr_cw,gr_ch,gr_bw,gr_bh,gr_sw,gr_sh;
extern	int	max_w,max_h,planes,colors,colors_available;
extern	int multi,aes_version,winx,magx,mtos,mint;
extern  int small_font,small_font_id,ibm_font,ibm_font_id,fonts_loaded,speedo;
extern	int search,work_out[],ext_work_out[];
extern  unsigned int gemdos_version;

#ifndef SMALL_NO_MENU
extern	int menu_available;
#endif

#ifndef SMALL_NO_FSEL
extern  DIAINFO *FSelDialog;
#endif

#ifndef SMALL_NO_XACC_AV
extern int AvServer;
#endif

extern	GRECT	desk;
extern	VRECT	clip;
extern	MFDB	*screen;
#ifndef SMALL_NO_ICONIFY
extern	OBJECT	*iconified;
#endif

void	ob_dostate(OBJECT*,int,int);
void	ob_undostate(OBJECT*,int,int);
int		ob_isstate(OBJECT*,int,int);

#define ob_setstate(t,o,s)	t[o].ob_state = s

int		ob_disable(DIAINFO *,OBJECT *,int,int,int);
int		ob_select(DIAINFO *,OBJECT *,int,int,int);

void	ob_doflag(OBJECT*,int,int);
void	ob_undoflag(OBJECT*,int,int);
int		ob_isflag(OBJECT*,int,int);
void	ob_hide(OBJECT*,int,int);

#define ob_setflags(t,o,f)	t[o].ob_flags = f

void	ob_xywh(OBJECT*,int,GRECT*);
void	ob_pos(OBJECT*,int,GRECT*);

char	*ob_get_text(OBJECT*,int,int);
void	ob_set_text(OBJECT*,int,char*);
void	ob_clear_edit(OBJECT *);
#ifndef SMALL_NO_EDIT
void	ob_edit_init(DIAINFO *,int);
void	ob_edit_handler(boolean (*foo)(char,char,char *));
int		ob_set_cursor(DIAINFO *,int,int,int);
#endif

OBJECT	*ob_copy_tree(OBJECT *);

int		ob_set_hotkey(OBJECT*,int,char);
char	ob_get_hotkey(OBJECT*,int);

int		ob_draw(DIAINFO*,int);
int		ob_draw_chg(DIAINFO*,int,GRECT*,int);
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

#ifndef SMALL_NO_CLIPBRD

void	scrp_clear(int);
long	scrp_length(void);
int		scrp_find(char*,char*);
int		scrp_path(char*,char*);

#ifndef SMALL_NO_XACC_AV

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

#endif
#endif

#ifndef SMALL_NO_MENU
int		menu_install(OBJECT*,int);
void	menu_enable(boolean);
void	menu_item_enable(int,int);
void	menu_select(int,int);
boolean menu_dropped(void);
#endif

#define HOR_SLIDER			0
#define	VERT_SLIDER			1

typedef struct
{
	int mx,my,mbut,kstate;
} MKSTATE;

void 	graf_busy_mouse(void);
int		graf_rt_rubberbox(int,int,int,int,int,GRECT*,int*,int*,void(*foo)(boolean,int*,MKSTATE *));
int		graf_rt_dragbox(int,GRECT *,GRECT*,int*,int*,void (*foo)(boolean,int*,MKSTATE *));
int		graf_rt_dragobjects(int,int *,GRECT *,void (*foo)(boolean,int *,MKSTATE *));
void	graf_rt_lines(int *,boolean);

#ifndef SMALL_NO_GRAF

void	graf_set_slider(SLINFO*,OBJECT*,int);

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
void	graf_rt_slidebox(SLINFO*,int,int,int,int);
void	graf_rt_slidecursor(SLINFO *,int);

#endif

int		Event_Multi(XEVENT*);
void	Event_Timer(int,int,int);
void	Event_Handler(int (*init)(XEVENT *,int),int (*handler)(XEVENT *));
void	ClrKeybd(void);
void 	NoClick(void);

#define DOUBLE_CLICK	0x8000
#define RIGHT_CLICK		0x4000
#define NO_CLICK		(~(DOUBLE_CLICK|RIGHT_CLICK))

int		X_Form_Do(DIAINFO**);
int		FormObject(int);
int 	XFormObject(DIAINFO **,int *);

int		appl_xgetinfo(int,int *,int *,int *,int *);
int		appl_getfontinfo(int,int *,int *,int *);

#ifdef  __PUREC__
int		wind_xget(int, int, int *, int *, int *,int *);
#else
#define	wind_xget(hdl,field,p1,p2,p3,p4)	wind_get(hdl,field,p1,p2,p3,p4)
#endif

boolean	init_gem(char*,char*,char*,char*,int,int,int);
#ifdef SMALL_NO_XACC_AV
#define	init_gem(a,b,c,d,e,f,g)	init_gem(a,b,NULL,NULL,e,f,g)
#endif
void	exit_gem(boolean,int);

boolean open_work(int*,int*);
void 	close_work(int);
boolean open_device(int,int*,int*);
void 	close_device(int);
boolean	driver_available(int);

boolean	open_rsc(char*,char*,char*,char*,char*,int,int,int);
#ifdef SMALL_NO_XACC_AV
#define	open_rsc(a,b,c,d,e,f,g,h)	open_rsc(a,b,c,NULL,NULL,f,g,h)
#endif
void	close_rsc(boolean,int);

void	rsrc_calc(OBJECT*,int,int,int);
void	rsrc_init(int,int,int,int,int,char**,long*,BITBLK*,long*,ICONBLK*,TEDINFO*,OBJECT*,OBJECT**,RS_IMDOPE*,int,int);

void	fix_objects(OBJECT*,int,int,int);
void	scale_image(OBJECT*,int,int,int);
void	trans_image(OBJECT*);

void	vsf_aespattern(int,int,int,int);

void	vs_attr(void);
void	v_set_text(int,int,int,int,int,int*);
int		v_set_point(int,int);
int		v_set_font(int);
void	v_set_mode(int);
void	v_set_line(int,int,int,int,int);
void	v_set_fill(int,int,int,int);
void	v_aespattern(int,int,int);

void 	v_rect(int,int,int,int);
void	v_line(int,int,int,int);

void	save_clipping(int *);
void	restore_clipping(int *);

#define	DIA_MOUSEPOS	TRUE
#define DIA_CENTERED	FALSE
#define DIA_LASTPOS		FAIL

DIAINFO *open_dialog(OBJECT*,char*,char*,OBJECT*,boolean,boolean,int,int,SLINFO **,XPOPUP**);
int		close_dialog(DIAINFO*,boolean);
void 	close_all_dialogs(void);

#define DIALOG_OBJECT	0
#define DIALOG_MOUSE	1
#define DIALOG_MOVEMENT	2

void	dialog_mouse(DIAINFO *,int (*foo)(DIAINFO *,OBJECT *,int,int,int,int,GRECT *));

WIN 	*open_window(char *,char *,char *,OBJECT *,int,int,int,int,GRECT*,GRECT*,SCROLL*,void (*foo)(int,WIN *,GRECT *),void *,int);
void	window_reinit(WIN *,char *,char *,char *,int,int);
void	window_top(WIN *);
void	window_bottom(WIN *);
void	window_size(WIN *,GRECT *);
void	window_slider(WIN *,int,int,int);
void	window_name(WIN *,char *,char *);
void	window_set_mouse(WIN *,int,int,int,int,MFORM *,MFORM *,MFORM *,MFORM *);
void	window_info(WIN *,char *);
void	window_border(int,int,int,int,int,GRECT *);
int		window_work(WIN *,GRECT *);
void	window_calc(int,int,GRECT *,GRECT *);
void	windial_calc(int,DIAINFO *,GRECT *);
WIN		*window_find(int,int);
void	redraw_window(WIN *,GRECT *);

#define MOUSE_OFF	FAIL
#define MOUSE_ON	FALSE
#define MOUSE_TEST	TRUE

#define RC_FIRST	1
#define RC_SCROLL	2

void	draw_window(WIN *,GRECT *,void *,int,void (*foo)(int,WIN*,GRECT*,GRECT *,void*));
#ifndef SMALL_NO_SCROLL
void	scroll_window(WIN *,int,GRECT*);
#endif
int		close_window(WIN *,int);
void	close_all_windows(void);

WIN		*get_window(int);
WIN		*get_window_list(int);
WIN		*get_top_window(void);

int		GetTop(void);

int		window_first(WIN *,GRECT *);
int		window_next(WIN *,GRECT *);

#define W_CLOSE				100
#define W_CLOSEALL			101
#define W_CYCLE				102
#define W_INVCYCLE			103
#define W_GLOBALCYCLE		104
#define W_FULL				105
#define W_BOTTOM			106
#define W_ICONIFY			107
#define W_ICONIFYALL		108
#define W_UNICONIFY			109
#define W_UNICONIFYALL		110
#define W_ICONIFYALLINONE	111

int		WindowHandler(int,WIN *,GRECT *);
void	MenuItems(MITEM *,MITEM *,MITEM *,MITEM *,MITEM *,MITEM *,MITEM *,MITEM *,MITEM *,MITEM *,int);
void	WindowItems(WIN*,int,MITEM *);

int		get_dialog_info(int *,int *,int *,DIAINFO **);
int		window_output(void);

int		xdialog(OBJECT*,char*,char*,OBJECT*,boolean,boolean,int);

ALERT	*MakeAlert(int,int,int,BITBLK *,int,int,int,char *,char *,char *);
int		ExitAlert(ALERT *,int);
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
#ifdef SMALL_ALERT
#define X_ICN_MAX		8
#else
#define X_ICN_MAX		17
#endif

#define	X_ICN_ALERT		0
#define	X_ICN_QUESTION	1
#define	X_ICN_STOP		2
#define	X_ICN_INFO		3
#define	X_ICN_ERROR		4
#define	X_ICN_DISC		5
#define	X_ICN_FLOPPY	6
#define	X_ICN_DISC_ERR	7
#define	X_ICN_PRT_ERR	8

#ifndef SMALL_NO_POPUP
#define POPUP_MOUSE		1
#define	POPUP_EXITENTRY	2
#define POPUP_DCLICK	4
#define POPUP_RCLICK	8

int		Popup(POPUP*,int,int,int,int,int *,int);
#endif

int 	beg_ctrl(int,int,int);
void 	end_ctrl(int,int);
int		beg_update(int,int);
void	end_update(int);

void	dial_colors(int,int,int,int,int,int,int,int,int,int,int,int,int,int,int);

#define KEY_FIRST	FAIL
#define KEY_STD		FALSE
#define KEY_ALWAYS	TRUE

#define RETURN_DEFAULT		TRUE
#define RETURN_NEXT_EDIT	FALSE
#define RETURN_LAST_DEFAULT	FAIL

#define AES_BACK	FAIL
#define NO_BACK		FALSE
#define ALWAYS_BACK	TRUE

void	dial_options(boolean,boolean,boolean,boolean,boolean,boolean,boolean,boolean,boolean,int);
void	header_options(boolean,boolean,boolean,boolean,boolean,int,int,int,int);
void	title_options(boolean,int,int);

void	radio_image(int,BUTTON*);
void	check_image(int,BUTTON*);
void	arrow_image(int,BUTTON*,BUTTON*,BUTTON*,BUTTON*);
void	cycle_image(int,BUTTON*,char);

void	create_cookie(COOKIE*,long,long);
boolean	new_cookie(COOKIE*);
boolean	get_cookie(long,long*);
void	remove_cookie(long);
void	move_cookiejar(long*,long);
long	cookie_size(void);

/* Font-Funktionen */

#ifndef SMALL_NO_FONT

typedef struct
{
	char	name[34];
	int		valid,id,index,type,min_size,max_size,min_ascii,max_ascii;
} FONTINFO;

#define FNT_PROP		1
#define FNT_VECTOR		2
#define FNT_SYSTEM		4
#define FNT_ASCII		8
#define FNT_TRUETYPE	16
#define FNT_SPEEDO		32
#define FNT_TYPE1		64
#define FNT_CFN			128

#define FS_FNT_ALL		127
#define FS_FNT_BITMAP	1
#define FS_FNT_VECTOR	2
#define FS_FNT_PROP		4
#define FS_FNT_MONO		8

#ifndef SMALL_NO_FSEL

#ifndef SMALL_NO_DD_FSEL
#define FSEL_DRAG		0
#endif

#define FSEL_DIAL		1
#define	FSEL_WIN		2

#define FS_RES_ERROR	-105
#define FS_NO_WINDOW	-104
#define FS_NO_FONTS		-103
#define FS_ACTIVE		-102
#define FS_SET			-101
#define FS_ERROR		-100
#define FS_ABANDON		FAIL
#define FS_CANCEL		FALSE
#define FS_OK			TRUE

#define FS_GADGETS_STANDARD	0
#define FS_GADGETS_EFFECT	1
#define FS_GADGETS_COLOR	2
#define FS_GADGETS_SKEW		4
#define FS_GADGETS_SPEEDO	8
#define FS_GADGETS_INVERS	16
#define FS_GADGETS_ALL		127

#define FS_ACT_NONE			0
#define FS_ACT_ICON			1
#define FS_ACT_BACK			2
#define FS_ACT_CLOSE		3

typedef struct
{
	char	*win_title,*title,*example;
	TEDINFO	*info;
	int		info_type,info_state;
	char	gadgets,fsel_type;
	int		min_pts_size,max_pts_size;
	struct
	{
		unsigned app_only : 1;
		unsigned buttons  : 1;
	} drag;
	struct
	{
	    unsigned         : 7;
	    unsigned redraw  : 1;
		signed center    : 3;
		unsigned boxes   : 1;
		unsigned preview : 1;
		unsigned sort    : 1;
		unsigned action  : 2;
	} options;
	int		(*font_test)(FONTINFO*,int);
	void cdecl (*help_func)(void);
	int		id,size,effect,color,skew,x,y;
	FONTINFO *fnt;
	int		app,win;
} FONTSEL;

boolean	FontSelect(int,FONTSEL *);
boolean UpdateFsel(boolean,boolean);

#endif

FONTINFO *FontInfo(int);
FONTINFO *FastFontInfo(int);

int		FontList(int,int,int,int,FONTINFO **,int(*foo)(FONTINFO*,int));
int		FontSizes(int,int,int,int,int,int*,int(*foo)(FONTINFO*,int));

#endif

#ifndef SMALL_NO_XACC_AV

int		FontChanged(int,int,int,int,int,int);
int		CallFontSelector(int,int,int,int,int);
int		FontAck(int,boolean);

#ifndef SH_WDRAW
#define SH_WDRAW	72
#endif

void	drive_changed(int);

#endif

int		FileSelect(char *,char *,char *,char *,int,int,char **);
char	*GetFilename(char *);
char	*GetExtension(char *);
char	*GetPath(char *);
int		GetDrive(char *);
char	*MakeFullpath(char *,char *, char *);
int		LoadInfoFile(char *,boolean,void *,int,int,char *,int);
boolean SaveInfoFile(char *,boolean,void *,int,char *,int);

#ifdef __PUREC__
char	*getenv(const char*);	/* Funktionen gibt es in stdlib.h */
int		putenv(const char*);
#endif	/* __PUREC__ */

int		scan_2_ascii(int,int);
char	UpperChar(char);
char	LowerChar(char);
char	*strlcpy(char *,char *);
char	*strend(char *);
char	*strwild(char *,char *);

#ifndef SMALL_EDIT
OBJECT	*MakeAscii(void);
char	ExitAscii(OBJECT *,int);
char	ascii_box(DIAINFO *,char *);
#endif

int		int2str(char *,int,int);
int		mm2dpi(int);

int		min(int,int);
int		max(int,int);
void	Min(int*,int);
void	Max(int*,int);

void	mfdb(MFDB*,int*,int,int,int,int);
long	mfdb_size(MFDB*);

#define CONT_TIMER	-1
#define	STOP_TIMER	-2

long 	NewTimer(long,long,long (*foo)(long,long,MKSTATE *));
int		KillTimer(long);

/* Drag & Drop */

#ifndef SMALL_NO_DD
char	*ParseArgs(char*);
int		SendDragDrop(int,int,int,char*,char*,long,char *);
void	SetDragDrop(int,char*);
#endif

/* XAcc-2- und AV-Protokoll */

#ifndef SMALL_NO_XACC_AV

#define XACC		1

#define MSGGROUP1	0x01
#define MSGGROUP2	0x02

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
#define MSG_AVSTARTED		0x004
#define MSG_AVFONTCHANGED	0x008
#define MSG_AVQUOTE			0x010

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
#define MSG_XWIND			0x800
#define MSG_VAFONTCHANGED	0x1000
#define MSG_VASTARTED		0x2000
#define MSG_VAQUOTE			0x4000

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
#define AV_STARTED          0x4738
#define AV_XWIND			0x4740

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
#define VA_FONTCHANGED		0x4739
#define VA_XOPEN			0x4741

#define	VA_OB_UNKNOWN		0
#define VA_OB_TRASHCAN  	1
#define VA_OB_SHREDDER  	2
#define VA_OB_CLIPBOARD 	3
#define VA_OB_FILE      	4
#define VA_OB_FOLDER		5
#define VA_OB_DRIVE			6
#define VA_OB_WINDOW    	7
#endif

#define MAX_XACCS	16

typedef struct
{
	int		flag,id,version,menu_id,av_msgs,va_msgs;
	char	name[10],*xname,*xdsc;
} XAcc;

XAcc		*find_xacc_xdsc(int,char*);
XAcc		*find_id(int);
XAcc		*find_app(int);

void		XAccBroadCast(int *);
int			XAccSendAck(int,int);
int			XAccSendKey(int,int,int);
int			XAccSendText(int,char *);
int			XAccSendMeta(int,int,char*,long);
int			XAccSendImg(int,int,char*,long);

int			VaStart(int,char *);

#endif

int			AvSendMsg(int,int,int*);
void 		*GetMsgBuffer(long);
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
#define VIEW_GETMFDB	0x5610

#define VIEWERR_ERROR	0
#define VIEWERR_SIZE	1
#define VIEWERR_COLOR	2
#define VIEWERR_WID		3
#define VIEWERR_MEM		4
#endif

/* PAULA-Protokoll */

int PaulaStop(void);
int PaulaShutDown(void);
int PaulaStart(char *);

#define MP_ACK			0x4800
#define MP_NAK			0x4801
#define MP_START		0x4802
#define MP_STOP			0x4803
#define MP_SHUTDOWN		0x4804

/* wichtige Scan-Codes */

#define key(s,a)	((s<<8)|(unsigned char) a)

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

#define K_SHIFT		(K_RSHIFT|K_LSHIFT)

/* Makros fÅr Mauszeiger */

#ifdef __MINT_LIB__#define BUSYBEE		BUSY_BEE#endif

#define MouseArrow()		MouseForm(ARROW,NULL)
#define MouseCursor()		MouseForm(TEXT_CRSR,NULL)
#define MouseBee()			MouseForm(BUSYBEE,NULL)
#define MouseHourGlass()	MouseForm(HOURGLASS,NULL)
#define MousePointHand()	MouseForm(POINT_HAND,NULL)
#define MouseFlatHand()		MouseForm(FLAT_HAND,NULL)
#define MouseThinCross()	MouseForm(THIN_CROSS,NULL)
#define MouseThickCross()	MouseForm(THICK_CROSS,NULL)
#define MouseOutlineCross()	MouseForm(OUTLN_CROSS,NULL)

int	mouse(int *,int *);
int MouseForm(int,MFORM *);
void MouseOn(void);
void MouseOff(void);
void MouseUpdate(int);

#endif	/* __E_GEM_LIB__ */
