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
 * Basic defines and declarations for the optimizer.
 * Optimizer now integrated in the compiler.
 */

#if OPTBUG
	#define PDBG(x, y) {add_debug(x, #y);peepcnt.y++;}
#else
	#define PDBG(x, y)
#endif

#define AMFIELDS 0		/* 1: experimental */

#include "peepstat.h"

/*
 * Instruction constants
 */

typedef enum
{
/*
 * Addressing modes in OPND.amode
 */
	NONE,			/* 0 operand unused */
	REG,			/* 1 register direct */
	REGI,			/* 2 reg. indirect */
	REGINC,			/* 3 reg. indirect + post increment */
	DECREG,			/* 4 reg. indirect + pre decrement */
	REGID,			/* 5 reg. indirect, w/ displacement */
	REGIDX,			/* 6 reg. indirect, w/ displacement & index */
	REGIDXX,		/* 7      with 020+ extensions */
	PCD,			/* 8 PC relative, w/ displacement */
	PCDX,			/* 9 PC relative, w/ displacement & index */
	PCDXX,			/* 10      with 020+ extensions */
	IMM,			/* 11 immediate */
	ABS,			/* 12 absolute */
	INSTD,			/* 13 instruction relative w/ displacement */
	RLST,			/* 14 register list */
	CONDREG,		/* 15 condition register (in opnd.disp) */
	SPPLUS,			/* 16 (sp)+ operand */
	FCREG			/* 17 FP control reg */
} ADMODE;

/*
 *  flags over OPND.am
 */
typedef
#if AMFIELDS
union
{
	struct
	{
		ubits
			dec   : 1,		/* postincrement (An)+ */
			inc   : 1,		/* predecrement -(An) */
			mind  : 1,		/* memory indirection (optional with POSTI or PREI) */
			odisp : 1,		/* have outer displacement */

			bdisp : 1,		/* have base  displacement */
			absw  : 1,		/* ABS or BDISP positively .w */
			absl  : 1,		/*      idem               .l */
			symb  : 1,		/* symbol used, not constant */

			xl    : 1,		/* long index register used */
			resv  : 2,

			m     : 5;		/* basic addressing mode */
	} f;
	ushort i;
#else
enum
{
	ABSL   = 0x0080,

	XLONG  = 0x0100,
	SYMB   = 0x0200,
	ABSW   = 0x0400,
	BDISP  = 0x0800,

	ODISP  = 0x1000,
	MIND   = 0x2000,
	INC    = 0x4000,
	DEC    = 0x8000,

	POSTI  = INC,			/* or memory indirect post indexed */
	PREI   = DEC,			/* or memory indirect pre  indexed */
#endif

} OPMODE;


#if AMFIELDS
#define MO(a) (a).i
#else
#define MO(a) a
#endif

#define DBGA2 0

typedef struct
{
	ubits
		jsl     : 1,		/* block contains 1 or more calls to local proc */
#if DBGA2
		has_trap : 1,		/* The function issues 1 or more trap's */
#endif
		has_loop : 1,		/* The function has a loop in it */
		loop    : 1,		/*  result of C while, do or for.
							    block is first of the loop (all label references are forward!
								except the 1 back to the first instruction of a loop) */
		swt     : 1,		/* block terminates with a 'dc' (so contains a switch) */
		mark    : 1,		/* temporary 'touched' mark */
		ret     : 1,		/* block terminates with a 'return' */
		reached : 1,		/* block IS reached (for switches) */
		label   : 1,		/* the block needs a label */
		touched : 1,		/* used in traversals */
		is_global : 1;		/* is the block's symbol global? */
} BFLAGS;

/*
 * flags in IDATA.iflag
 */
typedef enum
{
	SIDE  = 0x001,		/* inst. has side-effects */
	CCU   = 0x002,		/* inst. uses condition codes Scc FScc */
	REVDD = 0x004,		/* ..s dx dy --> ..x dy dx (motorola dn,<ea> and <ea>,dn) */
	REVD  = 0x008,		/* ..s    dy --> ..x dy     single operand equivalent */
	SET   = 0x010,		/* operand is set */
	REF   = 0x020,		/* operand is referenced */
	RTN   = 0x040,		/* is return */
	USG   = 0x080,       /* insts whose usage we are to try to avoid */
	LEA   = 0x100,		/* inst that takes address */
	SX    = 0x200		/* inst has only a single operand which is either
	                       reg or arg (see flags) or reg and arg are the same. */
} IFLAG;

#define AMFLGS  0xffe0
#define MO_FF   0x001f

#if AMFIELDS
#define	MM(x)	((x).f.m)
#else
#define	MM(x)	((x) & 0x1f)
#endif


/*
 * Misc. define's, etc. for instruction parsing.
 */

#define DEF_PO_ENUM 1
typedef enum
{
	INVOP,
#include "po_defs.h"
} ASMOP;

enum 		/* loc var type */
{
	DRG = 1,		/* normal data */
	FRG,			/* h/w floating */
	PTR,			/* pointer */
	ARD				/* area disp */
};

typedef struct opnd
{
	struct	opnd *next;	/* list of operands */
	struct	opnd *outd;	/* outer displacement (for astr, disp, aname & namedisp fields )*/
	long	disp,		/* also used for immediate data */
			namedisp;	/* displacement of name within area */
	Cstr	astr;		/* pointer to any symbol present */
	VREG_INFO	vreg;
	short	areg,	/* primary register or std area class number*/
			ireg;	/* index register, if applicable or real area number */
	OPMODE	am;		/* addressing mode used */
	ubits	aname : 1,	/* name has <area.disp> */
			gl    : 1,	/* name is global (for AS) */
			scale : 4,	/* scale factor for ireg (68020+) */
			type  : 4,	/* in case of loc var, type (PTR, DRG, FRG) */
			dum   : 6;
	char	fldo,	/* field offset */
			fldw;	/* field width */
	short	tlab;
} OPND;

/*
 * idata
 *
 * For each instruction, we have some global information, as well
 * as flags indicating what the instruction does with its operands.
 * We need to know if each operand is set and/or referenced. If the
 * instruction has side effects not directly related to its operands,
 * we need to know that as well, so "special case" code can deal with
 * that as well.
 */

typedef
void o_A(struct inode *ip);

typedef struct
{
	char *text;
	o_A  *opr;
	short
		defsz,			/* 0 no size field, #0 default size */
	    cc,				/* cc predicate for branch instructions */
	    iflag,			/* flags regarding the entire instruction */
	    regf,			/* flags for the reg, first and second operands */
	    argf,
	    dstf;
} IDATA;

/*
 * DxxOK(x) - evaluates TRUE if 'x' is okay for a displacement value.
 *
 * 'x' must be of type "long"
 */
#define	D16OK(x)	(((x) >= -32768L) && ((x) <= 32767L))

/*
 * D8OK(x) - like D16OK but for 8-bit displacements
 * D3OK for 3-bit
 */

#define	D8OK(x)	((x) >= -128 && (x) <= 127)
#define D3OK(x) ((x)                <= 8)

/*
 * Optimization stats
 */
extern
short
	s_bdel,
	s_badd,
	s_brev,
	s_peep1,
	s_peep2,
	s_peep3,
	s_idel,
	s_reg,
	s_movem,
	s_lnk,
	flows,
	peep_loops;

extern IDATA idata[];
extern RMASK loclist,		/* for mms mmx (movem) (uitsplitsing integral & float) */
             anywhere_used,
             anywhere_set;	/* for regdown */

#define OPFS(y)  (	    op2 eq y\
					and i1->iflg.i eq i2->iflg.i\
					and i1->sz     eq i2->sz)

#define is_return(x) (idata[(x)].iflag&RTN)
