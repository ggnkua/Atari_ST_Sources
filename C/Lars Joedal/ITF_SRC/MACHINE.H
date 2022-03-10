/*
**	File:	machine.h
**
**	(C)opyright 1987-1992 InfoTaskforce.
*/

/*
**	Compiler Customisation Variables:
**
**		INTERPRETER		: Interpreter Number - indicates the type of the
**						  target machine.
**		MODE_BITS		: The bits to set in the "mode_bits" byte of the
**						  game file header to indicate target system
**						  capabilities.
**		SCREEN_WIDTH	: Number of Characters per Screen Line.
**		SCREEN_HEIGHT	: Number of Screen Lines.
**		READ_STRING		: String used by fopen to open a file in read mode.
**		WRITE_STRING	: String used by fopen to open a file in write mode.
**		APPEND_STRING	: String used by fopen to open a file in append mode.
**		Void			: Defines the "void" type.
**		HUGE			: Used in the type definition of pointers.
**						  This is included for MSDOS and other Intel 80x86
**						  C Compilers with segment based memory models.
**		MALLOC			: Name of the memory allocation routine.
**		FREE			: Name of the memory deallocation routine.
**		main			: Name of the initial C procedure ( LSC Only ).
**		TIME_FUNCTION	: Time function ( returning a long ) used to seed
**						  the random number generator.
**		ONE_SECOND		: The value used by "TIME_FUNCTION" to indicate the
**						  passing of one second of real time.
**		INIT_SIGNAL		: Routine to perform any special initialisation for
**						  signal trapping routines.
**		SIGNAL_QUIT		: Routine to perform any signal cleanup and/or handling.
**						  An integer is passed to this routine to specify
**						  the action required.
**
**		INIT_IO			: Routine to perform any special initialisation for
**						  the I/O routines.
**		EXIT_IO			: Routine to restore any I/O modes when the
**						  program exits.
**		PUT_CHAR		: Routine to send a character to "stdout".
**		GOTO_XY			: Routine to move the cursor to a given screen position.
**		GET_X			: Routine to get the cursor's x-coordinate.
**		GET_Y			: Routine to get the cursor's y-coordinate.
**		USE_WINDOW		: Routine used to set a screen window's scroll region.
**		GET_CH			: Routine to get a character from "stdin" without echo.
**		KBD_HIT			: Routine to detect whether there is a character waiting
**						  to be read from "stdin".
**		ERASE_TO_EOLN	: Routine to Erase the current Screen Line.
**		ERASE_WINDOW	: Routine to Erase several consecutive Screen Lines.
**		SAVE_CURSOR		: Routine to Save the Current Cursor Position.
**		RESTORE_CURSOR	: Routine to Restore the Current Cursor Position.
**		RCFILE			: String containing name of initialization file.
*/

#ifndef	__MACHINE__

#define		__MACHINE__

/*
**	If "ANSI_COLOR" is defined, then "ANSI_ESCAPE" and "WANT_COLOR"
**	should also be defined.
*/

#ifdef	ANSI_COLOR
#define		ANSI_ESCAPE
#define		WANT_COLOR
#endif	/* ANSI_COLOR */

/*
**	If "SYS_V" or "BSD" is defined, then "UNIX" should also be defined.
**	If "MSC" or "TURBOC" is defined, then "MSDOS" should also be defined.
*/

#ifdef	SYS_V
#ifndef	UNIX
#define		UNIX
#endif	/* UNIX */
#endif	/* SYS_V */

#ifdef	BSD
#ifndef	UNIX
#define		UNIX
#endif	/* UNIX */
#endif	/* BSD */

#ifdef	MSC
#ifndef	MSDOS
#define		MSDOS
#endif	/* MSDOS */
#endif	/* MSC */

#ifdef	TURBOC
#ifndef	MSDOS
#define		MSDOS
#endif	/* MSDOS */
#endif	/* TURBOC */

/*
**	If CURSES_COLOR is defined, define CURSES, and, if appropriate, 
**	define WANT_COLOR
*/

#ifdef	CURSES_COLOR
#define	CURSES
#ifdef	SYS_V
/* Color is only available on later releases of UNIX System V curses */
#define	WANT_COLOR
#endif	/* SYS_V */
#endif	/* WANT_COLOR */

/*
**	UNIX Constants
*/

#ifdef	UNIX

#ifdef	SYS_V
#include	<malloc.h>
#include	<termio.h>
#endif	/* SYS_V */

#ifdef	BSD
char		*malloc () ;
#include	<sys/ioctl.h>
#endif	/* BSD */

#include	<time.h>

#define		SCREEN_WIDTH	80
#define		SCREEN_HEIGHT	24
#define		READ_STRING		"r"
#define		WRITE_STRING	"w"
#define		APPEND_STRING	"a"
#ifdef __STDC__
#define		Void			void
#else
#define		Void			int
#endif
#define		MALLOC(s)		malloc(s)
#define		FREE(p)			free((char *)p)
#define		TIME_FUNCTION	time((long *)0)
#define		ONE_SECOND		1
#define		INIT_SIGNAL		unix_signal_init
#define		SIGNAL_QUIT		unix_signal_quit
#define		RCFILE			".infocomrc"

#ifdef	TERMCAP

extern int	tcap_get_x () ;
extern int	tcap_get_y () ;

#define		INTERPRETER		APPLE_2E
#define		MODE_BITS		UNDERLINE
#define		INIT_IO			tcap_init_io
#define		EXIT_IO			tcap_exit_io
#define		PUT_CHAR		tcap_putchar
#define		GOTO_XY			tcap_goto_xy
#define		GET_X			tcap_get_x
#define		GET_Y			tcap_get_y
#define		USE_WINDOW		null_io
#define		GET_CH			getchar
#define		KBD_HIT			default_kbd_hit
#define		ERASE_TO_EOLN	tcap_erase_to_eoln
#define		ERASE_WINDOW	tcap_erase_window
#define		SAVE_CURSOR		tcap_save_cursor
#define		RESTORE_CURSOR	tcap_restore_cursor
#else	/* TERMCAP */
#ifdef	TERMINFO

#include <curses.h>
#include <term.h>

extern int	tinfo_get_x () ;
extern int	tinfo_get_y () ;

#define		INTERPRETER		APPLE_2E
#define		MODE_BITS		UNDERLINE
#define		INIT_IO			tinfo_init_io
#define		EXIT_IO			tinfo_exit_io
#define		PUT_CHAR		tinfo_putchar
#define		GOTO_XY			tinfo_goto_xy
#define		GET_X			tinfo_get_x
#define		GET_Y			tinfo_get_y
#define		USE_WINDOW		null_io
#define		GET_CH			getchar
#define		KBD_HIT			default_kbd_hit
#define		ERASE_TO_EOLN	tinfo_erase_to_eoln
#define		ERASE_WINDOW	tinfo_erase_window
#define		SAVE_CURSOR		tinfo_save_cursor
#define		RESTORE_CURSOR	tinfo_restore_cursor
#else	/* TERMINFO */
#ifdef	CURSES

#include	<curses.h>

/*
**	Some versions of curses apparently do not have cbreak()
*/

extern int	curses_get_ch () ;
extern int	curses_get_x () ;
extern int	curses_get_y () ;

#define		INTERPRETER		APPLE_2E
#define		MODE_BITS		UNDERLINE
#define		INIT_IO			curses_init_io
#define		EXIT_IO			curses_exit_io
#define		PUT_CHAR		curses_putchar
#define		GOTO_XY			curses_goto_xy
#define		GET_X			curses_get_x
#define		GET_Y			curses_get_y
#define		USE_WINDOW		null_io
#define		GET_CH			curses_get_ch
#define		KBD_HIT			default_kbd_hit
#define		ERASE_TO_EOLN	curses_erase_to_eoln
#define		ERASE_WINDOW	curses_erase_window
#define		SAVE_CURSOR		default_save_cursor
#define		RESTORE_CURSOR	default_restore_cursor
#else	/* CURSES */
#ifdef	ANSI_ESCAPE

extern int	ansi_get_x () ;
extern int	ansi_get_y () ;

#define		INTERPRETER		APPLE_2E
#define		MODE_BITS		UNDERLINE
#define		INIT_IO			ansi_init_io
#define		EXIT_IO			ansi_exit_io
#define		PUT_CHAR		ansi_putchar
#define		GOTO_XY			ansi_goto_xy
#define		GET_X			ansi_get_x
#define		GET_Y			ansi_get_y
#define		USE_WINDOW		null_io
#define		GET_CH			getchar
#define		KBD_HIT			default_kbd_hit
#define		ERASE_TO_EOLN	ansi_erase_to_eoln
#define		ERASE_WINDOW	ansi_erase_window
#define		SAVE_CURSOR		ansi_save_cursor
#define		RESTORE_CURSOR	ansi_restore_cursor
#else	/* ANSI_ESCAPE */
#define		INTERPRETER		APPLE_2E
#define		MODE_BITS		0
#define		INIT_IO			unix_init_io
#define		EXIT_IO			unix_exit_io
#define		PUT_CHAR		default_putchar
#define		GOTO_XY			default_goto_xy
#define		GET_X			default_get_x
#define		GET_Y			default_get_y
#define		USE_WINDOW		null_io
#define		GET_CH			getchar
#define		KBD_HIT			default_kbd_hit
#define		ERASE_TO_EOLN	null_io
#define		ERASE_WINDOW	null_io
#define		SAVE_CURSOR		default_save_cursor
#define		RESTORE_CURSOR	default_restore_cursor
#endif	/* ANSI_ESCAPE */
#endif	/* CURSES */
#endif	/* TERMINFO */
#endif	/* TERMCAP */

#endif	/* UNIX */

/*
**	Lightspeed C Version 2.01 Constants (Macintosh)
*/

#ifdef	LSC

#include	<storage.h>
#include	<time.h>

#define		INTERPRETER		APPLE_2E
#define		MODE_BITS		UNDERLINE
#define		SCREEN_WIDTH	80
#define		SCREEN_HEIGHT	24
#define		READ_STRING		"rb"
#define		WRITE_STRING	"wb"
#define		APPEND_STRING	"a"
#define		Void			int
#define		MALLOC(s)		mlalloc(s)
#define		FREE(p)			free((char *)p)
#define		main			_main
#define		TIME_FUNCTION	time((long *)0)
#define		ONE_SECOND		100
#define		INIT_SIGNAL		default_signal_init
#define		SIGNAL_QUIT		default_signal_quit

#define		INIT_IO			lsc_init_io
#define		EXIT_IO			null_io
#define		PUT_CHAR		lsc_putchar
#define		GOTO_XY			gotoxy
#define		GET_X			getxpos
#define		GET_Y			getypos
#define		USE_WINDOW		lsc_use_window
#define		GET_CH			getch
#define		KBD_HIT			kbhit
#define		ERASE_TO_EOLN	lsc_erase_to_eoln
#define		ERASE_WINDOW	lsc_erase_window
#define		SAVE_CURSOR		default_save_cursor
#define		RESTORE_CURSOR	default_restore_cursor

#endif	/* LSC */

/*
**	THINK C Version 4.0 Constants (Macintosh)
*/

#ifdef	THINKC

#include	<console.h>
#include	<stdlib.h>
#include	<time.h>

#define		INTERPRETER		APPLE_2E
#define		MODE_BITS		UNDERLINE
#define		SCREEN_WIDTH	80
#define		SCREEN_HEIGHT	24
#define		READ_STRING		"rb"
#define		WRITE_STRING	"wb"
#define		APPEND_STRING	"a"
#define		Void			int
#define		MALLOC(s)		malloc(s)
#define		FREE(p)			free((void *)p)
#define		main			_main
#define		TIME_FUNCTION	time((time_t *)0)
#define		ONE_SECOND		100
#define		INIT_SIGNAL		default_signal_init
#define		SIGNAL_QUIT		default_signal_quit

#define		INIT_IO			thinkc_init_io
#define		EXIT_IO			thinkc_exit_io
#define		PUT_CHAR		thinkc_putchar
#define		GOTO_XY			thinkc_goto_xy
#define		GET_X			thinkc_get_x
#define		GET_Y			thinkc_get_y
#define		USE_WINDOW		thinkc_use_window
#define		GET_CH			getchar
#define		KBD_HIT			default_kbd_hit
#define		ERASE_TO_EOLN	thinkc_erase_to_eoln
#define		ERASE_WINDOW	thinkc_erase_window
#define		SAVE_CURSOR		default_save_cursor
#define		RESTORE_CURSOR	default_restore_cursor

#endif	/* THINKC */

/*
**	MS-DOS Constants.
**
**	There are 3 different sets of MS-DOS constants defined here.
**	Those for Microsoft C (#define MSC), those for Borland C/Turbo C
**	(#define TURBOC), and a generic set. If neither MSC nor TURBOC
**	are defined then the generic set of constants will be used.
**
**	No "MALLOC" ( or "FREE" ) functions are defined in the generic
**	version, hence attempting to compile this version will produce
**	errors. The generic version uses ansi video routines which should
**	work with most MS-DOS ANSI.SYS files. If your ANSI.SYS does not support
**	the <ESC>[nJ sequence, then "SIMPLE_ANSI_ESCAPE" should also be defined.
**
**	Windowed scrolling is implemented using the INT 10h interrupt
**	function in "msdos_putchar()". This is done using the "int86 ()"
**	function defined in <dos.h>:
**
**		int
**		int86 ( intno,inregs,outregs )
**		int			intno ;
**		union REGS	*inregs ;
**		union REGS	*outregs ;
**
**	If your compiler does not support these features, please add an
**	extra definition rather than modifying the generic definition.
*/

#ifdef	MSDOS

#define WANT_COLOR

#include	<dos.h>

#define		INTERPRETER		APPLE_2E
#define		MODE_BITS		UNDERLINE
#define		SCREEN_WIDTH	80
#define		SCREEN_HEIGHT	25
#define		READ_STRING		"rb"
#define		WRITE_STRING	"wb"
#define		APPEND_STRING	"a"

#define		TIME_FUNCTION	time((long *)0)
#define		ONE_SECOND		1
#define		INIT_SIGNAL		msdos_signal_init
#define		SIGNAL_QUIT		msdos_signal_quit
#define		RCFILE			"infocom.rc"

#ifdef	MSC

#include	<malloc.h>

extern int	msc_get_x () ;
extern int	msc_get_y () ;

#define		Void			void
#define		HUGE			huge
#define		MALLOC(s)		halloc((long)((s/BLOCK_SIZE)+1),(size_t)BLOCK_SIZE)
#define		FREE(p)			hfree((void *)p)

#define		INIT_IO			msc_init_io
#define		EXIT_IO			msc_exit_io
#define		PUT_CHAR		msc_putchar
#define		GOTO_XY			msc_goto_xy
#define		GET_X			msc_get_x
#define		GET_Y			msc_get_y
#define		USE_WINDOW		null_io
#define		GET_CH			getch
#define		KBD_HIT			kbhit
#define		ERASE_TO_EOLN	msc_erase_to_eoln
#define		ERASE_WINDOW	msc_erase_window
#define		SAVE_CURSOR		default_save_cursor
#define		RESTORE_CURSOR	default_restore_cursor

#endif	/* MSC */

#ifdef	TURBOC

#include	<alloc.h>

extern int	tc_get_x () ;
extern int	tc_get_y () ;

#define		Void			void
#define		HUGE			huge
#define		MALLOC(s)		farmalloc((unsigned long)s)
#define		FREE(p)			farfree((void *)p)

#define		INIT_IO			tc_init_io
#define		EXIT_IO			null_io
#define		PUT_CHAR		tc_putchar
#define		GOTO_XY			tc_goto_xy
#define		GET_X			tc_get_x
#define		GET_Y			tc_get_y
#define		USE_WINDOW		null_io
#define		GET_CH			tc_getch
#define		KBD_HIT			kbhit
#define		ERASE_TO_EOLN	tc_erase_to_eoln
#define		ERASE_WINDOW	tc_erase_window
#define		SAVE_CURSOR		default_save_cursor
#define		RESTORE_CURSOR	default_restore_cursor

#endif	/* TURBOC */

#ifndef	MSC
#ifndef	TURBOC

#define		ANSI_ESCAPE

extern int	ansi_get_x () ;
extern int	ansi_get_y () ;

#define		Void			int
#define		HUGE
#define		MALLOC(s)		((char *)0)
#define		FREE(p)			(p)

#define		INIT_IO			ansi_init_io
#define		EXIT_IO			ansi_exit_io
#define		PUT_CHAR		msdos_putchar
#define		GOTO_XY			ansi_goto_xy
#define		GET_X			ansi_get_x
#define		GET_Y			ansi_get_y
#define		USE_WINDOW		null_io
#define		GET_CH			getch
#define		KBD_HIT			kbhit
#define		ERASE_TO_EOLN	ansi_erase_to_eoln
#define		ERASE_WINDOW	ansi_erase_window
#define		SAVE_CURSOR		ansi_save_cursor
#define		RESTORE_CURSOR	ansi_restore_cursor

#endif	/* TURBOC */
#endif	/* MSC */

#endif	/* MSDOS */


#include "atari_io.h"      /* Definitions for Atari ST. */


/*
**	Default Constant Settings
*/

#ifndef	INTERPRETER
#define		INTERPRETER		APPLE_2E
#endif	/* INTERPRETER */

#ifndef	MODE_BITS
#define		MODE_BITS		0
#endif	/* MODE_BITS */

#ifndef	SCREEN_WIDTH
#define		SCREEN_WIDTH	80
#endif	/* SCREEN_WIDTH */

#ifndef	SCREEN_HEIGHT
#define		SCREEN_HEIGHT	24
#endif	/* SCREEN_HEIGHT */

#ifndef	READ_STRING
#define		READ_STRING		"r"
#endif	/* READ_STRING */

#ifndef	WRITE_STRING
#define		WRITE_STRING	"w"
#endif	/* WRITE_STRING */

#ifndef	APPEND_STRING
#define		APPEND_STRING	"a"
#endif	/* APPEND_STRING */

#ifndef	Void
#define		Void			int
#endif	/* Void */

#ifndef	HUGE
#define		HUGE
#endif	/* HUGE */

#ifndef	MALLOC
#define		MALLOC(s)		malloc(s)
#endif	/* MALLOC */

#ifndef	FREE
#define		FREE(p)			free((char *)p)
#endif	/* FREE */

#ifndef	TIME_FUNCTION
#define		TIME_FUNCTION	-1L
#endif	/* TIME_FUNCTION */

#ifndef	ONE_SECOND


#define		ONE_SECOND		1
#endif	/* ONE_SECOND */

#ifndef	INIT_SIGNAL
#define		INIT_SIGNAL		default_signal_init
#endif	/* INIT_SIGNAL */

#ifndef	SIGNAL_QUIT
#define		SIGNAL_QUIT		default_signal_quit
#endif	/* SIGNAL_QUIT */

#ifndef	INIT_IO
#define		INIT_IO			null_io
#endif	/* INIT_IO */

#ifndef	EXIT_IO
#define		EXIT_IO			null_io
#endif	/* EXIT_IO */

#ifndef	PUT_CHAR
#define		PUT_CHAR		default_putchar
#endif	/* PUT_CHAR */

#ifndef	GOTO_XY
#define		GOTO_XY			default_goto_xy
#endif	/* GOTO_XY */

#ifndef	GET_X
#define		GET_X			default_get_x
#endif	/* GET_X */

#ifndef	GET_Y
#define		GET_Y			default_get_y
#endif	/* GET_Y */

#ifndef	USE_WINDOW
#define		USE_WINDOW		null_io
#endif	/* USE_WINDOW */

#ifndef	GET_CH
#define		GET_CH			getchar
#endif	/* GET_CH */

#ifndef	KBD_HIT
#define		KBD_HIT			default_kbd_hit
#endif	/* KBD_HIT */

#ifndef	ERASE_TO_EOLN
#define		ERASE_TO_EOLN	null_io
#endif	/* ERASE_TO_EOLN */

#ifndef	ERASE_WINDOW
#define		ERASE_WINDOW	null_io
#endif	/* ERASE_WINDOW */

#ifndef	SAVE_CURSOR
#define		SAVE_CURSOR		default_save_cursor
#endif	/* SAVE_CURSOR */

#ifndef	RESTORE_CURSOR
#define		RESTORE_CURSOR	default_restore_cursor
#endif	/* RESTORE_CURSOR */

#endif	/* __MACHINE__ */
