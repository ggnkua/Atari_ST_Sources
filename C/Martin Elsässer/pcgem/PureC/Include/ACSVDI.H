/******************************************************************************/
/*																										*/
/*          Eine handoptimierte Bibliothek fÅr Pure-C und GNU-C               */
/*																										*/
/* Die (N)VDI-Funktionen - Headerdatei														*/
/*																										*/
/*	(c) 1999 by Martin ElsÑsser																*/
/******************************************************************************/

#ifndef __ACSVDI__
#define __ACSVDI__

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

#define SOLID				LT_SOLID
#define LONGDASH			LT_LONGDASH
#define DOT					LT_DOTTED
#define DASHDOT			LT_DASHDOT
#define DASH				LT_DASHED
#define DASH2DOT			LT_DASHDOTDOT
#define USERLINE			LT_USERDEF

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
#define MT_DOT			1
#define MT_PLUS		2
#define MT_ASTERISK	3
#define MT_SQUARE		4
#define MT_DCROSS		5
#define MT_DIAMOND	6

/******************************************************************************/

/* Texteffekte (fÅr vst_effects) */
#define TF_NORMAL			0x00
#define TF_THICKENED		0x01
#define TF_LIGHTENED		0x02
#define TF_SLANTED		0x04
#define TF_UNDERLINED	0x08
#define TF_OUTLINED		0x10
#define TF_SHADOWED		0x20

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

/* FÅlltypen (fÅr vsf_interior) */
#define FIS_HOLLOW	0
#define FIS_SOLID		1
#define FIS_PATTERN	2
#define FIS_HATCH		3
#define FIS_USER		4

/******************************************************************************/

#define IP_HOLLOW       0
#define IP_1PATT        1
#define IP_2PATT        2
#define IP_3PATT        3
#define IP_4PATT        4
#define IP_5PATT        5
#define IP_6PATT        6
#define IP_SOLID        7

/******************************************************************************/

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
#define NOT_D           11
#define S_OR_NOTD       12
#define NOTS_OR_D       13
#define NOT_SANDD       14
#define ALL_BLACK       15

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
/*																										*/
/* Die diversen VDI-Strukturen																*/
/*																										*/
/******************************************************************************/

/* Datentyp fÅr Vektorfonts ab NVDI 4.x */
typedef INT32 fix31;

/******************************************************************************/

typedef struct
{
	void *fd_addr;
	INT16 fd_w;
	INT16 fd_h;
	INT16 fd_wdwidth;
	INT16 fd_stand;
	INT16 fd_nplanes;
	INT16 fd_r1;
	INT16 fd_r2;
	INT16 fd_r3;
} MFDB;

/******************************************************************************/

/* Struktur des Headers eines GEM-Metafiles */
typedef struct
{
	INT16 mf_header;		/* -1, Metafile-Kennung                             */
	INT16 mf_length;		/* HeaderlÑnge in Worten (normalerweise 24)         */
	INT16 mf_version;		/* Versionsnummer des Formats, hier 101 fÅr 1.01    */
	INT16 mf_ndcrcfl;		/* NDC/RC-Flag, normalerweise 2 (Rasterkoordinaten) */
	INT16 mf_extents[4];	/* optional - maximale Ausmaûe der Grafik           */
	INT16 mf_pagesz[2];	/* optional - Seitengrîûe in 1/10 mm                */
	INT16 mf_coords[4];	/* optional - Koordinatensystem                     */
	INT16 mf_imgflag;		/* Flag fÅr durch v_bit_image() eingebundene Bilder */
	INT16 mf_resvd[9];
} METAHDR;

/******************************************************************************/

/* Font-Info-Struktur (fÅr vqt_xfntinfo) */
typedef struct
{
	INT32 size;					/* LÑnge der Struktur, muû vor vqt_xfntinfo() gesetzt werden */
	INT16 format;				/* Fontformat, z.B. 4 f&uuml;r TrueType                      */
	INT16 id;					/* Font-ID, z.B. 6059                                        */
	INT16 index;				/* Index                                                     */
	char	font_name[50];		/* vollstÑndiger Fontname, z.B. "Century 725 Italic BT"      */
	char	family_name[50];	/* Name der Fontfamilie, z.B. "Century725 BT"                */
	char	style_name[50];	/* Name des Fontstils, z.B. "Italic"                         */
	char	file_name1[200];	/* Name der 1. Fontdatei, z.B. "C:\FONTS\TT1059M_.TTF"       */
	char	file_name2[200];	/* Name der optionalen 2. Fontdatei                          */
	char	file_name3[200];	/* Name der optionalen 3. Fontdatei                          */
	INT16 pt_cnt;				/* Anzahl der Punkthîhen fÅr vst_point(), z.B. 10            */
	INT16 pt_sizes[64];		/* verfÅgbare Punkthîhen, z.B.                               */
									/* {8, 9, 10, 11, 12, 14, 18, 24, 36, 48}                    */
} XFNT_INFO;

/******************************************************************************/
/*																										*/
/* Prototyp der Assembler-Routine															*/
/*	Diese macht den VDI-Aufruf und setzt den dazu nîtigen VDI-Parameterblock	*/
/* auf dem Stack zusammen - das ist etwas multithreading freundlicher... ;-)	*/
/*																										*/
/******************************************************************************/

void CDECL vdi( INT16 *contrl, INT16 *intin, INT16 *ptsin, INT16 *intout, INT16 *ptsout );

/******************************************************************************/
/*																										*/
/* Die fÅr ACS optimierten Funktionen														*/
/*																										*/
/******************************************************************************/

#ifndef __COMPATIBLE__

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*																										*/
/* Die Kontroll-Funktionen																		*/
/*																										*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

INT16 vst_load_fonts( const INT16 handle );
void vst_unload_fonts( const INT16 handle );
void vs_clip( const INT16 handle, const INT16 clip_flag, const Axywh *rect );

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*																										*/
/* Die Ausgabe-Funktionen																		*/
/*																										*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

void v_pline( const INT16 handle, const INT16 count, INT16 *pxyarray );
void v_pmarker( const INT16 handle, const INT16 count, INT16 *pxyarray );
void v_gtext( const INT16 handle, const INT16 x, const INT16 y, const char *string );
void v_fillarea( const INT16 handle, const INT16 count, INT16 *pxyarray );
void v_cellarray( const INT16 handle, INT16 *pxyarray, const INT16 row_length,
			const INT16 el_used, const INT16 num_rows, const INT16 wrt_mode,
			const INT16 *colarray );
void v_contourfill( const INT16 handle, const INT16 x, const INT16 y, const INT16 index );
void vr_recfl( const INT16 handle, const Axywh *rect );
void v_bar( const INT16 handle, INT16 *pxyarray );
void v_arc( const INT16 handle, const INT16 x, const INT16 y,
			const INT16 radius, const INT16 beg_ang, const INT16 end_ang );
void v_pieslice( const INT16 handle, const INT16 x, const INT16 y,
			const INT16 radius, const INT16 beg_ang, const INT16 end_ang );
void v_circle( const INT16 handle, const INT16 x, const INT16 y, const INT16 radius );
void v_ellipse( const INT16 handle, const INT16 x, const INT16 y,
			const INT16 xradius, const INT16 yradius );
void v_ellarc( const INT16 handle, const INT16 x, const INT16 y,
		const INT16 xradius, const INT16 yradius, const INT16 beg_ang, const INT16 end_ang );
void v_ellpie( const INT16 handle, const INT16 x, const INT16 y,
			const INT16 xradius, const INT16 yradius, const INT16 beg_ang, const INT16 end_ang );
void v_rbox( const INT16 handle, const Axywh *rectangle );
void v_rfbox( const INT16 handle, const Axywh *rectangle );
void v_justified( const INT16 handle, const INT16 x, const INT16 y, char *string,
			const INT16 length, const INT16 word_space, const INT16 char_space );

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*																										*/
/* Die Attribut-Funktionen																		*/
/*																										*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

void vs_color( const INT16 handle, const INT16 index, const RGB *rgb );

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*																										*/
/* Die Raster-Funktionen																		*/
/*																										*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

void vro_cpyfm( const INT16 handle, const INT16 wr_mode, const Axywh *koor_src,
			const Axywh *koor_dest, const MFDB *source, MFDB *dest );
void vrt_cpyfm( const INT16 handle, const INT16 wr_mode, const Axywh *koor_src,
			const Axywh *koor_dest, const MFDB *source, MFDB *dest, const INT16 color[2] );

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*																										*/
/* Die Eingabe-Funktionen																		*/
/*																										*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

INT16 vsin_mode( const INT16 handle, const INT16 dev_type, const INT16 mode );
void vrq_locator( const INT16 handle, const INT16 x_in, const INT16 y_in,
			INT16 *x_out, INT16 *y_out, INT16 *term );
INT16 vsm_locator( const INT16 handle, const INT16 x_in, const INT16 y_in,
			INT16 *x_out, INT16 *y_out, INT16 *term );
void vrq_valuator( const INT16 handle, const INT16 value_in, INT16 *value_out, INT16 *term );
void vsm_valuator( const INT16 handle, const INT16 value_in,
			INT16 *value_out, INT16 *term, INT16 *status );
void vrq_choice( const INT16 handle, const INT16 choice_in, INT16 *choice_out );
INT16 vsm_choice( const INT16 handle, INT16 *choice );
void vrq_string( const INT16 handle, const INT16 max_length, const INT16 echo_mode,
			const INT16 *echo_xy, char *string );
INT16 vsm_string( const INT16 handle, const INT16 max_length, const INT16 echo_mode,
			const INT16 *echo_xy, char *string );
void vex_timv( const INT16 handle, const INT16 (*tim_addr)(void),
			INT16 (**otim_addr)(void), INT16 *tim_conv );
void v_show_c( const INT16 handle, const INT16 reset );
void v_hide_c( const INT16 handle );
void vq_mouse( const INT16 handle, INT16 *pstatus, INT16 *x, INT16 *y );
void vex_butv( const INT16 handle, const INT16 (*pusrcode)(void), INT16 (**psavcode)(void) );
void vex_motv( const INT16 handle, const INT16 (*pusrcode)(void), INT16 (**psavcode)(void) );
void vex_curv( const INT16 handle, const INT16 (*pusrcode)(void), INT16 (**psavcode)(void) );
void vq_key_s( const INT16 handle, INT16 *pstatus );

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*																										*/
/* Die Auskunft-Funktionen																		*/
/*																										*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

INT16 vq_color( const INT16 handle, const INT16 color, const INT16 set_flag, RGB *rgb );
void vq_cellarray( const INT16 handle, const Axywh *xywh, const INT16 row_length,
			const INT16 num_rows, INT16 *el_used, INT16 *rows_used, INT16 *status,
			INT16 *colarray );

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*																										*/
/* Die Escape-Funktionen																		*/
/*																										*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

void v_output_window( const INT16 handle, const Axywh *xywh );
void v_bit_image( const INT16 handle, const char *filename, const INT16 aspect,
			const INT16 x_scale, const INT16 y_scale, const INT16 h_align,
			const INT16 v_align, const Axywh *xywh );

#endif

/******************************************************************************/
/*																										*/
/* Eigentliche VDI-Funktionen mit "Original-Parametern"								*/
/*																										*/
/******************************************************************************/

typedef struct
{
	INT16 contrl[15];
	INT16 intin[132];
	INT16 intout[140];
	INT16 ptsin[145];
	INT16 ptsout[145];
} VDIPARBLK;

typedef struct
{
	INT16 *contrl;
	INT16 *intin;
	INT16 *ptsin;
	INT16 *intout;
	INT16 *ptsout;
} VDIPB;

extern VDIPARBLK _VDIParBlk;

/******************************************************************************/
	
#ifdef __COMPATIBLE__
	
	/***************************************************************************/
	
	/* Die "alte" Fassung des VDI-Aufrufes */
	void vdi_( VDIPB *vdipb );
	
	/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	/*																									*/
	/* Die Kontroll-Funktionen																	*/
	/*																									*/
	/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	
	INT16 vst_load_fonts( const INT16 handle, const INT16 select );
	void vst_unload_fonts( const INT16 handle, const INT16 select );
	void vs_clip( const INT16 handle, const INT16 clip_flag, const INT16 *pxyarray );
	
	/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	/*																									*/
	/* Die Ausgabe-Funktionen																	*/
	/*																									*/
	/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	
	void vr_recfl( const INT16 handle, const INT16 *pxyarray );
	void v_rfbox( const INT16 handle, const INT16 *rectangle );
	void v_rbox( const INT16 handle, const INT16 *pxyarray );
	
	/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	/*																									*/
	/* Die Attribut-Funktionen																	*/
	/*																									*/
	/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	
	void vs_color( const INT16 handle, const INT16 index, const INT16 *rgb );
	
	/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	/*																									*/
	/* Die Raster-Funktionen																	*/
	/*																									*/
	/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	
	void vro_cpyfm( const INT16 handle, const INT16 wr_mode, const INT16 *pxyarray,
					const MFDB *source, MFDB *dest );
	void vrt_cpyfm( const INT16 handle, const INT16 wr_mode, const INT16 *pxyarray,
					const MFDB *source, MFDB *dest, const INT16 color[2] );
	
	/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	/*																									*/
	/* Die Auskunft-Funktionen																	*/
	/*																									*/
	/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	
	INT16 vq_color( const INT16 handle, const INT16 color, const INT16 set_flag, INT16 *rgb );
	void vq_cellarray( const INT16 handle, const INT16 *pxyarray, const INT16 row_length,
					const INT16 num_rows, INT16 *el_used, INT16 *rows_used, INT16 *status,
					INT16 *colarray );
	
	/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	/*																									*/
	/* Die Escape-Funktionen																	*/
	/*																									*/
	/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	
	void v_output_window( const INT16 handle, const INT16 *pxyarray );
	void v_bit_image( const INT16 handle, const char *filename, const INT16 aspect,
					const INT16 x_scale, const INT16 y_scale, const INT16 h_align,
					const INT16 v_align, const INT16 *pxyarray );
#else
	
	/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	/*																									*/
	/* Die Kontroll-Funktionen																	*/
	/*																									*/
	/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	
	INT16 vst_load_fonts_( const INT16 handle, const INT16 select );
	void vst_unload_fonts_( const INT16 handle, const INT16 select );
	void vs_clip_( const INT16 handle, const INT16 clip_flag, const INT16 *pxyarray );
	
	/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	/*																									*/
	/* Die Ausgabe-Funktionen																	*/
	/*																									*/
	/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	
	void vr_recfl_( const INT16 handle, const INT16 *pxyarray );
	void v_rfbox_( const INT16 handle, const INT16 *rectangle );
	void v_rbox_( const INT16 handle, const INT16 *pxyarray );
	
	/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	/*																									*/
	/* Die Attribut-Funktionen																	*/
	/*																									*/
	/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	
	void vs_color_( const INT16 handle, const INT16 index, const INT16 *rgb );
	
	/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	/*																									*/
	/* Die Raster-Funktionen																	*/
	/*																									*/
	/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	
	void vro_cpyfm_( const INT16 handle, const INT16 wr_mode, const INT16 *pxyarray,
					const MFDB *source, MFDB *dest );
	void vrt_cpyfm_( const INT16 handle, const INT16 wr_mode, const INT16 *pxyarray,
					const MFDB *source, MFDB *dest, const INT16 color[2] );
	
	/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	/*																									*/
	/* Die Auskunft-Funktionen																	*/
	/*																									*/
	/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	
	INT16 vq_color_( const INT16 handle, const INT16 color, const INT16 set_flag, INT16 *rgb );
	void vq_cellarray_( const INT16 handle, const INT16 *pxyarray, const INT16 row_length,
					const INT16 num_rows, INT16 *el_used, INT16 *rows_used, INT16 *status,
					INT16 *colarray );
	
	/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	/*																									*/
	/* Die Escape-Funktionen																	*/
	/*																									*/
	/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
	
	void v_output_window_( const INT16 handle, const INT16 *pxyarray );
	void v_bit_image_( const INT16 handle, const char *filename, const INT16 aspect,
					const INT16 x_scale, const INT16 y_scale, const INT16 h_align,
					const INT16 v_align, const INT16 *pxyarray );
#endif

/******************************************************************************/
/*																										*/
/* Gemeinsame Funktionen des "Originals" und der ACS-Optimierungen				*/
/*																										*/
/******************************************************************************/

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*																										*/
/* Die Kontroll-Funktionen																		*/
/*																										*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

void v_opnwk( INT16 *work_in, INT16 *handle, INT16 *work_out, INT16 max_x, INT16 max_y );
void v_clswk( const INT16 handle );
void v_opnvwk( INT16 *work_in, INT16 *handle, INT16 *work_out );
void v_clsvwk( const INT16 handle );
void v_clrwk( const INT16 handle );
INT16 v_updwk( const INT16 handle );
void v_opnbm( INT16 *work_in, MFDB *bitmap, INT16 *handle, INT16 *work_out );
void v_clsbm( const INT16 handle );

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*																										*/
/* Die Ausgabe-Funktionen																		*/
/*																										*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

void v_pline( const INT16 handle, const INT16 count, INT16 *pxyarray );
void v_pmarker( const INT16 handle, const INT16 count, INT16 *pxyarray );
void v_gtext( const INT16 handle, const INT16 x, const INT16 y, const char *string );
void v_fillarea( const INT16 handle, const INT16 count, INT16 *pxyarray );
void v_cellarray( const INT16 handle, INT16 *pxyarray, const INT16 row_length,
			const INT16 el_used, const INT16 num_rows, const INT16 wrt_mode,
			const INT16 *colarray );
void v_contourfill( const INT16 handle, const INT16 x, const INT16 y, const INT16 index );
void v_bar( const INT16 handle, INT16 *pxyarray );
void v_arc( const INT16 handle, const INT16 x, const INT16 y,
			const INT16 radius, const INT16 beg_ang, const INT16 end_ang );
void v_pieslice( const INT16 handle, const INT16 x, const INT16 y,
			const INT16 radius, const INT16 beg_ang, const INT16 end_ang );
void v_circle( const INT16 handle, const INT16 x, const INT16 y, const INT16 radius );
void v_ellipse( const INT16 handle, const INT16 x, const INT16 y,
			const INT16 xradius, const INT16 yradius );
void v_ellarc( const INT16 handle, const INT16 x, const INT16 y,
		const INT16 xradius, const INT16 yradius, const INT16 beg_ang, const INT16 end_ang );
void v_ellpie( const INT16 handle, const INT16 x, const INT16 y,
			const INT16 xradius, const INT16 yradius, const INT16 beg_ang, const INT16 end_ang );
void v_justified( const INT16 handle, const INT16 x, const INT16 y, char *string,
			const INT16 length, const INT16 word_space, const INT16 char_space );

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*																										*/
/* Die Attribut-Funktionen																		*/
/*																										*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

INT16 vq_gdos( void );
INT16 vswr_mode( const INT16 handle, const INT16 mode );
INT16 vsl_type( const INT16 handle, const INT16 style );
void vsl_udsty( const INT16 handle, const INT16 pattern );
INT16 vsl_width( const INT16 handle, const INT16 width );
INT16 vsl_color( const INT16 handle, const INT16 color );
void vsl_ends( const INT16 handle, const INT16 beg_style, const INT16 end_style );
INT16 vsm_type( const INT16 handle, const INT16 symbol );
INT16 vsm_height( const INT16 handle, const INT16 height );
INT16 vsm_color( const INT16 handle, const INT16 color );
void vst_height( const INT16 handle, const INT16 height,
			INT16 *char_width, INT16 *char_height, INT16 *cell_width, INT16 *cell_height );
INT16 vst_point( const INT16 handle, const INT16 point, 
			INT16 *char_width, INT16 *char_height, INT16 *cell_width, INT16 *cell_height );
INT16 vst_rotation( const INT16 handle, const INT16 angle );
INT16 vst_font( const INT16 handle, const INT16 font );
INT16 vst_color( const INT16 handle, const INT16 color );
INT16 vst_effects( const INT16 handle, const INT16 effect );
void vst_alignment( const INT16 handle, const INT16 hor_in, const INT16 ver_in,
			INT16 *hor_out, INT16 *ver_out );
INT16 vsf_interior( const INT16 handle, const INT16 style );
INT16 vsf_style( const INT16 handle, const INT16 style );
INT16 vsf_color( const INT16 handle, const INT16 color );
INT16 vsf_perimeter( const INT16 handle, const INT16 per_vis );
void vsf_udpat( const INT16 handle, const INT16 *pattern, const INT16 nplanes );
void vsf_updat( const INT16 handle, const INT16 *pattern, const INT16 nplanes );

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*																										*/
/* Die Raster-Funktionen																		*/
/*																										*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

void vr_trnfm( const INT16 handle, const MFDB *source, MFDB *dest );
void v_get_pixel( const INT16 handle, const INT16 x, const INT16 y,
			INT16 *pix_value, INT16 *col_index );

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*																										*/
/* Die Eingabe-Funktionen																		*/
/*																										*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

INT16 vsin_mode( const INT16 handle, const INT16 dev_type, const INT16 mode );
void vrq_locator( const INT16 handle, const INT16 x_in, const INT16 y_in,
			INT16 *x_out, INT16 *y_out, INT16 *term );
INT16 vsm_locator( const INT16 handle, const INT16 x_in, const INT16 y_in,
			INT16 *x_out, INT16 *y_out, INT16 *term );
void vrq_valuator( const INT16 handle, const INT16 value_in, INT16 *value_out, INT16 *term );
void vsm_valuator( const INT16 handle, const INT16 value_in,
			INT16 *value_out, INT16 *term, INT16 *status );
void vrq_choice( const INT16 handle, const INT16 choice_in, INT16 *choice_out );
INT16 vsm_choice( const INT16 handle, INT16 *choice );
void vrq_string( const INT16 handle, const INT16 max_length, const INT16 echo_mode,
			const INT16 *echo_xy, char *string );
INT16 vsm_string( const INT16 handle, const INT16 max_length, const INT16 echo_mode,
			const INT16 *echo_xy, char *string );
void vex_timv( const INT16 handle, const INT16 (*tim_addr)(void),
			INT16 (**otim_addr)(void), INT16 *tim_conv );
void v_show_c( const INT16 handle, const INT16 reset );
void v_hide_c( const INT16 handle );
void vq_mouse( const INT16 handle, INT16 *pstatus, INT16 *x, INT16 *y );
void vex_butv( const INT16 handle, const INT16 (*pusrcode)(void), INT16 (**psavcode)(void) );
void vex_motv( const INT16 handle, const INT16 (*pusrcode)(void), INT16 (**psavcode)(void) );
void vex_curv( const INT16 handle, const INT16 (*pusrcode)(void), INT16 (**psavcode)(void) );
void vq_key_s( const INT16 handle, INT16 *pstatus );

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*																										*/
/* Die Auskunft-Funktionen																		*/
/*																										*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

void vq_extnd( const INT16 handle, const INT16 owflag, INT16 *workout );
void vql_attributes( const INT16 handle, INT16 *attrib );
void vqm_attributes( const INT16 handle, INT16 *attrib );
void vqf_attributes( const INT16 handle, INT16 *attrib );
void vqt_attributes( const INT16 handle, INT16 *attrib );
void vqt_extent( const INT16 handle, const char *string, INT16 *extent );
INT16 vqt_width( const INT16 handle, const INT16 character, INT16 *cell_width,
			INT16 *left_delta, INT16 *right_delta );
INT16 vqt_name( const INT16 handle, const INT16 element_num, char *name );
void vqin_mode( const INT16 handle, const INT16 dev_type, INT16 *input_mode );
void vqt_fontinfo( const INT16 handle, INT16 *minADE, INT16 *maxADE, INT16 *distances,
			INT16 *maxwidth, INT16 *effects );
void vq_scrninfo( const INT16 handle, INT16 *work_out );

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*																										*/
/* Die Escape-Funktionen																		*/
/*																										*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

void vq_chcells( const INT16 handle, INT16 *rows, INT16 *cols );
void v_exit_cur( const INT16 handle );
void v_enter_cur( const INT16 handle );
void v_curup( const INT16 handle );
void v_curdown( const INT16 handle );
void v_curright( const INT16 handle );
void v_curleft( const INT16 handle );
void v_curhome( const INT16 handle );
void v_eeos( const INT16 handle );
void v_eeol( const INT16 handle );
void v_curaddress( const INT16 handle, const INT16 row, const INT16 col );
void v_curtext( const INT16 handle, const char *string );
void v_rvon( const INT16 handle );
void v_rvoff( const INT16 handle );
void vq_curaddress( const INT16 handle, INT16 *row, INT16 *col );
INT16 vq_tabstatus( const INT16 handle );
void v_hardcopy( const INT16 handle );
void v_dspcur( const INT16 handle, const INT16 x, const INT16 y );
void v_rmcur( const INT16 handle );
void v_form_adv( const INT16 handle );
void v_clear_disp_list( const INT16 handle );
void vq_scan( const INT16 handle, INT16 *g_slice, INT16 *g_page,
			INT16 *a_slice, INT16 *a_page, INT16 *div_fac );
void v_alpha_text( const INT16 handle, const char *string );
INT16 vs_palette( const INT16 handle, const INT16 palette );
void v_sound( const INT16 handle, const INT16 frequency, const INT16 duration );
INT16 vs_mute( const INT16 handle, const INT16 action );
void vt_resolution( const INT16 handle, const INT16 xres, const INT16 yres,
			INT16 *xset, INT16 *yset );
void vt_axis( const INT16 handle, const INT16 xres, const INT16 yres,
			INT16 *xset, INT16 *yset );
void vt_origin( const INT16 handle, const INT16 xorigin, const INT16 yorigin );
void vq_tdimensions( const INT16 handle, INT16 *xdim, INT16 *ydim );
void vt_alignment( const INT16 handle, const INT16 dx, const INT16 dy );
void vsp_film( const INT16 handle, const INT16 index, const INT16 lightness );
INT16 vqp_filmname( const INT16 handle, const INT16 index, char *name );
void vsc_exposure( const INT16 handle, const INT16 status );
void v_meta_extents( const INT16 handle, const INT16 min_x, const INT16 min_y,
			const INT16 max_x, const INT16 max_y );
void v_write_meta( const INT16 handle, const INT16 num_intin, const INT16 *a_intin,
			const INT16 num_ptsin, const INT16 *a_ptsin );
void vm_pagesize( const INT16 handle, const INT16 pgwidth, const INT16 pgheight );
void vm_coords( const INT16 handle, const INT16 llx, const INT16 lly,
			const INT16 urx, const INT16 ury );
void vm_filename( const INT16 handle, const char *filename );
void v_offset( const INT16 handle, const INT16 offset );
void v_fontinit( const INT16 handle, const void *font_header );
void v_escape2000( const INT16 handle, const INT16 times );

/******************************************************************************/
/*																										*/
/* Utility-Funktionen fÅr NVDI 4.x															*/
/*																										*/
/******************************************************************************/

INT16 fix31ToPixel( fix31 a );

/******************************************************************************/

#endif
