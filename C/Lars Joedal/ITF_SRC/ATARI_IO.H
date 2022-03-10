/*
**	Definitions for compiling under TOS (Atari ST) with Sozobon C
*/

#ifdef	SOZOBON

#include	<time.h>
#include	<malloc.h>


#define 	INTERPRETER 	ATARI_ST
#define 	SCREEN_WIDTH	80
#define 	SCREEN_HEIGHT	25
#define 	READ_STRING 	"rb"
#define 	WRITE_STRING	"wb"
#define 	APPEND_STRING	"a"

#define 	Void			void
#define 	MALLOC(s)		lalloc(s)
#define 	FREE(p) 		free((long *)p)

/* No advanced signal handling - just use default routines. */
#define 	INIT_SIGNAL 	default_signal_init
#define 	SIGNAL_QUIT 	default_signal_quit

#define 	RCFILE			"infocom.rc"

#define 	TIME_FUNCTION	clock ()
#define 	ONE_SECOND		CLK_TCK

#ifdef	VT52

#define 	MODE_BITS		0	/* not UNDERLINE */
#define 	INIT_IO 		vt52_init_io
#define 	EXIT_IO 		vt52_exit_io
#define 	PUT_CHAR		vt52_putchar
#define 	GOTO_XY 		vt52_goto_xy
#define 	GET_X			vt52_get_x
#define 	GET_Y			vt52_get_y
#define 	GET_CH			vt52_get_ch
#define 	KBD_HIT 		vt52_kbd_hit
#define 	ERASE_TO_EOLN	vt52_erase_to_eoln
#define 	USE_WINDOW		vt52_use_window
#define 	ERASE_WINDOW	vt52_erase_window
#define 	SAVE_CURSOR 	default_save_cursor
#define 	RESTORE_CURSOR	default_restore_cursor


/*
**	Function Prototypes
*/

int 			vt52_get_x () ;
int 			vt52_get_y () ;
int 			vt52_kbd_hit () ;
int 			vt52_get_ch () ;

Void			vt52_init_io () ;
Void			vt52_exit_io () ;
Void			vt52_goto_xy () ;
Void			vt52_putchar () ;
Void			vt52_use_window () ;
Void			vt52_erase_window () ;

/*
**	PLUS Function Prototypes
*/

int 			vt52_kbd_hit () ;



#endif	/* VT52 */

#endif	/* SOZOBON */

