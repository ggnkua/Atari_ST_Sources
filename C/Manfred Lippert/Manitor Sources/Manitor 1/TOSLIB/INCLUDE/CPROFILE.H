/*
	Tabulatorweite: 3
	Kommentare ab: Spalte 60											*Spalte 60*
*/

#include	<Types2B.h>														/* Prozessorunabhängige Datentypen */

#ifndef __CPROFILE__
#define __CPROFILE__

#define	CPROF_ProfileVersion			 0x02000000L

/* rendering_intent */
#define	CPROF_perceptual					0							/* ... */
#define	CPROF_relative_colorimetric	1							/* relative Farbwerte wählen (in Gamut einpassen) */
#define	CPROF_saturation					2							/* Sättigung beibehalten */
#define	CPROF_absolute_colorimetric	3							/* absolute Farbwerte beibehalten (Farben außerhalb des Gamuts werden geclippt) */

#define	CPROF_MAGIC							CHAR_CONST32('acsp')	/* Kennung für ICC-Profile */

/*----------------------------------------------------------------------------------------*/
/* Kennungen für Profiltypen																					*/
/*----------------------------------------------------------------------------------------*/
#define	CPROF_CLASS_abstract				CHAR_CONST32('abst')
#define	CPROF_CLASS_link					CHAR_CONST32('link')
#define	CPROF_CLASS_display				CHAR_CONST32('mntr')	/* Monitorprofil */
#define	CPROF_CLASS_named_color			CHAR_CONST32('nmcl')
#define	CPROF_CLASS_output				CHAR_CONST32('prtr')	/* Ausgabeprofil für einen Drucker */
#define	CPROF_CLASS_input					CHAR_CONST32('scnr')	/* Eingabeprofil von einem Scanner */
#define	CPROF_CLASS_color_space			CHAR_CONST32('spac')	/* Profil für Farbraumwandlung */

/*----------------------------------------------------------------------------------------*/
/* Profil-Plattform																								*/
/*----------------------------------------------------------------------------------------*/
#define	CPROF_Macintosh					CHAR_CONST32('APPL')
#define	CPROF_Microsoft					CHAR_CONST32('MSFT')
#define	CPROF_Solaris						CHAR_CONST32('SUNW')
#define	CPROF_SiliconGraphics			CHAR_CONST32('SGI ')
#define	CPROF_Taligent						CHAR_CONST32('TGNT')	/* höhö:-) */

/*----------------------------------------------------------------------------------------*/
/* Kennungen der öffentlichen Tags																			*/
/*----------------------------------------------------------------------------------------*/
#define	CPROF_TAG_AToB0					CHAR_CONST32('A2B0')	/* Umsetzungsmatrix Gerätefarbraum -> PCS (perceptual) */
#define	CPROF_TAG_AToB1					CHAR_CONST32('A2B1')	/* Umsetzungsmatrix Gerätefarbraum -> PCS (colorimetric) */
#define	CPROF_TAG_AToB2					CHAR_CONST32('A2B2')	/* Umsetzungsmatrix Gerätefarbraum -> PCS (saturation) */
#define	CPROF_TAG_BlueTRC					CHAR_CONST32('bTRC')	/* "Gamma"-Kurve für blauen Phospor */
#define	CPROF_TAG_BlueColorant			CHAR_CONST32('bXYZ')	/* relativer XYZ-Wert von blauem Phosphor */
#define	CPROF_TAG_BToA0					CHAR_CONST32('B2A0')	/* Umsetzungsmatrix PCS -> Gerätefarbraum (perceptual) */
#define	CPROF_TAG_BToA1					CHAR_CONST32('B2A1')	/* Umsetzungsmatrix PCS -> Gerätefarbraum (colorimetric) */
#define	CPROF_TAG_BToA2					CHAR_CONST32('B2A2')	/* Umsetzungsmatrix PCS -> Gerätefarbraum (saturation) */
#define	CPROF_TAG_UcrBg					CHAR_CONST32('bfd ')	/* UCR und Schwarz-Generierung */
#define	CPROF_TAG_MediaBlackPoint		CHAR_CONST32('bkpt')	/* Schwarzpunkt des Mediums */
#define	CPROF_TAG_CalibrationDateTime	CHAR_CONST32('calt')	/*	Datum und Uhrzeit der Kalibration */
#define	CPROF_TAG_Copyright				CHAR_CONST32('cprt')	/* Copyright-Information */
#define	CPROF_TAG_ProfileDescription	CHAR_CONST32('desc')	/* Profilbeschreibung (Text) */
#define	CPROF_TAG_DeviceMfgDesc			CHAR_CONST32('dmnd')	/* Gerätehersteller */
#define	CPROF_TAG_DeviceModelDesc		CHAR_CONST32('dmdd')	/* Gerätename */
#define	CPROF_TAG_Gamut					CHAR_CONST32('gamt')	/* Gamut-Matrix */
#define	CPROF_TAG_GreenTRC				CHAR_CONST32('gTRC')	/* "Gamma"-Kurve für grünen Phospor */
#define	CPROF_TAG_GreenColorant			CHAR_CONST32('gXYZ')	/* relativer XYZ-Wert von grünem Phosphor */
#define	CPROF_TAG_GrayTRC					CHAR_CONST32('kTRC')	/* Grauton-Kurve */
#define	CPROF_TAG_Luminance				CHAR_CONST32('lumi')	/* absolute Luminanz in cd/m^2 */
#define	CPROF_TAG_Measurement			CHAR_CONST32('meas')	/* alternative Meßspezifikation */
#define	CPROF_TAG_NamedColor2			CHAR_CONST32('ncl2')
#define	CPROF_TAG_NamedColor				CHAR_CONST32('ncol')
#define	CPROF_TAG_Preview0				CHAR_CONST32('pre0')	/* Vorschau-Transformation PCS -> Gerätefarbraum (perceptual) */
#define	CPROF_TAG_Preview1				CHAR_CONST32('pre1')	/* Vorschau-Transformation PCS -> Gerätefarbraum (colorimetric) */
#define	CPROF_TAG_Preview2				CHAR_CONST32('pre2')	/* Vorschau-Transformation PCS -> Gerätefarbraum (saturation) */
#define	CPROF_TAG_PS2CSA					CHAR_CONST32('ps2s')	/* Postscript */
#define	CPROF_TAG_PS2RenderingIntent	CHAR_CONST32('ps2i')	/* Postscript */
#define	CPROF_TAG_PS2CRD0					CHAR_CONST32('psd0')	/* Postscript */
#define	CPROF_TAG_PS2CRD1					CHAR_CONST32('psd1')	/* Postscript */
#define	CPROF_TAG_PS2CRD2					CHAR_CONST32('psd2')	/* Postscript */
#define	CPROF_TAG_PS2CRD3					CHAR_CONST32('psd3')	/* Postscript */
#define	CPROF_TAG_ProfileSequenceDesc	CHAR_CONST32('pseq')	/* Informationen über alle Profile, die zu einem endgültigen Profil kombiniert wurden */
#define	CPROF_TAG_RedTRC					CHAR_CONST32('rTRC')	/* "Gamma"-Kurve für roten Phospor */
#define	CPROF_TAG_RedColorant			CHAR_CONST32('rXYZ')	/* relativer XYZ-Wert von rotem Phosphor */
#define	CPROF_TAG_ScreeningDesc			CHAR_CONST32('scrd')
#define	CPROF_TAG_Screening				CHAR_CONST32('scrn')
#define	CPROF_TAG_CharTarget				CHAR_CONST32('targ')
#define	CPROF_TAG_Technology				CHAR_CONST32('tech')
#define	CPROF_TAG_ViewingConditions	CHAR_CONST32('view')
#define	CPROF_TAG_ViewingConditionsDesc	CHAR_CONST32('vued')
#define	CPROF_TAG_MediaWhitePoint		CHAR_CONST32('wtpt')	/* Weißpunkt des Mediums */

/*----------------------------------------------------------------------------------------*/
/* Kennungen für Technology-Tag																				*/
/*----------------------------------------------------------------------------------------*/
/* Drucker */
#define	CPROF_TECH_DyeSublimationPrinter CHAR_CONST32('dsub')	/* Sublimationsdrucker */
#define	CPROF_TECH_ElectrophotographicPrinter 	CHAR_CONST32('epho')
#define	CPROF_TECH_ElectrostaticPrinter 	CHAR_CONST32('esta')
#define	CPROF_TECH_InkJetPrinter		CHAR_CONST32('ijet')	/* Tintenstrahldrucker */
#define	CPROF_TECH_PhotographicPaperPrinter CHAR_CONST32('rpho')
#define	CPROF_TECH_ThermalWaxPrinter 	CHAR_CONST32('twax')

/* Scanner */
#define	CPROF_TECH_FilmScanner			CHAR_CONST32('fscn')	/* Filmscanner */
#define	CPROF_TECH_ReflectiveScanner 	CHAR_CONST32('rscn')	

/* Monitore */
#define	CPROF_TECH_AMDisplay				CHAR_CONST32('AMD ')	/* Aktiv-Matrix-Display */
#define	CPROF_TECH_CRTDisplay			CHAR_CONST32('CRT ')	/* Bildröhre */
#define	CPROF_TECH_PMDisplay				CHAR_CONST32('PMD ')	/* Passiv-Matrix-Display */

/* sontiges */
#define	CPROF_TECH_PhotoCD				CHAR_CONST32('KPCD')	/* Kodak-Photo CD */
#define	CPROF_TECH_Flexography			CHAR_CONST32('flex')
#define	CPROF_TECH_FilmWriter			CHAR_CONST32('fprn')
#define	CPROF_TECH_Gravure				CHAR_CONST32('grav')
#define	CPROF_TECH_PhotoImageSetter 	CHAR_CONST32('imgs')
#define	CPROF_TECH_OffsetLithography 	CHAR_CONST32('offs')
#define	CPROF_TECH_ProjectionTelevision 	CHAR_CONST32('pjtv')
#define	CPROF_TECH_Silkscreen			CHAR_CONST32('silk')
#define	CPROF_TECH_VideoCamera			CHAR_CONST32('vidc')
#define	CPROF_TECH_VideoMonitor			CHAR_CONST32('vidm')

/*----------------------------------------------------------------------------------------*/
/* Kennungen für die Strukturtypen																			*/
/*----------------------------------------------------------------------------------------*/
#define	CPROF_TYPE_XYZ						CHAR_CONST32('XYZ ')	/* Feld mit XYZ-Werten */
#define	CPROF_TYPE_curve					CHAR_CONST32('curv')	/* Kurvenbeschreibung */
#define	CPROF_TYPE_data					CHAR_CONST32('data')
#define	CPROF_TYPE_profile_description	CHAR_CONST32('desc')	/* Text */
#define	CPROF_TYPE_date_time				CHAR_CONST32('dtim')	/* Datum und Uhrzeit */
#define	CPROF_TYPE_measurement			CHAR_CONST32('meas')
#define	CPROF_TYPE_lut8					CHAR_CONST32('mft1')	/* 8-Bit-Matrix zur Farbraumumrechnung */
#define	CPROF_TYPE_lut16					CHAR_CONST32('mft2')	/* 16-Bit-Matrix zur Farbraumumrechnung */
#define	CPROF_TYPE_named_color2			CHAR_CONST32('ncl2')
#define	CPROF_TYPE_named_color			CHAR_CONST32('ncol')
#define	CPROF_TYPE_screening				CHAR_CONST32('scrn')
#define	CPROF_TYPE_s15fixed16			CHAR_CONST32('sf32')
#define	CPROF_TYPE_signature				CHAR_CONST32('sig ')
#define	CPROF_TYPE_text					CHAR_CONST32('text')
#define	CPROF_TYPE_u1fixed15				CHAR_CONST32('uf16')	/* Feld mit 1.15-Werten */
#define	CPROF_TYPE_u16fixed16			CHAR_CONST32('uf32')	/* Feld mit 16.16-Werten */
#define	CPROF_TYPE_uint8					CHAR_CONST32('ui08')
#define	CPROF_TYPE_uint32					CHAR_CONST32('ui32')
#define	CPROF_TYPE_uint64					CHAR_CONST32('ui64')
#define	CPROF_TYPE_viewing_conditions	CHAR_CONST32('view')

/*----------------------------------------------------------------------------------------*/
/* Kennungen für die Farbräume																				*/
/*----------------------------------------------------------------------------------------*/
#define	CPROF_CSPACE_CMY					CHAR_CONST32('CMY ')
#define	CPROF_CSPACE_CMYK					CHAR_CONST32('CMYK')
#define	CPROF_CSPACE_Gray					CHAR_CONST32('GRAY')
#define	CPROF_CSPACE_HLS					CHAR_CONST32('HLS ')
#define	CPROF_CSPACE_HSV					CHAR_CONST32('HSV ')
#define	CPROF_CSPACE_Lab					CHAR_CONST32('Lab ')
#define	CPROF_CSPACE_Luv					CHAR_CONST32('Luv ')
#define	CPROF_CSPACE_MCH5					CHAR_CONST32('MCH5')
#define	CPROF_CSPACE_RGB					CHAR_CONST32('RGB ')
#define	CPROF_CSPACE_XYZ					CHAR_CONST32('XYZ ')
#define	CPROF_CSPACE_Yxy					CHAR_CONST32('Yxy ')

/* "unbekannte" Farbräume */
#define	CPROF_CSPACE_2COLOR				CHAR_CONST32('2CLR')
#define	CPROF_CSPACE_3COLOR				CHAR_CONST32('3CLR')
#define	CPROF_CSPACE_4COLOR				CHAR_CONST32('4CLR')
#define	CPROF_CSPACE_5COLOR				CHAR_CONST32('5CLR')
#define	CPROF_CSPACE_6COLOR				CHAR_CONST32('6CLR')
#define	CPROF_CSPACE_7COLOR				CHAR_CONST32('7CLR')
#define	CPROF_CSPACE_8COLOR				CHAR_CONST32('8CLR')
#define	CPROF_CSPACE_9COLOR				CHAR_CONST32('9CLR')
#define	CPROF_CSPACE_10COLOR				CHAR_CONST32('ACLR')
#define	CPROF_CSPACE_11COLOR				CHAR_CONST32('BCLR')
#define	CPROF_CSPACE_12COLOR				CHAR_CONST32('CCLR')
#define	CPROF_CSPACE_13COLOR				CHAR_CONST32('DCLR')
#define	CPROF_CSPACE_14COLOR				CHAR_CONST32('ECLR')
#define	CPROF_CSPACE_15COLOR				CHAR_CONST32('FCLR')
#define	CPROF_CSPACE_MCH6					CHAR_CONST32('MCH6')
#define	CPROF_CSPACE_MCH7					CHAR_CONST32('MCH7')
#define	CPROF_CSPACE_MCH8					CHAR_CONST32('MCH8')


/* Measurement Flare */
#define	CPROF_ID_Flare0					0x00000000
#define	CPROF_ID_Flare100					0x00000001

/* Measurement Geometry	*/
#define	CPROF_GEOMETRY_unknown			0x00000000
#define	CPROF_GEOMETRY_045or450			0x00000001
#define	CPROF_GEOMETRY_0dord0			0x00000002

/* Standard Observer	*/
#define	CPROF_STDOBS_unknown				0x00000000
#define	CPROF_STDOBS_1931TwoDegrees	0x00000001
#define	CPROF_STDOBS_1964TenDegrees	0x00000002

/* Standard Illuminant */
#define	CPROF_ILLUMINANT_Unknown		0x00000000
#define	CPROF_ILLUMINANT_D50				0x00000001
#define	CPROF_ILLUMINANT_D65				0x00000002
#define	CPROF_ILLUMINANT_D93				0x00000003
#define	CPROF_ILLUMINANT_F2				0x00000004
#define	CPROF_ILLUMINANT_D55				0x00000005
#define	CPROF_ILLUMINANT_A				0x00000006
#define	CPROF_ILLUMINANT_EquiPower		0x00000007
#define	CPROF_ILLUMINANT_F8				0x00000008

/* Spot Function Value */
#define	CPROF_SPOT_Unknown			0,
#define	CPROF_SPOT_Default			1,
#define	CPROF_SPOT_Round				2,
#define	CPROF_SPOT_Diamond			3,
#define	CPROF_SPOT_Ellipse			4,
#define	CPROF_SPOT_Line				5,
#define	CPROF_SPOT_Square				6,
#define	CPROF_SPOT_Cross				7


/*----------------------------------------------------------------------------------------*/
/* Grundsätzliche Datentypen																					*/
/*----------------------------------------------------------------------------------------*/
#pragma PRAGMA_PACKED_ALIGN											/* Strukturelemente byteweise anordnen */

typedef struct
{
	uint16	year;
	uint16	month;
	uint16	day;
	uint16	hours;
	uint16	minutes;
	uint16	seconds;
} CPROF_DATE_TIME;

typedef struct																/* XYZ-Farbwert in 16.16 Notation */
{
	fixed		X;
	fixed		Y;
	fixed		Z;
} CPROF_FIXED_XYZ;

typedef struct
{
	uint16	X;
	uint16	Y;
	uint16	Z;
} CPROF_COLOR_XYZ;

#pragma PRAGMA_RESET_ALIGN												/* Einstellung zurücksetzen */

/*----------------------------------------------------------------------------------------*/
/* Header des Farbprofils																						*/
/*----------------------------------------------------------------------------------------*/
#pragma PRAGMA_PACKED_ALIGN											/* Strukturelemente byteweise anordnen */

typedef struct
{
	uint32	size;															/* Länge des gesamten Farbprofils */
	uint32	cmm_type;													/* CMM-Kennung */
	uint32	profile_version;											/* Version des ICC-Profils */
	uint32	profile_class;												/* Profiltyp */
	uint32	data_color_space;											/* Farbraum der Profildaten */
	uint32	profile_connection_space;								/* Umrechnungsfarbraum */
	CPROF_DATE_TIME	date_time;										/* Datum und Uhrzeit */
	uint32	profile_signature;										/* 'acsp'-Kennung */
	uint32	platform;													/* Rechnerplattform für das Profil */
	uint32	flags;														/* diverse Flags */
	uint32	device_manufacturer;										/* Gerätehersteller */
	uint32	device_model;												/* Gerätemodell */
	uint32	device_attributes[2];									/* Geräteeigenschaften */
	uint32	rendering_intent;											/* Wandlungs-Absicht */
	CPROF_FIXED_XYZ	white;											/* Profil-Beleuchtung */
	uint32	profile_creator;											/* Kennung des Profil-Erzeugers */
	uint8		reserved[44];												/* reserviert (0) */
} CPROF_HEADER;

typedef	CPROF_HEADER	CPROFILE;

typedef struct
{
	uint32	tag;															/* Kennung der Daten */
	uint32	offset;														/* Position der Daten relativ zum Profilanfang */
	uint32	size;															/* Länge der Daten */
} CPROF_TAG;

typedef struct
{
	uint32	count;														/* Anzahl der Einträge */
	CPROF_TAG	tags[VARIABLE_ARRAY_SIZE];
} CPROF_TAG_TABLE;

#pragma PRAGMA_RESET_ALIGN												/* Einstellung zurücksetzen */

/*----------------------------------------------------------------------------------------*/
/* Definition der Tags																							*/
/*----------------------------------------------------------------------------------------*/
#pragma PRAGMA_PACKED_ALIGN											/* Strukturelemente byteweise anordnen */

typedef struct																/* Feld mit XYZ-Werten */
{
	uint32	type;															/* 'XYZ ' */
	uint32	reserved;													/* reserviert (0) */
	CPROF_FIXED_XYZ	XYZ[VARIABLE_ARRAY_SIZE];
} CPROF_XYZ;
#define	sizeof_CPROF_XYZ	offsetof( CPROF_XYZ, XYZ )			/* Größe ohne Wertefelder */
#define	sizeof_CPROF_XYZ1	( sizeof_CPROF_XYZ + sizeof( CPROF_FIXED_XYZ )) 	/* Größe mit einem Wertefeld */

typedef struct																/* UCR und Schwarz-Generierung */
{
	uint32	type;															/* 'bfd  ' */
	uint32	reserved;													/* reserviert (0) */
	uint32	no_ucr_entries;											/* Anzahl der UCR-Einträge */
	uint16	ucr_values[VARIABLE_ARRAY_SIZE];
	uint32	no_bg_entries;												/* Anzahl der BG-Einträge */
	uint16	bg_values[VARIABLE_ARRAY_SIZE];
	uint8		ucrbg_ASCII[VARIABLE_ARRAY_SIZE];					/* ASCII-Zeichenkette (nullterminiert) */
} CPROF_UCRBG;

typedef struct																/* Kurvendefinition */
{
	uint32	type;															/* 'curv' */
	uint32	reserved;													/* reserviert (0) */
	uint32	no_entries;													/* Anzahl der Einträge */
	uint16	values[VARIABLE_ARRAY_SIZE];
} CPROF_CURVE;
#define	sizeof_CPROF_CURVE	offsetof( CPROF_CURVE, values )	/* Größe ohne Wertefelder */
#define	sizeof_CPROF_CURVE1	( sizeof_CPROF_CURVE + sizeof( uint16 ))	/* Größe mit einem Wertefeld */

typedef struct																/* allgemeine Daten */
{
	uint32	type;															/* 'data' */
	uint32	reserved;													/* reserviert (0) */
	uint32	data_flag;													/* 0: ASCII, 1: binär */
	uint8		data[VARIABLE_ARRAY_SIZE];
} CPROF_DATA;
#define	sizeof_CPROF_DATA	offsetof( CPROF_DATA, data )

typedef struct																/* Text (komplex) */
{
	uint32	type;															/* 'desc' */
	uint32	reserved;													/* reserviert (0) */
	uint32	ASCII_count;												/* Anzahl der ASCII-Zeichen */
	uint8		ASCII_name[VARIABLE_ARRAY_SIZE];
	uint32	unicode_code;												/* Unicode Sprachkennung */
	uint32	unicode_count;												/* Anzahl der Unicode-Zeichen */
	uint16	unicode_name[VARIABLE_ARRAY_SIZE];
	int16		scriptcode_code;											/* Macintosh Script Code */
	uint8		scriptcode_count;											/* Anzahl der Bytes */
	uint8		scriptcode_name[VARIABLE_ARRAY_SIZE];
} CPROF_TEXT_DESCRIPTION;
#define	sizeof_CPROF_TEXT_DESCRIPTION	23							/* Größe ohne irgendwelche Strings */

typedef struct																/* Zeitangabe */
{
	uint32	type;															/* 'dtim' */
	uint32	reserved;													/* reserviert (0) */
	CPROF_DATE_TIME	date_time;										/* Datum und Uhrzeit */
} CPROF_DTIM;

typedef struct
{
	uint32	type;															/* 'meas' */
	uint32	reserved;													/* reserviert (0) */
	uint32	standard_observer;										/* 0: unbekannt, 1: CIE 1931, 2: CIE 1964 */
	CPROF_FIXED_XYZ	backing_XYZ;									/* absolute XYZ-Werte backing */
	uint32	geometry;													/* 0: unbekannt, 1: 0/45 or 45/0, 2: 0/d or d/0 */
	uint32	flare;														/* 0: 0%, 1: 100% flare */
	uint32	illuminant;													/* Kennung des Standard-Illuminanten */
} CPROF_MEASUREMENT;

typedef struct																/* 8-Bit-Matrix für Farbraum-Umrechnung */
{
	uint32	type;															/* 'mft1' */
	uint32	reserved;													/* reserviert (0) */
	uint8		no_input_channels;										/* Anzahl der Eingabekanäle */
	uint8		no_output_channels;										/* Anzahl der Ausgabekanäle */
	uint8		no_grid_points;											/* Anzahl der Gitterpunkte für die CLUT (in jeder Kanalrichtung) */
	uint8		reserved2;													/* reserviert (0) */
	fixed		matrix[3][3];												/* Matrix für Normalisierung der Eingabewärte */
	uint16	no_input_table_entries;									/* Anzahl der Einträge in der input_table */
	uint16	no_output_table_entries;								/* Anzahl der Einträge in der output_table */
	uint8		input_table[256];
	uint8		clut[VARIABLE_ARRAY_SIZE];
	uint8		output_table[256];
} CPROF_LUT8;

typedef struct																/* 16-Bit-Matrix für Farbraum-Umrechnung */
{
	uint32	type;															/* 'mft2' */
	uint32	reserved;													/* reserviert (0) */
	uint8		no_input_channels;										/* Anzahl der Eingabekanäle */
	uint8		no_output_channels;										/* Anzahl der Ausgabekanäle */
	uint8		no_grid_points;											/* Anzahl der Gitterpunkte für die CLUT (in jeder Kanalrichtung) */
	uint8		reserved2;													/* reserviert (0) */
	fixed		matrix[3][3];												/* Matrix für Normalisierung der Eingabewärte */
	uint16	no_input_table_entries;									/* Anzahl der Einträge in der input_table */
	uint16	no_output_table_entries;								/* Anzahl der Einträge in der output_table */
	uint16	input_table[VARIABLE_ARRAY_SIZE];
	uint16	clut[VARIABLE_ARRAY_SIZE];
	uint16	output_table[VARIABLE_ARRAY_SIZE];
} CPROF_LUT16;

typedef struct
{
	uint32	type;															/* 'ncl2' */
	uint32	reserved;													/* reserviert (0) */
	uint32	vendor_flag;												/* diverse Flags */
	uint32	count;														/* Anzahl der benamten Farben im folgenden Feld */
	uint32	device_coords_count;										/* Anzahl der Einträge in device_color_coords */
	uint8		prefix_name[32];
	uint8		suffix_name[32];
	struct
	{
		uint8		root_name[32];
		uint16	PCS_color_coords[3];									/* Koordinaten im Lab- oder XYZ-Farbraum */
		uint16	device_color_coords[VARIABLE_ARRAY_SIZE];		/* Koordinaten im Gerätefarbraum */
	} color_names[VARIABLE_ARRAY_SIZE];
} CPROF_NAME_COLOR2;

typedef struct																/* Wegen konzeptioneller Fehler diese Struktur nicht mehr benutzen; besser ist CPROF_NAME_COLOR2 */
{
	uint32	type;															/* 'ncol' */
	uint32	reserved;													/* reserviert (0) */
	uint32	vendor_flag;												/* diverse Flags */
	uint32	count;														/* Anzahl der benamten Farben im folgenden Feld */
	uint8		prefix_name[VARIABLE_ARRAY_SIZE];					/* max. 32 Bytes groß, um aufs nächste Feld zuzugreifen, muß strlen() benutzt werden */
	uint8		suffix_name[VARIABLE_ARRAY_SIZE];					/* max. 32 Bytes groß, um aufs nächste Feld zuzugreifen, muß strlen() benutzt werden */
	struct
	{
		uint8	root_name[VARIABLE_ARRAY_SIZE];						/* max. 32 Bytes groß, um aufs nächste Feld zuzugreifen, muß strlen() benutzt werden */
		uint8	color_coords[VARIABLE_ARRAY_SIZE];
	} color_names[VARIABLE_ARRAY_SIZE];
} CPROF_NAME_COLOR;

typedef struct																/* Informationen über alle Profile, die zu einem endgültigen Profil kombiniert wurden */
{
	uint32	type;															/* 'pseq' */
	uint32	reserved;													/* reserviert (0) */
	uint32	count;														/* Anzahl der Beschreibungen */

	struct																	/* die Größe der Felder ist z.T. variabel */
	{
		uint32	device_manufacturer;									/* Herstellerr */
		uint32	device_model;											/* Gerätemodell */
		uint32	attributes[2];											/* Geräteeigenschaften */
		uint32	technology;												/* Kennung für Gerätetechnologie */
		uint32	mfg_desc_ASCII_count;								/* Byteanzahl */
		uint8		mfg_desc_ASCII_name[VARIABLE_ARRAY_SIZE];		/* Name als ASCII-String */
		uint32	mfg_desc_unicode_code;								/* Unicode Sprachkennung */
		uint32	mfg_desc_unicode_count;								/* Anzahl der Unicode-Zeichen */
		uint16	mfg_desc_unicode_name[VARIABLE_ARRAY_SIZE];
		uint32	mfg_desc_scriptcode_code;
		uint32	mfg_desc_scriptcode_count;							/* Anzahl der ASCII-Zeichen */
		uint8		mfg_desc_scriptcode_name[VARIABLE_ARRAY_SIZE];
		uint32	model_desc_ASCII_count;
		uint8		model_desc_ASCII_name[VARIABLE_ARRAY_SIZE];
		uint32	model_desc_unicode_code;							/* Unicode Sprachkennung */
		uint32	model_desc_unicode_count;							/* Anzahl der Unicode-Zeichen */
		uint16	model_desc_unicode_name[VARIABLE_ARRAY_SIZE];
		int16		model_desc_scriptcode_code;
		uint8		model_desc_scriptcode_count;						/* Anzahl der ASCII-Zeichen */
		uint8		model_desc_scriptcode_name[VARIABLE_ARRAY_SIZE];
	} profileDescription[VARIABLE_ARRAY_SIZE];
} CPROF_PROFILE_SEQUENCE_DESC;

typedef struct
{
	uint32	type;															/* 'scrn' */
	uint32	reserved;													/* reserviert (0) */
	uint32	screening_flag;											/* bit 0 : use printer default screens, bit 1 : inch/cm */
	uint32	no_channels;
	struct
	{
		fixed		frequency;												/* Frequenz */
		fixed		angle;													/* Winkel */
		uint32	spot_shape;												/* Form */
	} channel_screening[VARIABLE_ARRAY_SIZE];
} CPROF_SCREENING;

typedef struct																/* Feld mit vorzeichenbehafteten 16.16-Zahlen */
{
	uint32	type;															/* 'sf32' */
	uint32	reserved;													/* reserviert (0) */
	fixed		values[VARIABLE_ARRAY_SIZE];
} CPROF_S15FIXED16ARRAY;

typedef struct																/* Kennung */
{
	uint32	type;															/* 'sig ' */
	uint32	reserved;													/* reserviert (0) */
	uint32	signature;													/* Kennung */
} CPROF_SIGNATURE;

typedef struct																/* Text (simpel-ASCII) */
{
	uint32	type;															/* 'text' */
	uint32	reserved;													/* reserviert (0) */
	uint8		text[VARIABLE_ARRAY_SIZE];
} CPROF_TEXT;
#define	sizeof_CPROF_TEXT	offsetof( CPROF_TEXT, text )		/* Größe ohne Textfeld */

typedef struct																/* Feld mit vorzeichenlosen 16.16-Zahlen */
{
	uint32	type;															/* 'uf32' */
	uint32	reserved;													/* reserviert (0) */
	uint32	values[VARIABLE_ARRAY_SIZE];
} CPROF_U16FIXED16ARRAY;

typedef struct																/* Feld mit vorzeichenlosen 8-Bit-Zahlen */
{
	uint32	type;															/* 'ui08' */
	uint32	reserved;													/* reserviert (0) */
	uint8		values[VARIABLE_ARRAY_SIZE];
} CPROF_UINT8ARRAY;

typedef struct																/* Feld mit vorzeichenlosen 16-Bit-Zahlen */
{
	uint32	type;															/* 'ui16' */
	uint32	reserved;													/* reserviert (0) */
	uint16	values[VARIABLE_ARRAY_SIZE];
} CPROF_UINT16ARRAY;

typedef struct																/* Feld mit vorzeichenlosen 32-Bit-Zahlen */
{
	uint32	type;															/* 'ui32' */
	uint32	reserved;													/* reserviert (0) */
	uint32	values[VARIABLE_ARRAY_SIZE];
} CPROF_UINT32ARRAY;

typedef struct																/* Feld mit vorzeichenlosen 64-Bit-Zahlen */
{
	uint32	type;															/* 'ui64' */
	uint32	reserved;													/* reserviert (0) */
	uint64	values[VARIABLE_ARRAY_SIZE];
} CPROF_UINT64ARRAY;

typedef struct																/* Betrachtungs-Umstände */
{
	uint32	type;															/* 'view' */
	uint32	reserved;													/* reserviert (0) */
	CPROF_FIXED_XYZ	illuminant;										/* absoluter XYZ-Wert der Beleuchtung  in cd/m^2 */
	CPROF_FIXED_XYZ	surround;										/* absoluter XYZ-Wert der Umgebung in cd/m^2 */
	uint32	std_illuminant;											/* Kennung für Standard-Beleuchtung */
} CPROF_VIEWING_CONDITIONS;

#pragma PRAGMA_RESET_ALIGN												/* Einstellung zurücksetzen */

#endif
