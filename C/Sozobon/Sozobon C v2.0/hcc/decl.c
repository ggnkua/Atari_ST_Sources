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
 *	decl.c
 *
 *	Do all declarations
 *
 *	Currently, 
 *		struct tags are local
 *		struct members are tied to the struct
 *		enum tags are ignored
 *		enum members are local
 */

#include <stdio.h>
#include "param.h"
#include "tok.h"
#include "nodes.h"

extern NODE *cur;
extern level;

NODEP symtab[NHASH], tagtab;
extern NODE *blktab;

NODEP alltags(), allsyms(), llook(), hlook();

extern int oflags[];
#define debug	oflags['v'-'a']

/* look for global data decls
	return when see something weird
	return last ID declared */
NODEP
glb_decls()
{
	register NODEP head, xp;
	NODEP d_type(), def_type(), d_declr();
	int sclass;

	for(;;) {
		sclass = d_scl(HERE_SC);
		head = d_type();
		if (head == NULL)
			head = def_type();
		if (ok_gsh(sclass, head) == 0)
			continue;
	more:
		xp = d_declr(head,0);
		if (ok_gx(xp,head)) {
			xp->e_sc = sclass;
			opt_ginit(xp);
			new_sym(symtab,xp);
			if (xp->n_tptr->t_token == '(') {	/* func */
				if (cur->e_token == ',' ||
				    cur->e_token == ';')
					fix_fun(xp);
				else
					return xp;
			}
		}

		if (cur->e_token == ',') {
			fadvnode();
			goto more;
		}

		if (cur->e_token == ';') {
			fadvnode();
		} else
			return NULL;
	}
}

/* do local or arg decls
	return 1 if see something */
loc_decls()
{
	register NODEP head, xp;
	NODEP d_type(), def_type(), d_declr();
	int sclass;
	int regs;
	long size;
	int rv = 0;

	size = level > 2 ? blktab->n_next->b_size : 0;
	regs = level > 1 ? blktab->n_next->b_regs : 0;
	while (is_ty_start()) {
		rv++;
		sclass = d_scl(K_AUTO);
		head = d_type();
		if (head == NULL)
			head = def_type();
		if (ok_lsh(sclass, head) == 0)
			continue;
	more:
		xp = d_declr(head,0);
		if (ok_lx(xp,head)) {
			xp->e_sc = sclass;
			if (level > 1) {	/* not args */
				lc_size(&size, &regs, xp);
				out_advice(xp);
			}
			new_sym(&blktab->b_syms,xp);
			fix_fun(xp);
			if (level > 1)
				opt_linit(xp,sclass);
		}

		if (cur->e_token == ',') {
			fadvnode();
			goto more;
		}

		if (cur->e_token == ';') {
			fadvnode();
		} else {
			error("expect ;");
			return 1;
		}
	}
	while (STACKALN & size)
		size++;
	blktab->b_size = size;
	blktab->b_regs = regs;
	return rv;
}

/* Decls inside Struct/Union */
su_decls(listpp, isunion, sizep, alnp)
NODEP *listpp;
long *sizep;
char *alnp;
{
	register NODEP head, xp;
	NODEP d_type(), d_declr();
	long size;
	char aln;
	int fldw, fldoff;

	aln = 0;
	size = 0;
	fldoff = 0;
	for(;;) {
		head = d_type();
		if (head == NULL)
			goto out;
		if (ok_suh(head) == 0)
			continue;
	more:
		xp = d_declr(head,0);
		opt_field(xp,&fldw,isunion);
		if (ok_sux(xp,head)) {
			if (fldw > 0) {	/* handle field */
				su_fld(&size,&aln,xp,fldw,&fldoff);
				xp->e_offs = size;
			} else {		/* handle non-field */
				afterfld(&size,&fldoff);
				xp->e_offs = isunion ? 0 : size;
				su_size(&size,&aln,xp,isunion); 
			}
			new_sym(listpp,xp);
			listpp = &xp->n_next;
		} else if (fldw == 0) {
			afterfld(&size, &fldoff);
		}

		if (cur->e_token == ',') {
			fadvnode();
			goto more;
		}

		if (cur->e_token == ';') {
			fadvnode();
		} else
			goto out;
	}
out:
	afterfld(&size,&fldoff);
	while (aln & size)
		size++;
	*sizep = size;
	*alnp = aln;
	return;
}

/* Decls inside Enum */
en_decls()
{
	register NODEP head, xp;
	NODEP bas_type(), d_declr();
	int curval = 0;

	for(;;) {
		head = bas_type(K_INT);
	more:
		xp = d_declr(head,0);
		if (ok_enx(xp,head)) {
			opt_enval(&curval);
			xp->e_ival = curval++;
			xp->e_sc = ENUM_SC;
			new_sym(level ? blktab->b_syms : (NODE *)symtab,
				xp);
		}

		if (cur->e_token == ',') {
			fadvnode();
			goto more;
		}

		return;
	}
}

/*
 * called from expr.c, make a cast
 * only called if is_ty_start();
 */
NODE *
makecast()
{
	NODEP head, xp;
	register NODEP np;
	NODEP d_type(), d_declr(), def_type();

	head = d_type();	/* we know this is not NULL */
	xp = d_declr(head, 1);
	if (ok_cast(xp,head) == 0) {
		xp = def_type();	/* return cast to INT */
	}
	np = allocnode();
	np->e_token = TCONV;
	np->n_tptr = xp;
	if (xp == head)
		np->n_flags |= N_COPYT;
	if (debug) {
		printf("Make cast");
		printnode(np);
	}
	return np;
}

is_ty_start()
{
	NODEP rv;

	if (is_tykw(cur->e_token))
		return 1;
	if (cur->e_token == ID) {
		rv = allsyms(cur);
		if (rv && rv->e_sc == K_TYPEDEF)
			return 1;
	}
	return 0;
}

/* assemble decl and put in listpp */
new_sym(listpp, xp)
NODEP *listpp;
NODEP xp;
{
	NODEP old;

	if (xp == NULL)
		return 0;
/* put in table */
	if (debug) {
		printf("New sym sc %c", "EARTSCH"[xp->e_sc-K_EXTERN]);
		printnode(xp);
	}
	/* later look for previous definition */
	if (listpp == (NODE **)symtab) {
		old = hlook(listpp, xp);
		if (old == NULL || def2nd(old, xp))
			puthlist(listpp, xp);
	} else {
		old = llook(*listpp, xp);
		if (old == NULL || def2nd(old, xp))
			putlist(listpp, xp);
	}
	return 1;
}

/* look for storage class */
d_scl(defau)
{
	int rv;

	if (is_sclass(cur->e_token)) {
		rv = cur->e_token;
		fadvnode();
		return rv;
	}
	/* no storage class specified */
	return defau;
}

NODEP
d_declr(head, forcast)
NODEP head;
{
	NODEP e1;
	NODEP declarator(), rev_decl();
	NODEP xp, tailp;

	e1 = declarator();
	xp = rev_decl(e1, &tailp, forcast);
	if (xp) {
		tailp->n_tptr = head;
		tailp->n_flags |= N_COPYT;
		return xp;
	} else if (forcast)
		return head;
	else
		return NULL;
}

NODEP
rev_decl(np,tailpp,forcast)
NODEP np, *tailpp;
{
	NODEP rv, scan, nxt;

	rv = NULL;
	for (scan = np; scan != NULL; scan = nxt) {
		nxt = scan->n_next;
		scan->n_next = NULL;
		if (rv == NULL) {
			*tailpp = scan;
			scan->n_tptr = NULL;
			rv = scan;
		} else {
			scan->n_tptr = rv;
			rv = scan;
		}
		e_to_t(rv);
		switch (rv->t_token) {
		case UNARY '*':
			sprintf(rv->n_name, "Ptr to");
			break;
		case '(':
			sprintf(rv->n_name, "Fun ret");
			break;
		case '[':
			sprintf(rv->n_name, "Ary of");
			break;
		case ID:
			break;
		default:
			error("bad type xpr");
			return NULL;
		}
	}
	/* if normal decl and see something, must see id first */
	if (!ok_revx(rv,forcast))
		rv = NULL;
	return rv;
}

/*
 * Looking for type part of a decl
 */
NODEP
d_type()
{
	int btype, adj;
	NODEP rv;
	NODEP bas_type(), decl_su(), decl_enum();

	/* look for 'struct', 'union', 'enum' or typedef ID */
	switch (cur->e_token) {
	case ID:
		rv = allsyms(cur);
		if (rv && rv->e_sc == K_TYPEDEF) {
			fadvnode();
			rv = rv->n_tptr;
			return rv;
		}
		return NULL;
	case K_STRUCT:
		return decl_su(0);
	case K_UNION:
		return decl_su(1);
	case K_ENUM:
		return decl_enum();
	}

	/* look for modifiers 'long', 'short', 'unsigned' */
	adj = 0;
	while (is_tadj(cur->e_token)) {
		switch (cur->e_token) {
		case K_SHORT:
			adj |= SAW_SHORT;
			break;
		case K_LONG:
			adj |= SAW_LONG;
			break;
		case K_UNSIGNED:
			adj |= SAW_UNS;
			break;
		}
		fadvnode();
	}

	/* look for base type 'char', 'int', 'float', 'double', 'void'*/
	if (is_btype(cur->e_token)) {
		btype = cur->e_token;
		fadvnode();
	} else if (adj == 0)	/* saw nothing */
		return NULL;
	else
		btype = K_INT;

	if (adj)
		btype = adj_type(btype, adj);
	rv = bas_type(btype);
	return rv;
}

NODEP
decl_enum()
{
	NODEP bas_type();

	fadvnode();	/* skip 'enum' */

	if (cur->e_token == ID) {	/* ignore tag */
		fadvnode();
	}
	if (cur->e_token == '{') {	/* new declaration */
		fadvnode();	/* skip '{' */
		en_decls();	/* global scope */
		if (cur->e_token != '}')
			error("expect }");
		else
			fadvnode();	/* skip '}' */
	}
	return bas_type(K_INT);
}

NODEP
decl_su(isunion)
{
	register NODEP rv, tagp;
	NODEP *attab;
	extern lineno;

	fadvnode();	/* skip 'struct' or 'union' */

	attab = level ? &blktab->b_tags : &tagtab;
	tagp = NULL;
	if (cur->e_token == ID) {	/* hold on to ID node */
		tagp = cur;
		e_to_t(tagp);
		advnode();
		nnmadd(tagp, isunion ? ".U" : ".S");
	}
	if (cur->e_token == '{') {	/* new declaration */
		if (tagp == NULL) {	/* make fake name */
			tagp = allocnode();
			sprintf(tagp->n_name, isunion ? "%dU" : 
					"%dS", lineno);
		}
		fadvnode();	/* skip '{' */
		if (rv = llook(*attab, tagp)) {
			freenode(tagp);
			if (rv->n_right) {
				errors("struct redefined", rv->n_name);
				freenode(rv->n_right);
				rv->n_right = NULL;
			}
		} else {		/* new defn */
			rv = tagp;
			rv->t_token = isunion ? K_UNION : K_STRUCT;
			rv->n_flags |= N_BRKPR;	/* break print loops */
			putlist(attab, rv);
		}
		su_decls(&rv->n_right, isunion,
				&rv->t_size, &rv->t_aln);
		if (cur->e_token != '}')
			error("expect }");
		else
			fadvnode();	/* skip '}' */
	} else {		/* reference to old */
		if (tagp == NULL) {
			error("nonsense struct");
			goto out;
		}
		/* ANSI special decl
			struct <tag> ;
		   for hiding old tag within block */
		if (cur->e_token == ';' && level)
			rv = llook(*attab, tagp);
		else
			rv = alltags(tagp);
		if (rv == NULL) {	/* delayed tag */
			rv = tagp;
			rv->t_token = isunion ? K_UNION : K_STRUCT;
			rv->n_flags |= N_BRKPR;	/* break print loops */
			putlist(attab, rv);
			goto out;
		} else
			freenode(tagp);
	}
out:
	return rv;
}

NODE *
alltags(np)
NODE *np;
{
	register NODE *bp;
	NODE *rv;

	for (bp=blktab; bp != NULL; bp = bp->n_next)
		if ((rv = llook(bp->b_tags, np)) != NULL)
			return rv;
	return llook(tagtab, np);
}

NODE *
allsyms(np)
NODE *np;
{
	register NODE *bp;
	NODE *rv;

	for (bp=blktab; bp != NULL; bp = bp->n_next)
		if ((rv = llook(bp->b_syms, np)) != NULL)
			return rv;
	return hlook(symtab, np);
}

sim_type(a,b)
register NODE *a, *b;
{
more:
	if (a == b)
		return 1;
	if (a == NULL || b == NULL)
		return 0;
	if (a->t_token != b->t_token)
		return 0;
	if (a->t_size != b->t_size && a->t_size && b->t_size)
		return 0;
	a = a->n_tptr;
	b = b->n_tptr;
	goto more;
}

/* 2nd def of same name at same level */
/* OK if one extern and types the same */
def2nd(old,new)
NODEP old, new;
{
	int osc, nsc;

	if (sim_type(old->n_tptr, new->n_tptr) == 0)
		goto bad;
	osc = old->e_sc;
	nsc = new->e_sc;
	if (nsc == K_EXTERN) {	/* works only if no further use allowed */
		freenode(new);
		return 0;
	}
	if (osc == K_EXTERN) {
		/* replace old def with new one */
		/* for now, just put new one on list too */
		return 1;
	}
bad:
	errorn("bad 2nd decl of ", new);
	/* use 2nd def so other stuff works */
	return 1;
}

/* saw fun but no body */
fix_fun(np)
NODE *np;
{
	if (np == NULL) return;
	if (np->n_tptr->t_token == '(') {	/* fix to extern */
		if (np->e_sc != K_TYPEDEF)
			np->e_sc = K_EXTERN;
	}
}

e_to_t(np)
NODE *np;
{
	int token;

	token = np->e_token;
	np->t_token = token;
	np->t_size = 0;
	np->t_aln = 0;
}
