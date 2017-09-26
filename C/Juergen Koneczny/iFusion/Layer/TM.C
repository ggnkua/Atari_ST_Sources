#include	<mt_mem.h>
#include	<TOS.H>>
#include	<STDDEF.H>
#include	<STDLIB.H>
#include	<iconnect\TYPES.H>
#include	<stdio.h>

#include	"transprt.h"
#include	"layer.h"

#include	"IFusion.h"
#include	"TM.h"

int16 cdecl	IF_TIMER_call( void cdecl (*handler) (void), int16 install_code )
{
	printf("TIMER_call\n");
}
int32 cdecl	IF_TIMER_now( void )
{
	printf("TIMER_now\n");
}
int32 cdecl	IF_TIMER_elapsed( int32 moment )
{
	printf("TIMER_elapsed\n");
}
