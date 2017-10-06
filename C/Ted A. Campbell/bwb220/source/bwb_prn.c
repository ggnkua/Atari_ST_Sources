/***************************************************************

	bwb_prn.c       Print and Error-Handling Commands
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

/* Prototypes for functions visible only to this file */

int prn_col = 1;
static int prn_width = 80;	/* default width for stdout */

struct prn_fmt
   {
   int type;			/* STRING, NUMBER, SINGLE, or NUMBER */
   int exponential;		/* TRUE = use exponential notation */
   int right_justified;		/* TRUE = right justified else left justified */
   int width;			/* width of main section */
   int precision;		/* width after decimal point */
   int commas;                  /* use commas every three steps */
   int sign;			/* prefix sign to number */
   int money;			/* prefix money sign to number */
   int fill;			/* ASCII value for fill character, normally ' ' */
   int minus;			/* postfix minus sign to number */
   };

#if ANSI_C
static int prn_cr( char *buffer, FILE *f );
static struct prn_fmt *get_prnfmt( char *buffer, int *position, FILE *f );
static int bwb_xerror( char *message );
static int xxputc( FILE *f, char c );
static int xxxputc( FILE *f, char c );
static struct bwb_variable * bwb_esetovar( struct exp_ese *e );
#else
static int prn_cr();
static struct prn_fmt *get_prnfmt();
static int bwb_xerror();
static int xxputc();
static int xxxputc();
static struct bwb_variable * bwb_esetovar();
#endif


/***************************************************************

        FUNCTION:       bwb_print()

        DESCRIPTION:    This function implements the BASIC PRINT
                        command.

	SYNTAX:		PRINT [# device-number,][USING format-string$;] expressions...

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_print( struct bwb_line *l )
#else
struct bwb_line *
bwb_print( l )
   struct bwb_line *l;
#endif
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

      /* Revised to CALLOC pass-thru call by JBV */
      if ( ( s_buffer = CALLOC( MAXSTRINGSIZE + 1, sizeof(char), "bwb_print") ) == NULL )
         {
#if PROG_ERRORS
         bwb_error( "in bwb_print(): failed to get memory for s_buffer" );
#else
         bwb_error( err_getmem );
#endif
         }
      }

   /* advance beyond whitespace and check for the '#' sign */

   adv_ws( l->buffer, &( l->position ) );

#if COMMON_CMDS
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
         return bwb_zline( l );
         }

      req_devnumber = (int) exp_getnval( v );

      /* check the requested device number */

      if ( ( req_devnumber < 0 ) || ( req_devnumber >= DEF_DEVICES ))
         {
#if PROG_ERRORS
         bwb_error( "in bwb_input(): Requested device number is out of range." );
#else
         bwb_error( err_devnum );
#endif
         return bwb_zline( l );
         }

      if (( dev_table[ req_devnumber ].mode == DEVMODE_CLOSED ) ||
         ( dev_table[ req_devnumber ].mode == DEVMODE_AVAILABLE ))
         {
#if PROG_ERRORS
         bwb_error( "in bwb_input(): Requested device number is not open." );
#else
         bwb_error( err_devnum );
#endif

         return bwb_zline( l );
         }

      if ( dev_table[ req_devnumber ].mode != DEVMODE_OUTPUT )
         {
#if PROG_ERRORS
         bwb_error( "in bwb_print(): Requested device is not open for OUTPUT." );
#else
         bwb_error( err_devnum );
#endif

         return bwb_zline( l );
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

#else
   fp = stdout;
#endif				/* COMMON_CMDS */

   bwb_xprint( l, fp );

   return bwb_zline( l );
   }

/***************************************************************

        FUNCTION:       bwb_xprint()

	DESCRIPTION:    This function implements the BASIC PRINT
			command, utilizing a specified file our
			output device.

***************************************************************/

#if ANSI_C
int
bwb_xprint( struct bwb_line *l, FILE *f )
#else
int
bwb_xprint( l, f )
   struct bwb_line *l;
   FILE *f;
#endif
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
   register int i, j; /* JBV */
   int dig_pos, dec_pos; /* JBV */
   char tbuf[ MAXSTRINGSIZE + 1 ]; /* JBV */
#if INTENSIVE_DEBUG || TEST_BSTRING
   bstring *b;
#endif

   /* initialize buffers if necessary */

   if ( init == FALSE )
      {
      init = TRUE;

      /* Revised to CALLOC pass-thru call by JBV */
      if ( ( format_string = CALLOC( MAXSTRINGSIZE + 1, sizeof(char), "bwb_xprint") ) == NULL )
         {
#if PROG_ERRORS
         bwb_error( "in bwb_xprint(): failed to get memory for format_string" );
#else
         bwb_error( err_getmem );
#endif
         }
      /* Revised to CALLOC pass-thru call by JBV */
      if ( ( output_string = CALLOC( MAXSTRINGSIZE + 1, sizeof(char), "bwb_xprint") ) == NULL )
         {
#if PROG_ERRORS
         bwb_error( "in bwb_xprint(): failed to get memory for output_string" );
#else
         bwb_error( err_getmem );
#endif
         }
      /* Revised to CALLOC pass-thru call by JBV */
      if ( ( element = CALLOC( MAXSTRINGSIZE + 1, sizeof(char), "bwb_xprint") ) == NULL )
         {
#if PROG_ERRORS
         bwb_error( "in bwb_xprint(): failed to get memory for element buffer" );
#else
         bwb_error( err_getmem );
#endif
         }
      /* Revised to CALLOC pass-thru call by JBV */
      if ( ( prnbuf = CALLOC( MAXSTRINGSIZE + 1, sizeof(char), "bwb_xprint") ) == NULL )
         {
#if PROG_ERRORS
         bwb_error( "in bwb_xprint(): failed to get memory for prnbuf" );
#else
         bwb_error( err_getmem );
#endif
         }
      }

   /* Detect USING Here */

   fs_pos = -1;

   /* get "USING" in format_string */

   p = l->position;
   adv_element( l->buffer, &p, format_string );
   bwb_strtoupper( format_string );

#if COMMON_CMDS

   /* check to be sure */

   if ( strcmp( format_string, CMD_XUSING ) == 0 )
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

#endif 			/* COMMON_CMDS */

   /* if no arguments, simply print CR and return */

   adv_ws( l->buffer, &( l->position ) );
   switch( l->buffer[ l->position ] )
      {
      case '\0':
      case '\n':
      case '\r':
      case ':':
         prn_xprintf( f, "\n" );
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
      sprintf( bwb_ebuf, "in bwb_xprint(): op <%d> type <%d>",
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

#if COMMON_CMDS

         format = get_prnfmt( format_string, &fs_pos, f );

#if INTENSIVE_DEBUG
	 sprintf( bwb_ebuf, "in bwb_xprint(): format type <%d> width <%d>",
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
               if ( format->width == -1 ) /* JBV */
                  sprintf( output_string, "%s", element );
               else sprintf( output_string, "%.*s", format->width, element );

#if INTENSIVE_DEBUG
               sprintf( bwb_ebuf, "in bwb_xprint(): output string <%s>",
                  output_string );
               bwb_debug( bwb_ebuf );
#endif

               prn_xxprintf( f, output_string ); /* Was prn_xprintf (JBV) */
               break;

	    case NUMBER:
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
                  /*------------------------------------------------------*/
                  /* NOTE: Width and fill have no effect on C exponential */
                  /* format (JBV)                                         */
                  /*------------------------------------------------------*/
		  if ( format->sign == TRUE ) /* Added by JBV */
                     sprintf( output_string, "%+e", exp_getnval( e ) );
		  else
                     sprintf( output_string, "%e", exp_getnval( e ) );
		  }
	       else
		  {
                  /*---------------------------------------------------*/
                  /* NOTE: Minus, commas, and money are only valid for */
                  /* floating point format (JBV)                       */
                  /*---------------------------------------------------*/
		  if ( format->sign == TRUE ) /* Added by JBV */
		  sprintf( output_string, "%+*.*f",
		     format->width, format->precision, exp_getnval( e ) );
		  else if ( format->minus == TRUE ) /* Added by JBV */
                  {
		      sprintf( output_string, "%*.*f",
		         format->width, format->precision, exp_getnval( e ) );
                      for (i = 0; i < strlen( output_string ); ++i )
                      {
                          if ( output_string[ i ] != ' ' )
                          {
                              if ( output_string[ i ] == '-' )
                              {
                                  output_string[ i ] = ' ';
                                  strcat( output_string, "-" );
                              }
                              else strcat( output_string, " " );
                              break;
                          }
                      }
                  }
		  else
		  sprintf( output_string, "%*.*f",
		     format->width, format->precision, exp_getnval( e ) );

                  if ( format->commas == TRUE ) /* Added by JBV */
                  {
                      dig_pos = -1;
                      dec_pos = -1;
                      for ( i = 0; i < strlen( output_string ); ++i )
                      {
                          if ( ( isdigit( output_string[ i ] ) != 0 )
                          && ( dig_pos == -1 ) )
                             dig_pos = i;
                          if ( ( output_string[ i ] == '.' )
                          && ( dec_pos == -1 ) )
                             dec_pos = i;
                          if ( ( dig_pos != -1 ) && ( dec_pos != -1 ) ) break;
                      }
                      if ( dec_pos == -1 ) dec_pos = strlen( output_string );
                      j = 0;
                      for ( i = 0; i < strlen( output_string ); ++i )
                      {
                          if ( ( ( dec_pos - i ) % 3 == 0 )
                          && ( i > dig_pos ) && ( i < dec_pos ) )
                          {
                              tbuf[ j ] = ',';
                              ++j;
                              tbuf[ j ] = '\0';
                          }
                          tbuf[ j ] = output_string[ i ];
                          ++j;
                          tbuf[ j ] = '\0';
                      }
                      strcpy( output_string,
                         &tbuf[ strlen( tbuf ) - strlen( output_string ) ] );
                  }

                  if ( format->money == TRUE ) /* Added by JBV */
                  {
                      for ( i = 0; i < strlen( output_string ); ++i )
                      {
                          if ( output_string[ i ] != ' ' )
                          {
                              if ( i > 0 )
                              {
                                  if ( isdigit( output_string[ i ] ) == 0 )
                                  {
                                      output_string[ i - 1 ]
                                         = output_string[ i ];
                                      output_string[ i ] = '$';
                                  }
                                  else output_string[ i - 1 ] = '$';
                              }
                              break;
                          }
                      }
                  }

		  }

                  if ( format->fill == '*' ) /* Added by JBV */
                  for ( i = 0; i < strlen( output_string ); ++i )
                  {
                     if ( output_string[ i ] != ' ' ) break;
                     output_string[ i ] = '*';
                  }

#if INTENSIVE_DEBUG
	       sprintf( bwb_ebuf, "in bwb_xprint(): output number <%f> string <%s>",
		  exp_getnval( e ), output_string );
	       bwb_debug( bwb_ebuf );
#endif

               prn_xxprintf( f, output_string ); /* Was prn_xprintf (JBV) */
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

#endif			/* COMMON_CMDS */

         }

      /* not a format string: use defaults */

      else if ( strlen( element ) > 0 )
         {

         switch( e->type )
            {
            case STRING:
               prn_xprintf( f, element );
               break;
            default:
#if NUMBER_DOUBLE
               sprintf( prnbuf, " %.*lf", prn_precision( bwb_esetovar( e )),
                  exp_getnval( e ) );
#else
               sprintf( prnbuf, " %.*f", prn_precision( bwb_esetovar( e )),
                  exp_getnval( e ) );
#endif
               prn_xprintf( f, prnbuf );
               break;
            }
         }

      /* check the position to see if the loop should continue */

      adv_ws( l->buffer, &( l->position ) );
      switch( l->buffer[ l->position ] )
         {
#if OLDSTUFF
         case ':':		/* end of line segment */
	    loop = FALSE;
	    break;
         case '\0':		/* end of buffer */
         case '\n':
         case '\r':
	    loop = FALSE;
            break;
#endif
         case ',':		/* tab over */
            /* Tab only if there's no format specification! (JBV) */
            if (( fs_pos == -1 ) || ( strlen( element ) == 0 ))
               xputc( f, '\t' );
            ++l->position;
            adv_ws( l->buffer, &( l->position ) );
            break;
         case ';':		/* concatenate strings */
            ++l->position;
            adv_ws( l->buffer, &( l->position ) );
            break;
         default:
            loop = FALSE;
            break;
         }

      }				/* end of loop through print elements */

   if (( fs_pos > -1 ) && ( strlen( element ) > 0 ))
      format = get_prnfmt( format_string, &fs_pos, f ); /* Finish up (JBV) */

   /* call prn_cr() to print a CR if it is not overridden by a
      concluding ';' mark */

   prn_cr( l->buffer, f );

   return TRUE;

   }                            /* end of function bwb_xprint() */

#if COMMON_CMDS

/***************************************************************

        FUNCTION:       get_prnfmt()

	DESCRIPTION:    This function gets the PRINT USING
			format string, returning a structure
			to the format.

***************************************************************/

#if ANSI_C
static struct prn_fmt *
get_prnfmt( char *buffer, int *position, FILE *f )
#else
static struct prn_fmt *
get_prnfmt( buffer, position, f )
   char *buffer;
   int *position;
   FILE *f;
#endif
   {
   static struct prn_fmt retstruct;
   int loop;

   /* set some defaults */

   retstruct.precision = 0;
   retstruct.type = FALSE;
   retstruct.exponential = FALSE;
   retstruct.right_justified = FALSE;
   retstruct.commas = FALSE;
   retstruct.sign = FALSE;
   retstruct.money = FALSE;
   retstruct.fill = ' ';
   retstruct.minus = FALSE;
   retstruct.width = 0;

   /* check for negative position */

   if ( *position < 0 )
      {
      return &retstruct;
      }

   /* advance past whitespace */

   /* adv_ws( buffer, position ); */  /* Don't think we want this (JBV) */

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
            xxputc( f, buffer[ *position ] ); /* Gotta output it (JBV) */
            ++( *position ); /* JBV */
            if (retstruct.type != FALSE) loop = FALSE; /* JBV */
            break;
         case '\0':		/* end of format string */
         case '\n':
         case '\r':
            *position = -1;
            return &retstruct;
         case '_':		/* print next character as literal */
            ++( *position );
            xxputc( f, buffer[ *position ] ); /* Not xputc, no tabs (JBV) */
            ++( *position );
            break;

	 case '!':
            retstruct.type = STRING;
            retstruct.width = 1;
            ++( *position ); /* JBV */
            return &retstruct;

	 case '&': /* JBV */
            retstruct.type = STRING;
            retstruct.width = -1; 
            ++( *position );
            return &retstruct;

	 case '\\':

#if INTENSIVE_DEBUG
            sprintf( bwb_ebuf, "in get_prnfmt(): found \\" );
            bwb_debug( bwb_ebuf );
#endif

	    retstruct.type = STRING;
	    ++retstruct.width;
	    ++( *position );
	    for ( ; buffer[ *position ] == ' '; ++( *position ) )
               {
               ++retstruct.width;
               }
            if ( buffer[ *position ] == '\\' )
	       {
	       ++retstruct.width;
               ++( *position );
               }
            return &retstruct;
         case '$':
            ++retstruct.width; /* JBV */
            ++( *position );
            retstruct.money = TRUE;
            if ( buffer[ *position ] == '$' )
               {
               ++retstruct.width; /* JBV */
               ++( *position );
               }
            break;
         case '*':
            ++retstruct.width; /* JBV */
            ++( *position );
            retstruct.fill = '*';
            if ( buffer[ *position ] == '*' )
               {
               ++retstruct.width; /* JBV */
               ++( *position );
               }
            break;
         case '+':
            ++( *position );
            retstruct.sign = TRUE;
            break;
         case '#':
            retstruct.type = NUMBER;		/* for now */
            /* ++( *position ); */  /* Removed by JBV */
            /* The initial condition shouldn't be retstruct.width = 1 (JBV) */
            for ( ; buffer[ *position ] == '#'; ++( *position ) )
               {
               ++retstruct.width;
               }
            if ( buffer[ *position ] == ',' )
               {
               retstruct.commas = TRUE;
               ++retstruct.width; /* JBV */
               ++( *position ); /* JBV */
               }
            if ( buffer[ *position ] == '.' )
               {
	       retstruct.type = NUMBER;
	       ++retstruct.width;
               ++( *position );
               for ( retstruct.precision = 0; buffer[ *position ] == '#'; ++( *position ) )
                  {
		  ++retstruct.precision;
		  ++retstruct.width;
                  }
               }
            if ( buffer[ *position ] == '-' )
               {
               retstruct.minus = TRUE;
               ++( *position );
               }
            return &retstruct;

	 case '^':
            retstruct.type = NUMBER;
            retstruct.exponential = TRUE;
            for ( retstruct.width = 1; buffer[ *position ] == '^'; ++( *position ) )
               {
               ++retstruct.width;
               }
            return &retstruct;

	 default: /* JBV */
            xxputc( f, buffer[ *position ] ); /* Gotta output it (JBV) */
            ++( *position );
            break;

         }
      }					/* end of loop */

   return &retstruct;
   }

#endif

/***************************************************************

        FUNCTION:       prn_cr()

	DESCRIPTION:    This function outputs a carriage-return
			to a specified file or output device.

***************************************************************/

#if ANSI_C
static int
prn_cr( char *buffer, FILE *f )
#else
static int
prn_cr( buffer, f )
   char *buffer;
   FILE *f;
#endif
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
      prn_xprintf( f, "\n" );
      return TRUE;
      }

   }

/***************************************************************

        FUNCTION:       prn_xprintf()

	DESCRIPTION:    This function outputs a null-terminated
			string to a specified file or output
			device.

***************************************************************/

#if ANSI_C
int
prn_xprintf( FILE *f, char *buffer )
#else
int
prn_xprintf( f, buffer )
   FILE *f;
   char *buffer;
#endif
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

        FUNCTION:       prn_xxprintf()

	DESCRIPTION:    This function outputs a null-terminated
			string to a specified file or output
			device without expanding tabs.
			Added by JBV 10/95

***************************************************************/

#if ANSI_C
int
prn_xxprintf( FILE *f, char *buffer )
#else
int
prn_xxprintf( f, buffer )
   FILE *f;
   char *buffer;
#endif
   {
   char *p;

   /* DO NOT try anything so stupid as to run bwb_debug() from
      here, because it will create an endless loop. And don't
      ask how I know. */

   for ( p = buffer; *p != '\0'; ++p )
      {
      xxputc( f, *p );
      }

   return TRUE;

   }

/***************************************************************

        FUNCTION:       xputc()

	DESCRIPTION:    This function outputs a character to a
			specified file or output device, expanding
			TABbed output approriately.

***************************************************************/

#if ANSI_C
int
xputc( FILE *f, char c )
#else
int
xputc( f, c )
   FILE *f;
   char c;
#endif
   {
   static int tab_pending = FALSE;

   /*--------------------------------------------------------------------*/
   /* Don't expand tabs if not printing to stdout or stderr (JBV 9/4/97) */
   /*--------------------------------------------------------------------*/
   if (( f != stdout ) && ( f != stderr ))
      {
      xxputc( f, c );
      return TRUE;
      }

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

	DESCRIPTION:    This function outputs a character to a
			specified file or output device, checking
			to be sure the PRINT width is within
			the bounds specified for that device.

***************************************************************/

#if ANSI_C
static int
xxputc( FILE *f, char c )
#else
static int
xxputc( f, c )
   FILE *f;
   char c;
#endif
   {

   /*--------------------------------------------------------------------*/
   /* Don't check width if not printing to stdout or stderr (JBV 9/4/97) */
   /*--------------------------------------------------------------------*/
   if (( f != stdout ) && ( f != stderr ))
      {
      return xxxputc( f, c );
      }

   /* check to see if width has been exceeded */

   if ( * prn_getcol( f ) >= prn_getwidth( f ))
      {
      xxxputc( f, '\n' );                 /* output LF */
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

   return xxxputc( f, c );

   }

/***************************************************************

	FUNCTION:       xxxputc()

	DESCRIPTION:    This function sends a character to a
			specified file or output device.

***************************************************************/

#if ANSI_C
static int
xxxputc( FILE *f, char c )
#else
static int
xxxputc( f, c )
   FILE *f;
   char c;
#endif
   {
   if (( f == stdout ) || ( f == stderr ))
      {
      return bwx_putc( c );
      }
   else
      {
      return fputc( c, f );
      }
   }

/***************************************************************

        FUNCTION:       prn_getcol()

	DESCRIPTION:    This function returns a pointer to an
			integer containing the current PRINT
			column for a specified file or device.

***************************************************************/

#if ANSI_C
int *
prn_getcol( FILE *f )
#else
int *
prn_getcol( f )
   FILE *f;
#endif
   {
   register int n;
   static int dummy_pos;

   if (( f == stdout ) || ( f == stderr ))
      {
      return &prn_col;
      }

#if COMMON_CMDS
   for ( n = 0; n < DEF_DEVICES; ++n )
      {
      if ( dev_table[ n ].cfp == f )
         {
         return &( dev_table[ n ].col );
         }
      }
#endif

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

	DESCRIPTION:    This function returns the PRINT width for
			a specified file or output device.

***************************************************************/

#if ANSI_C
int
prn_getwidth( FILE *f )
#else
int
prn_getwidth( f )
   FILE *f;
#endif
   {
   register int n;

   if (( f == stdout ) || ( f == stderr ))
      {
      return prn_width;
      }

#if COMMON_CMDS
   for ( n = 0; n < DEF_DEVICES; ++n )
      {
      if ( dev_table[ n ].cfp == f )
         {
         return dev_table[ n ].width;
         }
      }
#endif

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

	DESCRIPTION:    This function returns the level of precision
			required for a specified numerical value.

***************************************************************/

#if ANSI_C
int
prn_precision( struct bwb_variable *v )
#else
int
prn_precision( v )
   struct bwb_variable *v;
#endif
   {
   int max_precision = 6;
   bnumber nval, d;
   int r;

   /* check for double value */

   if ( v->type == NUMBER )
      {
      max_precision = 12;
      }

   /* get the value in nval */

   nval = (bnumber) fabs( (double) var_getnval( v ) );

   /* cycle through until precision is found */

   d = (bnumber) 1;
   for ( r = 0; r < max_precision; ++r )
      {

#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in prn_precision(): fmod( %f, %f ) = %.12f",
         nval, d, fmod( (double) nval, (double) d ) );
      bwb_debug( bwb_ebuf );
#endif

      if ( fmod( (double) nval, (double) d ) < 0.0000001 ) /* JBV */
         {
         return r;
         }
      d /= 10;
      }

   /* return */

   return r;

   }

/***************************************************************

        FUNCTION:       bwb_debug()

        DESCRIPTION:    This function is called to display
                        debugging messages in Bywater BASIC.
                        It does not break out at the current
                        point (as bwb_error() does).

***************************************************************/

#if PERMANENT_DEBUG

#if ANSI_C
int
bwb_debug( char *message )
#else
int
bwb_debug( message )
   char *message;
#endif
   {
   char tbuf[ MAXSTRINGSIZE + 1 ];

   fflush( stdout );
   fflush( errfdevice );
   if ( prn_col != 1 )
      {
      prn_xprintf( errfdevice, "\n" );
      }
   sprintf( tbuf, "DEBUG %s\n", message );
   prn_xprintf( errfdevice, tbuf );

   return TRUE;
   }
#endif

#if COMMON_CMDS

/***************************************************************

        FUNCTION:       bwb_lerror()

        DESCRIPTION:    This function implements the BASIC ERROR
                        command.

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_lerror( struct bwb_line *l )
#else
struct bwb_line *
bwb_lerror( l )
   struct bwb_line *l;
#endif
   {
   char tbuf[ MAXSTRINGSIZE + 1 ];
   int n;
   struct exp_ese *e; /* JBV */
   int pos; /* JBV */

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
         return bwb_zline( l );
      default:
         break;
      }

   /* get the variable name or numerical constant */

   adv_element( l->buffer, &( l->position ), tbuf );
   /* n = atoi( tbuf ); */  /* Removed by JBV */

   /* Added by JBV */
   pos = 0;
   e = bwb_exp( tbuf, FALSE, &pos );
   n = (int) exp_getnval( e );

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_lerror(): error number is <%d> ", n );
   bwb_debug( bwb_ebuf );
#endif

   /* check the line number value */

   if ( ( n < 0 ) || ( n >= N_ERRORS ))
      {
      sprintf( bwb_ebuf, "Error number %d is out of range", n );
      bwb_xerror( bwb_ebuf );
      return bwb_zline( l );
      }

   bwb_xerror( err_table[ n ] );

   return bwb_zline( l );

   }

/***************************************************************

        FUNCTION:       bwb_width()

	DESCRIPTION:    This C function implements the BASIC WIDTH
			command, setting the maximum output width
			for a specified file or output device.

	SYNTAX:		WIDTH [# device-number,] number

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_width( struct bwb_line *l )
#else
struct bwb_line *
bwb_width( l )
   struct bwb_line *l;
#endif
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
         bwb_error( "in bwb_width(): no comma after#n" );
#else
         bwb_error( err_syntax );
#endif
         return bwb_zline( l );
         }

      req_devnumber = (int) exp_getnval( e );

      /* check the requested device number */

      if ( ( req_devnumber < 0 ) || ( req_devnumber >= DEF_DEVICES ))
         {
#if PROG_ERRORS
         bwb_error( "in bwb_width(): Requested device number is out of range." );
#else
         bwb_error( err_devnum );
#endif
         return bwb_zline( l );
         }

#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_width(): device number is <%d>",
         req_devnumber );
      bwb_debug( bwb_ebuf );
#endif

      }

   /* read the width requested */

   e = bwb_exp( l->buffer, FALSE, &( l->position ));
   req_width = (int) exp_getnval( e );

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

   return bwb_zline( l );
   }

#endif			/* COMMON_CMDS */

/***************************************************************

        FUNCTION:       bwb_error()

        DESCRIPTION:    This function is called to handle errors
                        in Bywater BASIC.  It displays the error
                        message, then calls the break_handler()
                        routine.

***************************************************************/

#if ANSI_C
int
bwb_error( char *message )
#else
int
bwb_error( message )
   char *message;
#endif
   {
   register int e;
   static char tbuf[ MAXSTRINGSIZE + 1 ];	/* must be permanent */
   static struct bwb_line eline;
   int save_elevel;
   struct bwb_line *cur_l;
   int cur_mode;

   /* try to find the error message to identify the error number */

   err_number = -1;			/* just for now */
   err_line = CURTASK number;		/* set error line number */

   for ( e = 0; e < N_ERRORS; ++e )
      {
      if ( message == err_table[ e ] )	/* set error number */
         {
         err_number = e;
         e = N_ERRORS;			/* break out of loop quickly */
         }
      }

   /* set the position in the current line to the end */

   while( is_eol( bwb_l->buffer, &( bwb_l->position ) ) != TRUE )
      {
      ++( bwb_l->position );
      }

   /* if err_gosubl is not set, then use xerror routine */

   if ( strlen( err_gosubl ) == 0 )
      {
      return bwb_xerror( message );
      }

#if INTENSIVE_DEBUG
   fprintf( stderr, "!!!!! USER_CALLED ERROR HANDLER\n" );
#endif

   /* save line and mode */

   cur_l = bwb_l;
   cur_mode = CURTASK excs[ CURTASK exsc ].code;

   /* err_gosubl is set; call user-defined error subroutine */

   sprintf( tbuf, "%s %s", CMD_GOSUB, err_gosubl );
   eline.next = &CURTASK bwb_end;
   eline.position = 0;
   eline.marked = FALSE;
   eline.buffer = tbuf;
   bwb_setexec( &eline, 0, EXEC_NORM );

   /* must be executed now */

   save_elevel = CURTASK exsc;
   bwb_execline();              /* This is a call to GOSUB and will increment
				   the exsc counter above save_elevel */

   while ( CURTASK exsc != save_elevel )        /* loop until return from GOSUB loop */
      {
      bwb_execline();
      }

   cur_l->next->position = 0;
   bwb_setexec( cur_l->next, 0, cur_mode );

   return TRUE;

   }

/***************************************************************

        FUNCTION:       bwb_xerror()

        DESCRIPTION:    This function is called by bwb_error()
                        in Bywater BASIC.  It displays the error
                        message, then calls the break_handler()
                        routine.

***************************************************************/

#if ANSI_C
static int
bwb_xerror( char *message )
#else
static int
bwb_xerror( message )
   char *message;
#endif
   {

   bwx_errmes( message );

   break_handler();

   return FALSE;
   }

/***************************************************************

        FUNCTION:       bwb_esetovar()

        DESCRIPTION:    This function converts the value in expression
			stack 'e' to a bwBASIC variable structure.

***************************************************************/

#if ANSI_C
static struct bwb_variable *
bwb_esetovar( struct exp_ese *e )
#else
static struct bwb_variable *
bwb_esetovar( e )
   struct exp_ese *e;
#endif
   {
   static struct bwb_variable b;

   var_make( &b, e->type );

   switch( e->type )
      {
      case STRING:
         str_btob( var_findsval( &b, b.array_pos ), exp_getsval( e ) );
         break;
      default:
         * var_findnval( &b, b.array_pos ) = e->nval;
         break;
      }

   return &b;

   }

#if COMMON_CMDS

/***************************************************************

        FUNCTION:       bwb_write()

	DESCRIPTION:    This C function implements the BASIC WRITE
			command.

	SYNTAX:		WRITE [# device-number,] element [, element ]....

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_write( struct bwb_line *l )
#else
struct bwb_line *
bwb_write( l )
   struct bwb_line *l;
#endif
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
      var_make( &nvar, NUMBER );
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
         bwb_error( "in bwb_write(): no comma after#n" );
#else
         bwb_error( err_syntax );
#endif
         return bwb_zline( l );
         }

      req_devnumber = (int) exp_getnval( e );

      /* check the requested device number */

      if ( ( req_devnumber < 0 ) || ( req_devnumber >= DEF_DEVICES ))
         {
#if PROG_ERRORS
         bwb_error( "in bwb_write(): Requested device number is out of range." );
#else
         bwb_error( err_devnum );
#endif
         return bwb_zline( l );
         }

      if (( dev_table[ req_devnumber ].mode == DEVMODE_CLOSED ) ||
         ( dev_table[ req_devnumber ].mode == DEVMODE_AVAILABLE ))
         {
#if PROG_ERRORS
         bwb_error( "in bwb_write(): Requested device number is not open." );
#else
         bwb_error( err_devnum );
#endif

         return bwb_zline( l );
         }

      if ( dev_table[ req_devnumber ].mode != DEVMODE_OUTPUT )
         {
#if PROG_ERRORS
         bwb_error( "in bwb_write(): Requested device is not open for OUTPUT." );
#else
         bwb_error( err_devnum );
#endif

         return bwb_zline( l );
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
            prn_xprintf( fp, tbuf );
            xputc( fp, '\"' );
#if INTENSIVE_DEBUG
            sprintf( bwb_ebuf, "in bwb_write(): output string element <\"%s\">",
               tbuf );
            bwb_debug( bwb_ebuf );
#endif
            break;
         default:
            * var_findnval( &nvar, nvar.array_pos ) =
               exp_getnval( e );
#if NUMBER_DOUBLE
            sprintf( tbuf, " %.*lf", prn_precision( &nvar ),
               var_getnval( &nvar ) );
#else
            sprintf( tbuf, " %.*f", prn_precision( &nvar ),
               var_getnval( &nvar ) );
#endif
            prn_xprintf( fp, tbuf );
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

   return bwb_zline( l );
   }

#endif

