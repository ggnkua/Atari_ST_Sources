/***************************************************************

        bwb_cnd.c       Conditional Expressions and Commands
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
#include <math.h>
#include <ctype.h>
#include <string.h>

#include "bwbasic.h"
#include "bwb_mes.h"

/* global variables visible to this file only */

static struct bwb_line * ws[ WHILELEVELS ];             /* WHILE stack */
int ws_counter = 0;                                     /* WHILE stack counter */

int fs_counter = 0;                                     /* FOR stack counter */

/* declarations of functions visible to this file only */

static int cnd_thenels( char *buffer, int position, int *then, int *els );
static int cnd_tostep( char *buffer, int position, int *to, int *step );
static struct bwb_line *find_wend( struct bwb_line *l );
static int var_setival( struct bwb_variable *v, int i );
static int dec_fsc( int level );

/***    IF-THEN-ELSE ***/

/***************************************************************

        FUNCTION:       bwb_if()

        DESCRIPTION:    This function handles the BASIC IF
                        statement.

***************************************************************/

struct bwb_line *
bwb_if( struct bwb_line *l )
   {
   register int i, n;
   int then, els;
   int pos;
   struct exp_ese *e;
   char tbuf[ MAXSTRINGSIZE + 1 ];
   char then_buffer[ MAXSTRINGSIZE + 1 ];	/* hold THEN statement */
   char elb_buffer[ MAXSTRINGSIZE + 1 ]; 	/* hold ELSE statement */

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_if(): entry, line <%d> buffer <%s>",
      l->number, &( l->buffer[ l->position ] ) );
   bwb_debug( bwb_ebuf );
   #endif

   /* Call bwb_exp() to evaluate the condition. This should return
      with position set to the "THEN" statement */

   e = bwb_exp( l->buffer, FALSE, &( l->position ) );

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_if(): line <%d> condition returns <%d>",
      l->number, exp_getival( e ) );
   bwb_debug( bwb_ebuf );
   #endif

   /* test for "THEN" and "ELSE" statements */

   cnd_thenels( l->buffer, l->position, &then, &els );

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_if(): return from cnd_thenelse, line is <%s>", 
      l->buffer );
   bwb_debug( bwb_ebuf );
   #endif

   if ( then != FALSE )
      {
      if ( els != FALSE )
         {
         then_buffer[ 0 ] = '\0';
         n = 0;
         for ( i = (then + 4); i < els; ++i )
            {
            then_buffer[ n ] = l->buffer[ i ];
            ++n;
            then_buffer[ n ] = '\0';
            }
         }
      else
         {
         then_buffer[ 0 ] = '\0';
         n = 0;
         for ( i = (then + 4); l->buffer[ i ] != '\0'; ++i )
            {
            then_buffer[ n ] = l->buffer[ i ];
            ++n;
            then_buffer[ n ] = '\0';
            }
         }

      }

   /* test for THEN line-number */

   pos = 0;
   adv_ws( then_buffer, &pos );
   adv_element( then_buffer, &pos, tbuf );
   if ( ( tbuf[ 0 ] >= '0' ) && ( tbuf[ 0 ] <= '9' ))
      {
      sprintf( tbuf, "GOSUB %s", then_buffer );
      strcpy( then_buffer, tbuf );
      }

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_if(): THEN statement is <%s>", then_buffer );
   bwb_debug( bwb_ebuf );
   #endif

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_if(): found THEN statement, line is <%s>", 
      l->buffer );
   bwb_debug( bwb_ebuf );
   #endif

   if ( els != FALSE )
      {
      elb_buffer[ 0 ] = '\0';
      n = 0;
      for ( i = (els + 4); l->buffer[ i ] != '\0'; ++i )
         {
         elb_buffer[ n ] = l->buffer[ i ];
         ++n;
         elb_buffer[ n ] = '\0';
         }

      #if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_if(): ELSE statement is <%s>", elb_buffer );
      bwb_debug( bwb_ebuf );
      #endif

      }

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_if(): searched for ELSE statement, line is <%s>", 
      l->buffer );
   bwb_debug( bwb_ebuf );
   #endif

   /* evaluate and execute */

   if ( exp_getival( e ) != FALSE )
      {
      if ( then == FALSE )
         {
         #if PROG_ERRORS
         sprintf( bwb_ebuf, "IF without THEN" );
         bwb_error( bwb_ebuf );
         #else
         bwb_error( err_syntax );
         #endif
         }
      else
         {
	 #if INTENSIVE_DEBUG
	 sprintf( bwb_ebuf, "in bwb_if(): executing then buffer <%s>",
	    then_buffer );
	 bwb_debug( bwb_ebuf );
	 #endif
	 return cnd_xpline( l, then_buffer );
	 }
      }
   else
      {
      if ( els != FALSE )
         {
	 #if INTENSIVE_DEBUG
	 sprintf( bwb_ebuf, "in bwb_if(): executing else buffer <%s>",
	    elb_buffer );
	 bwb_debug( bwb_ebuf );
	 #endif
	 return cnd_xpline( l, elb_buffer );
	 }
      }

   /* if neither then nor else were found */

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

int
cnd_thenels( char *buffer, int position, int *then, int *els )
   {
   int loop, t_pos, b_pos, p_word;
   char tbuf[ MAXSTRINGSIZE + 1 ];

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in cnd_thenelse(): entry, line is <%s>", buffer );
   bwb_debug( bwb_ebuf );
   #endif

   /* set then and els to FALSE initially */

   *then = *els = FALSE;

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
            return TRUE;
         case ' ':                      /* whitespace = end of word */
         case '\t':

            #if INTENSIVE_DEBUG
            sprintf( bwb_ebuf, "in cnd_thenels(): word is <%s>", tbuf );
            bwb_debug( bwb_ebuf );
            #endif

            if ( strncmp( tbuf, "THEN", (size_t) 4 ) == 0 )
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
            else if ( strncmp( tbuf, "ELSE", (size_t) 4 ) == 0 )
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
            ++b_pos;
            p_word = b_pos;
            t_pos = 0;
            tbuf[ 0 ] = '\0';
            break;

         default:
            if ( islower( buffer[ b_pos ] ) != FALSE )
               {
               tbuf[ t_pos ] = toupper( buffer[ b_pos ] );
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

/***************************************************************

        FUNCTION:       cnd_xpline()

        DESCRIPTION:    This function interprets a portion of a
                        command line.

***************************************************************/

struct bwb_line *
cnd_xpline( struct bwb_line *l, char *buffer )
   {
   char l_buffer[ MAXSTRINGSIZE + 1 ];
   struct bwb_line *nl;
   struct bwb_line *rl;

   if ( ( nl = calloc( 1, sizeof( struct bwb_line ) ) ) == NULL )
      {
      bwb_error( err_getmem );
      return l;
      }

   strncpy( l_buffer, buffer, MAXSTRINGSIZE );

   nl->marked = FALSE;
   nl->next = l->next;
   nl->number = l->number;
   nl->position = 0;
   nl->buffer = l_buffer;

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in cnd_xpline(): interpret line portion <%s>",
      nl->buffer );
   bwb_debug( bwb_ebuf );
   #endif

   rl = bwb_xline( nl );

   if ( nl->cmdnum == getcmdnum( "GOTO" ) )
      {
      return rl;
      }
   
   else if ( nl->cmdnum == getcmdnum( "GOSUB" ) )
      {
      return rl;
      }
   
   else if ( nl->cmdnum == getcmdnum( "RETURN" ) )
      {
      #if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in cnd_xpline(): RETURN returning line <%d>",
         rl->number );
      bwb_debug( bwb_ebuf );
      #endif

      l->cmdnum = getcmdnum( "RETURN" );
      l->marked = FALSE;

      return rl;
      }
   
   /* in all other cases, return the next line after the current one */

   l->next->position = 0;
   return l->next;

   }

/***    WHILE-WEND ***/

/***************************************************************

        FUNCTION:       bwb_while()

        DESCRIPTION:    This function handles the BASIC WHILE
                        statement.

***************************************************************/

struct bwb_line *
bwb_while( struct bwb_line *l )
   {
   register int n;
   struct bwb_line *wendnext;
   struct exp_ese *e;

   /* find the WEND statement */

   wendnext = find_wend( l );
   if ( wendnext == NULL )
      {
      l->next->position = 0;                           /* error routine has already been called */
      return l->next;                           /* error routine has already been called */
      }

   /* call bwb_exp() to interpret the expression */

   e = bwb_exp( l->buffer, FALSE, &( l->position ) );

   if ( exp_getival( e ) == TRUE )
      {
      ws[ ws_counter ] = l;
      ++ws_counter;
      l->next->position = 0;
      return l->next;
      }
   else
      {
      wendnext->position = 0;
      return wendnext;
      }

   }

/***************************************************************

        FUNCTION:       bwb_wend()

        DESCRIPTION:    This function handles the BASIC WEND
                        statement.

***************************************************************/

struct bwb_line *
bwb_wend( struct bwb_line *l )
   {

   if ( ws_counter <= 0 )
      {
      #if PROG_ERRORS
      sprintf( bwb_ebuf, "in bwb_wend(): WEND without WHILE" );
      bwb_error( bwb_ebuf );
      #else
      bwb_error( err_syntax  );
      #endif
      l->next->position = 0;
      return l->next;
      }

   --ws_counter;
   ws[ ws_counter ]->position = 0;
   return ws[ ws_counter ];
   }

/***************************************************************

        FUNCTION:       find_wend()

        DESCRIPTION:    This function searches for a line containing
                        a WEND statement corresponding to a previous
                        WHILE statement.

***************************************************************/

struct bwb_line *
find_wend( struct bwb_line *l )
   {
   struct bwb_line *current;
   register int w_level;
   int position;

   w_level = 1;
   for ( current = l->next; current != &bwb_end; current = current->next )
      {
      position = 0;
      line_start( current->buffer, &position, &( current->lnpos ),
         &( current->lnum ),
         &( current->cmdpos ),
         &( current->cmdnum ),
         &( current->startpos ) );
      current->position = current->startpos;

      if ( current->cmdnum > -1 )
         {

         if ( bwb_cmdtable[ current->cmdnum ].vector == bwb_while )
            {
            ++w_level;

            #if INTENSIVE_DEBUG
            sprintf( bwb_ebuf, "in bwb_wend(): found WHILE at line %d, level %d",
               current->number, w_level );
            bwb_debug( bwb_ebuf );
            #endif

            }
         else if ( bwb_cmdtable[ current->cmdnum ].vector == bwb_wend )
            {
            --w_level;

            #if INTENSIVE_DEBUG
            sprintf( bwb_ebuf, "in bwb_wend(): found WEND at line %d, level %d",
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
   sprintf( bwb_ebuf, "WHILE without WEND" );
   bwb_error( bwb_ebuf );
   #else
   bwb_error( err_syntax  );
   #endif

   return NULL;

   }

/***    FOR-NEXT ***/

/***************************************************************

        FUNCTION:       bwb_for()

        DESCRIPTION:    This function handles the BASIC FOR
                        statement.

	LIMITATION:	As implemented here, the NEXT statement
			must be at the beginning of a program
			line; a NEXT statement following a colon
			will not be recognized and may cause the
			program to hang up.

***************************************************************/

struct bwb_line *
bwb_for( struct bwb_line *l )
   {
   register int n;
   int e, loop;
   int to, step, p;
   struct exp_ese *exp;
   struct bwb_variable *v;
   char tbuf[ MAXSTRINGSIZE + 1 ];

   /* get the variable name */

   exp_getvfname( &( l->buffer[ l->startpos ] ), tbuf );
   v = var_find( tbuf );

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_for(): variable name <%s>.", v->name );
   bwb_debug( bwb_ebuf );
   #endif

   /* increment the FOR stack counter and check it */

   ++fs_counter;                                /* increment the counter */
   if ( fs_counter >= FORLEVELS )
      {
      #if PROG_ERRORS
      sprintf( bwb_ebuf, "Maximum FOR levels exceeded." );
      bwb_error( bwb_ebuf );
      #else
      bwb_error( err_overflow );
      #endif
      l->next->position = 0;
      return l->next;
      }

   /* initialize the FOR stack element for this level */

   fs[ fs_counter ].nextline = l;               /* set next line for loop */
   fs[ fs_counter ].variable = v;            /* set variable */
   fs[ fs_counter ].step = 1;                   /* set default step */
   l->position += strlen( tbuf );           /* set current position to end of variable */

   /* at this point one should find an equals sign ('=') */

   loop = TRUE;
   while( loop == TRUE )
      {
      switch( l->buffer[ l->position ] )
         {
         case '=':                              /* found equals sign; continue */
            ++l->position;
            loop = FALSE;
            break;
         case ' ':                              /* whitespace */
         case '\t':
            ++l->position;
            break;
         default:
            #if PROG_ERRORS
            sprintf( bwb_ebuf, "in bwb_for(): failed to find equals sign, buf <%s>",
               &( l->buffer[ l->position ] ) );
            bwb_error( bwb_ebuf );
            #else
            bwb_error( err_syntax );
            #endif
            l->next->position = 0;
            return l->next;
         }
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
      l->next->position = 0;
      return l->next;
      }

   /* copy initial value to small buffer and evaluate it */

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
   var_setival( fs[ fs_counter ].variable, exp_getival( exp ) );

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_for(): initial value <%d> pos <%d>",
      exp_getival( exp ), l->position );
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
   fs[ fs_counter ].target = exp_getival( exp );

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_for(): target value <%d> pos <%d>",
      exp_getival( exp ), l->position );
   bwb_debug( bwb_ebuf );
   #endif

   /* If there is a STEP statement, copy it to the small buffer
      and evaluate it */

   if ( step > 1 )
      {
      tbuf[ 0 ] = '\0';
      p = 0;
      l->position = step + 4;

      for ( n = l->position; n < strlen( l->buffer ); ++n )
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
      fs[ fs_counter ].step = exp_getival( exp );

      #if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_for(): step value <%d>",
         exp_getival( exp ) );
      bwb_debug( bwb_ebuf );
      #endif

      }

   /* set position in current line for reset */

   fs[ fs_counter ].position = l->position;     /* position for reset */

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_for(): ready to exit, position <%d>",
      l->position );
   bwb_debug( bwb_ebuf );
   #endif

   /* proceed with processing */

   l->next->position = 0;
   return l->next;

   }

/***************************************************************

        FUNCTION:       bwb_next()

        DESCRIPTION:    This function handles the BASIC NEXT
                        statement.

	LIMITATION:	As implemented here, the NEXT statement
			must be at the beginning of a program
			line; a NEXT statement following a colon
			will not be recognized and may cause the
			program to hang up.

***************************************************************/

struct bwb_line *
bwb_next( struct bwb_line *l )
   {
   register int c;
   int stack_level;
   char tbuf[ MAXSTRINGSIZE + 1 ];

   /* Check the integrity of the FOR stack */

   if ( fs_counter <= 0 )
      {
      #if PROG_ERRORS
      sprintf( bwb_ebuf, "NEXT without FOR" );
      bwb_error( bwb_ebuf );
      #else
      bwb_error( err_nf );
      #endif
      l->next->position = 0;
      return l->next;
      }

   /* Check for argument */

   adv_ws( l->buffer, &( l->position ) );
   switch( l->buffer[ l->position ] )
      {
      case '\0':
      case '\n':
      case '\r':
      case ':':
         #if PROG_ERRORS
         sprintf( bwb_ebuf, "at line %d: NEXT: no variable specified.",
            l->number );
         bwb_error( bwb_ebuf );
         #else
         bwb_error( err_syntax );
         #endif
         l->next->position = 0;
         return l->next;
      default:
         break;
      }

   adv_element( l->buffer, &( l->position ), tbuf );

   stack_level = 0;
   for ( c = 1; c <= fs_counter; ++c )
      {
      if ( strcmp( tbuf, fs[ c ].variable->name ) == 0 )
         {
         stack_level = c;
         }
      }
   if ( stack_level == 0  )
      {
      #if PROG_ERRORS
      sprintf( bwb_ebuf, "NEXT has invalid variable" );
      bwb_error( bwb_ebuf );
      #else
      bwb_error( err_syntax );
      #endif
      l->next->position = 0;
      return l->next;
      }

   /* we now have a valid stack level; now increment the variable value */

   var_setival( fs[ stack_level ].variable,
      var_getival( fs[ stack_level ].variable ) + fs[ stack_level ].step );

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_next(): variable <%s> is <%d>",
      fs[ stack_level ].variable->name,
      var_getival( fs[ stack_level ].variable ) );
   bwb_debug( bwb_ebuf );
   #endif

   /* check for completion of the loop */

   if ( fs[ stack_level ].step > 0 )            /* if step is positive */
      {
      if ( var_getival( fs[ stack_level ].variable )
         > fs[ stack_level ].target )
         {

         /* decrement the FOR stack counter and return */

         dec_fsc( stack_level );
         l->next->position = 0;
         return l->next;
         }
      }
   else                                         /* if step is negative */
      {
      if ( var_getival( fs[ stack_level ].variable )
         < fs[ stack_level ].target )
         {

         /* decrement the FOR stack counter and return */

         dec_fsc( stack_level );
         l->next->position = 0;
         return l->next;
         }
      }

   /* Target not reached: return to the top of the FOR loop */

   fs[ stack_level ].nextline->position = fs[ stack_level ].position;

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_next(): return to line <%d> position <%d> char <%c>",
      fs[ stack_level ].nextline->number,
      fs[ stack_level ].nextline->position,
      fs[ stack_level ].nextline->buffer[ fs[ stack_level ].nextline->position ] );
   bwb_debug( bwb_ebuf );
   #endif

   return fs[ stack_level ].nextline;

   }

/***************************************************************

        FUNCTION:       cnd_tostep()

        DESCRIPTION:    This function searches through the
                        <buffer> beginning at point <position>
                        and attempts to find positions of TO
                        and STEP statements.

***************************************************************/

int
cnd_tostep( char *buffer, int position, int *to, int *step )
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

            if ( strncmp( tbuf, "TO", (size_t) 2 ) == 0 )
               {

               #if INTENSIVE_DEBUG
               sprintf( bwb_ebuf, "in cnd_tostep(): TO found at position <%d>.",
                  p_word );
               bwb_debug( bwb_ebuf );
               #endif

               *to = p_word;
               }
            else if ( strncmp( tbuf, "STEP", (size_t) 4 ) == 0 )
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
               tbuf[ t_pos ] = toupper( buffer[ b_pos ] );
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

int
var_setival( struct bwb_variable *v, int i )
   {

   switch( v->type )
      {
      case INTEGER:
         * var_findival( v, v->array_pos ) = i;
         break;
      case DOUBLE:
         * var_finddval( v, v->array_pos ) = (double) i;
         break;
      case SINGLE:
         * var_findfval( v, v->array_pos ) = (float) i;
         break;
      default:
         #if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in var_setival(): variable <%s> is not a number",
            v->name );
         bwb_error( bwb_ebuf );
         #else
         bwb_error( err_mismatch );
         #endif
      }

   /* successful assignment */

   return TRUE;

   }

int
dec_fsc( int level )
   {
   register int l;

   --fs_counter;
   if ( fs_counter < 0 )
      {
      fs_counter = 0;
      #if PROG_ERRORS
      sprintf( bwb_ebuf, "FOR stack counter decremented below 0." );
      bwb_error( bwb_ebuf );
      #else
      bwb_error( err_overflow );
      #endif
      return FALSE;
      }

   /* pull down the FOR stack if necessary */

   l = level;
   while( l <= fs_counter )
      {
      memcpy( &( fs[ l ] ), &( fs[ l + 1 ] ), sizeof( struct fse ) );
      }

   /* return */

   return TRUE;

   }

