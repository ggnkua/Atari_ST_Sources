#include <stdio.h>
#include <stdlib.h>
#include <tos.h>
#include <string.h>

#include "stip_lib.h"
#include "../cookie.h"

#define _SYSBASE    0x4F2L
#define COOKIE_PTR  0x5A0L

#define ERROR(s)	puts(s)

typedef struct
{
     char	magic[4];
     ulong	value;
} COOKIE_ENTRY;

static STipCookie	*gCookie=NULL;

static ulong* SearchCookie(char *magic)
{
     ulong 			*value;
     void 			*stackPointer;
     COOKIE_ENTRY   *ptr;

     stackPointer=(void*)Super(0L);
     if((ptr=*(COOKIE_ENTRY**)COOKIE_PTR)==NULL)
     {
     	value=NULL;
     }
     else
     {
          while(strncmp((char*)ptr,magic,4) && *(long*)ptr!=0L) ptr++;
          value=!strncmp((char*)ptr,magic,4) ? (ulong*)&ptr->value : NULL;
     }
     Super(stackPointer);
     return value;
}

static STipCookie* GetCookie(void)
{
	STipCookie	**stip;
	
	if((stip=(STipCookie**)SearchCookie("STip"))==NULL) 
	{
		ERROR("GetCookie(): AutoSTip not installed");
		return NULL;
	}
	if(*stip==NULL)
	{
		ERROR("GetCookie(): STip not installed");
		return NULL;
	}
	return *stip;
}

Boolean TCP_Create(TCP_Create_CB *cb){
	if(gCookie==NULL) if((gCookie=GetCookie())==NULL) return FALSE;
	if(gCookie->tcpCreate==NULL) return FALSE;
	return gCookie->tcpCreate(cb);
}

Boolean TCP_ActiveOpen(ConnectionHandle handle, ulong connectionTimeout, IPAddress remoteIPAddress, unsigned short remotePort, unsigned short localPort, TCP_ActiveOpen_CB *cb){
	if(gCookie==NULL) if((gCookie=GetCookie())==NULL) return FALSE;
	if(gCookie->tcpActiveOpen==NULL) return FALSE;
	return gCookie->tcpActiveOpen(handle,connectionTimeout,remoteIPAddress,remotePort,localPort,cb);
}

Boolean TCP_PassiveOpen(ConnectionHandle handle, ulong connectionTimeout, ulong commandTimeout, IPAddress remoteIPAddress, unsigned short remotePort, unsigned short localPort, TCP_PassiveOpen_CB *cb){
	if(gCookie==NULL) if((gCookie=GetCookie())==NULL) return FALSE;
	if(gCookie->tcpPassiveOpen==NULL) return FALSE;
	return gCookie->tcpPassiveOpen(handle,connectionTimeout,commandTimeout,remoteIPAddress,remotePort,localPort,cb);
}

Boolean TCP_GetBytesAvail(ConnectionHandle handle, TCP_GetBytesAvail_CB *cb){
	if(gCookie==NULL) if((gCookie=GetCookie())==NULL) return FALSE;
	if(gCookie->tcpGetBytesAvail==NULL) return FALSE;
	return gCookie->tcpGetBytesAvail(handle,cb);
}

Boolean TCP_Receive(ConnectionHandle handle, ulong commandTimeout, ulong bytesToReceive, TCP_Receive_CB *cb){
	if(gCookie==NULL) if((gCookie=GetCookie())==NULL) return FALSE;
	if(gCookie->tcpReceive==NULL) return FALSE;
	return gCookie->tcpReceive(handle,commandTimeout,bytesToReceive,cb);
}

Boolean TCP_Send(ConnectionHandle handle, void *buffer, ulong bytesToSend, ushort urgent, ushort push, TCP_Send_CB *cb){
	if(gCookie==NULL) if((gCookie=GetCookie())==NULL) return FALSE;
	if(gCookie->tcpSend==NULL) return FALSE;
	return gCookie->tcpSend(handle,buffer,bytesToSend,urgent,push,cb);
}

Boolean TCP_GetStatus(ConnectionHandle handle, TCP_GetStatus_CB *cb){
	if(gCookie==NULL) if((gCookie=GetCookie())==NULL) return FALSE;
	if(gCookie->tcpGetStatus==NULL) return FALSE;
	return gCookie->tcpGetStatus(handle,cb);
}

Boolean TCP_Close(ConnectionHandle handle, TCP_Close_CB *cb){
	if(gCookie==NULL) if((gCookie=GetCookie())==NULL) return FALSE;
	if(gCookie->tcpClose==NULL) return FALSE;
	return gCookie->tcpClose(handle,cb);
}

Boolean TCP_Abort(ConnectionHandle handle, TCP_Abort_CB *cb){
	if(gCookie==NULL) if((gCookie=GetCookie())==NULL) return FALSE;
	if(gCookie->tcpAbort==NULL) return FALSE;
	return gCookie->tcpAbort(handle,cb);
}

Boolean TCP_Release(ConnectionHandle handle, TCP_Release_CB *cb){
	if(gCookie==NULL) if((gCookie=GetCookie())==NULL) return FALSE;
	if(gCookie->tcpRelease==NULL) return FALSE;
	return gCookie->tcpRelease(handle,cb);
}

Boolean UDP_Create(unsigned short localPort, UDP_Create_CB *cb){
	if(gCookie==NULL) if((gCookie=GetCookie())==NULL) return FALSE;
	if(gCookie->udpCreate==NULL) return FALSE;
	return gCookie->udpCreate(localPort,cb);
}

Boolean UDP_Read(ConnectionHandle handle, ulong commandTimeout, UDP_Read_CB *cb){
	if(gCookie==NULL) if((gCookie=GetCookie())==NULL) return FALSE;
	if(gCookie->udpRead==NULL) return FALSE;
	return gCookie->udpRead(handle,commandTimeout,cb);
}

Boolean UDP_Write(ConnectionHandle handle, IPAddress remoteIPAddress, unsigned short remotePort, void *buffer, ulong bytesToWrite, UDP_Write_CB *cb){
	if(gCookie==NULL) if((gCookie=GetCookie())==NULL) return FALSE;
	if(gCookie->udpWrite==NULL) return FALSE;
	return gCookie->udpWrite(handle,remoteIPAddress,remotePort,buffer,bytesToWrite,cb);
}

Boolean UDP_Release(ConnectionHandle handle, UDP_Release_CB *cb){
	if(gCookie==NULL) if((gCookie=GetCookie())==NULL) return FALSE;
	if(gCookie->udpRelease==NULL) return FALSE;
	return gCookie->udpRelease(handle,cb);
}

Boolean UDP_GetMTUSize(IPAddress remoteIPAddress, UDP_GetMTUSize_CB *cb){
	if(gCookie==NULL) if((gCookie=GetCookie())==NULL) return FALSE;
	if(gCookie->udpGetMTUSize==NULL) return FALSE;
	return gCookie->udpGetMTUSize(remoteIPAddress,cb);
}

Boolean DNR(IPAddress remoteIPAddress, DNR_CB *cb){
	if(gCookie==NULL) if((gCookie=GetCookie())==NULL) return FALSE;
	if(gCookie->dnr==NULL) return FALSE;
	return gCookie->dnr(remoteIPAddress,cb);
}

Boolean GetMyIPAddr(GetMyIPAddr_CB *cb){
	if(gCookie==NULL) if((gCookie=GetCookie())==NULL) return FALSE;
	if(gCookie->getMyIPAddr==NULL) return FALSE;
	return gCookie->getMyIPAddr(cb);
}

Boolean GetDNRIPAddr(GetDNRIPAddr_CB *cb){
	if(gCookie==NULL) if((gCookie=GetCookie())==NULL) return FALSE;
	if(gCookie->getDNRIPAddr==NULL) return FALSE;
	return gCookie->getDNRIPAddr(cb);
}

Boolean Test(Test_CB *cb)
{
	if(gCookie==NULL) if((gCookie=GetCookie())==NULL) return FALSE;
	if(gCookie->test==NULL) return FALSE;
	return gCookie->test(cb);
}

void Wait(void)
{
	if(gCookie==NULL) if((gCookie=GetCookie())==NULL) return;
	if(gCookie->wait==NULL) return;
	gCookie->wait();
}
