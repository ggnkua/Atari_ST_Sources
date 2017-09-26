/* -------- */
/* Includes */
/* -------- */

#include <stdio.h>
#include <stdlib.h>
#include <tos.h>
#include <string.h>
#include <time.h>
#include <aes.h>
#include <vdi.h>

/*
#include "stip_rsc.h"
#include "stip_rsc.rsh"
*/
#include "stip.h"
#include "stip_lib/stip_lib.h"
#include "cookie.h"
#include "mgmc.h"

#define UNUSED(x)				x=x;
#define _SYSBASE    			0x4F2L
#define COOKIE_PTR  			0x5A0L
#define STIP_VERSION			1
#define SEND_COMMAND_TIMEOUT	8*CLK_TCK

#define ERROR(s)				/* ShowError(s) */

typedef struct
{
     char	magic[4];
     ulong	value;
} COOKIE_ENTRY;

typedef struct _InputBuffer
{
	struct _InputBuffer	*next;
	
	ConnectionHandle	handle;
	uchar				buffer[MAX_ADDITIONAL_RECEIVE];
	ulong				pos,size;
} InputBuffer;

static int gAppID,gVDIHandle;
/*static OBJECT *gMenu;*/

static MgMcCookie	*gMagicMacCookie;
static STipCookie	gFunctionTable;
static Boolean		gDone;
static InputBuffer	*gInputBufferList=NULL;

extern short LockSender(void);
extern void UnlockSender(void);
extern long GetSTInterface(void *callMacContext);
extern void WaitNextEvent(void *callMacContext);

static void ShowError(char *errorText)
{
	char	s[256];

	sprintf(s,"[3][STip:%s][ OK ]",errorText);
	form_alert(1,s);
}

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

static void Wait(void)
{
	void	*stackPointer=NULL;

	if(Super((void*)1L)==0L) stackPointer=(void*)Super(0L);
	gMagicMacCookie->modeMac();

	WaitNextEvent(gMagicMacCookie->callMacContext);

	gMagicMacCookie->modeAtari();
	if(stackPointer!=NULL) Super(stackPointer);
}

static Boolean GetMacMessageType(ushort *type)
{
	STInterface	*interface;
	Boolean		result;
	void		*stackPointer=NULL;

	if(Super((void*)1L)==0L) stackPointer=(void*)Super(0L);
	gMagicMacCookie->modeMac();
	
	if((interface=(STInterface*)GetSTInterface(gMagicMacCookie->callMacContext))!=NULL)
	{
		*type=interface->macMsg.type;
		result=TRUE;
	}
	else
	{
		result=FALSE;
	}
	
	gMagicMacCookie->modeAtari();
	if(stackPointer!=NULL) Super(stackPointer);
	if(!result) ERROR("GetMacMessageType(): can't get ST-interface");
	return result;
}

static Boolean GetSTMessageType(ushort *type, ulong *size)
{
	STInterface	*interface;
	Boolean		result;
	void		*stackPointer=NULL;

	if(Super((void*)1L)==0L) stackPointer=(void*)Super(0L);
	gMagicMacCookie->modeMac();
	
	if((interface=(STInterface*)GetSTInterface(gMagicMacCookie->callMacContext))!=NULL)
	{
		result=TRUE;
		*type=interface->stMsg.type;
		*size=interface->stMsg.size;
	}
	else
	{		
		result=FALSE;
	}
	
	gMagicMacCookie->modeAtari();
	if(stackPointer!=NULL) Super(stackPointer);
	if(!result) ERROR("GetSTMessageType(): can't get ST-interface");
	return result;
}

static Boolean ReceiveSTMessage(void *base, ulong size)
{
	STInterface	*interface;
	Boolean		result;
	void		*stackPointer=NULL;

	if(Super((void*)1L)==0L) stackPointer=(void*)Super(0L);
	gMagicMacCookie->modeMac();

	if((interface=(STInterface*)GetSTInterface(gMagicMacCookie->callMacContext))!=NULL)
	{
		result=TRUE;
		if(base!=NULL && size>0) memcpy(base,interface->stMsg.msg,size);
		interface->stMsg.type=MSG_NONE;
	}
	else
	{
		result=FALSE;
	}

	gMagicMacCookie->modeAtari();
	if(stackPointer!=NULL) Super(stackPointer);
	if(!result) ERROR("ReceiveSTMessage(): can't get ST-interface");
	return result;
}

static Boolean SendMacMessage(ushort type, void *base, ulong size, Boolean *error)
{
	STInterface	*interface;
	Boolean		interfaceFound,result;
	void		*stackPointer=NULL;
	
	*error=FALSE;

	if(Super((void*)1L)==0L) stackPointer=(void*)Super(0L);
	gMagicMacCookie->modeMac();

	if((interface=(STInterface*)GetSTInterface(gMagicMacCookie->callMacContext))!=NULL)
	{
		interfaceFound=TRUE;
		if(interface->macMsg.type!=MSG_NONE)
		{
			result=FALSE;
		}
		else
		{
			result=TRUE;
			interface->macMsg.size=size;
			if(size>0 && base!=NULL) memcpy(interface->macMsg.msg,base,size);
			interface->macMsg.type=type;
		}
	}
	else
	{
		interfaceFound=FALSE;
		*error=TRUE;
		result=FALSE;
	}

	gMagicMacCookie->modeAtari();
	if(stackPointer!=NULL) Super(stackPointer);
	if(!interfaceFound) ERROR("SendMacMessage(): can't get ST-interface");
	return result;
}

static Boolean SendCombinedMacMessage(ushort type, void *base1, ulong size1, void *base2, ulong size2, Boolean *error)
{
	STInterface	*interface;
	Boolean		interfaceFound,result;
	void		*stackPointer=NULL;

	*error=FALSE;
	
	if(Super((void*)1L)==0L) stackPointer=(void*)Super(0L);
	gMagicMacCookie->modeMac();

	if((interface=(STInterface*)GetSTInterface(gMagicMacCookie->callMacContext))!=NULL)
	{
		interfaceFound=TRUE;
		if(interface->macMsg.type!=MSG_NONE)
		{
			result=FALSE;
		}
		else
		{
			result=TRUE;
			interface->macMsg.size=size1+size2;
			memcpy(interface->macMsg.msg,base1,size1);
			memcpy(interface->macMsg.msg+size1,base2,size2);
			interface->macMsg.type=type;
		}
	}
	else
	{
		interfaceFound=FALSE;
		*error=TRUE;
		result=FALSE;
	}

	gMagicMacCookie->modeAtari();
	if(stackPointer!=NULL) Super(stackPointer);
	if(!interfaceFound) ERROR("SendCombinedMacMessage(): can't get ST-interface");
	return result;
}

static Boolean SendMessage(ushort type, void *base, ulong size)
{
	clock_t	timeout;
	Boolean	error;
	
	if(size>MSG_SIZE)
	{
		ERROR("SendMessage(): message too large");
		return FALSE;
	}

	timeout=clock()+SEND_COMMAND_TIMEOUT;
	while(TRUE)
	{
		if(clock()>=timeout) 
		{
			ERROR("SendMessage(): sender lock timeout");
			return FALSE;
		}
		if(LockSender()) break;
		Wait();
	}

	while(TRUE)
	{
		if(SendMacMessage(type,base,size,&error))
		{
			UnlockSender();
			return TRUE;
		}
		if(error)
		{
			ERROR("SendMessage(): can't get message type from ST-interface");
			UnlockSender();
			return FALSE;
		}
		if(clock()>=timeout) 
		{
			ERROR("SendMessage(): send message timeout");
			UnlockSender();
			return FALSE;
		}
		Wait();
	}
}

static Boolean SendCombinedMessage(ushort type, void *base1, ulong size1, void *base2, ulong size2)
{
	clock_t	timeout;
	Boolean	error;
	
	if(size1+size2>MSG_SIZE)
	{
		ERROR("SendCombinedMessage(): message too large"); 
		return FALSE;
	}

	timeout=clock()+SEND_COMMAND_TIMEOUT;
	while(TRUE)
	{
		if(clock()>=timeout) 
		{
			ERROR("SendCombinedMessage(): sender lock timeout");
			return FALSE;
		}
		if(LockSender()) break;
		Wait();
	}

	while(TRUE)
	{
		if(SendCombinedMacMessage(type,base1,size1,base2,size2,&error))
		{
			UnlockSender();
			return TRUE;
		}
		if(error)
		{
			ERROR("SendCombinedMessage(): can't get message type from ST-interface");
			UnlockSender();
			return FALSE;
		}
		if(clock()>=timeout) 
		{
			ERROR("SendCombinedMessage(): send message timeout");
			UnlockSender();
			return FALSE;
		}
		Wait();
	}
}

static Boolean ReceiveMessage(ushort *type, void **base, ulong *size)
{
	if(!GetSTMessageType(type,size)) 
	{
		gDone=TRUE;
		/*ShowError("MacSTip not installed");*/
		return FALSE;
	}
	if(*type==MSG_NONE) return FALSE;
	if(*size>0)
	{
		if((*base=malloc(*size))==NULL)
		{
			gDone=TRUE;
			ShowError("out of memory");
			return FALSE;
		}
	}
	else
	{
		*base=NULL;
	}
	return ReceiveSTMessage(*base,*size);
}

static InputBuffer* GetInputBuffer(ConnectionHandle handle)
{
	InputBuffer	*ib;
	
	ib=gInputBufferList;
	while(ib!=NULL)
	{
		if(ib->handle==handle) return ib;
		ib=ib->next;
	}
	return NULL;
}

static Boolean NewInputBuffer(ConnectionHandle handle, uchar *buffer, ulong size)
{
	InputBuffer	*ib;
	
	if(size>MAX_ADDITIONAL_RECEIVE) 
	{
		ShowError("too much additional bytes received by MacSTip");
		return FALSE;
	}
	
	if((ib=calloc(1,sizeof(InputBuffer)))==NULL) 
	{
		ShowError("out of memory");
		return FALSE;
	}
	
	ib->handle=handle;
	memcpy(ib->buffer,buffer,size);
	ib->pos=0;
	ib->size=size;
	ib->next=gInputBufferList;
	gInputBufferList=ib;
	
	return TRUE;
}

static void RemoveInputBuffer(ConnectionHandle handle)
{
	InputBuffer	*current,*last=NULL;
	
	current=gInputBufferList;
	while(current!=NULL)
	{
		if(current->handle==handle)
		{
			if(last==NULL)
			{
				gInputBufferList=NULL;
			}
			else
			{
				last->next=current->next;
			}
			free(current);
			return;
		}
		current=current->next;
	}
}

static Boolean TCP_Create(TCP_Create_CB *cb)
{
	TCPCreateRec	rec;
	
	rec.userData=(ulong)cb;

	return SendMessage(MSG_TCP_CREATE,&rec,sizeof(TCPCreateRec));
}

static void TCP_Create_Response(TCPCreateRespRec *rec)
{
	TCP_Create_CB	*cb;
	
	cb=(TCP_Create_CB*)rec->userData;
	cb(rec->result,rec->handle);
}

static Boolean TCP_ActiveOpen(ConnectionHandle handle, ulong connectionTimeout, IPAddress remoteIPAddress, ushort remotePort, ushort localPort, TCP_ActiveOpen_CB *cb)
{
	TCPActiveOpenRec	rec;
	rec.handle=handle;	rec.connectionTimeout=connectionTimeout;	strcpy(rec.remoteIPAddress,remoteIPAddress);	rec.remotePort=remotePort;	rec.localPort=localPort;	

	rec.userData=(ulong)cb;		return SendMessage(MSG_TCP_ACTIVE_OPEN,&rec,sizeof(TCPActiveOpenRec));}

static void TCP_ActiveOpen_Response(TCPActiveOpenRespRec *rec)
{
	TCP_ActiveOpen_CB	*cb;
	
	cb=(TCP_ActiveOpen_CB*)rec->userData;
	cb(rec->result,rec->handle,rec->localPort);
}

static Boolean TCP_PassiveOpen(ConnectionHandle handle, ulong connectionTimeout, ulong commandTimeout, IPAddress remoteIPAddress, ushort remotePort, ushort localPort, TCP_PassiveOpen_CB *cb)
{
	TCPPassiveOpenRec	rec;
	rec.handle=handle;	rec.connectionTimeout=connectionTimeout;	rec.commandTimeout=commandTimeout;	strcpy(rec.remoteIPAddress,remoteIPAddress);	rec.remotePort=remotePort;	rec.localPort=localPort;	
	rec.userData=(ulong)cb;
	return SendMessage(MSG_TCP_PASSIVE_OPEN,&rec,sizeof(TCPPassiveOpenRec));
}

static void TCP_PassiveOpen_Response(TCPPassiveOpenRespRec *rec)
{
	TCP_PassiveOpen_CB	*cb;
	
	cb=(TCP_PassiveOpen_CB*)rec->userData;
	cb(rec->result,rec->handle,rec->remoteIPAddress,rec->remotePort,rec->localPort);
}

static Boolean TCP_GetBytesAvail(ConnectionHandle handle, TCP_GetBytesAvail_CB *cb)
{
	TCPGetBytesAvailRec	rec;
	
	rec.handle=handle;
	
	rec.userData=(ulong)cb;
	return SendMessage(MSG_TCP_GET_BYTES_AVAIL,&rec,sizeof(TCPGetBytesAvailRec));
}

static void TCP_GetBytesAvail_Response(TCPGetBytesAvailRespRec *rec)
{
	TCP_GetBytesAvail_CB	*cb;
	
	cb=(TCP_GetBytesAvail_CB*)rec->userData;
	cb(rec->result,rec->handle,rec->bytesAvailable);
}

static Boolean TCP_Receive(ConnectionHandle handle, ulong commandTimeout, ulong bytesToReceive, TCP_Receive_CB *cb)
{
	TCPReceiveRec	rec;
	InputBuffer		*ib;
	
	if((ib=GetInputBuffer(handle))!=NULL)
	{
		if(ib->size>0)
		{
			if(ib->size>bytesToReceive)
			{
				cb(ERR_NONE,handle,ib->buffer+ib->pos,bytesToReceive,FALSE);
				ib->pos+=bytesToReceive;
				ib->size-=bytesToReceive;
				return TRUE;
			}
			else
			{
				cb(ERR_NONE,handle,ib->buffer+ib->pos,ib->size,FALSE);
				RemoveInputBuffer(handle);
				return TRUE;
			}
		}

		RemoveInputBuffer(handle);
	}
	
	rec.handle=handle;	rec.commandTimeout=commandTimeout;	rec.bytesToReceive=bytesToReceive;		rec.userData=(ulong)cb;
	return SendMessage(MSG_TCP_RECEIVE,&rec,sizeof(TCPReceiveRec));
}

static void TCP_Receive_Response(TCPReceiveRespRec *rec, void *buffer)
{
	TCP_Receive_CB	*cb;
	
	cb=(TCP_Receive_CB*)rec->userData;
	
	if(rec->result==ERR_NONE && rec->bytesReceived>rec->bytesToReceive)
	{
		NewInputBuffer(rec->handle,(uchar*)buffer+rec->bytesToReceive,rec->bytesReceived-rec->bytesToReceive);
		cb(rec->result,rec->handle,buffer,rec->bytesToReceive,FALSE);
	}
	else
	{
		cb(rec->result,rec->handle,buffer,rec->bytesReceived,rec->urgent);
	}
}

static Boolean TCP_Send(ConnectionHandle handle, void *buffer, ulong bytesToSend, ushort urgent, ushort push, TCP_Send_CB *cb)
{
	TCPSendRec	rec;
	if(sizeof(TCPSendRec)+bytesToSend>MSG_SIZE)
	{
		ERROR("TCP_Send(): message too large");
		return FALSE;
	}		rec.handle=handle;	rec.bytesToSend=bytesToSend;
	rec.urgent=urgent;
	rec.push=push;		rec.userData=(ulong)cb;
	return SendCombinedMessage(MSG_TCP_SEND,&rec,sizeof(TCPSendRec),buffer,bytesToSend);
}

static void TCP_Send_Response(TCPSendRespRec *rec)
{
	TCP_Send_CB	*cb;
	
	cb=(TCP_Send_CB*)rec->userData;
	cb(rec->result,rec->handle);
}

static Boolean TCP_Close(ConnectionHandle handle, TCP_Close_CB *cb)
{
	TCPCloseRec	rec;
	rec.handle=handle;		rec.userData=(ulong)cb;
	return SendMessage(MSG_TCP_CLOSE,&rec,sizeof(TCPCloseRec));
}

static void TCP_Close_Response(TCPCloseRespRec *rec)
{
	TCP_Close_CB	*cb;
	
	cb=(TCP_Close_CB*)rec->userData;
	cb(rec->result,rec->handle);
}

static Boolean TCP_GetStatus(ConnectionHandle handle, TCP_GetStatus_CB *cb)
{
	TCPGetStatusRec	rec;
	rec.handle=handle;		rec.userData=(ulong)cb;
	return SendMessage(MSG_TCP_GET_STATUS,&rec,sizeof(TCPGetStatusRec));
}

static void TCP_GetStatus_Response(TCPGetStatusRespRec *rec)
{
	TCP_GetStatus_CB	*cb;
	
	cb=(TCP_GetStatus_CB*)rec->userData;
	cb(rec->result,rec->handle,rec->connectionState,rec->unacknowledgedData,rec->sendUnacknowledged,rec->unreadData);
}

static Boolean TCP_Abort(ConnectionHandle handle, TCP_Abort_CB *cb)
{
	TCPAbortRec	rec;
	rec.handle=handle;		rec.userData=(ulong)cb;
	return SendMessage(MSG_TCP_ABORT,&rec,sizeof(TCPAbortRec));
}

static void TCP_Abort_Response(TCPAbortRespRec *rec)
{
	TCP_Abort_CB	*cb;
	
	cb=(TCP_Abort_CB*)rec->userData;
	cb(rec->result,rec->handle);
}

static Boolean TCP_Release(ConnectionHandle handle, TCP_Release_CB *cb)
{
	TCPReleaseRec	rec;
	rec.handle=handle;		rec.userData=(ulong)cb;
	return SendMessage(MSG_TCP_RELEASE,&rec,sizeof(TCPReleaseRec));
}

static void TCP_Release_Response(TCPReleaseRespRec *rec)
{
	TCP_Release_CB	*cb;
	
	cb=(TCP_Release_CB*)rec->userData;
	cb(rec->result,rec->handle);
}

static Boolean UDP_Create(ushort localPort, UDP_Create_CB *cb)
{
	UDPCreateRec	rec;
	
	rec.localPort=localPort;
	
	rec.userData=(ulong)cb;

	return SendMessage(MSG_UDP_CREATE,&rec,sizeof(UDPCreateRec));
}

static void UDP_Create_Response(UDPCreateRespRec *rec)
{
	UDP_Create_CB	*cb;
	
	cb=(UDP_Create_CB*)rec->userData;
	cb(rec->result,rec->handle,rec->localPort);
}

static Boolean UDP_Read(ulong handle, ulong commandTimeout, UDP_Read_CB *cb)
{
	UDPReadRec	rec;
	
	rec.handle=handle;
	rec.commandTimeout=commandTimeout;
	
	rec.userData=(ulong)cb;

	return SendMessage(MSG_UDP_READ,&rec,sizeof(UDPReadRec));
}

static void UDP_Read_Response(UDPReadRespRec *rec, void *buffer)
{
	UDP_Read_CB	*cb;
	
	cb=(UDP_Read_CB*)rec->userData;
	cb(rec->result,rec->handle,rec->remoteIPAddress,rec->remotePort,buffer,rec->bytesRead);
}

static Boolean UDP_Write(ConnectionHandle handle, IPAddress remoteIPAddress, ushort remotePort, void *buffer, ulong bytesToWrite, UDP_Write_CB *cb)
{
	UDPWriteRec	rec;
	if(sizeof(UDPWriteRec)+bytesToWrite>MSG_SIZE) 
	{
		ERROR("UDP_Write(): message too large");
		return FALSE;
	}		rec.handle=handle;	strcpy(rec.remoteIPAddress,remoteIPAddress);	rec.remotePort=remotePort;	rec.bytesToWrite=bytesToWrite;		rec.userData=(ulong)cb;
	return SendCombinedMessage(MSG_UDP_WRITE,&rec,sizeof(UDPWriteRec),buffer,bytesToWrite);
}

static void UDP_Write_Response(UDPWriteRespRec *rec)
{
	UDP_Write_CB	*cb;
	
	cb=(UDP_Write_CB*)rec->userData;
	cb(rec->result,rec->handle);
}

static Boolean UDP_Release(ConnectionHandle handle, UDP_Release_CB *cb)
{
	UDPReleaseRec	rec;
	rec.handle=handle;		rec.userData=(ulong)cb;
	return SendMessage(MSG_UDP_RELEASE,&rec,sizeof(UDPReleaseRec));
}

static void UDP_Release_Response(UDPReleaseRespRec *rec)
{
	UDP_Release_CB	*cb;
	
	cb=(UDP_Release_CB*)rec->userData;
	cb(rec->result,rec->handle);
}

static Boolean UDP_GetMTUSize(IPAddress remoteIPAddress, UDP_GetMTUSize_CB *cb)
{
	UDPGetMTUSizeRec	rec;
	
	strcpy(rec.remoteIPAddress,remoteIPAddress);
	rec.userData=(ulong)cb;
	return SendMessage(MSG_UDP_GET_MTU_SIZE,&rec,sizeof(UDPGetMTUSizeRec));
}

static void UDP_GetMTUSize_Response(UDPGetMTUSizeRespRec *rec)
{
	UDP_GetMTUSize_CB	*cb;
	
	cb=(UDP_GetMTUSize_CB*)rec->userData;
	cb(rec->result,rec->mtuSize);
}

static Boolean DNR(IPAddress remoteIPAddress, DNR_CB *cb)
{
	DNRRec	rec;
	strcpy(rec.remoteIPAddress,remoteIPAddress);		rec.userData=(ulong)cb;
	return SendMessage(MSG_DNR,&rec,sizeof(DNRRec));
}

static void DNR_Response(DNRRespRec *rec)
{
	DNR_CB	*cb;
	
	cb=(DNR_CB*)rec->userData;
	cb(rec->result,rec->addr);
}

static Boolean GetMyIPAddr(GetMyIPAddr_CB *cb)
{
	GetMyIPAddrRec	rec;
	rec.userData=(ulong)cb;
	return SendMessage(MSG_GET_MY_IP_ADDR,&rec,sizeof(GetMyIPAddrRec));
}

static void GetMyIPAddr_Response(GetMyIPAddrRespRec *rec)
{
	GetMyIPAddr_CB	*cb;
	
	cb=(GetMyIPAddr_CB*)rec->userData;
	cb(rec->result,rec->addr,rec->mask);
}

static Boolean GetDNRIPAddr(GetDNRIPAddr_CB *cb)
{
	GetDNRIPAddrRec	rec;
	rec.userData=(ulong)cb;
	return SendMessage(MSG_GET_DNR_IP_ADDR,&rec,sizeof(GetDNRIPAddrRec));
}

static void GetDNRIPAddr_Response(GetDNRIPAddrRespRec *rec)
{
	GetDNRIPAddr_CB	*cb;
	
	cb=(GetDNRIPAddr_CB*)rec->userData;
	cb(rec->result,rec->addr);
}

static Boolean Test(Test_CB *cb)
{
	TestRec	rec;
	rec.userData=(ulong)cb;
	return SendMessage(MSG_TEST,&rec,sizeof(TestRec));
}

static void Test_Response(TestRespRec *rec)
{
	Test_CB	*cb;
	
	cb=(Test_CB*)rec->userData;
	cb();
}

static void HandleMessage(ushort type, void *base, ulong size)
{
	UNUSED(size)

	switch(type)
	{
		case MSG_TCP_CREATE_RESP:
			TCP_Create_Response((TCPCreateRespRec*)base);			break;				case MSG_TCP_ACTIVE_OPEN_RESP:			TCP_ActiveOpen_Response((TCPActiveOpenRespRec*)base);			break;				case MSG_TCP_PASSIVE_OPEN_RESP:			TCP_PassiveOpen_Response((TCPPassiveOpenRespRec*)base);			break;				case MSG_TCP_GET_BYTES_AVAIL_RESP:			TCP_GetBytesAvail_Response((TCPGetBytesAvailRespRec*)base);			break;				case MSG_TCP_RECEIVE_RESP:			TCP_Receive_Response((TCPReceiveRespRec*)base,(TCPReceiveRespRec*)base+1);			break;				case MSG_TCP_SEND_RESP:			TCP_Send_Response((TCPSendRespRec*)base);			break;				case MSG_TCP_GET_STATUS_RESP:			TCP_GetStatus_Response((TCPGetStatusRespRec*)base);			break;				case MSG_TCP_CLOSE_RESP:			TCP_Close_Response((TCPCloseRespRec*)base);			break;				case MSG_TCP_ABORT_RESP:			TCP_Abort_Response((TCPAbortRespRec*)base);			break;				case MSG_TCP_RELEASE_RESP:			TCP_Release_Response((TCPReleaseRespRec*)base);			break;				case MSG_UDP_CREATE_RESP:			UDP_Create_Response((UDPCreateRespRec*)base);			break;				case MSG_UDP_READ_RESP:			UDP_Read_Response((UDPReadRespRec*)base,(UDPReadRespRec*)base+1);			break;				case MSG_UDP_WRITE_RESP:			UDP_Write_Response((UDPWriteRespRec*)base);			break;				case MSG_UDP_RELEASE_RESP:			UDP_Release_Response((UDPReleaseRespRec*)base);			break;				case MSG_UDP_GET_MTU_SIZE_RESP:			UDP_GetMTUSize_Response((UDPGetMTUSizeRespRec*)base);			break;				case MSG_DNR_RESP:			DNR_Response((DNRRespRec*)base);			break;
		
		case MSG_GET_MY_IP_ADDR_RESP:			GetMyIPAddr_Response((GetMyIPAddrRespRec*)base);			break;
		
		case MSG_GET_DNR_IP_ADDR_RESP:			GetDNRIPAddr_Response((GetDNRIPAddrRespRec*)base);			break;
		
		case MSG_TEST_RESP:
			Test_Response((TestRespRec*)base);			break;
	}
}

static void Receiver(void)
{
	void	*base;
	ushort	type;
	ulong	size;

	if(ReceiveMessage(&type,&base,&size))
	{
		HandleMessage(type,base,size);
		if(size>0 && base!=NULL) free(base);
	}
}
/*
static void AboutDialog(void)
{
	form_alert(1,"[1][STip 1.0|von Dirk Sabiwalsky][ OK ]");
}

static Boolean HandleMenu(int entry)
{
	switch(entry)
	{
		case RSM_ABOUT:
			AboutDialog(); 
			break;

		case RSM_QUIT:
			if(form_alert(1,"[2][STip beenden?][ Ja | Nein ]")!=1) return TRUE;
			return FALSE;
	}

	return TRUE;
}

static char scancode_to_ascii(int event_code)
{
     char ascii_codes[51] = {0,0,'1','2','3','4','5','6','7','8','9','0',
                             0,0,0,0,'Q','W','E','R','T','Z','U','I',
                             'O','P',0,0,0,0,'A','S','D','F','G','H',
                             'J','K','L',0,0,0,0,0,'Y','X','C','V','B',
                             'N','M'};

     char scancode;

     scancode=*((char*)&event_code);
     if(scancode<=50) return(ascii_codes[scancode]);
     return(0);
}

static Boolean HandleKeyboard(int kstate, int key)
{
     char	ascii_key;

     ascii_key=*((char*)&key+1);

     switch(kstate)
     {
          case 0 :
          case 1 :
          case 2 : break;
          case 4 : ascii_key+=64; break;
          case 8 : ascii_key=scancode_to_ascii(key);
     }

	if(kstate==4)	   /* Control-Kombinationen */
	{
		switch(ascii_key)
		{
			/* Beenden */
			case 'Q': return HandleMenu(RSM_QUIT);
		}
	}
	
	return TRUE;
}

static void SetMenuStates(void)
{
	menu_ienable(gMenu,RSM_ABOUT,TRUE);
	menu_ienable(gMenu,RSM_QUIT,TRUE);
}
*/
static void EventLoop(void)
{
	int	result,dummy,msg[8]/*,kstate,key*/;

/*	SetMenuStates();*/

	do
	{
		result=evnt_multi(MU_MESAG | MU_TIMER /*| MU_KEYBD*/,
					   	  256 | 2,
					   	  3,0,0,0,0,0,0,0,0,0,0,0,
						  msg,
						  10,0,	/* Timer lo,hi */
						  &dummy,&dummy,&dummy,
/*						  &kstate,&key,*/ &dummy,&dummy,
						  &dummy);
		
		if(result & MU_MESAG)
		{
		  	switch(msg[0])
		  	{
            	case AP_TERM:
            		gDone=TRUE;
            		break;

/*				case MN_SELECTED:
					gDone=!HandleMenu(msg[4]);
					menu_tnormal(gMenu,msg[3],1);
					SetMenuStates();
					break;*/
		  	}
		}
/*
	 	if(result & MU_KEYBD)
	 	{
			gDone=!HandleKeyboard(kstate,key);
			SetMenuStates();
	 	}
*/
		Receiver();
	}
	while(!gDone);
}

static void IgnoreWaitingMessage(void)
{
	void	*base;
	ushort	type;
	ulong	size;

	if(ReceiveMessage(&type,&base,&size))
	{
		if(size>0 && base!=NULL) free(base);
	}
}

static Boolean Initialize(void)
{
	int			i,dummy,work_in[11],work_out[57];
	MgMcCookie	**mgmc;
	STipCookie	**stip;

	if((gAppID=appl_init())==-1)
	{
		printf("Can't register STip application\npress a key\n");
		getchar();
		return FALSE;
	}

	gVDIHandle=graf_handle(&dummy,&dummy,&dummy,&dummy);
	for(i=0;i<10;work_in[i++]=1) {}
	work_in[10]=2;
	v_opnvwk(work_in,&gVDIHandle,work_out);
	graf_mouse(ARROW,NULL);
/*	objc_init();
	gMenu=TREE[MENU];
	menu_bar(gMenu,1);*/

	if((mgmc=(MgMcCookie**)SearchCookie("MgMc"))==NULL) 
	{
		ShowError("MagicMac cookie not found");
		return FALSE;
	}
	if((gMagicMacCookie=*mgmc)==NULL) 
	{
		ShowError("MagicMac cookie contains NULL pointer");
		return FALSE;
	}

	gFunctionTable.version=STIP_VERSION;
	gFunctionTable.tcpCreate=TCP_Create;
	gFunctionTable.tcpActiveOpen=TCP_ActiveOpen;
	gFunctionTable.tcpPassiveOpen=TCP_PassiveOpen;
	gFunctionTable.tcpGetBytesAvail=TCP_GetBytesAvail;
	gFunctionTable.tcpReceive=TCP_Receive;
	gFunctionTable.tcpSend=TCP_Send;
	gFunctionTable.tcpGetStatus=TCP_GetStatus;
	gFunctionTable.tcpClose=TCP_Close;
	gFunctionTable.tcpAbort=TCP_Abort;
	gFunctionTable.tcpRelease=TCP_Release;
	gFunctionTable.udpCreate=UDP_Create;
	gFunctionTable.udpRead=UDP_Read;
	gFunctionTable.udpWrite=UDP_Write;
	gFunctionTable.udpRelease=UDP_Release;
	gFunctionTable.udpGetMTUSize=UDP_GetMTUSize;
	gFunctionTable.dnr=DNR;
	gFunctionTable.test=Test;
	gFunctionTable.getMyIPAddr=GetMyIPAddr;
	gFunctionTable.getDNRIPAddr=GetDNRIPAddr;
	gFunctionTable.wait=Wait;
	
	if((stip=(STipCookie**)SearchCookie("STip"))==NULL) 
	{
		ShowError("STip cookie not found");
		return FALSE;
	}
	*stip=&gFunctionTable;
	
	gDone=FALSE;

	IgnoreWaitingMessage();

	return TRUE;
}

static void Terminate(void)
{
	STipCookie	**stip;

	if((stip=(STipCookie**)SearchCookie("STip"))!=NULL) 
	{
		*stip=NULL;
	}

/*	menu_bar(gMenu,0);*/
	v_clsvwk(gVDIHandle);
	appl_exit();
}

void main(void)
{
	if(!Initialize()) return;
	EventLoop();
	Terminate();
}
