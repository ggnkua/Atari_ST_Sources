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
 *	body.c
 *
 *	Handle function entry, exit, etc.
 *	Parse statements.
 *	Also, general syntax error recovery strategy.
 *
 */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>
#include "common/mallocs.h"
#include "common/amem.h"
#include "common/pdb.h"

#include "param.h"
#include "pre.h"
#include "body.h"
#include "decl.h"
#include "d2.h"
#include "expr.h"
#include "e2.h"
#include "gsub.h"
#include "md.h"
#include "out.h"
#include "opt.h"

/* fun.c */

global
NP gp,gpbase;				/* for most code outside expressions */

#define FLOW_SHOW 0			/* diagnostics for flow analysis */
#define OPEN_END 1			/* check for missing returns */

bool C_stmt(VP);
void unit(VP, short);
	/* allthough unit() & C_stmt() are static funcs, they must
		be declared here because of their recursive nature.
	*/

global
TP *symtab;

static
short flno;

#define debugD G.xflags['d'-'a']		/* declarations */
#define debugS G.xflags['s'-'a']		/* statements */
#define debugZ G.xflags['z'-'a']		/* cleanup */

#if FLOW_SHOW
static
void disp_flow_unit(VP np, short d)
{
	short di = d;

	if (np eq nil)
		return;

	console("L%4ld\t", np->fl.ln);

	if (np->FF.root)
		console("%3d <<< ",np->FF.root->F.nr);
	else
		console("        ");

	if (np->FF.base)
		console("%3d <-- ",np->FF.base->F.nr);
	else
		console("        ");

	console("%3d\t",np->F.nr);

	if (di >= 0)
		while(di--) console("   ");
	else
		console("d error\n");

	if (np->name)
		console("%s", np->name);
	else
		console("??");

	if (np->token eq K_CASE)
		console(" %ld:",np->vval);
	if (np->FF.brk > 0)
		console("\tbl=%d",np->FF.brk);
	if (np->FF.cont > 0)
		console("\tcl=%d",np->FF.cont);
	if (np->F.escape)
	{
		short q = np->F.escape;
		console("\t[");
		if (q&RET)
			console("rtn ");
		if (q&RETV)
			console("rtv ");
		if (q&BRK)
			console("brk ");
		if (q&CNT)
			console("cont ");
		if (q&CLO)
			console("closed loop ");
		if (q&WILD)
			console("goto ");
		console("]");
	}

	console("\n");
}


/* This function not only gives a fine listing of the function's flow,
	it is also an excercise in traversing the graph in a correct way;
	that is: if the graph is well formed. */
static
void list_flow(VP np, short d)
{
	if (np)
		if (np->token eq K_CASE)		/* cases are linked by inner */
		{
			while (np)
			{
				disp_flow_unit(np, d);
				list_flow(np->next, d+1);

				np = np->inner;
			}
		}
		else
			while (np)
			{
				disp_flow_unit(np, d);
				list_flow(np->inner,d+1);
				list_flow(np->F.out,d+1);

				np = np->next;
			}
}
#endif

/* Check if there is a return missing. */
bool open_end(VP flow, short d);	/* recursion */

static
bool open_case(VP flow, short d)
{
	while (flow)
	{
		if (flow->F.escape&RETV)	/* the case itself returns */
			return false;

		if ( ! open_end(flow->next, d+1))
			return false;

		if ((flow->F.escape&BRK) eq 0)		/* scan fall thru cases */
			return open_case(flow->inner, d+1);

		flow = flow->inner;			/* cases link via inner */
	}

	return true;
}

static
bool open_end(VP flow, short d)
{
	while (flow)
	{
		if (flow->F.escape&RETV)	/* statement is followed by a return */
			return false;

		switch(flow->token)
		{
			case K_DO:
			case K_WHILE:
			case K_FOR:
				if ( ! open_end(flow->inner, d+1))
					return false;			/* loop is conditional or returns or breaks */
				if (flow->F.escape&CLO)		/* no return needed after closed_loop */
					return false;
			break;

			case K_IF:
				if (    ! open_end(flow->inner, d+1)			/* true choice */
					and ! open_end(flow->F.out, d+1) )			/* false choice */
					return false;			/* both cloices are closed */
			break;

			case K_SWITCH:
				if ( ! open_end(flow->F.out, d+1))			/* closed default closes whole switch */
					return false;
				if ( ! open_case(flow->inner->inner, d+1))	/* handles fall thru & break */
					return false;
			break;
		}

		flow = flow->next;
	}

	return true;		/* something falls thru, so the statement is open */
}

global
void eat(short c)
{
	if (cur->token eq c)
		fadvnode();
	else
		errorn(cur,"[1]expect '%s' -- got", graphic[c]);
}

#if C_DEBUG
bool last_k;

global
void eat_kcolb(void)		/* for debugging, else eat(KCOLB)*/
{
	if (cur->token eq KCOLB)
		last_k = true, fadvnode();
	else
		errorn(cur,"[2]expect '}' -- got");
}
#endif

static
void syntax_error(Cstr addm)
{
	error("syntax on %s at '%s'", addm, cur->name);
	if (cur->token ne EOFTOK) fadvnode();
}

static
NP reg_arg(ALREG *rp, ALREG *ap, TP xp, bool is_cdecl)
{
	NP fp = gx_node();
	short sc = xp->sc;

	xp->lbl = new_lbl();
	xp->cflgs.f.is_arg = 1;

	fp->r2 = -1;
	fp->name = xp->name;	/* prepare fp also for loc_advice() */
	fp->lbl = xp->lbl;
	fp->rno = FRAMEP;
	fp->val.i = xp->offset;
	fp->token = OREG;
	fp->size = xp->type->size;
	fp->ty = xp->type->ty;

	if (sc eq K_REG)
		if (lc_reg(rp, xp, nil))		/* nil = alloc high to low in rno */
		{
			fp->r1 = xp->rno;
		othw							/* out of regs? or n/applicable */
			sc = K_AUTO;
		}

	if (    (!G.h_cdecl_calling and is_cdecl eq 0)		/* argregs */
		and lc_reg(ap, xp, &fp->r2))			/* &... = alloc low to high */
	{											/* put reg args in local name space */
		TP mp = xp;
		long o = G.scope->b_size,
		     s = xp->type->size;

		while (mp)					/* make room in local name space */
		{
			char al = mp->type->aln;		/* keep alignment */
			bool arg = mp->offset - s > ARG_BASE;

			while (al & s)
				s++;

			mp->offset -= s;

			if (s eq 1 and arg)
				mp->offset -= 1;

			mp = mp->next;
		}

		if (sc ne K_REG)			/* allocate regarg */
		{
			o+=s;
			xp->offset = -o;
			G.scope->b_size = o;
			fp->val.i = xp->offset;
			set_vreg(xp);
			loc_advice(xp, fp);							/* 03'12 HR: must emit before sva */
			addcode(fp, "\tsvaS\tR2\tA" C(reg_arg_1) "\n");
		othw
			set_vreg(xp);
			loc_advice(xp, fp);							/* 03'12 HR: must emit before sva */
			addcode(fp, "\tsvaS\tR2\tR1" C(reg_arg_2) "\n");
		}
	}
	elif (sc eq K_REG)
		addcode(fp,"\tldxS\tR1\tA" C(reg_arg_3) "\n");

	xp->sc = sc;
	return fp;
}

static
VP new_unit(VP back, XP xp, short token)
{
	VP new        = allocVn(FLNODE);		/* statement */
	new->fl.ln    = cur->fl.ln;
	G.fltab->next = new;
	new->FF       = G.fltab->FF;		/* inherit flow data */
	new->F.nr     = ++flno;
	new->token    = token;
	name_to_str(new, graphic[token]);
	G.fltab = new;
	return new;
}

static
VP new_in(VP back, Cstr txt, short brk, short cont)
{
	VP new       = allocVn(FLNODE);
	new->F.nr    = ++flno;
	new->token   = K_THEN;
	new->FF      = back->FF;		/* inherit flow data */
	new->FF.base = back;			/* set new base of flow */
	/* will be copied across at each bifurcation */

	new->FF.brk  = brk  < 0 ? back->FF.brk  : brk;
	new->FF.cont = cont < 0 ? back->FF.cont : cont;
	name_to_str(new, txt);
	G.fltab = new;
	return new;
}

static
VP new_out(VP back, Cstr txt)
{
	VP new = allocVn(FLNODE);
	if (new)
	{
		new->F.nr  = ++flno;
		new->token = K_ELSE;
		new->FF    = back->FF;		/* inherit flow data (break & continue) */
		new->FF.base = back;
		name_to_str(new, txt);
		G.fltab = new;
	}
	return new;
}

global
void new_scope(short tok, Cstr nm)
{
	SCP new = CC_xcalloc(1,sizeof(SNODE), AH_SCOPE, CC_ranout);
#if NODESTATS
	G.ncnt[BLNODE]++;
#endif
	G.prtab->level++;
	new->outer = G.scope;
	new->token = tok;
	name_to_str((NP)new, nm);
	G.scope = new;

/* no extra block voor args dus voor level 2 hetzelfde block als level 1 */


	if (G.scope and G.scope->outer)
	{
		/* level :: 0: outside func, 1: args, 2 func body's block,  > 2 statememnts	*/
		if (   G.prtab->level >  2
#if FOR_A
			or tok          eq L_PROC
#endif
		   )
			G.scope->b_regs = G.scope->outer->b_regs,
			G.scope->b_size = G.scope->outer->b_size;

		G.scope->vreg.r = G.scope->outer->vreg.r;
		if (tok ne K_ASM)
			G.scope->vreg.l = G.scope->outer->vreg.l + 1;
	}
	elif (G.scope and tok ne K_ASM)
		G.scope->vreg.l = 1;

	if (tok ne K_ASM)		/* not asm */
	{
		gp->vreg.l = G.scope->vreg.l;
		G.scope->vreg.s = new_lbl();
		gp->vreg.s = G.scope->vreg.s;
	}
}

global
void label(NP np)
{
	VP tp;

	if (np->token ne ID)
	{
		errorn(np, "weird label");
		return;
	}
	tp = tlook(G.prtab->labels, np);
	if (tp)
	{
		freenode(np);
		if (tp->cs.def)
		{
			errorn(np, "duplicate label");
			return;
		}
	othw
		tp = allocVn(LBNODE);
		tp->name = np->name;
		tp->nflgs.f.nheap = np->nflgs.f.nheap;
		np->nflgs.f.nheap = 0;
		freenode(np);
		putv_lifo(&G.prtab->labels, tp);
		tp->cs.lbl = new_lbl();
	}

	tp->cs.def = 1;
#if BIP_ASM
	if (G.lang ne 's')
#endif
		def_lbl(tp->cs.lbl);
}

static
NP need_expr(void)
{
	NP np;

	np = get_expr();
	if (np eq nil)
		error("need expression");

	return np;
}

#if FOR_A
static
short find_do_lbl(short tok, const char **n)
{
	SCP sc; Cstr name;
	if (cur->token eq ID)
	{
		name = cur->name;
		fadvnode();
		sc = G.scope;
		while (sc)
		{
			if (    sc->token eq K_DO
			    and sc->do_lbl
			    and SCMP(300,sc->do_lbl, name) eq 0
			   )
			{
				*n = name;
				return tok eq K_BREAK ? sc->brk : sc->cnt;
			}
			sc = sc->outer;
		}

		error("undefined loop name '%s'", name);
	}
	return 0;
}
#endif

static
bool bra_stmt(VP flow)
{
	short tok = cur->token;
	NP np;
#if FOR_A
	short do_lbl; char *name;
#endif

	fadvnode();
	if (tok eq K_BREAK)
	{
		VP root = flow->FF.root;	/* flown */

#if FOR_A
		if (G.lang eq 'a')
			do_lbl = find_do_lbl(tok, &name);
#endif

		if (root)
		{
			flow->F.escape |= BRK;
#if FOR_A
			if (G.lang eq 'a' and do_lbl)
				out_br(do_lbl);
			else

#endif
			{
				if (root->token ne K_SWITCH)
				{
					root->F.escape |= BRK;		/* for do ... while() */
					root->F.escape &= ~CLO;
				}
				out_br(flow->FF.brk);
			}
		}
		else
			error("lonely %s", graphic[K_BREAK]);
	}
#if FOR_A
	elif (tok eq K_ESAC and G.lang ne 'a')
	{
		flow->F.escape |= BRK;
		out_br(flow->FF.brk);
		return true;			/* 04'13 HR: do not eat ENDS */
	}
#endif
	elif (tok eq K_CONT)
	{
#if FOR_A
		if (G.lang eq 'a')
			do_lbl = find_do_lbl(tok, &name);
#endif
		flow->F.escape |= CNT;
#if FOR_A
		if (G.lang eq 'a' and do_lbl)
			out_br(do_lbl);
		else
#endif
			out_br(flow->FF.cont);
	}
	elif (tok eq K_RETURN)
	{
		TP tp = G.prtab->type;

		np=get_expr();
		new_gp(np,RETURN);
#if FOR_A
		if (G.prtab->token eq STMT)
			error("'s' not allowed", graphic[K_RETURN]);
		else
#endif
		{
			flow->F.escape |= tp->token eq T_VOID ? RET : RETV;

			if   (np and tp->token eq T_VOID)
				 errorn((NP)G.prtab, "void functions cant return a value");
			elif (!np and tp->token ne T_VOID)
				 errorn((NP)G.prtab, "must return a value");

			if (np)
				ret_expr(np, tp);

			gp->lbl = G.prtab->fretl;
			addcode(gp, "\tbra \t\tL1\n");
		}
		out_gp();
	}
#if FOR_A
	elif (tok eq K_GOTO and G.lang ne 'a')
#else
	elif (tok eq K_GOTO)
#endif
	{
		flow->F.escape |= WILD;
		np = npcur(); advnode();
		if (np->token ne ID)
		{
			errorn(np,"bad '%s'",graphic[K_GOTO]);
		othw
			VP tp;
			bool bt = false;		/* 05'16 HR v5.4 branch_type: forward or backward */

			if (G.ag_nogoto)
				warnn(np, "%s",graphic[K_GOTO]);
			tp = tlook(G.prtab->labels, np);
			if (tp eq nil)
			{
				tp = allocVn(LBNODE);
				tp->name = np->name;
				tp->nflgs.f.nheap = np->nflgs.f.nheap;
				np->nflgs.f.nheap = 0;
				putv_lifo(&G.prtab->labels, tp);
				tp->cs.lbl = new_lbl();
				bt = true;		/* true = branch forward, false = branch backward */
			}
			freenode(np);
			out_branch(bt, tp->cs.lbl);	/* 05'16 HR v5.4 */
		}
	}
	else
	{
		CE_("unknown bra_stmt");
		return false;
	}
#if FOR_A
	if (G.lang ne 'a')
#endif
		eat(ENDS);
	return true;
}

#if USAGE
static
void check_scope(TP tp)		/* usage tracking */
{
	while (tp)
	{
		if (tp->tflgs.f.used eq 0)
			if (    tp->tflgs.f.isarg eq 0 		/* dont warn arguments */
			    and tp->sc ne PROT				/* and prototypes      */
			   )
				warnn(tp, "unused");

		tp = tp->next;
	}
}
#endif

global
void end_scope(void)
{
	SCP bp;

	if (G.scope->b_regs.a  < G.prtab->maxregs.a)
		G.prtab->maxregs.a = G.scope->b_regs.a;
	if (G.scope->b_regs.d  < G.prtab->maxregs.d)
		G.prtab->maxregs.d = G.scope->b_regs.d;
#if FLOAT
	if (G.scope->b_regs.f  < G.prtab->maxregs.f)
		G.prtab->maxregs.f = G.scope->b_regs.f;
#endif

	if (G.scope->b_size + G.scope->b_tsize > G.prtab->maxlocs)
		G.prtab->maxlocs = G.scope->b_size + G.scope->b_tsize;

	G.prtab->level--;
	bp = G.scope;

	G.scope = bp->outer;
	bp->outer = nil;

#if USAGE
	if (!G.nmerrors)
		check_scope(bp->b_syms);
#endif

	freeTn(bp->b_syms);
	freeTn(bp->b_ops);
	freeTn(bp->b_casts);
	freeTn(bp->b_tags);
	CC_xfree(bp);				/* arg  or sub  */
}

#if FOR_A
static
void phrase(VP flow, short tok)
{
	if (tok eq T_PROC)		/* something special (no extra G.scope for parameters) */
	{
		loc_decls();

		unit(flow, BLOCK);
	othw
		new_scope(tok, graphic[tok]);
		loc_decls();
		unit(flow, tok);
		end_scope();
	}
}
#endif

static
void do_block(VP flow, short delim, bool lex)
{
	if (lex)
		loc_decls();

	if (cur->token ne EOFTOK)
	{
		do{
			while (C_stmt(flow));

			if (cur->token eq delim)
				return;
#if FOR_A
			/* The following situation occurs only when compiling for A */
			if (	delim eq K_ELSE
				and (	cur->token eq K_FI
					 or	cur->token eq K_ELIF )
				)
				return;
#endif
			/* error if get to here or if single statement func (for A only) */
			if (cur->token eq EOFTOK or is_tykw(cur))
				/* get out of block */
				return;
			else
				syntax_error("statements");
		}od
	}
}

global
void new_proc(Cstr name)
{
	FP new = CC_xcalloc(1, sizeof(FNODE), AH_PROC, CC_ranout);
#if NODESTATS
	G.ncnt[PRNODE]++;
#endif
	if (new)
	{
		new->outer = G.prtab;
		G.prtab = new;
		G.prtab->token =  T_PROC;
		name_to_str((NP)G.prtab, name);
	}
}

/* 11'19 HR v6 */
static
short old_to_new (TP old, TP new)
{
	TP tp = old->list;
	short ps = 0;

	while(tp)
	{
		TP ap = tlook(new, tp);

		if (ap)
		{
			tp->type = ap->type;
			to_nct(tp);
			tp->sc = K_AUTO;
			ps++;
			old->tflgs.f.o_s_conv = 1;
		}
		tp = tp->next;
	}
	old->offset = ps;
	return ps;
}

static
void def_to_int(TP tp, long *size)
{
	while (tp)
	{
		TP ap;
		if ((ap = tlook(G.scope->b_syms, tp)) eq nil)
		{
			def_arg(&G.scope->b_syms, tp);
			ap = G.scope->b_syms;
		}
#if USAGE
		tp->tflgs.f.isarg = 1;
#endif
		arg_size(size, ap);
		tp = tp->next;
	}
}

static
void body(TP xp, short context)
{
	TP	tp = xp->type;
	ALREG rmask   = {0, ARV_END+1-AREG,
#if FLOAT
						FRV_END+1-FREG,
#else
						0,
#endif
						DRV_END+1-DREG},
		  argmask = {0, 0, 0, 0};
#if FOR_A
		if (cur->token eq IS)
			fadvnode();				/* just looks nice */
#endif

	/* function body definition possibly with 'old args' */
	new_proc("func");

	if (G.v_Cverbosity)
		console("compiling %s\n", xp->name);

	set_class(xp, TEXT_class);
	new_gp(nil, PROC);		/* make first gnode for code output */
	gp->name = xp->name;
	gp->area_info = xp->area_info;
	gp->sc   = xp->sc;
	gp->cflgs.i= xp->type->cflgs.i;
	G.prtab->type = functy(xp->type);		/* It is the return type !!!! */
	type_is_not_a_copy(G.prtab);
	G.prtab->fretl = new_lbl();
	G.prtab->lkxl  = new_lbl();
	G.prtab->mmxl  = new_lbl();
	G.prtab->name  = xp->name;	/* funcname globally accessible */
	G.prtab->nflgs.f.nheap = 0;
#if FU_TREE
	if (G.ah_project_help and G.af_func_tree)
		pdb_depend(&fun_dependencies, nil, xp->name);
#endif

/*	not anymore G.prtab->fstrl; return aggreg now via 8(a6)	*/
	G.prtab->maxregs.d = DRV_END+1-DREG;
	G.prtab->maxregs.a = ARV_END+1-AREG;
#if FLOAT
	G.prtab->maxregs.f = FRV_END+1-FREG;
#endif
	G.prtab->maxlocs = 0;

#if ! SY_LATER
	globl_sym(xp);		/* after out ivm ev loc name with 'old args' */
#endif

	change_class(TEXT_class);
	gp->xflgs.f.asm_f = xp->type->tflgs.f.asm_func;
	c_mods(gp, xp->type);		/* 09'19 HR: v6 correct pascal behaviour */
	addcode(gp, "^S\t\t^N^X\n");	/* ^X pragmats for optimizer per function */
	next_gp(nil);
	out_fbegin(G.prtab, xp);
	new_scope(T_PROC, "arg block");		/* not anymore an extra outer block for args */
	G.scope->b_size = 0;				/*   for consistency */
	G.scope->b_regs = rmask;
	G.prtab->level = 1;		/* Only for if OLD_ARGS */
	out_gp();

	/* prototyping : ipv argsblock & loc_decls */
	if (tp->tflgs.f.ans_args)		/* gemaakt door C_args\A_args() */
	{
		TP bp;
		new_gp(nil, PROC);

		/* generate advice for TOP  etc */
		G.scope->b_syms = copyTnode(tp->list);

/* if func returns a aggragate, insert room for pointer as 1st parameter;
must here because in declarator() we don't know the declarer which is the return type */

		add_argbase(G.scope->b_syms, tp->type, ARG_BASE);

		bp = G.scope->b_syms;
		while(bp)
		{
			next_gp(reg_arg(&rmask, &argmask, bp, tp->xflgs.f.cdec));		/* includes lc_reg  */
			bp = bp->next;
		}

		out_gp();
	othw
		/* was args_blk */
		short ps = 0;
		TP bp, np = tp->list;
		long size = 0;

		xp->sc = K_GLOBAL;
		loc_decls();		/* for args */

		new_gp(nil, PROC);

		/* make sure all decls were in arg list */
		bp = G.scope->b_syms;
		while (bp)
		{
			TP kp = tlook(np, bp);
			if (kp eq nil)
				errorn(bp, "not in parameter list");
			bp = bp->next;
		}

		/* now make any names not mentioned int */
		/* and 11'19 HR v6: attach types to old args list of ID's. */
		def_to_int(np, &size);
#if 1
		ps = old_to_new(tp, G.scope->b_syms);		/* 11'19 HR v6 */
#endif
		add_argbase(G.scope->b_syms, tp->type, ARG_BASE);

		/* generate offsets and alloc regs */
		/* NB 'old args' don't have a tptr->list for arg types */
		bp = G.scope->b_syms;
		while (bp)
		{
			next_gp(reg_arg(&rmask, &argmask, bp, tp->xflgs.f.cdec));		/* includes lc_reg  */
			bp = bp->next;
		}

		out_gp();
		if (!ps)
		{
			freeTn(tp->list);
			tp->list = nil;
		}

		/* 'old args' do not generate a prototype; only a return type
		 * because the args order in the loc_decl() part is not defined
		 * so can be different from the order in the argsblk.
		 */
	}

#if SY_LATER
	globl_sym(xp);		/* 12'18 HR: v6 after args ivm ev loc name with 'old args' */
#endif

	G.scope->b_regs = rmask;

	G.fltab = allocVn(FLNODE);
	G.flow_chart = G.fltab;
	G.fltab->FF.brk  = -1;
	G.fltab->FF.cont = -1;
	G.fltab->FF.base = G.fltab;		/* points to itself; is copied in all next's at this level 0 */
	flno = 0;
	G.fltab->F.nr  = 0;
	G.fltab->token = T_PROC;
	G.fltab->name  = G.prtab->name;

	if (xp->type->tflgs.f.asm_func)
	{
#if BIP_ASM
		void do_asm(TP xp, short delim, bool lex);
		eat(BLOCK);
		G.prtab->level++;
		do_asm(xp, KCOLB, true);
		G.prtab->level--;
		G.tk_flags &= ~TK_SEENL;
#else
		error("assembler functions not available");
		while (cur->token ne KCOLB and cur->token ne EOFTOK)
			fadvnode();
#endif
		eat(KCOLB);
	othw
#if FOR_A
		if (G.lang eq 'a')
			if (cur->token ne BLOCK)
			{
				G.prtab->level++;
				unit(G.fltab, BLOCK);	/* no block: do a single unit (no locals) */
				G.prtab->level--;
			othw
				eat(BLOCK);
#if C_DEBUG
				last_k = false;
#endif
				G.prtab->level++;
				phrase(G.fltab, T_PROC);
				G.prtab->level--;
				eat(KCOLB);
			}
		else
#endif
		{
			eat(BLOCK);		/*not anymore an extra block for args */
			G.prtab->level++;
			do_block(G.fltab, KCOLB, true);
			G.prtab->level--;
			eat(KCOLB);
		}
	}

	end_scope();	/* for args level */

#if FLOW_SHOW
/*		if (G.v_Cverbosity > 3) */
	{
		console("--- flow_chart ---\n");
		list_flow(G.flow_chart, 0);
	}
#endif
#if OPEN_END
	if (    !G.nmerrors
	    and G.prtab->type->token ne T_VOID
	    and xp->type->tflgs.f.asm_func eq 0
	   )
		if (open_end(G.flow_chart,0))
			warnn(G.flow_chart, "function must return a value");
#endif
#if FLOW_SHOW
/*		if (G.v_Cverbosity > 3) */
		console("\n");
#endif

	{
		VpV free_equs;
		VP np = G.prtab->labels;
		FP bp;

		while (np)
		{
			if (np->cs.def eq 0)
				errorn(np,"undefined label");
			np = np->next;
		}

		out_fret(G.prtab, xp);
		write_literals();		/* per function */
		freeVn(G.flow_chart);
		G.flow_chart = nil;
		G.fltab      = nil;
#if BIP_ASM
		if (xp->type->tflgs.f.asm_func)
			free_equs();
#endif

		bp           = G.prtab;		/* step down G.prtab */
		G.prtab      = bp->outer;
		bp->outer    = nil;

		freeVn(bp->labels);
		new_areas();
		CC_xfree(bp);
	}
}

#if FOR_A
#include "a_lproc.h"
void adddef(Cstr);
#endif

VpV popflags;

global
void do_C(void)			/* Main compiler loop on a file
							only once called from do_file() in main() */
{
	TP head, xp;
	short sclass;

#if FOR_A
	if (G.lang eq 'a' or (G.xlang eq 'a' or G.xlang eq 'd'))
	{
		G.lang = 'a';
		adddef("__A__=1");
	}
	elif (G.lang eq 's')
		adddef("__S__=1");
	else
		adddef("__C__=1");
#endif
/*	popflags();
*/	G.prtab = CC_xcalloc(1, sizeof(FNODE), AH_PRTAB, CC_ranout);
#if NODESTATS
	G.ncnt[PRNODE]++;
#endif
	name_to_str((NP)G.prtab, "file{");
	G.iftab = allocVn(IFNODE);			/* root for preprocessor */
	name_to_str(G.iftab, "prep");
	G.iftab->p.truth = true;

	if (!G.ae_no_extracodes)
		invoke_runtime();		/* for long mul, div & mod
									(and possibly other things) */


	advnode();

	do
	{
		Cstr psclass(NP np);
		short context = 0;
		bool iscomma, isbody, isends = false, declty;
		/* global decls (incl func's) until eof */
#if FOR_A
		sclass = G.lang eq 'a' ? K_STATIC : K_GLOBAL;
#else
		sclass = K_GLOBAL;
#endif
		/* declty is set by derived_type() */
		head   = Declarer(false, nil, &sclass, &declty);		/* sclass --> declarer (K&R all editions) */

		if (!ok_gsh(sclass, head))
			if (cur->token ne EOFTOK)
				sclass = K_STATIC;			/* on sc & declarer */
		do
		{
			isbody  = 0;
			iscomma = 0;
			xp = Declare(head, NORMAL);

			if (ok_gx(xp, head))			/* oa xp ne 0 */
			{
				xp->sc = sclass;

				if (   !is_code(xp->type)
			        or xp->sc eq K_TYPE
				   )
				{
					globl_sym(xp);
					if (    xp->token eq ID
						and (   xp->sc eq K_STATIC
							 or xp->sc eq K_GLOBAL)
						)
					{
						new_gp(nil, INIT);
						if (static_init(xp))
							outcode_list(gpbase);
						freenode(gpbase);
						gpbase = nil;
					}
				othw		/* must be code or a prototype */
					bool con = is_con(cur->token);			/* 12'13 HR: v5 value like Pure C */
					isbody = cur->token ne COMMA and cur->token ne ENDS;
					if (isbody and !con)
						/* code */
						body(xp, context);
					elif (xp->type->tflgs.f.ans_args)
					{
						if (con)
						{
							xp->offset = cur->val.i;
							xp->xflgs.f.inl_v = 1;
							fadvnode();
						}

						xp->sc = PROT;  /* prototype */
						globl_sym(xp);
					}
				}
			othw
				if (xp)
					freeTn(xp);

				if (!declty)
					if ((cur->token ne ENDS and cur->token ne COMMA) or cur->token eq EOFTOK)
						syntax_error("declarator");
					elif (!head->tflgs.f.dflt)
					{
						head->fl.ln = line_no;	/* 07'19 HR: quick fix. */
						errorn(head, "no declarator for");
					}
			}
			iscomma = cur->token eq COMMA;
			if (iscomma)
				fadvnode();
		}  while (iscomma);					/* on declarator */

		isends = cur->token eq ENDS;
		if (isends)
			fadvnode();
		elif (!isbody)
			 error("global declaration missing '%s' at %s", graphic[ENDS], cur->name);
	}
	while (cur->token ne EOFTOK);		/* on declarer  */
	CC_xfree(G.prtab);			/* base van de function table) */
	G.prtab = nil;
	freeVn(G.iftab);			/* base van de preprocessor nest table */
	G.iftab = nil;
	freeXn(cur);
}

static
bool sub_block(VP flow)
{
	eat(BLOCK);
	if (is_ty_start())
	{
		new_gp(nil, BLOCK);
		new_scope(BLOCK, "free{");
		out_gp();
		do_block(flow, KCOLB, true);
		end_scope();
	othw
		do_block(flow, KCOLB, false);	/* not a real block, {} serve only as brackets (mostly for 'if') */
	}
	eat(KCOLB);

	return true;
}

#if FOR_A
static
bool block(VP flow)
{
	eat(BLOCK);
	phrase(flow, BLOCK);
	eat(KCOLB);
	return true;
}
#endif

static
void add_case(VP swit, ulong val, short lbl)		/* 03'09 long val (was short) */
{
	if (swit)
	{
		VP np, last, bp;

		np = allocVn(CSNODE);
		np->vval = val;
		np->F.size = swit->F.size;
		np->cs.lbl = lbl;
		new_name(np, "%d:%d", val, lbl);

		last = nil;
		bp = swit->F.caselist;
		/* sort on (unsigned) value */
		while (bp)
		{
			if (bp->vval eq val)
			{
				error("duplicate %s value: %lx::%lx",graphic[K_CASE], bp->vval, val);
				return;
			othw
				if (bp->vval > val)
					break;
			}
			last = bp, bp = bp->next;
		}

		if (last)
			last->next = np;
		else
			swit->F.caselist = np;
		np->next = bp;
	}
}

/* N.B.  in C case & default are not closed */
static
void new_default(VP flow, short dlbl, short tok, short toek)
{
	VP new,
	   swit = flow->FF.root;

	if (swit eq nil)
		error("%s outside %s", graphic[toek], graphic[tok]);	/* 3'91 v1.2 */
	elif (swit->F.out)
		error("multiple %s", graphic[toek]);
	else
	{
		new = allocVn(FLNODE);
		new->F.nr   = ++flno;
		swit->F.out = new;
		new->token  = K_DEF;
		new->FF     = flow->FF;		/* inherit flow data (break & continue) */
		name_to_str(new, "default");
		swit->F.deflbl = dlbl;
		G.fltab = new;
	}
}

static
VP new_case(VP flow, short dlbl)
{
	VP np,
	   new = nil,
	   swit = flow->FF.root;

	if (swit eq nil)
		error("%s outside %s", graphic[K_CASE], graphic[K_SWITCH]);	/* 3'91 v1.2 */
	else
	{
		np = swit;
		while (np->inner)
			np = np->inner;		/* find last case */
		new = allocVn(FLNODE);
		new->F.nr  = ++flno;
		new->F.size = swit->F.size;
		np->inner  = new;
		new->token = K_CASE;
		new->FF    = swit->inner->FF;		/* inherit flow data (break & continue) */
		name_to_str(new, graphic[K_CASE]);
		G.fltab = new;
	}
	return new;
}

static
void lbl_stmt(VP flow)
{
	short l1 = new_lbl();
	do
	{
		short tok = cur->token;
		fadvnode();
		if   (tok eq K_CASE)
		{
			ulong val = 0;
			VP new = new_case(flow, l1);
			NP np  = need_expr();

			if (np)
				val = confold_value(np, FORSIDE);

			if (new)
			{
				VP swit = flow->FF.root;

				if (swit->F.size eq DOT_W)
					val &= 0xffff;
				elif (swit->F.size eq DOT_B)
					val &= 0xff;

				new->vval = val;
				add_case(flow->FF.root, new->vval, l1);
			}
		}
		elif (tok eq K_DEF)
			new_default(flow, l1, K_SWITCH, K_DEF);
		eat(LABEL);
	}
	while (is_lblst(cur));		/* K_CASE or K_DEF */
	def_lbl(l1);
}

#if FOR_A
#include "a_stmts.h"
#endif

static
bool blk_stmt(VP back)
{
	short tok;
	short l1, l2, l3;
	NP  e1, e2, e3;

	tok = cur->token;
	fadvnode();

	if (tok eq K_IF)
	{
		VP flow;

		l1 = new_lbl();
		flow = new_unit(back, cur, K_IF);
		eat(PAREN);
		e1 = need_expr();
		new_gp(e1, K_IF);
		gen_boolean(e1, l1, for_FALSE);
		out_gp();
		eat(NERAP);
		flow->inner = new_in(flow, "true", -1, -1);
		C_stmt(flow->inner);
		G.fltab = flow->inner;
#if FOR_A
		if (	cur->token eq K_ELIF
			or  cur->token eq K_ELSE)
		{
			if (cur->token eq K_ELIF)
			{
					/* trickbox (see 'if_stmt()' for proper programming (for a proper programming language) ) */
				cur->token = K_IF;
				cur->cat0|=BL_ST;
					/* This in fact mimics '#define elif else if' */
			}
			else
				fadvnode();

			l2 = new_lbl();
			flow->F.out = new_out(flow, "false");
			out_br(l2);
			def_lbl(l1);
			C_stmt(flow->F.out);
			def_lbl(l2);
		othw
			def_lbl(l1);
		}
#else
		if (cur->token eq K_ELSE)
		{
			fadvnode();
			l2 = new_lbl();
			flow->F.out = new_out(flow, "false");
			out_br(l2);
			def_lbl(l1);
			C_stmt(flow->F.out);
			def_lbl(l2);
		othw
			def_lbl(l1);
		}
#endif
		G.fltab = flow;
	}
	elif (tok eq K_WHILE)
	{
		VP flow;

		l1=new_lbl();
		l2=new_lbl();

		flow = new_unit(back, cur, K_WHILE);
		flow->inner = new_in(flow, "block", l2, l1);
		flow->inner->FF.root = flow;
		loop_lbl(l1);
		eat(PAREN);
		e1 = need_expr();
		if (e1 eq nil
			or e1 and  (e1->token eq ICON and e1->val.i ne 0)
		   )
			flow->F.escape |= CLO;
		new_gp(e1, WHILE);
		gen_boolean(e1, l2, for_FALSE);
		eat(NERAP);
		out_gp();
		C_stmt(flow->inner);
		add_br_1_2(l1);				/* bra l1\n  l2: */
		G.fltab = flow;
	}
	elif (tok eq K_DO)
	{
		VP flow;

		l1=new_lbl();
		l2=new_lbl();
		l3=new_lbl();
		flow = new_unit(back, cur, K_DO);
		flow->inner = new_in(flow, "block", l3, l2);
		flow->inner->FF.root = flow;
		loop_lbl(l1);
		C_stmt(flow->inner);
		def_lbl(l2);
		if (cur->token eq K_WHILE)
		{
			fadvnode();
			eat(PAREN);
			e1 = need_expr();
			if (   e1 eq nil
				or e1 and (e1->token eq ICON and e1->val.i ne 0)
			   )
				if ((flow->F.escape&BRK) eq 0)
					flow->F.escape |= CLO;
			new_gp(e1,WHILE);
			gen_boolean(e1, l1, for_TRUE);
			out_gp();
			eat(NERAP);
			eat(ENDS);
			def_lbl(l3);
		othw
#if FOR_A
			if (cur->token eq K_OD)					/* same as while(1) */
			{
				if ((flow->F.escape&BRK) eq 0)
					flow->F.escape |= CLO;
				fadvnode();
			}
			else
#endif
			{
				if ((flow->F.escape&BRK) eq 0)
					flow->F.escape |= CLO;
				warn("do statement without while! unconditional loop generated");
			}
			add_br_1_3(l1);
		}
		G.fltab = flow;
	}
	elif (tok eq K_FOR)
	{
		VP flow;
		long e3_line, e2_line;

		l1=new_lbl();
		l2=new_lbl();
		l3=new_lbl();

		flow = new_unit(back, cur, K_FOR);
		flow->inner = new_in(flow, "block", l3, l2);
		flow->inner->FF.root = flow;
		eat(PAREN);
		e1=get_expr();
		new_gp(e1, EX1);
		do_expr(e1, FORSIDE);
		out_gp();
		eat(ENDS);
		loop_lbl(l1);
		e2 = get_expr();
		new_gp(e2, EX2);
		if (e2)
		{
			if (e2->token eq ICON and e2->val.i ne 0)
				flow->F.escape |= CLO;
			gen_boolean(e2, l3, for_FALSE);
		}
		else
			flow->F.escape |= CLO;
		eat(ENDS);
		out_gp();
		e3 = get_expr();	/* save for later */
		e3_line = line_no;
		eat(NERAP);

		C_stmt(flow->inner);
		def_lbl(l2);
		e2_line = line_no;
		line_no = e3_line;
		new_gp(e3, EX3);
		do_expr(e3, FORSIDE);
		out_gp();
		line_no = e2_line;
		add_br_1_3(l1);
		G.fltab = flow;
	}
	elif (tok eq K_SWITCH)		/* curswit swapping removed; now via flow */
	{
		VP flow;
		short sty;
		long ssz;

		l1=new_lbl();		/* break lable */
		l2=new_lbl();		/* branch over case code to switching code */
		flow = new_unit(back, cur, K_SWITCH);
		flow->inner = new_in(flow, "list", l1, -1);
		flow->inner->FF.root = flow;
		eat(PAREN);
		e1 = need_expr();
		if (e1)
		{
			new_gp (e1, SWIT);
			do_expr(e1, SWITCH);		/* switches of any integral type */
			ssz = e1->size;
			sty = e1->ty;
			if (e1->size > DOT_W)
			if (    !G.nmerrors			/* ty not defined than */
				and sty ne ET_S and sty ne ET_U)
				error("switch non integral");
			out_gp();
			eat(NERAP);
		}

		out_br(l2);
		flow->F.deflbl = -1;
		flow->F.size = ssz;

		if (C_stmt(flow->inner))
		{
			add_br_1_2(l1);				/* bra l1\n  l2: */
			gen_switch(flow->F.caselist, flow->F.size, flow->F.deflbl);
			def_lbl(l1);
		}
		G.fltab = flow;
	}
	else
	{
		CE_("unknown blk_stmt");
		freenode(gpbase);
		gpbase = nil;
		return false;
	}
	return true;
}

#if FOR_A
#include "a_clause.h"
#endif

/* for C: do a single statement */
static
bool C_stmt(VP flow)
{
	do{
		if (cur->token eq BLOCK)
			return sub_block(flow),	true;
		if (cur->token eq ENDS )
			return fadvnode (),		true;
		if (cur->token eq K_ELSE)
			error("%s without correspondig %s", graphic[K_ELSE], graphic[K_IF]),
			fadvnode();
		elif (is_stkw(cur))
		{
			if (is_blkst(cur) and blk_stmt(G.fltab))
				return true;
			if (is_brast(cur) and bra_stmt(G.fltab))	/* G.fltab = current active flow */
				return true;
			if (is_lblst(cur))
				lbl_stmt(flow);
		othw
			NP np = get_expr();

			if (np eq nil)
				return false;
			if (cur->token ne LABEL)
			{
				new_gp(np, EXPR);
				do_expr(np, FORSIDE);
				eat(ENDS);
				out_gp();		/* will free everything */
				break;
			}

			fadvnode();
			label(np);
		}
	}od

	return true;
}
