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
FILENAME: 	asz80.y;
WARNINGS: 	"This software is in the public domain.  
		Any prior copyright claims are relinquished.  

		This software is distributed with no warranty whatever.  
		The author takes no responsibility for the consequences 
		of its use.

		Yacc (or Bison) required to compile."  ;
SEE-ALSO: 	asz80.doc,frasmain.c;	
AUTHORS: 	Mark Zenier;
COMPILERS: 	Microport Sys V/AT, ATT Yacc, Turbo C V1.5, Bison (CUG disk 285)
		(previous versions Xenix, Unisoft 68000 Version 7, Sun 3);
*/
/*   framework crossassembler for z80 + and minus */
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
	file		critz80.h
	author		Mark Zenier
	description	selection critera and syntax type defines for
			the z80 frasm (framework cross assembler)
	usage		Unix
	history		January 22, 1988
*/

/* xxxx.0000.0000.0000  cpu mask selection for all instructions */

#define	CPUMASK		0xf000

#define	CPU8080		0x1000
#define	CPU8085		0x3000
#define	CPUZ80		0x7000
#define	CPU64180	0xf000

#define	TS8080PLUS	0x1000
#define	TS8085PLUS	0x2000
#define	TSZ80PLUS	0x4000
#define	TS64180		0x8000

/* 0000.0000.0xxx.xxxx  double register select bits for B02, CC01, LD02, LD03,
			LD05, LD06, LD07, LD08, LD09, LD10, LD12, N03, N04, N05,
			N07, N11 */
#define DRMASK 0x7f
#define	DRIX	1
#define	DRIY	2
#define	DRSP	4
#define	DRHL	8
#define	DRDE	0x10
#define	DRBC	0x20
#define	DRAF	0x40

/* 0000.0xxx.x000.0000  destination select bits */
#define	DRDESTMASK	0x780
#define	DRDESTSP	0x80
#define DRDESTHL	0x100
#define DRDESTIX	0x200
#define DRDESTIY	0x300

/* 0000.x000.0000.0000  register is accum for LD02, LD10 */

#define REGISA	0x800

/* register field values for instructions */

#define	VALREGA	7
#define	VALREGB	0
#define	VALREGC	1
#define	VALREGD	2
#define	VALREGE	3
#define	VALREGH	4
#define	VALREGL	5

#define ST_B01 0x1
#define ST_B02 0x2
#define ST_B03 0x4
/* 0000.0000.xxxx.xxxx  condition select */
#define CCSELMASK	0x00ff
#define CCSELNZ	0x0001
#define CCSELZ	0x0002
#define CCSELNC	0x0004
#define CCSELC	0x0008
#define CCSELPO	0x0010
#define CCSELPE	0x0020
#define CCSELP	0x0040
#define CCSELM	0x0080
#define ST_CC01 0x1
#define ST_CC02 0x2
#define ST_CC03 0x4
#define ST_CC04 0x8
#define ST_CC05 0x10
#define ST_EX01 0x1
#define EXMASK	0xf
/*	0000.0000.0000.00xx   */
#define EX2AF		1
#define EX2HL		2
/*	0000.0000.0000.xx00   */
#define EX1AF		4
#define EX1DE		8
#define ST_EX02 0x2
#define ST_IM01 0x1
/* 0000.0000.0000.0xxx   interrupt mode select bits */
#define	INTSETMASK	7
#define INTSETMODE0	1
#define INTSETMODE1	2
#define INTSETMODE2	4
#define ST_IO01 0x1
#define ST_IO02 0x2
#define ST_IO03 0x4
#define ST_IO04 0x8
#define ST_LD01 0x1
#define ST_LD02 0x2
#define ST_LD03 0x4
#define ST_LD04 0x8
#define ST_LD05 0x10
#define ST_LD06 0x20
#define ST_LD07 0x40
#define ST_LD08 0x80
#define ST_LD09 0x100
#define ST_LD10 0x200
#define ST_LD11 0x400
#define ST_LD12 0x800
#define ST_LD13 0x1000
#define ST_LD14 0x2000
#define ST_LD15 0x4000
/* 0000.0000.0000.00xx */
#define SPECIALRMASK	3
#define SPECIALIR	1
#define SPECIALRR	2
#define ST_LD16 0x8000
#define ST_N01 0x1
#define ST_N02 0x2
#define ST_N04 0x4
#define ST_N05 0x8
#define ST_N06 0x10
#define ST_N07 0x20
#define ST_N08 0x40
#define ST_N09 0x80
#define ST_N10 0x100
#define ST_N11 0x200
#define ST_N12 0x400
#define ST_R01 0x1
	
	unsigned int cpuselect = CPU64180;
	static char	genbdef[] = "[1=];";
	static char	genwdef[] = "[1=]y";
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
	struct { int indsel, exp; } indexstruc;
}
%token <intv> SREGI
%token <intv> SREGR
%token <intv> REGA
%token <intv> REGB
%token <intv> REGC
%token <intv> REGD
%token <intv> REGE
%token <intv> REGH
%token <intv> REGL
%token <intv> DREGAF
%token <intv> DREGBC
%token <intv> DREGDE
%token <intv> DREGHL
%token <intv> DREGIX
%token <intv> DREGIY
%token <intv> DREGSP
%token <intv> CONDZ
%token <intv> CONDNZ
%token <intv> CONDNC
%token <intv> CONDPE
%token <intv> CONDPO
%token <intv> CONDP
%token <intv> CONDM

%type <intv> dreg condition reg8 specialr ixoriy topexpr
%type <indexstruc> index
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
%token <intv> KOC_bit
%token <intv> KOC_ccop
%token <intv> KOC_exop
%token <intv> KOC_intmode
%token <intv> KOC_ioop
%token <intv> KOC_ldop
%token <intv> KOC_opcode
%token <intv> KOC_restart

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
			fraerror("unknown cpu type, 64180 assumed");
			cpuselect = CPU64180;
		}
			}
	;
genline : KOC_bit  expr ',' '(' DREGHL ')' 
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1,$2);
		if(evalr[1].seg != SSG_ABS || 
			evalr[1].value < 0 ||
			evalr[1].value > 7)
		{
			evalr[1].value = 0;
			fraerror("impossible bit number");
		}
		evalr[1].value <<= 3;
		locctr += geninstr(findgen($1, ST_B01, cpuselect));
			}
	;
genline : KOC_bit  expr ',' index 
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1,$2);
		if(evalr[1].seg != SSG_ABS || 
			evalr[1].value < 0 ||
			evalr[1].value > 7)
		{
			evalr[1].value = 0;
			fraerror("impossible bit number");
		}
		evalr[1].value <<= 3;
		pevalexpr(2, $4.exp);
		locctr += geninstr(findgen($1, ST_B02, cpuselect|$4.indsel));
			}
	;
genline : KOC_bit  expr ',' reg8 
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1,$2);
		if(evalr[1].seg != SSG_ABS || 
			evalr[1].value < 0 ||
			evalr[1].value > 7)
		{
			evalr[1].value = 0;
			fraerror("impossible bit number");
		}
		evalr[1].value = (evalr[1].value << 3) | $4;
		locctr += geninstr(findgen($1, ST_B03, cpuselect));
			}
	;
genline : KOC_ccop  '(' dreg ')' 
			{
		genlocrec(currseg, labelloc);
		locctr += geninstr(findgen($1, ST_CC01, cpuselect|$3));
			}
	;
genline : KOC_ccop  condition ',' expr 
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1, $4);
		locctr += geninstr(findgen($1, ST_CC02, cpuselect|$2));
			}
	;
genline : KOC_ccop  expr 
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1,$2);
		locctr += geninstr(findgen($1, ST_CC03, cpuselect));
			}
	;
genline : KOC_ccop  condition  
			{
		genlocrec(currseg, labelloc);
		locctr += geninstr(findgen($1, ST_CC04, cpuselect|$2));
			}
	;
genline : KOC_ccop  
			{
		genlocrec(currseg, labelloc);
		locctr += geninstr(findgen($1, ST_CC05, cpuselect));
			}
	;
genline : KOC_exop  dreg ',' dreg 
			{
		int selc = 0;

		genlocrec(currseg, labelloc);
		switch($2)
		{
		case DRAF:
			selc = EX1AF;
			break;
		case DRDE:
			selc = EX1DE;
		default:
			break;
		}

		switch($4)
		{
		case DRAF:
			selc |= EX2AF;
			break;
		case DRHL:
			selc |= EX2HL;
		default:
			break;
		}
		locctr += geninstr(findgen($1, ST_EX01, cpuselect|selc));
			}
	;
genline : KOC_exop  '(' DREGSP ')' ',' dreg 
			{
		genlocrec(currseg, labelloc);
		locctr += geninstr(findgen($1, ST_EX02, cpuselect|$6));
			}
	;
genline : KOC_intmode  expr 
			{
		int selc = 0;

		genlocrec(currseg, labelloc);
		pevalexpr(1, $2);
		if(evalr[1].seg != SSG_ABS ||
		   evalr[1].value < 0 ||
		   evalr[1].value > 2)
		{
			fraerror("invalid interrupt mode");
		}
		else
		{
			selc = 1 << ((int) evalr[1].value);
		}
		locctr += geninstr(findgen($1, ST_IM01, cpuselect|selc));
			}
	;
genline : KOC_ioop  '(' topexpr ')' ',' reg8 
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1, $3);
		evalr[2].value = $6 << 3;
		locctr += geninstr(findgen($1, ST_IO01, cpuselect
			| ($6 == VALREGA ? REGISA : 0)));
			}
	;
genline : KOC_ioop  '(' REGC ')' ',' reg8 
			{
		genlocrec(currseg, labelloc);
		evalr[1].value = $6 << 3;
		locctr += geninstr(findgen($1, ST_IO02, cpuselect));
			}
	;
genline : KOC_ioop  reg8 ',' '(' topexpr ')' 
			{
		genlocrec(currseg, labelloc);
		evalr[1].value = $2 << 3;
		pevalexpr(2, $5);
		locctr += geninstr(findgen($1, ST_IO03, cpuselect
			| ($2 == VALREGA ? REGISA : 0)));
			}
	;
genline : KOC_ioop  reg8 ',' '(' REGC ')' 
			{
		genlocrec(currseg, labelloc);
		evalr[1].value = $2 << 3;
		locctr += geninstr(findgen($1, ST_IO04, cpuselect));
			}
	;
genline : KOC_ldop  '(' dreg ')' ',' topexpr 
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1, $6);
		locctr += geninstr(findgen($1, ST_LD01, cpuselect|$3));
			}
	;
genline : KOC_ldop  '(' dreg ')' ',' reg8 
			{
		genlocrec(currseg, labelloc);
		evalr[1].value = $6;
		locctr += geninstr(findgen($1, ST_LD02, cpuselect
			| $3 | ($6 == VALREGA ? REGISA : 0)));
			}
	;
genline : KOC_ldop  '(' topexpr ')' ',' dreg 
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1, $3);
		locctr += geninstr(findgen($1, ST_LD03, cpuselect|$6));
			}
	;
genline : KOC_ldop  '(' topexpr ')' ',' REGA 
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1, $3);
		locctr += geninstr(findgen($1, ST_LD04, cpuselect));
			}
	;
genline : KOC_ldop  dreg ',' '(' topexpr ')' 
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1, $5);
		locctr += geninstr(findgen($1, ST_LD05, cpuselect|$2));
			}
	;
genline : KOC_ldop  dreg ',' dreg 
			{
		genlocrec(currseg, labelloc);
		locctr += geninstr(findgen($1, ST_LD06, cpuselect|$4
			| ($2 == DRSP ? DRDESTSP : 0)));
			}
	;
genline : KOC_ldop  dreg ',' topexpr 
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1, $4);
		locctr += geninstr(findgen($1, ST_LD07, cpuselect|$2));
			}
	;
genline : KOC_ldop  index ',' expr 
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1, $2.exp);
		pevalexpr(2, $4);
		locctr += geninstr(findgen($1, ST_LD08, cpuselect|$2.indsel));
			}
	;
genline : KOC_ldop  index ',' reg8 
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1,$2.exp);
		evalr[2].value = $4;
		locctr += geninstr(findgen($1, ST_LD09, cpuselect|$2.indsel));
			}
	;
genline : KOC_ldop  reg8 ',' '(' dreg ')' 
			{
		genlocrec(currseg, labelloc);
		evalr[1].value = $2 << 3;
		locctr += geninstr(findgen($1, ST_LD10, cpuselect
			| $5 | ($2 == VALREGA ? REGISA : 0)));
			}
	;
genline : KOC_ldop  reg8 ',' topexpr 
			{
		genlocrec(currseg, labelloc);
		evalr[1].value = $2 << 3;
		pevalexpr(2, $4);
		locctr += geninstr(findgen($1, ST_LD11, cpuselect));
			}
	;
genline : KOC_ldop  reg8 ',' index 
			{
		genlocrec(currseg, labelloc);
		evalr[1].value = $2 << 3;
		pevalexpr(2, $4.exp);
		locctr += geninstr(findgen($1, ST_LD12, cpuselect|$4.indsel));
			}
	;
genline : KOC_ldop  reg8 ',' reg8 
			{
		genlocrec(currseg, labelloc);
		evalr[1].value = ($2 << 3 ) | $4;
		locctr += geninstr(findgen($1, ST_LD13, cpuselect));
			}
	;
genline : KOC_ldop  reg8 ',' '(' topexpr ')' 
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1, $5);
		locctr += geninstr(findgen($1, ST_LD14, cpuselect
			| ($2 == VALREGA ? REGISA : 0)));
			}
	;
genline : KOC_ldop  reg8 ',' specialr 
			{
		genlocrec(currseg, labelloc);
		locctr += geninstr(findgen($1, ST_LD15, cpuselect|$4
			| ($2 == VALREGA ? REGISA : 0)));
			}
	;
genline : KOC_ldop  specialr ',' REGA 
			{
		genlocrec(currseg, labelloc);
		locctr += geninstr(findgen($1, ST_LD16, cpuselect|$2));
			}
	;
genline : KOC_opcode 
			{
		genlocrec(currseg, labelloc);
		locctr += geninstr(findgen($1, ST_N01, cpuselect));
			}
	;
genline : KOC_opcode  '(' DREGHL ')' 
			{
		genlocrec(currseg, labelloc);
		locctr += geninstr(findgen($1, ST_N02, cpuselect));
			}
	;
genline : KOC_opcode  dreg 
			{
		genlocrec(currseg, labelloc);
		locctr += geninstr(findgen($1, ST_N04, cpuselect|$2));
			}
	;
genline : KOC_opcode  dreg ',' dreg 
			{
		int selc = 0;

		genlocrec(currseg, labelloc);
		switch($2)
		{
		case DRIX:
			selc = DRDESTIX;
			break;
		case DRIY:
			selc = DRDESTIY;
			break;
		case DRHL:
			selc = DRDESTHL;
		default:
			break;
		}
		locctr += geninstr(findgen($1, ST_N05, cpuselect
			| $4| selc));
			}
	;
genline : KOC_opcode  topexpr 
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1, $2);
		locctr += geninstr(findgen($1, ST_N06, cpuselect));
			}
	;
genline : KOC_opcode  index 
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1, $2.exp);
		locctr += geninstr(findgen($1, ST_N07, cpuselect|$2.indsel));
			}
	;
genline : KOC_opcode  reg8 
			{
		genlocrec(currseg, labelloc);
		evalr[1].value = $2;
		evalr[2].value = $2 << 3;
		locctr += geninstr(findgen($1, ST_N08, cpuselect));
			}
	;
genline : KOC_opcode  reg8 ',' '(' DREGHL ')' 
			{
		genlocrec(currseg, labelloc);
		locctr += geninstr(findgen($1, ST_N09, cpuselect
			| ($2 == VALREGA ? REGISA : 0)));
			}
	;
genline : KOC_opcode  reg8 ',' topexpr 
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1, $4);
		locctr += geninstr(findgen($1, ST_N10, cpuselect
			| ($2 == VALREGA ? REGISA : 0)));
			}
	;
genline : KOC_opcode  reg8 ',' index 
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1, $4.exp);
		locctr += geninstr(findgen($1, ST_N11, cpuselect|$4.indsel
			| ($2 == VALREGA ? REGISA : 0)));
			}
	;
genline : KOC_opcode  reg8 ',' reg8 
			{
		genlocrec(currseg, labelloc);
		evalr[1].value = $4;
		locctr += geninstr(findgen($1, ST_N12, cpuselect
			| ($2 == VALREGA ? REGISA : 0)));
			}
	;
genline : KOC_restart  expr 
			{
		int selc = 0;

		genlocrec(currseg, labelloc);
		pevalexpr(1, $2);
		if(evalr[1].seg != SSG_ABS)
		{
			fraerror("noncomputable expression for address");
		}
		else
		{
			selc = evalr[1].value;
			switch(selc)
			{
			case 0:
			case 0x8:
			case 0x10:
			case 0x18:
			case 0x20:
			case 0x28:
			case 0x30:
			case 0x38:
				break;
			default:
				fraerror("invalid value for reset expression");
				break;
			}
		}
		evalr[1].value &= 070;	
		locctr += geninstr(findgen($1, ST_R01, cpuselect));
			}
	;

reg8	:	REGA
	|	REGB
	|	REGC
	|	REGD
	|	REGE
	|	REGH
	|	REGL
	;

dreg	:	DREGAF
	|	DREGBC
	|	DREGDE
	|	DREGHL
	|	DREGIX
	|	DREGIY
	|	DREGSP
	;

condition :	CONDZ
	|	CONDNZ
	|	CONDNC
	|	CONDPE
	|	CONDPO
	|	CONDP
	|	CONDM
	|	REGC
			{
		$$ = CCSELC;
			}
	;

specialr :	SREGI
	|	SREGR
	;

index :	'(' ixoriy '+' expr ')'
			{
		$$.exp = $4;
		$$.indsel = $2;
			}
	;

ixoriy	:	DREGIX
	|	DREGIY
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

	reservedsym("i",SREGI,SPECIALIR);
	reservedsym("r",SREGR,SPECIALRR);
	reservedsym("I",SREGI,SPECIALIR);
	reservedsym("R",SREGR,SPECIALRR);
	reservedsym("a",REGA,VALREGA);
	reservedsym("b",REGB,VALREGB);
	reservedsym("c",REGC,VALREGC);
	reservedsym("d",REGD,VALREGD);
	reservedsym("e",REGE,VALREGE);
	reservedsym("h",REGH,VALREGH);
	reservedsym("l",REGL,VALREGL);
	reservedsym("af",DREGAF,DRAF);
	reservedsym("bc",DREGBC,DRBC);
	reservedsym("de",DREGDE,DRDE);
	reservedsym("hl",DREGHL,DRHL);
	reservedsym("ix",DREGIX,DRIX);
	reservedsym("iy",DREGIY,DRIY);
	reservedsym("sp",DREGSP,DRSP);
	reservedsym("z",CONDZ,CCSELZ);
	reservedsym("nz",CONDNZ,CCSELNZ);
	reservedsym("nc",CONDNC,CCSELNC);
	reservedsym("pe",CONDPE,CCSELPE);
	reservedsym("po",CONDPO,CCSELPO);
	reservedsym("p",CONDP,CCSELP);
	reservedsym("m",CONDM,CCSELM);
	reservedsym("A",REGA,VALREGA);
	reservedsym("B",REGB,VALREGB);
	reservedsym("C",REGC,VALREGC);
	reservedsym("D",REGD,VALREGD);
	reservedsym("E",REGE,VALREGE);
	reservedsym("H",REGH,VALREGH);
	reservedsym("L",REGL,VALREGL);
	reservedsym("AF",DREGAF,DRAF);
	reservedsym("BC",DREGBC,DRBC);
	reservedsym("DE",DREGDE,DRDE);
	reservedsym("HL",DREGHL,DRHL);
	reservedsym("IX",DREGIX,DRIX);
	reservedsym("IY",DREGIY,DRIY);
	reservedsym("SP",DREGSP,DRSP);
	reservedsym("Z",CONDZ,CCSELZ);
	reservedsym("NZ",CONDNZ,CCSELNZ);
	reservedsym("NC",CONDNC,CCSELNC);
	reservedsym("PE",CONDPE,CCSELPE);
	reservedsym("PO",CONDPO,CCSELPO);
	reservedsym("P",CONDP,CCSELP);
	reservedsym("M",CONDM,CCSELM);

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
		{"180", CPU64180},
		{"z80", CPUZ80},
		{"Z80", CPUZ80},
		{"85", CPU8085},
		{"80", CPU8080},
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

#define NUMOPCODE 104
#define NUMSYNBLK 159
#define NUMDIFFOP 276

int gnumopcode = NUMOPCODE;

int ophashlnk[NUMOPCODE];

struct opsym optab[NUMOPCODE+1]
	= {
	{"invalid", KOC_opcode, 2, 0 },
	{"ADC", KOC_opcode, 5, 2 },
	{"ADD", KOC_opcode, 5, 7 },
	{"AND", KOC_opcode, 4, 12 },
	{"BIT", KOC_bit, 3, 16 },
	{"BYTE", KOC_BDEF, 0, 0 },
	{"CALL", KOC_ccop, 2, 19 },
	{"CCF", KOC_opcode, 1, 21 },
	{"CHARDEF", KOC_CHDEF, 0, 0 },
	{"CHARSET", KOC_CHSET, 0, 0 },
	{"CHARUSE", KOC_CHUSE, 0, 0 },
	{"CHD", KOC_CHDEF, 0, 0 },
	{"CP", KOC_opcode, 4, 22 },
	{"CPD", KOC_opcode, 1, 26 },
	{"CPDR", KOC_opcode, 1, 27 },
	{"CPI", KOC_opcode, 1, 28 },
	{"CPIR", KOC_opcode, 1, 29 },
	{"CPL", KOC_opcode, 1, 30 },
	{"CPU", KOC_CPU, 0, 0 },
	{"DAA", KOC_opcode, 1, 31 },
	{"DB", KOC_BDEF, 0, 0 },
	{"DEC", KOC_opcode, 4, 32 },
	{"DI", KOC_opcode, 1, 36 },
	{"DJNZ", KOC_opcode, 1, 37 },
	{"DW", KOC_WDEF, 0, 0 },
	{"EI", KOC_opcode, 1, 38 },
	{"ELSE", KOC_ELSE, 0, 0 },
	{"END", KOC_END, 0, 0 },
	{"ENDI", KOC_ENDI, 0, 0 },
	{"EQU", KOC_EQU, 0, 0 },
	{"EX", KOC_exop, 2, 39 },
	{"EXX", KOC_opcode, 1, 41 },
	{"FCB", KOC_BDEF, 0, 0 },
	{"FCC", KOC_SDEF, 0, 0 },
	{"FDB", KOC_WDEF, 0, 0 },
	{"HALT", KOC_opcode, 1, 42 },
	{"IF", KOC_IF, 0, 0 },
	{"IM", KOC_intmode, 1, 43 },
	{"IN0", KOC_ioop, 1, 44 },
	{"IN", KOC_ioop, 2, 45 },
	{"INC", KOC_opcode, 4, 47 },
	{"INCL", KOC_INCLUDE, 0, 0 },
	{"INCLUDE", KOC_INCLUDE, 0, 0 },
	{"IND", KOC_opcode, 1, 51 },
	{"INDR", KOC_opcode, 1, 52 },
	{"INI", KOC_opcode, 1, 53 },
	{"INIR", KOC_opcode, 1, 54 },
	{"JP", KOC_ccop, 3, 55 },
	{"JR", KOC_ccop, 2, 58 },
	{"LD", KOC_ldop, 16, 60 },
	{"LDD", KOC_opcode, 1, 76 },
	{"LDDR", KOC_opcode, 1, 77 },
	{"LDI", KOC_opcode, 1, 78 },
	{"LDIR", KOC_opcode, 1, 79 },
	{"MULT", KOC_opcode, 1, 80 },
	{"NEG", KOC_opcode, 1, 81 },
	{"NOP", KOC_opcode, 1, 82 },
	{"OR", KOC_opcode, 4, 83 },
	{"ORG", KOC_ORG, 0, 0 },
	{"OTDM", KOC_opcode, 1, 87 },
	{"OTDMR", KOC_opcode, 1, 88 },
	{"OTDR", KOC_opcode, 1, 89 },
	{"OTIM", KOC_opcode, 1, 90 },
	{"OTIMR", KOC_opcode, 1, 91 },
	{"OTIR", KOC_opcode, 1, 92 },
	{"OUT0", KOC_ioop, 1, 93 },
	{"OUT", KOC_ioop, 2, 94 },
	{"OUTD", KOC_opcode, 1, 96 },
	{"OUTI", KOC_opcode, 1, 97 },
	{"POP", KOC_opcode, 1, 98 },
	{"PUSH", KOC_opcode, 1, 99 },
	{"RES", KOC_bit, 3, 100 },
	{"RESERVE", KOC_RESM, 0, 0 },
	{"RET", KOC_ccop, 2, 103 },
	{"RETI", KOC_opcode, 1, 105 },
	{"RETN", KOC_opcode, 1, 106 },
	{"RIM", KOC_opcode, 1, 107 },
	{"RL", KOC_opcode, 3, 108 },
	{"RLA", KOC_opcode, 1, 111 },
	{"RLC", KOC_opcode, 3, 112 },
	{"RLCA", KOC_opcode, 1, 115 },
	{"RLD", KOC_opcode, 1, 116 },
	{"RMB", KOC_RESM, 0, 0 },
	{"RR", KOC_opcode, 3, 117 },
	{"RRA", KOC_opcode, 1, 120 },
	{"RRC", KOC_opcode, 3, 121 },
	{"RRCA", KOC_opcode, 1, 124 },
	{"RRD", KOC_opcode, 1, 125 },
	{"RST", KOC_restart, 1, 126 },
	{"SBC", KOC_opcode, 5, 127 },
	{"SCF", KOC_opcode, 1, 132 },
	{"SET", KOC_bit, 3, 133 },
	{"SETEQU", KOC_SET, 0, 0 },
	{"SIM", KOC_opcode, 1, 136 },
	{"SLA", KOC_opcode, 3, 137 },
	{"SLP", KOC_opcode, 1, 140 },
	{"SRA", KOC_opcode, 3, 141 },
	{"SRL", KOC_opcode, 3, 144 },
	{"STRING", KOC_SDEF, 0, 0 },
	{"SUB", KOC_opcode, 4, 147 },
	{"TST", KOC_opcode, 3, 151 },
	{"TSTIO", KOC_opcode, 1, 154 },
	{"WORD", KOC_WDEF, 0, 0 },
	{"XOR", KOC_opcode, 4, 155 },
	{ "", 0, 0, 0 }};

struct opsynt ostab[NUMSYNBLK+1]
	= {
/* invalid 0 */ { 0, 1, 0 },
/* invalid 1 */ { 0xffff, 1, 1 },
/* ADC 2 */ { ST_N05, 4, 2 },
/* ADC 3 */ { ST_N09, 1, 6 },
/* ADC 4 */ { ST_N10, 1, 7 },
/* ADC 5 */ { ST_N11, 2, 8 },
/* ADC 6 */ { ST_N12, 1, 10 },
/* ADD 7 */ { ST_N05, 12, 11 },
/* ADD 8 */ { ST_N09, 1, 23 },
/* ADD 9 */ { ST_N10, 1, 24 },
/* ADD 10 */ { ST_N11, 2, 25 },
/* ADD 11 */ { ST_N12, 1, 27 },
/* AND 12 */ { ST_N02, 1, 28 },
/* AND 13 */ { ST_N06, 1, 29 },
/* AND 14 */ { ST_N07, 2, 30 },
/* AND 15 */ { ST_N08, 1, 32 },
/* BIT 16 */ { ST_B01, 1, 33 },
/* BIT 17 */ { ST_B02, 2, 34 },
/* BIT 18 */ { ST_B03, 1, 36 },
/* CALL 19 */ { ST_CC02, 8, 37 },
/* CALL 20 */ { ST_CC03, 1, 45 },
/* CCF 21 */ { ST_N01, 1, 46 },
/* CP 22 */ { ST_N02, 1, 47 },
/* CP 23 */ { ST_N06, 1, 48 },
/* CP 24 */ { ST_N07, 2, 49 },
/* CP 25 */ { ST_N08, 1, 51 },
/* CPD 26 */ { ST_N01, 1, 52 },
/* CPDR 27 */ { ST_N01, 1, 53 },
/* CPI 28 */ { ST_N01, 1, 54 },
/* CPIR 29 */ { ST_N01, 1, 55 },
/* CPL 30 */ { ST_N01, 1, 56 },
/* DAA 31 */ { ST_N01, 1, 57 },
/* DEC 32 */ { ST_N02, 1, 58 },
/* DEC 33 */ { ST_N04, 6, 59 },
/* DEC 34 */ { ST_N07, 2, 65 },
/* DEC 35 */ { ST_N08, 1, 67 },
/* DI 36 */ { ST_N01, 1, 68 },
/* DJNZ 37 */ { ST_N06, 1, 69 },
/* EI 38 */ { ST_N01, 1, 70 },
/* EX 39 */ { ST_EX01, 2, 71 },
/* EX 40 */ { ST_EX02, 3, 73 },
/* EXX 41 */ { ST_N01, 1, 76 },
/* HALT 42 */ { ST_N01, 1, 77 },
/* IM 43 */ { ST_IM01, 3, 78 },
/* IN0 44 */ { ST_IO03, 1, 81 },
/* IN 45 */ { ST_IO03, 1, 82 },
/* IN 46 */ { ST_IO04, 1, 83 },
/* INC 47 */ { ST_N02, 1, 84 },
/* INC 48 */ { ST_N04, 6, 85 },
/* INC 49 */ { ST_N07, 2, 91 },
/* INC 50 */ { ST_N08, 1, 93 },
/* IND 51 */ { ST_N01, 1, 94 },
/* INDR 52 */ { ST_N01, 1, 95 },
/* INI 53 */ { ST_N01, 1, 96 },
/* INIR 54 */ { ST_N01, 1, 97 },
/* JP 55 */ { ST_CC01, 3, 98 },
/* JP 56 */ { ST_CC02, 8, 101 },
/* JP 57 */ { ST_CC03, 1, 109 },
/* JR 58 */ { ST_CC02, 4, 110 },
/* JR 59 */ { ST_CC03, 1, 114 },
/* LD 60 */ { ST_LD01, 1, 115 },
/* LD 61 */ { ST_LD02, 3, 116 },
/* LD 62 */ { ST_LD03, 6, 119 },
/* LD 63 */ { ST_LD04, 1, 125 },
/* LD 64 */ { ST_LD05, 6, 126 },
/* LD 65 */ { ST_LD06, 3, 132 },
/* LD 66 */ { ST_LD07, 6, 135 },
/* LD 67 */ { ST_LD08, 2, 141 },
/* LD 68 */ { ST_LD09, 2, 143 },
/* LD 69 */ { ST_LD10, 3, 145 },
/* LD 70 */ { ST_LD11, 1, 148 },
/* LD 71 */ { ST_LD12, 2, 149 },
/* LD 72 */ { ST_LD13, 1, 151 },
/* LD 73 */ { ST_LD14, 1, 152 },
/* LD 74 */ { ST_LD15, 2, 153 },
/* LD 75 */ { ST_LD16, 2, 155 },
/* LDD 76 */ { ST_N01, 1, 157 },
/* LDDR 77 */ { ST_N01, 1, 158 },
/* LDI 78 */ { ST_N01, 1, 159 },
/* LDIR 79 */ { ST_N01, 1, 160 },
/* MULT 80 */ { ST_N04, 4, 161 },
/* NEG 81 */ { ST_N01, 1, 165 },
/* NOP 82 */ { ST_N01, 1, 166 },
/* OR 83 */ { ST_N02, 1, 167 },
/* OR 84 */ { ST_N06, 1, 168 },
/* OR 85 */ { ST_N07, 2, 169 },
/* OR 86 */ { ST_N08, 1, 171 },
/* OTDM 87 */ { ST_N01, 1, 172 },
/* OTDMR 88 */ { ST_N01, 1, 173 },
/* OTDR 89 */ { ST_N01, 1, 174 },
/* OTIM 90 */ { ST_N01, 1, 175 },
/* OTIMR 91 */ { ST_N01, 1, 176 },
/* OTIR 92 */ { ST_N01, 1, 177 },
/* OUT0 93 */ { ST_IO01, 1, 178 },
/* OUT 94 */ { ST_IO01, 1, 179 },
/* OUT 95 */ { ST_IO02, 1, 180 },
/* OUTD 96 */ { ST_N01, 1, 181 },
/* OUTI 97 */ { ST_N01, 1, 182 },
/* POP 98 */ { ST_N04, 6, 183 },
/* PUSH 99 */ { ST_N04, 6, 189 },
/* RES 100 */ { ST_B01, 1, 195 },
/* RES 101 */ { ST_B02, 2, 196 },
/* RES 102 */ { ST_B03, 1, 198 },
/* RET 103 */ { ST_CC04, 8, 199 },
/* RET 104 */ { ST_CC05, 1, 207 },
/* RETI 105 */ { ST_N01, 1, 208 },
/* RETN 106 */ { ST_N01, 1, 209 },
/* RIM 107 */ { ST_N01, 1, 210 },
/* RL 108 */ { ST_N02, 1, 211 },
/* RL 109 */ { ST_N07, 2, 212 },
/* RL 110 */ { ST_N08, 1, 214 },
/* RLA 111 */ { ST_N01, 1, 215 },
/* RLC 112 */ { ST_N02, 1, 216 },
/* RLC 113 */ { ST_N07, 2, 217 },
/* RLC 114 */ { ST_N08, 1, 219 },
/* RLCA 115 */ { ST_N01, 1, 220 },
/* RLD 116 */ { ST_N01, 1, 221 },
/* RR 117 */ { ST_N02, 1, 222 },
/* RR 118 */ { ST_N07, 2, 223 },
/* RR 119 */ { ST_N08, 1, 225 },
/* RRA 120 */ { ST_N01, 1, 226 },
/* RRC 121 */ { ST_N02, 1, 227 },
/* RRC 122 */ { ST_N07, 2, 228 },
/* RRC 123 */ { ST_N08, 1, 230 },
/* RRCA 124 */ { ST_N01, 1, 231 },
/* RRD 125 */ { ST_N01, 1, 232 },
/* RST 126 */ { ST_R01, 1, 233 },
/* SBC 127 */ { ST_N05, 4, 234 },
/* SBC 128 */ { ST_N09, 1, 238 },
/* SBC 129 */ { ST_N10, 1, 239 },
/* SBC 130 */ { ST_N11, 2, 240 },
/* SBC 131 */ { ST_N12, 1, 242 },
/* SCF 132 */ { ST_N01, 1, 243 },
/* SET 133 */ { ST_B01, 1, 244 },
/* SET 134 */ { ST_B02, 2, 245 },
/* SET 135 */ { ST_B03, 1, 247 },
/* SIM 136 */ { ST_N01, 1, 248 },
/* SLA 137 */ { ST_N02, 1, 249 },
/* SLA 138 */ { ST_N07, 2, 250 },
/* SLA 139 */ { ST_N08, 1, 252 },
/* SLP 140 */ { ST_N01, 1, 253 },
/* SRA 141 */ { ST_N02, 1, 254 },
/* SRA 142 */ { ST_N07, 2, 255 },
/* SRA 143 */ { ST_N08, 1, 257 },
/* SRL 144 */ { ST_N02, 1, 258 },
/* SRL 145 */ { ST_N07, 2, 259 },
/* SRL 146 */ { ST_N08, 1, 261 },
/* SUB 147 */ { ST_N02, 1, 262 },
/* SUB 148 */ { ST_N06, 1, 263 },
/* SUB 149 */ { ST_N07, 2, 264 },
/* SUB 150 */ { ST_N08, 1, 266 },
/* TST 151 */ { ST_N02, 1, 267 },
/* TST 152 */ { ST_N06, 1, 268 },
/* TST 153 */ { ST_N08, 1, 269 },
/* TSTIO 154 */ { ST_N06, 1, 270 },
/* XOR 155 */ { ST_N02, 1, 271 },
/* XOR 156 */ { ST_N06, 1, 272 },
/* XOR 157 */ { ST_N07, 2, 273 },
/* XOR 158 */ { ST_N08, 1, 275 },
	{ 0, 0, 0 } };

struct igel igtab[NUMDIFFOP+1]
	= {
/* invalid 0 */   { 0 , 0, 
		"[Xnullentry" },
/* invalid 1 */   { 0 , 0, 
		"[Xinvalid opcode" },
/* ADC 2 */   { TSZ80PLUS|DRDESTMASK|DRMASK , TSZ80PLUS|DRDESTHL|DRBC, 
		"ed;4a;" },
/* ADC 3 */   { TSZ80PLUS|DRDESTMASK|DRMASK , TSZ80PLUS|DRDESTHL|DRDE, 
		"ed;5a;" },
/* ADC 4 */   { TSZ80PLUS|DRDESTMASK|DRMASK , TSZ80PLUS|DRDESTHL|DRHL, 
		"ed;6a;" },
/* ADC 5 */   { TSZ80PLUS|DRDESTMASK|DRMASK , TSZ80PLUS|DRDESTHL|DRSP, 
		"ed;7a;" },
/* ADC 6 */   { REGISA , REGISA, 
		"8e;" },
/* ADC 7 */   { REGISA , REGISA, 
		"ce;[1=];" },
/* ADC 8 */   { REGISA|TSZ80PLUS|DRMASK , TSZ80PLUS|DRIX|REGISA, 
		"dd;8e;[1=]r" },
/* ADC 9 */   { REGISA|TSZ80PLUS|DRMASK , TSZ80PLUS|DRIY|REGISA, 
		"fd;8e;[1=]r" },
/* ADC 10 */   { REGISA|0 , 0|REGISA, 
		"88.[1#]|;" },
/* ADD 11 */   { DRDESTMASK|DRMASK , DRDESTHL|DRBC, 
		"09;" },
/* ADD 12 */   { TSZ80PLUS|DRDESTMASK|DRMASK , TSZ80PLUS|DRDESTIX|DRBC, 
		"dd;09;" },
/* ADD 13 */   { TSZ80PLUS|DRDESTMASK|DRMASK , TSZ80PLUS|DRDESTIY|DRBC, 
		"fd;09;" },
/* ADD 14 */   { DRDESTMASK|DRMASK , DRDESTHL|DRDE, 
		"19;" },
/* ADD 15 */   { TSZ80PLUS|DRDESTMASK|DRMASK , TSZ80PLUS|DRDESTIX|DRDE, 
		"dd;19;" },
/* ADD 16 */   { TSZ80PLUS|DRDESTMASK|DRMASK , TSZ80PLUS|DRDESTIY|DRDE, 
		"fd;19;" },
/* ADD 17 */   { DRDESTMASK|DRMASK , DRDESTHL|DRHL, 
		"29;" },
/* ADD 18 */   { TSZ80PLUS|DRDESTMASK|DRMASK , TSZ80PLUS|DRDESTIX|DRIX, 
		"dd;29;" },
/* ADD 19 */   { TSZ80PLUS|DRDESTMASK|DRMASK , TSZ80PLUS|DRDESTIY|DRIY, 
		"fd;29;" },
/* ADD 20 */   { DRDESTMASK|DRMASK , DRDESTHL|DRSP, 
		"39;" },
/* ADD 21 */   { TSZ80PLUS|DRDESTMASK|DRMASK , TSZ80PLUS|DRDESTIX|DRSP, 
		"dd;39;" },
/* ADD 22 */   { TSZ80PLUS|DRDESTMASK|DRMASK , TSZ80PLUS|DRDESTIY|DRSP, 
		"fd;39;" },
/* ADD 23 */   { REGISA , REGISA, 
		"86;" },
/* ADD 24 */   { REGISA , REGISA, 
		"c6;[1=];" },
/* ADD 25 */   { REGISA|TSZ80PLUS|DRMASK , TSZ80PLUS|DRIX|REGISA, 
		"dd;86;[1=]r" },
/* ADD 26 */   { REGISA|TSZ80PLUS|DRMASK , TSZ80PLUS|DRIY|REGISA, 
		"fd;86;[1=]r" },
/* ADD 27 */   { REGISA|0 , 0|REGISA, 
		"80.[1#]|;" },
/* AND 28 */   { 0 , 0, 
		"a6;" },
/* AND 29 */   { 0 , 0, 
		"e6;[1=];" },
/* AND 30 */   { DRMASK|TSZ80PLUS , TSZ80PLUS|DRIX, 
		"dd;a6;[1=]r" },
/* AND 31 */   { DRMASK|TSZ80PLUS , TSZ80PLUS|DRIY, 
		"fd;a6;[1=]r" },
/* AND 32 */   { 0 , 0, 
		"a0.[1#]|;" },
/* BIT 33 */   { TSZ80PLUS , TSZ80PLUS, 
		"cb;[1#].46|;" },
/* BIT 34 */   { TSZ80PLUS|DRMASK , TSZ80PLUS|DRIX, 
		"dd;cb;[2=]r46.[1#]|;" },
/* BIT 35 */   { TSZ80PLUS|DRMASK , TSZ80PLUS|DRIY, 
		"fd;cb;[2=]r46.[1#]|;" },
/* BIT 36 */   { TSZ80PLUS , TSZ80PLUS, 
		"cb;[1#].40|;" },
/* CALL 37 */   { CCSELMASK , CCSELNZ, 
		"c4;[1=]y" },
/* CALL 38 */   { CCSELMASK , CCSELZ, 
		"cc;[1=]y" },
/* CALL 39 */   { CCSELMASK , CCSELNC, 
		"d4;[1=]y" },
/* CALL 40 */   { CCSELMASK , CCSELC, 
		"dc;[1=]y" },
/* CALL 41 */   { CCSELMASK , CCSELPO, 
		"e4;[1=]y" },
/* CALL 42 */   { CCSELMASK , CCSELPE, 
		"ec;[1=]y" },
/* CALL 43 */   { CCSELMASK , CCSELP, 
		"f4;[1=]y" },
/* CALL 44 */   { CCSELMASK , CCSELM, 
		"fc;[1=]y" },
/* CALL 45 */   { 0 , 0, 
		"cd;[1=]y" },
/* CCF 46 */   { 0 , 0, 
		"3f;" },
/* CP 47 */   { 0 , 0, 
		"be;" },
/* CP 48 */   { 0 , 0, 
		"fe;[1=];" },
/* CP 49 */   { DRMASK|TSZ80PLUS , TSZ80PLUS|DRIX, 
		"dd;be;[1=]r" },
/* CP 50 */   { DRMASK|TSZ80PLUS , TSZ80PLUS|DRIY, 
		"fd;be;[1=]r" },
/* CP 51 */   { 0 , 0, 
		"b8.[1#]|;" },
/* CPD 52 */   { TSZ80PLUS , TSZ80PLUS, 
		"ed;a9;"  },
/* CPDR 53 */   { TSZ80PLUS , TSZ80PLUS, 
		"ed;b9;"  },
/* CPI 54 */   { TSZ80PLUS , TSZ80PLUS, 
		"ed;a1;"  },
/* CPIR 55 */   { TSZ80PLUS , TSZ80PLUS, 
		"ed;b1;"  },
/* CPL 56 */   { 0 , 0, 
		"2f;" },
/* DAA 57 */   { 0 , 0, 
		"27;" },
/* DEC 58 */   { 0 , 0, 
		"35;" },
/* DEC 59 */   { DRMASK , DRBC, 
		"0b;" },
/* DEC 60 */   { DRMASK , DRDE, 
		"1b;" },
/* DEC 61 */   { DRMASK , DRHL, 
		"2b;" },
/* DEC 62 */   { DRMASK , DRSP, 
		"3b;" },
/* DEC 63 */   { TSZ80PLUS|DRMASK , TSZ80PLUS|DRIX, 
		"dd;2b;" },
/* DEC 64 */   { TSZ80PLUS|DRMASK , TSZ80PLUS|DRIY, 
		"fd;2b;" },
/* DEC 65 */   { DRMASK|TSZ80PLUS , TSZ80PLUS|DRIX, 
		"dd;35;[1=]r" },
/* DEC 66 */   { DRMASK|TSZ80PLUS , TSZ80PLUS|DRIY, 
		"fd;35;[1=]r" },
/* DEC 67 */   { 0 , 0, 
		"05.[2#]|;" },
/* DI 68 */   { 0 , 0, 
		"f3;" },
/* DJNZ 69 */   { 0 , 0, 
		"10;[1=].P.2+-r" },
/* EI 70 */   { 0 , 0, 
		"fb;" },
/* EX 71 */   { EXMASK , EX1DE|EX2HL, 
		"eb;" },
/* EX 72 */   { TSZ80PLUS|EXMASK , TSZ80PLUS|EX1AF|EX2AF, 
		"08;" },
/* EX 73 */   { DRMASK , DRHL, 
		"e3;" },
/* EX 74 */   { TSZ80PLUS|DRMASK , TSZ80PLUS|DRIX, 
		"dd;e3;" },
/* EX 75 */   { TSZ80PLUS|DRMASK , TSZ80PLUS|DRIY, 
		"fd;e3;" },
/* EXX 76 */   { TSZ80PLUS , TSZ80PLUS, 
		"d9;" },
/* HALT 77 */   { 0 , 0, 
		"76;" },
/* IM 78 */   { TSZ80PLUS|INTSETMASK , TSZ80PLUS|INTSETMODE0, 
		"ed;46;" },
/* IM 79 */   { TSZ80PLUS|INTSETMASK , TSZ80PLUS|INTSETMODE1, 
		"ed;56;" },
/* IM 80 */   { TSZ80PLUS|INTSETMASK , TSZ80PLUS|INTSETMODE2, 
		"ed;5e;" },
/* IN0 81 */   { TS64180 , TS64180, 
		"ed;00.[1#]|;[2=];" },
/* IN 82 */   { REGISA , REGISA, 
		"db;[2=];" },
/* IN 83 */   { TSZ80PLUS , TSZ80PLUS, 
		"ed;40.[1#]|;" },
/* INC 84 */   { 0 , 0, 
		"34;" },
/* INC 85 */   { DRMASK , DRBC, 
		"03;" },
/* INC 86 */   { DRMASK , DRDE, 
		"13;" },
/* INC 87 */   { DRMASK , DRHL, 
		"23;" },
/* INC 88 */   { DRMASK , DRSP, 
		"33;" },
/* INC 89 */   { TSZ80PLUS|DRMASK , TSZ80PLUS|DRIX, 
		"dd;23;" },
/* INC 90 */   { TSZ80PLUS|DRMASK , TSZ80PLUS|DRIY, 
		"fd;23;" },
/* INC 91 */   { DRMASK|TSZ80PLUS , TSZ80PLUS|DRIX, 
		"dd;34;[1=]r" },
/* INC 92 */   { DRMASK|TSZ80PLUS , TSZ80PLUS|DRIY, 
		"fd;34;[1=]r" },
/* INC 93 */   { 0 , 0, 
		"04.[2#]|;" },
/* IND 94 */   { TSZ80PLUS , TSZ80PLUS, 
		"ed;aa;" },
/* INDR 95 */   { TSZ80PLUS , TSZ80PLUS, 
		"ed;ba;" },
/* INI 96 */   { TSZ80PLUS , TSZ80PLUS, 
		"ed;a2;" },
/* INIR 97 */   { TSZ80PLUS , TSZ80PLUS, 
		"ed;b2;" },
/* JP 98 */   { DRMASK , DRHL, 
		"e9;" },
/* JP 99 */   { TSZ80PLUS|DRMASK , TSZ80PLUS|DRIX, 
		"dd;e9;" },
/* JP 100 */   { TSZ80PLUS|DRMASK , TSZ80PLUS|DRIY, 
		"fd;e9;" },
/* JP 101 */   { CCSELMASK , CCSELNZ, 
		"c2;[1=]y" },
/* JP 102 */   { CCSELMASK , CCSELZ, 
		"ca;[1=]y" },
/* JP 103 */   { CCSELMASK , CCSELNC, 
		"d2;[1=]y" },
/* JP 104 */   { CCSELMASK , CCSELC, 
		"da;[1=]y" },
/* JP 105 */   { CCSELMASK , CCSELPO, 
		"e2;[1=]y" },
/* JP 106 */   { CCSELMASK , CCSELPE, 
		"ea;[1=]y" },
/* JP 107 */   { CCSELMASK , CCSELP, 
		"f2;[1=]y" },
/* JP 108 */   { CCSELMASK , CCSELM, 
		"fa;[1=]y" },
/* JP 109 */   { 0 , 0, 
		"c3;[1=]y" },
/* JR 110 */   { TSZ80PLUS|CCSELMASK , CCSELNZ|TSZ80PLUS, 
		"20;[1=].P.2+-r" },
/* JR 111 */   { TSZ80PLUS|CCSELMASK , CCSELZ|TSZ80PLUS, 
		"28;[1=].P.2+-r" },
/* JR 112 */   { TSZ80PLUS|CCSELMASK , CCSELNC|TSZ80PLUS, 
		"30;[1=].P.2+-r" },
/* JR 113 */   { TSZ80PLUS|CCSELMASK , CCSELC|TSZ80PLUS, 
		"38;[1=].P.2+-r" },
/* JR 114 */   { TSZ80PLUS , TSZ80PLUS, 
		"18;[1=].P.2+-r" },
/* LD 115 */   { DRMASK , DRHL, 
		"36;[1=];" },
/* LD 116 */   { DRMASK , DRHL, 
		"70.[1#]|;" },
/* LD 117 */   { DRMASK|REGISA , DRBC|REGISA, 
		"02;" },
/* LD 118 */   { DRMASK|REGISA , DRDE|REGISA, 
		"12;" },
/* LD 119 */   { DRMASK , DRHL, 
		"22;[1=]y" },
/* LD 120 */   { TSZ80PLUS|DRMASK , TSZ80PLUS|DRIX, 
		"dd;22;[1=]y" },
/* LD 121 */   { TSZ80PLUS|DRMASK , TSZ80PLUS|DRIY, 
		"fd;22;[1=]y" },
/* LD 122 */   { TSZ80PLUS|DRMASK , TSZ80PLUS|DRBC, 
		"ed;43;[1=]y" },
/* LD 123 */   { TSZ80PLUS|DRMASK , TSZ80PLUS|DRDE, 
		"ed;53;[1=]y" },
/* LD 124 */   { TSZ80PLUS|DRMASK , TSZ80PLUS|DRSP, 
		"ed;73;[1=]y" },
/* LD 125 */   { 0 , 0, 
		"32;[1=]y" },
/* LD 126 */   { DRMASK , DRHL, 
		"2a;[1=]y" },
/* LD 127 */   { TSZ80PLUS|DRMASK , TSZ80PLUS|DRIX, 
		"dd;2a;[1=]y" },
/* LD 128 */   { TSZ80PLUS|DRMASK , TSZ80PLUS|DRIY, 
		"fd;2a;[1=]y" },
/* LD 129 */   { TSZ80PLUS|DRMASK , TSZ80PLUS|DRBC, 
		"ed;4b;[1=]y" },
/* LD 130 */   { TSZ80PLUS|DRMASK , TSZ80PLUS|DRDE, 
		"ed;5b;[1=]y" },
/* LD 131 */   { TSZ80PLUS|DRMASK , TSZ80PLUS|DRSP, 
		"ed;7b;[1=]y" },
/* LD 132 */   { DRDESTMASK|TSZ80PLUS|DRMASK , TSZ80PLUS|DRHL|DRDESTSP, 
		"f9;" },
/* LD 133 */   { DRDESTMASK|TSZ80PLUS|DRMASK , TSZ80PLUS|DRIX|DRDESTSP, 
		"dd;f9;" },
/* LD 134 */   { DRDESTMASK|TSZ80PLUS|DRMASK , TSZ80PLUS|DRIY|DRDESTSP, 
		"fd;f9;" },
/* LD 135 */   { DRMASK , DRHL, 
		"21;[1=]y" },
/* LD 136 */   { DRMASK , DRBC, 
		"01;[1=]y" },
/* LD 137 */   { DRMASK , DRDE, 
		"11;[1=]y" },
/* LD 138 */   { DRMASK , DRSP, 
		"31;[1=]y" },
/* LD 139 */   { TSZ80PLUS|DRMASK , TSZ80PLUS|DRIX, 
		"dd;21;[1=]y" },
/* LD 140 */   { TSZ80PLUS|DRMASK , TSZ80PLUS|DRIY, 
		"fd;21;[1=]y" },
/* LD 141 */   { TSZ80PLUS|DRMASK , TSZ80PLUS|DRIX, 
		"dd;36;[1=]r[2=];" },
/* LD 142 */   { TSZ80PLUS|DRMASK , TSZ80PLUS|DRIY, 
		"fd;36;[1=]r[2=];" },
/* LD 143 */   { TSZ80PLUS|DRMASK , TSZ80PLUS|DRIX, 
		"dd;70.[2#]|;[1=]r" },
/* LD 144 */   { TSZ80PLUS|DRMASK , TSZ80PLUS|DRIY, 
		"fd;70.[2#]|;[1=]r" },
/* LD 145 */   { DRMASK , DRHL, 
		"46.[1#]|;" },
/* LD 146 */   { DRMASK|REGISA , DRBC|REGISA, 
		"0a;" },
/* LD 147 */   { DRMASK|REGISA , DRDE|REGISA, 
		"1a;" },
/* LD 148 */   { 0 , 0, 
		"06.[1#]|;[2=];" },
/* LD 149 */   { TSZ80PLUS|DRMASK , TSZ80PLUS|DRIX, 
		"dd;46.[1#]|;[2=]r" },
/* LD 150 */   { TSZ80PLUS|DRMASK , TSZ80PLUS|DRIY, 
		"fd;46.[1#]|;[2=]r" },
/* LD 151 */   { 0 , 0, 
		"40.[1#]|;" },
/* LD 152 */   { REGISA , REGISA, 
		"3a;[1=]y" },
/* LD 153 */   { REGISA|TSZ80PLUS|SPECIALRMASK , TSZ80PLUS|SPECIALIR|REGISA, 
		"ed;57;" },
/* LD 154 */   { REGISA|TSZ80PLUS|SPECIALRMASK , TSZ80PLUS|SPECIALRR|REGISA, 
		"ed;5f;" },
/* LD 155 */   { TSZ80PLUS|SPECIALRMASK , TSZ80PLUS|SPECIALIR, 
		"ed;47;" },
/* LD 156 */   { TSZ80PLUS|SPECIALRMASK , TSZ80PLUS|SPECIALRR, 
		"ed;4f;" },
/* LDD 157 */   { TSZ80PLUS , TSZ80PLUS, 
		"ed;a8;" },
/* LDDR 158 */   { TSZ80PLUS , TSZ80PLUS, 
		"ed;b8;" },
/* LDI 159 */   { TSZ80PLUS , TSZ80PLUS, 
		"ed;a0;" },
/* LDIR 160 */   { TSZ80PLUS , TSZ80PLUS, 
		"ed;b0;" },
/* MULT 161 */   { TS64180|DRMASK , TS64180|DRBC, 
		"ed;4c;" },
/* MULT 162 */   { TS64180|DRMASK , TS64180|DRDE, 
		"ed;5c;" },
/* MULT 163 */   { TS64180|DRMASK , TS64180|DRHL, 
		"ed;6c;" },
/* MULT 164 */   { TS64180|DRMASK , TS64180|DRSP, 
		"ed;7c;" },
/* NEG 165 */   { TSZ80PLUS , TSZ80PLUS, 
		"ed;44;" },
/* NOP 166 */   { 0 , 0, 
		"00;" },
/* OR 167 */   { 0 , 0, 
		"b6;" },
/* OR 168 */   { 0 , 0, 
		"f6;[1=];" },
/* OR 169 */   { DRMASK|TSZ80PLUS , TSZ80PLUS|DRIX, 
		"dd;b6;[1=]r" },
/* OR 170 */   { DRMASK|TSZ80PLUS , TSZ80PLUS|DRIY, 
		"fd;b6;[1=]r" },
/* OR 171 */   { 0 , 0, 
		"b0.[1#]|;" },
/* OTDM 172 */   { TS64180 , TS64180, 
		"ed;8b;" },
/* OTDMR 173 */   { TS64180 , TS64180, 
		"ed;9b;" },
/* OTDR 174 */   { TSZ80PLUS , TSZ80PLUS, 
		"ed;bb;" },
/* OTIM 175 */   { TS64180 , TS64180, 
		"ed;83;" },
/* OTIMR 176 */   { TS64180 , TS64180, 
		"ed;93;" },
/* OTIR 177 */   { TSZ80PLUS , TSZ80PLUS, 
		"ed;b3;" },
/* OUT0 178 */   { TS64180 , TS64180, 
		"ed;01.[2#]|;[1=];" },
/* OUT 179 */   { REGISA , REGISA, 
		"d3;[1=];" },
/* OUT 180 */   { TSZ80PLUS , TSZ80PLUS, 
		"ed;41.[1#]|;" },
/* OUTD 181 */   { TSZ80PLUS , TSZ80PLUS, 
		"ed;ab;" },
/* OUTI 182 */   { TSZ80PLUS , TSZ80PLUS, 
		"ed;a3;" },
/* POP 183 */   { DRMASK , DRBC, 
		"c1;" },
/* POP 184 */   { DRMASK , DRDE, 
		"d1;" },
/* POP 185 */   { DRMASK , DRHL, 
		"e1;" },
/* POP 186 */   { DRMASK , DRAF, 
		"f1;" },
/* POP 187 */   { TSZ80PLUS|DRMASK , TSZ80PLUS|DRIX, 
		"dd;e1;" },
/* POP 188 */   { TSZ80PLUS|DRMASK , TSZ80PLUS|DRIY, 
		"fd;e1;" },
/* PUSH 189 */   { DRMASK , DRBC, 
		"c5;" },
/* PUSH 190 */   { DRMASK , DRDE, 
		"d5;" },
/* PUSH 191 */   { DRMASK , DRHL, 
		"e5;" },
/* PUSH 192 */   { DRMASK , DRAF, 
		"f5;" },
/* PUSH 193 */   { TSZ80PLUS|DRMASK , TSZ80PLUS|DRIX, 
		"dd;e5;" },
/* PUSH 194 */   { TSZ80PLUS|DRMASK , TSZ80PLUS|DRIY, 
		"fd;e5;" },
/* RES 195 */   { TSZ80PLUS , TSZ80PLUS, 
		"cb;[1#].86|;" },
/* RES 196 */   { TSZ80PLUS|DRMASK , TSZ80PLUS|DRIX, 
		"dd;cb;[2=]r86.[1#]|;" },
/* RES 197 */   { TSZ80PLUS|DRMASK , TSZ80PLUS|DRIY, 
		"fd;cb;[2=]r86.[1#]|;" },
/* RES 198 */   { TSZ80PLUS , TSZ80PLUS, 
		"cb;[1#].80|;" },
/* RET 199 */   { CCSELMASK , CCSELNZ, 
		"c0;" },
/* RET 200 */   { CCSELMASK , CCSELZ, 
		"c8;" },
/* RET 201 */   { CCSELMASK , CCSELNC, 
		"d0;" },
/* RET 202 */   { CCSELMASK , CCSELC, 
		"d8;" },
/* RET 203 */   { CCSELMASK , CCSELPO, 
		"e0;" },
/* RET 204 */   { CCSELMASK , CCSELPE, 
		"e8;" },
/* RET 205 */   { CCSELMASK , CCSELP, 
		"f0;" },
/* RET 206 */   { CCSELMASK , CCSELM, 
		"f8;" },
/* RET 207 */   { 0 , 0, 
		"c9;" },
/* RETI 208 */   { TSZ80PLUS , TSZ80PLUS, 
		"ed;4d;" },
/* RETN 209 */   { TSZ80PLUS , TSZ80PLUS, 
		"ed;45;" },
/* RIM 210 */   { CPUMASK , CPU8085, 
		"20;" },
/* RL 211 */   { TSZ80PLUS , TSZ80PLUS, 
		"cb;16;" },
/* RL 212 */   { DRMASK|TSZ80PLUS , TSZ80PLUS|DRIX, 
		"dd;cb;[1=]r16;" },
/* RL 213 */   { DRMASK|TSZ80PLUS , TSZ80PLUS|DRIY, 
		"fd;cb;[1=]r16;" },
/* RL 214 */   { TSZ80PLUS , TSZ80PLUS, 
		"cb;10.[1#]|;" },
/* RLA 215 */   { 0 , 0, 
		"17;" },
/* RLC 216 */   { TSZ80PLUS , TSZ80PLUS, 
		"cb;06;" },
/* RLC 217 */   { DRMASK|TSZ80PLUS , TSZ80PLUS|DRIX, 
		"dd;cb;[1=]r06;" },
/* RLC 218 */   { DRMASK|TSZ80PLUS , TSZ80PLUS|DRIY, 
		"fd;cb;[1=]r06;" },
/* RLC 219 */   { TSZ80PLUS , TSZ80PLUS, 
		"cb;00.[1#]|;" },
/* RLCA 220 */   { 0 , 0, 
		"07;" },
/* RLD 221 */   { TSZ80PLUS , TSZ80PLUS, 
		"ed;6f;" },
/* RR 222 */   { TSZ80PLUS , TSZ80PLUS, 
		"cb;1e;" },
/* RR 223 */   { DRMASK|TSZ80PLUS , TSZ80PLUS|DRIX, 
		"dd;cb;[1=]r1e;" },
/* RR 224 */   { DRMASK|TSZ80PLUS , TSZ80PLUS|DRIY, 
		"fd;cb;[1=]r1e;" },
/* RR 225 */   { TSZ80PLUS , TSZ80PLUS, 
		"cb;18.[1#]|;" },
/* RRA 226 */   { 0 , 0, 
		"1f;" },
/* RRC 227 */   { TSZ80PLUS , TSZ80PLUS, 
		"cb;0e;" },
/* RRC 228 */   { DRMASK|TSZ80PLUS , TSZ80PLUS|DRIX, 
		"dd;cb;[1=]r0e;" },
/* RRC 229 */   { DRMASK|TSZ80PLUS , TSZ80PLUS|DRIY, 
		"fd;cb;[1=]r0e;" },
/* RRC 230 */   { TSZ80PLUS , TSZ80PLUS, 
		"cb;08.[1#]|;" },
/* RRCA 231 */   { 0 , 0, 
		"0f;" },
/* RRD 232 */   { TSZ80PLUS , TSZ80PLUS, 
		"ed;67;" },
/* RST 233 */   { 0 , 0, 
		"c7.[1#]|;" },
/* SBC 234 */   { TSZ80PLUS|DRDESTMASK|DRMASK , TSZ80PLUS|DRDESTHL|DRBC, 
		"ed;42;" },
/* SBC 235 */   { TSZ80PLUS|DRDESTMASK|DRMASK , TSZ80PLUS|DRDESTHL|DRDE, 
		"ed;52;" },
/* SBC 236 */   { TSZ80PLUS|DRDESTMASK|DRMASK , TSZ80PLUS|DRDESTHL|DRHL, 
		"ed;62;" },
/* SBC 237 */   { TSZ80PLUS|DRDESTMASK|DRMASK , TSZ80PLUS|DRDESTHL|DRSP, 
		"ed;72;" },
/* SBC 238 */   { REGISA , REGISA, 
		"9e;" },
/* SBC 239 */   { REGISA , REGISA, 
		"de;[1=];" },
/* SBC 240 */   { REGISA|TSZ80PLUS|DRMASK , TSZ80PLUS|DRIX|REGISA, 
		"dd;9e;[1=]r" },
/* SBC 241 */   { REGISA|TSZ80PLUS|DRMASK , TSZ80PLUS|DRIY|REGISA, 
		"fd;9e;[1=]r" },
/* SBC 242 */   { REGISA|0 , 0|REGISA, 
		"98.[1#]|;" },
/* SCF 243 */   { 0 , 0, 
		"37;" },
/* SET 244 */   { TSZ80PLUS , TSZ80PLUS, 
		"cb;[1#].c6|;" },
/* SET 245 */   { TSZ80PLUS|DRMASK , TSZ80PLUS|DRIX, 
		"dd;cb;[2=]rc6.[1#]|;" },
/* SET 246 */   { TSZ80PLUS|DRMASK , TSZ80PLUS|DRIY, 
		"fd;cb;[2=]rc6.[1#]|;" },
/* SET 247 */   { TSZ80PLUS , TSZ80PLUS, 
		"cb;[1#].c0|;" },
/* SIM 248 */   { CPUMASK , CPU8085, 
		"30;" },
/* SLA 249 */   { TSZ80PLUS , TSZ80PLUS, 
		"cb;26;" },
/* SLA 250 */   { DRMASK|TSZ80PLUS , TSZ80PLUS|DRIX, 
		"dd;cb;[1=]r26;" },
/* SLA 251 */   { DRMASK|TSZ80PLUS , TSZ80PLUS|DRIY, 
		"fd;cb;[1=]r26;" },
/* SLA 252 */   { TSZ80PLUS , TSZ80PLUS, 
		"cb;20.[1#]|;" },
/* SLP 253 */   { TS64180 , TS64180, 
		"ed;76;" },
/* SRA 254 */   { TSZ80PLUS , TSZ80PLUS, 
		"cb;2e;" },
/* SRA 255 */   { DRMASK|TSZ80PLUS , TSZ80PLUS|DRIX, 
		"dd;cb;[1=]r2e;" },
/* SRA 256 */   { DRMASK|TSZ80PLUS , TSZ80PLUS|DRIY, 
		"fd;cb;[1=]r2e;" },
/* SRA 257 */   { TSZ80PLUS , TSZ80PLUS, 
		"cb;28.[1#]|;" },
/* SRL 258 */   { TSZ80PLUS , TSZ80PLUS, 
		"cb;3e;" },
/* SRL 259 */   { DRMASK|TSZ80PLUS , TSZ80PLUS|DRIX, 
		"dd;cb;[1=]r3e;" },
/* SRL 260 */   { DRMASK|TSZ80PLUS , TSZ80PLUS|DRIY, 
		"fd;cb;[1=]r3e;" },
/* SRL 261 */   { TSZ80PLUS , TSZ80PLUS, 
		"cb;38.[1#]|;" },
/* SUB 262 */   { 0 , 0, 
		"96;" },
/* SUB 263 */   { 0 , 0, 
		"d6;[1=];" },
/* SUB 264 */   { DRMASK|TSZ80PLUS , TSZ80PLUS|DRIX, 
		"dd;96;[1=]r" },
/* SUB 265 */   { DRMASK|TSZ80PLUS , TSZ80PLUS|DRIY, 
		"fd;96;[1=]r" },
/* SUB 266 */   { 0 , 0, 
		"90.[1#]|;" },
/* TST 267 */   { TS64180 , TS64180, 
		"ed;34;" },
/* TST 268 */   { TS64180 , TS64180, 
		"ed;64;[1=];" },
/* TST 269 */   { TS64180 , TS64180, 
		"ed;04.[2#]|;" },
/* TSTIO 270 */   { TS64180 , TS64180, 
		"ed;74;[1=];" },
/* XOR 271 */   { 0 , 0, 
		"ae;" },
/* XOR 272 */   { 0 , 0, 
		"ee;[1=];" },
/* XOR 273 */   { DRMASK|TSZ80PLUS , TSZ80PLUS|DRIX, 
		"dd;ae;[1=]r" },
/* XOR 274 */   { DRMASK|TSZ80PLUS , TSZ80PLUS|DRIY, 
		"fd;ae;[1=]r" },
/* XOR 275 */   { 0 , 0, 
		"a8.[1#]|;" },
	{ 0,0,""} };
/* end fraptabdef.c */
