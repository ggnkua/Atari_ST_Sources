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
FILENAME: 	as6502.y;
WARNINGS: 	"This software is in the public domain.  
		Any prior copyright claims are relinquished.  

		This software is distributed with no warranty whatever.  
		The author takes no responsibility for the consequences 
		of its use.

		Yacc (or Bison) required to compile."  ;
SEE-ALSO: 	as6502.doc,frasmain.c;	
AUTHORS: 	Mark Zenier;
COMPILERS: 	Microport Sys V/AT, ATT Yacc, Turbo C V1.5, Bison (CUG disk 285)
		(previous versions Xenix, Unisoft 68000 Version 7, Sun 3);
*/
/* 65xx instruction generation file */
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

/*	0000.0000.0000.00xx		address mode selection bits */
#define	ADDRESS		0x3
#define	DIRECT		0x1
#define	EXTENDED	0x2
/*	0000.0000.0000.xx00		index selector bits */
#define	INDEXMASK	0xc
#define	INDEXX		0x4
#define	INDEXY		0x8
/*	0000.0xxx.0000.0000		instruction set enable bits */
#define	INSTCMOS	0x100
#define	INSTROCKWELL	0x200
#define	INST21		0x400
/*					instruction sets */
#define	CPU65		0
#define	CPUR65		INSTROCKWELL
#define	CPU65C		INSTCMOS
#define	CPUR65C		(INSTROCKWELL|INSTCMOS)
#define	CPUR21		(INSTROCKWELL|INST21)
#define ST_INH 0x1
#define ST_ACCUM 0x2
#define ST_EXPR 0x4
#define ST_INDEX 0x8
#define ST_PREINDEX 0x10
#define ST_INDIR 0x20
#define ST_POSTINDEX 0x40
#define ST_IMMED 0x80
#define ST_DIRREL 0x100
	
	int	cpuselect = CPUR65C;
	static char	genbdef[] = "[1=];";
	static char	genwdef[] = "[1=]y"; /* x for normal, y for byte rev */
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
}

%type <intv> topexpr
%token ACCUM
%token <intv> INDEX
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
			fraerror("unknown cpu type, R65C02 assumed");
			cpuselect = CPUR65C;
		}
			}
	;
genline : KOC_opcode 
			{
		genlocrec(currseg, labelloc);
		locctr += geninstr(findgen($1, ST_INH, cpuselect));
			}
	;
genline : KOC_opcode  ACCUM
			{
		genlocrec(currseg, labelloc);
		locctr += geninstr(findgen($1, ST_ACCUM, cpuselect));
			}
	;
genline : KOC_opcode  topexpr
			{
		pevalexpr(1, $2);
		genlocrec(currseg, labelloc);
		locctr += geninstr( findgen( $1, ST_EXPR, 
				  ( (evalr[1].seg == SSG_ABS 
				&& evalr[1].value >= 0
				&& evalr[1].value <= 255 )
				? DIRECT : EXTENDED ) | cpuselect )
				);
			}
	;
genline : KOC_opcode  topexpr ',' INDEX
			{
		pevalexpr(1, $2);
		genlocrec(currseg, labelloc);
		locctr += geninstr( findgen( $1, ST_INDEX, 
				  ( (evalr[1].seg == SSG_ABS 
				&& evalr[1].value >= 0
				&& evalr[1].value <= 255 )
				? DIRECT : EXTENDED ) | cpuselect | $4 )
				);
			}
	;
genline : KOC_opcode  '(' topexpr ',' INDEX ')'
			{
		pevalexpr(1, $3);
		genlocrec(currseg, labelloc);
		locctr += geninstr( findgen( $1, ST_PREINDEX, 
				  ( (evalr[1].seg == SSG_ABS 
				&& evalr[1].value >= 0
				&& evalr[1].value <= 255 )
				? DIRECT : EXTENDED ) | cpuselect | $5 )
				);
			}
	;
genline : KOC_opcode  '(' topexpr ')'
			{
		pevalexpr(1, $3);
		genlocrec(currseg, labelloc);
		locctr += geninstr( findgen( $1, ST_INDIR, 
				  ( (evalr[1].seg == SSG_ABS 
				&& evalr[1].value >= 0
				&& evalr[1].value <= 255 )
				? DIRECT : EXTENDED ) | cpuselect )
				);
			}
	;
genline : KOC_opcode  '(' topexpr ')' ',' INDEX
			{
		pevalexpr(1, $3);
		genlocrec(currseg, labelloc);
		locctr += geninstr( findgen( $1, ST_POSTINDEX, 
				  ( (evalr[1].seg == SSG_ABS 
				&& evalr[1].value >= 0
				&& evalr[1].value <= 255 )
				? DIRECT : EXTENDED ) | cpuselect | $6 )
				);
			}
	;
genline : KOC_opcode  '#' topexpr
			{
		pevalexpr(1, $3);
		genlocrec(currseg, labelloc);
		locctr += geninstr( findgen($1, ST_IMMED, cpuselect));
			}
	;
genline : KOC_opcode  topexpr ',' topexpr
			{
		pevalexpr(1, $2);
		pevalexpr(2, $4);
		genlocrec(currseg, labelloc);
		locctr += geninstr( findgen($1, ST_DIRREL, cpuselect));
			}
	;
topexpr	:	'+' expr %prec KEOP_MUN
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
	;

expr	:	'(' topexpr ')'
			{
				$$ = $2;
			}
	|	topexpr
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

	/* machine specific token definitions */
	reservedsym("a", ACCUM, 0);
	reservedsym("x", INDEX, INDEXX);
	reservedsym("y", INDEX, INDEXY);
	reservedsym("A", ACCUM, 0);
	reservedsym("X", INDEX, INDEXX);
	reservedsym("Y", INDEX, INDEXY);

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
		{"R65C", CPUR65C },
		{"r65c", CPUR65C },
		{"65C", CPU65C },
		{"65c", CPU65C },
		{"R65", CPUR65 },
		{"r65", CPUR65 },
		{"21", CPUR21 },
		{"65", CPU65 },
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

#define NUMOPCODE 124
#define NUMSYNBLK 166
#define NUMDIFFOP 221

int gnumopcode = NUMOPCODE;

int ophashlnk[NUMOPCODE];

struct opsym optab[NUMOPCODE+1]
	= {
	{"invalid", KOC_opcode, 2, 0 },
	{"ADC", KOC_opcode, 6, 2 },
	{"AND", KOC_opcode, 6, 8 },
	{"ASL", KOC_opcode, 3, 14 },
	{"BBR0", KOC_opcode, 1, 17 },
	{"BBR1", KOC_opcode, 1, 18 },
	{"BBR2", KOC_opcode, 1, 19 },
	{"BBR3", KOC_opcode, 1, 20 },
	{"BBR4", KOC_opcode, 1, 21 },
	{"BBR5", KOC_opcode, 1, 22 },
	{"BBR6", KOC_opcode, 1, 23 },
	{"BBR7", KOC_opcode, 1, 24 },
	{"BBS0", KOC_opcode, 1, 25 },
	{"BBS1", KOC_opcode, 1, 26 },
	{"BBS2", KOC_opcode, 1, 27 },
	{"BBS3", KOC_opcode, 1, 28 },
	{"BBS4", KOC_opcode, 1, 29 },
	{"BBS5", KOC_opcode, 1, 30 },
	{"BBS6", KOC_opcode, 1, 31 },
	{"BBS7", KOC_opcode, 1, 32 },
	{"BCC", KOC_opcode, 1, 33 },
	{"BCS", KOC_opcode, 1, 34 },
	{"BEQ", KOC_opcode, 1, 35 },
	{"BGE", KOC_opcode, 1, 36 },
	{"BIT", KOC_opcode, 3, 37 },
	{"BLT", KOC_opcode, 1, 40 },
	{"BMI", KOC_opcode, 1, 41 },
	{"BNE", KOC_opcode, 1, 42 },
	{"BPL", KOC_opcode, 1, 43 },
	{"BRA", KOC_opcode, 1, 44 },
	{"BRK", KOC_opcode, 2, 45 },
	{"BVC", KOC_opcode, 1, 47 },
	{"BVS", KOC_opcode, 1, 48 },
	{"BYTE", KOC_BDEF, 0, 0 },
	{"CHARDEF", KOC_CHDEF, 0, 0 },
	{"CHARSET", KOC_CHSET, 0, 0 },
	{"CHARUSE", KOC_CHUSE, 0, 0 },
	{"CHD", KOC_CHDEF, 0, 0 },
	{"CLC", KOC_opcode, 1, 49 },
	{"CLD", KOC_opcode, 1, 50 },
	{"CLI", KOC_opcode, 1, 51 },
	{"CLV", KOC_opcode, 1, 52 },
	{"CMP", KOC_opcode, 6, 53 },
	{"CPU", KOC_CPU, 0, 0 },
	{"CPX", KOC_opcode, 2, 59 },
	{"CPY", KOC_opcode, 2, 61 },
	{"DB", KOC_BDEF, 0, 0 },
	{"DEC", KOC_opcode, 3, 63 },
	{"DEX", KOC_opcode, 1, 66 },
	{"DEY", KOC_opcode, 1, 67 },
	{"DW", KOC_WDEF, 0, 0 },
	{"ELSE", KOC_ELSE, 0, 0 },
	{"END", KOC_END, 0, 0 },
	{"ENDI", KOC_ENDI, 0, 0 },
	{"EOR", KOC_opcode, 6, 68 },
	{"EQU", KOC_EQU, 0, 0 },
	{"FCB", KOC_BDEF, 0, 0 },
	{"FCC", KOC_SDEF, 0, 0 },
	{"FDB", KOC_WDEF, 0, 0 },
	{"IF", KOC_IF, 0, 0 },
	{"INC", KOC_opcode, 3, 74 },
	{"INCL", KOC_INCLUDE, 0, 0 },
	{"INCLUDE", KOC_INCLUDE, 0, 0 },
	{"INX", KOC_opcode, 1, 77 },
	{"INY", KOC_opcode, 1, 78 },
	{"JMP", KOC_opcode, 3, 79 },
	{"JSR", KOC_opcode, 1, 82 },
	{"LDA", KOC_opcode, 6, 83 },
	{"LDX", KOC_opcode, 3, 89 },
	{"LDY", KOC_opcode, 3, 92 },
	{"LSR", KOC_opcode, 3, 95 },
	{"MUL", KOC_opcode, 1, 98 },
	{"NOP", KOC_opcode, 1, 99 },
	{"ORA", KOC_opcode, 6, 100 },
	{"ORG", KOC_ORG, 0, 0 },
	{"PHA", KOC_opcode, 1, 106 },
	{"PHP", KOC_opcode, 1, 107 },
	{"PHX", KOC_opcode, 1, 108 },
	{"PHY", KOC_opcode, 1, 109 },
	{"PLA", KOC_opcode, 1, 110 },
	{"PLP", KOC_opcode, 1, 111 },
	{"PLX", KOC_opcode, 1, 112 },
	{"PLY", KOC_opcode, 1, 113 },
	{"RESERVE", KOC_RESM, 0, 0 },
	{"RMB0", KOC_opcode, 1, 114 },
	{"RMB1", KOC_opcode, 1, 115 },
	{"RMB2", KOC_opcode, 1, 116 },
	{"RMB3", KOC_opcode, 1, 117 },
	{"RMB4", KOC_opcode, 1, 118 },
	{"RMB5", KOC_opcode, 1, 119 },
	{"RMB6", KOC_opcode, 1, 120 },
	{"RMB7", KOC_opcode, 1, 121 },
	{"RMB", KOC_RESM, 0, 0 },
	{"ROL", KOC_opcode, 3, 122 },
	{"ROR", KOC_opcode, 3, 125 },
	{"RTI", KOC_opcode, 1, 128 },
	{"RTS", KOC_opcode, 1, 129 },
	{"SBC", KOC_opcode, 6, 130 },
	{"SEC", KOC_opcode, 1, 136 },
	{"SED", KOC_opcode, 1, 137 },
	{"SEI", KOC_opcode, 1, 138 },
	{"SET", KOC_SET, 0, 0 },
	{"SMB0", KOC_opcode, 1, 139 },
	{"SMB1", KOC_opcode, 1, 140 },
	{"SMB2", KOC_opcode, 1, 141 },
	{"SMB3", KOC_opcode, 1, 142 },
	{"SMB4", KOC_opcode, 1, 143 },
	{"SMB5", KOC_opcode, 1, 144 },
	{"SMB6", KOC_opcode, 1, 145 },
	{"SMB7", KOC_opcode, 1, 146 },
	{"STA", KOC_opcode, 5, 147 },
	{"STRING", KOC_SDEF, 0, 0 },
	{"STX", KOC_opcode, 2, 152 },
	{"STY", KOC_opcode, 2, 154 },
	{"STZ", KOC_opcode, 2, 156 },
	{"TAX", KOC_opcode, 1, 158 },
	{"TAY", KOC_opcode, 1, 159 },
	{"TRB", KOC_opcode, 1, 160 },
	{"TSB", KOC_opcode, 1, 161 },
	{"TSX", KOC_opcode, 1, 162 },
	{"TXA", KOC_opcode, 1, 163 },
	{"TXS", KOC_opcode, 1, 164 },
	{"TYA", KOC_opcode, 1, 165 },
	{"WORD", KOC_WDEF, 0, 0 },
	{ "", 0, 0, 0 }};

struct opsynt ostab[NUMSYNBLK+1]
	= {
/* invalid 0 */ { 0, 1, 0 },
/* invalid 1 */ { 0xffff, 1, 1 },
/* ADC 2 */ { ST_EXPR, 2, 2 },
/* ADC 3 */ { ST_IMMED, 1, 4 },
/* ADC 4 */ { ST_INDEX, 3, 5 },
/* ADC 5 */ { ST_INDIR, 1, 8 },
/* ADC 6 */ { ST_POSTINDEX, 1, 9 },
/* ADC 7 */ { ST_PREINDEX, 1, 10 },
/* AND 8 */ { ST_EXPR, 2, 11 },
/* AND 9 */ { ST_IMMED, 1, 13 },
/* AND 10 */ { ST_INDEX, 3, 14 },
/* AND 11 */ { ST_INDIR, 1, 17 },
/* AND 12 */ { ST_POSTINDEX, 1, 18 },
/* AND 13 */ { ST_PREINDEX, 1, 19 },
/* ASL 14 */ { ST_ACCUM, 1, 20 },
/* ASL 15 */ { ST_EXPR, 2, 21 },
/* ASL 16 */ { ST_INDEX, 2, 23 },
/* BBR0 17 */ { ST_DIRREL, 1, 25 },
/* BBR1 18 */ { ST_DIRREL, 1, 26 },
/* BBR2 19 */ { ST_DIRREL, 1, 27 },
/* BBR3 20 */ { ST_DIRREL, 1, 28 },
/* BBR4 21 */ { ST_DIRREL, 1, 29 },
/* BBR5 22 */ { ST_DIRREL, 1, 30 },
/* BBR6 23 */ { ST_DIRREL, 1, 31 },
/* BBR7 24 */ { ST_DIRREL, 1, 32 },
/* BBS0 25 */ { ST_DIRREL, 1, 33 },
/* BBS1 26 */ { ST_DIRREL, 1, 34 },
/* BBS2 27 */ { ST_DIRREL, 1, 35 },
/* BBS3 28 */ { ST_DIRREL, 1, 36 },
/* BBS4 29 */ { ST_DIRREL, 1, 37 },
/* BBS5 30 */ { ST_DIRREL, 1, 38 },
/* BBS6 31 */ { ST_DIRREL, 1, 39 },
/* BBS7 32 */ { ST_DIRREL, 1, 40 },
/* BCC 33 */ { ST_EXPR, 1, 41 },
/* BCS 34 */ { ST_EXPR, 1, 42 },
/* BEQ 35 */ { ST_EXPR, 1, 43 },
/* BGE 36 */ { ST_EXPR, 1, 44 },
/* BIT 37 */ { ST_EXPR, 2, 45 },
/* BIT 38 */ { ST_IMMED, 1, 47 },
/* BIT 39 */ { ST_INDEX, 2, 48 },
/* BLT 40 */ { ST_EXPR, 1, 50 },
/* BMI 41 */ { ST_EXPR, 1, 51 },
/* BNE 42 */ { ST_EXPR, 1, 52 },
/* BPL 43 */ { ST_EXPR, 1, 53 },
/* BRA 44 */ { ST_EXPR, 2, 54 },
/* BRK 45 */ { ST_IMMED, 1, 56 },
/* BRK 46 */ { ST_INH, 1, 57 },
/* BVC 47 */ { ST_EXPR, 1, 58 },
/* BVS 48 */ { ST_EXPR, 1, 59 },
/* CLC 49 */ { ST_INH, 1, 60 },
/* CLD 50 */ { ST_INH, 1, 61 },
/* CLI 51 */ { ST_INH, 1, 62 },
/* CLV 52 */ { ST_INH, 1, 63 },
/* CMP 53 */ { ST_EXPR, 2, 64 },
/* CMP 54 */ { ST_IMMED, 1, 66 },
/* CMP 55 */ { ST_INDEX, 3, 67 },
/* CMP 56 */ { ST_INDIR, 1, 70 },
/* CMP 57 */ { ST_POSTINDEX, 1, 71 },
/* CMP 58 */ { ST_PREINDEX, 1, 72 },
/* CPX 59 */ { ST_EXPR, 2, 73 },
/* CPX 60 */ { ST_IMMED, 1, 75 },
/* CPY 61 */ { ST_EXPR, 2, 76 },
/* CPY 62 */ { ST_IMMED, 1, 78 },
/* DEC 63 */ { ST_ACCUM, 1, 79 },
/* DEC 64 */ { ST_EXPR, 2, 80 },
/* DEC 65 */ { ST_INDEX, 2, 82 },
/* DEX 66 */ { ST_INH, 1, 84 },
/* DEY 67 */ { ST_INH, 1, 85 },
/* EOR 68 */ { ST_EXPR, 2, 86 },
/* EOR 69 */ { ST_IMMED, 1, 88 },
/* EOR 70 */ { ST_INDEX, 3, 89 },
/* EOR 71 */ { ST_INDIR, 1, 92 },
/* EOR 72 */ { ST_POSTINDEX, 1, 93 },
/* EOR 73 */ { ST_PREINDEX, 1, 94 },
/* INC 74 */ { ST_ACCUM, 1, 95 },
/* INC 75 */ { ST_EXPR, 2, 96 },
/* INC 76 */ { ST_INDEX, 2, 98 },
/* INX 77 */ { ST_INH, 1, 100 },
/* INY 78 */ { ST_INH, 1, 101 },
/* JMP 79 */ { ST_EXPR, 1, 102 },
/* JMP 80 */ { ST_INDIR, 1, 103 },
/* JMP 81 */ { ST_PREINDEX, 1, 104 },
/* JSR 82 */ { ST_EXPR, 1, 105 },
/* LDA 83 */ { ST_EXPR, 2, 106 },
/* LDA 84 */ { ST_IMMED, 1, 108 },
/* LDA 85 */ { ST_INDEX, 3, 109 },
/* LDA 86 */ { ST_INDIR, 1, 112 },
/* LDA 87 */ { ST_POSTINDEX, 1, 113 },
/* LDA 88 */ { ST_PREINDEX, 1, 114 },
/* LDX 89 */ { ST_EXPR, 2, 115 },
/* LDX 90 */ { ST_IMMED, 1, 117 },
/* LDX 91 */ { ST_INDEX, 2, 118 },
/* LDY 92 */ { ST_EXPR, 2, 120 },
/* LDY 93 */ { ST_IMMED, 1, 122 },
/* LDY 94 */ { ST_INDEX, 2, 123 },
/* LSR 95 */ { ST_ACCUM, 1, 125 },
/* LSR 96 */ { ST_EXPR, 2, 126 },
/* LSR 97 */ { ST_INDEX, 2, 128 },
/* MUL 98 */ { ST_INH, 1, 130 },
/* NOP 99 */ { ST_INH, 1, 131 },
/* ORA 100 */ { ST_EXPR, 2, 132 },
/* ORA 101 */ { ST_IMMED, 1, 134 },
/* ORA 102 */ { ST_INDEX, 3, 135 },
/* ORA 103 */ { ST_INDIR, 1, 138 },
/* ORA 104 */ { ST_POSTINDEX, 1, 139 },
/* ORA 105 */ { ST_PREINDEX, 1, 140 },
/* PHA 106 */ { ST_INH, 1, 141 },
/* PHP 107 */ { ST_INH, 1, 142 },
/* PHX 108 */ { ST_INH, 2, 143 },
/* PHY 109 */ { ST_INH, 2, 145 },
/* PLA 110 */ { ST_INH, 1, 147 },
/* PLP 111 */ { ST_INH, 1, 148 },
/* PLX 112 */ { ST_INH, 2, 149 },
/* PLY 113 */ { ST_INH, 2, 151 },
/* RMB0 114 */ { ST_EXPR, 1, 153 },
/* RMB1 115 */ { ST_EXPR, 1, 154 },
/* RMB2 116 */ { ST_EXPR, 1, 155 },
/* RMB3 117 */ { ST_EXPR, 1, 156 },
/* RMB4 118 */ { ST_EXPR, 1, 157 },
/* RMB5 119 */ { ST_EXPR, 1, 158 },
/* RMB6 120 */ { ST_EXPR, 1, 159 },
/* RMB7 121 */ { ST_EXPR, 1, 160 },
/* ROL 122 */ { ST_ACCUM, 1, 161 },
/* ROL 123 */ { ST_EXPR, 2, 162 },
/* ROL 124 */ { ST_INDEX, 2, 164 },
/* ROR 125 */ { ST_ACCUM, 1, 166 },
/* ROR 126 */ { ST_EXPR, 2, 167 },
/* ROR 127 */ { ST_INDEX, 2, 169 },
/* RTI 128 */ { ST_INH, 1, 171 },
/* RTS 129 */ { ST_INH, 1, 172 },
/* SBC 130 */ { ST_EXPR, 2, 173 },
/* SBC 131 */ { ST_IMMED, 1, 175 },
/* SBC 132 */ { ST_INDEX, 3, 176 },
/* SBC 133 */ { ST_INDIR, 1, 179 },
/* SBC 134 */ { ST_POSTINDEX, 1, 180 },
/* SBC 135 */ { ST_PREINDEX, 1, 181 },
/* SEC 136 */ { ST_INH, 1, 182 },
/* SED 137 */ { ST_INH, 1, 183 },
/* SEI 138 */ { ST_INH, 1, 184 },
/* SMB0 139 */ { ST_EXPR, 1, 185 },
/* SMB1 140 */ { ST_EXPR, 1, 186 },
/* SMB2 141 */ { ST_EXPR, 1, 187 },
/* SMB3 142 */ { ST_EXPR, 1, 188 },
/* SMB4 143 */ { ST_EXPR, 1, 189 },
/* SMB5 144 */ { ST_EXPR, 1, 190 },
/* SMB6 145 */ { ST_EXPR, 1, 191 },
/* SMB7 146 */ { ST_EXPR, 1, 192 },
/* STA 147 */ { ST_EXPR, 2, 193 },
/* STA 148 */ { ST_INDEX, 3, 195 },
/* STA 149 */ { ST_INDIR, 1, 198 },
/* STA 150 */ { ST_POSTINDEX, 1, 199 },
/* STA 151 */ { ST_PREINDEX, 1, 200 },
/* STX 152 */ { ST_EXPR, 2, 201 },
/* STX 153 */ { ST_INDEX, 1, 203 },
/* STY 154 */ { ST_EXPR, 2, 204 },
/* STY 155 */ { ST_INDEX, 1, 206 },
/* STZ 156 */ { ST_EXPR, 2, 207 },
/* STZ 157 */ { ST_INDEX, 2, 209 },
/* TAX 158 */ { ST_INH, 1, 211 },
/* TAY 159 */ { ST_INH, 1, 212 },
/* TRB 160 */ { ST_EXPR, 2, 213 },
/* TSB 161 */ { ST_EXPR, 2, 215 },
/* TSX 162 */ { ST_INH, 1, 217 },
/* TXA 163 */ { ST_INH, 1, 218 },
/* TXS 164 */ { ST_INH, 1, 219 },
/* TYA 165 */ { ST_INH, 1, 220 },
	{ 0, 0, 0 } };

struct igel igtab[NUMDIFFOP+1]
	= {
/* invalid 0 */   { 0 , 0, 
		"[Xnullentry" },
/* invalid 1 */   { 0 , 0, 
		"[Xinvalid opcode" },
/* ADC 2 */   { ADDRESS , DIRECT, 
		"65;[1=];" },
/* ADC 3 */   { ADDRESS , EXTENDED, 
		"6d;[1=]y" },
/* ADC 4 */   { 0 , 0, 
		"69;[1=];" },
/* ADC 5 */   { ADDRESS|INDEXMASK , DIRECT|INDEXX, 
		"75;[1=];" },
/* ADC 6 */   { ADDRESS|INDEXMASK , EXTENDED|INDEXX, 
		"7d;[1=]y" },
/* ADC 7 */   { INDEXMASK , INDEXY, 
		"79;[1=]y" },
/* ADC 8 */   { INSTCMOS|ADDRESS , DIRECT|INSTCMOS, 
		"72;[1=];" },
/* ADC 9 */   { ADDRESS|INDEXMASK , DIRECT|INDEXY, 
		"71;[1=];" },
/* ADC 10 */   { ADDRESS|INDEXMASK , DIRECT|INDEXX, 
		"61;[1=];" },
/* AND 11 */   { ADDRESS , DIRECT, 
		"25;[1=];" },
/* AND 12 */   { ADDRESS , EXTENDED, 
		"2d;[1=]y" },
/* AND 13 */   { 0 , 0, 
		"29;[1=];" },
/* AND 14 */   { ADDRESS|INDEXMASK , DIRECT|INDEXX, 
		"35;[1=];" },
/* AND 15 */   { ADDRESS|INDEXMASK , EXTENDED|INDEXX, 
		"3d;[1=]y" },
/* AND 16 */   { INDEXMASK , INDEXY, 
		"39;[1=]y" },
/* AND 17 */   { INSTCMOS|ADDRESS , DIRECT|INSTCMOS, 
		"32;[1=];" },
/* AND 18 */   { ADDRESS|INDEXMASK , DIRECT|INDEXY, 
		"31;[1=];" },
/* AND 19 */   { ADDRESS|INDEXMASK , DIRECT|INDEXX, 
		"21;[1=];" },
/* ASL 20 */   { 0 , 0, 
		"0a;" },
/* ASL 21 */   { ADDRESS , DIRECT, 
		"06;[1=];" },
/* ASL 22 */   { ADDRESS , EXTENDED, 
		"0e;[1=]y" },
/* ASL 23 */   { ADDRESS|INDEXMASK , DIRECT|INDEXX, 
		"16;[1=];" },
/* ASL 24 */   { ADDRESS|INDEXMASK , EXTENDED|INDEXX, 
		"1e;[1=]y" },
/* BBR0 25 */   { INSTROCKWELL , INSTROCKWELL, 
		"0f;[1=];[2=].Q.1+-r" },
/* BBR1 26 */   { INSTROCKWELL , INSTROCKWELL, 
		"1f;[1=];[2=].Q.1+-r" },
/* BBR2 27 */   { INSTROCKWELL , INSTROCKWELL, 
		"2f;[1=];[2=].Q.1+-r" },
/* BBR3 28 */   { INSTROCKWELL , INSTROCKWELL, 
		"3f;[1=];[2=].Q.1+-r" },
/* BBR4 29 */   { INSTROCKWELL , INSTROCKWELL, 
		"4f;[1=];[2=].Q.1+-r" },
/* BBR5 30 */   { INSTROCKWELL , INSTROCKWELL, 
		"5f;[1=];[2=].Q.1+-r" },
/* BBR6 31 */   { INSTROCKWELL , INSTROCKWELL, 
		"6f;[1=];[2=].Q.1+-r" },
/* BBR7 32 */   { INSTROCKWELL , INSTROCKWELL, 
		"7f;[1=];[2=].Q.1+-r" },
/* BBS0 33 */   { INSTROCKWELL , INSTROCKWELL, 
		"8f;[1=];[2=].Q.1+-r" },
/* BBS1 34 */   { INSTROCKWELL , INSTROCKWELL, 
		"9f;[1=];[2=].Q.1+-r" },
/* BBS2 35 */   { INSTROCKWELL , INSTROCKWELL, 
		"af;[1=];[2=].Q.1+-r" },
/* BBS3 36 */   { INSTROCKWELL , INSTROCKWELL, 
		"bf;[1=];[2=].Q.1+-r" },
/* BBS4 37 */   { INSTROCKWELL , INSTROCKWELL, 
		"cf;[1=];[2=].Q.1+-r" },
/* BBS5 38 */   { INSTROCKWELL , INSTROCKWELL, 
		"df;[1=];[2=].Q.1+-r" },
/* BBS6 39 */   { INSTROCKWELL , INSTROCKWELL, 
		"ef;[1=];[2=].Q.1+-r" },
/* BBS7 40 */   { INSTROCKWELL , INSTROCKWELL, 
		"ff;[1=];[2=].Q.1+-r" },
/* BCC 41 */   { 0 , 0, 
		"90;[1=].Q.1+-r" },
/* BCS 42 */   { 0 , 0, 
		"b0;[1=].Q.1+-r" },
/* BEQ 43 */   { 0 , 0, 
		"f0;[1=].Q.1+-r" },
/* BGE 44 */   { 0 , 0, 
		"b0;[1=].Q.1+-r" },
/* BIT 45 */   { ADDRESS , DIRECT, 
		"24;[1=];" },
/* BIT 46 */   { ADDRESS , EXTENDED, 
		"2c;[1=]y" },
/* BIT 47 */   { INSTCMOS , INSTCMOS, 
		"89;[1=];" },
/* BIT 48 */   { ADDRESS|INDEXMASK|INSTCMOS , DIRECT|INDEXX|INSTCMOS, 
		"34;[1=];" },
/* BIT 49 */   { ADDRESS|INDEXMASK|INSTCMOS , EXTENDED|INDEXX|INSTCMOS, 
		"3c;[1=]y" },
/* BLT 50 */   { 0 , 0, 
		"90;[1=].Q.1+-r" },
/* BMI 51 */   { 0 , 0, 
		"30;[1=].Q.1+-r" },
/* BNE 52 */   { 0 , 0, 
		"d0;[1=].Q.1+-r" },
/* BPL 53 */   { 0 , 0, 
		"10;[1=].Q.1+-r" },
/* BRA 54 */   { INST21 , INST21, 
		"80;[1=].Q.1+-r" },
/* BRA 55 */   { INSTCMOS , INSTCMOS, 
		"80;[1=].Q.1+-r" },
/* BRK 56 */   { 0 , 0, 
		"00;[1=];" },
/* BRK 57 */   { 0 , 0, 
		"00;" },
/* BVC 58 */   { 0 , 0, 
		"50;[1=].Q.1+-r" },
/* BVS 59 */   { 0 , 0, 
		"70;[1=].Q.1+-r" },
/* CLC 60 */   { 0 , 0, 
		"18;" },
/* CLD 61 */   { 0 , 0, 
		"d8;" },
/* CLI 62 */   { 0 , 0, 
		"58;" },
/* CLV 63 */   { 0 , 0, 
		"b8;" },
/* CMP 64 */   { ADDRESS , DIRECT, 
		"c5;[1=];" },
/* CMP 65 */   { ADDRESS , EXTENDED, 
		"cd;[1=]y" },
/* CMP 66 */   { 0 , 0, 
		"c9;[1=];" },
/* CMP 67 */   { ADDRESS|INDEXMASK , DIRECT|INDEXX, 
		"d5;[1=];" },
/* CMP 68 */   { ADDRESS|INDEXMASK , EXTENDED|INDEXX, 
		"dd;[1=]y" },
/* CMP 69 */   { INDEXMASK , INDEXY, 
		"d9;[1=]y" },
/* CMP 70 */   { INSTCMOS|ADDRESS , DIRECT|INSTCMOS, 
		"d2;[1=];" },
/* CMP 71 */   { ADDRESS|INDEXMASK , DIRECT|INDEXY, 
		"d1;[1=];" },
/* CMP 72 */   { ADDRESS|INDEXMASK , DIRECT|INDEXX, 
		"c1;[1=];" },
/* CPX 73 */   { ADDRESS , DIRECT, 
		"e4;[1=];" },
/* CPX 74 */   { ADDRESS , EXTENDED, 
		"ec;[1=]y" },
/* CPX 75 */   { 0 , 0, 
		"e0;[1=];" },
/* CPY 76 */   { ADDRESS , DIRECT, 
		"c4;[1=];" },
/* CPY 77 */   { ADDRESS , EXTENDED, 
		"cc;[1=]y" },
/* CPY 78 */   { 0 , 0, 
		"c0;[1=];" },
/* DEC 79 */   { INSTCMOS , INSTCMOS, 
		"3a;" },
/* DEC 80 */   { ADDRESS , DIRECT, 
		"c6;[1=];" },
/* DEC 81 */   { ADDRESS , EXTENDED, 
		"ce;[1=]y" },
/* DEC 82 */   { ADDRESS|INDEXMASK , DIRECT|INDEXX, 
		"d6;[1=];" },
/* DEC 83 */   { ADDRESS|INDEXMASK , EXTENDED|INDEXX, 
		"de;[1=]y" },
/* DEX 84 */   { 0 , 0, 
		"ca;" },
/* DEY 85 */   { 0 , 0, 
		"88;" },
/* EOR 86 */   { ADDRESS , DIRECT, 
		"45;[1=];" },
/* EOR 87 */   { ADDRESS , EXTENDED, 
		"4d;[1=]y" },
/* EOR 88 */   { 0 , 0, 
		"49;[1=];" },
/* EOR 89 */   { ADDRESS|INDEXMASK , DIRECT|INDEXX, 
		"55;[1=];" },
/* EOR 90 */   { ADDRESS|INDEXMASK , EXTENDED|INDEXX, 
		"5d;[1=]y" },
/* EOR 91 */   { INDEXMASK , INDEXY, 
		"59;[1=]y" },
/* EOR 92 */   { INSTCMOS|ADDRESS , DIRECT|INSTCMOS, 
		"52;[1=];" },
/* EOR 93 */   { ADDRESS|INDEXMASK , DIRECT|INDEXY, 
		"51;[1=];" },
/* EOR 94 */   { ADDRESS|INDEXMASK , DIRECT|INDEXX, 
		"41;[1=];" },
/* INC 95 */   { INSTCMOS , INSTCMOS, 
		"1a;" },
/* INC 96 */   { ADDRESS , DIRECT, 
		"e6;[1=];" },
/* INC 97 */   { ADDRESS , EXTENDED, 
		"ee;[1=]y" },
/* INC 98 */   { ADDRESS|INDEXMASK , DIRECT|INDEXX, 
		"f6;[1=];" },
/* INC 99 */   { ADDRESS|INDEXMASK , EXTENDED|INDEXX, 
		"fe;[1=]y" },
/* INX 100 */   { 0 , 0, 
		"e8;" },
/* INY 101 */   { 0 , 0, 
		"c8;" },
/* JMP 102 */   { 0 , 0, 
		"4c;[1=]y" },
/* JMP 103 */   { 0 , 0, 
		"6c;[1=]y" },
/* JMP 104 */   { INSTCMOS|INDEXMASK , INSTCMOS|INDEXX, 
		"7c;[1=]y" },
/* JSR 105 */   { 0 , 0, 
		"20;[1=]y" },
/* LDA 106 */   { ADDRESS , DIRECT, 
		"a5;[1=];" },
/* LDA 107 */   { ADDRESS , EXTENDED, 
		"ad;[1=]y" },
/* LDA 108 */   { 0 , 0, 
		"a9;[1=];" },
/* LDA 109 */   { ADDRESS|INDEXMASK , DIRECT|INDEXX, 
		"b5;[1=];" },
/* LDA 110 */   { ADDRESS|INDEXMASK , EXTENDED|INDEXX, 
		"bd;[1=]y" },
/* LDA 111 */   { INDEXMASK , INDEXY, 
		"b9;[1=]y" },
/* LDA 112 */   { INSTCMOS|ADDRESS , DIRECT|INSTCMOS, 
		"b2;[1=];" },
/* LDA 113 */   { ADDRESS|INDEXMASK , DIRECT|INDEXY, 
		"b1;[1=];" },
/* LDA 114 */   { ADDRESS|INDEXMASK , DIRECT|INDEXX, 
		"a1;[1=];" },
/* LDX 115 */   { ADDRESS , DIRECT, 
		"a6;[1=];" },
/* LDX 116 */   { ADDRESS , EXTENDED, 
		"ae;[1=]y" },
/* LDX 117 */   { 0 , 0, 
		"a2;[1=];" },
/* LDX 118 */   { ADDRESS|INDEXMASK , DIRECT|INDEXY, 
		"b6;[1=];" },
/* LDX 119 */   { ADDRESS|INDEXMASK , EXTENDED|INDEXY, 
		"be;[1=]y" },
/* LDY 120 */   { ADDRESS , DIRECT, 
		"a4;[1=];" },
/* LDY 121 */   { ADDRESS , EXTENDED, 
		"ac;[1=]y" },
/* LDY 122 */   { 0 , 0, 
		"a0;[1=];" },
/* LDY 123 */   { ADDRESS|INDEXMASK , DIRECT|INDEXX, 
		"b4;[1=];" },
/* LDY 124 */   { ADDRESS|INDEXMASK , EXTENDED|INDEXX, 
		"bc;[1=]y" },
/* LSR 125 */   { 0 , 0, 
		"4a;" },
/* LSR 126 */   { ADDRESS , DIRECT, 
		"46;[1=];" },
/* LSR 127 */   { ADDRESS , EXTENDED, 
		"4e;[1=]y" },
/* LSR 128 */   { ADDRESS|INDEXMASK , DIRECT|INDEXX, 
		"56;[1=];" },
/* LSR 129 */   { ADDRESS|INDEXMASK , EXTENDED|INDEXX, 
		"5e;[1=]y" },
/* MUL 130 */   { INST21 , INST21, 
		"02;" },
/* NOP 131 */   { 0 , 0, 
		"ea;" },
/* ORA 132 */   { ADDRESS , DIRECT, 
		"05;[1=];" },
/* ORA 133 */   { ADDRESS , EXTENDED, 
		"0d;[1=]y" },
/* ORA 134 */   { 0 , 0, 
		"09;[1=];" },
/* ORA 135 */   { ADDRESS|INDEXMASK , DIRECT|INDEXX, 
		"15;[1=];" },
/* ORA 136 */   { ADDRESS|INDEXMASK , EXTENDED|INDEXX, 
		"1d;[1=]y" },
/* ORA 137 */   { INDEXMASK , INDEXY, 
		"19;[1=]y" },
/* ORA 138 */   { INSTCMOS|ADDRESS , DIRECT|INSTCMOS, 
		"12;[1=];" },
/* ORA 139 */   { ADDRESS|INDEXMASK , DIRECT|INDEXY, 
		"11;[1=];" },
/* ORA 140 */   { ADDRESS|INDEXMASK , DIRECT|INDEXX, 
		"01;[1=];" },
/* PHA 141 */   { 0 , 0, 
		"48;" },
/* PHP 142 */   { 0 , 0, 
		"08;" },
/* PHX 143 */   { INSTCMOS , INSTCMOS, 
		"da;" },
/* PHX 144 */   { INST21 , INST21, 
		"da;" },
/* PHY 145 */   { INSTCMOS , INSTCMOS, 
		"5a;" },
/* PHY 146 */   { INST21 , INST21, 
		"5a;" },
/* PLA 147 */   { 0 , 0, 
		"68;" },
/* PLP 148 */   { 0 , 0, 
		"28;" },
/* PLX 149 */   { INSTCMOS , INSTCMOS, 
		"fa;" },
/* PLX 150 */   { INST21 , INST21, 
		"fa;" },
/* PLY 151 */   { INSTCMOS , INSTCMOS, 
		"7a;" },
/* PLY 152 */   { INST21 , INST21, 
		"7a;" },
/* RMB0 153 */   { INSTROCKWELL , INSTROCKWELL, 
		"07;[1=];" },
/* RMB1 154 */   { INSTROCKWELL , INSTROCKWELL, 
		"17;[1=];" },
/* RMB2 155 */   { INSTROCKWELL , INSTROCKWELL, 
		"27;[1=];" },
/* RMB3 156 */   { INSTROCKWELL , INSTROCKWELL, 
		"37;[1=];" },
/* RMB4 157 */   { INSTROCKWELL , INSTROCKWELL, 
		"47;[1=];" },
/* RMB5 158 */   { INSTROCKWELL , INSTROCKWELL, 
		"57;[1=];" },
/* RMB6 159 */   { INSTROCKWELL , INSTROCKWELL, 
		"67;[1=];" },
/* RMB7 160 */   { INSTROCKWELL , INSTROCKWELL, 
		"77;[1=];" },
/* ROL 161 */   { 0 , 0, 
		"2a;" },
/* ROL 162 */   { ADDRESS , DIRECT, 
		"26;[1=];" },
/* ROL 163 */   { ADDRESS , EXTENDED, 
		"2e;[1=]y" },
/* ROL 164 */   { ADDRESS|INDEXMASK , DIRECT|INDEXX, 
		"36;[1=];" },
/* ROL 165 */   { ADDRESS|INDEXMASK , EXTENDED|INDEXX, 
		"3e;[1=]y" },
/* ROR 166 */   { 0 , 0, 
		"6a;" },
/* ROR 167 */   { ADDRESS , DIRECT, 
		"66;[1=];" },
/* ROR 168 */   { ADDRESS , EXTENDED, 
		"6e;[1=]y" },
/* ROR 169 */   { ADDRESS|INDEXMASK , DIRECT|INDEXX, 
		"76;[1=];" },
/* ROR 170 */   { ADDRESS|INDEXMASK , EXTENDED|INDEXX, 
		"7e;[1=]y" },
/* RTI 171 */   { 0 , 0, 
		"40;" },
/* RTS 172 */   { 0 , 0, 
		"60;" },
/* SBC 173 */   { ADDRESS , DIRECT, 
		"e5;[1=];" },
/* SBC 174 */   { ADDRESS , EXTENDED, 
		"ed;[1=]y" },
/* SBC 175 */   { 0 , 0, 
		"e9;[1=];" },
/* SBC 176 */   { ADDRESS|INDEXMASK , DIRECT|INDEXX, 
		"f5;[1=];" },
/* SBC 177 */   { ADDRESS|INDEXMASK , EXTENDED|INDEXX, 
		"fd;[1=]y" },
/* SBC 178 */   { INDEXMASK , INDEXY, 
		"f9;[1=]y" },
/* SBC 179 */   { INSTCMOS|ADDRESS , DIRECT|INSTCMOS, 
		"f2;[1=];" },
/* SBC 180 */   { ADDRESS|INDEXMASK , DIRECT|INDEXY, 
		"f1;[1=];" },
/* SBC 181 */   { ADDRESS|INDEXMASK , DIRECT|INDEXX, 
		"e1;[1=];" },
/* SEC 182 */   { 0 , 0, 
		"38;" },
/* SED 183 */   { 0 , 0, 
		"f8;" },
/* SEI 184 */   { 0 , 0, 
		"78;" },
/* SMB0 185 */   { INSTROCKWELL , INSTROCKWELL, 
		"87;[1=];" },
/* SMB1 186 */   { INSTROCKWELL , INSTROCKWELL, 
		"97;[1=];" },
/* SMB2 187 */   { INSTROCKWELL , INSTROCKWELL, 
		"a7;[1=];" },
/* SMB3 188 */   { INSTROCKWELL , INSTROCKWELL, 
		"b7;[1=];" },
/* SMB4 189 */   { INSTROCKWELL , INSTROCKWELL, 
		"c7;[1=];" },
/* SMB5 190 */   { INSTROCKWELL , INSTROCKWELL, 
		"d7;[1=];" },
/* SMB6 191 */   { INSTROCKWELL , INSTROCKWELL, 
		"e7;[1=];" },
/* SMB7 192 */   { INSTROCKWELL , INSTROCKWELL, 
		"f7;[1=];" },
/* STA 193 */   { ADDRESS , DIRECT, 
		"85;[1=];" },
/* STA 194 */   { ADDRESS , EXTENDED, 
		"8d;[1=]y" },
/* STA 195 */   { ADDRESS|INDEXMASK , DIRECT|INDEXX, 
		"95;[1=];" },
/* STA 196 */   { ADDRESS|INDEXMASK , EXTENDED|INDEXX, 
		"9d;[1=]y" },
/* STA 197 */   { INDEXMASK , INDEXY, 
		"99;[1=]y" },
/* STA 198 */   { INSTCMOS|ADDRESS , DIRECT|INSTCMOS, 
		"92;[1=];" },
/* STA 199 */   { ADDRESS|INDEXMASK , DIRECT|INDEXY, 
		"91;[1=];" },
/* STA 200 */   { ADDRESS|INDEXMASK , DIRECT|INDEXX, 
		"81;[1=];" },
/* STX 201 */   { ADDRESS , DIRECT, 
		"86;[1=];" },
/* STX 202 */   { ADDRESS , EXTENDED, 
		"8e;[1=]y" },
/* STX 203 */   { ADDRESS|INDEXMASK , DIRECT|INDEXY, 
		"96;[1=];" },
/* STY 204 */   { ADDRESS , DIRECT, 
		"84;[1=];" },
/* STY 205 */   { ADDRESS , EXTENDED, 
		"8c;[1=]y" },
/* STY 206 */   { ADDRESS|INDEXMASK , DIRECT|INDEXX, 
		"94;[1=];" },
/* STZ 207 */   { ADDRESS|INSTCMOS , DIRECT|INSTCMOS, 
		"64;[1=];" },
/* STZ 208 */   { ADDRESS|INSTCMOS , EXTENDED|INSTCMOS, 
		"9c;[1=]y" },
/* STZ 209 */   { ADDRESS|INDEXMASK|INSTCMOS , DIRECT|INDEXX|INSTCMOS, 
		"74;[1=];" },
/* STZ 210 */   { ADDRESS|INDEXMASK|INSTCMOS , EXTENDED|INDEXX|INSTCMOS, 
		"9e;[1=]y" },
/* TAX 211 */   { 0 , 0, 
		"aa;" },
/* TAY 212 */   { 0 , 0, 
		"a8;" },
/* TRB 213 */   { ADDRESS|INSTCMOS , DIRECT|INSTCMOS, 
		"14;[1=];" },
/* TRB 214 */   { ADDRESS|INSTCMOS , EXTENDED|INSTCMOS, 
		"1c;[1=]y" },
/* TSB 215 */   { ADDRESS|INSTCMOS , DIRECT|INSTCMOS, 
		"04;[1=];" },
/* TSB 216 */   { ADDRESS|INSTCMOS , EXTENDED|INSTCMOS, 
		"0c;[1=]y" },
/* TSX 217 */   { 0 , 0, 
		"ba;" },
/* TXA 218 */   { 0 , 0, 
		"8a;" },
/* TXS 219 */   { 0 , 0, 
		"9a;" },
/* TYA 220 */   { 0 , 0, 
		"98;" },
	{ 0,0,""} };
/* end fraptabdef.c */
