/* Copyright (c) 1988,1989 by Sozobon, Limited.  Author: Tony Andrews
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
 *	inst.h
 */

#include "common/qmem.h"
#include "common/amem.h"

bool	opeq	(const OPND *, const OPND *, bool),
		regeq	(OPND *, ACC reg);

RMASK	reg_ref	(IP),
		reg_set	(IP);

void	uprefs	(IP ip);

IP		addinst	(BP, char *, char *, char *, char *),
		delinst	(BP, IP),
		instbefore	(BP, IP, bool with_arg),
		instafter 	(BP, IP, bool with_arg);

ASMOP	get_opcode	(char *);

short	ophash		(Cstr key);

extern MEMBASE opndmem;
