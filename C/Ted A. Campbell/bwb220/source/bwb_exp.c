/****************************************************************

        bwb_exp.c       Expression Parser
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

/***************************************************************

        FUNCTION:	bwb_exp()

        DESCRIPTION:	This is the function by which the expression
			parser is called.

***************************************************************/

#if ANSI_C
struct exp_ese *
bwb_exp( char *expression, int assignment, int *position )
#else
struct exp_ese *
bwb_exp( expression, assignment, position )
   char *expression;
   int assignment;
   int *position;
#endif
   {
   struct exp_ese *rval;			/* return value */
   int entry_level, main_loop, err_condition;
   char *e;                                     /* pointer to current string */
   int r;                                       /* return value from functions */
   register int c;                              /* quick counter */
#if OLD_WAY
   int adv_loop;
#endif

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "entered bwb_exp(): expression <%s> assignment <%d> level <%d>",
      & ( expression[ *position ] ), assignment, CURTASK expsc );
   bwb_debug( bwb_ebuf );
#endif

   /* save the entry level of the expression stack in order to
      check it at the end of this function */

   entry_level = CURTASK expsc;
   err_condition = FALSE;

   /* advance past whitespace or beginning of line segment */

#if MULTISEG_LINES
   if ( expression[ *position ] == ':' )
      {
      ++( *position );
      }
#endif
   adv_ws( expression, position );
#if MULTISEG_LINES
   if ( expression[ *position ] == ':' )
      {
      ++( *position );
      adv_ws( expression, position );
      }
#endif

   /* increment the expression stack counter to get a new level */

   inc_esc();

   /* check to be sure there is a legitimate expression
      and set initial parameters for the main loop */

   if ( is_eol( expression, position ) == TRUE )
      {
      main_loop = FALSE;    /* break out of loop */
      }
   else
      {
      main_loop = TRUE;
      CURTASK exps[ CURTASK expsc ].pos_adv = 0;
      }

#if OLDWAY
   adv_loop = TRUE;
   while( adv_loop == TRUE )
      {
      switch( expression[ *position ] )
         {
         case ' ':                           /* whitespace */
         case '\t':
            ++(*position);
            break;
         case '\0':                          /* end of string */
         case '\r':
         case '\n':
            main_loop = adv_loop = FALSE;    /* break out of loop */
            break;
         default:
            adv_loop = FALSE;
            main_loop = TRUE;
            CURTASK exps[ CURTASK expsc ].pos_adv = 0;
            break;
         }
      }
#endif

   /* main parsing loop */

   while ( main_loop == TRUE )
      {

      /* set variable <e> to the start of the expression */

      e = &( expression[ *position ] );

#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_exp(): main loop, level <%d> element <%s> ",
         CURTASK expsc, e );
      bwb_debug( bwb_ebuf );
#endif

      /* detect the operation required at this level */

      CURTASK exps[ CURTASK expsc ].operation = exp_findop( e );

#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_exp(): exp_findop() returned <%d>",
         CURTASK exps[ CURTASK expsc ].operation );
      bwb_debug( bwb_ebuf );
#endif

      /* perform actions specific to the operation */

      switch( CURTASK exps[ CURTASK expsc ].operation )
         {
         case OP_ERROR:
            main_loop = FALSE;
            err_condition = TRUE;
            break;

	 case OP_TERMINATE:                /* terminate at THEN, ELSE, TO */
#if INTENSIVE_DEBUG
	    bwb_debug( "in bwb_exp(): Found OP_TERMINATE" );
#endif
         case OP_STRJOIN:                  /* string join or tab */
         case OP_STRTAB:
	    main_loop = FALSE;
	    err_condition = FALSE;
	    dec_esc();
	    break;

	 case OP_ADD:                      /* in the case of any numerical operation, */
         case OP_SUBTRACT:
         case OP_MULTIPLY:
         case OP_DIVIDE:
         case OP_MODULUS:
         case OP_EXPONENT:
         case OP_INTDIVISION:
         case OP_GREATERTHAN:
         case OP_LESSTHAN:
         case OP_GTEQ:
         case OP_LTEQ:
         case OP_NOTEQUAL:
         case OP_NOT:
         case OP_AND:
         case OP_OR:
         case OP_XOR:
         case OP_IMPLIES:
         case OP_EQUIV:
         case OP_NEGATION: /* JBV */

#if INTENSIVE_DEBUG
            sprintf( bwb_ebuf, "in bwb_exp(): operator detected." );
            bwb_debug( bwb_ebuf );
#endif

            CURTASK exps[ CURTASK expsc ].pos_adv = -1;             /* set to strange number */

            /* cycle through operator table to find match */

            for ( c = 0; c < N_OPERATORS; ++c )
               {
               if ( exp_ops[ c ].operation == CURTASK exps[ CURTASK expsc ].operation )
                  {
                  CURTASK exps[ CURTASK expsc ].pos_adv = strlen( exp_ops[ c ].symbol );
                  }
               }

            if ( CURTASK exps[ CURTASK expsc ].pos_adv == -1 )      /* was a match found? */
               {
               CURTASK exps[ CURTASK expsc ].pos_adv = 0;           /* no -- set to 0 */
               }
            break;                         /* and move on */

         case OP_EQUALS:

#if INTENSIVE_DEBUG
            sprintf( bwb_ebuf, "in bwb_exp(): equal sign detected." );
            bwb_debug( bwb_ebuf );
#endif

            if ( assignment == TRUE )
               {
               CURTASK exps[ CURTASK expsc ].operation = OP_ASSIGN;
               }
            CURTASK exps[ CURTASK expsc ].pos_adv = 1;
            break;

         case PARENTHESIS:
            r = exp_paren( e );
            break;

	 case CONST_STRING:
            r = exp_strconst( e );
            break;

	 case CONST_NUMERICAL:
            r = exp_numconst( e );
#if INTENSIVE_DEBUG
            sprintf( bwb_ebuf, "in bwb_exp(): return from exp_numconst(), r = <%d>",
               r );
            bwb_debug( bwb_ebuf );
#endif
            break;

         case FUNCTION:

#if INTENSIVE_DEBUG
            sprintf( bwb_ebuf, "in bwb_exp(): calling exp_function(), expression <%s>",
               e );
            bwb_debug( bwb_ebuf );
#endif

            r = exp_function( e );
            break;

         case OP_USERFNC:

#if INTENSIVE_DEBUG
            sprintf( bwb_ebuf, "in bwb_exp(): calling exp_ufnc(), expression <%s>",
               e );
            bwb_debug( bwb_ebuf );
#endif

	    r = exp_ufnc( e );

#if INTENSIVE_DEBUG
	    sprintf( bwb_ebuf, "in bwb_exp(): return from exp_ufnc(), buffer <%s>",
	       &( expression[ *position ] ) );
	    bwb_debug( bwb_ebuf );
#endif

            break;

         case VARIABLE:
            r = exp_variable( e );
            break;

	 default:
            err_condition = TRUE;
            main_loop = FALSE;
#if PROG_ERRORS
            sprintf( bwb_ebuf, "in bwb_exp.c:bwb_exp(): unidentified operation (%d).",
               CURTASK exps[ CURTASK expsc ].operation );
            bwb_error( bwb_ebuf );
#else
            bwb_error( err_syntax );
#endif
            break;
         }

      /* increment *position counter based on previous actions */

      *position += CURTASK exps[ CURTASK expsc ].pos_adv;
      CURTASK exps[ CURTASK expsc ].pos_adv = 0;            /* reset advance counter */

#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_exp(): advanced position; r <%d> err_c <%d>",
         r, err_condition );
      bwb_debug( bwb_ebuf );
#endif

#if INTENSIVE_DEBUG
      if ( CURTASK exps[ CURTASK expsc ].operation == OP_EQUALS )
         {
         sprintf( bwb_ebuf, "in bwb_exp(): with OP_EQUALS: finished case" );
         bwb_debug( bwb_ebuf );
         }
#endif

      /* check for end of string */

      if ( is_eol( expression, position ) == TRUE )
         {
         main_loop = FALSE;    /* break out of loop */         
         }

#if OLDWAY
      adv_loop = TRUE;
      while( adv_loop == TRUE )
         {
         switch( expression[ *position ] )
            {
            case ' ':                           /* whitespace */
            case '\t':
               ++(*position);
               break;
            case '\0':                          /* end of string */
            case '\r':
            case '\n':
            case ':':
               main_loop = adv_loop = FALSE;    /* break out of loop */
               break;
            default:
               adv_loop = FALSE;
               break;
            }
         }
#endif

      /* get a new stack level before looping */

      if ( main_loop == TRUE )
         {
         r = inc_esc();
#if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in bwb_exp(): increment esc, r <%d>, err_c <%d>",
            r, err_condition );
         bwb_debug( bwb_ebuf );
#endif
         }

      /* check for error return */

      if ( r == OP_ERROR )
         {
#if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in bwb_exp(): found r == OP_ERROR." );
         bwb_debug( bwb_ebuf );
#endif
         main_loop = FALSE;
         err_condition = TRUE;
         }
      else
         {
         r = TRUE;
         }

      }                                 /* end of main parsing loop */

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_exp(): breakout from main parsing loop, r <%d> err_c <%d>",
      r, err_condition );
   bwb_debug( bwb_ebuf );
#endif

   /* check error condition */

   if ( err_condition == TRUE )
      {

#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "error detected in expression parser" );
      bwb_debug( bwb_ebuf );
#endif

      /* decrement the expression stack counter until it matches entry_level */

      while( CURTASK expsc > entry_level )
         {
         dec_esc();
         }

#if PROG_ERRORS
      bwb_error( "in bwb_exp():  Error detected in parsing expression" );
#else
      bwb_error( err_syntax );
#endif
      }

   /* no error; normal exit from function */

   else
      {

      /* are any more operations needed? if we are still at entry level,
         then they are not */

      /* try operations */

      exp_operation( entry_level );

      /* see what is on top of the stack */

      if ( CURTASK expsc > ( entry_level + 1 ))
         {
         switch( CURTASK exps[ CURTASK expsc ].operation )
            {
            case OP_STRJOIN:
               if ( CURTASK expsc != ( entry_level + 2 ))
                  {
#if PROG_ERRORS
                  sprintf( bwb_ebuf, "in bwb_exp(): OP_STRJOIN in wrong position." );
                  bwb_error( bwb_ebuf );
#else
                  bwb_error( err_syntax );
#endif
                  }
               break;
            default:
#if PROG_ERRORS
               sprintf( bwb_ebuf, "in bwb_exp(): incomplete expression." );
               bwb_error( bwb_ebuf );
#else
               bwb_error( err_syntax );
#endif
               break;
            }

         /* decrement the expression stack counter */

#if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in bwb_exp(): before dec_esc type is <%c>",
            CURTASK exps[ CURTASK expsc ].type );
         bwb_debug( bwb_ebuf );
#endif

         dec_esc();

         }

      /* assign rvar to the variable for the current level */

      rval = &( CURTASK exps[ CURTASK expsc ] );

      /* decrement the expression stack counter */

      dec_esc();

      /* check the current level before exit */

      if ( entry_level != CURTASK expsc )
         {
#if PROG_ERRORS
         sprintf( bwb_ebuf, "in bwb_exp(): exit stack level (%d) does not match entry stack level (%d)",
            CURTASK expsc, entry_level );
         bwb_error( bwb_ebuf );
#else
         bwb_error( err_overflow );
#endif
         }

      }

   /* return a pointer to the last stack level */

   return rval;

   }

/***************************************************************

	FUNCTION:       exp_findop()

	DESCRIPTION:    This function reads the expression to find
			what operation is required at its stack level.

***************************************************************/

#if ANSI_C
int
exp_findop( char *expression )
#else
int
exp_findop( expression )
   char *expression;
#endif
   {
   register int c;                              /* character counter */
   int carry_on;                                /* boolean: control while loop */
   int rval;                                    /* return value */
   char cbuf[ MAXSTRINGSIZE + 1 ];              /* capitalized expression */
   char nbuf[ MAXSTRINGSIZE + 1 ];              /* non-capitalized expression */
   int position;                                /* position in the expression */
   int adv_loop;                                /* control loop to build expression */

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in exp_findop(): received <%s>", expression );
   bwb_debug( bwb_ebuf );
#endif

   /* set return value to OP_NULL initially */

   rval = OP_NULL;

   /* assign local pointer to expression to begin reading */

   position = 0;

   /* advance to the first significant character */

   adv_ws( expression, &position );

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in exp_findop(): expression after advance <%s>",
      &( expression[ position ] ) );
   bwb_debug( bwb_ebuf );
#endif

   /* we now have the first significant character and can begin parsing */

   /* check the first character for an indication of a parenthetical
      expression, a string constant, or a numerical constant that begins
      with a digit (numerical constants beginning with a plus or minus
      sign or hex/octal/binary constants will have to be detected by
      exp_isnc() */

   carry_on = TRUE;
   switch ( expression[ position ] )
      {
      case '\"':                /* this should indicate a string constant */
         rval = CONST_STRING;
         break;
      case '(':                 /* this will indicate a simple parenthetical expression */
         rval = PARENTHESIS;
         break;

#if MULTISEG_LINES
      case ':':                 /* terminate processing */
#endif
      case ')':			/* end of argument list? */
         rval = OP_TERMINATE;
         break;

      case '0':                 /* these will indicate a numerical constant */
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
      case '&':                 /* designator for hex or octal constant */
         rval = CONST_NUMERICAL;
         break;
      }

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in exp_findop(): rval pos 1 is <%d>", rval );
   bwb_debug( bwb_ebuf );
#endif

   /* String constants, numerical constants, open parentheses, and
      the plus and minus operators have been checked at this point;
      but if the return value is still OP_NULL, other possibilities
      must be checked, namely, other operators, function names, and
      variable names.  The function adv_element cannot be used here
      because it will stop, e.g., with certain operators and not
      include them in the returned element. */

   /* get a character string to be interpreted */

   adv_loop = TRUE;
   cbuf[ 0 ] = '\0';
   nbuf[ 0 ] = '\0';
   c = 0;
   while ( adv_loop == TRUE )
      {

#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in exp_findop() loop position <%d> char 0x%x",
	 c, expression[ position ] );
      bwb_debug( bwb_ebuf );
#endif

      switch( expression[ position ] )
	 {
	 case ' ':              /* whitespace */
	 case '\t':
	 case '\r':             /* end of line */
	 case '\n':
	 case '\0':             /* end of string */
	 case '(':              /* parenthesis terminating function name */
	    adv_loop = FALSE;
	    break;
	 default:
	    nbuf[ c ] = cbuf[ c ] = expression[ position ];
	    ++c;
	    nbuf[ c ] = cbuf[ c ] = '\0';
	    ++position;
	    break;
	 }

      if ( c >= MAXSTRINGSIZE )
	 {
	 adv_loop = FALSE;
	 }

      }
   bwb_strtoupper( cbuf );

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in exp_findop(): cbuf element is <%s>", cbuf );
   bwb_debug( bwb_ebuf );
#endif

   /* check for numerical constant */

   if ( rval == OP_NULL )
      {
      rval = exp_isnc( cbuf );
      }

   /* check for other operators */

   if ( rval == OP_NULL )
      {
      rval = exp_isop( cbuf );
      }

   /* check for user-defined function */

   if ( rval == OP_NULL )
      {
      rval = exp_isufn( nbuf );
      }

   /* check for function name */

   if ( rval == OP_NULL )
      {
      rval = exp_isfn( nbuf );
      }

   /* check for a BASIC command, esp. to catch THEN or ELSE */

   if ( rval == OP_NULL )
      {
      rval = exp_iscmd( cbuf );
      }

   /* last: check for variable name, and assign it if there
      is not already one */

   if ( rval == OP_NULL )
      {
      rval = exp_isvn( nbuf );
      }

   /* return the value assigned (or OP_ERROR if none assigned) */

   if ( rval == OP_NULL )
      {
      return OP_ERROR;
      }
   else
      {
      return rval;
      }

   }

/***************************************************************

	FUNCTION:       exp_isnc()

	DESCRIPTION:    This function reads the expression to find
			if a numerical constant is present at this
			point.

***************************************************************/

#if ANSI_C
int
exp_isnc( char *expression )
#else
int
exp_isnc( expression )
   char *expression;
#endif
   {
   char tbuf[ MAXVARNAMESIZE + 1 ]; /* JBV */

   switch( expression[ 0 ] )
      {
      case '0':                 /* these will indicate a numerical constant */
      case '1':
      case '2':
      case '3':
      case '4':
      case '5':
      case '6':
      case '7':
      case '8':
      case '9':
      case '&':                 /* indicator for hex or octal constant */
         return CONST_NUMERICAL;
      case '+':
      case '-':

         /* if the previous stack level was a numerical value or a string,
            then this is certainly not one; return OP_NULL here
            and let the next function call to exp_isop() determine
            the (plus or minus) operator */

         if (  ( CURTASK exps[ CURTASK expsc - 1 ].operation == NUMBER )
            || ( CURTASK exps[ CURTASK expsc - 1 ].operation == VARIABLE )
            || ( CURTASK exps[ CURTASK expsc - 1 ].operation == CONST_STRING ) )
            {

#if INTENSIVE_DEBUG
            sprintf( bwb_ebuf, "in exp_isnc(): previous function is a number or string" );
            bwb_debug( bwb_ebuf );
#endif

            return OP_NULL;
            }

         /* similarly, if the previous stack level was a variable
            with a numerical value (not a string), then this level
            must be an operator, not a numerical constant */

         if ( ( CURTASK exps[ CURTASK expsc - 1 ].operation == VARIABLE )
            && ( CURTASK exps[ CURTASK expsc - 1 ].type != STRING ))
            {
            return OP_NULL;
            }

         /*--------------------------------------------------------*/
         /* Check for unary minus sign added by JBV.               */
         /* Could be prefixing a parenthetical expression or a     */
         /* variable name.                                         */
         /* But parentheses won't show up in expression (cbuf), so */
         /* just check for expression and variable name lengths.   */
         /*--------------------------------------------------------*/
         if (expression[0] == '-')
         {
             if (strlen(expression) == 1) return OP_NEGATION;
             exp_getvfname(&expression[1], tbuf);
             if (strlen(tbuf) != 0) return OP_NEGATION;
         }

         /* failing these tests, the argument must be a numerical
            constant preceded by a plus or minus sign */

         return CONST_NUMERICAL;

      default:
         return OP_NULL;
      }

   }

/***************************************************************

	FUNCTION:       exp_isop()

	DESCRIPTION:    This function reads the expression to find
			if a logical or mathematical operation is
			required at this point.

        This function presupposes that a numerical constant with
        affixed plus or minus sign has been ruled out.

***************************************************************/

#if ANSI_C
int
exp_isop( char *expression )
#else
int
exp_isop( expression )
   char *expression;
#endif
   {
   register int c;                              /* counter */

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in exp_isop(): expression is <%s>", expression );
   bwb_debug( bwb_ebuf );
#endif

   /* compare the initial characters of the string with the table
      of operators */

   for ( c = 0; c < N_OPERATORS; ++c )
      {
      if ( strncmp( expression, exp_ops[ c ].symbol,
         (size_t) strlen( exp_ops[ c ].symbol ) ) == 0 )
         {

#if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in exp_isop(): match <%s>, number <%d>.",
            exp_ops[ c ].symbol, c );
         bwb_debug( bwb_ebuf );
#endif

         return exp_ops[ c ].operation;
         }
      }

   /* search failed; return OP_NULL */

   return OP_NULL;

   }

/***************************************************************

	FUNCTION:       exp_iscmd()

	DESCRIPTION:    This function reads the expression to find
			if a BASIC command name is present; if so,
			it returns OP_TERMINATE to terminate expression
			parsing.  This is critical, for example, in
			parsing a conditional following IF where THEN,
			ELSE, and other BASIC commands may follow.

***************************************************************/

#if ANSI_C
int
exp_iscmd( char *expression )
#else
int
exp_iscmd( expression )
   char *expression;
#endif
   {
   register int n;

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in exp_iscmd(): expression received <%s>",
      expression );
   bwb_debug( bwb_ebuf );
#endif

   /* first check for THEN or ELSE statements */

   if ( strcmp( expression, CMD_THEN ) == 0 )
      {
#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in exp_iscmd(): match found, <%s>",
	 expression );
      bwb_debug( bwb_ebuf );
#endif
      return OP_TERMINATE;
      }

#if STRUCT_CMDS
   if ( strcmp( expression, CMD_TO ) == 0 )
      {
#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in exp_iscmd(): match found, <%s>",
	 expression );
      bwb_debug( bwb_ebuf );
#endif
      return OP_TERMINATE;
      }
#endif

   if ( strcmp( expression, CMD_ELSE ) == 0 )
      {
#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in exp_iscmd(): match found, <%s>",
	 expression );
      bwb_debug( bwb_ebuf );
#endif
      return OP_TERMINATE;
      }

   /* run through the command table and search for a match */

   for ( n = 0; n < COMMANDS; ++n )
      {
      if ( strcmp( expression, bwb_cmdtable[ n ].name ) == 0 )
         {
#if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in exp_iscmd(): match found, <%s>",
            expression );
         bwb_debug( bwb_ebuf );
#endif
         return OP_TERMINATE;
         }
#if INTENSIVE_DEBUG
      else
         {
         sprintf( bwb_ebuf, "in exp_iscmd(): No match, <%s> and <%s>; returns %d",
            expression, bwb_cmdtable[ n ].name,
            strcmp( expression, bwb_cmdtable[ n ].name ) );
         bwb_debug( bwb_ebuf );
         }
#endif
      }

   /* search failed, return NULL */

   return OP_NULL;

   }

/***************************************************************

        FUNCTION:   	exp_isufn()

        DESCRIPTION:  	This function reads the expression to find
        		if a user-defined function name is present
			at this point.

***************************************************************/

#if ANSI_C
int
exp_isufn( char *expression )
#else
int
exp_isufn( expression )
   char *expression;
#endif
   {
   struct fslte *f;
   char tbuf[ MAXVARNAMESIZE + 1 ];

   exp_getvfname( expression, tbuf );

   for ( f = CURTASK fslt_start.next; f != &CURTASK fslt_end; f = f->next )
      {
      if ( strcmp( f->name, tbuf ) == 0 )
         {
#if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in exp_isufn(): found user function <%s>",
            tbuf );
         bwb_debug( bwb_ebuf );
#endif

         /* a user function name was found: but is it the local variable
            name for the user function? If so, return OP_NULL and the
            name will be read as a variable */

         if ( var_islocal( tbuf ) != NULL )
            {
            return OP_NULL;
            }
         else
            {

#if INTENSIVE_DEBUG
            sprintf( bwb_ebuf, "in exp_isufn(): found function <%s> not a local variable, EXEC level <%d>",
               tbuf, CURTASK exsc );
            bwb_debug( bwb_ebuf );
            getchar();
#endif

            return OP_USERFNC;
            }
         }
      }

   return OP_NULL;

   }

/***************************************************************

	FUNCTION:       exp_isfn()

	DESCRIPTION:    This function reads the expression to find
			if a function name is present at this point.

***************************************************************/

#if ANSI_C
int
exp_isfn( char *expression )
#else
int
exp_isfn( expression )
   char *expression;
#endif
   {

   /* Block out the call to exp_getvfname() if exp_isvn() is called
      after exp_isfn() */

   exp_getvfname( expression, CURTASK exps[ CURTASK expsc ].string );

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in exp_isfn(): search for function <%s>",
      expression );
   bwb_debug( bwb_ebuf );
#endif

   if ( fnc_find( CURTASK exps[ CURTASK expsc ].string ) == NULL )
      {
#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in exp_isfn(): failed to find function <%s>",
         expression );
      bwb_debug( bwb_ebuf );
#endif
      return OP_NULL;
      }
   else
      {
#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in exp_isfn(): found function <%s>",
         expression );
      bwb_debug( bwb_ebuf );
#endif
      return FUNCTION;
      }

   }

/***************************************************************

	FUNCTION:       exp_isvn()

	DESCRIPTION:    This function reads the expression to find
			if a variable name at this point.

***************************************************************/

#if ANSI_C
int
exp_isvn( char *expression )
#else
int
exp_isvn( expression )
   char *expression;
#endif
   {

   /* Block out the call to exp_getvfname() if exp_isfn() is called
      after exp_isvn() */

   /* exp_getvfname( expression, CURTASK exps[ CURTASK expsc ].string ); */

   /* rule out null name */

   if ( strlen( CURTASK exps[ CURTASK expsc ].string ) == 0 )
      {
      return OP_NULL;
      }

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in exp_isvn(): search for variable <%s>",
      CURTASK exps[ CURTASK expsc ].string );
   bwb_debug( bwb_ebuf );
#endif

   if ( var_find( CURTASK exps[ CURTASK expsc ].string ) == NULL )
      {
#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in exp_isvn(): failed to find variable <%s>",
         expression );
      bwb_debug( bwb_ebuf );
#endif
      return OP_NULL;
      }
   else
      {
#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in exp_isvn(): found variable <%s>",
         CURTASK exps[ CURTASK expsc ].string );
      bwb_debug( bwb_ebuf );
#endif
      return VARIABLE;
      }

   }

/***************************************************************

	FUNCTION:       exp_getvfname()

	DESCRIPTION:    This function reads the expression to find
			a variable or function name at this point.

***************************************************************/

#if ANSI_C
int
exp_getvfname( char *source, char *destination )
#else
int
exp_getvfname( source, destination )
   char *source;
   char *destination;
#endif
   {
   int s_pos, d_pos;                    /* source, destination positions */

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in exp_getvfname(): source buffer <%s>", source );
   bwb_debug( bwb_ebuf );
#endif

   s_pos = d_pos = 0;
   destination[ 0 ] = '\0';
   while( source[ s_pos ] != '\0' )
      {

      /* all alphabetical characters are acceptable */

      if ( isalpha( source[ s_pos ] ) != 0 )

         {
         destination[ d_pos ] = source[ s_pos ];

         ++d_pos;
         ++s_pos;
         destination[ d_pos ] = '\0';
         }

      /* numerical characters are acceptable but not in the first position */

      else if (( isdigit( source[ s_pos ] ) != 0 ) && ( d_pos != 0 ))
         {
         destination[ d_pos ] = source[ s_pos ];
         ++d_pos;
         ++s_pos;
         destination[ d_pos ] = '\0';
         }

      /* other characters will have to be tried on their own merits */

      else
         {
         switch( source[ s_pos ] )
            {

            case '.':                           /* tolerated non-alphabetical characters */
            case '_':
               destination[ d_pos ] = source[ s_pos ];
               ++d_pos;
               ++s_pos;
               destination[ d_pos ] = '\0';
               break;

	    case STRING:                        /* terminating characters */
	    case '#':                           /* Microsoft-type double precision */
	    case '!':                           /* Microsoft-type single precision */

	       destination[ d_pos ] = source[ s_pos ];
               ++d_pos;
               ++s_pos;
               destination[ d_pos ] = '\0';

               return TRUE;

            case '(':				/* begin function/sub name */
               return TRUE;

            default:                            /* anything else is non-tolerated */
               return FALSE;
            }
         }
      }

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in exp_getvfname(): found name <%s>", destination );
   bwb_debug( bwb_ebuf );
#endif

   return TRUE;                         /* exit after coming to the end */

   }

/***************************************************************

	FUNCTION:       exp_validarg()

	DESCRIPTION:    This function reads the expression to
			determine whether it is a valid argument (to be
			read recursively by bwb_exp() and passed to a
			function.

***************************************************************/

#if ANSI_C
int
exp_validarg( char *expression )
#else
int
exp_validarg( expression )
   char *expression;
#endif
   {
   register int c;

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in exp_validarg(): expression <%s>.",
      expression );
   bwb_debug( bwb_ebuf );
#endif

   c = 0;
   while ( TRUE )
      {
      switch( expression[ c ] )
         {
         case ' ':
         case '\t':
            ++c;
            break;
         case '\0':
            return FALSE;
         default:
            return TRUE;
         }
      }

   }

/***************************************************************

        FUNCTION:   	exp_getnval()

	DESCRIPTION:    This function returns the numerical value
			contain in the expression-stack element
			pointed to by 'e'.

***************************************************************/

#if ANSI_C
bnumber
exp_getnval( struct exp_ese *e )
#else
bnumber
exp_getnval( e )
   struct exp_ese *e;
#endif
   {

   /* check for variable */

   if ( e->operation == VARIABLE )
      {
      switch( e->type )
         {
         case NUMBER:
            return (* var_findnval( e->xvar, e->array_pos ));
         default:
            bwb_error( err_mismatch );
            return (bnumber) 0.0;
         }
      }

   /* must be a numerical value */

   if ( e->operation != NUMBER )
      {
#if PROG_ERRORS
      sprintf( bwb_ebuf, "in exp_getnval(): operation <%d> is not a number",
         e->operation );
      bwb_error( bwb_ebuf );
#else
      bwb_error( err_syntax );
#endif
      return (bnumber) 0.0;
      }

   /* return specific values */

   switch( e->type )
      {
      case NUMBER:
         return e->nval;
      default:
#if PROG_ERRORS
         sprintf( bwb_ebuf, "in exp_getnval(): type is <%c>",
            e->type );
         bwb_error( bwb_ebuf );
#else
         bwb_error( err_syntax );
#endif
         return (bnumber) 0.0;
      }

   }

/***************************************************************

	FUNCTION:       exp_getsval()

	DESCRIPTION:    This function returns a pointer to the
			BASIC string structure pointed to by
			expression-stack element 'e'.

***************************************************************/

#if ANSI_C
bstring *
exp_getsval( struct exp_ese *e )
#else
bstring *
exp_getsval( e )
   struct exp_ese *e;
#endif
   {
   static bstring b;
#if TEST_BSTRING
   static int init = FALSE;

   if ( init == FALSE )
      {
      sprintf( b.name, "<exp_getsval() bstring>" );
      }
#endif

   b.rab = FALSE;

   /* return based on operation type */

   switch( e->operation )
      {
      case CONST_STRING:
      case OP_STRJOIN:
         return &( e->sval );
      case VARIABLE:
        switch( e->type )
            {
	    case STRING:
               return var_findsval( e->xvar, e->array_pos );
            case NUMBER:
               sprintf( bwb_ebuf, "%lf ", (double) exp_getnval( e ) );
               str_ctob( &b, bwb_ebuf );
               return &b;
            default:
#if PROG_ERRORS
               sprintf( bwb_ebuf, "in exp_getsval(): type <%c> inappropriate for NUMBER",
                  e->type );
               bwb_error( bwb_ebuf );
#else
               bwb_error( err_syntax );
#endif
               return NULL;
            }
	 break;

      case NUMBER:
        switch( e->type )
            {
	    case NUMBER:
               sprintf( bwb_ebuf, "%lf ", (double) exp_getnval( e ) );
               str_ctob( &b, bwb_ebuf );
               return &b;
            default:
#if PROG_ERRORS
               sprintf( bwb_ebuf, "in exp_getsval(): type <%c> inappropriate for NUMBER",
                  e->type );
               bwb_error( bwb_ebuf );
#else
               bwb_error( err_syntax );
#endif
               return NULL;
            }
	 break;
      default:
#if PROG_ERRORS
         sprintf( bwb_ebuf, "in exp_getsval(): operation <%d> inappropriate",
            e->operation );
         bwb_error( bwb_ebuf );
#else
         bwb_error( err_syntax );
#endif
         return NULL;
      }

   /* this point may not be reached */

   return NULL;

   }

/***************************************************************

	FUNCTION:       inc_esc()

	DESCRIPTION:    This function increments the expression
			stack counter.

***************************************************************/

#if ANSI_C
int
inc_esc( void )
#else
int
inc_esc()
#endif
   {

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in inc_esc(): prev level <%d>",
      CURTASK expsc );
   bwb_debug ( bwb_ebuf );
#endif

   ++CURTASK expsc;
   if ( CURTASK expsc >= ESTACKSIZE )
      {
      --CURTASK expsc;
#if PROG_ERRORS
      sprintf( bwb_ebuf, "in inc_esc(): Maximum expression stack exceeded <%d>",
         CURTASK expsc );
      bwb_error( bwb_ebuf );
#else
      bwb_error( err_overflow );
#endif
      return OP_NULL;
      }

#if INTENSIVE_DEBUG
   sprintf( CURTASK exps[ CURTASK expsc ].string, "New Expression Stack Level %d", CURTASK expsc );
#endif

   CURTASK exps[ CURTASK expsc ].type = NUMBER;
   CURTASK exps[ CURTASK expsc ].operation = OP_NULL;
   CURTASK exps[ CURTASK expsc ].pos_adv = 0;

   return TRUE;
   }

/***************************************************************

	FUNCTION:       dec_esc()

	DESCRIPTION:    This function decrements the expression
			stack counter.

***************************************************************/

#if ANSI_C
int
dec_esc( void )
#else
int
dec_esc()
#endif
   {
   --CURTASK expsc;
   if ( CURTASK expsc < 0 )
      {
      CURTASK expsc = 0;
#if PROG_ERRORS
      sprintf( bwb_ebuf, "in dec_esc(): Expression stack counter < 0." );
      bwb_error( bwb_ebuf );
#else
      bwb_error( err_overflow );
#endif
      return OP_NULL;
      }

   return TRUE;
   }

