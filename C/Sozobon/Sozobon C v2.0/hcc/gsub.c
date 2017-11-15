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
 *	gsub.c
 *
 *	Various code generation subroutines
 *	Includes generation of switches and
 *	conversion of type lists to simple type,size.
 */

#include <stdio.h>
#include "param.h"
#include "bstok.h"
#include "tytok.h"
#include "flags.h"
#include "nodes.h"
#include "gen.h"

#define isimmed(np)	((np)->g_flags & IMMEDID)
#define isareg(np)	((np)->g_token == REGVAR && (np)->g_rno >= AREG)

extern cctest;

extern xflags[];
#define debug	xflags['s'-'a']

gen_brt(np, lbl)
NODEP np;
{
	p2_expr(&np);
	mustty(np, R_SCALAR);
	br_sub(np, 0, lbl);
}

gen_brf(np, lbl)
NODEP np;
{
	p2_expr(&np);
	mustty(np, R_SCALAR);
	br_sub(np, 1, lbl);
}

br_sub(np, rev, lbl)
NODEP np;
{
	int i;

	switch (np->e_token) {
		case DOUBLE '&':
			br_split(np, lbl, rev);
			return;
		case DOUBLE '|':
			br_split(np, lbl, 2+rev);
			return;
	}
	genx(np, FORCC);
	i = cctest;
	if (i) {
		if (rev)
			/* reverse truth */
			i = (i&1) ? i+1 : i-1;
		out_b(i, lbl);
	}
}

br_split(np, lbl, n)
NODEP np;
{
	int nlbl;

	if (n == 0 || n == 3)
		nlbl = new_lbl();
	else
		nlbl = lbl;

	br_sub(np->n_left, n<2, nlbl);
	br_sub(np->n_right, n&1, lbl);

	freeunit(np);

	if (nlbl != lbl)
		def_lbl(nlbl);	
}

/* generate switch
	np - list of nodes with value,label pairs (sorted)
	dlbl - default label or -1
 */
#undef min
#undef max

gen_switch(np, odlbl)
NODEP np;
{
	int n,min,max;
	int dlbl;
	register NODEP p;

	if (debug) {
		printf("gs %d ", odlbl);
		printnode(np);
	}

	/* if no default, make one! */
	if (odlbl < 0)
		dlbl = new_lbl();
	else
		dlbl = odlbl;

	n = 0;
	for (p=np; p; p=p->n_next) {
		if (n == 0)
			min = max = p->c_casev;
		else
			max = p->c_casev;
		n++;
	}
	if (n <= C_SIMPLE)
		simple_sw(np,odlbl);
	else if (n >= max/C_RATIO - min/C_RATIO)
		table_sw(np,dlbl,min,max);
	else {
		half_sw(np,dlbl,max/2+min/2,n);
		goto out;		/* free already done */
	}
	freenode(np);
out:
	if (odlbl < 0)
		def_lbl(dlbl);
}

/* simple if-else type switch
	dlbl may be -1 -> fall through
	does not free np
*/
simple_sw(np, dlbl)
register NODEP np;
{
	while (np) {
		out_d0cmp(np->c_casev);
		out_b(B_EQ, np->c_casel);
		np = np->n_next;
	}
	if (dlbl >= 0)
		out_br(dlbl);
}

/* use table switch
	dlbl is not -1
	does not free np
*/
table_sw(np, dlbl, min, max)
NODEP np;
{
	out_d0cmp(min);
	out_b(B_LT, dlbl);
	out_d0cmp(max);
	out_b(B_GT, dlbl);
	if (min)
		out_d0sub(min);

	out_tsw();

	while (np) {
		while (min < np->c_casev) {
			out_tlbl(dlbl);
			min++;
		}
		out_tlbl(np->c_casel);
		min++;
		np = np->n_next;
	}
}

/* cut switch in half (by value)
	dlbl is not -1
	will free np
 */
half_sw(np, dlbl, cut, n)
NODEP np;
{
	register NODEP p, last;
	int nlo, nhi;
	int l1;

	for (p=np; p->c_casev < cut; p = p->n_next)
		last = p;
	/* we KNOW both pieces are non-NULL ! */
	last->n_next = NULL;
	last = p;

	nlo = 0;
	nhi = 0;
	for (p=np; p; p=p->n_next)
		nlo++;
	nhi = n - nlo;
	
	if (nhi == 1) {		/* switch hi and low */
		p = np;
		np = last;
		last = p;
		nlo = 1;
		nhi = n-1;
	}
	if (nlo == 1) {		/* also nhi == 1 */
		out_d0cmp(np->c_casev);
		out_b(B_EQ, np->c_casel);
		freenode(np);
		gen_switch(last, dlbl);
		return;
	}
	l1 = new_lbl();
	out_d0cmp(cut);
	out_b(B_GE, l1);
	gen_switch(np, dlbl);
	def_lbl(l1);
	gen_switch(last, dlbl);	
}

istempa(np)
register NODEP np;
{
	if (np->g_token == OREG && istemp(np->g_rno))
		return 1;
	return 0;
}

char chunkch[] = {0, 'b', 'w', 0, 'l'};

strasn(np)
NODEP np;
{
	int r;
	long count, i;
	int chunk, l;
	char buf[40];
	int lisa, risa, rissp;
	int useloop;

	if (np->g_ty != ET_A)
		return 0;

	count = np->g_bsize;
	chunk = np->g_sz;
	if (count == 1) {
		return 0;
	}

	useloop = count > 3;

	lisa = istempa(np->n_left);
	risa = istempa(np->n_right);
	rissp = (np->n_right->g_token == PUSHER);

	if (lisa)
		r = np->n_left->g_rno;
	else
		r = ralloc(AREG);	/* R0 */
	indir(np, r);
	np->g_offs = -(count*chunk);

	if (risa)
		np->g_r1 = np->n_right->g_rno;
	else if (rissp)
		np->g_r1 = AREG+7;
	else
		tempr(np, AREG);	/* R1 */
	if (useloop)
		tempr(np, 0);		/* R2 */

	if (!lisa || np->n_left->g_offs)
		addcode(np, "\tlea\t<A,R0\n");
	if (!(risa||rissp) || np->n_right->g_offs)
		addcode(np, "\tlea\t>A,R1\n");

	if (useloop) {
		sprintf(buf, "\tmove.w\t#%d,R2\n", (int)(count-1));
		addcode(np, buf);
		l = new_lbl();
		sprintf(buf, "'L%d:\tmove.%c\t(R1)+,(R0)+\n",l,chunkch[chunk]);
		addcode(np, buf);
		sprintf(buf, "\tdbra\tR2,'L%d\n", l);
		addcode(np, buf);
	} else for (i=0; i<count; i++) {
		sprintf(buf, "\tmove.%c\t(R1)+,(R0)+\n", chunkch[chunk]);
		addcode(np, buf);
	}

	if (chunk == 1 && count & 1 && rissp)
		addcode(np, "\tmove.b\t(sp)+,R2\n");
		
	return 1;
}

strret(np)
NODEP np;
{
	extern funstrl;

	strsub(np, funstrl);
}

strpush(np)
NODEP np;
{
	return strsub(np, 0);
}

strxpush(np)
NODEP np;
{
	strsub(np, -1);
}

strsub(np, tolbl)
register NODEP np;
{
	long count, i;
	int chunk, l;
	char buf[40];
	char *frstr;
	register NODEP tp;
	int useloop;

	count = np->g_bsize;
	chunk = np->g_sz;
	if (chunk == 1 && count & 1 && tolbl <= 0)
		count++;

	useloop = count > 3;

	if (useloop && np->g_r2 == -1)
		np->g_r2 = ralloc(0);

	/* set up 'from' address */
	if (np->g_token == OREG && istemp(np->g_rno)) {
		frstr = "R0";
		if (np->g_offs)
			addcode(np, "\tlea\tA,R0\n");
	} else if (tolbl == -1 && (tp = np->n_left) &&
	    tp->g_token == OREG && istemp(tp->g_rno) &&
	    tp->g_offs == 0) {
		frstr = "R1";
		np->g_r1 = tp->g_rno;
	} else {
		frstr = "R1";
		if (np->g_r1 == -1)
			np->g_r1 = ralloc(AREG);
		if (tolbl == -1)
			addcode(np, "\tlea\t<A,R1\n");
		else
			addcode(np, "\tlea\tA,R1\n");
	}

	/* set up 'to' address */
	if (tolbl > 0) {
		sprintf(buf, "\tmove.l\t#'L%d,H\n", tolbl);
		addcode(np, buf);
	} else {
		sprintf(buf, "\tsub\t#%d,sp\n", (int)(count*chunk));
		addcode(np, buf);
		addcode(np, "\tmove.l\tsp,H\n");
	}

	/* generate copy loop */
	if (useloop) {
		sprintf(buf, "\tmove.w\t#%d,R2\n", (int)(count-1));
		addcode(np, buf);
		l = new_lbl();
		sprintf(buf, "'L%d:\tmove.%c\t(%s)+,(H)+\n", l, chunkch[chunk],
			frstr);
		addcode(np, buf);
		sprintf(buf, "\tdbra\tR2,'L%d\n", l);
		addcode(np, buf);
	} else for (i=0; i<count; i++) {
		sprintf(buf, "\tmove.%c\t(%s)+,(H)+\n", chunkch[chunk],
			frstr);
		addcode(np, buf);
	}

	return count*chunk;
}

specasn(np, flags)
NODEP np;
{
	NODEP lp = np->n_left, rp = np->n_right;
	int r;

	if (rp->g_token == ICON && isimmed(rp)) {
		rinherit(np);

		if (rp->g_offs == 0)
			addcode(np, isareg(lp) ? "\tsub.S\t<A,<A\n"
				: "\tclr.S\t<A\n");
		else
			addcode(np, "\tmove.S\t>A,<A\n");
		return 1;
	}
	if (rp->g_token == OREG && isimmed(rp)) {
		rp->g_flags &= ~IMMEDID;
		if (isareg(lp)) {
			inherit(np);
			addcode(np, "\tlea\t>A,A\n");
		} else if (rp->g_offs == 0) {
			retreg(np, rp->g_rno);
			addcode(np, "\tmove.l\tA,<A\n");
		} else {
			if (istemp(rp->g_rno))
				r = rp->g_rno;
			else
				r = ralloc(AREG);
			retreg(np, r);
			addcode(np, "\tlea\t>A,A\n");
			addcode(np, "\tmove.l\tA,<A\n");
		}
		return 1;
	}
	return 0;
}

untype(np)
register NODEP np;
{
	if (np == NULL || np->n_tptr == NULL) {
		printf("? NULL untype ");
		return;
	}
	
	switch (np->e_type) {
	case E_BIN:
		untype(np->n_right);
		/* fall through */
	case E_UNARY:
		if (np->e_token == '.' && np->e_fldw) {
			np->g_fldw = np->e_fldw;
			np->g_fldo = np->e_fldo;
		} else
			np->g_fldw = 0;

		untype(np->n_left);
	}

	get_tyinf(np);

	if ((np->n_flags & N_COPYT) == 0)
		freenode(np->n_tptr);
	np->n_tptr = NULL;		/* is g_code */
	np->g_betw = NULL;
}

static char bty[] = {
	ET_U, ET_U, ET_S, ET_S, ET_U, ET_S, ET_S, ET_F, ET_F, 0
};

static char bsz[] = {
	SIZE_C, SIZE_L, SIZE_L, SIZE_S, SIZE_U,
	SIZE_I, SIZE_C, SIZE_F, SIZE_D, 0
};

get_tyinf(np)
register NODEP np;
{
	NODEP tp = np->n_tptr;
	int n;
	long offs;
	double fval;

	if (tp->t_token != K_DOUBLE)
		offs = np->e_offs;
	else
		fval = np->e_fval;

	/* inherit name,token,left,right,nmx from common
		and token, flags, type, sc from enode */

	switch (tp->t_token) {
	case K_STRUCT:
	case K_UNION:
		np->g_ty = ET_A;
		/* determine copy chunk size and number of chunks */
		if (tp->t_aln & 1) {
			if (tp->t_size & 1)
				fatal("aligned struct with odd size");
			if (tp->t_size & 2) {
				np->g_bsize = tp->t_size >> 1;
				np->g_sz = 2;
			} else {
				np->g_bsize = tp->t_size >> 2;
				np->g_sz = 4;
			}
		} else {
			np->g_bsize = tp->t_size;
			np->g_sz = 1;
		}
		break;
	case '(':
		break;
	case STAR:
		np->g_ty = ET_U;
		np->g_sz = SIZE_P;
		break;
	default:
		n = tp->t_token-FIRST_BAS;
		np->g_ty = bty[n];
		np->g_sz = bsz[n];
	}

	if (tp->t_token != K_DOUBLE)
		np->g_offs = offs;	/* different place */
	else
		np->g_fval = fval;
}

addcode(np, s)
register NODEP np;
char *s;
{
	NODEP tp;
	int i, c;

	while (np->g_code)
		np = np->g_code;
	tp = allocnode();
	np->g_code = tp;
	np->n_flags &= ~N_COPYT;
	i = strlen(s);
	if (i < NMXSIZE) {	/* fits in one */
		strcpy(tp->n_name, s);
		return;
	}

	/* need to split it */
	i = NMXSIZE-1;
	c = s[i-1];
	if (c == '<' || c == '>' || (c>='A' && c<='Z'))	/* special */
		i--;
	strncpy(tp->n_name, s, i);
	tp->n_name[i] = 0;
	addcode(tp, &s[i]);
}
