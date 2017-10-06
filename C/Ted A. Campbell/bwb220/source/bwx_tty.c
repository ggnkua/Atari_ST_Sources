/***************************************************************

        bwx_tty.c       Environment-dependent implementation
                        for Bywater BASIC Interpreter
			using simple TTY-style input/output

			This file should be used as a template
			for developing more sophisticated
			environment-dependent implementations

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

#include "bwbasic.h"
#include "bwb_mes.h"

#if HAVE_LONGJUMP /* Revised by JBV (bug found by DD) */
#include <setjmp.h>
#endif

extern int prn_col;
#if HAVE_LONGJUMP /* Revised by JBV (bug found by DD) */
extern jmp_buf mark;
#endif

/***************************************************************

        FUNCTION:       main()

        DESCRIPTION:    As in any C program, main() is the basic
                        function from which the rest of the
                        program is called. Some environments,
			however, provide their own main() functions
			(Microsoft Windows (tm) is an example).
			In these cases, the following code will
			have to be included in the initialization
			function that is called by the environment.

***************************************************************/

#if ANSI_C
void
main( int argc, char **argv )
#else
main( argc, argv )
   int argc;
   char **argv;
#endif
   {

   bwb_init( argc, argv );

#if HAVE_LONGJUMP /* Revised by JBV (bug found by DD) */
#if INTERACTIVE
   setjmp( mark );
#endif
#endif

   /* main program loop */

   while( !feof( stdin ) )		/* condition !feof( stdin ) added in v1.11 */
      {
      bwb_mainloop();
      }

      bwx_terminate();			/* allow ^D (Unix) exit with grace */


   }

/***************************************************************

        FUNCTION:       bwx_signon()

	DESCRIPTION:    This function prints out the sign-on
			message for bwBASIC.

***************************************************************/

#if ANSI_C
int
bwx_signon( void )
#else
int
bwx_signon()
#endif
   {

   sprintf( bwb_ebuf, "\r%s %s\n", MES_SIGNON, VERSION );
   prn_xprintf( stdout, bwb_ebuf );
   sprintf( bwb_ebuf, "\r%s\n", MES_COPYRIGHT );
   prn_xprintf( stdout, bwb_ebuf );
   sprintf( bwb_ebuf, "\r%s\n", MES_COPYRIGHT_2 ); /* JBV 1/97 */
   prn_xprintf( stdout, bwb_ebuf );
#if PERMANENT_DEBUG
   sprintf( bwb_ebuf, "\r%s\n", "Debugging Mode" );
   prn_xprintf( stdout, bwb_ebuf );
#else
   sprintf( bwb_ebuf, "\r%s\n", MES_LANGUAGE );
   prn_xprintf( stdout, bwb_ebuf );
#endif

   return TRUE;

   }

/***************************************************************

        FUNCTION:       bwx_message()

	DESCRIPTION:    This function outputs a message to the
			default output device.

***************************************************************/

#if ANSI_C
int
bwx_message( char *m )
#else
int
bwx_message( m )
   char *m;
#endif
   {

#if INTENSIVE_DEBUG
   fprintf( stderr, "<MES>" );
#endif

   prn_xprintf( stdout, m );

   return TRUE;

   }

/***************************************************************

        FUNCTION:       bwx_putc()

	DESCRIPTION:    This function outputs a single character
			to the default output device.

***************************************************************/

#if ANSI_C
int
bwx_putc( char c )
#else
int
bwx_putc( c )
   char c;
#endif
   {

   return fputc( c, stdout );

   }

/***************************************************************

        FUNCTION:       bwx_error()

	DESCRIPTION:    This function outputs a message to the
			default error-message device.

***************************************************************/

#if ANSI_C
int
bwx_errmes( char *m )
#else
int
bwx_errmes( m )
   char *m;
#endif
   {
   static char tbuf[ MAXSTRINGSIZE + 1 ];	/* this memory should be
						   permanent in case of memory
						   overrun errors */

   if (( prn_col != 1 ) && ( errfdevice == stderr ))
      {
      prn_xprintf( errfdevice, "\n" );
      }
   if ( CURTASK number == 0 )
      {
      sprintf( tbuf, "\n%s: %s\n", ERRD_HEADER, m );
      }
   else
      {
      sprintf( tbuf, "\n%s %d: %s\n", ERROR_HEADER, CURTASK number, m );
      }

#if INTENSIVE_DEBUG
   fprintf( stderr, "<ERR>" );
#endif

   prn_xprintf( errfdevice, tbuf );

   return TRUE;

   }

/***************************************************************

        FUNCTION:       bwx_input()

	DESCRIPTION:    This function outputs the string pointed
			to by 'prompt', then inputs a character
			string.

***************************************************************/

#if ANSI_C
int
bwx_input( char *prompt, char *buffer )
#else
int
bwx_input( prompt, buffer )
   char *prompt;
   char *buffer;
#endif
   {

#if INTENSIVE_DEBUG
   fprintf( stderr, "<INP>" );
#endif

   prn_xprintf( stdout, prompt );

   fgets( buffer, MAXREADLINESIZE, stdin );
   * prn_getcol( stdout ) = 1;			/* reset column */

   return TRUE;

   }

/***************************************************************

        FUNCTION:       bwx_terminate()

	DESCRIPTION:    This function terminates program execution.

***************************************************************/

#if ANSI_C
void
bwx_terminate( void )
#else
void
bwx_terminate()
#endif
   {
   exit( 0 );
   }

/***************************************************************

	FUNCTION:       bwx_shell()

	DESCRIPTION:    This function runs a shell program.

***************************************************************/

#if COMMAND_SHELL

#if ANSI_C
extern int
bwx_shell( struct bwb_line *l )
#else
extern int
bwx_shell( l )
   struct bwb_line *l;
#endif
   {
   static char *s_buffer;
   static int init = FALSE;
   static int position;

   /* get memory for temporary buffer if necessary */

   if ( init == FALSE )
      {
      init = TRUE;

      /* Revised to CALLOC pass-thru call by JBV */
      if ( ( s_buffer = CALLOC( MAXSTRINGSIZE + 1, sizeof( char ), "bwx_shell" )) == NULL )
	 {
	 bwb_error( err_getmem );
	 return FALSE;
	 }
      }

   /* get the first element and check for a line number */

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwx_shell(): line buffer is <%s>.", l->buffer );
   bwb_debug( bwb_ebuf );
#endif

   position = 0;
   adv_element( l->buffer, &position, s_buffer );
   if ( is_numconst( s_buffer ) != TRUE )                  /* not a line number */
      {

#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwx_shell(): no line number, command <%s>.",
	 l->buffer );
      bwb_debug( bwb_ebuf );
#endif

      if ( system( l->buffer ) == 0 )
	 {
	 return TRUE;
	 }
      else
	 {
	 return FALSE;
	 }
      }

   else                                         /* advance past line number */
      {
      adv_ws( l->buffer, &position );           /* advance past whitespace */

#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwx_shell(): line number, command <%s>.",
	 l->buffer );
      bwb_debug( bwb_ebuf );
#endif

      if ( system( &( l->buffer[ position ] ) ) == 0 )
	 {
	 return TRUE;
	 }
      else
	 {
	 return FALSE;
	 }
      }
   }
#endif

/***************************************************************

        FUNCTION:       matherr()

        DESCRIPTION:    This function is called to handle math
                        errors in Bywater BASIC.  It displays
                        the error message, then calls the
                        break_handler() routine.

***************************************************************/

#if ANSI_C
int
matherr( struct exception *except )
#else
int
matherr( except )
   struct exception *except;
#endif
   {

   perror( MATHERR_HEADER );
   break_handler();

   return FALSE;
   }

#if COMMON_CMDS

/***************************************************************

        FUNCTION:       bwb_edit()

	DESCRIPTION:    This function implements the BASIC EDIT
			program by shelling out to a default editor
			specified by the variable BWB.EDITOR$.

	SYNTAX:		EDIT

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_edit( struct bwb_line *l )
#else
struct bwb_line *
bwb_edit( l )
   struct bwb_line *l;
#endif
   {
   char tbuf[ MAXSTRINGSIZE + 1 ];
   char edname[ MAXSTRINGSIZE + 1 ];
   struct bwb_variable *ed;
   FILE *loadfile;

   ed = var_find( DEFVNAME_EDITOR );
   str_btoc( edname, var_getsval( ed ));

   sprintf( tbuf, "%s %s", edname, CURTASK progfile );

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_edit(): command line <%s>", tbuf );
   bwb_debug( bwb_ebuf );
#else
   system( tbuf );
#endif

   /* open edited file for read */

   if ( ( loadfile = fopen( CURTASK progfile, "r" )) == NULL )
      {
      sprintf( bwb_ebuf, err_openfile, CURTASK progfile );
      bwb_error( bwb_ebuf );

      return bwb_zline( l );
      }

   /* clear current contents */

   bwb_new( l ); /* Relocated by JBV (bug found by DD) */

   /* and (re)load the file into memory */

   bwb_fload( loadfile );


   return bwb_zline( l );
   }

/***************************************************************

        FUNCTION:       bwb_renum()

	DESCRIPTION:    This function implements the BASIC RENUM
			command by shelling out to a default
			renumbering program called "renum".
			Added by JBV 10/95

	SYNTAX:		RENUM

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_renum( struct bwb_line *l )
#else
struct bwb_line *
bwb_renum( l )
   struct bwb_line *l;
#endif
   {
   char tbuf[ MAXSTRINGSIZE + 1 ];
   FILE *loadfile;

   sprintf( tbuf, "renum %s\0", CURTASK progfile );

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_renum(): command line <%s>", tbuf );
   bwb_debug( bwb_ebuf );
#else
   system( tbuf );
#endif

   /* open edited file for read */

   if ( ( loadfile = fopen( CURTASK progfile, "r" )) == NULL )
      {
      sprintf( bwb_ebuf, err_openfile, CURTASK progfile );
      bwb_error( bwb_ebuf );

      return bwb_zline( l );
      }

   /* clear current contents */

   bwb_new( l ); /* Relocated by JBV (bug found by DD) */

   /* and (re)load the file into memory */

   bwb_fload( loadfile );


   return bwb_zline( l );
   }

/***************************************************************

        FUNCTION:       bwb_files()

	DESCRIPTION:    This function implements the BASIC FILES
			command, in this case by shelling out to
			a directory listing program or command
			specified in the variable BWB.FILES$.

	SYNTAX:		FILES filespec$

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_files( struct bwb_line *l )
#else
struct bwb_line *
bwb_files( l )
   struct bwb_line *l;
#endif
   {
   char tbuf[ MAXVARNAMESIZE + 1 ];
   char finame[ MAXVARNAMESIZE + 1 ];
   char argument[ MAXVARNAMESIZE + 1 ];
   struct bwb_variable *fi;
   struct exp_ese *e;

   fi = var_find( DEFVNAME_FILES );
   str_btoc( finame, var_getsval( fi ));

   /* get argument */

   adv_ws( l->buffer, &( l->position ));
   switch( l->buffer[ l->position ] )
      {
      case '\0':
      case '\r':
      case '\n':
         argument[ 0 ] = '\0';
         break;
      default:
         e = bwb_exp( l->buffer, FALSE, &( l->position ) );
         if ( e->type != STRING )
            {
            bwb_error( err_mismatch );
            return bwb_zline( l );
            }
         str_btoc( argument, exp_getsval( e ) );
         break;
      }


   sprintf( tbuf, "%s %s", finame, argument );

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_files(): command line <%s>", tbuf );
   bwb_debug( bwb_ebuf );
#else
   system( tbuf );
#endif

   return bwb_zline( l );

   }

#endif					/* COMMON_CMDS */

