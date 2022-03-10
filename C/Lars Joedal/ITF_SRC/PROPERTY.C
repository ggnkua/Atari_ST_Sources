/*
**	File:	property.c
**
**	(C)opyright 1987-1992 InfoTaskforce.
*/

#include	"infocom.h"

property
std_prop_addr ( obj )
std_object_ptr		obj ;
{
	extern byte_ptr		base_ptr ;

	register property	p ;

	p = base_ptr + ((word)(obj -> prop_ptr[0]) << 8) + (obj -> prop_ptr[1]) ;
	return ( p + (*p << 1) + 1 ) ;
}

property
plus_prop_addr ( obj )
plus_object_ptr		obj ;
{
	extern byte_ptr		base_ptr ;

	register property	p ;

	p = base_ptr + ((word)(obj -> prop_ptr[0]) << 8) + (obj -> prop_ptr[1]) ;
	return ( p + (*p << 1) + 1 ) ;
}

property
std_next_addr ( p )
register property	p ;
{
	return ( p + STD_PROPERTY_LENGTH ( p ) + 1 ) ;
}

property
plus_next_addr ( p )
register property	p ;
{
	register byte	mode ;

	mode = *p++ ;
	if ( ( mode & NEXT_BYTE_IS_LENGTH ) == 0 )
	{
		if ( mode & PLUS_WORD_MASK )
			++p ;
		return ( ++p ) ;
	}
	return ( p + PLUS_PROPERTY_LENGTH ( p ) + 1 ) ;
}

Void
std_getprop ( obj_num,prop_num )
word	obj_num ;
word	prop_num ;
{
	extern std_object_ptr	std_obj_list ;

	register property		p ;
	register word			p_num ;
	register word			prop ;

	p = std_prop_addr ( STD_OBJ_ADDR ( obj_num )) ;
	p_num = STD_PROPERTY_NUMBER ( p ) ;

	/*
	**	Properties are kept in descending order
	*/

	while ( p_num > prop_num )
	{
		p = std_next_addr ( p ) ;
		p_num = STD_PROPERTY_NUMBER ( p ) ;
	}
	if ( p_num < prop_num )
	{
		p = (property) std_obj_list + (( --prop_num ) << 1 ) ;
		prop = (*p++) << 8 ;
		prop += *p ;
	}
	else
	{
		if ( (*p++) & STD_WORD_MASK )
		{
			prop = (*p++) << 8 ;
			prop += *p ;
		}
		else
			prop = *p ;
	}
	store ( prop ) ;
}

Void
plus_getprop ( obj_num,prop_num )
word	obj_num ;
word	prop_num ;
{
	extern plus_object_ptr	plus_obj_list ;

	register property		p ;
	register word			p_num ;
	register word			prop ;

	p = plus_prop_addr ( PLUS_OBJ_ADDR ( obj_num )) ;
	p_num = PLUS_PROPERTY_NUMBER ( p ) ;

	/*
	**	Properties are kept in descending order
	*/

	while ( p_num > prop_num )
	{
		p = plus_next_addr ( p ) ;
		p_num = PLUS_PROPERTY_NUMBER ( p ) ;
	}
	if ( p_num < prop_num )
	{
		p = (property) plus_obj_list + (( --prop_num ) << 1 ) ;
		prop = (*p++) << 8 ;
		prop += *p ;
	}
	else
	{
		if ( (*p++) & PLUS_WORD_MASK )
		{
			prop = (*p++) << 8 ;
			prop += *p ;
		}
		else
			prop = *p ;
	}
	store ( prop ) ;
}

Void
std_put_prop ( obj_num,prop_num,value )
word	obj_num ;
word	prop_num ;
word	value ;
{
	extern std_object_ptr	std_obj_list ;

	register property		p ;
	register word			p_num ;

	p = std_prop_addr ( STD_OBJ_ADDR ( obj_num )) ;
	p_num = STD_PROPERTY_NUMBER ( p ) ;

	/*
	**	Properties are kept in descending order
	*/

	while ( p_num > prop_num )
	{
		p = std_next_addr ( p ) ;
		p_num = STD_PROPERTY_NUMBER ( p ) ;
	}
	if ( p_num < prop_num )
		error ( ERR_PUT_PROP ) ;
	else
	{
		if ( (*p++) & STD_WORD_MASK )
		{
			*p++ = value >> 8 ;
			*p = value ;
		}
		else
			*p = value ;
	}
}

Void
plus_put_prop ( obj_num,prop_num,value )
word	obj_num ;
word	prop_num ;
word	value ;
{
	extern plus_object_ptr	plus_obj_list ;

	register property		p ;
	register word			p_num ;

	p = plus_prop_addr ( PLUS_OBJ_ADDR ( obj_num )) ;
	p_num = PLUS_PROPERTY_NUMBER ( p ) ;

	/*
	**	Properties are kept in descending order
	*/

	while ( p_num > prop_num )
	{
		p = plus_next_addr ( p ) ;
		p_num = PLUS_PROPERTY_NUMBER ( p ) ;
	}
	if ( p_num < prop_num )
		error ( ERR_PUT_PROP ) ;
	else
	{
		if ( (*p++) & PLUS_WORD_MASK )
		{
			*p++ = value >> 8 ;
			*p = value ;
		}
		else
			*p = value ;
	}
}

Void
std_get_next_prop ( obj_num,prop_num )
word	obj_num ;
word	prop_num ;
{
	extern std_object_ptr	std_obj_list ;

	register property		p ;
	register word			p_num ;

	p = std_prop_addr ( STD_OBJ_ADDR ( obj_num )) ;
	if ( prop_num != 0 )
	{
		p_num = STD_PROPERTY_NUMBER ( p ) ;

		/*
		**	Properties are kept in descending order
		*/

		while ( p_num > prop_num )
		{
			p = std_next_addr ( p ) ;
			p_num = STD_PROPERTY_NUMBER ( p ) ;
		}
		if ( p_num < prop_num )
			error ( ERR_NEXT_PROP ) ;
		else
			p = std_next_addr ( p ) ;
	}
	store ( (word) STD_PROPERTY_NUMBER ( p ) ) ;
}

Void
plus_get_next_prop ( obj_num,prop_num )
word	obj_num ;
word	prop_num ;
{
	extern plus_object_ptr	plus_obj_list ;

	register property		p ;
	register word			p_num ;

	p = plus_prop_addr ( PLUS_OBJ_ADDR ( obj_num )) ;
	if ( prop_num != 0 )
	{
		p_num = PLUS_PROPERTY_NUMBER ( p ) ;

		/*
		**	Properties are kept in descending order
		*/

		while ( p_num > prop_num )
		{
			p = plus_next_addr ( p ) ;
			p_num = PLUS_PROPERTY_NUMBER ( p ) ;
		}
		if ( p_num < prop_num )
			error ( ERR_NEXT_PROP ) ;
		else
			p = plus_next_addr ( p ) ;
	}
	store ( (word) PLUS_PROPERTY_NUMBER ( p ) ) ;
}

Void
load_word_array ( base,offset )
register word	base ;
register word	offset ;
{
	word	page ;
	word	page_offset ;

	base += (word)( offset << 1 ) ;
	page = base / BLOCK_SIZE ;
	page_offset = base % BLOCK_SIZE ;
	store ( get_word ( &page,&page_offset ) ) ;
}

Void
load_byte_array ( base,offset )
register word	base ;
register word	offset ;
{
	word	page ;
	word	page_offset ;

	base += offset ;
	page = base / BLOCK_SIZE ;
	page_offset = base % BLOCK_SIZE ;
	store ( (word)get_byte ( &page,&page_offset ) ) ;
}

Void
save_word_array ( base,offset,value )
word	base ;
word	offset ;
word	value ;
{
	extern byte_ptr		base_ptr ;

	register byte_ptr	ptr ;

	ptr = base_ptr + (word)( base + (word)( offset << 1 ) ) ;
	*ptr++ = value >> 8 ;
	*ptr = value ;
}

Void
save_byte_array ( base,offset,value )
word	base ;
word	offset ;
word	value ;
{
	extern byte_ptr		base_ptr ;

	register byte_ptr	ptr ;

	ptr = base_ptr + (word)( base + offset ) ;
	*ptr = value ;
}

Void
std_get_prop_addr ( obj_num,prop_num )
word	obj_num ;
word	prop_num ;
{
	extern byte_ptr			base_ptr ;
	extern std_object_ptr	std_obj_list ;

	register property		p ;
	register word			p_num ;

	p = std_prop_addr ( STD_OBJ_ADDR ( obj_num )) ;
	p_num = STD_PROPERTY_NUMBER ( p ) ;

	/*
	**	Properties are kept in descending order
	*/

	while ( p_num > prop_num )
	{
		p = std_next_addr ( p ) ;
		p_num = STD_PROPERTY_NUMBER ( p ) ;
	}
	if ( p_num < prop_num )
		store ( (word)0 ) ;
	else
		store ( (word)(p + 1 - base_ptr) ) ;
}

Void
plus_get_prop_addr ( obj_num,prop_num )
word	obj_num ;
word	prop_num ;
{
	extern byte_ptr			base_ptr ;
	extern plus_object_ptr	plus_obj_list ;

	register property		p ;
	register word			p_num ;

	p = plus_prop_addr ( PLUS_OBJ_ADDR ( obj_num )) ;
	p_num = PLUS_PROPERTY_NUMBER ( p ) ;

	/*
	**	Properties are kept in descending order
	*/

	while ( p_num > prop_num )
	{
		p = plus_next_addr ( p ) ;
		p_num = PLUS_PROPERTY_NUMBER ( p ) ;
	}
	if ( p_num < prop_num )
		store ( (word)0 ) ;
	else
	{
		if ( ( *p & NEXT_BYTE_IS_LENGTH ) != 0 )
			++p ;
		store ( (word)(p + 1 - base_ptr) ) ;
	}
}

Void
std_get_p_len ( prop_num )
word	prop_num;
{
	extern byte_ptr		base_ptr ;

	register property	p ;

	p = base_ptr + prop_num - 1 ;
	store ( (word) STD_PROPERTY_LENGTH ( p ) ) ;
}

Void
plus_get_p_len ( prop_num )
word	prop_num;
{
	extern byte_ptr		base_ptr ;

	register property	p ;

	p = base_ptr + prop_num - 1 ;
	if ( ( *p & NEXT_BYTE_IS_LENGTH ) == 0 )
	{
		if ( *p & PLUS_WORD_MASK )
			store ( (word)2 ) ;
		else
			store ( (word)1 ) ;
		return ;
	}
	store ( (word) PLUS_PROPERTY_LENGTH ( p ) ) ;
}
