/****************************************************************

        bwb_fnc.c       Function Interpretation Routines
                        for Bywater BASIC Interpreter

                        Copyright (c) 1992, Ted A. Campbell

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

****************************************************************/

#define FSTACKSIZE      32

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <math.h>
#include <time.h>
#include "bwbasic.h"
#include "bwb_mes.h"

static time_t t;
static struct tm *lt;

struct bwb_function fnc_start, fnc_end;

int ufsc = -1;                   /* user function stack counter */

struct bwb_function bwb_prefuncs[ FUNCTIONS ] =
   {
   { "ABS",     DOUBLE,         1,  (struct user_fnc *) NULL,  fnc_abs,        (struct bwb_function *) NULL    },
   { "DATE$",   STRING,         0,  (struct user_fnc *) NULL,  fnc_date,       (struct bwb_function *) NULL    },
   { "TIME$",   STRING,         0,  (struct user_fnc *) NULL,  fnc_time,       (struct bwb_function *) NULL    },
   { "ATN",     DOUBLE,         1,  (struct user_fnc *) NULL,  fnc_atn,        (struct bwb_function *) NULL    },
   { "ACOS",     DOUBLE,         1,  (struct user_fnc *) NULL,  fnc_acos,        (struct bwb_function *) NULL    },
   { "COS",     DOUBLE,         1,  (struct user_fnc *) NULL,  fnc_cos,        (struct bwb_function *) NULL    },
   { "LOG",     DOUBLE,         1,  (struct user_fnc *) NULL,  fnc_log,        (struct bwb_function *) NULL    },
   { "ASIN",     DOUBLE,         1,  (struct user_fnc *) NULL,  fnc_acos,        (struct bwb_function *) NULL    },
   { "SIN",     DOUBLE,         1,  (struct user_fnc *) NULL,  fnc_sin,        (struct bwb_function *) NULL    },
   { "SQR",     DOUBLE,         1,  (struct user_fnc *) NULL,  fnc_sqr,        (struct bwb_function *) NULL    },
   { "TAN",     DOUBLE,         1,  (struct user_fnc *) NULL,  fnc_tan,        (struct bwb_function *) NULL    },
   { "SGN",     DOUBLE,         1,  (struct user_fnc *) NULL,  fnc_sgn,        (struct bwb_function *) NULL    },
   { "INT",     DOUBLE,         1,  (struct user_fnc *) NULL,  fnc_int,        (struct bwb_function *) NULL    },
   { "RND",     DOUBLE,         0,  (struct user_fnc *) NULL,  fnc_rnd,        (struct bwb_function *) NULL    },
   { "CHR$",    DOUBLE,         0,  (struct user_fnc *) NULL,  fnc_chr,        (struct bwb_function *) NULL    },
   { "TAB",     STRING,		1,  (struct user_fnc *) NULL,  fnc_tab,        (struct bwb_function *) NULL    },
   { "SPC",     STRING,		1,  (struct user_fnc *) NULL,  fnc_spc,        (struct bwb_function *) NULL    },
   { "SPACE$",  STRING,		1,  (struct user_fnc *) NULL,  fnc_space,      (struct bwb_function *) NULL    },
   { "STRING$", STRING,		1,  (struct user_fnc *) NULL,  fnc_string,     (struct bwb_function *) NULL    },
   { "MID$",    STRING,		3,  (struct user_fnc *) NULL,  fnc_mid,        (struct bwb_function *) NULL    },
   { "LEFT$",   STRING,		2,  (struct user_fnc *) NULL,  fnc_left,       (struct bwb_function *) NULL    },
   { "RIGHT$",  STRING,		2,  (struct user_fnc *) NULL,  fnc_right,      (struct bwb_function *) NULL    },
   { "TIMER",   SINGLE,         0,  (struct user_fnc *) NULL,  fnc_timer,      (struct bwb_function *) NULL    },
   { "VAL",     INTEGER,        1,  (struct user_fnc *) NULL,  fnc_val,        (struct bwb_function *) NULL    },
   { "POS",     INTEGER,        0,  (struct user_fnc *) NULL,  fnc_pos,        (struct bwb_function *) NULL    },
   { "ERR",     INTEGER,        0,  (struct user_fnc *) NULL,  fnc_err,        (struct bwb_function *) NULL    },
   { "ERL",     INTEGER,        0,  (struct user_fnc *) NULL,  fnc_erl,        (struct bwb_function *) NULL    },
   { "LEN",     INTEGER,        1,  (struct user_fnc *) NULL,  fnc_len,        (struct bwb_function *) NULL    },
   { "LOC",     INTEGER,        1,  (struct user_fnc *) NULL,  fnc_loc,        (struct bwb_function *) NULL    },
   { "LOF",     DOUBLE,         1,  (struct user_fnc *) NULL,  fnc_lof,        (struct bwb_function *) NULL    },
   { "EOF",     DOUBLE,         1,  (struct user_fnc *) NULL,  fnc_eof,        (struct bwb_function *) NULL    },
   { "CSNG",    SINGLE,         1,  (struct user_fnc *) NULL,  fnc_csng,       (struct bwb_function *) NULL    },
   { "EXP",     SINGLE,         1,  (struct user_fnc *) NULL,  fnc_exp,        (struct bwb_function *) NULL    },
   { "INSTR",   INTEGER,        1,  (struct user_fnc *) NULL,  fnc_instr,      (struct bwb_function *) NULL    },
   { "STR$",    STRING,         1,  (struct user_fnc *) NULL,  fnc_str,        (struct bwb_function *) NULL    },
   { "HEX$",    STRING,         1,  (struct user_fnc *) NULL,  fnc_hex,        (struct bwb_function *) NULL    },
   { "OCT$",    STRING,         1,  (struct user_fnc *) NULL,  fnc_oct,        (struct bwb_function *) NULL    },
   { "CINT",    SINGLE,         1,  (struct user_fnc *) NULL,  fnc_cint,       (struct bwb_function *) NULL    },
   { "ASC",     SINGLE,         1,  (struct user_fnc *) NULL,  fnc_asc,        (struct bwb_function *) NULL    },
   { "ENVIRON$",STRING,         1,  (struct user_fnc *) NULL,  fnc_environ,    (struct bwb_function *) NULL    },
   #if INTENSIVE_DEBUG
   { "TEST",    DOUBLE,         2,  (struct user_fnc *) NULL,  fnc_test,       (struct bwb_function *) NULL    },
   #endif
   { "MKD$",    STRING,         1,  (struct user_fnc *) NULL,  fnc_mkd,        (struct bwb_function *) NULL    },
   { "MKI$",    STRING,         1,  (struct user_fnc *) NULL,  fnc_mki,        (struct bwb_function *) NULL    },
   { "MKS$",    STRING,         1,  (struct user_fnc *) NULL,  fnc_mks,        (struct bwb_function *) NULL    },
   { "CVD",     DOUBLE,         1,  (struct user_fnc *) NULL,  fnc_cvd,        (struct bwb_function *) NULL    },
   { "CVS",     SINGLE,         1,  (struct user_fnc *) NULL,  fnc_cvs,        (struct bwb_function *) NULL    },
   { "CVI",     INTEGER,        1,  (struct user_fnc *) NULL,  fnc_cvi,        (struct bwb_function *) NULL    }
   };

/***************************************************************

        FUNCTION:       fnc_init()

        DESCRIPTION:    This command initializes the function
                        linked list, placing all predefined functions
                        in the list.

***************************************************************/

int
fnc_init()
   {
   register int n;
   struct bwb_function *f;

   strcpy( fnc_start.name, "FNC_START" );
   fnc_start.type = 'X';
   fnc_start.vector = fnc_null;
   strcpy( fnc_end.name, "FNC_END" );
   fnc_end.type = 'x';
   fnc_end.vector = fnc_null;
   fnc_end.next = &fnc_end;

   f = &fnc_start;

   /* now go through each of the preestablished functions and set up
      links between them; from this point the program address the functions
      only as a linked list (not as an array) */

   for ( n = 0; n < FUNCTIONS; ++n )
      {
      f->next = &( bwb_prefuncs[ n ] );
      f = f->next;
      }

   /* link the last pointer to the end; this completes the list */

   f->next = &fnc_end;

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

struct bwb_function *
fnc_find( char *buffer )
   {
   struct bwb_function * f;
   register int n;
   static char *tbuf;
   static int init = FALSE;

   /* get memory for temporary buffer if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      if ( ( tbuf = calloc( MAXSTRINGSIZE + 1, sizeof( char ) )) == NULL )
         {
         bwb_error( err_getmem );
         }
      }

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in fnc_find(): called for <%s> ", buffer );
   bwb_debug( bwb_ebuf );
   #endif

   for ( n = 0; buffer[ n ] != 0; ++n )
      {
      if ( islower( buffer[ n ] ) )
         {
         tbuf[ n ] = toupper( buffer[ n ] );
         }
      else
         {
         tbuf[ n ] = buffer[ n ];
         }
      }
   tbuf[ n ] = 0;

   for ( f = fnc_start.next; f != &fnc_end; f = f->next )
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

        FUNCTION:       bwb_deffn()

        DESCRIPTION:    This C function implements the BASIC
                        DEF FNxx statement.

***************************************************************/

struct bwb_line *
bwb_deffn( struct bwb_line *l )
   {
   register int n;
   int loop, arguments, p;
   struct bwb_function *f, *fncpos;
   static char *tbuf;
   static int init = FALSE;

   /* get memory for temporary buffer if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      if ( ( tbuf = calloc( MAXSTRINGSIZE + 1, sizeof( char ) )) == NULL )
         {
         bwb_error( err_getmem );
         }
      }

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_deffn(): entered function." );
   bwb_debug( bwb_ebuf );
   #endif

   /* test for appropriate function name */

   exp_getvfname( &( l->buffer[ l->startpos ] ), tbuf );     /* name in tbuf */

   for ( n = 0; tbuf[ n ] != '\0'; ++n )
      {
      if ( islower( tbuf[ n ] ) != FALSE )
         {
         tbuf[ n ] = toupper( tbuf[ n ] );
         }
      }

   if ( strncmp( tbuf, "FN", (size_t) 2 ) != 0 )
      {
      #if PROG_ERRORS
      sprintf( bwb_ebuf, "at line %d: User-defined function name must begin with FN.",
         l->number );
      bwb_error( bwb_ebuf );
      #else
      bwb_error( err_syntax );
      #endif
      l->next->position = 0;
      return l->next;
      }

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_deffn(): function name is <%s>", tbuf );
   bwb_debug( bwb_ebuf );
   #endif

   /* Allocate memory for a new function structure */

   if ( ( f = (struct bwb_function *) calloc( (size_t) 1, sizeof( struct bwb_function ) )) == NULL )
      {
      #if PROG_ERRORS
      sprintf( bwb_ebuf, "Failed to find memory for function structure." );
      bwb_error( bwb_ebuf );
      #else
      bwb_error( err_getmem );
      #endif
      l->next->position = 0;
      return l->next;
      }

   /* Allocate memory for a user function structure */

   if ( ( f->ufnc = (struct user_fnc *) calloc( (size_t) 1, sizeof( struct user_fnc ) )) == NULL )
      {
      #if PROG_ERRORS
      sprintf( bwb_ebuf, "Failed to find memory for function structure." );
      bwb_error( bwb_ebuf );
      #else
      bwb_error( err_getmem );
      #endif
      l->next->position = 0;
      return l->next;
      }

   /* Set some values for the new function */

   strncpy( f->name, tbuf, (size_t) MAXVARNAMESIZE );

   switch( f->name[ strlen( f->name ) - 1 ] )
      {
      case STRING:
      case DOUBLE:
      case INTEGER:
         f->type = f->name[ strlen( f->name ) - 1 ];
         break;
      default:
         f->type = SINGLE;
         break;
      }

   f->vector = NULL;
   f->arguments = 0;

   /* determine if there are arguments */

   loop = TRUE;
   arguments = FALSE;
   l->position += strlen( f->name );
   while( loop == TRUE )
      {

      switch( l->buffer[ l->position ] )
         {
         case ' ':                      /* whitespace */
         case '\t':
            ++l->position;
            break;
         case '(':                      /* begin parenthesis = arguments */
            ++l->position;
            loop = FALSE;
            arguments = TRUE;
            break;
         case '\n':                     /* unexpected end of line */
         case '\r':
         case '\0':
            #if PROG_ERRORS
            sprintf( bwb_ebuf, "at line %d: Unexpected end of line", l->number );
            bwb_error( bwb_ebuf );
            #else
            bwb_error( err_syntax );
            #endif
            l->next->position = 0;
            return l->next;
         default:                       /* any other character = no arguments */
            loop = FALSE;
            break;
         }

      }

   /* identify arguments */

   if ( arguments == TRUE )
      {

      loop = TRUE;
      f->arguments = 0;                              /* use as counter */
      p = 0;
      f->ufnc->user_vns[ f->arguments ][ 0 ] = '\0';
      while ( loop == TRUE )
         {
         switch( l->buffer[ l->position ] )
            {
            case ' ':                           /* whitespace */
            case '\t':
               ++l->position;
               break;
            case '\0':                          /* unexpected end of line */
            case '\n':
            case '\r':
               #if PROG_ERRORS
               sprintf( bwb_ebuf, "at line %d: Unexpected end of line.",
                  l->number );
               bwb_error( bwb_ebuf );
               #else
               bwb_error( err_syntax );
               #endif
               l->next->position = 0;
               return l->next;
            case ')':                           /* end of argument list */
               ++f->arguments;                  /* returns total number of arguments */
               ++l->position;                   /* advance beyond parenthesis */
               loop = FALSE;
               break;

            case ',':                           /* end of one argument */

               ++f->arguments;
               ++l->position;
               p = 0;
               f->ufnc->user_vns[ f->arguments ][ 0 ] = '\0';
               break;
            default:

               f->ufnc->user_vns[ f->arguments ][ p ] = l->buffer[ l->position ];
               ++l->position;
               ++p;
               f->ufnc->user_vns[ f->arguments ][ p ] = '\0';
               break;
            }
         }

      }

   /* else no arguments were found */

   else
      {
      f->arguments = 0;
      }

   #if INTENSIVE_DEBUG
   for ( n = 0; n < f->arguments; ++n )
      {
      sprintf( bwb_ebuf, "in bwb_deffn(): argument <%d> name <%s>.",
         n, f->ufnc->user_vns[ n ] );
      bwb_debug( bwb_ebuf );
      }
   #endif

   /* find the string to be interpreted */

   loop = TRUE;
   arguments = FALSE;
   while( loop == TRUE )
      {
      switch( l->buffer[ l->position ] )
         {
         case '\0':                     /* unexpected end of line */
         case '\n':
         case '\r':
            #if PROG_ERRORS
            sprintf( bwb_ebuf, "at line %d: Unexpected end of line.",
               l->number );
            bwb_error( bwb_ebuf );
            #else
            bwb_error( err_syntax );
            #endif
            l->next->position = 0;
            return l->next;
         case ' ':                      /* whitespace */
         case '\t':
            ++l->position;
            break;

         case '=':
            ++l->position;
            arguments = TRUE;
            break;
         default:
            loop = FALSE;
            break;
         }
      }

   /* if the equals sign was not detected, return error */

   if ( arguments == FALSE )
      {
      #if PROG_ERRORS
      sprintf( bwb_ebuf, "at line %d: Assignment operator (=) not found.",
         l->number );
      bwb_error( bwb_ebuf );
      #else
      bwb_error( err_syntax );
      #endif
      l->next->position = 0;
      return l->next;
      }

   /* write the string to be interpreted to the user function structure */

   strncpy( f->ufnc->int_line, &( l->buffer[ l->position ] ),
      (size_t) MAXSTRINGSIZE );

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_deffn(): line <%s>", f->ufnc->int_line );
   bwb_debug( bwb_ebuf );
   #endif

   /* Place the new function in the function linked list */

   for ( fncpos = &fnc_start; fncpos->next != &fnc_end; fncpos = fncpos->next )
      {
      ;
      }
   fncpos->next = f;
   f->next = &fnc_end;

   /* return */

   l->next->position = 0;
   return l->next;

   }

/***************************************************************

        FUNCTION:       fnc_intufnc()

        DESCRIPTION:    This C function interprets a user-defined
                        BASIC function.

***************************************************************/

struct bwb_variable *
fnc_intufnc( int argc, struct bwb_variable *argv, struct bwb_function *f )
   {
   register int n;
   int l_position, f_position;
   int written;
   bstring *b;
   struct exp_ese *e;
   static struct bwb_variable nvar;

   #if INTENSIVE_DEBUG
   sprintf( nvar.name, "intufnc variable" );
   #endif

   /* increment the user function stack counter */

   if ( ufsc >= UFNCSTACKSIZE )
      {
      #if PROG_ERRORS
      sprintf( bwb_ebuf, "exceeded user-defined function stack, level <%d>",
         ufsc );
      bwb_error( bwb_ebuf );
      #else
      bwb_error( err_overflow );
      #endif
      }

   ++ufsc;

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in fnc_intufnc(): interpreting user function <%s>",
      f->name );
   bwb_debug( bwb_ebuf );
   #endif

   /* print arguments to strings */

   for ( n = 1; n <= argc; ++n )
      {
      switch( argv[ n - 1 ].type )
         {
         case DOUBLE:
            sprintf( ufs[ ufsc ].args[ n - 1 ], "(%f)",
               var_getdval( &( argv[ n - 1 ] ) ));
            break;
         case SINGLE:
            sprintf( ufs[ ufsc ].args[ n - 1 ], "(%f)",
               var_getfval( &( argv[ n - 1 ] ) ));
            break;
         case INTEGER:
            sprintf( ufs[ ufsc ].args[ n - 1 ], "(%d)",
               var_getival( &( argv[ n - 1 ] ) ));
            break;
         case STRING:
            b = var_getsval( &( argv[ n - 1 ] ) );
            str_btoc( bwb_ebuf, b );
            sprintf( ufs[ ufsc ].args[ n - 1 ], "\"%s\"",
               bwb_ebuf );
            break;
         default:
            #if PROG_ERRORS
            sprintf( bwb_ebuf, "Unidentified variable type in argument to user function." );
            bwb_error( bwb_ebuf );
            #else
            bwb_error( err_mismatch );
            #endif
            return &nvar;
            }
      }

   #if INTENSIVE_DEBUG
   for ( n = 1; n <= argc; ++n )
      {
      sprintf( bwb_ebuf, "in fnc_intufnc(): arg string %d: <%s>.",
         n - 1, ufs[ ufsc ].args[ n - 1 ] );
      bwb_debug ( bwb_ebuf );
      }
   #endif

   /* copy the interpreted line to the buffer, substituting variable ufs[ ufsc ].args */

   ufs[ ufsc ].l_buffer[ 0 ] = '\0';
   l_position = 0;
   for ( f_position = 0; f->ufnc->int_line[ f_position ] != '\0'; ++f_position )
      {
      written = FALSE;
      for ( n = 0; n < argc; ++n )
         {
         if ( strncmp( &( f->ufnc->int_line[ f_position ] ), f->ufnc->user_vns[ n ],
            (size_t) strlen( f->ufnc->user_vns[ n ] ) ) == 0 )
            {
            strcat( ufs[ ufsc ].l_buffer, ufs[ ufsc ].args[ n ] );
            written = TRUE;
            f_position += strlen( f->ufnc->user_vns[ n ] + 1 );
            l_position += strlen( ufs[ ufsc ].args[ n ] );
            }

         }
      if ( written == FALSE )
         {
         ufs[ ufsc ].l_buffer[ l_position ] = f->ufnc->int_line[ f_position ];
         ++l_position;
         ufs[ ufsc ].l_buffer[ l_position ] = '\0';
         }
      }

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in fnc_intufnc(): reconstructed line: <%s>",
      ufs[ ufsc ].l_buffer );
   bwb_debug( bwb_ebuf );
   #endif

   /* parse */

   ufs[ ufsc ].position = 0;
   e = bwb_exp( ufs[ ufsc ].l_buffer, FALSE,
      &( ufs[ ufsc ].position ) );

   var_make( &nvar, e->type );

   switch( e->type )
      {
      case DOUBLE:
         * var_finddval( &nvar, nvar.array_pos ) = exp_getdval( e );
         break;
      case INTEGER:
         * var_findival( &nvar, nvar.array_pos ) = exp_getival( e );
         break;
      case STRING:
         str_btob( var_findsval( &nvar, nvar.array_pos ), 
            exp_getsval( e ) );
         break;
      default:
         * var_findfval( &nvar, nvar.array_pos ) = exp_getfval( e );
         break;
      }

   /* decrement the user function stack counter */

   --ufsc;

   return &nvar;

   }

/***************************************************************

        FUNCTION:       fnc_null()

        DESCRIPTION:    This is a null function that can be used
                        to fill in a required function-structure
                        pointer when needed.

***************************************************************/

struct bwb_variable *
fnc_null( int argc, struct bwb_variable *argv )
   {
   static struct bwb_variable nvar;
   static int init = FALSE;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, INTEGER );
      }

   return &nvar;
   }

/***************************************************************


        FUNCTION:       fnc_date()

        DESCRIPTION:    This C function implements the BASIC
                        predefined DATE$ function, returning
                        a string containing the year, month,
                        and day of the month.

***************************************************************/

struct bwb_variable *
fnc_date( int argc, struct bwb_variable *argv )
   {
   static struct bwb_variable nvar;
   static int init = FALSE;
   static char *tbuf;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, STRING );
      if ( ( tbuf = calloc( MAXSTRINGSIZE + 1, sizeof( char ) )) == NULL )
         {
         bwb_error( err_getmem );
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

***************************************************************/

struct bwb_variable *
fnc_time( int argc, struct bwb_variable *argv )
   {
   static struct bwb_variable nvar;
   static char *tbuf;
   static int init = FALSE;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, STRING );
      if ( ( tbuf = calloc( MAXSTRINGSIZE + 1, sizeof( char ) )) == NULL )
         {
         bwb_error( err_getmem );
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

        FUNCTION:       fnc_test()

        DESCRIPTION:    This is a test function, developed in
                        order to test argument passing to
                        BASIC functions.

***************************************************************/

#if INTENSIVE_DEBUG
struct bwb_variable *
fnc_test( int argc, struct bwb_variable *argv )
   {
   register int c;
   static struct bwb_variable rvar;
   static char *tbuf;
   static int init = FALSE;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &rvar, SINGLE );
      if ( ( tbuf = calloc( MAXSTRINGSIZE + 1, sizeof( char ) )) == NULL )
         {
         bwb_error( err_getmem );
         }
      }

   fprintf( stdout, "TEST function: received %d arguments: \n", argc );

   for ( c = 0; c < argc; ++c )
      {
      str_btoc( tbuf, var_getsval( &argv[ c ] ) );
      fprintf( stdout, "                  arg %d (%c): <%s> \n", c,
         argv[ c ].type, tbuf );
      }

   return &rvar;

   }
#endif

/***************************************************************

        FUNCTION:       fnc_rnd()

        DESCRIPTION:    This C function implements the BASIC
                        predefined RND function, returning a
                        pseudo-random number in the range
                        0 to 1.  It is affected by the RANDOMIZE
                        command statement.

***************************************************************/

struct bwb_variable *
fnc_rnd( int argc, struct bwb_variable *argv  )
   {
   static struct bwb_variable nvar;
   static int init = FALSE;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, SINGLE );
      }

   * var_findfval( &nvar, nvar.array_pos ) = (float) rand() / RAND_MAX;

   return &nvar;
   }

/***************************************************************

        FUNCTION:       fnc_chr()

        DESCRIPTION:    This C function implements the BASIC
                        predefined CHR$ function, returning a
                        string containing the single character
                        whose ASCII value is the argument to
                        this function.

***************************************************************/

struct bwb_variable *
fnc_chr( int argc, struct bwb_variable *argv  )
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

   tbuf[ 0 ] = (char) var_getival( &( argv[ 0 ] ) );
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

        FUNCTION:       fnc_mid()

        DESCRIPTION:    This C function implements the BASIC
                        predefined MID$ function

***************************************************************/

struct bwb_variable *
fnc_mid( int argc, struct bwb_variable *argv  )
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
   target_counter = var_getival( &( argv[ 1 ] ) ) - 1;
   if ( target_counter > strlen( target_string ))
      {
      tbuf[ 0 ] = '\0';
      str_ctob( var_findsval( &nvar, nvar.array_pos ), tbuf );
      return &nvar;
      }

   if ( argc == 3 )
      {
      num_spaces = var_getival( &( argv[ 2 ] ));
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

***************************************************************/

struct bwb_variable *
fnc_left( int argc, struct bwb_variable *argv  )
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
   num_spaces = var_getival( &( argv[ 1 ] ));

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

***************************************************************/

struct bwb_variable *
fnc_right( int argc, struct bwb_variable *argv  )
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
   target_counter = strlen( target_string ) - var_getival( &( argv[ 1 ] ));
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

        FUNCTION:       fnc_timer()

        DESCRIPTION:    This C function implements the BASIC
                        predefined TIMER function

***************************************************************/

struct bwb_variable *
fnc_timer( int argc, struct bwb_variable *argv  )
   {
   static struct bwb_variable nvar;
   static time_t now;
   static int init = FALSE;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, SINGLE );
      }

   time( &now );
   * var_findfval( &nvar, nvar.array_pos )
      = (float) fmod( (double) now, (double) (60*60*24));

   return &nvar;
   }

/***************************************************************

        FUNCTION:       fnc_val()

        DESCRIPTION:

***************************************************************/

struct bwb_variable *
fnc_val( int argc, struct bwb_variable *argv )
   {
   static struct bwb_variable nvar;
   static char *tbuf;
   static int init = FALSE;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, SINGLE );
      if ( ( tbuf = calloc( MAXSTRINGSIZE + 1, sizeof( char ) )) == NULL )
         {
         bwb_error( err_getmem );
         }
      }

   /* check arguments */

   #if PROG_ERRORS
   if ( argc < 1 )
      {
      sprintf( bwb_ebuf, "Not enough arguments to function VAL()" );
      bwb_error( bwb_ebuf );
      return NULL;
      }
   else if ( argc > 1 )
      {
      sprintf( bwb_ebuf, "Too many parameters (%d) to function VAL().",
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

   else if ( argv[ 0 ].type != STRING )
      {
      #if PROG_ERRORS
      sprintf( bwb_ebuf, "Argument to function VAL() must be a string.",
         argc );
      bwb_error( bwb_ebuf );
      #else
      bwb_error( err_mismatch );
      #endif
      return NULL;
      }

   /* read the value */

   str_btoc( tbuf, var_getsval( &( argv[ 0 ] ) ));
   sscanf( tbuf, "%f",
       var_findfval( &nvar, nvar.array_pos ) );

   return &nvar;
   }

/***************************************************************

        FUNCTION:       fnc_len()

        DESCRIPTION:

***************************************************************/

struct bwb_variable *
fnc_len( int argc, struct bwb_variable *argv )
   {
   static struct bwb_variable nvar;
   static int init = FALSE;
   static char *tbuf;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, INTEGER );
      if ( ( tbuf = calloc( MAXSTRINGSIZE + 1, sizeof( char ) )) == NULL )
         {
         bwb_error( err_getmem );
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
   * var_findival( &nvar, nvar.array_pos )
      = strlen( tbuf );

   return &nvar;
   }

/***************************************************************

        FUNCTION:       fnc_hex()

        DESCRIPTION:

***************************************************************/

struct bwb_variable *
fnc_hex( int argc, struct bwb_variable *argv )
   {
   static struct bwb_variable nvar;
   static char *tbuf;
   static int init = FALSE;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, STRING );
      if ( ( tbuf = calloc( MAXSTRINGSIZE + 1, sizeof( char ) )) == NULL )
         {
         bwb_error( err_getmem );
         }
      }

   /* check parameters */

   #if PROG_ERRORS
   if ( argc < 1 )
      {
      sprintf( bwb_ebuf, "Not enough parameters (%d) to function HEX$().",
         argc );
      bwb_error( bwb_ebuf );
      return NULL;
      }
   else if ( argc > 1 )
      {
      sprintf( bwb_ebuf, "Too many parameters (%d) to function HEX$().",
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

   /* format as hex integer */

   sprintf( tbuf, "%X", (int) trnc_int( (double) var_getfval( &( argv[ 0 ] )) ) );
   str_ctob( var_findsval( &nvar, nvar.array_pos ), tbuf );
   return &nvar;
   }

/***************************************************************

        FUNCTION:       fnc_oct()

        DESCRIPTION:	This C function implements the BASIC
			OCT$() function.

***************************************************************/

struct bwb_variable *
fnc_oct( int argc, struct bwb_variable *argv )
   {
   static struct bwb_variable nvar;
   static char *tbuf;
   static int init = FALSE;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, STRING );
      if ( ( tbuf = calloc( MAXSTRINGSIZE + 1, sizeof( char ) )) == NULL )
         {
         bwb_error( err_getmem );
         }
      }

   /* check parameters */

   #if PROG_ERRORS
   if ( argc < 1 )
      {
      sprintf( bwb_ebuf, "Not enough parameters (%d) to function OCT$().",
         argc );
      bwb_error( bwb_ebuf );
      return NULL;
      }
   else if ( argc > 1 )
      {
      sprintf( bwb_ebuf, "Too many parameters (%d) to function OCT$().",
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

   /* format as octal integer */

   sprintf( tbuf, "%o", var_getival( &( argv[ 0 ] ) ) );
   str_ctob( var_findsval( &nvar, nvar.array_pos ), tbuf );
   return &nvar;
   }

/***************************************************************

        FUNCTION:       fnc_asc()

        DESCRIPTION:    This function implements the predefined
			BASIC ASC() function.

***************************************************************/

struct bwb_variable *
fnc_asc( int argc, struct bwb_variable *argv )
   {
   static struct bwb_variable nvar;
   static char *tbuf;
   static int init = FALSE;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, INTEGER );
      if ( ( tbuf = calloc( MAXSTRINGSIZE + 1, sizeof( char ) )) == NULL )
         {
         bwb_error( err_getmem );
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
      sprintf( bwb_ebuf, "Argument to function ASC() must be a string.",
         argc );
      bwb_error( bwb_ebuf );
      #else
      bwb_error( err_mismatch );
      #endif
      return NULL;
      }

   /* assign ASCII value of first character in the buffer */

   str_btoc( tbuf, var_findsval( &( argv[ 0 ] ), argv[ 0 ].array_pos ) );
   * var_findival( &nvar, nvar.array_pos ) = (int) tbuf[ 0 ];

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

***************************************************************/

struct bwb_variable *
fnc_string( int argc, struct bwb_variable *argv )
   {
   static struct bwb_variable nvar;
   int length;
   register int i;
   char c;
   struct bwb_variable *v;
   static char *tbuf;
   static int init = FALSE;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, STRING );
      if ( ( tbuf = calloc( MAXSTRINGSIZE + 1, sizeof( char ) )) == NULL )
         {
         bwb_error( err_getmem );
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
   length = var_getival( &( argv[ 0 ] ));

   if ( argv[ 1 ].type == STRING )
      {
      str_btoc( tbuf, var_getsval( &( argv[ 1 ] )));
      c = tbuf[ 0 ];
      }
   else
      {
      c = (char) var_getival( &( argv[ 1 ] ) );
      }

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in fnc_string(): argument <%s> arg type <%c>, length <%d>",
      argv[ 1 ].string, argv[ 1 ].type, length );
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

        FUNCTION:       fnc_environ()

        DESCRIPTION:    This C function implements the BASIC
			ENVIRON$() function.

***************************************************************/

struct bwb_variable *
fnc_environ( int argc, struct bwb_variable *argv )
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

   strcpy( tmp, getenv( tbuf ));
   str_ctob( var_findsval( &nvar, nvar.array_pos ), tmp );

   /* return address of nvar */

   return &nvar;

   }

/***************************************************************

        FUNCTION:       fnc_instr()

        DESCRIPTION:    

***************************************************************/

struct bwb_variable *
fnc_instr( int argc, struct bwb_variable *argv )
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
      var_make( &nvar, INTEGER );
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
      start_pos = var_getival( &( argv[ n_pos ] ) ) - 1;
      }
   else
      {
      start_pos = 0;
      }

   /* get x and y strings */

   str_btoc( xbuf, var_getsval( &( argv[ x_pos ] ) ) );
   str_btoc( ybuf, var_getsval( &( argv[ y_pos ] ) ) );

   /* now search for match */

   for ( n = start_pos; n < strlen( xbuf ); ++n )
      {
      if ( strncmp( &( xbuf[ n ] ), ybuf, strlen( ybuf ) ) == 0 )
         {
         * var_findival( &nvar, nvar.array_pos ) = n + 1;
         return &nvar;
         }
      }

   /* match not found */
      
   * var_findival( &nvar, nvar.array_pos ) = 0;
   return &nvar;

   }

/***************************************************************

        FUNCTION:       fnc_str()

        DESCRIPTION:    

***************************************************************/

struct bwb_variable *
fnc_str( int argc, struct bwb_variable *argv )
   {
   static struct bwb_variable nvar;
   static char *tbuf;
   static int init = FALSE;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, STRING );
      if ( ( tbuf = calloc( MAXSTRINGSIZE + 1, sizeof( char ) )) == NULL )
         {
         bwb_error( err_getmem );
         }
      }

   /* check parameters */

   #if PROG_ERRORS
   if ( argc < 1 )
      {
      sprintf( bwb_ebuf, "Not enough parameters (%d) to function STR$().",
         argc );
      bwb_error( bwb_ebuf );
      return NULL;
      }
   else if ( argc > 1 )
      {
      sprintf( bwb_ebuf, "Too many parameters (%d) to function STR$().",
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

   /* format as decimal number */

   sprintf( tbuf, " %.*f", prn_precision( &( argv[ 0 ] ) ), 
      var_getfval( &( argv[ 0 ] ) ) ); 
   str_ctob( var_findsval( &nvar, nvar.array_pos ), tbuf );

   return &nvar;
   }

/***************************************************************

        FUNCTION:       fnc_checkargs()

        DESCRIPTION:    This C function checks the arguments to
			functions.

***************************************************************/

#if PROG_ERRORS
#else
int
fnc_checkargs( int argc, struct bwb_variable *argv, int min, int max )
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

***************************************************************/

#if PERMANENT_DEBUG
struct bwb_line *
bwb_fncs( struct bwb_line *l )
   {
   struct bwb_function *f;

   for ( f = fnc_start.next; f != &fnc_end; f = f->next )
      {
      fprintf( stdout, "%s\t%c \n", f->name, f->type );
      }

   l->next->position = 0;
   return l->next;

   }
#endif
