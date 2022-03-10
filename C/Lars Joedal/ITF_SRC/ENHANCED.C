/*
**	File:	enhanced.c
**
**	(C)opyright 1987-1992 InfoTaskforce.
*/

#include	<stdio.h>
#include	"infocom.h"

/*
**	Enhanced Windowing and Screen Printing Functions.
*/

Void
set_current_window ( the_window )
word	the_window ;
{
	extern header	data_head ;
	extern word		top_screen_line ;
	extern word		current_window ;
	extern boolean	disable_script ;

	if ( data_head.z_code_version >= VERSION_5 )
		flush_prt_buff () ;
	current_window = the_window ;
	if ( the_window != 0 )
	{
		/*
		**	Use the Upper Window.
		*/
		
		USE_WINDOW ( WINDOW_1 ) ;
		disable_script = TRUE ;
		save_cursor_position () ;

		/*
		**	Move the cursor to the top left-hand corner of the screen.
		*/

		GOTO_XY ( 0,top_screen_line ) ;
	}
	else
	{
		/*
		**	Use the Lower Window.
		*/
		
		USE_WINDOW ( WINDOW_0 ) ;
		disable_script = FALSE ;
		restore_cursor_position () ;

		/*
		**	Turn off all text attributes.
		**
		**	Prior to VERSION_4, the "set_text_mode ()" function
		**	did not exist. In VERSION_3 of the interpreter the
		**	statement:
		**							print_char ( (word)1 ) ;
		**	was used instead of:
		**							set_text_mode ( (word)0 ) ;
		*/

		set_text_mode ( (word)0 ) ;
	}
}

Void
split_screen ( param )
word	param ;
{
	extern header	data_head ;
	extern boolean	windowing_enabled ;
	extern word		top_screen_line ;
	extern word		window_height ;
	extern int		screen_height ;
	extern int		linecount ;
	
	if ( param == 0 )
	{
		/*
		**	Use the entire Screen.
		*/
		
		USE_WINDOW ( FULL_SCREEN ) ;
		restore_cursor_position () ;
		windowing_enabled = FALSE ;
		window_height = 0 ;
		linecount = 0 ;
	}
	else
	{
		windowing_enabled = TRUE ;
		if ( param >= (word)screen_height )
			param = (word)screen_height - 1 ;
		window_height = param ;
		if ( data_head.z_code_version <= VERSION_3 )
		{
			save_cursor_position () ;
			ERASE_WINDOW ( top_screen_line,top_screen_line + param ) ;
			restore_cursor_position () ;
		}
		USE_WINDOW ( WINDOW_0 ) ;
		if ( data_head.z_code_version >= VERSION_5 )
			GOTO_XY ( 0,screen_height - 1 ) ;
	}
}

/*
**	Enhanced Windowing Support Routines.
*/

boolean		cursor_pos_saved		= FALSE ;

Void
save_cursor_position ()
{
	extern boolean	cursor_pos_saved ;

	if ( cursor_pos_saved == FALSE )
	{
		SAVE_CURSOR () ;
		cursor_pos_saved = TRUE ;
	}
}

Void
restore_cursor_position ()
{
	extern header	data_head ;
	extern boolean	cursor_pos_saved ;
	extern int		screen_height ;

	if ( data_head.z_code_version <= VERSION_4 )
	{
		if ( cursor_pos_saved != FALSE )
		{
			RESTORE_CURSOR () ;
			cursor_pos_saved = FALSE ;
		}
	}
	else
	{
		if ( cursor_pos_saved != FALSE )
		{
			RESTORE_CURSOR () ;
			cursor_pos_saved = FALSE ;
		}
		else
			GOTO_XY ( 0,screen_height - 1 ) ;
	}
}
