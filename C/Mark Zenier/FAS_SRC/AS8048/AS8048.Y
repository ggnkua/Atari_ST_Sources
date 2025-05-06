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
FILENAME: 	as8048.y;
WARNINGS: 	"This software is in the public domain.  
		Any prior copyright claims are relinquished.  

		This software is distributed with no warranty whatever.  
		The author takes no responsibility for the consequences 
		of its use.

		Yacc (or Bison) required to compile."  ;
SEE-ALSO: 	as8048.doc,frasmain.c;	
AUTHORS: 	Mark Zenier;
COMPILERS: 	Microport Sys V/AT, ATT Yacc, Turbo C V1.5, Bison (CUG disk 285)
		(previous versions Xenix, Unisoft 68000 Version 7, Sun 3);
*/
/* 8048  et al  instruction generation file */
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

/* 0000.0000.0000.xxxx  interrupt selections */
#define	ISELMASK	0xf
#define	ISELI		0x1
#define	ISELTCNTI	0x2
#define	ISELDMA		0x4
#define	ISELFLAGS	0x8
/* 0000.0000.0000.xxxx  accum-flag selections */
#define	AFSELMASK	0xf
#define	AFSELA		0x1
#define	AFSELC		0x2
#define	AFSELF0		0x4
#define	AFSELF1		0x8
/* 0000.0000.xxxx.0000  low port selections */
#define	PSELMASK	0xf0
#define	PSELBUS		0x10
#define	PSELP1		0x20
#define	PSELP2		0x40
#define	PSELDBB		0x80
/* 0000.00xx.xxxx.0000  misc register selections */
#define	MSELMASK	0x3f0
#define	MSELPSW		0x10
#define	MSELT		0x20
#define	MSELCNT		0x40
#define	MSELTCNT	0x80
#define	MSELCLK		0x100
#define	MSELSTS		0x200
/* 0000.xx00.0000.0000  ram size */
#define	RAMSIZEMASK	0xc00
#define	RAMSIZE64	0x400
#define	RAMSIZE128	0x800
#define	RAMSIZE256	0xc00
/* xxx0.0000.0000.0000  instruction set variations */
#define	INSTIDL		0x8000
#define	INSTNOT41	0x4000
#define	INST41		0x2000
#define	CPU8048		INSTNOT41|RAMSIZE64
#define	CPU8049		INSTNOT41|RAMSIZE128
#define	CPU8050		INSTNOT41|RAMSIZE256
#define	CPU80C48	INSTNOT41|INSTIDL|RAMSIZE64
#define	CPU80C49	INSTNOT41|INSTIDL|RAMSIZE128
#define	CPU80C50	INSTNOT41|INSTIDL|RAMSIZE256
#define	CPU8041		INST41|RAMSIZE64
#define	CPU8042		INST41|RAMSIZE128
#define ST_AF 0x1
#define ST_REG 0x2
#define ST_EXPR 0x4
#define ST_AR 0x8
#define ST_AINDIRR 0x10
#define ST_AIMMED 0x20
#define ST_INDIRA 0x40
#define ST_INDIRR 0x80
#define ST_REGEXP 0x100
#define ST_PA2 0x200
#define ST_PA4 0x400
#define ST_P2A 0x800
#define ST_P4A 0x1000
#define ST_P2IMMED 0x2000
#define ST_INH 0x1
#define ST_INT 0x2
#define ST_RSELC 0x4
#define ST_MSELC 0x8
#define ST_MREG 0x10
#define ST_MAR 0x1
#define ST_MAINDIRA 0x2
#define ST_MAINDIRR 0x4
#define ST_MAIMMED 0x8
#define ST_MAMR 0x10
#define ST_MMRA 0x20
#define ST_MRA 0x40
#define ST_MRIMMED 0x80
#define ST_MINDIRRA 0x100
#define ST_MINDIRRIM 0x200
	
	static char	genbdef[] = "[1=];";
	static char	genwdef[] = "[1=]y"; /* x for normal, y for byte rev */
	char ignosyn[] = "[Xinvalid syntax for instruction";
	char ignosel[] = "[Xinvalid operands/illegal instruction for cpu";
	int	cpuselect = CPU80C50;

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

%token <intv> RSELC
%token <intv> MSELC
%token <intv> INT
%token <intv> AF
%token <intv> REG
%token <intv> P02
%token <intv> P47
%token <intv> MREG
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
%token <intv> KOC_REG
%token <intv> KOC_opcode
%token <intv> KOC_misc
%token <intv> KOC_mov

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
			fraerror("unknown cpu type, 80C50 assumed");
			cpuselect = CPU80C50;
		}
			}
	;
line :		LABEL KOC_REG expr 
		{
			if($1 -> seg == SSG_UNDEF
			   || $1 -> seg == SSG_SET)
			{
				pevalexpr(0, $3);
				if(evalr[0].seg == SSG_ABS)
				{
					switch(cpuselect & RAMSIZEMASK)
					{
					case RAMSIZE64:
						if(evalr[0].value < 0 ||
						   evalr[0].value > 63)
						{
							fraerror(
					"unimplemented register address");
						}
						break;

					case RAMSIZE128:
						if(evalr[0].value < 0 ||
						   evalr[0].value > 127)
						{
							fraerror(
					"unimplemented register address");
						}
						break;

					case RAMSIZE256:
						if(evalr[0].value < 0 ||
						   evalr[0].value > 255)
						{
							fraerror(
					"unimplemented register address");
						}
						break;

					default:
						break;
					}

					$1 -> seg = SSG_SET;
					$1 -> value = evalr[0].value;
					prtequvalue("C: 0x%lx\n",
						evalr[0].value);
				}
				else
				{
					fraerror(
				"noncomputable expression for REGISTER SET");
				}
			}
			else
			{
				fraerror(
			"cannot change symbol value with REGISTER SET");
			}
		}
	;
genline : KOC_opcode  AF
			{
		genlocrec(currseg, labelloc);
		locctr += geninstr(findgen($1, ST_AF,  $2|cpuselect));
			}
	;
genline : KOC_opcode  REG
			{
		genlocrec(currseg, labelloc);
		evalr[1].value = $2;
		locctr += geninstr(findgen($1, ST_REG,  cpuselect));
			}
	;
genline : KOC_opcode  expr
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1, $2);
		locctr += geninstr(findgen($1, ST_EXPR,  cpuselect));
			}
	;
genline : KOC_opcode  AF ',' REG
			{
		genlocrec(currseg, labelloc);
		evalr[1].value = $4;
		locctr += geninstr(findgen($1, ST_AR,  $2|cpuselect));
			}
	;
genline : KOC_opcode  AF ',' '@' REG
			{
		genlocrec(currseg, labelloc);
		if($5 > 1)
		{
			fraerror("invalid register for indirect mode");
			evalr[1].value = 0;
		}
		else
		{
			evalr[1].value = $5;
		}
		locctr += geninstr(findgen($1, ST_AINDIRR,  $2|cpuselect));
			}
	;
genline : KOC_opcode  AF ',' '#' expr
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1, $5);
		locctr += geninstr(findgen($1, ST_AIMMED,  $2|cpuselect));
			}
	;
genline : KOC_opcode  '@' AF
			{
		genlocrec(currseg, labelloc);
		locctr += geninstr(findgen($1, ST_INDIRA,  $3|cpuselect));
			}
	;
genline : KOC_opcode  '@' REG
			{
		genlocrec(currseg, labelloc);
		if($3 > 1)
		{
			fraerror("invalid register for indirect mode");
			evalr[1].value = 0;
		}
		else
		{
			evalr[1].value = $3;
		}
		locctr += geninstr(findgen($1, ST_INDIRR,  cpuselect));
			}
	;
genline : KOC_opcode  REG ',' expr
			{
		genlocrec(currseg, labelloc);
		evalr[1].value = $2;
		pevalexpr(2, $4);
		locctr += geninstr(findgen($1, ST_REGEXP,  cpuselect));
			}
	;
genline : KOC_opcode  AF ',' P02
			{
		genlocrec(currseg, labelloc);
		locctr += geninstr(findgen($1, ST_PA2,  $2 | $4|cpuselect));
			}
	;
genline : KOC_opcode  AF ',' P47 
			{
		genlocrec(currseg, labelloc);
		evalr[1].value = $4;
		locctr += geninstr(findgen($1, ST_PA4,  $2|cpuselect));
			}
	;
genline : KOC_opcode  P02 ',' AF
			{
		genlocrec(currseg, labelloc);
		locctr += geninstr(findgen($1, ST_P2A,  $2 | $4|cpuselect));
			}
	;
genline : KOC_opcode  P47 ',' AF
			{
		genlocrec(currseg, labelloc);
		evalr[1].value = $2;
		locctr += geninstr(findgen($1, ST_P4A,  $4|cpuselect));
			}
	;
genline : KOC_opcode  P02 ',' '#' expr
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1, $5);
		locctr += geninstr(findgen($1, ST_P2IMMED,  $2|cpuselect));
			}
	;
genline : KOC_misc 
			{
		genlocrec(currseg, labelloc);
		locctr += geninstr(findgen($1, ST_INH,  cpuselect));
			}
	;
genline : KOC_misc  INT
			{
		genlocrec(currseg, labelloc);
		locctr += geninstr(findgen($1, ST_INT,  $2|cpuselect));
			}
	;
genline : KOC_misc  RSELC
			{
		genlocrec(currseg, labelloc);
		evalr[1].value = $2 << 4;
		locctr += geninstr(findgen($1, ST_RSELC,  cpuselect));
			}
	;
genline : KOC_misc  MSELC
			{
		genlocrec(currseg, labelloc);
		evalr[1].value = $2 << 4;
		locctr += geninstr(findgen($1, ST_MSELC,  cpuselect));
			}
	;
genline : KOC_misc  MREG
			{
		genlocrec(currseg, labelloc);
		locctr += geninstr(findgen($1, ST_MREG,  $2|cpuselect));
			}
	;
genline : KOC_mov  AF ',' REG
			{
		genlocrec(currseg, labelloc);
		evalr[1].value = $4;
		locctr += geninstr(findgen($1, ST_MAR,  $2|cpuselect));
			}
	;
genline : KOC_mov  AF ',' '@' AF
			{
		genlocrec(currseg, labelloc);
		locctr += geninstr(findgen($1, ST_MAINDIRA,  $2|$5|cpuselect));
			}
	;
genline : KOC_mov  AF ',' '@' REG
			{
		genlocrec(currseg, labelloc);
		if($5 > 1)
		{
			fraerror("invalid register for indirect mode");
			evalr[1].value = 0;
		}
		else
		{
			evalr[1].value = $5;
		}
		locctr += geninstr(findgen($1, ST_MAINDIRR,  $2|cpuselect));
			}
	;
genline : KOC_mov  AF ',' '#' expr
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1, $5);
		locctr += geninstr(findgen($1, ST_MAIMMED,  $2|cpuselect));
			}
	;
genline : KOC_mov  AF ',' MREG
			{
		genlocrec(currseg, labelloc);
		locctr += geninstr(findgen($1, ST_MAMR,  $2 | $4|cpuselect));
			}
	;
genline : KOC_mov  MREG ',' AF
			{
		genlocrec(currseg, labelloc);
		locctr += geninstr(findgen($1, ST_MMRA,  $2 | $4|cpuselect));
			}
	;
genline : KOC_mov  REG ',' AF
			{
		genlocrec(currseg, labelloc);
		evalr[1].value = $2;
		locctr += geninstr(findgen($1, ST_MRA,  $4|cpuselect));
			}
	;
genline : KOC_mov  REG ',' '#' expr
			{
		genlocrec(currseg, labelloc);
		evalr[1].value = $2;
		pevalexpr(2, $5);
		locctr += geninstr(findgen($1, ST_MRIMMED,  cpuselect));
			}
	;
genline : KOC_mov  '@' REG ',' AF
			{
		genlocrec(currseg, labelloc);
		if($3 > 1)
		{
			fraerror("invalid register for indirect mode");
			evalr[1].value = 0;
		}
		else
		{
			evalr[1].value = $3;
		}
		locctr += geninstr(findgen($1, ST_MINDIRRA,  $5|cpuselect));
			}
	;
genline : KOC_mov  '@' REG ',' '#' expr
			{
		genlocrec(currseg, labelloc);
		if($3 > 1)
		{
			fraerror("invalid register for indirect mode");
			evalr[1].value = 0;
		}
		else
		{
			evalr[1].value = $3;
		}
		pevalexpr(2, $6);
		locctr += geninstr(findgen($1, ST_MINDIRRIM,  cpuselect));
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
	reservedsym("RB0", RSELC, 0);
	reservedsym("RB1", RSELC, 1);
	reservedsym("MB0", MSELC, 2);
	reservedsym("MB1", MSELC, 3);
	reservedsym("I", INT, ISELI);
	reservedsym("TCNTI", INT, ISELTCNTI);
	reservedsym("A", AF, AFSELA);
	reservedsym("C", AF, AFSELC);
	reservedsym("F0", AF, AFSELF0);
	reservedsym("F1", AF, AFSELF1);
	reservedsym("R0", REG, 0);
	reservedsym("R1", REG, 1);
	reservedsym("R2", REG, 2);
	reservedsym("R3", REG, 3);
	reservedsym("R4", REG, 4);
	reservedsym("R5", REG, 5);
	reservedsym("R6", REG, 6);
	reservedsym("R7", REG, 7);
	reservedsym("BUS", P02, PSELBUS);
	reservedsym("P1", P02, PSELP1);
	reservedsym("P2", P02, PSELP2);
	reservedsym("P4", P47, 0);
	reservedsym("P5", P47, 1);
	reservedsym("P6", P47, 2);
	reservedsym("P7", P47, 3);
	reservedsym("PSW", MREG, MSELPSW);
	reservedsym("T", MREG, MSELT);
	reservedsym("CNT", MREG, MSELCNT);
	reservedsym("TCNT", MREG, MSELTCNT);
	reservedsym("CLK", MREG, MSELCLK);
	reservedsym("DMA", INT, ISELDMA);
	reservedsym("FLAGS", INT, ISELFLAGS);
	reservedsym("DBB", P02, PSELDBB);
	reservedsym("STS", MREG, MSELSTS);
	reservedsym("rb0", RSELC, 0);
	reservedsym("rb1", RSELC, 1);
	reservedsym("mb0", MSELC, 2);
	reservedsym("mb1", MSELC, 3);
	reservedsym("i", INT, ISELI);
	reservedsym("tcnti", INT, ISELTCNTI);
	reservedsym("a", AF, AFSELA);
	reservedsym("c", AF, AFSELC);
	reservedsym("f0", AF, AFSELF0);
	reservedsym("f1", AF, AFSELF1);
	reservedsym("r0", REG, 0);
	reservedsym("r1", REG, 1);
	reservedsym("r2", REG, 2);
	reservedsym("r3", REG, 3);
	reservedsym("r4", REG, 4);
	reservedsym("r5", REG, 5);
	reservedsym("r6", REG, 6);
	reservedsym("r7", REG, 7);
	reservedsym("bus", P02, PSELBUS);
	reservedsym("p1", P02, PSELP1);
	reservedsym("p2", P02, PSELP2);
	reservedsym("p4", P47, 0);
	reservedsym("p5", P47, 1);
	reservedsym("p6", P47, 2);
	reservedsym("p7", P47, 3);
	reservedsym("psw", MREG, MSELPSW);
	reservedsym("t", MREG, MSELT);
	reservedsym("cnt", MREG, MSELCNT);
	reservedsym("tcnt", MREG, MSELTCNT);
	reservedsym("clk", MREG, MSELCLK);
	reservedsym("dma", INT, ISELDMA);
	reservedsym("flags", INT, ISELFLAGS);
	reservedsym("dbb", P02, PSELDBB);
	reservedsym("sts", MREG, MSELSTS);

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
		{"C48", CPU80C48},
		{"c48", CPU80C48},
		{"C35", CPU80C48},
		{"c35", CPU80C48},
		{"C49", CPU80C49},
		{"c49", CPU80C49},
		{"C39", CPU80C49},
		{"c39", CPU80C49},
		{"C50", CPU80C50},
		{"c50", CPU80C50},
		{"C40", CPU80C50},
		{"c40", CPU80C50},
		{"48", CPU8048},
		{"35", CPU8048},
		{"49", CPU8049},
		{"39", CPU8049},
		{"50", CPU8050},
		{"40", CPU8050},
		{"41", CPU8041},
		{"42", CPU8042},
		{ "" , 0 }
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

#define NUMOPCODE 91
#define NUMSYNBLK 94
#define NUMDIFFOP 116

int gnumopcode = NUMOPCODE;

int ophashlnk[NUMOPCODE];

struct opsym optab[NUMOPCODE+1]
	= {
	{"invalid", KOC_opcode, 2, 0 },
	{"ADD", KOC_opcode, 3, 2 },
	{"ADDC", KOC_opcode, 3, 5 },
	{"ANL", KOC_opcode, 4, 8 },
	{"ANLD", KOC_opcode, 1, 12 },
	{"BYTE", KOC_BDEF, 0, 0 },
	{"CALL", KOC_opcode, 1, 13 },
	{"CHARDEF", KOC_CHDEF, 0, 0 },
	{"CHARSET", KOC_CHSET, 0, 0 },
	{"CHARUSE", KOC_CHUSE, 0, 0 },
	{"CHD", KOC_CHDEF, 0, 0 },
	{"CLR", KOC_opcode, 1, 14 },
	{"CPL", KOC_opcode, 1, 15 },
	{"CPU", KOC_CPU, 0, 0 },
	{"DA", KOC_opcode, 1, 16 },
	{"DB", KOC_BDEF, 0, 0 },
	{"DEC", KOC_opcode, 2, 17 },
	{"DIS", KOC_misc, 1, 19 },
	{"DJNZ", KOC_opcode, 1, 20 },
	{"DW", KOC_WDEF, 0, 0 },
	{"ELSE", KOC_ELSE, 0, 0 },
	{"EN", KOC_misc, 1, 21 },
	{"END", KOC_END, 0, 0 },
	{"ENDI", KOC_ENDI, 0, 0 },
	{"ENT0", KOC_misc, 1, 22 },
	{"EQU", KOC_EQU, 0, 0 },
	{"FCB", KOC_BDEF, 0, 0 },
	{"FCC", KOC_SDEF, 0, 0 },
	{"FDB", KOC_WDEF, 0, 0 },
	{"HALT", KOC_misc, 1, 23 },
	{"IDL", KOC_misc, 1, 24 },
	{"IF", KOC_IF, 0, 0 },
	{"IN", KOC_opcode, 1, 25 },
	{"INC", KOC_opcode, 3, 26 },
	{"INCL", KOC_INCLUDE, 0, 0 },
	{"INCLUDE", KOC_INCLUDE, 0, 0 },
	{"INS", KOC_opcode, 1, 29 },
	{"JB0", KOC_opcode, 1, 30 },
	{"JB1", KOC_opcode, 1, 31 },
	{"JB2", KOC_opcode, 1, 32 },
	{"JB3", KOC_opcode, 1, 33 },
	{"JB4", KOC_opcode, 1, 34 },
	{"JB5", KOC_opcode, 1, 35 },
	{"JB6", KOC_opcode, 1, 36 },
	{"JB7", KOC_opcode, 1, 37 },
	{"JC", KOC_opcode, 1, 38 },
	{"JF0", KOC_opcode, 1, 39 },
	{"JF1", KOC_opcode, 1, 40 },
	{"JMP", KOC_opcode, 1, 41 },
	{"JMPP", KOC_opcode, 1, 42 },
	{"JNC", KOC_opcode, 1, 43 },
	{"JNI", KOC_opcode, 1, 44 },
	{"JNIBF", KOC_opcode, 1, 45 },
	{"JNT0", KOC_opcode, 1, 46 },
	{"JNT1", KOC_opcode, 1, 47 },
	{"JNZ", KOC_opcode, 1, 48 },
	{"JOBF", KOC_opcode, 1, 49 },
	{"JT0", KOC_opcode, 1, 50 },
	{"JT1", KOC_opcode, 1, 51 },
	{"JTF", KOC_opcode, 1, 52 },
	{"JZ", KOC_opcode, 1, 53 },
	{"MOV", KOC_mov, 9, 54 },
	{"MOVD", KOC_opcode, 2, 63 },
	{"MOVP3", KOC_mov, 1, 65 },
	{"MOVP", KOC_mov, 1, 66 },
	{"MOVX", KOC_mov, 2, 67 },
	{"NOP", KOC_misc, 1, 69 },
	{"ORG", KOC_ORG, 0, 0 },
	{"ORL", KOC_opcode, 4, 70 },
	{"ORLD", KOC_opcode, 1, 74 },
	{"OUT", KOC_opcode, 1, 75 },
	{"OUTL", KOC_opcode, 1, 76 },
	{"REGISTER", KOC_REG, 0, 0 },
	{"RESERVE", KOC_RESM, 0, 0 },
	{"RET", KOC_misc, 1, 77 },
	{"RETR", KOC_misc, 1, 78 },
	{"RL", KOC_opcode, 1, 79 },
	{"RLC", KOC_opcode, 1, 80 },
	{"RMB", KOC_RESM, 0, 0 },
	{"RR", KOC_opcode, 1, 81 },
	{"RRC", KOC_opcode, 1, 82 },
	{"SEL", KOC_misc, 2, 83 },
	{"SET", KOC_SET, 0, 0 },
	{"STOP", KOC_misc, 1, 85 },
	{"STRING", KOC_SDEF, 0, 0 },
	{"STRT", KOC_misc, 1, 86 },
	{"SWAP", KOC_opcode, 1, 87 },
	{"WORD", KOC_WDEF, 0, 0 },
	{"XCH", KOC_opcode, 2, 88 },
	{"XCHD", KOC_opcode, 1, 90 },
	{"XRL", KOC_opcode, 3, 91 },
	{ "", 0, 0, 0 }};

struct opsynt ostab[NUMSYNBLK+1]
	= {
/* invalid 0 */ { 0, 1, 0 },
/* invalid 1 */ { 0xffff, 1, 1 },
/* ADD 2 */ { ST_AIMMED, 1, 2 },
/* ADD 3 */ { ST_AINDIRR, 1, 3 },
/* ADD 4 */ { ST_AR, 1, 4 },
/* ADDC 5 */ { ST_AIMMED, 1, 5 },
/* ADDC 6 */ { ST_AINDIRR, 1, 6 },
/* ADDC 7 */ { ST_AR, 1, 7 },
/* ANL 8 */ { ST_AIMMED, 1, 8 },
/* ANL 9 */ { ST_AINDIRR, 1, 9 },
/* ANL 10 */ { ST_AR, 1, 10 },
/* ANL 11 */ { ST_P2IMMED, 3, 11 },
/* ANLD 12 */ { ST_P4A, 1, 14 },
/* CALL 13 */ { ST_EXPR, 1, 15 },
/* CLR 14 */ { ST_AF, 4, 16 },
/* CPL 15 */ { ST_AF, 4, 20 },
/* DA 16 */ { ST_AF, 1, 24 },
/* DEC 17 */ { ST_AF, 1, 25 },
/* DEC 18 */ { ST_REG, 1, 26 },
/* DIS 19 */ { ST_INT, 2, 27 },
/* DJNZ 20 */ { ST_REGEXP, 1, 29 },
/* EN 21 */ { ST_INT, 4, 30 },
/* ENT0 22 */ { ST_MREG, 1, 34 },
/* HALT 23 */ { ST_INH, 1, 35 },
/* IDL 24 */ { ST_INH, 1, 36 },
/* IN 25 */ { ST_PA2, 3, 37 },
/* INC 26 */ { ST_AF, 1, 40 },
/* INC 27 */ { ST_INDIRR, 1, 41 },
/* INC 28 */ { ST_REG, 1, 42 },
/* INS 29 */ { ST_PA2, 1, 43 },
/* JB0 30 */ { ST_EXPR, 1, 44 },
/* JB1 31 */ { ST_EXPR, 1, 45 },
/* JB2 32 */ { ST_EXPR, 1, 46 },
/* JB3 33 */ { ST_EXPR, 1, 47 },
/* JB4 34 */ { ST_EXPR, 1, 48 },
/* JB5 35 */ { ST_EXPR, 1, 49 },
/* JB6 36 */ { ST_EXPR, 1, 50 },
/* JB7 37 */ { ST_EXPR, 1, 51 },
/* JC 38 */ { ST_EXPR, 1, 52 },
/* JF0 39 */ { ST_EXPR, 1, 53 },
/* JF1 40 */ { ST_EXPR, 1, 54 },
/* JMP 41 */ { ST_EXPR, 1, 55 },
/* JMPP 42 */ { ST_INDIRA, 1, 56 },
/* JNC 43 */ { ST_EXPR, 1, 57 },
/* JNI 44 */ { ST_EXPR, 1, 58 },
/* JNIBF 45 */ { ST_EXPR, 1, 59 },
/* JNT0 46 */ { ST_EXPR, 1, 60 },
/* JNT1 47 */ { ST_EXPR, 1, 61 },
/* JNZ 48 */ { ST_EXPR, 1, 62 },
/* JOBF 49 */ { ST_EXPR, 1, 63 },
/* JT0 50 */ { ST_EXPR, 1, 64 },
/* JT1 51 */ { ST_EXPR, 1, 65 },
/* JTF 52 */ { ST_EXPR, 1, 66 },
/* JZ 53 */ { ST_EXPR, 1, 67 },
/* MOV 54 */ { ST_MAIMMED, 1, 68 },
/* MOV 55 */ { ST_MAINDIRR, 1, 69 },
/* MOV 56 */ { ST_MAMR, 2, 70 },
/* MOV 57 */ { ST_MAR, 1, 72 },
/* MOV 58 */ { ST_MINDIRRA, 1, 73 },
/* MOV 59 */ { ST_MINDIRRIM, 1, 74 },
/* MOV 60 */ { ST_MMRA, 3, 75 },
/* MOV 61 */ { ST_MRA, 1, 78 },
/* MOV 62 */ { ST_MRIMMED, 1, 79 },
/* MOVD 63 */ { ST_P4A, 1, 80 },
/* MOVD 64 */ { ST_PA4, 1, 81 },
/* MOVP3 65 */ { ST_MAINDIRA, 1, 82 },
/* MOVP 66 */ { ST_MAINDIRA, 1, 83 },
/* MOVX 67 */ { ST_MAINDIRR, 1, 84 },
/* MOVX 68 */ { ST_MINDIRRA, 1, 85 },
/* NOP 69 */ { ST_INH, 1, 86 },
/* ORL 70 */ { ST_AIMMED, 1, 87 },
/* ORL 71 */ { ST_AINDIRR, 1, 88 },
/* ORL 72 */ { ST_AR, 1, 89 },
/* ORL 73 */ { ST_P2IMMED, 3, 90 },
/* ORLD 74 */ { ST_P4A, 1, 93 },
/* OUT 75 */ { ST_P2A, 1, 94 },
/* OUTL 76 */ { ST_P2A, 3, 95 },
/* RET 77 */ { ST_INH, 1, 98 },
/* RETR 78 */ { ST_INH, 1, 99 },
/* RL 79 */ { ST_AF, 1, 100 },
/* RLC 80 */ { ST_AF, 1, 101 },
/* RR 81 */ { ST_AF, 1, 102 },
/* RRC 82 */ { ST_AF, 1, 103 },
/* SEL 83 */ { ST_MSELC, 1, 104 },
/* SEL 84 */ { ST_RSELC, 1, 105 },
/* STOP 85 */ { ST_MREG, 1, 106 },
/* STRT 86 */ { ST_MREG, 2, 107 },
/* SWAP 87 */ { ST_AF, 1, 109 },
/* XCH 88 */ { ST_AINDIRR, 1, 110 },
/* XCH 89 */ { ST_AR, 1, 111 },
/* XCHD 90 */ { ST_AINDIRR, 1, 112 },
/* XRL 91 */ { ST_AIMMED, 1, 113 },
/* XRL 92 */ { ST_AINDIRR, 1, 114 },
/* XRL 93 */ { ST_AR, 1, 115 },
	{ 0, 0, 0 } };

struct igel igtab[NUMDIFFOP+1]
	= {
/* invalid 0 */   { 0 , 0, 
		"[Xnullentry" },
/* invalid 1 */   { 0 , 0, 
		"[Xinvalid opcode" },
/* ADD 2 */   { AFSELMASK , AFSELA, 
		"03;[1=];" },
/* ADD 3 */   { AFSELMASK , AFSELA, 
		"60.[1#]|;" },
/* ADD 4 */   { AFSELMASK , AFSELA, 
		"68.[1#]|;" },
/* ADDC 5 */   { AFSELMASK , AFSELA, 
		"13;[1=];" },
/* ADDC 6 */   { AFSELMASK , AFSELA, 
		"70.[1#]|;" },
/* ADDC 7 */   { AFSELMASK , AFSELA, 
		"78.[1#]|;" },
/* ANL 8 */   { AFSELMASK , AFSELA, 
		"53;[1=];" },
/* ANL 9 */   { AFSELMASK , AFSELA, 
		"50.[1#]|;" },
/* ANL 10 */   { AFSELMASK , AFSELA, 
		"58.[1#]|;" },
/* ANL 11 */   { INSTNOT41|PSELMASK , PSELBUS|INSTNOT41, 
		"98;[1=];" },
/* ANL 12 */   { PSELMASK , PSELP1, 
		"99;[1=];" },
/* ANL 13 */   { PSELMASK , PSELP2, 
		"9a;[1=];" },
/* ANLD 14 */   { AFSELMASK , AFSELA, 
		"9c.[1#]|;" },
/* CALL 15 */   { 0 , 0, 
		"[1=].P.f800&-.bI~.3}.e0&.14|;!.ff&;" },
/* CLR 16 */   { AFSELMASK , AFSELA, 
		"27;" },
/* CLR 17 */   { AFSELMASK , AFSELC, 
		"97;" },
/* CLR 18 */   { AFSELMASK , AFSELF0, 
		"85;" },
/* CLR 19 */   { AFSELMASK , AFSELF1, 
		"a5;" },
/* CPL 20 */   { AFSELMASK , AFSELA, 
		"37;" },
/* CPL 21 */   { AFSELMASK , AFSELC, 
		"a7;" },
/* CPL 22 */   { AFSELMASK , AFSELF0, 
		"95;" },
/* CPL 23 */   { AFSELMASK , AFSELF1, 
		"b5;" },
/* DA 24 */   { AFSELMASK , AFSELA, 
		"57;" },
/* DEC 25 */   { AFSELMASK , AFSELA, 
		"07;" },
/* DEC 26 */   { 0 , 0, 
		"c8.[1#]|;" },
/* DIS 27 */   { ISELMASK , ISELI, 
		"15;" },
/* DIS 28 */   { ISELMASK , ISELTCNTI, 
		"35;" },
/* DJNZ 29 */   { 0 , 0, 
		"e8.[1#]|;[2=].Q.ff00&-.8I;" },
/* EN 30 */   { ISELMASK , ISELI, 
		"05;" },
/* EN 31 */   { ISELMASK , ISELTCNTI, 
		"25;" },
/* EN 32 */   { INST41|ISELMASK , ISELDMA|INST41, 
		"e5;" },
/* EN 33 */   { INST41|ISELMASK , ISELFLAGS|INST41, 
		"f5;" },
/* ENT0 34 */   { INSTNOT41|MSELMASK , MSELCLK|INSTNOT41, 
		"75;" },
/* HALT 35 */   { INSTIDL , INSTIDL, 
		"01;" },
/* IDL 36 */   { INSTIDL , INSTIDL, 
		"01;" },
/* IN 37 */   { INST41|PSELMASK|AFSELMASK , PSELDBB|AFSELA|INST41, 
		"22;" },
/* IN 38 */   { PSELMASK|AFSELMASK , PSELP1|AFSELA, 
		"09;" },
/* IN 39 */   { PSELMASK|AFSELMASK , PSELP2|AFSELA, 
		"0a;" },
/* INC 40 */   { AFSELMASK , AFSELA, 
		"17;" },
/* INC 41 */   { 0 , 0, 
		"10.[1#]|;" },
/* INC 42 */   { 0 , 0, 
		"18.[1#]|;" },
/* INS 43 */   { INSTNOT41|PSELMASK|AFSELMASK , PSELBUS|AFSELA|INSTNOT41, 
		"08;" },
/* JB0 44 */   { 0 , 0, 
		"12;[1=].Q.ff00&-.8I;" },
/* JB1 45 */   { 0 , 0, 
		"32;[1=].Q.ff00&-.8I;" },
/* JB2 46 */   { 0 , 0, 
		"52;[1=].Q.ff00&-.8I;" },
/* JB3 47 */   { 0 , 0, 
		"72;[1=].Q.ff00&-.8I;" },
/* JB4 48 */   { 0 , 0, 
		"92;[1=].Q.ff00&-.8I;" },
/* JB5 49 */   { 0 , 0, 
		"b2;[1=].Q.ff00&-.8I;" },
/* JB6 50 */   { 0 , 0, 
		"d2;[1=].Q.ff00&-.8I;" },
/* JB7 51 */   { 0 , 0, 
		"f2;[1=].Q.ff00&-.8I;" },
/* JC 52 */   { 0 , 0, 
		"f6;[1=].Q.ff00&-.8I;" },
/* JF0 53 */   { 0 , 0, 
		"b6;[1=].Q.ff00&-.8I;" },
/* JF1 54 */   { 0 , 0, 
		"76;[1=].Q.ff00&-.8I;" },
/* JMP 55 */   { 0 , 0, 
		"[1=].P.f800&-.bI~.3}.e0&.04|;!.ff&;" },
/* JMPP 56 */   { AFSELMASK , AFSELA, 
		"b3;" },
/* JNC 57 */   { 0 , 0, 
		"e6;[1=].Q.ff00&-.8I;" },
/* JNI 58 */   { INSTNOT41 , INSTNOT41, 
		"86;[1=].Q.ff00&-.8I;" },
/* JNIBF 59 */   { INST41 , INST41, 
		"d6;[1=].Q.ff00&-.8I;" },
/* JNT0 60 */   { 0 , 0, 
		"26;[1=].Q.ff00&-.8I;" },
/* JNT1 61 */   { 0 , 0, 
		"46;[1=].Q.ff00&-.8I;" },
/* JNZ 62 */   { 0 , 0, 
		"96;[1=].Q.ff00&-.8I;" },
/* JOBF 63 */   { INST41 , INST41, 
		"86;[1=].Q.ff00&-.8I;" },
/* JT0 64 */   { 0 , 0, 
		"36;[1=].Q.ff00&-.8I;" },
/* JT1 65 */   { 0 , 0, 
		"56;[1=].Q.ff00&-.8I;" },
/* JTF 66 */   { 0 , 0, 
		"16;[1=].Q.ff00&-.8I;" },
/* JZ 67 */   { 0 , 0, 
		"c6;[1=].Q.ff00&-.8I;" },
/* MOV 68 */   { AFSELMASK , AFSELA, 
		"23;[1=];" },
/* MOV 69 */   { AFSELMASK , AFSELA, 
		"f0.[1#]|;" },
/* MOV 70 */   { AFSELMASK|MSELMASK , AFSELA|MSELPSW, 
		"c7;" },
/* MOV 71 */   { AFSELMASK|MSELMASK , AFSELA|MSELT, 
		"42;" },
/* MOV 72 */   { AFSELMASK , AFSELA, 
		"f8.[1#]|;" },
/* MOV 73 */   { AFSELMASK , AFSELA, 
		"a0.[1#]|;" },
/* MOV 74 */   { 0 , 0, 
		"b0.[1#]|;[2=];" },
/* MOV 75 */   { AFSELMASK|MSELMASK , AFSELA|MSELPSW, 
		"d7;" },
/* MOV 76 */   { INST41|AFSELMASK|MSELMASK , AFSELA|MSELSTS|INST41, 
		"50;" },
/* MOV 77 */   { AFSELMASK|MSELMASK , AFSELA|MSELT, 
		"62;" },
/* MOV 78 */   { AFSELMASK , AFSELA, 
		"a8.[1#]|;" },
/* MOV 79 */   { 0 , 0, 
		"b8.[1#]|;[2=];" },
/* MOVD 80 */   { AFSELMASK , AFSELA, 
		"3c.[1#]|;" },
/* MOVD 81 */   { AFSELMASK , AFSELA, 
		"0c.[1#]|;" },
/* MOVP3 82 */   { AFSELMASK , AFSELA, 
		"e3;" },
/* MOVP 83 */   { AFSELMASK , AFSELA, 
		"a3;" },
/* MOVX 84 */   { INSTNOT41|AFSELMASK , AFSELA|INSTNOT41, 
		"80.[1#]|;" },
/* MOVX 85 */   { INSTNOT41|AFSELMASK , AFSELA|INSTNOT41, 
		"90.[1#]|;" },
/* NOP 86 */   { 0 , 0, 
		"00;" },
/* ORL 87 */   { AFSELMASK , AFSELA, 
		"43;[1=];" },
/* ORL 88 */   { AFSELMASK , AFSELA, 
		"40.[1#]|;" },
/* ORL 89 */   { AFSELMASK , AFSELA, 
		"48.[1#]|;" },
/* ORL 90 */   { INSTNOT41|PSELMASK , PSELBUS|INSTNOT41, 
		"88;[1=];" },
/* ORL 91 */   { PSELMASK , PSELP1, 
		"89;[1=];" },
/* ORL 92 */   { PSELMASK , PSELP2, 
		"8a;[1=];" },
/* ORLD 93 */   { AFSELMASK , AFSELA, 
		"8c.[1#]|;" },
/* OUT 94 */   { INST41|AFSELMASK|PSELMASK , AFSELA|PSELDBB|INST41, 
		"02;" },
/* OUTL 95 */   { INSTNOT41|AFSELMASK|PSELMASK , AFSELA|PSELBUS|INSTNOT41, 
		"02;" },
/* OUTL 96 */   { AFSELMASK|PSELMASK , AFSELA|PSELP1, 
		"39;" },
/* OUTL 97 */   { AFSELMASK|PSELMASK , AFSELA|PSELP2, 
		"3a;" },
/* RET 98 */   { 0 , 0, 
		"83;" },
/* RETR 99 */   { 0 , 0, 
		"93;" },
/* RL 100 */   { AFSELMASK , AFSELA, 
		"e7;" },
/* RLC 101 */   { AFSELMASK , AFSELA, 
		"f7;" },
/* RR 102 */   { AFSELMASK , AFSELA, 
		"77;" },
/* RRC 103 */   { AFSELMASK , AFSELA, 
		"67;" },
/* SEL 104 */   { INSTNOT41 , INSTNOT41, 
		"c5.[1#]|;" },
/* SEL 105 */   { 0 , 0, 
		"c5.[1#]|;" },
/* STOP 106 */   { MSELMASK , MSELTCNT, 
		"65;" },
/* STRT 107 */   { MSELMASK , MSELCNT, 
		"45;" },
/* STRT 108 */   { MSELMASK , MSELT, 
		"55;" },
/* SWAP 109 */   { AFSELMASK , AFSELA, 
		"47;" },
/* XCH 110 */   { AFSELMASK , AFSELA, 
		"20.[1#]|;" },
/* XCH 111 */   { AFSELMASK , AFSELA, 
		"28.[1#]|;" },
/* XCHD 112 */   { AFSELMASK , AFSELA, 
		"30.[1#]|;" },
/* XRL 113 */   { AFSELMASK , AFSELA, 
		"d3;[1=];" },
/* XRL 114 */   { AFSELMASK , AFSELA, 
		"d0.[1#]|;" },
/* XRL 115 */   { AFSELMASK , AFSELA, 
		"d8.[1#]|;" },
	{ 0,0,""} };
/* end fraptabdef.c */
