/***************************************************************

        bwx_iqc.c       Environment-dependent implementation
                        of Bywater BASIC Interpreter
			for IBM PC and Compatibles
			using the Microsoft QuickC (tm) Compiler

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
#include <stdlib.h>
#include <setjmp.h>
#include <bios.h>
#include <graph.h>
#include <signal.h>

#include "bwbasic.h"
#include "bwb_mes.h"

extern int prn_col;
extern jmp_buf mark;
short oldfgd;
long oldbgd;
int reset_mode = FALSE;

static int iqc_setpos( void );

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

void
main( int argc, char **argv )
   {
#if MS_CMDS
   struct videoconfig vc;
   short videomode;

   /* Save original foreground, background, and text position. */

   _getvideoconfig( &vc );
   oldfgd = _gettextcolor();
   oldbgd = _getbkcolor();

   if ( vc.mode != _TEXTC80 )
      {
      if ( _setvideomode( _TEXTC80 ) == 0 )
         {
	 _getvideoconfig( &vc );
	 prn_xprintf( stderr, "Failed to set color video mode\n" );
         }
      else
	 {
	 reset_mode = FALSE;
	 }
      }
   else
      {
      reset_mode = FALSE;
      }

#endif       /* MS_CMDS */

   bwb_init( argc, argv );

#if INTERACTIVE
   setjmp( mark );
#endif

   /* now set the number of colors available */

   * var_findnval( co, co->array_pos ) = (bnumber) vc.numcolors;

   /* main program loop */

   while( !feof( stdin ) )		/* condition !feof( stdin ) added in v1.11 */
      {
      bwb_mainloop();
      }

   }

/***************************************************************

        FUNCTION:       bwx_signon()

        DESCRIPTION:

***************************************************************/

int
bwx_signon( void )
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

        DESCRIPTION:

***************************************************************/

int
bwx_message( char *m )
   {

#if DEBUG
   _outtext( "<MES>" );
#endif

   _outtext( m );

   return TRUE;

   }

/***************************************************************

	FUNCTION:       bwx_putc()

	DESCRIPTION:

***************************************************************/

extern int
bwx_putc( char c )
   {
   static char tbuf[ 2 ];

   tbuf[ 0 ] = c;
   tbuf[ 1 ] = '\0';
   _outtext( tbuf );

   return TRUE;

   }

/***************************************************************

        FUNCTION:       bwx_error()

        DESCRIPTION:

***************************************************************/

int
bwx_errmes( char *m )
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
   prn_xprintf( stderr, "<ERR>" );
#endif

   prn_xprintf( errfdevice, tbuf );

   return TRUE;

   }

/***************************************************************

        FUNCTION:       bwx_input()

	DESCRIPTION:    As implemented here, the input facility
			is a hybrid of _outtext output (which allows
			the color to be set) and standard output
			(which does not).  The reason is that I've
			found it helpful to use the DOS facility
			for text entry, with its backspace-delete
			and recognition of the SIGINT, depite the
			fact that its output goes to stdout.

***************************************************************/

int
bwx_input( char *prompt, char *buffer )
   {

#if INTENSIVE_DEBUG
   prn_xprintf( stdout, "<INP>" );
#endif

   prn_xprintf( stdout, prompt );

   fgets( buffer, MAXREADLINESIZE, stdin );
   prn_xprintf( stdout, "\n" );               /* let _outtext catch up */

   * prn_getcol( stdout ) = 1;			/* reset column */

   return TRUE;

   }

/***************************************************************

        FUNCTION:       bwx_terminate()

        DESCRIPTION:

***************************************************************/

void
bwx_terminate( void )
   {
#if MS_CMDS

   if ( reset_mode == TRUE )
      {

      _setvideomode( _DEFAULTMODE );

      /* Restore original foreground and background. */

      _settextcolor( oldfgd );
      _setbkcolor( oldbgd );

      }

#endif

   exit( 0 );
   }

/***************************************************************

	FUNCTION:       bwx_shell()

	DESCRIPTION:

***************************************************************/

#if COMMAND_SHELL
extern int
bwx_shell( struct bwb_line *l )
   {
   static char *s_buffer;
   static int init = FALSE;
   static int position;

   /* get memory for temporary buffer if necessary */

   if ( init == FALSE )
      {
      init = TRUE;

      /* Revised to CALLOC pass-thru call by JBV */
      if ( ( s_buffer = CALLOC( MAXSTRINGSIZE + 1, sizeof( char ) )) == NULL )
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
	 iqc_setpos();
	 return TRUE;
	 }
      else
	 {
	 iqc_setpos();
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
	 iqc_setpos();
	 return TRUE;
	 }
      else
	 {
	 iqc_setpos();
	 return FALSE;
	 }
      }
   }
#endif

/***************************************************************

	FUNCTION:      iqc_setpos()

	DESCRIPTION:

***************************************************************/

static int
iqc_setpos( void )
   {
   union REGS ibm_registers;

   /* call the BDOS function 0x10 to read the current cursor position */

   ibm_registers.h.ah = 3;
   ibm_registers.h.bh = (unsigned char) _getvisualpage();
   int86( 0x10, &ibm_registers, &ibm_registers );

   /* set text to this position */

   _settextposition( ibm_registers.h.dh, ibm_registers.h.dl );

   /* and move down one position */

   prn_xprintf( stdout, "\n" );

   return TRUE;
   }


#if COMMON_CMDS

/***************************************************************

        FUNCTION:       bwb_edit()

        DESCRIPTION:

***************************************************************/

struct bwb_line *
bwb_edit( struct bwb_line *l )
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

      iqc_setpos();
      return bwb_zline( l );
      }

   /* clear current contents */

   bwb_new( l ); /* Relocated by JBV (bug found by DD) */

   /* and (re)load the file into memory */

   bwb_fload( loadfile );


   iqc_setpos();
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

      iqc_setpos();
      return bwb_zline( l );
      }

   /* clear current contents */

   bwb_new( l ); /* Relocated by JBV (bug found by DD) */

   /* and (re)load the file into memory */

   bwb_fload( loadfile );


   iqc_setpos();
   return bwb_zline( l );
   }

/***************************************************************

        FUNCTION:       bwb_files()

        DESCRIPTION:

***************************************************************/

struct bwb_line *
bwb_files( struct bwb_line *l )
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

   iqc_setpos();
   return bwb_zline( l );

   }

#endif					/* COMMON_CMDS */

#if INTERACTIVE

/***************************************************************

        FUNCTION:       fnc_inkey()

        DESCRIPTION:    This C function implements the BASIC INKEY$
        		function.  It is implementation-specific.

***************************************************************/

extern struct bwb_variable *
fnc_inkey( int argc, struct bwb_variable *argv )
   {
   static struct bwb_variable nvar;
   char tbuf[ MAXSTRINGSIZE + 1 ];
   static int init = FALSE;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, STRING, "fnc_inkey" );
      }

   /* check arguments */

#if PROG_ERRORS
   if ( argc > 0 )
      {
      sprintf( bwb_ebuf, "Two many arguments to function INKEY$()" );
      bwb_error( bwb_ebuf );
      return &nvar;
      }

#else
   if ( fnc_checkargs( argc, argv, 0, 0 ) == FALSE )
      {
      return NULL;
      }
#endif

   /* body of the INKEY$ function */

   if ( _bios_keybrd( _KEYBRD_READY ) == 0 )
      {
      tbuf[ 0 ] = '\0';
      }
   else
      {
      tbuf[ 0 ] = (char) _bios_keybrd( _KEYBRD_READ );
      tbuf[ 1 ] = '\0';
      }

   /* assign value to nvar variable */

   str_ctob( var_findsval( &nvar, nvar.array_pos ), tbuf );

   /* return value contained in nvar */

   return &nvar;

   }

#endif				/* INTERACTIVE */

#if MS_CMDS

/***************************************************************

        FUNCTION:       bwb_cls()

        DESCRIPTION:    This C function implements the BASIC CLS
        		command.  It is implementation-specific.

***************************************************************/

extern struct bwb_line *
bwb_cls( struct bwb_line *l )
   {

   _clearscreen( _GCLEARSCREEN );

   return bwb_zline( l );
   }

/***************************************************************

        FUNCTION:       bwb_locate()

        DESCRIPTION:    This C function implements the BASIC LOCATE
        		command.  It is implementation-specific.

***************************************************************/

extern struct bwb_line *
bwb_locate( struct bwb_line *l )
   {
   struct exp_ese *e;
   int row, column;

   /* get first argument */

   e = bwb_exp( l->buffer, FALSE, &( l->position ));
   row = (int) exp_getnval( e );

   /* advance past comma */

   adv_ws( l->buffer, &( l->position ));
   if ( l->buffer[ l->position ] != ',' )
      {
      bwb_error( err_syntax );
      return bwb_zline( l );
      }
   ++( l->position );

   /* get second argument */

   e = bwb_exp( l->buffer, FALSE, &( l->position ));
   column = (int) exp_getnval( e );

   /* position the cursor */

   _settextposition( row, column );

   return bwb_zline( l );
   }

/***************************************************************

	FUNCTION:       bwb_color()

	DESCRIPTION:    This C function implements the BASIC COLOR
			command.  It is implementation-specific.

***************************************************************/

extern struct bwb_line *
bwb_color( struct bwb_line *l )
   {
   struct exp_ese *e;
   int color;

   /* get first argument */

   e = bwb_exp( l->buffer, FALSE, &( l->position ));
   color = (int) exp_getnval( e );

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "Setting text color to %d", color );
   bwb_debug( bwb_ebuf );
#endif

   _settextcolor( (short) color );

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "Set text color to %d", color );
   bwb_debug( bwb_ebuf );
#endif

   /* advance past comma */

   adv_ws( l->buffer, &( l->position ));
   if ( l->buffer[ l->position ] == ',' )
      {

      ++( l->position );

      /* get second argument */

      e = bwb_exp( l->buffer, FALSE, &( l->position ));
      color = (int) exp_getnval( e );

#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "Setting background color to %d", color );
      bwb_debug( bwb_ebuf );
#endif

      /* set the background color */

      _setbkcolor( (long) color );

#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "Setting background color to %d\n", color );
      bwb_debug( bwb_ebuf );
#endif

      }

   return bwb_zline( l );
   }

#endif				/* MS_CMDS */

