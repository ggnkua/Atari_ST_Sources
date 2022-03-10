/*
**	File:	io.c
**
**	(C)opyright 1987-1992 InfoTaskforce.
*/

#include	<stdio.h>
#include	"infocom.h"

#include	<ctype.h>

#define		MAXATTR	10

#define		NORMAL_MODE			((word)0x00)
#define		INVERSE_MODE		((word)0x01)
#define		BOLD_MODE			((word)0x02)
#define		UNDERLINE_MODE		((word)0x04)

#define		INV_BOLD_MODE		((word)0x03)
#define		INV_UNDER_MODE		((word)0x05)
#define		BOLD_UNDER_MODE		((word)0x06)
#define		INV_BOLD_UNDER_MODE	((word)0x07)

static long	vidc[8][MAXATTR];
static word	text_mode = NORMAL_MODE;

#if (defined(CURSES) && !defined(BSD)) || defined(TERMINFO)

#define A_HIGH			A_BOLD
#define A_LOW			A_DIM
#define A_ITALIC		A_STANDOUT
#define A_FASTBLINK		A_BLINK

#define A_FGOFFSET		0
#define A_BGOFFSET		10

#else
#if defined(ANSI_ESCAPE)

/* ANSI Attributes */
#define	A_NORMAL		0
#define A_HIGH			1
#define A_LOW			2
#define A_ITALIC		3
#define A_UNDERLINE		4
#define A_BLINK			5
#define A_FASTBLINK		6
#define A_REVERSE		7

#ifdef WANT_COLOR
#define COLOR_BLACK		0
#define COLOR_RED		1
#define COLOR_GREEN		2
#define COLOR_YELLOW	3
#define COLOR_BLUE		4
#define COLOR_MAGENTA	5
#define COLOR_CYAN		6
#define COLOR_WHITE		7

#define A_FGOFFSET		30
#define A_BGOFFSET		40

#endif /* WANT_COLOR */

static boolean	use_save_cursor = FALSE ;

#else
#if defined(MSC) || defined(TURBOC)

/* Microsoft C Color Attributes */
#define	A_NORMAL		0
#define A_HIGH			1
#define A_LOW			0
#define A_ITALIC		0
#define A_UNDERLINE		0
#define A_BLINK			5
#define A_FASTBLINK		5
#define A_REVERSE		0
#define COLOR_BLACK		0
#define COLOR_RED		4
#define COLOR_GREEN		2
#define COLOR_YELLOW	6
#define COLOR_BLUE		1
#define COLOR_MAGENTA	5
#define COLOR_CYAN		3
#define COLOR_WHITE		7

#define A_FGOFFSET		10
#define A_BGOFFSET		20

#else

/* Dummy entries */
#define	A_NORMAL		0
#define A_HIGH			0
#define A_LOW			0
#define A_ITALIC		0
#define A_UNDERLINE		0
#define A_BLINK			0
#define A_FASTBLINK		0
#define A_REVERSE		0
#define COLOR_BLACK		0
#define COLOR_RED		0
#define COLOR_GREEN		0
#define COLOR_YELLOW	0
#define COLOR_BLUE		0
#define COLOR_MAGENTA	0
#define COLOR_CYAN		0
#define COLOR_WHITE		0

#define A_FGOFFSET		0
#define A_BGOFFSET		0

#endif
#endif
#endif

typedef struct attrtype
{
	char	*attrtok;
	long	attrnum;
} ATYPE;

static ATYPE	vidattrs[] =
{
	{ "normal",	A_NORMAL },
	{ "high",	A_HIGH },
	{ "low",	A_LOW },
	{ "italic",	A_ITALIC },
	{ "underline",	A_UNDERLINE },
	{ "blink",	A_BLINK },
	{ "fastblink",	A_FASTBLINK },
	{ "reverse",	A_REVERSE },
#ifdef WANT_COLOR
	{ "f_black",	A_FGOFFSET + COLOR_BLACK },
	{ "f_red",	A_FGOFFSET + COLOR_RED },
	{ "f_green",	A_FGOFFSET + COLOR_GREEN },
	{ "f_yellow",	A_FGOFFSET + COLOR_YELLOW },
	{ "f_blue",	A_FGOFFSET + COLOR_BLUE },
	{ "f_magenta",	A_FGOFFSET + COLOR_MAGENTA },
	{ "f_cyan",	A_FGOFFSET + COLOR_CYAN },
	{ "f_white",	A_FGOFFSET + COLOR_WHITE },
	{ "b_black",	A_BGOFFSET + COLOR_BLACK },
	{ "b_red",	A_BGOFFSET + COLOR_RED },
	{ "b_green",	A_BGOFFSET + COLOR_GREEN },
	{ "b_yellow",	A_BGOFFSET + COLOR_YELLOW },
	{ "b_blue",	A_BGOFFSET + COLOR_BLUE },
	{ "b_magenta",	A_BGOFFSET + COLOR_MAGENTA },
	{ "b_cyan",	A_BGOFFSET + COLOR_CYAN },
	{ "b_white",	A_BGOFFSET + COLOR_WHITE }
#endif
};

static char *
rc_get_token ( pstr )
char	**pstr;
{
	char	*tok ;

	while ( **pstr && isspace( **pstr ) )
		( *pstr )++ ;

	if (!**pstr)
		return 0 ;

	/* read keyword */
	tok = *pstr ;
	while ( **pstr && ! isspace ( **pstr ) )
	{
		if ( isupper ( **pstr ) )
			**pstr = tolower( **pstr ) ;
		( *pstr )++ ;
	}

	return tok;
}

static Void
rc_parse_attr ( attrnum, str )
int		attrnum;
char	*str;
{
	char	*attr ;

	vidc[attrnum][0] = 0 ;

	while ( attr = rc_get_token ( &str ) )
	{
		int	i ;

		for ( i = 0 ; i < sizeof ( vidattrs ) / sizeof ( ATYPE ) ; i++ )
			if ( !strncmp ( attr,vidattrs[i].attrtok,str - attr ) )
				vidc[attrnum][++vidc[attrnum][0]] = vidattrs[i].attrnum ;
	}
}

static Void
default_attrs ()
{
#ifdef WANT_COLOR

	/* default colors */
	vidc[NORMAL_MODE][0] = 2 ;
	vidc[NORMAL_MODE][1] = COLOR_CYAN + A_BGOFFSET ;
	vidc[NORMAL_MODE][2] = COLOR_BLACK + A_FGOFFSET ;

	vidc[INVERSE_MODE][0] = 3 ;
	vidc[INVERSE_MODE][1] = COLOR_RED + A_BGOFFSET ;
	vidc[INVERSE_MODE][2] = COLOR_CYAN + A_FGOFFSET ;
	vidc[INVERSE_MODE][3] = A_HIGH ;

	vidc[BOLD_MODE][0] = 2 ;
	vidc[BOLD_MODE][1] = COLOR_CYAN + A_BGOFFSET ;
	vidc[BOLD_MODE][2] = COLOR_YELLOW + A_FGOFFSET ;

	vidc[INV_BOLD_MODE][0] = 2 ;
	vidc[INV_BOLD_MODE][1] = COLOR_RED + A_BGOFFSET ;
	vidc[INV_BOLD_MODE][2] = COLOR_YELLOW + A_FGOFFSET ;

	vidc[UNDERLINE_MODE][0] = 3 ;
	vidc[UNDERLINE_MODE][1] = COLOR_CYAN + A_BGOFFSET ;
	vidc[UNDERLINE_MODE][2] = COLOR_GREEN + A_FGOFFSET ;
	vidc[UNDERLINE_MODE][3] = A_HIGH ;

	vidc[INV_UNDER_MODE][0] = 3 ;
	vidc[INV_UNDER_MODE][1] = COLOR_RED + A_BGOFFSET ;
	vidc[INV_UNDER_MODE][2] = COLOR_GREEN + A_FGOFFSET ;
	vidc[INV_UNDER_MODE][3] = A_HIGH ;

	vidc[BOLD_UNDER_MODE][0] = 2 ;
	vidc[BOLD_UNDER_MODE][1] = COLOR_CYAN + A_BGOFFSET ;
	vidc[BOLD_UNDER_MODE][2] = COLOR_WHITE + A_FGOFFSET ;

	vidc[INV_BOLD_UNDER_MODE][0] = 2 ;
	vidc[INV_BOLD_UNDER_MODE][1] = COLOR_RED + A_BGOFFSET ;
	vidc[INV_BOLD_UNDER_MODE][2] = COLOR_WHITE + A_FGOFFSET ;

#else

	/* default colors */
	vidc[NORMAL_MODE][0] = 1 ;
	vidc[NORMAL_MODE][1] = A_NORMAL ;

	vidc[INVERSE_MODE][0] = 1 ;
	vidc[INVERSE_MODE][1] = A_REVERSE ;

	vidc[BOLD_MODE][0] = 1 ;
	vidc[BOLD_MODE][1] = A_HIGH ;

	vidc[INV_BOLD_MODE][0] = 2 ;
	vidc[INV_BOLD_MODE][1] = A_REVERSE ;
	vidc[INV_BOLD_MODE][2] = A_HIGH ;

	vidc[UNDERLINE_MODE][0] = 1 ;
	vidc[UNDERLINE_MODE][1] = A_UNDERLINE ;

	vidc[INV_UNDER_MODE][0] = 2 ;
	vidc[INV_UNDER_MODE][1] = A_REVERSE ;
	vidc[INV_UNDER_MODE][2] = A_UNDERLINE ;

	vidc[BOLD_UNDER_MODE][0] = 2 ;
	vidc[BOLD_UNDER_MODE][1] = A_HIGH ;
	vidc[BOLD_UNDER_MODE][2] = A_UNDERLINE ;

	vidc[INV_BOLD_UNDER_MODE][0] = 3 ;
	vidc[INV_BOLD_UNDER_MODE][1] = A_REVERSE ;
	vidc[INV_BOLD_UNDER_MODE][2] = A_HIGH ;
	vidc[INV_BOLD_UNDER_MODE][3] = A_UNDERLINE ;

#endif /* WANT COLOR */
}

static Void
read_rcfile()
{
	extern int	screen_width ;
	extern int	screen_height ;

	extern long atol();
	extern char *getenv();

	static char default_rcfile[] = RCFILE;
	char	*home = getenv("HOME");
	char	rcfile[BUFSIZ];
	FILE	*rc;

	if (home)
		sprintf(rcfile, "%s/%s", home, default_rcfile);
	else
		strcpy(rcfile, default_rcfile);

	if ( (rc = fopen(rcfile, "r")) || (rc = fopen(RCFILE, "r")) )
	{
		int	attrnum = 0;

		while	(fgets(rcfile, BUFSIZ, rc))
		{
			char	*p = rcfile, *q;
			int	len;

			q = rc_get_token(&p);

			/* Added check for q == 0  -lj */
			if (q == 0)
				continue; /* empty line */

			if (*q == '#')
				continue; /* comment character */

			len = p - q;

			if (!strncmp(q, "height", len))
			{
				long	l = atol(p);

				if (l)
					screen_height = (int)l;
			}
			else if (!strncmp(q, "width", len))
			{
				long	l = atol(p);

				if (l)
					screen_width = (int)l;
			}
#ifdef ANSI_ESCAPE
			else if (!strncmp(q, "save", len))
				use_save_cursor = TRUE ;
#endif
			else if (!strncmp(q, "attr", len))
				rc_parse_attr(attrnum++, p);
		}
		fclose(rc);
	}
}

Void
print_status ( s_buffer )
byte	s_buffer[] ;
{
	Void	PUT_CHAR () ;
	Void	GOTO_XY () ;
	extern int	screen_width ;
	extern int	screen_height ;

	byte		*ptr	= s_buffer ;
	int			i		= screen_width ;

	/*
	**	Note:
	**		The variable "ptr" is of type "byte *"
	**		NOT "byte_ptr" - these definitions are
	**		different for MSDOS Compilers ("byte_ptr" is huge).
	*/

	GOTO_XY ( 0,0 ) ;
	PUT_CHAR ( (char)2 ) ;
	while ( i-- )
		out_char ( (char)*ptr++ ) ;
	PUT_CHAR ( (char)1 ) ;
	GOTO_XY ( 0,screen_height-1 ) ;
}

Void
display ( s )
char	*s ;
{
	Void	PUT_CHAR () ;

	while ( *s != '\0' )
		PUT_CHAR ( *s++ ) ;
}

Void
raw_display ( s )
char	*s ;
{
	/*
	**	"raw_display ()" must be used to print ANSI_ESCAPE sequences
	**	since we want these strings printed regardless of the state of
	**	"enable_screen". If "display ()" is used, then the "PUT_CHAR" routine
	**	will be called to print each character of the string - which will
	**	only happen if "enable_screen" is true.
	*/

	printf ( s ) ;
}

char	hex_string[] =	{
							'0','1','2','3','4','5','6','7',
							'8','9','A','B','C','D','E','F'
						} ;

Void
hex_digit ( n,level )
word	n ;
int		level ;
{
	Void	PUT_CHAR () ;

	if ( level < 4 )
	{
		hex_digit ( n/16,level+1 ) ;
		PUT_CHAR ( hex_string[n % 16] ) ;
	}
}

Void
hex_display ( n )
word	n ;
{
	hex_digit ( n,0 ) ;
}

char
read_char ()
{
	extern boolean	echo_in ;
	extern boolean	enhanced ;
	Void	PUT_CHAR () ;

	char			ch ;
	int				in ;

	if ( enhanced )
	{
		if (( in = GET_CH ()) == EOF )
		{
			/*
			**	If input is from file, handle EOF
			*/

			ch = '\n' ;
			quit () ;
		}
		else
			ch = (char)in ;
		if ( ch == '\r' )
			ch = '\n' ;
		PUT_CHAR ( ch ) ;
	}
	else
	{
		if (( in = GET_CH () ) == EOF )	/* Changed "getchar" to "GET_CH" -lj */
		{
			/*
			**	If input is from file, handle EOF
			*/

			ch = '\n' ;
			quit () ;
		}
		else
			ch = (char)in ;
		if ( echo_in )
			putchar ( ch ) ;
	}
	script_char ( ch ) ;
	return ( ch ) ;
}

Void
out_char ( c )
char	c ;
{
	extern boolean	enhanced ;
	extern boolean	windowing_enabled ;
	extern word		current_window ;
	extern word		window_height ;
	extern boolean	enable_screen ;
	extern int		screen_height ;
	extern int		linecount ;
	Void	PUT_CHAR () ;
	
	script_char ( c ) ;
	PUT_CHAR ( c ) ;
	if (( enable_screen ) && ( c == '\n' ))
	{
		if ( enhanced )
		{
			if ( windowing_enabled == FALSE )
			{
				if ( linecount++ >= screen_height - 4 )
				{
					more () ;
					linecount = 0 ;
				}
				return ;
			}
			if (( windowing_enabled == TRUE ) && ( current_window == 0 ))
			{
				if ( linecount++ >= screen_height - (int)window_height - 4 )
				{
					more () ;
					linecount = 0 ;
				}
				return ;
			}
		}
		else
		{
			if ( linecount++ >= screen_height - 4 )
			{
				more () ;
				linecount = 0 ;
			}
		}
	}
}

Void
more ()
{
	extern boolean	page_out ;

	int				in ;

	if ( !page_out )
	{
		display ( "[MORE]" ) ;
		in = GET_CH () ;
		display ( "\b\b\b\b\b\b      \b\b\b\b\b\b" ) ;
	}
}

word
allocate ( max_blocks )
word	max_blocks ;
{
	/*
	**	This routine allocates a page_table with 'max_blocks + 1' entries.
	**	This is because the page table needs one entry more than the number
	**	of allocated blocks. If it fails to allocate a table for the maximum
	**	number of blocks required, then it returns 0 - if it cannot allocate
	**	enough space for this table, then there will not be enough memory for
	**	a workable interpreter ... there isn't much point in trying to allocate
	**	a smaller table.
	**
	**	It then tries to allocate a contiguous block of memory
	**	that is at least 'max_blocks * BLOCK_SIZE' bytes long. If one
	**	is not available, 'BLOCK_SIZE' is continually subtracted from
	**	this amount, and it tries again.
	*/

	extern byte_ptr			base_ptr ;
	extern page_table_ptr	strt_page_table ;

	long					size ;

	size = ((long)max_blocks + 1 ) * sizeof ( page_table_t ) ;
	if ((strt_page_table = (page_table_ptr) MALLOC(size)) == (page_table_ptr)0)
	{
		base_ptr = (byte_ptr)0 ;
		return ( (word)0 ) ;
	}
	size = (long)max_blocks * BLOCK_SIZE ;
	while ((size != 0) && ((base_ptr = (byte_ptr) MALLOC(size)) == (byte_ptr)0))
		size -= BLOCK_SIZE ;
	return ((word)( size / (long)BLOCK_SIZE )) ;
}

Void
deallocate ()
{
	extern byte_ptr			base_ptr ;
	extern page_table_ptr	strt_page_table ;

	if ( base_ptr != (byte_ptr)0 )
	{
		FREE ( base_ptr ) ;
		base_ptr = (byte_ptr)0 ;
	}
	if ( strt_page_table != (page_table_ptr)0 )
	{
		FREE ( strt_page_table ) ;
		strt_page_table = (page_table_ptr)0 ;
	}
}

Void
seed_random ()
{
	/*
	**	This routine seeds the random number generator.
	*/

	extern word		random1 ;
	extern word		random2 ;

	random1 = (word)(TIME_FUNCTION >> 16) ;
	random2 = (word)TIME_FUNCTION ;
}

/*
**	Default Signal Trapping Routine.
*/

/*ARGSUSED*/
Void
default_signal_init ( sig_action )
int		sig_action ;
{
	/*
	**	Do nothing ...
	*/
}

/*ARGSUSED*/
Void
default_signal_quit ( sig_action )
int		sig_action ;
{
	/*
	**	Do nothing ...
	*/
}

/*ARGSUSED*/
Void
signal_shit ( action )
int		action ;
{
	extern int	sig_async ;
	extern int	sig_action ;

	switch ( sig_async )
	{
		case SH_INIT:
						/*
						**	Close I/O, files and memory.
						**	"main ()" will call "SIG_QUIT ()".
						*/

						sig_action |= ( SH_CLOSE | SH_IO ) ;
						break ;
		case SH_NORMAL:
						/*
						**	Close I/O, files and memory. Do it NOW !
						*/

						SIGNAL_QUIT ( sig_action | SH_CLOSE | SH_IO ) ;
						break ;
		case SH_NO_IO:
						/*
						**	Close files and memory only. Do it NOW !
						*/

						SIGNAL_QUIT ( sig_action | SH_CLOSE ) ;
						break ;
		default:
						break ;
	}
}

/*ARGSUSED*/
Void
signal_chit ( action )
int		action ;
{
	extern int	sig_action ;

	/*
	**	Request a core dump.
	*/

	sig_action |= SH_COREDUMP ;
	signal_shit () ;
}

/*
**	Default I/O Routines.
*/

Void
null_io ()
{
	/*
	**	Do nothing ...
	*/
}

Void
default_putchar ( c )
char	c ;
{
	extern boolean	enable_screen ;

	switch ( c )
	{
		case 1:
		case 2:
		case 3:
		case 4:
		case 5:
				/*
				**	Special Text Modes.
				*/

				break ;
		case 0:
				c = ' ' ;

				/*
				**	Fall Through ...
				*/

		default:
				if ( enable_screen )
					putchar ( c ) ;
				break ;
	}
}

Void
default_goto_xy ( x,y )
int		x,y ;
{
	out_char ( '\n' ) ;
}

int
default_get_x ()
{
	return ( 0 ) ;
}

int
default_get_y ()
{
	extern int	screen_height ;

	return ( screen_height - 1 ) ;
}

/*
**	The Enhanced Windowing Default I/O Functions.
*/

int		saved_cursor_x ;
int		saved_cursor_y ;

Void
default_save_cursor ()
{
	extern int	saved_cursor_x ;
	extern int	saved_cursor_y ;

	saved_cursor_x = GET_X () ;
	saved_cursor_y = GET_Y () ;
}

Void
default_restore_cursor ()
{
	Void		GOTO_XY () ;

	extern int	saved_cursor_x ;
	extern int	saved_cursor_y ;

	GOTO_XY ( saved_cursor_x,saved_cursor_y ) ;
}

/*
**	The PLUS Series Default I/O Functions.
*/

int
default_kbd_hit ()
{
	return ( TRUE ) ;
}

/*
**	Lightspeed C Version 2.01 I/O Routines.
**
**	Only compiled if LSC is defined.
*/

#ifdef	LSC

#undef		FALSE
#undef		TRUE
#include	<Quickdraw.h>
#define		FALSE		(0)
#define		TRUE		(!FALSE)

FontInfo	fi ;
Rect		full_screen ;
int			line_height ;

Void
lsc_init_io ()
{
	extern FontInfo		fi ;
	extern Rect			full_screen ;
	extern int			line_height ;
	extern word			top_screen_line ;

	GetFontInfo ( &fi ) ;
	line_height = fi.ascent + fi.descent + fi.leading ;
	thePort -> portRect.top += top_screen_line * line_height ;
	full_screen = thePort -> portRect ;
}

#define		CHAR_OFFSET		1

Void
lsc_putchar ( c )
char	c ;
{
	extern FontInfo	fi ;
	extern boolean	enable_screen ;
	extern word		text_mode ;

	Point			pn_loc ;
	RgnHandle		update ;
	Rect			r ;

	switch ( c )
	{
		case 1:
				text_mode = NORMAL_MODE ;
				break ;
		case 2:
				text_mode |= INVERSE_MODE ;
				break ;
		case 3:
				text_mode |= BOLD_MODE ;
				break ;
		case 4:
				break ;
		case 5:
				text_mode |= UNDERLINE_MODE ;
				break ;
		case 0:
				c = ' ' ;

				/*
				**	Fall Through ...
				*/

		default:
				if ( enable_screen )
				{
					GetPen ( &pn_loc ) ;
					SetRect ( &r,pn_loc.h-CHAR_OFFSET,pn_loc.v-fi.ascent,pn_loc.h+fi.widMax,pn_loc.v+fi.descent ) ;
					EraseRect ( &r ) ;
					if ( text_mode & BOLD_MODE )
					{
						TextFace ( bold ) ;
						putchar ( c ) ;
						TextFace ( 0 ) ;
						update = NewRgn () ;
						ScrollRect ( &r,-CHAR_OFFSET,0,update ) ;
						DisposeRgn ( update ) ;
						GOTO_XY ( GET_X (),GET_Y () ) ;
					}
					else
						putchar ( c ) ;
					if ( text_mode & UNDERLINE_MODE )
					{
						MoveTo ( pn_loc.h-CHAR_OFFSET,pn_loc.v+fi.descent-1 ) ;
						LineTo ( pn_loc.h+fi.widMax,pn_loc.v+fi.descent-1 ) ;
						GOTO_XY ( GET_X (),GET_Y () ) ;
					}
					if ( text_mode & INVERSE_MODE )
						InvertRect ( &r ) ;
				}
				break ;
	}
}

/*
**	The Enhanced Windowing LSC I/O Functions.
*/

Void
lsc_use_window ( the_window )
word	the_window ;
{
	extern word		window_height ;
	extern Rect		full_screen ;
	extern int		line_height ;

	switch ( the_window )
	{
		case WINDOW_0:
						/*
						**	Use the Lower Window.
						*/
						
						thePort -> portRect.top = full_screen.top + window_height * line_height ;
						thePort -> portRect.bottom = full_screen.bottom ;
						break ;
		case WINDOW_1:
						/*
						**	Use the Upper Window.
						*/
						
						thePort -> portRect.top = full_screen.top ;
						thePort -> portRect.bottom = full_screen.top + window_height * line_height ;
						break ;
		case FULL_SCREEN:
						/*
						**	Use the entire Screen.
						*/
						
						thePort -> portRect.top = full_screen.top ;
						thePort -> portRect.bottom = full_screen.bottom ;
						break ;
	}
}

#define		_CONTROLWIDTH	15		/* Width of Scroll Bar */
#define		_LEFTEDGE		4		/* Margins             */
#define		_TOPEDGE		4

Void
lsc_erase_window ( top_of_window,bottom_of_window )
word	top_of_window ;
word	bottom_of_window ;
{
	extern Rect		full_screen ;
	extern int		line_height ;
	extern int		screen_height ;
	extern word		top_screen_line ;
	
	Rect			r ;

	/*
	**	The problem with using Lightspeed C stdio is that when erasing
	**	the console window, its text buffer should also be cleared. Since
	**	this is quite tricky, we fudge it by printing a '\f' character
	**	when clearing the whole screen. When the screen is only partially
	**	cleared, we do not clear those lines from the console window's
	**	screen buffer ... this may sometimes cause problems !!!
	*/
			
	if	(
			( top_of_window == top_screen_line )
			&&
			( bottom_of_window == (word)screen_height )
		)
	{
		out_char ( '\f' ) ;
	}
	else
	{
		r.bottom = full_screen.top + bottom_of_window * line_height ;
		r.top = full_screen.top + _TOPEDGE + ( top_of_window - top_screen_line ) * line_height ;
		r.left = full_screen.left + _LEFTEDGE ;
		r.right = full_screen.right - _CONTROLWIDTH ;
		EraseRect ( &r ) ;
	}
}

/*
**	The PLUS Series LSC I/O Functions.
*/

Void
lsc_erase_to_eoln ()
{
	/*
	**	The characters at the cursor and to the right are erased.
	**	The cursor itself is not moved.
	*/

	extern int	screen_width ;
	int			saved_x_posn ;
	int			saved_y_posn ;
	int			i ;

	saved_x_posn = GET_X () ;
	saved_y_posn = GET_Y () ;
	for ( i = saved_x_posn ; i < screen_width ; i++ )
		out_char ( ' ' ) ;
	GOTO_XY ( saved_x_posn,saved_y_posn ) ;
}

#endif	/* LSC */

/*
**	MICROSOFT C I/O Routines
**
**	Only compiled if MSC defined.
*/

#ifdef	MSC

#include	<graph.h>

boolean			isvideoinit		= FALSE ;
boolean			saved_vidpage ;
short			user_vidpage ;
char			chs[9] ;

Void
msc_textattr ( modestr )
long	*modestr ;
{
	int	i, maxi;
	int	textmode = 0;

	for (maxi = *modestr, i = 1; i <= maxi; i++)
	{
		if (modestr[i] >= A_BGOFFSET)
			_setbkcolor ( (int) modestr[i] - A_BGOFFSET ) ;
		else if (modestr[i] >= A_FGOFFSET)
			textmode |= (int) modestr[i] - A_FGOFFSET ;
		else if (modestr[i] == A_BLINK)
			textmode |= 0x10 ;
		else if (modestr[i] == A_HIGH)
			textmode |= 0x08 ;
	}
	_settextcolor ( textmode ) ;
}

Void
msc_init_io ()
{
	extern boolean		enhanced ;
	extern boolean		isvideoinit ;
	extern int			screen_width ;
	extern int			screen_height ;
	extern word			text_mode ;
	extern boolean		saved_vidpage ;
	extern short		user_vidpage ;

	struct videoconfig	conf ;
	short				npages ;
	short				newvidpage ;

	enhanced = TRUE ;
	isvideoinit = TRUE ;
	_getvideoconfig ( &conf ) ;
	screen_width = conf.numtextcols ;
	screen_height = conf.numtextrows ;

	default_attrs () ;
	read_rcfile () ;

	if ( saved_vidpage = (( npages = conf.numvideopages ) > 1 ))
	{
		user_vidpage = _getactivepage () ;
		newvidpage = ( user_vidpage + 1 ) % npages ;
		_setactivepage ( newvidpage ) ;
	}

	text_mode = NORMAL_MODE ;
	msc_textattr ( vidc[NORMAL_MODE] ) ;
	_clearscreen ( _GCLEARSCREEN ) ;
	GOTO_XY ( 0,screen_height - 1 ) ;
	if ( saved_vidpage )
		_setvisualpage ( newvidpage ) ;
}

Void
msc_exit_io ()
{
	extern boolean	saved_vidpage ;
	extern short	user_vidpage ;

	if ( saved_vidpage )
	{
		_setactivepage ( user_vidpage ) ;
		_setvisualpage ( user_vidpage ) ;
	}
}

Void
msc_putchar ( c )
char	c ;
{
	extern boolean	enhanced ;
	extern boolean	isvideoinit ;
	extern boolean	enable_screen ;
	extern word		text_mode ;
	extern int		screen_width ;
	extern int		screen_height ;
	extern boolean	windowing_enabled ;
	extern word		window_height ;
	extern word		top_screen_line ;
	extern char		chs[] ;

	if ( isvideoinit )
	{
		switch ( c )
		{
			case 1:
					text_mode = NORMAL_MODE ;
					msc_textattr ( vidc[text_mode] ) ;
					break ;
			case 2:
					text_mode |= INVERSE_MODE ;
					msc_textattr ( vidc[text_mode] ) ;
					break ;
			case 3:
					text_mode |= BOLD_MODE ;
					msc_textattr ( vidc[text_mode] ) ;
					break ;
			case 4:
					break ;
			case 5:
					text_mode |= UNDERLINE_MODE ;
					msc_textattr ( vidc[text_mode] ) ;
					break ;
			case 0:
					c = ' ' ;

					/*
					**	Fall Through ...
					*/

			default:
					if ( enable_screen )
					{
						if ( c == '\n' )
						{
							if ( GET_Y () == screen_height - 1 )
							{
								if ( enhanced )
								{
									if ( windowing_enabled == TRUE )
									{
										_settextwindow ( window_height + top_screen_line + 1,1,screen_height,screen_width ) ;
										_scrolltextwindow ( _GSCROLLUP ) ;
										_settextwindow ( 1,1,screen_height,screen_width ) ;
										GOTO_XY ( 0,screen_height - 1 ) ;
									}
									else
										_outtext ( "\n" ) ;
								}
								else
									_outtext ( "\n" ) ;
							}
							else
								_outtext ( "\n" ) ;
						}
						else
						{
							if ( c < 0x20 )
							{
								if ( c == '\b' )
								{
									/*
									**	destructive backspace
									*/

									int		col ;

									col = GET_X () ;
									if ( col > 0 )
									{
										--col ;
										GOTO_XY ( col,GET_Y () ) ;
										chs[0] = ' ' ;
										chs[1] = '\0' ;
										_outtext ( chs ) ;
										GOTO_XY ( col,GET_Y () ) ;
									}
								}
								else
								{
									if ( c == '\t' )
									{
										int		n ;
										int		i ;

										n = 8 - (( GET_X () - 1 ) % 8 ) ;
										for ( i = 0 ; i < n ; i++ )
											chs[i] = ' ' ;
										chs[n] = '\0' ;
										_outtext ( chs ) ;
									}
								}
							}
							else
							{
								chs[0] = c ;
								chs[1] = '\0' ;
								_outtext ( chs ) ;
							}
						}
					}
					break ;
		}
	}
	else
	{
		if ( enable_screen )
		{
			if ( c == '\0' )
				c = ' ' ;
			if ( c > 5 )
				putchar ( c ) ;
		}
	}
}

Void
msc_goto_xy ( x,y )
int		x,y ;
{
	_settextposition ( y+1,x+1 ) ;
}

int
msc_get_x ()
{
	struct rccoord	cursor ;

	cursor = _gettextposition () ;
	return ( cursor.col - 1 ) ;
}

int
msc_get_y ()
{
	struct rccoord	cursor ;

	cursor = _gettextposition () ;
	return ( cursor.row - 1 ) ;
}

/*
**	The Enhanced Windowing MICROSOFT I/O Functions.
*/

Void
msc_erase_window ( top_of_window,bottom_of_window )
word	top_of_window ;
word	bottom_of_window ;
{
	extern int	screen_width ;
	extern int	screen_height ;

	_settextwindow ( top_of_window+1,1,bottom_of_window,screen_width ) ;
	_clearscreen ( _GWINDOW ) ;
	_settextwindow ( 1,1,screen_height,screen_width ) ;
	GOTO_XY ( 0,top_of_window ) ;
}

/*
**	The PLUS Series MICROSOFT I/O Functions.
*/

Void
msc_erase_to_eoln ()
{
	extern int		screen_width ;
	extern int		screen_height ;

	int				row ;
	int				col ;

	col = GET_X () ;
	row = GET_Y () ;
	_settextwindow ( row+1,col+1,row+1,screen_width ) ;
	_clearscreen ( _GWINDOW ) ;
	_settextwindow ( 1,1,screen_height,screen_width ) ;
	GOTO_XY ( col,row ) ;
}

#endif	/* MSC */

/*
**	TURBO C I/O Routines
**
**	Only compiled if TURBOC defined.
*/

#ifdef	TURBOC

#include	<conio.h>
#include	<signal.h>
/* #include	<string.h> */

#define		CTRL_C			((byte)0x03)

boolean		isvideoinit		= FALSE ;

/*
**	The way to get more than 25 lines in TURBOC is to manipulate the
**	undocumented "_video" structure. The structure definition outlined
**	below is only a guess, but it seems to make sense. The address
**	"( &_video ) + 7" is what is used by "window ()", "gotoxy ()", etc. to
**	determine screen height. It is not initialised to above 25 in the
**	TURBOC startup routine, so "tc_init_io ()" does it explicitly ...
*/

extern struct	video_def
{
	unsigned char	wleft_dec ;
	unsigned char	wtop_dec ;
	unsigned char	wright_dec ;
	unsigned char	wbottom_dec ;
	unsigned char	tattr ;
	unsigned char	nattr ;
	unsigned char	vmode ;
	unsigned char	srows ;
	unsigned char	scols ;
} _video ;

Void
tc_textattr ( modestr )
long	*modestr ;
{
	int	i, maxi;
	int	textmode = 0;

	for (maxi = *modestr, i = 1; i <= maxi; i++)
	{
		if (modestr[i] >= A_BGOFFSET)
			textmode |= (int) ( modestr[i] - A_BGOFFSET ) << 4 ;
		else if (modestr[i] >= A_FGOFFSET)
			textmode |= (int) modestr[i] - A_FGOFFSET ;
		else if (modestr[i] == A_BLINK)
			textmode |= 0x10 ;
		else if (modestr[i] == A_HIGH)
			textmode |= 0x08 ;
	}
	textattr ( textmode ) ;
}

Void
tc_init_io ()
{
	extern boolean	enhanced ;
	extern boolean	isvideoinit ;
	extern int		screen_width ;
	extern int		screen_height ;
	extern word		text_mode ;

	unsigned char	srows ;

	enhanced = TRUE ;
	isvideoinit = TRUE ;

	/*
	**	update TURBOC "_video" structure with BIOS
	**	data area values for screen size.
	*/

	srows = peekb ( 0x40,0x84 ) + 1 ;
	if ( srows != 0 )
		_video.srows = srows ;
	_video.scols = peekb ( 0x40,0x4A ) ;

	screen_width = _video.scols ;
	screen_height = _video.srows ;

	default_attrs () ;
	read_rcfile () ;

	window ( 1,1,screen_width,screen_height ) ;
	text_mode = NORMAL_MODE ;
	tc_textattr ( vidc[NORMAL_MODE] ) ;
	clrscr () ;
	GOTO_XY ( 0,screen_height - 1 ) ;
}

Void
tc_putchar ( c )
char	c ;
{
	extern boolean	enhanced ;
	extern boolean	isvideoinit ;
	extern boolean	enable_screen ;
	extern word		text_mode ;
	extern int		screen_width ;
	extern int		screen_height ;
	extern boolean	windowing_enabled ;
	extern word		window_height ;
	extern word		top_screen_line ;

	if ( isvideoinit )
	{
		switch ( c )
		{
			case 1:
					text_mode = NORMAL_MODE ;
					tc_textattr ( vidc[text_mode] ) ;
					break ;
			case 2:
					text_mode |= INVERSE_MODE ;
					tc_textattr ( vidc[text_mode] ) ;
					break ;
			case 3:
					text_mode |= BOLD_MODE ;
					tc_textattr ( vidc[text_mode] ) ;
					break ;
			case 4:
					break ;
			case 5:
					text_mode |= UNDERLINE_MODE ;
					tc_textattr ( vidc[text_mode] ) ;
					break ;
			case 0:
					c = ' ' ;

					/*
					**	Fall Through ...
					*/

			default:
					if ( enable_screen )
					{
						if ( c == '\n' )
						{
							if ( GET_Y () == screen_height - 1 )
							{
								if ( enhanced )
								{
									if ( windowing_enabled == TRUE )
									{
										window ( 1,window_height + top_screen_line + 1,screen_width,screen_height ) ;
										gotoxy ( 1,screen_height - window_height - top_screen_line ) ;
										cprintf ( "\n\r" ) ;
										clreol () ;
										window ( 1,1,screen_width,screen_height ) ;
										GOTO_XY ( 0,screen_height - 1 ) ;
									}
									else
									{
										cprintf ( "\n\r" ) ;
										clreol () ;
									}
								}
								else
								{
									cprintf ( "\n\r" ) ;
									clreol () ;
								}
							}
							else
								cprintf ( "\n\r" ) ;
						}
						else
						{
							if ( c < 0x20 )
							{
								if ( c == '\b' )
								{
									/*
									**	destructive backspace
									*/

									int		col ;

									col = GET_X () ;
									if ( col > 0 )
									{
										--col ;
										GOTO_XY ( col,GET_Y () ) ;
										putch ( ' ' ) ;
										GOTO_XY ( col,GET_Y () ) ;
									}
								}
								else
								{
									if ( c == '\t' )
									{
										int		n ;
										int		i ;

										n = 8 - (( GET_X () - 1 ) % 8 ) ;
										for ( i = 0 ; i < n ; i++ )
											putch ( ' ' ) ;
									}
								}
							}
							else
								putch ( c ) ;
						}
					}
					break ;
		}
	}
	else
	{
		if ( enable_screen )
		{
			if ( c == '\0' )
				c = ' ' ;
			if ( c > 5 )
				putchar ( c ) ;
		}
	}
}

Void
tc_goto_xy ( x,y )
int		x,y ;
{
	gotoxy ( x+1,y+1 ) ;
}

int
tc_get_x ()
{
	return ( wherex () - 1 ) ;
}

int
tc_get_y ()
{
	return ( wherey () - 1 ) ;
}

int
tc_getch ()
{
	int		in_char ;

	if (( in_char = getch ()) == CTRL_C )
		raise ( SIGINT ) ;
	return ( in_char ) ;
}

/*
**	The Enhanced Windowing TURBOC I/O Functions.
*/

Void
tc_erase_window ( top_of_window,bottom_of_window )
word	top_of_window ;
word	bottom_of_window ;
{
	extern int	screen_width ;
	extern int	screen_height ;

	window ( 1,top_of_window+1,screen_width,bottom_of_window ) ;
	clrscr () ;
	window ( 1,1,screen_width,screen_height ) ;
	GOTO_XY ( 0,top_of_window ) ;
}

/*
**	The PLUS Series TURBOC I/O Functions.
*/

Void
tc_erase_to_eoln ()
{
	clreol () ;
}

#endif	/* TURBOC */

#ifdef ANSI_ESCAPE

static Void
ansi_textattr ( modestr )
long	*modestr ;
{
	char	attrstr[BUFSIZ];
	char	*p;
	int		i, maxi;

	strcpy ( attrstr,"\033[0" );
	p = attrstr + strlen ( attrstr ) ;
	for ( maxi = (int) *modestr, i = 1 ; i <= maxi ; i++ )
	{
		sprintf ( p,";%ld",modestr[i] ) ;
		p += strlen ( p ) ;
	}
	*p++ = 'm' ;
	*p = 0 ;
	raw_display ( attrstr ) ;
}

#endif /* ANSI_ESCAPE */

/*
**	MSDOS Signal Handling Routines.
*/

#ifdef	MSDOS

#include	<signal.h>

Void
msdos_signal_init ()
{
	signal ( SIGINT,signal_shit ) ;
	signal ( SIGTERM,signal_shit ) ;
}

Void
msdos_signal_quit ( sig_action )
int		sig_action ;
{
	Void	EXIT_IO () ;

	if ( sig_action & SH_IO )
		EXIT_IO () ;
	if ( sig_action & SH_CLOSE )
	{
		close_script () ;
		close_file () ;
		deallocate () ;
	}
	if ( sig_action & SH_COREDUMP )
		abort () ;
	exit () ;
}

#ifndef	MSC
#ifndef	TURBOC
#ifdef	ANSI_ESCAPE

/*
**	MSDOS ANSI_ESCAPE I/O Routines.
**
**	Only compiled if MSDOS and ANSI_ESCAPE are defined.
*/

Void
msdos_putchar ( c )
char	c ;
{
	extern boolean	enhanced ;
	extern boolean	enable_screen ;
	extern int		screen_width ;
	extern int		screen_height ;
	extern int		current_line ;
	extern boolean	windowing_enabled ;
	extern word		window_height ;
	extern word		top_screen_line ;

	union REGS		inregs ;

	switch ( c )
	{
		case 1:
				text_mode = NORMAL_MODE ;
				ansi_textattr ( vidc[text_mode] ) ;
				break ;
		case 2:
				text_mode |= INVERSE_MODE ;
				ansi_textattr ( vidc[text_mode] ) ;
				break ;
		case 3:
				text_mode |= BOLD_MODE ;
				ansi_textattr ( vidc[text_mode] ) ;
				break ;
		case 4:
				break ;
		case 5:
				text_mode |= UNDERLINE_MODE ;
				ansi_textattr ( vidc[text_mode] ) ;
				break ;
		case 0:
				c = ' ' ;

				/*
				**	Fall Through ...
				*/

		default:
				if ( enable_screen )
				{
					if ( c == '\n' )
					{
						if ( current_line == screen_height - 1 )
						{
							if ( enhanced )
							{
								if ( windowing_enabled == TRUE )
								{
									inregs.h.ah = 6 ;
									inregs.h.al = 1 ;
									inregs.h.bh = 7 ;
									inregs.h.ch = window_height + top_screen_line ;
									inregs.h.cl = 0 ;
									inregs.h.dh = screen_height - 1 ;
									inregs.h.dl = screen_width - 1 ;
									int86 ( 0x10,&inregs,&inregs ) ;
									GOTO_XY ( 0,screen_height - 1 ) ;
								}
								else
									putchar ( '\n' ) ;
							}
							else
								putchar ( '\n' ) ;
						}
						else
						{
							++current_line ;
							putchar ( '\n' ) ;
						}
					}
					else
						putchar ( c ) ;
				}
				break ;
	}
}

#endif	/* ANSI_ESCAPE */
#endif	/* TURBOC */
#endif	/* MSC */
#endif	/* MSDOS */

/*
**	ANSI_ESCAPE I/O Routines.
**
**	Only compiled if ANSI_ESCAPE is defined.
*/

#ifdef	ANSI_ESCAPE

int		current_line ;
int		saved_current_line ;

Void
ansi_init_io ()
{
	extern int	screen_height ;

	/*
	**	Initialise the "current_line" variable using a call to "GOTO_XY".
	*/

#ifdef UNIX
	unix_init_io();
#endif

	GOTO_XY ( 0,screen_height - 1 ) ;

	default_attrs () ;
	read_rcfile () ;

	ansi_textattr(vidc[NORMAL_MODE]);

	raw_display ( "\033[2J" ) ; /* clear screen */
}

Void
ansi_exit_io ()
{
	raw_display ( "\033[0m" ) ;

#ifdef UNIX
	unix_exit_io();
#endif
}

Void
ansi_putchar ( c )
char	c ;
{
	extern boolean	enhanced ;
	extern boolean	enable_screen ;
	extern int		screen_width ;
	extern int		screen_height ;
	extern int		current_line ;
	extern boolean	windowing_enabled ;
	extern word		window_height ;
	extern word		top_screen_line ;

	switch ( c )
	{
		case 1:
				text_mode = NORMAL_MODE ;
				ansi_textattr ( vidc[text_mode] ) ;
				break ;
		case 2:
				text_mode |= INVERSE_MODE ;
				ansi_textattr ( vidc[text_mode] ) ;
				break ;
		case 3:
				text_mode |= BOLD_MODE ;
				ansi_textattr ( vidc[text_mode] ) ;
				break ;
		case 4:
				break ;
		case 5:
				text_mode |= UNDERLINE_MODE ;
				ansi_textattr ( vidc[text_mode] ) ;
				break ;
		case 0:
				c = ' ' ;

				/*
				**	Fall Through ...
				*/

		default:
				if ( enable_screen )
				{
					if ( c == '\n' )
					{
						if ( current_line == screen_height - 1 )
						{
							if ( enhanced )
							{
								if ( windowing_enabled == TRUE )
								{
									GOTO_XY ( 0,window_height + top_screen_line ) ;
									raw_display ( "\033[1M" ) ;
									GOTO_XY ( 0,screen_height - 1 ) ;
								}
								else
									putchar ( '\n' ) ;
							}
							else
								putchar ( '\n' ) ;
						}
						else
						{
							++current_line ;
							putchar ( '\n' ) ;
						}
					}
					else
						putchar ( c ) ;
				}
				break ;
	}
}

Void
ansi_goto_xy ( x,y )
int		x,y ;
{
	extern int	current_line ;

	current_line = y ;
	++x ;
	++y ;
	raw_display ( "\033[" ) ;
	putchar ( (char)( y / 10 + '0' )) ;
	putchar ( (char)( y % 10 + '0' )) ;
	putchar ( ';' ) ;
	putchar ( (char)( x / 10 + '0' )) ;
	putchar ( (char)( x % 10 + '0' )) ;
	putchar ( 'H' ) ;
}

int
ansi_get_x ()
{
	return ( 0 ) ;
}

int
ansi_get_y ()
{
	extern int	current_line ;

	return ( current_line ) ;
}

/*
**	The Enhanced Windowing ANSI_ESCAPE I/O Functions.
*/

Void
ansi_erase_window ( top_of_window,bottom_of_window )
word	top_of_window ;
word	bottom_of_window ;
{
	extern int		screen_width ;
	extern word		top_screen_line ;

	/*
	**	Erase Screen from the line specified by "top_of_window"
	**	to the line ABOVE that specified by "bottom_of_window".
	**	Leave Cursor at the top, left-hand corner of the erased window.
	*/

#ifdef	SIMPLE_ANSI_ESCAPE

	word			i ;

	for ( i = bottom_of_window ; i > top_of_window ; i-- )
	{
		GOTO_XY ( 0,i-1 ) ;
		raw_display ( "\033[K" ) ;
	}

#else	/* SIMPLE_ANSI_ESCAPE */

	if ( top_of_window == top_screen_line )
	{
		GOTO_XY ( screen_width - 1,bottom_of_window - 1 ) ;
		raw_display ( "\033[1J" ) ;
		GOTO_XY ( 0,top_of_window ) ;
	}
	else
	{
		GOTO_XY ( 0,top_of_window ) ;
		raw_display ( "\033[0J" ) ;
	}

#endif	/* SIMPLE_ANSI_ESCAPE */
}

Void
ansi_save_cursor ()
{
	extern int	current_line ;
	extern int	saved_current_line ;

	saved_current_line = current_line ;
	if ( use_save_cursor )
		raw_display ( "\033[s" ) ;
}

Void
ansi_restore_cursor ()
{
	extern int	current_line ;
	extern int	saved_current_line ;

	current_line = saved_current_line ;
	if ( use_save_cursor )
		raw_display ( "\033[u" ) ;
	else
		GOTO_XY ( 0,current_line ) ;
}

/*
**	The PLUS Series ANSI_ESCAPE I/O Functions.
*/

Void
ansi_erase_to_eoln ()
{
	raw_display ( "\033[K" ) ;
}

#endif	/* ANSI_ESCAPE */

/*
**	UNIX I/O Routines.
**
**	Only compiled if UNIX is defined.
*/

#ifdef	UNIX

#ifdef	SYS_V
static struct termio	s ;
#endif	/* SYS_V */

#ifdef	BSD
static struct sgttyb	s ;
#endif	/* BSD */

#if defined(TIOCGWINSZ) && defined(SYS_V)
/* What??? TIOCGWINSZ in a System V box???  We better include the right files */
#include <sys/types.h>
#include <sys/stream.h>
#include <sys/ptem.h>
#endif

/* Sun window size ioctl supported */
/*ARGSUSED*/
static Void
signal_winch ( sig_action )
int		sig_action ;
{
	extern int	screen_height, screen_width ;

#if defined(TIOCGWINSZ)
	struct winsize	w ;

	if ( !ioctl ( fileno(stdin), TIOCGWINSZ, &w) )
	{
		screen_height = w.ws_row ;
		screen_width = w.ws_col ;
	}
#endif
}

Void
unix_init_io ()
{
	extern boolean	enhanced ;

#ifdef	SYS_V

	struct termio	t ;

	enhanced = TRUE ;
	ioctl ( fileno(stdin),TCGETA,&s ) ;
	ioctl ( fileno(stdin),TCGETA,&t ) ;
	t.c_iflag |= ICRNL ;
	t.c_lflag &= ~(ECHO | ICANON) ;
	t.c_cc[VMIN] = 1 ;
	t.c_cc[VTIME] = 0 ;
	ioctl ( fileno(stdin),TCSETA,&t ) ;
	setbuf(stdin, (char *)0);

#endif	/* SYS_V */

#ifdef	BSD

	struct sgttyb	t ;

	enhanced = TRUE ;
	ioctl ( fileno(stdin),TIOCGETP,&s ) ;
	ioctl ( fileno(stdin),TIOCGETP,&t ) ;
	t.sg_flags |= CBREAK ;
	t.sg_flags &= ~ECHO ;
	ioctl ( fileno(stdin),TIOCSETP,&t ) ;

#endif	/* BSD */

	signal_winch ( 0 ) ;
}

Void
unix_exit_io ()
{
#ifdef	SYS_V

	ioctl ( fileno(stdin),TCSETA,&s ) ;

#endif	/* SYS_V */

#ifdef	BSD

	ioctl ( fileno(stdin),TIOCSETP,&s ) ;

#endif	/* BSD */
}

/*
**	UNIX Signal Handling Routines.
*/

#include	<signal.h>

Void
unix_signal_init ()
{
	signal ( SIGHUP,signal_shit ) ;
	signal ( SIGINT,signal_shit ) ;
	signal ( SIGTERM,signal_shit ) ;
	signal ( SIGQUIT,signal_chit ) ;
#ifdef SIGWINCH
	signal ( SIGWINCH, signal_winch ) ;
#endif
}

Void
unix_signal_quit ( sig_action )
int		sig_action ;
{
	Void	EXIT_IO () ;

	if ( sig_action & SH_IO )
		EXIT_IO () ;
	if ( sig_action & SH_CLOSE )
	{
		close_script () ;
		close_file () ;
		deallocate () ;
	}
	if ( sig_action & SH_COREDUMP )
		abort () ;
	exit (1) ;
}

#endif	/* UNIX */

/*
**	TERMCAP I/O Routines.
**
**	Only compiled if TERMCAP is defined.
*/

#ifdef	TERMCAP

char		*CE ;				/* Cursor_Eoln      */
char		*CL ;				/* Clear_Screen     */
char		*CM ;				/* Cursor_Move      */
char		*DL ;				/* Delete_Line      */
char		*PDL ;				/* Parametised Delete_Line      */
char		*RC ;				/* Restore_Cursor   */
char		*SC ;				/* Save_Cursor      */
char		*SE ;				/* Stand_End        */
char		*SO ;				/* Stand_Out        */
char		*TE ;				/* Terminal_Exit    */
char		*TI ;				/* Terminal_Init    */
char		*UE ;				/* Underscore_End   */
char		*US ;				/* Underscore_Start */

char		cmdbuf[1024] ;
char		*cmd_p = cmdbuf ;
char		termbuf[1024] ;

char		*getenv() ;
char		*tgetstr() ;
char		*tgoto() ;

int			current_line ;
int			saved_current_line ;

Void
tcap_init_io ()
{
	extern int	screen_width ;
	extern int	screen_height ;

	char		*term ;

#ifdef	UNIX
	unix_init_io () ;
#endif	/* UNIX */

	cmd_p = cmdbuf ;
	if (((term = getenv("TERM")) == NULL) || tgetent( termbuf,term ) <= 0)
	{
		CE = CL = CM = DL = RC = SC = SE = SO = TE = TI = UE = US = "" ;
		return ;
	}

	if ((CE = tgetstr("ce", &cmd_p)) == NULL)
		CE = "" ;
	if ((CL = tgetstr("cl", &cmd_p)) == NULL)
		CL = "" ;
	if ((CM = tgetstr("cm", &cmd_p)) == NULL)
		CM = "" ;
	if ((DL = tgetstr("dl", &cmd_p)) == NULL)
		DL = "" ;
	if ((PDL = tgetstr("DL", &cmd_p)) == NULL)
		PDL = "" ;
	if
	(
		((RC = tgetstr("rc", &cmd_p)) == NULL)
		||
		((SC = tgetstr("sc", &cmd_p)) == NULL)
	)
		RC = SC = "" ;
	if
	(
		((SE = tgetstr("se", &cmd_p)) == NULL)
		||
		((SO = tgetstr("so", &cmd_p)) == NULL)
	)
		SE = SO = "" ;
	if
	(
		((TE = tgetstr("te", &cmd_p)) == NULL)
		||
		((TI = tgetstr("ti", &cmd_p)) == NULL)
	)
		TE = TI = "" ;
	if
	(
		((UE = tgetstr("ue", &cmd_p)) == NULL)
		||
		((US = tgetstr("us", &cmd_p)) == NULL)
	)
		UE = US = "" ;

	if ((screen_width = tgetnum("co")) == -1)
		screen_width = SCREEN_WIDTH ;
	if ((screen_height = tgetnum("li")) == -1)
		screen_height = SCREEN_HEIGHT ;

	tputs ( TI,0,out_char ) ;
	tputs ( CL,0,out_char ) ;
	GOTO_XY ( 0,screen_height-1 ) ;
}

Void
tcap_exit_io ()
{
	/*
	**	Turn off any modes before quitting.
	*/

	if ( text_mode & INVERSE_MODE )
		tputs ( SE,0,out_char ) ;
	if ( text_mode & UNDERLINE_MODE )
		tputs ( UE,0,out_char ) ;

	tputs ( TE,0,out_char ) ;

#ifdef	UNIX
	unix_exit_io () ;
#endif	/* UNIX */
}

Void
tcap_putchar ( c )
char	c ;
{
	extern boolean	enhanced ;
	extern boolean	enable_screen ;
	extern int		screen_height ;
	extern int		current_line ;
	extern boolean	windowing_enabled ;
	extern word		window_height ;
	extern word		top_screen_line ;

	switch ( c )
	{
		case 1:
				text_mode = NORMAL_MODE ;
				tputs ( UE,0,out_char ) ;
				tputs ( SE,0,out_char ) ;
				break ;
		case 2:
				text_mode |= INVERSE_MODE ;
				tputs ( SO,0,out_char ) ;
				break ;
		case 3:
				/*
				**	TERMCAP doesn't support Bold Text Modes.
				*/

				text_mode |= BOLD_MODE ;
				break ;
		case 4:
				break ;
		case 5:
				text_mode |= UNDERLINE_MODE ;
				tputs ( US,0,out_char ) ;
				break ;
		case 0:
				c = ' ' ;

				/*
				**	Fall Through ...
				*/

		default:
				if ( enable_screen )
				{
					if ( c == '\n' )
					{
						/*
						**	Turn off any modes before printing a '\n'.
						*/

						if ( text_mode & INVERSE_MODE )
							tputs ( SE,0,out_char ) ;
						if ( text_mode & UNDERLINE_MODE )
							tputs ( UE,0,out_char ) ;

						if ( current_line == screen_height - 1 )
						{
							if ( enhanced )
							{
								if ( windowing_enabled == TRUE )
								{
									GOTO_XY ( 0,window_height + top_screen_line ) ;
									if ( DL )
										tputs ( DL,0,out_char ) ;
									else if ( PDL )
										tputs ( PDL,1,out_char ) ;
									GOTO_XY ( 0,screen_height - 1 ) ;
								}
								else
									putchar ( '\n' ) ;
							}
							else
								putchar ( '\n' ) ;
						}
						else
						{
							++current_line ;
							putchar ( '\n' ) ;
						}

						/*
						**	Restore modes.
						*/

						if ( text_mode & INVERSE_MODE )
							tputs ( SO,0,out_char ) ;
						if ( text_mode & UNDERLINE_MODE )
							tputs ( US,0,out_char ) ;
					}
					else
						putchar ( c ) ;
				}
				break ;
	}
}

Void
tcap_goto_xy ( x,y )
int		x,y ;
{
	extern int	current_line ;

	/*
	**	Turn off any modes before moving the cursor.
	*/

	if ( text_mode & INVERSE_MODE )
		tputs ( SE,0,out_char ) ;
	if ( text_mode & UNDERLINE_MODE )
		tputs ( UE,0,out_char ) ;

	/*
	**	Move the cursor.
	*/

	current_line = y ;
	tputs ( tgoto ( CM,x,y ),0,out_char ) ;

	/*
	**	Restore modes.
	*/

	if ( text_mode & INVERSE_MODE )
		tputs ( SO,0,out_char ) ;
	if ( text_mode & UNDERLINE_MODE )
		tputs ( US,0,out_char ) ;
}

int
tcap_get_x ()
{
	return ( 0 ) ;
}

int
tcap_get_y ()
{
	extern int	current_line ;

	return ( current_line ) ;
}

/*
**	The Enhanced Windowing TERMCAP I/O Functions.
*/

Void
tcap_erase_window ( top_of_window,bottom_of_window )
word	top_of_window ;
word	bottom_of_window ;
{
	extern int	screen_width ;

	int			i ;

	/*
	**	Erase Screen from the line specified by "top_of_window"
	**	to the line ABOVE that specified by "bottom_of_window".
	**	Leave Cursor at the top, left-hand corner of the erased window.
	*/

	for ( i = (int)top_of_window ; i < (int)bottom_of_window ; i++ )
	{
		GOTO_XY ( 0,i ) ;
		tcap_erase_to_eoln () ;
	}
	GOTO_XY ( 0,top_of_window ) ;
}

Void
tcap_save_cursor ()
{
	extern int	current_line ;
	extern int	saved_current_line ;

	/*
	**	Turn off any modes before moving the cursor.
	*/

	if ( text_mode & INVERSE_MODE )
		tputs ( SE,0,out_char ) ;
	if ( text_mode & UNDERLINE_MODE )
		tputs ( UE,0,out_char ) ;

	/*
	**	Save the cursor.
	*/

	saved_current_line = current_line ;
	if ( *SC )
		tputs ( SC,0,out_char ) ;

	/*
	**	Restore modes.
	*/

	if ( text_mode & INVERSE_MODE )
		tputs ( SO,0,out_char ) ;
	if ( text_mode & UNDERLINE_MODE )
		tputs ( US,0,out_char ) ;
}

Void
tcap_restore_cursor ()
{
	extern int	current_line ;
	extern int	saved_current_line ;

	/*
	**	Turn off any modes before moving the cursor.
	*/

	if ( text_mode & INVERSE_MODE )
		tputs ( SE,0,out_char ) ;
	if ( text_mode & UNDERLINE_MODE )
		tputs ( UE,0,out_char ) ;

	/*
	**	Restore the cursor.
	*/

	current_line = saved_current_line ;
	if ( *RC )
		tputs ( RC,0,out_char ) ;
	else
		GOTO_XY ( 0,current_line ) ;

	/*
	**	Restore modes.
	*/

	if ( text_mode & INVERSE_MODE )
		tputs ( SO,0,out_char ) ;
	if ( text_mode & UNDERLINE_MODE )
		tputs ( US,0,out_char ) ;
}

/*
**	The PLUS Series TERMCAP I/O Functions.
*/

Void
tcap_erase_to_eoln ()
{
	/*
	**	The characters at the cursor and to the right are erased.
	**	The cursor itself is not moved.
	*/

	/*
	**	Turn off any modes before moving the cursor.
	*/

	if ( text_mode & INVERSE_MODE )
		tputs ( SE,0,out_char ) ;
	if ( text_mode & UNDERLINE_MODE )
		tputs ( UE,0,out_char ) ;

	/*
	**	Erase the line.
	*/

	tputs ( CE,0,out_char ) ;

	/*
	**	Restore modes.
	*/

	if ( text_mode & INVERSE_MODE )
		tputs ( SO,0,out_char ) ;
	if ( text_mode & UNDERLINE_MODE )
		tputs ( US,0,out_char ) ;
}

#endif	/* TERMCAP */

/*
**	TERMINFO I/O Routines.
**
**	Only compiled if TERMINFO is defined.
*/

#ifdef	TERMINFO

int			current_col ;
int			current_line ;
int			saved_current_col ;
int			saved_current_line ;
chtype		cur_attrs = A_NORMAL ;

#if defined(__STDC__)
#define	OUT_CHAR	(int (*)(char))out_char
#else
#define	OUT_CHAR	out_char
#endif

Void
tinfo_init_io ()
{
	extern int	screen_width ;
	extern int	screen_height ;
	Void		GOTO_XY () ;

	setupterm ((char *)0,1,(int *)0) ;

	screen_width = columns ;
	screen_height = lines ;

	putp ( enter_ca_mode ) ;
	putp ( clear_screen ) ;
	GOTO_XY ( 0,screen_height-1 ) ;
	vidattr ( cur_attrs = A_NORMAL ) ;

#ifdef	UNIX
	unix_init_io () ;
#endif	/* UNIX */
}

Void
tinfo_exit_io ()
{
	/*
	**	Turn off any modes before quitting.
	*/

#ifdef	UNIX
	unix_exit_io () ;
#endif	/* UNIX */

	vidputs ( cur_attrs = A_NORMAL,OUT_CHAR ) ;
	tputs ( exit_ca_mode,1,OUT_CHAR ) ;

	reset_shell_mode () ;
}

Void
tinfo_putchar ( c )
char	c ;
{
	extern boolean	enhanced ;
	extern boolean	enable_screen ;
	extern int		screen_height ;
	extern int		current_line ;
	extern boolean	windowing_enabled ;
	extern word		window_height ;
	extern word		top_screen_line ;
	Void			GOTO_XY () ;

	switch ( c )
	{
		case 1:
				vidputs ( cur_attrs = A_NORMAL,OUT_CHAR );
				break ;
		case 2:
				if ( enter_reverse_mode )
					vidputs ( cur_attrs |= A_REVERSE,OUT_CHAR );
				break ;
		case 3:
				if ( enter_bold_mode )
					vidputs ( cur_attrs |= A_BOLD,OUT_CHAR );
				break ;
		case 4:
				break ;
		case 5:
				if ( enter_underline_mode )
					vidputs ( cur_attrs |= A_UNDERLINE,OUT_CHAR );
				break ;
		case 0:
				c = ' ' ;

				/*
				**	Fall Through ...
				*/

		default:
				if ( enable_screen )
				{
					if ( c == '\n' )
					{
						/*
						**	Turn off any modes before printing a '\n'.
						*/

						vidputs ( A_NORMAL,OUT_CHAR ) ;

						if ( current_line == screen_height - 1 )
						{
							if ( enhanced )
							{
								if ( windowing_enabled == TRUE )
								{
									GOTO_XY ( 0,window_height + top_screen_line ) ;
									if ( delete_line )
										tputs ( delete_line,1,OUT_CHAR ) ;
									else if ( parm_delete_line )
										tputs ( tparm ( parm_delete_line,1 ),1,OUT_CHAR ) ;
									GOTO_XY ( 0,screen_height - 1 ) ;
								}
								else
									putchar ( '\n' ) ;
							}
							else
								putchar ( '\n' ) ;
						}
						else
						{
							++current_line ;
							putchar ( '\r' ) ;
							putchar ( '\n' ) ;
						}

						current_col = 0 ;

						/*
						**	Restore modes.
						*/

						vidputs ( cur_attrs,OUT_CHAR ) ;
					}
					else
					{
						putchar ( c ) ;
						++current_col ;
					}
				}
				break ;
	}
}

Void
tinfo_goto_xy ( x,y )
int		x,y ;
{
	extern int	current_line ;

	/*
	**	Turn off any modes before moving the cursor.
	*/

	vidputs ( A_NORMAL,OUT_CHAR ) ;

	/*
	**	Move the cursor.
	*/

	current_col = x ;
	current_line = y ;
	tputs ( tparm ( cursor_address,y,x ),0,OUT_CHAR ) ;

	/*
	**	Restore modes.
	*/

	vidputs ( cur_attrs,OUT_CHAR ) ;
}

int
tinfo_get_x ()
{
	extern int	current_col ;

	return ( 0 ) ;
}

int
tinfo_get_y ()
{
	extern int	current_line ;

	return ( current_line ) ;
}

/*
**	The Enhanced Windowing TERMCAP I/O Functions.
*/

Void
tinfo_erase_window ( top_of_window,bottom_of_window )
word	top_of_window ;
word	bottom_of_window ;
{
	Void		tinfo_erase_to_eoln () ;
	extern int	screen_width ;

	int			i ;

	/*
	**	Erase Screen from the line specified by "top_of_window"
	**	to the line ABOVE that specified by "bottom_of_window".
	**	Leave Cursor at the top, left-hand corner of the erased window.
	*/

	for ( i = (int)top_of_window ; i < (int)bottom_of_window ; i++ )
	{
		GOTO_XY ( 0,i ) ;
		tinfo_erase_to_eoln () ;
	}
	GOTO_XY ( 0,top_of_window ) ;
}

Void
tinfo_save_cursor ()
{
	extern int	current_col ;
	extern int	current_line ;
	extern int	saved_current_col ;
	extern int	saved_current_line ;

	/*
	**	Turn off any modes before moving the cursor.
	*/

	vidputs ( A_NORMAL,OUT_CHAR ) ;

	/*
	**	Save the cursor.
	*/

	saved_current_col = current_col ;
	saved_current_line = current_line ;
	if ( save_cursor )
		tputs ( save_cursor,0,OUT_CHAR ) ;

	/*
	**	Restore modes.
	*/

	vidputs ( cur_attrs,OUT_CHAR ) ;
}

Void
tinfo_restore_cursor ()
{
	extern int	current_col ;
	extern int	current_line ;
	extern int	saved_current_col ;
	extern int	saved_current_line ;

	/*
	**	Turn off any modes before moving the cursor.
	*/

	vidputs ( A_NORMAL,OUT_CHAR ) ;

	/*
	**	Restore the cursor.
	*/

	current_col = saved_current_col ;
	current_line = saved_current_line ;
	if ( restore_cursor )
		tputs ( restore_cursor,0,OUT_CHAR ) ;
	else
		GOTO_XY ( 0,current_line ) ;

	/*
	**	Restore modes.
	*/

	vidputs ( cur_attrs,OUT_CHAR ) ;
}

/*
**	The PLUS Series TERMCAP I/O Functions.
*/

Void
tinfo_erase_to_eoln ()
{
	/*
	**	The characters at the cursor and to the right are erased.
	**	The cursor itself is not moved.
	*/

	/*
	**	Turn off any modes before moving the cursor.
	*/

	vidputs ( A_NORMAL,OUT_CHAR ) ;

	/*
	**	Erase the line.
	*/

	tputs ( clr_eol,1,OUT_CHAR ) ;

	/*
	**	Restore modes.
	*/

	vidputs ( cur_attrs,OUT_CHAR ) ;
}

#endif	/* TERMINFO */

/*
**	CURSES I/O Routines.
**
**	Only compiled if CURSES is defined.
*/

#ifdef	CURSES

#ifndef BSD

static long	vida[8] ;

static Void
curses_init_attrs ()
{
	int		i,j,n ;

	for ( i = 0 ; i < 8 ; i++ )
	{
		short	fg = -1, bg = -1;

		vida[i] = A_NORMAL ;

		for ( n = vidc[i][0], j = 1 ; j <= n ; j++ )
		{
			long	mode = vidc[i][j] ;

			switch ( mode )
			{
			case	A_STANDOUT:
			case	A_UNDERLINE:
			case	A_REVERSE:
			case	A_BLINK:
			case	A_DIM:
			case	A_BOLD:
					vida[i] |= mode ;
					break ;

			case	A_NORMAL:
					vida[i] = A_NORMAL ;
					break ;
			}

#ifdef WANT_COLOR
			if ( mode < A_BGOFFSET && mode >= A_FGOFFSET )
				fg = mode - A_FGOFFSET;

			if ( mode <= A_CHARTEXT && mode >= A_BGOFFSET )
				bg = mode - A_BGOFFSET;

			if ( fg >= 0 && bg >= 0 && has_colors () && i < COLOR_PAIRS )
			{
				init_pair ( i + 1,fg,bg ) ;
				vida[i] |= COLOR_PAIR ( i + 1 ) ;
			}
#endif
		}
	}
}

#endif

Void
curses_init_io ()
{
	extern boolean	enhanced ;
	extern int		screen_width ;
	extern int		screen_height ;

	/*
	**	If CURSES is being used, then "enhanced" should be TRUE.
	*/

	default_attrs () ;
	read_rcfile () ;
	enhanced = TRUE ;
	initscr () ;

#ifdef WANT_COLOR
	start_color () ;
#endif

	screen_width = COLS ;
	screen_height = LINES ;
	nonl () ;
#if defined(cbreak)
	cbreak () ;
#else
#if defined(crmode)
	crmode () ;
#else
	@@@ I need either cbreak() or crmode() defined!!! @@@
#endif
#endif
	noecho () ;
	scrollok ( stdscr,1 ) ;
	scrollok ( curscr,1 ) ;
	idlok ( stdscr,1 ) ;
	idlok ( curscr,1 ) ;
	GOTO_XY ( 0,screen_height-1 ) ;

#ifdef SYS_V
	curses_init_attrs () ;
	attrset ( vida[text_mode = NORMAL_MODE] ) ;
#endif

}

Void
curses_exit_io ()
{
#ifdef SYS_V
	attrset ( A_NORMAL ) ;
#endif
	addch ( '\n' ) ;
	refresh () ;
	echo () ;
#if defined(nocbreak)
	nocbreak () ;
#else
#if defined(nocrmode)
	nocrmode () ;
#else
	@@@ I need either nocbreak() or nocrmode() defined!!! @@@
#endif
#endif
	nl () ;
	endwin () ;
}

Void
curses_putchar ( c )
char	c ;
{
	extern boolean	enable_screen ;
	extern int		screen_height ;
	extern boolean	windowing_enabled ;
	extern word		window_height ;
	extern word		top_screen_line ;

	switch ( c )
	{
#ifdef	SYS_V
		case 1:
				text_mode = NORMAL_MODE ;
				attrset ( vida[text_mode] ) ;
				break ;
		case 2:
				text_mode |= INVERSE_MODE ;
				attrset ( vida[text_mode] ) ;
				break ;
		case 3:
				text_mode |= BOLD_MODE ;
				attrset ( vida[text_mode] ) ;
				break ;
		case 4:
				break ;
		case 5:
				text_mode |= UNDERLINE_MODE ;
				attrset ( vida[text_mode] ) ;
				break ;
#endif	/* SYS_V */
#ifdef	BSD
		case 1:
				standend () ;
				break ;
		case 2:
				standout () ;
				break ;
		case 3:
				standout () ;
				break ;
		case 4:
				break ;
		case 5:
				standout () ;
				break ;
#endif	/* BSD */
		case 0:
				c = ' ' ;

				/*
				**	Fall Through ...
				*/

		default:
				if ( enable_screen )
				{
					if ( c == '\n' )
					{
						if ( GET_Y () == screen_height - 1 )
						{
							if ( windowing_enabled == TRUE )
							{
								GOTO_XY ( 0,window_height + top_screen_line ) ;
								deleteln () ;
								GOTO_XY ( 0,screen_height - 1 ) ;
							}
							else
								addch ( '\n' ) ;
						}
						else
							addch ( '\n' ) ;
					}
					else
						addch ( c ) ;
				}
				break ;
	}
}

Void
curses_goto_xy ( x,y )
int		x,y ;
{
	move ( y,x ) ;
}

int
curses_get_x ()
{
	int		x ;
	int		y ;

	/*
	**	"getyx ()" is a MACRO which returns integers in "x" and "y".
	**	Note that "x" and "y" are used here, not "&x" and "&y" as expected
	**	for variables being returned.
	*/

	getyx ( stdscr,y,x ) ;
	return ( x ) ;
}

int
curses_get_y ()
{
	int		x ;
	int		y ;

	/*
	**	"getyx ()" is a MACRO which returns integers in "x" and "y".
	**	Note that "x" and "y" are used here, not "&x" and "&y" as expected
	**	for variables being returned.
	*/

	getyx ( stdscr,y,x ) ;
	return ( y ) ;
}

/*
**	The Enhanced Windowing CURSES I/O Functions.
*/

Void
curses_erase_window ( top_of_window,bottom_of_window )
word	top_of_window ;
word	bottom_of_window ;
{
	extern int	screen_width ;

	int			i ;

	/*
	**	Erase Screen from the line specified by "top_of_window"
	**	to the line ABOVE that specified by "bottom_of_window".
	**	Leave Cursor at the top, left-hand corner of the erased window.
	*/

	for ( i = (int)top_of_window ; i < (int)bottom_of_window ; i++ )
	{
		GOTO_XY ( 0,i ) ;
		clrtoeol () ;
	}
	GOTO_XY ( 0,top_of_window ) ;
}

int
curses_get_ch ()
{
	refresh () ;
	return ( getch () ) ;
}

/*
**	The PLUS Series CURSES I/O Functions.
*/

Void
curses_erase_to_eoln ()
{
	/*
	**	The characters at the cursor and to the right are erased.
	**	The cursor itself is not moved.
	*/

	clrtoeol () ;
}

#endif	/* CURSES */

/*
**	THINK C Version 4.0 I/O Routines.
**
**	Only compiled if THINKC is defined.
*/

#ifdef	THINKC

#undef		main

void
main ( argc,argv )
int		argc ;
char	*argv[] ;
{
	argc = ccommand ( &argv ) ;
	_main ( argc,argv ) ;
}

#undef		FALSE
#undef		TRUE
#include	<Quickdraw.h>
#define		FALSE		(0)
#define		TRUE		(!FALSE)

FILE		*console ;
FontInfo	fi ;
Rect		full_screen ;
int			line_height ;

Void
thinkc_init_io ()
{
	extern FILE			*console ;
	extern FontInfo		fi ;
	extern Rect			full_screen ;
	extern int			line_height ;
	extern word			top_screen_line ;

	if (( console = fopenc () ) == (FILE *)0 )
		exit ( 1 ) ;
	GetFontInfo ( &fi ) ;
	line_height = fi.ascent + fi.descent + fi.leading ;
	thePort -> portRect.top += top_screen_line * line_height ;
	full_screen = thePort -> portRect ;
}

Void
thinkc_exit_io ()
{
	extern FILE			*console ;

	fclose ( console ) ;
}

#define		CHAR_OFFSET		1

Void
thinkc_putchar ( c )
char	c ;
{
	extern FontInfo	fi ;
	extern boolean	enable_screen ;
	extern word		text_mode ;

	Point			pn_loc ;
	RgnHandle		update ;
	Rect			r ;

	switch ( c )
	{
		case 1:
				text_mode = NORMAL_MODE ;
				break ;
		case 2:
				text_mode |= INVERSE_MODE ;
				break ;
		case 3:
				text_mode |= BOLD_MODE ;
				break ;
		case 4:
				break ;
		case 5:
				text_mode |= UNDERLINE_MODE ;
				break ;
		case 0:
				c = ' ' ;

				/*
				**	Fall Through ...
				*/

		default:
				if ( enable_screen )
				{
					GetPen ( &pn_loc ) ;
					SetRect ( &r,pn_loc.h-CHAR_OFFSET,pn_loc.v-fi.ascent,pn_loc.h+fi.widMax,pn_loc.v+fi.descent ) ;
					EraseRect ( &r ) ;
					if ( text_mode & BOLD_MODE )
					{
						TextFace ( bold ) ;
						putchar ( c ) ;
						TextFace ( 0 ) ;
						update = NewRgn () ;
						ScrollRect ( &r,-CHAR_OFFSET,0,update ) ;
						DisposeRgn ( update ) ;
						GOTO_XY ( GET_X (),GET_Y () ) ;
					}
					else
						putchar ( c ) ;
					if ( text_mode & UNDERLINE_MODE )
					{
						MoveTo ( pn_loc.h-CHAR_OFFSET,pn_loc.v+fi.descent-1 ) ;
						LineTo ( pn_loc.h+fi.widMax,pn_loc.v+fi.descent-1 ) ;
						GOTO_XY ( GET_X (),GET_Y () ) ;
					}
					if ( text_mode & INVERSE_MODE )
						InvertRect ( &r ) ;
				}
				break ;
	}
}

Void
thinkc_goto_xy ( x,y )
int		x ;
int		y ;
{
	extern FILE		*console ;

	cgotoxy ( x,y,console ) ;
}

int
thinkc_get_x ()
{
	extern FILE		*console ;

	int				x ;
	int				y ;

	cgetxy ( &x,&y,console ) ;
	return ( x ) ;
}

int
thinkc_get_y ()
{
	extern FILE		*console ;

	int				x ;
	int				y ;

	cgetxy ( &x,&y,console ) ;
	return ( y ) ;
}

/*
**	The Enhanced Windowing THINK C I/O Functions.
*/

Void
thinkc_use_window ( the_window )
word	the_window ;
{
	extern word		window_height ;
	extern Rect		full_screen ;
	extern int		line_height ;

	switch ( the_window )
	{
		case WINDOW_0:
						/*
						**	Use the Lower Window.
						*/
						
						thePort -> portRect.top = full_screen.top + window_height * line_height ;
						thePort -> portRect.bottom = full_screen.bottom ;
						break ;
		case WINDOW_1:
						/*
						**	Use the Upper Window.
						*/
						
						thePort -> portRect.top = full_screen.top ;
						thePort -> portRect.bottom = full_screen.top + window_height * line_height ;
						break ;
		case FULL_SCREEN:
						/*
						**	Use the entire Screen.
						*/
						
						thePort -> portRect.top = full_screen.top ;
						thePort -> portRect.bottom = full_screen.bottom ;
						break ;
	}
}

#define		_CONTROLWIDTH	15		/* Width of Scroll Bar */
#define		_LEFTEDGE		4		/* Margins             */
#define		_TOPEDGE		4

Void
thinkc_erase_window ( top_of_window,bottom_of_window )
word	top_of_window ;
word	bottom_of_window ;
{
	extern FILE		*console ;
	extern Rect		full_screen ;
	extern int		line_height ;
	extern int		screen_height ;
	extern word		top_screen_line ;
	
	Rect			r ;

	/*
	**	The problem with using Lightspeed C stdio is that when erasing
	**	the console window, its text buffer should also be cleared. Since
	**	this is quite tricky, we fudge it by calling "ccleos ()"
	**	when clearing the whole screen. When the screen is only partially
	**	cleared, we do not clear those lines from the console window's
	**	screen buffer ... this may sometimes cause problems !!!
	*/
			
	if	(
			( top_of_window == top_screen_line )
			&&
			( bottom_of_window == (word)screen_height )
		)
	{
		ccleos ( console ) ;
	}
	else
	{
		r.bottom = full_screen.top + bottom_of_window * line_height ;
		r.top = full_screen.top + _TOPEDGE + ( top_of_window - top_screen_line ) * line_height ;
		r.left = full_screen.left + _LEFTEDGE ;
		r.right = full_screen.right - _CONTROLWIDTH ;
		EraseRect ( &r ) ;
	}
}

/*
**	The PLUS Series THINK C I/O Functions.
*/

Void
thinkc_erase_to_eoln ()
{
	extern FILE		*console ;

	/*
	**	The characters at the cursor and to the right are erased.
	**	The cursor itself is not moved.
	*/

	ccleol ( console ) ;
}

#endif	/* THINKC */


#include "atari_io.c"      /* Definitions for Atari ST. */

