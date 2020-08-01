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
 *	fix.c
 *
 *	Motorola has is not consistent in what operations allow
 *	which operands.  This section compensates for that --
 *	tries to find the best way to do something.
 */

#include <stdio.h>
#include "param.h"
#include "nodes.h"
#include "flags.h"
#include "bstok.h"
#include "gen.h"
#include "ops.h"

#define FAIL 0
#define OKAY 1

#define CL_IMM	IOPD
#define CL_AREG	AOPD
#define CL_DREG DOPD
#define CL_ADR	MOPD

#define RETAREG	0x100
#define RETDREG 0x200
#define RETLEFT	0x400
#define RETRIGHT 0x800

#define LISTMP	1
#define RISTMP	2
#define NDASSOC	4
#define CANRL	8
#define CANLR	0x10
#define CANRD	0x20
#define CANDL	0x40
#define CANLD	0x80
#define CANDD	0x100
#define CANDR	0x200

struct mtbl {
	int restr;
	char *code;
	int needregs;
} tbl2[] = {
	{LISTMP|CANRL,
		"\tN.S\t>A,<A\n", RETLEFT},
	{RISTMP|CANLR|NDASSOC,
		"\tN.S\t<A,>A\n", RETRIGHT},
	{CANRD,
		"\tmove.S\t<A,A\n\tN.S\t>A,A\n", RETDREG},
	{CANLD|NDASSOC,
		"\tmove.S\t>A,A\n\tN.S\t<A,A\n", RETDREG},
	/* only EOR and shifts get to here */
	{CANDL|LISTMP,
		"\tmove.S\t>A,R1\n\tN.S\tR1,A\n", RETLEFT|1},
	{CANDR|RISTMP|NDASSOC,
		"\tmove.S\t<A,R1\n\tN.S\tR1,A\n", RETRIGHT|1},
	{CANDD,
		"\tmove.S\t<A,A\n\tmove.S\t>A,R1\n\tN.S\tR1,A\n",
			RETDREG|1},
	{0}
};

struct mtbl tblmul[] = {
	{CANRL|LISTMP,
		"\tmulU\t>A,<A\n", RETLEFT},
	{CANLR|RISTMP,
		"\tmulU\t<A,>A\n", RETRIGHT},
	{CANRD,
		"\tmove.w\t>A,A\n\tmulU\t<A,A\n", RETDREG},
	{0}
};

struct mtbl tbldiv[] = {
	{CANRL|LISTMP,
		"\text.l\t<A\n\tdivs\t>A,<A\n", RETLEFT},
	{CANRD,
		"\tmove.w\t<A,A\n\text.l\tA\n\tdivs\t>A,A\n", RETDREG},
	{0}
};

struct mtbl tbludiv[] = {
	{CANRD,
		"\tclr.l\tA\n\tmove.w\t<A,A\n\tdivu\t>A,A\n", RETDREG},
	{0}
};

struct mtbl tblc[] = {
	{CANRL,
		"\tcmp.<S\t>A,<A\n", 0},
	{CANRD,
		"\tmove.<S\t<A,R1\n\tcmp.<S\t>A,R1\n", 1},
/* shouldnt get to here! */
	{CANDL,
		"\tmove.<S\t>A,R1\n\tcmp.<S\tR1,<A\n", 1},
	{CANDD,
		"\tmove.<S\t>A,R1\n\tmove.<S\t<A,R2\n\tcmp.<S\tR1,R2\n", 2},
	{0}
};

struct mtbl tblas[] = {
	{CANRL,
		"\tN.S\t>A,<A\n", RETLEFT},
	{CANDL,
		"\tmove.S\t>A,R1\n\tN.S\tR1,A\n", 1|RETLEFT},
	/* only MUL, DIV and shifts should get to here */
	{CANRD,
		"\tmove.S\t<A,A\n\tN.S\t>A,A\n\tmove.S\tA,<A\n",
			RETDREG},
	{CANLD|NDASSOC,
		"\tmove.S\t>A,A\n\tN.S\t<A,A\n\tmove.S\tA,<A\n",
			RETDREG},
	{CANDD,
	"\tmove.S\t<A,A\n\tmove.S\t>A,R1\n\tN.S\tR1,A\n\tmove.S\tA,<A\n",
			RETDREG|1},
	{0}
};

struct mtbl tblamul[] = {
	{CANRL,
		"\tmulU\t>A,<A\n", RETLEFT},
	{CANLR|RISTMP,
		"\tmulU\t<A,>A\n\tmove.w\t>A,<A\n", RETRIGHT},
	{CANRD,
		"\tmove.w\t<A,A\n\tmulU\t>A,A\n\tmove.w\tA,<A\n", RETDREG},
	{0}
};

struct mtbl tbladiv[] = {
	{CANRL,
		"\text.l\t<A\n\tdivs\t>A,<A\n", RETLEFT},
	{CANRD,
	"\tmove.w\t<A,A\n\text.l\tA\n\tdivs\t>A,A\n\tmove.w\tA,<A\n",
		RETDREG},
	{0}
};

struct mtbl tbluadiv[] = {
	{CANRD,
	"\tclr.l\tA\n\tmove.w\t<A,A\n\tdivu\t>A,A\n\tmove.w\tA,<A\n",
		RETDREG},
	{0}
};

struct mtbl tblamod[] = {
	{CANRL,
		"\text.l\t<A\n\tdivs\t>A,<A\n\tswap\t<A\n", RETLEFT},
	{CANRD,
  "\tmove.w\t<A,A\n\text.l\tA\n\tdivs\t>A,A\n\tswap\tA\n\tmove.w\tA,<A\n",
		RETDREG},
	{0}
};

struct mtbl tbluamod[] = {
	{CANRD,
  "\tclr.l\tA\n\tmove.w\t<A,A\n\tdivu\t>A,A\n\tswap\tA\n\tmove.w\tA,<A\n",
		RETDREG},
	{0}
};

class(np)
NODEP np;
{
	switch (np->g_token) {
	case ICON:
		return CL_IMM;
	case ONAME:
		return (np->g_flags & IMMEDID) ? CL_IMM : CL_ADR;
	case OREG:
		return (np->g_flags & IMMEDID) ? CL_IMM : CL_ADR;
	case PUSHER:
		return CL_ADR;
	case REGVAR:
		if (np->g_rno < AREG)
			return CL_DREG;
		else
			return CL_AREG;
	default:
		printf("Weird class ");
		return CL_IMM;
	}
}

int canswap;
NODEP matchnp;

fix_cmp(np, flags)
NODEP np;
{
	NODEP rp = np->n_right;

	/* special stuff for ICON 0 */
	if (rp->g_token == ICON && rp->g_offs == 0 &&
		(rp->g_flags & IMMEDID)) {
		addcode(np, "<Q");
		return OKAY;
	}
	canswap = 0;
	return fix_sub(np, flags, tblc);
}

fix2ops(np, flags)
NODEP np;
{
	canswap = flags & ASSOC;
	return fix_sub(np, flags, tbl2);
}

fixmul(np, flags)
NODEP np;
{
	return fix_sub(np, flags, tblmul);
}

fixdiv(np, flags)
NODEP np;
{
	return fix_sub(np, flags, np->g_ty == ET_U ? tbludiv : tbldiv);
}

fixmod(np, flags)
NODEP np;
{
	int r;

	r = fixdiv(np, flags);
	addcode(np, "\tswap\tA\n");
	return r;
}

fixamul(np, flags)
NODEP np;
{
	return fix_sub(np, flags, tblamul);
}

fixadiv(np, flags)
NODEP np;
{
	return fix_sub(np, flags, np->g_ty == ET_U ? tbluadiv : tbladiv);
}

fixamod(np, flags)
NODEP np;
{
	return fix_sub(np, flags, np->g_ty == ET_U ? tbluamod : tblamod);
}

fix_asn(np, flags)
NODEP np;
{
	canswap = 0;
	return fix_sub(np, flags, tblas);
}

fix_sub(np, flags, tbl)
register NODEP np;
struct mtbl *tbl;
{
	NODEP lp = np->n_left, rp = np->n_right;
	int lclass, rclass;
	register struct mtbl *p;
	int rv;

	lclass = class(lp);
	rclass = class(rp);
	matchnp = np;

	for (p = tbl; p->restr; p++)
		if ((rv = cando(flags, p->restr, lclass, rclass))) {
			dotbl(p, np);
			return OKAY;
		}
	printf("no code table match! ");
	return FAIL;
}

dotbl(p, np)
struct mtbl *p;
NODEP np;
{
	register int i, k;

	if (p->needregs) {
		i = p->needregs;
		if (i & RETLEFT)
			inherit(np);
		else if (i & RETRIGHT)
			rinherit(np);
		else if (i & RETAREG)
			retreg(np, ralloc(AREG));
		else if (i & RETDREG)
			retreg(np, ralloc(0));
		k = i & 7;
		while (k--)
			tempr(np, 0);
		k = (i/AREG) & 7;
		while (k--)
			tempr(np, AREG);
	}
	addcode(np, p->code);
}

#define canflag(l,r)	(l << cansh[r])

short cansh[] = {0, 0, 4, 0, 8, 0, 0, 0, 12};

cando(flags, restr, lc, rc)
register restr;
{
	NODEP lp = matchnp->n_left, rp = matchnp->n_right;

	if (restr & RISTMP) {
		if ((rc & (CL_DREG|CL_AREG)) == 0 ||
			istemp(rp->g_rno) == 0)
			return 0;
	} else if (restr & LISTMP) {
		if ((lc & (CL_DREG|CL_AREG)) == 0 ||
			istemp(lp->g_rno) == 0)
			return 0;
	}
	if (restr & NDASSOC) {
		if (canswap == 0)
			return 0;
	}
	if (restr & (CANLR|CANLD)) {
		flags |= quickflag(lp, flags);
	} else if (restr & (CANRL|CANRD)) {
		flags |= quickflag(rp, flags);
	}
	flags &= 0xfff;
	if (restr & CANLR) {
		if ((flags & canflag(lc,rc)) == 0)
			return 0;
	} else if (restr & CANRL) {
		if ((flags & canflag(rc,lc)) == 0)
			return 0;
	} else if (restr & CANRD) {
		if ((flags & canflag(rc,CL_DREG)) == 0)
			return 0;
	} else if (restr & CANDL) {
		if ((flags & canflag(CL_DREG,lc)) == 0)
			return 0;
	} else if (restr & CANLD) {
		if ((flags & canflag(lc,CL_DREG)) == 0)
			return 0;
	} else if (restr & CANDR) {
		if ((flags & canflag(CL_DREG,rc)) == 0)
			return 0;
	} else if (restr & CANDD) {
		if ((flags & DOPD) == 0)
			return 0;
	}
	return 1;
}

quickflag(np, flags)
NODEP np;
{
	long offs;

	if (np->g_token != ICON)
		return 0;
	offs = np->g_offs;
	if ((flags & QOPD) && np->g_offs >= 1 && np->g_offs <= 8)
		return IOPD;
	if ((flags & ONEOPM) && np->g_offs == 1)
		return IOPM;
	return 0;
}

/*
 * stuff to do field extract and field assign
 * Yes, this stuff can be optimized a lot more ... feel free
 */
fldget(np, flags)
register NODEP np;
{
	int how;

	how = 1;
	if (np->g_fldo == 0)
		how = 0;	/* no shift needed */
	else if (np->g_fldo > 8)
		how = 2;	/* shift too big for immediate */

	np->n_left->g_offs += np->g_offs;	/* major HACK, hope it works */

	retreg(np, ralloc(0));

	addcode(np, "\tmove\t<A,A\n");		/* get word */
	if (how)				/* shift to position */
		addcode(np, how==1 ?	"\tlsr\t#Y,A\n" :
			"\tlsr\t#8,A\n\tlsr\t#Z,A\n");
	addcode(np, "\tand\t#W,A\n");		/* mask off top */

	return OKAY;
}

#define istdreg(np)	((np)->g_token == REGVAR && (np)->g_rno < DRV_START)

fldasn(np, flags)
register NODEP np;
{
	int how;
	NODEP rp = np->n_right;

	how = 1;
	if (np->g_fldo == 0)
		how = 0;	/* no shift needed */
	else if (np->g_fldo > 8)
		how = 2;	/* shift too big for immediate */

	if (istdreg(rp)) {
		retreg(np, rp->g_rno);
	} else {
		retreg(np, ralloc(0));
		addcode(np, "\tmove\t>A,A\n");		/* value */
	}

	tempr(np, 0);

	if (needmask(np))		/* mask off high bits */
		addcode(np, "\tand\t#W,A\n");
	if (how)	/* shift into position */
		addcode(np, how==1 ?	"\tlsl\t#Y,A\n" :
					"\tlsl\t#8,A\n\tlsl\t#Z,A\n");

	addcode(np, "\tmove\t<A,R1\n");		/* old value */
	addcode(np, "\tand\t#X,R1\n");		/* mask out old value */
	addcode(np, "\tor\tA,R1\n");		/* set new field */
	addcode(np, "\tmove\tR1,<A\n");		/* store new word */

	if (how && (flags & NOVAL_OK) == 0)	/* return value */
		addcode(np, how==1 ?	"\tlsr\t#Y,A\n" :
					"\tlsr\t#8,A\n\tlsr\t#Z,A\n");

	return OKAY;
}

needmask(np)
register NODEP np;
{
	NODEP lp = np->n_left;

	if (np->g_fldw + np->g_fldo >= 16)
		return 0;

	if (lp->g_token != ICON)
		return 1;
	if ((int)lp->g_offs & ~ones(np->g_fldw)) {
		warn("value too big for field");
		return 1;
	}
	return 0;
}
