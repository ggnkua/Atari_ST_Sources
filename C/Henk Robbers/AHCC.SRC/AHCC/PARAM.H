/* Copyright (c) 1988 by Sozobon, Limited.  Author: Johann Ruegg
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
 *	param.h
 */

short alert_text(char *t, ... );

/*	host language prelude */

#ifndef PRELUDE_H
	#include <prelude.h>
#endif

#define fslash '/'
#define sfslash "/"
#define bslash '\\'
#define sbslash "\\"

#define NO_INT 1		/* make int synonymous to either short or long */

#if C_DEBUG
	#define CE 1			/* output compiler errors (more permanently than debugging) */
	#define NODESTATS 1		/* count nodes	*/
#else
	#define CE 0
	#define NODESTATS 0
#endif

/* Optimizer integrated (V1)
   Advices are implemented as opcodes
   (see also rta, rtf (return areg, return freg  etc)
*/

#ifdef __TURBOC__
	long bios(void, ...);
#endif

/*  development stages for GEM integration (BIP is for BuiltIn Procedure)
 *	compiler:
 *		29 nov 93		console and debug output to journal window
 *      30 nov 93       input via shell
 *		 1 dec 93		output changed --> send_out(char *, ...)
 *		 5 dec 93		output via shell
 *		   dec 93		All output via addcode/outcode/outsub.
 *		   mrt 97		Pure C calling; massive work for optimizer
 *  	   may 97		#A syntax
 *	optimizer:
 *		dec 94			(IXC) Interchange code for integration of optimizer
 *	    may 95          now integrated part of compiler
 *	assembler:			use PASM (Pure Assembler)
 *		may 98			preparations for integration in optimizer
 *		jan 05			start writing freestanding full asm from scratch
 *	loader:				can use PLINK  (Pure linker)
 *  	dec 03			start writing from scratch so it can be built in.
 *	AHCC:
 *		jan 09			Published on my homepage
 */

#if BIP_CC				/* look who's calling */
	#ifdef TTPSHELL
		#define      AHCC compiler		/* integrated in GEM shell */
		#define EXIT_AHCC return
		typedef FILE AHCOUT;
	#else
		#define      AHCC compiler		/* integrated in GEM shell */
		#define EXIT_AHCC return
		typedef void AHCOUT;
	#endif
#else

	#define      AHCC main			/* freestanding TTP program */
	#define EXIT_AHCC exit
	typedef FILE AHCOUT;
	#define ENVINC 1				/* also scan environment for include paths */
#endif

#if BIP_LD
	#define      AHCL linker		/* integrated in GEM shell */
	#define EXIT_AHCL(r) return r
#else
	#define      AHCL main			/* freestanding TTP program */
	#define EXIT_AHCL(r) send_msg(">\t");bios(2,2); return(r)
#endif

#define WARN_AREA '#'
#if C_DEBUG
#undef TRACE
#define TRACE(a) send_msg("= " #a " %ld =-\n", lineno), Cconin()
#undef RTR
#define RTR(a,b) send_msg("-= " #a " %d =-\n", b->r1)
#endif

extern bool last_k,MagX,MiNT;
extern AHCOUT *bugf;
extern Cstr class_names[];

short is_alpha(short c);	/* as ctype, but including underline :-) */
short is_alnum(short c);

#if !(__ABC__ || __AHCC__)
	#define __FPU__	1	/* if host uses FPU (this is for PURE C) */
#endif

/*	end prelude					> */

#define UNDERLINE	'_'
#define ESCAPE		'\\'
#define DBLSTART	'"'
#define DBLSTREND   '"'
#define DOUBLESTART 0362
#define DOUBLEEND 	0363	/* balance (make different) */
#define SINGLESTART 0364
#define SINGLEEND   0365	/* balance (make different) */
#define LQUOTED     "\362"
#define RQUOTED     "\363"

#define break_in (Kbshift(-1)==3)
#define cur_is(tok) (cur->token eq tok)
#define cur_ne(tok) (cur->token ne tok)
#define gwiden(x)	((x) eq 1 ? 2 : (x))
#define cntcpy(i,dest,src) {string __s=src,__d=dest;(i)=0; while ((*__d++=*__s++)!=0) (i)++;}
#define loccpy(dest,src) {string __s=src,__d=dest; while ((*__d++=*__s++)!=0);}
#define locncpy(dest,src,n) {string __s=src,__d=dest;short __i=n; while(__i--) *__d++=*__s++;}

enum
{
	NORMAL, CAST, FUNC
};

enum
{
/* The hardware sizes related to 68K assembler size field */
	DOT_B	= 1,
	DOT_W	= 2,
	DOT_L	= 4,
	DOT_S	= 4,
	DOT_LL  = 8,
	DOT_D   = 8,
	DOT_X	= 12,
	DOT_P	= 16,
	DOT_STR = 8,

/* sizes of basic types; mapping of hardware sizes to type sizes */

	SIZE_B	= DOT_B,	/* bool */
	SIZE_C	= DOT_B,	/* char */
	SIZE_I	= DOT_W,	/* int */
	SIZE_S	= DOT_W,	/* short */
	SIZE_L	= DOT_L,	/* long */
	SIZE_LL = DOT_LL,	/* long long */
	SIZE_U	= DOT_W,	/* unsigned */
	SIZE_F	= DOT_S,	/* float */
	SIZE_X	= DOT_X,	/* real */
	SIZE_D  = DOT_D,	/* 64 bit real */
	SIZE_P	= DOT_L,	/* pointer */
	SIZE_STR= DOT_STR,	/* AC sized string */

/* alignment requirements */

	ALN_B	= 0,	/* bool */
	ALN_C	= 0,	/* char */
	ALN_I	= 1,	/* int */
	ALN_S	= 1,	/* short */
	ALN_L	= 1,	/* long */
	ALN_LL	= 1,	/* long long */
	ALN_U	= 1,	/* unsigned */
	ALN_F	= 1,	/* short real (float) */
	ALN_D	= 1,	/* real       (double 64) */
	ALN_X	= 1,	/* real       (double 80) */
	ALN_P	= 1,	/* pointer */
	ALN_A	= 1		/* aggregate */	/* 01'14 v5.1 */
};

typedef struct def
{
	Cstr dname, dval;
} DEFS;

typedef struct			/* basic types */
{
	Cstr text;
	short 	size;
	char	align;
	char	type;
} BASTAB;

/* standard AHCC areas (slightly more then for Pure C)
   G..._area  :: global
    ..._area  :: static
   A..._area  :: anonymous local  */

typedef struct area_info
{
	short 	class;	/* storage class of area    */
	short 	id;		/* area number              */
	long	disp;	/* displacement within area */
} AREA_INFO;

typedef struct vreg_info
{
	uchar r, l;
	short s;
} VREG_INFO;

enum
{
	NO_class,		/* mostly external names */
	start_class,
	TEXT_class = start_class,
	DATA_class,
	GDATA_class,
	STR_class,
	CON_class,
	BSS_class,
	GBSS_class,
	OFFS_class,
	high_class		/* Here start extra area numbers */
};

typedef struct
{
	long outl,		/* current size of output buffer (used by realloc) */
	     size;		/* current total size of described objects */
	Wstr start,
	     out;		/* current output position in buffer */
	short id, class;	/* area number, class */
	char name[256];
} AREAS;

typedef struct area_scope
{
	struct area_scope *next;
	AREAS ar[high_class];
} AREA_STACK;

/*
 *	basic parameters
 */
enum
{
	MAXERRS  = 25,
	MAXWARNS = 50
};


#define PTRDIFF_T	T_LONG		/* must reflect ptrdiff_t in stddef.h	*/
#define SIZE_T		T_ULONG		/*      "       size_t			"		*/

/* I think this size_t is very important on a 32 bit computer */

#define ONY(flag) G.yflags[flag-'a']=1	/*	dynamic debugging */
#define ONX(flag) G.xflags[flag-'a']=1
#define OFFY(flag) G.yflags[flag-'a']=0
#define OFFX(flag) G.xflags[flag-'a']=0

/* bugprint a single word */
#if BIP_CC		/* have journal so we can scroll */
	#define bpr(a) paragraph(a)
#else			/* directly on screen: as compact as is possible */
	#define bpr(a) send_msg(a "\t")
#endif

#if C_DEBUG		/* invoke extensive debugging info (for the compiler itself) */
	extern short pstk;
	void paragraph(Cstr a);
	#define D_(z,s) if (debug ## z) bpr(s)	/* paragraph tracer */
	#define C(s) "\t;\t" #s
	#define REGLIST 1

	#if CE			/* invoke compiler internal errors */
		#define CE_(s) error("CE: " s)
		#define CE_N(n,s) errorn(n,"CE: " s)
		#define CE_X(s,x) error("CE: " s,x)
		#define CE_NX(n,s,x) errorn(n,"CE: " s,x)
	#else
		#define CE_(s)
		#define CE_N(n,s)
		#define CE_X(s,x)
		#define CE_NX(n,s,x)
	#endif

#else

	#define D_(z,s)
	#define C(s)
	#define REGLIST 0

	#define CE_(s)
	#define CE_N(n,s)
	#define CE_X(s,x)
	#define CE_NX(n,s,x)

#endif

#define NHASH 1009
#define for_TRUE 0
#define for_FALSE 1
#define STACKALN 1

typedef struct
{
	Cstr text;	/* --> lex */
	short flags;
	ushort cat0;	/* keyword categories */
	uchar  cat1;	/* Pure C doesnt support long enums */
	uchar prec;		/* precedence */
	short value;	/* conceptual token set */
	short x;		/* cross references if applicable */
	short l;
} TOKEN;

typedef struct
{
	Cstr text;	/* currently chosen graphic set for this particular */
	short value;    /* implementation of the A, C and assembler programming language */
	ushort cx;		/* S_KW, A_KW, F_KW or empty or else */
} LEX;

extern Cstr graphic[];
extern TOKEN *C_tok  [];
extern LEX    C_lex  [];

typedef enum
{
	NO_PHASE,
	COMPILING,
	OPTIMIZING,
	LINKING
} CC_PHASE;

extern CC_PHASE phase;

/* usage for registers */
/* Nota Bene! The ordering of these is NOT arbitrary */
typedef enum
{
	D0,
	FIRSTREG	= D0,
	DREG		= D0,
	D1,
	D2,
	D3,
	DRV_START	= D3,
	D4,
	D5,
	D6,
	D7,
	DRV_END		= D7,
	Dhigh       = D7,
	F0,
	FREG        = F0,
	F1,
	F2,
	F3,
	FRV_START	= F3,
	F4,
	F5,
	F6,
	F7,
	FRV_END		= F7,
	Fhigh       = F7,
	A0,
	AREG        = A0,
	A1,
	A2,
	ARV_START	= A2,
	A3,
	A4,
	A5,
	ARV_END		= A5,
	A6,
	FRAMEP		= A6,
	A7,
	SP          = A7,
	Ahigh       = A7,
	LASTREG		= A7,
	Rinv
} ACC;

enum
{
	MAXD = DRV_START-DREG,		/* ic 3 */
	MAXA = ARV_START-AREG,		/*    2 */
	MAXF = FRV_START-FREG,		/*    3 */
/* for argregs */
	AMAXD = DRV_END-DRV_START+1,		/* ic 5 */
	AMAXA = ARV_END-ARV_START+1,		/*    4 */
	AMAXF = ARV_END-ARV_START+1,		/*    5 */

/* construct masks for detecting presence of register variable registers */
	VARDM = ((1<<(DRV_END-DREG+1))-1)&~((1<<(DRV_START-DREG))-1),
	VARAM = ((1<<(ARV_END-AREG+1))-1)&~((1<<(ARV_START-AREG))-1),
	VARFM = ((1<<(FRV_END-FREG+1))-1)&~((1<<(FRV_START-FREG))-1),

/* construct masks for detecting usage of work regs */
	WRKDM = (1<<(DRV_START-DREG))-1,
	WRKAM = (1<<(ARV_START-AREG))-1,
	WRKFM = (1<<(FRV_START-FREG))-1
};

#define max_A G.scope->b_regs.a
#define max_D G.scope->b_regs.d
#define max_F G.scope->b_regs.f

#define MSKD 0xffffff00
#define MSKA 0xff00ffff
#define MSKF 0xffff00ff

#define DM (RMASK)VARDM
#define AM ((RMASK)VARAM<<16)
#define FM ((RMASK)VARFM<<8)
#define WDM (RMASK)WRKDM
#define WAM ((RMASK)WRKAM<<16)
#define WFM ((RMASK)WRKFM<<8)

/* definition of stack frame */
#define ARG_BASE	8
#define LOC_BASE	0

/*
 * tokens.h
*/

#define B_FLAGS(f0,f1,f2,f3,f4,f5,f6,f7) FLAG(f0,1)FLAG(f1,2)FLAG(f2,4)FLAG(f3,8)FLAG(f4,0x10)FLAG(f5,0x20)FLAG(f6,0x40)FLAG(f7,0x80)

#define W_FLAGS(f0,f1,f2,f3,f4,f5,f6,f7,f8,f9,fa,fb,fc,fd,fe,ff) FLAG(f0,1)\
FLAG(f1,2)FLAG(f2,4)FLAG(f3,8)FLAG(f4,0x10)FLAG(f5,0x20)FLAG(f6,0x40)FLAG(f7,0x80)FLAG(f8,0x100)\
FLAG(f9,0x200)FLAG(fa,0x400)FLAG(fb,0x800)FLAG(fc,0x1000)FLAG(fd,0x2000)FLAG(fe,0x4000)FLAG(ff,0x8000)

#define L_FLAGS(f0,f1,f2,f3,f4,f5,f6,f7,f8,f9,fa,fb,fc,fd,fe,ff,f10,f11,f12,f13,f14,f15,f16,f17,f18,f19,f1a,f1b,f1c,f1d,f1e,f1f) FLAG(f0,1)\
FLAG(f1,2)FLAG(f2,4)FLAG(f3,8)FLAG(f4,0x10)FLAG(f5,0x20)FLAG(f6,0x40)FLAG(f7,0x80)FLAG(f8,0x100)\
FLAG(f9,0x200)FLAG(fa,0x400)FLAG(fb,0x800)FLAG(fc,0x1000)FLAG(fd,0x2000)FLAG(fe,0x4000)FLAG(ff,0x8000)FLAG(f10,0x10000)\
FLAG(f11,0x20000)FLAG(f12,0x40000)FLAG(f13,0x80000)FLAG(f14,0x100000)FLAG(f15,0x200000)FLAG(f16,0x400000)FLAG(f17,0x800000)FLAG(f18,0x1000000)\
FLAG(f19,0x2000000)FLAG(f1a,0x4000000)FLAG(f1b,0x8000000)FLAG(f1c,0x10000000)FLAG(f1d,0x20000000)FLAG(f1e,0x40000000)FLAG(f1f,0x80000000)

/*	flags &
	conceptual tokens;
	dec en hex values: zie token listing opt -T	*/

#define DEF_ENUM 1			/* context for defs.h */
#define ALL_FLAGS 1
#define DEF_TOKS 1

enum
{
#include "defs.h"
	LASTTOK
};

#define TOKMASK	0x1ff
#define ASSIGN	0x200+
#define TOKSIZE (TOKMASK+1)

#if LASTTOK > TOKMASK
#error highest token > TOKMASK
#endif

#define FIRST_OP BLOCK
#define LAST_OP K_LAST

#define FIRST_MONOP FABS
#define BR_TOK  (B_EQ-1)

#define CALL	PAREN
#define LABEL	X_ELSE	/* erg he? in C al dat dubbele gebruik 	<	*/
#define FIELD	X_ELSE
#define DECLREF TIMES
#define DECLDEREF BINAND
#define TO_STR	PREP	/* ANSI: #param --> "param" */
#define ADDRESS BINAND	/*										>	*/

#define WITH_F 0		/* 02'17 HR: v5.6, analyze [2]arg nil */
#define M_TO_F 0		/* 02.17 HR: v5.6, nacros to functions */

#if M_TO_F
bool is_ass(short t);
bool is_ass_op(short t);
bool is_assignment(short t);
#elif WITH_F
#define is_ass(t)        ((t) eq ASS or (t) eq FIELDAS)
#define is_ass_op(t)     ((t) >= ASSIGN 0)
#define is_assignment(t) ((t) eq ASS or t eq FIELDAS or is_ass_op(t))
#else
#define is_ass(t)        ((t) eq ASS)
#define is_ass_op(t)     ((t) >= ASSIGN 0)
#define is_assignment(t) ((t) eq ASS or is_ass_op(t))
#endif


/* The following macros are type indifferent */
#define is_scon(x)  ((x)->token >= ASCON and (x)->token <= SCON2)
#define is_immed(np) ((np)->eflgs.f.imm)
#define un_immed(np) (np)->eflgs.f.imm = 0

extern TOKEN tok_tab[];

#define OP_N(y)			(C_tok[(y)]->text)
#define OP_X(y)			(C_tok[(y)]->x)
#define OP_F(y)			(C_tok[(y)]->flags)
#define KW_C(y)			(C_tok[(y)]->cat0)
#define is_C(x)			((x) >= FIRST_OP and (x) <= LAST_OP)

#define is_aggreg(x)	(((x)->cat0&AGGREG) ne 0 or (x)->ty eq ET_A)
#define is_sclass(x)	((x)->cat0&SC)
#define is_tadj(x)		((x)->cat0&TYP_M)
#define is_xadj(x)		((x)->cat0&EXT_M)
#define is_plain(x)		((x)->cat0&PLAIN)
#define is_basic(x) 	((x)->cat0&BASIC)
#define is_tykw(x)		((x)->cat0&DECL)
#define is_end(x)		(((x)->cat0&ST_E) or (x)->token eq KCOLB)
#define is_stkw(x)		((x)->cat0&(BR_ST|LB_ST|BL_ST))
#define is_brast(x)		((x)->cat0&BR_ST)
#define is_blkst(x)		((x)->cat0&BL_ST)
#define is_lblst(x)		((x)->cat0&LB_ST)
#define is_code(x)		((x)->cat0&CODE)

#define is_func(x)      ((x) eq T_PROC or (x) eq L_PROC)
#define is_op(x)		((x)->cat0&OPAT)

#define is_sreg(x)		((x)->cat1&SREG)
#define is_asreg(x)		((x)->cat1&ASREG)

#define is_compare(x)	(is_C(x) and (OP_F(x)&COMPARE))
#define is_C_NA(x)		(is_C(x) and (OP_F(x)&C_NA))
#define is_C_A(x)		(is_C(x) and (OP_F(x)&C_A))
#define is_C_A_NA(x)	(is_C(x) and (OP_F(x)&(C_A|C_NA)))
#define is_unop(x)		(is_C(x) and (OP_F(x)&UNOP))

typedef unsigned long int RMASK;
extern RMASK reserve, inhibit, argused;

#define yfreg(np)		((np)->rno >= FREG and (np)->rno <= Fhigh)
#define yareg(np)		((np)->rno >= AREG)
#define ydreg(np)		((np)->rno <= Fhigh)
#define ISF(x)          ((x)       >= FREG and (x)       <= Fhigh)
#define ISA(x)          ((x)       >= AREG)
#define	ISD(x)          ((x)       <= Fhigh)
#define	RM(x)           (1L << (x))			/* form a register mask */

#define ISDonly(x)		((x) >= DREG and (x) <= Dhigh)
#define ISFonly(x)		ISF(x)
#define ISAonly(x)		((x) >= AREG and (x) <= Ahigh)

#define WORKX			(RM(A0)|RM(A1)\
                        |RM(D0)|RM(D1)|RM(D2)\
                        |RM(F0)|RM(F1)|RM(F2))

#define EXTRAREGS       (RM(A7)|RM(A6)|RM(A5)|RM(A4)|RM(A3)|RM(A2)\
                        |RM(F7)|RM(F6)|RM(F5)|RM(F4)|RM(F3)\
                        |RM(D7)|RM(D6)|RM(D5)|RM(D4)|RM(D3))

#define isareg(np)		((np)->token eq REGVAR and yareg(np))
#define isdreg(np)		((np)->token eq REGVAR and ydreg(np))
#define isfreg(np)		((np)->token eq REGVAR and yfreg(np))
#define istdreg(np)		((np)->token eq REGVAR and (np)->rno <  DRV_START)

#define is_icon(tok)	((tok) eq ICON)
#define is_hw_fp(ty)	((ty) eq ET_R and  G.use_FPU)
#define is_sw_fp(ty)	((ty) eq ET_R and !G.use_FPU)
bool	is_sw_dbl		(void *vp);
bool    is_ll			(void *vp);
#define is_conv(np)		((np)->token >= IMPCNV and (np)->token <= ARGCNV)
bool	is_con			(short);
#define side_cc(np)		(np->eflgs.f.cc = 1)
#define reverse(i)		((i&1) ? i+1 : i-1)		/* truth rversion on branch token */

/* values for e_type */
enum
{
	E_LEAF		=	0,			/* no descendants (MUST be the zero one so it is the default after allocnode() ) */
	E_UNARY,					/* left node is expr, no right node */
	E_BIN,						/* left and right are expr */
	E_BINARY	=	E_BIN,

	E_SPEC,						/* special '(', '[', '.', '->', ... */

/* evaluation order values */
	EV_NONE		= E_LEAF,		/* !NOT! accidentally the same */
	EV_LEFT		= E_UNARY,
	EV_RIGHT	= E_BIN,

	NO_EV,						/* tt not used for eval order */
	EV_LR,
	EV_RL,
	EV_LRSEP,					/* left then right, but seperate */
	EV_RLSEP,					/* right then left, but seperate ( for args ) */

/* types of operands -- ordered in cast strength order */
	ET_CC   =   1,		/* boolean result in condition code register */
#if FLOAT
	ET_FC,				/*   "        "           "          "       for float; return condition code for compare (complete le ge etc) */
	ET_XC,				/*   "        "           "          "       for double */
#endif
	ET_B,				/* boolean variable */
	ET_S,				/* signed integer */
	ET_U,				/* unsigned integer */
	ET_P,				/* pointer */
#if FLOAT
	ET_R,				/* real */
#endif
	ET_A				/* aggregate */
};

enum		/* flow escape's */
{
	RET  = 1,
	RETV = 2,
	BRK  = 4,
	CNT  = 8,
	CLO  = 0x10,	/* loop is closed for(;;) while(1) etc */
	WILD = 0x20		/* goto */
};

#include "nodedefs.h"

#define is_nct(np)		((np)->nflgs.f.n_ct)		/* no copy type */
#define is_ct(np)       ((np)->nflgs.f.n_ct == 0)
#define to_nct(np)		 (np)->nflgs.f.n_ct = 1
#define not_nct(np)		 (np)->nflgs.f.n_ct = 0
#define type_is_not_a_copy to_nct
#define type_is_a_copy     not_nct


#define is_quick(x)			(   0 < (x) and (x) <= 8  )
#define is_signed_byte(x)	(-128 < (x) and (x) <= 128)
#define is_cardinal(x)		((x) eq ET_S or (x) eq ET_U)

#if C_DEBUG
void retreg(NP np, short r);
#else
#define retreg(np,r) 	np->token=REGVAR,np->rno=r
#endif

extern NP gp, gpbase;	/* code list & base; mostly for code outside expressions */

#if FOR_A
/* for A: need complete boolean expressions for enquiries ('if' and '?') */
#define AC_BOOL (R_CC | (G.lang eq 'a' ? 0 : R_SCALAR))
#else
#define AC_BOOL (R_CC|R_SCALAR)
#endif

enum				/* various */
{
/* restrictions on type */
/* R_CC: internal type bool */
	R_CC		= 1,
	R_INTEGRAL	= 2,
	R_FLOATING	= 4,
	R_POINTER	= 8,
	R_STRUCT	= 16,

/* catagories of restrictions on type */
	R_ARITH		= (R_INTEGRAL | R_FLOATING),
	R_SCALAR	= (R_ARITH    | R_POINTER),
	R_ASSN		= (R_CC       | R_SCALAR   | R_STRUCT),
	R_BIN		= (R_CC       | R_INTEGRAL),


	R_NOTHING   = 32,			/* ANSI: void */

/* contexts */

	NOCONTEXT   = 0,
	FORSIDE,
	FORPUSH,
	FORCC,
	FORIMA,
	FORADR,
	FORLVAL,			/* 12'08 HR usage tracking */
	FORINIT,
	IND0,				/* for return values */
	INF0,
	INA0,				/* argregs (Pure C compatible) */
	SWITCH,				/* for switch expression */
	RETSTRU,			/* all objects > DOT_L */
	FORLINIT,			/* ANSI local const init  */
	FORLAINIT,			/* ANSI local aggreg init */
	FORSTRINIT,			/* #A string init */
	FORVALUE,			/* #A primary block		*/
	FORTRUTH,			/* special context for #if expr. */
	FORASM,				/* various restrictions */
	FORSEE,				/* 12'08 HR usage tracking, special for see_id */
	HIGHCONTEXT,

			/* tokenizing stage flags */
	TK_SEENL		= 1,	/* want to see NL token - permanent shot */
	TK_SEEWS		= 2,	/* want to see WS token - single shot */
	TK_SAWNL		= 4,	/* newline seen */
	TK_LTSTR		= 8,	/* RIGHTHOOK starts a string */
	TK_KEEP         = TK_SEENL|TK_LTSTR		/* for cleaning single shot flags */
};


#define FIRST_BAS T_BOOL
#define LAST_BAS T_NTY


#undef DEF_ENUM
#undef ALL_FLAGS

#define SAW_NL (G.tk_flags &   TK_SAWNL)
#define SEEN_NL G.tk_flags &= ~TK_SAWNL

extern XP cur, curtok;

typedef struct
{
	long  bytes,  lines, I, H,
	     cbytes, clines, hbytes, hlines,
	     start,  limit,  time,   files;
} STATS;

#include "ahcc_pro.h"
#include "ahcc.h"
#include "nodes.h"
#include "io.h"
#include "diagpr.h"
#include "common.h"
