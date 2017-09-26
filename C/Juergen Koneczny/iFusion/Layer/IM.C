#include	<mt_mem.h>
#include	<TOS.H>>
#include	<STDDEF.H>
#include	<STDLIB.H>
#include	<iconnect\TYPES.H>
#include	<stdio.h>

#include	"transprt.h"
#include	"layer.h"

#include	"IFusion.h"
#include	"IM.h"

int16 cdecl	IF_IP_send( uint32 scr_host, uint32 dest_host, uint8 tos, uint16 dont_frag, uint8 ttl, uint8 protocol, uint16 ident, void *data, uint16 data_length, void *options, uint16 options_length )
{
	printf("IP_send\n");
}
IP_DGRAM *cdecl	IF_IP_fetch( int16 protocol )
{
	printf("IP_fetch\n");
}
int16 cdecl	IF_IP_handler( int16 protocol, int16 cdecl (* handler) (IP_DGRAM *), int16 install_code )
{
	printf("IP_handler\n");
}
void cdecl	IF_IP_discard( IP_DGRAM *datagram, int16 all_flag )
{
	printf("IP_discard\n");
}
