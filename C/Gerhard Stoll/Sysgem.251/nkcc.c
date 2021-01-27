/* ------------------------------------------------------------------- *
 * Module Version       : 2.03                                         *
 * Author               : Gerhard Stoll                                *
 * Programming Language : Pure-C                                       *
 * Copyright            : (c) 2000, Gerhard Stoll, 56727 Mayen         *
 * ------------------------------------------------------------------- */

#include        "kernel.h"
#include        "nkcc.h"

/* ------------------------------------------------------------------- */

VOID StrTolower ( BYTE *str )
{
	while (*str != EOS)
	{
		*str = nkc_tolower(*str);
		str++;
	}
}

/* ------------------------------------------------------------------- */

VOID StrToupper ( BYTE *str )
{
	while (*str != EOS)
	{
		*str = nkc_toupper(*str);
		str++;
	}
}
