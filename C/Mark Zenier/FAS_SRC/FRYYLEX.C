/*
HEADER: 	;
TITLE: 		Frankenstein Cross Assemblers;
VERSION: 	2.0;
DESCRIPTION: "	Reconfigurable Cross-assembler producing Intel (TM)
		Hex format object records.  ";
KEYWORDS: 	cross-assemblers, 1805, 2650, 6301, 6502, 6805, 6809, 
		6811, tms7000, 8048, 8051, 8096, z8, z80;
SYSTEM: 	UNIX, MS-Dos ;
FILENAME: 	fryylex.c;
WARNINGS: 	"This software is in the public domain.  
		Any prior copyright claims are relinquished.  

		This software is distributed with no warranty whatever.  
		The author takes no responsibility for the consequences 
		of its use.

		Yacc (or Bison) required to compile."  ;
SEE-ALSO: 	as*.y (yacc input files);
AUTHORS: 	Mark Zenier;
COMPILERS: 	Microport Sys V/AT, ATT Yacc, Turbo C V1.5, Bison (CUG disk 285)
		(previous versions Xenix, Unisoft 68000 Version 7, Sun 3);
*/


/*
	description	lexical analyzer for framework cross assembler
	usage		Framework cross assembler, Unix
	history		September 13, 1987
			September 14, 1990  Dosify, 6 char unique names
			October, 1990  hand carved scanner
*/

#include <stdio.h>
#include "frasmdat.h"
#include "fraytok.h"

#ifndef DEBUG
#define DEBUG 0
#endif

	extern YYSTYPE yylval; 

	enum symflag {Symopcode, Symsym} whichsym = Symopcode;

	FILE *yyin;

	char finbuff[INBUFFSZ] = "L:"; 
		/* initialization nonreusable, wiped out by pass 2 */
	static char *frainptr = &finbuff[2];
		/* point to null byte after L: on start up */
	enum readacts nextreadact = Nra_normal;


frareadrec()
/*
	description	read a line, on end of file, pop the include file
			stack.
	return		FALSE	got a line
			TRUE	end of input
*/
{
	while( fgets(&finbuff[2], INBUFFSZ -2, yyin) == (char *)NULL)
	{
		if(currfstk == 0)
		{
			return TRUE;
		}
		else
		{
			fclose(yyin);
			yyin = infilestk[--currfstk].fpt;
			fprintf(intermedf, "X:%s\n",infilestk[currfstk].fnm);
		}
	}
	return FALSE;
}

static int currtok=0; /* subscript of next token to return */
static int intokcnt=0; /* number of tokens in queue */

static struct
{
	char *textstrt, *textend;
	YYSTYPE  lvalv;
	int tokv; 
	enum {Yetprint, Yetsymbol, Yetreserved, Yetopcode, 
		Yetconstant, Yetstring, Yetunprint, Yetinvalid } errtype;
}  scanqueue[INBUFFSZ], *lasttokfetch, *nexttokload;

static char tempstrpool[2*INBUFFSZ];
static char *tptrstr;

#define	 CXC00_SKIP	0
#define	 CXC01_SPACE	1
#define	 CXC02_NL	2
#define	 CXC03_LETTER	3
#define	 CXC04_QUOTE	4
#define	 CXC05_OTHER	5
#define	 CXC06_DOLLAR	6
#define	 CXC07_PERCENT	7
#define	 CXC08_APP	8
#define	 CXC09_BIN	9
#define	 CXC10_OCT	10
#define	 CXC11_DEC	11
#define	 CXC12_SEMIC	12
#define	 CXC13_LT	13
#define	 CXC14_EQ	14
#define	 CXC15_GT	15
#define	 CXC16_AT	16
#define	 CXC17_HEXU	17
#define	 CXC18_B	18
#define	 CXC19_D	19
#define	 CXC20_H	20
#define	 CXC21_OQ	21
#define	 CXC22_HEXL	22
#define	 CXC23_BL	23
#define	 CXC24_DL	24
#define	 CXC25_BSLASH	25
#define  NUMCHARSETS	26

static char chartrantab[128] = {
/* 00 nul soh stx etx*/  CXC00_SKIP, CXC00_SKIP, CXC00_SKIP, CXC00_SKIP,
/* 04 eot enq ack bel*/  CXC00_SKIP, CXC00_SKIP, CXC00_SKIP, CXC00_SKIP,
/* 08 bs  ht  nl  vt */  CXC00_SKIP, CXC01_SPACE, CXC02_NL, CXC00_SKIP,
/* 0c np  cr  so  si */  CXC00_SKIP, CXC00_SKIP, CXC00_SKIP, CXC00_SKIP,
/* 10 dle dc1 dc2 dc3*/  CXC00_SKIP, CXC00_SKIP, CXC00_SKIP, CXC00_SKIP,
/* 14 dc4 nak syn etb*/  CXC00_SKIP, CXC00_SKIP, CXC00_SKIP, CXC00_SKIP,
/* 18 can em  sub esc*/  CXC00_SKIP, CXC00_SKIP, CXC00_SKIP, CXC00_SKIP,
/* 1c fs  gs  rs  us */  CXC00_SKIP, CXC00_SKIP, CXC00_SKIP, CXC00_SKIP,
/* 20 sp  !  "  # */  CXC01_SPACE, CXC03_LETTER, CXC04_QUOTE, CXC05_OTHER,
/* 24  $  %  &  ' */  CXC06_DOLLAR, CXC07_PERCENT, CXC03_LETTER, CXC08_APP,
/* 28  (  )  *  + */  CXC05_OTHER, CXC05_OTHER, CXC05_OTHER, CXC05_OTHER,
/* 2c  ,  -  .  / */  CXC05_OTHER, CXC05_OTHER, CXC05_OTHER, CXC05_OTHER,
/* 30  0  1  2  3 */  CXC09_BIN, CXC09_BIN, CXC10_OCT, CXC10_OCT,
/* 34  4  5  6  7 */  CXC10_OCT, CXC10_OCT, CXC10_OCT, CXC10_OCT,
/* 38  8  9  :  ; */  CXC11_DEC, CXC11_DEC, CXC05_OTHER, CXC12_SEMIC,
/* 3c  <  =  >  ? */  CXC13_LT, CXC14_EQ, CXC15_GT, CXC05_OTHER,
/* 40  @  A  B  C */  CXC16_AT, CXC17_HEXU, CXC18_B, CXC17_HEXU,
/* 44  D  E  F  G */  CXC19_D, CXC17_HEXU, CXC17_HEXU, CXC03_LETTER,
/* 48  H  I  J  K */  CXC20_H, CXC03_LETTER, CXC03_LETTER, CXC03_LETTER,
/* 4c  L  M  N  O */  CXC03_LETTER, CXC03_LETTER, CXC03_LETTER, CXC21_OQ,
/* 50  P  Q  R  S */  CXC03_LETTER, CXC21_OQ, CXC03_LETTER, CXC03_LETTER,
/* 54  T  U  V  W */  CXC03_LETTER, CXC03_LETTER, CXC03_LETTER, CXC03_LETTER,
/* 58  X  Y  Z  [ */  CXC03_LETTER, CXC03_LETTER, CXC03_LETTER, CXC05_OTHER,
/* 5c  \  ]  ^  _ */  CXC25_BSLASH, CXC05_OTHER, CXC03_LETTER, CXC03_LETTER,
/* 60  `  a  b  c */  CXC05_OTHER, CXC22_HEXL, CXC23_BL, CXC22_HEXL,
/* 64  d  e  f  g */  CXC24_DL, CXC22_HEXL, CXC22_HEXL, CXC03_LETTER,
/* 68  h  i  j  k */  CXC20_H, CXC03_LETTER, CXC03_LETTER, CXC03_LETTER,
/* 6c  l  m  n  o */  CXC03_LETTER, CXC03_LETTER, CXC03_LETTER, CXC21_OQ,
/* 70  p  q  r  s */  CXC03_LETTER, CXC21_OQ, CXC03_LETTER, CXC03_LETTER,
/* 74  t  u  v  w */  CXC03_LETTER, CXC03_LETTER, CXC03_LETTER, CXC03_LETTER,
/* 78  x  y  z  { */  CXC03_LETTER, CXC03_LETTER, CXC03_LETTER, CXC05_OTHER,
/* 7c vb  }  ~  del*/  CXC05_OTHER, CXC05_OTHER, CXC03_LETTER, CXC00_SKIP } ;


#if DEBUG

static char * statelab[] = {
		" 0 start of label",
		" 1 comment",
		" 2 label",
		" 3 rest of line",
		" 4 symbol",
		" 5 dollar",
		" 6 hex dollar",
		" 7 at sign",
		" 8 octal at",
		" 9 percent",
		"10 bin percent",
		"11 quote string",
		"12 appos. string",
		"13 greater than",
		"14 less than",
		"15 base 2 maybe",
		"16 base 8 maybe",
		"17 base 10 maybe",
		"18 hex",
		"19 found b ",
		"20 found d",
		"21 bslash quote",
		"22 bslash appos",
		};
			
static char *actlab[] = {
		" 0 skip/no op",
		" 1 load EOL token",
		" 2 start string",
		" 3 process label",
		" 4 save string char",
		" 5 load single char token",
		" 6 load EQ token",
		" 7 process symbol",
		" 8 load $ token",
		" 9 setup for $hex",
		"10 accumulate 0-9 constant",
		"11 accumulate A-F constant",
		"12 accumulate a-f constant",
		"13 load Constant token",
		"14 load @ token",
		"15 setup for @octal",
		"16 setup for %binary",
		"17 load % token",
		"18 load String token",
		"19 load GE token",
		"20 load GT token",
		"21 load LE token",
		"22 load NE token",
		"23 load LT token",
		"24 save numeric char 0-9",
		"25 save numeric char A-F",
		"26 save numeric char a-f",
		"27 convert numeric string base 2",
		"28 convert numeric string base 8",
		"29 convert numeric string base 10",
		"30 convert numeric string base 16",
		"31 save numeric 0xb",
		"32 save numeric 0xd",
		"33 set text start",
		"34 token choke"
		};

#endif  /* DEBUG */

static struct
{
	char action;
	char nextstate;
	char contin;
} 	*thisact, characttab [23][NUMCHARSETS] =
{
/*
	STATE 0 =	{start of label}
*/
	{
	/* SKIP    */  	/* SPACE   */	/* NL      */  	/* LETTER  */ 
	/* QUOTE   */  	/* OTHER   */	/* DOLLAR  */  	/* PERCENT */ 
	/* APP     */  	/* BIN     */ 	/* OCT     */  	/* DEC     */ 
	/* SEMIC   */  	/* LT      */	/* EQ      */  	/* GT      */ 
	/* AT      */  	/* HEXU    */	/* B       */  	/* D       */ 
	/* H       */  	/* OQ      */	/* HEXL    */  	/* BL      */ 
	/* DL      */ 	/* BSLASH  */
	{0, 0, FALSE},	{0, 3, FALSE},	{1, 0, FALSE},	{2, 2, TRUE},
	{2,11, FALSE},	{5, 3, FALSE},	{33, 5, FALSE},	{33, 9, FALSE},
	{2,12, FALSE},	{2,15, TRUE},	{2,16, TRUE},	{2,17, TRUE},
	{0, 1, FALSE},	{0,14, FALSE},	{6, 3, FALSE},	{0,13, FALSE},
	{33, 7, FALSE},	{2, 2, TRUE},	{2, 2, TRUE},	{2, 2, TRUE},
	{2, 2, TRUE},	{2, 2, TRUE},	{2, 2, TRUE},	{2, 2, TRUE},
	{2, 2, TRUE},	{5, 3, FALSE}
	},

/*
	STATE 1 =	{comment}
*/
	{
	{0, 1, FALSE},	{0, 1, FALSE},	{1, 0, FALSE},	{0, 1, FALSE},
	{0, 1, FALSE},	{0, 1, FALSE},	{0, 1, FALSE},	{0, 1, FALSE},
	{0, 1, FALSE},	{0, 1, FALSE},	{0, 1, FALSE},	{0, 1, FALSE},
	{0, 1, FALSE},	{0, 1, FALSE},	{0, 1, FALSE},	{0, 1, FALSE},
	{0, 1, FALSE},	{0, 1, FALSE},	{0, 1, FALSE},	{0, 1, FALSE},
	{0, 1, FALSE},	{0, 1, FALSE},	{0, 1, FALSE},	{0, 1, FALSE},
	{0, 1, FALSE},	{0, 1, FALSE} 
	},

/*
	STATE 2 =	{label}
*/
	{
	{0, 2, FALSE},	{3, 3, FALSE},	{3, 3, TRUE},	{4, 2, FALSE},
	{3, 3, TRUE},	{3, 3, TRUE},	{3, 3, TRUE},	{3, 3, TRUE},
	{3, 3, TRUE},	{4, 2, FALSE},	{4, 2, FALSE},	{4, 2, FALSE},
	{3, 1, FALSE},	{3,14, FALSE},	{3, 3, TRUE},	{3,13, FALSE},
	{3, 3, TRUE},	{4, 2, FALSE},	{4, 2, FALSE},	{4, 2, FALSE},
	{4, 2, FALSE},	{4, 2, FALSE},	{4, 2, FALSE},	{4, 2, FALSE},
	{4, 2, FALSE},  {3, 3, TRUE} 
	},

/*
	STATE 3  =	{rest of line}
*/
	{
	{0, 3, FALSE},	{0, 3, FALSE},	{1, 0, FALSE},	{2, 4, TRUE},
	{2,11, FALSE},	{5, 3, FALSE},	{33, 5, FALSE},	{33, 9, FALSE},
	{2,12, FALSE},	{2,15, TRUE},	{2,16, TRUE},	{2,17, TRUE},
	{0, 1, FALSE},	{0,14, FALSE},	{6, 3, FALSE},	{0,13, FALSE},
	{33, 7, FALSE},	{2, 4, TRUE},	{2, 4, TRUE},	{2, 4, TRUE},
	{2, 4, TRUE},	{2, 4, TRUE},	{2, 4, TRUE},	{2, 4, TRUE},
	{2, 4, TRUE} ,	{5, 3, FALSE}
	},

/*
	STATE 4 =	{symbol}
*/
	{
	{0, 4, FALSE},	{7, 3, FALSE},	{7, 3, TRUE},	{4, 4, FALSE},
	{7, 3, TRUE},	{7, 3, TRUE},	{7, 3, TRUE},	{7, 3, TRUE},
	{7, 3, TRUE},	{4, 4, FALSE},	{4, 4, FALSE},	{4, 4, FALSE},
	{7, 1, FALSE},	{7,14, FALSE},	{7, 3, TRUE},	{7,13, FALSE},
	{7, 3, TRUE},	{4, 4, FALSE},	{4, 4, FALSE},	{4, 4, FALSE},
	{4, 4, FALSE},	{4, 4, FALSE},	{4, 4, FALSE},	{4, 4, FALSE},
	{4, 4, FALSE},	{7, 3, TRUE}
	},

/*
	STATE 5 =	{dollar}
*/
	{
	{0, 5, FALSE},	{8, 3, FALSE},	{8, 3, TRUE},	{8, 3, TRUE},
	{8, 3, TRUE},	{8, 3, TRUE},	{8, 3, TRUE},	{8, 3, TRUE},
	{8, 3, TRUE},	{9, 6, TRUE},	{9, 6, TRUE},	{9, 6, TRUE},
	{8, 1, FALSE},	{8,14, FALSE},	{8, 3, TRUE},	{8,13, FALSE},
	{8, 3, TRUE},	{9, 6, TRUE},	{9, 6, TRUE},	{9, 6, TRUE},
	{8, 3, TRUE},	{8, 3, TRUE},	{9, 6, TRUE},	{9, 6, TRUE},
	{9, 6, TRUE} ,	{8, 3, TRUE}
	},

/*
	STATE 6 =	{dollar hex}
*/

	{
	{0, 6, FALSE},	{13, 3, FALSE},	{13, 3, TRUE},	{13, 3, TRUE},
	{13, 3, TRUE},	{13, 3, TRUE},	{13, 3, TRUE},	{13, 3, TRUE},
	{13, 3, TRUE},	{10, 6, FALSE},	{10, 6, FALSE},	{10, 6, FALSE},
	{13, 1, FALSE},	{13,14, FALSE},	{13, 3, TRUE},	{13,13, FALSE},
	{13, 3, TRUE},	{11, 6, FALSE},	{11, 6, FALSE},	{11, 6, FALSE},
	{13, 3, TRUE},	{13, 3, TRUE},	{12, 6, FALSE},	{12, 6, FALSE},
	{12, 6, FALSE},	{13, 3, TRUE}
	},
/*
	STATE 7 =	{at sign}
*/
	{
	{0, 7, FALSE},	{14, 3, FALSE},	{14, 3, TRUE},	{14, 3, TRUE},
	{14, 3, TRUE},	{14, 3, TRUE},	{14, 3, TRUE},	{14, 3, TRUE},
	{14, 3, TRUE},	{15, 8, TRUE},	{15, 8, TRUE},	{14, 3, TRUE},
	{14, 1, FALSE},	{14,14, FALSE},	{14, 3, TRUE},	{14,13, FALSE},
	{14, 3, TRUE},	{14, 3, TRUE},	{14, 3, TRUE},	{14, 3, TRUE},
	{14, 3, TRUE},	{14, 3, TRUE},	{14, 3, TRUE},	{14, 3, TRUE},
	{14, 3, TRUE},	{14, 3, TRUE}
	},

/*
	STATE 8 =	{at octal}
*/
	{
	{0, 8, FALSE},	{13, 3, FALSE},	{13, 3, TRUE},	{13, 3, TRUE},
	{13, 3, TRUE},	{13, 3, TRUE},	{13, 3, TRUE},	{13, 3, TRUE},
	{13, 3, TRUE},	{10, 8, FALSE},	{10, 8, FALSE},	{13, 3, TRUE},
	{13, 1, FALSE},	{13,14, FALSE},	{13, 3, TRUE},	{13,13, FALSE},
	{13, 3, TRUE},	{13, 3, TRUE},	{13, 3, TRUE},	{13, 3, TRUE},
	{13, 3, TRUE},	{13, 3, TRUE},	{13, 3, TRUE},	{13, 3, TRUE},
	{13, 3, TRUE},	{13, 3, TRUE}
	},

/*
	STATE 9 =	{percent}
*/
	{
	{0, 9, FALSE},	{17, 3, FALSE},	{17, 3, TRUE},	{17, 3, TRUE},
	{17, 3, TRUE},	{17, 3, TRUE},	{17, 3, TRUE},	{17, 3, TRUE},
	{17, 3, TRUE},	{16,10, TRUE},	{17, 3, TRUE},	{17, 3, TRUE},
	{17, 1, FALSE},	{17,14, FALSE},	{17, 3, TRUE},	{17,13, FALSE},
	{17, 3, TRUE},	{17, 3, TRUE},	{17, 3, TRUE},	{17, 3, TRUE},
	{17, 3, TRUE},	{17, 3, TRUE},	{17, 3, TRUE},	{17, 3, TRUE},
	{17, 3, TRUE},	{17, 3, TRUE}
	},

/*
	STATE 10 =	{percent binary}
*/
	{
	{0,10, FALSE},	{13, 3, FALSE},	{13, 3, TRUE},	{13, 3, TRUE},
	{13, 3, TRUE},	{13, 3, TRUE},	{13, 3, TRUE},	{13, 3, TRUE},
	{13, 3, TRUE},	{10,10, FALSE},	{13, 3, TRUE},	{13, 3, TRUE},
	{13, 1, FALSE},	{13,14, FALSE},	{13, 3, TRUE},	{13,13, FALSE},
	{13, 3, TRUE},	{13, 3, TRUE},	{13, 3, TRUE},	{13, 3, TRUE},
	{13, 3, TRUE},	{13, 3, TRUE},	{13, 3, TRUE},	{13, 3, TRUE},
	{13, 3, TRUE},	{13, 3, TRUE}
	},

/*
	STATE 11 =	{quote string}
*/
	{
	{0,11, FALSE},	{4,11, FALSE},	{34, 3, TRUE},	{4,11, FALSE},
	{18, 3, FALSE},	{4,11, FALSE},	{4,11, FALSE},	{4,11, FALSE},
	{4,11, FALSE},	{4,11, FALSE},	{4,11, FALSE},	{4,11, FALSE},
	{4,11, FALSE},	{4,11, FALSE},	{4,11, FALSE},	{4,11, FALSE},
	{4,11, FALSE},	{4,11, FALSE},	{4,11, FALSE},	{4,11, FALSE},
	{4,11, FALSE},	{4,11, FALSE},	{4,11, FALSE},	{4,11, FALSE},
	{4,11, FALSE},  {4,21, FALSE}
	},

/*
	STATE 12 =	{app string}
*/
	{
	{0,12, FALSE},	{4,12, FALSE},	{34, 3, TRUE},	{4,12, FALSE},
	{4,12, FALSE},	{4,12, FALSE},	{4,12, FALSE},	{4,12, FALSE},
	{18, 3, FALSE},	{4,12, FALSE},	{4,12, FALSE},	{4,12, FALSE},
	{4,12, FALSE},	{4,12, FALSE},	{4,12, FALSE},	{4,12, FALSE},
	{4,12, FALSE},	{4,12, FALSE},	{4,12, FALSE},	{4,12, FALSE},
	{4,12, FALSE},	{4,12, FALSE},	{4,12, FALSE},	{4,12, FALSE},
	{4,12, FALSE},	{4,22, FALSE}
	},

/*
	STATE 13 =	{greater than}
*/
	{
	{0,13, FALSE},	{20, 3, FALSE},	{20, 3, TRUE},	{20, 3, TRUE},
	{20, 3, TRUE},	{20, 3, TRUE},	{20, 3, TRUE},	{20, 3, TRUE},
	{20, 3, TRUE},	{20, 3, TRUE},	{20, 3, TRUE},	{20, 3, TRUE},
	{20, 1, FALSE},	{20,14, FALSE},	{19, 3, FALSE},	{20,13, FALSE},
	{20, 3, TRUE},	{20, 3, TRUE},	{20, 3, TRUE},	{20, 3, TRUE},
	{20, 3, TRUE},	{20, 3, TRUE},	{20, 3, TRUE},	{20, 3, TRUE},
	{20, 3, TRUE},	{20, 3, TRUE}
	},

/*
	STATE 14 =	{less than}
*/
	{
	{0,14, FALSE},	{23, 3, FALSE},	{23, 3, TRUE},	{23, 3, TRUE},
	{23, 3, TRUE},	{23, 3, TRUE},	{23, 3, TRUE},	{23, 3, TRUE},
	{23, 3, TRUE},	{23, 3, TRUE},	{23, 3, TRUE},	{23, 3, TRUE},
	{23, 1, FALSE},	{23,14, FALSE},	{21, 3, FALSE},	{22,13, FALSE},
	{23, 3, TRUE},	{23, 3, TRUE},	{23, 3, TRUE},	{23, 3, TRUE},
	{23, 3, TRUE},	{23, 3, TRUE},	{23, 3, TRUE},	{23, 3, TRUE},
	{23, 3, TRUE},	{23, 3, TRUE}
	},

/*
	STATE 15 =	{base 2 maybe}
*/
	{
	{0,15, FALSE},	{29, 3, FALSE},	{29, 3, TRUE},	{29, 3, TRUE},
	{29, 3, TRUE},	{29, 3, TRUE},	{29, 3, TRUE},	{29, 3, TRUE},
	{29, 3, TRUE},	{24,15, FALSE},	{24,16, FALSE},	{24,17, FALSE},
	{29, 1, FALSE},	{29,14, FALSE},	{29, 3, TRUE},	{29,13, FALSE},
	{29, 3, TRUE},	{25,18, FALSE},	{0,19, FALSE},	{0,20, FALSE},
	{30, 3, FALSE},	{28, 3, FALSE},	{26,18, FALSE},	{0,19, FALSE},
	{0,20, FALSE},	{29, 3, TRUE}
	},

/*
	STATE 16 =	{base 8 maybe}
*/
	{	
	{0,16, FALSE},	{29, 3, FALSE},	{29, 3, TRUE},	{29, 3, TRUE},
	{29, 3, TRUE},	{29, 3, TRUE},	{29, 3, TRUE},	{29, 3, TRUE},
	{29, 3, TRUE},	{24,16, FALSE},	{24,16, FALSE},	{24,17, FALSE},
	{29, 1, FALSE},	{29,14, FALSE},	{29, 3, TRUE},	{29,13, FALSE},
	{29, 3, TRUE},	{25,18, FALSE},	{25,18, FALSE},	{0,20, FALSE},
	{30, 3, FALSE},	{28, 3, FALSE},	{26,18, FALSE},	{26,18, FALSE},
	{0,20, FALSE},	{29, 3, TRUE}
	},

/*
	STATE 17 =	{base10 maybe}
*/
	{	
	{0,17, FALSE},	{29, 3, FALSE},	{29, 3, TRUE},	{29, 3, TRUE},
	{29, 3, TRUE},	{29, 3, TRUE},	{29, 3, TRUE},	{29, 3, TRUE},
	{29, 3, TRUE},	{24,17, FALSE},	{24,17, FALSE},	{24,17, FALSE},
	{29, 1, FALSE},	{29,14, FALSE},	{29, 3, TRUE},	{29,13, FALSE},
	{29, 3, TRUE},	{25,18, FALSE},	{25,18, FALSE},	{0,20, FALSE},
	{30, 3, FALSE},	{34, 3, FALSE},	{26,18, FALSE},	{26,18, FALSE},
	{0,20, FALSE},	{29, 3, TRUE}
	},

/*
	STATE 18 =	{hex}
*/
	{	
	{0,18, FALSE},	{34, 3, FALSE},	{34, 3, TRUE},	{34, 3, TRUE},
	{34, 3, TRUE},	{34, 3, TRUE},	{34, 3, TRUE},	{34, 3, TRUE},
	{34, 3, TRUE},	{24,18, FALSE},	{24,18, FALSE},	{24,18, FALSE},
	{34, 1, FALSE},	{34,14, FALSE},	{34, 3, TRUE},	{34,13, FALSE},
	{34, 3, TRUE},	{25,18, FALSE},	{25,18, FALSE},	{25,18, FALSE},
	{30, 3, FALSE},	{34, 3, TRUE},	{26,18, FALSE},	{26,18, FALSE},
	{26,18, FALSE},	{34, 3, TRUE}
	},

/*
	STATE 19 =	{bin or hex}
*/
	{	
	{0,19, FALSE},	{27, 3, FALSE},	{27, 3, TRUE},	{27, 3, TRUE},
	{27, 3, TRUE},	{27, 3, TRUE},	{27, 3, TRUE},	{27, 3, TRUE},
	{27, 3, TRUE},	{31,18, TRUE},	{31,18, TRUE},	{31,18, TRUE},
	{27, 1, FALSE},	{27,14, FALSE},	{27, 3, TRUE},	{27,13, FALSE},
	{27, 3, TRUE},	{31,18, TRUE},	{31,18, TRUE},	{31,18, TRUE},
	{31,18, TRUE},	{27, 3, TRUE},	{31,18, TRUE},	{31,18, TRUE},
	{31,18, TRUE},	{27, 3, TRUE}
	},

/*
	STATE 20 =	{dec or hex}
*/
	{	
	{0,20, FALSE},	{29, 3, FALSE},	{29, 3, TRUE},	{29, 3, TRUE},
	{29, 3, TRUE},	{29, 3, TRUE},	{29, 3, TRUE},	{29, 3, TRUE},
	{29, 3, TRUE},	{32,18, TRUE},	{32,18, TRUE},	{32,18, TRUE},
	{29, 1, FALSE},	{29,14, FALSE},	{29, 3, TRUE},	{29,13, FALSE},
	{29, 3, TRUE},	{32,18, TRUE},	{32,18, TRUE},	{32,18, TRUE},
	{32,18, TRUE},	{29, 3, TRUE},	{32,18, TRUE},	{32,18, TRUE},
	{32,18, TRUE},	{29, 3, TRUE}
	},

/*
	STATE 21 =	{bslash quote}
*/
	{
	{0,21, FALSE},	{4,11, FALSE},	{34, 3, TRUE},	{4,11, FALSE},
	{4,11, FALSE},	{4,11, FALSE},	{4,11, FALSE},	{4,11, FALSE},
	{4,11, FALSE},	{4,11, FALSE},	{4,11, FALSE},	{4,11, FALSE},
	{4,11, FALSE},	{4,11, FALSE},	{4,11, FALSE},	{4,11, FALSE},
	{4,11, FALSE},	{4,11, FALSE},	{4,11, FALSE},	{4,11, FALSE},
	{4,11, FALSE},	{4,11, FALSE},	{4,11, FALSE},	{4,11, FALSE},
	{4,11, FALSE},  {4,11, FALSE}
	},

/*
	STATE 22 =	{bslash appos}
*/
	{
	{0,22, FALSE},	{4,12, FALSE},	{34, 3, TRUE},	{4,12, FALSE},
	{4,12, FALSE},	{4,12, FALSE},	{4,12, FALSE},	{4,12, FALSE},
	{4,12, FALSE},	{4,12, FALSE},	{4,12, FALSE},	{4,12, FALSE},
	{4,12, FALSE},	{4,12, FALSE},	{4,12, FALSE},	{4,12, FALSE},
	{4,12, FALSE},	{4,12, FALSE},	{4,12, FALSE},	{4,12, FALSE},
	{4,12, FALSE},	{4,12, FALSE},	{4,12, FALSE},	{4,12, FALSE},
	{4,12, FALSE},	{4,12, FALSE}
	}
};
	
#define YEXL 32
static char yytext[YEXL];

static char *erryytextex(type)
	int type;
{
	char * strptr, *endptr;
	int charcnt;

	strptr = (lasttokfetch -> textstrt) - 1;
	if(type == STRING)
	{
		endptr = (lasttokfetch -> textend) - 1;
		if(*endptr == '\n')
			endptr --;
	}
	else
	{
		endptr = (lasttokfetch -> textend) - 2;
	}

	for(charcnt = 0; (strptr <= endptr) && charcnt < (YEXL - 1); charcnt ++)
	{
		yytext[charcnt] = *strptr++;
	}
	yytext[charcnt] = '\0';
}

int yylex()
{
	int scanstate;
	char *thistokstart;
	register char nextchar;
	int charset;
	long consaccum, consbase;



	if(currtok >= intokcnt)
	{
		switch(nextreadact)
		{
		case Nra_new:  /* access next file */
			fprintf(intermedf, "F:%s\n", infilestk[++currfstk].fnm);
			yyin = infilestk[currfstk].fpt;
			nextreadact = Nra_normal;
		case Nra_normal:
			if(frareadrec())
			{
				/* EOF */;
				return 0;
			}
			break;

		case Nra_end:  /* pop file and access previous */
			if(currfstk > 0)
			{
				fclose(yyin);
				yyin = infilestk[--currfstk].fpt;
				fprintf(intermedf, "X:%s\n",
					infilestk[currfstk].fnm);
				if(frareadrec())
				{
					/* EOF */;
					return 0;
				}
				else
				{
					nextreadact = Nra_normal;
				}
			}
			else
			{
				/* EOF */;
				return 0;
			}
			break;
		}

		if(listflag)
		{
			fputs(finbuff, intermedf);
		}
		else
		{
			fputs("L:\n", intermedf);
		}

		/* Scan a line */

		frainptr = &finbuff[2];

		currtok = intokcnt = 0;
		nexttokload = & scanqueue[0];

		tptrstr = &tempstrpool[0];
		scanstate = 0;
		whichsym = Symopcode;

		while( (nextchar = *frainptr++) != '\0' )
		{
			charset = chartrantab[nextchar & 0x7f];
			do {
				thisact =  & characttab [scanstate][charset];

#if DEBUG
	if(isprint(nextchar))
		printf("%c    ", nextchar);
	else
		printf("0x%2.2x ", nextchar);
	printf("%-18s %-33s %-11s  %2.2d\n",
		statelab[scanstate],
		actlab[thisact -> action],
		thisact -> contin ? "Continue" : "Swallow",
		thisact -> nextstate);
#endif

				switch(thisact -> action)
				{
				case 0: /* skip/no op */
					break;

				case 1: /* load EOL token */
					nexttokload -> lvalv.longv = 0;
					nexttokload -> tokv = EOL;
					nexttokload -> errtype = Yetunprint;
					nexttokload++;
					intokcnt++; 
					break;

				case 2: /* start string */
					thistokstart = tptrstr;
					nexttokload -> textstrt = frainptr;
					break;

				case 3: /* process label */
					{
			struct symel *tempsym;

			*tptrstr++ = '\0';
			tempsym = symbentry(thistokstart, SYMBOL);
			if((tempsym -> seg) != SSG_RESV)
			{
				nexttokload -> tokv = LABEL;
				nexttokload -> errtype = Yetsymbol;
				nexttokload -> lvalv.symb = tempsym;
			}
			else
			{
				nexttokload -> tokv = tempsym -> tok;
				nexttokload -> errtype = Yetreserved;
				nexttokload -> lvalv.intv = tempsym -> value;
			}
			nexttokload -> textend = frainptr;
			nexttokload++;
			intokcnt++; 
					}
					break;

				case 4: /* save string char */
					*tptrstr++ = nextchar;
					break;

				case 5: /* load single char token */
					nexttokload -> lvalv.longv = 0;
					nexttokload -> tokv = nextchar;
					nexttokload -> errtype = Yetprint;
					nexttokload++;
					intokcnt++; 
					break;

				case 6: /* load EQ token */
					nexttokload -> lvalv.longv = 0;
					nexttokload -> tokv = KEOP_EQ;
					nexttokload -> errtype = Yetunprint;
					nexttokload++;
					intokcnt++;
					break;

				case 7: /* process symbol */
					{
			register struct symel *symp;
			register char *ytp;
			int tempov;

			*tptrstr++ = '\0';
			if(whichsym == Symopcode)
			{
				for(ytp = thistokstart; *ytp != '\0'; 
					ytp++)
				{
					if(islower(*ytp))
					{
						*ytp = toupper(*ytp);
					}
				}
				nexttokload -> lvalv.intv 
					= tempov = findop(thistokstart);
				nexttokload -> tokv = 
					optab[tempov].token;
				nexttokload -> errtype = Yetopcode;
				whichsym = Symsym;
			}
			else
			{
				symp = symbentry(thistokstart,SYMBOL);
				if(symp -> seg != SSG_RESV)
				{
					nexttokload -> lvalv.symb = symp;
					nexttokload -> errtype = Yetsymbol;
				}
				else
				{
					nexttokload -> lvalv.intv 
						= symp->value;
					nexttokload -> errtype = Yetreserved;
				}

				nexttokload -> tokv = symp -> tok;
			}

			nexttokload -> textend = frainptr;
			nexttokload++;
			intokcnt++;
					}
					break;

				case 8: /* load $ token */
					nexttokload -> lvalv.longv = 0;
					nexttokload -> tokv = '$';
					nexttokload -> errtype = Yetprint;
					nexttokload++;
					intokcnt++;
					break;

				case 9: /* setup for $hex */
					consbase = 16;
					consaccum = 0;
					break;

				case 10: /* accumulate 0-9 constant */
					consaccum = (consaccum * consbase)
						+ (nextchar - '0');
					break;

				case 11: /* accumulate A-F constant  */
					consaccum = (consaccum * consbase)
						+ (nextchar - 'A' + 10);
					break;

				case 12: /* accumulate a-f constant */
					consaccum = (consaccum * consbase)
						+ (nextchar - 'a' + 10);
					break;

				case 13: /* load Constant token */
					nexttokload -> lvalv.longv = 
						consaccum;
					nexttokload -> tokv = CONSTANT;
					nexttokload -> errtype = Yetconstant;
					nexttokload -> textend = frainptr;
					nexttokload++;
					intokcnt++;
					break;

				case 14: /* load @ token */
					nexttokload -> lvalv.longv = 0;
					nexttokload -> tokv = '@';
					nexttokload -> errtype = Yetprint;
					nexttokload++;
					intokcnt++;
					break;

				case 15: /* setup for @octal */
					consbase = 8;
					consaccum = 0;
					break;

				case 16: /* setup for %binary */
					consbase = 2;
					consaccum = 0;
					break;

				case 17: /* load % token */
					nexttokload -> lvalv.longv = 0;
					nexttokload -> tokv = '%';
					nexttokload -> errtype = Yetprint;
					nexttokload++;
					intokcnt++;
					break;

				case 18: /* load String token */
					*tptrstr++  = '\0';
					nexttokload -> lvalv.strng = 
						thistokstart;
					nexttokload -> tokv = STRING;
					nexttokload -> errtype = Yetstring;
					nexttokload -> textend = frainptr;
					nexttokload++;
					intokcnt++;
					break;

				case 19: /* load GE token */
					nexttokload -> lvalv.longv = 0;
					nexttokload -> tokv = KEOP_GE;
					nexttokload -> errtype = Yetunprint;
					nexttokload++;
					intokcnt++;
					break;

				case 20: /* load GT token */
					nexttokload -> lvalv.longv = 0;
					nexttokload -> tokv = KEOP_GT;
					nexttokload -> errtype = Yetunprint;
					nexttokload++;
					intokcnt++;
					break;

				case 21: /* load LE token */
					nexttokload -> lvalv.longv = 0;
					nexttokload -> tokv = KEOP_LE;
					nexttokload -> errtype = Yetunprint;
					nexttokload++;
					intokcnt++;
					break;

				case 22: /* load NE token */
					nexttokload -> lvalv.longv = 0;
					nexttokload -> tokv = KEOP_NE;
					nexttokload -> errtype = Yetunprint;
					nexttokload++;
					intokcnt++;
					break;

				case 23: /* load LT token */
					nexttokload -> lvalv.longv = 0;
					nexttokload -> tokv = KEOP_LT;
					nexttokload -> errtype = Yetunprint;
					nexttokload++;
					intokcnt++;
					break;

				case 24: /* save numeric char 0-9 */
					*tptrstr++ = nextchar - '0';
					break;

				case 25: /* save numeric char A-F */
					*tptrstr++ = nextchar - 'A' + 10;
					break;

				case 26: /* save numeric char a-f */
					*tptrstr++ = nextchar - 'a' + 10;
					break;

				case 27: /* convert numeric string base 2 */
					{
			consaccum = 0;
			while(thistokstart < tptrstr)
			{
				consaccum = (consaccum * 2) + *thistokstart++;
			}
			nexttokload -> lvalv.longv = consaccum;
			nexttokload -> tokv = CONSTANT;
			nexttokload -> errtype = Yetconstant;
			nexttokload -> textend = frainptr;
			nexttokload++;
			intokcnt++;
					}
					break;

				case 28: /* convert numeric string base 8 */
					{
			consaccum = 0;
			while(thistokstart < tptrstr)
			{
				consaccum = (consaccum * 8) + *thistokstart++;
			}
			nexttokload -> lvalv.longv = consaccum;
			nexttokload -> tokv = CONSTANT;
			nexttokload -> errtype = Yetconstant;
			nexttokload -> textend = frainptr;
			nexttokload++;
			intokcnt++;
					}
					break;

				case 29: /* convert numeric string base 10 */
					{
			consaccum = 0;
			while(thistokstart < tptrstr)
			{
				consaccum = (consaccum * 10) + *thistokstart++;
			}
			nexttokload -> lvalv.longv = consaccum;
			nexttokload -> tokv = CONSTANT;
			nexttokload -> errtype = Yetconstant;
			nexttokload -> textend = frainptr;
			nexttokload++;
			intokcnt++;
					}
					break;

				case 30: /* convert numeric string base 16 */
					{
			consaccum = 0;
			while(thistokstart < tptrstr)
			{
				consaccum = (consaccum * 16) + *thistokstart++;
			}
			nexttokload -> lvalv.longv = consaccum;
			nexttokload -> tokv = CONSTANT;
			nexttokload -> errtype = Yetconstant;
			nexttokload -> textend = frainptr;
			nexttokload++;
			intokcnt++;
					}
					break;

				case 31: /* save numeric 0xb */
					*tptrstr++ = 0xb;
					break;

				case 32: /* save numeric 0xd */
					*tptrstr++ = 0xd;
					break;

				case 33: /* set text start */
					nexttokload -> textstrt = frainptr;
					break;
				
				case 34: /* token choke */
					nexttokload -> lvalv.longv = 0L;
					nexttokload -> tokv = KTK_invalid;
					nexttokload -> errtype = Yetinvalid;
					nexttokload -> textend = frainptr;
					nexttokload++;
					intokcnt++;
					break;
				}

				scanstate = thisact -> nextstate;

			}  while( thisact -> contin);
		}

		if(intokcnt <= 0)
		{ /* no tokens in line (comment or whitespace overlength) */
			scanqueue[0].tokv = EOL;
			scanqueue[0].errtype = Yetunprint;
			scanqueue[0].lvalv.longv = 0;
			intokcnt = 1;
		}

		if(scanstate != 0)
		{ /* no EOL */
			fraerror("Overlength/Unterminated Line");
		}
	}
	lasttokfetch = &scanqueue[currtok++];
	yylval = lasttokfetch -> lvalv;
	return lasttokfetch -> tokv;
}


yyerror(str)
	char *str;
/*	
	description	first pass - output a parser error to intermediate file
*/
{
	char * taglab;

	switch(lasttokfetch -> errtype)
	{
	case Yetprint:
		if( ! isprint(lasttokfetch -> tokv))
		{
			fprintf(intermedf, 
				"E: ERROR - %s at/before character \"^%c\"\n",
				str, PRINTCTRL(lasttokfetch -> tokv));
		}
		else
		{
			fprintf(intermedf, 
				"E: ERROR - %s at/before character \"%c\"\n",
				str, lasttokfetch -> tokv );
		}
		break;

	case Yetsymbol: 
	case Yetreserved: 
	case Yetopcode: 
	case Yetconstant: 
		erryytextex(SYMBOL);
		fprintf(intermedf, "E: ERROR - %s at/before token \"%s\" \n",
			str, yytext);
		break;

	case Yetinvalid: 
		erryytextex(SYMBOL);
		fprintf(intermedf, "E: ERROR - %s at invalid token \"%s\" \n",
			str, yytext);
		break;

	case Yetstring:
		erryytextex(STRING);
		fprintf(intermedf, "E: ERROR - %s at/before string %s \n",
			str, yytext);
		break;

	case Yetunprint:
		switch(lasttokfetch -> tokv)
		{
		case EOL:
			taglab = "End of Line";
			break;
		case KEOP_EQ:
			taglab = "\"=\"";
			break;
		case KEOP_GE:
			taglab = "\">=\"";
			break;
		case KEOP_GT:
			taglab = "\">\"";
			break;
		case KEOP_LE:
			taglab = "\"<=\"";
			break;
		case KEOP_NE:
			taglab = "\"<>\"";
			break;
		case KEOP_LT:
			taglab = "\"<\"";
			break;
		default:
			taglab = "Undeterminable Symbol";
			break;
		}
		fprintf(intermedf, "E: ERROR - %s at/before %s\n",
			str, taglab);
		break;

	default:
		fprintf(intermedf, "E: ERROR - %s - undetermined yyerror type\n",
			str);
		break;
	}

	errorcnt++;
}
