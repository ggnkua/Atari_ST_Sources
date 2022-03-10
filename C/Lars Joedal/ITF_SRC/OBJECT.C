/*
**	File:	object.c
**
**	(C)opyright 1987-1992 InfoTaskforce.
*/

#include	"infocom.h"

Void
std_transfer ( o1,o2 )
word	o1 ;
word	o2 ;
{
	extern std_object_ptr		std_obj_list ;
	extern boolean				xfer ;

	register std_object_ptr		obj1 ;
	register std_object_ptr		obj2 ;

	std_remove_obj ( o1 ) ;
	obj1 = STD_OBJ_ADDR ( o1 ) ;
	obj2 = STD_OBJ_ADDR ( o2 ) ;
	obj1 -> link[0] = obj2 -> holds[0] ;
	obj1 -> location[0] = (byte) o2 ;
	obj2 -> holds[0] = (byte) o1 ;
#ifdef	CHEAT
	if ( xfer )
	{ /* patch level 1 installed  --mlk */
		print_char ( (word)'[' ) ;
		std_p_obj ( o1 ) ;
		print_char ( (word)' ' ) ;
		print_char ( (word)'-' ) ;
		print_char ( (word)'>' ) ;
		print_char ( (word)' ' ) ;
		std_p_obj ( o2 ) ;
		print_char ( (word)']' ) ;
		new_line () ;
	}
#endif	/* CHEAT */
}

Void
plus_transfer ( o1,o2 )
word	o1 ;
word	o2 ;
{
	extern plus_object_ptr		plus_obj_list ;
	extern boolean				xfer ;

	register plus_object_ptr	obj1 ;
	register plus_object_ptr	obj2 ;

	plus_remove_obj ( o1 ) ;
	obj1 = PLUS_OBJ_ADDR ( o1 ) ;
	obj2 = PLUS_OBJ_ADDR ( o2 ) ;
	obj1 -> link[0] = obj2 -> holds[0] ;
	obj1 -> link[1] = obj2 -> holds[1] ;
	obj1 -> location[0] = (byte)( o2 >> BITS_PER_BYTE ) ;
	obj1 -> location[1] = (byte) o2 ;
	obj2 -> holds[0] = (byte)( o1 >> BITS_PER_BYTE ) ;
	obj2 -> holds[1] = (byte) o1 ;
#ifdef	CHEAT
	if ( xfer )
	{ /* patch level 1 installed  -mlk */
		print_char ( (word)'[' ) ;
		plus_p_obj ( o1 ) ;
		print_char ( (word)' ' ) ;
		print_char ( (word)'-' ) ;
		print_char ( (word)'>' ) ;
		print_char ( (word)' ' ) ;
		plus_p_obj ( o2 ) ;
		print_char ( (word)']' ) ;
		new_line () ;
	}
#endif	/* CHEAT */
}

Void
std_remove_obj ( obj_num )
word	obj_num ;
{
	extern std_object_ptr		std_obj_list ;

	register std_object_ptr		obj1 ;
	register std_object_ptr		obj2 ;

	obj1 = STD_OBJ_ADDR ( obj_num ) ;
	if ( obj1 -> location[0] != 0 )
	{
		obj2 = STD_OBJ_ADDR ((word)(obj1 -> location[0])) ;
		if ( obj2 -> holds[0] == (byte)obj_num )
			obj2 -> holds[0] = obj1 -> link[0] ;
		else
		{
			obj2 = STD_OBJ_ADDR ((word)(obj2 -> holds[0])) ;
			while ( obj2 -> link[0] != (byte)obj_num )
				obj2 = STD_OBJ_ADDR ((word)(obj2 -> link[0])) ;
			obj2 -> link[0] = obj1 -> link[0] ;
		}
		obj1 -> location[0] = 0 ;
		obj1 -> link[0] = 0 ;
	}
}

Void
plus_remove_obj ( obj_num )
word	obj_num ;
{
	extern plus_object_ptr		plus_obj_list ;

	register plus_object_ptr	obj1 ;
	register plus_object_ptr	obj2 ;
	register word				temp ;

	obj1 = PLUS_OBJ_ADDR ( obj_num ) ;
	temp = ((obj1 -> location[0]) << BITS_PER_BYTE) | (obj1 -> location[1]) ;
	if ( temp != 0 )
	{
		obj2 = PLUS_OBJ_ADDR ( temp ) ;
		temp = ((obj2 -> holds[0]) << BITS_PER_BYTE) | (obj2 -> holds[1]) ;
		if ( temp == obj_num )
		{
			obj2 -> holds[0] = obj1 -> link[0] ;
			obj2 -> holds[1] = obj1 -> link[1] ;
		}
		else
		{
			temp = ((obj2 -> holds[0]) << BITS_PER_BYTE) | (obj2 -> holds[1]) ;
			obj2 = PLUS_OBJ_ADDR ( temp ) ;
			temp = ((obj2 -> link[0]) << BITS_PER_BYTE) | (obj2 -> link[1]) ;
			while ( temp != obj_num )
			{
				obj2 = PLUS_OBJ_ADDR ( temp ) ;
				temp = ((obj2 -> link[0]) << BITS_PER_BYTE) | (obj2 -> link[1]);
			}
			obj2 -> link[0] = obj1 -> link[0] ;
			obj2 -> link[1] = obj1 -> link[1] ;
		}
		obj1 -> location[0] = 0 ;
		obj1 -> location[1] = 0 ;
		obj1 -> link[0] = 0 ;
		obj1 -> link[1] = 0 ;
	}
}

Void
std_test_attr ( obj_num,attr )
word	obj_num ;
word	attr ;
{
	extern std_object_ptr		std_obj_list ;
	extern boolean				attribute ;

	register std_object_ptr		obj ;
	register byte				attr_bit ;
	register int				i ;

	obj = STD_OBJ_ADDR ( obj_num ) ;
	attr_bit = FIRST_ATTRIBUTE ;
	for ( i = 0 ; i < (int)(attr % BITS_PER_BYTE) ; i++ )
		attr_bit >>= 1 ;
#ifdef	CHEAT
	if ( attribute )
	{ /* patch level 1 installed  --mlk */
		print_char ( (word)'[' ) ;
		std_p_obj ( obj_num ) ;
		print_char ( (word)'(' ) ;
		print_num ( attr ) ;
		print_char ( (word)')' ) ;
		print_char ( (word)' ' ) ;
		print_char ( (word)'=' ) ;
		print_char ( (word)'=' ) ;
		print_char ( (word)' ' ) ;
		if ( obj -> attributes[attr / BITS_PER_BYTE] & attr_bit )
			print_num ( 1 ) ;
		else
			print_num ( 0 ) ;
		print_char ( (word)']' ) ;
		new_line () ;
	}
#endif	/* CHEAT */
	if ( obj -> attributes[attr / BITS_PER_BYTE] & attr_bit )
		ret_value ( TRUE ) ;
	else
		ret_value ( FALSE ) ;
}

Void
plus_test_attr ( obj_num,attr )
word	obj_num ;
word	attr ;
{
	extern plus_object_ptr		plus_obj_list ;
	extern boolean				attribute ;

	register plus_object_ptr	obj ;
	register byte				attr_bit ;
	register int				i ;

	obj = PLUS_OBJ_ADDR ( obj_num ) ;
	attr_bit = FIRST_ATTRIBUTE ;
	for ( i = 0 ; i < (int)(attr % BITS_PER_BYTE) ; i++ )
		attr_bit >>= 1 ;
#ifdef	CHEAT
	if ( attribute )
	{ /* patch level 1 installed  -mlk */
		print_char ( (word)'[' ) ;
		plus_p_obj ( obj_num ) ;
		print_char ( (word)'(' ) ;
		print_num ( attr ) ;
		print_char ( (word)')' ) ;
		print_char ( (word)' ' ) ;
		print_char ( (word)'=' ) ;
		print_char ( (word)'=' ) ;
		print_char ( (word)' ' ) ;
		if ( obj -> attributes[attr / BITS_PER_BYTE] & attr_bit )
			print_num ( 1 ) ;
		else
			print_num ( 0 ) ;
		print_char ( (word)']' ) ;
		new_line () ;
	}
#endif	/* CHEAT */
	if ( obj -> attributes[attr / BITS_PER_BYTE] & attr_bit )
		ret_value ( TRUE ) ;
	else
		ret_value ( FALSE ) ;
}

Void
std_set_attr ( obj_num,attr )
word	obj_num ;
word	attr ;
{
	extern std_object_ptr		std_obj_list ;
	extern boolean				attribute ;

	register std_object_ptr		obj ;
	register byte				attr_bit ;
	register int				i ;

	obj = STD_OBJ_ADDR ( obj_num ) ;
	attr_bit = FIRST_ATTRIBUTE ;
	for ( i = 0 ; i < (int)(attr % BITS_PER_BYTE) ; i++ )
		attr_bit >>= 1 ;
	obj -> attributes[attr / BITS_PER_BYTE] |= attr_bit ;
#ifdef	CHEAT
	if ( attribute )
	{ /* patch level 1 installed  -mlk */
		print_char ( (word)'[' ) ;
		std_p_obj ( obj_num ) ;
		print_char ( (word)'(' ) ;
		print_num ( attr ) ;
		print_char ( (word)')' ) ;
		print_char ( (word)' ' ) ;
		print_char ( (word)':' ) ;
		print_char ( (word)'=' ) ;
		print_char ( (word)' ' ) ;
		print_num ( 1 ) ;
		print_char ( (word)']' ) ;
		new_line () ;
	}
#endif	/* CHEAT */
}

Void
plus_set_attr ( obj_num,attr )
word	obj_num ;
word	attr ;
{
	extern plus_object_ptr		plus_obj_list ;
	extern boolean				attribute ;

	register plus_object_ptr	obj ;
	register byte				attr_bit ;
	register int				i ;

	obj = PLUS_OBJ_ADDR ( obj_num ) ;
	attr_bit = FIRST_ATTRIBUTE ;
	for ( i = 0 ; i < (int)(attr % BITS_PER_BYTE) ; i++ )
		attr_bit >>= 1 ;
	obj -> attributes[attr / BITS_PER_BYTE] |= attr_bit ;
#ifdef	CHEAT
	if ( attribute )
	{ /* patch level 1 installed  -mlk */
		print_char ( (word)'[' ) ;
		plus_p_obj ( obj_num ) ;
		print_char ( (word)'(' ) ;
		print_num ( attr ) ;
		print_char ( (word)')' ) ;
		print_char ( (word)' ' ) ;
		print_char ( (word)':' ) ;
		print_char ( (word)'=' ) ;
		print_char ( (word)' ' ) ;
		print_num ( 1 ) ;
		print_char ( (word)']' ) ;
		new_line () ;
	}
#endif	/* CHEAT */
}

Void
std_clr_attr ( obj_num,attr )
word	obj_num ;
word	attr ;
{
	extern std_object_ptr		std_obj_list ;
	extern boolean				attribute ;

	register std_object_ptr		obj ;
	register byte				attr_bit ;
	register int				i ;

	obj = STD_OBJ_ADDR ( obj_num ) ;
	attr_bit = FIRST_ATTRIBUTE ;
	for ( i = 0 ; i < (int)(attr % BITS_PER_BYTE) ; i++ )
		attr_bit >>= 1 ;
	obj -> attributes[attr / BITS_PER_BYTE] &= ( ~attr_bit ) ;
#ifdef	CHEAT
	if ( attribute )
	{ /* patch level 1 installed  -mlk */
		print_char ( (word)'[' ) ;
		std_p_obj ( obj_num ) ;
		print_char ( (word)'(' ) ;
		print_num ( attr ) ;
		print_char ( (word)')' ) ;
		print_char ( (word)' ' ) ;
		print_char ( (word)':' ) ;
		print_char ( (word)'=' ) ;
		print_char ( (word)' ' ) ;
		print_num ( 0 ) ;
		print_char ( (word)']' ) ;
		new_line () ;
	}
#endif	/* CHEAT */
}

Void
plus_clr_attr ( obj_num,attr )
word	obj_num ;
word	attr ;
{
	extern plus_object_ptr		plus_obj_list ;
	extern boolean				attribute ;

	register plus_object_ptr	obj ;
	register byte				attr_bit ;
	register int				i ;

	obj = PLUS_OBJ_ADDR ( obj_num ) ;
	attr_bit = FIRST_ATTRIBUTE ;
	for ( i = 0 ; i < (int)(attr % BITS_PER_BYTE) ; i++ )
		attr_bit >>= 1 ;
	obj -> attributes[attr / BITS_PER_BYTE] &= ( ~attr_bit ) ;
#ifdef	CHEAT
	if ( attribute )
	{ /* level 1 patch installed  -mlk */
		print_char ( (word)'[' ) ;
		plus_p_obj ( obj_num ) ;
		print_char ( (word)'(' ) ;
		print_num ( attr ) ;
		print_char ( (word)')' ) ;
		print_char ( (word)' ' ) ;
		print_char ( (word)':' ) ;
		print_char ( (word)'=' ) ;
		print_char ( (word)' ' ) ;
		print_num ( 0 ) ;
		print_char ( (word)']' ) ;
		new_line () ;
	}
#endif	/* CHEAT */
}

Void
std_get_loc ( obj_num )
word	obj_num ;
{
	extern std_object_ptr		std_obj_list ;

	register std_object_ptr		obj ;

	obj = STD_OBJ_ADDR ( obj_num ) ;
	store ((word)(obj -> location[0])) ;
}

Void
plus_get_loc ( obj_num )
word	obj_num ;
{
	extern plus_object_ptr		plus_obj_list ;

	register plus_object_ptr	obj ;

	obj = PLUS_OBJ_ADDR ( obj_num ) ;
	store ((word)((obj -> location[0]) << BITS_PER_BYTE )|(obj -> location[1]));
}

Void
std_get_holds ( obj_num )
word	obj_num ;
{
	extern std_object_ptr		std_obj_list ;

	register std_object_ptr		obj ;
	register word				temp ;

	obj = STD_OBJ_ADDR ( obj_num ) ;
	temp = (word)( obj -> holds[0] ) ;
	store ( temp ) ;
	if ( temp )
		ret_value ( TRUE ) ;
	else
		ret_value ( FALSE ) ;
}

Void
plus_get_holds ( obj_num )
word	obj_num ;
{
	extern plus_object_ptr		plus_obj_list ;

	register plus_object_ptr	obj ;
	register word				temp ;

	obj = PLUS_OBJ_ADDR ( obj_num ) ;
	temp = ((obj -> holds[0]) << BITS_PER_BYTE ) | (obj -> holds[1]) ;
	store ( temp ) ;
	if ( temp )
		ret_value ( TRUE ) ;
	else
		ret_value ( FALSE ) ;
}

Void
std_get_link ( obj_num )
word	obj_num ;
{
	extern std_object_ptr		std_obj_list ;

	register std_object_ptr		obj ;
	register word				temp ;

	obj = STD_OBJ_ADDR ( obj_num ) ;
	temp = (word)( obj -> link[0] ) ;
	store ( temp ) ;
	if ( temp )
		ret_value ( TRUE ) ;
	else
		ret_value ( FALSE ) ;
}

Void
plus_get_link ( obj_num )
word	obj_num ;
{
	extern plus_object_ptr		plus_obj_list ;

	register plus_object_ptr	obj ;
	register word				temp ;

	obj = PLUS_OBJ_ADDR ( obj_num ) ;
	temp = ((obj -> link[0]) << BITS_PER_BYTE ) | (obj -> link[1]) ;
	store ( temp ) ;
	if ( temp )
		ret_value ( TRUE ) ;
	else
		ret_value ( FALSE ) ;
}

Void
std_check_loc ( o1,o2 )
word	o1 ;
word	o2 ;
{
	extern std_object_ptr		std_obj_list ;

	register std_object_ptr		obj ;

	obj = STD_OBJ_ADDR ( o1 ) ;
	if ( obj -> location[0] == (byte)o2 )
		ret_value ( TRUE ) ;
	else
		ret_value ( FALSE ) ;
}

Void
plus_check_loc ( o1,o2 )
word	o1 ;
word	o2 ;
{
	extern plus_object_ptr		plus_obj_list ;

	register plus_object_ptr	obj ;

	obj = PLUS_OBJ_ADDR ( o1 ) ;
	if ((word)(((obj -> location[0]) << BITS_PER_BYTE ) | (obj -> location[1])) == o2 )
		ret_value ( TRUE ) ;
	else
		ret_value ( FALSE ) ;
}
