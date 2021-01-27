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

/* 	EDITOR.H
 *	========
 */


extern STMDEF shunt,oldshunt;
extern OBJECT *edmenu;

void	do_Edit			(IT *w,short mt,short kstate);
void	do_Buffer		(IT *w,short mt,short kstate);
void	do_Repair		(IT *w,short mt,short kstate);
void	menuenable		(bool en);
void	dis_paste_etc	(OBJECT *menu, bool dis);
void	savefile		(IT *w,char *fn,bool force);
bool	savesfile		(IT *w);
VpW		abandonfile,
		empty_undo,
		clear_undo,
		cursor_undo;
bool	check_save		(IT *w);
bool	ed_key			(IT *w,short kcode);
void	invoke_editor	(OBJECT *m);
VpV		open_buf;
FCLOSE	deletebuf;
void 	do_repl			(IT *w);
bool 	replace			(IT *w, Cstr with, short l);
void	insert_fkey		(IT *w, short which);
