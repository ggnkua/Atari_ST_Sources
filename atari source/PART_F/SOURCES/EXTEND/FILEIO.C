/* fileio.c - i/o routines for extend.sys parser
 * 900814 kbad
 */

#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <ext.h>
#include "fileio.h"

static FILE	*infile;

/*
 * Open input file if input is not redirected.
 */
void
xopen( char *name )
{
    if( !isatty( stdin->Handle ) )
    {
	infile = stdin;
    }
    else
    {
	infile = fopen( name, "r" );
    }
}

/*
 * Get a line of up to LINE_MAX-1 chars from input file,
 * convert all uppercase characters to lowercase,
 * and discard chars beyond LINE_MAX-1.
 * Return string in 'buf', with newline discarded.
 */
char *
xgets( char *buf )
{
    char *s, *nl, temp[LINE_MAX];

    if( (s = fgets(buf, LINE_MAX, infile)) == NULL )
	return NULL;

    nl = s;
    while( *s && *s != '\n')
	*nl++ = (isalpha(*s)) ? tolower(*s++) : *s++;
    *nl++ = '\0';

    if( *s == '\n' )
	while( (nl = fgets(temp, LINE_MAX, infile)) != NULL )
	/* dump remainder of line */;

    return buf;
}

void
xclose( void )
{
    fclose( infile );
}
