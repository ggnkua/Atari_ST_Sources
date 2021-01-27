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
 * Optimizer integrated in the compiler.
 */

/*
 * Routines dealing with the parsing and output of instructions.
 */

#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>

#include "common/mallocs.h"
#include "param.h"
#include "out.h"
#include "opt.h"
#include "reg.h"
#include "inst.h"

#define error console

long lineno = 0;

global
RMASK loclist;
/*
 * characters that can terminate a register name
 */
static
bool isterm(char c)
{
	return (c eq '\0' or c eq '\r' or c eq '.' or c eq '+' or c eq '-' or c eq '/');
}

static
char * see(char *s, short c)
{
	while (*s)
	{
		if (*s eq c)
		{
			*s = 0;
			return s + 1;
		}
		s++;
	}
	return s;
}

static
ACC isreg(char *s)
{
	char c1 = *s++,
		 c2 = *s++,
		 c3 = c2 - '0';

	if (isterm(*s))
	{
		if (c1 eq '$')
			return DREG + c3;
		if (c1 eq '*')
			if (c2 eq 's')
				return SP;
			elif (c2 eq 'n')
				return FRAMEP;
			else
				return AREG + c3;
#if FLOAT
		if (c1 eq '~')
			return FREG + c3;
#endif
	}
	return -1;
}

/*
 * chkset(op) - check to see if operand 'op' sets a register
 *
 * This given operand is set by an instruction. Depending on the
 * addressing mode used, this may set a register. If so, return
 * an appropriate mask.
 */
static
RMASK chkset(OPND *op)
{
	if (op)
	{
		if (MO(op->am) eq SPPLUS)
			return RM(SP);

		if (    MM(op->am) eq  REG
#if AMFIELDS
			or  op->am.f.inc
			or  op->am.f.dec
#else
		    or (op->am & (INC|DEC)) ne 0
#endif
		   )
			return RM(op->areg);
	}
	return 0;
}

/*
 * chkref(op) - check to see if operand 'op' references a register
 *
 * Checks for register references in source or destination
 * operands, since they can occur in either.
 */
static
RMASK chkref(OPND *op, bool is_src)
{
	if (op eq nil)
		return 0;

	switch (MM(op->am))
	{
	case NONE:
	case IMM:
	case ABS:
	case PCD:
	case RLST:		/* catered for in chkside */
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

	case SPPLUS:
		return RM(SP);

	default:
		error("OE: Illegal mode in chkref() %d\n", MM(op->am));
		return 0;
	}
}

/*
 * chkside(ip, type) - check for side-effects of 'ip'
 *
 * Return a mask of registers set or referenced (depending on 'type')
 * by the given instruction. For example, "pea" sets and references
 * the stack pointer.
 */
static
RMASK chkside(IP ip, IFLAG type)
{
	OPND *arg = ip->arg;

	switch (ip->opcode)
	{
	case PEA:
	case PSH:
#if FLOAT
	case FPSH:
#endif
	case PLL:
	case PLA:
	case SPPLUS:
	case LKX:		/* refs/sets SP */
		return RM(SP);

	case ULX:
		if (type eq SET)
			return RM(SP);
		else
			return 0;

	case RTS:						/* return value in D0 */
		if (type eq SET)
			return RM(SP);
		else
			return RM(SP)|RM(D0);
	case RTA:						/* return value in A0 */
		if (type eq SET)
			return RM(SP);
		else
			return RM(SP)|RM(A0);
	case RTAD:						/* return value in A0 & D0 */
		if (type eq SET)
			return RM(SP)|RM(D0);
		else
			return RM(SP)|RM(A0);
#if FLOAT
	case RTF:						/* return value in F0 */
		if (type eq SET)
			return RM(SP);
		else
			return RM(SP)|RM(F0);
#endif
	case RTV:						/* return void */
			return RM(SP);
	case TRAP:
		if (type eq SET)
			return  RM(D0)|RM(D1)|RM(D2)|RM(A0)|RM(A1)|RM(A2)|RM(SP);
		else
			if (arg->disp eq 2)		/* special case AES/VDI */
				return RM(SP)|RM(D0)|RM(D1);
			else
				return RM(SP);
	case JSR:
	case BSR:
	case INLV:			/* 12'13 HR: v5 Pure C type inline */
		/*
		 * We have to account, here, for what the called
		 * routine might do. Registers D0-2,F0-2 and A0-1 may
		 * be munged.
		 */
		if (type eq SET)
			return WORKX|RM(SP);
		if (   !G.h_cdecl_calling and arg->next and MO(arg->next->am) )
		{
			char *iname(IP ip);
			Cstr s = arg->next->astr;

			if (s)
			{
				while (*s) if (*s ne ':') s++; else break;

				if (*s eq ':')
				{
					s++;

					if (*s eq '#')
					{
						RMASK l = atol(s+1);
						if (l&RM(FRAMEP))
							console("jsr | FRAMEP %ld(%lx)\n", l, l);
						return l|RM(SP);
					}
					else
						return s_to_mask(s)|RM(SP);
				}
			}
			return RM(SP);
		}
		else
			return	RM(SP);
	case JSL:
		return RM(SP);		/* others are determined by analyzing (as for DC) */
	case MMS:
		if (type eq SET)
			return RM(SP);
		else
			if (MO(arg->am) eq IMM)
				return arg->disp|RM(SP);
			elif (MO(arg->am) eq REG)
				return RM(arg->areg)|RM(SP);
			elif (MO(arg->am) eq ABS)
				return loclist;		/* via reg instruction */
			else
				return s_to_mask(arg->astr)|RM(SP);
	case MMX:
		if (type eq SET)
			if (MO(arg->am) eq IMM)
				return arg->disp|RM(SP);
			elif (MO(arg->am) eq REG)
				return RM(arg->areg)|RM(SP);
			elif (MO(arg->am) eq ABS)
				return loclist;		/* via reg instruction */
			else
				return s_to_mask(arg->astr)|RM(SP);
		else
			return RM(SP);
#if OPTBUG
	case LIV:
		if (type eq REF)
			return s_to_mask(arg->astr);
#endif
	}
	return 0;
}

/*
 * reg_set(ip) - return mask of regs set by 'ip'
 */
global
RMASK reg_set(IP ip)
{
	OPND *arg = ip->arg;

	IDATA *id = &idata[ip->opcode];
	RMASK mask = 0;	/* build up a register mask */

	if (id->regf & SET)
		mask |= RM(ip->reg);

	if (arg)
	{
		OPND *dst = arg->next;

		if (id->argf & SET)
			mask |= chkset(arg);
		if (id->argf & REF)
#if AMFIELDS
			if (arg->am.f.inc or arg->am.f.dec)
#else
			if (arg->am & (INC|DEC))
#endif
				mask |= RM(arg->areg);

		if (dst)
		{
			if (id->dstf & SET)
				mask |= chkset(dst);
			if (id->dstf & REF)
#if AMFIELDS
				if (dst->am.f.inc or dst->am.f.dec)
#else
				if (dst->am & (INC|DEC))
#endif
					mask |= RM(dst->areg);
		}
	}

	if (id->iflag & SIDE)
		mask |= chkside(ip, SET);

	return mask;
}
/*
 * reg_ref(ip) - return mask of regs referenced by 'ip'
 */
global
RMASK reg_ref(IP ip)
{
	IDATA *id = &idata[ip->opcode];
	RMASK mask = 0;	/* build up a register mask */

	if (id->regf & REF)
		mask |= RM(ip->reg);

	if (ip->arg)
	{
		mask |= chkref(ip->arg,       (id->argf & REF) ne 0);
		mask |= chkref(ip->arg->next, (id->dstf & REF) ne 0);
	}

	if (id->iflag & SIDE)
		mask |= chkside(ip, REF);

	return mask;
}

global
bool double_ref(IP ip)			/* 04'09 */
{
	if (ip->arg)
		if (ip->arg->next)
		{
			RMASK maska, maskd, masks;
			IDATA *id = &idata[ip->opcode];
			maska = chkref(ip->arg,       (id->argf & REF) ne 0);
			maskd = chkref(ip->arg->next, (id->dstf & REF) ne 0);
			if (maska eq maskd) return true;
			if (id->iflag & SIDE)
			{
				masks = chkside(ip, REF);
				if (maska eq masks or maskd eq masks) return true;
			}
		}

	return false;
}

/*
 * getreg/getop(op, s) - parse string 's' into the operand structure 'op'
 *
 * Hack alert!! The following code parses the operands only to the
 * extent needed by the optimizer. We're primarily interested in
 * details about addressing modes used, not in any expressions that
 * might be present. This code is highly tuned to the output of the
 * compiler.
 */
static
void getreg(IP ip, char *s)		/* reduced 1st op */
{
	ACC  reg;

	if ((reg = isreg(s)) >= 0)
		ip->reg = reg;
}

short area_number(char *);


static
void see_name(OPND *op, char *s)
{
	if (*s eq '<')
	{
		s++;
		op->aname = true;

		op->ireg = atoi(s);
		s = see(s, '/');
		op->areg = atoi(s);
		s = see(s, '.');
		op->namedisp = atol(s);
		s = see(s, '>');
		s = see(s, '[');
		op->astr = s;
		s = see(s, ']');
	othw
		op->astr = s;
		if (*s eq '-') s++;		/* 04'17 HR v5.6 '-', NB: '+' is not generated */
		while (is_alnum(*s)) s++;
	}

	if (*s eq '+')
	{
		*s++ = 0;
		op->disp = atol(s);		/* extra displacement with name */
	}
	elif (*s eq '-')			/* PSHL 04'17 HR v5.6 */
	{
		*s++ = 0;
		op->disp = -atol(s);	/* extra displacement with name */
	}
}

global
long atols(char **get)		/* returns next position */
{
	long n; short t;
	char *s = *get;

	n=0;
	t=0;

	if ( *s=='-')
	{
		s++;
		t=1;
	}

	while (*s>='0' && *s<='9')
	{
		n=10*n+*s++-'0';
	}

	*get = s;
	if (t) return -n;
	else   return  n;
}

static
unsigned long xtol(char *s)
{
	long n = 0;
	short c;

	while ( (c = *s++) ne 0)
	{
		if   (c >= '0' and c <= '9')
			n = 16*n + (c - '0');
		elif (c >= 'A' and c <= 'F')
			n = 16*n + (c - 'A' + 10);
		elif (c >= 'a' and c <= 'f')
			n = 16*n + (c - 'a' + 10);
		else
			break;
	}

	return n;
}

/*
 * placement of arg and dst is flexible
 * if opnd != nil, operand memory already exists (eg in inode)
 * else it is allocated here
 */
static
OPND * getop(char *s, OPND *opnd)
{
	OPND operand, *op;
	ACC  reg;

	op = opnd ? opnd : &operand;

	if (*s eq '\0' or *s eq '\r')
		return nil;

	pzero(op);

	if (*s eq '(')			/* 68020 bit fields */
	{
		s++;
		op->fldo = atoi(s);
		s = see(s, ':');
		op->fldw = atoi(s);
		s = see(s, ')');
	}

	if (*s eq '#')
	{				/* immediate data */
		MO(op->am) = IMM;
		s += 1;
		if (*s eq '$')
			s += 1, op->disp = xtol(s);
		elif (isdigit(*s) or *s eq '-') /* NB: '+' is not generated */
			op->disp = atol(s);
		else
		{
#if AMFIELDS
			op->am.f.symb = 1;
#else
			op->am |= SYMB;
#endif
			see_name(op, s);
		}
	}
	elif ((reg = isreg(s)) >= 0)
	{
		op->areg = reg;
		if   (s[2] eq '-')
			if (isreg(s+3) < 0)
			{
				MO(op->am) = REGI;
#if AMFIELDS
				op->am.f.dec = 1;
#else
				op->am |= DEC;
#endif
				s += 3;
			othw
				MO(op->am) = RLST;
				op->astr = s;
			}
		elif (s[2] eq '+')
		{
			MO(op->am) = REGI;
#if AMFIELDS
			op->am.f.inc = 1;
#else
			op->am |= INC;
#endif
			s += 3;
		}
		elif (s[2] eq '.')
		{
			s += 3;
			if (isdigit(*s) or *s eq '-')
				MO(op->am) = REGID,
				op->disp = atols(&s);
			else
				MO(op->am) = REGI;
			op->astr = nil;
			if (*s eq '/')	/* target register type */
			{
				s++;
				if (reg eq FRAMEP)
				{
					if   (*s eq '$') s++, op->type = DRG;
					elif (*s eq '~') s++, op->type = FRG;
					elif (*s eq '*') s++, op->type = PTR;
					if (*s eq 'v')
					{
						s++;
						op->vreg.r = atols(&s);
						if (*s eq 'l')
						{
							s++;
							op->vreg.l = atols(&s);
						}
						if (*s eq 's')
						{
							s++;
							op->vreg.s = atols(&s);
						}
					}
				}
			}
		}
		elif (s[2] eq '/')
			MO(op->am) = RLST,
			op->astr = s;
		else
			MO(op->am) = REG; 		/* reg. direct */
	}
	elif (s[0] eq 'p' and s[1] eq 'c' and !is_alpha(s[2]))
	{
		s += 3;
		op->disp = atol(s);
		MO(op->am) = PCD;
	othw
		MO(op->am) = ABS;
		see_name(op, s);
	}


	if (MO(op->am) ne NONE)
	{
		if (opnd eq nil)
		{
			OPND *new = CC_qalloc(&opndmem, sizeof(*new), CC_ranout, AH_CC_INST_OP);
			if (new)
				*new = operand;
			return new;
		}
		return op;
	}

	return nil;
}

global
void uprefs(IP ip)
{
	ip->rref = reg_ref(ip);
	ip->rset = reg_set(ip);
}

global
ASMOP get_opcode(char *s)
{
	char opc[32], *op = opc;
	if (s and *s ne ' ')
	{
		if (*s eq '.')
			s++;
		while (*s)
			if (*s eq '.')
				break;
			else
				*op++ = *s++;

		*op = 0;
		return find_op(opc);
	}
	return INVOP;
}

static
void mvreg(IP ip)
{
	OPND *op = ip->arg;
	op->vreg.l = op->disp;
	op->vreg.s = op->next->disp;
}
/*
 * addinst - add an instruction to block 'bp'
 */
global
IP addinst(BP bp, char *op, char *reg, char *args, char *dest)
{
	IP ni = nil;
	char *s;

	if (op eq nil)
		return nil;
	if (*op eq '\0' or *op eq '\r')	/* no instruction there */
		return nil;

	if (*op eq '.')
		op++;

	ni = allocIn();

	ni->opcode = INVOP;
	ni->reg = -1;

	s = op;
	while (*s)
	{
		if (*s eq ' ')
		{
			ni->sz = -1;
			*s = 0;
			break;
		}
		else
		if (*s eq '.')
		{
			/* length specifier */
			char c = *++s;
			if   (c eq 'b')
				  c = DOT_B;
			elif (c eq 'w')
				  c = DOT_W;
			elif (c eq 'l')
				  c = DOT_L;
			elif (c eq 's')
				  c = DOT_S,
				  ni->iflg.f.flt = 1;
			elif (c eq 'x')
				  c = DOT_X;
			elif (c eq 'd')
			      c = DOT_D;
#if LL
			elif (c eq 'e')
				  c = DOT_LL;
#endif
			else
				  error("OE: Bad size spec '%c'\n", c),
				  c = DOT_W;
			ni->sz = c;
		}
		s++;
	}

	ni->opcode = get_opcode(op);
	if (ni->sz eq -1)
		ni->sz = idata[ni->opcode].defsz;	/* currently 0 or DOT_W */
	getreg(ni, reg);
	ni->arg = getop(args, nil);
	if (ni->arg)
		ni->arg->next = getop(dest, nil);

#if DBGA2
	if (ni->opcode eq TRAP)
		bp->bflg.has_trap = 1;
#endif

#if OPTBUG
	if (ni->opcode eq SLINE)
		lineno  = ni->arg->disp;/* original source line number */
		ni->snr = lineno;
#endif

	if (ni->opcode eq INVOP)
	{

#if OPTBUG
		error("OE %ld: Unknown opcode '%s' %s %s,%s\n", ni->snr, op, reg, args, dest);
#else
		error("OE: Unknown opcode '%s' %s %s,%s\n", op, reg, args, dest);
#endif

		ni->opcode = 0;
		return nil;
	}

	if (bp eq nil)		/* if not in text areas */
		return ni;

	switch(ni->opcode)
	{
		case VARD:
			addvar(ni, DRG);
			freeIn(ni);
			return nil;
		case VARA:
			addvar(ni, PTR);
			freeIn(ni);
			return nil;
#if FLOAT
		case VARF:
			addvar(ni, FRG);
			freeIn(ni);
			return nil;
#endif
		case RGL:
			loclist = get_locs(ni);
			regi = ni;		/* save for puttimg in front */
			return ni;
		case LOC:
			loci = ni;		/* save for puttimg in front->next */
			return ni;
#if OPTBUG
		case SLINE:
#endif
		case END:
		case BEGIN:
		case RGD:
		case RGA:
		case VARX:
#if FLOAT
		case RGF:
#endif
			freeIn(ni);
			return nil;
	}

	uprefs(ni);		/* register usage */

	/*
	 * Link into the block appropriately
	 */
	if (bp->first eq nil)
	{
		bp->first = bp->last = ni;
	othw
		bp->last->next = ni;
		ni->prior = bp->last;

		bp->last = ni;
	}

	return ni;
}

/*
 * delinst(bp, ip) - delete instruction 'ip' in block 'bp'
 */

global
IP
delinst(BP bp, IP ip)
{
	IP pi, ni;	/* previous and next instructions */

	pi = ip->prior;
	ni = ip->next;

#if OPTBUG
	if (ip->bugstr)
		if   (ni)
			add_debug(ni, ip->bugstr);
		elif (pi)
			add_debug(pi, ip->bugstr);
#endif

	if (pi ne nil)
		pi->next = ni;
	else
		bp->first = ni;

	if (ni ne nil)
		ni->prior = pi;
	else
		bp->last = pi;

	/*
	 * Free space used by the instruction.
	 */
#if OPTBUG
	if (ip->bugstr) CC_xfree(ip->bugstr);
#endif

	freeIunit(ip);

	s_idel++;
	return ni;
}

global
IP instafter(BP bp, IP ip, bool with_arg)		/* ip exists */
{
	IP np = allocIn();
	IP ni;	/* previous and next instructions */

	ni = ip->next;

	np->prior = ip;				/* insert after */
	np->next = ni;

	if (!ni)					/* after last */
		bp->last = np;
	else
		ni->prior = np;

	ip->next = np;

	if (with_arg)
	{
		np->arg = CC_qalloc(&opndmem, sizeof(OPND), CC_ranout, AH_CC_INST_OP);
		if (np->arg)
			pzero(np->arg);
	}

	s_idel--;
	return np;
}

global
IP instbefore(BP bp, IP ip, bool with_arg)		/* ip exists */
{
	IP np = allocIn();
	IP ni;	/* previous and next instructions */

	ni = ip->prior;

	np->next = ip;				/* insert before */
	np->prior = ni;

	if (!ni)					/* before first */
		bp->first = np;
	else
		ni->next = np;

	ip->prior = np;

	if (with_arg)
	{
		np->arg = CC_qalloc(&opndmem, sizeof(OPND), CC_ranout, AH_CC_INST_OP);
		if (np->arg)
			pzero(np->arg);
	}

	s_idel--;
	return np;
}

global
bool regeq(OPND *op, ACC reg)
{
	if (op eq nil)
		return false;
	return MO(op->am) eq REG and op->areg eq reg;
}

/*
 * determine, based on the amode field, whether
 * the 'astr' field of the structure is active.
 */

static
bool is_astr(const OPND *op)
{
	return    MO(op->am) eq ABS
	       or MO(op->am) eq RLST
#if AMFIELDS
	       or (    op->am.f.m eq IMM
	           and op->am.f.symb ne 0
	          )
#else
	       or op->am eq (IMM|SYMB)
#endif
	;
}


/*
 * opeq(op1, op2) - test equality of two instruction operands
 */
#if AMFIELDS
bool opeq(const OPND *op1, const OPND *op2, bool dec)
{
	OPMODE am1, am2;


	if (op1 eq nil or op2 eq nil)
		return false;

	am1 = op1->am;
	am2 = op2->am;

	if (!dec)		/* dec not condidered */
		am1.f.dec = 0, am2.f.dec = 0;

	if (   am1.i      ne am2.i
		or op1->areg  ne op2->areg
		or op1->ireg  ne op2->ireg )
		return false;

	/*
	 * Depending on the addressing mode, we either need to
	 * compare the "astr" strings, or the displacements.
	 * Because of lea for standard areas we need compare both astr & disp
	 */

	if ( is_astr(op1) ne is_astr(op2))
		return false;

	if ((op1->astr eq nil) ne (op2->astr eq nil))
		return false;

	if (op1->astr)
		if (SCMP(304, op1->astr, op2->astr) ne 0)
			return false;

	return op1->disp eq op2->disp;
}
#else
global
bool opeq(const OPND *op1, const OPND *op2, bool dec)
{

	short am1, am2;

	am1 = op1->am;
	am2 = op2->am;

	if (op1 eq nil or op2 eq nil)
		return false;

	if (!dec)
		am1&=~DEC, am2&=~DEC;

	if (   am1        ne am2
		or op1->areg  ne op2->areg
		or op1->ireg  ne op2->ireg )
		return false;

	/*
	 * Depending on the addressing mode, we either need to
	 * compare the "astr" strings, or the displacements.
	 * Because of lea for standard areas we need compare both astr & disp
	 */
	if ( is_astr(op1) ne is_astr(op2))
		return false;

	if ((op1->astr eq nil) ne (op2->astr eq nil))
		return false;

	if (op1->astr)
		if (SCMP(305, op1->astr, op2->astr) ne 0)
			return false;

	return op1->disp eq op2->disp;
}
#endif