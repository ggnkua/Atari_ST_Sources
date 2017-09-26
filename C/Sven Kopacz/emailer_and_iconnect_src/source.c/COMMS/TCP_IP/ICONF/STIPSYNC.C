#include <stdio.h>
#include <stdlib.h>
#include <tos.h>
#include <time.h>
#include <string.h>

#include "stip_def.h"
#include "stip_lib.h"
#include "stipsync.h"

#define ERROR(s)
#define UNUSED(x)		x=x;
#define STD_TIMEOUT		60L*CLK_TCK

static short			gReady;
static short			gResult;
static ConnectionHandle	gHandle;
static ushort			gLocalPort;
static ushort			gRemotePort;
static ulong			gRemoteIPAddress;
static ulong			gBytesAvailable;
static uchar			gBuffer[MAX_DATA_SIZE];
static ulong			gBytesReceived;
static ulong			gBytesRead;
static ulong			gMTUSize;
static ushort			gUrgent;
static ushort			gConnectionState;
static ulong			gUnacknowledgedData;
static ulong			gSendUnacknowledged;
static ulong			gUnreadData;
static ulong			gMyIPAddr;
static ulong			gMyIPMask;
static ulong			gDNRIPAddr;

static Boolean WaitReady(ulong timeout)
{
	timeout+=clock();
	do
	{
		if(gReady) return TRUE;
		Wait();
	}
	while(clock()<timeout);
	
	ERROR("WaitReady(): timeout");
	return FALSE;
}

static void TCP_Create_Completion(short result, ConnectionHandle handle)
{
	gResult=result;
	gHandle=handle;

	gReady=TRUE;
}

Boolean TCP_Create_Sync(ConnectionHandle *handle)
{
	gReady=FALSE;
	if(!TCP_Create(TCP_Create_Completion)) return FALSE;
	if(!WaitReady(STD_TIMEOUT)) return FALSE;
	if(gResult!=ERR_NONE) 
	{
		ERROR("TCP_Create_Sync(): error returned");
		return FALSE;
	}
	*handle=gHandle;
	return TRUE;
}

static void TCP_ActiveOpen_Completion(short result, ConnectionHandle handle, ushort localPort)
{
	UNUSED(handle)
	
	gResult=result;
	gLocalPort=localPort;

	gReady=TRUE;
}

Boolean TCP_ActiveOpen_Sync(ConnectionHandle handle, ulong connectionTimeout, IPAddress remoteIPAddress, ushort remotePort, ushort *localPort){
	gReady=FALSE;
	if(!TCP_ActiveOpen(handle,connectionTimeout,remoteIPAddress,remotePort,*localPort,TCP_ActiveOpen_Completion)) return FALSE;
	if(!WaitReady(STD_TIMEOUT)) return FALSE;
	if(gResult!=ERR_NONE) 
	{
		ERROR("TCP_ActiveOpen_Sync(): error returned");
		return FALSE;
	}
	*localPort=gLocalPort;
	return TRUE;
}

static void TCP_PassiveOpen_Completion(short result, ConnectionHandle handle, ulong remoteIPAddress, ushort remotePort, ushort localPort)
{
	UNUSED(handle)
	
	gResult=result;
	gRemoteIPAddress=remoteIPAddress;
	gRemotePort=remotePort;
	gLocalPort=localPort;

	gReady=TRUE;
}

Boolean TCP_PassiveOpen_Sync(ConnectionHandle handle, ulong connectionTimeout, ulong commandTimeout, IPAddress remoteIPAddress, ushort *remotePort, ushort *localPort)
{
	gReady=FALSE;
	if(!TCP_PassiveOpen(handle,connectionTimeout,commandTimeout,remoteIPAddress,*remotePort,*localPort,TCP_PassiveOpen_Completion)) return FALSE;
	if(!WaitReady(commandTimeout*CLK_TCK)) return FALSE;
	if(gResult!=ERR_NONE) 
	{
		ERROR("TCP_PassiveOpen_Sync(): error returned");
		return FALSE;
	}
	*remoteIPAddress=gRemoteIPAddress;
	*remotePort=gRemotePort;
	*localPort=gLocalPort;
	return TRUE;
}
static void TCP_GetBytesAvail_Completion(short result, ConnectionHandle handle, ulong bytesAvailable)
{
	UNUSED(handle)
	
	gResult=result;
	gBytesAvailable=bytesAvailable;

	gReady=TRUE;
}

Boolean TCP_GetBytesAvail_Sync(ConnectionHandle handle, ulong *bytesAvailable)
{
	gReady=FALSE;
	if(!TCP_GetBytesAvail(handle,TCP_GetBytesAvail_Completion)) return FALSE;
	if(!WaitReady(STD_TIMEOUT)) return FALSE;
	if(gResult!=ERR_NONE) 
	{
		ERROR("TCP_GetBytesAvail_Sync(): error returned");
		return FALSE;
	}
	*bytesAvailable=gBytesAvailable;
	return TRUE;
}
static void TCP_Receive_Completion(short result, ConnectionHandle handle, void *buffer, ulong bytesReceived, ushort urgent)
{
	UNUSED(handle)
	
	gResult=result;
	gBytesReceived=bytesReceived;
	gUrgent=urgent;
	
	if(bytesReceived>0)
	{
		memcpy(gBuffer,buffer,bytesReceived);
	}

	gReady=TRUE;
}

Boolean TCP_Receive_Sync(ConnectionHandle handle, ulong commandTimeout, void *buffer, ulong *bytesToReceive, ushort *urgent){
	gReady=FALSE;
	if(!TCP_Receive(handle,commandTimeout,*bytesToReceive,TCP_Receive_Completion)) return FALSE;
	if(!WaitReady(commandTimeout*CLK_TCK)) return FALSE;
	if(gResult!=ERR_NONE)
	{
		ERROR("TCP_Receive_Sync(): error returned");
		return FALSE;
	}
	*bytesToReceive=gBytesReceived;
	*urgent=gUrgent;
	if(gBytesReceived>0)
	{
		memcpy(buffer,gBuffer,gBytesReceived);
	}
	return TRUE;
}

static void TCP_Send_Completion(short result, ConnectionHandle handle)
{
	UNUSED(handle)
	
	gResult=result;

	gReady=TRUE;
}

Boolean TCP_Send_Sync(ConnectionHandle handle, void *buffer, ulong bytesToSend, ushort urgent, ushort push)
{
	gReady=FALSE;
	if(!TCP_Send(handle,buffer,bytesToSend,urgent,push,TCP_Send_Completion)) return FALSE;
	if(!WaitReady(STD_TIMEOUT)) return FALSE;
	if(gResult!=ERR_NONE) 
	{
		ERROR("TCP_Send_Sync(): error returned");
		return FALSE;
	}
	return TRUE;
}
static void TCP_Close_Completion(short result, ConnectionHandle handle)
{
	UNUSED(handle)
	
	gResult=result;

	gReady=TRUE;
}

Boolean TCP_Close_Sync(ConnectionHandle handle)
{
	gReady=FALSE;
	if(!TCP_Close(handle,TCP_Close_Completion)) return FALSE;
	if(!WaitReady(STD_TIMEOUT)) return FALSE;
	if(gResult!=ERR_NONE) 
	{
		ERROR("TCP_Close_Sync(): error returned");
		return FALSE;
	}
	return TRUE;
}
static void TCP_GetStatus_Completion(short result, ConnectionHandle handle, ushort connectionState, ulong unacknowledgedData, ulong sendUnacknowledged, ulong unreadData)
{
	UNUSED(handle)
	
	gResult=result;
	gConnectionState=connectionState;
	gUnacknowledgedData=unacknowledgedData;
	gSendUnacknowledged=sendUnacknowledged;
	gUnreadData=unreadData;

	gReady=TRUE;
}

Boolean TCP_GetStatus_Sync(ConnectionHandle handle, ushort *connectionState, ulong *unacknowledgedData, ulong *sendUnacknowledged, ulong *unreadData)
{
	gReady=FALSE;
	if(!TCP_GetStatus(handle,TCP_GetStatus_Completion)) return FALSE;
	if(!WaitReady(STD_TIMEOUT)) return FALSE;
	if(gResult!=ERR_NONE) 
	{
		ERROR("TCP_GetStatus_Sync(): error returned");
		return FALSE;
	}
	*connectionState=gConnectionState;
	*unacknowledgedData=gUnacknowledgedData;
	*sendUnacknowledged=gSendUnacknowledged;
	*unreadData=gUnreadData;
	return TRUE;
}
static void TCP_Abort_Completion(short result, ConnectionHandle handle)
{
	UNUSED(handle)
	
	gResult=result;

	gReady=TRUE;
}

Boolean TCP_Abort_Sync(ConnectionHandle handle)
{
	gReady=FALSE;
	if(!TCP_Abort(handle,TCP_Abort_Completion)) return FALSE;
	if(!WaitReady(STD_TIMEOUT)) return FALSE;
	if(gResult!=ERR_NONE) 
	{
		ERROR("TCP_Abort_Sync(): error returned");
		return FALSE;
	}
	return TRUE;
}
static void TCP_Release_Completion(short result, ConnectionHandle handle)
{
	UNUSED(handle)
	
	gResult=result;

	gReady=TRUE;
}

Boolean TCP_Release_Sync(ConnectionHandle handle)
{
	gReady=FALSE;
	if(!TCP_Release(handle,TCP_Release_Completion)) return FALSE;
	if(!WaitReady(STD_TIMEOUT)) return FALSE;
	if(gResult!=ERR_NONE) 
	{
		ERROR("TCP_Release_Sync(): error returned");
		return FALSE;
	}
	return TRUE;
}
static void UDP_Create_Completion(short result, ConnectionHandle handle, ushort localPort)
{
	gResult=result;
	gHandle=handle;
	gLocalPort=localPort;

	gReady=TRUE;
}

Boolean UDP_Create_Sync(ConnectionHandle *handle, ushort *localPort)
{
	gReady=FALSE;
	if(!UDP_Create(*localPort,UDP_Create_Completion)) return FALSE;
	if(!WaitReady(STD_TIMEOUT)) return FALSE;
	if(gResult!=ERR_NONE) 
	{
		ERROR("UDP_Create_Sync(): error returned");
		return FALSE;
	}
	*handle=gHandle;
	*localPort=gLocalPort;
	return TRUE;
}

static void UDP_Read_Completion(short result, ConnectionHandle handle, ulong remoteIPAddress, ushort remotePort, void *buffer, ulong bytesRead)
{
	UNUSED(handle)
	
	gResult=result;
	gRemoteIPAddress=remoteIPAddress;
	gRemotePort=remotePort;
	gBytesRead=bytesRead;
	
	if(bytesRead>0)
	{
		memcpy(gBuffer,buffer,bytesRead);
	}

	gReady=TRUE;
}

Boolean UDP_Read_Sync(ConnectionHandle handle, ulong commandTimeout, void *buffer, ulong *bytesRead)
{
	gReady=FALSE;
	if(!UDP_Read(handle,commandTimeout,UDP_Read_Completion)) return FALSE;
	if(!WaitReady(commandTimeout*CLK_TCK)) return FALSE;
	if(gResult!=ERR_NONE) 
	{
		ERROR("UDP_Read_Sync(): error returned");
		return FALSE;
	}
	*bytesRead=gBytesRead;
	if(gBytesRead>0)
	{
		memcpy(buffer,gBuffer,gBytesRead);
	}
	return TRUE;
}
static void UDP_Write_Completion(short result, ConnectionHandle handle)
{
	UNUSED(handle)
	
	gResult=result;

	gReady=TRUE;
}

Boolean UDP_Write_Sync(ConnectionHandle handle, IPAddress remoteIPAddress, ushort remotePort, void *buffer, ulong bytesToWrite)
{
	gReady=FALSE;
	if(!UDP_Write(handle,remoteIPAddress,remotePort,buffer,bytesToWrite,UDP_Write_Completion)) return FALSE;
	if(!WaitReady(STD_TIMEOUT)) return FALSE;
	if(gResult!=ERR_NONE) 
	{
		ERROR("UDP_Write_Sync(): error returned");
		return FALSE;
	}
	return TRUE;
}
static void UDP_Release_Completion(short result, ConnectionHandle handle)
{
	UNUSED(handle)
	
	gResult=result;

	gReady=TRUE;
}

Boolean UDP_Release_Sync(ConnectionHandle handle)
{
	gReady=FALSE;
	if(!UDP_Release(handle,UDP_Release_Completion)) return FALSE;
	if(!WaitReady(STD_TIMEOUT)) return FALSE;
	if(gResult!=ERR_NONE) 
	{
		ERROR("UDP_Release_Sync(): error returned");
		return FALSE;
	}
	return TRUE;
}
static void UDP_GetMTUSize_Completion(short result, ulong mtuSize)
{
	gResult=result;
	gMTUSize=mtuSize;

	gReady=TRUE;
}

Boolean UDP_GetMTUSize_Sync(IPAddress remoteIPAddress, ulong *mtuSize)
{
	gReady=FALSE;
	if(!UDP_GetMTUSize(remoteIPAddress,UDP_GetMTUSize_Completion)) return FALSE;
	if(!WaitReady(STD_TIMEOUT)) return FALSE;
	if(gResult!=ERR_NONE) 
	{
		ERROR("UDP_GetMTUSize_Sync(): error returned");
		return FALSE;
	}
	*mtuSize=gMTUSize;
	return TRUE;
}
static void DNR_Completion(short result, ulong remoteIPAddress)
{
	gResult=result;
	gRemoteIPAddress=remoteIPAddress;

	gReady=TRUE;
}

Boolean DNR_Sync(IPAddress remoteIPAddress, ulong *addr)
{
	gReady=FALSE;
	if(!DNR(remoteIPAddress,DNR_Completion)) return FALSE;
	if(!WaitReady(STD_TIMEOUT)) return FALSE;
	if(gResult!=ERR_NONE) 
	{
		ERROR("DNR_Sync(): error returned");
		return FALSE;
	}
	*addr=gRemoteIPAddress;
	return TRUE;
}
static void GetMyIPAddr_Completion(short result, ulong addr, ulong mask)
{
	gResult=result;
	gMyIPAddr=addr;
	gMyIPMask=mask;

	gReady=TRUE;
}

Boolean GetMyIPAddr_Sync(ulong *addr, ulong *mask)
{
	gReady=FALSE;
	if(!GetMyIPAddr(GetMyIPAddr_Completion)) return FALSE;
	if(!WaitReady(STD_TIMEOUT)) return FALSE;
	if(gResult!=ERR_NONE) 
	{
		ERROR("GetMyIPAddr_Sync(): error returned");
		return FALSE;
	}
	*addr=gMyIPAddr;
	*mask=gMyIPMask;
	return TRUE;
}
static void GetDNRIPAddr_Completion(short result, ulong addr)
{
	gResult=result;
	gDNRIPAddr=addr;

	gReady=TRUE;
}

Boolean GetDNRIPAddr_Sync(ulong *addr)
{
	gReady=FALSE;
	if(!GetDNRIPAddr(GetDNRIPAddr_Completion)) return FALSE;
	if(!WaitReady(STD_TIMEOUT)) return FALSE;
	if(gResult!=ERR_NONE) 
	{
		ERROR("GetDNRIPAddr_Sync(): error returned");
		return FALSE;
	}
	*addr=gDNRIPAddr;
	return TRUE;
}
static void Test_Completion(void)
{
	gReady=TRUE;

}

Boolean Test_Sync(void)
{
	gReady=FALSE;
	if(!Test(Test_Completion)) return FALSE;
	if(!WaitReady(STD_TIMEOUT)) return FALSE;
	return TRUE;
}