/****************************************************************

        bwb_mth.c       Mathematical Functions
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

****************************************************************/

/*---------------------------------------------------------------*/
/* NOTE: Modifications marked "JBV" were made by Jon B. Volkoff, */
/* 11/1995 (eidetics@cerf.net).                                  */
/*---------------------------------------------------------------*/

#include <stdio.h>
#include <ctype.h>
#include <math.h>
#include <time.h>

#include "bwbasic.h"
#include "bwb_mes.h"

#ifndef RAND_MAX			/* added in v1.11 */
#define RAND_MAX	32767
#endif

#if ANSI_C
bnumber round_int( bnumber x );
#else
bnumber round_int();
#endif

#if MS_FUNCS
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
#endif

#if COMPRESS_FUNCS

/***************************************************************

	FUNCTION:       fnc_core()

	DESCRIPTION:    This C function implements all core
			BASIC functions if COMPRESS_FUNCS is
			TRUE.  This method saves program space.

***************************************************************/

#if ANSI_C
struct bwb_variable *
fnc_core( int argc, struct bwb_variable *argv, int unique_id  )
#else
struct bwb_variable *
fnc_core( argc, argv, unique_id  )
   int argc;
   struct bwb_variable *argv;
   int unique_id;
#endif
   {
   static struct bwb_variable nvar;
   static int init = FALSE;
   bnumber nval;

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in fnc_core(): entered function" );
   bwb_debug( bwb_ebuf );
#endif

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      strncpy( nvar.name, "(core var)", MAXVARNAMESIZE );
#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in fnc_core(): ready to make local variable <%s>",
	 nvar.name );
      bwb_debug( bwb_ebuf );
#endif
      var_make( &nvar, NUMBER );
      }

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in fnc_core(): received f_arg <%f> nvar type <%c>",
      var_getnval( &( argv[ 0 ] ) ), nvar.type );
   bwb_debug( bwb_ebuf );
#endif

   /* check for number of arguments as appropriate */

   switch ( unique_id )
      {
      case F_RND:                       /* no arguments necessary for RND */
	 break;
      default:
#if PROG_ERRORS
	 if ( argc < 1 )
	    {
	    sprintf( bwb_ebuf, "Not enough parameters (%d) to core function.",
	       argc );
	    bwb_error( bwb_ebuf );
	    return NULL;
	    }
	 else if ( argc > 1 )
	    {
	    sprintf( bwb_ebuf, "Too many parameters (%d) to core function.",
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
      }

   /* assign values */

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in fnc_core(): nvar type <%c>; calling findnval()",
      nvar.type );
   bwb_debug( bwb_ebuf );
#endif

   switch( unique_id )
      {
      case F_ABS:
         /* Added double recast here (JBV) */
	 * var_findnval( &nvar, nvar.array_pos ) =
	    (bnumber) fabs( (double) var_getnval( &( argv[ 0 ] ) ) );
	 break;
      case F_ATN:
	 * var_findnval( &nvar, nvar.array_pos )
	    = (bnumber) atan( (double) var_getnval( &( argv[ 0 ] ) ) );
	 break;
      case F_COS:
	 * var_findnval( &nvar, nvar.array_pos )
	    = (bnumber) cos( (double) var_getnval( &( argv[ 0 ] ) ) );
	 break;
      case F_ACOS:
	 * var_findnval( &nvar, nvar.array_pos )
	    = (bnumber) acos( (double) var_getnval( &( argv[ 0 ] ) ) );
	 break;
      case F_ASIN:
	 * var_findnval( &nvar, nvar.array_pos )
	    = (bnumber) asin( (double) var_getnval( &( argv[ 0 ] ) ) );
	 break;
	   case F_EXP:
         /* Added double recast here (JBV) */
	 * var_findnval( &nvar, nvar.array_pos )
	    = (bnumber) exp( (double) var_getnval( &( argv[ 0 ] ) ) );
	 break;
      case F_INT:
	 * var_findnval( &nvar, nvar.array_pos )
	    = (bnumber) floor( (double) var_getnval( &( argv[ 0 ] ) ) );
	 break;
      case F_LOG:
	 * var_findnval( &nvar, nvar.array_pos )
	    = (bnumber) log( (double) var_getnval( &( argv[ 0 ] ) ) );
	 break;
      case F_RND:
         /* Added bnumber recast here (JBV) */
	 * var_findnval( &nvar, nvar.array_pos )
	    = (bnumber) ( (float) rand() / RAND_MAX );
	 break;
      case F_SGN:
	 nval = var_getnval( &( argv[ 0 ] ));
	 if ( nval == (bnumber) 0.0 )
	    {
	    * var_findnval( &nvar, nvar.array_pos ) = (bnumber) 0;
	    }
	 else if ( nval > (bnumber) 0.0 )
	    {
	    * var_findnval( &nvar, nvar.array_pos ) = (bnumber) 1;
	    }
	 else
	    {
	    * var_findnval( &nvar, nvar.array_pos ) = (bnumber) -1;
	    }
	 break;
      case F_SIN:
	 * var_findnval( &nvar, nvar.array_pos )
	    = (bnumber) sin( (double) var_getnval( &( argv[ 0 ] ) ) );
	 break;
      case F_SQR:
	 * var_findnval( &nvar, nvar.array_pos )
	    = (bnumber) sqrt( (double) var_getnval( &( argv[ 0 ] ) ) );
	 break;
      case F_TAN:
	 * var_findnval( &nvar, nvar.array_pos )
	    = (bnumber) tan( (double) var_getnval( &( argv[ 0 ] ) ) );
	 break;
      }

   return &nvar;

   }

#else

/***************************************************************

        FUNCTION:       fnc_abs()

        DESCRIPTION:    This C function implements the BASIC
                        predefined ABS function, returning the
                        absolute value of the argument.

	SYNTAX:		ABS( number )

***************************************************************/

#if ANSI_C
struct bwb_variable *
fnc_abs( int argc, struct bwb_variable *argv, int unique_id  )
#else
struct bwb_variable *
fnc_abs( argc, argv, unique_id  )
   int argc;
   struct bwb_variable *argv;
   int unique_id;
#endif
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
      var_make( &nvar, NUMBER );
      }

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in fnc_abs(): received f_arg <%f> nvar type <%c>",
      var_getnval( &( argv[ 0 ] ) ), nvar.type );
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
   sprintf( bwb_ebuf, "in fnc_abs(): nvar type <%c>; calling finnval()",
      nvar.type );
   bwb_debug( bwb_ebuf );
#endif

   /* Added double recast here (JBV) */
   * var_findnval( &nvar, nvar.array_pos ) = 
      (bnumber) fabs( (double) var_getnval( &( argv[ 0 ] ) ) );

   return &nvar;

   }

/***************************************************************

        FUNCTION:       fnc_rnd()

        DESCRIPTION:    This C function implements the BASIC
                        predefined RND function, returning a
                        pseudo-random number in the range
                        0 to 1.  It is affected by the RANDOMIZE
                        command statement.

	SYNTAX:		RND( number )

***************************************************************/

#if ANSI_C
struct bwb_variable *
fnc_rnd( int argc, struct bwb_variable *argv, int unique_id  )
#else
struct bwb_variable *
fnc_rnd( argc, argv, unique_id  )
   int argc;
   struct bwb_variable *argv;
   int unique_id;
#endif
   {
   static struct bwb_variable nvar;
   static int init = FALSE;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, NUMBER );
      }

   /* Added bnumber recast here (JBV) */
   * var_findnval( &nvar, nvar.array_pos )
      = (bnumber) ( (float) rand() / RAND_MAX );

   return &nvar;
   }

/***************************************************************

        FUNCTION:       fnc_atn()

	DESCRIPTION:    This C function implements the BASIC
                        predefined ATN function, returning the
                        arctangent of the argument.

	SYNTAX:		ATN( number )

***************************************************************/

#if ANSI_C
struct bwb_variable *
fnc_atn( int argc, struct bwb_variable *argv, int unique_id  )
#else
struct bwb_variable *
fnc_atn( argc, argv, unique_id  )
   int argc;
   struct bwb_variable *argv;
   int unique_id;
#endif
   {
   static struct bwb_variable nvar;
   static int init = FALSE;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, NUMBER );
      }

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in fnc_atn(): received f_arg <%f> ",
      var_getnval( &( argv[ 0 ] ) ) );
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

   * var_findnval( &nvar, nvar.array_pos ) 
      = (bnumber) atan( (double) var_getnval( &( argv[ 0 ] ) ) );

   return &nvar;

   }

/***************************************************************

        FUNCTION:       fnc_cos()

        DESCRIPTION:    This C function implements the BASIC
                        predefined COS function, returning the
                        cosine of the argument.

	SYNTAX:		COS( number )

***************************************************************/

#if ANSI_C
struct bwb_variable *
fnc_cos( int argc, struct bwb_variable *argv, int unique_id  )
#else
struct bwb_variable *
fnc_cos( argc, argv, unique_id  )
   int argc;
   struct bwb_variable *argv;
   int unique_id;
#endif
   {
   static struct bwb_variable nvar;
   static int init = FALSE;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, NUMBER );
      }

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in fnc_cos(): received f_arg <%f> ",
      var_getnval( &( argv[ 0 ] ) ) );
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

   * var_findnval( &nvar, nvar.array_pos ) 
      = (bnumber) cos( (double) var_getnval( &( argv[ 0 ] ) ) );

   return &nvar;

   }
/***************************************************************

        FUNCTION:       fnc_acos()

        DESCRIPTION:    This C function implements the BASIC

                        predefined ACOS function, returning the
                        arccosinus of the argument.

***************************************************************/

#if ANSI_C
struct bwb_variable *
fnc_acos( int argc, struct bwb_variable *argv, int unique_id  )
#else
struct bwb_variable *
fnc_cos( argc, argv, unique_id  )
   int argc;
   struct bwb_variable *argv;
   int unique_id;
#endif
   {
   static struct bwb_variable nvar;
   static int init = FALSE;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, NUMBER );
      }

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in fnc_cos(): received f_arg <%f> ",
      var_getnval( &( argv[ 0 ] ) ) );
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

   * var_findnval( &nvar, nvar.array_pos ) 
      = (bnumber) acos( (double) var_getnval( &( argv[ 0 ] ) ) );

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

        FUNCTION:       fnc_log()

        DESCRIPTION:    This C function implements the BASIC
                        predefined LOG function, returning the
                        natural logarithm of the argument.

	SYNTAX:		LOG( number )

***************************************************************/

#if ANSI_C
struct bwb_variable *
fnc_log( int argc, struct bwb_variable *argv, int unique_id  )
#else
struct bwb_variable *
fnc_log( argc, argv, unique_id  )
   int argc;
   struct bwb_variable *argv;
   int unique_id;
#endif
   {
   static struct bwb_variable nvar;
   static int init = FALSE;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, NUMBER );
      }

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in fnc_log(): received f_arg <%f> ",
      var_getnval( &( argv[ 0 ] ) ) );
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

   * var_findnval( &nvar, nvar.array_pos ) 
      = (bnumber) log( (double) var_getnval( &( argv[ 0 ] ) ) );

   return &nvar;
   }

/***************************************************************

        FUNCTION:       fnc_sin()

        DESCRIPTION:    This C function implements the BASIC
                        predefined SIN function, returning
                        the sine of the argument.

	SYNTAX:		SIN( number )

***************************************************************/

#if ANSI_C
struct bwb_variable *
fnc_sin( int argc, struct bwb_variable *argv, int unique_id  )
#else
struct bwb_variable *
fnc_sin( argc, argv, unique_id  )
   int argc;
   struct bwb_variable *argv;
   int unique_id;
#endif
   {
   static struct bwb_variable nvar;
   static int init = FALSE;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, NUMBER );
      }

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in fnc_sin(): received f_arg <%f> ",
      var_getnval( &( argv[ 0 ] ) ) );
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

   * var_findnval( &nvar, nvar.array_pos ) 
      = (bnumber) sin( (double) var_getnval( &( argv[ 0 ] ) ) );

   return &nvar;

   }


/***************************************************************

        FUNCTION:       fnc_sqr()

        DESCRIPTION:    This C function implements the BASIC
                        predefined SQR function, returning
                        the square root of the argument.

	SYNTAX:		SQR( number )

***************************************************************/

#if ANSI_C
struct bwb_variable *
fnc_sqr( int argc, struct bwb_variable *argv, int unique_id  )
#else
struct bwb_variable *
fnc_sqr( argc, argv, unique_id  )
   int argc;
   struct bwb_variable *argv;
   int unique_id;
#endif
   {
   static struct bwb_variable nvar;
   static int init = FALSE;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, NUMBER );
      }

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in fnc_sqr(): received f_arg <%f> ",
      var_getnval( &( argv[ 0 ] ) ) );
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

   * var_findnval( &nvar, nvar.array_pos ) 
      = (bnumber) sqrt( (double) var_getnval( &( argv[ 0 ] ) ) );

   return &nvar;

   }

/***************************************************************

        FUNCTION:       fnc_tan()

        DESCRIPTION:    This C function implements the BASIC
                        predefined TAN function, returning the
                        tangent of the argument.

	SYNTAX:		TAN( number )

***************************************************************/

#if ANSI_C
struct bwb_variable *
fnc_tan( int argc, struct bwb_variable *argv, int unique_id  )
#else
struct bwb_variable *
fnc_tan( argc, argv, unique_id  )
   int argc;
   struct bwb_variable *argv;
   int unique_id;
#endif
   {
   static struct bwb_variable nvar;
   static int init = FALSE;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, NUMBER );
      }

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in fnc_tan(): received f_arg <%f> ",
      var_getnval( &( argv[ 0 ] ) ) );
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

   * var_findnval( &nvar, nvar.array_pos ) 
      = (bnumber) tan( (double) var_getnval( &( argv[ 0 ] ) ) );

   return &nvar;

   }


/***************************************************************

        FUNCTION:       fnc_sgn()

        DESCRIPTION:    This C function implements the BASIC
                        predefined SGN function, returning 0
                        if the argument is 0, -1 if the argument
                        is less than 0, or 1 if the argument
                        is more than 0.

	SYNTAX:		SGN( number )

***************************************************************/

#if ANSI_C
struct bwb_variable *
fnc_sgn( int argc, struct bwb_variable *argv, int unique_id  )
#else
struct bwb_variable *
fnc_sgn( argc, argv, unique_id  )
   int argc;
   struct bwb_variable *argv;
   int unique_id;
#endif
   {
   static struct bwb_variable nvar;
   bnumber nval;
   static int init = FALSE;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, NUMBER );
      }

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in fnc_sgn(): received f_arg <%f> ",
      var_getnval( &( argv[ 0 ] ) ) );
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

   nval = var_getnval( &( argv[ 0 ] ));

   if ( nval == (bnumber) 0.0 )
      {
      * var_findnval( &nvar, nvar.array_pos ) = (bnumber) 0;
      }
   else if ( nval > (bnumber) 0.0 )
      {
      * var_findnval( &nvar, nvar.array_pos ) = (bnumber) 1;
      }
   else
      {
      * var_findnval( &nvar, nvar.array_pos ) = (bnumber) -1;
      }

   return &nvar;
   }

/***************************************************************

        FUNCTION:       fnc_int()

        DESCRIPTION:    This C function implements the BASIC
                        predefined INT function, returning an
                        integer value less then or equal to the 
			argument.

	SYNTAX:		INT( number )

***************************************************************/

#if ANSI_C
struct bwb_variable *
fnc_int( int argc, struct bwb_variable *argv, int unique_id  )
#else
struct bwb_variable *
fnc_int( argc, argv, unique_id  )
   int argc;
   struct bwb_variable *argv;
   int unique_id;
#endif
   {
   static struct bwb_variable nvar;
   static int init = FALSE;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, NUMBER );
      }

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in fnc_int(): received f_arg <%f> ",
      var_getnval( &( argv[ 0 ] ) ) );
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

   * var_findnval( &nvar, nvar.array_pos ) 
      = (bnumber) floor( (double) var_getnval( &( argv[ 0 ] ) ) );

   return &nvar;
   }

/***************************************************************

        FUNCTION:       fnc_exp()

	DESCRIPTION:    This C function implements the BASIC
			EXP() function, returning the exponential
			value of the argument.

	SYNTAX:		EXP( number )

***************************************************************/

#if ANSI_C
struct bwb_variable *
fnc_exp( int argc, struct bwb_variable *argv, int unique_id )
#else
struct bwb_variable *
fnc_exp( argc, argv, unique_id )
   int argc;
   struct bwb_variable *argv;
   int unique_id;
#endif
   {
   static struct bwb_variable nvar;
   static int init = FALSE;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, NUMBER );
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

   /* Added double recast here (JBV) */
   * var_findnval( &nvar, nvar.array_pos ) 
      = (bnumber) exp( (double) var_getnval( &( argv[ 0 ] ) ) );

   return &nvar;
   }

#endif                          /* COMPRESS_FUNCS */

#if COMMON_FUNCS

/***************************************************************

        FUNCTION:       fnc_val()

	DESCRIPTION:    This C function implements the BASIC
			VAL() function, returning the numerical
			value of its string argument.

	SYNTAX:		VAL( string$ )

***************************************************************/

#if ANSI_C
struct bwb_variable *
fnc_val( int argc, struct bwb_variable *argv, int unique_id )
#else
struct bwb_variable *
fnc_val( argc, argv, unique_id )
   int argc;
   struct bwb_variable *argv;
   int unique_id;
#endif
   {
   static struct bwb_variable nvar;
   static char *tbuf;
   static int init = FALSE;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, NUMBER );

      /* Revised to CALLOC pass-thru call by JBV */
      if ( ( tbuf = CALLOC( MAXSTRINGSIZE + 1, sizeof( char ), "fnc_val" )) == NULL )
         {
#if PROG_ERRORS
         bwb_error( "in fnc_val(): failed to get memory for tbuf" );
#else
         bwb_error( err_getmem );
#endif
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

   if ( argv[ 0 ].type != STRING )
      {
#if PROG_ERRORS
      sprintf( bwb_ebuf, "Argument to function VAL() must be a string." );
      bwb_error( bwb_ebuf );
#else
      bwb_error( err_mismatch );
#endif
      return NULL;
      }

   /* read the value */

   str_btoc( tbuf, var_getsval( &( argv[ 0 ] ) ));
   *var_findnval( &nvar, nvar.array_pos ) = (bnumber) 0; /* JBV 1/97 */
   if ( strlen( tbuf ) != 0 ) /* JBV 1/97 (was == 0 with else) */
#if NUMBER_DOUBLE
   sscanf( tbuf, "%lf",
       var_findnval( &nvar, nvar.array_pos ) );
#else
   sscanf( tbuf, "%f",
       var_findnval( &nvar, nvar.array_pos ) );
#endif

   return &nvar;
   }

/***************************************************************

        FUNCTION:       fnc_str()

	DESCRIPTION:    This C function implements the BASIC
			STR$() function, returning an ASCII string
			with the decimal value of the numerical argument.

	SYNTAX:		STR$( number )

***************************************************************/

#if ANSI_C
struct bwb_variable *
fnc_str( int argc, struct bwb_variable *argv, int unique_id )
#else
struct bwb_variable *
fnc_str( argc, argv, unique_id )
   int argc;
   struct bwb_variable *argv;
   int unique_id;
#endif
   {
   static struct bwb_variable nvar;
   static char *tbuf;
   static int init = FALSE;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, STRING );

      /* Revised to CALLOC pass-thru call by JBV */
      if ( ( tbuf = CALLOC( MAXSTRINGSIZE + 1, sizeof( char ), "fnc_str" )) == NULL )
         {
#if PROG_ERRORS
         bwb_error( "in fnc_str(): failed to get memory for tbuf" );
#else
         bwb_error( err_getmem );
#endif
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
      var_getnval( &( argv[ 0 ] ) ) ); 
   str_ctob( var_findsval( &nvar, nvar.array_pos ), tbuf );

   return &nvar;
   }

#endif                          /* COMMON_FUNCS */

#if MS_FUNCS

/***************************************************************

        FUNCTION:       fnc_hex()

	DESCRIPTION:    This C function implements the BASIC
			HEX$() function, returning a string
			containing the hexadecimal value of
			the numerical argument.

	SYNTAX:		HEX$( number )

***************************************************************/

#if ANSI_C
struct bwb_variable *
fnc_hex( int argc, struct bwb_variable *argv, int unique_id )
#else
struct bwb_variable *
fnc_hex( argc, argv, unique_id )
   int argc;
   struct bwb_variable *argv;
   int unique_id;
#endif
   {
   static struct bwb_variable nvar;
   static char *tbuf;
   static int init = FALSE;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, STRING );

      /* Revised to CALLOC pass-thru call by JBV */
      if ( ( tbuf = CALLOC( MAXSTRINGSIZE + 1, sizeof( char ), "fnc_hex" )) == NULL )
         {
#if PROG_ERRORS
         bwb_error( "in fnc_hex(): failed to get memory for tbuf" );
#else
         bwb_error( err_getmem );
#endif
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

   sprintf( tbuf, "%X", (int) trnc_int( (bnumber) var_getnval( &( argv[ 0 ] )) ) );
   str_ctob( var_findsval( &nvar, nvar.array_pos ), tbuf );
   return &nvar;
   }

/***************************************************************

        FUNCTION:       fnc_oct()

        DESCRIPTION:	This C function implements the BASIC
			OCT$() function, returning a string
			with the octal value of the numerical
			argument.

	SYNTAX:		OCT$( number )

***************************************************************/

#if ANSI_C
struct bwb_variable *
fnc_oct( int argc, struct bwb_variable *argv, int unique_id )
#else
struct bwb_variable *
fnc_oct( argc, argv, unique_id )
   int argc;
   struct bwb_variable *argv;
   int unique_id;
#endif
   {
   static struct bwb_variable nvar;
   static char *tbuf;
   static int init = FALSE;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, STRING );

      /* Revised to CALLOC pass-thru call by JBV */
      if ( ( tbuf = CALLOC( MAXSTRINGSIZE + 1, sizeof( char ), "fnc_oct" )) == NULL )
         {
#if PROG_ERRORS
         bwb_error( "in fnc_oct(): failed to get memory for tbuf" );
#else
         bwb_error( err_getmem );
#endif
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

   /* Revised by JBV */
   /* sprintf( tbuf, "%o", (int) var_getnval( &( argv[ 0 ] ) ) ); */
   sprintf( tbuf, "%o", (int) trnc_int( (bnumber) var_getnval( &( argv[ 0 ] )) ) );
   str_ctob( var_findsval( &nvar, nvar.array_pos ), tbuf );
   return &nvar;
   }

/***************************************************************

        FUNCTION:       fnc_mki()

        DESCRIPTION:    This C function implements the BASIC
                        predefined MKI$() function.

	NOTE:		As implemented in bwBASIC, this is a
			pseudo-function, since bwBASIC does
			not recognize precision levels.

	SYNTAX:		MKI$( number )

***************************************************************/

#if ANSI_C
struct bwb_variable *
fnc_mki( int argc, struct bwb_variable *argv, int unique_id  )
#else
struct bwb_variable *
fnc_mki( argc, argv, unique_id  )
   int argc;
   struct bwb_variable *argv;
   int unique_id;
#endif
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

   an_integer.the_integer = (int) var_getnval( &( argv[ 0 ] ) );

   for ( i = 0; i < sizeof( int ); ++i )
      {
      tbuf[ i ] = an_integer.the_chars[ i ];
      tbuf[ i + 1 ] = '\0';
      }
   b = var_getsval( &nvar );
   b->length = sizeof( int );
   b->sbuffer = tbuf;
   b->rab = FALSE;

   return &nvar;
   }

/***************************************************************

        FUNCTION:       fnc_mkd()

        DESCRIPTION:    This C function implements the BASIC
                        predefined MKD$() function.

	NOTE:		As implemented in bwBASIC, this is a
			pseudo-function, since bwBASIC does
			not recognize precision levels.

	SYNTAX:		MKD$( number )

***************************************************************/

#if ANSI_C
struct bwb_variable *
fnc_mkd( int argc, struct bwb_variable *argv, int unique_id  )
#else
struct bwb_variable *
fnc_mkd( argc, argv, unique_id  )
   int argc;
   struct bwb_variable *argv;
   int unique_id;
#endif
   {
   register int i;
   static struct bwb_variable nvar;
   bstring *b;
   static char tbuf[ sizeof ( double ) ];
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

   a_double.the_double = var_getnval( &( argv[ 0 ] ) );

   for ( i = 0; i < sizeof ( double ); ++i )
      {
      tbuf[ i ] = a_double.the_chars[ i ];
      tbuf[ i + 1 ] = '\0';
      }
   b = var_getsval( &nvar );
   b->length = sizeof( double );
   b->sbuffer = tbuf;
   b->rab = FALSE;

   return &nvar;
   }

/***************************************************************

        FUNCTION:       fnc_mks()

        DESCRIPTION:    This C function implements the BASIC
                        predefined MKS$() function.

	NOTE:		As implemented in bwBASIC, this is a
			pseudo-function, since bwBASIC does
			not recognize precision levels.

	SYNTAX:		MKS$( number )

***************************************************************/

#if ANSI_C
struct bwb_variable *
fnc_mks( int argc, struct bwb_variable *argv, int unique_id  )
#else
struct bwb_variable *
fnc_mks( argc, argv, unique_id  )
   int argc;
   struct bwb_variable *argv;
   int unique_id;
#endif
   {
   register int i;
   static struct bwb_variable nvar;
   static char tbuf[ 5 ];
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

   a_float.the_float = var_getnval( &( argv[ 0 ] ) );

   for ( i = 0; i < sizeof( float ); ++i )
      {
      tbuf[ i ] = a_float.the_chars[ i ];
      tbuf[ i + 1 ] = '\0';
      }
   b = var_getsval( &nvar );
   b->length = sizeof( float );
   b->sbuffer = tbuf;
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

	NOTE:		As implemented in bwBASIC, this is a
			pseudo-function, since bwBASIC does
			not recognize precision levels.

	SYNTAX:		CVI( string$ )

***************************************************************/

#if ANSI_C
struct bwb_variable *
fnc_cvi( int argc, struct bwb_variable *argv, int unique_id  )
#else
struct bwb_variable *
fnc_cvi( argc, argv, unique_id  )
   int argc;
   struct bwb_variable *argv;
   int unique_id;
#endif
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
      var_make( &nvar, NUMBER );
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
      an_integer.the_chars[ i ] = b->sbuffer[ i ];
      }

   * var_findnval( &nvar, nvar.array_pos ) = (bnumber) an_integer.the_integer;

   return &nvar;
   }

/***************************************************************

        FUNCTION:       fnc_cvd()

        DESCRIPTION:    This C function implements the BASIC
                        predefined CVD() function.

	NOTE:		As implemented in bwBASIC, this is a
			pseudo-function, since bwBASIC does
			not recognize precision levels.

	SYNTAX:		CVD( string$ )

***************************************************************/

#if ANSI_C
struct bwb_variable *
fnc_cvd( int argc, struct bwb_variable *argv, int unique_id  )
#else
struct bwb_variable *
fnc_cvd( argc, argv, unique_id  )
   int argc;
   struct bwb_variable *argv;
   int unique_id;
#endif
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
      var_make( &nvar, NUMBER );
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
      a_double.the_chars[ i ] = b->sbuffer[ i ];
      }

   * var_findnval( &nvar, nvar.array_pos ) = (bnumber) a_double.the_double;

   return &nvar;

   }

/***************************************************************

        FUNCTION:       fnc_cvs()

        DESCRIPTION:    This C function implements the BASIC
                        predefined CVS() function.

	NOTE:		As implemented in bwBASIC, this is a
			pseudo-function, since bwBASIC does
			not recognize precision levels.

	SYNTAX:		CVS( string$ )

***************************************************************/

#if ANSI_C
struct bwb_variable *
fnc_cvs( int argc, struct bwb_variable *argv, int unique_id  )
#else
struct bwb_variable *
fnc_cvs( argc, argv, unique_id  )
   int argc;
   struct bwb_variable *argv;
   int unique_id;
#endif
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
      var_make( &nvar, NUMBER );
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
      a_float.the_chars[ i ] = b->sbuffer[ i ];
      }

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in fnc_cvs(): string <%s> hex vals <%X><%X><%X><%X>",
      a_float.the_chars, a_float.the_chars[ 0 ], a_float.the_chars[ 1 ], 
      a_float.the_chars[ 2 ], a_float.the_chars[ 3 ] );
   bwb_debug( bwb_ebuf );
#endif

   * var_findnval( &nvar, nvar.array_pos ) = a_float.the_float;

   return &nvar;

   }

/***************************************************************

        FUNCTION:       fnc_csng()

	DESCRIPTION:    This C function implements the BASIC
			function CSNG().  As implemented,
			this is a pseudo-function, since
			all bwBASIC numerical values have the
			same precision.

	SYNTAX:		CSNG( number )

***************************************************************/

#if ANSI_C
struct bwb_variable *
fnc_csng( int argc, struct bwb_variable *argv, int unique_id )
#else
struct bwb_variable *
fnc_csng( argc, argv, unique_id )
   int argc;
   struct bwb_variable *argv;
   int unique_id;
#endif
   {
   static struct bwb_variable nvar;
   static int init = FALSE;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, NUMBER );
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

   * var_findnval( &nvar, nvar.array_pos )
      = (bnumber) var_getnval( &( argv[ 0 ] ) );

   return &nvar;
   }

/***************************************************************

        FUNCTION:       fnc_cint()

	DESCRIPTION:    This C function returns the truncated
			rounded integer value of its numerical
			argument.

	SYNTAX:		CINT( number )

***************************************************************/

#if ANSI_C
struct bwb_variable *
fnc_cint( int argc, struct bwb_variable *argv, int unique_id )
#else
struct bwb_variable *
fnc_cint( argc, argv, unique_id )
   int argc;
   struct bwb_variable *argv;
   int unique_id;
#endif
   {
   static struct bwb_variable nvar;
   static int init = FALSE;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, NUMBER );
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

   /* get rounded integer value */

   * var_findnval( &nvar, nvar.array_pos )
      = round_int( var_getnval( &( argv[ 0 ] ) ));

   return &nvar;
   }

#endif				/* MS_FUNCS */

/***************************************************************

	FUNCTION:       trnc_int()

	DESCRIPTION:    This function returns the truncated
			truncated integer value of its numerical
			argument.

***************************************************************/

#if ANSI_C
bnumber
trnc_int( bnumber x )
#else
bnumber
trnc_int( x )
   bnumber x;
#endif
   {
   double sign; /* Was bnumber (JBV) */

   if ( x < (bnumber) 0.0 )
      {
      sign = (double) -1.0; /* Was bnumber (JBV) */
      }
   else
      {
      sign = (double) 1.0; /* Was bnumber (JBV) */
      }

   /* Added double recast here (JBV) */
   return (bnumber) ( floor( fabs( (double) x )) * sign );
   }

/***************************************************************

	FUNCTION:       round_int()

	DESCRIPTION:    This function returns the truncated
			rounded integer value of its numerical
			argument.

***************************************************************/

#if ANSI_C
bnumber
round_int( bnumber x )
#else
bnumber
round_int( x )
   bnumber x;
#endif
   {

   if ( x < (bnumber) 0.00 )
      {
      /* Added double recasts here (JBV) */
      if ( (bnumber) fabs( (bnumber) floor( (double) x ) - x ) < (bnumber) 0.500 )
	 {
	 return (bnumber) floor( (double) x );
	 }
      else
	 {
	 return (bnumber) ceil( (double) x );
	 }
      }
   else
      {
      if ( ( x - (bnumber) floor( (double) x )) < (bnumber) 0.500 )
	 {
	 return (bnumber) floor( (double) x );
	 }
      else
	 {
	 return (bnumber) ceil( (double) x );
	 }
      }
   }


