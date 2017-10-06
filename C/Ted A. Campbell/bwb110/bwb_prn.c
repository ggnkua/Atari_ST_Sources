/***************************************************************

        bwb_prn.c       Print Commands
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

***************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <math.h>

#include "bwbasic.h"
#include "bwb_mes.h"

/* Prototypes for functions visible only to this file */

static int prn_cr( char *buffer, FILE *f );
static int prn_col = 1;
static int prn_width = 80;	/* default width for stdout */
static struct bwb_variable * bwb_esetovar( struct exp_ese *e );

struct prn_fmt
   {
   int type;			/* STRING, DOUBLE, SINGLE, or INTEGER */
   int exponential;		/* TRUE = use exponential notation */
   int right_justified;		/* TRUE = right justified else left justified */
   int width;			/* width of main section */
   int precision;		/* width after decimal point */
   int commas;			/* use commas every three steps */
   int sign;			/* prefix sign to number */
   int money;			/* prefix money sign to number */
   int fill;			/* ASCII value for fill character, normally ' ' */
   int minus;			/* postfix minus sign to number */
   };

static struct prn_fmt *get_prnfmt( char *buffer, int *position, FILE *f );
static int bwb_xerror( char *message );
static int xxputc( FILE *f, char c );

/***************************************************************

        FUNCTION:       bwb_print()

        DESCRIPTION:    This function implements the BASIC PRINT
                        command.

***************************************************************/

struct bwb_line *
bwb_print( struct bwb_line *l )
   {
   FILE *fp;
   static int pos;
   int req_devnumber;
   struct exp_ese *v;
   static char *s_buffer;          	/* small, temporary buffer */
   static int init = FALSE;

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_print(): enter function" );
   bwb_debug( bwb_ebuf );
   #endif

   /* initialize buffers if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      if ( ( s_buffer = calloc( MAXSTRINGSIZE + 1, sizeof(char) ) ) == NULL )
         {
         bwb_error( err_getmem );
         }
      }

   /* advance beyond whitespace and check for the '#' sign */
   
   adv_ws( l->buffer, &( l->position ) );
   
   if ( l->buffer[ l->position ] == '#' )
      {
      ++( l->position );
      adv_element( l->buffer, &( l->position ), s_buffer );
      pos = 0;
      v = bwb_exp( s_buffer, FALSE, &pos );
      adv_ws( l->buffer, &( l->position ) );
      if ( l->buffer[ l->position ] == ',' )
         {
         ++( l->position );
         }
      else
         {
	 #if PROG_ERRORS
         bwb_error( "in bwb_print(): no comma after #n" );
         #else
         bwb_error( err_syntax );
         #endif
         l->next->position = 0;
         return l->next;
         }

      req_devnumber = exp_getival( v );

      /* check the requested device number */
      
      if ( ( req_devnumber < 0 ) || ( req_devnumber >= DEF_DEVICES ))
         {
         #if PROG_ERRORS
         bwb_error( "in bwb_input(): Requested device number is out of range." );
         #else
         bwb_error( err_devnum );
         #endif
         l->next->position = 0;
         return l->next;
         }

      if (( dev_table[ req_devnumber ].mode == DEVMODE_CLOSED ) ||
         ( dev_table[ req_devnumber ].mode == DEVMODE_AVAILABLE ))
         {
         #if PROG_ERRORS
         bwb_error( "in bwb_input(): Requested device number is not open." );
         #else
         bwb_error( err_devnum );
         #endif

         l->next->position = 0;
         return l->next;
         }

      if ( dev_table[ req_devnumber ].mode != DEVMODE_OUTPUT )
         {
         #if PROG_ERRORS
         bwb_error( "in bwb_print(): Requested device is not open for OUTPUT." );
         #else
         bwb_error( err_devnum );
         #endif

         l->next->position = 0;
         return l->next;
         }

      #if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_print(): device number is <%d>",
         req_devnumber );
      bwb_debug( bwb_ebuf );
      #endif

      /* look up the requested device in the device table */

      fp = dev_table[ req_devnumber ].cfp;

      }

   else
      {
      fp = stdout;
      }

   bwb_xprint( l, fp );

   l->next->position = 0;
   return l->next;
   }

/***************************************************************

        FUNCTION:       bwb_xprint()

        DESCRIPTION:

***************************************************************/

int
bwb_xprint( struct bwb_line *l, FILE *f )
   {
   struct exp_ese *e;
   int loop;
   static int p;
   static int fs_pos;
   struct prn_fmt *format;
   static char *format_string;
   static char *output_string;
   static char *element;
   static char *prnbuf;
   static int init = FALSE;
   #if INTENSIVE_DEBUG || TEST_BSTRING
   bstring *b;
   #endif

   /* initialize buffers if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      if ( ( format_string = calloc( MAXSTRINGSIZE + 1, sizeof(char) ) ) == NULL )
         {
         bwb_error( err_getmem );
         }
      if ( ( output_string = calloc( MAXSTRINGSIZE + 1, sizeof(char) ) ) == NULL )
         {
         bwb_error( err_getmem );
         }      
      if ( ( element = calloc( MAXSTRINGSIZE + 1, sizeof(char) ) ) == NULL )
         {
         bwb_error( err_getmem );
         }      
      if ( ( prnbuf = calloc( MAXSTRINGSIZE + 1, sizeof(char) ) ) == NULL )
         {
         bwb_error( err_getmem );
         }      
      }

   /* Detect USING Here */

   fs_pos = -1;

   /* get "USING" in format_string */

   p = l->position;
   adv_element( l->buffer, &p, format_string );
   bwb_strtoupper( format_string );

   /* check to be sure */

   if ( strcmp( format_string, "USING" ) == 0 )
      {
      l->position = p;
      adv_ws( l->buffer, &( l->position ) );

      /* now get the format string in format_string */

      e = bwb_exp( l->buffer, FALSE, &( l->position ) );
      if ( e->type == STRING )
         {

         /* copy the format string to buffer */

         str_btoc( format_string, exp_getsval( e ) );

         /* look for ';' after format string */

         fs_pos = 0;
         adv_ws( l->buffer, &( l->position ) );
         if ( l->buffer[ l->position ] == ';' )
            {
            ++l->position;
            adv_ws( l->buffer, &( l->position ) );
            }
         else
            {
            #if PROG_ERRORS
            bwb_error( "Failed to find \";\" after format string in PRINT USING" );
            #else
            bwb_error( err_syntax );
            #endif
            return FALSE;
            }

         #if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in bwb_xprint(): Found USING, format string <%s>",
            format_string );
         bwb_debug( bwb_ebuf );
         #endif

         }

      else
         {
         #if PROG_ERRORS
         bwb_error( "Failed to find format string after PRINT USING" );
         #else
         bwb_error( err_syntax );
         #endif
         return FALSE;
         }
      }

   /* if no arguments, simply print CR and return */

   adv_ws( l->buffer, &( l->position ) );
   switch( l->buffer[ l->position ] )
      {
      case '\0':
      case '\n':
      case '\r':
      case ':':
         xprintf( f, "\n" );
         return TRUE;
      default:
         break;
      }

   /* LOOP THROUGH PRINT ELEMENTS */

   loop = TRUE;
   while( loop == TRUE )
      {

      /* resolve the string */

      e = bwb_exp( l->buffer, FALSE, &( l->position ) );

      #if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_xprint(): op <%d> type <%c>",
         e->operation, e->type );
      bwb_debug( bwb_ebuf );
      #endif

      /* an OP_NULL probably indicates a terminating ';', but this
         will be detected later, so we can ignore it for now */

      if ( e->operation != OP_NULL )
         {
         #if TEST_BSTRING
         b = exp_getsval( e );
         sprintf( bwb_ebuf, "in bwb_xprint(): bstring name is <%s>",
            b->name );
         bwb_debug( bwb_ebuf );
         #endif
         str_btoc( element, exp_getsval( e ) );
         }
      else
         {
         element[ 0 ] = '\0';
         }

      #if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_xprint(): element <%s>",
         element );
      bwb_debug( bwb_ebuf );
      #endif

      /* print with format if there is one */

      if (( fs_pos > -1 ) && ( strlen( element ) > 0 ))
         {
         format = get_prnfmt( format_string, &fs_pos, f );

         #if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in bwb_xprint(): format type <%c> width <%d>",
            format->type, format->width );
         bwb_debug( bwb_ebuf );
         #endif

         switch( format->type )
            {
            case STRING:
               if ( e->type != STRING )
                  {
                  #if PROG_ERRORS
                  bwb_error( "Type mismatch in PRINT USING" );
                  #else
                  bwb_error( err_mismatch );
                  #endif
                  }
               sprintf( output_string, "%.*s", format->width,
                  element );

               #if INTENSIVE_DEBUG
               sprintf( bwb_ebuf, "in bwb_xprint(): output string <%s>",
                  output_string );
               bwb_debug( bwb_ebuf );
               #endif

               xprintf( f, output_string );
               break;
            case INTEGER:
               if ( e->type == STRING )
                  {
                  #if PROG_ERRORS
                  bwb_error( "Type mismatch in PRINT USING" );
                  #else
                  bwb_error( err_mismatch );
                  #endif
                  }
               sprintf( output_string, "%.*d", format->width,
                  exp_getival( e ) );
               xprintf( f, output_string );
               break;
            case SINGLE:
            case DOUBLE:
               if ( e->type == STRING )
                  {
                  #if PROG_ERRORS
                  bwb_error( "Type mismatch in PRINT USING" );
                  #else
                  bwb_error( err_mismatch );
                  #endif
                  }
               if ( format->exponential == TRUE )
                  {
                  sprintf( output_string, "%.le", 
                     e->dval );
                  xprintf( f, output_string );
                  }
               else
                  {
                  sprintf( output_string, "%*.*lf", 
                     format->width + 1 + format->precision,
                     format->precision, e->dval );
                  xprintf( f, output_string );
                  }
               break;
            default:
               #if PROG_ERRORS
               sprintf( bwb_ebuf, "in bwb_xprint(): get_prnfmt() returns unknown type <%c>",
                  format->type );
               bwb_error( bwb_ebuf );
               #else
               bwb_error( err_mismatch );
               #endif
               break;
            }
         }

      /* not a format string: use defaults */

      else if ( strlen( element ) > 0 )
         {

         switch( e->type )
            {
            case STRING:
               xprintf( f, element );
               break;
            case INTEGER:
               sprintf( prnbuf, " %d", exp_getival( e ) );
               xprintf( f, prnbuf );
               break;
            case DOUBLE:
               sprintf( prnbuf, " %.*f", prn_precision( bwb_esetovar( e )), 
                  exp_getdval( e ) );
               xprintf( f, prnbuf );
               break;
            default:
               sprintf( prnbuf, " %.*f", prn_precision( bwb_esetovar( e )), 
                  exp_getfval( e ) );
               xprintf( f, prnbuf );
               break;
            }
         }

      /* check the position to see if the loop should continue */

      adv_ws( l->buffer, &( l->position ) );
      switch( l->buffer[ l->position ] )
         {
         case ':':		/* end of line segment */
	    loop = FALSE;
/*	    ++( l->position ); */
	    break;
         case '\0':		/* end of buffer */
         case '\n':
         case '\r':
	    loop = FALSE;
            break;
         case ',':		/* tab over */
            xputc( f, '\t' );
            ++l->position;
            adv_ws( l->buffer, &( l->position ) );
            break;
         case ';':		/* concatenate strings */
            ++l->position;
            adv_ws( l->buffer, &( l->position ) );
            break;
         }

      }				/* end of loop through print elements */

   /* call prn_cr() to print a CR if it is not overridden by a
      concluding ';' mark */

   prn_cr( l->buffer, f ); 

   return TRUE;

   }                            /* end of function bwb_xprint() */

/***************************************************************

        FUNCTION:       get_prnfmt()

        DESCRIPTION:

***************************************************************/

struct prn_fmt *
get_prnfmt( char *buffer, int *position, FILE *f )
   {
   static struct prn_fmt retstruct;
   register int c;
   int loop;

   /* set some defaults */

   retstruct.type = FALSE;
   retstruct.exponential = FALSE;
   retstruct.right_justified = FALSE;
   retstruct.commas = FALSE;
   retstruct.sign = FALSE;
   retstruct.money = FALSE;
   retstruct.fill = ' ';
   retstruct.minus = FALSE;

   /* check for negative position */

   if ( *position < 0 )
      {
      return &retstruct;
      }

   /* advance past whitespace */

   adv_ws( buffer, position );

   /* check first character: a lost can be decided right here */

   loop = TRUE;
   while( loop == TRUE )
      {

      #if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in get_prnfmt(): loop, buffer <%s>",
         &( buffer[ *position ] ) );
      bwb_debug( bwb_ebuf );
      #endif

      switch( buffer[ *position ] )
         {
         case ' ':		/* end of this format segment */
            loop = FALSE;
            break;
         case '\0':		/* end of format string */
         case '\n':
         case '\r':
            *position = -1;
            return &retstruct;
         case '_':		/* print next character as literal */
            ++( *position );
            xputc( f, buffer[ *position ] );
            ++( *position );
            break;
         case '!':
            retstruct.type = STRING;
            retstruct.width = 1;
            return &retstruct;
         case '\\':
            #if INTENSIVE_DEBUG
            sprintf( bwb_ebuf, "in get_prnfmt(): found \\" );
            bwb_debug( bwb_ebuf );
            #endif
            retstruct.type = STRING;
            ++( *position );
            for ( retstruct.width = 0; buffer[ *position ] == ' '; ++( *position ) )
               {
               ++retstruct.width;
               }
            if ( buffer[ *position ] == '\\' )
               {
               ++( *position );
               }
            return &retstruct;
         case '$':
            ++( *position );
            retstruct.money = TRUE;
            if ( buffer[ *position ] == '$' )
               {
               ++( *position );
               }
            break;
         case '*':
            ++( *position );
            retstruct.fill = '*';
            if ( buffer[ *position ] == '*' )
               {
               ++( *position );
               }
            break;
         case '+':
            ++( *position );
            retstruct.sign = TRUE;
            break;
         case '#':
            retstruct.type = INTEGER;		/* for now */
            ++( *position );
            for ( retstruct.width = 1; buffer[ *position ] == '#'; ++( *position ) )
               {
               ++retstruct.width;
               }
            if ( buffer[ *position ] == ',' )
               {
               retstruct.commas = TRUE;
               }
            if ( buffer[ *position ] == '.' )
               {
               retstruct.type = DOUBLE;
               ++( *position );
               for ( retstruct.precision = 0; buffer[ *position ] == '#'; ++( *position ) )
                  {
                  ++retstruct.precision;
                  }
               }
            if ( buffer[ *position ] == '-' )
               {
               retstruct.minus = TRUE;
               ++( *position );
               }
            return &retstruct;
         case '^':
            retstruct.type = DOUBLE;
            retstruct.exponential = TRUE;
            for ( retstruct.width = 1; buffer[ *position ] == '^'; ++( *position ) )
               {
               ++retstruct.width;
               }
            return &retstruct;
         
         }
      }					/* end of loop */
      
   return &retstruct;
   }
   
/***************************************************************

        FUNCTION:       bwb_cr()

        DESCRIPTION:

***************************************************************/

int
prn_cr( char *buffer, FILE *f )
   {
   register int c;
   int loop;

   /* find the end of the buffer */

   for ( c = 0; buffer[ c ] != '\0'; ++c )
      {
      }

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in prn_cr(): initial c is <%d>", c );
   bwb_debug( bwb_ebuf );
   #endif

   /* back up through any whitespace */

   loop = TRUE;
   while ( loop == TRUE )
      {
      switch( buffer[ c ] )
         {
         case ' ':                              /* if whitespace */
         case '\t':
         case 0:

            #if INTENSIVE_DEBUG
            sprintf( bwb_ebuf, "in prn_cr(): backup: c is <%d>, char <%c>[0x%x]",
               c, buffer[ c ], buffer[ c ] );
            bwb_debug( bwb_ebuf );
            #endif

            --c;                                /* back up */
            if ( c < 0 )                        /* check position */
               {
               loop = FALSE;
               }
            break;

         default:                               /* else break out */
            #if INTENSIVE_DEBUG
            sprintf( bwb_ebuf, "in prn_cr(): breakout: c is <%d>, char <%c>[0x%x]",
               c, buffer[ c ], buffer[ c ] );
            bwb_debug( bwb_ebuf );
            #endif
            loop = FALSE;
            break;
         }
      }

   if ( buffer[ c ] == ';' )
      {

      #if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in prn_cr(): concluding <;> detected." );
      bwb_debug( bwb_ebuf );
      #endif

      return FALSE;
      }

   else
      {
      xprintf( f, "\n" );
      return TRUE;
      }

   }

/***************************************************************

        FUNCTION:       xprintf()

        DESCRIPTION:

***************************************************************/

int
xprintf( FILE *f, char *buffer )
   {
   char *p;

   /* DO NOT try anything so stupid as to run bwb_debug() from 
      here, because it will create an endless loop. And don't
      ask how I know. */

   for ( p = buffer; *p != '\0'; ++p )
      {
      xputc( f, *p );
      }

   return TRUE;
   }

/***************************************************************

        FUNCTION:       xputc()

        DESCRIPTION:

***************************************************************/

int
xputc( FILE *f, char c )
   {
   static int tab_pending = FALSE;
   register int i;

   /* check for pending TAB */

   if ( tab_pending == TRUE )
      {
      if ( (int) c < ( * prn_getcol( f ) ) )
         {
         xxputc( f, '\n' );
         }
      while( ( * prn_getcol( f )) < (int) c )
         {
         xxputc( f, ' ' );
         }
      tab_pending = FALSE;
      return TRUE;
      }

   /* check c for specific output options */

   switch( c )
      {
      case PRN_TAB:
         tab_pending = TRUE;
         break;

      case '\t':
         while( ( (* prn_getcol( f )) % 14 ) != 0 )
            {
            xxputc( f, ' ' );
            }
         break;

      default:
         xxputc( f, c );
         break;
      }

   return TRUE;

   }

/***************************************************************

        FUNCTION:       xxputc()

        DESCRIPTION:

***************************************************************/

int
xxputc( FILE *f, char c )
   {

   /* check to see if width has been exceeded */

   if ( * prn_getcol( f ) >= prn_getwidth( f ))
      {
      fputc( '\n', f );			/* output LF */
      * prn_getcol( f ) = 1;		/* and reset */
      }

   /* adjust the column counter */

   if ( c == '\n' )
      {
      * prn_getcol( f ) = 1;
      }
   else
      {
      ++( * prn_getcol( f ));
      }
      
   /* now output the character */

   return fputc( c, f );

   }

/***************************************************************

        FUNCTION:       prn_getcol()

        DESCRIPTION:

***************************************************************/

int *
prn_getcol( FILE *f )
   {
   register int n;
   static int dummy_pos;

   if (( f == stdout ) || ( f == stderr ))
      {
      return &prn_col;
      }

   for ( n = 0; n < DEF_DEVICES; ++n )
      {
      if ( dev_table[ n ].cfp == f )
         {
         return &( dev_table[ n ].col );
         }
      }

   /* search failed */

   #if PROG_ERRORS
   bwb_error( "in prn_getcol(): failed to find file pointer" );
   #else
   bwb_error( err_devnum );
   #endif

   return &dummy_pos;

   }

/***************************************************************

        FUNCTION:       prn_getwidth()

        DESCRIPTION:

***************************************************************/

int
prn_getwidth( FILE *f )
   {
   register int n;

   if (( f == stdout ) || ( f == stderr ))
      {
      return prn_width;
      }

   for ( n = 0; n < DEF_DEVICES; ++n )
      {
      if ( dev_table[ n ].cfp == f )
         {
         return dev_table[ n ].width;
         }
      }

   /* search failed */

   #if PROG_ERRORS
   bwb_error( "in prn_getwidth(): failed to find file pointer" );
   #else
   bwb_error( err_devnum );
   #endif

   return 1;

   }

/***************************************************************

        FUNCTION:       prn_precision()

        DESCRIPTION:

***************************************************************/

int
prn_precision( struct bwb_variable *v )
   {
   int max_precision = 6;
   double dval, d;
   int r;

   /* check for double value */

   if ( v->type == DOUBLE )
      {
      max_precision = 12;
      }

   /* get the value in dval */

   dval = var_getdval( v );

   /* cycle through until precision is found */

   d = 1.0;
   for ( r = 0; r < max_precision; ++r )
      {

      #if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in prn_precision(): fmod( %f, %f ) = %.12f",
         dval, d, fmod( dval, d ) );
      bwb_debug( bwb_ebuf );
      #endif

      if ( fmod( dval, d ) < 0.0000001 )
         {
         return r;
         }
      d /= 10;
      }

   /* return */

   return r;

   }

/***************************************************************

        FUNCTION:       fnc_tab()

        DESCRIPTION:    

***************************************************************/

struct bwb_variable *
fnc_tab( int argc, struct bwb_variable *argv )
   {
   static struct bwb_variable nvar;
   static int init = FALSE;
   static char t_string[ 4 ];
   static char nvar_name[] = "(tmp)";
   bstring *b;
   
   /* initialize nvar if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, (int) STRING );
/*      nvar.name = nvar_name; */
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
   t_string[ 1 ] = (char) var_getival( &( argv[ 0 ] ));
   t_string[ 2 ] = '\0';

   b = var_getsval( &nvar );
   str_ctob( b, t_string );

   return &nvar;
   }

/***************************************************************

        FUNCTION:       fnc_spc()

        DESCRIPTION:    

***************************************************************/

struct bwb_variable *
fnc_spc( int argc, struct bwb_variable *argv )
   {
   return fnc_space( argc, argv );
   }

/***************************************************************

        FUNCTION:       fnc_space()

        DESCRIPTION:    

***************************************************************/

struct bwb_variable *
fnc_space( int argc, struct bwb_variable *argv )
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
      if ( ( tbuf = calloc( MAXSTRINGSIZE + 1, sizeof( char ) )) == NULL )
         {
         bwb_error( err_getmem );
         }
      }

   tbuf[ 0 ] = '\0';
   spaces = var_getival( &( argv[ 0 ] ));

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

        FUNCTION:       fnc_pos()

        DESCRIPTION:    

***************************************************************/

struct bwb_variable *
fnc_pos( int argc, struct bwb_variable *argv )
   {
   static struct bwb_variable nvar;
   static int init = FALSE;
   static char nvar_name[] = "<pos()>";

   /* initialize nvar if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, (int) INTEGER );
/*      nvar.name = nvar_name; */
      }

   * var_findival( &nvar, nvar.array_pos ) = prn_col;

   return &nvar;
   }

/***************************************************************

        FUNCTION:       fnc_err()

        DESCRIPTION:    

***************************************************************/

struct bwb_variable *
fnc_err( int argc, struct bwb_variable *argv )
   {
   static struct bwb_variable nvar;
   static int init = FALSE;
   static char nvar_name[] = "<err()>";

   /* initialize nvar if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, (int) INTEGER );
/*      nvar.name = nvar_name; */
      }

   * var_findival( &nvar, nvar.array_pos ) = err_number;

   return &nvar;
   }

/***************************************************************

        FUNCTION:       fnc_erl()

        DESCRIPTION:    

***************************************************************/

struct bwb_variable *
fnc_erl( int argc, struct bwb_variable *argv )
   {
   static struct bwb_variable nvar;
   static int init = FALSE;
   static char nvar_name[] = "<erl()>";

   /* initialize nvar if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, (int) INTEGER );
/*      nvar.name = nvar_name; */
      }

   * var_findival( &nvar, nvar.array_pos ) = err_line;

   return &nvar;
   }

/***************************************************************

        FUNCTION:       bwb_debug()

        DESCRIPTION:    This function is called to display
                        debugging messages in Bywater BASIC.
                        It does not break out at the current
                        point (as bwb_error() does).

***************************************************************/

#if PERMANENT_DEBUG
int
bwb_debug( char *message )
   {
   char tbuf[ MAXSTRINGSIZE + 1 ];

   fflush( stdout );
   fflush( errfdevice );
   if ( prn_col != 1 )
      {
      xprintf( errfdevice, "\n" );
      }
   sprintf( tbuf, "DEBUG %s\n", message );
   xprintf( errfdevice, tbuf );

   return TRUE;
   }
#endif

/***************************************************************

        FUNCTION:       bwb_lerror()

        DESCRIPTION:    This function implements the BASIC ERROR
                        command.

***************************************************************/

struct bwb_line *
bwb_lerror( struct bwb_line *l )
   {
   char tbuf[ MAXSTRINGSIZE + 1 ];
   int n;

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_lerror(): entered function " );
   bwb_debug( bwb_ebuf );
   #endif

   /* Check for argument */

   adv_ws( l->buffer, &( l->position ) );
   switch( l->buffer[ l->position ] )
      {
      case '\0':
      case '\n':
      case '\r':
      case ':':
         bwb_error( err_incomplete );
         l->next->position = 0;
         return l->next;
      default:
         break;
      }

   /* get the variable name or numerical constant */

   adv_element( l->buffer, &( l->position ), tbuf );
   n = atoi( tbuf );

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_lerror(): error number is <%d> ", n );
   bwb_debug( bwb_ebuf );
   #endif

   /* check the line number value */

   if ( ( n < 0 ) || ( n >= N_ERRORS ))
      {
      sprintf( bwb_ebuf, "Error number %d is out of range", n );
      bwb_xerror( bwb_ebuf );
      return l;
      }

   bwb_xerror( err_table[ n ] );

   return l;

   }

/***************************************************************

        FUNCTION:       bwb_error()

        DESCRIPTION:    This function is called to handle errors
                        in Bywater BASIC.  It displays the error
                        message, then calls the break_handler()
                        routine.

***************************************************************/

int
bwb_error( char *message )
   {
   register int e;
   static char tbuf[ MAXSTRINGSIZE + 1 ];	/* must be permanent */

   /* try to find the error message to identify the error number */

   err_line = bwb_number;		/* set error line number */
   for ( e = 0; e < N_ERRORS; ++e )
      {
      if ( message == err_table[ e ] )	/* set error number */
         {
         err_number = e;
         e = N_ERRORS;			/* break out of loop quickly */
         }
      }

   /* if err_gosubn is not set, then use xerror routine */

   if ( err_gosubn == 0 )
      {
      return bwb_xerror( message );
      }

   /* err_gosubn is not set; call user-defined error subroutine */

   sprintf( tbuf, "GOSUB %d", err_gosubn );
   cnd_xpline( bwb_l, tbuf );
   return TRUE;

   }

/***************************************************************

        FUNCTION:       bwb_xerror()

        DESCRIPTION:    This function is called by bwb_error()
                        in Bywater BASIC.  It displays the error
                        message, then calls the break_handler()
                        routine.

***************************************************************/

int
bwb_xerror( char *message )
   {
   static char tbuf[ MAXSTRINGSIZE + 1 ];	/* this memory should be 
						   permanent in case of memory
						   overrun errors */

   fflush( stdout );
   fflush( errfdevice );
   if ( prn_col != 1 )
      {
      xprintf( errfdevice, "\n" );
      }
   sprintf( tbuf, "\n%s %d: %s\n", ERROR_HEADER, bwb_number, message );
   xprintf( errfdevice, tbuf );
   break_handler();

   return FALSE;
   }

/***************************************************************

        FUNCTION:       matherr()

        DESCRIPTION:    This function is called to handle math
                        errors in Bywater BASIC.  It displays
                        the error message, then calls the
                        break_handler() routine.

***************************************************************/

int
matherr( struct exception *except )
   {

   perror( MATHERR_HEADER );
   break_handler();

   return FALSE;
   }

static struct bwb_variable * 
bwb_esetovar( struct exp_ese *e )
   {
   static struct bwb_variable b;
   static init = FALSE;

   var_make( &b, e->type );

   switch( e->type )
      {
      case STRING:
         str_btob( var_findsval( &b, b.array_pos ), exp_getsval( e ) );
         break;
      case DOUBLE:
         * var_finddval( &b, b.array_pos ) = e->dval;
         break;
      case INTEGER:
         * var_findival( &b, b.array_pos ) = e->ival;
         break;
      default:
         * var_findfval( &b, b.array_pos ) = e->fval;
         break;
      }

   return &b;

   }

/***************************************************************

        FUNCTION:       bwb_width()

        DESCRIPTION:

***************************************************************/

struct bwb_line *
bwb_width( struct bwb_line *l )
   {
   int req_devnumber;
   int req_width;
   struct exp_ese *e;
   char tbuf[ MAXSTRINGSIZE + 1 ];
   int pos;

   /* detect device number if present */

   req_devnumber = -1;
   adv_ws( l->buffer, &( l->position ) );
   
   if ( l->buffer[ l->position ] == '#' )
      {
      ++( l->position );
      adv_element( l->buffer, &( l->position ), tbuf );
      pos = 0;
      e = bwb_exp( tbuf, FALSE, &pos );
      adv_ws( l->buffer, &( l->position ) );
      if ( l->buffer[ l->position ] == ',' )
         {
         ++( l->position );
         }
      else
         {
	 #if PROG_ERRORS
         bwb_error( "in bwb_width(): no comma after #n" );
         #else
         bwb_error( err_syntax );
         #endif
         l->next->position = 0;
         return l->next;
         }

      req_devnumber = exp_getival( e );

      /* check the requested device number */
      
      if ( ( req_devnumber < 0 ) || ( req_devnumber >= DEF_DEVICES ))
         {
         #if PROG_ERRORS
         bwb_error( "in bwb_width(): Requested device number is out of range." );
         #else
         bwb_error( err_devnum );
         #endif
         l->next->position = 0;
         return l->next;
         }

      #if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_width(): device number is <%d>",
         req_devnumber );
      bwb_debug( bwb_ebuf );
      #endif

      }

   /* read the width requested */

   e = bwb_exp( l->buffer, FALSE, &( l->position ));
   req_width = exp_getival( e );

   /* check the width */

   if ( ( req_width < 1 ) || ( req_width > 255 ))
      {
      #if PROG_ERRORS
      bwb_error( "in bwb_width(): Requested width is out of range (1-255)" );
      #else
      bwb_error( err_valoorange );
      #endif
      }

   /* assign the width */

   if ( req_devnumber == -1 )
      {
      prn_width = req_width;
      }
   else
      {
      dev_table[ req_devnumber ].width = req_width;
      }

   /* return */

   return l->next;
   }

/***************************************************************

        FUNCTION:       bwb_write()

        DESCRIPTION:

***************************************************************/

struct bwb_line *
bwb_write( struct bwb_line *l )
   {
   struct exp_ese *e;
   int req_devnumber;
   int pos;
   FILE *fp;
   char tbuf[ MAXSTRINGSIZE + 1 ];
   int loop;
   static struct bwb_variable nvar;
   static int init = FALSE;

   /* initialize variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, SINGLE );
      }

   /* detect device number if present */

   adv_ws( l->buffer, &( l->position ) );
   
   if ( l->buffer[ l->position ] == '#' )
      {
      ++( l->position );
      adv_element( l->buffer, &( l->position ), tbuf );
      pos = 0;
      e = bwb_exp( tbuf, FALSE, &pos );
      adv_ws( l->buffer, &( l->position ) );
      if ( l->buffer[ l->position ] == ',' )
         {
         ++( l->position );
         }
      else
         {
	 #if PROG_ERRORS
         bwb_error( "in bwb_write(): no comma after #n" );
         #else
         bwb_error( err_syntax );
         #endif
         l->next->position = 0;
         return l->next;
         }

      req_devnumber = exp_getival( e );

      /* check the requested device number */
      
      if ( ( req_devnumber < 0 ) || ( req_devnumber >= DEF_DEVICES ))
         {
         #if PROG_ERRORS
         bwb_error( "in bwb_write(): Requested device number is out of range." );
         #else
         bwb_error( err_devnum );
         #endif
         l->next->position = 0;
         return l->next;
         }

      if (( dev_table[ req_devnumber ].mode == DEVMODE_CLOSED ) ||
         ( dev_table[ req_devnumber ].mode == DEVMODE_AVAILABLE ))
         {
         #if PROG_ERRORS
         bwb_error( "in bwb_write(): Requested device number is not open." );
         #else
         bwb_error( err_devnum );
         #endif

         l->next->position = 0;
         return l->next;
         }

      if ( dev_table[ req_devnumber ].mode != DEVMODE_OUTPUT )
         {
         #if PROG_ERRORS
         bwb_error( "in bwb_write(): Requested device is not open for OUTPUT." );
         #else
         bwb_error( err_devnum );
         #endif

         l->next->position = 0;
         return l->next;
         }

      #if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_write(): device number is <%d>",
         req_devnumber );
      bwb_debug( bwb_ebuf );
      #endif

      /* look up the requested device in the device table */

      fp = dev_table[ req_devnumber ].cfp;

      }

   else
      {
      fp = stdout;
      }

   /* be sure there is an element to print */ 

   adv_ws( l->buffer, &( l->position ) );
   loop = TRUE;
   switch( l->buffer[ l->position ] )
      {
      case '\n':
      case '\r':
      case '\0':
      case ':':
         loop = FALSE;
         break;
      }

   /* loop through elements */

   while ( loop == TRUE )
      {

      /* get the next element */

      e = bwb_exp( l->buffer, FALSE, &( l->position ));

      /* perform type-specific output */

      switch( e->type )
         {
         case STRING:
            xputc( fp, '\"' );
            str_btoc( tbuf, exp_getsval( e ) );
            xprintf( fp, tbuf );
            xputc( fp, '\"' );
            #if INTENSIVE_DEBUG
            sprintf( bwb_ebuf, "in bwb_write(): output string element <\"%s\">",
               tbuf );
            bwb_debug( bwb_ebuf );
            #endif
            break;
         default:
            * var_findfval( &nvar, nvar.array_pos ) =
               exp_getfval( e );
            sprintf( tbuf, " %.*f", prn_precision( &nvar ), 
               var_getfval( &nvar ) );
            xprintf( fp, tbuf );
            #if INTENSIVE_DEBUG
            sprintf( bwb_ebuf, "in bwb_write(): output numerical element <%s>",
               tbuf );
            bwb_debug( bwb_ebuf );
            #endif
            break;
         }				/* end of case for type-specific output */

      /* seek a comma at end of element */

      adv_ws( l->buffer, &( l->position ) );
      if ( l->buffer[ l->position ] == ',' )
         {
         xputc( fp, ',' );
         ++( l->position );
         }

      /* no comma: end the loop */

      else
         {
         loop = FALSE;
         }

      }					/* end of loop through elements */

   /* print LF */

   xputc( fp, '\n' );

   /* return */

   l->next->position = 0;
   return l->next;
   }

