/*
 * linea.h -- C interface to Atari line A graphics routines.
 *
 * Copyright (c) 1986-1988, Mark Williams Company, Chicago
 * This file and its contents may not be copied or distributed
 * without permission.
 */
/*
 * Each of the following line A functions consists of only a few
 * lines of assembler code that save registers, load parameters,
 * execute one of the unimplemented line 'a' instructions, restore
 * registers, and return.
 *
 * Most of the line A functions pass their parameters through the
 * structure "la_data", which is referenced through
 * the pointer in the structure "la_init"; this, in turn,
 * is initialized by the function linea0().
 *
 * The bitblt and sprite functions are exceptions to this rule.
 *
 * The structure "la_ext" contains late additions to the linea
 * documentation.  This structure occupies the memory directly
 * below "la_data" in memory.
 *
 * The address of the linea data structure is fixed in the rom, so on
 * any given machine the address returned by "linea0()" will always be
 * the same.  If LINEA_AD is defined when this file is compiled, then its
 * absolute address will be used for referencing linea data items instead
 * of the more expensive pointer address references.
 * The value specified for LINEA_AD should be the address of the la_ext
 * structure, ie the value of ((long)la_init.li_a0)-46.
 */
#ifndef LINEA_H
#define LINEA_H

extern linea0();	/* () Initialize */
extern linea1();	/* () Put pixel */
extern linea2();	/* () Get pixel */
extern linea3();	/* () Draw line */
extern linea4();	/* () Draw horizontal line */
extern linea5();	/* () Draw filled rectangle */
extern linea6();	/* () Draw filled polygon */
extern linea7();	/* (struct la_blit *bp) BitBlt */
extern linea8();	/* () TextBlt */
extern linea9();	/* () Show mouse */
extern lineaa();	/* () Hide mouse */
extern lineab();	/* () Transform mouse */
extern lineac();	/* (char *sp) Undraw sprite */
extern linead();	/* (long x,y; char *p,*q) Draw sprite */
extern lineae();	/* () Copy raster form */
extern lineaf();	/* () Seedfill */

/*
 * Calling linea0() fetchs the following structure from
 * the system and stores it in external memory.
 */
struct linea_init {
	/* Early versions of TOS do not implement all possible functions */
	long li_d0;		/* 0 if old system bugs persist */
	long li_a0;		/* pointer to linea data structure */
	struct la_font **li_a1;	/* system font vector */
	long (*li_a2)();	/* linea function vector */
};

extern struct linea_init la_init;
/*
 * The system data structure implements graphics.
 * This is not well documented.
 */
struct la_data {
	int	ld_vplanes;	/* Number of video planes: 1, 2, or 4 */
	int	ld_vwrap;	/* Number of bytes/video line */
	int	*ld_contrl;	/* Pointer to CONTRL array */
	int	*ld_intin;	/* Pointer to INTIN array */
	int	*ld_ptsin;	/* Pointer to PTSIN array */
	int	*ld_intout;	/* Pointer to INTOUT array */
	int	*ld_ptsout;	/* Pointer to PTSOUT array */
	int	ld_colbit[4];	/* Color bit-plane[i] value */
	int	ld_lstlin;	/* -1 */
	int	ld_lnmask;	/* Line-style mask */
	int	ld_wmode;	/* Writing mode 0:replace, 1:transparent,
				   2:exclusive OR, 3:inverse transparent */
	int	ld_x1;		/* X1 coordinate */
	int	ld_y1;		/* Y1 coordinate */
	int	ld_x2;		/* X2 coordinate */
	int	ld_y2;		/* Y2 coordinate */
	int	*ld_patptr;	/* Fill pattern pointer */
	int	ld_patmsk;	/* Fill pattern mask */
	int	ld_mfill;	/* Multi-plane fill flag */
	int	ld_clip;	/* Clipping flag */
	int	ld_xmincl;	/* Minimum X clipping value */
	int	ld_ymincl;	/* Minimum Y clipping value */
	int	ld_xmaxcl;	/* Maximum X clipping value */
	int	ld_ymaxcl;	/* Maximum Y clipping value */
	int	ld_xdda;	/* Accumulator for textblt dda */
	int	ld_ddainc;	/* Fixed point scale factor */
	int	ld_scaldir;	/* Scale direction flag */
	int	ld_mono;	/* Current font is monospaced */
	int	ld_srcx;	/* X coord of character in font */
	int	ld_srcy;	/* Y coord of character in font */
	int	ld_dstx;	/* X coord of character on screen */
	int	ld_dsty;	/* Y coord of character on screen */
	int	ld_delx;	/* Width of character */
	int	ld_dely;	/* Height of character */
	int	*ld_fbase;	/* Pointer to start of font form */
	int	ld_fwidth;	/* Width of font form */
	int	ld_style;	/* Textblt special effects flags */
	int	ld_litemsk;	/* Lightening mask */
	int	ld_skewmsk;	/* Skewing mask */
	int	ld_weight;	/* Thickening factor */
	int	ld_roff;	/* Skew offset above baseline */
	int	ld_loff;	/* Skew offset below baseline */
	int	ld_scale;	/* Scaling flag */
	int	ld_chup;	/* Character rotation vector */
	int	ld_textfg;	/* Text foreground color */
	int	*ld_scrtchp;	/* Text special effects buffer */
	int	ld_scrpt2;	/* Offset to scaling buffer from above */
	int	ld_textbg;	/* Text background color */
	int	ld_copytran;	/* Copy raster form type flag */
	int	(*ld_seedabort)();	/* Seedfill end detect function */
};

/*
 * The extended linea data block.
 */
struct la_ext {
	short	ld_cel_ht;	/* Height of character cell */
	short	ld_cel_mx;	/* Maximum horizontal cell index */
	short	ld_cel_my;	/* Maximum vertical cell index */
	short	ld_cel_wr;	/* Screen width (bytes) * cel_ht */
	short	ld_col_bg;	/* Background color index */
	short	ld_col_fg;	/* Foreground color index */
	long	ld_cur_ad;	/* Cursor address */
	short	ld_cur_off;	/* Byte offset to cursor from screen base */
	short	ld_cur_cx;	/* Cursor horizontal cell index */
	short	ld_cur_cy;	/* Cursor vertical cell index */
	char	ld_cur_cnt;	/* Cursor flash shorterval (frames) */
	char	ld_cur_tim;	/* Cursor flash countdown */
	long	ld_fnt_ad;	/* Font table address */
	short	ld_fnt_nd;	/* Last ascii code in font */
	short	ld_fnt_st;	/* First ascii code in font */
	short	ld_fnt_wr;	/* Width of font form (bytes) */
	short	ld_x_max;	/* Maximum horizontal pixel index */
	long	ld_off_ad;	/* Font offset table address */
	char	ld_status;	/* Text status byte */
	char	ld_fill;	/* Filler byte */
	short	ld_y_max;	/* Maximum vertical pixel index */
	short	ld_x_wr;	/* Width of screen (bytes) */
};

/*
 * Accept an absolute specification for the linea la_data address.
 * Note that programs compiled with such an option will not work
 * on machines which have their linea la_data at some other address.
 * The location for your machine should be determined by calling
 * linea0() and displaying the address returned for la_init.li_a0.
 */
#ifndef LINEA_AD
#define LINEA_AD	(la_init.li_a0-sizeof(struct la_ext))
#endif

#define LA_EXT	((struct la_ext *)LINEA_AD)
#define LA_DATA	((struct la_data *)(LINEA_AD+sizeof(struct la_ext)))

/*
 * Definitions to make the names described in the Atari
 * linea.doc and linea.ext accessible.
 */
#define VPLANES	LA_DATA->ld_vplanes
#define VWRAP	LA_DATA->ld_vwrap
#define CONTRL	LA_DATA->ld_contrl
#define INTIN	LA_DATA->ld_intin
#define PTSIN	LA_DATA->ld_ptsin
#define INTOUT	LA_DATA->ld_intout
#define PTSOUT	LA_DATA->ld_ptsout
#define COLBIT0	LA_DATA->ld_colbit[0]
#define COLBIT1	LA_DATA->ld_colbit[1]
#define COLBIT2	LA_DATA->ld_colbit[2]
#define COLBIT3	LA_DATA->ld_colbit[3]
#define LSTLIN	LA_DATA->ld_lstlin
#define LNMASK	LA_DATA->ld_lnmask
#define WMODE	LA_DATA->ld_wmode
#define X1	LA_DATA->ld_x1
#define Y1	LA_DATA->ld_y1
#define X2	LA_DATA->ld_x2
#define Y2	LA_DATA->ld_y2
#define PATPTR	LA_DATA->ld_patptr
#define PATMSK	LA_DATA->ld_patmsk
#define MFILL	LA_DATA->ld_mfill
#define CLIP	LA_DATA->ld_clip
#define XMINCL	LA_DATA->ld_xmincl
#define YMINCL	LA_DATA->ld_ymincl
#define XMAXCL	LA_DATA->ld_xmaxcl
#define YMAXCL	LA_DATA->ld_ymaxcl
#define XDDA	LA_DATA->ld_xdda
#define DDAINC	LA_DATA->ld_ddainc
#define SCALDIR	LA_DATA->ld_scaldir
#define MONO	LA_DATA->ld_mono
#define SRCX	LA_DATA->ld_srcx
#define SRCY	LA_DATA->ld_srcy
#define DSTX	LA_DATA->ld_dstx
#define DSTY	LA_DATA->ld_dsty
#define DELX	LA_DATA->ld_delx
#define DELY	LA_DATA->ld_dely
#define FBASE	LA_DATA->ld_fbase
#define FWIDTH	LA_DATA->ld_fwidth
#define STYLE	LA_DATA->ld_style
#define LITEMSK	LA_DATA->ld_litemsk
#define SKEWMSK	LA_DATA->ld_skewmsk
#define WEIGHT	LA_DATA->ld_weight
#define ROFF	LA_DATA->ld_roff
#define LOFF	LA_DATA->ld_loff
#define SCALE	LA_DATA->ld_scale
#define CHUP	LA_DATA->ld_chup
#define TEXTFG	LA_DATA->ld_textfg
#define SCRTCHP	LA_DATA->ld_scrtchp
#define SCRPT2	LA_DATA->ld_scrpt2
#define TEXTBG	LA_DATA->ld_textbg
#define COPYTRAN	LA_DATA->ld_copytran
#define SEEDABORT	LA_DATA->ld_seedabort

#define V_CEL_HT	LA_EXT->ld_cel_ht
#define V_CEL_MX	LA_EXT->ld_cel_mx
#define V_CEL_MY	LA_EXT->ld_cel_my
#define V_CEL_WR	LA_EXT->ld_cel_wr
#define V_COL_BG	LA_EXT->ld_col_bg
#define V_COL_FG	LA_EXT->ld_col_fg
#define V_CUR_AD	LA_EXT->ld_cur_ad
#define V_CUR_OFF	LA_EXT->ld_cur_off
#define V_CUR_CX	LA_EXT->ld_cur_cx
#define V_CUR_CY	LA_EXT->ld_cur_cy
#define V_CUR_CNT	LA_EXT->ld_cur_cnt
#define V_CUR_TIM	LA_EXT->ld_cur_tim
#define V_FNT_AD	LA_EXT->ld_fnt_ad
#define V_FNT_ND	LA_EXT->ld_fnt_nd
#define V_FNT_ST	LA_EXT->ld_fnt_st
#define V_FNT_WR	LA_EXT->ld_fnt_wr
#define V_X_MAX		LA_EXT->ld_x_max
#define V_OFF_AD	LA_EXT->ld_off_ad
#define V_STATUS	LA_EXT->ld_status
#define V_Y_MAX		LA_EXT->ld_y_max
#define V_X_WR		LA_EXT->ld_x_wr

/*
 * Macros for the easiest line A functions.
 */
#define putpixel(x,y,v)	((PTSIN[0]=x),(PTSIN[1]=y),(INTIN[0]=v),linea1())
#define getpixel(x,y)	((PTSIN[0]=x),(PTSIN[1]=y),linea2())
#define showmouse()	(linea9())
#define hidemouse()	(lineaa())

/*
 * The mouse hidden flag/counter is at an undocumented negative offset
 * from the structure pointed to by a0 after a linea0 (init) call.
 * It is 0 when the mouse is shown.
 * This is true in 11/20/85 USA rom and later, and appears to be
 * true for all ROM versions of TOS.
 */
#define mousehidden	*((int *)((long)la_init.li_a0-598))

/*
 * The mouse position and button state information is also available
 * at a negative offset from the structure pointed to by a0 after a
 * linea0 (init) call.  Do not modify these values.
 */
#define	mousebutstate	*((int *)((long)la_init.li_a0-596))
#define	mouseposx	*((int *)((long)la_init.li_a0-344))
#define	mouseposy	*((int *)((long)la_init.li_a0-342))

/*
 * linea7() = BitBlt parameter block:
 * source and destination description blocks.
 */
struct la_blk {
	int	bl_xmin;		/* Minimum x */
	int	bl_ymin;		/* Minimum y */
	int	*bl_form;		/* Word aligned memory form */
	int	bl_nxwd;		/* Offset to next word in line */
	int 	bl_nxln;		/* Offset to next line in plane */
	int 	bl_nxpl;		/* Offset to next plane */
};

struct la_blit {
	int	bb_b_wd;		/* Width of block in pixels */
	int	bb_b_ht;		/* Height of block in pixels */
	int	bb_plane_ct;		/* Number of planes to blit */
	int	bb_fg_col;		/* Foreground color */
	int	bb_bg_col;		/* Background color */
	char	bb_op_tab[4];		/* Logic for fg x bg combination */
	struct la_blk bb_s;		/* Source info block */
	struct la_blk bb_d;		/* Destination info block */
	int	*bb_p_addr;		/* Pattern buffer address */
	int	bb_p_nxln;		/* Offset to next line in pattern */
	int	bb_p_nxpl;		/* Offset to next plane in pattern */
	int	bb_p_mask;		/* Pattern index mask */
	char	bb_fill[24];		/* Work space */
};
/*
 * Offsets to next word in plane:
 */
#define HIGH_NXWD	2
#define MED_NXWD	4
#define LOW_NXWD	8
/*
 * Scan line widths of the screen:
 */
#define HIGH_NXLN	80
#define MED_NXLN	160
#define LOW_NXLN	160
/*
 * Offsets between planes:
 */
#define NXPL		2
/*
 * linead() = Draw sprite, sprite definition block.
 *	sprite save block is 10+VPLANES*64 bytes big.
 */
struct la_sprite {
	int	ls_xhot;	/* X hot spot offset */
	int	ls_yhot;	/* Y hot spot offset */
	int	ls_form;	/* 1 for VDI, -1 for XOR */
	int	ls_bgcol;	/* Background color index */
	int	ls_fgcol;	/* Foreground color index */
	int	ls_image[32];	/* Background/foreground interleaved image */
};
/*
 * Font header. Taken from GEM VDI Programmers Guide G-2
 */
struct la_font {
	int	font_id;		/* Face identifier */
	int	font_size;		/* Font size in points */
	char	font_name[32];		/* Face name */
	int	font_low_ade;		/* Lowest ASCII value in face */
	int	font_hi_ade;		/* Highest ASCII value in face */
					/* Distance from char baseline */
	int	font_top_dst;		/* Top line distance */
	int	font_ascent_dst;	/* Ascent line distance */
	int	font_half_dst;		/* Half line distance */
	int	font_descent_dst; 	/* Descent line distance */
	int	font_bottom_dist; 	/* Bottom line distance */
	int	font_fatest;		/* Width of widest char in font */
	int	font_fat_cell;		/* Width of widest char cell in font */
	int	font_left_off;		/* Left offset */
	int	font_right_off;		/* Right offset */
	int	font_thickening; 	/* No. of pixles to widen chars */
	int	font_underline;		/* Width in pixles of underline */
	int	font_lightening; 	/* Mask used to drop pixles out */
	int	font_skewing;		/* Mask used to determine skewing */
	unsigned default_font:1; 	/* Set if default system font */
	unsigned horiz_ofset:1;		/* Use horizontal offset tables */
	unsigned byte_swap:1;		/* Byte swap flag */
	unsigned mono_space:1;		/* Monospaced font */
	int	*font_horiz_off; 	/* Pointer to horizontal offset table */
	int	*font_char_off;		/* Pointer to char offset table */
	char	*font_data;		/* Pointer to font data */
	int	font_width;		/* Font width */
	int	font_height;		/* Font height */
	char	*font_next;		/* Pointer to next font */
};
#endif

/* End of linea.h */
