#ifndef _STIP_H_
#define _STIP_H_

#include "stip_def.h"

#define GESTALT_SELECTOR				'STip'

#define MSG_SIZE						32500	/* MAX_DATA_SIZE + 500 */

#define MSG_NONE						0

#define MSG_TCP_CREATE					1	/* ST -> Mac */
#define MSG_TCP_ACTIVE_OPEN				2
#define MSG_TCP_PASSIVE_OPEN			3
#define MSG_TCP_GET_BYTES_AVAIL			4
#define MSG_TCP_RECEIVE					5
#define MSG_TCP_SEND					6
#define MSG_TCP_CLOSE					7
#define MSG_TCP_ABORT					8
#define MSG_TCP_RELEASE					9
#define MSG_UDP_CREATE					10
#define MSG_UDP_READ					11
#define MSG_UDP_WRITE					12
#define MSG_UDP_RELEASE					13
#define MSG_UDP_GET_MTU_SIZE			14
#define MSG_DNR							15
#define MSG_TEST						16
#define MSG_GET_MY_IP_ADDR				17
#define MSG_GET_DNR_IP_ADDR				18
#define MSG_TCP_GET_STATUS				19

#define MSG_TCP_CREATE_RESP			 	51	/* Mac -> ST */
#define MSG_TCP_ACTIVE_OPEN_RESP		52
#define MSG_TCP_PASSIVE_OPEN_RESP		53
#define MSG_TCP_GET_BYTES_AVAIL_RESP	54
#define MSG_TCP_RECEIVE_RESP			55
#define MSG_TCP_SEND_RESP				56
#define MSG_TCP_CLOSE_RESP				57
#define MSG_TCP_ABORT_RESP				58
#define MSG_TCP_RELEASE_RESP			59
#define MSG_UDP_CREATE_RESP				60
#define MSG_UDP_READ_RESP				61
#define MSG_UDP_WRITE_RESP				62	
#define MSG_UDP_RELEASE_RESP			63
#define MSG_UDP_GET_MTU_SIZE_RESP		64
#define MSG_DNR_RESP					65
#define MSG_TEST_RESP					66
#define MSG_GET_MY_IP_ADDR_RESP			67
#define MSG_GET_DNR_IP_ADDR_RESP		68
#define MSG_TCP_GET_STATUS_RESP			69

#define MAX_ADDITIONAL_RECEIVE			10000

typedef struct
{
	ulong				userData;
} TCPCreateRec;

typedef struct
{
	ulong				userData;
	short				result;
	ConnectionHandle	handle;
} TCPCreateRespRec;


typedef struct
{
	ulong				userData;
	ConnectionHandle	handle;
	ushort				connectionTimeout;	/* seconds */
	IPAddress			remoteIPAddress;
	ushort				remotePort;
	ushort				localPort;			/* use 0 for an unused port */
} TCPActiveOpenRec;

typedef struct
{
	ulong				userData;
	short				result;
	ConnectionHandle	handle;
	ushort				localPort;
} TCPActiveOpenRespRec;


typedef struct
{
	ulong				userData;
	ConnectionHandle	handle;
	ushort				connectionTimeout;	/* seconds */
	ushort 				commandTimeout;		/* use 0 for infinity; seconds */
	IPAddress			remoteIPAddress;	/* use an empty string to allow connections with any IP address */
	ushort 				remotePort;			/* use 0 to allow connections with any port */
	ushort 				localPort;			/* use 0 for an unused port */
} TCPPassiveOpenRec;

typedef struct
{
	ulong				userData;
	short				result;
	ConnectionHandle	handle;
	ulong				remoteIPAddress;
	ushort 				remotePort;
	ushort 				localPort;
} TCPPassiveOpenRespRec;


typedef struct
{
	ulong				userData;
	ConnectionHandle	handle;
} TCPGetBytesAvailRec;

typedef struct
{
	ulong				userData;
	short				result;
	ConnectionHandle	handle;
	ulong				bytesAvailable;
} TCPGetBytesAvailRespRec;


typedef struct
{
	ulong				userData;
	ConnectionHandle	handle;
	ushort				commandTimeout;		/* seconds */
	ulong				bytesToReceive;
} TCPReceiveRec;

typedef struct
{
	ulong				userData;
	short				result;
	ConnectionHandle	handle;
	ulong				bytesToReceive;
	ulong				bytesReceived;		/* following in the message buffer */
	ushort				urgent;
} TCPReceiveRespRec;


typedef struct
{
	ulong				userData;
	ConnectionHandle	handle;
	ulong				bytesToSend;		/* following in the message buffer */
	ushort				urgent;
	ushort				push;
} TCPSendRec;

typedef struct
{
	ulong				userData;
	short				result;
	ConnectionHandle	handle;
} TCPSendRespRec;


typedef struct
{
	ulong				userData;
	ConnectionHandle	handle;
} TCPGetStatusRec;

typedef struct
{
	ulong				userData;
	short				result;
	ConnectionHandle	handle;
	ushort				connectionState;
	ulong				unacknowledgedData;
	ulong				sendUnacknowledged;
	ulong				unreadData;
} TCPGetStatusRespRec;


typedef struct
{
	ulong				userData;
	ConnectionHandle	handle;
} TCPCloseRec;

typedef struct
{
	ulong				userData;
	short				result;
	ConnectionHandle	handle;
} TCPCloseRespRec;


typedef struct
{
	ulong				userData;
	ConnectionHandle	handle;
} TCPAbortRec;

typedef struct
{
	ulong				userData;
	short				result;
	ConnectionHandle	handle;
} TCPAbortRespRec;


typedef struct
{
	ulong				userData;
	ConnectionHandle	handle;
} TCPReleaseRec;

typedef struct
{
	ulong				userData;
	short				result;
	ConnectionHandle	handle;
} TCPReleaseRespRec;


typedef struct
{
	ulong				userData;
	ushort 				localPort;
} UDPCreateRec;

typedef struct
{
	ulong				userData;
	short				result;
	ConnectionHandle	handle;
	ushort 				localPort;
} UDPCreateRespRec;


typedef struct
{
	ulong				userData;
	ConnectionHandle	handle;
	ushort				commandTimeout;		/* seconds */
} UDPReadRec;

typedef struct
{
	ulong				userData;
	short				result;
	ConnectionHandle	handle;
	ulong				bytesRead;			/* following in the message buffer */
	ulong				remoteIPAddress;
	ushort				remotePort;
} UDPReadRespRec;


typedef struct
{
	ulong				userData;
	ConnectionHandle	handle;
	IPAddress			remoteIPAddress;
	ushort				remotePort;
	ulong				bytesToWrite;		/* following in the message buffer */
} UDPWriteRec;

typedef struct
{
	ulong				userData;
	short				result;
	ConnectionHandle	handle;
} UDPWriteRespRec;


typedef struct
{
	ulong				userData;
	ConnectionHandle	handle;
} UDPReleaseRec;

typedef struct
{
	ulong				userData;
	short				result;
	ConnectionHandle	handle;
} UDPReleaseRespRec;


typedef struct
{
	ulong				userData;
	IPAddress			remoteIPAddress;
} UDPGetMTUSizeRec;

typedef struct
{
	ulong				userData;
	short				result;
	ulong				mtuSize;
} UDPGetMTUSizeRespRec;


typedef struct
{
	ulong				userData;
	IPAddress			remoteIPAddress;
} DNRRec;

typedef struct
{
	ulong				userData;
	short				result;
	ulong				addr;
} DNRRespRec;


typedef struct
{
	ulong				userData;
} TestRec;

typedef struct
{
	ulong				userData;
} TestRespRec;


typedef struct
{
	ulong				userData;
} GetMyIPAddrRec;

typedef struct
{
	ulong				userData;
	short				result;
	ulong				addr;
	ulong				mask;
} GetMyIPAddrRespRec;


typedef struct
{
	ulong				userData;
} GetDNRIPAddrRec;

typedef struct
{
	ulong				userData;
	short				result;
	ulong				addr;
} GetDNRIPAddrRespRec;


typedef struct
{
	ushort	type;		/* type of the message */
	ushort	size;		/* size of the message */
	uchar	msg[MSG_SIZE];	/* message buffer */
} Message;

typedef struct
{
	Message	macMsg;			/* message for the mac */
	Message	stMsg;			/* message for the st */
} STInterface;

/* The "macMsg.type" and "stMsg.type" entries are set to "MSG_NONE" by default. If a part of the */
/* software wants to send a message to the other part, it sets up the "msg" and "size" entries */
/* and then overwrites the "type" entry with the intended type of the message. */
/* The receiver polls this entry. If it recognizes that the entry does not contain */
/* "MSG_NONE" it immediately copies the message and sets the "type" entry back to */
/* "MSG_NONE". So the sender knows that it can send the next message. */

#endif
