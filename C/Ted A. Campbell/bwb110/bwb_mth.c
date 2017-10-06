/****************************************************************

        bwb_mth.c       Mathematical Functions
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

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <math.h>
#include <time.h>

#include "bwbasic.h"
#include "bwb_mes.h"

union un_integer
   {
   int the_integer;
   unsigned char the_chars[ sizeof( int ) ];
   } an_integer;

union un_single
   {
   float the_float;
   unsigned char the_chars[ sizeof( float) ];
   } a_float;

union un_double
   {
   double the_double;
   unsigned char the_chars[ sizeof( double ) ];
   } a_double;

/***************************************************************

        FUNCTION:       fnc_abs()

        DESCRIPTION:    This C function implements the BASIC
                        predefined ABS function, returning the
                        absolute value of the argument.

***************************************************************/

struct bwb_variable *
fnc_abs( int argc, struct bwb_variable *argv  )
   {
   static struct bwb_variable nvar;
   static int init = FALSE;

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in fnc_abs(): entered function" );
   bwb_debug( bwb_ebuf );
   #endif

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      strncpy( nvar.name, "(abs var)", MAXVARNAMESIZE );
      #if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in fnc_abs(): ready to make local variable <%s>",
         nvar.name );
      bwb_debug( bwb_ebuf );
      #endif
      var_make( &nvar, SINGLE );
      }

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in fnc_abs(): received f_arg <%f> nvar type <%c>",
      var_getdval( &( argv[ 0 ] ) ), nvar.type );
   bwb_debug( bwb_ebuf );
   #endif

   #if PROG_ERRORS
   if ( argc < 1 )
      {
      sprintf( bwb_ebuf, "Not enough parameters (%d) to function ABS().",
         argc );
      bwb_error( bwb_ebuf );
      return NULL;
      }
   else if ( argc > 1 )
      {
      sprintf( bwb_ebuf, "Too many parameters (%d) to function ABS().",
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

   /* assign values */

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in fnc_abs(): nvar type <%c>; calling findval()",
      nvar.type );
   bwb_debug( bwb_ebuf );
   #endif

   * var_findfval( &nvar, nvar.array_pos ) = 
      (float) fabs( var_getdval( &( argv[ 0 ] ) ) );

   return &nvar;

   }

/***************************************************************

        FUNCTION:       fnc_atn()

        DESCRIPTION:    This C function implements the BASIC

                        predefined ATN function, returning the
                        arctangent of the argument.

***************************************************************/

struct bwb_variable *
fnc_atn( int argc, struct bwb_variable *argv  )
   {
   static struct bwb_variable nvar;
   static int init = FALSE;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, DOUBLE );
      }

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in fnc_atn(): received f_arg <%f> ",
      var_getdval( &( argv[ 0 ] ) ) );
   bwb_debug( bwb_ebuf );
   #endif

   #if PROG_ERRORS
   if ( argc < 1 )
      {
      sprintf( bwb_ebuf, "Not enough parameters (%d) to function ATN().",
         argc );
      bwb_error( bwb_ebuf );
      return NULL;
      }
   else if ( argc > 1 )
      {
      sprintf( bwb_ebuf, "Too many parameters (%d) to function ATN().",
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

   /* assign values */

   * var_finddval( &nvar, nvar.array_pos ) 
      = atan( var_getdval( &( argv[ 0 ] ) ) );

   return &nvar;

   }


/***************************************************************

        FUNCTION:       fnc_acos()

        DESCRIPTION:    This C function implements the BASIC

                        predefined ACOS function, returning the
                        arccosinus of the argument.

***************************************************************/

struct bwb_variable *
fnc_acos( int argc, struct bwb_variable *argv  )
   {
   static struct bwb_variable nvar;
   static int init = FALSE;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, DOUBLE );
      }

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in fnc_acos(): received f_arg <%f> ",
      var_getdval( &( argv[ 0 ] ) ) );
   bwb_debug( bwb_ebuf );
   #endif

   #if PROG_ERRORS
   if ( argc < 1 )
      {
      sprintf( bwb_ebuf, "Not enough parameters (%d) to function ACOS().",
         argc );
      bwb_error( bwb_ebuf );
      return NULL;
      }
   else if ( argc > 1 )
      {
      sprintf( bwb_ebuf, "Too many parameters (%d) to function ACOS().",
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

   /* assign values */

   * var_finddval( &nvar, nvar.array_pos ) 
      = acos( var_getdval( &( argv[ 0 ] ) ) );

   return &nvar;

   }


/***************************************************************

        FUNCTION:       fnc_cos()

        DESCRIPTION:    This C function implements the BASIC
                        predefined COS function, returning the
                        cosine of the argument.

***************************************************************/

struct bwb_variable *
fnc_cos( int argc, struct bwb_variable *argv  )
   {
   static struct bwb_variable nvar;
   static int init = FALSE;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, DOUBLE );
      }

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in fnc_cos(): received f_arg <%f> ",
      var_getdval( &( argv[ 0 ] ) ) );
   bwb_debug( bwb_ebuf );
   #endif

   #if PROG_ERRORS
   if ( argc < 1 )
      {
      sprintf( bwb_ebuf, "Not enough parameters (%d) to function COS().",
         argc );
      bwb_error( bwb_ebuf );
      return NULL;
      }
   else if ( argc > 1 )
      {
      sprintf( bwb_ebuf, "Too many parameters (%d) to function COS().",
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

   /* assign values */

   * var_finddval( &nvar, nvar.array_pos ) 
      = cos( var_getdval( &( argv[ 0 ] ) ) );

   return &nvar;

   }

/***************************************************************

        FUNCTION:       fnc_log()

        DESCRIPTION:    This C function implements the BASIC
                        predefined LOG function, returning the
                        natural logarithm of the argument.

***************************************************************/

struct bwb_variable *
fnc_log( int argc, struct bwb_variable *argv  )
   {
   static struct bwb_variable nvar;
   static int init = FALSE;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, DOUBLE );
      }

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in fnc_log(): received f_arg <%f> ",
      var_getdval( &( argv[ 0 ] ) ) );
   bwb_debug( bwb_ebuf );
   #endif

   #if PROG_ERRORS
   if ( argc < 1 )
      {
      sprintf( bwb_ebuf, "Not enough parameters (%d) to function LOG().",
         argc );
      bwb_error( bwb_ebuf );
      return NULL;
      }
   else if ( argc > 1 )
      {
      sprintf( bwb_ebuf, "Too many parameters (%d) to function LOG().",
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

   /* assign values */

   * var_finddval( &nvar, nvar.array_pos ) 
      = log( var_getdval( &( argv[ 0 ] ) ) );

   return &nvar;
   }

/***************************************************************

        FUNCTION:       fnc_sin()

        DESCRIPTION:    This C function implements the BASIC
                        predefined SIN function, returning
                        the sine of the argument.

***************************************************************/

struct bwb_variable *
fnc_sin( int argc, struct bwb_variable *argv  )
   {
   static struct bwb_variable nvar;
   static int init = FALSE;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, DOUBLE );
      }

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in fnc_sin(): received f_arg <%f> ",
      var_getdval( &( argv[ 0 ] ) ) );
   bwb_debug( bwb_ebuf );
   #endif

   #if PROG_ERRORS
   if ( argc < 1 )
      {
      sprintf( bwb_ebuf, "Not enough parameters (%d) to function SIN().",
         argc );
      bwb_error( bwb_ebuf );
      return NULL;
      }

   else if ( argc > 1 )
      {
      sprintf( bwb_ebuf, "Too many parameters (%d) to function SIN().",
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

   /* assign values */

   * var_finddval( &nvar, nvar.array_pos ) 
      = sin( var_getdval( &( argv[ 0 ] ) ) );

   return &nvar;

   }


/***************************************************************

        FUNCTION:       fnc_asin()

        DESCRIPTION:    This C function implements the BASIC
                        predefined ASIN function, returning
                        the sine of the argument.

***************************************************************/

struct bwb_variable *
fnc_asin( int argc, struct bwb_variable *argv  )
   {
   static struct bwb_variable nvar;
   static int init = FALSE;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, DOUBLE );
      }

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in fnc_asin(): received f_arg <%f> ",
      var_getdval( &( argv[ 0 ] ) ) );
   bwb_debug( bwb_ebuf );
   #endif

   #if PROG_ERRORS
   if ( argc < 1 )
      {
      sprintf( bwb_ebuf, "Not enough parameters (%d) to function ASIN().",
         argc );
      bwb_error( bwb_ebuf );
      return NULL;
      }

   else if ( argc > 1 )
      {
      sprintf( bwb_ebuf, "Too many parameters (%d) to function ASIN().",
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

   /* assign values */

   * var_finddval( &nvar, nvar.array_pos ) 
      = asin( var_getdval( &( argv[ 0 ] ) ) );

   return &nvar;

   }

/***************************************************************

        FUNCTION:       fnc_sqr()

        DESCRIPTION:    This C function implements the BASIC
                        predefined SQR function, returning
                        the square root of the argument.

***************************************************************/

struct bwb_variable *
fnc_sqr( int argc, struct bwb_variable *argv  )
   {
   static struct bwb_variable nvar;
   static int init = FALSE;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, DOUBLE );
      }

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in fnc_sqr(): received f_arg <%f> ",
      var_getdval( &( argv[ 0 ] ) ) );
   bwb_debug( bwb_ebuf );
   #endif

   #if PROG_ERRORS
   if ( argc < 1 )
      {
      sprintf( bwb_ebuf, "Not enough parameters (%d) to function SQR().",
         argc );
      bwb_error( bwb_ebuf );
      return NULL;
      }
   else if ( argc > 1 )
      {
      sprintf( bwb_ebuf, "Too many parameters (%d) to function SQR().",
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

   /* assign values */

   * var_finddval( &nvar, nvar.array_pos ) 
      = sqrt( var_getdval( &( argv[ 0 ] ) ) );

   return &nvar;

   }

/***************************************************************

        FUNCTION:       fnc_tan()

        DESCRIPTION:    This C function implements the BASIC
                        predefined TAN function, returning the
                        tangent of the argument.

***************************************************************/

struct bwb_variable *
fnc_tan( int argc, struct bwb_variable *argv  )
   {
   static struct bwb_variable nvar;
   static int init = FALSE;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, DOUBLE );
      }

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in fnc_tan(): received f_arg <%f> ",
      var_getdval( &( argv[ 0 ] ) ) );
   bwb_debug( bwb_ebuf );
   #endif

   #if PROG_ERRORS
   if ( argc < 1 )
      {
      sprintf( bwb_ebuf, "Not enough parameters (%d) to function TAN().",
         argc );
      bwb_error( bwb_ebuf );
      return NULL;
      }
   else if ( argc > 1 )
      {
      sprintf( bwb_ebuf, "Too many parameters (%d) to function TAN().",
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

   /* assign values */

   * var_finddval( &nvar, nvar.array_pos ) 
      = tan( var_getdval( &( argv[ 0 ] ) ) );

   return &nvar;

   }


/***************************************************************

        FUNCTION:       fnc_sgn()

        DESCRIPTION:    This C function implements the BASIC
                        predefined SGN function, returning 0
                        if the argument is 0, -1 if the argument
                        is less than 0, or 1 if the argument
                        is more than 0.

***************************************************************/

struct bwb_variable *
fnc_sgn( int argc, struct bwb_variable *argv  )
   {
   static struct bwb_variable nvar;
   double dval;
   static int init = FALSE;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, INTEGER );
      }

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in fnc_sgn(): received f_arg <%f> ",
      var_getdval( &( argv[ 0 ] ) ) );
   bwb_debug( bwb_ebuf );
   #endif

   #if PROG_ERRORS
   if ( argc < 1 )
      {
      sprintf( bwb_ebuf, "Not enough parameters (%d) to function SGN().",
         argc );
      bwb_error( bwb_ebuf );
      return NULL;
      }
   else if ( argc > 1 )
      {
      sprintf( bwb_ebuf, "Too many parameters (%d) to function SGN().",
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

   /* assign values */

   dval = var_getdval( &( argv[ 0 ] ));

   if ( dval == 0.0 )
      {
      * var_findival( &nvar, nvar.array_pos ) = 0;
      }
   else if ( dval > 0.0 )
      {
      * var_findival( &nvar, nvar.array_pos ) = 1;
      }
   else
      {
      * var_findival( &nvar, nvar.array_pos ) = -1;
      }

   return &nvar;
   }

/***************************************************************

        FUNCTION:       fnc_int()

        DESCRIPTION:    This C function implements the BASIC
                        predefined INT function, returning an
                        less than or equal to the argument.

***************************************************************/

struct bwb_variable *
fnc_int( int argc, struct bwb_variable *argv  )
   {
   static struct bwb_variable nvar;
   static int init = FALSE;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, SINGLE );
      }

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in fnc_int(): received f_arg <%f> ",
      var_getdval( &( argv[ 0 ] ) ) );
   bwb_debug( bwb_ebuf );
   #endif

   #if PROG_ERRORS
   if ( argc < 1 )
      {
      sprintf( bwb_ebuf, "Not enough parameters (%d) to function INT().",
         argc );
      bwb_error( bwb_ebuf );
      return NULL;
      }
   else if ( argc > 1 )
      {
      sprintf( bwb_ebuf, "Too many parameters (%d) to function INT().",
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

   /* assign values */

   * var_findfval( &nvar, nvar.array_pos ) 
      = (float) floor( var_getdval( &( argv[ 0 ] ) ) );

   return &nvar;
   }

/***************************************************************

        FUNCTION:       fnc_mki()

        DESCRIPTION:    This C function implements the BASIC
                        predefined MKI$() function.

***************************************************************/

struct bwb_variable *
fnc_mki( int argc, struct bwb_variable *argv  )
   {
   register int i;
   static struct bwb_variable nvar;
   bstring *b;
   static char tbuf[ sizeof( int ) ];
   static int init = FALSE;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, STRING );
      }

   #if PROG_ERRORS
   if ( argc < 1 )
      {
      sprintf( bwb_ebuf, "Not enough parameters (%d) to function MKI$().",
         argc );
      bwb_error( bwb_ebuf );
      return NULL;
      }
   else if ( argc > 1 )
      {
      sprintf( bwb_ebuf, "Too many parameters (%d) to function MKI$().",
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

   /* assign values */

   an_integer.the_integer = var_getival( &( argv[ 0 ] ) );

   for ( i = 0; i < sizeof( int ); ++i )
      {
      tbuf[ i ] = an_integer.the_chars[ i ];
      }
   b = var_getsval( &nvar );
   b->length = sizeof( int );
   b->buffer = tbuf;
   b->rab = FALSE;   

   return &nvar;
   }

/***************************************************************

        FUNCTION:       fnc_mkd()

        DESCRIPTION:    This C function implements the BASIC
                        predefined MKD$() function.

***************************************************************/

struct bwb_variable *
fnc_mkd( int argc, struct bwb_variable *argv  )
   {
   register int i;
   static struct bwb_variable nvar;
   bstring *b;
   char tbuf[ sizeof ( double ) ];
   static int init = FALSE;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, STRING );
      }

   #if PROG_ERRORS
   if ( argc < 1 )
      {
      sprintf( bwb_ebuf, "Not enough parameters (%d) to function MKD$().",
         argc );
      bwb_error( bwb_ebuf );
      return NULL;
      }
   else if ( argc > 1 )
      {
      sprintf( bwb_ebuf, "Too many parameters (%d) to function MKD$().",
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

   /* assign values */

   a_double.the_double = var_getdval( &( argv[ 0 ] ) );

   for ( i = 0; i < sizeof ( double ); ++i )
      {
      tbuf[ i ] = a_double.the_chars[ i ];
      tbuf[ i + 1 ] = '\0';
      }
   b = var_getsval( &nvar );
   b->length = sizeof( double );
   b->buffer = tbuf;
   b->rab = FALSE;

   return &nvar;
   }

/***************************************************************

        FUNCTION:       fnc_mks()

        DESCRIPTION:    This C function implements the BASIC
                        predefined MKS$() function.

***************************************************************/

struct bwb_variable *
fnc_mks( int argc, struct bwb_variable *argv  )
   {
   register int i;
   static struct bwb_variable nvar;
   static unsigned char tbuf[ 5 ];
   bstring *b;
   static int init = FALSE;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, STRING );
      }

   #if PROG_ERRORS
   if ( argc < 1 )
      {
      sprintf( bwb_ebuf, "Not enough parameters (%d) to function MKS$().",
         argc );
      bwb_error( bwb_ebuf );
      return NULL;
      }
   else if ( argc > 1 )
      {
      sprintf( bwb_ebuf, "Too many parameters (%d) to function MKS$().",
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

   /* assign values */

   a_float.the_float = var_getfval( &( argv[ 0 ] ) );

   for ( i = 0; i < sizeof( float ); ++i )
      {
      tbuf[ i ] = a_float.the_chars[ i ];
      }
   b = var_getsval( &nvar );
   b->length = sizeof( float );
   b->buffer = tbuf;
   b->rab = FALSE;

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in fnc_mks(): string <%s> hex vals <%X><%X><%X><%X>",
      tbuf, tbuf[ 0 ], tbuf[ 1 ], tbuf[ 2 ], tbuf[ 3 ] );
   bwb_debug( bwb_ebuf );
   #endif

   return &nvar;
   }

/***************************************************************

        FUNCTION:       fnc_cvi()

        DESCRIPTION:    This C function implements the BASIC
                        predefined CVI() function.

***************************************************************/

struct bwb_variable *
fnc_cvi( int argc, struct bwb_variable *argv  )
   {
   register int i;
   struct bwb_variable *v;
   bstring *b;
   static struct bwb_variable nvar;
   static int init = FALSE;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, INTEGER );
      }

   #if PROG_ERRORS
   if ( argc < 1 )
      {
      sprintf( bwb_ebuf, "Not enough parameters (%d) to function CVI().",
         argc );
      bwb_error( bwb_ebuf );
      return NULL;
      }
   else if ( argc > 1 )
      {
      sprintf( bwb_ebuf, "Too many parameters (%d) to function CVI().",
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

   /* assign values */

   v = &( argv[ 0 ] );
   b = var_findsval( v, v->array_pos );

   for ( i = 0; i < sizeof( int ); ++i )
      {
      an_integer.the_chars[ i ] = b->buffer[ i ];
      }

   * var_findival( &nvar, nvar.array_pos ) = an_integer.the_integer;

   return &nvar;
   }

/***************************************************************

        FUNCTION:       fnc_cvd()

        DESCRIPTION:    This C function implements the BASIC
                        predefined CVD() function.

***************************************************************/

struct bwb_variable *
fnc_cvd( int argc, struct bwb_variable *argv  )
   {
   register int i;
   struct bwb_variable *v;
   bstring *b;
   static struct bwb_variable nvar;
   static int init = FALSE;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, DOUBLE );
      }

   #if PROG_ERRORS
   if ( argc < 1 )
      {
      sprintf( bwb_ebuf, "Not enough parameters (%d) to function CVD().",
         argc );
      bwb_error( bwb_ebuf );
      return NULL;
      }
   else if ( argc > 1 )
      {
      sprintf( bwb_ebuf, "Too many parameters (%d) to function CVD().",
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

   /* assign values */

   v = &( argv[ 0 ] );
   b = var_findsval( v, v->array_pos );

   for ( i = 0; i < sizeof( double ); ++i )
      {
      a_double.the_chars[ i ] = b->buffer[ i ];
      }

   * var_finddval( &nvar, nvar.array_pos ) = a_double.the_double;

   return &nvar;

   }

/***************************************************************

        FUNCTION:       fnc_cvs()

        DESCRIPTION:    This C function implements the BASIC
                        predefined CVS() function.

***************************************************************/

struct bwb_variable *
fnc_cvs( int argc, struct bwb_variable *argv  )
   {
   register int i;
   struct bwb_variable *v;
   bstring *b;
   static struct bwb_variable nvar;
   static int init = FALSE;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, SINGLE );
      }

   #if PROG_ERRORS
   if ( argc < 1 )
      {
      sprintf( bwb_ebuf, "Not enough parameters (%d) to function CVS().",
         argc );
      bwb_error( bwb_ebuf );
      return NULL;
      }
   else if ( argc > 1 )
      {
      sprintf( bwb_ebuf, "Too many parameters (%d) to function CVS().",
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

   /* assign values */

   v = &( argv[ 0 ] );
   b = var_findsval( v, v->array_pos );

   for ( i = 0; i < sizeof( float ); ++i )
      {
      a_float.the_chars[ i ] = b->buffer[ i ];
      }

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in fnc_cvs(): string <%s> hex vals <%X><%X><%X><%X>",
      a_float.the_chars, a_float.the_chars[ 0 ], a_float.the_chars[ 1 ], 
      a_float.the_chars[ 2 ], a_float.the_chars[ 3 ] );
   bwb_debug( bwb_ebuf );
   #endif

   * var_findfval( &nvar, nvar.array_pos ) = a_float.the_float;

   return &nvar;

   }

/***************************************************************

        FUNCTION:       fnc_csng()

        DESCRIPTION:    

***************************************************************/

struct bwb_variable *
fnc_csng( int argc, struct bwb_variable *argv )
   {
   static struct bwb_variable nvar;
   static int init = FALSE;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, SINGLE );
      }

   /* check parameters */

   #if PROG_ERRORS
   if ( argc < 1 )
      {
      sprintf( bwb_ebuf, "Not enough parameters (%d) to function CINT().",
         argc );
      bwb_error( bwb_ebuf );
      return NULL;
      }
   else if ( argc > 1 )
      {
      sprintf( bwb_ebuf, "Too many parameters (%d) to function CINT().",
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

   /* get truncated integer value */

   * var_findfval( &nvar, nvar.array_pos )
      = (float) var_getfval( &( argv[ 0 ] ) );

   return &nvar;
   }

/***************************************************************

        FUNCTION:       fnc_exp()

        DESCRIPTION:    

***************************************************************/

struct bwb_variable *
fnc_exp( int argc, struct bwb_variable *argv )
   {
   static struct bwb_variable nvar;
   static int init = FALSE;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, DOUBLE );
      }

   #if PROG_ERRORS
   if ( argc < 1 )
      {
      sprintf( bwb_ebuf, "Not enough parameters (%d) to function EXP().",
         argc );
      bwb_error( bwb_ebuf );
      return NULL;
      }

   else if ( argc > 1 )
      {
      sprintf( bwb_ebuf, "Too many parameters (%d) to function EXP().",
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

   /* assign values */

   * var_finddval( &nvar, nvar.array_pos ) 
      = exp( var_getdval( &( argv[ 0 ] ) ) );

   return &nvar;
   }

/***************************************************************

        FUNCTION:       fnc_cint()

        DESCRIPTION:

***************************************************************/

struct bwb_variable *
fnc_cint( int argc, struct bwb_variable *argv )
   {
   static struct bwb_variable nvar;
   static int init = FALSE;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, SINGLE );
      }

   /* check parameters */

   #if PROG_ERRORS
   if ( argc < 1 )
      {
      sprintf( bwb_ebuf, "Not enough parameters (%d) to function CINT().",
         argc );
      bwb_error( bwb_ebuf );
      return NULL;
      }
   else if ( argc > 1 )
      {
      sprintf( bwb_ebuf, "Too many parameters (%d) to function CINT().",
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

   /* get truncated integer value */

   * var_findfval( &nvar, nvar.array_pos )
      = (float) trnc_int( (double) var_getfval( &( argv[ 0 ] )) );

   return &nvar;
   }

double
trnc_int( double x )
   {
   double sign;

   if ( x < 0.0 )
      {
      sign = -1.0;
      }
   else
      {
      sign = 1.0;
      }

   return ( floor( fabs( x )) * sign );
   }


