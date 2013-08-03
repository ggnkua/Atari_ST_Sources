#include "fontdef.h"
#include "attrdef.h"

EXTERN	struct attribute virt_work;	/* Virtual workstation attributes */
EXTERN	struct attribute *cur_work;	/* Pointer to current works attr. */

EXTERN WORD DDA_INC;			/* the fraction to be added to the DDA */
EXTERN WORD T_SCLSTS;			/* 0 if scale down, 1 if enlarge */

extern	WORD	FLIP_Y;			/* True if magnitudes being returned */
extern	WORD	MONO_STATUS;		/* True if current font monospaced */

EXTERN	BYTE	deftxbuf[];		/* Default text scratch buffer */
extern	WORD	scrtsiz;		/* Default offset to large text buffer */

extern	WORD	scrpt2;			/* Offset to large text buffer */
extern	BYTE	*scrtchp;		/* Pointer to text scratch buffer */

extern	WORD	ini_font_count;		/* Number of fonts in driver */

EXTERN	struct font_head first;		/* The small system font */

EXTERN	struct font_head *cur_font;	/* Current font */
EXTERN	struct font_head *def_font;	/* Default font from open workstation */

EXTERN	struct font_head *font_ring[];	/* Ring of available fonts */

extern	WORD	h_align;		/* Text horizontal alignment */
extern	WORD	v_align;		/* Text vertical alignment */
extern	WORD	STYLE;			/* Requested text special effects */
extern	WORD	DOUBLE;			/* True if current font scaled */
extern	WORD	CHUP;			/* Text baseline vector */

extern	WORD	line_cw;		/* Linewidth for current circle */
extern	WORD	num_qc_lines, q_circle[];

extern	WORD	val_mode,chc_mode,loc_mode,str_mode;

/* filled area variables */

extern	WORD	y,odeltay,deltay,deltay1,deltay2;
extern	WORD	fill_miny,fill_maxy;
extern	WORD	fil_intersect;
extern	WORD	fill_buffer[];
extern	WORD	*patptr, patmsk;
extern	WORD	multifill;

/* gdp area variables */

extern	WORD	xc, yc, xrad, yrad, del_ang, beg_ang, end_ang;
extern	WORD	start, angle, n_steps;

/* attribute environment save variables */

extern	WORD	s_fill_per, *s_patptr, s_patmsk;
extern	WORD	s_begsty, s_endsty, s_fil_col;

extern  WORD	CLIP, XMN_CLIP, XMX_CLIP, YMN_CLIP, YMX_CLIP;
extern	WORD	LINE_STYL[];
extern	WORD 	DITHER[];
extern	WORD	HATCH0[],HATCH1[],OEMPAT[];
extern	WORD	ROM_UD_PATRN[];
extern	WORD	SOLID;
extern	WORD	HOLLOW;
extern	WORD	HAT_0_MSK, HAT_1_MSK;
extern	WORD	DITHRMSK, OEMMSKPAT;

extern 	WORD	DEV_TAB[];	/* initial intout array for open workstation*/
extern 	WORD	SIZ_TAB[];	/* initial ptsout array for open workstation*/
extern	WORD	INQ_TAB[];	/* extended inquire values */

extern 	WORD	*CONTRL,*INTIN,*PTSIN,*INTOUT,*PTSOUT;

extern	WORD	FG_BP_1,FG_BP_2,FG_BP_3,FG_BP_4;

extern	WORD	LN_MASK,LSTLIN;
extern	WORD	HIDE_CNT;
extern	WORD	MOUSE_BT;
extern	WORD	WRT_MODE;
extern	WORD	REQ_COL[3][MAX_COLOR];
extern	WORD	MAP_COL[], REV_MAP_COL[];
extern	WORD	X1,Y1,X2,Y2;
extern	WORD	GCURX,GCURY,TERM_CH;

/* Bit-Blt variables */

EXTERN WORD	COPYTRAN;

/* Assembly Language Support Routines */

extern	VOID	ABLINE(),HABLINE(),CLEARMEM();
extern	VOID	CHK_ESC(),INIT_G(),DINIT_G();
extern	VOID	CLC_FLIT();
extern	WORD    SMUL_DIV();

/* Assembly Language Support Routines NEWLY ADDED */

extern  VOID    GSHIFT_S(), st_fl_p(), DIS_CUR(), GCHC_KEY();
extern  VOID    HIDE_CU(), GLOC_KEY(), GCHR_KEY(), TEXT_BLT();
extern  VOID    XFM_CRFM(), XFM_UNDL(), COPY_RFM(), VEX_CURV();
extern  VOID    VEX_BUTV(), VEX_MOTV(), RECTFILL();


/* C Support routines */

extern	WORD 	isin();
extern	WORD 	icos();
extern  WORD	text_init();
extern  WORD    screen();

/* C Support routines */

extern  WORD    VEC_LEN();
