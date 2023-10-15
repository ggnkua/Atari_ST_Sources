/************************************************************************/
/*																		*/
/*																		*/
/*		>>>>>>>>>>>  TOS - Magazin   Ausgabe 4/93  <<<<<<<<<<<<<		*/
/*																		*/
/*																		*/
/*		P R O J E C T	:	Beispiele fr Codieralgorithmen				*/
/*							CODING.TTP									*/
/*																		*/
/*		M O D U L E		:	PORT.C										*/
/*																		*/
/*																		*/
/*		Author			:	Jrgen Lietzow fr TOS-Magazin				*/
/*																		*/
/*		System/Compiler	:	Atari ST/TT, TOS 4.01, Pure C				*/
/*																		*/
/*		Last Update		:	26.02.93 (JL)								*/
/*																		*/
/*																		*/
/************************************************************************/

#define __PORT

#include "..\cod_lib.h"


#ifndef BIG_ENDIAN

void	ConvLong( long *values, int num )
{
	ulong	temp;
	ulong	val;
	
	while ( --num >= 0 )
	{
		val = (ulong) *values;

		temp = val >> 24;
		temp <<= 8;
		temp |= (val >> 16) & 0xff;
		temp <<= 8;
		temp |= (val >> 8) & 0xff;
		temp <<= 8;
		temp |= val & 0xff;
		
		*values++ = (long) temp;
	}
}

#endif
