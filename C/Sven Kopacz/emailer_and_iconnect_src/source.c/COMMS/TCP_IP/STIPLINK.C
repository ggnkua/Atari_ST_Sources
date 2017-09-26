#define iodebug

#include <stdio.h>
#include <stdlib.h>
#include <atarierr.h>
#include <aes.h>
#include <socket.h>
#include <in.h>
#include <types.h>
#include <sockerr.h>
#include <string.h>
#include <sfcntl.h>

#include "network.h"
#include "tcp.h"
#include "udp.h"
#include "slip.h"
#include "ppp.h"
#include "socksys.h"

#include "stip_def.h"
#include "stip_lib.h"
#include "stipsync.h"

/* ms to wait when polling read */
#define POLL_WAIT 100

extern default_values defaults;

typedef struct
{
	ConnectionHandle 	ch;
	int								port;	/* -1 is free entry */
}UDP_MEM;

typedef struct
{
	ConnectionHandle	ch;
	int								flags;
	int								parent_sock;
	
	uint							local_port;

	ulong							remote_ip;
	uint							remote_port;
	
	char							*recv_buf;
	long							buf_start;	/* Offset from recv_buf */
	long							buf_end;		/* Offset from recv_buf */
																/* buf_end points to byte after 
																		last byte! 
																*/
}TCP_MEM;
#define TCPL_NOTUSED 0
#define TCPL_USED    1
#define TCPL_LISTEN  2
#define TCPL_CONN		 4
#define RECV_BUF_SIZE 30000

typedef struct
{
	int								indi;	/* status indicator */
	ConnectionHandle	ch;
	ushort						state;
	ulong							una_data;
	ulong							una_send;
	ulong							unread;
}TCP_GSW;

typedef struct
{
	int								indi;	/* status indicator */
	ConnectionHandle	ch;
	ulong							bytes;
}TCP_GBA;

typedef struct
{
	int								indi;	/* status indicator */
	ConnectionHandle	ch;
	void							*buffer;
	ulong							bytes;
	ushort						urgent;
}TCP_GRC;

typedef struct
{
	int								indi;	/* status indicator */
	ConnectionHandle	ch;
	void							*buffer;
	ulong							bytes;
	ulong							remote_ip;
	int								remote_port;
}UDP_GRC;

#define TW_FREE			0
#define TW_WAITING 	1
#define TW_DONE_OK	2
#define TW_DONE_ERR 3

#define TW_TIMER 100

UDP_MEM *udp_handles=NULL;
TCP_MEM *tcp_handles=NULL;
TCP_GSW	*tcp_state_wait=NULL;
TCP_GBA	*tcp_avail_wait=NULL;
TCP_GRC	*tcp_recv_wait=NULL;
UDP_GRC	*udp_recv_wait=NULL;

#define TCP_HNDLS 256

int init_ok=0;

int stiplink_init(void)
{
	int a;

	if(init_ok==1) goto _init_2;
	
	udp_handles=tmalloc(sizeof(UDP_MEM)*defaults.udp_count);
	if(udp_handles==NULL) return(0);	
	tcp_handles=tmalloc(sizeof(TCP_MEM)*TCP_HNDLS);
	if(tcp_handles==NULL) {free(udp_handles); return(0);}
	tcp_state_wait=tmalloc(sizeof(TCP_GSW)*TCP_HNDLS);
	if(tcp_state_wait==NULL) {free(tcp_handles); free(udp_handles); return(0);}
	tcp_avail_wait=tmalloc(sizeof(TCP_GBA)*TCP_HNDLS);
	if(tcp_avail_wait==NULL) {free(tcp_state_wait); free(tcp_handles); free(udp_handles); return(0);}
	tcp_recv_wait=tmalloc(sizeof(TCP_GRC)*TCP_HNDLS);
	if(tcp_recv_wait==NULL) {free(tcp_avail_wait); free(tcp_state_wait); free(tcp_handles); free(udp_handles); return(0);}
	udp_recv_wait=tmalloc(sizeof(UDP_GRC)*defaults.udp_count);
	if(udp_recv_wait==NULL) {free(tcp_recv_wait); free(tcp_avail_wait); free(tcp_state_wait); free(tcp_handles); free(udp_handles); return(0);}

_init_2:
	init_ok=1;
			
	for(a=0; a < defaults.udp_count; ++a)
	{
		udp_handles[a].port=-1;
		udp_recv_wait[a].indi=TW_FREE;
	}

	for(a=0; a < TCP_HNDLS; ++a)
	{
		tcp_handles[a].flags=TCPL_NOTUSED;
		tcp_state_wait[a].indi=TW_FREE;
		tcp_avail_wait[a].indi=TW_FREE;
		tcp_recv_wait[a].indi=TW_FREE;
	}
	return(1);
}


char *loc_ntoa(ulong in, char *buf)
{
	ulong	a,b,c,d;
	char	num[20];
	
	a=in >> 24;
	b=(in >> 16) & 0xff;
	c=(in >> 8) & 0xff;
	d=in & 0xff;
	
	buf[0]=0;
	strcpy(buf, ultoa(a, num, 10));
	strcat(buf, ".");
	strcat(buf, ultoa(b, num, 10));
	strcat(buf, ".");
	strcat(buf, ultoa(c, num, 10));
	strcat(buf, ".");
	strcat(buf, ultoa(d, num, 10));
	
	return(buf);
}
/* -------------*/
/* TCP adaption */
/* -------------*/

int enter_tcp_handle(ConnectionHandle ch)
{
	int a=0;
	
	while(a < TCP_HNDLS)
	{
		if(tcp_handles[a].flags==TCPL_NOTUSED)
		{
			tcp_handles[a].flags=TCPL_USED;
			tcp_handles[a].ch=ch;
			tcp_handles[a].recv_buf=Malloc(RECV_BUF_SIZE);
			tcp_handles[a].buf_start=tcp_handles[a].buf_end=0;
			return(a);
		}
		++a;
	}
	return(ENHNDL);
}

int get_tcp_handle(ConnectionHandle ch)
{
	int a=0;
	
	while(a < TCP_HNDLS)
	{
		if((tcp_handles[a].flags & TCPL_USED) && (tcp_handles[a].ch==ch)) return(a);
		++a;
	}
	return(ERROR);
}

void set_tcp_listen(int local_handle, int parent)
{
	tcp_handles[local_handle].flags |= TCPL_LISTEN;
	tcp_handles[local_handle].parent_sock=parent;
}

void cb_get_status(short result, ConnectionHandle ch, ushort state, ulong una_data, ulong una_send, ulong unread)
{
	int a=0, handle;
	
	#ifdef iodebug
	Dftext("[Stat cb:");
	#endif	
	while(a < TCP_HNDLS)
	{
		if((tcp_state_wait[a].indi==TW_WAITING) && (tcp_state_wait[a].ch==ch))
			goto _cbgs_cont;
		++a;
	}
	#ifdef iodebug
	Dftext("handle?]\r\n");
	#endif
	return;

_cbgs_cont:
	if(result!=ERR_NONE) 
	{
		if(result==1)
		{
			#ifdef iodebug
				Dftext("[Trken-Override]");
			#endif
			goto _tov;
		}
		
		#ifdef iodebug
		Dftext("cb-Error: "); Dfnumber(result); Dftext("]\r\n");
		#endif	
		tcp_state_wait[a].indi=TW_DONE_ERR; 
		return;
	}
_tov:
	#ifdef iodebug
	Dftext("cb-ok]\r\n");
	#endif	
	tcp_state_wait[a].state=state;
	tcp_state_wait[a].una_data=una_data;
	tcp_state_wait[a].una_send=una_send;
	if(unread==0)
	{
		handle=get_tcp_handle(ch);
		if(tcp_handles[handle].buf_end-tcp_handles[handle].buf_start > 0)
			tcp_state_wait[a].unread=tcp_handles[handle].buf_end-tcp_handles[handle].buf_start;
		else
			tcp_state_wait[a].unread=0;
	}
	else	tcp_state_wait[a].unread=unread;
	tcp_state_wait[a].indi=TW_DONE_OK;
}

Boolean TCP_GetStatus_loc_Sync(ConnectionHandle handle, ushort *state, ulong *una_data, ulong *una_send, ulong *unread)
{
	int a=0;

	#ifdef iodebug
	Dftext("[Get loc stat...");
	#endif	
	while(a < TCP_HNDLS)
	{
		if(tcp_state_wait[a].indi==TW_FREE)
		{
			tcp_state_wait[a].indi=TW_WAITING;
			tcp_state_wait[a].ch=handle;
			goto _tgs_cont;
		}
		++a;
	}
	#ifdef iodebug
	Dftext("no free state_wait]\r\n");
	#endif
	return(FALSE);

_tgs_cont:
	if(TCP_GetStatus(handle, cb_get_status)==FALSE) 
	{
		tcp_state_wait[a].indi=TW_FREE;
		#ifdef iodebug
		Dftext("FALSE]\r\n");
		#endif
		return(FALSE);
	}

	#ifdef iodebug
	Dftext("waiting...");
	#endif	
	while(tcp_state_wait[a].indi==TW_WAITING)	
	{
		Wait();
		if(tcp_state_wait[a].indi==TW_WAITING) evnt_timer(TW_TIMER,0); 
	}

	if(tcp_state_wait[a].indi==TW_DONE_ERR)
	{
		#ifdef iodebug
		Dftext("Error]\r\n");
		#endif	
		tcp_state_wait[a].indi=TW_FREE;
		return(FALSE);
	}
	#ifdef iodebug
	Dftext("Ok]\r\n");
	#endif	
	*state=tcp_state_wait[a].state;
	*una_data=tcp_state_wait[a].una_data;
	*una_send=tcp_state_wait[a].una_send;
	*unread=tcp_state_wait[a].unread;
	tcp_state_wait[a].indi=TW_FREE;
	return(TRUE);
}

int get_first_child(int parent)
{
	int a=0;
	ushort	state;
	ulong	una_data, una_send, un_read;
	
	while(a < TCP_HNDLS)
	{
		if((tcp_handles[a].flags & TCPL_USED) && (tcp_handles[a].flags & TCPL_CONN) && (tcp_handles[a].parent_sock==parent))
		{
			if(TCP_GetStatus_loc_Sync(tcp_handles[a].ch, &state, &una_data, &una_send, &un_read)==FALSE)
				return(ERROR);
			if((state==TCP_STATE_ESTABLISHED)||(state==TCP_STATE_CLOSE_WAIT))
				return(a);
		}
		++a;
	}
	return(ERROR);
}

void cb_tcp_activeopen(short result, ConnectionHandle handle, ushort localPort)
{/* Supress compiler warning */
	if(result==handle==localPort) return;
}

void cb_tcp_passiveopen(short result, ConnectionHandle handle, ulong remoteIPAddress, ushort remotePort, ushort localPort)
{/* Passive open successfull */
	int	local_handle;
	
	if(result != ERR_NONE) return;
	local_handle=get_tcp_handle(handle);
	if(local_handle==ERROR) return;
	if(!(tcp_handles[local_handle].flags & TCPL_LISTEN)) return;
	tcp_handles[local_handle].remote_ip=remoteIPAddress;
	tcp_handles[local_handle].remote_port=remotePort;
	tcp_handles[local_handle].local_port=localPort;
	tcp_handles[local_handle].flags &= (~TCPL_LISTEN);
	tcp_handles[local_handle].flags |= TCPL_CONN;
}

Boolean sem_TCP_Create_Sync(ConnectionHandle *handle)
{
	Boolean res;
	
	while(!set_flag(STIP_SYNC_TC)) evnt_timer(20,0);
	res=TCP_Create_Sync(handle);
	clear_flag(STIP_SYNC_TC);
	return(res);
}

int x_tcp_open(int src_port, int dst_port, ulong dst_ip, int act_pas, int *tcp_sig, int user_timeout, byte precedence, int security)
{
	int	local_handle;
	char	buf[20];
	ConnectionHandle ch;
	
	if(defaults.using_mac_os)
	{
		#ifdef iodebug
		Dftext("[TCP open...");
		#endif
		if(sem_TCP_Create_Sync(&ch)==FALSE) 
		{
			#ifdef iodebug
			Dftext("FALSE]\r\n");
			#endif
			return(ERROR);
		}
		if((local_handle=enter_tcp_handle(ch))<0) 
		{
			#ifdef iodebug
			Dftext("no local]\r\n");
			#endif
			return(local_handle);
		}
		if(act_pas==0)
		{/* Active open */
			#ifdef iodebug
			Dftext("active, local: ");Dfnumber(local_handle);Dftext(" Mac:");Dfnumber(ch);Dftext("...");
			#endif
			if(TCP_ActiveOpen(ch, defaults.connection_timeout, loc_ntoa(dst_ip, buf), dst_port, src_port, cb_tcp_activeopen)==TRUE)
			{
				tcp_handles[local_handle].remote_ip=dst_ip;
				tcp_handles[local_handle].remote_port=dst_port;
				tcp_handles[local_handle].local_port=src_port;
				#ifdef iodebug
				Dftext("OK]\r\n");
				#endif
				return(local_handle);
			}
			#ifdef iodebug
			Dftext("Error]\r\n");
			#endif
			return(ERROR);
		}
		else
		{/* passive open (command timeout=0 means indef.) */
			if(TCP_PassiveOpen(ch, defaults.connection_timeout, 0, loc_ntoa(dst_ip, buf), dst_port, src_port, cb_tcp_passiveopen)==TRUE)
			{
				set_tcp_listen(local_handle, act_pas);
				return(local_handle);
			}
			return(ERROR);
		}
	}
	
	return(tcp_open(src_port, dst_port, dst_ip, act_pas, tcp_sig, user_timeout, precedence, security));
}

int x_tcp_status(int handle, tcb *dtcb)
{
	ushort	state;
	ulong	una_data, una_send, unread;
	
	if(defaults.using_mac_os)
	{
		#ifdef iodebug
		Dftext("[Status, local:");Dfnumber(handle);Dftext(" Mac: "); Dfnumber(tcp_handles[handle].ch);Dftext("...");
		#endif
		if(TCP_GetStatus_loc_Sync(tcp_handles[handle].ch, &state, &una_data, &una_send, &unread)==FALSE)
		{
			#ifdef iodebug
			Dftext("Error]\r\n");
			#endif
			return(ERROR);
		}
		#ifdef iodebug
		Dftext("state=");Dfnumber(state);Dftext(",unread=");Dfnumber(unread);Dftext("]\r\n");
		#endif
		switch(state)
		{
			case TCP_STATE_CLOSED: state=TCPS_CLOSED; break;
			case TCP_STATE_LISTEN: state=TCPS_LISTEN; break;
			case TCP_STATE_SYN_RECEIVED: state=TCPS_SYNRCVD; break;
			case TCP_STATE_SYN_SENT: state=TCPS_SYNSENT; break;
			case TCP_STATE_ESTABLISHED: state=TCPS_ESTABLISHED; break;
			case TCP_STATE_FIN_WAIT1: state=TCPS_FINWAIT1; break;
			case TCP_STATE_FIN_WAIT2: state=TCPS_FINWAIT2; break;
			case TCP_STATE_CLOSE_WAIT: state=TCPS_CLOSEWAIT; break;
			case TCP_STATE_CLOSING: state=TCPS_CLOSING; break;
			case TCP_STATE_LAST_ACK: state=TCPS_LASTACK; break;
			case TCP_STATE_TIME_WAIT: state=TCPS_TIMEWAIT; break;
		}
		if(dtcb)
		{
			dtcb->state=state;
			dtcb->dst_port=tcp_handles[handle].remote_port;
			dtcb->dst_ip=tcp_handles[handle].remote_ip;
			dtcb->src_port=tcp_handles[handle].local_port;
			dtcb->recv_flags=0;
			dtcb->snd_una=una_send;
/* Mega-Hack, weil <unread> 0 ist, sobald CLOSEWAIT erreicht ist */
/* Daten lassen sich trotzdem mit recv abholen, bis Fehler gemeldet wird */
if((unread==0)&&(state==TCPS_CLOSEWAIT))unread=1000;
			dtcb->recv_buf_len=unread;
		}
		return(state);
	}

	return(tcp_status(handle, dtcb));
}

long x_tcp_get_sendbufsize(int handle)
{
	ushort	state;
	ulong	una_data, una_send, unread;
	
	if(defaults.using_mac_os)
	{
		if(TCP_GetStatus_loc_Sync(tcp_handles[handle].ch, &state, &una_data, &una_send, &unread)==FALSE)
			return(ERROR);
		return((long)una_data+(long)una_send);
	}

	return(tcp_get_sendbufsize(handle));	
}

void cb_tcp_send(short result, ConnectionHandle handle)
{/* Supress warning */
	if(result==handle) return;
}

int x_tcp_send(int handle, uchar *buf, ulong len, int flags, int user_timeout)
{
	if(defaults.using_mac_os)
	{
		#ifdef iodebug
			Dftext("[TCP Send ");Dfnumber(len);Dftext(" Bytes]\r\n");
		#endif
		if(len > MAX_DATA_SIZE) return(ENSMEM);
		if(TCP_Send(tcp_handles[handle].ch, buf, len, flags, 0, cb_tcp_send)==TRUE)
			return((int)len);
		return(ERROR);
	}

	return(tcp_send(handle, buf, (int)len, flags, user_timeout));	
}

void cb_get_avail(short result, ConnectionHandle ch, ulong bytes)
{
	int a=0;
	
	while(a < TCP_HNDLS)
	{
		if((tcp_avail_wait[a].indi==TW_WAITING) && (tcp_avail_wait[a].ch==ch))
			goto _cbga_cont;
		++a;
	}
	return;

_cbga_cont:
	if(result!=ERR_NONE) {tcp_avail_wait[a].indi=TW_DONE_ERR; return;}
	tcp_avail_wait[a].bytes=bytes;
	tcp_avail_wait[a].indi=TW_DONE_OK;
}

Boolean TCP_GetBytesAvail_loc_Sync(ConnectionHandle ch, ulong *bytes)
{
/*	int a=0;*/
	int handle=get_tcp_handle(ch);

	if(tcp_handles[handle].buf_end-tcp_handles[handle].buf_start > 0)
	{
		
		*bytes=tcp_handles[handle].buf_end-tcp_handles[handle].buf_start;
		return(TRUE);
	}

return(TCP_GetBytesAvail_Sync(ch, bytes));
/*	
	while(a < TCP_HNDLS)
	{
		if(tcp_avail_wait[a].indi==TW_FREE)
		{
			tcp_avail_wait[a].indi=TW_WAITING;
			tcp_avail_wait[a].ch=ch;
			goto _tgb_cont;
		}
		++a;
	}
	return(FALSE);

_tgb_cont:
	if(TCP_GetBytesAvail(ch, cb_get_avail)==FALSE) 
	{
		tcp_avail_wait[a].indi=TW_FREE;
		return(FALSE);
	}
	
	while(tcp_avail_wait[a].indi==TW_WAITING)
	{
		Wait();
		if(tcp_avail_wait[a].indi==TW_WAITING)
			evnt_timer(TW_TIMER,0); 
	}
	
	if(tcp_avail_wait[a].indi==TW_DONE_ERR)
	{
		tcp_avail_wait[a].indi=TW_FREE;
		return(FALSE);
	}
	*bytes=tcp_avail_wait[a].bytes;
	tcp_avail_wait[a].indi=TW_FREE;
	return(TRUE);
*/
}

void cb_tcp_receive(short result, ConnectionHandle ch, void *buffer, ulong bytes, ushort urgent)
{
	int a=0;
	
	while(a < TCP_HNDLS)
	{
		if((tcp_recv_wait[a].indi==TW_WAITING) && (tcp_recv_wait[a].ch==ch))
			goto _cbr_cont;
		++a;
	}
	#ifdef iodebug
	Dftext("[Recv: No handle]\r\n");
	#endif
	return;

_cbr_cont:
	if(result!=ERR_NONE) {
/*		if(result==1)
		{
			#ifdef iodebug
				Dftext("[Trken-Override 2]\r\n");
			#endif
			goto _tov2;
		}*/
		#ifdef iodebug
			Dftext("[Recv error: ");Dfnumber(result);Dftext("(Bytes: "); Dfnumber(bytes);Dftext(")]\r\n");
		#endif
		tcp_recv_wait[a].indi=TW_DONE_ERR; return;
	}
/*_tov2:*/
	#ifdef iodebug
	Dftext("[Recvd bytes:");Dfnumber(bytes);Dftext("]\r\n");
	#endif
	tcp_recv_wait[a].buffer=buffer;
	tcp_recv_wait[a].bytes=bytes;
	tcp_recv_wait[a].urgent=urgent;
	tcp_recv_wait[a].indi=TW_DONE_OK;
}

Boolean TCP_Receive_loc_Sync(ConnectionHandle ch, ulong tout, void *buffer, ulong *maxlen, ushort *urgent)
{
	int a=0;

/*return(TCP_Receive_Sync(ch, tout, buffer, maxlen, urgent));*/
	
	while(a < TCP_HNDLS)
	{
		if(tcp_recv_wait[a].indi==TW_FREE)
		{
			tcp_recv_wait[a].indi=TW_WAITING;
			tcp_recv_wait[a].ch=ch;
			goto _trc_cont;
		}
		++a;
	}
	return(FALSE);

_trc_cont:
	if(TCP_Receive(ch, tout, *maxlen, cb_tcp_receive)==FALSE) 
	{
	#ifdef iodebug
	Dftext("[Recverr (1)]\r\n");
	#endif
		tcp_recv_wait[a].indi=TW_FREE;
		return(FALSE);
	}
	
	while(tcp_recv_wait[a].indi==TW_WAITING)
	{
		Wait();
		if(tcp_recv_wait[a].indi==TW_WAITING)
			evnt_timer(TW_TIMER,0); 
	}
	
	if(tcp_recv_wait[a].indi==TW_DONE_ERR)
	{
		tcp_recv_wait[a].indi=TW_FREE;
		return(FALSE);
	}
	if(tcp_recv_wait[a].bytes > 0)
		memcpy(buffer, tcp_recv_wait[a].buffer, tcp_recv_wait[a].bytes);
	*maxlen=tcp_recv_wait[a].bytes;	
	*urgent=tcp_recv_wait[a].urgent;
	tcp_recv_wait[a].indi=TW_FREE;
	return(TRUE);
}

long x_tcp_recv(int handle, uchar *buf, ulong len, int *flags, int peek)
{
	ulong	blen;
	
	if(defaults.using_mac_os)
	{
		if(tcp_handles[handle].recv_buf==NULL)
		{
			#ifdef iodebug
				Dftext("[X_TCP_Recv: no buffer]\r\n");
			#endif
			if(peek) return(EOPNOTSUPP);
	/*		if(TCP_GetBytesAvail_loc_Sync(tcp_handles[handle].ch, &blen)==FALSE) return(ERROR);
			if(blen==0) return(0);
			if(blen > len) */  blen=len;
			if(TCP_Receive_loc_Sync(tcp_handles[handle].ch, 0, buf, &blen, (ushort*)flags)==FALSE) return(ERROR);
			if(*flags) *flags=2;	/* Urgent */
			return(blen);
		}

		#ifdef iodebug
			Dftext("[X_TCP_Recv:");
		#endif
/*		if(len > tcp_handles[handle].buf_end-tcp_handles[handle].buf_start)*/
		if(tcp_handles[handle].buf_end-tcp_handles[handle].buf_start < 1)
		{
			#ifdef iodebug
				Dftext(" Fill buffer");
			#endif
			/* Fill local buffer */
			if(tcp_handles[handle].buf_start)	/* Copy back to start of buffer */
			{
				blen=0;
				while(tcp_handles[handle].buf_start < tcp_handles[handle].buf_end)
					tcp_handles[handle].recv_buf[blen++]=tcp_handles[handle].recv_buf[tcp_handles[handle].buf_start++];
				tcp_handles[handle].buf_start=0;
				tcp_handles[handle].buf_end=blen;
			}
			blen=RECV_BUF_SIZE-tcp_handles[handle].buf_end;
			if(blen)
			{
				#ifdef iodebug
					Dftext(" Mac Recv");
				#endif
				if(TCP_Receive_loc_Sync(tcp_handles[handle].ch, 0, &(tcp_handles[handle].recv_buf[tcp_handles[handle].buf_end]), &blen, (ushort*)flags)==FALSE)
				{
					#ifdef iodebug
						Dftext("return ERROR]\r\n");
					#endif
					return(ERROR);
				}
				#ifdef iodebug
					Dftext(" ok");
				#endif
			}
			tcp_handles[handle].buf_end+=blen;
			if(*flags) *flags=2;	/* Urgent */
		}
		if(len > tcp_handles[handle].buf_end - tcp_handles[handle].buf_start)
			len=tcp_handles[handle].buf_end-tcp_handles[handle].buf_start;
		
		/* Now copy from local buffer */
		blen=len;
		while(len--)
			*buf++=tcp_handles[handle].recv_buf[tcp_handles[handle].buf_start++];
		if(peek) tcp_handles[handle].buf_start-=blen;
		if(tcp_handles[handle].buf_start >= tcp_handles[handle].buf_end)
			tcp_handles[handle].buf_start=tcp_handles[handle].buf_end=0;
		#ifdef iodebug
			Dftext(" returning "); Dfnumber(blen); Dftext("]\r\n");
		#endif
		return(blen);
	}
	
	return(tcp_recv(handle, buf, len, flags, peek));
}

int x_check_assigned_tcb(int parent)
{
	int	local_handle;
	
	if(defaults.using_mac_os)
	{
		local_handle=get_first_child(parent);
		if(local_handle==ERROR) return(ERROR);
		return(local_handle);
	}
	
	return(check_assigned_tcb(parent));
}

int x_find_assigned_tcb(int parent, sockaddr_in *addr)
{
	int	local_handle;
	
	if(defaults.using_mac_os)
	{
		local_handle=get_first_child(parent);
		if(local_handle==ERROR) return(ERROR);
		tcp_handles[local_handle].parent_sock=-1;
		tcp_handles[local_handle].flags &= (~TCPL_CONN);
		addr->sin_port=tcp_handles[local_handle].remote_port;
		addr->sin_addr=tcp_handles[local_handle].remote_ip;
		return(local_handle);
	}
	
	return(find_assigned_tcb(parent, addr));
}

tcb *x_find_tcb_by_sock(int src_port, ulong src_ip, int dst_port, ulong dst_ip)
{/* Only used by <sockets> as a true/false function, so no pointer
		to a real tcb required */
	int a=0;

	src_ip=src_ip;
	
	if(defaults.using_mac_os)
	{
		while(a < TCP_HNDLS)
		{
			if((tcp_handles[a].flags & TCPL_USED) &&
					(tcp_handles[a].local_port==src_port) &&
					(tcp_handles[a].remote_port==dst_port) &&
					(tcp_handles[a].remote_ip==dst_ip))
					return((tcb*)1);
			++a;
		}
		return(NULL);
	}	
	
	return(find_tcb_by_sock(src_port, src_ip, dst_port, dst_ip));
}

void cb_tcp_release(short result, ConnectionHandle ch)
{
	if(result != ERR_NONE) return;
	tcp_handles[ch].flags=TCPL_NOTUSED;
	if(tcp_handles[ch].recv_buf) Mfree(tcp_handles[ch].recv_buf);
}

void x_tcp_kill_childs(int parent)
{
	int a=0;
	
	if(defaults.using_mac_os)
	{
		while(a < TCP_HNDLS)
		{
			if((tcp_handles[a].flags & TCPL_USED) && (tcp_handles[a].flags & TCPL_LISTEN) && (tcp_handles[a].parent_sock==parent))
				TCP_Release(tcp_handles[a].ch, cb_tcp_release);
			++a;
		}
		return;
	}

	tcp_kill_childs(parent);
}

void cb_tcp_close(short result, ConnectionHandle ch)
{
	int local_handle;
	
	if(result != ERR_NONE) return;
	if((local_handle=get_tcp_handle(ch))==ERROR) return;
	TCP_Release(tcp_handles[local_handle].ch, cb_tcp_release);
}

int x_tcp_close(int handle)
{
	if(defaults.using_mac_os)
	{
		if(TCP_Close(tcp_handles[handle].ch, cb_tcp_close)==FALSE)
			return(ERROR);
		return(E_OK);
	}
	
	return(tcp_close(handle));
}

int x_tcp_abort(int handle)
{
	if(defaults.using_mac_os)
	{
		if(TCP_Abort(tcp_handles[handle].ch, cb_tcp_close)==FALSE)
			return(ERROR);
		return(E_OK);
	}
	
	return(tcp_abort(handle));
}

void x_tcp_all_abort(void)
{
	int a=0;
	
	if(defaults.using_mac_os)
	{
		if(!init_ok) return;
		while(a < TCP_HNDLS)
		{
			if(tcp_handles[a].flags & TCPL_USED)
				TCP_Abort(tcp_handles[a].ch, cb_tcp_close);
			++a;
		}
		return;
	}

	tcp_all_abort();	
}


/* ------------ */
/* UDP adaption */
/* ------------ */


int set_udp_handle(int port, ConnectionHandle ch)
{
	int a=0;
	
	while(a < defaults.udp_count)
	{
		if((udp_handles[a].port==-1) || (udp_handles[a].port==port))
		{
			udp_handles[a].port=port;
			udp_handles[a].ch=ch;
			return(E_OK);
		}
		++a;
	}
	return(ERROR);
}

ConnectionHandle get_udp_handle(int port)
{
	int a=0;
	
	while(a < defaults.udp_count)
	{
		if(udp_handles[a].port==port) return(udp_handles[a].ch);
		++a;
	}
	return(0);
}

void free_udp_handle(int port)
{
	int a=0;
	while(a < defaults.udp_count)
	{
		if(udp_handles[a].port==port) 
		{
			udp_handles[a].port=-1;
			return;
		}
		++a;
	}
}

void cb_udp_release(short result, ConnectionHandle handle)
{/* Supress warning */
	if(result==handle) return;
}

void free_all_udp(void)
{
	int a=0;
	
	while(a < defaults.udp_count)
	{
		if(udp_handles[a].port > -1)
			UDP_Release(udp_handles[a].ch, cb_udp_release);
		udp_handles[a].port=-1;
		++a;
	}
}

Boolean sem_UDP_Create_Sync(ConnectionHandle *handle, ushort *localPort)
{
	Boolean res;
	
	while(!set_flag(STIP_SYNC_UC)) evnt_timer(20,0);
	res=UDP_Create_Sync(handle, localPort);
	clear_flag(STIP_SYNC_UC);
	return(res);
}

int x_udp_open(int port)
{
	ConnectionHandle ch;
	
	if(defaults.using_mac_os)
	{
		if(sem_UDP_Create_Sync(&ch, (ushort*)&port)==TRUE)
			return(set_udp_handle(port, ch));

		return(ERROR);
	}
	
	return(udp_open(port));
}

void cb_udp_send(short result, ConnectionHandle handle)
{/* Callback for udp_send */
/* Supress warning: */
	if(result==handle) return;
}

int x_udp_send(int src_port, int dst_port, ulong dst_ip, uchar *buf, int len)
{
	char tbuf[20];
	
	if(defaults.using_mac_os)
	{
		if(UDP_Write(get_udp_handle(src_port), loc_ntoa(dst_ip, tbuf), dst_port, buf, len, cb_udp_send)==TRUE)
			return(E_OK);
		return(ERROR);
	}
	
	return(udp_send(src_port, dst_port, dst_ip, buf, len));
}

void cb_udp_read(short result, ConnectionHandle ch, ulong remote_ip, ushort remote_port, void *buffer, ulong bytes)
{
	int a=0;
	
	while(a < defaults.udp_count)
	{
		if((udp_recv_wait[a].indi==TW_WAITING) && (udp_recv_wait[a].ch==ch))
			goto _cbur_cont;
		++a;
	}
	return;

_cbur_cont:
	if(result!=ERR_NONE) {udp_recv_wait[a].indi=TW_DONE_ERR; return;}
	udp_recv_wait[a].buffer=buffer;
	udp_recv_wait[a].bytes=bytes;
	udp_recv_wait[a].remote_port=remote_port;
	udp_recv_wait[a].remote_ip=remote_ip;
	udp_recv_wait[a].indi=TW_DONE_OK;
}

Boolean UDP_Read_loc_Sync(ConnectionHandle ch, ulong tout, sockaddr_in *from, void *buffer, ulong *maxlen)
{
	int a=0;
	
	while(a < defaults.udp_count)
	{
		if(udp_recv_wait[a].indi==TW_FREE)
		{
			udp_recv_wait[a].indi=TW_WAITING;
			udp_recv_wait[a].ch=ch;
			goto _urc_cont;
		}
		++a;
	}
	return(FALSE);

_urc_cont:
	if(UDP_Read(ch, tout, cb_udp_read)==FALSE) 
	{
		udp_recv_wait[a].indi=TW_FREE;
		return(FALSE);
	}
	
	while(udp_recv_wait[a].indi==TW_WAITING)
	{
		Wait();
		if(udp_recv_wait[a].indi==TW_WAITING)
			evnt_timer(TW_TIMER,0); 
	}
	
	if(udp_recv_wait[a].indi==TW_DONE_ERR)
	{
		udp_recv_wait[a].indi=TW_FREE;
		return(FALSE);
	}
	memcpy(buffer, udp_recv_wait[a].buffer, udp_recv_wait[a].bytes);
	*maxlen=udp_recv_wait[a].bytes;	
	from->sin_port=udp_recv_wait[a].remote_port;
	from->sin_addr=udp_recv_wait[a].remote_ip;
	udp_recv_wait[a].indi=TW_FREE;
	return(TRUE);
}

int x_udp_recv(int port, uchar *buf, int len, int peek, void *from, int *fromlen)
{
	ulong llen=len;
	
	if(defaults.using_mac_os)
	{
		if(peek) return(EOPNOTSUPP);
		/* Timeout 1 second, maybe 0 works also ? */
		if(UDP_Read_loc_Sync(get_udp_handle(port), 1, from, buf, &llen)==TRUE)
			return((int)llen);
		return(ERROR);
	}
	
	return(udp_recv(port, buf, len, peek, from, fromlen));
}

int x_udp_close(int port)
{
	if(defaults.using_mac_os)
	{
		if(UDP_Release(get_udp_handle(port), cb_udp_release)==TRUE)
		{
			free_udp_handle(port);
			return(E_OK);
		}
		return(ERROR);
	}
	
	return(udp_close(port));
}

void x_udp_all_abort(void)
{
	if(defaults.using_mac_os)
	{
		if(!init_ok) return;
		free_all_udp();
		return;
	}
	
	udp_all_abort();
}

Boolean sem_DNR_Sync(IPAddress remoteIPAddress, ulong *addr)
{
	Boolean res;
	
	while(!set_flag(STIP_SYNC_DNR)) evnt_timer(20,0);
	res=DNR_Sync(remoteIPAddress, addr);
	clear_flag(STIP_SYNC_DNR);
	return(res);
}

ulong	x_resolve(char *host)
{
	ulong	ipa;
	
	if(sem_DNR_Sync(host, &ipa)==FALSE) return(INADDR_NONE);
	return(ipa);
}

void x_timer_jobs(void)
{
	Wait();
}