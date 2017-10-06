/****************************************************************

        bwb_exp.c       Expression Parser
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

int exp_esc = 0;                        /* expression stack counter */

/***************************************************************

        FUNCTION:   bwb_exp()

        DESCRIPTION:  This is the function by which the expression
        parser is called.

***************************************************************/

struct exp_ese *
bwb_exp( char *expression, int assignment, int *position )
   {
   struct exp_ese *rval;			/* return value */
   int entry_level, main_loop, adv_loop, err_condition;
   char *e;                                     /* pointer to current string */
   int r;                                       /* return value from functions */
   register int c;                              /* quick counter */

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_exp(): expression <%s> assignment <%d> level <%d>",
      & ( expression[ *position ] ), assignment, exp_esc );
   bwb_debug( bwb_ebuf );
   #endif

   /* save the entry level of the expression stack in order to
      check it at the end of this function */

   entry_level = exp_esc;
   err_condition = FALSE;

   /* advance past whitespace or beginningg of line segment */

   if ( expression[ *position ] == ':' )
      {
      ++( *position );
      }
   adv_ws( expression, position );
   if ( expression[ *position ] == ':' )
      {
      ++( *position );
      adv_ws( expression, position );
      }

   /* increment the expression stack counter to get a new level */

   inc_esc();

   /* check to be sure there is a legitimate expression
      and set initial parameters for the main loop */

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
            exp_es[ exp_esc ].pos_adv = 0;
            break;
         }
      }

   /* main parsing loop */

   while ( main_loop == TRUE )
      {

      /* set variable <e> to the start of the expression */

      e = &( expression[ *position ] );

      #if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_exp(): main loop, level <%d> element <%s> ",
         exp_esc, e );
      bwb_debug( bwb_ebuf );
      #endif

      /* detect the operation required at this level */

      exp_es[ exp_esc ].operation = exp_findop( e );

      #if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_exp(): exp_findop() returned <%d>",
         exp_es[ exp_esc ].operation );
      bwb_debug( bwb_ebuf );
      #endif

      /* perform actions specific to the operation */

      switch( exp_es[ exp_esc ].operation )
         {
         case OP_ERROR:
            main_loop = FALSE;
            err_condition = TRUE;
            break;
         case OP_TERMINATE:
            main_loop = FALSE;
            /* *position += 1; */
            dec_esc();
            break;
         case OP_STRJOIN:                  /* string join or tab */
         case OP_STRTAB:
            main_loop = FALSE;
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

            #if INTENSIVE_DEBUG
            sprintf( bwb_ebuf, "in bwb_exp(): operator detected." );
            bwb_debug( bwb_ebuf );
            #endif

            exp_es[ exp_esc ].pos_adv = -1;             /* set to strange number */

            /* cycle through operator table to find match */

            for ( c = 0; c < N_OPERATORS; ++c )
               {
               if ( exp_ops[ c ].operation == exp_es[ exp_esc ].operation )
                  {
                  exp_es[ exp_esc ].pos_adv = strlen( exp_ops[ c ].symbol );
                  }
               }

            if ( exp_es[ exp_esc ].pos_adv == -1 )      /* was a match found? */
               {
               exp_es[ exp_esc ].pos_adv = 0;           /* no -- set to 0 */
               }
            break;                         /* and move on */

         case OP_EQUALS:

            #if INTENSIVE_DEBUG
            sprintf( bwb_ebuf, "in bwb_exp(): equal sign detected." );
            bwb_debug( bwb_ebuf );
            #endif

            if ( assignment == TRUE )
               {
               exp_es[ exp_esc ].operation = OP_ASSIGN;
               }
            exp_es[ exp_esc ].pos_adv = 1;
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

         case VARIABLE:
            r = exp_variable( e );
            break;
         default:
            err_condition = TRUE;
            main_loop = FALSE;
            #if PROG_ERRORS
            sprintf( bwb_ebuf, "in bwb_exp.c:bwb_exp(): unidentified operation (%d).",
               exp_es[ exp_esc ].operation );
            bwb_error( bwb_ebuf );
            #else
            bwb_error( err_syntax );
            #endif
            break;
         }

      /* increment *position counter based on previous actions */

      *position += exp_es[ exp_esc ].pos_adv;
      exp_es[ exp_esc ].pos_adv = 0;            /* reset advance counter */

      #if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_exp(): advanced position; r <%d> err_c <%d>",
         r, err_condition );
      bwb_debug( bwb_ebuf );
      #endif

      #if INTENSIVE_DEBUG
      if ( exp_es[ exp_esc ].operation == OP_EQUALS )
         {
         sprintf( bwb_ebuf, "in bwb_exp(): with OP_EQUALS: finished case" );
         bwb_debug( bwb_ebuf );
         }
      #endif

      /* check for end of string */

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
      sprintf( bwb_ebuf, "ERROR: error detected in expression parser" );
      bwb_debug( bwb_ebuf );
      #endif

      /* decrement the expression stack counter until it matches entry_level */

      while( exp_esc > entry_level )
         {
         dec_esc();
         }

      }

   /* no error; normal exit from function */

   else
      {

      /* are any more operations needed? if we are still at entry level,
         then they are not */

      /* try operations */

      exp_operation( entry_level );

      /* see what is on top of the stack */

      if ( exp_esc > ( entry_level + 1 ))
         {
         switch( exp_es[ exp_esc ].operation )
            {
            case OP_STRJOIN:
               if ( exp_esc != ( entry_level + 2 ))
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
            exp_es[ exp_esc ].type );
         bwb_debug( bwb_ebuf );
         #endif

         dec_esc();

         }

      /* assign rvar to the variable for the current level */

      rval = &( exp_es[ exp_esc ] );

      /* decrement the expression stack counter */

      dec_esc();

      /* check the current level before exit */

      if ( entry_level != exp_esc )
         {
         #if PROG_ERRORS
         sprintf( bwb_ebuf, "in bwb_exp(): exit stack level (%d) does not match entry stack level (%d)",
            exp_esc, entry_level );
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

        FUNCTION:   exp_findop()

        DESCRIPTION:  This function reads the expression to find
        what operation is required at its stack level.

***************************************************************/

int
exp_findop( char *expression )
   {
   char *pointer;                               /* pointer to start of string */
   register int c;                              /* character counter */
   int carry_on;                                /* boolean: control while loop */
   int rval;                                    /* return value */
   char tbuf[ MAXSTRINGSIZE + 1 ];

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in exp_findop(): received <%s>", expression );
   bwb_debug( bwb_ebuf );
   #endif

   /* set return value to OP_NULL initially */

   rval = OP_NULL;

   /* assign local pointer to expression to begin reading */

   pointer = expression;

   /* advance to the first significant character */

   carry_on = TRUE;
   while ( carry_on == TRUE )
      {
      switch( *pointer )
         {
         case ' ':                              /* whitespace */
         case '\t':
            ++pointer;                          /* increment the pointer */
            break;                              /* and move on */
         default:
            carry_on = FALSE;                   /* break out of while loop */
            break;
         }
      }

   /* we now have the first significant character and can begin parsing */

   /* check the first character for an indication of a parenthetical
      expression, a string constant, or a numerical constant that begins
      with a digit (numerical constants beginning with a plus or minus
      sign or hex/octal/binary constants will have to be detected by
      exp_isnc() */

   carry_on = TRUE;
   switch ( *pointer )
      {
      case '\"':                /* this should indicate a string constant */
         rval = CONST_STRING;
         break;
      case '(':                 /* this will indicate a simple parenthetical expression */
         rval = PARENTHESIS;
         break;
      case ':':                 /* terminate processing */
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

   /* string constants, numerical constants, open parentheses, and
      the plus and minus operators have been checked at this point;
      but if the return value is still OP_NULL, other possibilities
      must be checked, namely, other operators, function names, and
      variable names */

   /* get a character string to be interpreted */

   if ( rval == OP_NULL )
      {

      carry_on = TRUE;
      c = 0;
      tbuf[ c ] = *pointer;
      ++c;
      tbuf[ c ] = '\0';
      while( carry_on == TRUE )
         {
         switch( pointer[ c ] )
            {
            case ' ':                           /* whitespace */
            case '\t':
            case '(':
            case ')':
            case ',':
            case ';':
            case '\0':
            case '\n':
            case '\r':
               carry_on = FALSE;
               break;
            default:
               tbuf[ c ] = pointer[ c ];
               ++c;
               tbuf[ c ] = '\0';
               break;
            }
         }

      }

   /* check for a BASIC command */

   if ( rval == OP_NULL )
      {
      rval = exp_iscmd( tbuf );
      }

   /* check for numerical constant */

   if ( rval == OP_NULL )
      {
      rval = exp_isnc( tbuf );
      }

   /* check for other operators */

   if ( rval == OP_NULL )
      {
      rval = exp_isop( tbuf );
      }

   /* check for function name */

   if ( rval == OP_NULL )
      {
      rval = exp_isfn( tbuf );
      }

   /* last: check for variable name, and assign it if there
      is not already one */

   if ( rval == OP_NULL )
      {
      rval = exp_isvn( tbuf );
      }

   /* return the value assigned (or OP_NULL if none assigned) */

   return rval;

   }

/***************************************************************

        FUNCTION:   exp_isnc()

        DESCRIPTION:  This function reads the expression to find
        if a logical or mathematical operation is required at
        this point.

***************************************************************/

int
exp_isnc( char *expression )
   {

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

         if (  ( exp_es[ exp_esc - 1 ].operation == NUMBER )
            || ( exp_es[ exp_esc - 1 ].operation == VARIABLE )
            || ( exp_es[ exp_esc - 1 ].operation == CONST_STRING ) )
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

         if ( ( exp_es[ exp_esc - 1 ].operation == VARIABLE )
            && ( exp_es[ exp_esc - 1 ].type != STRING ))
            {
            return OP_NULL;
            }

         /* failing these tests, the argument must be a numerical
            constant preceded by a plus or minus sign */

         return CONST_NUMERICAL;

      default:
         return OP_NULL;
      }

   }

/***************************************************************

        FUNCTION:   exp_isop()

        DESCRIPTION:  This function reads the expression to find
        if a logical or mathematical operation is required at
        this point.

        This function presupposes that a numerical constant with
        affixed plus or minus sign has been ruled out.

***************************************************************/

int
exp_isop( char *expression )
   {
   register int c;                              /* counter */
   char tbuf[ MAXSTRINGSIZE + 1 ];

   /* first convert the expression to upper-case so that comparisons
      will work */

   for ( c = 0; expression[ c ] != '\0'; ++c )
      {
      if ( islower( expression[ c ] ))
         {
         tbuf[ c ] = toupper( expression[ c ] );
         }
      else
         {
         tbuf[ c ] = expression[ c ];
         }
      tbuf[ c + 1 ] = '\0';
      }

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in exp_isop(): expression is <%s>", tbuf );
   bwb_debug( bwb_ebuf );
   #endif

   /* compare the initial characters of the string with the table
      of operators */

   for ( c = 0; c < N_OPERATORS; ++c )
      {
      if ( strncmp( tbuf, exp_ops[ c ].symbol,
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

        FUNCTION:   exp_iscmd()

        DESCRIPTION:  This function reads the expression to find
        if a BASIC command name is present; if so, it returns
        OP_TERMINATE to terminate expression parsing.  This is
        critical, for example, in parsing a conditional following
        IF where THEN, ELSE, and other BASIC commands may follow.

***************************************************************/

int
exp_iscmd( char *expression )
   {
   register int n;
   char tbuf[ MAXSTRINGSIZE + 1 ];

   /* capitalize the expression */

   for ( n = 0; expression[ n ] != '\0'; ++n )
      {
      if ( n >= MAXARGSIZE )
         {
         #if PROG_ERRORS
         sprintf( bwb_ebuf, "Maximum arguments size exceeded." );
         bwb_error( bwb_ebuf );
         #else
         bwb_error( err_overflow );
         #endif
         }
      if ( islower( expression[ n ] ) != FALSE )
         {
         tbuf[ n ] = toupper( expression[ n ] );
         }
      else
         {
         tbuf[ n ] = expression[ n ];
         }
      tbuf[ n + 1 ] = '\0';
      }

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in exp_iscmd(): expression received <%s>, converted <%s>.",
      expression, tbuf );
   bwb_debug( bwb_ebuf );
   #endif

   /* first check for THEN or ELSE statements */

   if ( strcmp( tbuf, "THEN" ) == 0 )
      {
      #if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in exp_iscmd(): match found, <%s>",
         tbuf );
      bwb_debug( bwb_ebuf );
      #endif
      return OP_TERMINATE;
      }

   if ( strcmp( tbuf, "ELSE" ) == 0 )
      {
      #if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in exp_iscmd(): match found, <%s>",
         tbuf );
      bwb_debug( bwb_ebuf );
      #endif
      return OP_TERMINATE;
      }

   /* run through the command table and search for a match */

   for ( n = 0; n < COMMANDS; ++n )
      {
      if ( strcmp( tbuf, bwb_cmdtable[ n ].name ) == 0 )
         {
         #if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in exp_iscmd(): match found, <%s>",
            tbuf );
         bwb_debug( bwb_ebuf );
         #endif
         return OP_TERMINATE;
         }
      #if INTENSIVE_DEBUG
      else
         {
         sprintf( bwb_ebuf, "in exp_iscmd(): No match, <%s> and <%s>; returns %d",
            tbuf, bwb_cmdtable[ n ].name,
            strcmp( tbuf, bwb_cmdtable[ n ].name ) );
         bwb_debug( bwb_ebuf );
         }
      #endif
      }

   /* search failed, return NULL */

   return OP_NULL;

   }

/***************************************************************

        FUNCTION:   exp_isfn()

        DESCRIPTION:  This function reads the expression to find
        if a function name is present at this point.

***************************************************************/

int
exp_isfn( char *expression )
   {

   if ( fnc_find( expression ) == NULL )
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

        FUNCTION:   exp_isvn()

        DESCRIPTION:  This function reads the expression to find
        if a variable name at this point.

***************************************************************/

int
exp_isvn( char *expression )
   {

   exp_getvfname( expression, exp_es[ exp_esc ].string );

   if ( var_find( exp_es[ exp_esc ].string ) == NULL )
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
         exp_es[ exp_esc ].string );
      bwb_debug( bwb_ebuf );
      #endif
      return VARIABLE;
      }

   }

/***************************************************************

        FUNCTION:   exp_getvfname()

        DESCRIPTION:  This function reads the expression to find
        a variable or function name at this point.

***************************************************************/

int
exp_getvfname( char *source, char *destination )
   {
   int s_pos, d_pos;                    /* source, destination positions */

   s_pos = d_pos = 0;
   destination[ 0 ] = '\0';
   while( source[ s_pos ] != '\0' )
      {

      /* all aphabetical characters are acceptable */

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
            case SINGLE:
            case DOUBLE:
            case INTEGER:
               destination[ d_pos ] = source[ s_pos ];
               ++d_pos;
               ++s_pos;
               destination[ d_pos ] = '\0';

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

        FUNCTION:   exp_validarg()

        DESCRIPTION:  This function reads the expression to
        determine whether it is a valid argument (to be
        read recursively by bwb_exp() and passed to a
        function.

***************************************************************/

int
exp_validarg( char *expression )
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

        FUNCTION:   exp_getdval()

        DESCRIPTION:

***************************************************************/

double
exp_getdval( struct exp_ese *e )
   {

   /* check for variable */

   if ( e->operation == VARIABLE )
      {
      switch( e->type )
         {
         case DOUBLE:
            return (* var_finddval( e->xvar, e->array_pos ));
         case SINGLE:
            return (double) (* var_findfval( e->xvar, e->array_pos ));
         case INTEGER:
            return (double) (* var_findival( e->xvar, e->array_pos ));
         default:
            bwb_error( err_mismatch );
            return (double) 0.0;
         }
      }

   /* must be a numerical value */

   if ( e->operation != NUMBER )
      {
      #if PROG_ERRORS
      sprintf( bwb_ebuf, "in exp_getdval(): operation <%d> is not a number",
         e->operation );
      bwb_error( bwb_ebuf );
      #else
      bwb_error( err_syntax );
      #endif
      return (double) 0.0;
      }

   /* return specific values */

   switch( e->type )
      {
      case SINGLE:
         return (double) e->fval;
      case INTEGER:
         return (double) e->ival;
      case DOUBLE:
         return e->dval;
      default:
         #if PROG_ERRORS
         sprintf( bwb_ebuf, "in exp_getdval(): type is <%c>",
            e->type );
         bwb_error( bwb_ebuf );
         #else
         bwb_error( err_syntax );
         #endif
         return (double) 0.0;
      }

   }

/***************************************************************

        FUNCTION:   exp_getfval()

        DESCRIPTION:

***************************************************************/

float
exp_getfval( struct exp_ese *e )
   {

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in exp_getfval(): entry" );
   bwb_debug( bwb_ebuf );
   #endif

   /* check for variable */

   if ( e->operation == VARIABLE )
      {
      #if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in exp_getfval(): returning variable" );
      bwb_debug( bwb_ebuf );
      #endif

      switch( e->type )
         {
         case DOUBLE:
            return (float) (* var_finddval( e->xvar, e->array_pos ));
         case SINGLE:
            return (* var_findfval( e->xvar, e->array_pos ));
         case INTEGER:
            return (float) (* var_findival( e->xvar, e->array_pos ));
         default:
            bwb_error( err_mismatch );
            return (float) 0.0;
         }
      }

   /* must be a numerical value */

   if ( e->operation != NUMBER )
      {
      #if PROG_ERRORS
      sprintf( bwb_ebuf, "in exp_getfval(): operation <%d> is not a number",
         e->operation );
      bwb_error( bwb_ebuf );
      #else
      bwb_error( err_syntax );
      #endif
      return (float) 0.0;
      }

   /* return specific values */

   switch( e->type )
      {
      case SINGLE:
         #if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in exp_getfval(): returning from SINGLE, val <%f>",
            e->fval );
         bwb_debug( bwb_ebuf );
         #endif
         return e->fval;
      case INTEGER:
         #if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in exp_getfval(): returning from INTEGER, val <%d>",
            e->ival );
         bwb_debug( bwb_ebuf );
         #endif
         return (float) e->ival;
      case DOUBLE:
         #if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in exp_getfval(): returning from DOUBLE, val <%lf>",
            e->dval );
         bwb_debug( bwb_ebuf );
         #endif
         return (float) e->dval;
      default:
         #if PROG_ERRORS
         sprintf( bwb_ebuf, "in exp_getfval(): type is <%c>",
            e->type );
         bwb_error( bwb_ebuf );
         #else
         bwb_error( err_syntax );
         #endif
         return (float) 0.0;
      }

   }

/***************************************************************

        FUNCTION:   exp_getival()

        DESCRIPTION:

***************************************************************/

int
exp_getival( struct exp_ese *e )
   {

   /* check for variable */

   if ( e->operation == VARIABLE )
      {
      switch( e->type )
         {
         case DOUBLE:
            return (int) (* var_finddval( e->xvar, e->array_pos ));
         case SINGLE:
            return (int) (* var_findfval( e->xvar, e->array_pos ));
         case INTEGER:
            return (* var_findival( e->xvar, e->array_pos ));
         default:
            bwb_error( err_mismatch );
            return 0;
         }
      }

   /* must be a numerical value */

   if ( e->operation != NUMBER )
      {
      #if PROG_ERRORS
      sprintf( bwb_ebuf, "in exp_getival(): operation <%d> is not a number",
         e->operation );
      bwb_error( bwb_ebuf );
      #else
      bwb_error( err_syntax );
      #endif
      return 0;
      }

   /* return specific values */

   switch( e->type )
      {
      case SINGLE:
         return (int) e->fval;
      case INTEGER:
         return e->ival;
      case DOUBLE:
         return (int) e->dval;
      default:
         #if PROG_ERRORS
         sprintf( bwb_ebuf, "in exp_getival(): type is <%c>",
            e->type );
         bwb_error( bwb_ebuf );
         #else
         bwb_error( err_syntax );
         #endif
         return 0;
      }

   }

/***************************************************************

        FUNCTION:   exp_getsval()

        DESCRIPTION:

***************************************************************/

bstring *
exp_getsval( struct exp_ese *e )
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
            case DOUBLE:
               sprintf( bwb_ebuf, "%lf ", exp_getdval( e ) );
               str_ctob( &b, bwb_ebuf );
               return &b;
            case SINGLE:
               sprintf( bwb_ebuf, "%f ", exp_getfval( e ) );
               str_ctob( &b, bwb_ebuf );
               return &b;
            case INTEGER:
               sprintf( bwb_ebuf, "%d ", exp_getival( e ) );
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
	    case DOUBLE:
               sprintf( bwb_ebuf, "%lf ", exp_getdval( e ) );
               str_ctob( &b, bwb_ebuf );
               return &b;
            case SINGLE:
               sprintf( bwb_ebuf, "%f ", exp_getfval( e ) );
               str_ctob( &b, bwb_ebuf );
               return &b;
            case INTEGER:
               sprintf( bwb_ebuf, "%d ", exp_getival( e ) );
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

        FUNCTION:   exp_findfval()

        DESCRIPTION:

***************************************************************/

#ifdef NO_LONGER_IMPLEMENTED
float *
exp_findfval( struct exp_ese *e )
   {

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in exp_findfval(): entry" );
   bwb_debug( bwb_ebuf );
   #endif

   /* check for variable */

   if ( e->operation == VARIABLE )
      {
      #if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in exp_getfval(): returning variable" );
      bwb_debug( bwb_ebuf );
      #endif
      return var_findfval( e->xvar, e->xvar->array_pos );
      }

   /* must be a numerical value */

   if ( ( e->operation != NUMBER ) && ( e->type != SINGLE ))
      {
      #if PROG_ERRORS
      sprintf( bwb_ebuf, "in exp_findfval(): operation is not a single-precision number" );
      bwb_error( bwb_ebuf );
      #else
      bwb_error( err_syntax );
      #endif
      return NULL;
      }

   /* return specific value */

   return &( e->fval );

   }

/***************************************************************

        FUNCTION:   exp_finddval()

        DESCRIPTION:

***************************************************************/

double *
exp_finddval( struct exp_ese *e )
   {

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in exp_finddval(): entry" );
   bwb_debug( bwb_ebuf );
   #endif

   /* check for variable */

   if ( e->operation == VARIABLE )
      {
      #if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in exp_getdval(): returning variable" );
      bwb_debug( bwb_ebuf );
      #endif
      return var_finddval( e->xvar, e->xvar->array_pos );
      }

   /* must be a numerical value */

   if ( ( e->operation != NUMBER ) && ( e->type != SINGLE ))
      {
      #if PROG_ERRORS
      sprintf( bwb_ebuf, "in exp_finddval(): operation is not a double-precision number" );
      bwb_error( bwb_ebuf );
      #else
      bwb_error( err_syntax );
      #endif
      return NULL;
      }

   /* return specific value */

   return &( e->dval );

   }

/***************************************************************

        FUNCTION:   exp_findival()

        DESCRIPTION:

***************************************************************/

int *
exp_findival( struct exp_ese *e )
   {

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in exp_findival(): entry" );
   bwb_debug( bwb_ebuf );
   #endif

   /* check for variable */

   if ( e->operation == VARIABLE )
      {
      #if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in exp_getival(): returning variable" );
      bwb_debug( bwb_ebuf );
      #endif
      return var_findival( e->xvar, e->xvar->array_pos );
      }

   /* must be a numerical value */

   if ( ( e->operation != NUMBER ) && ( e->type != SINGLE ))
      {
      #if PROG_ERRORS
      sprintf( bwb_ebuf, "in exp_findival(): operation is not an integer number" );
      bwb_error( bwb_ebuf );
      #else
      bwb_error( err_syntax );
      #endif
      return NULL;
      }

   /* return specific value */

   return &( e->ival );

   }
#endif

/***************************************************************

        FUNCTION:   inc_esc()

        DESCRIPTION:  This function increments the expression
        stack counter.

***************************************************************/

int
inc_esc( void )
   {

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in inc_esc(): prev level <%d>",
      exp_esc );
   bwb_debug ( bwb_ebuf );
   #endif

   ++exp_esc;
   if ( exp_esc >= ESTACKSIZE )
      {
      --exp_esc;
      #if PROG_ERRORS
      sprintf( bwb_ebuf, "in inc_esc(): Maximum expression stack exceeded <%d>",
         exp_esc );
      bwb_error( bwb_ebuf );
      #else
      bwb_error( err_overflow );
      #endif
      return OP_NULL;
      }

   #if INTENSIVE_DEBUG
   sprintf( exp_es[ exp_esc ].string, "New Expression Stack Level %d", exp_esc );
   #endif

   exp_es[ exp_esc ].type = INTEGER;
   exp_es[ exp_esc ].operation = OP_NULL;
   exp_es[ exp_esc ].pos_adv = 0;

   return TRUE;
   }

/***************************************************************

        FUNCTION:   dec_esc()

        DESCRIPTION:  This function decrements the expression
        stack counter.

***************************************************************/

int
dec_esc( void )
   {
   --exp_esc;
   if ( exp_esc < 0 )
      {
      exp_esc = 0;
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
