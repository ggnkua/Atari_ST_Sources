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
 *	expr.c
 *
 *	Expression parse routines
 *
 *	All routines return either NULL or a valid tree
 *		binop nodes have non-null left and right
 *		unop nodes have non-null left
 *
 *	Special nodes:
 *		'(' : function call.  left:name-expr right:args 
 *		',': if part of function arg list, ival:num. descendants
 *		'?' : ?switch.  left:test-expr right:':' part
 *		  ':' : left:true-expr right:false-expr
 *		TCONV: left:convertee tptr:type-list
 *		TSIZEOF: tptr:type-list
 *
 */

#include <stdio.h>
#include "param.h"
#include "nodes.h"
#include "tok.h"

extern NODEP cur;
NODEP getnode();
NODEP opt_follow();

extern int oflags[];
#define debug oflags['x'-'a']

advnode()
{
	cur = getnode();
}

fadvnode()
{
	freenode(cur);
	cur = getnode();
}

NODEP
gete_or_ty()
{
	NODEP getexpr(), makecast();
	NODEP rv;

	if (is_ty_start()) {
		rv = makecast();
		if (debug) {
			printf("TY_X");
			printnode(rv);
		}
		return rv;
	} else
		return getexpr();
}

/* call this for any expr including comma's */
NODEP
getexpr()
{
	NODEP np, get_f_expr();

	np = get_f_expr(0);
	return np;
}

NODEP
get_f_expr(flg)
int flg;
{
	NODEP assignx();
	register NODEP op, lpart, rpart;
	int i = 0;

	lpart = assignx();
	if (lpart == NULL) {
		return NULL;
	}
	i++;
more:
	if (cur->e_token != ',')
		return lpart;

	op = cur;  advnode();
	rpart = assignx();
	if (rpart == NULL) {
		error("',' expr syntax");
		return lpart;
	}
	i++;
	op->n_left = lpart;
	op->n_right = rpart;
	op->e_type = E_BIN;
	op->e_ival = flg ? i : 0;
	lpart = op;
	if (debug) {
		printf("COMMA");
		printnode(op);
	}
	goto more;
}

/* call this if you want expr w/o comma's */
NODEP
assignx()
{
	NODEP questx();
	register NODEP op, lpart, rpart;

	lpart = questx();
	if (lpart == NULL)
		return NULL;
	if (!isassign(cur->e_token) && cur->e_token != '=')
		return lpart;
	op = cur;  advnode();
	rpart = assignx();
	if (rpart == NULL) {
		error("'=op' expr syntax");
		return lpart;
	}
	op->n_left = lpart;
	op->n_right = rpart;
	op->e_type = E_BIN;
	if (debug) {
		printf("ASSIGN");
		printnode(op);
	}
	return op;
}

/* call this if you want expr w/o assign's or comma's */
/* i.e. constant-expression */
NODEP
questx()
{
	NODEP binary();
	register NODEP holdq, holdc;
	NODEP qpart, tpart, fpart;

	qpart = binary();
	if (qpart == NULL)
		return NULL;
	if (cur->e_token != '?')
		return qpart;
	holdq = cur;  advnode();
	tpart = questx();
	if (tpart == NULL || cur->e_token != ':') {
bad:
		error("'?:' expr syntax");
		return qpart;
	}
	holdc = cur;  advnode();
	fpart = questx();
	if (fpart == NULL) goto bad;
	holdc->n_left = tpart;
	holdc->n_right = fpart;
	holdc->e_type = E_BIN;
	holdq->n_left = qpart;
	holdq->n_right = holdc;
	holdq->e_type = E_BIN;
	if (debug) {
		printf("QUEST");
		printnode(holdq);
	}
	return holdq;
}

NODEP
binary()
{
	NODEP unary(), buildbin();
	register NODEP rv, op, e2;

	rv = unary();
	if (rv == NULL)
		return NULL;
	rv->e_prec = 0;
more:
	if (cur->e_prec == 0)	/* not binary op */
		return rv;
	op = cur;  advnode();
	e2 = unary();
	if (e2 == NULL) {
		error("bin-op expr syntax");
		return rv;
	}
	e2->e_prec = 0;
	rv = buildbin(rv, op, e2);
	if (debug) {
		printf("BINARY");
		printnode(rv);
	}
	goto more;
}

NODEP
buildbin(lpart, op, upart)
NODEP lpart, op, upart;
{
	register NODEP look, tail;
	NODEP rv;

	tail = NULL;
	look = lpart;
	for (look=lpart; op->e_prec < look->e_prec; look=look->n_right)
		tail = look;
	if (tail == NULL) {
		op->n_left = lpart;
		op->n_right = upart;
		rv = op;
	} else {
		tail->n_right = op;
		op->n_left = look;
		op->n_right = upart;
		rv = lpart;
	}
	op->e_type = E_BIN;
	return rv;
}

NODEP
unary()
{
	register NODEP tp,e1;
	NODEP primary();

	if (cur->e_flags & CAN_U) {
		tp = cur;  advnode();
		if (tp->e_prec) {  /* also have BINARY op */
			tp->e_token = UNARY tp->e_token;
			strcat(tp->n_name, "U");
		}
		tp->n_left = unary();
		tp->e_type = E_UNARY;
		goto check;
	} else
	switch (cur->e_token) {
	case '(':
		fadvnode();
		tp = gete_or_ty();
		if (cur->e_token != ')') {
			error("missing )");
		} else
			fadvnode();
		if (tp == NULL)
			return NULL;
		if (tp->e_token == TCONV && tp->n_left == NULL) {
			sprintf(tp->n_name, "cast to");
			tp->n_left = unary();
			tp->e_type = E_UNARY;
		} else {
			tp = opt_follow(tp);
			goto out;
		}
		goto check;
	case K_SIZEOF:
		tp = cur;
		advnode();
		if (cur->e_token == '(') { /* may be type expr */
			fadvnode();
			e1 = gete_or_ty();
			if (cur->e_token != ')') {
				error("missing )");
			} else
				fadvnode();
		} else
			e1 = unary();
		if (e1 == NULL) {
			error("sizeof expr syntax");
			return NULL;
		}
		if (e1->e_token == TCONV) {
			freeunit(tp);
			e1->e_token = TSIZEOF;
			sprintf(e1->n_name, "T-sizeof");
			tp = e1;
			tp->e_type = E_LEAF;
			goto out;
		} else {
			tp->e_type = E_UNARY;
			tp->n_left = e1;
		}
		goto check;
	default:
		tp = primary();
		goto out;
	}
check:
	if (tp == NULL) return NULL;
	if (tp->n_left == NULL) {
		error("u-op expr syntax");
		return NULL;
	}
out:
	if (debug) {
		printf("UNARY");
		printnode(tp);
	}
	return tp;
}

NODEP
primary()
{
	register NODEP e1;

	switch (cur->e_token) {
	case ID:
	case ICON:
	case FCON:
	case SCON:
		e1 = cur;
		e1->e_type = E_LEAF;
		advnode();
		break;
	case '(':
		fadvnode();
		e1 = getexpr();
		if (cur->e_token != ')')
			error("missing )");
		else
			fadvnode();
		break;
	default:
		e1 = NULL;
	}
	if (e1 == NULL)
		return NULL;
	return opt_follow(e1);
}

NODEP
opt_follow(np)
NODEP np;
{
	register NODEP tp, e1, t2;

	switch (cur->e_token) {
	case '[':
		tp = cur;  advnode();
		e1 = getexpr();
		if (cur->e_token != ']') {
			error("missing ]");
			return np;
		} else {
			t2 = cur;  advnode();
		}
		if (e1 == NULL) {
			error("empty []");
			return np;
		}
		t2->n_left = np;
		t2->n_right = e1;
		t2->e_type = E_BIN;
		t2->e_token = '+';
		strcpy(t2->n_name, "+ [");

		tp->n_left = t2;
		tp->e_type = E_UNARY;
		tp->e_token = STAR;
		strcpy(tp->n_name, "U*");

		goto out;
	case '(':
		tp = cur;
		advnode();
		e1 = get_f_expr(1);
		if (cur->e_token != ')')
			error("expect )");
		else
			fadvnode();
		tp->n_left = np;
		tp->n_right = e1;
		tp->e_type = E_SPEC;
		goto out;
	case '.':
	case ARROW:
		tp = cur;  advnode();
		if (cur->e_token != ID) {
			error("expect ID");
			return np;
		}
		tp->n_left = np;
		tp->n_right = cur;
		tp->e_type = E_SPEC;
		if (tp->e_token == ARROW) { /* make into (*X).Y */
			tp->e_token = '.';
			strcpy(tp->n_name, ".");

			t2 = allocnode();
			t2->e_token = STAR;
			t2->n_left = np;
			t2->e_type = E_UNARY;
			strcpy(t2->n_name, "U*");

			tp->n_left = t2;	
		}
		advnode();
		goto out;
	case DOUBLE '+':
	case DOUBLE '-':
		tp = cur;  advnode();
		tp->e_token = (tp->e_token == DOUBLE '+') ? POSTINC : POSTDEC;
		strcat(tp->n_name, "post");
		tp->n_left = np;
		tp->e_type = E_UNARY;
		goto out;
	default:
		return np;
	}
out:
	return opt_follow(tp);
}

/* restricted version of unary for declarations or coertions */
/* allows NULL primary part */
NODEP
declarator()
{
	register NODEP tp,e1;
	NODEP ty_primary(), ty_follow();

	if (cur->e_token == '*') {
		tp = cur;
		tp->e_token = UNARY tp->e_token;
		strcat(tp->n_name, "U");
		advnode();
		tp->n_left = declarator();
		return tp;
	} else
	switch (cur->e_token) {
	case '(':
		tp = cur;
		advnode();
		e1 = declarator();
		if (cur->e_token != ')') {
			error("expect )");
		} else
			fadvnode();
		if (e1 == NULL) {	/* special "fun of" */
			/* left and right already NULL */
			return ty_follow(tp);
		} else {
			freeunit(tp);
			return ty_follow(e1);
		}
	default:
		return ty_primary();
	}
}

/* restricted version of primary for "declarator" */
NODEP
ty_primary()
{
	register NODEP e1;
	NODEP ty_follow();

	switch (cur->e_token) {
	case ID:
		e1 = cur;
		advnode();
		break;
	case '(':
		fadvnode();
		e1 = declarator();
		if (cur->e_token != ')')
			error("expect )");
		else
			fadvnode();
		break;
	default:
		e1 = NULL;
	}
	return ty_follow(e1);
}

/* restricted version of opt_follow for 'declarator' */
/* allow null [] */
NODEP
ty_follow(np)
NODEP np;
{
	register NODEP tp, e1;
	NODEP ty_args();

	switch (cur->e_token) {
	case '[':
		tp = cur;
		advnode();
		e1 = questx();
		if (cur->e_token != ']')
			error("expect ]");
		else
			fadvnode();
		tp->n_left = np;
		tp->n_right = e1;
		goto out;
	case '(':
		tp = cur;
		advnode();
		e1 = ty_args();	/* allow args of fun to follow */
		if (cur->e_token != ')')
			error("expect )");
		else
			fadvnode();
		tp->n_left = np;
		tp->n_right = e1;
		goto out;
	default:
		return np;
	}
out:
	return ty_follow(tp);
}

/* called for args of function declaration or NULL */
NODEP
ty_args()
{
	NODEP opt_id();
	register NODEP rv, tail, new;

	rv = opt_id();
	if (rv == NULL)
		return NULL;
	tail = rv;
more:
	if (cur->e_token != ',')
		return rv;
	fadvnode();
	new = opt_id();
	if (new == NULL) {
		error("expect as-op value");
		return rv;
	}
	tail->n_left = new;
	tail = new;
	goto more;
}

NODEP
opt_id()
{
	NODEP rv;

	if (cur->e_token == ID) {
		rv = cur;
		advnode();
		return rv;
	} else
		return NULL;
}
