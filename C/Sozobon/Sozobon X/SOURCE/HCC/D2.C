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
 *	d2.c
 *
 *	Declaration subroutines
 *
 *	Mostly routines for initializations
 */

#include <stdio.h>
#include "param.h"
#include "tok.h"
#include "nodes.h"
#include "cookie.h"

#if MMCC
overlay "pass2"
#endif

extern NODEP cur;
extern NODEP symtab[];
extern level;

extern int oflags[];
#define debugi	oflags['i'-'a']

su_size(lp, cp, xp, isunion)
register long *lp;
char *cp;
register NODE *xp;
{
	long sz;
	char al;

	sz = xp->n_tptr->t_size;
	al = xp->n_tptr->t_aln;
	if (isunion) {
		*lp = *lp > sz ? *lp : sz;
	} else {
		while (al & (*lp)) {	/* align new field */
			(*lp)++;
			xp->e_offs++;
		}
		*lp += sz;
	}
	*cp = *cp > al ? *cp : al;
}

lc_size(lp, rp, xp)
register long *lp;
int *rp;
register NODE *xp;
{
	long sz;
	char al;
	long arg_size();
#ifdef LAT_HOST
	long tsz;
#endif

	if (level > 1 && xp->e_sc == K_REGISTER) {
		if (lc_reg(rp, xp))
			return;
		else
			xp->e_sc = K_AUTO;
	}
	if (xp->e_sc == K_AUTO || level == 1) {
		sz = xp->n_tptr->t_size;
		al = xp->n_tptr->t_aln;
		while (al & (*lp)) {	/* align new field */
			(*lp)++;
			xp->e_offs++;
		}
		if (level == 1) {
#ifndef LAT_HOST
			sz = arg_size(sz,xp);
#else
			tsz = arg_size(sz,xp);
			sz = tsz;
#endif
			xp->e_offs += ARG_BASE + *lp;
		}
		*lp += sz;
		if (level != 1)
			xp->e_offs = LOC_BASE - *lp;
	}
}

su_fld(lp, alp, xp, fldw, fop)
register long *lp;
char *alp;
register NODE *xp;
int *fop;
{
	if (*alp < ALN_I)
		*alp = ALN_I;
	if (fldw == 0) {
		afterfld(lp, fop);
		return;
	}
	if (fldw + *fop > 8*SIZE_I)
		afterfld(lp, fop);
	if (xp) {
		xp->e_fldw = fldw;
		xp->e_fldo = *fop;
	}
	*fop += fldw;
}

afterfld(szp, fop)
long *szp;
int *fop;
{
	if (*fop) {
		*szp += SIZE_I;
		*fop = 0;
	}
}

ok_gsh(sc, np)
NODE *np;
{
	if (sc == K_REGISTER || sc == K_AUTO) {
		error("reg/auto outside fun");
		return 0;
	}
	return ok_ty(np, NULL);
}

ok_gx(np, endp)
NODEP np, endp;
{
	if (np)
		return ok_ty(np->n_tptr, endp);
	return 0;
}

ok_lsh(sc, np)
NODE *np;
{
	return ok_ty(np, NULL);
}

arytoptr(np)
NODEP np;
{
	NODEP tp = np->n_tptr;
	NODEP copyone();

	if (np->n_flags & N_COPYT) {	/* cant change if a dupl. */
		tp = copyone(tp);
		np->n_tptr = tp;
		np->n_flags &= ~N_COPYT;
	}
	tp->t_token = STAR;
	strcpy(tp->n_name, "Aptr to");
}

ok_lx(np,endp)
NODEP np, endp;
{
	if (np) {
		if (level == 1 && np->n_tptr->t_token == '[')
			arytoptr(np);
		return ok_ty(np->n_tptr, endp);
	}
	return 0;
}

ok_suh(np)
NODEP np;
{
	return 1;
}

ok_sux(np, endp)
NODEP np, endp;
{
	if (np)
		return ok_ty(np->n_tptr, endp);
	return 0;
}

ok_enx(np, endp)
NODEP np, endp;
{
	if (np && np->n_tptr == endp)	/* no modifiers */
		return 1;
	return 0;
}

ok_cast(np, endp)
NODEP np, endp;
{
	if (np)
		return ok_ty(np, endp);
	return 0;
}

ok_ty(np, endp)
register NODEP np, endp;
{
	NODEP child;
	long csize;
	long conlval();

	if (np == endp)
		return 1;
	child = np->n_tptr;
	if (child) {
		if (ok_ty(child, endp) == 0)
			return 0;
		csize = child->t_size;
	}

	switch (np->t_token) {
	case STAR:
		np->t_size = SIZE_P;
		np->t_aln = ALN_P;
		break;
	case '(':
		/* size 0 okay - fun ret void */
		if (child->t_token == '[') {
			error("bad func");
			return 0;
		}
		/* size 0 */
		break;
	case '[':
		if (csize == 0) {
			error("bad array");
			return 0;
		}
		if (np->n_right) {
			csize *= conlval(np->n_right);
			np->n_right = NULL;
			np->t_size = csize;
		}
		np->t_aln = child->t_aln;
		break;
	default:
		return 1;
	}
	return 1;
}

ok_revx(rv,forcast)
NODEP rv;
{
	if (rv == NULL)
		return 1;
	if (forcast == 0 && rv->e_token != ID) {
		error("need ID");
		return 0;
	}
	if (forcast && rv->e_token == ID) {
		error("ID in cast");
		return 0;
	}
	return 1;
}

opt_ginit(xp)
NODEP xp;
{
	if (xp->e_token != ID)
		return;
	if (xp->n_tptr->t_token == '(')
		return;
	switch (xp->e_sc) {
	case K_STATIC:
	case HERE_SC:
		if (cur->e_token == '=') {
			out_gv(xp, 0);
			fadvnode();
			g_init(xp->n_tptr);
		} else
			out_gv(xp, 1);
	}
}

opt_linit(xp)
NODEP xp;
{
	if (xp->e_token != ID)
		return;
	if (xp->n_tptr->t_token == '(')
		return;
	switch (xp->e_sc) {
	case K_STATIC:
		if (cur->e_token == '=') {
			out_gv(xp, 0);
			fadvnode();
			g_init(xp->n_tptr);
		} else
			out_gv(xp, 1);
		to_text();
		break;
	case K_AUTO:
	case K_REGISTER:
		if (xp->n_tptr->t_token == '[')
			return;
		if (cur->e_token == '=')
			a_init(xp);
		break;
	}
}

a_init(op)
NODEP op;
{
	register NODEP np, xp;
	NODEP assignx(), copynode();

	np = cur;  advnode();
	xp = assignx();
	op = copynode(op);
	np->n_left = op;
	np->n_right = xp;
	np->e_type = E_BIN;
	do_expr(np, FORSIDE);
	return;
}

opt_enval(intp)
int *intp;
{
	NODEP np;
	NODEP questx();

	if (cur->e_token == '=') {
		fadvnode();
		np = questx();
		*intp = conxval(np);
		return;
	}
}

opt_field(xp,wdp,isunion)
NODE *xp;
int *wdp;
{
	NODEP np;
	NODEP questx();
	int i;

	*wdp = -1;
	if (isunion) return;
	if (cur->e_token == ':') {
		fadvnode();
		np = questx();
		i = conxval(np);
		if (i > 8*SIZE_I) {
			error("field too big");
			i = 8*SIZE_I;
		}
		if (xp) {
			if (i <= 0 || bad_fty(xp->n_tptr)) {
				error("bad field");
				return;
			}
		} else if (i < 0) {
			error("neg field width");
			return;
		}
		*wdp = i;
		return;
	}
}

bad_fty(tp)
NODEP tp;
{
	int tok;

	tok = tp->t_token;
	if (tok == K_INT || tok == K_UNSIGNED)
		return 0;
	return 1;
}

field(xp, wd, ofp)
NODEP xp;
int *ofp;
{
}

NODEP
def_type()
{
	NODEP bas_type();

	return bas_type(K_INT);
}

#define NSC	LAST_SC-FIRST_SC+1
#define NBAS	LAST_BAS-FIRST_BAS+1

NODE basics[NBAS];
NODE str_ptr, fun_int;

struct bt {
	char	*name;
	int	size;
	char	align;
} btbl[] = {
	{"Uchar",	SIZE_C, ALN_C},
	{"Ulong",	SIZE_L, ALN_L},
	{"Long",	SIZE_L,	ALN_L},
	{"Short",	SIZE_S, ALN_S},
	{"Uns",		SIZE_U, ALN_U},
	{"Int",		SIZE_I, ALN_I},
	{"Char",	SIZE_C, ALN_C},
	{"Float",	SIZE_F, ALN_F},
	{"Dbl",		SIZE_D, ALN_D},
	{"Void",	0},
};

NODEP
bas_type(btype)
{
	NODEP rv;
	static once = 0;

	if (once == 0) {
		once++;

		sprintf(str_ptr.n_name, "Ptr to");
		str_ptr.t_token = STAR;
		str_ptr.n_tptr = bas_type(K_CHAR);
		str_ptr.n_flags = N_COPYT;
		str_ptr.t_size = SIZE_P;
		str_ptr.t_aln = ALN_P;

		sprintf(fun_int.n_name, "Fun ret");
		fun_int.t_token = '(';
		fun_int.n_tptr = bas_type(K_INT);
		fun_int.n_flags = N_COPYT;
	}
	if (btype == SCON)
		return &str_ptr;
	else if (btype == '(')
		return &fun_int;
	rv = &basics[btype-FIRST_BAS];
	if (rv->t_token == 0) {
		rv->t_token = btype;
		rv->t_size = btbl[btype-FIRST_BAS].size;
		rv->t_aln = btbl[btype-FIRST_BAS].align;
		sprintf(rv->n_name, btbl[btype-FIRST_BAS].name);
	}
	return rv;
}

/* new function name seen in expr */
NODEP
new_fun(op)
NODE *op;
{
	NODEP np;
	NODEP copyone();

	/* we know left, right and tptr are NULL */
	np = copyone(op); /* ID node */
	np->n_tptr = bas_type('(');
	np->n_flags = N_COPYT;
	np->e_sc = K_EXTERN;
	new_sym(symtab, np);
	return np;
}

/* declare arg name as int */
def_arg(listpp, op)
NODE **listpp, *op;
{
	register NODEP np;
	NODEP copyone();

	np = copyone(op);
	np->n_tptr = bas_type(K_INT);
	np->n_flags = N_COPYT;
	np->e_sc = K_AUTO;
	new_sym(listpp, np);
}

/* initialize 0 or 1 thing of any type (tp) */
g_init(tp)
register NODEP tp;
{
	int nsee;
	long sz;
	int oldsize;
	int seebr = 0;

	if (cur->e_token == SCON &&
		   tp->t_token == '[' &&
		   tp->n_tptr->t_token == K_CHAR) { /* hack for SCON ary */
			nsee = out_scon(cur);
			fadvnode();
			a_fix(tp, nsee);
			return 1;
	}

	if (cur->e_token == '{') {
		fadvnode();
		seebr = 1;
	}

	switch (tp->t_token) {
	case '[':
		if (tp->t_size)
			oldsize = tp->t_size / tp->n_tptr->t_size;
		else
			oldsize = 0;
		nsee = inita(tp->n_tptr, oldsize);
		if (nsee)
			a_fix(tp, nsee);
		break;
	case K_STRUCT:
		o_aln(tp->t_aln);
		nsee = inits(tp->n_right);
		break;
	case K_UNION:
		o_aln(tp->t_aln);
		nsee = g_init(tp->n_right->n_tptr);
		if (nsee) {
			sz = tp->t_size - tp->n_right->n_tptr->t_size;
			if (sz)
				o_nz(sz, 0);
		}
		break;
	default:
		nsee = init1(tp);
		break;
	}

	if (seebr) {
		if (cur->e_token == ',')
			fadvnode();
		eat('}');
	}
	return nsee ? 1 : 0;
}

/* initialize one (or 0) scalar to an expr */
init1(tp)
register NODEP tp;
{
	NODEP xp;
	NODEP assignx();

	if (debugi) {
		printf("init1");
		printnode(tp);
	}
	xp = assignx();
	if (xp) {
		if (debugi)
			printnode(xp);
		o_vinit(tp, xp);
		return 1;
	} else
		return 0;
}

/* set array size or fill array with zeros */
a_fix(tp, nsee)
register NODEP tp;
{
	int oldsize;

	if (tp->t_size) {
		oldsize = tp->t_size / tp->n_tptr->t_size;
		if (oldsize > nsee) {
			o_nz(tp->n_tptr->t_size * (oldsize-nsee),
				tp->n_tptr->t_aln);
		} else if (oldsize < nsee) {
			error("too many init exprs");
		}
	} else
		tp->t_size = nsee * tp->n_tptr->t_size;
}

/* initialize up to max items of type tp */
/* if max is 0, any number is okay */

inita(tp, maxi)
NODEP tp;
{
	int nsee;

	nsee = g_init(tp);
	if (nsee == 0)
		return 0;

	while (cur->e_token == ',') {
		if (nsee == maxi)
			break;
		fadvnode();
		nsee += g_init(tp);
	}
	return nsee;
}

long fldoffs = -1;
int fldvalue = 0;

/* initialize (possible) structure */
inits(np)
register NODEP np;
{
	int see1;

	if (np->e_fldw)
		see1 = fld_init(np,1);
	else
		see1 = g_init(np->n_tptr);
	if (see1 == 0)
		return 0;

	while (np->n_next) {
		np = np->n_next;
		if (cur->e_token == ',') {
			fadvnode();
			if (np->e_fldw)
				see1 = fld_init(np,1);
			else {
				fld_put();
				see1 = g_init(np->n_tptr);
			}
		} else
			see1 = 0;
		if (see1 == 0)
			if (np->e_fldw)
				fld_init(np,0);
			else {
				fld_put();
				z_init(np->n_tptr);
			}
	}

	fld_put();
	return 1;
}

fld_put()
{
	if (fldoffs != -1)
		out_fi(fldvalue);
	fldoffs = -1;
}

fld_init(np, valflg)
NODEP np;
{
	NODEP xp;
	NODEP assignx();
	int val, width, woffs;
	long soffs;
	
	width = np->e_fldw;
	woffs = np->e_fldo;
	soffs = np->e_offs;

	if (valflg == 0) {
		val = 0;
	} else {
		xp = assignx();
		if (xp) {
			val = conxval(xp);
		} else {
			fld_put();
			return 0;
		}
	}

	if (soffs != fldoffs) {
		fld_put();
		fldoffs = soffs;
		fldvalue = 0;
	}

	val &= ones(width);
	val <<= woffs;
	fldvalue |= val;

	return 1;
}

z_init(tp)
register NODEP tp;
{
	switch (tp->t_token) {
	case '[':
	case K_STRUCT:
	case K_UNION:
		o_nz(tp->t_size, tp->t_aln);
		break;
	default:
		out_zi(tp);
	}
}
