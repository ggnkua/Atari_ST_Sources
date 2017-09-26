/*----------------------------------------------------------------------------------------
	vdi.h, part of TOS Linker for CodeWarrior

	VDI system calls for TOS
	
	21.10.1998 by Manfred Lippert
	based on VDI documentations from Sven & Wilfried Behne

	last change: 16.1.2001

	Don't edit this file.

	If you have to make any changes on this file, please contact:
	mani@mani.de
----------------------------------------------------------------------------------------*/

#ifndef __TOS_vdi_h__
#define __TOS_vdi_h__

#ifndef __PORTAB__
#include <portab.h>
#endif

#if !TARGET_TOS
	#error VDI-Lib used in Non-TOS Project
#endif
#if !MC68K
	#error VDI-Lib used in Non-68K Project
#endif


#include <prsettng.h>
#include <Colors2B.h>
#include <Shapes2B.h>

/*----------------------------------------------------------------------------------------*/
/* transfer modes for bitmaps																					*/
/*----------------------------------------------------------------------------------------*/

/* Moduskonstanten */
#define	T_NOT					4							/* Konstante für Invertierung bei logischen Transfermodi */
#define	T_COLORIZE			16							/* Konstante für Einfärbung */

#define	T_LOGIC_MODE		0
#define	T_DRAW_MODE			32
#define	T_ARITH_MODE		64							/* Konstante für Arithmetische Transfermodi */
#define	T_DITHER_MODE		128						/* Konstante fürs Dithern */

/* logische Transfermodi */
#define	T_LOGIC_COPY			T_LOGIC_MODE+0
#define	T_LOGIC_OR				T_LOGIC_MODE+1
#define	T_LOGIC_XOR				T_LOGIC_MODE+2
#define	T_LOGIC_AND				T_LOGIC_MODE+3
#define	T_LOGIC_NOT_COPY		T_LOGIC_MODE+4
#define	T_LOGIC_NOT_OR			T_LOGIC_MODE+5
#define	T_LOGIC_NOT_XOR		T_LOGIC_MODE+6
#define	T_LOGIC_NOT_AND		T_LOGIC_MODE+7

/* Zeichenmodi */
#define	T_REPLACE				T_DRAW_MODE+0
#define	T_TRANSPARENT			T_DRAW_MODE+1
#define	T_HILITE					T_DRAW_MODE+2
#define	T_REVERS_TRANSPARENT	T_DRAW_MODE+3

/* arithmetische Transfermodi */
#define	T_BLEND					T_ARITH_MODE+0
#define	T_ADD						T_ARITH_MODE+1
#define	T_ADD_OVER				T_ARITH_MODE+2
#define	T_SUB						T_ARITH_MODE+3
#define	T_MAX						T_ARITH_MODE+5
#define	T_SUB_OVER				T_ARITH_MODE+6
#define	T_MIN						T_ARITH_MODE+7

/*----------------------------------------------------------------------------------------*/
/* Structs																											*/
/*----------------------------------------------------------------------------------------*/

typedef struct {
	int16	red;				/* Rot-Intensität in Promille (0-1000) */
	int16	green;			/* Grün-Intensität in Promille (0-1000) */
	int16	blue;				/* Blau-Intensität in Promille (0-1000) */
} RGB1000;

typedef struct {
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

typedef struct {
	int16	x;
	int16	y;
	int16	w;
	int16	h;
} GRECT16;

typedef struct {
	int32	x;
	int32	y;
	int32	w;
	int32	h;
} GRECT32;

typedef struct {
	int32	size;					/* Länge der Struktur, muß vor vqt_xfntinfo() gesetzt werden */
	int16	format;				/* Fontformat, z.B. 4 für TrueType */
	int16	id;					/* Font-ID, z.B. 6059 */
	int16	index;				/* Index */
	int8	font_name[50];		/* vollständiger Fontname, z.B. "Century 725 Italic BT" */
	int8	family_name[50];	/* Name der Fontfamilie, z.B. "Century725 BT" */
	int8	style_name[50];	/* Name des Fontstils, z.B. "Italic" */
	int8	file_name1[200];	/* Name der 1. Fontdatei, z.B. "C:\FONTS\TT1059M_.TTF" */
	int8	file_name2[200];	/* Name der optionalen 2. Fontdatei */
	int8	file_name3[200];	/* Name der optionalen 3. Fontdatei */
	int16	pt_cnt;				/* Anzahl der Punkthöhen für vst_point(), z.B. 10 */
	int16	pt_sizes[64];		/* verfügbare Punkthöhen, z.B. { 8, 9, 10, 11, 12, 14, 18, 24, 36, 48 } */
} XFNT_INFO;

/*--------------------------------------------------------------------------------------*/
/* Constants for vqt_ext_name															*/
/*--------------------------------------------------------------------------------------*/

/* flags: only valid if format is not FONTFORMAT_UNKNOWN */
#define FONTFLAG_MONO	0x1
#define FONTFLAG_SYMBOL	0x10

/* format: */
#define FONTFORMAT_UNKNOWN	0x0
#define FONTFORMAT_BITMAP	0x1
#define FONTFORMAT_SPEEDO	0x2
#define FONTFORMAT_TRUETYPE	0x4
#define FONTFORMAT_TYPE1	0x8

/*--------------------------------------------------------------------------------------*/
/* Defines																				*/
/*--------------------------------------------------------------------------------------*/

/* for vswr_mode, vrt_cpyfm: */

#define MD_REPLACE      1
#define MD_TRANS        2
#define MD_XOR          3
#define MD_ERASE        4

/* for vsf_interior: */

#define FIS_HOLLOW      0
#define FIS_SOLID       1
#define FIS_PATTERN     2
#define FIS_HATCH       3
#define FIS_USER        4

/* for vsf_style: */

#define IP_HOLLOW       0
#define IP_1PATT        1
#define IP_2PATT        2
#define IP_3PATT        3
#define IP_4PATT        4
#define IP_5PATT        5
#define IP_6PATT        6
#define IP_SOLID        7

/* for vro_cpyfm: */

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


/* for vsl_type: */

#define SOLID           1
#define LONGDASH        2
#define DOT             3
#define DASHDOT         4
#define DASH            5
#define DASH2DOT        6
#define USERLINE        7

/* for vsl_ends: */

#define SQUARE          0
#define ARROWED         1
#define ROUND           2


/*--------------------------------------------------------------------------------------*/
/* Functions																			*/
/*--------------------------------------------------------------------------------------*/

/* GDOS installed? */

extern C_CALL int16 vq_gdos(void);


/* device drivers and offscreen bitmaps: */

extern C_CALL void v_opnwk(int16 *work_in, int16 *handle, int16 *work_out);
extern C_CALL int16 v_opnprn(int16 base_handle, PRN_SETTINGS *settings, int16 *work_out);
extern C_CALL void v_clswk(int16 handle);
extern C_CALL void v_opnvwk(int16 *work_in, int16 *handle, int16 *work_out);
extern C_CALL void v_clsvwk(int16 handle);
extern C_CALL void v_clrwk(int16 handle);
extern C_CALL void v_clear_disp_list(int16 handle);
extern C_CALL void v_updwk(int16 handle);
extern C_CALL void v_opnbm(int16 *work_in, MFDB *bitmap, int16 *handle, int16 *work_out);
extern C_CALL void v_clsbm(int16 handle);
extern C_CALL int16 v_open_bm(int16 base_handle, GCBITMAP *bitmap, int16 zero, int16 flags, int16 pixel_width, int16 pixel_height);
extern C_CALL int16 v_resize_bm(int16 handle, int16 width, int16 height, int32 byte_width, uint8 *addr);
extern C_CALL void vq_extnd(int16 handle, int16 flag, int16 *wout);
extern C_CALL void vq_scrninfo(int16 handle, int16 *wout);
extern C_CALL void vq_devinfo(int16 handle, int16 device, int16 *dev_open, char *file_name, char *device_name);
extern C_CALL int16 vq_ext_devinfo(int16 handle, int16 device, int16 *dev_exists, char *file_path, char *file_name, char *name);

/* colors: */

extern C_CALL void vs_color(int16 handle, int16 index, RGB1000 *rgb);
extern C_CALL int16 vq_color(int16 handle, int16 index, int16 flag, RGB1000 *rgb);
extern C_CALL int16 vs_calibrate(int16 handle, int16 flag, RGB1000 *table);
extern C_CALL int16 vq_calibrate(int16 handle, int16 *flag);

/* writing mode and clipping area: */

extern C_CALL int16 vswr_mode(int16 handle, int16 mode);
extern C_CALL void vs_clip(int16 handle, int16 flag, POINT16 *area);

/* lines and unfilled graphic primitives: */

extern C_CALL void v_pline(int16 handle, int16 count, POINT16 *xy);
extern C_CALL void v_bez(int16 handle, int16 count, POINT16 *xyarr, uint8 *bezarr, POINT16 *extent, int16 *totpts, int16 *totmoves);
extern C_CALL void v_arc(int16 handle, int16 x, int16 y, int16 radius, int16 begang, int16 endang);
extern C_CALL void v_ellarc(int16 handle, int16 x, int16 y, int16 xradius, int16 yradius, int16 begang, int16 endang);
extern C_CALL void v_rbox(int16 handle, POINT16 *rect);
extern C_CALL int16 v_bez_on(int16 handle);
extern C_CALL void v_bez_off(int16 handle);
extern C_CALL void v_bez_qual(int16 handle, int16 qual, int16 *set_qual);	/* int16 return value?? */
extern C_CALL int16 vsl_type(int16 handle, int16 type);
extern C_CALL int16 vsl_width(int16 handle, int16 width);
extern C_CALL int16 vsl_color(int16 handle, int16 color_index);
extern C_CALL void vql_attributes(int16 handle, int16 *attrib);
extern C_CALL void vsl_ends(int16 handle, int16 beg_style, int16 end_style);
extern C_CALL void vsl_udsty(int16 handle, int16 pattern);

/* filled graphic primitives: */

extern C_CALL void v_fillarea(int16 handle, int16 count, POINT16 *xy);
extern C_CALL void v_bez_fill(int16 handle, int16 count, POINT16 *xyarr, uint8 *bezarr, POINT16 *extent, int16 *totpts, int16 *totmoves);
extern C_CALL void v_bar(int16 handle, POINT16 *rect);
extern C_CALL void v_pieslice(int16 handle, int16 x, int16 y, int16 radius, int16 begang, int16 endang);
extern C_CALL void v_circle(int16 handle, int16 x, int16 y, int16 radius);
extern C_CALL void v_ellipse(int16 handle, int16 x, int16 y, int16 xradius, int16 yradius);
extern C_CALL void v_ellpie(int16 handle, int16 x, int16 y, int16 xradius, int16 yradius, int16 begang, int16 endang);
extern C_CALL void v_rfbox(int16 handle, POINT16 *rect);
extern C_CALL int16 vsf_interior(int16 handle, int16 interior);
extern C_CALL int16 vsf_style(int16 handle, int16 style_index);
extern C_CALL int16 vsf_color(int16 handle, int16 color_index);
extern C_CALL void vqf_attributes(int16 handle, int16 *attrib);
extern C_CALL void v_contourfill(int16 handle, int16 x, int16 y, int16 color_index);
extern C_CALL int16 vsf_perimeter(int16 handle, int16 flag);
extern C_CALL void vsf_udpat(int16 handle, int16 *pattern, int16 planes);
extern C_CALL void v_recfl(int16 handle, POINT16 *rect);

/* marker: */

extern C_CALL void v_pmarker(int16 handle, int16 count, POINT16 *xy);
extern C_CALL int16 vsm_type(int16 handle, int16 type);
extern C_CALL int16 vsm_height(int16 handle, int16 height);
extern C_CALL int16 vsm_color(int16 handle, int16 color_index);
extern C_CALL void vqm_attributes(int16 handle, int16 *attrib);

/* text output with bitmap and vector fonts: */

extern C_CALL void v_gtext(int16 handle, int16 x, int16 y, char *string);
extern C_CALL void v_gtext_unicode(int16 handle, int16 x, int16 y, const uint16 *uni_string, uint32 length);
extern C_CALL void v_justified(int16 handle,int16 x, int16 y, char *string, int16 length, int16 word_space, int16 char_space);
extern C_CALL void vst_height(int16 handle, int16 height,
								int16 *char_width, int16 *char_height,
								int16 *cell_width, int16 *cell_height);
extern C_CALL int16 vst_rotation(int16 handle, int16 angle);
extern C_CALL int16 vst_font(int16 handle, int16 font);
extern C_CALL int16 vst_color(int16 handle, int16 color_index);
extern C_CALL void vqt_attributes(int16 handle, int16 *attrib);
extern C_CALL void vst_alignment(int16 handle, int16 hor_in,
									int16 vert_in, int16 *hor_out, int16 *vert_out);
extern C_CALL int16 vst_effects(int16 handle, int16 effect);
extern C_CALL int16 vst_point(int16 handle, int16 point,
								int16 *char_width, int16 *char_height,
								int16 *cell_width, int16 *cell_height);
extern C_CALL void vqt_extent(int16 handle, char *string, POINT16 *extent);
extern C_CALL int16 vqt_width(int16 handle, int16 index, int16 *cell_width,
								int16 *left_delta, int16 *right_delta);
extern C_CALL int16 vst_load_fonts(int16 handle, int16 select);
extern C_CALL void vst_unload_fonts(int16 handle, int16 select);
extern C_CALL int16 vqt_ext_name(int16 handle, int16 index, char *name,
									int16 *vector, uint16 *font_format, uint16 *flags);	/* flags is only valid, if format is not FONTFORMAT_UNKNOWN */
extern C_CALL void vqt_fontinfo(int16 handle, int16 *minADE, int16 *maxADE,
								int16 *distances, int16 *maxwidth, int16 *effects);
extern C_CALL uint16 vqt_char_index(int16 handle, uint16 src_index,
									int16 src_mode, int16 dst_mode);
extern C_CALL int16 vqt_xfntinfo(int16 handle, int16 flags, int16 id, int16 index,
									XFNT_INFO *info);
extern C_CALL int16 vst_name(int16 handle, int16 font_format,
								char *font_name, char *ret_name);
extern C_CALL int16 vqt_name_and_id(int16 handle, int16 font_format,
									char *font_name, char *ret_name);
extern C_CALL void vst_width(int16 handle, int16 width,
								int16 *char_width, int16 *char_height,
								int16 *cell_width, int16 *cell_height);
extern C_CALL void vqt_fontheader(int16 handle, void *buffer, char *tdf_name);
extern C_CALL void vqt_trackkern(int16 handle, fixed32 *x_offset, fixed32 *y_offset);
extern C_CALL void vqt_pairkern(int16 handle, int16 index1, int16 index2,
								fixed32 *x_offset, fixed32 *y_offset);
extern C_CALL void vst_charmap(int16 handle, int16 mode);
extern C_CALL int16 vst_mapmode(int16 handle, int16 mode);
extern C_CALL void vst_kern(int16 handle, int16 track_mode, int16 pair_mode,
							int16 *tracks, int16 *pairs);
extern C_CALL void vst_track_offset(int16 handle, fixed32 offset, int16 pair_mode,
									int16 *tracks, int16 *pairs);
extern C_CALL void v_getbitmap_info(int16 handle, int16 index,
									fixed32 *x_advance, fixed32 *y_advance,
									fixed32 *x_offset, fixed32 *y_offset,
									int16 *width, int16 *height, void **bitmap);
extern C_CALL void vqt_f_extent(int16 handle, char *string, int16 *extent);
extern C_CALL void vqt_real_extent(int16 handle, int16 x, int16 y,
									char *string, int16 *extent);
extern C_CALL void vqt_real_extent_unicode(int16 handle,
									int16 x, int16 y,
									const uint16 *uni_string, uint32 length,
									POINT16 *extent);
extern C_CALL void v_ftext(int16 handle, int16 x, int16 y, char *string);
extern C_CALL void v_ftext_offset(int16 handle, int16 x, int16 y, char *string, int16 *offset);
extern C_CALL void v_getoutline(int16 handle, int16 index, int16 *xyarr,
								uint8 *bezarr, int16 max_pts, int16 *count);
extern C_CALL int16 v_get_outline(int16 handle, uint16 index, int16 x_offset, int16 y_offset,
									int16 *xyarr, uint8 *bezarr, int16 max_pts);
extern C_CALL fixed32 vst_arbpt32(int16 handle, fixed32 height,
									int16 *char_width, int16 *char_height,
									int16 *cell_width, int16 *cell_height);
extern C_CALL void vqt_advance32(int16 handle, int16 index,
									fixed32 *x_advance, fixed32 *y_advance);
extern C_CALL int16 v_flushcache(int16 handle);
extern C_CALL fixed32 vst_setsize32(int16 handle, fixed32 width,
									int16 *char_width, int16 *char_height,
									int16 *cell_width, int16 *cell_height);
extern C_CALL int16 vst_skew(int16 handle, int16 skew);


/* raster operations: */

extern C_CALL void vro_cpyfm(int16 handle, int16 wr_mode, POINT16 *xyarr,
								MFDB *src_MFDB, MFDB *des_MFDB );
extern C_CALL void vrt_cpyfm(int16 handle, int16 wr_mode, POINT16 *xyarr,
								MFDB *src_MFDB, MFDB *des_MFDB,
								int16 *color_index);
extern C_CALL void vr_trnfm(int16 handle, MFDB *src_MFDB, MFDB *des_MFDB);
extern C_CALL void v_get_pixel(int16 handle, int16 x, int16 y, int16 *pel, int16 *index);


/* input functions: */

extern C_CALL void vsin_mode(int16 handle, int16 dev_type, int16 mode);
extern C_CALL void vrq_locator(int16 handle, int16 x, int16 y, int16 *xout,
								int16 *yout, int16 *term);
extern C_CALL int16 vsm_locator(int16 handle,  int16 x,  int16 y,  int16 *xout,
								int16 *yout, int16 *term);
extern C_CALL void vrq_choice(int16 handle, int16 ch_in, int16 *ch_out);
extern C_CALL int16 vsm_choice(int16 handle, int16 *choice);
extern C_CALL void vrq_string(int16 handle, int16 max_length, int16 echo_mode,
								int16 *echo_xy, char *string);
extern C_CALL int32 vsm_string(int16 handle, int16 max_length, int16 echo_mode,
								int16 *echo_xy, char *string);
extern C_CALL void vsc_form(int16 handle, int16 *cursor);
extern C_CALL void vqin_mode(int16 handle, int16 dev_type, int16 *input_mode);
extern C_CALL void vex_timv(int16 handle, void *tim_addr, void **otim_addr, int16 *tim_conv);
extern C_CALL void v_show_c(int16 handle, int16 reset);
extern C_CALL void v_hide_c(int16 handle);
extern C_CALL void vq_mouse(int16 handle, int16 *status, int16 *x, int16 *y);
extern C_CALL void vex_butv(int16 handle, void *pusrcode, void **psavcode);
extern C_CALL void vex_motv(int16 handle, void *pusrcode, void **psavcode);
extern C_CALL void vex_curv(int16 handle, void *pusrcode, void **psavcode);
extern C_CALL void vq_key_s(int16 handle, int16 *status);


/* text mode and VT52: */

extern C_CALL void vq_chcells(int16 handle, int16 *rows, int16 *columns);
extern C_CALL void v_exit_cur(int16 handle);
extern C_CALL void v_enter_cur(int16 handle);
extern C_CALL void v_curup(int16 handle);
extern C_CALL void v_curdown(int16 handle);
extern C_CALL void v_curright(int16 handle);
extern C_CALL void v_curleft(int16 handle);
extern C_CALL void v_curhome(int16 handle);
extern C_CALL void v_eeos(int16 handle);
extern C_CALL void v_eeol(int16 handle);
extern C_CALL void v_curaddress(int16 handle, int16 row, int16 column);
extern C_CALL void v_curtext(int16 handle, char *string);
extern C_CALL void v_rvon(int16 handle);
extern C_CALL void v_rvoff(int16 handle);
extern C_CALL void vq_curaddress(int16 handle, int16 *row, int16 *column);


/* printer specific functions: */

extern C_CALL void v_bit_image(int16 handle, char *name, int16 aspect,
								int16 x_scale, int16 y_scale, int16 h_align,
								int16 v_align, POINT16 *xyarray);
extern C_CALL void v_trays(int16 handle, int16 input, int16 output,
							int16 *set_input, int16 *set_output);
extern C_CALL void vq_tray_names(int16 handle, char *input_name,
									char *output_name, int16 *input, int16 *output);
extern C_CALL int16 v_page_size(int16 handle, int16 page_id);
extern C_CALL int16 vq_page_name(int16 handle, int16 page_id, char *page_name,
									int32 *page_width, int32 *page_height);
extern C_CALL void v_escape2000(int16 handle, int16 times);


/* metafile specific functions: */

extern C_CALL void v_meta_extents(int16 handle, int16 x_min, int16 y_min,
									int16 x_max, int16 y_max);
extern C_CALL void v_write_meta(int16 handle, int16 num_intin, int16 *a_intin,
								int16 num_ptsin, POINT16 *a_ptsin);
extern C_CALL void vm_pagesize(int16 handle, int16 pgwidth, int16 pgheight);
extern C_CALL void vm_coords(int16 handle, int16 llx, int16 lly, int16 urx, int16 ury);
extern C_CALL void vm_filename(int16 handle, char *filename);



/* NVDI 5: */


/* set foreground color compatible to GEM/3-Metafiles */
extern C_CALL void v_setrgb(int16 handle, int16 type, int16 r, int16 g, int16 b);

/* set foreground color */
extern C_CALL int16 vst_fg_color(int16 handle, int32 color_space, COLOR_ENTRY *fg_color);
extern C_CALL int16 vsf_fg_color(int16 handle, int32 color_space, COLOR_ENTRY *fg_color);
extern C_CALL int16 vsl_fg_color(int16 handle, int32 color_space, COLOR_ENTRY *fg_color);
extern C_CALL int16 vsm_fg_color(int16 handle, int32 color_space, COLOR_ENTRY *fg_color);
extern C_CALL int16 vsr_fg_color(int16 handle, int32 color_space, COLOR_ENTRY *fg_color);

/* set background color */
extern C_CALL int16 vst_bg_color(int16 handle, int32 color_space, COLOR_ENTRY *bg_color);
extern C_CALL int16 vsf_bg_color(int16 handle, int32 color_space, COLOR_ENTRY *bg_color);
extern C_CALL int16 vsl_bg_color(int16 handle, int32 color_space, COLOR_ENTRY *bg_color);
extern C_CALL int16 vsm_bg_color(int16 handle, int32 color_space, COLOR_ENTRY *bg_color);
extern C_CALL int16 vsr_bg_color(int16 handle, int32 color_space, COLOR_ENTRY *bg_color);

/* inquire foreground color */
extern C_CALL int32 vqt_fg_color(int16 handle, COLOR_ENTRY *fg_color);
extern C_CALL int32 vqf_fg_color(int16 handle, COLOR_ENTRY *fg_color);
extern C_CALL int32 vql_fg_color(int16 handle, COLOR_ENTRY *fg_color);
extern C_CALL int32 vqm_fg_color(int16 handle, COLOR_ENTRY *fg_color);
extern C_CALL int32 vqr_fg_color(int16 handle, COLOR_ENTRY *fg_color);

/* inquire background color */
extern C_CALL int32 vqt_bg_color(int16 handle, COLOR_ENTRY *bg_color);
extern C_CALL int32 vqf_bg_color(int16 handle, COLOR_ENTRY *bg_color);
extern C_CALL int32 vql_bg_color(int16 handle, COLOR_ENTRY *bg_color);
extern C_CALL int32 vqm_bg_color(int16 handle, COLOR_ENTRY *bg_color);
extern C_CALL int32 vqr_bg_color(int16 handle, COLOR_ENTRY *bg_color);

/* diverse Modi parametrisieren */
extern C_CALL int16 vs_hilite_color(int16 handle, int32 color_space, COLOR_ENTRY *hilite_color);
extern C_CALL int16 vs_min_color(int16 handle, int32 color_space, COLOR_ENTRY *min_color);
extern C_CALL int16 vs_max_color(int16 handle, int32 color_space, COLOR_ENTRY *max_color);
extern C_CALL int16 vs_weight_color(int16 handle, int32 color_space, COLOR_ENTRY *weight_color);

extern C_CALL int32 vq_hilite_color(int16 handle, COLOR_ENTRY *hilite_color);
extern C_CALL int32 vq_min_color(int16 handle, COLOR_ENTRY *min_color);
extern C_CALL int32 vq_max_color(int16 handle, COLOR_ENTRY *max_color);
extern C_CALL int32 vq_weight_color(int16 handle, COLOR_ENTRY *weight_color);

/* colors, pixel format */
extern C_CALL uint32 v_color2value(int16 handle, int32 color_space, COLOR_ENTRY *color);
extern C_CALL int32 v_value2color(int16 handle, uint32 value, COLOR_ENTRY *color);
extern C_CALL int32 v_color2nearest(int16 handle, int32 color_space, COLOR_ENTRY *color, COLOR_ENTRY *nearest_color);
extern C_CALL int32 vq_px_format(int16 handle, uint32 *px_format);

/* color tables */
extern C_CALL int16 vs_ctab(int16 handle, COLOR_TAB *ctab);
extern C_CALL int16 vs_ctab_entry(int16 handle, int16 index, int32 color_space, COLOR_ENTRY *color);
extern C_CALL int16 vs_dflt_ctab(int16 handle);

extern C_CALL int16 vq_ctab(int16 handle, int32 ctab_length, COLOR_TAB *ctab);
extern C_CALL int32 vq_ctab_entry(int16 handle, int16 index, COLOR_ENTRY *color);
extern C_CALL int32 vq_ctab_id(int16 handle);
extern C_CALL int16 v_ctab_idx2vdi(int16 handle, int16 index);
extern C_CALL int16 v_ctab_vdi2idx(int16 handle, int16 vdi_index);
extern C_CALL uint32 v_ctab_idx2value(int16 handle, int16 index);
extern C_CALL int32 v_get_ctab_id(int16 handle);
extern C_CALL int16 vq_dflt_ctab(int16 handle, int32 ctab_length, COLOR_TAB *ctab);

/* inverse color tables */
extern C_CALL ITAB_REF v_create_itab(int16 handle, COLOR_TAB *ctab, int16 bits);
extern C_CALL int16 v_delete_itab(int16 handle, ITAB_REF itab);

/* bitmap output */
extern C_CALL void vr_transfer_bits(int16 handle, GCBITMAP *src_bm, GCBITMAP *dst_bm,
									POINT16 *src_rect, POINT16 *dst_rect,
									int16 mode);

/* printer */
extern C_CALL int16 v_orient(int16 handle, int16 orient);
extern C_CALL int16 v_copies(int16 handle, int16 copies);
extern C_CALL fixed32 vq_prn_scaling(int16 handle);
extern C_CALL int16 vq_margins(int16 handle, int16 *top_margin, int16 *bottom_margin,
								int16 *left_margin, int16 *right_margin, int16 *hdpi, int16 *vdpi);
extern C_CALL int16 vs_document_info(int16 handle, int16 type, void *s, int16 wchar);



/* Low level VDI calls: */

typedef struct {
	int16 *contrl;
	int16 *intin;
	int16 *ptsin;
	int16 *intout;
	int16 *ptsout;
} VDIPB;

typedef struct {
	int16 opcode;			/* contrl[0] */
	int16 ptsin_count;		/* contrl[1] */
	int16 ptsout_count;		/* contrl[2] */
	int16 intin_count;		/* contrl[3] */
	int16 intout_count;		/* contrl[4] */
	int16 subcode;			/* contrl[5] */
	int16 handle;			/* contrl[6] */
	int16 idx7;				/* contrl[7] */
	int16 idx8;				/* contrl[8] */
	int16 idx9;				/* contrl[9] */
	int16 idx10;			/* contrl[10] */
	int16 idx11;			/* contrl[11] */
	int16 idx12;			/* contrl[12] */
} VDICONTRL;

/* better VDIPB: */
typedef struct {
	VDICONTRL *contrl;
	int16 *intin;
	POINT16 *ptsin;
	int16 *intout;
	POINT16 *ptsout;
} XVDIPB;

/* (mostly) constant "input"-parts of contrl fields for mt_vdi: */
typedef struct {
	int16 opcode;			/* contrl[0] */
	int16 ptsin_count;		/* contrl[1] */
	int16 intin_count;		/* contrl[3] */
	int16 subcode;			/* contrl[5] */
} VDICONIN;

/* mt save VDI binding:
   XVDIPB *pb and all data must be allocated locally on stack.
   VDICONIN can (should) be static, if it contains data, that
   never changes.
*/
extern C_CALL void mt_vdi(__A0(XVDIPB *pb), __A1(VDICONIN *conin));

#endif
