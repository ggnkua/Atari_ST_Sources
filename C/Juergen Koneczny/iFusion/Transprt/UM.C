#include	<mt_mem.h>
#include	<TOS.H>>
#include	<STDDEF.H>
#include	<STDLIB.H>
#include	<STRING.H>
#ifdef	ICONNECT
#include	<iconnect\TYPES.H>
#endif
#include	<stdio.h>

#include	<atarierr.h>
#ifdef	ICONNECT
#include	<iconnect\sockerr.h>
#include	<iconnect\socket.h>
#include	<iconnect\in.h>
#include	<iconnect\sockios.h>
#include	<iconnect\sfcntl.h>
#include	<iconnect\inet.h>
#endif

#ifdef	DRACONIS
#include	<stsocket.h>
#endif

#include	"transprt.h"

#include	"IFusion.h"
#include	"UM.h"

extern IF	If[FD_SETSIZE];

int16 cdecl	IF_UDP_open( uint32 rem_host, uint16 rem_port )
{
	int16	handle;
#ifdef DEBUG
	DebugMsg( "UDP_open\n" );
#endif
	handle = socket( AF_INET, SOCK_DGRAM, IPPROTO_IP );
	if( handle > 0 )
	{
#ifdef	DRACONIS
		struct sockaddr_in	sin;
		int16	len = ( int16 ) sizeof( struct sockaddr_in );
#endif
#ifdef	ICONNECT
		sockaddr_in	sin;
		int16	len = ( int16 ) sizeof( sockaddr_in );
#endif
		int16	ret;
		CAB			*Cab, Tmp;
		if( rem_port == UDP_EXTEND )
		{
#ifdef DEBUG
	DebugMsg( "UDP_open: erweiterter Modus\n" );
#endif
			Cab = ( CAB * ) &rem_host;
		}
		else
		{
#ifdef DEBUG
	DebugMsg( "UDP_open: normaler Modus\n" );
#endif
			if( rem_host == 0 )
			{
				Tmp.lport = rem_port;
				Tmp.lhost = 0;
				Tmp.rport = 0;
				Tmp.rhost = 0;
			}
			else
			{
				Tmp.lport = 0;
				Tmp.lhost = 0;
				Tmp.rport = rem_port;
				Tmp.rhost = rem_host;
			}
			Cab = &Tmp;
		}
#ifdef DEBUG
	DebugMsg( "UDP_open: lhost = %x, lport = %i\n", Cab->lhost, Cab->lport );
	DebugMsg( "          rhost = %x, rport = %i\n", Cab->rhost, Cab->rport );
#endif
		sin.sin_family = AF_INET;
#ifdef	DRACONIS
		memcpy( &sin.sin_addr.s_addr, &Cab->rhost, sizeof( Cab->rhost ));
#endif
#ifdef	ICONNECT	
		sin.sin_addr = Cab->lhost;
#endif
		sin.sin_port = Cab->lport;

#ifdef	ICONNECT
		sfcntl( handle, F_SETFL, O_NONBLOCK );
#endif

#ifdef	DRACONIS
		if(( ret = bind( handle, ( struct sockaddr * ) &sin, len )) != 0 )
#endif
#ifdef	ICONNECT
		if(( ret = bind( handle, &sin, len )) != E_OK )
#endif
		{
#ifdef	DRACONIS
			close_socket( handle );
#endif
#ifdef	ICONNECT
			sclose( handle );
#endif
			return( E_UNREACHABLE );
		}
		
#ifdef	DRACONIS
		getsockname( handle, ( struct sockaddr * ) &sin, &len );
#endif
#ifdef	ICONNECT
		getsockname( handle, &sin, &len );
#endif
		If[handle-1].sock = handle;
		If[handle-1].Cib.address.lport = sin.sin_port;
#ifdef	DRACONIS
		If[handle-1].Cib.address.lhost = sin.sin_addr.s_addr;
#endif
#ifdef	ICONNECT
		If[handle-1].Cib.address.lhost = sin.sin_addr;
#endif
		set_client_ip( If[handle-1].Cib.address.lhost );
		If[handle-1].Cib.address.rport = Cab->rport;
		If[handle-1].Cib.address.rhost = Cab->rhost;
		if( Cab->rport == 0 )
			If[handle-1].Cib.address.rhost = 0;
		If[handle-1].RcvSize = 0;
		If[handle-1].Rcv = NULL;
		If[handle-1].Cib.protocol = P_UDP;
		If[handle-1].Cib.status = 0;
		Cab->lhost = If[handle-1].Cib.address.lhost;
		Cab->lport = If[handle-1].Cib.address.lport;
		Cab->rhost = If[handle-1].Cib.address.rhost;
		Cab->rport = If[handle-1].Cib.address.rport;
#ifdef DEBUG
	DebugMsg( "UDP_open: lhost = %x, lport = %i\n", If[handle-1].Cib.address.lhost, If[handle-1].Cib.address.lport );
	DebugMsg( "          rhost = %x, rport = %i\n", If[handle-1].Cib.address.rhost, If[handle-1].Cib.address.rport );
	DebugMsg( "          handle = %i, sock = %i\n", handle, If[handle-1].sock );
#endif
		return( handle );
	}
	return( E_UNREACHABLE );
}

int16 cdecl	IF_UDP_close( int16 handle )
{
	shutdown( If[handle-1].sock, 2 );
#ifdef	DRACONIS
	close_socket( If[handle-1].sock );
#endif
#ifdef	ICONNECT
	sclose( If[handle-1].sock );
#endif
	return( E_NORMAL );
}

int16 cdecl	IF_UDP_send( int16 handle, void *buffer, int16 length )
{
	int16	ret;
#ifdef	DRACONIS
		struct sockaddr_in	sin;
#endif
#ifdef	ICONNECT
		sockaddr_in	sin;
#endif
	sin.sin_family = AF_INET;
#ifdef	DRACONIS
		memcpy( &sin.sin_addr.s_addr, &If[handle-1].Cib.address.rhost, sizeof( If[handle-1].Cib.address.rhost ));
#endif
#ifdef	ICONNECT
	sin.sin_addr = If[handle-1].Cib.address.rhost;
#endif
	sin.sin_port = If[handle-1].Cib.address.rport;
#ifdef DEBUG
	DebugMsg( "UDP_send [handle = %i]: sock = %i, %i\n", handle, If[handle-1].sock, length );
	DebugMsg( "                        rhost = %x, rport = %i\n", If[handle-1].Cib.address.rhost, If[handle-1].Cib.address.rport );
	{
		char	p[20000];
		memcpy( p, buffer, length );
		p[length-1] = 0;
		DebugMsg( "UDP_send [handle = %i]:\n%s\n", handle, p );
	}
#endif
#ifdef	DRACONIS
	if(( ret = sendto( If[handle-1].sock, buffer, length, 0, ( struct sockaddr * ) &sin, ( int16 ) sizeof( sin ))) < 0 )
#endif
#ifdef	ICONNECT
	if(( ret = sendto( If[handle-1].sock, buffer, length, 0, &sin, ( int16 ) sizeof( sockaddr_in ))) < 0 )
#endif
	{
#ifdef DEBUG
	DebugMsg( "UDP_send [handle = %i]: E_UNREACHABLE\n", handle );
#endif
		return( E_UNREACHABLE );
	}
#ifdef DEBUG
	DebugMsg( "UDP_send [handle = %i]: E_NORMAL\n", handle );
#endif
	return( E_NORMAL );
}

