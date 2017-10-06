/****************************************************************

        bwb_ops.c       Expression Parsing Operations
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

/* declarations for functions visible in this file only */

static int op_oplevel( int level );
static int op_add( int level, int precision );
static int op_subtract( int level, int precision );
static int op_multiply( int level, int precision );
static int op_divide( int level, int precision );
static int op_assign( int level, int precision );
static int op_equals( int level, int precision );
static int op_lessthan( int level, int precision );
static int op_greaterthan( int level, int precision );
static int op_lteq( int level, int precision );
static int op_gteq( int level, int precision );
static int op_notequal( int level, int precision );
static int op_modulus( int level, int precision );
static int op_exponent( int level, int precision );
static int op_intdiv( int level, int precision );
static int op_or( int level, int precision );
static int op_and( int level, int precision );
static int op_not( int level, int precision );
static int op_xor( int level, int precision );
static int op_islevelstr( int level );
static int op_getprecision( int level );
static int op_isoperator( int operation );
static int op_pulldown( int how_far );

static int op_level;

/***************************************************************

        FUNCTION:   exp_operation()

        DESCRIPTION:  This function performs whatever operations
        are necessary at the end of function bwb_exp.

***************************************************************/

int
exp_operation( int entry_level )
   {
   register int precedence;
   int operator;

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in exp_operation(): entered function." );
   bwb_debug( bwb_ebuf );
   #endif

   /* cycle through all levels of precedence and perform required
      operations */

   for ( precedence = 0; precedence <= MAX_PRECEDENCE; ++precedence )
      {

      /* Operation loop: cycle through every level above entry level
         and perform required operations as needed */

      op_level = entry_level + 1;
      while( ( op_level < exp_esc )
         && ( op_isoperator( exp_es[ op_level ].operation ) == FALSE ))
         {
         ++op_level;
         }

      while ( ( op_level > entry_level ) && ( op_level < exp_esc ) )
         {

         /* see if the operation at this level is an operator with the
            appropriate precedence level by running through the table
            of operators */

         for ( operator = 0; operator < N_OPERATORS; ++operator )
            {

            if ( exp_ops[ operator ].operation == exp_es[ op_level ].operation )
               {

               /* check for appropriate level of precedence */

               if ( exp_ops[ operator ].precedence == precedence )
                  {

                  #if INTENSIVE_DEBUG
                  sprintf( bwb_ebuf, "in exp_operation(): level <%d> operation <%d>",
                     op_level, exp_es[ op_level ].operation );
                  bwb_debug( bwb_ebuf );
                  #endif

                  op_oplevel( op_level );     /* perform the operation */

                  }
               }
            }

         /* advance level if appropriate; one must check, however, since
            the op_oplevel() function may have decremented exp_esc */

         if ( op_level < exp_esc )
            {
            ++op_level;

            #if INTENSIVE_DEBUG
            sprintf( bwb_ebuf, "in exp_operation() first increment op_level to <%d>",
               op_level );
            bwb_debug( bwb_ebuf );
            #endif

            while ( ( op_isoperator( exp_es [ op_level ].operation ) == FALSE )
               && ( op_level < exp_esc ) )
               {
               ++op_level;

               #if INTENSIVE_DEBUG
               sprintf( bwb_ebuf, "in exp_operation() further increment op_level to <%d>",
                  op_level );
               bwb_debug( bwb_ebuf );
               #endif

               }
            }                           /* end of increment of op_level */

         }                              /* end of for loop for stack levels */

      }                                 /* end of for loop for precedence levels */

   return TRUE;

   }                                    /* end of function exp_operation() */


/***************************************************************

        FUNCTION:   op_oplevel()

        DESCRIPTION:  This function performs a specific operation
        at a specific level.

***************************************************************/

int
op_oplevel( int level )
   {
   int precision;

   /* set the precision */

   if ( ( precision = op_getprecision( level ) ) == OP_ERROR )
      {
      #if PROG_ERRORS
      sprintf( bwb_ebuf, "exp_operation(): failed to set precision." );
      bwb_error( bwb_ebuf );
      #else
      bwb_error( err_mismatch );			/*** ??? ***/
      #endif
      op_pulldown( 2 );
      }

   /* precision is set correctly */

   else
      {
      #if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in op_oplevel(): level <%d>, precision <%c>",
         level, precision );
      bwb_debug( bwb_ebuf );
      #endif

      switch ( exp_es[ level ].operation )
         {
         case OP_ADD:
            op_add( level, precision );
            break;

         case OP_SUBTRACT:
            op_subtract( level, precision );
            break;

         case OP_MULTIPLY:
            op_multiply( level, precision );
            break;

         case OP_DIVIDE:
            op_divide( level, precision );
            break;

         case OP_ASSIGN:
            op_assign( level, precision );
            break;

         case OP_EQUALS:
            op_equals( level, precision );
            break;

         case OP_LESSTHAN:
            op_lessthan( level, precision );
            break;

         case OP_GREATERTHAN:
            op_greaterthan( level, precision );
            break;

         case OP_LTEQ:
            op_lteq( level, precision );
            break;

         case OP_GTEQ:
            op_gteq( level, precision );
            break;

         case OP_NOTEQUAL:
            op_notequal( level, precision );
            break;

         case OP_MODULUS:
            op_modulus( level, precision );
            break;

         case OP_INTDIVISION:
            op_intdiv( level, precision );
            break;

         case OP_OR:
            op_or( level, precision );
            break;

         case OP_AND:
            op_and( level, precision );
            break;

         case OP_NOT:
            op_not( level, precision );
            break;

         case OP_XOR:
            op_xor( level, precision );
            break;

         case OP_EXPONENT:
            op_exponent( level, precision );
            break;

         default:
            #if PROG_ERRORS
            sprintf( bwb_ebuf, "PROGRAMMING ERROR: operator <%d> not (yet) supported." );
            op_pulldown( 2 );
            bwb_error( bwb_ebuf );
            #else
            bwb_error( err_syntax );
            #endif
            break;
         }                              /* end of case statement for operators */
      }                                 /* end of else statement, precision set */

   return TRUE;

   }                                    /* end of function op_oplevel() */

/***************************************************************

        FUNCTION:   op_isoperator()

        DESCRIPTION:  This function detects whether its argument
        is an operator.

***************************************************************/

int
op_isoperator( int operation )
   {
   register int c;

   for( c = 0; c < N_OPERATORS; ++c )
      {
      if ( operation == exp_ops[ c ].operation )
         {

         #if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in op_isoperator(): found match <%s>",
            exp_ops[ c ].symbol );
         bwb_debug( bwb_ebuf );
         #endif

         return TRUE;
         }
      }

   /* test failed; return FALSE */

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in op_isoperator(): no match found for operation <%d>",
      operation );
   bwb_debug( bwb_ebuf );
   #endif

   return FALSE;

   }

/***************************************************************

        FUNCTION:   op_add()

        DESCRIPTION:  This function adds two numbers or
        concatenates two strings.

***************************************************************/

int
op_add( int level, int precision )
   {
   int error_condition;

   error_condition = FALSE;

   switch( precision )
      {
      case STRING:

         /* both sides of the operation should be strings for
            string addition; if not, report an error */

         if (  ( op_islevelstr( level - 1 ) != TRUE )
            || ( op_islevelstr( level + 1 ) != TRUE ) )
            {
            #if PROG_ERRORS
            sprintf( bwb_ebuf, "in op_add(): Type mismatch in string addition." );
            bwb_error( bwb_ebuf );
            #else
            bwb_error( err_mismatch );
            #endif
            error_condition = TRUE;
            }

         /* concatenate the two strings */

         if ( error_condition == FALSE )
            {

            #if INTENSIVE_DEBUG
            sprintf( bwb_ebuf, "in op_add(): try exp_getsval(), level <%d> op <%d> type <%c>:",
               level - 1, exp_es[ level - 1 ].operation, exp_es[ level - 1 ].type );
            bwb_debug( bwb_ebuf );
            exp_getsval( &( exp_es[ level - 1 ] ));
            sprintf( bwb_ebuf, "in op_add(): try exp_getsval(), level <%d> op <%d> type <%c>:",
               level + 1, exp_es[ level + 1 ].operation, exp_es[ level + 1 ].type );
            bwb_debug( bwb_ebuf );
            exp_getsval( &( exp_es[ level + 1 ] ));
            sprintf( bwb_ebuf, "in op_add(): string addition, exp_getsval()s completed" );
            bwb_debug( bwb_ebuf );
            #endif

            str_cat( exp_getsval( &( exp_es[ level - 1 ] ) ), 
               exp_getsval( &( exp_es[ level + 1 ] ) ) );
            }
         exp_es[ level - 1 ].operation = CONST_STRING;

         break;

      case DOUBLE:
         exp_es[ level - 1 ].dval
            = exp_getdval( &( exp_es[ level - 1 ] ))
            + exp_getdval( &( exp_es[ level + 1 ] ));
         exp_es[ level - 1 ].operation = NUMBER;
         break;

      case SINGLE:

         #if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in op_add(): single, (level <%d>) <%f> + <%f> (level <%d>",
            level - 1, exp_getfval( &( exp_es[ level - 1 ] )),
            exp_getfval( &( exp_es[ level + 1 ] )), level + 1 );
         bwb_debug( bwb_ebuf );
         #endif

         exp_es[ level - 1 ].fval
            = exp_getfval( &( exp_es[ level - 1 ] ))
            + exp_getfval( &( exp_es[ level + 1 ] ));

         #if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in op_add(): single, = <%f>",
            exp_es[ level - 1 ].fval );
         bwb_debug( bwb_ebuf );
         #endif

         exp_es[ level - 1 ].operation = NUMBER;
         break;

      case INTEGER:

         #if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in op_add(): Integer precision." );
         bwb_debug ( bwb_ebuf );
         sprintf( bwb_ebuf, "in op_add(): precisions: lhs <%d> rhs <%d>.",
            exp_es[ level - 1 ].type,
            exp_es[ level + 1 ].type );
         bwb_debug ( bwb_ebuf );
         #endif

         exp_es[ level - 1 ].ival
            = exp_getival( &( exp_es[ level - 1 ] ))
            + exp_getival( &( exp_es[ level + 1 ] ));

         #if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in op_add(): integer addition, result is <%d>",
            exp_es[ level - 1 ].ival );
         bwb_debug( bwb_ebuf );
         #endif

         exp_es[ level - 1 ].operation = NUMBER;
         break;
      }

   /* set variable to requested precision */

   exp_es[ level - 1 ].type = (char) precision;

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in op_add() returns with operation <%d> type <%c>",
      exp_es[ level - 1 ].operation, exp_es[ level - 1 ].type );
   bwb_debug( bwb_ebuf );
   #endif

   /* decrement the stack twice */

   op_pulldown( 2 );

   return TRUE;

   }

/***************************************************************

        FUNCTION:   op_subtract()

        DESCRIPTION:  This function subtracts the number on
        the left from the number on the right.


***************************************************************/

int
op_subtract( int level, int precision )
   {

   switch( precision )
      {
      case STRING:

         /* both sides of the operation should be numbers for
            string addition; if not, report an error */

         #if PROG_ERRORS
         sprintf( bwb_ebuf, "Strings cannot be subtracted." );
         bwb_error( bwb_ebuf );
         #else
         bwb_error( err_mismatch );
         #endif

         break;

      case DOUBLE:
         exp_es[ level - 1 ].dval
            = exp_getdval( &( exp_es[ level - 1 ] ))
            - exp_getdval( &( exp_es[ level + 1 ] ));
         break;

      case SINGLE:

         #if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in op_subtract(): Single precision." );
         bwb_debug ( bwb_ebuf );
         sprintf( bwb_ebuf, "in op_subtract(): precisions: lhs <%d> rhs <%d>.",
            exp_es[ level - 1 ].type,
            exp_es[ level + 1 ].type );
         bwb_debug ( bwb_ebuf );
         sprintf( bwb_ebuf, "in op_subtract(): values: lhs <%f> rhs <%f>.",
            exp_getfval( &( exp_es[ level - 1 ] )),
            exp_getfval( &( exp_es[ level + 1 ] )) );
         bwb_debug ( bwb_ebuf );
         #endif

         exp_es[ level - 1 ].fval
            = exp_getfval( &( exp_es[ level - 1 ] ))
            - exp_getfval( &( exp_es[ level + 1 ] ));

         #if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in op_subtract(): SINGLE subtraction, result is <%f>",
            exp_es[ level - 1 ].fval );
         bwb_debug( bwb_ebuf );
         #endif

         break;

      case INTEGER:

         #if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in op_subtract(): Integer precision." );
         bwb_debug ( bwb_ebuf );
         sprintf( bwb_ebuf, "in op_subtract(): precisions: lhs <%d> rhs <%d>.",
            exp_es[ level - 1 ].type,
            exp_es[ level + 1 ].type );
         bwb_debug ( bwb_ebuf );
         #endif

         exp_es[ level - 1 ].ival
            = exp_getival( &( exp_es[ level - 1 ] ))
            - exp_getival( &( exp_es[ level + 1 ] ));

         #if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in op_subtract(): integer subtraction, result is <%d>",
            exp_es[ level - 1 ].ival );
         bwb_debug( bwb_ebuf );
         #endif

         break;
      }

   /* set variable to requested precision */

   exp_es[ level - 1 ].type = (char) precision;
   exp_es[ level - 1 ].operation = NUMBER;

   /* decrement the stack twice */

   op_pulldown( 2 );

   return TRUE;

   }

/***************************************************************

        FUNCTION:   op_multiply()

        DESCRIPTION:  This function multiplies the number on
        the left from the number on the right.

***************************************************************/

int
op_multiply( int level, int precision )
   {

   switch( precision )
      {
      case STRING:

         /* both sides of the operation should be numbers for
            string addition; if not, report an error */

         #if PROG_ERRORS
         sprintf( bwb_ebuf, "Strings cannot be multiplied." );
         bwb_error( bwb_ebuf );
         #else
         bwb_error( err_mismatch );
         #endif

         break;

      case DOUBLE:
         exp_es[ level - 1 ].dval
            = exp_getdval( &( exp_es[ level - 1 ] ))
            * exp_getdval( &( exp_es[ level + 1 ] ));
         break;

      case SINGLE:
         exp_es[ level - 1 ].fval
            = exp_getfval( &( exp_es[ level - 1 ] ))
            * exp_getfval( &( exp_es[ level + 1 ] ));
         break;

      case INTEGER:
         exp_es[ level - 1 ].ival
            = exp_getival( &( exp_es[ level - 1 ] ))
            * exp_getival( &( exp_es[ level + 1 ] ));
         break;
      }

   /* set variable to requested precision */

   exp_es[ level - 1 ].type = (char) precision;
   exp_es[ level - 1 ].operation = NUMBER;

   /* decrement the stack twice */

   op_pulldown( 2 );

   return TRUE;

   }

/***************************************************************

        FUNCTION:   op_divide()

        DESCRIPTION:  This function divides the number on
        the left by the number on the right.

***************************************************************/

int
op_divide( int level, int precision )
   {

   switch( precision )
      {
      case STRING:

         /* both sides of the operation should be numbers for
            string addition; if not, report an error */

         #if PROG_ERRORS
         sprintf( bwb_ebuf, "Strings cannot be divided." );
         bwb_error( bwb_ebuf );
         #else
         bwb_error( err_mismatch );
         #endif

         break;

      case DOUBLE:
         if ( exp_getdval( &( exp_es[ level + 1 ] ))
            == 0.0 )
            {
            exp_es[ level - 1 ].dval = -1.0;
            op_pulldown( 2 );
            #if PROG_ERRORS
            sprintf( bwb_ebuf, "Divide by 0." );
            bwb_error( bwb_ebuf );
            #else
            bwb_error( err_dbz );
            #endif
            return FALSE;
            }
         exp_es[ level - 1 ].dval
            = exp_getdval( &( exp_es[ level - 1 ] ))
            / exp_getdval( &( exp_es[ level + 1 ] ));
         break;

      case SINGLE:
         if ( exp_getfval( &( exp_es[ level + 1 ] ))
            == (float) 0.0 )
            {
            exp_es[ level - 1 ].fval = (float) -1.0;
            op_pulldown( 2 );
            #if PROG_ERRORS
            sprintf( bwb_ebuf, "Divide by 0." );
            bwb_error( bwb_ebuf );
            #else
            bwb_error( err_dbz );
            #endif
            return FALSE;
            }
         exp_es[ level - 1 ].fval
            = exp_getfval( &( exp_es[ level - 1 ] ))
            / exp_getfval( &( exp_es[ level + 1 ] ));
         break;

      case INTEGER:
         if ( exp_getival( &( exp_es[ level + 1 ] ))
            == 0 )
            {
            exp_es[ level - 1 ].ival = -1;
            op_pulldown( 2 );
            #if PROG_ERRORS
            sprintf( bwb_ebuf, "Divide by 0." );
            bwb_error( bwb_ebuf );
            #else
            bwb_error( err_dbz );
            #endif
            return FALSE;
            }
         exp_es[ level - 1 ].ival
            = exp_getival( &( exp_es[ level - 1 ] ))
            / exp_getival( &( exp_es[ level + 1 ] ));
         break;
      }

   /* set variable to requested precision */

   exp_es[ level - 1 ].type = (char) precision;
   exp_es[ level - 1 ].operation = NUMBER;

   /* decrement the stack twice */

   op_pulldown( 2 );

   return TRUE;

   }

/***************************************************************

        FUNCTION:   op_assign()

        DESCRIPTION:  This function assigns the value in the
        right hand side to the variable in the left hand side.

***************************************************************/

int
op_assign( int level, int precision )
   {
   bstring *s, *d;

   /* Make sure the position one level below is a variable */

   if ( exp_es[ level - 1 ].operation != VARIABLE )
      {
      op_pulldown( 2 );
      #if PROG_ERRORS
      sprintf( bwb_ebuf, "in op_assign(): Assignment must be to variable: level -1 <%d> op <%d>",
         level - 1, exp_es[ level - 1 ].operation );
      bwb_error( bwb_ebuf );
      #else
      bwb_error( err_syntax );
      #endif
      return FALSE;
      }

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in op_assign(): entered function level <%d>",
      level );
   bwb_debug( bwb_ebuf );
   #endif

  /* if the assignment is numerical, then the precision should be set
     to that of the variable on the left-hand side of the assignment */

   if ( precision != STRING )
      {
      precision = (int) exp_es[ level - 1 ].type;
      }

   switch( precision )
      {
      case STRING:

         #if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in op_assign(): try exp_getsval(), level <%d> op <%d> type <%c>:",
            level - 1, exp_es[ level - 1 ].operation, exp_es[ level - 1 ].type );
         bwb_debug( bwb_ebuf );
         exp_getsval( &( exp_es[ level - 1 ] ));
         sprintf( bwb_ebuf, "in op_assign(): try exp_getsval(), level <%d> op <%d> type <%c>:",
            level + 1, exp_es[ level + 1 ].operation, exp_es[ level + 1 ].type );
         bwb_debug( bwb_ebuf );
         exp_getsval( &( exp_es[ level + 1 ] ));
         sprintf( bwb_ebuf, "in op_assign(): string addition, exp_getsval()s completed" );
         bwb_debug( bwb_ebuf );
         #endif

         str_btob( exp_getsval( &( exp_es[ level - 1 ] )),
                   exp_getsval( &( exp_es[ level + 1 ] )) );
         break;

      case DOUBLE:
         * var_finddval( exp_es[ level - 1 ].xvar, 
            exp_es[ level - 1 ].xvar->array_pos )  = 
            exp_es[ level - 1 ].dval = 
            exp_getdval( &( exp_es[ level + 1 ] ) );
         break;

      case SINGLE:
         * var_findfval( exp_es[ level - 1 ].xvar, 
            exp_es[ level - 1 ].xvar->array_pos )  = 
            exp_es[ level - 1 ].fval =
            exp_getfval( &( exp_es[ level + 1 ] ) );
         #if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in op_assign(): SINGLE assignment var <%s> val <%f>",
            exp_es[ level - 1 ].xvar->name, exp_getfval( &( exp_es[ level - 1 ] )) );
         bwb_debug( bwb_ebuf );
         #endif
         break;

      case INTEGER:
         * var_findival( exp_es[ level - 1 ].xvar, 
            exp_es[ level - 1 ].xvar->array_pos )  = 
            exp_es[ level - 1 ].ival =
            exp_getival( &( exp_es[ level + 1 ] ) );
         break;

      default:
         #if PROG_ERRORS
         sprintf( bwb_ebuf, "in op_assign(): Variable before assignment operator has unidentified type." );
         bwb_error( bwb_ebuf );
         #else
         bwb_error( err_mismatch );
         #endif
         return FALSE;

      }

   /* set variable to requested precision */

   exp_es[ level - 1 ].type = (char) precision;

   /* decrement the stack twice */

   op_pulldown( 2 );

   return TRUE;

   }

/***************************************************************

        FUNCTION:   op_equals()

        DESCRIPTION:  This function compares two values and
        returns an integer value: TRUE if they are the same
        and FALSE if they are not.

***************************************************************/

int
op_equals( int level, int precision )
   {
   int error_condition;
   bstring b;
   bstring *bp;

   error_condition = FALSE;
   b.rab = FALSE;

   switch( precision )
      {
      case STRING:

         /* both sides of the operation should be strings for
            string addition; if not, report an error */

         if (  ( op_islevelstr( level - 1 ) != TRUE )
            || ( op_islevelstr( level + 1 ) != TRUE ) )
            {
            #if PROG_ERRORS
            sprintf( bwb_ebuf, "in op_equals(): Type mismatch in string comparison." );
            bwb_error( bwb_ebuf );
            #else
            bwb_error( err_mismatch );
            #endif
            error_condition = TRUE;
            }

         /* compare the two strings */

         if ( error_condition == FALSE )
            {
            bp = exp_getsval( &( exp_es[ level - 1 ] ));
            b.length = bp->length;
            b.buffer = bp->buffer;
            if ( str_cmp( &b,
               exp_getsval( &( exp_es[ level + 1 ] )) ) == 0 )
               {
               exp_es[ level - 1 ].ival = TRUE;
               }
            else
               {
               exp_es[ level - 1 ].ival = FALSE;
               }
            }
         break;

      case DOUBLE:
         if ( exp_getdval( &( exp_es[ level - 1 ] ))
            == exp_getdval( &( exp_es[ level + 1 ] )) )
            {

            exp_es[ level - 1 ].ival = TRUE;
            }
         else
            {
            exp_es[ level - 1 ].ival = FALSE;
            }
         break;

      case SINGLE:
         if ( exp_getfval( &( exp_es[ level - 1 ] ))
            == exp_getfval( &( exp_es[ level + 1 ] )) )
            {
            exp_es[ level - 1 ].ival = TRUE;
            }
         else
            {
            exp_es[ level - 1 ].ival = FALSE;
            }
         break;

      case INTEGER:
         if ( exp_getival( &( exp_es[ level - 1 ] ))
            == exp_getival( &( exp_es[ level + 1 ] )) )
            {
            exp_es[ level - 1 ].ival = TRUE;
            }
         else
            {
            exp_es[ level - 1 ].ival = FALSE;
            }
         break;
      }

   /* set variable to integer and operation to NUMBER:
      this must be done at the end, since at the beginning it
      might cause op_islevelstr() to return a false error */

   exp_es[ level - 1 ].type = INTEGER;
   exp_es[ level - 1 ].operation = NUMBER;

   /* decrement the stack */

   op_pulldown( 2 );

   return TRUE;

   }

/***************************************************************

        FUNCTION:   op_lessthan()

        DESCRIPTION:  This function compares two values and
        returns an integer value: TRUE if the left hand value
        is less than the right, and FALSE if it is not.

***************************************************************/

int
op_lessthan( int level, int precision )
   {
   int error_condition;

   error_condition = FALSE;

   switch( precision )
      {
      case STRING:

         /* both sides of the operation should be numbers for
            string addition; if not, report an error */

         if (  ( op_islevelstr( level - 1 ) != TRUE )
            || ( op_islevelstr( level + 1 ) != TRUE ) )
            {
            #if PROG_ERRORS
            sprintf( bwb_ebuf, "Type mismatch in string comparison." );
            bwb_error( bwb_ebuf );
            #else
            bwb_error( err_mismatch );
            #endif
            error_condition = TRUE;
            }

         /* compare the two strings */

         if ( error_condition == FALSE )
            {
            if ( str_cmp( exp_getsval( &( exp_es[ level - 1 ] )),
               exp_getsval( &( exp_es[ level + 1 ] )) ) < 0 )
               {
               exp_es[ level - 1 ].ival = TRUE;
               }
            else
               {
               exp_es[ level - 1 ].ival = FALSE;
               }
            }
         break;

      case DOUBLE:
         if ( exp_getdval( &( exp_es[ level - 1 ] ))
            < exp_getdval( &( exp_es[ level + 1 ] )) )
            {
            exp_es[ level - 1 ].ival = TRUE;
            }
         else
            {
            exp_es[ level - 1 ].ival = FALSE;
            }
         break;

      case SINGLE:
         if ( exp_getfval( &( exp_es[ level - 1 ] ))
            < exp_getfval( &( exp_es[ level + 1 ] )) )
            {
            exp_es[ level - 1 ].ival = TRUE;
            }
         else
            {
            exp_es[ level - 1 ].ival = FALSE;
            }
         break;

      case INTEGER:
         if ( exp_getival( &( exp_es[ level - 1 ] ))
            < exp_getival( &( exp_es[ level + 1 ] )) )
            {

            exp_es[ level - 1 ].ival = TRUE;
            }
         else
            {
            exp_es[ level - 1 ].ival = FALSE;
            }
         break;
      }

   /* set variable to integer and operation to NUMBER:
      this must be done at the end, since at the beginning it
      might cause op_islevelstr() to return a false error */

   exp_es[ level - 1 ].type = INTEGER;
   exp_es[ level - 1 ].operation = NUMBER;

   /* decrement the stack */

   op_pulldown( 2 );

   return TRUE;

   }

/***************************************************************

        FUNCTION:   op_greaterthan()

        DESCRIPTION:  This function compares two values and
        returns an integer value: TRUE if the left hand value
        is greater than the right, and FALSE if it is not.

***************************************************************/

int
op_greaterthan( int level, int precision )
   {
   int error_condition;

   error_condition = FALSE;

   switch( precision )
      {
      case STRING:

         /* both sides of the operation should be numbers for
            string addition; if not, report an error */

         if (  ( op_islevelstr( level - 1 ) != TRUE )
            || ( op_islevelstr( level + 1 ) != TRUE ) )
            {
            #if PROG_ERRORS
            sprintf( bwb_ebuf, "Type mismatch in string comparison." );
            bwb_error( bwb_ebuf );
            #else
            bwb_error( err_mismatch );
            #endif
            error_condition = TRUE;
            }

         /* compare the two strings */

         if ( error_condition == FALSE )
            {
            if ( str_cmp( exp_getsval( &( exp_es[ level - 1 ] )),
               exp_getsval( &( exp_es[ level + 1 ] )) ) > 0 )
               {
               exp_es[ level - 1 ].ival = TRUE;
               }
            else
               {
               exp_es[ level - 1 ].ival = FALSE;
               }
            }
         break;

      case DOUBLE:
         if ( exp_getdval( &( exp_es[ level - 1 ] ))
            > exp_getdval( &( exp_es[ level + 1 ] )) )
            {
            exp_es[ level - 1 ].ival = TRUE;
            }
         else
            {
            exp_es[ level - 1 ].ival = FALSE;
            }
         break;

      case SINGLE:
         if ( exp_getfval( &( exp_es[ level - 1 ] ))
            > exp_getfval( &( exp_es[ level + 1 ] )) )
            {
            exp_es[ level - 1 ].ival = TRUE;
            }
         else
            {
            exp_es[ level - 1 ].ival = FALSE;
            }
         break;

      case INTEGER:
         if ( exp_getival( &( exp_es[ level - 1 ] ))
            > exp_getival( &( exp_es[ level + 1 ] )) )
            {
            exp_es[ level - 1 ].ival = TRUE;
            }
         else
            {
            exp_es[ level - 1 ].ival = FALSE;
            }
         break;
      }

   /* set variable to integer and operation to NUMBER:
      this must be done at the end, since at the beginning it
      might cause op_islevelstr() to return a false error */

   exp_es[ level - 1 ].type = INTEGER;
   exp_es[ level - 1 ].operation = NUMBER;

   /* decrement the stack */

   op_pulldown( 2 );

   return TRUE;

   }

/***************************************************************

        FUNCTION:   op_lteq()

        DESCRIPTION:  This function compares two values and
        returns an integer value: TRUE if the left hand value
        is less than or equal to the right, and FALSE if it is not.

***************************************************************/

int
op_lteq( int level, int precision )
   {
   int error_condition;

   error_condition = FALSE;

   switch( precision )
      {
      case STRING:

         /* both sides of the operation should be numbers for
            string addition; if not, report an error */

         if (  ( op_islevelstr( level - 1 ) != TRUE )
            || ( op_islevelstr( level + 1 ) != TRUE ) )
            {
            #if PROG_ERRORS
            sprintf( bwb_ebuf, "Type mismatch in string comparison." );
            bwb_error( bwb_ebuf );
            #else
            bwb_error( err_mismatch );
            #endif
            error_condition = TRUE;
            }

         /* compare the two strings */

         if ( error_condition == FALSE )
            {
            if ( str_cmp( exp_getsval( &( exp_es[ level - 1 ] )),
               exp_getsval( &( exp_es[ level + 1 ] )) ) <= 0 )
               {
               exp_es[ level - 1 ].ival = TRUE;
               }
            else
               {
               exp_es[ level - 1 ].ival = FALSE;
               }
            }
         break;

      case DOUBLE:
         if ( exp_getdval( &( exp_es[ level - 1 ] ))
            <= exp_getdval( &( exp_es[ level + 1 ] )) )
            {
            exp_es[ level - 1 ].ival = TRUE;
            }
         else
            {
            exp_es[ level - 1 ].ival = FALSE;
            }
         break;

      case SINGLE:

         if ( exp_getfval( &( exp_es[ level - 1 ] ))
            <= exp_getfval( &( exp_es[ level + 1 ] )) )
            {
            exp_es[ level - 1 ].ival = TRUE;
            }
         else
            {
            exp_es[ level - 1 ].ival = FALSE;
            }
         break;

      case INTEGER:
         if ( exp_getival( &( exp_es[ level - 1 ] ))
            <= exp_getival( &( exp_es[ level + 1 ] )) )
            {
            exp_es[ level - 1 ].ival = TRUE;
            }
         else
            {
            exp_es[ level - 1 ].ival = FALSE;
            }
         break;
      }

   /* set variable to integer and operation to NUMBER:
      this must be done at the end, since at the beginning it
      might cause op_islevelstr() to return a false error */

   exp_es[ level - 1 ].type = INTEGER;
   exp_es[ level - 1 ].operation = NUMBER;

   /* decrement the stack */

   op_pulldown( 2 );

   return TRUE;

   }

/***************************************************************

        FUNCTION:   op_gteq()

        DESCRIPTION:  This function compares two values and
        returns an integer value: TRUE if the left hand value
        is greater than or equal to the right, and FALSE if
        it is not.

***************************************************************/

int
op_gteq( int level, int precision )
   {
   int error_condition;

   error_condition = FALSE;

   switch( precision )
      {
      case STRING:

         /* both sides of the operation should be numbers for
            string addition; if not, report an error */

         if (  ( op_islevelstr( level - 1 ) != TRUE )
            || ( op_islevelstr( level + 1 ) != TRUE ) )
            {
            #if PROG_ERRORS
            sprintf( bwb_ebuf, "Type mismatch in string comparison." );
            bwb_error( bwb_ebuf );
            #else
            bwb_error( err_mismatch );
            #endif
            error_condition = TRUE;
            }

         /* compare the two strings */

         if ( error_condition == FALSE )
            {
            if ( str_cmp( exp_getsval( &( exp_es[ level - 1 ] )),
               exp_getsval( &( exp_es[ level + 1 ] )) ) >= 0 )
               {
               exp_es[ level - 1 ].ival = TRUE;
               }
            else
               {
               exp_es[ level - 1 ].ival = FALSE;
               }
            }
         break;

      case DOUBLE:
         if ( exp_getdval( &( exp_es[ level - 1 ] ))
            >= exp_getdval( &( exp_es[ level + 1 ] )) )
            {
            exp_es[ level - 1 ].ival = TRUE;
            }
         else
            {
            exp_es[ level - 1 ].ival = FALSE;
            }
         break;

      case SINGLE:
         if ( exp_getfval( &( exp_es[ level - 1 ] ))
            >= exp_getfval( &( exp_es[ level + 1 ] )) )
            {
            exp_es[ level - 1 ].ival = TRUE;
            }
         else
            {
            exp_es[ level - 1 ].ival = FALSE;
            }
         break;

      case INTEGER:
         if ( exp_getival( &( exp_es[ level - 1 ] ))
            >= exp_getival( &( exp_es[ level + 1 ] )) )
            {
            exp_es[ level - 1 ].ival = TRUE;
            }
         else
            {
            exp_es[ level - 1 ].ival = FALSE;
            }
         break;
      }

   /* set variable to integer and operation to NUMBER:
      this must be done at the end, since at the beginning it
      might cause op_islevelstr() to return a false error */

   exp_es[ level - 1 ].type = INTEGER;
   exp_es[ level - 1 ].operation = NUMBER;

   /* decrement the stack */

   op_pulldown( 2 );

   return TRUE;

   }

/***************************************************************

        FUNCTION:   op_notequal()

        DESCRIPTION:  This function compares two values and
        returns an integer value: TRUE if they are not the
        same and FALSE if they are.

***************************************************************/

int
op_notequal( int level, int precision )
   {
   int error_condition;

   error_condition = FALSE;

   switch( precision )
      {
      case STRING:

         /* both sides of the operation should be numbers for
            string addition; if not, report an error */

         if (  ( op_islevelstr( level - 1 ) != TRUE )
            || ( op_islevelstr( level + 1 ) != TRUE ) )
            {
            #if PROG_ERRORS
            sprintf( bwb_ebuf, "Type mismatch in string comparison." );
            bwb_error( bwb_ebuf );
            #else
            bwb_error( err_mismatch );
            #endif
            error_condition = TRUE;
            }

         /* compare the two strings */

         if ( error_condition == FALSE )

            {
            if ( str_cmp( exp_getsval( &( exp_es[ level - 1 ] )),
               exp_getsval( &( exp_es[ level + 1 ] )) ) != 0 )
               {
               exp_es[ level - 1 ].ival = TRUE;
               }
            else
               {
               exp_es[ level - 1 ].ival = FALSE;
               }
            }
         break;

      case DOUBLE:
         if ( exp_getdval( &( exp_es[ level - 1 ] ))
            != exp_getdval( &( exp_es[ level + 1 ] )) )
            {
            exp_es[ level - 1 ].ival = TRUE;
            }
         else
            {
            exp_es[ level - 1 ].ival = FALSE;
            }
         break;

      case SINGLE:
         if ( exp_getfval( &( exp_es[ level - 1 ] ))
            != exp_getfval( &( exp_es[ level + 1 ] )) )
            {
            exp_es[ level - 1 ].ival = TRUE;
            }
         else
            {
            exp_es[ level - 1 ].ival = FALSE;
            }
         break;

      case INTEGER:
         if ( exp_getival( &( exp_es[ level - 1 ] ))
            != exp_getival( &( exp_es[ level + 1 ] )) )
            {
            exp_es[ level - 1 ].ival = TRUE;
            }
         else
            {
            exp_es[ level - 1 ].ival = FALSE;
            }
         break;
      }

   /* set variable to integer and operation to NUMBER:
      this must be done at the end, since at the beginning it
      might cause op_islevelstr() to return a false error */

   exp_es[ level - 1 ].type = INTEGER;
   exp_es[ level - 1 ].operation = NUMBER;

   /* decrement the stack */

   op_pulldown( 2 );

   return TRUE;

   }

/***************************************************************

        FUNCTION:   op_modulus()

        DESCRIPTION:  This function divides the number on
        the left by the number on the right and return the
        remainder.

***************************************************************/

int
op_modulus( int level, int precision )
   {
   static double iportion;

   switch( precision )
      {
      case STRING:

         /* both sides of the operation should be numbers for
            string addition; if not, report an error */

         #if PROG_ERRORS
         sprintf( bwb_ebuf, "Strings cannot be divided." );
         bwb_error( bwb_ebuf );
         #else
         bwb_error( err_syntax );
         #endif

         break;

      case DOUBLE:
         if ( exp_getdval( &( exp_es[ level + 1 ] ))
            == 0.0 )
            {
            exp_es[ level - 1 ].dval = -1.0;
            op_pulldown( 2 );
            #if PROG_ERRORS
            sprintf( bwb_ebuf, "Divide by 0." );
            bwb_error( bwb_ebuf );
            #else
            bwb_error( err_dbz );
            #endif
            return FALSE;
            }
         exp_es[ level ].dval
            = exp_getdval( &( exp_es[ level - 1 ] ))
            / exp_getdval( &( exp_es[ level + 1 ] ));
         modf( exp_es[ level ].dval, &iportion );
         exp_es[ level - 1 ].dval
            = exp_getdval( &( exp_es[ level - 1 ] ))
            - ( exp_getdval( &( exp_es[ level + 1 ] ))
            * iportion );
         break;

      case SINGLE:
         if ( exp_getfval( &( exp_es[ level + 1 ] ))
            == (float) 0.0 )
            {
            exp_es[ level - 1 ].fval = (float) -1.0;
            op_pulldown( 2 );
            #if PROG_ERRORS
            sprintf( bwb_ebuf, "Divide by 0." );
            bwb_error( bwb_ebuf );
            #else
            bwb_error( err_dbz );
            #endif
            return FALSE;
            }
         exp_es[ level ].fval
            = exp_getfval( &( exp_es[ level - 1 ] ))
            / exp_getfval( &( exp_es[ level + 1 ] ));
         modf( (double) exp_es[ level ].fval, &iportion );

         #if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in op_modulus(): integer portion is %f",
            iportion );
         bwb_debug( bwb_ebuf );
         #endif

         exp_es[ level - 1 ].fval
            = exp_getfval( &( exp_es[ level - 1 ] ))
            - ( exp_getfval( &( exp_es[ level + 1 ] ))
            * (float) iportion );
         break;

      case INTEGER:
         if ( exp_getival( &( exp_es[ level + 1 ] ))
            == 0 )
            {
            exp_es[ level - 1 ].ival = -1;
            op_pulldown( 2 );

            #if PROG_ERRORS
            sprintf( bwb_ebuf, "Divide by 0." );
            bwb_error( bwb_ebuf );
            #else
            bwb_error( err_dbz );
            #endif
            return FALSE;
            }
         exp_es[ level - 1 ].ival
            = exp_getival( &( exp_es[ level - 1 ] ))
            % exp_getival( &( exp_es[ level + 1 ] ));
         break;
      }

   /* set variable to requested precision */

   exp_es[ level - 1 ].type = (char) precision;
   exp_es[ level - 1 ].operation = NUMBER;

   /* decrement the stack twice */

   op_pulldown( 2 );

   return TRUE;

   }

/***************************************************************

        FUNCTION:   op_exponent()

        DESCRIPTION:  This function divides the number on
        the left by the number on the right and return the
        remainder.

***************************************************************/

int
op_exponent( int level, int precision )
   {

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in op_exponent(): entered function level <%d>.",
      level );
   bwb_debug ( bwb_ebuf );
   #endif

   switch( precision )
      {
      case STRING:

         /* both sides of the operation should be numbers for
            string addition; if not, report an error */

         #if PROG_ERRORS
         sprintf( bwb_ebuf, "Strings cannot be taken as exponents." );
         bwb_error( bwb_ebuf );
         #else
         bwb_error( err_mismatch );
         #endif

         break;

      case DOUBLE:
         exp_es[ level - 1 ].dval
           = pow( exp_getdval( &( exp_es[ level - 1 ] )),
                  exp_getdval( &( exp_es[ level + 1 ] )) );
         break;

      case SINGLE:
         exp_es[ level - 1 ].fval
           = (float) pow( exp_getdval( &( exp_es[ level - 1 ] )),
                  exp_getdval( &( exp_es[ level + 1 ] )) );
         break;

      case INTEGER:

         #if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in op_exponent(): Integer precision." );
         bwb_debug ( bwb_ebuf );
         sprintf( bwb_ebuf, "in op_exponent(): lhs <%f> rhs <%f>.",
            exp_getdval( &( exp_es[ level - 1 ] )),
            exp_getdval( &( exp_es[ level + 1 ] )) );
         bwb_debug ( bwb_ebuf );
         #endif

         exp_es[ level - 1 ].ival
           = (int) pow( exp_getdval( &( exp_es[ level - 1 ] )),
                  exp_getdval( &( exp_es[ level + 1 ] )) );
         break;
      }

   /* set variable to requested precision */

   exp_es[ level - 1 ].type = (char) precision;
   exp_es[ level - 1 ].operation = NUMBER;

   /* decrement the stack twice */

   op_pulldown( 2 );

   return TRUE;

   }

/***************************************************************

        FUNCTION:   op_intdiv()

        DESCRIPTION:  This function divides the number on
        the left by the number on the right and returns the
        result as an integer.

***************************************************************/

int
op_intdiv( int level, int precision )
   {

   switch( precision )
      {
      case STRING:

         /* both sides of the operation should be numbers for
            string addition; if not, report an error */

         #if PROG_ERRORS
         sprintf( bwb_ebuf, "Strings cannot be divided." );
         bwb_error( bwb_ebuf );
         #else
         bwb_error( err_mismatch );
         #endif

         break;

      default:
         if ( exp_getival( &( exp_es[ level + 1 ] ))
            == 0 )
            {
            exp_es[ level - 1 ].ival = -1;
            op_pulldown( 2 );
            #if PROG_ERRORS
            sprintf( bwb_ebuf, "Divide by 0." );
            bwb_error( bwb_ebuf );
            #else
            bwb_error( err_dbz );
            #endif
            return FALSE;
            }

         #if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in op_intdiv(): <%d> / <%d>",
            exp_getival( &( exp_es[ level - 1 ] )),
            exp_getival( &( exp_es[ level + 1 ] )) );
         bwb_debug( bwb_ebuf );
         #endif

         exp_es[ level - 1 ].ival
            = exp_getival( &( exp_es[ level - 1 ] ))
            / exp_getival( &( exp_es[ level + 1 ] ));
         break;
      }

   /* set variable to requested precision */

   exp_es[ level - 1 ].type = INTEGER;
   exp_es[ level - 1 ].operation = NUMBER;

   /* decrement the stack twice */

   op_pulldown( 2 );

   return TRUE;

   }

/***************************************************************

        FUNCTION:   op_or()

        DESCRIPTION:  This function compares two integers and
        performs a logical NOT on them, returning the result
        as an integer.

***************************************************************/

int
op_or( int level, int precision )
   {

   switch( precision )
      {
      case STRING:

         /* both sides of the operation should be numbers for
            logical comparison; if not, report an error */

         #if PROG_ERRORS
         sprintf( bwb_ebuf, "Strings cannot be compared logically." );
         bwb_error( bwb_ebuf );
         #else
         bwb_error( err_mismatch );
         #endif

         break;

      case DOUBLE:
         exp_es[ level - 1 ].ival
            = exp_getival( &( exp_es[ level - 1 ] ))
            | exp_getival( &( exp_es[ level + 1 ] ));
         break;

      case SINGLE:
         exp_es[ level - 1 ].ival
            = exp_getival( &( exp_es[ level - 1 ] ))
            | exp_getival( &( exp_es[ level + 1 ] ));
         break;

      case INTEGER:
         exp_es[ level - 1 ].ival
            = exp_getival( &( exp_es[ level - 1 ] ))
            | exp_getival( &( exp_es[ level + 1 ] ));
         break;
      }

   /* set variable type to integer */

   exp_es[ level - 1 ].type = INTEGER;
   exp_es[ level - 1 ].operation = NUMBER;

   /* decrement the stack twice */

   op_pulldown( 2 );

   return TRUE;

   }

/***************************************************************

        FUNCTION:   op_and()

        DESCRIPTION:  This function compares two integers and
        performs a logical NOT on them, returning the result
        as an integer.

***************************************************************/

int
op_and( int level, int precision )
   {

   switch( precision )
      {
      case STRING:


         /* both sides of the operation should be numbers for
            logical comparison; if not, report an error */

         #if PROG_ERRORS
         sprintf( bwb_ebuf, "Strings cannot be compared logically." );
         bwb_error( bwb_ebuf );
         #else
         bwb_error( err_mismatch );
         #endif

         break;

      case DOUBLE:
         exp_es[ level - 1 ].ival
            = exp_getival( &( exp_es[ level - 1 ] ))
            & exp_getival( &( exp_es[ level + 1 ] ));
         break;

      case SINGLE:
         exp_es[ level - 1 ].ival
            = exp_getival( &( exp_es[ level - 1 ] ))
            & exp_getival( &( exp_es[ level + 1 ] ));
         break;

      case INTEGER:
         exp_es[ level - 1 ].ival
            = exp_getival( &( exp_es[ level - 1 ] ))
            & exp_getival( &( exp_es[ level + 1 ] ));
         break;
      }

   /* set variable type to integer */

   exp_es[ level - 1 ].type = INTEGER;
   exp_es[ level - 1 ].operation = NUMBER;

   /* decrement the stack twice */

   op_pulldown( 2 );

   return TRUE;

   }

/***************************************************************

        FUNCTION:   op_not()

        DESCRIPTION:  This function compares two integers and
        performs a logical NOT on them, returning the result
        as an integer.

***************************************************************/

int
op_not( int level, int precision )
   {
   unsigned char r;

   switch( precision )
      {
      case STRING:


         /* both sides of the operation should be numbers for
            logical comparison; if not, report an error */

         #if PROG_ERRORS
         sprintf( bwb_ebuf, "Strings cannot be compared logically." );
         bwb_error( bwb_ebuf );
         #else
         bwb_error( err_mismatch );
         #endif

         break;

      default:

         #if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in op_not(): argument is <%d>, precision <%c>",
            (unsigned int) exp_getival( &( exp_es[ level + 1 ] )), precision );
         bwb_debug( bwb_ebuf );
         #endif

         exp_es[ level ].ival =
            ~( exp_getival( &( exp_es[ level + 1 ] )) );

         #if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in op_not(): result is <%d>, precision <%c>",
            (int) r, precision );
         bwb_debug( bwb_ebuf );
         #endif

         break;
      }

   /* set variable type to integer */

   exp_es[ level ].type = INTEGER;
   exp_es[ level ].operation = NUMBER;

   /* decrement the stack once */

   op_pulldown( 1 );

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in op_not(): exp_esc <%d>, level <%d> result <%d>",
      exp_esc, level, exp_es[ exp_esc ].ival );
   bwb_debug( bwb_ebuf );
   #endif

   return TRUE;

   }

/***************************************************************

        FUNCTION:   op_xor()

        DESCRIPTION:  This function compares two integers and
        performs a logical NOT on them, returning the result
        as an integer.

***************************************************************/

int
op_xor( int level, int precision )
   {

   switch( precision )
      {
      case STRING:

         /* both sides of the operation should be numbers for
            logical comparison; if not, report an error */

         #if PROG_ERRORS
         sprintf( bwb_ebuf, "Strings cannot be compared logically." );
         bwb_error( bwb_ebuf );
         #else
         bwb_error( err_mismatch );
         #endif

         break;

      case DOUBLE:
         exp_es[ level - 1 ].ival
            = exp_getival( &( exp_es[ level - 1 ] ))
            ^ exp_getival( &( exp_es[ level + 1 ] ));
         break;

      case SINGLE:
         exp_es[ level - 1 ].ival
            = exp_getival( &( exp_es[ level - 1 ] ))
            ^ exp_getival( &( exp_es[ level + 1 ] ));
         break;

      case INTEGER:
         exp_es[ level - 1 ].ival   
            = exp_getival( &( exp_es[ level - 1 ] ))
            ^ exp_getival( &( exp_es[ level + 1 ] ));
         break;
      }

   /* set variable type to integer */

   exp_es[ level - 1 ].type = INTEGER;
   exp_es[ level - 1 ].operation = NUMBER;

   /* decrement the stack twice */

   op_pulldown( 2 );

   return TRUE;

   }

/***************************************************************

        FUNCTION:   op_islevelstr()

        DESCRIPTION:  This function determines whether the
        operation at a specified level involves a string
        constant or variable.

***************************************************************/

int
op_islevelstr( int level )
   {

   /* first see if the level holds a string constant */

   if ( exp_es[ level ].operation == CONST_STRING )
      {

      #if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in op_islevelstr(): string detected at level <%d>.",
         level );
      bwb_debug( bwb_ebuf );
      #endif

      return TRUE;
      }

   /* see if the level holds a string variable */

   if ( exp_es[ level ].operation == VARIABLE )
      {
      if ( exp_es[ level ].xvar->type == STRING )
         {

         #if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in op_islevelstr(): string detected at level <%d>.",
            level );
         bwb_debug( bwb_ebuf );
         #endif

         return TRUE;
         }
      }

   /* test has failed, return FALSE */

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in op_islevelstr(): string not detected at level <%d>.",
      level );
   bwb_debug( bwb_ebuf );
   #endif

   return FALSE;

   }

/***************************************************************

        FUNCTION:   op_getprecision()

        DESCRIPTION:  This function finds the precision for
        an operation by comparing the precision at this level
        and that two levels below.

***************************************************************/

int
op_getprecision( int level )
   {

   /* first test for string value */

   if (  ( exp_es[ level + 1 ].type == STRING )
      || ( exp_es[ level - 1 ].type == STRING ) )
      {
      return STRING;
      }

   /* Both are numbers, so we should be able to find a suitable
      precision level by starting with the top and moving down;
      check first for double precision */

   if (  ( exp_es[ level + 1 ].type == DOUBLE )
      || ( exp_es[ level - 1 ].type == DOUBLE ) )
      {
      return DOUBLE;
      }

   /* check next for single precision */

   if (  ( exp_es[ level + 1 ].type == SINGLE )
      || ( exp_es[ level - 1 ].type == SINGLE ) )
      {
      return SINGLE;
      }

   /* test integer precision */

   if (  ( exp_es[ level + 1 ].type == INTEGER )
      && ( exp_es[ level - 1 ].type == INTEGER ) )
      {
      return INTEGER;
      }

   /* else error */

   #if PROG_ERRORS
   sprintf( bwb_ebuf, "in op_getprecision(): invalid precision level." );
   bwb_error( bwb_ebuf );
   #else
   bwb_error( err_syntax );
   #endif

   return FALSE;

   }

/***************************************************************

        FUNCTION:   op_pulldown()

        DESCRIPTION:  This function pulls the expression stack
        down a specified number of levels, decrementing the
        expression stack counter (bycalling dec_esc()) and
        decrementing the current "level" of operation processing.

***************************************************************/

int
op_pulldown( int how_far )
   {
   int level;
   register int c;

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in op_pulldown(): pull down e stack <%d> place(s)",
      how_far );
   bwb_debug( bwb_ebuf );
   #endif

   /* first pull down the actual variables themselves */

   level = op_level + ( 2 - how_far );
   while ( exp_esc >= ( level + how_far ) )
      {

      memcpy( &exp_es[ level ], &exp_es[ level + how_far ],
         (size_t) ( sizeof( struct exp_ese )) );
      ++level;

      }

   /* decrement the expression stack counter */

   for ( c = 0; c < how_far; ++c )
      {

      if ( dec_esc() == TRUE )
         {
         --op_level;
         }
      else
         {
         return FALSE;
         }

      }

   return TRUE;

   }

