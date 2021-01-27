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
 *	decl.c
 *
 *	Do all declarations
 *
 *	Currently,
 *		struct tags are local
 *		struct members are tied to the struct
 *		enum tags are ignored
 *		enum members are local
 *
 */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "common/pdb.h"

#include "param.h"
#include "pre.h"
#include "body.h"
#include "expr.h"
#include "e2.h"
#include "decl.h"
#include "d2.h"
#include "md.h"
#include "out.h"

TP declarator(void);		/* this is THE recursive one */

#define debugD G.xflags['d'-'a']
#define debugQ G.xflags['q'-'a']

/* decl.c */

static
TP yields_code (TP mp)
{
	while(mp)
	{
		if ( is_code(mp)) break;
		mp = mp->type;
	}
	return mp;
}

/* 2nd def of same name at same level */

static
bool def2nd(TP old, TP new)	/* prototyping: herzien */
{
	short osc, nsc, reason;
	TP pt, tp = new->type, op = old->type;

	osc = old->sc;
	nsc = new->sc;
	pt = yields_code(tp);

	reason = similar_type(0, 1, op, tp, pt ne 0, 0);
	if (reason eq 0)
	{
		if (    osc eq ENUM
		    and nsc eq ENUM
		   )
			if (old->offset ne new->offset)		/* 05'10 HR check enums */
			{
				errorn(new, "bad redeclaration of");
				freeTn(new);
				return false;
			}
			else
				return true;

		if (	(osc eq nsc)
			and (osc eq K_TYPE or osc eq PROT)
		)
		{
			freeTn(new);
			return false;
		}

/* Exception for variables of type row. 04'09 */
		if (op->tflgs.f.formal)
			return true;		/* use second def */

/* Exception for variables of type func. */
		if (    pt
		    and (   (    osc eq K_EXTERN
		             and nsc ne PROT
		            )
		         or (    osc ne PROT
		             and nsc eq K_EXTERN
		            )
		        )
		   )
		   	return false;
	}

/* 11'09 HR: empty lists: type p(); type p() { ... }
             check independent from old/new style.	*/
/* 09'11 HR: Ooofff, checked the wrong list. */
/* WRONG !!!!  and old->list eq nil and new->list eq nil */

	if (    reason	eq 0			/* 06'11 HR */
		and tp and op
		and yields_code(op) ne nil
		and tp->list eq nil
	    and op->list eq nil
	   )
		return true;

	if (   (pt ne nil and osc eq PROT and reason eq 0)
	    or (pt eq nil and reason eq 0)
	   )
	{
		if (osc eq PROT)
		{
			if (tp->tflgs.f.old_args)
/* make inernal name so calls are matched against prototype.
 * We cannot free the node because it is a body definition.
 */ 			new_name(new, "__%d__", new_lbl());

			old->area_info = new->area_info;
			return true;
		}

		if ( osc eq K_EXTERN )
			return true;

		if ( nsc eq K_EXTERN )
		{
			freeTn(new);
			return false;
		}
	}

#if 1 /* C_DEBUG */
	errorn(new, "[%d]bad second declaration of", reason);
#else
	errorn(new, "Bad second declaration of");
#endif
	/* use 2nd def so other stuff works */
	return true;  /* put in front of list */
}

global
void loc_sym(TP xp)	/* 12'19 HR: v6 void function */
{
	TP old;

	if (xp)
	{
		if (xp->type and xp->type->tflgs.f.old_args)
			putt_lifo(&G.scope->b_syms, xp);
		elif (xp->type and is_op(xp->type))
			putt_lifo(xp->type->token eq K_OP ? &G.scope->b_ops : &G.scope->b_casts, xp);
		else
		{
		/* put in table */
		/* later look for previous definition */
			old = tlook(G.scope->b_syms, xp);
			if (   old eq nil
			    or def2nd(old, xp)
			   )
				putt_lifo(&G.scope->b_syms, xp);
		}
	}
}

/* put in listpp */
global
void list_sym(TP *list, TP xp)
{
	if (xp)
		/* put in table */
		putt_lifo(list, xp);
}

/* assemble decl and put in table */

static
short pdb_scope(short scope)
{
	switch (scope)
	{
		case PROT:
		case K_EXTERN:
			return -1;
	}
	return 0;
}

void pt(TP tp, Cstr s)
{
	if (strncmp(tp->name, "weiter", 6) eq 0)
		message("%s %s", s, tp->name);
}

global
void globl_sym(TP xp)
{
	if (xp)
	{
		TP old;
#if C_DEBUG
		if (xp->type and xp->type->xflgs.f.pasc)
			messagen(xp,"pascal symbol");
#endif

		if (xp->type and is_op(xp->type))
			putt_lifo(xp->type->token eq K_OP ? &G.optab : &G.casttab, xp);
		else
		{
		/* put in table */
		/* later look for previous definition */
			short h = hash(xp->name);
			old = tlook(symtab[h], xp);
			if (   old eq nil
			    or def2nd(old, xp)
			   )
			{
#if NODESTATS
				G.symbols++;
#endif
				put_hlist(&symtab[h], xp);
#if BIP_CC
				if (G.ah_project_help)
					pdb_new_ide(&identifiers, xp->name, G.inctab->p.fileno, xp->fl.ln, pdb_scope(xp->sc));
#endif
			}
		}
	}
}


#if  C_DEBUG
static
long simcount = 0, hwcount = 0, swcount = 0;

static
void psimcounts(void)
{
	send_msg("sim_type counts: %ld\n", simcount);
	send_msg("         hw      %ld\n", hwcount);
	send_msg("         sw      %ld\n", swcount);
	simcount = 0, hwcount = 0, swcount = 0;
}

static
void spr(short id, short lvl, TP a, TP b)
{
	if (id eq 6)
	message("[%d,%d]%lx,%lx\t%s,%s", id, lvl,
			a,
			b,
			a->name ? a->name : "œœœ",
			b->name ? b->name : "œœœ" /* ,
			pdb_file_by_number(auto_dependencies, a->fileno),
			pdb_file_by_number(auto_dependencies, b->fileno) */
		    ),
	bios(2,2);
}
#endif

static
bool ok_tytok(TP e1, TP tp)
{
	switch (tp->token)
	{
	case REFTO:
		name_to_str(tp, "Ptr to");
		break;
/*		case K_PROC:
		tp->token = T_PROC;
*/
	case T_PROC:
		name_to_str(tp, "function returning");
		break;

	case ARRAY:
		name_to_str(tp, "array of");
		break;

	case K_CAST:
		name_to_str(tp, "cast to");
		break;

	case ID:
	case K_OP:
		break;

	default:
		errorn(e1, "bad type expression at %s", graphic[tp->token]);
		return false;
	}

	return true;
}

static
bool ok_revx(TP rv, short dty)
{
	/* if normal decl and see something, must see id first */
	/* if for func then id optional and if absent generated */
	/* if for cast then id forbidden */
	/* if normal   then id required  */

	if (rv)
	{
		if ( dty eq NORMAL and rv->token ne ID )
		{
			error("Declaration needs ID");
			return false;
		}
		if ( dty eq CAST and rv->token eq ID )
		{
			errorn(rv, "ID in cast");
			return false;
		}
	}
	return true;
}


static
TP rev_decl(TP e1, TP *t)
{
	TP scan = e1, rv = nil;

	while (scan)
	{
		TP nxt = scan->next;
		if (!ok_tytok(e1, scan))
		{
			freeTn(scan);
			return nil;
		}

	/* transform declarer tree into type list */
		scan->next = nil;
		scan->type = rv;

		if (rv eq nil)
			*t = scan;

		rv = scan;
		scan = nxt;
	}

	return rv;
}

static
TP ok_decl_C(TP rv, TP head, TP tail, short forcast)
{
	/* if normal decl and see something, must see id first */
	/* if for func then id optional and if absent generated */
	/* if for cast then id forbidden */
	/* if normal   then id required  */

	if (!ok_revx(rv, forcast))
	{
		freeTn(rv);
		return nil;
	}

	if (rv)
		d_to_dt(tail, head);
	elif (forcast) 			/* 0 normal 1 cast 2 func */
		rv = head; 			/* cast or func */

#if PRLN
	G.To_prln = rv;		/* For #pragma prln */
#endif
	return rv;
}


#if FOR_A
#include "decl_a.h"
/* #else
#include "decl_c.h"
*/
#endif

global
TP Declare(TP head, short forcast)
{
	TP rv, tail = nil;
	TP e1 = declarator();

#if FOR_A
	if (G.lang eq 'a')
	{
		e1 = Declare_A(e1, head);
		return ok_decl_A(e1, head, forcast);
	}
#endif

	rv = rev_decl(e1, &tail);
	return ok_decl_C(rv, head, tail, forcast);
}

static
short storage_class(void)
{
	short sc = 0;

	if (is_sclass(cur))
	{
		sc = cur->token;
		fadvnode();
	}
	return sc;
}

/* look for qualifiers 'const' or 'volatile'	*/
static
short qualifier(void)
{
	if  (cur->token eq K_CONST)
		return fadvnode(), CONST;

	if (cur->token eq K_VOLAT)
		return fadvnode(), VOLAT;
#if 0
	if (cur->token eq K_RESTRICT)
		return fadvnode(), RESTRICT;
#endif
	return 0;
}

/* look for modifiers 'long', 'short', 'unsigned'
 * extra: 'signed' 'double'
 *        ('single' 'extended'; FOR_A)
 */
static
short modifier(void)
{
	short adj = 0;

	if (   is_tadj(cur)
		or is_xadj(cur)
	   )				/* alg&ANSI; is_xadj  */
	{
		switch (cur->token)
		{
		case K_SHORT:
			adj = SAW_SHORT;
			break;
		case K_LONG:
			adj = SAW_LONG;
			break;
		case K_UNS:
			adj = SAW_UNS;
			break;
#if FOR_A
		case K_SINGLE:
			adj = SAW_SINGLE;
			break;
#endif
#if FLOAT
		case K_DOUBLE:
			adj = SAW_DOUBLE;
			break;
#endif
		case K_SIGNED:						/* ANSI */
			adj = SAW_SIGNED;
			break;
		}
		fadvnode();
	}

	return adj;
}

/* Decls inside Struct/Union */
static
void su_decls(TP *listpp, short isstruct, long *sizep, char * alnp)
{
	TP head = nil, xp;
	long size = 0;
	char aln = 0;
	short fldw = 0, fldoff = 0;
	bool iscomma, isends, declty;
	short noclass = -1;
	do
	{
		iscomma = 0;
		isends  = 0;

		head = Declarer(false, nil, &noclass, &declty);

		do
		{
			xp = Declare(head, NORMAL);
			opt_field(xp, &fldw, isstruct);
			if (ok_sux(xp, head))			/* ook sclass */
			{
				if (fldw > 0)
				{									/* handle field */
					su_field(xp, &size, &aln, fldw, &fldoff);
					xp->offset = size;
				othw								/* handle non-field */
					afterfld(&size, &fldoff);
					xp->offset = isstruct eq K_STRUCT ? size : 0;
					su_size(&size, &aln, xp, isstruct);
				}
				list_sym(listpp, xp);
				listpp = &xp->next;
			othw
				if (fldw eq 0)
					afterfld(&size, &fldoff);
			}
			iscomma = cur->token eq COMMA;
			if (iscomma) fadvnode();
		}
		while (iscomma);

		isends = cur->token eq ENDS;
		if (isends) fadvnode();
	}
	while (isends);

	afterfld(&size, &fldoff);

	while (aln & size)
		size++;

	*sizep = size;
	*alnp  = aln;
}

/* bits true :: Decls inside Ebit (HR: For fun only)

ebit { B0, B1, B2, B3 };
yields:
#define B00 0x0001
#define B01 0x0002
#define B02 0x0004
#define B03 0x0008

etc

*/

/* Decls inside Enum */
static
void enum_decls(bool bits)
{
	TP head, xp;
	long curval = bits ? 1 : 0;

	head = default_type(-1, 0);

	do{
		xp = Declare(head, NORMAL);
		if (ok_enx(xp, head))
		{
			opt_enval(&curval);
			xp->offset = curval;

			xp->sc = ENUM;
			xp->token = ICON;
			xp->type = basic_type(icon_ty((NP)xp), 1);     /* final type */

			if (G.prtab->level)
				loc_sym(xp);
			else
				globl_sym(xp);
		}

		if (bits)
			curval<<=1;
		else
			curval++;
#if 1							/* 10'14 v5.2 */
		if (cur->token ne COMMA)
			return;
		fadvnode();
#else
		if (cur->token eq COMMA)
		{
			fadvnode();
			continue;
		}
		else
			return;
#endif
	}od
}

static
TP decl_enum(bool bit)
{
	short stok;
	fadvnode();				/* skip 'enum' */

	if (cur->token eq ID)
	{						/* ignore tag */
		fadvnode();
	}

#if FOR_A
		stok = cur->token eq BLOCK ? KCOLB
				: (cur->token eq PAREN ? NERAP : 0 );
	if (stok eq KCOLB or stok eq NERAP)
#else
	stok = KCOLB;
	if (cur->token eq BLOCK)
#endif
	{						/* new declaration */
		fadvnode();			/* skip PAREN */
		enum_decls(bit);		/* global scope */
		eat(stok);
	}
	return default_type(-1, 0);
}

static
TP alltags(TP np)
{
	SCP bp;
	TP rv = nil;

	for (bp = G.scope; bp ne nil; bp = bp->outer)
		if ((rv = tlook(bp->b_tags, np)) ne nil)
			break;

	if (!rv)
		rv = tlook(G.tagtab, np);

	if (rv)
	{
		free_name(np);
		np->name = rv->name;
	}
	return rv;
}

global
TP all_syms(TP np, short usage)
{
	SCP bp;
	TP rv = nil;

	for (bp = G.scope; bp ne nil; bp = bp->outer)
		if ((rv = tlook(bp->b_syms, np)) ne nil)
		{
#if USAGE
			if (usage)		/* 12'08 HR usage tracking */
				if (usage eq FORSEE)
				{
					rv->tflgs.f.used = 1;
					if (rv->tflgs.f.isarg eq 0)		/* dont warn arguments */
						if (rv->tflgs.f.inid eq 0)
							warnn(np, "no assignment to");
				}
#endif
			break;
		}

	if (!rv)
		rv = tlook(symtab[hash(np->name)], np);

	if (rv)
	{
		free_name(np);
		np->name = rv->name;
	}
	return rv;
}

#if FOR_A
#include "declr_a.h"
#else
#include "declr_c.h"
#endif

static
TP derived_type(bool *declty)
/* look for derived types */
{
	TP rv;
	short is_lbl(Cstr);

	*declty = false;

	if (cur->token eq ID)
	{
		rv = all_syms((TP)cur, 0);
		if (rv eq nil)
			return nil;
		if (rv->sc eq K_TYPE)
		{
			fadvnode();

			if (is_lbl(rv->type->name) > 0)		/* 11'09 HR: borrowed from OPT.C :-) */
				new_name(rv->type, "type %s", rv->name);	/* for display in messages */

			return rv->type;
		}
		else
			return nil;			/* !!! */
	}
	if (cur->token eq K_UNION)
	{
		*declty = true;
		return decl_su(K_UNION);
	}
	if (cur->token eq K_STRUCT)
	{
		*declty = true;
		return decl_su(K_STRUCT);
	}
#if FOR_A
	if (cur->token eq K_EBIT)
	{
		*declty = true;
		return decl_enum(true);		/* enumerate bits, not numbers */
	}
	if (cur->token eq K_PROC)
	{
		*declty = true;
		return decl_proc();
	}
	if (cur->token eq K_GREF)		/* generic reference (ref void) */
	{
		*declty = true;
		fadvnode();
		return basic_type(PV, 2);
	}
#endif	/* FOR_A */
	if (cur->token eq K_ENUM)
	{
		*declty = true;
		return decl_enum(false);
	}

	return nil;
}

#if FOR_A
/*
 * Looking for type makers [], ref, deref
 */

static
TP type_maker(bool loc, short *dclass, short *sclass, short *q, bool *declty)
{
	TP rv = nil;
	NP e1;
	short c = cur->token eq K_CONST;
	if (c) fadvnode();

	switch (cur->token)
	{
		case ARRAY:
			rv = tpcur(); advnode();
			e1 = questx();
			eat(YARRA);
			name_to_str(rv, "row_of");
			rv->ty = ET_A;				/* 10'14 v5.2 */
			rv->type = Declarer(loc, dclass, sclass, declty);
			may_nct(rv);				/* 12'14 v5.2 */
			rv->tflgs.f.tm = 1;			/*      "     */
			rv->list = (TP)e1;			/* will disappear after confold_value() */
			break;
		case K_DEREF:
			cur->aflgs.f.deref = 1;
			fall_thru
		case K_REF:
			rv = tpcur(), advnode();
			to_type(rv, REFTO);
			rv->type = Declarer(loc, dclass, sclass, declty);
			if (c)
				rv->cflgs.f.qc = 1, c = 0;	/* used */
			may_nct(rv);				/* 12'14 v5.2 */
			rv->tflgs.f.tm = 1;			/*      "     */
	}

	if (q) *q |= c;		/* if c is used above, its zeroized */

	return rv;
}
#endif

/*
 * Looking for declaration specifiers & modifuers
 */
/* was: d_type()
   prototyping & ANSI;
   rather changed:	Now completely according to K&R 1st & 2nd editions.
   N.B. *sclass contains default storage class; negative means not allowed.
        *dclass receives a storage class that is positively specified.
         if absent, the caller can decide on the default storage class.
*/
global
TP Declarer(bool loc, short *dclass, short *sclass, bool *declty)
{
	short see, seen,
		b = 0,
		c = 0,
		sc = 0,
		adj = 0,
		qual = 0,
		longs = 0;			/* count longs, normally only 1, 2 if LONGLONG */

	TP rv = nil;

	*declty = false;		/* declty false: declarator required; true not */

#if FOR_A
	if (G.lang eq 'a')
	{
		if (*sclass >= 0)				/* sc allowed */
			if ( (sc = storage_class()) ne 0)
			{
				seen = sc;
				see = sc;
				*sclass = sc;
			}

/* type_maker() builts a type list by calling this declarer() recursively */
		rv = type_maker(loc, dclass, sclass, &qual, declty);
		if (rv)
			return rv;
	}
#endif

	do
	{
		seen = 0;

		if (*sclass >= 0)				/* sc allowed */
			if (!sc)					/* look for storage class only once */
			{
				if ( (sc = storage_class()) ne 0)
				{
					seen = sc;
					see  = sc;
					*sclass = sc;
				}
			}

		see = qualifier();	/* look for qualifiers */

		qual |= see;
		seen |= see;
		see = modifier();		/* look for modifiers  */

#if LL
		if (see eq SAW_LONG)
		{
			longs++;
			if (longs eq 2)
			{
				if (G.i2_68020)
					see = SAW_2LONG;
				else
					error("long long only available with option -2");
			}
		}
#else
		if (see eq SAW_LONG)
		{
			longs++;
			if (longs eq 2)
				error("long long not available yet");
		}
#endif

		adj  |= see;
		seen |= see;

		if (!rv)						/* look for types only once */
		{
			see = is_plain(cur);
			if (see)
			{							/* look for plain types like 'char', 'int', '...', etc, see defs.h */
				b = cur->token;

				rv = basic_type(plain_type(b), 3);
				c = rv->token;
				fadvnode();
			othw
				rv = derived_type(declty);	/* look for 'struct', 'union', 'enum', proc' 'gref' or typedef names */
				see = rv ne 0;				/* enum returns default_type(-1, 0) in rv */
				if (see and is_basic(rv))
				{
					c = rv->token;
					b = c; 	/*	want to het rid of t_to_k!!!! */
				}
			}
			seen |= see;
		}
	}	while (seen);

	b = c;
	if (adj eq 0 and rv eq nil)				/* saw nothing  */
		rv = default_type(*sclass, qual);
	elif (!rv)								/* didnt see a type */
# if FLOAT
		if (adj & (SAW_SINGLE|SAW_DOUBLE) )
			b = T_FLOAT;
		else
# endif
			b = T_INT;
	if (b or adj)
		b = modify_type(b, adj);
# if FLOAT
	if (adj eq 0 and !G.use_FPU and b eq T_REAL)	/* 'real' only, no 'double|extended' */
		b = T_FLOAT;
# endif

	if (b)
	{
		rv = basic_type(b, 4);

	/*  ANSI: The problem with qualification is:
		syntacticly it belongs to the type, so thats the easiest way to
		handle it. Especially in this implementation.
		But it is really a property of the object.
		Basically the 2 are unrelated.
		type specifies format, qualifier specifies usage of declared object;
		The way qualifiers are defined in C is a real nuisance, not only
		for the user of C, but also for the compiler writer.
		Generally this is the case for C declaration syntax.
		K&R tried to combine 2 worlds (declaration & expression) syntactically
			that are semantically profoundly different.

		In Algol 68 e.g. the way an object is initialized determines whether
		the object is constant.  'int a := 1' vs 'int a = 1'
		In C you can have uninitialized constant objects.		Hmmm.
	*/
	}

	if (qual)
	{
		un_q(rv);				/* 01'15 v5.2 */
		rv = qualify_type(rv, qual);	/* This is the only call (besides the calls to itself) v5.2 improved*/
	}

	return rv;
}

/* do local decls
	return true if see something
*/
global
bool loc_decls(void)			/* called from body.c */
{
	TP head, xp;
	short sclass;
	bool rv = 0, iscomma, declty;

	while (is_ty_start())
	{
		sclass = 0;		/* prototyping; defaults ---> regvar_options() */
						/* zie ook C_args en A_args */
		rv |= true;

		/* ANSI: sclass --> declarer (K&R all editions) */

		head = Declarer(true, nil, &sclass, &declty);
		ok_lsh(sclass, head);
		do
		{
			iscomma = 0;
			xp = Declare(head, NORMAL);
			if (ok_lx(xp, head))
			{
				TP tp = xp->type;
				xp->sc = sclass;

				if (is_code(tp))
				{
					/* This is the spot for allowing local procs */
					if (tp->tflgs.f.ans_args)
					{
#if FOR_A && LOC_PROC 			/* No local proc's for now: problems with register usage */
						if (!(cur->token eq COMMA or cur->token eq ENDS))
							tp->xflgs.f.cdec = 1, loc_proc(xp, L_PROC);
						else
#endif
						{
							if (xp->sc ne K_TYPE)	/* local typedef proc's */
								xp->sc = PROT;
							loc_sym(xp);
						}
					othw
						if (tp->list)		/* old args with decls */
							warnn(xp, "current C does not support local procedures");
						loc_sym(xp);
					}
				othw
					NP ap = nil;
#if FOR_A
					long slocs = G.scope->b_locs,
						 ssize = G.scope->b_size;
					ALREG sregs = G.scope->b_regs;
#endif
					new_gp(nil, LINIT);
					regvar_options(xp, sclass);
					set_vreg(xp);

					if (xp->token eq ID)
					{
						if (xp->sc eq K_STATIC)
						{
							if (static_init(xp))
							{
								next_gp(add_tseg());
								G.scope->b_locs +=
									loc_size(gp, xp, &G.scope->b_size,
												     &G.scope->b_regs);
							}
							loc_sym(xp);
						}
						elif (      (   xp->sc eq K_AUTO
							         or xp->sc eq K_REG
							    	)
							    and (   is_ass(cur->token)		/* 02'17 HR: v5.6 */
#if FOR_A
							    	 or (    cur->token eq IS
							    	 	 and G.lang eq 'a' )
#endif
							    	)
							 )
						{
/* A lot of rearrangement for local aggragate initialization
 ( Also to make the difference possible between ':=' vs '=' as in Algol 68) */
							short context = tp->token eq ROW	? FORLAINIT
																: FORLINIT;
#if FOR_A
							if (cur->token eq IS)
							{
								xp->cflgs.f.qc = 1;
								cur->token = ASS;
							}
#endif

							ap = npcur(); advnode();

							if (    (   is_aggreg(xp->type)
							         or xp->type->token eq ROW
								    )
								and (   cur->token eq BLOCK
								     or is_scon(cur)
								    )
							   )
								auto_init(xp, ap, a_init(xp), context);		/* put initializer aside as static */
							else
							{
								NP e1;
								if (cur->token eq BLOCK)		/* 11'11 HR Pure C compat */
								{
									fadvnode();
									e1 = assignx();
									eat(KCOLB);
								othw
									e1 = assignx();
									if (!e1) warnn(xp, "empty xpr");
								}

#if FOR_A
								if (!gpbase)
									new_gp(nil, LINIT);			/* 07'13 HR v4.15: gpbase might have been used and cleared */
#endif
								auto_init(xp, ap, e1, context);		/* scalar */
#if FOR_A
								if (xp->cflgs.f.qc)		/* only if NO code needed */
								{
									ap = ap->right;		/* HR: 03'15 */
									if (ap)				/* There may be errors */
									{
										G.scope->b_locs = slocs;		/* correction */
							 			G.scope->b_size = ssize;
										G.scope->b_regs = sregs;
										xp->token = ap->token;			/* adopt con */
										xp->size  = ap->size;
										xp->offset  = ap->val.i;
										freenode(gpbase);
										gpbase = nil;
									}
								}
								else
#endif
									if (G.prtab->level > 1)			/* not args */
										loc_advice(xp, gpbase);
							}
						othw
							warn_const(xp);
							if (G.prtab->level > 1)		/* not args */
							{
								G.scope->b_locs +=
									loc_size(gpbase, xp, &G.scope->b_size,
											    	     &G.scope->b_regs);
								loc_advice(xp, gpbase);
							}
							loc_sym(xp);
						}
					}
					out_gp();
				}
			}

			iscomma = cur->token eq COMMA;
			if (iscomma) fadvnode();
		} while (iscomma);
		eat(ENDS);
	}

	while (STACKALN & G.scope->b_size)	/* ATARI ST/TT until even */
		G.scope->b_size++;
	return rv;
}

global
bool is_ty_start(void)		/* tbv loc_decls() and casts */
{
	TP rv;

	if (is_tykw(cur))
		return true;

#if FOR_A
	if (G.lang eq 'a' and cur->token eq ARRAY)
		return true;
#endif

	if (cur->token eq ID)
	{
		rv = all_syms((TP)cur, 0);
		if (rv)
		{
			if (rv->sc eq K_TYPE)
				return true;
#if FOR_A
			if (    G.lang eq 'a'
				and	(   rv->token eq K_STRUCT
					 or rv->token eq K_UNION
					 or rv->token eq T_PROC
					)
				)
				return true;
#endif
		}
	}

	G.prtab->insc = 0;			/* no more inits */
	return false;
}

static
TP C_args(TP np)
{
	TP *listpp, head, xp;
	short parnr, sclass;
	bool iscomma, isvargl, declty;

	parnr = 1;

	np->tflgs.f.ans_args = 1;
	np->size = 0;
	np->aln  = 0;

	listpp = &np->list;

	do
	{
		iscomma = 0;
		isvargl = 0;

		sclass = 0;
		head = Declarer(false,  nil, &sclass, &declty);	/* sclass --> declarer (K&R all editions) */
		if ( ok_prh(sclass, head) eq 0)
			sclass = 0;

		xp = Declare(head, FUNC);		/* FUNC: for proc param ID not required */
		xp = dummy_id(xp, head, parnr);

		if ( ok_prx(xp, head) )
		{
#if USAGE
			xp->tflgs.f.isarg = 1;
#endif
			regvar_options(xp, sclass);
			arg_size(&np->size, xp);
			list_sym(listpp, xp);
			listpp = &xp->next;
			isvargl = xp->type->token eq T_VARGL;
			parnr++;
		}

		iscomma = cur->token eq COMMA;
		if (iscomma)
			fadvnode();
		if (isvargl)
			break;
	}
	while (iscomma);

	while (STACKALN & np->size)
		np->size++;

	return np->list;				/* for orthogonality in ty_follow */
}

static
TP opt_id(void)
{
	TP rv;

	if (cur->token eq ID)
	{
		rv = tpcur(); advnode();
		return rv;
	}
	else
		return nil;
}

/* called for args of old style function declaration or nil */
static
TP ty_args(void)
{
	TP rv, tail, new;

	rv = opt_id();
	if (rv eq nil)
		return nil;
	tail = rv;
	do
	{
		if (cur->token ne COMMA)
			return rv;
		fadvnode();
		new = opt_id();
		if (new eq nil)
		{
			errorn(cur, "[2]expect ID; got");
			return rv;
		}
		tail->next = new;
		tail = new;
	}od
}

#if FOR_A
/* 10'14 v5.2 */
static
void spur(TP np, short tok) { errorn(np, "spurious '%s'", graphic[tok]); }

/* 10'14 v5.2 */
/* [], ref & deref are 'type_makers' and hence already part of np */
global
TP B_follow(TP np)
{
	if (np)
	{
		switch(cur->token)
		{
		case STR:
			fadvnode();
			if (np->aflgs.f.ns)
				spur(np, STR);
			else
				np->aflgs.f.ns = 1;
			return np;
/*		case CAR:
			fadvnode();
			if (np->aflgs.f.np)
				spur(np, CAR);
			else
				np->aflgs.f.np = 1;
			return np;
		case FLO:
			fadvnode();
			if (np->aflgs.f.nf)
				spur(np, FLO);
			else
				np->aflgs.f.nf = 1;
			return np;
*/		}
	}

	return nil;
}
#endif

/* restricted version of opt_follow for 'declarator' */
/* allow null [] */
static
TP ty_follow(TP np)
{
	TP tp;

#if FOR_A
	if (G.lang eq 'a' and (tp = B_follow((TP)np)) ne nil)
		return tp;
	else
#endif
	{
		if (cur->token eq ARRAY)
		{
			NP e1;
			tp = tpcur(); advnode();
			e1 = questx();
			eat(YARRA);
			tp->next = np;
			tp->list = (TP)e1;			/* will disappear after confold_value() */
			return ty_follow(tp);
		}

		if (cur->token eq PAREN)		/* arglist or ANSI prototype or func declaration */
		{
			TP e1;

			tp = tpcur(); advnode();
#if 0	/* Certainly not a good idee, but I couldnt resist writing it down :-) */
							if (cur->token eq NERAP)	/* declaration of 'fun()' becomes 'fun(void)' */
							{
								TP head = basic_type(T_VOID, 5);
								e1 = dummy_id(head, head);
							}
							else
#endif
			if (is_ty_start())
				e1 = C_args(tp);		/* allow C_args of func to follow */
			else
			{
				e1 = ty_args();			/* old_args */
				tp->tflgs.f.old_args = 1;
			}
			eat(NERAP);
			tp->next = np;
			tp->list = e1;
			to_type(tp, T_PROC);		/* PAREN --> PROC */
			return ty_follow(tp);		/* returns its input if nothing follows */
		}
	}

	return np;
}

/* restricted version of primary for "declarator" */
static
TP ty_primary(void)
{
	TP e1;

	if (cur->token eq ID)
		e1 = tpcur(), advnode();
	else
#if FOR_A
	if (G.lang ne 'a' and cur->token eq PAREN)
#else
	if (cur->token eq PAREN)
#endif
	{
		fadvnode();
		e1 = declarator();
		eat(NERAP);
	}
	else
		e1 = nil;

	return ty_follow(e1);
}

static
TP decl_op(void)
{
	TP rv, cp;
	short n = 0, narg = 0;

	rv = tpcur(); advnode();		/* 'op' */

	if (cur->prec)
		n = 2;					/* is binary op */
	if (is_unop(cur->token))
		n += 1;					/* can be unary op */
	if (!n)
		errorn(cur, "[3]expect unary or binary operator; got");

	rv->offset = cur->token;	/* for later use */
	fadvnode();

	if (cur->token eq PAREN)
	{
		fadvnode();				/* skip PAREN */

		rv->list = C_args(rv);
		eat(NERAP);
	}

	if (n)
	{
		cp = rv->list;
		if (cp)
			narg++;
		while(cp->next) narg++, cp = cp->next;

		if (n eq 3)				/* binary that can be unary */
		{
			if (narg eq 0)
			{
				error("'operator' must have at least 1 arg");
				freeTn(rv);
				rv = nil;
			othw
				if (narg > 2)
				{
					error("'operator' cannot have > 2 args");
					freeTn(rv->list->next->next);
					rv->list->next->next = nil;
				}
			}
		othw			/* have either 1 or 2 args */
			if (n ne narg)
			{
				error("wrong number of arguments");
				freeTn(rv);
				rv = nil;
			}
		}
	}
	if (rv)
		name_to_str(rv, graphic[rv->offset]);		/* for oplook */

	return rv;
}

static
TP decl_cast(void)
{
	TP rv, cp;
	short n = 0;

	rv = tpcur(); advnode();		/* 'cast' */

	if (cur->token eq PAREN)
	{
		fadvnode();				/* skip PAREN */

		rv->list = C_args(rv);
		eat(NERAP);
	}
	cp = rv->list;
	if (cp)
		n++;
	while(cp->next) n++, cp = cp->next;

	if (rv->token eq K_CAST and n ne 1)
	{
		error("'unary cast' must have 1 arg");
		freeTn(rv);
	}

	return rv;
}

static
void warn_func_modifier(TP e1, short k)
{
	Cstr s = *graphic[T_PROC] ? graphic[T_PROC] : "function";
	if (e1)
		warnn(e1, "%s on non-%s", graphic[k], s);
	else
		warn("%s on non-%s", graphic[k], s);
}

static
NP check_syscall(NP np)
{
	NP e1 = np;

	if (np)
	{
		form_types(np, FORSIDE,0);		/* constant & enum folding */
		if (np->token eq ICON)			/* (n) */
			if (np->val.i < 0 or np->val.i > 15)
				e1 = nil;
			else
				return e1;
		elif (np->token ne COMMA)			/* (n,m) */
			e1 = nil;
		elif (np->left->token ne ICON or np->right->token ne ICON)
			e1 = nil;
		elif (np->left->val.i < 0 or np->left->val.i > 15)
			e1 = nil;
	}

	if (e1 eq nil)
	{
		error("invalid %s", graphic[K_SYSC]);
		freenode(np);
	}
	return e1;
}

/* restricted version of unary for declarations or coercions */
/* allows nil primary part */
static
TP declarator(void)
{
	short qual;
	TP tp = nil, e1, kp;
	NP e2;

#if FOR_A
	if (G.lang ne 'a')
#endif
		switch (cur->token)
		{
		case DECLREF:						/* token for pointer in declarations */
			tp = tpcur(); advnode();
			to_type(tp, REFTO);
			qual = qualifier();
			tp->next = declarator();
			pick_qual(tp, qual);
			return tp;

#if FOR_A
		case DECLDEREF:
			tp = tpcur(); advnode();
			to_type(tp, REFTO);
			qual = qualifier();
			tp->aflgs.f.deref = 1;			/* used by see_id */
			tp->next = declarator();
			pick_qual(tp, qual);
			return tp;
#endif
		}


	if (cur->cat0 & PMOD)		/* cdecl, pascal, __asm__, __syscall__, etc. */
	{
		short tok = cur->token;
		fadvnode();
		switch (tok)
		{
		case K_CDECL:
			e1 = declarator();
			kp = yields_ty(e1, T_PROC);
			if (kp)
				kp->xflgs.f.cdec = 1;
			else
				warn_func_modifier(e1, tok);
			return e1;
		case K_PAS:
			e1 = declarator();
			kp = yields_ty(e1, T_PROC);
			if (kp)
			{
				kp->xflgs.f.cdec = 1;	/* pascal implies cdecl !! */
				kp->xflgs.f.pasc = 1;	/* 09'19 HR: v6 correct pascal behaviour */
			}
			else
				warn_func_modifier(e1, tok);

			return e1;
#if BIP_ASM
		case K_ASM:
			e1 = declarator();
			kp = yields_ty(e1, T_PROC);
			if (kp)
				kp->tflgs.f.asm_func = 1;
			else
				warn_func_modifier(e1, tok);
			return e1;
#endif
		case K_SYSC:				/* __syscall__ (currentlly used for generating trap instruction) */
			e2 = get_expr();
			e2 = check_syscall(e2);
			e1 = declarator();
			if (e1 eq nil or (e1 and e1->token ne T_PROC))
				warn_func_modifier(e1, tok);
			elif (e2)
			{
				if (e2->token eq ICON)
					e1->fld.offset = e2->val.i,
					e1->lbl  = -1;
				else
					e1->fld.offset = e2->left ->val.i,
					e1->lbl  = e2->right->val.i;
				e1->xflgs.f.sysc = 1;
				freenode(e2);
			}


			return e1;
		}
	}

	switch (cur->token)
	{
	case K_OP:
		e1 = decl_op();
		e1->next = declarator();
		return e1;
	case K_CAST:
		e1 = decl_cast();
		e1->next = declarator();
		return e1;
	case PAREN:					/* The (*fun)() is a pain in the ass */
	{
		bool is_cdecl = false;
		tp = tpcur(); advnode();
		if (cur->token eq K_CDECL)
		{
			is_cdecl = true;
			fadvnode();
		}
		e1 = declarator();
		eat(NERAP);
		if (e1 eq nil)
			/* left and right already nil */
			e1 = ty_follow(tp);
		else
		{
			freeTunit(tp);
			e1 = ty_follow(e1);
		}
		if (is_cdecl)
		{
			kp = yields_ty(e1, T_PROC);
			if (kp)
				kp->xflgs.f.cdec = 1;
			else
				warn_func_modifier(e1, K_CDECL);
		}
		return e1;
	}
	default:
		return ty_primary();
	}
}
