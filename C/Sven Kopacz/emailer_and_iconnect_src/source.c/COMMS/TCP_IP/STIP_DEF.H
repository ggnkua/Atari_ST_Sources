#ifndef _STIP_DEF_H_
#define _STIP_DEF_H_

#ifndef TRUE
	#define TRUE						1
	#define FALSE						0

	typedef short Boolean;
#endif

#define ERR_NONE						0
#define ERR_MAC_CALL					1
#define ERR_INVALID_PARAMETER			2
#define ERR_OOM							3
#define ERR_DNR							4
#define ERR_INVALID_HANDLE				5
#define ERR_UDP_TOO_LARGE				6

#define TCP_STATE_CLOSED				0
#define TCP_STATE_LISTEN				2
#define TCP_STATE_SYN_RECEIVED			4
#define TCP_STATE_SYN_SENT				6
#define TCP_STATE_ESTABLISHED			8
#define TCP_STATE_FIN_WAIT1				10
#define TCP_STATE_FIN_WAIT2				12
#define TCP_STATE_CLOSE_WAIT			14
#define TCP_STATE_CLOSING				16
#define TCP_STATE_LAST_ACK				18
#define TCP_STATE_TIME_WAIT				20

#define MAX_DATA_SIZE					32000

#define IP_ADDR_LENGTH					255

typedef char IPAddress[IP_ADDR_LENGTH+1];

#if !defined( __UTYPES__ )
#define __UTYPES__
typedef unsigned char uchar;
typedef	uchar					byte;
typedef unsigned short ushort;
typedef unsigned int uint;
typedef unsigned long ulong;
#endif

typedef ulong ConnectionHandle;

#endif
