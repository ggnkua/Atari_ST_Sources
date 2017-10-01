/*************************************************************
 * Copyright 1999 by Caldera Thin Clients, Inc.              *
 * This software is licensed under the GNU Public License.   *
 * Please see LICENSE.TXT for further information.           *
 *************************************************************/
#ifndef RCSIEXT_H

#define RCSIEXT_H

EXTERN	     WORD       flags;
EXTERN	     WORD       out1;
EXTERN	     WORD       xwait;
EXTERN	     WORD       ywait;
EXTERN	     WORD       wwait;
EXTERN	     WORD       hwait;
EXTERN	     WORD       out2;
EXTERN	     LONG       ad_rmsg;
EXTERN       WORD       rcs_rmsg[];
EXTERN	     GRECT      wait;
EXTERN	     WORD       mousex;
EXTERN	     WORD       mousey;
EXTERN	     WORD       bstate;
EXTERN	     WORD       kstate;
EXTERN	     WORD       kreturn;
EXTERN	     WORD       bclicks;
EXTERN	     WORD       rcs_edited;
EXTERN       GRECT      tools;
EXTERN       BYTE 	icn_file[];
EXTERN       WORD	rcs_xpert;
EXTERN	     UWORD      bit_mask[];
EXTERN	     WORD       gl_tcolor;
EXTERN	     WORD       gl_mode;
EXTERN	     WORD       gl_lcolor;
EXTERN	     GRECT      full;
EXTERN	     WORD       rcs_xpan;
EXTERN	     WORD       rcs_ypan;
EXTERN	     LONG       src_mp;
EXTERN	     LONG       dst_mp;
EXTERN	     GRECT      pbx;

#define      FINGER      3
#define      ARROW       0
EXTERN	     WORD       rcs_hot;
 
EXTERN       LONG	ad_menu;
EXTERN       WORD	icn_state;
#define      NOFILE_STATE	0
#define      FILE_STATE		1
EXTERN       WORD	OK_NOICN[];
EXTERN       WORD	OK_ICN[];
EXTERN       BOOLEAN	icn_edited;
EXTERN       WORD	OK_EDITED[];
EXTERN       BOOLEAN	gl_isicon;
EXTERN       LONG	ad_tools;
EXTERN       LONG       ad_itool;
EXTERN       LONG       ad_idisp;
EXTERN       GRECT	fat_area;
EXTERN       GRECT	 gridbx;
EXTERN       LONG	ad_view;
EXTERN       WORD	gl_wimage;
#define  gl_sqsize  8
EXTERN       WORD	gl_himage;
EXTERN       GRECT	view;
EXTERN       GRECT      itool;
EXTERN       GRECT      idisp;
EXTERN       LONG	ad_pbx;
EXTERN       GRECT	src_img;
EXTERN       GRECT	dat_img;
EXTERN       GRECT	mas_img;
EXTERN       GRECT	icn_img;
EXTERN       BOOLEAN	iconedit_flag;
EXTERN       MFDB	hold_mfdb;
EXTERN       MFDB	hld2_mfdb;
EXTERN       MFDB	disp_mfdb;
EXTERN       MFDB	undo_mfdb;
EXTERN       MFDB	und2_mfdb;
EXTERN       MFDB	clip_mfdb;
EXTERN       MFDB	clp2_mfdb;
EXTERN       MFDB	save_mfdb;
EXTERN       MFDB	sav2_mfdb;
EXTERN       MFDB	fat_mfdb;
EXTERN       LONG	save_tree;
EXTERN	     WORD	save_obj;
EXTERN       WORD	rcs_sel[];
EXTERN       WORD	rcs_view;
EXTERN       BYTE	rcs_title[];
EXTERN       WORD	rcs_state;
EXTERN       WORD	colour;
EXTERN       WORD	fgcolor;
EXTERN       WORD	bgcolor;
EXTERN	     WORD	old_fc;
EXTERN       GRECT	hold_area;  
EXTERN       GRECT	selec_area;
EXTERN	     GRECT	flash_area;
EXTERN       GRECT	clip_area;  
EXTERN       WORD	partp;
EXTERN	     WORD	deltax;
EXTERN	     WORD	deltay;
EXTERN       LONG	gl_icnspec;  
EXTERN       WORD	gl_datasize;  
EXTERN       WORD	gl_nplanes;  
EXTERN       WORD	gl_width;  
EXTERN       GRECT	scrn_area;  
EXTERN       WORD	gl_height;  
EXTERN       MFDB	scrn_mfdb;  
EXTERN       GRECT	scroll_fat;  
EXTERN       BOOLEAN	is_mask;  
EXTERN       WORD	rcs_nsel;  
#define     MAX_ICON_W	0x0040
#define     MAX_ICON_H  0x0040
EXTERN       LONG	ibuff_size;  
EXTERN       WORD	pen_on;  
EXTERN	     BOOLEAN	grid;
EXTERN	     BOOLEAN	clipped;
EXTERN	     BOOLEAN	paste_img;
EXTERN	     BOOLEAN	selecton;
EXTERN	     BOOLEAN    inverted;
EXTERN	     WORD	invert3[8];
EXTERN	     WORD	invert4[16];

#define      BI_PDATA(x)  (x)
#define      IB_PDATA(x)  (x + 4)
#define      BI_WB(x)     (x + 4)
#define      BI_HL(x)     (x + 6)
#define      BI_COLOR(x)  (x + 12)
#define      IB_CHAR(x)   (x + 12)
#define      IB_PMASK(x)  (x)
#define	     IB_XICON(x)  (x + 18)
#define      IB_WICON(x)  (x + 22)   
#define      IB_HICON(x)  (x + 24)
#define      OB_STATE(x) (tree + (x) * sizeof(OBJECT) + 10)

#endif
