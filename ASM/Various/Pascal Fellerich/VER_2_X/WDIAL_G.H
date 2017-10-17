/*typedef struct
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
*/
typedef	void	*DIALOG;
						
typedef	WORD	(cdecl *HNDL_OBJ)( DIALOG *dialog, EVNT *events, WORD obj, WORD clicks, void *data );

extern	void	*wdlg_create( HNDL_OBJ handle_exit, OBJECT *tree, void *user_data, WORD code, void *data, WORD flags );
extern	WORD	wdlg_open( DIALOG *dialog, BYTE *title, WORD kind, WORD x, WORD y, WORD code, void *data );
extern	WORD	wdlg_close( DIALOG *dialog );
extern	WORD	wdlg_delete( DIALOG *dialog );

extern	WORD	wdlg_get_tree( DIALOG *dialog, OBJECT **tree, GRECT *r );
extern	WORD	wdlg_get_edit( DIALOG *dialog, WORD *cursor );
extern	void	*wdlg_get_udata( DIALOG *dialog );
extern	WORD	wdlg_get_handle( DIALOG *dialog );

extern	WORD	wdlg_set_edit( DIALOG *dialog, WORD obj );
extern	WORD	wdlg_set_tree( DIALOG *dialog, OBJECT *tree );
extern	WORD	wdlg_set_size( DIALOG *dialog, GRECT *size );

extern	WORD	wdlg_evnt( DIALOG *dialog, EVNT *events );
extern	void	wdlg_redraw( DIALOG *dialog, GRECT *rect, WORD obj, WORD depth );

/* Definitionen fÅr <flags> */
#define	WDLG_BKGD	1													/* Hintergrundbedienung zulassen */

/* Funktionsnummern fÅr <obj> bei handle_exit(...) */
#define	HNDL_INIT	-1													/* Dialog initialisieren */
#define	HNDL_CLSD	-3													/* Dialogfenster wurde geschlossen */
#define	HNDL_OPEN	-5													/* Dialog-Initialisierung abschlieûen (zweiter Aufruf am Ende von wdlg_init) */
#define	HNDL_EDIT	-6													/* Zeichen fÅr ein Edit-Feld ÅberprÅfen */
#define	HNDL_EDDN	-7													/* Zeichen wurde ins Edit-Feld eingetragen */
#define	HNDL_EDCH	-8													/* Edit-Feld wurde gewechselt */
#define	HNDL_MOVE	-9													/* Dialog wurde verschoben */
#define	HNDL_TOPW	-10												/* Dialog-Fenster ist nach oben gekommen */
#define	HNDL_UNTP	-11												/* Dialog-Fenster ist nicht aktiv */
