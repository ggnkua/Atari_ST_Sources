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
 * assembler definitions
 *
 */

typedef
void	 p_A	(struct inode *ip, short tok, OPND *arg, OPND *dst),
    	 w_A	(struct inode *ip);

enum
{
	NOASOP,
#define DEF_AS_ENUM 1
#include "as_defs.h"
};

typedef struct
{
	char *text;
	p_A *parse;
	w_A *out;
	short
		defsz,			/* 0 no size field, #0 default size */
	    cc,				/* cc predicate for branch or test instructions */
	    cpu,
	    flag;
} ASDATA;

extern ASDATA asdata[];

enum cpus
{
	_family,
	_1 =    01,			/* 68010 */
	_2 =    02,			/* 68020 */
	_3 =    04,			/* 68030 */
	_4 =   030,			/* 68040 or 68060 */
	_6 =   020,			/* 68060 */
	_32=   040,			/* CPU32 */
	_CF=  0100,			/* coldfire */
	_5 =  0200,			/* 68851 */
	_8 =  0400,			/* 68881/2 */
	_S = 01000,			/* privileged */
	_H = _2|_3|_4|_6	/* all except 68010 */
};

enum mmureg
{
	VVAL = Rinv,				/* for pvalid */
	TT0  = 0020,
	TT1  = 0030,
	TC   = 0200,
	DRP  = 0210,
	SRP  = 0220,
	CRP  = 0230,
	CAL  = 0240,
	VAL  = 0250,
	SCC  = 0260,
	AC   = 0270,
	MMUSR= 0300,
	PSR  = 0300,
	PCSR = 0310,
	BAD0 = 0340, BAD1, BAD2, BAD3, BAD4, BAD5, BAD6, BAD7,
	BAC0 = 0350, BAC1, BAC2, BAC3, BAC4, BAC5, BAC6, BAC7
};

enum condreg
{
	CCR, SR, USP
};

enum cachereg
{
	NoC, DaC, InC, BoC
};

enum addr_modes
{
	AM_ALL,
	AM_C_ALT,
	AM_C_ADD,
	AM_M_ALT,
	AM_M_ADD,
	AM_D_ALT,
	AM_D_ADD,
	AM_ALTER,
	AM_CTRL,
	AM_DN  = 0x100,		/* extras */
	AM_INC = 0x200,
	AM_DEC = 0x400
};

#define AS_PARSE_OK ip->opcode = tok

VpV new_dotscope;
