/****************************************************************

        bwb_fnc.c       Interpretation Routines
			for Predefined Functions
                        for Bywater BASIC Interpreter

                        Copyright (c) 1993, Ted A. Campbell
                        Bywater Software

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

****************************************************************/

/*---------------------------------------------------------------*/
/* NOTE: Modifications marked "JBV" were made by Jon B. Volkoff, */
/* 11/1995 (eidetics@cerf.net).                                  */
/*---------------------------------------------------------------*/

#define FSTACKSIZE      32

#include <stdio.h>
#include <ctype.h>
#include <math.h>
#include <time.h>

#include "bwbasic.h"
#include "bwb_mes.h"

#if UNIX_CMDS
#include <sys/stat.h>
#endif

#ifndef RAND_MAX			/* added in v1.11 */
#define RAND_MAX	32767
#endif

static time_t t;
static struct tm *lt;

/***************************************************************

        FUNCTION:       fnc_init()

        DESCRIPTION:    This command initializes the function
                        linked list, placing all predefined functions
                        in the list.

***************************************************************/

#if ANSI_C
int
fnc_init( int task )
#else
int
fnc_init( task )
   int task;
#endif
   {
   register int n;
   struct bwb_function *f;

   strcpy( LOCALTASK fnc_start.name, "FNC_START" );
   LOCALTASK fnc_start.type = 'X';
   LOCALTASK fnc_start.vector = fnc_null;
   strcpy( LOCALTASK fnc_end.name, "FNC_END" );
   LOCALTASK fnc_end.type = 'x';
   LOCALTASK fnc_end.vector = fnc_null;
   LOCALTASK fnc_end.next = &LOCALTASK fnc_end;

   f = &LOCALTASK fnc_start;

   /* now go through each of the preestablished functions and set up
      links between them; from this point the program address the functions
      only as a linked list (not as an array) */

   for ( n = 0; n < FUNCTIONS; ++n )
      {
      f->next = &( bwb_prefuncs[ n ] );
      f = f->next;
      }

   /* link the last pointer to the end; this completes the list */

   f->next = &LOCALTASK fnc_end;

   return TRUE;
   }

/***************************************************************

        FUNCTION:       fnc_find()

        DESCRIPTION:    This C function attempts to locate
                        a BASIC function with the specified name.
                        If successful, it returns a pointer to
                        the C structure for the BASIC function,
                        if not successful, it returns NULL.

***************************************************************/

#if ANSI_C
struct bwb_function *
fnc_find( char *buffer )
#else
struct bwb_function *
fnc_find( buffer )
   char *buffer;
#endif
   {
   struct bwb_function * f;
   register int n;
   static char *tbuf;
   static int init = FALSE;

   if ( strlen( buffer ) == 0 )
      {
      return NULL;
      }

   /* get memory for temporary buffer if necessary */

   if ( init == FALSE )
      {
      init = TRUE;

      /* Revised to CALLOC pass-thru call by JBV */
      if ( ( tbuf = CALLOC( MAXSTRINGSIZE + 1, sizeof( char ), "fnc_find" )) == NULL )
         {
#if PROG_ERRORS
	 bwb_error( "in fnc_find(): failed to find memory for tbuf" );
#else
	 bwb_error( err_getmem );
#endif
	 }
      }

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in fnc_find(): called for <%s> ", buffer );
   bwb_debug( bwb_ebuf );
#endif

   strcpy( tbuf, buffer );
   bwb_strtoupper( tbuf );

   for ( f = CURTASK fnc_start.next; f != &CURTASK fnc_end; f = f->next )
      {
      if ( strcmp( f->name, tbuf ) == 0 )
         {
#if INTENSIVE_DEBUG
	 sprintf( bwb_ebuf, "in fnc_find(): found <%s> ", f->name );
	 bwb_debug( bwb_ebuf );
#endif
         return f;
         }
      }

   /* search has failed: return NULL */

   return NULL;

   }

/***************************************************************

        FUNCTION:       fnc_null()

        DESCRIPTION:    This is a null function that can be used
                        to fill in a required function-structure
                        pointer when needed.

***************************************************************/

#if ANSI_C
struct bwb_variable *
fnc_null( int argc, struct bwb_variable *argv, int unique_id )
#else
struct bwb_variable *
fnc_null( argc, argv, unique_id )
   int argc;
   struct bwb_variable *argv;
   int unique_id;
#endif
   {
   static struct bwb_variable nvar;
   static int init = FALSE;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, NUMBER );
      }

   return &nvar;
   }

/***************************************************************

        FUNCTION:       fnc_tab()

	DESCRIPTION:    This C function implements the BASIC TAB()
			function, adding tab spaces to a specified
			column.

			TAB is a core function, i.e., required
			for ANSI Minimal BASIC.

	SYNTAX:		TAB( number )

***************************************************************/

#if ANSI_C
struct bwb_variable *
fnc_tab( int argc, struct bwb_variable *argv, int unique_id )
#else
struct bwb_variable *
fnc_tab( argc, argv, unique_id )
   int argc;
   struct bwb_variable *argv;
   int unique_id;
#endif
   {
   static struct bwb_variable nvar;
   static int init = FALSE;
   static char t_string[ 4 ];
   bstring *b;

   /* initialize nvar if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, (int) STRING );
      }

   /* check for correct number of parameters */

   if ( argc < 1 )
      {
#if PROG_ERRORS
      sprintf( bwb_ebuf, "Not enough parameters (%d) to function TAB().",
         argc );
      bwb_error( bwb_ebuf );
#else
      bwb_error( err_syntax );
#endif
      break_handler();
      return NULL;
      }
   else if ( argc > 1 )
      {
#if PROG_ERRORS
      sprintf( bwb_ebuf, "Too many parameters (%d) to function TAB().",
         argc );
      bwb_error( bwb_ebuf );
#else
      bwb_error( err_syntax );
#endif
      break_handler();
      return NULL;
      }

   t_string[ 0 ] = PRN_TAB;
   t_string[ 1 ] = (char) var_getnval( &( argv[ 0 ] ));
   t_string[ 2 ] = '\0';

   b = var_getsval( &nvar );
   str_ctob( b, t_string );

   return &nvar;
   }

#if COMMON_FUNCS

/***************************************************************


        FUNCTION:       fnc_date()

        DESCRIPTION:    This C function implements the BASIC
                        predefined DATE$ function, returning
                        a string containing the year, month,
                        and day of the month.

	SYNTAX:		DATE$

***************************************************************/

#if ANSI_C
struct bwb_variable *
fnc_date( int argc, struct bwb_variable *argv, int unique_id )
#else
struct bwb_variable *
fnc_date( argc, argv, unique_id )
   int argc;
   struct bwb_variable *argv;
   int unique_id;
#endif
   {
   static struct bwb_variable nvar;
   static int init = FALSE;
   static char *tbuf;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, STRING );

      /* Revised to CALLOC pass-thru call by JBV */
      if ( ( tbuf = CALLOC( MAXSTRINGSIZE + 1, sizeof( char ), "fnc_date" )) == NULL )
         {
#if PROG_ERRORS
         bwb_error( "in fnc_date(): failed to get memory for tbuf" );
#else
         bwb_error( err_getmem );
#endif
         }
      }

   time( &t );
   lt = localtime( &t );

   sprintf( tbuf, "%02d-%02d-%04d", lt->tm_mon + 1, lt->tm_mday,
      1900 + lt->tm_year );
   str_ctob( var_findsval( &nvar, nvar.array_pos ), tbuf );

   return &nvar;
   }

/***************************************************************

        FUNCTION:       fnc_time()

        DESCRIPTION:    This C function implements the BASIC
                        predefined TIME$ function, returning a
                        string containing the hour, minute, and
                        second count.

	SYNTAX:		TIME$

***************************************************************/

#if ANSI_C
struct bwb_variable *
fnc_time( int argc, struct bwb_variable *argv, int unique_id )
#else
struct bwb_variable *
fnc_time( argc, argv, unique_id )
   int argc;
   struct bwb_variable *argv;
   int unique_id;
#endif
   {
   static struct bwb_variable nvar;
   static char *tbuf;
   static int init = FALSE;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, STRING );

      /* Revised to CALLOC pass-thru call by JBV */
      if ( ( tbuf = CALLOC( MAXSTRINGSIZE + 1, sizeof( char ), "fnc_time" )) == NULL )
         {
#if PROG_ERRORS
         bwb_error( "in fnc_time(): failed to get memory for tbuf" );
#else
         bwb_error( err_getmem );
#endif
         }
      }

   time( &t );
   lt = localtime( &t );

   sprintf( tbuf, "%02d:%02d:%02d", lt->tm_hour, lt->tm_min,
      lt->tm_sec );
   str_ctob( var_findsval( &nvar, nvar.array_pos ), tbuf );

   return &nvar;
   }

/***************************************************************

        FUNCTION:       fnc_chr()

        DESCRIPTION:    This C function implements the BASIC
                        predefined CHR$ function, returning a
                        string containing the single character
                        whose ASCII value is the argument to
                        this function.

	SYNTAX:		CHR$( number )

***************************************************************/

#if ANSI_C
struct bwb_variable *
fnc_chr( int argc, struct bwb_variable *argv, int unique_id  )
#else
struct bwb_variable *
fnc_chr( argc, argv, unique_id  )
   int argc;
   struct bwb_variable *argv;
   int unique_id;
#endif
   {
   static struct bwb_variable nvar;
   char tbuf[ MAXSTRINGSIZE + 1 ];
   static int init = FALSE;
#if TEST_BSTRING
   bstring *b;
#endif

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in fnc_chr(): entered function, argc <%d>",
      argc );
   bwb_debug( bwb_ebuf );
#endif

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, STRING );
#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in fnc_chr(): entered function, initialized nvar" );
      bwb_debug( bwb_ebuf );
#endif
      }

   /* check arguments */

#if PROG_ERRORS
   if ( argc < 1 )
      {
      sprintf( bwb_ebuf, "Not enough arguments to function CHR$()" );
      bwb_error( bwb_ebuf );
      return NULL;
      }
   else if ( argc > 1 )
      {
      sprintf( bwb_ebuf, "Too many parameters (%d) to function CHR$().",
         argc );
      bwb_error( bwb_ebuf );
      return NULL;
      }
#else
   if ( fnc_checkargs( argc, argv, 1, 1 ) == FALSE )
      {
      return NULL;
      }
#endif

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in fnc_chr(): entered function, checkargs ok" );
   bwb_debug( bwb_ebuf );
#endif

   tbuf[ 0 ] = (char) var_getnval( &( argv[ 0 ] ) );
   tbuf[ 1 ] = '\0';
   str_ctob( var_findsval( &nvar, nvar.array_pos ), tbuf );

#if TEST_BSTRING
   b = var_findsval( &nvar, nvar.array_pos );
   sprintf( bwb_ebuf, "in fnc_chr(): bstring name is <%s>", b->name );
   bwb_debug( bwb_ebuf );
#endif
#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in fnc_chr(): tbuf[ 0 ] is <%c>", tbuf[ 0 ] );
   bwb_debug( bwb_ebuf );
#endif

   return &nvar;
   }

/***************************************************************

        FUNCTION:       fnc_len()

	DESCRIPTION:    This C function implements the BASIC LEN()
			function, returning the length of a
			specified string in bytes.

	SYNTAX:		LEN( string$ )

***************************************************************/

#if ANSI_C
struct bwb_variable *
fnc_len( int argc, struct bwb_variable *argv, int unique_id )
#else
struct bwb_variable *
fnc_len( argc, argv, unique_id )
   int argc;
   struct bwb_variable *argv;
   int unique_id;
#endif
   {
   static struct bwb_variable nvar;
   static int init = FALSE;
   static char *tbuf;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, NUMBER );

      /* Revised to CALLOC pass-thru call by JBV */
      if ( ( tbuf = CALLOC( MAXSTRINGSIZE + 1, sizeof( char ), "fnc_len" )) == NULL )
         {
#if PROG_ERRORS
         bwb_error( "in fnc_len(): failed to get memory for tbuf" );
#else
         bwb_error( err_getmem );
#endif
         }
      }

   /* check parameters */

#if PROG_ERRORS
   if ( argc < 1 )
      {
      sprintf( bwb_ebuf, "Not enough parameters (%d) to function LEN().",
         argc );
      bwb_error( bwb_ebuf );
      return NULL;
      }
   else if ( argc > 1 )
      {
      sprintf( bwb_ebuf, "Too many parameters (%d) to function LEN().",
         argc );
      bwb_error( bwb_ebuf );
      return NULL;
      }
#else
   if ( fnc_checkargs( argc, argv, 1, 1 ) == FALSE )
      {
      return NULL;
      }
#endif

   /* return length as an integer */

   str_btoc( tbuf, var_getsval( &( argv[ 0 ] )) );
   * var_findnval( &nvar, nvar.array_pos )
      = (bnumber) strlen( tbuf );

   return &nvar;
   }

/***************************************************************

        FUNCTION:       fnc_pos()

	DESCRIPTION:    This C function implements the BASIC
			POS() function, returning the current
			column position for the output device.

	SYNTAX:		POS

***************************************************************/

#if ANSI_C
struct bwb_variable *
fnc_pos( int argc, struct bwb_variable *argv, int unique_id )
#else
struct bwb_variable *
fnc_pos( argc, argv, unique_id )
   int argc;
   struct bwb_variable *argv;
   int unique_id;
#endif
   {
   static struct bwb_variable nvar;
   static int init = FALSE;

   /* initialize nvar if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, (int) NUMBER );
      }

   * var_findnval( &nvar, nvar.array_pos ) = (bnumber) prn_col;

   return &nvar;
   }

#endif					/* COMMON_FUNCS */

#if MS_FUNCS

/***************************************************************

        FUNCTION:       fnc_timer()

        DESCRIPTION:    This C function implements the BASIC
                        predefined TIMER function

	SYNTAX:		TIMER

***************************************************************/

#if ANSI_C
struct bwb_variable *
fnc_timer( int argc, struct bwb_variable *argv, int unique_id  )
#else
struct bwb_variable *
fnc_timer( argc, argv, unique_id  )
   int argc;
   struct bwb_variable *argv;
   int unique_id;
#endif
   {
   static struct bwb_variable nvar;
   static time_t now;
   static int init = FALSE;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, NUMBER );
      }

   time( &now );
   /* Following statement was (bnumber) (JBV) */
   * var_findnval( &nvar, nvar.array_pos )
      = (float) fmod( (double) now, (double) (60*60*24));

   return &nvar;
   }

/***************************************************************

        FUNCTION:       fnc_mid()

        DESCRIPTION:    This C function implements the BASIC
                        predefined MID$ function

	SYNTAX:		MID$( string$, start-position-in-string[, number-of-spaces ] )

***************************************************************/

#if ANSI_C
struct bwb_variable *
fnc_mid( int argc, struct bwb_variable *argv, int unique_id  )
#else
struct bwb_variable *
fnc_mid( argc, argv, unique_id  )
   int argc;
   struct bwb_variable *argv;
   int unique_id;
#endif
   {
   static struct bwb_variable nvar;
   register int c;
   char target_string[ MAXSTRINGSIZE + 1 ];
   int target_counter, num_spaces;
   char tbuf[ MAXSTRINGSIZE + 1 ];
   static int init = FALSE;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, STRING );
      }

   /* check arguments */

#if PROG_ERRORS
   if ( argc < 2 )
      {
      sprintf( bwb_ebuf, "Not enough arguments to function MID$()" );
      bwb_error( bwb_ebuf );
      return &nvar;
      }

   if ( argc > 3 )
      {
      sprintf( bwb_ebuf, "Two many arguments to function MID$()" );
      bwb_error( bwb_ebuf );
      return &nvar;
      }

#else
   if ( fnc_checkargs( argc, argv, 2, 3 ) == FALSE )
      {
      return NULL;
      }
#endif

   /* get arguments */

   str_btoc( target_string, var_getsval( &( argv[ 0 ] ) ));
   target_counter = (int) var_getnval( &( argv[ 1 ] ) ) - 1;
   if ( target_counter > (int) strlen( target_string ))
      {
      tbuf[ 0 ] = '\0';
      str_ctob( var_findsval( &nvar, nvar.array_pos ), tbuf );
      return &nvar;
      }

   if ( argc == 3 )
      {
      num_spaces = (int) var_getnval( &( argv[ 2 ] ));
      }
   else
      {
      num_spaces = MAXSTRINGSIZE;
      }

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in fnc_mid() string <%s> startpos <%d> spaces <%d>",
      target_string, target_counter, num_spaces );
   bwb_debug( bwb_ebuf );
#endif

   c = 0;
   tbuf[ c ] = '\0';
   while ( ( c < num_spaces ) && ( target_string[ target_counter ] != '\0' ))
      {
      tbuf[ c ] = target_string[ target_counter ];
      ++c;
      tbuf[ c ] = '\0';
      ++target_counter;
      }
   str_ctob( var_findsval( &nvar, nvar.array_pos ), tbuf );

   return &nvar;
   }

/***************************************************************

        FUNCTION:       fnc_left()

        DESCRIPTION:    This C function implements the BASIC
                        predefined LEFT$ function

	SYNTAX:		LEFT$( string$, number-of-spaces )

***************************************************************/

#if ANSI_C
struct bwb_variable *
fnc_left( int argc, struct bwb_variable *argv, int unique_id  )
#else
struct bwb_variable *
fnc_left( argc, argv, unique_id  )
   int argc;
   struct bwb_variable *argv;
   int unique_id;
#endif
   {
   static struct bwb_variable nvar;
   register int c;
   char target_string[ MAXSTRINGSIZE + 1 ];
   int target_counter, num_spaces;
   char tbuf[ MAXSTRINGSIZE + 1 ];
   static int init = FALSE;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, STRING );
      }

   /* check arguments */

#if PROG_ERRORS
   if ( argc < 2 )
      {
      sprintf( bwb_ebuf, "Not enough arguments to function LEFT$()" );
      bwb_error( bwb_ebuf );
      return &nvar;
      }

   if ( argc > 2 )
      {
      sprintf( bwb_ebuf, "Two many arguments to function LEFT$()" );
      bwb_error( bwb_ebuf );
      return &nvar;
      }

#else
   if ( fnc_checkargs( argc, argv, 2, 2 ) == FALSE )
      {
      return NULL;
      }
#endif

   /* get arguments */

   str_btoc( tbuf, var_getsval( &( argv[ 0 ] ) ));
   target_counter = 0;
   num_spaces = (int) var_getnval( &( argv[ 1 ] ));

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in fnc_left() string <%s> startpos <%d> spaces <%d>",
      tbuf, target_counter, num_spaces );
   bwb_debug( bwb_ebuf );
#endif

   c = 0;
   target_string[ 0 ] = '\0';
   while (( c < num_spaces ) && ( tbuf[ c ] != '\0' ))
      {
      target_string[ target_counter ] = tbuf[ c ];
      ++target_counter;
      target_string[ target_counter ] = '\0';
      ++c;
      }
   str_ctob( var_findsval( &nvar, nvar.array_pos ), target_string );

   return &nvar;
   }

/***************************************************************

        FUNCTION:       fnc_right()

        DESCRIPTION:    This C function implements the BASIC
                        predefined RIGHT$ function

	SYNTAX:		RIGHT$( string$, number-of-spaces )

***************************************************************/

#if ANSI_C
struct bwb_variable *
fnc_right( int argc, struct bwb_variable *argv, int unique_id  )
#else
struct bwb_variable *
fnc_right( argc, argv, unique_id  )
   int argc;
   struct bwb_variable *argv;
   int unique_id;
#endif
   {
   static struct bwb_variable nvar;
   register int c;
   char target_string[ MAXSTRINGSIZE + 1 ];
   int target_counter, num_spaces;
   char tbuf[ MAXSTRINGSIZE + 1 ];
   static int init = FALSE;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, STRING );
      }

   /* check arguments */

#if PROG_ERRORS
   if ( argc < 2 )
      {
      sprintf( bwb_ebuf, "Not enough arguments to function RIGHT$()" );
      bwb_error( bwb_ebuf );
      return &nvar;
      }

   if ( argc > 2 )
      {
      sprintf( bwb_ebuf, "Two many arguments to function RIGHT$()" );
      bwb_error( bwb_ebuf );
      return &nvar;
      }

#else
   if ( fnc_checkargs( argc, argv, 2, 2 ) == FALSE )
      {
      return NULL;
      }
#endif

   /* get arguments */

   str_btoc( target_string, var_getsval( &( argv[ 0 ] ) ));
   target_counter = strlen( target_string ) - (int) var_getnval( &( argv[ 1 ] ));
   num_spaces = MAXSTRINGSIZE;

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in fnc_right() string <%s> startpos <%d> spaces <%d>",
      target_string, target_counter, num_spaces );
   bwb_debug( bwb_ebuf );
#endif

   c = 0;
   tbuf[ c ] = '\0';
   while ( ( c < num_spaces ) && ( target_string[ target_counter ] != '\0' ))
      {
      tbuf[ c ] = target_string[ target_counter ];
      ++c;
      tbuf[ c ] = '\0';
      ++target_counter;
      }
   str_ctob( var_findsval( &nvar, nvar.array_pos ), tbuf );

   return &nvar;
   }

/***************************************************************

        FUNCTION:       fnc_asc()

        DESCRIPTION:    This function implements the predefined
			BASIC ASC() function, returning the ASCII
			number associated with the first character
			in the string argument.

	SYNTAX:		ASC( string$ )

***************************************************************/

#if ANSI_C
struct bwb_variable *
fnc_asc( int argc, struct bwb_variable *argv, int unique_id )
#else
struct bwb_variable *
fnc_asc( argc, argv, unique_id )
   int argc;
   struct bwb_variable *argv;
   int unique_id;
#endif
   {
   static struct bwb_variable nvar;
   static char *tbuf;
   static int init = FALSE;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, NUMBER );

      /* Revised to CALLOC pass-thru call by JBV */
      if ( ( tbuf = CALLOC( MAXSTRINGSIZE + 1, sizeof( char ), "fnc_asc" )) == NULL )
         {
#if PROG_ERRORS
         bwb_error( "in fnc_asc(): failed to get memory for tbuf" );
#else
         bwb_error( err_getmem );
#endif
         }
      }

   /* check parameters */

#if PROG_ERRORS
   if ( argc < 1 )
      {
      sprintf( bwb_ebuf, "Not enough parameters (%d) to function ASC().",
         argc );
      bwb_error( bwb_ebuf );
      return NULL;
      }
   else if ( argc > 1 )
      {
      sprintf( bwb_ebuf, "Too many parameters (%d) to function ASC().",
         argc );
      bwb_error( bwb_ebuf );
      return NULL;
      }
#else
   if ( fnc_checkargs( argc, argv, 1, 1 ) == FALSE )
      {
      return NULL;
      }
#endif

   if ( argv[ 0 ].type != STRING )
      {
#if PROG_ERRORS
      sprintf( bwb_ebuf, "Argument to function ASC() must be a string." );
      bwb_error( bwb_ebuf );
#else
      bwb_error( err_mismatch );
#endif
      return NULL;
      }

   /* assign ASCII value of first character in the buffer */

   str_btoc( tbuf, var_findsval( &( argv[ 0 ] ), argv[ 0 ].array_pos ) );
   * var_findnval( &nvar, nvar.array_pos ) = (bnumber) tbuf[ 0 ];

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in fnc_asc(): string is <%s>",
      tbuf );
   bwb_debug( bwb_ebuf );
#endif

   return &nvar;
   }

/***************************************************************

        FUNCTION:       fnc_string()

        DESCRIPTION:    This C function implements the BASIC
			STRING$() function.

	SYNTAX:		STRING$( number, ascii-value|string$ )

***************************************************************/

#if ANSI_C
struct bwb_variable *
fnc_string( int argc, struct bwb_variable *argv, int unique_id )
#else
struct bwb_variable *
fnc_string( argc, argv, unique_id )
   int argc;
   struct bwb_variable *argv;
   int unique_id;
#endif
   {
   static struct bwb_variable nvar;
   int length;
   register int i;
   char c;
   static char *tbuf;
   static int init = FALSE;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, STRING );

      /* Revised to CALLOC pass-thru call by JBV */
      if ( ( tbuf = CALLOC( MAXSTRINGSIZE + 1, sizeof( char ), "fnc_string" )) == NULL )
         {
#if PROG_ERRORS
         bwb_error( "in fnc_string(): failed to get memory for tbuf" );
#else
         bwb_error( err_getmem );
#endif
         }
      }

   /* check for correct number of parameters */

#if PROG_ERRORS
   if ( argc < 2 )
      {
      sprintf( bwb_ebuf, "Not enough parameters (%d) to function STRING$().",
         argc );
      bwb_error( bwb_ebuf );
      return NULL;
      }
   else if ( argc > 2 )
      {
      sprintf( bwb_ebuf, "Too many parameters (%d) to function STRING$().",
         argc );
      bwb_error( bwb_ebuf );
      return NULL;
      }
#else
   if ( fnc_checkargs( argc, argv, 2, 2 ) == FALSE )
      {
      return NULL;
      }
#endif

   strcpy( nvar.name, "(string$)!" );
   nvar.type = STRING;
   tbuf[ 0 ] = '\0';
   length = (int) var_getnval( &( argv[ 0 ] ));

   if ( argv[ 1 ].type == STRING )
      {
      str_btoc( tbuf, var_getsval( &( argv[ 1 ] )));
      c = tbuf[ 0 ];
      }
   else
      {
      c = (char) var_getnval( &( argv[ 1 ] ) );
      }

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in fnc_string(): argument <%s> arg type <%c>, length <%d>",
      tbuf, argv[ 1 ].type, length );
   bwb_debug( bwb_ebuf );
   sprintf( bwb_ebuf, "in fnc_string(): type <%c>, c <0x%x>=<%c>",
      argv[ 1 ].type, c, c );
   bwb_debug( bwb_ebuf );
#endif

   /* add characters to the string */

   for ( i = 0; i < length; ++i )
      {
      tbuf[ i ] = c;
      tbuf[ i + 1 ] = '\0';
      }
   str_ctob( var_findsval( &nvar, nvar.array_pos ), tbuf );

   return &nvar;
   }

/***************************************************************

        FUNCTION:       fnc_instr()

        DESCRIPTION:	This C function implements the BASIC 
			INSTR() function, returning the position
			in string string-searched$ at which
			string-pattern$ occurs.

	SYNTAX:		INSTR( [start-position,] string-searched$, string-pattern$ )

***************************************************************/

#if ANSI_C
struct bwb_variable *
fnc_instr( int argc, struct bwb_variable *argv, int unique_id )
#else
struct bwb_variable *
fnc_instr( argc, argv, unique_id )
   int argc;
   struct bwb_variable *argv;
   int unique_id;
#endif
   {
   static struct bwb_variable nvar;
   static int init = FALSE;
   int n_pos, x_pos, y_pos;
   int start_pos;
   register int n;
   char xbuf[ MAXSTRINGSIZE + 1 ];
   char ybuf[ MAXSTRINGSIZE + 1 ];

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, NUMBER );
      }

   /* check for correct number of parameters */

#if PROG_ERRORS
   if ( argc < 2 )
      {
      sprintf( bwb_ebuf, "Not enough parameters (%d) to function INSTR().",
         argc );
      bwb_error( bwb_ebuf );
      return NULL;
      }
   else if ( argc > 3 )
      {
      sprintf( bwb_ebuf, "Too many parameters (%d) to function INSTR().",
         argc );
      bwb_error( bwb_ebuf );
      return NULL;
      }
#else
   if ( fnc_checkargs( argc, argv, 2, 3 ) == FALSE )
      {
      return NULL;
      }
#endif

   /* determine argument positions */

   if ( argc == 3 )
      {
      n_pos = 0;
      x_pos = 1;
      y_pos = 2;
      }
   else
      {
      n_pos = -1;
      x_pos = 0;
      y_pos = 1;
      }

   /* determine starting position */

   if ( n_pos == 0 )
      {
      start_pos = (int) var_getnval( &( argv[ n_pos ] ) ) - 1;
      }
   else
      {
      start_pos = 0;
      }

   /* get x and y strings */

   str_btoc( xbuf, var_getsval( &( argv[ x_pos ] ) ) );
   str_btoc( ybuf, var_getsval( &( argv[ y_pos ] ) ) );

   /* now search for match */

   for ( n = start_pos; n < (int) strlen( xbuf ); ++n )
      {
      if ( strncmp( &( xbuf[ n ] ), ybuf, strlen( ybuf ) ) == 0 )
         {
         * var_findnval( &nvar, nvar.array_pos ) = (bnumber) n + 1;
         return &nvar;
         }
      }

   /* match not found */

   * var_findnval( &nvar, nvar.array_pos ) = (bnumber) 0;
   return &nvar;

   }

/***************************************************************

        FUNCTION:       fnc_spc()

	DESCRIPTION:    This C function implements the BASIC
			SPC() function, returning a string
			containing a specified number of
			(blank) spaces.

	SYNTAX:		SPC( number )

***************************************************************/

#if ANSI_C
struct bwb_variable *
fnc_spc( int argc, struct bwb_variable *argv, int unique_id )
#else
struct bwb_variable *
fnc_spc( argc, argv, unique_id )
   int argc;
   struct bwb_variable *argv;
   int unique_id;
#endif
   {
   return fnc_space( argc, argv, unique_id );
   }

/***************************************************************

        FUNCTION:       fnc_space()

	DESCRIPTION:    This C function implements the BASIC
			SPACE() function, returning a string
			containing a specified number of
			(blank) spaces.

	SYNTAX:		SPACE$( number )

***************************************************************/

#if ANSI_C
struct bwb_variable *
fnc_space( int argc, struct bwb_variable *argv, int unique_id )
#else
struct bwb_variable *
fnc_space( argc, argv, unique_id )
   int argc;
   struct bwb_variable *argv;
   int unique_id;
#endif
   {
   static struct bwb_variable nvar;
   static char *tbuf;
   static int init = FALSE;
   int spaces;
   register int i;
   bstring *b;

   /* check for correct number of parameters */

   if ( argc < 1 )
      {
#if PROG_ERRORS
      sprintf( bwb_ebuf, "Not enough parameters (%d) to function SPACE$().",
         argc );
      bwb_error( bwb_ebuf );
#else
      bwb_error( err_syntax );
#endif
      break_handler();
      return NULL;
      }
   else if ( argc > 1 )
      {
#if PROG_ERRORS
      sprintf( bwb_ebuf, "Too many parameters (%d) to function SPACE$().",
         argc );
      bwb_error( bwb_ebuf );
#else
      bwb_error( err_syntax );
#endif
      break_handler();
      return NULL;
      }

   /* initialize nvar if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, (int) STRING );

      /* Revised to CALLOC pass-thru call by JBV */
      if ( ( tbuf = CALLOC( MAXSTRINGSIZE + 1, sizeof( char ), "fnc_space" )) == NULL )
         {
#if PROG_ERRORS
         bwb_error( "in fnc_space(): failed to get memory for tbuf" );
#else
         bwb_error( err_getmem );
#endif
         }
      }

   tbuf[ 0 ] = '\0';
   spaces = (int) var_getnval( &( argv[ 0 ] ));

   /* add spaces to the string */

   for ( i = 0; i < spaces; ++i )
      {
      tbuf[ i ] = ' ';
      tbuf[ i + 1 ] = '\0';
      }

   b = var_getsval( &nvar );
   str_ctob( b, tbuf );

   return &nvar;
   }

/***************************************************************

        FUNCTION:       fnc_environ()

        DESCRIPTION:    This C function implements the BASIC
			ENVIRON$() function, returning the value
			of a specified environment string.

	SYNTAX:		ENVIRON$( variable-string )

***************************************************************/

#if ANSI_C
struct bwb_variable *
fnc_environ( int argc, struct bwb_variable *argv, int unique_id )
#else
struct bwb_variable *
fnc_environ( argc, argv, unique_id )
   int argc;
   struct bwb_variable *argv;
   int unique_id;
#endif
   {
   char tbuf[ MAXSTRINGSIZE + 1 ];
   char tmp[ MAXSTRINGSIZE + 1 ];
   static struct bwb_variable nvar;
   static int init = FALSE;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, STRING );
      }

   /* check for correct number of parameters */

#if PROG_ERRORS
   if ( argc < 1 )
      {
      sprintf( bwb_ebuf, "Not enough parameters (%d) to function ENVIRON$().",
         argc );
      bwb_error( bwb_ebuf );
      return NULL;
      }
   else if ( argc > 1 )
      {
      sprintf( bwb_ebuf, "Too many parameters (%d) to function ENVIRON$().",
         argc );
      bwb_error( bwb_ebuf );
      return NULL;
      }
#else
   if ( fnc_checkargs( argc, argv, 1, 1 ) == FALSE )
      {
      return NULL;
      }
#endif

   /* resolve the argument and place string value in tbuf */

   str_btoc( tbuf, var_getsval( &( argv[ 0 ] )));

   /* call getenv() then write value to string */

   /*--------------------------------------------------------------------*/
   /* Added check for getenv return value to prevent segmentation faults */
   /* JBV 3/15/96                                                        */
   /*--------------------------------------------------------------------*/
   if (getenv( tbuf ) != NULL) strcpy( tmp, getenv( tbuf ));
   else strcpy( tmp, "" );

   str_ctob( var_findsval( &nvar, nvar.array_pos ), tmp );

   /* return address of nvar */

   return &nvar;

   }

/***************************************************************

        FUNCTION:       fnc_err()

	DESCRIPTION:    This C function implements the BASIC
			ERR function, returning the error number
			for the most recent error.

			Please note that as of revision level
			2.10, bwBASIC does not utilize a standard
			list of error numbers, so numbers returned
			by this function will not be those found
			in either ANSI or Microsoft or other
			BASIC error tables.

	SYNTAX:		ERR

***************************************************************/

#if ANSI_C
struct bwb_variable *
fnc_err( int argc, struct bwb_variable *argv, int unique_id )
#else
struct bwb_variable *
fnc_err( argc, argv, unique_id )
   int argc;
   struct bwb_variable *argv;
   int unique_id;
#endif
   {
   static struct bwb_variable nvar;
   static int init = FALSE;

   /* initialize nvar if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, (int) NUMBER );
      }

   * var_findnval( &nvar, nvar.array_pos ) = (bnumber) err_number;

   return &nvar;
   }

/***************************************************************

        FUNCTION:       fnc_erl()

	DESCRIPTION:    This C function implements the BASIC
			ERL function, returning the line number
			for the most recent error.

	SYNTAX:		ERL

***************************************************************/

#if ANSI_C
struct bwb_variable *
fnc_erl( int argc, struct bwb_variable *argv, int unique_id )
#else
struct bwb_variable *
fnc_erl( argc, argv, unique_id )
   int argc;
   struct bwb_variable *argv;
   int unique_id;
#endif
   {
   static struct bwb_variable nvar;
   static int init = FALSE;

   /* initialize nvar if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, (int) NUMBER );
      }

   * var_findnval( &nvar, nvar.array_pos ) = (bnumber) err_line;

   return &nvar;
   }

/***************************************************************

        FUNCTION:       fnc_loc()

        DESCRIPTION:    This C function implements the BASIC
			LOC() function. As implemented here,
			this only works for random-acess files.

	SYNTAX:		LOC( device-number )

***************************************************************/

#if ANSI_C
struct bwb_variable *
fnc_loc( int argc, struct bwb_variable *argv, int unique_id )
#else
struct bwb_variable *
fnc_loc( argc, argv, unique_id )
   int argc;
   struct bwb_variable *argv;
   int unique_id;
#endif
   {
   static struct bwb_variable nvar;
   static int init = FALSE;
   int dev_number;

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in fnc_loc(): received f_arg <%f> ",
      var_getnval( &( argv[ 0 ] ) ) );
   bwb_debug( bwb_ebuf );
#endif

   if ( argc < 1 )
      {
#if PROG_ERRORS
      sprintf( bwb_ebuf, "Not enough parameters (%d) to function LOC().",
         argc );
      bwb_error( bwb_ebuf );
#else
      bwb_error( err_syntax );
#endif
      return NULL;
      }
   else if ( argc > 1 )
      {
#if PROG_ERRORS
      sprintf( bwb_ebuf, "Too many parameters (%d) to function LOC().",
         argc );
      bwb_error( bwb_ebuf );
#else
      bwb_error( err_syntax );
#endif
      return NULL;
      }

   dev_number = (int) var_getnval( &( argv[ 0 ] ) );

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, NUMBER );
      }

   /* note if this is the very beginning of the file */

   if ( dev_table[ dev_number ].loc == 0 )
      {
      * var_findnval( &nvar, nvar.array_pos ) = (bnumber) 0;
      }
   else
      {
      * var_findnval( &nvar, nvar.array_pos ) =
         (bnumber) dev_table[ dev_number ].next_record;
      }

   return &nvar;
   }

/***************************************************************

        FUNCTION:       fnc_eof()

        DESCRIPTION:    This C function implements the BASIC
			EOF() function.

	SYNTAX:		EOF( device-number )

***************************************************************/

#if ANSI_C
struct bwb_variable *
fnc_eof( int argc, struct bwb_variable *argv, int unique_id )
#else
struct bwb_variable *
fnc_eof( argc, argv, unique_id )
   int argc;
   struct bwb_variable *argv;
   int unique_id;
#endif
   {
   static struct bwb_variable nvar;
   static int init = FALSE;
   int dev_number;
   int cur_pos, end_pos; /* JBV */

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in fnc_loc(): received f_arg <%f> ",
      var_getnval( &( argv[ 0 ] ) ) );
   bwb_debug( bwb_ebuf );
#endif

   if ( argc < 1 )
      {
#if PROG_ERRORS
      sprintf( bwb_ebuf, "Not enough parameters (%d) to function EOF().",
         argc );
      bwb_error( bwb_ebuf );
#else
      bwb_error( err_syntax );
#endif
      return NULL;
      }
   else if ( argc > 1 )
      {
#if PROG_ERRORS
      sprintf( bwb_ebuf, "Too many parameters (%d) to function EOF().",
         argc );
      bwb_error( bwb_ebuf );
#else
      bwb_error( err_syntax );
#endif
      return NULL;
      }

   dev_number = (int) var_getnval( &( argv[ 0 ] ) );

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, NUMBER );
      }

   /* note if this is the very beginning of the file */

   if ( dev_table[ dev_number ].mode == DEVMODE_AVAILABLE )
      {
      bwb_error( err_devnum );
      * var_findnval( &nvar, nvar.array_pos ) = (bnumber) TRUE;
      }
   else if ( dev_table[ dev_number ].mode == DEVMODE_CLOSED )
      {
      bwb_error( err_devnum );
      * var_findnval( &nvar, nvar.array_pos ) = (bnumber) TRUE;
      }

   /*------------------------------------------------------*/
   /* feof() finds EOF when you read past the end of file. */
   /* This is not how BASIC works, at least not GWBASIC.   */
   /* The EOF function should return an EOF indication     */
   /* when you are <at> the end of the file, not past it.  */
   /* This routine was modified to reflect this.           */
   /* (JBV, 10/15/95)                                      */
   /*------------------------------------------------------*/

   /*  else if ( feof( dev_table[ dev_number ].cfp ) == 0 ) */
   else if ( ftell( dev_table[ dev_number ].cfp ) !=
   dev_table [ dev_number ].lof )
      {
      * var_findnval( &nvar, nvar.array_pos ) = (bnumber) FALSE;
      }
   else
      {
      * var_findnval( &nvar, nvar.array_pos ) = (bnumber) TRUE;
      }

   return &nvar;
   }

/***************************************************************

        FUNCTION:       fnc_lof()

        DESCRIPTION:    This C function implements the BASIC
			LOF() function.

	SYNTAX:		LOF( device-number )

***************************************************************/

#if ANSI_C
struct bwb_variable *
fnc_lof( int argc, struct bwb_variable *argv, int unique_id )
#else
struct bwb_variable *
fnc_lof( argc, argv, unique_id )
   int argc;
   struct bwb_variable *argv;
   int unique_id;
#endif
   {
   static struct bwb_variable nvar;
   static int init = FALSE;
   int dev_number;

/* Following section no longer needed, removed by JBV */
/* #if UNIX_CMDS
   static struct stat statbuf;
   int r;
#endif */

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in fnc_lof(): received f_arg <%f> ",
      var_getnval( &( argv[ 0 ] ) ) );
   bwb_debug( bwb_ebuf );
#endif

   if ( argc < 1 )
      {
#if PROG_ERRORS
      sprintf( bwb_ebuf, "Not enough parameters (%d) to function LOF().",
         argc );
      bwb_error( bwb_ebuf );
#else
      bwb_error( err_syntax );
#endif
      return NULL;
      }
   else if ( argc > 1 )
      {
#if PROG_ERRORS
      sprintf( bwb_ebuf, "Too many parameters (%d) to function LOF().",
         argc );
      bwb_error( bwb_ebuf );
#else
      bwb_error( err_syntax );
#endif
      return NULL;
      }

   dev_number = (int) var_getnval( &( argv[ 0 ] ) );

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, NUMBER );
      }

   /* stat the file */

/* Following section no longer needed, removed by JBV */
/* #if UNIX_CMDS

   r = stat( dev_table[ dev_number ].filename, &statbuf );

   if ( r != 0 )
      {
#if PROG_ERRORS
      sprintf( bwb_ebuf, "in fnc_lof(): failed to find file <%s>",
         dev_table[ dev_number ].filename );
      bwb_error( bwb_ebuf );
#else
      sprintf( bwb_ebuf, ERR_OPENFILE,
         dev_table[ dev_number ].filename );
      bwb_error( bwb_ebuf );
#endif
      return NULL;
      }

   * var_findnval( &nvar, nvar.array_pos ) = (bnumber) statbuf.st_size; */

/* #else */  /* Removed by JBV, no longer needed */

   /* * var_findnval( &nvar, nvar.array_pos ) = (bnumber) FALSE; */
   * var_findnval( &nvar, nvar.array_pos ) =
      (bnumber) dev_table[ dev_number ].lof; /* JBV */

/* #endif */  /* Removed by JBV, no longer needed */

   return &nvar;
   }

#endif					/* MS_FUNCS */

/***************************************************************

        FUNCTION:       fnc_test()

        DESCRIPTION:    This is a test function, developed in
                        order to test argument passing to
                        BASIC functions.

***************************************************************/

#if INTENSIVE_DEBUG
#if ANSI_C
struct bwb_variable *
fnc_test( int argc, struct bwb_variable *argv, int unique_id )
#else
struct bwb_variable *
fnc_test( argc, argv, unique_id )
   int argc;
   struct bwb_variable *argv;
   int unique_id;
#endif
   {
   register int c;
   static struct bwb_variable rvar;
   static char *tbuf;
   static int init = FALSE;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &rvar, NUMBER );

      /* Revised to CALLOC pass-thru call by JBV */
      if ( ( tbuf = CALLOC( MAXSTRINGSIZE + 1, sizeof( char ), "fnc_test" )) == NULL )
         {
#if PROG_ERRORS
         bwb_error( "in fnc_test(): failed to get memory for tbuf" );
#else
         bwb_error( err_getmem );
#endif
         }
      }

   sprintf( bwb_ebuf, "TEST function: received %d arguments: \n", argc );
   prn_xprintf( stderr, bwb_ebuf );

   for ( c = 0; c < argc; ++c )
      {
      str_btoc( tbuf, var_getsval( &argv[ c ] ) );
      sprintf( bwb_ebuf, "                  arg %d (%c): <%s> \n", c,
	 argv[ c ].type, tbuf );
      prn_xprintf( stderr, bwb_ebuf );
      }

   return &rvar;

   }
#endif

/***************************************************************

        FUNCTION:       fnc_checkargs()

        DESCRIPTION:    This C function checks the arguments to
			functions.

***************************************************************/

#if PROG_ERRORS
#else
#if ANSI_C
int
fnc_checkargs( int argc, struct bwb_variable *argv, int min, int max )
#else
int
fnc_checkargs( argc, argv, min, max )
   int argc;
   struct bwb_variable *argv;
   int min;
   int max;
#endif
   {

   if ( argc < min )
      {
      bwb_error( err_syntax );
      return FALSE;
      }
   if ( argc > max )
      {
      bwb_error( err_syntax );
      return FALSE;
      }

   return TRUE;

   }
#endif

/***************************************************************

        FUNCTION:       fnc_fncs()

        DESCRIPTION:    This C function is used for debugging
                        purposes; it prints a list of all defined
                        functions.

	SYNTAX:		FNCS

***************************************************************/

#if PERMANENT_DEBUG

#if ANSI_C
struct bwb_line *
bwb_fncs( struct bwb_line *l )
#else
struct bwb_line *
bwb_fncs( l )
   struct bwb_line *l;
#endif
   {
   struct bwb_function *f;

   for ( f = CURTASK fnc_start.next; f != &CURTASK fnc_end; f = f->next )
      {
      sprintf( bwb_ebuf, "%s\t%c \n", f->name, f->type );
      prn_xprintf( stderr, bwb_ebuf );
      }

   return bwb_zline( l );

   }
#endif

