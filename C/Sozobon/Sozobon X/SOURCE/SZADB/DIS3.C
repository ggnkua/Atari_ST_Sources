/* Copyright (c) 1990 by Sozobon, Limited.  Authors: Johann Ruegg, Don Dugger
 *
 * Permission is granted to anyone to use this software for any purpose
 * on any computer system, and to redistribute it freely, with the
 * following restrictions:
 * 1) No charge may be made other than reasonable charges for reproduction.
 * 2) Modified versions must be clearly marked as such.
 * 3) The authors are not responsible for any harmful consequences
 *    of using this software, even if they result from defects in it.
 *
 *	dis3.c
 */

#include "adb.h"

extern long dot;
extern int dotoff;
#define DOT	(dot+dotoff)

int cursz;

nextw()
{
	return getwd();
}

long
nextl()
{
	unsigned int i[2];

	i[0] = getwd();
	i[1] = getwd();
	return ((long)i[0]) << 16 | i[1];
}

int op0(), op1(), op2(), op3(), op4(), op5(), op6(), op7();
int op8(), op9(), opa(), opb(), opc(), opd(), ope(), opf();

int (*funhi[])() = {
	op0, op1, op2, op3, op4, op5, op6, op7,
	op8, op9, opa, opb, opc, opd, ope, opf
};

puti()
{
	unsigned int op;

	align(20);

	op = nextw();

	if ( (*funhi[op>>12])(op) )
		;
	else
		prt("???");
}


#define M_IMM	1
#define M_PX	2
#define M_POFF	4
#define M_ABSL	010
#define M_ABSW	020
#define M_AX	040
#define M_AOFF	0100
#define M_ADEC	0200
#define M_AINC	0400
#define M_ATA	01000
#define M_AREG	02000
#define M_DREG	04000

valid(mode,reg,mask)
{
	if (mode == 7)
		switch (reg) {
		case 0:
			return mask & M_ABSW;
		case 1:
			return mask & M_ABSL;
		case 2:
			return mask & M_POFF;
		case 3:
			return mask & M_PX;
		case 4:
			return mask & M_IMM;
		default:
			return 0;
		}
	else
		switch (mode) {
		case 0:
			return mask & M_DREG;
		case 1:
			return mask & M_AREG;
		case 2:
			return mask & M_ATA;
		case 3:
			return mask & M_AINC;
		case 4:
			return mask & M_ADEC;
		case 5:
			return mask & M_AOFF;
		case 6:
			return mask & M_AX;
		}
}

ix_str(n)
{
	int op, r;
	char c;
	char *fmt;

	op = nextw();
	r = (op>>12) & 7;
	c = (op & 0x800) ? 'l' : 'w';
	if (n >= 8) {
		if (op<0)
			fmt = "%i(pc,%a.%c)";
		else
			fmt = "%i(pc,%d.%c)";
		prtf(fmt, (char)op, r, c);
	} else {
		if (op < 0)
			fmt = "%i(%a,%a.%c)";
		else
			fmt = "%i(%a,%d.%c)";
		prtf(fmt, (char)op, n, r, c);
	}
}

modepr(mode,reg)
{
	char *p;

	switch (mode) {
	case 0:
		prtf("%d", reg);
		break;
	case 1:
		prtf("%a", reg);
		break;
	case 2:
		prtf("(%a)", reg);
		break;
	case 3:
		prtf("(%a)+", reg);
		break;
	case 4:
		prtf("-(%a)", reg);
		break;
	case 5:
		prtf("%i(%a)", nextw(), reg);
		break;
	case 6:
		ix_str(reg);
		break;
	case 7:
		switch (reg) {
		case 0:
			prtf("%i", nextw());
			break;
		case 1:
			longval();
			break;
		case 2:
			prtf("%i(pc)", nextw());
			break;
		case 3:
			ix_str(8);
			break;
		case 4:
			switch (cursz) {
			case 0:
			case 1:
				prtf("#%i", nextw());
				break;
			case 2:
				putchr('#');
				longval();
				break;
			}
			break;
		}
	}
}

longval()
{
	long l;
	struct sym *sp;

	prtf("%A", nextl());
}

char szchr[] = { 'b', 'w', 'l' };

struct optbl {
	char sel[6];
	char *name;
	int allow;
	char arg[4];
	char sz;
};

struct optbl t0[] = {
	{ "0s", "or", 05770, "ie"},
	{ "00", "or", 1, "ic"},
	{ "01", "or", 1, "is", 1},
	{ "*4", "btst", 05777, "De"},
	{ "*5", "bchg", 05770, "De"},
	{ "*6", "bclr", 05770, "De"},
	{ "*7", "bset", 05770, "De"},
	{ "*4", "movep.w", 02000, "oD"},
	{ "*5", "movep.l", 02000, "oD"},
	{ "*6", "movep.w", 02000, "Do"},
	{ "*7", "movep.l", 02000, "Do"},
	{ "1s", "and", 05770, "ie"},
	{ "10", "and", 1, "ic"},
	{ "11", "and", 1, "is", 1},
	{ "2s", "sub", 05770, "ie"},
	{ "3s", "add", 05770, "ie"},
	{ "40", "btst", 05776, "ie"},
	{ "41", "bchg", 05770, "ie"},
	{ "42", "bclr", 05770, "ie"},
	{ "43", "bset", 05770, "ie"},
	{ "5s", "eor", 05770, "ie"},
	{ "50", "eor", 1, "ic"},
	{ "51", "eor", 1, "is", 1},
	{ "6s", "cmp", 05770, "ie"},
	{ 0, 0, 0, 0 }
};

op0(op)
{
	return tblop(op, t0);
}

match(c, val)
{
	switch (c) {
	case '*':
		return 1;
	case 's':
		return val <= 2;
	case 'S':
		return val >= 4 && val <= 6;
	case 'z':
		return val >= 1 && val <= 2;
	case 'Z':
		return val == 3 || val == 7;
	default:
		return val == (c - '0');
	}
}

op1(op)
{
	int sm, sr, dm, dr;

	sm = (op>>3) & 7;
	sr = op & 7;
	dm = (op>>6) & 7;
	dr = (op>>9) & 7;
	cursz = 0;
	if (valid(sm,sr,07777) && valid(dm,dr,05770)) {
		prt("move.b\t");
		modepr(sm,sr);
		putchr(',');
		modepr(dm,dr);
		return 1;
	}
	return 0;
}

op2(op)
{
	int sm, sr, dm, dr;

	sm = (op>>3) & 7;
	sr = op & 7;
	dm = (op>>6) & 7;
	dr = (op>>9) & 7;
	cursz = 2;
	if (valid(sm,sr,07777) && valid(dm,dr,07770)) {
		prt("move.l\t");
		modepr(sm,sr);
		putchr(',');
		modepr(dm,dr);
		return 1;
	}
	return 0;
}

op3(op)
{
	int sm, sr, dm, dr;

	sm = (op>>3) & 7;
	sr = op & 7;
	dm = (op>>6) & 7;
	dr = (op>>9) & 7;
	cursz = 1;
	if (valid(sm,sr,07777) && valid(dm,dr,07770)) {
		prt("move.w\t");
		modepr(sm,sr);
		putchr(',');
		modepr(dm,dr);
		return 1;
	}
	return 0;
}

struct optbl t4[] = {
	{ "0s", "negx", 05770, "e"},
	{ "03", "move.w", 05770, "se"},
	{ "*6", "chk", 05777, "eD"},
	{ "*7", "lea", 01176, "eA"},
	{ "1s", "clr", 05770, "e"},
	{ "2s", "neg", 05770, "e"},
	{ "23", "move.b", 05777, "ec"},
	{ "3s", "not", 05770, "e"},
	{ "33", "move.w", 05777, "es", 1},
	{ "40", "nbcd", 05770, "e"},
	{ "41", "swap", 04000, "d"},
	{ "41", "pea", 01176, "e"},
	{ "42", "ext.w", 04000, "d"},
	{ "42", "movem.w", 01170, "le"},
	{ "42", "movem.w", 00200, "Le"},
	{ "43", "movem.l", 01170, "le"},
	{ "43", "movem.l", 00200, "Le"},
	{ "43", "ext.l", 04000, "d"},
	{ "5s", "tst", 05770, "e"},
	{ "53", "tas", 05770, "e"},
	{ "53", "illegal", 0001, ""},
	{ "71", "trap", 06000, "t"},
	{ "71", "link", 01000, "ai", 1},
	{ "71", "unlk", 00400, "a"},
	{ "71", "move", 00200, "au"},
	{ "71", "move", 00100, "ua"},
	{ "7160", "reset", 0, ""},
	{ "7161", "nop", 0, ""},
	{ "7162", "stop", 0, ""},
	{ "7163", "rte", 0, ""},
	{ "7165", "rts", 0, ""},
	{ "7166", "trapv", 0, ""},
	{ "7167", "rtr", 0, ""},
	{ "72", "jsr", 01176, "e"},
	{ "73", "jmp", 01176, "e"},
	{ 0, 0, 0, 0 }
};

op4(op)
{
	int mode, reg, list;

	if ((op & 07600) == 06200) {
		reg = op & 7;
		mode = (op>>3) & 7;
		if (valid(mode,reg,01576)) {
			prtf("movem.%c\t", op & 0100 ? 'l' : 'w');
			list = nextw();
			modepr(mode,reg);
			putchr(',');
			rlist(list);
			return 1;
		} else
			return 0;
	}
	return tblop(op, t4);
}

tblop(op, tp)
register struct optbl *tp;
{
	int mode, reg;
	int hi,lo;

	reg = op & 7;
	mode = (op>>3) & 7;
	lo = (op>>6) & 7;
	hi = (op>>9) & 7;

	for (; tp->name; tp++)
		if (match(tp->sel[0], hi) &&
		    match(tp->sel[1], lo) &&
		    (tp->allow == 0 || valid(mode,reg,tp->allow)) &&
		    (tp->sel[2] == 0 || match(tp->sel[2], mode)) &&
		    (tp->sel[3] == 0 || match(tp->sel[3], reg)) ) {

			prt(tp->name);

			switch (tp->sel[1]) {
			case 's':
				cursz = lo;
				break;
			case 'S':
				cursz = lo-4;
				break;
			case 'z':
				cursz = (lo==1) ? 1 : 2;
				break;
			case 'Z':
				cursz = (lo==3) ? 1 : 2;
				break;
			default:
				cursz = tp->sz;
				goto noszpr;
			}

			prtf(".%c", szchr[cursz]);
noszpr:
			putchr('\t');

			if (tp->arg[0]) {
				puta(tp->arg[0],op);
				if (tp->arg[1]) {
					putchr(',');
					puta(tp->arg[1],op);
				}
			}
			return 1;
		}
	return 0;
}

puta(c, op)
{
	int reg,mode,hi;

	reg = op & 7;
	mode = (op>>3) & 7;
	hi = (op>>9) & 7;

	switch (c) {
	case 'i':
		modepr(7,4);
		break;
	case 'e':
		modepr(mode,reg);
		break;
	case 'c':
		prt("ccr");
		break;
	case 's':
		prt("sr");
		break;
	case 'D':
		modepr(0,hi);
		break;
	case 'd':
		modepr(0,reg);
		break;
	case 'A':
		modepr(1,hi);
		break;
	case 'a':
		modepr(1,reg);
		break;
	case 'o':
		modepr(5,reg);
		break;
	case 'm':
		modepr(4,reg);
		break;
	case 'M':
		modepr(4,hi);
		break;
	case 'p':
		modepr(3,reg);
		break;
	case 'P':
		modepr(3,hi);
		break;
	case 'l':
		rlist(nextw());
		break;
	case 'L':
		blist(nextw());
		break;
	case 'u':
		prt("usp");
		break;
	case 't':
		prtf("#%i", op & 0xf);
		break;
	case 'k':
		prtf("#%i", hi ? hi : 8);
		break;
	}
}

rlist(x)
{
	int as, ds;

	ds = x & 0xff;
	as = (x>>8) & 0xff;
	putchr('[');
	if (ds) {
		listc('d', ds);
		if (as) {
			putchr(',');
			listc('a', as);
		}
	} else if (as)
		listc('a', as);
	putchr(']');
}

listc(c, x)
char c;
{
	int i;

	for (i=0; i<8; )
		if (x & (1<<i))
			i += chunk(c, x, i);
		else
			i++;
}

chunk(c, x, i)
char c;
{
	int j;

	putchr(c);
	j = cnt1s(x>>i);
	if (j == 1) {
		putchr('0'+i);
		return j;
	} else {
		putchr('0'+i);
		putchr('-');
		putchr('0'+i+(j-1));
		return j;
	}
}

cnt1s(x)
{
	int i;

	for (i=0; i<9; i++)
		if ((x & (1<<i)) == 0)
			return i;
}

blist(x)
{
	int y;
	int i;
	unsigned uw = 0x8000;

	y = 0;
	for (i=0; i<16; i++)
		if (x & (1<<i))
			y |= (uw>>i);
	rlist(y);
}

char *bnm[] = {	"t", "f", "hi", "ls",
		"cc", "cs", "ne", "eq",
		"vc", "vs", "pl", "mi",
		"ge", "lt", "gt", "le" };

op5(op)
{
	int cond, mode, reg;
	int sz, k;
	long svdot = DOT;

	sz = (op>>6) & 3;
	reg = op & 7;
	mode = (op>>3) & 7;

	if (sz == 3) {
		cond = (op>>8) & 0xf;
		if (mode == 1) {
			prtf("db%s\t%d,%A", bnm[cond], reg,
				svdot+nextw());
			return 1;
		} else if (valid(mode,reg,05770)) {
			prtf("s%s\t", bnm[cond]);
			modepr(mode,reg);
			return 1;
		}
	} else {
		k = (op>>9) & 7;
		if (k == 0) k = 8;
		if (valid(mode,reg, sz ? 07770 : 05770)) {
			prtf((op&0x100) ? "subq.%c\t" : "addq.%c\t",
				szchr[sz]);
			prtf("#%i,", k);
			modepr(mode,reg);
			return 1;
		}
	}
	return 0;
}

op6(op)
{
	int cond, k;
	long svdot = DOT;

	cond = (op>>8) & 0xf;
	k = (char)op;
	if (k == 0)
		svdot += nextw();
	else
		svdot += k;
	if (cond < 2)
		prt(cond ? "bsr" : "bra");
	else
		prtf("b%s", bnm[cond]);
	prtf("\t%A", svdot);
	return 1;
}

op7(op)
{
	int reg, k;

	if (op & 0x100)
		return;
	k = (char)op;
	reg = (op>>9) & 7;
	prtf("moveq\t#%i,%d", k, reg);
	return 1;
}

struct optbl t8[] = {
	{ "*s", "or", 05777, "eD"},
	{ "*S", "or", 01770, "De"},
	{ "*3", "divu", 05777, "eD"},
	{ "*7", "divs", 05777, "eD"},
	{ "*4", "sbcd", 04000, "dD"},
	{ "*4", "sbcd", 02000, "mM"},
	{ 0, 0, 0, 0}
};

op8(op)
{
	return tblop(op, t8);
}

struct optbl t9[] = {
	{"*0", "sub.b", 05777, "eD"},
	{"*z", "sub", 07777, "eD"},
	{"*S", "sub", 01770, "De"},
	{"*Z", "sub", 07777, "eA"},
	{"*S", "subx", 04000, "dD"},
	{"*S", "subx", 02000, "mM"},
	{ 0, 0, 0, 0}
};

op9(op)
{
	return tblop(op, t9);
}

opa()
{
	return 0;
}

struct optbl tb[] = {
	{"*0", "cmp.b", 05777, "eD"},
	{"*z", "cmp", 07777, "eD"},
	{"*Z", "cmp", 07777, "eA"},
	{"*S", "eor", 05770, "De"},
	{"*S", "cmpm", 02000, "pP"},
	{0, 0, 0, 0}
};

opb(op)
{
	return tblop(op, tb);
}

struct optbl tc[] = {
	{"*s", "and", 05777, "eD"},
	{"*S", "and", 01770, "De"},
	{"*3", "mulu", 05777, "eD"},
	{"*7", "muls", 05777, "eD"},
	{"*4", "abcd", 04000, "dD"},
	{"*4", "abcd", 02000, "mM"},
	{"*5", "exg", 04000, "dD"},
	{"*5", "exg", 02000, "aA"},
	{"*6", "exg", 02000, "aD"},
	{0, 0, 0, 0}
};

opc(op)
{
	return tblop(op, tc);
}

struct optbl td[] = {
	{"*0", "add.b", 05777, "eD"},
	{"*z", "add", 07777, "eD"},
	{"*S", "add", 01770, "De"},
	{"*Z", "add", 07777, "eA"},
	{"*S", "addx", 04000, "dD"},
	{"*S", "addx", 02000, "mM"},
	{ 0, 0, 0, 0}
};

opd(op)
{
	return tblop(op, td);
}

char *shiftnm[] = { "as", "ls", "rox", "ro" };

ope(op)
{
	int sz, c_r;
	int mode, reg;

	sz = (op>>6) & 3;
	if (sz == 3) {
		mode = (op>>3) & 7;
		reg = op & 7;
		if (valid(mode,reg,01770)) {
			prtf("%s%c.w\t #1,", shiftnm[(op>>9)&3],
				(op&0x100) ? 'l' : 'r');
			modepr(mode,reg);
			return 1;
		}
	} else {
		prtf("%s%c.%c\t", shiftnm[(op>>3)&3],
			(op&0x100) ? 'l' : 'r',
			szchr[sz]);
		c_r = (op>>9) & 7;
		if (op & 040)
			prtf("%d", c_r);
		else
			prtf("#%i", c_r ? c_r : 8);
		prtf(",%d", op & 7);
		return 1;
	}
	return 0;
}

opf()
{
	return 0;
}
