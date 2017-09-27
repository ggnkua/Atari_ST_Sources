#ifndef _STIPLIB_H_
#define _STIPLIB_H_


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

Boolean TCP_Create(TCP_Create_CB *cb);
Boolean GetMyIPAddr(GetMyIPAddr_CB *cb);
Boolean GetDNRIPAddr(GetDNRIPAddr_CB *cb);
Boolean Test(Test_CB *cb);
void	Wait(void);
#endif