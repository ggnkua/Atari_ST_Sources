/****************************************************************

        bwb_elx.c       Parse Elements of Expressions
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
#include <string.h>
#include <ctype.h>
#include <math.h>

#include "bwbasic.h"
#include "bwb_mes.h"

/***************************************************************

        FUNCTION:   exp_paren()

        DESCRIPTION:  This function interprets a parenthetical
        expression, calling bwb_exp() (recursively) to resolve
        the internal expression.

***************************************************************/

int
exp_paren( char *expression )
   {
   struct exp_ese *e;
   register int c;
   int s_pos;                           /* position in build buffer */
   int loop;
   int paren_level;

   /* find a string enclosed by parentheses */

   exp_es[ exp_esc ].pos_adv = 1;       /* start beyond open paren */
   s_pos = 0;
   loop = TRUE;
   paren_level = 1;
   exp_es[ exp_esc ].string[ 0 ] = '\0';

   while( loop == TRUE )
      {

      /* check the current character */

      switch( expression[ exp_es[ exp_esc ].pos_adv ] )
         {

         case '(':
            ++paren_level;
            exp_es[ exp_esc ].string[ s_pos ]
               = expression[ exp_es[ exp_esc ].pos_adv ];
            ++s_pos;
            exp_es[ exp_esc ].string[ s_pos ] = '\0';
            break;

         case ')':

            --paren_level;
            if ( paren_level == 0 )
               {
               loop = FALSE;
               }
            else
               {
               exp_es[ exp_esc ].string[ s_pos ]
                  = expression[ exp_es[ exp_esc ].pos_adv ];
               ++s_pos;
               exp_es[ exp_esc ].string[ s_pos ] = '\0';
               }
            break;

         case '\"':                             /* embedded string constant */
            ++exp_es[ exp_esc ].pos_adv;
            while ( ( expression[ exp_es[ exp_esc ].pos_adv ] != '\"' )
               && ( expression[ exp_es[ exp_esc ].pos_adv ] != '\0' ) )
               {
               exp_es[ exp_esc ].string[ s_pos ]
                  = expression[ exp_es[ exp_esc ].pos_adv ];
               ++s_pos;
               exp_es[ exp_esc ].string[ s_pos ] = '\0';
               ++exp_es[ exp_esc ].pos_adv;
               }
            break;

         default:
            exp_es[ exp_esc ].string[ s_pos ]
               = expression[ exp_es[ exp_esc ].pos_adv ];
            ++s_pos;
            exp_es[ exp_esc ].string[ s_pos ] = '\0';
            break;
         }

      /* advance the counter */

      ++exp_es[ exp_esc ].pos_adv;

      }

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in exp_paren() found internal string <%s>",
      exp_es[ exp_esc ].string );
   bwb_debug( bwb_ebuf );
   #endif

   /* call bwb_exp() recursively to interpret this expression */

   exp_es[ exp_esc ].rec_pos = 0;
   e = bwb_exp( exp_es[ exp_esc ].string, FALSE,
          &( exp_es[ exp_esc ].rec_pos ) );

   /* assign operation and value at this level */

   exp_es[ exp_esc ].type = e->type;

   switch ( e->type )
      {
      case STRING:
         exp_es[ exp_esc ].operation = CONST_STRING;
         str_btob( exp_getsval( &( exp_es[ exp_esc ] )), exp_getsval( e ) );
         break;
      case INTEGER:
         exp_es[ exp_esc ].operation = NUMBER;
         exp_es[ exp_esc ].ival = exp_getival( e );
         break;
      case DOUBLE:
         exp_es[ exp_esc ].operation = NUMBER;
         exp_es[ exp_esc ].dval = exp_getdval( e );
         break;
      default:
         exp_es[ exp_esc ].operation = NUMBER;
         exp_es[ exp_esc ].fval = exp_getfval( e );
         break;
      }

   return TRUE;

   }

/***************************************************************

        FUNCTION:   exp_strconst()

        DESCRIPTION:  This function interprets a string
        constant.

***************************************************************/

int
exp_strconst( char *expression )
   {
   int e_pos, s_pos;

   /* assign values to structure */

   exp_es[ exp_esc ].type = STRING;
   exp_es[ exp_esc ].operation = CONST_STRING;

   /* set counters */

   s_pos = 0;
   exp_es[ exp_esc ].pos_adv = e_pos = 1;
   exp_es[ exp_esc ].string[ 0 ] = '\0';

   /* read the string up until the next double quotation mark */

   while( expression[ e_pos ] != '\"' )
      {
      exp_es[ exp_esc ].string[ s_pos ] = expression[ e_pos ];
      ++e_pos;
      ++s_pos;
      ++exp_es[ exp_esc ].pos_adv;
      exp_es[ exp_esc ].string[ s_pos ] = '\0';
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

   str_ctob( &( exp_es[ exp_esc ].sval ), exp_es[ exp_esc ].string );

   /* advance past last double quotation mark */

   ++exp_es[ exp_esc ].pos_adv;

   /* return */

   return TRUE;

   }

/***************************************************************

        FUNCTION:   exp_numconst()

        DESCRIPTION:  This function interprets a numerical
        constant.

***************************************************************/

int
exp_numconst( char *expression )
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
   double d;
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
      var_make( &mantissa, DOUBLE );
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
   exp_es[ exp_esc ].ival = 0;

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

         exp_es[ exp_esc ].pos_adv = man_start;
         exp_es[ exp_esc ].type = INTEGER;
         exp_es[ exp_esc ].string[ 0 ] = '\0';
         s_pos = 0;
         exponent = OP_NULL;
         build_loop = TRUE;

         /* loop to build the string */

         while ( build_loop == TRUE )
            {
            switch( expression[ exp_es[ exp_esc ].pos_adv ] )
               {
               case '-':                        /* prefixed plus or minus */
               case '+':

                  /* in the first position, a plus or minus sign can
                     be added to the beginning of the string to be
                     scanned */

                  if ( exp_es[ exp_esc ].pos_adv == man_start )
                     {
                     exp_es[ exp_esc ].string[ s_pos ] = expression[ exp_es[ exp_esc ].pos_adv ];
                     ++exp_es[ exp_esc ].pos_adv;  /* advance to next character */
                     ++s_pos;
                     exp_es[ exp_esc ].string[ s_pos ] = '\0';
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
                  if ( exp_es[ exp_esc ].type == INTEGER )
                     {
                     exp_es[ exp_esc ].type = SINGLE;
                     }                          /* fall through (no break) */
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
                  exp_es[ exp_esc ].string[ s_pos ] = expression[ exp_es[ exp_esc ].pos_adv ];
                  ++exp_es[ exp_esc ].pos_adv;  /* advance to next character */
                  ++s_pos;
                  exp_es[ exp_esc ].string[ s_pos ] = '\0';
                  break;

               case 'E':                        /* exponential, single precision */
               case 'e':
                  ++exp_es[ exp_esc ].pos_adv;  /* advance to next character */
                  exp_es[ exp_esc ].type = SINGLE;
		  exponent = TRUE;
                  build_loop = FALSE;
                  break;


               case 'D':                        /* exponential, double precision */
               case 'd':
                  ++exp_es[ exp_esc ].pos_adv;  /* advance to next character */
                  exp_es[ exp_esc ].type = DOUBLE;
		  exponent = TRUE;
                  build_loop = FALSE;
                  break;

               case SINGLE:                     /* single precision termination */
                  ++exp_es[ exp_esc ].pos_adv;  /* advance to next character */
                  exp_es[ exp_esc ].type = SINGLE;
                  build_loop = FALSE;
                  break;

               case DOUBLE:                     /* double precision termination */
                  ++exp_es[ exp_esc ].pos_adv;  /* advance to next character */
                  exp_es[ exp_esc ].type = DOUBLE;
                  build_loop = FALSE;
                  break;

               case INTEGER:                    /* integer precision termination */
                  ++exp_es[ exp_esc ].pos_adv;  /* advance to next character */
                  exp_es[ exp_esc ].type = INTEGER;
                  build_loop = FALSE;
                  break;

               default:                         /* anything else, terminate */
                  build_loop = FALSE;
                  break;
               }

            }

         /* assign the value to the mantissa variable */
         
         sscanf( exp_es[ exp_esc ].string, "%lf", 
           var_finddval( &mantissa, mantissa.array_pos ));

         #if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in exp_numconst(): read mantissa, string <%s> val <%lf>",
            exp_es[ exp_esc ].string, var_getdval( &mantissa ) );
         bwb_debug( bwb_ebuf );
         #endif

         /* test if integer bounds have been exceeded */

         if ( exp_es[ exp_esc ].type == INTEGER )
            {
            i = (int) var_getdval( &mantissa );
            d = (double) i;
            if ( d != var_getdval( &mantissa ))
               {
               exp_es[ exp_esc ].type = DOUBLE;
               #if INTENSIVE_DEBUG
               sprintf( bwb_ebuf, "in exp_numconst(): integer bounds violated, promote to DOUBLE" );
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

            exp_es[ exp_esc ].string[ 0 ] = '\0';
            s_pos = 0;
            build_loop = TRUE;

            /* loop to build the string */

            while ( build_loop == TRUE )
               {
               switch( expression[ exp_es[ exp_esc ].pos_adv ] )
                  {
		  case '-':                        /* prefixed plus or minus */
                  case '+':

		     if ( need_pm == TRUE )        /* only allow once */
			{
			exp_es[ exp_esc ].string[ s_pos ] = expression[ exp_es[ exp_esc ].pos_adv ];
			++exp_es[ exp_esc ].pos_adv;  /* advance to next character */
			++s_pos;
			exp_es[ exp_esc ].string[ s_pos ] = '\0';
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

                     exp_es[ exp_esc ].string[ s_pos ] = expression[ exp_es[ exp_esc ].pos_adv ];
                     ++exp_es[ exp_esc ].pos_adv;  /* advance to next character */
                     ++s_pos;
		     exp_es[ exp_esc ].string[ s_pos ] = '\0';
		     need_pm = FALSE;
                     break;

                  default:                         /* anything else, terminate */
                     build_loop = FALSE;
                     break;
                  }

               }                                /* end of build loop for exponent */

            /* assign the value to the user variable */

            sscanf( exp_es[ exp_esc ].string, "%d",
               &( exp_es[ exp_esc ].ival ) );

	    #if INTENSIVE_DEBUG
	    sprintf( bwb_ebuf, "in exp_numconst(): exponent is <%d>",
               exp_es[ exp_esc ].ival );
            bwb_debug( bwb_ebuf );
            #endif

            }                           /* end of exponent search */

         if ( exp_es[ exp_esc ].ival == 0 )
            {
            exp_es[ exp_esc ].dval = var_getdval( &mantissa );
            }
         else
            {
            exp_es[ exp_esc ].dval = var_getdval( &mantissa )
               * pow( (double) 10.0, (double) exp_es[ exp_esc ].ival );
            }

         exp_es[ exp_esc ].fval = (float) exp_es[ exp_esc ].dval;
         exp_es[ exp_esc ].ival = (int) exp_es[ exp_esc ].dval;

         #if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in exp_numconst(): val double <%lf> single <%f> int <%d>",
            exp_es[ exp_esc ].dval, exp_es[ exp_esc ].fval, exp_es[ exp_esc ].ival );
         bwb_debug( bwb_ebuf );
         #endif

         break;

      case 8:                           /* octal constant */

         /* initialize counters */

         exp_es[ exp_esc ].pos_adv = man_start;
         exp_es[ exp_esc ].type = INTEGER;
         exp_es[ exp_esc ].string[ 0 ] = '\0';
         s_pos = 0;
         exponent = OP_NULL;
         build_loop = TRUE;

         /* loop to build the string */

         while ( build_loop == TRUE )
            {
            switch( expression[ exp_es[ exp_esc ].pos_adv ] )
               {
               case '0':                        /* or ordinary digit */
               case '1':
               case '2':
               case '3':
               case '4':
               case '5':
               case '6':
               case '7':
                  exp_es[ exp_esc ].string[ s_pos ] = expression[ exp_es[ exp_esc ].pos_adv ];
                  ++exp_es[ exp_esc ].pos_adv;  /* advance to next character */
                  ++s_pos;
                  exp_es[ exp_esc ].string[ s_pos ] = '\0';
                  break;

               default:                         /* anything else, terminate */
                  build_loop = FALSE;
                  break;
               }

            }

         /* now scan the string to determine the number */

         sscanf( exp_es[ exp_esc ].string, "%o",
            &( exp_es[ exp_esc ].ival ));

         break;

      case 16:                          /* hexadecimal constant */

         /* initialize counters */

         exp_es[ exp_esc ].pos_adv = man_start;
         exp_es[ exp_esc ].type = INTEGER;
         exp_es[ exp_esc ].string[ 0 ] = '\0';
         s_pos = 0;
         exponent = OP_NULL;
         build_loop = TRUE;

         /* loop to build the string */

         while ( build_loop == TRUE )
            {
            switch( expression[ exp_es[ exp_esc ].pos_adv ] )
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
                  exp_es[ exp_esc ].string[ s_pos ] = expression[ exp_es[ exp_esc ].pos_adv ];

                  ++exp_es[ exp_esc ].pos_adv;  /* advance to next character */
                  ++s_pos;
                  exp_es[ exp_esc ].string[ s_pos ] = '\0';
                  break;

               default:                         /* anything else, terminate */
                  build_loop = FALSE;
                  break;
               }

            }

         /* now scan the string to determine the number */

         sscanf( exp_es[ exp_esc ].string, "%x",
            &( exp_es[ exp_esc ].ival ));

         break;
      }

   /* note that the operation at this level is now a determined NUMBER */

   exp_es[ exp_esc ].operation = NUMBER;

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in exp_numconst(): exit level <%d> precision <%c> value <%lf>",
      exp_esc, exp_es[ exp_esc ].type, exp_getdval( &( exp_es[ exp_esc ] ) ) );
   bwb_debug( bwb_ebuf );
   #endif

   #if CHECK_RECURSION
   in_use = FALSE;
   #endif

   return TRUE;

   }

/***************************************************************

        FUNCTION:   exp_function()

        DESCRIPTION:  This function interprets a function,
        calling bwb_exp() (recursively) to resolve any
        arguments to the function.

***************************************************************/

int
exp_function( char *expression )
   {
   struct exp_ese *e;
   register int c;
   int s_pos;                           /* position in build buffer */
   int loop;
   int paren_level;
   int n_args;
   struct bwb_variable *v;
   struct bwb_variable argv[ MAX_FARGS ];
   bstring *b;
   #if INTENSIVE_DEBUG
   char tbuf[ MAXSTRINGSIZE + 1 ];

   sprintf( bwb_ebuf, "in exp_function(): entered function, expression <%s>",
      expression );
   bwb_debug( bwb_ebuf );
   #endif

   /* assign pointers to argument stack */

   /* get the function name */

   exp_getvfname( expression, exp_es[ exp_esc ].string );

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in exp_function(): name is <%s>.",
      exp_es[ exp_esc ].string );
   bwb_debug( bwb_ebuf );
   #endif

   /* now find the function itself */

   exp_es[ exp_esc ].function = fnc_find( exp_es[ exp_esc ].string );

   /* check to see if it is valid */

   if ( exp_es[ exp_esc ].function == NULL )
      {
      #if PROG_ERRORS
      sprintf( bwb_ebuf, "Failed to find function <%s>.",
         exp_es[ exp_esc ].string );
      bwb_error( bwb_ebuf );
      #else
      bwb_error( err_uf  );
      #endif
      return OP_ERROR;
      }

   /* note that this level is a function */

   exp_es[ exp_esc ].operation = FUNCTION;
   exp_es[ exp_esc ].pos_adv = strlen( exp_es[ exp_esc ].string );

   /* check for begin parenthesis */

   loop = TRUE;
   while( loop == TRUE )
      {
      switch( expression[ exp_es[ exp_esc ].pos_adv ] )
         {

         case ' ':                              /* whitespace */
         case '\t':
            ++exp_es[ exp_esc ].pos_adv;        /* advance */
            break;

         case '(':                              /* begin paren */

            #if INTENSIVE_DEBUG
            sprintf( bwb_ebuf, "in exp_function(): found begin parenthesis." );
            bwb_debug( bwb_ebuf );
            #endif

            ++exp_es[ exp_esc ].pos_adv;        /* advance beyond it */
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
   exp_es[ exp_esc ].string[ 0 ] = '\0';

   while( paren_level > 0 )
      {

      /* check the current character */

      switch( expression[ exp_es[ exp_esc ].pos_adv ] )
         {

         case ',':                      /* end of an argument */

            if ( paren_level == 1 )     /* ignore ',' within parentheses */
               {

               /* call bwb_exp() recursively to resolve the argument */

               if ( exp_validarg( exp_es[ exp_esc ].string ) == TRUE )
                  {
		  #if INTENSIVE_DEBUG
		  sprintf( bwb_ebuf,
		     "in exp_function(): valid argument (not last)." );
                  bwb_debug( bwb_ebuf );
                  #endif

                  exp_es[ exp_esc ].rec_pos = 0;
                  e = bwb_exp( exp_es[ exp_esc ].string, FALSE,
                     &( exp_es[ exp_esc ].rec_pos ) );

                  /* assign operation and value at this level */

                  var_make( &( argv[ n_args ] ), e->type );

                  switch( argv[ n_args ].type )
                     {
                     case DOUBLE:
                        * var_finddval( &( argv[ n_args ] ), argv[ n_args ].array_pos )
                            = exp_getdval( e );
                        break;
                     case SINGLE:
                        * var_findfval( &( argv[ n_args ] ), argv[ n_args ].array_pos )
                            = exp_getfval( e );
                        break;
                     case INTEGER:
                        * var_findival( &( argv[ n_args ] ), argv[ n_args ].array_pos )
                            = exp_getival( e );
                        break;
                     case STRING:
                        str_btob( var_findsval( &( argv[ n_args ] ),
                           argv[ n_args ].array_pos ), exp_getsval( e ) );
                        break;
                     }

                  ++n_args;                /* increment number of arguments */

                  }

               s_pos = 0;               /* reset counter */
               exp_es[ exp_esc ].string[ 0 ] = '\0';
               }

            else
               {
               exp_es[ exp_esc ].string[ s_pos ]
                  = expression[ exp_es[ exp_esc ].pos_adv ];
               ++s_pos;
               exp_es[ exp_esc ].string[ s_pos ] = '\0';
               }
            break;

         case '(':
            ++paren_level;
            exp_es[ exp_esc ].string[ s_pos ]
               = expression[ exp_es[ exp_esc ].pos_adv ];
            ++s_pos;
            exp_es[ exp_esc ].string[ s_pos ] = '\0';
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

               if ( exp_validarg( exp_es[ exp_esc ].string ) == TRUE )
                  {
		  #if INTENSIVE_DEBUG
		  sprintf( bwb_ebuf,
		     "in exp_function(): valid argument (last)." );
		  bwb_debug( bwb_ebuf );
		  #endif

                  exp_es[ exp_esc ].rec_pos = 0;
                  e = bwb_exp( exp_es[ exp_esc ].string, FALSE,
                     &( exp_es[ exp_esc ].rec_pos ) );

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
                     case DOUBLE:
                        * var_finddval( &( argv[ n_args ] ), argv[ n_args ].array_pos )
                            = exp_getdval( e );
                        break;
                     case SINGLE:
                        * var_findfval( &( argv[ n_args ] ), argv[ n_args ].array_pos )
                            = exp_getfval( e );
                        break;
                     case INTEGER:
                        * var_findival( &( argv[ n_args ] ), argv[ n_args ].array_pos )
                            = exp_getival( e );
                        break;
                     case STRING:
                        str_btob( var_findsval( &( argv[ n_args ] ),
                           argv[ n_args ].array_pos ), exp_getsval( e ) );
                        break;
                     }

                  ++n_args;                /* increment number of arguments */

                  }

               s_pos = 0;               /* reset counter */
               exp_es[ exp_esc ].string[ 0 ] = '\0';
               }

            else
               {
               exp_es[ exp_esc ].string[ s_pos ]
                  = expression[ exp_es[ exp_esc ].pos_adv ];
               ++s_pos;
               exp_es[ exp_esc ].string[ s_pos ] = '\0';
               }
            break;

         case '\"':                             /* embedded string constant */

            /* add the initial quotation mark */

            exp_es[ exp_esc ].string[ s_pos ]
               = expression[ exp_es[ exp_esc ].pos_adv ];
            ++s_pos;
            exp_es[ exp_esc ].string[ s_pos ] = '\0';
            ++exp_es[ exp_esc ].pos_adv;

            /* add intervening characters */

            while ( ( expression[ exp_es[ exp_esc ].pos_adv ] != '\"' )
               && ( expression[ exp_es[ exp_esc ].pos_adv ] != '\0' ) )
               {
               exp_es[ exp_esc ].string[ s_pos ]
                  = expression[ exp_es[ exp_esc ].pos_adv ];
               ++s_pos;
               exp_es[ exp_esc ].string[ s_pos ] = '\0';
               ++exp_es[ exp_esc ].pos_adv;
               }

            /* add the concluding quotation mark */

            exp_es[ exp_esc ].string[ s_pos ]
               = expression[ exp_es[ exp_esc ].pos_adv ];
            ++s_pos;
            exp_es[ exp_esc ].string[ s_pos ] = '\0';
            /* the following bracketed out 14 July 1992; since this counter */
            /* incremented at the end of the switch statement, this may */
            /* increment it past the next character needed */
            /* ++exp_es[ exp_esc ].pos_adv; */
            break;

         default:
            exp_es[ exp_esc ].string[ s_pos ]
               = expression[ exp_es[ exp_esc ].pos_adv ];
            ++s_pos;
            exp_es[ exp_esc ].string[ s_pos ] = '\0';
            #if INTENSIVE_DEBUG
            sprintf( bwb_ebuf, "in exp_function(): new char <%d>=<%c>",
               expression[ exp_es[ exp_esc ].pos_adv ],
               expression[ exp_es[ exp_esc ].pos_adv ] );
            bwb_debug( bwb_ebuf );
            sprintf( bwb_ebuf, "in exp_function(): building <%s>.",
               exp_es[ exp_esc ].string );
            bwb_debug( bwb_ebuf );
            #endif
            break;
         }

      /* advance the counter */

      ++exp_es[ exp_esc ].pos_adv;

      }

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in exp_function(): ready to call function vector" );
   bwb_debug( bwb_ebuf );
   #endif

   /* call the function vector */

   if ( exp_es[ exp_esc ].function->ufnc != NULL )
      {
      #if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in exp_function(): calling fnc_intufnc()" );
      bwb_debug( bwb_ebuf );
      #endif
      v = fnc_intufnc( n_args, &( argv[ 0 ] ), exp_es[ exp_esc ].function );
      }
   else
      {
      #if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in exp_function(): calling preset function" );
      bwb_debug( bwb_ebuf );
      #endif
      v = exp_es[ exp_esc ].function->vector ( n_args, &( argv[ 0 ] ) );
      }

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in exp_function(): return from function vector, type <%c>",
      v->type );
   bwb_debug( bwb_ebuf );
   #endif

   /* assign the value at this level */

   exp_es[ exp_esc ].type = (char) v->type;
   
   switch( v->type )
      {
      case STRING:
         exp_es[ exp_esc ].operation = CONST_STRING;

         #if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in exp_function(): ready to assign STRING" );
         bwb_debug( bwb_ebuf );
         #endif

         b = var_findsval( v, v->array_pos );
         str_btob( exp_getsval( &( exp_es[ exp_esc ] )), b );

         #if INTENSIVE_DEBUG
         str_btoc( tbuf, b );
         sprintf( bwb_ebuf, "in exp_function(): string assigned <%s>", tbuf );
         bwb_debug( bwb_ebuf );
         #endif

         break;

      case DOUBLE:
         exp_es[ exp_esc ].operation = NUMBER;
         exp_es[ exp_esc ].dval = var_getdval( v );
         break;
      case INTEGER:
         exp_es[ exp_esc ].operation = NUMBER;
         exp_es[ exp_esc ].ival = var_getival( v );
         break;
      default:
         exp_es[ exp_esc ].operation = NUMBER;
         exp_es[ exp_esc ].fval = var_getfval( v );
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

        FUNCTION:   exp_variable()

        DESCRIPTION:  This function interprets a variable.

***************************************************************/

int
exp_variable( char *expression )
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

   exp_getvfname( expression, exp_es[ exp_esc ].string );

   /* now find the variable itself */

   v = exp_es[ exp_esc ].xvar = var_find( exp_es[ exp_esc ].string );

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in exp_variable(): level <%d>, found variable name <%s>",
      exp_esc, exp_es[ exp_esc ].xvar->name );
   bwb_debug( bwb_ebuf );
   #endif

   /* note that this level is a variable */

   exp_es[ exp_esc ].operation = VARIABLE;

   /* read subscripts */

   pos = strlen( exp_es[ exp_esc ].string );
   if ( ( v->dimensions == 1 ) && ( v->array_sizes[ 0 ] == 1 ))
      {
      #if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in exp_variable(): variable <%s> has 1 dimension",
         exp_es[ exp_esc ].xvar->name );
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
         exp_es[ exp_esc ].xvar->name );
      bwb_debug( bwb_ebuf );
      #endif
      dim_getparams( expression, &pos, &n_params, &pp );
      }

   exp_es[ exp_esc ].pos_adv = pos;
   for ( n = 0; n < v->dimensions; ++n )
      {
      exp_es[ exp_esc ].array_pos[ n ] = v->array_pos[ n ] = pp[ n ];
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

   exp_es[ exp_esc ].type = (char) v->type;
   
   switch( v->type )
      {
      case STRING:
         b = var_findsval( v, v->array_pos );
         #if TEST_BSTRING
         sprintf( bwb_ebuf, "in exp_variable(): b string name is <%s>",
            b->name );
         bwb_debug( bwb_ebuf );
         #endif
         exp_es[ exp_esc ].sval.length = b->length;
         exp_es[ exp_esc ].sval.buffer = b->buffer;
         break;
      case DOUBLE:
         exp_es[ exp_esc ].dval = var_getdval( v );
         break;
      case INTEGER:
         exp_es[ exp_esc ].ival = var_getival( v );
         break;
      default:
         exp_es[ exp_esc ].fval = var_getfval( v );
         break;
      }

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in exp_variable(): exit, name <%s>, level <%d>, op <%d>",
      v->name, exp_esc, exp_es[ exp_esc ].operation  );
   bwb_debug( bwb_ebuf );
   #endif

   /* return */

   return TRUE;

   }


