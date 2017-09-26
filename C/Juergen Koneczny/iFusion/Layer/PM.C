#include	<mt_mem.h>
#include	<TOS.H>>
#include	<STDDEF.H>
#include	<STDLIB.H>
#include	<iconnect\TYPES.H>
#include	<stdio.h>

#ifdef	ICONNECT
#include	<iconnect\inet.h>
#include	<iconnect\usis.h>
#endif

#include	"transprt.h"
#include	"layer.h"

#include	"IFusion.h"
#include	"PM.h"

int16 cdecl	IF_PRTCL_announce( int16 protocol )
{
	printf("PRTCL_announce\n");
}
int16 cdecl	IF_PRTCL_get_parameters( uint32 rem_IP, uint32 *lcl_IP, int16 *ttl, uint16 *mtu )
{
	if( lcl_IP )
	{
#ifdef	DRACONIS
		*lcl_IP = 0;
#endif
#ifdef	ICONNECT
		USIS_REQUEST  ur;
		ur.request = UR_LOCAL_IP;
		ur.free1 = NULL;
		ur.free2 = NULL;
		if( usis_query( &ur ) == UA_FOUND )
			*lcl_IP = ur.ip;
		else
			*lcl_IP = 0;
#endif
	}
	if( ttl )
		*ttl = 64;
	if( mtu )
		*mtu = 576;
	return( E_NORMAL );
}
int16 cdecl	IF_PRTCL_request( void *connect, CN_FUNCS *functions )
{
	printf("PRTCL_request\n");
}
void cdecl	IF_PRTCL_release( int16 handle )
{
	printf("PRTCL_release\n");
}
void *cdecl IF_PRTCL_lookup( int16 handle, CN_FUNCS *functions )
{
	printf("PRTCL_lookup\n");
}
