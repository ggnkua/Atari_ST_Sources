/************************************************************************/
/*																		*/
/*																		*/
/*		>>>>>>>>>>>  TOS - Magazin   Ausgabe 11/91  <<<<<<<<<<<<<		*/
/*																		*/
/*																		*/
/*		P R O J E C T	:	TOS ACCESSORY Spezial						*/
/*							TOSACC.ACC									*/
/*																		*/
/*		M O D U L E		:	TOSACC.H									*/
/*																		*/
/*																		*/
/*		Author			:	Jrgen Lietzow fr TOS-Magazin				*/
/*																		*/
/*		Last Update		:	28.08.91 (JL)								*/
/*																		*/
/*																		*/
/************************************************************************/

#include <stdio.h>

#if defined( __TURBOC__ )

	#include <vdi.h>
	#include <aes.h>
	#include <tos.h>

#else

	/* AES und VDI header */
	
	#error "Headerdateien von AES und VDI einbinden"
	
	#define Supexec(p)	xbios( 38, p )
	
#endif


#define		RESOURCE_FILE		"TOSACC.RSC"
#define		SAVE_FILE			"TOSACC.INF"
#define		MAX_TREES			7

#define		TIMER_ACCOPEN		0
#define		TIMER_ACCCLOSE		1
#define		MODE_TOPEN			2
#define		MODE_TCLOSE			3
#define		MODE_ACCCLOSE		4


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


#define	Bell()		putchar( '\a' )


/*	Hilfreich im Umgang mit Objekten */

#define TrPtr(n)		(trees[n])
#define ObPtr(t,o)		(TrPtr(t)+o)
#define IsEditable(ob)	( ((ob)->ob_flags & EDITABLE) && \
						  ((((ob)->ob_type & 0xff) == G_FTEXT) || \
						  (((ob)->ob_type & 0xff) == G_FBOXTEXT)) )
#define IsHidden(ob)	((ob)->ob_flags & HIDETREE)
#define IsSelectable(ob)((ob)->ob_flags & SELECTABLE)

#define	Select(ob)		((ob)->ob_state |= SELECTED)
#define	Deselect(ob)	((ob)->ob_state &= ~SELECTED)
#define IsSelected(ob)	((ob)->ob_state & SELECTED)

#define	Disable(ob)		((ob)->ob_state |= DISABLED)
#define Enable(ob)		((ob)->ob_state &= ~DISABLED)

#define	ObString(ob)	((ob)->ob_spec.free_string)
#define	Hide(ob)		((ob)->ob_flags |= HIDETREE)
#define	UnHide(ob)		((ob)->ob_flags &= ~HIDETREE)

#define	ObGRECT(ob)		((GRECT *) &(ob)->ob_x)


#define	Abs(a)			((a) < 0 ? -(a) : (a))
#define Max(a,b)		((a) < (b) ? (b) : (a))
#define Min(a,b)		((a) < (b) ? (a) : (b))


#define WIN_KIND		(NAME|CLOSER|MOVER|UPARROW|DNARROW|VSLIDE)


/*	Systemvariablen fr Traps */

#define	SysGEM		((int			(**)(int, long))	0x88)
#define	SysGEMDOS	((long	cdecl	(**)(int, ...))		0x84)
#define	SysBIOS		((long	cdecl	(**)(int, ...))		0xB4)
#define	SysXBIOS	((long	cdecl	(**)(int, ...))		0xB8)
#define	Sys200HZ	((void			(**)(void))			0x114)
#define	SysVSYNC	((void			(**)(void))			0x70)
#define	SysKEYBD	((void			(**)(void))			0x118)


typedef struct _event
{
		int			flags,
					bclicks,				/* Number of clicks to reach */
					bmask,					/* Mouse buttons to watch */
					bstate,					/* Mouse states to reach */
					m1flags,				/* recatangle #1 to watch */
					m1x, m1y,
					m1width, m1height,
					m2flags,				/* rectangle #2 to watch */
					m2x, m2y,
					m2width, m2height;
		int			tlocount,				/* Timer low word */
					thicount;				/* Timer high word */
		int			msgbuf[8];				/* Message buffer */

		int			evtype;
		int			mox, moy,				/* Mouse position */
					mstate,					/* Mouse button state */
					kstate,					/* Key state */
					kreturn,				/* Scancode | ASCII */
					mreturn;				/* Number of mouse clicks */
			
}	EVENT;

typedef struct
{
		int		slider;
		int		min;
		int		max;
		int		step;
		int		pos;
}	SLIDERBLK;

enum sltype
{
	SL_UP = 1,
	SL_BOX,
	SL_SLIDER,
	SL_DOWN
};


typedef struct
{
		int		x, y;
		int		obj;
		int		cmp;
		int		tx, ty;
		long	temp;
}	TPBLK;

typedef struct _edobj
{
		OBJECT	*tree;
		TEDINFO	*ted;
		int		edobj;
		int		pos;
		int		x, y;
}	WINDIA;

typedef	int (sub_fct)(OBJECT *tree, int obj, TPBLK *tb);

typedef struct _tool
{
		WINDIA	wd;
		int		winHdl;
		int		(*save)( struct _tool *tool, FILE *fp );
		int		(*mode)( struct _tool *tool, int type );
		int		(*event)( struct _tool *tool, int evtype, EVENT *ev, int top );
}	TOOL;

typedef TOOL	*(TINIT)( FILE *fp, int hdl );

typedef union
{
		TOOL	*tl;
		TINIT	*init;
}	TLIST;


#if !defined (__TOSACC__)

	extern	int		menuId;
	extern	int		vdiHdl;
	extern	int		physHdl;
	extern	int		winHdl;
	extern	int		work_in[11];
	extern	int		work_out[57];
	extern	int		xwork_out[57];
	extern	int		wchar, hchar, wbox, hbox;
	extern	OBJECT	*trees[];

#endif

/*
*	Von Modul TOSACC.C
*/

void	MouseOn( void );
void	MouseOff( void );
void	SetClip( const GRECT *gr, int flag );
void	FormCenter( OBJECT *tree );
int		ObjcDraw( OBJECT *tree, int start, int depth, GRECT *g );
void	RedrawWinObj( WINDIA *wd, int obj, int window );
int		WindCalc( int type, int kind, GRECT *src, GRECT *dest );
int		WindSet( int hdl, int type, GRECT *gr );
int		WindGet( int hdl, int type, GRECT *gr );
int		EventMulti( EVENT *ev );
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
void	OpenObjWin( OBJECT *tr, int kind, int hdl );


/*
*	Von Modul XDI_AL.C
*/

int		ScanTree( OBJECT *tree, int obj, TPBLK *tp, sub_fct *fct );
int		SaveScreen( OBJECT *tr, int obj, int frame, void **buffer,
					long *len );
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
void	ChangeEdField( WINDIA *wd, int new, int window );
int		DialButton( WINDIA *wd, int x, int y, int clicks, int window );
int		DialKeybd( WINDIA *wd, int key, int kstate, int window );

int		FormDo( OBJECT *tree, int startob );
int		FormAlert( int deflt, const char *fmt );







	