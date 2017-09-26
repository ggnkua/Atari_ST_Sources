/*----------------------------------------------------------------------------------------
	prdialog.h, part of TOS Linker for CodeWarrior

	printer dialog structures
	
	10.11.1998 by Manfred Lippert
	based on prdialog.h from Sven & Wilfried Behne

	last change: 17.11.1998

	Don't edit this file.

	If you have to make any changes on this file, please contact:
	mani@mani.de
----------------------------------------------------------------------------------------*/

#ifndef	__PRN_DIALOGS__
#define	__PRN_DIALOGS__

typedef struct _prn_tray						/* Beschreibung eines Einzugs/Auswurfs */
{
	struct _prn_tray	*next;
	
	int32	tray_id;							/* Nummer des Einzugs oder Auswurfs */
	int8	name[32];							/* Name des Schachts */
} PRN_TRAY;

typedef struct _media_size						/* Beschreibung eines Papierformats */
{
	struct _media_size	*next;

	int32	size_id;							/* Kennung des Papierformats */
	int8	name[32];							/* Name des Papierformats */
} MEDIA_SIZE;

typedef struct _media_type						/* Beschreibung eines Papiertyps/Druckmediums */
{
	struct _media_type	*next;

	int32	type_id;							/* Kennung des Papierformats */
	int8	name[32];							/* Name des Papierformats */
} MEDIA_TYPE;

typedef struct _prn_mode						/* Beschreibung eines Druckermodus */
{
	struct _prn_mode *next;						/* Zeiger auf den nächsten Druckermodus */

	int32		mode_id;						/* Moduskennung (Index innerhalb der Datei) */
	int16		hdpi;							/* horizontale Auflösung in dpi */
	int16		vdpi;							/* vertikale Auflîsung in dpi */
	int32		mode_capabilities;				/* Moduseigenschaften */

	int32		color_capabilities;				/* einstellbare Farbmodi */
	int32		dither_flags;					/* Flags, die angeben, ob der korrespondierende Farbmodus mit oder ohne Dithern ansprechbar ist */
	MEDIA_TYPE	*paper_types;					/* geeignete Papiertypen */
	int32		reserved;

	int8		name[32];						/* Modusname */
} PRN_MODE;

/* old_printer kann auch 0L sein */
typedef int32 CDECL (*PRN_SWITCH)( struct _drv_entry *drivers, struct _prn_settings *settings, struct _prn_entry *old_printer, struct _prn_entry *new_printer );

/* sub_flags */
#define	PRN_STD_SUBS	0x0001					/* Standard-Unterdialoge für NVDI-Drucker */
#define	PRN_FSM_SUBS	0x0002					/* Standard-Unterdialoge für FSM-Drucker */
#define	PRN_QD_SUBS		0x0004					/* Standard-Unterdialoge für QuickDraw-Drucker */

typedef struct _prn_entry						/* Gerätebeschreibung */
{
	struct _prn_entry	*next;					/* Zeiger auf die die nächste Gerätebeschreibung */
	int32		length;							/* Strukturlänge */
	int32		format;							/* Datenformat */
	int32		reserved;						/* reserviert */
	
	int16		driver_id;						/* Treiberkennung */
	int16		driver_type;					/* Treibertyp */
	int32		printer_id;						/* Druckerkennung */
	int32		printer_capabilities;			/* Druckereigenschaften */
	int32		reserved1;

	int32		sub_flags;						/* Flags für die Unterdialoge */
	struct _pdlg_sub	*sub_dialogs;			/* Zeiger auf die Liste der Unterdialoge für diesen Drucker */
	PRN_SWITCH	setup_panel;					/* Unterdialog bei Druckerwechsel initialisieren */
	PRN_SWITCH	close_panel;					/* Unterdialog bei Druckerwechsel schließen */

	PRN_MODE	*modes;							/* Liste der vorhandenen Auflösungen */
	MEDIA_SIZE	*papers;						/* Liste der vorhandenen Papierformate */
	PRN_TRAY	*input_trays;					/* Liste der Einzüge */
	PRN_TRAY	*output_trays;					/* Liste der Auswürfe */

	int8		name[32];						/* Name des Druckers */
} PRN_ENTRY;

typedef struct	_dither_mode
{
	struct _dither_mode	*next;
	int32	length;								/* Strukturlänge */
	int32	format;								/* Datenformat */
	int32	reserved;							/* reserviert */

	int32	dither_id;							/* Kennung */
	int32	color_modes;						/* unterstützte Farbtiefen */
	int32	reserved1;
	int32	reserved2;

	int8	name[32];							/* Name des Rasterverfahrens */
} DITHER_MODE;


typedef struct
{
	int32		magic;							/* 'pdnf' */
	int32		length;							/* Strukturlänge */
	int32		format;							/* Datenformat */
	int32		reserved;						/* reserviert */

	int16		driver_id;						/* Treibernummer fürs VDI */
	int16		driver_type;					/* Treibertyp */
	int32		reserved1;
	int32		reserved2;
	int32		reserved3;

	PRN_ENTRY	*printers;						/* Liste der zum Treiber gehörenden Drucker */
	DITHER_MODE	*dither_modes;					/* Liste der vom Treiber unterstützten Rasterverfahren */
	int32		reserved4;
	int32		reserved5;

	int32		reserved6;
	int32		reserved7;
	int32		reserved8;
	int32		reserved9;
	
	int8		device[128];					/* Ausgabedatei des Druckertreibers */
	
} DRV_INFO;

typedef struct _drv_entry
{
	struct _drv_entry	*next;
} DRV_ENTRY;

#define	PDLG_CHG_SUB	0x80000000L
#define	PDLG_IS_BUTTON	0x40000000L

#define	PDLG_PREBUTTON	0x20000000L
#define	PDLG_PB_OK		1
#define	PDLG_PB_CANCEL	2
#define	PDLG_PB_DEVICE	3

#define	PDLG_BUT_OK		( PDLG_PREBUTTON + PDLG_PB_OK )
#define	PDLG_BUT_CNCL	( PDLG_PREBUTTON + PDLG_PB_CANCEL )
#define	PDLG_BUT_DEV	( PDLG_PREBUTTON + PDLG_PB_DEVICE )

typedef	int32 CDECL (*PDLG_INIT)( struct _prn_settings *settings, struct _pdlg_sub *sub );
typedef	int32 CDECL (*PDLG_HNDL)( struct _prn_settings *settings, struct _pdlg_sub *sub, int16 exit_obj );
typedef	int32 CDECL (*PDLG_RESET)( struct _prn_settings *settings, struct _pdlg_sub *sub );

typedef struct _pdlg_sub						/* Unterdialog für Geräteeinstellung */
{
	struct _pdlg_sub *next;						/* Zeiger auf den Nachfolger in der Liste */
	int32		length;							/* Strukturlänge */
	int32		format;							/* Datenformat */
	int32		reserved;						/* reserviert */
	
	void		*drivers;						/* nur für interne Dialoge */
	int16		option_flags;					/* Flags, u.a. PDLG_PRINTING, PDLG_PREFS */
	int16		sub_id;							/* Kennung des Unterdialogs, wird für globale Unterdialoge von pdlg_add() eingetragen */
	DIALOG		*dialog;						/* Zeiger auf die Struktur des Fensterdialogs oder 0L */
	OBJECT		*tree;							/* Zeiger auf den zusammengesetzen Objektbaum */
	int16		index_offset;					/* Indexverschiebung des Unterdialogs */
	int16		reserved1;
	int32		reserved2;
	int32		reserved3;
	int32		reserved4;

	PDLG_INIT	init_dlg;						/* Initialisierungsfunktion */
	PDLG_HNDL	do_dlg;							/* Behandlungsfunktion */
	PDLG_RESET	reset_dlg;						/* Zurücksetzfunktion */
	int32		reserved5;

	OBJECT		*sub_icon;						/* Zeiger auf das Icon für die Listbox */
	OBJECT		*sub_tree;						/* Zeiger auf den Objektbaum des Unterdialogs */
	int32		reserved6;
	int32		reserved7;

	int32		private1;						/* dialogeigene Informationen */
	int32		private2;
	int32		private3;
	int32		private4;

} PDLG_SUB;

#endif
