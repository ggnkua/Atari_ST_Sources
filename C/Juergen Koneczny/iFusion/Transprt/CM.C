#include	<mt_mem.h>
#include	<TOS.H>>
#include	<STDDEF.H>
#include	<STDLIB.H>
#ifdef	ICONNECT
#include	<iconnect\TYPES.H>
#endif
#include	<STRING.H>
#include	<stdio.h>

#include	<atarierr.h>

#ifdef	DRACONIS
#include	<stsocket.h>
#include	<sockerr.h>
#endif
#ifdef	ICONNECT
#include	<iconnect\sockerr.h>
#include	<iconnect\socket.h>
#include	<iconnect\inet.h>
#endif

#include	"transprt.h"

#include	"IFusion.h"
#include	"CM.h"
#include	"MM.h"
#include	"TM.h"

extern IF	If[FD_SETSIZE];

int16 cdecl IF_CNkick( int16 handle )
{
	return( E_NORMAL );
}

int16 cdecl IF_CNbyte_count( int16 handle )
{
	int32	count;
#ifdef DEBUG
	DebugMsg( "CNbyte_count [handle = %i]\n", handle );
#endif
	if( If[handle-1].Cib.protocol == P_TCP )
	{
		if( IF_TCP_wait_state( handle, TESTABLISH, 0 ) != E_NORMAL )
		{
			if( If[handle-1].Cib.address.rhost )
				return( 0 );
			else
				return( E_LISTEN );
		}
	}
	if( If[handle-1].RcvSize > 0 )
		count = recv( If[handle-1].sock, If[handle-1].Rcv, If[handle-1].RcvSize, MSG_PEEK );
	else
	{
		char	c;
		count = recv( If[handle-1].sock, &c, 1, MSG_PEEK );
	}
#ifdef DEBUG
	DebugMsg( "CNbyte_count [handle = %i] recv() = %li\n", handle, count );
#endif
	if( count < 0 )
	{
#ifdef	DRACONIS
		return( E_RRESET );
#endif
#ifdef	ICONNECT
		switch(( int16 ) count )
		{
			case	EWOULDBLOCK:
				return( 0 );
			case	ECONNRESET:
				return( E_EOF );
			default:
				return( E_NODATA );
		}
#endif
	}
	return(( int16 ) count );
}

int16 cdecl IF_CNget_char( int16 handle )
{
	char	c;
	int32	count;
/*
#ifdef DEBUG
	DebugMsg( "CNget_char [handle = %i]\n", handle );
#endif
*/

#ifdef	DRACONIS
	{
		int nx;
		struct fd_set fd_chk;
		struct timeval tval;
		FD_ZERO(&fd_chk);
		FD_SET(If[handle-1].sock, &fd_chk);
		nx = select( If[handle-1].sock + 1, &fd_chk, NULL, NULL, &tval);
		if( !( nx && FD_ISSET( If[handle-1].sock, &fd_chk)))
			return( E_NODATA );
	}
#endif

	count = recv( If[handle-1].sock, &c, 1, 0 );
	if( count <= 0 )
	{
		switch(( int16 ) count )
		{
#ifdef	DRACONIS
			case	-1:
				return( E_EOF );
#endif
			case	EWOULDBLOCK:
				return( E_NODATA );	/* AMail ben”tigt E_NODATA */
			case	ECONNRESET:
				return( E_EOF );
			default:
				return( E_NODATA );
		}
	}
/*
#ifdef DEBUG
	DebugMsg( "CNget_char [handle = %i]: %c\n", handle, c );
#endif
*/
	return(( int16 ) c );
}

NDB *cdecl	IF_CNget_NDB( int16 handle )
{
	int16	len;
#ifdef DEBUG
	DebugMsg( "CNget_NDB [handle = %i]\n", handle );
#endif
	len = IF_CNbyte_count( handle );
	if( len > 0 )
	{
		NDB	*Ndb = IF_KRmalloc( sizeof( NDB ));
		if( Ndb )
		{
			Ndb->ndata = IF_KRmalloc( len );
			if( Ndb->ndata )
			{
				recv( If[handle-1].sock, Ndb->ndata, len, 0 );
				Ndb->ptr = Ndb->ndata;
				Ndb->len = len;
				Ndb->next = NULL;
				return( Ndb );
			}
			else
				free( Ndb );
		}
		
	}
	return( NULL );
}

int16 cdecl	IF_CNget_block( int16 handle, void *buffer, int16 length )
{
	int32	count = recv( If[handle-1].sock, buffer, length, 0 );
	if( count >= 0 )
		return(( int16 ) count );
	else
	{
		switch(( int16 ) count )
		{
#ifdef	DRACONIS
			case	-1:
				return( E_EOF );
#endif
			case	EWOULDBLOCK:
				return( E_NODATA );
			case	ECONNRESET:
				return( E_EOF );
			default:
				return( E_NODATA );
		}
	}
}
CIB *cdecl	IF_CNgetinfo( int16 handle )
{
#ifdef DEBUG
	DebugMsg( "CNgetinfo:\n" );
	DebugMsg( "           lhost = %lx, lport = %i\n", If[handle-1].Cib.address.lhost, If[handle-1].Cib.address.lport );
	DebugMsg( "           rhost = %lx, rport = %i\n", If[handle-1].Cib.address.rhost, If[handle-1].Cib.address.rport );
	DebugMsg( "           handle = %i, sock = %i\n", handle, If[handle-1].sock );
#endif
/*	printf("%i\n", If[handle-1].Cib.address.lport );
	printf("%s\n", inet_ntoa( If[handle-1].Cib.address.lhost ));
	printf("%i\n", If[handle-1].Cib.address.rport );
	printf("%li\n", If[handle-1].Cib.address.rhost );	*/
	return( &( If[handle-1].Cib ));
}
int16 cdecl	IF_CNgets( int16 cn, char *buffer, int16 len, char delim )
{
	printf("CNgets\n");
}
