/*----------------------------------------------------------------------------------------
	prsettng.h, part of TOS Linker for CodeWarrior

	printer settings structure
	
	21.10.1998 by Manfred Lippert
	based on prsettng.h from Sven & Wilfried Behne

	last change: 17.11.1998

	Don't edit this file.

	If you have to make any changes on this file, please contact:
	mani@mani.de
----------------------------------------------------------------------------------------*/

#ifndef	__PRN_SETTINGS__
#define	__PRN_SETTINGS__

/*--------------------------------------------------------------------------------------*/ 
/* einstellbare Farbmodi eines Druckermodus												*/
/*--------------------------------------------------------------------------------------*/ 
#define	CC_MONO			0x0001			/* 2 Grautöne */
#define	CC_4_GREY		0x0002			/* 4 Grautöne */
#define	CC_8_GREY		0x0004			/* 8 Grautöne */
#define	CC_16_GREY		0x0008			/* 16 Grautöne */
#define	CC_256_GREY		0x0010			/* 256 Grautöne */
#define	CC_32K_GREY		0x0020			/* 32768 Farben in Grautöne wandeln */
#define	CC_65K_GREY		0x0040			/* 65536 Farben in Grautöne wandeln */
#define	CC_16M_GREY		0x0080			/* 16777216 Farben in Grautöne wandeln */

#define	CC_2_COLOR		0x0100			/* 2 Farben */
#define	CC_4_COLOR		0x0200			/* 4 Farben */
#define	CC_8_COLOR		0x0400			/* 8 Farben */
#define	CC_16_COLOR		0x0800			/* 16 Farben */
#define	CC_256_COLOR	0x1000			/* 256 Farben */
#define	CC_32K_COLOR	0x2000			/* 32768 Farben */
#define	CC_65K_COLOR	0x4000			/* 65536 Farben */
#define	CC_16M_COLOR	0x8000			/* 16777216 Farben */

#define	NO_CC_BITS		16

/*--------------------------------------------------------------------------------------*/ 
/* einstellbare Rasterverfahren															*/
/*--------------------------------------------------------------------------------------*/ 
#define	DC_NONE			0				/* keine Rasterverfahren */
#define	DC_FLOYD		1				/* einfacher Floyd-Steinberg */

#define	NO_DC_BITS		1

/*--------------------------------------------------------------------------------------*/ 
/* Druckereigenschaften																	*/
/*--------------------------------------------------------------------------------------*/ 
#define	PC_FILE			0x0001			/* Drucker kann über GEMDOS-Dateien angesprochen werden */
#define	PC_SERIAL		0x0002			/* Drucker kann auf der seriellen Schnittstelle angesteuert werden */
#define	PC_PARALLEL		0x0004			/* Drucker kann auf der parallelen Schnittstelle angesteuert werden */
#define	PC_ACSI			0x0008			/* Drucker kann auf der ACSI-Schnittstelle ausgeben */
#define	PC_SCSI			0x0010			/* Drucker kann auf der SCSI-Schnittstelle ausgeben */

#define	PC_BACKGROUND	0x0080			/* Treiber kann im Hintergrund ausdrucken */

#define	PC_SCALING		0x0100			/* Treiber kann Seite skalieren */
#define	PC_COPIES		0x0200			/* Treiber kann Kopien einer Seite erstellen */

/*--------------------------------------------------------------------------------------*/ 
/* Moduseigenschaften																	*/
/*--------------------------------------------------------------------------------------*/ 
#define	MC_PORTRAIT		0x0001			/* Seite kann im Hochformat ausgegeben werden */
#define	MC_LANDSCAPE	0x0002			/* Seite kann im Querformat ausgegeben werden */
#define	MC_REV_PTRT		0x0004			/* Seite kann um 180 Grad gedreht im Hochformat ausgegeben werden */
#define	MC_REV_LNDSCP	0x0008			/* Seite kann um 180 Grad gedreht im Querformat ausgegeben werden */
#define	MC_ORIENTATION	0x000f

#define	MC_SLCT_CMYK	0x0400			/* Treiber kann bestimmte Farbebenen ausgeben */
#define	MC_CTRST_BRGHT	0x0800			/* Treiber kann Kontrast und Helligkeit verändern */

/*--------------------------------------------------------------------------------------*/ 
/* plane_flags																			*/
/*--------------------------------------------------------------------------------------*/ 
#define	PLANE_BLACK		0x0001
#define	PLANE_YELLOW	0x0002
#define	PLANE_MAGENTA	0x0004
#define	PLANE_CYAN		0x0008


/* <driver_mode> */
#define	DM_BG_PRINTING	0x0001			/* Flag für Hintergrunddruck */

/*--------------------------------------------------------------------------------------*/ 
/*--------------------------------------------------------------------------------------*/ 

/* <page_flags> */
#define	PG_EVEN_PAGES	0x0001			/* nur Seiten mit gerader Seitennummer ausgeben */
#define	PG_ODD_PAGES	0x0002			/* nur Seiten mit ungerader Seitennummer ausgeben */

/* <first_page/last_page> */
#define	PG_MIN_PAGE		1
#define	PG_MAX_PAGE		9999

/* <orientation> */
#define	PG_UNKNOWN		0x0000			/* Ausrichtung unbekannt und nicht verstellbar */
#define	PG_PORTRAIT		0x0001			/* Seite im Hochformat ausgeben */
#define	PG_LANDSCAPE	0x0002			/* Seite im Querformat ausgeben */

typedef struct _prn_settings
{
	int32	magic;						/* 'pset' */
	int32	length;						/* Strukturlänge */
	int32	format;						/* Strukturtyp */
	int32	reserved;

	int32	page_flags;					/* Flags, u.a. gerade Seiten, ungerade Seiten */
	int16	first_page;					/* erste zu druckende Seite */
	int16	last_page;					/* letzte zu druckende Seite */
	int16	no_copies;					/* Anzahl der Kopien */
	int16	orientation;				/* Drehung */
	fixed32	scale;						/* Skalierung: 0x10000L entspricht 100% */

	int16 driver_id;					/* VDI-Gerätenummer */
	int16	driver_type;				/* Typ des eingestellten Treibers */
	int32	driver_mode;				/* Flags, u.a. für Hintergrunddruck */
	int32	reserved1;
	int32	reserved2;
	
	int32	printer_id;					/* Druckernummer */
	int32	mode_id;					/* Modusnummer */
	int16	mode_hdpi;					/* horizontale Auflösung in dpi */
	int16	mode_vdpi;					/* vertikale Auflösung in dpi */
	int32	quality_id;					/* Druckmodus (hardwäremäßige Qualität, z.B. Microweave oder Econofast) */

	int32	color_mode;					/* Farbmodus */
	int32	plane_flags;				/* Flags für auszugebende Farbebenen (z.B. nur cyan) */
	int32	dither_mode;				/* Rasterverfahren */
	int32	dither_value;				/* Parameter für das Rasterverfahren */

	int32	size_id;					/* Papierformat */
	int32	type_id;					/* Papiertyp (normal, glossy) */
	int32	input_id;					/* Papiereinzug */
	int32	output_id;					/* Papierauswurf */

	fixed32	contrast;					/* Kontrast: 0x10000L entspricht Normaleinstellung */
	fixed32	brightness;					/* Helligkeit: 0x1000L entspricht Normaleinstellung */
	int32	reserved3;
	int32	reserved4;

	int32	reserved5;
	int32	reserved6;
	int32	reserved7;
	int32	reserved8;

	int8	device[128];				/* Dateiname für den Ausdruck */

#ifdef __PRINTING__
	TPrint	mac_settings;				/* Einstellung des Mac-Druckertreibers */
#else
	struct
	{
		uint8	inside[120];
	} mac_settings;
#endif

} PRN_SETTINGS;

#endif
