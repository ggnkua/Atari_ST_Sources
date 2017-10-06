/***************************************************************

        bwb_inp.c       Input Routines
                        for Bywater BASIC Interpreter

                        Commands:       DATA
                                        READ
                                        RESTORE
                                        INPUT
                                        LINE INPUT

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

/* Declarations of functions visible to this file only */

#if ANSI_C
static struct bwb_line *bwb_xinp( struct bwb_line *l, FILE *f );
static struct bwb_line *inp_str( struct bwb_line *l, char *buffer,
   char *var_list, int *position );
static int inp_const( char *m_buffer, char *s_buffer, int *position );
static int inp_assign( char *b, struct bwb_variable *v );
static int inp_advws( FILE *f );
static int inp_xgetc( FILE *f, int is_string );
static int inp_eatcomma( FILE *f );
static bnumber inp_numconst( char *expression ); /* JBV */
#else
static struct bwb_line *bwb_xinp();
static struct bwb_line *inp_str();
static int inp_const();
static int inp_assign();
static int inp_advws();
static int inp_xgetc();
static int inp_eatcomma();
static bnumber inp_numconst(); /* JBV */
#endif

static char_saved = FALSE;
static cs;
static int last_inp_adv_rval = FALSE; /* JBV */

/***************************************************************

        FUNCTION:       bwb_read()

        DESCRIPTION:    This function implements the BASIC READ
                        statement.

        SYNTAX:         READ variable[, variable...]

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_read( struct bwb_line *l )
#else
struct bwb_line *
bwb_read( l )
   struct bwb_line *l;
#endif
   {
   int pos;
   register int n;
   int main_loop, adv_loop;
   struct bwb_variable *v;
   int n_params;                         /* number of parameters */
   int *pp;                              /* pointer to parameter values */
   char tbuf[ MAXSTRINGSIZE + 1 ];

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_read(): buffer <%s>",
      &( l->buffer[ l->position ]));
   bwb_debug( bwb_ebuf );
#endif

   /* Process each variable read from the READ statement */

   main_loop = TRUE;
   while ( main_loop == TRUE )
      {

      /* first check position in l->buffer and advance beyond whitespace */

      adv_loop = TRUE;
      while( adv_loop == TRUE )
         {

#if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in bwb_read() adv_loop char <%d> = <%c>",
            l->buffer[ l->position ], l->buffer[ l->position ] );
         bwb_debug( bwb_ebuf );
#endif

         switch ( l->buffer[ l->position ] )
            {
            case ',':                   /* comma delimiter */
            case ' ':                   /* whitespace */
            case '\t':
               ++l->position;
               break;
            case ':':                   /* end of line segment */
	    case '\n':                  /* end of line */
            case '\r':
            case '\0':
               adv_loop = FALSE;        /* break out of advance loop */
               main_loop = FALSE;       /* break out of main loop */
               break;
            default:                    /* anything else */
               adv_loop = FALSE;        /* break out of advance loop */
               break;
            }
         }

#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_read(): end of adv_loop <%d> main_loop <%d>",
         adv_loop, main_loop );
      bwb_debug( bwb_ebuf );
#endif

      /* be sure main_loop id still valid after checking the line */

      if ( main_loop == TRUE )
         {

         /* Read a variable name */

         bwb_getvarname( l->buffer, tbuf, &( l->position ) );
         inp_adv( l->buffer, &( l->position ) );
         v = var_find( tbuf );

#if INTENSIVE_DEBUG
	 sprintf( bwb_ebuf, "in bwb_read(): line <%d> variable <%s>",
	    l->number, v->name );
	 bwb_debug( bwb_ebuf );
	 sprintf( bwb_ebuf, "in bwb_read(): remaining line <%s>",
	    &( l->buffer[ l->position ] ) );
	 bwb_debug( bwb_ebuf );
#endif

         /* advance beyond whitespace or comma in data buffer */

         inp_adv( CURTASK data_line->buffer, &CURTASK data_pos );

         /* Advance to next line if end of buffer */

         switch( CURTASK data_line->buffer[ CURTASK data_pos ] )
            {
            case '\0':                     /* end of buffer */
            case '\n':
            case '\r':

               CURTASK data_line = CURTASK data_line->next;

               /* advance farther to line with DATA statement if necessary */

               pos = 0;
               line_start( CURTASK data_line->buffer, &pos,
                  &( CURTASK data_line->lnpos ),
                  &( CURTASK data_line->lnum ),
                  &( CURTASK data_line->cmdpos ),
                  &( CURTASK data_line->cmdnum ),
                  &( CURTASK data_line->startpos ) );
               CURTASK data_pos = CURTASK data_line->startpos;

#if INTENSIVE_DEBUG
               sprintf( bwb_ebuf, "in bwb_read(): current data line: <%s>",
                  CURTASK data_line->buffer );
               bwb_debug( bwb_ebuf );
#endif

               break;
            }

         while ( bwb_cmdtable[ CURTASK data_line->cmdnum ].vector != bwb_data )
            {

            if ( CURTASK data_line == &CURTASK bwb_end )
               {
               CURTASK data_line = CURTASK bwb_start.next;
               }

            else
               {
               CURTASK data_line = CURTASK data_line->next;
               }

            pos = 0;
            line_start( CURTASK data_line->buffer, &pos,
               &( CURTASK data_line->lnpos ),
               &( CURTASK data_line->lnum ),
               &( CURTASK data_line->cmdpos ),
               &( CURTASK data_line->cmdnum ),
               &( CURTASK data_line->startpos ) );
            CURTASK data_pos = CURTASK data_line->startpos;

#if INTENSIVE_DEBUG
            sprintf( bwb_ebuf, "in bwb_read(): advance to data line: <%s>",
               CURTASK data_line->buffer );
            bwb_debug( bwb_ebuf );
#endif

            }

         /* advance beyond whitespace in data buffer */

         adv_loop = TRUE;
         while ( adv_loop == TRUE )
            {
            switch( CURTASK data_line->buffer[ CURTASK data_pos ] )
               {
               case '\0':                       /* end of buffer */
               case '\n':
               case '\r':
                  bwb_error( err_od );
                  return bwb_zline( l );
               case ' ':                        /* whitespace */
               case '\t':
                  ++CURTASK data_pos;
                  break;
               default:
                  adv_loop = FALSE;             /* carry on */
                  break;
               }
            }

         /* now at last we have a variable in v that needs to be
            assigned data from the data_buffer at position CURTASK data_pos.
            What remains to be done is to get one single bit of data,
            a string constant or numerical constant, into the small
            buffer */

         inp_const( CURTASK data_line->buffer, tbuf, &CURTASK data_pos );

#if INTENSIVE_DEBUG
	 sprintf( bwb_ebuf, "in bwb_read(): data constant is <%s>", tbuf );
	 bwb_debug( bwb_ebuf );
#endif

         /* get parameters if the variable is dimensioned */

	 adv_ws( l->buffer, &( l->position ) );
	 if ( l->buffer[ l->position ] == '(' )
	    {
#if INTENSIVE_DEBUG
	    sprintf( bwb_ebuf, "in bwb_read(): variable <%s> is dimensioned",
	       v->name );
	    bwb_debug( bwb_ebuf );
#endif
            dim_getparams( l->buffer, &( l->position ), &n_params, &pp );
            for ( n = 0; n < v->dimensions; ++n )
               {
               v->array_pos[ n ] = pp[ n ];
               }
	    }
#if INTENSIVE_DEBUG
	 else
	    {
	    sprintf( bwb_ebuf, "in bwb_read(): variable <%s> is NOT dimensioned",
	       v->name );
	    bwb_debug( bwb_ebuf );
	    sprintf( bwb_ebuf, "in bwb_read(): remaining line <%s>",
	       &( l->buffer[ l->position ] ) );
	    bwb_debug( bwb_ebuf );
	    }
#endif

         /* finally assign the data to the variable */

         inp_assign( tbuf, v );

         }                              /* end of remainder of main loop */

      }                                 /* end of main_loop */

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_read(): exiting function, line <%s> ",
      &( l->buffer[ l->position ] ) );
   bwb_debug( bwb_ebuf );
#endif

   return bwb_zline( l );

   }

/***************************************************************

        FUNCTION:       bwb_data()

        DESCRIPTION:    This function implements the BASIC DATA
                        statement, although at the point at which
                        DATA statements are encountered, no
                        processing is done.  All actual processing
                        of DATA statements is accomplished by READ
                        (bwb_read()).

        SYNTAX:         DATA constant[, constant]...

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_data( struct bwb_line *l )
#else
struct bwb_line *
bwb_data( l )
   struct bwb_line *l;
#endif
   {

#if MULTISEG_LINES
   adv_eos( l->buffer, &( l->position ));
#endif

   return bwb_zline( l );
   }

/***************************************************************

        FUNCTION:       bwb_restore()

        DESCRIPTION:    This function implements the BASIC RESTORE
                        statement.

        SYNTAX:         RESTORE [line number]

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_restore( struct bwb_line *l )
#else
struct bwb_line *
bwb_restore( l )
   struct bwb_line *l;
#endif
   {
   struct bwb_line *r;
   struct bwb_line *r_line;
   int n;
   int pos;
   char tbuf[ MAXSTRINGSIZE + 1 ];

   /* get the first element beyond the starting position */

   adv_element( l->buffer, &( l->position ), tbuf );

   /* if the line is not a numerical constant, then there is no
      argument; set the current line to the first in the program */

   if ( is_numconst( tbuf ) != TRUE )
      {
      CURTASK data_line = &CURTASK bwb_start;
      CURTASK data_pos = 0;
#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_restore(): RESTORE w/ no argument " );
      bwb_debug( bwb_ebuf );
#endif
      return bwb_zline( l );
      }

   /* find the line */

   n = atoi( tbuf );

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_restore(): line for restore is <%d>", n );
   bwb_debug( bwb_ebuf );
#endif

   r_line = NULL;
   for ( r = CURTASK bwb_start.next; r != &CURTASK bwb_end; r = r->next )
      {

      if ( r->number == n )
         {
         r_line = r;
         }
      }

   if ( r_line == NULL )
      {
#if PROG_ERRORS
      sprintf( bwb_ebuf, "at line %d: Can't find line number for RESTORE.",
         l->number );
      bwb_error( bwb_ebuf );
#else
      sprintf( bwb_ebuf, err_lnnotfound, n );
      bwb_error( bwb_ebuf );
#endif
      return bwb_zline( l );
      }

   /* initialize variables for the line */

   pos = 0;
   line_start( r_line->buffer, &pos,
      &( r_line->lnpos ),
      &( r_line->lnum ),
      &( r_line->cmdpos ),
      &( r_line->cmdnum ),
      &( r_line->startpos ) );

   /* verify that line is a data statement */

   if ( bwb_cmdtable[ r_line->cmdnum ].vector != bwb_data )
      {
#if PROG_ERRORS
      sprintf( bwb_ebuf, "at line %d: Line %d is not a DATA statement.",
         l->number, r_line->number );
      bwb_error( bwb_ebuf );
#else
      bwb_error( err_syntax );
#endif
      return bwb_zline( l );
      }

   /* reassign CURTASK data_line */

   CURTASK data_line = r_line;
   CURTASK data_pos = CURTASK data_line->startpos;

   return bwb_zline( l );
   }

/***************************************************************

        FUNCTION:       bwb_input()

        DESCRIPTION:    This function implements the BASIC INPUT
                        statement.

        SYNTAX:         INPUT [;][prompt$;]variable[$,variable]...
                        INPUT#n variable[$,variable]...

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_input( struct bwb_line *l )
#else
struct bwb_line *
bwb_input( l )
   struct bwb_line *l;
#endif
   {
   FILE *fp;
   int pos;
   int req_devnumber;
   struct exp_ese *v;
   int is_prompt;
   int suppress_qm;
   static char tbuf[ MAXSTRINGSIZE + 1 ];
   static char pstring[ MAXSTRINGSIZE + 1 ];

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_input(): enter function" );
   bwb_debug( bwb_ebuf );
#endif

   pstring[ 0 ] = '\0';

#if COMMON_CMDS

   /* advance beyond whitespace and check for the '#' sign */

   adv_ws( l->buffer, &( l->position ) );

   if ( l->buffer[ l->position ] == '#' )
      {
      ++( l->position );
      adv_element( l->buffer, &( l->position ), tbuf );
      pos = 0;
      v = bwb_exp( tbuf, FALSE, &pos );
      adv_ws( l->buffer, &( l->position ) );
      if ( l->buffer[ l->position ] == ',' )
         {
         ++( l->position );
         }
      else
         {
#if PROG_ERRORS
         bwb_error( "in bwb_input(): no comma after#n" );
#else
         bwb_error( err_syntax );
#endif
         return bwb_zline( l );
         }

      req_devnumber = (int) exp_getnval( v );

#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_input(): requested device number <%d>",
         req_devnumber );
      bwb_debug( bwb_ebuf );
#endif

      /* check the requested device number */

      if ( ( req_devnumber < 0 ) || ( req_devnumber >= DEF_DEVICES ))
         {
#if PROG_ERRORS
         bwb_error( "in bwb_input(): Requested device number is out if range." );
#else
         bwb_error( err_devnum );
#endif
         return bwb_zline( l );
         }

      if ( ( dev_table[ req_devnumber ].mode == DEVMODE_CLOSED ) ||
         ( dev_table[ req_devnumber ].mode == DEVMODE_AVAILABLE ) )
         {
#if PROG_ERRORS
         bwb_error( "in bwb_input(): Requested device number is not open." );
#else
         bwb_error( err_devnum );
#endif

         return bwb_zline( l );
         }

      if ( dev_table[ req_devnumber ].mode != DEVMODE_INPUT )
         {
#if PROG_ERRORS
         bwb_error( "in bwb_input(): Requested device is not open for INPUT." );
#else
         bwb_error( err_devnum );
#endif

         return bwb_zline( l );
         }

      /* look up the requested device in the device table */

      fp = dev_table[ req_devnumber ].cfp;

      }
   else
      {
      fp = stdin;
      }

#else
   fp = stdin;
#endif				/* COMMON_CMDS */

   /* if input is not from stdin, then branch to bwb_xinp() */

   if ( fp != stdin )
      {
      return bwb_xinp( l, fp );
      }

   /* from this point we presume that input is from stdin */

   /* check for a semicolon or a quotation mark, not in
      first position: this should indicate a prompt string */

   suppress_qm = is_prompt = FALSE;

   adv_ws( l->buffer, &( l->position ) );

   switch( l->buffer[ l->position ] )
      {
      case '\"':
         is_prompt = TRUE;
         break;

      case ';':

         /* AGENDA: add code to suppress newline if a
            semicolon is used here; this may not be possible
            using ANSI C alone, since it has not functions for
            unechoed console input. */

         is_prompt = TRUE;
         ++l->position;
         break;

      case ',':

         /* QUERY: why is this code here? the question mark should
            be suppressed if a comma <follows> the prompt string. */

#if INTENSIVE_DEBUG
         bwb_debug( "in bwb_input(): found initial comma" );
#endif
         suppress_qm = TRUE;
         ++l->position;
         break;
      }

   /* get prompt string and print it */

   if ( is_prompt == TRUE )
      {

      /* get string element */

      inp_const( l->buffer, tbuf, &( l->position ) );

      /* advance past semicolon to beginning of variable */

      /*--------------------------------------------------------*/
      /* Since inp_const was just called and inp_adv is called  */
      /* within that, it will have already noted and passed the */
      /* comma by the time it gets here.  Therefore one must    */
      /* refer instead to the last returned value for inp_adv!  */
      /* (JBV, 10/95)                                           */
      /*--------------------------------------------------------*/
      /* suppress_qm = inp_adv( l->buffer, &( l->position ) ); */
      suppress_qm = last_inp_adv_rval;

      /* print the prompt string */

      strncpy( pstring, tbuf, MAXSTRINGSIZE );
      }                                      /* end condition: prompt string */

   /* print out the question mark delimiter unless it has been
      suppressed */

   if ( suppress_qm != TRUE )
      {
      strncat( pstring, "? ", MAXSTRINGSIZE );
      }

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_input(): ready to get input line" );
   bwb_debug( bwb_ebuf );
#endif

   /* read a line into the input buffer */

   bwx_input( pstring, tbuf );
   bwb_stripcr( tbuf );

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_input(): received line <%s>", tbuf );
   bwb_debug( bwb_ebuf );
   bwb_debug( "Press RETURN: " );
   getchar();
#endif

   /* reset print column to account for LF at end of fgets() */

   * prn_getcol( stdout ) = 1;

   return inp_str( l, tbuf, l->buffer, &( l->position ) );

   }

/***************************************************************

        FUNCTION:       bwb_xinp()

        DESCRIPTION:    This function does the bulk of processing
                        for INPUT#, and so is file independent.

***************************************************************/

#if ANSI_C
static struct bwb_line *
bwb_xinp( struct bwb_line *l, FILE *f )
#else
static struct bwb_line *
bwb_xinp( l, f )
   struct bwb_line *l;
   FILE *f;
#endif
   {
   int loop;
   struct bwb_variable *v;
   char c;
   register int n;
   int *pp;
   int n_params;
   char tbuf[ MAXSTRINGSIZE + 1 ];

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_xinp(): buffer <%s>",
      &( l->buffer[ l->position ] ) );
   bwb_debug( bwb_ebuf );
#endif

   /* loop through elements required */

   loop = TRUE;
   while ( loop == TRUE )
      {
      
      /* read a variable from the list */

      bwb_getvarname( l->buffer, tbuf, &( l->position ) );
      v = var_find( tbuf );

#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_xinp(): found variable name <%s>",
         v->name );
      bwb_debug( bwb_ebuf );
#endif

      /* read subscripts */

      adv_ws( l->buffer, &( l->position ) );
      if ( l->buffer[ l->position ] == '(' )
         {
#if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in bwb_xinp(): variable <%s> has dimensions",
            v->name );
         bwb_debug( bwb_ebuf );
#endif
         dim_getparams( l->buffer, &( l->position ), &n_params, &pp );
         for ( n = 0; n < v->dimensions; ++n )
            {
            v->array_pos[ n ] = pp[ n ];
            }
         }

      inp_advws( f );

      /* perform type-specific input */

      switch( v->type )
         {
         case STRING:
            if ( inp_xgetc( f, TRUE ) != '\"' )
               {
#if PROG_ERRORS
               sprintf( bwb_ebuf, "in bwb_xinp(): expected quotation mark" );
               bwb_error( bwb_ebuf );
#else
               bwb_error( err_mismatch );
#endif
               }
            n = 0;
            while ( ( c = (char) inp_xgetc( f, TRUE )) != '\"' )
               {
               tbuf[ n ] = c;
               ++n;
               tbuf[ n ] = '\0';
               }
            str_ctob( var_findsval( v, v->array_pos ), tbuf );
#if INTENSIVE_DEBUG
            sprintf( bwb_ebuf, "in bwb_xinp(): read STRING <%s>",
               tbuf );
            bwb_debug( bwb_ebuf );
#endif
            inp_eatcomma( f );
            break;
         default:
            n = 0;
            while ( ( c = (char) inp_xgetc( f, FALSE )) != ',' )
               {
               tbuf[ n ] = c;
               ++n;
               tbuf[ n ] = '\0';
               }
#if INTENSIVE_DEBUG
            sprintf( bwb_ebuf, "in bwb_xinp(): read NUMBER <%s>",
               tbuf );
            bwb_debug( bwb_ebuf );
#endif
            /*------------------------------------------------------------*/
            /* atof call replaced by inp_numconst, gets all input formats */
            /* (JBV, 10/95)                                               */
            /*------------------------------------------------------------*/
            /* * var_findnval( v, v->array_pos ) = (bnumber) atof( tbuf ); */
            * var_findnval( v, v->array_pos ) = inp_numconst( tbuf );
            break;
         }				/* end of switch for type-specific input */

      /* check for comma */

      adv_ws( l->buffer, &( l->position ) );
      if ( l->buffer[ l->position ] == ',' )
         {
         ++( l->position );
         }
      else
         {
         loop = FALSE;
         }

      }

   /* return */

   return bwb_zline( l );

   }

/***************************************************************

        FUNCTION:       inp_advws()

	DESCRIPTION:    This C function advances past whitespace
			input from a particular file or device.

***************************************************************/

#if ANSI_C
static int
inp_advws( FILE *f )
#else
static int
inp_advws( f )
   FILE *f;
#endif
   {
   register int c;
   int loop;

   loop = TRUE;
   while ( loop == TRUE )
      {
      c = (char) inp_xgetc( f, TRUE );

      switch( c )
         {
         case '\n':
         case '\r':
         case ' ':
         case '\t':
            break;
         default:
            char_saved = TRUE;
            cs = c;
            loop = FALSE;
            break;
         }
      }   

   return TRUE;
   }

/***************************************************************

        FUNCTION:       inp_xgetc()

	DESCRIPTION:    This C function reads in a character from
			a specified file or device.

***************************************************************/

#if ANSI_C
static int
inp_xgetc( FILE *f, int is_string )
#else
static int
inp_xgetc( f, is_string )
   FILE *f;
   int is_string;
#endif
   {
   register int c;
   static int prev_eof = FALSE;

   if ( char_saved == TRUE )
      {
      char_saved = FALSE;
      return cs;
      }

   if ( feof( f ) != 0 )
      {
      if ( prev_eof == TRUE )
         {
         bwb_error( err_od );
         }
      else
         {
	 prev_eof = TRUE;
	 return (int) ',';
	 }
      }

   prev_eof = FALSE;

   c = fgetc( f );

   if ( is_string == TRUE )
      {
      return c;
      }
      
   switch( c )
      {
      case ' ':
      case '\n':
      case ',':
      case '\r':
         return ',';
      }

   return c;

   }

/***************************************************************

        FUNCTION:       inp_eatcomma()

	DESCRIPTION:    This C function advances beyond a comma
			input from a specified file or device.

***************************************************************/

#if ANSI_C
static int
inp_eatcomma( FILE *f )
#else
static int
inp_eatcomma( f )
   FILE *f;
#endif
   {
   char c;

   while ( ( c = (char) inp_xgetc( f, TRUE ) ) == ',' )
      {
      }
      
   char_saved = TRUE;
   cs = c;
      
   return TRUE;
   }

/***************************************************************

        FUNCTION:       inp_str()

        DESCRIPTION:    This function does INPUT processing
                        from a determined string of input
                        data and a determined variable list
                        (both in memory).  This presupposes
			that input has been taken from stdin,
			not from a disk file or device.

***************************************************************/

#if ANSI_C
static struct bwb_line *
inp_str( struct bwb_line *l, char *input_buffer, char *var_list, int *vl_position )
#else
static struct bwb_line *
inp_str( l, input_buffer, var_list, vl_position )
   struct bwb_line *l;
   char *input_buffer;
   char *var_list;
   int *vl_position;
#endif
   {
   int i;
   register int n;
   struct bwb_variable *v;
   int loop;
   int *pp;
   int n_params;
   char ttbuf[ MAXSTRINGSIZE + 1 ];		/* build element */
   char varname[ MAXSTRINGSIZE + 1 ];		/* build element */

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in inp_str(): received line <%s>",
      l->buffer );
   bwb_debug( bwb_ebuf );
   sprintf( bwb_ebuf, "in inp_str(): received variable list <%s>.",
      &( var_list[ *vl_position ] ) );
   bwb_debug( bwb_ebuf );
   sprintf( bwb_ebuf, "in inp_str(): received input buffer  <%s>.",
      input_buffer );
   bwb_debug( bwb_ebuf );
#endif

   /* Read elements, and assign them to variables */

   i = 0;
   loop = TRUE;
   while ( loop == TRUE )
      {

      /* get a variable name from the list */

      bwb_getvarname( var_list, varname, vl_position );    /* get name */
      v = var_find( varname );

#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in inp_str(): found variable buffer <%s> name <%s>",
         varname, v->name );
      bwb_debug( bwb_ebuf );
#endif

      /* read subscripts if appropriate */

      adv_ws( var_list, vl_position );
      if ( var_list[ *vl_position ] == '(' )
         {
#if INTENSIVE_DEBUG
	 sprintf( bwb_ebuf, "in inp_str(): variable <%s> has dimensions",
	    v->name );
	 bwb_debug( bwb_ebuf );
#endif
         dim_getparams( var_list, vl_position, &n_params, &pp );
         for ( n = 0; n < v->dimensions; ++n )
            {
            v->array_pos[ n ] = pp[ n ];
            }
         }

      /* build string from input buffer in ttbuf */

      n = 0;
      ttbuf[ 0 ] = '\0';
      while ( ( input_buffer[ i ] != ',' )
         &&   ( input_buffer[ i ] != '\0' ))
         {
         ttbuf[ n ] = input_buffer[ i ];
         ++n;
         ++i;
         ttbuf[ n ] = '\0';
         }

#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in inp_str(): string for input <%s>",
         ttbuf );
      bwb_debug( bwb_ebuf );
#endif

      /* perform type-specific input */

      inp_assign( ttbuf, v );

      /* check for commas in variable list and input list and advance */

      adv_ws( var_list, vl_position );
      switch( var_list[ *vl_position ] )
	 {
	 case '\n':
	 case '\r':
	 case '\0':
	 case ':':
	    loop = FALSE;
	    break;
	 case ',':
	    ++( *vl_position );
	    break;
         }
      adv_ws( var_list, vl_position );

      adv_ws( input_buffer, &i );
      switch ( input_buffer[ i ] )
	 {
	 case '\n':
	 case '\r':
	 case '\0':
	 case ':':
	    loop = FALSE;
	    break;
	 case ',':
	    ++i;
	    break;
	 }
      adv_ws( input_buffer, &i );

      }

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in inp_str(): exit, line buffer <%s>",
      &( l->buffer[ l->position ] ) );
   bwb_debug( bwb_ebuf );
#endif

   /* return */

   return bwb_zline( l );

   }

/***************************************************************

        FUNCTION:       inp_assign()

        DESCRIPTION:    This function assigns the value of a
                        numerical or string constant to a
                        variable.


***************************************************************/

#if ANSI_C
static int
inp_assign( char *b, struct bwb_variable *v )
#else
static int
inp_assign( b, v )
   char *b;
   struct bwb_variable *v;
#endif
   {

   switch( v->type )
      {
      case STRING:
         str_ctob( var_findsval( v, v->array_pos ), b );
         break;

      case NUMBER:
         if ( strlen( b ) == 0 )
            {
            *( var_findnval( v, v->array_pos )) = (bnumber) 0.0;
            }
         else
            {
            /*------------------------------------------------------------*/
            /* atof call replaced by inp_numconst, gets all input formats */
            /* (JBV, 10/95)                                               */
            /*------------------------------------------------------------*/
            /* *( var_findnval( v, v->array_pos )) = (bnumber) atof( b ); */
            *( var_findnval( v, v->array_pos )) = inp_numconst( b );
            }
         break;

      default:
#if PROG_ERRORS
         sprintf( bwb_ebuf, "in inp_assign(): variable <%s> of unknown type",
            v->name );
         bwb_error( bwb_ebuf );
#else
         bwb_error( err_mismatch );
#endif
         return FALSE;

      }

   return FALSE;

   }

/***************************************************************

        FUNCTION:       inp_adv()

        DESCRIPTION:    This function advances the string pointer
                        past whitespace and the item delimiter
                        (comma).

***************************************************************/

#if ANSI_C
int
inp_adv( char *b, int *c )
#else
int
inp_adv( b, c )
   char *b;
   int *c;
#endif
   {
   int rval;

   rval = FALSE;

   while( TRUE )
      {
      switch( b[ *c ] )
         {
         case ' ':              /* whitespace */
         case '\t':
         case ';':              /* semicolon, end of prompt string */
            ++*c;
            break;
         case ',':              /* comma, variable delimiter */
            rval = TRUE;
            ++*c;
            break;
         case '\0':		/* end of line */
         case ':': 		/* end of line segment */
            rval = TRUE;
            last_inp_adv_rval = rval; /* JBV */
            return rval;
         default:
            last_inp_adv_rval = rval; /* JBV */
            return rval;
         }
      }
   }

/***************************************************************

        FUNCTION:       inp_const()

        DESCRIPTION:    This function reads a numerical or string
                        constant from <m_buffer> into <s_buffer>,
                        incrementing <position> appropriately.

***************************************************************/

#if ANSI_C
static int
inp_const( char *m_buffer, char *s_buffer, int *position )
#else
static int
inp_const( m_buffer, s_buffer, position )
   char *m_buffer;
   char *s_buffer;
   int *position;
#endif
   {
   int string;
   int s_pos;
   int loop;

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in inp_const(): received argument <%s>.",
      &( m_buffer[ *position ] ) );
   bwb_debug( bwb_ebuf );
#endif

   string = FALSE;

   /* first detect string constant */

   if ( m_buffer[ *position ] == '\"' )
      {
      string = TRUE;
      ++( *position );
      }
   else
      {
      string = FALSE;
      }

   /* build the constant string */

   s_buffer[ 0 ] = '\0';
   s_pos = 0;
   loop = TRUE;

   while ( loop == TRUE )
      {

      switch ( m_buffer[ *position ] )
         {
         case '\0':                     /* end of string */
         case '\n':
         case '\r':
            return TRUE;
         case ' ':                      /* whitespace */
         case '\t':
         case ',':                      /* or end of argument */
            if ( string == FALSE )
               {
               return TRUE;
               }
            else
               {
               s_buffer[ s_pos ] = m_buffer[ *position ];
               ++( *position );
               ++s_buffer;
               s_buffer[ s_pos ] = '\0';
               }
            break;
         case '\"':
            if ( string == TRUE )
               {
               ++( *position );                 /* advance beyond quotation mark */
               inp_adv( m_buffer, position );
               return TRUE;
               }
            else
               {
#if PROG_ERRORS
               sprintf( bwb_ebuf, "Unexpected character in numerical constant." );
               bwb_error( bwb_ebuf );
#else
               bwb_error( err_syntax );
#endif
               return FALSE;
               }
         default:
            s_buffer[ s_pos ] = m_buffer[ *position ];
            ++( *position );
            ++s_buffer;
            s_buffer[ s_pos ] = '\0';
            break;
         }

      }

   return FALSE;

   }

#if COMMON_CMDS

/***************************************************************

        FUNCTION:       bwb_line()

        DESCRIPTION:    This function implements the BASIC LINE
                        INPUT statement.

	SYNTAX:         LINE INPUT [[#] device-number,]["prompt string";] string-variable$

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_line( struct bwb_line *l )
#else
struct bwb_line *
bwb_line( l )
   struct bwb_line *l;
#endif
   {
   int dev_no;
   struct bwb_variable *v;
   FILE *inp_device;
   char tbuf[ MAXSTRINGSIZE + 1 ];
   char pstring[ MAXSTRINGSIZE + 1 ];
   struct exp_ese *e; /* JBV */
   int pos; /* JBV */

   /* assign default values */

   inp_device = stdin;

   pstring[ 0 ] = '\0';

   /* advance to first element (INPUT statement) */

   adv_element( l->buffer, &( l->position ), tbuf );
   bwb_strtoupper( tbuf );
   if ( strcmp( tbuf, "INPUT" ) != 0 )
      {
      bwb_error( err_syntax );
      return bwb_zline( l );
      }
   adv_ws( l->buffer, &( l->position ) );

   /* check for semicolon in first position */

   if ( l->buffer[ l->position ] == ';' )
      {
      ++l->position;
      adv_ws( l->buffer, &( l->position ) );
      }

   /* else check for# for file number in first position */

   else if ( l->buffer[ l->position ] == '#' )
      {
      ++l->position;
      adv_element( l->buffer, &( l->position ), tbuf );
      adv_ws( l->buffer, &( l->position ));
      /* dev_no = atoi( tbuf ); */  /* We really need more, added next (JBV) */
      pos = 0;
      e = bwb_exp( tbuf, FALSE, &pos );
      dev_no = (int) exp_getnval( e );

#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_line(): file number requested <%d>", dev_no );
      bwb_debug( bwb_ebuf );
#endif

      if ( dev_table[ dev_no ].cfp == NULL )
         {
         bwb_error( err_dev );
         return bwb_zline( l );
         }
      else
         {
         inp_device = dev_table[ dev_no ].cfp;
         }
      }

   /* check for comma */

   if ( l->buffer[ l->position ] == ',' )
      {
      ++( l->position );
      adv_ws( l->buffer, &( l->position ));
      }

   /* check for quotation mark indicating prompt */

   if ( l->buffer[ l->position ] == '\"' )
      {
      inp_const( l->buffer, pstring, &( l->position ) );
      }

   /* read the variable for assignment */

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_line(): tbuf <%s>", 
      tbuf );
   bwb_debug( bwb_ebuf );
   sprintf( bwb_ebuf, "in bwb_line(): line buffer <%s>", 
      &( l->buffer[ l->position ] ) );
   bwb_debug( bwb_ebuf );
#endif

   adv_element( l->buffer, &( l->position ), tbuf );

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_line(): variable buffer <%s>", tbuf );
   bwb_debug( bwb_ebuf );
#endif
   v = var_find( tbuf );
   if ( v->type != STRING )
      {
#if PROG_ERRORS
      bwb_error( "in bwb_line(): String variable required" );
#else
      bwb_error( err_syntax );
#endif
      return bwb_zline( l );
      }

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_line(): variable for assignment <%s>", v->name );
   bwb_debug( bwb_ebuf );
#endif

   /* read a line of text into the bufffer */

   if ( inp_device == stdin )
      {
      bwx_input( pstring, tbuf );
      }
   else
      {
      /* Was MAXSTRINGSIZE (JBV 9/8/97) */
      fgets( tbuf, MAXSTRINGSIZE + 2, inp_device );
      }
   bwb_stripcr( tbuf );
   str_ctob( var_findsval( v, v->array_pos ), tbuf );

   /* end: return next line */

   return bwb_zline( l );
   }

#endif				/* COMMON_CMDS */

/***************************************************************

        FUNCTION:	inp_numconst()

        DESCRIPTION:	This function interprets a numerical
			constant.  Added by JBV 10/95

***************************************************************/

#if ANSI_C
bnumber
inp_numconst( char *expression )
#else
bnumber
inp_numconst( expression )
   char *expression;
#endif
   {
   int base;                            /* numerical base for the constant */
   static struct bwb_variable mantissa; /* mantissa of floating-point number */
   static int init = FALSE;		/* is mantissa variable initialized? */
   int exponent;                        /* exponent for floating point number */
   int man_start;                       /* starting point of mantissa */
   int s_pos;                           /* position in build string */
   int build_loop;
   int need_pm;
   int i;
   bnumber d;

   /* Expression stack stuff */
   char type;
   bnumber nval;
   char string[ MAXSTRINGSIZE + 1 ];
   int pos_adv;

   /* initialize the variable if necessary */

#if INTENSIVE_DEBUG
   strcpy( mantissa.name, "(mantissa)" );
#endif

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &mantissa, NUMBER );
      }

   /* be sure that the array_pos[ 0 ] for mantissa is set to dim_base;
      this is necessary because mantissa might be used before dim_base
      is set */

   mantissa.array_pos[ 0 ] = dim_base;

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in inp_numconst(): received <%s>, eval <%c>",
      expression, expression[ 0 ] );
   bwb_debug( bwb_ebuf );
#endif

   need_pm = FALSE;
   nval = (bnumber) 0;

   /* check the first character(s) to determine numerical base
      and starting point of the mantissa */

   switch( expression[ 0 ] )
      {
      case '-':
      case '+':
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
      case '.':
         base = 10;                     /* decimal constant */
	 man_start = 0;                 /* starts at position 0 */
	 need_pm = FALSE;
         break;
      case '&':                         /* hex or octal constant */
         if ( ( expression[ 1 ] == 'H' ) || ( expression[ 1 ] == 'h' ))
            {
            base = 16;                  /* hexadecimal constant */
            man_start = 2;              /* starts at position 2 */
            }
         else
            {
            base = 8;                   /* octal constant */
            if ( ( expression[ 1 ] == 'O' ) || ( expression[ 1 ] == 'o' ))
               {
               man_start = 2;           /* starts at position 2 */
               }
            else
               {
               man_start = 1;           /* starts at position 1 */
               }
            }
         break;
      default:

#if PROG_ERRORS
         sprintf( bwb_ebuf, "expression <%s> is not a numerical constant.",
            expression );
         bwb_error( bwb_ebuf );
#else
         bwb_error( err_syntax );
#endif
         return (bnumber) 0;
      }

   /* now build the mantissa according to the numerical base */

   switch( base )
      {

      case 10:                          /* decimal constant */

         /* initialize counters */

         pos_adv = man_start;
         type = NUMBER;
         string[ 0 ] = '\0';
         s_pos = 0;
         exponent = 0;
         build_loop = TRUE;

         /* loop to build the string */

         while ( build_loop == TRUE )
            {
            switch( expression[ pos_adv ] )
               {
               case '-':                        /* prefixed plus or minus */
               case '+':

                  /* in the first position, a plus or minus sign can
                     be added to the beginning of the string to be
                     scanned */

                  if ( pos_adv == man_start )
                     {
                     string[ s_pos ] = expression[ pos_adv ];
                     ++pos_adv;  /* advance to next character */
                     ++s_pos;
                     string[ s_pos ] = '\0';
                     }

                  /* but in any other position, the plus or minus sign
                     must be taken as an operator and thus as terminating
                     the string to be scanned */

                  else
                     {
                     build_loop = FALSE;
                     }
                  break;
               case '.':                        /* note at least single precision */
               case '0':                        /* or ordinary digit */
               case '1':
               case '2':
               case '3':
               case '4':
               case '5':
               case '6':
               case '7':
               case '8':
               case '9':
                  string[ s_pos ] = expression[ pos_adv ];
                  ++pos_adv;  /* advance to next character */
                  ++s_pos;
                  string[ s_pos ] = '\0';
                  break;

	       case '#':                        /* Microsoft-type precision indicator; ignored but terminates */
	       case '!':                        /* Microsoft-type precision indicator; ignored but terminates */
		  ++pos_adv;  /* advance to next character */
		  type = NUMBER;
		  exponent = FALSE;
		  build_loop = FALSE;
		  break;

	       case 'E':                        /* exponential, single precision */
               case 'e':
                  ++pos_adv;  /* advance to next character */
                  type = NUMBER;
		  exponent = TRUE;
                  build_loop = FALSE;
		  break;

               case 'D':                        /* exponential, double precision */
               case 'd':
                  ++pos_adv;  /* advance to next character */
                  type = NUMBER;
		  exponent = TRUE;
                  build_loop = FALSE;
                  break;

               default:                         /* anything else, terminate */
                  build_loop = FALSE;
                  break;
               }

            }

         /* assign the value to the mantissa variable */
         
#if NUMBER_DOUBLE
         sscanf( string, "%lf", var_findnval( &mantissa, mantissa.array_pos ));
#else
         sscanf( string, "%f", var_findnval( &mantissa, mantissa.array_pos ));
#endif

#if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in inp_numconst(): read mantissa, string <%s> val <%lf>",
            string, var_getnval( &mantissa ) );
         bwb_debug( bwb_ebuf );
#endif

         /* test if integer bounds have been exceeded */

         if ( type == NUMBER )
            {
            i = (int) var_getnval( &mantissa );
            d = (bnumber) i;
            if ( d != var_getnval( &mantissa ))
               {
               type = NUMBER;
#if INTENSIVE_DEBUG
               sprintf( bwb_ebuf, "in inp_numconst(): integer bounds violated, promote to NUMBER" );
               bwb_debug( bwb_ebuf );
#endif               
               }
            }

         /* read the exponent if there is one */

         if ( exponent == TRUE )
            {

	    /* allow a plus or minus once at the beginning */

	    need_pm = TRUE;

	    /* initialize counters */

            string[ 0 ] = '\0';
            s_pos = 0;
            build_loop = TRUE;

            /* loop to build the string */

            while ( build_loop == TRUE )
               {
               switch( expression[ pos_adv ] )
                  {
		  case '-':                        /* prefixed plus or minus */
                  case '+':

		     if ( need_pm == TRUE )        /* only allow once */
			{
			string[ s_pos ] = expression[ pos_adv ];
			++pos_adv;  /* advance to next character */
			++s_pos;
			string[ s_pos ] = '\0';
			}
		     else
			{
			build_loop = FALSE;
			}
		     break;

		  case '0':                        /* or ordinary digit */
                  case '1':
                  case '2':
                  case '3':
                  case '4':
                  case '5':
                  case '6':
                  case '7':
                  case '8':
                  case '9':

                     string[ s_pos ] = expression[ pos_adv ];
                     ++pos_adv;  /* advance to next character */
                     ++s_pos;
		     string[ s_pos ] = '\0';
		     need_pm = FALSE;
                     break;

                  default:                         /* anything else, terminate */
                     build_loop = FALSE;
                     break;
                  }

               }                                /* end of build loop for exponent */

            /* assign the value to the user variable */

#if NUMBER_DOUBLE
            sscanf( string, "%lf", &nval );
#else
            sscanf( string, "%f", &nval );
#endif

#if INTENSIVE_DEBUG
	    sprintf( bwb_ebuf, "in inp_numconst(): exponent is <%d>",
               (int) nval );
            bwb_debug( bwb_ebuf );
#endif

            }                           /* end of exponent search */

         if ( nval == (bnumber) 0 )
            {
            nval = var_getnval( &mantissa );
            }
         else
            {
            nval = var_getnval( &mantissa )
               * pow( (bnumber) 10.0, (bnumber) nval );
            }

         break;

      case 8:                           /* octal constant */

         /* initialize counters */

         pos_adv = man_start;
         type = NUMBER;
         string[ 0 ] = '\0';
         s_pos = 0;
         exponent = 0;
         build_loop = TRUE;

         /* loop to build the string */

         while ( build_loop == TRUE )
            {
            switch( expression[ pos_adv ] )
               {
               case '0':                        /* or ordinary digit */
               case '1':
               case '2':
               case '3':
               case '4':
               case '5':
               case '6':
               case '7':
                  string[ s_pos ] = expression[ pos_adv ];
                  ++pos_adv;  /* advance to next character */
                  ++s_pos;
                  string[ s_pos ] = '\0';
                  break;

               default:                         /* anything else, terminate */
                  build_loop = FALSE;
                  break;
               }

            }

         /* now scan the string to determine the number */

         sscanf( string, "%o", &i );
         nval = (bnumber) i;

         break;

      case 16:                          /* hexadecimal constant */

         /* initialize counters */

         pos_adv = man_start;
         type = NUMBER;
         string[ 0 ] = '\0';
         s_pos = 0;
         exponent = 0;
         build_loop = TRUE;

         /* loop to build the string */

         while ( build_loop == TRUE )
            {
            switch( expression[ pos_adv ] )
               {
               case '0':                        /* or ordinary digit */
               case '1':
               case '2':
               case '3':
               case '4':
               case '5':
               case '6':
               case '7':
               case '8':
               case '9':
               case 'A':
               case 'a':
               case 'B':
               case 'b':
               case 'C':
               case 'c':
               case 'D':
               case 'd':
               case 'E':
               case 'e':
               case 'F': /* Don't forget these! (JBV) */
               case 'f':
                  string[ s_pos ] = expression[ pos_adv ];

                  ++pos_adv;  /* advance to next character */
                  ++s_pos;
                  string[ s_pos ] = '\0';
                  break;

               default:                         /* anything else, terminate */
                  build_loop = FALSE;
                  break;
               }

            }

         /* now scan the string to determine the number */

         sscanf( string, "%x", &i );
         nval = (bnumber) i;
         break;
      }

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in inp_numconst(): precision <%c> value <%lf>",
      type, nval );
   bwb_debug( bwb_ebuf );
#endif

   return nval;

   }
