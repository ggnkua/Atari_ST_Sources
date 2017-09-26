#include	<mt_mem.h>
#include	<TOS.H>>
#include	<STDDEF.H>
#include	<STDLIB.H>
#include	<STRING.H>
#include	<TIME.H>
#ifdef	ICONNECT
#include	<iconnect\TYPES.H>
#endif
#include	<stdio.h>

#include	<atarierr.h>

#ifdef	DRACONIS
#include	<sockerr.h>
#include	<stsocket.h>
#endif
#ifdef	ICONNECT
#include	<iconnect\sockerr.h>
#include	<iconnect\socket.h>
#include	<iconnect\in.h>
#include	<iconnect\sockios.h>
#include	<iconnect\sfcntl.h>
#include	<iconnect\inet.h>
#endif

#include	"transprt.h"

#include "IFusion.h"
#include	"MM.h"
#include	"TM.h"

extern IF	If[FD_SETSIZE];

int16 cdecl	IF_TCP_open( uint32 rem_host, uint16 rem_port, uint16 tos, uint16 buffer_size )
{
	int16	handle;
#ifdef DEBUG
	DebugMsg( "TCP_open\n" );
#endif
	handle = socket( AF_INET, SOCK_STREAM, IPPROTO_IP );
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
		char			*Rcv = IF_KRmalloc( buffer_size );

		if( !Rcv )
		{
#ifdef	DRACONIS
			close_socket( handle );
#endif
#ifdef	ICONNECT
			sclose( handle );
#endif
			return( E_NOMEM );
		}

		if( rem_port == TCP_ACTIVE || rem_port == TCP_PASSIVE )
		{
#ifdef DEBUG
	DebugMsg( "TCP_open: erweiterter Modus\n" );
#endif
			Cab = ( CAB * ) &rem_host;
		}
		else
		{
#ifdef DEBUG
	DebugMsg( "TCP_open: normaler Modus\n" );
#endif
			if( rem_host == 0 )
			{
				Tmp.rport = 0;
				Tmp.rhost = 0;
				Tmp.lport = rem_port;
				Tmp.lhost = rem_host;
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
	DebugMsg( "TCP_open: lhost = %lx, lport = %i\n", Cab->lhost, Cab->lport );
	DebugMsg( "          rhost = %lx, rport = %i\n", Cab->rhost, Cab->rport );
#endif

#ifdef	ICONNECT
		sfcntl( handle, F_SETFL, O_NONBLOCK );
#endif
		if( Cab->rhost && Cab->rport )
		{
#ifdef DEBUG
	DebugMsg( "TCP_open: activ\n" );
#endif
			sin.sin_family = AF_INET;
#ifdef	DRACONIS
			sin.sin_addr.s_addr = Cab->rhost;
#endif
#ifdef	ICONNECT
			sin.sin_addr = Cab->rhost;
#endif
			sin.sin_port = Cab->rport;

#ifdef	DRACONIS
			if( connect( handle, ( struct sockaddr * ) &sin, ( int16 ) sizeof( sin )) != 0 )
#endif
#ifdef	ICONNECT
			if(( ret = connect( handle, &sin, ( int ) sizeof( sockaddr_in ))) != EINPROGRESS )
#endif
			{
#ifdef	DRACONIS
				close_socket( handle );
#endif
#ifdef	ICONNECT
				sclose( handle );
#endif
				IF_KRfree( Rcv );
				return( E_UNREACHABLE );
			}
		}
		else
		{
			int16	s;
#ifdef DEBUG
	DebugMsg( "TCP_open: passiv\n" );
#endif
			sin.sin_family = AF_INET;
#ifdef	DRACONIS
			sin.sin_addr.s_addr = Cab->lhost;
#endif
#ifdef	ICONNECT
			sin.sin_addr = Cab->lhost;
#endif
			sin.sin_port = Cab->lport;
#ifdef	DRACONIS
/*			if( bind( handle, ( struct sockaddr * ) &sin, ( int16 ) sizeof( sin )) != 0 )	*/
			if( 0 )
#endif
#ifdef	ICONNECT
			if(( ret = bind( handle, &sin, ( int ) sizeof( sockaddr_in ))) != E_OK )
#endif
			{
#ifdef	DRACONIS
				close_socket( handle );
#endif
#ifdef	ICONNECT
				sclose( handle );
#endif
				IF_KRfree( Rcv );
				return( E_UNREACHABLE );
			}
			if(( ret = listen( handle, 10 )) != E_OK && ret != EISCONN )
			{
#ifdef	DRACONIS
				close_socket( handle );
#endif
#ifdef	ICONNECT
				sclose( handle );
#endif
				IF_KRfree( Rcv );
				return( E_UNREACHABLE );
			}
#ifdef	ICONNECT
			if(( s = accept( handle, &sin, &len )) != EWOULDBLOCK )
			{
				sclose( handle );
				IF_KRfree( Rcv );
				return( E_UNREACHABLE );
			}
#endif
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
		If[handle-1].RcvSize = buffer_size;
		If[handle-1].Rcv = Rcv;
		If[handle-1].Cib.protocol = P_TCP;
		If[handle-1].Cib.status = 0;
		Cab->lhost = If[handle-1].Cib.address.lhost;
		Cab->lport = If[handle-1].Cib.address.lport;
		Cab->rhost = If[handle-1].Cib.address.rhost;
		Cab->rport = If[handle-1].Cib.address.rport;
#ifdef DEBUG
	DebugMsg( "TCP_open: lhost = %lx, lport = %i\n", If[handle-1].Cib.address.lhost, If[handle-1].Cib.address.lport );
	DebugMsg( "          rhost = %lx, rport = %i\n", If[handle-1].Cib.address.rhost, If[handle-1].Cib.address.rport );
	DebugMsg( "          handle = %i, sock = %i\n", handle, If[handle-1].sock );
#endif
		return( handle );
	}
	return( E_UNREACHABLE );
}

int16 cdecl	IF_TCP_close( int16 handle, int16 timeout )
{
	if( If[handle-1].Rcv )
	{
		IF_KRfree( If[handle-1].Rcv );
		If[handle-1].Rcv = NULL;
		If[handle-1].RcvSize = 0;
	}
	shutdown( If[handle-1].sock, 2 );
#ifdef	DRACONIS
	close_socket( If[handle-1].sock );
#endif
#ifdef	ICONNECT
	sclose( If[handle-1].sock );
#endif
	if( handle != If[handle-1].sock )
#ifdef	DRACONIS
		close_socket( handle );
#endif
#ifdef	ICONNECT
		sclose( handle );
#endif
	return( E_NORMAL );
}

int16 cdecl IF_TCP_send( int16 handle, void *buffer, int16 length )
{
	int32	n;
	int16	len = ( int16 ) sizeof( int32 );
#ifdef DEBUG
	DebugMsg( "TCP_send [handle = %i]: sock = %i\n", handle, If[handle-1].sock );
#endif
#ifdef	DRACONIS
	n = 0;
#endif
#ifdef	ICONNECT
	getsockopt( If[handle-1].sock, SOL_SOCKET, SO_SNDBUF, &n, &len );
#endif
	if( n > If[handle-1].RcvSize )
	{
#ifdef DEBUG
		DebugMsg( "TCP_send [handle = %i]: E_OBUFFULL\n", handle );
#endif
		return( E_OBUFFULL );
	}
	else
	{
		int16	ret = ( int16 ) send( If[handle-1].sock, buffer, length, 0 );
#ifdef DEBUG
		{
			char	p[20000];
			memcpy( p, buffer, length );
			p[length-1] = 0;
			DebugMsg( "TCP_send [handle = %i]: %i\n%s\n", handle, ret, p );
		}
#endif
		if( ret >= 0 )
			return( E_NORMAL );
		else
			return( E_EOF );
	}
}

int16 cdecl IF_TCP_wait_state( int16 handle, int16 state, int16 timeout )
{
	clock_t	Clock = clock();
#ifdef DEBUG
	DebugMsg( "TCP_wait_state [handle = %i]: sock = %i, state = %i, timeout = %i\n", handle, If[handle-1].sock, state, timeout );
#endif
	switch( state )
	{
		case	TESTABLISH:
		{
#ifdef	DRACONIS
			struct sockaddr_in	sin;
#endif
#ifdef	ICONNECT
			sockaddr_in	sin;
#endif
			int16			ret;
			if( If[handle-1].Cib.address.rhost )
			{
				fd_set  mask; 
#ifdef	DRACONIS
				struct timeval tout; 
#endif
#ifdef	ICONNECT
				timeval tout; 
#endif
#ifdef DEBUG
				DebugMsg( "TCP_wait_state [handle = %i]: aktiv\n", handle );
#endif
				FD_ZERO(&mask); 
				FD_SET(If[handle-1].sock, &mask);
				tout.tv_sec=0;
				tout.tv_usec=0; 
				for(;;)
				{ 
#ifdef	DRACONIS
					if( select( If[handle-1].sock + 1, &mask, &mask, NULL, &tout) && FD_ISSET(If[handle-1].sock, &mask))
#endif
#ifdef	ICONNECT
					if( select( If[handle-1].sock + 1, &mask, &mask, NULL, &tout))
#endif
						return( E_NORMAL );
					if(( clock() - Clock ) / CLK_TCK > timeout )
					{
#ifdef DEBUG
						DebugMsg( "TCP_wait_state [handle = %i]: E_CNTIMEOUT\n", handle );
#endif
						return( E_CNTIMEOUT );
					}
					Syield();
				}
			}
			else
			{
#ifdef	DRACONIS
				int16	len = ( int16 ) sizeof( struct sockaddr_in ), ret;
#endif
#ifdef	ICONNECT
				int16	len = ( int16 ) sizeof( sockaddr_in ), ret;
#endif
#ifdef DEBUG
				DebugMsg( "TCP_wait_state [handle = %i]: passiv\n", handle );
#endif
				sin.sin_family = AF_INET;
#ifdef	DRACONIS
				ret = accept( If[handle-1].sock, ( struct sockaddr * ) &sin, &len );
#endif
#ifdef	ICONNECT
				while(( ret = accept( If[handle-1].sock, &sin, &len )) == EWOULDBLOCK )
#endif
				{
					if(( clock() - Clock ) / CLK_TCK > timeout )
					{
#ifdef DEBUG
						DebugMsg( "TCP_wait_state [handle = %i]: E_CNTIMEOUT\n", handle );
#endif
						return( E_CNTIMEOUT );
					}
					Syield();
				}
				if( ret > 0 )
				{
#ifdef	ICONNECT
					sfcntl( ret, F_SETFL, O_NONBLOCK );
#endif
					If[handle-1].Cib.address.rport = sin.sin_port;
#ifdef	DRACONIS
					If[handle-1].Cib.address.rhost = sin.sin_addr.s_addr;
#endif
#ifdef	ICONNECT
					If[handle-1].Cib.address.rhost = sin.sin_addr;
#endif
					If[handle-1].sock = ret;
#ifdef DEBUG
					DebugMsg( "TCP_wait_state: lhost = %lx, lport = %i\n", If[handle-1].Cib.address.lhost, If[handle-1].Cib.address.lport );
					DebugMsg( "                rhost = %lx, rport = %i\n", If[handle-1].Cib.address.rhost, If[handle-1].Cib.address.rport );
					DebugMsg( "                handle = %i, sock = %i\n", handle, If[handle-1].sock );
#endif
					return( E_NORMAL );
				}
				else	if( ret == EINVFN )
					return( E_NORMAL );
				else
					return( E_BADHANDLE );
			}
		}
		default:
			printf("TCP_wait_state: %i\n", state );
			break;
	}
	return( E_BADHANDLE );
}

int16 cdecl IF_TCP_ack_wait( int16 handle, int16 timeout )
{
#ifdef	ICONNECT
	int32	n = 1;
	int16	len = ( int16 ) sizeof( int32 );
	clock_t	Clock = clock();
	while( n > 0 )
	{
		getsockopt( If[handle-1].sock, SOL_SOCKET, SO_SNDBUF, &n, &len );
		if(( clock() - Clock ) / CLK_TCK * 1000 > timeout )
			return( E_CNTIMEOUT );
		Syield();
	}
#endif
	return( E_NORMAL );
}
