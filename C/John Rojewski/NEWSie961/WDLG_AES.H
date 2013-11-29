/*      WDLG_AES.H   was  AES.H

        GEM AES Definitions

        Copyright (c) Borland International 1990
        All Rights Reserved.
*/


#if  !defined( __AES__ )
#define __AES__
#define __MTAES__

/*--- Macro for prototyping ---*/
#ifdef __PUREC__
#  define ___CDECL cdecl
#else
#  define ___CDECL
#  define cdecl ___CDECL
#endif

#include <portab.h>

/****** GEMparams *******************************************************/

extern  int       _app;

int  vq_aes( void );

typedef struct
{
	WORD *contrl;
	WORD *global;
	WORD *intin;
	WORD *intout;
	void **addrin;
	void **addrout;
} AESPB;

typedef struct
{
	WORD contrl[5];
	WORD intin[16];
	WORD intout[16];
	void *addrin[16];
	void *addrout[16];
} PARMDATA;

typedef struct {
	WORD x;
	WORD y;
	WORD bstate;
	WORD kstate;
} EVNTDATA;

typedef struct
{
        int     g_x;
        int     g_y;
        int     g_w;
        int     g_h;
} GRECT;

typedef struct
{
        int             ob_next;        /* -> object's next sibling     */
        int             ob_head;        /* -> head of object's children */
        int             ob_tail;        /* -> tail of object's children */
        unsigned int    ob_type;        /* object type: BOX, CHAR,...   */
        unsigned int    ob_flags;       /* object flags                 */
        unsigned int    ob_state;       /* state: SELECTED, OPEN, ...   */
        void	*       ob_spec;        /* "out": -> anything else      */
        int             ob_x;           /* upper left corner of object  */
        int             ob_y;           /* upper left corner of object  */
        int             ob_width;       /* object width                 */
        int             ob_height;      /* object height                */
} OBJECT;


/* extern void _crystal( AESPB *aespb ); */



/****** Wdialog definitions ***********************************************/
typedef struct
{
	WORD	mwhich;
	WORD	mx;
	WORD	my;
	WORD	mbutton;
	WORD	kstate;
	WORD	key;
	WORD	mclicks;
	WORD	reserved[9];
	WORD	msg[16];
} EVNT;
				
typedef	int	(cdecl *HNDL_OBJ)( void *dialog, EVNT *events, WORD obj, WORD clicks, void *data );
/*typedef	int	(cdecl *HNDL_OBJ)( DIALOG *dialog, EVNT *events, int obj, int clicks, void *data ); */

extern	void	*wdlg_create( HNDL_OBJ handle_exit, OBJECT *tree, void *user_data, WORD code, void *data, WORD flags );

extern	WORD	wdlg_open( void *dialog, BYTE *title, WORD kind, WORD x, WORD y, WORD code, void *data );
extern	WORD	wdlg_close( void *dialog );
extern	WORD	wdlg_delete( void *dialog );

extern	WORD	wdlg_get_tree( void *dialog, OBJECT **tree, GRECT *r );
extern	WORD	wdlg_get_edit( void *dialog, WORD *cursor );
extern	void	*wdlg_get_udata( void *dialog );
extern	WORD	wdlg_get_handle( void *dialog );

extern	WORD	wdlg_set_edit( void *dialog, WORD obj );
extern	WORD	wdlg_set_tree( void *dialog, OBJECT *tree );
extern	WORD	wdlg_set_size( void *dialog, GRECT *size );
extern	WORD	wdlg_set_iconify( void *dialog, GRECT *g,
					char *title, OBJECT *tree, WORD obj );
extern	WORD	wdlg_set_uniconify( void *dialog, GRECT *g,
					char *title, OBJECT *tree );

extern	WORD	wdlg_evnt( void *dialog, EVNT *events );
extern	void	wdlg_redraw( void *dialog, GRECT *rect, WORD obj, WORD depth );

/* Definitionen fÅr <flags> */
#define	WDLG_BKGD	1													/* Hintergrundbedienung zulassen */

/* Funktionsnummern fÅr <obj> bei handle_exit(...) */
#define	HNDL_INIT	-1		/* Dialog initialisieren */
#define	HNDL_MESG	-2		/* Dialog initialisieren */
#define	HNDL_CLSD	-3		/* Dialogfenster wurde geschlossen */
#define	HNDL_OPEN	-5		/* Dialog-Initialisierung abschlieûen (zweiter Aufruf am Ende von wdlg_init) */
#define	HNDL_EDIT	-6		/* Zeichen fÅr ein Edit-Feld ÅberprÅfen */
#define	HNDL_EDDN	-7		/* Zeichen wurde ins Edit-Feld eingetragen */
#define	HNDL_EDCH	-8		/* Edit-Feld wurde gewechselt */
#define	HNDL_MOVE	-9		/* Dialog wurde verschoben */
#define	HNDL_TOPW	-10		/* Dialog-Fenster ist nach oben gekommen */
#define	HNDL_UNTP	-11		/* Dialog-Fenster ist nicht aktiv */


#endif