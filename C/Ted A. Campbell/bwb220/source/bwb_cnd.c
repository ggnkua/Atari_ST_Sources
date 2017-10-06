/***************************************************************

        bwb_cnd.c       Conditional Expressions and Commands
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
/*                                                               */
/* Those additionally marked with "DD" were at the suggestion of */
/* Dale DePriest (daled@cadence.com).                            */
/*---------------------------------------------------------------*/

#include <stdio.h>
#include <math.h>
#include <ctype.h>

#include "bwbasic.h"
#include "bwb_mes.h"

/* declarations of functions visible to this file only */

#if ANSI_C
static int cnd_thenels( char *buffer, int position, int *then, int *els );
static int cnd_tostep( char *buffer, int position, int *to, int *step );
static struct bwb_line *find_wend( struct bwb_line *l );
static struct bwb_line *find_endif( struct bwb_line *l,
   struct bwb_line **else_line );
static int is_endif( struct bwb_line *l );
extern int var_setnval( struct bwb_variable *v, bnumber i );
static int case_eval( struct exp_ese *expression, struct exp_ese *minval,
   struct exp_ese *maxval );
static struct bwb_line *find_case( struct bwb_line *l );
static struct bwb_line *find_endselect( struct bwb_line *l );
static int is_endselect( struct bwb_line *l );
static struct bwb_line *bwb_caseif( struct bwb_line *l );

#if STRUCT_CMDS
static struct bwb_line *find_next( struct bwb_line *l );
#endif

#else
static int cnd_thenels();
static int cnd_tostep();
static struct bwb_line *find_wend();
static struct bwb_line *find_endif();
static int is_endif();
extern int var_setnval();
static int case_eval();
static struct bwb_line *find_case();
static struct bwb_line *find_endselect();
static int is_endselect();
static struct bwb_line *bwb_caseif();

#if STRUCT_CMDS
static struct bwb_line *find_next();
#endif

#endif                          /* ANSI_C for prototypes */

/***    IF-THEN-ELSE ***/

/***************************************************************

        FUNCTION:       bwb_if()

        DESCRIPTION:    This function handles the BASIC IF
                        statement.

   	SYNTAX:		IF expression THEN [statement [ELSE statement]]

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_if( struct bwb_line *l )
#else
struct bwb_line *
bwb_if( l )
   struct bwb_line *l;
#endif
   {
   int then, els;
   struct exp_ese *e;
   int glnumber;
   int tpos;
   static char tbuf[ MAXSTRINGSIZE + 1 ];
   static struct bwb_line gline;
#if STRUCT_CMDS
   static struct bwb_line *else_line;
   static struct bwb_line *endif_line;
#endif

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_if(): entry, line <%d> buffer <%s>",
      l->number, &( l->buffer[ l->position ] ) );
   bwb_debug( bwb_ebuf );
   getchar();
#endif

#if INTENSIVE_DEBUG
   if ( l == &gline )
      {
      sprintf( bwb_ebuf, "in bwb_if(): recursive call, l = &gline" );
      bwb_debug( bwb_ebuf );
      }
#endif

   /* Call bwb_exp() to evaluate the condition. This should return
      with position set to the "THEN" statement */

   e = bwb_exp( l->buffer, FALSE, &( l->position ) );

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_if(): line <%d> condition returns <%d>",
      l->number, exp_getnval( e ) );
   bwb_debug( bwb_ebuf );
#endif

   /* test for "THEN" and "ELSE" statements */

   cnd_thenels( l->buffer, l->position, &then, &els );

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_if(): return from cnd_thenelse, line is <%s>",
      l->buffer );
   bwb_debug( bwb_ebuf );
#endif

   /* test for multiline IF statement: this presupposes ANSI-compliant
      structured BASIC */

#if STRUCT_CMDS
   tpos = then + strlen( CMD_THEN ) + 1;
   if ( is_eol( l->buffer, &tpos ) == TRUE )
      {

#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_if(): found multi-line IF statement, line <%d>",
         l->number );
      bwb_debug( bwb_ebuf );
#endif

      /* find END IF and possibly ELSE[IF] line(s) */

      else_line = NULL;
      endif_line = find_endif( l, &else_line );

      /* evaluate the expression */

      if ( (int) exp_getnval( e ) != FALSE )
         {
         bwb_incexec();
         bwb_setexec( l->next, 0, EXEC_IFTRUE );

#if MULTISEG_LINES
         adv_eos( l->buffer, &( l->position ));
#endif
         return bwb_zline( l );
         }

      else if ( else_line != NULL )
         {
         bwb_incexec();
         bwb_setexec( else_line, 0, EXEC_IFFALSE );
         else_line->position = 0;
         return else_line;
         }
      else
         {
         /* Following line incorrect, replaced by next two (bug found by DD) */
         /* bwb_setexec( endif_line, 0, CURTASK excs[ CURTASK exsc ].code ); */

         bwb_incexec(); /* JBV */
         bwb_setexec( endif_line, 0, EXEC_IFFALSE ); /* JBV */
         endif_line->position = 0;
         return endif_line;
         }
      }

#endif			/* STRUCT_CMDS for Multi-line IF...THEN */

   /* Not a Multi-line IF...THEN: test for THEN line-number */

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_if(): not multi-line; line is <%s>",
      l->buffer );
   bwb_debug( bwb_ebuf );
#endif

   /* evaluate and execute */

   if ( (int) exp_getnval( e ) != FALSE )
      {

#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_if(): expression is TRUE" );
      bwb_debug( bwb_ebuf );
#endif

      if ( then == FALSE )
         {
#if PROG_ERRORS
	 sprintf( bwb_ebuf, "in bwb_if(): IF without THEN" );
         bwb_error( bwb_ebuf );
#else
         bwb_error( err_syntax );
#endif
         }
      else
         {

	 /* check for THEN followed by literal line number */

	 tpos = then + strlen( CMD_THEN ) + 1;
	 adv_element( l->buffer, &tpos, tbuf );

	 if ( isdigit( tbuf[ 0 ] ) != 0 )
	    {

	    glnumber = atoi( tbuf );

#if INTENSIVE_DEBUG
	    sprintf( bwb_ebuf, "Detected THEN followed by line number <%d>",
	       glnumber );
	    bwb_debug( bwb_ebuf );
#endif

	    sprintf( tbuf, "%s %d", CMD_GOTO, glnumber );
	    gline.buffer = tbuf;
	    gline.marked = FALSE;
	    gline.position = 0;
	    gline.next = l->next;
	    bwb_setexec( &gline, 0, CURTASK excs[ CURTASK exsc ].code );
	    return &gline;
	    }

	 /* form is not THEN followed by line number */

	 else
	    {
	    bwb_setexec( l, then, CURTASK excs[ CURTASK exsc ].code );
	    l->position = then + strlen( CMD_THEN ) + 1;
	    }

	 return l;
	 }
      }
   else
      {

#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_if(): expression is FALSE" );
      bwb_debug( bwb_ebuf );
#endif

      if ( els != FALSE )
         {
         l->position = els + strlen( CMD_ELSE ) + 1;
         /* bwb_setexec( l, els, EXEC_NORM ); */ /* Nope (JBV) */
         bwb_setexec( l, els, CURTASK excs[ CURTASK exsc ].code ); /* JBV */
	 return l;
	 }
      }

   /* if neither then nor else were found, advance to next line */
   /* DO NOT advance to next segment (only if TRUE should we do that) */

   l->next->position = 0;
   return l->next;

   }

/***************************************************************

        FUNCTION:       cnd_thenelse()

        DESCRIPTION:    This function searches through the
                        <buffer> beginning at point <position>
                        and attempts to find positions of THEN
                        and ELSE statements.

***************************************************************/

#if ANSI_C
static int
cnd_thenels( char *buffer, int position, int *then, int *els )
#else
static int
cnd_thenels( buffer, position, then, els )
   char *buffer;
   int position;
   int *then;
   int *els;
#endif
   {
   int loop, t_pos, b_pos, p_word;
   char tbuf[ MAXSTRINGSIZE + 1 ];

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in cnd_thenels(): entry, line is <%s>",
      &( buffer[ position ] ) );
   bwb_debug( bwb_ebuf );
#endif

   /* set then and els to 0 initially */

   *then = *els = 0;

   /* loop to find words */

   p_word = b_pos = position;
   t_pos = 0;
   tbuf[ 0 ] = '\0';
   loop = TRUE;
   while( loop == TRUE )
      {

      switch( buffer[ b_pos ] )
         {
         case '\0':                     /* end of string */
         case ' ':                      /* whitespace = end of word */
         case '\t':

#if INTENSIVE_DEBUG
            sprintf( bwb_ebuf, "in cnd_thenels(): word is <%s>", tbuf );
            bwb_debug( bwb_ebuf );
#endif

            if ( strncmp( tbuf, CMD_THEN, (size_t) strlen( CMD_THEN ) ) == 0 )
               {

#if INTENSIVE_DEBUG
               sprintf( bwb_ebuf, "in cnd_thenels(): THEN found at position <%d>.",
                  p_word );
               bwb_debug( bwb_ebuf );
               sprintf( bwb_ebuf, "in cnd_thenelse(): after THEN, line is <%s>", buffer );
               bwb_debug( bwb_ebuf );
#endif

               *then = p_word;
               }
            else if ( strncmp( tbuf, CMD_ELSE, (size_t) strlen( CMD_ELSE ) ) == 0 )
               {

#if INTENSIVE_DEBUG
               sprintf( bwb_ebuf, "in cnd_thenels(): ELSE found at position <%d>.",
                  p_word );
               bwb_debug( bwb_ebuf );
               sprintf( bwb_ebuf, "in cnd_thenelse(): after ELSE, line is <%s>", buffer );
               bwb_debug( bwb_ebuf );
#endif

               *els = p_word;
               }

            /* check for end of the line */

            if ( buffer[ b_pos ] == '\0' )
               {
#if INTENSIVE_DEBUG
               sprintf( bwb_ebuf, "in cnd_thenels(): return: end of string" );
               bwb_debug( bwb_ebuf );
#endif
               return TRUE;
               }

            ++b_pos;
            p_word = b_pos;
            t_pos = 0;
            tbuf[ 0 ] = '\0';
            break;

         default:
            if ( islower( buffer[ b_pos ] ) != FALSE )
               {
               tbuf[ t_pos ] = (char) toupper( buffer[ b_pos ] );
               }
            else
               {
               tbuf[ t_pos ] = buffer[ b_pos ];
               }
            ++b_pos;
            ++t_pos;
            tbuf[ t_pos ] = '\0';
            break;
         }

      }

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in cnd_thenelse(): exit, line is <%s>", buffer );
   bwb_debug( bwb_ebuf );
#endif

   return FALSE;

   }

#if STRUCT_CMDS

/***************************************************************

        FUNCTION:       bwb_else()

        DESCRIPTION:    This function handles the BASIC ELSE
                        statement.

   	SYNTAX:		ELSE

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_else( struct bwb_line *l )
#else
struct bwb_line *
bwb_else( l )
   struct bwb_line *l;
#endif
   {
   struct bwb_line *endif_line;
   struct bwb_line *else_line;

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_else(): entered function" );
   bwb_debug( bwb_ebuf );
#endif

   /* If the code is EXEC_NORM, then this is a continuation of a single-
      line IF...THEN...ELSE... statement and we should return */

   /*----------------------------------------------------------------------*/
   /* Well, not really... better to check for EXEC_IFTRUE or EXEC_IFFALSE, */
   /* and if not equal, then blow entirely out of current line (JBV)       */
   /*----------------------------------------------------------------------*/

   /* Section removed by JBV */
   /* if ( CURTASK excs[ CURTASK exsc ].code == EXEC_NORM )
      {

#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_else(): detected EXEC_NORM" );
      bwb_debug( bwb_ebuf );
#endif

      return bwb_zline( l );
      } */

   /* Section added by JBV */
   if (( CURTASK excs[ CURTASK exsc ].code != EXEC_IFTRUE ) &&
   ( CURTASK excs[ CURTASK exsc ].code != EXEC_IFFALSE ))
      {

#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_else(): no EXEC_IFTRUE or EXEC_IFFALSE" );
      bwb_debug( bwb_ebuf );
#endif

      l->next->position = 0;
      return l->next;
      }

   endif_line = find_endif( l, &else_line );

   if ( CURTASK excs[ CURTASK exsc ].code == EXEC_IFTRUE )
      {
      endif_line->position = 0;
      return endif_line;
      }
   else if ( CURTASK excs[ CURTASK exsc ].code == EXEC_IFFALSE )
      {

      return bwb_zline( l );
      }

#if PROG_ERRORS
   sprintf( bwb_ebuf, "in bwb_else(): ELSE without IF" );
   bwb_error( bwb_ebuf );
#else
   bwb_error( err_syntax );
#endif


   return bwb_zline( l );
   }

/***************************************************************

        FUNCTION:       bwb_elseif()

        DESCRIPTION:    This function handles the BASIC ELSEIF
                        statement.

	SYNTAX:		ELSEIF

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_elseif( struct bwb_line *l )
#else
struct bwb_line *
bwb_elseif( l )
   struct bwb_line *l;
#endif
   {
   struct bwb_line *endif_line;
   struct bwb_line *else_line;
   struct exp_ese *e;

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_elseif(): entered function" );
   bwb_debug( bwb_ebuf );
#endif

   else_line = NULL;
   endif_line = find_endif( l, &else_line );

   if ( CURTASK excs[ CURTASK exsc ].code == EXEC_IFTRUE )
      {
      endif_line->position = 0;
      return endif_line;
      }

   else if ( CURTASK excs[ CURTASK exsc ].code == EXEC_IFFALSE )
      {

      /* Call bwb_exp() to evaluate the condition. This should return
         with position set to the "THEN" statement */

      e = bwb_exp( l->buffer, FALSE, &( l->position ) );

      if ( (int) exp_getnval( e ) != FALSE ) /* Was == TRUE (JBV 10/1996) */
         {

         /* ELSEIF condition is TRUE: proceed to the next line */

         CURTASK excs[ CURTASK exsc ].code = EXEC_IFTRUE;

#if MULTISEG_LINES
         adv_eos( l->buffer, &( l->position ));
#endif
         return bwb_zline( l );

         }

      /* ELSEIF condition FALSE: proceed to next ELSE line if there is one */

      else if ( else_line != NULL )
         {
         bwb_setexec( else_line, 0, EXEC_IFFALSE );
         else_line->position = 0;
         return else_line;
         }

      /* ELSEIF condition is FALSE and no more ELSExx lines: proceed to END IF */

      else
         {
         bwb_setexec( endif_line, 0, CURTASK excs[ CURTASK exsc ].code );
         endif_line->position = 0;
         return endif_line;
         }

      }

#if PROG_ERRORS
   sprintf( bwb_ebuf, "in bwb_elseif(): ELSEIF without IF" );
   bwb_error( bwb_ebuf );
#else
   bwb_error( err_syntax );
#endif


#if MULTISEG_LINES
   adv_eos( l->buffer, &( l->position ));
#endif
   return bwb_zline( l );

   }

/***************************************************************

        FUNCTION:       bwb_endif()

        DESCRIPTION:    This function handles the BASIC END IF
                        statement.

	SYNTAX:		END IF

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_endif( struct bwb_line *l )
#else
struct bwb_line *
bwb_endif( l )
   struct bwb_line *l;
#endif
   {

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_endif(): entered function" );
   bwb_debug( bwb_ebuf );
#endif

   if (( CURTASK excs[ CURTASK exsc ].code != EXEC_IFTRUE )
      && ( CURTASK excs[ CURTASK exsc ].code != EXEC_IFFALSE ))
      {
#if PROG_ERRORS
      sprintf( bwb_ebuf, "in bwb_endif(): END IF without IF" );
      bwb_error( bwb_ebuf );
#else
      bwb_error( err_syntax );
#endif
      }

   bwb_decexec();


#if MULTISEG_LINES
   adv_eos( l->buffer, &( l->position ));
#endif
   return bwb_zline( l );
   }

/***************************************************************

        FUNCTION:       find_endif()

        DESCRIPTION:    This C function attempts to find an
			END IF statement.

***************************************************************/

#if ANSI_C
static struct bwb_line *
find_endif( struct bwb_line *l, struct bwb_line **else_line )
#else
static struct bwb_line *
find_endif( l, else_line )
   struct bwb_line *l;
   struct bwb_line **else_line;
#endif
   {
   struct bwb_line *current;
   register int i_level;
   int position;

   *else_line = NULL;
   i_level = 1;
   for ( current = l->next; current != &CURTASK bwb_end; current = current->next )
      {
      position = 0;
      if ( current->marked != TRUE )
         {
         line_start( current->buffer, &position, &( current->lnpos ),
            &( current->lnum ),
            &( current->cmdpos ),
            &( current->cmdnum ),
            &( current->startpos ) );
         }
      current->position = current->startpos;

      if ( current->cmdnum > -1 )
         {

         if ( bwb_cmdtable[ current->cmdnum ].vector == bwb_if )
            {
            ++i_level;

#if INTENSIVE_DEBUG
            sprintf( bwb_ebuf, "in find_endif(): found IF at line %d, level %d",
               current->number, i_level );
            bwb_debug( bwb_ebuf );
#endif

            }
         else if ( is_endif( current ) == TRUE )
            {
            --i_level;

#if INTENSIVE_DEBUG
            sprintf( bwb_ebuf, "in find_endif(): found END IF at line %d, level %d",
               current->number, i_level );
            bwb_debug( bwb_ebuf );
#endif

            if ( i_level == 0 )
               {
               return current;
               }
            }

         else if ( ( bwb_cmdtable[ current->cmdnum ].vector == bwb_else )
            || ( bwb_cmdtable[ current->cmdnum ].vector == bwb_elseif ))
            {

            /* we must only report the first ELSE or ELSE IF we encounter
               at level 1 */

            if ( ( i_level == 1 ) && ( *else_line == NULL ))
               {
               *else_line = current;
               }

            }
         }
      }

#if PROG_ERRORS
   sprintf( bwb_ebuf, "Multiline IF without END IF" );
   bwb_error( bwb_ebuf );
#else
   bwb_error( err_syntax  );
#endif

   return NULL;

   }

/***************************************************************

	FUNCTION:       is_endif()

	DESCRIPTION:    This C function attempts to determine if
			a given line contains an END IF statement.

***************************************************************/

#if ANSI_C
static int
is_endif( struct bwb_line *l )
#else
static int
is_endif( l )
   struct bwb_line *l;
#endif
   {
   int position;
   char tbuf[ MAXVARNAMESIZE + 1];

   if ( bwb_cmdtable[ l->cmdnum ].vector != bwb_xend )
      {
      return FALSE;
      }

   position = l->startpos;
   adv_ws( l->buffer, &position );
   adv_element( l->buffer, &position, tbuf );
   bwb_strtoupper( tbuf );

   if ( strcmp( tbuf, "IF" ) == 0 )
      {
      return TRUE;
      }

   return FALSE;

   }

/***************************************************************

        FUNCTION:       bwb_select()

        DESCRIPTION:    This C function handles the BASIC SELECT
                        statement.

	SYNTAX:		SELECT CASE expression

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_select( struct bwb_line *l )
#else
struct bwb_line *
bwb_select( l )
   struct bwb_line *l;
#endif
   {
   char tbuf[ MAXSTRINGSIZE + 1 ];
   struct exp_ese *e;

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_select(): entered function" );
   bwb_debug( bwb_ebuf );
#endif

   /* first element should be "CASE" */

   adv_element( l->buffer, &( l->position ), tbuf );
   bwb_strtoupper( tbuf );
   if ( strcmp( tbuf, "CASE" ) != 0 )
      {
#if PROG_ERRORS
      sprintf( bwb_ebuf, "SELECT without CASE" );
      bwb_error( bwb_ebuf );
#else
      bwb_error( err_syntax );

      return bwb_zline( l );
#endif
      }

   /* increment the level and set to EXEC_SELFALSE */

   bwb_incexec();
   CURTASK excs[ CURTASK exsc ].code = EXEC_SELFALSE;

   /* evaluate the expression at this level */

   e = bwb_exp( l->buffer, FALSE, &( l->position ) );

#if OLDWAY
   memcpy( &( CURTASK excs[ CURTASK exsc ].expression ), e,
      sizeof( struct exp_ese ) );
#endif

   if ( e->type == STRING )
      {
      CURTASK excs[ CURTASK exsc ].expression.type = STRING;
      str_btob( &( CURTASK excs[ CURTASK exsc ].expression.sval ),
	 &( e->sval ) );
      }
   else
      {
      CURTASK excs[ CURTASK exsc ].expression.type = NUMBER;
      CURTASK excs[ CURTASK exsc ].expression.nval
	 = exp_getnval( e );
      }

   /* return */

#if MULTISEG_LINES
   adv_eos( l->buffer, &( l->position ));
#endif

   return bwb_zline( l );
   }

/***************************************************************

        FUNCTION:       bwb_case()

        DESCRIPTION:    This C function handles the BASIC CASE
                        statement.

	SYNTAX:		CASE constant | IF partial-expression | ELSE

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_case( struct bwb_line *l )
#else
struct bwb_line *
bwb_case( l )
   struct bwb_line *l;
#endif
   {
   char tbuf[ MAXSTRINGSIZE + 1 ];
   int oldpos;
   struct exp_ese minvalue;
   struct exp_ese *maxval, *minval;
   struct bwb_line *retline;
   char cbuf1[ MAXSTRINGSIZE + 1 ];
   char cbuf2[ MAXSTRINGSIZE + 1 ];

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_case(): entered function" );
   bwb_debug( bwb_ebuf );
#endif

   /* if code is EXEC_SELTRUE, then we should jump to the end */

   if ( CURTASK excs[ CURTASK exsc ].code == EXEC_SELTRUE )
      {
#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_case(): exit EXEC_SELTRUE" );
      bwb_debug( bwb_ebuf );
#endif
      retline = find_endselect( l );
      retline->position = 0;
      return retline;
      }

   /* read first element */

   oldpos = l->position;
   adv_element( l->buffer, &( l->position ), tbuf );
   bwb_strtoupper( tbuf );

   /* check for CASE IF */

   if ( strcmp( tbuf, CMD_IF ) == 0 )
      {
      return bwb_caseif( l );
      }

   /* check for CASE ELSE: if true, simply proceed to the next line,
      because other options should have been detected by now */

   else if ( strcmp( tbuf, CMD_ELSE ) == 0 )
      {
#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_case(): execute CASE ELSE" );
      bwb_debug( bwb_ebuf );
#endif

      return bwb_zline( l );
      }

   /* neither CASE ELSE nor CASE IF; presume constant here for min value */

   l->position = oldpos;
   minval = bwb_exp( l->buffer, FALSE, &( l->position ));
   memcpy( &minvalue, minval, sizeof( struct exp_ese ) );
   maxval = minval = &minvalue;

   /* check for string value */

   if ( minvalue.type == STRING )
      {

      str_btoc( cbuf1, &( CURTASK excs[ CURTASK exsc ].expression.sval ) );
      str_btoc( cbuf2, &( minvalue.sval ) );

#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_case(): compare strings <%s> and <%s>",
	 cbuf1, cbuf2 );
      bwb_debug( bwb_ebuf );
#endif

      if ( strncmp( cbuf1, cbuf2, MAXSTRINGSIZE ) == 0 )
	 {
#if INTENSIVE_DEBUG
	 sprintf( bwb_ebuf, "in bwb_case(): string comparison returns TRUE" );
	 bwb_debug( bwb_ebuf );
#endif
	 CURTASK excs[ CURTASK exsc ].code = EXEC_SELTRUE;

#if MULTISEG_LINES
         adv_eos( l->buffer, &( l->position ));
#endif
	 return bwb_zline( l );
	 }

      else
	 {
#if INTENSIVE_DEBUG
	 sprintf( bwb_ebuf, "in bwb_case(): string comparison returns FALSE" );
	 bwb_debug( bwb_ebuf );
#endif
	 retline = find_case( l );
	 retline->position = 0;
	 return retline;
	 }

      }

   /* not a string; advance */

   adv_ws( l->buffer, &( l->position ));

   /* check for TO */

   if ( is_eol( l->buffer, &( l->position )) != TRUE )
      {

      /* find the TO statement */

      adv_element( l->buffer, &( l->position ), tbuf );
      bwb_strtoupper( tbuf );
      if ( strcmp( tbuf, CMD_TO ) != 0 )
         {
#if PROG_ERRORS
         sprintf( bwb_ebuf, "CASE has inexplicable code following expression" );
         bwb_error( bwb_ebuf );
#else
         bwb_error( err_syntax );

#if MULTISEG_LINES
         adv_eos( l->buffer, &( l->position ));
#endif
         return bwb_zline( l );
#endif
         }

      /* now evaluate the MAX expression */

      maxval = bwb_exp( l->buffer, FALSE, &( l->position ));

      }

   /* evaluate the expression */

   if ( case_eval( &( CURTASK excs[ CURTASK exsc ].expression ),
      minval, maxval ) == TRUE )
      {
#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_case(): evaluation returns TRUE" );
      bwb_debug( bwb_ebuf );
#endif
      CURTASK excs[ CURTASK exsc ].code = EXEC_SELTRUE;

#if MULTISEG_LINES
      adv_eos( l->buffer, &( l->position ));
#endif
      return bwb_zline( l );
      }

   /* evaluation returns a FALSE value; find next CASE or END SELECT statement */

   else
      {
#if INTENSIVE_DEBUGb
      sprintf( bwb_ebuf, "in bwb_case(): evaluation returns FALSE" );
      bwb_debug( bwb_ebuf );
#endif
      retline = find_case( l );
      retline->position = 0;
      return retline;
      }

   }

/***************************************************************

        FUNCTION:       bwb_caseif()

        DESCRIPTION:    This C function handles the BASIC CASE IF
                        statement.

***************************************************************/

#if ANSI_C
static struct bwb_line *
bwb_caseif( struct bwb_line *l )
#else
static struct bwb_line *
bwb_caseif( l )
   struct bwb_line *l;
#endif
   {
   char tbuf[ MAXSTRINGSIZE + 1 ];
   int position;
   struct exp_ese *r;
   struct bwb_line *retline;

   if ( CURTASK excs[ CURTASK exsc ].expression.type == NUMBER )
      {
      sprintf( tbuf, "%f %s",
         (float) CURTASK excs[ CURTASK exsc ].expression.nval,
         &( l->buffer[ l->position ] ) );
      }
   else
      {
      bwb_error( err_mismatch );
#if MULTISEG_LINES
      adv_eos( l->buffer, &( l->position ));
#endif
      return bwb_zline( l );
      }

   position = 0;
   r = bwb_exp( tbuf, FALSE, &position );

   if ( r->nval == (bnumber) TRUE )
      {
      CURTASK excs[ CURTASK exsc ].code = EXEC_SELTRUE;

#if MULTISEG_LINES
      adv_eos( l->buffer, &( l->position ));
#endif
      return bwb_zline( l );
      }
   else
      {
      retline = find_case( l );
      retline->position = 0;
      return retline;
      }

   }

/***************************************************************

        FUNCTION:       case_eval()

        DESCRIPTION:    This function evaluates a case statement
			by comparing minimum and maximum values
			with a set expression. It returns either
			TRUE or FALSE

***************************************************************/

#if ANSI_C
static int
case_eval( struct exp_ese *expression, struct exp_ese *minval,
   struct exp_ese *maxval )
#else
static int
case_eval( expression, minval, maxval )
   struct exp_ese *expression;
   struct exp_ese *minval;
   struct exp_ese *maxval;
#endif
   {

   /* string value */

   if ( expression->type == STRING )
      {
      bwb_error( err_mismatch );
      return FALSE;
      }

   /* numerical value */

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in case_eval(): n <%f> min <%f> max <%f>",
      (float) expression->nval,
      (float) minval->nval,
      (float) maxval->nval );
   bwb_debug( bwb_ebuf );
#endif

   if (  ( expression->nval >= minval->nval )
      && ( expression->nval <= maxval->nval ))
      {
      return TRUE;
      }

   return FALSE;

   }

/***************************************************************

        FUNCTION:       find_case()

        DESCRIPTION:    This function searches for a line containing
                        a CASE statement corresponding to a previous
                        SELECT CASE statement.

***************************************************************/

#if ANSI_C
static struct bwb_line *
find_case( struct bwb_line *l )
#else
static struct bwb_line *
find_case( l )
   struct bwb_line *l;
#endif
   {
   struct bwb_line *current;
   register int c_level;
   int position;

   c_level = 1;
   for ( current = l->next; current != &CURTASK bwb_end; current = current->next )
      {
      position = 0;
      if ( current->marked != TRUE )
         {
         line_start( current->buffer, &position, &( current->lnpos ),
            &( current->lnum ),
            &( current->cmdpos ),
            &( current->cmdnum ),
            &( current->startpos ) );
         }
      current->position = current->startpos;

      if ( current->cmdnum > -1 )
         {

         if ( bwb_cmdtable[ current->cmdnum ].vector == bwb_select )
            {
            ++c_level;

#if INTENSIVE_DEBUG
            sprintf( bwb_ebuf, "in find_case(): found SELECT at line %d, level %d",
               current->number, c_level );
            bwb_debug( bwb_ebuf );
#endif

            }
         else if ( is_endselect( current ) == TRUE )
            {
            --c_level;

#if INTENSIVE_DEBUG
            sprintf( bwb_ebuf, "in find_endif(): found END SELECT at line %d, level %d",
               current->number, c_level );
            bwb_debug( bwb_ebuf );
#endif

            if ( c_level == 0 )
               {
               return current;
               }
            }

         else if ( bwb_cmdtable[ current->cmdnum ].vector == bwb_case )
            {
            --c_level;

#if INTENSIVE_DEBUG
            sprintf( bwb_ebuf, "in find_case(): found CASE at line %d, level %d",
               current->number, c_level );
            bwb_debug( bwb_ebuf );
#endif

            if ( c_level == 0 )
               {
               return current;
               }
            }
         }
      }

#if PROG_ERRORS
   sprintf( bwb_ebuf, "SELECT without CASE" );
   bwb_error( bwb_ebuf );
#else
   bwb_error( err_syntax  );
#endif

   return NULL;

   }

/***************************************************************

        FUNCTION:       find_case()

        DESCRIPTION:    This function searches for a line containing
                        an END SELECT statement corresponding to a previous
                        SELECT CASE statement.

***************************************************************/

#if ANSI_C
static struct bwb_line *
find_endselect( struct bwb_line *l )
#else
static struct bwb_line *
find_endselect( l )
   struct bwb_line *l;
#endif
   {
   struct bwb_line *current;
   register int c_level;
   int position;

   c_level = 1;
   for ( current = l->next; current != &CURTASK bwb_end; current = current->next )
      {
      position = 0;
      if ( current->marked != TRUE )
         {
         line_start( current->buffer, &position, &( current->lnpos ),
            &( current->lnum ),
            &( current->cmdpos ),
            &( current->cmdnum ),
            &( current->startpos ) );
         }
      current->position = current->startpos;

      if ( current->cmdnum > -1 )
         {

         if ( bwb_cmdtable[ current->cmdnum ].vector == bwb_select )
            {
            ++c_level;

#if INTENSIVE_DEBUG
            sprintf( bwb_ebuf, "in find_case(): found SELECT at line %d, level %d",
               current->number, c_level );
            bwb_debug( bwb_ebuf );
#endif

            }
         else if ( is_endselect( current ) == TRUE )
            {
            --c_level;

#if INTENSIVE_DEBUG
            sprintf( bwb_ebuf, "in find_endif(): found END SELECT at line %d, level %d",
               current->number, c_level );
            bwb_debug( bwb_ebuf );
#endif

            if ( c_level == 0 )
               {
               return current;
               }
            }
         }
      }

#if PROG_ERRORS
   sprintf( bwb_ebuf, "SELECT without END SELECT" );
   bwb_error( bwb_ebuf );
#else
   bwb_error( err_syntax  );
#endif

   return NULL;

   }

/***************************************************************

	FUNCTION:       is_endselect()

	DESCRIPTION:    This C function attempts to determine if
			a given line contains an END SELECT statement.

***************************************************************/

#if ANSI_C
static int
is_endselect( struct bwb_line *l )
#else
static int
is_endselect( l )
   struct bwb_line *l;
#endif
   {
   int position;
   char tbuf[ MAXVARNAMESIZE + 1];

   if ( bwb_cmdtable[ l->cmdnum ].vector != bwb_xend )
      {
      return FALSE;
      }

   position = l->startpos;
   adv_ws( l->buffer, &position );
   adv_element( l->buffer, &position, tbuf );
   bwb_strtoupper( tbuf );

   if ( strcmp( tbuf, "SELECT" ) == 0 )
      {
      return TRUE;
      }

   return FALSE;

   }

/***************************************************************

        FUNCTION:       bwb_endselect()

        DESCRIPTION:    This function handles the BASIC END
                        SELECT statement.

	SYNTAX:		END SELECT

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_endselect( struct bwb_line *l )
#else
struct bwb_line *
bwb_endselect( l )
   struct bwb_line *l;
#endif
   {

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_endselect(): entered function" );
   bwb_debug( bwb_ebuf );
#endif

   if (  ( CURTASK excs[ CURTASK exsc ].code != EXEC_SELTRUE  )
      && ( CURTASK excs[ CURTASK exsc ].code != EXEC_SELFALSE ))
      {
#if PROG_ERRORS
      sprintf( bwb_ebuf, "in bwb_endselect(): END SELECT without SELECT" );
      bwb_error( bwb_ebuf );
#else
      bwb_error( err_syntax );
#endif
      }

   bwb_decexec();


#if MULTISEG_LINES
   adv_eos( l->buffer, &( l->position ));
#endif
   return bwb_zline( l );
   }

#endif				/* STRUCT_CMDS */

#if COMMON_CMDS || STRUCT_CMDS

/***    WHILE-WEND ***/

/***************************************************************

        FUNCTION:       bwb_while()

        DESCRIPTION:    This function handles the BASIC WHILE
			statement and also the ANSI DO WHILE
			statement.

	SYNTAX:		WHILE expression
			DO WHILE expression

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_while( struct bwb_line *l )
#else
struct bwb_line *
bwb_while( l )
   struct bwb_line *l;
#endif
   {
   struct exp_ese *e;
   struct bwb_line *r;

      /* if this is the first time at this WHILE statement, note it */

      if ( CURTASK excs[ CURTASK exsc ].while_line != l )
         {

         bwb_incexec();
         CURTASK excs[ CURTASK exsc ].while_line = l;

         /* find the WEND statement (or LOOP statement) */

#if STRUCT_CMDS
	 if ( l->cmdnum == getcmdnum( CMD_DO ))
            {
	    CURTASK excs[ CURTASK exsc ].wend_line = find_loop( l );
            }
         else
            {
	    CURTASK excs[ CURTASK exsc ].wend_line = find_wend( l );
	    }
#else
	 CURTASK excs[ CURTASK exsc ].wend_line = find_wend( l );
#endif

         if ( CURTASK excs[ CURTASK exsc ].wend_line == NULL )
            {
            return bwb_zline( l );
            }

#if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in bwb_while(): initialize WHILE loop, line <%d>",
            l->number );
         bwb_debug( bwb_ebuf );
#endif

         }
#if INTENSIVE_DEBUG
      else
         {
         sprintf( bwb_ebuf, "in bwb_while(): return to WHILE loop, line <%d>",
            l->number );
         bwb_debug( bwb_ebuf );
         }
#endif

   /*----------------------------------------------------*/
   /* Expression evaluation was at the top of bwb_while, */
   /* and the init portion was performed only if TRUE.   */
   /* The init routine should be performed regardless of */
   /* expression value, else a segmentation fault can    */
   /* occur! (JBV)                                       */
   /*----------------------------------------------------*/

   /* call bwb_exp() to interpret the expression */

   e = bwb_exp( l->buffer, FALSE, &( l->position ) );

   if ( (int) exp_getnval( e ) != FALSE ) /* Was == TRUE (JBV 10/1996) */
      {
      bwb_setexec( l, l->position, EXEC_WHILE );
      return bwb_zline( l );
      }
   else
      {
      CURTASK excs[ CURTASK exsc ].while_line = NULL;
      r = CURTASK excs[ CURTASK exsc ].wend_line;
      bwb_setexec( r, 0, CURTASK excs[ CURTASK exsc - 1 ].code );
      r->position = 0;
      bwb_decexec();
      return r;
      }

   }

/***************************************************************

        FUNCTION:       bwb_wend()

        DESCRIPTION:    This function handles the BASIC WEND
			statement and the LOOP statement ending
			a DO WHILE loop.

	SYNTAX:		WEND
			LOOP

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_wend( struct bwb_line *l )
#else
struct bwb_line *
bwb_wend( l )
   struct bwb_line *l;
#endif
   {

   /* check integrity of WHILE loop */

   if ( CURTASK excs[ CURTASK exsc ].code != EXEC_WHILE )
      {
#if PROG_ERRORS
      sprintf( bwb_ebuf, "in bwb_wend(): exec stack code != EXEC_WHILE" );
      bwb_error( bwb_ebuf );
#else
      bwb_error( err_syntax );
#endif
      }

   if ( CURTASK excs[ CURTASK exsc ].while_line == NULL )
      {
#if PROG_ERRORS
      sprintf( bwb_ebuf, "in bwb_wend(): exec stack while_line == NULL" );
      bwb_error( bwb_ebuf );
#else
      bwb_error( err_syntax );
#endif
      }

   /* reset to the top of the current WHILE loop */

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_wend() return to line <%d>",
      CURTASK excs[ CURTASK exsc ].while_line->number );
   bwb_debug( bwb_ebuf );
#endif

   CURTASK excs[ CURTASK exsc ].while_line->position = 0;
   bwb_setexec( CURTASK excs[ CURTASK exsc ].while_line, 0, EXEC_WHILE );

   return CURTASK excs[ CURTASK exsc ].while_line;

   }

/***************************************************************

        FUNCTION:       find_wend()

        DESCRIPTION:    This function searches for a line containing
                        a WEND statement corresponding to a previous
                        WHILE statement.

***************************************************************/

#if ANSI_C
static struct bwb_line *
find_wend( struct bwb_line *l )
#else
static struct bwb_line *
find_wend( l )
   struct bwb_line *l;
#endif
   {
   struct bwb_line *current;
   register int w_level;
   int position;

   w_level = 1;
   for ( current = l->next; current != &CURTASK bwb_end; current = current->next )
      {
      position = 0;
      if ( current->marked != TRUE )
         {
         line_start( current->buffer, &position, &( current->lnpos ),
            &( current->lnum ),
            &( current->cmdpos ),
            &( current->cmdnum ),
            &( current->startpos ) );
         }
      current->position = current->startpos;

      if ( current->cmdnum > -1 )
         {

         if ( bwb_cmdtable[ current->cmdnum ].vector == bwb_while )
            {
            ++w_level;

#if INTENSIVE_DEBUG
	    sprintf( bwb_ebuf, "in find_wend(): found WHILE at line %d, level %d",
               current->number, w_level );
            bwb_debug( bwb_ebuf );
#endif

            }
         else if ( bwb_cmdtable[ current->cmdnum ].vector == bwb_wend )
            {
            --w_level;

#if INTENSIVE_DEBUG
	    sprintf( bwb_ebuf, "in find_wend(): found WEND at line %d, level %d",
               current->number, w_level );
            bwb_debug( bwb_ebuf );
#endif

            if ( w_level == 0 )
               {
               return current->next;
               }
            }
         }
      }

#if PROG_ERRORS
   sprintf( bwb_ebuf, "in find_wend(): WHILE without WEND" );
   bwb_error( bwb_ebuf );
#else
   bwb_error( err_syntax  );
#endif

   return NULL;

   }

#if STRUCT_CMDS

/***************************************************************

	FUNCTION:       find_loop()

	DESCRIPTION:    This function searches for a line containing
			a LOOP statement corresponding to a previous
			DO statement.

***************************************************************/

#if ANSI_C
extern struct bwb_line *
find_loop( struct bwb_line *l )
#else
extern struct bwb_line *
find_loop( l )
   struct bwb_line *l;
#endif
   {
   struct bwb_line *current;
   register int w_level;
   int position;

   w_level = 1;
   for ( current = l->next; current != &CURTASK bwb_end; current = current->next )
      {
      position = 0;
      if ( current->marked != TRUE )
	 {
	 line_start( current->buffer, &position, &( current->lnpos ),
	    &( current->lnum ),
	    &( current->cmdpos ),
	    &( current->cmdnum ),
	    &( current->startpos ) );
	 }
      current->position = current->startpos;

      if ( current->cmdnum > -1 )
	 {

	 if ( bwb_cmdtable[ current->cmdnum ].vector == bwb_do )
	    {
	    ++w_level;

#if INTENSIVE_DEBUG
	    sprintf( bwb_ebuf, "in find_loop(): found DO at line %d, level %d",
	       current->number, w_level );
	    bwb_debug( bwb_ebuf );
#endif

	    }
	 else if ( bwb_cmdtable[ current->cmdnum ].vector == bwb_loop )
	    {
	    --w_level;

#if INTENSIVE_DEBUG
	    sprintf( bwb_ebuf, "in fnd_loop(): found LOOP at line %d, level %d",
	       current->number, w_level );
	    bwb_debug( bwb_ebuf );
#endif

	    if ( w_level == 0 )
	       {
	       return current->next;
	       }
	    }
	 }
      }

#if PROG_ERRORS
   sprintf( bwb_ebuf, "in find_loop(): DO without LOOP" );
   bwb_error( bwb_ebuf );
#else
   bwb_error( err_syntax  );
#endif

   return NULL;

   }

#endif                          /* STRUCT_CMDS */

#endif                          /* COMMON_CMDS || STRUCT_CMDS */

/***    FOR-NEXT ***/

/***************************************************************

        FUNCTION:       bwb_for()

        DESCRIPTION:    This function handles the BASIC FOR
                        statement.

	SYNTAX:		FOR counter = start TO finish [STEP increment]

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_for( struct bwb_line *l )
#else
struct bwb_line *
bwb_for( l )
   struct bwb_line *l;
#endif
   {
   register int n;
   int e, loop;
   int to, step, p;
   int for_step, for_target;
   struct exp_ese *exp;
   struct bwb_variable *v;
   char tbuf[ MAXSTRINGSIZE + 1 ];

   /* get the variable name */

   exp_getvfname( &( l->buffer[ l->position ] ), tbuf );
   l->position += strlen( tbuf );
   v = var_find( tbuf );

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_for(): variable name <%s>.", v->name );
   bwb_debug( bwb_ebuf );
#endif

   /*--------------------------------------------------------------*/
   /* Make sure we are in the right FOR-NEXT level!                */
   /* If we aren't (which could happen for legit reasons), fix the */
   /* exec stack.                                                  */
   /* JBV, 9/20/95                                                 */
   /*--------------------------------------------------------------*/
   if (v == CURTASK excs[ CURTASK exsc].local_variable) bwb_decexec();

   /* at this point one should find an equals sign ('=') */

   adv_ws( l->buffer, &( l->position ) );

   if ( l->buffer[ l->position ] != '=' )
      {
#if PROG_ERRORS
      sprintf( bwb_ebuf, "in bwb_for(): failed to find equals sign, buf <%s>",
         &( l->buffer[ l->position ] ) );
      bwb_error( bwb_ebuf );
#else
      bwb_error( err_syntax );
#endif
      return bwb_zline( l );
      }
   else
      {
      ++( l->position );
      }

   /* Find the TO and STEP statements */

   cnd_tostep( l->buffer, l->position, &to, &step );

   /* if there is no TO statement, then an error has ocurred */

   if ( to < 1 )
      {
#if PROG_ERRORS
      sprintf( bwb_ebuf, "FOR statement without TO" );
      bwb_error( bwb_ebuf );
#else
      bwb_error( err_syntax  );
#endif
      return bwb_zline( l );
      }

   /* copy initial value to buffer and evaluate it */

   tbuf[ 0 ] = '\0';
   p = 0;
   for ( n = l->position; n < to; ++n )
      {
      tbuf[ p ] = l->buffer[ n ];
      ++p;
      ++l->position;
      tbuf[ p ] = '\0';
      }

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_for(): initial value string <%s>",
      tbuf );
   bwb_debug( bwb_ebuf );
#endif

   p = 0;
   exp = bwb_exp( tbuf, FALSE, &p );
   var_setnval( v, exp_getnval( exp ) );

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_for(): initial value <%d> pos <%d>",
      exp_getnval( exp ), l->position );
   bwb_debug( bwb_ebuf );
#endif

   /* copy target value to small buffer and evaluate it */

   tbuf[ 0 ] = '\0';
   p = 0;
   l->position = to + 2;
   if ( step < 1 )
      {
      e = strlen( l->buffer );
      }
   else
      {
      e = step - 1;
      }

   loop = TRUE;
   n = l->position;
   while( loop == TRUE )
      {
      tbuf[ p ] = l->buffer[ n ];
      ++p;
      ++l->position;
      tbuf[ p ] = '\0';

      if ( n >= e )
          {
          loop = FALSE;
          }

      ++n;

      if ( l->buffer[ n ] == ':' )
         {
         loop = FALSE;
         }

      }

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_for(): target value string <%s>",
      tbuf );
   bwb_debug( bwb_ebuf );
#endif

   p = 0;
   exp = bwb_exp( tbuf, FALSE, &p );
   for_target = (int) exp_getnval( exp );

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_for(): target value <%d> pos <%d>",
      exp_getnval( exp ), l->position );
   bwb_debug( bwb_ebuf );
#endif

   /* If there is a STEP statement, copy it to a buffer
      and evaluate it */

   if ( step > 1 )
      {
      tbuf[ 0 ] = '\0';
      p = 0;
      l->position = step + 4;

      for ( n = l->position; n < (int) strlen( l->buffer ); ++n )
         {
         tbuf[ p ] = l->buffer[ n ];
         ++p;
         ++l->position;
         tbuf[ p ] = '\0';
         }

#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_for(): step value string <%s>",
         tbuf );
      bwb_debug( bwb_ebuf );
#endif

      p = 0;
      exp = bwb_exp( tbuf, FALSE, &p );
      for_step = (int) exp_getnval( exp );

      }
   else
      {
      for_step = 1;
      }


#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_for(): step value <%d>",
      for_step );
   bwb_debug( bwb_ebuf );
#endif

   /* set position in current line and increment EXEC counter */

   /* bwb_setexec( l, l->position, EXEC_NORM ); */  /* WRONG */
   bwb_incexec();

   CURTASK excs[ CURTASK exsc ].local_variable  = v;
   CURTASK excs[ CURTASK exsc ].for_step   = for_step;
   CURTASK excs[ CURTASK exsc ].for_target = for_target;

   /* set exit line to be used by EXIT FOR */

#if STRUCT_CMDS
   CURTASK excs[ CURTASK exsc ].wend_line  = find_next( l );
#endif

   /* set top line and position to be used in multisegmented FOR-NEXT loop */

#if MULTISEG_LINES
   CURTASK excs[ CURTASK exsc ].for_line     = l;
   CURTASK excs[ CURTASK exsc ].for_position = l->position;
#endif

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_for(): setting code to EXEC_FOR",
      l->position );
   bwb_debug( bwb_ebuf );
#endif

   bwb_setexec( l, l->position, EXEC_FOR );

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_for(): ready to exit, position <%d>",
      l->position );
   bwb_debug( bwb_ebuf );
#endif

   /* proceed with processing */

   return bwb_zline( l );

   }

/***************************************************************

        FUNCTION:       bwb_next()

        DESCRIPTION:    This function handles the BASIC NEXT
                        statement.

	SYNTAX:		NEXT counter

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_next( struct bwb_line *l )
#else
struct bwb_line *
bwb_next( l )
   struct bwb_line *l;
#endif
   {
   char tbuf[ MAXSTRINGSIZE + 1 ];
   struct bwb_variable *v; /* Relocated from INTENSIVE_DEBUG (JBV) */

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_next(): entered function, cmdnum <%d> exsc level <%d> code <%d>",
      l->cmdnum, CURTASK exsc, CURTASK excs[ CURTASK exsc ].code );
   bwb_debug( bwb_ebuf );
#endif

   /* Check the integrity of the FOR statement */

   if ( CURTASK excs[ CURTASK exsc ].code != EXEC_FOR )
      {
#if PROG_ERRORS
      sprintf( bwb_ebuf, "in bwb_next(): NEXT without FOR; code is <%d> instead of <%d>",
	 CURTASK excs[ CURTASK exsc ].code, EXEC_FOR );
      bwb_error( bwb_ebuf );
#else
      bwb_error( err_syntax );
#endif
      }

   /* read the argument, if there is one */

   /* Relocated from MULTISEG_LINES (JBV) */
   exp_getvfname( &( l->buffer[ l->position ] ), tbuf );

   if (strlen(tbuf) != 0)
   {
   /* Relocated from INTENSIVE_DEBUG (JBV) */
   v = var_find( tbuf );

#if MULTISEG_LINES                   /* not currently needed otherwise */

   l->position += strlen( tbuf );

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_next(): variable name detected <%s>.", v->name );
   bwb_debug( bwb_ebuf );
#endif
#endif

   /* decrement or increment the value */

   /*--------------------------------------------------------------*/
   /* Make sure we are in the right FOR-NEXT level!                */
   /* If we aren't (which could happen for legit reasons), fix the */
   /* exec stack.                                                  */
   /* JBV, 9/20/95                                                 */
   /*--------------------------------------------------------------*/
   while (v != CURTASK excs[ CURTASK exsc].local_variable) bwb_decexec();
   }

   var_setnval( CURTASK excs[ CURTASK exsc ].local_variable,
      var_getnval( CURTASK excs[ CURTASK exsc ].local_variable )
      + (bnumber) CURTASK excs[ CURTASK exsc ].for_step );

   /* check for completion of the loop */

   if ( CURTASK excs[ CURTASK exsc ].for_step > 0 )            /* if step is positive */
      {
      if ( (int) var_getnval( CURTASK excs[ CURTASK exsc ].local_variable )
         > CURTASK excs[ CURTASK exsc ].for_target )
         {
         bwb_decexec();
#if MULTISEG_LINES
	 bwb_setexec( l, l->position, CURTASK excs[ CURTASK exsc ].code );
#else
	 bwb_setexec( l->next, 0, CURTASK excs[ CURTASK exsc ].code );
#endif

#if INTENSIVE_DEBUG
	 sprintf( bwb_ebuf, "in bwb_next(): end of loop" );
	 bwb_debug( bwb_ebuf );
#endif

#ifdef OLD_WAY
	 l->next->position = 0;
	 return l->next;
#else
	 return bwb_zline( l );
#endif
         }
      }
   else                                         /* if step is negative */
      {
      if ( (int) var_getnval( CURTASK excs[ CURTASK exsc ].local_variable )
         < CURTASK excs[ CURTASK exsc ].for_target )
         {
         bwb_decexec();
	 bwb_setexec( l->next, 0, CURTASK excs[ CURTASK exsc ].code );

#if INTENSIVE_DEBUG
	 sprintf( bwb_ebuf, "in bwb_next(): end of loop" );
	 bwb_debug( bwb_ebuf );
#endif

#ifdef OLD_WAY
	 l->next->position = 0;
	 return l->next;
#else
	 return bwb_zline( l );
#endif
         }
      }

   /* Target not reached: return to the top of the FOR loop */

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_next(): resetting code to EXEC_FOR",
      l->position );
   bwb_debug( bwb_ebuf );
#endif

#if MULTISEG_LINES
   CURTASK excs[ CURTASK exsc ].for_line->position
      = CURTASK excs[ CURTASK exsc ].for_position;
   bwb_setexec( CURTASK excs[ CURTASK exsc ].for_line,
      CURTASK excs[ CURTASK exsc ].for_position, EXEC_FOR );

   return CURTASK excs[ CURTASK exsc ].for_line; /* Added (JBV) */
#else
   bwb_setexec( CURTASK excs[ CURTASK exsc - 1 ].line,
      CURTASK excs[ CURTASK exsc - 1 ].position, EXEC_FOR );

   return CURTASK excs[ CURTASK exsc - 1 ].line; /* Relocated (JBV) */
#endif

   }

#if STRUCT_CMDS

/***************************************************************

	FUNCTION:       bwb_exitfor()

	DESCRIPTION:    This function handles the BASIC EXIT
			FOR statement.  This is a structured
			programming command compatible with ANSI
			BASIC. It is called from the bwb_exit()
			subroutine.

	SYNTAX:		EXIT FOR
			
***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_exitfor( struct bwb_line *l )
#else
struct bwb_line *
bwb_exitfor( l )
   struct bwb_line *l;
#endif
   {
   struct bwb_line *next_line;
   int found;
   register int level;

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_exitfor(): entered subroutine" );
   bwb_debug( bwb_ebuf );
#endif

   /* Check the integrity of the FOR statement */

   found = FALSE;
   level = CURTASK exsc;
   do
      {
      if ( CURTASK excs[ level ].code == EXEC_FOR )
	 {
	 next_line = CURTASK excs[ CURTASK level ].wend_line;
	 found = TRUE;
	 }
      else
	 {
	 --level;
	 }
      }
   while ( ( level >= 0 ) && ( found == FALSE ) );

   if ( found != TRUE )
      {

#if PROG_ERRORS
      sprintf( bwb_ebuf, "in bwb_exitfor(): EXIT FOR without FOR" );
      bwb_error( bwb_ebuf );
#else
      bwb_error( err_syntax );
#endif

      return bwb_zline( l );

      }

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_exitfor(): level found is <%d>, current <%d>",
      level, CURTASK exsc );
   bwb_debug( bwb_ebuf );
#endif

   /* decrement below the level of the NEXT statement */

   while( CURTASK exsc >= level )
      {
      bwb_decexec();
      }

   /* set the next line in the exec stack */

   next_line->position = 0;
   /* bwb_setexec( next_line, 0, EXEC_NORM ); */  /* WRONG (JBV) */
   bwb_setexec( next_line, 0, CURTASK excs[ CURTASK exsc ].code ); /* JBV */

   return next_line;

   }

/***************************************************************

	FUNCTION:       find_next()

	DESCRIPTION:    This function searches for a line containing
			a NEXT statement corresponding to a previous
			FOR statement.

***************************************************************/

#if ANSI_C
static struct bwb_line *
find_next( struct bwb_line *l )
#else
static struct bwb_line *
find_next( l )
   struct bwb_line *l;
#endif
   {
   struct bwb_line *current;
   register int w_level;
   int position;

   w_level = 1;
   for ( current = l->next; current != &CURTASK bwb_end; current = current->next )
      {
      position = 0;
      if ( current->marked != TRUE )
	 {
	 line_start( current->buffer, &position, &( current->lnpos ),
	    &( current->lnum ),
	    &( current->cmdpos ),
	    &( current->cmdnum ),
	    &( current->startpos ) );
	 }
      current->position = current->startpos;

      if ( current->cmdnum > -1 )
	 {

	 if ( bwb_cmdtable[ current->cmdnum ].vector == bwb_for )
	    {
	    ++w_level;

#if INTENSIVE_DEBUG
	    sprintf( bwb_ebuf, "in find_next(): found FOR at line %d, level %d",
	       current->number, w_level );
	    bwb_debug( bwb_ebuf );
#endif

	    }
	 else if ( bwb_cmdtable[ current->cmdnum ].vector == bwb_next )
	    {
	    --w_level;

#if INTENSIVE_DEBUG
	    sprintf( bwb_ebuf, "in find_next(): found NEXT at line %d, level %d",
	       current->number, w_level );
	    bwb_debug( bwb_ebuf );
#endif

	    if ( w_level == 0 )
	       {

#if INTENSIVE_DEBUG
	       sprintf( bwb_ebuf, "in find_next(): found returning line <%d>",
		  current->next->number );
	       bwb_debug( bwb_ebuf );
#endif

	       return current->next;
	       }
	    }
	 }
      }

#if PROG_ERRORS
   sprintf( bwb_ebuf, "FOR without NEXT" );
   bwb_error( bwb_ebuf );
#else
   bwb_error( err_syntax  );
#endif

   return NULL;

   }

#endif				/* STRUCT_CMDS for EXIT FOR */

/***************************************************************

	FUNCTION:	cnd_tostep()

	DESCRIPTION:	This function searches through the
			<buffer> beginning at point <position>
			and attempts to find positions of TO
			and STEP statements.

***************************************************************/

#if ANSI_C
static int
cnd_tostep( char *buffer, int position, int *to, int *step )
#else
static int
cnd_tostep( buffer, position, to, step )
   char *buffer;
   int position;
   int *to;
   int *step;
#endif
   {
   int loop, t_pos, b_pos, p_word;
   char tbuf[ MAXSTRINGSIZE + 1 ];

   /* set then and els to FALSE initially */

   *to = *step = FALSE;

   /* loop to find words */

   p_word = b_pos = position;
   t_pos = 0;
   tbuf[ 0 ] = '\0';
   loop = TRUE;
   while ( loop == TRUE )
      {

      switch( buffer[ b_pos ] )
         {
         case '\0':                     /* end of string */
         case ':':			/* end of line segment */
            return TRUE;
         case ' ':                      /* whitespace = end of word */
         case '\t':

#if INTENSIVE_DEBUG
            sprintf( bwb_ebuf, "in cnd_tostep(): word is <%s>", tbuf );
            bwb_debug( bwb_ebuf );
#endif

            if ( strncmp( tbuf, CMD_TO, (size_t) strlen( CMD_TO ) ) == 0 )
               {

#if INTENSIVE_DEBUG
               sprintf( bwb_ebuf, "in cnd_tostep(): TO found at position <%d>.",
                  p_word );
               bwb_debug( bwb_ebuf );
#endif

               *to = p_word;
               }
            else if ( strncmp( tbuf, CMD_STEP, (size_t) strlen( CMD_STEP ) ) == 0 )
               {

#if INTENSIVE_DEBUG
               sprintf( bwb_ebuf, "in cnd_tostep(): STEP found at position <%d>.",
                  p_word );
               bwb_debug( bwb_ebuf );
#endif

               *step = p_word;
               }
            ++b_pos;
            p_word = b_pos;
            t_pos = 0;
            tbuf[ 0 ] = '\0';
            break;

         default:
            if ( islower( buffer[ b_pos ] ) != FALSE )
               {
               tbuf[ t_pos ] = (char) toupper( buffer[ b_pos ] );
               }
            else
               {
               tbuf[ t_pos ] = buffer[ b_pos ];
               }
            ++b_pos;
            ++t_pos;
            tbuf[ t_pos ] = '\0';
            break;
         }

      }

   return TRUE;

   }

/***************************************************************

	FUNCTION:       var_setnval()

	DESCRIPTION:    This function sets the value of numerical
			variable v to the value of i.

***************************************************************/

#if ANSI_C
extern int
var_setnval( struct bwb_variable *v, bnumber i )
#else
int
var_setnval( v, i )
   struct bwb_variable *v;
   bnumber i;
#endif
   {

   switch( v->type )
      {
      case NUMBER:
         * var_findnval( v, v->array_pos ) = i;
         break;
      default:
#if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in var_setnval(): variable <%s> is not a number",
            v->name );
         bwb_error( bwb_ebuf );
#else
         bwb_error( err_mismatch );
#endif
      }

   /* successful assignment */

   return TRUE;

   }

