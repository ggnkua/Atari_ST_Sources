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
FILENAME: 	as8051.y;
WARNINGS: 	"This software is in the public domain.  
		Any prior copyright claims are relinquished.  

		This software is distributed with no warranty whatever.  
		The author takes no responsibility for the consequences 
		of its use.

		Yacc (or Bison) required to compile."  ;
SEE-ALSO: 	as8051.doc,frasmain.c;	
AUTHORS: 	Mark Zenier;
COMPILERS: 	Microport Sys V/AT, ATT Yacc, Turbo C V1.5, Bison (CUG disk 285)
		(previous versions Xenix, Unisoft 68000 Version 7, Sun 3);
*/
/* 8051 structured generation file */
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

/*	0000.0000.0000.0xxx   register value */
#define REGVALMASK	0x7
/*	0xxx.xxxx.0000.0000	register and special select bits */
#define REGSEL_ALL	0x7f00
#define REG2NDSHFT	8
#define REGSEL_ACC	0x100
#define REGSEL_AB	0x200
#define REGSEL_C	0x400
#define REGSEL_DPTR	0x800
#define REGSEL_PC	0x1000
#define REGSEL_R01	0x2000
#define REGSEL_R07	0x4000
#define REG2SEL_ACC	0x1
#define REG2SEL_AB	0x2
#define REG2SEL_C	0x4
#define REG2SEL_DPTR	0x8
#define REG2SEL_PC	0x10
#define REG2SEL_R01	0x20
#define REG2SEL_R07	0x40
#define ST_INH 0x1
#define ST_UOP01 0x2
#define ST_UOP02 0x4
#define ST_UOP03 0x8
#define ST_UOP04 0x10
#define ST_UOP05 0x20
#define ST_ALU01 0x1
#define ST_ALU02 0x2
#define ST_ALU02E 0x4
#define ST_ALU03 0x8
#define ST_ALU04 0x10
#define ST_ALU05 0x20
#define ST_ALU06 0x40
#define ST_ALU07 0x80
#define ST_ALU08 0x100
#define ST_ALU09 0x200
#define ST_ALU10 0x400
#define ST_MOV01 0x1
#define ST_MOV02 0x2
#define ST_MOV03 0x4
#define ST_MOV04 0x8
#define ST_MOV05 0x10
#define ST_MOV06 0x20
#define ST_MOV07 0x40
#define ST_MOV08 0x80
#define ST_MOV09 0x100
#define ST_MOV10 0x200
#define ST_MOV11 0x400
#define ST_MOV12 0x800
#define ST_MOV13 0x1000
#define ST_MOV14 0x2000
#define ST_CJNE1 0x1
#define ST_CJNE2 0x2
#define ST_CJNE3 0x4
	
	static char	genbdef[] = "[1=];";
	static char	genwdef[] = "[1=]y"; /* x for normal, y for byte rev */
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
}

%token <intv> REG
%type <intv> bit
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
%token <intv> KOC_aluop
%token <intv> KOC_mov
%token <intv> KOC_cjne

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
		locctr += geninstr(findgen($1, ST_INH,  0));
			}
	;
genline : KOC_opcode  '@' REG
			{
		genlocrec(currseg, labelloc);
		evalr[1].value = ( $3 & REGVALMASK);
		locctr += geninstr(findgen($1, ST_UOP01,  ($3 & REGSEL_ALL)));
			}
	;
genline : KOC_opcode  REG
			{
		genlocrec(currseg, labelloc);
		evalr[1].value = ( $2 & REGVALMASK);
		locctr += geninstr(findgen($1, ST_UOP02,  ($2 & REGSEL_ALL)));
			}
	;
genline : KOC_opcode  bit
			{
		genlocrec(currseg, labelloc);
		evalr[1].value = $2;
		locctr += geninstr(findgen($1, ST_UOP03,  0));
			}
	;
genline : KOC_opcode  expr
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1,$2);
		locctr += geninstr(findgen($1, ST_UOP04,  0));
			}
	;
genline : KOC_opcode  '@' REG '+' REG
			{
		genlocrec(currseg, labelloc);
		locctr += geninstr(findgen($1, ST_UOP05, ($3 & REGSEL_ALL) 
			| (($5 & REGSEL_ALL) >> REG2NDSHFT) ));
			}
	;
genline : KOC_aluop  REG ',' '#' expr
			{
		genlocrec(currseg, labelloc);
		evalr[1].value = ( $2 & REGVALMASK);
		pevalexpr(2,$5);
		locctr += geninstr(findgen($1, ST_ALU01,  ($2 & REGSEL_ALL)));
			}
	;
genline : KOC_aluop  REG ',' '/' bit
			{
		genlocrec(currseg, labelloc);
		evalr[1].value = ( $2 & REGVALMASK);
		evalr[2].value = $5;
		locctr += geninstr(findgen($1, ST_ALU02,  ($2 & REGSEL_ALL)));
			}
	;
genline : KOC_aluop  REG ',' '/' expr
			{
		genlocrec(currseg, labelloc);
		evalr[1].value = ( $2 & REGVALMASK);
		pevalexpr(2,$5);
		locctr += geninstr(findgen($1, ST_ALU02E,  ($2 & REGSEL_ALL)));
			}
	;
genline : KOC_aluop  REG ',' '@' REG
			{
		genlocrec(currseg, labelloc);
		evalr[1].value = ( $2 & REGVALMASK);
		evalr[2].value = ( $5 & REGVALMASK);
		locctr += geninstr(findgen($1, ST_ALU03,  ($2 & REGSEL_ALL) 
			| (($5 & REGSEL_ALL) >> REG2NDSHFT)));
			}
	;
genline : KOC_aluop  REG ',' REG
			{
		genlocrec(currseg, labelloc);
		evalr[1].value = ( $2 & REGVALMASK);
		evalr[2].value = ( $4 & REGVALMASK);
		locctr += geninstr(findgen($1, ST_ALU04,  ($2 & REGSEL_ALL) 
			| (($4 & REGSEL_ALL) >> REG2NDSHFT)));
			}
	;
genline : KOC_aluop  REG ',' bit
			{
		genlocrec(currseg, labelloc);
		evalr[1].value = ( $2 & REGVALMASK);
		evalr[2].value = $4;
		locctr += geninstr(findgen($1, ST_ALU05,  ($2 & REGSEL_ALL)));
			}
	;
genline : KOC_aluop  REG ',' expr
			{
		genlocrec(currseg, labelloc);
		evalr[1].value = ( $2 & REGVALMASK);
		pevalexpr(2,$4);
		locctr += geninstr(findgen($1, ST_ALU06,  ($2 & REGSEL_ALL)));
			}
	;
genline : KOC_aluop  bit ',' expr
			{
		genlocrec(currseg, labelloc);
		evalr[1].value = $2;
		pevalexpr(2,$4);
		locctr += geninstr(findgen($1, ST_ALU07,  0));
			}
	;
genline : KOC_aluop  expr ',' '#' expr
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1,$2);
		pevalexpr(2,$5);
		locctr += geninstr(findgen($1, ST_ALU08,  0));
			}
	;
genline : KOC_aluop  expr ',' REG
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1,$2);
		evalr[2].value = ( $4 & REGVALMASK);
		locctr += geninstr(findgen($1, ST_ALU09,  ($4 & REGSEL_ALL)));
			}
	;
genline : KOC_aluop  expr ',' expr
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1,$2);
		pevalexpr(2,$4);
		locctr += geninstr(findgen($1, ST_ALU10,  0));
			}
	;
genline : KOC_mov  '@' REG ',' '#' expr
			{
		genlocrec(currseg, labelloc);
		evalr[1].value = ( $3 & REGVALMASK);
		pevalexpr(2,$6);
		locctr += geninstr(findgen($1, ST_MOV01,  ($3 & REGSEL_ALL)));
			}
	;
genline : KOC_mov  '@' REG ',' REG
			{
		genlocrec(currseg, labelloc);
		evalr[1].value = ( $3 & REGVALMASK);
		evalr[2].value = ( $5 & REGVALMASK);
		locctr += geninstr(findgen($1, ST_MOV02,  ($3 & REGSEL_ALL) 
			| (($5 & REGSEL_ALL) >> REG2NDSHFT)));
			}
	;
genline : KOC_mov  '@' REG ',' expr
			{
		genlocrec(currseg, labelloc);
		evalr[1].value = ( $3 & REGVALMASK);
		pevalexpr(2,$5);
		locctr += geninstr(findgen($1, ST_MOV03,  ($3 & REGSEL_ALL)));
			}
	;
genline : KOC_mov  REG ',' '#' expr
			{
		genlocrec(currseg, labelloc);
		evalr[1].value = ( $2 & REGVALMASK);
		pevalexpr(2,$5);
		locctr += geninstr(findgen($1, ST_MOV04,  ($2 & REGSEL_ALL)));
			}
	;
genline : KOC_mov  REG ',' '@' REG
			{
		genlocrec(currseg, labelloc);
		evalr[1].value = ( $2 & REGVALMASK);
		evalr[2].value = ( $5 & REGVALMASK);
		locctr += geninstr(findgen($1, ST_MOV05,  ($2 & REGSEL_ALL) 
			| (($5 & REGSEL_ALL) >> REG2NDSHFT)));
			}
	;
genline : KOC_mov  REG ',' '@' REG '+' REG
			{
		genlocrec(currseg, labelloc);
		locctr += geninstr(findgen($1, ST_MOV06,  (($2&$5) & REGSEL_ALL)
			| (($7 & REGSEL_ALL) >> REG2NDSHFT)));
			}
	;
genline : KOC_mov  REG ',' REG
			{
		genlocrec(currseg, labelloc);
		evalr[1].value = ( $2 & REGVALMASK);
		evalr[2].value = ( $4 & REGVALMASK);
		locctr += geninstr(findgen($1, ST_MOV07,  ($2 & REGSEL_ALL) 
			| (($4 & REGSEL_ALL) >> REG2NDSHFT)));
			}
	;
genline : KOC_mov  REG ',' bit
			{
		genlocrec(currseg, labelloc);
		evalr[1].value = ( $2 & REGVALMASK);
		evalr[2].value = $4;
		locctr += geninstr(findgen($1, ST_MOV08,  ($2 & REGSEL_ALL)));
			}
	;
genline : KOC_mov  REG ',' expr
			{
		genlocrec(currseg, labelloc);
		evalr[1].value = ( $2 & REGVALMASK);
		pevalexpr(2,$4);
		locctr += geninstr(findgen($1, ST_MOV09,  ($2 & REGSEL_ALL)));
			}
	;
genline : KOC_mov  bit ',' REG
			{
		genlocrec(currseg, labelloc);
		evalr[1].value = $2;
		evalr[2].value = ( $4 & REGVALMASK);
		locctr += geninstr(findgen($1, ST_MOV10,  ($4 & REGSEL_ALL)));
			}
	;
genline : KOC_mov  expr ',' '#' expr
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1,$2);
		pevalexpr(2,$5);
		locctr += geninstr(findgen($1, ST_MOV11,  0));
			}
	;
genline : KOC_mov  expr ',' '@' REG
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1,$2);
		evalr[2].value = ( $5 & REGVALMASK);
		locctr += geninstr(findgen($1, ST_MOV12,  ($5 & REGSEL_ALL)));
			}
	;
genline : KOC_mov  expr ',' REG
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1,$2);
		evalr[2].value = ($4 & REGVALMASK);
		locctr += geninstr(findgen($1, ST_MOV13,  ($4 & REGSEL_ALL)));
			}
	;
genline : KOC_mov  expr ',' expr
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1,$2);
		pevalexpr(2,$4);
		locctr += geninstr(findgen($1, ST_MOV14,  0));
			}
	;
genline : KOC_cjne  REG ',' expr ',' expr
			{
		genlocrec(currseg, labelloc);
		evalr[1].value = ( $2 & REGVALMASK);
		pevalexpr(2,$4);
		pevalexpr(3,$6);
		locctr += geninstr(findgen($1, ST_CJNE1,  ($2 & REGSEL_ALL)));
			}
	;
genline : KOC_cjne  REG ',' '#' expr ',' expr
			{
		genlocrec(currseg, labelloc);
		evalr[1].value = ( $2 & REGVALMASK);
		pevalexpr(2,$5);
		pevalexpr(3,$7);
		locctr += geninstr(findgen($1, ST_CJNE2,  ($2 & REGSEL_ALL)));
			}
	;
genline : KOC_cjne  '@' REG ',' '#' expr ',' expr
			{
		genlocrec(currseg, labelloc);
		evalr[1].value = ( $3 & REGVALMASK);
		pevalexpr(2,$6);
		pevalexpr(3,$8);
		locctr += geninstr(findgen($1, ST_CJNE3,  ($3 & REGSEL_ALL)));
			}
	;
bit	:	expr '.' CONSTANT
		{
			int	bitaddr;

			pevalexpr(0, $1);
			if(evalr[0].seg == SSG_ABS)
			{
				switch((int)(evalr[0].value))
				{
				case 0x20:
				case 0x21:
				case 0x22:
				case 0x23:
				case 0x24:
				case 0x25:
				case 0x26:
				case 0x27:
				case 0x28:
				case 0x29:
				case 0x2a:
				case 0x2b:
				case 0x2c:
				case 0x2d:
				case 0x2e:
				case 0x2f:
					bitaddr = (evalr[0].value - 0x20)
							<< 3;
					break;

				case 0x80:
				case 0x88:
				case 0x90:
				case 0x98:
				case 0xa0:
				case 0xa8:
				case 0xb0:
				case 0xb8:
				case 0xc0:
				case 0xc8:
				case 0xd0:
				case 0xd8:
				case 0xe0:
				case 0xe8:
				case 0xf0:
				case 0xf8:
					bitaddr = evalr[0].value;
					break;

				default:
					fraerror(
					"location is not bit addressable");
					evalr[0].value = 0;
					break;
				}
			}
			else
			{
				fraerror(
			"noncomputable expression in bit address");	
				evalr[0].value = 0;
			}
			
			if($3 < 0 || $3 > 7)
			{
				fraerror("bit number invalid");
			}

			$$ = bitaddr + $3;
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

	/* machine specific token definitions */
	reservedsym("a", REG, REGSEL_ACC);
	reservedsym("ab", REG, REGSEL_AB);
	reservedsym("c", REG, REGSEL_C);
	reservedsym("dptr", REG, REGSEL_DPTR);
	reservedsym("pc", REG, REGSEL_PC);
	reservedsym("r0", REG, REGSEL_R01|REGSEL_R07|0);
	reservedsym("r1", REG, REGSEL_R01|REGSEL_R07|1);
	reservedsym("r2", REG, REGSEL_R07|2);
	reservedsym("r3", REG, REGSEL_R07|3);
	reservedsym("r4", REG, REGSEL_R07|4);
	reservedsym("r5", REG, REGSEL_R07|5);
	reservedsym("r6", REG, REGSEL_R07|6);
	reservedsym("r7", REG, REGSEL_R07|7);

	reservedsym("A", REG, REGSEL_ACC);
	reservedsym("AB", REG, REGSEL_AB);
	reservedsym("C", REG, REGSEL_C);
	reservedsym("DPTR", REG, REGSEL_DPTR);
	reservedsym("PC", REG, REGSEL_PC);
	reservedsym("R0", REG, REGSEL_R01|REGSEL_R07|0);
	reservedsym("R1", REG, REGSEL_R01|REGSEL_R07|1);
	reservedsym("R2", REG, REGSEL_R07|2);
	reservedsym("R3", REG, REGSEL_R07|3);
	reservedsym("R4", REG, REGSEL_R07|4);
	reservedsym("R5", REG, REGSEL_R07|5);
	reservedsym("R6", REG, REGSEL_R07|6);
	reservedsym("R7", REG, REGSEL_R07|7);

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

#define NUMOPCODE 68
#define NUMSYNBLK 107
#define NUMDIFFOP 125

int gnumopcode = NUMOPCODE;

int ophashlnk[NUMOPCODE];

struct opsym optab[NUMOPCODE+1]
	= {
	{"invalid", KOC_opcode, 2, 0 },
	{"ACALL", KOC_opcode, 1, 2 },
	{"ADD", KOC_aluop, 4, 3 },
	{"ADDC", KOC_aluop, 4, 7 },
	{"AJMP", KOC_opcode, 1, 11 },
	{"ANL", KOC_aluop, 9, 12 },
	{"BYTE", KOC_BDEF, 0, 0 },
	{"CHARDEF", KOC_CHDEF, 0, 0 },
	{"CHARSET", KOC_CHSET, 0, 0 },
	{"CHARUSE", KOC_CHUSE, 0, 0 },
	{"CHD", KOC_CHDEF, 0, 0 },
	{"CJNE", KOC_cjne, 3, 21 },
	{"CLR", KOC_opcode, 3, 24 },
	{"CPL", KOC_opcode, 3, 27 },
	{"DA", KOC_opcode, 1, 30 },
	{"DB", KOC_BDEF, 0, 0 },
	{"DEC", KOC_opcode, 3, 31 },
	{"DIV", KOC_opcode, 1, 34 },
	{"DJNZ", KOC_aluop, 2, 35 },
	{"DW", KOC_WDEF, 0, 0 },
	{"ELSE", KOC_ELSE, 0, 0 },
	{"END", KOC_END, 0, 0 },
	{"ENDI", KOC_ENDI, 0, 0 },
	{"EQU", KOC_EQU, 0, 0 },
	{"FCB", KOC_BDEF, 0, 0 },
	{"FCC", KOC_SDEF, 0, 0 },
	{"FDB", KOC_WDEF, 0, 0 },
	{"IF", KOC_IF, 0, 0 },
	{"INC", KOC_opcode, 3, 37 },
	{"INCL", KOC_INCLUDE, 0, 0 },
	{"INCLUDE", KOC_INCLUDE, 0, 0 },
	{"JB", KOC_aluop, 2, 40 },
	{"JBC", KOC_aluop, 2, 42 },
	{"JC", KOC_opcode, 1, 44 },
	{"JMP", KOC_opcode, 1, 45 },
	{"JNB", KOC_aluop, 2, 46 },
	{"JNC", KOC_opcode, 1, 48 },
	{"JNZ", KOC_opcode, 1, 49 },
	{"JZ", KOC_opcode, 1, 50 },
	{"LCALL", KOC_opcode, 1, 51 },
	{"LJMP", KOC_opcode, 1, 52 },
	{"MOV", KOC_mov, 13, 53 },
	{"MOVC", KOC_mov, 1, 66 },
	{"MOVX", KOC_mov, 2, 67 },
	{"MUL", KOC_opcode, 1, 69 },
	{"NOP", KOC_opcode, 1, 70 },
	{"ORG", KOC_ORG, 0, 0 },
	{"ORL", KOC_aluop, 9, 71 },
	{"POP", KOC_opcode, 1, 80 },
	{"PUSH", KOC_opcode, 1, 81 },
	{"RESERVE", KOC_RESM, 0, 0 },
	{"RET", KOC_opcode, 1, 82 },
	{"RETI", KOC_opcode, 1, 83 },
	{"RL", KOC_opcode, 1, 84 },
	{"RLC", KOC_opcode, 1, 85 },
	{"RMB", KOC_RESM, 0, 0 },
	{"RR", KOC_opcode, 1, 86 },
	{"RRC", KOC_opcode, 1, 87 },
	{"SET", KOC_SET, 0, 0 },
	{"SETB", KOC_opcode, 3, 88 },
	{"SJMP", KOC_opcode, 1, 91 },
	{"STRING", KOC_SDEF, 0, 0 },
	{"SUBB", KOC_aluop, 4, 92 },
	{"SWAP", KOC_opcode, 1, 96 },
	{"WORD", KOC_WDEF, 0, 0 },
	{"XCH", KOC_aluop, 3, 97 },
	{"XCHD", KOC_aluop, 1, 100 },
	{"XRL", KOC_aluop, 6, 101 },
	{ "", 0, 0, 0 }};

struct opsynt ostab[NUMSYNBLK+1]
	= {
/* invalid 0 */ { 0, 1, 0 },
/* invalid 1 */ { 0xffff, 1, 1 },
/* ACALL 2 */ { ST_UOP04, 1, 2 },
/* ADD 3 */ { ST_ALU01, 1, 3 },
/* ADD 4 */ { ST_ALU03, 1, 4 },
/* ADD 5 */ { ST_ALU04, 1, 5 },
/* ADD 6 */ { ST_ALU06, 1, 6 },
/* ADDC 7 */ { ST_ALU01, 1, 7 },
/* ADDC 8 */ { ST_ALU03, 1, 8 },
/* ADDC 9 */ { ST_ALU04, 1, 9 },
/* ADDC 10 */ { ST_ALU06, 1, 10 },
/* AJMP 11 */ { ST_UOP04, 1, 11 },
/* ANL 12 */ { ST_ALU01, 1, 12 },
/* ANL 13 */ { ST_ALU02, 1, 13 },
/* ANL 14 */ { ST_ALU02E, 1, 14 },
/* ANL 15 */ { ST_ALU03, 1, 15 },
/* ANL 16 */ { ST_ALU04, 1, 16 },
/* ANL 17 */ { ST_ALU05, 1, 17 },
/* ANL 18 */ { ST_ALU06, 2, 18 },
/* ANL 19 */ { ST_ALU08, 1, 20 },
/* ANL 20 */ { ST_ALU09, 1, 21 },
/* CJNE 21 */ { ST_CJNE1, 1, 22 },
/* CJNE 22 */ { ST_CJNE2, 2, 23 },
/* CJNE 23 */ { ST_CJNE3, 1, 25 },
/* CLR 24 */ { ST_UOP02, 2, 26 },
/* CLR 25 */ { ST_UOP03, 1, 28 },
/* CLR 26 */ { ST_UOP04, 1, 29 },
/* CPL 27 */ { ST_UOP02, 2, 30 },
/* CPL 28 */ { ST_UOP03, 1, 32 },
/* CPL 29 */ { ST_UOP04, 1, 33 },
/* DA 30 */ { ST_UOP02, 1, 34 },
/* DEC 31 */ { ST_UOP01, 1, 35 },
/* DEC 32 */ { ST_UOP02, 2, 36 },
/* DEC 33 */ { ST_UOP04, 1, 38 },
/* DIV 34 */ { ST_UOP02, 1, 39 },
/* DJNZ 35 */ { ST_ALU06, 1, 40 },
/* DJNZ 36 */ { ST_ALU10, 1, 41 },
/* INC 37 */ { ST_UOP01, 1, 42 },
/* INC 38 */ { ST_UOP02, 3, 43 },
/* INC 39 */ { ST_UOP04, 1, 46 },
/* JB 40 */ { ST_ALU07, 1, 47 },
/* JB 41 */ { ST_ALU10, 1, 48 },
/* JBC 42 */ { ST_ALU07, 1, 49 },
/* JBC 43 */ { ST_ALU10, 1, 50 },
/* JC 44 */ { ST_UOP04, 1, 51 },
/* JMP 45 */ { ST_UOP05, 1, 52 },
/* JNB 46 */ { ST_ALU07, 1, 53 },
/* JNB 47 */ { ST_ALU10, 1, 54 },
/* JNC 48 */ { ST_UOP04, 1, 55 },
/* JNZ 49 */ { ST_UOP04, 1, 56 },
/* JZ 50 */ { ST_UOP04, 1, 57 },
/* LCALL 51 */ { ST_UOP04, 1, 58 },
/* LJMP 52 */ { ST_UOP04, 1, 59 },
/* MOV 53 */ { ST_MOV01, 1, 60 },
/* MOV 54 */ { ST_MOV02, 1, 61 },
/* MOV 55 */ { ST_MOV03, 1, 62 },
/* MOV 56 */ { ST_MOV04, 3, 63 },
/* MOV 57 */ { ST_MOV05, 1, 66 },
/* MOV 58 */ { ST_MOV07, 2, 67 },
/* MOV 59 */ { ST_MOV08, 1, 69 },
/* MOV 60 */ { ST_MOV09, 3, 70 },
/* MOV 61 */ { ST_MOV10, 1, 73 },
/* MOV 62 */ { ST_MOV11, 1, 74 },
/* MOV 63 */ { ST_MOV12, 1, 75 },
/* MOV 64 */ { ST_MOV13, 3, 76 },
/* MOV 65 */ { ST_MOV14, 1, 79 },
/* MOVC 66 */ { ST_MOV06, 2, 80 },
/* MOVX 67 */ { ST_MOV02, 2, 82 },
/* MOVX 68 */ { ST_MOV05, 2, 84 },
/* MUL 69 */ { ST_UOP02, 1, 86 },
/* NOP 70 */ { ST_INH, 1, 87 },
/* ORL 71 */ { ST_ALU01, 1, 88 },
/* ORL 72 */ { ST_ALU02, 1, 89 },
/* ORL 73 */ { ST_ALU02E, 1, 90 },
/* ORL 74 */ { ST_ALU03, 1, 91 },
/* ORL 75 */ { ST_ALU04, 1, 92 },
/* ORL 76 */ { ST_ALU05, 1, 93 },
/* ORL 77 */ { ST_ALU06, 2, 94 },
/* ORL 78 */ { ST_ALU08, 1, 96 },
/* ORL 79 */ { ST_ALU09, 1, 97 },
/* POP 80 */ { ST_UOP04, 1, 98 },
/* PUSH 81 */ { ST_UOP04, 1, 99 },
/* RET 82 */ { ST_INH, 1, 100 },
/* RETI 83 */ { ST_INH, 1, 101 },
/* RL 84 */ { ST_UOP02, 1, 102 },
/* RLC 85 */ { ST_UOP02, 1, 103 },
/* RR 86 */ { ST_UOP02, 1, 104 },
/* RRC 87 */ { ST_UOP02, 1, 105 },
/* SETB 88 */ { ST_UOP02, 1, 106 },
/* SETB 89 */ { ST_UOP03, 1, 107 },
/* SETB 90 */ { ST_UOP04, 1, 108 },
/* SJMP 91 */ { ST_UOP04, 1, 109 },
/* SUBB 92 */ { ST_ALU01, 1, 110 },
/* SUBB 93 */ { ST_ALU03, 1, 111 },
/* SUBB 94 */ { ST_ALU04, 1, 112 },
/* SUBB 95 */ { ST_ALU06, 1, 113 },
/* SWAP 96 */ { ST_UOP02, 1, 114 },
/* XCH 97 */ { ST_ALU03, 1, 115 },
/* XCH 98 */ { ST_ALU04, 1, 116 },
/* XCH 99 */ { ST_ALU06, 1, 117 },
/* XCHD 100 */ { ST_ALU03, 1, 118 },
/* XRL 101 */ { ST_ALU01, 1, 119 },
/* XRL 102 */ { ST_ALU03, 1, 120 },
/* XRL 103 */ { ST_ALU04, 1, 121 },
/* XRL 104 */ { ST_ALU06, 1, 122 },
/* XRL 105 */ { ST_ALU08, 1, 123 },
/* XRL 106 */ { ST_ALU09, 1, 124 },
	{ 0, 0, 0 } };

struct igel igtab[NUMDIFFOP+1]
	= {
/* invalid 0 */   { 0 , 0, 
		"[Xnullentry" },
/* invalid 1 */   { 0 , 0, 
		"[Xinvalid opcode" },
/* ACALL 2 */   { 0 , 0, 
		"[1=].Q.2+.f800&-.bI~.3}.e0&.11|;!.ff&;" },
/* ADD 3 */   { REGSEL_ACC , REGSEL_ACC, 
		"24;[2=];" },
/* ADD 4 */   { REGSEL_ACC|REG2SEL_R01 , REGSEL_ACC|REG2SEL_R01, 
		"26.[2#]|;" },
/* ADD 5 */   { REGSEL_ACC|REG2SEL_R07 , REGSEL_ACC|REG2SEL_R07, 
		"28.[2#]|;" },
/* ADD 6 */   { REGSEL_ACC , REGSEL_ACC, 
		"25;[2=].8I;" },
/* ADDC 7 */   { REGSEL_ACC , REGSEL_ACC, 
		"34;[2=];" },
/* ADDC 8 */   { REGSEL_ACC|REG2SEL_R01 , REGSEL_ACC|REG2SEL_R01, 
		"36.[2#]|;" },
/* ADDC 9 */   { REGSEL_ACC|REG2SEL_R07 , REGSEL_ACC|REG2SEL_R07, 
		"38.[2#]|;" },
/* ADDC 10 */   { REGSEL_ACC , REGSEL_ACC, 
		"35;[2=].8I;" },
/* AJMP 11 */   { 0 , 0, 
		"[1=].Q.2+.f800&-.bI~.3}.e0&.01|;!.ff&;" },
/* ANL 12 */   { REGSEL_ACC , REGSEL_ACC, 
		"54;[2=];" },
/* ANL 13 */   { REGSEL_C , REGSEL_C, 
		"b0;[2#];" },
/* ANL 14 */   { REGSEL_C , REGSEL_C, 
		"b0;[2=].8I;" },
/* ANL 15 */   { REGSEL_ACC|REG2SEL_R01 , REGSEL_ACC|REG2SEL_R01, 
		"56.[2#]|;" },
/* ANL 16 */   { REGSEL_ACC|REG2SEL_R07 , REGSEL_ACC|REG2SEL_R07, 
		"58.[2#]|;" },
/* ANL 17 */   { REGSEL_C , REGSEL_C, 
		"82;[2#];" },
/* ANL 18 */   { REGSEL_ACC , REGSEL_ACC, 
		"55;[2=].8I;" },
/* ANL 19 */   { REGSEL_C , REGSEL_C, 
		"82;[2=].8I;" },
/* ANL 20 */   { 0 , 0, 
		"53;[1=].8I;[2=];" },
/* ANL 21 */   { REGSEL_ACC , REGSEL_ACC, 
		"52;[1=].8I;" },
/* CJNE 22 */   { REGSEL_ACC , REGSEL_ACC, 
		"b5;[2=].8I;[3=].Q.1+-r" },
/* CJNE 23 */   { REGSEL_ACC , REGSEL_ACC, 
		"b4;[2=];[3=].Q.1+-r" },
/* CJNE 24 */   { REGSEL_R07 , REGSEL_R07, 
		"b8.[1#]|;[2=];[3=].Q.1+-r" },
/* CJNE 25 */   { REGSEL_R01 , REGSEL_R01, 
		"b6.[1#]|;[2=];[3=].Q.1+-r" },
/* CLR 26 */   { REGSEL_ACC , REGSEL_ACC, 
		"e4;" },
/* CLR 27 */   { REGSEL_C , REGSEL_C, 
		"c3;" },
/* CLR 28 */   { 0 , 0, 
		"c2;[1#];" },
/* CLR 29 */   { 0 , 0, 
		"c2;[1=].8I;" },
/* CPL 30 */   { REGSEL_ACC , REGSEL_ACC, 
		"f4;" },
/* CPL 31 */   { REGSEL_C , REGSEL_C, 
		"b3;" },
/* CPL 32 */   { 0 , 0, 
		"b2;[1#];" },
/* CPL 33 */   { 0 , 0, 
		"b2;[1=].8I;" },
/* DA 34 */   { REGSEL_ACC , REGSEL_ACC, 
		"d4;" },
/* DEC 35 */   { REGSEL_R01 , REGSEL_R01, 
		"16.[1#]|;" },
/* DEC 36 */   { REGSEL_ACC , REGSEL_ACC, 
		"14;" },
/* DEC 37 */   { REGSEL_R07 , REGSEL_R07, 
		"18.[1#]|;" },
/* DEC 38 */   { 0 , 0, 
		"15;[1=].8I;" },
/* DIV 39 */   { REGSEL_AB , REGSEL_AB, 
		"84;" },
/* DJNZ 40 */   { REGSEL_R07 , REGSEL_R07, 
		"d8.[1#]|;[2=].Q.1+-r" },
/* DJNZ 41 */   { 0 , 0, 
		"d5;[1=].8I;[2=].Q.1+-r" },
/* INC 42 */   { REGSEL_R01 , REGSEL_R01, 
		"06.[1#]|;" },
/* INC 43 */   { REGSEL_ACC , REGSEL_ACC, 
		"04;" },
/* INC 44 */   { REGSEL_R07 , REGSEL_R07, 
		"08.[1#]|;" },
/* INC 45 */   { REGSEL_DPTR , REGSEL_DPTR, 
		"a3;" },
/* INC 46 */   { 0 , 0, 
		"05;[1=].8I;" },
/* JB 47 */   { 0 , 0, 
		"20;[1#];[2=].Q.1+-r" },
/* JB 48 */   { 0 , 0, 
		"20;[1=].8I;[2=].Q.1+-r" },
/* JBC 49 */   { 0 , 0, 
		"10;[1#];[2=].Q.1+-r" },
/* JBC 50 */   { 0 , 0, 
		"10;[1=].8I;[2=].Q.1+-r" },
/* JC 51 */   { 0 , 0, 
		"40;[1=].Q.1+-r" },
/* JMP 52 */   { REGSEL_ACC|REG2SEL_DPTR , REGSEL_ACC|REG2SEL_DPTR, 
		"73;" },
/* JNB 53 */   { 0 , 0, 
		"30;[1#];[2=].Q.1+-r" },
/* JNB 54 */   { 0 , 0, 
		"30;[1=].8I;[2=].Q.1+-r" },
/* JNC 55 */   { 0 , 0, 
		"50;[1=].Q.1+-r" },
/* JNZ 56 */   { 0 , 0, 
		"70;[1=].Q.1+-r" },
/* JZ 57 */   { 0 , 0, 
		"60;[1=].Q.1+-r" },
/* LCALL 58 */   { 0 , 0, 
		"12;[1=]x" },
/* LJMP 59 */   { 0 , 0, 
		"02;[1=]x" },
/* MOV 60 */   { REGSEL_R01 , REGSEL_R01, 
		"76.[1#]|;[2=];" },
/* MOV 61 */   { REGSEL_R01|REG2SEL_ACC , REGSEL_R01|REG2SEL_ACC, 
		"f6.[1#]|;" },
/* MOV 62 */   { REGSEL_R01 , REGSEL_R01, 
		"a6.[1#]|;[2=].8I;" },
/* MOV 63 */   { REGSEL_ACC , REGSEL_ACC, 
		"74;[2=];" },
/* MOV 64 */   { REGSEL_DPTR , REGSEL_DPTR, 
		"90;[2=]x" },
/* MOV 65 */   { REGSEL_R07 , REGSEL_R07, 
		"78.[1#]|;[2=];" },
/* MOV 66 */   { REGSEL_ACC|REG2SEL_R01 , REGSEL_ACC|REG2SEL_R01, 
		"e6.[2#]|;" },
/* MOV 67 */   { REGSEL_ACC|REG2SEL_R07 , REGSEL_ACC|REG2SEL_R07, 
		"e8.[2#]|;" },
/* MOV 68 */   { REGSEL_R07|REG2SEL_ACC , REGSEL_R07|REG2SEL_ACC, 
		"f8.[1#]|;" },
/* MOV 69 */   { REGSEL_C , REGSEL_C, 
		"a2;[2#];" },
/* MOV 70 */   { REGSEL_ACC , REGSEL_ACC, 
		"e5;[2=].8I;" },
/* MOV 71 */   { REGSEL_C , REGSEL_C, 
		"a2;[2=].8I;" },
/* MOV 72 */   { REGSEL_R07 , REGSEL_R07, 
		"a8.[1#]|;[2=].8I;" },
/* MOV 73 */   { REGSEL_C , REGSEL_C, 
		"92;[1#];" },
/* MOV 74 */   { 0 , 0, 
		"75;[1=].8I;[2=];" },
/* MOV 75 */   { REGSEL_R01 , REGSEL_R01, 
		"86.[2#]|;[1=].8I;" },
/* MOV 76 */   { REGSEL_ACC , REGSEL_ACC, 
		"f5;[1=].8I;" },
/* MOV 77 */   { REGSEL_C , REGSEL_C, 
		"92;[1=].8I;" },
/* MOV 78 */   { REGSEL_R07 , REGSEL_R07, 
		"88.[2#]|;[1=].8I;" },
/* MOV 79 */   { 0 , 0, 
		"85;[2=].8I;[1=].8I;" },
/* MOVC 80 */   { REGSEL_ACC|REG2SEL_DPTR , REGSEL_ACC|REG2SEL_DPTR, 
		"93;" },
/* MOVC 81 */   { REGSEL_ACC|REG2SEL_PC , REGSEL_ACC|REG2SEL_PC, 
		"83;" },
/* MOVX 82 */   { REGSEL_DPTR|REG2SEL_ACC , REGSEL_DPTR|REG2SEL_ACC, 
		"f0;" },
/* MOVX 83 */   { REGSEL_R01|REG2SEL_ACC , REGSEL_R01|REG2SEL_ACC, 
		"f2.[1#]|;" },
/* MOVX 84 */   { REGSEL_ACC|REG2SEL_DPTR , REGSEL_ACC|REG2SEL_DPTR, 
		"e0;" },
/* MOVX 85 */   { REGSEL_ACC|REG2SEL_R01 , REGSEL_ACC|REG2SEL_R01, 
		"e2.[2#]|;" },
/* MUL 86 */   { REGSEL_AB , REGSEL_AB, 
		"a4;" },
/* NOP 87 */   { 0 , 0, 
		"00;" },
/* ORL 88 */   { REGSEL_ACC , REGSEL_ACC, 
		"44;[2=];" },
/* ORL 89 */   { REGSEL_C , REGSEL_C, 
		"a0;[2#];" },
/* ORL 90 */   { REGSEL_C , REGSEL_C, 
		"a0;[2=].8I;" },
/* ORL 91 */   { REGSEL_ACC|REG2SEL_R01 , REGSEL_ACC|REG2SEL_R01, 
		"46.[2#]|;" },
/* ORL 92 */   { REGSEL_ACC|REG2SEL_R07 , REGSEL_ACC|REG2SEL_R07, 
		"48.[2#]|;" },
/* ORL 93 */   { REGSEL_C , REGSEL_C, 
		"72;[2#];" },
/* ORL 94 */   { REGSEL_ACC , REGSEL_ACC, 
		"45;[2=].8I;" },
/* ORL 95 */   { REGSEL_C , REGSEL_C, 
		"72;[2=].8I;" },
/* ORL 96 */   { 0 , 0, 
		"43;[1=].8I;[2=];" },
/* ORL 97 */   { REGSEL_ACC , REGSEL_ACC, 
		"42;[1=].8I;" },
/* POP 98 */   { 0 , 0, 
		"d0;[1=].8I;" },
/* PUSH 99 */   { 0 , 0, 
		"c0;[1=].8I;" },
/* RET 100 */   { 0 , 0, 
		"22;" },
/* RETI 101 */   { 0 , 0, 
		"32;" },
/* RL 102 */   { REGSEL_ACC , REGSEL_ACC, 
		"23;" },
/* RLC 103 */   { REGSEL_ACC , REGSEL_ACC, 
		"33;" },
/* RR 104 */   { REGSEL_ACC , REGSEL_ACC, 
		"03;" },
/* RRC 105 */   { REGSEL_ACC , REGSEL_ACC, 
		"13;" },
/* SETB 106 */   { REGSEL_C , REGSEL_C, 
		"d3;" },
/* SETB 107 */   { 0 , 0, 
		"d2;[1#];" },
/* SETB 108 */   { 0 , 0, 
		"d2;[1=].8I;" },
/* SJMP 109 */   { 0 , 0, 
		"80;[1=].Q.1+-r" },
/* SUBB 110 */   { REGSEL_ACC , REGSEL_ACC, 
		"94;[2=];" },
/* SUBB 111 */   { REGSEL_ACC|REG2SEL_R01 , REGSEL_ACC|REG2SEL_R01, 
		"96.[2#]|;" },
/* SUBB 112 */   { REGSEL_ACC|REG2SEL_R07 , REGSEL_ACC|REG2SEL_R07, 
		"98.[2#]|;" },
/* SUBB 113 */   { REGSEL_ACC , REGSEL_ACC, 
		"95;[2=].8I;" },
/* SWAP 114 */   { REGSEL_ACC , REGSEL_ACC, 
		"c4;" },
/* XCH 115 */   { REGSEL_ACC|REG2SEL_R01 , REGSEL_ACC|REG2SEL_R01, 
		"c6.[2#]|;" },
/* XCH 116 */   { REGSEL_ACC|REG2SEL_R07 , REGSEL_ACC|REG2SEL_R07, 
		"c8.[2#]|;" },
/* XCH 117 */   { REGSEL_ACC , REGSEL_ACC, 
		"c5;[2=].8I;" },
/* XCHD 118 */   { REGSEL_ACC|REG2SEL_R01 , REGSEL_ACC|REG2SEL_R01, 
		"d6.[2#]|;" },
/* XRL 119 */   { REGSEL_ACC , REGSEL_ACC, 
		"64;[2=];" },
/* XRL 120 */   { REGSEL_ACC|REG2SEL_R01 , REGSEL_ACC|REG2SEL_R01, 
		"66.[2#]|;" },
/* XRL 121 */   { REGSEL_ACC|REG2SEL_R07 , REGSEL_ACC|REG2SEL_R07, 
		"68.[2#]|;" },
/* XRL 122 */   { REGSEL_ACC , REGSEL_ACC, 
		"65;[2=].8I;" },
/* XRL 123 */   { 0 , 0, 
		"63;[1=].8I;[2=];" },
/* XRL 124 */   { REGSEL_ACC , REGSEL_ACC, 
		"62;[1=].8I;" },
	{ 0,0,""} };
/* end fraptabdef.c */
