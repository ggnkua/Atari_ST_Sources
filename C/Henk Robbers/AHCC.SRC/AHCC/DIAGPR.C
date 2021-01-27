/* Copyright (c) 1988,1989 by Sozobon, Limited.  Author: Johann Ruegg
 *           (c) 1990 - present by H. Robbers.   ANSI upgrade.
 *
 * This file is part of AHCC.
 *
 * AHCC is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * AHCC is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with AHCC; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

/*
 * diagpr.c
 *
 * diagnostic print routines
 *
 */

#define PROCESS_H
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <tos.h>
#include "param.h"		/* defines & undefines DEF_ENUM */

long bios( void, ... );

#define debugT (G.xflags['t'-'a'])	/* extended types */
#define debugO (G.xflags['o'-'a'])	/* NO nflags or code or type */
#define debugK (G.xflags['k'-'a'])	/* print keyword cataguories */
#define debugN (G.xflags['n'-'a'])	/* print at all */
#define debugY (G.xflags['y'-'a'])	/* print node addresses */
#define debugW (G.xflags['w'-'a'])	/* wait */


global
Cstr sss(Cstr s)
{
	return s ? s : "~~~~~";
}

static
short precur = 0;

#define DEF_DIAG 1		/* used by defs.h in combo with DEF_TOKS to create names of tokens from enum param (#e) */

#define DEF_PO_CODE 1
static
Cstr ascodes[] =
{
	"INVOP",
#include "po_defs.h"
};
#undef DEF_PO_CODE

Cstr amodes[] =
{
	"NONE",
	"REG",
	"REGI",
	"REGINC",
	"DECREG",
	"REGID",
	"REGIDX",
	"REGIDXX",
	"PCD",
	"PCDX",
	"PCDXX",
	"IMM",
	"ABS",
	"INSTD",
	"RLST",
	"CONDREG",
	"SPPLUS",
	"FCREG"
};

Cstr aflgs[] =
{
	"|XL",
	"|SYM",
	"|AW",
	"|BD",
	"|OD",
	"|MI",
	"|INC",
	"|DEC"
};

global
Cstr pr_amode(ushort am)
{
	short m = am & 0xff, f = am>>8, i = 0;
	static char mt[32];

	strcpy(mt, amodes[m]);
	while(f)
	{
		if (f&1)
			strcat(mt, aflgs[i]);
		i++;
		f >>= 1;
	}
	return mt;
}

extern char *ordinal[];

global
void pr_opnd(short n, OPND *a, char *text)
{
	if (a)
	{
		send_msg("%s%s%s, ", ordinal[n], text, pr_amode(MO(a->am)) );
		send_msg("disp %ld, areg %d, ireg %d, ", a->disp, a->areg, a->ireg);
		send_msg("[%d]%s+%ld\n", a->aname, a->astr ? a->astr : "~10~", a->namedisp);
		if (a->outd)
			if (MO(a->outd->am) ne NONE)
			{
				send_msg("\t");
				pr_opnd(n, a->outd, "OUTD ");
			}
	}
	else
		send_msg("~~ operand\n");
}

global
Cstr pascode(short tok)
{
	static char rt[16];

	if ( tok <= 0 or tok > LDSR )
		sprintf(rt, "?[1]x%x?", tok);
	else
		sprintf(rt, "%s", ascodes[tok]);
	return rt;
}

#if AMFIELDS
void popond(OPND *op, short c)
{
	if (op)
	{
		if (op->am.i)
		{
			if (c)
				send_msg("%c", c);
			switch(op->am.f.m)
			{
				case REG:
					send_msg(preg(op->areg));	break;
				case REGI:
					if (op->am.f.inc)
						send_msg("(%s)+", preg(op->areg));
					elif (op->am.f.dec)
						send_msg("-(%s)", preg(op->areg));
					else
						send_msg("(%s)", preg(op->areg));
					break;
				case REGID:
					send_msg("%ld(%s)", op->disp, preg(op->areg));	break;
				case REGIDX:
					send_msg("%ld(%s, %s.%c)",
							op->disp,
							preg(op->areg),
							preg(op->ireg),
							op->am.f.xl ? 'l' : 'w' ); break;
				default:
					send_msg("mode > REGIDX");
			}
		}
	}
}
#else
static
void popond(OPND *op, short c)
{
	if (op)
	{
		if (op->am)
		{
			if (c)
				send_msg("%c", c);
			switch(op->am&~XLONG)
			{
				case REG:
					send_msg(preg(op->areg));	break;
				case REGI:
					send_msg("(%s)", preg(op->areg));	break;
				case REGI|INC:
					send_msg("(%s)+", preg(op->areg));	break;
				case REGI|DEC:
					send_msg("-(%s)", preg(op->areg));	break;
				case REGID:
					send_msg("%ld(%s)", op->disp, preg(op->areg));	break;
				case REGIDX:
					send_msg("%ld(%s, %s.%c)",
							op->disp,
							preg(op->areg),
							preg(op->ireg),
							(op->am&XLONG) ? 'l' : 'w' ); break;
				default:
					send_msg("mode > REGIDX");
			}
		}
	}
}
#endif

static
Cstr pflags(unsigned short flags, Cstr ty[])
{
	static char s[512];
	short i = 0;

	s[0] = 0;
	while (flags ne 0)
	{
		if (flags&1)
		{
			if (s[0])
				strcat(s, "|");
			strcat(s, ty[i]);
		}
		flags >>= 1;
		i++;
	}
	return s;
}

#define pflg(a) if (f.f.a) strcat(fs, #a "|")

static
void n_flags(NP np)
{
	char fs[64], *s;

	NFLAGS f = np->nflgs;
	if (f.i)
	{
		strcpy(fs,"N[");
		pflg(free);
		pflg(brk_l);
		pflg(nexp);
		pflg(spar);
		pflg(lcat);
		pflg(rcat);
/*		pflg(bas);
*/		pflg(res);
		pflg(n_ct);
#if BIP_ASM
		pflg(asmac);
		pflg(p1ws);
		pflg(follows);
		pflg(dot);
#endif
		pflg(nheap);
		s = fs + strlen(fs)-1;
		*s++ = ']';
		*s = 0;
		send_msg("%s\t", fs);
	}
}

static
void c_flags(NP tp)
{
	char fs[64], *s;

	CFLAGS f = tp->cflgs;
	if (f.i)
	{
		strcpy(fs,"C[");
		pflg(undef);
		pflg(see_reg);
		pflg(is_arg);
		pflg(cdec);
		pflg(sysc);
		pflg(rlop);
		pflg(cfop);
		pflg(ided);
		pflg(leaf);
		pflg(s_ef);
		pflg(equ);
		pflg(qc);
		pflg(qv);
		pflg(q);
		pflg(inl_v);
		pflg(asm_f);	/* All 16 bits used */
		s = fs + strlen(fs)-1;
		*s++ = ']';
		*s = 0;
		send_msg("%s\t", fs);
	}
}

#if FOR_A
static
void a_flags(TP tp)
{
	char fs[64], *s;

	AFLAGS f = tp->aflgs;
	if (f.i)
	{
		strcpy(fs,"A[");
		pflg(lproc);
		pflg(deref);
		pflg(ns);
		pflg(np);
		pflg(nf);
		s = fs + strlen(fs)-1;
		*s++ = ']';
		*s = 0;
		send_msg("%s\t", fs);
	}
}
#endif

static
void t_flags(TP tp)
{
	char fs[64], *s;

	TFLAGS f = tp->tflgs;
	if (f.i)
	{
		strcpy(fs,"T[");
		pflg(formal);
		pflg(saw_array);
		pflg(old_args);
		pflg(ans_args);
		pflg(asm_func);
		pflg(saw_proc);
		pflg(pu);
		pflg(tm);
		pflg(lpr);
		pflg(rpr);
		pflg(qd);
#if USAGE
		pflg(isarg);
		pflg(used);
		pflg(inid);
#endif
		s = fs + strlen(fs)-1;
		*s++ = ']';
		*s = 0;
		send_msg("%s\t", fs);
	}
}

static
void e_flags(NP np)
{
	char fs[64], *s;

	EFLAGS f = np->eflgs;
	if (f.i)
	{
		strcpy(fs,"E[");
		pflg(typed);
		pflg(varg);
		pflg(rname);
		pflg(lname);
		pflg(imm);
		pflg(cc);
		pflg(see_f);
		pflg(see_l);
		pflg(see_u);
		pflg(l_ass);
#if COLDFIRE
		pflg(cfl);
#endif
#if BIP_ASM
		pflg(asm_w);
		pflg(asm_l);
#endif
#if LL
		pflg(see_ll);
#endif
		pflg(pu);
		pflg(ftyp);		/* All 16 bits used */
		s = fs + strlen(fs)-1;
		{
			*s++ = ']';
			*s = 0;
			send_msg("%s\t", fs);
		}
	}
}

global
Cstr pcoflags(short f)
{
	static char fs[64], *s;
	if (f eq 0)
		return "";
	fs[0] = 0;
	if (f&CC_OK)
		strcat(fs, "CC_OK|");
	if (f&IMMA_OK)
		strcat(fs, "IMMA_OK|");
	if (f&NOVAL_OK)
		strcat(fs, "NOVAL_OK");
	s = fs + strlen(fs) - 1;
	if (*s eq '|')
		*s = 0;
	return fs;
}

#define DEF_A_FLAGS 1
static Cstr clsflags[] =
{
#include "defs.h"
};
#undef DEF_A_FLAGS

global
Cstr pclflags(short flags)
{
	return pflags(flags, clsflags);
}

#define DEF_K_FLAGS 1
static
Cstr catags[] =
{
#include "defs.h"
};
#undef DEF_K_FLAGS

global
Cstr pcat0(ushort flags)
{
	return pflags(flags, catags);
}

static
Cstr pcat1(uchar flags)
{
	return pflags(flags, catags + 16);
}

#define DEF_TOKS 1
static
Cstr ntypes[] =
{
#include "defs.h"
	"        "
};
#undef  DEF_TOKS

short alert_text(char *, ...);

global
void prntypesize(void)
{
alert_text(" size of ntypes | %ld/%ld = %ld ", sizeof(ntypes),sizeof(Cstr), sizeof(ntypes)/sizeof(Cstr));
}

global
Cstr prtok(void *vp)
{
	XP tp = vp;
	short tok = tp->token;
	Cstr name = tp->name ? tp->name : "~~~";
	static char rt[32];

	if ( tok < 0 or tok > ASSIGN TOKMASK )
		sprintf(rt, "%s<?[2]x%x?>%s", name, tok);
	elif ( (tok&TOKMASK) >= LASTTOK)
		sprintf(rt, "%s<%s?x%x?>%s", name, (tok&(ASSIGN 0))?"AS":"", tok&TOKMASK);
	else
		sprintf(rt, "%s<%s%s>", name, (tok&(ASSIGN 0))?"AS":"", ntypes[tok&TOKMASK]);
	return rt;
}

global
Cstr ptok(short tok)
{
	static char rt[16];

	if ( tok < 0 or tok > ASSIGN TOKMASK )
		sprintf(rt, "?x%x?", tok);
	elif ( (tok&TOKMASK) >= LASTTOK)
		sprintf(rt, "%s?x%x?", (tok&(ASSIGN 0))?"AS":"", tok&TOKMASK);
	else
		sprintf(rt, "%s%s", (tok&(ASSIGN 0))?"AS":"", ntypes[tok&TOKMASK]);
	return rt;
}

global
Cstr pntype(short ty)
{
	static char rs[8] = "0";

	if (ty eq -1)
	{
		rs[0] = '?';
		rs[1] = 0;
	othw
		if (ty ne 0 and (ty < FIRSTTY or ty >= LASTTY) )
		{
			sprintf(rs, "?[3]x%x?", ty);
		othw
			rs[0] = "~>XEGTSFCPRDLIlib"[ty];
			rs[1] = ':';
			rs[2] = 0;
		}
	}
	return rs;
}

global
Cstr psclass(NP np)
{
	static char ps[20];
	unsigned short sc = np->sc;
	*ps = 0;
	if ( sc )
	{
		if (sc >= LASTTOK )
			sprintf(ps, "\tsc: ?x%x?", sc);
		elif (np->cat0&SC)
	 		return ntypes[sc]+2;			/* w/o K_ */
	 	else
	 		return ntypes[sc];
	}
	return ps;
}

static
Cstr etypes[] =
{
	"E_LEAF",
	"E_UNARY",
	"E_BIN",
	"E_SPEC",
	"        "
};

static
Cstr gtypes[] =
{
	"EV_NONE",
	"EV_LEFT",
	"EV_RIGHT",
	"NO_EV",
	"EV_LR",
	"EV_RL",
	"EV_LRSEP",
	"EV_RLSEP",
	"            "
};

global
Cstr petype(NP np)
{
	short ety = np->tt;

	if ( np->nt eq EXNODE and ety < 0  or ety > E_SPEC )
	{
		ety = E_SPEC+1;
		sprintf((Wstr)etypes[ety], "?[4]x%x?", np->tt);
	othw
		if ( ety < 0 or ety > EV_RLSEP )
		{
			ety = EV_RLSEP + 1;
			sprintf((Wstr)gtypes[ety], "?[5]x%x?", np->tt);
		}
	}
	return (np->nt eq EXNODE ? etypes[ety] : gtypes[ety]);
}

static
Cstr storage[] =
{
	"t:0",
	"ET_CC",
	"ET_FC",
	"ET_XC",
	"ET_B",
	"ET_S",
	"ET_U",
	"ET_P",
	"ET_R",
	"ET_A",
	"            "
};
global
Cstr pty(short sty)
{
	if ( sty < 0 or sty > ET_A )
	{
		sprintf((Wstr)storage[ET_A+1], "?[6]x%x?", sty);
		sty = ET_A+1;
	}
	return (storage[sty]);
}

static
Cstr contexts[] =
{
	"NONE",
	"FORSIDE",
	"FORPUSH",
	"FORCC",
	"FORIMA",
	"FORADR",
	"FORLVAL",			/* 12'08 HR usage tracking */
	"FORINIT",
	"IND0",
	"INF0",
	"INA0",
	"SWITCH",
	"RETSTRU",
	"FORLINIT",
	"FORLAINIT",
	"FORVALUE",
	"FORTRUTH",
	"FORASM",
	"FORSEE",
	"FOR x????????????????"
};

global
Cstr prcntxt(short context)
{
	if (context < 0 or context >= HIGHCONTEXT)
	{
		sprintf((Wstr)&contexts[HIGHCONTEXT][5], "%x", context);
		return contexts[HIGHCONTEXT];
	}
	return contexts[context];
}

global
Cstr pclass(short class)
{
	static char pa[20];
	if (class >= 0 and class < high_class)
		return class_names[class];

	sprintf(pa, "A:%d(0x%x)", class, class);
	return pa;
}

static
char ra[3][4] = {" D ", " F ", " A "}, fr[10];

global
Cstr preg(short r)
{
	if (r eq -1)
		return "";

	if (r < 0 or r >= 24)
	{
		sprintf(fr, "~r:0x%x", r);
		return fr;
	othw
		short tr = r>>3;
		ra[tr][2] = (r&7)+'0';
		return ra[tr];
	}
}

static
short tel = 0;

static
void conwait(short brk)
{
	if (++tel eq brk and bugf eq stdout)
	{
		bios(2, 2);
		tel = 0;
		send_msg("\n");
		if break_in
			exit(0);
	}
}

#define DEF_TOK_FLAGS 1
static
Cstr tokflags[] =
{
#include "defs.h"
};
#undef  DEF_TOK_FLAGS

#include "pre.h"

global
void printtoks(void)
{
	short brk = 32;  /* or journal hight -1 or screen hight -1 */
	short i, tok = 0;

	tok_init();

	send_msg("LASTTOK = %d\n",LASTTOK);
	send_msg("Enum tokens:\n");
	while(tok <= LASTTOK)
	{
		send_msg("%3d\t0x%2x\t%-10s%-12s\n", tok, tok, ntypes[tok], graphic[tok]);
		tok++;
		conwait(brk);
	}

	send_msg("\fC_lex:\n");
	for (i = 0; i<TOKSIZE; i++)
	{
		if (C_lex[i].text eq nil)
			break;
		send_msg("%3d\t%-12s t:%3d %s\n",
			i,
			C_lex[i].text,
			C_lex[i].value,
			ntypes[C_lex[i].value]);
		conwait(brk);
	}
	send_msg("\fC_tok\n");

	for (i = 0; i<TOKSIZE; i++)
	{
		if (C_tok[i])
		{
			TOKEN *pt = C_tok[i];
			send_msg("%3d %-12sp:%2d t:%3d %-16s",
							i, pt->text, pt->prec, pt->value,
							pflags(pt->flags, tokflags));
			send_msg("%s", pcat0(pt->cat0));
			send_msg(",%s", pcat1(pt->cat1));
			if (pt->x)
				if (pt->cat0&BASIC)
					send_msg("%d", pt->x);
				else
					send_msg("%s", ntypes[pt->x]);
			send_msg("\n");
			conwait(brk);
		}
	}
	send_msg("\f");
}

static
void name_x(NP np)
{
	send_msg("<");
	send_name(np);
	send_msg(">\t");
}

static
void t_data(TP tp)
{
		send_msg("%s ",ptok(tp->token));
	if (!debugY)
		send_msg("%s%lx\t", pntype(tp->nt), tp);

	if debugK
		if ( tp->cat0 )
			send_msg("c0[%s]\t",
					pcat0(tp->cat0) );
		if ( tp->cat1 )
			send_msg("c1[%s]\t",
					pcat1(tp->cat1) );

	if ( tp->sc )
		send_msg("%s\t", psclass((NP)tp) );
	t_flags(tp);
	c_flags((NP)tp);
	if (!debugO)
		n_flags((NP)tp);
#if FOR_A
	a_flags(tp);
#endif
	if (tp->fld.width )
		send_msg("(%d,%d)\t", tp->fld.width, tp->fld.offset);
	if ( tp->size or tp->aln )
		send_msg("%s\ts:%ld\ta:%d\t",
				pty(tp->ty),
		        tp->size,
		        tp->aln);
	if ( tp->offset)
		send_msg("o:%ld\t",
		        tp->offset);
	if ( tp->area_info.class )
		send_msg("(%s)%d.%ld\t", pclass(tp->area_info.class), tp->area_info.id, tp->area_info.disp);
}

static
void tprint(TP np, short indent, short which)			/*	typelist nodes */
{
	short ni, ind;
	TP tp;

	if break_in return;		/* for loopholes in node graphs (thats why you need debugging) */

	ni = indent+1;
	ind = indent;
	while (ind--) send_msg("  ");
	if (np eq nil)
		send_msg("<nil>\n");
	else
	{
		tp = np;
		if (debugT)
		{
			while (np)
			{
				send_msg(" Type{ ");
				name_x((NP)np);
				t_data(np);
				send_msg(" } ");
				np = np->type;
			}

			send_msg("\n");

			while(tp)
			{
				if (tp->next)
					if (tp->tflgs.f.lpr eq 0 and tp->nflgs.f.brk_l eq 0)
					{
						tp->tflgs.f.lpr = 1;
						if (!debugY)
							send_msg("%lx", tp);
						send_msg("L\t");
						tprint(tp->next, ni, 1);
						tp->tflgs.f.lpr = 0;
					}

				if (tp->list)
					if (tp->tflgs.f.rpr eq 0)		/* 11'13 HR struct x { struct x *y .... } */
					{
						tp->tflgs.f.rpr = 1;
						if (!debugY)
							send_msg("%lx", tp);
						send_msg("R\t");
						tprint(tp->list, ni, 2);
						tp->tflgs.f.rpr = 0;
					}

				tp = tp->type;
			}
		}
		else
			send_msg("\n");
	}
}

static bool check_tt(NP np)
{
	if (np->tt eq NO_EV)
		return true;
	switch(np->nt)
	{
	case EXNODE:
		switch(np->tt)
		{
			case E_BIN:
			case E_SPEC:
				return true;
		}
	return false;
	case GENODE:
		switch(np->tt)
		{
			case EV_RIGHT:
			case EV_RL:
			case EV_LR:
			case EV_LRSEP:
			case EV_RLSEP:
				return true;
		}
	return false;
	default:
		return true;
	}
}

static
void cprint(NP np) /* np is the GENODE !! */
{
	VP tp;
	short i;

	send_msg("\ncode: ");
	if (np->betw)
	{
		tp = np->betw;
		for (i = 0; i < tp->tnr; i++)
			send_msg("\"%s\"", tp->ts[i]);
		send_msg("\n");			/* 04'14 v5.1 */
	}

	if (np->nflgs.f.n_ct)					/* code is a string */
		send_msg("\"%s\"", np->type);
	else
		for (tp = (VP)np->type; tp; tp = tp->codep)	/* code is a list */
			for (i = 0; i < tp->tnr; i++)
				send_msg("%s", tp->ts[i]);
}

static
void prnode(NP np, char *lr, short indent)
{
	short ni, ind;

	precur++;
	ni  = indent+1;
	ind = indent;

	if (!break_in)		/* for loopholes in node structure (thats why you need debugging) */
	{
		if (ind)
			while (ind--) send_msg("    ");	/* 1 less then actual indentation because of "L   " or "R   " */

		if (np eq nil)
			send_msg("<nil>\n");
		else
		{
			if (lr)
				send_msg("%s:\t", lr);

			send_msg("%ld:", np->fl.ln);
#if C_DEBUG
			/* presentation of diags according to current usage. */
			if (np->diags)
				send_msg("\tD=%ld\t", np->diags);
#endif
			if (np->nt eq TLNODE)
			{
				name_x(np);
				send_msg("%s\t", ptok(np->token));
				t_data((TP)np);
			}
			elif (np->nt eq INNODE)
			{
				IP ip = (IP)np;
				send_msg("op:%s.%d  ",
							pascode(ip->opcode), ip->sz);
				if (ip->reg >= 0)
					send_msg("%s", preg(ip->reg) );
				send_msg("\t");
				popond(ip->arg,         0 );
				popond(ip->arg->next,  ',');
			othw								/* X, E, Gnode */
				name_x(np);
				if (!(np->nt eq DFNODE or np->nt eq STNODE))
					if ( np->lbl)
						send_msg("\tL%d",  np->lbl);
				send_msg("\t%s\t",  ptok(np->token));
				if (!debugY)
					send_msg("%s%lx\t",  pntype(np->nt),  np);
				if (np->nt ne DFNODE)
					send_msg("%s\t", petype(np));
				if debugK
				{
					if ( np->cat0)
						send_msg("%s\t", pcat0(np->cat0) );
					if ( np->cat1)
						send_msg(",%s\t", pcat1(np->cat1) );
				}
				if ( np->sc )
					send_msg("%s\t",
					        psclass(np) );
				c_flags(np);
#if FOR_A
				a_flags((TP)np);
#endif
				if (np->nt eq TLNODE)
					t_flags((TP)np);
				else
					e_flags(np);
				if ( np->prec )
					send_msg("p:%d\t", np->prec);

				if ( np->val.i )
#if FLOAT
					if ( np->token eq FCON )
						send_msg("F:%lx\t", np->val.i);
	/* TURBO C hack voor float: gebruik val.i omdat TC float naar double converteerd
		als de float op de stack moet */
					elif ( np->token eq RCON and np->val.dbl)
						send_msg("D:%08lx %08lx%08lx\t", getrcon(np));
					else
#endif
#if LL
					if ( np->token eq LCON and np->val.dbl)
						send_msg("L:%08lx%08lx\t", getlcon(np));
					else
#endif
					if (np->token eq ICON)
						send_msg("I:%ld\t", np->val.i);
					else
						send_msg("o:%ld\t", np->val.i);

				if (np->nt > DFNODE and np->area_info.class)
					send_msg("(%s)%d.%ld\t", pclass(np->area_info.class), np->area_info.id, np->area_info.disp);

				if (np->nt > DFNODE)
				{
					if (np->size)
						send_msg("s:%ld\t", np->size);
					if (np->rno ne -1)
						send_msg("%s\t", preg(np->rno));
					if (np->fld.width)
						send_msg("(%d,%d)\t", np->fld.width, np->fld.offset);
					if (np->vreg.r)
						send_msg("<<v%dl%ds%d>>\t", np->vreg.r, np->vreg.l, np->vreg.s);
					if ( np->ty)
						send_msg("%s\t",
							pty(np->ty));
		/*				if (np->aln ne 1)
						send_msg("a:%d\t", np->aln);		*/


					if (np->nt eq GENODE  )
					{
						if ( *(short *)&np->needs )
							send_msg("n:#%03x\t", np->needs);
						if ( np->r1 ne -1 )
							send_msg("r1:%s\t", preg(np->r1));
						if ( np->r2 ne -1 )
							send_msg("r2:%s\t", preg(np->r2));
						if ( np->Tl)
							send_msg("Tl:%d\t", np->Tl);
						if ( np->Fl)
							send_msg("Fl:%d\t", np->Fl);
						if ( np->brt)
							send_msg("%s\t", ptok(np->brt + BR_TOK));
						if ( np->chunk_size )
							send_msg("chunk_size:%d\t", np->chunk_size);
						if ( np->misc1 )
							send_msg("misc1:%d\t", np->misc1);
						if ( np->misc )
							send_msg("misc:%ld\t", np->misc);
					}
				}
			}

			if (!debugO)
				n_flags(np);

			if (np->nflgs.f.free eq 0)
			{
				if (!np->type or debugO)
					send_msg("\n");
				elif (np->nt eq GENODE)
					cprint(np);
				elif (np->nt eq EXNODE)
					tprint(np->type, 0, 3);
				elif (np->nt eq DFNODE)
				{
					send_msg("\n");
					prnode((NP)((XP)np)->tseq, nil, ni);
				}

				if (np->nt ne INNODE)
				{
					if (np->left)
					{
						if (np->tt eq E_LEAF)
							send_msg("**** E_LEAF and left %8lx-->%8lx\n", np, np->left);
						elif (np->left ne np)
						{
							if (np->tt ne E_UNARY and !check_tt(np))
								send_msg("**** Left :%08lx tt %d\n", np, np->tt);
							else
								prnode(np->left, "L", ni);
						}
						else
							send_msg("**** left loophole %08lx\n", np);
					}

					if (np->right)
					{
						if (np->right ne np)
						{
							if (!check_tt(np))
								send_msg("**** right:%08lx tt %d\n", np, np->tt);
							else
								prnode(np->right, "R", ni);
						}
						else
							send_msg("**** right loophole %08lx\n", np);
					}
				}
			}
			else
				send_msg("**** free node %08lx\n", np);
		}
	}
	if (--precur eq 0 and bugf eq stdout and debugW) bios(2, 2);
}

static
void prln(NP np, short indent)
{
	NP svl, nxtl;

	for (svl = np; svl ne nil; svl = nxtl)
	{
		nxtl = svl->left;
		svl->left = nil;
		prnode(svl, "*", indent);	/* "*" = root */
		svl->left = nxtl;
		/* special hack for tag list */
		if (svl->nflgs.f.brk_l and svl->right)
			prln(svl->right, indent+2);
	}
}

global
void printlist(TP np)
{
	send_msg("\n");
	prln((NP)np, 2);
}

global
void frcprnode(NP np)		/* not used yet */
{
	if(debugW)
	{
		send_msg("\n");
		prnode(np, "*", 0);
	othw
		ONY('w');
		send_msg("\n");
		prnode(np, "*", 0);
		OFFY('w');
	}
}

global
void print_node(void *vp, char * s, bool wait, bool thisT)
{
#if 1
	TP tp = vp; short t = debugT, o = debugO;

	if (s)
		send_msg("\n--== %s ==--", s);

	debugT = thisT;
	debugO = 0;

	send_msg("\n");

	if (tp and tp->nt eq TLNODE)
		tprint(tp, 0, 4);
	else
		prnode(vp, "*", 0);

	debugT = t;
	debugO = o;
	if (wait)
		Cconin();
#endif
}

global
void printnode(void *vp, bool wait)
{
	TP tp = vp;
	if (debugN)
	{
		send_msg("\n");
		if (tp and tp->nt eq TLNODE)
			tprint(tp, 0, 5);
		else
			prnode(vp, "*", 0);
	}
	if (wait)
		Cconin();
}

/* short single line print of just 1 node */
global
void pnode_1(void *vp, Cstr txt, bool wait)		/* ad hoc printing of fields */
{
	NP np = vp;
	if (np)
	{
		console("%s: %s, %s%lx '%s' ", txt, ptok(np->token), pntype(np->nt), np, sss(np->name));
		n_flags(np);
		if (np->nt eq TLNODE)
			t_flags((TP)np);
		c_flags(np);
	}
	else
		console("<nil>");
	console("\n");
}

#if C_DEBUG
global
short pstk = 0;

global
void paragraph(Cstr s)
{
	short ct = pstk;
	while (ct--)
		send_msg("_ ");
	send_msg("-= %s =-\n", s);
/*	pstk++; */
}
#else
global
void paragraph(Cstr s)
{
	send_msg("-= %s =-\n", s);
}
#endif

static char pmb[512];
global
void pm_print(NP np)
{
	postmort(pmb, np, 28, ' ');
	send_msg("%lx:{[%s]}\n", np, pmb);
}
