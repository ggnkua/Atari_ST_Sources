#include	<mt_mem.h>
#include	<TOS.H>>
#include	<STDDEF.H>
#include	<STDLIB.H>
#include	<iconnect\TYPES.H>
#include	<stdio.h>

#include	"transprt.h"
#include	"layer.h"

#include	"IFusion.h"
#include	"RM.h"


int16 cdecl	IF_load_routing_table( void )
{
	printf("load_routing_table\n");
}

int16 cdecl	IF_get_route_entry( int16 index, uint32 *subnet, uint32 *submask, void **port, uint32 *gateway )
{
	printf("get_route_entry\n");
}
int16 cdecl	IF_set_route_entry( int16 index, uint32 subnet, uint32 submask, void *port, uint32 gateway )
{
	printf("set_route_entry\n");
}
