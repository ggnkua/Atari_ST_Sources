/*
**	File:	input.c
**
**	(C)opyright 1987-1992 InfoTaskforce.
*/

#include	"infocom.h"

/*
**	Input Routine Global Variables
**
**	Note:
**		The variable "end_of_sentence" is of type "byte *"
**		NOT "byte_ptr" - these definitions are different
**		for MSDOS Compilers ("byte_ptr" is huge).
*/

byte		ws_buff_strt[TABLE_SIZE] ;
byte		*end_of_sentence ;
word		num_vocab_words ;
word		vocab_entry_size ;
word		strt_vocab_table ;
word		end_vocab_table ;
word		initial_chop ;
boolean		has_initial_chop ;
char		ws_table[] =	{ ' ','\t','\r','.',',','?','\0','\0' } ;

Void
init_vocab ( vocab_strt )
byte_ptr	vocab_strt ;
{
	extern byte_ptr		base_ptr ;

	word				shift ;
	word				num ;

	/*	Note:
	**		'strt_vocab_table' and 'end_vocab_table' are given
	**		as offsets from the start of the data_file. These
	**		offsets are guaranteed to be no more than 16 bits
	**		long since only a two byte offset is required by
	**		the 'parse_buffer ()' routine. Hence we can use a
	**		'word' to represent them.
	*/

	num = *vocab_strt++ ;
	vocab_strt += num ;
	vocab_entry_size = *vocab_strt++ ;
	shift = *(vocab_strt++) << 8 ;
	shift |= *vocab_strt++ ;
	strt_vocab_table = (word)( vocab_strt - base_ptr ) ;

	if ( ((signed_word)shift) > 0 )
	{
		num_vocab_words = shift ;
		initial_chop = vocab_entry_size ;
		shift >>= 1 ;
		do
		{
			initial_chop <<= 1 ;
			shift >>= 1 ;
		} while ( shift != 0 ) ;
		has_initial_chop = TRUE ;
	}
	else
	{
		num_vocab_words = -((signed_word)shift) ;
		has_initial_chop = FALSE ;
	}

	end_vocab_table = strt_vocab_table + vocab_entry_size * (num_vocab_words-1);
}

Void
init_input ( vocab )
word	vocab ;
{
	extern byte_ptr		base_ptr ;
	extern byte_ptr		main_vocab_list ;

	word				num ;
	byte_ptr			p ;
	byte				*q ;
	byte				*r ;

	/*
	**	Note:
	**		The variables "q" and "r" are of type "byte *"
	**		NOT "byte_ptr" - these definitions are different
	**		for MSDOS Compilers ("byte_ptr" is huge).
	*/

	main_vocab_list = base_ptr + vocab ;

	p = main_vocab_list ;
	num = *p++ ;
	q = ws_buff_strt ;
	while ( num-- )
		*q++ = *p++ ;
	end_of_sentence = q ;
	r = (byte *)ws_table ;
	while ( *r != '\0' )
		*q++ = *r++ ;
	*q = '\0' ;

	init_vocab ( main_vocab_list ) ;
}

Void
input ()
{
	extern header		data_head ;
	extern word			default_param_stack[] ;
	extern word			param_stack[] ;
	extern byte_ptr		base_ptr ;
	extern byte_ptr		main_vocab_list ;

	byte_ptr			in_buf_strt ;
	byte_ptr			word_buff_strt ;

	/*
	**	Empty the Print Buffer
	*/

	if ( data_head.z_code_version <= VERSION_3 )
		prt_status () ;

	flush_prt_buff () ;

	default_param_stack[0] = 4 ;
	default_param_stack[2] = 0 ;
	default_param_stack[3] = 0xFFFF ;
	default_param_stack[4] = 0 ;
	parameter_copy ( default_param_stack,param_stack ) ;

	/*
	**	Get an Input Line and Parse it.
	**
	**	On entry:
	**			param_stack[1] = char_offset ;
	**			param_stack[2] = word_offset ;
	**			param_stack[3] = ? ;			<- ADVANCED Version Only.
	**			param_stack[4] = ? ;			<- ADVANCED Version Only.
	*/

	in_buf_strt = base_ptr + param_stack[1] ;
	word_buff_strt = base_ptr + param_stack[2] ;
	read_line ( in_buf_strt ) ;

	switch ( data_head.z_code_version )
	{
		case VERSION_1:
		case VERSION_2:
		case VERSION_3:
						std_parse_buffer ( in_buf_strt,word_buff_strt ) ;
						break ;
		case VERSION_4:
						plus_parse_buffer ( in_buf_strt,word_buff_strt ) ;
						break ;
		case VERSION_5:
		default:
						if ( param_stack[2] != 0 )
							advanced_parse_buffer ( in_buf_strt,word_buff_strt,main_vocab_list,(word)0 ) ;
						store ( (word)'\n' ) ;
						break ;
	}
}

Void
read_line ( buffer )
byte_ptr	buffer ;
{
	register byte_ptr	char_ptr ;
	register byte		buffer_size ;
	register byte		count ;
	register char		ch ;

	/*
	**	The first byte of the buffer contains the buffer length.
	**	The second byte contains the number of characters put in the buffer.
	*/

	buffer_size = *buffer++ ;
	char_ptr = ++buffer ;
	count = 0 ;
	while (( ch = read_char ()) != '\n' )
	{
		if ( ch == '\b' )
		{
			if ( char_ptr != buffer )
			{
				--char_ptr ;
				--count ;
			}
		}
		else
		{
			/*
			**	Make it Lower Case
			*/

			if (( ch >= 'A' ) && ( ch <= 'Z' ))
				ch += ( 'a' - 'A' ) ;
			*char_ptr++ = (byte)ch ;
			++count ;

			/*
			**	Check to see if Buffer is full
			*/

			if ( count == buffer_size )
			{
				/*
				**	Flush remaining characters
				*/

				new_line () ;
				display ( "Input line too long. Flushing: " ) ;
				while (( ch = read_char ()) != '\n' )
					print_char ( (word)ch ) ;
				new_line () ;
				break ;
			}
		}
	}
	/*
	**	Record the number of characters in the buffer.
	*/

	*(--buffer) = count ;
}

word
look_up ( coded,encoded_size )
word	coded[] ;
word	encoded_size ;
{
	register long_word	v_ptr ;
	register word		chop ;
	register word		data ;
	word				page ;
	word				offset ;
	int					i ;

	/*	Note:
	**		'strt_vocab_table' and 'end_vocab_table' are given
	**		as offsets from the start of the data_file. These
	**		offsets are guaranteed to be no more than 16 bits
	**		long since only a two byte offset is required by
	**		the 'parse_buffer ()' routine. Hence we can use a
	**		'word' to represent them.
	*/

	chop = initial_chop ;
	v_ptr = strt_vocab_table + chop - vocab_entry_size ;
	do
	{
		i = 0 ;
		chop >>= 1 ;
		page = (word)( v_ptr / BLOCK_SIZE ) ;
		offset = (word)( v_ptr % BLOCK_SIZE ) ;
		data = get_word ( &page,&offset ) ;
		while ( coded[i] == data )
		{
			if ( ++i < (int)encoded_size )
				data = get_word ( &page,&offset ) ;
			else
				return ( (word)v_ptr ) ;
		}
		if ( coded[i] > data )
		{
			v_ptr += chop ;
			if ( v_ptr > ((long_word)end_vocab_table) )
				v_ptr = ((long_word)end_vocab_table) ;
		}
		else
			v_ptr -= chop ;
	} while ( chop >= vocab_entry_size ) ;
	return ( (word)0 ) ;
}

/*
**	Standard Version Input Routines
*/

Void
std_parse_buffer ( in_buf_strt,word_buff_strt )
byte_ptr	in_buf_strt ;
byte_ptr	word_buff_strt ;
{
	word				coded[STD_ENCODED_SIZE] ;
	byte				the_word[STD_1CHARS_PER_WORD] ;
	boolean				white_space ;
	register word		offset ;
	register byte_ptr	in_buf_end ;
	register byte_ptr	last_word ;
	register byte_ptr	wd_ptr ;
	register byte_ptr	char_ptr ;
	register byte		*ws ;
	register byte		word_count ;
	register byte		ch ;
	register int		i ;

	/*
	**	Note:
	**		The variable "ws" is of type "byte *"
	**		NOT "byte_ptr" - these definitions are
	**		different for MSDOS Compilers ("byte_ptr" is huge).
	*/

	word_count = 0 ;
	char_ptr = in_buf_strt + 1 ;
	in_buf_end = in_buf_strt + 2 + *char_ptr++ ;
	wd_ptr = word_buff_strt + 2 ;

	i = 0 ;
	while (( char_ptr != in_buf_end ) || ( i != 0 ))
	{
		i = 0 ;
		last_word = char_ptr ;
		white_space = FALSE ;
		while (( char_ptr != in_buf_end ) && ( !white_space ))
		{
			ch = *char_ptr++ ;
			ws = ws_buff_strt ;
			while (( *ws != ch ) && ( *ws != 0 ))
				++ws ;
			if ( *ws == ch )
			{
				white_space = TRUE ;
				if ( i != 0 )
					--char_ptr ;
				if (( i == 0 ) && ( ws < end_of_sentence ))
					the_word[i++] = ch ;
			}
			else
			{
				if ( i < (int)STD_CHARS_PER_WORD )
					the_word[i++] = ch ;
			}
		}

		if ( i != 0 )
		{

			/*
			**	First byte of buffer contains the buffer length
			*/

			if ( word_count == *word_buff_strt )
			{
				display ( "Too many words typed. Flushing: " ) ;
				*in_buf_end = 0 ;
				display ( (char *)last_word ) ;
				new_line () ;
				*(word_buff_strt + 1) = *word_buff_strt ;
				return ;
			}
			else
			{
				++word_count ;
				*( wd_ptr + 2 ) = (byte)(char_ptr - last_word) ;
				*( wd_ptr + 3 ) = (byte)(last_word - in_buf_strt) ;
				the_word[i] = 0 ;
				std_encode ( the_word,coded ) ;
				offset = look_up ( coded,STD_ENCODED_SIZE ) ;
				*(wd_ptr + 1) = (byte)offset ;
				*wd_ptr = (byte)(offset >> 8) ;
				wd_ptr += 4 ;
			}
		}
	}
	*(word_buff_strt + 1) = word_count ;
}

/*
**	Plus Version Input Routines
*/

Void
plus_parse_buffer ( in_buf_strt,word_buff_strt )
byte_ptr	in_buf_strt ;
byte_ptr	word_buff_strt ;
{
	word				coded[PLUS_ENCODED_SIZE] ;
	byte				the_word[PLUS_1CHARS_PER_WORD] ;
	boolean				white_space ;
	register word		offset ;
	register byte_ptr	in_buf_end ;
	register byte_ptr	last_word ;
	register byte_ptr	wd_ptr ;
	register byte_ptr	char_ptr ;
	register byte		*ws ;
	register byte		word_count ;
	register byte		ch ;
	register int		i ;

	/*
	**	Note:
	**		The variable "ws" is of type "byte *"
	**		NOT "byte_ptr" - these definitions are
	**		different for MSDOS Compilers ("byte_ptr" is huge).
	*/

	word_count = 0 ;
	char_ptr = in_buf_strt + 1 ;
	in_buf_end = in_buf_strt + 2 + *char_ptr++ ;
	wd_ptr = word_buff_strt + 2 ;

	i = 0 ;
	while (( char_ptr != in_buf_end ) || ( i != 0 ))
	{
		i = 0 ;
		last_word = char_ptr ;
		white_space = FALSE ;
		while (( char_ptr != in_buf_end ) && ( !white_space ))
		{
			ch = *char_ptr++ ;
			ws = ws_buff_strt ;
			while (( *ws != ch ) && ( *ws != 0 ))
				++ws ;
			if ( *ws == ch )
			{
				white_space = TRUE ;
				if ( i != 0 )
					--char_ptr ;
				if (( i == 0 ) && ( ws < end_of_sentence ))
					the_word[i++] = ch ;
			}
			else
			{
				if ( i < (int)PLUS_CHARS_PER_WORD )
					the_word[i++] = ch ;
			}
		}

		if ( i != 0 )
		{

			/*
			**	First byte of buffer contains the buffer length
			*/

			if ( word_count == *word_buff_strt )
			{
				display ( "Too many words typed. Flushing: " ) ;
				*in_buf_end = 0 ;
				display ( (char *)last_word ) ;
				new_line () ;
				*(word_buff_strt + 1) = *word_buff_strt ;
				return ;
			}
			else
			{
				++word_count ;
				*( wd_ptr + 2 ) = (byte)(char_ptr - last_word) ;
				*( wd_ptr + 3 ) = (byte)(last_word - in_buf_strt) ;
				the_word[i] = 0 ;
				plus_encode ( the_word,coded ) ;
				offset = look_up ( coded,PLUS_ENCODED_SIZE ) ;
				*(wd_ptr + 1) = (byte)offset ;
				*wd_ptr = (byte)(offset >> 8) ;
				wd_ptr += 4 ;
			}
		}
	}
	*(word_buff_strt + 1) = word_count ;
}

/*
**	Advanced Version Input Routines
*/

word
scan_buffer ( start,length )
byte_ptr	*start ;
word		length ;
{
	extern byte			*end_of_sentence ;

	register boolean	white_space ;
	register byte_ptr	char_ptr ;
	register byte_ptr	end_of_buffer ;
	register byte		*ws ;
	register byte		ch ;
	register word		count ;

	/*
	**	Note:
	**		The variable "ws" is of type "byte *"
	**		NOT "byte_ptr" - these definitions are
	**		different for MSDOS Compilers ("byte_ptr" is huge).
	*/

	count = 0 ;
	white_space = FALSE ;
	char_ptr = *start ;
	end_of_buffer = *start + length ;
	while (( char_ptr != end_of_buffer ) && ( !white_space ))
	{
		ch = *char_ptr++ ;
		ws = ws_buff_strt ;
		if ( ch <= 0x7F )
		{
			while (( *ws != ch ) && ( *ws != 0 ))
				++ws ;
			if ( *ws == ch )
				white_space = TRUE ;
			else
				++count ;
		}
		else
			white_space = TRUE ;
		if (( white_space == TRUE ) && ( count == 0 ))
		{
			if ( ws >= end_of_sentence )
			{
				*start = char_ptr ;
				white_space = FALSE ;
			}
			else
				++count ;
		}
	}
	return ( count ) ;
}

Void
buffer_copy ( start,length,buffer,size )
byte_ptr	start ;
word		length ;
byte		*buffer ;
word		size ;
{
	/*
	**	Note:
	**		The parameter "buffer" is of type "byte *"
	**		NOT "byte_ptr" - these definitions are
	**		different for MSDOS Compilers ("byte_ptr" is huge).
	*/

	if ( length > size )
		length = size ;
	while ( length-- )
		*buffer++ = *start++ ;
	*buffer = 0 ;
}

word
get_code ( start,length,coded )
byte_ptr	*start ;
word		length ;
word		coded[] ;
{
	byte	the_word[PLUS_1CHARS_PER_WORD] ;

	if (( length = scan_buffer ( start,length )) != 0 )
	{
		buffer_copy ( *start,length,the_word,PLUS_CHARS_PER_WORD ) ;
		plus_encode ( the_word,coded ) ;
	}
	return ( length ) ;
}

Void
advanced_parse_buffer ( in_buf_strt,word_buff_strt,vocab_strt,ignore_offset )
byte_ptr	in_buf_strt ;
byte_ptr	word_buff_strt ;
byte_ptr	vocab_strt ;
word		ignore_offset ;
{
	register word		offset ;
	register word		count ;
	register word		num_bytes ;
	register byte_ptr	in_buf_end ;
	register byte_ptr	wd_ptr ;
	byte_ptr			char_ptr ;
	word				coded[PLUS_ENCODED_SIZE] ;

	init_vocab ( vocab_strt ) ;
	char_ptr = in_buf_strt + 1 ;
	num_bytes = *char_ptr++ ;
	in_buf_end = char_ptr + num_bytes ;
	wd_ptr = word_buff_strt + 1 ;
	*wd_ptr++ = 0 ;

	while (( num_bytes = (byte)( in_buf_end - char_ptr )) != 0 )
	{
		if (( count = get_code ( &char_ptr,num_bytes,coded )) == 0 )
			return ;

		if ( *(word_buff_strt + 1) == *word_buff_strt )
		{
			display ( "Too many words typed. Flushing: " ) ;
			*in_buf_end = 0 ;
			display ( (char *)char_ptr ) ;
			new_line () ;
			return ;
		}

		++(*(word_buff_strt + 1)) ;
		offset = look_up ( coded,PLUS_ENCODED_SIZE ) ;
		if (( offset != 0 ) || ( ignore_offset == 0 ))
		{
			*(wd_ptr + 1) = (byte)offset ;
			*wd_ptr = (byte)(offset >> 8) ;
		}
		*( wd_ptr + 2 ) = (byte)count ;
		*( wd_ptr + 3 ) = (byte)(char_ptr - in_buf_strt) ;
		wd_ptr += 4 ;
		char_ptr += count ;
	}
}
