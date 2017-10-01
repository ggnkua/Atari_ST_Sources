#ifndef DESKGRAF_H

#define DESKGRAF_H

EXTERN WORD	gl_width;
EXTERN WORD	gl_height;

EXTERN WORD	gl_nrows;
EXTERN WORD	gl_ncols;

EXTERN WORD	gl_wchar;
EXTERN WORD	gl_hchar;

EXTERN WORD	gl_wschar;
EXTERN WORD	gl_hschar;

EXTERN WORD	gl_wptschar;
EXTERN WORD	gl_hptschar;

EXTERN WORD	gl_wbox;
EXTERN WORD	gl_hbox;

EXTERN WORD	gl_xclip;
EXTERN WORD	gl_yclip;
EXTERN WORD	gl_wclip;
EXTERN WORD	gl_hclip;

EXTERN WORD gl_nplanes;
EXTERN WORD gl_handle;

EXTERN MFDB	gl_src;
EXTERN MFDB	gl_dst;

EXTERN WORD gl_ws[58];

EXTERN LONG	ad_intin;

EXTERN WORD	gl_mode;
EXTERN WORD	gl_mask;
EXTERN WORD	gl_tcolor;
EXTERN WORD	gl_lcolor;
EXTERN WORD	gl_fis;
EXTERN WORD	gl_patt;
EXTERN WORD	gl_font;

EXTERN GRECT	gl_rscreen;
EXTERN GRECT	gl_rfull;
EXTERN GRECT	gl_rzero;
EXTERN GRECT	gl_rcenter;
EXTERN GRECT	gl_rmenu;

EXTERN	WORD gsx_sclip(GRECT *pt);
EXTERN	VOID gsx_gclip(GRECT *pt);
EXTERN	VOID gsx_xline(WORD ptscount, WORD *ppoints);
EXTERN	VOID gsx_pline(WORD offx, WORD offy, WORD cnt, WORD *pts);
EXTERN	VOID gsx_attr(UWORD text, UWORD mode, UWORD color);
EXTERN	VOID gsx_fix(MFDB *pfd, LONG theaddr, WORD wb, WORD h);
EXTERN	VOID gsx_blt(LONG saddr, UWORD sx, UWORD sy, UWORD swb, LONG daddr,
	UWORD dx, UWORD dy, UWORD dwb, UWORD w, UWORD h, UWORD rule,
	WORD fgcolor, WORD bgcolor);
EXTERN VOID bb_screen(WORD scrule, WORD scsx, WORD scsy, WORD scdx,
	WORD scdy, WORD scw, WORD sch);
EXTERN	VOID gsx_trans(LONG saddr, UWORD swb, LONG daddr, UWORD dwb, UWORD h);
EXTERN	VOID gsx_start(VOID);
EXTERN	VOID gsx_tblt(WORD tb_f, WORD x, WORD y, BYTE *tb_s);
EXTERN	VOID bb_fill(WORD mode, WORD fis, WORD patt, WORD hx, WORD hy, WORD hw, WORD hh);
EXTERN	VOID gsx_vopen(VOID);

#endif
