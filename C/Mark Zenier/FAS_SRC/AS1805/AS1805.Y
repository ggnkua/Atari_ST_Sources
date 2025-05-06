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
FILENAME: 	as1805.y;
WARNINGS: 	"This software is in the public domain.  
		Any prior copyright claims are relinquished.  

		This software is distributed with no warranty whatever.  
		The author takes no responsibility for the consequences 
		of its use.

		Yacc (or Bison) required to compile."  ;
SEE-ALSO: 	as1805.doc,frasmain.c;	
AUTHORS: 	Mark Zenier;
COMPILERS: 	Microport Sys V/AT, ATT Yacc, Turbo C V1.5, Bison (CUG disk 285)
		(previous versions Xenix, Unisoft 68000 Version 7, Sun 3);
*/
/* RCA 1802 instruction generation file */
/* November 17, 1990 - character set support */

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

#define CPUMASK		0xc000
#define CPU1802		0x4000	
#define CPU1805		0xc000
#define TS1802PLUS	0x4000	/* mask and match values in table */
#define TS1805	0x8000	/* if select value & mask == mask */
#define ST_INH 0x1
#define ST_IMM 0x2
#define ST_EXP 0x4
#define ST_IO 0x1
#define ST_REG 0x1
#define ST_LDN 0x1
#define ST_RLDI 0x1
#define ST_DBNZ 0x1
	
	int	cpuselect = CPU1805;
	static char	genbdef[] = "[1=];";
	static char	genwdef[] = "[1=]x"; /* x for normal, y for byte rev */
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
%token <intv> KOC_ioop
%token <intv> KOC_regop
%token <intv> KOC_ldn
%token <intv> KOC_rldi
%token <intv> KOC_dbnz

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
		locctr += geninstr( findgen( $1, ST_INH, cpuselect
				));
			}
	;
genline : KOC_opcode  '#' expr
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1, $3);
		locctr += geninstr( findgen( $1, ST_IMM, cpuselect
				));
			}
	;
genline : KOC_opcode  expr
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1, $2);
		locctr += geninstr( findgen( $1, ST_EXP, cpuselect
				));
			}
	;
genline : KOC_ioop  expr
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1, $2);
		if(evalr[1].seg != SSG_ABS
			|| evalr[1].value < 1
			|| evalr[1].value > 7 )
		{
			fraerror("invalid IO port");
			evalr[1].value = 0;
		}
		locctr += geninstr( findgen( $1, ST_IO, cpuselect
				));
			}
	;
genline : KOC_regop  expr
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1, $2);
		if(evalr[1].seg != SSG_ABS
			|| evalr[1].value < 0
			|| evalr[1].value > 15  )
		{
			fraerror("invalid register expression");
			evalr[1].value = 0;
		}
		locctr += geninstr( findgen( $1, ST_REG, cpuselect
				));
			}
	;
genline : KOC_ldn  expr
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1, $2);
		if(evalr[1].seg != SSG_ABS
			|| evalr[1].value < 1
			|| evalr[1].value > 15  )
		{
			fraerror("invalid register expression");
			evalr[1].value = 0;
		}
		locctr += geninstr( findgen( $1, ST_LDN, cpuselect
				));
			}
	;
genline : KOC_rldi  expr ',' '#' expr
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1, $2);
		pevalexpr(2, $5);
		if(evalr[1].seg != SSG_ABS
			|| evalr[1].value < 0
			|| evalr[1].value > 15  )
		{
			fraerror("invalid register expression");
			evalr[1].value = 0;
		}
		locctr += geninstr( findgen( $1, ST_RLDI, cpuselect
				));
			}
	;
genline : KOC_dbnz  expr ',' expr
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1, $2);
		pevalexpr(2, $4);
		if(evalr[1].seg != SSG_ABS
			|| evalr[1].value < 0
			|| evalr[1].value > 15  )
		{
			fraerror("invalid register expression");
			evalr[1].value = 0;
		}
		locctr += geninstr( findgen( $1, ST_DBNZ, cpuselect
				));
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
		{"02", CPU1802 },
		{"05", CPU1805 },
		{"04", CPU1805 },
		{"06", CPU1805 },
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

#define NUMOPCODE 143
#define NUMSYNBLK 121
#define NUMDIFFOP 121

int gnumopcode = NUMOPCODE;

int ophashlnk[NUMOPCODE];

struct opsym optab[NUMOPCODE+1]
	= {
	{"invalid", KOC_opcode, 2, 0 },
	{"ADC", KOC_opcode, 1, 2 },
	{"ADCI", KOC_opcode, 1, 3 },
	{"ADD", KOC_opcode, 1, 4 },
	{"ADI", KOC_opcode, 1, 5 },
	{"AND", KOC_opcode, 1, 6 },
	{"ANI", KOC_opcode, 1, 7 },
	{"B1", KOC_opcode, 1, 8 },
	{"B2", KOC_opcode, 1, 9 },
	{"B3", KOC_opcode, 1, 10 },
	{"B4", KOC_opcode, 1, 11 },
	{"BCI", KOC_opcode, 1, 12 },
	{"BDF", KOC_opcode, 1, 13 },
	{"BGE", KOC_opcode, 1, 14 },
	{"BL", KOC_opcode, 1, 15 },
	{"BM", KOC_opcode, 1, 16 },
	{"BN1", KOC_opcode, 1, 17 },
	{"BN2", KOC_opcode, 1, 18 },
	{"BN3", KOC_opcode, 1, 19 },
	{"BN4", KOC_opcode, 1, 20 },
	{"BNF", KOC_opcode, 1, 21 },
	{"BNQ", KOC_opcode, 1, 22 },
	{"BNZ", KOC_opcode, 1, 23 },
	{"BPZ", KOC_opcode, 1, 24 },
	{"BQ", KOC_opcode, 1, 25 },
	{"BR", KOC_opcode, 1, 26 },
	{"BXI", KOC_opcode, 1, 27 },
	{"BYTE", KOC_BDEF, 0, 0 },
	{"BZ", KOC_opcode, 1, 28 },
	{"CHARDEF", KOC_CHDEF, 0, 0 },
	{"CHARSET", KOC_CHSET, 0, 0 },
	{"CHARUSE", KOC_CHUSE, 0, 0 },
	{"CHD", KOC_CHDEF, 0, 0 },
	{"CID", KOC_opcode, 1, 29 },
	{"CIE", KOC_opcode, 1, 30 },
	{"DACI", KOC_opcode, 1, 31 },
	{"DADC", KOC_opcode, 1, 32 },
	{"DADD", KOC_opcode, 1, 33 },
	{"DADI", KOC_opcode, 1, 34 },
	{"DB", KOC_BDEF, 0, 0 },
	{"DBNZ", KOC_dbnz, 1, 35 },
	{"DEC", KOC_regop, 1, 36 },
	{"DIS", KOC_opcode, 1, 37 },
	{"DSAV", KOC_opcode, 1, 38 },
	{"DSBI", KOC_opcode, 1, 39 },
	{"DSM", KOC_opcode, 1, 40 },
	{"DSMB", KOC_opcode, 1, 41 },
	{"DSMI", KOC_opcode, 1, 42 },
	{"DTC", KOC_opcode, 1, 43 },
	{"DW", KOC_WDEF, 0, 0 },
	{"ELSE", KOC_ELSE, 0, 0 },
	{"END", KOC_END, 0, 0 },
	{"ENDI", KOC_ENDI, 0, 0 },
	{"EQU", KOC_EQU, 0, 0 },
	{"ETQ", KOC_opcode, 1, 44 },
	{"FCB", KOC_BDEF, 0, 0 },
	{"FCC", KOC_SDEF, 0, 0 },
	{"FDB", KOC_WDEF, 0, 0 },
	{"GEC", KOC_opcode, 1, 45 },
	{"GHI", KOC_regop, 1, 46 },
	{"GLO", KOC_regop, 1, 47 },
	{"IDL", KOC_opcode, 1, 48 },
	{"IF", KOC_IF, 0, 0 },
	{"INC", KOC_regop, 1, 49 },
	{"INCL", KOC_INCLUDE, 0, 0 },
	{"INCLUDE", KOC_INCLUDE, 0, 0 },
	{"INP", KOC_ioop, 1, 50 },
	{"IRX", KOC_opcode, 1, 51 },
	{"LBDF", KOC_opcode, 1, 52 },
	{"LBNF", KOC_opcode, 1, 53 },
	{"LBNQ", KOC_opcode, 1, 54 },
	{"LBNZ", KOC_opcode, 1, 55 },
	{"LBQ", KOC_opcode, 1, 56 },
	{"LBR", KOC_opcode, 1, 57 },
	{"LBZ", KOC_opcode, 1, 58 },
	{"LDA", KOC_regop, 1, 59 },
	{"LDC", KOC_opcode, 1, 60 },
	{"LDI", KOC_opcode, 1, 61 },
	{"LDN", KOC_ldn, 1, 62 },
	{"LDX", KOC_opcode, 1, 63 },
	{"LDXA", KOC_opcode, 1, 64 },
	{"LSDF", KOC_opcode, 1, 65 },
	{"LSIE", KOC_opcode, 1, 66 },
	{"LSKP", KOC_opcode, 1, 67 },
	{"LSNF", KOC_opcode, 1, 68 },
	{"LSNQ", KOC_opcode, 1, 69 },
	{"LSNZ", KOC_opcode, 1, 70 },
	{"LSQ", KOC_opcode, 1, 71 },
	{"LSZ", KOC_opcode, 1, 72 },
	{"MARK", KOC_opcode, 1, 73 },
	{"NBR", KOC_opcode, 1, 74 },
	{"NLBR", KOC_opcode, 1, 75 },
	{"NOP", KOC_opcode, 1, 76 },
	{"OR", KOC_opcode, 1, 77 },
	{"ORG", KOC_ORG, 0, 0 },
	{"ORI", KOC_opcode, 1, 78 },
	{"OUT", KOC_ioop, 1, 79 },
	{"PHI", KOC_regop, 1, 80 },
	{"PLO", KOC_regop, 1, 81 },
	{"REQ", KOC_opcode, 1, 82 },
	{"RESERVE", KOC_RESM, 0, 0 },
	{"RET", KOC_opcode, 1, 83 },
	{"RLDI", KOC_rldi, 1, 84 },
	{"RLXA", KOC_regop, 1, 85 },
	{"RMB", KOC_RESM, 0, 0 },
	{"RNX", KOC_regop, 1, 86 },
	{"RSHL", KOC_opcode, 1, 87 },
	{"RSHR", KOC_opcode, 1, 88 },
	{"RSXD", KOC_regop, 1, 89 },
	{"SAV", KOC_opcode, 1, 90 },
	{"SCAL", KOC_dbnz, 1, 91 },
	{"SCM1", KOC_opcode, 1, 92 },
	{"SCM2", KOC_opcode, 1, 93 },
	{"SD", KOC_opcode, 1, 94 },
	{"SDB", KOC_opcode, 1, 95 },
	{"SDBI", KOC_opcode, 1, 96 },
	{"SDI", KOC_opcode, 1, 97 },
	{"SEP", KOC_regop, 1, 98 },
	{"SEQ", KOC_opcode, 1, 99 },
	{"SET", KOC_SET, 0, 0 },
	{"SEX", KOC_regop, 1, 100 },
	{"SHL", KOC_opcode, 1, 101 },
	{"SHLC", KOC_opcode, 1, 102 },
	{"SHR", KOC_opcode, 1, 103 },
	{"SHRC", KOC_opcode, 1, 104 },
	{"SKP", KOC_opcode, 1, 105 },
	{"SM", KOC_opcode, 1, 106 },
	{"SMB", KOC_opcode, 1, 107 },
	{"SMBI", KOC_opcode, 1, 108 },
	{"SMI", KOC_opcode, 1, 109 },
	{"SPM1", KOC_opcode, 1, 110 },
	{"SPM2", KOC_opcode, 1, 111 },
	{"SRET", KOC_regop, 1, 112 },
	{"STM", KOC_opcode, 1, 113 },
	{"STPC", KOC_opcode, 1, 114 },
	{"STR", KOC_regop, 1, 115 },
	{"STRING", KOC_SDEF, 0, 0 },
	{"STXD", KOC_opcode, 1, 116 },
	{"WORD", KOC_WDEF, 0, 0 },
	{"XID", KOC_opcode, 1, 117 },
	{"XIE", KOC_opcode, 1, 118 },
	{"XOR", KOC_opcode, 1, 119 },
	{"XRI", KOC_opcode, 1, 120 },
	{ "", 0, 0, 0 }};

struct opsynt ostab[NUMSYNBLK+1]
	= {
/* invalid 0 */ { 0, 1, 0 },
/* invalid 1 */ { 0xffff, 1, 1 },
/* ADC 2 */ { ST_INH, 1, 2 },
/* ADCI 3 */ { ST_IMM, 1, 3 },
/* ADD 4 */ { ST_INH, 1, 4 },
/* ADI 5 */ { ST_IMM, 1, 5 },
/* AND 6 */ { ST_INH, 1, 6 },
/* ANI 7 */ { ST_IMM, 1, 7 },
/* B1 8 */ { ST_EXP, 1, 8 },
/* B2 9 */ { ST_EXP, 1, 9 },
/* B3 10 */ { ST_EXP, 1, 10 },
/* B4 11 */ { ST_EXP, 1, 11 },
/* BCI 12 */ { ST_EXP, 1, 12 },
/* BDF 13 */ { ST_EXP, 1, 13 },
/* BGE 14 */ { ST_EXP, 1, 14 },
/* BL 15 */ { ST_EXP, 1, 15 },
/* BM 16 */ { ST_EXP, 1, 16 },
/* BN1 17 */ { ST_EXP, 1, 17 },
/* BN2 18 */ { ST_EXP, 1, 18 },
/* BN3 19 */ { ST_EXP, 1, 19 },
/* BN4 20 */ { ST_EXP, 1, 20 },
/* BNF 21 */ { ST_EXP, 1, 21 },
/* BNQ 22 */ { ST_EXP, 1, 22 },
/* BNZ 23 */ { ST_EXP, 1, 23 },
/* BPZ 24 */ { ST_EXP, 1, 24 },
/* BQ 25 */ { ST_EXP, 1, 25 },
/* BR 26 */ { ST_EXP, 1, 26 },
/* BXI 27 */ { ST_EXP, 1, 27 },
/* BZ 28 */ { ST_EXP, 1, 28 },
/* CID 29 */ { ST_INH, 1, 29 },
/* CIE 30 */ { ST_INH, 1, 30 },
/* DACI 31 */ { ST_IMM, 1, 31 },
/* DADC 32 */ { ST_INH, 1, 32 },
/* DADD 33 */ { ST_INH, 1, 33 },
/* DADI 34 */ { ST_IMM, 1, 34 },
/* DBNZ 35 */ { ST_DBNZ, 1, 35 },
/* DEC 36 */ { ST_REG, 1, 36 },
/* DIS 37 */ { ST_INH, 1, 37 },
/* DSAV 38 */ { ST_INH, 1, 38 },
/* DSBI 39 */ { ST_IMM, 1, 39 },
/* DSM 40 */ { ST_INH, 1, 40 },
/* DSMB 41 */ { ST_INH, 1, 41 },
/* DSMI 42 */ { ST_IMM, 1, 42 },
/* DTC 43 */ { ST_INH, 1, 43 },
/* ETQ 44 */ { ST_INH, 1, 44 },
/* GEC 45 */ { ST_INH, 1, 45 },
/* GHI 46 */ { ST_REG, 1, 46 },
/* GLO 47 */ { ST_REG, 1, 47 },
/* IDL 48 */ { ST_INH, 1, 48 },
/* INC 49 */ { ST_REG, 1, 49 },
/* INP 50 */ { ST_IO, 1, 50 },
/* IRX 51 */ { ST_INH, 1, 51 },
/* LBDF 52 */ { ST_EXP, 1, 52 },
/* LBNF 53 */ { ST_EXP, 1, 53 },
/* LBNQ 54 */ { ST_EXP, 1, 54 },
/* LBNZ 55 */ { ST_EXP, 1, 55 },
/* LBQ 56 */ { ST_EXP, 1, 56 },
/* LBR 57 */ { ST_EXP, 1, 57 },
/* LBZ 58 */ { ST_EXP, 1, 58 },
/* LDA 59 */ { ST_REG, 1, 59 },
/* LDC 60 */ { ST_INH, 1, 60 },
/* LDI 61 */ { ST_IMM, 1, 61 },
/* LDN 62 */ { ST_LDN, 1, 62 },
/* LDX 63 */ { ST_INH, 1, 63 },
/* LDXA 64 */ { ST_INH, 1, 64 },
/* LSDF 65 */ { ST_INH, 1, 65 },
/* LSIE 66 */ { ST_INH, 1, 66 },
/* LSKP 67 */ { ST_INH, 1, 67 },
/* LSNF 68 */ { ST_INH, 1, 68 },
/* LSNQ 69 */ { ST_INH, 1, 69 },
/* LSNZ 70 */ { ST_INH, 1, 70 },
/* LSQ 71 */ { ST_INH, 1, 71 },
/* LSZ 72 */ { ST_INH, 1, 72 },
/* MARK 73 */ { ST_INH, 1, 73 },
/* NBR 74 */ { ST_EXP, 1, 74 },
/* NLBR 75 */ { ST_EXP, 1, 75 },
/* NOP 76 */ { ST_INH, 1, 76 },
/* OR 77 */ { ST_INH, 1, 77 },
/* ORI 78 */ { ST_IMM, 1, 78 },
/* OUT 79 */ { ST_IO, 1, 79 },
/* PHI 80 */ { ST_REG, 1, 80 },
/* PLO 81 */ { ST_REG, 1, 81 },
/* REQ 82 */ { ST_INH, 1, 82 },
/* RET 83 */ { ST_INH, 1, 83 },
/* RLDI 84 */ { ST_RLDI, 1, 84 },
/* RLXA 85 */ { ST_REG, 1, 85 },
/* RNX 86 */ { ST_REG, 1, 86 },
/* RSHL 87 */ { ST_INH, 1, 87 },
/* RSHR 88 */ { ST_INH, 1, 88 },
/* RSXD 89 */ { ST_REG, 1, 89 },
/* SAV 90 */ { ST_INH, 1, 90 },
/* SCAL 91 */ { ST_DBNZ, 1, 91 },
/* SCM1 92 */ { ST_INH, 1, 92 },
/* SCM2 93 */ { ST_INH, 1, 93 },
/* SD 94 */ { ST_INH, 1, 94 },
/* SDB 95 */ { ST_INH, 1, 95 },
/* SDBI 96 */ { ST_IMM, 1, 96 },
/* SDI 97 */ { ST_IMM, 1, 97 },
/* SEP 98 */ { ST_REG, 1, 98 },
/* SEQ 99 */ { ST_INH, 1, 99 },
/* SEX 100 */ { ST_REG, 1, 100 },
/* SHL 101 */ { ST_INH, 1, 101 },
/* SHLC 102 */ { ST_INH, 1, 102 },
/* SHR 103 */ { ST_INH, 1, 103 },
/* SHRC 104 */ { ST_INH, 1, 104 },
/* SKP 105 */ { ST_INH, 1, 105 },
/* SM 106 */ { ST_INH, 1, 106 },
/* SMB 107 */ { ST_INH, 1, 107 },
/* SMBI 108 */ { ST_IMM, 1, 108 },
/* SMI 109 */ { ST_IMM, 1, 109 },
/* SPM1 110 */ { ST_INH, 1, 110 },
/* SPM2 111 */ { ST_INH, 1, 111 },
/* SRET 112 */ { ST_REG, 1, 112 },
/* STM 113 */ { ST_INH, 1, 113 },
/* STPC 114 */ { ST_INH, 1, 114 },
/* STR 115 */ { ST_REG, 1, 115 },
/* STXD 116 */ { ST_INH, 1, 116 },
/* XID 117 */ { ST_INH, 1, 117 },
/* XIE 118 */ { ST_INH, 1, 118 },
/* XOR 119 */ { ST_INH, 1, 119 },
/* XRI 120 */ { ST_IMM, 1, 120 },
	{ 0, 0, 0 } };

struct igel igtab[NUMDIFFOP+1]
	= {
/* invalid 0 */   { 0 , 0, 
		"[Xnullentry" },
/* invalid 1 */   { 0 , 0, 
		"[Xinvalid opcode" },
/* ADC 2 */   { 0 , 0, 
		"74;" },
/* ADCI 3 */   { 0 , 0, 
		"7c;[1=];" },
/* ADD 4 */   { 0 , 0, 
		"f4;" },
/* ADI 5 */   { 0 , 0, 
		"fc;[1=];" },
/* AND 6 */   { 0 , 0, 
		"f2;" },
/* ANI 7 */   { 0 , 0, 
		"fa;[1=];" },
/* B1 8 */   { 0 , 0, 
		"34;[1=].Q.ff00&-~.0<T!;" },
/* B2 9 */   { 0 , 0, 
		"35;[1=].Q.ff00&-~.0<T!;" },
/* B3 10 */   { 0 , 0, 
		"36;[1=].Q.ff00&-~.0<T!;" },
/* B4 11 */   { 0 , 0, 
		"37;[1=].Q.ff00&-~.0<T!;" },
/* BCI 12 */   { TS1805 , TS1805, 
		"68;3e;[1=].Q.ff00&-~.0<T!;" },
/* BDF 13 */   { 0 , 0, 
		"33;[1=].Q.ff00&-~.0<T!;" },
/* BGE 14 */   { 0 , 0, 
		"33;[1=].Q.ff00&-~.0<T!;" },
/* BL 15 */   { 0 , 0, 
		"3b;[1=].Q.ff00&-~.0<T!;" },
/* BM 16 */   { 0 , 0, 
		"3b;[1=].Q.ff00&-~.0<T!;" },
/* BN1 17 */   { 0 , 0, 
		"3c;[1=].Q.ff00&-~.0<T!;" },
/* BN2 18 */   { 0 , 0, 
		"3d;[1=].Q.ff00&-~.0<T!;" },
/* BN3 19 */   { 0 , 0, 
		"3e;[1=].Q.ff00&-~.0<T!;" },
/* BN4 20 */   { 0 , 0, 
		"3f;[1=].Q.ff00&-~.0<T!;" },
/* BNF 21 */   { 0 , 0, 
		"3b;[1=].Q.ff00&-~.0<T!;" },
/* BNQ 22 */   { 0 , 0, 
		"39;[1=].Q.ff00&-~.0<T!;" },
/* BNZ 23 */   { 0 , 0, 
		"3a;[1=].Q.ff00&-~.0<T!;" },
/* BPZ 24 */   { 0 , 0, 
		"33;[1=].Q.ff00&-~.0<T!;" },
/* BQ 25 */   { 0 , 0, 
		"31;[1=].Q.ff00&-~.0<T!;" },
/* BR 26 */   { 0 , 0, 
		"30;[1=].Q.ff00&-~.0<T!;" },
/* BXI 27 */   { TS1805 , TS1805, 
		"68;3f;[1=].Q.ff00&-~.0<T!;" },
/* BZ 28 */   { 0 , 0, 
		"32;[1=].Q.ff00&-~.0<T!;" },
/* CID 29 */   { TS1805 , TS1805, 
		"68;0d;" },
/* CIE 30 */   { TS1805 , TS1805, 
		"68;0c;" },
/* DACI 31 */   { TS1805 , TS1805, 
		"68;7c;[1=];" },
/* DADC 32 */   { TS1805 , TS1805, 
		"68;74;" },
/* DADD 33 */   { TS1805 , TS1805, 
		"68;f4;" },
/* DADI 34 */   { TS1805 , TS1805, 
		"68;fc;[1=];" },
/* DBNZ 35 */   { TS1805 , TS1805, 
		"68;20.[1#]|;[2=]x" },
/* DEC 36 */   { 0 , 0, 
		"20.[1#]|;" },
/* DIS 37 */   { 0 , 0, 
		"71;" },
/* DSAV 38 */   { TS1805 , TS1805, 
		"68;76;" },
/* DSBI 39 */   { TS1805 , TS1805, 
		"68;7f;[1=];" },
/* DSM 40 */   { TS1805 , TS1805, 
		"68;f7;" },
/* DSMB 41 */   { TS1805 , TS1805, 
		"68;77;" },
/* DSMI 42 */   { TS1805 , TS1805, 
		"68;ff;[1=];" },
/* DTC 43 */   { TS1805 , TS1805, 
		"68;01;" },
/* ETQ 44 */   { TS1805 , TS1805, 
		"68;09;" },
/* GEC 45 */   { TS1805 , TS1805, 
		"68;08;" },
/* GHI 46 */   { 0 , 0, 
		"90.[1#]|;" },
/* GLO 47 */   { 0 , 0, 
		"80.[1#]|;" },
/* IDL 48 */   { 0 , 0, 
		"00;" },
/* INC 49 */   { 0 , 0, 
		"10.[1#]|;" },
/* INP 50 */   { 0 , 0, 
		"68.[1#]|;" },
/* IRX 51 */   { 0 , 0, 
		"60;" },
/* LBDF 52 */   { 0 , 0, 
		"c3;[1=]x" },
/* LBNF 53 */   { 0 , 0, 
		"cb;[1=]x" },
/* LBNQ 54 */   { 0 , 0, 
		"c9;[1=]x" },
/* LBNZ 55 */   { 0 , 0, 
		"ca;[1=]x" },
/* LBQ 56 */   { 0 , 0, 
		"c1;[1=]x" },
/* LBR 57 */   { 0 , 0, 
		"c0;[1=]x" },
/* LBZ 58 */   { 0 , 0, 
		"c2;[1=]x" },
/* LDA 59 */   { 0 , 0, 
		"40.[1#]|;" },
/* LDC 60 */   { TS1805 , TS1805, 
		"68;06;" },
/* LDI 61 */   { 0 , 0, 
		"f8;[1=];" },
/* LDN 62 */   { 0 , 0, 
		"00.[1#]|;" },
/* LDX 63 */   { 0 , 0, 
		"f0;" },
/* LDXA 64 */   { 0 , 0, 
		"72;" },
/* LSDF 65 */   { 0 , 0, 
		"cf;" },
/* LSIE 66 */   { 0 , 0, 
		"cc;" },
/* LSKP 67 */   { 0 , 0, 
		"c8;" },
/* LSNF 68 */   { 0 , 0, 
		"c7;" },
/* LSNQ 69 */   { 0 , 0, 
		"c5;" },
/* LSNZ 70 */   { 0 , 0, 
		"c6;" },
/* LSQ 71 */   { 0 , 0, 
		"cd;" },
/* LSZ 72 */   { 0 , 0, 
		"ce;" },
/* MARK 73 */   { 0 , 0, 
		"79;" },
/* NBR 74 */   { 0 , 0, 
		"38;[1=].Q.ff00&-~.0<T!;" },
/* NLBR 75 */   { 0 , 0, 
		"c8;[1=]x" },
/* NOP 76 */   { 0 , 0, 
		"c4;" },
/* OR 77 */   { 0 , 0, 
		"f1;" },
/* ORI 78 */   { 0 , 0, 
		"f9;[1=];" },
/* OUT 79 */   { 0 , 0, 
		"60.[1#]|;" },
/* PHI 80 */   { 0 , 0, 
		"b0.[1#]|;" },
/* PLO 81 */   { 0 , 0, 
		"a0.[1#]|;" },
/* REQ 82 */   { 0 , 0, 
		"7a;" },
/* RET 83 */   { 0 , 0, 
		"70;" },
/* RLDI 84 */   { TS1805 , TS1805, 
		"68;c0.[1#]|;[2=]x" },
/* RLXA 85 */   { TS1805 , TS1805, 
		"68;60.[1#]|;" },
/* RNX 86 */   { TS1805 , TS1805, 
		"68;b0.[1#]|;" },
/* RSHL 87 */   { 0 , 0, 
		"7e;" },
/* RSHR 88 */   { 0 , 0, 
		"76;" },
/* RSXD 89 */   { TS1805 , TS1805, 
		"68;a0.[1#]|;" },
/* SAV 90 */   { 0 , 0, 
		"78;" },
/* SCAL 91 */   { TS1805 , TS1805, 
		"68;80.[1#]|;[2=]x" },
/* SCM1 92 */   { TS1805 , TS1805, 
		"68;05;" },
/* SCM2 93 */   { TS1805 , TS1805, 
		"68;03;" },
/* SD 94 */   { 0 , 0, 
		"f5;" },
/* SDB 95 */   { 0 , 0, 
		"75;" },
/* SDBI 96 */   { 0 , 0, 
		"7d;[1=];" },
/* SDI 97 */   { 0 , 0, 
		"fd;[1=];" },
/* SEP 98 */   { 0 , 0, 
		"d0.[1#]|;" },
/* SEQ 99 */   { 0 , 0, 
		"7b;" },
/* SEX 100 */   { 0 , 0, 
		"e0.[1#]|;" },
/* SHL 101 */   { 0 , 0, 
		"fe;" },
/* SHLC 102 */   { 0 , 0, 
		"7e;" },
/* SHR 103 */   { 0 , 0, 
		"f6;" },
/* SHRC 104 */   { 0 , 0, 
		"76;" },
/* SKP 105 */   { 0 , 0, 
		"38;" },
/* SM 106 */   { 0 , 0, 
		"f7;" },
/* SMB 107 */   { 0 , 0, 
		"77;" },
/* SMBI 108 */   { 0 , 0, 
		"7f;[1=];" },
/* SMI 109 */   { 0 , 0, 
		"ff;[1=];" },
/* SPM1 110 */   { TS1805 , TS1805, 
		"68;04;" },
/* SPM2 111 */   { TS1805 , TS1805, 
		"68;02;" },
/* SRET 112 */   { TS1805 , TS1805, 
		"68;90.[1#]|;" },
/* STM 113 */   { TS1805 , TS1805, 
		"68;07;" },
/* STPC 114 */   { TS1805 , TS1805, 
		"68;00;" },
/* STR 115 */   { 0 , 0, 
		"50.[1#]|;" },
/* STXD 116 */   { 0 , 0, 
		"73;" },
/* XID 117 */   { TS1805 , TS1805, 
		"68;0b;" },
/* XIE 118 */   { TS1805 , TS1805, 
		"68;0a;" },
/* XOR 119 */   { 0 , 0, 
		"f3;" },
/* XRI 120 */   { 0 , 0, 
		"fb;[1=];" },
	{ 0,0,""} };
/* end fraptabdef.c */
