
/*
HEADER: 	;
TITLE: 		Frankenstein Cross Assemblers;
VERSION: 	2.0;
DESCRIPTION: "	Reconfigurable Cross-assembler producing Intel (TM)
		Hex format object records.  ";
FILENAME: 	frasmdat.h;
SEE-ALSO: 	;
AUTHORS: 	Mark Zenier;
*/

/*
	description	structures and data used in parser and output phases
	history		September 15, 1987
			August 3, 1988   Global
			September 14, 1990   6 char portable var
*/

#include <ctype.h>
#define PRINTCTRL(char) ((char)+'@')

#ifndef Global
#define	Global	extern
#endif

#ifdef USEINDEX
#define strchr index
#endif

#ifdef NOSTRING
extern char * strncpy();
extern char * strchr();
extern int strcmp();
extern int strlen();
#else
#include <string.h>
#endif

#define local 

#define TRUE 1
#define FALSE 0

#define hexch(cv) (hexcva[(cv)&0xf])
extern char hexcva[];

/* symbol table element */
struct symel
{
	char	*symstr;
	int	tok;
	int	seg;
	long	value;
	struct	symel *nextsym;
	int	symnum;
};

#define SSG_UNUSED 0
#define SSG_UNDEF -1
#define SSG_ABS 8
#define SSG_RESV -2
#define SSG_EQU 2
#define SSG_SET 3

#define SYMNULL (struct symel *) NULL
struct symel * symbentry();

/* opcode symbol table element */

struct opsym
{
	char	*opstr;
	int	token;
	int	numsyn;
	int	subsyn;
};

struct opsynt
{
	int	syntaxgrp;
	int	elcnt;
	int	gentabsub;
};

struct igel 
{
	int	selmask;
	int	criteria;
	char	* genstr;
};
	
#define PPEXPRLEN 256

struct evalrel
{
	int	seg;
	long	value;
	char	exprstr[PPEXPRLEN];
};

#define INBUFFSZ 258
extern char finbuff[INBUFFSZ];

extern int nextsymnum;
Global struct symel **symbindex;

#define EXPRLSIZE (INBUFFSZ/2)
extern int nextexprs;
Global int	exprlist[EXPRLSIZE];

#define STRLSIZE (INBUFFSZ/2)
extern int nextstrs;
Global char *	stringlist[STRLSIZE];

extern struct opsym optab[];
extern int gnumopcode;
extern struct opsynt ostab[];
extern struct igel igtab[];
extern int ophashlnk[];

#define NUMPEXP 6
Global struct evalrel evalr[NUMPEXP];

#define PESTKDEPTH 32
struct evstkel
{
	long v;
	int s;
};

Global struct evstkel	estk[PESTKDEPTH], *estkm1p;

Global int	currseg; 
Global long 	locctr; 

extern FILE *yyin;
extern FILE	*intermedf;
extern int	listflag;
extern int hexvalid, hexflag;
Global FILE	*hexoutf, *loutf;
extern int errorcnt, warncnt;

extern int linenumber;

#define IFSTKDEPTH 32
extern int	ifstkpt; 
Global enum { If_Active, If_Skip, If_Err } 
	elseifstk[IFSTKDEPTH], endifstk[IFSTKDEPTH];

#define FILESTKDPTH 20
Global int currfstk;
#define nextfstk (currfstk+1)
Global struct fstkel
{
	char *fnm;
	FILE *fpt;
} infilestk[FILESTKDPTH];

Global int lnumstk[FILESTKDPTH];
Global char currentfnm[100];

extern struct symel * endsymbol;

enum readacts
{
	Nra_normal, 
	Nra_new, 
	Nra_end 
} ;

extern enum readacts nextreadact;

char * savestring(), *findgen();
long	strtol();
void	reservedsym();
char	*calloc(), *malloc();

extern struct symel * endsymbol;
extern char ignosyn[] ;
extern char ignosel[] ;

#define NUM_CHTA 6
extern int chtnxalph, *chtcpoint, *chtnpoint ;
Global int *(chtatab[NUM_CHTA]);
int chtcreate(), chtcfind(), chtran();

#define CF_END		-2
#define CF_INVALID 	-1
#define CF_UNDEF 	0
#define CF_CHAR 	1
#define CF_NUMBER 	2

