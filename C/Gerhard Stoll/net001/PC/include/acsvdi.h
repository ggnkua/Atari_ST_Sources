/******************************************************************************/
/*																										*/
/*          Eine handoptimierte Bibliothek fÅr Pure-C und GNU-C               */
/*																										*/
/* Die (N)VDI-Funktionen - Headerdatei														*/
/*																										*/
/*	(c) 1998-2008 by Martin ElsÑsser @ LL, Gerhard Stoll @ B							*/
/*																										*/
/* 																Tabsize: 1 Tag = 3 Spaces	*/
/******************************************************************************/

#ifndef __ACSVDI__
#define __ACSVDI__

/******************************************************************************/

#ifdef __cplusplusextern "C" {#endif
/******************************************************************************/

#ifndef __ACSTYPE__
	#include <ACSTYPE.H>
#endif

#include <StdLib.H>

/******************************************************************************/
/*																										*/
/* Die diversen VDI-Konstanten																*/
/*																										*/
/******************************************************************************/

/* Die Namen der Farben */
#define WHITE            0
#define BLACK            1
#define RED              2
#define GREEN            3
#define BLUE             4
#define CYAN             5
#define YELLOW           6
#define MAGENTA          7
#define LWHITE           8
#define LBLACK           9
#define LRED            10
#define LGREEN          11
#define LBLUE           12
#define LCYAN           13
#define LYELLOW         14
#define LMAGENTA        15

#define __COLORS

/******************************************************************************/

/* Status des Atari-SLM-Laserdruckers fÅr v_updwk */
#define NO_ERROR				0
#define PRINTER_NOT_READY	2
#define TONER_EMPTY			3
#define PAPER_EMPTY			5

/* Konstanten aus GEMLIB */
#define SLM_OK					NO_ERROR#define SLM_ERROR				PRINTER_NOT_READY#define SLM_NOTONER			TONER_EMPTY#define SLM_NOPAPER			PAPER_EMPTY
/******************************************************************************/

/* Fehlercodes fÅr vst_error */
/* Bereits definiert!
#define NO_ERROR				0 */

#define CHAR_NOT_FOUND		1#define FILE_READERR 		8#define FILE_OPENERR 		9#define BAD_FORMAT		10#define CACHE_FULL		11#define MISC_ERROR		(-1)
/******************************************************************************/

/* Die Schreibmodi (fÅr vswr_mode) */
#define MD_REPLACE	1
#define MD_TRANS		2
#define MD_XOR			3
#define MD_ERASE		4

/******************************************************************************/

/* Die Linientypen (fÅr vsl_type) */
#define LT_SOLID			1
#define LT_LONGDASH		2
#define LT_DOTTED			3
#define LT_DASHDOT		4
#define LT_DASHED			5
#define LT_DASHDOTDOT	6
#define LT_USERDEF		7

/* Konstanten aus PureC-Binding */
#define SOLID				LT_SOLID
#define LONGDASH			LT_LONGDASH
#define DOT					LT_DOTTED
#define DASHDOT			LT_DASHDOT
#define DASH				LT_DASHED
#define DASH2DOT			LT_DASHDOTDOT
#define USERLINE			LT_USERDEF

/* Konstanten aus GEMLIB */
#define LDASHED			LT_LONGDASH#define DOTTED				LT_DOTTED#define DASHDOT			LT_DASHDOT#define DASH				LT_DASHED#define DASHDOTDOT		LT_DASHDOTDOT
/******************************************************************************/

/* Die Linienenden (fÅr vsl_ends) */
#define LE_SQUARED	0
#define LE_ARROWED	1
#define LE_ROUNDED	2

#define SQUARE			LE_SQUARED
#define ARROWED		LE_ARROWED
#define ROUND			LE_ROUNDED

/******************************************************************************/

/* Die Markertypen (fÅr vsm_type) */
#define MT_DOT				1
#define MT_PLUS			2
#define MT_ASTERISK		3
#define MT_SQUARE			4
#define MT_DCROSS			5
#define MT_DIAMOND		6

/* Konstanten aus GEMLIB */
#define MRKR_DOT			MT_DOT#define MRKR_PLUS 		MT_PLUS#define MRKR_ASTERISK	MT_ASTERISK#define MRKR_BOX			MT_SQUARE#define MRKR_CROSS		MT_DCROSS#define MRKR_DIAMOND		MT_DIAMOND
/******************************************************************************/

/* Texteffekte (fÅr vst_effects) */
#define TF_NORMAL			0x00
#define TF_THICKENED		0x01
#define TF_LIGHTENED		0x02
#define TF_SLANTED		0x04
#define TF_UNDERLINED	0x08
#define TF_OUTLINED		0x10
#define TF_SHADOWED		0x20

/* Konstanten aus GEMLIB */
#define TXT_NORMAL		TF_NORMAL
#define TXT_THICKENED	TF_THICKENED#define TXT_LIGHT			TF_LIGHTENED#define TXT_SKEWED		TF_SLANTED#define TXT_UNDERLINED	TF_UNDERLINED#define TXT_OUTLINED		TF_OUTLINED#define TXT_SHADOWED		TF_SHADOWED
/******************************************************************************/

/* Text-Ausrichtung (fÅr vst_alignment) */
#define TA_LEFT		0
#define TA_CENTER		1
#define TA_RIGHT		2

#define TA_BASELINE	0
#define TA_HALF		1
#define TA_ASCENT		2
#define TA_BOTTOM		3
#define TA_DESCENT	4
#define TA_TOP			5

/******************************************************************************/

/* Mode fÅr vst_charmap */#define MAP_BITSTREAM	0#define MAP_ATARI			1#define MAP_UNICODE		2		/* for vst_map_mode, NVDI 4 */
/******************************************************************************/
/* Modes fÅr 'track_mode' von vst_kern */#define TRACK_NONE			0#define TRACK_NORMAL 		1#define TRACK_TIGHT			2#define TRACK_VERYTIGHT		3
/******************************************************************************/

/* Modes fÅr 'pair_mode' von vst_kern */#define PAIR_OFF				0#define PAIR_ON				1
/******************************************************************************/

/* Modes fÅr vst_scratch */#define SCRATCH_BOTH			0#define SCRATCH_BITMAP		1#define SCRATCH_NONE			2/******************************************************************************/

/* FÅlltypen (fÅr vsf_interior) */
#define FIS_HOLLOW	0
#define FIS_SOLID		1
#define FIS_PATTERN	2
#define FIS_HATCH		3
#define FIS_USER		4

/******************************************************************************/

/* vsf_perimeter Modes */#define PERIMETER_OFF	0#define PERIMETER_ON		1/******************************************************************************/

#define IP_HOLLOW       0
#define IP_1PATT        1
#define IP_2PATT        2
#define IP_3PATT        3
#define IP_4PATT        4
#define IP_5PATT        5
#define IP_6PATT        6
#define IP_SOLID        7

/******************************************************************************/

/* Mode fÅr v_bez */
#define BEZ_BEZIER		0x01#define BEZ_POLYLINE		0x00#define BEZ_NODRAW		0x02

/******************************************************************************/

/* Modus fÅr v_bit_image */#define IMAGE_LEFT		0#define IMAGE_CENTER		1#define IMAGE_RIGHT		2#define IMAGE_TOP 		0#define IMAGE_BOTTOM		2
/******************************************************************************/
/* Modus fÅr v_justified */#define NOJUSTIFY			0#define JUSTIFY			1
/******************************************************************************/
/* vq_color modes */#define COLOR_REQUESTED		0#define COLOR_ACTUAL			1
/******************************************************************************/
/* Mode fÅr vqin_mode & vsin_mode analog GEMLIB */#define VINMODE_LOCATOR			1#define VINMODE_VALUATOR		2#define VINMODE_CHOICE			3#define VINMODE_STRING			4
/* DIe "alten" Namen der Konstanten */
#define LOCATOR		VINMODE_LOCATOR#define VALUATOR		VINMODE_VALUATOR#define CHOICE			VINMODE_CHOICE#define STRING			VINMODE_STRING
/******************************************************************************/
/* Modus fÅr vqt_cachesize */#define CACHE_CHAR		0#define CACHE_MISC		1
/******************************************************************************/
/* Returnwert von vqt_devinfo */#define DEV_MISSING			0#define DEV_INSTALLED		1
/******************************************************************************/
/* Returnwert von vqt_name */#define BITMAP_FONT		0
/******************************************************************************/
/* Mode fÅr vst_error */#define APP_ERROR			0#define SCREEN_ERROR		1/******************************************************************************/

/* Die VerknÅpfungen der Raster-Operationen */
#define ALL_WHITE        0
#define S_AND_D          1
#define S_AND_NOTD       2
#define S_ONLY           3
#define NOTS_AND_D       4
#define D_ONLY           5
#define S_XOR_D          6
#define S_OR_D           7
#define NOT_SORD         8
#define NOT_SXORD        9
#define D_INVERT        10
#define NOT_D           10
#define S_OR_NOTD       11
#define NOT_S				12#define NOTS_OR_D       13
#define NOT_SANDD       14
#define ALL_BLACK       15

/******************************************************************************/

#define T_LOGIC_MODE			  0
#define T_COLORIZE			 16		/* Quelle einfÑrben           */
#define T_DRAW_MODE			 32
#define T_ARITH_MODE			 64		/* Arithmetische Transfermodi */
#define T_DITHER_MODE		128		/* Quelldaten dithern         */

/* Logische Transfermodi fÅr NVDI-5-Raster-Funktionen */
#define T_LOGIC_COPY				(T_LOGIC_MODE+0)	/* dst = src;                        */
#define T_LOGIC_OR				(T_LOGIC_MODE+1)	/* dst = src OR dst;                 */
#define T_LOGIC_XOR				(T_LOGIC_MODE+2)	/* dst = src XOR dst;                */
#define T_LOGIC_AND				(T_LOGIC_MODE+3)	/* dst = src AND dst;                */
#define T_LOGIC_NOT_COPY		(T_LOGIC_MODE+4)	/* dst = ( NOT src );                */
#define T_LOGIC_NOT_OR			(T_LOGIC_MODE+5)	/* dst = ( NOT src ) OR dst;         */
#define T_LOGIC_NOT_XOR			(T_LOGIC_MODE+6)	/* dst = ( NOT src ) XOR dst;        */
#define T_LOGIC_NOT_AND			(T_LOGIC_MODE+7)	/* dst = ( NOT src ) AND dst;        */

#define T_NOT						T_LOGIC_NOT_COPY

/* Zeichenmodi fÅr NVDI-5-Raster-Funktionen */
#define T_REPLACE					(T_DRAW_MODE+0)	/* dst = src;                        */
#define T_TRANSPARENT			(T_DRAW_MODE+1)	/* if ( src != bg_col ) dst = src;   */
#define T_HILITE					(T_DRAW_MODE+2)	/* if ( src != bg_col )              */
																/* {                                 */
																/*    if ( dst == bg_col )           */
																/*       dst = hilite_col;           */
																/*    else if ( dst == hilite_col )  */
																/*       dst = bg_col;               */
																/* }                                 */
#define T_REVERS_TRANSPARENT	(T_DRAW_MODE+3)	/* if ( src == bg_col ) dst = src;   */

/* Arithmetische Transfermodi fÅr NVDI-5-Raster-Funktionen */
#define T_BLEND					(T_ARITH_MODE+0)	/* Quell- und Zielfarbe mischen       */
																/* rgb = RGB( src ) * Gewichtung );   */
																/* rgb += RGB( dst ) * (1-Gewichtung));*/
																/* dst = PIXELWERT( rgb );            */

#define T_ADD						(T_ARITH_MODE+1)	/* Quell- und Zielfarbe addieren      */
																/* rgb = RGB( src ) + RGB( dst )      */
																/* if ( rgb > max_rgb )               */
																/*    rgb = max_rgb;                  */
																/* dst = PIXELWERT( rgb );            */

#define T_ADD_OVER				(T_ARITH_MODE+2)	/* Quell- und Zielfarbe addieren,     */
																/* öberlauf nicht abfangen            */
																/* rgb = RGB( src ) + RGB( dst )      */
																/* dst = PIXELWERT( rgb );            */

#define T_SUB						(T_ARITH_MODE+3)	/* Quell- von Zielfarbe subtrahieren  */
																/* rgb = RGB( dst ) - RGB( src )      */
																/* if ( rgb < min_rgb )               */
																/*    rgb = min_rgb;                  */
																/* dst = PIXELWERT( rgb );            */

#define T_MAX						(T_ARITH_MODE+5)	/* maximale RGB-Komponenten           */
																/* rgb = MAX(RGB( dst ), RGB( src ))  */
																/* dst = PIXELWERT( rgb );            */

#define T_SUB_OVER				(T_ARITH_MODE+6)	/* Quell- von Zielfarbe subtrahieren, */
																/* öberlauf nicht abfangen            */
																/* rgb = RGB( dst ) - RGB( src )      */
																/* dst = PIXELWERT( rgb );            */

#define T_MIN						(T_ARITH_MODE+7)	/* minimale RGB-Komponenten           */
																/* rgb = MIN(RGB( dst ), RGB( src ))  */
																/* dst = PIXELWERT( rgb );            */

/******************************************************************************/

/* Konstanten fÅr Pixelformate */
#define  PX_1COMP    0x01000000L /* Pixel besteht aus einer benutzten Komponente: Farbindex */
#define  PX_3COMP    0x03000000L /* Pixel besteht aus drei benutzten Komponenten, z.B. RGB */
#define  PX_4COMP    0x04000000L /* Pixel besteht aus vier benutzten Komponenten, z.B. CMYK */

#define  PX_REVERSED 0x00800000L /* Pixel wird in umgekehrter Bytereihenfolge ausgegeben */
#define  PX_xFIRST   0x00400000L /* unbenutzte Bits liegen vor den benutzen (im Motorola-Format betrachtet) */
#define  PX_kFIRST   0x00200000L /* K liegt vor CMY (im Motorola-Format betrachtet) */
#define  PX_aFIRST   0x00100000L /* Alphakanal liegen vor den Farbbits (im Motorola-Format betrachtet) */

#define  PX_PACKED   0x00020000L /* Bits sind aufeinanderfolgend abgelegt */
#define  PX_PLANES   0x00010000L /* Bits sind auf mehrere Ebenen verteilt (Reihenfolge: 0, 1, ..., n) */
#define  PX_IPLANES  0x00000000L /* Bits sind auf mehrere Worte verteilt (Reihenfolge: 0, 1, ..., n) */

#define  PX_USES1    0x00000100L /* 1 Bit des Pixels wird benutzt */
#define  PX_USES2    0x00000200L /* 2 Bit des Pixels werden benutzt */
#define  PX_USES3    0x00000300L /* 3 Bit des Pixels werden benutzt */
#define  PX_USES4    0x00000400L /* 4 Bit des Pixels werden benutzt */
#define  PX_USES8    0x00000800L /* 8 Bit des Pixels werden benutzt */
#define  PX_USES15   0x00000f00L /* 15 Bit des Pixels werden benutzt */
#define  PX_USES16   0x00001000L /* 16 Bit des Pixels werden benutzt */
#define  PX_USES24   0x00001800L /* 24 Bit des Pixels werden benutzt */
#define  PX_USES32   0x00002000L /* 32 Bit des Pixels werden benutzt */
#define  PX_USES48   0x00003000L /* 48 Bit des Pixels werden benutzt */

#define  PX_1BIT     0x00000001L /* Pixel besteht aus 1 Bit */
#define  PX_2BIT     0x00000002L /* Pixel besteht aus 2 Bit */
#define  PX_3BIT     0x00000003L /* Pixel besteht aus 3 Bit */
#define  PX_4BIT     0x00000004L /* Pixel besteht aus 4 Bit */
#define  PX_8BIT     0x00000008L /* Pixel besteht aus 8 Bit */
#define  PX_16BIT    0x00000010L /* Pixel besteht aus 16 Bit */
#define  PX_24BIT    0x00000018L /* Pixel besteht aus 24 Bit */
#define  PX_32BIT    0x00000020L /* Pixel besteht aus 32 Bit */
#define  PX_48BIT    0x00000030L /* Pixel besteht aus 48 Bit */

#define  PX_CMPNTS   0x0f000000L /* Maske f&uuml;r Anzahl der Pixelkomponenten */
#define  PX_FLAGS    0x00f00000L /* Maske f&uuml;r diverse Flags */
#define  PX_PACKING  0x00030000L /* Maske f&uuml;r Pixelformat */
#define  PX_USED     0x00003f00L /* Maske f&uuml;r Anzahl der benutzten Bits */
#define  PX_BITS     0x0000003fL /* Maske f&uuml;r Anzahl der Bits pro Pixel */

/* Pixelformate fÅr ATARI-Grafik */
#define  PX_ATARI1   ( PX_PACKED + PX_1COMP + PX_USES1 + PX_1BIT )
#define  PX_ATARI2   ( PX_IPLANES + PX_1COMP + PX_USES2 + PX_2BIT )
#define  PX_ATARI4   ( PX_IPLANES + PX_1COMP + PX_USES4 + PX_4BIT )
#define  PX_ATARI8   ( PX_IPLANES + PX_1COMP + PX_USES8 + PX_8BIT )
#define  PX_FALCON15 ( PX_PACKED + PX_3COMP + PX_USES16 + PX_16BIT )

/* Pixelformate fÅr Mac */
#define  PX_MAC1     ( PX_PACKED + PX_1COMP + PX_USES1 + PX_1BIT )
#define  PX_MAC4     ( PX_PACKED + PX_1COMP + PX_USES4 + PX_4BIT )
#define  PX_MAC8     ( PX_PACKED + PX_1COMP + PX_USES8 + PX_8BIT )
#define  PX_MAC15    ( PX_xFIRST + PX_PACKED + PX_3COMP + PX_USES15 + PX_16BIT )
#define  PX_MAC32    ( PX_xFIRST + PX_PACKED + PX_3COMP + PX_USES24 + PX_32BIT )

/* Pixelformate fÅr Grafikkarten */
#define  PX_VGA1     ( PX_PACKED + PX_1COMP + PX_USES1 + PX_1BIT )
#define  PX_VGA4     ( PX_PLANES + PX_1COMP + PX_USES4 + PX_4BIT )
#define  PX_VGA8     ( PX_PACKED + PX_1COMP + PX_USES8 + PX_8BIT )
#define  PX_VGA15    ( PX_REVERSED + PX_xFIRST + PX_PACKED + PX_3COMP + PX_USES15 + PX_16BIT )
#define  PX_VGA16    ( PX_REVERSED + PX_PACKED + PX_3COMP + PX_USES16 + PX_16BIT )
#define  PX_VGA24    ( PX_REVERSED + PX_PACKED + PX_3COMP + PX_USES24 + PX_24BIT )
#define  PX_VGA32    ( PX_REVERSED + PX_xFIRST + PX_PACKED + PX_3COMP + PX_USES24 + PX_32BIT )

#define  PX_MATRIX16 ( PX_PACKED + PX_3COMP + PX_USES16 + PX_16BIT )

#define  PX_NOVA32   ( PX_PACKED + PX_3COMP + PX_USES24 + PX_32BIT )

/* Pixelformate fÅr Drucker */
#define  PX_PRN1     ( PX_PACKED + PX_1COMP + PX_USES1 + PX_1BIT )
#define  PX_PRN8     ( PX_PACKED + PX_1COMP + PX_USES8 + PX_8BIT )
#define  PX_PRN32    ( PX_xFIRST + PX_PACKED + PX_3COMP + PX_USES24 + PX_32BIT )

/* bevorzugte (schnelle) Pixelformate fÅr Bitmaps */
#define  PX_PREF1    ( PX_PACKED + PX_1COMP + PX_USES1 + PX_1BIT )
#define  PX_PREF2    ( PX_PACKED + PX_1COMP + PX_USES2 + PX_2BIT )
#define  PX_PREF4    ( PX_PACKED + PX_1COMP + PX_USES4 + PX_4BIT )
#define  PX_PREF8    ( PX_PACKED + PX_1COMP + PX_USES8 + PX_8BIT )
#define  PX_PREF15   ( PX_xFIRST + PX_PACKED + PX_3COMP + PX_USES15 + PX_16BIT )
#define  PX_PREF32   ( PX_xFIRST + PX_PACKED + PX_3COMP + PX_USES24 + PX_32BIT )

/******************************************************************************/

enum
{
	CSPACE_RGB		=	0x0001,
	CSPACE_ARGB		=	0x0002,
	CSPACE_CMYK		=	0x0004
};

/******************************************************************************/

enum
{
	CSPACE_1COMPONENT		=	0x0001,
	CSPACE_2COMPONENTS	=	0x0002,
	CSPACE_3COMPONENTS	= 	0x0003,
	CSPACE_4COMPONENTS	=	0x0004
};

/******************************************************************************/

/* Logische EingabegerÑte (fÅr vsin_mode) */
#define DEV_LOCATOR	1
#define DEV_VALUATOR	2
#define DEV_CHOICE	3
#define DEV_STRING	4

/******************************************************************************/

/* Eingabe-Modus der EingabegerÑte (fÅr vsin_mode) */
#define MODE_REQUEST	1
#define MODE_SAMPLE	2

/******************************************************************************/

/* Die Seiten-Formate (fÅr v_opnprn) */
#define PAGE_DEFAULT		0
#define PAGE_A3			1		/* DIN A3 */
#define PAGE_A4			2		/* DIN A4 */
#define PAGE_A5			3		/* DIN A5 */
#define PAGE_B5			4		/* DIN B5 */

#define PAGE_LETTER		16		/* letter size      */
#define PAGE_HALF			17		/* half size        */
#define PAGE_LEGAL		18		/* legal size       */
#define PAGE_DOUBLE		19		/* double size      */
#define PAGE_BROAD		20		/* broad sheet size */

/******************************************************************************/

/* Flags fÅr die Font-Informationen Åber Fonts (fÅr vqt_ext_name) */
#define FNT_AEQUIDIST	0x0001
#define FNT_SYMBOL		0x0010

/******************************************************************************/

/* Flags fÅr die Font-Informationen Åber das Font-Format (fÅr vqt_ext_name) */
#define FNT_BITMAP	0x0001
#define FNT_SPEEDO	0x0002
#define FNT_TRUETYPE	0x0004
#define FNT_TYPE1		0x0008

/******************************************************************************/

/* Das Mapping von Zeichen (fÅr vqt_char_index) */
#define CHARIDX_DIRECT	0
#define CHARIDX_ASCII	1
#define CHARIDX_UNICODE	2

/******************************************************************************/

/* Mode-Konstanten fÅr vst_charmap */
#define CHARMODE_DIRECT		 0
#define CHARMODE_ASCII		 1
#define CHARMODE_UNICODE	 2
#define CHARMODE_UNKNOWN	-1

/******************************************************************************/

/* Modes fÅr Track-Kerning (vst_kern) */
#define TRACKMODE_NO					0
#define TRACKMODE_NORMAL			1
#define TRACKMODE_TIGHTY			2
#define TRACKMODE_VERY_TIGHTY		3

/******************************************************************************/

/* Modes fÅr Pair-Kerning (vst_kern) */
#define PAIRKERN_OFF		0
#define PAIRKERN_ON		1

/******************************************************************************/

/* Ausrichtung der Seite (v_orient) */
#define ORIENT_INQUIRE		-1
#define ORIENT_NORMAL		0
#define ORIENT_LANDSCAPE	1

/******************************************************************************/

/* RÅckgabewerte von vq_vgdos */
#define GDOS_NONE      -2L            /* no GDOS installed           */
#define GDOS_FSM       0x5F46534DL    /* '_FSM' - FSMGDOS installed  */
#define GDOS_FNT       0x5F464E54L    /* '_FNT' - FONTGDOS installed */

/******************************************************************************/

/* Die Funktion _vq_gdos ist identisch mit vq_vgdos */
#define _vq_gdos() vq_vgdos()

/******************************************************************************/
/*																										*/
/* Die diversen VDI-Strukturen																*/
/*																										*/
/******************************************************************************/

/* Datentyp fÅr Vektorfonts ab NVDI 4.x */
typedef int32 fix31;

/******************************************************************************/

typedef struct
{
	void *fd_addr;
	int16 fd_w;
	int16 fd_h;
	int16 fd_wdwidth;
	int16 fd_stand;
	int16 fd_nplanes;
	int16 fd_r1;
	int16 fd_r2;
	int16 fd_r3;
} MFDB;

/******************************************************************************/

/* Struktur des Headers eines GEM-Metafiles */
typedef struct
{
	int16 mf_header;		/* -1, Metafile-Kennung                             */
	int16 mf_length;		/* HeaderlÑnge in Worten (normalerweise 24)         */
	int16 mf_version;		/* Versionsnummer des Formats, hier 101 fÅr 1.01    */
	int16 mf_ndcrcfl;		/* NDC/RC-Flag, normalerweise 2 (Rasterkoordinaten) */
	int16 mf_extents[4];	/* optional - maximale Ausmaûe der Grafik           */
	int16 mf_pagesz[2];	/* optional - Seitengrîûe in 1/10 mm                */
	int16 mf_coords[4];	/* optional - Koordinatensystem                     */
	int16 mf_imgflag;		/* Flag fÅr durch v_bit_image() eingebundene Bilder */
	int16 mf_resvd[9];
} METAHDR;

/******************************************************************************/

/* Font-Info-Struktur (fÅr vqt_xfntinfo) */
typedef struct
{
	int32 size;					/* LÑnge der Struktur, muû vor vqt_xfntinfo() gesetzt werden */
	int16 format;				/* Fontformat, z.B. 4 f&uuml;r TrueType                      */
	int16 id;					/* Font-ID, z.B. 6059                                        */
	int16 index;				/* Index                                                     */
	char	font_name[50];		/* vollstÑndiger Fontname, z.B. "Century 725 Italic BT"      */
	char	family_name[50];	/* Name der Fontfamilie, z.B. "Century725 BT"                */
	char	style_name[50];	/* Name des Fontstils, z.B. "Italic"                         */
	char	file_name1[200];	/* Name der 1. Fontdatei, z.B. "C:\FONTS\TT1059M_.TTF"       */
	char	file_name2[200];	/* Name der optionalen 2. Fontdatei                          */
	char	file_name3[200];	/* Name der optionalen 3. Fontdatei                          */
	int16 pt_cnt;				/* Anzahl der Punkthîhen fÅr vst_point(), z.B. 10            */
	int16 pt_sizes[64];		/* verfÅgbare Punkthîhen, z.B.                               */
									/* {8, 9, 10, 11, 12, 14, 18, 24, 36, 48}                    */
} XFNT_INFO;

/******************************************************************************/

/* Aufbau der RGB-Farben */
typedef struct
{
	uint16 reserved;	/* reserviert, auf 0 setzen */
	uint16 red;			/* Rot-Anteil: 0..65535     */
	uint16 green;		/* GrÅn-Anteil: 0..65535    */
	uint16 blue;		/* Blau-Anteil: 0..65535    */
} COLOR_RGB;

/******************************************************************************/

/* Aufbau der CMYK-Farben */
typedef struct
{
	uint16 cyan;
	uint16 magenta;
	uint16 yellow;
	uint16 black;
} COLOR_CMYK;

/******************************************************************************/

/* Ein Eintrag der Farbtabelle */
typedef union
{
	COLOR_RGB	rgb;
	COLOR_CMYK	cmyk;
} COLOR_ENTRY;

/******************************************************************************/

#define	COLOR_TAB_MAGIC	'ctab'

/* Die Farb-Tabelle */
typedef struct
{
	int32 magic;				/* COLOR_TAB_MAGIC ('ctab') */
	int32 length;
	int32 format;				/* Format (0) */
	int32 reserved;			/* reserviert, auf 0 setzen */
	
	int32 map_id;				/* Kennung der Farbtabelle */
	int32 color_space;		/* Farbraum (z.Zt. nur CSPACE_RGB) */
	int32 flags;				/* VDI-interne Flags, auf 0 setzen */
	int32 no_colors;			/* Anzahl der FarbeintrÑge */
	
	int32 reserved1;			/* reserviert, auf 0 setzen */
	int32 reserved2;			/* reserviert, auf 0 setzen */
	int32 reserved3;			/* reserviert, auf 0 setzen */
	int32 reserved4;			/* reserviert, auf 0 setzen */
	
	COLOR_ENTRY colors[];	/* Die Tabelle der EintrÑge */
} COLOR_TAB;

/******************************************************************************/

/* vordefinierte Tabelle mit 256 EintrÑgen */
typedef struct							/* Farbtabelle */
{
	int32 magic;				/* COLOR_TAB_MAGIC ('ctab') */
	int32 length;
	int32 format;				/* Format (0) */
	int32 reserved;			/* reserviert, auf 0 setzen */
	
	int32 map_id;				/* Kennung der Farbtabelle */
	int32 color_space;		/* Farbraum (z.Zt. nur CSPACE_RGB) */
	int32 flags;				/* VDI-interne Flags, auf 0 setzen */
	int32 no_colors;			/* Anzahl der FarbeintrÑge */
	
	int32 reserved1;			/* reserviert, auf 0 setzen */
	int32 reserved2;			/* reserviert, auf 0 setzen */
	int32 reserved3;			/* reserviert, auf 0 setzen */
	int32 reserved4;			/* reserviert, auf 0 setzen */
	
	COLOR_ENTRY colors[256];/* Die Tabelle der EintrÑge */
} COLOR_TAB256;

/******************************************************************************/

/* Zwei Zeiger-Typen auf die Farb-Tabelle */
typedef COLOR_TAB *CTAB_PTR;
typedef COLOR_TAB	*CTAB_REF;

/******************************************************************************/

/* Die inverse Farbtabelle - Aufbau nicht dokumentiert und nicht von Bedeutung */
typedef void INVERSE_CTAB;
typedef INVERSE_CTAB *ITAB_PTR;
typedef INVERSE_CTAB *ITAB_REF;

/******************************************************************************/

#define CBITMAP_MAGIC	'cbtm'

/* ôffentliche Bitmapbeschreibung (Struktur mit Versionsheader) */
typedef struct _gcbitmap
{
   int32       magic;      /* Strukturkennung CBITMAP_MAGIC ('cbtm') */
   int32       length;     /* StrukturlÑnge */
   int32       format;     /* Strukturformat (0) */
   int32       reserved;   /* reserviert (0) */
	
   uint8       *addr;      /* Adresse der Bitmap */
   int32       width;      /* Breite einer Zeile in Bytes */
   int32       bits;       /* Bittiefe */
   uint32      px_format;  /* Pixelformat */
	
   int32       xmin;       /* minimale diskrete x-Koordinate der Bitmap */
   int32       ymin;       /* minimale diskrete y-Koordinate der Bitmap */
   int32       xmax;       /* maximale diskrete x-Koordinate der Bitmap + 1 */
   int32       ymax;       /* maximale diskrete y-Koordinate der Bitmap + 1 */
	
   CTAB_REF    ctab;       /* Verweis auf die Farbtabelle oder 0L */
   ITAB_REF    itab;       /* Verweis auf die inverse Farbtabelle oder 0L */
   int32       reserved0;  /* reserviert (muû auf 0 gesetzt werden) */
   int32       reserved1;  /* reserviert (muû auf 0 gesetzt werden) */
} GCBITMAP;

/******************************************************************************/

/* Wert des Cookies 'NVDI' */
typedef struct
{
	uint16 nvdi_version;  /*  z.B. 0x0301 fÅr Version 3.01    */
	uint32 nvdi_datum;    /*  z.B. 0x18061990L fÅr 18.06.1990 */
	struct
	{
		unsigned           : 9;  /* Reserved                       */
		unsigned alert     : 1;  /* Error-messages on/off          */
		unsigned           : 1;  /* Reserved                       */
		unsigned linea     : 1;  /* LINE-A                         */
		unsigned mouse     : 1;  /* Dynamic mouse                  */
		unsigned gemdos    : 1;  /* (Fast) GEMDOS character output */
		unsigned error     : 1;  /* Error compatibility            */
		unsigned gdos      : 1;  /* GDOS                           */
	} nvdi_config;
} NVDI_STRUC;

/******************************************************************************/
/*																										*/
/* Die AES-Include-Datei wird nun benîtigt												*/
/*	Diese kann erst hier eingelesen werden, da dort auf vorstehende Strukturen	*/
/* verwiesen wird!																				*/
/*																										*/
/******************************************************************************/

#include <AES.H>

/******************************************************************************/
/*																										*/
/* Prototyp der Assembler-Routine															*/
/*	Diese macht den VDI-Aufruf und setzt den dazu nîtigen VDI-Parameterblock	*/
/* auf dem Stack zusammen - das ist etwas multithreading freundlicher... ;-)	*/
/*																										*/
/******************************************************************************/

void CDECL vdi_( int16 *contrl, int16 *intin, int16 *ptsin, int16 *intout, int16 *ptsout );

/******************************************************************************/
/*																										*/
/* Eigentliche VDI-Funktionen mit "Original-Parametern"								*/
/*																										*/
/******************************************************************************/

typedef struct
{
	int16 contrl[15];
	int16 intin[132];
	int16 intout[140];
	int16 ptsin[145];
	int16 ptsout[145];
} VDIPARBLK;

typedef struct
{
	int16 *contrl;
	int16 *intin;
	int16 *ptsin;
	int16 *intout;
	int16 *ptsout;
} VDIPB;

extern VDIPARBLK _VDIParBlk;

/******************************************************************************/
	
/* Die "alte" Fassung des VDI-Aufrufes */
void vdi( VDIPB *vdipb );

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*																									*/
/* Die Kontroll-Funktionen																	*/
/*																									*/
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

int16 vst_load_fonts( const int16 handle, const int16 select );
void vst_unload_fonts( const int16 handle, const int16 select );
void vs_clip( const int16 handle, const int16 clip_flag, const int16 *pxyarray );

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*																									*/
/* Die Ausgabe-Funktionen																	*/
/*																									*/
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

void vr_recfl( const int16 handle, const int16 *pxyarray );
void v_rfbox( const int16 handle, const int16 *rectangle );
void v_rbox( const int16 handle, const int16 *pxyarray );

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*																									*/
/* Die Attribut-Funktionen																	*/
/*																									*/
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

void vs_color( const int16 handle, const int16 index, const int16 *rgb );
int16 vs_ctab( const int16 handle, COLOR_TAB *ctab );
int16 vs_ctab_entry( const int16 handle, const int16 index,
				const int32 color_space, COLOR_ENTRY *color );
int16 vs_dflt_ctab( const int16 handle );

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*																									*/
/* Die Raster-Funktionen																	*/
/*																									*/
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

void vro_cpyfm( const int16 handle, const int16 wr_mode, const int16 *pxyarray,
				const MFDB *source, MFDB *dest );
void vrt_cpyfm( const int16 handle, const int16 wr_mode, const int16 *pxyarray,
				const MFDB *source, MFDB *dest, const int16 color[2] );
void vr_transfer_bits( const int16 handle, const GCBITMAP *src_bm, const GCBITMAP *dst_bm,
				const int16 *src_rect, const int16 *dst_rect, const int16 mode );

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*																									*/
/* Die Auskunft-Funktionen																	*/
/*																									*/
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

int16 vq_color( const int16 handle, const int16 color, const int16 set_flag, int16 *rgb );
void vq_cellarray( const int16 handle, const int16 *pxyarray, const int16 row_length,
				const int16 num_rows, int16 *el_used, int16 *rows_used, int16 *status,
				int16 *colarray );

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*																									*/
/* Die Escape-Funktionen																	*/
/*																									*/
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

void v_output_window( const int16 handle, const int16 *pxyarray );
void v_bit_image( const int16 handle, const char *filename, const int16 aspect,
				const int16 x_scale, const int16 y_scale, const int16 h_align,
				const int16 v_align, const int16 *pxyarray );

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*																										*/
/* Die Kontroll-Funktionen																		*/
/*																										*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

void v_opnwk( int16 *work_in, int16 *handle, int16 *work_out );
int16 v_opnprn( int16 *handle, PRN_SETTINGS *settings, int16 *work_out );
void v_opnprnwrk( int16 *handle, int16 *work_in, PRN_SETTINGS *settings, int16 *work_out );
void v_opnmatrixprn( int16 *work_in, int16 *handle, int16 *work_out, int16 max_x, int16 max_y );
void v_opnmeta( int16 *work_in, int16 *handle, int16 *work_out, const char *filename );
void v_clswk( const int16 handle );
void v_opnvwk( int16 *work_in, int16 *handle, int16 *work_out );
void v_clsvwk( const int16 handle );
void v_clrwk( const int16 handle );
void v_updwk( const int16 handle );

/* NVDI-Erweiterungen */
void v_opnbm( int16 *work_in, const MFDB *bitmap, int16 *handle, int16 *work_out );
void v_clsbm( const int16 handle );
int16 v_open_bm( const int16 base_handle, const GCBITMAP *bitmap, const int16 zero,
				const int16 flags, const int16 pixel_width, const int16 pixel_height );
int16 v_resize_bm( const int16 handle, const int16 width, const int16 height,
				const int32 byte_width, const uint8 *addr );

/* Speedo-Erweiterung */
void v_set_app_buff( const int16 handle, void *address, const int16 nparagraphs );

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*																										*/
/* Die Ausgabe-Funktionen																		*/
/*																										*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

void v_pline( const int16 handle, const int16 count, int16 *pxyarray );
void v_pmarker( const int16 handle, const int16 count, int16 *pxyarray );
void v_gtext( const int16 handle, const int16 x, const int16 y, const char *string );
void v_fillarea( const int16 handle, const int16 count, int16 *pxyarray );
void v_cellarray( const int16 handle, int16 *pxyarray, const int16 row_length,
			const int16 el_used, const int16 num_rows, const int16 wrt_mode,
			const int16 *colarray );
void v_contourfill( const int16 handle, const int16 x, const int16 y, const int16 index );
void v_bar( const int16 handle, int16 *pxyarray );
void v_arc( const int16 handle, const int16 x, const int16 y,
			const int16 radius, const int16 beg_ang, const int16 end_ang );
void v_pieslice( const int16 handle, const int16 x, const int16 y,
			const int16 radius, const int16 beg_ang, const int16 end_ang );
void v_circle( const int16 handle, const int16 x, const int16 y, const int16 radius );
void v_ellipse( const int16 handle, const int16 x, const int16 y,
			const int16 xradius, const int16 yradius );
void v_ellarc( const int16 handle, const int16 x, const int16 y,
		const int16 xradius, const int16 yradius, const int16 beg_ang, const int16 end_ang );
void v_ellpie( const int16 handle, const int16 x, const int16 y,
			const int16 xradius, const int16 yradius, const int16 beg_ang, const int16 end_ang );
void v_justified( const int16 handle, const int16 x, const int16 y, char *string,
			const int16 length, const int16 word_space, const int16 char_space );

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

void v_bez( const int16 handle, const int16 count, int16 *pxyarray, char *bezarray,
			int16 *extent, int16 *totpts, int16 *totmoves );
int16 v_bez_on( const int16 handle );
void v_bez_off( const int16 handle );
void v_bez_qual( const int16 handle, const int16 qual, int16 *set_qual );
void v_bez_fill( const int16 handle, const int16 count, int16 *pxyarray, uint8 *bezarray,
			int16 *extent, int16 *totpts, int16 *totmoves );
void v_ftext( const int16 handle, const int16 x, const int16 y, const char *string );
void v_ftext_offset( const int16 handle, const int16 x, const int16 y,
			const char *string, const int16 *offsets );

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

int16 v_get_outline( const int16 handle, const int16 index, const int16 x_offset,
			const int16 y_offset, int16 *xyarray, uint8 *bezarray, const int16 max_pts );
void v_getoutline( const int16 handle, const int16 index, int16 *xyarray, 
			uint8 *bezarray, const int16 max_pts, int16 *count );

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*																										*/
/* Die Attribut-Funktionen																		*/
/*																										*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

int16 vq_gdos( void );
int32 vq_vgdos( void );
int16 vswr_mode( const int16 handle, const int16 mode );
int16 vsl_type( const int16 handle, const int16 style );
void vsl_udsty( const int16 handle, const int16 pattern );
int16 vsl_width( const int16 handle, const int16 width );
int16 vsl_color( const int16 handle, const int16 color );
void vsl_ends( const int16 handle, const int16 beg_style, const int16 end_style );
int16 vsm_type( const int16 handle, const int16 symbol );
int16 vsm_height( const int16 handle, const int16 height );
int16 vsm_color( const int16 handle, const int16 color );
void vst_height( const int16 handle, const int16 height,
			int16 *char_width, int16 *char_height, int16 *cell_width, int16 *cell_height );
int16 vst_point( const int16 handle, const int16 point, 
			int16 *char_width, int16 *char_height, int16 *cell_width, int16 *cell_height );
int16 vst_arbpt( const int16 handle, const int16 point, int16 *char_width,
			int16 *char_height, int16 *cell_width, int16 *cell_height );
fix31 vst_arbpt32( const int16 handle, const fix31 height, int16 *char_width,
			int16 *char_height, int16 *cell_width, int16 *cell_height );
int16 vst_setsize( const int16 handle, const int16 width, int16 *char_width,
			int16 *char_height, int16 *cell_width, int16 *cell_height );
fix31 vst_setsize32( const int16 handle, const fix31 width, int16 *char_width,
			int16 *char_height, int16 *cell_width, int16 *cell_height );
int16 vst_rotation( const int16 handle, const int16 angle );
int16 vst_font( const int16 handle, const int16 fontID );
int16 vst_color( const int16 handle, const int16 color );
int16 vst_effects( const int16 handle, const int16 effect );
void vst_error( const int16 handle, const int16 mode, int16 *errorcode );
int16 v_savecache( const int16 handle, char *filename );
int16 v_loadcache( const int16 handle, const char *filename, const int16 mode );
int16 v_flushcache( const int16 handle );
void vst_scratch( const int16 handle, const int16 mode );
void vst_alignment( const int16 handle, const int16 hor_in, const int16 ver_in,
			int16 *hor_out, int16 *ver_out );
int16 vst_name( const int16 handle, const int16 font_format, const char *font_name,
			char *ret_name );
void vst_width( const int16 handle, const int16 width, int16 *char_width,
					int16 *char_height, int16 *cell_width, int16 *cell_height );
void vst_charmap( const int16 handle, const int16 mode );
int16 vst_map_mode( const int16 handle, const int16 mode );
void vst_kern( const int16 handle, const int16 track_mode, const int16 pair_mode,
			int16 *tracks, int16 *pairs );
void vst_kern_offset( const int16 handle, const fix31 offset, const int16 pair_mode,
			int16 *tracks, int16 *pairs );
void vst_track_offset( const int16 handle, const fix31 offset, const int16 pair_mode,
			int16 *tracks, int16 *pairs );
int16 vst_skew( const int16 handle, const int16 skew );
int16 vsf_interior( const int16 handle, const int16 style );
int16 vsf_style( const int16 handle, const int16 style );
int16 vsf_color( const int16 handle, const int16 color );
int16 vsf_perimeter( const int16 handle, const int16 per_vis );
void vsf_udpat( const int16 handle, const int16 *pattern, const int16 nplanes );
void vsf_updat( const int16 handle, const int16 *pattern, const int16 nplanes );

/* Aus PC-GEM/3 */
int16 vsf_perimeter3( const int16 handle, const int16 per_vis, const int16 style );

/* NVDI-Erweiterungen */
int16 vst_fg_color( const int16 handle, int32 color_space, COLOR_ENTRY *fg_color );
int16 vsf_fg_color( const int16 handle, int32 color_space, COLOR_ENTRY *fg_color );
int16 vsl_fg_color( const int16 handle, int32 color_space, COLOR_ENTRY *fg_color );
int16 vsm_fg_color( const int16 handle, int32 color_space, COLOR_ENTRY *fg_color );
int16 vsr_fg_color( const int16 handle, int32 color_space, COLOR_ENTRY *fg_color );
int16 vst_bg_color( const int16 handle, int32 color_space, COLOR_ENTRY *bg_color );
int16 vsf_bg_color( const int16 handle, int32 color_space, COLOR_ENTRY *bg_color );
int16 vsl_bg_color( const int16 handle, int32 color_space, COLOR_ENTRY *bg_color );
int16 vsm_bg_color( const int16 handle, int32 color_space, COLOR_ENTRY *bg_color );
int16 vsr_bg_color( const int16 handle, int32 color_space, COLOR_ENTRY *bg_color );
fixed vq_prn_scaling( const int16 handle );

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*																										*/
/* Die Raster-Funktionen																		*/
/*																										*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

void vr_trnfm( const int16 handle, const MFDB *source, MFDB *dest );
void v_get_pixel( const int16 handle, const int16 x, const int16 y,
			int16 *pix_value, int16 *col_index );

/* NVDI-Erweiterungen */
int16 v_orient( const int16 handle, const int16 orient );
int16 vs_hilite_color( const int16 handle, const int32 color_space,
				const COLOR_ENTRY *hilite_color );
int16 vs_min_color( const int16 handle, const int32 color_space,
				const COLOR_ENTRY *min_color );
int16 vs_max_color( const int16 handle, const int32 color_space,
				const COLOR_ENTRY *min_color );
int16 vs_weight_color( const int16 handle, const int32 color_space,
				const COLOR_ENTRY *weight_color );
int16 vs_document_info( const int16 handle, const int16 type, const char *s, int16 wchar );

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*																										*/
/* Die Eingabe-Funktionen																		*/
/*																										*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

int16 vsin_mode( const int16 handle, const int16 dev_type, const int16 mode );
void vrq_locator( const int16 handle, const int16 x_in, const int16 y_in,
			int16 *x_out, int16 *y_out, int16 *term );
int16 vsm_locator( const int16 handle, const int16 x_in, const int16 y_in,
			int16 *x_out, int16 *y_out, int16 *term );
void vrq_valuator( const int16 handle, const int16 value_in, int16 *value_out, int16 *term );
void vsm_valuator( const int16 handle, const int16 value_in,
			int16 *value_out, int16 *term, int16 *status );
void vrq_choice( const int16 handle, const int16 choice_in, int16 *choice_out );
int16 vsm_choice( const int16 handle, int16 *choice );
void vrq_string( const int16 handle, const int16 max_length, const int16 echo_mode,
			const int16 *echo_xy, char *string );
int16 vsm_string( const int16 handle, const int16 max_length, const int16 echo_mode,
			const int16 *echo_xy, char *string );
void vex_timv( const int16 handle, const int16 (*tim_addr)(void),
			int16 (**otim_addr)(void), int16 *tim_conv );
void v_show_c( const int16 handle, const int16 reset );
void v_hide_c( const int16 handle );
void vq_mouse( const int16 handle, int16 *pstatus, int16 *x, int16 *y );
void vex_butv( const int16 handle, const int16 (*pusrcode)(void), int16 (**psavcode)(void) );
void vex_motv( const int16 handle, const int16 (*pusrcode)(void), int16 (**psavcode)(void) );
void vex_curv( const int16 handle, const int16 (*pusrcode)(void), int16 (**psavcode)(void) );
void vq_key_s( const int16 handle, int16 *pstatus );
void vex_wheelv( const int16 handle, const int16 (*pusrcode)(void), int16 (**psavcode)(void) );

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*																										*/
/* Die Auskunft-Funktionen																		*/
/*																										*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

void vq_extnd( const int16 handle, const int16 owflag, int16 *workout );
void vql_attributes( const int16 handle, int16 *attrib );
void vqm_attributes( const int16 handle, int16 *attrib );
void vqf_attributes( const int16 handle, int16 *attrib );
void vqt_extent( const int16 handle, const char *string, int16 *extent );
int16 vqt_width( const int16 handle, const int16 character, int16 *cell_width,
			int16 *left_delta, int16 *right_delta );
void vqin_mode( const int16 handle, const int16 dev_type, int16 *input_mode );
void vqt_attributes( const int16 handle, int16 *attrib );

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

/* Speedo-Erweiterung */
void vqt_get_table( const int16 handle, int16 **map );
void vqt_cachesize( const int16 handle, const int16 which_cache, int32 *size );

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

/* NVDI-Erweiterungen */
void vqt_f_extent( const int16 handle, const char *string, int16 *extent );
void vqt_real_extent( const int16 handle, const int16 x,
			const int16 y, const char *string, int16 *extent );
int16 vqt_name( const int16 handle, const int16 element_num, char *name );
int16 vqt_ext_name( const int16 handle, const int16 element_num, char *name,
				uint16 *font_format, uint16 *flags );
int16 vqt_xfntinfo( const int16 handle, const int16 flags, const int16 id,
				const int16 index, XFNT_INFO *info );
int16 vqt_name_and_id( const int16 handle, const int16 font_format,
				const char *font_name, char *ret_name );
void vqt_fontinfo( const int16 handle, int16 *minADE, int16 *maxADE, int16 *distances,
			int16 *maxwidth, int16 *effects );
void vqt_justified( const int16 handle, const int16 x, const int16 y, const char *string,
			const int16 length, const int16 word_space, const int16 char_space, int16 *offsets );
void vq_devinfo( const int16 handle, const int16 device, boolean *dev_open,
			char *file_name, char *device_name );
void vqt_devinfo( const int16 handle, const int16 devnum,
				boolean *devexists, char *devstr );
boolean vq_ext_devinfo( const int16 handle, const int16 device, boolean *dev_exists,
			char *file_path, char *file_name, char *name );
void vqt_fontheader( const int16 handle, void *buffer, char *tdf_name );
void vq_scrninfo( const int16 handle, int16 *work_out );
void vqt_trackkern( const int16 handle, fix31 *x_offset, fix31 *y_offset );
void vqt_pairkern( const int16 handle, const int16 index1, const int16 index2,
				fix31 *x_offset, fix31 *y_offset );
void vqt_advance( const int16 handle, const int16 ch, int16 *x_advance, int16 *y_advance,
				int16 *x_remainder, int16 *y_remainder );
void vqt_advance32( const int16 handle, const int16 index,
				fix31 *x_advance, fix31 *y_advance );
void v_getbitmap_info( const int16 handle, const int16 index,
			fix31 *x_advance, fix31 *y_advance, fix31 *x_offset, fix31 *y_offset,
			int16 *width, int16 *height, int16 **bitmap );
int32 vq_hilite_color( const int16 handle, COLOR_ENTRY *hilite_color );
int32 vq_min_color( const int16 handle, COLOR_ENTRY *min_color );
int32 vq_max_color( const int16 handle, COLOR_ENTRY *min_color );
int32 vq_weight_color( const int16 handle, COLOR_ENTRY *min_color );

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

uint16 vqt_char_index( const int16 handle, const uint16 src_index,
					const int16 src_mode, const int16 dst_mode );
boolean vqt_isCharAvailable( const int16 handle, const uint16 unicode );

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*																										*/
/* Die Escape-Funktionen																		*/
/*																										*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

void vq_chcells( const int16 handle, int16 *rows, int16 *cols );
void v_exit_cur( const int16 handle );
void v_enter_cur( const int16 handle );
void v_curup( const int16 handle );
void v_curdown( const int16 handle );
void v_curright( const int16 handle );
void v_curleft( const int16 handle );
void v_curhome( const int16 handle );
void v_eeos( const int16 handle );
void v_eeol( const int16 handle );
void v_curaddress( const int16 handle, const int16 row, const int16 col );
void vs_curaddress( const int16 handle, const int16 row, const int16 col );
void v_curtext( const int16 handle, const char *string );
void v_rvon( const int16 handle );
void v_rvoff( const int16 handle );
void vq_curaddress( const int16 handle, int16 *row, int16 *col );
int16 vq_tabstatus( const int16 handle );
void v_hardcopy( const int16 handle );
void v_dspcur( const int16 handle, const int16 x, const int16 y );
void v_rmcur( const int16 handle );
void v_form_adv( const int16 handle );
void v_clear_disp_list( const int16 handle );
void vq_scan( const int16 handle, int16 *g_slice, int16 *g_page,
			int16 *a_slice, int16 *a_page, int16 *div_fac );
void v_alpha_text( const int16 handle, const char *string );
int16 v_copies( int16 handle, int16 count );
int16 v_trays( const int16 handle, const int16 input, const int16 output,
				int16 *set_input, int16 *set_output );
int16 vq_tray_names( const int16 handle, char *input_name, char *output_name,
				int16 *input, int16 *output );
int16 v_page_size( const int16 handle, const int16 page_id );
int16 vq_page_name( const int16 handle, const int16 page_id, char *page_name,
				int32 *page_width, int32 *page_height );
int16 vs_palette( const int16 handle, const int16 palette );
void v_sound( const int16 handle, const int16 frequency, const int16 duration );
int16 vs_mute( const int16 handle, const int16 action );
void vt_resolution( const int16 handle, const int16 xres, const int16 yres,
			int16 *xset, int16 *yset );
void vt_axis( const int16 handle, const int16 xres, const int16 yres,
			int16 *xset, int16 *yset );
void vt_origin( const int16 handle, const int16 xorigin, const int16 yorigin );
void vq_tdimensions( const int16 handle, int16 *xdim, int16 *ydim );
void vt_alignment( const int16 handle, const int16 dx, const int16 dy );
void vsp_film( const int16 handle, const int16 index, const int16 lightness );
int16 vqp_filmname( const int16 handle, const int16 index, char *name );
void vsc_expose( const int16 handle, const int16 status );
void v_meta_extents( const int16 handle, const int16 min_x, const int16 min_y,
			const int16 max_x, const int16 max_y );
void v_write_meta( const int16 handle, const int16 num_intin, const int16 *a_intin,
			const int16 num_ptsin, const int16 *a_ptsin );
void vm_pagesize( const int16 handle, const int16 pgwidth, const int16 pgheight );
void vm_coords( const int16 handle, const int16 llx, const int16 lly,
			const int16 urx, const int16 ury );
void vm_filename( const int16 handle, const char *filename );
void v_offset( const int16 handle, const int16 offset );
void v_fontinit( const int16 handle, const void *font_header );
void v_escape2000( const int16 handle, const int16 times );

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

/* NVDI-Erweiterungen */
int16 vs_calibrate( const int16 handle, const boolean flag, const RGB1000 *table );
int16 vq_calibrate( const int16 handle, boolean *flag );

int32 vqt_fg_color( const int16 handle, COLOR_ENTRY *fg_color );
int32 vqf_fg_color( const int16 handle, COLOR_ENTRY *fg_color );
int32 vql_fg_color( const int16 handle, COLOR_ENTRY *fg_color );
int32 vqm_fg_color( const int16 handle, COLOR_ENTRY *fg_color );
int32 vqr_fg_color( const int16 handle, COLOR_ENTRY *fg_color );
int32 vqt_bg_color( const int16 handle, COLOR_ENTRY *bg_color );
int32 vqf_bg_color( const int16 handle, COLOR_ENTRY *bg_color );
int32 vql_bg_color( const int16 handle, COLOR_ENTRY *bg_color );
int32 vqm_bg_color( const int16 handle, COLOR_ENTRY *bg_color );
int32 vqr_bg_color( const int16 handle, COLOR_ENTRY *bg_color );
void v_setrgb( const int16 handle, const int16 type,
				const int16 r, const int16 g, const int16 b );
uint32 v_color2value( const int16 handle, const int32 color_space, COLOR_ENTRY *color );
int32 v_value2color( const int16 handle, const uint32 value, COLOR_ENTRY *color );
int32 v_color2nearest( const int16 handle, const int32 color_space, const COLOR_ENTRY *color,
			COLOR_ENTRY *nearest );
int32 vq_px_format( const int16 handle, uint32 *px_format );
int16 vq_ctab( const int16 handle, const int32 ctab_length, COLOR_TAB *ctab );
int32 vq_ctab_entry( const int16 handle, const int16 index, COLOR_ENTRY *color );
int32 vq_ctab_id( const int16 handle );
int16 v_ctab_idx2vdi( const int16 handle, const int16 index );
int16 v_ctab_vdi2idx( const int16 handle, const int16 index );
int32 v_ctab_idx2value( const int16 handle, const int16 index );
int32 v_get_ctab_id( const int16 handle );
int16 vq_dflt_ctab( const int16 handle, int32 ctab_length, COLOR_TAB *ctab );
COLOR_TAB *v_create_ctab( const int16 handle, const int32 color_space, uint32 px_format );int16 v_delete_ctab( const int16 handle, COLOR_TAB *ctab );ITAB_REF v_create_itab( const int16 handle, COLOR_TAB *ctab, int16 bits );
int16 v_delete_itab( const int16 handle, ITAB_REF *itab );

/******************************************************************************/
/*																										*/
/* Utility-Funktionen fÅr NVDI 4.x															*/
/*																										*/
/******************************************************************************/

/* Format fix31 in Pixel umrechnen */
int16 fix31ToPixel( fix31 a );

/* NVDI-Cookie lesen */
NVDI_STRUC *Ash_NVDICookie( void );

/* Eine EdDI-Funktion aufrufen */
int16 Ash_CallEdDI( int16 fkt_nr );

/* NVDI-Version & NVDI-Datum ermitteln */
uint16 Ash_NVDIVersion( void );
uint32 Ash_NVDIDatum( void );

/******************************************************************************/

#ifdef __cplusplus
}
#endif

/******************************************************************************/

#endif
