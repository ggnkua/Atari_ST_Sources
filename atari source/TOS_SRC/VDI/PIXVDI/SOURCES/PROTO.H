#include	"portab.h"
#include	"scrndev.h"

/* INIT.C */
VOID	init_st_tt_sp( VOID );
VOID InitST( VOID );
VOID InitTT( VOID );
VOID InitSTSpLut( VOID );
VOID Init16Pal( VOID );
VOID Init32Pal( VOID );
VOID InitColReqArray( VOID );
VOID InitTTLut( VOID );

/* ISIN.C */
WORD Isin( REG WORD ang);
WORD Icos( WORD ang ); 

/* JMPTBL.C */
VOID SCREEN( VOID );

/* MONOBJ.C */
VOID vsl_type( VOID );
VOID vsl_width( VOID );
VOID vsl_ends( VOID );	
VOID vsl_color( VOID );
VOID vsm_height( VOID );
VOID vsm_type( VOID );
VOID vsm_color( VOID );
VOID vsf_interior( VOID );
VOID vsf_style( VOID );
VOID vsf_color( VOID );
VOID v_locator( VOID );
VOID v_show_c( VOID );
VOID v_hide_c( VOID );
VOID v_valuator( VOID );
VOID v_choice( VOID );
VOID v_string( VOID );
VOID vq_key_s( VOID );
VOID vswr_mode( VOID );
VOID vsin_mode( VOID );
VOID vqi_mode( VOID );
VOID vsf_perimeter( VOID );
VOID vsl_udsty( VOID );
VOID s_clip( VOID );
VOID arb_corner( WORD *corners,WORD *type );
VOID dro_cpyfm( VOID );
VOID drt_cpyfm( VOID );
VOID dr_trn_fm( VOID );
VOID dr_recfl( VOID );

/* MONOUT.C */
VOID vq_extnd( VOID );
VOID v_clswk( VOID );
VOID v_pline( VOID );
VOID v_pmarker( VOID );
VOID v_fillarea( VOID );
VOID v_gdp( VOID );
VOID vql_attr( VOID );
VOID vqm_attr( VOID );
VOID vqf_attr( VOID );
VOID pline( VOID );
WORD clip_line( VOID );
WORD code( WORD x,WORD y );
VOID plygn( VOID );
VOID gdp_rbox( VOID );
VOID gdp_arc( VOID );
VOID clc_nsteps( VOID );
VOID gdp_ell( VOID );
VOID clc_arc( VOID );
VOID Calc_pts( WORD j ); 
VOID st_fl_ptr( VOID );
VOID cir_dda( VOID );
VOID wline( VOID );
VOID perp_off( WORD *px,WORD *py);
VOID quad_xform( int quad,int x,int y,int *tx,int *ty );
VOID do_circ( WORD cx, WORD cy );
VOID s_fa_attr( VOID );
VOID r_fa_attr( VOID );
VOID do_arrow( VOID );
VOID arrow( WORD *xy,WORD inc );
VOID init_wk( VOID );
VOID d_opnvwk( VOID );
VOID d_clsvwk( VOID );
VOID dsf_udpat( VOID );
VOID vq_color( VOID );
VOID vs_color( VOID );

/* OPNWK.C */
VOID v_opnwk( VOID );
SCREENDEF *FindDevice( WORD devId );
VOID SetCurDevice( WORD curRez );
VOID InitFonts( VOID );
VOID InitDevTabInqTab( VOID );

/* SEEDFILL.C */
VOID d_contourfill( VOID );
VOID seedfill( VOID );
VOID crunch_Q( VOID );
WORD get_seed( REG WORD xin,REG WORD yin,REG WORD *xleftout,
	REG WORD *xrightout,BOOLEAN *collide );
VOID v_get_pixel( VOID );

/* SPCOLOR.C */
VOID sp_vs_color( VOID );
VOID sp_vq_color( VOID );

/* TEXT.C */
VOID d_gtext( VOID );
VOID text_init( VOID );
VOID dst_height( VOID );
VOID copy_name( BYTE *source,BYTE *dest );
VOID make_header( VOID );
VOID dst_point( VOID );
VOID dst_style( VOID );
VOID dst_alignment( VOID );
VOID dst_rotation( VOID );
VOID dst_font( VOID );
VOID dst_color( VOID );
VOID dqt_attributes( VOID );
VOID dqt_extent( VOID );
VOID dqt_width( VOID );
VOID dqt_name( VOID );
VOID dqt_fontinfo( VOID );
VOID d_justified( VOID );
VOID dt_loadfont( VOID );
VOID dt_unloadfont( VOID );

/* TRUCOLOR.C */
VOID vs_32_color( VOID );
VOID vq_32_color( VOID );
VOID vs_16_color( VOID );
VOID vq_16_color( VOID );

/* TTCOLOR.C */
VOID tt_vs_color( VOID );
VOID tt_vq_color( VOID );
