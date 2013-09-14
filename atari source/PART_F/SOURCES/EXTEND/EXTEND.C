/* extend.c - parse extend.sys file
 * 900814 kbad
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <ext.h>
#include <errno.h>
#include "lex.h"
#include "fileio.h"

void	skipequal( void );
void	fonts( void );

char	fsmpath[LINE_MAX];
char	err[LINE_MAX];
struct stat statbuf;


int
isdir( struct stat *s )
{
    return (s->st_mode & S_IFDIR );
}

main()
{
    long    len;

    xopen( "c:\\extend.sys" );
    if( errno )
    {
	perror("extend.sys");
	exit( errno );
    }

    if( !match(PATH) )
    {
	fprintf( stderr, "%d: No PATH line at top of extend.sys file.\n",
		 yylineno );
	exit( 1 );
    }

    skipequal();

    if( match(PATHSPEC) )
    {
	strncpy( fsmpath, yytext, yyleng );
	len = yyleng-1;
	if( fsmpath[len] != '\\' ) ++len;
	fsmpath[len] = '\0';
	if( !stat(fsmpath, &statbuf) )
	    errno = (isdir(&statbuf)) ? 0 : ENOTDIR;
	if( errno )
	{
	    perror( fsmpath );
	    exit( errno );
	}
    }
    else
    {
	fprintf( stderr, "%d: Invalid PATH %s\n", yylineno, yytext );
	exit( 1 );
    }
    advance();

    printf( "FSM font path is %s.\n", fsmpath );

    while( !match(EOI) )
    {
	if( match(BITCACHE) )
	{
	    skipequal();
	    if( match(NUMBER) )
	    {
		printf( "Bitmap cache size = %ldK.\n", atol(yytext)/1024L );
		advance();
	    }
	    else
		fprintf( stderr, "%d: missing BITCACHE size\n", yylineno );
	}
	else if( match(FSMCACHE) )
	{
	    skipequal();
	    if( match(NUMBER) )
	    {
		printf( "FSM cache size = %ldK.\n", atol(yytext)/1024L );
		advance();
	    }
	    else
		fprintf( stderr, "%d: missing FSMCACHE size\n", yylineno );
	}
	else if( match(WIDTH) )
	{
	    skipequal();
	    if( match(NUMBER) )
	    {
		printf( "%s width tables.\n", (atol(yytext)) ?
			"Using" : "Not using" );
		advance();
	    }
	    else
		fprintf( stderr, "%d: missing WIDTHTABLES number\n",
			 yylineno );
	}
	else
 	    fonts();

    }

    return 0;
}

/* 
 * Advance past current token, and skip EQUAL token if one follows.
 * If current token isn't followed by EQUAL, print an error message.
 */
void
skipequal( void )
{
    advance();

    if( match(EQUAL) )
	advance();
    else
	fprintf( stderr, "%d: Inserting missing =\n", yylineno );
}


/*
 * Handle FONT and POINTS lines
 */
void
fonts( void )
{
    char    fontpath[LINE_MAX];
    char    fontname[LINE_MAX];
    char    qfm[LINE_MAX];
    char    *curpath, *ptext, *pqfm, *pname, *limit;

    if( match(FONT) || match(SYMBOL) || match(HEBREW) )
    {
	skipequal();

	/* Set fontname to next token,
	 * and set current font path to fsmpath\fontname
	 * If the font doesn't exist, set curpath to NULL,
	 * and print an error.
	 */
	curpath = NULL;
	if( match(PATHSPEC) )
	{
	    ptext = yytext;
	    pname = fontname;
	    pqfm = NULL;
	    limit = yytext + yyleng;
	    while( ptext < limit )
	    {
		if( isfilechar(*ptext) )
		    *pname++ = *ptext++;
		else
		{
		    strncpy( qfm, ptext, limit - ptext );
		    qfm[limit-ptext] = '\0';
		    if( strcmp(".qfm", qfm) == 0 )
			pqfm = qfm;
		    break;
		}
	    }
	    if( pqfm )
	    {
		*pname = '\0';
		sprintf( fontpath, "%s\\%s.qfm", fsmpath, fontname );
		if( !stat(fontpath, &statbuf) )
		    curpath = fontpath;
		if( curpath )
		    printf( "Font %s\t", fontname );
		else
		{
		    sprintf( err, "%d: (%s)", yylineno, fontpath );
		    perror( err );
		}
	    }
	    else
		fprintf( stderr, "%d: invalid font name %0.*s\n",
			 yyleng, yytext );
	    advance();
	}
	else
	{
	    fprintf( stderr, "%d: missing font name\n", yylineno );
	}

	/*
	 * If there's a POINTS line for this font, handle all point sizes.
	 */
	if( match(POINTS) )
	{
	    skipequal();

	    while( match(NUMBER) )
	    {
		printf( "%0.*s", yyleng, yytext );
		advance();
		if( match(COMMA) )
		{
		    printf( "," );
		    advance();
		}
		else
		{
		    printf( " points.\n" );
		    break;
		}
	    }
	}
	else
	    printf( "no points specified.\n" );
    }
}
