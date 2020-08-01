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
 *	gen.c
 *
 *	Generate code.
 *	Includes main routine and code generation for unary nodes
 *	and leafs.
 */

#include <stdio.h>
#include "param.h"
#include "bstok.h"
#include "tytok.h"
#include "flags.h"
#include "nodes.h"
#include "gen.h"

NODEP strsave;
int cctest;
static int reserve;
static int tmpused;
extern long convalue;

extern xflags[];
#define debug xflags['g'-'a']

#define FAIL	0
#define OKAY	1

#define isimmed(np)	((np)->g_flags & IMMEDID)
#define isareg(np)	((np)->g_token == REGVAR && (np)->g_rno >= AREG)
#define isdreg(np)	((np)->g_token == REGVAR && (np)->g_rno < AREG)
#define istdreg(np)	((np)->g_token == REGVAR && (np)->g_rno < DRV_START)

int cookflags[] = {
	0,
	NOVAL_OK|CC_OK|IMMA_OK,		/* FORSIDE */
	IMMA_OK,			/* FORPUSH */
	CC_OK,				/* FORCC */
	IMMA_OK,			/* FORIMA */
	0,				/* FORADR */
	IMMA_OK,			/* FORINIT */
	0,				/* IND0 */
	0,				/* RETSTRU */
	0,				/* FORVALUE */
};

genx(np, cookie)
register NODEP np;
{
	extern nmerrors;
	int rv;
	extern NODE *blktab;

	if (np == NULL) return;
	if (nmerrors)
		goto bad;
	if (debug) {
		printf("GEN enter");
		printnode(np);
	}

	untype(np);
	if (debug>1) {
		printf("after UNTYPE");
		printnode(np);
	}

	tmpused = 0;
	gunk(np);
	if (tmpused && tmpused > blktab->b_tsize)
		blktab->b_tsize = tmpused;
	if (debug > 1) {
		printf("after gunk");
		printnode(np);
	}
	order(np);

	reserve = 0;
	rv = eval(np, cookie);
	if (rv == OKAY && debug) {
		printf("GEN exit");
		codeprint(np);
	}
	if (rv == OKAY)
		rv = cookmon(np, cookie);
	else
		error("couldnt eval node");
	freenode(np);
	return rv;
bad:
	freenode(np);
	return FAIL;
}

eval(np, cookie)
register NODEP np;
{
	int rv;

	np->g_r1 = np->g_r2 = -1;

	if (np == NULL) return FAIL;

	switch (np->g_type) {

	default:
		rv = b_eval(np, cookie);
		free1(np, np->n_left);
		free1(np, np->n_right);
		break;

	case EV_LEFT:
		rv = u_eval(np, cookie);
		free1(np, np->n_left);
		break;

	case EV_NONE:
		rv = l_eval(np);
		break;
	}
	freetmps(np);
	return rv;
}

u_eval(np, cookie)
register NODEP np;
{
	int subcook = FORADR;

	switch (np->g_token) {
	case STAR:
		subcook = FORIMA;
		break;
	case '!':
		subcook = FORCC;
		break;
	}

	if (eval(np->n_left, subcook) == FAIL)
		return FAIL;
	return u_sube(np, cookflags[cookie]);
}

u_sube(np, flags)
register NODEP np;
{
	register NODEP lp = np->n_left;
	long offs;
	int i;

	switch (np->g_token) {
	case '.':
		if (np->g_fldw)
			return fldget(np, flags);
		offs = np->g_offs;
		inherit(np);
		np->g_offs += offs;
		return OKAY;
	case STAR:
		if (isimmed(lp)) {
			inherit(np);
			np->g_flags &= ~IMMEDID;
		} else if (isareg(lp)) {
			indir(np, lp->g_rno);
		} else {	/* NEED A temp */
			if (lp->g_token == OREG && istemp(lp->g_rno))
				i = lp->g_rno;
			else
				i = ralloc(AREG);
			addcode(np, "\tmove.l\t<A,R0\n");
			indir(np, i);
		}
		return OKAY;
	case UNARY '&':
		if (isimmed(lp))
			warn("& ignored");
		else if (lp->g_token == REGVAR)
			return FAIL;
		inherit(np);
		np->g_flags |= IMMEDID;
		if ((flags & IMMA_OK) == 0)
			imm_oreg(np);
		return OKAY;
	case '~':
		utemp(np);
		addcode(np, "\tnot.S\tA\n");
		cc_hack(np);
		return OKAY;
	case UNARY '-':
		utemp(np);
		addcode(np, "\tneg.S\tA\n");
		cc_hack(np);
		return OKAY;
	case TCONV:
		castgen(np);
		return OKAY;
	case PUSHER:	/* must not be on left of assign or asn-op */
		if ((lp->g_token != OREG && lp->g_token != REGVAR) ||
			istemp(lp->g_rno) == 0) {
			inherit(np);
			return OKAY;
		}
		if (lp->g_ty == ET_A)
			strxpush(np);
		else
			addcode(np, "\tmove.S\t<A,-(sp)\n");
		return OKAY;
	case '(':
		if (np->g_ty == ET_A) {		/* struct returned */
			frc_ral(AREG);
			indir(np, AREG);
		} else {
			frc_ral(0);
			retreg(np, 0);
		}
		addcode(np, "\tjsr\t<A\n");
		return OKAY;
	case DOUBLE '+':
		holdcon(np);
		inherit(np);
		addcode(np, "\tadd.S\t#K,A\n");
		cc_hack(np);
		return OKAY;
	case DOUBLE '-':
		holdcon(np);
		inherit(np);
		addcode(np, "\tsub.S\t#K,A\n");
		cc_hack(np);
		return OKAY;
	case POSTINC:
		if ((flags & NOVAL_OK) == 0) {
			i = ralloc(0);
			retreg(np, i);
			addcode(np, "\tmove.S\t<A,A\n");
		}
		addcode(np, "\tadd.S\t#O,<A\n");
		return OKAY;
	case POSTDEC:
		if ((flags & NOVAL_OK) == 0) {
			i = ralloc(0);
			retreg(np, i);
			addcode(np, "\tmove.S\t<A,A\n");
		}
		addcode(np, "\tsub.S\t#O,<A\n");
		return OKAY;
	case CMPBR:
		i = ralloc(0);
		retreg(np, i);
		addcode(np, "\tsN\tA\n\tand.w\t#1,A\n");
		cc_hack(np);
		return OKAY;
	case '!':
		if (flags & CC_OK) {
			if (iscc(lp)) {
				i = cctok(lp);
				i = (i&1) ? i+1 : i-1;	/* reverse truth */
			} else {
				i = B_EQ;
				addcode(np, "<Q");
			}
			np->g_token = i + BR_TOK;
		} else {
			if (istdreg(lp))
				i = lp->g_rno;
			else
				i = ralloc(0);
			retreg(np, i);
			if (iscc(lp)) {
				addcode(np, "<EA\n\tand.w\t#1,A\n");
			} else {
				addcode(np, "<Q");
				addcode(np, "\tseq\tA\n\tand.w\t#1,A\n");
			}
		}
		return OKAY;
	default:
		printf("Weird u_eval %s ", np->n_name);
		return FAIL;
	}
}

holdcon(np)
NODEP np;
{
	np->g_bsize = np->g_offs;
}

retreg(np, rno)
NODEP np;
{
	np->g_token = REGVAR;
	np->g_rno = rno;
}

indir(np, rno)
register NODEP np;
{
	np->g_token = OREG;
	np->g_offs = 0;
	np->g_rno = rno;
}

inherit(np)
register NODEP np;
{
	NODEP lp = np->n_left;

	np->g_token = lp->g_token;
	np->g_offs = lp->g_offs;
	np->g_rno = lp->g_rno;
	np->g_flags |= CHILDNM | (lp->g_flags & IMMEDID);
}

cookmon(np, cookie)
register NODEP np;
{
	extern FILE *output;

	if (np == NULL) return FAIL;

	switch (cookie) {
	case FORCC:
		if (iscc(np)) {
			outcode(np);
			cctest = cctok(np);
		} else {
			if (np->g_token == ICON && isimmed(np)) {
				cctest = np->g_offs ? B_YES : B_NO;
				return OKAY;
			}
			outcode(np);
			outsub("Q", np);
			cctest = B_NE;
		}
		return OKAY;
	case FORINIT:
		if (anycode(np) == 0 && isimmed(np)) {
			out_a(np, output);
			return OKAY;
		}
		error("bad INIT expr");
		return FAIL;
	case FORVALUE:
		if (anycode(np) == 0 && isimmed(np) &&
		    np->g_token == ICON) {
			convalue = np->g_offs;
			return OKAY;
		}
		error("illegal CONSTANT expr");
		return FAIL;
	case IND0:
		outcode(np);
		if (np->g_token != REGVAR ||
			np->g_rno != 0)
			if (np->g_token == ICON && np->g_offs == 0 &&
				isimmed(np))
				outsub("\tclr.S\td0\n", np);
			else
				outsub("\tmove.S\tA,d0\n", np);
		return OKAY;
	case RETSTRU:
		freetmps(np);
		strret(np);
		outcode(np);
		return OKAY;
	}
	outcode(np);
	return OKAY;
}

anycode(np)
register NODEP np;
{
	if (np->g_code)
		return 1;
	switch (np->g_type) {
	case EV_NONE:
		return 0;
	case EV_LEFT:
		return anycode(np->n_left);
	case EV_RIGHT:
		return anycode(np->n_right);
	case EV_LR:
	case EV_RL:
		return anycode(np->n_left) || anycode(np->n_right);
	}
}

l_eval(np)
register NODEP np;
{
	int l1;

	switch (np->g_token) {
	case ID:
		switch (np->g_sc) {
		default:	/* EXTERN or HERE */
			np->g_token = ONAME;
			np->g_offs = 0;
			if (np->n_name[0] != '%')
				nnmins(np, "_");
			else	/* hack for inline name */
				strcpy(np->n_name, &np->n_name[1]);
			return OKAY;		/* dont free n_nmx */
		case K_STATIC:
			sprintf(np->n_name, "L%d", (int)np->g_offs);
			np->g_offs = 0;
			np->g_token = ONAME;
			break;
		case K_AUTO:
			np->g_rno = FRAMEP;
			np->g_token = OREG;
			break;
		case K_REGISTER:
			np->g_token = REGVAR;
			break;
		}
		if (np->n_nmx) {
			freenode(np->n_nmx);
			np->n_nmx = NULL;
		}
		return OKAY;
	case ICON:
		np->g_flags |= IMMEDID;
		return OKAY;
	case FCON:
		np->g_flags |= IMMEDID;
		return OKAY;
	case SCON:
		np->g_flags |= IMMEDID;
		np->g_token = ONAME;
		l1 = new_lbl();
		save_scon(np, l1);
		sprintf(np->n_name, "L%d", l1);
		return OKAY;
	case OREG:
		return OKAY;
	}
	return FAIL;
}

save_scon(np, lbl)
NODEP np;
{
	NODEP tp, copyone();

	tp = copyone(np);
	tp->g_offs = lbl;
	if (np->n_nmx) {
		freenode(np->n_nmx);
		np->n_nmx = NULL;
	}
	putlist(&strsave, tp);
}

utemp(np)
NODEP np;
{
	NODEP lp = np->n_left;
	int i;

	if (lp->g_token == REGVAR && 
	    istemp(lp->g_rno)) {
		inherit(np);
		return;
	}
	i = ralloc(0);
	retreg(np, i);
	addcode(np, "\tmove.S\t<A,A\n");
}

freetmps(np)
register NODEP np;
{
	if (np->g_r1 != -1)
		rfree(np->g_r1);
	if (np->g_r2 != -1)
		rfree(np->g_r2);
}

free1(np, cp)
NODEP np, cp;
{
	int cr;

	if (cp->g_token != OREG && cp->g_token != REGVAR)
		return;
	cr = cp->g_rno;
	if (np && cr == np->g_rno &&
		(np->g_token == OREG || np->g_token == REGVAR))
		return;
	if (istemp(cr))
		rfree(cr);
}

istemp(rno)
{
	return (rno < DRV_START || 
		(rno >= AREG && rno < ARV_START));
}

rfree(rno)
{
	reserve &= ~(1<<rno);
}

frc_ral(rno)
{
	int i;

	i = (1<<rno);
	if (reserve & i)
		error("rno reserved! ");
	reserve |= i;
}

tempr(np, type)
NODEP np;
{
	int i;

	i = ralloc(type);
	if (np->g_r1 == -1)
		np->g_r1 = i;
	else
		np->g_r2 = i;
	return i;
}

ralloc(type)
{
	int starti, endi;
	register int i;

	if (type == AREG) {
		starti = AREG;
		endi = ARV_START;
	} else {
		starti = 0;
		endi = DRV_START;
	}
	for (i=starti; i<endi; i++)
		if ((reserve & (1<<i)) == 0) {
			reserve |= (1<<i);
			return i;
		}
	error("Compiler failure - rallo");
	return -1;
}

tmp_alloc(sz)
{
	extern NODE *blktab;

	tmpused += sz;
	return blktab->b_size + tmpused;
}

/* fixes nodes with no code or aX is temp that are #d(aX) */
imm_oreg(np)
NODEP np;
{
	char *regnm(), buf[30];
	int i;

	if (np->g_token != OREG)
		return;
	if ((np->g_flags & IMMEDID) == 0)
		return;
	np->g_flags &= ~IMMEDID;
	if (np->g_offs == 0) {		/* #(a0) -> a0 */
		np->g_token = REGVAR;
		return;
	}
	if (istemp(np->g_rno)) {
		holdcon(np);
		addcode(np, "\tadd\t#K,A\n");
		np->g_token = REGVAR;
		return;
	}
	sprintf(buf, "\tlea\t%d(%s),A\n", (int)np->g_offs, regnm(np->g_rno));
	addcode(np, buf);
	i = ralloc(AREG);
	retreg(np, i);
}

castgen(tp)
register NODEP tp;
{
	register NODEP np = tp->n_left;
	int sz = tp->g_sz;
	int i;

	if (sz == 0) {	/* cast to void */
		inherit(tp);
		return;
	}
	if (np->g_token == ICON && isimmed(np)) {
		if (tp->g_ty == ET_F) {
			tp->g_token = FCON;
			*(float *)&tp->g_offs = (float)np->g_offs;
			tp->g_flags |= IMMEDID;
		} else {
			inherit(tp);
			i_exp(tp, np->g_sz, np->g_ty);
			squish(tp);
		}
	} else if (np->g_token == FCON && isimmed(np)) {
		if (tp->g_ty != ET_F) {
			tp->g_token = ICON;
			tp->g_offs = (long)*(float *)&np->g_offs;
			tp->g_flags |= IMMEDID;
			squish(tp);
		} else {
			inherit(tp);
		}
	} else if (sz > np->g_sz) {
		if (np->g_ty == ET_U) {
			i = ralloc(0);
			retreg(tp, i);
			addcode(tp, "\tclr.S\tA\n\tmove.<S\t<A,A\n");
		} else {
			if (isdreg(np)) {
				inherit(tp);
			} else {
				i = ralloc(0);
				retreg(tp, i);
				addcode(tp, "\tmove.<S\t<A,A\n");
			}
			if (sz == 4 && np->g_sz == 1)
				addcode(tp, "\text.w\tA\n\text.l\tA\n");
			else
				addcode(tp, "\text.S\tA\n");
		}
		return;
	}
	else if (sz < np->g_sz) {
		switch (np->g_token) {
		case ONAME:
		case OREG:
			if (isimmed(np)) {
smfudge:
				i = ralloc(0);
				retreg(tp, i);
				addcode(tp, "\tmove.<S\t<A,A\n");
				return;
			}
			inherit(tp);
			tp->g_offs = np->g_offs + (np->g_sz - sz);
			break;
		case REGVAR:
			if (sz == 1 && np->g_rno >= AREG)
				goto smfudge;
			/* fall through */
		default:
			inherit(tp);
		}
	} else
		inherit(tp);
}

squish(np)
NODEP np;
{
	int neg;

	neg = (np->g_ty == ET_S && np->g_offs < 0);

	switch (np->g_sz) {
	case 1:
		if (neg)
			np->g_offs |= 0xffffff00L;
		else
			np->g_offs &= 0xff;
		break;
	case 2:
		if (neg)
			np->g_offs |= 0xffff0000L;
		else
			np->g_offs &= 0xffffL;
		break;
	}
}

i_exp(np, osz, oty)
NODEP np;
{
	long l;

	if (oty == ET_S && osz < np->g_sz) {
		l = np->g_offs;
		switch (osz) {
		case 1:
			l = (char) l;
			break;
		case 2:
			l = (short) l;
			break;
		}
		np->g_offs = l;
	}
}
