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
 *	expr.c
 *
 *	Expression parse routines
 *
 *	All routines return either nil or a valid tree
 *		binop nodes have non-null left and right
 *		unop nodes have non-null left
 *
 *	Special nodes:
 *		PAREN cq CALL	: function call.  left: name-expr; right: args
 *		ARG 	: comma in function arg list, e.val.i is num. descendants
 *						if unary: last arg
 *		X_THEN: ? switch.  left: test-expr; right: X_ELSE part
 *		X_ELSE	: left: true-expr; right: false-expr
 *		...CNV	: left: convertee; tptr:  type-list
 *				IMPCNV:  implicit
 *				EXPCNV:  explicit (cast)
 *				ARGCNV:  implicit for pushing
 *		TSIZEOF	: type: type-list
 *		TOFFSET : type: lookup member in typelist for offset
 *
 */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "common/mallocs.h"
#include "common/amem.h"

#include "param.h"
#include "pre.h"
#include "body.h"
#include "decl.h"
#include "d2.h"
#include "expr.h"

#define debugX G.xflags['x'-'a']
#define debug_x G.yflags['x'-'a']

#define is_prim(tok)	((tok) eq BLOCK or (tok) eq K_IF or (tok) eq K_CASE)

global
char exprs[] = "expression syntax";
global
NP get_arglist(void);


#if M_TO_F			/* 02'17 HR: v5.6 */
global
bool is_ass_op(short t)
{
	return t >= ASSIGN 0;
}

global
bool is_ass(short t)
{
	return   t eq ASS
#if WITH_F
	      or t eq FIELDAS
#endif
	 ;
}

global bool is_assignment(short t)
{
	return is_ass_op(t) or is_ass(t);
}
#endif

global
bool is_con(short tok)
{
	switch (tok)
	{
	case ICON:
#if FLOAT
	case FCON:
	case RCON:
#endif
#if LL
	case LCON:
#endif
		return true;
	}
	return false;
}

global
void clr_flgs(NP np)
{
	np->eflgs.i = 0;
	np->cflgs.i = 0;
}

global
void take_flgs(NP np, TP tp)
{
	np->eflgs.i = tp->tflgs.i;
	np->cflgs.i = tp->cflgs.i;
}

global
void fuse_scon(NP lp, NP rp)
{
	long l = lp->size + rp->size;
	Wstr catted;
	lp->nflgs.f.lcat |= rp->nflgs.f.lcat;		/* inherit flag for subseq catanations */
	lp->left = rp->left;
	catted = CC_xmalloc(l+1, AH_FUSE_SCON, CC_ranout);
	if (catted)
	{
		long j = 0,i = 0;
		while (i < lp->size) catted[i] = lp->name[i], i++;
		while (i < l)        catted[i] = rp->name[j], i++, j++;
		catted[l] = 0;
		free_name(lp);
		freeunit(rp);
		lp->size = l;
		lp->name = catted;
		lp->nflgs.f.nheap = 1;
	}
}

global
void concatstr(NP concat)	/* concatenate adjacent strings */
{
	while (cur->token eq SCON)
	{
		fuse_scon(concat, npcur());
		advnode();
	}
}

static
NP opt_follow(NP np)
{
	NP tp, e1, t2;

#if BIP_ASM
	if (    G.lang eq 's'
	    and cur->token ne SELECT
	    and cur->token ne ASM_SELECT
	   )
		return np;
#endif

	D_(X, "opt_follow");

#if FOR_A
	if (G.lang eq 'a')
		B_follow((TP)np);
#endif

	switch (cur->token)
	{
	case ARRAY:
		tp = npcur(); advnode();
		e1 = get_expr();

		if (cur->token ne YARRA)
		{
			errorn(cur, "[4]expect '%s'; got", graphic[YARRA]);
			return np;
		othw
			t2 = npcur(); advnode();
		}

		if (e1 eq nil)
		{
			errorn(np, "empty %s%s", graphic[ARRAY], graphic[YARRA]);
			return np;
		}

		t2->left = np;
		t2->right = e1;
		t2->tt = E_BIN;
		t2->token =  INDEX;		/* this is the action; ARRAY is the type. */
		name_to_str(t2, "add_index");

		tp->left = t2;
		tp->tt = E_UNARY;
		tp->token = DEREF;
		name_to_str(tp, "deref");
		break;
	case PAREN:
								/* call: cur=PAREN; np=name expr */
		tp = npcur(); advnode();
		tp->token = CALL;
		name_to_str(tp, "call");
		e1 = get_arglist();
		tp->left = np;
		tp->right = e1;
		tp->tt = E_SPEC;
		eat(NERAP);
		break;
#if BIP_ASM
	case ASM_SELECT:
#endif
	case SELECT:
	case ARROW:
		tp = npcur(); advnode();
		if (cur->token ne ID)
		{
			errorn(cur, "[5]expect ID; got");
			return np;
		}
		tp->left = np;
		tp->right = npcur(); advnode();
		tp->tt = E_SPEC;

		if (tp->token eq ARROW)
		{ 								/* make into (*X).Y */
			tp->token = SELECT;
			name_to_str(tp, "member");

			t2 = make_node(DEREF, E_UNARY, 0, "deref");
			t2->left = np;
			tp->left = t2;
		}

		break;
	case INCR:
	case DECR:
		tp = npcur(); advnode();
		tp->token = (tp->token eq INCR) ? POSTINCR : POSTDECR;
		tp->left = np;
		tp->tt = E_UNARY;
		break;
	default:
		return np;
	}

	return opt_follow(tp);
}

#if BIP_ASM
static
NP asm_indirect(NP np)
{
	NP ind = get_expr();
	eat(NERAP);
	if (ind)
	{
		np->token = REGINDIRECT;

		if (    ind->tt eq E_LEAF
		    and ind->token >= K_A0
		    and ind->token <= K_A7
		   )
		{
			if (cur->token eq PLUS)
			{
				fadvnode();
				np->token = REGINDPLUS;
			}
		}

		if (ind->token eq COMMA)		/* (Bn,Xn) */
		{
			NP ic;
			np->token = REGINDISP;
			np->tt = E_SPEC;
			ic = allocnode(EXNODE);
			ic->token = ICON;
			np->left = ic;
			np->right = ind;
		othw
			np->tt = E_UNARY;
			np->left = ind;
		}
	}

	return np;
}

static
NP asm_memindirect(NP np)
{
	NP ind = get_expr();
	eat(YARRA);
	if (ind)
	{
		np->tt = E_UNARY;
		np->token = REGINDIM;
		np->left = ind;
	}
	return np;
}
#endif

static
TP see_asmvar(XP np)
{
	TP tp = all_syms((TP)np, 0);

	if (tp)
		if (	 tp->token           ne ID			/* make sure no infinite recursion occurs */
		    and (tp->cat1 & S_KW) ne 0		/* 07'13 v4.15 () ne 0 */
		   )
			return tp;

	return nil;
}

static
NP primary(void)
{
	NP e1;
#if BIP_ASM
	TP vp;
#endif
	short tok = cur->token;

	D_(X, "primary");

#if BIP_ASM
	if (    G.lang eq 's' 		/* 05'11 HR repair equ */
	    and tok eq ID
	    and (vp = see_asmvar(cur)) ne nil
	   )
	{
		cur->token = vp->token;
		cur->cat0 = vp->cat0;
		cur->cat1 = vp->cat1;
		cur->name = vp->name;
		cur->nflgs.f.nheap = 0;
		return primary();
	}
#endif

	if (   tok eq ID
	    or is_con(tok)
#if BIP_ASM
	    or (cur->cat1 & S_KW) ne 0
#endif
	   )
	{
		e1 = npcur(); advnode();
		e1->tt = E_LEAF;
		return opt_follow(e1);
	}

#if BIP_ASM
	if (G.lang eq 's' and tok eq SELECT)		/* unary use of dot in assembler names */
	{
		fadvnode();
		if (cur->token eq ID)
		{
			e1 = npcur(), advnode();
			e1->tt = E_LEAF;
			e1->nflgs.f.dot = 1;
			return opt_follow(e1);
		}
	}
#endif

	if (cur->cflgs.f.leaf)
	{
		e1 = npcur(), advnode();
		e1->tt = E_LEAF;
		return e1;
	}

	if (tok eq SCON)
	{
		e1 = npcur(), advnode();
		e1->tt = E_LEAF;
		concatstr(e1);				/* concatenate adjacent strings */
		return opt_follow(e1);
	}

#if BIP_ASM
	if (G.lang eq 's' and tok eq ARRAY)
	{
		e1 = npcur(), advnode();
		return asm_memindirect(e1);
	}
#endif

	if (tok eq PAREN)
	{
		e1 = npcur(); advnode();
#if BIP_ASM
		if (G.lang eq 's' and is_asreg(cur) ne 0)
			return asm_indirect(e1);
		else
#endif
		{
			freenode(e1);			/* ( */
			e1 = get_expr();
			eat(NERAP);
			if (e1)
				return opt_follow(e1);
		}
	}
#if FOR_A
	elif (G.lang eq 'a' and is_prim(tok))
	{
		TP xp, tp;
		long xln = G.lineno;

		tp = allocTn(1);
		tp->token = T_PROC;
		tp->tflgs.f.ans_args = 1;

		xp = allocTn(1);
		xp->token = STMT;
		xp->name = cur->name;
		xp->type = tp;

		loc_proc(xp, STMT);		/* puts aposteriori type in xp->type->type */
		if (!G.nmerrors)
		{
			tp = xp->type->type;
			if (    tp eq nil
				or (tp ne nil and tp->token eq T_VOID)
				)
			{
				long svln = G.lineno;
				G.lineno = xln;
				error("primary statememt must yield a value");
				G.lineno = svln;
				freeTn(xp);
				if (tp)
					freeTn(tp);
				return nil;
			}
		}
		e1 = make_node(CALL, E_SPEC, 0, "primary block");
		e1->left = t_to_e(xp);

		return opt_follow(e1);
	}
#endif

	return nil;
}

/*
 * called if is_ty_start();		there is allways a head!
 */
static
NP make_cast(char *nm)
{
	short noclass = -1;
	TP head, xp;
	NP np;
	bool declty;

	head = Declarer(false, nil, &noclass, &declty);
	/* we know head is not nil */
	xp = Declare(head, CAST);
	if (ok_cast(xp, head) eq 0)
		xp = default_type(noclass, 0);
	np = make_node(EXPCNV, E_UNARY, 0, nm);
	d_to_dt((TP)np, xp);
	if (xp ne head)
		type_is_a_copy(np);

	return np;
}

static
NP unary(void)
{
	NP tp, e1;

	short op = cur->token;

	D_(X, "unary");

	if (   is_unop(cur->token)
		or cur->cflgs.f.rlop)
	{
		tp = npcur();  advnode();
		if (tp->prec)						/* also have BINARY op */
			tp->token = OP_X(tp->token);	/* defs: x field of tok_tab */
		tp->left = unary();
		tp->tt = E_UNARY;
	}
	elif (
	         op eq DEFINED
#if FOR_A
	      or op eq DECLARED
#endif
	     )
	{
		if (!G.in_if_X)
		{
			cur->token = ID;
			return primary();
		}
		tp = npcur();  advnode();
		tp->left = unary();
		tp->tt = E_UNARY;
	}
	elif (op eq PAREN)
	{
#if BIP_ASM
		e1 = npcur(); advnode();
		if (G.lang eq 's' and is_asreg(cur) ne 0)
			return asm_indirect(e1);
		else
		{
			freenode(e1);
#else
		{
			fadvnode();
#endif
#if BIP_ASM
			if (G.lang ne 's' and is_ty_start())		/* (char *)expr */
#else
			if (is_ty_start())		/* (char *)expr */
#endif
			{
			    tp = make_cast("cast to");
				eat(NERAP);
				if (tp)
					tp->left = unary();
			othw
				tp = get_expr();		/* if not a cast, do the same as in 'primary' */
				eat(NERAP);
				if (tp)
					return opt_follow(tp);
			}
		}
	}

#if 0	/* 1st: int(expr) :: its impossible to see the difference between a formal
							 procedure declaration and a cast to int when
						     you still allow old style arguments.
		   2nd: if this happens exactly between declaration & execution part
		   it goes wrong.
		*/
	elif (G.lang eq 'a' and is_ty_start())		/* pe: char *(expr) */
	{
		tp = make_cast("cast to");
		if (tp)
		{
			eat(PAREN);
			tp->left = unary();
			eat(NERAP);
		}
	}
#endif
	elif (op eq K_SIZEOF)
	{
		tp = npcur(); advnode();
		if (cur->token eq PAREN)
		{ 							/* may be type expr */
			fadvnode();
			e1 =   is_ty_start()
			     ? make_cast("sizeof")
			     : get_expr();
			eat(NERAP);
		} else
			e1 = unary();

		if (e1 eq nil)
		{
			errorn(cur, "'%s' %s at", graphic[K_SIZEOF], exprs);
			return nil;
		}

		if (e1->token eq EXPCNV)		/* if made cast */
		{
			freeunit(tp);
			e1->token = TSIZEOF;
			name_to_str(e1, "T_sizeof");
			e1->tt = E_LEAF;
			return e1;
		othw
			tp->tt = E_UNARY;
			tp->left = e1;
		}
	}

	elif (op eq K_OFFSET)
	{
		tp = npcur(); advnode();
		e1 = make_cast("offsetof");		/* must be type expr */

		if (e1 eq nil or (e1 and e1->token ne EXPCNV))
		{
			errorn(cur, "'%s' %s at", graphic[K_OFFSET], exprs);
			freeunit(tp);
			return nil;
		}

		freeunit(tp);
		if (!is_aggreg(e1->type))
		{
			errorn(cur, "'%s' needs aggreg at", graphic[K_OFFSET]);
			return nil;
		}
		e1->token = TOFFSET;
		name_to_str(e1, "T_offset");
		tp = e1;
		tp->tt = E_UNARY;
		if (cur->token ne SELECT)
		{
			errorn(cur, "'%s' needs selection at", graphic[K_OFFSET]);
			freenode(e1);
			return nil;
		}
		fadvnode();
		if (cur->token ne ID)
		{
			errorn(cur, "'%s' needs ID at", graphic[K_OFFSET]);
			freenode(e1);
			return nil;
		}
		tp->left = npcur(); advnode();
		tp->left->token = MEMBER;
		tp->left->type = basic_type(SIZE_T, 20);
		to_nct(tp->left);
		return tp;
	}
	elif (op eq K_VARGL)
	/* '...' in expressions is address of position of '...' in the parameter list */
	/* we turn '...' into '& __ELLIPSIS__'		*/
	/* '__ELLIPSIS__' is the name that is given to the '...' in the parameter list */
	{
		e1 = make_node(TAKE, E_UNARY, 0, "&...");
		e1->left = npcur(); advnode();
		e1->left->token = ID;
		new_name(e1->left, "__ELLIPSIS__");
		return e1;
	}
	else
		return primary();

	if (tp)
		if (!tp->left)
		{
			errorn(cur, "'%s' %s at", graphic[op&(TOKMASK)], exprs);
			freenode(tp);
			return nil;
		}

	return tp;
}

/* call this if you want expr w/o assign's or comma's or ?: */
static
NP binary(void)
{
	NP lp, op, up;

	D_(X, "binary");

	lp = unary();
	if (lp)
	{
		lp->prec = 0;

		do{			/* while binary op */
#if BIP_ASM
			if (G.asm_if and is_ass(cur->token) )		/* 2'17 HR: v5.6 */
				cur->token = EQUALS, cur->prec = 7;
#endif
			if (cur->prec eq 0)
				break;

			op = npcur();  advnode();
			up = unary();
			if (up eq nil)
			{
				errorn(cur, "'%s' %s at", graphic[op->token&(TOKMASK)], exprs);
				break;
			}

			up->prec = 0;

			{						/* was buildbin */
				NP look = lp, tail = nil;

				while (op->prec < look->prec)
					tail = look,
					look = look->right;

				if (look eq lp)
					lp = op;
				else
					tail->right = op;

				op->left = look;
				op->right = up;
				op->tt = E_BIN;
			}
		}od
	}

	return lp;
}

/* call this if you want expr w/o assign's or comma's */
/* i.e. constant-expression */
global
NP questx()
{
	NP holdq, holdc,
	   qpart, tpart, fpart;

	D_(X, "questx");

	qpart = binary();
	if (qpart eq nil)
		return nil;
	if (cur->token ne X_THEN)
		return qpart;
	holdq = npcur();  advnode();
	tpart = questx();
	if (tpart eq nil or cur->token ne X_ELSE)
	{
		errorn(cur, "'%s' %s at", graphic[X_THEN], exprs);
		holdq = qpart;
	othw
		holdc = npcur();  advnode();
		fpart = questx();
		if (fpart eq nil)
		{
			errorn(cur, "'%s' %s at", graphic[X_ELSE], exprs);
			holdq = qpart;
		othw
			holdc->left  = tpart;
			holdc->right = fpart;
			holdc->tt    = E_BIN;
			holdq->left  = qpart;
			holdq->right = holdc;
			holdq->tt    = E_BIN;
		}
	}
	return holdq;
}

/* call this if you want expr w/o comma's */
global
NP assignx(void)
{
	NP op, lpart, rpart;

	D_(X, "assignx");

	lpart = questx();
	if (lpart eq nil)
		return nil;
	if (!is_assignment(cur->token))
		return lpart;
	op = npcur();  advnode();
	rpart = assignx();
	if (rpart eq nil)
	{
		errorn(cur, "'%s' %s at", graphic[ASS], exprs);
		return lpart;
	}
	op->left = lpart;
	op->right = rpart;
	op->tt = E_BIN;
	return op;
}

global
NP get_expr(void)
{
	NP op, lpart, rpart;

	D_(X, "get_expr");

	if ( (lpart = assignx()) ne nil /* and !G.lang eq 'a' */)
	{
		while (cur->token eq COMMA)
		{
			op = npcur(); advnode();
			if ( (rpart = assignx()) eq nil)
			{
				errorn(cur, "'%s' %s at", graphic[COMMA], exprs);
				break;
			}

			op->left = lpart;
			op->right = rpart;
			op->tt = E_BIN;
			lpart = op;
		}
	}
	return lpart;
}

/* changed this function in such a way that the args are
   put in a list, NOT in a tree.
   The list is build through ARG tokens, 1 for each arg.
   The last ARG is a unary.

   The argument list in a function declaration is really
   a special kind of structure, hence the actual parameter
   list in a call is really a structure initialization.
   (structure display in Algol68 terms)

   The comma's are no ordinary binary operators but
   list separators.
*/
global
NP get_arglist(void)
{
	NP rv, comma, lpart, rpart;
	long i = 0;

	D_(X, "get_arglist");

	if ( (lpart = assignx()) eq nil)		/* 0 args */
		return nil;

	i = 1;
	rv = comma = allocnode(EXNODE);			/* head of list */
	name_to_str(rv, "arghead");
	do
	{
		comma->token = ARG;
		comma->left = lpart;
		comma->tt = E_UNARY;
		if (cur->token ne COMMA)
			break;

		i++;
		rpart = npcur(); advnode();
		if ( (lpart = assignx()) eq nil)
		{
			errorn(cur, "'%s' %s at", graphic[COMMA], exprs);
			freenode(rpart);
			break;
		}
		comma->right = rpart;
		comma->tt = E_BIN;

		comma = rpart;
	}od

	rv->val.i = i;

	return rv;
}
