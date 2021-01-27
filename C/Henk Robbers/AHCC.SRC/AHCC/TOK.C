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

#define CHECK_TAB 0

/*	tok.c
 *
 *	Basic level token routines
 *
 *	Read lines and splice lines
 *
 *	Then:
 *	at this level, we return the following things:
 *		id's - strings of alpha-alnum
 *		integer constants
 *		real constants
 *		string constants
 *		multi-char tokens
 *
 *	We DONT know about:
 *		keywords
 *		#defined id's
 *		any other meaning of a name
 *
 *	Interface:
 *		call tok_next() to get next token
 *		look at 'curtok' for current token
 *		if EOF is seen, we call end_L0_file() before
 *		  giving up
 *
 *	Special flags:  (tk_flags)
 *		These special flags are needed for the pre-processor.
 *		All but TK_SEENL are 1-shot.
 *
 *		TK_SEENL - want to see \n
 *		TK_SEEWS - want to see white space (for #define).
 *		TK_LTSTR - '<' is a string starter
 *		TK_ONLY1 - skip to token after \n  (for #if--)
 *
 *	Discarding of white space and other irregular tokens
 *		is delayed and performed by advnode() (in EXPR.C)
 *		DELETE token introduced to get things smoother.
 *		Escape sequences in strings are now dealt with AFTER ALL preprocessing
 *			by advnode()
 */


#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <tos.h>
#include <ctype.h>

#include "common/dict.h"
#include "param.h"			/* basic definitions NB: token enums til LASTTOK */
#include "expr.h"
#include "e2.h"				/* for #if expressions */
#include "c_lex.h"
#include "pre.h"
#include "tok.h"

#define ONE_ERROR 0

#if FLOAT
static
VP curdbl;
#endif

global
LEX_RECORD * cur_LEX;			/* tokenizing */

#define debugP (G.xflags['p'-'a'])
#define debugB (G.xflags['b'-'a'])
#define debug_b (G.yflags['b'-'a'])

typedef LEX_RECORD *DO_TOKEN(LEX_RECORD *r, LEX_RECORD *n, XP tokcur);

typedef struct catagories
{
	char name[4];
	DO_TOKEN *do_tok;
} CATTBL;

DO_TOKEN
	do_eof,
	do_ide,
	do_dig,
	do_dig,
	do_nl,
	do_op,
	do_op2,
	do_op3,
	do_bad,
	do_ws,
	do_ws,
	do_quo,
	do_apo
	;

static
CATTBL cattbl[] =
{
	"eof", do_eof,
	"ide", do_ide,
	"oct", nil,
	"dig", do_dig,
	"hex", do_dig,
	"spl", nil,
	" nl", do_nl,
	"com", do_ws,
	" op", do_op,
	"mop", nil,
	"op2", do_op2,
	"op3", do_op3,
	"  X", do_bad,
	" ws", do_ws,
	"quo", do_quo,
	"apo", do_apo,
	"cok", nil,
	"last",nil
};

static
struct in_out
{
	short in,out;
} trigraphs[] =
{
	{'=','#'},
	{'/',ESCAPE},
	{'\'','^'},
	{'(','['},
	{')',']'},
	{'!','|'},
	{'<','{'},
	{'>','}'},
	{'-','~'},
	{0,0}
};

static
struct in_out
escapes[] =
{
	{LETTERALRM,ALARM    },
	{LETTERBS,  BACKSPACE},
	{LETTERNL,  NEWLINE  },
	{LETTERHT,  HORTAB   },
	{LETTERCRT, CARRETURN},
	{LETTERFF,  FORMFEED },
	{LETTERVT,  VERTAB   },
	{0,0}
};

static
char ctrans(short c, struct in_out io[])
{
	short i;
	for (i = 0; io[i].in; i++)
		if (c eq io[i].in)
			return io[i].out;
	return c;
}


global
char is_escape(short c)
{
	return ctrans(c, escapes);
}

global
char is_tri(short c)
{
	return ctrans(c, trigraphs);
}

global
char ishexa(short c)
{
	if ( c >= DIGITNAUGHT and c <= DIGITNINE )
		return (c-DIGITNAUGHT);
	c = tolower(c);
	if ( c >= DIGITTEN and c <= DIGITFIFTEEN )
		return (c-DIGITTEN+10);
	return -1;
}

static
long tok_dig(LEX_RECORD *r)
{
	long val = 0;
	char *s = r->text;

	while (*s)
		val = (val*10)+(*s++ - DIGITNAUGHT);

	return val;
}

#if LL
static
__ll tok_digll(LEX_RECORD *r)
{
	__ll val = {0,0};
	char *s = r->text;

	while (*s)
	{
		ushort c = *s++ - DIGITNAUGHT;
		val = _ullsmul(val, 10, c);		/* c is added to the result */
	}

	return val;
}
#endif

static
long tok_oct(LEX_RECORD *r)
{
	long val = 0;
	char *s = r->text;

	while (*s)
		if (*s <= DIGITSEVEN)
			val = (val<<3)+(*s++ - DIGITNAUGHT);
		else
		{
			error("illegal octal digit in '%s'", r->text);
			return 0;
		}

	return val;
}

#if LL
static
__ll tok_octll(LEX_RECORD *r)
{
	__ll val = {0,0};
	char *s = r->text;

	while (*s)
		if (*s <= DIGITSEVEN)
		{
			ushort c = (uchar)*s++ - DIGITNAUGHT;
			val = _ullsmul(val, 8, c);		/* c is added to the result */
		othw
			error("illegal octal digit in '%s'", r->text);
			val.hi = 0;
			val.lo = 0;
		}

	return val;
}
#endif

static
long tok_hex(LEX_RECORD *r)
{
	long val = 0;
	char *s = r->text;

	s += 2;				/* we know its 0x */
	while (*s)
	{
		char c = ishexa(*s++);
		val = (val<<4)+ c;
	}

	return val;
}

#if LL
static
__ll tok_hexll(LEX_RECORD *r)
{
	__ll val = {0,0};
	char *s = r->text;

	s += 2;				/* we know its 0x */
	while (*s)
	{
		ushort c = (uchar)ishexa(*s++);
		val = _ullsmul(val, 16, c);		/* c is added to the result */
	}

	return val;
}
#endif

#define is_point(r) ((r)->cat eq op and *(r)->text eq DECIMALP)

static
bool is_digits(char *s)
{
	while(*s)
		if (*s < DIGITNAUGHT or *s > DIGITNINE)
			return false;
		else
			s++;
	return true;
}

#if FLOAT
static
bool is_exp(LEX_RECORD *r)
{
	return r->cat eq ide and tolower(*r->text) eq Exponent;
}

static
bool is_L_or_F(char c)
{
	c = tolower(c);
	return c eq REALTOK or c eq LONGTOK;
}

static
bool is_LF(LEX_RECORD *r)	/* L, F, LF, FL */
{
	char *s = r->text;
	if (r->cat eq ide)
	{
		/* 03'11 HR: NB! rl includes \0 character */
		if (r->rl-size_LEX eq 2 and is_L_or_F(*s))
			return true;
		if (    r->rl-size_LEX eq 3
		    and is_L_or_F(* s)
		    and is_L_or_F(*(s+1))
		   )
			return true;
	}

	return false;
}

/* tok_real always starts with a dig */
static
LEX_RECORD * tok_real(LEX_RECORD *r, LEX_RECORD *n, char *f)
{
	bool okp = is_point(n),
	     oke = is_exp(n);

	if (!okp and !oke)
		return false;

	strcpy(f, r->text);

	if (okp)
	{
		strcat(f, n->text);
		r = next_LEX(n);
		if (r->cat eq dig)
		{
			strcat(f, r->text);
			LEX_next(r);
		}

		oke = is_exp(r);
	}
	else
		r = n;

	if (oke)
	{
		strcat(f, r->text);
		if (tolower(*(f + strlen(f) -1)) ne Exponent)		/* 11'11 HR!!! 1e-1, 1E+1 */
			LEX_next(r);
		else					/* single e allows for +/- */
		{
			LEX_next(r);
			if (     r->cat eq op
		        and (   *r->text eq MINUSSIGN
		             or *r->text eq PLUSSIGN
		            )
		       )
			{
				strcat(f, r->text);
				LEX_next(r);
			}
			if (r->cat eq dig)
			{
				strcat(f, r->text);
				LEX_next(r);
			}
		}
	}

	if (is_LF(r))
		LEX_next(r);		/* following L or F or both is OK */

	curtok->token = RCON;
	curdbl = allocVn(RLNODE);
	curdbl->rval = atof(f);
	curtok->val.dbl = curdbl;

	return r;
}
#endif

#define ASP 0		/* precedence of assign operators; until now 0 */

global
Cstr graphic[TOKSIZE];
global
TOKEN *C_tok  [TOKSIZE];

#if CHECK_TAB
global
TOKEN *dup_tok[TOKSIZE];
#endif

/*  if flag=ASOP: add  precedence to token value,
				  add  ASSIGN     to token value,
			  and move ASP        to precedence
*/

#define DEF_LEX 1
global
LEX C_lex[] =
{
#include "defs.h"
	{0}
};
#undef DEF_LEX

#define DEF_TAB 1

global
TOKEN tok_tab[] =
{
#include "defs.h"
	{0}
};

#if CHECK_TAB
global
TOKEN dup_tab[] =
{
#include "defs.h"
	{0}
};
#endif

#undef DEF_TAB

static
LEX *op_lex[256],
	*kw_lex[256];
#if FOR_A
LEX	*ow_lex[256];
#endif

char graphemp[] = "???";

short alert_text(char *, ...);

static
void mo_init(void)
{
	LEX *pt;
	uint c;

extern void prntypesize(void);

/*
prntypesize();
alert_text(" LASTTOK %d | size of tok_tab | %ld/%ld = %ld", LASTTOK, sizeof(tok_tab),sizeof(TOKEN), sizeof(tok_tab)/sizeof(TOKEN));
*/
	for (c = 0; c < 256;     c++) op_lex [c] = 0;
	for (c = 0; c < TOKSIZE; c++) C_tok  [c] = 0, graphic[c] = graphemp;
#if CHECK_TAB
	for (c = 0; c < TOKSIZE; c++) dup_tok[c] = 0;
#endif
	pt = C_lex;
	while (pt->text)
	{
		short tok = pt->value;
		if (!C_tok[tok])
		{
			  C_tok[tok] = &tok_tab[tok-FIRST_OP];
#if CHECK_TAB
			dup_tok[tok] = &dup_tab[tok-FIRST_OP];
#endif
		}
		if (strcmp(graphic[tok], graphemp) eq 0)
		{
			graphic[tok] = pt->text;
			  C_tok[tok]->text = pt->text;
#if CHECK_TAB
			dup_tok[tok]->text = pt->text;
#endif
		}

		if (*pt->text and !is_alpha(*pt->text))
		{
			c = (uchar)pt->text[0];
			if (!op_lex[c])
				 op_lex[c] = pt;
		}
		pt++;
	}
}

static
void kw_init(void)
{
	LEX *pt;
	uint c;

	for (c = 0; c<256; c++) kw_lex[c] = 0
#if FOR_A
						  , ow_lex[c] = 0
#endif
						;
	pt = C_lex;
	while (pt->text)
	{
		if (*pt->text and is_alpha(*pt->text))
		{
			c = pt->text[0];
#if ! FOR_A
			if (kw_lex[c] eq 0)
				kw_lex[c] = pt;
#else
			if (tok_tab[pt->value-FIRST_OP].flags&KWD)	/* All 'KW' macro calls for tok_tab */
			{
				if (kw_lex[c] eq 0)
					kw_lex[c] = pt;
			othw
				if (ow_lex[c] eq 0)
					ow_lex[c] = pt;
			}
#endif
		}
		pt++;
	}
}

static
void take(XP tp, TOKEN *tok, LEX *lex)
{
	tp->token = tok->value;
	tp->cat0  = tok->cat0;
	tp->cat1  = tok->cat1 | lex->cx;
#if FLOAT
	tp->cflgs.f.rlop = (tok->flags&RLOP) ne 0;
	tp->cflgs.f.cfop = (tok->flags&CFOP) ne 0;
#endif
	tp->cflgs.f.leaf = (tok->flags&LEAF) ne 0;
	tp->cflgs.f.s_ef = (tok->flags&S_EF) ne 0;
	free_name((NP)tp);
	tp->name = lex->text;
}

static
void node_from_op(XP tp, LEX *kp)
{
	short tok = kp->value;
	TOKEN *ct;

#if BIP_ASM
	if (G.lang eq 's')
		if (tok eq NOT)			/* 'unary !' --> 'unary ~', PASM compable */
			tok = BINNOT;
#endif

	ct  = C_tok[tok];
	if (ct->flags&ASOP)
	{
		tok += ct->prec;
		tp->prec = ASP;
		tok = ASSIGN tok;
	othw
		tp->prec = ct->prec;
	}

	take(tp, ct, kp);
	tp->zflgs.i = 0;

#if FOR_A
	if (tok eq IS and G.lang ne 'a')
		tok = ASS;
#else
	if (tok eq BECOMES)
	{
		warn("'%s' is not C; Assume '%s'", graphic[BECOMES], graphic[ASS]);
		tok = ASS;
	}
#endif
	tp->token = tok;
}

static
void to_id(XP tp, short which)			/* then library software or ID */
{
/*	message(0, 1, "[%d]to_id %s", which, prtok(tp));
*/	tp->token   = ID;
	tp->cflgs.i = 0;
	tp->cat0    = 0;
	tp->cat1    = 0;
	tp->cflgs.f.ided = 1;	/* prevent from matching again */
}

static
void tok_BAD(void) { curtok->token = BADTOK; }

static
void tok_op(LEX_RECORD *r)
{
	uchar c = *r->text;
	LEX *pt = op_lex[c];

	if (pt)
	{
		/* the single char operator is always the last (or the only :-) */
		while (*(pt->text + 1) ne 0) pt++;

		node_from_op(curtok, pt);

#if NODESTATS
		G.operators++;
#endif
		return;
	}

	tok_BAD();
}

static
void tok_op3(LEX_RECORD *r)
{
	Cstr s = r->text, t;
	uchar c = *s;
	LEX *pt = op_lex[c];

	if (pt)
	{
		/* the triple char operator is always the first and the only :-) */
		if (*(pt->text + 2) ne 0)
		{
			t = pt->text;
			if (    *(s+1) eq *(t+1)
			    and *(s+2) eq *(t+2)
			   )
			{
				node_from_op(curtok, pt);
#if NODESTATS
				G.operators++;
#endif
				return;
			}
		}
	}

	tok_BAD();
}

static
void tok_op2(LEX_RECORD *r)
{
	uchar c = *r->text, d;
	LEX *pt = op_lex[c];

	if (pt)
	{
		/* the triple char operator is always the first (or the only :-) */
		if (*(pt->text + 2) ne 0)
			pt++;
		while(   pt->text
		      and *pt->text eq c
		      and (d = *(pt->text + 1)) ne 0
		     )
		{
			if (*(r->text+1) eq d)
			{
				node_from_op(curtok, pt);
#if NODESTATS
				G.operators++;
#endif
				return;
			}
			pt++;
		}
	}

	tok_BAD();
}

global
void tok_init(void)
{
	static bool in = false;
	if (!in)
	{
		mo_init();
		kw_init();
		in = true;
	}

}

short cmpl(const char *s1, const char *s2, short l);
									/* l at least 1 */

bool is_pre_kw(char *s, short l);

global
short is_bold_word(void *bc, char *s)
/* Determine if a word in source is a reserved word.
   Used by the editor for displaying these in bold. */
{
	LEX *kp;
	char *to = s; long l;
#if BIP_ASM
	while (is_alnum(*to)) to++;
#else
	while (islower(*to)) to++;
	if (!is_alpha(*to))
#endif
	{
		uint u = *(uchar *)s;
		l = to-s;

		if (l)
		{
			kp = kw_lex[u];

			if (kp)
				while (kp->text)
				{
					short i = cmpl(s, kp->text, l);
					if ( i eq 0)
						return l;
					elif (i < 0)
						break;
					++kp;
				}

	#if FOR_A
			kp = ow_lex[u];

			if (kp)
				while (kp->text)
				{
					short i = cmpl(s, kp->text, l);
					if ( i eq 0)
						return l;
					elif (i < 0)
						break;
					++kp;
				}
	#endif

			if (is_pre_kw(s, l))
				return l;
		}
	}
	return -1;
}

static
LEX *find_kw(Cstr s, LEX *lex[], short flag)
{
	LEX *kp = lex[*(uchar *)s];
	if (kp)
	{
		while (kp->text)
		{
			if ((tok_tab[kp->value-FIRST_OP].flags&flag) eq 0)
			{
				short i = strcmp(s, kp->text);
				if (i eq 0) return kp;
				if (i <  0) return nil;
			}
			kp++;
		}
	}
	return nil;
}

global
void kw_tok(XP tp)			/* NB!!!!! after macro expansion */
{
	LEX *kp = find_kw(tp->name, kw_lex, 0);
	if (kp)
	{
		TOKEN *tok = C_tok[kp->value];
		tp->prec  = tok->prec;		/* 12'13 HR: v5 */
		take(tp, tok, kp);
		/* The only one needed after macro expansion */
		if (!G.use_FPU and tp->cflgs.f.rlop)
			to_id(tp, 3);
	}
}


#if FOR_A
global
void ow_tok(XP tp)			/* NB!!!!!! before macro expansion */
{
	LEX *kp = find_kw(tp->name, ow_lex, KWD);

	if (kp)
		node_from_op(tp, kp);
}
#endif

static
short tok_EOF(void)
{
	curtok->token = EOFTOK;
	name_to_str(curtok, "end of file");
	return EOFTOK;
}

static
short tok_NL(void)
{
	curtok->token = NL;
	name_to_str(curtok, "\n");
	G.tk_flags &= TK_KEEP;			/* 03'09 */
	G.tk_flags |= TK_SAWNL;
	return NL;
}

extern
char in_name[];

static
bool end_L0_file(void)
{
	VP ip = G.inctab;
	VpV cur_name;
	char *sp;

	if (ip->p.lvl eq 0)
	{
		if (!G.iftab)			/* in optdef() no endof's here */
			return false;
		if (G.iftab->p.nest)
			error("%d %sendif%s missing", G.iftab->p.nest, graphic[PREP], pluralis(G.iftab->p.nest));
		strcpy(G.input_name.s, G.inctab->name);
		return true;		/* EOF */
	}

	delete_from_cache(ip->name, G.ac_cache_headers);		/* 12'09 HR: for ST */

	G.inctab = ip->next;
	ip->next = nil;
	freeVn(ip);

	DIRcpy(&G.includer, G.inctab->name);
	sp = strrslash(G.includer.s);
	if (sp)
		*(sp+1) = 0;
	else
		G.includer.s[0] = 0;			/* 09'11 HR */

	line_no = G.inctab->vval;
	cur_name();
	cur_LEX = G.inctab->p.cur_LEX;

	G.tk_flags |= TK_SAWNL;    /* 03'09 */
	return false;
}

/* these are called from within the preprocessor */
global
void tok_to_nl(bool after)
{
	LEX_RECORD *r = cur_LEX;

	if (SAW_NL)
		SEEN_NL;
	else
	{
		while (r->cat ne nl)
		{
			if (r->cat eq eof)
				break;
			else
				LEX_next(r);
		}

		if (r->cat eq eof)
			if (end_L0_file())
			{
				tok_EOF();
				cur_LEX = r;
				return;
			}
			else
				r = cur_LEX;
		{
			char *o = r->text;
			if ((long)o & 1)
				o++;
			line_no = *(long *)o;
		}

		if (after)
		{
			LEX_next(r);
			G.tk_flags |= TK_SAWNL;    /* 03'09 */
		}
	}

	if (r->cat eq ws)	/* skip spaces after nl */
		LEX_next(r);

	cur_LEX = r;
}

static
bool find_hardnl(void)
{
	LEX_RECORD *r = cur_LEX;

	while (r->cat ne eof)
	{
		if (r->cat eq nl)
			break;

		LEX_next(r);
	}

	if (r->cat eq eof)
		if ( end_L0_file() )
			return false;
		else
			r = cur_LEX;

	{
		char *o = r->text;
		if ((long)o & 1)
			o++;
		line_no = *(long *)o;
	}

	cur_LEX = next_LEX(r);

	return true;
}

static
char * pr_tk(void)
{
	static char b[40];
	short f = G.tk_flags;

	b[0]=0;
	if   (f & TK_SEENL)
		strcat(b, "SEENL|");
	if (f & TK_SEEWS)
		strcat(b, "SEEWS|");
	if (f & TK_SAWNL)
		strcat(b, "SAWNL|");
	if (b[0])
		*(b + strlen(b) -1) = 0;
	return b;
}

bool is_swit(LEX_RECORD *r);

global
short tok_prep(void)
{
	LEX_RECORD *r;

	if (SAW_NL)
		SEEN_NL;
	elif (!find_hardnl())
		return tok_EOF();

	do{
		r = cur_LEX;
		while(r->cat eq ws)		/* skip spaces after nl */
			LEX_next(r);

#if BIP_ASM
		if (    G.xlang eq 's'
		    and r->cat eq ide	/* 10'10 HR else endif endc fi */
			and is_swit(r)
		   )
			return PREP;
#endif
		if (r->cat eq op and *r->text eq PREPWARN)
		{
			tok_op(r);		/* found a single # */
			cur_LEX = next_LEX(r);
			return curtok->token;
		}

		if (!find_hardnl())
			return tok_EOF();
	}od		/* until prep  or EOF */
}

#include "tok_do.h"		/* DO_TOKEN functions via cattbl[] */

static
LEX * get_kw(XP tp)
{
	LEX *kp;

		kp = find_kw(tp->name, op_lex, 0);
	if (!kp)
		kp = find_kw(tp->name, kw_lex, 0);
#if FOR_A
	if (!kp)
		kp = find_kw(tp->name, ow_lex, 0);
#endif
	return kp;
}

static
short get_cat(XP tp)
{
	LEX *kp = get_kw(tp);
	if (kp)
		return kp->cx;
	return 0;
}

static
short get_tok(XP tp)
{
	LEX *kp = get_kw(tp);
	if (kp)
		return kp->value;
	return -1;
}

static
void make_id(XP xp, short flag0, short flag1)
{
	if (flag0)
	{
		if (xp->cat0&flag0)
		{
			to_id(xp, 1);
			return;
		}
	}
	if (flag1)
	{
		LEX * tok = get_kw(xp);
		if (tok)
		{
			TOKEN *tk = C_tok[tok->value];
			if (tk)
			{
				short cat = (tk->cat0&XC) ? tok->cx : tk->cat1;

				if (cat&flag1)
					to_id(xp, 3);
			}
		}
	}
}


#if CHECK_TAB
global
short check_tab(TOKEN *i, TOKEN *o, long l)
{
	short t = 0;
	while (l>0)
	{
		if (i->text ne o->text)
			if (i->text ne 0 and o->text ne 0)
				if (strcmp(i->text, o->text) ne 0)
					return 1;
		if (i->cat0 ne o->cat0)
			return 2;
		if (i->cat1 ne o->cat1)
			return 3;
		i++;
		o++;
		t++;
		l--;
	}

	return 0;		/* OK */
}
#endif

Cstr prtok(void *);

global
short tok_next(void)
{
#if ONE_ERROR
	if (G.nmerrors)
		return tok_EOF();
#endif

	if (curtok->nt ne STNODE)		/* token unused */
		curtok = allocXn(1);		/* 1: with clear */

	curtok->token = NOTOK;
	curtok->nflgs.f.nheap = 1;		 /* special case: no name yet */

	do
	{
		LEX_RECORD *this, *nxt; CATTBL *ctb;

		line_no = n_line_no;			/* 03'09 (was out of loop) */


		this = cur_LEX;
#if BIP_ASM
		if (G.lang eq 's')
			G.tk_flags |= TK_SEENL; /* tok_NL */
#endif
		nxt = next_LEX(this);

		ctb = cattbl + this->cat;
		if (ctb and ctb->do_tok)
			cur_LEX = cattbl[this->cat].do_tok(this, nxt, curtok);
		else
		{
			error("CE: invalid token index");
			return tok_EOF();
		}
	}
	while tok_is(NOTOK);			/* mostly not requested white space and newline ~(TK_SEEWS|TK_SEENL) */

#if C_DEBUG
	if break_in						/* <RSHIFT+LSHIFT> */
		return tok_EOF();
#else
	{
		static long breaks = 0;
		breaks++;
		if (breaks&0xfffffe00)		/* once every 512 tokens */
		{
			breaks = 0;
			if break_in
				return tok_EOF();
		}
	}
#endif
#if CHECK_TAB
	{
		short i = check_tab(tok_tab, dup_tab, sizeof(tok_tab)/sizeof(TOKEN));
		if (i)
			message(0, 1, "CORRUPTION %s @ %d r=%d", prtok(curtok), i);
	}
#endif

#if FOR_A or FLOAT or BIP_ASM
	if (curtok->token eq ID)
	{
	#if FOR_A
		if (G.lang ne 'a')
			make_id(curtok, 0, A_KW);	/* some A_KW tokens are C tokens as well */
	#endif
	#if FLOAT
		if (!G.use_FPU)
			make_id(curtok, 0, F_KW);
	#endif
	#if BIP_ASM
		if (G.lang ne 's')
			make_id(curtok, 0, S_KW);
	#endif
	}
#endif
	return curtok->token;
}
