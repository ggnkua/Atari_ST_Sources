/*
 * Bawk main program
 */
#define MAIN 1

#include <ctype.h>
#include <stdio.h>
#include "bawk.h"

/*
 * Main program
 */
main( argc, argv )
int argc;
char **argv;
{
        int gotrules, didfile;

        didfile =
        gotrules = 0;

        /*
         * Initialize global variables:
         */
        Beginact = (char *) 0;
        Endact = (char *) 0;
        Rules = (struct rule *) 0;
        Rulep = (struct rule *) 0;
#ifdef DEBUG
        Debug = 0;
#endif
        Filename = (char *) 0;
        Linecount = 0;
        Saw_break = 0;
        Stackptr = Stackbtm - 1;
        Stacktop = Stackbtm + MAXSTACKSZ;
        Nextvar = Vartab;

        strcpy( Fieldsep, " \t" );
        strcpy( Recordsep, "\n" );

        /*
         * Parse command line
         */

	argv ++ ;
	argc -- ;
	
        while ( argc > 0 && *argv[0] == '-')
        {
                /*
                 * Process dash options.
                 */
                switch ( *(argv[0] + 1) )
                {
#ifdef DEBUG
                case 'd':
                        ++Debug;
                        break;
#endif
		case 'F':
			Fieldsep[0] = *(argv[0] + 1);
			Fieldsep[1] = '\0';
			break;

		case 'f':
			argv++ ; argc-- ;
			if ( gotrules || argc <= 0 ) usage();
                        if ( !strcmp( *argv, "-" ) )
                                newfile( (char *)NULL );
                        else
				newfile( *argv );
			compile();
			gotrules = 1;
			break;

		case '\0':
			goto dosomething;
                default: usage();
                }

		argv++ ; argc -- ;
        }

    dosomething:

        while ( argc-- > 0 )
        {
                if ( gotrules )
                {
                        /*
                         * Already read rules file - assume this is
                         * is a text file for processing.
                         */
                        if ( ++didfile == 1 && Beginact )
                                doaction( Beginact );
                        if ( !strcmp( *argv, "-" ) )
                                newfile( (char *)NULL );
                        else
                                newfile( *argv );
                        process();
                }
                else
                {
                        /*
                         * First argument on command line is assumed
                         * to be a prgram - attempt to compile it.
                         */
                        strfile( *argv );
                        compile();
                        gotrules = 1;
                }
                argv++;
        }
        if ( !gotrules )
                usage();

        if ( ! didfile )
        {
                /*
                 * Didn't process any files yet - process stdin.
                 */
                newfile( (char *)NULL );
                if ( Beginact )
                        doaction( Beginact );
                process();
        }
        if ( Endact )
                doaction( Endact );

	exit(0) ;
}

/*
 * Regular expression/action file compilation routines.
 */
compile()
{
        /*
         * Compile regular expressions and C actions into Rules struct,
         * reading from current input file "Fileptr".
         */
        int c, len;

#ifdef DEBUG
        if ( Debug )
                error( "compiling...", 0 );
#endif

        while ( (c = getcharacter()) != -1 )
        {
                if ( c==' ' || c=='\t' || c=='\n' )
                        /* swallow whitespace */
                        ;
                else if ( c=='#' )
                {
                        /*
                         * Swallow comments
                         */
                        while ( (c=getcharacter()) != -1 && c!='\n' )
                                ;
                }
                else if ( c=='{' )
                {
#ifdef DEBUG
                        if ( Debug )
                                error( "action", 0 );
#endif
                        /*
                         * Compile (tokenize) the action string into our
                         * global work buffer, then allocate some memory
                         * for it and copy it over.
                         */
                        ungetcharacter( '{' );
                        len = act_compile( Workbuf );

                        if ( Rulep && Rulep->action )
                        {
                                Rulep->nextrule = (struct rule *)getmem((unsigned int) sizeof( *Rulep ) );
                                Rulep = Rulep->nextrule;
                                fillmem((char *) Rulep, sizeof( *Rulep ), 0 );
                        }
                        if ( !Rulep )
                        {
                                /*
                                 * This is the first action encountered.
                                 * Allocate the first Rules structure and
                                 * initialize it
                                 */
                                Rules = Rulep = (struct rule *) getmem( (unsigned int) sizeof( *Rulep ) );
                                fillmem((char *) Rulep, sizeof( *Rulep ), 0 );
                        }
                        Rulep->action = getmem((unsigned int) len );
                        movemem( Workbuf, Rulep->action, len );
                }
                else if ( c==',' )
                {
#ifdef DEBUG
                        if ( Debug )
                                error( "stop pattern", 0 );
#endif
                        /*
                         * It's (hopefully) the second part of a two-part
                         * pattern string.  Swallow the comma and start
                         * compiling an action string.
                         */
                        if ( !Rulep || !Rulep->pattern.start )
                                error( "stop pattern without a start",
                                        RE_ERROR );
                        if ( Rulep->pattern.stop )
                                error( "already have a stop pattern",
                                        RE_ERROR );
                        len = pat_compile( Workbuf );
                        Rulep->pattern.stop = getmem((unsigned int) len );
                        movemem( Workbuf, Rulep->pattern.stop, len );
                }
                else
                {
                        /*
                         * Assume it's a regular expression pattern
                         */
#ifdef DEBUG
                        if ( Debug )
                                error( "start pattern", 0 );
#endif

                        ungetcharacter( c );
                        len = pat_compile( Workbuf );

                        if ( *Workbuf == T_BEGIN )
                        {
                                /*
                                 * Saw a "BEGIN" keyword - compile following
                                 * action into special "Beginact" buffer.
                                 */
                                len = act_compile( Workbuf );
                                Beginact = getmem((unsigned int) len );
                                movemem( Workbuf, Beginact, len );
                                continue;
                        }
                        if ( *Workbuf == T_END )
                        {
                                /*
                                 * Saw an "END" keyword - compile following
                                 * action into special "Endact" buffer.
                                 */
                                len = act_compile( Workbuf );
                                Endact = getmem((unsigned int) len );
                                movemem( Workbuf, Endact, len );
                                continue;
                        }
                        if ( Rulep )
                        {
                                /*
                                 * Already saw a pattern/action - link in
                                 * another Rules structure.
                                 */
                                Rulep->nextrule = (struct rule *) getmem((unsigned int) sizeof( *Rulep ) );
                                Rulep = Rulep->nextrule;
                                fillmem((char *) Rulep, sizeof( *Rulep ), 0 );
                        }
                        if ( !Rulep )
                        {
                                /*
                                 * This is the first pattern encountered.
                                 * Allocate the first Rules structure and
                                 * initialize it
                                 */
                                Rules = Rulep = (struct rule *) getmem((unsigned int) sizeof( *Rulep ) );
                                fillmem((char *) Rulep, sizeof( *Rulep ), 0 );
                        }
                        if ( Rulep->pattern.start )
                                error( "already have a start pattern",
                                        RE_ERROR );

                        Rulep->pattern.start = getmem((unsigned int) len );
                        movemem( Workbuf, Rulep->pattern.start, len );
                }
        }
        endfile();
}

/*
 * Text file main processing loop.
 */
process()
{
        /*
         * Read a line at a time from current input file at "Fileptr",
         * then apply each rule in the Rules chain to the input line.
         */
        int i;

#ifdef DEBUG
        if ( Debug )
                error( "processing...", 0 );
#endif

        Recordcount = 0;

        while ( getline() )
        {
                /*
                 * Parse the input line.
                 */
                Fieldcount = parse( Linebuf, Fields, Fieldsep );
#ifdef DEBUG
                if ( Debug>1 )
                {
                        printf( "parsed %d words:\n", Fieldcount );
                        for(i=0; i<Fieldcount; ++i )
                                printf( "<%s>\n", Fields[i] );
                }
#endif

                Rulep = Rules;
                while ( Rulep )
                {
                        if ( Rulep->pattern.startseen )
                        {
                                /*
                                 * Start pattern already found - perform
                                 * action then check if line matches
                                 * stop pattern.
                                 */
                                doaction( Rulep->action );
                                if ( dopattern( Rulep->pattern.stop ) )
                                        Rulep->pattern.startseen = 0;
                        }
                        else if ( dopattern( Rulep->pattern.start ) )
                        {
                                /*
                                 * Matched start pattern - perform action.
                                 * If a stop pattern was given, set "start
                                 * pattern seen" flag and process every input
                                 * line until stop pattern found.
                                 */
                                doaction( Rulep->action );
                                if ( Rulep->pattern.stop )
                                        Rulep->pattern.startseen = 1;
                        }
                        Rulep = Rulep->nextrule;
                }

                /*
                 * Release memory allocated by parse().
                 */
                while ( Fieldcount )
                        free( Fields[ --Fieldcount ] );
        }
}

/*
 * Miscellaneous functions
 */
parse( str, wrdlst, delim )
char *str;
char *wrdlst[];
char *delim;
{
        /*
         * Parse the string of words in "str" into the word list at "wrdlst".
         * A "word" is a sequence of characters delimited by one or more
         * of the characters found in the string "delim".
         * Returns the number of words parsed.
         * CAUTION: the memory for the words in "wrdlst" is allocated
         * by malloc() and should eventually be returned by free()...
         */
        int wrdcnt, wrdlen;
        char wrdbuf[ MAXLINELEN ], c;

        wrdcnt = 0;
        while ( *str )
        {
                while ( instr( *str, delim ) )
                        ++str;
                if ( !*str )
                        break;
                wrdlen = 0;
                while ( (c = *str) && !instr( c, delim ) )
                {
                        wrdbuf[ wrdlen++ ] = c;
                        ++str;
                }
                wrdbuf[ wrdlen++ ] = 0;
                /*
                 * NOTE: allocate a MAXLINELEN sized buffer for every
                 * word, just in case user wants to copy a larger string
                 * into a field.
                 */
                wrdlst[ wrdcnt ] = getmem((unsigned int) MAXLINELEN );
                strcpy( wrdlst[ wrdcnt++ ], wrdbuf );
        }

        return wrdcnt;
}

unparse( wrdlst, wrdcnt, str, delim )
char *wrdlst[];
int wrdcnt;
char *str;
char *delim;
{
        /*
         * Replace all the words in "str" with the words in "wrdlst",
         * maintaining the same word seperation distance as found in
         * the string.
         * A "word" is a sequence of characters delimited by one or more
         * of the characters found in the string "delim".
         */
        int wc;
        char strbuf[ MAXLINELEN ], *sp, *wp, *start;

        wc = 0;         /* next word in "wrdlst" */
        sp = strbuf;    /* points to our local string */
        start = str;    /* save start address of "str" for later... */
        while ( *str )
        {
                /*
                 * Copy the field delimiters from the original string to
                 * our local version.
                 */
                while ( instr( *str, delim ) )
                        *sp++ = *str++;
                if ( !*str )
                        break;
                /*
                 * Skip over the field in the original string and...
                 */
                while ( *str && !instr( *str, delim ) )
                        ++str;

                if ( wc < wrdcnt )
                {
                        /*
                         * ...copy in the field in the wordlist instead.
                         */
                        wp = wrdlst[ wc++ ];
                        while ( *wp )
                                *sp++ = *wp++;
                }
        }
        /*
         * Tie off the local string, then copy it back to caller's string.
         */
        *sp = 0;
        strcpy( start, strbuf );
}

instr( c, s )
char c, *s;
{
        while ( *s )
                if ( c==*s++ )
                        return 1;
        return 0;
}

char *
getmem( len )
unsigned len;
{
        char *cp, *malloc();

        if ( cp=malloc( len ) )
                return cp;
        error( "out of memory", MEM_ERROR );
}

char *
newfile( s )
char *s;
{
	static int getstdin = 0;

        Linecount = 0;
        if ( Filename = s )
        {
#ifdef BDS_C
                if ( fopen( s, Fileptr = Curfbuf ) == -1 )
#else
                if ( !(Fileptr = fopen( s, "r" )) )
#endif
                        error( "file not found", FILE_ERROR );
        }
        else
        {
                /*
                 * No file name given - process standard input.
                 */
	        if ( getstdin++ )
	        	error( "stdin usage must be unique", USAGE_ERROR );
                Fileptr = stdin;
                Filename = "standard input";
        }

	return s ;
}

strfile( s )
char *s;
{
        Linecount = 0;
        Fileptr = (FILE *)NULL;
        Filename = "argument";
        Filechar = s;
}

getline()
{
        /*
         * Read a line of text from current input file.  Strip off
         * trailing record seperator (newline).
         */
        int rtn, len;

        for ( len=0; len<MAXLINELEN; ++len )
        {
                if ( (rtn = getcharacter()) == *Recordsep || rtn == -1 )
                        break;
                Linebuf[ len ] = rtn;
        }
        Linebuf[ len ] = 0;

        if ( rtn == -1 )
        {
                endfile();
                return 0;
        }
        return 1;
}

getcharacter()
{
        /*
         * Read a character from curren input file.
         * WARNING: your getc() must convert lines that end with CR+LF
         * to LF and CP/M's EOF character (^Z) to a -1.
         * Also, getc() must return a -1 when attempting to read from
         * an unopened file.
         */
        int c;

        if ( Fileptr == (FILE *) NULL ) {
        	c = *Filechar;
        	if ( c == 0 )
        		c = -1;
        	else
        		Filechar++;
        } else
#ifdef BDS_C
        /*
         * BDS C doesn't do CR+LF to LF and ^Z to -1 conversions <gag>
         */
        if ( (c = getc( Fileptr )) == '\r' )
        {
                if ( (c = getc( Fileptr )) != '\n' )
                {
                        ungetc( c );
                        c = '\r';
                }
        }
        else if ( c == 26 )     /* ^Z */
                c = -1;
#else
        c = getc( Fileptr );
#endif

        if ( c == *Recordsep )
                ++Recordcount;
        if ( c=='\n' )
                ++Linecount;

        return c;
}

ungetcharacter( c )
{
        /*
         * Push a character back into the input stream.
         * If the character is a record seperator, or a newline character,
         * the record and line counters are adjusted appropriately.
         */
        if ( c == *Recordsep )
                --Recordcount;
        if ( c=='\n' )
                --Linecount;
        if ( Fileptr == (FILE *)NULL )
        	return *--Filechar = c;
	else
	        return ungetc( c, Fileptr );
}

endfile()
{
	if ( Fileptr != (FILE *)NULL && Fileptr != stdin )
	        fclose( Fileptr );
        Filename = (char *) 0 ; Linecount = 0;
}

error( s, severe )
char *s;
int severe;
{
        char *cp, *errat;

        if ( Filename )
                fprintf( stderr, "%s:", Filename );

        if ( Linecount )
                fprintf( stderr, " line %d:", Linecount );

        fprintf( stderr, " %s\n", s );
        if ( severe )
                exit( severe );
}

usage()
{
        error( "Usage: bawk [ -Fc ] [ program | -f progfile ] [ file ... ]\n",
	       USAGE_ERROR );
}

movemem( from, to, count )
char *from, *to;
int count;
{
        while ( count-- > 0 )
                *to++ = *from++;
}

fillmem( array, count, value )
char *array, value;
int count;
{
        while ( count-- > 0 )
                *array++ = value;
}

strncmp( s, t, n )
char *s, *t;
int n;
{
        while ( --n>0 && *s && *t && *s==*t )
        {
                ++s;
                ++t;
        }
        if ( *s || *t )
                return *s - *t;
        return 0;
}

num( c )
char c;
{
        return '0'<=c && c<='9';
}

alpha( c )
char c;
{
        return ('a'<=c && c<='z') || ('A'<=c && c<='Z') || c=='_';
}

alphanum( c )
char c;
{
        return alpha( c ) || num( c );
}
