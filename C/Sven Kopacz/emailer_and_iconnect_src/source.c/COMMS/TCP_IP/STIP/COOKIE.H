#ifndef _COOKIE_H_
#define _COOKIE_H_

typedef Boolean (TCP_Create_Func)(TCP_Create_CB *cb);

typedef struct
{
	ushort					version;

	TCP_Create_Func			*tcpCreate;
	TCP_ActiveOpen_Func		*tcpActiveOpen;
	TCP_PassiveOpen_Func	*tcpPassiveOpen;
	TCP_GetBytesAvail_Func	*tcpGetBytesAvail;
	TCP_Receive_Func		*tcpReceive;
	TCP_Send_Func			*tcpSend;
	TCP_GetStatus_Func		*tcpGetStatus;
	TCP_Close_Func			*tcpClose;
	TCP_Abort_Func			*tcpAbort;
	TCP_Release_Func		*tcpRelease;
	UDP_Create_Func			*udpCreate;
	UDP_Read_Func			*udpRead;
	UDP_Write_Func			*udpWrite;
	UDP_Release_Func		*udpRelease;
	UDP_GetMTUSize_Func		*udpGetMTUSize;
	DNR_Func				*dnr;
	GetMyIPAddr_Func		*getMyIPAddr;
	GetDNRIPAddr_Func		*getDNRIPAddr;
	Test_Func				*test;
	Wait_Func				*wait;
} STipCookie;

#endif