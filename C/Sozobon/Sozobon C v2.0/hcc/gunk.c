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
 *	gunk.c
 *
 *	Transformations on expression trees
 *	Most of this stuff is because we cant handle
 *	floats, long mul/div, or fields directly.
 */

#include <stdio.h>
#include "param.h"
#include "bstok.h"
#include "tytok.h"
#include "flags.h"
#include "nodes.h"
#include "gen.h"

NODEP copyone();

#define gwiden(x)	((x)==1 ? 2 : (x))
#define isfield(np)	((np)->g_token == '.' && (np)->g_fldw)

NODEP npar1, npar2, npar3;
char *spar1, *spar2, *spar3;
int ipar1, ipar2, ipar3;

struct rule {
	int (*match)();		/* test for transformation needed */
	int (*rewri)();		/* rewrite function */
};

int m_unfold(), unfold(), m_cast(), cast(), m_inline(), inline();
int m_hardas(), hardas(), m_fcmp(), fcmp(), m_md_shf(), md_shf();
int m_eident(), eident(), m_incdec(), incdec(), m_fldas(), fldas();

struct rule gunktbl[] = {
	{m_unfold, unfold},
	{m_cast, cast},
	{m_md_shf, md_shf},
	{m_eident, eident},
	{m_incdec, incdec},
	{m_hardas, hardas},
	{m_inline, inline}, /* must cast before inline */
	{m_fcmp, fcmp},
	{m_fldas, fldas},
	{0}
};

int anygunk;

gunk(np)
NODEP np;
{
	do {
		anygunk = 0;
		gunks(np);
	} while (anygunk);
}

gunks(np)
register NODEP np;
{
	switch (np->g_type) {
	case E_BIN:
		gunks(np->n_right);
	case E_UNARY:
		gunks(np->n_left);
	}
	gunk1(np);
}

gunk1(np)
NODEP np;
{
	register struct rule *p;

	for (p=gunktbl; p->match; p++)
		if ((*p->match)(np)) {
			anygunk++;
			(*p->rewri)(np);
			return;
		}
}

/*
 *	Change pointer arithmetic to equivalent trees
 *		(main thing is to mult or div by object size)
 */
m_unfold(np)
NODEP np;
{
	switch (np->g_token) {
	case PTRADD:
		ipar1 = '+';
		return 1;
	case PTRSUB:
		ipar1 = '-';
		return 1;
	case PTRDIFF:
		ipar1 = 0;
		return 1;
	case ASSIGN PTRADD:
		ipar1 = ASSIGN '+';
		return 1;
	case ASSIGN PTRSUB:
		ipar1 = ASSIGN '-';
		return 1;
	}
	return 0;
}

unfold(np)
NODEP np;
{
	if (ipar1) {
		ins_mul(np, np->g_offs);
		np->g_token = ipar1;
	} else {
		ins_div(np, np->g_offs);
	}
}

NODEP
newgcon(kon, ty, sz)
long kon;
{
	register NODEP kp;

	kp = allocnode();
	kp->g_token = ICON;
	sprintf(kp->n_name, "%ld", kon);
	kp->g_offs = kon;
	kp->g_type = E_LEAF;
	kp->g_ty = ty;
	kp->g_sz = sz;
	return kp;
}

ins_mul(np, kon)
NODEP np;
long kon;
{
	NODEP rp = np->n_right;
	register NODEP mp, kp;

	if (kon == 1)
		return;
	if (rp->g_token == ICON) {
		rp->g_offs *= kon;
		rp->g_sz = gwiden(rp->g_sz);
		return;
	}

	mp = allocnode();
	mp->g_token = '*';
	sprintf(mp->n_name, "p*");
	mp->g_type = E_BIN;
	mp->g_ty = rp->g_ty;
	mp->g_sz = gwiden(rp->g_sz);

	kp = newgcon(kon, mp->g_ty, mp->g_sz);

	mp->n_right = kp;
	mp->n_left = np->n_right;
	np->n_right = mp;
}

ins_div(np, kon)
register NODEP np;
long kon;
{
	register NODEP tp, kp;

	kp = newgcon(kon, np->g_ty, np->g_sz);

	tp = copyone(np);
	tp->g_token = '-';
	tp->n_left = np->n_left;
	tp->n_right = np->n_right;
	tp->g_sz = SIZE_P;
	tp->g_ty = ET_U;

	np->n_left = tp;
	np->n_right = kp;
	np->g_type = E_BIN;
	np->g_token = '/';
	sprintf(np->n_name, "p/");
}

#define CAST_LN	1
#define CAST_RN 2
#define CAST_LLONG	3

/*
 *	Insert needed (implied) casts
 */
m_cast(np)
NODEP np;
{
	NODEP lp = np->n_left;

	switch (np->g_type) {
	case E_LEAF:
		return 0;
	case E_BIN:
		return bm_cast(np);
	}
	/* must be unary */
	switch (np->g_token) {
	case UNARY '-':
	case '~':
		return castup(lp, np, CAST_LN);
	case TCONV:
		return fcastlong(np);
	}
	return 0;
}

bm_cast(np)
register NODEP np;
{
	NODEP lp = np->n_left, rp = np->n_right;

	if (isassign(np->g_token)) {
		if (castup(rp, lp, CAST_RN))
			return 1;
		if (castmagic(rp, lp, CAST_RN, np->g_token - (ASSIGN 0)))
			return 1;
		return 0;
	}

	switch (np->g_token) {
	case '=':
		if (np->g_ty == ET_A)
			return 0;
		return castany(rp, lp, CAST_RN);

	case '<':
	case '>':
	case DOUBLE '=':
	case NOTEQ:
	case LTEQ:
	case GTEQ:
		if (castup(lp, rp, CAST_LN))
			return 1;
		return castup(rp, lp, CAST_RN);

	case '(':
	case ',':
	case '?':
	case DOUBLE '&':
	case DOUBLE '|':
		return 0;

	case DOUBLE '<':
	case DOUBLE '>':
		if (castup(lp, np, CAST_LN))
			return 1;
		return castany(rp, np, CAST_RN);

	default:
		if (castup(lp, np, CAST_LN))
			return 1;
		return castup(rp, np, CAST_RN);
	}
	return 0;
}

fcastlong(np)
NODEP np;
{
	NODEP lp = np->n_left;

	if (red_con(lp))
		return 0;
	if (np->g_ty == ET_F && lp->g_ty != ET_F && lp->g_sz != SIZE_L) {
		ipar1 = CAST_LLONG;
		return 1;
	}
	if (lp->g_ty == ET_F && np->g_ty != ET_F && np->g_sz != SIZE_L) {
		ipar1 = CAST_LLONG;
		return 1;
	}
	return 0;
}

castup(lowp, hip, par)
NODEP lowp, hip;
{
	if (stronger(hip, lowp)) {
		ipar1 = par;
		npar1 = hip;
		return 1;
	}
	return 0;
}

castmagic(p1, p2, par, tok)
NODEP p1, p2;
{
	if (xstronger(p1,p2) && magicop(tok)) {
		ipar1 = par;
		npar1 = p2;
		return 1;
	}
	return 0;
}

castany(p1, p2, par)
NODEP p1, p2;
{
	if (p1->g_sz != p2->g_sz ||
		((p1->g_ty == ET_F) != (p2->g_ty == ET_F))) {
		ipar1 = par;
		npar1 = p2;
		return 1;
	}
	return 0;
}

cast(np)
NODEP np;
{
	switch (ipar1) {
	case CAST_LN:
		castsub(npar1->g_ty, npar1->g_sz, &np->n_left, np->n_left);
		break;
	case CAST_RN:
		castsub(npar1->g_ty, npar1->g_sz, &np->n_right, np->n_right);
		break;
	case CAST_LLONG:
		castsub(ET_S, SIZE_L, &np->n_left, np->n_left);
		break;
	}
}

castsub(ty, sz, npp, np)
NODEP *npp, np;
{
	register NODEP tp;

	/* ICON cast optimization */
	if (np->g_token == ICON &&
	    np->g_ty == ty &&
	    np->g_sz < sz) {
		np->g_sz = sz;
		return;
	}

	tp = allocnode();
	tp->g_token = TCONV;
	strcpy(tp->n_name, "cast up");
	tp->n_left = np;
	*npp = tp;
	tp->g_sz = sz;
	tp->g_ty = ty;
	tp->g_type = E_UNARY;
}

/*
 *	Change stuff computer cant do to calls to inline functions
 *	(in this case, all floats and long *%/)
 */
m_inline(np)
NODEP np;
{
	int isfloat, isuns;

	if (np->g_type == E_LEAF)
		return 0;

	if (np->g_ty == ET_A)
		return 0;
	isfloat = (np->g_ty == ET_F);
	isuns = (np->g_ty == ET_U);

	if (np->g_type == E_UNARY) {
		switch (np->g_token) {
		case UNARY '-':
			if (!isfloat) return 0;
			spar1 = "%fpneg";
			return 1;
		case TCONV:
			if ((np->n_left->g_ty == ET_F) == isfloat)
				return 0;
			if (red_con(np->n_left))
				return 0;
			spar1 = isfloat ? "fpltof" : "fpftol";
			return 1;
		}
		return 0;
	}

	if (np->g_sz != 4)	/* longs or floats only */
		return 0;

	switch (np->g_token) {
	case '*':
		spar1 = isfloat ? "%fpmul" : (isuns ? "%lmulu" : "%lmul");
		return 1;
	case '/':
		spar1 = isfloat ? "%fpdiv" : (isuns ? "%ldivu" : "%ldiv");
		return 1;
	case '+':
		if (!isfloat) return 0;
		spar1 = "%fpadd";
		return 1;
	case '-':
		if (!isfloat) return 0;
		spar1 = "%fpsub";
		return 1;
	case '%':
		spar1 = isuns ? "%lremu" : "%lrem";
		return 1;
	}
	return 0;
}

inline(np)
NODEP np;
{
	register NODEP nmp, cmap;
	int isunary;

	isunary = (np->g_type == E_UNARY);

	if (isunary) {
		np->n_right = np->n_left;
		np->g_type = E_BIN;
	} else {
		cmap = copyone(np);
		cmap->n_left = np->n_left;
		cmap->n_right = np->n_right;
		np->n_right = cmap;

		cmap->g_token = ',';
		cmap->g_offs = 2;
		strcpy(cmap->n_name, ",inl");
	}

	nmp = allocnode();
	np->n_left = nmp;

	np->g_token = '(';
	strcpy(np->n_name, "inline");

	nmp->g_token = ID;
	strcpy(nmp->n_name, spar1);
#ifdef OUT_AZ
	strcat(nmp->n_name, "#");
#endif
}

/*
 *	Transform hard ++,-- to equivalent trees
 *	(for us, floats or fields)
 */
m_incdec(np)
NODEP np;
{
	if (np->g_type != E_UNARY)
		return 0;
	if (np->g_ty != ET_F && !isfield(np->n_left))
		return 0;

	ipar2 = 0;
	switch (np->g_token) {
	case DOUBLE '+':
		ipar1 = ASSIGN '+';
		spar1 = "+=";
		break;
	case DOUBLE '-':
		ipar1 = ASSIGN '-';
		spar1 = "-=";
		break;
	case POSTINC:
		ipar1 = DOUBLE '+';
		spar1 = "++";
		ipar2 = '-';
		spar2 = "-";
		break;
	case POSTDEC:
		ipar1 = DOUBLE '-';
		spar1 = "--";
		ipar2 = '+';
		spar2 = "+";
		break;
	default:
		return 0;
	}
	return 1;
}

incdec(np)
register NODEP np;
{
	NODEP t1;
	NODEP onep;

	onep = newgcon(1L, ET_S, SIZE_I);

	if (ipar2 == 0) {		/* easy case, ++X becomes X+=1 */
		np->g_token = ipar1;
		np->g_type = E_BIN;
		np->n_right = onep;
		strcpy(np->n_name, spar1);
		return;
	}

	/* hard case, X++ becomes (++X - 1) */
	t1 = copyone(np);
	t1->n_left = np->n_left;
	np->n_left = t1;
	np->n_right = onep;
	np->g_type = E_BIN;
	np->g_token = ipar2;
	strcpy(np->n_name, spar2);

	t1->g_token = ipar1;
	strcpy(t1->n_name, spar1);
}

/*
 *	Transform hard op= trees to equivalent '=' trees
 *	(in this case, all floats, long or char *%/, fields)
 */
m_hardas(np)
NODEP np;
{
	int op;

	if (np->g_type != E_BIN)
		return 0;
	op = np->g_token;
	if (isassign(op))
		op -= ASSIGN 0;
	else
		return 0;
	if (xstronger(np->n_right, np->n_left) &&
		magicop(op) == 0)
		return 1;
	if (np->g_ty == ET_F || isfield(np->n_left))
		return 1;
	if (np->g_sz == 4 || np->g_sz == 1)
		switch (op) {
		case '*':
		case '/':
		case '%':
			return 1;
		}
	return 0;
}

hardas(np)
NODEP np;
{
	NODEP opp, newl;
	NODEP copynode();

	if (m_vhard(np)) {
		vhard(np);
		return;
	}

	opp = copyone(np);
	newl = copynode(np->n_left);
	opp->n_right = np->n_right;
	np->n_right = opp;
	opp->n_left = newl;

	np->g_token = '=';
	strcpy(np->n_name, "unfold");

	opp->g_token -= (ASSIGN 0);
	bmaxty(opp);
}

/*
 *	Check for lhs of op= that have side effects or are complex
 */
m_vhard(np)
NODEP np;
{
	NODEP lp = np->n_left;

	while (lp->g_token == '.')
		lp = lp->n_left;
	if (lp->g_token != STAR)
		return 0;
	return isvhard(lp->n_left);
}

isvhard(np)
NODEP np;
{
	NODEP rp;

descend:
	switch (np->g_type) {
	case E_LEAF:
		return 0;
	case E_UNARY:
		switch (np->g_token) {
		case '(':
		case DOUBLE '+':
		case DOUBLE '-':
		case POSTINC:
		case POSTDEC:
			return 1;
		default:
			np = np->n_left;
			goto descend;
		}
	case E_BIN:
		switch (np->g_token) {
		case '+':
		case '-':
			rp = np->n_right;
			if (rp->g_token == ICON && np->g_ty != ET_F) {
				np = np->n_left;
				goto descend;
			}
			/* fall through */
		default:
			return 1;
		}
	}
}

vhard(np)
NODEP np;
{
	NODEP starp;
	NODEP atree, btree;
	NODEP t1, t2;
	register NODEP opp;
	NODEP tmp_var();

	starp = np->n_left;
	while (starp->g_token == '.')
		starp = starp->n_left;
	atree = starp->n_left;
	btree = np->n_right;
	t1 = tmp_var(ET_U, SIZE_P);
	t2 = copyone(t1);
	starp->n_left = t2;

	opp = copyone(t1);
	opp->g_type = E_BIN;
	opp->g_token = '=';
	strcpy(opp->n_name, "=");
	opp->n_right = atree;
	opp->n_left = t1;

	comma_r(np, opp);
}

comma_r(topp, lp)
NODEP topp, lp;
{
	register NODEP newp;

	newp = copyone(topp);
	topp->g_token = ',';
	strcpy(topp->n_name, ",");
	newp->n_left = topp->n_left;
	newp->n_right = topp->n_right;
	topp->n_left = lp;
	topp->n_right = newp;
}

NODEP
tmp_var(ty, sz)
{
	register NODEP t1;

	t1 = allocnode();
	t1->g_token = OREG;
	t1->g_type = E_LEAF;
	t1->g_rno = AREG+6;
	t1->g_ty = ty;
	t1->g_sz = sz;
	t1->g_offs = - tmp_alloc(sz);
	strcpy(t1->n_name, "tmp_v");
	return t1;
}

/* X op= Y where Y's type is stronger than X's
	either unfold it or (default)
	cast Y to weaker type (+ or -)
*/

magicop(op)
{
	switch (op) {
	case '+':
	case '-':
	case DOUBLE '<':
	case DOUBLE '>':
	case '&':
	case '|':
	case '^':
		return 1;
	}
	return 0;
}

stronger(xp, yp)
NODEP xp, yp;
{
	if (xp->g_sz > yp->g_sz || 
		(xp->g_sz == yp->g_sz && xp->g_ty > yp->g_ty))
		return 1;
	return 0;
}

/* stronger with ET_S and ET_U considered equal */
xstronger(xp, yp)
NODEP xp, yp;
{
	if (xp->g_sz > yp->g_sz ||
		(xp->g_ty == ET_F && yp->g_ty != ET_F))
		return 1;
	return 0;
}

/* give np the type of the stronger child */
bmaxty(np)
NODEP np;
{
	NODEP lp = np->n_left, rp = np->n_right;

	if (stronger(lp, rp))
		rp = lp;
	np->g_ty = rp->g_ty;
	np->g_sz = gwiden(rp->g_sz);
}

/*
 *	Change floating compares to inline call 
 */
m_fcmp(np)
NODEP np;
{
		/* already made L and R same with casts */
	if (np->g_type != E_BIN || np->n_left->g_ty != ET_F)
		return 0;
	switch (np->g_token) {
	case '<':
		spar2 = "lt";
		return 1;
	case '>':
		spar2 = "gt";
		return 1;
	case DOUBLE '=':
		spar2 = "eq";
		return 1;
	case NOTEQ:
		spar2 = "ne";
		return 1;
	case GTEQ:
		spar2 = "ge";
		return 1;
	case LTEQ:
		spar2 = "le";
		return 1;
	}
	return 0;
}

fcmp(np)
register NODEP np;
{
	register NODEP tp;

	spar1 = "%fpcmp";
	inline(np);

	tp = copyone(np);
	tp->n_left = np->n_left;
	tp->n_right = np->n_right;
	np->n_left = tp;

	np->n_right = NULL;
	np->g_type = E_UNARY;
	np->g_token = CMPBR;
	sprintf(np->n_name, spar2);
}

/*
 *	Remove useless binary operations with identity constant
 */
m_eident(np)
NODEP np;
{
	NODEP rp = np->n_right;
	long l;
	int i, op;

	if (np->g_type != E_BIN)
		return 0;
	if (np->g_ty == ET_F)
		return 0;
	while (rp->g_token == TCONV && rp->g_ty != ET_F)
		rp = rp->n_left;
	if (rp->g_token != ICON)
		return 0;
	l = rp->g_offs;
	if (l < 0 || l > 1)
		return 0;

	op = np->g_token;
	if (isassign(op))
		op -= ASSIGN 0;
	switch (op) {
	case '+':
	case '-':
	case DOUBLE '<':
	case DOUBLE '>':
	case '|':
	case '^':
		i = 0;	break;
	case '*':
	case '/':
		i = 1;  break;
	default:
		return 0;
	}
	if (l != i)
		return 0;
	return 1;	
}

eident(np)
NODEP np;
{
	NODEP lp = np->n_left, rp = np->n_right;

	freenode(rp);
	
	lcpy(np, lp, sizeof(NODE)/4);

	freeunit(lp);
}

#define MAXLOOK	8

/*
 *	Change certain mult or div to equivalent shift
 */
m_md_shf(np)
NODEP np;
{
	NODEP rp = np->n_right;
	long l;
	register i, j;

	if (np->g_type != E_BIN)
		return 0;
	if (np->g_ty == ET_F)
		return 0;
	while (rp->g_token == TCONV && rp->g_ty != ET_F)
		rp = rp->n_left;
	if (rp->g_token != ICON)
		return 0;

	switch (np->g_token) {
	case '*':
		ipar1 = DOUBLE '<';  break;
	case '/':
		ipar1 = DOUBLE '>';  break;
	case ASSIGN '*':
		ipar1 = ASSIGN DOUBLE '<';  break;
	case ASSIGN '/':
		ipar1 = ASSIGN DOUBLE '>';  break;
	default:
		return 0;
	}

	l = rp->g_offs;
	if (l < 2 || l > (1<<MAXLOOK))
		return 0;
	i = l;
	for (j=1; j<=MAXLOOK; j++)
		if (i == 1<<j) {
			ipar2 = j;
			return 1;
		}
	return 0;
}

md_shf(np)
NODEP np;
{
	NODEP rp = np->n_right;

	np->g_token = ipar1;
	while (rp->g_token == TCONV)
		rp = rp->n_left;
	rp->g_offs = ipar2;
}

m_fldas(np)
NODEP np;
{
	if (np->g_type != E_BIN)
		return 0;
	if (np->g_token == '=' && isfield(np->n_left))
		return 1;
	return 0;
}

fldas(np)
register NODEP np;
{
	NODEP lp = np->n_left;

	np->g_fldw = lp->g_fldw;
	np->g_fldo = lp->g_fldo;
	np->g_token = FIELDAS;

	lp->g_fldw = 0;
}

red_con(np)
register NODEP np;
{
	while (np->g_token == TCONV)
		np = np->n_left;
	if (np->g_token == ICON || np->g_token == FCON)
		return 1;
	return 0;
}
