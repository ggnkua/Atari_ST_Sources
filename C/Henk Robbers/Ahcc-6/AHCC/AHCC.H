/* Copyright (c) 1988 by Sozobon, Limited.  Author: Johann Ruegg
 *           (c) 1990 - present by H. Robbers.   ANSI upgrade.
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
 *
 *	ahcc.h
 */

extern long line_no, n_line_no, bin_size;
extern Cstr Error,Warning,Message,Comment,W,Fatal;

extern short depth;	/* set and owned by the shell,
						if no shell, not used. */

short 	main		(short argc, char **argv);

VpI		waitexit;

void	error		(Cstr, ...),
		warn		(Cstr, ...),
		message		(Cstr, ...),
		errorn		(void *, Cstr, ...),
		warnn		(void *, Cstr, ...),
		messagen	(void *, Cstr, ...),
		send_incname(short, Cstr incname);

