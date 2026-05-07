#define	VERSION "1.07 "		/* N.NNw *only* */
#define MONTHYEAR "Nov 1988"	/* Mon YYYY *only* */


/*
 *  Atari ST definitions (Alcyon 5.0 C68 C compiler)
 */
#ifdef ST
#define SYSTEM	"Atari ST"
#define	CREATMASK	0
#define	STDOUT		1
#define	ERROUT		1
#define	BYTE unsigned char
#define	WORD unsigned short
#define	LONG unsigned long
#define	VOID void
#define	SLASHCHAR '\\'
#define	SLASHSTRING "\\"
#define PRTERR0(a) printf(a)
#define PRTERR1(a,b) printf(a,b)
#define	DEBUG if(debug) DBpause(); if(debug)
#endif

/*
 * VAX BSD definitions
 */
#ifdef BSD
#define UNIX
#define	SYSTEM	"Vax BSD"
#define	CREATMASK	0666
#define	STDOUT		1
#define	ERROUT		2
#define	BYTE unsigned char
#define	WORD unsigned short
#define	LONG unsigned long
#define	VOID void
#define	SLASHCHAR '/'
#define	SLASHSTRING "/"
#define PRTERR0(a) fprintf(stderr, a)
#define PRTERR1(a,b) fprintf(stderr, a,b)
#define	DEBUG if(debug)
#endif


/*
 * System V definitions (ATT 3B1 SVR2)
 */
#ifdef SYSV
#define UNIX
#define	SYSTEM	"3B1 SysV"
#define	CREATMASK	0666
#define	STDOUT		1
#define	ERROUT		2
#define	BYTE unsigned char
#define	WORD unsigned short
#define	LONG unsigned long
#define	VOID void
#define	SLASHCHAR '/'
#define	SLASHSTRING "/"
#define PRTERR0(a) fprintf(stderr, a)
#define PRTERR1(a,b) fprintf(stderr, a,b)
#define	DEBUG if(debug)
#endif

/*
 *  MSDOS definitions (MSC 5.1)
 */
#ifdef MSDOS
#define SYSTEM	"MSDOS"
#define	CREATMASK	0
#define	STDOUT		1
#define	ERROUT		1
#define	BYTE unsigned char
#define	WORD unsigned short
#define	LONG unsigned long
#define	VOID void
#define	SLASHCHAR '\\'
#define	SLASHSTRING "\\"
#define PRTERR0(a) printf(a)
#define PRTERR1(a,b) printf(a,b)
#define	DEBUG if(debug)
#endif

/*
 *  Linux x86
 */
#ifdef LINUX86
#define SYSTEM	"Linux 386"
#define	CREATMASK	0666
#define	STDOUT		1
#define	ERROUT		1
#define	BYTE unsigned char
#define	WORD unsigned short
#define	LONG unsigned long
#define	VOID void
#define	SLASHCHAR '/'
#define	SLASHSTRING "/"
#define PRTERR0(a) printf(a)
#define PRTERR1(a,b) printf(a,b)
#define	DEBUG if(debug)
#define USE_STANDARD_LIBS
#define UNIX
#endif


#ifndef NULL
#define	NULL	((long)0)	/* must fit in a pointer */
#endif

#define	NOREG			/* NOREG, reverse of "register" */
#define	OK	0		/* OK return */
#define	ERROR	(-1)		/* generic error return */
#define	EOS	'\0'		/* end of string */
#define	SPACE	' '		/* ascii space */
#define	FNSIZ	128		/* maximum size of a filename */

#define	VALUE	LONG		/* assembler value */
#define	TOKEN	LONG		/* assembler token */


/*
 *  Common functions and debugging aids
 */
#ifndef USE_STANDARD_LIBS
char *malloc();			/* ditto */
#else
#include <memory.h>
#include <stdlib.h>
#include <stdio.h>
#endif

char *amem();			/* alloc a chunk of memory */
extern int debug;


/*
 *  Symbols
 */
#define	SYM struct _sym
SYM {
  SYM *snext;			/* -> next symbol on hash-chain */
  SYM *sorder;			/* -> next symbol in order of reference */
  SYM *sdecl;			/* -> next symbol in order of declaration */
  BYTE stype;			/* symbol type */
  WORD sattr;			/* attribute bits */
  WORD senv;			/* enviroment number */
  LONG svalue;			/* symbol value */
  char *sname;			/* -> symbol's print-name */
};

/* symbol spaces: */
#define	LABEL	0		/* user-defined symbol */
#define	MACRO	1		/* macro definition */
#define	MACARG	2		/* macro argument */
#define	SY_UNDEF -1		/* undefined (lookup never matches it) */

/*
 *  Symbol and expression attributes
 *   (ORed with expression spaces below)
 */
#define	DEFINED		0x8000	/* symbol has been defined */
#define	GLOBAL		0x4000	/* symbol has been .GLOBL'd */
#define	COMMON		0x2000	/* symbol has been .COMM'd */
#define	REFERENCED	0x1000	/* symbol has been referenced */
#define	EQUATED		0x0800	/* symbol was equated */
#define	SDECLLIST	0x0400	/* symbol is on 'sdecl'-order list */

/*
 *  Expression spaces
 *   ORed with symbol and expression attributes above
 */
#define	ABS		0x0000	/* in absolute space */
#define	TEXT		0x0001	/* relative to text */
#define	DATA		0x0002	/* relative to data */
#define	BSS		0x0004	/* relative to BSS */
#define	M6502		0x0008	/* 6502/microprocessor (absolute) */
#define TDB		(TEXT|DATA|BSS)	/* mask for text+data+bss */


/*
 *  Pointer type that can point to (almost) anything
 */
#define PTR union _ptr
PTR {
  char *cp;			/* char* */
  WORD *wp;			/* WORD* */
  LONG *lp;			/* LONG* */
  LONG lw;			/* LONG*/
  SYM **sy;			/* SYM** */
  TOKEN *tk;			/* TOKEN* */
};



/*  Sizes */
#define	SIZB		0x0001	/* .b */
#define	SIZW		0x0002	/* .w */
#define	SIZL		0x0004	/* .l */
#define	SIZN		0x0008	/* no .(size) specifier */


/*
 *  (normally) non-printable tokens
 *
 */
#define	COLON	':'		/* : (grumble: GNUmacs hates ':') */
#define	CONST	'a'		/* CONST <value> */
#define	ACONST	'A'		/* ACONST <value> <attrib> */
#define	STRING	'b'		/* STRING <address> */
#define	SYMBOL	'c'		/* SYMBOL <address> */
#define	EOL	'e'		/* end of line */
#define	TKEOF	'f'		/* end of file (or macro) */
#define	DEQUALS	'g'		/* == */
#define	SET	'S'		/* set */
#define	REG	'R'		/* reg */
#define	DCOLON	'h'		/* :: */
#define	GE	'i'		/* >= */
#define	LE	'j'		/* <= */
#define	NE	'k'		/* <> or != */
#define	SHR	'l'		/* >> */
#define	SHL	'm'		/* << */
#define	UNMINUS	'n'		/* unary '-' */
#define	DOTB	'B'		/* .b or .B or .s or .S */
#define	DOTW	'W'		/* .w or .W */
#define	DOTL	'L'		/* .l or .L */
#define	ENDEXPR	'E'		/* end of expression */


/*
 * ^^ operators:
 */
#define CR_DEFINED	'p'	/* ^^defined --- is symbol defined? */
#define CR_REFERENCED	'q'	/* ^^referenced --- was symbol referenced? */
#define CR_STREQ	'v'	/* ^^streq --- compare two strings */
#define	CR_MACDEF	'w'	/* ^^macdef -- is macro defined? */
#define	CR_TIME		'x'	/* ^^time -- DOS format time */
#define	CR_DATE		'y'	/* ^^date -- DOS format date */

/*
 *  Object code formats
 */
#define	ALCYON	0		/* Alcyon/DRI C object format */
#define	MWC	1		/* Mark Williams object format */
