/*==========================================================================*/
/* SCANNER.H																*/
/* =========																*/
/*																			*/
/* include file for all parser related files, contains all typedefs		    */
/* and enum lists.								 							*/
/* 																			*/
/* Required by SCAN.C and TOKEN.C											*/
/* 																			*/
/* 																			*/
/* 																			*/
/*																			*/
/* Author: Pascal Fellerich													*/
/*																			*/
/* rev 1.00	16-may-1996	creation											*/
/*																			*/
/*																			*/
/*==========================================================================*/

/* general stuff */
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>


/*==========================================================================*/
/* MACRO DEFINITIONS														*/
/*==========================================================================*/

/*
 * UNCOMMENT THE NEXT LINE FOR FINAL VERSIONS!
 * (This will remove all assert() statements).
 */
/* #define NDEBUG */




/* === static limits =============== */

#define MAXNAME_LEN			255		/* max. token string data length */
#define MAXLINE_LEN			1023	/* max. input line length (net) */
#define DEFNAME_LEN			32		/* default name length */

#define HASHSIZE			101		/* hash table size (prime number) */
		/* examples: 101,211,307,401,503,601,701,809,901,1009,1511,2003... */

#define STRBLOCK_LEN		8L		/* used by Token.c, _must be a pwr of 2_ */




/* === VMS: VAXC lib extension ===== */
#ifdef __VAXC__
#define __VMS__
#endif

#ifdef __VMS__
/* These functions are defined at the end of SCAN.C */
int		strnicmp(const char *a, const char *b, size_t n);
int		stricmp(const char *a, const char *b);
char	*strupr(char *s);
#endif



/* === general ===================== */
#define MAX(a,b) (((a)>(b)) ? (a) : (b))
#define MIN(a,b) (((a)<(b)) ? (a) : (b))


/* === Shortcuts for token functions */
#define push(stk,obj)		tk_push(&stk, obj)
#define pop(stk)			tk_pop(&stk)
#define peek(stk)			tk_peek(&stk)
#define drop(stk)			tk_drop(&stk)
#define dup(tok)			tk_dup(tok)
#define isempty(stk)		tk_stack_isempty(&stk)
#define store(tab, tok)		tk_store(tab, tok)
#define locate(tab, tok)	tk_locate(tab, tok)


/* === various chars =============== */
#define NUL			'\0'
#define BEL			'\007'
#define QUOTE		'\''
#define DQUOTE		'"'
#define BACKSLASH	'\\'
#define SPACE		' '
#define USCORE		'_'
#define SEMICOLON	';'



/*==========================================================================*/
/* ENUM TYPES                 												*/
/*==========================================================================*/

/* 

#ifdef __VMS__
typedef int BOOL;
#else
typedef int BOOL;
#endif

*/

typedef int BOOL;
#ifndef TRUE
#define FALSE 0
#define TRUE !FALSE
#endif

/*
 * token defs:
 */
#define TKGROUP			0x1000

#define TokenKind(x)	((x) & 0xF000)		/* determine group */

typedef enum {
	NO_TOKEN	= 0,			/* unrecognized token */
	EOS			= 1,			/* end of token stream */
	NEWLINE 	= 10,			/* end of line */


	/*----------------------------------*
	 |	constants						*
	 *----------------------------------*/
	CONSTANT = 1*TKGROUP,
	REALCONST,	INTEGERCONST, BINCONST,	HEXCONST,
	STRINGCONST,


	/*----------------------------------*
	 |	indentifiers (and variables)	*
	 *----------------------------------*/
	IDENTIFIER = 2*TKGROUP,


	/*----------------------------------*
	 |	keywords						*
	 *----------------------------------*/
	KEYWORD = 3*TKGROUP,

	K_KBTAB_NORMAL,	K_KBTAB_SHIFT,	K_KBTAB_CAPSLOCK,	K_KBTAB_COMPOSE,
	K_NAME,			K_SWITCHES,		K_COMPOSE,			K_DEADKEY,
	K_EXTKEY,		K_ALT_NNN,		K_TABLE_APPLIES_TO,	K_ON,
	K_OFF,			K_DEC_MODE,		K_MULTICHAR,		K_AUTOMULTI,
	K_NOAUTOMULTI,	K_ORDER,		K_NOORDER,			K_NOTHING,
	K_KEYBOARD,		K_BOTH,			K_END,


	/*----------------------------------*
	 |	operators						*
	 *----------------------------------*/
	OPERATOR = 4*TKGROUP,

	OP_NOT,		OP_UPLUS,	OP_UMINUS,			/* monadic ops */

	OP_ASSIGN,	OP_PLUS,	OP_MINUS,			/* dyadic ops */
	OP_MUL,		OP_DIV,		OP_POWER,
	OP_EQ,		OP_NE,		OP_GT,
	OP_GE,		OP_LT,		OP_LE,
	OP_AND,		OP_OR,		OP_XOR,
	OP_MODULO,


	/*----------------------------------*
	 |	separators						*
	 *----------------------------------*/
	SEPARATOR = 5*TKGROUP,
	
	S_LPAREN,	S_RPAREN,	S_LBRACE,	S_RBRACE,
	S_LBRACKET,	S_RBRACKET,	S_COMMA,	S_COLON,
	S_SEMICOLON,	S_DOT,	S_DOUBLEDOT,

} Symbol;


/*==========================================================================*/
/* RELATED TYPE TEST FUNCTIONS												*/
/*==========================================================================*/
#define IsDyadicOperator(x)	((OP_ASSIGN<=(x) && (x)<=OP_XOR) || (x)==OP_MODULO)
#define IsOperator(x)		(TokenKind(x)==OPERATOR)
#define IsFunction(x)		(TokenKind(x)==FUNCTION)
#define IsKeyword(x)		(TokenKind(x)==KEYWORD)



/*==========================================================================*/
/* DATA STRUCTURES DEFINITIONS												*/
/*==========================================================================*/

typedef struct tokptr {		/* UNIVERSAL TOKEN -----------------------------*/
	struct tokptr *next;			/* universal link pointer */
	Symbol	token;					/* terminal symbol */

	/* start of static user data */

	/* end of static user data */
	
	char	name[STRBLOCK_LEN];		/* lbl/var: Identifier; stringdata */
	/* note: this element can be expanded dynamically in steps of STRBLOCK_LEN */
} Token;


typedef struct {			/* STACK ---------------------------------------*/
	Token	*root;					/* root pointer */
	int		count;					/* number of entries */
} Stack;


typedef Token *Hashtable[HASHSIZE];


typedef struct {			/* keyword templates as defined in the lists ---*/
	char	*name;
	Symbol	sym;
} Keyword;


/*==========================================================================*/
/* prototypes and global variables...										*/
/*==========================================================================*/

/* external, to be supplied by user */
int		ReadLine(char *buf, size_t nchars);		/* for the scanner */
void	internal_error(char *msg);				/* something went wrong! */


/* from TOKEN.C */
extern long tk_created;							/* number of tokens created */
extern long tk_disposed;						/* number of tokens released */

Token*	tk_create(size_t datasize);				/* basic handling */
BOOL	tk_dispose(Token *t);
void	tk_zero(Token *t);
Token*	tk_dup(Token *t);

void	stack_init(Stack *st);					/* stacks */
BOOL	tk_push(Stack *st, Token *t);
Token*	tk_pop(Stack *st);
Token*	tk_peek(Stack *st);
BOOL	tk_drop(Stack *st);
void	tk_stack_clear(Stack *st);
BOOL	tk_stack_isempty(Stack *st);
long	tk_stack_size(Stack *st);

void	hashtable_init(Hashtable tab);			/* hash tables */
Token*	tk_store(Hashtable tab, Token *t);
Token*	tk_locate(Hashtable tab, Token *t);
Token*	tk_remove(Hashtable tab, Token *t);
void	tk_table_clear(Hashtable tab);
long	tk_table_scan(Hashtable tab, BOOL (*examine)(const Token *) );


/* from SCAN.C */
extern Token *symbol;					/* ptr to main token used */
extern long	cline;						/* current line number */
extern char	line[];						/* input line */
extern char	*lineptr;					/* read pointer */

BOOL scanner_init(void);
void scanner_exit(void);

BOOL get_symbol(void);
BOOL unget_symbol(void);				/* use with care! */
BOOL get_constant(void);
BOOL get_token(Keyword *list);
BOOL get_identifier(void);
BOOL flushline(void);
void ltrim(void);
BOOL newline(void);


/*==========================================================================*/
/* eof    																	*/
/*==========================================================================*/

