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

/* 	CURSOR.H
 *	========
 */

#ifndef CURSOR_H
#define CURSOR_H

#include "common/config.h"

extern short hook,hooklevel;

typedef short  NEXT_CH(IT *w, CINF *ci);
typedef short  NEXT_WD(IT *w, CINF *fs, CINF *fe);

#define FBOUND  255		/* eof for NEXT_CH replies;
				translates to STP because \0 translates to WSP */

typedef enum	/* for regrouping of special characters */
{				/* Also used to record selection type */
	STP,		/* class nonspace nonword nonspecial */
	LOWHOOK,
	L_C = LOWHOOK,		/* {([</**/>])} */
	L_P,
	L_I,
	L_H,
	L_COM,
	L_HLEFT = L_COM,
	R_COM,
	R_H,
	R_I,
	R_P,
	R_C,
	HIGHHOOK,			/* bound for hooks */

	QUO,				/* specials (no orientation) */
	APOS,

	N_COM,				/* New Comment // */

	SHIFT_DRAG,			/* shift click  or  drag	*/
	WSP      = ' ',		/* all white space */
	SELLN,				/* shift dbl click = select line */
	LOWEST_W = '#',
	N_WH     = 10,		/* no of hooks as yet in rsc */
	HIGH_WH  = 2*N_WH + 1,
	TY_WH    = 100		/* add to word hook for ty */
} TRANS_CH;

extern TRANS_CH chcl[];

bool	cur_vis			(IT *w);
VpW		cur_on,
		cur_off;

bool	t_to_s_x		(IT *w, STMNR cuy,short cux,CINF *ci, short rich);
void	x_to_s_t		(IT *w, CINF *ci);
void	invoke_cursor	(OBJECT *m);
VpV		do_hooks;
TIMER	cur_timer, txt_timer;
EDIT	ed_key;
KEYBD	do_keybd;

NEXT_CH next_ch,
		prev_ch;
NEXT_WD	next_word,
		prev_word;
bool	select_thing	(IT *w);

/* general find: */
short	Find(IT *w,						/* window info									*/
			Cstr zoek,					/* primary string    	(OR relations)			*/
			char *zz[],					/* secondary strings	  "      "				*/
			CINF cu,					/* in:  start position of search				*/
			CINF *ss, CINF *se,			/* out: start & end of found					*/
			FIND_OPTIONS *o
/*			bool word,					/* letters & digits, but starting with a letter */
			bool beg,					/* idem but at beginning (prefix)				*/
			bool kast,					/* case sensitive								*/
			bool forw					/* direction: false = backward					*/
*/		);
/* with selection & ping: */
bool	do_find			(IT *w,Cstr zoek,char *zz[], bool surr, bool rev, FIND_OPTIONS *);
/* bool,bool,bool,bool,short); */
/* as above but use dialogue options: */
bool	dial_find		(IT *w,Cstr zoek);

bool	do_key			(IT *w,short kcode);
BUTTON	txt_click;
void	init_hooks		(OBJECT *m, short kit_i);
short 	is_hook			(char *f);
void	cat_hash		(IT *w, CINF *fs);
bool	txtsel_cursor	(IT *w, short kcode);
bool	select_line		(IT *w, STMNR l);
bool	set_line		(IT *w, CINF *ss, CINF *se);
#endif
