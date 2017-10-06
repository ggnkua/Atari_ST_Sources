/***************************************************************

        bwbasic.c       Main Program File
                        for Bywater BASIC Interpreter

                        Copyright (c) 1993, Ted A. Campbell
                        Bywater Software

			"I was no programmer, neither was I a
			programmer's son; but I was an herdman
			and a gatherer of sycomore fruit."
			     - Amos 7:14b AV, slightly adapted

                        email: tcamp@delphi.com

        Copyright and Permissions Information:

        All U.S. and international rights are claimed by the author,
        Ted A. Campbell.

	This software is released under the terms of the GNU General
	Public License (GPL), which is distributed with this software
	in the file "COPYING".  The GPL specifies the terms under
	which users may copy and use the software in this distribution.

	A separate license is available for commercial distribution,
	for information on which you should contact the author.

***************************************************************/

/*---------------------------------------------------------------*/
/* NOTE: Modifications marked "JBV" were made by Jon B. Volkoff, */
/* 11/1995 (eidetics@cerf.net).                                  */
/*---------------------------------------------------------------*/

#include <stdio.h>
#include <ctype.h>
#include <math.h>

#include "bwbasic.h"
#include "bwb_mes.h"

#if HAVE_SIGNAL
#include <signal.h>
#endif

#if HAVE_LONGJUMP
#include <setjmp.h>
#endif

char *bwb_ebuf;				/* error buffer */
static char *read_line;
int bwb_trace = FALSE;
FILE *errfdevice = stderr;              /* output device for error messages */

#if HAVE_LONGJUMP
jmp_buf mark;
#endif

static int program_run = 0;		/* has the command-line program been run? */
int bwb_curtask = 0;			/* current task */

struct bwb_variable *ed;                /* BWB.EDITOR$ variable */
struct bwb_variable *fi;                /* BWB.FILES$ variable */
struct bwb_variable *pr;                /* BWB.PROMPT$ variable */
struct bwb_variable *im;                /* BWB.IMPLEMENTATION$ variable */
struct bwb_variable *co;                /* BWB.COLORS variable */

#if PARACT
struct bwb_task *bwb_tasks[ TASKS ];	/* table of task pointers */
#else
char progfile[ MAXARGSIZE ];		/* program file */
int rescan = TRUE;                      /* program needs to be rescanned */
int number = 0;				/* current line number */
struct bwb_line *bwb_l;			/* current line pointer */
struct bwb_line bwb_start;		/* starting line marker */
struct bwb_line bwb_end;		/* ending line marker */
struct bwb_line *data_line;     	/* current line to read data */
int data_pos = 0;                       /* position in data_line */
struct bwb_variable var_start;		/* variable list start marker */
struct bwb_variable var_end;		/* variable list end marker */
struct bwb_function fnc_start;		/* function list start marker */
struct bwb_function fnc_end;		/* function list end marker */
struct fslte fslt_start;		/* function-sub-label lookup table start marker */
struct fslte fslt_end;			/* function-sub-label lookup table end marker */
int exsc = -1;				/* EXEC stack counter */
int expsc = 0;				/* expression stack counter */
int xtxtsc = 0;				/* eXecute TeXT stack counter */
struct exse *excs;			/* EXEC stack */
struct exp_ese *exps;			/* Expression stack */
struct xtxtsl *xtxts;                   /* Execute Text stack */
#endif

/* Prototypes for functions visible only to this file */

#if ANSI_C
extern int is_ln( char *buffer );
#else
extern int is_ln();
#endif
  
/***************************************************************

        FUNCTION:       bwb_init()

        DESCRIPTION:    This function initializes bwBASIC.

***************************************************************/

void
#if ANSI_C
bwb_init( int argc, char **argv )
#else
bwb_init( argc, argv )
   int argc;
   char **argv;
#endif
   {
   static FILE *input = NULL;
   register int n;
#if PROFILE
   struct bwb_variable *v;
#endif
#if REDIRECT_STDERR
   FILE *newerr;
#endif
#if PROFILE
   FILE *profile;
#endif
#if PARACT
#else
   static char start_buf[] = "\0";
   static char end_buf[] = "\0";
#endif

#if INTENSIVE_DEBUG
   prn_xprintf( stderr, "Memory Allocation Statistics:\n" );
   prn_xprintf( stderr, "----------------------------\n" );
#if PARACT
   sprintf( bwb_ebuf, "task structure:   %ld bytes\n",
      (long) sizeof( struct bwb_task ) );
   prn_xprintf( stderr, bwb_ebuf );
   getchar();
#endif
#endif

   /* set all task pointers to NULL */

#if PARACT

   for ( n = 0; n < TASKS; ++n )
      {
      bwb_tasks[ n ] = NULL;
      }

#else

   /* Memory allocation */
   /* eXecute TeXT stack */

   /* Revised to CALLOC pass-thru call by JBV */
   if ( ( xtxts = CALLOC( XTXTSTACKSIZE, sizeof( struct xtxtsl ), "bwb_init") ) == NULL )
      {
#if PROG_ERRORS
      bwb_error( "in bwb_init(): failed to find memory for xtxts" );
#else
      bwb_error( err_getmem );
#endif
      }

   /* expression stack */

   /* Revised to CALLOC pass-thru call by JBV */
   if ( ( exps = CALLOC( ESTACKSIZE, sizeof( struct exp_ese ), "bwb_init") ) == NULL )
      {
#if PROG_ERRORS
      bwb_error( "in bwb_init(): failed to find memory for exps" );
#else
      bwb_error( err_getmem );
#endif
      }

   /* EXEC stack */

   /* Revised to CALLOC pass-thru call by JBV */
   if ( ( excs = CALLOC( EXECLEVELS, sizeof( struct exse ), "bwb_init") ) == NULL )
      {
#if PROG_ERRORS
      bwb_error( "in bwb_init(): failed to find memory for excs" );
#else
      bwb_error( err_getmem );
#endif
      }

   /* initialize tables of variables, functions */

   bwb_start.number = 0;
   bwb_start.next = &bwb_end;
   bwb_end.number = MAXLINENO + 1;
   bwb_end.next = &bwb_end;
   bwb_start.buffer = start_buf;
   bwb_end.buffer = end_buf;
   data_line = &bwb_start;
   data_pos = 0;
   exsc = -1;
   expsc = 0;
   xtxtsc = 0;
   bwb_start.position = 0;
   bwb_l = &bwb_start; 

   var_init( 0 );
   fnc_init( 0 );
   fslt_init( 0 );

#endif

   /* character buffers */

   /* Revised to CALLOC pass-thru call by JBV */
   if ( ( bwb_ebuf = CALLOC( MAXSTRINGSIZE + 1, sizeof(char), "bwb_init") ) == NULL )
      {
#if PROG_ERRORS
      bwb_error( "in bwb_init(): failed to find memory for bwb_ebuf" );
#else
      bwb_error( err_getmem );
#endif
      }
   /* Revised to CALLOC pass-thru call by JBV */
   if ( ( read_line = CALLOC( MAXREADLINESIZE + 1, sizeof(char), "bwb_init") ) == NULL )
      {
#if PROG_ERRORS
      bwb_error( "in bwb_init(): failed to find memory for read_line" );
#else
      bwb_error( err_getmem );
#endif
      }

#if PARACT

   /* request task 0 as current (base) task */

   bwb_curtask = bwb_newtask( 0 );

   if ( bwb_curtask == -1 )
      {
      return;				/* error message has already been called*/
      }

#endif

#if TEST_BSTRING
   for ( n = 0; n < ESTACKSIZE; ++n )
      {
      sprintf( CURTASK exps[ n ].sval.name, "<Exp stack bstring %d>", n );
      }
#endif

   /* assign memory for the device table */

#if COMMON_CMDS
   /* Revised to CALLOC pass-thru call by JBV */
   if ( ( dev_table = CALLOC( DEF_DEVICES, sizeof( struct dev_element ), "bwb_init") ) == NULL )
      {
#if PROG_ERRORS
      bwb_error( "in bwb_init(): failed to find memory for dev_table" );
#else
      bwb_error( err_getmem );
#endif
      bwx_terminate();
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
#endif			/* COMMON_CMDS */

   /* initialize preset variables */

   ed = var_find( DEFVNAME_EDITOR );
   ed->preset = TRUE;
   ed->common = TRUE;
   str_ctob( var_findsval( ed, ed->array_pos ), DEF_EDITOR );

   fi = var_find( DEFVNAME_FILES );
   fi->preset = TRUE;
   fi->common = TRUE;
   str_ctob( var_findsval( fi, fi->array_pos ), DEF_FILES );

   pr = var_find( DEFVNAME_PROMPT );
   pr->preset = TRUE;
   pr->common = TRUE;
   str_ctob( var_findsval( pr, pr->array_pos ), PROMPT );

   im = var_find( DEFVNAME_IMPL );
   im->preset = TRUE;
   im->common = TRUE;
   str_ctob( var_findsval( im, im->array_pos ), IMP_IDSTRING );

   co = var_find( DEFVNAME_COLORS );
   co->preset = TRUE;
   co->common = TRUE;
   * var_findnval( co, co->array_pos ) = (bnumber) DEF_COLORS;

   /* Signon message */

   bwx_signon();

   /* Redirect stderr if specified */

#if REDIRECT_STDERR
   newerr = freopen( ERRFILE, "w", stderr );
   if ( newerr == NULL )
      {
      sprintf( bwb_ebuf, "Failed to redirect error messages to file <%s>\n",
         ERRFILE );
      errfdevice = stdout;
      prn_xprintf( errfdevice, bwb_ebuf );
      }
   else
      {
      sprintf( bwb_ebuf, "NOTE: Error messages are redirected to file <%s>\n",
         ERRFILE );
      prn_xprintf( errfdevice, bwb_ebuf );
      errfdevice = stderr;
      }
#else
   errfdevice = stdout;
#endif

   /* if there is a profile.bas, execute it */

#if PROFILE
   if ( ( profile = fopen( PROFILENAME, "r" )) != NULL )
      {
      bwb_fload( profile );	/* load profile */
      bwb_run( &CURTASK bwb_start );	/* run profile */

      /* profile must be run immediately, not by scheduler */

      while ( CURTASK exsc > -1 )
           {
           bwb_execline();
           }

      /* mark all profiled variables as preset */

      for ( v = CURTASK var_start.next; v != &CURTASK var_end; v = v->next )
         {

#if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in bwb_init(): marked variable <%s> preset TRUE",
            v->name );
         bwb_debug( bwb_ebuf );
#endif

         v->preset = TRUE;
         }

      bwb_new( &CURTASK bwb_start ); 	/* remove profile from memory */
      }
#endif

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in main(): Ready to save jump MARKER" );
   bwb_debug( bwb_ebuf );
#endif

   /* set a buffer for jump: program execution returns to this point
      in case of a jump (error, interrupt, or finish program) */

#if INTERACTIVE

#if HAVE_SIGNAL
   signal( SIGINT, break_mes );
#endif

#if HAVE_LONGJUMP
   setjmp( mark );
#endif

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_init(): Return from jump MARKER, program run <%d>",
      program_run + 1 );
   bwb_debug( bwb_ebuf );
   getchar();
#endif

   /* if INTERACTIVE is FALSE, then we must have a program file */

#else

   if ( argc < 2 )
      {
      bwb_error( err_noprogfile );
      }

#endif				/* INTERACTIVE */

   /* check to see if there is a program file: but do this only the first
      time around! */

   ++program_run;
   if (( argc > 1 ) && ( program_run == 1 ))
      {
      strcpy( CURTASK progfile, argv[ 1 ] ); /* JBV */
      if ( ( input = fopen( CURTASK progfile, "r" )) == NULL ) /* JBV */
         {
         strcat( CURTASK progfile, ".bas" );
         if ( ( input = fopen( CURTASK progfile, "r" )) == NULL )
            {
            CURTASK progfile[ 0 ] = 0;
            sprintf( bwb_ebuf, err_openfile, argv[ 1 ] );
            bwb_error( bwb_ebuf );
            }
         }
      if ( input != NULL )
         {
         /* strcpy( CURTASK progfile, argv[ 1 ] ); */  /* Removed by JBV */
#if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in main(): progfile is <%s>.", CURTASK progfile );
         bwb_debug( bwb_ebuf );
#endif

         bwb_fload( input );
         bwb_run( &CURTASK bwb_start );
         }
      }

   }

/***************************************************************

        FUNCTION:       bwb_interact()

        DESCRIPTION: 	This function gets a line from the user
			and processes it.

***************************************************************/

#if INTERACTIVE
int
#if ANSI_C
bwb_interact( void )
#else
bwb_interact()
#endif
   {
   char tbuf[ MAXSTRINGSIZE + 1 ]; /* JBV */

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_interact(): ready to read from keyboard" );
   bwb_debug( bwb_ebuf );
#endif

   /* take input from keyboard */

   bwb_gets( read_line );
   bwb_stripcr( read_line ); /* JBV */

   /* If there is no line number, execute the line as received */

   if ( is_ln( read_line ) == FALSE )
      {
      bwb_xtxtline( read_line );
      }

   /*-----------------------------------------------------------------*/
   /* Another possibility: if read_line is a numeric constant, delete */
   /* the indicated line number (JBV)                                 */
   /*-----------------------------------------------------------------*/
   else if ( is_numconst( read_line ) == TRUE )
   {
       strcpy(tbuf, read_line);
       sprintf(read_line, "delete %s\0", tbuf);
       bwb_xtxtline( read_line );
   }

   /* If there is a line number, add the line to the file in memory */

   else
      {
      bwb_ladd( read_line, TRUE );
#if INTENSIVE_DEBUG
      bwb_debug( "Return from bwb_ladd()" );
#endif
      }

   return TRUE;

   }

#endif				/* INTERACTIVE == TRUE */

/***************************************************************

        FUNCTION:       bwb_fload()

        DESCRIPTION: 	This function loads a BASIC program
			file into memory given a FILE pointer.

***************************************************************/

int
#if ANSI_C
bwb_fload( FILE *file )
#else
bwb_fload( file )
   FILE *file;
#endif
   {

   while ( feof( file ) == FALSE )
      {
      read_line[ 0 ] = '\0';
      fgets( read_line, MAXREADLINESIZE, file );
      if ( file == stdin )
         {
         * prn_getcol( stdout ) = 1;		/* reset column */
         }
      bwb_stripcr( read_line );

      /* be sure that this is not EOF with a NULL line */

      if (( feof( file ) == FALSE ) || ( strlen( read_line ) > 0 ))
	 {
	 bwb_ladd( read_line, FALSE );
	 }
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

int
#if ANSI_C
bwb_ladd( char *buffer, int replace )
#else
bwb_ladd( buffer, replace )
   char *buffer;
   int replace;
#endif
   {
   struct bwb_line *l, *previous, *p;
   static char *s_buffer;
   static int init = FALSE;
   static int prev_num = 0;
   char *newbuffer;

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_ladd(): add line <%s>",
      buffer );
   bwb_debug( bwb_ebuf );
#endif

   /* get memory for temporary buffer if necessary */

   if ( init == FALSE )
      {
      init = TRUE;

      /* Revised to CALLOC pass-thru call by JBV */
      if ( ( s_buffer = CALLOC( (size_t) MAXSTRINGSIZE + 1, sizeof( char ), "bwb_ladd" )) == NULL )
	 {
#if PROG_ERRORS
	 bwb_error( "in bwb_ladd(): failed to find memory for s_buffer" );
#else
	 bwb_error( err_getmem );
#endif
	 return FALSE;
         }
      }

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_ladd(): s_buffer initialized " );
   bwb_debug( bwb_ebuf );
#endif

   /* get memory for this line */

   /* Revised to CALLOC pass-thru call by JBV */
   if ( ( l = (struct bwb_line *) CALLOC( (size_t) 1, sizeof( struct bwb_line ), "bwb_ladd")) == NULL )
      {
#if PROG_ERRORS
      bwb_error( "in bwb_ladd(): failed to find memory for new line" );
#else
      bwb_error( err_getmem );
#endif
      return FALSE;
      }

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_ladd(): got memory." );
   bwb_debug( bwb_ebuf );
#endif

   /* note that line is not yet marked and the program must be rescanned */

   l->marked = FALSE;
   CURTASK rescan = TRUE;		/* program needs to be scanned again */
   l->xnum = FALSE;

   /* get the first element and test for a line number */

   adv_element( buffer, &( l->position ), s_buffer );

   /* set line number in line structure */

   if ( is_numconst( s_buffer ) == TRUE )
      {

      l->number = atoi( s_buffer );

#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_ladd(): line is numbered, number is <%d>",
	 l->number );
      bwb_debug( bwb_ebuf );
#endif

      prev_num = l->number;
      l->xnum = TRUE;
      ++( l->position );
      newbuffer = &( buffer[ l->position ] );

      /* allocate memory and assign buffer to line buffer */

      ln_asbuf( l, newbuffer );

      }

   /* There is not a line number */

   else
      {

#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_ladd(): line is not numbered, using prev <%d>",
         prev_num );
      bwb_debug( bwb_ebuf );
#endif

      newbuffer = buffer;

      /* allocate memory and assign buffer to line buffer */

      ln_asbuf( l, newbuffer );

      l->xnum = FALSE;
      l->number = prev_num;
      }

   /* find the place of the current line */

   for ( previous = &CURTASK bwb_start; previous != &CURTASK bwb_end; previous = previous->next )
      {

      /* replace a previously existing line */

      if ( ( l->xnum == (char) TRUE ) /* Better recast this one (JBV) */
         && ( previous->number == l->number )
	 && ( replace == TRUE )
	 )
         {

#if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in bwb_ladd(): writing to previous number <%d>",
            l->number );
         bwb_debug( bwb_ebuf );
#endif

         /* allocate memory and assign buffer to line buffer */

	 ln_asbuf( previous, newbuffer );

         /* free the current line */

         /* Revised to FREE pass-thru calls by JBV */
         /* if (l->buffer != NULL) FREE( l->buffer, "bwb_ladd" ); */
         /* FREE( l, "bwb_ladd" ); */
         bwb_freeline( l ); /* JBV */

         /* and return */

         return TRUE;

         }

      /* add after previously existing line: this is to allow unnumbered
         lines that follow in sequence after a previously numbered line */

      else if (( previous->number == l->number )
	 && ( replace == FALSE )
	 )
         {
#if INTENSIVE_DEBUG
	 sprintf( bwb_ebuf, "in bwb_ladd(): adding doubled number <%d>",
	    l->number );
	 bwb_debug( bwb_ebuf);
#endif

         /* if there are multiple instances of this particular line number,
            then it is incumbent upon us to find the very last one */

         for ( p = previous; p->number == l->number; p = p->next )
            {
#if INTENSIVE_DEBUG
	    bwb_debug( "in bwb_ladd(): advancing..." );
#endif
            previous = p;
            }

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

   /* attempt to link line number has failed; free memory */

   /* Revised to FREE pass-thru calls by JBV */
   /* if (l->buffer != NULL) FREE( l->buffer, "bwb_ladd" ); */
   /* FREE( l, "bwb_ladd" ); */
   bwb_freeline( l ); /* JBV */

   sprintf( bwb_ebuf, ERR_LINENO );
   bwb_error( bwb_ebuf );

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_ladd(): attempt to add line has failed" );
   bwb_debug( bwb_ebuf );
#endif

   return FALSE;

   }

/***************************************************************

        FUNCTION:       bwb_xtxtline()

        DESCRIPTION:    This function executes a text line, i.e.,
                        places it in memory and then relinquishes
                        control.

***************************************************************/

struct bwb_line *
#if ANSI_C
bwb_xtxtline( char *buffer )
#else
bwb_xtxtline( buffer )
   char *buffer;
#endif
   {
   struct bwb_line *c;
   char *p;
   int loop;

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_xtxtline(): received <%s>", buffer );
   bwb_debug( bwb_ebuf );
#endif

   /* increment xtxt stack counter */

   if ( CURTASK xtxtsc >= XTXTSTACKSIZE )
      {
      sprintf( bwb_ebuf, "Exceeded maximum xtxt stack <%d>",
         CURTASK xtxtsc );
      return &CURTASK bwb_end;
      }

   ++CURTASK xtxtsc;

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
            --CURTASK xtxtsc;
            return &CURTASK bwb_end;
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

/* Removed by JBV (no longer needed, done by ln_asbuf) */
/*   if ( CURTASK xtxts[ CURTASK xtxtsc ].l.buffer != NULL )
      { */
/* #if INTENSIVE_DEBUG */
/*      sprintf( bwb_ebuf, "in bwb_xtxtline(): freeing buffer memory" );
      bwb_debug( bwb_ebuf ); */
/* #endif */
        /* Revised to FREE pass-thru call by JBV */
/*      FREE( CURTASK xtxts[ CURTASK xtxtsc ].l.buffer, "bwb_xtxtline" );
      } */

   /* copy the whole line to the line structure buffer */

   ln_asbuf( &( CURTASK xtxts[ CURTASK xtxtsc ].l ), buffer );

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_xtxtline(): copied to line buffer <%s>.",
      CURTASK xtxts[ CURTASK xtxtsc ].l.buffer );
   bwb_debug( bwb_ebuf );
#endif

   /* set line number in line structure */

   CURTASK xtxts[ CURTASK xtxtsc ].l.number = 0;
   CURTASK xtxts[ CURTASK xtxtsc ].l.marked = FALSE;

   /* execute the line as BASIC command line */

   CURTASK xtxts[ CURTASK xtxtsc ].l.next = &CURTASK bwb_end;
   c = &( CURTASK xtxts[ CURTASK xtxtsc ].l );
   c->position = 0;

#if THEOLDWAY
   do
      {
      c = bwb_xline( c );
      }

   while( c != &CURTASK bwb_end );
#endif

   bwb_incexec();		/* increment EXEC stack */
   bwb_setexec( c, 0, EXEC_NORM );		/* and set current line in it */

   /* decrement xtxt stack counter ??? */

   --CURTASK xtxtsc;

   return c;

   }

/***************************************************************

        FUNCTION:       bwb_incexec()

        DESCRIPTION:    This function increments the EXEC
			stack counter.

***************************************************************/

#if ANSI_C
extern void
bwb_incexec( void )
   {
#else
void
bwb_incexec()
   {
#endif
   ++CURTASK exsc;

   if ( CURTASK exsc >= EXECLEVELS )
      {
      --CURTASK exsc;
#if PROG_ERRORS
      sprintf( bwb_ebuf, "in bwb_incexec(): incremented EXEC stack past max <%d>",
         EXECLEVELS );
      bwb_error( bwb_ebuf );
#else
      bwb_error( err_overflow );
#endif
      }

   CURTASK excs[ CURTASK exsc ].while_line = NULL;
   CURTASK excs[ CURTASK exsc ].wend_line  = NULL;
   CURTASK excs[ CURTASK exsc ].n_cvs = 0;
   CURTASK excs[ CURTASK exsc ].local_variable = NULL;

   }

/***************************************************************

        FUNCTION:       bwb_decexec()

        DESCRIPTION:    This function decrements the EXEC
			stack counter.

***************************************************************/

#if ANSI_C
extern void
bwb_decexec( void )
   {
#else
void
bwb_decexec()
   {
#endif

   /* decrement the exec stack counter */

   --CURTASK exsc;

   if ( CURTASK exsc < -1 )
      {
      CURTASK exsc = -1;
#if PROG_ERRORS
      sprintf( bwb_ebuf, "in bwb_decexec(): decremented EXEC stack past min <-1>" );
      bwb_error( bwb_ebuf );
#else
      bwb_error( err_overflow );
#endif
      }

   /* check for EXEC_ON and decrement recursively */

   if ( CURTASK excs[ CURTASK exsc ].code == EXEC_ON )
      {

      /* Revised to FREE pass-thru calls by JBV */
      /* FREE( CURTASK excs[ CURTASK exsc ].while_line->buffer, "bwb_decexec" ); */
      /* FREE( CURTASK excs[ CURTASK exsc ].while_line, "bwb_decexec" ); */
      bwb_freeline( CURTASK excs[ CURTASK exsc ].while_line ); /* JBV */

      bwb_decexec();
      }

   }

/***************************************************************

        FUNCTION:       bwb_setexec()

        DESCRIPTION:    This function sets the line and position
			for the next call to bwb_execline();

***************************************************************/

#if ANSI_C
extern int
bwb_setexec( struct bwb_line *l, int position, int code )
   {
#else
int
bwb_setexec( l, position, code )
   struct bwb_line *l;
   int position;
   int code;
   {
#endif

   CURTASK excs[ CURTASK exsc ].line = l;
   CURTASK excs[ CURTASK exsc ].position = position;
   CURTASK excs[ CURTASK exsc ].code = code;

   return TRUE;

   }

/***************************************************************

        FUNCTION:       bwb_mainloop()

        DESCRIPTION:    This C function performs one iteration
                        of the interpreter. In a non-preemptive
                        scheduler, this function should be called
                        by the scheduler, not by bwBASIC code.

***************************************************************/

void
#if ANSI_C
bwb_mainloop( void )
#else
bwb_mainloop()
#endif
   {
   if ( CURTASK exsc > -1 )
      {
      bwb_execline();			/* execute one line of program */
      }
#if INTERACTIVE
   else
      {
      bwb_interact();			/* get user interaction */
      }
#endif
   }

/***************************************************************

        FUNCTION:       bwb_execline()

        DESCRIPTION:    This function executes a single line of
                        a program in memory. This function is
			called by bwb_mainloop().

***************************************************************/

void
#if ANSI_C
bwb_execline( void )
#else
bwb_execline()
#endif
   {
   struct bwb_line *r, *l;

   l = CURTASK excs[ CURTASK exsc ].line;

   /* if the line is &CURTASK bwb_end, then break out of EXEC loops */

   if ( l == &CURTASK bwb_end )
      {
      CURTASK exsc = -1;
      return;
      }

   /* Check for wacko line numbers  */

#if INTENSIVE_DEBUG
   if ( l->number < -1 )
      {
#if PROG_ERRORS
      sprintf( bwb_ebuf, "in bwb_execline(): received line number <%d> < -1",
         l->number );
      bwb_error( bwb_ebuf );
#else
      bwb_error( err_syntax );
#endif
      return;
      }

   if ( l->number > MAXLINENO )
      {
#if PROG_ERRORS
      sprintf( bwb_ebuf, "in bwb_execline(): received line number <%d> > MAX <%d>",
         l->number, MAXLINENO );
      bwb_error( bwb_ebuf );
#else
      bwb_error( err_syntax );
#endif
      return;
      }
#endif

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_execline(): buffer <%s>",
      &( l->buffer[ l->position ] ) );
   bwb_debug( bwb_ebuf );
#endif

   /* Print line number if trace is on */

   if ( bwb_trace == TRUE )
      {
#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "[ %d ]", l->number );
      prn_xprintf( errfdevice, bwb_ebuf );
#else
      if ( l->number > 0 )
         {
         sprintf( bwb_ebuf, "[ %d ]", l->number );
	 prn_xprintf( errfdevice, bwb_ebuf );
         }
#endif
      }

   /* Set current line for error/break handling */

   CURTASK number = l->number;
   CURTASK bwb_l = l;

   /* advance beyond whitespace */

   adv_ws( l->buffer, &( l->position ) );

   /*  advance past segment delimiter and warn */

#if MULTISEG_LINES
   if ( l->buffer[ l->position ] == ':' )
      {
      ++( l->position );
      adv_ws( l->buffer, &( l->position ) );
      }
   l->marked = FALSE;
#else
#if PROG_ERRORS
   if ( l->buffer[ l->position ] == ':' )
      {
      ++( l->position );
      adv_ws( l->buffer, &( l->position ) );
      sprintf( bwb_ebuf, "Enable MULTISEG_LINES for multi-segmented lines",
         VERSION );
      bwb_error( bwb_ebuf );
      }
#endif
#endif

   /* set positions in buffer */

#if MULTISEG_LINES
   if ( ( l->marked != TRUE ) || ( l->position > l->startpos ))
      {
      line_start( l->buffer, &( l->position ), &( l->lnpos ), &( l->lnum ),
         &( l->cmdpos ), &( l->cmdnum ), &( l->startpos ) );
      l->marked = TRUE;
      }
   else
      {
#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_execline(): line <%d> is already marked",
          l->number );
      bwb_debug( bwb_ebuf );
#endif
      }
   l->position = l->startpos;
#else				/* not MULTISEG_LINES */
   line_start( l->buffer, &( l->position ), &( l->lnpos ), &( l->lnum ),
      &( l->cmdpos ), &( l->cmdnum ), &( l->startpos ) );
   if ( l->position < l->startpos )
      {
      l->position = l->startpos;
      }
#endif

   /* if there is a BASIC command in the line, execute it here */

   if ( l->cmdnum > -1 )
      {

#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_execline(): executing <%s>", l->buffer );
      bwb_debug( bwb_ebuf );
#endif

      /* execute the command vector */

      r = bwb_cmdtable[ l->cmdnum ].vector ( l );

      }

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

      bwx_shell( l );
      bwb_setexec( l->next, 0, CURTASK excs[ CURTASK exsc ].code );
      return;
      }

#else				/* COMMAND_SHELL == FALSE */

   else
     {
     bwb_error( err_uc );
     }

#endif

   /* check for end of line: if so, advance to next line and return */

   adv_ws( r->buffer, &( r->position ) );
   switch( r->buffer[ r->position ] )
      {
      case '\n':
      case '\r':
      case '\0':

#if INTENSIVE_DEBUG
	 sprintf( bwb_ebuf, "in bwb_execline(): detected end of line" );
	 bwb_debug( bwb_ebuf );
#endif

	 r->next->position = 0;
         bwb_setexec( r->next, 0, CURTASK excs[ CURTASK exsc ].code );
         return;			/* and return */
      }

   /* else reset with the value in r */

   bwb_setexec( r, r->position, CURTASK excs[ CURTASK exsc ].code );

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_execline(): exit setting line number <%d>",
      r->number );
   bwb_debug( bwb_ebuf );
#endif

   }

/***************************************************************

        FUNCTION:       ln_asbuf()

        DESCRIPTION:    This function allocates memory and copies
			a null-terminated string to a line buffer.

***************************************************************/

int
#if ANSI_C
ln_asbuf( struct bwb_line *l, char *s )
#else
ln_asbuf( l, s )
   struct bwb_line *l;
   char *s;
#endif
   {

/* Reinstated by JBV */
/* #if DONTDOTHIS */		/* but why not? */
   if ( l->buffer != NULL )
      {
      /* Revised to FREE pass-thru call by JBV */
      FREE( l->buffer, "ln_asbuf" );
      l->buffer = NULL; /* JBV */
      }
/* #endif */

   /* Revised to CALLOC pass-thru call by JBV */
   if ( ( l->buffer = CALLOC( strlen( s ) + 2, sizeof( char ), "ln_asbuf") )
      == NULL )
      {
#if PROG_ERRORS
      bwb_error( "in ln_asbuf(): failed to find memory for new line" );
#else
      bwb_error( err_getmem );
#endif
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

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in ln_asbuf(): stripped CRs" );
   bwb_debug( bwb_ebuf );
#endif

   return TRUE;

   }

/***************************************************************

        FUNCTION:       bwb_gets()

        DESCRIPTION:    This function reads a single line from
                        the specified buffer.

***************************************************************/

int
#if ANSI_C
bwb_gets( char *buffer )
#else
bwb_gets( buffer )
   char *buffer;
#endif
   {
   struct bwb_variable *v;
   char tbuf[ MAXSTRINGSIZE + 1 ];
#if PARACT
   char ubuf[ MAXSTRINGSIZE + 1 ];
#endif

   CURTASK number = 0;

   v = var_find( DEFVNAME_PROMPT );
   str_btoc( tbuf, var_getsval( v ) );
#if PARACT
   sprintf( ubuf, "TASK %d %s", bwb_curtask, tbuf );
   strcpy( tbuf, ubuf );
#endif

   bwx_input( tbuf, buffer );

   return TRUE;
   }

/***************************************************************

        FUNCTION:       break_mes()

        DESCRIPTION:    This function is called (a) by a SIGINT
			signal or (b) by error-handling routines.
			It prints an error message then calls
			break_handler() to handle the program
			interruption.

***************************************************************/

void
#if ANSI_C
break_mes( int x )
#else
break_mes( x )
   int x;
#endif
   {
   static char *tmp_buffer;
   static int init = FALSE;

   /* get memory for temporary buffer if necessary */

   if ( init == FALSE )
      {
      init = TRUE;

      /* Revised to CALLOC pass-thru call by JBV */
      if ( ( tmp_buffer = CALLOC( MAXSTRINGSIZE + 1, sizeof( char ), "break_mes")) == NULL )
         {
#if PROG_ERRORS
	 bwb_error( "in break_mes(): failed to find memory for tmp_buffer" );
#else
	 bwb_error( err_getmem );
#endif
	 }
      }

   CURTASK expsc = 0;

   sprintf( tmp_buffer, "\r%s %d\n", MES_BREAK, CURTASK number );
   prn_xprintf( errfdevice, tmp_buffer );

   break_handler();

   }

/***************************************************************

	FUNCTION:       break_handler()

	DESCRIPTION:    This function is called by break_mes()
			and handles program interruption by break
			(or by the STOP command).

***************************************************************/

void
#if ANSI_C
break_handler( void )
#else
break_handler()
#endif
   {

#if INTERACTIVE		/* INTERACTIVE: reset counters and jump back to mark */

   /* reset all stack counters */

   CURTASK exsc = -1;
   CURTASK expsc = 0;
   CURTASK xtxtsc = 0;
   err_gosubl[ 0 ] = '\0';

   /* reset the break handler */

#if HAVE_SIGNAL
   signal( SIGINT, break_mes );
#endif

#if HAVE_LONGJUMP
   longjmp( mark, -1 );
#else		/* HAVE_LONGJUMP = FALSE; no jump available; terminate */   
   bwx_terminate();
#endif   

#else		/* nonINTERACTIVE:  terminate immediately */

   bwx_terminate();

#endif

   }


/***************************************************************

	FUNCTION:       is_ln()

	DESCRIPTION:    This function determines whether a program
			line (in buffer) begins with a line number.

***************************************************************/

int
#if ANSI_C
is_ln( char *buffer )
#else
is_ln( buffer )
   char *buffer;
#endif
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


/***************************************************************

	FUNCTION:       CALLOC()

	DESCRIPTION:    Pass-thru function to calloc() for debugging
			purposes.  Added by JBV 10/95

***************************************************************/

void *
#if ANSI_C
CALLOC( size_t nelem, size_t elsize, char *str )
#else
CALLOC( nelem, elsize, str )
   size_t nelem;
   size_t elsize;
   char *str;
#endif
{
    void *ptr;

    ptr = calloc(nelem, elsize);
    /* printf("%x %x\n", ptr, mallocblksize(ptr)); */
    return ptr;
}

/***************************************************************

	FUNCTION:       FREE()

	DESCRIPTION:    Pass-thru function to free() for debugging
			purposes.  Added by JBV 10/95

***************************************************************/

void
#if ANSI_C
FREE( void *ptr, char *str )
#else
FREE( ptr, str )
   void *ptr;
   char *str;
#endif
{
    /* printf("%x\n", ptr); */
    free(ptr);
}
