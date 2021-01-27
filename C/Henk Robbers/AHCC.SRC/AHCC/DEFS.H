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

/* XP
 *  Macros to forge together the various attributes of things.
 *		Ruled by defining context.
 *
 *		DEFS.H
 *
 */

#undef FLAG
#undef DTOK
#undef KW
#undef KWOP
#undef KWS
#undef OP
#undef OPS

/* DEF_ENUM :: declare enum values */
/* DEF_LEX  :: create table holding ALL token texts (incl synonyms) for scanning */
/* DEF_DIAG :: create table of stringifyed enum values */
/* DEF_TOK  :: create full token table with ALL token attributes */

/* Note if DEF_ENUM is created first, one has a value LASTTAK defined
   (Can be used for checking of indici)
*/

#if DEF_ENUM					/* context */
	#define FLAG(e,p)			e=p,		/* for enums */
	#define DTOK(e)				e,
	#define OP(g,f,c,p,e,x)		e,
	#define OPS(g,cx,e)
	#define KW(g,f,c,cx,e,x)	e,
	#define KWOP(g,f,c,cx,p,e,x)	e,
	#define KWS(g,cx,e)
#elif DEF_LEX							/* for lex table */
	#define FLAG(e,p)					/* (the currently chosen actual graphic */
	#define DTOK(e)						/*	representation of tokens) */
	#define OP(g,f,c,p,e,x)		{g,e,0},
	#define OPS(g,cx,e)			{g,e,cx},
	#define KW(g,f,c,cx,e,x)	{g,e,cx},
	#define KWOP(g,f,c,cx,p,e,x)	{g,e,cx},
	#define KWS(g,cx,e)			{g,e,cx},
#elif DEF_DIAG
	#define FLAG(e,p)			#e,			/* for diagnostic printing */
	#define DTOK(e)				#e,
	#define OP(g,f,c,p,e,x)		#e,
	#define OPS(g,cx,e)
	#define KW(g,f,c,cx,e,x)	#e,
	#define KWOP(g,f,c,cx,p,e,x)	#e,
	#define KWS(g,cx,e)
#elif DEF_TAB								/* for tok info table */
	#define FLAG(e,p)
	#define DTOK(e)
	#define OP(g,f,c,p,e,x)		{0,f,c,0,p,e,x},
	#define OPS(g,cx,e)
	#define KW(g,f,c,cx,e,x)	{0,f|KWD,c,cx,0,e,x},
	#define KWOP(g,f,c,cx,p,e,x)	{0,f|KWD,c,cx,p,e,x},
	#define KWS(g,cx,e)
#endif

/* P_KW: only commentary: tokens that are defined in prelude.h.
         if !__ABC__ (move to ahcc_rt.h ????)
*/
#if ALL_FLAGS || DEF_K_FLAGS
/*		keyword catagories */
	W_FLAGS(AGGREG,SC,TYP_M,EXT_M,PLAIN,BASIC,DECL,BR_ST,
	        BL_ST,LB_ST,LP_ST,CODE,OPAT,ST_E,PMOD,XC)
	B_FLAGS(ASREG,SREG,C05,P_KW,A_KW,A_OP,F_KW,S_KW)
#endif

/* You see ?  ... synonyms are only in the LEX table.
			The cross indexes are found in tok.c */


#if ALL_FLAGS or DEF_TOK_FLAGS
/* token flags	*/

	W_FLAGS(ASOP,UNOP,RLOP,CFOP,C_NA,C_A,COMPARE,KWD,SPCL,LEAF,
	        S_EF,O11,O12,O13,O14,O15)

/*		RLOP			floating point monadic operator if FPU
		CFOP			idem available on Coldfire
		ASOP			is assign operator
		UNOP			is, or can be unary op
		SPCL			special token beginner
		C_NA			commutative but not associative
		C_A 			commutative and associative
		LEAF			leaf denotation
*/
#endif

#if ALL_FLAGS or DEF_X_FLAGS
/* eval flags derived from context */

	B_FLAGS(NOVAL_OK,CC_OK,IMMA_OK,C3,C4,C5,C6,C7)

/*		NOVAL_OK,	/* value is optional */
		CC_OK,		/* just setting cond. codes okay */
		IMMA_OK,	/* immediate OREG is okay */
*/
#endif

/*	operand classes */
#if ALL_FLAGS or DEF_A_FLAGS
	W_FLAGS(CL_DREG,CL_AREG,CL_ADR,CL_IMM,CL_ABS,CL_FREG,Af6,Af7,
	        RETAREG,RETDREG,RETLEFT,RETRIGHT,Af12,Af13,Af14,Af15)
#endif

#if ALL_FLAGS or DEF_M_FLAGS
/* modifier seen flags */

	B_FLAGS(
		SAW_SHORT,
		SAW_LONG,
		SAW_2LONG,
		SAW_UNS,
		SAW_SINGLE,
		SAW_DOUBLE,
		SAW_SIGNED,
		SAW_CONST
	)
#endif

#if DEF_TOKS
	#if DEF_ENUM
		RESETTOK = -1,
	#endif

	DTOK(BADTOK)		/* MUST be first!! */

/* branch types
	EQUALS,			here are the C tokens, so you can check the correct order of B_.. tokens below
	NOTEQ,
	LESS,
	GTEQ,
	LTEQ,
	GREATER,
   designed so that pairs (i,i+1) with odd i represent opposites */

	DTOK(B_EQ)			/* MUST follow BADTOK */
	DTOK(B_NE)
	DTOK(B_LT)
	DTOK(B_GE)
	DTOK(B_LE)
	DTOK(B_GT)
	DTOK(B_YES)
	DTOK(B_NO)
	DTOK(B_ULT)
	DTOK(B_UGE)
	DTOK(B_ULE)
	DTOK(B_UGT)

	DTOK(ERRNODE)

/*  used for storage class in nodes (not in DECL.C, no category);
	must produce positive char value */
	DTOK (PROT)
	DTOK (PROT_USED)
	DTOK (ENUM)

	/* reserved words and operaters */
	/* only grouped by 1st character and then sorted;
		(\0 is higher than everything else) */
	/*  for the sake of the #param usage put the , immediate before and after the param that is to be #'d;
		Pure C should remove trailing and leading white space, but it does not do so. */

	OP ("{",	0, 0, 0			,BLOCK, 0)	/* MUST be first */
	OP ("}",	0, 0, 0			,KCOLB, 0)
	OP ("[",	0, 0, 0			,ARRAY, 0)
	OP ("]",	0, 0, 0			,YARRA, 0)
	OP ("(",	0, 0, 0			,PAREN, 0)
	OP (")",	0, 0, 0			,NERAP, 0)
	OP ("####",	0, 0, 0			,END_MAC, 0)
	OP ("##",	0, 0, 0			,PARCAT, 0)
	OP ("#",	0, 0, 0			,PREP, 0)
	OP ("\\",	0, 0, 0			,BSLASH, 0)
	OP (";",	0, 0, 0			,ENDS, 0)
	OP (",",	0, 0, 0			,COMMA, 0)

#if FOR_A
	OP (":=",	0, 0, ASP		,ASS, 0)
#else
	OP (":=",	0, 0, ASP		,BECOMES,0)
#endif

	OP (":",	0, 0, 0			,X_ELSE, 0)

	KW ("...",	0,DECL|BASIC|PLAIN, 0 ,K_VARGL, 0)
	OP (".",	0, 0, 0			,SELECT, 0)

#if BIP_ASM
	OP ("@",	0, 0, 0			,ASM_SELECT, 0)
#endif

	OP ("\"",	SPCL, 0, 0		,QUOTE, 0)
	OP ("'",	SPCL, 0, 0		,APOS, 0)

	OP ("==",	C_NA|COMPARE,XC,7, EQUALS, B_EQ)

#if FOR_A
	OP ("=",	0, 0, ASP		,IS, 0)
#else
	OP ("=",	0, 0, ASP		,ASS, 0)
#endif

	OP ("++",	UNOP, 0, 0		,INCR, 0)
	OP ("+=",	ASOP, 0, +1		,ASPLUS, 0)
	OP ("+",	UNOP|C_A, 0,4	,PLUS, UPLUS)

	OP ("-=",	ASOP, 0, +3		,ASMINUS, 0)
	OP ("--",	UNOP, 0, 0		,DECR, 0)
	OP ("->",	0, 0, 0			,ARROW, 0)
	OP ("-",	UNOP, 0, 4		,MINUS, NEGATE)

	OP ("*=",	ASOP, 0, +1		,ASTIMES, 0)
	OP ("*",	UNOP|C_A, 0,2	,TIMES, DEREF)

#if FOR_A
	OP ("$",	UNOP, 0, 0		,STR, 0)
#endif
	OP ("%=",	ASOP, 0, +1		,ASMOD, 0)
	OP ("%",	0, XC, 2		,MOD, 0)

	OP ("/=",	ASOP, 0,+1		,ASDIV,0)
	OP ("/",	0, 0, 2			,DIV, 0)

	OP ("&&",	0, XC, 11		,AND, 0)
	OP ("&=",	ASOP, 0, +1		,ASBINAND, 0)
	OP ("&",	UNOP|C_A, 0,8	,BINAND, TAKE)

	OP ("|=",	ASOP, 0, +2		,ASBINOR, 0)
	OP ("||",	0, XC, 12		,OR, 0)
	OP ("|",	C_A, 0, 10		,BINOR, 0)

	OP ("!=",	C_NA|COMPARE, XC, 7 ,NOTEQ,B_NE)
	OP ("!",	UNOP, XC, 0			,NOT,0)

#if FOR_A
	OP ("~",	UNOP, 0, 0			,FLO, 0)
#else
	OP ("~",	UNOP, 0, 0			,BINNOT, 0)	/* 05'13 different meaning in ASM */
#endif
	OP ("^=",	ASOP, 0, +1			,ASBINEOR, 0)
	OP ("^",	C_A, 0, 9			,BINEOR, 0)

	OP ("<<=",	ASOP, 0, +1			,ASSHL, 0)
	OP ("<<",	0, 0, 5				,SHL, 0)
	OP ("<=",	C_NA|COMPARE, XC, 6 ,LTEQ, B_LE)
#if FOR_A
	OP ("<>",	0, 0, 5				,ROL, 0)
#endif
	OP ("<",	SPCL|C_NA|COMPARE, 0, 6, LESS, B_LT)

	OP (">>=",	ASOP, 0, +1			,ASSHR, 0)
	OP (">>",	0, 0, 5				,SHR,	0)

#if FOR_A
	OP ("><",	0, 0, 5				,ROR,	0)
#endif
	OP (">=",	C_NA|COMPARE, XC, 6	,GTEQ,   B_GE)
	OP (">",	C_NA|COMPARE, XC, 6	,GREATER,B_GT)

	OP ("?",	0, 0, 0				,X_THEN,0)
#
#
#
#
#if BIP_ASM
	KW ("a0",		LEAF, XC, ASREG|S_KW		,K_A0, 0)
	KW ("a1",		LEAF, XC, ASREG|S_KW		,K_A1, 0)
	KW ("a2",		LEAF, XC, ASREG|S_KW		,K_A2, 0)
	KW ("a3",		LEAF, XC, ASREG|S_KW		,K_A3, 0)
	KW ("a4",		LEAF, XC, ASREG|S_KW		,K_A4, 0)
	KW ("a5",		LEAF, XC, ASREG|S_KW		,K_A5, 0)
	KW ("a6",		LEAF, XC, ASREG|S_KW		,K_A6, 0)
	KW ("a7",		LEAF, XC, ASREG|S_KW		,K_A7, 0)
#endif

#if FOR_A
	KW ("after",	0, BL_ST|LP_ST,A_KW			,K_AFTER,0)
	OPS("and",		P_KW, AND)
#endif

	KW ("auto",		0, DECL|SC, 0				,K_AUTO,0)

#if 0 /* FOR_A */
	KWS("begin",	0							,BLOCK)
#endif

	KW ("break",	0, BR_ST, 0					,K_BREAK,0)

#if FOR_A
	KW ("by",		0, BL_ST|LP_ST,A_KW			,K_BY,0)
#endif

	KW ("case",		0, LB_ST, 0					,K_CASE,0)
	KW ("cdecl",	0, DECL|PMOD, 0				,K_CDECL,0)
	KW ("char",		0, DECL|BASIC|PLAIN,0		,K_CHAR,0)
#if FOR_A && FLOAT
	KW ("compl",	0, DECL|BASIC|PLAIN,A_KW	,K_COMPL,0)
	KWS("complex",	A_KW ,K_COMPL)
#endif
	KW ("const",	0, DECL, 0					,K_CONST,0)
	KW ("continue",	0, BR_ST, 0					,K_CONT,0)

#if BIP_ASM
	KW ("d0",		LEAF, XC, ASREG|S_KW		,K_D0,0)
	KW ("d1",		LEAF, XC, ASREG|S_KW		,K_D1,0)
	KW ("d2",		LEAF, XC, ASREG|S_KW		,K_D2,0)
	KW ("d3",		LEAF, XC, ASREG|S_KW		,K_D3,0)
	KW ("d4",		LEAF, XC, ASREG|S_KW		,K_D4,0)
	KW ("d5",		LEAF, XC, ASREG|S_KW		,K_D5,0)
	KW ("d6",		LEAF, XC, ASREG|S_KW		,K_D6,0)
	KW ("d7",		LEAF, XC, ASREG|S_KW		,K_D7,0)
#endif

#if FOR_A
	KW ("declared", 0, 0, A_KW				,DECLARED,0)	/* 04'09 just for fun */
#endif
	KW ("default", 	0, LB_ST, 0				,K_DEF,0)
	KW ("defined",	0, 0, 0					,DEFINED,0)

#if FOR_A
	KW ("deref",	0, DECL, A_KW			,K_DEREF,0)
#endif

	KW ("do",		0, BL_ST|LP_ST, 0		,K_DO,0)

#if FLOAT
	KW ("double",	0, DECL|EXT_M, 0		,K_DOUBLE,0)
#endif

#if FOR_A
	KW ("ebit",		0, DECL, 0				,K_EBIT, 0)
	KW ("elif",		0, ST_E, P_KW			,K_ELIF,0)
#endif

	KW ("else",		0, ST_E, 0				,K_ELSE,0)

#if 0 /* FOR_A */
	KWS("end",		0, KCOLB)
#endif

#if BIP_ASM
	KW ("endm",		XC, ST_E, S_KW			,K_ENDMAC, 0)
	KWS("endmac",	S_KW, K_ENDMAC)
	KWS("endr",		S_KW, K_ENDMAC)
#endif

	KW ("enum",		0, DECL, 0				,K_ENUM, 0)

#if FOR_A
	OPS("eq",		P_KW, EQUALS)
	KW ("esac",		0, ST_E|BR_ST, P_KW		,K_ESAC, 0)
#endif

#if FOR_A and FLOAT
	KW ("extended",	0, DECL|EXT_M,P_KW		,K_EXTENDED, 0)
#endif

	KW ("extern",	0, DECL|SC, 0			,K_EXTERN, 0)
	KW ("false",	LEAF, 0, P_KW			,K_FALSE, 0)

#if FOR_A
	KW ("fi",		0, ST_E, A_KW			,K_FI, 0)
#endif

#if FLOAT
	KW ("float",	0, DECL|BASIC|PLAIN, 0	,K_FLOAT, 0)
#endif

	KW ("for",		0, BL_ST|LP_ST, 0		,K_FOR, 0)

#if BIP_ASM and FLOAT
	KW ("fp0",		LEAF, 0, S_KW			,K_F0, 0)
	KW ("fp1",		LEAF, 0, S_KW			,K_F1, 0)
	KW ("fp2",		LEAF, 0, S_KW			,K_F2, 0)
	KW ("fp3",		LEAF, 0, S_KW			,K_F3, 0)
	KW ("fp4",		LEAF, 0, S_KW			,K_F4, 0)
	KW ("fp5",		LEAF, 0, S_KW			,K_F5, 0)
	KW ("fp6",		LEAF, 0, S_KW			,K_F6, 0)
	KW ("fp7",		LEAF, 0, S_KW			,K_F7, 0)
#endif

#if FOR_A
	KW ("from",		0, BL_ST|LP_ST,A_KW		,K_FROM, 0)
#endif

#if FOR_A
	OPS("ge",		P_KW, GTEQ)
#endif
#if FOR_A
	KW ("global",	0, DECL|SC, P_KW		,K_GLOBAL, 0)
#endif

	KW ("goto",		0, BR_ST, 0				,K_GOTO, 0)

#if FOR_A
	KW ("gref",		0, DECL,A_KW			,K_GREF, 0)
#endif

	KW ("if",		0, BL_ST, 0				,K_IF, 0)
	KW ("int",		0, DECL|BASIC|PLAIN,0	,K_INT, 0)

#if FOR_A
	KW ("inv",		0,0,0					,BINNOT, 0)
	OPS("le",		P_KW, LTEQ)
#endif

	KW ("long",		0, DECL|BASIC|TYP_M,0	,K_LONG, 0)

#if FOR_A
	OPS("ne",		P_KW, NOTEQ)
	KW ("nil",		LEAF, 0, P_KW			,K_NIL, 0)
	OPS("not",		P_KW, NOT)
	KW ("od",		0, ST_E, P_KW			,K_OD, 0)
	OPS("or",		P_KW, OR)
#endif

	KW ("pascal",	0, DECL|PMOD, 0			,K_PAS, 0)

#if BIP_ASM
	KW ("pc",		LEAF, XC, ASREG|S_KW	,K_PC, 0)
#endif

#if FOR_A
	KW ("proc",		0, DECL|CODE, A_KW		,K_PROC, 0)
	KW ("ref",		0, DECL, A_KW			,K_REF, 0)
#endif

	KW ("register",	0, DECL|SC, 0			,K_REG, 0)
	KW ("return",	0, BR_ST, 0				,K_RETURN, 0)

	KW ("short",	0, DECL|BASIC|TYP_M,0	,K_SHORT, 0)
	KW ("signed",	0, DECL|EXT_M, 0		,K_SIGNED, 0)

#if FOR_A and FLOAT
	KW ("single",	0, DECL|EXT_M,P_KW		,K_SINGLE, 0)
#endif

	KW ("sizeof",	0, 0, 0					,K_SIZEOF, 0)

#if BIP_ASM
	KWS("sp",		S_KW ,K_A7)
#endif

	KW ("static",	0, DECL|SC, 0			,K_STATIC, 0)

#if FOR_A
	KW ("string",	0, DECL|BASIC|PLAIN,A_KW		,K_STRING, 0)
#endif

	KW ("struct",	0, DECL|AGGREG, 0		,K_STRUCT, 0)
	KW ("switch",	0, BL_ST, 0				,K_SWITCH, 0)

#if FOR_A
	KW ("then",		0, ST_E, A_KW			,K_THEN, 0)
	KW ("to",		0, BL_ST|LP_ST, A_KW	,K_TO, 0)
#endif

	KW ("true",		LEAF, 0, P_KW			,K_TRUE, 0)

#if FOR_A
	KWS("type",		A_KW, K_TYPE)
#endif

	KW ("typedef",	0, DECL|SC|XC, 0		,K_TYPE, 0)
	KW ("union",	0, DECL|AGGREG, 0		,K_UNION, 0)
	KW ("unsigned",	0, DECL|BASIC|TYP_M, 0	,K_UNS, 0)

	KW ("void",		0, DECL|BASIC|PLAIN, 0	,K_VOID, 0)
	KW ("volatile",	0, DECL, 0				,K_VOLAT, 0)

#if FOR_A
	KW ("when",		0, ST_E, A_KW			,K_WHEN, 0)
#endif

	KW ("while",	0, BL_ST|ST_E|LP_ST, 0	,K_WHILE, 0)

#if BIP_ASM
	KWS("A0",		S_KW,K_A0)
	KWS("A1",		S_KW,K_A1)
	KWS("A2",		S_KW,K_A2)
	KWS("A3",		S_KW,K_A3)
	KWS("A4",		S_KW,K_A4)
	KWS("A5",		S_KW,K_A5)
	KWS("A6",		S_KW,K_A6)
	KWS("A7",		S_KW,K_A7)

	KWS("D0",		S_KW,K_D0)
	KWS("D1",		S_KW,K_D1)
	KWS("D2",		S_KW,K_D2)
	KWS("D3",		S_KW,K_D3)
	KWS("D4",		S_KW,K_D4)
	KWS("D5",		S_KW,K_D5)
	KWS("D6",		S_KW,K_D6)
	KWS("D7",		S_KW,K_D7)

#if FLOAT
	KWS("FP0",		S_KW,K_F0)
	KWS("FP1",		S_KW,K_F1)
	KWS("FP2",		S_KW,K_F2)
	KWS("FP3",		S_KW,K_F3)
	KWS("FP4",		S_KW,K_F4)
	KWS("FP5",		S_KW,K_F5)
	KWS("FP6",		S_KW,K_F6)
	KWS("FP7",		S_KW,K_F7)
#endif

	KWS("PC",		S_KW,K_PC)

	KWS("SP",		S_KW,K_A7)
#endif

	KW ("_Bool",	0, DECL|BASIC|PLAIN, 0	,K_BOOL, 0)

#if FLOAT
	KW ("_Real",	0,	DECL|BASIC|PLAIN, 0	,K_REAL, 0)
#endif

	KW ("__CR__",	LEAF, 	0, SREG			,K_CR, 0)	/* 12'11 */

#if FLOAT
	KW ("__FABS__",		RLOP|CFOP, 0, F_KW	,FABS, 0)
	KW ("__FACOS__",	RLOP, 0, F_KW		,ACOS, 0)
	KW ("__FASIN__",	RLOP, 0, F_KW		,ASIN, 0)
	KW ("__FATANH__",	RLOP, 0, F_KW		,ATANH, 0)
	KW ("__FATAN__",	RLOP, 0, F_KW		,ATAN, 0)

	KW ("__FCOSH__",	RLOP, 0, F_KW		,COSH, 0)
	KW ("__FCOS__",		RLOP, 0, F_KW		,COS, 0)
	KW ("__FETOXM1__",	RLOP, 0, F_KW		,ETOXM1, 0)
	KW ("__FETOX__",	RLOP, 0, F_KW		,ETOX, 0)
	KW ("__FGETEXP__",	RLOP, 0, F_KW		,GETEXP, 0)

	KW ("__FGETMAN__",	RLOP, 0, F_KW		,GETMAN, 0)
	KW ("__FINTRZ__",	RLOP|CFOP, 0, F_KW	,INTRZ, 0)
	KW ("__FINT__",	 	RLOP|CFOP, 0, F_KW	,INT, 0)
	KW ("__FLOG10__",	RLOP, 0, F_KW		,LOG10, 0)
	KW ("__FLOG2__", 	RLOP, 0, F_KW		,LOG2, 0)
	KW ("__FLOGNP1__",	RLOP, 0, F_KW		,LOGNP1, 0)
	KW ("__FLOGN__", 	RLOP, 0, F_KW		,LOGN, 0)

	KW ("__FNEG__",		RLOP|CFOP, 0, F_KW	,NEG, 0)
	KW ("__FPCR__",		LEAF, 0, SREG		,FPCR, 0)	/* 12'11 */
	KW ("__FPSR__",		LEAF, 0, SREG		,FPSR, 0)	/* 12'11 */
	KW ("__FSINH__",	RLOP, 0, F_KW		,SINH, 0)
	KW ("__FSIN__",		RLOP, 0, F_KW		,SIN, 0)

	KW ("__FSQRT__",	RLOP|CFOP, 0,F_KW	,SQRT, 0)
	KW ("__FTANH__",	RLOP, 0, F_KW		,TANH, 0)
	KW ("__FTAN__",		RLOP, 0, F_KW		,TAN, 0)
	KW ("__FTENTOX__",	RLOP, 0, F_KW		,TENTOX, 0)
	KW ("__FTWOTOX__",	RLOP, 0, F_KW		,TWOTOX, 0)
#endif

	KW ("__OP__",		0, DECL|CODE|OPAT, 0,K_OP, 0)
#if ! FOR_A
#if ROTOP
	OPS ("__ROL__", 0, ROL)
	OPS ("__ROR__", 0, ROR)
#else
	KWOP ("__ROL__",	0, 0, 0, 5, ROL, 0)	/* 12'13 v5 rotate left */
	KWOP ("__ROR__",	0, 0, 0, 5, ROR, 0)	/* 12'13 v5 rotate right */
#endif
#endif
	KW ("__SR__",		LEAF, 0, SREG		,K_SR, 0)	/* 12'11 */
	KW ("__UC__",		0, DECL|CODE|OPAT, 0,K_CAST, 0)



/* NB!! underline < lowercase !! */
	KW ("__asm__",		0, DECL|CODE|PMOD, 0,K_ASM, 0)

	OP ("__bswp__",		UNOP|S_EF, 0, 0	,BSWP, 0)		/* 03'09 */
	KW ("__delay__",	UNOP|S_EF, 0, 0	,DELAY, 0)		/* 05'13 v4.15 */
	OP ("__getsetsr__",	UNOP|S_EF, 0, 0	,GETSETSR, 0)	/* 03'09 */
	KW ("__ldsr__",		UNOP|S_EF, 0, 0	,GETSR, 0)		/* sr->ea 03'09 */
	KW ("__nop__",		LEAF, 0, 0				,K_NOP, 0)		/* 03'09 */
	KW ("__offsetof__",	0,    0, 0				,K_OFFSET, 0)	/* 03'09 */
	KWS("__o__",		0,	K_OFFSET)	/* 11' 13 */
	KW ("__rest__",		LEAF, 0, 0				,K_REST, 0)		/* 03'09 */
	KW ("__save__",		LEAF, 0, 0				,K_SAVE, 0)		/* 03'09 */
	OP ("__stop__",		UNOP|S_EF, 0, 0	,HALT, 0)		/* 03'09 */
	OP ("__stsr__",		UNOP|S_EF, 0, 0	,SETSR, 0)		/* ea->sr 03'09 */
	KW ("__syscall__",	0 ,DECL|PMOD, 0			,K_SYSC, 0)

/*					derived tokens */
	OPS("\362",		0, QUOTE)
	OPS("\364",		0, APOS)

/* same order as bas_def.h */
	KW ("", 0, DECL|BASIC, 0		,T_BOOL, 0)
	KW ("", 0, DECL|BASIC, 0		,T_CHAR, 0)
	KW ("", 0, DECL|BASIC, 0		,T_UCHAR, 0)
	KW ("", 0, DECL|BASIC, 0		,T_SHORT, 0)
	KW ("", 0, DECL|BASIC, 0		,T_USHORT, 0)
	KW ("", 0, DECL|BASIC, 0		,T_INT, 0)
#if FOR_A
	KW ("", 0, DECL|BASIC, 0		,T_DEF, 0)		/* default type */
#endif
	KW ("", 0, DECL|BASIC, 0		,T_UINT, 0)
	KW ("", 0, DECL|BASIC, 0		,T_LONG, 0)
	KW ("", 0, DECL|BASIC, 0		,T_ULONG, 0)
#if LL
	KW ("", 0, DECL|BASIC|AGGREG, 0	,T_LLONG, 0)
#endif

	KW ("", 0, 0, 0					,REFTO, 0)

#if FLOAT
	KW ("", 0, DECL|BASIC, 0		,T_FLOAT, 0)
	KW ("", 0, DECL|BASIC, 0		,T_REAL, 0)
#endif
#if FOR_A
	KW ("", 0, DECL|BASIC, 0	,T_STRING, 0)	/* 10'14 v5.2 */
	KW ("", 0, DECL|BASIC, 0	,T_COMPL, 0)
#endif

	KW ("", 0, DECL|BASIC, 0	,T_VARGL, 0)
	KW ("", 0, DECL|BASIC, 0	,T_VOID, 0)
	KW ("", 0, DECL|BASIC, 0	,T_NTY, 0)
#if FOR_A
	KW ("", 0, DECL|CODE,  0	,L_PROC, 0)	/* #A local procs */
#endif

	KW ("", 0, DECL|CODE,  0	,T_UNION, 0)	/* 10'14 v5.2 */
	KW ("", 0, DECL|CODE,  0	,T_STRUCT, 0)	/* 10'14 v5.2 */
	KW ("", 0, DECL|CODE,  0	,T_PROC, 0)		/* 10'14 v5.2 */

#if BIP_ASM
	KW ("", 0, 0, S_KW		,REGINDIRECT, 0)
	KW ("", 0, 0, S_KW		,REGINDPLUS, 0)
	KW ("", 0, 0, S_KW		,MINUSREGIND, 0)
	KW ("", 0, 0, S_KW		,REGINDISP, 0)
	KW ("", 0, 0, S_KW		,REGINDX, 0)
	KW ("", 0, 0, S_KW		,REGINDIM, 0)
	KW ("", 0, 0, S_KW		,ASMSCALE, 0)
	KW ("", 0, 0, S_KW		,INSTR, 0)
	KW ("", 0, DECL, S_KW	,K_AHEAD, 0)	/* forward referencing operand */
	KW ("", 0, DECL, S_KW	,K_LOCAL, 0)	/* LOCAL label in asm macros */
#endif

#if ! FOR_A		/* #A tokens that are internally usefull */
	KW ("", 0, ST_E, 0		,K_THEN, 0)
	KW ("", 0, DECL|SC, 0	,K_GLOBAL, 0)
#endif

 /* LAST_OP */
	KW ("", 0, 0, 0 ,K_LAST, 0)



	/* internal tokens */

	DTOK (FUSED)				/* ANSI: voor PARCAT catenated */
	DTOK (CATTED)				/* ANSI: voor PARCAT tokenized */
	DTOK (DELETE)				/* ANSI: voor TO_STR */
	DTOK (DPARAM)
	DTOK (EOFTOK)
	DTOK (FIELDAS)
	DTOK (ZERO)

	DTOK (ONAME)
	DTOK (OLNAME)
	DTOK (OREG)
	DTOK (PUSHER)
	DTOK (REGVAR)
	DTOK (O_ABS)
	DTOK (ICON)

#if FLOAT
	DTOK (FCON)				/* 32 bit float literals */
	DTOK (RCON)				/* 96 bit double loterals */
#endif

#if LL
	DTOK (LCON)				/* 01'09 HR long long constant */
#endif

#if COLDFIRE
	DTOK (COLDCON)			/* For coldfire: literals in a table (like RCONS and FCONS) */
#endif
							/* type conversions */
	DTOK (IMPCNV)			/* implicit */
	DTOK (EXPCNV)			/* explicit (casts) */
	DTOK (ARGCNV)			/* for pushing */

	DTOK (TSIZEOF)
	DTOK (TOFFSET)
	DTOK (MEMBER)
	DTOK (POSTINCR)
	DTOK (POSTDECR)
	DTOK (ARG)				/* COMMA in argument list */
	DTOK (PULL)				/* pull arguments in registers */
	DTOK (PULLARG)			/* pull 1 arg */
	DTOK (ARGP)				/* push struct return pointer. */
	DTOK (FUNF)				/* special COMMA for callee expression unfolding */

	/* unary use of otherwise binary operators	*/
	DTOK (DEREF)			/*   '*'   */
	DTOK (UPLUS)			/*   '+'   */
	DTOK (NEGATE)			/*   '-'   */
	DTOK (TAKE)			/*   '&'   */

	/* other tokens  (aplphabetic on mnemonic)
		handled outside matchop() */
#if FOR_A
	DTOK (I_ROW)			/* row inner */
/*	DTOK (O_ROW)			   row out */
	DTOK (STMT)				/* token of local proc that is generated
							   if a block or statement is used as primary */
#endif

	DTOK (ID)
	DTOK (ROW)				/* row size confolded */
	DTOK (INDEX)			/*   '[]' in expressions */
	DTOK (SCALE)			/* pointer scaling */
	DTOK (NL)

	/* keep xSCONn tokens together in this order */
	DTOK (ASCON)			/* ASCII constant pe: 'x' */
	DTOK (SCON)
	DTOK (SCON1)			/* ANSI: quoted string in include */
	DTOK (SCON2)			/*		  <..>    "         "    */
#if FOR_A
	DTOK (PV)				/* ptr to void (gref or K_GREF) */
	DTOK (IMPL)
#endif
	DTOK (WS)
	DTOK (DLAST)			/* 03'09: for balancing macro expansions */
	DTOK (FLOW)				/* flow list node */

/* the following tokens are for the 'gp' nodes */
	DTOK (EXPR)
	DTOK (FUNFOLD)			/* 04'14 HR v5.1 */
	DTOK (RETURN)
	DTOK (PROC)
	DTOK (IFX)
	DTOK (FOR)
	DTOK (FROM)
	DTOK (BY)
	DTOK (TO)
	DTOK (WHILE)
	DTOK (AFTER)
	DTOK (SWIT)
	DTOK (EX1)
	DTOK (EX2)
	DTOK (EX3)
	DTOK (INIT)
	DTOK (LINIT)
	DTOK (SCALAR)
	DTOK (OUT)
	DTOK (LEXED)		/* pretokenized file */
	DTOK (HIGH_TOK)

#endif		/* deftoks */
