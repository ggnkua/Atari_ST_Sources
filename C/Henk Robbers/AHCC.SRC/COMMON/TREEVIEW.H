/*  Copyright (c) 2012- present by Henk Robbers Amsterdam.
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

/*	TREEVIEW.H
 *	==========
 *
 *	Defines for showing a tree view in a window.
 */

WINIT trv_init;
ANTEVNT trv_evm;
TOPPED trv_top;
SIZED trv_sizew;
MOVED trv_movew;
BUTTON trv_button;
KEYBD trv_key;

extern M_S dmen;

#define WM 255
#define VLINE_DIST 3
#define VLINE_W (VLINE_DIST*wchar)

IT *	 treeview_window	(Cstr,
							 void *root,
		                     Cstr,
							 WINIT *,
							 DRAW *,
							 SELECT *,
							 CLOSED *,
							 KEYBD *,
							 WICON *,
							 MENU_DO *,
							 M_S *,
							 INFO_T);

NSP		trv_new_nest		(Cstr name);
void	trv_spacer			(NSP np);
NSP		trv_add_nest		(NSP in, NSP new, bool sort);
NSP		trv_set_new			(IT *w, NSP np, Cstr nm);
void 	trv_line			(IT *w, NSP np);
void	trv_deselect		(IT *w, NSP np);
void	trv_adjust			(IT *w, NSP np);
void	trv_draw			(IT *w, NSP np);
void	trv_del_nest		(NSP np);
NSP 	trv_find_sel		(NSP np);
void	trv_linenrs			(IT *w, NSP np);
NSP		trv_find_ln			(NSP np, short ln);