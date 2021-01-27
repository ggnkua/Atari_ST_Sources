/* Copyright (c) 1988,1989 by Sozobon, Limited.  Author: Johann Ruegg
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
 *	e2.c
 *
 *	Expression tree routines.
 *
 *	Constant folding, typing of nodes, simple transformations.
 */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include <tos.h>
#include "common/dict.h"
#include "common/hierarch.h"
#include "common/pdb.h"

#include "param.h"
#include "pre.h"
#include "body.h"
#include "decl.h"
#include "d2.h"
#include "expr.h"
#include "e2.h"
#include "gen.h"
#include "gsub.h"
#include "md.h"
#include "out.h"

#define debug_x G.yflags['x'-'a']
#define debug_s G.yflags['s'-'a']
#define debugQ  G.xflags['q'-'a']
#define debugC (G.xflags['c'-'a'])		/* casting */
#define debugM  G.xflags['m'-'a']

#define ICONRIGHT 1			/* icons to the left give better code (moveq #n,Dn) */
#define FUNFOLD2 0			/* uncorrect yet */
#define is_icon(tok)	((tok) eq ICON)

static
void gen_expr(NP np, short context)
{
	untype(np);
	branch_tree(np);
	genx(np, context);
}

static
void impl_deref(NP np, TP tp)
{
	NP cp = copyone(np);
	np->token = DEREF;
	np->tt = E_UNARY;
	clr_flgs(np);
	cp->left = np->left;

/* 11'09 HR: forgot about the right part */

	cp->right = np->right;
	np->right = nil;

	np->left = cp;
	np->type = tp;
	to_nct(np);
	name_to_str(np, "impl_deref");
}

/* new function name seen in expr */
static
TP new_func(NP op)
{
	short context = 0;
	TP np;
	D_(_x, "new_func");
	/* we know left, right and type are nil */
	np = e_copyone_t(op);
	np->type = basic_type(T_PROC, 30);
	to_nct(np);
	np->sc = K_EXTERN;
	globl_sym(np, context);
	np->nflgs.f.nheap = op->nflgs.f.nheap;		/* symtab must own the name */
	op->nflgs.f.nheap = 0;

	return np;
}

static
void see_func(NP np)	/* restricted version of see_id() */
{
	TP tp = all_syms((TP)np, 0);
	if (tp eq nil)
	{
#if FOR_A
		errorn(np, "undefined function");
#else
		warnn(np, "no prototype for");
#endif
		tp = new_func(np);
	}
	if (tp->sc eq K_REG)
		np->rno = tp->rno;
	/* we need these for the implicit deref */
	np->vreg = tp->vreg;
	np->sc = tp->sc;
	np->val.i = tp->offset;
	np->lbl = tp->lbl;
	clr_flgs(np);
	np->cflgs.f.undef   = tp->cflgs.f.undef;
	np->cflgs.f.see_reg = tp->cflgs.f.see_reg;
	np->cflgs.f.cdec    = tp->cflgs.f.cdec;
	np->cflgs.f.inl_v   = tp->cflgs.f.inl_v;	/* 12'13 v5 */
	np->type = tp->type;
	to_nct(np);
	if (np->cflgs.f.inl_v)
		np->val.i = tp->offset;
}

/* 04'14 v5.1 */
static
TP deref_func(NP lp)	/* lp is  callee expression */
/* Perform a single implicit dereference if applicable */
{
	TP typ = lp->type;

	if (    typ->token ne T_PROC
#if FOR_A
		and typ->token ne L_PROC
#endif
	   )		/* still not a func ?? */
	{
		TP ttp = typ;
		typ = nil;
		if (ttp->token eq REFTO)
		{
			ttp = ttp->type;
			if (   ttp->token eq T_PROC
#if FOR_A
				or ttp->token eq L_PROC
#endif
			   )
			{
				impl_deref(lp, ttp);
				typ = ttp->type;	/* return type */
			}
		}
	}
	else
		typ = typ->type;			/* The return type */

	return typ;
}

global
NP make_bin(short tok, Cstr name, NP lp, NP rp)
{
	NP xp;

	if (lp and rp)
	{
		xp = make_node(tok, E_BIN, 0, name);
		if (xp)
		{
			xp->left = lp;
			xp->right = rp;
		}

		binary_types(xp, FORSIDE, 0);
	}

	return xp;
}

/* (type yielding func) (args) */
static
void callee_type(NP np, short context)
{
	NP lp = np->left;

	D_(_x, "callee_type");
#if FOR_A
	if (lp->token ne STMT)
#endif
		if (lp->token eq ID)
			see_func(lp);		/* may be new ID; */
		else
			form_types(lp, context, 0);
}

static
void function_type(NP np, short context)
{
	TP typ = deref_func(np->left);		/* Do a single deref if applicable */

	if (typ)
	{
		if (typ->token eq REFTO)
			np->rno = AREG;
#if FLOAT
		elif (is_hw_fp(typ->ty))		/* was np ????? */
			np->rno = FREG;
#endif
	othw
		error("call non-function");
#if FOR_A
		typ = basic_type(G.lang eq 'a' ? T_VOID : T_INT, 31);
#else
		typ = basic_type(T_INT, 31);
#endif
	}

	np->type = typ;
	to_nct(np);
}

static
void toomany(NP np)
{
	errorn(np, "too many parameters");
}

static
void toofew(NP np)
{
	errorn(np, "too few parameters");
}

/* 3'11 HR promote by casts (simplify onearg()) */
static
void promote(NP arg)
{
	NP  np = arg->left;
	TP  tp = np->type,
	   itp = default_type(-1, 0);
#if FLOAT
	TP ftp = basic_type(T_REAL, 32);
#endif

	switch (tp->ty)
	{
		case ET_U:
		case ET_S:			/* promote int to default int size */
			if (tp->size < itp->size)
			{
				Cast(np, itp, ARGCNV, "Promote int");
				arg->type = np->type;
				to_nct(arg);
			}
		break;
#if FLOAT
		case ET_R:			/* promote real to default real size */
			if (tp->size < ftp->size)
			{
				Cast(np, ftp, ARGCNV, "Promote float");
				arg->type = np->type;
				to_nct(arg);
			}
		break;
#endif
	}
}

static
void promote_args(NP np)
{
	while (np)
	{
		promote (np);
		np = np->right;
	}
}

static
void match_args(NP np)	/* and insert argcasts  */
{
	TP tl, tls; NP args;
	short i, j;
#if FOR_A
	bool loc = np->left->type->token eq L_PROC;
#endif
	D_(_x, "match_args");

	tl = np->left->type;

	if ( tl->list eq nil and np->right eq nil ) return;		/* 11'09 HR check before ANSI args */

	if (!tl->tflgs.f.ans_args)
	{
		warnn(np->left, "No args matching for");
		promote_args(np->right);
		return;
	}

	tl = tl->list;					/* list is ID or REFTO */
	args = np->right;				/* right is arg expr */

	if ( tl eq nil )
	{
		toomany(np);
		return;
	}

	/* tl now !nil */

	if ( args eq nil )
	{
		if ( yields_ty(tl, T_VARGL) eq nil )
			toofew(np);
		return;
	}

	/* both tl and args now !nil */

	tls = tl;
	j = 0;
	while(tls)
	{
		if (yields_ty(tls, T_VARGL)) break;
		j++;
		tls = tls->next;
	}
	/* no of args in typelist excl vargl */

	i = 1;								/* already excluded 0 args */
	if ( args->token eq ARG )
		i = args->val.i;					/* no of args in CALL */

	if (i<j)
	{
		toofew(np);
		return;
	}

	if ( i>j and !tls )					/* T_VARGL leaves tls!nil */
	{
		toomany(np);
		return;
	}

	while (args)
	{
		args->rno = -1;
#if FOR_A
		if (arg_check(args, tl, loc) eq 0)		/* false: found  T_VARGL */
#else
		if (arg_check(args, tl) eq 0)		/* false: found  T_VARGL */
#endif
		{
			args->eflgs.f.varg = 1;
			promote_args(args);
			return;
		}
		args->type = args->left->type;
		tl = tl->next;
		args = args->right;
	}
}

/* np points to ID or DEREF or SELECT node
	type is a COPY
	type token is ROW  */

static
void see_array(NP np)
{
	NP tp;

#if BIP_ASM
	if (G.lang eq 's')
		return;
#endif
	tp = copyone(np);
	tp->left = np->left;
	np->size = tp->type->size;		/* keep total size */
	tp->type = tp->type->type;		/*	hier verdwijnt Arr of, maar staat nog in np
									    dus houdt zijn not_a_copy flag ?*/
	np->left = tp;
	np->token = TAKE;
	np->tt = E_UNARY;
	name_to_str(np, "array_to_pointer");
	array_to_pointer((TP)np);			/* Array of --> Arref to */
#if FOR_A
	if (G.lang eq 'a')
	{
		np->type->name = np->left->name;	/* new 'for' syntax: must have name of terminal array */
		np->type->nflgs.f.nheap = 0;
	}
#endif
}
/*
static
void keep_qual(void * vtp, void  *vnp)
{
	TP tp = vtp, np = vnp;
	if (tp and np)
	{
		tp->cflgs.f.qc |= np->cflgs.f.qc;
		tp->cflgs.f.qv |= np->cflgs.f.qv;
	}
}
*/
/* (struct|union).ID */
static
void member_type(NP xp)
{
	NP rp, lp; TP sup, rv;

	rp = xp->right;
	lp = xp->left;
	sup = lp->type;

/* already checked that rp->token is ID */

	if ( !is_aggreg(sup) )
	{
		errorn(lp, "select non-%s/%s", graphic[K_STRUCT], graphic[K_UNION]);
		rv = default_type(-1, 0);
	othw
		rv = tlook(sup->list, (TP)rp);
		if (rv eq nil)
		{
			errorn(rp, "not member of '%s'", sup->name);
			rv = default_type(-1, 0);
		othw
			xp->val.i = rv->offset;
			if (rv->fld.width)
				xp->fld = rv->fld;
			xp->name = rv->name;		/* remember selection's name */
			xp->nflgs.f.nheap = 0;
/*			keep_qual(xp, lp);
*/			rv = rv->type;
		}
	}

	xp->type = rv;
	to_nct(xp);

	/* change to UNARY op */
	xp->tt = E_UNARY;
	freenode(rp);
	xp->right = nil;

	/* change ROW OF to REF TO */
	if (rv->token eq ROW)
		see_array(xp);
}

/* used for CASE value, row index decl, enum value,
   size of bitfields & #if truth value	*/
global
long confold_value(NP np, short context)
{
	long l;

	D_(_x, "confold_value");

	if (np)
	{
		form_types(np, context, 0);	/* confold now in form_types */

		if (is_con(np->token))			/* 11'13 HR is_con */
		{
			l = np->val.i;
			freenode(np);
			return l;
		}
	}

	error("needs constant expression");
	return 0;
}

#if BIP_ASM

/* similar to get_arglist, but calls questx() */

/* used in assembler: The association of ( in eg d(a0) is different from a call */
global
NP asm_expr(void)
{
	NP np, ind, e1;

	D_(_x, "asm_expr");

	np = questx();		/* xpr without commas */

	if (np)
	{
		if ( (np->cat1 & S_KW) eq 0)
		{
			if (np->token eq DEREF)		/* 05'11 HR: unary '*' --> Instruction Counter */
				np->token = INSTR;
			elif (cur->token eq PAREN)		/* followed by (...) */
			{
				ind = npcur(); advnode();
				e1 = get_expr();
				eat(NERAP);
				if (e1)
				{
					ind->token = REGINDISP;
					ind->tt = E_SPEC;
					ind->left = np;
					ind->right = e1;
					np = ind;
				othw
					error("empty ()");
					freenode(np);
					freenode(ind);
					return nil;
				}
			othw
			/* if questx() yields a COMMA expr, the expression must
			   have been held between parentheses;
			   questx() --> primary() :: '(' --> get_expr()
			*/
				if (np->token eq COMMA)		/* (... , ...) */
				{
					np->token = REGINDX;
					np->tt = E_SPEC;
				}
			}
		}
	}

	form_types(np, FORSIDE, 0);	/* includes confold */

	return np;
}
#endif

static
void newicon(NP np, long x)
{
	D_(_x, "newicon");

	np->token = ICON;
	np->val.i = x;
	new_name(np, "%ld", x);
	np->tt = E_LEAF;
	if (np->left)
	{
		freenode(np->left);
		np->left = nil;
	}
	if (np->right)
	{
		freenode(np->right);
		np->right = nil;
	}
}

#if FLOAT
static
void makefcon(NP np, double x, short r_or_f)
{
	if (r_or_f eq RCON)
		new_rnode(np, x);
	else
		np->val.f = x;

	np->token = r_or_f;
	new_name(np, "%g", x);
	np->tt = E_LEAF;
	if (np->left)
	{
		freenode(np->left);
		np->left = nil;
	}
	if (np->right)
	{
		freenode(np->right);
		np->right = nil;
	}
}

global
void newfcon(NP np, float x)
{
	D_(_x, "newfcon");
	makefcon(np, x, FCON);
}

global
void newrcon(NP np, double x)
{
	D_(_x, "newrcon");
	makefcon(np, x, RCON);
}

#endif

static
void insptrto(NP np)
{
	D_(_x, "insptrto");
	{
		NP op = copyone(np);

		np->left = op;
		np->token = TAKE;
		np->tt = E_UNARY;
		name_to_str(np, "&Proc");
	}

/* position in flow of see_id changed
   must now complete types */
	{
		TP op = basic_type(REFTO, 33);		/* construct TAKE's type */
		name_to_str(op, "func pointer to");
		op->type = np->type;		/* func */
		to_nct(op);
		op->tflgs.f.saw_proc = 1;		/* 01'12 HR: for &proc */
		np->type = op;				/* ref to func */
		not_nct(np);
	}
}

#if BIP_ASM
static
TP asm_symbol(NP np)
{
	TP tp;

	tp = make_type(ID, -1, np->name, nil);
	tp->type = asm_type();
	to_nct(tp);
	tp->nflgs.f.nheap = np->nflgs.f.nheap;
	tp->nflgs.f.dot   = np->nflgs.f.dot;
	np->nflgs.f.nheap = 0;				/* symtab owns name */
	tp->sc   = K_AHEAD;
	tp->area_info.id = (tp->nflgs.f.dot and G.scope) ? area_id : 0;	/* 2'11 HR */

	tp->area_info.class = in_class;

	np->area_info = tp->area_info;
	np->sc = tp->sc;				/* 11'10 HR */

	if (tp->nflgs.f.dot)
		np->lbl = dot_sym(tp);
	elif (G.scope)
		loc_sym(tp, 0);
	else
		globl_sym(tp, 0);

	return tp;
}
#endif

static TP undef_ID(NP np)
{
	TP tp = make_type(ID, -1, np->name, nil);	/* symbol table entry */

	if (tp)
	{
		tp->cflgs.f.undef = 1;			/* to avoid a lot of identical err msgs */
		np->cflgs.f.undef = 1;
		tp->type   = default_type(-1, 0);
		to_nct(tp);
		tp->offset = 0;

		tp->nflgs.f.nheap = np->nflgs.f.nheap;
		np->nflgs.f.nheap = 0;				/* symtab owns name */

		if (G.scope)
			loc_sym(tp, 0);
		else
			globl_sym(tp, 0);
	}

	return tp;
}

#if FOR_A
static
bool B_flags(NP np)
{
	return   np->aflgs.f.ns
	      or np->aflgs.f.np
	      or np->aflgs.f.nf;
}

static
short post_type(NP np)
{
	if (np->aflgs.f.ns)
		return T_STRING;
	if (np->aflgs.f.np)
		return T_INT;
#if FLOAT
	if (np->aflgs.f.nf)
		return T_REAL;
#endif
	return T_INT;
}

static
TP impl_decl(NP np)
{
	TP tp = make_type(ID, -1, np->name, nil);	/* symbol table entry */

	if (tp)
	{
		void std_area_start(TP, short);
		short was_class = in_class;
		tp->type = basic_type(post_type(np), 2000);
		to_nct(tp);
		tp->nflgs.f.nheap = np->nflgs.f.nheap;
		np->nflgs.f.nheap = 0;				/* symtab owns name */
		np->sc = K_GLOBAL;
		new_gp(nil, IMPL);
		np->type = tp->type;
		to_nct(np);
		permanent_var(4, (TP)np, GBSS_class);
		globl_sym(tp, 0);
		new_class((TP)np, was_class);
	}

	return tp;
}
#endif

static
TP undef_symbol(NP np)
{
#if FOR_A
	if (G.lang eq 'a' and B_flags(np))
	{
		messagen(0, 0, np, "undefined");
		return impl_decl(np);
	}
	else
#endif
	{
#if C_DEBUG
		warnn
#else
		errorn
#endif
			(np, "[1]undefined");
		return undef_ID(np);
	}
}

static
void see_id(NP np, short context, short usage)
{
	TP tp;
#if BIP_ASM
	void asm_offs(NP, TP);
#endif

	D_(_x, "see_id");
	if (usage ne FORLVAL)
		usage = FORSEE;

#if BIP_ASM
	if (G.lang eq 's' and G.equs)
	{
		XP et = tlook(G.equs, np);
		if (et) if (et->xpr)
		{							/* 04'12 HR: equ expression: Replace leaf by expression */
									/*			Note: the expr is already typed. */
			TP tp = et->xpr->type;
			NP new = copynode(et->xpr);
			copyinto(np, new);
			np->type = tp;
			to_nct(np);
			freeunit(new);
			return;
		}
	}
#endif

#if BIP_ASM
	if (G.dot_seen)
	{
		G.dot_seen = false;
		np->nflgs.f.dot = 1;
	}

	if (np->nflgs.f.dot)
		tp = tlook(G.dot_labels, (TP)np);
	else
#endif
		tp = all_syms((TP)np, usage);

	if (tp eq nil)
	{
		if (context eq FORTRUTH)		/*for #if expressions */
		{
			np->token = ICON;
			np->val.i = 0;				/* constant representing falsehood */
			np->type = default_type(-1, 0);
			to_nct(np);
			return;
		}
#if BIP_ASM
		/* if asm, make symbol table entry for advance reference (K_AHEAD) */
		if (G.lang eq 's')
		{
			tp = asm_symbol(np);
			asm_offs(np, tp);		/* convert offset ID and K_AUTO to ICON */
		}
		else
#endif
			tp = undef_symbol(np);
	othw
#if USAGE
		if (context eq FORLVAL)			/* 12'08 HR usage tracking */
			tp->tflgs.f.inid = 1;
#endif
		if (tp->token eq ICON)
			np->token = ICON;			/* t.off is same location as e.val.i */
		elif (tp->sc eq K_REG)
			np->rno = tp->rno;

		np->vreg = tp->vreg;
		np->sc    = tp->sc;
		np->val.i = tp->offset;
		np->area_info = tp->area_info;
		np->lbl   = tp->lbl;
		take_flgs(np, tp);

#if BIP_ASM
		if (G.lang eq 's')
			asm_offs(np, tp);		/* convert offset ID and K_AUTO to ICON */
#endif
	}

	np->type = tp->type;
	to_nct(np);
	tp = np->type;

	/* special conversions */
	if (   tp->token eq T_PROC
#if FOR_A
		or tp->token eq L_PROC
#endif
	   )		/* local procedure */
	{
		if (tp->cflgs.f.sysc)			/* 01'12 HR */
			errorn(np, "Cant take address of a %s", graphic[K_SYSC]);
		insptrto(np);
	}

#if FOR_A
	if (G.lang eq 'a')
		if (tp->aflgs.f.deref)
			impl_deref(np, tp->type);
#endif
}

static
TP xcon_ty(NP lp)
{
	if (lp->token eq ICON)	return basic_type(icon_ty(lp), 34);
#if FLOAT
	if (lp->token eq RCON)	return basic_type(T_REAL, 35);
	if (lp->token eq FCON)	return basic_type(T_FLOAT, 36);
#endif
#if LL
	if (lp->token eq LCON)	return basic_type(T_LLONG, 37);
#endif
	return nil;
}

/* UNARY */

static
void ucanon(NP np)	/* somewhat more straightforward */
{
	if (np->token eq K_SIZEOF)
	{
/*  I needed the true pointer size(4) in the Arr_of type node.
	so I put the total size if a array in the TAKE expression node
*/
		newicon(np, (np->left->type->tflgs.f.saw_array)
					? np->left->      size
					: np->left->type->size
				);
		np->type = basic_type(SIZE_T, 38);
		to_nct(np);
		return;
	}

	if (np->token eq TOFFSET)	/* should be part of unary_types like TSIZEOF */
	{
		TP mp;
		mp = tlook(np->type->list, np->left);
		if (mp)
		{
			newicon(np, mp->offset);
			np->type = basic_type(SIZE_T, 40);
			to_nct(np);
		}
		else
			errorn(np->type, "offsetof: '%s' not member of ", np->left->name);
		return;
	}

#if FLOAT
	if (np->left->token eq FCON)
	{
		float new = np->left->val.f;
		switch (np->token)
		{
		case NEGATE:
			new = - new;
		case UPLUS:
			np->type = np->left->type;
			to_nct(np);
			newfcon(np, new);
		}

		return;
	}
	elif (np->left->token eq RCON)
	{
		double new = getrcon(np->left);
		switch (np->token)
		{
		case NEGATE:
			new = -new;
		case UPLUS:
			np->type = np->left->type;
			to_nct(np);
			newrcon(np, new);
		}

		return;
	}
#endif

/* Here LCON folding */
	if (np->left->token eq ICON)
	{
		switch (np->token)
		{
		case UPLUS:
			np->type = np->left->type;
			to_nct(np);
			newicon(np, np->left->val.i);
		break;
		case NEGATE:
			np->type = np->left->type;
			to_nct(np);
			newicon(np, -np->left->val.i);
		break;
		case BINNOT:
			np->type = np->left->type;
			to_nct(np);
			newicon(np, ~np->left->val.i);
		break;
		case NOT:
			np->type = np->left->type;
			to_nct(np);
#if 0 /* BIP_ASM */
			if (G.lang eq 's' and !G.in_if_x)
				newicon(np, ~np->left->val.i);
			else
#endif
				newicon(np, !np->left->val.i);
		break;
		}
	}
}

/* switch pseudo-commutative op */
static
void swt_op(NP np)
{
	short newtok;

	D_(_x, "swt_op");

/* shame, shame on me!!! botched up reversion */
	switch (np->token)
	{
	case LTEQ:		newtok = GTEQ;		break;
	case GTEQ:		newtok = LTEQ;		break;
	case LESS:		newtok = GREATER;	break;
	case GREATER:	newtok = LESS;		break;
	default:
		return;
	}
	np->token = newtok;
	name_to_str(np, graphic[newtok]);
}

bool stronger(TP xp, TP  yp);		/* ex MD.C */

/* BINARY 2 ICON's */
static
void b2i(NP np)
{
	long l, r, x;
	D_(_x, "b2i");

	r = np->right->val.i;
	l = np->left->val.i;

	switch (np->token)
	{
	case PLUS:
			x = l + r;	break;
	case MINUS:
			x = l - r;	break;
	case TIMES:
			x = l * r;	break;
	case DIV:
			x = l / r;	break;
	case MOD:
			x = l % r;	break;
	case GREATER:
			x = l > r;	break;
	case LESS:
			x = l < r;	break;
	case LTEQ:
			x = l <= r;	break;		/* 03'09 oooops ( was >= ) */
	case GTEQ:
			x = l >= r;	break;		/* 03'09 oooops ( was <= ) */
	case EQUALS:
			x = l eq r;	break;
	case NOTEQ:
			x = l ne r;	break;
	case BINAND:
			x = l & r;	break;
	case BINOR:
			x = l | r;	break;
	case BINEOR:
			x = l ^ r;	break;
	case SHL:
			x = l << r;	break;
	case SHR:
			x = l >> r;	break;
	default:
		return;
	}

	np->eflgs.i = np->left->eflgs.i > np->right->eflgs.i
					? np->left->eflgs.i
					: np->right->eflgs.i;
	if (!(np->eflgs.f.see_u or np->eflgs.f.see_l))
		np->val.i = x,
		np->type = basic_type(icon_ty(np), 41);
	else
		np->type = stronger(np->left->type, np->right->type)
				? np->left->type
				: np->right->type;
	to_nct(np);

	newicon(np, x);
}


#if FLOAT
/* BINARY 2 RCON's */
static
void b2f(NP np, double l, double r)
{
	double x;
	short ix, isint;

	D_(_x, "b2f");

	isint = 0;

	switch (np->token)
	{
	case PLUS:
			x = l + r;	break;
	case MINUS:
			x = l - r;	break;
	case TIMES:
			x = l * r;	break;
	case DIV:
			x = l / r;	break;
	case GREATER:
			ix = l > r;  isint++;	break;
	case LESS:
			ix = l < r;  isint++;	break;
	case LTEQ:
			ix = l <= r; isint++;	break;	/* 03'09 oooops ( was >= ) */
	case GTEQ:
			ix = l >= r; isint++;	break;	/* 03'09 oooops ( was <= ) */
	case EQUALS:
			ix = l eq r; isint++;	break;
	case NOTEQ:
			ix = l ne r; isint++;	break;
	default:
		return;
	}

	to_nct(np);

	if (isint)
	{
		newicon(np, ix);
		np->type = basic_type(T_BOOL, 42);	/* ty ET_B */
	othw
		newrcon(np, x);		/* intermediate arithm allways double */
		np->type = basic_type(T_REAL, 43);
	}
}
#endif

/* 10'10 HR: Now only called for X_THEN */
static
void xcanon(NP np)
{
	long l = np->left->val.i;
	NP onp, tp;

	D_(_x, "xcanon");

	tp = np->right;				/* X_ELSE node */

	if (l)
	{							/* take true side */
		onp = tp->left;
		freenode(tp->right);
	othw						/* take false side */
		onp = tp->right;
		freenode(tp->left);
	}

	freenode(np->left);
	freeunit(np->right);
	copyinto(np, onp);
	onp->nflgs.f.nheap = 0;
	freeunit(onp);
}

static
void collaps(NP np, long truth)
{
	np->token = ICON;
	np->val.i = truth;
	np->tt = E_LEAF;
	freenode(np->left);
	np->left = nil;
	freenode(np->right);
	np->right = nil;
}

static
void pull_right(NP np)
{
	NP onp = np->right;
	freenode(np->left);			/* icon */
	copyinto(np, onp);
	onp->nflgs.f.nheap = 0;
	freeunit(onp);
}

static
void pull_left(NP np)
{
	NP onp = np->left;
	freenode(np->right);		/* icon */
	copyinto(np, onp);
	onp->nflgs.f.nheap = 0;
	freeunit(onp);
}

/* 10'10 HR: AND, OR */
static
void ycanon(NP np)
{
	short lt = np->left ->token eq ICON,
	      rt = np->right->token eq ICON,
	      tok = np->token;
	long l = np->left ->val.i,
	     r = np->right->val.i;

	if (lt and rt)
		if (tok eq AND)
			collaps(np, l and r);
		else
			collaps(np, l or  r);
	elif (lt)
		if (tok eq AND and l eq 0)	/* false for sure */
			collaps(np, 0);
		elif (tok eq OR and l ne 0)	/* true for sure  */
			collaps(np, 1);
		else
			pull_right(np);			/* dont bother about icon */
	elif (rt)
		if (tok eq AND and r eq 0)	/* false for sure */
			collaps(np, 0);
		elif (tok eq OR and r ne 0)	/* true for sure  */
			collaps(np, 1);
		else
			pull_left(np);			/* dont bother about icon */
}

/* confold integrated in form_types:
	its easier when you have the types already determined. */
static
void bcanon(NP np)
{
	short ltok, rtok;
	NP tp;

	ltok = np->left->token;
	rtok = np->right->token;

#if ICONRIGHT
												/* previous */
	if (!is_icon(ltok) and is_icon(rtok) and np->token eq MINUS)
	{
		np->token = PLUS;					/* X - con --> X + -con (This sure helps :-) */
		np->right->val.i = -np->right->val.i;
	}

	if (is_con(ltok) and !is_con(rtok))		/* left is ?CON, right is not */
	{
		if (is_C_A_NA(np->token))
		{						/* reverse sides  - put CON on right */
			tp = np->left;
			np->left = np->right;
			np->right = tp;
			if (is_C_NA(np->token))
				swt_op(np);
		}
		return;
	}
#else
	/* opposite of previous: put CON on left !!!!! (more asm optimizations possible (moveq #,Dn)) */
	/* MINUS --> PLUS For better performance (more often) of b_assoc (now left_assoc & right_assoc) */

	if (is_icon(ltok) and !is_icon(rtok) and np->token eq MINUS)
	{
		np->token = PLUS;					/* con - X --> -con + X (This sure helps :-) */
		np->left->val.i = -np->left->val.i;
	}

	if (is_con(rtok) and !is_con(ltok))
	{
								/* right is ?CON, left is not */
		if (is_C_A_NA(np->token))
		{						/* reverse sides  - put CON on left */
			tp = np->right;
			np->right = np->left;
			np->left = tp;
			if (is_C_NA(np->token))
				swt_op(np);
		}
		return;
	}
#endif

	if (is_icon(ltok) and is_icon(rtok))		/* both int */
	{
#if BIP_ASM
		if (np->left->area_info.id ne np->right->area_info.id)
		{
			send_msg("%d %d\n", np->left->area_info.id, np->right->area_info.id);
			error("undefined address arithmatic between different areas");
			return;
		}
#endif
		b2i(np);
		return;
	}

#if FLOAT
	if (is_con(rtok) and is_con(ltok))	/* mixed int, short or long real */
	{
		double l, r;

		if (ltok eq RCON)
			l = getrcon(np->left);		/* intermediate real arithmatic allways extended precision */
		elif (ltok eq FCON)
			l = np->left->val.f;
		else
			l = np->left->val.i;

		if (rtok eq RCON)
			r = getrcon(np->right);		/* idem */
		elif (rtok eq FCON)
			r = np->right->val.f;
		else
			r = np->right->val.i;

		b2f(np, l, r);
	}
#endif
}

/* canon for assoc. & comm. op */
/* Johann: this code will almost never be executed, but it was fun. */
/* OK, but it wasnt perfect ;-)
		See changes in bcanon, especially reversion of MINUS --> PLUS for constants
		Now it is done quite a lot more often.

		I made a left and right version of b_assoc to make the process
		independant of the position of the constants. Whether put left or right.
 */

static
bool right_assoc(NP np)
{
	NP lp, rp;
	short tok;

	D_(_x, "right_assoc");

	lp = np->left;
	if (lp->token ne np->token)
		return false;
									/* left is same op as np */
	rp = np->right;
	tok = lp->right->token;
	if (!is_con(tok))
		return false;
	/* left.right is ?CON */
	tok = rp->token;
	if (is_con(tok))
	{
					/* have 2 CONS l.r and r -- put together on r */
		NP	ep;
		ep = lp->left;
		np->left = ep;
		np->right = lp;
		lp->left = rp;
					/* can now fold 2 CONS */
		/*	warn("right_assoc together right %ld %ld\n", lp->left->type->size, lp->right->type->size); */
		bcanon(lp);
	othw
					/* have 1 CON at l.r -- move to top right */
		NP	kp;
		kp = lp->right;
		lp->right = rp;
		np->right = kp;
		/*	warn("right_assoc top right\n"); */
		castdefault(lp->left, lp->right, lp->type);
	}

	return true;
}

static
bool left_assoc(NP np)
{
	NP rp, lp;
	short tok;

	D_(_x, "left_assoc");

	rp = np->right;
	if (rp->token ne np->token)
		return false;
									/* right is same op as np */
	lp = np->left;
	tok = rp->left->token;
	if (!is_con(tok))
		return false;
	/* right.left is ?CON */
	tok = lp->token;
	if (is_con(tok))
	{
					/* have 2 CONS r.l and r -- put together on l */
		NP	ep;
		ep = rp->right;
		np->right = ep;
		np->left = rp;
		rp->right = lp;
					/* can now fold 2 CONS */
		bcanon(rp);
	othw
					/* have 1 CON at r.l -- move to top left */
		NP	kp;
		kp = rp->left;
		rp->left = lp;
		np->left = kp;
		castdefault(rp->left, rp->right, rp->type);
	}

	return true;
}

static
bool is_useless(NP np, long val)
{
	NP rp = np->right, lp = np->left;
	if (is_icon(rp->token) and rp->val.i eq val)
	{
		freenode(rp);
		copyinto(np, lp);
		lp->nflgs.f.nheap = 0;
		freeunit(lp);
		return TRUE;
	}
	return FALSE;
}

static
short save_scon(NP np)		/* for the sake of size moved to here from gen.c */
{
	NP tp;

	D_(_x, "save_Scon");

	tp = copyone(np);
	tp->nflgs.f.nheap = np->nflgs.f.nheap;		/* reverses default copyone action. */
	np->nflgs.f.nheap = 0;
	tp->lbl = new_lbl();
	tp->nflgs.f.brk_l = 1;
#if NODESTATS
		G.ncnt[tp->nt]--;
		G.ncnt[GENODE]++;
#endif
	tp->nt = GENODE;
	addcode(tp, "L1:\nXZ");
	putn_fifo(&G.strsave, &G.strlast, tp);
	set_class(np, STR_class);
	np->area_info.disp = std_areas->ar[np->area_info.class].size;
	std_areas->ar[np->area_info.class].size += tp->size + 1;

	return tp->lbl;
}

/* lcanon integrated in leaf_types, confold integrated in form_types */
global
TYPE_FUN leaf_types
{
	switch (np->token)
	{
	case ID:
		see_id(np, context, usage);
		if (np->type->token eq ROW)
			if (context ne FORLAINIT)		/* ANSI: init local arrays */
				see_array(np);				/* change to &ID; insert UNARY & node */
		return;
	case SCON:
#if BIP_ASM
		if (G.lang ne 's')
#endif
			np->lbl = save_scon(np);
		np->type = basic_type(SCON, 44);
	break;
	case MEMBER:
		np->type = default_type(-1, 0);
		np->token = ID;
	break;
	case TSIZEOF:
		newicon(np, np->type->size);
		if (is_ct(np))		/* 12'14 pffffff! v5.2 */
			freeTn(np->type);
		np->type = basic_type(SIZE_T, 45);
	break;
	case K_TRUE:
		newicon(np, 1);
		np->type = basic_type(T_BOOL, 46);
	break;
	case K_FALSE:
		newicon(np, 0);
		np->type = basic_type(T_BOOL, 47);
	break;
	case T_VOID:
		newicon(np, 0);
		np->type = basic_type(T_VOID, 48);
	break;
#if FOR_A
	case K_NIL:							/* (void *)0L */
		newicon(np, 0);
		np->type = basic_type(T_ULONG, 49);
	break;
#endif
	case K_NOP:					/* 03'09 */
	case K_REST:
	case K_SAVE:
		np->type = basic_type(T_VOID, 50);
	break;
	case K_SR:					/* 12'11 HR */
		np->type = basic_type(T_USHORT, 51);
	break;
	case K_CR:					/* 12'11 HR */
		np->type = basic_type(T_USHORT, 52);
	break;
#if FLOAT
	case FPCR:					/* 12'11 HR */
	case FPSR:
		np->type = basic_type(T_ULONG, 53);
	break;
#endif
#if FOR_A
	case STMT:
		return;		/* type already established */
#endif
	case K_VOID:	/* 05'13 HR: v5: do nothing? */
		np->type = basic_type(T_VOID, 54);
		return;
	default:		/* must be ?CON */
#if BIP_ASM
		if (np->cat1 & S_KW)
			np->type = basic_type(T_SHORT, 55);
		else
#endif
		if ((np->type = xcon_ty(np)) eq nil)
		{
#if C_DEBUG
			CE_NX(np, "Weird leaf %s", ptok(np->token));
#else
			CE_NX(np, "Weird leaf: %d", np->token);
#endif
			np->type = default_type(-1, 0);
		}
	}
	to_nct(np);
}

static
void unary_types(NP np)
{
	NP lp; TP tp;

	ucanon(np);			/* confold integrated in form_types */
						/* its easier when the types are already determined */

	if (np->tt ne E_UNARY)		/* probably done something */
		return;

	if (external_unary_op(np))		/* s/w dbl: now we know the type for */
		return;						/*	external defined unary operators */

	lp = np->left;
	tp = lp->type;				/* default */
#if FLOAT
	if (np->cflgs.f.rlop)		/* fpu monops */
	{
		mustty(lp, R_ARITH);
		tp = basic_type(T_REAL, 56);
	}
	else
#endif
	switch (np->token)
	{
		case TOFFSET:
		break;
	case POSTINCR:
		mustlval(lp);
		mustty(lp, R_SCALAR);
		if (postincdec(np, tp, ASSIGN PLUS, INCR, MINUS))	/* X++ becomes (++X - 1) */
			return;
		break;
	case POSTDECR:
		mustlval(lp);
		mustty(lp, R_SCALAR);
		if (postincdec(np, tp, ASSIGN MINUS, DECR, PLUS))
			return;
		break;
	case INCR:
		mustlval(lp);
		mustty(lp, R_SCALAR);
		if (incdec(np, tp, ASSIGN PLUS))			/* ++X becomes X+=1 */
			return;
		break;
	case DECR:
		mustlval(lp);
		mustty(lp, R_SCALAR);
		if (incdec(np, tp, ASSIGN MINUS))
			return;
		break;
	case DEREF:
		if (mustty(lp, R_POINTER))
		{
			tp = default_type(-1, 0);			/* error */
			break;
		}

		tp = tp->type;
		np->type = tp;
		to_nct(np);
		/* ROW OF to REF TO */
		if (tp->token eq ROW)
			see_array(np);
		return;
	case TAKE:
		if (lp->token eq TAKE)
		{
			if (lp->type->tflgs.f.saw_array)
			{
				/* change back to array_of */
				TP ltp = lp->type;
				NP keep = lp->left;
				np->left = keep;
				keep->type = ltp;
				not_nct(keep);
				ltp->token = ROW;
				ltp->size = lp->size;
				ltp->ty = ET_A;
				name_to_str(ltp, "array_of");
				ltp->tflgs.f.saw_array = 0;
				freeunit(lp);
				lp = keep;
			}
			elif (lp->type->tflgs.f.saw_proc)		/* 01'12 HR */
			{
				lp->type->tflgs.f.saw_proc = 0;
				np->left = lp->left;
				freeTunit(lp->type);
				freeunit(lp);
				lp = np->left;
			}
		}
		mustlval(lp);
		if (lp->cflgs.f.see_reg)		/* actually specified 'register' */
			errorn(lp, "%s reg_var", graphic[ADDRESS]);
		if (G.v_Cverbosity > 2 and (lp->sc eq K_AUTO or lp->sc eq K_REG) and lp->cflgs.f.is_arg)
			messagen(0, 0, lp, "&arg");

		tp = basic_type(REFTO, 57);
		tp->type = lp->type;
		to_nct(tp);
/*		keep_qual(tp, lp);
*/		np->type = tp;
		return;
#if BIP_ASM
	case INSTR:				/* 05'11 HR: '*' operand */
		if (lp->token ne ICON)
		{
			errorn(lp, "+/- integer constant required");
			np->val.i = 0;
		}
		else
			np->val.i = lp->val.i;
		np->tt = E_LEAF;
		np->left = nil;
		freenode(lp);
		np->type = basic_type(T_LONG, 58);
		to_nct(np);
		return;
#endif
	case NEGATE:
#if BIP_ASM
		if (G.lang eq 's' and lp->token eq REGINDIRECT)
		{
			*np = *lp;
			freeunit(lp);
			np->token = MINUSREGIND;
			return;
		}
#endif
		mustty(lp, R_ARITH);
#if COLDFIRE
		if (G.Coldfire)
		{
			cast_up(lp, basic_type(np->ty eq ET_S ? T_LONG : T_ULONG, 59), "Cast neg");
			tp = lp->type;
		}
		else
#endif
		if (is_CC(lp))			/* 06'11 HR */
			cast_up(lp, basic_type(np->ty eq ET_S ? T_INT : T_UINT, 60), "cast_cc unary minus");
		break;
	case UPLUS:
		mustty(lp, R_ARITH);
		if (is_CC(lp))			/* 06'11 HR */
			cast_up(lp, basic_type(np->ty eq ET_S ? T_INT : T_UINT, 61), "cast_cc unary plus");
		break;
	case IMPCNV:
	case EXPCNV:
	case ARGCNV:
		if (np->type->token ne T_VOID)
		{
			mustty(lp, R_CC|R_SCALAR);
			mustty(np, R_CC|R_SCALAR);
		}

		if ( is_con(lp->token) and cast_con(lp, np->type, "E2_cast", 999))	/* 09'15 v5.3 */
		{
			TP ntp = np->type;
			if (is_ct(lp))
				freeTn(lp->type);
			*np = *lp;
			np->type = ntp;
			to_nct(np);
			return;
		}
		if (!G.nmerrors and G.casttab)
			external_cast(np);
		return;				/* type already specified */
	case NOT:				/* always yields a true boolean */
		mustty(lp, R_CC|R_SCALAR);
		if (!is_CC(lp))
			cmp_zero(lp);
		np->type = CC_type(np->left, nil);
		not_nct(np);
		return;
	case BINNOT:
		mustty(lp, R_INTEGRAL);
#if COLDFIRE
		if (G.Coldfire)
			tp = basic_type(T_ULONG, 62);
#endif
		break;
	case BSWP:			/* 03'09 byte swap */
		mustty(lp, R_INTEGRAL);
		tp = basic_type(widen(lp->type->token), 63);
		cast_up(lp, tp, "Cast bswap");
		break;
	case DELAY:			/* 05'13 v4.15 small delay loop */
		mustty(lp, R_INTEGRAL);
		tp = basic_type(widen(lp->type->token), 64);
		cast_up(lp, tp, "Cast delay");
		break;
	case HALT:			/* 03'09 stop */
		mustty(lp, R_INTEGRAL);
		if (lp->token ne ICON)
			error("stop needs integer constant");
		tp = basic_type(T_VOID, 65);
		break;
	case SETSR:			/* 03'09 move to   SR */
		tp = basic_type(T_VOID, 66);
		/* fall thru */
	case GETSR:			/* 03.09 move from SR */
		mustty(lp, R_INTEGRAL);
		break;
	case GETSETSR:		/* 03'09 move from & move to SR */
		mustty(lp, R_INTEGRAL);
		tp = basic_type(T_SHORT, 67);
		break;
#if BIP_ASM
	case REGINDIRECT:		/* 11'09 HR forgot these */
	case REGINDPLUS:
	break;
#endif
	default:
		CE_X("unknown unary operator '%s'", np->name);
		tp = default_type(-1, 0);
	}

	np->type = tp;
	to_nct(np);
}

static
bool must_soft(NP np, TP tp, short op)
{
	if (G.nmerrors)
		return false;

#if FLOAT
	if (tp->ty ne ET_R)
#endif
	{
		if (    tp->size eq SIZE_L
#if FLOAT || COLDFIRE
		    and !(G.i2_68020 or G.Coldfire)
#endif
		   )
		{
			np->type = tp;
			to_nct(np);

			/* extracodes: now we know left & right types for external defined binary operators */

			if (op eq (np->token&TOKMASK))	/* if not transformed */
			{
				bool bex = external_binary_op(np);
				if (!bex)
					error("long '%s' and no function defined for it in 'ahcc_rt.h'", graphic[op]);
			}
			return true;
		}
	}

	return false;
}

#if COLDFIRE
global
void cold_con(NP np, TP tp)
{
	if (G.Coldfire and tp->size eq SIZE_L)
	{
		NP lp = np->left, rp = np->right;
		if (is_icon(lp->token) and lp->token eq np->token)	/* both icons (confold) */
			return;
		if (is_icon(lp->token))
			lp->token = COLDCON;		/* to be saved in l_eval */
		if (is_con(rp->token))
			rp->token = COLDCON;
	}
}
#endif

static
bool can_shift(NP rp, TP tp, TP ltp)
{
	if (    is_icon(rp->token)
#if FLOAT
		and tp->ty ne ET_R
#endif
#if COLDFIRE
		and !(G.Coldfire and ltp->size < DOT_L)		/* 09'10 HR: must check left size */
#endif
		and make2pow(&rp->val.i)
	   )
		return true;

	return false;
}

static
void can_moveq(NP np)
{
	NP rp = np->right,
	   lp = np->left;

	if (rp->token eq ICON)
		/* simple and small optimization (use moveq when possible) */
		if (    is_C_A(np->token)
		    and is_signed_byte(rp->val.i)	/* moveq is sign extending!! */
		   )
		{
			np->left = rp;
			np->right = lp;
		}
}

/* 10'13 HR: v5 */
/* return true if a expresion has side effects */
static
short side_effects(NP np)
{
	if (np->cflgs.f.s_ef)				return true;
	switch (np->tt)
	{
	case E_SPEC:
	case E_BIN:
		if (np->token eq CALL)			return true;
		if (side_effects(np->left))		return true;
		if (side_effects(np->right))	return true;
		if (is_assignment(np->token))	return true;
		return false;
	case E_UNARY:
		if (side_effects(np->left))		return true;
		switch (np->token)
		{
			case POSTINCR:
			case POSTDECR:
			case INCR:
			case DECR:
										return true;
		}
		return false;
	case E_LEAF:
		if (np->cflgs.f.leaf)			return true;
	}
	return false;
}

global
TYPE_FUN binary_types
{
	TP tp, ltp, rtp;
	NP lp, rp;
	bool pow2;
	short op = np->token&TOKMASK;
	bool assignop = is_ass_op(np->token);

	if (op ne X_ELSE)		/* confold integrated */
	{
		if (assignop)
			mustlval(np->left);

/* 10'10 HR xcanon only correct for X_THEN
			symmetric function ycanon for 2 icon's
			other combinations were already handled correctly.
*/

		if (op eq X_THEN and np->left->token eq ICON)
		{
			xcanon(np);
			return;			/* 10'11 HR: must return */
		}

		if (    (op eq AND or op eq OR)
			  and (   np->left ->token eq ICON
		           or np->right->token eq ICON
		          )
		     )
		{
			ycanon(np);
			return;
		}

		bcanon(np);
		if (is_C_A(np->token))
		#if ICONRIGHT
			if (!right_assoc(np))	/* 2 versions of old b_assoc (for right and left operator chains) */
				left_assoc(np);
		#else
			if (!left_assoc(np))
				right_assoc(np);
		#endif

		if (np->tt ne E_BIN)	/* must have done something */
			return;
	}

	lp = np->left;
	rp = np->right;
	ltp = lp->type;
	rtp = rp->type;

	if (lp->cflgs.f.undef)		/* reducing err msgs */
		lp->type = rtp;
	if (rp->cflgs.f.undef)
		rp->type = ltp;

	tp = default_type(-1, 0);

	switch (op)
	{
	case TIMES:
#if BIP_ASM
		if (G.lang eq 's' and is_asreg(lp) ne 0)
		{
			np->token = ASMSCALE;
			tp = lp->type;
			break;
		}

		/* else fall thru */
#endif
	case DIV:
		if (must2ty(np, R_ARITH)) break;
		tp = normalty(np, 0);
		if (is_useless(np, 1))
			return;				/* removes ICON so no bcanon needed */

/* If target is ST, conversion to shift must be done before soft long mul/div */

		pow2 = can_shift(rp, tp, ltp);	/* 09'10 HR must check ltp for Coldfire !!! */
		if (pow2)
		{								/* make2pow doesnt change off if false */
			np->token &= (ASSIGN 0);
			np->token |= op eq TIMES ? SHL : SHR;

			if (!assignop)
				castdefault(lp, rp, tp);
			else
			{
				castasmagic(lp, rp);
				tp = hardasmagic(np, ltp, 0);
			}
		}
		else

		{
			tp = basic_type(widen(tp->token), 68);		/* widen alleen voor mul,div,mod */
			if (!assignop)
				castdefault(lp, rp, tp);
			if (assignop)
			{
				tp = ltp;
				castasop(lp, rp);
				tp = hardas(np, tp);
			}

			if (must_soft(np, tp, op))
				return;

#if COLDFIRE
			cold_con(np, tp);
#endif

		}

		break;
	case MOD:
		if (must2ty(np, R_ARITH)) break;
		tp = normalty(np, 0);
		if (is_useless(np, 1))
			return;				/* removes ICON so no bcanon needed */

		if (					/* 4'17 HR: v5.6 */
#if LL || COLDFIRE
		        rp->size <= DOT_L
		    and
#endif
		        !assignop
		    and is_icon(rp->token)
		    and is2pow(rp->val.i)
		   )
		{
/*			message(0, 0, "mod to and for %lx", rp->val.i);
*/			np->token = BINAND;
			rp->val.i -= 1;
			break;
		}

		tp = basic_type(widen(tp->token), 69);		/* widen alleen voor mul,div,mod */
		if (!assignop)
			castdefault(lp, rp, tp);
		if (assignop)
		{
			tp = ltp;
			castasop(lp, rp);
			tp = hardas(np, tp);
		}

		if (must_soft(np, tp, op))
			return;

#if COLDFIRE
		cold_con(np, tp);
#endif
		break;
	case AND:
	case OR:			/* recursive call of  binary_types :: no more fall thru */
#if FOR_A
		if (    G.lang eq 'a'
		    and !is_CC(lp) and ltp->token eq T_BOOL
		    and !is_CC(rp) and rtp->token eq T_BOOL)
		{
			np->token = np->token eq AND ? BINAND : BINOR;
			/* both boolean variables: fall through to BIN op's !!This is a concession.
			   In fact you must abolish && and || from the language,
			   and always use & and | for both boolean and binary operation */
			binary_types(np, FORSIDE, usage);	/* process the changed and/or */
			return;
		}
#endif
		mustty(lp, R_CC|R_SCALAR);
		mustty(rp, R_CC|R_SCALAR);
		if (!is_CC(lp))			/* only if types are different */
			cmp_zero(lp);
		if (!is_CC(rp))			/*   "     */
			cmp_zero(rp);
		np->type = CC_type(np->left, np->right);		/* makes special type ET_?C */
		not_nct(np);
		external_binary_op(np);
		return;
	case BINAND:
	case BINOR:
	case BINEOR:
		if (must2ty(np, R_BIN)) break;
		if (op ne BINAND and is_useless(np, 0))
			return;
		tp = bitsty(np, G.Coldfire);

		if (!assignop)
			castdefault(lp, rp, tp);
		else
		{
			castasmagic(lp, rp);
			tp = hardasmagic(np, ltp, G.Coldfire);
		}
		break;
	case MINUS:
#if BIP_ASM					/* difference between ID's in same area */
		if (	G.lang eq 's'
			and lp->token eq ID and rp->token eq ID
		    /* and lp->area_info.id eq rp->area_info.id */
		   )
		{
			if (!(lp->sc eq K_AHEAD or rp->sc eq K_AHEAD) )
			{
				if (lp->area_info.id ne rp->area_info.id)
					error("labels must be in same area");
				else
				{
					np->token = ICON;
					np->val.i = lp->area_info.disp - rp->area_info.disp;
					np->tt = E_LEAF;
					freenode(lp);
					freenode(rp);
					np->left = nil;
					np->right = nil;
				}
			}
			tp = basic_type(T_LONG, 70);
			break;
		}
		/* else fall thru */
#endif
	case INDEX:
	case PLUS:
		if (must2ty(np, R_SCALAR)) break;
		if (is_useless(np, 0))
			return;
		if (ltp->token eq REFTO or rtp->token eq REFTO)
		{
			if (op eq PLUS)
				np->token = (np->token & ~TOKMASK) | INDEX;	/* ptr + i */

			tp = scalety(np);	/* may change lp &| rp (former addty() */
			lp = np->left;
			rp = np->right;
		othw
			tp = normalty(np, G.Coldfire);
		}

		if (assignop)
		{
			castasmagic(lp, rp);
			tp = hardasmagic(np, ltp, G.Coldfire);
		}
		elif (!(ltp->token eq REFTO or rtp->token eq REFTO))
			castdefault(lp, rp, tp);
	/*	else
		    casts already done in scalety */

/*		if (op eq INDEX)
			keep_qual(np, tp);
*/
		break;
	case SHL:		/* shift count(right) is used module 64 so can be any integral type */
	case SHR:
	case ROL:
	case ROR:
		if (must2ty(np, R_INTEGRAL)) break;
		if (is_useless(np, 0))
			return;
#if 0
		if (lp->token eq ICON and ltp->size eq DOT_B)	/* 1 << n */
			ltp = basic_type(widen(ltp->token), 71);		/* most compilers do this */

/* ANSI: the type of the shiftcount does not influence the type of the result.
   A problem with shift on 68000 is that
    lsl #n,Dy		shift count is 3 bits	treated as unsigned (with a special treatment for 0)
	lsl Dx,Dy		shift count is 6 bits 	Dx modulo 64 	The manual is not clear about a sign
		So the best for the right part is do nothing, because even casting from byte to int doesnt
		do any good;
	In that case 'a<<-3' or 'a<<325' must be considered unpredictable
*/
#endif

/* cast. (for practical reasons (and compatability with Pure C.) ) */
		tp = shiftty(np, G.Coldfire);

		if (!assignop)					/* 03'02 HR */
			castdefault(lp, rp, tp);
		else							/* 03'02 HR */
		{
			castasmagic(lp, rp);
			tp = hardasmagic(np, ltp, G.Coldfire);
		}
		break;
	case LESS:
	case GREATER:
	case LTEQ:
	case GTEQ:
		if (must2ty(np, R_SCALAR)) break;
		chkcmp(np);
		if (is_zero(rp))
			ins_zero(rp);
		else
			cast_compare(np, lp, rp);

		np->type = CC_type(np->left, np->right);
		not_nct(np);
		external_binary_op(np);
		return;
	case EQUALS:
	case NOTEQ:
		if (must2ty(np, R_CC|R_SCALAR)) break;
		chkcmp(np);
		if (is_zero(rp))
			ins_zero(rp);
		else
			cast_compare(np, lp, rp);
		np->type = CC_type(np->left, nil);
		not_nct(np);
		external_binary_op(np);
		return;
	case X_THEN:
		mustty(lp, AC_BOOL);
		tp = rp->type;
		if (!is_CC(lp))
			cmp_zero(lp);
		break;
	case X_ELSE:
	{
		if (!side_effects(lp))				/* 11'13 HR v5 */
			if (mustty(lp, R_CC|R_ASSN)) break;
		if (!side_effects(rp))				/* 11'13 HR v5 */
			if (mustty(rp, R_CC|R_ASSN)) break;
		tp = colonty(np);
		if (!is_aggreg(tp))
			castdefault(lp, rp, tp);
		break;
	}
#if WITH_F
	case FIELDAS:		/* 2'17 HR: v5.6 */
#endif
	case ASS:
		if (   mustlval(lp)
			or mustty  (lp, R_ASSN) ) break;		/* use R_STRUCT for arrays */
		asn_check (ltp, rp, context);

		tp = ltp;
		castasn(lp, rp);
		fieldas(np, lp);
		break;
	case COMMA:
#if BIP_ASM
	if (G.lang ne 's')
#endif
		if (rp->token ne ARG)
			Cast(rp, rtp, EXPCNV, "Cast !arg");			/* 01'12 HR: must always cast */
	case PULL:		/* pull argregs from the stack */
	case ARG:		/* does arrive here only if G.h_cdecl_calling (else CE ) */
	case ARGP:
	case FUNF:
		tp = rtp;
		break;
	default:
		CE_X("unknown binary operator '%s'", np->name);
	}

	np->type = tp;
	to_nct(np);

#if 0
	#if BIP_ASM
		if (G.lang ne 's')
	#endif
			if (!is_ass_op(np->token) and np->token ne TIMES)
				can_moveq(np);
#endif

	if (assignop or is_ass(np->token) )		/* 2'17 HR: v5.6 */
		const_check(np, context);

	external_binary_op(np);
}

global
void call_types(NP np, short context)	/* args in list */
{
	NP rp = np->right;

	D_(_x, "call_types");

	if (rp)				 /* voor args */
	{
		while (rp)
		{
			form_types(rp->left, context, 0);
			rp->type = rp->left->type;
			to_nct(rp);
			rp = rp->right;
		}
		np->tt = E_BIN;
	}
	else
		np->tt = E_UNARY;
}

#if BIP_ASM
static
void asmsize_type(NP np)		/* only called for operands */
{
	TP tp;
	NP lp = np->left, rp = np->right;

D_(_x, "asmsize_type");

	tp = lp->type;

	if (rp->token eq ID)
	{
		short c = tolower(*rp->name);

		if (    *(rp->name + 1) eq 0
			and (c eq 'w' or c eq 'l')
		   )
		{
			*np = *lp;
			freenode(rp);
			freenode(lp);
			np->type = tp;
			to_nct(np);
			if (c eq 'w')
				np->eflgs.f.asm_w = 1;
			elif (c eq 'l')
				np->eflgs.f.asm_l = 1;
			return;
		}
	}

	error("asm size syntax error");
	np->type = tp;
	to_nct(np);
}
#endif

global
TYPE_FUN form_types
{
	if (np eq nil) return;

	if (context eq FORLINIT)
		if (np->eflgs.f.ftyp)
			messagen(0, 0, np, "form_types already called");
		else
			np->eflgs.f.ftyp = 1;

	switch (np->tt)
	{
	case E_SPEC:
		switch (np->token)		/* special cases */
		{
#if BIP_ASM
		case ASM_SELECT:
			form_types(np->left, context, usage);
			member_type(np);
			return;
#endif
		case SELECT:
			form_types(np->left, context, usage);
#if BIP_ASM
			if (G.lang eq 's')				/* id.w or id.l */
				asmsize_type(np);
			else
#endif
				member_type(np);
			return;
		case CALL:
		{
			call_types(np, context);
			callee_type(np, context);
			function_type(np, context);
			match_args(np);			/* also do argassigns if proc is local */
			arg_regs(np);

#if FU_TREE
			if (    G.ah_project_help
			    and G.af_func_tree
			    and np->left->token eq ID
			   )	/* and call by name */
				pdb_depend(&fun_dependencies, G.prtab->name, np->left->name);
#endif
			return;
		}
	}
/*	case E_SPEC fall through (be sure they are in fact binary) */
	case E_BIN:
/*		if (is_ass(np->token) )
			form_types(np->left, context, FORLVAL);	/* 12'08 HR usage tracking */
		else
*/
		form_types(np->left,  context, usage);
		form_types(np->right, context, usage);
		binary_types(np,      context, usage);
		break;

	case E_UNARY:
/*		if (usage eq FORLVAL and context eq FORLINIT)			/* 12'08 HR usage tracking */
			form_types(np->left,  context, 0);
		else
*/
		form_types(np->left,  context, usage);
		unary_types(np);
		break;

	case E_LEAF:
		leaf_types(np, context, usage);
		break;
	}
}

static
bool is_voidened(NP np)
{
	if (    np->token eq EXPCNV
	    and np->type->size eq 0)
		return true;
	return false;
}

/* general expression */
global
void do_expr(NP np, short context)
{
	G.prtab->tmps = 0;
/*	'and !G.nmerrors' if want only one error per expression	*/
	if (np and !G.nmerrors)
	{

		if (    context eq FORSIDE
		    and np->token ne X_ELSE
		    and !side_effects(np)	/* 10'13 HR: v5 */
		    and !is_voidened(np)
		   )
			warn("code has no effect");

		form_types(np, context, 0);

		if (!G.nmerrors)
			gen_expr(np, context);
	}
}

/* expression returning struct or union */
static
void str_expr(NP np, TP typ)
{
	bool reason;
	G.prtab->tmps = 0;
	if (np and !G.nmerrors)
	{
		form_types(np, RETSTRU, 0);
		reason = similar_type(0,1,np->type, typ, 0, 0);
		if (!G.nmerrors and reason)
		{
#if C_DEBUG
			error("%s bad return %s reason %d", sss(np->name), ptok(np->type->token));
#else
			error("bad %s return", graphic[np->type->token]);
#endif
		}
		if (!G.nmerrors)
			gen_expr(np, RETSTRU);
	}
}

static
short ret_context(TP typ)
{
#if FLOAT
	if (   (    !G.use_FPU
	        and typ->token eq T_REAL
	       )
	    or typ->ty eq ET_A
	   )
		return RETSTRU;
	else
#endif
	if (    typ->token eq REFTO
/*		and typ->cflgs.f.cdec eq 0		/* 09'10 HR */
*/	   )
		return INA0;
	else
		return IND0;		/* implies INF0 */
}

global
void ret_expr(NP np, TP typ)
{
	if (is_aggreg(typ))
	{
		D_(_x, "ret_stru");
		str_expr(np, typ);
	othw
		short context = ret_context(typ);
		Cast(np, typ, IMPCNV, "Ret_cast");
		do_expr(np, context);
	}
}

global
bool coercable(TP prt, TP tp)
{
	if (    (prt->ty eq ET_S or prt->ty eq ET_U)
		and ( tp->ty eq ET_S or  tp->ty eq ET_U)
		)
		return true;	/* both integral types */

	if (prt->ty eq ET_P and tp->ty eq ET_P)
		if (   (prt->type and prt->type->token eq T_VOID)
			or ( tp->type and  tp->type->token eq T_VOID)
		   )
			return true;

	return !similar_type(0,0,prt, tp, 0, 0);		/* 07'12 v5.1 */
}

#if FOR_A
#include "a_expr.h"
#endif