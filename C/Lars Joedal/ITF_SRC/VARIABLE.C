/*
**	File:	variable.c
**
**	(C)opyright 1987-1992 InfoTaskforce.
*/

#include	"infocom.h"

Void
get_var ( var )
word	var ;
{
	store ( load_var ( var ) ) ;
}

word
load_var ( var )
word	var ;
{
	extern byte_ptr		global_ptr ;
	extern word			*stack_var_ptr ;
	extern word			*stack ;

	register word		value ;
	register word		*svp ;
	register byte_ptr	ptr ;

	if ( var == 0 )
		return ( *stack ) ;
	else
	{
		if ( var < LOCAL_VARS )
		{
			/*
			**	In interpreters prior to VERSION_5, the "stack_var_ptr"
			**	pointed to the first local variable on the z_code stack.
			**	In VERSION_5 and subsequent interpreters, the "stack_var_ptr"
			**	points to the stack entry above the first local variable on
			**	the z_code stack.
			**
			**	However, there is no reason for us not to adopt the VERSION_5
			**	method for all versions of the interpreter. This decision
			**	affects the following opcodes:
			**								gosub, std_rtn, load_var & put_var.
			**
			**	Interpreters prior to VERSION_5 used the statement:
			**
			**				svp = stack_var_ptr - ( var - 1 ) ;
			**
			**	instead of:
			**
			**				svp = stack_var_ptr - var ;
			*/

			svp = stack_var_ptr - var ;
			return ( *svp ) ;
		}
		else
		{
			ptr = global_ptr + (( var - LOCAL_VARS ) << 1 ) ;
			value = *(ptr++) << BITS_PER_BYTE ;
			return ( (word)(value | *ptr) ) ;
		}
	}
}

Void
put_var ( var,value )
word	var,value ;
{
	extern byte_ptr		global_ptr ;
	extern word			*stack_var_ptr ;
	extern word			*stack ;

	register word		*svp ;
	register byte_ptr	ptr ;

	if ( var == 0 )
		*stack = value ;
	else
	{
		if ( var < LOCAL_VARS )
		{
			/*
			**	In interpreters prior to VERSION_5, the "stack_var_ptr"
			**	pointed to the first local variable on the z_code stack.
			**	In VERSION_5 and subsequent interpreters, the "stack_var_ptr"
			**	points to the stack entry above the first local variable on
			**	the z_code stack.
			**
			**	However, there is no reason for us not to adopt the VERSION_5
			**	method for all versions of the interpreter. This decision
			**	affects the following opcodes:
			**								gosub, std_rtn, load_var & put_var.
			**
			**	Interpreters prior to VERSION_5 used the statement:
			**
			**				svp = stack_var_ptr - ( var - 1 ) ;
			**
			**	instead of:
			**
			**				svp = stack_var_ptr - var ;
			*/

			svp = stack_var_ptr - var ;
			*svp = value ;
		}
		else
		{
			ptr = global_ptr + (( var - LOCAL_VARS ) << 1 ) ;
			*ptr++ = MOST_SIGNIFICANT_BYTE ( value ) ;
			*ptr = LEAST_SIGNIFICANT_BYTE ( value ) ;
		}
	}
}

Void
push ( value )
word	value ;
{
	extern word		*stack ;

	*(--stack) = value ;
}

Void
pop ( var )
word	var ;
{
	extern word		*stack ;

	put_var ( var,*stack++ ) ;
}

Void
inc_var ( var )
word	var ;
{
	put_var ( var,load_var ( var ) + 1 ) ;
}

Void
dec_var ( var )
word	var ;
{
	put_var ( var,load_var ( var ) - 1 ) ;
}

Void
inc_chk ( var,threshold )
word	var,threshold ;
{
	register word	value ;

	value = load_var ( var ) + 1 ;
	put_var ( var,value ) ;
	if ( (signed_word)value > (signed_word)threshold )
		ret_value ( TRUE ) ;
	else
		ret_value ( FALSE ) ;
}

Void
dec_chk ( var,threshold )
word	var,threshold ;
{
	register word	value ;

	value = load_var ( var ) - 1 ;
	put_var ( var,value ) ;
	if ( (signed_word)value < (signed_word)threshold )
		ret_value ( TRUE ) ;
	else
		ret_value ( FALSE ) ;
}

word
load ( mode )
int		mode ;
{
	/*
	**	Mode 0 = Immediate Word ;
	**	Mode 1 = Immediate Byte ;
	**	Mode 2 = Variable ;
	*/

	extern word		*stack ;

	register word	var ;

	if ( --mode < 0 )
		return ( next_word () ) ;
	if ( mode == 0 )
		return ( (word)next_byte () ) ;
	var = next_byte () ;
	if ( var == 0 )
		return ( *stack++ ) ;
	else
		return ( load_var ( var ) ) ;
}
