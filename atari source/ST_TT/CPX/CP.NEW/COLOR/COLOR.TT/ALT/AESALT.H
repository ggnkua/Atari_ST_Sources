/*	aesalt.h - alternate AES bindings
 * Copyright 1990, Atari Corporation
 * ================================================================
 * 900129 kbad	Incorporated cgee updates, added enums for type
 *				checking, created WARGS union, added event macros
 * 890716 kbad	Modified object structure macros so as not to
 *				conflict with AES <taddr.h>
 * 890716 kbad	finito...
 */

#ifndef __AESALT__
#define __AESALT__
#ifndef __AES__
#include <aes.h>
#endif
#ifndef PORTAB_H
#include <stddef.h>
#include <sys\portab.h>
#endif


/* Definitions
 * ================================================================
 */

#define A_OK	TRUE
#define A_ERROR FALSE
#define A_CANCEL FALSE

/* nil object */
#define NIL		-1

/* Window info structure, demonstrated in textwind.c
 */
#ifdef WINFO
#error WINFO defined somewhere other than aesalt.h
#endif
typedef struct _winfo{
		struct _winfo *next;
		struct _winfo *prev;
		WORD	id;				/* window handle */
		GRECT	r;				/* window position */
		GRECT	work;			/* working rectangle */
		GRECT	save;			/* saved window position */
		BOOLEAN fulled;			/* window is fulled */
		WORD	kind;			/* wind_create flags */
		char	name[80];		/* window name */
		char	info[80];		/* window info */
		GRECT	phy;			/* physical coordinates */
		WORD 	wchar, hchar;	/* dimensions of a "character" */
		GRECT	vir;			/* virtual coordinates */
		void	*x;				/* extended info (app. specific) */
} WINFO;


/* MRETS struct for mouse parameters returned by
 * Evnt_button(), Evnt_mouse(), Evnt_multi(), Graf_mkstate()
 */
#ifdef MRETS
#error MRETS defined somewhere other than aesalt.h
#endif
typedef struct {
	WORD	x;
	WORD	y;
	WORD	buttons;
	WORD	kstate;
} MRETS;

/* flags for objc_edit(), as enum for type checking */
#undef ED_START
#undef ED_INIT
#undef ED_CHAR
#undef ED_END
typedef enum {
	ED_START=0,
	ED_INIT,
	ED_CHAR,
	ED_END
} ED_FLAG;

/* flags for form_dial(), as enum for type checking */
#undef FMD_START
#undef FMD_GROW
#undef FMD_SHRINK
#undef FMD_FINISH
typedef enum {
	FMD_START=0,
	FMD_GROW,
	FMD_SHRINK,
	FMD_FINISH
} FMD_FLAG;

/* flags for wind_set/get, as enum for type checking */
#undef WF_KIND
#undef WF_NAME
#undef WF_INFO
#undef WF_WORKXYWH
#undef WF_CURRXYWH
#undef WF_PREVXYWH
#undef WF_FULLXYWH
#undef WF_HSLIDE
#undef WF_VSLIDE
#undef WF_TOP
#undef WF_FIRSTXYWH
#undef WF_NEXTXYWH
#undef WF_RESVD
#undef WF_NEWDESK
#undef WF_HSLSIZE
#undef WF_VSLSIZE
#undef WF_SCREEN
typedef enum {
	WF_KIND=1,
	WF_NAME,
	WF_INFO,
	WF_WORKXYWH,
	WF_CURRXYWH,
	WF_PREVXYWH,
	WF_FULLXYWH,
	WF_HSLIDE,
	WF_VSLIDE,
	WF_TOP,
	WF_FIRSTXYWH,
	WF_NEXTXYWH,
	WF_RESVD,
	WF_NEWDESK,
	WF_HSLSIZE,
	WF_VSLSIZE,
	WF_SCREEN
} WFLAG;

/* wind_get/set() args */
typedef union {
	char 	*name;		/* NAME */
	char 	*info;		/* INFO */
	GRECT	r;			/* WORK, CURR, PREV, FULL, FIRST, NEXT */
	WORD	position;	/* HSLIDE, VSLIDE */
	WORD	id;			/* TOP */
	struct {
		OBJECT	*tree;
		WORD	startob;
	} newdesk;			/* NEWDESK */
	WORD	size;		/* HSLSIZE, VSLSIZE */
	void	*buf;		/* SCREEN */
} WARGS;

#define NOBOX 0, 0, 0, 0	/* some GEM routines need coordinates */
#define MAX_WINDOWS 7		/* DO NOT RELY ON THIS NUMBER!!!
							 * it will go away someday.
							 */

/* Event_multi() returns, require `WORD event' declaration
 * ================================================================
 */
#define EvKey()		(event & MU_KEYBD)
#define EvButton()	(event & MU_BUTTON)
#define EvM1()		(event & MU_M1)
#define EvM2()		(event & MU_M2)
#define EvMessage()	(event & MU_MESAG)
#define EvTimer()	(event & MU_TIMER)

/* Message buffer defines, require `WORD (msg)[8]' declaration
 * ================================================================
 */
#define MsgType(msg)	((msg)[0])
#define MsgSender(msg)	((msg)[1])
#define MsgExtra(msg)	((msg)[2])
#define MnTitle(msg)	((msg)[3])
#define MnItem(msg)		((msg)[4])
#define WmId(msg)		((msg)[3])
#define WmRect(msg)		(*(GRECT *)&((msg)[4]))
#define WmAction(msg)	((msg)[4])
#define WmSlider(msg)	((msg)[4])
#define AcPosition(msg)	((msg)[3])
#define AcOpenId(msg)	((msg)[4])
#define AcCloseId(msg)	((msg)[3])

/*
 * New message types
 */
#define	KEY_CODE	53

/* Object structure macros, useful in dealing with forms
 * ================================================================
 * `tree' must be an OBJECT *
 */
#define SPECIAL		0x40 /* user defined object state */

#define ObNext(obj)		( tree[(obj)].ob_next )
#define ObHead(obj)		( tree[(obj)].ob_head )
#define ObTail(obj)		( tree[(obj)].ob_tail )
#define ObFlags(obj)	( tree[(obj)].ob_flags )
#define ObState(obj)	( tree[(obj)].ob_state )
#define ObSpec(obj)		( tree[(obj)].ob_spec )
#define TedText(obj)	( tree[(obj)].ob_spec.tedinfo->te_ptext )
#define TedTemp(obj)	( tree[(obj)].ob_spec.tedinfo->te_ptmplt )
#define TedLen(obj)		( tree[(obj)].ob_spec.tedinfo->te_txtlen )
#define TedJust( obj )  ( tree[(obj)].ob_spec.tedinfo->te_just )
#define TedFont( obj )  ( tree[(obj)].ob_spec.tedinfo->te_font )
#define TedColor( obj ) ( tree[(obj)].ob_spec.tedinfo->te_color )

#define ObString(obj)	( tree[(obj)].ob_spec.free_string )
#define ObX(obj) 		( tree[(obj)].ob_x )
#define ObY(obj) 		( tree[(obj)].ob_y )
#define ObW(obj) 		( tree[(obj)].ob_width )
#define ObH(obj) 		( tree[(obj)].ob_height )
#define ObRect(obj) 	( *(GRECT *)(&(tree[(obj)].ob_x)) )

#define IconData( obj )   ( tree[(obj)].ob_spec.iconblk->ib_pdata )
#define IconText( obj )   ( tree[(obj)].ob_spec.iconblk->ib_ptext )
#define IconWidth( obj )  ( tree[(obj)].ob_spec.iconblk->ib_wicon )
#define IconHeight( obj ) ( tree[(obj)].ob_spec.iconblk->ib_hicon )
#define IconColor( obj )  ( tree[(obj)].ob_spec.iconblk->ib_char )

#define Set_tree(obj)		( rsrc_gaddr(R_TREE,(obj),&tree) )
#define Set_alert(num,s)	( rsrc_gaddr(R_STRING,(num),&((OBJECT *)(s)) )
#define Set_button(num,s)	( rsrc_gaddr(R_STRING,(num),&((OBJECT *)(s)) )

#define	IsHidden(obj)			( ObFlags(obj) & HIDETREE )
#define IsSelected(obj)			( ObState(obj) & SELECTED )
#define IsEditable(obj)			( ObFlags(obj) & EDITABLE )
#define IsSpecial(obj)			( ObState(obj) & SPECIAL  )
#define ActiveTree( newtree )	( tree = newtree )
#define IsDisabled(obj)			( ObState(obj) & DISABLED )

/* macros ok when object is not on screen
 */
#define HideObj(obj)		( ObFlags(obj) |= HIDETREE )
#define ShowObj(obj)		( ObFlags(obj) &= ~HIDETREE )
#define MakeEditable(obj)	( ObFlags(obj) |= EDITABLE )
#define NoEdit(obj)			( ObFlags(obj) &= ~EDITABLE )
#define Select(obj)			( ObState(obj) |= SELECTED )
#define Deselect(obj)		( ObState(obj) &= ~SELECTED )
#define Disable(obj)		( ObState(obj) |= DISABLED )
#define Enable(obj)			( ObState(obj) &= ~DISABLED )
#define MarkObj(obj)		( ObState(obj) |= SPECIAL  )
#define UnmarkObj(obj)		( ObState(obj) &= ~SPECIAL  )
#define SetNormal(obj)		( ObState(obj) = NORMAL	   )
#define MakeDefault(obj)	( ObFlags(obj) |= DEFAULT )
#define NoDefault(obj)		( ObFlags(obj) &= ~DEFAULT )


/* use these when object is on screen - see Objc_change below
 */
#define deselect( tree, obj ) \
	Objc_change( (tree), (obj), NULL, (ObState(obj) & ~SELECTED), 1 )
#define select( tree, obj ) \
	Objc_change( (tree), (obj), NULL, (ObState(obj) | SELECTED), 1 )
#define enable( tree, obj ) \
	Objc_change( (tree), (obj), NULL, (ObState(obj) & ~DISABLED), 1 )
#define disable( tree, obj ) \
	Objc_change( (tree), (obj), NULL, (ObState(obj) | DISABLED), 1 )


/* Functions not in TC bindings
 * ================================================================
 */

/* min & max - used by rc_functions
 * self explanatory (I hope!)
 */
WORD min( WORD a, WORD b );
WORD max( WORD a, WORD b );

/* rc (rect) functions
 */
void	rc_2xy( const GRECT *r, WORD *pxy );
/* Convert GRECT to VDI pxy array.
*/
void	rc_center( const GRECT *rs, GRECT *rd, WORD xoffset, WORD yoffset );
/* Center `rd' within `rs', offset by `xoffset' and `yoffset'
 */

/* -WARNING- Psychotic typecasts! */
#define rc_equal( r1, r2 ) \
	( *((long *)(r1)) == *((long *)(r2)) && \
	  *((long *)(&((r1)->g_w))) == *((long *)(&((r2)->g_w))) )
#define rc_empty( r ) ( !*(long *)(&((r)->g_w)) )

void	rc_inset( GRECT *r, WORD xoffset, WORD yoffset );
/* Inset `r' within itself by `xoffset' and `yoffset'
 */
BOOLEAN	rc_intersect( const GRECT *rs, GRECT *rd );
/* If `rs' and `rd' intersect, change `rd' to the intersection rect,
 * and return TRUE.  Otherwise, leave `rd' alone and return FALSE.
 */
void	rc_union( const GRECT *rs, GRECT *rd );
/* Change `rd' to the union of `rs' and `rd'.
 */

/* xy functions
 */
void	xy_2rect( const WORD *pxy, GRECT *r );
/* Convert VDI pxy array to rect
*/
BOOLEAN	xy_inrect( WORD x, WORD y, GRECT *r );
/* Return TRUE if coordinates are within r
*/



/* File selector utility functions
 * ================================================================
 */

void	fsel_init( void );
/* initialize file selector utility module
 */ 

WORD	fsel_name( BOOLEAN remember, char *name, const char *searchmask,
					const char *label );
/* Handle file and/or path selection.
 *
 * If `remember' is TRUE, the file selector module remembers
 * the path chosen by the user.
 * `name' must point to a string at least 128 characters long.
 *
 *	If path\filename supplied in `name', use it as default,
 *	  (NOTE: if caller supplies path\filename, there MUST be a filename,
 *		or the path must end in a backslash, otherwise fsel_name will
 *		think that the end of the path is the filename)
 * 	else use remembered default path.
 *  `searchmask' is default file mask for the file selector top line.
 *	If `searchmask' is NULL and a default path\filename is supplied,
 *	  use extender of filename as searchmask (*.ext), else use ``*.*''.
 *
 *	If `label' is non-NULL, use it as a prompt string for the file selector
 *	(using fsel_exinput if available, or a special dialog for older TOSes).
 *
 *	Return conditions:
 *	1)	If fsel_input returns an error, null the string in `name',
 *		and return the error code.
 *	1)	If user selects OK, copy full path\filename to `name',
 *		and return A_OK (TRUE).
 *	2)	If user selects OK with no file, copy backslash terminated path to
 *		`name' and return A_CANCEL (FALSE).
 *	3)	If user selects Cancel, null the string in `name'
 *		and return A_CANCEL.
 */

WORD	fsel_load( BOOLEAN remember, char *name, const char *searchmask,
					const char *label, void **buffer );
/* Select a file, Malloc a buffer for it, and read the file into the buffer.
 * Parameters as for fsel_name(); the address of the Malloc'ed
 * buffer is passed back in `buffer'.  Return any errors in buffer Malloc,
 * or Fopen/Fread.
 */



/* Warped AES bindings
 * ================================================================
 * Unless otherwise noted, these behave the same way as the
 * usual AES bindings for these functions.
 */


/* Event manager functions
 */
WORD	Evnt_button( WORD clicks, WORD bmask, WORD bstate, MRETS *m );
void	Evnt_mouse( const MOBLK *mblock, MRETS *m );
WORD	Evnt_multi( WORD flags, WORD clicks, WORD bmask, WORD bstate,
					const MOBLK *m1, const MOBLK *m2, WORD *msgbuf, long time,
					MRETS *m, WORD *key, WORD *nclicks );
/* Evnt_multi input struct pointers (m1, m2) may be NULL, but
 * output pointers (msgbuf, m, key, nclicks) must point to the
 * appropriate things
 */
void	Evnt_timer( long time );


/* Form manager functions
 */
void	Form_center( const OBJECT *tree, GRECT *r );
BOOLEAN Form_dial( FMD_FLAG flag, const GRECT *small, const GRECT *large );


/* Graphics manager functions
 */
BOOLEAN Graf_dragbox( GRECT *box, const GRECT *bound );
/* Pass start rect of box in `box', returns end rect of box in `box'.
 */
BOOLEAN	Graf_growbox( const GRECT *small, const GRECT *large );
#define Graf_movebox Graf_mbox
BOOLEAN	Graf_mbox( const GRECT *box, WORD endx, WORD endy );
void	Graf_mkstate( MRETS *m );
BOOLEAN	Graf_rubberbox( GRECT *r );
/* Pass min rect of box in `r', returns end rect of box in `r'.
 */
BOOLEAN	Graf_shrinkbox( const GRECT *small, const GRECT *large );


/* Object manager functions
 * If `clip' is NULL in Objc_draw or _change, the binding will calculate
 * a clip rectangle for you, based on the extent of the object.
 */
BOOLEAN Objc_change( OBJECT *tree, WORD object, const GRECT *clip,
						WORD state, BOOLEAN redraw );
BOOLEAN Objc_draw( const OBJECT *tree, WORD startob, WORD depth,
					const GRECT *clip );

/* Window manager functions
 */
void	Wind_calc( WORD inout, WORD kind, const GRECT *in, GRECT *out );
/* Wind_calc is implemented as a function rather than an OS call, and
 * requires that you declare global gl_wbox and gl_hbox,
 * getting their values from graf_handle().
 */
WORD	Wind_create( WORD kind, const GRECT *fullsize );
BOOLEAN	Wind_get( WORD id, WFLAG which, WARGS *args );
BOOLEAN	Wind_open( WORD id, const GRECT *size );
BOOLEAN	Wind_set( WORD id, WFLAG which, const WARGS *args );

#endif __AESALT__
