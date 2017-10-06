/*
 * gemx.h - main header file for new gem-lib extensions
 *
 * This lib contains all GEM extensions of MagiC and NVDI/FSM/Speedo
 *
 */
#ifndef _GEMLIB_X_H_
#define _GEMLIB_X_H_
#include "mgem.h"
#ifdef __cplusplus
extern "C" {
#endif
/*******************************************************************************
 * The AES extensions of MagiC
*/
typedef struct
{
	INT16 mwhich;		 	/* Art der Ereignisse					  */
	INT16 mx;				/* x-Koordinate des Mauszeigers 	  */
	INT16 my;				/* y-Koordinate des Mauszeigers 	  */
	INT16 mbutton; 			/* gedrÅckte Maustaste 				  */
	INT16 kstate;			/* Status der Sondertasten (kbshift) */
	INT16 key;				/* Scancode der gedrÅckten Taste		*/
	INT16 mclicks; 			/* Anzahl der Mausklicks					*/
	INT16 reserved[9];		/* reserviert 							  */
	INT16 msg[16]; 			/* Message-Buffer 						 */
} EVNT;
/*
 * Extensions to the form library (MagiC only)
*/
typedef struct
{
	char	scancode;
	char	nclicks;
	INT16 	objnr;
} SCANX;

typedef struct
{
	SCANX *unsh;			/* Tabellen fÅr UnShift-Kombinationen	 */
	SCANX *shift;			/* Tabellen fÅr Shift-Kombinationen 	*/
	SCANX *ctrl;			/* Tabellen fÅr Control-Kombinationen	 */
	SCANX *alt; 			/* Tabellen fÅr Alternate-Kombinationen */
	void	*resvd;			/* reserviert */
} XDO_INF;

extern int form_popup 		(OBJECT *tree, int x, int y);
extern int form_wbutton		(OBJECT *fo_btree, int fo_bobject, int fo_bclicks, INT16 *fo_bnxtobj, int whandle);
extern int form_wkeybd		(OBJECT *fo_ktree, int fo_kobject, int fo_kobnext, int fo_kchar, INT16 *fo_knxtobject, INT16 *fo_knxtchar, int whandle);
extern int form_xdial 		(int fo_diflag, int fo_dilittlx, int fo_dilittly, int fo_dilittlw, int fo_dilittlh, int fo_dibigx, int fo_dibigy, int fo_dibigw, int fo_dibigh, void **flydial);
extern int form_xdo			(OBJECT *tree, int startob, INT16 *lastcrsr, XDO_INF *tabs, void *flydial); 
extern int form_xerr		(long errcode, char *errfile);
extern int mt_form_popup 	(OBJECT *tree, int x, int y, INT16 *global_aes);
extern int mt_form_wbutton	(OBJECT *fo_btree, int fo_bobject, int fo_bclicks, INT16 *fo_bnxtobj, int whandle, INT16 *global_aes);
extern int mt_form_wkeybd	(OBJECT *fo_ktree, int fo_kobject, int fo_kobnext, int fo_kchar, INT16 *fo_knxtobject, INT16 *fo_knxtchar, int whandle, INT16 *global_aes);
extern int mt_form_xdial 	(int fo_diflag, int fo_dilittlx, int fo_dilittly, int fo_dilittlw, int fo_dilittlh, int fo_dibigx, int fo_dibigy, int fo_dibigw, int fo_dibigh, void **flydial, INT16 *global_aes);
extern int mt_form_xdo		(OBJECT *tree, int startob, INT16 *lastcrsr, XDO_INF *tabs, void *flydial, INT16 *global_aes); 
extern int mt_form_xerr		(long errcode, char *errfile, INT16 *global_aes);
/*
 * Extensions to the object library (MagiC only)
*/
extern void objc_wchange	(OBJECT *tree, int obj, int new_state, GRECT *clip,  int whandle);
extern void objc_wdraw		(OBJECT *tree, int start, int depth, GRECT *clip,  int whandle);
extern int	objc_wedit		(OBJECT *tree, int obj, int key, INT16 *idx, int kind, int whandle);
extern int	objc_xedit		(OBJECT *tree, int obj, int key, INT16 *xpos, int subfn, GRECT *r);
extern void mt_objc_wchange	(OBJECT *tree, int obj, int new_state, GRECT *clip,  int whandle, INT16 *global_aes);
extern void mt_objc_wdraw	(OBJECT *tree, int start, int depth, GRECT *clip,  int whandle, INT16 *global_aes);
extern int	mt_objc_wedit	(OBJECT *tree, int obj, int key, INT16 *idx, int kind, int whandle, INT16 *global_aes);
extern int	mt_objc_xedit	(OBJECT *tree, int obj, int key, INT16 *xpos, int subfn, GRECT *r, INT16 *global_aes);
/*
 * fnts_*	font selection (MagiC/WDIALOG only)
*/
typedef void *FNT_DIALOG;
typedef void (__CDECL *UTXT_FN)(INT16 x, INT16 y, INT16 *clip_rect, long id, long pt, long ratio, char *string);
typedef struct _fnts_item
{
	struct	_fnts_item	*next;		/* Zeiger auf den nÑchsten Font oder 0L (Ende der Liste) */
	UTXT_FN		display; 			/* Zeiger auf die Anzeige-Funktion fÅr applikationseigene Fonts */
	long		id;					/* ID des Fonts, >= 65536 fÅr applikationseigene Fonts */
	INT16 		index;				/* Index des Fonts (falls VDI-Font) */
	char		mono; 				/* Flag fÅr Ñquidistante Fonts */
	char		outline; 			/* Flag fÅr Vektorfont */
	INT16 		npts; 				/* Anzahl der vordefinierten Punkthîhen */
	char		*full_name; 		/* Zeiger auf den vollstÑndigen Namen */
	char		*family_name;		/* Zeiger auf den Familiennamen */
	char		*style_name;		/* Zeiger auf den Stilnamen */
	char		*pts; 				/* Zeiger auf Feld mit Punkthîhen */
	long		reserved[4];		/* reserviert, mÅssen 0 sein */
} FNTS_ITEM;
/* Definitionen fÅr <font_flags> bei fnts_create() */
#define FNTS_BTMP 		1			/* Bitmapfonts anzeigen */
#define FNTS_OUTL 		2			/* Vektorfonts anzeigen */
#define FNTS_MONO 		4			/* Ñquidistante Fonts anzeigen */
#define FNTS_PROP 		8			/* proportionale Fonts anzeigen */
/* Definitionen fÅr <dialog_flags> bei fnts_create() */
#define FNTS_3D			1			/* 3D-Design benutzen */
/* Definitionen fÅr <button_flags> bei fnts_open() */
#define FNTS_SNAME		0x01		/* Checkbox fÅr die Namen selektieren */
#define FNTS_SSTYLE		0x02		/* Checkbox fÅr die Stile selektieren */
#define FNTS_SSIZE		0x04		/* Checkbox fÅr die Hîhe selektieren */
#define FNTS_SRATIO		0x08		/* Checkbox fÅr das VerhÑltnis Breite/Hîhe selektieren */
#define FNTS_CHNAME		0x0100	/* Checkbox fÅr die Namen anzeigen */
#define FNTS_CHSTYLE 	0x0200	/* Checkbox fÅr die Stile anzeigen */
#define FNTS_CHSIZE		0x0400	/* Checkbox fÅr die Hîhe anzeigen */
#define FNTS_CHRATIO 	0x0800	/* Checkbox fÅr das VerhÑltnis Breite/Hîhe anzeigen */
#define FNTS_RATIO		0x1000	/* VerhÑltnis Breite/Hîhe einstellbar */
#define FNTS_BSET 		0x2000	/* Button "setzen" anwÑhlbar */
#define FNTS_BMARK		0x4000	/* Button "markieren" anwÑhlbar */
/* Definitionen fÅr <button> bei fnts_evnt() */
#define FNTS_CANCEL		1			/* "Abbruch" wurde angewÑhlt */
#define FNTS_OK			2			/* "OK" wurde gedrÅckt */
#define FNTS_SET			3			/* "setzen" wurde angewÑhlt */
#define FNTS_MARK 		4			/* "markieren" wurde betÑtigt */
#define FNTS_OPT			5			/* der applikationseigene Button wurde ausgewÑhlt */
extern int	fnts_add 				(FNT_DIALOG *fnt_dialog, FNTS_ITEM *user_fonts);
extern int	fnts_close				(FNT_DIALOG *fnt_dialog, INT16 *x, INT16 *y);
extern FNT_DIALOG	*fnts_create	(int vdi_handle, int no_fonts, int font_flags, int dialog_flags, char *sample, char *opt_button);
extern int	fnts_delete 			(FNT_DIALOG *fnt_dialog, int vdi_handle);
extern int	fnts_do					(FNT_DIALOG *fnt_dialog, int button_flags, long id_in, long pt_in, long ratio_in, INT16 *check_boxes, long *id, long *pt, long *ratio);
extern int	fnts_evnt				(FNT_DIALOG *fnt_dialog, EVNT *events, INT16 *button, INT16 *check_boxes, long *id, long *pt, long *ratio);
extern int	fnts_get_info			(FNT_DIALOG *fnt_dialog, long id, INT16 *mono, INT16 *outline);
extern int	fnts_get_name			(FNT_DIALOG *fnt_dialog, long id, char *full_name, char *family_name, char *style_name);
extern int	fnts_get_no_styles		(FNT_DIALOG *fnt_dialog, long id);
extern long	fnts_get_style 			(FNT_DIALOG *fnt_dialog, long id, int index);
extern int	fnts_open				(FNT_DIALOG *fnt_dialog, int button_flags, int x, int y, long id, long pt, long ratio);
extern void	fnts_remove 			(FNT_DIALOG *fnt_dialog);
extern int	fnts_update 			(FNT_DIALOG *fnt_dialog, int button_flags, long id, long pt, long ratio);
extern int	mt_fnts_add 				(FNT_DIALOG *fnt_dialog, FNTS_ITEM *user_fonts, INT16 *global_aes);
extern int	mt_fnts_close				(FNT_DIALOG *fnt_dialog, INT16 *x, INT16 *y, INT16 *global_aes);
extern FNT_DIALOG	*mt_fnts_create		(int vdi_handle, int no_fonts, int font_flags, int dialog_flags, char *sample, char *opt_button, INT16 *global_aes);
extern int	mt_fnts_delete 				(FNT_DIALOG *fnt_dialog, int vdi_handle, INT16 *global_aes);
extern int	mt_fnts_do					(FNT_DIALOG *fnt_dialog, int button_flags, long id_in, long pt_in, long ratio_in, INT16 *check_boxes, long *id, long *pt, long *ratio, INT16 *global_aes);
extern int	mt_fnts_evnt				(FNT_DIALOG *fnt_dialog, EVNT *events, INT16 *button, INT16 *check_boxes, long *id, long *pt, long *ratio, INT16 *global_aes);
extern int	mt_fnts_get_info			(FNT_DIALOG *fnt_dialog, long id, INT16 *mono, INT16 *outline, INT16 *global_aes);
extern int	mt_fnts_get_name			(FNT_DIALOG *fnt_dialog, long id, char *full_name, char *family_name, char *style_name, INT16 *global_aes);
extern int	mt_fnts_get_no_styles		(FNT_DIALOG *fnt_dialog, long id, INT16 *global_aes);
extern long	mt_fnts_get_style 			(FNT_DIALOG *fnt_dialog, long id, int index, INT16 *global_aes);
extern int	mt_fnts_open				(FNT_DIALOG *fnt_dialog, int button_flags, int x, int y, long id, long pt, long ratio, INT16 *global_aes);
extern void	mt_fnts_remove 				(FNT_DIALOG *fnt_dialog, INT16 *global_aes);
extern int	mt_fnts_update 				(FNT_DIALOG *fnt_dialog, int button_flags, long id, long pt, long ratio, INT16 *global_aes);
/*
 * fslx_*	file selection (MagiC only)
*/
typedef int (__CDECL *XFSL_FILTER)(char *path, char *name, void *xattr);

/* Sortiermodi */
#define SORTBYNAME	0
#define SORTBYDATE	1
#define SORTBYSIZE	2
#define SORTBYTYPE	3
#define SORTBYNONE	4
/* Flags fÅr Dateiauswahl */
#define DOSMODE		1
#define NFOLLOWSLKS	2
#define GETMULTI		8
/* fslx_set_flags */
#define SHOW8P3		1
extern int	fslx_close			(void *fsd);
extern void *fslx_do			(char *title, char *path, int pathlen, char *fname, int fnamelen, char *patterns, XFSL_FILTER filter, char *paths, INT16 *sort_mode, int flags, INT16 *button, INT16 *nfiles, char **pattern);
extern int	fslx_evnt			(void *fsd, EVNT *events, char *path, char *fname, INT16 *button, INT16 *nfiles, INT16 *sort_mode, char **pattern); 
extern int	fslx_getnxtfile		(void *fsd, char *fname);
extern void *fslx_open			(char *title, int x, int y, INT16 *handle, char *path, int pathlen, char *fname, int fnamelen, char *patterns, XFSL_FILTER filter, char *paths, int sort_mode, int flags);
extern int	fslx_set_flags 		(int flags, INT16 *oldval);
extern int	mt_fslx_close		(void *fsd, INT16 *global_aes);
extern void *mt_fslx_do			(char *title, char *path, int pathlen, char *fname, int fnamelen, char *patterns, XFSL_FILTER filter, char *paths, INT16 *sort_mode, int flags, INT16 *button, INT16 *nfiles, char **pattern, INT16 *global_aes);
extern int	mt_fslx_evnt		(void *fsd, EVNT *events, char *path, char *fname, INT16 *button, INT16 *nfiles, INT16 *sort_mode, char **pattern, INT16 *global_aes); 
extern int	mt_fslx_getnxtfile	(void *fsd, char *fname, INT16 *global_aes);
extern void *mt_fslx_open		(char *title, int x, int y, INT16 *handle, char *path, int pathlen, char *fname, int fnamelen, char *patterns, XFSL_FILTER filter, char *paths, int sort_mode, int flags, INT16 *global_aes);
extern int	mt_fslx_set_flags 	(int flags, INT16 *oldval, INT16 *global_aes);
/*
 * pdlg_*	printer configuration dialogs (WDIALOG only)
*/
#ifdef __GNUC__
/* GNU braucht ein paar 'forwards' */
struct _drv_entry;
struct _prn_entry;
struct _prn_settings;
#endif
typedef void *PRN_DIALOG;
typedef struct _prn_tray						/* Beschreibung eines Einzugs/Auswurfs */
{
	struct _prn_tray	*next;
	
	long	tray_id; 								/* Nummer des Einzugs oder Auswurfs */
	char	name[32];								/* Name des Schachts */
} PRN_TRAY;

typedef struct _media_size 					/* Beschreibung eines Papierformats */
{
	struct _media_size	*next;
	long			size_id; 						/* Kennung des Papierformats */
	char			name[32];						/* Name des Papierformats */
} MEDIA_SIZE;

typedef struct _media_type 					/* Beschreibung eines Papiertyps/Druckmediums */
{
	struct _media_type	*next;
	long			type_id; 						/* Kennung des Papierformats */
	char			name[32];						/* Name des Papierformats */
} MEDIA_TYPE;

typedef struct _prn_mode						/* Beschreibung eines Druckermodus */
{
	struct _prn_mode *next; 					/* Zeiger auf den nÑchsten Druckermodus */
	long		mode_id; 					/* Moduskennung (Index innerhalb der Datei) */
	INT16 		hdpi; 						/* horizontale Auflîsung in dpi */
	INT16 		vdpi; 						/* vertikale Auflîsung in dpi */
	long		mode_capabilities;			/* Moduseigenschaften */
	long		color_capabilities;			/* einstellbare Farbmodi */
	long		dither_flags;				/* Flags, die angeben, ob der korrespondierende Farbmodus mit oder ohne Dithern ansprechbar ist */
	MEDIA_TYPE	*paper_types;				/* geeignete Papiertypen */
	long		reserved;
	char		name[32];					/* Modusname */
} PRN_MODE;

/* sub_flags */
#define	PRN_STD_SUBS	0x0001				/* Standard-Unterdialoge fÅr NVDI-Drucker */
#define	PRN_FSM_SUBS	0x0002				/* Standard-Unterdialoge fÅr FSM-Drucker */
#define	PRN_QD_SUBS 	0x0004				/* Standard-Unterdialoge fÅr QuickDraw-Drucker */
/* old_printer kann auch 0L sein */
typedef long (__CDECL *PRN_SWITCH)(struct _drv_entry *drivers, struct _prn_settings *settings, struct _prn_entry *old_printer, struct _prn_entry *new_printer);

typedef struct _prn_entry						/* GerÑtebeschreibung */
{
	struct _prn_entry *next;					/* Zeiger auf die die nÑchste GerÑtebeschreibung */
	long			length;						/* StrukturlÑnge */
	long			format;						/* Datenformat */
	long			reserved;					/* reserviert */
	
	INT16 		driver_id;					/* Treiberkennung */
	INT16 		driver_type;				/* Treibertyp */
	long		printer_id; 				/* Druckerkennung */
	long		printer_capabilities;		/* Druckereigenschaften */
	long		reserved1;
	long			sub_flags;					/* Flags fÅr die Unterdialoge */
	struct _pdlg_sub	*sub_dialogs;			/* Zeiger auf die Liste der Unterdialoge fÅr diesen Drucker */
	PRN_SWITCH	setup_panel;					/* Unterdialog bei Druckerwechsel initialisieren */
	PRN_SWITCH	close_panel;					/* Unterdialog bei Druckerwechsel schlieûen */
	PRN_MODE 	*modes;							/* Liste der vorhandenen Auflîsungen */
	MEDIA_SIZE	*papers; 						/* Liste der vorhandenen Papierformate */
	PRN_TRAY 	*input_trays;					/* Liste der EinzÅge */
	PRN_TRAY 	*output_trays; 					/* Liste der AuswÅrfe */
	char			name[32];						/* Name des Druckers */
} PRN_ENTRY;

typedef struct _dither_mode
{
	struct _dither_mode	*next;
	long			length;							/* StrukturlÑnge */
	long			format;							/* Datenformat */
	long			reserved;						/* reserviert */
	long			dither_id;						/* Kennung */
	long			color_modes;					/* unterstÅtzte Farbtiefen */
	long			reserved1;
	long			reserved2;
	char			name[32];						/* Name des Rasterverfahrens */
} DITHER_MODE;

typedef struct
{
	long			 magic;							/* 'pdnf' */
	long			 length;						/* StrukturlÑnge */
	long			 format;						/* Datenformat */
	long			 reserved;						/* reserviert */
	INT16 			 driver_id;						/* Treibernummer fÅrs VDI */
	INT16 			 driver_type;					/* Treibertyp */
	long			 reserved1;
	long			 reserved2;
	long			 reserved3;
	PRN_ENTRY		*printers;					/* Liste der zum Treiber gehîrenden Drucker */
	DITHER_MODE 	*dither_modes; 				/* Liste der vom Treiber unterstÅtzten Rasterverfahren */
	long			 reserved4;
	long			 reserved5;
	long			 reserved6;
	long			 reserved7;
	long			 reserved8;
	long			 reserved9;
	
	char			 device[128];					/* Ausgabedatei des Druckertreibers */
	
} DRV_INFO;

typedef struct _drv_entry
{
	struct _drv_entry *next;
} DRV_ENTRY;

#define	PDLG_CHG_SUB	0x80000000L
#define	PDLG_IS_BUTTON 	0x40000000L
#define	PDLG_PREBUTTON 	0x20000000L
#define	PDLG_PB_OK		1
#define	PDLG_PB_CANCEL 	2
#define	PDLG_PB_DEVICE 	3
#define	PDLG_BUT_OK 	( PDLG_PREBUTTON + PDLG_PB_OK )
#define	PDLG_BUT_CNCL	( PDLG_PREBUTTON + PDLG_PB_CANCEL )
#define	PDLG_BUT_DEV	( PDLG_PREBUTTON + PDLG_PB_DEVICE )
typedef long (__CDECL *PDLG_INIT)(struct _prn_settings *settings, struct _pdlg_sub *sub);
typedef long (__CDECL *PDLG_HNDL)(struct _prn_settings *settings, struct _pdlg_sub *sub, INT16 exit_obj);
typedef long (__CDECL *PDLG_RESET)(struct _prn_settings *settings, struct _pdlg_sub *sub);

typedef struct _pdlg_sub				/* Unterdialog fÅr GerÑteeinstellung */
{
	struct _pdlg_sub 	*next; 			/* Zeiger auf den Nachfolger in der Liste */
	long				 length;		/* StrukturlÑnge */
	long				 format;		/* Datenformat */
	long				 reserved;		/* reserviert */
	
	void				*drivers;		/* nur fÅr interne Dialoge */
	INT16 				 option_flags;	/* Flags, u.a. PDLG_PRINTING, PDLG_PREFS */
	INT16 				 sub_id;		/* Kennung des Unterdialogs, wird fÅr globale Unterdialoge von pdlg_add() eingetragen */
	void				*dialog; 		/* Zeiger auf die Struktur des Fensterdialogs oder 0L */
	OBJECT				*tree;			/* Zeiger auf den zusammengesetzen Objektbaum */
	INT16 				 index_offset;	/* Indexverschiebung des Unterdialogs */
	INT16 				 reserved1;
	long				 reserved2;
	long				 reserved3;
	long				 reserved4;
	PDLG_INIT			 init_dlg;		/* Initialisierungsfunktion */
	PDLG_HNDL			 do_dlg;		/* Behandlungsfunktion */
	PDLG_RESET			 reset_dlg;		/* ZurÅcksetzfunktion */
	long				 reserved5;
	OBJECT				*sub_icon;		/* Zeiger auf das Icon fÅr die Listbox */
	OBJECT				*sub_tree;		/* Zeiger auf den Objektbaum des Unterdialogs */
	long				 reserved6;
	long				 reserved7;
	long				 private1;		/* dialogeigene Informationen */
	long				 private2;
	long				 private3;
	long				 private4;
} PDLG_SUB;

/*----------------------------------------------------------------------------------------*/ 
/* einstellbare Farbmodi eines Druckermodus																*/
/*----------------------------------------------------------------------------------------*/ 
#define	CC_MONO			0x0001		/* 2 Grautîne */
#define	CC_4_GREY		0x0002		/* 4 Grautîne */
#define	CC_8_GREY		0x0004		/* 8 Grautîne */
#define	CC_16_GREY		0x0008		/* 16 Grautîne */
#define	CC_256_GREY 	0x0010		/* 256 Grautîne */
#define	CC_32K_GREY 	0x0020		/* 32768 Farben in Grautîne wandeln */
#define	CC_65K_GREY 	0x0040		/* 65536 Farben in Grautîne wandeln */
#define	CC_16M_GREY 	0x0080		/* 16777216 Farben in Grautîne wandeln */
#define	CC_2_COLOR		0x0100		/* 2 Farben */
#define	CC_4_COLOR		0x0200		/* 4 Farben */
#define	CC_8_COLOR		0x0400		/* 8 Farben */
#define	CC_16_COLOR 	0x0800		/* 16 Farben */
#define	CC_256_COLOR	0x1000		/* 256 Farben */
#define	CC_32K_COLOR	0x2000		/* 32768 Farben */
#define	CC_65K_COLOR	0x4000		/* 65536 Farben */
#define	CC_16M_COLOR	0x8000		/* 16777216 Farben */
#define	NO_CC_BITS		16
/*----------------------------------------------------------------------------------------*/ 
/* einstellbare Rasterverfahren																				*/
/*----------------------------------------------------------------------------------------*/ 
#define	DC_NONE			0				/* keine Rasterverfahren */
#define	DC_FLOYD 		1				/* einfacher Floyd-Steinberg */
#define	NO_DC_BITS		1
/*----------------------------------------------------------------------------------------*/ 
/* Druckereigenschaften 																						*/
/*----------------------------------------------------------------------------------------*/ 
#define	PC_FILE			0x0001		/* Drucker kann Åber GEMDOS-Dateien angesprochen werden */
#define	PC_SERIAL		0x0002		/* Drucker kann auf der seriellen Schnittstelle angesteuert werden */
#define	PC_PARALLEL 	0x0004		/* Drucker kann auf der parallelen Schnittstelle angesteuert werden */
#define	PC_ACSI			0x0008		/* Drucker kann auf der ACSI-Schnittstelle ausgeben */
#define	PC_SCSI			0x0010		/* Drucker kann auf der SCSI-Schnittstelle ausgeben */
#define	PC_BACKGROUND	0x0080		/* Treiber kann im Hintergrund ausdrucken */
#define	PC_SCALING		0x0100		/* Treiber kann Seite skalieren */
#define	PC_COPIES		0x0200		/* Treiber kann Kopien einer Seite erstellen */
/*----------------------------------------------------------------------------------------*/ 
/* Moduseigenschaften																							*/
/*----------------------------------------------------------------------------------------*/ 
#define	MC_PORTRAIT 	0x0001		/* Seite kann im Hochformat ausgegeben werden */
#define	MC_LANDSCAPE	0x0002		/* Seite kann im Querformat ausgegeben werden */
#define	MC_REV_PTRT 	0x0004		/* Seite kann um 180 Grad gedreht im Hochformat ausgegeben werden */
#define	MC_REV_LNDSCP	0x0008		/* Seite kann um 180 Grad gedreht im Querformat ausgegeben werden */
#define	MC_ORIENTATION 	0x000f
#define	MC_SLCT_CMYK	0x0400		/* Treiber kann bestimmte Farbebenen ausgeben */
#define	MC_CTRST_BRGHT 	0x0800		/* Treiber kann Kontrast und Helligkeit verÑndern */
/*----------------------------------------------------------------------------------------*/ 
/* plane_flags 																									*/
/*----------------------------------------------------------------------------------------*/ 
#define	PLANE_BLACK 	0x0001
#define	PLANE_YELLOW	0x0002
#define	PLANE_MAGENTA	0x0004
#define	PLANE_CYAN		0x0008
/* <driver_mode> */
#define	DM_BG_PRINTING 0x0001		/* Flag fÅr Hintergrunddruck */
/*----------------------------------------------------------------------------------------*/ 
/* <page_flags> */
#define	PG_EVEN_PAGES	0x0001		/* nur Seiten mit gerader Seitennummer ausgeben */
#define	PG_ODD_PAGES	0x0002		/* nur Seiten mit ungerader Seitennummer ausgeben */
/* <first_page/last_page> */
#define	PG_MIN_PAGE 	1
#define	PG_MAX_PAGE 	9999
/* <orientation> */
#define	PG_UNKNOWN		0x0000		/* Ausrichtung unbekannt und nicht verstellbar */
#define	PG_PORTRAIT 	0x0001		/* Seite im Hochformat ausgeben */
#define	PG_LANDSCAPE	0x0002		/* Seite im Querformat ausgeben */

typedef struct _prn_settings
{
	long	magic;							/* 'pset' */
	long	length;							/* StrukturlÑnge */
	long	format;							/* Strukturtyp */
	long	reserved;
	long	page_flags; 					/* Flags, u.a. gerade Seiten, ungerade Seiten */
	INT16 	first_page; 					/* erste zu druckende Seite */
	INT16 	last_page;						/* letzte zu druckende Seite */
	INT16 	no_copies;						/* Anzahl der Kopien */
	INT16 	orientation;					/* Drehung */
	long	scale;							/* Skalierung: 0x10000L entspricht 100% */
	INT16 	driver_id;						/* VDI-GerÑtenummer */
	INT16 	driver_type;					/* Typ des eingestellten Treibers */
	long	driver_mode;					/* Flags, u.a. fÅr Hintergrunddruck */
	long	reserved1;
	long	reserved2;
	
	long	printer_id; 					/* Druckernummer */
	long	mode_id; 						/* Modusnummer */
	INT16 	mode_hdpi;						/* horizontale Auflîsung in dpi */
	INT16 	mode_vdpi;						/* vertikale Auflîsung in dpi */
	long	quality_id; 					/* Druckmodus (hardwÑremÑûige QualitÑt, z.B. Microweave oder Econofast) */
	long	color_mode; 					/* Farbmodus */
	long	plane_flags;					/* Flags fÅr auszugebende Farbebenen (z.B. nur cyan) */
	long	dither_mode;					/* Rasterverfahren */
	long	dither_value;					/* Parameter fÅr das Rasterverfahren */
	long	size_id; 						/* Papierformat */
	long	type_id; 						/* Papiertyp (normal, glossy) */
	long	input_id;						/* Papiereinzug */
	long	output_id;						/* Papierauswurf */
	long	contrast;						/* Kontrast: 0x10000L entspricht Normaleinstellung */
	long	brightness; 					/* Helligkeit: 0x1000L entspricht Normaleinstellung */
	long	reserved3;
	long	reserved4;
	long	reserved5;
	long	reserved6;
	long	reserved7;
	long	reserved8;
	char	device[128];					/* Dateiname fÅr den Ausdruck */
	struct
	{
		char	inside[120];
	} mac_settings;
} PRN_SETTINGS;

/* <dialog_flags> fÅr pdlg_create() */
#define PDLG_3D				0x0001
/* <option_flags> fÅr pdlg_open/do() */
#define PDLG_PREFS			0x0000			/* Einstelldialog anzeigen */
#define PDLG_PRINT			0x0001			/* Druckdialog anzeigen */
#define PDLG_ALWAYS_COPIES 	0x0010			/* immer Kopien anbieten */
#define PDLG_ALWAYS_ORIENT 	0x0020			/* immer Querformat anbieten */
#define PDLG_ALWAYS_SCALE	0x0040			/* immer Skalierung anbieten */
#define	PDLG_EVENODD		0x0100			/* Option fÅr gerade und ungerade Seiten anbieten */
/* <button> fÅr pdlg_evnt()/pdlg_do */
#define	PDLG_CANCEL 1							/* "Abbruch" wurde angewÑhlt */
#define	PDLG_OK		2							/* "OK" wurde gedrÅckt */
extern int	pdlg_add_printers 				(PRN_DIALOG *prn_dialog, DRV_INFO *drv_info);
extern int	pdlg_add_sub_dialogs 			(PRN_DIALOG *prn_dialog, PDLG_SUB *sub_dialogs);
extern int	pdlg_close						(PRN_DIALOG *prn_dialog, INT16 *x, INT16 *y);
extern PRN_DIALOG* pdlg_create 				(int dialog_flags);
extern int	pdlg_delete 					(PRN_DIALOG *prn_dialog);
extern int	pdlg_dflt_settings				(PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings);
extern int	pdlg_do							(PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, char *document_name, int option_flags);
extern int	pdlg_evnt						(PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, EVNT *events, INT16 *button);
extern int	pdlg_free_settings				(PRN_SETTINGS *settings);
extern long	pdlg_get_setsize				(void);
extern PRN_SETTINGS *pdlg_new_settings		(PRN_DIALOG *prn_dialog);
extern int	pdlg_open						(PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, char *document_name, int option_flags, int x, int y);
extern int	pdlg_remove_printers 			(PRN_DIALOG *prn_dialog);
extern int	pdlg_remove_sub_dialogs 		(PRN_DIALOG *prn_dialog);
extern int	pdlg_save_default_settings 		(PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings);
extern int	pdlg_update 					(PRN_DIALOG *prn_dialog, char *document_name);
extern int	pdlg_use_settings 				(PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings);
extern int	pdlg_validate_settings			(PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings);
extern int	mt_pdlg_add_printers 			(PRN_DIALOG *prn_dialog, DRV_INFO *drv_info, INT16 *global_aes);
extern int	mt_pdlg_add_sub_dialogs 		(PRN_DIALOG *prn_dialog, PDLG_SUB *sub_dialogs, INT16 *global_aes);
extern int	mt_pdlg_close					(PRN_DIALOG *prn_dialog, INT16 *x, INT16 *y, INT16 *global_aes);
extern PRN_DIALOG* mt_pdlg_create 			(int dialog_flags, INT16 *global_aes);
extern int	mt_pdlg_delete 					(PRN_DIALOG *prn_dialog, INT16 *global_aes);
extern int	mt_pdlg_dflt_settings			(PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, INT16 *global_aes);
extern int	mt_pdlg_do						(PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, char *document_name, int option_flags, INT16 *global_aes);
extern int	mt_pdlg_evnt					(PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, EVNT *events, INT16 *button, INT16 *global_aes);
extern int	mt_pdlg_free_settings			(PRN_SETTINGS *settings, INT16 *global_aes);
extern long	mt_pdlg_get_setsize				(INT16 *global_aes);
extern PRN_SETTINGS *mt_pdlg_new_settings	(PRN_DIALOG *prn_dialog, INT16 *global_aes);
extern int	mt_pdlg_open					(PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, char *document_name, int option_flags, int x, int y, INT16 *global_aes);
extern int	mt_pdlg_remove_printers 		(PRN_DIALOG *prn_dialog, INT16 *global_aes);
extern int	mt_pdlg_remove_sub_dialogs 		(PRN_DIALOG *prn_dialog, INT16 *global_aes);
extern int	mt_pdlg_save_default_settings 	(PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, INT16 *global_aes);
extern int	mt_pdlg_update 					(PRN_DIALOG *prn_dialog, char *document_name, INT16 *global_aes);
extern int	mt_pdlg_use_settings 			(PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, INT16 *global_aes);
extern int	mt_pdlg_validate_settings		(PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, INT16 *global_aes);

/****** Listbox definitions ***********************************************/
/* from MT_AES of Andreas Kromke
*/

typedef  void  *LIST_BOX;

typedef struct _lbox_item
{
	struct _lbox_item *next;      /* Pointer to the next entry in the list */
	INT16  selected;               /* Specifies if the object is selected */

	INT16  data1;                  /* Data for the program... */
	void  *data2;
	void  *data3;

} LBOX_ITEM;

typedef  void  (__CDECL *SLCT_ITEM)( LIST_BOX *box, OBJECT *tree, LBOX_ITEM *item, void *user_data, INT16 obj_index, INT16 last_state );
typedef  INT16  (__CDECL *SET_ITEM)( LIST_BOX *box, OBJECT *tree, LBOX_ITEM *item, INT16 obj_index, void *user_data, GRECT *rect, INT16 first );



#define	LBOX_VERT   1           /* Listbox with vertical slider */
#define	LBOX_AUTO   2           /* Auto-scrolling */
#define	LBOX_AUTOSLCT  4        /* Automatic display during auto-scrolling */
#define	LBOX_REAL   8           /* Real-time slider */
#define	LBOX_SNGL   16          /* Only a selectable entry */
#define	LBOX_SHFT   32          /* Multi-selection with Shift */
#define	LBOX_TOGGLE 64          /* Toggle status of an entry at selection */
#define	LBOX_2SLDRS 128         /* Listbox has a horiz. and a vertical slider */

/* #defines for listboxes with only one slider */
#define	lbox_get_visible \
			lbox_get_avis

#define	lbox_get_first \
			lbox_get_afirst
         
#define	lbox_set_slider \
			lbox_set_asldr

#define	lbox_scroll_to \
			lbox_ascroll_to
extern LIST_BOX *mt_lbox_create( OBJECT *tree, SLCT_ITEM slct, SET_ITEM set, LBOX_ITEM *items, int visible_a, int first_a,
						  INT16 *ctrl_objs, INT16 *objs, int flags, int pause_a, void *user_data, void *dialog,
						  int visible_b, int first_b, int entries_b, int pause_b, INT16 *global_aes );

extern void	mt_lbox_update( LIST_BOX *box, GRECT *rect, INT16 *global_aes );
extern int	mt_lbox_do( LIST_BOX *box, int obj, INT16 *global_aes );
extern int	mt_lbox_delete( LIST_BOX *box, INT16 *global_aes );

extern int	mt_lbox_cnt_items( LIST_BOX *box, INT16 *global_aes );
extern OBJECT	*mt_lbox_get_tree( LIST_BOX *box, INT16 *global_aes );
extern int	mt_lbox_get_avis( LIST_BOX *box, INT16 *global_aes );
extern void	*mt_lbox_get_udata( LIST_BOX *box, INT16 *global_aes );
extern int	mt_lbox_get_afirst( LIST_BOX *box, INT16 *global_aes );
extern int	mt_lbox_get_slct_idx( LIST_BOX *box, INT16 *global_aes );
extern LBOX_ITEM	*mt_lbox_get_items( LIST_BOX *box, INT16 *global_aes );
extern LBOX_ITEM	*mt_lbox_get_item( LIST_BOX *box, int n, INT16 *global_aes );
extern LBOX_ITEM	*mt_lbox_get_slct_item( LIST_BOX *box, INT16 *global_aes );
extern int	mt_lbox_get_idx( LBOX_ITEM *items, LBOX_ITEM *search, INT16 *global_aes );
extern int	mt_lbox_get_bvis( LIST_BOX *box, INT16 *global_aes );
extern int	mt_lbox_get_bentries( LIST_BOX *box, INT16 *global_aes );
extern int	mt_lbox_get_bfirst( LIST_BOX *box, INT16 *global_aes );

extern void	mt_lbox_set_asldr( LIST_BOX *box, int first, GRECT *rect, INT16 *global_aes );
extern void	mt_lbox_set_items( LIST_BOX *box, LBOX_ITEM *items, INT16 *global_aes );
extern void	mt_lbox_free_items( LIST_BOX *box, INT16 *global_aes );
extern void	mt_lbox_free_list( LBOX_ITEM *items, INT16 *global_aes );
extern void	mt_lbox_ascroll_to( LIST_BOX *box, int first, GRECT *box_rect, GRECT *slider_rect, INT16 *global_aes );
extern void	mt_lbox_set_bsldr( LIST_BOX *box, int first, GRECT *rect, INT16 *global_aes );
extern void	mt_lbox_set_bentries( LIST_BOX *box, int entries, INT16 *global_aes );
extern void	mt_lbox_bscroll_to( LIST_BOX *box, int first, GRECT *box_rect, GRECT *slider_rect, INT16 *global_aes );

extern LIST_BOX *mt_lbox_create( OBJECT *tree, SLCT_ITEM slct, SET_ITEM set, LBOX_ITEM *items, int visible_a, int first_a,
						  INT16 *ctrl_objs, INT16 *objs, int flags, int pause_a, void *user_data, void *dialog,
						  int visible_b, int first_b, int entries_b, int pause_b, INT16 *global_aes );

extern void	mt_lbox_update( LIST_BOX *box, GRECT *rect, INT16 *global_aes );
extern int	mt_lbox_do( LIST_BOX *box, int obj, INT16 *global_aes );
extern int	mt_lbox_delete( LIST_BOX *box, INT16 *global_aes );

#define lbox_cnt_items(a) mt_lbox_cnt_items(a,aes_global)
#define lbox_get_tree(a) mt_lbox_get_tree(a,aes_global)
#define lbox_get_avis(a) mt_lbox_get_avis(a,aes_global)
#define lbox_get_udata(a) mt_lbox_get_udata(a,aes_global)
#define lbox_get_afirst(a) mt_lbox_get_afirst(a,aes_global)
#define lbox_get_slct_idx(a) mt_lbox_get_slct_idx(a,aes_global)
#define lbox_get_items(a) mt_lbox_get_items(a,aes_global)
#define lbox_get_item(a,b) mt_lbox_get_item(a,b,aes_global)
#define lbox_get_slct_item(a) mt_lbox_get_slct_item(a,aes_global)
#define lbox_get_idx(a,b) mt_lbox_get_idx(a,b,aes_global)
#define lbox_get_bvis(a) mt_lbox_get_bvis(a,aes_global)
#define lbox_get_bentries(a) mt_lbox_get_bentries(a,aes_global)
#define lbox_get_bfirst(a) mt_lbox_get_bfirst(a,aes_global)
#define lbox_set_asldr(a,b,c) mt_lbox_set_asldr(a,b,c,aes_global)
#define lbox_set_items(a,b) mt_lbox_set_items(a,b,aes_global)
#define lbox_free_items(a) mt_lbox_free_items(a,aes_global)
#define lbox_free_list(a) mt_lbox_free_list(a,aes_global)
#define lbox_ascroll_to(a,b,c,d) mt_lbox_ascroll_to(a,b,c,d,aes_global)
#define lbox_set_bsldr(a,b,c) mt_lbox_set_bsldr(a,b,c,aes_global)
#define lbox_set_bentries(a,b) mt_lbox_set_bentries(a,b,aes_global)
#define lbox_bscroll_to(a,b,c,d) mt_lbox_bscroll_to(a,b,c,d,aes_global)

/****** Wdialog definitions ***********************************************/
/* from MT_AES of Andreas Kromke */

typedef  void  *DIALOG;
                  
typedef  INT16  (__CDECL *HNDL_OBJ)( DIALOG *dialog, EVNT *events, INT16 obj, INT16 clicks, void *data );

extern DIALOG  *MT_wdlg_create( HNDL_OBJ handle_exit, OBJECT *tree, void *user_data, int code, void *data, int flags, INT16 *global );
extern int	MT_wdlg_open( DIALOG *dialog, char *title, int kind, int x, int y, int code, void *data, INT16 *global );
extern int	MT_wdlg_close( DIALOG *dialog, INT16 *x, INT16 *y, INT16 *global );
extern int	MT_wdlg_delete( DIALOG *dialog, INT16 *global );

extern int	MT_wdlg_get_tree( DIALOG *dialog, OBJECT **tree, GRECT *r, INT16 *global );
extern int	MT_wdlg_get_edit( DIALOG *dialog, INT16 *cursor, INT16 *global );
extern void	*MT_wdlg_get_udata( DIALOG *dialog, INT16 *global );
extern int	MT_wdlg_get_handle( DIALOG *dialog, INT16 *global );

extern int	MT_wdlg_set_edit( DIALOG *dialog, int obj, INT16 *global );
extern int	MT_wdlg_set_tree( DIALOG *dialog, OBJECT *tree, INT16 *global );
extern int	MT_wdlg_set_size( DIALOG *dialog, GRECT *size, INT16 *global );
extern int	MT_wdlg_set_iconify( DIALOG *dialog, GRECT *g, char *title, OBJECT *tree, int obj, INT16 *global );
extern int	MT_wdlg_set_uniconify( DIALOG *dialog, GRECT *g, char *title, OBJECT *tree, INT16 *global );

extern int	MT_wdlg_evnt( DIALOG *dialog, EVNT *events );
extern void	MT_wdlg_redraw( DIALOG *dialog, GRECT *rect, int obj, int depth );


#define wdlg_create(a,b,c,d,e,f) mt_wdlg_create(a,b,c,d,e,f,aes_global)
#define wdlg_open(a,b,c,d,e,f,g) mt_wdlg_open(a,b,c,d,e,f,g,aes_global)
#define wdlg_close(a,b,c) mt_wdlg_close(a,b,c,aes_global)
#define wdlg_delete(a) mt_wdlg_delete(a,aes_global)
#define wdlg_get_tree(a,b,c) mt_wdlg_get_tree(a,b,c,aes_global)
#define wdlg_get_edit(a,b) mt_wdlg_get_edit(a,b,aes_global)
#define wdlg_get_udata(a) mt_wdlg_get_udata(a,aes_global)
#define wdlg_get_handle(a) mt_wdlg_get_handle(a,aes_global)
#define wdlg_set_edit(a,b) mt_wdlg_set_edit(a,b,aes_global)
#define wdlg_set_tree(a,b) mt_wdlg_set_tree(a,b,aes_global)
#define wdlg_set_size(a,b) mt_wdlg_set_size(a,b,aes_global)
#define wdlg_set_iconify(a,b,c,e,f) mt_wdlg_set_iconify(a,b,c,e,f,aes_global)
#define wdlg_set_uniconify(a,b,c,d) mt_wdlg_set_uniconify(a,b,c,d,aes_global)
#define wdlg_evnt(a,b) mt_wdlg_evnt(a,b,aes_global)
#define wdlg_redraw(a,b,c,d) mt_wdlg_redraw(a,b,c,d,aes_global)


/* Definitions for <flags> */
#define  WDLG_BKGD   1           /* Permit background operation */

/* Function numbers for <obj> with handle_exit(...) */
#define  HNDL_INIT   -1          /* Initialise dialog */
#define  HNDL_MESG   -2          /* Initialise dialog */
#define  HNDL_CLSD   -3          /* Dialog window was closed */
#define  HNDL_OPEN   -5          /* End of dialog initialisation (second  call at end of wdlg_init) */
#define  HNDL_EDIT   -6          /* Test characters for an edit-field */
#define  HNDL_EDDN   -7          /* Character was entered in edit-field */
#define  HNDL_EDCH   -8          /* Edit-field was changed */
#define  HNDL_MOVE   -9          /* Dialog was moved */
#define  HNDL_TOPW   -10         /* Dialog-window has been topped */
#define  HNDL_UNTP   -11         /* Dialog-window is not active */

/******************************************************************************
* Editor extensions for Magic from MT_EDIT of Andreas Kromke
*/

#define G_EDIT 37

typedef void XEDITINFO;
extern XEDITINFO *mt_edit_create( INT16 *global );
extern int mt_edit_open(OBJECT *tree, int obj, INT16 *global);
extern void mt_edit_close(OBJECT *tree, int obj, INT16 *global);
extern void mt_edit_delete(XEDITINFO *xi, INT16 *global);
extern int mt_edit_cursor(OBJECT *tree, int obj, int whdl, int show, INT16 *global);
extern int mt_edit_evnt(OBJECT *tree, int obj, int whdl,	EVNT *ev, long *errc, INT16 *global);
extern int mt_edit_get_buf( OBJECT *tree, int obj, char **buf, long *buflen, long *txtlen, INT16 *global );
extern int mt_edit_get_format( OBJECT *tree, int obj, INT16 *tabwidth, INT16 *autowrap, INT16 *global );
extern int mt_edit_get_colour( OBJECT *tree, int obj, INT16 *tcolour, INT16 *bcolour, INT16 *global );
extern int mt_edit_get_cursor( OBJECT *tree, int obj, char **cursorpos, INT16 *global );
extern int mt_edit_get_font( OBJECT *tree, int obj,	INT16 *fontID, INT16 *fontH, INT16 *fontPix, INT16 *mono, INT16 *global );
extern void mt_edit_set_buf( OBJECT *tree, int obj, char *buf, long buflen, INT16 *global );
extern void mt_edit_set_format( OBJECT *tree, int obj, int tabwidth, int autowrap, INT16 *global );
extern void mt_edit_set_font( OBJECT *tree, int obj, int fontID, int fontH, int fontPix, int mono, INT16 *global );
extern void mt_edit_set_colour( OBJECT *tree, int obj, int tcolour, int bcolour, INT16 *global );
extern void mt_edit_set_cursor( OBJECT *tree, int obj, char *cursorpos, INT16 *global );
extern int mt_edit_resized( OBJECT *tree, int obj, INT16 *oldrh, INT16 *newrh, INT16 *global );
extern int mt_edit_get_dirty( OBJECT *tree, int obj,	INT16 *global );
extern void mt_edit_set_dirty( OBJECT *tree, int obj,	int dirty, INT16 *global );
extern void mt_edit_get_sel( OBJECT *tree, int obj, char **bsel, char **esel, INT16 *global );
extern void mt_edit_get_pos( OBJECT *tree, int obj, INT16 *xscroll, long *yscroll, char **cyscroll, char **cursorpos, INT16 *cx, INT16 *cy, INT16 *global );
extern void mt_edit_set_pos( OBJECT *tree, int obj, int xscroll, long yscroll, char *cyscroll, char *cursorpos, int cx, int cy, INT16 *global );
extern void mt_edit_get_scrollinfo( OBJECT *tree, int obj,	long *nlines, long *yscroll, INT16 *yvis, INT16 *yval, INT16 *ncols, INT16 *xscroll, INT16 *xvis, INT16 *global );
extern int mt_edit_scroll( OBJECT *tree, int obj, int whdl, long yscroll, int xscroll, INT16 *global );

#define edit_create() mt_edit_create(aes_global)
#define edit_open(a,b) mt_edit_open(a,b,aes_global)
#define edit_close(a,b) mt_edit_close(a,b,aes_global)
#define edit_delete(a) mt_edit_delete(a,aes_global)
#define edit_cursor(a,b,c,d) mt_edit_cursor(a,b,c,d,aes_global)
#define edit_evnt(a,b,c,d,e) mt_edit_evnt(a,b,c,d,e,aes_global)
#define edit_get_buf(a,b,c,d,e) mt_edit_get_buf(a,b,c,d,e,aes_global)
#define edit_set_buf(a,b,c,d) mt_edit_set_buf(a,b,c,d,aes_global)
#define edit_set_format(a,b,c,d) mt_edit_set_format(a,b,c,d,aes_global)
#define edit_get_format(a,b,c,d) mt_edit_get_format(a,b,c,d,aes_global)
#define edit_set_font(a,b,c,d,e,f) mt_edit_set_font(a,b,c,d,e,f,aes_global)
#define edit_get_font(a,b,c,d,e,f) mt_edit_get_font(a,b,c,d,e,f,aes_global)
#define edit_set_colour(a,b,c,d) mt_edit_set_colour(a,b,c,d,aes_global)
#define edit_resized(a,b,c,d) mt_edit_resized(a,b,c,d,aes_global)
#define edit_get_dirty(a,b) mt_edit_get_dirty(a,b,aes_global)
#define edit_set_dirty(a,b,c) mt_edit_set_dirty(a,b,c,aes_global)
#define edit_get_sel(a,b,c,d) mt_edit_get_sel(a,b,c,d,aes_global)
#define edit_get_pos(a,b,c,d,e,f,g,h) mt_edit_get_pos(a,b,c,d,e,f,g,h,aes_global)
#define edit_set_pos(a,b,c,d,e,f,g,h) mt_edit_set_pos(a,b,c,d,e,f,g,h,aes_global)
#define edit_get_scrollinfo(a,b,c,d,e,f,g,h,i) mt_edit_get_scrollinfo(a,b,c,d,e,f,g,h,i,aes_global)
#define edit_scroll(a,b,c,d,e) mt_edit_scroll(a,b,c,d,e,aes_global)



/*******************************************************************************
 * The VDI extensions of NVDI/FSM/Speedo
*/
/*
 * The following functions requires EdDI version 1.x or higher
*/
extern void		v_clsbm				(int handle);
extern void		v_opnbm				(INT16 *work_in, MFDB *bitmap, INT16 *handle, INT16 *work_out);
extern void		vq_scrninfo			(int handle, INT16 *work_out);
/*
 * The following functions requires NVDI version 2.x or higher
*/
extern int		v_bez_on			(int handle);
extern void		v_bez_off			(int handle);
extern void		v_bez				(int handle, int count, INT16 *xyarr, char *bezarr, INT16 *extent, INT16 *totpts, INT16 *totmoves);
extern void		v_bez_fill			(int handle, int count, INT16 *xyarr, char *bezarr, INT16 *extent, INT16 *totpts, INT16 *totmoves);
extern void 	v_bez_qual	 		(int handle, int percent, INT16 *actual);
/*
 * The following functions requires NVDI version 3.x or higher
*/

typedef struct
{
	long	size;
	INT16	format;
	INT16	id;
	INT16	index;
	char	font_name[50];
	char	family_name[50];
	char	style_name[50];
	char	file_name1[200];
	char	file_name2[200];
	char	file_name3[200];
	INT16	pt_cnt;
	INT16	pt_sizes[64];
} XFNT_INFO;

extern void		v_ftext				(int handle, int x, int y, char *str) ;
extern void		v_ftext16			(int handle, int x, int y, const INT16 *wstr, int wstrlen) ;
extern void		v_ftext_offset		(int handle, int x, int y, char *str, INT16 *offset);
extern void		v_ftext_offset16	(int handle, int x, int y, INT16 *wstr,int wstrlen, INT16 *offset);
extern void		v_getbitmap_info	(int handle, int ch, long *advancex, long *advancey, long *xoffset, long *yoffset, INT16 *width, INT16 *height, INT16 **bitmap);
extern void		v_getoutline		(int handle, int ch, INT16 *xyarray, char *bezarray, int maxverts, INT16 *numverts);
extern void		vqt_devinfo			(int handle, int device, INT16 *dev_open, char *file_name, char *device_name);
extern int		vq_ext_devinfo	 	(int handle, int device, INT16 *dev_exists, char *file_path, char *file_name, char *name);
extern void		vqt_advance			(int handle, int ch, long *advx, long *advy, long *xrem, long *yrem);
extern void		vqt_advance32		(int handle, int ch, long *advx, long *advy);
extern int		vqt_ext_name	 	(int handle, int index, char *name, INT16 *font_format, INT16 *flags);
extern void		vqt_f_extent		(int handle, char *str, INT16 extent[]);
extern void		vqt_fontheader		(int handle, char *buffer, char *pathname);
extern int		vqt_name_and_id		(int handle, int font_format, char *font_name, char *ret_name);
extern void		vqt_pairkern		(int handle, int ch1, int ch2, long *x, long *y);
extern void		vqt_real_extent		(int handle, int x, int y, char *string, INT16 extent[]);
extern void		vqt_trackkern		(int handle, long *x, long *y);
extern int		vqt_xfntinfo		(int handle, int flags, int id, int index, XFNT_INFO *info);
extern int  	vst_arbpt 			(int handle, int point, INT16 *wchar, INT16 *hchar, INT16 *wcell, INT16 *hcell);
extern long  	vst_arbpt32 		(int handle, long point, INT16 *wchar, INT16 *hchar, INT16 *wcell, INT16 *hcell);
extern int 		vst_charmap 		(int handle, int mode);
extern void 	vst_kern			(int handle, int tmode, int pmode, INT16 *tracks, INT16 *pairs);
extern int 		vst_name 			(int handle, int font_format, char *font_name, char *ret_name);
extern INT16 	vst_setsize 		(int handle, int point, INT16 *wchar, INT16 *hchar, INT16 *wcell, INT16 *hcell);
extern long 	vst_setsize32 		(int handle, long point, INT16 *wchar, INT16 *hchar, INT16 *wcell, INT16 *hcell);
extern int 		vst_skew 			(int handle, int skew);
extern void 	vst_track_offset	(int handle, long offset, int pairmode, INT16 *tracks, INT16 *pairs);
extern void 	vst_width			(int handle, int width, INT16 *char_width, INT16 *char_height, INT16 *cell_width, INT16 *cell_height);
/*
 * The following functions requires NVDI version 4.x or higher
*/
extern int	vqt_char_index		(int handle, int scr_index, int scr_mode, int dst_mode);
/*
 * The following functions requires NVDI version 5.x or higher
*/
typedef struct
{
	unsigned INT16	reserved;
	unsigned INT16	red;
	unsigned INT16	green;
	unsigned INT16	blue;
} COLOR_RGB;

typedef struct
{
	unsigned INT16	cyan;
	unsigned INT16	magenta;
	unsigned INT16	yellow;
	unsigned INT16	black;
} COLOR_CMYK;

typedef union
{
	COLOR_RGB	rgb;
	COLOR_CMYK	cmyk;
} COLOR_ENTRY;

typedef struct
{
	long	magic;
	long	length;
	long	format;
	long	reserved;
	long	map_id;
	long	color_space;
	long	flags;
	long	no_colors;
	long	reserved1;
	long	reserved2;
	long	reserved3;
	long	reserved4;

#ifdef __GNUC__
/*
 * this should be a variable array but GNU does'nt accept this :-((
*/
	COLOR_ENTRY	colors[1];
#else
	COLOR_ENTRY	colors[];
#endif
} COLOR_TAB;

typedef COLOR_TAB		*CTAB_PTR;
typedef COLOR_TAB		*CTAB_REF;
typedef void			 INVERSE_CTAB;
typedef INVERSE_CTAB	*ITAB_REF;

typedef struct	_gcbitmap
{
	long				magic;
	long				length;
	long				format;
	long				reserved;
	unsigned char		*addr;
	long				 width;
	long				 bits;
	unsigned long		 px_format;
	long				xmin;
	long				ymin;
	long				xmax;
	long				ymax;
	CTAB_REF			*ctab;
	ITAB_REF 			*itab;
	long				 reserved0;
	long				 reserved1;
} GCBITMAP;

extern long		v_color2nearest			(int handle, long color_space, COLOR_ENTRY *color, COLOR_ENTRY *nearest_color);
extern unsigned long v_color2value		(int handle, long color_space, COLOR_ENTRY *color);
extern COLOR_TAB *v_create_ctab			(int handle, long color_space, unsigned long px_format);
extern ITAB_REF v_create_itab			(int handle, COLOR_TAB *ctab, int bits );
extern unsigned long v_ctab_idx2value	(int handle, int index );
extern int		v_ctab_idx2vdi			(int handle, int index);
extern int		v_ctab_vdi2idx			(int handle, int vdi_index);
extern int		v_delete_ctab			(int handle, COLOR_TAB *ctab);
extern int		v_delete_itab			(int handle, ITAB_REF itab);
extern long		v_get_ctab_id			(int handle);
extern int		v_get_outline			(int handle, int index, int x_offset, int y_offset, INT16 *pts, char *flags, int max_pts);
extern int		v_opnprn				(int aes_handle, PRN_SETTINGS *settings, INT16 work_out[]);
extern int		v_resize_bm				(int handle, int width, int height, long b_width, unsigned char *addr);
extern void		v_setrgb				(int handle, int type, int r, int g, int b);
extern long		v_value2color			(int handle, unsigned long value, COLOR_ENTRY *color);
extern int		vq_ctab					(int handle, long ctab_length, COLOR_TAB *ctab);
extern long		vq_ctab_entry			(int handle, int index, COLOR_ENTRY *color);
extern long		vq_ctab_id				(int handle);
extern int		vq_dflt_ctab			(int handle, long ctab_length, COLOR_TAB *ctab);
extern long		vq_hilite_color			(int handle, COLOR_ENTRY *hilite_color);
extern int		vq_margins				(int handle, INT16 *top_margin, INT16 *bottom_margin, INT16 *left_margin, INT16 *right_margin, INT16 *hdpi, INT16 *vdpi);
extern long		vq_max_color			(int handle, COLOR_ENTRY *hilite_color);
extern long		vq_min_color			(int handle, COLOR_ENTRY *hilite_color);
extern long		vq_prn_scaling			(int handle);
extern long		vq_px_format			(int handle, unsigned long *px_format);
extern long		vq_weight_color			(int handle, COLOR_ENTRY *hilite_color);
extern long		vqf_bg_color			(int handle, COLOR_ENTRY *fg_color);
extern long		vqf_fg_color			(int handle, COLOR_ENTRY *fg_color);
extern long		vql_bg_color			(int handle, COLOR_ENTRY *fg_color);
extern long		vql_fg_color			(int handle, COLOR_ENTRY *fg_color);
extern long		vqm_bg_color			(int handle, COLOR_ENTRY *fg_color);
extern long		vqm_fg_color			(int handle, COLOR_ENTRY *fg_color);
extern long		vqr_bg_color			(int handle, COLOR_ENTRY *fg_color);
extern long		vqr_fg_color			(int handle, COLOR_ENTRY *fg_color);
extern long		vqt_bg_color			(int handle, COLOR_ENTRY *fg_color);
extern long		vqt_fg_color			(int handle, COLOR_ENTRY *fg_color);
extern void		vr_transfer_bits		(int handle, GCBITMAP *src_bm, GCBITMAP *dst_bm, INT16 *src_rect, INT16 *dst_rect, int mode);
extern int		vs_ctab					(int handle, COLOR_TAB *ctab);
extern int		vs_ctab_entry			(int handle, int index, long color_space, COLOR_ENTRY *color);
extern int		vs_dflt_ctab			(int handle);
extern int		vs_document_info		(int vdi_handle, int type, char *s, int wchar);
extern int		vs_hilite_color			(int handle, long color_space, COLOR_ENTRY *hilite_color);
extern int		vs_max_color			(int handle, long color_space, COLOR_ENTRY *min_color);
extern int		vs_min_color			(int handle, long color_space, COLOR_ENTRY *min_color);
extern int		vs_weight_color			(int handle, long color_space, COLOR_ENTRY *weight_color);
extern int		vsf_bg_color			(int handle, long color_space, COLOR_ENTRY *bg_color);
extern int		vsf_fg_color			(int handle, long color_space, COLOR_ENTRY *fg_color);
extern int		vsl_bg_color			(int handle, long color_space, COLOR_ENTRY *bg_color);
extern int		vsl_fg_color			(int handle, long color_space, COLOR_ENTRY *fg_color);
extern int		vsm_bg_color			(int handle, long color_space, COLOR_ENTRY *bg_color);
extern int		vsm_fg_color			(int handle, long color_space, COLOR_ENTRY *fg_color);
extern int		vsr_bg_color			(int handle, long color_space, COLOR_ENTRY *bg_color);
extern int		vsr_fg_color			(int handle, long color_space, COLOR_ENTRY *fg_color);
extern int		vst_bg_color			(int handle, long color_space, COLOR_ENTRY *bg_color);
extern int		vst_fg_color			(int handle, long color_space, COLOR_ENTRY *fg_color);
#ifdef __cplusplus
}
#endif
#endif
