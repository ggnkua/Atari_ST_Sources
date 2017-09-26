/*
	Tabulatorweite: 3
	Kommentare ab: Spalte 60											*Spalte 60*
*/

#include	<Types2B.h>
#include	<VDI.H>

#ifndef	__VDICOL__
#define	__VDICOL__

#include	<PRSETTNG.H>													/* PRN_SETTINGS-Struktur */

#ifndef	__COLORMAP__

#define	REFS_ARE_PTRS	1

typedef struct
{
	int16	red;																/* Rot-IntensitÑt in Promille (0-1000) */
	int16	green;															/* GrÅn-IntensitÑt in Promille (0-1000) */
	int16	blue;																/* Blau-IntensitÑt in Promille (0-1000) */
} RGB1000;


/*----------------------------------------------------------------------------------------*/
/* Konstanten fÅr Pixelformate																				*/
/*----------------------------------------------------------------------------------------*/
#define	PX_1COMP		0x01000000L										/* Pixel besteht aus einer benutzten Komponente: Farbindex */
#define	PX_3COMP		0x03000000L										/* Pixel besteht aus drei benutzten Komponenten, z.B. RGB */
#define	PX_4COMP		0x04000000L										/* Pixel besteht aus vier benutzten Komponenten, z.B. CMYK */

#define	PX_REVERSED	0x00800000L										/* Pixel wird in umgekehrter Bytreihenfolge ausgegeben */
#define	PX_xFIRST	0x00400000L										/* unbenutzte Bits liegen vor den benutzen (im Motorola-Format betrachtet) */
#define	PX_kFIRST	0x00200000L										/* K liegt vor CMY (im Motorola-Format betrachtet) */
#define	PX_aFIRST	0x00100000L										/* Alphakanal liegen vor den Farbbits (im Motorola-Format betrachtet) */

#define	PX_PACKED	0x00020000L										/* Bits sind aufeinanderfolgend abgelegt */
#define	PX_PLANES	0x00010000L										/* Bits sind auf mehrere Ebenen verteilt (Reihenfolge: 0, 1, ..., n) */
#define	PX_IPLANES	0x00000000L										/* Bits sind auf mehrere Worte verteilt (Reihenfolge: 0, 1, ..., n) */

#define	PX_USES1		0x00000100L										/* 1 Bit des Pixels wird benutzt */
#define	PX_USES2		0x00000200L										/* 2 Bit des Pixels werden benutzt */
#define	PX_USES3		0x00000300L										/* 3 Bit des Pixels werden benutzt */
#define	PX_USES4		0x00000400L										/* 4 Bit des Pixels werden benutzt */
#define	PX_USES8		0x00000800L										/* 8 Bit des Pixels werden benutzt */
#define	PX_USES15	0x00000f00L										/* 15 Bit des Pixels werden benutzt */
#define	PX_USES16	0x00001000L										/* 16 Bit des Pixels werden benutzt */
#define	PX_USES24	0x00001800L										/* 24 Bit des Pixels werden benutzt */
#define	PX_USES32	0x00002000L										/* 32 Bit des Pixels werden benutzt */
#define	PX_USES48	0x00003000L										/* 48 Bit des Pixels werden benutzt */

#define	PX_1BIT		0x00000001L										/* Pixel besteht aus 1 Bit */
#define	PX_2BIT		0x00000002L										/* Pixel besteht aus 2 Bit */
#define	PX_3BIT		0x00000003L										/* Pixel besteht aus 3 Bit */
#define	PX_4BIT		0x00000004L										/* Pixel besteht aus 4 Bit */
#define	PX_8BIT		0x00000008L										/* Pixel besteht aus 8 Bit */
#define	PX_16BIT		0x00000010L										/* Pixel besteht aus 16 Bit */
#define	PX_24BIT		0x00000018L										/* Pixel besteht aus 24 Bit */
#define	PX_32BIT		0x00000020L										/* Pixel besteht aus 32 Bit */
#define	PX_48BIT		0x00000030L										/* Pixel besteht aus 48 Bit */

#define	PX_CMPNTS	0x0f000000L										/* Maske fÅr Anzahl der Pixelkomponenten */
#define	PX_FLAGS		0x00f00000L										/* Maske fÅr diverse Flags */
#define	PX_PACKING	0x00030000L										/* Maske fÅr Pixelformat */
#define	PX_USED		0x00003f00L										/* Maske fÅr Anzahl der benutzten Bits */
#define	PX_BITS		0x0000003fL										/* Maske fÅr Anzahl der Bits pro Pixel */

/*----------------------------------------------------------------------------------------*/
/* Pixelformate fÅr ATARI-Grafik																				*/
/*----------------------------------------------------------------------------------------*/
#define	PX_ATARI1	( PX_PACKED + PX_1COMP + PX_USES1 + PX_1BIT )
#define	PX_ATARI2	( PX_IPLANES + PX_1COMP + PX_USES2 + PX_2BIT )
#define	PX_ATARI4	( PX_IPLANES + PX_1COMP + PX_USES4 + PX_4BIT )
#define	PX_ATARI8	( PX_IPLANES + PX_1COMP + PX_USES8 + PX_8BIT )
#define	PX_FALCON15	( PX_PACKED + PX_3COMP + PX_USES16 + PX_16BIT )

/*----------------------------------------------------------------------------------------*/
/* Pixelformate fÅr Macintosh																					*/
/*----------------------------------------------------------------------------------------*/
#define	PX_MAC1		( PX_PACKED + PX_1COMP + PX_USES1 + PX_1BIT )
#define	PX_MAC4		( PX_PACKED + PX_1COMP + PX_USES4 + PX_4BIT )
#define	PX_MAC8		( PX_PACKED + PX_1COMP + PX_USES8 + PX_8BIT )
#define	PX_MAC15		( PX_xFIRST + PX_PACKED + PX_3COMP + PX_USES15 + PX_16BIT )
#define	PX_MAC32		( PX_xFIRST + PX_PACKED + PX_3COMP + PX_USES24 + PX_32BIT )

/*----------------------------------------------------------------------------------------*/
/* Pixelformate fÅr Grafikkarten																				*/
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
/* Pixelformate fÅr Drucker																					*/
/*----------------------------------------------------------------------------------------*/
#define	PX_PRN1		( PX_PACKED + PX_1COMP + PX_USES1 + PX_1BIT )
#define	PX_PRN8		( PX_PACKED + PX_1COMP + PX_USES8 + PX_8BIT )
#define	PX_PRN32		( PX_xFIRST + PX_PACKED + PX_3COMP + PX_USES24 + PX_32BIT )

/*----------------------------------------------------------------------------------------*/
/* bevorzugte (schnelle) Pixelformate fÅr Bitmaps 														*/
/*----------------------------------------------------------------------------------------*/

#define	PX_PREF1		( PX_PACKED + PX_1COMP + PX_USES1 + PX_1BIT )
#define	PX_PREF2		( PX_PACKED + PX_1COMP + PX_USES2 + PX_2BIT )
#define	PX_PREF4		( PX_PACKED + PX_1COMP + PX_USES4 + PX_4BIT )
#define	PX_PREF8		( PX_PACKED + PX_1COMP + PX_USES8 + PX_8BIT )
#define	PX_PREF15	( PX_xFIRST + PX_PACKED + PX_3COMP + PX_USES15 + PX_16BIT )
#define	PX_PREF32	( PX_xFIRST + PX_PACKED + PX_3COMP + PX_USES24 + PX_32BIT )

/*----------------------------------------------------------------------------------------*/
/* Farbtabellen																									*/
/*----------------------------------------------------------------------------------------*/

enum
{
	CSPACE_RGB		=	0x0001,
	CSPACE_ARGB		=	0x0002,
	CSPACE_CMYK		=	0x0004
};

enum
{
	CSPACE_1COMPONENT		=	0x0001,
	CSPACE_2COMPONENTS	=	0x0002,
	CSPACE_3COMPONENTS	= 	0x0003,
	CSPACE_4COMPONENTS	=	0x0004
};

typedef struct
{
	uint16	reserved;
	uint16	red;
	uint16	green;
	uint16	blue;
} COLOR_RGB;

typedef struct
{
	uint16	cyan;
	uint16	magenta;
	uint16	yellow;
	uint16	black;
} COLOR_CMYK;

typedef union
{
	COLOR_RGB	rgb;
	COLOR_CMYK	cmyk;
} COLOR_ENTRY;

#define	COLOR_TAB_MAGIC	'ctab'

typedef struct																/* Farbtabelle */
{
	int32	magic;															/* 'ctab' */
	int32	length;
	int32	format;															/* Format (0) */
	int32	reserved;
	
	int32	map_id;															/* Kennung der Farbtabelle */
	int32	color_space;													/* Farbraum */
	int32	flags;															/* interne Flags */
	int32	no_colors;														/* Anzahl der FarbeintrÑge */

	int32	reserved1;
	int32	reserved2;
	int32	reserved3;
	int32	reserved4;

	COLOR_ENTRY	colors[];
} COLOR_TAB;

/* vordefinierte Tabelle mit 256 EintrÑgen */
typedef struct																/* Farbtabelle */
{
	int32	magic;															/* 'ctab' */
	int32	length;
	int32	format;															/* Format (0) */
	int32	reserved;
	
	int32	map_id;															/* Kennung der Farbtabelle */
	int32	color_space;													/* Farbraum */
	int32	flags;															/* interne Flags */
	int32	no_colors;														/* Anzahl der FarbeintrÑge */

	int32	reserved1;
	int32	reserved2;
	int32	reserved3;
	int32	reserved4;

	COLOR_ENTRY	colors[256];
} COLOR_TAB256;

typedef	void	INVERSE_CTAB;											/* der Aufbau ist nicht von Bedeutung */

/*----------------------------------------------------------------------------------------*/
/* Verweise auf Farbtabellen																					*/
/*----------------------------------------------------------------------------------------*/

#if	REFS_ARE_PTRS														/* Zeiger verweisen auf Farbtabellen */
typedef COLOR_TAB		*CTAB_PTR;
typedef COLOR_TAB		*CTAB_REF;
typedef INVERSE_CTAB	*ITAB_REF;
#endif


/*----------------------------------------------------------------------------------------*/
/*	Bitmaps																											*/
/*----------------------------------------------------------------------------------------*/

#define	CBITMAP_MAGIC	'cbtm'

typedef struct	_gcbitmap												/* îffentliche Bitmapbeschreibung (mit Versionsheader) */
{
	int32			magic;													/* Strukturkennung 'cbtm' */
	int32			length;													/* StrukturlÑnge */
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
	int32			reserved0;												/* reserviert (0) */
	int32			reserved1;												/* reserviert (0) */
} GCBITMAP;
#endif


/*----------------------------------------------------------------------------------------*/
/* Transfermodi fÅr Bitmaps																					*/
/*----------------------------------------------------------------------------------------*/

/* Moduskonstanten */
#define	T_NOT					4											/* Konstante fÅr Invertierung bei logischen Transfermodi */
#define	T_COLORIZE			16											/* Konstante fÅr EinfÑrbung */

#define	T_LOGIC_MODE		0
#define	T_DRAW_MODE			32
#define	T_ARITH_MODE		64											/* Konstante fÅr Arithmetische Transfermodi */
#define	T_DITHER_MODE		128										/* Konstante fÅrs Dithern */

/* logische Transfermodi */
#define	T_LOGIC_COPY		T_LOGIC_MODE+0
#define	T_LOGIC_OR			T_LOGIC_MODE+1
#define	T_LOGIC_XOR			T_LOGIC_MODE+2
#define	T_LOGIC_AND			T_LOGIC_MODE+3
#define	T_LOGIC_NOT_COPY	T_LOGIC_MODE+4
#define	T_LOGIC_NOT_OR		T_LOGIC_MODE+5
#define	T_LOGIC_NOT_XOR	T_LOGIC_MODE+6
#define	T_LOGIC_NOT_AND	T_LOGIC_MODE+7

/* Zeichenmodi */
#define	T_REPLACE			T_DRAW_MODE+0
#define	T_TRANSPARENT		T_DRAW_MODE+1
#define	T_HILITE				T_DRAW_MODE+2
#define	T_REVERS_TRANSPARENT	T_DRAW_MODE+3

/* arithmetische Transfermodi */
#define	T_BLEND				T_ARITH_MODE+0
#define	T_ADD					T_ARITH_MODE+1
#define	T_ADD_OVER			T_ARITH_MODE+2
#define	T_SUB					T_ARITH_MODE+3
#define	T_MAX					T_ARITH_MODE+5
#define	T_SUB_OVER			T_ARITH_MODE+6
#define	T_MIN					T_ARITH_MODE+7

/*----------------------------------------------------------------------------------------*/
/* Strukturen																										*/
/*----------------------------------------------------------------------------------------*/

typedef struct																/* Rechteck fÅr 16-Bit-Koordinaten */
{
	int16	x1;
	int16	y1;
	int16	x2;
	int16	y2;
} RECT16;

typedef struct																/* Rechteck fÅr 32-Bit-Koordinaten */
{
	int32	x1;
	int32	y1;
	int32	x2;
	int32	y2;
} RECT32;

typedef struct
{
	int32	size;					/* LÑnge der Struktur, muû vor vqt_xfntinfo() gesetzt werden */
	int16	format;				/* Fontformat, z.B. 4 fÅr TrueType */
	int16	id;					/* Font-ID, z.B. 6059 */
	int16	index;				/* Index */
	int8	font_name[50];		/* vollstÑndiger Fontname, z.B. "Century 725 Italic BT" */
	int8	family_name[50];	/* Name der Fontfamilie, z.B. "Century725 BT" */
	int8	style_name[50];	/* Name des Fontstils, z.B. "Italic" */
	int8	file_name1[200];	/* Name der 1. Fontdatei, z.B. "C:\FONTS\TT1059M_.TTF" */
	int8	file_name2[200];	/* Name der optionalen 2. Fontdatei */
	int8	file_name3[200];	/* Name der optionalen 3. Fontdatei */
	int16	pt_cnt;				/* Anzahl der Punkthîhen fÅr vst_point(), z.B. 10 */
	int16	pt_sizes[64];		/* verfÅgbare Punkthîhen, z.B. { 8, 9, 10, 11, 12, 14, 18, 24, 36, 48 } */
} XFNT_INFO;

/*----------------------------------------------------------------------------------------*/
/* Funktionsdeklarationen																						*/
/*----------------------------------------------------------------------------------------*/

extern int16	v_opnprn( int16 base_handle, PRN_SETTINGS *settings, int16 *work_out );
extern void		v_opnbm( int16 *work_in, MFDB *bitmap, int16 *handle, int16 *work_out );
extern int16	v_resize_bm( int16 handle, int16 width, int16 height, int32 byte_width, uint8 *addr );
extern int16	v_open_bm( int16 base_handle, GCBITMAP *bitmap, 
								  int16 color_flags, int16 unit_flags, int16 pixel_width, int16 pixel_height );
extern void		v_clsbm( int16 handle );
#define	v_close_bm( handle )	v_clsbm( handle )
extern void		vq_scrninfo( int16 handle, int16 *work_out );
extern int16	vq_ext_devinfo( int16 handle, int16 id, int16 *exists, int8 *file_path, int8 *file_name, int8 *name );

extern void	_v_bez( int16 handle, int16 count, int16 *xy, int8 *bezarr,
						  int16 *extent, int16 *totpts, int16 *totmoves );
extern void	_v_bez_fill( int16 handle, int16 count, int16 *xy, int8 *bezarr,
								 int16 *extent, int16 *totpts, int16 *totmoves );

extern void		v_ftext_wide( int16 handle, int16 x, int16 y, uint16 *string );
extern int16	vst_map_mode( int16 handle, int16 mode );
extern void		vst_width( int16 handle, int16 width, int16 *char_width, int16 *char_height,
								  int16 *cell_width, int16 *cell_height );
extern void		vst_track_offset( int16 handle, fix31 offset, int16 pair_mode, int16 *tracks, int16 *pairs );
extern int16	vst_name( int16 handle, int16 font_format, int8 *font_name, int8 *ret_name );

extern uint16	vqt_char_index( int16 handle, uint16 src_index, int16 src_mode, int16 dst_mode );
extern int16	vqt_ext_name( int16 handle, int16 index, int8 *name, uint16 *font_format, uint16 *flags );
extern int16	v_get_outline( int16 handle, uint16 index, int16 x_offset, int16 y_offset,
										int16 *pts, int8 *flags, int16 max_pts );
extern int16	vqt_xfntinfo( int16 handle, int16 flags, int16 id, int16 index, XFNT_INFO *info );
extern void		vqt_extent_wide( int16 handle, uint16 *string, int16 *extent );
extern void		vqt_real_extent( int16 handle, int16 x, int16 y, int8 *string, int16 *extent );
extern void		vqt_real_extent_wide( int16 handle, int16 x, int16 y, uint16 *string, int16 *extent );
extern int16	vqt_name_and_id( int16 handle, int16 font_format, int8 *font_name, int8 *ret_name );

/* Vordergrundfarbe kompatibel zu GEM/3-Metafiles setzen */
extern void	v_setrgb( int16 handle, int16 type, int16 r, int16 g, int16 b );

/* Vordergrundfarbe setzen */
extern int16	vst_fg_color( int16 handle, int32 color_space, COLOR_ENTRY *fg_color );
extern int16	vsf_fg_color( int16 handle, int32 color_space, COLOR_ENTRY *fg_color );
extern int16	vsl_fg_color( int16 handle, int32 color_space, COLOR_ENTRY *fg_color );
extern int16	vsm_fg_color( int16 handle, int32 color_space, COLOR_ENTRY *fg_color );
extern int16	vsr_fg_color( int16 handle, int32 color_space, COLOR_ENTRY *fg_color );

/* Hintergrundfarbe setzen */
extern int16	vst_bg_color( int16 handle, int32 color_space, COLOR_ENTRY *bg_color );
extern int16	vsf_bg_color( int16 handle, int32 color_space, COLOR_ENTRY *bg_color );
extern int16	vsl_bg_color( int16 handle, int32 color_space, COLOR_ENTRY *bg_color );
extern int16	vsm_bg_color( int16 handle, int32 color_space, COLOR_ENTRY *bg_color );
extern int16	vsr_bg_color( int16 handle, int32 color_space, COLOR_ENTRY *bg_color );


/* Vordergrundfarbe erfragen */
extern int32	vqt_fg_color( int16 handle, COLOR_ENTRY *fg_color );
extern int32	vqf_fg_color( int16 handle, COLOR_ENTRY *fg_color );
extern int32	vql_fg_color( int16 handle, COLOR_ENTRY *fg_color );
extern int32	vqm_fg_color( int16 handle, COLOR_ENTRY *fg_color );
extern int32	vqr_fg_color( int16 handle, COLOR_ENTRY *fg_color );

/* Hintergrundfarbe erfragen */
extern int32	vqt_bg_color( int16 handle, COLOR_ENTRY *bg_color );
extern int32	vqf_bg_color( int16 handle, COLOR_ENTRY *bg_color );
extern int32	vql_bg_color( int16 handle, COLOR_ENTRY *bg_color );
extern int32	vqm_bg_color( int16 handle, COLOR_ENTRY *bg_color );
extern int32	vqr_bg_color( int16 handle, COLOR_ENTRY *bg_color );

/* diverse Modi parametrisieren */
extern int16	vs_hilite_color( int16 handle, int32 color_space, COLOR_ENTRY *hilite_color );
extern int16	vs_min_color( int16 handle, int32 color_space, COLOR_ENTRY *min_color );
extern int16	vs_max_color( int16 handle, int32 color_space, COLOR_ENTRY *max_color );
extern int16	vs_weight_color( int16 handle, int32 color_space, COLOR_ENTRY *weight_color );

extern int32	vq_hilite_color( int16 handle, COLOR_ENTRY *hilite_color );
extern int32	vq_min_color( int16 handle, COLOR_ENTRY *min_color );
extern int32	vq_max_color( int16 handle, COLOR_ENTRY *max_color );
extern int32	vq_weight_color( int16 handle, COLOR_ENTRY *weight_color );

/* Farben erfragen */
extern uint32	v_color2value( int16 handle, int32 color_space, COLOR_ENTRY *color );
extern int32	v_value2color( int16 handle, uint32 value, COLOR_ENTRY *color );
extern int32	v_color2nearest( int16 handle, int32 color_space, COLOR_ENTRY *color, COLOR_ENTRY *nearest_color );
extern int32	vq_px_format( int16 handle, uint32 *px_format );


/* Farbtabellen */
extern int16	vs_ctab( int16 handle, COLOR_TAB *ctab );
extern int16	vs_ctab_entry( int16 handle, int16 index, int32 color_space, COLOR_ENTRY *color );
extern int16	vs_dflt_ctab( int16 handle );

extern int16	vq_ctab( int16 handle, int32 ctab_length, COLOR_TAB *ctab );
extern int32	vq_ctab_entry( int16 handle, int16 index, COLOR_ENTRY *color );
extern int32	vq_ctab_id( int16 handle );
extern int16	v_ctab_idx2vdi( int16 handle, int16 index );
extern int16	v_ctab_vdi2idx( int16 handle, int16 vdi_index );
extern uint32	v_ctab_idx2value( int16 handle, int16 index );
extern int32	v_get_ctab_id( int16 handle );
extern int16	vq_dflt_ctab( int16 handle, int32 ctab_length, COLOR_TAB *ctab );
extern COLOR_TAB	*v_create_ctab( int16 handle, int32 color_space, uint32 px_format );
extern int16	v_delete_ctab( int16 handle, COLOR_TAB *ctab );

/* inverse Farbtabellen */
extern ITAB_REF	v_create_itab( int16 handle, COLOR_TAB *ctab, int16 bits );
extern int16	v_delete_itab( int16 handle, ITAB_REF itab );


/* Bitmapausgabe */
extern void	vr_transfer_bits( int16 handle, GCBITMAP *src_bm, GCBITMAP *dst_bm,
										int16 *src_rect, int16 *dst_rect,
										int16 mode );

/* Drucker */
extern int16	v_orient( int16 handle, int16 orientation );
extern int16	v_copies( int16 vdi_handle, int16 copies );
extern fixed	vq_prn_scaling( int16 handle );
extern int16	vq_margins( int16 handle, int16 *top_margin, int16 *bottom_margin, int16 *left_margin, int16 *right_margin, int16 *hdpi, int16 *vdpi );
extern int16	vs_document_info( int16 handle, int16 type, void *s, int16 wchar );

#endif