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
 *	d2.c
 *
 *	Declaration subroutines (mostly called from decl.c)
 *
 *	Mostly routines for initializations
 */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "param.h"
#include "pre.h"
#include "common/dict.h"
#include "body.h"
#include "decl.h"
#include "d2.h"
#include "expr.h"
#include "e2.h"
#include "gen.h"
#include "gsub.h"
#include "md.h"
#include "out.h"

#define t_tok(a) ((a)-FIRST_BAS)
#define	is_ulp(tp) ((tp)->ty eq ET_U and (tp)->size eq SIZE_P)

#define debugD G.xflags['d'-'a']

size_t g_init(TP xp, short area);			/* for recursion */

global
TP dummy_id(TP xp, TP head, short parnr)
{
	if (xp)
		if (xp->token ne ID)
		{
			TP e1 = make_type(ID, -1, nil, nil);
			if (xp->token eq T_VARGL)
				new_name(e1, "__ELLIPSIS__");
			else
				new_name(e1, "__P%d__", parnr);
			d_to_dt(e1, xp);			/* 12'14 v5.2 */
			if (xp ne head)
				type_is_a_copy(e1);
			return e1;
		}
	return xp;
}

global
void su_size(long *lp, char * cp, TP xp, short tok)
{
	long sz;
	char al;

	sz = xp->type->size;
	al = xp->type->aln;

	if (tok eq K_STRUCT)
	{
		while (al & *lp)
		{								/* align new field */
			*lp += 1;
			xp->offset += 1;
		}

		*lp += sz;
	}
	else
		*lp = *lp > sz ? *lp : sz;

/* 01'14 v5.1 PC compat */

	*cp = *cp > al ? *cp : al;
}

global
long loc_size(NP fp, TP xp, long *lp, ALREG *rp)
{
	long sz;
	char al;

	fp->name = xp->name;
	fp->rno = FRAMEP;
	fp->token = OREG;
	fp->size = xp->type->size;
	if (xp->sc eq K_REG)
		if (lc_reg(rp, xp, nil))		/* check types; nil = alloc high to low */
		{
			fp->r1 = xp->rno;
			return fp->size;
		othw
			xp->sc = K_AUTO;
		}

	if (xp->sc ne K_AUTO)
		return 0;

	sz = xp->type->size;
	al = xp->type->aln;

	if (*lp + sz > 16384)
	{
		errorn(xp, "more than 16384 bytes local name space at");
		return sz;
	}

	xp->lbl = new_lbl();
	fp->lbl = xp->lbl;

	while (al & *lp)
	{							/* align new field */
		*lp += 1;
		xp->offset += 1;
	}
	*lp += sz;
	xp->offset = LOC_BASE - *lp;
	fp->val.i = xp->offset;
	return sz;
}

global
void arg_size(long *lp, TP xp)
{
	long sz;
	char al;
								/* loc_size after all declarations */
	sz = xp->type->size ;
	if (sz < 0 ) sz = 0;		/* prototyping; voor vargl */
	al = xp->type->aln;
	while (al & *lp)			/* align new field */
		*lp += 1;
	sz = arg_align(sz, xp);		/* maakt xp->offset eerst 0 */
	xp->offset += *lp;			/* ARG_BASE after all declarations */
	*lp += sz;
}

global
void afterfld(long *sizep, short *fop)
{
	if (*fop)
	{
		*sizep += default_type(-1, 0)->size;	/* 06'11 HR regression fixed: always default size int */
		*fop = 0;
	}
}

/* only called if xp ne 0 and fldw > 0 */
global
void su_field(TP xp, long *sizep, char *alp, short fldw, short *fop)
{
	short w;

	if (*fop eq 0)					/* align properly */
		while (*alp & *sizep)
			(*sizep)++;

	if (*alp < ALN_I)
		*alp = ALN_I;

	w = 8*default_type(-1, 0)->size;	/* 06'11 HR regression fixed: always default size int */

	if (fldw + *fop > w)
		afterfld(sizep, fop);

	xp->fld.width  = fldw;
	xp->fld.offset = *fop;
	xp->fld.shift  = w - (fldw+*fop);		/* 02'11 HR optimization */

	*fop += fldw;
}

static
bool ok_ty(TP np, TP endp)
{
	TP type;
	long csize = 0;

#if FOR_A
	if (!(G.lang eq 'a' and np->token eq ARRAY))	/* The tree is slightly different from those for_C */
#endif
		if (np eq endp)
			return true;

	type = np->type;

	if (type)
	{
		if (ok_ty(type, endp) eq 0)
			return false;
		csize = type->size;
	}

	switch (np->token)
	{
	case REFTO:
		to_type(np, REFTO);
		break;
	case K_OP:
		if (	endp->token eq T_BOOL  /* is_CC(endp) */
			and !(is_compare(np->offset) or np->offset eq NOT)	)
			error("boolean result on no conditional operator");
		/* fall through */
	case K_CAST:
	case T_PROC:
			/*  size 0 okay; func ret void */
		if (   type->token eq ARRAY
		    or type->token eq ROW  )		/* 11'11 HR also ROW */
		{
			error("return of array not allowed");
			return false;
		}
		/* size 0 */
		break;
	case ARRAY:
/*		checking of csize moved to places where the sizes
		are actually needed.	(init and use)
*/
		np->token = ROW;		/* 04'09 confolded size */
		if (np->list)
		{
			long inds = confold_value((NP)np->list, FORSIDE);		/* frees its nodes */
			csize *= inds;
			np->list = nil;
			np->size = csize;
		}
		else
		{
			np->tflgs.f.formal = 1;
		}

		if (type->token eq T_VOID)		/* 11'11 HR ANSI */
			error("array of %s not allowed", graphic[K_VOID]);

		np->aln = type->aln;
		np->ty = ET_A;
		break;
	default:
		return true;
	}

	return true;
}

global
bool ok_prh(short sc, TP np)
{
	if ( sc ne 0 and sc ne K_AUTO and sc ne K_REG)
	{
		error("'%s' in arguments", graphic[sc]);
		return false;
	}
	return ok_ty(np, nil);
}

static
bool varglist(TP np)
{
	if ( np )
		if ( np->token eq T_VARGL )
		{
			error("'%s' outside function declaration", graphic[K_VARGL]);
			return true;
		}
	return false;
}

global
bool ok_gsh(short sc, TP np)
{
	G.prtab->insc = sc;
	if ( sc eq K_AUTO or sc eq K_REG)
	{
		error("'%s' outside function", graphic[sc]);
		return false;
	}
	if (varglist(np)) return false;

	return ok_ty(np, nil);
}

global
bool ok_gx(TP np, TP  endp)
{
	if (np)
	{
		return ok_ty(np->type, endp);
	}
	return false;
}

global
bool ok_lsh(short sc, TP np)
{
	G.prtab->insc = sc;
	if (G.prtab->level eq 1)
		return ok_prh(sc, np);
	return ok_ty(np, nil);
}

global
void array_to_pointer(TP np)
{
	TP tp = np->type;
	if (is_nct(np))
	{							/* cant change if no dupl. */
		tp = copyTone(tp);
		np->type = tp;
		not_nct(np);
		tp->nflgs.f.res = 0;
	}

	to_type(tp, REFTO);
	name_to_str(tp, "array_ptr to");
	tp->tflgs.f.saw_array = 1;		/* for &[] */
}

static
void func_to_pointer(TP np)
{
	TP tp = make_type(-1, REFTO, nil, "func_ptr to");
	tp->tflgs.f.saw_proc = 1;		/* 01'12 HR: for &proc */
	tp->type = np->type;
	np->type = tp;
	type_is_not_a_copy(tp);
	type_is_a_copy(np);
}

global
bool ok_prx(TP np, TP endp)
{
	/* for func decl formal parameters */
	if (np)
	{
		if (   np->type->token eq ARRAY
		    or np->type->token eq ROW		/* 04'09 */
		   )
		{
			ok_ty(np, endp);
			array_to_pointer(np);
		}
		if (np->type->token eq T_PROC)
		{
			ok_ty(np, endp);
			func_to_pointer(np);
		}
		if (np->type->token eq T_VOID)	/* ignore plain void */
		{
			freeTn(np);
			return false;
		}
		return ok_ty(np->type, endp);
	}
	return false;
}

global
bool ok_lx(TP np, TP endp)
{
	if (G.prtab->level eq 1)
		return ok_prx(np, endp);

	if (np)
		return ok_ty(np->type, endp);
	return false;
}

global
bool ok_sux(TP np, TP endp)
{
	if (np)
		return ok_ty(np->type, endp);
	return false;
}

global
bool ok_enx(TP np, TP endp)
{
	if (np and np->type eq endp)	/* no modifiers */
		return true;
	return false;
}

global
bool
ok_cast(TP np, TP endp)
{
	if (np)
	{
		if (varglist(endp))
			return false;
		return ok_ty(np, endp);
	}
	return false;
}

global
void regvar_options(TP xp, short sc)
{
	if (sc eq K_REG)
		xp->cflgs.f.see_reg = 1;
	if (sc eq 0)
		sc = K_AUTO;

	xp->sc = sc;
}

/* set array size or fill array with zeros */
/* squeeze can only be set for size 1 types */
static
void a_fix(TP tp, short area, size_t nsee, bool squeeze)
{
	size_t oldsize;

	if (tp->size)
	{
		oldsize = tp->size / tp->type->size;

		if (oldsize > nsee)
		{
			if (squeeze)			/* ANSI */
			{
				addcode(gp, "Z");
				nsee++;
				std_areas->ar[area].size++;
			}
			if (oldsize > nsee)
				o_nz(tp->type->size * (oldsize-nsee), area, tp->type->aln);
		}
		else if (oldsize < nsee)
			error("too many init expressions");
	othw
		if (squeeze)			/* ANSI */
		{
			addcode(gp, "Z");
			nsee++;
			std_areas->ar[area].size++;
		}
		tp->size = nsee * tp->type->size;
	}
}

/* initialize 0 or 1 thing of any type (tp) */
static
short scon_size(NP sc)
{
	if (is_scon(sc)) return        sc->size;
	else             return strlen(sc->name);
}

static
size_t inita(TP tp, short area, long maxi)
{
	size_t nsee = g_init(tp, area);	/* initialize up to max items of type tp */
	if (nsee)
		while (cur->token eq COMMA)
		{
			if (nsee eq maxi)
				break;
			fadvnode();
			nsee += g_init(tp, area);
		}

	return nsee;
}

/* init 1 long with the size of the initializer,
   init 1 ref to char with a ref to the initializer (must be a SCON) */

#if FOR_A
static
size_t init_str(short area)
{
	size_t nsee = 0;

	NP np = assignx();
	if (np)
		if (np->token eq SCON)		/* No need for asn_check :-) */
		{
			size_t sz = np->size;
			form_types(np, FORSIDE, 0);
			if (np->type and !G.nmerrors)
			{
				untype(np);
				branch_tree(np);
				np->str_sz = sz;
				nsee = genx(np, FORSTRINIT);
				if (nsee)
				{
					std_areas->ar[area].size += SIZE_STR;
					gp->size = SIZE_STR;
				}
				gp->right = np;
			}
		}
		else
			warn("needs string constant");

	return 1;
}
#endif

/* initialize one (or 0) scalar to an expr */
static
size_t init1(TP tp, short area)
{
	size_t nsee = 0;
	NP np = assignx();
	if (np)
	{
		G.prtab->tmps = 0;
		form_types(np, FORSIDE, 0);
		asn_check(tp, np, FORINIT);
		Cast(np, tp, IMPCNV, "Init cast");
		if (!G.nmerrors)
		{
			change_class(area);
			o_aln(tp->aln, area);
			untype(np);
			branch_tree(np);
			nsee = geni(np) ? 1 : 0;				/* reduced version of genx for init */
			if (nsee)
			{
				std_areas->ar[area].size += tp->size;
				gp->size  = tp->size;
			}
			gp->token = SCALAR;		/* for constanizing */
			gp->right = np;
		}
	}

	return nsee;
}

/* initialize (possible) structure */
static
size_t inits(TP xp, short area)
{
	size_t see1  = g_init(xp->type, area);

	if (see1 eq 0) return see1;

	xp = xp->next;
	while (xp)	/* for each member */
	{
		TP tp = xp->type;
		if (cur->token eq COMMA)
			fadvnode(), see1 = g_init(tp, area);
		else
			see1 = 0;

		if (see1 eq 0)
		{					/* was: z_init */
			if (is_aggreg(tp) or tp->token eq ROW)
				o_nz(tp->size, area, tp->aln);
			else
			{				/* was: out_zi */
				NP fp = gx_node();		/* own node for size */
				fp->size = tp->size;
				fp->ty   = tp->ty;		/* 11'11 HR: needed for out tlen() */
				std_areas->ar[area].size += tp->size;
				addcode(fp, "\t^YS\t\t0" C(inits) "\n");
				next_gp(fp);
			}
		}
		xp = xp->next;
	}

	return 1;
}


#if 0	/* member controlled initialization not yet. *) */
		if (cur->token eq ID)
		{
			XP id = cur;
			advnode();
			if (cur->token eq LABEL)
			{
				message("g_init : %s", id->name);
				freeXn(id), fadvnode();
			}
		}
#endif

/* initialize 0 or 1 thing of any type (tp) */
static
size_t g_init(TP tp, short area)
{
	size_t nsee, sz, oldsize;
	bool seebr = false;

	if (    cur->token eq SCON
	    and tp->token eq ROW
	    and (   tp->type->token eq T_CHAR
	         or tp->type->token eq T_UCHAR
	        )
	   )
	{ 										/* hack for SCON ary */
		NP concat = npcur(); advnode();
		concatstr(concat);				/* ANSI: concatenate adjacent strings */
		nsee = scon_size(concat);
		std_areas->ar[area].size += nsee;
#if NODESTATS
		G.ncnt[concat->nt]--;
		G.ncnt[GENODE]++;
#endif
		concat->nt = GENODE;
		addcode(concat, "X");
		next_gp(concat);
		a_fix(tp, area, nsee, true);		/* delayed terminating zero if room for */
		return 1;
	}


	if (cur->token eq BLOCK)
	{
		fadvnode();
		seebr = true;
	}

	switch (tp->token)
	{
	case ROW:					/* other than above */
		change_class(area);
		o_aln(tp->aln, area);
		oldsize = tp->size ? tp->size / tp->type->size : 0;
		nsee = inita(tp->type, area, oldsize);
		if (nsee)
			a_fix(tp, area, nsee, false);
		break;

	case K_STRUCT:

#if FOR_A && FLOAT
	case T_COMPL:
#endif
/* *) */
		change_class(area);
		o_aln(tp->aln, area);
		nsee = inits(tp->list, area);
		break;

	case K_UNION:
		change_class(area);
		o_aln(tp->aln, area);
		nsee = g_init(tp->list->type, area);	/* init only the first member */
		if (nsee)
		{
			sz = tp->size - tp->list->type->size;
			if (sz)
				o_nz(sz, area, 0);		/* zerofill remainder */
		}
		break;

#if FOR_A
	case T_STRING:				/* 10'14 v5.2 */
		change_class(area);
		o_aln(tp->aln, area);
		nsee = init_str(area);
	break;
#endif

	default:
#if 1
		nsee = init1(tp, area);
#else
#include "init_sca.h
#endif
		break;
	}

	if (seebr)
	{
		if (cur->token eq COMMA) fadvnode();
		eat(KCOLB);
	}

	return nsee ? 1 : 0;		/* straight from HCC :-) */
}

char *pclass(short);

global
void std_area_start(TP xp, short class)
{
	xp->area_info.class = class;
	xp->area_info.id    = std_areas->ar[class].id;
	if (class > 0 and class < high_class)
		xp->area_info.disp = std_areas->ar[class].size;
}

static
void
std_area_end(TP xp, short class)
{
	if (class > 0 and class < high_class)
	{
		if (class >= BSS_class)
			std_areas->ar[class].size += xp->type->size;
	}
}


global
void new_class(TP np, short new)
{
	change_class(new);
	o_aln(gp->aln, new);
	std_area_start(np, new);
}

/* variable with permanent extent */
global
void permanent_var(TP np, short class)
{
	long sz;
	TP tp;

	if (np->sc eq K_EXTERN)		/* ?? */
		return;

	tp = np->type;

	if (np->sc eq K_STATIC and G.prtab->level > 1)	/* lbl only if within func. */
		np->lbl = new_lbl();

	gp->sc  = np->sc;
	gp->lbl = np->lbl;
	gp->aln = tp->aln;
	gp->name = np->name;
	new_class(np, class);

	if (class eq BSS_class or class eq GBSS_class)
	{
		sz = tp->size;
		if (!sz)
			errorn(np, "size of object not known or zero");

/* Remove generation of 'comm'
   For Pure C linker and its stack allocation
   mechanism. All .comm was located at the end of the bss. Yes,
   after the stack, pcstart puts the stackpointer at the end of the
   bss and thus at the end if the .comm variables so that these soon
   became overwritten. */

		if (tp->aln)
			gp->size = DOT_W,		/* we dont know how much of which basic size. */
			sz /= DOT_W;			/* type->size is the whole */
		else
			gp->size = 1;

		gp->misc = sz;
		addcode(gp, "^N:\n\t^ZS\t\tM" C(perv 2) "\n");
	othw
		addcode(gp, "^N:" C(perv 4) "\n");
		out_gp();			/* must synchronize alignment */
		new_gp(nil, INIT);
	}
}

global
void warn_const(TP xp)
{
	TP tp = xp;
	if (xp->type and xp->type->token eq REFTO)	/* 08'13 HR */
		xp = xp->type;
	if (xp->cflgs.f.qc)
		warnn(tp, "uninitialized const object");
}

global
void auto_init(TP xp, NP ap, NP e1, short context)
{
	if (e1)
	{
		ap->left = t_copy_e(xp);		/* make expression node for left of assignment */
		ap->right = e1;
		ap->tt = E_BIN;
		if (G.prtab->level > 1)		/* not args */
			G.scope->b_locs += loc_size(gpbase, xp, &G.scope->b_size, &G.scope->b_regs);
		loc_sym(xp);
		next_gp(ap);
		do_expr(ap, context);	/* for local scalar init */
	}
}

global
bool static_init(TP xp)
{
	short class;
	TP tp = xp->type;

#if FOR_A							/* 'is defined as' operator */
#include "a_init.h"
#else

	if (is_ass(cur->token))			/* 02'17 HR: v5.6 */
	{
		tp->tflgs.f.formal = 0;			/* 04'09 */
		class = xp->sc eq K_GLOBAL ? GDATA_class : DATA_class;
		permanent_var(xp, class);
		fadvnode();
		std_area_end(xp, class);
		if (!g_init(tp, class))
		{
			errorn(xp, "Needs init expression(s)");			/* 04'17 HR: also missing in HCC */
			return false;
		}
	othw
		class = xp->sc eq K_GLOBAL ? GBSS_class : BSS_class;
		warn_const(xp);
		permanent_var(xp, class);
		std_area_end(xp, class);
	}

#endif
	return true;
}

global
NP add_tseg(void)
{
	NP fp = gx_node();
	fp->misc1 = TEXT_class;
	addcode(fp, "\n^D" C(add_tseg) "\n");	/* ^D dynamic change of area */
	return fp;
}

global
NP a_init(TP op)  /* local aggreg init only */
/* op is the declaration; it belongs to the symbol table!!
   Its not yet put in so we can copy, and we must,
   because we cant change it */
{
	TP xp;

	/* set aside initializer as static */
	xp = copyTnode(op);			/* symbol table entry for static initializer */
	xp->sc = K_STATIC;
	xp->rno = 0;
	permanent_var(xp, DATA_class);	/* sets also new_lbl() in xp->lbl */
	new_name(xp, "__%d", xp->lbl);
	loc_sym(xp);
	std_area_end(xp, DATA_class);
	g_init(xp->type, DATA_class);
	next_gp(add_tseg());
	op->type->size = xp->type->size;
	return t_copy_e(xp);  /* R of assignment */
}

global
void opt_enval(long *val)  /* enum id = value */
{
	NP np;

#if FOR_A
	if (   (G.lang eq 'a' and cur->token eq IS)
	    or (G.lang ne 'a' and cur->token eq ASS)
	   )
#else
	if (is_ass(cur->token))			/* 02'17 HR: v5.6 */
#endif
	{
		fadvnode();
		np = questx();
		*val = confold_value(np, FORSIDE);
	}
}

static
bool bad_fty(TP tp)
{
	short tok;

	tok = tp->token;

	if (   tok eq T_INT
	    or tok eq T_UINT
#if FOR_A
	    or tok eq T_DEF
#endif
	   )
		return false;

#if NO_INT
/* 01'11 HR: 06'11 HR: allow long/short with int32 */
	if (G.ai_int32 and (tok eq T_LONG or tok eq T_ULONG))
		return false;

	elif (!G.ai_int32 and (tok eq T_SHORT or tok eq T_USHORT))
		return false;
#endif
	return true;
}

global
void opt_field(TP xp, short *wdp, short tok)
{
	*wdp = -1;
	if (tok eq K_UNION) return;
	if (cur->token eq FIELD)
	{
		NP np;
		short i, w;

		fadvnode();
		np = questx();
		i = confold_value(np, FORSIDE);
		if (xp)
		{
			TP tp = xp->type;
			if (i < 0)
			{
				errorn(xp, "bad field width");
				return;
			}
			elif (bad_fty(tp))
			{
				errorn(xp, "bad field");
				return;
			}
			w = tp->size * 8;
			if (i > w)
			{
				errorn(xp, "field wider than %d bits", w);
				i = w;
			}
		}

		*wdp = i;
		return;
	}
}

#define NBAS (T_NTY-T_BOOL+1)

static
TNODE	basics[NBAS],
		scon_ptr,
#if FOR_A
		v_ptr,
		str_desc,
		lpart,
		spart,
#endif
		nil_ptr,
		func_int,
		compl_s,
		repart,
		impart;

#define DEF_BTBL 1
global
BASTAB btbl[] =
{
#include "bas_def.h"
};
#undef DEF_BTBL

global
TP asm_type(void)
{
	return basic_type(T_LONG, 10);		/* identifiers in operands without .w or .l (PASM compatible) */
}

global
TP default_type(short sc, short q)
{
	TP rv;
/*	if (sc eq K_EXTERN and !q)	/* 07'19 HR v6: Pure C doesnt warn */
		warn("no declarer for %s object", graphic[sc]);
*/
	rv =
#if FOR_A
		basic_type(T_DEF, 11);
#else
		basic_type(T_INT, 11);
#endif
	rv->tflgs.f.dflt = 1;		/* 07'19 HR: v6 avoid spurious no declarator for ... */
	rv->fl.ln = line_no;			/* 07'19 HR: v6 */
	return rv;
}

#if FOR_A
/* >>> 02'15 v5.2								*/
static
short cur_def_type(void)
{
	return G.ai_int32 ? T_LONG : T_SHORT;
}

global bool
same_intty(TP l, TP r)
{
	return l->token eq T_DEF and r->token eq cur_def_type();
}

global
bool same_int(TP ltp, TP rtp)
{
	return same_intty(ltp, rtp) or same_intty(rtp, ltp);
}
/* <<<											*/
#endif

/* 05.13 HR: v4.15
	There are so many reasons for returning false. So I decided
    to reverse truth value and to put meaning into falsehood.
*/

#if C_DEBUG
#define leave(l,x) { console("[%d]unsim %d\n", l, x); return x;}
#else
#define leave(l,x) return x;
#endif

global
short similar_type(short lvl, short q, TP lp, TP rp, short proty, short in)	/* prototyping; geheel herziene 'same_type' */
{
	/* prototyping: maak universeel */
	/* allways starts with ->type's if any */

	TP l = lp, r = rp;

	if (l ne r)		/* same h/w address is easy, this happens most often when the types
	                   come from the same symbol table or are basic :-) */
	{
		while (l and r)
		{
			short aggreg, pty;


			if (l->token ne r->token)
#if FOR_A
				if (!same_int(l, r) )
#endif
				 														leave(lvl, 1)

			if (l->token ne ROW)			/* index sizes may differ */
				if (	l->size and r->size
				    and l->size ne  r->size )							leave(lvl, 2)

			/* equal token pair at this point */
			aggreg = is_aggreg(l), pty = is_code(l);

			if (    (pty or aggreg)
			    and l->nflgs.f.brk_l eq 0
			   )
				if (similar_type(lvl+1, q, l->list, r->list, pty, in))	leave(lvl, 3)

			/* names in func decls may differ so we dont look at them */
			/* aggreg tag_names may have been generated so ignore them to   */
			/* and if only equivalency is the question, well */
			if (l->token eq ID)
				if (!proty and SCMP(200, l->name, r->name) ne 0)		leave(lvl, 4)
			/* 05.13 v4.15 */

			if (q and !(in or proty))			/* 11'09 HR: consider qualifiers */
			{
				/* only dismiss if right is less restrictive */
				if (    l->cflgs.f.qc eq 0
				    and r->cflgs.f.qc ne 0)								leave(lvl, 5)

				if (    l->cflgs.f.qv eq 0
				    and r->cflgs.f.qv ne 0)								leave(lvl, 6)

			}
			if (!aggreg)	/* geen taglists bekijken */
				if (similar_type(lvl+1, q, l->next, r->next, proty, 0))	leave(lvl, 8)
			if (l eq l->type or r eq r->type)
				break;

			l = l->type;
			r = r->type;
		}

		if (l or r) 	/* lost synchronization */						leave(lvl, 9)
	}

	return 0;		/* OK */
}

global
short default_class(void)
{
#if FOR_A
	return G.lang eq 'a' ? K_STATIC : K_GLOBAL;
#else
	return K_GLOBAL;
#endif
}

static
void make_t(TP tp, short tok, Cstr nm)
{
	tp->token = tok;
	tp->nt = TLNODE;
	tp->nflgs.f.res = 1;
	name_to_str(tp, nm);
}

/* 10'14 v5.2 */
static
void make_2ag(	short tok, short ttok, TP bas,
				TP t1, TP t2,
				short tok1, Cstr n1,
				short tok2, Cstr n2)
{
	make_t(bas, 0, graphic[tok]);
	make_t(t1, ID, n1);
	make_t(t2, ID, n2);
	bas->aln  = 1 /* btbl[t_tok(tok)].align */;
	bas->list = t1;
	t1->type = basic_type(tok1,12);
	t1->size = t1->type->size;
	t2->offset = t1->type->size;
	t2->type = basic_type(tok2,13);
	t2->size = t2->type->size;

	bas->size = t1->size + t2->size;

	t1->next = t2;
}

/* Allways called with token out of keyword table (that is; if thoroughly debugged) */
global
void to_type(TP np, short token)	/* ensure consistency of TLNODES */
{
	short n;

	if (!is_C(token))		/* not in table */
	{
		CE_X("weird type: %s\n", ptok(token));
		token = T_INT;
	}

	np->token = token;
	switch (token)
	{
		case T_PROC:
		case K_OP:
		case K_CAST:
		break;
		case K_STRUCT: 				/* derived types */
		case K_UNION:
			np->ty = ET_A;
			np->nflgs.f.brk_l = 1;	/* break list print loops */
		break;
#if FOR_A
		case K_STRING:		/* 10'14 v5.2 */
# if FLOAT
		case K_COMPL:
# endif
			np->ty = ET_A;
			np->nflgs.f.brk_l = 1;
		break;
#endif
		default:					/* basic types */
			{
				n = t_tok(token);
				np->ty   = btbl[n].type;
				np->size = btbl[n].size;
				np->aln  = btbl[n].align;
			}
	}

	np->cat0 = KW_C(token);
}

/*		declare basic type(s) */
global
TP bas_type(short btype)
{
	TP rv ;
	short bm;
	short i;

	if (!G.first_declare)
	{
		G.first_declare = true;

		for (i = 0; i<NBAS; i++)
			basics[i].token = 0;
/* dont want to change the original type names */
		if (G.ai_int32)
		{
			btbl[t_tok(T_INT )].size  = SIZE_L;
			btbl[t_tok(T_INT )].align = ALN_L;
			btbl[t_tok(T_UINT)].size  = SIZE_L;
			btbl[t_tok(T_UINT)].align = ALN_L;
		othw
			btbl[t_tok(T_INT )].size  = SIZE_I;
			btbl[t_tok(T_INT )].align = ALN_I;
			btbl[t_tok(T_UINT)].size  = SIZE_I;
			btbl[t_tok(T_UINT)].align = ALN_I;
		}
#if FOR_A
		btbl[t_tok(T_DEF)] = btbl[t_tok(T_INT)];
		btbl[t_tok(T_DEF)].text = "default type";
#endif

#if COLDFIRE && FLOAT
		if (G.Coldfire)
		{
			btbl[t_tok(T_REAL)].size  = SIZE_D;
			btbl[t_tok(T_REAL)].align = ALN_D;
		othw
			btbl[t_tok(T_REAL)].size  = SIZE_X;
			btbl[t_tok(T_REAL)].align = ALN_X;
		}
#endif
		name_to_str(&scon_ptr, "scon_ptr to");
		to_type(&scon_ptr, REFTO);
		scon_ptr.nflgs.f.res = 1;
		scon_ptr.nt = TLNODE;
		to_nct(&scon_ptr);
		scon_ptr.type = basic_type(G.k_char_is_unsigned ? T_UCHAR : T_CHAR, 100);

#if FOR_A
		name_to_str(&nil_ptr, "nil_ptr to");
		to_type(&nil_ptr, REFTO);
		nil_ptr.nflgs.f.res = 1;
		nil_ptr.nt = TLNODE;
		to_nct(&nil_ptr);
		nil_ptr.type = basic_type(T_VOID, 200);

		name_to_str(&v_ptr, "generic_ptr");
		to_type(&v_ptr, REFTO);
		v_ptr.nt = TLNODE;
		v_ptr.nflgs.f.res = 1;
		to_nct(&v_ptr);
		v_ptr.type = basic_type(T_VOID, 300);
#endif

		name_to_str(&func_int, "func_rtn");
		to_type(&func_int, T_PROC);
		func_int.nflgs.f.res = 1;
		func_int.nt = TLNODE;
#if FOR_A
		if (G.lang eq 'a')
			func_int.type = basic_type(T_VOID, 400);
		else
			func_int.type = default_type(-1, 0);
		/* default should allways have been 'void' */
#else
		func_int.type = default_type(-1, 0);
#endif
		to_nct(&func_int);

#if FOR_A && FLOAT
		make_2ag(K_COMPL,  T_COMPL, &compl_s,  &repart, &impart, T_REAL,  "re", T_REAL,  "im");	/* 10'14 v5.2  compl(ex) description */
#endif
#if FOR_A
		make_2ag(K_STRING, T_STRING, &str_desc, &lpart,  &spart,  T_ULONG, "l",  SCON,    "s");	/* 10'14 v5.2  string dscriptor */
#endif
	}

#if FOR_A
	if (btype eq PV)
		return &v_ptr;

	if (btype eq K_NIL)
		return &nil_ptr;
#endif

	if (btype eq REFTO)
	{
		rv = make_type(-1, REFTO, nil, "ptr_to");
		graphic[btype] = rv->name;		/* for displaying */
		return rv;
	}

	if (btype eq SCON)
		return &scon_ptr;

	if (btype eq T_PROC)
		return &func_int;

#if FOR_A
	if (btype eq T_STRING)		/* 10'14 v5.2 */
	{
		rv =  &str_desc;
		bm = t_tok(T_STRING);
	}
# if FLOAT
	elif (btype eq T_COMPL)
	{
		rv = &compl_s;
		bm = t_tok(T_COMPL);
	}
# endif
	else
#endif
	{
#if C_DEBUG
		if (!(is_C(btype) and (KW_C(btype)&BASIC) ne 0))
		{
			error("type not basic: %s\n", ptok(btype));
			btype = T_INT;
		}
#endif
		bm = t_tok(btype);
		rv = &basics[bm];
	}


	if (rv->token eq 0)			/* if not allready declared */
	{
	#if NODESTATS
		G.ncnt[rv->nt]--;
		G.ncnt[TLNODE]++;
	#endif
		rv->nt = TLNODE;
		to_type(rv, btype);
		rv->nflgs.f.res = 1;
		name_to_str(rv, btbl[bm].text);
		graphic[btype] = rv->name;		/* for displaying */

#if NO_INT					/* make int synonymous to either short or long */
		if (G.ai_int32)
		{
			if (rv->token eq T_INT)
				rv->token = T_LONG;
			elif(rv->token eq T_UINT)
				rv->token = T_ULONG;
		othw
			if (rv->token eq T_INT)
				rv->token = T_SHORT;
			elif(rv->token eq T_UINT)
				rv->token = T_USHORT;
		}
#endif
	}

	return rv;
}

global
bool double_size(void *vp)
{
	NP np = vp;
#if COLDFIRE
	if (G.Coldfire)
		return np->size eq SIZE_D;
#endif
	return np->size eq SIZE_X;
}

global
short CC_ty(NP lp, NP rp)
{
	short ty = ET_CC;
#if FLOAT
	if (lp->ty eq ET_R)
		if (double_size(lp))
			ty = ET_XC;
		else
			ty = ET_FC;

	if (ty eq ET_CC and rp)
		if (rp->ty eq ET_R)
			if (double_size(rp))
				ty = ET_XC;
			else
				ty = ET_FC;
#endif
	return ty;
}

global
TP CC_type(NP lp, NP rp)
{
	short ty = ET_CC;
	TP tp = copyTone(basic_type(T_BOOL, 14));		/* must copy because of ty */

	tp->nflgs.f.res = 0;
	ty = CC_ty((NP)lp->type, rp ? (NP)rp->type : nil);
	tp->ty = ty;
	return tp;
}

/* declare arg name as integral */
global
void def_arg(TP *listpp, TP op)
{
	TP np = copyTone(op);
	np->type = default_type(-1, 0);
	to_nct(np);
	np->sc = K_AUTO;
	list_sym(listpp, np);
}

/* 10'13 v5 HR */
static
bool pu_ok(TP tp)		/* true if pointer union */
{
	if (tp)
	{
		tp = tp->list;
		while (tp)
		{
			TP lp = tp->type;

			if (lp->ty ne ET_P and !is_ulp(lp))
 				return false;

			tp = tp->next;
		}
	}
	else
		return false;

	return true;
}

global
bool can_pu(TP xp)
{
	TP tp = xp->type;

	if (tp)
		return is_aggreg(tp) and tp->token eq K_UNION and tp->size eq SIZE_P and pu_ok(tp);
	return false;
}

global
void set_vreg(TP xp)
{
	if (xp->type)
	{
		short ty = xp->type->ty;
		/* 10'13 v5.0 HR */
		bool have = can_pu(xp);

		if ((ty >= ET_B and ty < ET_A) or have)
		{
			xp->vreg = G.scope->vreg;
			G.scope->vreg.r++;
			xp->vreg.r = G.scope->vreg.r;
			if (have)
				xp->type->tflgs.f.pu = 1;		/* 10'13 v5 HR */
		}
	}
}

global
void loc_advice(TP np, NP fp)
{
	TP tp = np->type;
	long size = tp->size;

	if (size <= 0)
		return;

	fp->ty = tp->ty;			/* 03'11 HR !!!!!! */

	if (    (    is_aggreg(tp)
		      or tp->token eq ROW
#if FLOAT
		      or (tp->ty eq ET_R and !G.use_FPU)
#endif
	        )
		and tp->tflgs.f.pu eq 0
	   )
	{
		return;
	}

	if (tp->tflgs.f.pu)
	{
		fp->ty = ET_A;
		fp->eflgs.f.pu = 1;
		fp->vreg = np->vreg;
		addcode(fp, "\tvraS\t\tA\n");
	}
	elif (np->sc eq K_AUTO)
	{
		fp->vreg = np->vreg;
		if (tp->token eq REFTO)
			addcode(fp, "\tvraS\t\tA\n");
#if FLOAT
		elif (tp->ty eq ET_R)
			addcode(fp, "\tvrfS\t\tA\n");
#endif
		else
			addcode(fp, "\tvrdS\t\tA\n");
	}
	elif (np->sc eq K_REG)
	{
		if (tp->token eq REFTO)
			addcode(fp, "\trgaS\tR1[^N]\n");
#if FLOAT
		elif (tp->ty eq ET_R)
			addcode(fp, "\trgfS\tR1[^N]\n");
#endif
		else
			addcode(fp, "\trgdS\tR1[^N]\n");
	}
}

/* 04'14 v5.1 */
static
NP t_to_gx(TP tp, NP gp)
{
	if (gp eq nil)
		gp = gx_node();
	if (gp)
	{
		gp->ty    = tp->ty;
		gp->size  = tp->size;
		gp->name  = tp->name;
		gp->vreg  = tp->vreg;
		gp->val.i = tp->offset;
	}

	return gp;
}

/* 04'14 v5.1 */
global
NP e_temp_var(TP type)
{
	NP np;
	TP tp;

	np = nil;
	tp = allocTn(1);
	if (tp and type)
	{
		NP fp;
		tp->token = ID;
		tp->lbl = new_lbl();
		new_name(tp, "__%d", tp->lbl);
		tp->type = type;
		tp->sc = K_AUTO;
		tp->size = type->size;
		G.scope->b_size += type->size;
		tp->offset = -G.scope->b_size;
		set_vreg(tp);
		loc_sym(tp);
		fp = t_to_gx(tp, nil);
		if (fp)
		{
			fp->token = OREG;
			fp->rno = FRAMEP;
			loc_advice(tp, fp);
			prev_gp(fp);
			np = copyone((NP)tp);
			if (np)
				np->nt = EXNODE;
		}
	}
	return np;
}
