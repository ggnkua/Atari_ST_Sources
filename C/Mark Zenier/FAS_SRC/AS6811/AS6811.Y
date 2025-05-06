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
FILENAME: 	as6811.y;
WARNINGS: 	"This software is in the public domain.  
		Any prior copyright claims are relinquished.  

		This software is distributed with no warranty whatever.  
		The author takes no responsibility for the consequences 
		of its use.

		Yacc (or Bison) required to compile."  ;
SEE-ALSO: 	as6811.doc,frasmain.c;	
AUTHORS: 	Mark Zenier;
COMPILERS: 	Microport Sys V/AT, ATT Yacc, Turbo C V1.5, Bison (CUG disk 285)
		(previous versions Xenix, Unisoft 68000 Version 7, Sun 3);
*/
/* 6811 instruction generation file */
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
	description	Selection criteria and token values for 6811
			framework assembler
	usage		framework cross assembler
	history		September 19, 1987
*/

		/* 000000xxxx */
#define CPUMASK		0xf
#define CPU6800		0x1	/* cpuselect value in parser */
#define CPU6801		0x3
#define CPU6811		0x7
#define TS6800PLUS	0x1	/* mask and match values in table */
#define TS6801PLUS	0x2	/* if select value & mask == mask */
#define TS6811		0x4

		/* 0000xx0000 */
#define ACCREG		0x30
#define REGA		0x10
#define REGB		0x20

		/* 00xx000000 */
#define INDREG		0xc0
#define REGX		0x40
#define REGY		0x80

		/* xx00000000 */
#define ADDR		0x300
#define DIRECT		0x100
#define EXTENDED	0x200


#define ST_ACC 0x1
#define ST_AEXP 0x2
#define ST_AIMM 0x4
#define ST_AIND 0x8
#define ST_BRSET 0x10
#define ST_BSET 0x20
#define ST_EXP 0x40
#define ST_IBRSET 0x80
#define ST_IBSET 0x100
#define ST_IMM 0x200
#define ST_IND 0x400
#define ST_INDREG 0x800
#define ST_INH 0x1000
	
	
	int	cpuselect = CPU6811;
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

%token <intv> ACCUM
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
			fraerror("unknown cpu type, 68hc11 assumed");
			cpuselect = CPU6811;
		}
			}
	;
genline : KOC_opcode  ACCUM
			{
		genlocrec(currseg, labelloc);
		locctr += geninstr(findgen($1, ST_ACC, $2 + cpuselect));
			}
	;
genline : KOC_opcode  ACCUM expr
			{
		pevalexpr(1, $3);
		genlocrec(currseg, labelloc);
		locctr += geninstr(findgen( $1, ST_AEXP, cpuselect + $2
				 + ( (evalr[1].seg == SSG_ABS 
				&& evalr[1].value >= 0
				&& evalr[1].value <= 255 )
				? DIRECT : EXTENDED ) ) );
			}
	;
genline : KOC_opcode  ACCUM '#' expr
			{
		pevalexpr(1,$4);
		genlocrec(currseg, labelloc);
		locctr += geninstr( findgen($1, ST_AIMM, $2 + cpuselect));
			}
	;
genline : KOC_opcode  ACCUM indexed
			{
		pevalexpr(1, $3.ex);
		genlocrec(currseg, labelloc);
		locctr += geninstr( findgen($1, ST_AIND, cpuselect
					+ $2 + $3.indexv));
			}
	;
genline : KOC_opcode  expr ',' expr ',' expr
			{
		pevalexpr(1,$2);
		pevalexpr(2,$4);
		pevalexpr(3,$6);
		genlocrec(currseg, labelloc);
		locctr += geninstr( findgen($1, ST_BRSET, cpuselect));
			}
	;
genline : KOC_opcode  expr ',' expr
			{
		pevalexpr(1,$2);
		pevalexpr(2,$4);
		genlocrec(currseg, labelloc);
		locctr += geninstr( findgen( $1, ST_BSET, cpuselect));
			}
	;
genline : KOC_opcode  expr
			{
		pevalexpr(1, $2);
		genlocrec(currseg, labelloc);
		locctr += geninstr( findgen( $1, ST_EXP, cpuselect 
				 + ( (evalr[1].seg == SSG_ABS 
				&& evalr[1].value >= 0
				&& evalr[1].value <= 255 )
				? DIRECT : EXTENDED ) )
				);
			}
	;
genline : KOC_opcode  indexed ',' expr ',' expr
			{
		pevalexpr(1,$2.ex);
		pevalexpr(2,$4);
		pevalexpr(3,$6);
		genlocrec(currseg, labelloc);
		locctr += geninstr( findgen($1, ST_IBRSET, cpuselect
					+ $2.indexv));
			}
	;
genline : KOC_opcode  indexed ',' expr
			{
		pevalexpr(1,$2.ex);
		pevalexpr(2,$4);
		genlocrec(currseg, labelloc);
		locctr += geninstr( findgen($1, ST_IBSET, cpuselect
					+ $2.indexv));
			}
	;
genline : KOC_opcode  '#' expr
			{
		pevalexpr(1, $3);
		genlocrec(currseg, labelloc);
		locctr += geninstr( findgen($1, ST_IMM, cpuselect));
			}
	;
genline : KOC_opcode  indexed
			{
		pevalexpr(1, $2.ex);
		genlocrec(currseg, labelloc);
		locctr += geninstr( findgen($1, ST_IND, cpuselect 
					+ ($2.indexv)));
			}
	;
genline : KOC_opcode  INDEX
			{
		genlocrec(currseg, labelloc);
		locctr += geninstr(findgen($1, ST_INDREG, $2 + cpuselect));
			}
	;
genline : KOC_opcode 
			{
		genlocrec(currseg, labelloc);
		locctr += geninstr(findgen($1, ST_INH, cpuselect));
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


indexed	:	INDEX ',' expr
			{
				$$.ex = $3;
				$$.indexv = $1;
			}
	|	expr ',' INDEX
			{
				$$.ex = $1;
				$$.indexv = $3;
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


	reservedsym("a", ACCUM, REGA);
	reservedsym("b", ACCUM, REGB);
	reservedsym("x", INDEX, REGX);
	reservedsym("y", INDEX, REGY);
	reservedsym("A", ACCUM, REGA);
	reservedsym("B", ACCUM, REGB);
	reservedsym("X", INDEX, REGX);
	reservedsym("Y", INDEX, REGY);

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
		{"11", CPU6811},
		{"01", CPU6801},
		{"00", CPU6800},
		{"03", CPU6801},
		{"02", CPU6800},
		{"08", CPU6800},
		{"", 0} 
	};

	for(msub = 0; matchtab[msub].cpuv != 0; msub++)
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

#define NUMOPCODE 183
#define NUMSYNBLK 277
#define NUMDIFFOP 459

int gnumopcode = NUMOPCODE;

int ophashlnk[NUMOPCODE];

struct opsym optab[NUMOPCODE+1]
	= {
	{"invalid", KOC_opcode, 2, 0 },
	{"ABA", KOC_opcode, 1, 2 },
	{"ABX", KOC_opcode, 1, 3 },
	{"ABY", KOC_opcode, 1, 4 },
	{"ADC", KOC_opcode, 3, 5 },
	{"ADCA", KOC_opcode, 3, 8 },
	{"ADCB", KOC_opcode, 3, 11 },
	{"ADD", KOC_opcode, 3, 14 },
	{"ADDA", KOC_opcode, 3, 17 },
	{"ADDB", KOC_opcode, 3, 20 },
	{"ADDD", KOC_opcode, 3, 23 },
	{"AND", KOC_opcode, 3, 26 },
	{"ANDA", KOC_opcode, 3, 29 },
	{"ANDB", KOC_opcode, 3, 32 },
	{"ASL", KOC_opcode, 3, 35 },
	{"ASLA", KOC_opcode, 1, 38 },
	{"ASLB", KOC_opcode, 1, 39 },
	{"ASLD", KOC_opcode, 1, 40 },
	{"ASR", KOC_opcode, 3, 41 },
	{"ASRA", KOC_opcode, 1, 44 },
	{"ASRB", KOC_opcode, 1, 45 },
	{"BCC", KOC_opcode, 1, 46 },
	{"BCLR", KOC_opcode, 2, 47 },
	{"BCS", KOC_opcode, 1, 49 },
	{"BEQ", KOC_opcode, 1, 50 },
	{"BGE", KOC_opcode, 1, 51 },
	{"BGT", KOC_opcode, 1, 52 },
	{"BHI", KOC_opcode, 1, 53 },
	{"BHS", KOC_opcode, 1, 54 },
	{"BIT", KOC_opcode, 3, 55 },
	{"BITA", KOC_opcode, 3, 58 },
	{"BITB", KOC_opcode, 3, 61 },
	{"BLE", KOC_opcode, 1, 64 },
	{"BLO", KOC_opcode, 1, 65 },
	{"BLS", KOC_opcode, 1, 66 },
	{"BLT", KOC_opcode, 1, 67 },
	{"BMI", KOC_opcode, 1, 68 },
	{"BNE", KOC_opcode, 1, 69 },
	{"BPL", KOC_opcode, 1, 70 },
	{"BRA", KOC_opcode, 1, 71 },
	{"BRCLR", KOC_opcode, 2, 72 },
	{"BRN", KOC_opcode, 1, 74 },
	{"BRSET", KOC_opcode, 2, 75 },
	{"BSET", KOC_opcode, 2, 77 },
	{"BSR", KOC_opcode, 1, 79 },
	{"BVC", KOC_opcode, 1, 80 },
	{"BVS", KOC_opcode, 1, 81 },
	{"BYTE", KOC_BDEF, 0, 0 },
	{"CBA", KOC_opcode, 1, 82 },
	{"CHARDEF", KOC_CHDEF, 0, 0 },
	{"CHARSET", KOC_CHSET, 0, 0 },
	{"CHARUSE", KOC_CHUSE, 0, 0 },
	{"CHD", KOC_CHDEF, 0, 0 },
	{"CLC", KOC_opcode, 1, 83 },
	{"CLI", KOC_opcode, 1, 84 },
	{"CLR", KOC_opcode, 3, 85 },
	{"CLRA", KOC_opcode, 1, 88 },
	{"CLRB", KOC_opcode, 1, 89 },
	{"CLV", KOC_opcode, 1, 90 },
	{"CMP", KOC_opcode, 3, 91 },
	{"CMPA", KOC_opcode, 3, 94 },
	{"CMPB", KOC_opcode, 3, 97 },
	{"COM", KOC_opcode, 3, 100 },
	{"COMA", KOC_opcode, 1, 103 },
	{"COMB", KOC_opcode, 1, 104 },
	{"CPD", KOC_opcode, 3, 105 },
	{"CPU", KOC_CPU, 0, 0 },
	{"CPX", KOC_opcode, 3, 108 },
	{"CPY", KOC_opcode, 3, 111 },
	{"DAA", KOC_opcode, 1, 114 },
	{"DB", KOC_BDEF, 0, 0 },
	{"DEC", KOC_opcode, 3, 115 },
	{"DECA", KOC_opcode, 1, 118 },
	{"DECB", KOC_opcode, 1, 119 },
	{"DES", KOC_opcode, 1, 120 },
	{"DEX", KOC_opcode, 1, 121 },
	{"DEY", KOC_opcode, 1, 122 },
	{"DW", KOC_WDEF, 0, 0 },
	{"ELSE", KOC_ELSE, 0, 0 },
	{"END", KOC_END, 0, 0 },
	{"ENDI", KOC_ENDI, 0, 0 },
	{"EOR", KOC_opcode, 3, 123 },
	{"EORA", KOC_opcode, 3, 126 },
	{"EORB", KOC_opcode, 3, 129 },
	{"EQU", KOC_EQU, 0, 0 },
	{"FCB", KOC_BDEF, 0, 0 },
	{"FCC", KOC_SDEF, 0, 0 },
	{"FDB", KOC_WDEF, 0, 0 },
	{"FDIV", KOC_opcode, 1, 132 },
	{"IDIV", KOC_opcode, 1, 133 },
	{"IF", KOC_IF, 0, 0 },
	{"INC", KOC_opcode, 3, 134 },
	{"INCA", KOC_opcode, 1, 137 },
	{"INCB", KOC_opcode, 1, 138 },
	{"INCL", KOC_INCLUDE, 0, 0 },
	{"INCLUDE", KOC_INCLUDE, 0, 0 },
	{"INS", KOC_opcode, 1, 139 },
	{"INX", KOC_opcode, 1, 140 },
	{"INY", KOC_opcode, 1, 141 },
	{"JMP", KOC_opcode, 2, 142 },
	{"JSR", KOC_opcode, 2, 144 },
	{"LDA", KOC_opcode, 3, 146 },
	{"LDAA", KOC_opcode, 3, 149 },
	{"LDAB", KOC_opcode, 3, 152 },
	{"LDD", KOC_opcode, 3, 155 },
	{"LDS", KOC_opcode, 3, 158 },
	{"LDX", KOC_opcode, 3, 161 },
	{"LDY", KOC_opcode, 3, 164 },
	{"LSL", KOC_opcode, 3, 167 },
	{"LSLA", KOC_opcode, 1, 170 },
	{"LSLB", KOC_opcode, 1, 171 },
	{"LSLD", KOC_opcode, 1, 172 },
	{"LSR", KOC_opcode, 3, 173 },
	{"LSRA", KOC_opcode, 1, 176 },
	{"LSRB", KOC_opcode, 1, 177 },
	{"LSRD", KOC_opcode, 1, 178 },
	{"MUL", KOC_opcode, 1, 179 },
	{"NEG", KOC_opcode, 3, 180 },
	{"NEGA", KOC_opcode, 1, 183 },
	{"NEGB", KOC_opcode, 1, 184 },
	{"NOP", KOC_opcode, 1, 185 },
	{"ORA", KOC_opcode, 3, 186 },
	{"ORAA", KOC_opcode, 3, 189 },
	{"ORAB", KOC_opcode, 3, 192 },
	{"ORG", KOC_ORG, 0, 0 },
	{"PSH", KOC_opcode, 2, 195 },
	{"PSHA", KOC_opcode, 1, 197 },
	{"PSHB", KOC_opcode, 1, 198 },
	{"PSHX", KOC_opcode, 1, 199 },
	{"PSHY", KOC_opcode, 1, 200 },
	{"PUL", KOC_opcode, 2, 201 },
	{"PULA", KOC_opcode, 1, 203 },
	{"PULB", KOC_opcode, 1, 204 },
	{"PULX", KOC_opcode, 1, 205 },
	{"PULY", KOC_opcode, 1, 206 },
	{"RESERVE", KOC_RESM, 0, 0 },
	{"RMB", KOC_RESM, 0, 0 },
	{"ROL", KOC_opcode, 3, 207 },
	{"ROLA", KOC_opcode, 1, 210 },
	{"ROLB", KOC_opcode, 1, 211 },
	{"ROR", KOC_opcode, 3, 212 },
	{"RORA", KOC_opcode, 1, 215 },
	{"RORB", KOC_opcode, 1, 216 },
	{"RTI", KOC_opcode, 1, 217 },
	{"RTS", KOC_opcode, 1, 218 },
	{"SBA", KOC_opcode, 1, 219 },
	{"SBC", KOC_opcode, 3, 220 },
	{"SBCA", KOC_opcode, 3, 223 },
	{"SBCB", KOC_opcode, 3, 226 },
	{"SEC", KOC_opcode, 1, 229 },
	{"SEI", KOC_opcode, 1, 230 },
	{"SET", KOC_SET, 0, 0 },
	{"SEV", KOC_opcode, 1, 231 },
	{"STA", KOC_opcode, 2, 232 },
	{"STAA", KOC_opcode, 2, 234 },
	{"STAB", KOC_opcode, 2, 236 },
	{"STD", KOC_opcode, 2, 238 },
	{"STOP", KOC_opcode, 1, 240 },
	{"STRING", KOC_SDEF, 0, 0 },
	{"STS", KOC_opcode, 2, 241 },
	{"STX", KOC_opcode, 2, 243 },
	{"STY", KOC_opcode, 2, 245 },
	{"SUB", KOC_opcode, 3, 247 },
	{"SUBA", KOC_opcode, 3, 250 },
	{"SUBB", KOC_opcode, 3, 253 },
	{"SUBD", KOC_opcode, 3, 256 },
	{"SWI", KOC_opcode, 1, 259 },
	{"TAB", KOC_opcode, 1, 260 },
	{"TAP", KOC_opcode, 1, 261 },
	{"TBA", KOC_opcode, 1, 262 },
	{"TEST", KOC_opcode, 1, 263 },
	{"TPA", KOC_opcode, 1, 264 },
	{"TST", KOC_opcode, 3, 265 },
	{"TSTA", KOC_opcode, 1, 268 },
	{"TSTB", KOC_opcode, 1, 269 },
	{"TSX", KOC_opcode, 1, 270 },
	{"TSY", KOC_opcode, 1, 271 },
	{"TXS", KOC_opcode, 1, 272 },
	{"TYS", KOC_opcode, 1, 273 },
	{"WAI", KOC_opcode, 1, 274 },
	{"WORD", KOC_WDEF, 0, 0 },
	{"XGDX", KOC_opcode, 1, 275 },
	{"XGDY", KOC_opcode, 1, 276 },
	{ "", 0, 0, 0 }};

struct opsynt ostab[NUMSYNBLK+1]
	= {
/* invalid 0 */ { 0, 1, 0 },
/* invalid 1 */ { 0xffff, 1, 1 },
/* ABA 2 */ { ST_INH, 1, 2 },
/* ABX 3 */ { ST_INH, 1, 3 },
/* ABY 4 */ { ST_INH, 1, 4 },
/* ADC 5 */ { ST_AEXP, 4, 5 },
/* ADC 6 */ { ST_AIMM, 2, 9 },
/* ADC 7 */ { ST_AIND, 4, 11 },
/* ADCA 8 */ { ST_EXP, 2, 15 },
/* ADCA 9 */ { ST_IMM, 1, 17 },
/* ADCA 10 */ { ST_IND, 2, 18 },
/* ADCB 11 */ { ST_EXP, 2, 20 },
/* ADCB 12 */ { ST_IMM, 1, 22 },
/* ADCB 13 */ { ST_IND, 2, 23 },
/* ADD 14 */ { ST_AEXP, 4, 25 },
/* ADD 15 */ { ST_AIMM, 2, 29 },
/* ADD 16 */ { ST_AIND, 4, 31 },
/* ADDA 17 */ { ST_EXP, 2, 35 },
/* ADDA 18 */ { ST_IMM, 1, 37 },
/* ADDA 19 */ { ST_IND, 2, 38 },
/* ADDB 20 */ { ST_EXP, 2, 40 },
/* ADDB 21 */ { ST_IMM, 1, 42 },
/* ADDB 22 */ { ST_IND, 2, 43 },
/* ADDD 23 */ { ST_EXP, 2, 45 },
/* ADDD 24 */ { ST_IMM, 1, 47 },
/* ADDD 25 */ { ST_IND, 2, 48 },
/* AND 26 */ { ST_AEXP, 4, 50 },
/* AND 27 */ { ST_AIMM, 2, 54 },
/* AND 28 */ { ST_AIND, 4, 56 },
/* ANDA 29 */ { ST_EXP, 2, 60 },
/* ANDA 30 */ { ST_IMM, 1, 62 },
/* ANDA 31 */ { ST_IND, 2, 63 },
/* ANDB 32 */ { ST_EXP, 2, 65 },
/* ANDB 33 */ { ST_IMM, 1, 67 },
/* ANDB 34 */ { ST_IND, 2, 68 },
/* ASL 35 */ { ST_ACC, 2, 70 },
/* ASL 36 */ { ST_EXP, 1, 72 },
/* ASL 37 */ { ST_IND, 2, 73 },
/* ASLA 38 */ { ST_INH, 1, 75 },
/* ASLB 39 */ { ST_INH, 1, 76 },
/* ASLD 40 */ { ST_INH, 1, 77 },
/* ASR 41 */ { ST_ACC, 2, 78 },
/* ASR 42 */ { ST_EXP, 1, 80 },
/* ASR 43 */ { ST_IND, 2, 81 },
/* ASRA 44 */ { ST_INH, 1, 83 },
/* ASRB 45 */ { ST_INH, 1, 84 },
/* BCC 46 */ { ST_EXP, 1, 85 },
/* BCLR 47 */ { ST_BSET, 1, 86 },
/* BCLR 48 */ { ST_IBSET, 2, 87 },
/* BCS 49 */ { ST_EXP, 1, 89 },
/* BEQ 50 */ { ST_EXP, 1, 90 },
/* BGE 51 */ { ST_EXP, 1, 91 },
/* BGT 52 */ { ST_EXP, 1, 92 },
/* BHI 53 */ { ST_EXP, 1, 93 },
/* BHS 54 */ { ST_EXP, 1, 94 },
/* BIT 55 */ { ST_AEXP, 4, 95 },
/* BIT 56 */ { ST_AIMM, 2, 99 },
/* BIT 57 */ { ST_AIND, 4, 101 },
/* BITA 58 */ { ST_EXP, 2, 105 },
/* BITA 59 */ { ST_IMM, 1, 107 },
/* BITA 60 */ { ST_IND, 2, 108 },
/* BITB 61 */ { ST_EXP, 2, 110 },
/* BITB 62 */ { ST_IMM, 1, 112 },
/* BITB 63 */ { ST_IND, 2, 113 },
/* BLE 64 */ { ST_EXP, 1, 115 },
/* BLO 65 */ { ST_EXP, 1, 116 },
/* BLS 66 */ { ST_EXP, 1, 117 },
/* BLT 67 */ { ST_EXP, 1, 118 },
/* BMI 68 */ { ST_EXP, 1, 119 },
/* BNE 69 */ { ST_EXP, 1, 120 },
/* BPL 70 */ { ST_EXP, 1, 121 },
/* BRA 71 */ { ST_EXP, 1, 122 },
/* BRCLR 72 */ { ST_BRSET, 1, 123 },
/* BRCLR 73 */ { ST_IBRSET, 2, 124 },
/* BRN 74 */ { ST_EXP, 1, 126 },
/* BRSET 75 */ { ST_BRSET, 1, 127 },
/* BRSET 76 */ { ST_IBRSET, 2, 128 },
/* BSET 77 */ { ST_BSET, 1, 130 },
/* BSET 78 */ { ST_IBSET, 2, 131 },
/* BSR 79 */ { ST_EXP, 1, 133 },
/* BVC 80 */ { ST_EXP, 1, 134 },
/* BVS 81 */ { ST_EXP, 1, 135 },
/* CBA 82 */ { ST_INH, 1, 136 },
/* CLC 83 */ { ST_INH, 1, 137 },
/* CLI 84 */ { ST_INH, 1, 138 },
/* CLR 85 */ { ST_ACC, 2, 139 },
/* CLR 86 */ { ST_EXP, 1, 141 },
/* CLR 87 */ { ST_IND, 2, 142 },
/* CLRA 88 */ { ST_INH, 1, 144 },
/* CLRB 89 */ { ST_INH, 1, 145 },
/* CLV 90 */ { ST_INH, 1, 146 },
/* CMP 91 */ { ST_AEXP, 4, 147 },
/* CMP 92 */ { ST_AIMM, 2, 151 },
/* CMP 93 */ { ST_AIND, 4, 153 },
/* CMPA 94 */ { ST_EXP, 2, 157 },
/* CMPA 95 */ { ST_IMM, 1, 159 },
/* CMPA 96 */ { ST_IND, 2, 160 },
/* CMPB 97 */ { ST_EXP, 2, 162 },
/* CMPB 98 */ { ST_IMM, 1, 164 },
/* CMPB 99 */ { ST_IND, 2, 165 },
/* COM 100 */ { ST_ACC, 2, 167 },
/* COM 101 */ { ST_EXP, 1, 169 },
/* COM 102 */ { ST_IND, 2, 170 },
/* COMA 103 */ { ST_INH, 1, 172 },
/* COMB 104 */ { ST_INH, 1, 173 },
/* CPD 105 */ { ST_EXP, 2, 174 },
/* CPD 106 */ { ST_IMM, 1, 176 },
/* CPD 107 */ { ST_IND, 2, 177 },
/* CPX 108 */ { ST_EXP, 2, 179 },
/* CPX 109 */ { ST_IMM, 1, 181 },
/* CPX 110 */ { ST_IND, 2, 182 },
/* CPY 111 */ { ST_EXP, 2, 184 },
/* CPY 112 */ { ST_IMM, 1, 186 },
/* CPY 113 */ { ST_IND, 2, 187 },
/* DAA 114 */ { ST_INH, 1, 189 },
/* DEC 115 */ { ST_ACC, 2, 190 },
/* DEC 116 */ { ST_EXP, 1, 192 },
/* DEC 117 */ { ST_IND, 2, 193 },
/* DECA 118 */ { ST_INH, 1, 195 },
/* DECB 119 */ { ST_INH, 1, 196 },
/* DES 120 */ { ST_INH, 1, 197 },
/* DEX 121 */ { ST_INH, 1, 198 },
/* DEY 122 */ { ST_INH, 1, 199 },
/* EOR 123 */ { ST_AEXP, 4, 200 },
/* EOR 124 */ { ST_AIMM, 2, 204 },
/* EOR 125 */ { ST_AIND, 4, 206 },
/* EORA 126 */ { ST_EXP, 2, 210 },
/* EORA 127 */ { ST_IMM, 1, 212 },
/* EORA 128 */ { ST_IND, 2, 213 },
/* EORB 129 */ { ST_EXP, 2, 215 },
/* EORB 130 */ { ST_IMM, 1, 217 },
/* EORB 131 */ { ST_IND, 2, 218 },
/* FDIV 132 */ { ST_INH, 1, 220 },
/* IDIV 133 */ { ST_INH, 1, 221 },
/* INC 134 */ { ST_ACC, 2, 222 },
/* INC 135 */ { ST_EXP, 1, 224 },
/* INC 136 */ { ST_IND, 2, 225 },
/* INCA 137 */ { ST_INH, 1, 227 },
/* INCB 138 */ { ST_INH, 1, 228 },
/* INS 139 */ { ST_INH, 1, 229 },
/* INX 140 */ { ST_INH, 1, 230 },
/* INY 141 */ { ST_INH, 1, 231 },
/* JMP 142 */ { ST_EXP, 1, 232 },
/* JMP 143 */ { ST_IND, 2, 233 },
/* JSR 144 */ { ST_EXP, 3, 235 },
/* JSR 145 */ { ST_IND, 2, 238 },
/* LDA 146 */ { ST_AEXP, 4, 240 },
/* LDA 147 */ { ST_AIMM, 2, 244 },
/* LDA 148 */ { ST_AIND, 4, 246 },
/* LDAA 149 */ { ST_EXP, 2, 250 },
/* LDAA 150 */ { ST_IMM, 1, 252 },
/* LDAA 151 */ { ST_IND, 2, 253 },
/* LDAB 152 */ { ST_EXP, 2, 255 },
/* LDAB 153 */ { ST_IMM, 1, 257 },
/* LDAB 154 */ { ST_IND, 2, 258 },
/* LDD 155 */ { ST_EXP, 2, 260 },
/* LDD 156 */ { ST_IMM, 1, 262 },
/* LDD 157 */ { ST_IND, 2, 263 },
/* LDS 158 */ { ST_EXP, 2, 265 },
/* LDS 159 */ { ST_IMM, 1, 267 },
/* LDS 160 */ { ST_IND, 2, 268 },
/* LDX 161 */ { ST_EXP, 2, 270 },
/* LDX 162 */ { ST_IMM, 1, 272 },
/* LDX 163 */ { ST_IND, 2, 273 },
/* LDY 164 */ { ST_EXP, 2, 275 },
/* LDY 165 */ { ST_IMM, 1, 277 },
/* LDY 166 */ { ST_IND, 2, 278 },
/* LSL 167 */ { ST_ACC, 2, 280 },
/* LSL 168 */ { ST_EXP, 1, 282 },
/* LSL 169 */ { ST_IND, 2, 283 },
/* LSLA 170 */ { ST_INH, 1, 285 },
/* LSLB 171 */ { ST_INH, 1, 286 },
/* LSLD 172 */ { ST_INH, 1, 287 },
/* LSR 173 */ { ST_ACC, 2, 288 },
/* LSR 174 */ { ST_EXP, 1, 290 },
/* LSR 175 */ { ST_IND, 2, 291 },
/* LSRA 176 */ { ST_INH, 1, 293 },
/* LSRB 177 */ { ST_INH, 1, 294 },
/* LSRD 178 */ { ST_INH, 1, 295 },
/* MUL 179 */ { ST_INH, 1, 296 },
/* NEG 180 */ { ST_ACC, 2, 297 },
/* NEG 181 */ { ST_EXP, 1, 299 },
/* NEG 182 */ { ST_IND, 2, 300 },
/* NEGA 183 */ { ST_INH, 1, 302 },
/* NEGB 184 */ { ST_INH, 1, 303 },
/* NOP 185 */ { ST_INH, 1, 304 },
/* ORA 186 */ { ST_AEXP, 4, 305 },
/* ORA 187 */ { ST_AIMM, 2, 309 },
/* ORA 188 */ { ST_AIND, 4, 311 },
/* ORAA 189 */ { ST_EXP, 2, 315 },
/* ORAA 190 */ { ST_IMM, 1, 317 },
/* ORAA 191 */ { ST_IND, 2, 318 },
/* ORAB 192 */ { ST_EXP, 2, 320 },
/* ORAB 193 */ { ST_IMM, 1, 322 },
/* ORAB 194 */ { ST_IND, 2, 323 },
/* PSH 195 */ { ST_ACC, 2, 325 },
/* PSH 196 */ { ST_INDREG, 2, 327 },
/* PSHA 197 */ { ST_INH, 1, 329 },
/* PSHB 198 */ { ST_INH, 1, 330 },
/* PSHX 199 */ { ST_INH, 1, 331 },
/* PSHY 200 */ { ST_INH, 1, 332 },
/* PUL 201 */ { ST_ACC, 2, 333 },
/* PUL 202 */ { ST_INDREG, 2, 335 },
/* PULA 203 */ { ST_INH, 1, 337 },
/* PULB 204 */ { ST_INH, 1, 338 },
/* PULX 205 */ { ST_INH, 1, 339 },
/* PULY 206 */ { ST_INH, 1, 340 },
/* ROL 207 */ { ST_ACC, 2, 341 },
/* ROL 208 */ { ST_EXP, 1, 343 },
/* ROL 209 */ { ST_IND, 2, 344 },
/* ROLA 210 */ { ST_INH, 1, 346 },
/* ROLB 211 */ { ST_INH, 1, 347 },
/* ROR 212 */ { ST_ACC, 2, 348 },
/* ROR 213 */ { ST_EXP, 1, 350 },
/* ROR 214 */ { ST_IND, 2, 351 },
/* RORA 215 */ { ST_INH, 1, 353 },
/* RORB 216 */ { ST_INH, 1, 354 },
/* RTI 217 */ { ST_INH, 1, 355 },
/* RTS 218 */ { ST_INH, 1, 356 },
/* SBA 219 */ { ST_INH, 1, 357 },
/* SBC 220 */ { ST_AEXP, 4, 358 },
/* SBC 221 */ { ST_AIMM, 2, 362 },
/* SBC 222 */ { ST_AIND, 4, 364 },
/* SBCA 223 */ { ST_EXP, 2, 368 },
/* SBCA 224 */ { ST_IMM, 1, 370 },
/* SBCA 225 */ { ST_IND, 2, 371 },
/* SBCB 226 */ { ST_EXP, 2, 373 },
/* SBCB 227 */ { ST_IMM, 1, 375 },
/* SBCB 228 */ { ST_IND, 2, 376 },
/* SEC 229 */ { ST_INH, 1, 378 },
/* SEI 230 */ { ST_INH, 1, 379 },
/* SEV 231 */ { ST_INH, 1, 380 },
/* STA 232 */ { ST_AEXP, 4, 381 },
/* STA 233 */ { ST_AIND, 4, 385 },
/* STAA 234 */ { ST_EXP, 2, 389 },
/* STAA 235 */ { ST_IND, 2, 391 },
/* STAB 236 */ { ST_EXP, 2, 393 },
/* STAB 237 */ { ST_IND, 2, 395 },
/* STD 238 */ { ST_EXP, 2, 397 },
/* STD 239 */ { ST_IND, 2, 399 },
/* STOP 240 */ { ST_INH, 1, 401 },
/* STS 241 */ { ST_EXP, 2, 402 },
/* STS 242 */ { ST_IND, 2, 404 },
/* STX 243 */ { ST_EXP, 2, 406 },
/* STX 244 */ { ST_IND, 2, 408 },
/* STY 245 */ { ST_EXP, 2, 410 },
/* STY 246 */ { ST_IND, 2, 412 },
/* SUB 247 */ { ST_AEXP, 4, 414 },
/* SUB 248 */ { ST_AIMM, 2, 418 },
/* SUB 249 */ { ST_AIND, 4, 420 },
/* SUBA 250 */ { ST_EXP, 2, 424 },
/* SUBA 251 */ { ST_IMM, 1, 426 },
/* SUBA 252 */ { ST_IND, 2, 427 },
/* SUBB 253 */ { ST_EXP, 2, 429 },
/* SUBB 254 */ { ST_IMM, 1, 431 },
/* SUBB 255 */ { ST_IND, 2, 432 },
/* SUBD 256 */ { ST_EXP, 2, 434 },
/* SUBD 257 */ { ST_IMM, 1, 436 },
/* SUBD 258 */ { ST_IND, 2, 437 },
/* SWI 259 */ { ST_INH, 1, 439 },
/* TAB 260 */ { ST_INH, 1, 440 },
/* TAP 261 */ { ST_INH, 1, 441 },
/* TBA 262 */ { ST_INH, 1, 442 },
/* TEST 263 */ { ST_INH, 1, 443 },
/* TPA 264 */ { ST_INH, 1, 444 },
/* TST 265 */ { ST_ACC, 2, 445 },
/* TST 266 */ { ST_EXP, 1, 447 },
/* TST 267 */ { ST_IND, 2, 448 },
/* TSTA 268 */ { ST_INH, 1, 450 },
/* TSTB 269 */ { ST_INH, 1, 451 },
/* TSX 270 */ { ST_INH, 1, 452 },
/* TSY 271 */ { ST_INH, 1, 453 },
/* TXS 272 */ { ST_INH, 1, 454 },
/* TYS 273 */ { ST_INH, 1, 455 },
/* WAI 274 */ { ST_INH, 1, 456 },
/* XGDX 275 */ { ST_INH, 1, 457 },
/* XGDY 276 */ { ST_INH, 1, 458 },
	{ 0, 0, 0 } };

struct igel igtab[NUMDIFFOP+1]
	= {
/* invalid 0 */   { 0 , 0, 
		"[Xnullentry" },
/* invalid 1 */   { 0 , 0, 
		"[Xinvalid opcode" },
/* ABA 2 */   { 0 , 0, 
		"1b;" },
/* ABX 3 */   { TS6801PLUS , TS6801PLUS, 
		"3a;" },
/* ABY 4 */   { TS6811 , TS6811, 
		"18;3a;" },
/* ADC 5 */   { ACCREG+ADDR , REGA+DIRECT, 
		"99;[1=];" },
/* ADC 6 */   { ACCREG+ADDR , REGA+EXTENDED, 
		"b9;[1=]x" },
/* ADC 7 */   { ACCREG+ADDR , REGB+DIRECT, 
		"d9;[1=];" },
/* ADC 8 */   { ACCREG+ADDR , REGB+EXTENDED, 
		"f9;[1=]x" },
/* ADC 9 */   { ACCREG , REGA, 
		"89;[1=];" },
/* ADC 10 */   { ACCREG , REGB, 
		"c9;[1=];" },
/* ADC 11 */   { ACCREG+INDREG , REGA+REGX, 
		"a9;[1=];" },
/* ADC 12 */   { ACCREG+INDREG+TS6811 , REGA+REGY+TS6811, 
		"18;a9;[1=];" },
/* ADC 13 */   { ACCREG+INDREG , REGB+REGX, 
		"e9;[1=];" },
/* ADC 14 */   { ACCREG+INDREG+TS6811 , REGB+REGY+TS6811, 
		"18;e9;[1=];" },
/* ADCA 15 */   { ADDR , DIRECT, 
		"99;[1=];" },
/* ADCA 16 */   { ADDR , EXTENDED, 
		"b9;[1=]x" },
/* ADCA 17 */   { 0 , 0, 
		"89;[1=];" },
/* ADCA 18 */   { INDREG , REGX, 
		"a9;[1=];" },
/* ADCA 19 */   { INDREG+TS6811 , REGY+TS6811, 
		"18;a9;[1=];" },
/* ADCB 20 */   { ADDR , DIRECT, 
		"d9;[1=];" },
/* ADCB 21 */   { ADDR , EXTENDED, 
		"f9;[1=]x" },
/* ADCB 22 */   { 0 , 0, 
		"c9;[1=];" },
/* ADCB 23 */   { INDREG , REGX, 
		"e9;[1=];" },
/* ADCB 24 */   { INDREG+TS6811 , REGY+TS6811, 
		"18;e9;[1=];" },
/* ADD 25 */   { ACCREG+ADDR , REGA+DIRECT, 
		"9b;[1=];" },
/* ADD 26 */   { ACCREG+ADDR , REGA+EXTENDED, 
		"bb;[1=]x" },
/* ADD 27 */   { ACCREG+ADDR , REGB+DIRECT, 
		"db;[1=];" },
/* ADD 28 */   { ACCREG+ADDR , REGB+EXTENDED, 
		"fb;[1=]x" },
/* ADD 29 */   { ACCREG , REGA, 
		"8b;[1=];" },
/* ADD 30 */   { ACCREG , REGB, 
		"cb;[1=];" },
/* ADD 31 */   { ACCREG+INDREG , REGA+REGX, 
		"ab;[1=];" },
/* ADD 32 */   { ACCREG+INDREG+TS6811 , REGA+REGY+TS6811, 
		"18;ab;[1=];" },
/* ADD 33 */   { ACCREG+INDREG , REGB+REGX, 
		"eb;[1=];" },
/* ADD 34 */   { ACCREG+INDREG+TS6811 , REGB+REGY+TS6811, 
		"18;eb;[1=];" },
/* ADDA 35 */   { ADDR , DIRECT, 
		"9b;[1=];" },
/* ADDA 36 */   { ADDR , EXTENDED, 
		"bb;[1=]x" },
/* ADDA 37 */   { 0 , 0, 
		"8b;[1=];" },
/* ADDA 38 */   { INDREG , REGX, 
		"ab;[1=];" },
/* ADDA 39 */   { INDREG+TS6811 , REGY+TS6811, 
		"18;ab;[1=];" },
/* ADDB 40 */   { ADDR , DIRECT, 
		"db;[1=];" },
/* ADDB 41 */   { ADDR , EXTENDED, 
		"fb;[1=]x" },
/* ADDB 42 */   { 0 , 0, 
		"cb;[1=];" },
/* ADDB 43 */   { INDREG , REGX, 
		"eb;[1=];" },
/* ADDB 44 */   { INDREG+TS6811 , REGY+TS6811, 
		"18;eb;[1=];" },
/* ADDD 45 */   { ADDR+TS6801PLUS , DIRECT+TS6801PLUS, 
		"d3;[1=];" },
/* ADDD 46 */   { ADDR+TS6801PLUS , EXTENDED+TS6801PLUS, 
		"f3;[1=]x" },
/* ADDD 47 */   { TS6801PLUS , 0+TS6801PLUS, 
		"c3;[1=]x" },
/* ADDD 48 */   { INDREG+TS6801PLUS , REGX+TS6801PLUS, 
		"e3;[1=];" },
/* ADDD 49 */   { INDREG+TS6811 , REGY+TS6811, 
		"18;e3;[1=];" },
/* AND 50 */   { ACCREG+ADDR , REGA+DIRECT, 
		"94;[1=];" },
/* AND 51 */   { ACCREG+ADDR , REGA+EXTENDED, 
		"b4;[1=]x" },
/* AND 52 */   { ACCREG+ADDR , REGB+DIRECT, 
		"d4;[1=];" },
/* AND 53 */   { ACCREG+ADDR , REGB+EXTENDED, 
		"f4;[1=]x" },
/* AND 54 */   { ACCREG , REGA, 
		"84;[1=];" },
/* AND 55 */   { ACCREG , REGB, 
		"c4;[1=];" },
/* AND 56 */   { ACCREG+INDREG , REGA+REGX, 
		"a4;[1=];" },
/* AND 57 */   { ACCREG+INDREG+TS6811 , REGA+REGY+TS6811, 
		"18;a4;[1=];" },
/* AND 58 */   { ACCREG+INDREG , REGB+REGX, 
		"e4;[1=];" },
/* AND 59 */   { ACCREG+INDREG+TS6811 , REGB+REGY+TS6811, 
		"18;e4;[1=];" },
/* ANDA 60 */   { ADDR , DIRECT, 
		"94;[1=];" },
/* ANDA 61 */   { ADDR , EXTENDED, 
		"b4;[1=]x" },
/* ANDA 62 */   { 0 , 0, 
		"84;[1=];" },
/* ANDA 63 */   { INDREG , REGX, 
		"a4;[1=];" },
/* ANDA 64 */   { INDREG+TS6811 , REGY+TS6811, 
		"18;a4;[1=];" },
/* ANDB 65 */   { ADDR , DIRECT, 
		"d4;[1=];" },
/* ANDB 66 */   { ADDR , EXTENDED, 
		"f4;[1=]x" },
/* ANDB 67 */   { 0 , 0, 
		"c4;[1=];" },
/* ANDB 68 */   { INDREG , REGX, 
		"e4;[1=];" },
/* ANDB 69 */   { INDREG+TS6811 , REGY+TS6811, 
		"18;e4;[1=];" },
/* ASL 70 */   { ACCREG , REGA, 
		"48;" },
/* ASL 71 */   { ACCREG , REGB, 
		"58;" },
/* ASL 72 */   { 0 , 0, 
		"78;[1=]x" },
/* ASL 73 */   { INDREG , REGX, 
		"68;[1=];" },
/* ASL 74 */   { INDREG+TS6811 , REGY+TS6811, 
		"18;68;[1=];" },
/* ASLA 75 */   { 0 , 0, 
		"48;" },
/* ASLB 76 */   { 0 , 0, 
		"58;" },
/* ASLD 77 */   { TS6801PLUS , TS6801PLUS, 
		"05;" },
/* ASR 78 */   { ACCREG , REGA, 
		"47;" },
/* ASR 79 */   { ACCREG , REGB, 
		"57;" },
/* ASR 80 */   { 0 , 0, 
		"77;[1=]x" },
/* ASR 81 */   { INDREG , REGX, 
		"67;[1=];" },
/* ASR 82 */   { INDREG+TS6811 , REGY+TS6811, 
		"18;67;[1=];" },
/* ASRA 83 */   { 0 , 0, 
		"47;" },
/* ASRB 84 */   { 0 , 0, 
		"57;" },
/* BCC 85 */   { 0 , 0, 
		"24;[1=].P.2+-r" },
/* BCLR 86 */   { TS6811 , TS6811, 
		"15;[1=];[2=];" },
/* BCLR 87 */   { INDREG+TS6811 , REGX+TS6811, 
		"1d;[1=];[2=];" },
/* BCLR 88 */   { INDREG+TS6811 , REGY+TS6811, 
		"18;1d;[1=];[2=];" },
/* BCS 89 */   { 0 , 0, 
		"25;[1=].P.2+-r" },
/* BEQ 90 */   { 0 , 0, 
		"27;[1=].P.2+-r" },
/* BGE 91 */   { 0 , 0, 
		"2c;[1=].P.2+-r" },
/* BGT 92 */   { 0 , 0, 
		"2e;[1=].P.2+-r" },
/* BHI 93 */   { 0 , 0, 
		"22;[1=].P.2+-r" },
/* BHS 94 */   { 0 , 0, 
		"24;[1=].P.2+-r" },
/* BIT 95 */   { ACCREG+ADDR , REGA+DIRECT, 
		"95;[1=];" },
/* BIT 96 */   { ACCREG+ADDR , REGA+EXTENDED, 
		"b5;[1=]x" },
/* BIT 97 */   { ACCREG+ADDR , REGB+DIRECT, 
		"d5;[1=];" },
/* BIT 98 */   { ACCREG+ADDR , REGB+EXTENDED, 
		"f5;[1=]x" },
/* BIT 99 */   { ACCREG , REGA, 
		"85;[1=];" },
/* BIT 100 */   { ACCREG , REGB, 
		"c5;[1=];" },
/* BIT 101 */   { ACCREG+INDREG , REGA+REGX, 
		"a5;[1=];" },
/* BIT 102 */   { ACCREG+INDREG+TS6811 , REGA+REGY+TS6811, 
		"18;a5;[1=];" },
/* BIT 103 */   { ACCREG+INDREG , REGB+REGX, 
		"e5;[1=];" },
/* BIT 104 */   { ACCREG+INDREG+TS6811 , REGB+REGY+TS6811, 
		"18;e5;[1=];" },
/* BITA 105 */   { ADDR , DIRECT, 
		"95;[1=];" },
/* BITA 106 */   { ADDR , EXTENDED, 
		"b5;[1=]x" },
/* BITA 107 */   { 0 , 0, 
		"85;[1=];" },
/* BITA 108 */   { INDREG , REGX, 
		"a5;[1=];" },
/* BITA 109 */   { INDREG+TS6811 , REGY+TS6811, 
		"18;a5;[1=];" },
/* BITB 110 */   { ADDR , DIRECT, 
		"d5;[1=];" },
/* BITB 111 */   { ADDR , EXTENDED, 
		"f5;[1=]x" },
/* BITB 112 */   { 0 , 0, 
		"c5;[1=];" },
/* BITB 113 */   { INDREG , REGX, 
		"e5;[1=];" },
/* BITB 114 */   { INDREG+TS6811 , REGY+TS6811, 
		"18;e5;[1=];" },
/* BLE 115 */   { 0 , 0, 
		"2f;[1=].P.2+-r" },
/* BLO 116 */   { 0 , 0, 
		"25;[1=].P.2+-r" },
/* BLS 117 */   { 0 , 0, 
		"23;[1=].P.2+-r" },
/* BLT 118 */   { 0 , 0, 
		"2d;[1=].P.2+-r" },
/* BMI 119 */   { 0 , 0, 
		"2b;[1=].P.2+-r" },
/* BNE 120 */   { 0 , 0, 
		"26;[1=].P.2+-r" },
/* BPL 121 */   { 0 , 0, 
		"2a;[1=].P.2+-r" },
/* BRA 122 */   { 0 , 0, 
		"20;[1=].P.2+-r" },
/* BRCLR 123 */   { TS6811 , TS6811, 
		"13;[1=];[2=];[3=].P.4+-r" },
/* BRCLR 124 */   { INDREG+TS6811 , REGX+TS6811, 
		"1f;[1=];[2=];[3=].P.4+-r" },
/* BRCLR 125 */   { INDREG+TS6811 , REGY+TS6811, 
		"18;1f;[1=];[2=];[3=].P.5+-r" },
/* BRN 126 */   { TS6801PLUS , TS6801PLUS, 
		"21;[1=].P.2+-r" },
/* BRSET 127 */   { TS6811 , TS6811, 
		"12;[1=];[2=];[3=].P.4+-r" },
/* BRSET 128 */   { INDREG+TS6811 , REGX+TS6811, 
		"1e;[1=];[2=];[3=].P.4+-r" },
/* BRSET 129 */   { INDREG+TS6811 , REGY+TS6811, 
		"18;1e;[1=];[2=];[3=].P.5+-r" },
/* BSET 130 */   { TS6811 , TS6811, 
		"14;[1=];[2=];" },
/* BSET 131 */   { INDREG+TS6811 , REGX+TS6811, 
		"1c;[1=];[2=];" },
/* BSET 132 */   { INDREG+TS6811 , REGY+TS6811, 
		"18;1c;[1=];[2=];" },
/* BSR 133 */   { 0 , 0, 
		"8d;[1=].P.2+-r" },
/* BVC 134 */   { 0 , 0, 
		"28;[1=].P.2+-r" },
/* BVS 135 */   { 0 , 0, 
		"29;[1=].P.2+-r" },
/* CBA 136 */   { 0 , 0, 
		"11;" },
/* CLC 137 */   { 0 , 0, 
		"0c;" },
/* CLI 138 */   { 0 , 0, 
		"0e;" },
/* CLR 139 */   { ACCREG , REGA, 
		"4f;" },
/* CLR 140 */   { ACCREG , REGB, 
		"5f;" },
/* CLR 141 */   { 0 , 0, 
		"7f;[1=]x" },
/* CLR 142 */   { INDREG , REGX, 
		"6f;[1=];" },
/* CLR 143 */   { INDREG+TS6811 , REGY+TS6811, 
		"18;6f;[1=];" },
/* CLRA 144 */   { 0 , 0, 
		"4f;" },
/* CLRB 145 */   { 0 , 0, 
		"5f;" },
/* CLV 146 */   { 0 , 0, 
		"0a;" },
/* CMP 147 */   { ACCREG+ADDR , REGA+DIRECT, 
		"91;[1=];" },
/* CMP 148 */   { ACCREG+ADDR , REGA+EXTENDED, 
		"b1;[1=]x" },
/* CMP 149 */   { ACCREG+ADDR , REGB+DIRECT, 
		"d1;[1=];" },
/* CMP 150 */   { ACCREG+ADDR , REGB+EXTENDED, 
		"f1;[1=]x" },
/* CMP 151 */   { ACCREG , REGA, 
		"81;[1=];" },
/* CMP 152 */   { ACCREG , REGB, 
		"c1;[1=];" },
/* CMP 153 */   { ACCREG+INDREG , REGA+REGX, 
		"a1;[1=];" },
/* CMP 154 */   { ACCREG+INDREG+TS6811 , REGA+REGY+TS6811, 
		"18;a1;[1=];" },
/* CMP 155 */   { ACCREG+INDREG , REGB+REGX, 
		"e1;[1=];" },
/* CMP 156 */   { ACCREG+INDREG+TS6811 , REGB+REGY+TS6811, 
		"18;e1;[1=];" },
/* CMPA 157 */   { ADDR , DIRECT, 
		"91;[1=];" },
/* CMPA 158 */   { ADDR , EXTENDED, 
		"b1;[1=]x" },
/* CMPA 159 */   { 0 , 0, 
		"81;[1=];" },
/* CMPA 160 */   { INDREG , REGX, 
		"a1;[1=];" },
/* CMPA 161 */   { INDREG+TS6811 , REGY+TS6811, 
		"18;a1;[1=];" },
/* CMPB 162 */   { ADDR , DIRECT, 
		"d1;[1=];" },
/* CMPB 163 */   { ADDR , EXTENDED, 
		"f1;[1=]x" },
/* CMPB 164 */   { 0 , 0, 
		"c1;[1=];" },
/* CMPB 165 */   { INDREG , REGX, 
		"e1;[1=];" },
/* CMPB 166 */   { INDREG+TS6811 , REGY+TS6811, 
		"18;e1;[1=];" },
/* COM 167 */   { ACCREG , REGA, 
		"43;" },
/* COM 168 */   { ACCREG , REGB, 
		"53;" },
/* COM 169 */   { 0 , 0, 
		"73;[1=]x" },
/* COM 170 */   { INDREG , REGX, 
		"63;[1=];" },
/* COM 171 */   { INDREG+TS6811 , REGY+TS6811, 
		"18;63;[1=];" },
/* COMA 172 */   { 0 , 0, 
		"43;" },
/* COMB 173 */   { 0 , 0, 
		"53;" },
/* CPD 174 */   { ADDR+TS6811 , DIRECT+TS6811, 
		"1a;93;[1=];" },
/* CPD 175 */   { ADDR+TS6811 , EXTENDED+TS6811, 
		"1a;b3;[1=]x" },
/* CPD 176 */   { TS6811 , TS6811, 
		"1a;83;[1=]x" },
/* CPD 177 */   { INDREG+TS6811 , REGX+TS6811, 
		"1a;a3;[1=];" },
/* CPD 178 */   { INDREG+TS6811 , REGY+TS6811, 
		"cd;a3;[1=];" },
/* CPX 179 */   { ADDR , DIRECT, 
		"9c;[1=];" },
/* CPX 180 */   { ADDR , EXTENDED, 
		"bc;[1=]x" },
/* CPX 181 */   { 0 , 0, 
		"8c;[1=]x" },
/* CPX 182 */   { INDREG , REGX, 
		"ac;[1=];" },
/* CPX 183 */   { INDREG+TS6811 , REGY+TS6811, 
		"cd;ac;[1=];" },
/* CPY 184 */   { ADDR+TS6811 , DIRECT+TS6811, 
		"18;9c;[1=];" },
/* CPY 185 */   { ADDR+TS6811 , EXTENDED+TS6811, 
		"18;bc;[1=]x" },
/* CPY 186 */   { TS6811 , TS6811, 
		"18;8c;[1=]x" },
/* CPY 187 */   { INDREG+TS6811 , REGX+TS6811, 
		"1a;ac;[1=];" },
/* CPY 188 */   { INDREG+TS6811 , REGY+TS6811, 
		"18;ac;[1=];" },
/* DAA 189 */   { 0 , 0, 
		"19;" },
/* DEC 190 */   { ACCREG , REGA, 
		"4a;" },
/* DEC 191 */   { ACCREG , REGB, 
		"5a;" },
/* DEC 192 */   { 0 , 0, 
		"7a;[1=]x" },
/* DEC 193 */   { INDREG , REGX, 
		"6a;[1=];" },
/* DEC 194 */   { INDREG+TS6811 , REGY+TS6811, 
		"18;6a;[1=];" },
/* DECA 195 */   { 0 , 0, 
		"4a;" },
/* DECB 196 */   { 0 , 0, 
		"5a;" },
/* DES 197 */   { 0 , 0, 
		"34;" },
/* DEX 198 */   { 0 , 0, 
		"09;" },
/* DEY 199 */   { TS6811 , TS6811, 
		"18;09;" },
/* EOR 200 */   { ACCREG+ADDR , REGA+DIRECT, 
		"98;[1=];" },
/* EOR 201 */   { ACCREG+ADDR , REGA+EXTENDED, 
		"b8;[1=]x" },
/* EOR 202 */   { ACCREG+ADDR , REGB+DIRECT, 
		"d8;[1=];" },
/* EOR 203 */   { ACCREG+ADDR , REGB+EXTENDED, 
		"f8;[1=]x" },
/* EOR 204 */   { ACCREG , REGA, 
		"88;[1=];" },
/* EOR 205 */   { ACCREG , REGB, 
		"c8;[1=];" },
/* EOR 206 */   { ACCREG+INDREG , REGA+REGX, 
		"a8;[1=];" },
/* EOR 207 */   { ACCREG+INDREG+TS6811 , REGA+REGY+TS6811, 
		"18;a8;[1=];" },
/* EOR 208 */   { ACCREG+INDREG , REGB+REGX, 
		"e8;[1=];" },
/* EOR 209 */   { ACCREG+INDREG+TS6811 , REGB+REGY+TS6811, 
		"18;e8;[1=];" },
/* EORA 210 */   { ADDR , DIRECT, 
		"98;[1=];" },
/* EORA 211 */   { ADDR , EXTENDED, 
		"b8;[1=]x" },
/* EORA 212 */   { 0 , 0, 
		"88;[1=];" },
/* EORA 213 */   { INDREG , REGX, 
		"a8;[1=];" },
/* EORA 214 */   { INDREG+TS6811 , REGY+TS6811, 
		"18;a8;[1=];" },
/* EORB 215 */   { ADDR , DIRECT, 
		"d8;[1=];" },
/* EORB 216 */   { ADDR , EXTENDED, 
		"f8;[1=]x" },
/* EORB 217 */   { 0 , 0, 
		"c8;[1=];" },
/* EORB 218 */   { INDREG , REGX, 
		"e8;[1=];" },
/* EORB 219 */   { INDREG+TS6811 , REGY+TS6811, 
		"18;e8;[1=];" },
/* FDIV 220 */   { TS6811 , TS6811, 
		"03;" },
/* IDIV 221 */   { TS6811 , TS6811, 
		"02;" },
/* INC 222 */   { ACCREG , REGA, 
		"4c;" },
/* INC 223 */   { ACCREG , REGB, 
		"5c;" },
/* INC 224 */   { 0 , 0, 
		"7c;[1=]x" },
/* INC 225 */   { INDREG , REGX, 
		"6c;[1=];" },
/* INC 226 */   { INDREG+TS6811 , REGY+TS6811, 
		"18;6c;[1=];" },
/* INCA 227 */   { 0 , 0, 
		"4c;" },
/* INCB 228 */   { 0 , 0, 
		"5c;" },
/* INS 229 */   { 0 , 0, 
		"31;" },
/* INX 230 */   { 0 , 0, 
		"08;" },
/* INY 231 */   { TS6811 , TS6811, 
		"18;08;" },
/* JMP 232 */   { 0 , 0, 
		"7e;[1=]x" },
/* JMP 233 */   { INDREG , REGX, 
		"6e;[1=];" },
/* JMP 234 */   { INDREG+TS6811 , REGY+TS6811, 
		"18;6e;[1=];" },
/* JSR 235 */   { ADDR+CPUMASK , DIRECT+CPU6800, 
		"bd;[1=]x" },
/* JSR 236 */   { ADDR+TS6801PLUS , DIRECT+TS6801PLUS, 
		"9d;[1=];" },
/* JSR 237 */   { ADDR , EXTENDED, 
		"bd;[1=]x" },
/* JSR 238 */   { INDREG , REGX, 
		"ad;[1=];" },
/* JSR 239 */   { INDREG+TS6811 , REGY+TS6811, 
		"18;ad;[1=];" },
/* LDA 240 */   { ACCREG+ADDR , REGA+DIRECT, 
		"96;[1=];" },
/* LDA 241 */   { ACCREG+ADDR , REGA+EXTENDED, 
		"b6;[1=]x" },
/* LDA 242 */   { ACCREG+ADDR , REGB+DIRECT, 
		"d6;[1=];" },
/* LDA 243 */   { ACCREG+ADDR , REGB+EXTENDED, 
		"f6;[1=]x" },
/* LDA 244 */   { ACCREG , REGA, 
		"86;[1=];" },
/* LDA 245 */   { ACCREG , REGB, 
		"c6;[1=];" },
/* LDA 246 */   { ACCREG+INDREG , REGA+REGX, 
		"a6;[1=];" },
/* LDA 247 */   { ACCREG+INDREG+TS6811 , REGA+REGY+TS6811, 
		"18;a6;[1=];" },
/* LDA 248 */   { ACCREG+INDREG , REGB+REGX, 
		"e6;[1=];" },
/* LDA 249 */   { ACCREG+INDREG+TS6811 , REGB+REGY+TS6811, 
		"18;e6;[1=];" },
/* LDAA 250 */   { ADDR , DIRECT, 
		"96;[1=];" },
/* LDAA 251 */   { ADDR , EXTENDED, 
		"b6;[1=]x" },
/* LDAA 252 */   { 0 , 0, 
		"86;[1=];" },
/* LDAA 253 */   { INDREG , REGX, 
		"a6;[1=];" },
/* LDAA 254 */   { INDREG+TS6811 , REGY+TS6811, 
		"18;a6;[1=];" },
/* LDAB 255 */   { ADDR , DIRECT, 
		"d6;[1=];" },
/* LDAB 256 */   { ADDR , EXTENDED, 
		"f6;[1=]x" },
/* LDAB 257 */   { 0 , 0, 
		"c6;[1=];" },
/* LDAB 258 */   { INDREG , REGX, 
		"e6;[1=];" },
/* LDAB 259 */   { INDREG+TS6811 , REGY+TS6811, 
		"18;e6;[1=];" },
/* LDD 260 */   { ADDR+TS6801PLUS , DIRECT+TS6801PLUS, 
		"dc;[1=];" },
/* LDD 261 */   { ADDR+TS6801PLUS , EXTENDED+TS6801PLUS, 
		"fc;[1=]x" },
/* LDD 262 */   { TS6801PLUS , TS6801PLUS, 
		"cc;[1=]x" },
/* LDD 263 */   { TS6801PLUS+INDREG , REGX+TS6801PLUS, 
		"ec;[1=];" },
/* LDD 264 */   { INDREG+TS6811 , REGY+TS6811, 
		"18;ec;[1=];" },
/* LDS 265 */   { ADDR , DIRECT, 
		"9e;[1=];" },
/* LDS 266 */   { ADDR , EXTENDED, 
		"be;[1=]x" },
/* LDS 267 */   { 0 , 0, 
		"8e;[1=]x" },
/* LDS 268 */   { INDREG , REGX, 
		"ae;[1=];" },
/* LDS 269 */   { INDREG+TS6811 , REGY+TS6811, 
		"18;ae;[1=];" },
/* LDX 270 */   { ADDR , DIRECT, 
		"de;[1=];" },
/* LDX 271 */   { ADDR , EXTENDED, 
		"fe;[1=]x" },
/* LDX 272 */   { 0 , 0, 
		"ce;[1=]x" },
/* LDX 273 */   { INDREG , REGX, 
		"ee;[1=];" },
/* LDX 274 */   { INDREG+TS6811 , REGY+TS6811, 
		"cd;ee;[1=];" },
/* LDY 275 */   { TS6811+ADDR , DIRECT+TS6811, 
		"18;de;[1=];" },
/* LDY 276 */   { TS6811+ADDR , EXTENDED+TS6811, 
		"18;fe;[1=]x" },
/* LDY 277 */   { TS6811 , TS6811, 
		"18;ce;[1=]x" },
/* LDY 278 */   { TS6811+INDREG , REGX+TS6811, 
		"1a;ee;[1=];" },
/* LDY 279 */   { INDREG+TS6811 , REGY+TS6811, 
		"18;ee;[1=];" },
/* LSL 280 */   { ACCREG , REGA, 
		"48;" },
/* LSL 281 */   { ACCREG , REGB, 
		"58;" },
/* LSL 282 */   { 0 , 0, 
		"78;[1=]x" },
/* LSL 283 */   { INDREG , REGX, 
		"68;[1=];" },
/* LSL 284 */   { INDREG+TS6811 , REGY+TS6811, 
		"18;68;[1=];" },
/* LSLA 285 */   { 0 , 0, 
		"48;" },
/* LSLB 286 */   { 0 , 0, 
		"58;" },
/* LSLD 287 */   { TS6801PLUS , TS6801PLUS, 
		"05;" },
/* LSR 288 */   { ACCREG , REGA, 
		"44;" },
/* LSR 289 */   { ACCREG , REGB, 
		"54;" },
/* LSR 290 */   { 0 , 0, 
		"74;[1=]x" },
/* LSR 291 */   { INDREG , REGX, 
		"64;[1=];" },
/* LSR 292 */   { INDREG+TS6811 , REGY+TS6811, 
		"18;64;[1=];" },
/* LSRA 293 */   { 0 , 0, 
		"44;" },
/* LSRB 294 */   { 0 , 0, 
		"54;" },
/* LSRD 295 */   { TS6801PLUS , TS6801PLUS, 
		"04;" },
/* MUL 296 */   { TS6801PLUS , TS6801PLUS, 
		"3d;" },
/* NEG 297 */   { ACCREG , REGA, 
		"40;" },
/* NEG 298 */   { ACCREG , REGB, 
		"50;" },
/* NEG 299 */   { 0 , 0, 
		"70;[1=]x" },
/* NEG 300 */   { INDREG , REGX, 
		"60;[1=];" },
/* NEG 301 */   { INDREG+TS6811 , REGY+TS6811, 
		"18;60;[1=];" },
/* NEGA 302 */   { 0 , 0, 
		"40;" },
/* NEGB 303 */   { 0 , 0, 
		"50;" },
/* NOP 304 */   { 0 , 0, 
		"01;" },
/* ORA 305 */   { ACCREG+ADDR , REGA+DIRECT, 
		"9a;[1=];" },
/* ORA 306 */   { ACCREG+ADDR , REGA+EXTENDED, 
		"ba;[1=]x" },
/* ORA 307 */   { ACCREG+ADDR , REGB+DIRECT, 
		"da;[1=];" },
/* ORA 308 */   { ACCREG+ADDR , REGB+EXTENDED, 
		"fa;[1=]x" },
/* ORA 309 */   { ACCREG , REGA, 
		"8a;[1=];" },
/* ORA 310 */   { ACCREG , REGB, 
		"ca;[1=];" },
/* ORA 311 */   { ACCREG+INDREG , REGA+REGX, 
		"aa;[1=];" },
/* ORA 312 */   { ACCREG+INDREG+TS6811 , REGA+REGY+TS6811, 
		"18;aa;[1=];" },
/* ORA 313 */   { ACCREG+INDREG , REGB+REGX, 
		"ea;[1=];" },
/* ORA 314 */   { ACCREG+INDREG+TS6811 , REGB+REGY+TS6811, 
		"18;ea;[1=];" },
/* ORAA 315 */   { ADDR , DIRECT, 
		"9a;[1=];" },
/* ORAA 316 */   { ADDR , EXTENDED, 
		"ba;[1=]x" },
/* ORAA 317 */   { 0 , 0, 
		"8a;[1=];" },
/* ORAA 318 */   { INDREG , REGX, 
		"aa;[1=];" },
/* ORAA 319 */   { INDREG+TS6811 , REGY+TS6811, 
		"18;aa;[1=];" },
/* ORAB 320 */   { ADDR , DIRECT, 
		"da;[1=];" },
/* ORAB 321 */   { ADDR , EXTENDED, 
		"fa;[1=]x" },
/* ORAB 322 */   { 0 , 0, 
		"ca;[1=];" },
/* ORAB 323 */   { INDREG , REGX, 
		"ea;[1=];" },
/* ORAB 324 */   { INDREG+TS6811 , REGY+TS6811, 
		"18;ea;[1=];" },
/* PSH 325 */   { ACCREG , REGA, 
		"36;" },
/* PSH 326 */   { ACCREG , REGB, 
		"37;" },
/* PSH 327 */   { TS6801PLUS+INDREG , REGX+TS6801PLUS, 
		"3c;" },
/* PSH 328 */   { INDREG+TS6811 , REGY+TS6811, 
		"18;3c;" },
/* PSHA 329 */   { 0 , 0, 
		"36;" },
/* PSHB 330 */   { 0 , 0, 
		"37;" },
/* PSHX 331 */   { TS6801PLUS , TS6801PLUS, 
		"3c;" },
/* PSHY 332 */   { TS6811 , TS6811, 
		"18;3c;" },
/* PUL 333 */   { ACCREG , REGA, 
		"32;" },
/* PUL 334 */   { ACCREG , REGB, 
		"33;" },
/* PUL 335 */   { TS6801PLUS+INDREG , REGX+TS6801PLUS, 
		"38;" },
/* PUL 336 */   { INDREG+TS6811 , REGY+TS6811, 
		"18;38;" },
/* PULA 337 */   { 0 , 0, 
		"32;" },
/* PULB 338 */   { 0 , 0, 
		"33;" },
/* PULX 339 */   { TS6801PLUS , TS6801PLUS, 
		"38;" },
/* PULY 340 */   { TS6811 , TS6811, 
		"18;38;" },
/* ROL 341 */   { ACCREG , REGA, 
		"49;" },
/* ROL 342 */   { ACCREG , REGB, 
		"59;" },
/* ROL 343 */   { 0 , 0, 
		"79;[1=]x" },
/* ROL 344 */   { INDREG , REGX, 
		"69;[1=];" },
/* ROL 345 */   { INDREG+TS6811 , REGY+TS6811, 
		"18;69;[1=];" },
/* ROLA 346 */   { 0 , 0, 
		"49;" },
/* ROLB 347 */   { 0 , 0, 
		"59;" },
/* ROR 348 */   { ACCREG , REGA, 
		"46;" },
/* ROR 349 */   { ACCREG , REGB, 
		"56;" },
/* ROR 350 */   { 0 , 0, 
		"76;[1=]x" },
/* ROR 351 */   { INDREG , REGX, 
		"66;[1=];" },
/* ROR 352 */   { INDREG+TS6811 , REGY+TS6811, 
		"18;66;[1=];" },
/* RORA 353 */   { 0 , 0, 
		"46;" },
/* RORB 354 */   { 0 , 0, 
		"56;" },
/* RTI 355 */   { 0 , 0, 
		"3b;" },
/* RTS 356 */   { 0 , 0, 
		"39;" },
/* SBA 357 */   { 0 , 0, 
		"10;" },
/* SBC 358 */   { ACCREG+ADDR , REGA+DIRECT, 
		"92;[1=];" },
/* SBC 359 */   { ACCREG+ADDR , REGA+EXTENDED, 
		"b2;[1=]x" },
/* SBC 360 */   { ACCREG+ADDR , REGB+DIRECT, 
		"d2;[1=];" },
/* SBC 361 */   { ACCREG+ADDR , REGB+EXTENDED, 
		"f2;[1=]x" },
/* SBC 362 */   { ACCREG , REGA, 
		"82;[1=];" },
/* SBC 363 */   { ACCREG , REGB, 
		"c2;[1=];" },
/* SBC 364 */   { ACCREG+INDREG , REGA+REGX, 
		"a2;[1=];" },
/* SBC 365 */   { ACCREG+INDREG+TS6811 , REGA+REGY+TS6811, 
		"18;a2;[1=];" },
/* SBC 366 */   { ACCREG+INDREG , REGB+REGX, 
		"e2;[1=];" },
/* SBC 367 */   { ACCREG+INDREG+TS6811 , REGB+REGY+TS6811, 
		"18;e2;[1=];" },
/* SBCA 368 */   { ADDR , DIRECT, 
		"92;[1=];" },
/* SBCA 369 */   { ADDR , EXTENDED, 
		"b2;[1=]x" },
/* SBCA 370 */   { 0 , 0, 
		"82;[1=];" },
/* SBCA 371 */   { INDREG , REGX, 
		"a2;[1=];" },
/* SBCA 372 */   { INDREG+TS6811 , REGY+TS6811, 
		"18;a2;[1=];" },
/* SBCB 373 */   { ADDR , DIRECT, 
		"d2;[1=];" },
/* SBCB 374 */   { ADDR , EXTENDED, 
		"f2;[1=]x" },
/* SBCB 375 */   { 0 , 0, 
		"c2;[1=];" },
/* SBCB 376 */   { INDREG , REGX, 
		"e2;[1=];" },
/* SBCB 377 */   { INDREG+TS6811 , REGY+TS6811, 
		"18;e2;[1=];" },
/* SEC 378 */   { 0 , 0, 
		"0d;" },
/* SEI 379 */   { 0 , 0, 
		"0f;" },
/* SEV 380 */   { 0 , 0, 
		"0b;" },
/* STA 381 */   { ACCREG+ADDR , REGA+DIRECT, 
		"97;[1=];" },
/* STA 382 */   { ACCREG+ADDR , REGA+EXTENDED, 
		"b7;[1=]x" },
/* STA 383 */   { ACCREG+ADDR , REGB+DIRECT, 
		"d7;[1=];" },
/* STA 384 */   { ACCREG+ADDR , REGB+EXTENDED, 
		"f7;[1=]x" },
/* STA 385 */   { ACCREG+INDREG , REGA+REGX, 
		"a7;[1=];" },
/* STA 386 */   { ACCREG+INDREG+TS6811 , REGA+REGY+TS6811, 
		"18;a7;[1=];" },
/* STA 387 */   { ACCREG+INDREG , REGB+REGX, 
		"e7;[1=];" },
/* STA 388 */   { ACCREG+INDREG+TS6811 , REGB+REGY+TS6811, 
		"18;e7;[1=];" },
/* STAA 389 */   { ADDR , DIRECT, 
		"97;[1=];" },
/* STAA 390 */   { ADDR , EXTENDED, 
		"b7;[1=]x" },
/* STAA 391 */   { INDREG , REGX, 
		"a7;[1=];" },
/* STAA 392 */   { INDREG+TS6811 , REGY+TS6811, 
		"18;a7;[1=];" },
/* STAB 393 */   { ADDR , DIRECT, 
		"d7;[1=];" },
/* STAB 394 */   { ADDR , EXTENDED, 
		"f7;[1=]x" },
/* STAB 395 */   { INDREG , REGX, 
		"e7;[1=];" },
/* STAB 396 */   { INDREG+TS6811 , REGY+TS6811, 
		"18;e7;[1=];" },
/* STD 397 */   { TS6801PLUS+ADDR , DIRECT+TS6801PLUS, 
		"dd;[1=];" },
/* STD 398 */   { TS6801PLUS+ADDR , EXTENDED+TS6801PLUS, 
		"fd;[1=]x" },
/* STD 399 */   { TS6801PLUS+INDREG , REGX+TS6801PLUS, 
		"ed;[1=];" },
/* STD 400 */   { INDREG+TS6811 , REGY+TS6811, 
		"18;ed;[1=];" },
/* STOP 401 */   { TS6811 , TS6811, 
		"cf;" },
/* STS 402 */   { ADDR , DIRECT, 
		"9f;[1=];" },
/* STS 403 */   { ADDR , EXTENDED, 
		"bf;[1=]x" },
/* STS 404 */   { INDREG , REGX, 
		"af;[1=];" },
/* STS 405 */   { INDREG+TS6811 , REGY+TS6811, 
		"18;af;[1=];" },
/* STX 406 */   { ADDR , DIRECT, 
		"df;[1=];" },
/* STX 407 */   { ADDR , EXTENDED, 
		"ff;[1=]x" },
/* STX 408 */   { INDREG , REGX, 
		"ef;[1=];" },
/* STX 409 */   { INDREG+TS6811 , REGY+TS6811, 
		"cd;ef;[1=];" },
/* STY 410 */   { TS6811+ADDR , DIRECT+TS6811, 
		"18;df;[1=];" },
/* STY 411 */   { TS6811+ADDR , EXTENDED+TS6811, 
		"18;ff;[1=]x" },
/* STY 412 */   { TS6811+INDREG , REGX+TS6811, 
		"1a;ef;[1=];" },
/* STY 413 */   { INDREG+TS6811 , REGY+TS6811, 
		"18;ef;[1=];" },
/* SUB 414 */   { ACCREG+ADDR , REGA+DIRECT, 
		"90;[1=];" },
/* SUB 415 */   { ACCREG+ADDR , REGA+EXTENDED, 
		"b0;[1=]x" },
/* SUB 416 */   { ACCREG+ADDR , REGB+DIRECT, 
		"d0;[1=];" },
/* SUB 417 */   { ACCREG+ADDR , REGB+EXTENDED, 
		"f0;[1=]x" },
/* SUB 418 */   { ACCREG , REGA, 
		"80;[1=];" },
/* SUB 419 */   { ACCREG , REGB, 
		"c0;[1=];" },
/* SUB 420 */   { ACCREG+INDREG , REGA+REGX, 
		"a0;[1=];" },
/* SUB 421 */   { ACCREG+INDREG+TS6811 , REGA+REGY+TS6811, 
		"18;a0;[1=];" },
/* SUB 422 */   { ACCREG+INDREG , REGB+REGX, 
		"e0;[1=];" },
/* SUB 423 */   { ACCREG+INDREG+TS6811 , REGB+REGY+TS6811, 
		"18;e0;[1=];" },
/* SUBA 424 */   { ADDR , DIRECT, 
		"90;[1=];" },
/* SUBA 425 */   { ADDR , EXTENDED, 
		"b0;[1=]x" },
/* SUBA 426 */   { 0 , 0, 
		"80;[1=];" },
/* SUBA 427 */   { INDREG , REGX, 
		"a0;[1=];" },
/* SUBA 428 */   { INDREG+TS6811 , REGY+TS6811, 
		"18;a0;[1=];" },
/* SUBB 429 */   { ADDR , DIRECT, 
		"d0;[1=];" },
/* SUBB 430 */   { ADDR , EXTENDED, 
		"f0;[1=]x" },
/* SUBB 431 */   { 0 , 0, 
		"c0;[1=];" },
/* SUBB 432 */   { INDREG , REGX, 
		"e0;[1=];" },
/* SUBB 433 */   { INDREG+TS6811 , REGY+TS6811, 
		"18;e0;[1=];" },
/* SUBD 434 */   { TS6801PLUS+ADDR , DIRECT+TS6801PLUS, 
		"93;[1=];" },
/* SUBD 435 */   { TS6801PLUS+ADDR , EXTENDED+TS6801PLUS, 
		"b3;[1=]x" },
/* SUBD 436 */   { TS6801PLUS , TS6801PLUS, 
		"83;[1=]x" },
/* SUBD 437 */   { TS6801PLUS+INDREG , REGX+TS6801PLUS, 
		"a3;[1=];" },
/* SUBD 438 */   { INDREG+TS6811 , REGY+TS6811, 
		"18;a3;[1=];" },
/* SWI 439 */   { 0 , 0, 
		"3f;" },
/* TAB 440 */   { 0 , 0, 
		"16;" },
/* TAP 441 */   { 0 , 0, 
		"06;" },
/* TBA 442 */   { 0 , 0, 
		"17;" },
/* TEST 443 */   { TS6811 , TS6811, 
		"00;" },
/* TPA 444 */   { 0 , 0, 
		"07;" },
/* TST 445 */   { ACCREG , REGA, 
		"4d;" },
/* TST 446 */   { ACCREG , REGB, 
		"5d;" },
/* TST 447 */   { 0 , 0, 
		"7d;[1=]x" },
/* TST 448 */   { INDREG , REGX, 
		"6d;[1=];" },
/* TST 449 */   { INDREG+TS6811 , REGY+TS6811, 
		"18;6d;[1=];" },
/* TSTA 450 */   { 0 , 0, 
		"4d;" },
/* TSTB 451 */   { 0 , 0, 
		"5d;" },
/* TSX 452 */   { 0 , 0, 
		"30;" },
/* TSY 453 */   { TS6811 , TS6811, 
		"18;30;" },
/* TXS 454 */   { 0 , 0, 
		"35;" },
/* TYS 455 */   { TS6811 , TS6811, 
		"18;35;" },
/* WAI 456 */   { 0 , 0, 
		"3e;" },
/* XGDX 457 */   { TS6811 , TS6811, 
		"8f;" },
/* XGDY 458 */   { TS6811 , TS6811, 
		"18;8f;" },
	{ 0,0,""} };
/* end fraptabdef.c */
