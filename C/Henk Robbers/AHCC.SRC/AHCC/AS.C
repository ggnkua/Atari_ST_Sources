/* Copyright (c) 2004 - present by H. Robbers.
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

/* standard Motorola assembler
 * capable of using C data declarations
 */

#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include <tos.h>
#include "param.h"
#include "common/mallocs.h"

#include "decl.h"
#include "body.h"
#include "d2.h"
#include "pre.h"

#include "opt.h"
#include "inst.h"
#include "out.h"
#include "reg.h"
#include "po.h"
#include "as.h"

char *pclass(short);
VpV free_equs;

#pragma warn -aus

#ifdef PRELUDE_H
#if ! __ABC__
#undef and
#undef or
#undef not
#endif
#endif

#define DEF_AS_PROTO 1
#include "as_defs.h"

#define DEF_AS_OP 1
global
ASDATA asdata[] =
{
	{"invalid"},
#include "as_defs.h"
	{0L}
};

#ifdef PRELUDE_H
#if ! __ABC__
#define and &&
#define or ||
#define not !
#endif
#endif

static
ASM_TAB **asm_tab = nil;

global
void new_dotscope(void)
{
	if (G.dot_labels)
	{
		freeTn(G.dot_labels);
		G.dot_labels = nil;
	}
}

global
short dot_sym(TP tp)
{
	if (tp eq nil)
		return 0;

	tp->lbl = new_lbl();
	tp->type = basic_type(T_LONG, 0);
	to_nct(tp);
	putt_lifo(&G.dot_labels, tp);
	return tp->lbl;
}

static
short find_asmop(Cstr opc)
{
	ASM_TAB *ab;
	char o[256];

	if (*opc eq '=' and *(opc+1) eq 0)
		return A_set;

	strcpy(o, opc);
	strlwr(o);
	ab = asm_tab[ophash(o)];
	while (ab)
	{
		if (strcmp(ab->name, o) eq 0)
			return ab->tok;
		ab = ab->link;
	}

	return 0;
}

static
bool asmc_setup(void)
{
	if (asm_tab)
		return true;
	else
	{
		short opc = 1;
		ASDATA *id = asdata + opc, *ad = asdata;

		/* for opcc (operation ## condition) type instructions eg beq, sne, fdbolt */
		w_A *remember_w;
		p_A *remember_p;

		while(ad->text)
		{
			if (ad->parse)
				remember_w = ad->out,
				remember_p = ad->parse;
			else
				ad->out = remember_w,
				ad->parse = remember_p;
			++ad;
		}

		asm_tab = CC_xcalloc(1, sizeof(void *) * OPHASH, AH_ASMC_SETUP, nil);

		if (asm_tab eq nil)
			return false;

		while (id->text)
		{
			short hval;
			ASM_TAB *at = CC_xmalloc(sizeof(*at), AH_ASMC_SETUP, nil);
			if (at eq nil)
				return false;

			hval = ophash(id->text);
			at->link = asm_tab[hval];
			at->name = id->text;
			at->tok = opc;
			asm_tab[hval] = at;
			++id;
			++opc;
		}
	}

	return true;
}

global
void asmc_end(void)
{
	CC_xfree_all(AH_ASMC_SETUP);
	asm_tab = nil;
}

static
bool is_line(XP np)
{
	switch(np->token)
	{
		case TIMES:
		case ENDS:
		case BINOR:
			return false;
	}

	return true;
}

static
OPND oplist[6];
static
short opndcnt;

global
OPND *newop(void)
{
	OPND *new = &oplist[opndcnt++];
	pzero(new);
	return new;
}

static
char * p_cpu(enum cpus cpu)
{
	long l;
	static char s[128];

	s[0] = 0;

	cpu &= 0777;

	if (cpu eq 0)
		return "MC68000";
	if (cpu & _1)
		strcat(s, "MC68010,");
	if (cpu & _2)
		strcat(s, "MC68020,");
	if (cpu & _3)
		strcat(s, "MC68030,");
	if (cpu & _4)
		strcat(s, "MC68040,");
	if (cpu & _6)
		strcat(s, "MC68060,");
	if (cpu & _32)
		strcat(s, "CPU32,");
	if (cpu & _CF)
		strcat(s, "ColdFire,");
	if (cpu & _5)
		strcat(s, "MC68851,");
	if (cpu & _8)
		strcat(s, "MC68881/2");

	if (s[0] eq 0)
		return "Unknown";

	l = strlen(s) - 1;

	if (s[l] eq ',')
		s[l] = 0;
	return s;
}

global
void cpuerr(void)
{
	error("instruction not available on current cpu type (%s)", p_cpu(G.CPU));
}

global
bool cpu_ok(ASDATA *d)
{
	if ((d->cpu & _S) ne 0 and (G.CPU & _S) eq 0)
	{
		error("'%s' is privileged instruction", d->text);
		return false;
	}
	if ((d->cpu & ~_S) eq 0)
		return true;
	if (d->cpu & G.CPU)
		return true;
	cpuerr();
	return false;
}

static
bool is_set(XP np)
{
	switch (find_asmop(np->name))
	{
		case A_equ:
		case A_set:
			return true;
	}

	return false;
}

globalXP last_label = nil;

static
short after_newline(void)
{
	short ws = 0;
	G.skip_X = true;					/* dont expand */
	while (cur->token ne NL and cur->token ne EOFTOK)
		fadvnode();

	G.skip_X = false;
	ws = cur->nflgs.f.p1ws;
	fadvnode();
	return ws;
}

/* basic assembler main loop */
static
void asm_loop(short delim)
{
	short ws = 0;
	last_label = nil;

	while (cur->token ne delim and cur->token ne EOFTOK)
	{
		XP ll;
		short tok, incl;
		Cstr ptok(short ty);

		if break_in break;

		if (cur->token eq NL)
			ws = cur->nflgs.f.p1ws;

#if 0
		send_msg("----- %ld -%c--- %s %s %s\n",
		lineno, ws ? 'W' : '-', ptok(cur->token), cur->name, G.iftab->p.truth ? "" : "~~~~");
#endif

		if (is_line(cur))
		{
			if (cur->token eq SELECT)
			{
				fadvnode();
				if (cur->token eq ID)
					cur->nflgs.f.dot = 1;
			}

			if ((cur->cat1 & S_KW) eq 0 and is_alpha(*cur->name))
				cur->token = ID;

			incl = tok = find_asmop(cur->name);

			if (tok > 0)				/* opcode */
			{
				if (G.iftab->p.truth or asdata[tok].flag)
				{
					INODE i = {0}, *ip = &i;
					OPND arg = {0}, dst = {0}, aod = {0}, dod = {0};

					ll = cur;
					advnode();		/* skip opcode */

					G.dot_seen = false;

					if (cur->token eq LABEL)
					{
						p_label(ll, 0, P.in_module);
						if (cur->token eq NL)
							ws = after_newline();
						continue;
					}

					freeXunit(ll);
					ip->reg = -1;
					ip->arg = &arg;
					arg.outd = &aod;
					arg.next = &dst;
					dst.outd = &dod;
					opndcnt = 0;			/* excess of 2 operands */

					if (cpu_ok(&asdata[tok]))
					{
						asdata[tok].parse(ip, tok, &arg, &dst);		/* may change tok/opcode */

						tok = ip->opcode;

						if (tok > 0 and G.iftab->p.truth)
						{
							if (asdata[tok].out)
								asdata[tok].out(ip);
							else
								error("CE: No output routine for '%s'\n", asdata[tok].text);
						}
					}

					if (last_label)
					{
						freeXunit(last_label);
						last_label = nil;
					}

					if (tok eq A_end)  /* P_end */
						break;
				}
			othw						/* label */
				if (G.iftab->p.truth)
				{
					if (cur->token eq ID)
					{
						ll = cur;

						advnode();
						if (is_set(cur))
							last_label = ll;
						elif (cur->token eq LABEL or ws eq 0)
						{
							p_label(ll, 0, P.in_module);
							if (cur->token eq NL)
								ws = after_newline();
						othw
							errorn(ll, "unknown mnemonic");
							ws = after_newline();
						}
						continue;
					}
					elif (!is_line(cur))
						continue;
					elif (cur->token ne NL)
						errorn(cur, "syntax error at");
				}
			}
		}

		if (incl eq A_include)		/* 11'09 HR otherwise first line was skipped */
			fadvnode();
		else
			ws = after_newline();
	}
}

/* Important note to myself:
   Be carefull NOT to produce op->aname's
   cause P.area_po_names isnt ready.
*/
global
void do_S(void)  /* complete .S file */
{
	if (G.use_FPU)
		G.CPU |= _8;

#if COLDFIRE
	if (G.Coldfire)
	{
		G.CPU |= _CF;
		G.aw_Xnl = 1;			/* 10'12 Xn.l default if Coldfire */
	}
	else
#endif
	if (G.i2_68020)
		G.CPU |= _2|_3;
	if (G.i2_68030)
		G.CPU |= _3;
	if (G.i2_68040)
		G.CPU |= _4;
	if (G.i2_68060)
		G.CPU |= _6;

	if (G.au_supervisor)
		G.CPU |= _S;

	G.lang = 's';

	if (!asmc_setup() or !o_setup())
	{
		error("insufficient memory for assembling");
		return;
	}

	area_id = 0;

	o_area_setup(BSS_class, ++area_id, "anonymous_bss");
	P.code_std_areas[BSS_class] = P.area_now;
	o_fixup("__1", area_id, FIX_lcmod, 0);

	o_area_setup(DATA_class, ++area_id, "anonymous_data");
	P.code_std_areas[DATA_class] = P.area_now;
	o_fixup("__2", area_id, FIX_lcmod, 0);

	o_area_setup(TEXT_class, ++area_id, "anonymous_text");
	P.code_std_areas[TEXT_class] = P.area_now;
	o_fixup("__3", area_id, FIX_lcmod, 0);

	P.in_module = false;
	class_now = TEXT_class;

	new_proc("asm root");
	G.iftab = allocVn(IFNODE);
	name_to_str(G.iftab, "prep");
	G.iftab->p.truth = true;

	advnode();

	asm_loop(EOFTOK);

	if (G.scope)		/* module w/o endmod */
	{
		if (P.area_now->target eq FIX_text)
			o_endproc();
		end_scope();
	}
	else
	if (!P.in_module)
	{
		P.area_now = P.code_std_areas[TEXT_class];
		o_endproc();
	}

	new_dotscope();		/* 01'15 v5.2 */
	free_equs();
	CC_xfree(G.prtab);
	G.prtab = nil;
	freeVn(G.iftab);
	G.iftab = nil;
	freeXn(cur);
}


/* compile assembler function in C file */
static
void anon_area(short class, char *text)
{
	short id;

	out_force_class(class, "; asm area ^N\n");	/* forces area id bumping */
	id = std_areas->ar[class].id;
	o_area_setup(class, id, text);
	P.code_std_areas[class] = P.area_now;
	o_fixup(text, id, FIX_lcmod, 0);
}

global
void do_asm(TP xp, short delim, bool lex)
{
	AREA *ar;
	short id    = xp->area_info.id,
	      class = xp->area_info.class;
	short old = G.lang;

	G.lang = 's';
	P.in_module = true;
	P.in_func   = true;

	if (!asmc_setup() or !o_setup())
	{
		error("insufficient memory for assembling");
		return;
	}

	anon_area(DATA_class, "anonymous data");
	anon_area(BSS_class,  "anonymous bss");
	change_class(class);

	ar = o_area_setup(class, id, xp->name);
	P.code_std_areas[TEXT_class] = P.area_now;
	o_fixup(xp->name, id, xp->sc eq K_STATIC ? FIX_lcmod : FIX_glmod, 0);
	ar->name = str_alloc(xp->name);

	asm_loop(delim);

	new_dotscope();		/* 01'15 v5.2 */
	P.area_now = P.code_std_areas[TEXT_class];
	o_endproc();

	P.in_module = false;
	P.in_func   = false;
	G.lang = old;
}

global
void end_S(void) { o_end(G.v_Cverbosity); }
