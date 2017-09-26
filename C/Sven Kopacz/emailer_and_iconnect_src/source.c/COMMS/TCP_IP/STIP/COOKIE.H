#ifndef _COOKIE_H_
#define _COOKIE_H_

typedef Boolean (TCP_Create_Func)(TCP_Create_CB *cb);typedef Boolean (TCP_ActiveOpen_Func)(ConnectionHandle handle, ulong connectionTimeout, IPAddress remoteIPAddress, ushort remotePort, ushort localPort, TCP_ActiveOpen_CB *cb);typedef Boolean (TCP_PassiveOpen_Func)(ConnectionHandle handle, ulong connectionTimeout, ulong commandTimeout, IPAddress remoteIPAddress, ushort remotePort, ushort localPort, TCP_PassiveOpen_CB *cb);typedef Boolean (TCP_GetBytesAvail_Func)(ConnectionHandle handle, TCP_GetBytesAvail_CB *cb);typedef Boolean (TCP_Receive_Func)(ConnectionHandle handle, ulong commandTimeout, ulong bytesToReceive, TCP_Receive_CB *cb);typedef Boolean (TCP_Send_Func)(ConnectionHandle handle, void *buffer, ulong bytesToSend, ushort urgent, ushort push, TCP_Send_CB *cb);typedef Boolean (TCP_Close_Func)(ConnectionHandle handle, TCP_Close_CB *cb);typedef Boolean (TCP_GetStatus_Func)(ConnectionHandle handle, TCP_GetStatus_CB *cb);typedef Boolean (TCP_Abort_Func)(ConnectionHandle handle, TCP_Abort_CB *cb);typedef Boolean (TCP_Release_Func)(ConnectionHandle handle, TCP_Release_CB *cb);typedef Boolean (UDP_Create_Func)(ushort localPort, UDP_Create_CB *cb);typedef Boolean (UDP_Read_Func)(ConnectionHandle handle, ulong commandTimeout, UDP_Read_CB *cb);typedef Boolean (UDP_Write_Func)(ConnectionHandle handle, IPAddress remoteIPAddress, ushort remotePort, void *buffer, ulong bytesToWrite, UDP_Write_CB *cb);typedef Boolean (UDP_Release_Func)(ConnectionHandle handle, UDP_Release_CB *cb);typedef Boolean (UDP_GetMTUSize_Func)(IPAddress remoteIPAddress, UDP_GetMTUSize_CB *cb);typedef Boolean (DNR_Func)(IPAddress remoteIPAddress, DNR_CB *cb);typedef Boolean	(GetMyIPAddr_Func)(GetMyIPAddr_CB *cb);typedef Boolean	(GetDNRIPAddr_Func)(GetDNRIPAddr_CB *cb);typedef Boolean	(Test_Func)(Test_CB *cb);typedef void 	(Wait_Func)(void);

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
