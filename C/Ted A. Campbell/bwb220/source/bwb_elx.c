/****************************************************************

        bwb_elx.c       Parse Elements of Expressions
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
/*                                                               */
/* Those additionally marked with "DD" were at the suggestion of */
/* Dale DePriest (daled@cadence.com).                            */
/*---------------------------------------------------------------*/

#include <stdio.h>
#include <ctype.h>
#include <math.h>

#include "bwbasic.h"
#include "bwb_mes.h"

/***************************************************************

	FUNCTION:       exp_paren()

	DESCRIPTION:    This function interprets a parenthetical
			expression, calling bwb_exp() (recursively)
			to resolve the internal expression.

***************************************************************/

#if ANSI_C
int
exp_paren( char *expression )
#else
int
exp_paren( expression )
   char *expression;
#endif
   {
   struct exp_ese *e;
   int s_pos;                           /* position in build buffer */
   int loop;
   int paren_level;

   /* find a string enclosed by parentheses */

   CURTASK exps[ CURTASK expsc ].pos_adv = 1;       /* start beyond open paren */
   s_pos = 0;
   loop = TRUE;
   paren_level = 1;
   CURTASK exps[ CURTASK expsc ].string[ 0 ] = '\0';

   while( loop == TRUE )
      {

      /* check the current character */

      switch( expression[ CURTASK exps[ CURTASK expsc ].pos_adv ] )
         {

         case '\r':				/* these tests added v1.11 */
         case '\n':
         case '\0':
            bwb_error( err_incomplete );
            loop = FALSE;
            break;

         case '(':
            ++paren_level;
            CURTASK exps[ CURTASK expsc ].string[ s_pos ]
               = expression[ CURTASK exps[ CURTASK expsc ].pos_adv ];
            ++s_pos;
            CURTASK exps[ CURTASK expsc ].string[ s_pos ] = '\0';
            break;

         case ')':

            --paren_level;
            if ( paren_level == 0 )
               {
               loop = FALSE;
               }
            else
               {
               CURTASK exps[ CURTASK expsc ].string[ s_pos ]
                  = expression[ CURTASK exps[ CURTASK expsc ].pos_adv ];
               ++s_pos;
               CURTASK exps[ CURTASK expsc ].string[ s_pos ] = '\0';
               }
            break;

         case '\"':                             /* embedded string constant */
            ++CURTASK exps[ CURTASK expsc ].pos_adv;
            while ( ( expression[ CURTASK exps[ CURTASK expsc ].pos_adv ] != '\"' )
               && ( expression[ CURTASK exps[ CURTASK expsc ].pos_adv ] != '\0' ) )
               {
               CURTASK exps[ CURTASK expsc ].string[ s_pos ]
                  = expression[ CURTASK exps[ CURTASK expsc ].pos_adv ];
               ++s_pos;
               CURTASK exps[ CURTASK expsc ].string[ s_pos ] = '\0';
               ++CURTASK exps[ CURTASK expsc ].pos_adv;
               }
            break;

         default:
            CURTASK exps[ CURTASK expsc ].string[ s_pos ]
               = expression[ CURTASK exps[ CURTASK expsc ].pos_adv ];
            ++s_pos;
            CURTASK exps[ CURTASK expsc ].string[ s_pos ] = '\0';
            break;
         }

      /* advance the counter */

      ++CURTASK exps[ CURTASK expsc ].pos_adv;

      }

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in exp_paren() found internal string <%s>",
      CURTASK exps[ CURTASK expsc ].string );
   bwb_debug( bwb_ebuf );
#endif

   /* call bwb_exp() recursively to interpret this expression */

   CURTASK exps[ CURTASK expsc ].rec_pos = 0;
   e = bwb_exp( CURTASK exps[ CURTASK expsc ].string, FALSE,
          &( CURTASK exps[ CURTASK expsc ].rec_pos ) );

   /* assign operation and value at this level */

   CURTASK exps[ CURTASK expsc ].type = e->type;

   switch ( e->type )
      {
      case STRING:
         CURTASK exps[ CURTASK expsc ].operation = CONST_STRING;
         str_btob( exp_getsval( &( CURTASK exps[ CURTASK expsc ] )), exp_getsval( e ) );
         break;
      default:
         CURTASK exps[ CURTASK expsc ].operation = NUMBER;
         CURTASK exps[ CURTASK expsc ].nval = exp_getnval( e );
         break;
      }

   return TRUE;

   }

/***************************************************************

        FUNCTION:   	exp_strconst()

        DESCRIPTION:	This function interprets a string
			constant.

***************************************************************/

#if ANSI_C
int
exp_strconst( char *expression )
#else
int
exp_strconst( expression )
   char *expression;
#endif
   {
   int e_pos, s_pos;

   /* assign values to structure */

   CURTASK exps[ CURTASK expsc ].type = STRING;
   CURTASK exps[ CURTASK expsc ].operation = CONST_STRING;

   /* set counters */

   s_pos = 0;
   CURTASK exps[ CURTASK expsc ].pos_adv = e_pos = 1;
   CURTASK exps[ CURTASK expsc ].string[ 0 ] = '\0';

   /* read the string up until the next double quotation mark */

   /* While yer at it, check for a null terminator too (JBV, found by DD) */
   while(( expression[ e_pos ] != '\"') && ( expression[ e_pos ] != '\0' ))
      {
      CURTASK exps[ CURTASK expsc ].string[ s_pos ] = expression[ e_pos ];
      ++e_pos;
      ++s_pos;
      ++CURTASK exps[ CURTASK expsc ].pos_adv;
      CURTASK exps[ CURTASK expsc ].string[ s_pos ] = '\0';
      if ( s_pos >= ( MAXSTRINGSIZE - 1 ) )
         {
#if PROG_ERRORS
         sprintf( bwb_ebuf, "string <%s> exceeds maximum size (%d) for string constant.",
            expression, MAXSTRINGSIZE );
         bwb_error( bwb_ebuf );
#else
         bwb_error( err_overflow );
#endif
         return OP_NULL;
         }
      }

   /* now write string over to bstring */

   str_ctob( &( CURTASK exps[ CURTASK expsc ].sval ), CURTASK exps[ CURTASK expsc ].string );

   /* advance past last double quotation mark */

   /*-------------------------------------------------------------*/
   /* Of course, it doesn't hurt to make sure it's really a quote */
   /* (JBV, found by DD)                                          */
   /*-------------------------------------------------------------*/
   if ( expression[ e_pos ] == '\"' ) ++CURTASK exps[ CURTASK expsc ].pos_adv;

   /* return */

   return TRUE;

   }

/***************************************************************

        FUNCTION:	exp_numconst()

        DESCRIPTION:	This function interprets a numerical
			constant.

***************************************************************/

#if ANSI_C
int
exp_numconst( char *expression )
#else
int
exp_numconst( expression )
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
#if CHECK_RECURSION
   static int in_use = FALSE;                   /* boolean: is function in use? */

   /* check recursion status */

   if ( in_use == TRUE )
      {
      sprintf( bwb_ebuf, "Recursion error in bwb_exp.c:exp_findop(): recursion violation." );
      bwb_error( bwb_ebuf );
      }

   /* reset recursion status indicator */

   else
      {
      in_use = TRUE;
      }
#endif

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
   sprintf( bwb_ebuf, "in exp_numconst(): received <%s>, eval <%c>",
      expression, expression[ 0 ] );
   bwb_debug( bwb_ebuf );
#endif

   need_pm = FALSE;
   CURTASK exps[ CURTASK expsc ].nval = (bnumber) 0;

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
         return OP_NULL;
      }

   /* now build the mantissa according to the numerical base */

   switch( base )
      {

      case 10:                          /* decimal constant */

         /* initialize counters */

         CURTASK exps[ CURTASK expsc ].pos_adv = man_start;
         CURTASK exps[ CURTASK expsc ].type = NUMBER;
         CURTASK exps[ CURTASK expsc ].string[ 0 ] = '\0';
         s_pos = 0;
         exponent = OP_NULL;
         build_loop = TRUE;

         /* loop to build the string */

         while ( build_loop == TRUE )
            {
            switch( expression[ CURTASK exps[ CURTASK expsc ].pos_adv ] )
               {
               case '-':                        /* prefixed plus or minus */
               case '+':

                  /* in the first position, a plus or minus sign can
                     be added to the beginning of the string to be
                     scanned */

                  if ( CURTASK exps[ CURTASK expsc ].pos_adv == man_start )
                     {
                     CURTASK exps[ CURTASK expsc ].string[ s_pos ] = expression[ CURTASK exps[ CURTASK expsc ].pos_adv ];
                     ++CURTASK exps[ CURTASK expsc ].pos_adv;  /* advance to next character */
                     ++s_pos;
                     CURTASK exps[ CURTASK expsc ].string[ s_pos ] = '\0';
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
                  CURTASK exps[ CURTASK expsc ].string[ s_pos ] = expression[ CURTASK exps[ CURTASK expsc ].pos_adv ];
                  ++CURTASK exps[ CURTASK expsc ].pos_adv;  /* advance to next character */
                  ++s_pos;
                  CURTASK exps[ CURTASK expsc ].string[ s_pos ] = '\0';
                  break;

	       case '#':                        /* Microsoft-type precision indicator; ignored but terminates */
	       case '!':                        /* Microsoft-type precision indicator; ignored but terminates */
		  ++CURTASK exps[ CURTASK expsc ].pos_adv;  /* advance to next character */
		  CURTASK exps[ CURTASK expsc ].type = NUMBER;
		  exponent = FALSE;
		  build_loop = FALSE;
		  break;

	       case 'E':                        /* exponential, single precision */
               case 'e':
                  ++CURTASK exps[ CURTASK expsc ].pos_adv;  /* advance to next character */
                  CURTASK exps[ CURTASK expsc ].type = NUMBER;
		  exponent = TRUE;
                  build_loop = FALSE;
		  break;

               case 'D':                        /* exponential, double precision */
               case 'd':
                  ++CURTASK exps[ CURTASK expsc ].pos_adv;  /* advance to next character */
                  CURTASK exps[ CURTASK expsc ].type = NUMBER;
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
         sscanf( CURTASK exps[ CURTASK expsc ].string, "%lf", 
           var_findnval( &mantissa, mantissa.array_pos ));
#else
         sscanf( CURTASK exps[ CURTASK expsc ].string, "%f", 
           var_findnval( &mantissa, mantissa.array_pos ));
#endif

#if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in exp_numconst(): read mantissa, string <%s> val <%lf>",
            CURTASK exps[ CURTASK expsc ].string, var_getnval( &mantissa ) );
         bwb_debug( bwb_ebuf );
#endif

         /* test if integer bounds have been exceeded */

         if ( CURTASK exps[ CURTASK expsc ].type == NUMBER )
            {
            i = (int) var_getnval( &mantissa );
            d = (bnumber) i;
            if ( d != var_getnval( &mantissa ))
               {
               CURTASK exps[ CURTASK expsc ].type = NUMBER;
#if INTENSIVE_DEBUG
               sprintf( bwb_ebuf, "in exp_numconst(): integer bounds violated, promote to NUMBER" );
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

            CURTASK exps[ CURTASK expsc ].string[ 0 ] = '\0';
            s_pos = 0;
            build_loop = TRUE;

            /* loop to build the string */

            while ( build_loop == TRUE )
               {
               switch( expression[ CURTASK exps[ CURTASK expsc ].pos_adv ] )
                  {
		  case '-':                        /* prefixed plus or minus */
                  case '+':

		     if ( need_pm == TRUE )        /* only allow once */
			{
			CURTASK exps[ CURTASK expsc ].string[ s_pos ] = expression[ CURTASK exps[ CURTASK expsc ].pos_adv ];
			++CURTASK exps[ CURTASK expsc ].pos_adv;  /* advance to next character */
			++s_pos;
			CURTASK exps[ CURTASK expsc ].string[ s_pos ] = '\0';
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

                     CURTASK exps[ CURTASK expsc ].string[ s_pos ] = expression[ CURTASK exps[ CURTASK expsc ].pos_adv ];
                     ++CURTASK exps[ CURTASK expsc ].pos_adv;  /* advance to next character */
                     ++s_pos;
		     CURTASK exps[ CURTASK expsc ].string[ s_pos ] = '\0';
		     need_pm = FALSE;
                     break;

                  default:                         /* anything else, terminate */
                     build_loop = FALSE;
                     break;
                  }

               }                                /* end of build loop for exponent */

            /* assign the value to the user variable */

#if NUMBER_DOUBLE
            sscanf( CURTASK exps[ CURTASK expsc ].string, "%lf",
               &( CURTASK exps[ CURTASK expsc ].nval ) );
#else
            sscanf( CURTASK exps[ CURTASK expsc ].string, "%f",
               &( CURTASK exps[ CURTASK expsc ].nval ) );
#endif

#if INTENSIVE_DEBUG
	    sprintf( bwb_ebuf, "in exp_numconst(): exponent is <%d>",
               (int) CURTASK exps[ CURTASK expsc ].nval );
            bwb_debug( bwb_ebuf );
#endif

            }                           /* end of exponent search */

         if ( CURTASK exps[ CURTASK expsc ].nval == (bnumber) 0 )
            {
            CURTASK exps[ CURTASK expsc ].nval = var_getnval( &mantissa );
            }
         else
            {
            CURTASK exps[ CURTASK expsc ].nval = var_getnval( &mantissa )
               * pow( (bnumber) 10.0, (bnumber) CURTASK exps[ CURTASK expsc ].nval );
            }

         break;

      case 8:                           /* octal constant */

         /* initialize counters */

         CURTASK exps[ CURTASK expsc ].pos_adv = man_start;
         CURTASK exps[ CURTASK expsc ].type = NUMBER;
         CURTASK exps[ CURTASK expsc ].string[ 0 ] = '\0';
         s_pos = 0;
         exponent = OP_NULL;
         build_loop = TRUE;

         /* loop to build the string */

         while ( build_loop == TRUE )
            {
            switch( expression[ CURTASK exps[ CURTASK expsc ].pos_adv ] )
               {
               case '0':                        /* or ordinary digit */
               case '1':
               case '2':
               case '3':
               case '4':
               case '5':
               case '6':
               case '7':
                  CURTASK exps[ CURTASK expsc ].string[ s_pos ] = expression[ CURTASK exps[ CURTASK expsc ].pos_adv ];
                  ++CURTASK exps[ CURTASK expsc ].pos_adv;  /* advance to next character */
                  ++s_pos;
                  CURTASK exps[ CURTASK expsc ].string[ s_pos ] = '\0';
                  break;

               default:                         /* anything else, terminate */
                  build_loop = FALSE;
                  break;
               }

            }

         /* now scan the string to determine the number */

         sscanf( CURTASK exps[ CURTASK expsc ].string, "%o", &i );
         CURTASK exps[ CURTASK expsc ].nval = (bnumber) i;

         break;

      case 16:                          /* hexadecimal constant */

         /* initialize counters */

         CURTASK exps[ CURTASK expsc ].pos_adv = man_start;
         CURTASK exps[ CURTASK expsc ].type = NUMBER;
         CURTASK exps[ CURTASK expsc ].string[ 0 ] = '\0';
         s_pos = 0;
         exponent = OP_NULL;
         build_loop = TRUE;

         /* loop to build the string */

         while ( build_loop == TRUE )
            {
            switch( expression[ CURTASK exps[ CURTASK expsc ].pos_adv ] )
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
                  CURTASK exps[ CURTASK expsc ].string[ s_pos ] = expression[ CURTASK exps[ CURTASK expsc ].pos_adv ];

                  ++CURTASK exps[ CURTASK expsc ].pos_adv;  /* advance to next character */
                  ++s_pos;
                  CURTASK exps[ CURTASK expsc ].string[ s_pos ] = '\0';
                  break;

               default:                         /* anything else, terminate */
                  build_loop = FALSE;
                  break;
               }

            }

         /* now scan the string to determine the number */

         sscanf( CURTASK exps[ CURTASK expsc ].string, "%x", &i );
         CURTASK exps[ CURTASK expsc ].nval = (bnumber) i;
         break;
      }

   /* note that the operation at this level is now a determined NUMBER */

   CURTASK exps[ CURTASK expsc ].operation = NUMBER;

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in exp_numconst(): exit level <%d> precision <%c> value <%lf>",
      CURTASK expsc, CURTASK exps[ CURTASK expsc ].type, exp_getnval( &( CURTASK exps[ CURTASK expsc ] ) ) );
   bwb_debug( bwb_ebuf );
#endif

#if CHECK_RECURSION
   in_use = FALSE;
#endif

   return TRUE;

   }

/***************************************************************

	FUNCTION:       exp_function()

	DESCRIPTION:    This function interprets a function,
			calling bwb_exp() (recursively) to resolve any
			arguments to the function.

***************************************************************/

#if ANSI_C
int
exp_function( char *expression )
#else
int
exp_function( expression )
   char *expression;
#endif
   {
   struct exp_ese *e;
   int s_pos;                           /* position in build buffer */
   int loop;
   int paren_level;
   int n_args;
   struct bwb_variable *v;
   /* struct bwb_variable argv[ MAX_FARGS ]; */ /* Removed by JBV */
   struct bwb_variable *argv; /* Added by JBV */
   bstring *b;
   register int i, j; /* JBV */
#if INTENSIVE_DEBUG
   char tbuf[ MAXSTRINGSIZE + 1 ];

   sprintf( bwb_ebuf, "in exp_function(): entered function, expression <%s>",
      expression );
   bwb_debug( bwb_ebuf );
#endif

   /*-----------------------------------------------------------*/
   /* Added by JBV                                              */
   /* Required because adding a simple "static" modifier in the */
   /* argv declaration doesn't work for recursive calls!        */
   /*-----------------------------------------------------------*/
   if ( ( argv = (struct bwb_variable *) CALLOC( MAX_FARGS,
      sizeof( struct bwb_variable ), "exp_function" )) == NULL )
      {
      bwb_error( err_getmem );
      return 0;
      }

   /* assign pointers to argument stack */

   /* get the function name */

   exp_getvfname( expression, CURTASK exps[ CURTASK expsc ].string );

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in exp_function(): name is <%s>.",
      CURTASK exps[ CURTASK expsc ].string );
   bwb_debug( bwb_ebuf );
#endif

   /* now find the function itself */

   CURTASK exps[ CURTASK expsc ].function = fnc_find( CURTASK exps[ CURTASK expsc ].string );

   /* check to see if it is valid */

   if ( CURTASK exps[ CURTASK expsc ].function == NULL )
      {
#if PROG_ERRORS
      sprintf( bwb_ebuf, "Failed to find function <%s>.",
         CURTASK exps[ CURTASK expsc ].string );
      bwb_error( bwb_ebuf );
#else
      bwb_error( err_uf  );
#endif
      return OP_ERROR;
      }

   /* note that this level is a function */

   CURTASK exps[ CURTASK expsc ].operation = FUNCTION;
   CURTASK exps[ CURTASK expsc ].pos_adv = strlen( CURTASK exps[ CURTASK expsc ].string );

   /* check for begin parenthesis */

   loop = TRUE;
   while( loop == TRUE )
      {
      switch( expression[ CURTASK exps[ CURTASK expsc ].pos_adv ] )
         {

         case ' ':                              /* whitespace */
         case '\t':
            ++CURTASK exps[ CURTASK expsc ].pos_adv;        /* advance */
            break;

         case '(':                              /* begin paren */

#if INTENSIVE_DEBUG
            sprintf( bwb_ebuf, "in exp_function(): found begin parenthesis." );
            bwb_debug( bwb_ebuf );
#endif

            ++CURTASK exps[ CURTASK expsc ].pos_adv;        /* advance beyond it */
            paren_level = 1;                    /* set paren_level */
            loop = FALSE;                       /* and break out */
            break;

         default:                               /* anything else */
            loop = FALSE;
            paren_level = 0;                    /* do not look for arguments */
            break;
         }
      }

   /* find arguments within parentheses */
   /* for each argument, find a string ending with ',' or with end parenthesis */

   n_args = 0;
   s_pos = 0;
   CURTASK exps[ CURTASK expsc ].string[ 0 ] = '\0';

   while( paren_level > 0 )
      {

      /* check the current character */

      switch( expression[ CURTASK exps[ CURTASK expsc ].pos_adv ] )
         {

         case ',':                      /* end of an argument */

            if ( paren_level == 1 )     /* ignore ',' within parentheses */
               {

               /* call bwb_exp() recursively to resolve the argument */

               if ( exp_validarg( CURTASK exps[ CURTASK expsc ].string ) == TRUE )
                  {
#if INTENSIVE_DEBUG
		  sprintf( bwb_ebuf,
		     "in exp_function(): valid argument (not last)." );
                  bwb_debug( bwb_ebuf );
#endif

                  CURTASK exps[ CURTASK expsc ].rec_pos = 0;
                  e = bwb_exp( CURTASK exps[ CURTASK expsc ].string, FALSE,
                     &( CURTASK exps[ CURTASK expsc ].rec_pos ) );

                  /* assign operation and value at this level */

                  var_make( &( argv[ n_args ] ), e->type );

                  switch( argv[ n_args ].type )
                     {
                     case NUMBER:
                        * var_findnval( &( argv[ n_args ] ), argv[ n_args ].array_pos )
                            = exp_getnval( e );
                        break;
                     case STRING:
                        str_btob( var_findsval( &( argv[ n_args ] ),
                           argv[ n_args ].array_pos ), exp_getsval( e ) );
                        break;
                     }

                  ++n_args;                /* increment number of arguments */

                  }

               s_pos = 0;               /* reset counter */
               CURTASK exps[ CURTASK expsc ].string[ 0 ] = '\0';
               }

            else
               {
               CURTASK exps[ CURTASK expsc ].string[ s_pos ]
                  = expression[ CURTASK exps[ CURTASK expsc ].pos_adv ];
               ++s_pos;
               CURTASK exps[ CURTASK expsc ].string[ s_pos ] = '\0';
               }
            break;

         case '(':
            ++paren_level;
            CURTASK exps[ CURTASK expsc ].string[ s_pos ]
               = expression[ CURTASK exps[ CURTASK expsc ].pos_adv ];
            ++s_pos;
            CURTASK exps[ CURTASK expsc ].string[ s_pos ] = '\0';
            break;

         case ')':
            --paren_level;

#if INTENSIVE_DEBUG
            sprintf( bwb_ebuf,
               "in exp_function(): hit close parenthesis." );
            bwb_debug( bwb_ebuf );
#endif

            if ( paren_level == 0 )
               {

#if INTENSIVE_DEBUG
               sprintf( bwb_ebuf,
                  "in exp_function(): paren level 0." );
               bwb_debug( bwb_ebuf );
#endif

               /* call bwb_exp() recursively to resolve the argument */

               if ( exp_validarg( CURTASK exps[ CURTASK expsc ].string ) == TRUE )
                  {
#if INTENSIVE_DEBUG
		  sprintf( bwb_ebuf,
		     "in exp_function(): valid argument (last)." );
		  bwb_debug( bwb_ebuf );
#endif

                  CURTASK exps[ CURTASK expsc ].rec_pos = 0;
                  e = bwb_exp( CURTASK exps[ CURTASK expsc ].string, FALSE,
                     &( CURTASK exps[ CURTASK expsc ].rec_pos ) );

#if INTENSIVE_DEBUG
		  sprintf( bwb_ebuf,
		     "in exp_function(): return from bwb_exp(), last arg, type <%c> op <%d>",
		     e->type, e->operation );
		  bwb_debug( bwb_ebuf );
#endif

                  /* assign operation and value at this level */

                  var_make( &( argv[ n_args ] ), e->type );

                  switch( argv[ n_args ].type )
                     {
                     case NUMBER:
                        * var_findnval( &( argv[ n_args ] ), argv[ n_args ].array_pos )
                            = exp_getnval( e );
                        break;
                     case STRING:
                        str_btob( var_findsval( &( argv[ n_args ] ),
                           argv[ n_args ].array_pos ), exp_getsval( e ) );
                        break;
                     }

                  ++n_args;                /* increment number of arguments */

                  }

               s_pos = 0;               /* reset counter */
               CURTASK exps[ CURTASK expsc ].string[ 0 ] = '\0';
               }

            else
               {
               CURTASK exps[ CURTASK expsc ].string[ s_pos ]
                  = expression[ CURTASK exps[ CURTASK expsc ].pos_adv ];
               ++s_pos;
               CURTASK exps[ CURTASK expsc ].string[ s_pos ] = '\0';
               }
            break;

         case '\"':                             /* embedded string constant */

            /* add the initial quotation mark */

            CURTASK exps[ CURTASK expsc ].string[ s_pos ]
               = expression[ CURTASK exps[ CURTASK expsc ].pos_adv ];
            ++s_pos;
            CURTASK exps[ CURTASK expsc ].string[ s_pos ] = '\0';
            ++CURTASK exps[ CURTASK expsc ].pos_adv;

            /* add intervening characters */

            while ( ( expression[ CURTASK exps[ CURTASK expsc ].pos_adv ] != '\"' )
               && ( expression[ CURTASK exps[ CURTASK expsc ].pos_adv ] != '\0' ) )
               {
               CURTASK exps[ CURTASK expsc ].string[ s_pos ]
                  = expression[ CURTASK exps[ CURTASK expsc ].pos_adv ];
               ++s_pos;
               CURTASK exps[ CURTASK expsc ].string[ s_pos ] = '\0';
               ++CURTASK exps[ CURTASK expsc ].pos_adv;
               }

            /* add the concluding quotation mark */

            CURTASK exps[ CURTASK expsc ].string[ s_pos ]
               = expression[ CURTASK exps[ CURTASK expsc ].pos_adv ];
            ++s_pos;
            CURTASK exps[ CURTASK expsc ].string[ s_pos ] = '\0';
            /* the following bracketed out 14 July 1992; since this counter */
            /* incremented at the end of the switch statement, this may */
            /* increment it past the next character needed */
            /* ++CURTASK exps[ CURTASK expsc ].pos_adv; */
            break;

         default:
            CURTASK exps[ CURTASK expsc ].string[ s_pos ]
               = expression[ CURTASK exps[ CURTASK expsc ].pos_adv ];
            ++s_pos;
            CURTASK exps[ CURTASK expsc ].string[ s_pos ] = '\0';
#if INTENSIVE_DEBUG
            sprintf( bwb_ebuf, "in exp_function(): new char <%d>=<%c>",
               expression[ CURTASK exps[ CURTASK expsc ].pos_adv ],
               expression[ CURTASK exps[ CURTASK expsc ].pos_adv ] );
            bwb_debug( bwb_ebuf );
            sprintf( bwb_ebuf, "in exp_function(): building <%s>.",
               CURTASK exps[ CURTASK expsc ].string );
            bwb_debug( bwb_ebuf );
#endif
            break;
         }

      /* advance the counter */

      ++CURTASK exps[ CURTASK expsc ].pos_adv;

      }

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in exp_function(): ready to call function vector" );
   bwb_debug( bwb_ebuf );
#endif

   /* call the function vector */

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in exp_function(): calling preset function" );
   bwb_debug( bwb_ebuf );
#endif

   v = CURTASK exps[ CURTASK expsc ].function->vector ( n_args, &( argv[ 0 ] ),
      CURTASK exps[ CURTASK expsc ].function->id );

   /*-------------------------------------------------*/
   /* Now free the argv memory                        */
   /* (some other less fortunate routine may need it) */
   /* JBV, 10/95                                      */
   /*-------------------------------------------------*/

   /* First kleanup the joint (JBV) */
   for ( i = 0; i < n_args; ++i )
   {
       if ( argv[ i ].memnum != NULL )
       {
           /* Revised to FREE pass-thru call by JBV */
           FREE(argv[ i ].memnum, "exp_function");
           argv[ i ].memnum = NULL;
       }
       if ( argv[ i ].memstr != NULL )
       {
           /* Remember to deallocate those far-flung branches! (JBV) */
           for ( j = 0; j < (int) argv[ i ].array_units; ++j )
           {
               if ( argv[ i ].memstr[ j ].sbuffer != NULL )
               {
                   /* Revised to FREE pass-thru call by JBV */
                   FREE( argv[ i ].memstr[ j ].sbuffer, "exp_function" );
                   argv[ i ].memstr[ j ].sbuffer = NULL;
               }
               argv[ i ].memstr[ j ].rab = FALSE;
               argv[ i ].memstr[ j ].length = 0;
           }
           /* Revised to FREE pass-thru call by JBV */
           FREE( argv[ i ].memstr, "exp_function" );
           argv[ i ].memstr = NULL;
       }
       /* Revised to FREE pass-thru calls by JBV */
       if (argv[ i ].array_sizes != NULL)
       {
           FREE( argv[ i ].array_sizes, "exp_function" );
           argv[ i ].array_sizes = NULL; /* JBV */
       }
       if (argv[ i ].array_pos != NULL)
       {
           FREE( argv[ i ].array_pos, "exp_function" );
           argv[ i ].array_pos = NULL; /* JBV */
       }
   }

   FREE( argv, "exp_function" );

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in exp_function(): return from function vector, type <%c>",
      v->type );
   bwb_debug( bwb_ebuf );
#endif

   /* assign the value at this level */

   CURTASK exps[ CURTASK expsc ].type = (char) v->type;
   
   switch( v->type )
      {
      case STRING:
         CURTASK exps[ CURTASK expsc ].operation = CONST_STRING;

#if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in exp_function(): ready to assign STRING" );
         bwb_debug( bwb_ebuf );
#endif

         b = var_findsval( v, v->array_pos );
         str_btob( exp_getsval( &( CURTASK exps[ CURTASK expsc ] )), b );

#if INTENSIVE_DEBUG
         str_btoc( tbuf, b );
         sprintf( bwb_ebuf, "in exp_function(): string assigned <%s>", tbuf );
         bwb_debug( bwb_ebuf );
#endif

         break;

      default:
         CURTASK exps[ CURTASK expsc ].operation = NUMBER;
         CURTASK exps[ CURTASK expsc ].nval = var_getnval( v );
         break;
      }

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in exp_function(): end of function" );
   bwb_debug( bwb_ebuf );
#endif

   /* return */

   return TRUE;

   }

/***************************************************************

	FUNCTION:       exp_variable()

	DESCRIPTION:    This function interprets a variable.

***************************************************************/

#if ANSI_C
int
exp_variable( char *expression )
#else
int
exp_variable( expression )
   char *expression;
#endif
   {
   int pos;
   int *pp;
   int n_params;
   register int n;
   struct bwb_variable *v;
   bstring *b;
   int p;

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in exp_variable(): entered function." );
   bwb_debug( bwb_ebuf );
#endif

   /* get the variable name */

   exp_getvfname( expression, CURTASK exps[ CURTASK expsc ].string );

   /* now find the variable itself */

   v = CURTASK exps[ CURTASK expsc ].xvar = var_find( CURTASK exps[ CURTASK expsc ].string );

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in exp_variable(): level <%d>, found variable name <%s>",
      CURTASK expsc, CURTASK exps[ CURTASK expsc ].xvar->name );
   bwb_debug( bwb_ebuf );
#endif

   /* note that this level is a variable */

   CURTASK exps[ CURTASK expsc ].operation = VARIABLE;

   /* read subscripts */

   pos = strlen( CURTASK exps[ CURTASK expsc ].string );
   if ( ( v->dimensions == 1 ) && ( v->array_sizes[ 0 ] == 1 ))
      {
#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in exp_variable(): variable <%s> has 1 dimension",
         CURTASK exps[ CURTASK expsc ].xvar->name );
      bwb_debug( bwb_ebuf );
#endif
      pos = strlen( v->name );
      n_params = 1;
      pp = &p;
      pp[ 0 ] = dim_base;
      }
   else
      {
#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in exp_variable(): variable <%s> has > 1 dimensions",
         CURTASK exps[ CURTASK expsc ].xvar->name );
      bwb_debug( bwb_ebuf );
#endif
      dim_getparams( expression, &pos, &n_params, &pp );
      }

   CURTASK exps[ CURTASK expsc ].pos_adv = pos;
   for ( n = 0; n < v->dimensions; ++n )
      {
      CURTASK exps[ CURTASK expsc ].array_pos[ n ] = v->array_pos[ n ] = pp[ n ];
      }

#if INTENSIVE_DEBUG
   for ( n = 0; n < v->dimensions; ++ n )
      {
      sprintf( bwb_ebuf, "in exp_variable(): var <%s> array_pos element <%d> is <%d>.",
         v->name, n, v->array_pos[ n ] );
      bwb_debug( bwb_ebuf );
      }
#endif

   /* assign the type and value at this level */

   CURTASK exps[ CURTASK expsc ].type = (char) v->type;
   
   switch( v->type )
      {
      case STRING:
         b = var_findsval( v, v->array_pos );
#if TEST_BSTRING
         sprintf( bwb_ebuf, "in exp_variable(): b string name is <%s>",
            b->name );
         bwb_debug( bwb_ebuf );
#endif
#if OLDWAY
	 CURTASK exps[ CURTASK expsc ].sval.length = b->length;
	 CURTASK exps[ CURTASK expsc ].sval.sbuffer = b->sbuffer;
#endif
	 str_btob( &( CURTASK exps[ CURTASK expsc ].sval ), b );
         break;
      default:
         CURTASK exps[ CURTASK expsc ].nval = var_getnval( v );
         break;
      }

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in exp_variable(): exit, name <%s>, level <%d>, op <%d>",
      v->name, CURTASK expsc, CURTASK exps[ CURTASK expsc ].operation  );
   bwb_debug( bwb_ebuf );
#endif

   /* return */

   return TRUE;

   }
