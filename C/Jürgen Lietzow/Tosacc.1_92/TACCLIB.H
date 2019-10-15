/************************************************************************/
/*																		*/
/*																		*/
/*		>>>>>>>>>>>  TOS - Magazin   Ausgabe 1/92  <<<<<<<<<<<<<		*/
/*																		*/
/*																		*/
/*		P R O J E C T	:	TOS ACCESSORY Spezial						*/
/*							TOSACC.ACC									*/
/*																		*/
/*		M O D U L E		:	TACCLIB.H									*/
/*																		*/
/*																		*/
/*		Author			:	Jrgen Lietzow fr TOS-Magazin				*/
/*																		*/
/*																		*/
/*		System/Compiler	:	Atari ST/TT, TOS 1.4, Pure C				*/
/*																		*/
/*		Last Update		:	21.11.91 (JL)								*/
/*																		*/
/*																		*/
/************************************************************************/

#if !defined __TACCLIB__

#define __TACCLIB__

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


/*	Nach OpenGEM() gesetzt */

#define		_Planes			xwork_out[4]
#define		MaxX			work_out[0]
#define 	MaxY			work_out[1]
#define		Colors			work_out[39]
#define		_Cw				wchar
#define		_Ch				hchar


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
 #define 	ObPtr(t,o)	((*((OBJECT ***)(&(_GemParBlk.global[5]))))[t]+o)
#else
 #define	TrPtr(t)	(((extern OBJECT[]*)rs_trindex)[t])
 #define 	ObPtr(t,o)	(((extern OBJECT[]*)rs_trindex)[t]+o)
#endif

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

#define ObTxt(ob)		((ob)->ob_spec.tedinfo->te_ptext)
#define	ObString(ob)	((ob)->ob_spec.free_string)
#define	ObGRECT(ob)		((GRECT *) &(ob)->ob_x)


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

typedef struct
{
		int		slider;			/* Nummer des Silder-Objekts */
		int		min;			/* Kleinster erlaubter Wert */
		int		max;			/* Gr”žter erlaubter Wert */
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
		int		pos;			/* Cursor Position */
		int		x, y;			/* Text Position */
}	WINDIA;

typedef	int (sub_fct)(OBJECT *tree, int obj, TPBLK *tb);


/*	Globale Variablen in TACCLIB.C definiert */

#if !defined (__TACCLIB)

	extern	int		menuId;				/* Accessory Meneintrag */
	extern	int		vdiHdl;				/* VDI Handle */
	extern	int		physHdl;			/* Physikalisches Handle */
	extern	int		applId;				/* Applikations id */
	extern	int		work_in[11];
	extern	int		work_out[57];
	extern	int		xwork_out[57];
	extern	int		wchar, hchar, wbox, hbox;

#endif

int		OpenGEM( void );
void	CloseGEM( void );

void	MouseOn( void );
void	MouseOff( void );

void	SetClip( const GRECT *gr, int flag );
void	FormCenter( OBJECT *tree );
int		ObjcDraw( OBJECT *tree, int start, int depth, GRECT *g );
void	FixImages( OBJECT *tree, int num );
void	RedrawWinObj( WINDIA *wd, int obj, int window );
int		WindCalc( int type, int kind, GRECT *src, GRECT *dest );
int		WindSet( int hdl, int type, GRECT *gr );
int		WindGet( int hdl, int type, GRECT *gr );
int		EventMulti( EVENT *ev );
char	*StrnCpy( char *dest, const char *src, size_t len );
int		rc_intersect( const GRECT *r1, GRECT *r2 );
int		PosSlider( OBJECT *tree, SLIDERBLK *sl, int new_pos );
int		SliderToPos( OBJECT *tree, SLIDERBLK *sl );
int		SliderPage( OBJECT *tree, SLIDERBLK *sl );
void	SliderToEdText( WINDIA *wd, int edobj, int pos, int window );
void	EdTextToSlider( WINDIA *wd, int edobj, SLIDERBLK *sl, int window );
int		HdlSlider( OBJECT *tree, SLIDERBLK *sl, int obj );
void	RedrawWin( const GRECT *gr, int hdl,
				   void (*Redraw)( GRECT *gr, int hdl ) );
void	MoveObjWin( GRECT *gr, WINDIA *wd, int window, int kind );
int		CreateWin( int kind );
int		OpenObjWin( OBJECT *tr, int kind, int hdl );

int		ScanTree( OBJECT *tree, int obj, TPBLK *tp, sub_fct *fct );
int		SaveScreen( const GRECT *gr, int frame, void **buffer, long *len );
void	RedrawScreen( void *buffer );
int		IsInParent( OBJECT *tree, int parent, int obj );
int		NextEditable( OBJECT *tree, int obj );
int		LastEditable( OBJECT *tree, int obj );
int		RightString( OBJECT *tree, int obj );
int		GetButton( OBJECT *tree, int key );
int		KeyToUpper( int key );

void	CursorChg( WINDIA *wd );
void	InitCurPos( WINDIA *wd );
void	InitEdObj( WINDIA *wd, OBJECT *tree, int obj );
int		ObjcInsChar( WINDIA *wd, int key, int window );
void	ChangeEdField( WINDIA *wd, int new, int window );
int		DialButton( WINDIA *wd, int x, int y, int clicks, int window );
int		DialKeybd( WINDIA *wd, int key, int kstate, int window );

int		FormDo( OBJECT *tree, int startob );
int		FormAlert( int deflt, const char *fmt );

#endif