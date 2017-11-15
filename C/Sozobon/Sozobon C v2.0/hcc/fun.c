/* Copyright (c) 1988,1991 by Sozobon, Limited.  Author: Johann Ruegg
 *
 * Permission is granted to anyone to use this software for any purpose
 * on any computer system, and to redistribute it freely, with the
 * following restrictions:
 * 1) No charge may be made other than reasonable charges for reproduction.
 * 2) Modified versions must be clearly marked as such.
 * 3) The authors are not responsible for any harmful consequences
 *    of using this software, even if they result from defects in it.
 *
 *	fun.c
 *
 *	Handle function entry, exit, etc.
 *	Parse statements.
 *	Also, general syntax error recovery strategy.
 */

#include <stdio.h>
#include "param.h"
#include "tok.h"
#include "nodes.h"
#include "cookie.h"

#if MMCC
overlay "pass2"
#endif

extern NODE *cur;

int level;
NODE *blktab;
NODE *labels;

struct swittbl {
	NODEP	caselist;
	int	deflbl;
} *curswit;

int curbrk, curcont;
int funtopl, funbotl, funretl, funstrl;
NODEP funtyp;
int maxregs;
long maxlocs;

int skipon;

NODEP glb_decls();

extern int oflags[];
#define debugl oflags['l'-'a']
#define debugs oflags['s'-'a']
#define debugv oflags['v'-'a']

findtok(x)
{
	while (cur->e_token != EOFTOK && cur->e_token != x)
		fadvnode();
	if (cur->e_token == EOFTOK)
		exit(1);
}

program()
{
	extern NODEP symtab[];
	NODEP last;

	skipon = 0;
more:
	last = glb_decls();
	if (cur->e_token == EOFTOK)
		return;
	if (last) skipon = 0;	/* saw something valid */
	if (last && last->n_tptr && last->n_tptr->t_token == '(') {
	/* possible function definition */
		if (debugs) {
			printf("FUN ");
			put_nnm(last);
		}
		out_fstart(last);
#ifdef OUT_AZ
		last->e_sc = HERE_SC;
#else
		last->e_sc = K_EXTERN;
#endif
		fun_start(last->n_tptr);
		args_blk(last->n_tptr->n_right);
		sub_block();
		fun_end();
		clr_lvl(); /* for args block */
		goto more;
	}
	/* error if get to here */
	if (last) {
		error("missing ;");
		goto more;
	} else {
		skip();
		goto more;
	}
}

fun_start(np)
NODEP np;
{
	NODEP functy();

	funtyp = functy(np);
	curbrk = curcont = -1;
	funtopl = new_lbl();
	funbotl = new_lbl();
	funretl = new_lbl();
	switch (funtyp->t_token) {
	case K_STRUCT:
	case K_UNION:
		funstrl = new_lbl();
		break;
	default:
		funstrl = 0;
	}
	maxregs = 0;
	maxlocs = 0;
	out_br(funbotl);
	def_lbl(funtopl);
}

fun_end()
{
	NODEP np;

	if (labels) {
		for (np = labels; np; np = np->n_next)
			if (np->c_defined == 0)
				errorn("undefined label", np);
		freenode(labels);
		labels = NULL;
	}
	def_lbl(funretl);
	out_fret(maxregs, funstrl);
	def_lbl(funbotl);
	out_fend(maxregs, maxlocs);
	out_br(funtopl);
	if (funstrl)
		out_fs(funstrl, funtyp->t_size);
}

skip()
{
	if (skipon == 0) {
		error("syntax (try skipping...)");
		skipon = 1;
	}
	fadvnode();
}

block()
{
	int some;
	int sawsome;

	some = loc_decls();
	if (cur->e_token == EOFTOK)
		return;
	if (some) skipon = 0;
more:
	sawsome = stmts(); 
	if (sawsome) skipon = 0;
	if (cur->e_token == '}') {
		maxregs |= blktab->b_regs;
		if (blktab->b_size + blktab->b_tsize > maxlocs)
			maxlocs = blktab->b_size + blktab->b_tsize;
		return;
	}

	/* error if get to here */
	if (cur->e_token == EOFTOK || is_tykw(cur->e_token))
		/* get out of block */
		return;
	else {
		skip();
		goto more;
	}
}

clr_lvl()
{
	NODE *bp;

	level--;
	bp = blktab;
	blktab = bp->n_next;
	bp->n_next = NULL;
	if (debugl && bp->b_syms) {
		printf("local syms %d", level);
		printlist(bp->b_syms);
	}
#ifdef OUT_AZ
	xrefl(bp->b_syms);
#endif
	freenode(bp->b_syms);
	if (debugl && bp->b_tags) {
		printf("local tags %d", level);
		printlist(bp->b_tags);
	}
	freenode(bp->b_tags);
	freenode(bp);
}

eat(c)
{
	char *p = "assume X";

	if (cur->e_token == c)
		fadvnode();
	else {
		p[strlen(p) - 1] = c;
		error(p);
	}
}

sub_block()
{
	register NODE *new;

	if (debugs)
		printf("{ ");
	eat('{');
	level++;
	new = allocnode();
	new->n_next = blktab;
	sprintf(new->n_name, "sub{");
	blktab = new;
	block();
	clr_lvl();
	eat('}');
	if (debugs)
		printf("}\n");
}

args_blk(np)
NODEP np;
{
	register NODE *p;
	register NODE *new;
	NODE *tp;
	NODEP llook();
	long size;
	int rmask;

	size = 0;
	rmask = 0;
	new = allocnode();
	new->n_next = blktab;
	sprintf(new->n_name, "arg{");
	blktab = new;
	level++;
	loc_decls();
	/* make sure all decls were in arg list */
	for (p=new->b_syms; p != NULL; p = p->n_next)
		if (llook(np, p) == NULL)
			errorn("ID not param", p);
	/* now make any names not mentioned INT */
	/* and generate offsets and alloc regs */
	for (p=np; p != NULL; p = p->n_next) {
		if ((tp=llook(new->b_syms, p)) == NULL) {
			def_arg(&new->b_syms, p);
			tp = new->b_syms;
		}
		lc_size(&size, &rmask, tp);
		if (tp->e_sc == K_REGISTER)
			reg_arg(&rmask, tp);
		if (debugv) {
			printf("final o%ld r%d ", tp->e_offs, tp->e_rno);
			put_nnm(tp);
			putchar('\n');
		}
		out_advice(tp);
	}
	new->b_regs = rmask;
}

reg_arg(rp, xp)
int *rp;
NODEP xp;
{
	if (lc_reg(rp, xp) == 0) {	/* out of regs? */
		xp->e_sc = K_AUTO;
		return;
	}
	out_argreg(xp);
}


stmts()
{
	int didsome;

	didsome = 0;
	while (stmt())
		didsome++;
	return didsome;
}

stmt_bc(brk,cont)
{
	int svb, svc;

	svb = curbrk;
	svc = curcont;
	curbrk = brk;
	curcont = cont;

	stmt();

	curbrk = svb;
	curcont = svc;
}

stmt_b(brk)
{
	int svb;

	svb = curbrk;
	curbrk = brk;

	stmt();

	curbrk = svb;
}

/* do a single statement */
stmt()
{
	register tok;
	NODEP np;
	NODEP getexpr();
	int i;

more:
	tok = cur->e_token;
	if (is_stkw(tok)) {
		if (is_blkst(tok)) {
			i = blk_stmt();
		} else if (is_brast(tok)) {
			i = bra_stmt();
		} else if (is_lblst(tok)) {
			i = lbl_stmt();
		} else {
			asm_stmt();
			return 1;
		}
		if (i == 0)
			goto more;
		return 1;
	}
	else if (tok == '{') {
		sub_block();
		return 1;
	} else if (tok == ';') {
		fadvnode();
		return 1;
	}
	np = getexpr();
	if (np) {
		if (cur->e_token == ':') {
			fadvnode();
			label(np);
			goto more;
		}
		expr_stmt(np);
		if (cur->e_token != ';')
			error("missing ;");
		else
			fadvnode();
		return 1;
	}
	return 0;
}

expr_stmt(np)
NODEP np;
{
	if (debugs) {
		printf("E_STMT ");
		if (debugs > 1)
			printnode(np);
	}
	do_expr(np, FORSIDE);
}

label(np)
NODEP np;
{
	register NODEP tp;
	NODEP llook();

	if (debugs) {
		printf("LABEL ");
		if (debugs > 1)
			printnode(np);
	}
	if (np->e_token != ID) {
		error("weird label");
		return;
	}
	tp = llook(labels, np);
	if (tp) {
		freenode(np);
		if (tp->c_defined) {
			error("duplicate label");
			return;
		}
	} else {
		putlist(&labels, np);
		tp = np;
		tp->c_casel = new_lbl();
	}
	tp->c_defined = 1;
	def_lbl(tp->c_casel);
}

blk_stmt()
{
	register tok;
	int l1, l2, l3;
	NODEP e1, e2, e3;
	NODEP opt_expr(), paren_expr(), def_type();
	struct swittbl locswit, *oldp;
	extern int lineno;
	int svline, svline2;

	tok = cur->e_token;
	fadvnode();
	switch (tok) {
	case K_IF:
		if (debugs)
			printf("IF ");
		l1 = new_lbl();
		e1 = paren_expr();
		gen_brf(e1, l1);
		eat(')');
		stmt();
		opt_else(l1);
		return 1;
	case K_WHILE:
		if (debugs)
			printf("WHILE ");
		e1 = paren_expr();
		l1 = new_lbl();
		l2 = new_lbl();

		def_lbl(l1);
		gen_brf(e1,l2);
		eat(')');

		stmt_bc(l2,l1);

		out_br(l1);
		def_lbl(l2);
		return 1;
	case K_DO:
		if (debugs)
			printf("DO ");
		l1 = new_lbl();
		l2 = new_lbl();
		l3 = new_lbl();
		def_lbl(l1);

		stmt_bc(l3,l2);

		def_lbl(l2);
		eat(K_WHILE);
		e1 = paren_expr();
		gen_brt(e1, l1);
		eat(')');
		eat(';');
		def_lbl(l3);
		return 1;
	case K_FOR:
		if (debugs)
			printf("FOR ");
		l1 = new_lbl();
		l2 = new_lbl();
		l3 = new_lbl();
		eat('(');
		e1 = opt_expr();
		expr_stmt(e1);
		eat(';');
		def_lbl(l1);
		e2 = opt_expr();
		if (e2)
			gen_brf(e2,l3);
		eat(';');
		e3 = opt_expr();	/* save for later */
		svline = lineno;
		eat(')');

		stmt_bc(l3,l2);

		def_lbl(l2);

		svline2 = lineno;
		lineno = svline;
		expr_stmt(e3);
		lineno = svline2;

		out_br(l1);
		def_lbl(l3);
		return 1;
	case K_SWITCH:
		if (debugs)
			printf("SWITCH ");
		e1 = paren_expr();
		l1 = new_lbl();
		l2 = new_lbl();
		to_d0(e1, def_type());
		eat(')');

		out_br(l2);
		oldp = curswit;
		curswit = &locswit;
		locswit.caselist = NULL;
		locswit.deflbl = -1;

		stmt_b(l1);

		out_br(l1);
		def_lbl(l2);
		gen_switch(locswit.caselist, locswit.deflbl);
		curswit = oldp;
		def_lbl(l1);
		return 1;
	case K_ELSE:
		error("unexpected 'else'");
		fadvnode();
		return 0;
	}
}

NODEP
paren_expr()
{
	NODEP np;
	NODEP need_expr();

	eat('(');
	np = need_expr();
	return np;
}

bra_stmt()
{
	register tok;
	NODEP np, tp;
	NODEP opt_expr(), llook();

	tok = cur->e_token;
	fadvnode();
	switch (tok) {
	case K_BREAK:
		if (debugs)
			printf("BRK");
		eat(';');
		out_br(curbrk);
		return 1;
	case K_CONTINUE:
		if (debugs)
			printf("CONT ");
		eat(';');
		out_br(curcont);
		return 1;
	case K_RETURN:
		if (debugs)
			printf("RETURN ");
		np = opt_expr();
		if (np) {
			if (funstrl)
				ret_stru(np);
			else
				to_d0(np, funtyp);
		}
		out_br(funretl);
		eat(';');
		return 1;
	case K_GOTO:
		if (debugs)
			printf("GOTO ");
		np = cur;  advnode();
		if (np->e_token != ID)
			error("bad goto");
		else {
			tp = llook(labels, np);
			if (tp) {
				freenode(np);	
			} else {
				tp = np;
				putlist(&labels, tp);
				tp->c_casel = new_lbl();
			}
			out_br(tp->c_casel);
		}
		eat(';');
		return 1;
	}
}

lbl_stmt()
{
	register tok;
	NODEP need_expr(), np;
	int l1, i;

	l1 = new_lbl();
	tok = cur->e_token;
again:
	fadvnode();
	switch (tok) {
	case K_CASE:
		if (debugs)
			printf("CASE ");
		np = need_expr();
		i = conxval(np);
		if (curswit)
			add_case(i,l1);
		else
			error("'case' outside switch");
		eat(':');
		break;
	case K_DEFAULT:
		if (debugs)
			printf("DEFAULT ");
		if (curswit) {
			if (curswit->deflbl >= 0)
				error("multiple 'default'");
			curswit->deflbl = l1;
		} else
			error("'default' outside switch");
		eat(':');
	}
	tok = cur->e_token;	/* lookahead for more cases */
	if (tok == K_CASE || tok == K_DEFAULT)
		goto again;
	def_lbl(l1);
	return 0;
}

asm_stmt()
{
	NODEP np, getexpr();

	fadvnode();
	np = getexpr();
	if (np == NULL || np->e_token != SCON) {
		error("bad asm() func");
	} else {
		out_asm(np);
		freenode(np);
	}
	eat(';');
}

NODEP
opt_expr()
{
	NODE *np, *getexpr();

	np = getexpr();
	if (np) {
		if (debugs) {
			printf("OXPR ");
			if (debugs > 1)
				printnode(np);
		}
	}
	return np;
}

NODEP
need_expr()
{
	NODE *np, *getexpr();

	np = getexpr();
	if (np) {
		if (debugs) {
			printf("NXPR ");
			if (debugs > 1)
				printnode(np);
		}
	} else
		error("need expr");
	return np;
}

opt_else(l1)
{
	int l2;

	if (cur->e_token == K_ELSE) {
		if (debugs)
			printf("ELSE ");
		fadvnode();
		l2 = new_lbl();
		out_br(l2);
		def_lbl(l1);
		stmt();
		def_lbl(l2);
	} else
		def_lbl(l1);
}

add_case(val, lbl)
{
	NODEP np, last, p;

	np = allocnode();
	np->c_casev = val;
	np->c_casel = lbl;
	sprintf(np->n_name, "%d:%d", val, lbl);

	last = NULL;
	for (p = curswit->caselist; p; last=p, p=p->n_next)
		if (p->c_casev == val) {
			error("duplicate case");
			return;
		} else if (p->c_casev > val)
			break;
	if (last) {
		last->n_next = np;
		np->n_next = p;
	} else {
		curswit->caselist = np;
		np->n_next = p;
	}
	if (debugs) {
		printf("CASELIST\n");
		printnode(curswit->caselist);
	}
}

to_d0(np, typ)
NODEP np, typ;
{
	NODEP tp;

	tp = allocnode();
	tp->e_token = TCONV;
	tp->n_tptr = typ;
	tp->n_flags |= N_COPYT;
	tp->n_left = np;
	tp->e_type = E_UNARY;
	strcpy(tp->n_name, "r cast");

	do_expr(tp, IND0);
}

ret_stru(np)
NODEP np;
{
	p2_expr(&np);
	if (same_type(np->n_tptr, funtyp) == 0) {
		error("bad struct return type");
		return;
	}
	genx(np, RETSTRU);	
}
