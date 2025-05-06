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
FILENAME: 	as8096.y;
WARNINGS: 	"This software is in the public domain.  
		Any prior copyright claims are relinquished.  

		This software is distributed with no warranty whatever.  
		The author takes no responsibility for the consequences 
		of its use.

		Yacc (or Bison) required to compile."  ;
SEE-ALSO: 	as8096.doc,frasmain.c;	
AUTHORS: 	Mark Zenier;
COMPILERS: 	Microport Sys V/AT, ATT Yacc, Turbo C V1.5, Bison (CUG disk 285)
		(previous versions Xenix, Unisoft 68000 Version 7, Sun 3);
*/
/* 8096 instruction generation file */
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

/*	0000.0000.0000.00xx	short/long index selection */
#define	ADDR		0x3
#define	DIRECT		0x1
#define	EXTENDED	0x2
/*	0000.0000.0000.x000	80196 select */
#define	CPU196		0x8
#define	CPU96		0
#define ST_INH 0x1
#define ST_DIR1 0x2
#define ST_DIR2 0x4
#define ST_DIR3 0x8
#define ST_IMM1 0x10
#define ST_IMM2 0x20
#define ST_IMM3 0x40
#define ST_IND1 0x80
#define ST_INC1 0x100
#define ST_IND2 0x200
#define ST_INC2 0x400
#define ST_IND3 0x800
#define ST_INC3 0x1000
#define ST_INX1 0x2000
#define ST_INX2 0x4000
#define ST_INX3 0x8000
	
	int	cpuselect = CPU196;
	static char	genbdef[] = "[1=];";
	static char	genwdef[] = "[1=]y"; /* x for normal, y for byte rev */
	char ignosyn[] = "[Xinvalid syntax for instruction";
	char ignosel[] = "[Xinvalid operands/illegal instruction for cpu";
/*	constants for increment bit in indirect operand */
#define	AUTOINC		1
#define	NOINC		0

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

%token <intv> KOC_WDEF
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
%token <intv> KOC_CHSET
%token <intv> KOC_CHDEF
%token <intv> KOC_CHUSE
%token <intv> KOC_AWRESM
%token <intv> KOC_ALRESM
%token <intv> KOC_ALDEF
%token <intv> KOC_AWDEF
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


genline :	KOC_AWRESM expr 
			{
				while(labelloc & 1)
				{
					labelloc += 1;
				}

				pevalexpr(0, $2);
				if(evalr[0].seg == SSG_ABS)
				{
					locctr = labelloc + (2*evalr[0].value);
					prtequvalue("C: 0x%lx\n", labelloc);
				}
				else
				{
					fraerror(
				 "noncomputable result for RMB expression");
				}
			}
	;
genline :	KOC_ALRESM expr 
			{
				while(labelloc & 3)
				{
					labelloc += 1;
				}

				pevalexpr(0, $2);
				if(evalr[0].seg == SSG_ABS)
				{
					locctr = labelloc + (4*evalr[0].value);
					prtequvalue("C: 0x%lx\n", labelloc);
				}
				else
				{
					fraerror(
				 "noncomputable result for RMB expression");
				}
			}
	;
genline :	KOC_ALDEF exprlist 
			{
				while(labelloc & 3)
				{
					labelloc = (locctr += 1);
				}

				genlocrec(currseg, labelloc);
				for( satsub = 0; satsub < $2; satsub++)
				{
					pevalexpr(1, exprlist[satsub]);
					locctr += geninstr(
						"[1=]~.ffff&y!.10}y");
				}
			}	
	;
genline :	KOC_AWDEF exprlist 
			{
				if(labelloc & 1)
				{
					labelloc = (locctr += 1);
				}

				genlocrec(currseg, labelloc);
				for( satsub = 0; satsub < $2; satsub++)
				{
					pevalexpr(1, exprlist[satsub]);
					locctr += geninstr(genwdef);
				}
			}	
	;
line	:	KOC_CPU STRING
			{
		if( ! cpumatch($2))
		{
			fraerror("unknown cpu type, 80196 assumed");
			cpuselect = CPU196;
		}
			}
	;
genline : KOC_opcode 
			{
		genlocrec(currseg, labelloc);
		locctr += geninstr(findgen($1, ST_INH, cpuselect));
			}
	;
genline : KOC_opcode  expr
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1,$2);
		locctr += geninstr(findgen($1, ST_DIR1, cpuselect
				 + ( (evalr[1].seg == SSG_ABS 
				&& evalr[1].value >= 0
				&& evalr[1].value <= 255 )
				? DIRECT : EXTENDED ) ) );
			}
	;
genline : KOC_opcode  expr ',' expr
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1,$2);
		pevalexpr(2,$4);
		locctr += geninstr(findgen($1, ST_DIR2, cpuselect
				 + ( (evalr[2].seg == SSG_ABS 
				&& evalr[2].value >= 0
				&& evalr[2].value <= 255 )
				? DIRECT : EXTENDED ) ) );
			}
	;
genline : KOC_opcode  expr ',' expr ',' expr
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1,$2);
		pevalexpr(2,$4);
		pevalexpr(3,$6);
		locctr += geninstr(findgen($1, ST_DIR3, cpuselect
				 + ( (evalr[3].seg == SSG_ABS 
				&& evalr[3].value >= 0
				&& evalr[3].value <= 255 )
				? DIRECT : EXTENDED ) ) );
			}
	;
genline : KOC_opcode  '#' expr
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1,$3);
		locctr += geninstr(findgen($1, ST_IMM1, cpuselect));
			}
	;
genline : KOC_opcode  expr ',' '#' expr
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1,$2);
		pevalexpr(2,$5);
		locctr += geninstr(findgen($1, ST_IMM2, cpuselect));
			}
	;
genline : KOC_opcode  expr ',' expr ',' '#' expr
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1,$2);
		pevalexpr(2,$4);
		pevalexpr(3,$7);
		locctr += geninstr(findgen($1, ST_IMM3, cpuselect));
			}
	;
genline : KOC_opcode  '[' expr ']'
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1,$3);
		evalr[2].value = NOINC;
		locctr += geninstr(findgen($1, ST_IND1, cpuselect));
			}
	;
genline : KOC_opcode  '[' expr ']' '+'
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1,$3);
		evalr[2].value = AUTOINC;
		locctr += geninstr(findgen($1, ST_IND1, cpuselect));
			}
	;
genline : KOC_opcode  expr ',' '[' expr ']'
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1,$2);
		pevalexpr(2,$5);
		evalr[3].value = NOINC;
		locctr += geninstr(findgen($1, ST_IND2, cpuselect));
			}
	;
genline : KOC_opcode  expr ',' '[' expr ']' '+'
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1,$2);
		pevalexpr(2,$5);
		evalr[3].value = AUTOINC;
		locctr += geninstr(findgen($1, ST_IND2, cpuselect));
			}
	;
genline : KOC_opcode  expr ',' expr ',' '[' expr ']'
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1,$2);
		pevalexpr(2,$4);
		pevalexpr(3,$7);
		evalr[4].value = NOINC;
		locctr += geninstr(findgen($1, ST_IND3, cpuselect));
			}
	;
genline : KOC_opcode  expr ',' expr ',' '[' expr ']' '+'
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1,$2);
		pevalexpr(2,$4);
		pevalexpr(3,$7);
		evalr[4].value = AUTOINC;
		locctr += geninstr(findgen($1, ST_IND3, cpuselect));
			}
	;
genline : KOC_opcode  expr '[' expr ']'
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1,$2);
		pevalexpr(2,$4);
		locctr += geninstr(findgen($1, ST_INX1, cpuselect
				 + ( (evalr[1].seg == SSG_ABS 
				&& evalr[1].value >= -128
				&& evalr[1].value <= 127 )
				? DIRECT : EXTENDED ) ) );
			}
	;
genline : KOC_opcode  expr ',' expr '[' expr ']'
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1,$2);
		pevalexpr(2,$4);
		pevalexpr(3,$6);
		locctr += geninstr(findgen($1, ST_INX2, cpuselect
				 + ( (evalr[2].seg == SSG_ABS 
				&& evalr[2].value >= -128
				&& evalr[2].value <= 127 )
				? DIRECT : EXTENDED ) ) );
			}
	;
genline : KOC_opcode  expr ',' expr ',' expr '[' expr ']'
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1,$2);
		pevalexpr(2,$4);
		pevalexpr(3,$6);
		pevalexpr(4,$8);
		locctr += geninstr(findgen($1, ST_INX3, cpuselect
				 + ( (evalr[3].seg == SSG_ABS 
				&& evalr[3].value >= -128
				&& evalr[3].value <= 127 )
				? DIRECT : EXTENDED ) ) );
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
		{"19", CPU196 },
		{"9", CPU96 },
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

#define NUMOPCODE 125
#define NUMSYNBLK 239
#define NUMDIFFOP 323

int gnumopcode = NUMOPCODE;

int ophashlnk[NUMOPCODE];

struct opsym optab[NUMOPCODE+1]
	= {
	{"invalid", KOC_opcode, 2, 0 },
	{"ADD", KOC_opcode, 8, 2 },
	{"ADDB", KOC_opcode, 8, 10 },
	{"ADDC", KOC_opcode, 4, 18 },
	{"ADDCB", KOC_opcode, 4, 22 },
	{"AND", KOC_opcode, 8, 26 },
	{"ANDB", KOC_opcode, 8, 34 },
	{"BMOV", KOC_opcode, 1, 42 },
	{"BR", KOC_opcode, 1, 43 },
	{"BYTE", KOC_BDEF, 0, 0 },
	{"CHARDEF", KOC_CHDEF, 0, 0 },
	{"CHARSET", KOC_CHSET, 0, 0 },
	{"CHARUSE", KOC_CHUSE, 0, 0 },
	{"CHD", KOC_CHDEF, 0, 0 },
	{"CLR", KOC_opcode, 1, 44 },
	{"CLRB", KOC_opcode, 1, 45 },
	{"CLRC", KOC_opcode, 1, 46 },
	{"CLRVT", KOC_opcode, 1, 47 },
	{"CMP", KOC_opcode, 4, 48 },
	{"CMPB", KOC_opcode, 4, 52 },
	{"CMPL", KOC_opcode, 1, 56 },
	{"CPU", KOC_CPU, 0, 0 },
	{"DCB", KOC_BDEF, 0, 0 },
	{"DCL", KOC_ALDEF, 0, 0 },
	{"DCW", KOC_AWDEF, 0, 0 },
	{"DEC", KOC_opcode, 1, 57 },
	{"DECB", KOC_opcode, 1, 58 },
	{"DI", KOC_opcode, 1, 59 },
	{"DIV", KOC_opcode, 4, 60 },
	{"DIVB", KOC_opcode, 4, 64 },
	{"DIVU", KOC_opcode, 4, 68 },
	{"DIVUB", KOC_opcode, 4, 72 },
	{"DJNZ", KOC_opcode, 1, 76 },
	{"DJNZW", KOC_opcode, 1, 77 },
	{"DSB", KOC_RESM, 0, 0 },
	{"DSL", KOC_ALRESM, 0, 0 },
	{"DSW", KOC_AWRESM, 0, 0 },
	{"EI", KOC_opcode, 1, 78 },
	{"ELSE", KOC_ELSE, 0, 0 },
	{"END", KOC_END, 0, 0 },
	{"ENDI", KOC_ENDI, 0, 0 },
	{"EQU", KOC_EQU, 0, 0 },
	{"EXT", KOC_opcode, 1, 79 },
	{"EXTB", KOC_opcode, 1, 80 },
	{"FCB", KOC_BDEF, 0, 0 },
	{"FCC", KOC_SDEF, 0, 0 },
	{"FDB", KOC_AWDEF, 0, 0 },
	{"IDLPD", KOC_opcode, 1, 81 },
	{"IF", KOC_IF, 0, 0 },
	{"INC", KOC_opcode, 1, 82 },
	{"INCB", KOC_opcode, 1, 83 },
	{"INCL", KOC_INCLUDE, 0, 0 },
	{"INCLUDE", KOC_INCLUDE, 0, 0 },
	{"JBC", KOC_opcode, 1, 84 },
	{"JBS", KOC_opcode, 1, 85 },
	{"JC", KOC_opcode, 1, 86 },
	{"JE", KOC_opcode, 1, 87 },
	{"JGE", KOC_opcode, 1, 88 },
	{"JGT", KOC_opcode, 1, 89 },
	{"JH", KOC_opcode, 1, 90 },
	{"JLE", KOC_opcode, 1, 91 },
	{"JLT", KOC_opcode, 1, 92 },
	{"JNC", KOC_opcode, 1, 93 },
	{"JNE", KOC_opcode, 1, 94 },
	{"JNH", KOC_opcode, 1, 95 },
	{"JNST", KOC_opcode, 1, 96 },
	{"JNV", KOC_opcode, 1, 97 },
	{"JNVT", KOC_opcode, 1, 98 },
	{"JST", KOC_opcode, 1, 99 },
	{"JV", KOC_opcode, 1, 100 },
	{"JVT", KOC_opcode, 1, 101 },
	{"LCALL", KOC_opcode, 1, 102 },
	{"LD", KOC_opcode, 4, 103 },
	{"LDB", KOC_opcode, 4, 107 },
	{"LDBSE", KOC_opcode, 4, 111 },
	{"LDBZE", KOC_opcode, 4, 115 },
	{"LJMP", KOC_opcode, 1, 119 },
	{"LONG", KOC_ALDEF, 0, 0 },
	{"MUL", KOC_opcode, 8, 120 },
	{"MULB", KOC_opcode, 8, 128 },
	{"MULU", KOC_opcode, 8, 136 },
	{"MULUB", KOC_opcode, 8, 144 },
	{"NEG", KOC_opcode, 1, 152 },
	{"NEGB", KOC_opcode, 1, 153 },
	{"NOP", KOC_opcode, 1, 154 },
	{"NORML", KOC_opcode, 1, 155 },
	{"NOT", KOC_opcode, 1, 156 },
	{"NOTB", KOC_opcode, 1, 157 },
	{"OR", KOC_opcode, 4, 158 },
	{"ORB", KOC_opcode, 4, 162 },
	{"ORG", KOC_ORG, 0, 0 },
	{"POP", KOC_opcode, 3, 166 },
	{"POPA", KOC_opcode, 1, 169 },
	{"POPF", KOC_opcode, 1, 170 },
	{"PUSH", KOC_opcode, 4, 171 },
	{"PUSHA", KOC_opcode, 1, 175 },
	{"PUSHF", KOC_opcode, 1, 176 },
	{"RESERVE", KOC_RESM, 0, 0 },
	{"RET", KOC_opcode, 1, 177 },
	{"RMB", KOC_RESM, 0, 0 },
	{"RST", KOC_opcode, 1, 178 },
	{"SCALL", KOC_opcode, 1, 179 },
	{"SET", KOC_SET, 0, 0 },
	{"SETC", KOC_opcode, 1, 180 },
	{"SHL", KOC_opcode, 2, 181 },
	{"SHLB", KOC_opcode, 2, 183 },
	{"SHLL", KOC_opcode, 2, 185 },
	{"SHR", KOC_opcode, 2, 187 },
	{"SHRA", KOC_opcode, 2, 189 },
	{"SHRAB", KOC_opcode, 2, 191 },
	{"SHRAL", KOC_opcode, 2, 193 },
	{"SHRB", KOC_opcode, 2, 195 },
	{"SHRL", KOC_opcode, 2, 197 },
	{"SJMP", KOC_opcode, 1, 199 },
	{"SKIP", KOC_opcode, 1, 200 },
	{"ST", KOC_opcode, 3, 201 },
	{"STB", KOC_opcode, 3, 204 },
	{"STRING", KOC_SDEF, 0, 0 },
	{"SUB", KOC_opcode, 8, 207 },
	{"SUBB", KOC_opcode, 8, 215 },
	{"SUBC", KOC_opcode, 4, 223 },
	{"SUBCB", KOC_opcode, 4, 227 },
	{"WORD", KOC_AWDEF, 0, 0 },
	{"XOR", KOC_opcode, 4, 231 },
	{"XORB", KOC_opcode, 4, 235 },
	{ "", 0, 0, 0 }};

struct opsynt ostab[NUMSYNBLK+1]
	= {
/* invalid 0 */ { 0, 1, 0 },
/* invalid 1 */ { 0xffff, 1, 1 },
/* ADD 2 */ { ST_DIR2, 2, 2 },
/* ADD 3 */ { ST_DIR3, 2, 4 },
/* ADD 4 */ { ST_IMM2, 1, 6 },
/* ADD 5 */ { ST_IMM3, 1, 7 },
/* ADD 6 */ { ST_IND2, 1, 8 },
/* ADD 7 */ { ST_IND3, 1, 9 },
/* ADD 8 */ { ST_INX2, 2, 10 },
/* ADD 9 */ { ST_INX3, 2, 12 },
/* ADDB 10 */ { ST_DIR2, 2, 14 },
/* ADDB 11 */ { ST_DIR3, 2, 16 },
/* ADDB 12 */ { ST_IMM2, 1, 18 },
/* ADDB 13 */ { ST_IMM3, 1, 19 },
/* ADDB 14 */ { ST_IND2, 1, 20 },
/* ADDB 15 */ { ST_IND3, 1, 21 },
/* ADDB 16 */ { ST_INX2, 2, 22 },
/* ADDB 17 */ { ST_INX3, 2, 24 },
/* ADDC 18 */ { ST_DIR2, 2, 26 },
/* ADDC 19 */ { ST_IMM2, 1, 28 },
/* ADDC 20 */ { ST_IND2, 1, 29 },
/* ADDC 21 */ { ST_INX2, 2, 30 },
/* ADDCB 22 */ { ST_DIR2, 2, 32 },
/* ADDCB 23 */ { ST_IMM2, 1, 34 },
/* ADDCB 24 */ { ST_IND2, 1, 35 },
/* ADDCB 25 */ { ST_INX2, 2, 36 },
/* AND 26 */ { ST_DIR2, 2, 38 },
/* AND 27 */ { ST_DIR3, 2, 40 },
/* AND 28 */ { ST_IMM2, 1, 42 },
/* AND 29 */ { ST_IMM3, 1, 43 },
/* AND 30 */ { ST_IND2, 1, 44 },
/* AND 31 */ { ST_IND3, 1, 45 },
/* AND 32 */ { ST_INX2, 2, 46 },
/* AND 33 */ { ST_INX3, 2, 48 },
/* ANDB 34 */ { ST_DIR2, 2, 50 },
/* ANDB 35 */ { ST_DIR3, 2, 52 },
/* ANDB 36 */ { ST_IMM2, 1, 54 },
/* ANDB 37 */ { ST_IMM3, 1, 55 },
/* ANDB 38 */ { ST_IND2, 1, 56 },
/* ANDB 39 */ { ST_IND3, 1, 57 },
/* ANDB 40 */ { ST_INX2, 2, 58 },
/* ANDB 41 */ { ST_INX3, 2, 60 },
/* BMOV 42 */ { ST_DIR2, 1, 62 },
/* BR 43 */ { ST_IND1, 1, 63 },
/* CLR 44 */ { ST_DIR1, 1, 64 },
/* CLRB 45 */ { ST_DIR1, 1, 65 },
/* CLRC 46 */ { ST_INH, 1, 66 },
/* CLRVT 47 */ { ST_INH, 1, 67 },
/* CMP 48 */ { ST_DIR2, 2, 68 },
/* CMP 49 */ { ST_IMM2, 1, 70 },
/* CMP 50 */ { ST_IND2, 1, 71 },
/* CMP 51 */ { ST_INX2, 2, 72 },
/* CMPB 52 */ { ST_DIR2, 2, 74 },
/* CMPB 53 */ { ST_IMM2, 1, 76 },
/* CMPB 54 */ { ST_IND2, 1, 77 },
/* CMPB 55 */ { ST_INX2, 2, 78 },
/* CMPL 56 */ { ST_DIR2, 1, 80 },
/* DEC 57 */ { ST_DIR1, 1, 81 },
/* DECB 58 */ { ST_DIR1, 1, 82 },
/* DI 59 */ { ST_INH, 1, 83 },
/* DIV 60 */ { ST_DIR2, 2, 84 },
/* DIV 61 */ { ST_IMM2, 1, 86 },
/* DIV 62 */ { ST_IND2, 1, 87 },
/* DIV 63 */ { ST_INX2, 2, 88 },
/* DIVB 64 */ { ST_DIR2, 2, 90 },
/* DIVB 65 */ { ST_IMM2, 1, 92 },
/* DIVB 66 */ { ST_IND2, 1, 93 },
/* DIVB 67 */ { ST_INX2, 2, 94 },
/* DIVU 68 */ { ST_DIR2, 2, 96 },
/* DIVU 69 */ { ST_IMM2, 1, 98 },
/* DIVU 70 */ { ST_IND2, 1, 99 },
/* DIVU 71 */ { ST_INX2, 2, 100 },
/* DIVUB 72 */ { ST_DIR2, 2, 102 },
/* DIVUB 73 */ { ST_IMM2, 1, 104 },
/* DIVUB 74 */ { ST_IND2, 1, 105 },
/* DIVUB 75 */ { ST_INX2, 2, 106 },
/* DJNZ 76 */ { ST_DIR2, 1, 108 },
/* DJNZW 77 */ { ST_DIR2, 1, 109 },
/* EI 78 */ { ST_INH, 1, 110 },
/* EXT 79 */ { ST_DIR1, 1, 111 },
/* EXTB 80 */ { ST_DIR1, 1, 112 },
/* IDLPD 81 */ { ST_IMM1, 1, 113 },
/* INC 82 */ { ST_DIR1, 1, 114 },
/* INCB 83 */ { ST_DIR1, 1, 115 },
/* JBC 84 */ { ST_DIR3, 1, 116 },
/* JBS 85 */ { ST_DIR3, 1, 117 },
/* JC 86 */ { ST_DIR1, 1, 118 },
/* JE 87 */ { ST_DIR1, 1, 119 },
/* JGE 88 */ { ST_DIR1, 1, 120 },
/* JGT 89 */ { ST_DIR1, 1, 121 },
/* JH 90 */ { ST_DIR1, 1, 122 },
/* JLE 91 */ { ST_DIR1, 1, 123 },
/* JLT 92 */ { ST_DIR1, 1, 124 },
/* JNC 93 */ { ST_DIR1, 1, 125 },
/* JNE 94 */ { ST_DIR1, 1, 126 },
/* JNH 95 */ { ST_DIR1, 1, 127 },
/* JNST 96 */ { ST_DIR1, 1, 128 },
/* JNV 97 */ { ST_DIR1, 1, 129 },
/* JNVT 98 */ { ST_DIR1, 1, 130 },
/* JST 99 */ { ST_DIR1, 1, 131 },
/* JV 100 */ { ST_DIR1, 1, 132 },
/* JVT 101 */ { ST_DIR1, 1, 133 },
/* LCALL 102 */ { ST_DIR1, 1, 134 },
/* LD 103 */ { ST_DIR2, 2, 135 },
/* LD 104 */ { ST_IMM2, 1, 137 },
/* LD 105 */ { ST_IND2, 1, 138 },
/* LD 106 */ { ST_INX2, 2, 139 },
/* LDB 107 */ { ST_DIR2, 2, 141 },
/* LDB 108 */ { ST_IMM2, 1, 143 },
/* LDB 109 */ { ST_IND2, 1, 144 },
/* LDB 110 */ { ST_INX2, 2, 145 },
/* LDBSE 111 */ { ST_DIR2, 2, 147 },
/* LDBSE 112 */ { ST_IMM2, 1, 149 },
/* LDBSE 113 */ { ST_IND2, 1, 150 },
/* LDBSE 114 */ { ST_INX2, 2, 151 },
/* LDBZE 115 */ { ST_DIR2, 2, 153 },
/* LDBZE 116 */ { ST_IMM2, 1, 155 },
/* LDBZE 117 */ { ST_IND2, 1, 156 },
/* LDBZE 118 */ { ST_INX2, 2, 157 },
/* LJMP 119 */ { ST_DIR1, 1, 159 },
/* MUL 120 */ { ST_DIR2, 2, 160 },
/* MUL 121 */ { ST_DIR3, 2, 162 },
/* MUL 122 */ { ST_IMM2, 1, 164 },
/* MUL 123 */ { ST_IMM3, 1, 165 },
/* MUL 124 */ { ST_IND2, 1, 166 },
/* MUL 125 */ { ST_IND3, 1, 167 },
/* MUL 126 */ { ST_INX2, 2, 168 },
/* MUL 127 */ { ST_INX3, 2, 170 },
/* MULB 128 */ { ST_DIR2, 2, 172 },
/* MULB 129 */ { ST_DIR3, 2, 174 },
/* MULB 130 */ { ST_IMM2, 1, 176 },
/* MULB 131 */ { ST_IMM3, 1, 177 },
/* MULB 132 */ { ST_IND2, 1, 178 },
/* MULB 133 */ { ST_IND3, 1, 179 },
/* MULB 134 */ { ST_INX2, 2, 180 },
/* MULB 135 */ { ST_INX3, 2, 182 },
/* MULU 136 */ { ST_DIR2, 2, 184 },
/* MULU 137 */ { ST_DIR3, 2, 186 },
/* MULU 138 */ { ST_IMM2, 1, 188 },
/* MULU 139 */ { ST_IMM3, 1, 189 },
/* MULU 140 */ { ST_IND2, 1, 190 },
/* MULU 141 */ { ST_IND3, 1, 191 },
/* MULU 142 */ { ST_INX2, 2, 192 },
/* MULU 143 */ { ST_INX3, 2, 194 },
/* MULUB 144 */ { ST_DIR2, 2, 196 },
/* MULUB 145 */ { ST_DIR3, 2, 198 },
/* MULUB 146 */ { ST_IMM2, 1, 200 },
/* MULUB 147 */ { ST_IMM3, 1, 201 },
/* MULUB 148 */ { ST_IND2, 1, 202 },
/* MULUB 149 */ { ST_IND3, 1, 203 },
/* MULUB 150 */ { ST_INX2, 2, 204 },
/* MULUB 151 */ { ST_INX3, 2, 206 },
/* NEG 152 */ { ST_DIR1, 1, 208 },
/* NEGB 153 */ { ST_DIR1, 1, 209 },
/* NOP 154 */ { ST_INH, 1, 210 },
/* NORML 155 */ { ST_DIR2, 1, 211 },
/* NOT 156 */ { ST_DIR1, 1, 212 },
/* NOTB 157 */ { ST_DIR1, 1, 213 },
/* OR 158 */ { ST_DIR2, 2, 214 },
/* OR 159 */ { ST_IMM2, 1, 216 },
/* OR 160 */ { ST_IND2, 1, 217 },
/* OR 161 */ { ST_INX2, 2, 218 },
/* ORB 162 */ { ST_DIR2, 2, 220 },
/* ORB 163 */ { ST_IMM2, 1, 222 },
/* ORB 164 */ { ST_IND2, 1, 223 },
/* ORB 165 */ { ST_INX2, 2, 224 },
/* POP 166 */ { ST_DIR1, 2, 226 },
/* POP 167 */ { ST_IND1, 1, 228 },
/* POP 168 */ { ST_INX1, 2, 229 },
/* POPA 169 */ { ST_INH, 1, 231 },
/* POPF 170 */ { ST_INH, 1, 232 },
/* PUSH 171 */ { ST_DIR1, 2, 233 },
/* PUSH 172 */ { ST_IMM1, 1, 235 },
/* PUSH 173 */ { ST_IND1, 1, 236 },
/* PUSH 174 */ { ST_INX1, 2, 237 },
/* PUSHA 175 */ { ST_INH, 1, 239 },
/* PUSHF 176 */ { ST_INH, 1, 240 },
/* RET 177 */ { ST_INH, 1, 241 },
/* RST 178 */ { ST_INH, 1, 242 },
/* SCALL 179 */ { ST_DIR1, 1, 243 },
/* SETC 180 */ { ST_INH, 1, 244 },
/* SHL 181 */ { ST_DIR2, 1, 245 },
/* SHL 182 */ { ST_IMM2, 1, 246 },
/* SHLB 183 */ { ST_DIR2, 1, 247 },
/* SHLB 184 */ { ST_IMM2, 1, 248 },
/* SHLL 185 */ { ST_DIR2, 1, 249 },
/* SHLL 186 */ { ST_IMM2, 1, 250 },
/* SHR 187 */ { ST_DIR2, 1, 251 },
/* SHR 188 */ { ST_IMM2, 1, 252 },
/* SHRA 189 */ { ST_DIR2, 1, 253 },
/* SHRA 190 */ { ST_IMM2, 1, 254 },
/* SHRAB 191 */ { ST_DIR2, 1, 255 },
/* SHRAB 192 */ { ST_IMM2, 1, 256 },
/* SHRAL 193 */ { ST_DIR2, 1, 257 },
/* SHRAL 194 */ { ST_IMM2, 1, 258 },
/* SHRB 195 */ { ST_DIR2, 1, 259 },
/* SHRB 196 */ { ST_IMM2, 1, 260 },
/* SHRL 197 */ { ST_DIR2, 1, 261 },
/* SHRL 198 */ { ST_IMM2, 1, 262 },
/* SJMP 199 */ { ST_DIR1, 1, 263 },
/* SKIP 200 */ { ST_DIR1, 1, 264 },
/* ST 201 */ { ST_DIR2, 2, 265 },
/* ST 202 */ { ST_IND2, 1, 267 },
/* ST 203 */ { ST_INX2, 2, 268 },
/* STB 204 */ { ST_DIR2, 2, 270 },
/* STB 205 */ { ST_IND2, 1, 272 },
/* STB 206 */ { ST_INX2, 2, 273 },
/* SUB 207 */ { ST_DIR2, 2, 275 },
/* SUB 208 */ { ST_DIR3, 2, 277 },
/* SUB 209 */ { ST_IMM2, 1, 279 },
/* SUB 210 */ { ST_IMM3, 1, 280 },
/* SUB 211 */ { ST_IND2, 1, 281 },
/* SUB 212 */ { ST_IND3, 1, 282 },
/* SUB 213 */ { ST_INX2, 2, 283 },
/* SUB 214 */ { ST_INX3, 2, 285 },
/* SUBB 215 */ { ST_DIR2, 2, 287 },
/* SUBB 216 */ { ST_DIR3, 2, 289 },
/* SUBB 217 */ { ST_IMM2, 1, 291 },
/* SUBB 218 */ { ST_IMM3, 1, 292 },
/* SUBB 219 */ { ST_IND2, 1, 293 },
/* SUBB 220 */ { ST_IND3, 1, 294 },
/* SUBB 221 */ { ST_INX2, 2, 295 },
/* SUBB 222 */ { ST_INX3, 2, 297 },
/* SUBC 223 */ { ST_DIR2, 2, 299 },
/* SUBC 224 */ { ST_IMM2, 1, 301 },
/* SUBC 225 */ { ST_IND2, 1, 302 },
/* SUBC 226 */ { ST_INX2, 2, 303 },
/* SUBCB 227 */ { ST_DIR2, 2, 305 },
/* SUBCB 228 */ { ST_IMM2, 1, 307 },
/* SUBCB 229 */ { ST_IND2, 1, 308 },
/* SUBCB 230 */ { ST_INX2, 2, 309 },
/* XOR 231 */ { ST_DIR2, 2, 311 },
/* XOR 232 */ { ST_IMM2, 1, 313 },
/* XOR 233 */ { ST_IND2, 1, 314 },
/* XOR 234 */ { ST_INX2, 2, 315 },
/* XORB 235 */ { ST_DIR2, 2, 317 },
/* XORB 236 */ { ST_IMM2, 1, 319 },
/* XORB 237 */ { ST_IND2, 1, 320 },
/* XORB 238 */ { ST_INX2, 2, 321 },
	{ 0, 0, 0 } };

struct igel igtab[NUMDIFFOP+1]
	= {
/* invalid 0 */   { 0 , 0, 
		"[Xnullentry" },
/* invalid 1 */   { 0 , 0, 
		"[Xinvalid opcode" },
/* ADD 2 */   { ADDR , DIRECT, 
		"64;[2=]~.1&T!.8I;[1=]~.1&T!.8I;" },
/* ADD 3 */   { ADDR , EXTENDED, 
		"67;01;[2=]~.1&T!y[1=]~.1&T!.8I;" },
/* ADD 4 */   { ADDR , DIRECT, 
		"44;[3=]~.1&T!.8I;[2=]~.1&T!.8I;[1=]~.1&T!.8I;" },
/* ADD 5 */   { ADDR , EXTENDED, 
		"47;01;[3=]~.1&T!y[2=]~.1&T!.8I;[1=]~.1&T!.8I;" },
/* ADD 6 */   { 0 , 0, 
		"65;[2=]y[1=]~.1&T!.8I;" },
/* ADD 7 */   { 0 , 0, 
		"45;[3=]y[2=]~.1&T!.8I;[1=]~.1&T!.8I;" },
/* ADD 8 */   { 0 , 0, 
		"66;[2=]~.1&T!.8I.[3#]|;[1=]~.1&T!.8I;" },
/* ADD 9 */   { 0 , 0, 
		"46;[3=]~.1&T!.8I.[4#]|;[2=]~.1&T!.8I;[1=]~.1&T!.8I;" },
/* ADD 10 */   { ADDR , DIRECT, 
		"67;[3=]~.1&T!.8I;[2=]r[1=]~.1&T!.8I;" },
/* ADD 11 */   { ADDR , EXTENDED, 
		"67;[3=]~.1&T!.8I.1|;[2=]y[1=]~.1&T!.8I;" },
/* ADD 12 */   { ADDR , DIRECT, 
		"47;[4=]~.1&T!.8I;[3=]r[2=]~.1&T!.8I;[1=]~.1&T!.8I;" },
/* ADD 13 */   { ADDR , EXTENDED, 
		"47;[4=]~.1&T!.8I.1|;[3=]y[2=]~.1&T!.8I;[1=]~.1&T!.8I;" },
/* ADDB 14 */   { ADDR , DIRECT, 
		"74;[2=].8I;[1=].8I;" },
/* ADDB 15 */   { ADDR , EXTENDED, 
		"77;01;[2=]y[1=].8I;" },
/* ADDB 16 */   { ADDR , DIRECT, 
		"54;[3=].8I;[2=].8I;[1=].8I;" },
/* ADDB 17 */   { ADDR , EXTENDED, 
		"57;01;[3=]y[2=].8I;[1=].8I;" },
/* ADDB 18 */   { 0 , 0, 
		"75;[2=];[1=].8I;" },
/* ADDB 19 */   { 0 , 0, 
		"55;[3=];[2=].8I;[1=].8I;" },
/* ADDB 20 */   { 0 , 0, 
		"76;[2=]~.1&T!.8I.[3#]|;[1=].8I;" },
/* ADDB 21 */   { 0 , 0, 
		"56;[3=]~.1&T!.8I.[4#]|;[2=].8I;[1=].8I;" },
/* ADDB 22 */   { ADDR , DIRECT, 
		"77;[3=]~.1&T!.8I;[2=]r[1=].8I;" },
/* ADDB 23 */   { ADDR , EXTENDED, 
		"77;[3=]~.1&T!.8I.1|;[2=]y[1=].8I;" },
/* ADDB 24 */   { ADDR , DIRECT, 
		"57;[4=]~.1&T!.8I;[3=]r[2=].8I;[1=].8I;" },
/* ADDB 25 */   { ADDR , EXTENDED, 
		"57;[4=]~.1&T!.8I.1|;[3=]y[2=].8I;[1=].8I;" },
/* ADDC 26 */   { ADDR , DIRECT, 
		"a4;[2=]~.1&T!.8I;[1=]~.1&T!.8I;" },
/* ADDC 27 */   { ADDR , EXTENDED, 
		"a7;01;[2=]~.1&T!y[1=]~.1&T!.8I;" },
/* ADDC 28 */   { 0 , 0, 
		"a5;[2=]y[1=]~.1&T!.8I;" },
/* ADDC 29 */   { 0 , 0, 
		"a6;[2=]~.1&T!.8I.[3#]|;[1=]~.1&T!.8I;" },
/* ADDC 30 */   { ADDR , DIRECT, 
		"a7;[3=]~.1&T!.8I;[2=]r[1=]~.1&T!.8I;" },
/* ADDC 31 */   { ADDR , EXTENDED, 
		"a7;[3=]~.1&T!.8I.1|;[2=]y[1=]~.1&T!.8I;" },
/* ADDCB 32 */   { ADDR , DIRECT, 
		"b4;[2=].8I;[1=].8I;" },
/* ADDCB 33 */   { ADDR , EXTENDED, 
		"b7;01;[2=]y[1=].8I;" },
/* ADDCB 34 */   { 0 , 0, 
		"b5;[2=];[1=].8I;" },
/* ADDCB 35 */   { 0 , 0, 
		"b6;[2=]~.1&T!.8I.[3#]|;[1=].8I;" },
/* ADDCB 36 */   { ADDR , DIRECT, 
		"b7;[3=]~.1&T!.8I;[2=]r[1=].8I;" },
/* ADDCB 37 */   { ADDR , EXTENDED, 
		"b7;[3=]~.1&T!.8I.1|;[2=]y[1=].8I;" },
/* AND 38 */   { ADDR , DIRECT, 
		"60;[2=]~.1&T!.8I;[1=]~.1&T!.8I;" },
/* AND 39 */   { ADDR , EXTENDED, 
		"63;01;[2=]~.1&T!y[1=]~.1&T!.8I;" },
/* AND 40 */   { ADDR , DIRECT, 
		"40;[3=]~.1&T!.8I;[2=]~.1&T!.8I;[1=]~.1&T!.8I;" },
/* AND 41 */   { ADDR , EXTENDED, 
		"43;01;[3=]~.1&T!y[2=]~.1&T!.8I;[1=]~.1&T!.8I;" },
/* AND 42 */   { 0 , 0, 
		"61;[2=]y[1=]~.1&T!.8I;" },
/* AND 43 */   { 0 , 0, 
		"41;[3=]y[2=]~.1&T!.8I;[1=]~.1&T!.8I;" },
/* AND 44 */   { 0 , 0, 
		"62;[2=]~.1&T!.8I.[3#]|;[1=]~.1&T!.8I;" },
/* AND 45 */   { 0 , 0, 
		"42;[3=]~.1&T!.8I.[4#]|;[2=]~.1&T!.8I;[1=]~.1&T!.8I;" },
/* AND 46 */   { ADDR , DIRECT, 
		"63;[3=]~.1&T!.8I;[2=]r[1=]~.1&T!.8I;" },
/* AND 47 */   { ADDR , EXTENDED, 
		"63;[3=]~.1&T!.8I.1|;[2=]y[1=]~.1&T!.8I;" },
/* AND 48 */   { ADDR , DIRECT, 
		"43;[4=]~.1&T!.8I;[3=]r[2=]~.1&T!.8I;[1=]~.1&T!.8I;" },
/* AND 49 */   { ADDR , EXTENDED, 
		"43;[4=]~.1&T!.8I.1|;[3=]y[2=]~.1&T!.8I;[1=]~.1&T!.8I;" },
/* ANDB 50 */   { ADDR , DIRECT, 
		"70;[2=].8I;[1=].8I;" },
/* ANDB 51 */   { ADDR , EXTENDED, 
		"73;01;[2=]y[1=].8I;" },
/* ANDB 52 */   { ADDR , DIRECT, 
		"50;[3=].8I;[2=].8I;[1=].8I;" },
/* ANDB 53 */   { ADDR , EXTENDED, 
		"53;01;[3=]y[2=].8I;[1=].8I;" },
/* ANDB 54 */   { 0 , 0, 
		"71;[2=];[1=].8I;" },
/* ANDB 55 */   { 0 , 0, 
		"51;[3=];[2=].8I;[1=].8I;" },
/* ANDB 56 */   { 0 , 0, 
		"72;[2=]~.1&T!.8I.[3#]|;[1=].8I;" },
/* ANDB 57 */   { 0 , 0, 
		"52;[3=]~.1&T!.8I.[4#]|;[2=].8I;[1=].8I;" },
/* ANDB 58 */   { ADDR , DIRECT, 
		"73;[3=]~.1&T!.8I;[2=]r[1=].8I;" },
/* ANDB 59 */   { ADDR , EXTENDED, 
		"73;[3=]~.1&T!.8I.1|;[2=]y[1=].8I;" },
/* ANDB 60 */   { ADDR , DIRECT, 
		"53;[4=]~.1&T!.8I;[3=]r[2=].8I;[1=].8I;" },
/* ANDB 61 */   { ADDR , EXTENDED, 
		"53;[4=]~.1&T!.8I.1|;[3=]y[2=].8I;[1=].8I;" },
/* BMOV 62 */   { CPU196 , CPU196, 
		"c1;[2=]~.1&T!.8I;[1=]~.3&T!.8I;" },
/* BR 63 */   { 0 , 0, 
		"e3;[1=]~.1&T!.8I;" },
/* CLR 64 */   { 0 , 0, 
		"01;[1=]~.1&T!.8I;" },
/* CLRB 65 */   { 0 , 0, 
		"11;[1=].8I;" },
/* CLRC 66 */   { 0 , 0, 
		"f8;" },
/* CLRVT 67 */   { 0 , 0, 
		"fc;" },
/* CMP 68 */   { ADDR , DIRECT, 
		"88;[2=]~.1&T!.8I;[1=]~.1&T!.8I;" },
/* CMP 69 */   { ADDR , EXTENDED, 
		"8b;01;[2=]~.1&T!y[1=]~.1&T!.8I;" },
/* CMP 70 */   { 0 , 0, 
		"89;[2=]y[1=]~.1&T!.8I;" },
/* CMP 71 */   { 0 , 0, 
		"8a;[2=]~.1&T!.8I.[3#]|;[1=]~.1&T!.8I;" },
/* CMP 72 */   { ADDR , DIRECT, 
		"8b;[3=]~.1&T!.8I;[2=]r[1=]~.1&T!.8I;" },
/* CMP 73 */   { ADDR , EXTENDED, 
		"8b;[3=]~.1&T!.8I.1|;[2=]y[1=]~.1&T!.8I;" },
/* CMPB 74 */   { ADDR , DIRECT, 
		"98;[2=].8I;[1=].8I;" },
/* CMPB 75 */   { ADDR , EXTENDED, 
		"9b;01;[2=]y[1=].8I;" },
/* CMPB 76 */   { 0 , 0, 
		"99;[2=];[1=].8I;" },
/* CMPB 77 */   { 0 , 0, 
		"9a;[2=]~.1&T!.8I.[3#]|;[1=].8I;" },
/* CMPB 78 */   { ADDR , DIRECT, 
		"9b;[3=]~.1&T!.8I;[2=]r[1=].8I;" },
/* CMPB 79 */   { ADDR , EXTENDED, 
		"9b;[3=]~.1&T!.8I.1|;[2=]y[1=].8I;" },
/* CMPL 80 */   { CPU196 , CPU196, 
		"c5;[2=]~.3&T!.8I;[1=]~.3&T!.8I;" },
/* DEC 81 */   { 0 , 0, 
		"05;[1=]~.1&T!.8I;" },
/* DECB 82 */   { 0 , 0, 
		"15;[1=].8I;" },
/* DI 83 */   { 0 , 0, 
		"fa;" },
/* DIV 84 */   { ADDR , DIRECT, 
		"fe;8c;[2=]~.1&T!.8I;[1=]~.3&T!.8I;" },
/* DIV 85 */   { ADDR , EXTENDED, 
		"fe;8f;01;[2=]~.1&T!y[1=]~.3&T!.8I;" },
/* DIV 86 */   { 0 , 0, 
		"fe;8d;[2=]y[1=]~.3&T!.8I;" },
/* DIV 87 */   { 0 , 0, 
		"fe;8e;[2=]~.1&T!.8I.[3#]|;[1=]~.3&T!.8I;" },
/* DIV 88 */   { ADDR , DIRECT, 
		"fe;8f;[3=]~.1&T!.8I;[2=]r[1=]~.3&T!.8I;" },
/* DIV 89 */   { ADDR , EXTENDED, 
		"fe;8f;[3=]~.1&T!.8I.1|;[2=]y[1=]~.3&T!.8I;" },
/* DIVB 90 */   { ADDR , DIRECT, 
		"fe;9c;[2=].8I;[1=]~.1&T!.8I;" },
/* DIVB 91 */   { ADDR , EXTENDED, 
		"fe;9f;01;[2=]y[1=]~.1&T!.8I;" },
/* DIVB 92 */   { 0 , 0, 
		"fe;9d;[2=];[1=]~.1&T!.8I;" },
/* DIVB 93 */   { 0 , 0, 
		"fe;9e;[2=]~.1&T!.8I.[3#]|;[1=]~.1&T!.8I;" },
/* DIVB 94 */   { ADDR , DIRECT, 
		"fe;9f;[3=]~.1&T!.8I;[2=]r[1=]~.1&T!.8I;" },
/* DIVB 95 */   { ADDR , EXTENDED, 
		"fe;9f;[3=]~.1&T!.8I.1|;[2=]y[1=]~.1&T!.8I;" },
/* DIVU 96 */   { ADDR , DIRECT, 
		"8c;[2=]~.1&T!.8I;[1=]~.3&T!.8I;" },
/* DIVU 97 */   { ADDR , EXTENDED, 
		"8f;01;[2=]~.1&T!y[1=]~.3&T!.8I;" },
/* DIVU 98 */   { 0 , 0, 
		"8d;[2=]y[1=]~.3&T!.8I;" },
/* DIVU 99 */   { 0 , 0, 
		"8e;[2=]~.1&T!.8I.[3#]|;[1=]~.3&T!.8I;" },
/* DIVU 100 */   { ADDR , DIRECT, 
		"8f;[3=]~.1&T!.8I;[2=]r[1=]~.3&T!.8I;" },
/* DIVU 101 */   { ADDR , EXTENDED, 
		"8f;[3=]~.1&T!.8I.1|;[2=]y[1=]~.3&T!.8I;" },
/* DIVUB 102 */   { ADDR , DIRECT, 
		"9c;[2=].8I;[1=]~.1&T!.8I;" },
/* DIVUB 103 */   { ADDR , EXTENDED, 
		"9f;01;[2=]y[1=]~.1&T!.8I;" },
/* DIVUB 104 */   { 0 , 0, 
		"9d;[2=];[1=]~.1&T!.8I;" },
/* DIVUB 105 */   { 0 , 0, 
		"9e;[2=]~.1&T!.8I.[3#]|;[1=]~.1&T!.8I;" },
/* DIVUB 106 */   { ADDR , DIRECT, 
		"9f;[3=]~.1&T!.8I;[2=]r[1=]~.1&T!.8I;" },
/* DIVUB 107 */   { ADDR , EXTENDED, 
		"9f;[3=]~.1&T!.8I.1|;[2=]y[1=]~.1&T!.8I;" },
/* DJNZ 108 */   { 0 , 0, 
		"e0;[1=].8I;[2=].Q.1+-r" },
/* DJNZW 109 */   { CPU196 , CPU196, 
		"e1;[1=]~.1&T!.8I;[2=].Q.1+-r" },
/* EI 110 */   { 0 , 0, 
		"fb;" },
/* EXT 111 */   { 0 , 0, 
		"06;[1=]~.3&T!.8I;" },
/* EXTB 112 */   { 0 , 0, 
		"16;[1=]~.1&T!.8I;" },
/* IDLPD 113 */   { CPU196 , CPU196, 
		"f6;[1=];" },
/* INC 114 */   { 0 , 0, 
		"07;[1=]~.1&T!.8I;" },
/* INCB 115 */   { 0 , 0, 
		"17;[1=].8I;" },
/* JBC 116 */   { 0 , 0, 
		"[2=].3I.30|;[1=].8I;[3=].Q.1+-r" },
/* JBS 117 */   { 0 , 0, 
		"[2=].3I.38|;[1=].8I;[3=].Q.1+-r" },
/* JC 118 */   { 0 , 0, 
		"db;[1=].Q.1+-r" },
/* JE 119 */   { 0 , 0, 
		"df;[1=].Q.1+-r" },
/* JGE 120 */   { 0 , 0, 
		"d6;[1=].Q.1+-r" },
/* JGT 121 */   { 0 , 0, 
		"d2;[1=].Q.1+-r" },
/* JH 122 */   { 0 , 0, 
		"d9;[1=].Q.1+-r" },
/* JLE 123 */   { 0 , 0, 
		"da;[1=].Q.1+-r" },
/* JLT 124 */   { 0 , 0, 
		"de;[1=].Q.1+-r" },
/* JNC 125 */   { 0 , 0, 
		"d3;[1=].Q.1+-r" },
/* JNE 126 */   { 0 , 0, 
		"d7;[1=].Q.1+-r" },
/* JNH 127 */   { 0 , 0, 
		"d1;[1=].Q.1+-r" },
/* JNST 128 */   { 0 , 0, 
		"d0;[1=].Q.1+-r" },
/* JNV 129 */   { 0 , 0, 
		"d5;[1=].Q.1+-r" },
/* JNVT 130 */   { 0 , 0, 
		"d4;[1=].Q.1+-r" },
/* JST 131 */   { 0 , 0, 
		"d8;[1=].Q.1+-r" },
/* JV 132 */   { 0 , 0, 
		"dd;[1=].Q.1+-r" },
/* JVT 133 */   { 0 , 0, 
		"dc;[1=].Q.1+-r" },
/* LCALL 134 */   { 0 , 0, 
		"ef;[1=].Q.2+-.ffff&y" },
/* LD 135 */   { ADDR , DIRECT, 
		"a0;[2=]~.1&T!.8I;[1=]~.1&T!.8I;" },
/* LD 136 */   { ADDR , EXTENDED, 
		"a3;01;[2=]~.1&T!y[1=]~.1&T!.8I;" },
/* LD 137 */   { 0 , 0, 
		"a1;[2=]y[1=]~.1&T!.8I;" },
/* LD 138 */   { 0 , 0, 
		"a2;[2=]~.1&T!.8I.[3#]|;[1=]~.1&T!.8I;" },
/* LD 139 */   { ADDR , DIRECT, 
		"a3;[3=]~.1&T!.8I;[2=]r[1=]~.1&T!.8I;" },
/* LD 140 */   { ADDR , EXTENDED, 
		"a3;[3=]~.1&T!.8I.1|;[2=]y[1=]~.1&T!.8I;" },
/* LDB 141 */   { ADDR , DIRECT, 
		"b0;[2=].8I;[1=].8I;" },
/* LDB 142 */   { ADDR , EXTENDED, 
		"b3;01;[2=]y[1=].8I;" },
/* LDB 143 */   { 0 , 0, 
		"b1;[2=];[1=].8I;" },
/* LDB 144 */   { 0 , 0, 
		"b2;[2=]~.1&T!.8I.[3#]|;[1=].8I;" },
/* LDB 145 */   { ADDR , DIRECT, 
		"b3;[3=]~.1&T!.8I;[2=]r[1=].8I;" },
/* LDB 146 */   { ADDR , EXTENDED, 
		"b3;[3=]~.1&T!.8I.1|;[2=]y[1=].8I;" },
/* LDBSE 147 */   { ADDR , DIRECT, 
		"bc;[2=].8I;[1=]~.1&T!.8I;" },
/* LDBSE 148 */   { ADDR , EXTENDED, 
		"bf;01;[2=]y[1=]~.1&T!.8I;" },
/* LDBSE 149 */   { 0 , 0, 
		"bd;[2=];[1=]~.1&T!.8I;" },
/* LDBSE 150 */   { 0 , 0, 
		"be;[2=]~.1&T!.8I.[3#]|;[1=]~.1&T!.8I;" },
/* LDBSE 151 */   { ADDR , DIRECT, 
		"bf;[3=]~.1&T!.8I;[2=]r[1=]~.1&T!.8I;" },
/* LDBSE 152 */   { ADDR , EXTENDED, 
		"bf;[3=]~.1&T!.8I.1|;[2=]y[1=]~.1&T!.8I;" },
/* LDBZE 153 */   { ADDR , DIRECT, 
		"ac;[2=].8I;[1=]~.1&T!.8I;" },
/* LDBZE 154 */   { ADDR , EXTENDED, 
		"af;01;[2=]y[1=]~.1&T!.8I;" },
/* LDBZE 155 */   { 0 , 0, 
		"ad;[2=];[1=]~.1&T!.8I;" },
/* LDBZE 156 */   { 0 , 0, 
		"ae;[2=]~.1&T!.8I.[3#]|;[1=]~.1&T!.8I;" },
/* LDBZE 157 */   { ADDR , DIRECT, 
		"af;[3=]~.1&T!.8I;[2=]r[1=]~.1&T!.8I;" },
/* LDBZE 158 */   { ADDR , EXTENDED, 
		"af;[3=]~.1&T!.8I.1|;[2=]y[1=]~.1&T!.8I;" },
/* LJMP 159 */   { 0 , 0, 
		"e7;[1=].Q.2+-.ffff&y" },
/* MUL 160 */   { ADDR , DIRECT, 
		"fe;6c;[2=]~.1&T!.8I;[1=]~.3&T!.8I;" },
/* MUL 161 */   { ADDR , EXTENDED, 
		"fe;6f;01;[2=]~.1&T!y[1=]~.3&T!.8I;" },
/* MUL 162 */   { ADDR , DIRECT, 
		"fe;4c;[3=]~.1&T!.8I;[2=]~.1&T!.8I;[1=]~.3&T!.8I;" },
/* MUL 163 */   { ADDR , EXTENDED, 
		"fe;4f;01;[3=]~.1&T!y[2=]~.1&T!.8I;[1=]~.3&T!.8I;" },
/* MUL 164 */   { 0 , 0, 
		"fe;6d;[2=]y[1=]~.3&T!.8I;" },
/* MUL 165 */   { 0 , 0, 
		"fe;4d;[3=]y[2=]~.1&T!.8I;[1=]~.3&T!.8I;" },
/* MUL 166 */   { 0 , 0, 
		"fe;6e;[2=]~.1&T!.8I.[3#]|;[1=]~.3&T!.8I;" },
/* MUL 167 */   { 0 , 0, 
		"fe;4e;[3=]~.1&T!.8I.[4#]|;[2=]~.1&T!.8I;[1=]~.3&T!.8I;" },
/* MUL 168 */   { ADDR , DIRECT, 
		"fe;6f;[3=]~.1&T!.8I;[2=]r[1=]~.3&T!.8I;" },
/* MUL 169 */   { ADDR , EXTENDED, 
		"fe;6f;[3=]~.1&T!.8I.1|;[2=]y[1=]~.3&T!.8I;" },
/* MUL 170 */   { ADDR , DIRECT, 
		"fe;4f;[4=]~.1&T!.8I;[3=]r[2=]~.1&T!.8I;[1=]~.3&T!.8I;" },
/* MUL 171 */   { ADDR , EXTENDED, 
		"fe;4f;[4=]~.1&T!.8I.1|;[3=]y[2=]~.1&T!.8I;[1=]~.3&T!.8I;" },
/* MULB 172 */   { ADDR , DIRECT, 
		"fe;7c;[2=].8I;[1=]~.1&T!.8I;" },
/* MULB 173 */   { ADDR , EXTENDED, 
		"fe;7f;01;[2=]y[1=]~.1&T!.8I;" },
/* MULB 174 */   { ADDR , DIRECT, 
		"fe;5c;[3=].8I;[2=].8I;[1=]~.1&T!.8I;" },
/* MULB 175 */   { ADDR , EXTENDED, 
		"fe;5f;01;[3=]y[2=].8I;[1=]~.1&T!.8I;" },
/* MULB 176 */   { 0 , 0, 
		"fe;7d;[2=];[1=]~.1&T!.8I;" },
/* MULB 177 */   { 0 , 0, 
		"fe;5d;[3=];[2=].8I;[1=]~.1&T!.8I;" },
/* MULB 178 */   { 0 , 0, 
		"fe;7e;[2=]~.1&T!.8I.[3#]|;[1=]~.1&T!.8I;" },
/* MULB 179 */   { 0 , 0, 
		"fe;5e;[3=]~.1&T!.8I.[4#]|;[2=].8I;[1=]~.1&T!.8I;" },
/* MULB 180 */   { ADDR , DIRECT, 
		"fe;7f;[3=]~.1&T!.8I;[2=]r[1=]~.1&T!.8I;" },
/* MULB 181 */   { ADDR , EXTENDED, 
		"fe;7f;[3=]~.1&T!.8I.1|;[2=]y[1=]~.1&T!.8I;" },
/* MULB 182 */   { ADDR , DIRECT, 
		"fe;5f;[4=]~.1&T!.8I;[3=]r[2=].8I;[1=]~.1&T!.8I;" },
/* MULB 183 */   { ADDR , EXTENDED, 
		"fe;5f;[4=]~.1&T!.8I.1|;[3=]y[2=].8I;[1=]~.1&T!.8I;" },
/* MULU 184 */   { ADDR , DIRECT, 
		"6c;[2=]~.1&T!.8I;[1=]~.3&T!.8I;" },
/* MULU 185 */   { ADDR , EXTENDED, 
		"6f;01;[2=]~.1&T!y[1=]~.3&T!.8I;" },
/* MULU 186 */   { ADDR , DIRECT, 
		"4c;[3=]~.1&T!.8I;[2=]~.1&T!.8I;[1=]~.3&T!.8I;" },
/* MULU 187 */   { ADDR , EXTENDED, 
		"4f;01;[3=]~.1&T!y[2=]~.1&T!.8I;[1=]~.3&T!.8I;" },
/* MULU 188 */   { 0 , 0, 
		"6d;[2=]y[1=]~.3&T!.8I;" },
/* MULU 189 */   { 0 , 0, 
		"4d;[3=]y[2=]~.1&T!.8I;[1=]~.3&T!.8I;" },
/* MULU 190 */   { 0 , 0, 
		"6e;[2=]~.1&T!.8I.[3#]|;[1=]~.3&T!.8I;" },
/* MULU 191 */   { 0 , 0, 
		"4e;[3=]~.1&T!.8I.[4#]|;[2=]~.1&T!.8I;[1=]~.3&T!.8I;" },
/* MULU 192 */   { ADDR , DIRECT, 
		"6f;[3=]~.1&T!.8I;[2=]r[1=]~.3&T!.8I;" },
/* MULU 193 */   { ADDR , EXTENDED, 
		"6f;[3=]~.1&T!.8I.1|;[2=]y[1=]~.3&T!.8I;" },
/* MULU 194 */   { ADDR , DIRECT, 
		"4f;[4=]~.1&T!.8I;[3=]r[2=]~.1&T!.8I;[1=]~.3&T!.8I;" },
/* MULU 195 */   { ADDR , EXTENDED, 
		"4f;[4=]~.1&T!.8I.1|;[3=]y[2=]~.1&T!.8I;[1=]~.3&T!.8I;" },
/* MULUB 196 */   { ADDR , DIRECT, 
		"7c;[2=].8I;[1=]~.1&T!.8I;" },
/* MULUB 197 */   { ADDR , EXTENDED, 
		"7f;01;[2=]y[1=]~.1&T!.8I;" },
/* MULUB 198 */   { ADDR , DIRECT, 
		"5c;[3=].8I;[2=].8I;[1=]~.1&T!.8I;" },
/* MULUB 199 */   { ADDR , EXTENDED, 
		"5f;01;[3=]y[2=].8I;[1=]~.1&T!.8I;" },
/* MULUB 200 */   { 0 , 0, 
		"7d;[2=];[1=]~.1&T!.8I;" },
/* MULUB 201 */   { 0 , 0, 
		"5d;[3=];[2=].8I;[1=]~.1&T!.8I;" },
/* MULUB 202 */   { 0 , 0, 
		"7e;[2=]~.1&T!.8I.[3#]|;[1=]~.1&T!.8I;" },
/* MULUB 203 */   { 0 , 0, 
		"5e;[3=]~.1&T!.8I.[4#]|;[2=].8I;[1=]~.1&T!.8I;" },
/* MULUB 204 */   { ADDR , DIRECT, 
		"7f;[3=]~.1&T!.8I;[2=]r[1=]~.1&T!.8I;" },
/* MULUB 205 */   { ADDR , EXTENDED, 
		"7f;[3=]~.1&T!.8I.1|;[2=]y[1=]~.1&T!.8I;" },
/* MULUB 206 */   { ADDR , DIRECT, 
		"5f;[4=]~.1&T!.8I;[3=]r[2=].8I;[1=]~.1&T!.8I;" },
/* MULUB 207 */   { ADDR , EXTENDED, 
		"5f;[4=]~.1&T!.8I.1|;[3=]y[2=].8I;[1=]~.1&T!.8I;" },
/* NEG 208 */   { 0 , 0, 
		"03;[1=]~.1&T!.8I;" },
/* NEGB 209 */   { 0 , 0, 
		"13;[1=].8I;" },
/* NOP 210 */   { 0 , 0, 
		"fd;" },
/* NORML 211 */   { 0 , 0, 
		"0f;[2=].8I;[1=]~.3&T!.8I;" },
/* NOT 212 */   { 0 , 0, 
		"02;[1=]~.1&T!.8I;" },
/* NOTB 213 */   { 0 , 0, 
		"12;[1=].8I;" },
/* OR 214 */   { ADDR , DIRECT, 
		"80;[2=]~.1&T!.8I;[1=]~.1&T!.8I;" },
/* OR 215 */   { ADDR , EXTENDED, 
		"83;01;[2=]~.1&T!y[1=]~.1&T!.8I;" },
/* OR 216 */   { 0 , 0, 
		"81;[2=]y[1=]~.1&T!.8I;" },
/* OR 217 */   { 0 , 0, 
		"82;[2=]~.1&T!.8I.[3#]|;[1=]~.1&T!.8I;" },
/* OR 218 */   { ADDR , DIRECT, 
		"83;[3=]~.1&T!.8I;[2=]r[1=]~.1&T!.8I;" },
/* OR 219 */   { ADDR , EXTENDED, 
		"83;[3=]~.1&T!.8I.1|;[2=]y[1=]~.1&T!.8I;" },
/* ORB 220 */   { ADDR , DIRECT, 
		"90;[2=].8I;[1=].8I;" },
/* ORB 221 */   { ADDR , EXTENDED, 
		"93;01;[2=]y[1=].8I;" },
/* ORB 222 */   { 0 , 0, 
		"91;[2=];[1=].8I;" },
/* ORB 223 */   { 0 , 0, 
		"92;[2=]~.1&T!.8I.[3#]|;[1=].8I;" },
/* ORB 224 */   { ADDR , DIRECT, 
		"93;[3=]~.1&T!.8I;[2=]r[1=].8I;" },
/* ORB 225 */   { ADDR , EXTENDED, 
		"93;[3=]~.1&T!.8I.1|;[2=]y[1=].8I;" },
/* POP 226 */   { ADDR , DIRECT, 
		"cc;[1=]~.1&T!.8I;" },
/* POP 227 */   { ADDR , EXTENDED, 
		"cf;01;[1=]~.1&T!y" },
/* POP 228 */   { 0 , 0, 
		"ce;[1=]~.1&T!.8I.[2#]|;" },
/* POP 229 */   { ADDR , DIRECT, 
		"cf;[2=]~.1&T!.8I;[1=]r" },
/* POP 230 */   { ADDR , EXTENDED, 
		"cf;[2=]~.1&T!.8I.1|;[1=]y" },
/* POPA 231 */   { CPU196 , CPU196, 
		"f5;" },
/* POPF 232 */   { 0 , 0, 
		"f3;" },
/* PUSH 233 */   { ADDR , DIRECT, 
		"c8;[1=]~.1&T!.8I;" },
/* PUSH 234 */   { ADDR , EXTENDED, 
		"cb;01;[1=]~.1&T!y" },
/* PUSH 235 */   { 0 , 0, 
		"c9;[1=]y" },
/* PUSH 236 */   { 0 , 0, 
		"ca;[1=]~.1&T!.8I.[2#]|;" },
/* PUSH 237 */   { ADDR , DIRECT, 
		"cb;[2=]~.1&T!.8I;[1=]r" },
/* PUSH 238 */   { ADDR , EXTENDED, 
		"cb;[2=]~.1&T!.8I.1|;[1=]y" },
/* PUSHA 239 */   { CPU196 , CPU196, 
		"f4;" },
/* PUSHF 240 */   { 0 , 0, 
		"f2;" },
/* RET 241 */   { 0 , 0, 
		"f0;" },
/* RST 242 */   { 0 , 0, 
		"ff;" },
/* SCALL 243 */   { 0 , 0, 
		"[1=].Q.2+-.bR.2800|x" },
/* SETC 244 */   { 0 , 0, 
		"f9;" },
/* SHL 245 */   { 0 , 0, 
		"09;[2=].8I~.24<T!;[1=]~.1&T!.8I;" },
/* SHL 246 */   { 0 , 0, 
		"09;[2=].4I;[1=]~.1&T!.8I;" },
/* SHLB 247 */   { 0 , 0, 
		"19;[2=].8I~.24<T!;[1=].8I;" },
/* SHLB 248 */   { 0 , 0, 
		"19;[2=].4I;[1=].8I;" },
/* SHLL 249 */   { 0 , 0, 
		"0d;[2=].8I~.24<T!;[1=]~.3&T!.8I;" },
/* SHLL 250 */   { 0 , 0, 
		"0d;[2=].4I;[1=]~.3&T!.8I;" },
/* SHR 251 */   { 0 , 0, 
		"08;[2=].8I~.24<T!;[1=]~.1&T!.8I;" },
/* SHR 252 */   { 0 , 0, 
		"08;[2=].4I;[1=]~.1&T!.8I;" },
/* SHRA 253 */   { 0 , 0, 
		"0a;[2=].8I~.24<T!;[1=]~.1&T!.8I;" },
/* SHRA 254 */   { 0 , 0, 
		"0a;[2=].4I;[1=]~.1&T!.8I;" },
/* SHRAB 255 */   { 0 , 0, 
		"1a;[2=].8I~.24<T!;[1=].8I;" },
/* SHRAB 256 */   { 0 , 0, 
		"1a;[2=].4I;[1=].8I;" },
/* SHRAL 257 */   { 0 , 0, 
		"0e;[2=].8I~.24<T!;[1=]~.3&T!.8I;" },
/* SHRAL 258 */   { 0 , 0, 
		"0e;[2=].4I;[1=]~.3&T!.8I;" },
/* SHRB 259 */   { 0 , 0, 
		"18;[2=].8I~.24<T!;[1=].8I;" },
/* SHRB 260 */   { 0 , 0, 
		"18;[2=].4I;[1=].8I;" },
/* SHRL 261 */   { 0 , 0, 
		"0c;[2=].8I~.24<T!;[1=]~.3&T!.8I;" },
/* SHRL 262 */   { 0 , 0, 
		"0c;[2=].4I;[1=]~.3&T!.8I;" },
/* SJMP 263 */   { 0 , 0, 
		"[1=].Q.2+-.bR.2000|x" },
/* SKIP 264 */   { 0 , 0, 
		"00;[1=];" },
/* ST 265 */   { ADDR , DIRECT, 
		"c0;[2=]~.1&T!.8I;[1=]~.1&T!.8I;" },
/* ST 266 */   { ADDR , EXTENDED, 
		"c3;01;[2=]~.1&T!y[1=]~.1&T!.8I;" },
/* ST 267 */   { 0 , 0, 
		"c2;[2=]~.1&T!.8I.[3#]|;[1=]~.1&T!.8I;" },
/* ST 268 */   { ADDR , DIRECT, 
		"c3;[3=]~.1&T!.8I;[2=]r[1=]~.1&T!.8I;" },
/* ST 269 */   { ADDR , EXTENDED, 
		"c3;[3=]~.1&T!.8I.1|;[2=]y[1=]~.1&T!.8I;" },
/* STB 270 */   { ADDR , DIRECT, 
		"c4;[2=].8I;[1=].8I;" },
/* STB 271 */   { ADDR , EXTENDED, 
		"c7;01;[2=]y[1=].8I;" },
/* STB 272 */   { 0 , 0, 
		"c6;[2=]~.1&T!.8I.[3#]|;[1=].8I;" },
/* STB 273 */   { ADDR , DIRECT, 
		"c7;[3=]~.1&T!.8I;[2=]r[1=].8I;" },
/* STB 274 */   { ADDR , EXTENDED, 
		"c7;[3=]~.1&T!.8I.1|;[2=]y[1=].8I;" },
/* SUB 275 */   { ADDR , DIRECT, 
		"68;[2=]~.1&T!.8I;[1=]~.1&T!.8I;" },
/* SUB 276 */   { ADDR , EXTENDED, 
		"6b;01;[2=]~.1&T!y[1=]~.1&T!.8I;" },
/* SUB 277 */   { ADDR , DIRECT, 
		"48;[3=]~.1&T!.8I;[2=]~.1&T!.8I;[1=]~.1&T!.8I;" },
/* SUB 278 */   { ADDR , EXTENDED, 
		"4b;01;[3=]~.1&T!y[2=]~.1&T!.8I;[1=]~.1&T!.8I;" },
/* SUB 279 */   { 0 , 0, 
		"69;[2=]y[1=]~.1&T!.8I;" },
/* SUB 280 */   { 0 , 0, 
		"49;[3=]y[2=]~.1&T!.8I;[1=]~.1&T!.8I;" },
/* SUB 281 */   { 0 , 0, 
		"6a;[2=]~.1&T!.8I.[3#]|;[1=]~.1&T!.8I;" },
/* SUB 282 */   { 0 , 0, 
		"4a;[3=]~.1&T!.8I.[4#]|;[2=]~.1&T!.8I;[1=]~.1&T!.8I;" },
/* SUB 283 */   { ADDR , DIRECT, 
		"6b;[3=]~.1&T!.8I;[2=]r[1=]~.1&T!.8I;" },
/* SUB 284 */   { ADDR , EXTENDED, 
		"6b;[3=]~.1&T!.8I.1|;[2=]y[1=]~.1&T!.8I;" },
/* SUB 285 */   { ADDR , DIRECT, 
		"4b;[4=]~.1&T!.8I;[3=]r[2=]~.1&T!.8I;[1=]~.1&T!.8I;" },
/* SUB 286 */   { ADDR , EXTENDED, 
		"4b;[4=]~.1&T!.8I.1|;[3=]y[2=]~.1&T!.8I;[1=]~.1&T!.8I;" },
/* SUBB 287 */   { ADDR , DIRECT, 
		"78;[2=].8I;[1=].8I;" },
/* SUBB 288 */   { ADDR , EXTENDED, 
		"7b;01;[2=]y[1=].8I;" },
/* SUBB 289 */   { ADDR , DIRECT, 
		"58;[3=].8I;[2=].8I;[1=].8I;" },
/* SUBB 290 */   { ADDR , EXTENDED, 
		"5b;01;[3=]y[2=].8I;[1=].8I;" },
/* SUBB 291 */   { 0 , 0, 
		"79;[2=];[1=].8I;" },
/* SUBB 292 */   { 0 , 0, 
		"59;[3=];[2=].8I;[1=].8I;" },
/* SUBB 293 */   { 0 , 0, 
		"7a;[2=]~.1&T!.8I.[3#]|;[1=].8I;" },
/* SUBB 294 */   { 0 , 0, 
		"5a;[3=]~.1&T!.8I.[4#]|;[2=].8I;[1=].8I;" },
/* SUBB 295 */   { ADDR , DIRECT, 
		"7b;[3=]~.1&T!.8I;[2=]r[1=].8I;" },
/* SUBB 296 */   { ADDR , EXTENDED, 
		"7b;[3=]~.1&T!.8I.1|;[2=]y[1=].8I;" },
/* SUBB 297 */   { ADDR , DIRECT, 
		"5b;[4=]~.1&T!.8I;[3=]r[2=].8I;[1=].8I;" },
/* SUBB 298 */   { ADDR , EXTENDED, 
		"5b;[4=]~.1&T!.8I.1|;[3=]y[2=].8I;[1=].8I;" },
/* SUBC 299 */   { ADDR , DIRECT, 
		"a8;[2=]~.1&T!.8I;[1=]~.1&T!.8I;" },
/* SUBC 300 */   { ADDR , EXTENDED, 
		"ab;01;[2=]~.1&T!y[1=]~.1&T!.8I;" },
/* SUBC 301 */   { 0 , 0, 
		"a9;[2=]y[1=]~.1&T!.8I;" },
/* SUBC 302 */   { 0 , 0, 
		"aa;[2=]~.1&T!.8I.[3#]|;[1=]~.1&T!.8I;" },
/* SUBC 303 */   { ADDR , DIRECT, 
		"ab;[3=]~.1&T!.8I;[2=]r[1=]~.1&T!.8I;" },
/* SUBC 304 */   { ADDR , EXTENDED, 
		"ab;[3=]~.1&T!.8I.1|;[2=]y[1=]~.1&T!.8I;" },
/* SUBCB 305 */   { ADDR , DIRECT, 
		"b8;[2=].8I;[1=].8I;" },
/* SUBCB 306 */   { ADDR , EXTENDED, 
		"bb;01;[2=]y[1=].8I;" },
/* SUBCB 307 */   { 0 , 0, 
		"b9;[2=];[1=].8I;" },
/* SUBCB 308 */   { 0 , 0, 
		"ba;[2=]~.1&T!.8I.[3#]|;[1=].8I;" },
/* SUBCB 309 */   { ADDR , DIRECT, 
		"bb;[3=]~.1&T!.8I;[2=]r[1=].8I;" },
/* SUBCB 310 */   { ADDR , EXTENDED, 
		"bb;[3=]~.1&T!.8I.1|;[2=]y[1=].8I;" },
/* XOR 311 */   { ADDR , DIRECT, 
		"84;[2=]~.1&T!.8I;[1=]~.1&T!.8I;" },
/* XOR 312 */   { ADDR , EXTENDED, 
		"87;01;[2=]~.1&T!y[1=]~.1&T!.8I;" },
/* XOR 313 */   { 0 , 0, 
		"85;[2=]y[1=]~.1&T!.8I;" },
/* XOR 314 */   { 0 , 0, 
		"86;[2=]~.1&T!.8I.[3#]|;[1=]~.1&T!.8I;" },
/* XOR 315 */   { ADDR , DIRECT, 
		"87;[3=]~.1&T!.8I;[2=]r[1=]~.1&T!.8I;" },
/* XOR 316 */   { ADDR , EXTENDED, 
		"87;[3=]~.1&T!.8I.1|;[2=]y[1=]~.1&T!.8I;" },
/* XORB 317 */   { ADDR , DIRECT, 
		"94;[2=].8I;[1=].8I;" },
/* XORB 318 */   { ADDR , EXTENDED, 
		"97;01;[2=]y[1=].8I;" },
/* XORB 319 */   { 0 , 0, 
		"95;[2=];[1=].8I;" },
/* XORB 320 */   { 0 , 0, 
		"96;[2=]~.1&T!.8I.[3#]|;[1=].8I;" },
/* XORB 321 */   { ADDR , DIRECT, 
		"97;[3=]~.1&T!.8I;[2=]r[1=].8I;" },
/* XORB 322 */   { ADDR , EXTENDED, 
		"97;[3=]~.1&T!.8I.1|;[2=]y[1=].8I;" },
	{ 0,0,""} };
/* end fraptabdef.c */
