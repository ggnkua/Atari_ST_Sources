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

/*
 *  init_cc.c
 *			      for if BIP_CC  (compiler builtin in GEM progr)
 */

#include <stdio.h>
#include <string.h>
#include "param.h"
#include "common/pdb.h"

void adddef(Cstr);
void subdef(Cstr);

extern
DEFS defines[];
extern
NODESPACE xspace[], initspace[];

global
void init_cc(void)
{
	short i;

	zero(G);

	G.e_max_errors   = MAXERRS;
	G.f_max_warnings = MAXWARNS;
	G.l_identifier_max_length = 32;
	G.tk_flags = TK_SAWNL;    /* 03'09 */

	bugf = stdout;
	G.npred = 0;

	adddef("__MC68000__=1");
	adddef("__TURBOC__=1");
	adddef("TURBO_C=1");		/* 06'19 HR: very old Pure C projects */
	adddef("__PUREC__=1");
	adddef("__bool_true_false_are_defined=1");		/* C99 */

#if FOR_A
	adddef("__ABC__=1");
	adddef("__AC__=1");		/* scheduled for redundancy */
#endif

	adddef("__AHCC__=1");
	adddef("__ATARI_ST__=1");
	adddef("__TOS__=1");

	G.idir_n = 0;		/* number of entries in include table */

	for(i = 0; i<XXr; i++)
		xspace[i] = initspace[i];
}
