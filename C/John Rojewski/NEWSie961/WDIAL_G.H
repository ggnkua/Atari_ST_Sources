/* WDIAL_G.H  - from Magic 5 Developers docs */

typedef struct evnt
{
	int	mwhich;
	int	mx;
	int	my;
	int	mbutton;
	int	kstate;
	int	key;
	int	mclicks;
	int	reserved[9];
	int	msg[16];
} EVNT;

typedef	void	*DIALOG;
						
typedef	int	(cdecl *HNDL_OBJ)( void *dialog, EVNT *events, int obj, int clicks, void *data );

extern	void	*wdlg_create( HNDL_OBJ handle_exit, OBJECT *tree, void *user_data, int code, void *data, int flags );
extern	int	wdlg_open( DIALOG *dialog, char *title, int kind, int x, int y, int code, void *data );
extern	int	wdlg_close( DIALOG *dialog );
extern	int	wdlg_delete( DIALOG *dialog );

extern	int	wdlg_get_tree( DIALOG *dialog, OBJECT **tree, GRECT *r );
extern	int	wdlg_get_edit( DIALOG *dialog, int *cursor );
extern	void	*wdlg_get_udata( DIALOG *dialog );
extern	int	wdlg_get_handle( DIALOG *dialog );

extern	int	wdlg_set_edit( DIALOG *dialog, int obj );
extern	int	wdlg_set_tree( DIALOG *dialog, OBJECT *tree );
extern	int	wdlg_set_size( DIALOG *dialog, GRECT *size );
extern	int	wdlg_set_iconify( DIALOG *d, GRECT *g, char *title, OBJECT *tree, int obj );
extern	int	wdlg_set_uniconify( DIALOG *d, GRECT *g, char *title, OBJECT *tree );

extern	int	wdlg_evnt( DIALOG *dialog, EVNT *events );
extern	void	wdlg_redraw( DIALOG *dialog, GRECT *rect, int obj, int depth );

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
