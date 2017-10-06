/***************************************************************

        bwb_cmd.c       Miscellaneous Commands
                        for Bywater BASIC Interpreter

                        Commands:       RUN
                                        LET
                                        LOAD
                                        MERGE
                                        CHAIN
                                        NEW
                                        RENUM
                                        SAVE
                                        LIST
                                        GOTO
                                        GOSUB
                                        RETURN
                                        ON
                                        STOP
                                        END
                                        SYSTEM
                                        TRON
                                        TROFF
                                        DELETE
                                        RANDOMIZE
					ENVIRON
                                        CMDS            (*debugging)

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

#if HAVE_SIGNAL
#include <signal.h>
#endif

char err_gosubl[ MAXVARNAMESIZE + 1 ] = { '\0' }; /* line for error GOSUB */

#if ANSI_C
extern struct bwb_line *bwb_xnew( struct bwb_line *l );
extern struct bwb_line *bwb_onerror( struct bwb_line *l );
struct bwb_line *bwb_donum( struct bwb_line *l );
struct bwb_line *bwb_dounnum( struct bwb_line *l );
static int xl_line( FILE *file, struct bwb_line *l );
#else
extern struct bwb_line *bwb_xnew();
extern struct bwb_line *bwb_onerror();
struct bwb_line *bwb_donum();
struct bwb_line *bwb_dounnum();
static int xl_line();
#endif

/***************************************************************

        FUNCTION:       bwb_null()

	DESCRIPTION:    This is a null command function body, and
			can be used as the basis for developing
			new BASIC commands.

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_null( struct bwb_line *l )
#else
struct bwb_line *
bwb_null( l )
   struct bwb_line *l;
#endif
   {

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_null(): NULL command" );
   bwb_debug( bwb_ebuf );
#endif

#if MULTISEG_LINES
   adv_eos( l->buffer, &( l->position ));
#endif

   return bwb_zline( l );
   }

/***************************************************************

	FUNCTION:       bwb_rem()

	DESCRIPTION:    This C function implements the BASIC rem
			(REMark) command, ignoring the remainder
			of the line.

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_rem( struct bwb_line *l )
#else
struct bwb_line *
bwb_rem( l )
   struct bwb_line *l;
#endif
   {

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_rem(): REM command" );
   bwb_debug( bwb_ebuf );
#endif

   /* do not use bwb_zline() here; blank out remainder of line */

   l->next->position = 0;
   return l->next;

   }

/***************************************************************

        FUNCTION:       bwb_let()

	DESCRIPTION:    This C function implements the BASIC
			LET assignment command, even if LET
			is implied and not explicit.

	SYNTAX:		LET variable = expression

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_let( struct bwb_line *l )
#else
struct bwb_line *
bwb_let( l )
   struct bwb_line *l;
#endif
   {

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_let(): pos <%d> line <%s>",
      l->position, l->buffer );
   bwb_debug( bwb_ebuf );
#endif

   /* Call the expression interpreter to evaluate the assignment */

   bwb_exp( l->buffer, TRUE, &( l->position ) );


   return bwb_zline( l );

   }

/***************************************************************

        FUNCTION:       bwb_go

        DESCRIPTION:	This C function implements the BASIC
			GO command, branching appropriately to
			GOTO or GOSUB.

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_go( struct bwb_line *l )
#else
struct bwb_line *
bwb_go( l )
   struct bwb_line *l;
#endif
   {
   char tbuf[ MAXSTRINGSIZE + 1 ];

   adv_element( l->buffer, &( l->position ), tbuf );
   bwb_strtoupper( tbuf );

   if ( strcmp( tbuf, CMD_XSUB ) == 0 )
      {
      return bwb_gosub( l );
      }

   if ( strcmp( tbuf, CMD_XTO ) == 0 )
      {
      return bwb_goto( l );
      }

#if PROG_ERRORS
   sprintf( bwb_ebuf, "in bwb_go(): Nonsense following GO" );
   bwb_error( bwb_ebuf );
#else
   bwb_error( err_syntax );
#endif

   return bwb_zline( l );

   }


	
/***************************************************************

        FUNCTION:       bwb_goto

        DESCRIPTION:	This C function implements the BASIC
			GOTO command.

   	SYNTAX:		GOTO line | label

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_goto( struct bwb_line *l )
#else
struct bwb_line *
bwb_goto( l )
   struct bwb_line *l;
#endif
   {
   struct bwb_line *x;
   char tbuf[ MAXSTRINGSIZE + 1 ];

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_goto(): entered function" );
   bwb_debug( bwb_ebuf );
#endif

   /* Check for argument */

   adv_ws( l->buffer, &( l->position ) );
   switch( l->buffer[ l->position ] )
      {
      case '\0':
      case '\n':
      case '\r':
      case ':':
         bwb_error( err_noln );

         return bwb_zline( l );
      default:
         break;
      }

   adv_element( l->buffer, &( l->position ), tbuf );

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_goto(): buffer has <%s>", tbuf );
   bwb_debug( bwb_ebuf );
#endif

   /* check for target label */

#if STRUCT_CMDS

   if ( isalpha( tbuf[ 0 ] ))
      {

#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_goto(): found LABEL, <%s>", tbuf );
      bwb_debug( bwb_ebuf );
#endif

      x = find_label( tbuf );
      x->position = 0;
      return x;
      }

   else
      {
      for ( x = &CURTASK bwb_start; x != &CURTASK bwb_end; x = x->next )
         {
         if ( x->number == atoi( tbuf ) )
            {

            /* found the requested number */

#if INTENSIVE_DEBUG
            sprintf( bwb_ebuf, "in bwb_goto(): returning line <%d>", x->number );
            bwb_debug( bwb_ebuf );
#endif

            x->position = 0;
            return x;
            }
         }
      }

#else

   for ( x = &CURTASK bwb_start; x != &CURTASK bwb_end; x = x->next )
      {
      if ( x->number == atoi( tbuf ) )
         {

         /* found the requested number */

#if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in bwb_goto(): returning line <%d>", x->number );
         bwb_debug( bwb_ebuf );
#endif

         x->position = 0;
         return x;
         }
      }

#endif

   sprintf( bwb_ebuf, err_lnnotfound, atoi( tbuf ) );
   bwb_error( bwb_ebuf );

   return bwb_zline( l );
   }

/***************************************************************

        FUNCTION:       bwb_gosub()

	DESCRIPTION:    This function implements the BASIC GOSUB
			command.

   	SYNTAX:		GOSUB line | label

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_gosub( struct bwb_line *l )
#else
struct bwb_line *
bwb_gosub( l )
   struct bwb_line *l;
#endif
   {
   struct bwb_line *x;
   char atbuf[ MAXSTRINGSIZE + 1 ];

   /* Check for argument */

   adv_ws( l->buffer, &( l->position ) );
   switch( l->buffer[ l->position ] )
      {
      case '\0':
      case '\n':
      case '\r':
      case ':':
         sprintf( bwb_ebuf, err_noln );
         bwb_error( bwb_ebuf );

         return bwb_zline( l );
      default:
         break;
      }

   /* get the target line number in tbuf */

   adv_element( l->buffer, &( l->position ), atbuf );

#if MULTISEG_LINES
   adv_eos( l->buffer, &( l->position ));
#endif

   /* check for a label rather than line number */

#if STRUCT_CMDS

   if ( isalpha( atbuf[ 0 ] ))
      {
      x = find_label( atbuf );

#if MULTISEG_LINES
      CURTASK excs[ CURTASK exsc ].position = l->position;
#endif

      bwb_incexec();

      /* set the new position to x and return x */

      x->cmdnum = -1;
      x->marked = FALSE;
      x->position = 0;
      bwb_setexec( x, 0, EXEC_GOSUB );

      return x;

      }

#endif

   for ( x = &CURTASK bwb_start; x != &CURTASK bwb_end; x = x->next )
      {

      if ( x->number == atoi( atbuf ))
         {

         /* this is the line we are looking for */

#if MULTISEG_LINES
         CURTASK excs[ CURTASK exsc ].position = l->position;
#endif

         /* increment the EXEC stack */

         bwb_incexec();

         /* set the new position to x and return x */

         x->cmdnum = -1;
         x->marked = FALSE;
         x->position = 0;
         bwb_setexec( x, 0, EXEC_GOSUB );

         return x;
         }
      }

   /* the requested line was not found */

   sprintf( bwb_ebuf, err_lnnotfound, atoi( atbuf ) );
   bwb_error( bwb_ebuf );

   return bwb_zline( l );

   }

/***************************************************************

        FUNCTION:       bwb_return()

	DESCRIPTION:    This function implements the BASIC RETURN
			command.

   	SYNTAX:		RETURN

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_return( struct bwb_line *l )
#else
struct bwb_line *
bwb_return( l )
   struct bwb_line *l;
#endif
   {

#if  INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_return() at line <%d> cmdnum <%d>",
      l->number, l->cmdnum );
   bwb_debug( bwb_ebuf );
#endif

   /* see if old position was "GOSUB" */

/* JBV 1/20/97 */
/*
   if ( CURTASK excs[ CURTASK exsc ].code != EXEC_GOSUB )
      {
      bwb_error( err_retnogosub );
      }
*/

   /*--------------------------------------------------------------*/
   /* Make sure we are at the right stack level!                   */
   /* If we aren't (which could happen for legit reasons), fix the */
   /* exec stack.                                                  */
   /* JBV, 1/20/97                                                 */
   /*--------------------------------------------------------------*/
   while ( CURTASK excs[ CURTASK exsc ].code != EXEC_GOSUB )
   {
   bwb_decexec();
   if ( CURTASK excs[ CURTASK exsc ].code == EXEC_NORM ) /* End of the line? */
      {
      bwb_error( err_retnogosub );
      }
   }

   /* decrement the EXEC stack counter */

   bwb_decexec();

   /* restore position and return old line */

#if MULTISEG_LINES
   CURTASK excs[ CURTASK exsc ].line->position
      = CURTASK excs[ CURTASK exsc ].position;
   return CURTASK excs[ CURTASK exsc ].line;
#else
   CURTASK excs[ CURTASK exsc ].line->next->position = 0;
   return CURTASK excs[ CURTASK exsc ].line->next;
#endif

   }

/***************************************************************

        FUNCTION:       bwb_on

        DESCRIPTION:    This function implements the BASIC ON...
                        GOTO or ON...GOSUB statements.

			It will also detect the ON ERROR... statement
			and pass execution to bwb_onerror().

   	SYNTAX:		ON variable GOTO|GOSUB line[,line,line,...]

	LIMITATION:     As implemented here, the ON...GOSUB|GOTO
			command recognizes line numbers only
			(not labels).

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_on( struct bwb_line *l )
#else
struct bwb_line *
bwb_on( l )
   struct bwb_line *l;
#endif
   {
   struct bwb_line *oline, *x;
   char varname[ MAXVARNAMESIZE + 1 ];
   char tbuf[ MAXSTRINGSIZE + 1 ];
   static int p;
   struct exp_ese *rvar;
   int v;
   int loop;
   int num_lines;
   int command;
   int lines[ MAX_GOLINES ];
   char sbuf[ 7 ];

   /* Check for argument */

   adv_ws( l->buffer, &( l->position ) );

   switch( l->buffer[ l->position ] )
      {
      case '\0':
      case '\n':
      case '\r':
      case ':':
         sprintf( bwb_ebuf, err_incomplete );
         bwb_error( bwb_ebuf );

         return bwb_zline( l );
      default:
         break;
      }

   /* get the variable name or numerical constant */

   adv_element( l->buffer, &( l->position ), varname );

   /* check for ON ERROR statement */

#if COMMON_CMDS
   strncpy( sbuf, varname, 6 );
   bwb_strtoupper( sbuf );
   if ( strcmp( sbuf, CMD_XERROR ) == 0 )
      {
#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_on(): detected ON ERROR" );
      bwb_debug( bwb_ebuf );
#endif
      return bwb_onerror( l );
      }
#endif	/* COMMON_CMDS */

   /* evaluate the variable name or constant */

   p = 0;
   rvar = bwb_exp( varname, FALSE, &p );
   v = (int) exp_getnval( rvar );

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_on(): value is <%d>", v );
   bwb_debug( bwb_ebuf );
#endif

   /* Get GOTO or GOSUB statements */

   adv_element( l->buffer, &( l->position ), tbuf );
   bwb_strtoupper( tbuf );
   if ( strncmp( tbuf, CMD_GOTO, (size_t) strlen( CMD_GOTO ) ) == 0 )
      {
      command = getcmdnum( CMD_GOTO );
      }
   else if ( strncmp( tbuf, CMD_GOSUB, (size_t) strlen( CMD_GOSUB ) ) == 0 )
      {
      command = getcmdnum( CMD_GOSUB );
      }
   else
      {
      sprintf( bwb_ebuf, ERR_ONNOGOTO );
      bwb_error( bwb_ebuf );

      return bwb_zline( l );
      }

   num_lines = 0;

   loop = TRUE;
   while( loop == TRUE )
      {

      /* read a line number */

      inp_adv( l->buffer, &( l->position ) );
      adv_element( l->buffer, &( l->position ), tbuf );

      lines[ num_lines ] = atoi( tbuf );

      ++num_lines;

      if ( num_lines >= MAX_GOLINES )
         {
         loop = FALSE;
         }

      /* check for end of line */

      adv_ws( l->buffer, &( l->position ) );
      switch( l->buffer[ l->position ] )
         {
         case '\0':
         case '\n':
         case '\r':
         case ':':
            loop = FALSE;
            break;
         }

      }

   /* advance to end of segment */

#if MULTISEG_LINES
   adv_eos( l->buffer, &( l->position ) );
#endif

   /* Be sure value is in range */

   if ( ( v < 1 ) || ( v > num_lines ))
      {
      sprintf( bwb_ebuf, err_valoorange );
      bwb_error( bwb_ebuf );

      return bwb_zline( l );
      }

   if ( command == getcmdnum( CMD_GOTO ))
      {

#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_on(): executing ON...GOTO" );
      bwb_debug( bwb_ebuf );
#endif

      oline = NULL;
      for ( x = &CURTASK bwb_start; x != &CURTASK bwb_end; x = x->next )
	 {
	 if ( x->number == lines[ v - 1 ] )
	    {

	    /* found the requested number */

#if INTENSIVE_DEBUG
	    sprintf( bwb_ebuf, "in bwb_on(): returning line <%d>", x->number );
	    bwb_debug( bwb_ebuf );
#endif

	    oline = x;
	    }
	 }

      if ( oline == NULL )
	 {
	 bwb_error( err_lnnotfound );
	 return bwb_zline( l );
	 }

      oline->position = 0;
      bwb_setexec( oline, 0, CURTASK excs[ CURTASK exsc ].code );

      return oline;

      }

   else if ( command == getcmdnum( CMD_GOSUB ))
      {

#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_on(): executing ON...GOSUB" );
      bwb_debug( bwb_ebuf );
#endif

      /* save current stack level */

      bwb_setexec( l, l->position, CURTASK excs[ CURTASK exsc ].code );

      /* increment exec stack */

      bwb_incexec();

      /* get memory for line and buffer */

      /* Revised to CALLOC pass-thru call by JBV */
      if ( ( oline = CALLOC( 1, sizeof( struct bwb_line ), "bwb_on") ) == NULL )
	 {
#if PROG_ERRORS
	 bwb_error( "in bwb_on(): failed to find memory for oline" );
#else
	 bwb_error( err_getmem );
#endif
	 }
      /* Revised to CALLOC pass-thru call by JBV */
      if ( ( oline->buffer = CALLOC( 1, MAXSTRINGSIZE + 1, "bwb_on") ) == NULL )
	 {
#if PROG_ERRORS
	 bwb_error( "in bwb_on(): failed to find memory for oline buffer" );
#else
	 bwb_error( err_getmem );
#endif
	 }

      CURTASK excs[ CURTASK exsc ].while_line = oline;

      sprintf( oline->buffer, "%s %d", CMD_GOSUB, lines[ v - 1 ] );
      oline->marked = FALSE;
      oline->position = 0;
      oline->next = l->next;
      bwb_setexec( oline, 0, EXEC_ON );
      return oline;
      }

   else
      {
#if PROG_ERRORS
      sprintf( bwb_ebuf, "in bwb_on(): invalid value for command." );
      bwb_error( bwb_ebuf );
#else
      bwb_error( err_syntax );
#endif

      return bwb_zline( l );
      }

   }

/***************************************************************

        FUNCTION:       bwb_stop()

	DESCRIPTION:    This C function implements the BASIC
			STOP command, interrupting program flow
			at a specific point.

   	SYNTAX:		STOP

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_stop( struct bwb_line *l )
#else
struct bwb_line *
bwb_stop( l )
   struct bwb_line *l;
#endif
   {

#if HAVE_SIGNAL
#if HAVE_RAISE
   raise( SIGINT );
#else
   kill( getpid(), SIGINT );
#endif
#endif

   return bwb_xend( l );
   }

/***************************************************************

        FUNCTION:       bwb_xend()

	DESCRIPTION:    This C function implements the BASIC
			END command, checking for END SUB
			or END FUNCTION, else stopping program
			execution for a simple END command.

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_xend( struct bwb_line *l )
#else
struct bwb_line *
bwb_xend( l )
   struct bwb_line *l;
#endif
   {
#if STRUCT_CMDS
   char tbuf[ MAXSTRINGSIZE + 1 ];
#endif

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_xend(): entered funtion" );
   bwb_debug( bwb_ebuf );
#endif

   /* Detect END SUB or END FUNCTION here */

#if STRUCT_CMDS
   adv_element( l->buffer, &( l->position ), tbuf );
   bwb_strtoupper( tbuf );

   if ( strcmp( tbuf, CMD_XSUB ) == 0 )
      {
      return bwb_endsub( l );
      }

   if ( strcmp( tbuf, CMD_XFUNCTION ) == 0 )
      {
      return bwb_endfnc( l );
      }

   if ( strcmp( tbuf, CMD_XIF ) == 0 )
      {
      return bwb_endif( l );
      }

   if ( strcmp( tbuf, CMD_XSELECT ) == 0 )
      {
      return bwb_endselect( l );
      }

#endif			/* STRUCT_CMDS */

   /* else a simple END statement */

   break_handler();

   return &CURTASK bwb_end;
   }

/***************************************************************

        FUNCTION:       bwb_do()

	DESCRIPTION:    This C function implements the BASIC DO
			command, also checking for the DO NUM
			and DO UNNUM commands for interactive
			programming environment.

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_do( struct bwb_line *l )
#else
struct bwb_line *
bwb_do( l )
   struct bwb_line *l;
#endif
   {
   char tbuf[ MAXSTRINGSIZE + 1 ];

   adv_element( l->buffer, &( l->position ), tbuf );
   bwb_strtoupper( tbuf );

   /* if there is no argument (with STRUCT_CMDS) then we have a
      DO-LOOP structure: pass on to bwb_doloop() in bwb_stc.c */

#if STRUCT_CMDS

   if ( strlen( tbuf ) == 0 )
      {
      return bwb_doloop( l );
      }

   if ( strcmp( tbuf, CMD_WHILE ) == 0 )
      {
      return bwb_while( l );
      }
#endif

#if INTERACTIVE
   if ( strcmp( tbuf, CMD_XNUM ) == 0 )
      {
      return bwb_donum( l );
      }

   if ( strcmp( tbuf, CMD_XUNNUM ) == 0 )
      {
      return bwb_dounnum( l );
      }
#endif				/* INTERACTIVE */

   /* if none of these occurred, then presume an error */

   bwb_error( err_syntax );
   return bwb_zline( l );
   }

/***************************************************************

        FUNCTION:       bwb_run()

        DESCRIPTION:	This C function implements the BASIC
			RUN command.

			Even though RUN is not a core statement,
			the function bwb_run() is called from
			core, so it must be present for a minimal
			implementation.

   	SYNTAX:		RUN [line]|[file-name]

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_run( struct bwb_line *l )
#else
struct bwb_line *
bwb_run( l )
   struct bwb_line *l;
#endif
   {
   struct bwb_line *current, *x;
   int go_lnumber;                /* line number to go to */
   char tbuf[ MAXSTRINGSIZE + 1 ];
   struct exp_ese *e;
   FILE *input;

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_run(): entered function. buffer <%s> pos <%d>",
      l->buffer, l->position );
   bwb_debug( bwb_ebuf );
#endif

   /* see if there is an element */

   current = NULL;
   adv_ws( l->buffer, &( l->position ) );
#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_run(): check buffer <%s> pos <%d> char <0x%x>",
      l->buffer, l->position, l->buffer[ l->position ] );
   bwb_debug( bwb_ebuf );
#endif
   switch ( l->buffer[ l->position ] )
      {
      case '\0':
      case '\n':
      case '\r':
      case ':':
#if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in bwb_run(): no argument; begin at start.next" );
         bwb_debug( bwb_ebuf );
#endif
         current = CURTASK bwb_start.next;
         e = NULL;
         break;
      default:
         e = bwb_exp( l->buffer, FALSE, &( l->position ) );
         break;
      }

   /* check its type: if it is a string, open the file and execute it */

   if (( e != NULL ) && ( e->type == STRING ))
      {
      bwb_new( l );				/* clear memory */
      str_btoc( tbuf, exp_getsval( e ) );	/* get string in tbuf */
      if ( ( input = fopen( tbuf, "r" )) == NULL )	/* open file */
         {
         sprintf( bwb_ebuf, err_openfile, tbuf );
         bwb_error( bwb_ebuf );
         }
      bwb_fload( input );		/* load program */

      /* Next line removed by JBV (unnecessary recursion asks for trouble) */
      /* bwb_run( &CURTASK bwb_start ); */         /* and call bwb_run() recursively */
      current = &CURTASK bwb_start; /* JBV */
      }

   /* else if it is a line number, execute the program in memory
      at that line number */

   /* Removed by JBV */
   /* else
      { */

      /* Removed by JBV */
      /* if ( current == NULL )
         { */

         /* Added expression type check and changed loop boundaries (JBV) */
         if (( e != NULL ) && ( e->type != STRING ))
         {
            go_lnumber = (int) exp_getnval( e );

#if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in bwb_run(): element detected <%s>, lnumber <%d>",
            tbuf, go_lnumber );
         bwb_debug( bwb_ebuf );
#endif

         for ( x = CURTASK bwb_start.next; x != &CURTASK bwb_end; x = x->next )
            {
            if ( x->number == go_lnumber )
               {
               current = x;
               }
            }
         }

      /*    } */ /* Removed by JBV */

      if ( current == NULL )
         {
         sprintf( bwb_ebuf, err_lnnotfound, go_lnumber );
         bwb_error( bwb_ebuf );
         return &CURTASK bwb_end;
         }

#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_run(): ready to run starting at line %d",
         current->number );
      bwb_debug( bwb_ebuf );
#endif

      if ( CURTASK rescan == TRUE )
         {
         bwb_scan();
         }

      current->position = 0;
      CURTASK exsc = 0;
      bwb_setexec( current, 0, EXEC_NORM );

   /*    } */ /* Removed by JBV */

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_run(): function complete." );
   bwb_debug( bwb_ebuf );
#endif

   return current;

   }

/***************************************************************

        FUNCTION:       bwb_new()

        DESCRIPTION:	This C function implements the BASIC
			NEW command.

			Even though NEW is not a core statement,
			the function bwb_run() is called from
			core, so it must be present for a minimal
			implementation.

	SYNTAX:		NEW

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_new( struct bwb_line *l )
#else
struct bwb_line *
bwb_new( l )
   struct bwb_line *l;
#endif
   {

   /* clear program in memory */

   bwb_xnew( l );

   /* clear all variables */

   bwb_clear( l );


   return bwb_zline( l );

   }

/* End of Core Functions Section */

#if INTERACTIVE

/***************************************************************

        FUNCTION:       bwb_system()

	DESCRIPTION:    This C function implements the BASIC
			SYSTEM command, exiting to the operating
			system (or calling program).  It is also
			called by the QUIT command, a functional
			equivalent for SYSTEM in Bywater BASIC.

	SYNTAX:		SYSTEM
			QUIT

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_system( struct bwb_line *l )
#else
struct bwb_line *
bwb_system( l )
   struct bwb_line *l;
#endif
   {
   prn_xprintf( stdout, "\n" );

#if INTENSIVE_DEBUG
   bwb_debug( "in bwb_system(): ready to exit" );
#endif

   bwx_terminate();
   return &CURTASK bwb_end;                 /* to make LINT happy */

   }

/***************************************************************

        FUNCTION:       bwb_load()

        DESCRIPTION:	This C function implements the BASIC
			LOAD command.

   	SYNTAX:		LOAD file-name

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_load( struct bwb_line *l )
#else
struct bwb_line *
bwb_load( l )
   struct bwb_line *l;
#endif
   {

   /* clear current contents */

   bwb_new( l );

   /* call xload function to load program in memory */

   bwb_xload( l );

   return bwb_zline( l );

   }

/***************************************************************

        FUNCTION:       bwb_xload()

        DESCRIPTION:	This C function loads a BASIC program
			into memory.

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_xload( struct bwb_line *l )
#else
struct bwb_line *
bwb_xload( l )
   struct bwb_line *l;
#endif
   {
   FILE *loadfile;
   struct exp_ese *e; /* JBV */

   /* Get an argument for filename */

   adv_ws( l->buffer, &( l->position ) );
   switch( l->buffer[ l->position ] )
      {
      case '\0':
      case '\n':
      case '\r':
      case ':':
         bwb_error( err_nofn ); /* Added by JBV (bug found by DD) */

         return bwb_zline( l );
      default:
         break;
      }

   /* Section added by JBV (bug found by DD) */
   e = bwb_exp( l->buffer, FALSE, &( l->position ) );
   if ( e->type != STRING )
      {
#if PROG_ERRORS
      sprintf( bwb_ebuf, "in bwb_xload(): Missing filespec" );
      bwb_error( bwb_ebuf );
#else
      bwb_error( err_syntax );
#endif

      return bwb_zline( l );
      }

   /* This line removed by JBV (no longer required) */
   /* bwb_const( l->buffer, CURTASK progfile, &( l->position ) ); */
   str_btoc( CURTASK progfile, exp_getsval( e ) ); /* JBV */

   if ( ( loadfile = fopen( CURTASK progfile, "r" )) == NULL )
      {
      sprintf( bwb_ebuf, err_openfile, CURTASK progfile );
      bwb_error( bwb_ebuf );

      return bwb_zline( l );
      }

   bwb_fload( loadfile );


   return bwb_zline( l );
   }

/***************************************************************

        FUNCTION:       bwb_save()

	DESCRIPTION:    This C function implements the BASIC
			SAVE command.

   	SYNTAX:		SAVE file-name

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_save( struct bwb_line *l )
#else
struct bwb_line *
bwb_save( l )
   struct bwb_line *l;
#endif
   {
   FILE *outfile;
   static char filename[ MAXARGSIZE ];
   struct exp_ese *e; /* JBV */

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_save(): entered function." );
   bwb_debug( bwb_ebuf );
#endif

   /* Get an argument for filename */

   adv_ws( l->buffer, &( l->position ) );
   switch( l->buffer[ l->position ] )
      {
      case '\0':
      case '\n':
      case '\r':
      case ':':
         bwb_error( err_nofn );

         return bwb_zline( l );
      default:
         break;
      }

   /* Section added by JBV (bug found by DD) */
   e = bwb_exp( l->buffer, FALSE, &( l->position ) );
   if ( e->type != STRING )
      {
#if PROG_ERRORS
      sprintf( bwb_ebuf, "in bwb_save(): Missing filespec" );
      bwb_error( bwb_ebuf );
#else
      bwb_error( err_syntax );
#endif

      return bwb_zline( l );
      }

   /* This line removed by JBV (no longer required) */
   /* bwb_const( l->buffer, filename, &( l->position ) ); */
   str_btoc( filename, exp_getsval( e ) ); /* JBV */

   if ( ( outfile = fopen( filename, "w" )) == NULL )
      {
      sprintf( bwb_ebuf, err_openfile, filename );
      bwb_error( bwb_ebuf );

      return bwb_zline( l );
      }

   bwb_xlist( l, outfile );
   fclose( outfile );


   return bwb_zline( l );

   }

/***************************************************************

        FUNCTION:       bwb_list()

        DESCRIPTION:	This C function implements the BASIC
			LIST command.

   	SYNTAX:		LIST line[-line]

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_list( struct bwb_line *l )
#else
struct bwb_line *
bwb_list( l )
   struct bwb_line *l;
#endif
   {
   bwb_xlist( l, stdout );

   return bwb_zline( l );
   }

/***************************************************************

        FUNCTION:       bwb_xlist()

        DESCRIPTION:	This C function lists the program in
			memory to a specified output device.

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_xlist( struct bwb_line *l, FILE *file )
#else
struct bwb_line *
bwb_xlist( l, file )
   struct bwb_line *l;
   FILE *file;
#endif
   {
   struct bwb_line *start, *end, *current;
   int s, e;
   int f, r;

   start = CURTASK bwb_start.next;
   end = &CURTASK bwb_end;

   r = bwb_numseq( &( l->buffer[ l->position ] ), &s, &e );

   /* advance to the end of the segment */

#if MULTISEG_LINES
   adv_eos( l->buffer, &( l->position ));
#endif

   if (( r == FALSE ) || ( s == 0 ))
      {
      s = CURTASK bwb_start.next->number;
      }

   if ( e == 0 )
      {
      e = s;
      }

   if ( r == FALSE )
      {
      for ( current = CURTASK bwb_start.next; current != &CURTASK bwb_end; current = current->next )
         {
         if ( current->next == &CURTASK bwb_end )
            {
            e = current->number;
            }
         }
      }

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_xlist(): LBUFFER sequence is %d-%d", s, e );
   bwb_debug( bwb_ebuf );
#endif

   /* abort if either number == (MAXLINENO + 1) which denotes CURTASK bwb_end */

   if ( ( s == (MAXLINENO + 1)) || ( e == (MAXLINENO + 1 ) ) )
      {

      return bwb_zline( l );
      }

   /* Now try to find the actual lines in memory */

   f = FALSE;

   for ( current = CURTASK bwb_start.next; current != &CURTASK bwb_end; current = current->next )
      {
      if ( current != l )
         {
         if (( current->number == s ) && ( f == FALSE ))
            {
            f = TRUE;
	    start = current;

#if INTENSIVE_DEBUG
	    sprintf( bwb_ebuf, "in bwb_xlist(): start line number is <%d>",
               s );
            bwb_debug( bwb_ebuf );
#endif

            }
         }
      }

   /* check and see if a line number was found */

   if ( f == FALSE )
      {
      sprintf( bwb_ebuf, err_lnnotfound, s );
      bwb_error( bwb_ebuf );

      return bwb_zline( l );
      }

   if ( e >= s )
      {
      for ( current = CURTASK bwb_start.next; current != &CURTASK bwb_end; current = current->next )
         {
         if ( current != l )
            {
            if ( current->number == e )
               {
#if INTENSIVE_DEBUG
	       sprintf( bwb_ebuf, "in bwb_xlist(): end line number is <%d>",
                  current->next->number );
               bwb_debug( bwb_ebuf );
#endif

               end = current->next;
               }
            }
         }
      }
   else
      {
      end = start;
      }

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_xlist(): line sequence is <%d-%d>",
      start->number, end->number );
   bwb_debug( bwb_ebuf );
#endif

   /* previous should now be set to the line previous to the
      first in the omission list */

   /* now go through and list appropriate lines */

   if ( start == end )
      {
#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_xlist(): start == end" );
      bwb_debug( bwb_ebuf );
#endif
      xl_line( file, start );
      }
   else
      {
      for ( current = start; current != end; current = current->next )
         {
         xl_line( file, current );
         }
      }

   return bwb_zline( l );

   }

/***************************************************************

	FUNCTION:       xl_line()

	DESCRIPTION:    This function lists a single program
			line to a specified device of file.
			It is called by bwb_xlist();

***************************************************************/

#if ANSI_C
static int
xl_line( FILE *file, struct bwb_line *l )
#else
static int
xl_line( file, l )
   FILE *file;
   struct bwb_line *l;
#endif
   {
   char tbuf[ MAXSTRINGSIZE + 1 ];

   if (( file == stdout ) || ( file == stderr ))
      {

      if ( l->xnum == (char) TRUE ) /* Better recast this one (JBV) */
	 {
	 sprintf( tbuf, "%7d: %s\n", l->number, l->buffer );
	 }
      else
	 {
	 sprintf( tbuf, "       : %s\n", l->buffer );
	 }

      prn_xprintf( file, tbuf );
      }
   else
      {

      if ( l->xnum == (char) TRUE ) /* Better recast this one (JBV) */
	 {
	 fprintf( file, "%d %s\n", l->number, l->buffer );
	 }
      else
	 {
	 fprintf( file, "%s\n", l->buffer );
	 }

      }

   return TRUE;
   }

/***************************************************************

        FUNCTION:       bwb_delete()

	DESCRIPTION:    This C function implements the BASIC
			DELETE command for interactive programming,
			deleting a specified program line (or lines)
			from memory.

   	SYNTAX:		DELETE line[-line]

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_delete( struct bwb_line *l )
#else
struct bwb_line *
bwb_delete( l )
   struct bwb_line *l;
#endif
   {
   struct bwb_line *start, *end, *current, *previous, *p, *next;
   static int s, e;
   int f;

   previous = &CURTASK bwb_start;
   start = CURTASK bwb_start.next;
   end = &CURTASK bwb_end;

   bwb_numseq( &( l->buffer[ l->position ] ), &s, &e );

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_delete(): LBUFFER sequence is %d-%d", s, e );
   bwb_debug( bwb_ebuf );
#endif

   /* advance to the end of the segment */

#if MULTISEG_LINES
   adv_eos( l->buffer, &( l->position ));
#endif

   /* Now try to find the actual lines in memory */

   previous = p = &CURTASK bwb_start;
   f = FALSE;

   for ( current = CURTASK bwb_start.next; current != &CURTASK bwb_end; current = current->next )
      {
      if ( current != l )
         {
         /* Following line revised by JBV */
         if (( current->xnum == (char) TRUE ) && ( current->number == s ))
            {
            f = TRUE;
            previous = p;
            start = current;

#if INTENSIVE_DEBUG
            sprintf( bwb_ebuf, "in bwb_delete(): start line number is <%d>",
               s );
            bwb_debug( bwb_ebuf );
#endif

            }
         }
      p = current;
      }

   /* check and see if a line number was found */

   if ( f == FALSE )
      {
      sprintf( bwb_ebuf, err_lnnotfound, s );
      bwb_error( bwb_ebuf );

      return bwb_zline( l );
      }

   if ( e > s )
      {
      for ( current = CURTASK bwb_start.next; current != &CURTASK bwb_end; current = current->next )
         {
         if ( current != l )
            {
            /* Following line revised by JBV */
            if (( current->xnum == (char) TRUE) &&  ( current->number == e ))
               {
#if INTENSIVE_DEBUG
	       sprintf( bwb_ebuf, "in bwb_delete(): end line number is <%d>",
		  e );
	       bwb_debug( bwb_ebuf );
#endif

               end = current->next;
               }
            }
         }
      }
   else
      {
      end = start->next;
      }

   /* previous should now be set to the line previous to the
      first in the omission list */

   /* now go through and delete appropriate lines */

   current = start;
   while (( current != end ) && ( current != &CURTASK bwb_end ))
      {
      next = current->next;

#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_delete(): deleting line %d",
         current->number );
      bwb_debug( bwb_ebuf );
#endif

      /* free line memory */

      bwb_freeline( current );

      /* recycle */

      current = next;
      }

   /* reset link */

   previous->next = current;


   return bwb_zline( l );
   }

/***************************************************************

        FUNCTION:       bwb_donum()

	DESCRIPTION:    This function implements the BASIC DO
			NUM command, numbering all program lines
			in memory in increments of 10 beginning
			at 10.

	SYNTAX:		DO NUM

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_donum( struct bwb_line *l )
#else
struct bwb_line *
bwb_donum( l )
   struct bwb_line *l;
#endif
   {
   struct bwb_line *current;
   register int lnumber;

   lnumber = 10;
   for ( current = bwb_start.next; current != &bwb_end; current = current->next )
      {
      current->number = lnumber;
      current->xnum = TRUE;

      lnumber += 10;
      if ( lnumber >= MAXLINENO )
         {
         return bwb_zline( l );
         }
      }

   return bwb_zline( l );
   }

/***************************************************************

        FUNCTION:       bwb_dounnum()

	DESCRIPTION:    This function implements the BASIC DO
			UNNUM command, removing all line numbers
			from the program in memory.

	SYNTAX:		DO UNNUM

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_dounnum( struct bwb_line *l )
#else
struct bwb_line *
bwb_dounnum( l )
   struct bwb_line *l;
#endif
   {
   struct bwb_line *current;

   for ( current = bwb_start.next; current != &bwb_end; current = current->next )
      {
      current->number = 0;
      current->xnum = FALSE;
      }

   return bwb_zline( l );
   }

#endif				/* INTERACTIVE */

#if COMMON_CMDS

/***************************************************************

        FUNCTION:       bwb_chain()

        DESCRIPTION:	This C function implements the BASIC
			CHAIN command.

   	SYNTAX:		CHAIN file-name

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_chain( struct bwb_line *l )
#else
struct bwb_line *
bwb_chain( l )
   struct bwb_line *l;
#endif
   {

   /* deallocate all variables except common ones */

   var_delcvars();

   /* remove old program from memory */

   bwb_xnew( l );

   /* call xload function to load new program in memory */

   bwb_xload( l );

   /* reset all stack counters */

   CURTASK exsc = -1;
   CURTASK expsc = 0;
   CURTASK xtxtsc = 0;

   /* run the program */

   return bwb_run( &CURTASK bwb_start  );

   }

/***************************************************************

        FUNCTION:       bwb_merge()

        DESCRIPTION:	This C function implements the BASIC
			MERGE command, merging command lines from
			a specified file into the program in memory
			without deleting the lines already in memory.

   	SYNTAX:		MERGE file-name

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_merge( struct bwb_line *l )
#else
struct bwb_line *
bwb_merge( l )
   struct bwb_line *l;
#endif
   {

   /* call xload function to merge program in memory */

   bwb_xload( l );


   return bwb_zline( l );

   }

/***************************************************************

        FUNCTION:       bwb_onerror()

        DESCRIPTION:	This C function implements the BASIC
        		ON ERROR GOSUB command.

   	SYNTAX:		ON ERROR GOSUB line | label

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_onerror( struct bwb_line *l )
#else
struct bwb_line *
bwb_onerror( l )
   struct bwb_line *l;
#endif
   {
   char tbuf[ MAXSTRINGSIZE + 1 ];

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_onerror(): entered function" );
   bwb_debug( bwb_ebuf );
#endif

   /* get the GOSUB STATEMENT */

   adv_element( l->buffer, &( l->position ), tbuf );

   /* check for GOSUB statement */

   bwb_strtoupper( tbuf );
   if ( strcmp( tbuf, CMD_GOSUB ) != 0 )
      {
#if PROG_ERRORS
      sprintf( bwb_ebuf, "in bwb_onerror(): GOSUB statement missing" );
      bwb_error( bwb_ebuf );
#else
      bwb_error( err_syntax );
#endif

      return bwb_zline( l );
      }

   /* get the GOSUB line */

   adv_element( l->buffer, &( l->position ), err_gosubl );

   return bwb_zline( l );

   }

/***************************************************************

        FUNCTION:       bwb_tron()

	DESCRIPTION:    This function implements the BASIC TRON
			command, turning the trace mechanism on.

	SYNTAX:		TRON

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_tron( struct bwb_line *l )
#else
struct bwb_line *
bwb_tron( l )
   struct bwb_line *l;
#endif
   {
   bwb_trace = TRUE;
   prn_xprintf( stdout, "Trace is ON\n" );

   return bwb_zline( l );
   }

/***************************************************************

        FUNCTION:       bwb_troff()

	DESCRIPTION:    This function implements the BASIC TROFF
			command, turning the trace mechanism off.

	SYNTAX:		TROFF

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_troff( struct bwb_line *l )
#else
struct bwb_line *
bwb_troff( l )
   struct bwb_line *l;
#endif
   {
   bwb_trace = FALSE;
   prn_xprintf( stdout, "Trace is OFF\n" );

   return bwb_zline( l );
   }

#endif				/* COMMON_CMDS */

/***************************************************************

        FUNCTION:       bwb_randomize()

	DESCRIPTION:    This function implements the BASIC
			RANDOMIZE command, seeding the pseudo-
			random number generator.

	SYNTAX:		RANDOMIZE number

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_randomize( struct bwb_line *l )
#else
struct bwb_line *
bwb_randomize( l )
   struct bwb_line *l;
#endif
   {
   register unsigned n;
   struct exp_ese *e;

   /* Check for argument */

   adv_ws( l->buffer, &( l->position ) );
   switch( l->buffer[ l->position ] )
      {
      case '\0':
      case '\n':
      case '\r':
#if MULTISEG_LINES
      case ':':
#endif
         n = (unsigned) 1;
         break;
      default:
         n = (unsigned) 0;
         break;
      }

   /* get the argument in tbuf */

   if ( n == (unsigned) 0 )
      {
      e = bwb_exp( l->buffer, FALSE, &( l->position ) );
      n = (unsigned) exp_getnval( e );
      }

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_randomize(): argument is <%d>", n );
   bwb_debug( bwb_ebuf );
#endif

   srand( n );

   return bwb_zline( l );
   }


/***************************************************************

        FUNCTION:       bwb_xnew()

        DESCRIPTION:	Clears the program in memory, but does not
			deallocate all variables.

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_xnew( struct bwb_line *l )
#else
struct bwb_line *
bwb_xnew( l )
   struct bwb_line *l;
#endif
   {
   struct bwb_line *current, *previous;
   int wait;

   wait = TRUE;
   for ( current = CURTASK bwb_start.next; current != &CURTASK bwb_end; current = current->next )
      {
      if ( wait != TRUE )
         {
         /* Revised to FREE pass-thru call by JBV */
         FREE( previous, "bwb_xnew" );
         previous = NULL; /* JBV */
         }
      wait = FALSE;
      previous = current;
      }

   CURTASK bwb_start.next = &CURTASK bwb_end;

   return bwb_zline( l );
   }

#if UNIX_CMDS

/***************************************************************

        FUNCTION:       bwb_environ()

        DESCRIPTION:	This C function implements the BASIC
			ENVIRON command, assigning a string
			value to an environment variable.

	SYNTAX:		ENVIRON variable-string$ = string$

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_environ( struct bwb_line *l )
#else
struct bwb_line *
bwb_environ( l )
   struct bwb_line *l;
#endif
   {
   static char tbuf[ MAXSTRINGSIZE + 1 ];
   char tmp[ MAXSTRINGSIZE + 1 ];
   register int i;
   int pos;
   struct exp_ese *e;

   /* find the equals sign */

   for ( i = 0; ( l->buffer[ l->position ] != '=' ) && ( l->buffer[ l->position ] != '\0' ); ++i )
      {
      tbuf[ i ] = l->buffer[ l->position ];
      tbuf[ i + 1 ] = '\0';
      ++( l->position );
      }

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_environ(): variable string is <%s>", tbuf );
   bwb_debug( bwb_ebuf );
#endif

   /* get the value string to be assigned */

   pos = 0;
   e = bwb_exp( tbuf, FALSE, &pos );
   str_btoc( tbuf, exp_getsval( e ) );

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_environ(): variable string resolves to <%s>", tbuf );
   bwb_debug( bwb_ebuf );
#endif

   /* find the equals sign */

   adv_ws( l->buffer, &( l->position ) );
   if ( l->buffer[ l->position ] != '=' )
      {
#if PROG_ERRORS
      sprintf( bwb_ebuf, "in bwb_environ(): failed to find equal sign" );
      bwb_error( bwb_ebuf );
#else
      bwb_error( err_syntax );
#endif

      return bwb_zline( l );
      }
   ++( l->position );

   /* get the value string to be assigned */

   e = bwb_exp( l->buffer, FALSE, &( l->position ));
   str_btoc( tmp, exp_getsval( e ) );

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_environ(): value string resolves to <%s>", tmp );
   bwb_debug( bwb_ebuf );
#endif

   /* construct string */

   strcat( tbuf, "=" );
   strcat( tbuf, tmp );

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_environ(): assignment string is <%s>", tbuf );
   bwb_debug( bwb_ebuf );
#endif

   /* now assign value to variable */
#ifndef ATARI
   if ( putenv( tbuf ) == -1 )
      {
      bwb_error( err_opsys );

      return bwb_zline( l );
      }

   /* return */
#endif

   return bwb_zline( l );

   }

#endif					/* UNIX_CMDS */

/***************************************************************

        FUNCTION:       bwb_cmds()

	DESCRIPTION:    This function implements a CMD command,
			which lists all commands implemented.
			It is not part of a BASIC specification,
			but is used for debugging bwBASIC.

	SYNTAX:		CMDS

***************************************************************/

#if PERMANENT_DEBUG

#if ANSI_C
struct bwb_line *
bwb_cmds( struct bwb_line *l )
#else
struct bwb_line *
bwb_cmds( l )
   struct bwb_line *l;
#endif
   {
   register int n;
   char tbuf[ MAXSTRINGSIZE + 1 ];

   prn_xprintf( stdout, "BWBASIC COMMANDS AVAILABLE: \n" );

   /* run through the command table and print comand names */

   for ( n = 0; n < COMMANDS; ++n )
      {
      sprintf( tbuf, "%s \n", bwb_cmdtable[ n ].name );
      prn_xprintf( stdout, tbuf );
      }

   return bwb_zline( l );
   }
#endif

/***************************************************************

	FUNCTION:       getcmdnum()

	DESCRIPTION:    This function returns the number associated
			with a specified command (cmdstr) in the
			command table.

***************************************************************/

#if ANSI_C
int
getcmdnum( char *cmdstr )
#else
int
getcmdnum( cmdstr )
   char *cmdstr;
#endif
   {
   register int c;

   for ( c = 0; c < COMMANDS; ++c )
      {
      if ( strcmp( bwb_cmdtable[ c ].name, cmdstr ) == 0 )
         {
         return c;
         }
      }

   return -1;

   }

/***************************************************************

        FUNCTION:       bwb_zline()

        DESCRIPTION:	This function is called at the exit from
        		Bywater BASIC command functions.  If
        		MULTISEG_LINES is TRUE, then it returns
        		a pointer to the current line; otherwise it
        		sets the position in the next line to zero
        		and returns a pointer to the next line.

***************************************************************/

#if ANSI_C
extern struct bwb_line *
bwb_zline( struct bwb_line *l )
#else
struct bwb_line *
bwb_zline( l )
   struct bwb_line *l;
#endif
   {
#if MULTISEG_LINES
   /* l->marked = FALSE; */
   return l;
#else
   l->next->position = 0;
   return l->next;
#endif
   }


