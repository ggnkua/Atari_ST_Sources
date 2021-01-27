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
 *	Especially the handling of the nesting preprocesser directives
 *	is made (via nodes) more straightforward.
 *	Apart from the straightforwardness, which is quite an improvement,
 *	this became necessary because the symmetry was broken with the
 *	introduction of '#elif'.
 *
 */

#define DEBUGINC 1
#define X_REPAIR 1

#if FOR_A
static
char * d_prelude = "__prelude__";
#endif

short alert_text(char *, ...);
/*
 *	pre.c
 *
 *	preprocessor for the compiler
 *
 *	Handles all preprocessor (#) commands and
 *	  looks up keywords
 *
 *	Interface:
 *		advnode()	returns next "token node"
 *
 *	Special flags:  (tk_flags)
 *		These special flags are needed for the pre-processor.
 *		TK_SEEWS - want to see white space (for #define).
 *		TK_LTSTR - '<' is a string starter
 *
 * Discarding of white space and other irregular tokens
 * is delayed and performed by advnode() (in EXPR.C)
 * DELETE token introduced to get things smoother.
 * Escape sequences in strings are now dealt with AFTER ALL preprocessing
 * 	by advnode()
 */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include <tos.h>

#include "common/mallocs.h"
#include "common/amem.h"
#include "common/hierarch.h"
#include "common/pdb.h"

#include "param.h"
#include "decl.h"
#include "expr.h"
#include "e2.h"				/* for #if expressions */
#include "cache.h"
#include "pre.h"
#include "tok.h"

#define debugP (G.xflags['p'-'a'])
#define debug_p (G.yflags['p'-'a'])

XP cur, curtok;
XP *deflist;
XP getnode(void);			/* recursion */

long bios( void, ... );		/* bij Sozobon in STDIO.H */

extern
char trtime[], trdate[];		/* compiletime/date (once per translation unit) */

void dopound(void);


enum		/* preprocessor nests */
{
	NO_NEST,
	IF = 16,
	IFDEF,
	IFNDEF,
	ELIF,
	ELSE,
	ENDIF
};

typedef void PRE_COMMAND(struct cmds *cp, short isasm);

typedef struct cmds
{
	Cstr text;
	short l;
	PRE_COMMAND *pproc;
	short kind;
} CMDS;

static
char expects[]="preprocessor expects";

global void check_cache(short which, const char *s)
{
	short c = 0;
	CP ch = cache;
	while (ch)
	{
		if (!ch->name)
			alert_text("(%d)'%s' @ %d, | this %lx| name %lx next %lx | fileno %d   text %lx",
			             which,s,        c,   ch,       ch->name,ch->next,  ch->fileno, ch->text);

		c++;
		ch = ch->next;
	}
}

static
void PR_list(XP val, Cstr m)
{
	console("PR-= %s =-\t", m);
	while (val)
	{
		console("%lx, %s", val, val->name ? val->name : "???");
		val = val->next;
	}
	console("\n");
}

#if NODESTATS
static
XP tok_to_node(void)
{
	G.ncnt[STNODE]--;
	G.ncnt[DFNODE]++;
	curtok->nt = DFNODE;
	return curtok;
}
#elif 1
#define tok_to_node() (curtok->nt = DFNODE, curtok)
#else
XP tok_to_node(void)
{
if (curtok->token eq ROL)
	message(0, 0, "ROL %d", curtok->prec);
	curtok->nt = DFNODE;
	return curtok;
}
#endif

static
void hold_back(XP np)			/* some form of unget */
{
	np->next = G.holdtok;
	G.holdtok = np;
}

static
XP to_endof(void)
{
	XP rv = allocXn(1);
	rv->token = EOFTOK;
	name_to_str(rv, "end of file");
	return rv;
}

static
XP tok_cat(void)		/* retokenize from catenated tokens */
{					/* because new tokens may be formed */
					/* name ALLWAYS in heap, thus is \0 terminated */
	XP rv;

	G.tk_flags |= TK_SEENL;

	G.save_LEX = cur_LEX;
	cur_LEX = G.holdtok->catp;	/* this is for tok_next() */

	tok_next();					/* yields NL if holdtok->catp became empty */
	if (tok_ne(NL))
	{
		rv = tok_to_node();
		G.holdtok->catp = cur_LEX;		/* overwrite token */
		if (cur_LEX->cat eq eof)		/* if last token from catanation pass cat flag */
			rv->nflgs.i |= G.holdtok->nflgs.i;
		cur_LEX = G.save_LEX;
		G.save_LEX = nil;
		return rv;
	}
	cur_LEX = G.save_LEX;
	G.save_LEX = nil;
	rv = G.holdtok;
	G.holdtok = rv->next;				/* step */
	rv->next = nil;
	freeXn(rv);					/* free now tokenized holdtok */
	G.tk_flags &= ~TK_SEENL;
	return nil;
}

/* 2'11 HR: delayed lexing of catenated tokens */
/* 1'05 New lex: pretokenize the catenated token texts */
static
void cat_lex(XP np)
{
	LEX_RECORD *tokked;
	long l = strlen(np->name);

	tokked = CC_xmalloc(res_LEX*l + res_LEX, AH_FUSE_NAME_C, CC_ranout);	/* 6 times is theoretical maximum of C_lexical + end */
	l = C_lexical(2, nil, false, np->name, tokked, nil, nil, false, G.lang);
	free_name(np);
	np->nflgs.f.nheap = 1;
	np->name = (Cstr)tokked;
	np->catp = tokked;
	np->token = CATTED;
}

static
XP hi_node(void)			/* + tokenize catenated holdtoks */
{
	while (G.holdtok)					/* node from hold queue ? (expanded defines)*/
	{
		XP rv = G.holdtok;

		if (rv->token eq FUSED)			/* 02'11 HR: delay lexing of catenated tokens (a##b##c) */
			cat_lex(rv);

		if (rv->token eq CATTED)
		{
			if ( (rv = tok_cat()) eq nil)
				continue;
		othw
			G.holdtok = rv->next;			/* step */
			rv->next = nil;
		}
		return rv;
	}

	while tok_ne(EOFTOK)
		if (G.iftab->p.truth)
		{
			ushort  tok = tok_next();
			if (SAW_NL and tok eq PREP)	/* 03'09 check first of a line */
				dopound();				/* may change iftab->p.truth */
			else
			{
				tok_to_node();
				return curtok;
			}
		}
		else
			if (tok_prep() eq PREP)
				dopound();				/* may change iftab->p.truth */
			else
				return nil;				/* can only be EOF */

	return nil;
}

/* 05'11 HR: reduced version of hi_node */
static
void hi_tok(void)
{
	if (G.holdtok)					/* node from hold queue ? */
	{
		curtok = G.holdtok;
		G.holdtok = curtok->next;	/* step */
		curtok->next = nil;
	}
	else
		tok_next();
}

/* 01'09 HR */
static
void slash_double(char *d, Cstr s)
{
	while (*s)
	{
		if (*s eq '\\') *d++ = '\\';
		*d++ = *s++;
	}
	*d = 0;
}

static
bool builtin(XP np)
{
	if   (strcmp(np->name, "__LINE__") eq 0)
	{
		np->token = ICON;
		np->val.i = line_no;
		return true;
	}
	elif (strcmp(np->name, "__FILE__") eq 0)
	{
		char double_slash[256];
		slash_double(double_slash, G.inctab->name);		/* 01'09 HR */
		np->token = SCON;
		np->val.i = new_name(np, LQUOTED "%s" RQUOTED, double_slash);
		return true;
	}
	elif (strcmp(np->name, "__TIME__") eq 0)
	{
		np->token = SCON;
		np->val.i = new_name(np, LQUOTED "%s" RQUOTED, trtime);
		return true;
	}
	elif (strcmp(np->name, "__DATE__") eq 0)
	{
		np->token = SCON;
		np->val.i = new_name(np, LQUOTED "%s" RQUOTED, trdate);
		return true;
	}
	elif (strcmp(np->name, "__STDC__") eq 0)
	{
		np->token = ICON;
		np->val.i = true;
		return true;
	}
	elif (   strcmp(np->name, "__func__") eq 0
	      or strcmp(np->name, "__FUNCTION__") eq 0)		/* 03'09 */
	{
		Cstr pname = G.prtab ? G.prtab->name : "File";

		np->token = SCON;
		np->val.i = new_name(np, LQUOTED "%s" RQUOTED, pname);
	}

	return false;
}

static
void argsmod(XP toks, XP args, short isasm)	/* handling of TO_STR (#param) */
{
	XP vp;
	XP hp = nil;			/* position of TO_STR */

	while (toks)
	{
		if (!isasm and toks->token eq TO_STR)
			hp = toks;
		elif (toks->token eq ID)
		{
			if ( (vp = tlook(args, toks)) ne nil)
			{
				toks->nflgs.f.spar = 0;
				if (hp)
				{
					toks->nflgs.f.spar = 1;
					while (hp ne toks)		/* TO_STR & WS til current */
					{
						hp->token = DELETE;
						hp = hp->next;
					}
					hp = nil;
				}
				toks->token = DPARAM;
				toks->val = vp->val;
				new_name(toks, "\\%ld", toks->val.i);
			}
		}

		if (toks->token ne WS and toks->token ne TO_STR)
		{
			if (hp)
				errorn(toks, "'%s' with no parameter", graphic[TO_STR]);
			hp = nil;
		}

		toks = toks->next;
	}
}

static
bool l_cmp(XP p1, XP p2)		/* names --> true: truely equal */
{
	if (p1->token ne p2->token)
		return false;

	if (p1->token eq ID and p1->name eq p2->name)
		return true;

	switch (p1->token)			/* same token */
	{
		case ID:
		case SCON:
		case SCON1:
			return strcmp(p1->name, p2->name) eq 0;
		case ICON:
#if FLOAT
		case FCON:
#endif
		case ASCON:
			return p1->val.i eq p2->val.i;
#if FLOAT
		case RCON:
			return getrcon((NP)p1) eq getrcon((NP)p2);
#endif

#if LL
		case LCON:
		{
			__ll l1 = getlcon((NP)p1),
			     l2 = getlcon((NP)p2);
			 return l1.hi eq l2.hi and l1.lo eq l2.lo;
		}
#endif
	}

	return true;
}

static
bool same_list(XP p1, XP p2)		/* true = equal */
{
	D_(P, "same_list");

	if (p1 eq nil)
		if (p2 eq nil) return true;
	if (p2 eq nil)
		return false;
	if (l_cmp(p1, p2) eq 0)
		return true;
	return same_list(p1->next, p2->next);
}

static
bool samedef(XP p1, XP p2)		/* true = equal */
{
	D_(P, "samedef\t");

	if (p1->val.i ne p2->val.i)
		return false;
	return same_list(p1->tseq, p2->tseq);
}

/* 03'09: Quick fix of real existing recursions */
static
void mark_exp(XP def, XP val)
{
	while (val)
	{
		val->nflgs.f.Xp = 1;
		if (val->token eq ID and def->name eq val->name)
			val->nflgs.f.nexp = 1;
		val = val->next;
	}
}

global
void do_define(XP def, XP val, XP args, bool pdb, short isasm)
{
	XP oldp; short h;

	D_(P, "do_define");

	if (args ne nil)
	{
		argsmod(val, args, isasm);
		freeXn(args);
	}

	def->tseq = val;
	mark_exp(def, val);			/* oa K&R 2nd A12.3 */

	def->nflgs.f.brk_l = 1;
	h = hash(def->name);
	if ((oldp = tlook(deflist[h], def)) eq nil)
	{
#if BIP_ASM
		def->nflgs.f.asmac |= isasm;
#endif
		put_xlist(&deflist[h], def);
#if BIP_CC
		if (G.ah_project_help and pdb)
			pdb_new_ide(&identifiers, def->name, def->fl.n, def->fl.ln, 0);
#endif
	othw
#if BIP_ASM
		if (isasm)
		{
			if (oldp->cflgs.f.equ)
				error("redefinition of '%s'", def->name);
			freeXn(def);
		}
		else
#endif
		{
			if (!samedef(oldp, def))
				warn("redefinition of '%s' not same", def->name);
			freeXn(def);
		}
	}
}

static
short defnargs;

static
Cstr pwarn(short isasm) { return graphic[isasm ? SELECT : PREP]; }

global
XP def_arglist(short isasm)
{
	XP tail = nil,
	   np   = nil,
	   rv   = nil;

	D_(P, "def_arglist");
	do{
		if tok_ne(ID)
		{
			error("%sdefine expects ID", pwarn(isasm));
			freeXn(rv);
			defnargs = 0;
			return nil;
		}

		np = tok_to_node();
		np->val.i = defnargs++;	/* hold sequence number */

		if (tail eq nil)			/* first one */
			rv = np;
		else						/* more */
			tail->next = np;

		tail = np;
		tok_next();
		if (tok_ne(COMMA))
			break;

		tok_next();
	}od

	return rv;
}

static
XP def_args(short isasm)			/* make LIST of args, NOT tree */
{
	XP rv;

	D_(P, "def_args");

	if (tok_next() eq NERAP)		/* empty arg list is OK */
	{
		tok_next();
		return nil;
	}

	rv = def_arglist(isasm);

	if tok_is(NERAP)
		tok_next();
	else
	{
		error("%sdefine argument syntax", pwarn(isasm));
		freeXn(rv);
		rv = nil;
		defnargs = 0;
	}

	return rv;
}

#if BIP_ASM
static
bool is_repeat(XP tok)
{
	return tok->token eq ID
	    and (   stricmp(tok->name, "rept"  ) eq 0
		     or stricmp(tok->name, "repeat") eq 0
		    );
}

static
bool is_endrm(XP tok)
{
	return tok->token eq ID
	    and (   stricmp(tok->name, "endm") eq 0
	         or stricmp(tok->name, "endr") eq 0
	        );
}

static
bool is_mac(XP tok)
{
	return tok->token eq ID
		and stricmp(tok->name, "macro") eq 0;
}

/* bool is_endmac(XP tok) */
static
bool is_pnest(XP tok)
{
	return is_repeat(tok) or is_mac(tok);
}

/* 05'11 HR: replaces def_val and made recursive. */
static
XP rpt_val(void)
{
	XP rv   = nil,
	   tail = nil,
	   np   = nil,
	   last;
	XP repeat(XP *last);

	G.in_def = true;

	while (tok_ne(EOFTOK))
	{
		if (tok_is(ENDS))
			tok_to_nl(false);		/* on nl */
		else
		{
			if (is_repeat(curtok))
			{
				if (tok_is(WS))
					hi_tok();
				hi_tok();
				cur = curtok;
				np = repeat(&last);
			othw
				if (is_endrm(curtok))
					break;

				np = tok_to_node();
				last = np;
			}

			if (tail eq nil)				/* first one */
				rv = np;
			else							/* more */
				tail->next = np;

			tail = last;

			G.tk_flags |= TK_SEEWS;	/* delay discarding of WS */
		}

		hi_tok();
	}

	G.in_def = false;

	return rv;
}
#endif

static
Cstr tokseq = "token sequence";

/* If end is ENDMAC, isasm can be either 0 or 1.
   If end is NL isasm is always 0.
 */
global
XP def_val(short endv, short isasm)
{
	XP rv   = nil,
	   tail = nil,
	   np   = nil,
	   back = nil;

#if BIP_ASM
	short level = 0;
#endif

	D_(P, "def_val");

	G.in_def = true;

	if (tok_is(WS))			/* 03'09 oooops */
		tok_next();

	while (tok_is(PARCAT))
	{
		error("%s starts with '%s'", tokseq, graphic[PARCAT]);
		if (tok_next() eq WS)
			tok_next();
	}

	while (
#if BIP_ASM
	       level or
#endif
	       tok_ne(endv)
	      )
	{
		if (isasm and tok_is(ENDS))
			tok_to_nl(false);		/* on nl */
		else
		if (
#if BIP_ASM
		    !isasm and
#endif
		    tok_is(PARCAT))	/* definitely not first */
		{
			if (tail->nflgs.f.lcat)
				error("consecutive %s", graphic[PARCAT]);
			else
			{
				if (tail->token eq WS)
				{
					freeXn(tail);
					tail = back;
					if (rv eq back)
						back = nil;
					else
						back = tail;
				}
				tail->nflgs.f.lcat = 1;
			}
		othw
#if BIP_ASM
			if (isasm)
				if (is_repeat(curtok))
					level++;
				elif(is_endrm(curtok))
				{
					if (level eq 0)
						break;
					level--;
				}
#endif
			np = tok_to_node();

			if (tail eq nil)				/* first one */
				rv = np;
			else							/* more */
			{
				if (tail->nflgs.f.lcat)
					np->nflgs.f.rcat = 1;
				tail->next = np;
			}
			back = tail;
			tail = np;
			G.tk_flags |= TK_SEEWS;	/* delay discarding of WS */
		}							/* only if !PARCAT */

		tok_next();
	}

	if (np)						/* then there is at least 1 non WS */
	{
		if (back and np->token eq WS)	/* discard trailing white space if back */
		{
			freeXn(tail);
			back->next = nil;
			tail = back;
		}

		if (tail and tail->token eq PARCAT)
			if (np ne tail)
			{
				error("%s ends with '%s'", tokseq, graphic[PARCAT]);
				tail->token = WS;
			}
	}

	G.in_def = false;

	return rv;
}

global
void optdef(Cstr s, Cstr as)	/* as must be just 1 token */
{
	XP val;
	XP def;
	LEX_RECORD *tokked;

	defnargs = -1;
	val = nil;

	def = allocXn(1);
	def->token = ID;
	new_name(def, "%s", s);
	G.save_LEX = cur_LEX ? cur_LEX : (LEX_RECORD *)"";
	G.tk_flags |= TK_SEENL;
	tokked = CC_xmalloc(res_LEX*strlen(as) + res_LEX, AH_OPTDEF, CC_ranout);		/* as is minimal a "1" */
#if BIP_ASM || FOR_A
	C_lexical(3, nil, false, as, tokked, nil, nil, false, G.lang);
#else
	C_lexical(4, nil, false, as, tokked, nil, nil, false, 'c');
#endif
	cur_LEX = tokked;
	tok_next();
	val = def_val(NL, 0);
	cur_LEX = G.save_LEX;
	G.save_LEX = nil;
	def->val.i = defnargs;
	do_define(def, val, nil, false, 0);
	CC_xfree(tokked);
	G.tk_flags &= ~TK_SEENL;			/* 03'09 */
}

static
XP gath1(short endc, short *sep)
{
	XP np  = nil,
	   rv  = nil,
	   tail= nil;
	XP back;
	short inparen = 0, tel = 1;

#if X_REPAIR
	np = getnode();
#else
	np = hi_node();
#endif

	/* flow changed for handling WS:
		  (discard only trailing and leading)
	   labels removed
	*/

	do{
		if (np eq nil)
		{
			freeXn(rv);
			*sep = 0;
			return nil;
		}

		if (   np->token eq endc
		    or np->token eq NERAP
		    or np->token eq COMMA
		   )
			if (inparen)
			{							/* dont end, part of subexpr */
				if (np->token eq NERAP)
					inparen--;
			othw
				*sep = np->token;
				freeXn(np);
				break;					/* see above */
			}
		elif (np->token eq PAREN)
			inparen++;

		if (tail eq nil)
			rv = np;					/* first one */
		else
			tail->next = np;			/* more */
		back = tail;

		tail = np;

		G.tk_flags |= TK_SEEWS;	/* delay discarding of WS */
		tel++;
#if X_REPAIR
		np = getnode();
#else
		np = hi_node();
#endif
	}od

	if (tail and tail->token eq WS)	/* discard trailing white space */
	{
		freeXn(tail);
		back->next = nil;
		tail = back;
	}

	return rv;
}

static
XP gath_args(short n, short endc)
{
	XP rv = nil,
	   np,
	   tail = nil;

	short getn = 0,
		sep;

	do{
		np = gath1(endc, &sep);

		if (np eq nil)
		{
#if 0
			np = allocXn(1);		/* 11'13 HR: accept empty stguments */
			if (np)
				name_to_str(np, "empty");
			else
#endif
			{
				error("%s argument", expects);
				if (tail eq nil)
					freeXn(rv);
				rv = nil;
				break;
			}
		}

		getn++;

		if (tail eq nil)		/* first one */
			rv = np;
		else						/* more */
			tail->down = np;

		tail = np;

		if (!sep)
			error("%.12s expand argument syntax", expects);
		elif(sep eq COMMA)
			continue;
		elif(sep eq endc)
		{
			if (getn ne n)
			{
				error("%.12s no of arguments mismatch", expects);
				freeXn(rv);
				rv = nil;
			}
			break;
		}
	}od

	return rv;
}

static
XP gath_S_args(short n)
{
	XP rv;

	if (n eq 0)
		return nil;

	G.in_def = true;

	rv = gath_args(n, NL);

	G.in_def = false;
	return rv;
}

static
XP gath_C_args(short n)
{
	XP rv = nil, np;

	G.in_def = true;
	np = hi_node();

	if (np->token eq WS)
	{
		freeXn(np);
		np = hi_node();
	}

	if (np->token ne PAREN)
	{
		/* application of name without parentheses where the same
		   name with arguments has been found in the defines
		   is considered not an error; name just is not expanded */
		hold_back(np);			/* push unused token back */
		(long)rv = -1;
	othw
		freeXn(np);

		if (n eq 0)
		{
			np = hi_node();
			if (np->token eq NERAP)
				freeXn(np);				/* allow empty actual parameter list. */
			else
			{
				error("%s '%s'", expects, graphic[NERAP]);
				hold_back(np);			/* push unused token back */
			}
		}
		else
			rv = gath_args(n, NERAP);
	}

	G.in_def = false;
	return rv;
}

#define T (unsigned char)

static
XP spar_fix(XP sub)
{
	Wstr quoted;
	short i = 2;		/* for 2 quotes	*/
	XP scons = sub;

	D_(P, "spar_fix");

	while (scons)
	{
		i += strlen(scons->name);
		scons = scons->next;
	}

	scons = sub;
	quoted = CC_xmalloc(i+1, AH_SPAR_FIX, CC_ranout);

	if (quoted)
	{
		Wstr s = quoted+1;
		strcpy(quoted, LQUOTED);
		while (scons)
		{
			strcat(quoted, scons->name);
			scons = scons->next;
		}
		while (*s)		/* if the #param had quotes, must reinstate them */
		{
			if (T*s eq DOUBLESTART)
				*s = DBLSTART;
			elif (T*s eq DOUBLEEND)
				*s = DBLSTREND;
			s++;
		}
	}
	strcat(quoted, RQUOTED);

	freeXn(sub->next);
	sub->next = nil;
	sub->name = quoted;
	sub->nflgs.f.nheap = 1;
	sub->val.i = i;
	sub->token = SCON;		/* --> string */

	return sub;
}

static
XP copylist(XP np, XP *tailp)
{
	XP rv = nil, nx = nil, tail = nil;

	while (np)
	{
		nx = copyXone(np);
		if (!tail)
			rv = nx;
		else
			tail->next = nx;
		tail = nx;
		np = np->next;
	}
	*tailp = nx;
	return rv;
}

/* 1'05 New lex: pretokenize the cattenated token texts */
static
void fuse_name(XP lp, XP rp, short isasm)	/* left = LCAT, next = right has RCAT */
{
	long l = strlen(lp->name) + strlen(rp->name);
	Wstr catted;
	lp->nflgs.f.lcat |= rp->nflgs.f.lcat;		/* inherit flag for subseq catanations */
	lp->next = rp->next;
	catted = CC_xmalloc(l+1, AH_FUSE_NAME_T, CC_ranout);
	if (catted)
	{
		strcpy(catted, lp->name);
		strcat(catted, rp->name);
		free_name(lp);
		freeXunit(rp);
		lp->nflgs.f.nheap = 1;
		lp->name = catted;
		lp->token = FUSED;
	}
}

static
XP arg_fix(XP val, XP args, XP *rt, short isasm)
{
	XP sub,
	   substail,
	   head,
	   cat,
	   back;

	head = val;
	back = nil;

	while (val)
	{
		cat = val;

		if (val->token eq DPARAM)
		{
			sub = (XP)rthnode((NP)args, val->val.i);	/* ivalth node */
			sub = copylist(sub, &substail);				/* substitution */

			if (val->nflgs.f.spar)
				substail = spar_fix(sub);

			substail->nflgs.f.lcat |= val->nflgs.f.lcat;	/* inherit flags */
			substail->nflgs.f.rcat |= val->nflgs.f.rcat;

			if (back)
				back->next = sub;
			else
				head = sub;
			substail->next = val->next;
			val->next = nil;
			freeXn(val);
			val = substail;
			cat = sub;
		}

		if (cat->nflgs.f.rcat)		/* PARCAT (##) */
		{
			back->nflgs.f.lcat = 0;
			fuse_name(back, cat, isasm);

	/* catenate last tok of left seq (back) with first tok of
	   right seq ( back->next = cat = sub) */

			val = back;						/* val->next swallowed */
		}

		back = val;
		val  = val->next;

	}
	*rt = back;

#if C_DEBUG
	if (debugP)
	{
		val = head;
		while(val)
		{
			send_msg("|%s", val->name);
			val  = val->next;
		}
		send_msg("\n");
	}
#endif
	return head;
}

static
bool expand(XP dp, XP *to, short isasm)
{
	short nargs;
	XP args, val, tail;

	val = dp->tseq;			/* token sequence */

	if (val)
		val = copylist(val, &tail);		/* copy macro definition */

	nargs = dp->val.i;

	if (nargs >= 0)
	{
#if BIP_ASM
		args = (
		          dp->nflgs.f.asmac
				? gath_S_args
				: gath_C_args)(nargs);

#else
		args = gath_C_args(nargs);
#endif
		if ((long) args eq -1)			/* no expansion */
		{
			freeXn(val);
			return false;
		}

		if (	nargs > 0
			and	!args
			and val      )
		{
			freeXn(val);
			val = nil;		/* in stead of compiling unexpanded code */
		}
	}

	if (val)
		val = arg_fix(val, args, &tail, isasm);

	if (args and nargs >= 0)
		freeXn(args);

	if (val)
	{
		tail->next = *to;
		*to = val;
	}

	return true;
}

static
PRE_COMMAND p_undef
{
	XP np, tp; short h;

	D_(P, "p_undef");

	if (tok_next() ne ID)
		error("bad %sundef", pwarn(isasm));
	else
	{
		tp = tok_to_node();
		h = hash(tp->name);
		if ((np = tlook(deflist[h], tp)) ne nil)
			name_to_str(np, "~~~");
		freeXn(tp);
	}
}

#define MAXIDIR	16

/* NN..BB..    these are also in init_cc when BIP _ CC */
static
Wstr srchlist[MAXIDIR];

global
void doincl(Cstr s)		/* optincl */
{
#ifdef ENVINC
	char	buf[256];
	Wstr pt;
#endif
	char	dir[256];
	char c;
	short i;

	if (G.idir_n >= MAXIDIR)
	{
		warn("too many -I dirs");
		return;
	}
#ifdef ENVINC
	strcpy(buf, s);

	/*
	 * Convert ',' and ';' to nulls
	 */
	for (pt = buf; *pt ne 0 ;pt++)
		if (*pt eq ',' or *pt eq ';')
			*pt = 0;
	pt[1] = 0;			/* double null terminated */

	/*
	 * Grab each directory, make sure it ends with a backslash,
	 * and add it to the directory list.
	 */
	for (pt = buf; *pt ne 0 ;pt++)
	{
		strcpy(dir, pt);
#else
		strcpy(dir, s);
#endif

		c = dir[strlen(dir)-1];

		if (c ne bslash and c ne fslash)
			strcat(dir, sbslash);

		for (i = 0; i < G.idir_n; i++)
			if (stricmp(srchlist[i], dir) eq 0)
			{
				*dir = 0;
				break;
			}

		if (*dir)
		{
			char *to = CC_xmalloc(strlen(dir) + 1, AH_DOINCL, CC_ranout);
			if (to)
			{
				short n;
				strcpy(to, dir);
				/* push up previous dirs */
				for (n = G.idir_n; n > 0; n--)
					srchlist[n] = srchlist[n - 1];
				srchlist[0] = to;
				G.idir_n++;
			}
		}

#ifdef ENVINC
		while (*pt ne 0)
			pt++;
	}
#endif
#if 0 /* DEBUGINC */
if (G.v_Cverbosity > 3)
	{
		Cstr *dir = srchlist;
		console("-I files %d\n", G.idir_n);
		while (*dir)
		{
			console("-I '%s'\n", *dir);
			dir++;
		}
	}
#endif
}

global
void free_srchlist(void)
{
	short i;
	for (i = 0; i < G.idir_n; i++)
		CC_xfree(srchlist[i]);
	G.idir_n = 0;
}

global
void freeincs(void)
{
	freeVn(G.inctab);
	G.inctab = nil;

	if (G.v_Cverbosity > 1)
	{
		long size = 0; short no = 0;
		CP cp = cache;
		while (cp)
		{
			size += cp->size;
			no++;
			cp = cp->next;
		}
		if (no)
			send_msg("Cached %d header%s in %ldK\n", no, pluralis(no), (size+1023)/1024);
	}
}

static
bool reduce_path(char *path)
{
	char *sp,
	     *s = path + strlen(path) - 1;

	*s = 0;
	sp = strrchr(path, '\\');
	*s = '\\';
	if (sp)
		return strcpy(sp, s), true;
	return false;
}

#include "common/hierarch.h"

global
bool is_drive(Cstr s)
{
	return isalpha(*s) and *(s + 1) eq ':';
}

void inc_stats(CP, bool);
VP load_bin(char *name);

static
CP look_file(S_path *dir, TP scon, short *fileno, short what)
{
	CP xp;
	S_path f;

	static S_path lasttry = {""};

	if (*dir->s eq '\\')
		DIRcpy(&f, dir->s+1);
	else
		DIRcpy(&f, dir->s);

	DIRcat(&f, scon->name);
	hn_dotdot(f.s, ":\\.", 4);		/* collapse \..\ */

	if (strcmp(lasttry.s, f.s) eq 0)	/* useless try */
		return nil;

	if (G.incbin)
	{
		(VP)xp = load_bin(f.s);
	othw
		xp = cache_look(3, cache, nil, f.s, true);

		if (xp and fileno)
		{
			*fileno = xp->fileno;
			free_name(scon);
			scon->name = xp->name;
			G.C_bytes += xp->bytes;
#if BIP_CC
			if (G.aj_auto_depend or G.ah_project_help)
				pdb_fdepend(&auto_dependencies, G.inctab ? G.inctab->name : nil ,f.s, *fileno, 2);
			else
				*fileno = xp->fileno;
#endif
		}
		else
			xp = load_source_file(f.s, fileno);

#if DEBUGINC
		if (G.v_Cverbosity > 3)
			console("[%d]tried '%s' :: %s\n", what, f.s, xp ? "OK" : "FAIL");
#endif

		if (xp eq nil)
			DIRcpy(&lasttry, f.s);
#if BIP_CC
		else
			inc_stats(xp, false);
#endif
	}

	return xp;
}

static
CP srch_open(TP scon, bool here, short *fileno)
{
	S_path thisdir, temp;
	CP xp = nil;

#if BIP_CC
	extern S_path mkpad;
#endif

#if DEBUGINC
	if (G.v_Cverbosity > 3)
		send_msg("srch_open %s\n", scon->name);
#endif

	if (is_drive(scon->name))
	{
		temp.s[0] = 0;
		xp = look_file(&temp, scon, fileno,1);
	othw
		Cstr *dir = srchlist;

		if (here)			/* "name" */
		{
/*			if (G.v_Cverbosity > 3)
				message(0, 0, "includer is '%s'", G.includer.s);
*/			xp = look_file(&G.includer, scon, fileno,2);
			if (xp)
				return xp;

			DIRcpy(&thisdir, G.input_dir.s);		/* look in current dir */
			xp = look_file(&G.input_dir, scon, fileno,3);

			if (xp eq nil)
				while (reduce_path(thisdir.s))	/* go up in current dir */
					if ( (xp = look_file(&thisdir, scon, fileno,4)) ne nil)
						break;
			if (xp)
				return xp;
		}
		while (*dir)			/* start looking as close as possible to the includer */
		{
			if (!is_drive(*dir))					/* look in standard include dir's (-I's) */
			{
				DIRcpy(&temp, G.input_dir.s);				/* 11'09 HR: look in directory of PRJ as well for !here */
				DIRcat(&temp, *dir);
				xp = look_file(&temp, scon, fileno,5);
				if (!xp)
				{
#if BIP_CC
					DIRcpy(&temp, mkpad.s);		/* look in current dir */
					DIRcat(&temp, *dir);
					xp = look_file(&temp, scon, fileno,6);
					if (!xp)
#endif
					{
#if CC_PATH
						DIRcpy(&temp, CC_path.s);
						DIRcat(&temp, *dir);
						xp = look_file(&temp, scon, fileno,7);
#else
						DIRcpy(&temp, *dir);
						xp = look_file(&temp, scon, fileno,8);
#endif
					}
				}
			othw
				DIRcpy(&temp, *dir);
				xp = look_file(&temp, scon, fileno,9);
			}

			if (xp)
				break;

			dir++;
		}

#if BIP_CC
		if (xp eq nil)							/* try project dir */
			xp = look_file(&mkpad, scon, fileno,10);
#endif
	}

	return xp;
}

static
void newfile(CP sp, short fileno)
{
	if (sp)
	{
		VP ip = G.inctab;
		VP np = allocVn(IFNODE);

		np->name = sp->name;
		putv_lifo(&G.inctab, np);
		ip->vval  = line_no;
		ip->p.cur_LEX = cur_LEX;
		np->p.lvl     = ip->p.lvl+1;
		np->p.fileno  = fileno;
		np->p.cache   = sp;
		cur_LEX = sp->text;
		line_no = n_line_no = 1;
		G.tk_flags = TK_SAWNL;    /* 03'09 */
		send_incname(ip->p.lvl, np->name);		/* name w/o path */
	}
}

global
CP incl_name(short isasm, short *fileno)
{
	bool chkhere;
	void fix_scon1(XP xp);
	CP newf;
	TP scon;

	G.tk_flags |= TK_LTSTR;

	if (isasm)
	{
		if (cur->token eq ICON)		/* 11'09 HR: hack for include 'nnnnnnnn' in asm */
		{
			cur->val.i = strlen(cur->name);
			fix_scon1(cur);
		}
	}
	else
		advnode();

	scon = tpcur();

	if (   scon->token eq SCON		/* "...." */
		or scon->token eq SCON1)
		chkhere = true;
	elif (scon->token eq SCON2)		/* <....> */
		chkhere = false;
	elif (   scon->token eq NL
		  or scon->token eq EOFTOK)
	{
		error("bad %sinclude", pwarn(isasm));
		freeTn(scon);
		return nil;
	}

	{
		Wstr s = (Wstr)scon->name;
		while (*s)
		{
			if (*s eq '/') *s = '\\';
			s++;
		}
	}

	newf = srch_open(scon, chkhere, fileno);

	if (!newf)
		error("Can't open include file '%s'\n", scon->name);

	freeTn(scon);

	return newf;
}

static
PRE_COMMAND p_inc
{
	short fileno = 0;
	D_(P, "p_inc");
	newfile(incl_name(isasm, &fileno), fileno);
}

global
void invoke_runtime(void)
{
	short fileno = 0;
	CP newf;
	TP scon = make_type(SCON2, -1, nil,
#ifdef PRGNAME
	  PRGNAME
#else
	 "AHCC"
#endif
		   "RT.H");

	newf = srch_open(scon, 0, &fileno);

	if (newf)
		newfile(newf, fileno);
	else
		errorn(scon, "Can't open runtime header");

	freeTn(scon);
}

static
void p_defined(NP np)	/* traverse expr tree for defined */
{
	D_(P, "p_defined");

	if (np->token eq DEFINED)
	{
		NP lp;				/* defined is unary dus geen right meer */
		short truth;

		lp = np->left;

		if (lp and lp->token eq ID)
		{
			truth = (tlook (deflist[hash(lp->name)], (XP)lp) ne nil);
			np->left = lp->left;
			freeunit(lp);
			np->token = ICON;
			np->val.i = truth;
			np->tt = E_LEAF;
		}
	}
#if FOR_A
	elif (np->token eq DECLARED)
	{
		NP lp;
		short truth;

		lp = np->left;

		if (lp and lp->token eq ID)
		{
			truth = all_syms((TP)lp, 0) ne nil;
			np->left = lp->left;
			freeunit(lp);
			np->token = ICON;
			np->val.i = truth;
			np->tt = E_LEAF;
		}
	}
#endif

	if (np->left)
		p_defined(np->left);
	if (np->right)
		p_defined(np->right);
}

static
long if_expr(CMDS *cp, short isasm)
{
	NP tp;
	long rv;

	G.in_if_X = true;				/* 3'91 v1.2: for getnode() and questx() */
	G.skip_id = false;
#if BIP_ASM
	G.asm_if = isasm;				/* 04'12 HR: '=' in expression is 'EQUALS' */
#endif

	if (!isasm)
		advnode();

	tp = questx();


	G.in_if_X = false;			/* 3'91 v1.2 */
	G.skip_id = false;
#if BIP_ASM
	G.asm_if  = false;
#endif

	if (tp)
	{
		p_defined(tp);			/* 3'91 v1.2 */
		rv = confold_value(tp, FORTRUTH);
		if (cp->kind < IF)			/* 10'10 HR */
		{
			switch(cp->kind)
			{
				case B_NE: rv = rv ne 0; break;
				case B_EQ: rv = rv eq 0; break;
				case B_LE: rv = rv <= 0; break;
				case B_LT: rv = rv <  0; break;
				case B_GE: rv = rv >= 0; break;
				case B_GT: rv = rv >  0; break;
			}
		}
	} else
		rv = 0;

	if cur_ne(NL)
		error("bad %s%s", pwarn(isasm), cp->text);
	elif (!isasm)
		if (cur->nt ne EXNODE)
			freeXn(cur);
		else
			freenode((NP)cur);
	return rv;
}

global
PRE_COMMAND p_if
{
	short truth;
	VP new = copyVone(G.iftab);
	new->next  = G.iftab;
	new->p.kind = cp->kind;
	new->p.nest++;
	name_to_str(new, cp->text);
	G.iftab = new;

	if (!G.iftab->p.truth)				/* inherited	*/
		return;

	if (cp->kind < IF)
	{
		if (!isasm)
			warn("'%s' is a assembler directive", cp->text);
		truth = if_expr(cp, isasm);
	}
	elif(   cp->kind eq IF
		 or cp->kind eq ELIF
		)
		truth = if_expr(cp, isasm);
	elif(   cp->kind eq IFDEF
		 or cp->kind eq IFNDEF
		)
	{
		if (!isasm)
			tok_next();
		if (curtok->token ne ID)
		{
			error("bad %s%s", pwarn(isasm), cp->text);
			return;
		}
		truth = (tlook (deflist[hash(curtok->name)], curtok) ne nil);
		if (G.iftab->p.kind eq IFNDEF)
			truth = !truth;
	}

	G.iftab->p.truth = truth;
}

static
PRE_COMMAND p_swit
{
	if (G.iftab->p.nest eq 0)
	{
		error("not in %sif", pwarn(isasm));
		return;
	}

	if	(   (   cp->kind eq ELSE
		     or cp->kind eq ELIF
		    )
		 and G.iftab->next->p.truth 	/* was this nested within truth */
		)
		G.iftab->p.truth = !G.iftab->p.truth;
	elif (cp->kind eq ENDIF)
	{
		short ifty;
		do
		{
			VP xp = G.iftab;
			ifty = G.iftab->p.kind;
			G.iftab = G.iftab->next;
			freeVunit(xp);			/*	end all consecutive elifs	*/
		}							/*	and matching if				*/
		while (ifty eq ELIF);
	}
}

static
PRE_COMMAND p_elif
{
	PRE_COMMAND p_if;
	p_swit(cp, isasm);
	p_if(cp, isasm);
}

static
PRE_COMMAND p_def
{
	XP args, val, def;

	D_(P, "p_def");

	defnargs = -1;
	args = nil;
	val = nil;
	if (!isasm)
		tok_next();
	if (tok_ne(ID))
	{
		error("%sdefine: no identifier %s", pwarn(isasm), curtok->name);
		return;
	}

#if FOR_A
	if (strcmp(curtok->name, d_prelude) eq 0)
	{
		G.prelude = true;
		return;
	}
#endif

	def = tok_to_node();
	G.tk_flags |= TK_SEEWS;
	switch (tok_next())
	{
	case PAREN:
		defnargs = 0;
		args = def_args(isasm);
	case WS:
		val = def_val(NL, isasm);
	case NL:
		def->val.i = defnargs;
		do_define(def, val, args, true, isasm);
		break;
	default:
		error("bad %sdefine", pwarn(isasm));
	}
}

static
PRE_COMMAND p_macro
{
	XP args, val, def;
	ushort tok = 0;

	defnargs = -1;
	args = nil;
	val = nil;

	if (curtok->token ne ID)
	{
		error("%smacro: no identifier %s", pwarn(isasm), curtok->name);
		return;
	}

	def = tok_to_node();
	G.tk_flags |= TK_SEEWS;
	switch (tok_next())
	{
	case PAREN:						/* must be ( args ) */
		tok = PAREN;
		defnargs = 0;
		args = def_args(isasm);
		break;
	case ID:						/* have args */
		tok = ID;
		defnargs = 0;
		args = def_arglist(isasm);
		break;
	case WS:						/* could be args */
		tok = tok_next();
		if (tok eq ID)				/* have args */
		{
			defnargs = 0;
			args = def_arglist(isasm);
		}
		tok = ID;
		break;
	case NL:						/* no args */
		tok = NL;
		break;
#if BIP_ASM
	case K_ENDMAC:
#endif
	case END_MAC:
		console("K_ENDMAC\n");		/* should not happen */
	default:
		error("bad %smacro", pwarn(isasm));
	}

	if (tok)
	{
		if (tok_is(NL))
			tok_next();
		val = def_val(END_MAC, isasm);
		def->val.i = defnargs;
		do_define(def, val, args, true, 1);
		cur = curtok;
	}
}

#if BIP_ASM
static
XP repeat(XP *rtail)
{
	XP val, tail, copy, last;
	NP np;
	long i = 1;

	np = questx();

	i = confold_value(np, FORSIDE);

	if (i <= 0)
	{
		error("invalid repeat value: %ld", i);
		i = 1;
	}

	curtok = cur;
	G.tk_flags |= TK_SEEWS;

	val = rpt_val();
	copy = copylist(val, &tail);

	while (--i > 0)
	{
		last = tail;
		last->next = copylist(val, &tail);
	}

	freeXn(val);
	*rtail = tail;
	return copy;
}

static
PRE_COMMAND p_repeat
{
	XP tail,
	   rv = repeat(&tail);

	tail->next = G.holdtok;
	G.holdtok = rv;
}
#endif

static
PRE_COMMAND p_line
{
	D_(P, "p_line");

	G.tk_flags |= TK_LTSTR;		/* allow <......> */
	advnode();
	if cur_ne(ICON)
	{
		error("bad %sline", pwarn(isasm));
	othw
		line_no = cur->val.i;
		fadvnode();
		if is_scon(cur)
		{
			G.inctab->name = cur->name;
			G.inctab->nflgs.f.nheap = 0;
			freeXn(cur);
		}
	}
}


static
void pr_msg(Cstr w)
{
	send_msg("%s directive in %s L%ld ",  w, G.inctab->name, line_no);
	do
	{
		G.tk_flags |= TK_SEEWS;
		tok_next();
		send_name(curtok);
	}
	while tok_ne(NL);
}

static
PRE_COMMAND p_error
{
	pr_msg(Error);
	G.nmerrors++;
}

static
PRE_COMMAND p_warn
{
	pr_msg(Warning);
	G.nmwarns++;
}

static
PRE_COMMAND p_message
{
	pr_msg(Message);
	G.nmmessages++;
}


static
PRE_COMMAND p_W
{
	pr_msg(W);
	G.nmmessages++;
	Cconin();
}

static
PRE_COMMAND p_fatal
{
	pr_msg(Fatal);
	error("compilation abandoned\n");
	G.nmerrors = G.e_max_errors+1;
}

static
PRE_COMMAND p_ragma
{
	tok_next();
	if (tok_is(WS))
		tok_next();

#if 1
	if (tok_is(ID))
	{
		Cstr s = curtok->name;

	#if PRLN
		if (stricmp(s, "prln") eq 0)
		{
			if (G.To_prln)		/* 10'14 v5.2 */
				print_node(G.To_prln, "#pragma prln", 1, 1);
		}
		else
	#endif
		while (*s)
		{
			if   (*s eq 'r')	G.pragmats.noregs = false;
			elif (*s eq 'R')	G.pragmats.noregs = true;
			elif (*s eq 'n')	G.pragmats.new_peep = false;
			elif (*s eq 'N')	G.pragmats.new_peep = true;
			s++;
		}
	}
#else
	while (tok_is(ID))
	{
		Cstr s = curtok->name;

	#if PRLN
		if (stricmp(s, "prln") eq 0)
		{
			if (G.To_prln)		/* 10'14 v5.2 */
				print_node(G.To_prln, "#pragma prln", 1, 1);
		}
		else
	#endif
	if   (strcmp(s, "noregs"   ) eq 0)	G.pragmats.noregs   = false;
	elif (strcmp(s, "regs"     ) eq 0)	G.pragmats.noregs   = true;
	elif (strcmp(s, "nonewpeep") eq 0)	G.pragmats.new_peep = false;
	elif (strcmp(s, "newpeep"  ) eq 0)	G.pragmats.new_peep = true;
	s++;

		tok_next();
		if (tok_is(WS))
			tok_next();
	}
#endif
	tok_to_nl(true);		/* after nl */
}



#if FOR_A
void subdef(Cstr);
void adddef(Cstr);

static
PRE_COMMAND p_toA
{
	G.lang = 'a';
	if (G.v_Cverbosity)
		message(0, 0, "A syntax");
	subdef("__C__");
	subdef("__A__");
	adddef("__A__=1");
	tok_to_nl(true);
}

static
PRE_COMMAND p_toC
{
	G.lang = 'c';
	if (G.v_Cverbosity)
		message(0, 0, "C syntax");
	subdef("__A__");
	subdef("__C__");
	adddef("__C__=1");
	tok_to_nl(true);
}
#endif

static
CMDS pcmds[] =
{
	{"endif",	5,	p_swit,	ENDIF  },
	{"else",	4,	p_swit,	ELSE   },
	{"fi",		2,	p_swit,	ENDIF  },
	{"define",	6,	p_def,	NO_NEST},
	{"undef",	5,	p_undef,NO_NEST},
	{"include",	7,	p_inc,	NO_NEST},
	{"if",		2,	p_if,	IF     },
	{"ifdef",	5,	p_if,	IFDEF  },
	{"ifndef",	6,	p_if,	IFNDEF },
	{"elif",	4,	p_elif,	ELIF   },
	{"line",	4,	p_line,	NO_NEST},
	{"pragma",	6,	p_ragma,NO_NEST},
	{"error",	5,	p_error,NO_NEST},
	{"warn",	4,	p_warn, NO_NEST},
	{"warning",	7,	p_warn, NO_NEST},		/* 03'09 */
	{"fatal",	5,	p_fatal,NO_NEST},
	{"message", 7,	p_message,NO_NEST},
	{"wait",    4,  p_W,	NO_NEST},
	{"macro",	5,	p_macro,NO_NEST},
#if BIP_ASM
	{"ifne",	4,	p_if,	B_NE   },
	{"iff",		3,	p_if,	B_EQ   },
	{"ifeq",	4,	p_if,	B_EQ   },
	{"ifle",	4,	p_if,	B_LE   },
	{"iflt",	4,	p_if,	B_LT   },
	{"ifge",	4,	p_if,	B_GE   },
	{"ifgt",	4,	p_if,	B_GT   },
	{"endc",	4,	p_swit,	ENDIF  },
	{"rept",	4,	p_repeat,NO_NEST},
	{"repeat",	6,	p_repeat,NO_NEST},
#endif
#if FOR_A
	{"A",		1,	p_toA,	NO_NEST},
	{"C",		1,	p_toC,	NO_NEST},		/* runtime syntax shift */
	{"W",		1,	p_W,	NO_NEST},		/* message with wait */
#endif
	{0}
};

global
bool is_swit(LEX_RECORD *r)		/* Only called if G.in_S */
{
	CMDS *cp = pcmds;
	while (cp->text)
	{
		if (   (cp->pproc eq p_swit or cp->pproc eq p_if)
		    and stricmp(r->text, cp->text) eq 0				/* 04'12 HR stricmp */
		   )
			return true;

		++cp;
	}
	return false;
}

short cmpl(const char *s1, const char *s2, short l);

/* Only used by editor */
global
bool is_pre_kw(char *s, short l)
{
	CMDS *cp = pcmds;
	while (cp->text)
	{
		if (cmpl(s, cp->text, l) eq 0)
			return true;
		++cp;
	}
	return false;
}

#if BIP_ASM
global
void S_pre(Cstr s)
{
	CMDS *cp = pcmds;

	while (cp->text)
		if (stricmp(s, cp->text) eq 0)
		{
			if (G.iftab->p.truth or cp->kind ne NO_NEST)
				cp->pproc(cp, 1);
			break;
		}
		else
			cp++;

}
#endif

global
void C_pre(Cstr s)
{
	CMDS *cp = pcmds;

	while (cp->text)
	{
#if BIP_ASM
		if ((G.lang eq 's' ? stricmp : strcmp)(s, cp->text) eq 0)
#else
		if (strcmp(s, cp->text) eq 0)
#endif
		{
			if (G.iftab->p.truth or cp->kind ne NO_NEST)
			{
				freeXn(curtok);			/* after tok_next() */
				cp->pproc(cp, 0);
			}

			break;
		}
		else
			cp++;
	}

	if (cp->text eq nil)
		error("unknown %.12s directive: '%s'", expects, curtok->name);
}

static
void dopound(void)
{
	G.tk_flags |= TK_SEENL;

	if (tok_next() ne ID)
	{
		if tok_ne(NL)
			error("%s directive", expects);
		return;		/* empty # line */
	}

	C_pre(curtok->name);
	G.tk_flags &= TK_SAWNL;		/* keep nl flag */
	return;
}

#if 0
void pr_exp(XP ep, XP rv, short level, short which)
{
	message(0,0,"expanded [%d]level %d %s -->", which, level, rv->name);

	ep = ep->tseq;
	while (ep)
	{
		send_msg("\t%s\n", ep->name);
		ep = ep->next;
	}

	Cconin();
}
#endif

#if BIP_ASM and FOR_A
#include "getnode.h" /* text w/o #if's for clarity */
#else
static
XP getnode(void)
{
	XP rv, dp;
	rv = hi_node();

	if (rv eq nil)
		rv = to_endof();
	elif (G.in_if_X and strcmp(rv->name, "defined") eq 0)	/* ANSI 'defined' is treated as unary operator. */
	{
		G.skip_id = true;		/* do not expand very next identifier */
		rv->token = DEFINED;
	}
#if FOR_A
	elif (G.in_if_X and strcmp(rv->name, "declared") eq 0)
	{
		G.skip_id = true;		/* do not expand very next identifier */
		rv->token = DECLARED;
	}
#endif
	elif (rv->token eq ID)
	{
		if (G.skip_id)		/* expand inhibited na 'defined' */
			G.skip_id = false;
#if BIP_ASM
		elif (!(G.lang eq 's' and G.skip_X))
#else
		else
#endif
		{
			if (rv->nflgs.f.nexp eq 0)
			{
				if ((dp = tlook(deflist[hash(rv->name)], rv)) ne nil)
#if BIP_ASM
					if (expand(dp, &G.holdtok, G.lang eq 's'))
#else
					if (expand(dp, &G.holdtok, false))
#endif
					{
						freeXn(rv);
						rv = getnode();
					}
			}

			if (! (   (    rv->name[0] eq '_'
			           and rv->name[1] eq '_'
			           and builtin(rv)
			          )
			       or rv->cflgs.f.ided
			      )
			   )
				kw_tok(rv);
		}
	}

	return rv;
}
#endif

#define T (unsigned char)

static
short un_escape(Cstr in, Wstr smal, short l)	 /* this must be done after #param usage */
{
	short c;
	short nhave = 0;
	Wstr s = smal;

	while (l > 0)		/* 07'15 v5.2 l > 0 in stead of l != 0 */
	{
		c = *in++; l--;

		if (c eq ESCAPE)
		{
			if (C_oct[T*in])
			{
				short n = 0, i = 0;

				while (C_oct[T*in] and i++ < 3)
					n = (n<<3) + (*in++ - DIGITNAUGHT), l--;
				c = n;
			}
			elif (tolower(*in) eq HEXPREF)
			{
				short n = 0, i = 0, h;

				c = *++in, l--;
				while ( (h = ishexa(c)) >= 0 and i++ < 2)
					n = (n<<4) + h, c = *++in, l--;
				c = n;
			}
			else
				c = is_escape(*in++), l--;
		}

		*s++ = c, nhave++;
	}

	*s = 0;
	return nhave;
}

/* escapes in string only at this stage */

static
void fix_ascon(XP xp)
{
	long v = 0;
	short nhave;
	char smal[32], *mal = smal;

	if (xp->val.i > 30)
	{
		error("ascii constant very wide");
		xp->val.i = 6;
	}
	elif (xp->val.i < 2)
	{
		xp->val.i = 0;
		error("ascii constant inomplete %ld", xp->val.i);
		return;
	}

	nhave = un_escape((char*)xp->name + 1, smal, xp->val.i - 2);

	if (nhave > 4)
		warnn(xp, "ascii constant too wide");
	xp->token = ICON;

	while (nhave--)
		v <<= 8,
		v  |= (*mal++)&0xff;

	xp->val.i = v;
}

/* escapes in string only at this stage */
static
void fix_scon(XP xp)
{
	Wstr smal;

	if (xp->val.i < 2)
	{
		error("incomplete string literal (%ld)",xp->val.i);
		xp->val.i = 0;
		name_to_str(xp, "");
		return;
	}

	smal = CC_xmalloc(xp->val.i + 1, AH_FIX_SCON, CC_ranout);

	if (smal)
	{
		short nhave;

		nhave = un_escape((char*)xp->name + 1, smal, xp->val.i - 2);
		free_name(xp);
		xp->val.i = nhave;
		xp->nflgs.f.nheap = 1;
		xp->name = smal;
	}
}

static
void fix_scon1(XP xp)		/* no special chars in #include string */
{
	Wstr smal;

	if (xp->val.i < 2)
	{
		error("incomplete include string");
		xp->val.i = 0;
		name_to_str(xp, "");
		return;
	}

	smal = CC_xmalloc(xp->val.i, AH_FIX_SCON1, CC_ranout);

	if (smal)
	{
		short nhave = xp->val.i - 2;

		strmaxcpy(smal, xp->name + 1, nhave);
		if (xp->token eq SCON1)
			xp->token = SCON;		/* for rest of compiler */
									/* < ... > string still seperate token */
		free_name(xp);
		xp->val.i = nhave;
		xp->nflgs.f.nheap = 1;
		xp->name = smal;
	}
}

global
void advnode(void)		/* definitely after ALL preprocessing */
{
	if ( G.nmerrors > G.e_max_errors or G.nmwarns > G.f_max_warnings)
	{
		freeXn(G.holdtok);
		G.holdtok = nil;			/* dont want to use nonlocal jmp */
									/* because compiler can be builtin procedure and */
									/* therefore doesnt use exit() so we must clear all memory neatly */
		cur = to_endof();
	othw
		XP xcur = getnode();
		if	 (   xcur->token eq WS
			  or xcur->token eq DELETE
			  or xcur->token eq DLAST		/* 03'09 */
			 )
		{
			freeXn(xcur);
			advnode();
		}
		elif (   xcur->token eq BADTOK)	/* delayed discarding of irregular tokens */
		{
			if (xcur->name)
				error("illegal char '%c'(%#X)", *xcur->name, *xcur->name);
			else
				error("illegal character");
			freeXn(xcur);
			advnode();
		othw
			cur = xcur;
#if BIP_ASM
			if (!(G.lang eq 's' and G.skip_X))
#endif
/*			if (is_scon(cur))	/* 07'15 v5.2 */
*/			{
				if   (   cur->token eq SCON and (G.tk_flags&TK_LTSTR))
					fix_scon1(cur);
				elif (   cur->token eq SCON1
					  or cur->token eq SCON2)
					fix_scon1(cur);
				elif (   cur->token eq SCON)
					fix_scon(cur);
				elif (   cur->token eq ASCON)
					fix_ascon(cur);
			}
			G.tk_flags &= ~TK_LTSTR;
		}
	}
}

global
void fadvnode(void)
{
	if (cur->nflgs.f.free eq 0)		/* already freed */
		freeXn(cur);
	advnode();
}

global
TP tpcur(void)
{
	TP tp = allocTn(1);
	*(XP)tp = *cur;
#if NODESTATS
	G.xcopied++;
#endif
	set_line_no(tp);
	cur->nflgs.f.nheap = 0;
	tp->nt = TLNODE;		/* after above struct assignment. */
	freeXunit(cur);
	return tp;
}

global
NP npcur(void)
{
	NP np = allocnode(EXNODE);
	*(XP)np = *cur;
#if NODESTATS
	G.xcopied++;
#endif
	if (is_scon(np))
		np->size = np->val.i,
		np->val.i = 0;
	set_line_no(np);
	cur->nflgs.f.nheap = 0;
	np->nt = EXNODE;		/* after above struct assignment. */
	freeXunit(cur);
	return np;
}
