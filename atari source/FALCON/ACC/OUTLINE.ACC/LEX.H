/* lex.h for extend.sys files
 * 900814 kbad
 */

typedef enum {
	NO_TOKEN=-1,	/* illegal token	*/
	EOI,		/* end of input		*/
	SEMI,		/* ; comment character	*/
	EQUAL,		/* =			*/
	COMMA,		/* ,			*/
	PATH,		/* PATH			*/
	PATHSPEC,	/* drv:\path<path>	*/
	BITCACHE,	/* BITCACHE		*/
	FSMCACHE,	/* FSMCACHE		*/
	WIDTH,		/* WIDTHTABLES		*/
	SYMBOL,		/* SYMBOL		*/
	HEBREW,		/* HEBREW		*/
	FONT,		/* FONT			*/
	POINTS,		/* POINTS		*/
	NUMBER
} Token;

extern char *yytext;	/* lex	    - lexeme (not null-terminated)	*/
extern int  yyleng;	/* lex	    - lexeme length			*/
extern int  yylineno;	/* lex	    - input line number			*/

int	    isfilechar( int c );
int	    ispathchar( int c );

int	    match( Token token );
void	    advance( void );
