/************************************************************************/
/*																		*/
/*																		*/
/*		>>>>>>>>>>>  TOS - Magazin   Ausgabe 3/92  <<<<<<<<<<<<<		*/
/*																		*/
/*																		*/
/*		P R O J E C T	:	TOS ACCESSORY Spezial						*/
/*							TOSACC.ACC									*/
/*																		*/
/*		M O D U L E		:	TGEMLIB.H									*/
/*																		*/
/*																		*/
/*		Author			:	Jrgen Lietzow fr TOS-Magazin				*/
/*																		*/
/*		System/Compiler	:	Atari ST/TT, TOS 1.4, Pure C				*/
/*																		*/
/*		Last Update		:	31.01.92 (JL)								*/
/*																		*/
/*																		*/
/************************************************************************/

#if !defined __TGEMLIB__

#define __TGEMLIB__

/*
	>>RESOURCE_FILE<< sollte definiert sein, wenn eine Resource-Datei
	mit rsrc_load() gelesen wird.
*/

#include <stdio.h>

#if defined( __TURBOC__ )

	#include <vdi.h>
	#include <aes.h>
	#include <tos.h>

#else

	/* AES und VDI header */
	
	#error "Headerdateien von AES und VDI in TACCLIB.H einbinden"
	
	#define Supexec(p)	xbios( 38, p )
	
#endif

#define		MAX_OWN			100

#define		MAX_STRLEN	31
#define		MAX_BUTLEN	10

#define		AL_BUFLEN	1024

/*	Nach OpenGEM() gesetzt */

#define		_Planes			gemv.xwork_out[4]
#define		MaxX			gemv.work_out[0]
#define 	MaxY			gemv.work_out[1]
#define		Colors			gemv.work_out[39]
#define		_Cw				gemv.wchar
#define		_Ch				gemv.hchar


/*	line types */

#define	SOLID				1
#define	LONGDASH			2
#define	DOT					3
#define	DASHDOT				4
#define	DASH				5
#define	DASH2DOT			6
#define	USERLINE			7

/*	line ends */

#define	SQUARED				0
#define	ARROWED				1
#define	ROUNDED				2

/*	polymarker types */

#define	PM_DOT				1
#define	PM_PLUS				2
#define	PM_ASTERISK			3
#define	PM_SQUARE			4
#define	PM_DIAGCROSS		5
#define	PM_DIAMOND			6

/*	text effects */

#define	TXT_NORMAL			0x0000
#define	TXT_THICKENED		0x0001
#define	TXT_LIGHT			0x0002
#define	TXT_SKEWED			0x0004
#define	TXT_UNDERLINED		0x0008
#define	TXT_OUTLINED		0x0010
#define	TXT_SHADOWED		0x0020

/*	horizontal text alignment */

#define	ALI_LEFT			0
#define	ALI_CENTER			1
#define	ALI_RIGHT			2

/*	vertical text alignment */

#define	ALI_BASE			0
#define	ALI_HALF			1
#define	ALI_ASCENT			2
#define	ALI_BOTTOM			3
#define	ALI_DESCENT			4
#define	ALI_TOP				5

/*	Scan- und Asciicode; zurckgegeben von evnt_multi() */
 
#define	SHIFT		0x0003
#define	CONTROL		0x0004
#define	ALT			0x0008

#define ESC			0x011b
#define BACKSPACE	0x0e08
#define DELETE		0x537f
#define INSERT		0x5200
#define RETURN		0x1c0d
#define ENTER		0x720d
#define C_UP		0x4800
#define C_LEFT		0x4b00
#define C_RIGHT		0x4d00
#define C_DOWN		0x5000
#define SHFT_CL		0x4b34
#define SHFT_CR		0x4d36
#define SHFT_HOME	0x4737
#define HOME		0x4700
#define CNTRL_S		0x1f13
#define CNTRL_U		0x1615

#define	PLUS		0x1b2b
#define ZPLUS		0x4e2b
#define MINUS		0x352d
#define ZMINUS		0x4a2d


#define	Bell()			putchar( '\a' )


/*	Hilfreich im Umgang mit Objekten */


#if defined ( RESOURCE_FILE )
 #define	TrPtr(t)	((*((OBJECT ***)(&(_GemParBlk.global[5]))))[t])
#else
 #define	TrPtr(t)	(((extern OBJECT[]*)rs_trindex)[t])
#endif

#define		ObPtr(t,o)	(TrPtr(t)+(o))

#define IsEditable(ob)	( ((ob)->ob_flags & EDITABLE) && \
						  ((((ob)->ob_type & 0xff) == G_FTEXT) || \
						  (((ob)->ob_type & 0xff) == G_FBOXTEXT)) )

#define IsSelectable(ob)((ob)->ob_flags & SELECTABLE)

#define	Select(ob)		((ob)->ob_state |= SELECTED)
#define	Deselect(ob)	((ob)->ob_state &= ~SELECTED)
#define IsSelected(ob)	((ob)->ob_state & SELECTED)

#define IsEnabled(ob)	(!((ob)->ob_state & DISABLED))
#define	Disable(ob)		((ob)->ob_state |= DISABLED)
#define Enable(ob)		((ob)->ob_state &= ~DISABLED)

#define	Hide(ob)		((ob)->ob_flags |= HIDETREE)
#define	UnHide(ob)		((ob)->ob_flags &= ~HIDETREE)
#define IsHidden(ob)	((ob)->ob_flags & HIDETREE)

#define IsRadio(ob)		((ob)->ob_flags & RBUTTON)

#define ObTxt(ob)		((ob)->ob_spec.tedinfo->te_ptext)
#define	ObString(ob)	((ob)->ob_spec.free_string)
#define	ObGRECT(ob)		((GRECT *) &(ob)->ob_x)

#define	MInGrect(x,y,g)	( (x) >= (g)->g_x && (y) >= (g)->g_y && \
						  (x) <  (g)->g_x + (g)->g_w && \
						  (y) <  (g)->g_y + (g)->g_h )
#define ObjInSl(o,sl)	( (o) >= (sl) && (o) < ((sl) + 5) )						  

#define	Abs(a)			((a) < 0 ? -(a) : (a))
#define Max(a,b)		((a) < (b) ? (b) : (a))
#define Min(a,b)		((a) < (b) ? (a) : (b))


/*	Systemvariablen fr Traps */

#define	SysGEM		((int	volatile		(**)(int, long))	0x88)
#define	SysGEMDOS	((long	volatile cdecl	(**)(int, ...))		0x84)
#define	SysBIOS		((long	volatile cdecl	(**)(int, ...))		0xB4)
#define	SysXBIOS	((long	volatile cdecl	(**)(int, ...))		0xB8)
#define	Sys200HZ	((void	volatile		(**)(void))			0x114)
#define	SysVSYNC	((void	volatile		(**)(void))			0x70)
#define	SysKEYBD	((void	volatile		(**)(void))			0x118)

#define	_p_cookies	(*(long **) 0x5A0)

#if !defined (__PUREC__)

typedef struct 
{
		int			ev_mflags,
					ev_mbclicks,			/* Number of clicks to reach */
					ev_bmask,				/* Mouse buttons to watch */
					ev_bstate,				/* Mouse states to reach */
					ev_mmm1flags,			/* rectangle #1 to watch */
					ev_mm1x, ev_mm1y,
					ev_mm1width, ev_mm1height,
					ev_mm2flags,			/* rectangle #2 to watch */
					ev_mm2x, ev_mm2y,
					ev_mm2width, ev_mm2height;
		int			ev_mtlocount,			/* Timer low word */
					ev_mthicount;			/* Timer high word */

		int			ev_mwich;				/* Event type returned */
		int			ev_mmox, ev_mmoy,		/* Mouse position */
					ev_mmobutton,			/* Mouse button state */
					ev_mmokstate,			/* Key state */
					ev_mkreturn,			/* Scancode | ASCII */
					ev_mbreturn;			/* Number of mouse clicks */
		int			ev_mmgpbuf[8];			/* Message buffer */
}	EVENT;

#endif


typedef struct
{
	unsigned frcol	: 4;
	unsigned tecol	: 4;
	unsigned trans	: 1;
	unsigned patt	: 3;
	unsigned inter	: 4;
} TEDCOL;

typedef struct _sliderblk
{
		int		slider;			/* Nummer des Silder-Objekts */
		int		num;			/* Anzahl der auszuwertenden positionen */
		int		(*sl_handle)( OBJECT *tree, struct _sliderblk *sl );
		int		min;			/* Kleinster erlaubter Wert */
		int		step;			/* Z„hler fr n„chsten Wert */
		int		pos;			/* Aktueller Wert */
}	SLIDERBLK;

enum OBSLIDER
{
	SL_UP = 1,
	SL_BOX,
	SL_SLIDER,
	SL_DOWN
};

/*	Gr”že des History-Buffers */

#define	MAX_TLEN	80
#define MAX_HIST	20


typedef struct
{
		char	valid[MAX_TLEN];
		char	text[MAX_TLEN];
}	HIST;


/*	Fr ScanTree() */

typedef struct
{
		int		x, y;			/* Absolute Position des Objektes */
								/* wird von ScanTree() gesetzt */
		int		obj;
		int		cmp;
		int		tx, ty;
		long	temp;
}	TPBLK;

typedef struct _windia
{
		OBJECT	*tree;
		TEDINFO	*ted;
		int		edobj;
		int		pos;			/*	Cursor Position */
		int		x, y;			/*	Text Position */
		int		extflag;		/*	Selektierte Objekte auch behandeln	*/
		int		window;
}	WINDIA;

typedef	int (sub_fct)(OBJECT *tree, int obj, TPBLK *tb);

typedef struct
{
		int		work_in[11];
		int		work_out[57];
		int		xwork_out[57];
		int		applId;				/* Applikations id */
		int		vdiHdl;				/* VDI handle */
		int		physHdl;			/* physikalisches VDI handle */
		int		menuId;				/* Meneintrag */
		int		wchar, hchar, wbox, hbox;
		GRECT	desk;
		GRECT	work;
		void	*gemBuf;			/* Buffer fr Alerts und „hnliches */
		long	gemBufLen;
		int		gemMalloc;
}	GEMVARS;

typedef struct
{
		char	path[128];
		char	fname[14];
		char	fspec[14];
}	FILE_SPEC;

/* Fr die Alertbox */

typedef struct
{
		int		old;
		int		new;
		char	fmt[2];
}	ALERTS;

typedef struct
{
		int		buf_len;
		int		pos;
		int		num;
		ALERTS	*alerts;
}	AL_INF;


/*	Globale Variablen in HIGHGEM.C definiert */

#if !defined (__HIGHGEM)

	extern	GEMVARS	gemv;
	extern	int		xobFlag;
	extern	char	alBuf;
	extern	AL_INF	alInf;

#endif


/*	from module HIGHGEM.C	*/

int		OpenGEM( void );
void	CloseGEM( void );
void	OpenXGEM( void );
void	SetClip( const GRECT *gr, int flag );
int		ObjcDraw( OBJECT *tree, int start, int depth, const GRECT *g );
void	*GetCookie( long name );
void	TransMFDB( int *saddr, int sw, int *daddr, int dw, int h );
void	RedrawWinObj( WINDIA *wd, int obj, GRECT *gr );
int		SetFlags( WINDIA *wd, int *ol, int num, long bits, int draw, int flag );
long	SetBits( WINDIA *wd, int *ol, int num, int flag );

int		SlAbsToRel( SLIDERBLK *sl, int abs );
int		SlRelToAbs( SLIDERBLK *sl, int rel );
int		SlSetSize( OBJECT *tree, SLIDERBLK *sl );
int		SlAbsPage( OBJECT *tree, SLIDERBLK *sl );
int		SlSetAbsPos( OBJECT *tree, SLIDERBLK *sl, int pos );
int		SlGetAbsPos( OBJECT *tree, SLIDERBLK *sl );
void	SlDigit( OBJECT *tree, SLIDERBLK *sl, int num );
int		HdlSlider( WINDIA *wd, SLIDERBLK *sl, int obj );
int		SlInit( OBJECT *tree, SLIDERBLK *sl, int rel );

void	RedrawWin( const GRECT *gr, int hdl, void (*Redraw)( const GRECT *gr, int hdl ) );
void	MoveObjWin( GRECT *gr, WINDIA *wd, int kind );
long	ScreenSize( const GRECT *gr );
void	SaveScreen( const GRECT *gr, void *buffer );
void	RedrawScreen( void *buffer );
void	CursorChg( WINDIA *wd );
void	InitCurPos( WINDIA *wd );
void	InitEdObj( WINDIA *wd, OBJECT *tree, int obj );
void	ChangeEdField( WINDIA *wd, int new );
int		GetValid( int key, char *valid, int pos );
void	RedrawEdObj( WINDIA *wd );
int		ObjcInsChar( WINDIA *wd, int key );
int		ObjcEdit( OBJECT *tree, int edobj, int key, int *pos, int type );
int		DialButton( WINDIA *wd, int x, int y, int clicks );
int		DialKeybd( WINDIA *wd, int key, int kstate );
int		FormEvent( WINDIA *wd, EVENT *ev );
int		FormDo( OBJECT *tree, int startob );
int		_FormAlert( int deflt, const char *fmt );
int		FormAlert( int deflt, const char *fmt );
void	DelAlerts( void );


/*	from module LOWGEM.C	*/

void	MouseOn( void );
void	MouseOff( void );
void	FormCenter( OBJECT *tree );
void	FormDial( int flag, GRECT *ltl, GRECT *big );
int		set_hchar( int vhdl, int hchar );
void	line_default( int vhdl );
void	text_default( int vhdl, int hchar );
void	DrawFrame( GRECT *fr, int frame, int vhdl );
void	AbsObj( OBJECT *tree, int obj, GRECT *abs );
void	RelObj( OBJECT *tree, int obj, const GRECT *abs );
int		WindCalc( int type, int kind, GRECT *src, GRECT *dest );
int		WindSet( int hdl, int type, GRECT *gr );
int		WindGet( int hdl, int type, GRECT *gr );
#if !defined (__PUREC__)
int		EvntMulti( EVENT *ev );
#endif
int		EventMulti( EVENT *ev );
void	InitFileSpec( FILE_SPEC *fs, char *path, char *name, char *spec );
int		FselInput( FILE_SPEC *fs, char *mes );
char	*StrnCpy( char *dest, const char *src, size_t len );
void	FixImages( OBJECT *tree, int num );
void	FixTree( OBJECT *tree );
int		rc_intersect( const GRECT *r1, GRECT *r2 );
int		rc_constrain( const GRECT *r1, GRECT *r2 );
void	rc_merge( const GRECT *r1, GRECT *r2 );
void	rc_frame( GRECT *r, int frame );
void	rc_rest( const GRECT *frame, const GRECT *part, GRECT gr_list[5] );
int		rc_center( const GRECT *fr, GRECT *box );
int		CreateWin( int kind );
int		OpenObjWin( OBJECT *tr, int kind, int hdl );
int		ScanTree( OBJECT *tree, int obj, TPBLK *tp, sub_fct *fct );
int		ObjcParent( OBJECT *tr, int obj );
int		IsInParent( OBJECT *tree, int parent, int obj );
int		NextEditable( OBJECT *tree, int obj );
int		LastEditable( OBJECT *tree, int obj );
int		RightString( OBJECT *tree, int obj );
int		GetButton( OBJECT *tree, int key );
int		IsFirstUpper( const char *str, int key );
int		KeyToUpper( int key );

#endif