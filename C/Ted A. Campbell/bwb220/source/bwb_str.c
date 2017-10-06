/***************************************************************

	bwb_str.c       String-Management Routines
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

#include "bwbasic.h"
#include "bwb_mes.h"

#if INTENSIVE_DEBUG || TEST_BSTRING
static char tbuf[ MAXSTRINGSIZE + 1 ];
#endif

/***************************************************************

        FUNCTION:       str_btob()

        DESCRIPTION:    This C function assigns a bwBASIC string
			structure to another bwBASIC string
			structure.

***************************************************************/

#if ANSI_C
int
str_btob( bstring *d, bstring *s )
#else
int
str_btob( d, s )
   bstring *d;
   bstring *s;
#endif
   {
   char *t;
   register int i;

#if TEST_BSTRING
   sprintf( tbuf, "in str_btob(): entry, source b string name is <%s>", s->name );
   bwb_debug( tbuf );
   sprintf( tbuf, "in str_btob(): entry, destination b string name is <%s>", d->name );
   bwb_debug( tbuf );
#endif

   /* get memory for new buffer */

   /* Following section removed by JBV (no more mass string reallocation) */
   /* if ( ( t = (char *) CALLOC( s->length + 1, 1, "str_btob" )) == NULL )
      {
#if PROG_ERRORS
      bwb_error( "in str_btob(): failed to get memory for new buffer" );
#else
      bwb_error( err_getmem );
#endif
      return FALSE;
      } */

   /* Only one of these two conditions necessitates reallocation (JBV) */
   if ( ( d->sbuffer == NULL ) || ( d->rab == TRUE ) )
   {
      if ( ( t = (char *) CALLOC( MAXSTRINGSIZE + 1, 1, "str_btob" )) == NULL )
         {
#if PROG_ERRORS
         bwb_error( "in str_btob(): failed to get memory for new buffer" );
#else
         bwb_error( err_getmem );
#endif
         return FALSE;
         }
   }
   else t = d->sbuffer; /* Leave well enough alone (JBV) */

   /* write the b string to the temp c string */

   t[ 0 ] = '\0';
   for ( i = 0; i < (int) s->length; ++i )
      {
      t[ i ] = s->sbuffer[ i ];
      t[ i + 1 ] = '\0'; /* JBV */
#if INTENSIVE_DEBUG
      tbuf[ i ] = s->sbuffer[ i ];
      tbuf[ i + 1 ] = '\0';
#endif
      }

   /* deallocate old memory */

#if INTENSIVE_DEBUG
   if ( d->rab == TRUE )
      {
      sprintf( bwb_ebuf, "in str_btob(): reallocating RAB" );
      bwb_debug( bwb_ebuf );
      }
#endif

   /* Following section removed by JBV (no more mass string reallocation) */
   /* if (( d->rab != TRUE ) && ( d->sbuffer != NULL ))
      {
#if INTENSIVE_DEBUG
      sprintf( tbuf, "in str_btob(): deallocating string memory" );
      bwb_debug ( tbuf );
#endif
      FREE( d->sbuffer, "str_btob" );
      d->sbuffer = NULL;
      }
   else
      {
      d->rab = (char) FALSE;
      } */

   d->rab = (char) FALSE; /* JBV */

   /* reassign buffer */

   d->sbuffer = t;

   /* reassign length */

   d->length = s->length;

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in str_btob(): exit length <%d> string <%s>",
      d->length, tbuf );
   bwb_debug( bwb_ebuf );
#endif

   /* return */

   return TRUE;

   }

/***************************************************************

        FUNCTION:       str_ctob()

        DESCRIPTION:    This C function assigns a null-terminated
			C string to a bwBASIC string structure.

***************************************************************/

#if ANSI_C
int
str_ctob( bstring *s, char *buffer )
#else
int
str_ctob( s, buffer )
   bstring *s;
   char *buffer;
#endif
   {
   char *t;
   register int i;

#if INTENSIVE_DEBUG
   sprintf( tbuf, "in str_ctob(): entry, c string is <%s>", buffer );
   bwb_debug( tbuf );
#endif
#if TEST_BSTRING
   sprintf( tbuf, "in str_ctob(): entry, b string name is <%s>", s->name );
   bwb_debug( tbuf );
#endif

   /* get memory for new buffer */

   /* Following section removed by JBV (no more mass string reallocation) */
   /* if ( ( t = (char *) CALLOC( strlen( buffer ) + 1, 1, "str_ctob" )) == NULL )
      {
#if PROG_ERRORS
      bwb_error( "in str_ctob(): failed to get memory for new buffer" );
#else
      bwb_error( err_getmem );
#endif
      return FALSE;
      } */

   /* Only one of these two conditions necessitates reallocation (JBV) */
   if ( ( s->sbuffer == NULL ) || ( s->rab == TRUE ) )
   {
   if ( ( t = (char *) CALLOC( MAXSTRINGSIZE + 1, 1, "str_ctob" )) == NULL )
      {
#if PROG_ERRORS
      bwb_error( "in str_ctob(): failed to get memory for new buffer" );
#else
      bwb_error( err_getmem );
#endif
      return FALSE;
      }
   }
   else t = s->sbuffer; /* Leave well enough alone (JBV) */

   /* write the c string to the temp c string */

   t[ 0 ] = '\0';
   for ( i = 0; i < (int) strlen( buffer ); ++i )
      {
      t[ i ] = buffer[ i ];
      t[ i + 1 ] = '\0'; /* JBV */
#if INTENSIVE_DEBUG
      tbuf[ i ] = buffer[ i ];
      tbuf[ i + 1 ] = '\0';
#endif
      }

   /* deallocate old memory */

#if INTENSIVE_DEBUG
   if ( s->rab == TRUE )
      {
      sprintf( bwb_ebuf, "in str_ctob(): reallocating RAB" );
      bwb_debug( bwb_ebuf );
      }
#endif

   /* Following section removed by JBV (no more mass string reallocation) */
   /* if (( s->rab != TRUE ) && ( s->sbuffer != NULL ))
      {
      FREE( s->sbuffer, "str_ctob" );
      s->sbuffer = NULL;
      }
   else
      {
      s->rab = (char) FALSE;
      } */

   s->rab = (char) FALSE; /* JBV */

   /* reassign buffer */

   s->sbuffer = t;

   /* reassign length */

   /* Was unsigned char (JBV 9/4/97) */
   s->length = (unsigned int) strlen( buffer );

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in str_ctob(): exit length <%d> string <%s>",
      s->length, tbuf );
   bwb_debug( bwb_ebuf );
#endif

   /* return */

   return TRUE;

   }

/***************************************************************

        FUNCTION:       str_btoc()

        DESCRIPTION:    This C function assigns a null-terminated
			C string to a bwBASIC string structure.

***************************************************************/

#if ANSI_C
int
str_btoc( char *buffer, bstring *s )
#else
int
str_btoc( buffer, s )
   char *buffer;
   bstring *s;
#endif
   {
   register int i;

#if INTENSIVE_DEBUG
   sprintf( tbuf, "in str_btoc(): entry, b string length is <%d>",
      s->length );
   bwb_debug( tbuf );
#endif
#if TEST_BSTRING
   sprintf( tbuf, "in str_btoc(): entry, b string name is <%s>", s->name );
   bwb_debug( tbuf );
#endif

   /* write the b string to the c string */

   buffer[ 0 ] = '\0';
   for ( i = 0; i < (int) s->length; ++i )
      {
      buffer[ i ] = s->sbuffer[ i ];
      buffer[ i + 1 ] = '\0';
      if ( i >= MAXSTRINGSIZE )
         {
         i = s->length + 1;
         }
      }

#if INTENSIVE_DEBUG
   sprintf( tbuf, "in str_btoc(): exit, c string is <%s>", buffer );
   bwb_debug( tbuf );
#endif

   /* return */

   return TRUE;

   }

/***************************************************************

        FUNCTION:       str_cat()

        DESCRIPTION:    This C function performs the equivalent
			of the C strcat() function, using BASIC
			strings.

***************************************************************/

#if ANSI_C
char *
str_cat( bstring *a, bstring *b )
#else
char *
str_cat( a, b )
   bstring *a;
   bstring *b;
#endif
   {
   char abuf[ MAXSTRINGSIZE + 1 ];
   char bbuf[ MAXSTRINGSIZE + 1 ];
   char *r;

   str_btoc( abuf, a );
   str_btoc( bbuf, b );

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in str_cat(): a <%s> b <%s>", abuf, bbuf );
   bwb_debug( bwb_ebuf );
#endif

   strcat( abuf, bbuf );
   str_ctob( a, abuf );

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in str_cat(): returns <%s>", abuf );
   bwb_debug( bwb_ebuf );
#endif

   return r;
   }

/***************************************************************

        FUNCTION:       str_cmp()

	DESCRIPTION:    This C function performs the equivalent
			of the C strcmp() function, using BASIC
			strings.

***************************************************************/

#if ANSI_C
int
str_cmp( bstring *a, bstring *b )
#else
int
str_cmp( a, b )
   bstring *a;
   bstring *b;
#endif
   {
   char abuf[ MAXSTRINGSIZE + 1 ];
   char bbuf[ MAXSTRINGSIZE + 1 ];

   str_btoc( abuf, a );
   str_btoc( bbuf, b );

   return strcmp( abuf, bbuf );
   }


