/* Copyright (c) 1988,1991 by Sozobon, Limited.  Author: Tony Andrews
 *
 * Permission is granted to anyone to use this software for any purpose
 * on any computer system, and to redistribute it freely, with the
 * following restrictions:
 * 1) No charge may be made other than reasonable charges for reproduction.
 * 2) Modified versions must be clearly marked as such.
 * 3) The authors are not responsible for any harmful consequences
 *    of using this software, even if they result from defects in it.
 */

/*
 * Routines for data flow analysis of a single instruction
 */

#include "top.h"

/*
 * idata
 *
 * For each instruction, we have some global information, as well
 * as flags indicating what the instruction does with its operands.
 * We need to know if each operand is set and/or referenced. If the
 * instruction has side-effects not directly related to its operands,
 * we need to know that as well, so "special case" code can deal with
 * that as well.
 */
struct	idata	{

	char	iflag;		/* flags regarding the entire instruction */
#define		SIDE	0x01	/* inst. has side-effects */
#define		CC	0x02	/* inst. munges condition codes */

	char	op1f;		/* flags for the first and second operands */
	char	op2f;
#define		SET	0x01	/* operand is set */
#define		REF	0x02	/* operand is referenced */

} idata[] =
{
	{ CC,		REF,		REF|SET },	/* OR */
	{ CC,		REF,		REF },		/* BTST */
	{ 0,		REF,		SET },		/* MOVEP */
	{ CC,		REF,		REF|SET },	/* BCHG */
	{ CC,		REF,		REF|SET },	/* BCLR */
	{ CC,		REF,		REF|SET },	/* BSET */
	{ CC,		REF,		REF|SET },	/* AND */
	{ CC,		REF,		REF|SET },	/* SUB */
	{ CC,		REF,		REF|SET },	/* ADD */
	{ CC,		REF,		REF|SET },	/* EOR */
	{ CC,		REF,		REF },		/* CMP */
	{ CC,		REF,		SET },		/* MOVE */
	{ CC,		REF|SET,	0 },		/* NEGX */
	{ CC,		REF,		REF },		/* CHK */
	{ 0,		REF,		SET },		/* LEA */
	{ CC,		SET,		0 },		/* CLR */
	{ CC,		REF|SET,	0 },		/* NEG */
	{ CC,		REF|SET,	0 },		/* NOT */
	{ CC,		REF|SET,	0 },		/* NBCD */
	{ CC,		REF|SET,	0 },		/* SWAP */
	{ SIDE,		REF,		0 },		/* PEA */
	{ CC,		REF|SET,	0 },		/* EXT */
	{ SIDE,		REF,		SET },		/* MOVEM */
	{ CC,		REF,		0 },		/* TST */
	{ CC,		REF|SET,	0 },		/* TAS */
	{ 0,		REF,		0 },		/* TRAP */
	{ SIDE,		REF|SET,	REF },		/* LINK */
	{ SIDE,		REF|SET,	0 },		/* UNLK */
	{ 0,		0,		0 },		/* RESET */
	{ 0,		0,		0 },		/* NOP */
	{ CC,		REF,		0 },		/* STOP */
	{ SIDE|CC,	0,		0 },		/* RTE */
	{ SIDE,		0,		0 },		/* RTS */
	{ 0,		0,		0 },		/* TRAPV */
	{ SIDE|CC,	0,		0 },		/* RTR */
	{ SIDE,		REF,		0 },		/* JSR */
	{ 0,		REF,		0 },		/* JMP */
	{ CC,		REF,		REF|SET },	/* ADDQ */
	{ 0,		SET,		0 },		/* ST */
	{ CC,		REF|SET,	REF },		/* DBT */
	{ CC,		REF,		REF|SET },	/* SUBQ */
	{ 0,		SET,		0 },		/* SF */
	{ CC,		REF|SET,	REF },		/* DBRA (dbf) */
	{ 0,		SET,		0 },		/* SHI */
	{ CC,		REF|SET,	REF },		/* DBHI */
	{ 0,		SET,		0 },		/* SLS */
	{ CC,		REF|SET,	REF },		/* DBLS */
	{ 0,		SET,		0 },		/* SCC */
	{ CC,		REF|SET,	REF },		/* DBCC */
	{ 0,		SET,		0 },		/* SCS */
	{ CC,		REF|SET,	REF },		/* DBCS */
	{ 0,		SET,		0 },		/* SNE */
	{ CC,		REF|SET,	REF },		/* DBNE */
	{ 0,		SET,		0 },		/* SEQ */
	{ CC,		REF|SET,	REF },		/* DBEQ */
	{ 0,		SET,		0 },		/* SVC */
	{ CC,		REF|SET,	REF },		/* DBVC */
	{ 0,		SET,		0 },		/* SVS */
	{ CC,		REF|SET,	REF },		/* DBVS */
	{ 0,		SET,		0 },		/* SPL */
	{ 0,		SET,		0 },		/* SMI */
	{ CC,		REF|SET,	REF },		/* DBMI */
	{ 0,		SET,		0 },		/* SGE */
	{ CC,		REF|SET,	REF },		/* DBGE */
	{ 0,		SET,		0 },		/* SLT */
	{ CC,		REF|SET,	REF },		/* DBLT */
	{ 0,		SET,		0 },		/* SGT */
	{ CC,		REF|SET,	REF },		/* DBGT */
	{ 0,		SET,		0 },		/* SLE */
	{ CC,		REF|SET,	REF },		/* DBLE */
	{ 0,		REF,		0 },		/* BRA */
	{ SIDE,		REF,		0 },		/* BSR */
	{ 0,		REF,		0 },		/* BHI */
	{ 0,		REF,		0 },		/* BLS */
	{ 0,		REF,		0 },		/* BCC */
	{ 0,		REF,		0 },		/* BCS */
	{ 0,		REF,		0 },		/* BNE */
	{ 0,		REF,		0 },		/* BEQ */
	{ 0,		REF,		0 },		/* BVC */
	{ 0,		REF,		0 },		/* BVS */
	{ 0,		REF,		0 },		/* BPL */
	{ 0,		REF,		0 },		/* BMI */
	{ 0,		REF,		0 },		/* BGE */
	{ 0,		REF,		0 },		/* BLT */
	{ 0,		REF,		0 },		/* BGT */
	{ 0,		REF,		0 },		/* BLE */
	{ CC,		REF,		SET },		/* MOVEQ */
	{ CC,		REF,		REF|SET },	/* DIVU */
	{ CC,		REF,		REF|SET },	/* SBCD */
	{ CC,		REF,		REF|SET },	/* DIVS */
	{ CC,		REF,		REF|SET },	/* SUBX */
	{ CC,		REF,		REF },		/* CMPM */
	{ CC,		REF,		REF|SET },	/* MULU */
	{ CC,		REF,		REF|SET },	/* ABCD */
	{ 0,		REF|SET,	REF|SET },	/* EXG */
	{ CC,		REF,		REF|SET },	/* MULS */
	{ CC,		REF,		REF|SET },	/* ADDX */
	{ CC,		REF,		REF|SET },	/* ASR */
	{ CC,		REF,		REF|SET },	/* LSR */
	{ CC,		REF,		REF|SET },	/* ROXR */
	{ CC,		REF,		REF|SET },	/* ROR */
	{ CC,		REF,		REF|SET },	/* ASL */
	{ CC,		REF,		REF|SET },	/* LSL */
	{ CC,		REF,		REF|SET },	/* ROXL */
	{ CC,		REF,		REF|SET },	/* ROL */
	{ 0,		0,		0 },		/* DC */
};

/*
 * chkset(op) - check to see if operand 'op' sets a register
 *
 * This given operand is set by an instruction. Depending on the
 * addressing mode used, this may set a register. If so, return
 * an appropriate mask. This only happens with register direct
 * addressing.
 */
int
chkset(op)
register struct	opnd	*op;
{
	switch (M(op->amode)) {

	case REG:
		return RM(op->areg);
	case REGI:
		if (op->amode & (INC|DEC))
			return RM(op->areg);
		else
			return 0;

	default:
		return 0;
	}
}

/*
 * chkref(op) - check to see if operand 'op' references a register
 *
 * Checks for register references in source or destination
 * operands, since they can occur in either.
 */
int
chkref(op, is_src)
register struct	opnd	*op;
register bool	is_src;		/* is the operand a source? */
{
	switch (M(op->amode)) {

	case NONE:
	case IMM:
	case ABS:
	case PCD:
		return 0;

	case REG:
		if (is_src)
			return RM(op->areg);
		else
			return 0;

	case REGI:
	case REGID:
		return RM(op->areg);

	case REGIDX:
		return (RM(op->areg) | RM(op->ireg));

	case PCDX:
		return RM(op->ireg);

	default:
		fprintf(stderr, "illegal mode in chkref() %d\n", M(op->amode));
		exit(1);
	}
}

/*
 * chkside(ip, type) - check for side-effects of 'ip'
 *
 * Return a mask of registers set or referenced (depending on 'type')
 * by the given instruction. For example, "pea" sets and references
 * the stack pointer.
 */
int
chkside(ip, type)
INST	*ip;
int	type;
{
	switch (ip->opcode) {
	case PEA:		/* refs/sets the stack pointer */
		return RM(SP);

	case LINK:		/* refs/sets SP */
		return RM(SP);

	case UNLK:
		if (type == SET)
			return RM(SP);
		else
			return 0;

	case RTE:
	case RTS:
	case RTR:
		if (type == SET)
			return RM(SP);
		else
			return RM(SP)|RM(D0);	/* return value's in D0 */

	case JSR:
	case BSR:
		/*
		 * We have to account, here, for what the called
		 * routine might do. Registers D0-3 and A0-3 may
		 * be munged.
		 */
		if (type == SET)
			return	RM(A0)|RM(A1)|RM(A2)|
				RM(D0)|RM(D1)|RM(D2)|RM(SP);
		else
			return	RM(SP);


	case MOVEM:
		/*
		 * We should really check for a register mask spec.
		 * here and parse it. The simple solution is to assume
		 * that all the registers used for register variables
		 * are referenced or modified.
		 */
		return RM(A3)|RM(A4)|RM(A5)|RM(A7)|
		       RM(D3)|RM(D4)|RM(D5)|RM(D6)|RM(D7);

	default:
		fprintf(stderr, "chkside() - unknown opcode\n");
		exit(1);
	}
}

/*
 * reg_set(ip) - return mask of regs set by 'ip'
 */
int
reg_set(ip)
register INST	*ip;
{
	int	mask = 0;	/* build up a register mask */

	if (idata[ip->opcode].op1f & SET)
		mask |= chkset(&ip->src);
	if (idata[ip->opcode].op1f & REF) {
		if ((ip->src.amode & (INC|DEC)) != 0)
			mask |= RM(ip->src.areg);
	}

	if (idata[ip->opcode].op2f & SET)
		mask |= chkset(&ip->dst);
	if (idata[ip->opcode].op2f & REF) {
		if ((ip->dst.amode & (INC|DEC)) != 0)
			mask |= RM(ip->dst.areg);
	}

	if (idata[ip->opcode].iflag & SIDE)
		mask |= chkside(ip, SET);

	return mask;
}

/*
 * reg_ref(ip) - return mask of regs referenced by 'ip'
 */
int
reg_ref(ip)
register INST	*ip;
{
	int	mask = 0;	/* build up a register mask */

	mask |= chkref(&ip->src, idata[ip->opcode].op1f & REF);
	mask |= chkref(&ip->dst, idata[ip->opcode].op2f & REF);
	if (idata[ip->opcode].iflag & SIDE)
		mask |= chkside(ip, REF);

	return mask;
}

/*
 * sets(ip, reg) - is 'reg' set by the instruction 'ip'?
 */
bool
sets(ip, reg)
INST	*ip;
int	reg;
{
	return ((reg_set(ip) & RM(reg)) != 0);
}

/*
 * refs(ip, reg) - is 'reg' referenced by the instruction 'ip'?
 */
bool
refs(ip, reg)
INST	*ip;
int	reg;
{
	return ((reg_ref(ip) & RM(reg)) != 0);
}

/*
 * uses(ip, ref) - is 'reg' used by the instruction 'ip'?
 */
bool
uses(ip, reg)
INST	*ip;
int	reg;
{
	return sets(ip, reg) || refs(ip, reg);
}
