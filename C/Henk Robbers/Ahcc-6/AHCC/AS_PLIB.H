/* Copyright (c) 2004 - present by H. Robbers.
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
 * assembler
 *
 */

enum imm_kind {IMMXPR, IMMCONS};

short 	opnd_err	(short n, Cstr msg);
void	ea_error	(short n, short type);
void	cpuerr		(void);
OPND *	new_arg		(void);
bool	immediate	(OPND *, bool cons, short);
OPND *  p_ea		(OPND *, short type, short n);
bool	check_ea	(OPND *, short type);
bool 	check_imm	(long l, short sz, short n);
bool	p_isareg	(void * np);
bool	p_isdreg	(void * np);
bool	p_isfreg	(void * np);
