/*  Copyright (c) 2017 - present by Gerhard Stoll Worms, Germay
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

/*
 *	SCARP.H
 *
 */

#define SCRS 256

char *	scrap_rtxt		(char *, long *, long );
bool	get_scrapdir	(void);
void 	buf_to_scrap	(void),
		scrap_to_buf	(void),
		create_scrap	(void),
		scrap_clear		(void),
		scrap_wtxt		(char *),
		mk_scrap_name	(char *);

extern
bool have_scrap;

extern
char scrap_name[], scrap_dir[];
