/*  Copyright (c) 1990 - present by Henk Robbers Amsterdam.
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

/* 	FILES.H
 *	=======
 */


typedef struct f_cfg
{
	struct f_cfg *n;
	INFO_T ty;
	MAX_dir name;
	bool selection;
	CINF cu,se;
	short sty;
	CFG_LOCAL loc;
	OpEntry *tab;
} F_CFG;

extern bool init_open_jrnl;

bool	write_out		(IT *w, char *fn);
bool	collect			(IT *w);
bool	savemsgfile		(IT *w);
void	not_found		(Cstr fn);
void	init_files		(short argc, char *argv[]);
void	do_Open			(short mt);
void	do_Lua			(short mt);
void	open_text_file	(char *fn);
void	open_startfile	(char *fn, short fl, short ty, F_CFG *q);
void	init_fs			(void);