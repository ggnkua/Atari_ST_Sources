#ifndef __AES_XTND_H
#define __AES_XTND_H

#if ( WDLG_DIRECT_CALL == 0 )

/****** Wdialog definitions ***********************************************/

typedef	void	*DIALOG;
						
typedef	G_w	(__Cdecl *HNDL_OBJ)( DIALOG *dialog, EVNT *events, G_w obj, G_w clicks, void *data );

DIALOG *G_decl G_n(wdlg_create)( HNDL_OBJ handle_exit, OBJECT *tree, void *user_data, G_w code, void *data, G_w flags dglob );
G_w	G_decl G_n(wdlg_open)( DIALOG *dialog, G_b *title, G_w kind, G_w x, G_w y, G_w code, void *data dglob );
#if MT_OLDWAY
G_w	G_decl G_n(wdlg_close)( DIALOG *dialog dglob );
#else
G_w	G_decl G_n(wdlg_close)( DIALOG *dialog, G_w *x, G_w *y dglob );
#endif
G_w	G_decl G_n(wdlg_delete)( DIALOG *dialog dglob );

G_w	G_decl G_n(wdlg_get_tree)( DIALOG *dialog, OBJECT **tree, GRECT *r dglob );
G_w	G_decl G_n(wdlg_get_edit)( DIALOG *dialog, G_w *cursor dglob );
void *G_decl G_n(wdlg_get_udata)( DIALOG *dialog dglob );
G_w	G_decl G_n(wdlg_get_handle)( DIALOG *dialog dglob );

G_w	G_decl G_n(wdlg_set_edit)( DIALOG *dialog, G_w obj dglob );
G_w	G_decl G_n(wdlg_set_tree)( DIALOG *dialog, OBJECT *tree dglob );
G_w	G_decl G_n(wdlg_set_size)( DIALOG *dialog, GRECT *size dglob );
G_w	G_decl G_n(wdlg_set_iconify)( DIALOG *dialog, GRECT *g, char *title, OBJECT *tree, G_w obj dglob );
G_w	G_decl G_n(wdlg_set_uniconify)( DIALOG *dialog, GRECT *g, char *title, OBJECT *tree dglob );

G_w	G_decl G_n(wdlg_evnt)( DIALOG *dialog, EVNT *events dglob );
void G_decl G_n(wdlg_redraw)( DIALOG *dialog, GRECT *rect, G_w obj, G_w depth dglob );

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

typedef	void	(__Cdecl *SLCT_ITEM)( LIST_BOX *box, OBJECT *tree, struct _lbox_item *item, void *user_data, G_w obj_index, G_w last_state );
typedef	G_w	(__Cdecl *SET_ITEM)( LIST_BOX *box, OBJECT *tree, struct _lbox_item *item, G_w obj_index, void *user_data, GRECT *rect, G_w first );

typedef struct	_lbox_item
{
	struct _lbox_item *next;			/* Zeiger auf den nÑchsten Eintrag in der Liste */
	G_w	selected;					/* gibt an, ob das Objekt selektiert ist */

	G_w	data1;					/* Daten fÅr das Programm... */
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
			
LIST_BOX *G_decl G_n(lbox_create)(
		OBJECT *tree, SLCT_ITEM slct, SET_ITEM set, LBOX_ITEM *items, G_w visible_a, G_w first_a,
		G_w *ctrl_objs, G_w *objs, G_w flags, G_w pause_a, void *user_data, void *dialog,
		G_w visible_b, G_w first_b, G_w entries_b, G_w pause_b dglob );

void G_decl G_n(lbox_update)( LIST_BOX *box, GRECT *rect dglob );
G_w	G_decl G_n(lbox_do)( LIST_BOX *box, G_w obj dglob );
G_w	G_decl G_n(lbox_delete)( LIST_BOX *box dglob );

G_w	G_decl G_n(lbox_cnt_items)( LIST_BOX *box dglob );
OBJECT *G_decl G_n(lbox_get_tree)( LIST_BOX *box dglob );
G_w	G_decl G_n(lbox_get_avis)( LIST_BOX *box dglob );
void *G_decl G_n(lbox_get_udata)( LIST_BOX *box dglob );
G_w	G_decl G_n(lbox_get_afirst)( LIST_BOX *box dglob );
G_w	G_decl G_n(lbox_get_slct_idx)( LIST_BOX *box dglob );
LBOX_ITEM *G_decl G_n(lbox_get_items)( LIST_BOX *box dglob );
LBOX_ITEM *G_decl G_n(lbox_get_item)( LIST_BOX *box, G_w n dglob );
LBOX_ITEM *G_decl G_n(lbox_get_slct_item)( LIST_BOX *box dglob );
G_w	G_decl G_n(lbox_get_idx)( LBOX_ITEM *items, LBOX_ITEM *search dglob );
G_w	G_decl G_n(lbox_get_bvis)( LIST_BOX *box dglob );
G_w	G_decl G_n(lbox_get_bentries)( LIST_BOX *box dglob );
G_w	G_decl G_n(lbox_get_bfirst)( LIST_BOX *box dglob );

void G_decl G_n(lbox_set_asldr)( LIST_BOX *box, G_w first, GRECT *rect dglob );
void G_decl G_n(lbox_set_items)( LIST_BOX *box, LBOX_ITEM *items dglob );
void G_decl G_n(lbox_free_items)( LIST_BOX *box dglob );
void G_decl G_n(lbox_free_list)( LBOX_ITEM *items dglob );
void G_decl G_n(lbox_ascroll_to)( LIST_BOX *box, G_w first, GRECT *box_rect, GRECT *slider_rect dglob );
void G_decl G_n(lbox_set_bsldr)( LIST_BOX *box, G_w first, GRECT *rect dglob );
void G_decl G_n(lbox_set_bentries)( LIST_BOX *box, G_w entries dglob );
void G_decl G_n(lbox_bscroll_to)( LIST_BOX *box, G_w first, GRECT *box_rect, GRECT *slider_rect dglob );
/****** font selector definitions ***********************************************/

typedef	void	*FNT_DIALOG;

typedef	void	(__Cdecl *UTXT_FN)( G_w x, G_w y, G_w *clip_rect, G_l id, G_l pt, G_l ratio, G_b *string );

typedef struct _fnts_item
{
	struct	_fnts_item	*next;	/* Zeiger auf den nÑchsten Font oder 0L (Ende der Liste) */
	UTXT_FN	display;				/* Zeiger auf die Anzeige-Funktion fÅr applikationseigene Fonts */
	G_l		id;					/* ID des Fonts, >= 65536 fÅr applikationseigene Fonts */
	G_w		index;				/* Index des Fonts (falls VDI-Font) */
	G_b		mono;				/* Flag fÅr Ñquidistante Fonts */
	G_b		outline;				/* Flag fÅr Vektorfont */
	G_w		npts;				/* Anzahl der vordefinierten Punkthîhen */
	G_b		*full_name;			/* Zeiger auf den vollstÑndigen Namen */
	G_b		*family_name;			/* Zeiger auf den Familiennamen */
	G_b		*style_name;			/* Zeiger auf den Stilnamen */
	G_b		*pts;				/* Zeiger auf Feld mit Punkthîhen */
	G_l		reserved[4];			/* reserviert, mÅssen 0 sein */
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

FNT_DIALOG	*G_decl G_n(fnts_create)( G_w vdi_handle, G_w no_fonts, G_w font_flags, G_w dialog_flags, G_b *sample, G_b *opt_button dglob );
G_w	G_decl G_n(fnts_delete)( FNT_DIALOG *fnt_dialog, G_w vdi_handle dglob );
G_w	G_decl G_n(fnts_open)( FNT_DIALOG *fnt_dialog, G_w button_flags, G_w x, G_w y, G_l id, G_l pt, G_l ratio dglob );
#if MT_OLDWAY
G_w	G_decl G_n(fnts_close)( FNT_DIALOG *fnt_dialog dglob );
#else
G_w	G_decl G_n(fnts_close)( FNT_DIALOG *fnt_dialog, G_w *x, G_w *y dglob );
#endif

G_w	G_decl G_n(fnts_get_no_styles)( FNT_DIALOG *fnt_dialog, G_l id dglob );
G_l G_decl G_n(fnts_get_style)( FNT_DIALOG *fnt_dialog, G_l id, G_w index dglob );
G_w	G_decl G_n(fnts_get_name)( FNT_DIALOG *fnt_dialog, G_l id, G_b *full_name, G_b *family_name, G_b *style_name dglob );
G_w	G_decl G_n(fnts_get_info)( FNT_DIALOG *fnt_dialog, G_l id, G_w *mono, G_w *outline dglob );

G_w	G_decl G_n(fnts_add)( FNT_DIALOG *fnt_dialog, FNTS_ITEM *user_fonts dglob );
void G_decl G_n(fnts_remove)( FNT_DIALOG *fnt_dialog dglob );
G_w	G_decl G_n(fnts_update)( FNT_DIALOG *fnt_dialog, G_w button_flags, G_l id, G_l pt, G_l ratio dglob );

G_w	G_decl G_n(fnts_evnt)( FNT_DIALOG *fnt_dialog, EVNT *events, G_w *button, G_w *check_boxes, G_l *id, G_l *pt, G_l *ratio dglob );
G_w	G_decl G_n(fnts_do)( FNT_DIALOG *fnt_dialog, G_w button_flags, G_l id_in, G_l pt_in, G_l ratio_in, G_w *check_boxes, G_l *id, G_l *pt, G_l *ratio dglob );
#endif	/* WDLG_DIRECT_CALL */

/****** file selector definitions ***********************************************/
/* Sortiermodi */

#define SORTBYNAME	0
#define SORTBYDATE	1
#define SORTBYSIZE	2
#define SORTBYTYPE	3
#define SORTBYNONE	4

/* Flags fÅr Dateiauswahl */

#define DOSMODE	1
#define NFOLLOWSLKS	2
#define GETMULTI	8

/* fslx_set_flags */

#define SHOW8P3	1
typedef void XATTR;

typedef G_w (__Cdecl XFSL_FILTER)(char *path, char *name, XATTR *xa);

void * G_decl G_n(fslx_open)(
			char *title,
			G_w x, G_w y,
			G_w	*handle,
			char *path, G_w pathlen,
			char *fname, G_w fnamelen,
			char *patterns,
			XFSL_FILTER *filter,
			char *paths,
			G_w sort_mode,
			G_w flags dglob);

G_w G_decl G_n(fslx_evnt)(
			void *fsd,
			EVNT *events,
			char *path,
			char *fname,
			G_w *button,
			G_w *nfiles,
			G_w *sort_mode,
			char **pattern dglob );

void * G_decl G_n(fslx_do)(
			char *title,
			char *path, G_w pathlen,
			char *fname, G_w fnamelen,
			char *patterns,
			XFSL_FILTER *filter,
			char *paths,
			G_w *sort_mode,
			G_w flags,
			G_w *button,
			G_w *nfiles,
			char **pattern dglob );

G_w	G_decl G_n(fslx_getnxtfile)( void *fsd, char *fname dglob );
G_w	G_decl G_n(fslx_close)( void *fsd dglob );
G_w	G_decl G_n(fslx_set_flags)( G_w flags, G_w *oldval dglob );

/************************************************************************/
#if ( WDLG_DIRECT_CALL == 0 )

#include	"PRDIALOG.H"	/* Struktur zum EinfÅgen eigener Drucker und Unterdialoge */
#include	"PRSETTNG.H"	/* PRN_SETTINGS-Struktur */

typedef void *PRN_DIALOG;

PRN_DIALOG *G_decl G_n(pdlg_create)( G_w dialog_flags dglob );
G_w	G_decl G_n(pdlg_delete)( PRN_DIALOG *prn_dialog dglob );
G_w	G_decl G_n(pdlg_open)( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, G_b *document_name, G_w option_flags, G_w x, G_w y dglob );
G_w	G_decl G_n(pdlg_close)( PRN_DIALOG *prn_dialog, G_w *x, G_w *y dglob );

G_l G_decl G_nv(pdlg_get_setsize);

G_w	G_decl G_n(pdlg_add_printers)( PRN_DIALOG *prn_dialog, DRV_INFO *drv_info dglob );
G_w	G_decl G_n(pdlg_remove_printers)( PRN_DIALOG *prn_dialog dglob );
G_w	G_decl G_n(pdlg_update)( PRN_DIALOG *prn_dialog, G_b *document_name dglob );
G_w	G_decl G_n(pdlg_add_sub_dialogs)( PRN_DIALOG *prn_dialog, PDLG_SUB *sub_dialogs dglob );
G_w	G_decl G_n(pdlg_remove_sub_dialogs)( PRN_DIALOG *prn_dialog dglob );
PRN_SETTINGS *G_decl G_n(pdlg_new_settings)( PRN_DIALOG *prn_dialog dglob );
G_w	G_decl G_n(pdlg_free_settings)( PRN_SETTINGS *settings dglob );
G_w	G_decl G_n(pdlg_dflt_settings)( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings dglob );
G_w	G_decl G_n(pdlg_validate_settings)( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings dglob );
G_w	G_decl G_n(pdlg_use_settings)( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings dglob );
G_w	G_decl G_n(pdlg_save_default_settings)( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings dglob );
G_w	G_decl G_n(pdlg_evnt)( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, EVNT *events, G_w *button dglob );
G_w	G_decl G_n(pdlg_do)( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, G_b *document_name, G_w option_flags dglob );


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


#endif	/*WDLG_DIRECT_CALL*/

/************************************************************************\

/* Editor-Funktionen */

\************************************************************************/
typedef void XEDITINFO;

XEDITINFO * G_decl G_nv(edit_create);
G_w G_decl G_n(edit_open)(OBJECT *tree, G_w obj dglob);
void G_decl G_n(edit_close)(OBJECT *tree, G_w obj dglob);
void G_decl G_n(edit_delete)(XEDITINFO *xi dglob);
G_w G_decl G_n(edit_cursor)(OBJECT *tree, G_w obj, G_w whdl, G_w show dglob);
G_w G_decl G_n(edit_evnt)(OBJECT *tree, G_w obj, G_w whdl,	EVNT *ev dglob);
G_w G_decl G_n(edit_get_buf)( OBJECT *tree, G_w obj, char **buf, long *buflen, long *txtlen dglob );
G_w G_decl G_n(edit_get_format)( OBJECT *tree, G_w obj, G_w *tabwidth, G_w *autowrap dglob );
G_w G_decl G_n(edit_get_colour)( OBJECT *tree, G_w obj, G_w *tcolour, G_w *bcolour dglob );
G_w G_decl G_n(edit_get_cursor)( OBJECT *tree, G_w obj, char **cursorpos dglob );
G_w G_decl G_n(edit_get_font)( OBJECT *tree, G_w obj,	G_w *fontID, G_w *fontH, G_w *mono dglob );
void G_decl G_n(edit_set_buf)( OBJECT *tree, G_w obj, char *buf, long buflen dglob );
void G_decl G_n(edit_set_format)( OBJECT *tree, G_w obj, G_w tabwidth, G_w autowrap dglob );
void G_decl G_n(edit_set_font)( OBJECT *tree, G_w obj, G_w fontID, G_w fontH, G_w mono dglob );
void G_decl G_n(edit_set_colour)( OBJECT *tree, G_w obj, G_w tcolour, G_w bcolour dglob );
void G_decl G_n(edit_set_cursor)( OBJECT *tree, G_w obj, char *cursorpos dglob );
G_w G_decl G_n(edit_resized)( OBJECT *tree, G_w obj, G_w *oldrh, G_w *newrh dglob );
G_w G_decl G_n(edit_get_dirty)( OBJECT *tree, G_w obj dglob );
void G_decl G_n(edit_set_dirty)( OBJECT *tree, G_w obj,	G_w dirty dglob );
void G_decl G_n(edit_get_sel)( OBJECT *tree, G_w obj, char **bsel, char **esel dglob );
void G_decl G_n(edit_get_pos)( OBJECT *tree, G_w obj, G_w *xscroll, long *yscroll, char **cyscroll, char **cursorpos, G_w *cx, G_w *cy dglob );
void G_decl G_n(edit_set_pos)( OBJECT *tree, G_w obj, G_w xscroll, long yscroll, char *cyscroll, char *cursorpos, G_w cx, G_w cy dglob );
void G_decl G_n(edit_get_scrollinfo)( OBJECT *tree, G_w obj,	long *nlines, long *yscroll, G_w *yvis, G_w *yval, G_w *ncols, G_w *xscroll, G_w *xvis dglob );
G_w G_decl G_n(edit_scroll)( OBJECT *tree, G_w obj, G_w whdl, long yscroll, G_w xscroll dglob );
#endif
