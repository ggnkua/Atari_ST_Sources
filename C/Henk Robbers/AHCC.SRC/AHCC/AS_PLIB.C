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
 * assembler: parse routines for as_parse
 *
 */

#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include "common/mallocs.h"
#include "param.h"
#include "pre.h"
#include "decl.h"
#include "d2.h"
#include "expr.h"
#include "e2.h"
#include "inst.h"
#include "body.h"
#include "opt.h"
#include "out.h"
#include "reg.h"
#include "po.h"
#include "as.h"
#include "as_plib.h"

#define debug_a G.yflags['a'-'a']
#define debugA G.xflags['a'-'a']

short alert_text (char *t, ... );

global
char *ordinal[] =
{
	"size ",
	"first ",
	"second ",
	"third ",
	"fourth ",
	"fifth ",
	"sixth ",
	"seventh ",
	"eighth ",
	"",				/* unspecified */
	0
};

global
short opnd_err(short n, short which, Cstr msg)
{
	if (n < 0 or n > 9)
		n = 9;			/* we really need enumerating array initializations */
	error("[%d]invalid %soperand: %s", which, ordinal[n], msg);

	return 1;
}

static
char * modes[] =
{
	"all",
	"control alterable",
	"control addressable",
	"memory alterable",
	"memory addressable",
	"data alterable",
	"data addressable",
	"alterable",
	"control"
};

global
void ea_error(short n, short type)
{
	error("only '%s' modes allowed for %s operand", modes[type&0xff], ordinal[n]);
}

static
AREA_INFO zero_info ={0,0,0};

global
void asm_offs(NP np, TP tp)
{
	if (np->sc eq K_AUTO)
	{
		np->token = tp->token  = ICON;
		np->val.i = tp->offset;
		tp->type  = basic_type(T_LONG, 0);
		np->area_info = zero_info;
	}
	elif (np->area_info.class eq OFFS_class)
	{
		np->token = tp->token  = ICON;
		np->val.i = tp->offset = np->area_info.disp;
		tp->type  = basic_type(T_LONG, 0);
		np->area_info = zero_info;
	}
}

global
OPND *new_arg(void)
{
	OPND *new = CC_qalloc(&opndmem, sizeof(*new), CC_ranout, AH_CC_INST_OP);
	if (new)
		pzero(new);
	return new;
}

/*
AM_.....   = allowed addressing modes
		     x: one octal digit for a register number

AM_CTRL		control					        2x       5x 6x 70 71 72 73
AM_C_ALT	control alterable		        2x       5x 6x 70 71
AM_C_ADD	control addressable		        2x       5x 6x 70 71 72 73 74
AM_M_ALT	memory alterable		        2x 3x 4x 5x 6x 70 71
AM_D_ALT	data alterable			0x      2x 3x 4x 5x 6x 70 71
AM_D_ADD	data addressable		0x      2x 3x 4x 5x 6x 70 71 72 73 74
AM_M_ADD	memory addresing		        2x 3x 4x 5x 6x 70 71 72 73 74
AM_ALTER	all alterable			0x 1xWL 2x 3x 4x 5x 6x 70 71
AM_ALL		all						0x 1xWL 2x 3x 4x 5x 6x 70 71 72 73 74
*/

/*
bool is_indirect(OPMODE m)
{
	return MO(m) >= REGI and MO(m) <= DECREG;
}
*/
global
bool check_ea(OPND *a, short am)		/* am one of AM_..... */
{
	short reg, mo;

	reg = a->areg,

#if AMFIELDS
	mo = a->am.f.m;

	if (am & AM_DN)
		if (mo eq REG and ISD(reg))
			return true;

	if (am & AM_INC)
		if (mo eq REGI and a->am.f.inc)
			return true;
	if (am & AM_DEC)
		if (mo eq REGI and a->am.f.dec)
			return true;
#else
	mo = a->am;

	if (am & AM_DN)
		if (mo eq REG and ISD(reg))
			return true;

	if (am & AM_INC)
		if (mo eq (REGI|INC))
			return true;
	if (am & AM_DEC)
		if (mo eq (REGI|DEC))
			return true;

	mo = MM(mo);
#endif

	am &= 0xff;

	switch (am)
	{
		case AM_CTRL:
			return    check_ea(a, AM_C_ADD)
			       and mo ne IMM;
		case AM_C_ALT:
			return (    check_ea(a, AM_ALTER)
			        and check_ea(a, AM_C_ADD) );
		case AM_C_ADD:
			if (mo eq REG)
				return false;
#if AMFIELDS
			if (mo eq REGI and (a->am.f.inc or a->am.f.dec))
#else
			if (mo eq REGI and (a->am & (INC|DEC)) ne 0    )
#endif
				return false;
			return true;
		case AM_M_ALT:
			return (   check_ea(a, AM_C_ALT)
#if AMFIELDS
			        or (mo eq REGI and (a->am.f.inc or a->am.f.dec) ) );
#else
			        or (mo eq REGI and (a->am & (INC|DEC)) ne 0     ) );
#endif
		case AM_M_ADD:
			return mo ne REG;
		case AM_D_ALT:
			return (   check_ea(a, AM_M_ALT)
			        or (mo eq REG and ISD(reg)) );
		case AM_D_ADD:
			if (mo eq REG and ISA(reg))
				return false;
			return true;
		case AM_ALTER:
			if (mo eq IMM or mo eq PCD or mo eq PCDX or mo eq PCDXX)
				return false;
			return true;
	}

	return true;
}

global
bool check_imm(long l, short sz, short n)
{
	long check = l;

	switch(sz)
	{
		case DOT_B:
			check &= 0xffffff00;
			if (check ne 0 and check ne 0xffffff00)
				return opnd_err(n, 2, "out of range"), false;
		break;
		case DOT_W:
			check &= 0xffff0000;
			if (check ne 0 and check ne 0xffff0000)
				return opnd_err(n, 3, "out of range"), false;
		break;
	}

	return true;
}

global
void chk_glob(OPND *a, void * e1)
{
	TP np = e1;
	TP rv = tlook(symtab[hash(np->name)],np);

	if (rv)
		if (rv->sc eq K_GLOBAL)
			a->gl = true;
}

static
bool asm_select(OPND *a, NP e1, OPMODE am)
{
	if (e1->token eq ASM_SELECT)		/* strunion @ member */
	{
		if (e1->left->sc eq K_TYPE)		/* declarer @ member (offsetof) */
		{
			a->am = am;
			a->disp  = e1->val.i;
		othw							/* variable @ member */
			a->astr  = e1->left->name;
			a->tlab  = e1->left->lbl;
			a->areg  = e1->area_info.id;
			a->disp  = e1->val.i;
			a->am = am;
#if AMFIELDS
			a->am.f.symb = 1;
#else
			a->am |= SYMB;
#endif
		}

		return true;
	}

	return false;
}

static
void name_size(OPND *a, NP np)
{
#if AMFIELDS
	a->am.f.absl = np->eflgs.f.asm_l;
	a->am.f.absw = np->eflgs.f.asm_w;
#else
	if (np->eflgs.f.asm_l)
		a->am |= ABSL; 		/* 5'15 v5.2 */
	else
	if (np->eflgs.f.asm_w)
		a->am |= ABSW;
#endif
}

static
short name_xpr(OPND *a, NP e1, short am)  /* id, n or id+n */
{
	OPMODE mam;

	am |= MO(a->am) & AMFLGS;		/* keep flags */

	MO(mam) = am;

	if (asm_select(a, e1, mam))
		return 0;

	if (    e1->token eq PLUS
	    and e1->left ->token eq ID
	    and e1->right->token eq ICON
	   )
	{
		a->astr = e1->left->name;
		a->tlab = e1->left->lbl;
		a->areg = e1->left->area_info.id;
		MO(a->am) = am;
#if AMFIELDS
		a->am.f.symb = 1;
#else
		a->am |= SYMB;
#endif
		chk_glob(a, e1->left);
		a->disp = e1->right->val.i;
		name_size(a, e1->left);
	}
	elif (    e1->token eq MINUS
	      and e1->left ->token eq ID
	      and e1->right->token eq ID
	     )
	{
/*		message(0, 0, "ID-ID");
*/		return 7;
	}
	elif (e1->token eq ID)
	{
		a->astr = e1->name;
		a->tlab = e1->lbl;
		a->areg = e1->area_info.id;
		MO(a->am) = am;
#if AMFIELDS
		a->am.f.symb = 1;
#else
		a->am |= SYMB;
#endif
		chk_glob(a, e1);
		name_size(a, e1);
	}
	elif (e1->token eq ICON)
	{
		a->disp = e1->val.i;
		a->am = mam;
		name_size(a, e1);
	}
	else
		return 7;

	return 0;
}

static
char not_id[] = "not id, n or id+n";

global
bool immediate(OPND *a, bool cons, short n)
{
	NP e1; short err = 0;

	if (cur->token eq PREP)
		fadvnode();
	e1 = asm_expr();

	if (e1)
	{
		short err = name_xpr(a, e1, IMM);
		if (err)
			opnd_err(n, 4, not_id);
		if (    cons
		    and !m_no_absw(a->am, IMM)
		   )
			err = opnd_err(n, 5, "needs constant immediate");

		freenode(e1);
	}
	else
		err = opnd_err(n, 6, "missing");

	return err eq 0;
}

global
short p_dreg(NP np)
{
	short tok = np->token;
	if is_asreg(np)
		if (tok >= K_D0 and tok <= K_D7)
			return D0 + (tok - K_D0);
	return -1;
}

global
short p_areg(NP np)
{
	short tok = np->token;
	if is_asreg(np)
		if (tok >= K_A0 and tok <= K_A7)
			return A0 + (tok - K_A0);
	return -1;
}


#if FLOAT
global
short p_freg(NP np)
{
	short tok = np->token;
	if (np->cat1 & S_KW)
		if (tok >= K_F0 and tok <= K_F7)
			return F0 + (tok - K_F0);
	return -1;
}
#endif


global
short p_adreg(NP np)
{
	short reg = p_areg(np);
	if (reg >= 0) return reg;
	reg = p_dreg(np);
	if (reg >= 0) return reg;
	return -1;
}

global
short p_allreg(NP np)
{
	short reg = p_areg(np);
	if (reg >= 0) return reg;
	reg = p_dreg(np);
	if (reg >= 0) return reg;
#if FLOAT
	reg = p_freg(np);
	if (reg >= 0) return reg;
#endif
	return -1;
}

global
bool p_isareg(void * vp)
{
	XP np = vp;
	if is_asreg(np)
		if (np->token <= K_A7)
			return true;
	return false;
}

global
bool p_isdreg(void * vp)		/* includes fp regs */
{
	XP np = vp;
	if is_asreg(np)
		if (np->token >= K_D0)
			return true;
	return false;
}

#if FLOAT
global
bool p_isfreg(void * vp)
{
	XP np = vp;
	if (np->cat1 & S_KW)
		if (np->token >= K_F0 and np->token <= K_F7)
			return true;
	return false;
}
#endif

static
short base_reg(OPND *a, NP np)
{
	OPMODE m;

	if (np->token eq K_PC)
		MO(m) = PCD;
	else
	{
		if (p_isareg(np))
		{
			a->areg = p_areg(np);
			MO(m) = a->disp eq 0 ? REGI : REGID;
		}
		elif (p_isdreg(np))
		{
			if ((G.CPU & _H) eq 0)
				return 12;
			a->areg = -1;
			a->ireg = p_dreg(np);
			MO(m) = REGIDXX;
		}
		else
			return 13;
	}

#if AMFIELDS
	a->am.f.m = m.f.m;
#else
	a->am |= m;
#endif
	return 0;
}

static
void mem_ind(OPND *a, NP np, NP *bd, NP *An, NP *Xn)
{
	if is_asreg(np)
	{
		*An = np;			/* ([reg]...) */
		if (p_isdreg(np))
#if AMFIELDS
			a->am.f.dec = 1;
#else
			a->am |= PREI;
#endif
	othw
		if (np->token eq COMMA)		/* ([x,y...]...) */
		{
			if (np->left->token eq COMMA)		/* ([bd,An,Xn]...) */
			{
				*bd = np->left->left;
				*An = np->left->right;
				*Xn = np->right;
#if AMFIELDS
				a->am.f.dec = 1;
#else
				a->am |= PREI;
#endif
			}
			elif is_asreg(np->left)
			{
				*An = np->left;		/* ([An,Xn]...) */
				*Xn = np->right;
#if AMFIELDS
				a->am.f.dec = 1;
#else
				a->am |= PREI;
#endif
			othw
				*bd = np->left;		/* ([bd,An]...) */
				*An = np->right;
				if (p_isdreg(np->right))
				{
#if AMFIELDS
					a->am.f.dec = 1;
#else
					a->am |= PREI;
#endif
				}
			}
		}
		else
			*bd = np;				/* ([bd]...) */
	}
}

static
NP opt_scale(OPND *a, NP xp, short n)
{
	if (xp->tt eq E_BINARY and xp->token eq ASMSCALE)
	{
		short scale = xp->right->val.i;
		if ((G.CPU & (_H|_CF)) eq 0 and scale > 1)		/* if scale > 1, cpu id must be high or Coldfire */
			opnd_err(n, 7, "scale factor not allowed");
		else
		{
			xp = xp->left;
			if (scale ne 1 and scale ne 2 and scale ne 4 and scale ne 8)
				opnd_err(n, 8, "scale factor must be 2, 4, or 8");
			else
				a->scale = scale eq 2 ? 1 : scale eq 4 ? 2 : 3;
		}
	}

	return xp;
}

static
short make_opnd(short n, OPND *a, NP bd, NP An, NP Xn, short m1, short m2)
{
	short err = 0;
	short mode = m2;

	if (bd)
	{
		err = name_xpr(a, bd, m2);
		if (err)
			opnd_err(n, 9, not_id);
#if AMFIELDS
		a->am.f.bdisp = 1;
#else
		a->am |= BDISP;
#endif
	}

	if (An)
	{
		if (An->token eq K_PC)
			mode = m1;
		elif (p_isareg(An))
			a->areg = p_areg(An);
		else
		{
			if (Xn)
				err = opnd_err(n, 10, "too many registers"); 			/* syntax error */
			Xn = An;
			An = nil;
		}
	}

	if (Xn)
	{
		Xn = opt_scale(a, Xn, n);

		if (p_isareg(Xn) or p_isdreg(Xn))
		{
			a->ireg = p_adreg(Xn);
			if (Xn->eflgs.f.asm_l)			/* 04'09 use ASM_W|ASM_L */
#if AMFIELDS
				a->am.f.xl = 1;
#else
				a->am |= XLONG;
#endif
			elif (   !(Xn->eflgs.f.asm_l or Xn->eflgs.f.asm_w)
			      and G.aw_Xnl
			     )
			{
#if AMFIELDS
				a->am.f.xl = 1;
#else
				a->am |= XLONG;
#endif
#if COLDFIRE
				if (G.Coldfire)
					warn("Xn defaults to .l for Coldfire");
#endif
			}
		}
		else
			err = opnd_err(n, 11, "invalid index register");
	}

#if AMFIELDS
	a->am.f.m = mode;
#else
	a->am &= AMFLGS;			/* keep flags */
	a->am |= mode;
#endif
	return err;
}

/* the number of good asm extended operand expression trees is finite
   and actually not extremely large.

   Some trees might just have the same effect

   bd = base displacement
   An = base register
   Xn = index register
   od = outer displacement

   Note that there is a difference between An and Xn such that
   An can only be a address reg and Xn can also be a data reg

   Xn and od also involve a choice between post & pre memory indexing

([bd,An,Xn],od)		/* 1111 */
([bd,An],Xn,od)

([bd,An,Xn])		/* 1110 */
([bd,An],Xn)

([bd,An],od)		/* 1101 */

([bd,An])			/* 1100 */

([bd,Xn],od)		/* 1011 */
([bd],Xn,od)

([bd,Xn],od)		/* 1010 */
([bd],Xn,od)

([bd],od)			/* 1001 */

([bd])				/* 1000 */

([An,Xn],od)		/* 0111 */
([An],Xn,od)

([An,Xn])			/* 0110 */
([An],Xn)

([An],od)			/* 0101 */

([An])				/* 0100 */

([Xn],od)			/* 0011 */

([Xn])				/* 0010 */
(Xn)

(od)				/* 0001 */

()					/* 0000 */

(bd,An,Xn)			/*  111 */
(bd,An)				/*  110 */
(bd,Xn)				/*  101 */
(bd)				/*  100 */
(An,Xn)				/*  011 */
(An)				/*  010 */
(Xn)				/*  001 */

()					/*  000 */

The other (normal) addressing modes are quite uncomplicated
*/

char *cpu_n_avail = "addressing mode not available on current cpu type";

static
bool can_REGINDISP(NP lp, NP rp)
{
	if (lp->token eq ICON and D16OK(lp->val.i))
		return true;
	return false;
}

static
bool can_REGIDX(NP lp, NP rp)
{
	if (lp->token eq ICON and D8OK(lp->val.i))
		return true;
	return false;
}

static
bool operr1018(short n, short *err)
{
	if ((G.CPU & _H) eq 0) { *err = opnd_err(n, 12, cpu_n_avail); return true; }
	return false;
}

static
bool yields_ID(NP np)
{
	TP tp;
	if (np->tt eq E_UNARY)
		np = np->left;

	if (np->token eq ID)
	{
		tp = np->type;
		if (tp)
			if (tp->token eq T_PROC)
				return true;
	}

	return false;
}

static NP to_name(NP np)
{
	NP e1 = np;
	if (np->tt eq E_UNARY)
	{
		e1 = np->left;
		np->left = nil;
		e1->sc = 0;
		freeunit(np);
	}

	return e1;
}

static short ea_to_a(OPND *a, NP e1, short type, short n)
{
	short reg, err = 0;
	NP lp, rp,
	   bd = nil,
	   An = nil,
	   Xn = nil,
	   oud = nil;

	if (e1)
	{
		OPMODE mam;

		switch (e1->tt)
		{
			case E_LEAF:
				if (e1->token eq INSTR)		/* 05'11 HR: '*' operand */
				{
					MO(a->am) = INSTD;
					a->disp = e1->val.i;
				othw					/* simple: register or name or number */
					reg = p_allreg(e1);

					if (reg >= 0)
					{
						MO(a->am) = REG;
						a->areg  = reg;
					}
					else
						err = name_xpr(a, e1, ABS);
				}

			break;
			case E_UNARY:
				if (yields_ID(e1))
				{
					/* reduces e1 to name only */
					e1 = to_name(e1);
					return ea_to_a(a, e1, type, n);
				}

				MO(mam) = ABS;
				if (!asm_select(a, e1, mam))
				{
					lp = e1->left, rp = e1->right;
					if (e1->token eq REGINDIM)		/* memory indirect ([...]) */
					{
						if ((G.CPU & _H) eq 0) { err = opnd_err(n, 13, cpu_n_avail); break; }
						a->areg = -1, a->ireg = -1;
#if AMFIELDS
						a->am.f.mind = 1;
#else
						a->am |= MIND;
#endif
						mem_ind(a, lp, &bd, &An, &Xn);		/* dispatch [] elements */
						err = make_opnd(n, a, bd, An, Xn, PCDXX, REGIDXX);
					}
					elif (lp->tt eq E_LEAF)			/* simple indirection */
					{
						if (e1->token eq REGINDIRECT)		/* ...REGIND... always have valid reg */
						{
							if (lp->token eq K_PC)
								MO(a->am) = PCD;
							elif (p_isareg(lp))
							{
								MO(a->am) = REGI;
								a->areg = p_areg(lp);
							othw
								if ((G.CPU & _H) eq 0) { err = opnd_err(n, 14, cpu_n_avail); break; }

								MO(a->am) = REGIDXX;
								a->areg = -1;
								a->ireg = p_adreg(lp);
							}
						}
						elif (e1->token eq REGINDPLUS)
						{
							MO(a->am) = REGI;
#if AMFIELDS
							a->am.f.inc = 1;
#else
							a->am |= INC;
#endif
							a->areg = p_adreg(lp);
						}
						elif (e1->token eq MINUSREGIND)
						{
							MO(a->am) = REGI;
#if AMFIELDS
							a->am.f.dec = 1;
#else
							a->am |= DEC;
#endif
							a->areg = p_adreg(lp);
						}
					}
				}
			break;
			case E_BINARY:					/* simple asm expression: number, name or name+number */
				err = name_xpr(a, e1, ABS);
				if (err)
					opnd_err(n, 15, not_id);
			break;
			case E_SPEC:					/* complex: extended addressing modes */
				lp = e1->left, rp = e1->right;
				if (e1->token eq REGINDISP)
				{
					err = name_xpr(a, lp, 0);
					if (err) { opnd_err(n, 16, not_id); break; }

					if (rp->tt eq E_LEAF)			/* base register only */
					{
						if (!check_imm(lp->val.i, DOT_W, n))
							err = 3;
						if (err eq 0)
						{
							err = base_reg(a, rp);
							if (err) { opnd_err(n, 17, "invalid base register"); break; }
						}
					}
					elif (rp->token eq COMMA)		/* both base & index register */
					{
						if (!check_imm(lp->val.i, DOT_B, n))
							err = 3;
						if (err eq 0)
						{
							An = rp->left;
							Xn = rp->right;
							err = make_opnd(n, a, nil, An, Xn, PCDX, REGIDX);
						}
					}
				}
				elif (e1->token eq REGINDX)			/* 2 or 3 elements separated by comma's */
				{									/* REGINDX is last comma */

					a->areg = -1, a->ireg = -1;

					if (lp->token eq REGINDIM)		/* ([...] */
					{
						if (operr1018(n, &err))
							break;
#if AMFIELDS
						a->am.f.mind = 1;
#else
						a->am |= MIND;
#endif
						if (rp->token ne COMMA)		/* ([...], od) */
						{
							mem_ind(a, lp->left, &bd, &An, &Xn);  /* dispatch [] elements */
							if (Xn eq 0 and is_asreg(rp) ne 0)	/* ([bd,An],Xn) */
							{
#if AMFIELDS
								a->am.f.inc = 1;
#else
								a->am |= POSTI;
#endif
								Xn = rp;
							}
							else
								oud = rp;
						}
					}
					elif (lp->token eq COMMA)		/* (x,,) */
					{
						NP cp = lp->left;

						if (cp->token eq REGINDIM)	/* ([..],,) */
						{
							if (operr1018(n,&err))
								break;
#if AMFIELDS
							a->am.f.mind = 1;
#else
							a->am |= MIND;
#endif
							mem_ind(a, cp->left, &bd, &An, &Xn);

							if (Xn)
								err = opnd_err(n, 18, "too many registers");

#if AMFIELDS
							a->am.f.inc = 1;
#else
							a->am |= POSTI;
#endif
							Xn = lp->right;
							oud = e1->right;
						othw
							if (can_REGIDX(lp->left, lp->right))		/* 02'12 HR */
							{
								a->disp = cp->val.i;
								err = make_opnd(n, a, nil, lp->right, rp, PCDX, REGIDX);
								break;
							othw
								if (operr1018(n,&err))
									break;
								Xn = rp;
								An = lp->right;
								bd = cp;
							}
						}
					othw							/* (,) */
						if (can_REGINDISP(lp, rp))				/* 02'12 HR */
						{
							a->disp = lp->val.i;
							err = make_opnd(n, a, nil, rp, nil, PCD, REGID);
							break;
						othw
							if (operr1018(n,&err))
								break;
							Xn = nil;
							An = rp;
							bd = lp;
						}
					}

					err = make_opnd(n, a, bd, An, Xn, PCDXX, REGIDXX);

					if (oud)
					{
						err = name_xpr(a->outd, oud, ABS);
						if (err)
							opnd_err(n, 19, "invalid outer displacement");
						else
#if AMFIELDS
							a->am.f.odisp = 1;
#else
							a->am |= ODISP;
#endif
					}
				}
			break;
		}

		freenode(e1);
	}
	return err;
}

void pr_opnd(short, OPND *, char *);

global
OPND * p_ea(OPND *a, short type, short n)
{
	short err = 0;
	NP e1;
	MO(a->am) = NONE;

	if (cur->token eq PREP)
		return immediate(a, IMMXPR, n), a;

	e1 = asm_expr();
	err = ea_to_a(a, e1, type, n);
	if (!err)

#if AMFIELDS
		if (a->am.f.symb and a->am.f.absw)
#else
		if ((a->am&SYMB) and (a->am&ABSW))
#endif
		{
/*			console("am: 0x%04x\n",a->am);
*/			opnd_err(n, 20, "symbol.w not allowed");
		}
	if (MM(a->am) eq NONE)
		opnd_err(n, 21, "syntax");
	elif (err eq 0)
		if (check_ea(a, type))
			return a;
		else
			ea_error(n, type);

	return nil;
}
