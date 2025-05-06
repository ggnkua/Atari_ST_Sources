%{

/*
HEADER: 	;
TITLE: 		Frankenstein Cross Assemblers;
VERSION: 	2.0;
DESCRIPTION: "	Reconfigurable Cross-assembler producing Intel (TM)
		Hex format object records.  ";
KEYWORDS: 	cross-assemblers, 1805, 2650, 6301, 6502, 6805, 6809, 
		6811, tms7000, 8048, 8051, 8096, z8, z80;
SYSTEM: 	UNIX, MS-Dos ;
FILENAME: 	as6805.y;
WARNINGS: 	"This software is in the public domain.  
		Any prior copyright claims are relinquished.  

		This software is distributed with no warranty whatever.  
		The author takes no responsibility for the consequences 
		of its use.

		Yacc (or Bison) required to compile."  ;
SEE-ALSO: 	as6805.doc,frasmain.c;	
AUTHORS: 	Mark Zenier;
COMPILERS: 	Microport Sys V/AT, ATT Yacc, Turbo C V1.5, Bison (CUG disk 285)
		(previous versions Xenix, Unisoft 68000 Version 7, Sun 3);
*/
/* 6805 instruction generation file */
/* November 17, 1990 */

/*
	description	frame work parser description for framework cross
			assemblers
	history		February 2, 1988
			September 11, 1990 - merge table definition
			September 12, 1990 - short file names
			September 14, 1990 - short variable names
			September 17, 1990 - use yylex as external
*/
#include <stdio.h>
#include "frasmdat.h"
#include "fragcon.h"

#define yylex lexintercept

/*
	file		fraselcrit.h
	author		Mark Zenier
	description	Selection criteria and token values for 6805
			framework assembler
	usage		framework cross assembler
	history		September 19, 1987
			October 2, 1987
			June 7, 1989  fix relative addressing (BRset/clr)
*/
	/* selectors for the ST_EXP address */
	/* 0000 0000 0000 00xx */
#define ADDR		0x3
#define DIRECT		0x1
#define EXTENDED	0x2

	/* selectors for the ST_IND offset */
	/* 0000 0000 000x xx00 */
#define INDEXLEN	0x1C
#define INDEX0		0x4
#define INDEX1		0x8
#define INDEX2		0x10

	/* selectors for instruction set extensions */
	/* 0000 0000 xxx0 0000 */
#define INSTSTWA	0x20
#define INSTMUL	0x40
#define INSTDAA	0x80

	/* cpu instruction extensions */
#define CPU6805	0
#define CPU146805	INSTSTWA
#define CPU68HC05	(INSTSTWA | INSTMUL)
#define CPU6305	(INSTSTWA | INSTDAA)
#define ST_BRSET 0x1
#define ST_BSET 0x2
#define ST_EXP 0x4
#define ST_IMM 0x8
#define ST_IND 0x10
#define ST_INH 0x20
	
	int	cpuselect = CPU6805;
	static char	genbdef[] = "[1=];";
	static char	genwdef[] = "[1=]x";
	char ignosyn[] = "[Xinvalid syntax for instruction";
	char ignosel[] = "[Xinvalid operands/illegal instruction for cpu";

	long	labelloc;
	static int satsub;
	int	ifstkpt = 0;
	int	fraifskip = FALSE;

	struct symel * endsymbol = SYMNULL;

%}
%union {
	int	intv;
	long 	longv;
	char	*strng;
	struct symel *symb;
	struct {int indexv, ex; } inetre;
}

%token <intv> INDEX
%type <inetre> indexed
%token <intv> KOC_BDEF
%token <intv> KOC_ELSE
%token <intv> KOC_END
%token <intv> KOC_ENDI
%token <intv> KOC_EQU
%token <intv> KOC_IF
%token <intv> KOC_INCLUDE
%token <intv> KOC_ORG
%token <intv> KOC_RESM
%token <intv> KOC_SDEF
%token <intv> KOC_SET
%token <intv> KOC_WDEF
%token <intv> KOC_CHSET
%token <intv> KOC_CHDEF
%token <intv> KOC_CHUSE
%token <intv> KOC_CPU
%token <intv> KOC_opcode

%token <longv> CONSTANT
%token EOL
%token KEOP_AND
%token KEOP_DEFINED
%token KEOP_EQ
%token KEOP_GE
%token KEOP_GT
%token KEOP_HIGH
%token KEOP_LE
%token KEOP_LOW
%token KEOP_LT
%token KEOP_MOD
%token KEOP_MUN
%token KEOP_NE
%token KEOP_NOT
%token KEOP_OR
%token KEOP_SHL
%token KEOP_SHR
%token KEOP_XOR
%token KEOP_locctr
%token <symb> LABEL
%token <strng> STRING
%token <symb> SYMBOL

%token KTK_invalid

%right	KEOP_HIGH KEOP_LOW
%left	KEOP_OR KEOP_XOR
%left	KEOP_AND
%right	KEOP_NOT
%nonassoc	KEOP_GT KEOP_GE KEOP_LE KEOP_LT KEOP_NE KEOP_EQ
%left	'+' '-'
%left	'*' '/' KEOP_MOD KEOP_SHL KEOP_SHR
%right	KEOP_MUN


%type <intv> expr exprlist stringlist

%start file

%%

file	:	file allline
	|	allline
	;

allline	: 	line EOL
			{
				clrexpr();
			}
	|	EOL
	|	error EOL
			{
				clrexpr();
				yyerrok;
			}
	;

line	:	LABEL KOC_END 
			{
				endsymbol = $1;
				nextreadact = Nra_end;
			}
	|	      KOC_END 
			{
				nextreadact = Nra_end;
			}
	|	KOC_INCLUDE STRING
			{
		if(nextfstk >= FILESTKDPTH)
		{
			fraerror("include file nesting limit exceeded");
		}
		else
		{
			infilestk[nextfstk].fnm = savestring($2,strlen($2));
			if( (infilestk[nextfstk].fpt = fopen($2,"r"))
				==(FILE *)NULL )
			{
				fraerror("cannot open include file");
			}
			else
			{
				nextreadact = Nra_new;
			}
		}
			}
	|	LABEL KOC_EQU expr 
			{
				if($1 -> seg == SSG_UNDEF)
				{
					pevalexpr(0, $3);
					if(evalr[0].seg == SSG_ABS)
					{
						$1 -> seg = SSG_EQU;
						$1 -> value = evalr[0].value;
						prtequvalue("C: 0x%lx\n",
							evalr[0].value);
					}
					else
					{
						fraerror(
					"noncomputable expression for EQU");
					}
				}
				else
				{
					fraerror(
				"cannot change symbol value with EQU");
				}
			}
	|	LABEL KOC_SET expr 
			{
				if($1 -> seg == SSG_UNDEF
				   || $1 -> seg == SSG_SET)
				{
					pevalexpr(0, $3);
					if(evalr[0].seg == SSG_ABS)
					{
						$1 -> seg = SSG_SET;
						$1 -> value = evalr[0].value;
						prtequvalue("C: 0x%lx\n",
							evalr[0].value);
					}
					else
					{
						fraerror(
					"noncomputable expression for SET");
					}
				}
				else
				{
					fraerror(
				"cannot change symbol value with SET");
				}
			}
	|	KOC_IF expr 
			{
		if((++ifstkpt) < IFSTKDEPTH)
		{
			pevalexpr(0, $2);
			if(evalr[0].seg == SSG_ABS)
			{
				if(evalr[0].value != 0)
				{
					elseifstk[ifstkpt] = If_Skip;
					endifstk[ifstkpt] = If_Active;
				}
				else
				{
					fraifskip = TRUE;
					elseifstk[ifstkpt] = If_Active;
					endifstk[ifstkpt] = If_Active;
				}
			}
			else
			{
				fraifskip = TRUE;
				elseifstk[ifstkpt] = If_Active;
				endifstk[ifstkpt] = If_Active;
			}
		}
		else
		{
			fraerror("IF stack overflow");
		}
			}
						
	|	KOC_IF 
			{
		if(fraifskip) 
		{
			if((++ifstkpt) < IFSTKDEPTH)
			{
					elseifstk[ifstkpt] = If_Skip;
					endifstk[ifstkpt] = If_Skip;
			}
			else
			{
				fraerror("IF stack overflow");
			}
		}
		else
		{
			yyerror("syntax error");
			YYERROR;
		}
				}
						
	|	KOC_ELSE 
			{
				switch(elseifstk[ifstkpt])
				{
				case If_Active:
					fraifskip = FALSE;
					break;
				
				case If_Skip:
					fraifskip = TRUE;
					break;
				
				case If_Err:
					fraerror("ELSE with no matching if");
					break;
				}
			}

	|	KOC_ENDI 
			{
				switch(endifstk[ifstkpt])
				{
				case If_Active:
					fraifskip = FALSE;
					ifstkpt--;
					break;
				
				case If_Skip:
					fraifskip = TRUE;
					ifstkpt--;
					break;
				
				case If_Err:
					fraerror("ENDI with no matching if");
					break;
				}
			}
	|	LABEL KOC_ORG expr 
			{
				pevalexpr(0, $3);
				if(evalr[0].seg == SSG_ABS)
				{
					locctr = labelloc = evalr[0].value;
					if($1 -> seg == SSG_UNDEF)
					{
						$1 -> seg = SSG_ABS;
						$1 -> value = labelloc;
					}
					else
						fraerror(
						"multiple definition of label");
					prtequvalue("C: 0x%lx\n",
						evalr[0].value);
				}
				else
				{
					fraerror(
					 "noncomputable expression for ORG");
				}
			}
	|	      KOC_ORG expr 
			{
				pevalexpr(0, $2);
				if(evalr[0].seg == SSG_ABS)
				{
					locctr = labelloc = evalr[0].value;
					prtequvalue("C: 0x%lx\n",
						evalr[0].value);
				}
				else
				{
					fraerror(
					 "noncomputable expression for ORG");
				}
			}
	|	LABEL KOC_CHSET
			{
				if($1 -> seg == SSG_UNDEF)
				{
					$1 -> seg = SSG_EQU;
					if( ($1->value = chtcreate()) <= 0)
					{
		fraerror( "cannot create character translation table");
					}
					prtequvalue("C: 0x%lx\n", $1 -> value);
				}
				else
				{
			fraerror( "multiple definition of label");
				}
			}
	|		KOC_CHUSE
			{
				chtcpoint = (int *) NULL;
				prtequvalue("C: 0x%lx\n", 0L);
			}
	|		KOC_CHUSE expr
			{
				pevalexpr(0, $2);
				if( evalr[0].seg == SSG_ABS)
				{
					if( evalr[0].value == 0)
					{
						chtcpoint = (int *)NULL;
						prtequvalue("C: 0x%lx\n", 0L);
					}
					else if(evalr[0].value < chtnxalph)
					{
				chtcpoint = chtatab[evalr[0].value];
				prtequvalue("C: 0x%lx\n", evalr[0].value);
					}
					else
					{
			fraerror("nonexistent character translation table");
					}
				}
				else
				{
					fraerror("noncomputable expression");
				}
			}
	|		KOC_CHDEF STRING ',' exprlist
			{
		int findrv, numret, *charaddr;
		char *sourcestr = $2, *before;

		if(chtnpoint != (int *)NULL)
		{
			for(satsub = 0; satsub < $4; satsub++)
			{
				before = sourcestr;

				pevalexpr(0, exprlist[satsub]);
				findrv = chtcfind(chtnpoint, &sourcestr,
						&charaddr, &numret);
				if(findrv == CF_END)
				{
			fraerror("more expressions than characters");
					break;
				}

				if(evalr[0].seg == SSG_ABS)
				{
					switch(findrv)
					{
					case CF_UNDEF:
						{
				if(evalr[0].value < 0 ||
					evalr[0].value > 255)
				{
			frawarn("character translation value truncated");
				}
				*charaddr = evalr[0].value & 0xff;
				prtequvalue("C: 0x%lx\n", evalr[0].value);
						}
						break;

					case CF_INVALID:
					case CF_NUMBER:
				fracherror("invalid character to define", 
					before, sourcestr);
						break;

					case CF_CHAR:
				fracherror("character already defined", 
					before, sourcestr);
						break;
					}
				}
				else
				{
					fraerror("noncomputable expression");
				}
			}

			if( *sourcestr != '\0')
			{
				fraerror("more characters than expressions");
			}
		}
		else
		{
			fraerror("no CHARSET statement active");
		}
			
			}
	|	LABEL 
			{
			if($1 -> seg == SSG_UNDEF)
			{
				$1 -> seg = SSG_ABS;
				$1 -> value = labelloc;
				prtequvalue("C: 0x%lx\n", labelloc);

			}
			else
				fraerror(
				"multiple definition of label");
			}
	|	labeledline
	;

labeledline :	LABEL genline
			{
			if($1 -> seg == SSG_UNDEF)
			{
				$1 -> seg = SSG_ABS;
				$1 -> value = labelloc;
			}
			else
				fraerror(
				"multiple definition of label");
			labelloc = locctr;
			}
				
	|	genline
			{
				labelloc = locctr;
			}
	;

genline	:	KOC_BDEF	exprlist 
			{
				genlocrec(currseg, labelloc);
				for( satsub = 0; satsub < $2; satsub++)
				{
					pevalexpr(1, exprlist[satsub]);
					locctr += geninstr(genbdef);
				}
			}
	|	KOC_SDEF stringlist 
			{
				genlocrec(currseg, labelloc);
				for(satsub = 0; satsub < $2; satsub++)
				{
					locctr += genstring(stringlist[satsub]);
				}
			}
	|	KOC_WDEF exprlist 
			{
				genlocrec(currseg, labelloc);
				for( satsub = 0; satsub < $2; satsub++)
				{
					pevalexpr(1, exprlist[satsub]);
					locctr += geninstr(genwdef);
				}
			}	
	|	KOC_RESM expr 
			{
				pevalexpr(0, $2);
				if(evalr[0].seg == SSG_ABS)
				{
					locctr = labelloc + evalr[0].value;
					prtequvalue("C: 0x%lx\n", labelloc);
				}
				else
				{
					fraerror(
				 "noncomputable result for RMB expression");
				}
			}
	;

exprlist :	exprlist ',' expr
			{
				exprlist[nextexprs ++ ] = $3;
				$$ = nextexprs;
			}
	|	expr
			{
				nextexprs = 0;
				exprlist[nextexprs ++ ] = $1;
				$$ = nextexprs;
			}
	;

stringlist :	stringlist ',' STRING
			{
				stringlist[nextstrs ++ ] = $3;
				$$ = nextstrs;
			}
	|	STRING
			{
				nextstrs = 0;
				stringlist[nextstrs ++ ] = $1;
				$$ = nextstrs;
			}
	;


line	:	KOC_CPU STRING
			{
		if( ! cpumatch($2))
		{
			fraerror("unknown cpu type, 6805 assumed");
			cpuselect = CPU6805;
		}
			}
	;
genline : KOC_opcode  expr ',' expr ',' expr
			{
		pevalexpr(1,$2);
		if(evalr[1].seg != SSG_ABS || 
			evalr[1].value < 0 ||
			evalr[1].value > 7)
		{
			evalr[1].value = 0;
			fraerror("impossible bit number");
		}
		else
		{
			evalr[1].value *= 2;
		}
		pevalexpr(2,$4);
		pevalexpr(3,$6);
		genlocrec(currseg, labelloc);
		locctr += geninstr( findgen($1, ST_BRSET, 0));
			}
	;
genline : KOC_opcode  expr ',' expr
			{
		pevalexpr(1,$2);
		if(evalr[1].seg != SSG_ABS || 
			evalr[1].value < 0 ||
			evalr[1].value > 7)
		{
			evalr[1].value = 0;
			fraerror("impossible bit number");
		}
		else
		{
			evalr[1].value *= 2;
		}
		pevalexpr(2,$4);
		genlocrec(currseg, labelloc);
		locctr += geninstr( findgen( $1, ST_BSET, 0));
			}
	;
genline : KOC_opcode  expr
			{
		pevalexpr(1, $2);
		genlocrec(currseg, labelloc);
		locctr += geninstr( findgen( $1, ST_EXP, 
				  ( (evalr[1].seg == SSG_ABS 
				&& evalr[1].value >= 0
				&& evalr[1].value <= 255 )
				? DIRECT : EXTENDED ) )
				);
			}
	;
genline : KOC_opcode  '#' expr
			{
		pevalexpr(1, $3);
		genlocrec(currseg, labelloc);
		locctr += geninstr( findgen($1, ST_IMM, 0));
			}
	;
genline : KOC_opcode  indexed
			{
		int selcrit = INDEX2;

		pevalexpr(1, $2.ex);

		if(evalr[1].seg == SSG_ABS)
		{
			if(evalr[1].value == 0)
			{
				selcrit = INDEX0;
			}
			else if(evalr[1].value > 0 && evalr[1].value <= 255)
			{
				selcrit = INDEX1;
			}
		}

		genlocrec(currseg, labelloc);
		locctr += geninstr( findgen($1, ST_IND, selcrit));
			}
	;
genline : KOC_opcode 
			{
		genlocrec(currseg, labelloc);
		locctr += geninstr(findgen($1, ST_INH, cpuselect));
			}
	;

indexed	:	',' INDEX	
			{
				$$.indexv = $2;
				$$.ex = exprnode(PCCASE_CONS,0,
					IGP_CONSTANT,0,
					(long)0, SYMNULL);
			}
	|	expr ',' INDEX
			{
				$$.ex = $1;
				$$.indexv = $3;
			}
	;

expr	:	'+' expr %prec KEOP_MUN
			{
				$$ = $2;
			}
	|	'-' expr %prec KEOP_MUN
			{
				$$ = exprnode(PCCASE_UN,$2,IFC_NEG,0,0L,
					SYMNULL);
			}
	|	KEOP_NOT expr
			{
				$$ = exprnode(PCCASE_UN,$2,IFC_NOT,0,0L,
					SYMNULL);
			}
	|	KEOP_HIGH expr
			{
				$$ = exprnode(PCCASE_UN,$2,IFC_HIGH,0,0L,
					SYMNULL);
			}
	|	KEOP_LOW expr
			{
				$$ = exprnode(PCCASE_UN,$2,IFC_LOW,0,0L,
					SYMNULL);
			}
	|	expr '*' expr
			{
				$$ = exprnode(PCCASE_BIN,$1,IFC_MUL,$3,0L,
					SYMNULL);
			}
	|	expr '/' expr
			{
				$$ = exprnode(PCCASE_BIN,$1,IFC_DIV,$3,0L,
					SYMNULL);
			}
	|	expr '+' expr
			{
				$$ = exprnode(PCCASE_BIN,$1,IFC_ADD,$3,0L,
					SYMNULL);
			}
	|	expr '-' expr
			{
				$$ = exprnode(PCCASE_BIN,$1,IFC_SUB,$3,0L,
					SYMNULL);
			}
	|	expr KEOP_MOD expr
			{
				$$ = exprnode(PCCASE_BIN,$1,IFC_MOD,$3,0L,
					SYMNULL);
			}
	|	expr KEOP_SHL expr
			{
				$$ = exprnode(PCCASE_BIN,$1,IFC_SHL,$3,0L,
					SYMNULL);
			}
	|	expr KEOP_SHR expr
			{
				$$ = exprnode(PCCASE_BIN,$1,IFC_SHR,$3,0L,
					SYMNULL);
			}
	|	expr KEOP_GT expr
			{
				$$ = exprnode(PCCASE_BIN,$1,IFC_GT,$3,0L,
					SYMNULL);
			}
	|	expr KEOP_GE expr
			{
				$$ = exprnode(PCCASE_BIN,$1,IFC_GE,$3,0L,
					SYMNULL);
			}
	|	expr KEOP_LT expr
			{
				$$ = exprnode(PCCASE_BIN,$1,IFC_LT,$3,0L,
					SYMNULL);
			}
	|	expr KEOP_LE expr
			{
				$$ = exprnode(PCCASE_BIN,$1,IFC_LE,$3,0L,
					SYMNULL);
			}
	|	expr KEOP_NE expr
			{
				$$ = exprnode(PCCASE_BIN,$1,IFC_NE,$3,0L,
					SYMNULL);
			}
	|	expr KEOP_EQ expr
			{
				$$ = exprnode(PCCASE_BIN,$1,IFC_EQ,$3,0L,
					SYMNULL);
			}
	|	expr KEOP_AND expr
			{
				$$ = exprnode(PCCASE_BIN,$1,IFC_AND,$3,0L,
					SYMNULL);
			}
	|	expr KEOP_OR expr
			{
				$$ = exprnode(PCCASE_BIN,$1,IFC_OR,$3,0L,
					SYMNULL);
			}
	|	expr KEOP_XOR expr
			{
				$$ = exprnode(PCCASE_BIN,$1,IFC_XOR,$3,0L,
					SYMNULL);
			}
	|	KEOP_DEFINED SYMBOL
			{
				$$ = exprnode(PCCASE_DEF,0,IGP_DEFINED,0,0L,$2);
			}
	|	SYMBOL
			{
				$$ = exprnode(PCCASE_SYMB,0,IFC_SYMB,0,0L,$1);
			}
	|	'*'
			{
				$$ = exprnode(PCCASE_PROGC,0,IFC_PROGCTR,0,
					labelloc, SYMNULL);
			}
	|	CONSTANT
			{
				$$ = exprnode(PCCASE_CONS,0,IGP_CONSTANT,0,$1,
					SYMNULL);
			}
	|	STRING
			{
				char *sourcestr = $1;
				long accval = 0;

				if(strlen($1) > 0)
				{
					accval = chtran(&sourcestr);
					if(*sourcestr != '\0')
					{
						accval = (accval << 8) +
							chtran(&sourcestr);
					}

					if( *sourcestr != '\0')
					{
	frawarn("string constant in expression more than 2 characters long");
					}
				}
				$$ = exprnode(PCCASE_CONS, 0, IGP_CONSTANT, 0,
					accval, SYMNULL);
			}
	|	'(' expr ')'
			{
				$$ = $2;
			}
	;


%%

lexintercept()
/*
	description	intercept the call to yylex (the lexical analyzer)
			and filter out all unnecessary tokens when skipping
			the input between a failed IF and its matching ENDI or
			ELSE
	globals 	fraifskip	the enable flag
*/
{
#undef yylex

	int rv;

	if(fraifskip)
	{
		for(;;)
		{

			switch(rv = yylex())

			{
			case 0:
			case KOC_END:
			case KOC_IF:
			case KOC_ELSE:
			case KOC_ENDI:
			case EOL:
				return rv;
			default:
				break;
			}
		}
	}
	else
		return yylex();
#define yylex lexintercept
}


setreserved()
{
/* machine dependent */
	reservedsym("x", INDEX, 0);
	reservedsym("X", INDEX, 0);


	reservedsym("and", KEOP_AND, 0);
	reservedsym("defined", KEOP_DEFINED,0);
	reservedsym("eq", KEOP_EQ, 0);
	reservedsym("ge", KEOP_GE, 0);
	reservedsym("gt", KEOP_GT, 0);
	reservedsym("high", KEOP_HIGH, 0);
	reservedsym("le", KEOP_LE, 0);
	reservedsym("low", KEOP_LOW, 0);
	reservedsym("lt", KEOP_LT, 0);
	reservedsym("mod", KEOP_MOD, 0);
	reservedsym("ne", KEOP_NE, 0);
	reservedsym("not", KEOP_NOT, 0);
	reservedsym("or", KEOP_OR, 0);
	reservedsym("shl", KEOP_SHL, 0);
	reservedsym("shr", KEOP_SHR, 0);
	reservedsym("xor", KEOP_XOR, 0);
	reservedsym("AND", KEOP_AND, 0);
	reservedsym("DEFINED", KEOP_DEFINED,0);
	reservedsym("EQ", KEOP_EQ, 0);
	reservedsym("GE", KEOP_GE, 0);
	reservedsym("GT", KEOP_GT, 0);
	reservedsym("HIGH", KEOP_HIGH, 0);
	reservedsym("LE", KEOP_LE, 0);
	reservedsym("LOW", KEOP_LOW, 0);
	reservedsym("LT", KEOP_LT, 0);
	reservedsym("MOD", KEOP_MOD, 0);
	reservedsym("NE", KEOP_NE, 0);
	reservedsym("NOT", KEOP_NOT, 0);
	reservedsym("OR", KEOP_OR, 0);
	reservedsym("SHL", KEOP_SHL, 0);
	reservedsym("SHR", KEOP_SHR, 0);
	reservedsym("XOR", KEOP_XOR, 0);

}

cpumatch(str)
	char * str;
{
	int msub;

	static struct
	{
		char * mtch;
		int   cpuv;
	} matchtab[] =
	{
		{"4", CPU146805 },
		{"hc", CPU68HC05 },
		{"HC", CPU68HC05 },
		{"l05", CPU6805 },
		{"L05", CPU6805 },
		{"3", CPU6305 },
		{"05", CPU6805 },
		{"", 0} 
	};

	for(msub = 0; matchtab[msub].mtch[0] != '\0'; msub++)
	{
		if(strcontains(str, matchtab[msub].mtch))
		{
			cpuselect = matchtab[msub].cpuv;
			return TRUE;
		}
	}

	return FALSE;
}


strcontains(s1, sm)
	char * s1, *sm;
{
	int l1 = strlen(s1), lm = strlen(sm);

	for(; l1 >= lm; l1--, s1++)
	{
		if(strncmp(s1, sm, lm) == 0)
		{
			return TRUE;
		}
	}
	return FALSE;
}

/*
	description	Opcode and Instruction generation tables
	usage		Unix, framework crossassembler
	history		September 25, 1987
*/

#define NUMOPCODE 115
#define NUMSYNBLK 132
#define NUMDIFFOP 192

int gnumopcode = NUMOPCODE;

int ophashlnk[NUMOPCODE];

struct opsym optab[NUMOPCODE+1]
	= {
	{"invalid", KOC_opcode, 2, 0 },
	{"ADC", KOC_opcode, 3, 2 },
	{"ADD", KOC_opcode, 3, 5 },
	{"AND", KOC_opcode, 3, 8 },
	{"ASL", KOC_opcode, 2, 11 },
	{"ASLA", KOC_opcode, 1, 13 },
	{"ASLX", KOC_opcode, 1, 14 },
	{"ASR", KOC_opcode, 2, 15 },
	{"ASRA", KOC_opcode, 1, 17 },
	{"ASRX", KOC_opcode, 1, 18 },
	{"BCC", KOC_opcode, 1, 19 },
	{"BCLR", KOC_opcode, 1, 20 },
	{"BCS", KOC_opcode, 1, 21 },
	{"BEQ", KOC_opcode, 1, 22 },
	{"BHCC", KOC_opcode, 1, 23 },
	{"BHCS", KOC_opcode, 1, 24 },
	{"BHI", KOC_opcode, 1, 25 },
	{"BHS", KOC_opcode, 1, 26 },
	{"BIH", KOC_opcode, 1, 27 },
	{"BIL", KOC_opcode, 1, 28 },
	{"BIT", KOC_opcode, 3, 29 },
	{"BLO", KOC_opcode, 1, 32 },
	{"BLS", KOC_opcode, 1, 33 },
	{"BMC", KOC_opcode, 1, 34 },
	{"BMI", KOC_opcode, 1, 35 },
	{"BMS", KOC_opcode, 1, 36 },
	{"BNE", KOC_opcode, 1, 37 },
	{"BPL", KOC_opcode, 1, 38 },
	{"BRA", KOC_opcode, 1, 39 },
	{"BRCLR", KOC_opcode, 1, 40 },
	{"BRN", KOC_opcode, 1, 41 },
	{"BRSET", KOC_opcode, 1, 42 },
	{"BSET", KOC_opcode, 1, 43 },
	{"BSR", KOC_opcode, 1, 44 },
	{"BYTE", KOC_BDEF, 0, 0 },
	{"CHARDEF", KOC_CHDEF, 0, 0 },
	{"CHARSET", KOC_CHSET, 0, 0 },
	{"CHARUSE", KOC_CHUSE, 0, 0 },
	{"CHD", KOC_CHDEF, 0, 0 },
	{"CLC", KOC_opcode, 1, 45 },
	{"CLI", KOC_opcode, 1, 46 },
	{"CLR", KOC_opcode, 2, 47 },
	{"CLRA", KOC_opcode, 1, 49 },
	{"CLRX", KOC_opcode, 1, 50 },
	{"CMP", KOC_opcode, 3, 51 },
	{"COM", KOC_opcode, 2, 54 },
	{"COMA", KOC_opcode, 1, 56 },
	{"COMX", KOC_opcode, 1, 57 },
	{"CPU", KOC_CPU, 0, 0 },
	{"CPX", KOC_opcode, 3, 58 },
	{"DAA", KOC_opcode, 1, 61 },
	{"DB", KOC_BDEF, 0, 0 },
	{"DEC", KOC_opcode, 2, 62 },
	{"DECA", KOC_opcode, 1, 64 },
	{"DECX", KOC_opcode, 1, 65 },
	{"DW", KOC_WDEF, 0, 0 },
	{"ELSE", KOC_ELSE, 0, 0 },
	{"END", KOC_END, 0, 0 },
	{"ENDI", KOC_ENDI, 0, 0 },
	{"EOR", KOC_opcode, 3, 66 },
	{"EQU", KOC_EQU, 0, 0 },
	{"FCB", KOC_BDEF, 0, 0 },
	{"FCC", KOC_SDEF, 0, 0 },
	{"FDB", KOC_WDEF, 0, 0 },
	{"IF", KOC_IF, 0, 0 },
	{"INC", KOC_opcode, 2, 69 },
	{"INCA", KOC_opcode, 1, 71 },
	{"INCL", KOC_INCLUDE, 0, 0 },
	{"INCLUDE", KOC_INCLUDE, 0, 0 },
	{"INCX", KOC_opcode, 1, 72 },
	{"JMP", KOC_opcode, 2, 73 },
	{"JSR", KOC_opcode, 2, 75 },
	{"LDA", KOC_opcode, 3, 77 },
	{"LDX", KOC_opcode, 3, 80 },
	{"LSL", KOC_opcode, 2, 83 },
	{"LSLA", KOC_opcode, 1, 85 },
	{"LSLX", KOC_opcode, 1, 86 },
	{"LSR", KOC_opcode, 2, 87 },
	{"LSRA", KOC_opcode, 1, 89 },
	{"LSRX", KOC_opcode, 1, 90 },
	{"MUL", KOC_opcode, 1, 91 },
	{"NEG", KOC_opcode, 2, 92 },
	{"NEGA", KOC_opcode, 1, 94 },
	{"NEGX", KOC_opcode, 1, 95 },
	{"NOP", KOC_opcode, 1, 96 },
	{"ORA", KOC_opcode, 3, 97 },
	{"ORG", KOC_ORG, 0, 0 },
	{"RESERVE", KOC_RESM, 0, 0 },
	{"RMB", KOC_RESM, 0, 0 },
	{"ROL", KOC_opcode, 2, 100 },
	{"ROLA", KOC_opcode, 1, 102 },
	{"ROLX", KOC_opcode, 1, 103 },
	{"ROR", KOC_opcode, 2, 104 },
	{"RORA", KOC_opcode, 1, 106 },
	{"RORX", KOC_opcode, 1, 107 },
	{"RSP", KOC_opcode, 1, 108 },
	{"RTI", KOC_opcode, 1, 109 },
	{"RTS", KOC_opcode, 1, 110 },
	{"SBC", KOC_opcode, 3, 111 },
	{"SEC", KOC_opcode, 1, 114 },
	{"SEI", KOC_opcode, 1, 115 },
	{"SET", KOC_SET, 0, 0 },
	{"STA", KOC_opcode, 2, 116 },
	{"STOP", KOC_opcode, 1, 118 },
	{"STRING", KOC_SDEF, 0, 0 },
	{"STX", KOC_opcode, 2, 119 },
	{"SUB", KOC_opcode, 3, 121 },
	{"SWI", KOC_opcode, 1, 124 },
	{"TAX", KOC_opcode, 1, 125 },
	{"TST", KOC_opcode, 2, 126 },
	{"TSTA", KOC_opcode, 1, 128 },
	{"TSTX", KOC_opcode, 1, 129 },
	{"TXA", KOC_opcode, 1, 130 },
	{"WAIT", KOC_opcode, 1, 131 },
	{"WORD", KOC_WDEF, 0, 0 },
	{ "", 0, 0, 0 }};

struct opsynt ostab[NUMSYNBLK+1]
	= {
/* invalid 0 */ { 0, 1, 0 },
/* invalid 1 */ { 0xffff, 1, 1 },
/* ADC 2 */ { ST_EXP, 2, 2 },
/* ADC 3 */ { ST_IMM, 1, 4 },
/* ADC 4 */ { ST_IND, 3, 5 },
/* ADD 5 */ { ST_EXP, 2, 8 },
/* ADD 6 */ { ST_IMM, 1, 10 },
/* ADD 7 */ { ST_IND, 3, 11 },
/* AND 8 */ { ST_EXP, 2, 14 },
/* AND 9 */ { ST_IMM, 1, 16 },
/* AND 10 */ { ST_IND, 3, 17 },
/* ASL 11 */ { ST_EXP, 1, 20 },
/* ASL 12 */ { ST_IND, 2, 21 },
/* ASLA 13 */ { ST_INH, 1, 23 },
/* ASLX 14 */ { ST_INH, 1, 24 },
/* ASR 15 */ { ST_EXP, 1, 25 },
/* ASR 16 */ { ST_IND, 2, 26 },
/* ASRA 17 */ { ST_INH, 1, 28 },
/* ASRX 18 */ { ST_INH, 1, 29 },
/* BCC 19 */ { ST_EXP, 1, 30 },
/* BCLR 20 */ { ST_BSET, 1, 31 },
/* BCS 21 */ { ST_EXP, 1, 32 },
/* BEQ 22 */ { ST_EXP, 1, 33 },
/* BHCC 23 */ { ST_EXP, 1, 34 },
/* BHCS 24 */ { ST_EXP, 1, 35 },
/* BHI 25 */ { ST_EXP, 1, 36 },
/* BHS 26 */ { ST_EXP, 1, 37 },
/* BIH 27 */ { ST_EXP, 1, 38 },
/* BIL 28 */ { ST_EXP, 1, 39 },
/* BIT 29 */ { ST_EXP, 2, 40 },
/* BIT 30 */ { ST_IMM, 1, 42 },
/* BIT 31 */ { ST_IND, 3, 43 },
/* BLO 32 */ { ST_EXP, 1, 46 },
/* BLS 33 */ { ST_EXP, 1, 47 },
/* BMC 34 */ { ST_EXP, 1, 48 },
/* BMI 35 */ { ST_EXP, 1, 49 },
/* BMS 36 */ { ST_EXP, 1, 50 },
/* BNE 37 */ { ST_EXP, 1, 51 },
/* BPL 38 */ { ST_EXP, 1, 52 },
/* BRA 39 */ { ST_EXP, 1, 53 },
/* BRCLR 40 */ { ST_BRSET, 1, 54 },
/* BRN 41 */ { ST_EXP, 1, 55 },
/* BRSET 42 */ { ST_BRSET, 1, 56 },
/* BSET 43 */ { ST_BSET, 1, 57 },
/* BSR 44 */ { ST_EXP, 1, 58 },
/* CLC 45 */ { ST_INH, 1, 59 },
/* CLI 46 */ { ST_INH, 1, 60 },
/* CLR 47 */ { ST_EXP, 1, 61 },
/* CLR 48 */ { ST_IND, 2, 62 },
/* CLRA 49 */ { ST_INH, 1, 64 },
/* CLRX 50 */ { ST_INH, 1, 65 },
/* CMP 51 */ { ST_EXP, 2, 66 },
/* CMP 52 */ { ST_IMM, 1, 68 },
/* CMP 53 */ { ST_IND, 3, 69 },
/* COM 54 */ { ST_EXP, 1, 72 },
/* COM 55 */ { ST_IND, 2, 73 },
/* COMA 56 */ { ST_INH, 1, 75 },
/* COMX 57 */ { ST_INH, 1, 76 },
/* CPX 58 */ { ST_EXP, 2, 77 },
/* CPX 59 */ { ST_IMM, 1, 79 },
/* CPX 60 */ { ST_IND, 3, 80 },
/* DAA 61 */ { ST_INH, 1, 83 },
/* DEC 62 */ { ST_EXP, 1, 84 },
/* DEC 63 */ { ST_IND, 2, 85 },
/* DECA 64 */ { ST_INH, 1, 87 },
/* DECX 65 */ { ST_INH, 1, 88 },
/* EOR 66 */ { ST_EXP, 2, 89 },
/* EOR 67 */ { ST_IMM, 1, 91 },
/* EOR 68 */ { ST_IND, 3, 92 },
/* INC 69 */ { ST_EXP, 1, 95 },
/* INC 70 */ { ST_IND, 2, 96 },
/* INCA 71 */ { ST_INH, 1, 98 },
/* INCX 72 */ { ST_INH, 1, 99 },
/* JMP 73 */ { ST_EXP, 2, 100 },
/* JMP 74 */ { ST_IND, 3, 102 },
/* JSR 75 */ { ST_EXP, 2, 105 },
/* JSR 76 */ { ST_IND, 3, 107 },
/* LDA 77 */ { ST_EXP, 2, 110 },
/* LDA 78 */ { ST_IMM, 1, 112 },
/* LDA 79 */ { ST_IND, 3, 113 },
/* LDX 80 */ { ST_EXP, 2, 116 },
/* LDX 81 */ { ST_IMM, 1, 118 },
/* LDX 82 */ { ST_IND, 3, 119 },
/* LSL 83 */ { ST_EXP, 1, 122 },
/* LSL 84 */ { ST_IND, 2, 123 },
/* LSLA 85 */ { ST_INH, 1, 125 },
/* LSLX 86 */ { ST_INH, 1, 126 },
/* LSR 87 */ { ST_EXP, 1, 127 },
/* LSR 88 */ { ST_IND, 2, 128 },
/* LSRA 89 */ { ST_INH, 1, 130 },
/* LSRX 90 */ { ST_INH, 1, 131 },
/* MUL 91 */ { ST_INH, 1, 132 },
/* NEG 92 */ { ST_EXP, 1, 133 },
/* NEG 93 */ { ST_IND, 2, 134 },
/* NEGA 94 */ { ST_INH, 1, 136 },
/* NEGX 95 */ { ST_INH, 1, 137 },
/* NOP 96 */ { ST_INH, 1, 138 },
/* ORA 97 */ { ST_EXP, 2, 139 },
/* ORA 98 */ { ST_IMM, 1, 141 },
/* ORA 99 */ { ST_IND, 3, 142 },
/* ROL 100 */ { ST_EXP, 1, 145 },
/* ROL 101 */ { ST_IND, 2, 146 },
/* ROLA 102 */ { ST_INH, 1, 148 },
/* ROLX 103 */ { ST_INH, 1, 149 },
/* ROR 104 */ { ST_EXP, 1, 150 },
/* ROR 105 */ { ST_IND, 2, 151 },
/* RORA 106 */ { ST_INH, 1, 153 },
/* RORX 107 */ { ST_INH, 1, 154 },
/* RSP 108 */ { ST_INH, 1, 155 },
/* RTI 109 */ { ST_INH, 1, 156 },
/* RTS 110 */ { ST_INH, 1, 157 },
/* SBC 111 */ { ST_EXP, 2, 158 },
/* SBC 112 */ { ST_IMM, 1, 160 },
/* SBC 113 */ { ST_IND, 3, 161 },
/* SEC 114 */ { ST_INH, 1, 164 },
/* SEI 115 */ { ST_INH, 1, 165 },
/* STA 116 */ { ST_EXP, 2, 166 },
/* STA 117 */ { ST_IND, 3, 168 },
/* STOP 118 */ { ST_INH, 1, 171 },
/* STX 119 */ { ST_EXP, 2, 172 },
/* STX 120 */ { ST_IND, 3, 174 },
/* SUB 121 */ { ST_EXP, 2, 177 },
/* SUB 122 */ { ST_IMM, 1, 179 },
/* SUB 123 */ { ST_IND, 3, 180 },
/* SWI 124 */ { ST_INH, 1, 183 },
/* TAX 125 */ { ST_INH, 1, 184 },
/* TST 126 */ { ST_EXP, 1, 185 },
/* TST 127 */ { ST_IND, 2, 186 },
/* TSTA 128 */ { ST_INH, 1, 188 },
/* TSTX 129 */ { ST_INH, 1, 189 },
/* TXA 130 */ { ST_INH, 1, 190 },
/* WAIT 131 */ { ST_INH, 1, 191 },
	{ 0, 0, 0 } };

struct igel igtab[NUMDIFFOP+1]
	= {
/* invalid 0 */   { 0 , 0, 
		"[Xnullentry" },
/* invalid 1 */   { 0 , 0, 
		"[Xinvalid opcode" },
/* ADC 2 */   { ADDR , DIRECT, 
		"B9;[1=];" },
/* ADC 3 */   { ADDR , EXTENDED, 
		"C9;[1=]x" },
/* ADC 4 */   { 0 , 0, 
		"A9;[1=];" },
/* ADC 5 */   { INDEXLEN , INDEX2, 
		"D9;[1=]x" },
/* ADC 6 */   { INDEXLEN , INDEX1, 
		"E9;[1=];" },
/* ADC 7 */   { INDEXLEN , INDEX0, 
		"F9;" },
/* ADD 8 */   { ADDR , DIRECT, 
		"BB;[1=];" },
/* ADD 9 */   { ADDR , EXTENDED, 
		"CB;[1=]x" },
/* ADD 10 */   { 0 , 0, 
		"AB;[1=];" },
/* ADD 11 */   { INDEXLEN , INDEX2, 
		"DB;[1=]x" },
/* ADD 12 */   { INDEXLEN , INDEX1, 
		"EB;[1=];" },
/* ADD 13 */   { INDEXLEN , INDEX0, 
		"FB;" },
/* AND 14 */   { ADDR , DIRECT, 
		"B4;[1=];" },
/* AND 15 */   { ADDR , EXTENDED, 
		"C4;[1=]x" },
/* AND 16 */   { 0 , 0, 
		"A4;[1=];" },
/* AND 17 */   { INDEXLEN , INDEX2, 
		"D4;[1=]x" },
/* AND 18 */   { INDEXLEN , INDEX1, 
		"E4;[1=];" },
/* AND 19 */   { INDEXLEN , INDEX0, 
		"F4;" },
/* ASL 20 */   { ADDR , DIRECT, 
		"38;[1=];" },
/* ASL 21 */   { INDEXLEN , INDEX1, 
		"68;[1=];" },
/* ASL 22 */   { INDEXLEN , INDEX0, 
		"78;" },
/* ASLA 23 */   { 0 , 0, 
		"48;" },
/* ASLX 24 */   { 0 , 0, 
		"58;" },
/* ASR 25 */   { ADDR , DIRECT, 
		"37;[1=];" },
/* ASR 26 */   { INDEXLEN , INDEX1, 
		"67;[1=];" },
/* ASR 27 */   { INDEXLEN , INDEX0, 
		"77;" },
/* ASRA 28 */   { 0 , 0, 
		"47;" },
/* ASRX 29 */   { 0 , 0, 
		"57;" },
/* BCC 30 */   { 0 , 0, 
		"24;[1=].Q.1+-r" },
/* BCLR 31 */   { 0 , 0, 
		"11.[1#]|;[2=];" },
/* BCS 32 */   { 0 , 0, 
		"25;[1=].Q.1+-r" },
/* BEQ 33 */   { 0 , 0, 
		"27;[1=].Q.1+-r" },
/* BHCC 34 */   { 0 , 0, 
		"28;[1=].Q.1+-r" },
/* BHCS 35 */   { 0 , 0, 
		"29;[1=].Q.1+-r" },
/* BHI 36 */   { 0 , 0, 
		"22;[1=].Q.1+-r" },
/* BHS 37 */   { 0 , 0, 
		"24;[1=].Q.1+-r" },
/* BIH 38 */   { 0 , 0, 
		"2f;[1=].Q.1+-r" },
/* BIL 39 */   { 0 , 0, 
		"2e;[1=].Q.1+-r" },
/* BIT 40 */   { ADDR , DIRECT, 
		"B5;[1=];" },
/* BIT 41 */   { ADDR , EXTENDED, 
		"C5;[1=]x" },
/* BIT 42 */   { 0 , 0, 
		"A5;[1=];" },
/* BIT 43 */   { INDEXLEN , INDEX2, 
		"D5;[1=]x" },
/* BIT 44 */   { INDEXLEN , INDEX1, 
		"E5;[1=];" },
/* BIT 45 */   { INDEXLEN , INDEX0, 
		"F5;" },
/* BLO 46 */   { 0 , 0, 
		"25;[1=].Q.1+-r" },
/* BLS 47 */   { 0 , 0, 
		"23;[1=].Q.1+-r" },
/* BMC 48 */   { 0 , 0, 
		"2c;[1=].Q.1+-r" },
/* BMI 49 */   { 0 , 0, 
		"2b;[1=].Q.1+-r" },
/* BMS 50 */   { 0 , 0, 
		"2d;[1=].Q.1+-r" },
/* BNE 51 */   { 0 , 0, 
		"26;[1=].Q.1+-r" },
/* BPL 52 */   { 0 , 0, 
		"2a;[1=].Q.1+-r" },
/* BRA 53 */   { 0 , 0, 
		"20;[1=].Q.1+-r" },
/* BRCLR 54 */   { 0 , 0, 
		"01.[1#]|;[2=];[3=].Q.1+-r" },
/* BRN 55 */   { 0 , 0, 
		"21;[1=].Q.1+-r" },
/* BRSET 56 */   { 0 , 0, 
		"00.[1#]|;[2=];[3=].Q.1+-r" },
/* BSET 57 */   { 0 , 0, 
		"10.[1#]|;[2=];" },
/* BSR 58 */   { 0 , 0, 
		"ad;[1=].Q.1+-r" },
/* CLC 59 */   { 0 , 0, 
		"98;" },
/* CLI 60 */   { 0 , 0, 
		"9a;" },
/* CLR 61 */   { ADDR , DIRECT, 
		"3F;[1=];" },
/* CLR 62 */   { INDEXLEN , INDEX1, 
		"6F;[1=];" },
/* CLR 63 */   { INDEXLEN , INDEX0, 
		"7F;" },
/* CLRA 64 */   { 0 , 0, 
		"4F;" },
/* CLRX 65 */   { 0 , 0, 
		"5F;" },
/* CMP 66 */   { ADDR , DIRECT, 
		"B1;[1=];" },
/* CMP 67 */   { ADDR , EXTENDED, 
		"C1;[1=]x" },
/* CMP 68 */   { 0 , 0, 
		"A1;[1=];" },
/* CMP 69 */   { INDEXLEN , INDEX2, 
		"D1;[1=]x" },
/* CMP 70 */   { INDEXLEN , INDEX1, 
		"E1;[1=];" },
/* CMP 71 */   { INDEXLEN , INDEX0, 
		"F1;" },
/* COM 72 */   { ADDR , DIRECT, 
		"33;[1=];" },
/* COM 73 */   { INDEXLEN , INDEX1, 
		"63;[1=];" },
/* COM 74 */   { INDEXLEN , INDEX0, 
		"73;" },
/* COMA 75 */   { 0 , 0, 
		"43;" },
/* COMX 76 */   { 0 , 0, 
		"53;" },
/* CPX 77 */   { ADDR , DIRECT, 
		"B3;[1=];" },
/* CPX 78 */   { ADDR , EXTENDED, 
		"C3;[1=]x" },
/* CPX 79 */   { 0 , 0, 
		"A3;[1=];" },
/* CPX 80 */   { INDEXLEN , INDEX2, 
		"D3;[1=]x" },
/* CPX 81 */   { INDEXLEN , INDEX1, 
		"E3;[1=];" },
/* CPX 82 */   { INDEXLEN , INDEX0, 
		"F3;" },
/* DAA 83 */   { INSTDAA , INSTDAA, 
		"8d;" },
/* DEC 84 */   { ADDR , DIRECT, 
		"3A;[1=];" },
/* DEC 85 */   { INDEXLEN , INDEX1, 
		"6A;[1=];" },
/* DEC 86 */   { INDEXLEN , INDEX0, 
		"7A;" },
/* DECA 87 */   { 0 , 0, 
		"4A;" },
/* DECX 88 */   { 0 , 0, 
		"5A;" },
/* EOR 89 */   { ADDR , DIRECT, 
		"B8;[1=];" },
/* EOR 90 */   { ADDR , EXTENDED, 
		"C8;[1=]x" },
/* EOR 91 */   { 0 , 0, 
		"A8;[1=];" },
/* EOR 92 */   { INDEXLEN , INDEX2, 
		"D8;[1=]x" },
/* EOR 93 */   { INDEXLEN , INDEX1, 
		"E8;[1=];" },
/* EOR 94 */   { INDEXLEN , INDEX0, 
		"F8;" },
/* INC 95 */   { ADDR , DIRECT, 
		"3C;[1=];" },
/* INC 96 */   { INDEXLEN , INDEX1, 
		"6C;[1=];" },
/* INC 97 */   { INDEXLEN , INDEX0, 
		"7C;" },
/* INCA 98 */   { 0 , 0, 
		"4C;" },
/* INCX 99 */   { 0 , 0, 
		"5C;" },
/* JMP 100 */   { ADDR , DIRECT, 
		"BC;[1=];" },
/* JMP 101 */   { ADDR , EXTENDED, 
		"CC;[1=]x" },
/* JMP 102 */   { INDEXLEN , INDEX2, 
		"DC;[1=]x" },
/* JMP 103 */   { INDEXLEN , INDEX1, 
		"EC;[1=];" },
/* JMP 104 */   { INDEXLEN , INDEX0, 
		"FC;" },
/* JSR 105 */   { ADDR , DIRECT, 
		"BD;[1=];" },
/* JSR 106 */   { ADDR , EXTENDED, 
		"CD;[1=]x" },
/* JSR 107 */   { INDEXLEN , INDEX2, 
		"DD;[1=]x" },
/* JSR 108 */   { INDEXLEN , INDEX1, 
		"ED;[1=];" },
/* JSR 109 */   { INDEXLEN , INDEX0, 
		"FD;" },
/* LDA 110 */   { ADDR , DIRECT, 
		"B6;[1=];" },
/* LDA 111 */   { ADDR , EXTENDED, 
		"C6;[1=]x" },
/* LDA 112 */   { 0 , 0, 
		"A6;[1=];" },
/* LDA 113 */   { INDEXLEN , INDEX2, 
		"D6;[1=]x" },
/* LDA 114 */   { INDEXLEN , INDEX1, 
		"E6;[1=];" },
/* LDA 115 */   { INDEXLEN , INDEX0, 
		"F6;" },
/* LDX 116 */   { ADDR , DIRECT, 
		"BE;[1=];" },
/* LDX 117 */   { ADDR , EXTENDED, 
		"CE;[1=]x" },
/* LDX 118 */   { 0 , 0, 
		"AE;[1=];" },
/* LDX 119 */   { INDEXLEN , INDEX2, 
		"DE;[1=]x" },
/* LDX 120 */   { INDEXLEN , INDEX1, 
		"EE;[1=];" },
/* LDX 121 */   { INDEXLEN , INDEX0, 
		"FE;" },
/* LSL 122 */   { ADDR , DIRECT, 
		"38;[1=];" },
/* LSL 123 */   { INDEXLEN , INDEX1, 
		"68;[1=];" },
/* LSL 124 */   { INDEXLEN , INDEX0, 
		"78;" },
/* LSLA 125 */   { 0 , 0, 
		"48;" },
/* LSLX 126 */   { 0 , 0, 
		"58;" },
/* LSR 127 */   { ADDR , DIRECT, 
		"34;[1=];" },
/* LSR 128 */   { INDEXLEN , INDEX1, 
		"64;[1=];" },
/* LSR 129 */   { INDEXLEN , INDEX0, 
		"74;" },
/* LSRA 130 */   { 0 , 0, 
		"44;" },
/* LSRX 131 */   { 0 , 0, 
		"54;" },
/* MUL 132 */   { INSTMUL , INSTMUL, 
		"42;" },
/* NEG 133 */   { ADDR , DIRECT, 
		"30;[1=];" },
/* NEG 134 */   { INDEXLEN , INDEX1, 
		"60;[1=];" },
/* NEG 135 */   { INDEXLEN , INDEX0, 
		"70;" },
/* NEGA 136 */   { 0 , 0, 
		"40;" },
/* NEGX 137 */   { 0 , 0, 
		"50;" },
/* NOP 138 */   { 0 , 0, 
		"9d;" },
/* ORA 139 */   { ADDR , DIRECT, 
		"BA;[1=];" },
/* ORA 140 */   { ADDR , EXTENDED, 
		"CA;[1=]x" },
/* ORA 141 */   { 0 , 0, 
		"AA;[1=];" },
/* ORA 142 */   { INDEXLEN , INDEX2, 
		"DA;[1=]x" },
/* ORA 143 */   { INDEXLEN , INDEX1, 
		"EA;[1=];" },
/* ORA 144 */   { INDEXLEN , INDEX0, 
		"FA;" },
/* ROL 145 */   { ADDR , DIRECT, 
		"39;[1=];" },
/* ROL 146 */   { INDEXLEN , INDEX1, 
		"69;[1=];" },
/* ROL 147 */   { INDEXLEN , INDEX0, 
		"79;" },
/* ROLA 148 */   { 0 , 0, 
		"49;" },
/* ROLX 149 */   { 0 , 0, 
		"59;" },
/* ROR 150 */   { ADDR , DIRECT, 
		"36;[1=];" },
/* ROR 151 */   { INDEXLEN , INDEX1, 
		"66;[1=];" },
/* ROR 152 */   { INDEXLEN , INDEX0, 
		"76;" },
/* RORA 153 */   { 0 , 0, 
		"46;" },
/* RORX 154 */   { 0 , 0, 
		"56;" },
/* RSP 155 */   { 0 , 0, 
		"9c;" },
/* RTI 156 */   { 0 , 0, 
		"80;" },
/* RTS 157 */   { 0 , 0, 
		"81;" },
/* SBC 158 */   { ADDR , DIRECT, 
		"B2;[1=];" },
/* SBC 159 */   { ADDR , EXTENDED, 
		"C2;[1=]x" },
/* SBC 160 */   { 0 , 0, 
		"A2;[1=];" },
/* SBC 161 */   { INDEXLEN , INDEX2, 
		"D2;[1=]x" },
/* SBC 162 */   { INDEXLEN , INDEX1, 
		"E2;[1=];" },
/* SBC 163 */   { INDEXLEN , INDEX0, 
		"F2;" },
/* SEC 164 */   { 0 , 0, 
		"99;" },
/* SEI 165 */   { 0 , 0, 
		"9b;" },
/* STA 166 */   { ADDR , DIRECT, 
		"B7;[1=];" },
/* STA 167 */   { ADDR , EXTENDED, 
		"C7;[1=]x" },
/* STA 168 */   { INDEXLEN , INDEX2, 
		"D7;[1=]x" },
/* STA 169 */   { INDEXLEN , INDEX1, 
		"E7;[1=];" },
/* STA 170 */   { INDEXLEN , INDEX0, 
		"F7;" },
/* STOP 171 */   { INSTSTWA , INSTSTWA, 
		"8e;" },
/* STX 172 */   { ADDR , DIRECT, 
		"BF;[1=];" },
/* STX 173 */   { ADDR , EXTENDED, 
		"CF;[1=]x" },
/* STX 174 */   { INDEXLEN , INDEX2, 
		"DF;[1=]x" },
/* STX 175 */   { INDEXLEN , INDEX1, 
		"EF;[1=];" },
/* STX 176 */   { INDEXLEN , INDEX0, 
		"FF;" },
/* SUB 177 */   { ADDR , DIRECT, 
		"B0;[1=];" },
/* SUB 178 */   { ADDR , EXTENDED, 
		"C0;[1=]x" },
/* SUB 179 */   { 0 , 0, 
		"A0;[1=];" },
/* SUB 180 */   { INDEXLEN , INDEX2, 
		"D0;[1=]x" },
/* SUB 181 */   { INDEXLEN , INDEX1, 
		"E0;[1=];" },
/* SUB 182 */   { INDEXLEN , INDEX0, 
		"F0;" },
/* SWI 183 */   { 0 , 0, 
		"83;" },
/* TAX 184 */   { 0 , 0, 
		"97;" },
/* TST 185 */   { ADDR , DIRECT, 
		"3D;[1=];" },
/* TST 186 */   { INDEXLEN , INDEX1, 
		"6D;[1=];" },
/* TST 187 */   { INDEXLEN , INDEX0, 
		"7D;" },
/* TSTA 188 */   { 0 , 0, 
		"4D;" },
/* TSTX 189 */   { 0 , 0, 
		"5D;" },
/* TXA 190 */   { 0 , 0, 
		"9f;" },
/* WAIT 191 */   { INSTSTWA , INSTSTWA, 
		"8f;" },
	{ 0,0,""} };
/* end fraptabdef.c */
