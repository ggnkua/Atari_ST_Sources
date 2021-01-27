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

/* 	TEXT.H
 *	======
 */

extern M_S tmen;
extern bool abandon_ins;

#define HIGH_VAL 0x7fffffffL
#define high(s) (s ? s->xun : HIGH_VAL)
#define APRCT 66

STMC *	ins_text		(STMACC acc,IT *w,char *text, ...);
void	clearmal		(STMDEF *d);
STMC *	find_line		(IT *w,long zoek);
STMC *	find_current_line(IT *w);
short 	de_tab			(char *to, char *fro, short tabs, short vis, short vco, short maxw);
short 	totab			(short c,short t);
void 	read_tags		(void);
IT *	open_X			(char *fn);
void	close_X			(IT *w);
DISP	disp_line,
		disp_nosel;
FOPEN	open_text;
MENU_DO do_tmenu;
ANTEVNT text_evm;		/* IT *w; bool w_on, short evmask */
CLOSED	close_text;
DRAW	display;
FULLED	text_full;
KEYBD	txtsel_keybd;
WINIT	txt_winit;

LINES 	text_lines;
VpW 	make_lines;
bool	ascii_file		(uchar *s, size_t l);
VpW		printfile;
bool	close_textfile	(IT *w, bool force);
IT *	editor_window	(bool cre, Cstr name, char *info,
						short kind, short fl, short type,
						char *map, long mapl,
						MENU_DO do_menu, M_S *m_s_menu, EDIT ed_key,
						CLOSED closer, FCLOSE deleter,
						FULLED fuller, TIMER timer,
						WINIT winit                 );
void	txt_margin		(IT *w,STMC *s,short y);
char *	condense		(IT *w, long *mapl, void *base);
void	f_txt			(short,short,short,char *);		/* aligned text */
