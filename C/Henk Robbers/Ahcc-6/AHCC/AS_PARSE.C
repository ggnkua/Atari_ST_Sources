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
 * assembler: parse each individual instructions arguments
 *
 */

#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include "param.h"

#include "decl.h"
#include "body.h"
#include "d2.h"
#include "expr.h"
#include "e2.h"
#include "pre.h"
#include "inst.h"
#include "opt.h"
#include "out.h"
#include "reg.h"
#include "po.h"
#include "plib.h"
#include "as.h"
#include "as_plib.h"

#define DEF_AS_PROTO 1
#include "as_defs.h"

OPND *newop(void);
short is_mfpcr(short *cr);
bool  is_fpsr (short *sr);

static
void must_an(short n)
{
	opnd_err(n, "must be (An)");
}

global
short missing(short n)
{
	return opnd_err(n, "missing");
}

global
void out_of_range(short n)
{
	opnd_err(n, "out of range");
}

/* NB!!!! OPMODE must be passed by value */
global
bool m_no_absw(OPMODE m, short mo)
{
#if AMFIELDS
	m.f.absw = 0;
	return m.i eq mo;
#else
	return (m & ~ABSW) eq mo;
#endif
}

static
char bwl [] = "bwl     ",
     bwls[] = "bwls    ",
#if COLDFIRE
     bw  [] = "bw      ",
     fC  [] = "     d  ",
#endif
     b   [] = "b       ",
     bl  [] = "b l     ",
     dsdc[] = "bwl x  s",
      wl [] = " wl     ",
      ll [] = "  l     ";
#if FLOAT
char fpx [] = "  l x   ",
    forfp[] = "bwl xdps";
#endif

enum
{
	mandatory, optional
};

static
short isize(Cstr allowed, short def)		/* 12'10 HR: allow for .label */
{
	short sz = -1;
	G.dot_seen = false;
	if (cur->token eq SELECTOR)
	{
		fadvnode();
		if (cur->token ne ID)
			opnd_err(0, "no size identifier");
		else
		{
			if   (allowed[0] ne ' ' and stricmp(cur->name, "b") eq 0)
				sz = DOT_B;
			elif (allowed[1] ne ' ' and stricmp(cur->name, "w") eq 0)
				sz = DOT_W;
			elif (allowed[2] ne ' ' and stricmp(cur->name, "l") eq 0)
				sz = DOT_L;
			elif (allowed[3] ne ' ' and stricmp(cur->name, "s") eq 0)
				sz = DOT_B;			/* short branche operand */
			elif (allowed[4] ne ' ' and stricmp(cur->name, "x") eq 0)
				sz = DOT_X;
			elif (allowed[5] ne ' ' and stricmp(cur->name, "d") eq 0)
				sz = DOT_D;
			elif (allowed[6] ne ' ' and stricmp(cur->name, "p") eq 0)
				sz = DOT_P;
			elif (allowed[7] ne ' ' and stricmp(cur->name, "s") eq 0)
				sz = DOT_S+1;		/* single precision floating point */

			if (sz ne -1)
				fadvnode();
			else
				G.dot_seen = true;

		}
	}
	else
		sz = def;

	return sz;
}

static
bool p_colon(short n)
{
	if (cur->token eq LABEL)
	{
		fadvnode();
		return true;
	othw
		opnd_err(n, "expects ':'");
		return false;
	}
}

static
bool opt_colon(short n)
{
	if (cur->token eq LABEL)
	{
		fadvnode();
		return true;
	othw
		return false;
	}
}

static
bool p_comma(short n)
{
	if (cur->token eq COMMA)
	{
		fadvnode();
		return true;
	othw
		missing(n);
		return false;
	}
}

static
bool opt_comma(void)
{
	if (cur->token eq COMMA)
	{
		fadvnode();
		return true;
	othw
		return false;
	}
}

static
bool p_Dn(OPND *op, short n)
{
	if (p_ea(op, 0, n))
	if (MO(op->am) eq REG)
	if (ISDonly(op->areg))
		return true;
	opnd_err(n, "not a data register");
	return false;
}

static
bool p_An(OPND *op, short n)
{
	if (p_ea(op, 0, n))
	if (MO(op->am) eq REG)
	if (ISAonly(op->areg))
		return true;
	opnd_err(n, "not an address register");
	return false;
}

#if FLOAT
static
bool p_Fn(OPND *op, short n)
{
	if (p_ea(op, 0, n))
	if (MO(op->am) eq REG)
	if (ISFonly(op->areg))
		return true;
	opnd_err(n, "not a floating point register");
	return false;
}
#endif

static
bool p_Xn(OPND *op, short n)
{
	if (p_ea(op, 0, n))
	if (MO(op->am) eq REG)
		return true;
	opnd_err(n, "must be register direct");
	return false;
}

static
bool is_srccr(IP ip, OPND *a, bool sr, bool usp, short n)
{
	if (!sr)              return false;
	if (cur->token ne ID) return false;
	if (stricmp(cur->name, "ccr") eq 0)
	{
		if (ip->sz ne DOT_W and ip->sz ne DOT_B)
			opnd_err(0, "only byte and word size allowed");
		else
			MO(a->am) = CONDREG;
		a->disp = CCR;
		return true;
	}

	if (stricmp(cur->name, "sr") eq 0)
	{
		if (G.CPU & _S)
		{
			if (ip->sz ne DOT_W)
				opnd_err(0, "only word size allowed");
			else
				MO(a->am) = CONDREG;
			a->disp = SR;
		}
		else
			opnd_err(n, "sr is privileged");

		return true;
	}

	if (usp and stricmp(cur->name, "usp") eq 0)
	{
		if (G.CPU & _S)
		{
			if (ip->sz ne DOT_W and ip->sz ne DOT_L)
				opnd_err(0, "only word and long allowed");
			else
				MO(a->am) = CONDREG;
			ip->sz = DOT_L;
			a->disp = USP;
		}
		else
			opnd_err(n, "usp is privileged");

		return true;
	}

	return false;		/* only return false if it is NOT one of sr,ccr,usp */
}

static
void p_imm_ea(IP ip, OPND *arg, OPND *dst, short tok, bool srccr, short ty)
{
	ip->reg = -1;
	ip->sz = isize(bwl, DOT_W);
	if (immediate(arg, IMMXPR, 1))
		if (p_comma(2))
			if (is_srccr(ip, dst, srccr, false, 2))
			{
				fadvnode();
				if (MO(dst->am) eq CONDREG)
					AS_PARSE_OK;
			}
			elif (p_ea(dst, ty, 2))
				if (check_imm(ip->arg->disp, ip->sz, 1))
					AS_PARSE_OK;
}

/* add, sub, and, or, eor that are really addi, subi, andi, ori, eori */
static
void p_simmp_ea(IP ip, OPND *arg, OPND *dst, short tok, short A_tok)
{
	ip->reg = -1;
	if (immediate(arg, IMMXPR, 1))
		if (p_comma(2))
			if (A_tok and p_isareg(cur))
			{
				p_An(dst, 2);
				tok = A_tok;
				ip->reg = dst->areg;
				AS_PARSE_OK;
			}
			elif (p_ea(dst, AM_D_ALT, 2))
				if (check_imm(ip->arg->disp, ip->sz, 1))
					AS_PARSE_OK;
}

static
void bs_err(void)
{
	opnd_err(0, "byte size not allowed");
}

static
bool p_ok_An(IP ip, OPND *op)
{
	if (MO(op->am) eq REG and ISAA(op))
		if (ip->sz eq DOT_B)
			return bs_err(), false;
	return true;
}

static
bool p_may_An(IP ip, OPND *op, short Atok, short *tok)
{
	if (MO(op->am) eq REG)
	{
		if (Atok and ISAA(op))
		{
			if (ip->sz eq DOT_B)
				return bs_err(), false;

			*tok = Atok;
		}

		ip->reg = op->areg;
		ip->arg->next = nil;
	}

	return true;
}

static
bool p_ea_DnA(IP ip, OPND *arg, OPND *dst, short ty, short Atok, short *tok)
{
	if (p_ea(arg, 0, 1))
		if (p_comma(2))
			if (p_ea(dst, ty, 2))
				return p_may_An(ip, dst, Atok, tok);
	return false;
}

static
bool p_ea_An(IP ip, OPND *arg, OPND *dst, short ty)
{
	if (p_ea(arg, ty, 1))
		if (p_comma(2))
			if (p_An(dst, 2))
			{
				ip->reg = dst->areg;
				ip->arg->next = nil;
				return true;
			}
	return false;
}

static
bool p_ea_Dn(IP ip, OPND *arg, OPND *dst, short ty)
{
	if (p_ea(arg, ty, 1))
		if (p_comma(2))
			if (p_Dn(dst, 2))
			{
				ip->reg = dst->areg;
				ip->arg->next = nil;
				return true;
			}
	return false;
}

static
bool p_Dn_ea(IP ip, OPND *arg, OPND *dst, short srcty, short dstty)
{
	if (p_Dn(arg, 1))
		if (p_comma(2))
			if (p_isdreg(cur))
			{
				p_Dn(dst, 2);
				ip->reg = dst->areg;
				ip->arg->next = nil;
				return true;
			}
			elif (p_ea(dst, p_isdreg(cur) ? srcty : dstty, 2))		/* pe: and d0,d1 */
				return true;
	return false;
}

TP llist = 0;

static
void to_llist(void)
{
	if (cur->token eq ID)
	{
		TP tp = tpcur();
		putt_lifo(&llist, tp);
		advnode();
	}
	else
		error("LOCAL needs comma seperated list if identifiers");

}

static
void p_comma_separated(IP ip, short tok, short sc)		/* 7'15 v5.2 */
{
	TP np ,rv;

	do{
		if (cur->token ne ID)
			return;

		np = tpcur(), advnode();
		rv = tlook(symtab[hash(np->name)],np);

		if (!rv)
		{
			globl_sym(np);
			np->sc = sc;

			np->type = basic_type(T_LONG, 0);
			to_nct(np);
		othw
			rv->sc = K_GLOBAL;		/* if already there, extern --> global */
			freeTn(np);
		}

		if (cur->token ne COMMA)
			break;
		fadvnode();
	}od
}

static
short label_scope(TP rv, TP gv, bool err)
{
	short ty = FIX_lcent;

	if (gv)
		rv->sc = gv->sc;
	if (rv->sc eq K_GLOBAL or rv->sc eq K_EXTERN)
		ty = FIX_glent;
	elif (rv->sc eq K_AHEAD)
		rv->sc = K_STATIC;
	elif (err)
		error("duplicate ASM label %s", rv->name);

	return ty;
}

extern
XP last_label, curtok;

/* 05'13 v4.15: introduction of extra offset to be able to compile
	label equ *+-n correctly */

global
void p_label(XP ll, long offs, bool loc) /* loc is true, label within 'module' */
{
	short ty;
	TP lb, rv, gv = nil;
	XP help;
	FIXUP *f;
	REFS *rf;
	bool dot = ll->nflgs.f.dot;
	help = cur;
	cur = ll;
	lb = tpcur();
	cur = help;

	if (dot)
		rv = tlook(G.dot_labels, lb);
	else
	{
		new_dotscope();
		if (loc)		/* in module */
		{
			gv = tlook(symtab[hash(lb->name)],lb);	/* might be globl */
			rv = tlook(G.scope->b_syms, lb);
		}
		else
			rv = tlook(symtab[hash(lb->name)],lb);
	}

	if (rv)
	{
		ty = label_scope(rv, gv, rv->sc ne K_LOCAL);
		freeTn(lb);
	othw
		lb->type = asm_type();
		to_nct(lb);
		if (dot)
			dot_sym(lb);
		elif (loc)
			loc_sym(lb);
		else
			globl_sym(lb);
		rv = lb;
		ty = label_scope(rv, gv, false);
	}

	rv->area_info.class = class_now;
	rv->area_info.id    = P.area_now->id;			/* 11'10 HR */
	rv->area_info.disp  = P.area_now->limage;

#if USAGE
	rv->tflgs.f.used = 1;
#endif

	f = o_fixup(rv->name, rv->area_info.id, ty, rv->lbl);	/* name is copied */

	if (f)
	{
		f->disp += offs;
		rf = get_label(P.area_now, rv->name, rv->lbl);
		if (!rf)
		{
			ins_ref(&refmem, &P.area_now->lbls, P.area_now, f, CC_ranout);
			branch_aheads(P.area_now, f);
		}
	}

	if (cur->token eq LABEL)
		fadvnode();
}

void p_local(IP ip, short tok)	/* 7'15 v5.2 */
{
	TP np ,rv;

	do{
		if (cur->token ne ID)
			return;

		np = tpcur(), advnode();
		np->lbl = new_lbl();
/*!!*/	rv = tlook(symtab[hash(np->name)],np);

		if (!rv)
		{
/*!!*/		globl_sym(np);
			np->sc = K_LOCAL;
			np->type = basic_type(T_LONG, 0);
			to_nct(np);
		othw
			rv->lbl = np->lbl;
			freeTn(np);
		}

		if (cur->token ne COMMA)
			break;
		fadvnode();
	}od
}


static
void p_addsubq(IP ip, OPND *arg, OPND *dst, short tok)
{
	ip->reg = -1;
	ip->sz = isize(bwl, DOT_W);
	if (immediate(arg, IMMXPR, 1))
		if (p_comma(2))
			if (p_ea(dst, AM_ALTER, 2))
			{
				long l = ip->arg->disp;
				if (l <= 0 or l > 8)
					opnd_err(1, "not (0 < n <= 8)");
				elif (p_ok_An(ip, dst))
					AS_PARSE_OK;
			}
}

static
bool equ_ok(NP np)			/* PASM compatability */
{
	switch (np->tt)
	{
		case E_BIN:
			if (!equ_ok(np->right))
				return false;
		case E_UNARY:
			if (!equ_ok(np->left))
				return false;
			break;
		case E_LEAF:
			if (np->token eq ID and (np->sc eq K_EXTERN or np->sc eq K_AHEAD))
				return false;
	}
	return true;
}

static
void p_equ(short c)
{
	NP val;
	TP rv;

	if (last_label eq nil)
	{
		last_label = cur;			/* 05'13 HR v4.15 */
		advnode();

		if (cur->token eq COMMA)
			fadvnode();
	}

	last_label->cflgs.i |= c;			/* equ: named value is const */
	val = asm_expr();

	if (val->token eq INSTR and c)		/* 05'13 v4.15: compile label equ *+-n correctly */
		p_label(last_label, val->val.i, P.in_module);
	elif (    val->token eq ICON
	      or (val->cat1 & S_KW) eq 0)
	{
		XP help = cur;
		TP tp;
		cur = last_label;

		tp = tpcur();
		cur = help;

		if (val->token eq ICON)
		{
			tp->offset = val->val.i;
			tp->sc = ENUM;
		}

		tp->token = val->token;
		tp->cat0 = val->cat0;
		tp->cat1 = val->cat1;
		tp->type = val->type;;
		to_nct(tp);

		rv = tlook(symtab[hash(tp->name)],tp);

		if (rv)
		{
			if (rv->cflgs.f.equ)
				errorn(tp, "cant modify");
			else
			{				/*present and changeable ( set or = ) */
				rv->offset = tp->offset;
				rv->token = tp->token;
				rv->cat0 = tp->cat0;
				rv->cat1 = tp->cat1;
				freeTn(tp);
			}
		}
		else
			globl_sym(tp);		/* see see_id */
		freenode(val);
	othw
		if (equ_ok(val))
		{
			putx_lifo(&G.equs, last_label);
			last_label->xpr = val;
		}
		else
			warnn(last_label, "needs constant expression or register name");
	}

	last_label = nil;			/* used */
}

global
void free_equs(void)
{
	XP xp = G.equs;
	while (xp)
	{
		XP nx = xp->next;
		freenode(xp->xpr);
		freeXunit(xp);
		xp = nx;
	}
	G.equs = nil;
}

static
bool p_area(IP ip, OPND *arg)
{
	if (p_ea(arg, 0, 1))
#if AMFIELDS
		if (    ip->arg->am.f.m eq ABS
		    and ip->arg->am.f.symb
		   )
#else
		if (ip->arg->am eq (ABS|SYMB))
#endif
		{
			if (G.scope)
				end_scope();

			new_scope(K_ASM, ip->arg->astr);
			return true;
		}
	opnd_err(1, "must be a single identifier");
	return false;
}

static
bool p_close(void)
{
	if (G.scope)
	{
		if (P.area_now->target eq FIX_text)
			o_endproc();
		end_scope();
		return true;
	}

	error("endmod without module");
	return false;
}

p_A P_equ    { p_equ(CONST); }
p_A P_set    { p_equ(    0); }
p_A P_globl  { p_comma_separated(ip, tok, K_GLOBAL); }
p_A P_global { p_comma_separated(ip, tok, K_GLOBAL); }
p_A P_export { p_comma_separated(ip, tok, K_GLOBAL); }
p_A P_xdef   { p_comma_separated(ip, tok, K_GLOBAL); }
p_A P_import { p_comma_separated(ip, tok, K_EXTERN); }
p_A P_xref   { p_comma_separated(ip, tok, K_EXTERN); }
p_A P_extern { p_comma_separated(ip, tok, K_EXTERN); }
p_A P_local  { p_local(ip, tok); }	/* 7'15 v5.2 */
p_A P_text   { AS_PARSE_OK; }
p_A P_data   { AS_PARSE_OK; }
p_A P_bss    { AS_PARSE_OK; }
p_A P_offset { AS_PARSE_OK; }
p_A P_even   { AS_PARSE_OK; }

p_A P_align
{
	if (cur->token eq ICON)
	{
		arg->disp = cur->val.i;
		advnode();
		AS_PARSE_OK;
	othw
		arg->disp = 2;
	}
}

p_A P_section
{
	if (cur->token ne ID)
		opnd_err(1, "needs ID");
	elif (stricmp(cur->name, "text") eq 0)
		ip->opcode = A_text;
	elif (stricmp(cur->name, "data") eq 0)
		ip->opcode = A_data;
	elif (stricmp(cur->name, "bss") eq 0)
		ip->opcode = A_bss;
	else
		opnd_err(1, "needs 'text', 'data' or 'bss'");
}

p_A P_module
{
	new_dotscope();

	if (p_area(ip, arg))
		AS_PARSE_OK;
}
p_A P_area
{
	new_dotscope();

	if (p_area(ip, arg))
		AS_PARSE_OK;
}
p_A P_endmod
{
	new_dotscope();

	if (p_close())
		AS_PARSE_OK;
}

p_A P_define { S_pre("define"); }
p_A P_macro  { S_pre("macro"); }
p_A P_rept   { S_pre("repeat"); cur = curtok; }
p_A P_repeat { S_pre("repeat"); cur = curtok; }
p_A P_if     { S_pre("if"); }
p_A P_ifne   { S_pre("ifne"); }
p_A P_iff    { S_pre("iff"); }
p_A P_ifeq   { S_pre("ifeq"); }
p_A P_ifle   { S_pre("ifle"); }
p_A P_iflt   { S_pre("iflt"); }
p_A P_ifge   { S_pre("ifge"); }
p_A P_ifgt   { S_pre("ifgt"); }

p_A P_ifd    { S_pre("ifdef"); }
p_A P_ifnd   { S_pre("ifndef"); }
p_A P_ifdef  { S_pre("ifdef"); }
p_A P_ifndef { S_pre("ifndef"); }

p_A P_else   { S_pre("else"); }
p_A P_elif   { S_pre("elif"); }
p_A P_fi     { S_pre("fi"); }
p_A P_endif  { S_pre("fi"); }
p_A P_endc   { S_pre("fi"); }
p_A P_include{ S_pre("include"); }
p_A P_incbin
{
	short fileno = 0;
	VP newf;

	G.incbin = true;
	newf = (VP)incl_name(1, &fileno);
	G.incbin = false;

	if (newf)
	{
		ip->arg->astr = (Cstr)newf;
		AS_PARSE_OK;
	}
}

p_A P_cpu
{
	if (cur->token ne ICON)
		opnd_err(1, "must be a number");
	else
		switch(cur->val.i)
		{
			case 0: G.CPU  =  0 | (G.CPU & (_S|_8)); break;
			case 1: G.CPU  = _1 | (G.CPU & (_S|_8)); break;
			case 2: G.CPU  = _2 | (G.CPU & (_S|_5|_8)); break;
			case 3: G.CPU  = _3 | (G.CPU & (_S|_8)); break;
			case 4: G.CPU  = _4 | (G.CPU & (_S|_8)); break;
			case 6: G.CPU  = _6 | (G.CPU & (_S|_8)); break;
			case 5: G.CPU |= _5; break;
			case 7: G.CPU  = _CF| (G.CPU & (_S|_8)); break;
			case 8: G.CPU |= _8; break;
			default:
				opnd_err(1, "must be (0 <= cpu <= 8)");
		}
}

p_A P_user    { G.CPU &= ~_S; }
p_A P_super   { G.CPU |=  _S; }
p_A P_mc68000 { G.CPU =  0 | (G.CPU & (_S|_8)); }
p_A P_mc68010 { G.CPU = _1 | (G.CPU & (_S|_8)); }
p_A P_mc68020 { G.CPU = _2 | (G.CPU & (_S|_8|_5)); }
p_A P_mc68030 { G.CPU = _3 | (G.CPU & (_S|_8)); }
p_A P_mc68040 { G.CPU = _4 | (G.CPU & (_S|_8)); }
p_A P_mc68060 { G.CPU = _6 | (G.CPU & (_S|_8)); }
p_A P_coldfire{ G.CPU = _CF | (G.CPU & (_S|_8|_H)); }
p_A P_mc68851 { G.CPU |= _5; }
p_A P_mc68881 { G.CPU |= _8; }

p_A P_page {  }
p_A P_end { AS_PARSE_OK; }

p_A P_org
{
	if (class_now ne BSS_class)
		error("org not allowed");
	else
	{
		NP e1 = questx();

		if (e1)
		{
			arg->disp = confold_value(e1, FORSIDE);
			MO(arg->am) = IMM;
			AS_PARSE_OK;
		}
	}
}

p_A P_ds
{
	NP e1;

	ip->sz = isize(dsdc, DOT_W);
	e1 = questx();

	if (e1)
	{
		arg->disp = confold_value(e1, FORSIDE);
		MO(arg->am) = IMM;
		AS_PARSE_OK;
	}
}

static
bool well_formed(NP np, short sz)
{
	NP lp = np->left,
	   rp = np->right;

	if (np->token eq ID)
		return true;

	if (    np->token eq ICON
	    and check_imm(np->val.i, sz, 9)
	   )
		return true;

	if (np->token eq PLUS)
	{
		if (   lp->token ne ID
		    or rp->token ne ICON
		   )
			return false;

		if (sz eq DOT_L)
			return true;

		return check_imm(lp->val.i, sz, 9);
	}

	if (	np->token eq MINUS
	    and lp->token eq ID
	    and rp->token eq ID
	   )
	{
		return true;
	}

	return false;
}

static
bool check_dc(NP np, short sz)
{
	if (np->token eq COMMA)
		return     check_dc(np->left,  sz)
		       and check_dc(np->right, sz);

	switch (sz)
	{
	case DOT_B:
		return     np->token eq SCON
		      or  (    np->token eq ICON
		           and check_imm(np->val.i, DOT_B, 9)
		          )
		      ;
	case DOT_W:
	case DOT_L:
		return well_formed(np, sz);

#if FLOAT
	case DOT_D:
	case DOT_X:
		if (np->token eq ICON)
		{
			newrcon(np, np->val.i);
			np->type = basic_type(T_REAL, 0);
			return true;
		}

		return np->token eq RCON;
#endif
	}

	return false;
}

p_A P_dc
{
	if (no_image(P.area_now->target))
		error("invalid opcode");
	else
	{
		NP e1;

		ip->sz = isize(dsdc, DOT_W);
		e1 = get_expr();

		if (e1)
		{
			form_types(e1, FORSIDE, 0);
			if (check_dc(e1, ip->sz))
			{
				(NP)ip->arg = e1;
				AS_PARSE_OK;
				return;
			}
			else
				out_of_range(9);

			freenode(e1);
		}
	}
}

p_A P_dcb
{
	if (no_image(P.area_now->target))
		error("invalid opcode");
	else
	{
		NP e1;

		ip->sz = isize(dsdc, DOT_W);
		e1 = get_expr();

		if (e1)
		{
			form_types(e1, FORSIDE, 0);

			if (e1->token eq COMMA)
			{
				if (e1->left->token ne ICON)
					opnd_err(2, "needs constant expression");
				elif (e1->left->val.i <= 0)
					out_of_range(2);
				elif (check_dc(e1->right, ip->sz))
				{
					(NP)ip->arg = e1;
					AS_PARSE_OK;
					return;
				}
				else
					out_of_range(9);

			othw
				if (check_dc(e1, ip->sz))
				{
					(NP)ip->arg = e1;
					AS_PARSE_OK;
					return;
				}
				else
					out_of_range(9);
			}

			freenode(e1);
		}
	}
}

bool scon_tree(NP np)
{
	bool ok;
	if (np->token eq COMMA)
	{
		ok = scon_tree(np->left);
		if (ok)
			ok = scon_tree(np->right);
	}
	elif (np->token eq SCON)
		return true;
	return ok;
}

p_A P_ascii
{
	if (no_image(P.area_now->target))
		error("invalid opcode");
	else
	{
		NP e1;

		ip->sz = DOT_B;

		e1 = get_expr();

		if (e1)
		{
			form_types(e1, FORSIDE, 0);

			if (scon_tree(e1))
			{
				(NP)ip->arg = e1;
				AS_PARSE_OK;
				return;
			}
			else
				opnd_err(1, "needs quoted strings");

			freenode(e1);
		}
	}
}

p_A P_asciil { P_ascii(ip, tok, arg, dst); }
p_A P_asciiz { P_ascii(ip, tok, arg, dst); }

static
bool p_XY(IP ip, OPND *arg, OPND *dst, short tok)
{
	if (p_isdreg(cur))
	{
		p_Dn(arg, 1);
		if (p_comma(2))
			if (p_Dn(dst, 2))
				return true;
	othw
		if (p_ea(arg, 0, 1))
#if AMFIELDS
			if (!(    arg->am.f.m eq REGI
			      and arg->am.f.dec
			   ) )
#else
			if (arg->am ne (REGI|DEC))
#endif
				opnd_err(1, "must be data register or -(An)");
			elif (p_comma(2))
				if (p_ea(dst, 0, 2))
#if AMFIELDS
					if (!(    dst->am.f.m eq REGI
					      and dst->am.f.dec
					   ) )
#else
					if (dst->am ne (REGI|DEC))
#endif
						opnd_err(2, "must be -(An)");
					else
						return true;
	}
	return false;
}

p_A P_nbcd
{
	if (p_ea(arg, AM_D_ALT, 1))
		AS_PARSE_OK;
}

p_A P_abcd {                             if (p_XY(ip, arg, dst, tok)) AS_PARSE_OK; }
p_A P_sbcd {                             if (p_XY(ip, arg, dst, tok)) AS_PARSE_OK; }

p_A P_addx { ip->sz = isize(bwl, DOT_W); if (p_XY(ip, arg, dst, tok)) AS_PARSE_OK; }
p_A P_subx { ip->sz = isize(bwl, DOT_W); if (p_XY(ip, arg, dst, tok)) AS_PARSE_OK; }

p_A P_negx
{
	ip->sz = isize(bwl, DOT_W);
	if (p_ea(arg, AM_D_ALT, 1))
		AS_PARSE_OK;
}

static
void p_pack(IP ip, OPND *arg, OPND *dst, OPND *adj, short tok)
{
	ip->sz = DOT_W;
	if (p_XY(ip, arg, dst, tok))
		if (!opt_comma())
			AS_PARSE_OK;
		elif (immediate(adj, IMMCONS, 3))
			if (check_imm(adj->disp, DOT_W, 3))
				dst->next = adj, AS_PARSE_OK;
}

p_A P_pack { p_pack(ip, arg, dst, newop(), tok); }
p_A P_unpk { p_pack(ip, arg, dst, newop(), tok); }

static
void inst_ea_An(IP ip, OPND *arg, OPND *dst, short tok)
{
	ip->sz = isize(wl, DOT_W);
	if (p_ea_An(ip, arg, dst, AM_ALL))
		AS_PARSE_OK;
}

p_A P_cmpa { inst_ea_An(ip, arg, dst, tok); }
p_A P_adda { inst_ea_An(ip, arg, dst, tok); }
p_A P_suba { inst_ea_An(ip, arg, dst, tok); }

p_A P_addq { p_addsubq(ip, arg, dst, tok); }
p_A P_subq { p_addsubq(ip, arg, dst, tok); }

static
void p_regular(IP ip, OPND *arg, OPND *dst,
               short tok, short Atok, short Itok,
               short srcty, short dstty)
{
	ip->sz = isize(bwl, DOT_W);
	if (cur->token eq PREP)
		p_simmp_ea(ip, arg, dst, Itok, Atok);
	elif (p_isdreg(cur))
	{
		p_Dn(arg, 1);
		if (p_comma(2))
			if (p_isdreg(cur))
			{
				p_Dn(dst, 2);
				ip->reg = dst->areg;
				ip->arg->next = nil;
				AS_PARSE_OK;
			}
			elif (Atok and p_isareg(cur))
			{
				p_An(dst, 2);
				if (p_may_An(ip, dst, Atok, &tok))
					AS_PARSE_OK;
			}
			elif (p_ea(dst, dstty, 2))
				AS_PARSE_OK;
	othw
		if (Atok)
			if (p_ea_DnA(ip, arg, dst, srcty, Atok, &tok))
				AS_PARSE_OK;
			else ;
		elif (p_ea_Dn(ip, arg, dst, srcty))
			AS_PARSE_OK;
	}
}

/* well, not really very regular :-( */
p_A P_add  { p_regular(ip, arg, dst, tok, A_adda, A_addi, AM_ALL,   AM_M_ALT); }
p_A P_sub  { p_regular(ip, arg, dst, tok, A_suba, A_subi, AM_ALL,   AM_M_ALT); }
p_A P_and  { p_regular(ip, arg, dst, tok, 0,      A_andi, AM_D_ADD, AM_M_ALT); }
p_A P_or   { p_regular(ip, arg, dst, tok, 0,      A_ori,  AM_D_ADD, AM_M_ALT); }


p_A P_addi { p_imm_ea(ip, arg, dst, tok, false, AM_D_ALT); }
p_A P_subi { p_imm_ea(ip, arg, dst, tok, false, AM_D_ALT); }
p_A P_cmpi { p_imm_ea(ip, arg, dst, tok, false, AM_D_ALT); }
p_A P_andi { p_imm_ea(ip, arg, dst, tok, true,  AM_D_ALT); }	/* true: allow SR,CCR */
p_A P_ori  { p_imm_ea(ip, arg, dst, tok, true,  AM_D_ALT); }
p_A P_eori { p_imm_ea(ip, arg, dst, tok, true,  AM_D_ALT); }

p_A P_callm
{
	ip->sz = DOT_B;
	p_imm_ea(ip, arg, dst, tok, false, AM_C_ALT);
}

p_A P_cmp			/* ea,Dn version of eor */
{
	ip->sz = isize(bwl, DOT_W);
	if (cur->token eq PREP)
		p_simmp_ea(ip, arg, dst, A_cmpi, A_cmpa);
	elif (p_ea_DnA(ip, arg, dst, AM_ALL, A_cmpa, &tok))
		AS_PARSE_OK;
}

p_A P_eor			/* Dn,ea version of cmp */
{
	ip->sz = isize(bwl, DOT_W);
	if (cur->token eq PREP)
		p_simmp_ea(ip, arg, dst, A_eori, 0);
	elif (p_Dn(arg, 1))
	{
		ip->reg = arg->areg;
		ip->arg->next = nil;
		if (p_comma(2))
			if (p_ea(arg, AM_D_ALT, 2))
				AS_PARSE_OK;
	}
}

static
void p_shift(IP ip, OPND *arg, OPND *dst, short tok)
{
	ip->sz = isize(bwl, DOT_W);
	if (p_isdreg(cur))
	{
		p_Dn(arg, 1);
		if (cur->token eq COMMA)
		{
			if (p_comma(2))
				if (p_Dn(dst, 2))
					ip->reg = dst->areg, AS_PARSE_OK;
		othw
			*dst = *arg;		/* 7'15 v5.2 shift Dn defaults to shift #1,Dn (Pure C compat) */
			MO(arg->am) = IMM;
			arg->disp = 1;
			ip->reg = dst->areg;
			AS_PARSE_OK;
		}
	}
	elif (cur->token eq PREP)
	{
		if (immediate(arg, IMMCONS, 1))
			if (p_comma(2))
				if (arg->disp < 1 or arg->disp > 8)
					out_of_range(1);	/* 11'09 HR operand 1 */
				elif (p_Dn(dst, 2))
					ip->reg = dst->areg, AS_PARSE_OK;
	othw
		if (ip->sz ne DOT_W)
			opnd_err(0, "must be word size");
		elif (p_ea(arg, AM_M_ALT, 1))
			ip->reg = -1, AS_PARSE_OK;
	}
}

p_A P_asl  { p_shift(ip, arg, dst, tok); }
p_A P_asr  { p_shift(ip, arg, dst, tok); }
p_A P_lsl  { p_shift(ip, arg, dst, tok); }
p_A P_lsr  { p_shift(ip, arg, dst, tok); }
p_A P_rol  { p_shift(ip, arg, dst, tok); }
p_A P_ror  { p_shift(ip, arg, dst, tok); }
p_A P_roxl { p_shift(ip, arg, dst, tok); }
p_A P_roxr { p_shift(ip, arg, dst, tok); }

static
void p_ea_1(IP ip, short sz, OPND *arg, short tok, short ty)
{
	if (sz) ip->sz = isize(bwl, DOT_W);
	if (p_ea(arg, ty, 1))
		AS_PARSE_OK;
}

p_A P_tst { p_ea_1(ip, DOT_W, arg, tok, AM_ALL  ); }
p_A P_neg { p_ea_1(ip, DOT_W, arg, tok, AM_D_ALT); }
p_A P_not { p_ea_1(ip, DOT_W, arg, tok, AM_D_ALT); }

p_A P_clr
{
	ip->sz = isize(bwl, DOT_W);
	if (p_isareg(cur) and ip->sz > DOT_B)
	{
		tok = A_suba;				/* clr a1 --> suba a1,a1 */
		p_An(arg, 1);
		ip->reg = arg->areg;
		AS_PARSE_OK;
	}
	elif (p_ea(arg, AM_D_ALT, 1))
		AS_PARSE_OK;
}

static
void p_bit(IP ip, OPND *arg, OPND *dst, short tok, short type)
{
	isize(bl, DOT_W);
	if (p_ea(arg, 0, 1))
		if (p_comma(2))
			if (p_ea(dst, AM_D_ADD, 2))
				if (MO(arg->am) ne REG and !m_no_absw(arg->am, IMM))
					opnd_err(1, "must be Dn or constant immediate");
				else
					AS_PARSE_OK;
}

p_A P_btst { p_bit(ip, arg, dst, tok, AM_D_ADD); }
p_A P_bchg { p_bit(ip, arg, dst, tok, AM_D_ALT); }
p_A P_bclr { p_bit(ip, arg, dst, tok, AM_D_ALT); }
p_A P_bset { p_bit(ip, arg, dst, tok, AM_D_ALT); }

static
void dc_err(short n)
{
	opnd_err(n, "must be Dn or constant");
}

static
OPND * p_bfow(void)
{
	OPND *offset = newop(), *width = newop();

	if (cur->token ne BLOCK)
		return missing(2), (OPND *)nil;
	fadvnode();
	if (p_ea(offset, 0, 2))
	{
		if (    MO(offset->am) ne REG
		    and !m_no_absw(offset->am, IMM)
		    and !m_no_absw(offset->am, ABS)
		   )
			return dc_err(2), (OPND *)nil;
		if (cur->token ne FIELD)
			return missing(2), (OPND *)nil;
		else
		{
			fadvnode();
			width = p_ea(width, 0, 3);
			if (width eq nil)
				return nil;
			if (    MO(width->am) ne REG
			    and !m_no_absw(width->am, IMM)
			    and !m_no_absw(width->am, ABS)
			   )
				return dc_err(2), (OPND *)nil;
			if (cur->token ne /* br */ KCOLB)
				return missing(2), (OPND *)nil;
			fadvnode();
		}
		offset->next = width;
		return offset;
	}
	return nil;
}

static
void p_bf(IP ip, OPND *arg, OPND *d, short tok, short ty)
{
	if (p_ea(arg, ty, 1))
	{
		OPND *b = p_bfow();
		if (b)
		{
			if (d)
			{
				if (!p_comma(2))
					return;
				if (p_Dn(d, 4))
					ip->reg = d->areg;
				else
					return;
			}
			arg->next = b;
			AS_PARSE_OK;
		}
	}
}

p_A P_bftst  { p_bf(ip, arg, nil, tok, AM_C_ADD|AM_DN); }
p_A P_bfchg  { p_bf(ip, arg, nil, tok, AM_C_ALT|AM_DN); }
p_A P_bfclr  { p_bf(ip, arg, nil, tok, AM_C_ALT|AM_DN); }
p_A P_bfset  { p_bf(ip, arg, nil, tok, AM_C_ALT|AM_DN); }

p_A P_bfextu { p_bf(ip, arg, dst, tok, AM_C_ADD|AM_DN); }	/* <ea>{o:w},Dn */
p_A P_bfexts { p_bf(ip, arg, dst, tok, AM_C_ADD|AM_DN); }	/* <ea>{o:w},Dn */
p_A P_bfffo  { p_bf(ip, arg, dst, tok, AM_C_ADD|AM_DN); }	/* <ea>{o:w},Dn */
p_A P_bfins													/* Dn,<ea>{o:w} */
{
	if (p_Dn(dst, 1))
		if (p_comma(2))
		{
			if (p_ea(arg, AM_C_ALT|AM_DN, 2))
			{
				OPND *b = p_bfow();
				if (b)
				{
					ip->reg = dst->areg;
					arg->next = b;
					AS_PARSE_OK;
				}
			}
		}
}

p_A P_exg
{
	isize(ll, DOT_L);		/* 07'13 v4.15 accept .l */
	if (p_Xn(arg, 1))
	{

		ip->reg = arg->areg;
		if (p_comma(2))
			if (p_Xn(arg, 2))
			{
				if (ISD(ip->reg) ne ISD(arg->areg))
					if (ISD(arg->areg))		/* 03'09: 2nd operand D, then swap (was A) */
					{
						short reg = ip->reg;
						ip->reg = arg->areg;
						arg->areg = reg;
					}
				AS_PARSE_OK;
			}
	}
}

p_A P_swap
{
	isize(wl, DOT_W);	/* 7'15 v5.2 accept .w */
	if (p_Dn(arg, 1))
		ip->reg = arg->areg, AS_PARSE_OK;
}

p_A P_sats
{
	if (p_Dn(arg, 1))
		ip->reg = arg->areg, AS_PARSE_OK;
}

p_A P_ext
{
	ip->sz = isize(wl, DOT_W);
	if (p_Dn(arg, 1))
	{
		ip->sz = ip->sz eq DOT_W ? DOT_B : DOT_W;
		ip->reg = arg->areg;
		AS_PARSE_OK;
	}
}

p_A P_extb
{
	ip->sz = isize(ll, DOT_L);
	if (p_Dn(arg, 1))
		ip->reg = arg->areg, AS_PARSE_OK;
}

p_A P_illegal { AS_PARSE_OK; }

p_A P_jsr { p_ea_1(ip, 0, arg, tok, AM_CTRL); }
p_A P_jmp { p_ea_1(ip, 0, arg, tok, AM_CTRL); }
p_A P_pea { isize(ll, 0); p_ea_1(ip, 0, arg, tok, AM_CTRL); }

p_A P_lea
{
	isize(ll, DOT_L);
	ip->sz = DOT_L;
	if (p_ea_An(ip, arg, dst, AM_CTRL))
		AS_PARSE_OK;
}

p_A P_link
{
	ip->sz = isize(wl, DOT_W);
	if (ip->sz eq DOT_L and (G.CPU & _H) eq 0)
		opnd_err(0, "long size not allowed with 68000");
	elif (p_An(arg, 1))
	{
		ip->reg = arg->areg;
		if (p_comma(2))
			if (p_ea(arg, 0, 2))
				if (!m_no_absw(arg->am, IMM))
					opnd_err(2, "needs constant immediate");
				else
					AS_PARSE_OK;
	}
}

p_A P_unlk
{
	if (p_An(arg, 1))
		ip->reg = arg->areg, AS_PARSE_OK;
}

p_A P_move
{
	ip->reg = -1;
	ip->sz = isize(bwl, DOT_W);
	if (is_srccr(ip, arg, true, true, 1))
	{
		fadvnode();
		if (MO(arg->am) eq CONDREG)
			if (p_comma(2))
				if (arg->disp eq USP)
					if (p_An(dst,2))
						AS_PARSE_OK;
					else
						;
				elif (p_ea(dst, AM_D_ALT, 2))
					AS_PARSE_OK;
	othw
		if (p_ea(arg, 0, 1))
			if (p_comma(2))
				if (is_srccr(ip, dst, true, true, 2))
				{
					if (MO(dst->am) eq CONDREG)
						if (dst->disp eq USP)
							if (!ISAA(arg))
								opnd_err(1, "not a address register");
							else
								AS_PARSE_OK;
						elif (check_ea(arg, AM_D_ADD))
							AS_PARSE_OK;
						else
							ea_error(2, AM_D_ADD);
					fadvnode();
				othw
					if (p_ea(dst, 0, 2))
					{
						if (p_may_An(ip, dst, A_movea, &tok))
							AS_PARSE_OK;
						elif (check_ea(dst, AM_D_ALT))
							AS_PARSE_OK;
						else
							ea_error(2, AM_D_ALT);
					}
				}
	}
}

p_A P_strldsr
{
	if (immediate(arg, IMMCONS, 1))
		AS_PARSE_OK;
}

p_A P_wdebug
{
	if (p_ea(arg, 0, 1))
		if (MO(arg->am) eq REGI or MO(arg->am) eq REGID)
			AS_PARSE_OK;
		else
			opnd_err(1, "needs (An) or d(An)");

}

p_A P_wddata
{
	ip->sz = isize(bwl, DOT_W);
	if (p_ea(arg, AM_M_ALT, 1))
		AS_PARSE_OK;
}

p_A P_movea
{
	ip->sz = isize(wl, DOT_W);
	if (p_ea(arg, 0, 1))
		if (p_comma(2))
			if (p_An(dst, 2))
				{
					ip->reg = dst->areg;
					ip->arg->next = nil;
					AS_PARSE_OK;
				}
}

p_A P_move16
{
	if (p_ea(arg, 0, 1))
		if (p_comma(2))
			if (p_ea(dst, 0, 2))
			{
				OPMODE ma, md;
				bool amm, dmm;

#if AMFIELDS
				arg->am.f.absw = 0;
				dst->am.f.absw = 0;
				ma = arg->am;
				md = dst->am;
				amm = ma.i eq ABS or ma.i eq IMM;
				dmm = md.i eq ABS or md.i eq IMM;

				if (   (    ma.f.m eq REGI
				        and ma.f.inc
				        and md.f.m eq REGI
				        and md.f.inc
				       )
				    or (    amm
				        and md.i eq REGI
				       )
				    or (    amm
				        and md.f.m eq REGI
				        and md.f.inc
				       )
				    or (    ma.f.m eq REGI
				        and dmm
				       )
				    or (    ma.f.m eq REGI
				        and ma.f.inc
				        and dmm
				       )
				   )
#else
				arg->am &= ~ABSW;
				dst->am &= ~ABSW;
				ma = arg->am;
				md = dst->am;
				amm = ma eq ABS or ma eq IMM;
				dmm = md eq ABS or md eq IMM;

				if (   (ma eq (REGI|INC) and md eq (REGI|INC))
				    or (amm and md eq REGI)
				    or (amm and md eq (REGI|INC))
				    or (ma eq REGI and dmm)
				    or (ma eq (REGI|INC) and dmm)
				   )
#endif
					AS_PARSE_OK;
				else
					error("'move16' one or more operands incorrect");
			}
}

/*
 * X_spec() - convert a partial register spec
 *
 * Convert a string like "Rm" or "Rm-Rn" to a mask.
 */

static
void mk_mask(RMASK *msk, short r1, short r2)
{
	if (r1 <= r2)
		while (r1 <= r2)
			*msk |= RM(r1), r1++;
	else
		while (r2 <= r1)
			*msk |= RM(r2), r2++;
}

static
void rl_err(short n)
{
	opnd_err(n, "syntax error in register list");
}

static
bool X_spec(RMASK *mask, short n)
{
	ushort	r1;

	if (p_isdreg(cur))
	{
		r1 = cur->token - K_D0 + DREG;

		fadvnode();
		if (cur->token eq MINUS)
		{
			fadvnode();
			if (p_isdreg(cur))
			{
				mk_mask(mask, r1,
				              cur->token - K_D0 + DREG);
				fadvnode();
			}
			elif (p_isareg(cur))
			{
				mk_mask(mask, r1, K_D7 - K_D0 + DREG);
				mk_mask(mask, K_A0 - K_A0 + AREG - FREG,
				              cur->token - K_A0 + AREG - FREG);
				fadvnode();
			}
			else
				return rl_err(n), false;
		}
		else
			mk_mask(mask, r1, r1);			/* 1 reg */
	}
	elif (p_isareg(cur))
	{
		r1 = cur->token - K_A0 + AREG - FREG;		/* enum order = Dn,Fn,An */
		fadvnode();
		if (cur->token eq MINUS)
		{
			fadvnode();
			if (p_isareg(cur))
			{
				mk_mask(mask, r1,
				              cur->token - K_A0 + AREG - FREG);
				fadvnode();
			}
			elif (p_isdreg(cur))
			{
				mk_mask(mask, r1,
				              K_A0 - K_A0 + AREG - FREG);
				mk_mask(mask, K_D7 - K_D0 + DREG,
				              cur->token - K_D0 + DREG);
				fadvnode();
			}
			else
				return rl_err(n), false;
		}
		else
			mk_mask(mask, r1, r1);			/* 1 reg */
	}

	return true;
}

static
bool reg_list(OPND *op, short n)
{
	if (cur->token eq PREP)
	{
		if (immediate(op, IMMCONS, n))
			return true;
	othw
		RMASK mask = 0;
		X_spec(&mask, n);
		while (cur->token eq DIV)
		{
			fadvnode();
			if (!X_spec(&mask, n))
				break;
		}

		op->disp = mask;
		MO(op->am) = IMM;
		return true;
	}

	return false;
}

#if FLOAT
static
bool F_spec(RMASK *mask, short n)
{
	ushort	r1, r2;
	RMASK msk = 0;

	if (p_isfreg(cur))
	{
		r1 = cur->token - K_F0 + FREG;
		fadvnode();
		if (cur->token eq MINUS)
		{
			fadvnode();
			if (p_isfreg(cur))
			{
				r2 = cur->token - K_F0 + FREG;
				fadvnode();
			}
			else
				return rl_err(n), false;
		}
		else
			r2 = r1;			/* 1 reg */
	}

	if (r1 <= r2)
		while (r1 <= r2)
			msk |= RM(r1), r1++;
	else
		while (r2 <= r1)
			msk |= RM(r2), r2++;

	*mask |= msk;

	return true;
}

static
bool freg_list(OPND *op, short n)
{
	if (cur->token eq PREP)
	{
		if (immediate(op, IMMCONS, n))
			return true;
	othw
		RMASK mask = 0;
		F_spec(&mask, n);
		while (cur->token eq DIV)
		{
			fadvnode();
			if (!F_spec(&mask, n))
				break;
		}

		op->disp = mask >> 8;
		MO(op->am) = IMM;
		return true;
	}

	return false;
}
#endif

static
ushort flip(ushort m)		/* reverse bit order */
{
	short i;
	ushort n = 0;
	for (i=0; i<16; i++)
	{
		n <<= 1;
		n |= m&1;
		m >>= 1;
	}
	return n;
}

p_A P_movem
{
	ip->sz = isize(wl, DOT_W);

	/* register direct or immediate are not allowed <ea>'s */
	if (  is_asreg(cur) ne 0
		or cur->token              eq PREP
	   )
	{
		if (reg_list(arg, 1))
		{
			if (p_comma(2))
				if (p_ea(dst, AM_C_ALT|AM_DEC, 2))
				{
#if AMFIELDS
					if (    dst->am.f.m eq REGI
					    and dst->am.f.dec
					   )
#else
					if (dst->am eq (REGI|DEC))			/* special case, mostly -(sp) */
#endif
						arg->disp = flip(arg->disp);

					AS_PARSE_OK;
				}
		}
	}
	elif (p_ea(arg, AM_C_ADD|AM_INC, 1))
		if (p_comma(2))
			if (reg_list(dst, 2))
				AS_PARSE_OK;
}

/* 05'12 HR: fadvnode() reglist; -> lea      -count(sp),sp
 *							   movem.l  reglist,(sp)
 *           count is calculated for you by the compiler :-)
 */
p_A P_xsave
{
	ip->sz = isize(ll, DOT_L);

	if (reg_list(arg, 1))
	{
		arg->disp = flip(arg->disp);
		AS_PARSE_OK;
	}
}

p_A P_xrest
{
	ip->sz = isize(ll, DOT_L);

	if (reg_list(arg, 1))
		AS_PARSE_OK;
}

#if FLOAT
p_A P_fmovem
{
	short scr, dcr;
  #if COLDFIRE
	if (G.Coldfire)
	{
		isize(fC, DOT_D);
		ip->sz = DOT_D;

	}
	else
  #endif
	{
		ip->sz = isize(fpx, DOT_X);

		if (ip->sz eq DOT_L)
		{
			short t = is_mfpcr(&scr);
			if (t)
			{
				if (p_comma(2))
					if (p_ea(dst, AM_ALTER, 2))
						ip->reg = scr, MO(arg->am) = FCREG, AS_PARSE_OK;
			}
			elif (p_ea(arg, AM_ALL, 1))
				if (p_comma(2))
				{
					t = is_mfpcr(&dcr);
					if (t)
						ip->reg = dcr, MO(dst->am) = FCREG, AS_PARSE_OK;
				}
			return;
		}

		elif (ip->sz ne DOT_X)
		{
			error("invalid size field");
			ip->sz = DOT_X;
		}

	}

	if (  (p_isfreg(cur))
		or cur->token              eq PREP
	   )
	{
		if (freg_list(arg, 1))
			if (p_comma(2))
				if (p_ea(dst, AM_C_ALT|AM_DEC, 2))
					AS_PARSE_OK;
	}
	elif (p_ea(arg, AM_C_ADD|AM_INC, 1))
	{
		if (p_comma(2))
			if (freg_list(dst, 2))
			{
#if AMFIELDS
				if (    arg->am.f.m eq REGI
				    and arg->am.f.inc
				   )
#else
				if (arg->am eq (REGI|INC))			/* special case, mostly (sp)+ */
#endif
					dst->disp = flip(dst->disp << 8);
				AS_PARSE_OK;
			}
	}
}
#endif

p_A P_movep
{
	ip->sz = isize(wl, DOT_W);
	if (p_ea(arg, 0, 1))
		if (p_comma(2))
			if (p_ea(dst, 0, 2))
			{
				if (ISDD(arg) and (MO(dst->am) eq REGID or MO(dst->am) eq REGI))
				{
					ip->reg = arg->areg;
					ip->arg = dst;
					AS_PARSE_OK;
				}
				elif ((MO(arg->am) eq REGID or MO(arg->am) eq REGI) and ISDD(dst))
				{
					ip->reg = -1;
					AS_PARSE_OK;
				}
				else
					error("'movep' needs Dn,d(An) or d(An),Dn");
			}
}

p_A P_moveq
{
	isize(ll, DOT_L);
	if (p_ea(arg, 0, 1))
		if (      MO(arg->am) eq IMM
		      and check_imm(arg->disp, DOT_B, 1))
			if (p_comma(2))
				if (p_Dn(dst, 2))
				{
					ip->reg = dst->areg;
					ip->arg->next = nil;
					AS_PARSE_OK;
				}
}

#if COLDFIRE
static
void p_mvsz(IP ip, short tok, OPND *arg, OPND *dst)
{
	ip->sz = isize(bw, DOT_L);
	if (p_ea_Dn(ip, arg, dst, AM_ALL))
		AS_PARSE_OK;
}

p_A P_mvs { p_mvsz(ip, tok, arg, dst); }
p_A P_mvz { p_mvsz(ip, tok, arg, dst); }

static
void o_Dl(IP ip, short tok, OPND *arg)
{
	isize(ll, DOT_L);
	if (p_Dn(arg, 1))
		AS_PARSE_OK;
}

p_A P_bitrev  { o_Dl(ip, tok, arg); }
p_A P_byterev { o_Dl(ip, tok, arg); }
p_A P_ff1     { o_Dl(ip, tok, arg); }
p_A P_mov3q
{
}
#endif

static
void p_divmul(IP ip, bool l, short tok, OPND *arg, OPND *dst, bool opt)
{
	ip->sz = l ? isize(ll, DOT_L) : isize(wl, DOT_W);
	if (p_ea_Dn(ip, arg, dst, AM_D_ADD))
		if (ip->sz eq DOT_W)
			AS_PARSE_OK;
		elif ((G.CPU & (_H|_CF)) eq 0)
			cpuerr();
		elif (opt_colon(2))
		{
			arg->next = dst;
			if (p_Dn(dst, 3))
				AS_PARSE_OK;
		}
		else
			AS_PARSE_OK;
}

p_A P_muls  { p_divmul(ip, 0, tok, arg, dst, optional); }
p_A P_mulu  { p_divmul(ip, 0, tok, arg, dst, optional); }
p_A P_divs  { p_divmul(ip, 0, tok, arg, dst, optional); }
p_A P_divu  { p_divmul(ip, 0, tok, arg, dst, optional); }
p_A P_divsl { p_divmul(ip, 1, tok, arg, dst, mandatory); }
p_A P_divul { p_divmul(ip, 1, tok, arg, dst, mandatory); }
p_A P_rems	{ p_divmul(ip, 1, tok, arg, dst, mandatory); }
p_A P_remu  { p_divmul(ip, 1, tok, arg, dst, mandatory); }

p_A P_rtm
{
	if (p_An(arg, 1))
		ip->reg = arg->areg, AS_PARSE_OK;
}

p_A P_reset {AS_PARSE_OK;}
p_A P_nop {AS_PARSE_OK;}
p_A P_halt {AS_PARSE_OK;}
p_A P_pulse {AS_PARSE_OK;}
p_A P_stop
{
	if (immediate(arg, IMMCONS, 1))
		AS_PARSE_OK;
}
p_A P_rte {AS_PARSE_OK;}
p_A P_rtd
{
	if (immediate(arg, IMMCONS, 1))
		AS_PARSE_OK;
}
p_A P_rts {AS_PARSE_OK;}
p_A P_trapv {AS_PARSE_OK;}
p_A P_rtr {AS_PARSE_OK;}


p_A P_tas
{
	ip->sz = DOT_B;
	if (p_ea(arg, AM_D_ALT, 1))
		AS_PARSE_OK;
}

p_A P_trap
{
	ip->sz = DOT_W;
	if (immediate(arg, IMMCONS, 1))
		if (arg->disp >= 0 and arg->disp <= 16)
			AS_PARSE_OK;
		else
			out_of_range(1);
}

p_A P_aline
{
	if (immediate(arg, IMMCONS, 1))
		AS_PARSE_OK;
}

static
bool p_cachereg(IP ip, XP xp)
{
	if (xp->token eq ID)
	{
		Cstr s = xp->name;
		fadvnode();
		if   (stricmp(s, "nc") eq 0) { ip->reg = NoC; return true; }
		elif (stricmp(s, "dc") eq 0) { ip->reg = DaC; return true; }
		elif (stricmp(s, "ic") eq 0) { ip->reg = InC; return true; }
		elif (stricmp(s, "bc") eq 0) { ip->reg = BoC; return true; }
	}
	return false;
}

static
void p_cinvpush(IP ip, OPND *arg, short tok)
{
	if (!p_cachereg(ip, cur))
		opnd_err(1, "needs identifier which is one of NC, DC, IC or BC");
	elif (arg eq nil)
		AS_PARSE_OK;
	elif (p_comma(2))
		if (p_ea(arg, 0, 2))
			if (MO(arg->am) eq REGI)
				AS_PARSE_OK;
			else
				must_an(2);
}

p_A P_cinvl  { p_cinvpush(ip, arg, tok); }
p_A P_cinvp  { p_cinvpush(ip, arg, tok); }
p_A P_cinva  { p_cinvpush(ip, nil, tok); }
p_A P_cpushl { p_cinvpush(ip, arg, tok); }
p_A P_cpushp { p_cinvpush(ip, arg, tok); }
p_A P_cpusha { p_cinvpush(ip, nil, tok); }

p_A P_intouch
{
	if (p_ea(arg, 0, 1))
		if (MO(arg->am) eq REGI)
			AS_PARSE_OK;
		else
				must_an(1);
}

typedef struct crr
{
	char text[8];
	short value, cpu;
} CRR;

global
CRR control_regs[] =
{
	{ "SFC",	0,		_H   	},
	{ "DFC",	1	,	_H    	},
	{ "USP",	0x800,	_H    	},
	{ "VBR",	0x801,	_H|_CF 	},

	{ "CACR",	2,		_H|_CF 	},
	{ "CAAR",	0x802,	_2|_3|_4},
	{ "MSP",	0x803,	_2|_3|_4},
	{ "ISP",	0x804,	_2|_3|_4},

	{ "ASID",	3,		_CF		},
	{ "ACR0",	4,		_CF		},
	{ "ACR1",	5,		_CF		},
	{ "ACR2",	6,		_CF		},
	{ "ACR3",	7,		_CF		},
	{ "MMUBAR",	8,		_CF		},
	{ "PC",		0x80f,	_CF		},
	{ "ROMBAR0",0xc00,	_CF		},
	{ "ROMBAR1",0xc01,	_CF		},
	{ "RAMBAR0",0xc04,	_CF		},
	{ "RAMBAR1",0xc05,	_CF		},
	{ "MPCR",	0xc0c,	_CF		},
	{ "EDRAMBAR",0xc0d,	_CF		},
	{ "SECMBAR",0xc0e,	_CF		},
	{ "MBAR",	0xc0f,	_CF		},
	{ "PCR1U0",	0xd02,	_CF		},
	{ "PCR1L0",	0xd03,	_CF		},
	{ "PCR2U0",	0xd04,	_CF		},
	{ "PCR2L0",	0xd05,	_CF		},
	{ "PCR3U0",	0xd06,	_CF		},
	{ "PCR3L0",	0xd07,	_CF		},
	{ "PCR1U1",	0xd0a,	_CF		},
	{ "PCR1L1",	0xd0b,	_CF		},
	{ "PCR2U1",	0xd0c,	_CF		},
	{ "PCR2L1",	0xd0d,	_CF		},
	{ "PCR3U1",	0xd0e,	_CF		},
	{ "PCR3L1",	0xd0f,	_CF		},

	{ "TC", 	3,		_4|_6	},
	{ "ITT0",	4,		_4|_6	},
	{ "ITT1",	5,		_4|_6	},
	{ "DTT0",	6,		_4|_6	},
	{ "DTT1",	7,		_4|_6	},
	{ "MMUSR",	0x805,	_4   	},
	{ "URP",	0x806,	_4|_6	},
	{ "SRP",	0x807,	_4|_6	},

	{ "PCR",	0x808,	   _6	},
	{ "BUSCR",	8,		   _6	},

	{ "", 0, 0 }
};

global
CRR mmu_regs[] =
{
	{ "TT0",	TT0, _3    },
	{ "TT1",	TT1, _3    },
	{ "TC" ,	TC , _3|_5 },
	{ "DRP",	DRP,    _5 },
	{ "SRP",	SRP, _3|_5 },
	{ "CRP",	CRP, _3|_5 },
	{ "CAL",	CAL,    _5 },
	{ "VAL",	VAL,    _5 },
	{ "SCC",	SCC,    _5 },
	{ "AC" ,	AC ,    _5 },
	{ "MMUSR",	MMUSR,	_3 },
	{ "PSR",	PSR,    _5 },
	{ "PCSR",	PCSR,   _5 },
	{ "BAD0",	BAD0,   _5 },
	{ "BAD1",	BAD1,   _5 },
	{ "BAD2",	BAD2,   _5 },
	{ "BAD3",	BAD3,   _5 },
	{ "BAD4",	BAD4,   _5 },
	{ "BAD5",	BAD5,   _5 },
	{ "BAD6",	BAD6,   _5 },
	{ "BAD7",	BAD7,   _5 },
	{ "BAC0",	BAC0,   _5 },
	{ "BAC1",	BAC1,   _5 },
	{ "BAC2",	BAC2,   _5 },
	{ "BAC3",	BAC3,   _5 },
	{ "BAC4",	BAC4,   _5 },
	{ "BAC5",	BAC5,   _5 },
	{ "BAC6",	BAC6,   _5 },
	{ "BAC7",	BAC7,   _5 },
	{ "", 0, 0 }
};

static
CRR * is_crr(Cstr s, CRR *y)
{
	while (*y->text)
	{
		if (stricmp(y->text, s) eq 0)
			return y;
		y++;
	}

	return nil;
}

static
bool is_fpsr(short *sr)
{
	if (cur->token eq ID)
	{
		if (stricmp(cur->name, "FPCR") eq 0)
			return *sr = 4, true;
		if (stricmp(cur->name, "FPSR") eq 0)
			return *sr = 2, true;
		if (stricmp(cur->name, "FPIAR") eq 0)
			return *sr = 1, true;
	}

	return false;
}

static
short is_mfpcr(short *cr)
{
	short sr, t = 0;
	*cr = 0;
	while(is_fpsr(&sr))
	{
		if ((*cr & sr) eq 0)
		{
			*cr |= sr;
			t++;
		}
		fadvnode();
		if (cur->token ne DIV)
			break;
		fadvnode();
	}

	return t;
}


static
bool p_crr(OPND *op, CRR *y, short n)
{
	if (cur->token ne ID)
		opnd_err(n, "needs identifier");
	else
	{
		Cstr s = cur->name;

		fadvnode();

		y = is_crr(s, y);

		if (y)
		{
			if (y->cpu & G.CPU)
			{
				op->disp = y->value;
				MO(op->am) = IMM;
				return true;
			}

			opnd_err(n, "control register not present on current cpu type");
		}
		else
			opnd_err(n, "not a control register identifier");
	}

	return false;
}

p_A P_movec
{
	isize(ll, DOT_L);
	if is_asreg(cur)
	{
		p_Xn(dst, 1);
		ip->reg = dst->areg;
		if (p_comma(2))
			if (p_crr(arg, control_regs, 2))
				AS_PARSE_OK;
	othw
		ip->reg = -1;
		if (p_crr(arg, control_regs, 1))
			if (p_comma(2))
				if (p_Xn(dst, 2))
					AS_PARSE_OK;

	}
}

p_A P_moves
{
	ip->sz = isize(bwl, DOT_W);
	if is_asreg(cur)
	{
		p_Xn(dst, 1);
		ip->reg = dst->areg;
		if (p_comma(2))
			if (p_ea(arg, AM_M_ALT, 2))
				AS_PARSE_OK;
	othw
		ip->reg = -1;
		if (p_ea(arg, AM_M_ALT, 1))
			if (p_comma(2))
				if (p_Xn(dst, 2))
					AS_PARSE_OK;

	}
}

static
bool o_bra(IP ip, OPND *arg, short n)
{
	if (p_ea(arg, 0, n))
	{
		if (MM(arg->am) ne ABS and MM(arg->am) ne INSTD)	/* 05'11 HR: allow INSTD */
			opnd_err(n, "not a valid branch destination");
		elif (ip->sz eq DOT_L and (G.CPU & _H) eq 0)
			opnd_err(n, "long not allowed on 68000");
		elif (check_imm(arg->disp, ip->sz, n))
			return true;
	}
	return false;
}

p_A P_bra			/* Bcc */
{
	ip->sz = isize(bwls, DOT_W);
	if (ip->sz eq DOT_S+1)			/* avoid confusion between Single & Short */
		ip->sz = DOT_B;
	if (o_bra(ip, arg, 1))
		AS_PARSE_OK;
	G.dot_seen = false;
}

p_A P_bsr { P_bra(ip, tok, arg, dst); }		/* only tok is the difference */

p_A P_st			/* Scc */
{
	isize(b, DOT_B);
	if (p_ea(arg, AM_D_ALT, 1))
		AS_PARSE_OK;
}

p_A P_dbra			/* DBcc */
{
	isize(wl,DOT_W);
	ip->sz = DOT_W;
	if (p_Dn(arg,1))
	{
		ip->reg = arg->areg;
		if (p_comma(2))
			if (o_bra(ip, arg, 2))
				AS_PARSE_OK;
	}
}

p_A P_trapt			/* TRAPcc */
{
	ip->sz = isize(wl, DOT_W);
	if (cur->token ne PREP)
		opnd_err(1, "needs constant immediate");
	else
		if (immediate(arg, IMMCONS, 1))
			AS_PARSE_OK;
}

p_A P_cmpm
{
	ip->sz = isize(bwl, DOT_W);
	if (p_ea(arg, 0, 1))
#if AMFIELDS
		if (!(    arg->am.f.m eq REGI
		      and arg->am.f.inc
		   ) )
#else
		if (arg->am ne (REGI|INC))
#endif
			opnd_err(1, "must be (An)+");
		elif (p_comma(2))
			if (p_ea(dst, 0, 2))
#if AMFIELDS
				if (!(    dst->am.f.m eq REGI
				      and dst->am.f.inc
				   ) )
#else
				if (dst->am ne (REGI|INC))
#endif
					opnd_err(2, "must be (An)+");
				else
					AS_PARSE_OK;
}

static
void p_cmpchk2(IP ip, OPND *arg, OPND *dst, short tok)
{
	ip->sz = isize(bwl, DOT_W);
	if (p_ea(arg, AM_C_ADD, 1))
		if (p_comma(2))
			if (p_Xn(dst, 3))
				ip->reg = dst->areg, AS_PARSE_OK;
}
p_A P_cmp2 { p_cmpchk2(ip, arg, dst, tok); }
p_A P_chk2 { p_cmpchk2(ip, arg, dst, tok); }
p_A P_chk
{
	ip->sz = isize(wl, DOT_W);
	if (ip->sz eq DOT_L and (G.CPU & _H) eq 0)
		opnd_err(1, "long not allowed on 68000");
	elif (p_ea(arg, AM_D_ADD, 1))
		if (p_comma(2))
			if (p_Dn(dst, 3))
				ip->reg = dst->areg, AS_PARSE_OK;
}

p_A P_cas
{
	dst->next = newop();
	ip->sz = isize(bwl, DOT_W);
	if (p_Dn(arg, 1))
		if (p_comma(2))
			if (p_Dn(dst, 2))
				if (p_comma(3))
					if (p_ea(dst->next, AM_M_ALT, 3))
						AS_PARSE_OK;
}

static
bool cas_mode(OPND *op)
{
	if (MO(op->am) eq REGI)	return true;		/* (An) */
	if (    MO(op->am) eq REGIDXX				/* (Dn) ? */
	    and op->areg eq -1
	    and op->ireg >= 0
	    and (MO(op->am) & AMFLGS) eq 0			/* no other extensions */
	   )
	{
		op->areg = op->ireg;
		return true;
	}
	return false;
}

p_A P_cas2
{
	OPND *o1,*o2,*o3,*o4;
	o1 = newop(), dst->next = o1;
	o2 = newop(), o1->next = o2;
	o3 = newop(), o2->next = o3;
	o4 = newop(), o3->next = o4;

	ip->sz = isize(wl, DOT_W);
	if (p_Dn(arg, 1))
	if (p_colon(2))
	if (p_Dn(dst, 2))
	if (p_comma(3))
	if (p_Dn(o1, 3))
	if (p_colon(4))
	if (p_Dn(o2, 4))
	if (p_comma(5))
	if (p_ea(o3, 0, 5))
	if (!cas_mode(o3))
		opnd_err(5, "needs (An) or (Dn)");
	else
	if (p_colon(6))
	if (p_ea(o4, 0, 6))
	if (cas_mode(o4))
		AS_PARSE_OK;
	else
		opnd_err(6, "needs (An) or (Dn)");
}

p_A P_bkpt
{
	if (immediate(arg, IMMCONS, 1))
		if (arg->disp >= 0 and arg->disp < 8)
			AS_PARSE_OK;
		else
			opnd_err(1, "needs constant immediate 0 <= i < 8");
}

#if FLOAT
p_A P_fmovesr {}		/* dummy for W_fmovesr */

p_A P_fmove
{
	short fpsr = 0;
	ip->sz = isize(forfp, DOT_W);

	if (p_isfreg(cur))
	{
		p_Fn(arg, 1);				/* fpm */
		if (p_comma(2))
			if (p_isfreg(cur))
			{
				p_Fn(dst, 2);		/* fpn */
				ip->reg = dst->areg;
				AS_PARSE_OK;
			}
			elif (p_ea(dst, AM_D_ALT, 2))	/* fpm,<ea> */
				AS_PARSE_OK;
	}
	else
	if (is_fpsr(&fpsr))			/* FPCR,FPSR,FPIAR */
	{
		fadvnode();
		tok = A_fmovesr;
		if (ip->sz ne DOT_L)
			opnd_err(1, "invalid size");
		elif (p_comma(2))
			if (p_ea(arg, AM_D_ALT, 2))
				ip->reg = fpsr, AS_PARSE_OK;
	}
	else
	if (p_ea(arg, AM_D_ADD, 1))	/* <ea>,fpn */
		if (p_comma(2))
			if (is_fpsr(&fpsr))
			{
				fadvnode();
				tok = A_fmovesr;
				if (ip->sz ne DOT_L)
					opnd_err(1, "invalid size");
				else
					dst->areg = fpsr, AS_PARSE_OK;
			}
			elif (p_Fn(dst, 2))		/* fpn */
				ip->reg = dst->areg, AS_PARSE_OK;
}

static
void p_fp(IP ip, OPND *arg, short tok, bool move)
{
	OPND *dst = arg->next;
	bool have_sz = cur->token eq SELECTOR;

	ip->sz = isize(forfp, DOT_W);

	if (p_isfreg(cur))
		if (have_sz and ip->sz ne DOT_X and !move)
			opnd_err(0, "only none or .x allowed");
		else
		{
			ip->sz = DOT_X;
			p_Fn(arg, 1);				/* fpm */
			if (opt_comma())
			{
				if (p_Fn(dst, 2))		/* fpn */
					ip->reg = dst->areg, AS_PARSE_OK;
			othw
				ip->arg = nil;			/* fpm = fpn */
				ip->reg = arg->areg, AS_PARSE_OK;
			}
		}
	elif (p_ea(arg, AM_D_ADD, 1))
		if (p_comma(2))
			if (p_Fn(dst, 2))		/* fpn */
				ip->reg = dst->areg, AS_PARSE_OK;
}

#define do_p_fp p_fp(ip, arg, tok, false)

p_A P_fint    { do_p_fp; }
p_A P_fsinh   { do_p_fp; }
p_A P_fintrz  { do_p_fp; }
p_A P_fsqrt   { do_p_fp; }
p_A P_flognp1 { do_p_fp; }
p_A P_fetoxm1 { do_p_fp; }
p_A P_ftanh   { do_p_fp; }
p_A P_fatan   { do_p_fp; }
p_A P_fasin   { do_p_fp; }
p_A P_fatanh  { do_p_fp; }
p_A P_fsin    { do_p_fp; }
p_A P_ftan    { do_p_fp; }
p_A P_fetox   { do_p_fp; }
p_A P_ftwotox { do_p_fp; }
p_A P_ftentox { do_p_fp; }
p_A P_flogn   { do_p_fp; }
p_A P_flog10  { do_p_fp; }
p_A P_flog2   { do_p_fp; }
p_A P_fabs    { do_p_fp; }
p_A P_fcosh   { do_p_fp; }
p_A P_fneg    { do_p_fp; }
p_A P_facos   { do_p_fp; }
p_A P_fcos    { do_p_fp; }
p_A P_fgetexp { do_p_fp; }
p_A P_fgetman { do_p_fp; }
p_A P_fdiv    { do_p_fp; }
p_A P_fmod    { do_p_fp; }
p_A P_fadd    { do_p_fp; }
p_A P_fmul    { do_p_fp; }
p_A P_fsgldiv { do_p_fp; }
p_A P_frem    { do_p_fp; }
p_A P_fscale  { do_p_fp; }
p_A P_fsglmul { do_p_fp; }
p_A P_fsub    { do_p_fp; }
p_A P_fcmp    { do_p_fp; }

p_A P_fsabs   { do_p_fp; }
p_A P_fsadd   { do_p_fp; }
p_A P_fsdiv   { do_p_fp; }
p_A P_fsmove  { do_p_fp; }
p_A P_fsmul   { do_p_fp; }
p_A P_fsneg   { do_p_fp; }
p_A P_fssqrt  { do_p_fp; }
p_A P_fssub   { do_p_fp; }

p_A P_fdabs   { do_p_fp; }
p_A P_fdadd   { do_p_fp; }
p_A P_fddiv   { do_p_fp; }
p_A P_fdmove  { do_p_fp; }
p_A P_fdmul   { do_p_fp; }
p_A P_fdneg   { do_p_fp; }
p_A P_fdsqrt  { do_p_fp; }
p_A P_fdsub   { do_p_fp; }

p_A P_fmovecr
{
	if (immediate(arg, IMMCONS, 1))
		if (p_comma(2))
			if (p_Fn(dst, 3))
				ip->reg = dst->areg, AS_PARSE_OK;
}
p_A P_fsincos
{
	do_p_fp;
	if (ip->opcode eq tok)
	{
		if (cur->token eq LABEL)
		{
			fadvnode();
			if (p_Fn(dst, 3))
			{
				short reg = ip->reg;
				ip->reg = dst->areg;
				dst->areg = reg;
				AS_PARSE_OK;
			}
		othw
			opnd_err(3, "needs 2 destination registers");
			ip->opcode = 0;
		}
	}
}

p_A P_fnop { AS_PARSE_OK; }

p_A P_ftst
{
	bool have_sz = cur->token eq SELECTOR;

	ip->sz = isize(forfp, DOT_W);

	ip->reg = -1;
	if (p_isfreg(cur))
		if (have_sz and ip->sz ne DOT_X)
			opnd_err(0, "only none or .x allowed");
		else
		{
			ip->sz = DOT_X;
			p_Fn(arg, 1);
			ip->reg = arg->areg;
			AS_PARSE_OK;
		}
	elif (p_ea(arg, AM_D_ADD, 1))
		AS_PARSE_OK;
}
#endif

static
bool o_pfbra(IP ip, OPND *arg, short n)
{
	if (p_ea(arg, 0, n))
		if (MM(arg->am) ne ABS)
			opnd_err(n, "not a valid branch destination");
		elif (check_imm(arg->disp, ip->sz, n))
			return true;
	return false;
}

static
void o_pfdbf(IP ip, OPND *arg, short tok)
{
	ip->sz = DOT_W;
	if (p_Dn(arg,1))
		if (p_comma(2))
		{
			ip->reg = arg->areg;
			if (o_pfbra(ip, arg, 2))
				AS_PARSE_OK;
		}
}

static
void o_pftrapf(IP ip, OPND *arg, short tok)
{
	bool have_sz = cur->token eq SELECTOR;

	ip->sz = isize(bwl, DOT_B);
	if (!have_sz)
		AS_PARSE_OK;
	elif (immediate(arg, IMMCONS, 1))
		AS_PARSE_OK;
}

#if FLOAT
p_A P_fbf
{
	ip->sz = isize(wl, DOT_W);
	if (o_pfbra(ip, arg, 1))
		AS_PARSE_OK;
}

p_A P_fsf      { if (p_ea(arg, AM_D_ALT, 1)) AS_PARSE_OK; }
p_A P_fdbf     { o_pfdbf  (ip, arg, tok); }
p_A P_ftrapf   { o_pftrapf(ip, arg, tok); }
p_A P_fsave    { if (p_ea(arg, AM_CTRL|AM_DEC, 1)) AS_PARSE_OK; }
p_A P_frestore { if (p_ea(arg, AM_CTRL|AM_INC, 1)) AS_PARSE_OK; }
#endif

static
void p_plpa(IP ip, OPND *arg, short tok)
{
	if (p_ea(arg, 0, 1))
		if (MO(arg->am) eq REGI)
			AS_PARSE_OK;
		else
			opnd_err(1, "must be (An)");
}
p_A P_plpar { p_plpa(ip, arg, tok); }
p_A P_plpaw { p_plpa(ip, arg, tok); }
p_A P_lpstop
{
	if (immediate(arg, IMMCONS, 1))
		if (check_imm(arg->disp, DOT_W, 1))
			AS_PARSE_OK;
}

p_A P_pbbs
{
	ip->sz = isize(wl, DOT_W);
	if (o_pfbra(ip, arg, 1))
		AS_PARSE_OK;
}
p_A P_psbs     { if (p_ea(arg, AM_D_ALT, 1)) AS_PARSE_OK; }
p_A P_pdbbs    { o_pfdbf  (ip, arg, tok); }
p_A P_ptrapbs  { o_pftrapf(ip, arg, tok); }
p_A P_psave    { if (p_ea(arg, AM_CTRL|AM_DEC, 1)) AS_PARSE_OK; }
p_A P_prestore { if (p_ea(arg, AM_CTRL|AM_INC, 1)) AS_PARSE_OK; }

p_A P_pvalid
{
	if (p_ea(arg, 0, 1))
	{
#if AMFIELDS
		if (    arg->am.f.m eq ABS
		    and arg->am.f.symb
#else
		if (    arg->am eq (ABS|SYMB)
#endif
		    and stricmp(arg->astr, "val") eq 0
		   )
			ip->reg = VVAL;
		elif (MO(arg->am) eq REG and ISA(arg->areg))
			ip->reg = arg->areg;
		else
		{
			opnd_err(1, "only VAL or An allowed");
			return;
		}

		if (p_comma(2))
			if (p_ea(arg, AM_C_ALT, 2))
				AS_PARSE_OK;
	}
}

p_A P_pflusha  { AS_PARSE_OK; }
p_A P_pflushan { AS_PARSE_OK; }

static
void pflush_4(IP ip, OPND *arg, short tok)
{
	if (p_ea(arg, 0, 1))
		if (MO(arg->am) eq REGI)
			AS_PARSE_OK;
		else
			must_an(1);
}

p_A P_pflushn { pflush_4(ip, arg, tok); }

static
bool p_fc(OPND *a)
{
	short m = (G.CPU & _5) ? 15 : 7;

	if (p_isdreg(cur))
	{
		a->disp = cur->token - K_D0 + 010;
		fadvnode();
		return true;
	}

	if (p_ea(a, 0, 1))
#if AMFIELDS
		if (    a->am.f.m eq ABS
		    and a->am.f.symb
		   )
#else
		if (a->am eq (ABS|SYMB))
#endif
			if (stricmp(a->astr, "sfc") eq 0)
				return a->disp = 0, true;
			elif (stricmp(a->astr, "dfc") eq 0)
				return a->disp = 1, true;
			else
				;
		if (m_no_absw(a->am, IMM))
			if (a->disp >= 0 and a->disp <= m)
				return a->disp |= 020, true;

	opnd_err(1, "no valid function code specification");
	return false;
}

static
bool p_mask(OPND *a)
{
	if (p_ea(a, 0, 2))
		if (m_no_absw(a->am, IMM))
			if (a->disp >= 0 and a->disp <= 7)
				return true;

	opnd_err(1, "no valid mask specification");
	return false;
}

static
void p_flush(IP ip, OPND *arg, OPND *dst, short tok)
{
	if (G.CPU & _4)
		pflush_4(ip, arg, tok);
	elif (p_fc(arg))
		if (p_comma(2))
			if (p_mask(dst))
				if (!opt_comma())
					AS_PARSE_OK;
				else
				{
					OPND *a = newop();
					dst->next = nil;
					if (p_ea(a, AM_C_ALT, 3))
						dst->next = a, AS_PARSE_OK;
				}
}

p_A P_pflush  { p_flush(ip, arg, dst, tok); }
p_A P_pflushs { p_flush(ip, arg, dst, tok); }
p_A P_pflushr { if (p_ea(arg, AM_M_ADD, 1)) AS_PARSE_OK; }

static
void p_load(IP ip, OPND *arg, OPND *dst, short tok)
{
	if (p_fc(dst))
		if (p_comma(2))
			if (p_ea(arg, AM_C_ALT, 2))
				AS_PARSE_OK;
}

p_A P_ploadr { p_load(ip, arg, dst, tok); }
p_A P_ploadw { p_load(ip, arg, dst, tok); }

static
void p_ptest(IP ip, OPND *arg, OPND *dst, short tok)
{
	if (G.CPU & _4)
		pflush_4(ip, arg, tok);
	else
	{
		OPND *a = newop(), *an = newop();
		ip->reg = -1;
		if (p_fc(dst))
		if (p_comma(2))
		if (p_ea(arg, AM_C_ALT, 2))
		if (p_comma(3))
		if (p_ea(a, 0, 3))
		if (    m_no_absw(a->am, IMM)
			and a->disp >= 0
			and a->disp <= 7
		   )
		{
			dst->next = a;
			if (!opt_comma())
				AS_PARSE_OK;
			elif (p_An(an, 4))
				ip->reg = an->areg, AS_PARSE_OK;
		}
		else
			opnd_err(3, "no valid level specification");
	}
}

p_A P_ptestr { p_ptest(ip, arg, dst, tok); }
p_A P_ptestw { p_ptest(ip, arg, dst, tok); }

static
bool cpu5_ok(OPND *a, short reg, short n)
{
	if (MO(a->am) eq REG)
		if (reg >= DRP and reg <= CRP)
			return opnd_err(n, "register direct not allowed"), false;
	if (n eq 1 and reg eq PCSR)
		return opnd_err(2, "pmove to pcsr not allowed"), false;
	return true;
}

void p_pmove(IP ip, OPND *arg, OPND *dst, short tok)
{
	if (cur->token eq ID and is_crr(cur->name, mmu_regs) ne nil)
	{
		if (p_crr(dst, mmu_regs, 1))
			if (p_comma(2))
				if (p_ea(arg, (G.CPU&_5) ? AM_ALTER : AM_C_ALT, 2))
					if (cpu5_ok(arg, dst->disp, 2))
						ip->reg = 1, AS_PARSE_OK;
	othw
		if (p_ea(arg, (G.CPU&_5) ? AM_ALL : AM_C_ALT, 1))
			if (p_comma(2))
				if (p_crr(dst, mmu_regs, 2))
					if (cpu5_ok(arg, dst->disp, 1))
						ip->reg = -1, AS_PARSE_OK;
	}
}

p_A P_pmove   { p_pmove(ip, arg, dst, tok); }
p_A P_pmovefd { p_pmove(ip, arg, dst, tok); }
