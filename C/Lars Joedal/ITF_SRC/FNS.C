/*
**	File:	fns.c
**
**	(C)opyright 1987-1992 InfoTaskforce.
*/

#include	"infocom.h"

Void
plus ( a,b )
word	a,b ;
{
	store ( a + b ) ;
}

Void
minus ( a,b )
word	a,b ;
{
	store ( a - b ) ;
}

Void
multiply ( a,b )
word	a,b ;
{
	store ((word)((signed_word)a * (signed_word)b)) ;
}

Void
divide ( a,b )
word	a,b ;
{
	store ((word)((signed_word)a / (signed_word)b)) ;
}

Void
mod ( a,b )
word	a,b ;
{
	store ((word)((signed_word)a % (signed_word)b)) ;
}

Void
std_random ( param1 )
word	param1 ;
{
	extern word		random1 ;
	extern word		random2 ;

	register word	temp ;

	temp = random1 >> 1 ;
	if ( random2 & 0x0001 )
		temp |= 0x8000 ;
	random1 = random2 ;
	temp = ( random2 ^= temp ) ;
	store (((int)( temp & 0x7FFF ) % (int)param1 ) + 1 ) ;
}

Void
plus_random ( param1 )
word	param1 ;
{
	extern word		random1 ;
	extern word		random2 ;
	extern word		random3 ;
	extern word		random4 ;

	register word	temp ;

	if ((signed_word)param1 <= 0)
	{
		random3 = random4 = -((signed_word)param1) ;
		store ( (word)1 ) ;
		return ;
	}

	if ( random4 != 0 )
	{
		/*
		**	Note that even if random3 & ramdom4
		**	were unsigned, there is no way that
		**	they can ever be negative !
		*/

		if ( ++random3 >= random4 )
			random3 = 0 ;
		temp = random3 ;
	}
	else
	{
		temp = random1 >> 1 ;
		if ( random2 & 0x0001 )
			temp |= 0x8000 ;
		random1 = random2 ;
		temp = ( random2 ^= temp ) ;
	}
	store (((int)( temp & 0x7FFF ) % (int)param1 ) + 1 ) ;
}

Void
less_than ( a,b )
word	a,b ;
{
	ret_value ( (signed_word)a < (signed_word)b ) ;
}

Void
greater_than ( a,b )
word	a,b ;
{
	ret_value ( (signed_word)a > (signed_word)b ) ;
}

Void
bit ( a,b )
word	a,b ;
{
	ret_value ((( b & ( ~a )) == 0)) ;
}

Void
or ( a,b )
word	a,b ;
{
	store ( a | b ) ;
}

Void
not ( a )
word	a ;
{
	store ( ~a ) ;
}

Void
and ( a,b )
word	a,b ;
{
	store ( a & b ) ;
}

Void
compare ()
{
	extern word		param_stack[] ;

	register word	*param_ptr = &param_stack[0] ;
	register word	num_params ;
	register word	param1 ;

	num_params = *param_ptr++ ;
	param1 = *param_ptr++ ;
	while ( --num_params != 0 )
	{
		if ( param1 == *param_ptr++ )
		{
			ret_value ( TRUE ) ;
			return ;
		}
	}
	ret_value ( FALSE ) ;
}

Void
cp_zero ( a )
word	a ;
{
	ret_value (( a == 0 )) ;
}
