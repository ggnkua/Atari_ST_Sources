#ifndef __E_GEM_LIB__
#define __E_GEM_LIB__

#if defined(__EPX__) && !defined(__SPACE__)
#define __NoEGEM__
#else
#undef __NoEGEM__
#endif

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
#define SMALL_NO_MOUSE
#define SMALL_NO_TERMINAL
#define SMALL_NO_LISTBOX
#define SMALL_NO_HANDLER
#define SMALL_NO_OEP
#endif

#if (defined(SMALL_NO_GRAF) || defined(SMALL_NO_POPUP) || defined(SMALL_NO_FONT)) && !defined(SMALL_NO_FSEL)
#define SMALL_NO_FSEL
#endif

#if defined(SMALL_NO_FSEL) && !defined(SMALL_NO_DD_FSEL)
#define SMALL_NO_DD_FSEL
#endif

#if defined(SMALL_NO_GRAF) && !defined(SMALL_NO_LISTBOX)
#define SMALL_NO_LISTBOX
#endif

#if defined(SMALL_NO_EDIT) && !defined(SMALL_EDIT)
#define SMALL_EDIT
#endif

#if defined(SMALL_EDIT) && !defined(SMALL_NO_HZ)
#define SMALL_NO_HZ
#endif

#if defined(SMALL_NO_SCROLL) && !defined(SMALL_NO_TERMINAL)
#define SMALL_NO_TERMINAL
#endif

#if defined(SMALL_NO_DD) && !defined(SMALL_NO_OEP)
#define SMALL_NO_OEP
#endif

#ifdef SMALL_NO_HANDLER
#ifndef SMALL_NO_ICONIFY
#define SMALL_NO_ICONIFY
#endif
#ifndef SMALL_NO_MENU
#define SMALL_NO_MENU
#endif
#endif

#define E_GEM			"EnhancedGEM"
#define E_GEM_VERSION	"2.25"
#define E_GEM_DATE		"Mar 10 1995"

#define XACCVERSION		0x22

#if defined(__SOZOBONX__) && defined(__CREATE_E_GEM_LIB_OR_EXAMPLE__)
#define int short
#endif

#ifdef __GNUC__
/* Anpassung der Enhanced GEM-Library an GNU CC + MiNT-Lib */

#ifndef __MINT_LIB__
#define __MINT_LIB__	/* MiNT-Lib wird beim GCC verwendet! */
#endif	/* !__MINT_LIB__ */

#ifdef __CREATE_E_GEM_LIB__
#define __TCC_COMPAT__
#endif	/* __CREATE_E_GEM_LIB__ */

#define reg			/* Keine register Variablen */
#define cdecl		/* Kein `cdecl' unter GCC */

extern short _global[];

#define AES_VERSION	gl_ap_version	/* EnhÑlt unter GCC die AES-Version */
#define CONTRL		_contrl
#define INTIN		_intin
#define INTOUT		_intout
#define PTSIN		_ptsin
#define	PTSOUT		_ptsout
#define _GLOBAL		_global
#define GINTIN		INTIN
#define GINTOUT		INTOUT
#define ADDRIN		((void **)(&_ptsin[0]))
#define ADDROUT		((void **)(&_ptsout[0]))

#define BASPAG		BASEPAGE
#include <basepage.h>

#define vq_gdos()	(vq_vgdos()!=-2)
 
int __aes__(unsigned long);			/* Def. aus der GemLib. */
#define _aes(a, b) __aes__(b)
void __vdi__(unsigned long,int);

extern short _app;

#endif	/* __GNUC__ */


#ifdef LATTICE
/* Anpassung der Enhanced GEM-Library an Lattice C + MiNT-Lib */

#ifndef __MINT_LIB__
#define __MINT_LIB__		/* MiNT-Lib wird bei Lattice verwendet! */
#endif	/* !__MINT_LIB__ */

#ifdef __CREATE_E_GEM_LIB__
#define __TCC_COMPAT__
#endif	/* __CREATE_E_GEM_LIB__ */

#define __TCC_GEMLIB__
#define __OLD_WAY__

#define reg					/* Keine register Variablen */
#define cdecl	__stdargs	/* `__stdargs' entspricht `cdecl' in Lattice C */

extern short _AESglobal[],_AES_intin[],_AESintout[];
extern void *_AESaddrin[],*_AESaddrout[];
extern short _VDI_ptsin[],_VDIptsout[],_VDI_intin[],_VDIintout[],_VDIcontrl[];

#define AES_VERSION	_AESglobal[0]	/* EnhÑlt unter Lattice C die AES-Version */
#define _GLOBAL		_AESglobal
#define GINTIN		_AES_intin
#define GINTOUT		_AESintout
#define ADDRIN		_AESaddrin
#define ADDROUT		_AESaddrout
#define PTSIN		_VDI_ptsin
#define PTSOUT		_VDIptsout
#define INTIN		_VDI_intin
#define INTOUT		_VDIintout
#define CONTRL		_VDIcontrl

int __regargs _AESif(unsigned long);
#define _aes(a,b)	_AESif(b)
#define	vdi(pb)		vdi((void *) pb)

extern short _app;

#endif	/* LATTICE */


#ifdef __PUREC__
/* Anpassung an Pure C */

#if __PUREC__<0x0250
#error "Use Pure C >= v1.1!"
#endif

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

typedef struct
{
	int		contrl[15];
	int		intin[132];
	int		intout[140];
	int		ptsin[145];
	int		ptsout[145];
}VDIPARBLK;

typedef struct
{
	int	*contrl;
	int	*intin;
	int	*ptsin;
	int	*intout;
	int	*ptsout;
} VDIPB;

extern VDIPARBLK _VDIParBlk;
extern GEMPARBLK _GemParBlk;

#else

#include <tos.h>
#include <aes.h>
#include <vdi.h>

#endif	/* __MINT_LIB__ */

#define AES_VERSION		_GemParBlk.global[0]
#define _GLOBAL			_GemParBlk.global
#define GINTIN			_GemParBlk.intin
#define GINTOUT			_GemParBlk.intout
#define ADDRIN			_GemParBlk.addrin
#define ADDROUT			_GemParBlk.addrout
#define INTIN			_VDIParBlk.intin
#define INTOUT			_VDIParBlk.intout
#define PTSIN			_VDIParBlk.ptsin
#define PTSOUT			_VDIParBlk.ptsout
#define CONTRL			_VDIParBlk.contrl

extern int _app;

extern void _aes(int dummy,long);
extern void vdi(VDIPB *vdipb);

#define vdi(pb)	vdi((VDIPB *) pb)

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

#if defined(__GNUC__) && defined(__CREATE_E_GEM_LIB__)
#define evnt_timer(a,b) evnt_timer(((unsigned long)b << 16) + (unsigned short)a)
#endif	/* (__GNUC__ && __CREATE_E_GEM_LIB__) */

#else	/* __MINT_LIB__ */

#ifdef __SOZOBONX__

#if __SOZOBONX__ < 0x232
#error "Use hcc v2.00x32 or newer!"
#endif

#include <atari.h>

#ifdef _XDLIBS
#if _XDLIBS < 0x111
#error "Use xdlibs v1.11 or newer!"
#endif

#define reg register
#define BASPAG BASEPAGE

#ifdef __CREATE_E_GEM_LIB_OR_EXAMPLE__

void *_lcalloc(long n, long size);
/* Diese beiden Zeilen kînnen raus, wenn das lmemset aus den xdlibs
   funktioniert! */
char *_lmemset(char *s,char val,long len);
#define lmemset _lmemset

#define calloc(n,s) _lcalloc((long)(n),(long)(s))
#define malloc(l) lalloc((long)(l))

#undef Mshrink
#define Mshrink(zero,ptr,size) (short) gemdos(0x4A,(short)(0),(long)(ptr),(long)(size))

#include <string.h>

/* Prototypen fÅr lmemmove()/lmemset() fehlen in string.h bzw. support.h! */
extern char *lmemmove(char *dst, char *src, long len);

#define memcpy(d,s,l) lmemmove((char *)(d),(char *)(s),(long)(l))
#define memmove(d,s,l) lmemmove((char *)(d),(char *)(s),(long)(l))
#define memset(d,c,l) lmemset((char *)(d),(char)(c),(long)(l))
#endif /* __CREATE_E_GEM_LIB_OR_EXAMPLE__ */

#endif /* _XDLIBS */

#ifdef __CREATE_E_GEM_LIB_OR_EXAMPLE__
#define obspec index
#endif /* __CREATE_E_GEM_LIB_OR_EXAMPLE__ */
#include <xgemfast.h>

#ifdef _XAESFAST_A
#if _XAESFAST_A < 0x104
#error "Use xaesfast v1.04 or newer!"
#endif

#define __OLD_WAY__

extern short    int_in[],int_out[],pts_in[],pts_out[],vdi_contrl[];
extern void     *addr_in[],*addr_out[];

#define AES_VERSION gl_apversion
#define _GLOBAL      global
#define GINTIN      int_in
#define GINTOUT     int_out
#define ADDRIN      addr_in
#define ADDROUT     addr_out
#define INTIN       int_in
#define INTOUT      int_out
#define PTSIN       pts_in
#define PTSOUT      pts_out
#define CONTRL      vdi_contrl

#define _aes(a, b)  call_aes(b)
#define vdi(pb)     c_vdi(pb)

#ifdef __CREATE_E_GEM_LIB_OR_EXAMPLE__
#undef obspec
#define obspec bfobspec
#define interiorcol innercol
#define fillpattern fillpat
#endif /* __CREATE_E_GEM_LIB_OR_EXAMPLE__ */
#endif  /* _XAESFAST_A */
#endif  /* __SOZOBONX__ */
#endif	/* !__MINT_LIB__ */

void _call_vdi(int opcode,int nptsin,int nintin,int sopcode,int handle);

#undef CH_EXIT
#define CH_EXIT				90

#ifndef WF_BEVENT /* MTOS-1.01-Erweiterungen definiert ? */

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

#ifndef WF_ICONIFY /* MTOS-1.08-Erweiterungen definiert ? */

#define WF_ICONIFY			26
#define WF_UNICONIFY		27
#define WF_UNICONIFYXYWH	28

#define WM_ICONIFY			34
#define WM_UNICONIFY		35
#define WM_ALLICONIFY		36

#endif	/* WF_ICONIFY */

#undef SMALLER
#define SMALLER				0x4000

#ifndef LK3DIND /* objc_sysvar-Konstanten definiert? */

#define	LK3DIND		1
#define LK3DACT		2
#define INDBUTCOL	3
#define ACTBUTCOL	4
#define BACKGRCOL	5
#define AD3DVALUE	6

#define OB_GETVAR	0
#define OB_SETVAR	1

#endif

#ifndef AP_DRAGDROP
#define AP_DRAGDROP			63
#endif

int appl_search(int ap_smode, char *ap_sname, int *ap_stype, int *ap_sid);
int appl_getinfo(int ap_gtype, int *ap_gout1, int *ap_gout2, int *ap_gout3, int *ap_gout4);

#ifndef SMALL_NO_DD

#define NO_DD			-100
#define NO_PIPE			-101
#define NO_RECEIVER		-102

#endif

#ifndef DD_OK	/* Drag&Drop-Erweiterungen definiert? */

#define	DD_OK			0
#define DD_NAK			1
#define DD_EXT			2
#define DD_LEN			3
#define DD_TRASH		4
#define DD_PRINTER		5
#define DD_CLIPBOARD	6

#define DD_TIMEOUT		3000			/* timeout in milliseconds */

#define DD_NUMEXTS		8
#define DD_EXTSIZE		32
#define DD_NAMEMAX		128				/* max size of a drag&drop item name */

#define DD_HDRMAX		(8+DD_NAMEMAX*2)/* max length of a drag&drop header */

#endif

#if defined(__MINT_LIB__) || defined(_XAESFAST_A)

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

int EvntMulti(EVENT *evnt_struct);

#endif	/* __MINT_LIB__ || _XAESFAST_A */

#ifndef GDOS_PROP

#define GDOS_PROP		0			/* Speedo GDOS font */
#define GDOS_MONO		1			/* Speedo GDOS font, force monospace output */
#define GDOS_BITM		2			/* GDOS bit map font */

#define te_fontid		te_junk1	/* GDOS font id */
#define te_fontsize 	te_junk2	/* GDOS font size in points */

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
#define MU_KEY_FIRST	0x8000

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

#ifndef WM_M_BDROPPED	/* MagiC-Erweiterungen definiert? */
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
#define COOKIE_FREEDOM		0x3F46646DL		/* '?Fdm' */
#define MAGIC_FREEDOM		0x2146646DL		/* '!Fdm' */
#define COOKIE_VIEW			0x56696577L		/* 'View' */
#define COOKIE_WINCOM		0x5749434FL		/* 'WICO' */
#define COOKIE_AMAN			0x416D414EL		/* 'AmAN' */
#define COOKIE_AFNT			0x41466E74L		/* 'AFnt' */
#define COOKIE_SMALL		0x534D414CL		/* 'SMAL' */

#define ICF_GETSIZE		0x0000
#define ICF_GETPOS		0x0001
#define ICF_FREEPOS		0x0002
#define ICF_SNAP		0x0003
#define ICF_FREEALL		0x0100
#define ICF_INFO		0x0200
#define ICF_CONFIG		0x0201
#define ICF_SETSIZE		0x0202
#define ICF_SETSPACE	0x0203

#define FILE_SELECTED	0x4560

#ifndef SMALL_NO_EDIT
#define OBJC_EDITED		0x7a00
#endif

#define OBJC_SELECTED	0x7a01
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
#define POPUP_CLOSE		0x7a08
#endif

#ifndef SMALL_NO_GRAF
#define SLIDER_CHANGED	0x7a09
#endif

#ifndef SMALL_NO_LISTBOX
#define LISTBOX_CHANGED	0x7a0a
#endif

#ifndef SMALL_NO_DD_FSEL
#define FSEL_DD_INIT	0x7a0b
#endif

#ifndef SMALL_NO_XACC_AV
#define XACC_AV_INIT	0x7a10
#define XACC_AV_EXIT	0x7a11
#define XACC_AV_CLOSE	0x7a12
#endif

#define CPX_RES1		0x7a13
#define CPX_RES2		0x7a14
#define CPX_RES3		0x7a15
#define CPX_RES4		0x7a16
#define CPX_RES5		0x7a17

#define WIN_CHANGEFNT	30961

#define	FONT_CHANGED	0x7a18
#define	FONT_SELECT		0x7a19
#define FONT_ACK		0x7a1a
#define XFONT_CHANGED	0x7a1b

typedef struct
{
	unsigned int pair  : 1;
	unsigned int track : 2;
	unsigned int width : 13;
} VECTOR_INFO;

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

#define FLY_DIAL		0x0001l
#define WIN_DIAL		0x0002l
#define AUTO_DIAL		(FLY_DIAL|WIN_DIAL)
#define MODAL			0x0004l
#define FRAME			0x0008l
#define NO_ICONIFY		0x0010l
#define SMALL_FRAME		0x0020l
#define SMART_FRAME		(FRAME|SMALL_FRAME)
#define DDD_DIAL		0x0040l

#define	WD_HSLIDER		0x0080l
#define	WD_VSLIDER		0x0100l
#define WD_SIZER		0x0200l
#define WD_CLOSER		0x0400l
#define WD_FULLER		0x0800l
#define WD_INFO			0x1000l
#define WD_SET_SIZE		0x2000l
#define WD_TREE_SIZE	0x4000l
#define SHADOW_DIAL		0x8000l
#define	CLOSE_BACK		0x00010000l
#define	CLOSE_ESC		0x00020000l
#define	CLOSE_UNDO		0x00040000l
#define NO_FRAME		0x00080000l

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
#define MITEM_ENABLE	0x17

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

#ifdef __SOZOBONX__
#define G_TYPE			(int)(~(G_MODAL|G_UNMODAL))
#else
#define G_TYPE			(~(G_MODAL|G_UNMODAL))
#endif

#define NO_SCALING		0
#define SCALING			1
#define TEST_SCALING	2
#define DARK_SCALING	4
#define STATIC_SCALING	8
#define NO_XOBJECTS		16

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
	int 	font_id,font_size,color,effect;
	char	center,mode;
} X_TEXT;

#if defined(__PUREC__) || defined(_XAESFAST_A)
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

#ifdef _XDLIBS
#undef FALSE
#undef TRUE
#endif

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

#define VISIBLE		0
#define SHADE		1
#define ICONIFIED	2
#define ICFS		4
#define SHUTDOWN	8
#define NOT_VISIBLE	16
#define	IN_VISIBLE	127

typedef struct
{
	int	menu,scan,state,mode,msg;
} MITEM;

#ifndef SMALL_NO_MOUSE
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
#endif

typedef struct __win_info
{
	int		handle,gadgets,vdi_handle;
#ifndef SMALL_NO_MOUSE
	GRECT	mrect;
	int		mflag;
#ifndef SMALL_NO_ICONIFY
	MFORM	*mouse_inform,*mouse_outform,*mouse_workform,*mouse_iconform;
	int		mouse_in,mouse_work,mouse_out,mouse_icon,inside;
#else
	MFORM	*mouse_inform,*mouse_outform,*mouse_workform;
	int		mouse_in,mouse_work,mouse_out,inside;
#endif
#endif
	char	iconified,fulled,opened,back,flag;
#ifndef SMALL_NO_XACC_AV
	char	av_win;
#endif
	int		msgs,min_w,min_h,drawn;
	GRECT	max,curr,prev,work,first;
	int		sl_hpos,sl_vpos,sl_hsize,sl_vsize;
	char	*name,*info;
	char	name_buffer[256];
#ifndef SMALL_NO_ICONIFY
	GRECT	icon_work;
	OBJECT	*icon;
	char	*icon_name;
	int		posnr;
#endif
	void	(*redraw)(int first,struct __win_info *win,GRECT *area);
	void	*dialog,*para;
#ifndef SMALL_NO_TERMINAL
	void	*terminal;
#endif
#ifndef SMALL_NO_SCROLL
	SCROLL	*scroll;
#endif
#ifndef SMALL_NO_HANDLER
	MITEM	*items;
	int		items_cnt;
#endif
	long	timer;
	int		timer_enable,index;
#ifdef __EPX__
	void	*cpx,*cpx_para;
#endif
} WIN;

#define XM_TOP		0x01
#define XM_BOTTOM	0x02
#define XM_SIZE		0x04

#ifndef SMALL_NO_DD

#define AV_DRAG		0
#define AV_START	1
#define AV_OPEN		2
#define MINT_DRAG	3
#define MINT_ARGS	4
#ifndef SMALL_NO_OEP
#define MINT_OEPD	5
#endif

typedef struct
{
	int		dd_type,dd_originator;
	int		dd_mx,dd_my,dd_kstate;
	char	*dd_text,*dd_name,*dd_args,*dd_mem,dd_ext[4];
	long	dd_size;
	WIN		*dd_win;
} DRAG_DROP;
#endif

#define MAX_EDIT	256
#define MAX_PATH	256

#ifdef __EPX__
#define MAX_WINDOWS	32
#else
#define MAX_WINDOWS	16
#endif
#define MAX_DIALS	16

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
	int			di_fly;
	long		di_mode;
#ifndef SMALL_NO_EDIT
	int			di_ed_obj,di_ed_index,di_ed_scroll,di_cursor,di_insert,di_inddef,di_ed_cnt;
	char		di_undobuff[MAX_EDIT];
	GRECT		di_crsrect;
	boolean 	(*di_edit_handler)(struct __dialog *info,char valid,char input,char *out);
#endif
	int			di_default,di_help,di_undo,di_esc,di_taken,di_xy_off,di_wh_off;
	char		*di_title;
#ifndef SMALL_NO_GRAF
	void		*di_slider;
#endif
#ifndef SMALL_NO_POPUP
	void		*di_popup;
#endif
#ifndef SMALL_NO_LISTBOX
	void		*di_listbox;
#endif
	WIN			*di_win;
	int 		(*di_mouse)(struct __dialog *info,OBJECT *tree,int obj,int last_obj,int x,int y,GRECT *out);
	int			di_last_obj,di_last_mode,di_update;
	ALERT		*di_alert;
	void		*di_mem;
	void 		(*di_handler)(struct __dialog *info,int obj,int clicks);
	void		*di_para;
#ifdef __EPX__
	void		*di_cpx,*di_cpx_para;
	int	cdecl	(*di_cpx_handler)(struct __dialog *info,int obj,int clicks);
	int cdecl	(*di_cpx_edit_handler)(struct __dialog *info,char valid,char input,char *out);
	int	cdecl	(*di_cpx_mouse)(struct __dialog *info,OBJECT *tree,int obj,int last_obj,int x,int y,GRECT *out);
#endif
} DIAINFO;

#ifndef SMALL_NO_POPUP

#define POPUP_EXIT	-1
#define POPUP_CONT	0

typedef struct __popup
{
	DIAINFO	*p_info;
	OBJECT	*p_menu;
	int		p_parent,p_button,p_cycle;
	boolean	p_wrap,p_set;
	int		(*p_func)(struct __popup *popup,int current,int mode);
#ifdef __EPX__
	int	cdecl (*cpx_p_func)(struct __popup *popup,int current,int mode);
#endif
} POPUP;

typedef struct
{
	POPUP	popup;
	int		id,mode,cycle_mode,center,x,y,index,current,opened;
} XPOPUP;

#else

#define XPOPUP		void

#endif

#ifndef SMALL_NO_LISTBOX

typedef struct
{
	DIAINFO	*lb_info;
	char	**lb_entries;
	int		lb_parent,lb_button,lb_cycle;
	int		lb_cnt,lb_width,lb_height,lb_current;
	boolean	lb_set;
} LISTBOX;

typedef struct
{
	LISTBOX	listbox;
	int		lb_mode,lb_cycle_mode,lb_opened;
} XLISTBOX;

#else

#define XLISTBOX	void

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
	void		(*sl_do)(struct __slinfo *sl,OBJECT *tree,int pos,int prev,int max_pos,int cursor,int prev_crs);
	SLKEY		*sl_keys;
	int			sl_keys_cnt;
#ifdef __EPX__
	void cdecl	(*cpx_sl_do)(struct __slinfo *sl,OBJECT *tree,int pos,int prev,int max_pos,int cursor,int prev_crs);
#endif
} SLINFO;

#define SL_UP			-1
#define SL_DOWN			-2
#define SL_PG_UP		-3
#define SL_PG_DN		-4
#define SL_START		-5
#define SL_END			-6
#define SL_SET			-7
#define SL_CRS_UP		-8
#define SL_CRS_DN		-9
#define SL_CRS_PG_UP	-10
#define SL_CRS_PG_DN	-11
#define SL_CRS_START	-12
#define SL_CRS_END		-13

#else

#define SLINFO	void

#endif

#if !(defined(__MINT_LIB__) || defined(_XAESFAST_A))
typedef struct
{
	int			v_x1;
	int			v_y1;
	int			v_x2;
	int			v_y2;
} VRECT;
#endif	/* !(__MINT_LIB__ || _XAESFAST_A) */

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

#ifndef __NoEGEM__
extern	int	ap_id,menu_id,grhandle,x_handle,has_3d,bottom,bevent,owner;
extern	int	gr_cw,gr_ch,gr_bw,gr_bh,gr_sw,gr_sh,windows_opened;
extern	int	max_w,max_h,planes,colors,colors_available;
extern	int multi,aes_version,winx,wincom,magx,mtos,mint;
extern	int small_font,small_font_id,ibm_font,ibm_font_id,fonts_loaded,speedo;
extern	int search,work_out[],ext_work_out[],boot_drive;
extern	unsigned int gemdos_version,tos_version,tos_date;

#ifndef SMALL_NO_MENU
extern	int menu_available;
#endif

#ifndef SMALL_NO_FSEL
extern	DIAINFO *FSelDialog;
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

void ob_dostate(OBJECT *tree, int obj, int state);
void ob_undostate(OBJECT *tree, int obj, int state);
int ob_isstate(OBJECT *tree, int obj, int state);

#define	FLIP_STATE	FAIL
#define CLEAR_STATE	FALSE
#define SET_STATE	TRUE
void ob_switchstate(OBJECT *tree,int obj,int masc,int set);

#endif

#define ob_setstate(t,o,s)	t[o].ob_state = s

#ifndef __NoEGEM__
int ob_disable(DIAINFO *info, OBJECT *tree, int obj, int disable, int draw);
int ob_select(DIAINFO *info, OBJECT *tree, int obj, int select, int draw);
int ob_state(DIAINFO *info,OBJECT *tree,int obj,int masc,int set,int draw);

void ob_switchflags(OBJECT *tree,int obj,int masc,int set);
void ob_blockup(OBJECT *tree,int object,int set);
void ob_popup(OBJECT *tree,int object);
void ob_doflag(OBJECT *tree, int obj, int flag);
void ob_undoflag(OBJECT *tree, int obj, int flag);
int ob_isflag(OBJECT *tree, int obj, int flag);
void ob_hide(OBJECT *tree, int obj, int hide);
#endif

#define ob_setflags(t,o,f)	t[o].ob_flags = f

#ifndef __NoEGEM__
void ob_xywh(OBJECT *tree, int obj, GRECT *rec);
void ob_pos(OBJECT *tree, int obj, GRECT *rec);

char *ob_get_text(OBJECT *tree, int obj, int clear);
void ob_set_text(OBJECT *tree, int obj, char *text);
void ob_clear_edit(OBJECT *obj);
void ob_dial_init(DIAINFO *info,int edit);

#ifndef SMALL_NO_EDIT

#define CURSOR_SET	TRUE
#define CURSOR_NOT	FALSE
#define CURSOR_DONE	FAIL

void ob_edit_init(DIAINFO *info, int edit);
void ob_edit_handler(DIAINFO *info,boolean (*foo)(DIAINFO *info,char valid,char input,char *out));
void ob_cursor_handler(boolean (*foo)(DIAINFO *info,int obj,int index,int scroll,int insert));
int ob_set_cursor(DIAINFO *info, int obj, int index, int insert, int scroll);

boolean init_edit(OBJECT *tree, int obj, char *text,int len);
int set_edit(DIAINFO *info, OBJECT *tree, int obj, char *text);
char *get_edit(DIAINFO *info, int obj);
boolean update_edit(DIAINFO *info, int obj);

#endif

OBJECT *ob_copy_tree(OBJECT *tree);

int ob_set_hotkey(OBJECT *tree, int button, char hot);
char ob_get_hotkey(OBJECT *tree, int button);

int ob_draw(DIAINFO *info, int obj);
int ob_draw_chg(DIAINFO *info, int obj, GRECT *area, int new_state);
int ob_draw_list(reg DIAINFO *info, reg int *ob_lst, reg GRECT *area);

void ob_draw_dialog(OBJECT *tree, int x, int y, int w, int h);
void ob_undraw_dialog(OBJECT *tree, int x, int y, int w, int h);

int ob_radio(DIAINFO *info,OBJECT *tree, int parent, int object);
int ob_get_parent(OBJECT *tree, int index);

boolean InitUserObject(PARMBLK *pb, GRECT *work, int mode, int font, int size);
void InvertUserLine(GRECT *work, int y, int h);
void ExitUserObject(void);

#ifdef __GNUC__
#define rc_grect_to_array grect_to_array
#else	/* __GNUC__ */
void rc_grect_to_array(GRECT *rec, int *pxy);
#ifdef __PUREC__
int		rc_copy(GRECT*,GRECT*);
int		rc_equal(GRECT*,GRECT*);
int		rc_intersect(GRECT*,GRECT*);
int 	rc_inside(int x, int y, GRECT *rec);
#else
#ifdef _XVDIFAST_A
int rc_inside(int x, int y, GRECT *rec);
#else /* !_XVDIFAST_A */
#define rc_inside(a,b,c)	(rc_inside(a,b,c) & 0x0001)
#endif
#endif	/* __PUREC__ */
#endif	/* !__GNUC__ */

void rc_array_to_grect(int *pxy, GRECT *rec);

void rc_sc_copy(GRECT *source, int dx, int dy, int mode);
void rc_sc_clear(GRECT *dest);
void rc_sc_set(GRECT *dest);
void rc_sc_invert(GRECT *dest);
int rc_sc_scroll(GRECT *work, int dist_h, int dist_v, GRECT *work2);
int rc_sc_save(GRECT *rect, RC_RECT *rc);
int rc_sc_freshen(int sx, int sy, RC_RECT *rc);
int rc_sc_restore(int x, int y, RC_RECT *rc, int mode);

#ifndef SMALL_NO_CLIPBRD

void scrp_clr(int all);
long scrp_length(void);
int scrp_find(char *extension, char *filename);
int scrp_path(char *path, char *file);

void scrp_changed(int format, long best_ext);

#endif
#endif

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

#if !defined(SMALL_NO_MENU) && !defined(__NoEGEM__)
int menu_install(OBJECT *tree, int show);
void menu_enable(boolean enable);
void menu_item_enable(int obj, int enable);
void menu_select(int titel, int select);
boolean menu_dropped(void);
#endif

#define HOR_SLIDER			0
#define	VERT_SLIDER			1

typedef struct
{
	int mx,my,mbut,kstate;
} MKSTATE;

#ifndef __NoEGEM__
void graf_busy_mouse(void);
int graf_rt_rubberbox(int desk_clip, int s_x, int s_y, int min_w, int min_h, GRECT *bound, int *r_w, int *r_h, void (*call_func )(boolean draw, int *array, MKSTATE *mk));
int graf_rt_dragbox(int desk_clip, GRECT *start, GRECT *bound, int *r_x, int *r_y, void (*call_func )(boolean draw, int *array, MKSTATE *mk));
int graf_rt_dragobjects(int desk_clip, int *objects, GRECT *bound, void (*call_func )(boolean draw, int *array, MKSTATE *mk));
void graf_rt_lines(int *array, boolean close);
#endif

#ifndef SMALL_NO_GRAF

#define GRAF_SET_ARROWS		1
#define GRAF_SET_SIZE_POS	2
#define GRAF_DRAW_SLIDER	4

#define GRAF_SET			(GRAF_SET_ARROWS|GRAF_SET_SIZE_POS)
#define GRAF_DRAW			(GRAF_SET|GRAF_DRAW_SLIDER)

#define SL_STEP				0
#define SL_LINEAR			1
#define SL_LOG				2
#define SL_EXP				3

#ifndef __NoEGEM__
void graf_set_slider(SLINFO *sl, OBJECT *tree, int show);
void graf_arrows(SLINFO *sl, OBJECT *tree, int show);
void graf_rt_slidebox(SLINFO *sl, int obj, int double_click, int new_pos, int new_cursor);
void graf_rt_slidecursor(SLINFO *sl, int dc);
#endif
#endif

#ifndef __NoEGEM__
int	Event_Multi(XEVENT*event);
void Event_Timer(int locount, int hicount, int no_key);
void DispatchEvents(void);
void Event_Handler(int (*init )(XEVENT *event, int available), int (*handler )(XEVENT *event));
void ClrKeybd(void);
void NoClick(void);
#endif

#define DOUBLE_CLICK	0x8000
#define RIGHT_CLICK		0x4000
#ifdef __SOZOBONX__
#define NO_CLICK		(int)(~(DOUBLE_CLICK|RIGHT_CLICK))
#else
#define NO_CLICK		(~(DOUBLE_CLICK|RIGHT_CLICK))
#endif

#ifndef __NoEGEM__
int X_Form_Do(DIAINFO **back);
void FormUpdate(int flag);

int appl_xgetinfo(int type, int *out1, int *out2, int *out3, int *out4);
int objc_xsysvar(int ob_smode, int ob_swhich, int ob_sival1, int ob_sival2, int *ob_soval1, int *ob_soval2);
int appl_getfontinfo(int ap_gtype, int *height, int *id, int *type);

#ifdef	__PUREC__
int wind_xget(int w_handle,int w_field,int *w1,int *w2,int *w3,int *w4);
#else
#if !defined(__SOZOBONX__) || defined(__CREATE_E_GEM_LIB_OR_EXAMPLE__)
#define	wind_xget(hdl,field,p1,p2,p3,p4)	wind_get(hdl,field,p1,p2,p3,p4)
#endif
#endif

boolean init_gem(char *win_id, char *m_entry, char *x_name, char *a_name, int av_msgs, int va_msgs, int va_x_msgs, int xacc_msgs);
void reinit_gem(boolean close_all,boolean no_msg);
#ifdef SMALL_NO_XACC_AV
#define	init_gem(a,b,c,d,e,f,g,h)	init_gem(a,b,NULL,NULL,e,f,g,h)
#endif
void exit_gem(boolean all, int result);

boolean open_work(int *handle, int *work_out);
void close_work(int handle);
boolean open_device(int dev, boolean rc, int *handle, int *work_out);
void close_device(int handle);
boolean driver_available(int dev);

boolean open_rsc(char *rscname, char *win_id, char *m_entry, char *x_name, char *a_name, int av_msgs, int va_msgs, int va_xmsgs, int xacc_msgs);
#ifdef SMALL_NO_XACC_AV
#define	open_rsc(a,b,c,d,e,f,g,h,i)	open_rsc(a,b,c,NULL,NULL,f,g,h,i)
#endif

#define	close_rsc(all,exit)	exit_gem(all,exit)

void rsrc_calc(OBJECT *tree, int scaling, int orig_cw, int orig_ch);
void rsrc_init(int n_tree, int n_obs, int n_frstr, int n_frimg, int scaling, char **rs_strings, long *rs_frstr, BITBLK *rs_bitblk, long *rs_frimg, ICONBLK *rs_iconblk, TEDINFO *rs_tedinfo, OBJECT *rs_object, OBJECT **rs_trindex, RS_IMDOPE *rs_imdope,
	int orig_cw, int orig_ch, boolean obfix);

void fix_objects(OBJECT *tree, int scaling, int orig_cw, int orig_ch);
OBJECT *fix_tree(int index, int scaling, int orig_cw, int orig_ch);
void scale_image(OBJECT *obj, int scaling, int orig_cw, int orig_ch);
void trans_image(OBJECT *obj);

void vsf_aespattern(int handle, int obx, int oby, int patternindex);

void vs_attr(void);
void v_set_text(int font, int height, int color, int effect, int rotate, int *out);
int v_set_point(int all, int height);
int v_set_font(int font);
int Height2Point(int font, int height);
void v_set_mode(int mode);
void v_set_line(int color, int width, int type, int start, int end);
void v_set_fill(int color, int inter, int style, int peri);
void v_aespattern(int ob_x, int ob_y, int pattern);

void v_rect(int sx, int sy, int dx, int dy);
void v_line(int x1, int y1, int x2, int y2);

void save_clipping(int *area);
void restore_clipping(int *new_area);
void clip_rect(GRECT *area);
#endif

#define	DIA_MOUSEPOS	TRUE
#define DIA_CENTERED	FALSE
#define DIA_LASTPOS		FAIL

#ifndef __NoEGEM__
DIAINFO *open_dialog(OBJECT *tree,char *win_name,char *icon_name,OBJECT *icon,boolean center,boolean box,long mode,int edit,SLINFO **slider,XPOPUP **pop,XLISTBOX **listbox,SCROLL *scroll,void (*foo)(DIAINFO *info,int obj,int clicks),void *para);
int close_dialog(DIAINFO *info, boolean box);
void close_all_dialogs(void);
#endif

#ifndef SMALL_NO_MOUSE
#define DIALOG_OBJECT	0
#define DIALOG_MOUSE	1
#define DIALOG_MOVEMENT	2

#ifndef __NoEGEM__
void dialog_mouse(DIAINFO *info, int (*mouse )(DIAINFO *info, OBJECT *tree, int obj, int last_obj, int x, int y, GRECT *out));
#endif
#endif

#ifndef SMALL_NO_ICONIFY
#define GD_TITLE	(MOVER|NAME|CLOSER|SMALLER)
#else
#define GD_TITLE	(MOVER|NAME|CLOSER)
#endif

#define	GD_SIZE		(GD_TITLE|FULLER|SIZER)
#define GD_STANDARD	(GD_SIZE|UPARROW|DNARROW|RTARROW|LFARROW|VSLIDE|HSLIDE)

#ifndef __NoEGEM__
WIN *open_window(char *title, char *icon_title, char *info, OBJECT *icon, int typ, int box, int min_w, int min_h, GRECT *max_curr, GRECT *curr, SCROLL *scroll, void (*redraw )(int first, WIN *win, GRECT *area), void *para, int msgs, int back);
void window_reinit(WIN *win, char *title, char *icon_title, char *info, int home, int draw);
boolean window_top(WIN *win);
boolean WindowTop(WIN *win);
boolean window_bottom(WIN *win);
void window_size(WIN *win, GRECT *size);
void window_slider(WIN *win, int dir, int pos, int size);
void window_name(WIN *win, char *name, char *icon_name);
#ifndef SMALL_NO_MOUSE
void window_set_mouse(WIN *window, int in, int work, int out, int icon, MFORM *in_form, MFORM *work_form, MFORM *out_form, MFORM *icon_form);
#endif
void window_info(WIN *win, char *info);
void window_border(int kind,boolean dsk, int x, int y, int w_in, int h_in, GRECT *out);
int window_work(WIN *win, GRECT *out);
void window_calc(int type, int kind, GRECT *in, GRECT *out);
void windial_calc(int calc_work, DIAINFO *info, GRECT *work);
void windial_offset(long mode,int *xy,int *wh);
WIN *window_find(int x, int y);
void redraw_window(WIN *win, GRECT *area);
#endif

#define MOUSE_OFF	FAIL
#define MOUSE_ON	FALSE
#define MOUSE_TEST	TRUE

#define RC_FIRST	1
#define RC_SCROLL	2

#ifndef __NoEGEM__
void draw_window(WIN *win, GRECT *area, void *para, int m_off, void (*redraw )(int first, WIN *win, GRECT *area, GRECT *work, void *para));

#ifndef SMALL_NO_SCROLL
void scroll_window(WIN *win, int mode, GRECT *rect);
#endif
int close_window(WIN *window, int box);
void close_all_windows(void);

WIN *get_window(int handle);
WIN *get_window_list(int first);
WIN *get_top_window(void);

int GetTop(void);
int GetOwner(int handle);

int window_first(WIN *win, GRECT *rect);
int window_next(WIN *win, GRECT *rect);
#endif

#ifndef SMALL_NO_HANDLER
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

#ifndef __NoEGEM__
int WindowHandler(int mode, WIN *window);
void MenuItems(MITEM *close, MITEM *closeall, MITEM *cycle, MITEM *invcycle, MITEM *globcycle, MITEM *full, MITEM *bottom, MITEM *iconify, MITEM *iconify_all, MITEM *menu, int menu_cnt);
void WindowItems(WIN *win, int cnt, MITEM *items);
#endif
#endif

#ifndef __NoEGEM__
int get_dialog_info(int *fly_dials, int *win_dials, DIAINFO **top);
int window_output(void);
#endif

#ifndef SMALL_NO_TERMINAL

typedef struct
{
	char	ch,effect;
	int		color;
} TCHAR;

#define T_ESC		1
#define	T_XPOS		2
#define T_YPOS		3
#define T_EFFON		4
#define T_EFFOFF	5
#define T_QUOTE		6
#define T_CR		7
#define T_FLASH		8

#define	T_STD		0
#define T_EXT		1

#define CH_UPDT		1
#define NO_UPDT		0
#define LN_UPDT		-1

typedef struct
{
	WIN		*window;
	SCROLL	scroll;
	int		text_id,text_size,text_effect,text_color,bg_color;
	int		wrap_mode,wrap,tab,rows,lines,scrollback;
	int		crs_x,crs_y,crs_on;
	int		cw,ch,save_x,save_y,mi,ma,update,dsc;
	char	mode,raw,lock,esc;
	TCHAR	*chars;
	long	mem_chars,mem_line,term_chars;
} TERM;

void TWrite(TERM *con, char *txt);
void TWriteLn(TERM *con);
void TWriteLine(TERM *con, char *line);
void TWriteChar(TERM *con, char c);
int TPrintf(TERM *con, const char *format, ...);

char TGetChar(TERM *con, int x, int y, int *color, int *effect);
void TGetPos(TERM *con, int *x, int *y);

void TClrLine(TERM *con);
void TClrStartOfLine(TERM *con);
void TClrEndOfLine(TERM *con);
void TClrStartOfScreen(TERM *con);
void TClrEndOfScreen(TERM *con);
void TClrScreen(TERM *con);
void TDeleteLine(TERM *con);
void TInsertLine(TERM *con);
void TGetLine(TERM *con, int line, char *string);

#define	T_MAX	FAIL
#define T_CURR	FALSE
#define	T_SIZE	TRUE

boolean TSetFont(TERM *con, int id, int height, int color, int effect, boolean size);
void TSetSize(TERM *con, int x, int y, int w, int h, GRECT *max_curr);
void TSetCursor(TERM *con, int x, int y, int on);
void TSetAttributes(TERM *con, int bg, int text, int effect);

#define	AUTO_WRAP	FAIL
#define	NO_WRAP		FALSE
#define WRAP_ON		TRUE

void TSetOptions(TERM *con, boolean mode, int wrap, int tab, boolean raw);

void TerminalLock(TERM *con, boolean lock);
TERM *OpenTerminal(char *name, char *icon_name, char *info, OBJECT *icon, int gadgets, int x, int y, int w, int h, int rows, int lines, int scrollback, GRECT *max_curr, int id, int height, int txt, int bg, int mode);
void CloseTerminal(TERM *con);

TERM *GetTopTerminal(void);

#endif

#if defined(DEBUG) && !defined(SMALL_NO_XACC_AV)

void Trace(const char *id,const char *format, ...);

#else

#define Trace()

#endif

typedef struct
{
	char magic[4],id[5],buffer[76],access;
	int msg_count;
} TRACE;

#define SEND_TRACE	 0x4888
#define ANSWER_TRACE 0x4889

#ifndef __NoEGEM__
ALERT *MakeAlert(int def, int undo, int icn, BITBLK *usr_icn, int modal, int center, int width, char *title, char *txt, char *btns);
int ExitAlert(ALERT *al, int exit);
int xalert(int def, int undo, int icn, BITBLK *usr_icn, int modal, int center, int width, char *title, char *txt, char *btns);
void error(int icn, char *title, char *err);
#endif

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

#ifndef __NoEGEM__
int Popup(POPUP *popup, int mode, int center, int x, int y, int *index, int select);
void ClosePopup(void);
#endif

#endif

#ifndef SMALL_NO_LISTBOX

#define	LB_OPEN		0
#define LB_CYCLE	POPUP_CYCLE
#define LB_INVCYCLE	POPUP_INVCYCLE

#ifndef __NoEGEM__
int ListBox(LISTBOX *lb, int mode, int x, int y);
#endif

#endif

#ifndef __NoEGEM__
int beg_ctrl(int test, int out, int ms);
void end_ctrl(int out, int ms);
int beg_update(int test, int off);
void end_update(int on);

void dial_colors(int d_pattern, int d_color, int d_frame, int hotkey, int alert, int popup, int check, int radio, int arrow, int popup_bgrnd, int check_bgrnd, int radio_bgrnd, int arrow_bgrnd, int edit_ddd, int draw_ddd, int icon_bg_color);
#endif

#define KEY_FIRST	FAIL
#define KEY_STD		FALSE
#define KEY_ALWAYS	TRUE

#define RETURN_DEFAULT		TRUE
#define RETURN_NEXT_EDIT	FALSE
#define RETURN_LAST_DEFAULT	FAIL

enum {TOP_BACK=-1,NO_BACK,AES_BACK,ALWAYS_BACK};

#ifndef __NoEGEM__
void dial_options(boolean round, boolean niceline, boolean xobjs_norm, boolean ret, boolean back, boolean nonsel, boolean keys, boolean mouse, boolean clipboard, int hz);
void header_options(boolean set, boolean center, boolean frame, boolean small, boolean transp, int tcolor, int fcolor, int bcolor, int bpattern);
void title_options(boolean title, int color, int size);

void radio_image(int index, BUTTON *radio);
void check_image(int index, BUTTON *check);
void arrow_image(int index, BUTTON *down, BUTTON *up, BUTTON *left, BUTTON *right);
void cycle_image(int index, BUTTON *cycle, char c);

void create_cookie(COOKIE *cookie, long id, long value);
boolean new_cookie(COOKIE *entry);
boolean get_cookie(long cookie, long *value);
void remove_cookie(long cookie_id);
void move_cookiejar(long *dest, long size);
long cookie_size(void);
#endif

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
#define FS_FNT_SYSTEM	16

#ifndef SMALL_NO_FSEL

#ifndef SMALL_NO_DD_FSEL
#define FSEL_DRAG		0
#endif

#define FSEL_DIAL		1
#define	FSEL_WIN		2
#define FSEL_NONMODAL	3

#define FS_RES_ERROR	-105
#define FS_NO_WINDOW	-104
#define FS_NO_FONTS		-103
#define FS_ACTIVE		-102
#define FS_SET			-101
#define FS_ERROR		-100
#define FS_ABANDON		FAIL
#define FS_CANCEL		FALSE
#define FS_OK			TRUE
#define FS_OPENED		100

#define FS_GADGETS_STANDARD	0
#define FS_GADGETS_EFFECT	1
#define FS_GADGETS_COLOR	2
#define FS_GADGETS_SKEW		4
#define FS_GADGETS_SPEEDO	8
#define FS_GADGETS_INVERS	16
#define FS_GADGETS_DEFAULT	32
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
		unsigned app_only  : 1;
		unsigned buttons   : 1;
		unsigned no_action : 1;
	} drag;
	struct __fsel_options
	{
		unsigned		 : 7;
		unsigned redraw  : 1;
		signed center    : 3;
		unsigned boxes   : 1;
		unsigned preview : 1;
		unsigned sort    : 1;
		unsigned action  : 2;
	} options;
	int		(*font_test)(FONTINFO*fnt,int h);
	void	(*help_func)(void);
	int		id,size,effect,color,skew,x,y;
	FONTINFO *fnt;
	int		app,win;
} FONTSEL;

typedef struct
{
	int	title;
	int font,face,size,example;
	int	info,cancel,ok;
} FSELOBJ;

extern FSELOBJ FSelObjects;

boolean FontSelect(int mode, FONTSEL *fs);
boolean UpdateFsel(boolean all, boolean example);

#endif

FONTINFO *FontInfo(int id);
FONTINFO *FastFontInfo(int id);

int FontAvailable(int id, char *name);
int FontList(int type, int min_size, int max_size, int max_fonts, FONTINFO *fonts[], int (*font_test )(FONTINFO *fnt, int h));
int FontSizes(int id, int fsm, int min_size, int max_size, int max_cnt, reg int *sizes, int (*font_test )(FONTINFO *fnt, int h));

#endif

#ifndef __NoEGEM__
int FontChanged(int app, int win, int id, int size, int color, int effect);
int CallFontSelector(int win, int fnt_id, int size, int color, int effect);
int FontAck(int id, boolean ack);
#endif

#ifndef SH_WDRAW
#define SH_WDRAW	72
#endif

#ifndef __NoEGEM__
void drive_changed(int drive);
#endif

#define	F_APPLMODAL	FAIL
#define	F_NONMODAL	FALSE
#define F_SYSMODAL	TRUE

#ifndef __NoEGEM__
int FileSelect(char *title, char *path, char *fname, char *sel, int no_insel, int out, char *outptr[], int id, boolean modal);

char *DgetFullpath(char *path);
char *BuildName(char *dest,char *src,boolean to_str);
char *GetFilename(char *path);
char *GetExtension(char *path);
char *GetPath(char *fname);
int GetDrive(char *path);
char *MakeFullpath(char *dest, char *path, char *file);
char *QuoteFname(boolean quote, char *dest, char *source);
char *HomeDirectory(char *home);
boolean SaveInfoFile(char *file, boolean auto_path, void *info, int len, char *id, int version);
int LoadInfoFile(char *file, boolean auto_path, void *info, int len, int min_len, char *id, int min_version);

#ifdef __PUREC__
char *getenv(const char *var);	/* Funktionen gibt es in stdlib.h */
int putenv(const char *entry);
#endif	/* __PUREC__ */

int scan_2_ascii(int scan, int state);
char UpperChar(char ch);
char LowerChar(char ch);
char *strlcpy(reg char *d, reg char *s);
char *strend(reg char *str);
char *strwild(char *string, char *wild);

#ifndef SMALL_EDIT
OBJECT *MakeAscii(void);
char ExitAscii(OBJECT *tree, int exit);
char ascii_box(DIAINFO *edit, char *title);
#endif

int int2str(char *p, int val, int size);
int mm2dpi(int size);

int mini(int v_1, int v_2);
int maxi(int v_1, int v_2);
void Min(int *var, int val);
void Max(int *var, int val);

void mfdb(MFDB *fm, int *adr, int w, int h, int st, int pl);
long mfdb_size(MFDB *fm);
#endif

#define  MIN(x,y) ((x)<(y) ? (x) : (y))
#define  MAX(x,y) ((x)>(y) ? (x) : (y))

#define CONT_TIMER	-1L
#define	STOP_TIMER	-2L

typedef struct timeout_entry
{
	struct timeout_entry *next,*prev;
	long id,last,count,para,timer_id;
	int enable;
	long (*fkt)(long para,long time,MKSTATE *mk);
	WIN *win;
#ifdef __EPX__
	long cpx_para;
	long cdecl (*cpx_foo)(long para,long time,MKSTATE *mk,int *stop);
	void *cpx;
#endif
} TIMEOUT;

#ifndef __NoEGEM__
long 	NewTimer(long count,long para,long (*foo)(long para,long time,MKSTATE *mk));
long 	WinTimer(WIN*win,int enable,long count,long para,long (*foo)(long para,long time,MKSTATE *mk));
boolean	EnableTimer(long id,boolean para);
int		KillTimer(long id);
#endif

/* Drag & Drop */

char *ParseArgs(char *orig);

#if !defined(SMALL_NO_DD) && !defined(__NoEGEM__)
int SendDragDrop(int msx, int msy, int kstate, char *text, char *name, char *sp_ext, long size, char *data);
long AppDragDrop(int sendto, int win_id, int msx, int msy, int kstate, char *text, char *name, char *sp_ext, long size, char *data, int res1, long *res2);
void SetDragDrop(int any, char *exts);
#endif

/* XAcc-2- und AV-Protokoll */

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
#define AV_STARTED			0x4738
#define AV_XWIND			0x4740
#define AV_VIEW				0x4751
#define AV_FILEINFO			0x4753
#define AV_COPYFILE			0x4755
#define AV_DELFILE			0x4757
#define AV_SETWINDPOS		0x4759

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
#define VA_VIEWED			0x4752
#define VA_FILECHANGED		0x4754
#define VA_FILECOPIED		0x4756
#define VA_FILEDELETED		0x4758
#define VA_PATH_UPDATE		0x4760

#define	VA_OB_UNKNOWN		0
#define VA_OB_TRASHCAN		1
#define VA_OB_SHREDDER		2
#define VA_OB_CLIPBOARD 	3
#define VA_OB_FILE			4
#define VA_OB_FOLDER		5
#define VA_OB_DRIVE			6
#define VA_OB_WINDOW		7
#endif

#ifndef SMALL_NO_XACC_AV

#define XACC		0x01

#define MSGGROUP1	0x01
#define MSGGROUP2	0x02

#define XACC_LEVEL	(MSGGROUP1|MSGGROUP2)

#define	X_MSG_TEXT	0x1
#define	X_MSG_META	0x2
#define	X_MSG_IMG	0x4

#define AV			0x02

/* AV_PROTOKOLL-Bitmap */

#define MSG_SETSTATUS		0x001
#define MSG_START			0x002
#define MSG_AVSTARTED		0x004
#define MSG_AVFONTCHANGED	0x008
#define MSG_AVQUOTE			0x010
#define MSG_AV_PATH_UPDATE	0x020

/* VA_PROTOSTATUS-Bitmap */

#define	MSG_SENDKEY			0x001
#define MSG_ASKFILEFONT		0x002
#define MSG_ASKCONFONT		0x004
#define MSG_ASKOBJECT		0x008
#define MSG_OPENWIND		0x010
#define MSG_STARTPROG		0x020
#define MSG_ACCWINDOPEN		0x040
#define	MSG_STATUS			0x080
#define MSG_COPY_DRAGGED	0x100
#define MSG_VA_PATH_UPDATE	0x200
#define MSG_VAEXIT			0x400
#define MSG_XWIND			0x800
#define MSG_VAFONTCHANGED	0x1000
#define MSG_VASTARTED		0x2000
#define MSG_VAQUOTE			0x4000
#define MSG_FILEINFO		0x8000

#define MSG_COPYFILE		0x001
#define MSG_DELFILE			0x002
#define MSG_VIEW			0x004
#define MSG_SETWINDOWPOS	0x008


#define MAX_XACCS	16
#define XNAME_ALLOC	0x8000

typedef struct
{
	int		flag,id,version,menu_id,av_msgs,va_msgs,va_xmsgs;
	char	name[10],*xname,*xdsc;
} XAcc;

#ifndef __NoEGEM__
XAcc *find_xacc_xdsc(int id, char *dsc);
XAcc *find_id(int id);
XAcc *find_app(int first);

int XAccSendAck(int sendto, int answer);
int XAccSendKey(int sendto, int scan, int state);
int XAccSendText(int sendto, char *text);
int XAccSendMeta(int sendto, int last, char *data, long len);
int XAccSendImg(int sendto, int last, char *data, long len);

int VaStart(int sendto, char *args);
void AvOptions(int no_key);
#endif
#endif

#ifndef __NoEGEM__
void XAccBroadCast(int *msg);
int AvSendMsg(int sendto, int msg_id, int *msg);
void InternalMsg(int buffered,int msg_id,int *msg,boolean init,boolean optimize);
void *GetMsgBuffer(long size);
#define GetMsgBuffer(s)	GetMsgBuffer((long) (s))
boolean AppName(int app, char *prog_name, char *xacc_name);
int AppLoaded(char *app);
#endif

/* OEP-Protokoll */

#ifndef OLE_INIT

#define OLE_INIT		16962
#define OLE_EXIT		16963
#define OLE_NEW			16964

#define OL_OEP			0x0001

#define OEP_RES00		21000
#define OEP_CONFIG		21001
#define OEP_INFO		21002
#define OEP_LINK		21003
#define OEP_RES04		21004
#define OEP_UPDATE		21005
#define OEP_DATA		21006
#define OEP_CHANGED		21007
#define OEP_MANGRJOB	21008
#define OEP_RES09		21009
#define OEP_RES10		21010
#define OEP_RES11		21011
#define OEP_RES12		21012
#define OEP_RES13		21013
#define OEP_RES14		21014
#define OEP_RES15		21015
#define OEP_RES16		21016
#define OEP_RES17		21017
#define OEP_RES18		21018
#define OEP_RES19		21019

#define OEP_CONF_UPDT	0x0001
#define OEP_CONF_SHOW	0x0002
#define OEP_CONF_USER	0x0004
#define OEP_CONF_RESV	0x0008
#define OEP_CONF_GDOS	0x0010

#define OEP_INFO_CONF	0x0001

#define OEP_LINK_FREE	0x0001
#define OEP_LINK_USER	0x0002

#define OEP_OBNEW		0x0001
#define OEP_OBCONV		0x0002
#define OEP_ARES0		0x0004
#define OEP_ARES1		0x0008
#define OEP_GDOS		0x0010
#define OEP_ARES2		0x0020
#define OEP_ARES3		0x0040
#define OEP_ARES4		0x0080
#define OEP_OBJECT		0x0100
#define OEP_OBINFO		0x0200
#define OEP_APINFO		0x0400
#define OEP_CRINFO		0x0800

#define SEND_TOALL		-1
#define NO_MANAGER		-2

typedef struct
{
	int 	apid,manager,ok,version,config,res;
} OEP;

typedef struct
{
	long		id;
	unsigned	date,time;
	long		systime,cid;
} OEP_OBHEADER;

typedef struct
{
	long	id;
	unsigned	date,time;
	long	systime,cid;
	char	obname[128],obfile[128];
	long	obtype;
	char	crname[32],crfile[10];
	int 	crid,datacoming;
} OEP_BIGOBHEADER;

typedef struct
{
	int 	type;
	long	id;
	unsigned	date,time;
	long	systime,cid;
	char	obname[128],obfile[128];
	long	obtype,res1,res2;
	char	apname[32],apfile[10];
	int 	apid;
	long	res3,res4;
	char	crname[32],crfile[10];
	int 	crid;
	long	res5,res6;
	int		res7;
	long	res8;
} OEPD_HEADER;

typedef struct
{
	long	link;
} OEPD_DATA;

#endif

#ifndef SMALL_NO_OEP

typedef struct
{
	OEPD_HEADER	oepd;
	void	*data;
	long	size;
} OEPD_DATAINFO;

#define MAX_OEP_DATA	64

long oep_senddata(int id,OEPD_DATAINFO *data,int type);

OEPD_DATAINFO *oep_newdata(long size,char *apname,char *apfile,char *obname,char *obfile,int obtype);
void oep_setdata(OEPD_DATAINFO *data,OEPD_HEADER *oepd);
boolean oep_updatedata(OEPD_DATAINFO *data);
boolean oep_killdata(OEPD_DATAINFO *data);
void oep_link_doc(OEPD_DATAINFO *data);
void oep_unlink_doc(OEPD_DATAINFO *data);

extern OEP oep;

#endif

/* MenÅ-Protokoll */

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
#define WM_DELETE		0x100c
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

#ifndef SMALL_NO_PAULA
int PaulaStop(void);
int PaulaShutDown(void);
int PaulaStart(char *args);
#endif

#ifndef MP_ACK
#define MP_ACK			0x4800
#define MP_NAK			0x4801
#define MP_START		0x4802
#define MP_STOP			0x4803
#define MP_SHUTDOWN		0x4804
#endif

/* wichtige Scan-Codes */

#ifdef __SOZOBONX__
#define KEY(s,a)	((s*256)|a)
#else
#define KEY(s,a)	((s<<8)|(unsigned char) a)
#endif

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
#define CTRLHOME	119

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

#ifndef _XAESFAST_A
#define K_SHIFT		(K_RSHIFT|K_LSHIFT)
#endif

/* Makros fÅr Mauszeiger */

#if defined(__MINT_LIB__) && !defined(__GNUC__)
#define BUSYBEE	BUSY_BEE
#endif

#ifndef __NoEGEM__
#define MouseArrow()		MouseForm(ARROW,NULL)
#define MouseCursor()		MouseForm(TEXT_CRSR,NULL)
#define MouseBee()			MouseForm(BUSYBEE,NULL)
#define MouseHourGlass()	MouseForm(HOURGLASS,NULL)
#define MousePointHand()	MouseForm(POINT_HAND,NULL)
#define MouseFlatHand()		MouseForm(FLAT_HAND,NULL)
#define MouseThinCross()	MouseForm(THIN_CROSS,NULL)
#define MouseThickCross()	MouseForm(THICK_CROSS,NULL)
#define MouseOutlineCross()	MouseForm(OUTLN_CROSS,NULL)

int mouse(int *x, int *y, int *state);
int MouseButton(void);
int MouseForm(int index,MFORM *user);
int MouseState(int *form, MFORM **user);
void MouseOn(void);
void MouseOff(void);
void MouseUpdate(int flag);
void ButtonUpdate(int flag);
void KeyUpdate(int flag);
#endif

#endif	/* __E_GEM_LIB__ */
