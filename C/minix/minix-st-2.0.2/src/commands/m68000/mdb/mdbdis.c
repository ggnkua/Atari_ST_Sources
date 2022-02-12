/*
 * mdbdis.c - MINIX program disassembler
 *
 * Written by Bruce D. Szablak
 *
 * This free software is provided for non-commerical use. No warrantee
 * of fitness for any use is implied. You get what you pay for. Anyone
 * may make modifications and distribute them, but please keep this header
 * in the distribution.
 */

#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>
#include "mdb.h"

#define BYTE 0
#define WORD 1
#define LONG 2

#define BFIELD(w,b,l) (((w) >> ((b)-(l)+1)) & (int)((1L<<(l))-1))
#define BTST(w,b) ((w) & (1 << (b)))
char opwfmt[] = "%s.%c\t";
#define OPI(s,w) printf(opwfmt, s, w)

char size[] = "bwl";
char *cc[] = {"ra", "f", "hi", "ls", "cc", "cs", "ne", "eq", "vc", "vs",
	"pl", "mi", "ge", "lt", "gt", "le" };

char *bitop[] = { "btst", "bchg", "bclr", "bset" };
char *imedop[] = { "ori", "andi", "subi", "addi", "?", "eori", "cmpi" };
char *misc1[] = { "negx", "clr", "neg", "not" };
char *misc2[] = { "reset", "nop", "stop", "rte", "??", "rts", "trapv", "rtr" };
char *shf[] = { "as", "ls", "rox", "ro" };

char *fmts[] = { "d%d", "a%d", "(a%d)", "(a%d)+", "-(a%d)" };

extern curpid;
extern long saddr, eaddr;

long gaddr, gbuf;
int gempty, gisize, gjmp;

_PROTOTYPE(short gword , (void));
_PROTOTYPE(long glong , (void));
_PROTOTYPE(void reladdr , (int sep ));
_PROTOTYPE(void movem , (int from , int predec , int rmsk ));
_PROTOTYPE(void op1 , (int mode , int reg ));
_PROTOTYPE(void op2 , (int f , int m1 , int r1 , int m2 , int r2 ));
_PROTOTYPE(void opmode , (char *op , int opm , int reg , int m , int r ));

short
gword()
{
	if (gempty)
	{
		gempty = 0;
		gbuf = ptrace(1, curpid, gaddr, 0L);
		gaddr += 2;
		return gbuf >> 16;
	}
	gempty = 1;
	gaddr += 2;
	return gbuf;
}

long
glong()
{
	gempty = 1;
	gbuf = ptrace(1, curpid, gaddr, 0L);
	gaddr += 4;
	return gbuf;
}

void reladdr(sep)
	char sep;
{
	int d = gword();
	symbolic(gaddr + d - 2, sep);
}

void movem(from, predec, rmsk)
{
	int b, f = 0;

	if (!from) putc(',', stdout);
	for (b = 16; b--; rmsk >>= 1)
	{
		if (rmsk & 1)
		{
			if (f) putc('/', stdout);
			else f = 1;
			if (predec) printf("%c%d", b>7 ? 'a' : 'd', b % 8);
			else printf("%c%d", b>7 ? 'd' : 'a', 7 - b % 8);
		}
	}
	if (from) putc(',', stdout);
}

void op1(mode,reg)
{
	int	d;
	char	*s;
	long	l;

	if (mode < 5)
	{
		printf(fmts[mode], reg);
		return;
	}
	if (mode == 5)
	{
		printf("%d(a%d)", gword(), reg);
		return;
	}
	if (mode == 6)
	{
		d = gword();
		printf("%d(a%d,%c%d.%c)",
			BFIELD(d,7,8) | (BTST(d,7) ? 0xFF00 : 0), reg,
			BTST(d,15) ? 'a' : 'd', BFIELD(d,14,3),
			BTST(d,11) ? 'l' : 'w');
		return;
	}
	switch (reg)
	{
	case 0:	printf("%d.w", gword()); break;
	case 1:	symbolic(glong(), '\0'); break;
	case 2: l = gaddr;
		printf("%d(pc) {", d = gword());
		symbolic(l+d, '}');
		break;
	case 3: d = gword();
		printf("%d(pc,%c%d.%c)",
			BFIELD(d,7,8) | (BTST(d,7) ? 0xFF00 : 0),
			BTST(d,15) ? 'a' : 'd', BFIELD(d,14,3),
			BTST(d,11) ? 'l' : 'w');
		break;
	case 4: putc('#', stdout);
		if (gisize == LONG) symbolic(glong(), '\0');
		else if (gisize == BYTE) printf("%d", (char)gword());
		else printf("%d", gword());
		break;
	case 5: printf("sr"); break;
	}
}

void op2(f,m1,r1,m2,r2) /* f set means order passed, clear reverses order */
{
	if (f) op1(m1,r1); else op1(m2,r2);
	putc(',',stdout);
	if (f) op1(m2,r2); else op1(m1,r1);
}

void opmode(op, opm, reg, m, r)
	char *op;
{
	OPI(op, size[gisize=BFIELD(opm,1,2)]);
	op2(BTST(opm,2),0,reg,m,r);
}

long
dasm(addr,cnt, symflg)
	long addr;
{
	int	tflg = 0;
	register unsigned int w, m1, m2, r1, r2, op;
	char 	ds;

	gaddr = addr; gempty = 1;
	while (tflg || cnt--)
	{
		tflg = 0;
		if (symflg) symbolic(gaddr, '\t');
		else printf("0x%lx ", gaddr);
		w = gword();
		m1 = BFIELD(w,8,3); m2 = BFIELD(w,5,3);
		r1 = BFIELD(w,11,3); r2 = BFIELD(w,2,3);
		op = BFIELD(w,15,4);
		switch (op)
		{
		case 0x0:
			if (m2 == 1)
			{
				OPI("movep", BTST(w,6) ? 'l' : 'w');
				op2(BTST(w,7),0,r1,5,r2);
				break;
			}
			if (BTST(w,8))
			{
				OPI(bitop[BFIELD(w,7,2)], m2 ? 'b' : 'l');
				op2(1,0,r1,m2,r2);
				break;
			}
			if (r1 == 4)
			{
				OPI(bitop[BFIELD(w,7,2)], m2 ? 'b' : 'l');
				gisize = WORD;
				op2(1,7,4,m2,r2);
				break;
			}
			OPI(imedop[r1],size[gisize = m1]);
			op2(1,7,4,m2,r2);
			break;
		case 0x1:
			gisize = BYTE; goto domove;
		case 0x2:
			gisize = LONG; goto domove;
		case 0x3:
			gisize = WORD;

			domove:
				OPI("move", size[gisize]);
				op2(1,m2,r2,m1,r1);
			break;
		case 0x4:
			if (BTST(w,8))
			{
				if (BTST(w,6))
				{
					printf("lea\t");
					op1(m2,r2);
					printf(",a%d", r1);
					break;
				}
				printf("chk\t");
				op1(m2,r2);
				printf(",d%d", r1);
				break;
			}
			if (r1 < 4)
			{
				if (m1 == 3)
				{
					printf("move\t");
					gisize = WORD;
					if (r1 == 0) printf("sr,");
					op1(m2,r2);
					if (r1 == 2) printf(",ccr");
					if (r1 == 3) printf(",sr");
					break;
				}
				OPI(misc1[r1], size[m1]);
				op1(m2,r2);
				break;
			}
			else if (r1 == 4)
			{
				switch(m1)
				{
				case 0: printf("nbcd\t"); break;
				case 1: printf(m2 ? "pea\t" : "swap\t"); break;
				case 2:
				case 3:	OPI(m2 ? "movem" : "ext",
					    BTST(w,6) ? 'l' : 'w');
					if (m2) movem(1,m2==4, gword());
					break;
				}
				op1(m2,r2);
				break;
			}
			if (r1 == 5)
			{
				if (m1 == 3) printf("tas\t");
				else OPI("tst", size[m1]);
				op1(m2,r2);
				break;
			}
			if (r1 == 6)
			{
				OPI("movem", BTST(w,6) ? 'l' : 'w');
				op = gword();
				op1(m2,r2);
				movem(0,m2==4,op);
				break;
			}
			if (BTST(w,7))
			{
				printf(BTST(w,6) ? "jmp\t" : "jsr\t");
				op1(m2,r2);
				break;
			}
			switch (m2)
			{
			case 0:
			case 1:	printf("trap\t#%d", BFIELD(w,3,4));
				tflg = 1;
				break;
			case 2: printf("link\ta%d,#%d", r2, gword()); break;
			case 3: printf("unlk\ta%d", r2); break;
			case 4: printf("move.l a%d,usp", r2); break;
			case 5: printf("move.l usp,a%d", r2); break;
			case 6: printf(misc2[r2]); break;
			}
			break;
		case 0x5:
			if (BFIELD(w,7,2) == 3)
			{
				op = BFIELD(w,11,4);
				if (m2 == 1)
				{
					printf("db%s\td%d,",cc[op], r2);
					reladdr('\0');
				}
				else
				{
					printf("s%s\t",cc[op]);
					op1(m2,r2);
				}
			}
			else
			{
				printf("%sq.%c\t#%d,",BTST(w,8)?"sub":"add",
					size[BFIELD(w,7,2)],
					((r1 - 1) & 7) + 1);
				op1(m2,r2);
			}
			break;
		case 0x6:
			ds = BFIELD(w,7,8);
			printf("b%s.%c\t", cc[BFIELD(w,11,4)], ds ? 's' : 'w');
			if (ds) symbolic(gaddr+ds,'\0');
			else reladdr('\0');
			break;
		case 0x7:
			printf("moveq\t#%d,d%d",BFIELD(w,7,8),r1);
			break;
		case 0x8:
			if (m1 == 3 || m1 == 7)
			{
				printf("div%c\t", BTST(w,8) ? 's' : 'u');
				op2(0,0,r1,m2,r2);
			}
			else if (m1 == 4 && (m2 == 1 || m2 == 0))
			{
				printf(m2 ? "sbcd\t-(a%d),-(a%d)"
					  : "sbcd\td%d,d%d", r2, r1);
			}
			else
			{
				opmode("or",m1,r1,m2,r2);
			}
			break;
		case 0x9:
		case 0xD:
			if ((m2 == 0 || m2 == 1) && m1 > 3 && m1 < 7)
			{
				OPI(op == 9 ? "subx" : "addx",
					size[BFIELD(w,7,2)]);
				m2 <<= 2;
				op2(1,m2,r2,m2,r1);
			}
			else if (m1 == 3 || m1 == 7)
			{
				gisize = m1 == 3 ? WORD : LONG;
				OPI(op==9 ? "sub" : "add", size[gisize]);
				op2(1,m2,r2,1,r1);
			}
			else
			{
				opmode(op==9 ? "sub" : "add",m1,r1,m2,r2);
			}
			break;
		case 0xB:
			if (BTST(w,8))
			{
				if (m2 == 1)
				{
					OPI("cmpm", size[BFIELD(w,7,2)]);
					printf("(a%d)+,(a%d)+",r2,r1);
				}
				else
				{
					opmode("eor",m1,r1,m2,r2);
				}
			}
			else
			{
				opmode("cmp",m1,r1,m2,r2);
			}
			break;
		case 0xC:
			if (m1 == 3 || m1 == 7)
			{
				printf("mul%c\t", m1==7 ? 's' : 'u');
				op2(0,0,r1,m2,r2);
			}
			else if (m1 == 4 && (m2 == 1 || m2 == 0))
			{
				printf(m2 ? "abcd\t-(a%d),-(a%d)"
					  : "abcd\td%d,d%d", r2, r1);
			}
			else if (m1 == 5)
			{
				op = BTST(w,3) ? 'a' : 'd';
				printf("exg\t%c%d,%c%d",op,r1,op,r2);
			}
			else if (m1 == 6)
			{
				printf("exg\td%d,a%d",r1,r2);
			}
			else
			{
				opmode("and",m1,r1,m2,r2);
			}
			break;
		case 0xE:
			if (BFIELD(w,7,2) == 3)
			{
				printf("%s%c.w\t",shf[BFIELD(w,10,2)],
					BTST(w,8) ? 'l' : 'r');
				op1(m2,r2);
			}
			else
			{
				printf("%s%c.%c\t",shf[BFIELD(w,4,2)],
					BTST(w,8) ? 'l' : 'r',
					size[BFIELD(w,7,2)]);
				if (BTST(w,5))
				{
					op2(1,0,r1,0,r2);
				}
				else
				{
					printf("#%d,",r1);
					op1(0,r2);
				}
			}
			break;
		case 0xA:
		case 0xF:
			printf("%x", w);
			break;
		}
		putc('\n',stdout);
	}
	return gaddr;
}
