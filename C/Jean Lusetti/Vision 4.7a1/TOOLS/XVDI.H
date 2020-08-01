/*****************************************************************************/
/*   VDI.H: Common VDI definitions and structures.                           */
/*****************************************************************************/
/*                                                                           */
/*   Authors: Dieter & Juergen Geiss                                         */
/*                                                                           */
/*****************************************************************************/

#ifndef __VDI__
#define __VDI__

/****** Control library ******************************************************/

#define OW_FILE          0 /* output device type in the low-order byte */
#define OW_SERIAL        1
#define OW_PARALLEL      2
#define OW_DEVICE        3
#define OW_NOCHANGE    255

#define OW_LETTER1       0 /* page size index in the high-order byte */
#define OW_HALF          5
#define OW_B5           10
#define OW_LETTER2      20
#define OW_A4           30
#define OW_LEGAL        40
#define OW_DOUBLE       50
#define OW_BROAD        55
#define OW_INDIRECT    255 /* use work_in [101] and work_in [102] */

VOID v_get_driver_info _((WORD device_id, WORD info_select,
                          UBYTE FAR *info_string));
VOID v_opnwk           _((WORD FAR *work_in, WORD FAR *handle,
                          WORD FAR *work_out));
VOID v_clswk           _((WORD handle));
VOID v_clrwk           _((WORD handle));
VOID v_updwk           _((WORD handle));
VOID v_opnvwk          _((WORD FAR *work_in, WORD FAR *handle, 
                          WORD FAR *work_out));
VOID v_clsvwk          _((WORD handle));
WORD vst_load_fonts    _((WORD handle, WORD select));
VOID vst_unload_fonts  _((WORD handle, WORD select));

#if GEM & (GEM3 | XGEM)
WORD vst_ex_load_fonts _((WORD handle, WORD select, WORD font_max,
                          WORD font_free));
#endif

VOID vs_clip           _((WORD handle, WORD clip_flag, WORD FAR *pxyarray));
VOID v_set_app_buff    _((VOID FAR *address, WORD nparagraphs));
WORD v_bez_on          _((WORD handle));
WORD v_bez_off         _((WORD handle));
WORD v_bez_qual        _((WORD handle, WORD prcnt));
VOID v_pat_rotate      _((WORD handle, WORD angle));

/****** Output library *******************************************************/

VOID v_pline           _((WORD handle, WORD count, WORD FAR *xy));
VOID v_pmarker         _((WORD handle, WORD count, WORD FAR *xy));
VOID v_gtext           _((WORD handle, WORD x, WORD y, BYTE FAR *string));

#if GEM & (GEM3 | XGEM)
VOID v_etext           _((WORD handle, WORD x, WORD y, UBYTE FAR *string,
                          WORD FAR *offsets));
#endif

VOID v_fillarea        _((WORD handle, WORD count, WORD FAR *xy));
VOID v_cellarray       _((WORD handle, WORD FAR *pxyarray, WORD row_length,
                          WORD el_used, WORD num_rows, WORD wrt_mode,
                          WORD FAR *colarray));
VOID v_bar             _((WORD handle, WORD FAR *pxyarray));
VOID v_arc             _((WORD handle, WORD x, WORD y, WORD radius,
                          WORD begang, WORD endang));
VOID v_pieslice        _((WORD handle, WORD x, WORD y, WORD radius,
                          WORD begang, WORD endang));
VOID v_circle          _((WORD handle, WORD x, WORD y, WORD radius));
VOID v_ellipse         _((WORD handle, WORD x, WORD y, WORD xradius,
                          WORD yradius));
VOID v_ellarc          _((WORD handle, WORD x, WORD y, WORD xradius,
                          WORD yradius, WORD begang, WORD endang));
VOID v_ellpie          _((WORD handle, WORD x, WORD y, WORD xradius,
                          WORD yradius, WORD begang, WORD endang));
VOID v_rbox            _((WORD handle, WORD FAR *xyarray));
VOID v_rfbox           _((WORD handle, WORD FAR *xyarray));
VOID v_justified       _((WORD handle, WORD x, WORD y, BYTE FAR *string,
                          WORD length, WORD word_space, WORD char_space));
VOID v_contourfill     _((WORD handle, WORD x, WORD y, WORD index));
VOID vr_recfl          _((WORD handle, WORD FAR *pxyarray));
VOID v_bez             _((WORD handle, WORD count, WORD FAR *xyarr,
                          UBYTE FAR *bezarr, WORD FAR *minmax, WORD FAR *npts,
                          WORD FAR *nmove));
VOID v_bez_fill        _((WORD handle, WORD count, WORD FAR *xyarr,
                          UBYTE FAR *bezarr, WORD FAR *minmax, WORD FAR *npts,
                          WORD FAR *nmove));

/****** Attribute library ****************************************************/

#define MD_REPLACE       1 /* gsx modes */
#define MD_TRANS         2
#define MD_XOR           3
#define MD_ERASE         4

#define FIS_HOLLOW       0 /* gsx styles */
#define FIS_SOLID        1
#define FIS_PATTERN      2
#define FIS_HATCH        3
#define FIS_USER         4

#define ALL_WHITE        0 /* bit blt rules */
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
#define S_OR_NOTD       11
#define NOT_D           12
#define NOTS_OR_D       13
#define NOT_SANDD       14
#define ALL_BLACK       15

#ifndef WHITE
#define WHITE            0 /* colors */
#define BLACK            1
#define RED              2
#define GREEN            3
#define BLUE             4
#define CYAN             5
#define YELLOW           6
#define MAGENTA          7
#define DWHITE           8
#define DBLACK           9
#define DRED            10
#define DGREEN          11
#define DBLUE           12
#define DCYAN           13
#define DYELLOW         14
#define DMAGENTA        15
#endif

#define SOLID            1 /* line types */
#define LONGDASH         2
#define DOT              3
#define DASHDOT          4
#define DASH             5
#define DASH2DOT         6
#define USERLINE         7

#define SQUARED          0 /* line ends */
#define ARROWED          1
#define ROUNDED          2

#define PM_DOT           1 /* polymarker types */
#define PM_PLUS          2
#define PM_ASTERISK      3
#define PM_SQUARE        4
#define PM_DIAGCROSS     5
#define PM_DIAMOND       6

#define TXT_NORMAL       0x0000 /* text effects */
#define TXT_THICKENED    0x0001
#define TXT_LIGHT        0x0002
#define TXT_SKEWED       0x0004
#define TXT_UNDERLINED   0x0008
#define TXT_OUTLINED     0x0010
#define TXT_SHADOWED     0x0020

#define ALI_LEFT         0 /* horizontal text alignment */
#define ALI_CENTER       1
#define ALI_RIGHT        2

#define ALI_BASE         0 /* vertical text alignment */
#define ALI_HALF         1
#define ALI_ASCENT       2
#define ALI_BOTTOM       3
#define ALI_DESCENT      4
#define ALI_TOP          5

/* fill pattern */

typedef struct patarray
{
  WORD patword [16];
} FILLPAT;

WORD vswr_mode         _((WORD handle, WORD mode));
VOID vs_color          _((WORD handle, WORD index, WORD FAR *rgb_in));
WORD vsl_type          _((WORD handle, WORD style));
VOID vsl_udsty         _((WORD handle, WORD pattern));
WORD vsl_width         _((WORD handle, WORD width));
WORD vsl_color         _((WORD handle, WORD color_index));
VOID vsl_ends          _((WORD handle, WORD beg_style, WORD end_style));
WORD vsm_type          _((WORD handle, WORD symbol));
WORD vsm_height        _((WORD handle, WORD height));
WORD vsm_color         _((WORD handle, WORD color_index));
VOID vst_height        _((WORD handle, WORD height,
                          WORD FAR *char_width, WORD FAR *char_height,
                          WORD FAR *cell_width, WORD FAR *cell_height));
WORD vst_point         _((WORD handle, WORD point,
                          WORD FAR *char_width, WORD FAR *char_height,
                          WORD FAR *cell_width, WORD FAR *cell_height));
WORD vst_rotation      _((WORD handle, WORD angle));
WORD vst_font          _((WORD handle, WORD font));
WORD vst_color         _((WORD handle, WORD color_index));
WORD vst_effects       _((WORD handle, WORD effect));
VOID vst_alignment     _((WORD handle, WORD hor_in, WORD vert_in,
                          WORD FAR *hor_out, WORD FAR *vert_out));
WORD vsf_interior      _((WORD handle, WORD style));
WORD vsf_style         _((WORD handle, WORD style_index));
WORD vsf_color         _((WORD handle, WORD color_index));
WORD vsf_perimeter     _((WORD handle, WORD per_vis));
WORD vsf_xperimeter    _((WORD handle, WORD per_vis, WORD per_style));
VOID vsf_udpat         _((WORD handle, WORD FAR *pfill_pat, WORD planes));
VOID vs_grayoverride   _((WORD handle, WORD grayval));

/****** Raster library *******************************************************/

/* Memory Form Definition Block */

typedef struct memform
{
  VOID FAR *mp;
  WORD fwp;
  WORD fh;
  WORD fww;
  WORD ff;
  WORD np;
  WORD r1;
  WORD r2;
  WORD r3;
} MFDB;

typedef struct fdbstr   /* for compatibility */
{
  VOID FAR *fd_addr;
  WORD fd_w;
  WORD fd_h;
  WORD fd_wdwidth;
  WORD fd_stand;
  WORD fd_nplanes;
  WORD fd_r1;
  WORD fd_r2;
  WORD fd_r3;
} FDB;

VOID v_get_pixel       _((WORD handle, WORD x, WORD y, WORD FAR *pel,
                          WORD FAR *index));
VOID vro_cpyfm         _((WORD handle, WORD wr_mode, WORD FAR *xy,
                          MFDB FAR *srcMFDB, MFDB FAR *desMFDB));
VOID vr_trnfm          _((WORD handle, MFDB FAR *srcMFDB, MFDB FAR *desMFDB));
VOID vrt_cpyfm         _((WORD handle, WORD wr_mode, WORD FAR *xy,
                          MFDB FAR *srcMFDB, MFDB FAR *desMFDB,
                          WORD FAR *index));

/****** Input library ********************************************************/

#define DEV_LOCATOR      1 /* input device */
#define DEV_VALUATOR     2
#define DEV_CHOICE       3
#define DEV_STRING       4

#define MODE_REQUEST     1 /* input mode */
#define MODE_SAMPLE      2

VOID vsin_mode         _((WORD handle, WORD dev_type, WORD mode));
VOID vrq_locator       _((WORD handle, WORD initx, WORD inity,
                          WORD FAR *xout, WORD FAR *yout, WORD FAR *term));
WORD vsm_locator       _((WORD handle, WORD initx, WORD inity,
                          WORD FAR *xout, WORD FAR *yout, WORD FAR *term));
VOID vrq_valuator      _((WORD handle, WORD val_in, WORD FAR *val_out,
                          WORD FAR *term));
VOID vsm_valuator      _((WORD handle, WORD val_in, WORD FAR *val_out,
                          WORD FAR *term, WORD FAR *status));
VOID vrq_choice        _((WORD handle, WORD in_choice, WORD FAR *out_choice));
WORD vsm_choice        _((WORD handle, WORD FAR *choice));
VOID vrq_string        _((WORD handle, WORD length, WORD echo_mode,
                          WORD FAR *echo_xy, BYTE FAR *string));
WORD vsm_string        _((WORD handle, WORD length, WORD echo_mode,
                          WORD FAR *echo_xy, BYTE FAR *string));
VOID vsc_form          _((WORD handle, WORD FAR *cur_form));
#if HIGH_C
VOID vex_timv          _((WORD handle, FAR WORD (*tim_addr)(),
                          FAR WORD (* FAR *old_addr)(), WORD FAR *scale));
#else
VOID vex_timv          _((WORD handle, WORD (FAR *tim_addr)(),
                          WORD (FAR * FAR *old_addr)(), WORD FAR *scale));
#endif
VOID v_show_c          _((WORD handle, WORD reset));
VOID v_hide_c          _((WORD handle));
VOID vq_mouse          _((WORD handle, WORD FAR *status, WORD FAR *px,
                          WORD FAR *py));
#if HIGH_C
VOID vex_butv          _((WORD handle, FAR WORD (*usercode)(),
                          FAR WORD (* FAR *savecode)()));
VOID vex_motv          _((WORD handle, FAR WORD (*usercode)(),
                          FAR WORD (* FAR *savecode)()));
VOID vex_curv          _((WORD handle, FAR WORD (*usercode)(),
                          FAR WORD (* FAR *savecode)()));
#else
VOID vex_butv          _((WORD handle, WORD (FAR *usercode)(),
                          WORD (FAR * FAR *savcode)()));
VOID vex_motv          _((WORD handle, WORD (FAR *usercode)(),
                          WORD (FAR * FAR *savecode)()));
VOID vex_curv          _((WORD handle, WORD (FAR *usercode)(),
                          WORD (FAR * FAR *savecode)()));
#endif

VOID vq_key_s          _((WORD handle, WORD FAR *status));

/****** Inquire library ******************************************************/

VOID vq_color          _((WORD handle, WORD index, WORD set_flag,
                          WORD FAR *rgb));
VOID vq_cellarray      _((WORD handle, WORD FAR *pxyarray,
                          WORD row_length, WORD num_rows,
                          WORD FAR *el_used, WORD FAR *rows_used,
                          WORD FAR *status, WORD FAR *colarray));
VOID vql_attributes    _((WORD handle, WORD FAR *attrib));
VOID vqm_attributes    _((WORD handle, WORD FAR *attrib));
VOID vqf_attributes    _((WORD handle, WORD FAR *attrib));
VOID vqt_attributes    _((WORD handle, WORD FAR *attrib));
VOID vq_extnd          _((WORD handle, WORD owflag, WORD FAR *work_out));
VOID vqin_mode         _((WORD handle, WORD dev_type, WORD FAR *input_mode));
VOID vqt_extent        _((WORD handle, BYTE FAR *string, WORD FAR *extent));
WORD vqt_width         _((WORD handle, BYTE character, WORD FAR *cell_width,
                          WORD FAR *left_delta, WORD FAR *right_delta));
WORD vqt_name          _((WORD handle, WORD element_num, BYTE FAR *name));
VOID vqt_fontinfo      _((WORD handle, WORD FAR *minADE, WORD FAR *maxADE,
                          WORD FAR *distances, WORD FAR *maxwidth,
                          WORD FAR *effects));
WORD vqt_justified     _((WORD handle, WORD x, WORD y, BYTE FAR *string,
                          WORD length, WORD word_space, WORD char_space,
                          WORD FAR *offsets));

/****** Escape library *******************************************************/

#define O_B_BOLDFACE     '0' /* OUT-File definitions for v_alpha_text */
#define O_E_BOLDFACE     '1'
#define O_B_ITALICS      '2'
#define O_E_ITALICS      '3'
#define O_B_UNDERSCORE   '4'
#define O_E_UNDERSCORE   '5'
#define O_B_SUPERSCRIPT  '6'
#define O_E_SUPERSCRIPT  '7'
#define O_B_SUBSCRIPT    '8'
#define O_E_SUBSCRIPT    '9'
#define O_B_NLQ          'A'
#define O_E_NLQ          'B'
#define O_B_EXPANDED     'C'
#define O_E_EXPANDED     'D'
#define O_B_LIGHT        'E'
#define O_E_LIGHT        'F'
#define O_PICA           'W'
#define O_ELITE          'X'
#define O_CONDENSED      'Y'
#define O_PROPORTIONAL   'Z'

#define O_GRAPHICS       "\033\033GEM,%d,%d,%d,%d,%s"

#define MUTE_RETURN     -1 /* definitions for vs_mute */
#define MUTE_ENABLE      0
#define MUTE_DISABLE     1

#define OR_PORTRAIT      0 /* definitions for v_orient */
#define OR_LANDSCAPE     1

#define TRAY_MANUAL     -1 /* definitions fpr v_tray */
#define TRAY_DEFAULT     0
#define TRAY_FIRSTOPT    1

#define XBIT_FRACT       0 /* definitions for v_xbit_image */
#define XBIT_INTEGER     1

#define XBIT_LEFT        0
#define XBIT_CENTER      1
#define XBIT_RIGHT       2

#define XBIT_TOP         0
#define XBIT_MIDDLE      1
#define XBIT_BOTTOM      2

VOID vq_chcells        _((WORD handle, WORD FAR *rows, WORD FAR *columns));
VOID v_exit_cur        _((WORD handle));
VOID v_enter_cur       _((WORD handle));
VOID v_curup           _((WORD handle));
VOID v_curdown         _((WORD handle));
VOID v_curright        _((WORD handle));
VOID v_curleft         _((WORD handle));
VOID v_curhome         _((WORD handle));
VOID v_eeos            _((WORD handle));
VOID v_eeol            _((WORD handle));
VOID vs_curaddress     _((WORD handle, WORD row, WORD column));
VOID v_curtext         _((WORD handle, BYTE FAR *string));
VOID v_rvon            _((WORD handle));
VOID v_rvoff           _((WORD handle));
VOID vq_curaddress     _((WORD handle, WORD FAR *row, WORD FAR *column));
WORD vq_tabstatus      _((WORD handle));
VOID v_hardcopy        _((WORD handle));
VOID v_dspcur          _((WORD handle, WORD x, WORD y));
VOID v_rmcur           _((WORD handle));
VOID v_form_adv        _((WORD handle));
VOID v_output_window   _((WORD handle, WORD FAR *xyarray));
VOID v_clear_disp_list _((WORD handle));
VOID v_bit_image       _((WORD handle, BYTE FAR *filename,
                          WORD aspect, WORD x_scale, WORD y_scale,
                          WORD h_align, WORD v_align, WORD FAR *xyarray));
VOID vq_scan           _((WORD handle, WORD FAR *g_height, WORD FAR *g_slices,
                          WORD FAR *a_height, WORD FAR *a_slices,
                          WORD FAR *factor));
VOID v_alpha_text      _((WORD handle, BYTE FAR *string));
WORD vs_palette        _((WORD handle, WORD palette));
VOID v_sound           _((WORD handle, WORD frequency, WORD duration));
WORD vs_mute           _((WORD handle, WORD action));
VOID vt_resolution     _((WORD handle, WORD xres, WORD yres,
                          WORD FAR *xset, WORD FAR *yset));
VOID vt_axis           _((WORD handle, WORD xres, WORD yres,
                          WORD FAR *xset, WORD FAR *yset));
VOID vt_origin         _((WORD handle, WORD xorigin, WORD yorigin));
VOID vq_tdimensions    _((WORD handle, WORD FAR *xdimension,
                          WORD FAR *ydimension));
VOID vt_alignment      _((WORD handle, WORD dx, WORD dy));
VOID vsp_film          _((WORD handle, WORD index, WORD lightness));
WORD vqp_filmname      _((WORD handle, WORD index, BYTE FAR *name));
VOID vsc_expose        _((WORD handle, WORD state));
VOID v_meta_extents    _((WORD handle, WORD min_x, WORD min_y,
                          WORD max_x, WORD max_y));
VOID v_write_meta      _((WORD handle, WORD num_intin, WORD FAR *intin,
                          WORD num_ptsin, WORD FAR *ptsin));
VOID vm_filename       _((WORD handle, BYTE FAR *filename));

#if GEM & (GEM3 | XGEM)
VOID vm_pagesize       _((WORD handle, WORD pgwidth, WORD pgheight));
VOID vm_coords         _((WORD handle, WORD llx, WORD lly,
                          WORD urx, WORD ury));
VOID v_copies          _((WORD handle, WORD count));
VOID v_orient          _((WORD handle, WORD orientation));
VOID v_tray            _((WORD handle, WORD tray));
WORD v_xbit_image      _((WORD handle, BYTE FAR *filename, WORD aspect,
                          WORD x_scale, WORD y_scale,
                          WORD h_align, WORD v_align, WORD rotate,
                          WORD background, WORD foreground, WORD FAR *xy));
#endif

VOID vs_bkcolor        _((WORD handle, WORD color));
VOID v_setrgbi         _((WORD handle, WORD primtype, WORD r, WORD g, WORD b,
                          WORD i));
VOID v_topbot          _((WORD handle, WORD height,
                          WORD FAR *char_width, WORD FAR *char_height,
                          WORD FAR *cell_width, WORD FAR *cell_height));
VOID v_ps_halftone     _((WORD handle, WORD index, WORD angle,
                          WORD frequency));

#if GEM & GEM1
VOID vqp_films         _((WORD handle, BYTE FAR *film_names));
VOID vqp_state         _((WORD handle, WORD FAR *port, BYTE FAR *film_name,
                          WORD FAR *lightness, WORD FAR *interlace,
                          WORD FAR *planes, WORD FAR *indexes));
VOID vsp_state         _((WORD handle, WORD port, WORD film_num,
                          WORD lightness, WORD interlace, WORD planes,
                          WORD FAR *indexes));
VOID vsp_save          _((WORD handle));
VOID vsp_message       _((WORD handle));
WORD vqp_error         _((WORD handle));

VOID v_offset          _((WORD handle, WORD offset));
VOID v_fontinit        _((WORD handle, WORD fh_high, WORD fh_low));
VOID v_escape2000      _((WORD times));
WORD vq_gdos           _((VOID));
#endif /* GEM1 */

/*****************************************************************************/

#endif /* __VDI__ */
