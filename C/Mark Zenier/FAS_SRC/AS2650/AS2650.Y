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
FILENAME: 	as2650.y;
WARNINGS: 	"This software is in the public domain.  
		Any prior copyright claims are relinquished.  

		This software is distributed with no warranty whatever.  
		The author takes no responsibility for the consequences 
		of its use.

		Yacc (or Bison) required to compile."  ;
SEE-ALSO: 	as2650.doc,frasmain.c;	
AUTHORS: 	Mark Zenier;
COMPILERS: 	Microport Sys V/AT, ATT Yacc, Turbo C V1.5, Bison (CUG disk 285)
		(previous versions Xenix, Unisoft 68000 Version 7, Sun 3);
*/
/* 2650 instruction generation file, standard syntax */
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

	/* selectors for register */
	/* 0000 0000 0000 xxxx */
#define REGMASK	0xf 
#define REG0	0x1
#define REG1	0x2
#define REG2	0x4
#define REG3	0x8
	/* selectors for conditions */
	/* 0000 0000 xxxx 0000 */
#define CONDMASK	0xf0
#define COND0	0x10
#define COND1	0x20
#define COND2	0x40
#define COND3 0x80

#define PAGEBITS 0x6000
#define ST_INH 0x1
#define ST_EXP 0x2
#define ST_INDIR 0x4
#define ST_REG 0x8
#define ST_REGCOMMA 0x10
#define ST_REGEXP 0x20
#define ST_REGINDIR 0x40
#define ST_COND 0x80
#define ST_CONDEXP 0x100
#define ST_CONDINDIR 0x200
#define ST_BINDEX 0x400
#define ST_BINDIRX 0x800
#define	API_ABS	0
#define	API_INC	2
#define	API_DEC	4
#define	API_IND	6
#define	API_IABS	8
#define	API_IINC	0xa
#define	API_IDEC	0xc
#define	API_IIND	0xe
#define ST_ABSOLUTE 0x1
#define ST_INDEX 0x2
#define ST_INCINDEX 0x4
#define ST_DECINDEX 0x8
#define ST_AREGINDIR 0x10
#define ST_INDIRX 0x20
#define ST_INCINDIRX 0x40
#define ST_DECINDIRX 0x80
	
	static int	regsel[4] = {REG0, REG1, REG2, REG3};
	static int	condsel[4] = {COND0, COND1, COND2, COND3};
	static int	prevpage;
	static char	genbdef[] = "[1=];";
	static char	genwdef[] = "[1=]x"; /* x for normal, y for byte rev */
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

%token <intv> REGISTER 
%token <intv> CONDITION 
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
%token <intv> KOC_ACON
%token <intv> KOC_opcode
%token <intv> KOC_indexabs

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


genline :	KOC_ACON exprlist
		{
			genlocrec(currseg, labelloc);
			for( satsub = 0; satsub < $2; satsub++)
			{
				pevalexpr(1, exprlist[satsub]);
				locctr += geninstr("[1=].fIx");
			}
		}	
genline : KOC_opcode 
		{
		genlocrec(currseg, labelloc);
		prevpage = (locctr & PAGEBITS);
		if(prevpage == locctr)
			frawarn("Page Boundary");
		locctr += geninstr(findgen($1, ST_INH, 0));
		}
	;
genline : KOC_opcode  expr
		{
		genlocrec(currseg, labelloc);
		prevpage = (locctr & PAGEBITS);
		if(prevpage == locctr)
			frawarn("Page Boundary");
		pevalexpr(1, $2);
		locctr += geninstr(findgen($1, ST_EXP, 0));
		if(((locctr -1) & PAGEBITS) != prevpage)
			fraerror("instruction crosses page boundry");
		}
	;
genline : KOC_opcode  '*' expr 
		{
		genlocrec(currseg, labelloc);
		prevpage = (locctr & PAGEBITS);
		if(prevpage == locctr)
			frawarn("Page Boundary");
		pevalexpr(1, $3);
		locctr += geninstr(findgen($1, ST_INDIR, 0));
		if(((locctr -1) & PAGEBITS) != prevpage)
			fraerror("instruction crosses page boundry");
		}
	;
genline : KOC_opcode  REGISTER
		{
		genlocrec(currseg, labelloc);
		prevpage = (locctr & PAGEBITS);
		if(prevpage == locctr)
			frawarn("Page Boundary");
		evalr[1].value = $2;
		locctr += geninstr(findgen($1, ST_REG, regsel[$2] ));
		}
	;
genline : KOC_opcode  ',' REGISTER
		{
		genlocrec(currseg, labelloc);
		prevpage = (locctr & PAGEBITS);
		if(prevpage == locctr)
			frawarn("Page Boundary");
		evalr[1].value = $3;
		locctr += geninstr(findgen($1, ST_REGCOMMA, regsel[$3] ));
		}
	;
genline : KOC_opcode  ',' REGISTER expr
		{
		genlocrec(currseg, labelloc);
		prevpage = (locctr & PAGEBITS);
		if(prevpage == locctr)
			frawarn("Page Boundary");
		evalr[1].value = $3;
		pevalexpr(2, $4);
		locctr += geninstr(findgen($1, ST_REGEXP, regsel[$3] ));
		if(((locctr -1) & PAGEBITS) != prevpage)
			fraerror("instruction crosses page boundry");
		}
	;
genline : KOC_opcode  ',' REGISTER '*' expr 
		{
		genlocrec(currseg, labelloc);
		prevpage = (locctr & PAGEBITS);
		if(prevpage == locctr)
			frawarn("Page Boundary");
		evalr[1].value = $3;
		pevalexpr(2, $5);
		locctr += geninstr(findgen($1, ST_REGINDIR, regsel[$3] ));
		if(((locctr -1) & PAGEBITS) != prevpage)
			fraerror("instruction crosses page boundry");
		}
	;
genline : KOC_opcode  ',' CONDITION
		{
		genlocrec(currseg, labelloc);
		prevpage = (locctr & PAGEBITS);
		if(prevpage == locctr)
			frawarn("Page Boundary");
		evalr[1].value = $3;
		locctr += geninstr(findgen($1, ST_COND, condsel[$3] ));
		}
	;
genline : KOC_opcode  ',' CONDITION expr
		{
		genlocrec(currseg, labelloc);
		prevpage = (locctr & PAGEBITS);
		if(prevpage == locctr)
			frawarn("Page Boundary");
		evalr[1].value = $3;
		pevalexpr(2, $4);
		locctr += geninstr(findgen($1, ST_CONDEXP, condsel[$3] ));
		if(((locctr -1) & PAGEBITS) != prevpage)
			fraerror("instruction crosses page boundry");
		}
	;
genline : KOC_opcode  ',' CONDITION '*' expr 
		{
		genlocrec(currseg, labelloc);
		prevpage = (locctr & PAGEBITS);
		if(prevpage == locctr)
			frawarn("Page Boundary");
		evalr[1].value = $3;
		pevalexpr(2, $5);
		locctr += geninstr(findgen($1, ST_CONDINDIR, condsel[$3] ));
		if(((locctr -1) & PAGEBITS) != prevpage)
			fraerror("instruction crosses page boundry");
		}
	;
genline : KOC_opcode  expr ',' REGISTER
		{
		genlocrec(currseg, labelloc);
		prevpage = (locctr & PAGEBITS);
		if(prevpage == locctr)
			frawarn("Page Boundary");
		evalr[1].value = $4;
		pevalexpr(2, $2);
		locctr += geninstr(findgen($1, ST_BINDEX, regsel[$4] ));
		if(((locctr -1) & PAGEBITS) != prevpage)
			fraerror("instruction crosses page boundry");
		}
	;
genline : KOC_opcode  '*' expr ',' REGISTER
		{
		genlocrec(currseg, labelloc);
		prevpage = (locctr & PAGEBITS);
		if(prevpage == locctr)
			frawarn("Page Boundary");
		evalr[1].value = $5;
		pevalexpr(2, $3);
		locctr += geninstr(findgen($1, ST_BINDIRX, regsel[$5] ));
		if(((locctr -1) & PAGEBITS) != prevpage)
			fraerror("instruction crosses page boundry");
		}
	;
genline : KOC_indexabs  ',' REGISTER  expr
		{
		genlocrec(currseg, labelloc);
		prevpage = (locctr & PAGEBITS);
		if(prevpage == locctr)
			frawarn("Page Boundary");
		evalr[1].value = $3;
		pevalexpr(2, $4);
		evalr[3].value = API_ABS;
		locctr += geninstr(findgen($1, ST_ABSOLUTE, regsel[$3] ));
		if(((locctr -1) & PAGEBITS) != prevpage)
			fraerror("instruction crosses page boundry");
		}
	;
genline : KOC_indexabs  ',' REGISTER expr ',' REGISTER
		{
		genlocrec(currseg, labelloc);
		prevpage = (locctr & PAGEBITS);
		if(prevpage == locctr)
			frawarn("Page Boundary");
		if($3 != 0)
			fraerror("destination register must be R0");
		evalr[1].value = $6;
		pevalexpr(2, $4);
		evalr[3].value = API_IND;
		locctr += geninstr(findgen($1, ST_ABSOLUTE, regsel[$6] ));
		if(((locctr -1) & PAGEBITS) != prevpage)
			fraerror("instruction crosses page boundry");
		}
	;
genline : KOC_indexabs  ',' REGISTER expr ',' REGISTER ',' '+'
		{
		genlocrec(currseg, labelloc);
		prevpage = (locctr & PAGEBITS);
		if(prevpage == locctr)
			frawarn("Page Boundary");
		if($3 != 0)
			fraerror("destination register must be R0");
		evalr[1].value = $6;
		pevalexpr(2, $4);
		evalr[3].value = API_INC;
		locctr += geninstr(findgen($1, ST_ABSOLUTE, regsel[$6] ));
		if(((locctr -1) & PAGEBITS) != prevpage)
			fraerror("instruction crosses page boundry");
		}
	;
genline : KOC_indexabs  ',' REGISTER expr ',' REGISTER ',' '-' 
		{
		genlocrec(currseg, labelloc);
		prevpage = (locctr & PAGEBITS);
		if(prevpage == locctr)
			frawarn("Page Boundary");
		if($3 != 0)
			fraerror("destination register must be R0");
		evalr[1].value = $6;
		pevalexpr(2, $4);
		evalr[3].value = API_DEC;
		locctr += geninstr(findgen($1, ST_ABSOLUTE, regsel[$6] ));
		if(((locctr -1) & PAGEBITS) != prevpage)
			fraerror("instruction crosses page boundry");
		}
	;
genline : KOC_indexabs  ',' REGISTER '*' expr 
		{
		genlocrec(currseg, labelloc);
		prevpage = (locctr & PAGEBITS);
		if(prevpage == locctr)
			frawarn("Page Boundary");
		evalr[1].value = $3;
		pevalexpr(2, $5);
		evalr[3].value = API_IABS;
		locctr += geninstr(findgen($1, ST_ABSOLUTE, regsel[$3] ));
		if(((locctr -1) & PAGEBITS) != prevpage)
			fraerror("instruction crosses page boundry");
		}
	;
genline : KOC_indexabs  ',' REGISTER '*' expr ',' REGISTER
		{
		genlocrec(currseg, labelloc);
		prevpage = (locctr & PAGEBITS);
		if(prevpage == locctr)
			frawarn("Page Boundary");
		if($3 != 0)
			fraerror("destination register must be R0");
		evalr[1].value = $7;
		pevalexpr(2, $5);
		evalr[3].value = API_IIND;
		locctr += geninstr(findgen($1, ST_ABSOLUTE, regsel[$7] ));
		if(((locctr -1) & PAGEBITS) != prevpage)
			fraerror("instruction crosses page boundry");
		}
	;
genline : KOC_indexabs  ',' REGISTER '*' expr ',' REGISTER ',' '+' 
		{
		genlocrec(currseg, labelloc);
		prevpage = (locctr & PAGEBITS);
		if(prevpage == locctr)
			frawarn("Page Boundary");
		if($3 != 0)
			fraerror("destination register must be R0");
		evalr[1].value = $7;
		pevalexpr(2, $5);
		evalr[3].value = API_IINC;
		locctr += geninstr(findgen($1, ST_ABSOLUTE, regsel[$7] ));
		if(((locctr -1) & PAGEBITS) != prevpage)
			fraerror("instruction crosses page boundry");
		}
	;
genline : KOC_indexabs  ',' REGISTER '*' expr ',' REGISTER ',' '-' 
		{
		genlocrec(currseg, labelloc);
		prevpage = (locctr & PAGEBITS);
		if(prevpage == locctr)
			frawarn("Page Boundary");
		if($3 != 0)
			fraerror("destination register must be R0");
		evalr[1].value = $7;
		pevalexpr(2, $5);
		evalr[3].value = API_IDEC;
		locctr += geninstr(findgen($1, ST_ABSOLUTE, regsel[$7] ));
		if(((locctr -1) & PAGEBITS) != prevpage)
			fraerror("instruction crosses page boundry");
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
	|	'$'
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
	reservedsym("ge", KEOP_GE, 0);
	reservedsym("high", KEOP_HIGH, 0);
	reservedsym("le", KEOP_LE, 0);
	reservedsym("low", KEOP_LOW, 0);
	reservedsym("mod", KEOP_MOD, 0);
	reservedsym("ne", KEOP_NE, 0);
	reservedsym("not", KEOP_NOT, 0);
	reservedsym("or", KEOP_OR, 0);
	reservedsym("shl", KEOP_SHL, 0);
	reservedsym("shr", KEOP_SHR, 0);
	reservedsym("xor", KEOP_XOR, 0);
	reservedsym("AND", KEOP_AND, 0);
	reservedsym("DEFINED", KEOP_DEFINED,0);
	reservedsym("GE", KEOP_GE, 0);
	reservedsym("HIGH", KEOP_HIGH, 0);
	reservedsym("LE", KEOP_LE, 0);
	reservedsym("LOW", KEOP_LOW, 0);
	reservedsym("MOD", KEOP_MOD, 0);
	reservedsym("NE", KEOP_NE, 0);
	reservedsym("NOT", KEOP_NOT, 0);
	reservedsym("OR", KEOP_OR, 0);
	reservedsym("SHL", KEOP_SHL, 0);
	reservedsym("SHR", KEOP_SHR, 0);
	reservedsym("XOR", KEOP_XOR, 0);

	/* machine specific token definitions */
	reservedsym("r0", REGISTER, 0);
	reservedsym("r1", REGISTER, 1);
	reservedsym("r2", REGISTER, 2);
	reservedsym("r3", REGISTER, 3);
	reservedsym("R0", REGISTER, 0);
	reservedsym("R1", REGISTER, 1);
	reservedsym("R2", REGISTER, 2);
	reservedsym("R3", REGISTER, 3);
	reservedsym("PLUS", CONDITION, 1);
	reservedsym("ZERO", CONDITION, 0); 
	reservedsym("MINUS", CONDITION, 2);
	reservedsym("GT", CONDITION, 1);
	reservedsym("EQ", CONDITION, 0); 
	reservedsym("LT", CONDITION, 2);
	reservedsym("UN", CONDITION, 3);
	reservedsym("ALWAYS", CONDITION, 3);
	reservedsym("plus", CONDITION, 1);
	reservedsym("zero", CONDITION, 0); 
	reservedsym("minus", CONDITION, 2);
	reservedsym("gt", CONDITION, 1);
	reservedsym("eq", CONDITION, 0); 
	reservedsym("lt", CONDITION, 2);
	reservedsym("un", CONDITION, 3);
	reservedsym("always", CONDITION, 3);

}

cpumatch(str)
	char *str;
{
	return TRUE;
}


/*
	description	Opcode and Instruction generation tables
	usage		Unix, framework crossassembler
	history		September 25, 1987
*/

#define NUMOPCODE 102
#define NUMSYNBLK 105
#define NUMDIFFOP 128

int gnumopcode = NUMOPCODE;

int ophashlnk[NUMOPCODE];

struct opsym optab[NUMOPCODE+1]
	= {
	{"invalid", KOC_opcode, 2, 0 },
	{"ACON", KOC_ACON, 0, 0 },
	{"ADDA", KOC_indexabs, 1, 2 },
	{"ADDI", KOC_opcode, 1, 3 },
	{"ADDR", KOC_opcode, 2, 4 },
	{"ADDZ", KOC_opcode, 1, 6 },
	{"ANDA", KOC_indexabs, 1, 7 },
	{"ANDI", KOC_opcode, 1, 8 },
	{"ANDR", KOC_opcode, 2, 9 },
	{"ANDZ", KOC_opcode, 1, 11 },
	{"BCFA", KOC_opcode, 2, 12 },
	{"BCFR", KOC_opcode, 2, 14 },
	{"BCTA", KOC_opcode, 2, 16 },
	{"BCTR", KOC_opcode, 2, 18 },
	{"BDRA", KOC_opcode, 2, 20 },
	{"BDRR", KOC_opcode, 2, 22 },
	{"BIRA", KOC_opcode, 2, 24 },
	{"BIRR", KOC_opcode, 2, 26 },
	{"BRNA", KOC_opcode, 2, 28 },
	{"BRNR", KOC_opcode, 2, 30 },
	{"BSFA", KOC_opcode, 2, 32 },
	{"BSFR", KOC_opcode, 2, 34 },
	{"BSNA", KOC_opcode, 2, 36 },
	{"BSNR", KOC_opcode, 2, 38 },
	{"BSTA", KOC_opcode, 2, 40 },
	{"BSTR", KOC_opcode, 2, 42 },
	{"BSXA", KOC_opcode, 2, 44 },
	{"BXA", KOC_opcode, 2, 46 },
	{"BYTE", KOC_BDEF, 0, 0 },
	{"CHARDEF", KOC_CHDEF, 0, 0 },
	{"CHARSET", KOC_CHSET, 0, 0 },
	{"CHARUSE", KOC_CHUSE, 0, 0 },
	{"CHD", KOC_CHDEF, 0, 0 },
	{"COMA", KOC_indexabs, 1, 48 },
	{"COMI", KOC_opcode, 1, 49 },
	{"COMR", KOC_opcode, 2, 50 },
	{"COMZ", KOC_opcode, 1, 52 },
	{"CPSL", KOC_opcode, 1, 53 },
	{"CPSU", KOC_opcode, 1, 54 },
	{"DAR", KOC_opcode, 1, 55 },
	{"DATA", KOC_BDEF, 0, 0 },
	{"DB", KOC_BDEF, 0, 0 },
	{"DW", KOC_WDEF, 0, 0 },
	{"ELSE", KOC_ELSE, 0, 0 },
	{"END", KOC_END, 0, 0 },
	{"ENDI", KOC_ENDI, 0, 0 },
	{"EORA", KOC_indexabs, 1, 56 },
	{"EORI", KOC_opcode, 1, 57 },
	{"EORR", KOC_opcode, 2, 58 },
	{"EORZ", KOC_opcode, 1, 60 },
	{"EQU", KOC_EQU, 0, 0 },
	{"FCB", KOC_BDEF, 0, 0 },
	{"FCC", KOC_SDEF, 0, 0 },
	{"FDB", KOC_WDEF, 0, 0 },
	{"HALT", KOC_opcode, 1, 61 },
	{"IF", KOC_IF, 0, 0 },
	{"INCL", KOC_INCLUDE, 0, 0 },
	{"INCLUDE", KOC_INCLUDE, 0, 0 },
	{"IORA", KOC_indexabs, 1, 62 },
	{"IORI", KOC_opcode, 1, 63 },
	{"IORR", KOC_opcode, 2, 64 },
	{"IORZ", KOC_opcode, 1, 66 },
	{"LODA", KOC_indexabs, 1, 67 },
	{"LODI", KOC_opcode, 1, 68 },
	{"LODR", KOC_opcode, 2, 69 },
	{"LODZ", KOC_opcode, 1, 71 },
	{"LPSL", KOC_opcode, 1, 72 },
	{"LPSU", KOC_opcode, 1, 73 },
	{"NOP", KOC_opcode, 1, 74 },
	{"ORG", KOC_ORG, 0, 0 },
	{"PPSL", KOC_opcode, 1, 75 },
	{"PPSU", KOC_opcode, 1, 76 },
	{"REDC", KOC_opcode, 1, 77 },
	{"REDD", KOC_opcode, 1, 78 },
	{"REDE", KOC_opcode, 1, 79 },
	{"RES", KOC_RESM, 0, 0 },
	{"RESERVE", KOC_RESM, 0, 0 },
	{"RETC", KOC_opcode, 1, 80 },
	{"RETE", KOC_opcode, 1, 81 },
	{"RMB", KOC_RESM, 0, 0 },
	{"RRL", KOC_opcode, 1, 82 },
	{"RRR", KOC_opcode, 1, 83 },
	{"SET", KOC_SET, 0, 0 },
	{"SPSL", KOC_opcode, 1, 84 },
	{"SPSU", KOC_opcode, 1, 85 },
	{"STRA", KOC_indexabs, 1, 86 },
	{"STRING", KOC_SDEF, 0, 0 },
	{"STRR", KOC_opcode, 2, 87 },
	{"STRZ", KOC_opcode, 1, 89 },
	{"SUBA", KOC_indexabs, 1, 90 },
	{"SUBI", KOC_opcode, 1, 91 },
	{"SUBR", KOC_opcode, 2, 92 },
	{"SUBZ", KOC_opcode, 1, 94 },
	{"TMI", KOC_opcode, 1, 95 },
	{"TPSL", KOC_opcode, 1, 96 },
	{"TPSU", KOC_opcode, 1, 97 },
	{"WORD", KOC_WDEF, 0, 0 },
	{"WRTC", KOC_opcode, 1, 98 },
	{"WRTD", KOC_opcode, 1, 99 },
	{"WRTE", KOC_opcode, 1, 100 },
	{"ZBRR", KOC_opcode, 2, 101 },
	{"ZBSR", KOC_opcode, 2, 103 },
	{ "", 0, 0, 0 }};

struct opsynt ostab[NUMSYNBLK+1]
	= {
/* invalid 0 */ { 0, 1, 0 },
/* invalid 1 */ { 0xffff, 1, 1 },
/* ADDA 2 */ { ST_ABSOLUTE, 1, 2 },
/* ADDI 3 */ { ST_REGEXP, 1, 3 },
/* ADDR 4 */ { ST_REGEXP, 1, 4 },
/* ADDR 5 */ { ST_REGINDIR, 1, 5 },
/* ADDZ 6 */ { ST_REG, 1, 6 },
/* ANDA 7 */ { ST_ABSOLUTE, 1, 7 },
/* ANDI 8 */ { ST_REGEXP, 1, 8 },
/* ANDR 9 */ { ST_REGEXP, 1, 9 },
/* ANDR 10 */ { ST_REGINDIR, 1, 10 },
/* ANDZ 11 */ { ST_REG, 3, 11 },
/* BCFA 12 */ { ST_CONDEXP, 3, 14 },
/* BCFA 13 */ { ST_CONDINDIR, 3, 17 },
/* BCFR 14 */ { ST_CONDEXP, 3, 20 },
/* BCFR 15 */ { ST_CONDINDIR, 3, 23 },
/* BCTA 16 */ { ST_CONDEXP, 1, 26 },
/* BCTA 17 */ { ST_CONDINDIR, 1, 27 },
/* BCTR 18 */ { ST_CONDEXP, 1, 28 },
/* BCTR 19 */ { ST_CONDINDIR, 1, 29 },
/* BDRA 20 */ { ST_REGEXP, 1, 30 },
/* BDRA 21 */ { ST_REGINDIR, 1, 31 },
/* BDRR 22 */ { ST_REGEXP, 1, 32 },
/* BDRR 23 */ { ST_REGINDIR, 1, 33 },
/* BIRA 24 */ { ST_REGEXP, 1, 34 },
/* BIRA 25 */ { ST_REGINDIR, 1, 35 },
/* BIRR 26 */ { ST_REGEXP, 1, 36 },
/* BIRR 27 */ { ST_REGINDIR, 1, 37 },
/* BRNA 28 */ { ST_REGEXP, 1, 38 },
/* BRNA 29 */ { ST_REGINDIR, 1, 39 },
/* BRNR 30 */ { ST_REGEXP, 1, 40 },
/* BRNR 31 */ { ST_REGINDIR, 1, 41 },
/* BSFA 32 */ { ST_CONDEXP, 3, 42 },
/* BSFA 33 */ { ST_CONDINDIR, 3, 45 },
/* BSFR 34 */ { ST_CONDEXP, 3, 48 },
/* BSFR 35 */ { ST_CONDINDIR, 3, 51 },
/* BSNA 36 */ { ST_REGEXP, 1, 54 },
/* BSNA 37 */ { ST_REGINDIR, 1, 55 },
/* BSNR 38 */ { ST_REGEXP, 1, 56 },
/* BSNR 39 */ { ST_REGINDIR, 1, 57 },
/* BSTA 40 */ { ST_CONDEXP, 1, 58 },
/* BSTA 41 */ { ST_CONDINDIR, 1, 59 },
/* BSTR 42 */ { ST_CONDEXP, 1, 60 },
/* BSTR 43 */ { ST_CONDINDIR, 1, 61 },
/* BSXA 44 */ { ST_BINDEX, 1, 62 },
/* BSXA 45 */ { ST_BINDIRX, 1, 63 },
/* BXA 46 */ { ST_BINDEX, 1, 64 },
/* BXA 47 */ { ST_BINDIRX, 1, 65 },
/* COMA 48 */ { ST_ABSOLUTE, 1, 66 },
/* COMI 49 */ { ST_REGEXP, 1, 67 },
/* COMR 50 */ { ST_REGEXP, 1, 68 },
/* COMR 51 */ { ST_REGINDIR, 1, 69 },
/* COMZ 52 */ { ST_REG, 1, 70 },
/* CPSL 53 */ { ST_EXP, 1, 71 },
/* CPSU 54 */ { ST_EXP, 1, 72 },
/* DAR 55 */ { ST_REGCOMMA, 1, 73 },
/* EORA 56 */ { ST_ABSOLUTE, 1, 74 },
/* EORI 57 */ { ST_REGEXP, 1, 75 },
/* EORR 58 */ { ST_REGEXP, 1, 76 },
/* EORR 59 */ { ST_REGINDIR, 1, 77 },
/* EORZ 60 */ { ST_REG, 1, 78 },
/* HALT 61 */ { ST_INH, 1, 79 },
/* IORA 62 */ { ST_ABSOLUTE, 1, 80 },
/* IORI 63 */ { ST_REGEXP, 1, 81 },
/* IORR 64 */ { ST_REGEXP, 1, 82 },
/* IORR 65 */ { ST_REGINDIR, 1, 83 },
/* IORZ 66 */ { ST_REG, 1, 84 },
/* LODA 67 */ { ST_ABSOLUTE, 1, 85 },
/* LODI 68 */ { ST_REGEXP, 1, 86 },
/* LODR 69 */ { ST_REGEXP, 1, 87 },
/* LODR 70 */ { ST_REGINDIR, 1, 88 },
/* LODZ 71 */ { ST_REG, 4, 89 },
/* LPSL 72 */ { ST_INH, 1, 93 },
/* LPSU 73 */ { ST_INH, 1, 94 },
/* NOP 74 */ { ST_INH, 1, 95 },
/* PPSL 75 */ { ST_EXP, 1, 96 },
/* PPSU 76 */ { ST_EXP, 1, 97 },
/* REDC 77 */ { ST_REGCOMMA, 1, 98 },
/* REDD 78 */ { ST_REGCOMMA, 1, 99 },
/* REDE 79 */ { ST_REGEXP, 1, 100 },
/* RETC 80 */ { ST_COND, 1, 101 },
/* RETE 81 */ { ST_COND, 1, 102 },
/* RRL 82 */ { ST_REGCOMMA, 1, 103 },
/* RRR 83 */ { ST_REGCOMMA, 1, 104 },
/* SPSL 84 */ { ST_INH, 1, 105 },
/* SPSU 85 */ { ST_INH, 1, 106 },
/* STRA 86 */ { ST_ABSOLUTE, 1, 107 },
/* STRR 87 */ { ST_REGEXP, 1, 108 },
/* STRR 88 */ { ST_REGINDIR, 1, 109 },
/* STRZ 89 */ { ST_REG, 3, 110 },
/* SUBA 90 */ { ST_ABSOLUTE, 1, 113 },
/* SUBI 91 */ { ST_REGEXP, 1, 114 },
/* SUBR 92 */ { ST_REGEXP, 1, 115 },
/* SUBR 93 */ { ST_REGINDIR, 1, 116 },
/* SUBZ 94 */ { ST_REG, 1, 117 },
/* TMI 95 */ { ST_REGEXP, 1, 118 },
/* TPSL 96 */ { ST_EXP, 1, 119 },
/* TPSU 97 */ { ST_EXP, 1, 120 },
/* WRTC 98 */ { ST_REGCOMMA, 1, 121 },
/* WRTD 99 */ { ST_REGCOMMA, 1, 122 },
/* WRTE 100 */ { ST_REGEXP, 1, 123 },
/* ZBRR 101 */ { ST_EXP, 1, 124 },
/* ZBRR 102 */ { ST_INDIR, 1, 125 },
/* ZBSR 103 */ { ST_EXP, 1, 126 },
/* ZBSR 104 */ { ST_INDIR, 1, 127 },
	{ 0, 0, 0 } };

struct igel igtab[NUMDIFFOP+1]
	= {
/* invalid 0 */   { 0 , 0, 
		"[Xnullentry" },
/* invalid 1 */   { 0 , 0, 
		"[Xinvalid opcode" },
/* ADDA 2 */   { 0 , 0, 
		"8c.[1#]|;[2=].P.6000&-.dI.[3#]000|x" },
/* ADDI 3 */   { 0 , 0, 
		"84.[1#]|;[2=];" },
/* ADDR 4 */   { 0 , 0, 
		"88.[1#]|;[2=]~.P.6000&-.dIQ.1+-.7R;" },
/* ADDR 5 */   { 0 , 0, 
		"88.[1#]|;[2=]~.P.6000&-.dIQ.1+-.7R.80|;" },
/* ADDZ 6 */   { 0 , 0, 
		"80.[1#]|;" },
/* ANDA 7 */   { 0 , 0, 
		"4c.[1#]|;[2=].P.6000&-.dI.[3#]000|x" },
/* ANDI 8 */   { 0 , 0, 
		"44.[1#]|;[2=];" },
/* ANDR 9 */   { 0 , 0, 
		"48.[1#]|;[2=]~.P.6000&-.dIQ.1+-.7R;" },
/* ANDR 10 */   { 0 , 0, 
		"48.[1#]|;[2=]~.P.6000&-.dIQ.1+-.7R.80|;" },
/* ANDZ 11 */   { REGMASK , REG1, 
		"41;" },
/* ANDZ 12 */   { REGMASK , REG2, 
		"42;" },
/* ANDZ 13 */   { REGMASK , REG3, 
		"43;" },
/* BCFA 14 */   { CONDMASK , COND0, 
		"9c.[1#]|;[2=].fIx" },
/* BCFA 15 */   { CONDMASK , COND1, 
		"9c.[1#]|;[2=].fIx" },
/* BCFA 16 */   { CONDMASK , COND2, 
		"9c.[1#]|;[2=].fIx" },
/* BCFA 17 */   { CONDMASK , COND0, 
		"9c.[1#]|;[2=].fI.8000|x" },
/* BCFA 18 */   { CONDMASK , COND1, 
		"9c.[1#]|;[2=].fI.8000|x" },
/* BCFA 19 */   { CONDMASK , COND2, 
		"9c.[1#]|;[2=].fI.8000|x" },
/* BCFR 20 */   { CONDMASK , COND0, 
		"98.[1#]|;[2=]~.P.6000&-.dIQ.1+-.7R;" },
/* BCFR 21 */   { CONDMASK , COND1, 
		"98.[1#]|;[2=]~.P.6000&-.dIQ.1+-.7R;" },
/* BCFR 22 */   { CONDMASK , COND2, 
		"98.[1#]|;[2=]~.P.6000&-.dIQ.1+-.7R;" },
/* BCFR 23 */   { CONDMASK , COND0, 
		"98.[1#]|;[2=]~.P.6000&-.dIQ.1+-.7R.80|;" },
/* BCFR 24 */   { CONDMASK , COND1, 
		"98.[1#]|;[2=]~.P.6000&-.dIQ.1+-.7R.80|;" },
/* BCFR 25 */   { CONDMASK , COND2, 
		"98.[1#]|;[2=]~.P.6000&-.dIQ.1+-.7R.80|;" },
/* BCTA 26 */   { 0 , 0, 
		"1c.[1#]|;[2=].fIx" },
/* BCTA 27 */   { 0 , 0, 
		"1c.[1#]|;[2=].fI.8000|x" },
/* BCTR 28 */   { 0 , 0, 
		"18.[1#]|;[2=]~.P.6000&-.dIQ.1+-.7R;" },
/* BCTR 29 */   { 0 , 0, 
		"18.[1#]|;[2=]~.P.6000&-.dIQ.1+-.7R.80|;" },
/* BDRA 30 */   { 0 , 0, 
		"fc.[1#]|;[2=].fIx" },
/* BDRA 31 */   { 0 , 0, 
		"fc.[1#]|;[2=].fI.8000|x" },
/* BDRR 32 */   { 0 , 0, 
		"f8.[1#]|;[2=]~.P.6000&-.dIQ.1+-.7R;" },
/* BDRR 33 */   { 0 , 0, 
		"f8.[1#]|;[2=]~.P.6000&-.dIQ.1+-.7R.80|;" },
/* BIRA 34 */   { 0 , 0, 
		"dc.[1#]|;[2=].fIx" },
/* BIRA 35 */   { 0 , 0, 
		"dc.[1#]|;[2=].fI.8000|x" },
/* BIRR 36 */   { 0 , 0, 
		"d8.[1#]|;[2=]~.P.6000&-.dIQ.1+-.7R;" },
/* BIRR 37 */   { 0 , 0, 
		"d8.[1#]|;[2=]~.P.6000&-.dIQ.1+-.7R.80|;" },
/* BRNA 38 */   { 0 , 0, 
		"5c.[1#]|;[2=].fIx" },
/* BRNA 39 */   { 0 , 0, 
		"5c.[1#]|;[2=].fI.8000|x" },
/* BRNR 40 */   { 0 , 0, 
		"58.[1#]|;[2=]~.P.6000&-.dIQ.1+-.7R;" },
/* BRNR 41 */   { 0 , 0, 
		"58.[1#]|;[2=]~.P.6000&-.dIQ.1+-.7R.80|;" },
/* BSFA 42 */   { CONDMASK , COND0, 
		"bc.[1#]|;[2=].fIx" },
/* BSFA 43 */   { CONDMASK , COND1, 
		"bc.[1#]|;[2=].fIx" },
/* BSFA 44 */   { CONDMASK , COND2, 
		"bc.[1#]|;[2=].fIx" },
/* BSFA 45 */   { CONDMASK , COND0, 
		"bc.[1#]|;[2=].fI.8000|x" },
/* BSFA 46 */   { CONDMASK , COND1, 
		"bc.[1#]|;[2=].fI.8000|x" },
/* BSFA 47 */   { CONDMASK , COND2, 
		"bc.[1#]|;[2=].fI.8000|x" },
/* BSFR 48 */   { CONDMASK , COND0, 
		"b8.[1#]|;[2=]~.P.6000&-.dIQ.1+-.7R;" },
/* BSFR 49 */   { CONDMASK , COND1, 
		"b8.[1#]|;[2=]~.P.6000&-.dIQ.1+-.7R;" },
/* BSFR 50 */   { CONDMASK , COND2, 
		"b8.[1#]|;[2=]~.P.6000&-.dIQ.1+-.7R;" },
/* BSFR 51 */   { CONDMASK , COND0, 
		"b8.[1#]|;[2=]~.P.6000&-.dIQ.1+-.7R.80|;" },
/* BSFR 52 */   { CONDMASK , COND1, 
		"b8.[1#]|;[2=]~.P.6000&-.dIQ.1+-.7R.80|;" },
/* BSFR 53 */   { CONDMASK , COND2, 
		"b8.[1#]|;[2=]~.P.6000&-.dIQ.1+-.7R.80|;" },
/* BSNA 54 */   { 0 , 0, 
		"7c.[1#]|;[2=].fIx" },
/* BSNA 55 */   { 0 , 0, 
		"7c.[1#]|;[2=].fI.8000|x" },
/* BSNR 56 */   { 0 , 0, 
		"78.[1#]|;[2=]~.P.6000&-.dIQ.1+-.7R;" },
/* BSNR 57 */   { 0 , 0, 
		"78.[1#]|;[2=]~.P.6000&-.dIQ.1+-.7R.80|;" },
/* BSTA 58 */   { 0 , 0, 
		"3c.[1#]|;[2=].fIx" },
/* BSTA 59 */   { 0 , 0, 
		"3c.[1#]|;[2=].fI.8000|x" },
/* BSTR 60 */   { 0 , 0, 
		"38.[1#]|;[2=]~.P.6000&-.dIQ.1+-.7R;" },
/* BSTR 61 */   { 0 , 0, 
		"38.[1#]|;[2=]~.P.6000&-.dIQ.1+-.7R.80|;" },
/* BSXA 62 */   { REGMASK , REG3, 
		"bf;[2=].fIx" },
/* BSXA 63 */   { REGMASK , REG3, 
		"bf;[2=].fI.8000|x" },
/* BXA 64 */   { REGMASK , REG3, 
		"9f;[2=].fIx" },
/* BXA 65 */   { REGMASK , REG3, 
		"9f;[2=].fI.8000|x" },
/* COMA 66 */   { 0 , 0, 
		"ec.[1#]|;[2=].P.6000&-.dI.[3#]000|x" },
/* COMI 67 */   { 0 , 0, 
		"e4.[1#]|;[2=];" },
/* COMR 68 */   { 0 , 0, 
		"e8.[1#]|;[2=]~.P.6000&-.dIQ.1+-.7R;" },
/* COMR 69 */   { 0 , 0, 
		"e8.[1#]|;[2=]~.P.6000&-.dIQ.1+-.7R.80|;" },
/* COMZ 70 */   { 0 , 0, 
		"e0.[1#]|;" },
/* CPSL 71 */   { 0 , 0, 
		"75;[1=];" },
/* CPSU 72 */   { 0 , 0, 
		"74;[1=];" },
/* DAR 73 */   { 0 , 0, 
		"94.[1#]|;" },
/* EORA 74 */   { 0 , 0, 
		"2c.[1#]|;[2=].P.6000&-.dI.[3#]000|x" },
/* EORI 75 */   { 0 , 0, 
		"24.[1#]|;[2=];" },
/* EORR 76 */   { 0 , 0, 
		"28.[1#]|;[2=]~.P.6000&-.dIQ.1+-.7R;" },
/* EORR 77 */   { 0 , 0, 
		"28.[1#]|;[2=]~.P.6000&-.dIQ.1+-.7R.80|;" },
/* EORZ 78 */   { 0 , 0, 
		"20.[1#]|;" },
/* HALT 79 */   { 0 , 0, 
		"40;" },
/* IORA 80 */   { 0 , 0, 
		"6c.[1#]|;[2=].P.6000&-.dI.[3#]000|x" },
/* IORI 81 */   { 0 , 0, 
		"64.[1#]|;[2=];" },
/* IORR 82 */   { 0 , 0, 
		"68.[1#]|;[2=]~.P.6000&-.dIQ.1+-.7R;" },
/* IORR 83 */   { 0 , 0, 
		"68.[1#]|;[2=]~.P.6000&-.dIQ.1+-.7R.80|;" },
/* IORZ 84 */   { 0 , 0, 
		"60.[1#]|;" },
/* LODA 85 */   { 0 , 0, 
		"0c.[1#]|;[2=].P.6000&-.dI.[3#]000|x" },
/* LODI 86 */   { 0 , 0, 
		"04.[1#]|;[2=];" },
/* LODR 87 */   { 0 , 0, 
		"08.[1#]|;[2=]~.P.6000&-.dIQ.1+-.7R;" },
/* LODR 88 */   { 0 , 0, 
		"08.[1#]|;[2=]~.P.6000&-.dIQ.1+-.7R.80|;" },
/* LODZ 89 */   { REGMASK , REG0, 
		"60;" },
/* LODZ 90 */   { REGMASK , REG1, 
		"01;" },
/* LODZ 91 */   { REGMASK , REG2, 
		"02;" },
/* LODZ 92 */   { REGMASK , REG3, 
		"03;" },
/* LPSL 93 */   { 0 , 0, 
		"93;" },
/* LPSU 94 */   { 0 , 0, 
		"92;" },
/* NOP 95 */   { 0 , 0, 
		"c0;" },
/* PPSL 96 */   { 0 , 0, 
		"77;[1=];" },
/* PPSU 97 */   { 0 , 0, 
		"76;[1=];" },
/* REDC 98 */   { 0 , 0, 
		"30.[1#]|;" },
/* REDD 99 */   { 0 , 0, 
		"70.[1#]|;" },
/* REDE 100 */   { 0 , 0, 
		"54.[1#]|;[2=];" },
/* RETC 101 */   { 0 , 0, 
		"14.[1#]|;" },
/* RETE 102 */   { 0 , 0, 
		"34.[1#]|;" },
/* RRL 103 */   { 0 , 0, 
		"d0.[1#]|;" },
/* RRR 104 */   { 0 , 0, 
		"50.[1#]|;" },
/* SPSL 105 */   { 0 , 0, 
		"13;" },
/* SPSU 106 */   { 0 , 0, 
		"12;" },
/* STRA 107 */   { 0 , 0, 
		"cc.[1#]|;[2=].P.6000&-.dI.[3#]000|x" },
/* STRR 108 */   { 0 , 0, 
		"c8.[1#]|;[2=]~.P.6000&-.dIQ.1+-.7R;" },
/* STRR 109 */   { 0 , 0, 
		"c8.[1#]|;[2=]~.P.6000&-.dIQ.1+-.7R.80|;" },
/* STRZ 110 */   { REGMASK , REG1, 
		"c1;" },
/* STRZ 111 */   { REGMASK , REG2, 
		"c2;" },
/* STRZ 112 */   { REGMASK , REG3, 
		"c3;" },
/* SUBA 113 */   { 0 , 0, 
		"ac.[1#]|;[2=].P.6000&-.dI.[3#]000|x" },
/* SUBI 114 */   { 0 , 0, 
		"a4.[1#]|;[2=];" },
/* SUBR 115 */   { 0 , 0, 
		"a8.[1#]|;[2=]~.P.6000&-.dIQ.1+-.7R;" },
/* SUBR 116 */   { 0 , 0, 
		"a8.[1#]|;[2=]~.P.6000&-.dIQ.1+-.7R.80|;" },
/* SUBZ 117 */   { 0 , 0, 
		"a0.[1#]|;" },
/* TMI 118 */   { 0 , 0, 
		"f4.[1#]|;[2=];" },
/* TPSL 119 */   { 0 , 0, 
		"b5;[1=];" },
/* TPSU 120 */   { 0 , 0, 
		"b4;[1=];" },
/* WRTC 121 */   { 0 , 0, 
		"b0.[1#]|;" },
/* WRTD 122 */   { 0 , 0, 
		"f0.[1#]|;" },
/* WRTE 123 */   { 0 , 0, 
		"d4.[1#]|;[2=];" },
/* ZBRR 124 */   { 0 , 0, 
		"9b;[1=].dI~.fff>.2000_*|.7R;" },
/* ZBRR 125 */   { 0 , 0, 
		"9b;[1=].dI~.fff>.2000_*|.7R.80|;" },
/* ZBSR 126 */   { 0 , 0, 
		"bb;[1=].dI~.fff>.2000_*|.7R;" },
/* ZBSR 127 */   { 0 , 0, 
		"bb;[1=].dI~.fff>.2000_*|.7R.80|;" },
	{ 0,0,""} };
/* end fraptabdef.c */
