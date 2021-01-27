/* Copyright (c) 1988,1989 by Sozobon, Limited.  Author: Tony Andrews
 * Copyright (c) 1990 - present by H. Robbers.   ANSI upgrade.
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
 *	opt.h
 *
 * TONY_H either original code by Tony Andrew or Tony's code sped up by me (HR)
 */

#define TONY 1		/* 1 = Use original health analysis by TONY_H's with option -t
					       or when a functions has loop(s) in it.
					   2 = Always use TONY_H's code.
						   Performs better with small loops in small functions. */
#define TONY_H "tony.h"	/* Test (or use) improvements of tony's health. */

#define DBGB 0
#define DBGH 0

typedef struct asmtable
{
	struct asmtable *link;
	char *name;
	ASMOP tok;
} ASM_TAB;

#define OPHASH 127

Wstr	optimize(void);
short 	is_lbl		(Cstr);
BP		getsym		(Cstr),
		mksym		(Cstr);
void	add_debug	(IP ip, Cstr s);
bool	ipeep0		(BP bp, IP ip);
void	All_inst	(BP, bool, Cstr, ...);
void	All_blocks	(BP, bool, Cstr);

#if AMFIELDS
bool	is_dreg		(OPMODE, short);
bool	is_freg		(OPMODE, short);
bool	is_areg		(OPMODE, short);
#else
bool	is_dreg		(short,  short);
bool	is_freg		(short,  short);
bool	is_areg		(short,  short);
#endif

bool	op_dreg		(OPND *);
short 	ophash		(Cstr);
ASMOP	find_op		(char *);
void	IXC_inst	(IP);
bool	m_no_absw	(OPMODE, short);

extern short cur_proc;
extern IP regi, loci;
