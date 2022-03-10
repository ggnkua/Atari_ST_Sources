#ifdef SOZOBON
#ifdef VT52

/* Private variables. */

int first_line ;	/* First line used for normal text (not statusline). */
int last_line ; 	/* Last line used for normal text. */
int cursor_x ;		/* Current row (line) of cursor. */
int cursor_y ;		/* Current column of cursor. */

boolean reverse_text = FALSE ;	/* Currently reverse text is off. */

#define ESC 	(char) 27

/*
**	I/O routines for Atari ST, using VT52 codes.
*/

Void
vt52_init_io ()
{
	extern int		screen_height ;
	extern int		screen_width ;
	extern int		top_screen_line ;
	extern boolean	enhanced ;

	int 	i;

	/*
	**	Initialization.
	*/

	enhanced = TRUE;	/* Meaning: This is not just a dumb terminal (no auto-
						 * matic echo, <return> can be '\r' not '\n', windowing
						 * is possible).
						 */

	default_attrs () ;
	read_rcfile () ;

	putchar(ESC); putchar('w'); 		/* Wrap off. */
	putchar(ESC); putchar('f'); 		/* Cursor off. */
	putchar(ESC); putchar('E'); 		/* Clear screen. */
	/* Write a black line (status line) at the top of the screen. */
	GOTO_XY(0,0);
	putchar(ESC); putchar('p'); 		/* Reverse on. */
	for (i = 0; i < screen_width; i++)
		putchar(' ');
	putchar(ESC); putchar('q'); 		/* Reverse off. */

	first_line = top_screen_line ;
	last_line = screen_height - 1 ; 	/* Numbering begins with 0. */
	GOTO_XY ( 0, last_line ) ;
}

Void
vt52_exit_io ()
{
	extern boolean	page_out ;

	/*
	**	Clean up.
	*/

	GOTO_XY ( 0, last_line ) ;
	putchar(ESC); putchar('v'); 	/* Wrap on. */
	putchar(ESC); putchar('e'); 	/* Cursor on. */
	/* If inverse text is on turn it off. */
	if (reverse_text)
	{
		putchar(ESC); putchar('q');
		reverse_text = TRUE;
	}

	if ( !page_out )
	{
		/* Output is formatted with [MORE] after each full page. This shows
		 * that the game is run interactively (not with input from a file).
		 * It is definitely the possibility that the game is run from the
		 * desktop, so many users will be happy that the game waits until
		 * it exits.
		 */
		printf( "(Press any key to exit)" );
		getch();
		printf( "\n" );
	}
}

Void
vt52_putchar ( c )
char	c ;
{
	extern boolean	enable_screen ;

	switch ( c )
	{
		case 1:
			/*
			**	Set Normal Text Mode.
			*/

			/* If inverse text is on turn it off. */
			if (reverse_text)
			{
				putchar(ESC); putchar('q');
				reverse_text = TRUE;
			}
			break;

		case 2:
			/*
			**	Set Inverse Text Mode.
			*/

			putchar(ESC); putchar('p');
			reverse_text = TRUE;
			break;

		case 3:
			/*
			**	Set Bold Text Mode.
			*/

			/* Unfortunately, I don't know how... */
			break;

		case 4:
			/*
			**	Unused.
			*/

			break;

		case 5:
			/*
			**	Set Underline Text Mode.
			*/

			/* Unfortunately, I don't know how... */
			break;

		case '\n':
			/*
			**	Newline.
			*/

			if ( !enable_screen )
				break;

			/* If current line is the last used, scroll text but not
			   status line.
			*/
			if (cursor_y == last_line)
			{
				GOTO_XY(0, first_line);
				putchar(ESC); putchar('M'); 	/* Delete line. */
				GOTO_XY(0, last_line);
				putchar(ESC); putchar('L'); 	/* Insert line. */
			}
			else
			{
				putchar(c);
				cursor_y++ ;
				cursor_x = 0;
			}
			break;

		case '\b':
			/*
			**	Backspace
			*/

			if ( enable_screen && (cursor_x > 0) )
			{
				/* Go back, delete the letter, and go back again. */
				printf("\b \b");
				cursor_x-- ;
			}
			break;

		case '\t':
			/*
			**	Tab
			*/

			if ( enable_screen )
			{
				int 	n;
				int 	i;

				n = 8 - (GET_X() % 8);
				for ( i = 0 ; i < n ; i++ )
					putchar(' ');
				cursor_x = cursor_x + n;
			}
			break;

		case 0:
			c = ' ';

			/*
			**	Fall through ...
			*/

		default:
			if ( enable_screen )
			{
				putchar ( c ) ;
				cursor_x++ ;
			}
			break;
	}
}

Void
vt52_goto_xy ( x,y )
int 	x,y ;
{
	/*
	**	Move the cursor to (x,y) ...
	**	The top-left corner of the screen has coordinates (0,0).
	*/

	putchar(ESC);
	putchar('Y');
	putchar( (char)(y+32) );
	putchar( (char)(x+32) );
	cursor_x = x;
	cursor_y = y;
}

int
vt52_get_x ()
{
	/*
	**	The left-most character position is position 0.
	*/

	return (cursor_x);
}

int
vt52_get_y ()
{
	/*
	**	The top screen line is 0.
	*/

	return (cursor_y);
}

/*
**	The Enhanced Windowing I/O Functions.
*/

Void
vt52_use_window ( the_window )
word	the_window;
{
	extern int	screen_height;
	extern int	window_height;
	extern int	top_screen_line;

	/* There is no description of the variable 'window_height', but it
	** it seems that 'top_screen_line + window_height' gives the first
	** line of the lower window. The upper window must then be from
	** 'top_screen_line' to 'top_screen_line + window_height - 1'.
	*/

	switch ( the_window )
	{
		case WINDOW_0:
			/*
			**	Use the Lower Window ...
			*/

			first_line = top_screen_line + window_height;
			last_line = screen_height - 1;

			break;
		case WINDOW_1:
			/*
			**	Use the Upper Window ...
			*/

			first_line = top_screen_line;
			last_line = top_screen_line + window_height - 1;

			break;
		case FULL_SCREEN:
			/*
			**	Use the entire screen ...
			*/

			first_line = top_screen_line;
			last_line = screen_height - 1;

			break;
	}
}

Void
vt52_erase_window ( top_of_window, bottom_of_window )
word	top_of_window;
word	bottom_of_window;
{
	/*
	**	Erase screen from the line specified by "top_of_window"
	**	to the line ABOVE that specified by "bottom_of_window".
	**	Leave cursor at the top, left-hand corner of the erased window.
	**	The top screen line is line 0.
	*/

	word	i;

	for ( i = bottom_of_window ; i > top_of_window ; i-- )
	{
		GOTO_XY (0, i-1);
		putchar(ESC); putchar('l'); 	/* Clear line. */
	}
	GOTO_XY (0, top_of_window);
}

/*
**	The Plus Series I/O Functions.
*/

Void
vt52_erase_to_eoln ()
{
	/*
	**	The characters at the cursor and to the right are erased.
	**	The cursor itself is not moved.
	*/

	putchar(ESC); putchar('K'); 	/* Clear to EOL. */
}

int
vt52_kbd_hit ()
{
	return ( kbhit() );
}

int
vt52_get_ch ()
{
	int c;

	putchar(ESC); putchar('e'); 		/* Cursor on. */
	c = getch();
	putchar(ESC); putchar('f'); 		/* Cursor off. */

	/* Conversion of special characters as suggested in read_the_key() */
	switch( c )
	{
		case 127:
			c = '\b';		/* Delete  ->  backspace */
			break;
		case 200:
			c = 0x08;		/* Up-arrow  ->  tab */
			break;
		case 203:
			c = '\b';		/* Left-arrow  ->  backspace */
			break;
		case 205:
			c = 0x07;		/* Right-arrow	->	bell */
			break;
		case 208:
			c = '\r';		/* Down-arrow  ->  return */
			break;
		default:
			/* No change. */
			break;
	}

	return ( c );
}

#endif VT52
#endif SOZOBON

