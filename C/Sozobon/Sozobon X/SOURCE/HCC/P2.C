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
 *	p2.c
 *
 *	Expression tree routines.
 *
 *	Constant folding, typing of nodes, simple transformations.
 */

#include <stdio.h>
#include "param.h"
#include "tok.h"
#include "nodes.h"
#include "cookie.h"

#if MMCC
overlay "pass2"
#endif

extern int xflags[];
#define debug xflags['t'-'a']

extern nmerrors;
NODEP bas_type();
long convalue;

do_expr(np, cookie)
NODE *np;
{
	if (np == NULL)
		return;
/*	include if want only one error at a time
	if (nmerrors) {
		freenode(np);
		return;
	}
*/
	p2_expr(&np);
	genx(np, cookie);
}

p2_expr(npp)
NODEP *npp;
{
	NODEP np = *npp;

	if (np == NULL) return;
	if (debug > 1) {
		printf("P2 enter");
		printnode(np);
	}
	confold(npp,0);
	np = *npp;
	form_types(np);
	if (debug) {
		printf("p2_expr");
		printnode(np);
	}
	return;
}

form_types(np)
NODEP np;
{

	if (np == NULL) return;
	switch (np->e_type) {
	case E_SPEC:
		switch (np->e_token) {	/* special cases */
		case '.':
		case ARROW:
			form_types(np->n_left);
			sel_type(np);
			return;
		case '(':
			if (np->n_right) {
				form_types(np->n_right);	/* args */
				np->e_type = E_BIN;
			} else
				np->e_type = E_UNARY;
			fun_type(np);
			return;
		}
		/* fall through */
	case E_BIN:
		form_types(np->n_left);
		form_types(np->n_right);
		b_types(np);
		break;

	case E_UNARY:
		form_types(np->n_left);
		u_types(np);
		break;

	case E_LEAF:
		l_types(np);
		break;
	}
}

/* (fun) (args) */
fun_type(np)
NODEP np;
{
	NODEP lp, typ;
	NODEP allsyms(), new_fun();

	lp = np->n_left;
	if (lp->e_token == ID) { /* may be new ID */
		typ = allsyms(lp);
		if (typ == NULL)
			typ = new_fun(lp);
		typ = typ->n_tptr;
		lp->n_tptr = typ;
		lp->n_flags |= N_COPYT;
	} else {
		form_types(lp);
		typ = lp->n_tptr;
	}
	if (typ->t_token != '(') {	/* fun ret ? */
		error("call non-fun");
		goto bad;
	}
	typ = typ->n_tptr;
	goto good;
bad:
	typ = bas_type(K_INT);
good:
	np->n_tptr = typ;
	np->n_flags |= N_COPYT;
}

/* (struct|union) (. or ->) ID */
sel_type(xp)
NODEP xp;
{
	NODEP np, sup;
	int tok;
	NODEP rv;
	NODEP llook();

	np = xp->n_right;
	sup = xp->n_left->n_tptr;
	tok = xp->e_token;

/* already checked that np->e_token == ID */
	if (tok == ARROW) {
		if (sup->t_token != STAR) {
			error("(non pointer)->");
			goto bad;
		}
		sup = sup->n_tptr;
	}
	if (sup->t_token != K_STRUCT && sup->t_token != K_UNION) {
		error("select non-struct");
		goto bad;
	}
	rv = llook(sup->n_right, np);
	if (rv == NULL) {
		error("? member ID");
		goto bad;
	}
	xp->e_offs = rv->e_offs;
	if (rv->e_fldw) {
		xp->e_fldw = rv->e_fldw;
		xp->e_fldo = rv->e_fldo;
	}
	rv = rv->n_tptr;
	goto good;
bad:
	rv = bas_type(K_INT);
good:
	xp->n_tptr = rv;
	xp->n_flags |= N_COPYT;

	/* change to UNARY op */
	xp->e_type = E_UNARY;
	freenode(np);
	xp->n_right = NULL;

	/* change ARY OF to PTR TO */
	if (rv->t_token == '[')
		see_array(xp);
}

l_types(np)
register NODE *np;
{
	NODEP allsyms();
	register NODE *tp;

	switch (np->e_token) {
	case ID:	/* already did see_id */
		if (np->n_tptr->t_token == '[')	/* change to &ID */
			see_array(np);
		return;
	case ICON:
		tp = bas_type(icon_ty(np));
		break;
	case FCON:
		tp = bas_type(K_DOUBLE);
		break;
	case SCON:
		tp = bas_type(SCON);
		break;
	default:
		errors("Weird leaf",np->n_name);
	bad:
		tp = bas_type(K_INT);
	}
	np->n_tptr = tp;
	np->n_flags |= N_COPYT;
}

u_types(np)
NODEP np;
{
	NODEP tp;
	NODEP lp = np->n_left;
	NODEP normalty();

	tp = lp->n_tptr;	/* default */

	switch (np->e_token) {
	case DOUBLE '+':
	case DOUBLE '-':
	case POSTINC:
	case POSTDEC:
		mustlval(lp);
		mustty(lp, R_SCALAR);
		if (tp->t_token == STAR)
			np->e_offs = tp->n_tptr->t_size;
		else
			np->e_offs = 1;
		break;
	case STAR:
		if (mustty(lp, R_POINTER)) goto bad;
		tp = tp->n_tptr;
		np->n_tptr = tp;
		np->n_flags |= N_COPYT;

		/* Ary of to Ptr to */
		if (tp->t_token == '[')
			see_array(np);
		return;
	case UNARY '&':
		mustlval(lp);
		tp = allocnode();
		tp->n_tptr = lp->n_tptr;
		tp->n_flags |= N_COPYT;
		tp->t_token = STAR;
		sprintf(tp->n_name, "Ptr to");
		tp->t_size = SIZE_P;
		np->n_tptr = tp;
		return;		/* no COPYT */
	case UNARY '-':
		mustty(lp, R_ARITH);
		tp = normalty(lp, NULL);
		break;
	case TCONV:
		if (np->n_tptr->t_token != K_VOID) {
			mustty(lp, R_SCALAR);
			mustty(np, R_SCALAR);
		}
		return;		/* type already specified */
	case '!':
		mustty(lp, R_SCALAR);
		tp = bas_type(K_INT);
		break;
	case '~':
		mustty(lp, R_INTEGRAL);
		tp = normalty(lp, NULL);
		break;
	default:
		error("bad unary type");
	bad:
		tp = bas_type(K_INT);
	}
	np->n_tptr = tp;
	np->n_flags |= N_COPYT;
}

b_types(np)
NODEP np;
{
	NODEP tp;
	NODEP lp, rp;
	NODEP normalty(), addty(), colonty();
	int op;

	op = np->e_token;
	if (isassign(op)) {
		mustlval(np->n_left);
		op -= (ASSIGN 0);
	}

	lp = np->n_left;
	rp = np->n_right;
	tp = bas_type(K_INT);
	switch (op) {
	case '*':
	case '/':
		mustty(lp, R_ARITH);
		mustty(rp, R_ARITH);
		tp = normalty(lp,rp);
		break;
	case '%':
	case '&':
	case '|':
	case '^':
		mustty(lp, R_INTEGRAL);
		mustty(rp, R_INTEGRAL);
		tp = normalty(lp,rp);
		break;
	case '+':
	case '-':
		mustty(lp, R_SCALAR);
		mustty(rp, R_SCALAR);
		tp = addty(np);
		break;
	case DOUBLE '<':
	case DOUBLE '>':
		mustty(lp, R_INTEGRAL);
		mustty(rp, R_INTEGRAL);
		tp = normalty(lp, NULL);
		break;
	case '<':
	case '>':
	case LTEQ:
	case GTEQ:
	case DOUBLE '=':
	case NOTEQ:
		mustty(lp, R_SCALAR);
		mustty(rp, R_SCALAR);
		chkcmp(np);
		break;		/* INT */
	case DOUBLE '&':
	case DOUBLE '|':
		mustty(lp, R_SCALAR);
		mustty(rp, R_SCALAR);
		break;		/* INT */
	case '?':
		mustty(lp, R_SCALAR);
		tp = rp->n_tptr;
		break;
	case ':':
		if (same_type(lp->n_tptr, rp->n_tptr)) {
			tp = lp->n_tptr;
			break;
		}
		mustty(lp, R_SCALAR);
		mustty(rp, R_SCALAR);
		tp = colonty(np);
		break;
	case '=':
		mustlval(lp);
		mustty(lp, R_ASSN);
		asn_chk(lp->n_tptr, rp);
		tp = lp->n_tptr;
		break;
	case ',':
		tp = rp->n_tptr;
		break;
	default:
		error("bad binary type");
	bad:
		tp = bas_type(K_INT);
	}
	if (isassign(np->e_token)) {
		/* ignore normal result -- result is left type */
		tp = lp->n_tptr;
	}
	np->n_tptr = tp;
	np->n_flags |= N_COPYT;
}

long
conlval(np)
NODEP np;
{
	long i;

	confold(&np,0);
	if (np->e_token == ICON) {
		i = np->e_ival;
		freenode(np);
		return i;
	}
	/* try the code generation */
	form_types(np);
	genx(np, FORVALUE);
	return convalue;
}

conxval(np)
NODEP np;
{
	return (int)conlval(np);
}

confold(npp,spec)
NODEP *npp;
{
	NODEP np;
	NODEP tp, onp;
	int tok,spl,spr;
	long l;

	np = *npp;
	if (np == NULL) return;
	switch (np->e_type) {
	case E_LEAF:
			lcanon(np,spec);
			return;
	case E_UNARY:
			confold(&np->n_left,0);
			ucanon(np);
			return;
	case E_BIN:
			confold(&np->n_left,0);
	/* delay confold on the right tree */
			switch (np->e_token) {
			case DOUBLE '|':
				l = np->n_left->e_ival;
				tp = np;
				goto l_or_r;
			case DOUBLE '&':
				l = ! np->n_left->e_ival;
				tp = np;
				goto l_or_r;
			case '?':
				l = np->n_left->e_ival;
				tp = np->n_right;	/* ':' node */
		l_or_r:
				tok = np->n_left->e_token;
				if (tok != ICON) {
					confold(&np->n_right,0);
					return;
				}
				onp = np;
				if (l) {	/* take true side */
					np = tp->n_left;
					tp->n_left = NULL;
				} else {	/* take false side */
					np = tp->n_right;
					tp->n_right = NULL;
				}
				freenode(onp);
				confold(&np,0);
				*npp = np;
				return;
			}
			confold(&np->n_right,0);
			bcanon(np);
			if (np->e_flags & C_AND_A)
				b_assoc(np);
			return;
	case E_SPEC:
		tok = np->e_token;
		spl = spr = 0;
		switch (tok) {
		case '(':
			spl = tok;	/* new name allowed */
			break;
		case '.':
		case ARROW:
			spr = tok;	/* look in struct sym.tab. */
			break;
		}
		confold(&np->n_left,spl);
		confold(&np->n_right,spr);
		return;
	}
}

newicon(np,x,nf)
NODE *np;
long x;
{
	np->e_token = ICON;
	np->e_ival = x;
	np->e_flags = nf;
	sprintf(np->n_name, "%ld", x);
	np->e_type = E_LEAF;
	if (np->n_left) {
		freenode(np->n_left);
		np->n_left = NULL;
	}
	if (np->n_right) {
		freenode(np->n_right);
		np->n_right = NULL;
	}
}

newfcon(np,x,nf)
NODE *np;
double x;
{
	np->e_token = FCON;
	np->e_fval = x;
	np->e_flags = nf;
	sprintf(np->n_name, FLTFORM, x);
	np->e_type = E_LEAF;
	if (np->n_left) {
		freenode(np->n_left);
		np->n_left = NULL;
	}
	if (np->n_right) {
		freenode(np->n_right);
		np->n_right = NULL;
	}
}

/* LEAF */
/* sptok is token if E_SPEC node is parent
   and dont want to look at ID yet */
lcanon(np,sptok)
NODE *np;
{
	NODE *tp;
	NODEP allsyms();
	long x;

	if (np->e_token == ID) {
		if (sptok)
			return;
		see_id(np);
		return;
	}
	if (np->e_token == TSIZEOF) {
		tp = np->n_tptr;
		x = tp->t_size;
		np->n_tptr = NULL;
		if ((np->n_flags & N_COPYT) == 0)
			freenode(tp);
		newicon(np, x, 0);
	}
}

/* UNARY */
ucanon(np)
NODE *np;
{
	NODE *tp;
	long x,l;
	int lflags = 0;

	if (np->e_token == K_SIZEOF) {
		tp = np->n_left;
		confold(&tp,0);
		form_types(tp);
		tp = tp->n_tptr;
		x = tp->t_size;
		goto out;
	}

	if (np->n_left->e_token == FCON) {
		if (np->e_token == UNARY '-')
			newfcon(np, -(np->n_left->e_fval));
		return;
	}
	if (np->n_left->e_token != ICON)
		return;
	l = np->n_left->e_ival;
	lflags = np->n_left->e_flags;
	switch (np->e_token) {
	case UNARY '-':
			x = -l;		break;
	case '~':
			x = ~l;		break;
	case '!':
			x = !l;		break;
	default:
		return;
	}
out:
	newicon(np, x, lflags);
}

bcanon(np)
register NODE *np;
{
	int ltok, rtok;
	double l,r;
	NODEP tp;

	ltok = np->n_left->e_token;
	rtok = np->n_right->e_token;
	if (ltok != ICON && ltok != FCON)
		return;
	if (rtok != ICON && rtok != FCON) {
	/* left is ?CON, right is not */
		if (np->e_flags & (C_AND_A|C_NOT_A)) {
		/* reverse sides  - put CON on right */
			tp = np->n_left;
			np->n_left = np->n_right;
			np->n_right = tp;
			if (np->e_flags & C_NOT_A)
				swt_op(np);
		}
		return;
	}
	if (ltok == ICON && rtok == ICON) {
		b2i(np);
		return;
	}
	if (ltok == FCON)
		l = np->n_left->e_fval;
	else
		l = (double)np->n_left->e_ival;
	if (rtok == FCON)
		r = np->n_right->e_fval;
	else
		r = (double)np->n_right->e_ival;
	b2f(np,l,r);
}

/* canon for assoc. & comm. op */
/* this code will almost never be executed, but it was fun. */
b_assoc(np)
NODEP np;
{
	NODEP lp, rp;
	int tok;

	lp = np->n_left;
	if (lp->e_token != np->e_token)
		return;
	/* left is same op as np */
	rp = np->n_right;
	tok = lp->n_right->e_token;
	if (tok != ICON && tok != FCON)
		return;
	/* left.right is ?CON */
	tok = rp->e_token;
	if (tok == ICON || tok == FCON) {
		/* have 2 CONS l.r and r -- put together on r */
		NODEP	ep;
		ep = lp->n_left;
		np->n_left = ep;
		np->n_right = lp;
		lp->n_left = rp;
		/* can now fold 2 CONS */
		bcanon(lp);
	} else {
		/* have 1 CON at l.r -- move to top right */
		NODEP	kp;
		kp = lp->n_right;
		lp->n_right = rp;
		np->n_right = kp;
	}
}

/* switch pseudo-commutative op */
swt_op(np)
NODEP np;
{
	int newtok;
	char *newnm;

	switch (np->e_token) {
	case '<':	newtok = '>';	newnm = ">";	break;
	case '>':	newtok = '<';	newnm = "<";	break;
	case LTEQ:	newtok = GTEQ;	newnm = ">=";	break;
	case GTEQ:	newtok = LTEQ;	newnm = "<=";	break;
	default:
		return;
	}
	np->e_token = newtok;
	strcpy(np->n_name, newnm);
}

/* BINARY 2 ICON's */
b2i(np)
register NODE *np;
{
	register long l,r,x;
	int newflags,lflags;

	newflags = 0;

	r = np->n_right->e_ival;
	newflags = np->n_right->e_flags;

	l = np->n_left->e_ival;
	lflags = np->n_left->e_flags;
	newflags = newflags>lflags ? newflags : lflags;

	switch (np->e_token) {
	case '+':
			x = l+r;	break;
	case '-':
			x = l-r;	break;
	case '*':
			x = l*r;	break;
	case '/':
			x = l/r;	break;
	case '%':
			x = l%r;	break;
	case '>':
			x = l>r;	break;
	case '<':
			x = l<r;	break;
	case LTEQ:
			x = l<=r;	break;
	case GTEQ:
			x = l>=r;	break;
	case DOUBLE '=':
			x = l==r;	break;
	case NOTEQ:
			x = l!=r;	break;
	case '&':
			x = l&r;	break;
	case '|':
			x = l|r;	break;
	case '^':
			x = l^r;	break;
	case DOUBLE '<':
			x = l<<r;	break;
	case DOUBLE '>':
			x = l>>r;	break;
	default:
		return;
	}
	newicon(np, x, newflags);
}

/* BINARY 2 FCON's */
b2f(np,l,r)
register NODE *np;
double l,r;
{
	register double x;
	int ix, isint;

	isint = 0;

	switch (np->e_token) {
	case '+':
			x = l+r;	break;
	case '-':
			x = l-r;	break;
	case '*':
			x = l*r;	break;
	case '/':
			x = l/r;	break;
	case '>':
			ix = l>r;	isint++;	break;
	case '<':
			ix = l<r;	isint++;	break;
	case LTEQ:
			ix = l>=r;	isint++;	break;
	case GTEQ:
			ix = l<=r;	isint++;	break;
	case DOUBLE '=':
			ix = l==r;	isint++;	break;
	case NOTEQ:
			ix = l!=r;	isint++;	break;
	default:
		return;
	}
	if (isint)
		newicon(np, (long)ix, 0);
	else
		newfcon(np, x);
}

same_type(a,b)
register NODE *a, *b;
{
more:
	if (a == b)
		return 1;
	if (a == NULL || b == NULL)
		return 0;
	if (a->t_token != b->t_token)
		return 0;
	if (a->t_token != STAR && a->t_size != b->t_size)
		return 0;
	a = a->n_tptr;
	b = b->n_tptr;
	goto more;
}

see_id(np)
NODEP np;
{
	NODEP tp;
	NODEP allsyms(), def_type();

	tp = allsyms(np);
	if (tp == NULL) {
		errorn("undefined:", np);
		tp = def_type();
		goto out;
	}
	switch (tp->e_sc) {
	case ENUM_SC:
		newicon(np, tp->e_ival, 0);
		return;
	case K_REGISTER:
		np->e_rno = tp->e_rno;
		/* fall through */
	default:
		np->e_sc = tp->e_sc;
		np->e_offs = tp->e_offs;
		tp = tp->n_tptr;
	}
out:
	np->n_tptr = tp;
	np->n_flags |= N_COPYT;

	/* special conversions */
	if (tp->t_token == '(')
		insptrto(np);
}

insptrto(np)
NODEP np;
{
	NODEP op, copyone();

	op = copyone(np);

	np->n_left = op;
	np->e_token = UNARY '&';
	np->e_type = E_UNARY;
	strcpy(np->n_name, "&fun");
	np->n_flags &= ~N_COPYT;
}

/* np points to ID or STAR or '.' node
	tptr is a COPY
	tptr token is '[' */

see_array(np)
NODEP np;
{
	NODEP tp, copyone();

	tp = copyone(np);
	tp->n_left = np->n_left;
	tp->n_tptr = tp->n_tptr->n_tptr;

	np->n_left = tp;
	np->e_token = UNARY '&';
	np->e_type = E_UNARY;
	strcpy(np->n_name, "&ary");
	arytoptr(np);
/* leave old size
	np->n_tptr->t_size = SIZE_P;
*/
}
