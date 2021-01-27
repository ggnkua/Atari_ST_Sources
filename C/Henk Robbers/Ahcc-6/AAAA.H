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
 * MERCHANTABILITY or FITNxESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with AHCC; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

/* 	AAAA.H
 *	======
 *
 *   The ultimate GEM program.
 */

#ifndef AAAA_H
#define AAAA_H

#ifndef HIERARCH_H
#include "common/hierarch.h"
#endif

#ifndef AA_INTRO_H
#include "aaaa_ini.h"
#endif

#include "common/win_menu.h"	/* also sets WMENU */
#include "aaaa_win.h"			/* VOOR ahcc_stm & windows.h */
#include "common/windows.h"

#define WINX 1		/* do force redraw na bounce */

/* Readme: aaaa.txt */

#define noPRINFO
#define INTERNAL 0   /* do internal errors */
#define noCURKADER
#define SERIALSTM
#define get_tedinfo(o,i) o[i].spec.tedinfo

#define FTED(n, i) k->n = k->tree[i].spec.tedinfo
#define FSTR(n, i) k->n = k->tree[i].spec.free_string

#define FBUT(n, i) w->n = (k->tree[i].state & SELECTED) ne 0
#define FCDBV(n) w->n = cdbv(k->n->text)
#define F2CDBV(n, m) w->n = cdbv(k->m->text)
#define FTXTGET(n) strsncpy(w->n, k->n->text, k->n->txtlen)

#define FSTATE(n, i) if (w->n) k->tree[i].state|=SELECTED; else k->tree[i].state&=~SELECTED
#define FBIN(n)     strsncpy(k->n->text, cbdu(w->n, k->n->txtlen-1,'0'), k->n->txtlen)
#define F2BIN(n, m) strsncpy(k->n->text, cbdu(w->m, k->n->txtlen-1,'0'), k->n->txtlen)
#define FTXTSET(n) strsncpy(k->n->text, w->n, k->n->txtlen)

#define CBIN(n)    sprintf(pkit.n->text, "%d", SHL_cfg.n)
/*
#define C2BIN(n,m) sprintf(pkit.n->text, "%d", SHL_cfg.m)
*/
#define get_freestring(o,i) o[i].spec.free_string

#ifdef SERIALSTM
#define STMMODE SERIAL
#else
#define STMMODE CYCLIC
#endif

	/*      cursor is kader;                 mouse is ARROW/TEXT_CRSR */
#define noCURLINE
	/* else:cursor is black box or low line; mouse is ARROW/kader     */

#define YD ((2+YDP)*(INFO_H+1))

#define BITS8	255
#define MAXL	248			/* maximum textline length (excl \0) */
#define MAXJ	79			/* maximum minicons input line; must NOT be more than 131 */
#define LSEL	40			/* alloc length find strings */
#define FBS		10			/* no of Find strings */
#define FSL		80
#define FKS		20			/* no of function keys */
#define FKL		80

#define XA_TCHUNK (1L<<14)	/* 16384 */
#define STMS	((XA_TCHUNK/sizeof(STMC))+1)	/* allocation unit storemanager (lines) (tuned to malloc chunksize of XA_TCHUNK) */
#define LABELS  200								/* idem           (disassembler)	*/
#define HIDE 	true		/* do wind_update en hidem en ev cur_off */
#define NO_HIDE false
#define cur_on(w) (*w->cursor)(w,ON)
#define cur_off(w) (*w->cursor)(w,OFF)

#if WINDIAL or WIN_OB
#define wdial_on(w) wdial_cur(w,ON)
#define wdial_off(w) wdial_cur(w,OFF)
#else
#define wdial_on(w)
#define wdial_off(w)
#endif

#if 0
#define TRACE(a)  form_alert(1,"[0][-=" #a "=-][OK|NO]");
#define TREES(a)  alert_text("-= %d =-", a);
#else
#define TRACE(a)
#define TREES(a)
#endif

#if __AHCC__
#define TR(a,b)
#else
#define TR(a,b) alert_text(a,b)
#endif

#define ALMENU	false
#define ALMOUSE true
#define WIDIVMAX 9		/* max no windows involved in tile/overlap */
#define MAX_W	(640-20)		/* max width used for open, full etc. */

#define pdial -2		/* in ieder geval AES 0.19 form_dial patch w&h */

#define OPEN_ANY		/* or OPEN_ANY_IS_LAST */

short Pdomain(short);

/* export globals of AAAA */
extern char obty[][12],
			lost_cw[],
			prg_name[];
extern short points, hpoints, aes_keycode, aes_keystate, wchar, hchar;
extern STMDEF winbase;
extern STBASE *txtfreebase;
extern IT deskw, *dirw;
extern RECT  wi;			/* afmeting gecentreerde template box */
extern OBJECT  *Menu;
extern M_S mainmenu;
extern bool showchange;
extern bool m_alerted;
extern short (*alert_cur)	(short, const char *);

#define DRECT "%d/%d,%d/%d"

VpV		marrow;
void	start_help		(char *);
char *	frstr			(short ob);
short 	half_h			(void);
void	do_dial			(OBJECT *O,short f);
void	wwa_align		(OBJECT *ob,IT *w);
short 	eruit			(short r);
MENU_DO do_menu;
void	w_top			(short mn, IT *w, IT *wt);
short 	alert_msg		(char *t, ... );		/* via alert_cur */
void 	mem_alert		(char *op1, char *op2);
void *	mmalloc			(long l,char *op1,char *op2, short key);
IT *	get_second		(IT *w, WSELECT *sel);

#endif