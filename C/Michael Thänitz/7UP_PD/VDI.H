/*      VDI.H

        GEM VDI Definitions

        Copyright (c) Borland International 1990
        All Rights Reserved.
*/


#if  !defined( __VDI__ )
#define __VDI__

#include <vdilib.h>
/*
typedef struct
{
    int    contrl[12];
    int    intin[132];
    int    intout[140];
    int    ptsin[145];
    int    ptsout[145];
} VDIPARBLK;

extern  VDIPARBLK _VDIParBlk;
void  _VdiCtrl(int handle, int fkt, GEMPARBLK *_GemParBlk);
*/
/****** Control definitions *********************************************/

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

void v_get_driver_info _((int device_id, int info_select,
                          char *info_string));
void    v_opnwk( int *work_in,  int *handle, int *work_out);
void    v_clswk( int handle );
void    v_opnvwk( int *work_in, int *handle, int *work_out);
void    v_clsvwk( int handle );
void    v_clrwk( int handle );
void    v_updwk( int handle );
int             vst_load_fonts( int handle, int select );
void    vst_unload_fonts( int handle, int select );
void    vs_clip( int handle, int clip_flag, int *pxyarray );


/****** Output definitions **********************************************/

void    v_pline( int handle, int count, int *pxyarray );
void    v_pmarker( int handle, int count, int *pxyarray );
void    v_gtext( int handle, int x, int y, char *string );
void    v_fillarea( int handle, int count, int *pxyarray );
void    v_cellarray( int handle, int *pxyarray, int row_length,
                     int el_used, int num_rows, int wrt_mode,
                     int *colarray );
void    v_contourfill( int handle, int x, int y, int index );
void    vr_recfl( int handle, int *pxyarray );
void    v_bar( int handle, int *pxyarray );
void    v_arc( int handle, int x, int y, int radius,
               int begang, int endang );
void    v_pieslice( int handle, int x, int y, int radius,
                    int begang, int endang );
void    v_circle( int handle, int x, int y, int radius );
void    v_ellarc( int handle, int x, int y, int xradius,
                  int yradius, int begang, int endang );
void    v_ellpie( int handle, int x, int y, int xradius,
                  int yradius, int begang, int endang );
void    v_ellipse( int handle, int x, int y, int xradius,
                   int yradius  );
void    v_rbox  ( int handle, int *pxyarray );
void    v_rfbox ( int handle, int *pxyarray );
void    v_justified( int handle,int x, int y, char *string,
                     int length, int word_space,
                     int char_space );


/****** Attribute definitions *****************************************/

#define IP_HOLLOW       0
#define IP_1PATT        1
#define IP_2PATT        2
#define IP_3PATT        3
#define IP_4PATT        4
#define IP_5PATT        5
#define IP_6PATT        6
#define IP_SOLID        7


/* gsx modes */

#define MD_REPLACE      1
#define MD_TRANS        2
#define MD_XOR          3
#define MD_ERASE        4


/* gsx styles */

#define FIS_HOLLOW      0
#define FIS_SOLID       1
#define FIS_PATTERN     2
#define FIS_HATCH       3
#define FIS_USER        4


/* bit blt rules */

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

/* linetypes */

#define SOLID           1
#define LONGDASH        2
#define DOT             3
#define DASHDOT         4
#define DASH            5
#define DASH2DOT        6
#define USERLINE        7

#define SQUARED         0
#define ARROWED         1
#define ROUND           2

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

int     vswr_mode( int handle, int mode );
void    vs_color( int handle, int index, int *rgb_in );
int     vsl_type( int handle, int style );
void    vsl_udsty( int handle, int pattern );
int     vsl_width( int handle, int width );
int     vsl_color( int handle, int color_index );
void    vsl_ends( int handle, int beg_style, int end_style );
int     vsm_type( int handle, int symbol );
int     vsm_height( int handle, int height );
int     vsm_color( int handle, int color_index );
void    vst_height( int handle, int height, int *char_width,
                    int *char_height, int *cell_width,
                    int *cell_height );
int     vst_point( int handle, int point, int *char_width,
                    int *char_height, int *cell_width,
                    int *cell_height );
int     vst_rotation( int handle, int angle );
int     vst_font( int handle, int font );
int     vst_color( int handle, int color_index );
int     vst_effects( int handle, int effect );
void    vst_alignment( int handle, int hor_in, int vert_in,
                       int *hor_out, int *vert_out );
int     vsf_interior( int handle, int style );
int     vsf_style( int handle, int style_index );
int     vsf_color( int handle, int color_index );
int     vsf_perimeter( int handle, int per_vis );
void    vsf_udpat( int handle, int *pfill_pat, int planes );


/****** Raster definitions *********************************************/

typedef struct memform
{
  void *mp;
  int fwp;
  int fh;
  int fww;
  int ff;
  int np;
  int r1;
  int r2;
  int r3;
} FDB;

typedef struct
{
        void            *fd_addr;
        int             fd_w;
        int             fd_h;
        int             fd_wdwidth;
        int             fd_stand;
        int             fd_nplanes;
        int             fd_r1;
        int             fd_r2;
        int             fd_r3;
} MFDB;

void    vro_cpyfm( int handle, int vr_mode, int *pxyarray,
                   MFDB *psrcMFDB, MFDB *pdesMFDB );
void    vrt_cpyfm( int handle, int vr_mode, int *pxyarray,
                   MFDB *psrcMFDB, MFDB *pdesMFDB,
                   int *color_index );
void    vr_trnfm( int handle, MFDB *psrcMFDB, MFDB *pdesMFDB );
void    v_get_pixel( int handle, int x, int y, int *pel,
                     int *index );


/****** Input definitions **********************************************/
#define DEV_LOCATOR      1 /* input device */
#define DEV_VALUATOR     2
#define DEV_CHOICE       3
#define DEV_STRING       4

#define MODE_REQUEST     1 /* input mode */
#define MODE_SAMPLE      2

void    vsin_mode( int handle, int dev_type, int mode );
void    vrq_locator( int handle, int x, int y, int *xout,
                     int *yout, int *term );
int     vsm_locator( int handle, int x, int y, int *xout,
                     int *yout, int *term );
void    vrq_valuator( int handle, int valuator_in,
                      int *valuator_out, int *terminator );
void    vsm_valuator( int handle, int val_in, int *val_out,
                      int *term, int *status );
void    vrq_choice( int handle, int ch_in, int *ch_out );
int     vsm_choice( int handle, int *choice );
void    vrq_string( int handle, int max_length, int echo_mode,
                    int *echo_xy, char *string );
int     vsm_string( int handle, int max_length, int echo_mode,
                    int *echo_xy, char *string );
void    vsc_form( int handle, int *pcur_form );
void    vex_timv( int handle, int (*tim_addr)(), int (**otim_addr)(),
                  int *tim_conv );
void    v_show_c( int handle, int reset );
void    v_hide_c( int handle );
void    vq_mouse( int handle, int *pstatus, int *x, int *y );
void    vex_butv( int handle, int (*pusrcode)(), int (**psavcode)() );
void    vex_motv( int handle, int (*pusrcode)(), int (**psavcode)() );
void    vex_curv( int handle, int (*pusrcode)(), int (**psavcode)() );
void    vq_key_s( int handle, int *pstatus );


/****** Inquire definitions *******************************************/

void    vq_extnd( int handle, int owflag, int *work_out );
int     vq_color( int handle, int color_index,
                  int set_flag, int *rgb );
void    vql_attributes( int handle, int *attrib );
void    vqm_attributes( int handle, int *attrib );
void    vqf_attributes( int handle, int *attrib );
void    vqt_attributes( int handle, int *attrib );
void    vqt_extent( int handle, char *string, int *extent );
int     vqt_width( int handle, char character,
                   int *cell_width, int *left_delta,
                   int *right_delta );
int     vqt_name( int handle, int element_num, char *name );
void    vq_cellarray( int handle, int *pxyarray,
                      int row_length, int num_rows,
                      int *el_used, int *rows_used,
                      int *status, int *colarray );
void    vqin_mode( int handle, int dew_type, int *input_mode );
void    vqt_fontinfo( int handle, int *minADE, int *maxADE,
                      int *distances, int *maxwidth,
                      int *effects );


/****** Escape definitions *********************************************/

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

#define TRAY_MANUAL     -1 /* definitions for v_tray */
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

void    vq_chcells( int handle, int *rows, int *columns );
void    v_exit_cur( int handle );
void    v_enter_cur( int handle );
void    v_curup( int handle );
void    v_curdown( int handle );
void    v_curright( int handle );
void    v_curleft( int handle );
void    v_curhome( int handle );
void    v_eeos( int handle );
void    v_eeol( int handle );
void    vs_curaddress( int handle, int row, int column );
void    v_curaddress( int handle, int row, int column );
void    v_curtext( int handle, char *string );
void    v_rvon( int handle );
void    v_rvoff( int handle );
void    vq_curaddress( int handle, int *row, int *column );
int     vq_tabstatus( int handle );
void    v_hardcopy( int handle );
void    v_dspcur( int handle, int x, int y );
void    v_rmcur( int handle );
void    v_form_adv( int handle );
void    v_output_window( int handle, int *xyarray );
void    v_clear_disp_list( int handle );
void    v_bit_image( int handle, const char *filename,
                     int aspect, int x_scale, int y_scale,
                     int h_align, int v_align, int *xyarray );
void    vq_scan( int handle, int *g_slice, int *g_page,
                 int *a_slice, int *a_page, int *div_fac);
void    v_alpha_text( int handle, char *string );
void    vs_palette( int handle, int palette );
void	v_sound( int handle, int frequency, int duration );
int		vs_mute( int handle, int action );
void    vqp_films( int handle, char *film_names );
void    vqp_state( int handle, int *port, char *film_name,
                   int *lightness, int *interlace,
                   int *planes, int *indexes );
void    vsp_state( int handle, int port, int film_num,
                   int lightness, int interlace, int planes,
                   int *indexes );
void    vsp_save( int handle );
void    vsp_message( int handle );
int     vqp_error( int handle );
void    v_meta_extents( int handle, int min_x, int min_y,
                        int max_x, int max_y );
void    v_write_meta( int handle,
                      int num_intin, int *intin,
                      int num_ptsin, int *ptsin );
void    vm_coords( int handle, int llx, int lly, int urx, int ury );
void    vm_filename( int handle, const char *filename );
void    vm_pagesize( int handle, int pgwidth, int pdheight );
void    v_offset( int handle, int offset );
void    v_fontinit( int handle, int fh_high, int fh_low );
void    v_escape2000( int handle, int times );

void    vt_resolution( int handle, int xres, int yres,
                       int *xset, int *yset );
void    vt_axis( int handle, int xres, int yres,
                 int *xset, int *yset );
void    vt_origin( int handle, int xorigin, int yorigin );
void    vq_tdimensions( int handle, int *xdimension, int *ydimension );
void    vt_alignment( int handle, int dx, int dy );
void    vsp_film( int handle, int index, int lightness );
void    vsc_expose( int handle, int state );


#define GDOS_NONE      -2L            /* no GDOS installed           */
#define GDOS_FSM       0x5F46534DL    /* '_FSM' - FSMGDOS installed  */
#define GDOS_FNT       0x5F464E54L    /* '_FNT' - FONTGDOS installed */

int     vq_gdos( void );
long    vq_vgdos( void );

int     v_bez_on( int handle );
void    v_bez_off( int handle );
void    v_set_app_buff( int handle, int **address, int nparagraphs );
void    v_bez( int handle, int count, int *xyarr,
                char *bezarr, int *extent, int *totpts, int *totmoves );
void    v_bez_fill( int handle, int count, int *xyarr,
                     char *bezarr, int *extent, int *totpts,
                     int *totmoves );
int     v_bez_qual( int handle, int prcnt, int *actual );


/****** FSMGDOS definitions ********************************************/

typedef struct
{
    int    value;
    int    remainder;

}   fsm_int;

typedef struct
{
    fsm_int    x;
    fsm_int    y;

}   fsm_fpoint_t;

typedef struct
{
    fsm_fpoint_t     pt;
    fsm_fpoint_t     cpt;
    fsm_int          sharp;

}   fsm_data_fpoint_t;

typedef struct fsm_component_t
{
    int                       resevered1;
    struct fsm_component_t    *nextComponent;
    unsigned char             numPoints;
    unsigned char             numCurves;
    unsigned char             numContours;
    unsigned char             reserved2[13];
    fsm_data_fpoint_t         *points;
    unsigned char             *startPts;

}   fsm_component_t;


void    vqt_f_extent( int handle, char *string, int *extent );
void    v_ftext( int handle, int x, int y, char *string );
void    v_killoutline( int handle, fsm_component_t *component );
void    v_getoutline( int handle, int ch, fsm_component_t **component );
void    vst_scratch( int handle, int mode );
void    vst_error( int handle, int mode, int *errorvar );
void    vqt_advance( int handle, int ch, int *advx, int *advy,
                       int *remx, int *remy );
int     vst_arbpt( int handle, int point, int *chwd, int *chht,
                   int *cellwd, int *cellht );
void    vqt_devinfo( int handle, int devnum, int *devexits,
                     char *devstr );
int     v_flushcache( int handle );
void    vqt_cachesize( int handle, int which_cache, long *size );
void    vqt_get_tables( int handle, int **gascii, int **sytle );
int     v_loadcache( int handle, char *filename, int mode );
int     v_savecache( int handle, char *filename );
int     vst_setsize( int handle, int point, int *chwd, int *chht,
                     int *cellwd, int *cellht );
int     vst_skew( int handle, int skew );


#endif

/***********************************************************************/
