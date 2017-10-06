/***************************************************************

        bwb_inp.c       Input Routines
                        for Bywater BASIC Interpreter

                        Commands:       DATA
                                        READ
                                        RESTORE
                                        INPUT
                                        LINE INPUT

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

***************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <math.h>

#include "bwbasic.h"
#include "bwb_mes.h"

struct bwb_line *data_line;
int data_pos;

/* Declarations of functions visible to this file only */

static struct bwb_line *bwb_xinp( struct bwb_line *l, FILE *f );
static struct bwb_line *inp_str( struct bwb_line *l, char *buffer,
   char *var_list, int *position );
static int inp_const( char *m_buffer, char *s_buffer, int *position );
static int inp_assign( char *b, struct bwb_variable *v );
static int inp_advws( FILE *f );
static int inp_xgetc( FILE *f, int is_string );
static int inp_eatcomma( FILE *f );
static char_saved = FALSE;
static cs;

/***************************************************************

        FUNCTION:       bwb_read()

        DESCRIPTION:    This function implements the BASIC READ
                        statement.

        SYNTAX:         READ variable[, variable...]

***************************************************************/

struct bwb_line *
bwb_read( struct bwb_line *l )
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

         inp_adv( data_line->buffer, &data_pos );

         /* Advance to next line if end of buffer */

         switch( data_line->buffer[ data_pos ] )
            {
            case '\0':                     /* end of buffer */
            case '\n':
            case '\r':

               data_line = data_line->next;

               /* advance farther to line with DATA statement if necessary */

               pos = 0;
               line_start( data_line->buffer, &pos,
                  &( data_line->lnpos ),
                  &( data_line->lnum ),
                  &( data_line->cmdpos ),
                  &( data_line->cmdnum ),
                  &( data_line->startpos ) );
               data_pos = data_line->startpos;

	       #if INTENSIVE_DEBUG
               sprintf( bwb_ebuf, "in bwb_read(): current data line: <%s>",
                  data_line->buffer );
               bwb_debug( bwb_ebuf );
               #endif

               break;
            }

         while ( bwb_cmdtable[ data_line->cmdnum ].vector != bwb_data )
            {

            if ( data_line == &bwb_end )
               {
               data_line = bwb_start.next;
               }

            else
               {
               data_line = data_line->next;
               }

            pos = 0;
            line_start( data_line->buffer, &pos,
               &( data_line->lnpos ),
               &( data_line->lnum ),
               &( data_line->cmdpos ),
               &( data_line->cmdnum ),
               &( data_line->startpos ) );
            data_pos = data_line->startpos;

            #if INTENSIVE_DEBUG
            sprintf( bwb_ebuf, "in bwb_read(): advance to data line: <%s>",
               data_line->buffer );
            bwb_debug( bwb_ebuf );
            #endif

            }

         /* advance beyond whitespace in data buffer */

         adv_loop = TRUE;
         while ( adv_loop == TRUE )
            {
            switch( data_line->buffer[ data_pos ] )
               {
               case '\0':                       /* end of buffer */
               case '\n':
               case '\r':
                  bwb_error( err_od );
                  l->next->position = 0;
                  return l->next;
               case ' ':                        /* whitespace */
               case '\t':
                  ++data_pos;
                  break;
               default:
                  adv_loop = FALSE;             /* carry on */
                  break;
               }
            }

         /* now at last we have a variable in v that needs to be
            assigned data from the data_buffer at position data_pos.
            What remains to be done is to get one single bit of data,
            a string constant or numerical constant, into the small
            buffer */

         inp_const( data_line->buffer, tbuf, &data_pos );

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

   l->next->position = 0;
   return l->next;

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

struct bwb_line *
bwb_data( struct bwb_line *l )
   {
   l->next->position = 0;
   return l->next;
   }

/***************************************************************

        FUNCTION:       bwb_restore()

        DESCRIPTION:    This function implements the BASIC RESTORE
                        statement.

        SYNTAX:         RESTORE [line number]

***************************************************************/

struct bwb_line *
bwb_restore( struct bwb_line *l )
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
      data_line = &bwb_start;
      data_pos = 0;
      #if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_restore(): RESTORE w/ no argument " );
      bwb_debug( bwb_ebuf );
      #endif
      l->next->position = 0;
      return l->next;
      }

   /* find the line */

   n = atoi( tbuf );

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_restore(): line for restore is <%d>", n );
   bwb_debug( bwb_ebuf );
   #endif

   r_line = NULL;
   for ( r = bwb_start.next; r != &bwb_end; r = r->next )
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
      l->next->position = 0;
      return l->next;
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
      l->next->position = 0;
      return l->next;
      }

   /* reassign data_line */

   data_line = r_line;
   data_pos = data_line->startpos;

   l->next->position = 0;
   return l->next;
   }

/***************************************************************

        FUNCTION:       bwb_input()

        DESCRIPTION:    This function implements the BASIC INPUT
                        statement.

        SYNTAX:         INPUT [;][prompt$;]variable[$,variable]...
                        INPUT #n variable[$,variable]...

***************************************************************/

struct bwb_line *
bwb_input( struct bwb_line *l )
   {
   FILE *fp;
   int pos;
   int req_devnumber;
   struct exp_ese *v;
   int is_prompt;
   int suppress_qm;
   static char tbuf[ MAXSTRINGSIZE + 1 ];

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_input(): enter function" );
   bwb_debug( bwb_ebuf );
   #endif

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
         bwb_error( "in bwb_input(): no comma after #n" );
         #else
         bwb_error( err_syntax );
         #endif
         l->next->position = 0;
         return l->next;
         }

      req_devnumber = exp_getival( v );

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
         l->next->position = 0;
         return l->next;
         }

      if ( ( dev_table[ req_devnumber ].mode == DEVMODE_CLOSED ) ||
         ( dev_table[ req_devnumber ].mode == DEVMODE_AVAILABLE ) )
         {
         #if PROG_ERRORS
         bwb_error( "in bwb_input(): Requested device number is not open." );
         #else
         bwb_error( err_devnum );
         #endif

         l->next->position = 0;
         return l->next;
         }

      if ( dev_table[ req_devnumber ].mode != DEVMODE_INPUT )
         {
         #if PROG_ERRORS
         bwb_error( "in bwb_input(): Requested device is not open for INPUT." );
         #else
         bwb_error( err_devnum );
         #endif

         l->next->position = 0;
         return l->next;
         }

      /* look up the requested device in the device table */

      fp = dev_table[ req_devnumber ].cfp;

      }
   else
      {
      fp = stdin;
      }

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

      suppress_qm = inp_adv( l->buffer, &( l->position ) );

      /* print the prompt string */

      xprintf( stdout, tbuf );
      }                                      /* end condition: prompt string */

   /* print out the question mark delimiter unless it has been
      suppressed */

   if ( suppress_qm != TRUE )
      {
      xprintf( stdout, "? " );
      }

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_input(): ready to get input line" );
   bwb_debug( bwb_ebuf );
   #endif

   /* read a line into the input buffer */

   fflush( stdin );
   fgets( tbuf, MAXSTRINGSIZE, stdin );
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
                        for INPUT #, and so is file independent.

***************************************************************/

struct bwb_line *
bwb_xinp( struct bwb_line *l, FILE *f )
   {
   int loop;
   struct bwb_variable *v;
   char c;
   register int n;
   int pos;
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
      if ( l->buffer[ l->position ] == ')' )
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
         case INTEGER:
            n = 0;
            while ( ( c = (char) inp_xgetc( f, FALSE )) != ',' )
               {
               tbuf[ n ] = c;
               ++n;
               tbuf[ n ] = '\0';
               }
            #if INTENSIVE_DEBUG
            sprintf( bwb_ebuf, "in bwb_xinp(): read INTEGER <%s>",
               tbuf );
            bwb_debug( bwb_ebuf );
            #endif
            * var_findival( v, v->array_pos ) = atoi( tbuf );
            break;
         case DOUBLE:
            n = 0;
            while ( ( c = (char) inp_xgetc( f, FALSE )) != ',' )
               {
               tbuf[ n ] = c;
               ++n;
               tbuf[ n ] = '\0';
               }
            #if INTENSIVE_DEBUG
            sprintf( bwb_ebuf, "in bwb_xinp(): read DOUBLE <%s>",
               tbuf );
            bwb_debug( bwb_ebuf );
            #endif
            * var_finddval( v, v->array_pos ) = (double) atof( tbuf );
            break;
         default:			/* take SINGLE as default */
            n = 0;
            while ( ( c = (char) inp_xgetc( f, FALSE )) != ',' )
               {
               tbuf[ n ] = c;
               ++n;
               tbuf[ n ] = '\0';
               }
            #if INTENSIVE_DEBUG
            sprintf( bwb_ebuf, "in bwb_xinp(): read SINGLE <%s>",
               tbuf );
            bwb_debug( bwb_ebuf );
            #endif
            * var_findfval( v, v->array_pos ) = (float) atof( tbuf );
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

   return l;

   }

/***************************************************************

        FUNCTION:       inp_advws()

        DESCRIPTION:    

***************************************************************/

int
inp_advws( FILE *f )
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

        DESCRIPTION:    

***************************************************************/

int
inp_xgetc( FILE *f, int is_string )
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

        DESCRIPTION:    

***************************************************************/

int
inp_eatcomma( FILE *f )
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

struct bwb_line *
inp_str( struct bwb_line *l, char *input_buffer, char *var_list, int *vl_position )
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
      if ( var_list[ *vl_position ] == ')' )
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

   l->next->position = 0;
   return l->next;

   }

/***************************************************************

        FUNCTION:       inp_assign()

        DESCRIPTION:    This function assigns the value of a
                        numerical or string constant to a
                        variable.


***************************************************************/

int
inp_assign( char *b, struct bwb_variable *v )
   {

   switch( v->type )
      {
      case STRING:
         str_ctob( var_findsval( v, v->array_pos ), b );
         break;

      case DOUBLE:
         if ( strlen( b ) == 0 )
            {
            *( var_finddval( v, v->array_pos )) = (double) 0.0;
            }
         else
            {
            *( var_finddval( v, v->array_pos )) = (double) atof( b );
            }
         break;

      case SINGLE:
         if ( strlen( b ) == 0 )
            {
            *( var_findfval( v, v->array_pos )) = (float) 0.0;
            }
         else
            {
            *( var_findfval( v, v->array_pos )) = (float) atof( b );
            }
         break;

      case INTEGER:
         if ( strlen( b ) == 0 )
            {
            *( var_findival( v, v->array_pos )) = 0;
            }
         else
            {
            *( var_findival( v, v->array_pos )) = atoi( b );
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

int
inp_adv( char *b, int *c )
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
            return rval;
         default:
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

int
inp_const( char *m_buffer, char *s_buffer, int *position )
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

   return 0;

   }

/***************************************************************

        FUNCTION:       bwb_line()

        DESCRIPTION:    This function implements the BASIC LINE
                        INPUT statement.

        SYNTAX:         LINE INPUT

***************************************************************/

struct bwb_line *
bwb_line( struct bwb_line *l )
   {
   int dev_no;
   struct bwb_variable *v;
   FILE *inp_device;
   char tbuf[ MAXSTRINGSIZE + 1 ];

   /* assign default values */

   inp_device = stdin;
   l->next->position = 0;

   /* advance to first element (INPUT statement) */

   adv_element( l->buffer, &( l->position ), tbuf );
   bwb_strtoupper( tbuf );
   if ( strcmp( tbuf, "INPUT" ) != 0 )
      {
      bwb_error( err_syntax );
      return l->next;
      }
   adv_ws( l->buffer, &( l->position ) );

   /* check for semicolon in first position */

   if ( l->buffer[ l->position ] == ';' )
      {
      ++l->position;
      adv_ws( l->buffer, &( l->position ) );
      }

   /* else check for # for file number in first position */

   else if ( l->buffer[ l->position ] == '#' )
      {
      ++l->position;
      adv_element( l->buffer, &( l->position ), tbuf );
      adv_ws( l->buffer, &( l->position ));
      dev_no = atoi( tbuf );

      #if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_line(): file number requested <%d>", dev_no );
      bwb_debug( bwb_ebuf );
      #endif

      if ( dev_table[ dev_no ].cfp == NULL )
         {
         bwb_error( err_dev );
         return l->next;
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
      inp_const( l->buffer, tbuf, &( l->position ) );
      xprintf( stdout, tbuf );
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
      return l->next;
      }

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_line(): variable for assignment <%s>", v->name );
   bwb_debug( bwb_ebuf );
   #endif

   /* read a line of text into the bufffer */

   fgets( tbuf, MAXSTRINGSIZE, inp_device );
   bwb_stripcr( tbuf );
   str_ctob( var_findsval( v, v->array_pos ), tbuf );

   /* end: return next line */

   return l->next;
   }

