/****** Wdialog definitions ***********************************************/

typedef	void	*WD_DIALOG;
						
typedef	WORD	(cdecl *HNDL_OBJ)( WD_DIALOG *dialog, EVNT *events, WORD obj, WORD clicks, void *data );

 WD_DIALOG	*wdlg_create( HNDL_OBJ handle_exit, OBJECT *tree, void *user_data, WORD code, void *data, WORD flags);
 WORD	wdlg_open( WD_DIALOG *dialog, BYTE *title, WORD kind, WORD x, WORD y, WORD code, void *data);
#if OLDWAY
 WORD	wdlg_close( WD_DIALOG *dialog);
#else
 WORD	wdlg_close( WD_DIALOG *dialog, WORD *x, WORD *y);
#endif
 WORD	wdlg_delete( WD_DIALOG *dialog);

 WORD	wdlg_get_tree( WD_DIALOG *dialog, OBJECT **tree, GRECT *r);
 WORD	wdlg_get_edit( WD_DIALOG *dialog, WORD *cursor);
 void	*wdlg_get_udata( WD_DIALOG *dialog);
 WORD	wdlg_get_handle( WD_DIALOG *dialog);

 WORD	wdlg_set_edit( WD_DIALOG *dialog, WORD obj);
 WORD	wdlg_set_tree( WD_DIALOG *dialog, OBJECT *tree);
 WORD	wdlg_set_size( WD_DIALOG *dialog, GRECT *size);
 WORD	wdlg_set_iconify( WD_DIALOG *dialog, GRECT *g, char *title, OBJECT *tree, WORD obj);
 WORD	wdlg_set_uniconify( WD_DIALOG *dialog, GRECT *g, char *title, OBJECT *tree);

 WORD	wdlg_evnt( WD_DIALOG *dialog, EVNT *events);
 void	wdlg_redraw( WD_DIALOG *dialog, GRECT *rect, WORD obj, WORD depth);

/* Definitionen fÅr <flags> */
#define	WDLG_BKGD	1				/* Hintergrundbedienung zulassen */

/* Funktionsnummern fÅr <obj> bei handle_exit(...) */
#define	HNDL_INIT	-1				/* Dialog initialisieren */
#define	HNDL_MESG	-2				/* Dialog initialisieren */
#define	HNDL_CLSD	-3				/* Dialogfenster wurde geschlossen */
#define	HNDL_OPEN	-5				/* Dialog-Initialisierung abschlieûen (zweiter Aufruf am Ende von wdlg_init) */
#define	HNDL_EDIT	-6				/* Zeichen fÅr ein Edit-Feld ÅberprÅfen */
#define	HNDL_EDDN	-7				/* Zeichen wurde ins Edit-Feld eingetragen */
#define	HNDL_EDCH	-8				/* Edit-Feld wurde gewechselt */
#define	HNDL_MOVE	-9				/* Dialog wurde verschoben */
#define	HNDL_TOPW	-10				/* Dialog-Fenster ist nach oben gekommen */
#define	HNDL_UNTP	-11				/* Dialog-Fenster ist nicht aktiv */

/****** Listbox definitions ***********************************************/
typedef	void	*LIST_BOX;

typedef	void	(cdecl *SLCT_ITEM)( LIST_BOX *box, OBJECT *tree, struct _lbox_item *item, void *user_data, WORD obj_index, WORD last_state );
typedef	WORD	(cdecl *SET_ITEM)( LIST_BOX *box, OBJECT *tree, struct _lbox_item *item, WORD obj_index, void *user_data, GRECT *rect, WORD first );

typedef struct	_lbox_item
{
	struct _lbox_item *next;			/* Zeiger auf den nÑchsten Eintrag in der Liste */
	WORD	selected;					/* gibt an, ob das Objekt selektiert ist */

	WORD	data1;					/* Daten fÅr das Programm... */
	void	*data2;
	void	*data3;

} LBOX_ITEM;

#define	LBOX_VERT	1				/* Listbox mit vertikalem Slider */
#define	LBOX_AUTO	2				/* Auto-Scrolling */
#define	LBOX_AUTOSLCT	4			/* automatische Darstellung beim Auto-Scrolling */
#define	LBOX_REAL	8				/* Real-Time-Slider */
#define	LBOX_SNGL	16				/* nur ein anwÑhlbarer Eintrag */
#define	LBOX_SHFT	32				/* Mehrfachselektionen mit Shift */
#define	LBOX_TOGGLE	64			/* Status eines Eintrags bei Selektion wechseln */
#define	LBOX_2SLDRS	128			/* Listbox hat einen hor. und einen vertikalen Slider */

/* #defines fÅr Listboxen mit nur einem Slider */
#define	lbox_get_visible \
			lbox_get_avis

#define	lbox_get_first \
			lbox_get_afirst
			
#define	lbox_set_slider \
			lbox_set_asldr

#define	lbox_scroll_to \
			lbox_ascroll_to
			
 LIST_BOX *lbox_create( OBJECT *tree, SLCT_ITEM slct, SET_ITEM set, LBOX_ITEM *items, WORD visible_a, WORD first_a,
						  WORD *ctrl_objs, WORD *objs, WORD flags, WORD pause_a, void *user_data, void *dialog,
						  WORD visible_b, WORD first_b, WORD entries_b, WORD pause_b);

 void	lbox_update( LIST_BOX *box, GRECT *rect);
 WORD	lbox_do( LIST_BOX *box, WORD obj);
 WORD	lbox_delete( LIST_BOX *box);

 WORD	lbox_cnt_items( LIST_BOX *box);
 OBJECT	*lbox_get_tree( LIST_BOX *box);
 WORD	lbox_get_avis( LIST_BOX *box);
 void	*lbox_get_udata( LIST_BOX *box);
 WORD	lbox_get_afirst( LIST_BOX *box);
 WORD	lbox_get_slct_idx( LIST_BOX *box);
 LBOX_ITEM	*lbox_get_items( LIST_BOX *box);
 LBOX_ITEM	*lbox_get_item( LIST_BOX *box, WORD n);
 LBOX_ITEM *lbox_get_slct_item( LIST_BOX *box);
 WORD	lbox_get_idx( LBOX_ITEM *items, LBOX_ITEM *search);
 WORD	lbox_get_bvis( LIST_BOX *box);
 WORD	lbox_get_bentries( LIST_BOX *box);
WORD	lbox_get_bfirst( LIST_BOX *box);

void	lbox_set_asldr( LIST_BOX *box, WORD first, GRECT *rect);
void	lbox_set_items( LIST_BOX *box, LBOX_ITEM *items);
void	lbox_free_items( LIST_BOX *box);
void	lbox_free_list( LBOX_ITEM *items);
void	lbox_ascroll_to( LIST_BOX *box, WORD first, GRECT *box_rect, GRECT *slider_rect);
void	lbox_set_bsldr( LIST_BOX *box, WORD first, GRECT *rect);
void	lbox_set_bentries( LIST_BOX *box, WORD entries);
void	lbox_bscroll_to( LIST_BOX *box, WORD first, GRECT *box_rect, GRECT *slider_rect);

/****** font selector definitions ***********************************************/

typedef	void	*FNT_DIALOG;

typedef	void	(cdecl *UTXT_FN)( WORD x, WORD y, WORD *clip_rect, LONG id, LONG pt, LONG ratio, BYTE *string );

typedef struct _fnts_item
{
	struct	_fnts_item	*next;	/* Zeiger auf den nÑchsten Font oder 0L (Ende der Liste) */
	UTXT_FN	display;				/* Zeiger auf die Anzeige-Funktion fÅr applikationseigene Fonts */
	LONG		id;					/* ID des Fonts, >= 65536 fÅr applikationseigene Fonts */
	WORD		index;				/* Index des Fonts (falls VDI-Font) */
	BYTE		mono;				/* Flag fÅr Ñquidistante Fonts */
	BYTE		outline;				/* Flag fÅr Vektorfont */
	WORD		npts;				/* Anzahl der vordefinierten Punkthîhen */
	BYTE		*full_name;			/* Zeiger auf den vollstÑndigen Namen */
	BYTE		*family_name;			/* Zeiger auf den Familiennamen */
	BYTE		*style_name;			/* Zeiger auf den Stilnamen */
	BYTE		*pts;				/* Zeiger auf Feld mit Punkthîhen */
	LONG		reserved[4];			/* reserviert, mÅssen 0 sein */
} FNTS_ITEM;

/* Definitionen fÅr <font_flags> bei fnts_create() */

#define FNTS_BTMP		1				/* Bitmapfonts anzeigen */
#define FNTS_OUTL		2				/* Vektorfonts anzeigen */
#define FNTS_MONO		4				/* Ñquidistante Fonts anzeigen */
#define FNTS_PROP		8				/* proportionale Fonts anzeigen */

/* Definitionen fÅr <dialog_flags> bei fnts_create() */
#define FNTS_3D		1				/* 3D-Design benutzen */

/* Definitionen fÅr <button_flags> bei fnts_open() */
#define FNTS_SNAME		0x01		/* Checkbox fÅr die Namen selektieren */
#define FNTS_SSTYLE		0x02		/* Checkbox fÅr die Stile selektieren */
#define FNTS_SSIZE		0x04		/* Checkbox fÅr die Hîhe selektieren */
#define FNTS_SRATIO		0x08		/* Checkbox fÅr das VerhÑltnis Breite/Hîhe selektieren */

#define FNTS_CHNAME		0x0100	/* Checkbox fÅr die Namen anzeigen */
#define FNTS_CHSTYLE	0x0200	/* Checkbox fÅr die Stile anzeigen */
#define FNTS_CHSIZE		0x0400	/* Checkbox fÅr die Hîhe anzeigen */
#define FNTS_CHRATIO	0x0800	/* Checkbox fÅr das VerhÑltnis Breite/Hîhe anzeigen */
#define FNTS_RATIO		0x1000	/* VerhÑltnis Breite/Hîhe einstellbar */
#define FNTS_BSET		0x2000	/* Button "setzen" anwÑhlbar */
#define FNTS_BMARK		0x4000	/* Button "markieren" anwÑhlbar */

/* Definitionen fÅr <button> bei fnts_evnt() */

#define FNTS_CANCEL		1		/* "Abbruch" wurde angewÑhlt */
#define FNTS_OK		2		/* "OK" wurde gedrÅckt */
#define FNTS_SET		3		/* "setzen" wurde angewÑhlt */
#define FNTS_MARK		4		/* "markieren" wurde betÑtigt */
#define FNTS_OPT		5		/* der applikationseigene Button wurde ausgewÑhlt */

 FNT_DIALOG	*fnts_create( WORD vdi_handle, WORD no_fonts, WORD font_flags, WORD dialog_flags, BYTE *sample, BYTE *opt_button);
 WORD	fnts_delete( FNT_DIALOG *fnt_dialog, WORD vdi_handle);
 WORD	fnts_open( FNT_DIALOG *fnt_dialog, WORD button_flags, WORD x, WORD y, LONG id, LONG pt, LONG ratio);
#if OLDWAY
 WORD	fnts_close( FNT_DIALOG *fnt_dialog);
#else
 WORD	fnts_close( FNT_DIALOG *fnt_dialog, WORD *x, WORD *y);
#endif

WORD	fnts_get_no_styles( FNT_DIALOG *fnt_dialog, LONG id);
LONG	fnts_get_style( FNT_DIALOG *fnt_dialog, LONG id, WORD index);
WORD	fnts_get_name( FNT_DIALOG *fnt_dialog, LONG id, BYTE *full_name, BYTE *family_name, BYTE *style_name);
WORD	fnts_get_info( FNT_DIALOG *fnt_dialog, LONG id, WORD *mono, WORD *outline);

WORD	fnts_add( FNT_DIALOG *fnt_dialog, FNTS_ITEM *user_fonts);
void	fnts_remove( FNT_DIALOG *fnt_dialog);
WORD	fnts_update( FNT_DIALOG *fnt_dialog, WORD button_flags, LONG id, LONG pt, LONG ratio);

WORD	fnts_evnt( FNT_DIALOG *fnt_dialog, EVNT *events, WORD *button, WORD *check_boxes, LONG *id, LONG *pt, LONG *ratio);
WORD	fnts_do( FNT_DIALOG *fnt_dialog, WORD button_flags, LONG id_in, LONG pt_in, LONG ratio_in, WORD *check_boxes, LONG *id, LONG *pt, LONG *ratio);

/***** *******************************/

#include <prdialog.h>
#include <prsettng.h>

typedef	void *PRN_DIALOG;

PRN_DIALOG	*pdlg_create( WORD dialog_flags);
WORD	pdlg_delete( PRN_DIALOG *prn_dialog);
WORD	pdlg_open( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, BYTE *document_name, WORD option_flags, WORD x, WORD y);
WORD	pdlg_close( PRN_DIALOG *prn_dialog, WORD *x, WORD *y);

LONG	pdlg_get_setsize(VOID);

WORD	pdlg_add_printers( PRN_DIALOG *prn_dialog, DRV_INFO *drv_info);
WORD	pdlg_remove_printers( PRN_DIALOG *prn_dialog);
WORD	pdlg_update( PRN_DIALOG *prn_dialog, BYTE *document_name);
WORD	pdlg_add_sub_dialogs( PRN_DIALOG *prn_dialog, PDLG_SUB *sub_dialogs);
WORD	pdlg_remove_sub_dialogs( PRN_DIALOG *prn_dialog);
PRN_SETTINGS	*pdlg_new_settings( PRN_DIALOG *prn_dialog);
WORD	pdlg_free_settings( PRN_SETTINGS *settings);
WORD	pdlg_dflt_settings( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings);
WORD	pdlg_validate_settings( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings);
WORD	pdlg_use_settings( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings);
WORD	pdlg_save_default_settings( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings);
WORD	pdlg_evnt( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, EVNT *events, WORD *button);
WORD	pdlg_do( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, BYTE *document_name, WORD option_flags);


/* <dialog_flags> fÅr pdlg_create() */
#define	PDLG_3D			0x0001

/* <option_flags> fÅr pdlg_open/do() */
#define	PDLG_PREFS		0x0000			/* Einstelldialog anzeigen */
#define	PDLG_PRINT		0x0001			/* Druckdialog anzeigen */

#define	PDLG_ALWAYS_COPIES	0x0010			/* immer Kopien anbieten */
#define	PDLG_ALWAYS_ORIENT	0x0020			/* immer Querformat anbieten */
#define	PDLG_ALWAYS_SCALE	0x0040			/* immer Skalierung anbieten */

#define	PDLG_EVENODD		0x0100			/* Option fÅr gerade und ungerade Seiten anbieten */

/* <button> fÅr pdlg_evnt()/pdlg_do */
#define	PDLG_CANCEL	1					/* "Abbruch" wurde angewÑhlt */
#define	PDLG_OK		2					/* "OK" wurde gedrÅckt */
