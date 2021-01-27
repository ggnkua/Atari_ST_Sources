/*  Copyright (c) 1987 - 1991 by Han  Driesen Leiden.
 *            (c) 1996 - 2008 by Henk Robbers Amsterdam.
 *
 * This file is part of Atari Digger.
 *
 * Digger is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * Digger is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Digger; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

/* 	DIGIT.C
 *	=======
 */

/* prototypes using IT */

typedef RXY *KEPT(IT *w, short x, short y);
void pc_rel(IT *w,PCB a);

void page		(IT *w);
void il			(IT *w),
     nl			(IT *w, short);

void other_machine(IT *w,bool draw);
void settabs	(IT *w);
bool load_idx	(IT *w, char *fn);
bool save_idx	(IT *w, char *fn);
bool load_idf	(IT *w, char *fn);
bool save_idf	(IT *w, char *fn);
void delete_index(IT *w);

long get_addr	(IT *w, char * s);
void do_select	(IT *w, short sel);
PC scan_DRI		(IT *w);
void scan_PC	(IT *w);
PCB scan_PRG	(IT *w);
bool user_hname	(IT *w, HSYM *s, LAB new);
void mark		(IT *w, MARK *do_mark,MARK *do_clr, short s);
void jmpwmark	(IT *w, MARK *do_mark);
void mark_long	(IT *w, short s);
void user_names	(IT *w, FILE *fp);
bool erase_name	(IT *w, HSYM *s, long old);
void bookmark_msg(IT *w, void (*msg)(char *text, ...), long org, char *b, char *n);
void l_opt		(IT *w,short new_m,bool draw);
void opt		(IT *w,short new_m,bool draw);
void scan_reloc	(IT *w);
void labels		(IT *w);
void symbols	(IT *w);
bool alloc_jt	(IT *w);
void make_vis_pc(IT *w,PC pc);
bool fcfg_idx	(IT *w, char*);
void init_labs	(IT *w);
bool abs_label	(IT *w);
void dat_to_w	(IT *w);
void mask20		(IT *w);
void listfixups	(IT *w);
void tk_dial	(IT *w, short mn, short mt);

DRAW			draw_page,write_page;
SLIDER			sliders;
MENU_SET		set_menu;
CON_RET			set_dat;
KEPT which_label,which_lname,which_line;
void listsym	(IT *w, SYM *sy, bool lnk,	long ld,
									long htext,
									long hdata,
									long hbss,
				 bool es);		/* 5'99 RA: es */
void diskit_fresh(IT *w);
void do_mach	(IT *w, short mt);
void set_wordop	(TTD_PROF *w);
