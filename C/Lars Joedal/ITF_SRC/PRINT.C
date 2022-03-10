/*
**	File:	print.c
**
**	(C)opyright 1987-1992 InfoTaskforce.
*/

#include	"infocom.h"

/*
**	Print Routine Global Variables
**
**	Note:
**		The variables "p_buff_ptr" and "p_buff_end" are of
**		type "byte *" NOT "byte_ptr" - these definitions are
**		different for MSDOS Compilers ("byte_ptr" is huge).
*/

byte	p_buff_strt[MAX_LINE_LENGTH] ;
byte	*p_buff_ptr ;
byte	*p_buff_end ;

Void
init_print ()
{
	extern header	data_head ;
	extern int		screen_width ;
	extern int		linecount ;
	extern boolean	enable_screen ;
	extern boolean	disable_script ;
	extern proc_ptr	PrintChar ;
	extern boolean	windowing_enabled ;
	extern word		current_window ;
	extern boolean	use_buffered_io ;
	extern word		top_screen_line ;

	linecount			= 0 ;
	enable_screen		= TRUE ;
	disable_script		= FALSE ;
	PrintChar			= print_char ;
	p_buff_ptr			= p_buff_strt ;
	p_buff_end			= &p_buff_strt[screen_width - 1] ;
	windowing_enabled	= FALSE ;
	current_window		= 0 ;
	use_buffered_io		= TRUE ;

	if ( data_head.z_code_version <= VERSION_3 )
		top_screen_line = STD_TOP_SCREEN_LINE ;
	else
		top_screen_line = PLUS_TOP_SCREEN_LINE ;
}

Void
flush_prt_buff ()
{
	extern int	linecount ;

	print_buffer ( p_buff_ptr ) ;
	p_buff_ptr = p_buff_strt ;
	linecount = 0 ;
}

Void
print_num ( number )
word	number ;
{
	extern proc_ptr	PrintChar ;
	int				num ;

	if ( number == 0 )
		(*PrintChar)( (word)'0' ) ;
	else
	{
		num = (signed_word)number ;
		if ( num < 0 )
		{
			num = -num ;
			(*PrintChar)( (word)'-' ) ;
		}
		PrintNumber ( num ) ;
	}
}

Void
PrintNumber ( num )
int		num ;
{
	extern proc_ptr	PrintChar ;

	word			ch ;

	if ( num > 9 )
		PrintNumber ( num / 10 ) ;
	ch = '0' + ( num % 10 ) ;
	(*PrintChar)( ch ) ;
}

Void
std_print2 ( address )
word	address ;
{
	word	page ;
	word	offset ;

	page = STD_PAGE ( address ) ;
	offset = STD_OFFSET ( address ) ;
	print_coded ( &page,&offset ) ;
}

Void
plus_print2 ( address )
word	address ;
{
	word	page ;
	word	offset ;

	page = PLUS_PAGE ( address ) ;
	offset = PLUS_OFFSET ( address ) ;
	print_coded ( &page,&offset ) ;
}

Void
print1 ( address )
word	address ;
{
	word	page ;
	word	offset ;

	page = address / BLOCK_SIZE ;
	offset = address % BLOCK_SIZE ;
	print_coded ( &page,&offset ) ;
}

Void
std_p_obj ( obj_num )
word	obj_num ;
{
	extern std_object_ptr	std_obj_list ;

	std_object_ptr			obj ;
	word					address ;

	obj = STD_OBJ_ADDR ( obj_num ) ;
	address = ((obj -> prop_ptr[0]) << 8) + (obj -> prop_ptr[1]) + 1 ;
	print1 ( address ) ;
}

Void
plus_p_obj ( obj_num )
word	obj_num ;
{
	extern plus_object_ptr	plus_obj_list ;

	plus_object_ptr			obj ;
	word					address ;

	obj = PLUS_OBJ_ADDR ( obj_num ) ;
	address = ((obj -> prop_ptr[0]) << 8) + (obj -> prop_ptr[1]) + 1 ;
	print1 ( address ) ;
}

Void
wrt ()
{
	extern word		pc_page ;
	extern word		pc_offset ;

	print_coded ( &pc_page,&pc_offset ) ;
	fix_pc () ;
}

Void
writeln ()
{
	wrt () ;
	new_line () ;
	ret_true () ;
}

Void
new_line ()
{
	*p_buff_ptr++ = '\n' ;
	print_buffer ( p_buff_ptr ) ;
	p_buff_ptr = p_buff_strt ;
}

Void
print_char ( ch )
word	ch ;
{
	extern boolean		use_buffered_io ;
	extern boolean		use_internal_buffer ;
	extern byte_ptr		internal_io_ptr ;
	extern word			int_io_buff_length ;

	byte				*ptr ;

	/*
	**	Note:
	**		The variable "ptr" is of type "byte *"
	**		NOT "byte_ptr" - these definitions are
	**		different for MSDOS Compilers ("byte_ptr" is huge).
	*/

	if ( use_internal_buffer == TRUE )
	{
		*internal_io_ptr++ = (byte)ch ;
		++int_io_buff_length ;
		return ;
	}
	if ( use_buffered_io == FALSE )
	{
		out_char ( (char)ch ) ;
		return ;
	}

	if ( p_buff_ptr == p_buff_end )
	{
		if ( ch == (word)' ' )
		{
			print_buffer ( p_buff_end ) ;
			out_char ( '\n' ) ;
			p_buff_ptr = p_buff_strt ;
			return ;
		}
		else
		{
			--p_buff_ptr ;
			while ((*p_buff_ptr != (byte)' ') && (p_buff_ptr != p_buff_strt))
				--p_buff_ptr ;
			if ( p_buff_ptr == p_buff_strt )
			{
				print_buffer ( p_buff_end ) ;
				out_char ( '\n' ) ;
			}
			else
			{
				print_buffer ( ++p_buff_ptr ) ;
				out_char ( '\n' ) ;
				ptr = p_buff_strt ;
				while ( p_buff_ptr != p_buff_end )
					*ptr++ = *p_buff_ptr++ ;
				p_buff_ptr = ptr ;
			}
		}
	}
	*p_buff_ptr++ = (byte)ch ;
}

Void
print_buffer ( buff_end )
byte	*buff_end ;
{
	byte	*ptr = p_buff_strt ;

	/*
	**	Note:
	**		The parameter "buff_end" and the variable "ptr"
	**		are of type "byte *" NOT "byte_ptr" - these
	**		definitions are different for MSDOS Compilers ("byte_ptr" is huge).
	*/
	
	while ( ptr != buff_end )
		out_char ( (char)*ptr++ ) ;
}
