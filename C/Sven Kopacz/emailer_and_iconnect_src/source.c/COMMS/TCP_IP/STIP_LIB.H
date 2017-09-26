#ifndef _STIPLIB_H_
#define _STIPLIB_H_

#include "stip_def.h"

typedef void (TCP_Create_CB)(short result, ConnectionHandle handle);
typedef void (TCP_ActiveOpen_CB)(short result, ConnectionHandle handle, ushort localPort);
typedef void (TCP_PassiveOpen_CB)(short result, ConnectionHandle handle, ulong remoteIPAddress, ushort remotePort, ushort localPort);
typedef void (TCP_GetBytesAvail_CB)(short result, ConnectionHandle handle, ulong bytesAvailable);
typedef void (TCP_Receive_CB)(short result, ConnectionHandle handle, void *buffer, ulong bytesReceived, ushort urgent);
typedef void (TCP_Send_CB)(short result, ConnectionHandle handle);
typedef void (TCP_GetStatus_CB)(short result, ConnectionHandle handle, ushort connectionState, ulong unacknowledgedData, ulong sendUnacknowledged, ulong unreadData);
typedef void (TCP_Close_CB)(short result, ConnectionHandle handle);
typedef void (TCP_Abort_CB)(short result, ConnectionHandle handle);
typedef void (TCP_Release_CB)(short result, ConnectionHandle handle);
typedef void (UDP_Create_CB)(short result, ConnectionHandle handle, ushort localPort);
typedef void (UDP_Read_CB)(short result, ConnectionHandle handle, ulong remoteIPAddress, ushort remotePort, void *buffer, ulong bytesRead);
typedef void (UDP_Write_CB)(short result, ConnectionHandle handle);
typedef void (UDP_Release_CB)(short result, ConnectionHandle handle);
typedef void (UDP_GetMTUSize_CB)(short result, ulong mtuSize);
typedef void (DNR_CB)(short result, ulong addr);
typedef void (GetMyIPAddr_CB)(short result, ulong addr, ulong mask);
typedef void (GetDNRIPAddr_CB)(short result, ulong addr);
typedef void (Test_CB)(void);

Boolean TCP_Create(TCP_Create_CB *cb);Boolean TCP_ActiveOpen(ConnectionHandle handle, ulong connectionTimeout, IPAddress remoteIPAddress, ushort remotePort, ushort localPort, TCP_ActiveOpen_CB *cb);Boolean TCP_PassiveOpen(ConnectionHandle handle, ulong connectionTimeout, ulong commandTimeout, IPAddress remoteIPAddress, ushort remotePort, ushort localPort, TCP_PassiveOpen_CB *cb);Boolean TCP_GetBytesAvail(ConnectionHandle handle, TCP_GetBytesAvail_CB *cb);Boolean TCP_Receive(ConnectionHandle handle, ulong commandTimeout, ulong bytesToReceive, TCP_Receive_CB *cb);Boolean TCP_Send(ConnectionHandle handle, void *buffer, ulong bytesToSend, ushort urgent, ushort push, TCP_Send_CB *cb);Boolean TCP_GetStatus(ConnectionHandle handle, TCP_GetStatus_CB *cb);Boolean TCP_Close(ConnectionHandle handle, TCP_Close_CB *cb);Boolean TCP_Abort(ConnectionHandle handle, TCP_Abort_CB *cb);Boolean TCP_Release(ConnectionHandle handle, TCP_Release_CB *cb);Boolean UDP_Create(ushort localPort, UDP_Create_CB *cb);Boolean UDP_Read(ConnectionHandle handle, ulong commandTimeout, UDP_Read_CB *cb);Boolean UDP_Write(ConnectionHandle handle, IPAddress remoteIPAddress, ushort remotePort, void *buffer, ulong bytesToWrite, UDP_Write_CB *cb);Boolean UDP_Release(ConnectionHandle handle, UDP_Release_CB *cb);Boolean UDP_GetMTUSize(IPAddress remoteIPAddress, UDP_GetMTUSize_CB *cb);Boolean DNR(IPAddress remoteIPAddress, DNR_CB *cb);
Boolean GetMyIPAddr(GetMyIPAddr_CB *cb);
Boolean GetDNRIPAddr(GetDNRIPAddr_CB *cb);
Boolean Test(Test_CB *cb);
void	Wait(void);
#endif
