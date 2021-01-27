/* Copyright (c) 1990 - present by H. Robbers.
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

/* defines for the AHCC lex system */

#ifndef C_LEX_H
#define C_LEX_H

#include "prelude.h"

extern uchar C_hex[], C_oct[];
extern long line_no;

enum
{
	eof,
	ide,
	oct,
	dig,
	hex,
	spl,
	nl,
	com,
	op,
	mop,
	op2,
	op3,
	X,
	ws,
	quo,
	apo,
	cok,
	Last,
};

typedef struct lex_record
{
	uchar rl, cat;		/* token length, catagory */
	char text[0];		/* text of token at least a \0 */
} LEX_RECORD;

#define SCONSPLIT 1
enum
{
	size_LEX = sizeof(LEX_RECORD),
	dummy,
	res_LEX,
	MAX_LEX  = 255,						/* 07'15 v5.2 */
	MAX_SCON = MAX_LEX - size_LEX - 1	/* 07'15 v5.2 */
};

#define next_LEX(r) (LEX_RECORD *)((char *)r + r->rl)
#define LEX_next(r) ((char *)r += r->rl)

typedef void	VpPE	(Cstr, ...);

void pr_lex(LEX_RECORD *s, char *txt);
long C_lexical(Cstr name, bool, Cstr, LEX_RECORD *, long *, VpPE *, bool, short);

#if 1
#define break_in (Kbshift(-1)==3)
#else
#define break_in (0)
#endif

#endif
