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
 *	md.c
 *
 *	Machine dependant parts & expression tree transformations.
 *	Also type checking subroutines.
 */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "param.h"

#include "body.h"
#include "decl.h"
#include "d2.h"
#include "expr.h"
#include "e2.h"
#include "md.h"

#define debugM (G.xflags['m'-'a'])
#define debugC (G.xflags['c'-'a'])		/* casting */
#define debugE (G.xflags['e'-'a'])		/* extracode */
#define debug_x (G.yflags['x' - 'a'])

#define ERRCONST warn
#define isfield(np) ((np)->token eq SELECTOR and (np)->fld.width)

global
void strsncpy(char *d, Cstr s, size_t l);

global
char ml[128], mr[128];

static
short maxt(short tok1, short tok2)
{
#if C_DEBUG
	if (!is_C(tok1) or !is_C(tok2))	/* errors ? */
	{
		error("CE: !is_C %d|%d\n", tok1, tok2);
		return G.Coldfire ? T_LONG : T_INT;
	}
#endif
	if (tok1  > tok2)
		return tok1;
	return tok2;
}

static
void cat_qual(char *s, TP tp)
{
	if (tp->cflgs.f.qc)			/* qualifiers */
		strcat(s, "const ");
	if (tp->cflgs.f.qv)
		strcat(s, "volatile ");
}

global
Cstr prdeclarer(TP tp)
{
#if PRFU
	TP pr = nil;
#endif
	static MAX_str s;		/* N.B. niet dus meer dan 1 keer in EEN printf gebruiken */

	s[0] = 0;

	while (tp)
	{
		cat_qual(s, tp);
		if (tp->name)
		{
#if C_DEBUG
			sprintf(s + strlen(s), "%s::%s ", ptok(tp->token), tp->name);
#else
			strcat(s, tp->name);

			if (tp->type)
				strcat(s, " ");
#endif
#if PRFU
			if (tp->token eq T_PROC)
				pr = tp;
#endif

		othw
			strcat(s, "? ");
		}
		tp = tp->type;
	}
#if PRFU
		if (pr)
			sprintf(s + strlen(s), " (%s parameter list)", pr->list ? "with" : " NO ");
#endif

	return s;
}

static
void cpmm(TP lp, TP rp)
{
	strsncpy(ml, prdeclarer(lp), sizeof ml);
	strsncpy(mr, prdeclarer(rp), sizeof mr);
}

global
short chkmm(void)
{
	if (strlen(ml) ne sizeof ml -1) return 1;
	if (strlen(mr) ne sizeof mr -1) return 2;
	return 0; /* in advnode */
}

global
void spmm(void)
{
	memset(ml, ' ', sizeof ml);
	memset(mr, ' ', sizeof mr);
	ml[sizeof ml - 1] = 0;
	mr[sizeof mr - 1] = 0;
}

static
short adjtab[] = {
	T_INT,		/* 0000 none */
	T_SHORT,	/* 0001 short */
	T_LONG,		/* 0010 long */
	T_LONG,		/* 0011 long short is long int in 16 bits */
	0,			/* 0100 */
	0,			/* 0101 */
#if LL
	T_LLONG,	/* 0110 long long */
#else
	0,
#endif
	0,			/* 0111 */
	T_UINT,		/* 1000 unsigned */
	T_USHORT,	/* 1001 unsigned short */
	T_ULONG,	/* 1010 unsigned long */
	T_ULONG,	/* 1011 unsigned long short is unsigned long int in 32 bits */
	0,			/* 1100 */
	0,			/* 1101 */
	0,			/* 1110 */
	0			/* 1111 */
};

#define ADJMASK 0x0f

global
short plain_type(short type)		/* No modifiers */
{
	short rv = type;

	switch (type)
	{
	case K_VARGL:
		rv = T_VARGL;
	break;
	case K_CHAR:
		rv = T_CHAR;
	break;
#if FLOAT
	case K_FLOAT:
		rv = T_FLOAT;
	break;
	case K_REAL:
		rv = T_REAL;
	break;
# if FOR_A
	case K_COMPL:
		rv = T_COMPL;
	break;
# endif
#endif
	case K_INT:
		rv = T_INT;
	break;
	case K_VOID:
		rv = T_VOID;
	break;
	case K_BOOL:
		rv = T_BOOL;
	break;
#if FOR_A
	case K_STRING:			/* 10'14 v5.2 */
		rv = T_STRING;
	break;
#endif
	}

	return rv;
}

global
short modify_type(short type, short modifier)
/* Only called if type OR adj are non zero */
{
	short rv = type;

	switch (type)
	{
	case T_VOID:
	case T_BOOL:
	case T_VARGL:
#if FOR_A
	case T_STRING:		/* 10'14 v5.2 */
# if FLOAT
	case T_COMPL:
# endif
#endif
	break;
#if FLOAT
	case T_FLOAT:
		if (modifier & (SAW_LONG|SAW_DOUBLE) )
			return T_REAL;
	break;
	case K_REAL:
		if (modifier & (SAW_SHORT|SAW_SINGLE) )
			return T_FLOAT;
/* in case 'double' only, no 'float|real' see also declarer().
 * We don't want to cater for this in basic_type() because basic_type is too basic,
 * and it must still work for internal FCON/RCON's if the compiler uses
 * the fpu or has extended precision software
 * (pe Turbo C or the new Sozobon on the TT030 without option -8).
 */
	break;
#endif
	case T_CHAR:
		if (modifier & SAW_UNS)
			return T_UCHAR;
		if (modifier & SAW_SIGNED)
			return T_CHAR;

		if (G.k_char_is_unsigned )		/* opt -K */
			return T_UCHAR;				/* default char is unsigned */
	break;
	case T_INT:
		rv = adjtab[modifier & ADJMASK];
		if (rv)
			return rv;
	break;
	/* These must be included, because they can pop up out of typedef's */
	case T_SHORT:
		rv = adjtab[(modifier&(SAW_UNS|SAW_LONG))|SAW_SHORT];
		if (rv)
			return rv;
	break;
	case T_LONG:
		rv = adjtab[(modifier&(SAW_UNS|SAW_SHORT|SAW_2LONG))|SAW_LONG];
		if (rv)
			return rv;
	break;
	}

	if (modifier)							/* what's left is NOT modifiable */
#if C_DEBUG
		errorn(cur, "bad type"
				    " modifier to %s for ", ptok(type));	/* test catanation */
#else
		errorn(cur, "bad type modifier for ");
#endif
	return rv;
}

static
bool islongv(long l)
{
#if 0			/*  just like the old SOZOBON */
#define	HIBITS	0xffff0000L
	if ((l & HIBITS) == 0)		/* upper 16 bits zero */
		return false;

	if ((l & HIBITS) == HIBITS) {	/* upper bits all on */
		if (l & 0x8000L)
			return false;	/* upper bits aren't significant */
		else
			return true;
	}
	return true;
#else
	return (l > 32768 or l <= -32768);
#endif
}

static
bool isintv(long i)
{
	return (i > 128 or i <= -128);
}

/* given ICON value, and flags see_l, see_u
	determine final type */
global
short icon_ty(NP tp)
{
	short islong, isuns;
	long val = tp->val.i;

	islong = tp->eflgs.f.see_l;
	isuns  = tp->eflgs.f.see_u;

	if (islong and isuns)
		return T_ULONG;

	if (islong or islongv(val))
		if (isuns)
			return T_ULONG;
		else
			return T_LONG;

	if (isintv(val))
		if (isuns)
			return T_UINT;
		else
			return T_INT;

	if (isuns)
		return T_UCHAR;
	else
		return T_CHAR;
}


typedef bool ALC_X(ALREG *rp, TP xp, char *up);

/* high to low */
/* + low to high for ARGREGS */

static
ALC_X al_areg
{
	if (up)
		if (rp->a < MAXA)
			return *up = rp->a++ + AREG, true;
		else ;					/* geen fi in C */
	else
		if (rp->a > MAXA)
			return xp->rno = --rp->a + AREG, true;

	return false;
}

#if FLOAT
static
ALC_X al_freg
{
	if (up)
		if (rp->f < MAXF)
			return *up = rp->f++ + FREG, true;
		else ;
	else
		if (rp->f > MAXF)
			return xp->rno = --rp->f + FREG, true;

	return false;
}
#endif

static
ALC_X al_dreg
{
	if (up)
		if (rp->d < MAXD)
			return *up = rp->d++ + DREG, true;
		else ;
	else
		if (rp->d > MAXD)
			return xp->rno = --rp->d + DREG, true;

	return false;
}

global
bool lc_reg(ALREG *rp, TP xp, char *up)
{
	TP tp = xp->type;

	switch (tp->token)
	{
	case REFTO:
		if (tp->type and tp->type->token eq T_VARGL)
			return false;
		return al_areg(rp, xp, up);
	case T_CHAR:
	case T_UCHAR:
	case T_INT:
	case T_UINT:
#if FOR_A
	case T_DEF:
#endif
	case T_SHORT:
	case T_USHORT:
	case T_BOOL:
	case T_LONG:
	case T_ULONG:
		return al_dreg(rp, xp, up);
#if FLOAT
	case T_FLOAT:
		if (G.use_FPU)
			return al_freg(rp, xp, up);
		else
			return al_dreg(rp, xp, up);
	case T_REAL:
		if (G.use_FPU)
			return al_freg(rp, xp, up);
#endif
	default:
		if (tp->tflgs.f.pu or can_pu(xp))		/* 10'13 v5.0 HR */
		{
			tp->tflgs.f.pu = 1;
			return al_areg(rp, xp, up);
		}

		return false;
	}
}

global
void add_argbase(TP tp, TP tm, long base)		/* base for local procs */
{
	if (
#if FLOAT
          (    !G.use_FPU
	       and tm->token eq T_REAL
	      )
		or
#endif
		   is_aggreg(tm)
	   )
		base += SIZE_P;	/* make room for pointer to return location */

	while (tp)
		tp->offset += base, tp = tp->next;
}

global
long arg_align(long sz, TP np)
{
	np->offset = 0;

	switch (np->type->token)
	{
	case ROW:
		CE_N(np, "array arg ");
		return SIZE_P;
	case T_CHAR:			/* 1 byte on the stack must start at */
	case T_UCHAR:			/* the odd address */
		np->offset = SIZE_I - SIZE_C;
		return SIZE_I;
#if SIZE_I ne SIZE_S
	case T_SHORT:
	case T_USHORT:
		np->offset = SIZE_I - SIZE_S;
		return SIZE_I;
#endif
	default:
		if (sz & 1)					/* 3'91 v1.2 */
			sz++;
		return sz;
	}
}

global
bool mustlval(NP np)
{
	if is_sreg(np)					/* 12'11 HR */
	{
		np->eflgs.f.l_ass = 1;
		return true;
	}

	switch (np->token)
	{
	case ID:
	case DEREF:
	case SELECTOR:
		break;
	case EXPCNV:			/* allow casting */
	case IMPCNV:
	case ARGCNV:
		return mustlval(np->left);
	default:
#if C_DEBUG
		errorn(np, "not lvalue: %s", ptok(np->token) );
#else
		errorn(np, "not lvalue");
#endif
		return true;
	}
	return false;
}

global
bool is_CC(void *vp)
{
	NP np = vp;
	TP tp = vp;

	short ty;
	switch(np->nt)
	{
		case TLNODE: ty = tp->ty;       break;
		case EXNODE: ty = np->type->ty; break;
		case GENODE: ty = np->ty;       break;
		default:     ty = np->ty;
	}

#if FLOAT
	return (ty >= ET_CC and ty <= ET_XC);
#else
	return ty eq ET_CC;
#endif
}

static
void not_allowed(NP np, short w)
{
	errorn(np, "<%s> not allowed (%d)", graphic[np->type->token], w);
}

global
bool mustty(NP np, short flags, short w)		/* returns true if failure */
{
	short tok = np->type->token;

	switch (tok)
	{
	case REFTO:
		if (flags & R_POINTER)
			return false;
		not_allowed(np, w);
		return true;
	case K_STRUCT:
	case K_UNION:
	case ROW:				/* init local array */
		if (flags & R_STRUCT)
			return false;
		not_allowed(np, w);
		return true;
#if FOR_A				/* arithmitic by external functions (ahcc_rt.h) */
	case T_STRING:		/* 10'14 v5.2 */
		return false;
# if FLOAT
	case T_COMPL:
		return false;
# endif
#endif
	case T_CHAR:
	case T_SHORT:
	case T_USHORT:
	case T_INT:
	case T_UINT:
#if FOR_A
	case T_DEF:
#endif
	case T_LONG:
	case T_UCHAR:
	case T_ULONG:
#if LL
	case T_LLONG:
#endif
		if (flags & R_BIN)
			return false;
		not_allowed(np, w);
		return true;
#if FLOAT
	case T_FLOAT:
	case T_REAL:
		if (flags & R_FLOATING)
			return false;
		not_allowed(np, w);
		return true;
#endif
	case T_VOID:
		not_allowed(np, w);
		return true;
	case T_VARGL:
		not_allowed(np, w);
		return true;
	case T_BOOL:
#if FOR_A
		if (G.lang eq 'a')
		{
			if (flags & R_CC)				/* true boolean */
				return false;
			not_allowed(np, wm);
			return true;
		}
#endif
		return false;
	case T_PROC:
		return true;
	default:
#if C_DEBUG
		CE_NX(np, "mustty wrong token %s", ptok(tok));
		printnode(np, 0);
		printnode(np->type, 0);
#else
		CE_NX(np, "mustty wrong token: %d", tok);
#endif
		return true;
	}
}

global
bool must2ty(NP np, short flags)
{
	return mustty(np->left,flags,-2) or mustty(np->right, flags, -1);
}

static
void mustzero(NP np)
{
	if (!((   np->token eq ICON and np->val.i eq 0)
#if FOR_A
	       or np->token eq K_NIL
#endif
	     )
	    )
		errorn(np, "only zero allowed with pointer");
}

static
bool mayzero(NP np)
{
	if (np->token eq ICON and np->val.i eq 0)
		return true;
	return false;
}

global
short widen(short ty)
{
	switch (ty)
	{
	case T_CHAR:
		return T_INT;
	case T_UCHAR:
		return T_UINT;
	case T_SHORT:
		return T_INT;
#if FOR_A
	case T_DEF:
		return T_INT;
#endif
	case T_USHORT:
		return T_UINT;
	default:
		return ty;
	}
}

/* only applicable to ICONS */
global
short narrow(TP tp, short to)
{
	short tok = tp->token;

	switch (tok)
	{
		case T_LONG:
		case T_INT:
#if FOR_A
		case T_DEF:
#endif
		case T_SHORT:
			tok = to eq DOT_B ? T_CHAR : T_INT;
		break;
		case T_ULONG:
		case T_UINT:
		case T_USHORT:
			tok = to eq DOT_B ? T_UCHAR : T_UINT;
		break;
	}

	return tok;
}

global
short lwiden(short ty)
{
	switch (ty)
	{
		case T_CHAR:
		case T_INT:
		case T_SHORT:
#if FOR_A
		case T_DEF:
#endif
			return T_LONG;
		case T_UCHAR:
		case T_UINT:
		case T_USHORT:
			return T_ULONG;
		default:
			return ty;
	}
}

static
short to_unsigned(NP tp)
{
	switch (tp->token)
	{
		case T_CHAR:
			return T_UCHAR;
		case T_INT:
#if FOR_A
		case T_DEF:
#endif
			return T_UINT;
		case T_SHORT:
			return T_USHORT;
		case T_LONG:
			return T_ULONG;
	}
	return tp->token;
}

global
TP functy(TP np)
{
	short lt = np->type->token;

	if (lt ne T_VOID)
		mustty((NP)np, R_ASSN,23);
	switch (lt)
	{
	case REFTO:
	case K_STRUCT:
	case K_UNION:
#if FOR_A
	case T_STRING:		/* 10'14 v5.2 */
# if FLOAT
	case T_COMPL:
# endif
#endif
		return np->type;
	}

	return basic_type(lt, 75);
}

global
TP shiftty(NP np, short ty)		/* shifts minimal 2 bytes (Pure C compatability) */
{
	TP tp;
	/* already checked types are R_ARITH */
	tp = basic_type(
			     maxt (widen(np->left ->type->token),
				       widen(np->right->type->token)), 76);
#if COLDFIRE
	if (ty and tp->size < SIZE_L)
	{
		tp = basic_type(lwiden(tp->token), 77);
		np->eflgs.f.cfl = 1;
	}
	else
		np->eflgs.f.cfl = np->left->eflgs.f.cfl | np->right->eflgs.f.cfl;		/* inherit */
#endif
	return tp;
}

/* only called for binary ops */
global
TP normalty(NP np, short ty)
{
	/* already checked types are R_ARITH */
	TP tp;
	NP lp = np->left,
	   rp = np->right;

#if 0				/* seems OK, but makes AHCC incompatable to HCC and Pure C in some cases. */
	/* Never cast a var to the width of a constant */
	if (    rp->token eq ICON and lp->token ne ICON
		and rp->type->size > lp->type->size
	   )
	{
		tp = lp->type;
		rp->type = basic_type(narrow(rp->type,lp->type->size), 78);
	}
	else
#endif
		tp = basic_type( maxt (lp->type->token,
						       rp->type->token), 79);

#if COLDFIRE
	if (ty and tp->size < SIZE_L)
	{
		tp = basic_type(lwiden(tp->token), 80);
		np->eflgs.f.cfl = 1;
	}
	else
		np->eflgs.f.cfl = np->left->eflgs.f.cfl | np->right->eflgs.f.cfl;		/* inherit */
#endif

	if (is_CC(tp))
		tp = basic_type(T_BOOL, 81);	/* ty ET_B */

	return tp;
}

global
TP bitsty(NP np, short ty)
{
	/* already checked types are R_ARITH */
	TP tp;
	NP lp = np->left,
	   rp = np->right;

	tp = basic_type( maxt (lp->type->token,
					       rp->type->token), 82);
#if COLDFIRE
	if (ty and tp->size < SIZE_L)
	{
		if (!is_con(lp->token) and !is_con(rp->token))
			tp = basic_type(lwiden(tp->token), 83);

		tp = basic_type(to_unsigned((NP)tp), 84);
		np->eflgs.f.cfl = 1;
	}
	else
		np->eflgs.f.cfl = np->left->eflgs.f.cfl | np->right->eflgs.f.cfl;		/* inherit */
#endif
	return tp;
}

global
bool const_check(NP np, short context)
{
	if (np)
	{
		NP lp = np->left;
		if (lp)
		{
			TP tp = lp->type;
			if (tp)
			{
				if (context eq FORLINIT or context eq FORLAINIT)
					return true;			/* checked */
				if (   lp->cflgs.f.qc		/* const object */
				    or tp->cflgs.f.qc		/* const type */
				   )
					ERRCONST("cannot modify a constant object");
			}
		}
	}
	return false;
}

static
bool sign_only(TP ltp, TP rtp, Cstr *bas)
{
	if (is_basic(ltp) and is_basic(rtp))
	{
		short rt = rtp->token;
		switch (ltp->token)
		{
		case T_CHAR:	*bas = graphic[K_CHAR ]; return rt eq T_UCHAR;
		case T_UCHAR:	*bas = graphic[K_CHAR ]; return rt eq T_CHAR;
		case T_SHORT:	*bas = graphic[K_SHORT]; return rt eq T_USHORT;
		case T_USHORT:	*bas = graphic[K_SHORT]; return rt eq T_SHORT;
#if FOR_A
		case T_DEF:
#endif
		case T_INT: 	*bas = graphic[K_INT  ]; return rt eq T_UINT;
		case T_UINT: 	*bas = graphic[K_INT  ]; return rt eq T_INT;
		case T_LONG:	*bas = graphic[K_LONG ]; return rt eq T_ULONG;
		case T_ULONG:	*bas = graphic[K_LONG ]; return rt eq T_LONG;
		}
	}

	return false;
}

static
bool isinit(short context)
{
	switch (context)
	{
		case FORINIT:
		case FORLINIT:
		case FORLAINIT:
		case FORPUSH:
			return true;
	}
	return false;
}

global
void asn_check(TP ltp, NP rp, short context)
{
	short reason;
	bool sim_context = isinit(context);
	TP rtp = rp->type;

	if (rtp->token eq T_VOID)
	{
		error(context eq FORPUSH ? "push of " : "assign of %s", graphic[rtp->token]);
		return;
	}

	if (ltp)

	switch (ltp->token)
	{
	case K_STRUCT:
	case K_UNION:
#if FOR_A && FLOAT
	case T_COMPL:
#endif
	case ROW:				/* init local array */
		reason = similar_type(0,0,ltp, rtp, 0, sim_context);
		if (reason)
		{
			cpmm(ltp, rtp);
			warnn(rp, "%s types mismatch\n\t<%s> :=\n\t<%s>", graphic[ltp->token], ml, mr);
		}
		elif (ltp->token eq ROW and context ne FORLAINIT)
			errorn(rp, "C does not support array assign");
		return;
	case REFTO:
		if (mayzero(rp))
			return;
		if (!ltp->type)		/* 05'13 HR: v4.15 */
			return;
		if (ltp->type->token eq T_VOID)
			return;
		if (rtp->token eq REFTO and rtp->type->token eq T_VOID)
			return;
		if (mustty(rp, R_POINTER,24))
			return;
		if (rtp->token eq REFTO)
			reason = similar_type(0,1,ltp->type, rtp->type, 0, sim_context);		/* 11'13 HR v5 */
		else
			reason = similar_type(0,1,ltp,       rtp,       0, sim_context);

		if (reason)
		{
			char *basic;
			if (sign_only(ltp->type, rtp->type, &basic))
			{
				cpmm(ltp, rtp);
				warnn(rp, "[%d]mixing pointers to signed and unsigned <%s>\n\t<%s> :=\n\t%s",
					reason, basic, ml, mr);
			othw
				cpmm(ltp, rtp);
				warnn(rp, "[%d]pointer types mismatch\n\t<%s> :=\n\t<%s>", reason, ml, mr);
			}
		}
		return;
	default:
		if (mustty(rp, R_BIN|R_ARITH,25))
			return;
	}
}

global
void chkcmp(NP np)
{
	short reason, lt, rt;
	NP lp  = np->left, rp  = np->right;
	TP ltp = lp->type, rtp = rp->type;

	lt = ltp->token;
	lt = (lt eq REFTO);
	rt = rtp->token;
	rt = (rt eq REFTO);
	if (lt and rt)
	{							/* ptr cmp ptr */
		if (ltp->type->token eq T_VOID or rtp->type->token eq T_VOID)
			return;
		reason = similar_type(0,0,ltp, rtp, 0, 1);
		if (reason)
		{
			char *basic;
			if (sign_only(ltp->type, rtp->type, &basic))
			{
				warnn(rp, "[%d]compare pointers to signed and unsigned %s", reason, basic);
			othw
				cpmm(ltp, rtp);	/* can np */
				if (    ltp->type
				    and rtp->type
					and ltp->type->token eq T_PROC
					and rtp->type->token eq T_PROC
				   )
				   	warnn(rp, "[%d]compare different function pointers", reason);
				else
					warnn(rp, "[%d]compare different pointers; %s :: %s", reason, ml, mr);
			}
		}
	othw
		if (lt)				/* ptr  cmp intg */
			mustzero(rp);
		elif (rt)			/* intg cmp ptr */
			mustzero(lp);
	}						/* else both ARITH */
}

global
TP colonty(NP np)
{
	short reason, lt, rt;
	NP lp  = np->left, rp  = np->right;
	TP ltp = lp->type, rtp = rp->type;

	lt = ltp->token;
	lt = (lt eq REFTO);
	rt = rtp->token;
	rt = (rt eq REFTO);

	if (lt and rt)
	{							/* ptr : ptr */
		if (ltp->type->token eq T_VOID)
			return rtp;
		if (rtp->type->token eq T_VOID)
			return ltp;
		reason = similar_type(0,1,ltp, rtp, 0, 0);
		if (reason ne 0)
		{
			cpmm(ltp, rtp);
			warnn(rp, "'%s' different pointers; %s :: %s", graphic[X_ELSE], ml, mr);
		}
		return ltp;
	othw
		if (lt)
		{						/* ptr : intg */
			mustzero(rp);
			return ltp;
		othw
			if (rt)
			{
				mustzero(lp);
				return rtp;
			othw
				if (is_aggreg(ltp) or is_aggreg(rtp))
				{
					reason = similar_type(0,1,ltp, rtp, 0, 0);
					if (reason)
					{
						cpmm(ltp, rtp);
						errorn(rp, "'%s' different multiple types\n\t\t %s :: %s",
									graphic[X_ELSE], ml, mr);
					}
					return ltp;
				}
				else
					return normalty(np, 0);
			}
		}
	}
}

static
void pwiden(NP rp)		/* rp INTEGRAL, so its tptr is a resident node */
{
	if (rp->type->size eq 1)
	{
		rp->type = default_type(-1, 0);
		to_nct(rp);
	}
}

static
NP newpcon(long kon)
{
	NP kp = make_node(ICON, E_LEAF, kon, "ob_sz");

	kp->type = basic_type(icon_ty(kp), 85);
	to_nct(kp);
	pwiden(kp);					/* if its char make it least int */
	return kp;
}

#define MAXLOOK	8

/* 4'17 HR: v5.6 */
global
bool is2pow(long l)
{
	long i;
	short j;

	i = l;
	for (j = 1; j <= 31; j++)
		if (i eq (1L<<j))
			return true;

	return false;
}

/* 4'17 HR: v5.6 */
global
bool make2pow(long *val)
{
	long i;
	short j;
	long l = *val;

	if (l < 2 or l > (1L<<MAXLOOK))
		return false;
	i = l;
	for (j = 1; j <= MAXLOOK; j++)
		if (i eq (1L<<j))
		{
			*val = j;
			return true;
		}
	return false;
}

static
bool ins_mul(NP np, long kon)
{
	NP rp = np->right, mp, kp;

	if (kon eq 0)			/* 04'09 */
	{
		/* warnn(np->left, "unscalable pointer"); */
		return false;
	}
	if (kon eq 1)
		return false;

	if (rp->token eq ICON)
	{
		rp->val.i *= kon;			/* teeny tiny confold */
		pwiden(rp);
		return false;
	}

	mp = make_node(SCALE, E_BIN, 0, "p*");
	mp->type = np->right->type;		/* ptr + int !!! */
	to_nct(mp);
	pwiden(mp);
	kp = newpcon(kon);
	mp->right = kp;
	mp->left  = rp;
	np->right = mp;


#if COLDFIRE
	if (!(G.Coldfire and rp->type->size eq SIZE_I))
#endif
		if (make2pow(&kp->val.i))		/* changes e.val.i to power if true */
			mp->token = SHL;
	return true;
}

static
bool ins_div(NP np, long kon)
{
	NP tp, kp;

	if (kon eq 1)
	{
		np->type = basic_type(PTRDIFF_T, 86);
		return false;
	}

	kp = newpcon(kon);

	tp = for_old_copyone(np);
	tp->type = basic_type(PTRDIFF_T, 87);
	to_nct(tp);
	tp->token = MINUS;
	np->left = tp;
	np->right = kp;
	np->tt = E_BIN;
	name_to_str(np, "p/");

	np->token = DIV;

#if COLDFIRE
	if (!(G.Coldfire and tp->type->size eq SIZE_I))
#endif
		if (make2pow(&kp->val.i))		/* changes e.val.i to power if true */
			np->token = SHR;
	return true;
}

static
TP castindex(NP lp, NP rp, TP tp)
{
	if (lp->type->size > DOT_W)
		return lp->type;				/* already wide enough */

	cast_up(lp, tp, "Castli");
	cast_up(rp, tp, "Castri");

	return tp;
}

global
void castdefault(NP lp, NP rp, TP tp)
{
	cast_up(lp, tp, "Castl");
	cast_up(rp, tp, "Castr");
}

global
TP scalety(NP np)
{
	/* already checked types are R_SCALAR */
	/* op is INDEX or PLUS or MINUS or ASSIGN PLUS or ASSIGN MINUS */
	short reason, oop, op, lt, rt;
	NP lp, rp; TP tp, rtp;

	lp = np->left;
	rp = np->right;
	oop = np->token;
	op = oop;
	if (is_ass_op(op))
		op -= ASSIGN 0;
	lt = lp->type->token eq REFTO;
	rt = rp->type->token eq REFTO;

	if (lt and rt)
	{											/* ptr - ptr */
		reason = similar_type(0,0,lp->type, rp->type, 0, 0);
		if (oop ne MINUS or reason)
		{
			cpmm(lp->type, rp->type);
			errorn(rp, "bad:  %s %s %s", ml, graphic[oop&(TOKMASK)], mr);
			return lp->type;
		}

		if (ins_div(np, lp->type->type->size))
		{
			tp = np->left->type;
			castdefault(np->left, np->right, tp);
			np->type = tp;
			to_nct(np);
			if (np->token eq DIV)	/* not changed to shift */
			{
#if COLDFIRE
				if (G.Coldfire and !b_overload(np))
					cold_con(np, np->type);		/* 01'12 HR: Omission. See also after ins_mul */
#else
				b_overload(np);	/* extracodes: now we know left & right types for
						           external defined binary operators (e.g. ldiv) */
#endif
			}
		}
		/* else unit size 1; no divide needed */
		return np->type;
	}

	if (rt)			/* integral +-[ ptr : switch sides so integral is on right */
	{
		if (is_ass_op(oop) or op eq MINUS)
		{
			errorn(rp, "Illegal int %s pointer", graphic[oop&(TOKMASK)]);
			return default_type(-1, 0);
		}
		np->left = rp;
		np->right = lp;
		lp = rp;
		rp = np->right;
	}

	rtp = rp->type;

/* we must cast unsigned short to unsigned long
   because m68k mode (An,Xn) only knows signed Xn */
/* pointer add needs at least size 2
   (no extra casting to long is needed. Unless Coldfire) */

	if (rtp->ty eq ET_U and rtp->size eq DOT_W)
		Cast(rp, basic_type(T_ULONG, 88), IMPCNV, "Cast iuns");
	elif (rtp->size < DOT_W)
		Cast(rp, basic_type(T_SHORT, 89), IMPCNV, "cast ptr add");

	tp = lp->type;						/* type of pointer */
										/* ptr +-[ integral */
	mustty(rp, R_INTEGRAL,26);

	/* ins_mul includes typing of rp !!! */
	if (ins_mul(np, tp->type->size))		/* ptr +-[ (index*objectsize) */
	{
		rp  = np->right;
		rtp = castindex(rp->left, rp->right, default_type(-1, 0));
		rp->type = rtp;
		to_nct(rp);

		if (rp->token eq SCALE)
		{
		    if (    rp->left ->type->size eq DOT_W
		        and rp->right->type->size eq DOT_W
		       )
		    {
				/* multiply;  muls is DOT_W * DOT_W = DOT_L
				   Nota maxima Bene: this all is very machine dependent code.
					We do this only for pointer scaling.
					 The physics of pointers are extremely implementor defined */

		    	if (rp->type->size eq DOT_W)
		    		rp->type = basic_type(lwiden(rp->type->token), 90);

		    othw
		    	castdefault(rp->left,rp->right,rtp);
#if COLDFIRE
				if (G.Coldfire and !b_overload(rp))		/* 01'12 HR: only for Coldfire target */
					cold_con(rp, rtp);
#else
				b_overload(rp);	/* extracodes: now we know left & right types for
								   external defined binary operators (e.g. lmul) */
#endif
			}
		othw			/* LSHIFT */
			NP cp = rp->left;
	    	if (cp->type->size eq DOT_W)	/* 03'11 HR also long scaling with shifts */
	    	{
	    		Cast(cp, basic_type(lwiden(cp->type->token), 91), IMPCNV, "cast shift scale");
	    		rp->type = cp->type;
	    		to_nct(rp);
	    	}
		}
	othw
#if COLDFIRE
		if (G.Coldfire)
			castdefault(np->left, np->right, basic_type(T_LONG, 92));
		else
#endif
			tp = castindex(np->left, np->right, tp);

		np->type = tp;
		to_nct(np);
	}
	return tp;
}

global
bool is_zero(NP np)
{
	switch (np->token)
	{
		case ICON:
			return np->val.i eq 0;
#if FLOAT
		case FCON:
			return np->val.f eq 0.0;
		case RCON:
			return getrcon(np) eq 0.0;
#endif
#if LL
		case LCON:
		{
			__ll ll = getlcon(np);
			return ll.hi eq 0 and ll.lo eq 0;
		}
#endif
#if FOR_A
		case K_NIL:
			return true;
#endif
	}
	return false;
}

#if 0
static
void
i_exp(NP np, TP tp)
{
	long l;
	if (np->type->size < tp->size)
	{
		l = np->val.i;
		switch (np->type->size)
		{
		case 1:
			l = (char) l;
			break;
		case 2:
			l = (short) l;
			break;
		}
		np->val.i = l;
	}
}

static
void squish(NP np)
{
	short neg;
	TP tp = np->type;

	if (tp->ty eq ET_B)
	{
		if (np->val.i)
			np->val.i = true;		/* converge bool's */
		else
			np->val.i = false;
	othw
		neg = (tp->ty eq ET_S and np->val.i < 0);

		switch (tp->size)
		{
		case DOT_B:
			if (neg)
				np->val.i |= 0xffffff00L;
			else
				np->val.i &= 0xffL;
			break;
		case DOT_W:
			if (neg)
				np->val.i |= 0xffff0000L;
			else
				np->val.i &= 0xffffL;
			break;
		}
	}
}
#endif

static
void warn_sig(long val)
{
	warn("constant too wide (0x%lx)", val);
}

#define LUNS 2147483648.0		/* a very interesting number */

#if LL
static
double ll_to_double(__ll l)
{
	return l.lo;				/* preliminary!!!!! */
}
#endif

static
void check_hi(NP cp, TP ctp, TP ntp)
{
	if (ntp->size < ctp->size)
	{
		long hi;

#if LL
		if (ctp->size eq DOT_LL)
		{
			VP dp = cp->val.dbl;
			hi = dp->llval.hi;
		}
		else
#endif
			hi = cp->val.i;

		if (ntp->size eq DOT_B)
		{
			hi >>= 8;
			if (!(hi eq -1 or hi eq 0))
		   		warn_sig(cp->val.i);
		}
		elif (ntp->size eq DOT_W)
		{
			hi >>= 16;
		    if (!(hi eq -1 or hi eq 0))
				warn_sig(cp->val.i);
		}
		elif (ntp->size eq DOT_L)	/* if DOT_L is smaller, the other one must be DOT_LL :-) */
		{
			if (ctp->size eq DOT_LL)	/* internal integrity */
				if (hi ne -1 and hi ne 0)
					warn("long long constant too wide");
		}
	}
}

#if LL
static
void check_ll(NP cp, TP ctp, TP ntp)
{
	if (ntp->size < ctp->size and ctp->size eq DOT_LL)
	{
		VP dp = cp->val.dbl;
		cp->val.i = dp->llval.lo;
		if (ntp->ty eq ET_B)
			cp->val.i |= dp->llval.hi;
		cp->token = ICON;
		freeVn(dp);
	}
	elif (ctp->size < ntp->size and ntp->size eq DOT_LL)
	{
		__ll new;
		new.lo = cp->val.i;
		new.hi =  new.lo < 0 and ctp->ty eq ET_S ? -1 : 0;
		new_lnode(cp, new);
	}
}
#endif

#if FLOAT
static
void ll_to_real(NP cp, TP ctp, TP ntp)
{
	if (double_size(ntp))
	{
#if LL
		if (ctp->size eq SIZE_LL)
		{
			VP dp = cp->val.dbl;
			double d = ll_to_double(dp->llval);
			freeVn(dp);
			new_rnode(cp, d);
		}
		else
#endif
			new_rnode(cp, cp->val.i);
		cp->token = RCON;
	othw
		cp->val.f = cp->val.i;
		cp->token = FCON;
	}
}
#endif

static
void check_uhi(NP cp, TP ctp, TP ntp)
{
	if (ntp->ty eq ET_U)
		if (ntp->size < ctp->size)
		{
			unsigned long val = (unsigned long)cp->val.i;
			if (  (    ntp->size eq DOT_B
			       and (val > 255)
			      )
			   or (    ntp->size eq DOT_W
			       and (val > 65536)
			      )
			   )
				warn_sig(cp->val.i);
		}
}

#if FLOAT
static
void uns_to_real(NP cp, TP ctp, TP ntp)
{
	long uns = cp->val.i&0x7fffffffL;
	bool sign = cp->val.i < 0;
	if (double_size(ntp))
	{
		VP dp;
		new_rnode(cp, uns);
		cp->token = RCON;
		dp = cp->val.dbl;
		if (ctp->size eq sizeof(cp->val.i) and sign)
			dp->rval += LUNS;
	othw
		cp->val.f = uns;		/* may loose precision, but NOT sign and magnitude */
		cp->token = FCON;
		if (ctp->size eq sizeof(cp->val.i) and sign)
			cp->val.f += LUNS;
	}
}
#endif

static
void int_to_bool(NP cp)
{
	if (cp->val.i)
		cp->val.i = true;
	else
		cp->val.i = false;
}

/*
static
void check_rneg(NP cp, TP ctp)
{
	if (ctp->size eq DOT_L)			/* float */
		if (cp->val.f < 0)
			warn(wneg);
		else ;
	else
		if (getrcon(cp) < 0)
			warn(wneg);
}
*/

#if FLOAT
static
void real_to_int(NP cp, TP ctp)
{
	long i;
	if (ctp->size eq DOT_L)			/* float */
		i = cp->val.f;
	else
	{
		i = getrcon(cp);
		freeVn(cp->val.dbl);
	}
	cp->val.i = i;
	cp->token = ICON;
}

static
void real_to_real(NP cp, TP ctp, TP ntp)
{
	if (ctp->size < ntp->size)
	{
		new_rnode(cp, cp->val.f);
	othw
		float f = getrcon(cp);
		freeVn(cp->val.dbl);
		cp->val.f = f;
		cp->token = FCON;
	}
}
#endif

static
CON_CAST cast_s_s
{
	check_hi(cp, ctp, ntp);
#if LL
	check_ll(cp, ctp, ntp);
#endif
}
static
CON_CAST cast_s_u
{
#if LL
	check_ll(cp, ctp, ntp);
#endif
}

#if FLOAT
static
CON_CAST cast_s_r
{
	ll_to_real(cp, ctp, ntp);	/* for all int's */
}
#endif

static
CON_CAST cast_u_s		/* unsigned long long not yet */
{
	check_uhi(cp, ctp, ntp);
}

#if FLOAT
static
CON_CAST cast_u_r
{
	/* unsigned long must produce a positive real !!! */
	uns_to_real(cp, ctp, ntp);
}
static
CON_CAST cast_p_r
{
	warn("Cast pointer constant to real");
	uns_to_real(cp, ctp, ntp);
}
#endif

static
CON_CAST cast_p_i
{
	check_uhi(cp, ctp, ntp);
}
static
CON_CAST cast_p_u
{
	check_uhi(cp, ctp, ntp);
}

#if FLOAT
static
CON_CAST cast_r_r
{
	real_to_real(cp, ctp, ntp);
}
static
CON_CAST cast_r_u
{
/*	check_rneg(cp, ctp);	*/
	real_to_int(cp, ctp);
}
static
CON_CAST cast_r_i
{
	real_to_int(cp, ctp);
}
#endif


/* all these functions are called with at least ET_.. or size different */
#if FLOAT

#define ETS (ET_R-ET_B+1)

/*
static
CON_CAST cdisp
{
	console("cdisp\n");		/* no action (0L) */
}
*/

static
CON_CAST *cast_tab[ETS][ETS] =
{
	{
		0L,
		0L,
		0L,
		0L,
		cast_s_r
	},
	{
		cast_s_s,
		cast_s_s,
		cast_s_u,
		cast_s_u,
		cast_s_r
	},
	{
		cast_u_s,
		cast_u_s,
		cast_u_s,
		cast_u_s,
		cast_u_r
	},
	{
		cast_p_i,
		cast_p_i,
		cast_p_u,
		cast_p_u,
		cast_p_r
	},
	{
		cast_r_i,
		cast_r_i,
		cast_r_u,
		cast_r_u,
		cast_r_r
	}
};
#else

#define ETS (ET_P-ET_B+1)

static
CON_CAST *cast_tab[ETS][ETS] =
{
	{
		0L,
		0L,
		0L,
		0L,
	},
	{
		cast_s_s,
		cast_s_s,
		cast_s_u,
		cast_s_u,
	},
	{
		cast_u_s,
		cast_u_s,
		cast_u_s,
		cast_u_s,
	},
	{
		cast_p_i,
		cast_p_i,
		cast_p_u,
		cast_p_u,
	}
};
#endif


static
bool is_l_to_ref(TP ctp, TP ntp)
{
	if (ctp->token ne T_LONG)			return false;
	if (ntp->token ne REFTO )			return false;
	return true;
}
global
bool cast_con(NP cp, TP ntp, Cstr cn, short context)
{
	TP ctp = cp->type;
	short cpn = ctp->ty - ET_B,
	      npn = ntp->ty - ET_B;

/* ctp = current type;  ntp = new type */


	if (	cpn eq npn
		and ctp->size eq ntp->size)
		return true;

	if (cpn >= 0 and npn >= 0)			/* 01'12 HR: consistency */
	if (    cpn < ETS
	    and npn < ETS
	   )
	{
		if (cast_tab[cpn][npn])
		{
#if 0
			if (context > HIGHCONTEXT and !is_l_to_ref(ctp, ntp))
			{
				char t[32];
				sprintf(t,"%s", ptok(ntp->token));
				message("Cast_con[%s] %s to %s", cn, ptok(ctp->token), t);
			}
#endif
			cast_tab[cpn][npn](cp, ctp, ntp);
		}
#if FOR_A
		if (G.lang eq 'a' and ntp->ty eq ET_B)		/* Very likely to be incompatible otherwise */
			int_to_bool(cp);
#endif
		return true;
	}

	return false;
}

global
void Cast(NP np, TP tp, short cnv, Cstr cn)
{
	NP cp;

	if (np->type)		/* np is old type, tp is new type */
	{
		if ( is_con(np->token) and cast_con(np, tp, cn, 0) )
		{
			if (is_ct(np))
				freeTn(np->type);
			np->type = tp;				/* new type */
			to_nct(np);
			return;
		}

#if FLOAT
		if (    cnv eq IMPCNV
		    and is_hw_fp(tp->ty)
		    and is_hw_fp(np->type->ty)		/* 03'11 HR float <-> double */
		    and tp->size eq np->type->size	/* 03'11 HR        "         */
		    and np->type->ty ne ET_XC			/* cast ET_XC to ET_R */
		    and np->type->ty ne ET_FC			/* cast ET_FC to ET_R */
		   )
			return;

		/* h/w floating point is casted by h\w in normal expressions
				if from integral to real.
			For real to integral we need fintrz (as Pure C does). */
		/* however casting is still needed for function arguments
		   and cc setting fp operations (ET_XC) */
		/* 03'11 HR Also casting between float and double must be
		            done explicitely;	*/
#endif
	}
	cp = for_old_copyone(np);
	np->left = cp;

	np->token = cnv;
	np->tt = E_UNARY;
	name_to_str(np, cn);
	np->type = tp;
	to_nct(np);
	np->cflgs.f.rlop = 0;
	c_overload(np);		/* s/w dbl */
}

global
bool stronger(TP xp, TP  yp)
{
	return (   xp->size > yp->size
			or xp->ty   > yp->ty  );
}

/* right stronger with ET_S and ET_U/ET_P considered equal */
static
bool xstronger(TP rtp, TP  ltp)
{
	return (	rtp->size >  ltp->size
#if FLOAT
			or (rtp->ty   eq ET_R and ltp->ty ne ET_R)
#endif
		   );
}

global
void cast_up(NP np, TP tp, char *n)
{
	TP ntp;

	if (G.nmerrors)
		return;

	ntp = np->type;

	/* stronger(tp, np->type) */
	if (   tp->size >  ntp->size
		or tp->ty   >  ntp->ty
		)
		Cast(np, tp, IMPCNV, n);
}

global
void castasn(NP lp, NP rp)
{
	TP ltp, rtp;

	if (G.nmerrors)
		return;

	ltp = lp->type;
	rtp = rp->type;

	if (	rtp->size  ne ltp->size
		or	rtp->ty    ne ltp->ty
		)
		Cast(rp, ltp, IMPCNV, "Cast=");
}

/* 	For general consistancy I
		complete incomplete boolean expression.
	If members of 'AND', 'OR' and 'NOT' are not of a boolean type,
		(ET_CC, ET_FC or ET_XC), '!= 0' is generated.
	Algol68 fans will strongly agree with this.
	K&R should have defined a basic type 'bool'.
*/

global
void ins_zero(NP np)
{
#if FLOAT
	if (np->token eq RCON)
	{
		freeVn(np->val.dbl);
		np->val.dbl = nil;
	}
#endif
#if LL
	if (np->token eq LCON)
	{
		freeVn(np->val.dbl);
		np->val.dbl = nil;
	}
#endif
	np->token = ZERO;
	name_to_str(np, "right 0");
	np->type = basic_type(T_NTY, 93);	/* cons allways a basic type */
	to_nct(np);
}

global
void cmp_zero(NP np)		/* because there is no compare at all */
{
	NP rp, cp;
	TP tp = CC_type(np, nil);			/* makes ALLways a copy!! */

	rp = make_node(ZERO, E_LEAF, 0, nil);
	rp->type = basic_type(T_NTY, 94);	/* cons allways a basic type */
	to_nct(rp);

	cp = for_old_copyone(np);

	np->left  = cp;
	np->right = rp;
	np->tt = E_BIN;
	np->token = NOTEQ;
	name_to_str(np, "cmp 0");
	np->type = tp;
	not_nct(np);
}

/* N.B. np->type is, and stays bool  */

global
void cast_compare(NP np, NP lp, NP rp)
{
	TP ltp, rtp;

	if (G.nmerrors)
		return;

	ltp = lp->type;
	rtp = rp->type;

	/* Never cast a var to the width of a constant */
	if (rp->token eq ICON and lp->token ne ICON)
#if FLOAT
		if (ltp->ty eq ET_R)		/* 10'10 HR: cast ICON to RCON */
	    	Cast(rp, ltp, IMPCNV, "CastIR");
		else
#endif
		{
			rp->type = lp->type;
			rp->nflgs.f.n_ct = lp->nflgs.f.n_ct;	/* 05'12 HR: oooops (vergeet deze dingen NOOIT!! */
		}
	elif (stronger(rtp, ltp))
		Cast(lp, rtp, IMPCNV, "CastBl");
	elif (stronger(ltp, rtp))
		Cast(rp, ltp, IMPCNV, "CastBr");

	ltp = lp->type;
	rtp = rp->type;			/* you can only compare objects */

	if (is_CC(ltp))
		Cast(lp, basic_type(T_BOOL, 95), IMPCNV, "CastCl");

	if (is_CC(rtp))
		Cast(rp, basic_type(T_BOOL, 96), IMPCNV, "CastCr");
}

/* cast for:  *=  %=  /=  */
global
void castasop(NP lp, NP rp)
{
	if ( stronger(lp->type, rp->type ) )
		Cast(rp, lp->type, IMPCNV, "Castx=");
}

/* cast for: +=  -=  >>=  <<=  &=  ^=  |= */
global
void castasmagic(NP lp, NP rp)
{
	TP ltp = lp->type, rtp = rp->type;

	if (    stronger(ltp, rtp)		/* left stronger */
		or xstronger(rtp, ltp) )	/* right stronger with ET_S and ET_U considered equal */
		Cast(rp, ltp, IMPCNV, "CastX=");
}

static
TP oplook(TP head, NP np)
{
	TP pt = head;

	while(pt)
	{
		if (pt->type->token eq K_OP)
			if (pt->type->offset eq np->token)
				return pt;
		pt = pt->next;
	}
	return nil;
}

static
NP copy_id(TP ca)
{
	NP id = t_copyone_e(ca);		/* copy ID node */
	id->tt = E_LEAF;
	id->type = ca->type;	/* with complete type list */
	to_nct(id);
	return id;
}

global
TP yields_ty (TP mp, short typ)
{
	while(mp)
	{
		if ( mp->token eq typ ) break;
		mp = mp->type;
	}
	return mp;
}

static
void arg_asn(NP np, TP tl)
{
	NP rp = copyone(np);
	np->token = ASS;
	name_to_str(np, graphic[ASS]);
	np->left = t_copyone_e(tl);
	np->right = rp;
	np->tt = E_BINARY;
	/* types where already OK */
}

/*	recursive check replaced by iterative check	*/
global
#if FOR_A
bool arg_check(NP np, TP tl, bool loc)
#else
bool arg_check(NP np, TP tl)
#endif
{
	bool reason;
	TP tp;
	NP lp = np->left;
	if (!tl)
	{
		error("arg_check: compiler failure");
		return false;
	othw
		if ( yields_ty(tl, T_VARGL) )
			return false;
		tp = tl->type;
		asn_check(tp, lp, FORPUSH);
		reason = similar_type(0,1,lp->type, tp, 1, 0);
		if (reason)
		{
			if ( tp->token eq T_CHAR ) /* char --> int */
				tp = default_type(-1, 0);
			elif ( tp->token eq T_UCHAR)
				tp = basic_type(T_UINT, 97);
			Cast(lp, tp, ARGCNV, "arg_cast");
#if FOR_A
			if (loc)
				np->token = COMMA,		/* local procs: prevent pushing */
				arg_asn(lp, tl);
#endif
		}
		lp->eflgs.f.typed = 1;				/* mark typed argument */
		return true;
	}
}

static
TP castscan(TP tab, NP np)
{
	bool reason, reasonl;
	TP pt;

	for (pt = tab; pt ne nil; pt = pt->next)
		if (pt->type->token eq K_CAST)
		{
			TP tr = pt->type->list;	/* arg */
			reason  = similar_type(0,0,np->left->type, tr->type      , 1, 0);
			reasonl = similar_type(0,0,np      ->type, pt->type->type, 1, 0);
			if (	!reason		/* the 1 arg */
				and !reasonl	/* the return type.   ,1, ) = dont compare ID's */
				) return pt;
		}
	return nil;
}

static
TP uopscan(TP tab, NP np)
{
	TP rv = nil;

	while (tab and (rv = oplook(tab, np)) ne nil)
	{
		TP tr = rv->type->list;	/* first arg */
		if (	!tr->next			/* is unary op */
			and similar_type(0,0,np->left->type, tr->type, 1, 0) eq 0
			) break;
		rv = nil;
		tab = tab->next;
	}
	return rv;
}

static
TP bopscan(TP tab, NP np)
{
	TP rv = nil;

/* note that args in ->type form a list */
/* and members of an expression form a tree */

	while (tab and (rv = oplook(tab, np)) ne nil)
	{
		TP tr = rv->type->list;	/* first arg */

		if (	tr->next			/* is binary op */
			and similar_type(0,0,np->left ->type, tr->      type, 1, 0) eq 0
			and similar_type(0,0,np->right->type, tr->next->type, 1, 0)	eq 0 /* ,1) = dont compare ID's */
			) break;
		rv = nil;
		tab = tab->next;
	}
	return rv;
}

static
NP ins_cast(NP cp, TP ca)
{
	NP np = make_node(CALL, E_BIN, 0, "exbcast");	/* call */
	np->type = ca->type->type;			/* return type */
	to_nct(np);
	np->right = cp;						/* original becomes the 1 arg */
	np->left = copy_id(ca);				/* what's to be called */
	return np;
}

static
void ins_call(NP np, TP id, Cstr n)
{
	/* transform op|cast node to call (id is ID to be called) */

#if NODESTATS
		G.ncnt[np->nt]--;
		G.ncnt[EXNODE]++;
#endif
	np->nt = EXNODE;
	np->token = CALL;
	np->tt = E_BIN;
	np->sc = 0;
	np->size = 0;
	np->aln = 0;
	clr_flgs(np);
	name_to_str(np, n);
	if (is_ct(np))
		freeTn(np->type);
	np->type = id->type->type;	/* result type */
	to_nct(np);
	np->left = copy_id(id);	/* what's to be called */
}

static
void ins_pull(NP pl, TP tp, short r)
{
	NP pll;

	pll = make_node(PULLARG, E_LEAF, 0, "pl_a");
	pll->rno = r;
	pll->type = tp;
	to_nct(pll);

	if (pl->left)
	{
		pll->left = pl->left;
		pll->tt = E_UNARY;
	}

	pl->left = pll;
	pl->tt = E_BIN;
}

/* 04'14 v5.1 use a temp: callee xpr will almost surely clobber registers */
static
bool func_unfold(NP np)
{
	/* Only called when there are indeed arguments in regs */
	if (np->right and np->left and np->left->token eq DEREF)
	{
		NP lp = np->left->left;
		if (lp->token eq CALL)
			return true;
	}
	return false;
}

static
NP callee_unfold(NP np)
{
	TP tp = basic_type(REFTO, 999);
	NP asp = nil,
	   lap,
	    lp = np->left;

	if (lp)
	{
		tp->type = lp->type;
		to_nct(tp);

		lap = e_temp_var(tp);	/* puts a symbol in the symbol table and returns a expression node */
		/* construct assignment of callee xpr result to a temp */
		if (lap)
		{
			asp   = make_bin(ASS,   "assign to temp",   lap, lp->left);
			lp->left = copynode(lap);	/* np is the original CALL */
		}
	}
	return asp;
}

global
NP arg_regs(NP np)
{
	NP last = nil;

	if(!G.h_cdecl_calling)
	{
		if (
				np->right
		    and np->left->type->xflgs.f.cdec eq 0
		   )
		{
			short an = AREG,
			      dn = DREG;
#if FLOAT
			short fn = FREG;		/* reserve regs for args if !cdecl */
#endif

			NP args = np->right,
			   argtail = nil,
			   arghead = nil,
			   pll;
			TP tp;

			pll = copyone(np->right);
			pll->right = np->right;
			pll->tt = E_UNARY;
			pll->token = PULL;

			last = pll;

			while (args)		/* arglist */
			{
				if (args->eflgs.f.varg)		/* from match_args */
					break;

				tp = args->type;

				if (tp->ty eq ET_P)
				{
					if (an < ARV_START)
						args->rno = an,
						ins_pull(pll, tp, an++);
				}
#if FLOAT
				elif (tp->ty eq ET_R and G.use_FPU)
				{
					if (fn < FRV_START)
						args->rno = fn,
						ins_pull(pll, tp, fn++);
				}
#endif
				elif (   tp->ty eq ET_S
					  or tp->ty eq ET_U
					  or tp->ty eq ET_B
					  or tp->ty eq ET_CC
					 )
				{
					if (tp->size <= SIZE_L)		/* must fit in a reg */
						if (dn < DRV_START)
							args->rno = dn,
							ins_pull(pll, tp, dn++);
				}

				if (args->rno ne -1)		/* have argreg: isolate */
				{
					last->right = args->right;
					args->right = nil;
					if (arghead eq nil)
						arghead = args;
					if (argtail)
						argtail->right = args;
					argtail = args;
					args = last->right;
				othw
					last = args;
					args = args->right;
				}
			}

			/* put regs in front and adjust tt's */
			if (arghead)
			{
				argtail->right = pll->right;
				pll->right = arghead;

				args = arghead;
				while (args)
				{
					if (args->right)
						args->tt = E_BIN;
					else
						args->tt = E_UNARY;
					args = args->right;
				}
			}

			if (pll->left)		/* something done ? (eg any args in regs) */
			{
#if FUNF
				if (func_unfold(np))	/* 04'14 HR: v5.1 */
				{
					NP cxp = callee_unfold(np);
					pll->left = make_bin(FUNF, "callee between", cxp, pll->left);
				}
#endif
				np->right = pll;
			}
			else
				freeunit(pll);
		}
	}

	return last;
}

global
bool c_overload(NP np)
{
	TP rv = nil;
	SCP loc;

	for (loc = G.scope; loc ne nil; loc = loc->outer)
		if ((rv = castscan(loc->b_casts, np)) ne nil) break;

	if (!rv and G.casttab)
		rv = castscan(G.casttab, np);

	if (rv)
	{
		NP arg, lp = np->left;

		ins_call(np, rv, "__excast");		/* transform tconv to call */

		arg = make_node(ARG, E_UNARY, 1, nil);
		arg->type = lp->type;
		to_nct(arg);
		arg->left = lp;
		np->right = arg;
		arg_regs(np);
		return true;
	}

	return false;
}

global
bool u_overload(NP np)
{
	TP rv = nil;
	SCP loc;

	for (loc = G.scope; loc ne nil; loc = loc->outer)
		if ((rv = uopscan(loc->b_ops, np)) ne nil) break;

	if (!rv and G.optab)
		rv = uopscan(G.optab, np);

	if (rv)				/* transform unary expr node to call */
	{
		NP arg, lp = np->left;

		ins_call(np, rv, "__exun");

		arg = make_node(ARG, E_UNARY, 1, nil);
		arg->type = lp->type;
		to_nct(arg);
		arg->left = lp;
		np->right = arg;
		lp->eflgs.f.typed = 1;
		arg_regs(np);
		return true;
	}
	return false;
}

global
bool b_overload(NP np)
{
	TP rv = nil;
	SCP loc;
	short tok = np->token;

	if (tok eq COMMA)
		return false;			/* 02'18 HR. comma's should not be overloaded */

	if (tok eq SCALE)
		np->token = TIMES;						/* 11'09 HR: Ooooofffff Pffff! */

	for (loc = G.scope; loc ne nil; loc = loc->outer)
		if ((rv = bopscan(loc->b_ops, np)) ne nil) break;

	if (!rv and G.optab)
		rv = bopscan(G.optab, np);

	if (rv)				/* transform binary expr node to call */
	{
		NP arg, lp = np->left,
		        rp = np->right,
		   comma;

		ins_call(np, rv, "__exbin");
		comma = make_node(ARG, E_BIN, 2, "exbpars");
		np->right = comma;

		arg = make_node(ARG, 0, 1, nil);
		arg->left = rp;
		arg->type = lp->type;
		to_nct(arg);

		comma->right = arg;
		comma->left = lp;
		comma->type = comma->right->type;
		to_nct(comma);
		lp->eflgs.f.typed = 1;
		rp->eflgs.f.typed = 1;
		arg_regs(np);
		return true;
	}
	np->token = tok;
	return false;
}

static
NP newcon(long kon, TP tp)
{
	NP kp = allocnode(EXNODE);
#if FLOAT
	if (tp->ty eq ET_R)
	{
		if (tp->size eq SIZE_F)
		{
			kp->val.f = kon;
			kp->token = FCON;
		othw
			VP dp = allocVn(RLNODE);
			dp->rval = kon;
			kp->val.dbl = dp;
			kp->token = RCON;
		}
	}
	else
#endif
	{
		kp->val.i = kon;
		kp->token = ICON;
	}
	kp->tt = E_LEAF;
	kp->type = tp;
	to_nct(kp);
	return kp;
}

/*
 *	Transform hard ++,-- to equivalent trees
 *	(for us, floats or fields)
 *  or if Coldfire, byte or word
 */

static
bool must_unfold(NP np, TP tp)
{
	return
#if COLDFIRE
		(G.Coldfire ne 0 and tp->size < SIZE_L) or
#endif
#if FLOAT
		tp->ty eq ET_R or
#endif
#if LL
		tp->size > DOT_L or
#endif
		isfield(np->left);
}

global
bool incdec(NP np, TP tp, short newop)
{
	if (G.nmerrors)
		return false;

	/* correct object size, so multiplation not needed */
	np->val.i = (tp->token eq REFTO) ? tp->type->size : 1;

	if (must_unfold(np, tp))
	{
		NP onep = newcon(1L, tp);

		np->token = newop;	/* easy case, ++X becomes X+=1 */
		np->tt = E_BIN;
		np->right = onep;
		name_to_str(np, "incdec");
		binary_types(np, FORSIDE, 0);
		return true;
	}
	return false;
}

global
bool postincdec(NP np, TP tp, short asop, short newun, short newbin)
{
	if (G.nmerrors)
		return false;

	/* correct object size, so multiplation not needed */
	np->val.i = (tp->token eq REFTO) ? tp->type->size : 1;

	if (must_unfold(np, tp))
	{
		NP t1, onep, lp;

		onep = newcon(1L, tp), lp = np->left;
		t1 = copyone(np);		/* hard case, X++ becomes (++X - 1) */
		t1->left = lp;
		np->left = t1;
		np->right = onep;
		np->tt = E_BIN;
		np->token = newbin;
		name_to_str(np, graphic[newbin]);		/* for pe external_binary_op */
		t1->token = newun;
		t1->type = tp;
		to_nct(t1);
		name_to_str(t1, graphic[newun]);

		incdec(t1, tp, asop);			/* allways work from inside to outside in trees */

		binary_types(np, FORSIDE, 0);
		return true;
	}
	return false;
}

static
bool equivalent_field(NP lp, NP rp)
{
	int l = *(int *)&lp->fld;
	int r = *(int *)&rp->fld;
	return lp->size eq rp->size and l eq r;
}

/* HR 02'11: optimization for assign fields same offset width intsize */
global
void fieldas(NP np, NP lp)
{
	if (isfield(lp))
	{
		np->fld   = lp->fld;
		np->token = FIELDAS;
		lp->fld.width = 0;
	}
}

/*
 *	Transform hard op= trees to equivalent '=' trees
 *	(in this case, all (long, char  *,%,/) or float or fields)
 */

static
bool ptr_vv_long(NP np)
{
	NP lp = np->left;
	if (np->size ne lp->size)					return false;
	if (np->size ne DOT_L)						return false;
	if (np->ty ne ET_P and lp->ty ne ET_P)		return false;
	if (     lp->ty eq ET_P
	    and (np->ty eq ET_U or np->ty eq ET_S)) return true;
	if (     np->ty eq ET_P
	    and (lp->ty eq ET_U or lp->ty eq ET_S)) return true;
	return false;
}

/*
 *	Check for lhs of op= that have side effects or are complex
 */

static
bool isvhard(NP np)
{
	NP rp;
	if (np->type eq nil)
	{
		CE_N(np, "isvhard; no type");
		return false;
	}

	do{									/*	descend:	*/
		switch (np->tt)
		{
		case E_LEAF:
			return false;
		case E_UNARY:
			switch (np->token)
			{
			case CALL:
			case INCR:
			case DECR:
			case POSTINCR:
			case POSTDECR:
				return true;
			default:
				np = np->left;		/*	go to descend;	*/
				continue;
			}
		case E_BIN:
			switch (np->token)
			{
			case PLUS:
			case MINUS:
				rp = np->right;
				if (    rp->token eq ICON
#if FLOAT
				    and np->type->ty ne ET_R
#endif
				   )
				{
					np = np->left;	/*	go to descend;	*/
					continue;
				}		/* fall through */
			default:
				return true;
			}
		}
	}od
#ifdef SOZOBON
	return false;
#endif
}

static
bool m_vhard(NP lp)
{
	while (lp->token eq SELECTOR)
		lp = lp->left;
	if (lp->token ne DEREF)
		return false;
	return isvhard(lp->left);
}

global
void
comma_r(NP topp, NP lp)
{
	NP newp = for_old_copyone(topp);
	topp->token = COMMA;
	name_to_str(topp, "comma_r");
	topp->left = lp;
	topp->right = newp;
}

global
void comma_l(NP topp, NP rp)
{
	NP newp = for_old_copyone(topp);
	topp->token = COMMA;
	name_to_str(topp, "comma_l");
	topp->right = rp;
	topp->left = newp;
}

static
NP etmp_var(short token)
{
	NP t1;
	TP tp;
	tp = make_type(-1, token, nil, nil);
	G.prtab->tmps += tp->size;
	t1 = make_node(OREG, E_LEAF, -(G.scope->b_size + G.prtab->tmps), "etmp_v");
	t1->rno = FRAMEP;
	t1->sc = K_AUTO;
	t1->type = tp;
	return t1;
}

static
TP hardassign(NP np, TP tp)
{
	NP lp = np->left, rp = np->right, oldnp = np;

	if (m_vhard(np->left))
	{										/* for left part */
		/* put result of whole left expression in a temp */
		NP atree, t1, t2, opp, starp = np->left;

		while (starp->token eq SELECTOR)
			starp = starp->left;
		atree = starp->left;

		t1 = etmp_var(REFTO);
		name_to_str(t1->type, "tmp_ref to");
		t2 = copyone(t1);
		starp->left = t2;

		opp = copyone(t1);
		opp->tt = E_BIN;
		opp->token = ASS;
		name_to_str(opp, graphic[ASS]);
		opp->right = atree;
		opp->left = t1;
		comma_r(np, opp);

		oldnp = np->right;
	}

	{								/* for right part */
		NP opp, newl;

		lp = oldnp->left;		/* for if changed by above */
		rp = oldnp->right;

		opp = copyone(oldnp);
		newl = copynode(lp);
		newl->eflgs.f.l_ass = 0;	/* 12'11 HR */
		opp->right = rp;
		oldnp->right = opp;
		opp->left = newl;

		oldnp->token = ASS;
		name_to_str(oldnp, "unfold");
		opp->token -= (ASSIGN 0);
		name_to_str(opp, graphic[opp->token]);		/* for b_overload() */
		binary_types(opp, FORSIDE, 0);
		oldnp->type = oldnp->left->type;		/* left type for assignment */
		to_nct(oldnp);
	}

	binary_types(np, FORSIDE, 0);		/* 11'10 HR */
	return tp;
}

global
TP hardasmagic(NP np, TP tp, short ty)
{
	if (
#if FLOAT
	     tp->ty eq ET_R
	     or
#endif
#if LL
		    tp->size > DOT_L
		 or
#endif
	        is_sreg(np->left) ne 0
	     or isfield(np->left)	/* only float or field if not *%/ */
	   )
		tp = hardassign(np, tp);
	elif (ty and tp->size < SIZE_L)
		tp = hardassign(np, tp);

	return tp;
}

global
TP hardas(NP np, TP tp)
{
	if (	xstronger(np->right->type, np->left->type)
		or  tp->size eq SIZE_L
		or  tp->size eq SIZE_C
		or	(
#if FLOAT
		     tp->ty eq ET_R or
#endif
#if LL
		     tp->size > DOT_L or
#endif
		     isfield(np->left)
		    )
	   )
		tp = hardassign(np, tp);
	return tp;
}
