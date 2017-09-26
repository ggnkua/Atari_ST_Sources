/*
	Tabulatorweite: 3
	Kommentare ab: Spalte 60											*Spalte 60*
*/

#include	<Types2B.h>
#include	<stddef.h>														/* wird fŸr offsetof() benštigt */

#ifndef	__COLORMAP__
#define	__COLORMAP__

/*----------------------------------------------------------------------------------------*/
/* Farben und FarbrŠume																							*/
/*----------------------------------------------------------------------------------------*/

enum																			/* FarbrŠume (color_space) */
{
	CSPACE_FLAGS	= 	0xff00,											/* die oberen 8 Bits fŸr Flags */
	CSPACE_MASK		=	0x00ff,											/* die unteren 8 Bit fŸr die Farbraumkennung */
	
	CSPACE_ALPHA_FLAG	= 0x0100,										/* Flag fŸr Alphakanal */

	CSPACE_UNKNOWN =	0x0000,

	CSPACE_RGB		=	0x0001,											/* RGB-Farbraum */
	CSPACE_ARGB		=	0x0101,											/* RGB-Farbraum mit Alphakanal */

	CSPACE_HSV		=	0x0002,											/* HSV-Farbraum */
	CSPACE_HSL		=	0x0003,											/* HSL-Farbraum */

	CSPACE_CMYK		=	0x0004,											/* CMYK-Farbraum */

	CSPACE_YCbCr	=	0x0005,											/* YCbCr-Farbraum */
	CSPACE_YCCK		=	0x0006,											/* YCbCrK-Farbraum */

	CSPACE_GRAY		=	0x0007,											/* Grau-Farbraum */
	CSPACE_AGRAY	=	0x0107,											/* Grau-Farbraum mit Alphakanal */

	CSPACE_PhotoYCC = 0x0008,											/* YCC-Farbraum (PhotoCD) */
	CSPACE_APhotoYCC = 0x0108,											/* YCC-Farbraum (PhotoCD) mit Alphakanal */

	CSPACE_XYZ		= 	0x0010,											/* XYZ-Farbraum */
	CSPACE_Yxy		= 	0x0011,											/* Yxy-Farbraum */
	CSPACE_Lab		=	0x0012,											/* L*a*b*-Farbraum */
	CSPACE_Luv		=	0x0013											/* L*u*v*-Farbraum */
};

enum																			/* Komponentenanzahl in der Farbtabelle (flags) */
{
	CSPACE_1COMPONENT		=	0x0001,
	CSPACE_2COMPONENTS	=	0x0002,
	CSPACE_3COMPONENTS	= 	0x0003,
	CSPACE_4COMPONENTS	=	0x0004,
	CSPACE_5COMPONENTS	=	0x0005,
	CSPACE_6COMPONENTS	=	0x0006,
	CSPACE_7COMPONENTS	=	0x0007,
	CSPACE_COMP_MASK		=	0x000f									/* Maske fŸr die Komponentenanzahl */
};

#pragma PRAGMA_PACKED_ALIGN											/* Strukturelemente byteweise anordnen */

typedef struct																/* RGB-Farbwert */
{
	uint16	reserved;
	uint16	red;
	uint16	green;
	uint16	blue;
} COLOR_RGB;

typedef struct																/* ARGB-Farbwert */
{
	uint16	alpha;
	uint16	red;
	uint16	green;
	uint16	blue;
} COLOR_ARGB;

typedef struct																/* HSL-Farbwert */
{
	uint16	reserved;
	uint16	hue;
	uint16	saturation;
	uint16	lightness;
} COLOR_HSL;

typedef struct																/* HSV-Farbwert */
{
	uint16	reserved;
	uint16	hue;
	uint16	saturation;
	uint16	value;
} COLOR_HSV;

typedef struct																/* CMYK-Farbwert */
{
	uint16	cyan;
	uint16	magenta;
	uint16	yellow;
	uint16	black;
} COLOR_CMYK;

typedef struct																/* YCbCr-Farbwert */
{
	uint16	reserved;
	uint16	Y;
	uint16	Cb;
	uint16	Cr;
} COLOR_YCbCr;

typedef struct																/* YCCK-Farbwert */
{
	uint16	Y;
	uint16	Cb;
	uint16	Cr;
	uint16	K;																/* ###CHANGE: je nach Verhalten von Photoshop, das wohl das einzig wichtige Programm  */
																				/* fŸr diese Format ist, kann sich diese Definition noch Šndern */
} COLOR_YCCK;

typedef struct																/* Graustufe */
{
	uint16	reserved;
	uint16	reserved1;													/* sollte aus KompatibilitŠtsgrŸnden auf den gleichen Wert wie gray gesetzt werden */
	uint16	reserved2;													/* sollte aus KompatibilitŠtsgrŸnden auf den gleichen Wert wie gray gesetzt werden */
	uint16	gray;
} COLOR_GRAY;

typedef struct																/* Graustufe mit Alphakanal */
{
	uint16	alpha;
	uint16	reserved1;													/* sollte aus KompatibilitŠtsgrŸnden auf den gleichen Wert wie gray gesetzt werden */
	uint16	reserved2;													/* sollte aus KompatibilitŠtsgrŸnden auf den gleichen Wert wie gray gesetzt werden */
	uint16	gray;
} COLOR_AGRAY;

typedef struct																/* XYZ-Farbwert */
{
	uint16	reserved;
	uint16	X;
	uint16	Y;
	uint16	Z;
} COLOR_XYZ;

typedef struct																/* Yxy-Farbwert */
{
	uint16	reserved;
	uint16	Y;
	uint16	x;
	uint16	y;
} COLOR_Yxy;

typedef struct																/* L*a*b*-Farbwert */
{
	uint16	reserved;
	uint16	L;																/* 0 entspricht 0.0, 0xffffU entspricht 1.0 */
	uint16	a;																/* 0 entspricht -1.0, 0x8000 entspricht 0.0, 0xffff entspricht 1.0 */
	uint16	b;																/* 0 entspricht -1.0, 0x8000 entspricht 0.0, 0xffff entspricht 1.0 */
} COLOR_Lab;

typedef struct																/* L*u*v*-Farbwert */
{
	uint16	reserved;
	uint16	L;																/* 0 entspricht 0.0, 0xffffU entspricht 1.0 */
	uint16	u;																/* 0 entspricht -1.0, 0x8000 entspricht 0.0, 0xffff entspricht 1.0 */
	uint16	v;																/* 0 entspricht -1.0, 0x8000 entspricht 0.0, 0xffff entspricht 1.0 */
} COLOR_Luv;

typedef union
{
	COLOR_RGB	rgb;
	COLOR_ARGB	argb;
	COLOR_HSV	hsv;
	COLOR_HSL	hsl;
	COLOR_CMYK	cmyk;
	COLOR_YCbCr	ycc;
	COLOR_YCCK	ycck;
	COLOR_GRAY	gray;
	COLOR_AGRAY	agray;
	COLOR_XYZ	xyz;
	COLOR_Yxy	yxy;
	COLOR_Lab	lab;
	COLOR_Luv	luv;
} COLOR_ENTRY;

#pragma PRAGMA_RESET_ALIGN												/* Einstellung zurŸcksetzen */

/*----------------------------------------------------------------------------------------*/
/* Farbtabellen																									*/
/*----------------------------------------------------------------------------------------*/
#pragma PRAGMA_PACKED_ALIGN											/* Strukturelemente byteweise anordnen */

#define	COLOR_TAB_MAGIC	CHAR_CONST32('ctab')
#define	CTAB_TEMP_ID		0											/* signalisiert eine noch nicht zugewiesene Kennung der Farbtabelle */

typedef struct																/* Farbtabelle */
{
	int32	magic;															/* 'ctab' */
	int32	length;
	int32	format;															/* Format (0) */
	int32	reserved;
	
	int32	map_id;															/* Kennung der Farbtabelle */
	int32	color_space;													/* Farbraum */
	int32	flags;															/* interne Flags */
	int32	no_colors;														/* Anzahl der FarbeintrŠge */

	int32	non_system_colors;											/* Anzahl der nicht-Systemfarben (wird intern verwaltet; war reserved1) */
	int32	reserved2;
	int32	reserved3;
	int32	reserved4;

	COLOR_ENTRY	colors[VARIABLE_ARRAY_SIZE];
} COLOR_TAB;

#define	sizeof_COLOR_TAB	offsetof( COLOR_TAB, colors )		/* StrukturlŠnge ohne variablen Anhang */

/* vordefinierte Tabelle mit 256 EintrŠgen */
typedef struct																/* Farbtabelle */
{
	int32	magic;															/* 'ctab' */
	int32	length;
	int32	format;															/* Format (0) */
	int32	reserved;
	
	int32	map_id;															/* Kennung der Farbtabelle */
	int32	color_space;													/* Farbraum */
	int32	flags;															/* interne Flags */
	int32	no_colors;														/* Anzahl der FarbeintrŠge */

	int32	reserved1;
	int32	reserved2;
	int32	reserved3;
	int32	reserved4;

	COLOR_ENTRY	colors[256];
} COLOR_TAB256;

typedef void	INVERSE_CTAB;											/* inverse Farbtabelle */

#pragma PRAGMA_RESET_ALIGN												/* Einstellung zurŸcksetzen */

/*----------------------------------------------------------------------------------------*/
/* Verweise auf Farbtabellen																					*/
/*----------------------------------------------------------------------------------------*/

typedef COLOR_TAB		*CTAB_PTR;
typedef COLOR_TAB		*CTAB_REF;
typedef INVERSE_CTAB	*ITAB_REF;

/*----------------------------------------------------------------------------------------*/
/*	Bitmaps																											*/
/*----------------------------------------------------------------------------------------*/
#pragma PRAGMA_PACKED_ALIGN											/* Strukturelemente byteweise anordnen */

#define	CBITMAP_MAGIC	CHAR_CONST32('cbtm')

typedef struct	_gcbitmap												/* šffentliche Bitmapbeschreibung mit Header fŸr Systemaufrufe */
{
	int32			magic;													/* Strukturkennung 'cbtm' */
	int32			length;													/* StrukturlŠnge */
	int32			format;													/* Strukturformat (0) */
	int32			reserved;												/* reserviert (0) */

	uint8			*addr;													/* Adresse der Bitmap */
	int32			width;													/* Breite einer Zeile in Bytes */
	int32			bits;														/* Bittiefe */
	uint32		px_format;												/* Pixelformat */

	int32			xmin;														/* minimale diskrete x-Koordinate der Bitmap */
	int32			ymin;														/* minimale diskrete y-Koordinate der Bitmap */
	int32			xmax;														/* maximale diskrete x-Koordinate der Bitmap + 1 */
	int32			ymax;														/* maximale diskrete y-Koordinate der Bitmap + 1 */

	CTAB_REF		ctab;														/* Verweis auf die Farbtabelle oder 0L */
	ITAB_REF		itab;														/* Verweis auf die inverse Farbtabelle oder 0L */
	int32			color_space;											/* Farbraum (war bei frŸheren Varianten 0/CSPACE_UNKNOWN: reserved0) */
	int32			reserved1;												/* reserviert (0) */
} GCBITMAP;

#pragma PRAGMA_RESET_ALIGN												/* Einstellung zurŸcksetzen */

/*----------------------------------------------------------------------------------------*/
/* Konstanten fŸr Pixelformate																				*/
/*----------------------------------------------------------------------------------------*/

/* Anzahl der benutzten Komponenten */
#define	PX_1COMP		0x01000000L										/* Pixel besteht aus einer benutzten Komponente: Farbindex */
#define	PX_2COMP		0x02000000L										/* Pixel besteht aus zwei benutzten Komponenten, z.B. AG */
#define	PX_3COMP		0x03000000L										/* Pixel besteht aus drei benutzten Komponenten, z.B. RGB, YCbCr, XYZ, Yxy, Lab, Luv */
#define	PX_4COMP		0x04000000L										/* Pixel besteht aus vier benutzten Komponenten, z.B. CMYK, ARGB */
#define	PX_5COMP		0x05000000L										/* Pixel besteht aus fŸnf benutzten Komponenten */
#define	PX_6COMP		0x06000000L										/* Pixel besteht aus sechs benutzten Komponenten*/
#define	PX_7COMP		0x07000000L										/* Pixel besteht aus sieben benutzten Komponenten */

/* Little-Endian */
#define	PX_REVERSED	0x00800000L										/* Pixel wird in umgekehrter Bytreihenfolge ausgegeben */

/* Rotation der Komponenten */
#define	PX_0LROTATE	0x00400000L										/* unbenutzte Bits liegen links */
#define	PX_1LROTATE	0x00500000L										/* um 1 Komponente nach links rotieren */
#define	PX_2LROTATE	0x00600000L										/* um 2 Komponenten nach links rotieren */
#define	PX_3LROTATE	0x00700000L										/* um 3 Komponenten nach links rotieren */

#define	PX_0RROTATE	0x00000000L										/* unbenutzte Bits liegen rechts */
#define	PX_1RROTATE	0x00100000L										/* um 1 Komponente nach rechts rotieren */
#define	PX_2RROTATE	0x00200000L										/* um 2 Komponenten nach rechts rotieren */
#define	PX_3RROTATE	0x00300000L										/* um 3 Komponenten nach rechts rotieren */

#define	PX_xFIRST	0x00400000L										/* xRGB: Unbenutzte Bits liegen links und die Komponenten werden nach links rotiert */
#define	PX_xLAST		0x00000000L										/* RGBx: Unbenutzte Bits liegen rechts und die Komponenten werden nach rechts rotiert */

#define	PX_kFIRST	0x00100000L										/* KCMY: K liegt vor CMY (CMYK um eine Komponenten nach rechts rotiert ergibt KCMY) */
#define	PX_kLAST		0x00000000L										/* CMYK: K liegt hinter CMY (CMYK ohne Rotation) */

#define	PX_aFIRST	0x00400000L										/* ARGB: A liegt vor RGB (es sind keine unbenutzten Bits vorhanden, aber aus KompatibilitŠt zu xRGB wird um 0 Komponenten nach links rotiert) */
#define	PX_aLAST		0x00300000L										/* RGBA: A liegt hinter RGB (ARGB um drei Komponenten nach rechts rotiert ergibt RGBA) */

/* Packverfahren */
#define	PX_PACKED	0x00020000L										/* Bits bzw. Komponenten sind aufeinanderfolgend abgelegt */
#define	PX_PLANES	0x00010000L										/* Bits sind auf mehrere Ebenen verteilt (Reihenfolge: 0, 1, ..., n) */
#define	PX_IPLANES	0x00000000L										/* Bits sind auf mehrere Worte verteilt (Reihenfolge: 0, 1, ..., n) */

/* Anzahl der benutzten Bits */
#define	PX_USES1		0x00000100L										/* 1 Bit des Pixels wird benutzt */
#define	PX_USES2		0x00000200L										/* 2 Bit des Pixels werden benutzt */
#define	PX_USES3		0x00000300L										/* 3 Bit des Pixels werden benutzt */
#define	PX_USES4		0x00000400L										/* 4 Bit des Pixels werden benutzt */
#define	PX_USES8		0x00000800L										/* 8 Bit des Pixels werden benutzt */
#define	PX_USES15	0x00000f00L										/* 15 Bit des Pixels werden benutzt */
#define	PX_USES16	0x00001000L										/* 16 Bit des Pixels werden benutzt */
#define	PX_USES24	0x00001800L										/* 24 Bit des Pixels werden benutzt */
#define	PX_USES30	0x00001e00L										/* 30 Bit des Pixels werden benutzt */
#define	PX_USES32	0x00002000L										/* 32 Bit des Pixels werden benutzt */
#define	PX_USES48	0x00003000L										/* 48 Bit des Pixels werden benutzt */
#define	PX_USES64	0x00004000L										/* 64 Bit des Pixels werden benutzt */

/* Anzahl der Bits pro Pixel */
#define	PX_1BIT		0x00000001L										/* Pixel besteht aus 1 Bit */
#define	PX_2BIT		0x00000002L										/* Pixel besteht aus 2 Bit */
#define	PX_3BIT		0x00000003L										/* Pixel besteht aus 3 Bit */
#define	PX_4BIT		0x00000004L										/* Pixel besteht aus 4 Bit */
#define	PX_8BIT		0x00000008L										/* Pixel besteht aus 8 Bit */
#define	PX_16BIT		0x00000010L										/* Pixel besteht aus 16 Bit */
#define	PX_24BIT		0x00000018L										/* Pixel besteht aus 24 Bit */
#define	PX_32BIT		0x00000020L										/* Pixel besteht aus 32 Bit */
#define	PX_48BIT		0x00000030L										/* Pixel besteht aus 48 Bit */
#define	PX_64BIT		0x00000040L										/* Pixel besteht aus 64 Bit */

/* Masken */
#define	PX_CMPNTS	0x0f000000L										/* Maske fŸr Anzahl der Pixelkomponenten */
#define	PX_FLAGS		0x00f00000L										/* Maske fŸr diverse Flags (Little Endian/Rotationsrichtung/Anzahl der rotierten Komponenten) */
#define	PX_RTDIR		0x00400000L										/* Rotationsrichtung */
#define	PX_RTCMPNTS	0x00300000L										/* Anzahl der zu rotierenden Komponenten */
#define	PX_PACKING	0x00030000L										/* Maske fŸr Pixelformat */
#define	PX_USED		0x0000ff00L										/* Maske fŸr Anzahl der benutzten Bits */
#define	PX_BITS		0x000000ffL										/* Maske fŸr Anzahl der Bits pro Pixel */

/*----------------------------------------------------------------------------------------*/
/* Zugriffsmakros																									*/
/*----------------------------------------------------------------------------------------*/
#define	get_PX_CMPNTS( px_format )		((( px_format ) & PX_CMPNTS ) >> 24 )
#define	get_PX_USED( px_format )		((( px_format ) & PX_USED ) >> 8 )
#define	get_PX_BITS( px_format )		((( px_format ) & PX_BITS ))

#define	set_PX_CMPNTS( components )	(( components ) << 24 )
#define	set_PX_USED( used_bits )		(( used_bits ) << 8 )
#define	set_PX_BITS( total_bits )		(( total_bits ))

/*----------------------------------------------------------------------------------------*/
/* Pixelformate fŸr ATARI-Grafik	(RGB)																		*/
/*----------------------------------------------------------------------------------------*/
#define	PX_ATARI1	( PX_PACKED + PX_1COMP + PX_USES1 + PX_1BIT )
#define	PX_ATARI2	( PX_IPLANES + PX_1COMP + PX_USES2 + PX_2BIT )
#define	PX_ATARI4	( PX_IPLANES + PX_1COMP + PX_USES4 + PX_4BIT )
#define	PX_ATARI8	( PX_IPLANES + PX_1COMP + PX_USES8 + PX_8BIT )
#define	PX_FALCON15	( PX_PACKED + PX_3COMP + PX_USES16 + PX_16BIT )

/*----------------------------------------------------------------------------------------*/
/* Pixelformate fŸr Macintosh	(RGB)																			*/
/*----------------------------------------------------------------------------------------*/
#define	PX_MAC1		( PX_PACKED + PX_1COMP + PX_USES1 + PX_1BIT )
#define	PX_MAC4		( PX_PACKED + PX_1COMP + PX_USES4 + PX_4BIT )
#define	PX_MAC8		( PX_PACKED + PX_1COMP + PX_USES8 + PX_8BIT )
#define	PX_MAC15		( PX_xFIRST + PX_PACKED + PX_3COMP + PX_USES15 + PX_16BIT )
#define	PX_MAC32		( PX_xFIRST + PX_PACKED + PX_3COMP + PX_USES24 + PX_32BIT )

/*----------------------------------------------------------------------------------------*/
/* Pixelformate fŸr Grafikkarten	(RGB)																		*/
/*----------------------------------------------------------------------------------------*/
#define	PX_VGA1		( PX_PACKED + PX_1COMP + PX_USES1 + PX_1BIT )
#define	PX_VGA4		( PX_PLANES + PX_1COMP + PX_USES4 + PX_4BIT )
#define	PX_VGA8		( PX_PACKED + PX_1COMP + PX_USES8 + PX_8BIT )
#define	PX_VGA15		( PX_REVERSED + PX_xFIRST + PX_PACKED + PX_3COMP + PX_USES15 + PX_16BIT )
#define	PX_VGA16		( PX_REVERSED + PX_PACKED + PX_3COMP + PX_USES16 + PX_16BIT )
#define	PX_VGA24		( PX_REVERSED + PX_PACKED + PX_3COMP + PX_USES24 + PX_24BIT )
#define	PX_VGA32		( PX_REVERSED + PX_xFIRST + PX_PACKED + PX_3COMP + PX_USES24 + PX_32BIT )

#define	PX_MATRIX16	( PX_PACKED + PX_3COMP + PX_USES16 + PX_16BIT )

#define	PX_NOVA32	( PX_PACKED + PX_3COMP + PX_USES24 + PX_32BIT )

/*----------------------------------------------------------------------------------------*/
/* Pixelformate fŸr Drucker (RGB)																			*/
/*----------------------------------------------------------------------------------------*/
#define	PX_PRN1		( PX_PACKED + PX_1COMP + PX_USES1 + PX_1BIT )
#define	PX_PRN3		( PX_PLANES + PX_1COMP + PX_USES3 + PX_3BIT )
#define	PX_PRN4		( PX_PLANES + PX_1COMP + PX_USES4 + PX_4BIT )
#define	PX_PRN8		( PX_PACKED + PX_1COMP + PX_USES8 + PX_8BIT )
#define	PX_PRN32		( PX_xFIRST + PX_PACKED + PX_3COMP + PX_USES24 + PX_32BIT )

/*----------------------------------------------------------------------------------------*/
/* bevorzugte (schnelle) Pixelformate fŸr Bitmaps (RGB)												*/
/*----------------------------------------------------------------------------------------*/
#define	PX_PREFn( n )	( PX_PACKED + PX_1COMP + ( n << 8 ) + n )
#define	PX_PREF1		( PX_PACKED + PX_1COMP + PX_USES1 + PX_1BIT )
#define	PX_PREF2		( PX_PACKED + PX_1COMP + PX_USES2 + PX_2BIT )
#define	PX_PREF4		( PX_PACKED + PX_1COMP + PX_USES4 + PX_4BIT )
#define	PX_PREF8		( PX_PACKED + PX_1COMP + PX_USES8 + PX_8BIT )
#define	PX_PREF15	( PX_xFIRST + PX_PACKED + PX_3COMP + PX_USES15 + PX_16BIT )
#define	PX_PREF32	( PX_xFIRST + PX_PACKED + PX_3COMP + PX_USES24 + PX_32BIT )

/*----------------------------------------------------------------------------------------*/
/* Pixelformate fŸr RGB								 															*/
/*----------------------------------------------------------------------------------------*/
#define	PX_xRGB15	( PX_xFIRST + PX_PACKED + PX_3COMP + PX_USES15 + PX_16BIT )
#define	PX_RGB24		( PX_PACKED + PX_3COMP + PX_USES24 + PX_24BIT )
#define	PX_xRGB24	( PX_xFIRST + PX_PACKED + PX_3COMP + PX_USES24 + PX_32BIT )
#define	PX_RGB48		( PX_PACKED + PX_3COMP + PX_USES48 + PX_48BIT )
#define	PX_xRGB48	( PX_xFIRST + PX_PACKED + PX_3COMP + PX_USES48 + PX_64BIT )

/*----------------------------------------------------------------------------------------*/
/* Pixelformate fŸr RGB mit Alpha-Kanal								 									*/
/*----------------------------------------------------------------------------------------*/
#define	PX_ARGB32	( PX_aFIRST + PX_4COMP + PX_PACKED + PX_USES32 + PX_32BIT )
#define	PX_ARGB64	( PX_aFIRST + PX_4COMP + PX_PACKED + PX_USES64 + PX_64BIT )

#define	PX_RGBA32	( PX_aLAST + PX_4COMP + PX_PACKED + PX_USES32 + PX_32BIT )
#define	PX_RGBA64	( PX_aLAST + PX_4COMP + PX_PACKED + PX_USES64 + PX_64BIT )

/*----------------------------------------------------------------------------------------*/
/* Pixelformate fŸr CMYK								 														*/
/*----------------------------------------------------------------------------------------*/
#define	PX_CMYK32	( PX_PACKED + PX_4COMP + PX_USES32 + PX_32BIT )
#define	PX_CMYK64	( PX_PACKED + PX_4COMP + PX_USES64 + PX_64BIT )

#define	PX_KCMY32	( PX_kFIRST + PX_PACKED + PX_4COMP + PX_USES32 + PX_32BIT )
#define	PX_KCMY64	( PX_kFIRST + PX_PACKED + PX_4COMP + PX_USES64 + PX_64BIT )

/*----------------------------------------------------------------------------------------*/
/* Pixelformate fŸr YCrCb								 														*/
/*----------------------------------------------------------------------------------------*/
#define	PX_YCC24		( PX_PACKED + PX_3COMP + PX_USES24 + PX_24BIT )
#define	PX_xYCC24	( PX_xFIRST + PX_PACKED + PX_3COMP + PX_USES24 + PX_32BIT )
#define	PX_xYCC30	( PX_xFIRST + PX_PACKED + PX_3COMP + PX_USES30 + PX_32BIT )
#define	PX_YCC48		( PX_PACKED + PX_3COMP + PX_USES48 + PX_48BIT )
#define	PX_xYCC48	( PX_xFIRST + PX_PACKED + PX_3COMP + PX_USES48 + PX_64BIT )

/*----------------------------------------------------------------------------------------*/
/* Pixelformate fŸr YCCK								 														*/
/*----------------------------------------------------------------------------------------*/
#define	PX_YCCK32	( PX_PACKED + PX_4COMP + PX_USES32 + PX_32BIT )
#define	PX_YCCK64	( PX_PACKED + PX_4COMP + PX_USES64 + PX_64BIT )

/*----------------------------------------------------------------------------------------*/
/* Pixelformate fŸr L*a*b*									 													*/
/*----------------------------------------------------------------------------------------*/
#define	PX_Lab24		( PX_PACKED + PX_3COMP + PX_USES24 + PX_24BIT )
#define	PX_xLab24	( PX_xFIRST + PX_PACKED + PX_3COMP + PX_USES24 + PX_32BIT )
#define	PX_xLab30	( PX_xFIRST + PX_PACKED + PX_3COMP + PX_USES30 + PX_32BIT )
#define	PX_Lab48		( PX_PACKED + PX_3COMP + PX_USES48 + PX_48BIT )
#define	PX_xLab48	( PX_xFIRST + PX_PACKED + PX_3COMP + PX_USES48 + PX_64BIT )

/*----------------------------------------------------------------------------------------*/
/* Pixelformate fŸr L*u*v*									 													*/
/*----------------------------------------------------------------------------------------*/
#define	PX_Luv24		( PX_PACKED + PX_3COMP + PX_USES24 + PX_24BIT )
#define	PX_xLuv24	( PX_xFIRST + PX_PACKED + PX_3COMP + PX_USES24 + PX_32BIT )
#define	PX_xLuv30	( PX_xFIRST + PX_PACKED + PX_3COMP + PX_USES30 + PX_32BIT )
#define	PX_Luv48		( PX_PACKED + PX_3COMP + PX_USES48 + PX_48BIT )
#define	PX_xLuv48	( PX_xFIRST + PX_PACKED + PX_3COMP + PX_USES48 + PX_64BIT )


/*----------------------------------------------------------------------------------------*/
/* Makros fŸr Pixelwandlung in Direct-RGB																	*/
/*----------------------------------------------------------------------------------------*/

#define	PX15pp16( s )		((( s << 1 ) & 0xffc0 ) | \
									(( s >> 4 ) & 0x0020 ) | \
									( s & 0x001f ))

#define	PX15pp32( s )		((( s << 9 ) & 0x00f80000L ) | \
									(( s << 4 ) & 0x00070000L ) | \
									(( s << 6 ) & 0x0000f800L ) | \
									(( s << 1 ) & 0x00000700L ) | \
									(( s << 3 ) & 0x000000f8L ) | \
									(( s >> 2 ) & 0x00000007L ))


#define	PX16pp15( s )		((( s >> 1 ) & 0x7fe0 ) | \
									( s & 0x001f ))

#define	PX16pp32( s )		((( s << 8 ) & 0x00f80000L ) | \
									(( s << 3 ) & 0x000700f8L ) | \
									(( s << 5 ) & 0x0000fc00L ) | \
									(( s >> 1 ) & 0x00000200L ) | \
									(( s >> 2 ) & 0x00000007L ))


#define	PX32pp15( s )		((( s >> 9 ) & 0x7c00 ) | \
									(( s >> 6 ) & 0x03e0 ) | \
									(( s >> 3 ) & 0x001f ))

#define	PX32pp16( s )		((( s >> 8 ) & 0xf800 ) | \
									(( s >> 5 ) & 0x07e0 ) | \
									(( s >> 3 ) & 0x001f ))


#define	PX32ppGREY( s )	(((( s >> 14 ) & 0x03fc ) + \
									(( s >> 16 ) & 0x00ff ) + \
									(( s >> 5 ) & 0x07f8 ) + \
									(( s >> 8 ) & 0x00ff ) + \
									(( s << 1 ) & 0x01fe )) >> 4 )


/*----------------------------------------------------------------------------------------*/
/* Wandlung in bevorzugte Formate																			*/
/*----------------------------------------------------------------------------------------*/

/* gggB bbbb .Rrr rrGg -> .Rrr rrGg gggB bbbb */
#define	BGRx16_xRGB16( s )	((( s >> 8 ) & 0x00ff ) | \
										 (( s << 8 ) & 0xff00 ))

/* Rrrr rGgg gggB bbbb -> .Rrr rrGg gggB bbbb */
#define	RGB16_xRGB16( s )		((( s >> 1 ) & 0x7fe0 ) | \
										  ( s 		 & 0x001f ))

/* gggB bbbb Rrrr rGgg -> .Rrr rrGg gggB bbbb */
#define	BGR16_xRGB16( s )		((( s << 7 ) & 0x7f80 ) | \
										 (( s >> 9 ) & 0x0060 ) | \
										 (( s >> 8 ) & 0x001f ))



/* .Rrr rrGg gggB bbbb - > Rrrr rGgg gggB bbbb */
#define	xRGB16_RGB16( s )		((( s & 0x7fe0 ) << 1 ) | \
										 (( s & 0x0200 ) >> 4 ) | \
										  ( s 		 & 0x001f ))



/* .Rrr rrGg gggB bbbb -> gggB bbbb .Rrr rrGg */
#define	xRGB16_BGRx16( s )	((( s >> 8 ) & 0x00ff ) | \
										 (( s << 8 ) & 0xff00 ))



/* .Rrr rrGg gggB bbbb -> gggB bbbb Rrrr rGgg */
#define	xRGB16_BGR16( s )		((( s & 0x7f80 ) >> 7 ) | \
										 (( s & 0x0060 ) << 9 ) | \
										 (( s & 0x0200 ) << 4 ) | \
										 (( s & 0x001f ) << 8 ))



/* .Rrr rrGg gggB bbbb -> .... .... Rrrr rrrr Gggg gggg Bbbb bbbb */
#define	xRGB16_xRGB32( s )	((( s << 9 ) & 0x00f80000L ) | \
										 (( s << 4 ) & 0x00070000L ) | \
										 (( s << 6 ) & 0x0000f800L ) | \
										 (( s << 1 ) & 0x00000700L ) | \
										 (( s << 3 ) & 0x000000f8L ) | \
										 (( s >> 2 ) & 0x00000007L ))

/* gggB bbbb .Rrr rrGg -> .... .... Rrrr rrrr Gggg gggg Bbbb bbbb */
#define	BGRx16_xRGB32( s )	((( s << 17 ) & 0x00f80000L ) | \
										 (( s << 12 ) & 0x00070000L ) | \
										 (( s << 14 ) & 0x0000c000L ) | \
										 (( s << 9  ) & 0x00000600L ) | \
										 (( s >> 2  ) & 0x00003800L ) | \
										 (( s >> 7  ) & 0x00000100L ) | \
										 (( s >> 5  ) & 0x000000f8L ) | \
										 (( s >> 10 ) & 0x00000007L ))

/* Rrrr rGgg gggB bbbb  -> .... .... Rrrr rrrr Gggg gggg Bbbb bbbb */
#define	RGB16_xRGB32( s )		((( s << 8 ) & 0x00f80000L ) | \
										 (( s << 3 ) & 0x000700f8L ) | \
										 (( s << 5 ) & 0x0000fc00L ) | \
										 (( s >> 1 ) & 0x00000200L ) | \
										 (( s >> 2 ) & 0x00000007L ))

/* gggB bbbb Rrrr rGgg -> .... .... Rrrr rrrr Gggg gggg Bbbb bbbb */
#define	BGR16_xRGB32( s )		((( s << 16 ) & 0x00f80000L ) | \
										 (( s << 11 ) & 0x00070000L ) | \
										 (( s << 13 ) & 0x0000e000L ) | \
										 (( s << 7  ) & 0x00000300L ) | \
										 (( s >> 3  ) & 0x00001c00L ) | \
										 (( s >> 5  ) & 0x000000f8L ) | \
										 (( s >> 10 ) & 0x00000007L ))

/* Rrrr rrrr Gggg gggg Bbbb bbbb -> .... .... Rrrr rrrr Gggg gggg Bbbb bbbb */
#define	RGB24_xRGB32( s )		( s )

/* Bbbb bbbb Gggg gggg Rrrr rrrr -> .... .... Rrrr rrrr Gggg gggg Bbbb bbbb */
#define	BGR24_xRGB32( s )		((( s >> 24 ) & 0x000000ffL ) | \
										 (( s >> 8 )  & 0x0000ff00L ) | \
										 (( s << 16 ) & 0x00ff0000L ))

/* Rrrr rrrr Gggg gggg Bbbb bbbb .... ..... -> .... .... Rrrr rrrr Gggg gggg Bbbb bbbb */
#define	RGBx32_xRGB32( s )	( s >> 8 )

/* Bbbb bbbb Gggg gggg Rrrr rrrr .... ..... -> .... .... Rrrr rrrr Gggg gggg Bbbb bbbb */
#define	BGRx32_xRGB32( s )	((( s >> 24 ) & 0x000000ffL ) | \
										 (( s >> 8 )  & 0x0000ff00L ) | \
										 (( s << 16 ) & 0x00ff0000L ))



/* .... .... Rrrr rrrr Gggg gggg Bbbb bbbb -> Rrrr rrrr Gggg gggg Bbbb bbbb .... ..... */
#define	xRGB32_RGBx32( s )	( s << 8 )



/* .... .... Rrrr rrrr Gggg gggg Bbbb bbbb -> Bbbb bbbb Gggg gggg Rrrr rrrr .... ..... */
#define	xRGB32_BGRx32( s )	((( s << 24 ) & 0xff000000L ) | \
										 (( s >> 8 )  & 0x0000ff00L ) | \
										 (( s << 8 )  & 0x00ff0000L ))


#endif