/*
 * linea.h - vdi primitives interface file
 *
 * Started 31/8/89 Alex G. Kiernan
 *
 * Copyright (c) 1989 HiSoft
 */

#ifndef _LINEA_H
#define _LINEA_H

typedef struct la_data
{
	short ld_vplanes;	/* number of video planes */
	short ld_vwrap;		/* number of bytes/video line */
	short *ld_contrl;	/* pointer to CONTRL array */
	short *ld_intin;	/* pointer to INTIN array */
	short *ld_ptsin;	/* pointer to PTSIN array */
	short *ld_intout;	/* pointer to INTOUT array */
	short *ld_ptsout;	/* pointer to PTSOUT array */
	short ld_colbit[4];	/* colour bit-plane[i] value */
	short ld_lstlin;	/* plot last pixel flag */
	short ld_lnmask;	/* line-style mask */
	short ld_wmode;		/* writing mode 0:replace, 1:transparent,
						   2:exclusive OR, 3:inverse transparent */
	short ld_x1;		/* X1 coordinate */
	short ld_y1;		/* Y1 coordinate */
	short ld_x2;		/* X2 coordinate */
	short ld_y2;		/* Y2 coordinate */
	short *ld_patptr;	/* fill pattern pointer */
	short ld_patmsk;	/* fill pattern mask */
	short ld_mfill;		/* multi-plane fill flag */
	short ld_clip;		/* clipping flag */
	short ld_xmincl;	/* minimum X clipping value */
	short ld_ymincl;	/* minimum Y clipping value */
	short ld_xmaxcl;	/* maximum X clipping value */
	short ld_ymaxcl;	/* maximum Y clipping value */
	short ld_xdda;		/* accumulator for textblt dda */
	short ld_ddainc;	/* fixed point scale factor */
	short ld_scaldir;	/* scale direction flag */
	short ld_mono;		/* current font is monospaced */
	short ld_srcx;		/* X coord of character in font */
	short ld_srcy;		/* Y coord of character in font */
	short ld_dstx;		/* X coord of character on screen */
	short ld_dsty;		/* Y coord of character on screen */
	short ld_delx;		/* width of character */
	short ld_dely;		/* height of character */
	void *ld_fbase;		/* pointer to start of font form */
	short ld_fwidth;	/* width of font form */
	short ld_style;		/* textblt special effects flags */
	short ld_litemsk;	/* lightening mask */
	short ld_skewmsk;	/* skewing mask */
	short ld_weight;	/* thickening factor */
	short ld_roff;		/* skew offset above baseline */
	short ld_loff;		/* skew offset below baseline */
	short ld_scale;		/* scaling flag */
	short ld_chup;		/* character rotation vector */
	short ld_textfg;	/* text foreground colour */
	void *ld_scrtchp;	/* text special effects buffer */
	short ld_scrpt2;	/* offset to scaling buffer from above */
	short ld_textbg;	/* text background colour */
	short ld_copytran;	/* copy raster form type flag */
	int (*ld_seedabort)(void);	/* seedfill end detect function */
} LA_DATA;

typedef struct la_font
{
	short font_id;				/* face identifier */
	short font_size;			/* font size in points */
	char font_name[32];			/* face name */
	short font_low_ade;			/* lowest ASCII value in face */
	short font_hi_ade;			/* highest ASCII value in face */
	short font_top_dst;			/* top line distance */
	short font_ascent_dst;		/* ascent line distance */
	short font_half_dst;		/* half line distance */
	short font_descent_dst;		/* descent line distance */
	short font_bottom_dist;		/* bottom line distance */
	short font_fatest;			/* width of widest char in font */
	short font_fat_cell;		/* width of widest char cell in font */
	short font_left_off;		/* left offset */
	short font_right_off;		/* right offset */
	short font_thickening; 		/* no. of pixels to widen chars */
	short font_underline;		/* width in pixels of underline */
	short font_lightening; 		/* mask used to drop pixels out */
	short font_skewing;			/* mask used to determine skewing */
	short font_flags;			/* font flags */
	short *font_horiz_off; 		/* pointer to horizontal offset table */
	short *font_char_off;		/* pointer to char offset table */
	void *font_data;			/* pointer to font data */
	short font_width;			/* font width */
	short font_height;			/* font height */
	struct la_font *font_next;	/* pointer to next font */
} LA_FONT;

typedef struct la_ext
{
	long ld_resvd1;
	struct la_font *ld_cur_font;	/* pointer to current font header */
	short ld_resvd2[23];
	short ld_m_pos_hx;				/* mouse x hot spot */
	short ld_m_pos_hy;				/* mouse y hot spot */
	short ld_m_planes;				/* writing mode for mouse */
	short ld_m_cdb_bg;				/* mouse background colour */
	short ld_m_cdb_fg;				/* mouse foreground colour */
	short ld_mask_form[32];			/* mouse mask and form */
	short ld_inq_tab[45];			/* vq_extnd information */
	short ld_dev_tab[45];			/* v_opnwk information */
	short ld_gcurx;					/* current mouse x position */
	short ld_gcury;					/* current mouse x position */
	short ld_m_hid_ct;				/* mouse hide count */
	short ld_mouse_bt;				/* mouse button status */
	short ld_req_col[3][16];		/* internal vq_color lookup */
	short ld_siz_tab[15];			/* current text, line and marker sizes */
	short ld_resvd3;
	short ld_resvd4;
	short *ld_cur_work;				/* current vwork attributes */
	struct la_font *ld_def_font;	/* default font header */
	struct la_font *ld_font_ring[4];/* vdi font ring */
	short ld_font_count;			/* number of fonts in font ring */
	short ld_resvd5[45];
	unsigned char ld_cur_ms_stat;	/* mouse status */
	char ld_resvd6;
	short ld_v_hid_cnt;				/* cursor hide count */
	short ld_cur_x;					/* mouse x position */
	short ld_cur_y;					/* mouse y position */
	char ld_cur_flag;				/* mouse draw status */
	char ld_mouse_flag;				/* mouse processing enabled */
	long ld_resvd7;
	short ld_v_sav_xy[2];			/* saved cursor xy position */
	short ld_save_len;				/* height of saved form */
	short *ld_save_addr;			/* screen address of saved form */
	short ld_save_stat;				/* save status */
	long ld_save_area[4][16];		/* form save area */
	void (*ld_user_tim)();			/* user timer vector */
	void (*ld_next_tim)();			/* next timer vector */
	void (*ld_user_but)();			/* user button vector */
	void (*ld_user_cur)();			/* user cursor vector */
	void (*ld_user_mot)();			/* user motion vector */
	short ld_cel_ht;				/* cell height */
	short ld_cel_mx;				/* max x cells */
	short ld_cel_my;				/* max y cells */
	short ld_cel_wr;				/* displacement to next vertical cell */
	short ld_col_bg;				/* background colour index */
	short ld_col_fg;				/* foreground colour index */
	void *ld_cur_ad;				/* cursor address */
	short ld_cur_off;				/* offset to first cell */
	short ld_cur_xy[2];				/* cursor xy position */
	char ld_cur_cnt;				/* cursor flash period */
	char ld_cur_tim;				/* cursor flash countdown */
	void *ld_fnt_ad;				/* address of font data */
	short ld_fnt_nd;				/* last ade in font */
	short ld_fnt_st;				/* first ade in font */
	short ld_fnt_wr;				/* font form width */
	short ld_x_max;					/* horizontal pixel resolution */
	void *ld_off_ad;				/* pointer to font offset table */
	short ld_status;				/* cursor status */
	short ld_y_max;					/* vertical pixel resolution */
	short ld_bytes_lin;				/* width of destination form */
} LA_EXT;

typedef struct la_blk
{
	short bl_xmin;	/* minimum x */
	short bl_ymin;	/* minimum y */
	short *bl_form;	/* word aligned memory form */
	short bl_nxwd;	/* offset to next word in line */
	short bl_nxln;	/* offset to next line in plane */
	short bl_nxpl;	/* offset to next plane */
} LA_BLK;

typedef struct la_blit
{
	short bb_b_wd;		/* width of block in pixels */
	short bb_b_ht;		/* height of block in pixels */
	short bb_plane_ct;	/* number of planes to blit */
	short bb_fg_col;	/* foreground colour */
	short bb_bg_col;	/* background colour */
	char bb_op_tab[4];	/* Logic for fg x bg combination */
	struct la_blk bb_s;	/* source info block */
	struct la_blk bb_d;	/* destination info block */
	short *bb_p_addr;	/* pattern buffer address */
	short bb_p_nxln;	/* offset to next line in pattern */
	short bb_p_nxpl;	/* offset to next plane in pattern */
	short bb_p_mask;	/* pattern index mask */
	char bb_fill[24];	/* work space */
} LA_BLIT;

typedef struct la_sprite
{
	short ls_xhot;		/* X hot spot offset */
	short ls_yhot;		/* Y hot spot offset */
	short ls_form;		/* 1 for VDI, -1 for XOR */
	short ls_bgcol;		/* background colour index */
	short ls_fgcol;		/* foreground colour index */
	short ls_image[32];	/* background/foreground interleaved image */
} LA_SPRITE;

/* Lattice 3 flavour */
typedef struct linea_info
{
	long li_d0;				/* linea data structure pointer */
	struct la_data *li_a0;	/* linea data structure pointer */
	struct la_font **li_a1;	/* system font vector */
	long (*li_a2)();		/* linea function vector */
} LINEA_INFO;

extern struct linea_info la_info;

/* Mark Williams flavour */
struct linea_init
{
	long li_d0;				/* linea data structure pointer */
	struct la_data *li_a0;	/* linea data structure pointer */
	struct la_font **li_a1;	/* system font vector */
	long (*li_a2)();		/* linea function vector */
};

extern struct linea_init la_init;

/* Lattice 3 compatability macros */
#define VPLANES	la_info.li_a0->ld_vplanes
#define VWRAP	la_info.li_a0->ld_vwrap
#define CONTRL	la_info.li_a0->ld_contrl
#define INTIN	la_info.li_a0->ld_intin
#define PTSIN	la_info.li_a0->ld_ptsin
#define INTOUT	la_info.li_a0->ld_intout
#define PTSOUT	la_info.li_a0->ld_ptsout
#define COLBIT0	la_info.li_a0->ld_colbit[0]
#define COLBIT1	la_info.li_a0->ld_colbit[1]
#define COLBIT2	la_info.li_a0->ld_colbit[2]
#define COLBIT3	la_info.li_a0->ld_colbit[3]
#define LSTLIN	la_info.li_a0->ld_lstlin
#define LNMASK	la_info.li_a0->ld_lnmask
#define WMODE	la_info.li_a0->ld_wmode
#define X1		la_info.li_a0->ld_x1
#define Y1		la_info.li_a0->ld_y1
#define X2		la_info.li_a0->ld_x2
#define Y2		la_info.li_a0->ld_y2
#define PATPTR	la_info.li_a0->ld_patptr
#define PATMSK	la_info.li_a0->ld_patmsk
#define MFILL	la_info.li_a0->ld_mfill
#define CLIP	la_info.li_a0->ld_clip
#define XMINCL	la_info.li_a0->ld_xmincl
#define YMINCL	la_info.li_a0->ld_ymincl
#define XMAXCL	la_info.li_a0->ld_xmaxcl
#define YMAXCL	la_info.li_a0->ld_ymaxcl
#define XDDA	la_info.li_a0->ld_xdda
#define DDAINC	la_info.li_a0->ld_ddainc
#define SCALDIR	la_info.li_a0->ld_scaldir
#define MONO	la_info.li_a0->ld_mono
#define SRCX	la_info.li_a0->ld_srcx
#define SRCY	la_info.li_a0->ld_srcy
#define DSTX	la_info.li_a0->ld_dstx
#define DSTY	la_info.li_a0->ld_dsty
#define DELX	la_info.li_a0->ld_delx
#define DELY	la_info.li_a0->ld_dely
#define FBASE	la_info.li_a0->ld_fbase
#define FWIDTH	la_info.li_a0->ld_fwidth
#define STYLE	la_info.li_a0->ld_style
#define LITEMSK	la_info.li_a0->ld_litemsk
#define SKEWMSK	la_info.li_a0->ld_skewmsk
#define WEIGHT	la_info.li_a0->ld_weight
#define ROFF	la_info.li_a0->ld_roff
#define LOFF	la_info.li_a0->ld_loff
#define SCALE	la_info.li_a0->ld_scale
#define CHUP	la_info.li_a0->ld_chup
#define TEXTFG	la_info.li_a0->ld_textfg
#define SCRTCHP	la_info.li_a0->ld_scrtchp
#define SCRPT2	la_info.li_a0->ld_scrpt2
#define TEXTBG	la_info.li_a0->ld_textbg
#define COPYTRAN	la_info.li_a0->ld_copytran
#define SEEDABORT	la_info.li_a0->ld_seedabort

#define V_CUR_FONT	((LA_EXT *)la_info.li_a0-1)->ld_cur_font
#define V_M_POS_HX	((LA_EXT *)la_info.li_a0-1)->ld_m_pos_hx
#define V_M_POS_HY	((LA_EXT *)la_info.li_a0-1)->ld_m_pos_hy
#define V_M_PLANES	((LA_EXT *)la_info.li_a0-1)->ld_m_planes
#define V_M_CDB_BG	((LA_EXT *)la_info.li_a0-1)->ld_m_cdb_bg
#define V_M_CDB_FG	((LA_EXT *)la_info.li_a0-1)->ld_m_cdb_fg
#define V_MASK_FORM	((LA_EXT *)la_info.li_a0-1)->ld_mask_form
#define V_INQ_TAB	((LA_EXT *)la_info.li_a0-1)->ld_inq_tab
#define V_DEV_TAB	((LA_EXT *)la_info.li_a0-1)->ld_dev_tab
#define V_GCURX	((LA_EXT *)la_info.li_a0-1)->ld_gcurx
#define V_GCURY	((LA_EXT *)la_info.li_a0-1)->ld_gcury
#define V_M_HID_CT	((LA_EXT *)la_info.li_a0-1)->ld_m_hid_ct
#define V_MOUSE_BT	((LA_EXT *)la_info.li_a0-1)->ld_mouse_bt
#define V_REQ_COL	((LA_EXT *)la_info.li_a0-1)->ld_req_col
#define V_SIZ_TAB	((LA_EXT *)la_info.li_a0-1)->ld_siz_tab
#define V_CUR_WORK	((LA_EXT *)la_info.li_a0-1)->ld_cur_work
#define V_DEF_FONT	((LA_EXT *)la_info.li_a0-1)->ld_def_font
#define V_FONT_RING	((LA_EXT *)la_info.li_a0-1)->ld_font_ring
#define V_FONT_COUNT	((LA_EXT *)la_info.li_a0-1)->ld_font_count
#define V_CUR_MS_STAT	((LA_EXT *)la_info.li_a0-1)->ld_cur_ms_stat
#define V_V_HID_CNT	((LA_EXT *)la_info.li_a0-1)->ld_v_hid_cnt
#define V_CUR_X	((LA_EXT *)la_info.li_a0-1)->ld_cur_x
#define V_CUR_Y	((LA_EXT *)la_info.li_a0-1)->ld_cur_y
#define V_CUR_FLAG	((LA_EXT *)la_info.li_a0-1)->ld_cur_flag
#define V_MOUSE_FLAG	((LA_EXT *)la_info.li_a0-1)->ld_mouse_flag
#define V_V_SAV_XY	((LA_EXT *)la_info.li_a0-1)->ld_v_sav_xy
#define V_SAVE_LEN	((LA_EXT *)la_info.li_a0-1)->ld_save_len
#define V_SAVE_ADDR	((LA_EXT *)la_info.li_a0-1)->ld_save_addr
#define V_SAVE_STAT	((LA_EXT *)la_info.li_a0-1)->ld_save_stat
#define V_SAVE_AREA	((LA_EXT *)la_info.li_a0-1)->ld_save_area
#define V_USER_TIM	((LA_EXT *)la_info.li_a0-1)->ld_user_tim
#define V_NEXT_TIM	((LA_EXT *)la_info.li_a0-1)->ld_next_tim
#define V_USER_BUT	((LA_EXT *)la_info.li_a0-1)->ld_user_but
#define V_USER_CUR	((LA_EXT *)la_info.li_a0-1)->ld_user_cur
#define V_USER_MOT	((LA_EXT *)la_info.li_a0-1)->ld_user_mot
#define V_CEL_HT	((LA_EXT *)la_info.li_a0-1)->ld_cel_ht
#define V_CEL_MX	((LA_EXT *)la_info.li_a0-1)->ld_cel_mx
#define V_CEL_MY	((LA_EXT *)la_info.li_a0-1)->ld_cel_my
#define V_CEL_WR	((LA_EXT *)la_info.li_a0-1)->ld_cel_wr
#define V_COL_BG	((LA_EXT *)la_info.li_a0-1)->ld_col_bg
#define V_COL_FG	((LA_EXT *)la_info.li_a0-1)->ld_col_fg
#define V_CUR_AD	((LA_EXT *)la_info.li_a0-1)->ld_cur_ad
#define V_CUR_OFF	((LA_EXT *)la_info.li_a0-1)->ld_cur_off
#define V_CUR_CX	((LA_EXT *)la_info.li_a0-1)->ld_cur_xy[0]
#define V_CUR_CY	((LA_EXT *)la_info.li_a0-1)->ld_cur_xy[1]
#define V_CUR_CNT	((LA_EXT *)la_info.li_a0-1)->ld_cur_cnt
#define V_CUR_TIM	((LA_EXT *)la_info.li_a0-1)->ld_cur_tim
#define V_FNT_AD	((LA_EXT *)la_info.li_a0-1)->ld_fnt_ad
#define V_FNT_ND	((LA_EXT *)la_info.li_a0-1)->ld_fnt_nd
#define V_FNT_ST	((LA_EXT *)la_info.li_a0-1)->ld_fnt_st
#define V_FNT_WR	((LA_EXT *)la_info.li_a0-1)->ld_fnt_wr
#define V_X_MAX		((LA_EXT *)la_info.li_a0-1)->ld_x_max
#define V_OFF_AD	((LA_EXT *)la_info.li_a0-1)->ld_off_ad
#define V_STATUS	((LA_EXT *)la_info.li_a0-1)->ld_status
#define V_Y_MAX	((LA_EXT *)la_info.li_a0-1)->ld_y_max
#define BYTES_LIN	((LA_EXT *)la_info.li_a0-1)->ld_bytes_lin

#define putpixel(x,y,v)	((PTSIN[0]=(x)),(PTSIN[1]=(y)),(INTIN[0]=(v)),linea1())
#define getpixel(x,y)	((PTSIN[0]=(x)),(PTSIN[1]=(y)),linea2())
#define showmouse(show)	(INTIN[0]=show,linea9())
#define hidemouse()	lineaa()
#define mousehidden	(V_M_HID_CT)

struct la_data *linea0(void);
void linea1(void);
short linea2(void);
void linea3(void);
void linea4(void);
void linea5(void);
void linea6(void);
void linea7(LA_BLIT *);
void linea8(void);
void linea9(void);
void lineaa(void);
void lineab(void);
void lineac(void *);
void linead(int,int,LA_SPRITE *,void *);
void lineae(void);
void lineaf(void);

#pragma inline linea1()	{register a2,d2; "a001";}
#pragma inline d0=linea2()	{register a2,d2; "a002";}
#pragma inline linea3()	{register a2,d2; "a003";}
#pragma inline linea4()	{register a2,d2; "a004";}
#pragma inline linea5()	{register a2,d2; "a005";}
#pragma inline linea6()	{register a2,d2; "a006";}
#pragma inline linea7(a6)	{register a2,d2; "a007";}
#pragma inline linea8()	{register a2,d2; "a008";}
#pragma inline linea9()	{register a2,d2; "a009";}
#pragma inline lineaa()	{register a2,d2; "a00a";}
#pragma inline lineab()	{register a2,d2; "a00b";}
#pragma inline lineac(a2)	{register d2,a6; "a00c";}
#pragma inline linead(d0,d1,a0,a2)	{register d2,a6; "a00d";}
#pragma inline lineae()	{register a2,d2; "a00e";}
#pragma inline lineaf()	{register a2,d2; "a00f";}
#endif
