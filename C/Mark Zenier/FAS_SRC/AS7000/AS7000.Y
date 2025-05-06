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
FILENAME: 	as7000.y;
WARNINGS: 	"The language defined in this file does
		not follow the standard Texas Instruments syntax.

		This software is in the public domain.  
		Any prior copyright claims are relinquished.  

		This software is distributed with no warranty whatever.  
		The author takes no responsibility for the consequences 
		of its use.

		Yacc (or Bison) required to compile."  ;
SEE-ALSO: 	as7000.doc,frasmain.c;	
AUTHORS: 	Mark Zenier;
COMPILERS: 	Microport Sys V/AT, ATT Yacc, Turbo C V1.5, Bison (CUG disk 285)
		(previous versions Xenix, Unisoft 68000 Version 7, Sun 3);
*/
/* TMS7000 instruction generation file */
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

 /*	0000.0000.0000.00xx */
#define	DSTMASK		0x3
#define	DSTA		0x1
#define	DSTB		0x2
 /* 	0000.0000.0000.xx00 */
#define	SRCMASK		0xc
#define	SRCA		0x4
#define	SRCB		0x8
#define ST_INH 0x1
#define ST_EXPR 0x2
#define ST_EXPR2 0x4
#define ST_EXPR3 0x8
#define ST_IEXPR2 0x10
#define ST_IEXPR3 0x20
#define ST_INDEX 0x40
#define ST_IMMIND 0x80
#define ST_RINDIR 0x100
#define ST_STATUS 0x200
	
	static int operselbits;
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

%token STATUS
%token <intv> REG
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
		locctr += geninstr(findgen($1, ST_INH,  0));
			}
	;
genline : KOC_opcode  expr
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1,$2);
		operselbits = 0;
		if(evalr[1].seg == SSG_ABS)
		{
			if(evalr[1].value == 0)
			{
				operselbits |= DSTA;
			}
			else if(evalr[1].value == 1)
			{
				operselbits |= DSTB;
			}
		}	
		locctr += geninstr(findgen($1, ST_EXPR, operselbits));
			}
	;
genline : KOC_opcode  expr ',' expr
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1,$2);
		pevalexpr(2,$4);
		operselbits = 0;
		if(evalr[1].seg == SSG_ABS)
		{
			if(evalr[1].value == 0)
			{
				operselbits |= SRCA;
			}
			else if(evalr[1].value == 1)
			{
				operselbits |= SRCB;
			}
		}	
		if(evalr[2].seg == SSG_ABS)
		{
			if(evalr[2].value == 0)
			{
				operselbits |= DSTA;
			}
			else if(evalr[2].value == 1)
			{
				operselbits |= DSTB;
			}
		}	
		locctr += geninstr(findgen($1, ST_EXPR2, operselbits));
			}
	;
genline : KOC_opcode  expr ',' expr ',' expr
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1,$2);
		pevalexpr(2,$4);
		pevalexpr(3,$6);
		operselbits = 0;
		if(evalr[1].seg == SSG_ABS)
		{
			if(evalr[1].value == 0)
			{
				operselbits |= SRCA;
			}
			else if(evalr[1].value == 1)
			{
				operselbits |= SRCB;
			}
		}	
		if(evalr[2].seg == SSG_ABS)
		{
			if(evalr[2].value == 0)
			{
				operselbits |= DSTA;
			}
			else if(evalr[2].value == 1)
			{
				operselbits |= DSTB;
			}
		}	
		locctr += geninstr(findgen($1, ST_EXPR3, operselbits));
			}
	;
genline : KOC_opcode  '#' expr ',' expr
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1,$3);
		pevalexpr(2,$5);
		operselbits = 0;
		if(evalr[2].seg == SSG_ABS)
		{
			if(evalr[2].value == 0)
			{
				operselbits |= DSTA;
			}
			else if(evalr[2].value == 1)
			{
				operselbits |= DSTB;
			}
		}	
		locctr += geninstr(findgen($1, ST_IEXPR2, operselbits));
			}
	;
genline : KOC_opcode  '#' expr ',' expr ',' expr
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1,$3);
		pevalexpr(2,$5);
		pevalexpr(3,$7);
		operselbits = 0;
		if(evalr[2].seg == SSG_ABS)
		{
			if(evalr[2].value == 0)
			{
				operselbits |= DSTA;
			}
			else if(evalr[2].value == 1)
			{
				operselbits |= DSTB;
			}
		}	
		locctr += geninstr(findgen($1, ST_IEXPR3, operselbits));
			}
	;
genline : KOC_opcode  expr '(' REG ')'
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1,$2);
		operselbits = 0;
		if($4 == 0)
		{
			operselbits |= SRCA;
		}
		else if($4 == 1)
		{
			operselbits |= SRCB;
		}
		locctr += geninstr(findgen($1, ST_INDEX,  operselbits));
			}
	;
genline : KOC_opcode  '#' expr '(' REG ')' ',' expr
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1,$3);
		pevalexpr(2,$8);
		operselbits = 0;
		if($5 == 0)
		{
			operselbits |= SRCA;
		}
		else if($5 == 1)
		{
			operselbits |= SRCB;
		}
		locctr += geninstr(findgen($1, ST_IMMIND,  operselbits));
			}
	;
genline : KOC_opcode  '[' expr ']'
			{
		genlocrec(currseg, labelloc);
		pevalexpr(1,$3);
		locctr += geninstr(findgen($1, ST_RINDIR,  0));
			}
	;
genline : KOC_opcode   STATUS
			{
		genlocrec(currseg, labelloc);
		locctr += geninstr(findgen($1, ST_STATUS,  0));
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


expr	:	REG
		{
	$$ = exprnode(PCCASE_CONS,0,IGP_CONSTANT,0,(long)$1,SYMNULL);
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
	reservedsym("st", STATUS, 0);
	reservedsym("a", REG, 0);
	reservedsym("b", REG, 1);
	reservedsym("ST", STATUS, 0);
	reservedsym("A", REG, 0);
	reservedsym("B", REG, 1);

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

#define NUMOPCODE 92
#define NUMSYNBLK 104
#define NUMDIFFOP 213

int gnumopcode = NUMOPCODE;

int ophashlnk[NUMOPCODE];

struct opsym optab[NUMOPCODE+1]
	= {
	{"invalid", KOC_opcode, 2, 0 },
	{"ADC", KOC_opcode, 2, 2 },
	{"ADD", KOC_opcode, 2, 4 },
	{"AND", KOC_opcode, 2, 6 },
	{"ANDP", KOC_opcode, 2, 8 },
	{"BR", KOC_opcode, 3, 10 },
	{"BTJO", KOC_opcode, 2, 13 },
	{"BTJOP", KOC_opcode, 2, 15 },
	{"BTJZ", KOC_opcode, 2, 17 },
	{"BTJZP", KOC_opcode, 2, 19 },
	{"BYTE", KOC_BDEF, 0, 0 },
	{"CALL", KOC_opcode, 3, 21 },
	{"CHARDEF", KOC_CHDEF, 0, 0 },
	{"CHARSET", KOC_CHSET, 0, 0 },
	{"CHARUSE", KOC_CHUSE, 0, 0 },
	{"CHD", KOC_CHDEF, 0, 0 },
	{"CLR", KOC_opcode, 1, 24 },
	{"CLRC", KOC_opcode, 1, 25 },
	{"CMP", KOC_opcode, 2, 26 },
	{"CMPA", KOC_opcode, 3, 28 },
	{"DAC", KOC_opcode, 2, 31 },
	{"DB", KOC_BDEF, 0, 0 },
	{"DEC", KOC_opcode, 1, 33 },
	{"DECD", KOC_opcode, 1, 34 },
	{"DINT", KOC_opcode, 1, 35 },
	{"DJNZ", KOC_opcode, 1, 36 },
	{"DSB", KOC_opcode, 2, 37 },
	{"DW", KOC_WDEF, 0, 0 },
	{"EINT", KOC_opcode, 1, 39 },
	{"ELSE", KOC_ELSE, 0, 0 },
	{"END", KOC_END, 0, 0 },
	{"ENDI", KOC_ENDI, 0, 0 },
	{"EQU", KOC_EQU, 0, 0 },
	{"FCB", KOC_BDEF, 0, 0 },
	{"FCC", KOC_SDEF, 0, 0 },
	{"FDB", KOC_WDEF, 0, 0 },
	{"IDLE", KOC_opcode, 1, 40 },
	{"IF", KOC_IF, 0, 0 },
	{"INC", KOC_opcode, 1, 41 },
	{"INCL", KOC_INCLUDE, 0, 0 },
	{"INCLUDE", KOC_INCLUDE, 0, 0 },
	{"INV", KOC_opcode, 1, 42 },
	{"JC", KOC_opcode, 1, 43 },
	{"JEQ", KOC_opcode, 1, 44 },
	{"JGE", KOC_opcode, 1, 45 },
	{"JGT", KOC_opcode, 1, 46 },
	{"JHS", KOC_opcode, 1, 47 },
	{"JL", KOC_opcode, 1, 48 },
	{"JLT", KOC_opcode, 1, 49 },
	{"JMP", KOC_opcode, 1, 50 },
	{"JN", KOC_opcode, 1, 51 },
	{"JNC", KOC_opcode, 1, 52 },
	{"JNE", KOC_opcode, 1, 53 },
	{"JNZ", KOC_opcode, 1, 54 },
	{"JP", KOC_opcode, 1, 55 },
	{"JPZ", KOC_opcode, 1, 56 },
	{"JZ", KOC_opcode, 1, 57 },
	{"LDA", KOC_opcode, 3, 58 },
	{"LDSP", KOC_opcode, 1, 61 },
	{"MOV", KOC_opcode, 2, 62 },
	{"MOVD", KOC_opcode, 3, 64 },
	{"MOVP", KOC_opcode, 2, 67 },
	{"MPY", KOC_opcode, 2, 69 },
	{"NOP", KOC_opcode, 1, 71 },
	{"OR", KOC_opcode, 2, 72 },
	{"ORG", KOC_ORG, 0, 0 },
	{"ORP", KOC_opcode, 2, 74 },
	{"POP", KOC_opcode, 2, 76 },
	{"PUSH", KOC_opcode, 2, 78 },
	{"RESERVE", KOC_RESM, 0, 0 },
	{"RETI", KOC_opcode, 1, 80 },
	{"RETS", KOC_opcode, 1, 81 },
	{"RL", KOC_opcode, 1, 82 },
	{"RLC", KOC_opcode, 1, 83 },
	{"RMB", KOC_RESM, 0, 0 },
	{"RR", KOC_opcode, 1, 84 },
	{"RRC", KOC_opcode, 1, 85 },
	{"SBB", KOC_opcode, 2, 86 },
	{"SET", KOC_SET, 0, 0 },
	{"SETC", KOC_opcode, 1, 88 },
	{"STA", KOC_opcode, 3, 89 },
	{"STRING", KOC_SDEF, 0, 0 },
	{"STSP", KOC_opcode, 1, 92 },
	{"SUB", KOC_opcode, 2, 93 },
	{"SWAP", KOC_opcode, 1, 95 },
	{"TRAP", KOC_opcode, 1, 96 },
	{"TSTA", KOC_opcode, 1, 97 },
	{"TSTB", KOC_opcode, 1, 98 },
	{"WORD", KOC_WDEF, 0, 0 },
	{"XCHB", KOC_opcode, 1, 99 },
	{"XOR", KOC_opcode, 2, 100 },
	{"XORP", KOC_opcode, 2, 102 },
	{ "", 0, 0, 0 }};

struct opsynt ostab[NUMSYNBLK+1]
	= {
/* invalid 0 */ { 0, 1, 0 },
/* invalid 1 */ { 0xffff, 1, 1 },
/* ADC 2 */ { ST_EXPR2, 4, 2 },
/* ADC 3 */ { ST_IEXPR2, 3, 6 },
/* ADD 4 */ { ST_EXPR2, 4, 9 },
/* ADD 5 */ { ST_IEXPR2, 3, 13 },
/* AND 6 */ { ST_EXPR2, 4, 16 },
/* AND 7 */ { ST_IEXPR2, 3, 20 },
/* ANDP 8 */ { ST_EXPR2, 2, 23 },
/* ANDP 9 */ { ST_IEXPR2, 1, 25 },
/* BR 10 */ { ST_EXPR, 1, 26 },
/* BR 11 */ { ST_INDEX, 1, 27 },
/* BR 12 */ { ST_RINDIR, 1, 28 },
/* BTJO 13 */ { ST_EXPR3, 4, 29 },
/* BTJO 14 */ { ST_IEXPR3, 3, 33 },
/* BTJOP 15 */ { ST_EXPR3, 2, 36 },
/* BTJOP 16 */ { ST_IEXPR3, 1, 38 },
/* BTJZ 17 */ { ST_EXPR3, 4, 39 },
/* BTJZ 18 */ { ST_IEXPR3, 3, 43 },
/* BTJZP 19 */ { ST_EXPR3, 2, 46 },
/* BTJZP 20 */ { ST_IEXPR3, 1, 48 },
/* CALL 21 */ { ST_EXPR, 1, 49 },
/* CALL 22 */ { ST_INDEX, 1, 50 },
/* CALL 23 */ { ST_RINDIR, 1, 51 },
/* CLR 24 */ { ST_EXPR, 3, 52 },
/* CLRC 25 */ { ST_INH, 1, 55 },
/* CMP 26 */ { ST_EXPR2, 4, 56 },
/* CMP 27 */ { ST_IEXPR2, 3, 60 },
/* CMPA 28 */ { ST_EXPR, 1, 63 },
/* CMPA 29 */ { ST_INDEX, 1, 64 },
/* CMPA 30 */ { ST_RINDIR, 1, 65 },
/* DAC 31 */ { ST_EXPR2, 4, 66 },
/* DAC 32 */ { ST_IEXPR2, 3, 70 },
/* DEC 33 */ { ST_EXPR, 3, 73 },
/* DECD 34 */ { ST_EXPR, 3, 76 },
/* DINT 35 */ { ST_INH, 1, 79 },
/* DJNZ 36 */ { ST_EXPR2, 3, 80 },
/* DSB 37 */ { ST_EXPR2, 4, 83 },
/* DSB 38 */ { ST_IEXPR2, 3, 87 },
/* EINT 39 */ { ST_INH, 1, 90 },
/* IDLE 40 */ { ST_INH, 1, 91 },
/* INC 41 */ { ST_EXPR, 3, 92 },
/* INV 42 */ { ST_EXPR, 3, 95 },
/* JC 43 */ { ST_EXPR, 1, 98 },
/* JEQ 44 */ { ST_EXPR, 1, 99 },
/* JGE 45 */ { ST_EXPR, 1, 100 },
/* JGT 46 */ { ST_EXPR, 1, 101 },
/* JHS 47 */ { ST_EXPR, 1, 102 },
/* JL 48 */ { ST_EXPR, 1, 103 },
/* JLT 49 */ { ST_EXPR, 1, 104 },
/* JMP 50 */ { ST_EXPR, 1, 105 },
/* JN 51 */ { ST_EXPR, 1, 106 },
/* JNC 52 */ { ST_EXPR, 1, 107 },
/* JNE 53 */ { ST_EXPR, 1, 108 },
/* JNZ 54 */ { ST_EXPR, 1, 109 },
/* JP 55 */ { ST_EXPR, 1, 110 },
/* JPZ 56 */ { ST_EXPR, 1, 111 },
/* JZ 57 */ { ST_EXPR, 1, 112 },
/* LDA 58 */ { ST_EXPR, 1, 113 },
/* LDA 59 */ { ST_INDEX, 1, 114 },
/* LDA 60 */ { ST_RINDIR, 1, 115 },
/* LDSP 61 */ { ST_INH, 1, 116 },
/* MOV 62 */ { ST_EXPR2, 7, 117 },
/* MOV 63 */ { ST_IEXPR2, 3, 124 },
/* MOVD 64 */ { ST_EXPR2, 1, 127 },
/* MOVD 65 */ { ST_IEXPR2, 1, 128 },
/* MOVD 66 */ { ST_IMMIND, 1, 129 },
/* MOVP 67 */ { ST_EXPR2, 4, 130 },
/* MOVP 68 */ { ST_IEXPR2, 1, 134 },
/* MPY 69 */ { ST_EXPR2, 4, 135 },
/* MPY 70 */ { ST_IEXPR2, 3, 139 },
/* NOP 71 */ { ST_INH, 1, 142 },
/* OR 72 */ { ST_EXPR2, 4, 143 },
/* OR 73 */ { ST_IEXPR2, 3, 147 },
/* ORP 74 */ { ST_EXPR2, 2, 150 },
/* ORP 75 */ { ST_IEXPR2, 1, 152 },
/* POP 76 */ { ST_EXPR, 3, 153 },
/* POP 77 */ { ST_STATUS, 1, 156 },
/* PUSH 78 */ { ST_EXPR, 3, 157 },
/* PUSH 79 */ { ST_STATUS, 1, 160 },
/* RETI 80 */ { ST_INH, 1, 161 },
/* RETS 81 */ { ST_INH, 1, 162 },
/* RL 82 */ { ST_EXPR, 3, 163 },
/* RLC 83 */ { ST_EXPR, 3, 166 },
/* RR 84 */ { ST_EXPR, 3, 169 },
/* RRC 85 */ { ST_EXPR, 3, 172 },
/* SBB 86 */ { ST_EXPR2, 4, 175 },
/* SBB 87 */ { ST_IEXPR2, 3, 179 },
/* SETC 88 */ { ST_INH, 1, 182 },
/* STA 89 */ { ST_EXPR, 1, 183 },
/* STA 90 */ { ST_INDEX, 1, 184 },
/* STA 91 */ { ST_RINDIR, 1, 185 },
/* STSP 92 */ { ST_INH, 1, 186 },
/* SUB 93 */ { ST_EXPR2, 4, 187 },
/* SUB 94 */ { ST_IEXPR2, 3, 191 },
/* SWAP 95 */ { ST_EXPR, 3, 194 },
/* TRAP 96 */ { ST_EXPR, 1, 197 },
/* TSTA 97 */ { ST_INH, 1, 198 },
/* TSTB 98 */ { ST_INH, 1, 199 },
/* XCHB 99 */ { ST_EXPR, 3, 200 },
/* XOR 100 */ { ST_EXPR2, 4, 203 },
/* XOR 101 */ { ST_IEXPR2, 3, 207 },
/* XORP 102 */ { ST_EXPR2, 2, 210 },
/* XORP 103 */ { ST_IEXPR2, 1, 212 },
	{ 0, 0, 0 } };

struct igel igtab[NUMDIFFOP+1]
	= {
/* invalid 0 */   { 0 , 0, 
		"[Xnullentry" },
/* invalid 1 */   { 0 , 0, 
		"[Xinvalid opcode" },
/* ADC 2 */   { SRCMASK|DSTMASK , SRCB|DSTA, 
		"69;" },
/* ADC 3 */   { DSTMASK , DSTA, 
		"19;[1=].8I;" },
/* ADC 4 */   { DSTMASK , DSTB, 
		"39;[1=].8I;" },
/* ADC 5 */   { 0 , 0, 
		"49;[1=].8I;[2=].8I;" },
/* ADC 6 */   { DSTMASK , DSTA, 
		"29;[1=];" },
/* ADC 7 */   { DSTMASK , DSTB, 
		"59;[1=];" },
/* ADC 8 */   { 0 , 0, 
		"79;[1=];[2=].8I;" },
/* ADD 9 */   { SRCMASK|DSTMASK , SRCB|DSTA, 
		"68;" },
/* ADD 10 */   { DSTMASK , DSTA, 
		"18;[1=].8I;" },
/* ADD 11 */   { DSTMASK , DSTB, 
		"38;[1=].8I;" },
/* ADD 12 */   { 0 , 0, 
		"48;[1=].8I;[2=].8I;" },
/* ADD 13 */   { DSTMASK , DSTA, 
		"28;[1=];" },
/* ADD 14 */   { DSTMASK , DSTB, 
		"58;[1=];" },
/* ADD 15 */   { 0 , 0, 
		"78;[1=];[2=].8I;" },
/* AND 16 */   { SRCMASK|DSTMASK , SRCB|DSTA, 
		"63;" },
/* AND 17 */   { DSTMASK , DSTA, 
		"13;[1=].8I;" },
/* AND 18 */   { DSTMASK , DSTB, 
		"33;[1=].8I;" },
/* AND 19 */   { 0 , 0, 
		"43;[1=].8I;[2=].8I;" },
/* AND 20 */   { DSTMASK , DSTA, 
		"23;[1=];" },
/* AND 21 */   { DSTMASK , DSTB, 
		"53;[1=];" },
/* AND 22 */   { 0 , 0, 
		"73;[1=];[2=].8I;" },
/* ANDP 23 */   { SRCMASK , SRCA, 
		"83;[2=].100-.8I;" },
/* ANDP 24 */   { SRCMASK , SRCB, 
		"93;[2=].100-.8I;" },
/* ANDP 25 */   { 0 , 0, 
		"a3;[1=];[2=].100-.8I;" },
/* BR 26 */   { 0 , 0, 
		"8c;[1=]x" },
/* BR 27 */   { SRCMASK , SRCB, 
		"ac;[1=]x" },
/* BR 28 */   { 0 , 0, 
		"9c;[1=].8I;" },
/* BTJO 29 */   { SRCMASK|DSTMASK , SRCB|DSTA, 
		"66;[3=].Q.1+-r" },
/* BTJO 30 */   { DSTMASK , DSTA, 
		"16;[1=].8I;[3=].Q.1+-r" },
/* BTJO 31 */   { DSTMASK , DSTB, 
		"36;[1=].8I;[3=].Q.1+-r" },
/* BTJO 32 */   { 0 , 0, 
		"46;[1=].8I;[2=].8I;[3=].Q.1+-r" },
/* BTJO 33 */   { DSTMASK , DSTA, 
		"26;[1=];[3=].Q.1+-r" },
/* BTJO 34 */   { DSTMASK , DSTB, 
		"56;[1=];[3=].Q.1+-r" },
/* BTJO 35 */   { 0 , 0, 
		"76;[1=];[2=].8I;[3=].Q.1+-r" },
/* BTJOP 36 */   { SRCMASK , SRCA, 
		"86;[2=].100-.8I;[3=].Q.1+-r" },
/* BTJOP 37 */   { SRCMASK , SRCB, 
		"96;[2=].100-.8I;[3=].Q.1+-r" },
/* BTJOP 38 */   { 0 , 0, 
		"a6;[1=];[2=].100-.8I;[3=].Q.1+-r" },
/* BTJZ 39 */   { SRCMASK|DSTMASK , SRCB|DSTA, 
		"67;[3=].Q.1+-r" },
/* BTJZ 40 */   { DSTMASK , DSTA, 
		"17;[1=].8I;[3=].Q.1+-r" },
/* BTJZ 41 */   { DSTMASK , DSTB, 
		"37;[1=].8I;[3=].Q.1+-r" },
/* BTJZ 42 */   { 0 , 0, 
		"47;[1=].8I;[2=].8I;[3=].Q.1+-r" },
/* BTJZ 43 */   { DSTMASK , DSTA, 
		"27;[1=];[3=].Q.1+-r" },
/* BTJZ 44 */   { DSTMASK , DSTB, 
		"57;[1=];[3=].Q.1+-r" },
/* BTJZ 45 */   { 0 , 0, 
		"77;[1=];[2=].8I;[3=].Q.1+-r" },
/* BTJZP 46 */   { SRCMASK , SRCA, 
		"87;[2=].100-.8I;[3=].Q.1+-r" },
/* BTJZP 47 */   { SRCMASK , SRCB, 
		"97;[2=].100-.8I;[3=].Q.1+-r" },
/* BTJZP 48 */   { 0 , 0, 
		"a7;[1=];[2=].100-.8I;[3=].Q.1+-r" },
/* CALL 49 */   { 0 , 0, 
		"8e;[1=]x" },
/* CALL 50 */   { SRCMASK , SRCB, 
		"ae;[1=]x" },
/* CALL 51 */   { 0 , 0, 
		"9e;[1=].8I;" },
/* CLR 52 */   { DSTMASK , DSTA, 
		"b5;" },
/* CLR 53 */   { DSTMASK , DSTB, 
		"c5;" },
/* CLR 54 */   { 0 , 0, 
		"d5;[1=].8I;" },
/* CLRC 55 */   { 0 , 0, 
		"b0;" },
/* CMP 56 */   { SRCMASK|DSTMASK , SRCB|DSTA, 
		"6d;" },
/* CMP 57 */   { DSTMASK , DSTA, 
		"1d;[1=].8I;" },
/* CMP 58 */   { DSTMASK , DSTB, 
		"3d;[1=].8I;" },
/* CMP 59 */   { 0 , 0, 
		"4d;[1=].8I;[2=].8I;" },
/* CMP 60 */   { DSTMASK , DSTA, 
		"2d;[1=];" },
/* CMP 61 */   { DSTMASK , DSTB, 
		"5d;[1=];" },
/* CMP 62 */   { 0 , 0, 
		"7d;[1=];[2=].8I;" },
/* CMPA 63 */   { 0 , 0, 
		"8d;[1=]x" },
/* CMPA 64 */   { SRCMASK , SRCB, 
		"ad;[1=]x" },
/* CMPA 65 */   { 0 , 0, 
		"9d;[1=].8I;" },
/* DAC 66 */   { SRCMASK|DSTMASK , SRCB|DSTA, 
		"6e;" },
/* DAC 67 */   { DSTMASK , DSTA, 
		"1e;[1=].8I;" },
/* DAC 68 */   { DSTMASK , DSTB, 
		"3e;[1=].8I;" },
/* DAC 69 */   { 0 , 0, 
		"4e;[1=].8I;[2=].8I;" },
/* DAC 70 */   { DSTMASK , DSTA, 
		"2e;[1=];" },
/* DAC 71 */   { DSTMASK , DSTB, 
		"5e;[1=];" },
/* DAC 72 */   { 0 , 0, 
		"7e;[1=];[2=].8I;" },
/* DEC 73 */   { DSTMASK , DSTA, 
		"b2;" },
/* DEC 74 */   { DSTMASK , DSTB, 
		"c2;" },
/* DEC 75 */   { 0 , 0, 
		"d2;[1=].8I;" },
/* DECD 76 */   { DSTMASK , DSTA, 
		"bb;" },
/* DECD 77 */   { DSTMASK , DSTB, 
		"cb;" },
/* DECD 78 */   { 0 , 0, 
		"db;[1=].8I;" },
/* DINT 79 */   { 0 , 0, 
		"06;" },
/* DJNZ 80 */   { SRCMASK , SRCA, 
		"ba;[2=].Q.1+-r" },
/* DJNZ 81 */   { SRCMASK , SRCB, 
		"ca;[2=].Q.1+-r" },
/* DJNZ 82 */   { 0 , 0, 
		"da;[1=].8I;[2=].Q.1+-r" },
/* DSB 83 */   { SRCMASK|DSTMASK , SRCB|DSTA, 
		"6f;" },
/* DSB 84 */   { DSTMASK , DSTA, 
		"1f;[1=].8I;" },
/* DSB 85 */   { DSTMASK , DSTB, 
		"3f;[1=].8I;" },
/* DSB 86 */   { 0 , 0, 
		"4f;[1=].8I;[2=].8I;" },
/* DSB 87 */   { DSTMASK , DSTA, 
		"2f;[1=];" },
/* DSB 88 */   { DSTMASK , DSTB, 
		"5f;[1=];" },
/* DSB 89 */   { 0 , 0, 
		"7f;[1=];[2=].8I;" },
/* EINT 90 */   { 0 , 0, 
		"05;" },
/* IDLE 91 */   { 0 , 0, 
		"01;" },
/* INC 92 */   { DSTMASK , DSTA, 
		"b3;" },
/* INC 93 */   { DSTMASK , DSTB, 
		"c3;" },
/* INC 94 */   { 0 , 0, 
		"d3;[1=].8I;" },
/* INV 95 */   { DSTMASK , DSTA, 
		"b4;" },
/* INV 96 */   { DSTMASK , DSTB, 
		"c4;" },
/* INV 97 */   { 0 , 0, 
		"d4;[1=].8I;" },
/* JC 98 */   { 0 , 0, 
		"e3;[1=].Q.1+-r" },
/* JEQ 99 */   { 0 , 0, 
		"e2;[1=].Q.1+-r" },
/* JGE 100 */   { 0 , 0, 
		"e5;[1=].Q.1+-r" },
/* JGT 101 */   { 0 , 0, 
		"e4;[1=].Q.1+-r" },
/* JHS 102 */   { 0 , 0, 
		"e3;[1=].Q.1+-r" },
/* JL 103 */   { 0 , 0, 
		"e7;[1=].Q.1+-r" },
/* JLT 104 */   { 0 , 0, 
		"e1;[1=].Q.1+-r" },
/* JMP 105 */   { 0 , 0, 
		"e0;[1=].Q.1+-r" },
/* JN 106 */   { 0 , 0, 
		"e1;[1=].Q.1+-r" },
/* JNC 107 */   { 0 , 0, 
		"e7;[1=].Q.1+-r" },
/* JNE 108 */   { 0 , 0, 
		"e6;[1=].Q.1+-r" },
/* JNZ 109 */   { 0 , 0, 
		"e6;[1=].Q.1+-r" },
/* JP 110 */   { 0 , 0, 
		"e4;[1=].Q.1+-r" },
/* JPZ 111 */   { 0 , 0, 
		"e5;[1=].Q.1+-r" },
/* JZ 112 */   { 0 , 0, 
		"e2;[1=].Q.1+-r" },
/* LDA 113 */   { 0 , 0, 
		"8a;[1=]x" },
/* LDA 114 */   { SRCMASK , SRCB, 
		"aa;[1=]x" },
/* LDA 115 */   { 0 , 0, 
		"9a;[1=].8I;" },
/* LDSP 116 */   { 0 , 0, 
		"0d;" },
/* MOV 117 */   { SRCMASK|DSTMASK , SRCA|DSTB, 
		"c0;" },
/* MOV 118 */   { SRCMASK|DSTMASK , SRCB|DSTA, 
		"62;" },
/* MOV 119 */   { DSTMASK , DSTA, 
		"12;[1=].8I;" },
/* MOV 120 */   { SRCMASK , SRCA, 
		"d0;[2=].8I;" },
/* MOV 121 */   { SRCMASK , SRCB, 
		"d1;[2=].8I;" },
/* MOV 122 */   { DSTMASK , DSTB, 
		"32;[1=].8I;" },
/* MOV 123 */   { 0 , 0, 
		"42;[1=].8I;[2=].8I;" },
/* MOV 124 */   { DSTMASK , DSTA, 
		"22;[1=];" },
/* MOV 125 */   { DSTMASK , DSTB, 
		"52;[1=];" },
/* MOV 126 */   { 0 , 0, 
		"72;[1=];[2=].8I;" },
/* MOVD 127 */   { 0 , 0, 
		"98;[1=].8I;[2=].8I;" },
/* MOVD 128 */   { 0 , 0, 
		"88;[1=]x[2=].8I;" },
/* MOVD 129 */   { SRCMASK , SRCB, 
		"a8;[1=]x[2=].8I;" },
/* MOVP 130 */   { SRCMASK , SRCA, 
		"82;[2=].100-.8I;" },
/* MOVP 131 */   { SRCMASK , SRCB, 
		"92;[2=].100-.8I;" },
/* MOVP 132 */   { DSTMASK , DSTA, 
		"80;[1=].100-.8I;" },
/* MOVP 133 */   { DSTMASK , DSTB, 
		"91;[1=].100-.8I;" },
/* MOVP 134 */   { 0 , 0, 
		"a2;[1=];[2=].100-.8I;" },
/* MPY 135 */   { SRCMASK|DSTMASK , SRCB|DSTA, 
		"6c;" },
/* MPY 136 */   { DSTMASK , DSTA, 
		"1c;[1=].8I;" },
/* MPY 137 */   { DSTMASK , DSTB, 
		"3c;[1=].8I;" },
/* MPY 138 */   { 0 , 0, 
		"4c;[1=].8I;[2=].8I;" },
/* MPY 139 */   { DSTMASK , DSTA, 
		"2c;[1=];" },
/* MPY 140 */   { DSTMASK , DSTB, 
		"5c;[1=];" },
/* MPY 141 */   { 0 , 0, 
		"7c;[1=];[2=].8I;" },
/* NOP 142 */   { 0 , 0, 
		"00;" },
/* OR 143 */   { SRCMASK|DSTMASK , SRCB|DSTA, 
		"64;" },
/* OR 144 */   { DSTMASK , DSTA, 
		"14;[1=].8I;" },
/* OR 145 */   { DSTMASK , DSTB, 
		"34;[1=].8I;" },
/* OR 146 */   { 0 , 0, 
		"44;[1=].8I;[2=].8I;" },
/* OR 147 */   { DSTMASK , DSTA, 
		"24;[1=];" },
/* OR 148 */   { DSTMASK , DSTB, 
		"54;[1=];" },
/* OR 149 */   { 0 , 0, 
		"74;[1=];[2=].8I;" },
/* ORP 150 */   { SRCMASK , SRCA, 
		"84;[2=].100-.8I;" },
/* ORP 151 */   { SRCMASK , SRCB, 
		"94;[2=].100-.8I;" },
/* ORP 152 */   { 0 , 0, 
		"a4;[1=];[2=].100-.8I;" },
/* POP 153 */   { DSTMASK , DSTA, 
		"b9;" },
/* POP 154 */   { DSTMASK , DSTB, 
		"c9;" },
/* POP 155 */   { 0 , 0, 
		"d9;[1=].8I;" },
/* POP 156 */   { 0 , 0, 
		"08;" },
/* PUSH 157 */   { DSTMASK , DSTA, 
		"b8;" },
/* PUSH 158 */   { DSTMASK , DSTB, 
		"c8;" },
/* PUSH 159 */   { 0 , 0, 
		"d8;[1=].8I;" },
/* PUSH 160 */   { 0 , 0, 
		"0e;" },
/* RETI 161 */   { 0 , 0, 
		"0b;" },
/* RETS 162 */   { 0 , 0, 
		"0a;" },
/* RL 163 */   { DSTMASK , DSTA, 
		"be;" },
/* RL 164 */   { DSTMASK , DSTB, 
		"ce;" },
/* RL 165 */   { 0 , 0, 
		"de;[1=].8I;" },
/* RLC 166 */   { DSTMASK , DSTA, 
		"bf;" },
/* RLC 167 */   { DSTMASK , DSTB, 
		"cf;" },
/* RLC 168 */   { 0 , 0, 
		"df;[1=].8I;" },
/* RR 169 */   { DSTMASK , DSTA, 
		"bc;" },
/* RR 170 */   { DSTMASK , DSTB, 
		"cc;" },
/* RR 171 */   { 0 , 0, 
		"dc;[1=].8I;" },
/* RRC 172 */   { DSTMASK , DSTA, 
		"bd;" },
/* RRC 173 */   { DSTMASK , DSTB, 
		"cd;" },
/* RRC 174 */   { 0 , 0, 
		"dd;[1=].8I;" },
/* SBB 175 */   { SRCMASK|DSTMASK , SRCB|DSTA, 
		"6b;" },
/* SBB 176 */   { DSTMASK , DSTA, 
		"1b;[1=].8I;" },
/* SBB 177 */   { DSTMASK , DSTB, 
		"3b;[1=].8I;" },
/* SBB 178 */   { 0 , 0, 
		"4b;[1=].8I;[2=].8I;" },
/* SBB 179 */   { DSTMASK , DSTA, 
		"2b;[1=];" },
/* SBB 180 */   { DSTMASK , DSTB, 
		"5b;[1=];" },
/* SBB 181 */   { 0 , 0, 
		"7b;[1=];[2=].8I;" },
/* SETC 182 */   { 0 , 0, 
		"07;" },
/* STA 183 */   { 0 , 0, 
		"8b;[1=]x" },
/* STA 184 */   { SRCMASK , SRCB, 
		"ab;[1=]x" },
/* STA 185 */   { 0 , 0, 
		"9b;[1=].8I;" },
/* STSP 186 */   { 0 , 0, 
		"09;" },
/* SUB 187 */   { SRCMASK|DSTMASK , SRCB|DSTA, 
		"6a;" },
/* SUB 188 */   { DSTMASK , DSTA, 
		"1a;[1=].8I;" },
/* SUB 189 */   { DSTMASK , DSTB, 
		"3a;[1=].8I;" },
/* SUB 190 */   { 0 , 0, 
		"4a;[1=].8I;[2=].8I;" },
/* SUB 191 */   { DSTMASK , DSTA, 
		"2a;[1=];" },
/* SUB 192 */   { DSTMASK , DSTB, 
		"5a;[1=];" },
/* SUB 193 */   { 0 , 0, 
		"7a;[1=];[2=].8I;" },
/* SWAP 194 */   { DSTMASK , DSTA, 
		"b7;" },
/* SWAP 195 */   { DSTMASK , DSTB, 
		"c7;" },
/* SWAP 196 */   { 0 , 0, 
		"d7;[1=].8I;" },
/* TRAP 197 */   { 0 , 0, 
		"ff.[1=].5I-~.e8<T!;" },
/* TSTA 198 */   { 0 , 0, 
		"b0;" },
/* TSTB 199 */   { 0 , 0, 
		"c1;" },
/* XCHB 200 */   { DSTMASK , DSTA, 
		"b6;" },
/* XCHB 201 */   { DSTMASK , DSTB, 
		"c6;" },
/* XCHB 202 */   { 0 , 0, 
		"d6;[1=].8I;" },
/* XOR 203 */   { SRCMASK|DSTMASK , SRCB|DSTA, 
		"65;" },
/* XOR 204 */   { DSTMASK , DSTA, 
		"15;[1=].8I;" },
/* XOR 205 */   { DSTMASK , DSTB, 
		"35;[1=].8I;" },
/* XOR 206 */   { 0 , 0, 
		"45;[1=].8I;[2=].8I;" },
/* XOR 207 */   { DSTMASK , DSTA, 
		"25;[1=];" },
/* XOR 208 */   { DSTMASK , DSTB, 
		"55;[1=];" },
/* XOR 209 */   { 0 , 0, 
		"75;[1=];[2=].8I;" },
/* XORP 210 */   { SRCMASK , SRCA, 
		"85;[2=].100-.8I;" },
/* XORP 211 */   { SRCMASK , SRCB, 
		"95;[2=].100-.8I;" },
/* XORP 212 */   { 0 , 0, 
		"a5;[1=];[2=].100-.8I;" },
	{ 0,0,""} };
/* end fraptabdef.c */
