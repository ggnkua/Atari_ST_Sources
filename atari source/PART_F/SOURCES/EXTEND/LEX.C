/* lex.c for extend.sys files
 * 900814 kbad
 */

/* extendsys ->		fsmpath cache width fonts
 * fsmpath ->		PATH = pathspec
 *
 * pathspec ->		drive path filespec
 * drive ->		letter:\ | letter: | <e>
 * path ->		.\ |  ..\ | filespec\ | <e>
 * filespec ->		filename ext
 * filename ->		filechar optchars
 * filechar ->		[!"#$%&'()+,-;<=>@[]^_`{|}~0-9a-zA-Z]
 * optchars ->		optchar optchars
 * optchar ->		filechar | <e>
 * ext ->		.optchar optchars
 *
 * cache ->		BITCACHE = NUMBER | FSMCACHE = NUMBER | <e>
 * width ->		WIDTHTABLES = NUMBER | <e>
 * fonts ->		SYMBOL = fontname points |
 *			HEBREW = fontname points |
 *			FONT = fontname points |
 *			<e>
 * fontname ->		filename .QFM
 * points ->		POINTS = pointlist | <e>
 * pointlist ->		NUMBER morepoints | <e>
 * morepoints ->	,NUMBER morepoints | <e>
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "lex.h"
#include "fileio.h"

char	*yytext = "";	/* lexeme (not '\0' terminated)	*/
int	yyleng;		/* lexeme length		*/
int	yylineno;	/* input line number		*/

typedef struct {
	char	*name;
	Token	tok;
} KWORD;

static KWORD	Ktab[] =
{
    { "path",	    PATH	},
    { "bitcache",   BITCACHE	},
    { "fsmcache",   FSMCACHE	},
    { "widthtables",WIDTH	},
    { "symbol",	    SYMBOL	},
    { "hebrew",	    HEBREW	},
    { "font",	    FONT	},
    { "points",	    POINTS	}
};
static int	ktabIsSorted = 0;

static int
cmpKWORD( KWORD *a, KWORD *b )
{
    return ( strcmp(a->name, b->name) );
}

int
isfilechar( int c )
{
/* legal pathname characters ,;= removed to avoid parse conflict
 * static char *valid = "!\"#$%&'()+,-;<=>@[]^_`{|}~";
 */
static char *valid = "!\"#$%&'()+-<>@[]^_`{|}~";
    return ( isalnum(c) || strchr(valid,c) || (c > '\x7f') );
}

int
ispathchar( int c )
{
    return( (c == '.') || (c == ':') || (c == '\\') || isfilechar(c) );
}

Token
lex( void )
{
static	char	input_buffer[LINE_MAX], ktok[LINE_MAX];
	char	*current, *s;
	KWORD	*k, kword;

    kword.name = ktok;

    current = yytext + yyleng;	/* skip current lexeme	*/

    for(;;)			/* get the next one	*/
    {

	while( !*current )
	{
	    /* Get new lines, skipping any leading white space on the line,
	     * until a nonblank line is found.
	     */

	    current = input_buffer;
	    if( !xgets(input_buffer) )
	    {
		*current = '\0';
		return EOI;
	    }
	    ++yylineno;


	    while( isspace(*current) )
		++current;
	}

	for( ; *current ; ++current )
	{
	    /* Get the next token */

	    yytext = current;
	    yyleng = 1;

	    switch( *current )
	    {
	    case ';':	while( *++current )
			/* discard comments */;
			break;
	    case '=':	return EQUAL;
	    case ',':	return COMMA;
	    /* ignore articles */

	    case '\t':
	    case ' ' :
	    break;

	    default:
		if( ispathchar(*current) )
		{
		    /* find the end of number/keyword tokens */

		    while( *current && ispathchar(*current) )
			++current;
		    yyleng = (int)(current - yytext);

		    /* number */
		    strtol( yytext, &s, 0 );
		    if( s != yytext )
			return NUMBER;

		    /* keyword */
		    strncpy( ktok, yytext, yyleng );
		    ktok[yyleng] = '\0';
		    if( !ktabIsSorted )
		        qsort( Ktab, sizeof(Ktab)/sizeof(KWORD),
			       sizeof(KWORD), cmpKWORD );
		    k = bsearch( &kword, Ktab, sizeof(Ktab)/sizeof(KWORD),
				 sizeof(KWORD), cmpKWORD );
		    if( k )
			return k->tok;

		    /* fontname or pathspec */
		    return PATHSPEC;
		}
		else
		    fprintf( stderr, "%d: ignoring illegal char <%c>\n",
			     yylineno, *current );
	    break;
	    }
	}
    }
}


Token	lookahead = NO_TOKEN;

int
match( Token token )
{
    /* Return TRUE if "token" matches the current lookahead symbol. */

    if( lookahead == NO_TOKEN )
	lookahead = lex();

    return (token == lookahead);
}

void
advance( void )
{
    /* Advance the lookahead to the next input symbol. */

    lookahead = lex();
}
