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

/*
 *	TTDKIT.H
 *
 */

#ifndef CONFIG_H
#include "common/config.h"
#endif

typedef struct kit_refs
{
	OBJECT
		*tree;
	TEDINFO
		*ppupath,
		*width,
		*height,

		*kt[5],

		*sec_text,
		*sec_data,
		*sec_bss,
		*xdef,
		*xref,
		*comm,
		*moduul,
		*endmod,
		*equ,
		*sbr,
		*wbr,
		*lbr,
		*wordabs,
		*longabs,
		*wordops,
		*labelsep,
		*copref,
		*kpref,
		*r16,
		*illegal,
		*src_ext,
		*hex_ext,
		*asx_ext,
		*rnamApath,
		*wnamApath,
		*include,
		*sysvcom,
		*sysvend,
		*idxcom,
		*idxend,
		*invisible;
	char
		*vis[8];
} KIT_REFS;


VpV		invoke_ttdkit,
		end_ttdkit;

CHARSET *	curr_cs		(TTD_PROF *w);
void		text_to_vis	(KIT_REFS *k, TTD_PROF *w);
void		vis_to_text	(KIT_REFS *k, TTD_PROF *w);

extern KIT_REFS pkit;
