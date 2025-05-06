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
FILENAME: 	asz8.y;
WARNINGS: 	"This software is in the public domain.  
		Any prior copyright claims are relinquished.  

		This software is distributed with no warranty whatever.  
		The author takes no responsibility for the consequences 
		of its use.

		Yacc (or Bison) required to compile."  ;
SEE-ALSO: 	asz8.doc,frasmain.c;	
AUTHORS: 	Mark Zenier;
COMPILERS: 	Microport Sys V/AT, ATT Yacc, Turbo C V1.5, Bison (CUG disk 285)
		(previous versions Xenix, Unisoft 68000 Version 7, Sun 3);
*/
/* z8 instruction generation file */
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
	file		critz8.h
	author		Mark Zenier
	description	Selection criteria and syntax type constants for
			the z8 framework assembler
	usage		Unix
	history		October 28, 1987
*/

/* 0000.0000.0000.000x   destination register is in working set */
#define	DSTWORK	0x1

/* 0000.0000.0000.00x0	destination is double register */
#define DSTDBL	0x2

/* 0000.0000.0000.0x00   source register is in working set */
#define SRCWORK	0x4

/* 0000.0000.0000.x000	source is double register */
#define SRCDBL	0x8

/* type flags for symbol table value for registers */
#define REGFLGSHFT	8
#define REGDFLGSH	REGFLGSHFT
#define REGSFLGSH	(REGFLGSHFT -2)
#define REGFLGS		((DSTWORK|DSTDBL)<<REGFLGSHFT)
#define REGDEFWRK	(DSTWORK<<REGFLGSHFT)
#define	REGDEFDBL	(DSTDBL<<REGFLGSHFT)
#define REGBITS		0xff
#define REGWORKBITS	0xf

#define CPU8600	1	/* use z8 register set */
#define CPU8090	2	/* use UPC register set */
#define ST_CEXP 0x1
#define ST_EXP 0x2
#define ST_INH 0x4
#define ST_IR1 0x8
#define ST_IRIM 0x10
#define ST_IRIR 0x20
#define ST_IRR 0x40
#define ST_R1 0x80
#define ST_R2 0x100
#define ST_REXP 0x200
#define ST_RIMM 0x400
#define ST_RIR 0x800
#define ST_RX 0x1000
#define ST_XR 0x2000
#define ST_IMM 0x1
	
	int cpuselect = CPU8600;
	static char	genbdef[] = "[1=];";
	static char	genwdef[] = "[1=]x";
	char ignosyn[] = "[Xinvalid syntax for instruction";
	char ignosel[] = "[Xinvalid operands";
	int	prevregwork = 0;
	int	regloccnt = 0;

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

%type <intv> regdefop regoperand

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
%token <intv> KOC_REG
%token <intv> KOC_RREG
%token <intv> KOC_CPU
%token <intv> KOC_opcode
%token <intv> KOC_srp

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



line 	:	LABEL regdefop regoperand
			{
		if($1 -> seg == SSG_UNDEF)
		{
			$1 -> value = ( $3 & REGBITS )
					| ( $3 & REGDEFWRK )
					| ($2 == 2 ? REGDEFDBL : 0);
			$1 -> seg = SSG_RESV;
			$1 -> tok = REGISTER;

			if($3 & REGDEFWRK) 
			{
				if(($3 & 0xf0) != 0xe0)
					fraerror(
				"invalid working register address");
			}
			else
			{
				switch(cpuselect)
				{
				case CPU8600:
					if( ($3 & REGBITS) > 0x7f &&
						($3 & REGBITS) < 0xf0)
					{
						fraerror(
					"unimplemented register address");
					}
					break;

				case CPU8090:
					if( ($3 & REGBITS) > 0xdf &&
						($3 & REGBITS) < 0xf0)
					{
						fraerror(
					"unimplemented register address");
					}
					break;

				}
			}

			if( ( $1 -> value & REGDEFDBL) && ( $1 -> value & 1) )
				fraerror("double register not on even boundry");

			prtequvalue("C: 0x%x\n",REGBITS & ((int) $1->value));
		}
		else
		{
			fraerror("multiple definition of label");
		}
		prevregwork = $3 & REGDEFWRK;
		regloccnt = ($3 & REGBITS) + $2;
			}
	;

regdefop :	KOC_REG
			{
		$$ = 1;
			}
	|	KOC_RREG
			{
		$$ = 2;
			}
	;

regoperand :	REGISTER
			{
		$$ = $1;
			}
	|	expr
			{
		$$ = 0;
		pevalexpr(0, $1);
		if(evalr[0].seg != SSG_ABS)
		{
			fraerror("noncomputable value for REG");
		}
		else
		{
			if(evalr[0].value >= 0 && evalr[0].value <= 255)
				$$ = evalr[0].value;
			else
				fraerror("value out of range");
		}
			}
	|
			{
		if(regloccnt <= 255)
			$$ = regloccnt | prevregwork ;
		else
		{
			$$ = 0;
			fraerror("register location counter out of range");
		}
			}
	;

line	:	KOC_CPU STRING
			{
		if( ! cpumatch($2))
		{
			fraerror("unknown cpu type, z8 assumed");
			cpuselect = CPU8600;
		}
			}
	;
genline : KOC_opcode  CONDITION ',' expr
			{
		genlocrec(currseg, labelloc);
		evalr[1].value = $2;
		pevalexpr(2, $4);
		locctr += geninstr(findgen($1, ST_CEXP, 0));
			}
	;
genline : KOC_opcode  expr
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1, $2);
		locctr += geninstr(findgen($1, ST_EXP, 0));
			}
	;
genline : KOC_opcode 
			{
		genlocrec(currseg, labelloc);
		locctr += geninstr(findgen($1, ST_INH, 0));
			}
	;
genline : KOC_opcode  '@' REGISTER
			{
		genlocrec(currseg, labelloc);
		evalr[1].value = $3 & REGBITS;
		evalr[2].value = $3 & REGWORKBITS;
		locctr += geninstr(findgen($1, ST_IR1, 
			($3 & REGFLGS) >> REGDFLGSH ));
			}
	;
genline : KOC_opcode  '@' REGISTER ',' '#' expr
			{
		genlocrec(currseg, labelloc);
		evalr[1].value = $3 & REGBITS;
		evalr[3].value = $3 & REGWORKBITS;
		pevalexpr(2, $6);
		locctr += geninstr(findgen($1, ST_IRIM, 
			($3 & REGFLGS) >> REGDFLGSH ));
			}
	;
genline : KOC_opcode  '@' REGISTER ',' '@' REGISTER
			{
		genlocrec(currseg, labelloc);
		evalr[1].value = $3 & REGBITS;
		evalr[2].value = $3 & REGWORKBITS;
		evalr[3].value = $6 & REGBITS;
		evalr[4].value = $6 & REGWORKBITS;
		locctr += geninstr(findgen($1, ST_IRIR, 
			( ($3 & REGFLGS) >> REGDFLGSH ) |
			( ($6 & REGFLGS) >> REGSFLGSH ) ));
			}
	;
genline : KOC_opcode  '@' REGISTER ',' REGISTER
			{
		genlocrec(currseg, labelloc);
		evalr[1].value = $3 & REGBITS;
		evalr[2].value = $3 & REGWORKBITS;
		evalr[3].value = $5 & REGBITS;
		evalr[4].value = $5 & REGWORKBITS;
		locctr += geninstr(findgen($1, ST_IRR, 
			( ($3 & REGFLGS) >> REGDFLGSH ) |
			( ($5 & REGFLGS) >> REGSFLGSH ) ));
			}
	;
genline : KOC_opcode  REGISTER
			{
		genlocrec(currseg, labelloc);
		evalr[1].value = $2 & REGBITS;
		evalr[2].value = $2 & REGWORKBITS;
		locctr += geninstr(findgen($1, ST_R1, 
			($2 & REGFLGS) >> REGDFLGSH ));
			}
	;
genline : KOC_opcode  REGISTER ',' REGISTER
			{
		genlocrec(currseg, labelloc);
		evalr[1].value = $2 & REGBITS;
		evalr[2].value = $2 & REGWORKBITS;
		evalr[3].value = $4 & REGBITS;
		evalr[4].value = $4 & REGWORKBITS;
		locctr += geninstr(findgen($1, ST_R2, 
			( ($2 & REGFLGS) >> REGDFLGSH ) |
			( ($4 & REGFLGS) >> REGSFLGSH ) ));
			}
	;
genline : KOC_opcode  REGISTER ',' expr
			{
		genlocrec(currseg, labelloc);
		evalr[1].value = $2 & REGBITS;
		pevalexpr(2, $4);
		evalr[3].value = $2 & REGWORKBITS;
		locctr += geninstr(findgen($1, ST_REXP,
			($2 & REGFLGS) >> REGDFLGSH ));
			}
	;
genline : KOC_opcode  REGISTER ',' '#' expr
			{
		genlocrec(currseg, labelloc);
		evalr[1].value = $2 & REGBITS;
		evalr[3].value = $2 & REGWORKBITS;
		pevalexpr(2, $5);
		locctr += geninstr(findgen($1, ST_RIMM, 
			($2 & REGFLGS) >> REGDFLGSH ));
			}
	;
genline : KOC_opcode  REGISTER ',' '@' REGISTER
			{
		genlocrec(currseg, labelloc);
		evalr[1].value = $2 & REGBITS;
		evalr[2].value = $2 & REGWORKBITS;
		evalr[3].value = $5 & REGBITS;
		evalr[4].value = $5 & REGWORKBITS;
		locctr += geninstr(findgen($1, ST_RIR, 
			( ($2 & REGFLGS) >> REGDFLGSH ) |
			( ($5 & REGFLGS) >> REGSFLGSH ) ));
			}
	;
genline : KOC_opcode  REGISTER ',' expr '(' REGISTER ')'
			{
		genlocrec(currseg, labelloc);
		evalr[1].value = $2 & REGWORKBITS;
		pevalexpr(2, $4);
		evalr[3].value = $6 & REGWORKBITS;
		locctr += geninstr(findgen($1, ST_RX, 
			( ($2 & REGFLGS) >> REGDFLGSH ) |
			( ($6 & REGFLGS) >> REGSFLGSH ) ));
			}
	;
genline : KOC_opcode  expr '(' REGISTER ')' ',' REGISTER 
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1, $2);
		evalr[2].value = $4 & REGWORKBITS;
		evalr[3].value = $7 & REGWORKBITS;
		locctr += geninstr(findgen($1, ST_XR, 
			( ($4 & REGFLGS) >> REGDFLGSH ) |
			( ($7 & REGFLGS) >> REGSFLGSH ) ));
			}
	;
genline : KOC_srp  '#' expr
			{
		pevalexpr(1, $3);
		if(evalr[1].seg != SSG_ABS)
		{
			fraerror("noncomputable value for SRP");
		}
		else
		{
			switch(( (int) evalr[1].value ) & REGBITS)
			{
			case 0x80:
			case 0x90:
			case 0xa0:
			case 0xb0:
			case 0xc0:
			case 0xd0:
				if(cpuselect == CPU8600)
				{
					fraerror("invalid value for SRP");
					break;
				}
				/* fall thru */
			case 0x00:
			case 0x10:
			case 0x20:
			case 0x30:
			case 0x40:
			case 0x50:
			case 0x60:
			case 0x70:
			case 0xf0:
				genlocrec(currseg, labelloc);
				locctr += geninstr(findgen($1, ST_IMM, 0));
				break;
			default:
				fraerror("invalid value for SRP");
				break;
			}
		}
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

expr	:	'(' REGISTER ')'
		{
	$$ = exprnode(PCCASE_CONS,0,IGP_CONSTANT,0,
		(long) (REGBITS & $2),
		SYMNULL);
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
	reservedsym("high", KEOP_HIGH, 0);
	reservedsym("low", KEOP_LOW, 0);
	reservedsym("mod", KEOP_MOD, 0);
	reservedsym("not", KEOP_NOT, 0);
	reservedsym("or", KEOP_OR, 0);
	reservedsym("shl", KEOP_SHL, 0);
	reservedsym("shr", KEOP_SHR, 0);
	reservedsym("xor", KEOP_XOR, 0);
	reservedsym("AND", KEOP_AND, 0);
	reservedsym("DEFINED", KEOP_DEFINED,0);
	reservedsym("HIGH", KEOP_HIGH, 0);
	reservedsym("LOW", KEOP_LOW, 0);
	reservedsym("MOD", KEOP_MOD, 0);
	reservedsym("NOT", KEOP_NOT, 0);
	reservedsym("OR", KEOP_OR, 0);
	reservedsym("SHL", KEOP_SHL, 0);
	reservedsym("SHR", KEOP_SHR, 0);
	reservedsym("XOR", KEOP_XOR, 0);
	reservedsym("F", CONDITION, 0);
	reservedsym("C", CONDITION, 0x7);
	reservedsym("NC", CONDITION, 0xf);
	reservedsym("Z", CONDITION, 0x6);
	reservedsym("NZ", CONDITION, 0xe);
	reservedsym("PL", CONDITION, 0xd);
	reservedsym("MI", CONDITION, 0x5);
	reservedsym("OV", CONDITION, 0x4);
	reservedsym("NOV", CONDITION, 0xc);
	reservedsym("EQ", CONDITION, 0x6);
	reservedsym("NE", CONDITION, 0xe);
	reservedsym("GE", CONDITION, 0x9);
	reservedsym("LT", CONDITION, 0x1);
	reservedsym("GT", CONDITION, 0xa);
	reservedsym("LE", CONDITION, 0x2);
	reservedsym("UGE", CONDITION, 0xf);
	reservedsym("ULT", CONDITION, 0x7);
	reservedsym("UGT", CONDITION, 0xb);
	reservedsym("ULE", CONDITION, 0x3);
	reservedsym("R0", REGISTER, REGDEFWRK + 0xe0);
	reservedsym("R1", REGISTER, REGDEFWRK + 0xe1);
	reservedsym("R2", REGISTER, REGDEFWRK + 0xe2);
	reservedsym("R3", REGISTER, REGDEFWRK + 0xe3);
	reservedsym("R4", REGISTER, REGDEFWRK + 0xe4);
	reservedsym("R5", REGISTER, REGDEFWRK + 0xe5);
	reservedsym("R6", REGISTER, REGDEFWRK + 0xe6);
	reservedsym("R7", REGISTER, REGDEFWRK + 0xe7);
	reservedsym("R8", REGISTER, REGDEFWRK + 0xe8);
	reservedsym("R9", REGISTER, REGDEFWRK + 0xe9);
	reservedsym("R10", REGISTER, REGDEFWRK + 0xea);
	reservedsym("R11", REGISTER, REGDEFWRK + 0xeb);
	reservedsym("R12", REGISTER, REGDEFWRK + 0xec);
	reservedsym("R13", REGISTER, REGDEFWRK + 0xed);
	reservedsym("R14", REGISTER, REGDEFWRK + 0xee);
	reservedsym("R15", REGISTER, REGDEFWRK + 0xef);
	reservedsym("RR0", REGISTER, REGDEFWRK + REGDEFDBL + 0xe0);
	reservedsym("RR2", REGISTER, REGDEFWRK + REGDEFDBL + 0xe2);
	reservedsym("RR4", REGISTER, REGDEFWRK + REGDEFDBL + 0xe4);
	reservedsym("RR6", REGISTER, REGDEFWRK + REGDEFDBL + 0xe6);
	reservedsym("RR8", REGISTER, REGDEFWRK + REGDEFDBL + 0xe8);
	reservedsym("RR10", REGISTER, REGDEFWRK + REGDEFDBL + 0xea);
	reservedsym("RR12", REGISTER, REGDEFWRK + REGDEFDBL + 0xec);
	reservedsym("RR14", REGISTER, REGDEFWRK + REGDEFDBL + 0xee);
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
		{"86", CPU8600 },
		{"z8", CPU8600 },
		{"Z8", CPU8600 },
		{"upc", CPU8090 },
		{"UPC", CPU8090 },
		{"9", CPU8090 },
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

#define NUMOPCODE 70
#define NUMSYNBLK 102
#define NUMDIFFOP 130

int gnumopcode = NUMOPCODE;

int ophashlnk[NUMOPCODE];

struct opsym optab[NUMOPCODE+1]
	= {
	{"invalid", KOC_opcode, 2, 0 },
	{"ADC", KOC_opcode, 4, 2 },
	{"ADD", KOC_opcode, 4, 6 },
	{"AND", KOC_opcode, 4, 10 },
	{"BYTE", KOC_BDEF, 0, 0 },
	{"CALL", KOC_opcode, 2, 14 },
	{"CCF", KOC_opcode, 1, 16 },
	{"CHARDEF", KOC_CHDEF, 0, 0 },
	{"CHARSET", KOC_CHSET, 0, 0 },
	{"CHARUSE", KOC_CHUSE, 0, 0 },
	{"CHD", KOC_CHDEF, 0, 0 },
	{"CLR", KOC_opcode, 2, 17 },
	{"COM", KOC_opcode, 2, 19 },
	{"CP", KOC_opcode, 4, 21 },
	{"CPU", KOC_CPU, 0, 0 },
	{"DA", KOC_opcode, 2, 25 },
	{"DB", KOC_BDEF, 0, 0 },
	{"DEC", KOC_opcode, 2, 27 },
	{"DECW", KOC_opcode, 2, 29 },
	{"DI", KOC_opcode, 1, 31 },
	{"DJNZ", KOC_opcode, 1, 32 },
	{"DW", KOC_WDEF, 0, 0 },
	{"EI", KOC_opcode, 1, 33 },
	{"ELSE", KOC_ELSE, 0, 0 },
	{"END", KOC_END, 0, 0 },
	{"ENDI", KOC_ENDI, 0, 0 },
	{"EQU", KOC_EQU, 0, 0 },
	{"FCB", KOC_BDEF, 0, 0 },
	{"FCC", KOC_SDEF, 0, 0 },
	{"FDB", KOC_WDEF, 0, 0 },
	{"IF", KOC_IF, 0, 0 },
	{"INC", KOC_opcode, 2, 34 },
	{"INCL", KOC_INCLUDE, 0, 0 },
	{"INCLUDE", KOC_INCLUDE, 0, 0 },
	{"INCW", KOC_opcode, 2, 36 },
	{"IRET", KOC_opcode, 1, 38 },
	{"JP", KOC_opcode, 3, 39 },
	{"JR", KOC_opcode, 2, 42 },
	{"LD", KOC_opcode, 7, 44 },
	{"LDC", KOC_opcode, 2, 51 },
	{"LDCI", KOC_opcode, 1, 53 },
	{"LDE", KOC_opcode, 2, 54 },
	{"LDEI", KOC_opcode, 1, 56 },
	{"NOP", KOC_opcode, 1, 57 },
	{"OR", KOC_opcode, 4, 58 },
	{"ORG", KOC_ORG, 0, 0 },
	{"POP", KOC_opcode, 2, 62 },
	{"PUSH", KOC_opcode, 2, 64 },
	{"RCF", KOC_opcode, 1, 66 },
	{"REG", KOC_REG, 0, 0 },
	{"RESERVE", KOC_RESM, 0, 0 },
	{"RET", KOC_opcode, 1, 67 },
	{"RL", KOC_opcode, 2, 68 },
	{"RLC", KOC_opcode, 2, 70 },
	{"RMB", KOC_RESM, 0, 0 },
	{"RR", KOC_opcode, 2, 72 },
	{"RRC", KOC_opcode, 2, 74 },
	{"RREG", KOC_RREG, 0, 0 },
	{"SBC", KOC_opcode, 4, 76 },
	{"SCF", KOC_opcode, 1, 80 },
	{"SET", KOC_SET, 0, 0 },
	{"SRA", KOC_opcode, 2, 81 },
	{"SRP", KOC_srp, 1, 83 },
	{"STRING", KOC_SDEF, 0, 0 },
	{"SUB", KOC_opcode, 4, 84 },
	{"SWAP", KOC_opcode, 2, 88 },
	{"TCM", KOC_opcode, 4, 90 },
	{"TM", KOC_opcode, 4, 94 },
	{"WORD", KOC_WDEF, 0, 0 },
	{"XOR", KOC_opcode, 4, 98 },
	{ "", 0, 0, 0 }};

struct opsynt ostab[NUMSYNBLK+1]
	= {
/* invalid 0 */ { 0, 1, 0 },
/* invalid 1 */ { 0xffff, 1, 1 },
/* ADC 2 */ { ST_IRIM, 1, 2 },
/* ADC 3 */ { ST_R2, 2, 3 },
/* ADC 4 */ { ST_RIMM, 1, 5 },
/* ADC 5 */ { ST_RIR, 2, 6 },
/* ADD 6 */ { ST_IRIM, 1, 8 },
/* ADD 7 */ { ST_R2, 2, 9 },
/* ADD 8 */ { ST_RIMM, 1, 11 },
/* ADD 9 */ { ST_RIR, 2, 12 },
/* AND 10 */ { ST_IRIM, 1, 14 },
/* AND 11 */ { ST_R2, 2, 15 },
/* AND 12 */ { ST_RIMM, 1, 17 },
/* AND 13 */ { ST_RIR, 2, 18 },
/* CALL 14 */ { ST_EXP, 1, 20 },
/* CALL 15 */ { ST_IR1, 1, 21 },
/* CCF 16 */ { ST_INH, 1, 22 },
/* CLR 17 */ { ST_IR1, 1, 23 },
/* CLR 18 */ { ST_R1, 1, 24 },
/* COM 19 */ { ST_IR1, 1, 25 },
/* COM 20 */ { ST_R1, 1, 26 },
/* CP 21 */ { ST_IRIM, 1, 27 },
/* CP 22 */ { ST_R2, 2, 28 },
/* CP 23 */ { ST_RIMM, 1, 30 },
/* CP 24 */ { ST_RIR, 2, 31 },
/* DA 25 */ { ST_IR1, 1, 33 },
/* DA 26 */ { ST_R1, 1, 34 },
/* DEC 27 */ { ST_IR1, 1, 35 },
/* DEC 28 */ { ST_R1, 1, 36 },
/* DECW 29 */ { ST_IR1, 1, 37 },
/* DECW 30 */ { ST_R1, 1, 38 },
/* DI 31 */ { ST_INH, 1, 39 },
/* DJNZ 32 */ { ST_REXP, 1, 40 },
/* EI 33 */ { ST_INH, 1, 41 },
/* INC 34 */ { ST_IR1, 1, 42 },
/* INC 35 */ { ST_R1, 2, 43 },
/* INCW 36 */ { ST_IR1, 1, 45 },
/* INCW 37 */ { ST_R1, 1, 46 },
/* IRET 38 */ { ST_INH, 1, 47 },
/* JP 39 */ { ST_CEXP, 1, 48 },
/* JP 40 */ { ST_EXP, 1, 49 },
/* JP 41 */ { ST_IR1, 1, 50 },
/* JR 42 */ { ST_CEXP, 1, 51 },
/* JR 43 */ { ST_EXP, 1, 52 },
/* LD 44 */ { ST_IRIM, 1, 53 },
/* LD 45 */ { ST_IRR, 2, 54 },
/* LD 46 */ { ST_R2, 3, 56 },
/* LD 47 */ { ST_RIMM, 2, 59 },
/* LD 48 */ { ST_RIR, 2, 61 },
/* LD 49 */ { ST_RX, 1, 63 },
/* LD 50 */ { ST_XR, 1, 64 },
/* LDC 51 */ { ST_IRR, 1, 65 },
/* LDC 52 */ { ST_RIR, 1, 66 },
/* LDCI 53 */ { ST_IRIR, 2, 67 },
/* LDE 54 */ { ST_IRR, 1, 69 },
/* LDE 55 */ { ST_RIR, 1, 70 },
/* LDEI 56 */ { ST_IRIR, 2, 71 },
/* NOP 57 */ { ST_INH, 1, 73 },
/* OR 58 */ { ST_IRIM, 1, 74 },
/* OR 59 */ { ST_R2, 2, 75 },
/* OR 60 */ { ST_RIMM, 1, 77 },
/* OR 61 */ { ST_RIR, 2, 78 },
/* POP 62 */ { ST_IR1, 1, 80 },
/* POP 63 */ { ST_R1, 1, 81 },
/* PUSH 64 */ { ST_IR1, 1, 82 },
/* PUSH 65 */ { ST_R1, 1, 83 },
/* RCF 66 */ { ST_INH, 1, 84 },
/* RET 67 */ { ST_INH, 1, 85 },
/* RL 68 */ { ST_IR1, 1, 86 },
/* RL 69 */ { ST_R1, 1, 87 },
/* RLC 70 */ { ST_IR1, 1, 88 },
/* RLC 71 */ { ST_R1, 1, 89 },
/* RR 72 */ { ST_IR1, 1, 90 },
/* RR 73 */ { ST_R1, 1, 91 },
/* RRC 74 */ { ST_IR1, 1, 92 },
/* RRC 75 */ { ST_R1, 1, 93 },
/* SBC 76 */ { ST_IRIM, 1, 94 },
/* SBC 77 */ { ST_R2, 2, 95 },
/* SBC 78 */ { ST_RIMM, 1, 97 },
/* SBC 79 */ { ST_RIR, 2, 98 },
/* SCF 80 */ { ST_INH, 1, 100 },
/* SRA 81 */ { ST_IR1, 1, 101 },
/* SRA 82 */ { ST_R1, 1, 102 },
/* SRP 83 */ { ST_IMM, 1, 103 },
/* SUB 84 */ { ST_IRIM, 1, 104 },
/* SUB 85 */ { ST_R2, 2, 105 },
/* SUB 86 */ { ST_RIMM, 1, 107 },
/* SUB 87 */ { ST_RIR, 2, 108 },
/* SWAP 88 */ { ST_IR1, 1, 110 },
/* SWAP 89 */ { ST_R1, 1, 111 },
/* TCM 90 */ { ST_IRIM, 1, 112 },
/* TCM 91 */ { ST_R2, 2, 113 },
/* TCM 92 */ { ST_RIMM, 1, 115 },
/* TCM 93 */ { ST_RIR, 2, 116 },
/* TM 94 */ { ST_IRIM, 1, 118 },
/* TM 95 */ { ST_R2, 2, 119 },
/* TM 96 */ { ST_RIMM, 1, 121 },
/* TM 97 */ { ST_RIR, 2, 122 },
/* XOR 98 */ { ST_IRIM, 1, 124 },
/* XOR 99 */ { ST_R2, 2, 125 },
/* XOR 100 */ { ST_RIMM, 1, 127 },
/* XOR 101 */ { ST_RIR, 2, 128 },
	{ 0, 0, 0 } };

struct igel igtab[NUMDIFFOP+1]
	= {
/* invalid 0 */   { 0 , 0, 
		"[Xnullentry" },
/* invalid 1 */   { 0 , 0, 
		"[Xinvalid opcode" },
/* ADC 2 */   { 0 , 0, 
		"17;[1#];[2=];" },
/* ADC 3 */   { SRCWORK+DSTWORK , SRCWORK+DSTWORK, 
		"12;[2#4#];" },
/* ADC 4 */   { 0 , 0, 
		"14;[3#];[1#];" },
/* ADC 5 */   { 0 , 0, 
		"16;[1#];[2=];" },
/* ADC 6 */   { SRCWORK+DSTWORK , SRCWORK+DSTWORK, 
		"13;[2#4#];" },
/* ADC 7 */   { 0 , 0, 
		"15;[3#];[1#];" },
/* ADD 8 */   { 0 , 0, 
		"07;[1#];[2=];" },
/* ADD 9 */   { SRCWORK+DSTWORK , SRCWORK+DSTWORK, 
		"02;[2#4#];" },
/* ADD 10 */   { 0 , 0, 
		"04;[3#];[1#];" },
/* ADD 11 */   { 0 , 0, 
		"06;[1#];[2=];" },
/* ADD 12 */   { SRCWORK+DSTWORK , SRCWORK+DSTWORK, 
		"03;[2#4#];" },
/* ADD 13 */   { 0 , 0, 
		"05;[3#];[1#];" },
/* AND 14 */   { 0 , 0, 
		"57;[1#];[2=];" },
/* AND 15 */   { SRCWORK+DSTWORK , SRCWORK+DSTWORK, 
		"52;[2#4#];" },
/* AND 16 */   { 0 , 0, 
		"54;[3#];[1#];" },
/* AND 17 */   { 0 , 0, 
		"56;[1#];[2=];" },
/* AND 18 */   { SRCWORK+DSTWORK , SRCWORK+DSTWORK, 
		"53;[2#4#];" },
/* AND 19 */   { 0 , 0, 
		"55;[3#];[1#];" },
/* CALL 20 */   { 0 , 0, 
		"d6;[1=]x" },
/* CALL 21 */   { DSTDBL , DSTDBL, 
		"d4;[1#];" },
/* CCF 22 */   { 0 , 0, 
		"ef;" },
/* CLR 23 */   { 0 , 0, 
		"b1;[1#];" },
/* CLR 24 */   { 0 , 0, 
		"b0;[1#];" },
/* COM 25 */   { 0 , 0, 
		"61;[1#];" },
/* COM 26 */   { 0 , 0, 
		"60;[1#];" },
/* CP 27 */   { 0 , 0, 
		"a7;[1#];[2=];" },
/* CP 28 */   { SRCWORK+DSTWORK , SRCWORK+DSTWORK, 
		"a2;[2#4#];" },
/* CP 29 */   { 0 , 0, 
		"a4;[3#];[1#];" },
/* CP 30 */   { 0 , 0, 
		"a6;[1#];[2=];" },
/* CP 31 */   { SRCWORK+DSTWORK , SRCWORK+DSTWORK, 
		"a3;[2#4#];" },
/* CP 32 */   { 0 , 0, 
		"a5;[3#];[1#];" },
/* DA 33 */   { 0 , 0, 
		"41;[1#];" },
/* DA 34 */   { 0 , 0, 
		"40;[1#];" },
/* DEC 35 */   { 0 , 0, 
		"01;[1#];" },
/* DEC 36 */   { 0 , 0, 
		"00;[1#];" },
/* DECW 37 */   { 0 , 0, 
		"81;[1#];" },
/* DECW 38 */   { DSTDBL , DSTDBL, 
		"80;[1#];" },
/* DI 39 */   { 0 , 0, 
		"8f;" },
/* DJNZ 40 */   { DSTWORK , DSTWORK, 
		"[3#]a;[2=].Q.1+-r" },
/* EI 41 */   { 0 , 0, 
		"9f;" },
/* INC 42 */   { 0 , 0, 
		"21;[1#];" },
/* INC 43 */   { DSTWORK , DSTWORK, 
		"[2#]e;" },
/* INC 44 */   { 0 , 0, 
		"20;[1#];" },
/* INCW 45 */   { 0 , 0, 
		"a1;[1#];" },
/* INCW 46 */   { DSTDBL , DSTDBL, 
		"a0;[1#];" },
/* IRET 47 */   { 0 , 0, 
		"bf;" },
/* JP 48 */   { 0 , 0, 
		"[1#]d;[2=]x" },
/* JP 49 */   { 0 , 0, 
		"8d;[1=]x" },
/* JP 50 */   { DSTDBL , DSTDBL, 
		"30;[1#];" },
/* JR 51 */   { 0 , 0, 
		"[1#]b;[2=].Q.1+-r" },
/* JR 52 */   { 0 , 0, 
		"8b;[1=].Q.1+-r" },
/* LD 53 */   { 0 , 0, 
		"e7;[1#];[2=];" },
/* LD 54 */   { DSTWORK+SRCWORK , DSTWORK+SRCWORK, 
		"f3;[2#4#];" },
/* LD 55 */   { 0 , 0, 
		"f5;[3#];[1#];" },
/* LD 56 */   { DSTWORK , DSTWORK, 
		"[2#]8;[3#];" },
/* LD 57 */   { SRCWORK , SRCWORK, 
		"[4#]9;[1#];" },
/* LD 58 */   { 0 , 0, 
		"e4;[3#];[1#];" },
/* LD 59 */   { DSTWORK , DSTWORK, 
		"[3#]c;[2=];" },
/* LD 60 */   { 0 , 0, 
		"e6;[1#];[2=];" },
/* LD 61 */   { DSTWORK+SRCWORK , DSTWORK+SRCWORK, 
		"e3;[2#4#];" },
/* LD 62 */   { 0 , 0, 
		"e5;[3#];[1#];" },
/* LD 63 */   { DSTWORK+SRCWORK , DSTWORK+SRCWORK, 
		"c7;[1#3#];[2=];" },
/* LD 64 */   { DSTWORK+SRCWORK , DSTWORK+SRCWORK, 
		"d7;[3#2#];[1=];" },
/* LDC 65 */   { DSTWORK+SRCWORK , DSTWORK+SRCWORK, 
		"d2;[4#2#];" },
/* LDC 66 */   { DSTWORK+SRCWORK , DSTWORK+SRCWORK, 
		"c2;[2#4#];" },
/* LDCI 67 */   { SRCDBL+DSTDBL+DSTWORK+SRCWORK , SRCDBL+DSTWORK+SRCWORK, 
		"c3;[2#4#];" },
/* LDCI 68 */   { SRCDBL+DSTDBL+DSTWORK+SRCWORK , DSTDBL+DSTWORK+SRCWORK, 
		"d3;[4#2#];" },
/* LDE 69 */   { DSTWORK+SRCWORK , DSTWORK+SRCWORK, 
		"92;[4#2#];" },
/* LDE 70 */   { DSTWORK+SRCWORK , DSTWORK+SRCWORK, 
		"82;[2#4#];" },
/* LDEI 71 */   { SRCDBL+DSTDBL+DSTWORK+SRCWORK , SRCDBL+DSTWORK+SRCWORK, 
		"83;[2#4#];" },
/* LDEI 72 */   { SRCDBL+DSTDBL+DSTWORK+SRCWORK , DSTDBL+DSTWORK+SRCWORK, 
		"93;[4#2#];" },
/* NOP 73 */   { 0 , 0, 
		"ff;" },
/* OR 74 */   { 0 , 0, 
		"47;[1#];[2=];" },
/* OR 75 */   { SRCWORK+DSTWORK , SRCWORK+DSTWORK, 
		"42;[2#4#];" },
/* OR 76 */   { 0 , 0, 
		"44;[3#];[1#];" },
/* OR 77 */   { 0 , 0, 
		"46;[1#];[2=];" },
/* OR 78 */   { SRCWORK+DSTWORK , SRCWORK+DSTWORK, 
		"43;[2#4#];" },
/* OR 79 */   { 0 , 0, 
		"45;[3#];[1#];" },
/* POP 80 */   { 0 , 0, 
		"51;[1#];" },
/* POP 81 */   { 0 , 0, 
		"50;[1#];" },
/* PUSH 82 */   { 0 , 0, 
		"71;[1#];" },
/* PUSH 83 */   { 0 , 0, 
		"70;[1#];" },
/* RCF 84 */   { 0 , 0, 
		"cf;" },
/* RET 85 */   { 0 , 0, 
		"af;" },
/* RL 86 */   { 0 , 0, 
		"91;[1#];" },
/* RL 87 */   { 0 , 0, 
		"90;[1#];" },
/* RLC 88 */   { 0 , 0, 
		"11;[1#];" },
/* RLC 89 */   { 0 , 0, 
		"10;[1#];" },
/* RR 90 */   { 0 , 0, 
		"e1;[1#];" },
/* RR 91 */   { 0 , 0, 
		"e0;[1#];" },
/* RRC 92 */   { 0 , 0, 
		"c1;[1#];" },
/* RRC 93 */   { 0 , 0, 
		"c0;[1#];" },
/* SBC 94 */   { 0 , 0, 
		"37;[1#];[2=];" },
/* SBC 95 */   { SRCWORK+DSTWORK , SRCWORK+DSTWORK, 
		"32;[2#4#];" },
/* SBC 96 */   { 0 , 0, 
		"34;[3#];[1#];" },
/* SBC 97 */   { 0 , 0, 
		"36;[1#];[2=];" },
/* SBC 98 */   { SRCWORK+DSTWORK , SRCWORK+DSTWORK, 
		"33;[2#4#];" },
/* SBC 99 */   { 0 , 0, 
		"35;[3#];[1#];" },
/* SCF 100 */   { 0 , 0, 
		"df;" },
/* SRA 101 */   { 0 , 0, 
		"d1;[1#];" },
/* SRA 102 */   { 0 , 0, 
		"d0;[1#];" },
/* SRP 103 */   { 0 , 0, 
		"31;[1=];" },
/* SUB 104 */   { 0 , 0, 
		"27;[1#];[2=];" },
/* SUB 105 */   { SRCWORK+DSTWORK , SRCWORK+DSTWORK, 
		"22;[2#4#];" },
/* SUB 106 */   { 0 , 0, 
		"24;[3#];[1#];" },
/* SUB 107 */   { 0 , 0, 
		"26;[1#];[2=];" },
/* SUB 108 */   { SRCWORK+DSTWORK , SRCWORK+DSTWORK, 
		"23;[2#4#];" },
/* SUB 109 */   { 0 , 0, 
		"25;[3#];[1#];" },
/* SWAP 110 */   { 0 , 0, 
		"f1;[1#];" },
/* SWAP 111 */   { 0 , 0, 
		"f0;[1#];" },
/* TCM 112 */   { 0 , 0, 
		"67;[1#];[2=];" },
/* TCM 113 */   { SRCWORK+DSTWORK , SRCWORK+DSTWORK, 
		"62;[2#4#];" },
/* TCM 114 */   { 0 , 0, 
		"64;[3#];[1#];" },
/* TCM 115 */   { 0 , 0, 
		"66;[1#];[2=];" },
/* TCM 116 */   { SRCWORK+DSTWORK , SRCWORK+DSTWORK, 
		"63;[2#4#];" },
/* TCM 117 */   { 0 , 0, 
		"65;[3#];[1#];" },
/* TM 118 */   { 0 , 0, 
		"77;[1#];[2=];" },
/* TM 119 */   { SRCWORK+DSTWORK , SRCWORK+DSTWORK, 
		"72;[2#4#];" },
/* TM 120 */   { 0 , 0, 
		"74;[3#];[1#];" },
/* TM 121 */   { 0 , 0, 
		"76;[1#];[2=];" },
/* TM 122 */   { SRCWORK+DSTWORK , SRCWORK+DSTWORK, 
		"73;[2#4#];" },
/* TM 123 */   { 0 , 0, 
		"75;[3#];[1#];" },
/* XOR 124 */   { 0 , 0, 
		"b7;[1#];[2=];" },
/* XOR 125 */   { SRCWORK+DSTWORK , SRCWORK+DSTWORK, 
		"b2;[2#4#];" },
/* XOR 126 */   { 0 , 0, 
		"b4;[3#];[1#];" },
/* XOR 127 */   { 0 , 0, 
		"b6;[1#];[2=];" },
/* XOR 128 */   { SRCWORK+DSTWORK , SRCWORK+DSTWORK, 
		"b3;[2#4#];" },
/* XOR 129 */   { 0 , 0, 
		"b5;[3#];[1#];" },
	{ 0,0,""} };
/* end fraptabdef.c */
