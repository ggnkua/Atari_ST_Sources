/***************************************************************

        bwbasic.c       Main Program File
                        for Bywater BASIC Interpreter

                        Copyright (c) 1992, Ted A. Campbell

			"I was no programmer, neither was I a
			programmer's son; but I was an herdman
			and a gatherer of sycomore fruit."
			     - Amos 7:14b AV, slightly adapted

                        Bywater Software
                        P. O. Box 4023
                        Duke Station
                        Durham, NC  27706

                        email: tcamp@acpub.duke.edu

        Copyright and Permissions Information:

        All U.S. and international copyrights are claimed by the
        author. The author grants permission to use this code
        and software based on it under the following conditions:
        (a) in general, the code and software based upon it may be
        used by individuals and by non-profit organizations; (b) it
        may also be utilized by governmental agencies in any country,
        with the exception of military agencies; (c) the code and/or
        software based upon it may not be sold for a profit without
        an explicit and specific permission from the author, except
        that a minimal fee may be charged for media on which it is
        copied, and for copying and handling; (d) the code must be
        distributed in the form in which it has been released by the
        author; and (e) the code and software based upon it may not
        be used for illegal activities.

***************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <math.h>
#include <signal.h>
#include <setjmp.h>

#include "bwbasic.h"
#include "bwb_mes.h"

char bwb_progfile[ MAXARGSIZE ];
struct bwb_line bwb_start, bwb_end;
char *bwb_ebuf;				/* error buffer */
static char *read_line;
int bwb_trace = FALSE;
int bwb_number = 0;
struct bwb_line *bwb_l;

struct xtxtsl
   {
   int  position;
   struct bwb_line l;
   };

struct xtxtsl *xtxts;            	/* eXecute TeXT stack */
struct exp_ese *exp_es;    		/* expression stack */
struct ufsel *ufs;              	/* user function stack */
struct fse *fs;                         /* FOR stack */

int xtxtsc = -1;                        /* eXecute TeXT stack counter */

FILE *errfdevice;                       /* output device for error messages */
static jmp_buf mark;
static int program_run = FALSE;		/* has the command-line program ben run? */

/* Prototypes for functions visible only to this file */

#if COMMAND_SHELL
extern int bwb_shell( struct bwb_line *l );
#endif

extern int is_ln( char *buffer );

/***************************************************************

        FUNCTION:       main()

        DESCRIPTION:    As in any C program, main() is the basic
                        function from which the rest of the
                        program is called.

	PRAYER:		Everlasting God,

			Thine eternal Logos is the main() function
			from which all things have their being
			and unto which all things shall return;
			all subroutines are restless until they
			find their rest in thee.

			Grant that users of this software may
			apply it for good purposes; grant
			unto programmers searching its ways that
			they may not be entirely confounded; and
			grant that all our work may be unto thy
			glory. Amen.

***************************************************************/

void
main( int argc, char **argv )
   {
   static FILE *input = NULL;
   static int jump_set = FALSE;
   static char start_buf[] = "\0";
   static char end_buf[] = "\0";
   register int n;
   #if REDIRECT_STDERR
   FILE *newerr;
   #endif

   /* set some initial variables */

   bwb_start.number = 0;
   bwb_start.next = &bwb_end;
   bwb_end.number = MAXLINENO;
   bwb_end.next = &bwb_end;
   bwb_start.buffer = start_buf;
   bwb_end.buffer = end_buf;
   data_line = &bwb_start;
   data_pos = 0;

   /* Memory allocation for various tables */

   /* eXecute TeXT stack */

   if ( ( xtxts = calloc( XTXTSTACKSIZE, sizeof( struct xtxtsl ) ) ) == NULL )
      {
      bwb_error( err_getmem );
      }

   /* expression stack */

   if ( ( exp_es = calloc( ESTACKSIZE, sizeof( struct exp_ese ) ) ) == NULL )
      {
      bwb_error( err_getmem );
      }

   /* user-defined function stack */

   if ( ( ufs = calloc( UFNCSTACKSIZE, sizeof( struct ufsel ) ) ) == NULL )
      {
      bwb_error( err_getmem );
      }

   /* FOR-NEXT stack */

   if ( ( fs = calloc( FORLEVELS, sizeof( struct fse ) ) ) == NULL )
      {
      bwb_error( err_getmem );
      }

   /* GOSUB-RETURN stack */

   if ( ( bwb_gss = calloc( GOSUBLEVELS, sizeof( struct gsse ) ) ) == NULL )
      {
      bwb_error( err_getmem );
      }

   /* character buffers */

   if ( ( bwb_ebuf = calloc( MAXSTRINGSIZE + 1, sizeof(char) ) ) == NULL )
      {
      bwb_error( err_getmem );
      }
   if ( ( read_line = calloc( MAXREADLINESIZE + 1, sizeof(char) ) ) == NULL )
      {
      bwb_error( err_getmem );
      }

   /* Variable and function table initializations */

   var_init();                  /* initialize variable chain */

   fnc_init();                  /* initialize function chain */

   #if TEST_BSTRING
   for ( n = 0; n < ESTACKSIZE; ++n )
      {
      sprintf( exp_es[ n ].sval.name, "<Exp stack bstring %d>", n );
      }
   #endif

   /* assign memory for the device table */

   if ( ( dev_table = calloc( DEF_DEVICES, sizeof( struct dev_element ) ) ) == NULL )
      {
      bwb_error( err_getmem );
      exit(-1);
      }

   /* initialize all devices to DEVMODE_AVAILABLE */

   for ( n = 0; n < DEF_DEVICES; ++n )
      {
      dev_table[ n ].mode = DEVMODE_AVAILABLE;
      dev_table[ n ].reclen = -1;
      dev_table[ n ].cfp = NULL;
      dev_table[ n ].buffer = NULL;
      dev_table[ n ].width = DEF_WIDTH;
      dev_table[ n ].col = 1;
      }

   /* Signon message */

   sprintf( bwb_ebuf, "\r%s %s\n", MES_SIGNON, VERSION );
   xprintf( stdout, bwb_ebuf );
   sprintf( bwb_ebuf, "\r%s\n", MES_COPYRIGHT );
   xprintf( stdout, bwb_ebuf );
   #if PERMANENT_DEBUG
   sprintf( bwb_ebuf, "\r%s\n", "DEBUGGING MODE" );
   xprintf( stdout, bwb_ebuf );
   #else
   sprintf( bwb_ebuf, "\r%s\n", MES_LANGUAGE );
   xprintf( stdout, bwb_ebuf );
   #endif

   /* Redirect stderr if specified */

   #if REDIRECT_STDERR
   newerr = freopen( ERRFILE, "w", stderr );
   if ( newerr == NULL )
      {
      sprintf( bwb_ebuf, "Failed to redirect error messages to file <%s>\n",
         ERRFILE );
      xprintf( stdout, bwb_ebuf );
      errfdevice = stdout;
      }
   else
      {
      sprintf( bwb_ebuf, "NOTE: Error messages are redirected to file <%s>\n",
         ERRFILE );
      xprintf( errfdevice, bwb_ebuf );
      errfdevice = stderr;
      }
   #else
   errfdevice = stdout;
   #endif

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in main(): Ready to save jump MARKER" );
   bwb_debug( bwb_ebuf );
   getchar();
   #endif

   /* set a buffer for jump: program execution returns to this point
      in case of a jump (error, interrupt, or finish program) */

   signal( SIGINT, break_mes );
   setjmp( mark );

   #if THEOLDWAY
   if ( jump_set == FALSE )
      {
      signal( SIGINT, break_mes );
      setjmp( mark );
      jump_set = TRUE;
      }
   #endif

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in main(): Return from jump MARKER, program run <%d>",
      program_run );
   bwb_debug( bwb_ebuf );
   getchar();
   #endif

   /* check to see if there is a program file: but do this only the first
      time around! */

   if (( argc > 1 ) && ( program_run == FALSE ))
      {
      program_run = TRUE;			/* don't do it again */
      if ( ( input = fopen( argv[ 1 ], "r" )) == NULL )
         {
         strcpy( bwb_progfile, argv[ 1 ] );
         strcat( bwb_progfile, ".bas" );
         if ( ( input = fopen( bwb_progfile, "r" )) == NULL )
            {
            bwb_progfile[ 0 ] = 0;
            sprintf( bwb_ebuf, err_openfile, argv[ 1 ] );
            bwb_error( bwb_ebuf );
            }
         }
      if ( input != NULL )
         {
         strcpy( bwb_progfile, argv[ 1 ] );
         #if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in main(): progfile is <%s>.", bwb_progfile );
         bwb_debug( bwb_ebuf );
         #endif
         bwb_fload( input );
         bwb_run( &bwb_start );
         }
      }

   /* Main Program Loop */

   while( TRUE )
      {

      /* take input from keyboard */

      bwb_gets( read_line );

      /* If there is no line number, execute the line as received */

      if ( is_ln( read_line ) == FALSE )
         {
         bwb_xtxtline( read_line );
         }

      /* If there is a line number, add the line to the file in memory */

      else
         {
         bwb_ladd( read_line, TRUE );
         }

      }

   }

/***************************************************************

        FUNCTION:       bwb_fload()

        DESCRIPTION: This function loads a BASIC program
        file into memory.

***************************************************************/

bwb_fload( FILE *file )
   {

   while ( feof( file ) == FALSE )
      {
      read_line[ 0 ] = '\0';
      if ( file == stdin )
         {
         fflush( file );
         }
      fgets( read_line, MAXREADLINESIZE, file );
      if ( file == stdin )
         {
         * prn_getcol( stdout ) = 1;		/* reset column */
         }
      bwb_stripcr( read_line );
      bwb_ladd( read_line, FALSE );
      }

   /* close file stream */

   fclose( file );

   return TRUE;
   }

/***************************************************************

        FUNCTION:       bwb_ladd()

        DESCRIPTION:    This function adds a new line (in the
                        buffer) to the program in memory.

***************************************************************/

bwb_ladd( char *buffer, int replace )
   {
   struct bwb_line *l, *previous;
   register int n, a;
   static char *s_buffer;
   static int init = FALSE;
   static int prev_num = 0;

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_ladd(): ready to get memory for <%s>",
      buffer );
   bwb_debug( bwb_ebuf );
   #endif

   /* get memory for temporary buffer if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      if ( ( s_buffer = calloc( (size_t) MAXSTRINGSIZE + 1, sizeof( char ) )) == NULL )
         {
         bwb_error( err_getmem );
         return FALSE;
         }
      }

   /* get memory for this line */

   if ( ( l = (struct bwb_line *) calloc( (size_t) 1, sizeof( struct bwb_line ) )) == NULL )
      {
      bwb_error( err_getmem );
      return FALSE;
      }

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_ladd(): got memory." );
   bwb_debug( bwb_ebuf );
   #endif

   /* allocate memory and assign buffer to line buffer */

   ln_asbuf( l, buffer );

   /* get the first element and test for a line number */

   adv_element( l->buffer, &( l->position ), s_buffer );

   /* note that line is not yet marked */

   l->marked = FALSE;

   /* set line number in line structure */

   if ( is_numconst( s_buffer ) == TRUE )
      {
      l->number = atoi( s_buffer );
      prev_num = l->number;
      }
   else
      {

      #if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_ladd(): line is not numbered, using prev <%d>",
         prev_num );
      bwb_debug( bwb_ebuf );
      #endif

      l->number = prev_num;
      }

   /* find the place of the current line */

   for ( previous = &bwb_start; previous != &bwb_end; previous = previous->next )
      {

      /* replace a previously existing line */

      if (( previous->number == l->number ) && ( replace == TRUE ))
         {

         #if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in bwb_ladd(): writing to previous number." );
         bwb_debug( bwb_ebuf );
         #endif

         /* allocate memory and assign buffer to line buffer */

         ln_asbuf( previous, buffer );

         /* free the current line */

         free( l );

         /* and return */

         return TRUE;

         }

      /* add after previously existing line: this is to allow unnumbered
         lines that follow in sequence after a previously numbered line */

      else if (( previous->number == l->number ) && ( replace == FALSE ))
         {
         #if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in bwb_ladd(): adding doubled number <%d>",
            l->number );
         bwb_debug( bwb_ebuf);
         #endif
         l->next = previous->next;
         previous->next = l;
         return TRUE;
         }

      /* add a new line */

      else if ( ( previous->number < l->number )
         && ( previous->next->number > l->number ))
         {
         l->next = previous->next;
         previous->next = l;

         #if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in bwb_ladd(): added new line <%d> buffer <%s>",
            l->number, l->buffer );
         bwb_debug( bwb_ebuf );
         #endif

         return TRUE;
         }

      }

   sprintf( bwb_ebuf, ERR_LINENO );
   bwb_error( bwb_ebuf );
   return FALSE;

   }

/***************************************************************

        FUNCTION:       bwb_shell()

        DESCRIPTION:

***************************************************************/

#if COMMAND_SHELL
int
bwb_shell( struct bwb_line *l )
   {
   static char *s_buffer;
   static int init = FALSE;
   static int position;

   /* get memory for temporary buffer if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      if ( ( s_buffer = calloc( MAXSTRINGSIZE + 1, sizeof( char ) )) == NULL )
         {
         bwb_error( err_getmem );
         return FALSE;
         }
      }

   /* get the first element and check for a line number */

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_shell(): line buffer is <%s>.", l->buffer );
   bwb_debug( bwb_ebuf );
   #endif

   position = 0;
   adv_element( l->buffer, &position, s_buffer );
   if ( is_numconst( s_buffer ) != TRUE )                  /* not a line number */
      {

      #if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_shell(): no line number, command <%s>.",
         l->buffer );
      bwb_debug( bwb_ebuf );
      #endif

      if ( system( l->buffer ) == 0 )
         {
         return TRUE;
         }
      else
         {
         return FALSE;
         }
      }

   else                                         /* advance past line number */
      {
      adv_ws( l->buffer, &position );           /* advance past whitespace */

      #if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_shell(): line number, command <%s>.",
         l->buffer );
      bwb_debug( bwb_ebuf );
      #endif

      if ( system( &( l->buffer[ position ] ) ) == 0 )
         {
         return TRUE;
         }
      else
         {
         return FALSE;
         }
      }
   }
#endif

/***************************************************************

        FUNCTION:       bwb_xtxtline()

        DESCRIPTION:    This function executes a text line, i.e.,
                        places it in memory and then calls
                        bwb_xline() to execute it.

***************************************************************/

struct bwb_line *
bwb_xtxtline( char *buffer )
   {
   struct bwb_line *c;
   register int n, a;
   char *p;
   int loop;

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_xtxtline(): received <%s>", buffer );
   bwb_debug( bwb_ebuf );
   #endif

   /* increment xtxt stack counter */

   if ( xtxtsc >= XTXTSTACKSIZE )
      {
      sprintf( bwb_ebuf, "Exceeded maximum xtxt stack <%d>",
         xtxtsc );
      return &bwb_end;
      }

   ++xtxtsc;

   /* advance past whitespace */

   p = buffer;
   loop = TRUE;
   while( loop == TRUE )
      {

      switch( *p )
         {
         case '\0':                     /* end of string */

            #if INTENSIVE_DEBUG
            sprintf( bwb_ebuf, "Null command line received." );
            bwb_debug( bwb_ebuf );
            #endif
            --xtxtsc;
            return &bwb_end;
         case ' ':                      /* whitespace */
         case '\t':
            ++p;
            break;
         default:
            loop = FALSE;
            break;
         }

      }

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_xtxtline(): ready to get memory" );
   bwb_debug( bwb_ebuf );
   #endif

   if ( xtxts[ xtxtsc ].l.buffer != NULL )
      {
      #if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_xtxtline(): freeing buffer memory" );
      bwb_debug( bwb_ebuf );
      #endif
      free( xtxts[ xtxtsc ].l.buffer );
      }

   /* copy the whole line to the line structure buffer */

   ln_asbuf( &( xtxts[ xtxtsc ].l ), buffer );

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_xtxtline(): copied to line buffer <%s>.",
      xtxts[ xtxtsc ].l.buffer );
   bwb_debug( bwb_ebuf );
   #endif

   /* set line number in line structure */

   xtxts[ xtxtsc ].l.number = 0;
   xtxts[ xtxtsc ].l.marked = FALSE;

   /* execute the line as BASIC command line */

   xtxts[ xtxtsc ].l.next = &bwb_end;
   c = &( xtxts[ xtxtsc ].l );
   c->position = 0;

   do
      {
/*      xtxts[ xtxtsc ].position = 0; */
      c = bwb_xline( c );
      }

   while( c != &bwb_end );

   /* decrement xtxt stack counter */

   --xtxtsc;

   return c;

   }

/***************************************************************

        FUNCTION:       bwb_xline()

        DESCRIPTION:    This function executes a single line of
                        the program in memory.

***************************************************************/

struct bwb_line *
bwb_xline( struct bwb_line *l )
   {
   int loop, extended_line;
   struct bwb_line *r;

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_xline(): buffer <%s>",
      &( l->buffer[ l->position ] ) );
   bwb_debug( bwb_ebuf );
   #endif

   /* Print line number if trace is on */

   if ( bwb_trace == TRUE )
      {
      if ( l->number > 0 )
         {
         sprintf( bwb_ebuf, "[ %d ]", l->number );
         xprintf( errfdevice, bwb_ebuf );
         }
      }

   /* Set current line for error/break handling */

   bwb_number = l->number;
   bwb_l = l;
   extended_line = FALSE;

   /* advance past whitespace and segment delimiter */

   if ( l->buffer[ l->position ] == ':' )
      {
      ++( l->position );
      }
   adv_ws( l->buffer, &( l->position ) );
   if ( l->buffer[ l->position ] == ':' )
      {
      ++( l->position );
      adv_ws( l->buffer, &( l->position ) );
      }

   /* Loop through line segments delimited by ':' */

   loop = TRUE;
   r = l->next;

   while ( loop == TRUE )
      {

      /* set loop to false: it will be set to TRUE later if needed */

      loop = FALSE;

      /* set positions in buffer */

      #if MARK_LINES
      if ( ( l->marked != TRUE ) || ( l->position > l->startpos ))
	 {
	 line_start( l->buffer, &( l->position ), &( l->lnpos ), &( l->lnum ),
	    &( l->cmdpos ), &( l->cmdnum ), &( l->startpos ) );
	 l->marked = TRUE;
	 }
      else
         {
         #if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in bwb_xline(): line <%d> is already marked",
             l->number );
         bwb_debug( bwb_ebuf );
         #endif
         }
      #else
      line_start( l->buffer, &( l->position ), &( l->lnpos ), &( l->lnum ),
         &( l->cmdpos ), &( l->cmdnum ), &( l->startpos ) );
      #endif

      if ( l->position < l->startpos )
         {
         l->position = l->startpos;
         }

      /* if there is a BASIC command in the line, execute it here */

      if ( l->cmdnum > -1 )
         {

         #if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in bwb_xline(): executing <%s>", l->buffer );
         bwb_debug( bwb_ebuf );
         #endif

         /* execute the command vector */

         r = ( bwb_cmdtable[ l->cmdnum ].vector ) ( l );

	 #if INTENSIVE_DEBUG
	 if ( l->cmdnum == getcmdnum( "GOSUB" ) )
	    {
	    sprintf( bwb_ebuf, "in bwb_xline(): returning from GOSUB, position <%d>",
	       l->position );
	    bwb_debug( bwb_ebuf );
            }
	 #endif

         /* If the command was RETURN OR GOTO, then we must break out of
            the loop at this point; the rest of the line is irrelevant */

         if ( l->cmdnum == getcmdnum( "RETURN" ) )
            {
	    #if INTENSIVE_DEBUG
	    sprintf( bwb_ebuf, "in bwb_xline(): returning from RETURN command, ret line <%d>",
	       r->number );
	    bwb_debug( bwb_ebuf );
	    #endif
	    r->cmdnum = getcmdnum( "RETURN" );
	    r->marked = FALSE;
	    return r;			/* break out; return now */
	    }

         else if ( l->cmdnum == getcmdnum( "GOTO" ) )
            {
	    #if INTENSIVE_DEBUG
            sprintf( bwb_ebuf, "in bwb_xline(): returning from GOTO command, ret line <%d>",
               r->number );
            bwb_debug( bwb_ebuf );
            #endif
            return r;
            }
         }

      else if ( l->buffer[ l->position ] == ':' )
         {
         l->marked = FALSE;
         }				/* do nothing */

      /* No BASIC command; try to execute it as a shell command */

      #if COMMAND_SHELL
      else
	 {

	 #if INTENSIVE_DEBUG
	 sprintf( bwb_ebuf, "Breaking out to shell, line num <%d> buf <%s> cmd <%d> pos <%d>",
	    l->number, &( l->buffer[ l->position ] ), l->cmdnum, l->position );
	 bwb_debug( bwb_ebuf );
	 getchar();
	 #endif

	 bwb_shell( l );
	 }

      #else				/* COMMAND_SHELL == FALSE */

      else
        {
        bwb_error( err_uc );
        }

      #endif

      /* detect if the current character is ':', in which case loop
         back through to execute it */

      #if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_xline(): remaining line is <%s>",
         &( l->buffer[ l->position ] ) );
      bwb_debug( bwb_ebuf );
      #endif

      adv_ws( l->buffer, &( l->position ) );
      if ( l->buffer[ l->position ] == ':' )
         {

	 #if INTENSIVE_DEBUG
	 sprintf( bwb_ebuf, "in bwb_xline(): line <%d> found \':\'",
	    l->number );
         bwb_debug( bwb_ebuf );
         #endif

	 ++l->position;
	 l->marked = FALSE;
	 extended_line = TRUE;
         loop = TRUE;
         }

      else if ( extended_line == TRUE )
	 {
	 l->marked = FALSE;
	 }

      }                                 /* end of loop through line */

   /* return the value in r */

   #if INTENSIVE_DEBUG
   if ( r->cmdnum == getcmdnum( "RETURN" ) )
      {
      bwb_debug( "in bwb_xline(): returning RETURN cmdnum" );
      }
   #endif

   return r;

   }

/***************************************************************

        FUNCTION:       ln_asbuf()

        DESCRIPTION:    This function allocates memory and copies
			a null-terminated string to a line buffer.

***************************************************************/

int
ln_asbuf( struct bwb_line *l, char *s )
   {

   #ifdef DONTDOIT
   if ( l->buffer != NULL )
      {
      free( l->buffer );
      }
   #endif

   if ( ( l->buffer = calloc( strlen( s ) + 2, sizeof( char ) ) )
      == NULL )
      {
      bwb_error( err_getmem );
      return FALSE;
      }

   /* copy the whole line to the line structure buffer */

   strcpy( l->buffer, s );

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in ln_asbuf(): allocated buffer <%s>", l->buffer );
   bwb_debug( bwb_ebuf );
   #endif

   /* strip CR from the buffer */

   bwb_stripcr( l->buffer );

   return TRUE;

   }

/***************************************************************

        FUNCTION:       bwb_gets()

        DESCRIPTION:    This function reads a single line from
                        the specified buffer.

***************************************************************/

bwb_gets( char *buffer )
   {
   bwb_number = 0;
   sprintf( bwb_ebuf, "\r%s\n", PROMPT );
   xprintf( stdout, bwb_ebuf );
   fflush( stdin );
   fgets( buffer, MAXREADLINESIZE, stdin );
   * prn_getcol( stdout ) = 1;			/* reset column */
   return TRUE;
   }

/***************************************************************

        FUNCTION:       break_mes()

        DESCRIPTION:    This function is called (a) by a SIGINT
                        signal or (b) by error-handling routines.

***************************************************************/

void
break_mes( int x )
   {
   static char *tmp_buffer;
   static int init = FALSE;

   /* get memory for temporary buffer if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      if ( ( tmp_buffer = calloc( MAXSTRINGSIZE + 1, sizeof( char ) )) == NULL )
         {
         bwb_error( err_getmem );
         }
      }

   exp_esc = 0;

   sprintf( tmp_buffer, "\r%s %d\n", MES_BREAK, bwb_number );
   xprintf( errfdevice, tmp_buffer );

   break_handler();

   }

void
break_handler( void )
   {

   /* zero all stack counters */

   exp_esc = 0;
   bwb_gssc = 0;
   ufsc = 0;
   ws_counter = 0;
   fs_counter = 0;
   xtxtsc = 0;

   /* jump back to mark */

   longjmp( mark, -1 );

   }


int
is_ln( char *buffer )
   {
   static int position;

   position = 0;
   adv_ws( buffer, &position );
   switch( buffer[ position ] )
      {
      case '0':
      case '1':
      case '2':
      case '3':
      case '4':
      case '5':
      case '6':
      case '7':
      case '8':
      case '9':
         return TRUE;
      default:
         return FALSE;
      }
   }

