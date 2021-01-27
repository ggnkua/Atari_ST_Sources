/*  Copyright (c) 1992 - present by Henk Robbers Amsterdam.
 *
 * This file is part of AHCC.
 *
 * AHCC is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * AHCC is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with AHCC; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

/* 	WINDOWS.H
 *	=========
 */

#ifndef __WINDOWS_H
#define __WINDOWS_H

#include <stdio.h>

#include "aaaa_win.h"
#include "common/stm.h"
#include "common/win_menu.h"

#define win     deskw.in
#define wwa     deskw.wa
#define wwv     deskw.v
#define INFO_H  (hchar+hchar/8)
#define MENU_M	w->menu
#define MENU_H  MENU_M->m[1].h+1
#define KIND    (NAME|     MOVER|CLOSER|FULLER|SIZER|VSLIDE|UPARROW|DNARROW|HSLIDE|LFARROW|RTARROW)
#define WKIND   KIND
/*
typedef struct position
{
	short x; long y;
} POS;

typedef struct size
{
	short w; long h;
} SZ;

typedef struct a_rect
{
	POS pos;
	SZ  sz;
} A_RECT;
*/
typedef struct cursorinfo
{
	POS pos;			/* cursor pos in data */
	short
		updn,			/* horizontal pos on screen as target of cursor up/down */
		scrx,			/*   "     "      "         actual  (tabs, nl, hex, ascii, spacing etc ) */
		ty;				/* type of cursor (needed for binary (hex | ascii) ) */
} CINF;

typedef enum
{
	ISMAP = 0x01,			/* ->user in bitmap  */
	ISMOD = 0x02,			/* is modified */
	IN_UNDO	=0x10,			/* is allready in undo buffer */
	SGL_0 = 0x20
} MSGFLAG;

typedef void DISP		(struct it *w,STMC *s,bool hide);
typedef short DISPH		(struct it *w,STMC *s);
typedef void SELECT		(struct it *w);
typedef void DESELECT	(struct it *w,CUR_TO rich);
typedef void XSELECT	(struct it *w,CINF *css,CINF *cse, STMNR top, STMNR bot);
typedef bool MENU_DO	(struct it *w,OBJECT *m,short title,short choice, short kstate);
typedef void MENU_SET	(struct it *w);
typedef bool FCLOSE		(struct it *w,bool force);
typedef void SCRL_VAL	(struct it *w, short *hv, short *vv, short *htv, short *vtv);
typedef void COLUMN		(struct it *w);

typedef struct view_state
{
	struct it *w;
	CINF cu, ss, se;
	STMNR top;
	short selty;
} VIEW_STATE;

typedef struct help_stack
{
	struct help_stack *prev;
	VIEW_STATE this;
} HELP_STACK;

/* The following immense struct was originally devised to accomodate
	the ability to have more than 1 window open at any time for any purpose.
	It gradually evolved in to sort of a thing that is driving any
	process going on in the program.
	It contains information on window, files, OBJECT's, bitmaps and rectangles
	alike.
	If the epitheton 'OBJECT' wasnt given away in times when microsoft designers
	had microsoft minds, I could have chosen that name for it.

	It's still growing. Wy not call it... .
*/
typedef struct it
{
							/* ----     vectors     ----						*/
	DRAW *		antedraw,	/* processing to be done before draw				*/
	     *		draw,		/* that draws (anything except objc_draw)			*/
	     *		postdraw;	/* processing to be done after draw					*/
	LINES *		lines;		/* display individual lines (without arrowed lines) */
	ANTEVNT *	antevnt;	/* processing to be done before evnt_multi			*/
	CLOSED *	closed;		/*   for window closebox							*/
	TOPPED *	topped;
	FULLED *	fulled;
	SLIDE *		slide;
	SLIDER *	slider;
	ARROWD *	arrowd;
	SIZED *		sized;
	MOVED *		moved;
	WINFO *		winfo;
	BUTTON *	button;
	KEYBD *		keybd;
	EDIT *		edit;
	TIMER *		timer;
	DRAWM *		draw_menu;
	MARGIN *	do_margin;
	MENU_DO *	do_menu;
	MENU_SET *	set_menu;
	FCLOSE *	close_file;	/* if menu action different from window closebox	*/
	SELECT *	select;		/*  selection										*/
	DESELECT *	deselect;	/*  The opposite									*/
	XSELECT *	wselect;	/*  The actual writing (with the parameters NOT explicitely from IT) */
	CURSOR *	cursor;		/*  cursor draw function									*/
	MUIS *		muisvorm;	/*  mouse appearance if in window					*/
	DIALFI *	dial_find;	/*  10 F toetsen type of find dialogue function		*/
	DIALREP *	do_repl;	/*  replace function								*/
	DRAG_SEL *	drag;		/*  what to do for dragging a selection				*/
	CINFI *		upd_cinf;	/*  Was: t_to_s_f */
	CINFO *		cinf_upd;	/*	Was: f_to_s_t */
#if KOLM
	COLUMN *	column;		/* redraw column (sheets ) */
#endif
						/* ----    general     ----							*/
	A_RECT
		norm,			/* window content e.g. lines/columns (units of scroll)	*/
		view;			/* the world behind a window in units of scroll */
	WH	unit;			/* cursor size and unit of scroll */

	unsigned
	short
		kcode,			/* normalized keyboard character */
		aeskcode, 		/* image of _intout[5] (unnormalized) when using NKCC, for use in form_keybd&objc_edit */
		aeskstate;

	short
		wh,				/* window handle									*/
		fl,				/* file handle										*/
		vhl;			/* VDI handle										*/

	M_S *	menu;		/* menu_bar for window menu							*/
	bool
		plain;			/* use m_key() also for plain keys					*/

	STMNR
		nls; 			/* totaal aantal items								*/

	short
		points;			/* points for font									*/
		fullw;			/* full window width (texts)						*/

	FILE *fd;			/* for if whole file cannot be read in (BIP_CC)		*/

	char *
		map;			/* address of bitmap on which window gives a view (pe bitmap) */
	long
		mapl;			/* size of map										*/

	bool
		cup,			/* text      curser displayed						*/
		crlf,			/* have \r in first line							*/
		lnrs,			/* line numbers in left margin						*/
		csens,			/* find is case sensative							*/
		surr,			/* select incl surrounding space					*/
		fback,			/* find backward									*/
		fforw,			/* find forward										*/
		selection;		/* because ss.l is 0-n								*/

	CINF
		cp,				/* for serial input not affecting other CINF's		*/
		cu,				/* cursor											*/
		ss,				/* selection start									*/
		se,				/*      "    end									*/
		vc;				/* make change(s) visable							*/

	short
		selty,			/* selection type (for CTRL LEFT/RIGHT)				*/
		color,			/* selection color									*/
		den;			/* denotation space for line number					*/
	char
		html[16];		/* html hook name 									*/

	RECT
		c,				/* current uitwendige afmeting						*/
		v,				/* afmetingen omranding (verschil)					*/
						/* tbv omrekeningen CURR <-> WORK					*/
		inf,			/* voor info line (tbv submenu)  dynamisch			*/
		in,				/*      rectangles  initieel						*/
		men,			/*      			voor w_menu bar statisch		*/
		wa,				/*                  AES workarea					*/
		ma,				/*                  my work area					*/
		rem,			/*                  remember						*/
		frem,			/*                      "    fulled					*/
		nfrem;			/*                      "    unfulled				*/
	WH	mg;				/*                  margin widths					*/
	long
		magic1;
	struct
	{
		char
			v,			/* for possible version indicator pe 'N'			*/
			u,			/* for 'Undone' indication   pe: 'U'				*/
			x,			/* for 'modified' indication pe: '*'				*/
			filler;		/* space											*/

		MAX_dir t;
	#ifdef DIGGER
		char Xt[32];	/* when 'from - to' overflows title					*/
	#endif
	}  title;

	MAX_dir info;		/* Can contain name of a related non_top window		*/
	char Xinfo[12];		/* Mostly for use by journal, if a small text is prepended */
	INFO_T  ty;			/* type of thing in window (dialogues < 100, all other >=100)
						   is tree index for identification of dialogue		*/
	bool op,			/* open   true										*/
	     full,			/* fulled true										*/
	     snap;			/* snap on x; allways snap w and h					*/
	short
	     wkind,			/* samenstelling									*/
	     avrg,			/* avarage line size (for allocation of new lines)	*/
	     vslp,vsls,		/* vertical   slider position, -size ( 0-1000 )		*/
	     hslp,hsls;		/* horizontal    "       "        "       "    		*/

	CFG_LOCAL
		 loc;

#ifdef BOLDTAGS
	BOLDCAT *bc;
#endif

#ifdef MNUNDO
						/* ---- for UNDO operations							*/
	STMDEF
		undo;		/* base of chain									*/
	bool
		undone;		/* undo status: true=undone, false=not or re-undone	*/
	VIEW_STATE
		u;
#endif

	bool
		ismod;		/* global flag for modified (only CALC & DIGGER) */
	COPRMSG *
		init_text;	/* initial text (used for journal) */

						/* ----    specific for usage of STM     ----		*/
	STMDEF *
		base;		/* to base of chain that controls contents of w		*/
	STMDEF *
		old;		/* to base of chain that controls changes  of contents of w (for undo) */
	char *
		line;		/* result of 'find_line' (->user info)				*/
	STMDEF
		text;		/* base of chain									*/
	DISP *
		disp;		/* display line										*/
	DISPH * dha,	/* ante display	on obove							*/
		  *	dhp;	/* post    "       "    							*/

						/* ----    specific for dialogues     ----			*/
#if WINDIAL or WIN_OB		/* worksheets share data and dialogue in a window */
	struct wdial
	{
		struct
		it *	act_on;	/* struct of related window (last top window)	*/
		void   (*action)(struct it *w);
		OBJECT *
			ob;			/* address of dialogues object tree					*/
		OB_PLACE *
			place;	/* adjust place	of object							*/
		short
			item,		/* start item for draw								*/
			edup,		/* dialogue cursor displayed						*/
			edon,		/* dialogue cursor active							*/
			ddx,		/* distance from root to item						*/
			ddy;
		DEXIT *
			exit;		/* process dialogue after exit condition			*/
		/* cursor information */
		OBJECT *
			ed;			/* current edit object								*/
		TEDINFO *
			ted;		/* info of above									*/
		short
			edob,		/* for use in edit of forms (as in form_do())		*/
			idx,		/* index of cursor in text&valid string				*/
			edx,		/* x, y of current editable field					*/
			edy,
			cx,			/* x, y, of touch within object in chars */
			cy;
		char * tmplt,	/* cursor pos in template							*/
			 * txt,		/* cursor position in text							*/
			 * val;		/* cursor pos in validation string					*/
	} dial;
#endif

#if defined GEMSHELL || TEXTFILE || BINED
	void *loctab;
#endif
						/* ----    specific for work sheets    ----			*/
#ifdef WKS
	struct sheet
	{
		SH_SHEET tab;	/* tables of pointers to cells; ([MAXCOLS][MAXROWS]) */
		SH_HDR	head;		/* sheet header for use by .CAL sheets	*/
		void *ides;			/* symbol table */
		char edstr[128],
		     costr[128];	/* permanently stored strings in which editing can be in progress */
		short Ver;
		bool editing;		/* obno: editing in progress --> display contents of edstr,
							       0   : display comtents of cell			*/
	} wks;
#endif
						/* ----    specific for mandelbrot      ---- 		*/
#ifdef MFRAC
	void *s;			/* veel extra info									*/
	bool overscan;
#endif

						/* ----    specific for images         ---- 		*/
#ifdef IMGS
	struct images
	{
		DRBVN set,get;		/* tbv set_img & get_ing */
		MFDB S;
		RECT orig;
	} img;
#endif
						/* ----    specific for binary editor  ---- 		*/
#ifdef BINED
	struct binary
	{
		long cur;			/* file position of cursor							*/
		bool curty;			/* true ascii area, false hex area					*/
		short
			 xnrw,			/* no if places needed for hex & dec numbers in margin */
			 dnrw,
			 asciipos,		/* start of ascii field */
			 hex_end,		/* end of hex field */
			 lw,			/* no of longs per line								*/
			 bw,			/* no of bytes per line (lw*sizeof(long))			*/
			 bln;			/* current line in window							*/
	} bin;
#endif

						/* ----    specific for Digger      ---- 		*/
#ifdef DIGGER
	TTD_CFG  cf;		/* global config									*/
	TTD_PROF cg;		/* profile											*/
	PDW *dw;			/* extra info using special types used in DIGST.C	*/
	void *cg_tab;
	void *cf_tab;

	struct stdigger
	{
		FHD  kop;
		MAX_dir
		     fo,		/* strings for constructing .idx & .idf & .cff */
			 fs;		/* There is not always a suitable string in w->title */
		bool *jt, rescan, mask[64], maskx[64],
		     marked, lbl1, f_info, d_info,
		     defs, odefs, extra, esym, is_bm;
		long s_jt, s_rel, s_lab, s_dt,
		     lreloc, ltext, ldat, lbss,
		     lsym,   limg,  lfix, lnam, debug,
		     dist, syms, fixups, value, flen;
		PC   ssel, esel, ruler, rkey, key_remember,
		     pc0, npg, *history, fend, lim, pclim;
		PCB  buffer;
		Wstr t5, t6, t69, t74, t_hex, t_char, t_h;
		short his_ptr, t_x, hexw;
		char *index;
	} dis;
#endif
						/* ----    specific for treeview windows			*/
#ifdef COFT
	struct treeview
	{
		WICON *wicon;
		NSP np, root, cur, sel;
		void *dp;
		char txt[256];
		Cstr prj;
		short y;
	} trv;
#endif
						/* ----    specific for mini console				*/
#ifdef MINICONS
	struct miniconsole
	{
		short task,stage;
		struct
		it     *act_on;		/* struct of related window (last top window)		*/
		CON_RET *ret_action,
				*undo_action;
		short prompt;
		char remember[128];
		bool  volat;		/* journal is volatile (closed on <RETURN>, <ENTER> & <UNDO> */
	} con;
#endif
	bool lsto;				/* lines have been stored, redraw is needed			*/
	long magic2;
} IT;
#endif

extern short whs[];
extern CINF cnil;
#define c1st cnil

typedef void VpW(IT *w);
void	alertwindow		(char *opm);

WSELECT	is_drop,
		is_text,
		is_srce,
		is_dial,
		is_buf,
		is_jrnl,
		is_sheet,
		is_bin,
		no_dial,
		is_mand,
		is_object,
		is_graphic,
		no_graphic,
		is_file, is_trv,
		for_tile;
void	redraw_windows	(INFO_T);
void	next_upper_left	(IT *nw, short dx, short dy, RECT *in);
IT *	get_it			(short h, INFO_T t);
IT *	is_it			(IT *w);
IT *	get_top_it		(void);
IT *	get_fn_it		(Cstr fn);
REDRAW	do_redraw;
VpV		to_top,
		to_bottom;
STMNR	bounce			(IT *w,STMNR top);
void 	ck_act_on		(IT *w, IT *wt);
VpW		wi_title,
		set_U,
		set_X,
		set_V,
		renum,
		close_w,
		cyclewindows,
		get_work,
		clear_margin;
void	set_pxy_s		(IT *w, short x, short y),
		v_bounce_img	(IT *w),
		h_bounce_img	(IT *w);
short 	open_w			(IT *w);
ANTEVNT wdial_evm;
short 	w_handles		(short whs[],WSELECT te_sel);
RECT	overlap			(void);

#define ITMAGIC 'HROB'

IT *	create_IT	(	bool   with_w,
						Cstr name,
						short  fl,
						char * info,
						COPRMSG * init_text,
						short  wkind,
						INFO_T ty,
						void * root,		/*	root of a treeview */
						Cstr pname,
						OBJECT * ob,
						OB_PLACE *place,
						short  item,
						WINIT  winit,
						DEXIT  pr_dial,
						DRAW   antedraw,
						DRAW   draw,
						DRAW   postdraw,
						ANTEVNT antevnt,
						LINES lines,
						DISP  displ,
						DISPH  dha,
						DISPH  dhp,
						CLOSED closew,
						FCLOSE fclose,
						TOPPED topw,
						FULLED fullw,
						SLIDE  slidew,	/* event */
						SLIDER slider,	/* action */
						ARROWD arrow,
						SIZED  sizew,
						MOVED  movew,
						BUTTON buttonw,
						KEYBD  keyw,
						EDIT   ed_key,
						TIMER  timer,
						DRAWM  draw_wmenu,
						MENU_DO do_wmenu,
						MENU_SET set_menu,
						M_S * menu,
						SELECT sel,
						DESELECT desel,
						XSELECT wsel,
						CURSOR do_cur,
						CINFI upd_cinf,
						CINFO cinf_upd,
						MUIS muis,
						void * bitmap,
						long   mapl,
						WH unit,
						short vhl,		/* 07'20 HR v6 */
						short  w_points,
						short minmargin,
						MARGIN do_margin);

void	update_it		(bool app, INFO_T ty);
SCRL_VAL h_and_v;
void	snapwindow		(IT *w, RECT *sn);
short 	wmenu_tnormal	(IT *w,short i, short state);
bool	delete_windows	(bool force);
void	print_it		(IT *w,char *text);
RECT	lower_right		(RECT in);
bool	is_beyond_scr	(IT *w);
void	rack_up			(IT *w, STMNR oldy);
void	rack_dn			(IT *w, STMNR oldy);

FULLED	fullwindow, full_img;
SIZED	sizewindow, size_img;
SLIDE	slidewindow, slide_img;
ARROWD	arrowwindow, arrow_img,arrow_fs;
MOVED	movewindow, move_img;
SLIDER	v_slider, img_slider;

extern
RECT nomargin;
