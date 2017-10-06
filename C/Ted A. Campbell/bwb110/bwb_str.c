/***************************************************************

        bwb_str.c       String-management routines
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
#include <string.h>

#include "bwbasic.h"
#include "bwb_mes.h"

#define FREE_STRBUFFERS	0	/* works with QuickC but not others */

#if INTENSIVE_DEBUG || TEST_BSTRING
static char tbuf[ MAXSTRINGSIZE + 1 ];
#endif

/***************************************************************

        FUNCTION:       str_btob()

        DESCRIPTION:    This C function assigns a bwBASIC string
			structure to another bwBASIC string 
			structure.

***************************************************************/

int
str_btob( bstring *d, bstring *s )
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

   if ( ( t = (char *) calloc( s->length + 1, 1 )) == NULL )
      {
      bwb_error( err_getmem );
      return FALSE;
      }

   /* write the c string to the b string */

   t[ 0 ] = '\0';
   for ( i = 0; i < s->length; ++i )
      {
      t[ i ] = s->buffer[ i ];
      #if INTENSIVE_DEBUG
      tbuf[ i ] = s->buffer[ i ];
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
   #if FREE_STRBUFFERS
   if (( d->rab != TRUE ) && ( d->buffer != NULL ))
      {
      free( d->buffer );
      }
   #endif
   d->rab = (char) FALSE;

   /* reassign buffer */

   d->buffer = t;

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

int
str_ctob( bstring *s, char *buffer )
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

   if ( ( t = (char *) calloc( strlen( buffer ) + 1, 1 )) == NULL )
      {
      bwb_error( err_getmem );
      return FALSE;
      }

   /* write the c string to the b string */

   t[ 0 ] = '\0';
   for ( i = 0; i < strlen( buffer ); ++i )
      {
      t[ i ] = buffer[ i ];
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
   #if FREE_STRBUFFERS
   if (( s->rab != TRUE ) && ( s->buffer != NULL ))
      {
      free( s->buffer );
      }
   #endif
   s->rab = (char) FALSE;

   /* reassign buffer */

   s->buffer = t;

   /* reassign length */

   s->length = (unsigned char) strlen( buffer );

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

int
str_btoc( char *buffer, bstring *s )
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
   for ( i = 0; i < s->length; ++i )
      {
      buffer[ i ] = s->buffer[ i ];
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

        DESCRIPTION:    This C function 

***************************************************************/

char *
str_cat( bstring *a, bstring *b )
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

   r = strcat( abuf, bbuf );
   str_ctob( a, abuf );

   return r;
   }

/***************************************************************

        FUNCTION:       str_cmp()

        DESCRIPTION:    This C function 

***************************************************************/

int
str_cmp( bstring *a, bstring *b )
   {
   char abuf[ MAXSTRINGSIZE + 1 ];
   char bbuf[ MAXSTRINGSIZE + 1 ];

   str_btoc( abuf, a );
   str_btoc( bbuf, b );

   return strcmp( abuf, bbuf );
   }


