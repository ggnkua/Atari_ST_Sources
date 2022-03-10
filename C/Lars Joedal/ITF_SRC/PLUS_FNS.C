/*
**	File:	plus_fns.c
**
**	(C)opyright 1987-1992 InfoTaskforce.
*/

#include	<stdio.h>
#include	"infocom.h"

/*
**	PLUS Interpreter Function Definitions.
*/

Void
parameter_copy ( src,dst )
word	*src ;
word	*dst ;
{
	word	src_size ;
	word	dst_size ;

	src_size = *src++ ;
	dst_size = *dst++ ;
	if ( src_size > dst_size )
	{
		src += dst_size ;
		dst += dst_size ;
		src_size -= dst_size ;
		while ( src_size-- )
			*dst++ = *src++ ;
	}
}

Void
plus_compare2 ()
{
	extern word		param_stack[] ;

	register word	*ptr	= &param_stack[1] ;
	register word	data ;			/* Parameter 1 */
	register word	address ;		/* Parameter 2 */
	register word	num_words ;		/* Parameter 3 */
	word			addr_page ;
	word			addr_offset ;

	data = *ptr++ ;
	address = *ptr++ ;
	num_words = *ptr++ ;
	addr_page = address / BLOCK_SIZE ;
	addr_offset = address % BLOCK_SIZE ;
	while ( num_words-- != 0 )
	{
		if ( data == get_word ( &addr_page,&addr_offset ) )
		{
			address = ( addr_page * BLOCK_SIZE ) + addr_offset - 2 ;
			store ( address ) ;
			ret_value ( TRUE ) ;
			return ;
		}
	}
	store ( (word)0 ) ;
	ret_value ( FALSE ) ;
}

Void
adv_compare2 ()
{
	extern word		param_stack[] ;
	extern word		default_param_stack[] ;

	register word	*ptr	= &param_stack[1] ;
	register word	data ;			/* Parameter 1 */
	register word	address ;		/* Parameter 2 */
	register word	num_words ;		/* Parameter 3 */
	register word	inc ;			/* Parameter 4 */
	register word	data_size ;		/* Parameter 4 */
	word			addr_page ;
	word			addr_offset ;

	default_param_stack[0] = 4 ;
	default_param_stack[4] = 0x82 ;
	parameter_copy ( default_param_stack,param_stack ) ;
	data = *ptr++ ;
	address = *ptr++ ;
	num_words = *ptr++ ;
	inc = *ptr & 0x7F ;
	data_size = *ptr & 0x80 ;
	while ( num_words-- )
	{
		addr_page = address / BLOCK_SIZE ;
		addr_offset = address % BLOCK_SIZE ;
		if ( data_size != 0 )
		{
			if ( data == get_word ( &addr_page,&addr_offset ) )
			{
				store ( address ) ;
				ret_value ( TRUE ) ;
				return ;
			}
		}
		else
		{
			if ( (byte)data == get_byte ( &addr_page,&addr_offset ) )
			{
				store ( address ) ;
				ret_value ( TRUE ) ;
				return ;
			}
		}
		address += inc ;
	}
	store ( (word)0 ) ;
	ret_value ( FALSE ) ;
}

Void
gosub2 ( address )
word	address ;
{
	extern proc_ptr	jmp_op2[] ;
	extern word		param_stack[] ;

	param_stack[0] = 1 ;
	param_stack[1] = address ;

	/*
	**	Call the current "gosub" opcode ...
	*/

	(*jmp_op2[0x20])() ;
}

Void
do_beep ( sound )
word	sound ;
{
	/*
	**	Note: The only legal values for sound are 1 and 2.
	*/

	while ( sound-- )
		putchar ( BELL ) ;
}

Void
erase_line ( mode )
word	mode ;
{
	/*
	**	"mode" must be 1.
	**	The characters at the cursor and to the right are erased.
	**	The cursor itself is not moved.
	*/

	if ( mode == 1 )
		ERASE_TO_EOLN () ;
}

Void
do_clear_screen ( param )
word	param ;
{
	extern header	data_head ;
	extern word		window_height ;
	extern int		screen_height ;
	extern word		top_screen_line ;

	signed_word		window ;

	window = (signed_word)param ;
	switch ( window )
	{
		case -1:
				split_screen ( (word)0 ) ;
				ERASE_WINDOW ( top_screen_line,(word)screen_height ) ;
				if ( data_head.z_code_version == VERSION_4 )
				{
					/*
					**	cursor to bottom l.h.s
					*/

					GOTO_XY ( 0,screen_height - 1 ) ;
				}
				break ;
		case 0:
				ERASE_WINDOW ( window_height,(word)screen_height ) ;
				break ;
		case 1:
				ERASE_WINDOW ( top_screen_line,window_height ) ;
				break ;
	}
}

Void
set_cursor_posn ()
{
	/*
	**	Here is some code from either a MAC or an AMIGA.
	**	It is different to that used by the IBM PC (see below).
	**	Which is better ?
	**
	**		if ( current_window != 1 )
	**			error ( PLUS_ERROR_2 ) ;
	**		GOTO_XY ( param_stack[2],param_stack[1] ) ;
	*/

	extern header	data_head ;
	extern word		param_stack[] ;
	extern word		current_window ;
	extern boolean	use_buffered_io ;

	if ( data_head.z_code_version >= VERSION_5 )
	{
		flush_prt_buff () ;
		GOTO_XY ( --param_stack[2],--param_stack[1] ) ;
	}
	else
	{
		if ( use_buffered_io == FALSE )
		{
			if ( current_window != 0 )
				GOTO_XY ( --param_stack[2],--param_stack[1] ) ;
		}
	}
}

Void
set_text_mode ( mode )
word	mode ;
{
	/*
	**	Mode:
	**			0 = NORMAL_MODE ;
	**			1 = INVERSE_MODE ;
	**			2 = BOLD_MODE ;
	*/

	/*
	**	In interpreters prior to VERSION_5, the "mode" parameter is not
	**	checked before being incremented and passed to "print_char ()".
	**	In VERSION_5 and subsequent interpreters, the "mode" parameter
	**	is checked first.
	**
	**	However, there is no reason for us not to adopt the VERSION_5
	**	method for all versions of the interpreter.
	**
	**	Interpreters prior to VERSION_5 did not include the statement:
	**
	**				if ( mode < 5 )
	*/

	if ( mode < 5 )
		print_char ( ++mode ) ;
}

Void
io_buffer_mode ( param )
word	param ;
{
	extern boolean	use_buffered_io ;

	if ( param == 0 )
	{
		use_buffered_io = FALSE ;
		flush_prt_buff () ;
	}
	else
		use_buffered_io = TRUE ;
}

Void
io_mode ()
{
	extern header		data_head ;
	extern word			param_stack[] ;
	extern byte_ptr		base_ptr ;
	extern byte_ptr		internal_io_buffer ;
	extern byte_ptr		internal_io_ptr ;
	extern word			int_io_buff_length ;
	extern boolean		enable_screen ;
	extern boolean		script_on ;
	extern boolean		use_internal_buffer ;

	byte_ptr			ptr ;
	signed_word			mode ;

	mode = (signed_word)param_stack[1] ;
	switch ( mode )
	{
		case 1:
				enable_screen = TRUE ;
				break ;
		case 2:
				if ( script_on == FALSE )
				{
					data_head.script_status |= SCRIPT_MODE_ON ;
					if (( script_on = open_script () ) == FALSE )
						data_head.script_status = SCRIPT_ERROR ;
					ptr = (byte_ptr) &(((header_ptr)base_ptr) -> script_status) ;
					*ptr++ = MOST_SIGNIFICANT_BYTE ( data_head.script_status ) ;
					*ptr = LEAST_SIGNIFICANT_BYTE ( data_head.script_status ) ;
				}
				break ;
		case 3:
				use_internal_buffer = TRUE ;
				internal_io_buffer = base_ptr + param_stack[2] ;
				int_io_buff_length = 0 ;
				internal_io_ptr = internal_io_buffer + 2 ;
				break ;
		case -1:
				enable_screen = FALSE ;
				break ;
		case -2:
				script_on = FALSE ;
				data_head.script_status &= SCRIPT_MODE_OFF ;
				close_script () ;
				ptr = (byte_ptr) &(((header_ptr)base_ptr) -> script_status) ;
				*ptr++ = MOST_SIGNIFICANT_BYTE ( data_head.script_status ) ;
				*ptr = LEAST_SIGNIFICANT_BYTE ( data_head.script_status ) ;
				break ;
		case -3:
				use_internal_buffer = FALSE ;
				*internal_io_buffer++ = MOST_SIGNIFICANT_BYTE ( int_io_buff_length ) ;
				*internal_io_buffer = LEAST_SIGNIFICANT_BYTE ( int_io_buff_length ) ;
				*internal_io_ptr = 0 ;
				break ;
	}
}

Void
get_key ()
{
	extern header	data_head ;
	extern word		param_stack[] ;
	extern int		linecount ;

	if ( data_head.z_code_version >= VERSION_5 )
		flush_prt_buff () ;

	linecount = 0 ;
	if ( param_stack[1] == 1 )
	{
		if ( param_stack[0] < 3 )
		{
			store ( read_the_key () ) ;
			return ;
		}
		else
		{
			if ( wait_for_key ( param_stack[2]/10,param_stack[3] ) == TRUE )
			{
				store ( read_the_key () ) ;
				return ;
			}
		}
	}
	store ( (word)0 ) ;
}

word
read_the_key ()
{
	/*
	**	This routine assumes that special keys such as the cursor
	**	movement and backspace/delete keys have been translated by
	**	the "GET_CH" routine.
	**
	**	The following translations are suggested:
	**
	**		DELETE		-> BACK_SPACE character ('\b')
	**		LEFT_ARROW	-> BACK_SPACE character ('\b')
	**		RIGHT_ARROW	-> BELL character (0x07)
	**		UP_ARROW	-> VERTICAL_TAB character (0x0B)
	**		DOWN_ARROW	-> CARRIAGE_RETURN character ('\r')
	**
	**	This routine translates '\n' to '\r'.
	*/

	register int	ch ;
	register int	done	= FALSE ;

	while ( ! done )
	{
		switch ( ch = GET_CH () )
		{
			case BELL:
			case VERTICAL_TAB:
			case '\b':
			case '\r':
						done = TRUE ;
						break ;
			case '\n':
						ch = '\r' ;
						done = TRUE ;
						break ;
			default:
						if ( ch >= ' ' )
							done = TRUE ;
						break ;
		}
	}
	return ( (word)ch ) ;
}

boolean
wait_for_key ( time_out,address )
word	time_out ;
word	address ;
{
	register word	delay ;
	register long	now ;
	register long	next ;

	do
	{
		delay = time_out ;
		do
		{
			now = TIME_FUNCTION ;
			do
			{
				if ( KBD_HIT () )
					return ( TRUE ) ;
				next = TIME_FUNCTION ;
			} while ( next - now < ONE_SECOND ) ;
			now = next ;
		} while ( --delay != 0 ) ;
	} while ( special_gosub ( address ) == 0 ) ;
	return ( FALSE ) ;
}

word
special_gosub ( address )
word	address ;
{
	extern proc_ptr	jmp_op2[] ;
	extern word		param_stack[] ;
	extern word		pc_page ;
	extern word		*stack ;
	extern boolean	stop ;

	word			value ;
	boolean			old_stop ;

	old_stop = stop ;
	*(--stack) = pc_page ;
	pc_page = EMPTY_PAGE ;
	param_stack[0] = 1 ;
	param_stack[1] = address ;

	/*
	**	Call the current "gosub" opcode ...
	*/

	(*jmp_op2[0x20])() ;

	execute_opcode () ;
	value = *stack++ ;
	pc_page = *stack++ ;
	fix_pc () ;
	stop = old_stop ;
	return ( value ) ;
}

/*
**	ADVANCED Interpreter Function Definitions.
*/

Void
gosub4 ()
{
	call ( PROCEDURE ) ;
}

Void
gosub5 ( address )
word	address ;
{
	extern word		param_stack[] ;

	param_stack[0] = 1 ;
	param_stack[1] = address ;
	gosub4 () ;
}

Void
call ( type )
word	type ;
{
	extern word		pc_offset ;
	extern word		pc_page ;
	extern word		*stack_base ;
	extern word		*stack_var_ptr ;
	extern word		*stack ;
	extern word		param_stack[] ;
	extern byte		local_params ;

	register word	*param_ptr = &param_stack[0] ;
	register word	address ;
	register word	parameter ;
	register int	num_params ;
	int				vars ;

	num_params = (int) *param_ptr++ ;
	if (( address = *param_ptr++ ) == 0 )
	{
		if ( type != PROCEDURE )
			store ( address ) ;
	}
	else
	{
		--num_params ;
		*(--stack) = pc_page ;
		*(--stack) = pc_offset ;
		*(--stack) = type | local_params ;

		/*
		**	Push offset of old stack_var_ptr from stack_base onto stack
		*/

		*(--stack) = (word)(stack_var_ptr - stack_base) ;

		pc_page = PLUS_PAGE ( address ) ;
		pc_offset = PLUS_OFFSET ( address ) ;
		fix_pc () ;

		/*
		**	The value of the current stack pointer is the
		**	new value of stack_var_ptr.
		*/

		stack_var_ptr = stack ;
		local_params = num_params ;

		/*
		**	Global variables 1 to 15 are Local variables, which
		**	reside on the stack (and so are local to each procedure).
		*/

		vars = (int) next_byte () ;
		if ( vars > ( (int)LOCAL_VARS - 1 ) )
		{
			display ( "Bad loc num" ) ;
			vars = LOCAL_VARS - 1 ;
		}
		if ( num_params > vars )
		{
			display ( "Bad optional num" ) ;
			num_params = vars ;
		}
		vars -= num_params ;
		while ( num_params-- )
			*(--stack) = *param_ptr++ ;
		while ( vars-- )
			*(--stack) = 0 ;
	}
}

Void
branch_true ()
{
	ret_value ( TRUE ) ;
}

Void
throw_away_stack_frame ( value,stack_offset )
word	value ;
word	stack_offset ;
{
	extern word		*stack_base ;
	extern word		*stack_var_ptr ;

	register word	*new_svp ;

	new_svp = stack_base + (signed_word)stack_offset ;
	if ( new_svp < stack_var_ptr )
		display ( "Bad Throw" ) ;
	else
	{
		stack_var_ptr = new_svp ;
		adv_rtn ( value ) ;
	}
}

Void
parse ()
{
	extern word			default_param_stack[] ;
	extern word			param_stack[] ;
	extern byte_ptr		base_ptr ;
	extern byte_ptr		main_vocab_list ;

	byte_ptr			in_buf_strt ;
	byte_ptr			word_buff_strt ;
	byte_ptr			vocab_strt ;

	default_param_stack[0] = 4 ;
	default_param_stack[3] = 0 ;
	default_param_stack[4] = 0 ;
	parameter_copy ( default_param_stack,param_stack ) ;

	in_buf_strt = base_ptr + param_stack[1] ;
	word_buff_strt = base_ptr + param_stack[2] ;
	if ( param_stack[3] == 0 )
		vocab_strt = main_vocab_list ;
	else
		vocab_strt = base_ptr + param_stack[3] ;
	advanced_parse_buffer ( in_buf_strt,word_buff_strt,vocab_strt,param_stack[4] ) ;
}

Void
encrypt ( param1,param2,param3,param4 )
word	param1 ;
word	param2 ;
word	param3 ;
word	param4 ;
{
	extern byte_ptr		base_ptr ;

	word				coded[PLUS_ENCODED_SIZE] ;
	byte_ptr			ptr ;
	register word		i ;

	ptr = base_ptr + param1 + param3 ;
	i = get_code ( &ptr,PLUS_CHARS_PER_WORD,coded ) ;
	ptr = base_ptr + param4 ;
	for ( i = 0 ; i < PLUS_ENCODED_SIZE ; i++ )
	{
		*ptr++ = MOST_SIGNIFICANT_BYTE ( coded[i] ) ;
		*ptr++ = LEAST_SIGNIFICANT_BYTE ( coded[i] ) ;
	}
}

Void
block_copy ()
{
	extern word				param_stack[] ;
	extern byte_ptr			base_ptr ;

	register word			*ptr		= &param_stack[1] ;
	register boolean		negative	= FALSE ;
	register byte_ptr		dst ;
	register word			src_offset ;	/* Parameter 1 */
	register word			dst_offset ;	/* Parameter 2 */
	register signed_word	num_words ;		/* Parameter 3 */
	word					addr_page ;
	word					addr_offset ;

	src_offset = *ptr++ ;
	dst_offset = *ptr++ ;
	if ( src_offset != dst_offset )
	{
		num_words = (signed_word)*ptr ;
		if ( num_words != 0 )
		{
			if ( num_words < 0 )
			{
				negative = TRUE ;
				num_words = -num_words ;
			}
			if ( dst_offset == 0 )
			{
				dst = base_ptr + src_offset ;
				while ( num_words-- )
					*dst++ = 0 ;
			}
			else
			{
				if	(
						( negative )
						||
						( src_offset > dst_offset )
						||
						( (word)( (signed_word)src_offset + num_words ) < dst_offset )
					)
				{
					dst = base_ptr + dst_offset ;
					addr_page = src_offset / BLOCK_SIZE ;
					addr_offset = src_offset % BLOCK_SIZE ;
					while ( num_words-- )
						*dst++ = get_byte ( &addr_page,&addr_offset ) ;
				}
				else
				{
					dst = base_ptr + ( dst_offset + num_words ) ;
					src_offset += num_words ;
					while ( num_words-- )
					{
						--src_offset ;
						addr_page = src_offset / BLOCK_SIZE ;
						addr_offset = src_offset % BLOCK_SIZE ;
						*(--dst) = get_byte ( &addr_page,&addr_offset ) ;
					}
				}
			}
		}
	}
}

Void
print_text ()
{
	extern word		default_param_stack[] ;
	extern word		param_stack[] ;

	register word	*ptr	= &param_stack[1] ;
	register word	address ;		/* Parameter 1 */
	register word	line_width ;	/* Parameter 2 */
	register word	num_lines ;		/* Parameter 3 */
	register word	count ;
	word			addr_page ;
	word			addr_offset ;
	int				cursor_x ;
	int				cursor_y ;

	default_param_stack[0] = 3 ;
	default_param_stack[3] = 1 ;
	parameter_copy ( default_param_stack,param_stack ) ;

	cursor_x = GET_X () ;
	cursor_y = GET_Y () ;
	address = *ptr++ ;
	line_width = *ptr++ ;
	num_lines = *ptr++ ;
	if ( line_width > 0 )
	{
		while ( num_lines )
		{
			count = line_width ;
			addr_page = address / BLOCK_SIZE ;
			addr_offset = address % BLOCK_SIZE ;
			while ( count-- )
				print_char ( (word) get_byte ( &addr_page,&addr_offset ) ) ;
			if ( --num_lines )
			{
				/*
				**	New Line.
				*/

				GOTO_XY ( cursor_x,++cursor_y ) ;
				address += line_width ;
			}
		}
	}
}

Void
num_local_params ( num_params )
word	num_params ;
{
	extern byte		local_params ;

	if ( num_params <= (word)local_params )
		ret_value ( TRUE ) ;
	else
		ret_value ( FALSE ) ;
}

Void
logical_shift ( param1,param2 )
word	param1 ;
word	param2 ;
{
	register signed_word	bits_to_shift ;

	bits_to_shift = (signed_word) param2 ;
	if ( bits_to_shift < 0 )
		store ( (word)( param1 >> ( -bits_to_shift ) ) ) ;
	else
		store ( (word)( param1 << bits_to_shift ) ) ;
}

Void
arithmetic_shift ( param1,param2 )
word	param1 ;
word	param2 ;
{
	register signed_word	bits_to_shift ;

	bits_to_shift = (signed_word) param2 ;
	if ( bits_to_shift < 0 )
	{
		if ( ( (signed_word)param1 ) < 0 )
			store ( (word)( ~((signed_word)( ~param1 ) >> ( -bits_to_shift )) ) ) ;
		else
			store ( (word)( (signed_word)param1 >> ( -bits_to_shift ) ) ) ;
	}
	else
		store ( (word)( param1 << bits_to_shift ) ) ;
}

Void
clear_flag ()
{
	/*
	**	Load a register with 0 but don't do anything with it.
	*/
}

Void
set_flag ()
{
	/*
	**	Load a register with 1 but don't do anything with it.
	*/
}

int
array_test ( ptr,value )
byte_ptr	ptr ;
word		value ;
{
	/*
	**	This function is only used by "test_byte_array ()".
	**	On a MAC, it always returns -1.
	*/

	return ( -1 ) ;
}

Void
test_byte_array ( value,offset )
word	value ;
word	offset ;
{
	extern byte_ptr		base_ptr ;

	register byte_ptr	ptr ;

	ptr = base_ptr + offset ;
	if ( array_test ( ptr,value ) >= 0 )
		ret_value ( TRUE ) ;
	else
		ret_value ( FALSE ) ;
}
