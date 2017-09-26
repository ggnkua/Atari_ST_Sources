#include	<mt_mem.h>
#include	<PORTAB.H>
#include	<TOS.H>
#include	<VDICOL.H>
#include	<MT_AES.H>
#include	<STDDEF.H>
#include	<STDARG.H>
#include	<STDLIB.H>
#include	<stdio.h>
#include	<string.h>
#include	<TIME.H>
#include	<MATH.H>
#include	<CTYPE.H>

#include	<atarierr.h>
#include	<av.h>

#ifdef	DRACONIS
#include	<stsocket.h>
#endif
#ifdef	ICONNECT
#include	<iconnect\in.h>
#include	<iconnect\netdb.h>
#include	<iconnect\sfcntl.h>
#include	<iconnect\socket.h>
#include	<iconnect\types.h>
#include	<iconnect\sockios.h>
#include	<iconnect\usis.h>
#endif
#include	<iconnect\sockerr.h>
#include	<iconnect\sockinit.h>

#include	"main.h"
#include	"TCP.h"

/*-----------------------------------------------------------------------------*/
/* Strukturdefinitionen                                                        */
/*-----------------------------------------------------------------------------*/
typedef	struct	__tcp_data__
{
	WORD	MainAppId;
	WORD	WinHandle;
	WORD	SocketHandle;
	BYTE	*Url;
}	TCP_DATA;

typedef	struct	__msg_data__
{
	struct __msg_data__	*next;
	WORD	AppId;
	WORD	Msg[8];
}	MSG_DATA;

typedef	struct
{
	MSG_DATA	*First;
	clock_t	Last;
}	MSG_STAMP;

/*-----------------------------------------------------------------------------*/
/* Externe Variablen                                                           */
/*-----------------------------------------------------------------------------*/
extern WORD		magic_version;
extern LONG		magic_date;
#ifndef	TCPOVL
extern volatile WORD	RecPufLen;
#else
WORD RecPufLen = 8192;
#endif

extern BYTE	*RxPath, *RxPara, *TxPath, *TxPara;

/*-----------------------------------------------------------------------------*/
/* Globale Variablen                                                           */
/*-----------------------------------------------------------------------------*/
char	Hostname[256];
static int HostnameFlag = 0;
#ifdef	ICONNECT
static int	StipFlag = 0;
#endif

/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/
static LONG	cdecl	TcpThread( BYTE *Dummy );
static void	AppendMessage( WORD Msg[8], MSG_DATA **MsgPuf, WORD AppId );

#ifndef	TCPOVL
WORD	Tcp( WORD Global[15] )
{
	WORD			AppId;
/*#ifdef	DRACONIS
	 AppId = MT_shel_write( 1, 1, 100, "tcp.ovl", NULL, Global );
#endif*/
	THREADINFO	Thread;

	Thread.proc = (void *) TcpThread;
	Thread.user_stack = NULL;
	Thread.stacksize = 4096L;
	Thread.mode = 0;
	Thread.res1 = 0L;

#ifdef	DEBUG
	DebugMsg( Global, "Tcp: shel_write( SHW_THR_CREATE, ...)\n" );
#endif 
	if( magic_version && magic_date >= 0x19960401L )
		AppId = MT_shel_write( SHW_THR_CREATE, 1, 0, ( char * ) &Thread, NULL, Global );
	else
		AppId = -1;
#ifdef	DEBUG
	DebugMsg( Global, "Tcp: AppId = %i\n", AppId );
#endif
	return( AppId );
}
#endif

#ifndef	TCPOVL
static LONG	cdecl	TcpThread( BYTE *Dummy )
#else
WORD	main( int ArgC, const char *ArgV[] )
#endif
{
	WORD	AppId, Global[15];
#ifdef	DEBUG
	DebugMsg( Global, "TcpThread\n" );
#endif
	if(( AppId = MT_appl_init( Global )) != -1 )
	{
		LONG	Ret = 0, MemCounter = 0;
		WORD	ClientAppId, ClientWinId;
		WORD	Msg[8], Quit = 0, Connected = 0;
		EVNT	Events;
		WORD	SocketHandle = -1;
		WORD	RecPufLenL = RecPufLen;
		BYTE	*RecPuf = malloc( RecPufLenL );
		void	*TcpMsgPuf = NULL;
		WORD	SaveStdin, SaveStdout, NewStd[2], ExtFlag = 0;
#ifdef	DEBUG
	DebugMsg( Global, "TcpThread: AppId = %i\n", AppId );
#endif
		while( !Quit || ( Quit && MemCounter ))
		{
			if( Connected )
				MT_EVNT_multi( MU_MESAG + MU_TIMER, 0, 0, 0, 0L, 0L, 200, &Events, Global );
			else
				MT_EVNT_multi( MU_MESAG, 0, 0, 0, 0L, 0L, 0, &Events, Global );

			TcpMessage( NULL, &TcpMsgPuf, -1, Global );

			if( Events.mwhich & MU_MESAG )
			{
				switch( Events.msg[0] )
				{
					case	TCP_CMD:
					{
						switch( Events.msg[4] )
						{
							case	TCP_init:
							{
#ifdef	DRACONIS
								WORD	Ret = E_OK;
								if( get_connected() == -1 )
									Ret = SE_NINSTALL;
#endif
#ifdef	ICONNECT
								WORD	Ret = sock_init();
								if( Ret == E_OK && !StipFlag )
								{
									USIS_REQUEST  ur; 
									ur.request = UR_PROXY_IP;
									ur.free1 = "stip";
									ur.free2 = NULL;
									if( usis_query( &ur ) == UA_FOUND )
										StipFlag = 1;
									else
										StipFlag = -1;
								}
#endif
#ifdef	DEBUG
	DebugMsg( Global, "TcpThread (TCP_init): sock_init() = %i\n", Ret );
#endif
								ClientAppId = Events.msg[1];
								ClientWinId = Events.msg[3];
#ifdef	DEBUG
	DebugMsg( Global, "TcpThread (TCP_init): Client-AppId = %i\n", ClientAppId );
	DebugMsg( Global, "TcpThread (TCP_init): Client-WinId = %i\n", ClientWinId );
#endif
								Msg[0] = TCP_ACK;
								Msg[1] = AppId;
								Msg[2] = 0;
								Msg[3] = Events.msg[3];
								Msg[4] = TCP_init;
								Msg[7] = Ret;
								TcpMessage( Msg, &TcpMsgPuf, Events.msg[1], Global );
								break;

							}
							case	TCP_socket:
							{
								SocketHandle = socket( AF_INET, SOCK_STREAM, IPPROTO_TCP );
								Msg[0] = TCP_ACK;
								Msg[1] = AppId;
								Msg[2] = 0;
								Msg[3] = Events.msg[3];
								Msg[4] = TCP_socket;
								Msg[7] = SocketHandle;
								TcpMessage( Msg, &TcpMsgPuf, Events.msg[1], Global );
								break;
							}
							case	TCP_gethostbyname:
							{
#ifdef	DRACONIS
								struct hostent	*He;
								BYTE	*c = *( BYTE ** )&( Events.msg[5] );
								if( isdigit( c[0] ))
								{
									*( long * )&( Msg[5] ) = inet_addr( *( BYTE ** )&( Events.msg[5] ));
									Msg[0] = TCP_ACK;
									Msg[1] = AppId;
									Msg[2] = 0;
									Msg[3] = Events.msg[3];
									Msg[4] = TCP_gethostbyname;
									Msg[7] = E_OK;
									if( !HostnameFlag )
									{
										gethostname( Hostname, 256 );
										if( strlen( Hostname ) == 0 )
										{
											int	len;
											struct sockaddr_in	sin;
											getsockname( SocketHandle, ( struct sockaddr * ) &sin, &len );
											strcpy( Hostname, inet_ntoa( sin.sin_addr ));
										}
										HostnameFlag = 1;
#ifdef	TCPOVL
										{
											WORD	M[8];
											M[0] = TCP_ACK;
											M[1] = AppId;
											M[2] = 0;
											M[3] = Events.msg[3];
											M[4] = TCP_hostname;
											*( BYTE **)&M[5] = Hostname;
											TcpMessage( M, &TcpMsgPuf, Events.msg[1], Global );
										}
#endif
									}
									TcpMessage( Msg, &TcpMsgPuf, Events.msg[1], Global );
									break;
								}
								
#endif
#ifdef	ICONNECT
								hostent	*He;
#endif
								Msg[0] = TCP_ACK;
								Msg[1] = AppId;
								Msg[2] = 0;
								Msg[3] = Events.msg[3];
								Msg[4] = TCP_gethostbyname;
								He = gethostbyname( *( BYTE ** )&( Events.msg[5] ));
								if( He && He->h_addr )
								{
									*( long * )&( Msg[5] ) = *( long * ) He->h_addr;
									Msg[7] = E_OK;
									if( !HostnameFlag )
									{
										gethostname( Hostname, 256 );
#ifdef	DRACONIS
										if( strlen( Hostname ) == 0 )
										{
											int	len;
											struct sockaddr_in	sin;
											getsockname( SocketHandle, ( struct sockaddr * ) &sin, &len );
											strcpy( Hostname, inet_ntoa( sin.sin_addr ));
										}
#endif
										HostnameFlag = 1;
#ifdef	TCPOVL
										{
											WORD	M[8];
											M[0] = TCP_ACK;
											M[1] = AppId;
											M[2] = 0;
											M[3] = Events.msg[3];
											M[4] = TCP_hostname;
											*( BYTE **)&M[5] = Hostname;
											TcpMessage( M, &TcpMsgPuf, Events.msg[1], Global );
										}
#endif
									}
								}
								else
									Msg[7] = ERROR;
								TcpMessage( Msg, &TcpMsgPuf, Events.msg[1], Global );
								break;
							}
							case	TCP_connect:
							{
#ifdef	DRACONIS
								struct sockaddr_in	SockAddrIn;
#endif
#ifdef	ICONNECT
								sockaddr_in	SockAddrIn;
#endif
								Msg[0] = TCP_ACK;
								Msg[1] = AppId;
								Msg[2] = 0;
								Msg[3] = Events.msg[3];
								Msg[4] = TCP_connect;
								SockAddrIn.sin_family = AF_INET;
								SockAddrIn.sin_port = Events.msg[7];
#ifdef	DRACONIS
								memcpy( &SockAddrIn.sin_addr.s_addr, &( Events.msg[5] ), sizeof( long ));
#endif
#ifdef	ICONNECT
								SockAddrIn.sin_addr = *( long * )&( Events.msg[5] );
#endif
#ifdef	DRACONIS
								if(( Msg[7] = connect( SocketHandle, ( struct sockaddr * ) &SockAddrIn, (int) sizeof( struct sockaddr_in ))) == E_OK )
#endif
#ifdef	ICONNECT
								if(( Msg[7] = connect( SocketHandle, &SockAddrIn, (int) sizeof( sockaddr_in ))) == E_OK )
#endif
								{
#ifdef	ICONNECT
									sfcntl( SocketHandle, F_SETFL, O_NONBLOCK );
#endif
									Connected = 1;
								}
								TcpMessage( Msg, &TcpMsgPuf, Events.msg[1], Global );
								break;
							}
							case	TCP_close:
							{
								if( SocketHandle != -1 )
								{
								shutdown( SocketHandle, 2 );
#ifdef	DRACONIS
								close_socket( SocketHandle );
#endif
#ifdef	ICONNECT
								sclose( SocketHandle );
#endif
								}
								Msg[0] = TCP_ACK;
								Msg[1] = AppId;
								Msg[2] = 0;
								Msg[3] = Events.msg[3];
								Msg[4] = TCP_close;
								TcpMessage( Msg, &TcpMsgPuf, Events.msg[1], Global );
								Quit = 1;
								break;
							}
							case	TCP_out:
							{
/*								{
									FILE	*File;
									File = fopen( "c:\\tmp\\Chatter.log", "a" );
									fwrite( *( BYTE ** )&( Events.msg[5] ), 1, Events.msg[7], File );
									fclose( File );
								}	*/
#ifdef	DEBUG_NO_CONNECTION
/*printf("%s\n",*( BYTE ** )&( Events.msg[5] ));*/
#endif
								if( send( SocketHandle, *( BYTE ** )&( Events.msg[5] ), Events.msg[7], 0 ) == Events.msg[7] )
								{								
									Msg[0] = TCP_ACK;
									Msg[1] = AppId;
									Msg[2] = 0;
									Msg[3] = Events.msg[3];
									Msg[4] = TCP_out;
									Msg[5] = Events.msg[5];
									Msg[6] = Events.msg[6];
									TcpMessage( Msg, &TcpMsgPuf, Events.msg[1], Global );
								}
								else
								{
									Msg[0] = TCP_CMD;
									Msg[1] = AppId;
									Msg[2] = 0;
									Msg[3] = Events.msg[3];
									Msg[4] = TCP_closed;
									Msg[7] = ( WORD ) Ret;
									TcpMessage( Msg, &TcpMsgPuf, ClientAppId, Global );
									Connected = 0;
								}
								break;
							}
							case	TCP_rx:
							{
								Msg[0] = TCP_ACK;
								Msg[1] = AppId;
								Msg[2] = 0;
								Msg[3] = Events.msg[3];
								Msg[4] = TCP_rx;
								Msg[7] = ERROR;
								TcpMessage( Msg, &TcpMsgPuf, Events.msg[1], Global );
								break;
							}
							case	TCP_tx:
							{
								Msg[0] = TCP_ACK;
								Msg[1] = AppId;
								Msg[2] = 0;
								Msg[3] = Events.msg[3];
								Msg[4] = TCP_tx;
								Msg[7] = ERROR;
								TcpMessage( Msg, &TcpMsgPuf, Events.msg[1], Global );
								break;
							}
							case	TCP_bind:
							{
#ifdef	DRACONIS
								struct sockaddr_in	SockAddrIn;
#endif
#ifdef	ICONNECT
								sockaddr_in	SockAddrIn;
#endif
								Msg[0] = TCP_ACK;
								Msg[1] = AppId;
								Msg[2] = 0;
								Msg[3] = Events.msg[3];
								Msg[4] = TCP_bind;
								SockAddrIn.sin_family = AF_INET;
								SockAddrIn.sin_port = 0;
#ifdef	DRACONIS
/*								if(( Msg[7] = 	( SocketHandle, ( struct sockaddr * ) &SockAddrIn, (int) sizeof( struct sockaddr_in ))) == E_OK )	*/
								SockAddrIn.sin_addr.s_addr = 0;
								if( 1 )
#endif
#ifdef	ICONNECT
								if(( Msg[7] = bind( SocketHandle, &SockAddrIn, (int) sizeof( sockaddr_in ))) == E_OK )
#endif
								{
#ifdef	DRACONIS
									int	LenSaddr = (int) sizeof( struct sockaddr_in );
									listen( SocketHandle, 1 );
									getsockname( SocketHandle, ( struct sockaddr * ) &SockAddrIn, &LenSaddr );
									*( long * )&( Msg[5] ) = SockAddrIn.sin_addr.s_addr;
#endif
#ifdef	ICONNECT
									int	LenSaddr = (int) sizeof( sockaddr_in );
									getsockname( SocketHandle, &SockAddrIn, &LenSaddr );
									*( long * )&( Msg[5] ) = SockAddrIn.sin_addr;
#endif
									Msg[7] = SockAddrIn.sin_port;
								}
								TcpMessage( Msg, &TcpMsgPuf, Events.msg[1], Global );
								break;
							}
							case	TCP_accept:
							{
#ifdef	ICONNECT
								listen( SocketHandle, 1 );
								sfcntl( SocketHandle, F_SETFL, O_NONBLOCK );
#endif
								Connected = 2;
								break;
							}
						}
						break;
					}
					case	TCP_ACK:
					{
						switch( Events.msg[4] )
						{
							case	TCP_in:
								free( *( BYTE ** )&( Events.msg[5] ));
								MemCounter--;
								break;
						}
						break;
					}
				}
			}

			if(( Events.mwhich & MU_TIMER ) && !Quit )
			{
				LONG	Ret;
				if( Connected == 1 )
				{
					int nx;
#ifdef	DRACONIS
					struct fd_set fd_chk1, fd_chk2;
					struct timeval tval;
#endif
#ifdef	ICONNECT
					fd_set fd_chk1, fd_chk2;
					timeval tval;
#endif
					FD_ZERO(&fd_chk1);
					FD_SET(SocketHandle, &fd_chk1);
					FD_ZERO(&fd_chk2);
					FD_SET(SocketHandle, &fd_chk2);
		
					tval.tv_sec = 0;
					tval.tv_usec = 500;

#ifdef	ICONNECT
					if( StipFlag == 1 )
					{
						nx = select(SocketHandle + 1, &fd_chk1, &fd_chk2, NULL, NULL );
						if( nx && FD_ISSET( SocketHandle, &fd_chk1 ))
							Ret = recv( SocketHandle, RecPuf, RecPufLenL, 0 );
						else
							Ret = EWOULDBLOCK;
					}
					else				
						Ret = recv( SocketHandle, RecPuf, RecPufLenL, 0 );
#endif
#ifdef	DRACONIS
					nx = select(SocketHandle + 1, &fd_chk1, &fd_chk2, NULL, &tval);
					if( nx && FD_ISSET( SocketHandle, &fd_chk1 ))
						Ret = recv( SocketHandle, RecPuf, RecPufLenL, 0 );
					else
					{
						if( send( SocketHandle, "", 0, 0 ) != 0 )
							Ret = -1;
						else
							Ret = EWOULDBLOCK;
					}
#endif
				}
				else	if( Connected == 2 )
				{
#ifdef	DRACONIS
					int	LenSaddr = (int) sizeof( struct sockaddr_in );
					struct sockaddr_in	SockAddrIn;

					Ret = accept( SocketHandle, ( struct sockaddr * ) &SockAddrIn, &LenSaddr );

#endif
#ifdef	ICONNECT
					int	LenSaddr = (int) sizeof( sockaddr_in );
					sockaddr_in	SockAddrIn;
					Ret = accept( SocketHandle, &SockAddrIn, &LenSaddr );
#endif
				}
				if( Ret > 0 && Connected == 1 )
				{
					Msg[0] = TCP_CMD;
					Msg[1] = AppId;
					Msg[2] = 0;
					Msg[3] = ClientWinId;
					Msg[4] = TCP_in;
					*( BYTE ** )&( Msg[5] ) = RecPuf;
					MemCounter++;
					Msg[7] = ( WORD ) Ret;
					RecPuf = malloc( RecPufLenL );
					TcpMessage( Msg, &TcpMsgPuf, ClientAppId, Global );
				}
				else	if( Ret > 0 && Connected == 2 )
				{
					Msg[0] = TCP_ACK;
					Msg[1] = AppId;
					Msg[2] = 0;
					Msg[3] = ClientWinId;
					Msg[4] = TCP_accept;
					Msg[7] = ( WORD ) Ret;
					TcpMessage( Msg, &TcpMsgPuf, ClientAppId, Global );
#ifdef	DRACONIS
					close_socket( SocketHandle );
#endif
#ifdef	ICONNECT
					sclose( SocketHandle );
#endif
					SocketHandle = Ret;
					Connected = 1;
				}
				else	if( Ret != EWOULDBLOCK )
				{
					Msg[0] = TCP_CMD;
					Msg[1] = AppId;
					Msg[2] = 0;
					Msg[3] = ClientWinId;
					Msg[4] = TCP_closed;
					Msg[7] = ( WORD ) Ret;
					TcpMessage( Msg, &TcpMsgPuf, ClientAppId, Global );
					Connected = 0;
				}
			}
		}
		while( TcpMsgPuf )
		{
			TcpMessage( NULL, &TcpMsgPuf, -1, Global );
			MT_appl_yield( Global );
		}

#ifdef	DEBUG
	DebugMsg( Global, "TcpThread: appl_exit()\n" );
#endif
		if( RecPuf )
			free( RecPuf );
		MT_appl_exit( Global );
#ifndef	TCPOVL
		return(( LONG ) ClientWinId );
#else
		return( ClientWinId );
#endif
	}
	else
	{
		Con( "Error: No AES" ); crlf;
		return( -1 );
	}
}

WORD	TcpMessage( WORD Msg[8], void **MsgPuf, WORD AppId, WORD Global[15] )
{
	MSG_DATA	*MsgData = *MsgPuf, *Tmp;

	if( AppId != -1 )
	{
		AppendMessage( Msg, &MsgData, AppId );
		*MsgPuf = MsgData;
	}

	while( MsgData )
	{
		if( MT_appl_write( MsgData->AppId, 16, MsgData->Msg, Global ) == 1 )
		{
			Tmp = MsgData;
			MsgData = MsgData->next;
			free( Tmp );
		}
		else
			break;
		MT_appl_yield( Global );
	}
	*MsgPuf = MsgData;
	return( E_OK );
}

#ifndef	TCPOVL
WORD	TcpMessageTime( WORD Msg[8], void **MsgPuf, WORD AppId, WORD Global[15] )
{
	MSG_STAMP	*MsgStamp = *MsgPuf;

	if( AppId != -1 )
	{
		if( !MsgStamp )
		{
			MsgStamp = malloc( sizeof( MSG_STAMP ));
			if( MsgStamp )
			{
				MsgStamp->First = NULL;
				MsgStamp->Last = ( clock_t ) 0;
				*MsgPuf = MsgStamp;
			}
		}
		AppendMessage( Msg, &( MsgStamp->First ), AppId );
	}

	if( MsgStamp )
	{
		MSG_DATA	*Tmp;
		while( MsgStamp->First )
		{
			Tmp = MsgStamp->First;
			if( MT_appl_write( Tmp->AppId, 16, Tmp->Msg, Global ) == 1 )
			{
				MsgStamp->First = Tmp->next;
				MsgStamp->Last = clock();
				free( Tmp );
			}
			else
				break;
		}
	}

	if( MsgStamp )
	{
		if( !MsgStamp->First )
		{
			free( MsgStamp );
			*MsgPuf = NULL;
		}
		else
			return( 1 );
	}
	return( 0 );
}
#endif

static void	AppendMessage( WORD Msg[8], MSG_DATA **MsgPuf, WORD AppId )
{
	MSG_DATA	*MsgData = malloc( sizeof( MSG_DATA ));
	if( MsgData )
	{
		WORD	i;
		for( i = 0; i < 8; i++ )
			MsgData->Msg[i] = Msg[i];
		MsgData->AppId = AppId;
		MsgData->next = NULL;
		if( *MsgPuf == NULL )
			 *MsgPuf = MsgData;
		else
		{
			MSG_DATA	*Tmp = *MsgPuf;
			while( Tmp->next )
				Tmp = Tmp->next;
			Tmp->next = MsgData;
		}
	}
}