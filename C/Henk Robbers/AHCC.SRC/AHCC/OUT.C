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
 *   out.c
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <time.h>

#include "common/mallocs.h"
#include "common/amem.h"
#include "param.h"

#include "io.h"
#include "gsub.h"
#include "out.h"
#include "opt.h"

#define notTIME_OUTCODE

#define DCCHUNK 32
#define DCBCHUNK 64		/* 01'16 v5.3 :: should be 0 < def < 1024 */

#define debugH  G.xflags['h'-'a']
#define debugZ  G.xflags['z'-'a']

short in_class = -1, area_id = 0;

global
AREA_STACK *std_areas   = nil,
                  *start_areas = nil,
                  *end_areas   = nil;

global
S_path o_name;

global
long combine_areas(void)
{
	long count = 0; short i;
	AREA_STACK *as = start_areas;
#if C_DEBUG
	long allocated = 0;
#endif

	for (i = start_class; i < high_class; i++)
	{
		as = start_areas;
		while (as)
		{
			AREAS *a = as->ar;
			long this = a[i].out - a[i].start;
			if (this)
			{
#if C_DEBUG
				send_msg("start %s [%6ld]%s\n", class_names[i], this, a->name);
#endif
				count += this + 40;
			}
#if C_DEBUG
			allocated += a[i].outl;
#endif
			as = as->next;
		}
	}

#if C_DEBUG
	send_msg("memory allocated for area buffers: %ld\n", allocated);
#endif
	if (count)
	{
		char *new;

		count += 2;
#if C_DEBUG
		send_msg("try alloc %ld\n", count);
#endif
		new = fmalloc(count, AH_COMBINE);
		if (new)
		{
			char *add = new;
			for (i = start_class; i < high_class; i++)
			{
				as = start_areas;
				while (as)
				{
					AREAS *a = as->ar;
					long this = a[i].out - a[i].start;
					if (this)
					{
						add += sprintf(add, ";IXC: area %d class %d(%s)\r\n", a[i].id, a[i].class, class_names[i]);
						memmove(add, a[i].start, this);
					}
					add += this;
					as = as->next;
				}
			}
			*add++ = 0;
			*add++ = 0;
			out_buf = new;
			count = add - new;
		othw
			error("Not enough memory for output");
			return 0;
		}
	}

	return count;
}

global
bool can_3q(long val)
{
	return val eq -1 or (val > 0 and val < 8);
}

global
void set_class(void *xp, short class)
{
	TP tp = xp;
	tp->area_info.class = class;
	tp->area_info.id = std_areas->ar[class].id;
}

global
void out_gp(void)
{
	if (gpbase)
	{
		if (!G.nmerrors)
			outcode_list(gpbase);
		freenode(gpbase);
		gpbase = nil;
	}
}

static
bool alloc_area(AREAS *a, AREAS *pr, long l, short class)
{
	a->outl = 0;
	a->out = 0;
	a->size = 0;
	if (!(pr and pr->out - pr->start eq 0))
	{
		a->start = CC_fmalloc(l, AH_AREA, nil);
		if (a->start eq nil)
			return false;

		a->outl  = l;
		a->out   = a->start;
		a->class = class;
		a->id    = ++area_id;
	othw
		a->start = pr->start;		/* hold on to unused memory */
		a->out   = pr->out;
		a->outl  = pr->outl;
		a->class = pr->class;
		a->id    = pr->id;
		strcpy(a->name, pr->name);

		pr->outl = 0;				/* invalidate prev unused level */
		pr->class= 0;
		pr->id   = -1;
		pr->start= nil;
		pr->out  = nil;
	}

	return true;
}

static
void free_area(AREAS *a)
{
	if (a)
	{
		if (a->start)
			CC_ffree(a->start);
		a->start = a->out = nil;
		a->outl = 0;
		a->size = 0;
	}
}

global
bool create_areas(void)
{
	short i;
	AREA_STACK *new, *prev = std_areas;

	new = CC_fcalloc(1, sizeof(*new), AH_AREA_STACK, nil);
	if (new eq nil)
		return false;

	if (start_areas eq nil)
		start_areas = new;
	else
		end_areas->next = new;

	end_areas = new;
	std_areas = new;

	for (i = start_class; i < high_class; i++)
		if ( ! alloc_area(&new->ar[i], prev ? &prev->ar[i] : nil, i eq TEXT_class ? 2K : 1K, i))
			return false;

	if (in_class >= start_class and in_class < high_class)
		out_goes = new->ar[in_class].out;
	elif (in_class ne -1)
	{
		error("CE: invalid current class %d", in_class);
		return false;
	}

	return true;
}

global
void new_areas(void)
{
	if (!create_areas())
		error("[5]Not enough memory for output");
}


global
void destroy_areas(void)
{
	short i;
	AREA_STACK *as = start_areas;

	while (as)
	{
		AREA_STACK *nx = as->next;

		for (i = start_class; i < high_class; i++)
			free_area(&as->ar[i]);

		CC_ffree(as);
		as = nx;
	}
}

static
Wstr check_out(Wstr goes)
{
	if (in_class >= 0)
	{
		AREAS *a = &std_areas->ar[in_class];
		long used = goes - a->start;

		if (a->outl - used < L_OUT)
		{
			long nout = (3*a->outl)/2;			/* increment buffer size mildly exponentially */
			Wstr nbuf = CC_frealloc(a->start, nout, 40 + in_class, CC_ranout);

			if (nbuf eq nil)
			{
				error("[2]%ld not enough memory for output", nout);
				goes = a->start;
			othw
				a->outl = nout;
				goes = nbuf + used;
				a->start = nbuf;
				out_buf = nbuf;
			}
		}
		a->out = goes;
	}

	return goes;
}

static
void add_out(Cstr f)
{
	Wstr s = out_goes;
	while (*f)
	{
		if (*f eq '\n')
		{
			*s++ = '\r';
			*s++ = *f++;
			s = check_out(s);
		}
		else
			*s++ = *f++;
	}
	out_goes = s;
}

void send_out	(char *f, ...);

static
void send_lab(short l)
{
	send_out("__%d", l);	/* __ is ANSI convention for implementor defined names */
}

static
void add_name(NP np)		/* lbl only if within func (G.prtab->level > 1) */
{
	if (np->sc eq K_STATIC and np->lbl)
		send_lab(np->lbl);
	elif (np->name)
	{
		char *s = out_goes;
		Cstr n = np->name;
		if (G.x_add_underline)
			*s++ = UNDERLINE;
		while (*n) *s++ = *n++;
		out_goes = s;
	}
}

global
void send_out(char *f, ...)		/* reduced (faster) version of sprintf */
{
	char *s;
	va_list(sp);
	va_start(sp, f);

	s = out_goes;
	do
	{
		char c = *f++, *fro;
		short i, sz;
		bool lo;
		unsigned long l;

		if (c eq '%')
		{
			c = *f++;

			sz = 0;				/* for x */
			if (c eq '0')
			{
				sz = *f++ - '0';
				c = *f++;
			}

			if ( (lo = c eq 'l') ne 0)
				c = *f++;

			switch (c)
			{
			case 's':
				fro = va_arg(sp, char *);
				while((*s++ = *fro++) ne 0);
				s--;
				break;

			case 'd':
				if (lo)
				{
					char x[16];
					long sign;
					l = va_arg(sp, long);
					if ( (sign = l) < 0 ) l =  -l;
					fro = &x[sizeof(x)-1];
					*fro = 0;
					do *--fro = l%10 +' 0'; while ((l /= 10) > 0 );
					if ( sign<0 ) *--fro = '-';
					while((*s++ = *fro++) ne 0);
					s--;
				othw
					char x[7];
					short sign;
					i = va_arg(sp, short);
					if ( (sign = i) < 0 ) i =  -i;
					fro = &x[sizeof(x)-1];
					*fro = 0;
					do *--fro = i%10 + '0'; while ((i /= 10) > 0 );
					if ( sign<0 ) *--fro = '-';
					while((*s++ = *fro++) ne 0);
					s--;
				}
				break;

			case 'X':
			case 'x':
			{
				char x[9];
				if (lo)
					l = va_arg(sp, unsigned long);
				else
					l = va_arg(sp, uint);
				for (i = 0; i<sizeof(x); i++) x[i] = '0';
				fro = &x[sizeof(x)-1];
				*fro-- = 0;
				do
				{
					i = (l%16);
					*fro-- = i+(i<10?'0':'W');
				} while ((l /= 16) > 0 );
				fro = x;
				if (!sz)
				{
					while (*fro eq '0') fro++;
					if (*fro eq 0)
						fro--;
				}
				else
					fro += sizeof(x) -1 - sz;
				while((*s++ = *fro++) ne 0);
				s--;
			}
			break;
			case 'O':
			case 'o':
			{
				char x[12];
				if (lo)
					l = va_arg(sp, unsigned long);
				else
					l = va_arg(sp, uint);
				for (i = 0; i<sizeof(x); i++) x[i] = '0';
				fro = &x[sizeof(x)-1];
				*fro-- = 0;
				do
				{
					i = (l%8);
					*fro-- = i+'0';
				} while ((l /= 8) > 0 );
				fro = x;
				if (!sz)
				{
					while (*fro eq '0') fro++;
					if (*fro eq 0)
						fro--;
				}
				else
					fro += sizeof(x) -1 - sz;
				while((*s++ = *fro++) ne 0);
				s--;
			}
			break;
			case 'c':
				*s++ = va_arg(sp, short);
				break;

			default:
				*s++ = c;
			}
		othw
			if (c eq '\n')
			{
				*s++ = '\r';
				*s++ = c;
				s = check_out(s);
			}
			else
				*s++ = c;
		}
	} while (*f);
	va_end(sp);
	out_goes = s;
}

void out_let(short c, NP np),		/* recursion */
	 outsub	(NP np, Cstr cp);

static
bool willshow(char c)
{
	return isprint(c) ne 0 and c ne '\'' and c ne '\"';
}

global
bool out_setup(Cstr s)
{
	if (G.output eq nil)	/* anders of stdout, of -o outfn */
	{
		P_path ps;
		ps.s = s;
		o_name = change_suffix(ps.t, ".o");
#if BIP_ASM
		if (G.xlang ne 's')
#endif
		{
			G.output_name = change_suffix(ps.t, ".i");
			G.output = open_S(G.output_name.s);
			if (G.output eq nil)
			{
				console("Can't open output %s\n", G.output_name.s);
				return false;
			}
		}
	}

	std_areas   = nil;
	start_areas = nil;
	end_areas   = nil;

	in_class = -1;
	G.lblnum = 1;
	area_id = 0;
	out_goes = nil;

	return true;
}

global
void end_C(void)
{
	VpV asmc_end;

	close_S(G.output);

	if (!G.nmerrors and !G.an_no_O)
		out_goes = optimize();

	G.output = nil;
}

global
void write_literals(void)
{
	short cur = in_class;

	if (G.consave)				/* doubles apart */
	{
		gp = gx_node();
		change_class(CON_class);
		putn_lifo(&G.consave, gp);
		outcode_list(G.consave);
		freenode(G.consave);
		G.conlast = G.consave = nil;
	}

	if (G.strsave)
	{
		gp = gx_node();
		change_class(STR_class);
		putn_lifo(&G.strsave, gp);
		outcode_list(G.strsave);
		freenode(G.strsave);
		G.strlast = G.strsave = nil;
	}

	change_class(cur);
}

global
Cstr class_names[] =
{
	"",							/* NO_class */
	"#text",					/* TEXT_class */
	"#data",					/* DATA_class */
	"#gdata",					/* GDATA_class */
	"#strings",					/* STR_class */
	"constants",				/* CON_class */
	"#bss",						/* BSS_class */
	"#gbss",					/* GBSS_class */
	"#offs",					/* OFFS_class */
	nil
};

global
void change_class(short class)
{
	if (in_class ne class)
	{
		if (in_class >= 0)
			std_areas->ar[in_class].out = out_goes;
		out_goes = std_areas->ar[class].out;
		in_class = class;
	}
}

global
void out_force_class(short class, Cstr comment)
{
	new_gp(nil, PROC);
	change_class(class);
	addcode(gp, comment);
	out_gp();
}

char *pclass(short);

global
bool o_aln(short aln, short class)
{
	if (aln and (std_areas->ar[class].size & 1) ne 0)
	{
		std_areas->ar[class].size++;
		addcode(gp, "\tds.b\t\t1" C(o_aln) "\n");
		return true;
	}

	return false;
}

static
Cstr rnms[] =
{
	"$0", "$1", "$2", "$3", "$4", "$5", "$6", "$7",
	"~0", "~1", "~2", "~3", "~4", "~5", "~6", "~7",
	"*0", "*1", "*2", "*3", "*4", "*5", "*n", "*s"
};

global
Cstr regnm(short x)
{
#if C_DEBUG
	return x >= 0 and x<24 ? rnms[x] : "!~";
#else
	return rnms[x];
#endif
}

static
char *tlen(short c, NP np)
{
	switch (c)
	{
	case DOT_B:
		return ".b";
	case DOT_W:
		return ".w";
#if FLOAT
	case DOT_X:
		return ".x";
#endif
	default:
#if FLOAT
		if (G.use_FPU and np->ty eq ET_R)
		{
			if (c eq DOT_D or np->token eq RCON)
				return ".d";
			if (c eq DOT_S or np->token eq FCON)
				return ".s";
		}
#endif
		/* After ET_R check :-) */
		if (c eq DOT_L)
			return ".l";
#if LL
		if (c eq DOT_LL)
			return ".e";
#endif

		CE_NX(np, "Weird size %d", c);
		return ".?";
	}
}

global
short new_lbl(void)
{
	return G.lblnum++;
}

#if FOR_A
global
short new_albl(short which) { return G.lblnum++; }
#endif
global
void out_fbegin(FP pt, TP np)
{
	char *n = std_areas->ar[TEXT_class].name;

	*n = 0;
	if (G.x_add_underline)			/* 04'09 */
		*n++ = UNDERLINE;

	strcpy(n, np->name);
#if BIP_ASM
	if (np->type->tflgs.f.asm_func eq 0)
#endif
	{
		gp->misc = *(unsigned long *)&pt->maxregs;
		gp->lbl = pt->lkxl;
		gp->r1 = FRAMEP;
		addcode(gp, "\tlkx  \tR1\t#L1"  C(out_fbegin) "\n");
		addcode(gp, "\tmms.l\t\tL2\n");
	}
}

#if FOR_A
global
void out_pbegin(FP pt) { gp->misc = *(unsigned long *)&pt->maxregs; }
#endif

/* 09'10 HR: cdecl flag for return in a0 and d0 */
static
void out_rts(TP ptt, short is_cdecl)
{
	if (ptt->token eq T_VOID)
		addcode(gp, "\trtv  \t\t" C(out_rts) "\n");	/* kill all regs */
	elif (ptt->token eq REFTO)
		if (is_cdecl or G.h_cdecl_calling)
			addcode(gp, "\trtad \t\t" C(out_rts_addr_cdecl) "\n");		/* 09'10 HR: A0 & D0 */
		else
			addcode(gp, "\trta  \t\t" C(out_rts_addr) "\n");
#if FLOAT
	elif (G.use_FPU and ptt->ty eq ET_R)
		addcode(gp, "\trtf  \t\t" C(out_rts_real) "\n");
#endif
	else
		addcode(gp, "\trts  \t\t" C(out_rts) "\n");
}

global
void out_fret(FP pt, TP xp)
{
	TP tp = xp->type,
	   ptt = tp->type;

	new_gp(nil, OUT);
#if BIP_ASM
	if (tp->tflgs.f.asm_func eq 0)
#endif
	{
		gp->misc = *(unsigned long *)&pt->maxregs;
		gp->lbl = pt->fretl;
		gp->r1 = FRAMEP;
		addcode(gp, "L1:\n");	/* return label */

		/* pt = G.prtab whose ->type is the return type */
		gp->cflgs.f.cdec = tp->cflgs.f.cdec;
		addcode(gp, "^R\tmmx.l\t\tL3\n");
		addcode(gp, "\tulx  \tR1\n");

		out_rts(ptt, tp->cflgs.f.cdec);
	}

	addcode(gp, "#pend\n");
	out_gp();
}

#if FOR_A
global
void out_pret(FP pt, TP tp)
{
	TP ptt = pt->type;

	new_gp(nil, OUT);
	gp->misc = *(unsigned long *)&pt->maxregs;
	gp->lbl = pt->fretl;
	if (pt->token ne STMT)
	{
		gp->r1 = FRAMEP;
		addcode(gp, "L1:\n");	/* return label */
	}

	if (pt->token eq STMT)
		addcode(gp, "\tbra  \t\tL1" C(out_stmt) "\n");
	else
		out_rts(ptt, 0);

	addcode(gp, "\n");
	out_gp();
}
#endif

global
void def_lbl(short l)
{
	NP gp = gx_node();

	gp->lbl = l;
	outsub(gp, "L1:\n");
	freenode(gp);
}

#if FOR_A
global
void def_albl(short l, short which)
{
	NP gp = gx_node();

	D_(H, "def_albl");

	gp->lbl = l;
	outsub(gp, "L1:\n");
	freenode(gp);
}
#endif

global
short loop_lbl(short l)
{
	NP gp = gx_node();

	gp->lbl = l;
	outsub(gp, "L1:\n\tloop\n");
	freenode(gp);
	return l;
}

global
void add_br_2_1(short l)
{
	NP gp = gx_node();

	gp->lbl = l;
	outsub(gp, "\tbra \t\tL2" C(br_2_1) "\n");
	outsub(gp, "L1:\n");
	freenode(gp);
}

global
void add_br_1_2(short l)
{
	NP gp = gx_node();

	gp->lbl = l;
	outsub(gp, "\tbra \t\tL1" C(br_1_2) "\nL2:\n");
	freenode(gp);
}

global
void add_br_1_3(short l)
{
	NP gp = gx_node();

	gp->lbl = l;
	outsub(gp, "\tbra \t\tL1" C(br_1_3) "\nL3:\n");
	freenode(gp);
}

#if FOR_A
global
void out_comment(char *s)
{
	NP gp = gx_node();

	name_to_str(gp, s);
	outsub(gp, "\n;\t--== N ==--\n");
	freenode(gp);
}

static
TP find_loop_var(Cstr n)
{
	TP tp; SCP bp;

	bp = G.scope;

	while (bp)
	{
		tp = bp->b_syms;
		while (tp)
		{
			if (tp->name)
				if (strcmp(tp->name, n) eq 0)
					return tp;
			tp = tp->next;
		}
		bp = bp->outer;
	}
	return nil;
}

global
void out_arr_cmp(Cstr name, short l)
{
	NP gp; TP sp, ep = find_loop_var("__e");

	if (ep)
	{
		gp = gx_node();
		sp = find_loop_var(name);
		if (sp)
		{
			gp->token = sp->token;
			gp->val.i = sp->offset;
			gp->rno = sp->rno;
			gp->size = sp->size;		/* unit size */
			gp->ty = ET_P;
			gp->vreg = sp->vreg;				/* 10'14 v5.2 */
			outsub(gp, "\tldx.l\tRd0\tA" C(arr_cmp1) "\n");
			freenode(gp);
			gp = gx_node();
		}

		gp->token = ep->token;
		gp->val.i = ep->offset;
		gp->rno = ep->rno;
		gp->lbl = l;
		gp->ty = ET_P;
		gp->vreg = ep->vreg;				/* 10'14 v5.2 */
		outsub(gp, "\tcpx.l\tRd0\tA\n\tbge \t\tL1" C(arr_cmp2) "\n");
		freenode(gp);
	}
}

global
void out_arr_end(TP rp)		/* 2'15 v5.2 np,  must be present */
{
	TP tp = find_loop_var("__e");

	if (tp)
	{
		NP gp = gx_node();
		gp->size = tp->size;
		gp->token = tp->token;
		gp->val.i = tp->offset - DOT_L;		/* we know there 2 of them and we know the order */
		gp->rno = tp->rno;
		gp->ty = ET_P;
		gp->vreg = rp->vreg;				/* 2'15 v5.2 */
		outsub(gp, "\tmov.l\t\tA,");
		gp->val.i += DOT_L;
		gp->vreg = tp->vreg;				/* 2'15 v5.2 */
		outsub(gp, "A\n\tldx.l\tRd0\t#^I\n\tads.l\tRd0\tA" C(arr_end) "\n");
		freenode(gp);
	}
}

global
void out_arr_add(TP tp)
{
	NP gp = gx_node();

	gp->token = tp->token;
	gp->val.i = tp->offset;
	gp->rno = tp->rno;
	gp->size = tp->size;		/* unit size */
	gp->ty = ET_P;
	gp->vreg = tp->vreg;				/* 10'14 v5.2 */
	outsub(gp, "\tldx.l\tRd0\t#^I\n\tads.l\tRd0\tA" C(arr_add) "\n");
	freenode(gp);
}

global
void out_loop_clear(Cstr name)
{
	TP tp = find_loop_var(name);

	if (tp)
	{
		NP gp = gx_node();
		gp->token = tp->token;
		gp->val.i = tp->offset;
		gp->rno = tp->rno;
		gp->ty = ET_S;
		gp->vreg = tp->vreg;			/* 07'13 HR v4.15 */
		outsub(gp, "\tcls.l\t\tA" C(loop_clr) "\n");
		freenode(gp);
	}
}

global
void out_loop_inc(Cstr name)
{
	TP tp = find_loop_var(name);

	if (tp)
	{
		NP gp = gx_node();
		gp->token = tp->token;
		gp->val.i = tp->offset;
		gp->rno = tp->rno;
		gp->ty = ET_S;
		gp->vreg = tp->vreg;			/* 07'13 HR v4.15 */
		outsub(gp, "\tldx.l\tRd0\t#1\n\tads.l\tRd0\tA" C(loop_inc) "\n");
		freenode(gp);
	}
}

global
void out_loop_rtn(void)
{
	TP tp = find_loop_var("__c");

	if (tp)
	{
		NP gp = gx_node();
		gp->token = tp->token;
		gp->val.i = tp->offset;
		gp->rno = tp->rno;
		gp->ty = ET_S;
		outsub(gp, "\tldx.l\tRd0\tA" C(loop_return) "\n");
		freenode(gp);
	}
}
#endif

global
void out_br(short l)
{
	if (l < 0)
	{
		if (l ne -1)
			CE_("bad branch");
	othw
		NP gp = gx_node();
		gp->lbl = l;
		outsub(gp, "\tbra \t\tL1" C(out_br) "\n");
		freenode(gp);
	}
}

/* 05'16 HR v5.4 (bit of a hack :-/ ) */
global
void out_branch(bool ty, short l)
{
	if (l < 0)
	{
		if (l ne -1)
			CE_("bad branch");
	othw
		NP gp = gx_node();
		gp->lbl = l;

		outsub(gp, ty ? "\tbrf" : "\tbrb");
		outsub(gp, " \t\tL1" C(out_br) "\n");
		freenode(gp);
	}
}

extern
Cstr tstnm[];						/* ex GEN.C */

#if FLOAT
static
char fbptxt[] = "\tfb%s \t\t";
#endif
static
char bptxt[] =  "\tb%s \t\t";

global
void out_b(short key, short l)
{
	gp->lbl = l;
	gp->brt = key;
	if (key ne B_NO)
		addcode(gp, "BL1" C(out_b) "\n");
}

global
void out_cmp(ulong x)
{
	gp->misc = x;
	addcode(gp, "\tcpxS\tR0\t#M" C(out_cmp) "\n");
}

/* 03'11 HR Coldfire */
global
void out_anx(short isz)
{
	if (gp->size eq DOT_B)
		if (isz eq DOT_L)
			addcode(gp, "\tanx.l\tR0\t#$ff\n" C(out_anx) "\n");
		else
			addcode(gp, "\tanx.w\tR0\t#$ff\n" C(out_anx) "\n");
	elif (isz eq DOT_L)
		addcode(gp, "\tanx.l\tR0\t#$ffff\n" C(out_anx) "\n");
}

global
void out_sbx(ulong x)
{
	gp->val.i = x;
	addcode(gp, "\tsbxS\tR0\t#O" C(out_sbx) "\n");
}

global
void out_tlbl(short l)
{
	NP gp = gx_node();

	gp->size = DOT_L;
	gp->lbl = l;
	outsub(gp, "\tdcsS\t\tL1\n");
	freenode(gp);
}

global
void out_tsw(void)
{
	addcode(gp, "\tswtS\tR0\tRa0\t\t" C(out_tsw) "\n");		/* 03'11 HR: S */
}

global
void o_nz(long sz, short area, short aln)
{
	NP fp = gx_node();

	std_areas->ar[area].size += sz;
	fp->size = 1;
	if (aln)
	{
		if (sz & 1)
			addcode(fp, "\t^ZS\t\t1" C(o_nz 1) "\n");
		sz >>= 1;
		fp->size = 2;
	}
	fp->misc = sz;
	addcode(fp, "\t^ZS\t\tM" C(o_nz 2) "\n");
	next_gp(fp);
}

static
void outcode_row(NP np, VP cp)
{
	short i;

	if (cp)
#if C_DEBUG
		if (cp->tnr < 0 or cp->tnr > TPLMAX)
			error("CE: template # %d %08lx", cp->tnr, cp);
		else
#endif
		for (i = 0; i < cp->tnr; i++)
			outsub(np, cp->ts[i]);
}

static
void outcode_node(NP np)		/* np = gnode */
{
	VP cp;

	if (np->nflgs.f.n_ct)			/* type is a (string) */
		outsub(np, (Cstr)np->type);
	else							/* codep is a list of nodes */
		for (cp = (VP)np->type; cp; cp = cp->codep)
			outcode_row(np, cp);
}

global
void out_expr(NP np)
{
	if (np eq nil) return;
	if (np->nt ne GENODE) return;

	switch (np->tt)
	{
	case EV_NONE:
		break;

	case EV_RL:
	case EV_RLSEP:
		out_expr(np->right);
		outcode_row(np, np->betw); /* was outsub */
		/* fall through */
	case EV_LEFT:
		out_expr(np->left);
		break;

	case EV_LR:
	case EV_LRSEP:
		out_expr(np->left);
		outcode_row(np, np->betw);
		/* fall through */
	case EV_RIGHT:
		out_expr(np->right);
		break;

	default:
		CE_NX(np, "bad eval %d ", np->tt);
	}

	outcode_node(np);
}

global
void outcode_list(NP gp)			/* output FIFO code list */
{										/* All other lists are LIFO  */
	if (!G.nmerrors)
		while (gp)
		{
			out_expr(gp->right);	/* right first. (everytime a right is	*/
			outcode_node(gp);		/*	added, it is created in a new next)	*/
			gp = gp->left;
		}
}

static
Cstr seereg(NP np, Cstr cp)
{
	short i, c = *cp++;

	switch (c)
	{
		case '0':	i = np->rno;	break;			/* variable from node */
		case '1':	i = np->r1;		break;
		case '2':	i = np->r2;		break;
		case 'd':	i = *cp++ - '0' + D0;	break;	/* absolute reg */
#if FLOAT
		case 'f':	i = *cp++ - '0' + F0;	break;
#endif
		case 'a':	i = *cp++ - '0' + A0;	break;
		default: return cp;
	}
	if (i < D0 or i > Rinv)
		error("CE: invalid reg %d", i);
	else
		add_out(regnm(i));

	return cp;
}

static
void add_vreg(NP cvp)
{
	if (cvp->vreg.r)
		send_out("v%dl%ds%d", cvp->vreg.r, cvp->vreg.l, cvp->vreg.s);
}

static
void out_A(NP np, short adj)
{
	long offs = np->val.i+adj;

	if (np->eflgs.f.imm)
		char_out('#');

	switch (np->token)
	{
	case ICON:
		switch (np->size)
		{
			case DOT_B:
			{
				unsigned char c = offs;
				send_out("%d", (uint)c);
			}
			break;
			case DOT_W:
			{
				short u = offs;
				send_out("%ld", (unsigned long)u);
			}
			break;
#if LL
			case DOT_LL:				/* 01'09 long long constant */
				send_out("$%08lx%08lx", getlcon(np));
			break;
#endif
			default:
				send_out("%ld", offs);
		}
	break;
#if LL
	case LCON:				/* 01'09 long long constant */
		send_out("$%08lx%08lx", getlcon(np));
		break;
#endif
#if FLOAT
	case FCON:
		send_out("$%08lx", np->val.i);	 /* no loss of precision */
		break;
	case RCON:
		if (np->size eq DOT_D)
		{
			R64 d64;
			d80tod64(&d64, getrcon(np));
			send_out("$%08lx%08lx", d64);
		}
		else
			send_out("$%08lx%08lx%08lx", getrcon(np));
		break;
#endif
	case O_ABS:
		send_out("%ld", np->val.i);
		break;
	case ONAME:
	case OLNAME:
		np = childname(np);
		switch (np->area_info.class)
		{
			case DATA_class:
			case GDATA_class:
			case BSS_class:
			case GBSS_class:
			case STR_class:
			case CON_class:
			case TEXT_class:
				send_out("<%d/%d.%ld>", np->area_info.class, np->area_info.id, np->area_info.disp);
				char_out('[');
				add_name(np);
				char_out(']');
			break;
			case NO_class:
				add_name(np);
			break;
			default:
				send_out("<%d/%d.%ld>", np->area_info.class, np->area_info.id, np->area_info.disp);
				char_out('[');
				add_name(np);
				char_out(']');
		}

		if (offs)
			send_out(offs > 0 ? "+%ld" : "%ld", offs);
		break;
#if FOR_A
	case STMT:			/* primary use of statement */
		send_lab(np->lbl);
		break;
#endif
	case PUSHER:
		send_out("%s+", regnm(SP));
		break;
	case OREG:
		send_out("%s.", regnm(np->rno));
		if (offs)
		{
			send_out("%ld", offs);
			if (np->rno eq FRAMEP)
			{
				NP cvp = np;

				while (cvp->eflgs.f.lname)
					if (cvp->rno eq FRAMEP and cvp->val.i eq offs)
						cvp = cvp->left;
					else
						break;

				switch(cvp->ty)		/* determine target register variable type: */
				{						/* $ = Dn, ~ = FPn, * = An */
					case ET_B:
					case ET_S:
					case ET_U:
						add_out("/$");
						add_vreg(cvp);
					break;
#if FLOAT
					case ET_R:
						add_out("/~");
						add_vreg(cvp);
					break;
#endif
					case ET_P:
						add_out("/*");
						add_vreg(cvp);
					break;
					case ET_A:
						if (cvp->eflgs.f.pu)
						{
							add_out("/*");
							add_vreg(cvp);
						}
					break;
				}
			}
		}
#if DBGREG
		if (np->rno eq FRAMEP)
		{
			np = childname(np);
			if (np)
				if (np->name)
				{
					char_out('[');
					add_name(np);
					char_out(']');
				}
		}
#endif
		break;
	case REGVAR:
		add_out(regnm(np->rno));
		break;
	default:
#if C_DEBUG
		warnn(np, "unknown A %lx '%s'", np, ptok(np->token));
#else
		CE_NX(np, "unknown A: %d", np->token);
#endif
	}
}

static
void out_let(short c, NP np)
{
	switch (c)
	{
/*	case 'A':			in outsub	*/
	case 'B':									/* branch */
#if FLOAT
		if (    G.use_FPU
		    and (   np->ty eq ET_R
		         or np->ty eq ET_XC
		         or np->ty eq ET_FC
		        )
		   )
			send_out(fbptxt, tstnm[np->brt]);
		else
#endif
			send_out( bptxt, tstnm[np->brt]);
		break;
	case 'C':			/* strasn chunk size */
#if FLOAT
		if (np->ty eq ET_R and np->size eq DOT_L)
			add_out(".s");			/* 03'11 HR .s !!! */
		else
#endif
			add_out(tlen(np->chunk_size, np));
		break;
	case 'D':
		char_out(np->ty eq ET_U ? 'u' : 's');
		break;
	case 'E':			/* unsigned b --> l extend */
		char_out(np->size eq DOT_L ? 'e' : 'u');
		break;
	case 'F':
		send_out("%d", np->fld.offset);
		break;
	case 'G':			/* aggreg return: first param */
		send_out("%s.%d", regnm(FRAMEP), ARG_BASE);
		break;
	case 'H':			/* for logical operations */
		if (G.Coldfire or np->size eq DOT_L)
			send_out(".l");
		else
			char_out(' ');
		break;
	case 'I':			/* area info */
		send_out("%d,%d", np->area_info.id, np->area_info.class);
		break;
	case 'K':
		send_out("%ld", np->misc);
		break;
/*	case 'L':			in outsub	*/
/*	case 'M':			in outsub	*/
	case 'N':
		outsub(np, np->name);				/* basic operation name */
		break;
	case 'O':								/* diversen */
		send_out("%ld", np->val.i);
		break;
#if FOR_A
	case 'P':
		send_out("%ld", np->str_sz);		/* #A string size */
	break;
#endif
/*	case 'R':			in outsub	*/
	case 'S':
		add_out(tlen(np->size, np));
		break;
	case 'T':								/* __syscall__ */
		send_out("%d", np->lbl);
		break;
	case 'U':
		add_out(   np->ty eq ET_U
				or np->ty eq ET_P ? "u" : "");
		break;
	case 'V':
		char_out(   np->ty eq ET_U
				 or np->ty eq ET_P ? 'l' : 'a');	/* for shifts */
		break;
	case 'W':
		send_out("%d", np->fld.width);		/* 68020 bitfields */
		break;
	case 'X':				/* output string (np->nmx) */
#if ! DOLLARSCON
		{
			short i,j; bool first = true; Cstr s;

			i = np->size;
			s = np->name;

			if (i)
			{
				add_out("\tdc.b\t\t");
				while (i > 0)
				{
					if (willshow(*s))
					{
						char_out('\'');
						j = 0;
						while(willshow(*s) and i > 0)
						{
#if DCBCHUNK
							if (j and (j % DCBCHUNK) eq 0)		/* 01'16 v5.3 */
							{
								if (first)
									char_out('\'');
								add_out("\n\tdc.b\t\t'");
							}
#endif
							char_out(*s++), i--, j++;
						}
						if (i > 0)
							add_out("',");
						else
							char_out('\'');
					othw
						while(i > 0 and !willshow(*s))
						{
							send_out("0x%x", *s++ & 0xff);
							i--;
							if (i > 0)
								char_out(',');
						}
					}
				}
				first = false;
				add_out("\n");
			}
		}
#else
		{
			short i;
			add_out(dc);			/* first */
			for (i = 0;i < np->e.size; i++)
			{
				if (i ne 0)
					if ((i % DCCHUNK) eq 0)			/* 3'91 v1.2 */
						add_out("\n"
						add_out(dc);
					else
						char_out(',');
				send_out("0x%x", np->name[i] & 0xff);
			}
			add_out("\n");
		}
#endif
		break;
	case 'Z':				/* output string terminator */
		add_out("\tdc.b\t\t0" C(out_X) "\n");
		break;
	default:
		errorn(np, "bad out_let %c ", c);
	}
}

global ulong ones(short n) { return (1L << n) - 1; }

/* A teeny tiny Turing machine.
   Its not the famous one, because the tape moves in 1 direction only.
   The end is simply reached by running out of tape.
   Equivalent versions can be made for uint or unsigned long by just
   changing 'mask's type and using a cbindec routine for r.
   (example unsigned long:  b1-b12/b14/b17-b24/b31)
*/

/* for readability: */
#define putmnem b=regname; while (*b) *s++=*b++; *s++=r+'0'

static
char *c_bits(char *s, uchar mask, char *regname)
{
	short r = 0;
	char *b;
	*s = -1;				/* begin */
	while (mask)
	{
		switch (mask&3)
		{
		case 0:			/* a 0 pops up: seperate by '/' */
		case 2:
			if (*s ne -1) *s = '/';
			break;
		case 1:			/* 1 followed by 0 close or start */
			if (*s eq '/') s++;
			putmnem;
			break;
		case 3:			/* contiguous bits */
			if (*s eq -1 or *s eq '/')
			{
				if (*s eq '/') s++;
				putmnem;
				*s++ = '-';
			}
		}
		mask >>= 1;		/* !!!! mask must be unsigned !!!! */
		r++;
	}
	return s;
}

global
Cstr mask_to_s(RMASK m)
{
	static char buf[256];
	char *s = buf+1;
	s = c_bits(s, m,     "$");
	if (*s ne -1)					/* something done */
		*s++ = '/';
	s = c_bits(s, m>>16, "*");
	if (*s ne -1)
		*s++ = '/';
	s = c_bits(s, m>>8,  "~");
	if (*s ne -1)
		*s++ = '/';
	if (*(s-1) eq '/')
		*(s-1) = 0;
	*s = 0;
	return buf+1;
}

/* '^' introduces out_shift        */
static
void out_shift(short c, NP np)
{
	switch (c)
	{
	case 'C':					/* assign constant to field */
	{
		short sh = np->fld.shift;
		if (np->size eq DOT_L)
			send_out("$%08lx",   (np->right->val.i << sh)
			                    &(ones(np->fld.width) << sh) );
		else
			send_out("$%04x",
			    (unsigned short) (
			                       (np->right->val.i << sh)
			                      &(ones(np->fld.width) << sh)
			                     )
			        );
		break;
	}
	case 'D':					/* output area (bss, text, data or lits) */
		change_class(np->misc1);	/* dynamic area change */
		break;
	case 'E':
		add_out("#$80000000");
		break;
	case 'F':					/* convert field offset to bit number */
		{
			short up = np->fld.offset/8;
			np->left->val.i += up;
			send_out("%d", up*8 + 7 - np->fld.offset);
		}
		break;
	case 'G':					/* shift sign extended field into working position (with sra) */
		if (np->size eq DOT_L)
			send_out("%d", 32 - np->fld.width);
		else
			send_out("%d", 16 - np->fld.width);
		break;
	case 'I':
		send_out("%ld", np->size);
		break;
	case 'K':
	{
		short sh = np->fld.shift;
		if (np->size eq DOT_L)
			send_out("$%08lx", ones(np->fld.width)<<sh);
		else
			send_out("$%04x", (unsigned short)		/* W << offset */	/* 11'10 HR */
					    (ones(np->fld.width)<<sh));
		break;
	}
	case 'L':
		if (np->reserve)
#if REGLIST
			send_out(":%s", mask_to_s(np->reserve));
#else
			send_out(":#%ld", np->reserve);
#endif
		break;
	case 'M':
	{
		short sh = np->fld.shift;
		if (np->size eq DOT_L)
			send_out("$%08lx", ~(ones(np->fld.width)<<sh));
		else
			send_out("$%04x", (unsigned short)		/* ~(W << offset) */	/* 3'91 v1.2 */
					(~(ones(np->fld.width)<<sh)));
		break;
	}
	case 'N':						/* output name */
		add_name(np);
		break;
	case 'O':
		send_out("%d", np->fld.shift);
		break;
	case 'R':					/* output save/restore regs */
		{
			ALREG r = *(ALREG *)&np->misc;
			short i; RMASK m = 0;

			for (i = r.d+DREG; i <= DRV_END; i++)
				m |= RM(i);
#if FLOAT
			for (i = r.f+FREG; i <= FRV_END; i++)
				m |= RM(i);
#endif
			for (i = r.a+AREG; i <= ARV_END; i++)
				m |= RM(i);
			m |= G.prtab->wregmsk;
			if (np->cflgs.f.cdec)
				m |= RM(D2);
#if REGLIST
			if (m)
				send_out("\treg \t\t%s,", mask_to_s(m));
			else
				send_out("\treg \t\t#0,");
#else
			if (m)
				send_out("\treg \t\t#%ld,", m);
			else
				send_out("\treg \t\t#0,");
#endif
			send_lab(G.prtab->mmxl);
			send_out("\n\tloc \t\t#-%d,", G.prtab->maxlocs);
			send_lab(G.prtab->lkxl);
			add_out("\n");
		}
		break;
	case 'S':					/* output scope */
		if (np->sc ne K_STATIC)
			add_out("#gproc\t");
		else
			add_out("#proc\t");
		break;
	case 'W':					/* field width 1's */
		if (np->size eq DOT_L)
			send_out("$%08lx", ones(np->fld.width));
		else
			send_out("$%04x", (unsigned short)ones(np->fld.width));
		break;
	case 'Y':
		add_out("dc");
		break;
	case 'Z':
		add_out("ds");
		break;
	case 'X':					/* for debugging */
		char_out(',');
		if (np->cflgs.f.asm_f)
		{
			send_out("%d", np->area_info.id);
		othw
			if (G.pragmats.noregs) char_out('R');
			else                   char_out('r');
			if (G.pragmats.new_peep) char_out('N');
			else                     char_out('n');
		}
		break;
	default:
		errorn(np, "bad out_shift %c ", c);
	}
}

static
void seelab(char c, NP np)
{
	short l = 0;

	if (c >= '0' and c <= '9')		/* L0 means 1 less than stated label */
		l = np->lbl+c-'1';
	elif (c eq 't')					/* branch_tree */
		l = np->Tl;
	else
		l = np->Fl;

	send_lab(l);
}

static
void outsub(NP np, Cstr cp) 	/* now also <L >L  etc */
{
	char c;

	if (cp eq nil or G.nmerrors)
		return;

#if OPTBUG
	if (np->fl.ln ne G.lineno)
	{
		send_out("\n\tline\t\t#%ld\n", np->fl.ln);
		G.lineno = np->fl.ln;
	}
#endif

	while ( (c = *cp++) ne 0 )
	{
		NP xp = np;

		if (c eq '<')
			if (np->left)
				np = np->left, c = *cp++;
			else
			{
				CE_NX(np, "outsub: no left with %s", cp);
			}
		elif (c eq '>')
			if (np->right)
				np = np->right, c = *cp++;
			else
			{
				CE_NX(np, "outsub: no right with %s", cp);
			}

		if (c eq '\n')
		{
			char_out('\r');
			char_out('\n');
			out_goes = check_out(out_goes);
		}
		elif (c ne '^' and (c < '@' or c > 'Z'))
			char_out(c);
		elif (c eq 'A')		/* the most frequent first */
			out_A(np, 0);
#if PSHL
		elif (c eq 'J')
		{
			short c = *cp++;
			out_A(np, c - '0');
		}
#endif
		else
		switch(c)
		{
		case 'L':
			seelab(*cp++, np);
		break;
		case 'R':
			cp = seereg(np, cp);
		break;
		case 'M':
			send_out("%ld", np->misc);
		break;
		case '^':
			out_shift(*cp++, np);
		break;
		default:
			out_let(c, np);
		}
		np = xp;
	}
}
