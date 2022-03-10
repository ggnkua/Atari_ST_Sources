/*
**	File:	support.c
**
**	(C)opyright 1987-1992 InfoTaskforce.
*/

#include	"infocom.h"

Void
null ()
{
	/*
	**	The NULL function
	*/
}

Void
restart ()
{
	extern word			save_blocks ;
	extern byte_ptr		base_ptr ;

	new_line () ;
	load_page ( 0,save_blocks,base_ptr ) ;
	init_interpreter ( TRUE ) ;
}

Void
quit ()
{
	extern boolean	stop ;

	stop = TRUE ;
}

Void
verify ()
{
	extern word		resident_blocks ;
	extern header	data_head ;

	register word	sum ;
	register word	addr_hi ;
	register word	addr_lo ;
	word			page ;
	word			offset ;
	word			save ;

	if ( data_head.z_code_version <= VERSION_3 )
	{
		addr_lo = STD_OFFSET ( data_head.verify_length ) ;
		addr_hi = STD_PAGE ( data_head.verify_length ) ;
	}
	else
	{
		addr_lo = PLUS_OFFSET ( data_head.verify_length ) ;
		addr_hi = PLUS_PAGE ( data_head.verify_length ) ;
	}
	save = resident_blocks ;
	resident_blocks = 0 ;
	page = 0 ;
	offset = sizeof ( header ) ;
	sum = 0 ;
	while (( page != addr_hi ) || ( offset != addr_lo ))
		sum += get_byte ( &page,&offset ) ;

	resident_blocks = save ;
	if ( sum == data_head.verify_checksum )
		ret_value ( TRUE ) ;
	else
		ret_value ( FALSE ) ;
}

Void
store ( value )
word	value ;
{
	extern word		*stack ;

	word			var ;

	var = next_byte () ;
	if ( var == 0 )
		*(--stack) = value ;
	else
		put_var ( var,value ) ;
}

Void
ret_value ( result )
word	result ;
{
	extern word		pc_offset ;

	word	branch ;

	branch = next_byte () ;

	/*
	**	Test bit 7
	*/

	if (( branch & 0x80 ) != 0 )
	{
		/*
		**	Clear bit 7
		*/

		branch &= 0x7F ;
		++result ;
	}

	/*
	**	Test bit 6
	*/

	if (( branch & 0x40 ) == 0 )
	{
		branch = ( branch << BITS_PER_BYTE ) | next_byte () ;

		/*
		**	Test bit D. If set, make branch negative.
		*/

		if ( branch & 0x2000 )
			branch |= 0xC000 ;
	}
	else
	{
		/*
		**	Clear bit 6
		*/

		branch &= 0xBF ;
	}

	if (( --result ) != 0 )
	{
		switch ( branch )
		{
			case 0 :	ret_false () ;
						break ;
			case 1 :	ret_true () ;
						break ;
			default :	pc_offset += ( branch - 2 ) ;
						fix_pc () ;
		}
	}
}

byte
get_byte ( page,offset )
word	*page ;
word	*offset ;
{
	extern word			resident_blocks ;
	extern byte_ptr		base_ptr ;

	byte_ptr			ptr ;

	if ( *page < resident_blocks )
		ptr = base_ptr + ((signed_long)*page * BLOCK_SIZE) + *offset ;
	else
		ptr = fetch_page ( *page ) + *offset ;
	++(*offset) ;
	if ( *offset == BLOCK_SIZE )
	{
		*offset = 0 ;
		++(*page) ;
	}
	return ( *ptr ) ;
}

word
get_word ( page,offset )
word	*page ;
word	*offset ;
{
	word	temp ;

	temp = get_byte ( page,offset ) << BITS_PER_BYTE ;
	return ( temp | get_byte ( page,offset ) ) ;
}

byte
next_byte ()
{
	extern word			pc_offset ;
	extern byte_ptr		prog_block_ptr ;

	register byte_ptr	ptr ;

	ptr = prog_block_ptr + pc_offset++ ;
	if ( pc_offset == BLOCK_SIZE )
		fix_pc () ;
	return ( *ptr ) ;
}

word
next_word ()
{
	word	temp ;

	temp = next_byte () << BITS_PER_BYTE ;
	return ( temp | next_byte () ) ;
}

Void
error ( err_num )
word	err_num ;
{
	char	ch[4] ;

	/*
	**	'err_num' must be between 00 and 99 inclusive.
	**	We can't use print_char or print_num because the print
	**	buffer may not yet have been created or initialised.
	*/

	display ( "\nInternal Error " ) ;
	if ( err_num != ERR_MEMORY )
	{
		ch[0] = '#' ;
		ch[1] = '0' + ( err_num / 10 ) ;
		ch[2] = '0' + ( err_num % 10 ) ;
		ch[3] = 0 ;
		display ( ch ) ;
	}
	display ( "\n" ) ;
	quit () ;
}
