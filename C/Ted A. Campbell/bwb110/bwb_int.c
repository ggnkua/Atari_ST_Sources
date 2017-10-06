/***************************************************************f

        bwb_int.c       Line Interpretation Routines
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

#include "bwbasic.h"
#include "bwb_mes.h"

/***************************************************************

        FUNCTION:       adv_element()

        DESCRIPTION:    This function reads characters in <buffer>
                        beginning at <pos> and advances past a
                        line element, incrementing <pos> appropri-
                        ately and returning the line element in
                        <element>.

***************************************************************/

int
adv_element( char *buffer, int *pos, char *element )
   {
   int loop;                                    /* control loop */
   int e_pos;                                   /* position in element buffer */
   int str_const;                               /* boolean: building a string constant */

   /* advance beyond any initial whitespace */

   adv_ws( buffer, pos );

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in adv_element(): receieved <%s>.", &( buffer[ *pos ] ));
   bwb_debug( bwb_ebuf );
   #endif

   /* now loop while building an element and looking for an
      element terminator */

   loop = TRUE;
   e_pos = 0;
   element[ e_pos ] = '\0';
   str_const = FALSE;

   while ( loop == TRUE )
      {
      switch( buffer[ *pos ] )
         {
         case ',':                      /* element terminators */
         case ';':
         case ':':
         case '=':
         case ' ':
         case '\t':
         case '\0':
         case '\n':
         case '\r':
            if ( str_const == TRUE )
               {
               element[ e_pos ] = buffer[ *pos ];
               ++e_pos;
               ++( *pos );
               element[ e_pos ] = '\0';
               }
            else
               {
               return TRUE;
               }
            break;

         case '\"':                     /* string constant */
            element[ e_pos ] = buffer[ *pos ];
            ++e_pos;
            ++( *pos );
            element[ e_pos ] = '\0';
            if ( str_const == TRUE )    /* termination of string constant */
               {
               return TRUE;
               }
            else                        /* beginning of string constant */
               {
               str_const = TRUE;
               }
            break;

         default:
            element[ e_pos ] = buffer[ *pos ];
            ++e_pos;
            ++( *pos );
            element[ e_pos ] = '\0';
            break;
         }
      }

   /* This should not happen */

   return FALSE;

   }

/***************************************************************

        FUNCTION:       adv_ws()

        DESCRIPTION:    This function reads characters in <buffer>
                        beginning at <pos> and advances past any
                        whitespace, incrementing <pos> appropri-
                        ately.

***************************************************************/

int
adv_ws( char *buffer, int *pos )
   {
   int loop;

   loop = TRUE;
   while ( loop == TRUE )
      {
      switch( buffer[ *pos ] )
         {
         case ' ':
         case '\t':
            ++( *pos );
            break;
         default:
            return TRUE;
         }
      }

   /* This should not happen */

   return FALSE;

   }

/***************************************************************

        FUNCTION:       bwb_strtoupper()

        DESCRIPTION:    This function converts the string in
                        <buffer> to upper-case characters.

***************************************************************/

int
bwb_strtoupper( char *buffer )
   {
   char *p;

   p = buffer;
   while ( *p != '\0' )
      {
      if ( islower( *p ) != FALSE )
         {
         *p = toupper( *p );
         }
      ++p;
      }

   return TRUE;

   }

/***************************************************************

        FUNCTION:       line_start()

        DESCRIPTION:    This function reads a line buffer in
                        <buffer> beginning at the position
                        <pos> and attempts to determine (a)
                        the position of the line number in the
                        buffer (returned in <lnpos>), (b) the
                        line number at this position (returned
                        in <lnum>), (c) the position of the
                        BASIC command in the buffer (returned
                        in <cmdpos>), (d) the position of this
                        BASIC command in the command table
                        (returned in <cmdnum>), and (e) the
                        position of the beginning of the rest
                        of the line (returned in <startpos>).
                        Although <startpos> must be returned
                        as a positive integer, the other
                        searches may fail, in which case FALSE
                        will be returned in their positions.
                        <pos> is not incremented.

***************************************************************/

int
line_start( char *buffer, int *pos, int *lnpos, int *lnum, int *cmdpos,
   int *cmdnum, int *startpos )
   {
   static int position;
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
   sprintf( bwb_ebuf, "in line_start(): pos <%d> buffer <%s>", *pos,
      buffer );
   bwb_debug( bwb_ebuf );
   #endif

   /* set initial values */

   *startpos = position = *pos;
   *cmdpos = *lnpos = *pos;
   *cmdnum = *lnum = -1;

   /* check for null line */

   adv_ws( buffer, &position );
   if ( buffer[ position ] == '\0' )
      {
      #if INTENSIVE_DEBUG
      bwb_debug( "in line_start(): found NULL line" );
      #endif
      *cmdnum = getcmdnum( "REM" );
      return TRUE;
      }

   /* advance beyond the first element */

   *lnpos = position;
   adv_element( buffer, &position, tbuf );
   adv_ws( buffer, &position );

   /* test for a line number in the first element */

   if ( is_numconst( tbuf ) == TRUE )               /* a line number */
      {

      *lnum = atoi( tbuf );
      *startpos = position;                             /* temp */
      *cmdpos = position;

      adv_element( buffer, &position, tbuf );       /* advance past next element */

      #if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in line_start(): new element is <%s>", tbuf );
      bwb_debug( bwb_ebuf );
      #endif

      if ( is_cmd( tbuf, cmdnum ) == TRUE )
         {
         adv_ws( buffer, &position );
         *startpos = position;
         }
      else if ( is_let( &( buffer[ *cmdpos ] ), cmdnum ) == TRUE )
         {
         *cmdpos = -1;
         }
      else
         {
         *cmdpos = *cmdnum = -1;
         }
      }

   /* not a line number */

   else
      {
      *lnum = -1;
      *lnpos = -1;

      #if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in line_start(): no line number, element <%s>.",
         tbuf );
      bwb_debug( bwb_ebuf );
      #endif

      if ( is_cmd( tbuf, cmdnum ) == TRUE )
         {
         adv_ws( buffer, &position );
         *startpos = position;
         }
      else if ( is_let( &( buffer[ position ] ), cmdnum ) == TRUE )
         {
         adv_ws( buffer, &position );
         *cmdpos = -1;
         }
      else
         {
         *cmdpos = *cmdnum = -1;
         }
      }

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in line_start(): lnpos <%d> lnum <%d>",
      *lnpos, *lnum );
   bwb_debug( bwb_ebuf );
   sprintf( bwb_ebuf, "in line_start(): cmdpos <%d> cmdnum <%d> startpos <%d>",
      *cmdpos, *cmdnum, *startpos );
   bwb_debug( bwb_ebuf );
   #endif

   /* return */

   return TRUE;

   }

/***************************************************************

        FUNCTION:       is_cmd()

        DESCRIPTION:

***************************************************************/

int
is_cmd( char *buffer, int *cmdnum )
   {
   register int n;

   /* Convert the command name to upper case */

   bwb_strtoupper( buffer );

   /* Go through the command table and search for a match. */

   for ( n = 0; n < COMMANDS; ++n )
      {
      if ( strncmp( bwb_cmdtable[ n ].name, buffer,
         strlen( bwb_cmdtable[ n ].name )) == 0 )
         {
         *cmdnum = n;
         return TRUE;
         }
      }

   /* No command name was found */

   *cmdnum = -1;
   return FALSE;

   }

/***************************************************************

        FUNCTION:       is_let()

        DESCRIPTION:    This function tries to determine if the
                        expression in <buffer> is a LET statement
                        without the LET command specified.

***************************************************************/

int
is_let( char *buffer, int *cmdnum )
   {
   register int n, i;

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in is_let(): buffer <%s>", buffer );
   bwb_debug( bwb_ebuf );
   #endif

   /* Go through the expression and search for an assignment operator. */

   for ( n = 0; buffer[ n ] != '\0'; ++n )
      {
      switch( buffer[ n ] )
         {
         case '\"':                     /* string constant */
            ++n;
            while( buffer[ n ] != '\"' )
               {
               ++n;
               if ( buffer[ n ] == '\0' )
                  {
                  #if PROG_ERRORS
                  sprintf( bwb_ebuf, "Incomplete string constant" );
                  bwb_error( bwb_ebuf );
                  #else
                  bwb_error( err_syntax );
                  #endif
                  *cmdnum = -1;
                  return FALSE;
                  }
               }
            ++n;
            break;
         case '=':

            #if INTENSIVE_DEBUG
            sprintf( bwb_ebuf, "in is_let(): implied LET found." );
            bwb_debug( bwb_ebuf );
            #endif

            for ( i = 0; i < COMMANDS; ++i )
               {
               if ( strncmp( bwb_cmdtable[ i ].name, "LET", (size_t) 3 ) == 0 )
                  {
                  *cmdnum = i;
                  }
               }
            return TRUE;
         }
      }

   /* No command name was found */

   *cmdnum = -1;
   return FALSE;

   }

/***************************************************************

        FUNCTION:       bwb_stripcr()

        DESCRIPTION:


***************************************************************/

int
bwb_stripcr( char *s )
   {
   char *p;

   p = s;
   while ( *p != 0 )
      {
      switch( *p )
         {


         case 0x0d:
         case 0x0a:
            *p = 0;
            return TRUE;
         }
      ++p;
      }
   *p = 0;
   return TRUE;
   }

/***************************************************************

        FUNCTION:       is_numconst()

        DESCRIPTION:    This function reads the string in <buffer>
                        and returns TRUE if it is a numerical
                        constant and FALSE if it is not. At
                        this point, only decimal (base 10)
                        constants are detected.

***************************************************************/

int
is_numconst( char *buffer )
   {
   char *p;

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in is_numconst(): received string <%s>.", buffer );
   bwb_debug( bwb_ebuf );
   #endif

   /* Return FALSE for empty buffer */

   if ( buffer[ 0 ] == '\0' )
      {
      return FALSE;
      }

   /* else check digits */

   p = buffer;
   while( *p != '\0' )
      {
      switch( *p )
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
            break;
         default:
            return FALSE;
         }
      ++p;
      }

   /* only numerical characters detected */

   return TRUE;

   }

/***************************************************************

        FUNCTION:       bwb_numseq()

        DESCRIPTION:

***************************************************************/

int
bwb_numseq( char *buffer, int *start, int *end )
   {
   register int b, n;
   int numbers;
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

   if ( buffer[ 0 ] == 0 )
      {
      *start = *end = 0;
      return FALSE;
      }

   numbers = n = b = 0;
   tbuf[ 0 ] = 0;
   while( TRUE )
      {
      switch( buffer[ b ] )
         {
         case 0:                           /* end of string */
         case '\n':
         case '\r':
            if ( n > 0 )
               {
               if ( numbers == 0 )
                  {
                  *end = 0;
                  *start = atoi( tbuf );
                  ++numbers;
                  }
               else
                  {

                  *end = atoi( tbuf );
                  return TRUE;
                  }
               }
            else
               {
               if ( numbers == 0 )
                  {
                  *start = *end = 0;
                  }
               else if ( numbers == 1 )
                  {
                  *end = 0;
                  }
               else if ( ( numbers == 2 ) && ( tbuf[ 0 ] == 0 ))
                  {
                  *end = 0;
                  }
               }
            return TRUE;

         #ifdef ALLOWWHITESPACE
         case ' ':                         /* whitespace */
         case '\t':
         #endif

         case '-':                         /* or skip to next number */
            if ( n > 0 )
               {
               if ( numbers == 0 )
                  {
                  *start = atoi( tbuf );
                  ++numbers;
                  }
               else
                  {
                  *end = atoi( tbuf );
                  return TRUE;
                  }
               }
            ++b;
            n = 0;
            break;
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
            tbuf[ n ] = buffer[ b ];
            ++n;
            tbuf[ n ] = 0;
            ++b;
            break;
         default:
            #if PROG_ERRORS
            sprintf( bwb_ebuf,
               "ERROR: character <%c> unexpected in numerical sequence",
               buffer[ b ] );
            ++b;
            bwb_error( bwb_ebuf );
            #else
            bwb_error( err_syntax );
            #endif
            break;
         }
      }

   }

/***************************************************************

        FUNCTION:       bwb_freeline()

        DESCRIPTION:

***************************************************************/

int
bwb_freeline( struct bwb_line *l )
   {
   register int n;

   /* free arguments if there are any */
   
   free( l );

   return TRUE;
   }
   
/***************************************************************

        FUNCTION:       int_qmdstr()

        DESCRIPTION:    This function .

***************************************************************/

int
int_qmdstr( char *buffer_a, char *buffer_b )
   {
   char *a, *b;
   
   a = buffer_a;
   ++a;                         /* advance beyond quotation mark */
   b = buffer_b;

   while( *a != '\"' )
      {
      *b = *a;
      ++a;
      ++b;
      *b = '\0';
      }

   return TRUE;

   }







