/***************************************************************f

        bwb_int.c       Line Interpretation Routines
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
/*                                                               */
/* Those additionally marked with "DD" were at the suggestion of */
/* Dale DePriest (daled@cadence.com).                            */
/*---------------------------------------------------------------*/

#include <stdio.h>
#include <ctype.h>

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

#if ANSI_C
int
adv_element( char *buffer, int *pos, char *element )
#else
int
adv_element( buffer, pos, element )
   char *buffer;
   int *pos;
   char *element;
#endif
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
#if MULTISEG_LINES
         case ':':
#endif
         case '=':
         case ' ':
         case '\t':
         /* case '\0': */ /* Removed by JBV (found by DD) */
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

         case '\0':                     /* Added by JBV (found by DD) */
            if ( str_const == TRUE )    /* termination of string constant */
               {
               element[ e_pos ] = '\"';
               element[ ++e_pos ] = '\0';
               }
            return TRUE;
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

#if ANSI_C
int
adv_ws( char *buffer, int *pos )
#else
int
adv_ws( buffer, pos )
   char *buffer;
   int *pos;
#endif
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

	FUNCTION:       adv_eos()

	DESCRIPTION:    This function reads characters in <buffer>
			beginning at <pos> and advances to the
			end of a segment delimited by ':',
			incrementing <pos> appropriately.

***************************************************************/

#if MULTISEG_LINES
#if ANSI_C
int
adv_eos( char *buffer, int *pos )
#else
int
adv_eos( buffer, pos )
   char *buffer;
   int *pos;
#endif
   {
   int loop;

   loop = TRUE;
   while ( loop == TRUE )
      {

      if ( is_eol( buffer, pos ) == TRUE )
	 {
	 return FALSE;
	 }

      switch( buffer[ *pos ] )
	 {
	 case ':':              /* end of segment marker */
	    ++( *pos );
	    return TRUE;

	 case '\"':             /* begin quoted string */

	    ++( *pos );

	    while ( buffer[ *pos ] != '\"' )
	       {
	       if ( is_eol( buffer, pos ) == TRUE )
		  {
		  return FALSE;
		  }
	       else
		  {
		  ++( *pos );
		  }
	       }

	    break;

	 default:
	    ++( *pos );
	 }
      }

   /* This should not happen */

   return FALSE;

   }

#endif                          /* MULTISEG_LINES */

/***************************************************************

        FUNCTION:       bwb_strtoupper()

        DESCRIPTION:    This function converts the string in
                        <buffer> to upper-case characters.

***************************************************************/

#if ANSI_C
int
bwb_strtoupper( char *buffer )
#else
int
bwb_strtoupper( buffer )
   char *buffer;
#endif
   {
   char *p;

   p = buffer;
   while ( *p != '\0' )
      {
      if ( islower( *p ) != FALSE )
         {
         *p = (char) toupper( *p );
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

#if ANSI_C
int
line_start( char *buffer, int *pos, int *lnpos, int *lnum, int *cmdpos,
   int *cmdnum, int *startpos )
#else
int
line_start( buffer, pos, lnpos, lnum, cmdpos, cmdnum, startpos )
   char *buffer;
   int *pos;
   int *lnpos;
   int *lnum;
   int *cmdpos;
   int *cmdnum;
   int *startpos;
#endif
   {
   static int position;
   static char *tbuf;
   static int init = FALSE;

   /* get memory for temporary buffer if necessary */

   if ( init == FALSE )
      {
      init = TRUE;

      /* Revised to CALLOC pass-thru call by JBV */
      if ( ( tbuf = CALLOC( MAXSTRINGSIZE + 1, sizeof( char ), "line_start")) == NULL )
         {
#if PROG_ERRORS
	 bwb_error( "in line_start(): failed to get memory for tbuf" );
#else
	 bwb_error( err_getmem );
#endif
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
      *cmdnum = getcmdnum( CMD_REM );
      return TRUE;
      }

   /* advance beyond the first element */

   *lnpos = position;
   scan_element( buffer, &position, tbuf );
   adv_ws( buffer, &position );

   /* test for a line number in the first element */

   if ( is_numconst( tbuf ) == TRUE )               /* a line number */
      {

      *lnum = atoi( tbuf );
      *startpos = position;                             /* temp */
      *cmdpos = position;

      scan_element( buffer, &position, tbuf );       /* advance past next element */

#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in line_start(): new element is <%s>", tbuf );
      bwb_debug( bwb_ebuf );
#endif

#if STRUCT_CMDS
      if ( is_label( tbuf ) == TRUE )
         {
         *cmdnum = getcmdnum( CMD_LABEL );
         adv_ws( buffer, &position );
         *startpos = position;
         }

      else if ( is_cmd( tbuf, cmdnum ) == TRUE )
#else
      if ( is_cmd( tbuf, cmdnum ) == TRUE )
#endif
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

#if STRUCT_CMDS
      if ( is_label( tbuf ) == TRUE )
         {

#if INTENSIVE_DEBUG
	 sprintf( bwb_ebuf, "in line_start(): label detected <%s>.",
	    tbuf );
	 bwb_debug( bwb_ebuf );
#endif

         *cmdnum = getcmdnum( CMD_LABEL );
         adv_ws( buffer, &position );
         *startpos = position;
         }

      else if ( is_cmd( tbuf, cmdnum ) == TRUE )
#else
      if ( is_cmd( tbuf, cmdnum ) == TRUE )
#endif
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

	DESCRIPTION:    This function determines whether the
			string in 'buffer' is a BASIC command
			statement, returning TRUE or FALSE,
			and if TRUE returning the command number
			in the command lookup table in the
			integer pointed to by 'cmdnum'.

***************************************************************/

#if ANSI_C
int
is_cmd( char *buffer, int *cmdnum )
#else
int
is_cmd( buffer, cmdnum )
   char *buffer;
   int *cmdnum;
#endif
   {
   register int n;

   /* Convert the command name to upper case */

   bwb_strtoupper( buffer );

   /* Go through the command table and search for a match. */

   for ( n = 0; n < COMMANDS; ++n )
      {
      if ( strcmp( bwb_cmdtable[ n ].name, buffer ) == 0 )
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

#if ANSI_C
int
is_let( char *buffer, int *cmdnum )
#else
int
is_let( buffer, cmdnum )
   char *buffer;
   int *cmdnum;
#endif
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

	DESCRIPTION:    This function strips the carriage return
			or line-feed from the end of a string.

***************************************************************/

#if ANSI_C
int
bwb_stripcr( char *s )
#else
int
bwb_stripcr( s )
   char *s;
#endif
   {
   char *p;

   p = s;
   while ( *p != 0 )
      {
      switch( *p )
         {


         case '\r':
         case '\n':
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

#if ANSI_C
int
is_numconst( char *buffer )
#else
int
is_numconst( buffer )
   char *buffer;
#endif
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

	DESCRIPTION:    This function reads in a sequence of
			numbers (e.g., "10-120"), returning
			the first and last numbers in the sequence
			in the integers pointed to by 'start' and
			'end'.

***************************************************************/

#if ANSI_C
int
bwb_numseq( char *buffer, int *start, int *end )
#else
int
bwb_numseq( buffer, start, end )
   char *buffer;
   int *start;
   int *end;
#endif
   {
   register int b, n;
   int numbers;
   static char *tbuf;
   static int init = FALSE;

   /* get memory for temporary buffer if necessary */

   if ( init == FALSE )
      {
      init = TRUE;

      /* Revised to CALLOC pass-thru call by JBV */
      if ( ( tbuf = CALLOC( MAXSTRINGSIZE + 1, sizeof( char ), "bwb_numseq")) == NULL )
         {
#if PROG_ERRORS
	 bwb_error( "in bwb_numseq(): failed to find memory for tbuf" );
#else
	 bwb_error( err_getmem );
#endif
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

	DESCRIPTION:    This function frees memory associated
			with a program line in memory.

***************************************************************/

#if ANSI_C
int
bwb_freeline( struct bwb_line *l )
#else
int
bwb_freeline( l )
   struct bwb_line *l;
#endif
   {

   /* free arguments if there are any */

   /* Revised to FREE pass-thru calls by JBV */
   if (l->buffer != NULL)
   {
       FREE( l->buffer, "bwb_freeline" );
       l->buffer = NULL; /* JBV */
   }
   FREE( l, "bwb_freeline" );
   l = NULL; /* JBV */

   return TRUE;
   }

/***************************************************************

        FUNCTION:       int_qmdstr()

	DESCRIPTION:    This function returns a string delimited
			by quotation marks.

***************************************************************/

#if ANSI_C
int
int_qmdstr( char *buffer_a, char *buffer_b )
#else
int
int_qmdstr( buffer_a, buffer_b )
   char *buffer_a;
   char *buffer_b;
#endif
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

/***************************************************************

	FUNCTION:       is_eol()

	DESCRIPTION:    This function determines whether the buffer
			is at the end of a line.

***************************************************************/

#if ANSI_C
extern int
is_eol( char *buffer, int *position )
#else
int
is_eol( buffer, position )
   char *buffer;
   int *position;
#endif
   {

   adv_ws( buffer, position );

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in is_eol(): character is <0x%x> = <%c>",
      buffer[ *position ], buffer[ *position ] );
   bwb_debug( bwb_ebuf );
#endif

   switch( buffer[ *position ] )
      {
      case '\0':
      case '\n':
      case '\r':
#if MULTISEG_LINES
      case ':':
#endif
         return TRUE;
      default:
         return FALSE;
      }

   }

