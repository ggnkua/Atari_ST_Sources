/* Copyright (c) 1990 - present by H. Robbers Amsterdam.
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

/* 	WI_TYPES.H
 *	==========
 */

#ifndef WI_TYPES_H
#define WI_TYPES_H

/* window content are expexted to be mostly vertically oblong */

#if WKS
#include "calc/sheet.h"		/* contains IT types for worksheets */
#endif

#ifdef JOURNAL
#define alertm alert_jrnl    /* alerts with 1 button (OK) */
short alert_jrnl(char *,...);
#else
#define alertm alert_msg
#endif

#ifndef HAVE_WH
typedef struct
{
	long w,h;
} L_WH;

typedef struct
{
	short w,h;
} WH;

#define HAVE_WH
#endif

/* declarations needed before storeman.h and winfo.h */

typedef enum {LOW,HIGH} CUR_TO;
typedef enum {OFF,ON} CURST;
typedef enum {REUNDONE = -1,ALT,UNDONE} UDO;
typedef void DRAW   (struct it *w,RECT t2);
typedef void LINES  (struct it *w, short arrow);
typedef void MARGIN (struct it *w, struct stmcell *s, short y);
typedef short  ANTEVNT(struct it *w, bool w_on, short evmask);
typedef char MAP;
typedef DRAW REDRAW;
typedef void OB_PLACE(struct it *w);
typedef void CLOSED (struct it *w);
typedef void TOPPED (struct it *nw, struct it *ow);
typedef void FULLED (struct it *w);
typedef void SLIDE  (struct it *w, short hslp, short vslp, bool topw);
typedef void SLIDER (struct it *w);
typedef void ARROWD (struct it *w, short arrow, bool topw);
typedef void SIZED  (struct it *w, RECT *to);
typedef void MOVED  (struct it *w, RECT *to);
typedef void WINFO  (struct it *w);
typedef void BUTTON (struct it *w, short button, short kstate,
                                           short bclicks,
                                           short mx, short my);
typedef void KEYBD  (struct it *w, short kcode);
typedef void TIMER  (struct it *w);
typedef void CURSOR (struct it *w, CURST to);
typedef void WINIT  (struct it *w);
typedef void DEXIT  (struct it *w, short obno);
typedef bool WSELECT(struct it *w);
typedef bool EDIT	(struct it *w,short kcode);
typedef void MUIS   (struct it *w);
typedef bool DIALFI (struct it *w, Cstr zoek);
typedef void DIALREP (struct it *w);
typedef bool DRAG_SEL (struct it *w, short button, short kstate,
                                           short bclicks,
                                           short mx, short my);
typedef void CON_RET (struct it *w,char *line,short prompt,short curtask,short curstage);
typedef void WICON (short hl, RECT r, bool op, bool sel, bool kleur);
typedef bool CINFI (struct it *w,
		long cu_y,
		short to_x,
		struct cursorinfo *ci, short rich);
typedef void CINFO (struct it *w,
		struct cursorinfo *ci);

#define DIALM	100		/* max for dialogue windows;
						   OBJECT number is dialogue windows type */
#define TEXTM   200		/* max for various text type windows */
#define WKSM    300		/* max for worksheet type windows */
#define GRAPHM  400		/* max for screen bitmaps */
#define OBJM    500		/* max for Digger */
#define BINM    600		/* max for binary files */
#define TRVM	700		/* max for Tree view windows (not a file!!!) */

typedef struct l_rect
{
	short x; long y;
	short w,h;
} N_RECT;		/* special rectangle: description of units of scroll */

typedef enum
{
	BUFF = DIALM,
	JRNL,

	SRCE,
	SRC_C,
	SRC_H,
	SRC_A,
	SRC_S,
	SRC_P,

	CALC   = TEXTM,
	MAND   = WKSM,
	OBJ    = GRAPHM,
	BIN    = GRAPHM,
	DMA,
	TRV    = BINM,		/* must be the last before anything thats like DROP */
	TRVFS,
	TRVDEP,
	TRVFU,
	DROP   = TRVM		/* If MagX, fixed litle window for dropping things onto.
							Very usefull when no other windows are open. */
} INFO_T;

typedef long STMNR;

typedef struct
{
	STMNR	nr;		/* sequence number (allways first) */
	char	*text;	/* data pointer    (allways second) */
	STMNR	un,		/* old sequence number at UNDO point */
			l;		/* length of info excl terminators */
	uchar   ty,		/* type of data in s->user (not used yet) */
			rem,	/* remainder of cell left for ch insertion */
			flags;	/* misc flags pe, is_modified */
} XSTM;

typedef struct
{
	STMNR      nr;			/* sequence number (allways first) */
	struct it *w;			/* data pointer    (allways second) */
} WSTM;

#define xn  user.txt.nr
#define xun user.txt.un
#define xty user.txt.ty
#define xl  user.txt.l
#define xrm user.txt.rem
#define xfg user.txt.flags
#define xtx user.txt.text
#define wit user.winfo.w

typedef struct stmcell
{
	struct stmcell *nx;
	struct stmcell *pr;
	union
	{
		XSTM	txt;
		WSTM    winfo;
	} user;
} STMC;

typedef struct
{
	bool st_guide,		/* if true, words must be preceded by '@' */
	     a68,			/* if true, display uppercase words in bold lower case */
	     upper;			/* if true, treat upper case as lower */
	char *match,
	     **tags,
	     **at  [26];
} BOLDCAT;

typedef struct
{
	uint magic,he;
	long limage,
	     lfixup,
	     lnames,
	     res0,
	     res1,
	     res2,
	     hekp;
} PC_H;

typedef struct
{
	uint magic;
	long ltext,			/* image if PC */
	     ldata,			/* fixup if PC */
	     lbss,			/* names if PC */
	     lsym,
	     res1,
	     res2;
	short  norelo;
} DRI_H;

typedef union
{
	PC_H pch;
	DRI_H drih;
} FHD;

typedef enum {NEST,TERM,EMP} TRVty;

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

typedef struct name_nest
{
	struct name_nest *d,			/* deeper level (nil = not exploded or terminal) */
	                 *n,			/* next name same level (nil = last) */
	                 *o;			/* pointer to outer */
	short
		dep,						/* depth ( no of '\' -1 ) */
		state;						/* state (selected) */

	long
		subs,						/* no of subsiduaries */
		ln;							/* line no (behind window) */

	TRVty f;						/* directory, terminal or whatever */
	short count;
	RECT r;							/* for clicking */
	char trv_x[8];					/* extra info */
	char trv_txt[0];				/* is malloc'd */
} Nest, *NSP;

#endif
