#ifndef	__TCP__
#define	__TCP__

#include	"Window.h"

#define	TCP_init				0x0000
#define	TCP_close			0x0001
#define	TCP_gethostbyname	0x0002
#define	TCP_socket			0x0003
#define	TCP_connect			0x0004
#define	TCP_in				0x0005
#define	TCP_out				0x0006
#define	TCP_closed			0x0007
#define	TCP_rx				0x0008
#define	TCP_tx				0x0009
#define	TCP_bind				0x000a
#define	TCP_accept			0x000b
#define	TCP_hostname		0x000c

/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/
WORD	Tcp( WORD Global[15] );
WORD	TcpMessage( WORD Msg[8], void **MsgPuf, WORD AppId, WORD Global[15] );
WORD	TcpMessageTime( WORD Msg[8], void **MsgPuf, WORD AppId, WORD Global[15] );

#endif