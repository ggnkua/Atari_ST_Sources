#include	<mt_mem.h>
#include	<TOS.H>>
#include	<STDDEF.H>
#include	<STDLIB.H>
#include	<iconnect\TYPES.H>
#include	<stdio.h>

#include	"transprt.h"
#include	"layer.h"

#include	"IFusion.h"
#include	"SM.h"


static int16	active = 1, fraction = 10;

void cdecl	IF_set_dgram_ttl( IP_DGRAM *datagram )
{
	printf("set_dgram_ttl\n");
}
int16 cdecl	IF_check_dgram_ttl( IP_DGRAM *datagram )
{
	printf("check_dgram_ttl\n");
}
int32 cdecl	IF_set_sysvars( int16 new_active, int16 new_fraction )
{
	int32	ret = 0;
	ret = active;
	ret = ret << 16;
	ret += fraction;
	if( new_active != -1 )
		active = new_active;
	if( new_fraction != -1 )
		fraction = new_fraction;
	return( ret );
}

void cdecl	IF_query_chains( void **port, void **drv, void **layer )
{
	*port = NULL;
	*drv = NULL;
	*layer = NULL;
}

int32 cdecl IF_protect_exec( void *para, int32 cdecl ( *code ) (void *))
{
	printf("protect_exec\n");
}
