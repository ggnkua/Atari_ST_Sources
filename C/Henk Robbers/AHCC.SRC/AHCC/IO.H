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
 */

/*
 *	io.h
 */

extern Wstr out_goes, out_buf;
extern long out_l;

#define L_OUT (80+2*256)  /* a full line with 2 full operand names */

VpV		init_cc, init_po;
char *	CC_load		(Cstr name, short *fh, long *l, Cstr opm, short key);
char *	Cload		(Cstr fname, short *fh, long *l, Cstr opm);
char *	Fload		(Cstr fname, short *fh, long *l, short key);
CP		load_source_file (Cstr name, short *count);
AHCOUT *open_S		(Cstr fn);
short 	close_S		(AHCOUT *fd);
void	send_msg	(Cstr text, ...);
void	console		(Cstr text, ...);
