/****************************************************************

        bwb_ops.c       Expression Parsing Operations
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

#include "bwbasic.h"
#include "bwb_mes.h"

/* declarations for functions visible in this file only */

#if ANSI_C
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
static int op_negation( int level, int precision ); /* JBV */
static int op_islevelstr( int level );
static int op_getprecision( int level );
static int op_isoperator( int operation );
static int op_pulldown( int how_far );
#else
static int op_oplevel();
static int op_add();
static int op_subtract();
static int op_multiply();
static int op_divide();
static int op_assign();
static int op_equals();
static int op_lessthan();
static int op_greaterthan();
static int op_lteq();
static int op_gteq();
static int op_notequal();
static int op_modulus();
static int op_exponent();
static int op_intdiv();
static int op_or();
static int op_and();
static int op_not();
static int op_xor();
static int op_negation(); /* JBV */
static int op_islevelstr();
static int op_getprecision();
static int op_isoperator();
static int op_pulldown();
#endif				/* ANSI_C for prototypes */

static int op_level;

/***************************************************************

	FUNCTION:       exp_operation()

	DESCRIPTION:    This function performs whatever operations
			are necessary at the end of function bwb_exp()
			(i.e., the end of the parsing of an expression;
			see file bwb_exp.c).

***************************************************************/

#if ANSI_C
int
exp_operation( int entry_level )
#else
int
exp_operation( entry_level )
   int entry_level;
#endif
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
      while( ( op_level < CURTASK expsc )
         && ( op_isoperator( CURTASK exps[ op_level ].operation ) == FALSE ))
         {
         ++op_level;
         }

      while ( ( op_level > entry_level ) && ( op_level < CURTASK expsc ) )
         {

         /* see if the operation at this level is an operator with the
            appropriate precedence level by running through the table
            of operators */

         for ( operator = 0; operator < N_OPERATORS; ++operator )
            {

            if ( exp_ops[ operator ].operation == CURTASK exps[ op_level ].operation )
               {

               /* check for appropriate level of precedence */

               if ( exp_ops[ operator ].precedence == precedence )
                  {

#if INTENSIVE_DEBUG
                  sprintf( bwb_ebuf, "in exp_operation(): level <%d> operation <%d>",
                     op_level, CURTASK exps[ op_level ].operation );
                  bwb_debug( bwb_ebuf );
#endif

                  op_oplevel( op_level );     /* perform the operation */

                  }
               }
            }

         /* advance level if appropriate; one must check, however, since
            the op_oplevel() function may have decremented CURTASK expsc */

         if ( op_level < CURTASK expsc )
            {
            ++op_level;

#if INTENSIVE_DEBUG
            sprintf( bwb_ebuf, "in exp_operation() first increment op_level to <%d>",
               op_level );
            bwb_debug( bwb_ebuf );
#endif

            while ( ( op_isoperator( CURTASK exps [ op_level ].operation ) == FALSE )
               && ( op_level < CURTASK expsc ) )
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

	FUNCTION:       op_oplevel()

	DESCRIPTION:    This function performs a specific operation
			at a specific level as the expression parser
			resolves its arguments.

***************************************************************/

#if ANSI_C
static int
op_oplevel( int level )
#else
static int
op_oplevel( level )
   int level;
#endif
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

      switch ( CURTASK exps[ level ].operation )
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

         case OP_NEGATION: /* JBV */
            op_negation( level, precision );
            break;

         default:
#if PROG_ERRORS
            sprintf( bwb_ebuf, "PROGRAMMING ERROR: operator <%d> not (yet) supported.", CURTASK exps[ level ].operation );
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

	FUNCTION:       op_isoperator()

	DESCRIPTION:    This function detects whether its argument
			is an operator.

***************************************************************/

#if ANSI_C
static int
op_isoperator( int operation )
#else
static int
op_isoperator( operation )
   int operation;
#endif
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

        FUNCTION:   	op_add()

        DESCRIPTION:  	This function adds two numbers or
        		concatenates two strings.

***************************************************************/

#if ANSI_C
static int
op_add( int level, int precision )
#else
static int
op_add( level, precision )
   int level;
   int precision;
#endif
   {
   int error_condition;
   static bstring b; /* JBV */

   error_condition = FALSE;
   b.rab = FALSE; /* JBV */

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
               level - 1, CURTASK exps[ level - 1 ].operation, CURTASK exps[ level - 1 ].type );
            bwb_debug( bwb_ebuf );
            exp_getsval( &( CURTASK exps[ level - 1 ] ));
            sprintf( bwb_ebuf, "in op_add(): try exp_getsval(), level <%d> op <%d> type <%c>:",
               level + 1, CURTASK exps[ level + 1 ].operation, CURTASK exps[ level + 1 ].type );
            bwb_debug( bwb_ebuf );
            exp_getsval( &( CURTASK exps[ level + 1 ] ));
            sprintf( bwb_ebuf, "in op_add(): string addition, exp_getsval()s completed" );
            bwb_debug( bwb_ebuf );
#endif

            /* Removed by JBV (incomplete, modifies wrong string variable!) */
            /* str_cat( exp_getsval( &( CURTASK exps[ level - 1 ] ) ), 
               exp_getsval( &( CURTASK exps[ level + 1 ] ) ) ); */

            /* Added by JBV */
            str_btob( &b, exp_getsval( &( CURTASK exps[ level - 1 ] ) ) );
            str_cat( &b, exp_getsval( &( CURTASK exps[ level + 1 ] ) ) );
            str_btob( &( CURTASK exps[ level - 1 ].sval ), &b );
            CURTASK exps[ level - 1 ].operation = CONST_STRING;

#if INTENSIVE_DEBUG
            sprintf( bwb_ebuf, "in op_add(): str_cat() returns <%d>-byte string to level <%d>",
               exp_getsval( &( CURTASK exps[ level - 1 ] ) )->length, level - 1 );
            bwb_debug( bwb_ebuf );
#endif
            }

         break;

      case NUMBER:
         CURTASK exps[ level - 1 ].nval
            = exp_getnval( &( CURTASK exps[ level - 1 ] ))
            + exp_getnval( &( CURTASK exps[ level + 1 ] ));
         CURTASK exps[ level - 1 ].operation = NUMBER;
         break;

      }

   /* set variable to requested precision */

   CURTASK exps[ level - 1 ].type = (char) precision;

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in op_add() returns with operation <%d> type <%c>",
      CURTASK exps[ level - 1 ].operation, CURTASK exps[ level - 1 ].type );
   bwb_debug( bwb_ebuf );
#endif

   /* decrement the stack twice */

   op_pulldown( 2 );

   return TRUE;

   }

/***************************************************************

	FUNCTION:       op_subtract()

	DESCRIPTION:    This function subtracts the number on
			the left from the number on the right.

***************************************************************/

#if ANSI_C
static int
op_subtract( int level, int precision )
#else
static int
op_subtract( level, precision )
   int level;
   int precision;
#endif
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

      case NUMBER:
         CURTASK exps[ level - 1 ].nval
            = exp_getnval( &( CURTASK exps[ level - 1 ] ))
            - exp_getnval( &( CURTASK exps[ level + 1 ] ));
         break;

      }

   /* set variable to requested precision */

   CURTASK exps[ level - 1 ].type = (char) precision;
   CURTASK exps[ level - 1 ].operation = NUMBER;

   /* decrement the stack twice */

   op_pulldown( 2 );

   return TRUE;

   }

/***************************************************************

	FUNCTION:       op_multiply()

	DESCRIPTION:    This function multiplies the number on
			the left by the number on the right.

***************************************************************/

#if ANSI_C
static int
op_multiply( int level, int precision )
#else
static int
op_multiply( level, precision )
   int level;
   int precision;
#endif
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

      case NUMBER:
         CURTASK exps[ level - 1 ].nval
            = exp_getnval( &( CURTASK exps[ level - 1 ] ))
            * exp_getnval( &( CURTASK exps[ level + 1 ] ));
         break;

      }

   /* set variable to requested precision */

   CURTASK exps[ level - 1 ].type = (char) precision;
   CURTASK exps[ level - 1 ].operation = NUMBER;

   /* decrement the stack twice */

   op_pulldown( 2 );

   return TRUE;

   }

/***************************************************************

	FUNCTION:       op_divide()

	DESCRIPTION:    This function divides the number on
			the left by the number on the right.

***************************************************************/

#if ANSI_C
static int
op_divide( int level, int precision )
#else
static int
op_divide( level, precision )
   int level;
   int precision;
#endif
   {

   switch( precision )
      {
      case STRING:

         /* both sides of the operation should be numbers for
            division; if not, report an error */

#if PROG_ERRORS
         sprintf( bwb_ebuf, "Strings cannot be divided." );
         bwb_error( bwb_ebuf );
#else
         bwb_error( err_mismatch );
#endif

         break;

      case NUMBER:
         if ( exp_getnval( &( CURTASK exps[ level + 1 ] ))
            == (bnumber) 0 )
            {
            CURTASK exps[ level - 1 ].nval = (bnumber) -1.0;
            op_pulldown( 2 );
#if PROG_ERRORS
            sprintf( bwb_ebuf, "Divide by 0." );
            bwb_error( bwb_ebuf );
#else
            bwb_error( err_dbz );
#endif
            return FALSE;
            }
         CURTASK exps[ level - 1 ].nval
            = exp_getnval( &( CURTASK exps[ level - 1 ] ))
            / exp_getnval( &( CURTASK exps[ level + 1 ] ));
         break;
      }

   /* set variable to requested precision */

   CURTASK exps[ level - 1 ].type = (char) precision;
   CURTASK exps[ level - 1 ].operation = NUMBER;

   /* decrement the stack twice */

   op_pulldown( 2 );

   return TRUE;

   }

/***************************************************************

	FUNCTION:       op_assign()

	DESCRIPTION:    This function assigns the value in the
			right hand side to the variable in the
			left hand side.

***************************************************************/

#if ANSI_C
static int
op_assign( int level, int precision )
#else
static int
op_assign( level, precision )
   int level;
   int precision;
#endif
   {

   /* Make sure the position one level below is a variable */

   if ( CURTASK exps[ level - 1 ].operation != VARIABLE )
      {
      op_pulldown( 2 );
#if PROG_ERRORS
      sprintf( bwb_ebuf, "in op_assign(): Assignment must be to variable: level -1 <%d> op <%d>",
         level - 1, CURTASK exps[ level - 1 ].operation );
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
      precision = (int) CURTASK exps[ level - 1 ].type;
      }

   switch( precision )
      {
      case STRING:

#if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in op_assign(): try exp_getsval(), level <%d> op <%d> type <%c>:",
            level - 1, CURTASK exps[ level - 1 ].operation, CURTASK exps[ level - 1 ].type );
         bwb_debug( bwb_ebuf );
         exp_getsval( &( CURTASK exps[ level - 1 ] ));
         sprintf( bwb_ebuf, "in op_assign(): try exp_getsval(), level <%d> op <%d> type <%c>:",
            level + 1, CURTASK exps[ level + 1 ].operation, CURTASK exps[ level + 1 ].type );
         bwb_debug( bwb_ebuf );
         exp_getsval( &( CURTASK exps[ level + 1 ] ));
         sprintf( bwb_ebuf, "in op_assign(): string addition, exp_getsval()s completed" );
         bwb_debug( bwb_ebuf );
#endif

         str_btob( exp_getsval( &( CURTASK exps[ level - 1 ] )),
                   exp_getsval( &( CURTASK exps[ level + 1 ] )) );
         break;

      case NUMBER:
         * var_findnval( CURTASK exps[ level - 1 ].xvar, 
            CURTASK exps[ level - 1 ].array_pos ) =
            CURTASK exps[ level - 1 ].nval = 
            exp_getnval( &( CURTASK exps[ level + 1 ] ) );
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

   CURTASK exps[ level - 1 ].type = (char) precision;

   /* decrement the stack twice */

   op_pulldown( 2 );

   return TRUE;

   }

/***************************************************************

	FUNCTION:       op_equals()

	DESCRIPTION:    This function compares two values and
			returns an integer value: TRUE if they are
			the same and FALSE if they are not.

***************************************************************/

#if ANSI_C
static int
op_equals( int level, int precision )
#else
static int
op_equals( level, precision )
   int level;
   int precision;
#endif
   {
   int error_condition;
   static bstring b;
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
            bp = exp_getsval( &( CURTASK exps[ level - 1 ] ));
#if OLDWAY
	    b.length = bp->length;
	    b.sbuffer = bp->sbuffer;
#endif
	    str_btob( &b, bp );

            if ( str_cmp( &b,
               exp_getsval( &( CURTASK exps[ level + 1 ] )) ) == 0 )
               {
               CURTASK exps[ level - 1 ].nval = (bnumber) TRUE;
               }
            else
               {
               CURTASK exps[ level - 1 ].nval = (bnumber) FALSE;
               }
            }
         break;

      case NUMBER:
         if ( exp_getnval( &( CURTASK exps[ level - 1 ] ))
            == exp_getnval( &( CURTASK exps[ level + 1 ] )) )
            {
            CURTASK exps[ level - 1 ].nval = (bnumber) TRUE;
            }
         else
            {
            CURTASK exps[ level - 1 ].nval = (bnumber) FALSE;
            }
         break;

      }

   /* set variable to integer and operation to NUMBER:
      this must be done at the end, since at the beginning it
      might cause op_islevelstr() to return a false error */

   CURTASK exps[ level - 1 ].type = NUMBER;
   CURTASK exps[ level - 1 ].operation = NUMBER;

   /* decrement the stack */

   op_pulldown( 2 );

   return TRUE;

   }

/***************************************************************

	FUNCTION:       op_lessthan()

	DESCRIPTION:    This function compares two values and
			returns an integer value: TRUE if the
			left hand value is less than the right,
			and FALSE if it is not.

***************************************************************/

#if ANSI_C
static int
op_lessthan( int level, int precision )
#else
static int
op_lessthan( level, precision )
   int level;
   int precision;
#endif
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
            if ( str_cmp( exp_getsval( &( CURTASK exps[ level - 1 ] )),
               exp_getsval( &( CURTASK exps[ level + 1 ] )) ) < 0 )
               {
               CURTASK exps[ level - 1 ].nval = (bnumber) TRUE;
               }
            else
               {
               CURTASK exps[ level - 1 ].nval = (bnumber) FALSE;
               }
            }
         break;

      case NUMBER:
         if ( exp_getnval( &( CURTASK exps[ level - 1 ] ))
            < exp_getnval( &( CURTASK exps[ level + 1 ] )) )
            {
            CURTASK exps[ level - 1 ].nval = (bnumber) TRUE;
            }
         else
            {
            CURTASK exps[ level - 1 ].nval = (bnumber) FALSE;
            }
         break;

      }

   /* set variable to integer and operation to NUMBER:
      this must be done at the end, since at the beginning it
      might cause op_islevelstr() to return a false error */

   CURTASK exps[ level - 1 ].type = NUMBER;
   CURTASK exps[ level - 1 ].operation = NUMBER;

   /* decrement the stack */

   op_pulldown( 2 );

   return TRUE;

   }

/***************************************************************

	FUNCTION:       op_greaterthan()

	DESCRIPTION:    This function compares two values and
			returns an integer value: TRUE if the
			left hand value is greater than the right,
			and FALSE if it is not.

***************************************************************/

#if ANSI_C
static int
op_greaterthan( int level, int precision )
#else
static int
op_greaterthan( level, precision )
   int level;
   int precision;
#endif
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
            if ( str_cmp( exp_getsval( &( CURTASK exps[ level - 1 ] )),
               exp_getsval( &( CURTASK exps[ level + 1 ] )) ) > 0 )
               {
               CURTASK exps[ level - 1 ].nval = (bnumber) TRUE;
               }
            else
               {
               CURTASK exps[ level - 1 ].nval = (bnumber) FALSE;
               }
            }
         break;

      case NUMBER:
         if ( exp_getnval( &( CURTASK exps[ level - 1 ] ))
            > exp_getnval( &( CURTASK exps[ level + 1 ] )) )
            {
            CURTASK exps[ level - 1 ].nval = (bnumber) TRUE;
            }
         else
            {
            CURTASK exps[ level - 1 ].nval = (bnumber) FALSE;
            }
         break;

      }

   /* set variable to integer and operation to NUMBER:
      this must be done at the end, since at the beginning it
      might cause op_islevelstr() to return a false error */

   CURTASK exps[ level - 1 ].type = NUMBER;
   CURTASK exps[ level - 1 ].operation = NUMBER;

   /* decrement the stack */

   op_pulldown( 2 );

   return TRUE;

   }

/***************************************************************

	FUNCTION:       op_lteq()

	DESCRIPTION:    This function compares two values and
			returns an integer value: TRUE if the
			left hand value is less than or equal
			to the right, and FALSE if it is not.

***************************************************************/

#if ANSI_C
static int
op_lteq( int level, int precision )
#else
static int
op_lteq( level, precision )
   int level;
   int precision;
#endif
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
            if ( str_cmp( exp_getsval( &( CURTASK exps[ level - 1 ] )),
               exp_getsval( &( CURTASK exps[ level + 1 ] )) ) <= 0 )
               {
               CURTASK exps[ level - 1 ].nval = (bnumber) TRUE;
               }
            else
               {
               CURTASK exps[ level - 1 ].nval = (bnumber) FALSE;
               }
            }
         break;

      case NUMBER:
         if ( exp_getnval( &( CURTASK exps[ level - 1 ] ))
            <= exp_getnval( &( CURTASK exps[ level + 1 ] )) )
            {
            CURTASK exps[ level - 1 ].nval = (bnumber) TRUE;
            }
         else
            {
            CURTASK exps[ level - 1 ].nval = (bnumber) FALSE;
            }
         break;

      }

   /* set variable to integer and operation to NUMBER:
      this must be done at the end, since at the beginning it
      might cause op_islevelstr() to return a false error */

   CURTASK exps[ level - 1 ].type = NUMBER;
   CURTASK exps[ level - 1 ].operation = NUMBER;

   /* decrement the stack */

   op_pulldown( 2 );

   return TRUE;

   }

/***************************************************************

	FUNCTION:       op_gteq()

	DESCRIPTION:    This function compares two values and
			returns an integer value: TRUE if the
			left hand value is greater than or equal
			to the right, and FALSE if it is not.

***************************************************************/

#if ANSI_C
static int
op_gteq( int level, int precision )
#else
static int
op_gteq( level, precision )
   int level;
   int precision;
#endif
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
            if ( str_cmp( exp_getsval( &( CURTASK exps[ level - 1 ] )),
               exp_getsval( &( CURTASK exps[ level + 1 ] )) ) >= 0 )
               {
               CURTASK exps[ level - 1 ].nval = (bnumber) TRUE;
               }
            else
               {
               CURTASK exps[ level - 1 ].nval = (bnumber) FALSE;
               }
            }
         break;

      case NUMBER:
         if ( exp_getnval( &( CURTASK exps[ level - 1 ] ))
            >= exp_getnval( &( CURTASK exps[ level + 1 ] )) )
            {
            CURTASK exps[ level - 1 ].nval = (bnumber) TRUE;
            }
         else
            {
            CURTASK exps[ level - 1 ].nval = (bnumber) FALSE;
            }
         break;

      }

   /* set variable to integer and operation to NUMBER:
      this must be done at the end, since at the beginning it
      might cause op_islevelstr() to return a false error */

   CURTASK exps[ level - 1 ].type = NUMBER;
   CURTASK exps[ level - 1 ].operation = NUMBER;

   /* decrement the stack */

   op_pulldown( 2 );

   return TRUE;

   }

/***************************************************************

	FUNCTION:       op_notequal()

	DESCRIPTION:    This function compares two values and
			returns an integer value: TRUE if they
			are not the same and FALSE if they are.

***************************************************************/

#if ANSI_C
static int
op_notequal( int level, int precision )
#else
static int
op_notequal( level, precision )
   int level;
   int precision;
#endif
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
            if ( str_cmp( exp_getsval( &( CURTASK exps[ level - 1 ] )),
               exp_getsval( &( CURTASK exps[ level + 1 ] )) ) != 0 )
               {
               CURTASK exps[ level - 1 ].nval = (bnumber) TRUE;
               }
            else
               {
               CURTASK exps[ level - 1 ].nval = (bnumber) FALSE;
               }
            }
         break;

      case NUMBER:
         if ( exp_getnval( &( CURTASK exps[ level - 1 ] ))
            != exp_getnval( &( CURTASK exps[ level + 1 ] )) )
            {
            CURTASK exps[ level - 1 ].nval = (bnumber) TRUE;
            }
         else
            {
            CURTASK exps[ level - 1 ].nval = (bnumber) FALSE;
            }
         break;

      }

   /* set variable to integer and operation to NUMBER:
      this must be done at the end, since at the beginning it
      might cause op_islevelstr() to return a false error */

   CURTASK exps[ level - 1 ].type = NUMBER;
   CURTASK exps[ level - 1 ].operation = NUMBER;

   /* decrement the stack */

   op_pulldown( 2 );

   return TRUE;

   }

/***************************************************************

	FUNCTION:       op_modulus()

	DESCRIPTION:    This function divides the number on
			the left by the number on the right
			and returns the remainder.

***************************************************************/

#if ANSI_C
static int
op_modulus( int level, int precision )
#else
static int
op_modulus( level, precision )
   int level;
   int precision;
#endif
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

      case NUMBER:
         if ( exp_getnval( &( CURTASK exps[ level + 1 ] ))
            == (bnumber) 0 )
            {
            CURTASK exps[ level - 1 ].nval = (bnumber) -1;
            op_pulldown( 2 );
#if PROG_ERRORS
            sprintf( bwb_ebuf, "Divide by 0." );
            bwb_error( bwb_ebuf );
#else
            bwb_error( err_dbz );
#endif
            return FALSE;
            }
         CURTASK exps[ level ].nval
            = exp_getnval( &( CURTASK exps[ level - 1 ] ))
            / exp_getnval( &( CURTASK exps[ level + 1 ] ));
         modf( (double) CURTASK exps[ level ].nval, &iportion );
         CURTASK exps[ level - 1 ].nval
            = exp_getnval( &( CURTASK exps[ level - 1 ] ))
            - ( exp_getnval( &( CURTASK exps[ level + 1 ] ))
            * iportion );
         break;

      }

   /* set variable to requested precision */

   CURTASK exps[ level - 1 ].type = (char) precision;
   CURTASK exps[ level - 1 ].operation = NUMBER;

   /* decrement the stack twice */

   op_pulldown( 2 );

   return TRUE;

   }

/***************************************************************

	FUNCTION:       op_exponent()

	DESCRIPTION:    This function finds the exponential value
			of a number (on the left) to the power
			indicated on the right-hand side.

***************************************************************/

#if ANSI_C
static int
op_exponent( int level, int precision )
#else
static int
op_exponent( level, precision )
   int level;
   int precision;
#endif
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

      case NUMBER:
         CURTASK exps[ level - 1 ].nval
           = (bnumber) pow( (double) exp_getnval( &( CURTASK exps[ level - 1 ] )),
                  (double) exp_getnval( &( CURTASK exps[ level + 1 ] )) );
         break;

      }

   /* set variable to requested precision */

   CURTASK exps[ level - 1 ].type = (char) precision;
   CURTASK exps[ level - 1 ].operation = NUMBER;

   /* decrement the stack twice */

   op_pulldown( 2 );

   return TRUE;

   }

/***************************************************************

	FUNCTION:       op_intdiv()

	DESCRIPTION:    This function divides the number on
			the left by the number on the right,
			returning the result as an integer.

***************************************************************/

#if ANSI_C
static int
op_intdiv( int level, int precision )
#else
static int
op_intdiv( level, precision )
   int level;
   int precision;
#endif
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
         if ( exp_getnval( &( CURTASK exps[ level + 1 ] ))
            == (bnumber) 0 )
            {
            CURTASK exps[ level - 1 ].nval = (bnumber) -1;
            op_pulldown( 2 );
#if PROG_ERRORS
            sprintf( bwb_ebuf, "Divide by 0." );
            bwb_error( bwb_ebuf );
#else
            bwb_error( err_dbz );
#endif
            return FALSE;
            }

         CURTASK exps[ level - 1 ].nval
            = exp_getnval( &( CURTASK exps[ level - 1 ] ))
            / exp_getnval( &( CURTASK exps[ level + 1 ] ));
         break;
      }

   /* set variable to requested precision */

   CURTASK exps[ level - 1 ].type = NUMBER;
   CURTASK exps[ level - 1 ].operation = NUMBER;

   /* decrement the stack twice */

   op_pulldown( 2 );

   return TRUE;

   }

/***************************************************************

	FUNCTION:       op_or()

	DESCRIPTION:    This function compares two integers and
			performs a logical OR on them.

***************************************************************/

#if ANSI_C
static int
op_or( int level, int precision )
#else
static int
op_or( level, precision )
   int level;
   int precision;
#endif
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

      case NUMBER:
         CURTASK exps[ level - 1 ].nval
            = (bnumber) ((int) exp_getnval( &( CURTASK exps[ level - 1 ] ))
            | (int) exp_getnval( &( CURTASK exps[ level + 1 ] )));
         break;

      }

   /* set variable type to integer */

   CURTASK exps[ level - 1 ].type = NUMBER;
   CURTASK exps[ level - 1 ].operation = NUMBER;

   /* decrement the stack twice */

   op_pulldown( 2 );

   return TRUE;

   }

/***************************************************************

	FUNCTION:       op_and()

	DESCRIPTION:    This function compares two integers and
			performs a logical AND on them.

***************************************************************/

#if ANSI_C
static int
op_and( int level, int precision )
#else
static int
op_and( level, precision )
   int level;
   int precision;
#endif
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

      case NUMBER:
         CURTASK exps[ level - 1 ].nval
            = (bnumber) ((int) exp_getnval( &( CURTASK exps[ level - 1 ] ))
            & (int) exp_getnval( &( CURTASK exps[ level + 1 ] )));
         break;

      }

   /* set variable type to integer */

   CURTASK exps[ level - 1 ].type = NUMBER;
   CURTASK exps[ level - 1 ].operation = NUMBER;

   /* decrement the stack twice */

   op_pulldown( 2 );

   return TRUE;

   }

/***************************************************************

	FUNCTION:       op_not()

	DESCRIPTION:    This function performs a logical NOT on
			the integer to the right.

***************************************************************/

#if ANSI_C
static int
op_not( int level, int precision )
#else
static int
op_not( level, precision )
   int level;
   int precision;
#endif
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

      default:

#if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in op_not(): argument is <%d>, precision <%c>",
            (unsigned int) exp_getnval( &( CURTASK exps[ level + 1 ] )), precision );
         bwb_debug( bwb_ebuf );
#endif

         CURTASK exps[ level ].nval = (bnumber)
            ~( (int) exp_getnval( &( CURTASK exps[ level + 1 ] )) );

#if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in op_not(): result is <%d>, precision <%c>",
            (unsigned int) exp_getnval( &( CURTASK exps[ level ] )), precision );
         bwb_debug( bwb_ebuf );
#endif

         break;
      }

   /* set variable type to integer */

   CURTASK exps[ level ].type = NUMBER;
   CURTASK exps[ level ].operation = NUMBER;

   /* decrement the stack once */

   op_pulldown( 1 );

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in op_not(): CURTASK expsc <%d>, level <%d> result <%d>",
      CURTASK expsc, level, CURTASK exps[ CURTASK expsc ].nval );
   bwb_debug( bwb_ebuf );
#endif

   return TRUE;

   }

/***************************************************************

	FUNCTION:       op_xor()

	DESCRIPTION:    This function compares two integers and
			performs a logical XOR on them.

***************************************************************/

#if ANSI_C
static int
op_xor( int level, int precision )
#else
static int
op_xor( level, precision )
   int level;
   int precision;
#endif
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

      case NUMBER:
         CURTASK exps[ level - 1 ].nval
            = (bnumber) ((int) exp_getnval( &( CURTASK exps[ level - 1 ] ))
            ^ (int) exp_getnval( &( CURTASK exps[ level + 1 ] )));
         break;

      }

   /* set variable type to integer */

   CURTASK exps[ level - 1 ].type = NUMBER;
   CURTASK exps[ level - 1 ].operation = NUMBER;

   /* decrement the stack twice */

   op_pulldown( 2 );

   return TRUE;

   }

/***************************************************************

	FUNCTION:       op_negation()

	DESCRIPTION:    This function performs a negation on the
			element to the right.
			Added by JBV 10/95

***************************************************************/

#if ANSI_C
static int
op_negation( int level, int precision )
#else
static int
op_negation( level, precision )
   int level;
   int precision;
#endif
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

      default:

#if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in op_negation(): argument is <%f>, precision <%c>",
            exp_getnval( &( CURTASK exps[ level + 1 ] )), precision );
         bwb_debug( bwb_ebuf );
#endif

         CURTASK exps[ level ].nval = (bnumber)
            -( exp_getnval( &( CURTASK exps[ level + 1 ] )) );

#if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in op_negation(): result is <%f>, precision <%c>",
            exp_getnval( &( CURTASK exps[ level ] )), precision );
         bwb_debug( bwb_ebuf );
#endif

         break;
      }

   /* set variable type to requested precision (JBV) */

   CURTASK exps[ level ].type = (char) precision;
   CURTASK exps[ level ].operation = NUMBER;

   /* decrement the stack once */

   op_pulldown( 1 );

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in op_negation(): CURTASK expsc <%d>, level <%d> result <%f>",
      CURTASK expsc, level, CURTASK exps[ CURTASK expsc ].nval );
   bwb_debug( bwb_ebuf );
#endif

   return TRUE;

   }

/***************************************************************

	FUNCTION:       op_islevelstr()

	DESCRIPTION:    This function determines whether the
			operation at a specified level involves a
			string constant or variable.

***************************************************************/

#if ANSI_C
static int
op_islevelstr( int level )
#else
static int
op_islevelstr( level )
   int level;
#endif
   {

   /* first see if the level holds a string constant */

   if ( CURTASK exps[ level ].operation == CONST_STRING )
      {

#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in op_islevelstr(): string detected at level <%d>.",
         level );
      bwb_debug( bwb_ebuf );
#endif

      return TRUE;
      }

   /* see if the level holds a string variable */

   if ( CURTASK exps[ level ].operation == VARIABLE )
      {
      if ( CURTASK exps[ level ].xvar->type == STRING )
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

	FUNCTION:       op_getprecision()

	DESCRIPTION:    This function finds the precision for
			an operation by comparing the precision
			at this level and that two levels below.

***************************************************************/

#if ANSI_C
static int
op_getprecision( int level )
#else
static int
op_getprecision( level )
   int level;
#endif
   {

   /* first test for string value */

   if (  ( CURTASK exps[ level + 1 ].type == STRING )
      || ( CURTASK exps[ level - 1 ].type == STRING ) )
      {
      return STRING;
      }

   /* Both are numbers, so we should be able to find a suitable
      precision level by starting with the top and moving down;
      check first for double precision */

   else
      {
      return NUMBER;
      }

   }

/***************************************************************

	FUNCTION:       op_pulldown()

	DESCRIPTION:    This function pulls the expression stack
			down a specified number of levels, decrementing
			the expression stack counter (bycalling dec_esc())
			and decrementing the current "level" of operation
			processing.

***************************************************************/

#if ANSI_C
static int
op_pulldown( int how_far )
#else
static int
op_pulldown( how_far )
   int how_far;
#endif
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
   while ( CURTASK expsc >= ( level + how_far ) )
      {

      /*------------------------------------------------------*/
      /* But before memcpy, deallocate sbuffer for level, and */
      /* afterwards, set sbuffer for level + how_far to NULL! */
      /* Else konfusion reigns the next time around... (JBV)  */
      /*------------------------------------------------------*/

      if( CURTASK exps[ level ].sval.sbuffer != NULL ) /* JBV */
         FREE( CURTASK exps[ level ].sval.sbuffer, "op_pulldown" );
      memcpy( &CURTASK exps[ level ], &CURTASK exps[ level + how_far ],
         (size_t) ( sizeof( struct exp_ese )) );
      CURTASK exps[ level + how_far ].sval.sbuffer = NULL; /* JBV */

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


