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
 *	g2.c
 *
 *	Generate code for binary nodes.
 */

#include <stdio.h>
#include "param.h"
#include "nodes.h"
#include "flags.h"
#include "bstok.h"
#include "gen.h"
#include "ops.h"

#define FAIL	0
#define OKAY	1

extern int cookflags[];

#define isimmed(np)	((np)->g_flags & IMMEDID)
#define isareg(np)	((np)->g_token == REGVAR && (np)->g_rno >= AREG)
#define isdreg(np)	((np)->g_token == REGVAR && (np)->g_rno < AREG)

struct bop {
	char *s_op, *u_op;
	int opflags;
} bops[] = {
	{"muls",	"mulu",	EOPD |ASSOC},
	{"divs",	"divu",	EOPD},
	{"divs",	"divu", EOPD},
	{"and",		"and",	EOPD|DOPE|IOPE |ASSOC},
	{"or",		"or",	EOPD|DOPE|IOPE |ASSOC},
	{"eor",		"eor",	DOPE|IOPE |ASSOC},
	{"add",		"add",	EOPD|DOPE|EOPA|IOPE|AOPA|AOPD |ASSOC},
	{"sub",		"sub",	EOPD|DOPE|EOPA|IOPE|AOPA|AOPD},
	{"asl",		"lsl",	DOPD|QOPD|ONEOPM},
	{"asr",		"lsr",	DOPD|QOPD|ONEOPM},
};

char *tstnm[] = {
	"lt",		/* < */
	"gt",		/* > */
	"le",		/* <= */
	"ge",		/* >= */
	"eq",		/* == */
	"ne",		/* != */
};

int tstx[] = {
	B_LT, B_GT, B_LE, B_GE, B_EQ, B_NE
};

char *utstnm[] = {
	"cs",		/* < */
	"hi",		/* > */
	"ls",		/* <= */
	"cc",		/* >= */
	"eq",		/* == */
	"ne",		/* != */
};

int utstx[] = {
	B_ULT, B_UGT, B_ULE, B_UGE, B_EQ, B_NE
};

b_eval(np, cookie)
register NODEP np;
{
	NODEP lp = np->n_left, rp = np->n_right;
	NODEP tp;
	int lcook = FORADR, rcook = FORADR;

	switch (np->g_token) {		/* special cookies */
	case DOUBLE '&':
	case DOUBLE '|':
		lcook = rcook = FORCC;
		break;
	case '?':
		lcook = FORCC;
		break;
	case '(':
		rcook = FORPUSH;
		break;
	case ',':
		if (np->g_offs)	/* function args */
			lcook = rcook = FORPUSH;
		else {
			lcook = FORSIDE;
			rcook = cookie;
		}
		break;
	case '=':
		rcook = FORIMA;
		break;
	case '+':
	case '-':
		tp = rp;
		while (tp->g_token == TCONV && tp->g_ty != ET_F)
			tp = tp->n_left;
		if (tp->g_token == ICON)
			lcook = FORIMA;
		break;		
	}

	if (np->g_type == EV_LR) {
		if (eval(lp,lcook) == FAIL)
			return FAIL;
		if (eval(rp,rcook) == FAIL)
			return FAIL;
	} else if (np->g_type == EV_RL) {
		if (eval(rp,rcook) == FAIL)
			return FAIL;
		if (eval(lp,lcook) == FAIL)
			return FAIL;
	} else {	/* EV_LRSEP */
		if (eval(lp,lcook) == FAIL)
			return FAIL;
		free1(NULL, lp);
		if (eval(rp,rcook) == FAIL)
			return FAIL;
	}
	return b_sube(np, cookflags[cookie]);
}

b_sube(np, flags)
register NODEP np;
{
	NODEP lp = np->n_left, rp = np->n_right;
	register int i, r;
	int argsize;
	char buf[40];
	
	if (isassign(np->g_token))
		return as_eval(np);

	switch (np->g_token) {
	case '=':
		if (specasn(np, flags) || strasn(np))
			return OKAY;
		inherit(np);
		addcode(np, "\tmove.S\t>A,<A\n");
		return OKAY;

	case '(':
		argsize = argmod(rp);
		free1(NULL,rp);
		if (np->g_ty == ET_A) {		/* struct returned */
			frc_ral(AREG);
			indir(np, AREG);
		} else {
			frc_ral(0);
			retreg(np, 0);
		}
		sprintf(buf, "\tjsr\t<A\n\tadd.w\t#%d,sp\n", argsize);
		addcode(np, buf);
		return OKAY;

	case ',':
		if (np->g_offs == 0)	/* normal ',' */
			rinherit(np);
		return OKAY;

	case DOUBLE '&':
		free1(NULL, rp);
		r = ralloc(0);
		retreg(np, r);
		holdlbls(np);
		np->g_betw = iscc(lp) ? "<FL1\n" :
			"<Q\tbeq\tL1\n";
		addcode(np, iscc(rp) ? ">FL1\n" :
			">Q\tbeq\tL1\n");
		addcode(np, "\tmoveq\t#1,A\n");
		addcode(np, "\tbra\tL2\nL1:\tclr\tA\nL2:\n");
		return OKAY;

	case DOUBLE '|':
		free1(NULL, rp);
		r = ralloc(0);
		retreg(np, r);
		holdlbls(np);
		np->g_betw = iscc(lp) ? "<TL1\n" :
			"<Q\tbne\tL1\n";
		addcode(np, iscc(rp) ? ">TL1\n" :
			">Q\tbne\tL1\n");
		addcode(np, "\tclr\tA\n");
		addcode(np, "\tbra\tL2\nL1:\tmoveq\t#1,A\nL2:\n");
		return OKAY;

	case '?':
		rinherit(np);
		rinhlbls(np);
		np->g_betw = iscc(lp) ? "<FL1\n" : "<Q\tbeq\tL1\n";
		return OKAY;

	case ':':
		free1(NULL, rp);
		r = ralloc(0);
		retreg(np, r);
		holdlbls(np);
		np->g_betw = same_a(np, lp) ?
			"\tbra\tL2\nL1:\n"  :
			"\tmove.S\t<A,A\n\tbra\tL2\nL1:\n";
		if (!same_a(np, rp))
			addcode(np, "\tmove.S\t>A,A\n");
		addcode(np, "L2:\n");
		return OKAY;

	case '<':
		i = 0;  goto dotst;
	case '>':
		i = 1;  goto dotst;
	case LTEQ:
		i = 2;  goto dotst;
	case GTEQ:
		i = 3;  goto dotst;
	case DOUBLE '=':
		i = 4;  goto dotst;
	case NOTEQ:
		i = 5;
dotst:
		fix_cmp(np, EOPD|EOPA|IOPE|AOPA|AOPD);
		if (flags & CC_OK) {
			np->g_token = (lp->g_ty == ET_U ?
			utstx[i] : tstx[i]) + BR_TOK;
		} else {
			strcpy(np->n_name, lp->g_ty == ET_U ?
			utstnm[i] : tstnm[i]);
			r = ralloc(0);
			retreg(np, r);
			addcode(np, "\tsN\tA\n\tand.w\t#1,A\n");
		}
		return OKAY;

	case '*':
		return fixmul(np, bops[0].opflags);
	case '/':
		return fixdiv(np, bops[1].opflags);
	case '%':
		return fixmod(np, bops[2].opflags);
	case '&':	i = 3;  goto doop;
	case '|':	i = 4;  goto doop;
	case '^':	i = 5;	goto doop;
	case '+':
		if (optadd(np, flags, 1))
			return OKAY;
			i = 6;  goto doop;
	case '-':
		if (optadd(np, flags, -1))
			return OKAY;
			i = 7;  goto doop;
	case DOUBLE '<':i = 8;  goto doop;
	case DOUBLE '>':i = 9;
doop:
		strcpy(np->n_name, np->g_ty == ET_U ?
			bops[i].u_op : bops[i].s_op);
		r = fix2ops(np, bops[i].opflags);
		cc_hack(np);
		return r;
	case FIELDAS:
		return fldasn(np, flags);
	default:
		printf("Weird b_eval %s ", np->n_name);
		return FAIL;
	}
}

as_eval(np)
register NODEP np;
{
	NODEP rp = np->n_right;
	register int op, i, r;

	rp = np->n_right;

	op = np->g_token;
	op -= ASSIGN 0;
	switch (op) {

	/* these get unfolded now */
	case '*':
			return fixamul(np, bops[0].opflags);
	case '/':
			return fixadiv(np, bops[1].opflags);
	case '%':
			return fixamod(np, bops[2].opflags);
	case '&':	i = 3;  goto doop;
	case '|':	i = 4;  goto doop;
	case '^':	i = 5;	goto doop;
	case '+':	i = 6;  goto doop;
	case '-':	i = 7;  goto doop;
	case DOUBLE '<':i = 8;  goto doop;
	case DOUBLE '>':i = 9;
doop:
		strcpy(np->n_name, np->g_ty == ET_U ?
			bops[i].u_op : bops[i].s_op);
		r = fix_asn(np, bops[i].opflags);
		cc_hack(np);
		return r;

	default:
		printf("Weird as_eval %s ", np->n_name);
		return FAIL;
	}
}

rinherit(np)
register NODEP np;
{
	register NODEP rp = np->n_right;

	np->g_token = rp->g_token;
	np->g_offs = rp->g_offs;
	np->g_rno = rp->g_rno;
	np->g_flags |= RCHILDNM | (rp->g_flags & IMMEDID);
}

argmod(np)
register NODEP np;
{
	int size = 0;

	if (np->g_token == ',') {
		np->g_type = EV_RL;
		size += argmod(np->n_right);
		size += argmod(np->n_left);
		return size;
	}
	size += onearg(np);
	return size;
}

onearg(np)
register NODEP np;
{
	int rv;

	/* hack small ICON */
	if (np->g_sz == 1 && np->g_token == ICON)
		np->g_sz = 2;
	/* hack push of 0 */
	if (np->g_token == ICON && np->g_offs == 0 && isimmed(np)) {
		addcode(np, "\tclr.S\t-(sp)\n");
		return (int)np->g_sz;
	}
	/* hack push of #OREG */
	if (np->g_token == OREG && isimmed(np)) {
		np->g_flags &= ~IMMEDID;
		addcode(np, "\tpea\tA\n");
		return 4;
	}

	if (np->g_ty == ET_A) {
		rv = strpush(np);
		freetmps(np);
		free1(NULL,np);
		return rv;
	}

	switch (np->g_sz) {
	case 1:
		if (isdreg(np))
		addcode(np, (np->g_ty == ET_U) ?
		   "\tand.w\t#255,A\n\tmove.w\tA,-(sp)\n" :
		   "\text.w\tA\n\tmove.w\tA,-(sp)\n" );
		else
		addcode(np, (np->g_ty == ET_U) ?
		   "\tclr.w\td0\n\tmove.b\tA,d0\n\tmove.w\td0,-(sp)\n" :
		   "\tmove.b\tA,d0\n\text.w\td0\n\tmove.w\td0,-(sp)\n" );
		return 2;
	case 2:
		addcode(np,
		   "\tmove.w\tA,-(sp)\n");
		return 2;
	default:
		addcode(np,
		   "\tmove.l\tA,-(sp)\n");
		return 4;
	}
}

#define MAXD DRV_START
#define MAXA (ARV_START-AREG)
#define NEEDALL	(MAXA*AREG + MAXD)

order(np)
register NODEP np;
{
	int l, r;

	switch (np->g_type) {
	case E_BIN:
		order(np->n_right);
		r = np->n_right->g_needs;
	case E_UNARY:
		order(np->n_left);
		l = np->n_left->g_needs;
		break;
	default:	/* leaf */
		np->g_type = EV_NONE;
		np->g_needs = 0;
		return;
	}

	if (np->g_type == E_UNARY) {
		switch (np->g_token) {
		case STAR:
		case UNARY '&':
			np->g_needs = merge(l,AREG);
			break;
		case '(':
			np->g_needs = NEEDALL;
			break;
		case POSTINC:
		case POSTDEC:
		case '!':
		case TCONV:
			np->g_needs = merge(l,1);
			break;
		case '.':
			if (np->g_fldw) {
				np->g_needs = merge(l,1);
				break;
			}
			/* else fall through */
		default:
			np->g_needs = l;
		}
		np->g_type = EV_LEFT;
		return;
	}

/* at this point, have binary node */

	switch (np->g_token) {
	case DOUBLE '&':
	case DOUBLE '|':
	case '?':
	case ':':
		/* always left-right, no extra regs */
		np->g_type = EV_LRSEP;
		np->g_needs = merge(1, merge(l,r));
		return;
	case ',':
		np->g_needs = merge(l, r);
		np->g_type = EV_LRSEP;
		return;
	case '(':
		np->g_needs = NEEDALL;
		break;
	case '^':
	case DOUBLE '<':
	case DOUBLE '>':
	case ASSIGN '/':
	case ASSIGN DOUBLE '<':
	case ASSIGN DOUBLE '>':
		np->g_needs = merge(bin(l,r), 2);
		break;
	case FIELDAS:
		np->g_type = EV_RL;	/* no PUSHR's on L */
		np->g_needs = merge(rbin(l,r), 2);
		flag_saves(np, l, r);
		return;
	default:
		if (isassign(np->g_token) || np->g_token == '=')
			np->g_needs = merge(rbin(l,r), 1);
		else
			np->g_needs = merge(bin(l,r), 1);
	}

	if (isassign(np->g_token) || np->g_token == '=')
		np->g_type = EV_RL;	/* NO PUSHER's on L */
	else
		np->g_type = worst_1st(l, r);
	flag_saves(np, l, r);
}

flag_saves(np, l, r)
NODEP np;
{
	NODEP *cpp;
	register int other;

	if (np->g_type == EV_LR) {
		cpp = &np->n_left;
		other = r;
	} else {
		cpp = &np->n_right;
		other = l;
	}
	if ((other & 7) >= MAXD || (other/AREG) >= MAXA)
		addtmp(np, cpp);
}

addtmp(np, cpp)
NODEP np, *cpp;
{
	NODEP cp, tp;
	NODEP copyone();

	cp = *cpp;
	tp = copyone(cp);
	tp->n_left = cp;
	*cpp = tp;
	tp->g_token = PUSHER;
	strcpy(tp->n_name, "pusher");
	tp->g_type = EV_LEFT;
}
	
worst_1st(l,r)
{
	int ld, rd;

	ld = l & 7;
	rd = r & 7;
	if (rd > ld)
		return EV_RL;
	if (r > l)
		return EV_RL;
	return EV_LR;
}

bin(l,r)
{
	int la, ra, na;
	int ld, rd, nd;
	int rfirst;

	la = l/AREG;
	ra = r/AREG;
	ld = l & 7;
	rd = r & 7;
	rfirst = (ra > la) || (rd > ld);
	return rfirst ? rbin(l,r) : rbin(r,l);
}

rbin(last,first)
{
	int la, fa, na;
	int ld, fd, nd;

	la = last/AREG;
	fa = first/AREG;
	ld = last & 7;
	fd = first & 7;
	na = fa > la ? fa : la + (fa ? 1 : 0);
	if (na > MAXA)
		na = MAXA;
	nd = fd > ld ? fd : ld + (fd ? 1 : 0);
	if (nd > MAXD)
		nd = MAXD;
	return na*AREG + nd;
}

merge(need, have)
{
	int na, nd, ha, hd, xa, xd;

	na = need/AREG;
	ha = have/AREG;
	nd = need & 7;
	hd = have & 7;
	xa = na > ha ? na : ha;
	xd = nd > hd ? nd : hd;
	return xa*AREG + xd;
}

holdlbls(np)
NODEP np;
{
	np->g_bsize = new_lbl();
	new_lbl();
}

rinhlbls(np)
NODEP np;
{
	np->g_bsize = np->n_right->g_bsize;
}

/* limited version of same address check
	assume one of these is a temp register */
same_a(p1, p2)
NODEP p1, p2;
{
	if (p1->g_token != p2->g_token)
		return 0;
	if (p1->g_rno != p2->g_rno)
		return 0;
	return 1;
}

optadd(np, flags, sign)
register NODEP np;
{
	NODEP lp = np->n_left, rp = np->n_right;

	if (rp->g_token != ICON)
		return 0;
	if (isimmed(lp) && isimmed(rp)) {
		switch (lp->g_token) {
		case OREG:
		case ONAME:
			inherit(np);
			if (sign == -1)
				rp->g_offs = -rp->g_offs;
			np->g_offs += rp->g_offs;

			if ((flags & IMMA_OK) == 0)
				imm_oreg(np);
			return 1;
		default:
			return 0;
		}
	}
	return 0;
}

iscc(np)
NODEP np;
{
	return (np->g_token >= BR_TOK) || (np->g_flags & SIDE_CC);
}

cc_hack(np)
NODEP np;
{
	if (isareg(np))
		return;
	np->g_flags |= SIDE_CC;
}

cctok(np)
NODEP np;
{
	if (np->g_token >= BR_TOK)
		return np->g_token - BR_TOK;
	if (np->g_flags & SIDE_CC)
		return B_NE;
	printf("cctok error ");
	return 0;
}
