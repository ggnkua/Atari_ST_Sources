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

/* 	TEXT_CFG.H
 *	==========
 */

CFG_LOCAL
		txt_local		(void);
void	init_txtcfg		(KIT_REFS *k);
void	do_txtcfg		(IT *w);
void	txtkit_fresh	(IT *w);
void	change_txtkit	(KIT_REFS *k, IT *w, IT *wd);
bool	save_txtconfig	(void);
bool	load_txtconfig	(void);
