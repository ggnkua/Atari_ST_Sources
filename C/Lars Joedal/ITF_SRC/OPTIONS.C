/*
**	File:	options.c
**
**	(C)opyright 1987-1992 InfoTaskforce.
*/

#include	"infocom.h"

#define		MAX_CHARS_PER_WORD	(PLUS_CHARS_PER_WORD)
/*
#define		VOCAB_BUFFER_SIZE	(MAX_CHARS_PER_WORD+3)
*/
#define		VOCAB_BUFFER_SIZE	((word)(0x09+3))
#define		VOCAB1_BUFFER_SIZE	((word)(0x09+4))
#define		BYTE_DISPLAY(x)		hex_digit((x),2)

char		vocab_buffer[VOCAB1_BUFFER_SIZE] ;
char		*vocab_ptr ;

Void
options ( opt )
word	opt ;
{
	extern header	data_head ;

	init_print () ;
	if ( opt & HEAD_INFO )
		show_header () ;
	if ( opt & ( VOCABULARY | EXTENDED_VOCAB ) )
		show_vocab ( opt ) ;
	if ( opt & OBJECTS )
		show_objects ( data_head.z_code_version,opt ) ;
	if ( opt & TREE )
		show_tree ( data_head.z_code_version ) ;
}

Void
print_item ( s,n )
char	*s ;
word	n ;
{
	display ( s ) ;
	hex_display ( n ) ;
	new_line () ;
}

Void
show_header ()
{
	extern header	data_head ;
	extern proc_ptr	PrintChar ;

	word			i ;

	/*
	**	We use 'new_line()' to get a new line so that
	**	the "**MORE**" facility will be used.
	*/

	display ( "INFOCOM Data File Header." ) ;
	new_line () ;
	new_line () ;
	print_item ( "Z-Code Version: $",(word)data_head.z_code_version ) ;
	new_line () ;
	if ( data_head.mode_bits & USE_TIME )
		display ( "Score/Time    : Time" ) ;
	else
		display ( "Score/Time    : Score" ) ;
	new_line () ;
	print_item ( "Mode Bits     : $",(word)data_head.mode_bits ) ;
	print_item ( "Release Number: $",data_head.release ) ;
	print_item ( "Resident Bytes: $",data_head.resident_bytes ) ;
	print_item ( "Start Address : $",data_head.start ) ;
	print_item ( "Vocab Address : $",data_head.vocab ) ;
	print_item ( "Object List   : $",data_head.object_list ) ;
	print_item ( "Global Vars.  : $",data_head.globals ) ;
	print_item ( "Save Bytes    : $",data_head.save_bytes ) ;
	print_item ( "Script Status : $",data_head.script_status ) ;
	if ( data_head.script_status == 0 )
		display ( "Script Status : Off" ) ;
	else
		display ( "Script Status : On" ) ;
	new_line () ;
	display ( "Serial Number : " ) ;
	for ( i = 0 ; i < 6 ; i++ )
		(*PrintChar) ( (word)data_head.serial_no[i] ) ;
	new_line () ;
	print_item ( "Common Words  : $",data_head.common_word ) ;
	print_item ( "Verify Length : $",data_head.verify_length ) ;
	print_item ( "Verify Check  : $",data_head.verify_checksum ) ;
	new_line () ;
	new_line () ;
}

Void
print_word ( ch )
word	ch ;
{
	extern char		*vocab_ptr ;

	*vocab_ptr++ = (char)ch ;
}

Void
show_vocab ( opt )
word	opt ;
{
	extern header		data_head ;
	extern word			num_vocab_words ;
	extern word			vocab_entry_size ;
	extern word			strt_vocab_table ;
	extern byte_ptr		base_ptr ;
	extern proc_ptr		PrintChar ;
	extern char			vocab_buffer[] ;
	extern char			*vocab_ptr ;
	extern int			screen_width ;
	extern int			print_mode ;
	extern int			single_mode ;
	extern Void			print_word () ;

	proc_ptr			old_printchar ;
	byte_ptr			ptr ;
	word				page ;
	word				offset ;
	word				count ;
	int					words_per_line ;
	int					i ;

	display ( "INFOCOM Adventure - Vocab List." ) ;
	new_line () ;
	new_line () ;
	print_item ( "Number of Words: $",num_vocab_words ) ;
	new_line () ;

	old_printchar = PrintChar ;
	PrintChar = print_word ;
	vocab_ptr = vocab_buffer ;
	for ( i = 0 ; i < (int)VOCAB_BUFFER_SIZE ; i++ )
		*vocab_ptr++ = ' ' ;
	*vocab_ptr = '\0' ;

	words_per_line = screen_width / (int)VOCAB_BUFFER_SIZE ;
	count = 0 ;
	ptr = base_ptr + strt_vocab_table ;
	while ( count < num_vocab_words )
	{
		page = ( ptr - base_ptr ) / (int)BLOCK_SIZE ;
		offset = ( ptr - base_ptr ) % (int)BLOCK_SIZE ;

		print_mode = single_mode = 0 ;
		vocab_ptr = vocab_buffer ;
		if ( data_head.z_code_version <= VERSION_3 )
		{
			for ( i = 0 ; i < (int)STD_ENCODED_SIZE ; i++ )
				decode ( get_word ( &page,&offset ) ) ;
		}
		else
		{
			for ( i = 0 ; i < (int)PLUS_ENCODED_SIZE ; i++ )
				decode ( get_word ( &page,&offset ) ) ;
		}
		while ( *vocab_ptr != '\0' )
			*vocab_ptr++ = ' ' ;
		display ( vocab_buffer ) ;

		if ( opt & EXTENDED_VOCAB )
		{
			if ( data_head.z_code_version <= VERSION_3 )
			{
				for (i = 0; i < (int)(vocab_entry_size - (STD_ENCODED_SIZE * 2)); i++)
				{
					display ( "\t$" ) ;
					BYTE_DISPLAY ( get_byte ( &page,&offset ) ) ;
				}
			}
			else
			{
				for (i = 0; i < (int)(vocab_entry_size - (PLUS_ENCODED_SIZE * 2)); i++)
				{
					display ( "\t$" ) ;
					BYTE_DISPLAY ( get_byte ( &page,&offset ) ) ;
				}
			}
			++count ;
			new_line () ;
		}
		else
		{
			if ( ((int)++count % words_per_line) == 0 )
				new_line () ;
		}

		ptr += vocab_entry_size ;
	}
	new_line () ;
	new_line () ;
	PrintChar = old_printchar ;
}

boolean
prop_name ( obj_num )
word	obj_num ;
{
	extern header			data_head ;
	extern byte_ptr			base_ptr ;
	extern std_object_ptr	std_obj_list ;
	extern plus_object_ptr	plus_obj_list ;

	std_object_ptr			std_obj ;
	plus_object_ptr			plus_obj ;
	byte_ptr				p ;

	if ( data_head.z_code_version <= VERSION_3 )
	{
		std_obj = STD_OBJ_ADDR ( obj_num ) ;
		p = base_ptr + ((word)(std_obj -> prop_ptr[0]) << 8) + (std_obj -> prop_ptr[1]) ;
		if ( *p )
			return ( TRUE ) ;
	}
	else
	{
		plus_obj = PLUS_OBJ_ADDR ( obj_num ) ;
		p = base_ptr + ((word)(plus_obj -> prop_ptr[0]) << 8) + (plus_obj -> prop_ptr[1]) ;
		if ( *p )
			return ( TRUE ) ;
	}
	return ( FALSE ) ;
}

Void
show_std_props ( obj_num )
word	obj_num ;
{
	extern std_object_ptr	std_obj_list ;
	extern property			std_prop_addr () ;

	property				p ;
	byte					p_num ;
	byte					p_len ;

	new_line () ;
	p = std_prop_addr ( STD_OBJ_ADDR ( obj_num ) ) ;
	while ( ( p_num = STD_PROPERTY_NUMBER ( p ) ) != 0 )
	{
		p_len = STD_PROPERTY_LENGTH ( p ) ;
		++p ;
		display ( "\t -> property   : $" ) ;
		BYTE_DISPLAY ( p_num ) ;
		display ( " [" ) ;
		while ( p_len-- )
		{
			display ( " $" ) ;
			BYTE_DISPLAY ( *p++ ) ;
		}
		display ( " ]" ) ;
		new_line () ;
	}
}

Void
show_plus_props ( obj_num )
word	obj_num ;
{
	extern plus_object_ptr	plus_obj_list ;
	extern property			plus_prop_addr () ;

	property				p ;
	byte					p_num ;
	byte					p_len ;
	byte					mode ;

	new_line () ;
	p = plus_prop_addr ( PLUS_OBJ_ADDR ( obj_num ) ) ;
	while ( ( p_num = PLUS_PROPERTY_NUMBER ( p ) ) != 0 )
	{
		mode = *p++ ;
		if ( mode & NEXT_BYTE_IS_LENGTH )
			p_len = PLUS_PROPERTY_LENGTH ( p++ ) ;
		else
		{
			if ( mode & PLUS_WORD_MASK )
				p_len = 2 ;
			else
				p_len = 1 ;
		}
		display ( "\t -> property   : $" ) ;
		BYTE_DISPLAY ( p_num ) ;
		display ( " [" ) ;
		while ( p_len-- )
		{
			display ( " $" ) ;
			BYTE_DISPLAY ( *p++ ) ;
		}
		display ( " ]" ) ;
		new_line () ;
	}
}

Void
show_objects ( version,opt )
byte	version ;
word	opt ;
{
	extern header				data_head ;
	extern std_object_ptr		std_obj_list ;
	extern plus_object_ptr		plus_obj_list ;
	extern byte_ptr				base_ptr ;

	register std_object_ptr		std_obj ;
	register plus_object_ptr	plus_obj ;
	word						i,j ;
	int							n_objs ;

	display ( "INFOCOM Adventure - Object List." ) ;
	new_line () ;
	new_line () ;
	if ( data_head.z_code_version <= VERSION_3 )
	{
		std_obj = STD_OBJ_ADDR ( 1 ) ;
		n_objs = (( std_obj -> prop_ptr[0] << BITS_PER_BYTE ) + std_obj -> prop_ptr[1] - ( (byte_ptr)std_obj - base_ptr )) / (unsigned int)STD_OBJ_SIZE ;
	}
	else
	{
		plus_obj = PLUS_OBJ_ADDR ( 1 ) ;
		n_objs = (( plus_obj -> prop_ptr[0] << BITS_PER_BYTE ) + plus_obj -> prop_ptr[1] - ( (byte_ptr)plus_obj - base_ptr )) / (unsigned int)PLUS_OBJ_SIZE ;
	}
	print_item ( "Number of Objects: $",(word)n_objs ) ;
	new_line () ;
	for ( i = 1 ; i <= (word)n_objs ; i++ )
	{
		display ( "Object $" ) ;
		hex_display ( i ) ;
		display ( " : " ) ;

		if ( version <= VERSION_3 )
		{
			if ( prop_name ( i ) )
				std_p_obj ( i ) ;
			else
				display ( "<No Name>" ) ;
			new_line () ;
			display ( "\t -> attributes : " ) ;
			std_obj = STD_OBJ_ADDR ( i ) ;
			for ( j = 0 ; j < 4 ; j++ )
				bit_byte ( std_obj -> attributes[j] ) ;
			new_line () ;
			print_item ( "\t -> location   : $",(word)std_obj -> location[0] ) ;
			print_item ( "\t -> link       : $",(word)std_obj -> link[0] ) ;
			print_item ( "\t -> holds      : $",(word)std_obj -> holds[0] ) ;
			print_item ( "\t -> prop_ptr   : $",(word)((std_obj -> prop_ptr[0] << BITS_PER_BYTE) | (std_obj -> prop_ptr[1])) ) ;
			if ( opt & SHOW_PROPS )
				show_std_props ( i ) ;
		}
		else
		{
			if ( prop_name ( i ) )
				plus_p_obj ( i ) ;
			else
				display ( "<No Name>" ) ;
			new_line () ;
			display ( "\t -> attributes : " ) ;
			plus_obj = PLUS_OBJ_ADDR ( i ) ;
			for ( j = 0 ; j < 6 ; j++ )
				bit_byte ( plus_obj -> attributes[j] ) ;
			new_line () ;
			print_item ( "\t -> location   : $",(word)((plus_obj -> location[0] << BITS_PER_BYTE) | (plus_obj -> location[1])) ) ;
			print_item ( "\t -> link       : $",(word)((plus_obj -> link[0] << BITS_PER_BYTE) | (plus_obj -> link[1])) ) ;
			print_item ( "\t -> holds      : $",(word)((plus_obj -> holds[0] << BITS_PER_BYTE) | (plus_obj -> holds[1])) ) ;
			print_item ( "\t -> prop_ptr   : $",(word)((plus_obj -> prop_ptr[0] << BITS_PER_BYTE) | (plus_obj -> prop_ptr[1])) ) ;
			if ( opt & SHOW_PROPS )
				show_plus_props ( i ) ;
		}
		new_line () ;
	}
}

Void
bit_byte ( bits )
byte	bits ;
{
	register byte	i ;

	for ( i = FIRST_ATTRIBUTE ; i ; i >>= 1 )
		out_char( bits & i ? '1' : '0' ) ;
	out_char( ' ' ) ;
}

Void
show_tree ( version )
byte	version ;
{
	extern header				data_head ;
	extern std_object_ptr		std_obj_list ;
	extern plus_object_ptr		plus_obj_list ;
	extern byte_ptr				base_ptr ;

	register std_object_ptr		std_obj ;
	register plus_object_ptr	plus_obj ;
	word						location ;
	word						i ;
	int							n_objs ;

	display ( "INFOCOM Adventure - Object Tree." ) ;
	new_line () ;
	new_line () ;
	if ( data_head.z_code_version <= VERSION_3 )
	{
		std_obj = STD_OBJ_ADDR ( 1 ) ;
		n_objs = (( std_obj -> prop_ptr[0] << BITS_PER_BYTE ) + std_obj -> prop_ptr[1] - ( (byte_ptr)std_obj - base_ptr )) / (unsigned int)STD_OBJ_SIZE ;
	}
	else
	{
		plus_obj = PLUS_OBJ_ADDR ( 1 ) ;
		n_objs = (( plus_obj -> prop_ptr[0] << BITS_PER_BYTE ) + plus_obj -> prop_ptr[1] - ( (byte_ptr)plus_obj - base_ptr )) / (unsigned int)PLUS_OBJ_SIZE ;
	}
	print_item ( "Number of Objects: $",(word)n_objs ) ;
	new_line () ;
	new_line () ;
	for ( i = 1 ; i <= (word)n_objs ; i++ )
	{
		if ( version <= VERSION_3 )
		{
			std_obj = STD_OBJ_ADDR ( i ) ;
			location = (word)( std_obj -> location[0] ) ;
		}
		else
		{
			plus_obj = PLUS_OBJ_ADDR ( i ) ;
			location = ( plus_obj -> location[0] << BITS_PER_BYTE ) | ( plus_obj -> location[1] ) ;
		}
		if ( location == 0 )
		{
			obtree ( version,i,0 ) ;
			new_line () ;
		}
	}
}

Void
obtree ( version,o1,level )
byte	version ;
word	o1 ;
int		level ;
{
	extern std_object_ptr		std_obj_list ;
	extern plus_object_ptr		plus_obj_list ;

	register std_object_ptr		std_obj ;
	register plus_object_ptr	plus_obj ;
	register word				temp ;
	int							i ;

	for ( i = level ; i ; i-- )
		out_char( '\t' ) ;
	display ( "$" ) ;
	hex_display ( o1 ) ;
	display ( " : " ) ;

	if ( version <= VERSION_3 )
	{
		if ( prop_name ( o1 ) )
			std_p_obj ( o1 ) ;
		else
			display ( "<No Name>" ) ;
		new_line () ;
		std_obj = STD_OBJ_ADDR ( o1 ) ;
		if ( std_obj -> holds[0] )
			obtree ( version,(word)( std_obj -> holds[0] ),level + 1 ) ;
		if ( std_obj -> link[0] )
			obtree ( version,(word)( std_obj -> link[0] ),level ) ;
	}
	else
	{
		if ( prop_name ( o1 ) )
			plus_p_obj ( o1 ) ;
		else
			display ( "<No Name>" ) ;
		new_line () ;
		plus_obj = PLUS_OBJ_ADDR ( o1 ) ;
		temp = ( plus_obj -> holds[0] << BITS_PER_BYTE ) | ( plus_obj -> holds[1] ) ;
		if ( temp )
			obtree ( version,temp,level+1 ) ;
		temp = ( plus_obj -> link[0] << BITS_PER_BYTE ) | ( plus_obj -> link[1] ) ;
		if ( temp )
			obtree ( version,temp,level ) ;
	}
}
