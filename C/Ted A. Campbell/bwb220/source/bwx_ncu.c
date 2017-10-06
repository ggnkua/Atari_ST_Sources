/***************************************************************

        bwx_ncu.c       Environment-dependent implementation
                        of Bywater BASIC Interpreter
                        for Linux (and others?) using Ncurses
                        library, 
                        
                        This BWBASIC file hacked together by L.C. Benschop,
                        Eindhoven, The Netherlands. 1997/01/14 and
                        1997/01/15  derived from the iqc version.
                        (benschop@eb.ele.tue.nl)

			All the shell commands (like FILES) interact badly 
			with curses. I should replace them with popen/addch
                        
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
#include <curses.h> /* Should be the ncurses version */
#include <setjmp.h>
#include <signal.h>
#undef TRUE
#undef FALSE

/* So curses TRUE and FALSE conflict with the ones defined by bwbasic.
   Doesn't this suck big time?
   */

#include "bwbasic.h"
#include "bwb_mes.h"

extern int prn_col;
extern jmp_buf mark;
short oldfgd;
long oldbgd;
int reset_mode = FALSE;

static int ncu_setpos( void );

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


static int col_arr[]={COLOR_BLACK,COLOR_RED,COLOR_GREEN,COLOR_YELLOW,
               COLOR_BLUE,COLOR_MAGENTA,COLOR_CYAN,COLOR_WHITE};
	       

int /* Nobody shall declare main() as void!!!!! (L.C. Benschop)*/
main( int argc, char **argv )
   {
   int i,j;
   initscr();
   start_color();
   if(has_colors()) {
     /* so there are 63 color pairs, from 1 to 63. Just 1 too few for
        all the foreground/background combinations. */
    for(i=0;i<8;i++)
      for(j=0;j<8;j++)
       if(i||j) init_pair(i*8+j,col_arr[i],col_arr[j]);
   }
   cbreak();
   nonl();
   noecho();
   scrollok(stdscr,1);
   bwb_init( argc, argv );

#if INTERACTIVE
   setjmp( mark );
#endif

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
   addstr( "<MES>" );
#endif

   addstr( m );
   refresh();
   return TRUE;

   }

/***************************************************************

	FUNCTION:       bwx_putc()

	DESCRIPTION:

***************************************************************/

extern int
bwx_putc( char c )
   {
   addch(c);
   refresh();
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

	DESCRIPTION:    (w)get(n)str seems to interact badly with last line
                        on screen condition and scrolling.


***************************************************************/

int
bwx_input( char *prompt, char *buffer )
   {
    int y,x,my,mx; 
#if INTENSIVE_DEBUG
   prn_xprintf( stdout, "<INP>" );
#endif
   prn_xprintf( stdout, prompt );
   getyx(stdscr,y,x);
   echo();
   wgetnstr(stdscr, buffer, MAXREADLINESIZE);
   noecho();
   getmaxyx(stdscr,my,mx);
   /*  printf("%d %d",my,mx);*/
   if(y+1==my)scroll(stdscr);
   /* So this is an extreeeeemely ugly kludge to work around some
      bug/feature/wart in ncurses FIXME
      I should replace it with getch/addch in a loop  */   

   /* prn_xprintf( stdout, "\n" );*/        /* let _outtext catch up */

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
    nodelay(stdscr,FALSE);
    echo();
    nl();
    nocbreak();
    endwin();
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
      if ( ( s_buffer = CALLOC( MAXSTRINGSIZE + 1, sizeof( char ),"bwx_shell" )) == NULL )
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
      nl();
      endwin(); /* Added by JBV 10/11/97 */
      if ( system( l->buffer ) == 0 )
	 {
         refresh(); /* Added by JBV 10/11/97 */
         nonl();
	 ncu_setpos();
	 return TRUE;
	 }
      else
	 {
         refresh(); /* Added by JBV 10/11/97 */
         nonl();
	 ncu_setpos();
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
      nl();
      endwin(); /* Added by JBV 10/11/97 */
      if ( system( &( l->buffer[ position ] ) ) == 0 )
	 {
         refresh(); /* Added by JBV 10/11/97 */
         nonl();
	 ncu_setpos();
	 return TRUE;
	 }
      else
	 {
         refresh(); /* Added by JBV 10/11/97 */
         nonl();
	 ncu_setpos();
	 return FALSE;
	 }
      }
   }
#endif

/***************************************************************

	FUNCTION:      ncu_setpos()

	DESCRIPTION:

***************************************************************/

static int
ncu_setpos( void )
   {
    int x,y;
    getyx(stdscr,y,x);
    move(y,x);
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
   nl();
   endwin(); /* Added by JBV 10/11/97 */
   system( tbuf );

   /*-----------------------*/
   /* Added by JBV 10/11/97 */
   /*-----------------------*/
   fprintf( stderr, "Press RETURN when ready..." );
   fgets( tbuf, MAXREADLINESIZE, stdin );
   refresh();

   nonl();
#endif

   /* open edited file for read */

   if ( ( loadfile = fopen( CURTASK progfile, "r" )) == NULL )
      {
      sprintf( bwb_ebuf, err_openfile, CURTASK progfile );
      bwb_error( bwb_ebuf );

      ncu_setpos();
      return bwb_zline( l );
      }

   /* clear current contents */

   bwb_new( l ); /* Relocated by JBV (bug found by DD) */

   /* and (re)load the file into memory */

   bwb_fload( loadfile );


   ncu_setpos();
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
   nl();
   endwin(); /* Added by JBV 10/11/97 */
   system( tbuf );

   /*-----------------------*/
   /* Added by JBV 10/11/97 */
   /*-----------------------*/
   fprintf( stderr, "Press RETURN when ready..." );
   fgets( tbuf, MAXREADLINESIZE, stdin );
   refresh();

   nonl();
#endif

   /* open edited file for read */

   if ( ( loadfile = fopen( CURTASK progfile, "r" )) == NULL )
      {
      sprintf( bwb_ebuf, err_openfile, CURTASK progfile );
      bwb_error( bwb_ebuf );

      ncu_setpos();
      return bwb_zline( l );
      }

   /* clear current contents */

   bwb_new( l ); /* Relocated by JBV (bug found by DD) */

   /* and (re)load the file into memory */

   bwb_fload( loadfile );


   ncu_setpos();
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
   nl();
   endwin(); /* Added by JBV 10/11/97 */
   system( tbuf );

   /*-----------------------*/
   /* Added by JBV 10/11/97 */
   /*-----------------------*/
   fprintf( stderr, "Press RETURN when ready..." );
   fgets( tbuf, MAXREADLINESIZE, stdin );
   refresh();

   nonl();
#endif

   ncu_setpos();
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
fnc_inkey( int argc, struct bwb_variable *argv,int unique)
   {
   static struct bwb_variable nvar;
   char tbuf[ MAXSTRINGSIZE + 1 ];
   static int init = FALSE;
   int c;

   /* initialize the variable if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, STRING);
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
   
   nodelay(stdscr,1);
   if ( (c=getch())==EOF )
      {
      tbuf[ 0 ] = '\0';
      }
   else
      {
      tbuf[ 0 ] = (char) c;
      tbuf[ 1 ] = '\0';
      }
   nodelay(stdscr,0);
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

   clear();
   refresh();

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

   move( row-1, column-1 );

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
   int fgcolor,bgcolor;

   /* get first argument */

   e = bwb_exp( l->buffer, FALSE, &( l->position ));
   fgcolor = (int) exp_getnval( e );

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "Setting text color to %d", fgcolor );
   bwb_debug( bwb_ebuf );
#endif


#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "Set text color to %d", fgcolor );
   bwb_debug( bwb_ebuf );
#endif

   /* advance past comma */

   adv_ws( l->buffer, &( l->position ));
   if ( l->buffer[ l->position ] == ',' )
      {

      ++( l->position );

      /* get second argument */

      e = bwb_exp( l->buffer, FALSE, &( l->position ));
      bgcolor = (int) exp_getnval( e );

#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "Setting background color to %d", bgcolor );
      bwb_debug( bwb_ebuf );
#endif

      /* set the foreground and background color */
      if (has_colors()) {
	attrset(A_NORMAL);
        bkgdset(COLOR_PAIR((bgcolor&7))|' ');
        if((fgcolor&7)==0 && (bgcolor&7)==0){
	 /* we didn't reserve a color pair for fg and bg both black. 
            Bright black(color 8)==dark gray as foreground color A_DIM
            A_INVIS doesn't seem to work. wait for next version of
            ncurses, don't bother for now.*/
         if(fgcolor<8) attrset(A_INVIS); else attrset(A_DIM);
        } else
        attrset(COLOR_PAIR((8*(fgcolor&7)+(bgcolor&7))) | 
                      ((fgcolor>7)*A_BOLD));
        /* fg colors 8--15 == extra brightness */
      } else { /* no colors, have a go at it with reverse/bold/dim */
        attrset(A_NORMAL);
        bkgdset(A_REVERSE*((fgcolor&7)<(bgcolor&7))|' ');
        attrset(A_BOLD*(fgcolor>8)|
          A_REVERSE*((fgcolor&7)<(bgcolor&7))|A_INVIS*(fgcolor==bgcolor));
      }
      

#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "Setting background color to %d\n", bgcolor );
      bwb_debug( bwb_ebuf );
#endif

      }

   return bwb_zline( l );
   }
#endif /* MS_CMDS */






