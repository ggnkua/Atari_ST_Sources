/*
 *  Extension of Pure C GEM library
 *
 *  Version 1.1  (september 2001)
 *
 *  Dominique BÇrÇziat
 *
 *  This file complets definitions of AES.H and VDI.H for modern
 *  GEM interface and give interface of new functions binded
 *  in PCGMXLIB.LIB
 *
 *  version 1.0 : first version released with WinDom
 *  version 1.1 : adding some constants not defined in AES.H
 *                adding rc_intersect function
 *				  adding wind_set_str, wind_set_grect,
 *                       wind_get_str and wind_get_grect macros
 */

#ifndef _PCGEMX_H_
#define _PCGEMX_H_


/***********************************************************
 * Special AES 3.4 and AES 4 definitions
 */

#ifndef G_CICON
#define G_CICON			33
typedef struct cicon_data {
		WORD	num_planes;
		WORD	*col_data;
		WORD	*col_mask;
		WORD	*sel_data;
		WORD	*sel_mask;
		struct cicon_data *next_res;
} CICON;

typedef struct cicon_blk {
		ICONBLK monoblk;
		CICON	*mainlist;
} CICONBLK;
#endif

#ifndef SMALLER
#define SMALLER 0x4000
#endif

#ifndef WF_BOTTOM
#define WF_BOTTOM			25
#endif


/*#ifndef WF_ICONIFY*/ /* YD 23/04/07 */
#define WF_ICONIFY			26
#define WF_UNICONIFY		27	
#define WF_UNICONIFYXYWH 	28
#define WF_TOOLBAR			30
#define WF_FTOOLBAR			31
#define WF_NTOOLBAR			32
/*#endif*/

#ifndef WM_ICONIFY
#define WM_ICONIFY		34
#define WM_UNICONIFY	35
#define WM_ALLICONIFY	36
#define WM_TOOLBAR		37
#define	WM_BOTTOM		33
#define WM_BOTTOMED		WM_BOTTOM
#endif

#ifndef AP_TERM
#define AP_TERM			50
#define AP_TFAIL        51
#define AP_RESCHG       57
#define SHUT_COMPLETED  60
#define RESCHG_COMPLETED  61
#define CH_EXIT         80
#endif

#define M_SAVE		258
#define M_RESTORE	260

#ifndef FNT_CHANGED
#define FNT_CHANGED 83
#endif


/*******************************************************************************
 * Compatibilith with classic GEM headers
 */
typedef bfobspec BFOBSPEC;

/*******************************************************************************
 * Completion of AES standard call not binded in PCGEMLIB
 */

/* appl_getinfo() */
#define AES_LARGEFONT	0
#define AES_SMALLFONT	1
#define AES_SYSTEM		2
#define AES_LANGUAGE	3
#define AES_PROCESS		4
#define AES_PCGEM		5
#define AES_INQUIRE		6
#define AES_EXTENSION	7
#define AES_MOUSE		8
#define AES_MENU		9
#define AES_SHELL		10
#define AES_WINDOW 		11
#define AES_MESSAGE		12
#define AES_OBJECT		13
#define AES_FORM		14

/* appl_control() mode */
#define APC_HIDE	10
#define APC_SHOW	11
#define APC_TOP		12
#define APC_HIDENOT	13

/* objc_sysvar() mode */
#define SV_INQUIRE	0
#define SV_SET		1

/* objc_sysvar() which */
#define LK3DIND		1
#define LK3DACT		2
#define INDBUTCOL	3
#define ACTBUTCOL	4
#define BACKGRCOL	5
#define AD3DVAL		6

/* appl_search() */
#define APP_FIRST 0
#define APP_NEXT 1

int appl_control( int ap_cid, int ap_cwhat, void *ap_cout);
int appl_getinfo( int type, int *out1, int *out2, int *out3, int *out4);
int objc_sysvar	( int mode, int which, int in1, int in2, int *out1, int *out2);

/*
 * For better compatibility with GemLib
 */

#define wind_set_str	wind_set
#define wind_set_grect  wind_set
#define wind_get_str	wind_get
#define wind_get_grect(h,m,g)	wind_get(h,m,&(g)->g_x,&(g)->g_y,&(g)->g_w,&(g)->g_h);

#define	_AESversion   (_GemParBlk.global[0])
#define	_AESnumapps   (_GemParBlk.global[1])
#define	_AESapid 	  (_GemParBlk.global[2])
#define	_AESappglobal (*((long *)&_GemParBlk.global[3]))
#define	_AESrscfile   ((OBJECT **)(*((long *)&_GemParBlk.global[5])))
#define	_AESmaxchar   (_GemParBlk.global[13])
#define	_AESminchar   (_GemParBlk.global[14])

/*
 * Usefull functions defined in GemLib
 */

int rc_intersect( GRECT *, GRECT *);
void grect_to_array( const GRECT *rect, int *array);
 
/*******************************************************************************
 * The AES extensions of MagiC
 */

#ifndef SM_M_SPECIAL
#define SM_M_SPECIAL    101
#define SMC_TIDY_UP		0
#define SMC_TERMINATE	1
#define SMC_SWITCH		2
#define SMC_FREEZE		3
#define SMC_UNFREEZE	4
#define SMC_RES5		5
#define SMC_UNHIDEALL	6
#define SMC_HIDEOTHERS	7
#define SMC_HIDEACT		8
#endif

typedef struct {
	short mwhich;		 	/* Art der Ereignisse					  */
	short mx;				/* x-Koordinate des Mauszeigers 	  */
	short my;				/* y-Koordinate des Mauszeigers 	  */
	short mbutton; 			/* gedrÅckte Maustaste 				  */
	short kstate;			/* Status der Sondertasten (kbshift)  */
	short key;				/* Scancode der gedrÅckten Taste	  */
	short mclicks; 			/* Anzahl der Mausklicks			*/
	short reserved[9];		/* reserviert 							  */
	short msg[16]; 			/* Message-Buffer 					  */
} EVNT;

/*
 * Extensions to the form library (MagiC only)
 */

typedef struct {
	char	scancode;
	char	nclicks;
	short objnr;
} SCANX;

typedef struct {
	SCANX *unsh;			/* Tabellen fÅr UnShift-Kombinationen	 */
	SCANX *shift;			/* Tabellen fÅr Shift-Kombinationen 	*/
	SCANX *ctrl;			/* Tabellen fÅr Control-Kombinationen	 */
	SCANX *alt; 			/* Tabellen fÅr Alternate-Kombinationen */
	void	*resvd;			/* reserviert */
} XDO_INF;

int form_popup 	( OBJECT *tree, int x, int y);
int form_wbutton( OBJECT *fo_btree, int fo_bobject, int fo_bclicks, int *fo_bnxtobj, int whandle);
int form_wkeybd	( OBJECT *fo_ktree, int fo_kobject, int fo_kobnext, int fo_kchar, int *fo_knxtobject, int *fo_knxtchar, int whandle);
int form_xdial 	( int fo_diflag, int fo_dilittlx, int fo_dilittly, int fo_dilittlw, int fo_dilittlh, int fo_dibigx, int fo_dibigy, int fo_dibigw, int fo_dibigh, void **flydial);
int form_xdo	( OBJECT *tree, int startob, int *lastcrsr, XDO_INF *tabs, void *flydial); 
int form_xerr	( long errcode, char *errfile);


/*
 * Extensions to the object library (MagiC only)
 */

void objc_wchange	( OBJECT *tree, int obj, int new_state, GRECT *clip,  int whandle);
void objc_wdraw		( OBJECT *tree, int start, int depth, GRECT *clip,  int whandle);
int	 objc_wedit		( OBJECT *tree, int obj, int key, int *idx, int kind, int whandle);
int	 objc_xedit		( OBJECT *tree, int obj, int key, int *xpos, int subfn, GRECT *r);

/*
 * fnts_*	font selection (MagiC/WDIALOG only)
 */

typedef void *FNT_DIALOG;
typedef void (cdecl *UTXT_FN)(short x, short y, short *clip_rect, long id, long pt, long ratio, char *string);

typedef struct _fnts_item {
	struct	_fnts_item	*next;		/* Zeiger auf den nÑchsten Font oder 0L (Ende der Liste) */
	UTXT_FN	display; 				/* Zeiger auf die Anzeige-Funktion fÅr applikationseigene Fonts */
	long	id;						/* ID des Fonts, >= 65536 fÅr applikationseigene Fonts */
	short 	index;					/* Index des Fonts (falls VDI-Font) */
	char	mono; 					/* Flag fÅr Ñquidistante Fonts */
	char	outline; 				/* Flag fÅr Vektorfont */
	short 	npts; 					/* Anzahl der vordefinierten Punkthîhen */
	char	*full_name; 			/* Zeiger auf den vollstÑndigen Namen */
	char	*family_name;			/* Zeiger auf den Familiennamen */
	char	*style_name;			/* Zeiger auf den Stilnamen */
	char	*pts; 					/* Zeiger auf Feld mit Punkthîhen */
	long	reserved[4];			/* reserviert, mÅssen 0 sein */
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
#define FNTS_SET		3			/* "setzen" wurde angewÑhlt */
#define FNTS_MARK 		4			/* "markieren" wurde betÑtigt */
#define FNTS_OPT		5			/* der applikationseigene Button wurde ausgewÑhlt */

int			fnts_add 			( FNT_DIALOG *fnt_dialog, FNTS_ITEM *user_fonts);
int			fnts_close			( FNT_DIALOG *fnt_dialog, int *x, int *y);
FNT_DIALOG* fnts_create			( int vdi_handle, int no_fonts, int font_flags, int dialog_flags, char *sample, char *opt_button);
int			fnts_delete 		( FNT_DIALOG *fnt_dialog, int vdi_handle);
int			fnts_do				( FNT_DIALOG *fnt_dialog, int button_flags, long id_in, long pt_in, long ratio_in, int *check_boxes, long *id, long *pt, long *ratio);
int			fnts_evnt			( FNT_DIALOG *fnt_dialog, EVNT *events, int *button, int *check_boxes, long *id, long *pt, long *ratio);
int			fnts_get_info		( FNT_DIALOG *fnt_dialog, long id, int *mono, int *outline);
int			fnts_get_name		( FNT_DIALOG *fnt_dialog, long id, char *full_name, char *family_name, char *style_name);
int			fnts_get_no_styles	( FNT_DIALOG *fnt_dialog, long id);
long		fnts_get_style 		( FNT_DIALOG *fnt_dialog, long id, int index);
int			fnts_open			( FNT_DIALOG *fnt_dialog, int button_flags, int x, int y, long id, long pt, long ratio);
void 		fnts_remove 		( FNT_DIALOG *fnt_dialog);
int			fnts_update 		( FNT_DIALOG *fnt_dialog, int button_flags, long id, long pt, long ratio);


/*
 * fslx_*	file selection (MagiC only)
 */

typedef int (cdecl *XFSL_FILTER)(char *path, char *name, void *xattr);

/* Sortiermodi */
#define SORTBYNAME	0
#define SORTBYDATE	1
#define SORTBYSIZE	2
#define SORTBYTYPE	3
#define SORTBYNONE	4

/* Flags fÅr Dateiauswahl */
#define DOSMODE		1
#define NFOLLOWSLKS	2
#define GETMULTI	8

/* fslx_set_flags */
#define SHOW8P3		1

int		fslx_close		( void *fsd);
void*	fslx_do			( char *title, char *path, int pathlen, char *fname, int fnamelen, char *patterns, XFSL_FILTER filter, char *paths, int *sort_mode, int flags, int *button, int *nfiles, char **pattern);
int		fslx_evnt		( void *fsd, EVNT *events, char *path, char *fname, int *button, int *nfiles, int *sort_mode, char **pattern); 
int		fslx_getnxtfile	( void *fsd, char *fname);
void*	fslx_open		( char *title, int x, int y, int *handle, char *path, int pathlen, char *fname, int fnamelen, char *patterns, XFSL_FILTER filter, char *paths, int sort_mode, int flags);
int		fslx_set_flags 	( int flags, int *oldval);

/*
 * pdlg_*	printer configuration dialogs (WDIALOG only)
 */

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

	long	size_id; 						/* Kennung des Papierformats */
	char	name[32];						/* Name des Papierformats */
} MEDIA_SIZE;

typedef struct _media_type 					/* Beschreibung eines Papiertyps/Druckmediums */
{
	struct _media_type	*next;

	long	type_id; 						/* Kennung des Papierformats */
	char	name[32];						/* Name des Papierformats */
} MEDIA_TYPE;

typedef struct _prn_mode						/* Beschreibung eines Druckermodus */
{
	struct _prn_mode *next; 					/* Zeiger auf den nÑchsten Druckermodus */

	long	mode_id; 						/* Moduskennung (Index innerhalb der Datei) */
	short 	hdpi; 							/* horizontale Auflîsung in dpi */
	short 	vdpi; 							/* vertikale Auflîsung in dpi */
	long	mode_capabilities;			/* Moduseigenschaften */

	long	color_capabilities;			/* einstellbare Farbmodi */
	long	dither_flags;					/* Flags, die angeben, ob der korrespondierende Farbmodus mit oder ohne Dithern ansprechbar ist */
	MEDIA_TYPE	*paper_types;					/* geeignete Papiertypen */
	long	reserved;

	char	name[32];						/* Modusname */
} PRN_MODE;

/* sub_flags */
#define	PRN_STD_SUBS	0x0001				/* Standard-Unterdialoge fÅr NVDI-Drucker */
#define	PRN_FSM_SUBS	0x0002				/* Standard-Unterdialoge fÅr FSM-Drucker */
#define	PRN_QD_SUBS 	0x0004				/* Standard-Unterdialoge fÅr QuickDraw-Drucker */

/* old_printer kann auch 0L sein */
typedef long (cdecl *PRN_SWITCH)(struct _drv_entry *drivers, struct _prn_settings *settings, struct _prn_entry *old_printer, struct _prn_entry *new_printer);

typedef struct _prn_entry						/* GerÑtebeschreibung */
{
	struct _prn_entry *next;					/* Zeiger auf die die nÑchste GerÑtebeschreibung */
	long		length;							/* StrukturlÑnge */
	long		format;							/* Datenformat */
	long		reserved;						/* reserviert */
	
	short 		driver_id;						/* Treiberkennung */
	short 		driver_type;					/* Treibertyp */
	long		printer_id; 					/* Druckerkennung */
	long		printer_capabilities;		/* Druckereigenschaften */
	long		reserved1;

	long		sub_flags;						/* Flags fÅr die Unterdialoge */
	struct _pdlg_sub	*sub_dialogs;			/* Zeiger auf die Liste der Unterdialoge fÅr diesen Drucker */
	PRN_SWITCH	setup_panel;					/* Unterdialog bei Druckerwechsel initialisieren */
	PRN_SWITCH	close_panel;					/* Unterdialog bei Druckerwechsel schlieûen */

	PRN_MODE 	*modes;							/* Liste der vorhandenen Auflîsungen */
	MEDIA_SIZE	*papers; 						/* Liste der vorhandenen Papierformate */
	PRN_TRAY 	*input_trays;					/* Liste der EinzÅge */
	PRN_TRAY 	*output_trays; 				/* Liste der AuswÅrfe */

	char		name[32];						/* Name des Druckers */
} PRN_ENTRY;

typedef struct _dither_mode
{
	struct _dither_mode	*next;
	long		length;							/* StrukturlÑnge */
	long		format;							/* Datenformat */
	long		reserved;						/* reserviert */

	long		dither_id;						/* Kennung */
	long		color_modes;					/* unterstÅtzte Farbtiefen */
	long		reserved1;
	long		reserved2;

	char		name[32];						/* Name des Rasterverfahrens */
} DITHER_MODE;


typedef struct {
	long		magic;							/* 'pdnf' */
	long		length;							/* StrukturlÑnge */
	long		format;							/* Datenformat */
	long		reserved;						/* reserviert */

	short 		driver_id;						/* Treibernummer fÅrs VDI */
	short 		driver_type;					/* Treibertyp */
	long		reserved1;
	long		reserved2;
	long		reserved3;

	PRN_ENTRY	*printers;						/* Liste der zum Treiber gehîrenden Drucker */
	DITHER_MODE *dither_modes; 				/* Liste der vom Treiber unterstÅtzten Rasterverfahren */
	long		reserved4;
	long		reserved5;

	long		reserved6;
	long		reserved7;
	long		reserved8;
	long		reserved9;
	
	char		device[128];					/* Ausgabedatei des Druckertreibers */
	
} DRV_INFO;

typedef struct _drv_entry
{
	struct _drv_entry *next;
} DRV_ENTRY;

#define	PDLG_CHG_SUB	0x80000000L
#define	PDLG_IS_BUTTON 0x40000000L

#define	PDLG_PREBUTTON 0x20000000L
#define	PDLG_PB_OK		1
#define	PDLG_PB_CANCEL 2
#define	PDLG_PB_DEVICE 3

#define	PDLG_BUT_OK 	( PDLG_PREBUTTON + PDLG_PB_OK )
#define	PDLG_BUT_CNCL	( PDLG_PREBUTTON + PDLG_PB_CANCEL )
#define	PDLG_BUT_DEV	( PDLG_PREBUTTON + PDLG_PB_DEVICE )

typedef long (cdecl *PDLG_INIT)( struct _prn_settings *settings, struct _pdlg_sub *sub);
typedef long (cdecl *PDLG_HNDL)( struct _prn_settings *settings, struct _pdlg_sub *sub, short exit_obj);
typedef long (cdecl *PDLG_RESET)( struct _prn_settings *settings, struct _pdlg_sub *sub);

typedef struct _pdlg_sub				/* Unterdialog fÅr GerÑteeinstellung */
{
	struct _pdlg_sub *next; 			/* Zeiger auf den Nachfolger in der Liste */
	long		length;					/* StrukturlÑnge */
	long		format;					/* Datenformat */
	long		reserved;				/* reserviert */
	
	void		*drivers;				/* nur fÅr interne Dialoge */
	short 		option_flags;			/* Flags, u.a. PDLG_PRINTING, PDLG_PREFS */
	short 		sub_id;					/* Kennung des Unterdialogs, wird fÅr globale Unterdialoge von pdlg_add() eingetragen */
	void		*dialog; 				/* Zeiger auf die Struktur des Fensterdialogs oder 0L */
	OBJECT		*tree;					/* Zeiger auf den zusammengesetzen Objektbaum */
	short 		index_offset;			/* Indexverschiebung des Unterdialogs */
	short 		reserved1;
	long		reserved2;
	long		reserved3;
	long		reserved4;

	PDLG_INIT	init_dlg;				/* Initialisierungsfunktion */
	PDLG_HNDL	do_dlg;					/* Behandlungsfunktion */
	PDLG_RESET	reset_dlg;				/* ZurÅcksetzfunktion */
	long		reserved5;

	OBJECT		*sub_icon;				/* Zeiger auf das Icon fÅr die Listbox */
	OBJECT		*sub_tree;				/* Zeiger auf den Objektbaum des Unterdialogs */
	long		reserved6;
	long		reserved7;

	long		private1;				/* dialogeigene Informationen */
	long		private2;
	long		private3;
	long		private4;

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
#define	MC_ORIENTATION 0x000f

#define	MC_SLCT_CMYK	0x0400		/* Treiber kann bestimmte Farbebenen ausgeben */
#define	MC_CTRST_BRGHT 0x0800		/* Treiber kann Kontrast und Helligkeit verÑndern */

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
	short first_page; 					/* erste zu druckende Seite */
	short last_page;						/* letzte zu druckende Seite */
	short no_copies;						/* Anzahl der Kopien */
	short orientation;					/* Drehung */
	long	scale;							/* Skalierung: 0x10000L entspricht 100% */

	short driver_id;						/* VDI-GerÑtenummer */
	short driver_type;					/* Typ des eingestellten Treibers */
	long	driver_mode;					/* Flags, u.a. fÅr Hintergrunddruck */
	long	reserved1;
	long	reserved2;
	
	long	printer_id; 					/* Druckernummer */
	long	mode_id; 						/* Modusnummer */
	short mode_hdpi;						/* horizontale Auflîsung in dpi */
	short mode_vdpi;						/* vertikale Auflîsung in dpi */
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

#define PDLG_ALWAYS_COPIES 0x0010			/* immer Kopien anbieten */
#define PDLG_ALWAYS_ORIENT 0x0020			/* immer Querformat anbieten */
#define PDLG_ALWAYS_SCALE	0x0040			/* immer Skalierung anbieten */

#define	PDLG_EVENODD		0x0100			/* Option fÅr gerade und ungerade Seiten anbieten */

/* <button> fÅr pdlg_evnt()/pdlg_do */
#define	PDLG_CANCEL 1							/* "Abbruch" wurde angewÑhlt */
#define	PDLG_OK		2							/* "OK" wurde gedrÅckt */

int	pdlg_add_printers 			( PRN_DIALOG *prn_dialog, DRV_INFO *drv_info);
int	pdlg_add_sub_dialogs 		( PRN_DIALOG *prn_dialog, PDLG_SUB *sub_dialogs);
int	pdlg_close					( PRN_DIALOG *prn_dialog, int *x, int *y);
PRN_DIALOG* pdlg_create 		( int dialog_flags);
int	pdlg_delete 				( PRN_DIALOG *prn_dialog);
int	pdlg_dflt_settings			( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings);
int	pdlg_do						( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, char *document_name, int option_flags);
int	pdlg_evnt					( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, EVNT *events, int *button);
int	pdlg_free_settings			( PRN_SETTINGS *settings);
long	pdlg_get_setsize		( void);
PRN_SETTINGS *pdlg_new_settings	( PRN_DIALOG *prn_dialog);
int	pdlg_open					( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings, char *document_name, int option_flags, int x, int y);
int	pdlg_remove_printers 		( PRN_DIALOG *prn_dialog);
int	pdlg_remove_sub_dialogs 	( PRN_DIALOG *prn_dialog);
int	pdlg_save_default_settings 	( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings);
int	pdlg_update 				( PRN_DIALOG *prn_dialog, char *document_name);
int	pdlg_use_settings 			( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings);
int	pdlg_validate_settings		( PRN_DIALOG *prn_dialog, PRN_SETTINGS *settings);

/*******************************************************************************
 * The VDI extensions of NVDI/FSM/Speedo
 */

/*
 * The following functions requires EdDI version 1.x or higher
 */
void	v_clsbm		( int handle);
void	v_opnbm		( int *work_in, MFDB *bitmap, int *handle, int *work_out);
void	vq_scrninfo	( int handle, int *work_out);


/*
 * The following functions requires NVDI version 3.x or higher
 */
typedef struct {
	long	size;
	short	format;
	short	id;
	short	index;
	char	font_name[50];
	char	family_name[50];
	char	style_name[50];
	char	file_name1[200];
	char	file_name2[200];
	char	file_name3[200];
	short	pt_cnt;
	short	pt_sizes[64];
} XFNT_INFO;

void	v_ftext_offset	( int handle, int x, int y, char *str, int *offset);
void	v_getbitmap_info( int handle, int ch, long *advancex, long *advancey, long *xoffset, long *yoffset, int *width, int *height, short **bitmap);

void	vq_devinfo		( int handle, int device, int *dev_open, char *file_name, char *device_name);
int		vq_ext_devinfo	( int handle, int device, int *dev_exists, char *file_path, char *file_name, char *name);

int		vqt_ext_name	( int handle, int index, char *name, int *font_format, int *flags);
void	vqt_f_extent	( int handle, char *str, int extent[]);
void	vqt_fontheader	( int handle, char *buffer, char *pathname);
int		vqt_name_and_id	( int handle, int font_format, char *font_name, char *ret_name);
void	vqt_pairkern	( int handle, int ch1, int ch2, long *x, long *y);
void	vqt_real_extent	( int handle, int x, int y, char *string, int extent[]);
void	vqt_trackkern	( int handle, long *x, long *y);
int		vqt_xfntinfo	( int handle, int flags, int id, int index, XFNT_INFO *info);

void 	vst_kern		( int handle, int tmode, int pmode, int *tracks, int *pairs);
int 	vst_name 		( int handle, int font_format, char *font_name, char *ret_name);
void 	vst_track_offset( int handle, long offset, int pairmode, int *tracks, int *pairs);
void 	vst_width		( int handle, int width, int *char_width, int *char_height, int *cell_width, int *cell_height);

/*
 * The following functions requires NVDI version 4.x or higher
 */
int	vqt_char_index		( int handle, int scr_index, int scr_mode, int dst_mode);


/*
 * The following functions requires NVDI version 5.x or higher
 */

typedef struct {
	unsigned short	reserved;
	unsigned short	red;
	unsigned short	green;
	unsigned short	blue;
} COLOR_RGB;

typedef struct {
	unsigned short	cyan;
	unsigned short	magenta;
	unsigned short	yellow;
	unsigned short	black;
} COLOR_CMYK;

typedef union {
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


typedef void			INVERSE_CTAB;
typedef INVERSE_CTAB	*ITAB_REF;

typedef struct	_gcbitmap {
	long			magic;
	long			length;
	long			format;
	long			reserved;

	unsigned char	*addr;
	long			width;
	long			bits;
	unsigned long	px_format;

	long			xmin;
	long			ymin;
	long			xmax;
	long			ymax;

	CTAB_REF		*ctab;
	ITAB_REF 		*itab;
	long			reserved0;
	long			reserved1;
} GCBITMAP;


long		v_color2nearest	( int handle, long color_space, COLOR_ENTRY *color, COLOR_ENTRY *nearest_color);
unsigned long 
			v_color2value	( int handle, long color_space, COLOR_ENTRY *color);
COLOR_TAB *	v_create_ctab	( int handle, long color_space, unsigned long px_format);
ITAB_REF 	v_create_itab	( int handle, COLOR_TAB *ctab, int bits );
unsigned long	
			v_ctab_idx2value( int handle, int index );
int			v_ctab_idx2vdi	( int handle, int index);
int			v_ctab_vdi2idx	( int handle, int vdi_index);
int			v_delete_ctab	( int handle, COLOR_TAB *ctab);
int			v_delete_itab	( int handle, ITAB_REF itab);
long		v_get_ctab_id	( int handle);
int			v_get_outline	( int handle, int index, int x_offset, int y_offset, short *pts, char *flags, int max_pts);
int			v_opnprn		( int aes_handle, PRN_SETTINGS *settings, int work_out[]);
int			v_resize_bm		( int handle, int width, int height, long b_width, unsigned char *addr);
void		v_setrgb		( int handle, int type, int r, int g, int b);
long		v_value2color	( int handle, unsigned long value, COLOR_ENTRY *color);
int			vq_ctab			( int handle, long ctab_length, COLOR_TAB *ctab);
long		vq_ctab_entry	( int handle, int index, COLOR_ENTRY *color);
long		vq_ctab_id		( int handle);
int			vq_dflt_ctab	( int handle, long ctab_length, COLOR_TAB *ctab);
long		vq_hilite_color	( int handle, COLOR_ENTRY *hilite_color);
int			vq_margins		( int handle, int *top_margin, int *bottom_margin, int *left_margin, int *right_margin, int *hdpi, int *vdpi);
long		vq_max_color	( int handle, COLOR_ENTRY *hilite_color);
long		vq_min_color	( int handle, COLOR_ENTRY *hilite_color);
long		vq_prn_scaling	( int handle);
long		vq_px_format	( int handle, unsigned long *px_format);
long		vq_weight_color	( int handle, COLOR_ENTRY *hilite_color);
long		vqf_bg_color	( int handle, COLOR_ENTRY *fg_color);
long		vqf_fg_color	( int handle, COLOR_ENTRY *fg_color);
long		vql_bg_color	( int handle, COLOR_ENTRY *fg_color);
long		vql_fg_color	( int handle, COLOR_ENTRY *fg_color);
long		vqm_bg_color	( int handle, COLOR_ENTRY *fg_color);
long		vqm_fg_color	( int handle, COLOR_ENTRY *fg_color);
long		vqr_bg_color	( int handle, COLOR_ENTRY *fg_color);
long		vqr_fg_color	( int handle, COLOR_ENTRY *fg_color);
long		vqt_bg_color	( int handle, COLOR_ENTRY *fg_color);
long		vqt_fg_color	( int handle, COLOR_ENTRY *fg_color);
void		vr_transfer_bits( int handle, GCBITMAP *src_bm, GCBITMAP *dst_bm, int *src_rect, int *dst_rect, int mode);
int			vs_ctab			( int handle, COLOR_TAB *ctab);
int			vs_ctab_entry	( int handle, int index, long color_space, COLOR_ENTRY *color);
int			vs_dflt_ctab	( int handle);
int			vs_document_info( int vdi_handle, int type, char *s, int wchar);
int			vs_hilite_color	( int handle, long color_space, COLOR_ENTRY *hilite_color);
int			vs_max_color	( int handle, long color_space, COLOR_ENTRY *min_color);
int			vs_min_color	( int handle, long color_space, COLOR_ENTRY *min_color);
int			vs_weight_color	( int handle, long color_space, COLOR_ENTRY *weight_color);
int			vsf_bg_color	( int handle, long color_space, COLOR_ENTRY *bg_color);
int			vsf_fg_color	( int handle, long color_space, COLOR_ENTRY *fg_color);
int			vsl_bg_color	( int handle, long color_space, COLOR_ENTRY *bg_color);
int			vsl_fg_color	( int handle, long color_space, COLOR_ENTRY *fg_color);
int			vsm_bg_color	( int handle, long color_space, COLOR_ENTRY *bg_color);
int			vsm_fg_color	( int handle, long color_space, COLOR_ENTRY *fg_color);
int			vsr_bg_color	( int handle, long color_space, COLOR_ENTRY *bg_color);
int			vsr_fg_color	( int handle, long color_space, COLOR_ENTRY *fg_color);
int			vst_bg_color	( int handle, long color_space, COLOR_ENTRY *bg_color);
int			vst_fg_color	( int handle, long color_space, COLOR_ENTRY *fg_color);

/* For New binding */

typedef struct {
	short *contrl;
	short *global;
	short *intin;
	short *intout;
	long  *addrin;
	long  *addrout;
} _AESPB;

extern _AESPB aespb;
void aes( _AESPB *);

extern VDIPB vdipb;
void vdi( VDIPB *);

#endif
