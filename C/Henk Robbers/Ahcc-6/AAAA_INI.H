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

/* AA_INI.H
 * ========
 */

#ifndef AA_INTRO_H
#define AA_INTRO_H

#ifdef RSRC_H
	#include RSRC_H			/* drives most of the conditional program production
							   taken from a [-D] in the project file (see also RSRC_RSC) */
#endif

#include "aaaa_cfg.h"

typedef struct scrollinfo
{
	short m1,
	      arrow,
	      grtel,
	      grnoem;
} SINF;

typedef enum
{
	IS_OBJECT,
	IS_MENU,
	TCSL = 40
} TREETY;

typedef char TCS[TCSL];

typedef struct cfg_local
{
	short
		vistab,		/* Visible tab character							*/
		vistco,		/* if visible tab fill to target position			*/
		tabn,		/* apparent tabsize	for Fix tabulate				*/
		tabp,		/* physical tabsize for retabulation				*/
		tabl,		/* retab only leading white space					*/
		tabs,		/* tabsize											*/
		split;		/* Split line on last space before split chs.		*/
	bool
		lib_str,
		rootname,
		ai,			/* autoindent cq autocalc							*/
		trail,		/* if true, remove trailing spaces when saving		*/
		boldtag,	/* reserved words are bold tags						*/
		lnrs,		/* line numbers										*/
		font;		/* normal or small font								*/
	SINF
		sch,		/* scroll info  hor									*/
		scv;		/*    "     "   vert								*/
} CFG_LOCAL;

typedef struct charset
{
	char v[8][34];
} CHARSET;

typedef struct ttd_profile
{
	CHARSET cust;
	char invisible[2];

	bool
		kb[5],
		mccf,
	    mc00,
	    mc20,
		mc30,
		mc40,
		mc60,
		mc51,
		mc81,

		dblf,
		wabx,
		dirw,

		labnl,
		opoct,
		dec,

		opc,
		asc,
		opasc,
		stand,
		lbl,
		sym,

		usysv,
		isysv,
		tosimg,		/* 151002 */
		v95,
		vger,
		vfra,
		vlat,
		vsca,
		vmat,
		vall,
		vnon,
		vcustom,
	    wordop,
		diags;

	TCS kt[5],
	    sec_text,
	    sec_data,
	    sec_bss,
	    xdef,
	    xref,
	    comm,
	    moduul,
	    endmod,
		equ,
		sbr,
		wbr,
		lbr,
		wordabs,
		longabs,
		wordops,
		labelsep,
		copref,
		kpref,
	    r16,
		illegal,
		src_ext,
		hex_ext,
		asx_ext;

	MAX_dir
	    rnamApath,		/* global namA */
		wnamApath,
		include,		/* template */
		sysvcom,		/* global equ's */
		sysvend,
		idxcom,			/* local equ's */
		idxend;
	CHARSET svvis;		/* remember of true characters */
	char tvis[260];			/* catenation of true characters */
	bool sym1;
	short rdx;
} TTD_PROF;

typedef unsigned short *PCU;
typedef short *PCW;
typedef long *PCL;		/* toch wel handig dat C */
typedef char *PCB;		/* PCL & PCB mostly for casting */

typedef union
{
	PCB b;
	PCW w;
	PCL l;
	uchar *k;
	uint *u;
	long i;
	ulong ui;
} PC;

typedef struct
{
	short ty;
	MAX_dir name, idx_name;
	bool idx;
	short  tabber;
	bool haveoff;

	long offset;
	PC   spg;
} TTD_CFG;

typedef struct d_cfg
{
	struct d_cfg *n;
	TTD_CFG cf;
	TTD_PROF cg;
} D_CFG;

/*
typedef struct f_cfg
{
	struct f_cfg *n;
	short ty;
	MAX_dir name;
	bool selection;
	CINF cu,se;
	short sty;
	CFG_LOCAL loc;
	OpEntry *tab;
} F_CFG;
*/

#define TST_MARGIN 0	/* 6 for margin for text (eg for line numbers) (+1) */
#define MINMARGIN (deskw.unit.w/2)

typedef void VpV	(void), VpI(short);
typedef bool BpV	(void);
typedef void FOPEN	(Cstr fn, short fl, void *q);

typedef char *COPRMSG[];
typedef void COPRM(short *w, short *h, COPRMSG msg);

#ifndef PDW
#define PDW void
#endif

#endif
