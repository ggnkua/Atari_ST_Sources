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
FILENAME: 	as6301.y;
WARNINGS: 	"This software is in the public domain.  
		Any prior copyright claims are relinquished.  

		This software is distributed with no warranty whatever.  
		The author takes no responsibility for the consequences 
		of its use.

		Yacc (or Bison) required to compile."  ;
SEE-ALSO: 	as6301.doc,frasmain.c;	
AUTHORS: 	Mark Zenier;
COMPILERS: 	Microport Sys V/AT, ATT Yacc, Turbo C V1.5, Bison (CUG disk 285)
		(previous versions Xenix, Unisoft 68000 Version 7, Sun 3);
*/
/* 6301 instruction generation file */
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
	description	Selection criteria and token values for 6301
			framework assembler
	usage		framework cross assembler
	history		September 19, 1987
*/

		/* 0000.0000.xxxx.xxxx */
#define BITNUMB		0xff
#define BIT0		0x01
#define BIT1		0x02
#define BIT2		0x04
#define BIT3		0x08
#define BIT4		0x10
#define BIT5		0x20
#define BIT6		0x40
#define BIT7		0x80

		/* 0000.00xx.0000.0000 */
#define ACCREG		0x300
#define REGA		0x100
#define REGB		0x200

		/* 0000.xx00.0000.0000 */
#define ADDR		0xc00
#define DIRECT		0x400
#define EXTENDED	0x800

#define ST_INH 0x1
#define ST_ACC 0x2
#define ST_INDREG 0x4
#define ST_EXP 0x8
#define ST_IMM 0x10
#define ST_IND 0x20
#define ST_AEXP 0x40
#define ST_AIMM 0x80
#define ST_AIND 0x100
#define ST_BSET 0x200
#define ST_BSETIND 0x400
#define ST_MEMIMM 0x800
#define ST_MEMIMMIND 0x1000
	
	static char	genbdef[] = "[1=];";
	static char	genwdef[] = "[1=]x";
	char ignosyn[] = "[Xinvalid syntax for instruction";
	char ignosel[] = "[Xinvalid operands";

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


genline : KOC_opcode 
			{
		genlocrec(currseg, labelloc);
		locctr += geninstr(findgen($1, ST_INH, 0));
			}
	;
genline : KOC_opcode  ACCUM
			{
		genlocrec(currseg, labelloc);
		locctr += geninstr(findgen($1, ST_ACC, $2));
			}
	;
genline : KOC_opcode  INDEX
			{
		genlocrec(currseg, labelloc);
		locctr += geninstr(findgen($1, ST_INDREG, 0));
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
		pevalexpr(1, $2.ex);
		genlocrec(currseg, labelloc);
		locctr += geninstr( findgen($1, ST_IND, 0));
			}
	;
genline : KOC_opcode  ACCUM expr
			{
		pevalexpr(1, $3);
		genlocrec(currseg, labelloc);
		locctr += geninstr(findgen( $1, ST_AEXP, $2
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
		locctr += geninstr( findgen($1, ST_AIMM, $2 ));
			}
	;
genline : KOC_opcode  ACCUM indexed
			{
		pevalexpr(1, $3.ex);
		genlocrec(currseg, labelloc);
		locctr += geninstr( findgen($1, ST_AIND, $2));
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
		pevalexpr(2,$4);
		genlocrec(currseg, labelloc);
		locctr += geninstr( findgen( $1, ST_BSET, 1<<evalr[1].value));
			}
	;
genline : KOC_opcode  expr ',' indexed 
			{
		pevalexpr(1,$2);
		if(evalr[1].seg != SSG_ABS || 
			evalr[1].value < 0 ||
			evalr[1].value > 7)
		{
			evalr[1].value = 0;
			fraerror("impossible bit number");
		}
		pevalexpr(2,$4.ex);
		genlocrec(currseg, labelloc);
		locctr += geninstr( findgen( $1, ST_BSETIND, 
					1<<evalr[1].value));
			}
	;
genline : KOC_opcode  '#' expr ',' expr
			{
		pevalexpr(1, $3);
		pevalexpr(2, $5);
		genlocrec(currseg, labelloc);
		locctr += geninstr( findgen( $1, ST_MEMIMM, 0));
			}
	;
genline : KOC_opcode  '#' expr ',' indexed 
			{
		pevalexpr(1, $3);
		pevalexpr(2, $5.ex);
		genlocrec(currseg, labelloc);
		locctr += geninstr( findgen( $1, ST_MEMIMMIND, 0));
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
	reservedsym("x", INDEX, 0);
	reservedsym("A", ACCUM, REGA);
	reservedsym("B", ACCUM, REGB);
	reservedsym("X", INDEX, 0);
}

cpumatch(str)
	char * str;
{
	return TRUE;
}

/*
	description	Opcode and Instruction generation tables
	usage		Unix, framework crossassembler
	history		September 25, 1987
*/

#define NUMOPCODE 171
#define NUMSYNBLK 263
#define NUMDIFFOP 419

int gnumopcode = NUMOPCODE;

int ophashlnk[NUMOPCODE];

struct opsym optab[NUMOPCODE+1]
	= {
	{"invalid", KOC_opcode, 2, 0 },
	{"ABA", KOC_opcode, 1, 2 },
	{"ABX", KOC_opcode, 1, 3 },
	{"ADC", KOC_opcode, 3, 4 },
	{"ADCA", KOC_opcode, 3, 7 },
	{"ADCB", KOC_opcode, 3, 10 },
	{"ADD", KOC_opcode, 3, 13 },
	{"ADDA", KOC_opcode, 3, 16 },
	{"ADDB", KOC_opcode, 3, 19 },
	{"ADDD", KOC_opcode, 3, 22 },
	{"AIM", KOC_opcode, 2, 25 },
	{"AND", KOC_opcode, 3, 27 },
	{"ANDA", KOC_opcode, 3, 30 },
	{"ANDB", KOC_opcode, 3, 33 },
	{"ASL", KOC_opcode, 3, 36 },
	{"ASLA", KOC_opcode, 1, 39 },
	{"ASLB", KOC_opcode, 1, 40 },
	{"ASLD", KOC_opcode, 1, 41 },
	{"ASR", KOC_opcode, 3, 42 },
	{"ASRA", KOC_opcode, 1, 45 },
	{"ASRB", KOC_opcode, 1, 46 },
	{"BCC", KOC_opcode, 1, 47 },
	{"BCLR", KOC_opcode, 2, 48 },
	{"BCS", KOC_opcode, 1, 50 },
	{"BEQ", KOC_opcode, 1, 51 },
	{"BGE", KOC_opcode, 1, 52 },
	{"BGT", KOC_opcode, 1, 53 },
	{"BHI", KOC_opcode, 1, 54 },
	{"BHS", KOC_opcode, 1, 55 },
	{"BIT", KOC_opcode, 3, 56 },
	{"BITA", KOC_opcode, 3, 59 },
	{"BITB", KOC_opcode, 3, 62 },
	{"BLE", KOC_opcode, 1, 65 },
	{"BLO", KOC_opcode, 1, 66 },
	{"BLS", KOC_opcode, 1, 67 },
	{"BLT", KOC_opcode, 1, 68 },
	{"BMI", KOC_opcode, 1, 69 },
	{"BNE", KOC_opcode, 1, 70 },
	{"BPL", KOC_opcode, 1, 71 },
	{"BRA", KOC_opcode, 1, 72 },
	{"BRN", KOC_opcode, 1, 73 },
	{"BSET", KOC_opcode, 2, 74 },
	{"BSR", KOC_opcode, 1, 76 },
	{"BTGL", KOC_opcode, 2, 77 },
	{"BTST", KOC_opcode, 2, 79 },
	{"BVC", KOC_opcode, 1, 81 },
	{"BVS", KOC_opcode, 1, 82 },
	{"BYTE", KOC_BDEF, 0, 0 },
	{"CBA", KOC_opcode, 1, 83 },
	{"CHARDEF", KOC_CHDEF, 0, 0 },
	{"CHARSET", KOC_CHSET, 0, 0 },
	{"CHARUSE", KOC_CHUSE, 0, 0 },
	{"CHD", KOC_CHDEF, 0, 0 },
	{"CLC", KOC_opcode, 1, 84 },
	{"CLI", KOC_opcode, 1, 85 },
	{"CLR", KOC_opcode, 3, 86 },
	{"CLRA", KOC_opcode, 1, 89 },
	{"CLRB", KOC_opcode, 1, 90 },
	{"CLV", KOC_opcode, 1, 91 },
	{"CMP", KOC_opcode, 3, 92 },
	{"CMPA", KOC_opcode, 3, 95 },
	{"CMPB", KOC_opcode, 3, 98 },
	{"COM", KOC_opcode, 3, 101 },
	{"COMA", KOC_opcode, 1, 104 },
	{"COMB", KOC_opcode, 1, 105 },
	{"CPX", KOC_opcode, 3, 106 },
	{"DAA", KOC_opcode, 1, 109 },
	{"DB", KOC_BDEF, 0, 0 },
	{"DEC", KOC_opcode, 3, 110 },
	{"DECA", KOC_opcode, 1, 113 },
	{"DECB", KOC_opcode, 1, 114 },
	{"DES", KOC_opcode, 1, 115 },
	{"DEX", KOC_opcode, 1, 116 },
	{"DW", KOC_WDEF, 0, 0 },
	{"EIM", KOC_opcode, 2, 117 },
	{"ELSE", KOC_ELSE, 0, 0 },
	{"END", KOC_END, 0, 0 },
	{"ENDI", KOC_ENDI, 0, 0 },
	{"EOR", KOC_opcode, 3, 119 },
	{"EORA", KOC_opcode, 3, 122 },
	{"EORB", KOC_opcode, 3, 125 },
	{"EQU", KOC_EQU, 0, 0 },
	{"FCB", KOC_BDEF, 0, 0 },
	{"FCC", KOC_SDEF, 0, 0 },
	{"FDB", KOC_WDEF, 0, 0 },
	{"IF", KOC_IF, 0, 0 },
	{"INC", KOC_opcode, 3, 128 },
	{"INCA", KOC_opcode, 1, 131 },
	{"INCB", KOC_opcode, 1, 132 },
	{"INCL", KOC_INCLUDE, 0, 0 },
	{"INCLUDE", KOC_INCLUDE, 0, 0 },
	{"INS", KOC_opcode, 1, 133 },
	{"INX", KOC_opcode, 1, 134 },
	{"JMP", KOC_opcode, 2, 135 },
	{"JSR", KOC_opcode, 2, 137 },
	{"LDA", KOC_opcode, 3, 139 },
	{"LDAA", KOC_opcode, 3, 142 },
	{"LDAB", KOC_opcode, 3, 145 },
	{"LDD", KOC_opcode, 3, 148 },
	{"LDS", KOC_opcode, 3, 151 },
	{"LDX", KOC_opcode, 3, 154 },
	{"LSL", KOC_opcode, 3, 157 },
	{"LSLA", KOC_opcode, 1, 160 },
	{"LSLB", KOC_opcode, 1, 161 },
	{"LSLD", KOC_opcode, 1, 162 },
	{"LSR", KOC_opcode, 3, 163 },
	{"LSRA", KOC_opcode, 1, 166 },
	{"LSRB", KOC_opcode, 1, 167 },
	{"LSRD", KOC_opcode, 1, 168 },
	{"MUL", KOC_opcode, 1, 169 },
	{"NEG", KOC_opcode, 3, 170 },
	{"NEGA", KOC_opcode, 1, 173 },
	{"NEGB", KOC_opcode, 1, 174 },
	{"NOP", KOC_opcode, 1, 175 },
	{"OIM", KOC_opcode, 2, 176 },
	{"ORA", KOC_opcode, 3, 178 },
	{"ORAA", KOC_opcode, 3, 181 },
	{"ORAB", KOC_opcode, 3, 184 },
	{"ORG", KOC_ORG, 0, 0 },
	{"PSH", KOC_opcode, 2, 187 },
	{"PSHA", KOC_opcode, 1, 189 },
	{"PSHB", KOC_opcode, 1, 190 },
	{"PSHX", KOC_opcode, 1, 191 },
	{"PUL", KOC_opcode, 2, 192 },
	{"PULA", KOC_opcode, 1, 194 },
	{"PULB", KOC_opcode, 1, 195 },
	{"PULX", KOC_opcode, 1, 196 },
	{"RESERVE", KOC_RESM, 0, 0 },
	{"RMB", KOC_RESM, 0, 0 },
	{"ROL", KOC_opcode, 3, 197 },
	{"ROLA", KOC_opcode, 1, 200 },
	{"ROLB", KOC_opcode, 1, 201 },
	{"ROR", KOC_opcode, 3, 202 },
	{"RORA", KOC_opcode, 1, 205 },
	{"RORB", KOC_opcode, 1, 206 },
	{"RTI", KOC_opcode, 1, 207 },
	{"RTS", KOC_opcode, 1, 208 },
	{"SBA", KOC_opcode, 1, 209 },
	{"SBC", KOC_opcode, 3, 210 },
	{"SBCA", KOC_opcode, 3, 213 },
	{"SBCB", KOC_opcode, 3, 216 },
	{"SEC", KOC_opcode, 1, 219 },
	{"SEI", KOC_opcode, 1, 220 },
	{"SET", KOC_SET, 0, 0 },
	{"SEV", KOC_opcode, 1, 221 },
	{"SLP", KOC_opcode, 1, 222 },
	{"STA", KOC_opcode, 2, 223 },
	{"STAA", KOC_opcode, 2, 225 },
	{"STAB", KOC_opcode, 2, 227 },
	{"STD", KOC_opcode, 2, 229 },
	{"STRING", KOC_SDEF, 0, 0 },
	{"STS", KOC_opcode, 2, 231 },
	{"STX", KOC_opcode, 2, 233 },
	{"SUB", KOC_opcode, 3, 235 },
	{"SUBA", KOC_opcode, 3, 238 },
	{"SUBB", KOC_opcode, 3, 241 },
	{"SUBD", KOC_opcode, 3, 244 },
	{"SWI", KOC_opcode, 1, 247 },
	{"TAB", KOC_opcode, 1, 248 },
	{"TAP", KOC_opcode, 1, 249 },
	{"TBA", KOC_opcode, 1, 250 },
	{"TIM", KOC_opcode, 2, 251 },
	{"TPA", KOC_opcode, 1, 253 },
	{"TST", KOC_opcode, 3, 254 },
	{"TSTA", KOC_opcode, 1, 257 },
	{"TSTB", KOC_opcode, 1, 258 },
	{"TSX", KOC_opcode, 1, 259 },
	{"TXS", KOC_opcode, 1, 260 },
	{"WAI", KOC_opcode, 1, 261 },
	{"WORD", KOC_WDEF, 0, 0 },
	{"XGDX", KOC_opcode, 1, 262 },
	{ "", 0, 0, 0 }};

struct opsynt ostab[NUMSYNBLK+1]
	= {
/* invalid 0 */ { 0, 1, 0 },
/* invalid 1 */ { 0xffff, 1, 1 },
/* ABA 2 */ { ST_INH, 1, 2 },
/* ABX 3 */ { ST_INH, 1, 3 },
/* ADC 4 */ { ST_AEXP, 4, 4 },
/* ADC 5 */ { ST_AIMM, 2, 8 },
/* ADC 6 */ { ST_AIND, 2, 10 },
/* ADCA 7 */ { ST_EXP, 2, 12 },
/* ADCA 8 */ { ST_IMM, 1, 14 },
/* ADCA 9 */ { ST_IND, 1, 15 },
/* ADCB 10 */ { ST_EXP, 2, 16 },
/* ADCB 11 */ { ST_IMM, 1, 18 },
/* ADCB 12 */ { ST_IND, 1, 19 },
/* ADD 13 */ { ST_AEXP, 4, 20 },
/* ADD 14 */ { ST_AIMM, 2, 24 },
/* ADD 15 */ { ST_AIND, 2, 26 },
/* ADDA 16 */ { ST_EXP, 2, 28 },
/* ADDA 17 */ { ST_IMM, 1, 30 },
/* ADDA 18 */ { ST_IND, 1, 31 },
/* ADDB 19 */ { ST_EXP, 2, 32 },
/* ADDB 20 */ { ST_IMM, 1, 34 },
/* ADDB 21 */ { ST_IND, 1, 35 },
/* ADDD 22 */ { ST_EXP, 2, 36 },
/* ADDD 23 */ { ST_IMM, 1, 38 },
/* ADDD 24 */ { ST_IND, 1, 39 },
/* AIM 25 */ { ST_MEMIMM, 1, 40 },
/* AIM 26 */ { ST_MEMIMMIND, 1, 41 },
/* AND 27 */ { ST_AEXP, 4, 42 },
/* AND 28 */ { ST_AIMM, 2, 46 },
/* AND 29 */ { ST_AIND, 2, 48 },
/* ANDA 30 */ { ST_EXP, 2, 50 },
/* ANDA 31 */ { ST_IMM, 1, 52 },
/* ANDA 32 */ { ST_IND, 1, 53 },
/* ANDB 33 */ { ST_EXP, 2, 54 },
/* ANDB 34 */ { ST_IMM, 1, 56 },
/* ANDB 35 */ { ST_IND, 1, 57 },
/* ASL 36 */ { ST_ACC, 2, 58 },
/* ASL 37 */ { ST_EXP, 1, 60 },
/* ASL 38 */ { ST_IND, 1, 61 },
/* ASLA 39 */ { ST_INH, 1, 62 },
/* ASLB 40 */ { ST_INH, 1, 63 },
/* ASLD 41 */ { ST_INH, 1, 64 },
/* ASR 42 */ { ST_ACC, 2, 65 },
/* ASR 43 */ { ST_EXP, 1, 67 },
/* ASR 44 */ { ST_IND, 1, 68 },
/* ASRA 45 */ { ST_INH, 1, 69 },
/* ASRB 46 */ { ST_INH, 1, 70 },
/* BCC 47 */ { ST_EXP, 1, 71 },
/* BCLR 48 */ { ST_BSET, 8, 72 },
/* BCLR 49 */ { ST_BSETIND, 8, 80 },
/* BCS 50 */ { ST_EXP, 1, 88 },
/* BEQ 51 */ { ST_EXP, 1, 89 },
/* BGE 52 */ { ST_EXP, 1, 90 },
/* BGT 53 */ { ST_EXP, 1, 91 },
/* BHI 54 */ { ST_EXP, 1, 92 },
/* BHS 55 */ { ST_EXP, 1, 93 },
/* BIT 56 */ { ST_AEXP, 4, 94 },
/* BIT 57 */ { ST_AIMM, 2, 98 },
/* BIT 58 */ { ST_AIND, 2, 100 },
/* BITA 59 */ { ST_EXP, 2, 102 },
/* BITA 60 */ { ST_IMM, 1, 104 },
/* BITA 61 */ { ST_IND, 1, 105 },
/* BITB 62 */ { ST_EXP, 2, 106 },
/* BITB 63 */ { ST_IMM, 1, 108 },
/* BITB 64 */ { ST_IND, 1, 109 },
/* BLE 65 */ { ST_EXP, 1, 110 },
/* BLO 66 */ { ST_EXP, 1, 111 },
/* BLS 67 */ { ST_EXP, 1, 112 },
/* BLT 68 */ { ST_EXP, 1, 113 },
/* BMI 69 */ { ST_EXP, 1, 114 },
/* BNE 70 */ { ST_EXP, 1, 115 },
/* BPL 71 */ { ST_EXP, 1, 116 },
/* BRA 72 */ { ST_EXP, 1, 117 },
/* BRN 73 */ { ST_EXP, 1, 118 },
/* BSET 74 */ { ST_BSET, 8, 119 },
/* BSET 75 */ { ST_BSETIND, 8, 127 },
/* BSR 76 */ { ST_EXP, 1, 135 },
/* BTGL 77 */ { ST_BSET, 8, 136 },
/* BTGL 78 */ { ST_BSETIND, 8, 144 },
/* BTST 79 */ { ST_BSET, 8, 152 },
/* BTST 80 */ { ST_BSETIND, 8, 160 },
/* BVC 81 */ { ST_EXP, 1, 168 },
/* BVS 82 */ { ST_EXP, 1, 169 },
/* CBA 83 */ { ST_INH, 1, 170 },
/* CLC 84 */ { ST_INH, 1, 171 },
/* CLI 85 */ { ST_INH, 1, 172 },
/* CLR 86 */ { ST_ACC, 2, 173 },
/* CLR 87 */ { ST_EXP, 1, 175 },
/* CLR 88 */ { ST_IND, 1, 176 },
/* CLRA 89 */ { ST_INH, 1, 177 },
/* CLRB 90 */ { ST_INH, 1, 178 },
/* CLV 91 */ { ST_INH, 1, 179 },
/* CMP 92 */ { ST_AEXP, 4, 180 },
/* CMP 93 */ { ST_AIMM, 2, 184 },
/* CMP 94 */ { ST_AIND, 2, 186 },
/* CMPA 95 */ { ST_EXP, 2, 188 },
/* CMPA 96 */ { ST_IMM, 1, 190 },
/* CMPA 97 */ { ST_IND, 1, 191 },
/* CMPB 98 */ { ST_EXP, 2, 192 },
/* CMPB 99 */ { ST_IMM, 1, 194 },
/* CMPB 100 */ { ST_IND, 1, 195 },
/* COM 101 */ { ST_ACC, 2, 196 },
/* COM 102 */ { ST_EXP, 1, 198 },
/* COM 103 */ { ST_IND, 1, 199 },
/* COMA 104 */ { ST_INH, 1, 200 },
/* COMB 105 */ { ST_INH, 1, 201 },
/* CPX 106 */ { ST_EXP, 2, 202 },
/* CPX 107 */ { ST_IMM, 1, 204 },
/* CPX 108 */ { ST_IND, 1, 205 },
/* DAA 109 */ { ST_INH, 1, 206 },
/* DEC 110 */ { ST_ACC, 2, 207 },
/* DEC 111 */ { ST_EXP, 1, 209 },
/* DEC 112 */ { ST_IND, 1, 210 },
/* DECA 113 */ { ST_INH, 1, 211 },
/* DECB 114 */ { ST_INH, 1, 212 },
/* DES 115 */ { ST_INH, 1, 213 },
/* DEX 116 */ { ST_INH, 1, 214 },
/* EIM 117 */ { ST_MEMIMM, 1, 215 },
/* EIM 118 */ { ST_MEMIMMIND, 1, 216 },
/* EOR 119 */ { ST_AEXP, 4, 217 },
/* EOR 120 */ { ST_AIMM, 2, 221 },
/* EOR 121 */ { ST_AIND, 2, 223 },
/* EORA 122 */ { ST_EXP, 2, 225 },
/* EORA 123 */ { ST_IMM, 1, 227 },
/* EORA 124 */ { ST_IND, 1, 228 },
/* EORB 125 */ { ST_EXP, 2, 229 },
/* EORB 126 */ { ST_IMM, 1, 231 },
/* EORB 127 */ { ST_IND, 1, 232 },
/* INC 128 */ { ST_ACC, 2, 233 },
/* INC 129 */ { ST_EXP, 1, 235 },
/* INC 130 */ { ST_IND, 1, 236 },
/* INCA 131 */ { ST_INH, 1, 237 },
/* INCB 132 */ { ST_INH, 1, 238 },
/* INS 133 */ { ST_INH, 1, 239 },
/* INX 134 */ { ST_INH, 1, 240 },
/* JMP 135 */ { ST_EXP, 1, 241 },
/* JMP 136 */ { ST_IND, 1, 242 },
/* JSR 137 */ { ST_EXP, 2, 243 },
/* JSR 138 */ { ST_IND, 1, 245 },
/* LDA 139 */ { ST_AEXP, 4, 246 },
/* LDA 140 */ { ST_AIMM, 2, 250 },
/* LDA 141 */ { ST_AIND, 2, 252 },
/* LDAA 142 */ { ST_EXP, 2, 254 },
/* LDAA 143 */ { ST_IMM, 1, 256 },
/* LDAA 144 */ { ST_IND, 1, 257 },
/* LDAB 145 */ { ST_EXP, 2, 258 },
/* LDAB 146 */ { ST_IMM, 1, 260 },
/* LDAB 147 */ { ST_IND, 1, 261 },
/* LDD 148 */ { ST_EXP, 2, 262 },
/* LDD 149 */ { ST_IMM, 1, 264 },
/* LDD 150 */ { ST_IND, 1, 265 },
/* LDS 151 */ { ST_EXP, 2, 266 },
/* LDS 152 */ { ST_IMM, 1, 268 },
/* LDS 153 */ { ST_IND, 1, 269 },
/* LDX 154 */ { ST_EXP, 2, 270 },
/* LDX 155 */ { ST_IMM, 1, 272 },
/* LDX 156 */ { ST_IND, 1, 273 },
/* LSL 157 */ { ST_ACC, 2, 274 },
/* LSL 158 */ { ST_EXP, 1, 276 },
/* LSL 159 */ { ST_IND, 1, 277 },
/* LSLA 160 */ { ST_INH, 1, 278 },
/* LSLB 161 */ { ST_INH, 1, 279 },
/* LSLD 162 */ { ST_INH, 1, 280 },
/* LSR 163 */ { ST_ACC, 2, 281 },
/* LSR 164 */ { ST_EXP, 1, 283 },
/* LSR 165 */ { ST_IND, 1, 284 },
/* LSRA 166 */ { ST_INH, 1, 285 },
/* LSRB 167 */ { ST_INH, 1, 286 },
/* LSRD 168 */ { ST_INH, 1, 287 },
/* MUL 169 */ { ST_INH, 1, 288 },
/* NEG 170 */ { ST_ACC, 2, 289 },
/* NEG 171 */ { ST_EXP, 1, 291 },
/* NEG 172 */ { ST_IND, 1, 292 },
/* NEGA 173 */ { ST_INH, 1, 293 },
/* NEGB 174 */ { ST_INH, 1, 294 },
/* NOP 175 */ { ST_INH, 1, 295 },
/* OIM 176 */ { ST_MEMIMM, 1, 296 },
/* OIM 177 */ { ST_MEMIMMIND, 1, 297 },
/* ORA 178 */ { ST_AEXP, 4, 298 },
/* ORA 179 */ { ST_AIMM, 2, 302 },
/* ORA 180 */ { ST_AIND, 2, 304 },
/* ORAA 181 */ { ST_EXP, 2, 306 },
/* ORAA 182 */ { ST_IMM, 1, 308 },
/* ORAA 183 */ { ST_IND, 1, 309 },
/* ORAB 184 */ { ST_EXP, 2, 310 },
/* ORAB 185 */ { ST_IMM, 1, 312 },
/* ORAB 186 */ { ST_IND, 1, 313 },
/* PSH 187 */ { ST_ACC, 2, 314 },
/* PSH 188 */ { ST_INDREG, 1, 316 },
/* PSHA 189 */ { ST_INH, 1, 317 },
/* PSHB 190 */ { ST_INH, 1, 318 },
/* PSHX 191 */ { ST_INH, 1, 319 },
/* PUL 192 */ { ST_ACC, 2, 320 },
/* PUL 193 */ { ST_INDREG, 1, 322 },
/* PULA 194 */ { ST_INH, 1, 323 },
/* PULB 195 */ { ST_INH, 1, 324 },
/* PULX 196 */ { ST_INH, 1, 325 },
/* ROL 197 */ { ST_ACC, 2, 326 },
/* ROL 198 */ { ST_EXP, 1, 328 },
/* ROL 199 */ { ST_IND, 1, 329 },
/* ROLA 200 */ { ST_INH, 1, 330 },
/* ROLB 201 */ { ST_INH, 1, 331 },
/* ROR 202 */ { ST_ACC, 2, 332 },
/* ROR 203 */ { ST_EXP, 1, 334 },
/* ROR 204 */ { ST_IND, 1, 335 },
/* RORA 205 */ { ST_INH, 1, 336 },
/* RORB 206 */ { ST_INH, 1, 337 },
/* RTI 207 */ { ST_INH, 1, 338 },
/* RTS 208 */ { ST_INH, 1, 339 },
/* SBA 209 */ { ST_INH, 1, 340 },
/* SBC 210 */ { ST_AEXP, 4, 341 },
/* SBC 211 */ { ST_AIMM, 2, 345 },
/* SBC 212 */ { ST_AIND, 2, 347 },
/* SBCA 213 */ { ST_EXP, 2, 349 },
/* SBCA 214 */ { ST_IMM, 1, 351 },
/* SBCA 215 */ { ST_IND, 1, 352 },
/* SBCB 216 */ { ST_EXP, 2, 353 },
/* SBCB 217 */ { ST_IMM, 1, 355 },
/* SBCB 218 */ { ST_IND, 1, 356 },
/* SEC 219 */ { ST_INH, 1, 357 },
/* SEI 220 */ { ST_INH, 1, 358 },
/* SEV 221 */ { ST_INH, 1, 359 },
/* SLP 222 */ { ST_INH, 1, 360 },
/* STA 223 */ { ST_AEXP, 4, 361 },
/* STA 224 */ { ST_AIND, 2, 365 },
/* STAA 225 */ { ST_EXP, 2, 367 },
/* STAA 226 */ { ST_IND, 1, 369 },
/* STAB 227 */ { ST_EXP, 2, 370 },
/* STAB 228 */ { ST_IND, 1, 372 },
/* STD 229 */ { ST_EXP, 2, 373 },
/* STD 230 */ { ST_IND, 1, 375 },
/* STS 231 */ { ST_EXP, 2, 376 },
/* STS 232 */ { ST_IND, 1, 378 },
/* STX 233 */ { ST_EXP, 2, 379 },
/* STX 234 */ { ST_IND, 1, 381 },
/* SUB 235 */ { ST_AEXP, 4, 382 },
/* SUB 236 */ { ST_AIMM, 2, 386 },
/* SUB 237 */ { ST_AIND, 2, 388 },
/* SUBA 238 */ { ST_EXP, 2, 390 },
/* SUBA 239 */ { ST_IMM, 1, 392 },
/* SUBA 240 */ { ST_IND, 1, 393 },
/* SUBB 241 */ { ST_EXP, 2, 394 },
/* SUBB 242 */ { ST_IMM, 1, 396 },
/* SUBB 243 */ { ST_IND, 1, 397 },
/* SUBD 244 */ { ST_EXP, 2, 398 },
/* SUBD 245 */ { ST_IMM, 1, 400 },
/* SUBD 246 */ { ST_IND, 1, 401 },
/* SWI 247 */ { ST_INH, 1, 402 },
/* TAB 248 */ { ST_INH, 1, 403 },
/* TAP 249 */ { ST_INH, 1, 404 },
/* TBA 250 */ { ST_INH, 1, 405 },
/* TIM 251 */ { ST_MEMIMM, 1, 406 },
/* TIM 252 */ { ST_MEMIMMIND, 1, 407 },
/* TPA 253 */ { ST_INH, 1, 408 },
/* TST 254 */ { ST_ACC, 2, 409 },
/* TST 255 */ { ST_EXP, 1, 411 },
/* TST 256 */ { ST_IND, 1, 412 },
/* TSTA 257 */ { ST_INH, 1, 413 },
/* TSTB 258 */ { ST_INH, 1, 414 },
/* TSX 259 */ { ST_INH, 1, 415 },
/* TXS 260 */ { ST_INH, 1, 416 },
/* WAI 261 */ { ST_INH, 1, 417 },
/* XGDX 262 */ { ST_INH, 1, 418 },
	{ 0, 0, 0 } };

struct igel igtab[NUMDIFFOP+1]
	= {
/* invalid 0 */   { 0 , 0, 
		"[Xnullentry" },
/* invalid 1 */   { 0 , 0, 
		"[Xinvalid opcode" },
/* ABA 2 */   { 0 , 0, 
		"1b;" },
/* ABX 3 */   { 0 , 0, 
		"3a;" },
/* ADC 4 */   { ACCREG+ADDR , REGA+DIRECT, 
		"99;[1=];" },
/* ADC 5 */   { ACCREG+ADDR , REGA+EXTENDED, 
		"b9;[1=]x" },
/* ADC 6 */   { ACCREG+ADDR , REGB+DIRECT, 
		"d9;[1=];" },
/* ADC 7 */   { ACCREG+ADDR , REGB+EXTENDED, 
		"f9;[1=]x" },
/* ADC 8 */   { ACCREG , REGA, 
		"89;[1=];" },
/* ADC 9 */   { ACCREG , REGB, 
		"c9;[1=];" },
/* ADC 10 */   { ACCREG , REGA, 
		"a9;[1=];" },
/* ADC 11 */   { ACCREG , REGB, 
		"e9;[1=];" },
/* ADCA 12 */   { ADDR , DIRECT, 
		"99;[1=];" },
/* ADCA 13 */   { ADDR , EXTENDED, 
		"b9;[1=]x" },
/* ADCA 14 */   { 0 , 0, 
		"89;[1=];" },
/* ADCA 15 */   { 0 , 0, 
		"a9;[1=];" },
/* ADCB 16 */   { ADDR , DIRECT, 
		"d9;[1=];" },
/* ADCB 17 */   { ADDR , EXTENDED, 
		"f9;[1=]x" },
/* ADCB 18 */   { 0 , 0, 
		"c9;[1=];" },
/* ADCB 19 */   { 0 , 0, 
		"e9;[1=];" },
/* ADD 20 */   { ACCREG+ADDR , REGA+DIRECT, 
		"9b;[1=];" },
/* ADD 21 */   { ACCREG+ADDR , REGA+EXTENDED, 
		"bb;[1=]x" },
/* ADD 22 */   { ACCREG+ADDR , REGB+DIRECT, 
		"db;[1=];" },
/* ADD 23 */   { ACCREG+ADDR , REGB+EXTENDED, 
		"fb;[1=]x" },
/* ADD 24 */   { ACCREG , REGA, 
		"8b;[1=];" },
/* ADD 25 */   { ACCREG , REGB, 
		"cb;[1=];" },
/* ADD 26 */   { ACCREG , REGA, 
		"ab;[1=];" },
/* ADD 27 */   { ACCREG , REGB, 
		"eb;[1=];" },
/* ADDA 28 */   { ADDR , DIRECT, 
		"9b;[1=];" },
/* ADDA 29 */   { ADDR , EXTENDED, 
		"bb;[1=]x" },
/* ADDA 30 */   { 0 , 0, 
		"8b;[1=];" },
/* ADDA 31 */   { 0 , 0, 
		"ab;[1=];" },
/* ADDB 32 */   { ADDR , DIRECT, 
		"db;[1=];" },
/* ADDB 33 */   { ADDR , EXTENDED, 
		"fb;[1=]x" },
/* ADDB 34 */   { 0 , 0, 
		"cb;[1=];" },
/* ADDB 35 */   { 0 , 0, 
		"eb;[1=];" },
/* ADDD 36 */   { ADDR , DIRECT, 
		"d3;[1=];" },
/* ADDD 37 */   { ADDR , EXTENDED, 
		"f3;[1=]x" },
/* ADDD 38 */   { 0 , 0, 
		"c3;[1=]x" },
/* ADDD 39 */   { 0 , 0, 
		"e3;[1=];" },
/* AIM 40 */   { 0 , 0, 
		"71;[1=];[2=];" },
/* AIM 41 */   { 0 , 0, 
		"61;[1=];[2=];" },
/* AND 42 */   { ACCREG+ADDR , REGA+DIRECT, 
		"94;[1=];" },
/* AND 43 */   { ACCREG+ADDR , REGA+EXTENDED, 
		"b4;[1=]x" },
/* AND 44 */   { ACCREG+ADDR , REGB+DIRECT, 
		"d4;[1=];" },
/* AND 45 */   { ACCREG+ADDR , REGB+EXTENDED, 
		"f4;[1=]x" },
/* AND 46 */   { ACCREG , REGA, 
		"84;[1=];" },
/* AND 47 */   { ACCREG , REGB, 
		"c4;[1=];" },
/* AND 48 */   { ACCREG , REGA, 
		"a4;[1=];" },
/* AND 49 */   { ACCREG , REGB, 
		"e4;[1=];" },
/* ANDA 50 */   { ADDR , DIRECT, 
		"94;[1=];" },
/* ANDA 51 */   { ADDR , EXTENDED, 
		"b4;[1=]x" },
/* ANDA 52 */   { 0 , 0, 
		"84;[1=];" },
/* ANDA 53 */   { 0 , 0, 
		"a4;[1=];" },
/* ANDB 54 */   { ADDR , DIRECT, 
		"d4;[1=];" },
/* ANDB 55 */   { ADDR , EXTENDED, 
		"f4;[1=]x" },
/* ANDB 56 */   { 0 , 0, 
		"c4;[1=];" },
/* ANDB 57 */   { 0 , 0, 
		"e4;[1=];" },
/* ASL 58 */   { ACCREG , REGA, 
		"48;" },
/* ASL 59 */   { ACCREG , REGB, 
		"58;" },
/* ASL 60 */   { 0 , 0, 
		"78;[1=]x" },
/* ASL 61 */   { 0 , 0, 
		"68;[1=];" },
/* ASLA 62 */   { 0 , 0, 
		"48;" },
/* ASLB 63 */   { 0 , 0, 
		"58;" },
/* ASLD 64 */   { 0 , 0, 
		"05;" },
/* ASR 65 */   { ACCREG , REGA, 
		"47;" },
/* ASR 66 */   { ACCREG , REGB, 
		"57;" },
/* ASR 67 */   { 0 , 0, 
		"77;[1=]x" },
/* ASR 68 */   { 0 , 0, 
		"67;[1=];" },
/* ASRA 69 */   { 0 , 0, 
		"47;" },
/* ASRB 70 */   { 0 , 0, 
		"57;" },
/* BCC 71 */   { 0 , 0, 
		"24;[1=].P.2+-r" },
/* BCLR 72 */   { BITNUMB , BIT0, 
		"71;fe;[2=];" },
/* BCLR 73 */   { BITNUMB , BIT1, 
		"71;fd;[2=];" },
/* BCLR 74 */   { BITNUMB , BIT2, 
		"71;fb;[2=];" },
/* BCLR 75 */   { BITNUMB , BIT3, 
		"71;f7;[2=];" },
/* BCLR 76 */   { BITNUMB , BIT4, 
		"71;ef;[2=];" },
/* BCLR 77 */   { BITNUMB , BIT5, 
		"71;df;[2=];" },
/* BCLR 78 */   { BITNUMB , BIT6, 
		"71;bf;[2=];" },
/* BCLR 79 */   { BITNUMB , BIT7, 
		"71;7f;[2=];" },
/* BCLR 80 */   { BITNUMB , BIT0, 
		"61;fe;[2=];" },
/* BCLR 81 */   { BITNUMB , BIT1, 
		"61;fd;[2=];" },
/* BCLR 82 */   { BITNUMB , BIT2, 
		"61;fb;[2=];" },
/* BCLR 83 */   { BITNUMB , BIT3, 
		"61;f7;[2=];" },
/* BCLR 84 */   { BITNUMB , BIT4, 
		"61;ef;[2=];" },
/* BCLR 85 */   { BITNUMB , BIT5, 
		"61;df;[2=];" },
/* BCLR 86 */   { BITNUMB , BIT6, 
		"61;bf;[2=];" },
/* BCLR 87 */   { BITNUMB , BIT7, 
		"61;7f;[2=];" },
/* BCS 88 */   { 0 , 0, 
		"25;[1=].P.2+-r" },
/* BEQ 89 */   { 0 , 0, 
		"27;[1=].P.2+-r" },
/* BGE 90 */   { 0 , 0, 
		"2c;[1=].P.2+-r" },
/* BGT 91 */   { 0 , 0, 
		"2e;[1=].P.2+-r" },
/* BHI 92 */   { 0 , 0, 
		"22;[1=].P.2+-r" },
/* BHS 93 */   { 0 , 0, 
		"24;[1=].P.2+-r" },
/* BIT 94 */   { ACCREG+ADDR , REGA+DIRECT, 
		"95;[1=];" },
/* BIT 95 */   { ACCREG+ADDR , REGA+EXTENDED, 
		"b5;[1=]x" },
/* BIT 96 */   { ACCREG+ADDR , REGB+DIRECT, 
		"d5;[1=];" },
/* BIT 97 */   { ACCREG+ADDR , REGB+EXTENDED, 
		"f5;[1=]x" },
/* BIT 98 */   { ACCREG , REGA, 
		"85;[1=];" },
/* BIT 99 */   { ACCREG , REGB, 
		"c5;[1=];" },
/* BIT 100 */   { ACCREG , REGA, 
		"a5;[1=];" },
/* BIT 101 */   { ACCREG , REGB, 
		"e5;[1=];" },
/* BITA 102 */   { ADDR , DIRECT, 
		"95;[1=];" },
/* BITA 103 */   { ADDR , EXTENDED, 
		"b5;[1=]x" },
/* BITA 104 */   { 0 , 0, 
		"85;[1=];" },
/* BITA 105 */   { 0 , 0, 
		"a5;[1=];" },
/* BITB 106 */   { ADDR , DIRECT, 
		"d5;[1=];" },
/* BITB 107 */   { ADDR , EXTENDED, 
		"f5;[1=]x" },
/* BITB 108 */   { 0 , 0, 
		"c5;[1=];" },
/* BITB 109 */   { 0 , 0, 
		"e5;[1=];" },
/* BLE 110 */   { 0 , 0, 
		"2f;[1=].P.2+-r" },
/* BLO 111 */   { 0 , 0, 
		"25;[1=].P.2+-r" },
/* BLS 112 */   { 0 , 0, 
		"23;[1=].P.2+-r" },
/* BLT 113 */   { 0 , 0, 
		"2d;[1=].P.2+-r" },
/* BMI 114 */   { 0 , 0, 
		"2b;[1=].P.2+-r" },
/* BNE 115 */   { 0 , 0, 
		"26;[1=].P.2+-r" },
/* BPL 116 */   { 0 , 0, 
		"2a;[1=].P.2+-r" },
/* BRA 117 */   { 0 , 0, 
		"20;[1=].P.2+-r" },
/* BRN 118 */   { 0 , 0, 
		"21;[1=].P.2+-r" },
/* BSET 119 */   { BITNUMB , BIT0, 
		"72;01;[2=];" },
/* BSET 120 */   { BITNUMB , BIT1, 
		"72;02;[2=];" },
/* BSET 121 */   { BITNUMB , BIT2, 
		"72;04;[2=];" },
/* BSET 122 */   { BITNUMB , BIT3, 
		"72;08;[2=];" },
/* BSET 123 */   { BITNUMB , BIT4, 
		"72;10;[2=];" },
/* BSET 124 */   { BITNUMB , BIT5, 
		"72;20;[2=];" },
/* BSET 125 */   { BITNUMB , BIT6, 
		"72;40;[2=];" },
/* BSET 126 */   { BITNUMB , BIT7, 
		"72;80;[2=];" },
/* BSET 127 */   { BITNUMB , BIT0, 
		"62;01;[2=];" },
/* BSET 128 */   { BITNUMB , BIT1, 
		"62;02;[2=];" },
/* BSET 129 */   { BITNUMB , BIT2, 
		"62;04;[2=];" },
/* BSET 130 */   { BITNUMB , BIT3, 
		"62;08;[2=];" },
/* BSET 131 */   { BITNUMB , BIT4, 
		"62;10;[2=];" },
/* BSET 132 */   { BITNUMB , BIT5, 
		"62;20;[2=];" },
/* BSET 133 */   { BITNUMB , BIT6, 
		"62;40;[2=];" },
/* BSET 134 */   { BITNUMB , BIT7, 
		"62;80;[2=];" },
/* BSR 135 */   { 0 , 0, 
		"8d;[1=].P.2+-r" },
/* BTGL 136 */   { BITNUMB , BIT0, 
		"75;01;[2=];" },
/* BTGL 137 */   { BITNUMB , BIT1, 
		"75;02;[2=];" },
/* BTGL 138 */   { BITNUMB , BIT2, 
		"75;04;[2=];" },
/* BTGL 139 */   { BITNUMB , BIT3, 
		"75;08;[2=];" },
/* BTGL 140 */   { BITNUMB , BIT4, 
		"75;10;[2=];" },
/* BTGL 141 */   { BITNUMB , BIT5, 
		"75;20;[2=];" },
/* BTGL 142 */   { BITNUMB , BIT6, 
		"75;40;[2=];" },
/* BTGL 143 */   { BITNUMB , BIT7, 
		"75;80;[2=];" },
/* BTGL 144 */   { BITNUMB , BIT0, 
		"65;01;[2=];" },
/* BTGL 145 */   { BITNUMB , BIT1, 
		"65;02;[2=];" },
/* BTGL 146 */   { BITNUMB , BIT2, 
		"65;04;[2=];" },
/* BTGL 147 */   { BITNUMB , BIT3, 
		"65;08;[2=];" },
/* BTGL 148 */   { BITNUMB , BIT4, 
		"65;10;[2=];" },
/* BTGL 149 */   { BITNUMB , BIT5, 
		"65;20;[2=];" },
/* BTGL 150 */   { BITNUMB , BIT6, 
		"65;40;[2=];" },
/* BTGL 151 */   { BITNUMB , BIT7, 
		"65;80;[2=];" },
/* BTST 152 */   { BITNUMB , BIT0, 
		"7b;01;[2=];" },
/* BTST 153 */   { BITNUMB , BIT1, 
		"7b;02;[2=];" },
/* BTST 154 */   { BITNUMB , BIT2, 
		"7b;04;[2=];" },
/* BTST 155 */   { BITNUMB , BIT3, 
		"7b;08;[2=];" },
/* BTST 156 */   { BITNUMB , BIT4, 
		"7b;10;[2=];" },
/* BTST 157 */   { BITNUMB , BIT5, 
		"7b;20;[2=];" },
/* BTST 158 */   { BITNUMB , BIT6, 
		"7b;40;[2=];" },
/* BTST 159 */   { BITNUMB , BIT7, 
		"7b;80;[2=];" },
/* BTST 160 */   { BITNUMB , BIT0, 
		"6b;01;[2=];" },
/* BTST 161 */   { BITNUMB , BIT1, 
		"6b;02;[2=];" },
/* BTST 162 */   { BITNUMB , BIT2, 
		"6b;04;[2=];" },
/* BTST 163 */   { BITNUMB , BIT3, 
		"6b;08;[2=];" },
/* BTST 164 */   { BITNUMB , BIT4, 
		"6b;10;[2=];" },
/* BTST 165 */   { BITNUMB , BIT5, 
		"6b;20;[2=];" },
/* BTST 166 */   { BITNUMB , BIT6, 
		"6b;40;[2=];" },
/* BTST 167 */   { BITNUMB , BIT7, 
		"6b;80;[2=];" },
/* BVC 168 */   { 0 , 0, 
		"28;[1=].P.2+-r" },
/* BVS 169 */   { 0 , 0, 
		"29;[1=].P.2+-r" },
/* CBA 170 */   { 0 , 0, 
		"11;" },
/* CLC 171 */   { 0 , 0, 
		"0c;" },
/* CLI 172 */   { 0 , 0, 
		"0e;" },
/* CLR 173 */   { ACCREG , REGA, 
		"4f;" },
/* CLR 174 */   { ACCREG , REGB, 
		"5f;" },
/* CLR 175 */   { 0 , 0, 
		"7f;[1=]x" },
/* CLR 176 */   { 0 , 0, 
		"6f;[1=];" },
/* CLRA 177 */   { 0 , 0, 
		"4f;" },
/* CLRB 178 */   { 0 , 0, 
		"5f;" },
/* CLV 179 */   { 0 , 0, 
		"0a;" },
/* CMP 180 */   { ACCREG+ADDR , REGA+DIRECT, 
		"91;[1=];" },
/* CMP 181 */   { ACCREG+ADDR , REGA+EXTENDED, 
		"b1;[1=]x" },
/* CMP 182 */   { ACCREG+ADDR , REGB+DIRECT, 
		"d1;[1=];" },
/* CMP 183 */   { ACCREG+ADDR , REGB+EXTENDED, 
		"f1;[1=]x" },
/* CMP 184 */   { ACCREG , REGA, 
		"81;[1=];" },
/* CMP 185 */   { ACCREG , REGB, 
		"c1;[1=];" },
/* CMP 186 */   { ACCREG , REGA, 
		"a1;[1=];" },
/* CMP 187 */   { ACCREG , REGB, 
		"e1;[1=];" },
/* CMPA 188 */   { ADDR , DIRECT, 
		"91;[1=];" },
/* CMPA 189 */   { ADDR , EXTENDED, 
		"b1;[1=]x" },
/* CMPA 190 */   { 0 , 0, 
		"81;[1=];" },
/* CMPA 191 */   { 0 , 0, 
		"a1;[1=];" },
/* CMPB 192 */   { ADDR , DIRECT, 
		"d1;[1=];" },
/* CMPB 193 */   { ADDR , EXTENDED, 
		"f1;[1=]x" },
/* CMPB 194 */   { 0 , 0, 
		"c1;[1=];" },
/* CMPB 195 */   { 0 , 0, 
		"e1;[1=];" },
/* COM 196 */   { ACCREG , REGA, 
		"43;" },
/* COM 197 */   { ACCREG , REGB, 
		"53;" },
/* COM 198 */   { 0 , 0, 
		"73;[1=]x" },
/* COM 199 */   { 0 , 0, 
		"63;[1=];" },
/* COMA 200 */   { 0 , 0, 
		"43;" },
/* COMB 201 */   { 0 , 0, 
		"53;" },
/* CPX 202 */   { ADDR , DIRECT, 
		"9c;[1=];" },
/* CPX 203 */   { ADDR , EXTENDED, 
		"bc;[1=]x" },
/* CPX 204 */   { 0 , 0, 
		"8c;[1=]x" },
/* CPX 205 */   { 0 , 0, 
		"ac;[1=];" },
/* DAA 206 */   { 0 , 0, 
		"19;" },
/* DEC 207 */   { ACCREG , REGA, 
		"4a;" },
/* DEC 208 */   { ACCREG , REGB, 
		"5a;" },
/* DEC 209 */   { 0 , 0, 
		"7a;[1=]x" },
/* DEC 210 */   { 0 , 0, 
		"6a;[1=];" },
/* DECA 211 */   { 0 , 0, 
		"4a;" },
/* DECB 212 */   { 0 , 0, 
		"5a;" },
/* DES 213 */   { 0 , 0, 
		"34;" },
/* DEX 214 */   { 0 , 0, 
		"09;" },
/* EIM 215 */   { 0 , 0, 
		"75;[1=];[2=];" },
/* EIM 216 */   { 0 , 0, 
		"65;[1=];[2=];" },
/* EOR 217 */   { ACCREG+ADDR , REGA+DIRECT, 
		"98;[1=];" },
/* EOR 218 */   { ACCREG+ADDR , REGA+EXTENDED, 
		"b8;[1=]x" },
/* EOR 219 */   { ACCREG+ADDR , REGB+DIRECT, 
		"d8;[1=];" },
/* EOR 220 */   { ACCREG+ADDR , REGB+EXTENDED, 
		"f8;[1=]x" },
/* EOR 221 */   { ACCREG , REGA, 
		"88;[1=];" },
/* EOR 222 */   { ACCREG , REGB, 
		"c8;[1=];" },
/* EOR 223 */   { ACCREG , REGA, 
		"a8;[1=];" },
/* EOR 224 */   { ACCREG , REGB, 
		"e8;[1=];" },
/* EORA 225 */   { ADDR , DIRECT, 
		"98;[1=];" },
/* EORA 226 */   { ADDR , EXTENDED, 
		"b8;[1=]x" },
/* EORA 227 */   { 0 , 0, 
		"88;[1=];" },
/* EORA 228 */   { 0 , 0, 
		"a8;[1=];" },
/* EORB 229 */   { ADDR , DIRECT, 
		"d8;[1=];" },
/* EORB 230 */   { ADDR , EXTENDED, 
		"f8;[1=]x" },
/* EORB 231 */   { 0 , 0, 
		"c8;[1=];" },
/* EORB 232 */   { 0 , 0, 
		"e8;[1=];" },
/* INC 233 */   { ACCREG , REGA, 
		"4c;" },
/* INC 234 */   { ACCREG , REGB, 
		"5c;" },
/* INC 235 */   { 0 , 0, 
		"7c;[1=]x" },
/* INC 236 */   { 0 , 0, 
		"6c;[1=];" },
/* INCA 237 */   { 0 , 0, 
		"4c;" },
/* INCB 238 */   { 0 , 0, 
		"5c;" },
/* INS 239 */   { 0 , 0, 
		"31;" },
/* INX 240 */   { 0 , 0, 
		"08;" },
/* JMP 241 */   { 0 , 0, 
		"7e;[1=]x" },
/* JMP 242 */   { 0 , 0, 
		"6e;[1=];" },
/* JSR 243 */   { ADDR , DIRECT, 
		"9d;[1=];" },
/* JSR 244 */   { ADDR , EXTENDED, 
		"bd;[1=]x" },
/* JSR 245 */   { 0 , 0, 
		"ad;[1=];" },
/* LDA 246 */   { ACCREG+ADDR , REGA+DIRECT, 
		"96;[1=];" },
/* LDA 247 */   { ACCREG+ADDR , REGA+EXTENDED, 
		"b6;[1=]x" },
/* LDA 248 */   { ACCREG+ADDR , REGB+DIRECT, 
		"d6;[1=];" },
/* LDA 249 */   { ACCREG+ADDR , REGB+EXTENDED, 
		"f6;[1=]x" },
/* LDA 250 */   { ACCREG , REGA, 
		"86;[1=];" },
/* LDA 251 */   { ACCREG , REGB, 
		"c6;[1=];" },
/* LDA 252 */   { ACCREG , REGA, 
		"a6;[1=];" },
/* LDA 253 */   { ACCREG , REGB, 
		"e6;[1=];" },
/* LDAA 254 */   { ADDR , DIRECT, 
		"96;[1=];" },
/* LDAA 255 */   { ADDR , EXTENDED, 
		"b6;[1=]x" },
/* LDAA 256 */   { 0 , 0, 
		"86;[1=];" },
/* LDAA 257 */   { 0 , 0, 
		"a6;[1=];" },
/* LDAB 258 */   { ADDR , DIRECT, 
		"d6;[1=];" },
/* LDAB 259 */   { ADDR , EXTENDED, 
		"f6;[1=]x" },
/* LDAB 260 */   { 0 , 0, 
		"c6;[1=];" },
/* LDAB 261 */   { 0 , 0, 
		"e6;[1=];" },
/* LDD 262 */   { ADDR , DIRECT, 
		"dc;[1=];" },
/* LDD 263 */   { ADDR , EXTENDED, 
		"fc;[1=]x" },
/* LDD 264 */   { 0 , 0, 
		"cc;[1=]x" },
/* LDD 265 */   { 0 , 0, 
		"ec;[1=];" },
/* LDS 266 */   { ADDR , DIRECT, 
		"9e;[1=];" },
/* LDS 267 */   { ADDR , EXTENDED, 
		"be;[1=]x" },
/* LDS 268 */   { 0 , 0, 
		"8e;[1=]x" },
/* LDS 269 */   { 0 , 0, 
		"ae;[1=];" },
/* LDX 270 */   { ADDR , DIRECT, 
		"de;[1=];" },
/* LDX 271 */   { ADDR , EXTENDED, 
		"fe;[1=]x" },
/* LDX 272 */   { 0 , 0, 
		"ce;[1=]x" },
/* LDX 273 */   { 0 , 0, 
		"ee;[1=];" },
/* LSL 274 */   { ACCREG , REGA, 
		"48;" },
/* LSL 275 */   { ACCREG , REGB, 
		"58;" },
/* LSL 276 */   { 0 , 0, 
		"78;[1=]x" },
/* LSL 277 */   { 0 , 0, 
		"68;[1=];" },
/* LSLA 278 */   { 0 , 0, 
		"48;" },
/* LSLB 279 */   { 0 , 0, 
		"58;" },
/* LSLD 280 */   { 0 , 0, 
		"05;" },
/* LSR 281 */   { ACCREG , REGA, 
		"44;" },
/* LSR 282 */   { ACCREG , REGB, 
		"54;" },
/* LSR 283 */   { 0 , 0, 
		"74;[1=]x" },
/* LSR 284 */   { 0 , 0, 
		"64;[1=];" },
/* LSRA 285 */   { 0 , 0, 
		"44;" },
/* LSRB 286 */   { 0 , 0, 
		"54;" },
/* LSRD 287 */   { 0 , 0, 
		"04;" },
/* MUL 288 */   { 0 , 0, 
		"3d;" },
/* NEG 289 */   { ACCREG , REGA, 
		"40;" },
/* NEG 290 */   { ACCREG , REGB, 
		"50;" },
/* NEG 291 */   { 0 , 0, 
		"70;[1=]x" },
/* NEG 292 */   { 0 , 0, 
		"60;[1=];" },
/* NEGA 293 */   { 0 , 0, 
		"40;" },
/* NEGB 294 */   { 0 , 0, 
		"50;" },
/* NOP 295 */   { 0 , 0, 
		"01;" },
/* OIM 296 */   { 0 , 0, 
		"72;[1=];[2=];" },
/* OIM 297 */   { 0 , 0, 
		"62;[1=];[2=];" },
/* ORA 298 */   { ACCREG+ADDR , REGA+DIRECT, 
		"9a;[1=];" },
/* ORA 299 */   { ACCREG+ADDR , REGA+EXTENDED, 
		"ba;[1=]x" },
/* ORA 300 */   { ACCREG+ADDR , REGB+DIRECT, 
		"da;[1=];" },
/* ORA 301 */   { ACCREG+ADDR , REGB+EXTENDED, 
		"fa;[1=]x" },
/* ORA 302 */   { ACCREG , REGA, 
		"8a;[1=];" },
/* ORA 303 */   { ACCREG , REGB, 
		"ca;[1=];" },
/* ORA 304 */   { ACCREG , REGA, 
		"aa;[1=];" },
/* ORA 305 */   { ACCREG , REGB, 
		"ea;[1=];" },
/* ORAA 306 */   { ADDR , DIRECT, 
		"9a;[1=];" },
/* ORAA 307 */   { ADDR , EXTENDED, 
		"ba;[1=]x" },
/* ORAA 308 */   { 0 , 0, 
		"8a;[1=];" },
/* ORAA 309 */   { 0 , 0, 
		"aa;[1=];" },
/* ORAB 310 */   { ADDR , DIRECT, 
		"da;[1=];" },
/* ORAB 311 */   { ADDR , EXTENDED, 
		"fa;[1=]x" },
/* ORAB 312 */   { 0 , 0, 
		"ca;[1=];" },
/* ORAB 313 */   { 0 , 0, 
		"ea;[1=];" },
/* PSH 314 */   { ACCREG , REGA, 
		"36;" },
/* PSH 315 */   { ACCREG , REGB, 
		"37;" },
/* PSH 316 */   { 0 , 0, 
		"3c;" },
/* PSHA 317 */   { 0 , 0, 
		"36;" },
/* PSHB 318 */   { 0 , 0, 
		"37;" },
/* PSHX 319 */   { 0 , 0, 
		"3c;" },
/* PUL 320 */   { ACCREG , REGA, 
		"32;" },
/* PUL 321 */   { ACCREG , REGB, 
		"33;" },
/* PUL 322 */   { 0 , 0, 
		"38;" },
/* PULA 323 */   { 0 , 0, 
		"32;" },
/* PULB 324 */   { 0 , 0, 
		"33;" },
/* PULX 325 */   { 0 , 0, 
		"38;" },
/* ROL 326 */   { ACCREG , REGA, 
		"49;" },
/* ROL 327 */   { ACCREG , REGB, 
		"59;" },
/* ROL 328 */   { 0 , 0, 
		"79;[1=]x" },
/* ROL 329 */   { 0 , 0, 
		"69;[1=];" },
/* ROLA 330 */   { 0 , 0, 
		"49;" },
/* ROLB 331 */   { 0 , 0, 
		"59;" },
/* ROR 332 */   { ACCREG , REGA, 
		"46;" },
/* ROR 333 */   { ACCREG , REGB, 
		"56;" },
/* ROR 334 */   { 0 , 0, 
		"76;[1=]x" },
/* ROR 335 */   { 0 , 0, 
		"66;[1=];" },
/* RORA 336 */   { 0 , 0, 
		"46;" },
/* RORB 337 */   { 0 , 0, 
		"56;" },
/* RTI 338 */   { 0 , 0, 
		"3b;" },
/* RTS 339 */   { 0 , 0, 
		"39;" },
/* SBA 340 */   { 0 , 0, 
		"10;" },
/* SBC 341 */   { ACCREG+ADDR , REGA+DIRECT, 
		"92;[1=];" },
/* SBC 342 */   { ACCREG+ADDR , REGA+EXTENDED, 
		"b2;[1=]x" },
/* SBC 343 */   { ACCREG+ADDR , REGB+DIRECT, 
		"d2;[1=];" },
/* SBC 344 */   { ACCREG+ADDR , REGB+EXTENDED, 
		"f2;[1=]x" },
/* SBC 345 */   { ACCREG , REGA, 
		"82;[1=];" },
/* SBC 346 */   { ACCREG , REGB, 
		"c2;[1=];" },
/* SBC 347 */   { ACCREG , REGA, 
		"a2;[1=];" },
/* SBC 348 */   { ACCREG , REGB, 
		"e2;[1=];" },
/* SBCA 349 */   { ADDR , DIRECT, 
		"92;[1=];" },
/* SBCA 350 */   { ADDR , EXTENDED, 
		"b2;[1=]x" },
/* SBCA 351 */   { 0 , 0, 
		"82;[1=];" },
/* SBCA 352 */   { 0 , 0, 
		"a2;[1=];" },
/* SBCB 353 */   { ADDR , DIRECT, 
		"d2;[1=];" },
/* SBCB 354 */   { ADDR , EXTENDED, 
		"f2;[1=]x" },
/* SBCB 355 */   { 0 , 0, 
		"c2;[1=];" },
/* SBCB 356 */   { 0 , 0, 
		"e2;[1=];" },
/* SEC 357 */   { 0 , 0, 
		"0d;" },
/* SEI 358 */   { 0 , 0, 
		"0f;" },
/* SEV 359 */   { 0 , 0, 
		"0b;" },
/* SLP 360 */   { 0 , 0, 
		"1a;" },
/* STA 361 */   { ACCREG+ADDR , REGA+DIRECT, 
		"97;[1=];" },
/* STA 362 */   { ACCREG+ADDR , REGA+EXTENDED, 
		"b7;[1=]x" },
/* STA 363 */   { ACCREG+ADDR , REGB+DIRECT, 
		"d7;[1=];" },
/* STA 364 */   { ACCREG+ADDR , REGB+EXTENDED, 
		"f7;[1=]x" },
/* STA 365 */   { ACCREG , REGA, 
		"a7;[1=];" },
/* STA 366 */   { ACCREG , REGB, 
		"e7;[1=];" },
/* STAA 367 */   { ADDR , DIRECT, 
		"97;[1=];" },
/* STAA 368 */   { ADDR , EXTENDED, 
		"b7;[1=]x" },
/* STAA 369 */   { 0 , 0, 
		"a7;[1=];" },
/* STAB 370 */   { ADDR , DIRECT, 
		"d7;[1=];" },
/* STAB 371 */   { ADDR , EXTENDED, 
		"f7;[1=]x" },
/* STAB 372 */   { 0 , 0, 
		"e7;[1=];" },
/* STD 373 */   { ADDR , DIRECT, 
		"dd;[1=];" },
/* STD 374 */   { ADDR , EXTENDED, 
		"fd;[1=]x" },
/* STD 375 */   { 0 , 0, 
		"ed;[1=];" },
/* STS 376 */   { ADDR , DIRECT, 
		"9f;[1=];" },
/* STS 377 */   { ADDR , EXTENDED, 
		"bf;[1=]x" },
/* STS 378 */   { 0 , 0, 
		"af;[1=];" },
/* STX 379 */   { ADDR , DIRECT, 
		"df;[1=];" },
/* STX 380 */   { ADDR , EXTENDED, 
		"ff;[1=]x" },
/* STX 381 */   { 0 , 0, 
		"ef;[1=];" },
/* SUB 382 */   { ACCREG+ADDR , REGA+DIRECT, 
		"90;[1=];" },
/* SUB 383 */   { ACCREG+ADDR , REGA+EXTENDED, 
		"b0;[1=]x" },
/* SUB 384 */   { ACCREG+ADDR , REGB+DIRECT, 
		"d0;[1=];" },
/* SUB 385 */   { ACCREG+ADDR , REGB+EXTENDED, 
		"f0;[1=]x" },
/* SUB 386 */   { ACCREG , REGA, 
		"80;[1=];" },
/* SUB 387 */   { ACCREG , REGB, 
		"c0;[1=];" },
/* SUB 388 */   { ACCREG , REGA, 
		"a0;[1=];" },
/* SUB 389 */   { ACCREG , REGB, 
		"e0;[1=];" },
/* SUBA 390 */   { ADDR , DIRECT, 
		"90;[1=];" },
/* SUBA 391 */   { ADDR , EXTENDED, 
		"b0;[1=]x" },
/* SUBA 392 */   { 0 , 0, 
		"80;[1=];" },
/* SUBA 393 */   { 0 , 0, 
		"a0;[1=];" },
/* SUBB 394 */   { ADDR , DIRECT, 
		"d0;[1=];" },
/* SUBB 395 */   { ADDR , EXTENDED, 
		"f0;[1=]x" },
/* SUBB 396 */   { 0 , 0, 
		"c0;[1=];" },
/* SUBB 397 */   { 0 , 0, 
		"e0;[1=];" },
/* SUBD 398 */   { ADDR , DIRECT, 
		"93;[1=];" },
/* SUBD 399 */   { ADDR , EXTENDED, 
		"b3;[1=]x" },
/* SUBD 400 */   { 0 , 0, 
		"83;[1=]x" },
/* SUBD 401 */   { 0 , 0, 
		"a3;[1=];" },
/* SWI 402 */   { 0 , 0, 
		"3f;" },
/* TAB 403 */   { 0 , 0, 
		"16;" },
/* TAP 404 */   { 0 , 0, 
		"06;" },
/* TBA 405 */   { 0 , 0, 
		"17;" },
/* TIM 406 */   { 0 , 0, 
		"7b;[1=];[2=];" },
/* TIM 407 */   { 0 , 0, 
		"6b;[1=];[2=];" },
/* TPA 408 */   { 0 , 0, 
		"07;" },
/* TST 409 */   { ACCREG , REGA, 
		"4d;" },
/* TST 410 */   { ACCREG , REGB, 
		"5d;" },
/* TST 411 */   { 0 , 0, 
		"7d;[1=]x" },
/* TST 412 */   { 0 , 0, 
		"6d;[1=];" },
/* TSTA 413 */   { 0 , 0, 
		"4d;" },
/* TSTB 414 */   { 0 , 0, 
		"5d;" },
/* TSX 415 */   { 0 , 0, 
		"30;" },
/* TXS 416 */   { 0 , 0, 
		"35;" },
/* WAI 417 */   { 0 , 0, 
		"3e;" },
/* XGDX 418 */   { 0 , 0, 
		"18;" },
	{ 0,0,""} };
/* end fraptabdef.c */
