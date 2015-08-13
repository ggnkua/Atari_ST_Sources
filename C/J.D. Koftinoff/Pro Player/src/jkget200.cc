/*

 The Pro MIDI Player
 Copyright 1986-1994 By J.D. Koftinoff Software, Ltd.
 Released under the GPL in 2007
 Please see the file 'COPYING' including in this package.
 
*/
 


#include <jk_sys.h>

static long _200_time;

static void getit()
{
	_200_time=(*(long *)0x4ba);
}

long jk_get_200()
{
	Supexec( getit );
	return _200_time;
}


