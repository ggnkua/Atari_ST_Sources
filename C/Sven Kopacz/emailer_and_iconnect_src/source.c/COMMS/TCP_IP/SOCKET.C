#define iodebug

#include <stdio.h>
#include <stdlib.h>
#include <atarierr.h>
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

#include "stiplink.h"

/* ms to wait when polling read */
#define POLL_WAIT 100

extern default_values defaults;
extern BASPAG **act_pd;

sock_dscr	*first_sock=NULL;

int		port_number=-1;
int		sock_handle_init=0;
int		aborting=0;
fd_set assigned_sockets, blocking_calls;

int get_port_number(void)
{
	if(port_number==-1)
		port_number=defaults.port_init;
	++port_number;
	if(port_number > defaults.port_max)
		port_number=defaults.port_init;
	return(port_number);
}

int get_sock_handle(void)
{
	int a;
	
	if(!sock_handle_init)
	{/* Intialize */
		sock_handle_init=1;
		FD_ZERO(&assigned_sockets);
		FD_ZERO(&blocking_calls);
	}
	
	for(a=1; a < FD_SETSIZE; ++a)
		if(!FD_ISSET(a, &assigned_sockets))
		{
			FD_SET(a, &assigned_sockets);
			return(a);
		}
	return(ENHNDL);
}

sock_dscr	*find_sock(int handle)
{
	sock_dscr	*sd=first_sock;
	
	while(sd)
	{
		if(sd->handle == handle)
			break;
		sd=sd->next;
	}
	if(sd && (*act_pd != sd->owner_pd))
		sd=NULL;
		
	return(sd);
}

void delete_sock(sock_dscr *sc)
{
	sock_dscr	**prev=&first_sock, *sd=first_sock;
	
	while(sd)
	{
		if(sd==sc)
		{/* found, now delete */
			FD_CLR(sd->handle, &assigned_sockets);
			*prev=sd->next;
			ifree(sd);
			return;
		}
		prev=&(sd->next);
		sd=sd->next;
	}
}

sock_dscr *new_sock(void)
{
	sock_dscr	**prev=&first_sock, *sd;

	/* Make a new socket */
	while(*prev)
		prev=&((*prev)->next);
	
	*prev=sd=(sock_dscr*)tmalloc(sizeof(sock_dscr));

	return(sd);
}

int cdecl socket(int af, int type, int protocol)
{
	sock_dscr	*sd;
	int rval;

	#ifdef iodebug
		Dftext("[new socket]\r\n");
	#endif		
	
	if(af != AF_INET)
		return(EAFNOSUPPORT); /* Adress family not supported */

	if((type != SOCK_STREAM) && (type != SOCK_DGRAM))
		return(ESOCKTNOSUPPORT); /* Socket type not supported */
		
	if(type==SOCK_STREAM)
	{
		if(protocol == IPPROTO_IP) protocol=IPPROTO_TCP;
		if(protocol != IPPROTO_TCP)
			return(EPROTONOSUPPORT); /* Protocol not supported */
	}
	else /* SOCK_DGRAM */
	{
		if(protocol == IPPROTO_IP) protocol=IPPROTO_UDP;
		if(protocol != IPPROTO_UDP)
			return(EPROTONOSUPPORT); /* Protocol not supported */
	}

	while(!set_flag(SOCK_SEM));
	
	/* Make a new socket */
	/* Make a new socket */
	rval=get_sock_handle();
	if(rval < 0)
	{/* No handles left etc.. */
		clear_flag(SOCK_SEM);
		return(rval);
	}
	
	sd=new_sock();
	
	if(sd==NULL)
	{
		FD_CLR(rval, &assigned_sockets);
		clear_flag(SOCK_SEM);
		return(ENSMEM);
	}

	sd->next=NULL;
	sd->owner_pd=*act_pd;
	sd->handle=rval;
	sd->type=type;
	sd->flags=0;
	sd->port=-1;
	sd->tcp_handle=-1;
	sd->tcp_sig=0;
	sd->udp_dport=-1;
	sd->udp_dip=0;
	sd->file_status_flags=0;
	sd->so_options=0;
	sd->l_onoff=0;
	sd->l_linger=0;
	sd->so_error=0;
	clear_flag(SOCK_SEM);
	#ifdef iodebug
		Dftext("[New socket #");Dfnumber(rval);Dftext("]\r\n");
	#endif
	return(rval);	
	/* Do not access socket pointers after freeing SOCK_SEM, so
	  not return(sd->handle); !!! */
}

int cdecl bind(int s, const void *addr, int addrlen)
{
	sock_dscr	*sd, *sb;
	sockaddr_in	*sa=(sockaddr_in*)addr;
	int err;
	
	while(!set_flag(SOCK_SEM));
	
	sd=find_sock(s);
	#ifdef iodebug
		Dftext("[bind #");Dfnumber(s);Dftext("]\r\n");
	#endif
	
	if(sd==NULL)
	{
		clear_flag(SOCK_SEM);
		return(ENOTSOCK);
	}

	if(addrlen != sizeof(sockaddr_in))
	{
		sd->so_error=EINVAL;
		clear_flag(SOCK_SEM);
		return(EINVAL);
	}

	if(sd->flags & SF_SHUTDOWN)
	{
		sd->so_error=EINVAL;
		clear_flag(SOCK_SEM);
		return(EINVAL);
	}
	
	if((sd->type != SOCK_STREAM) && (sd->type != SOCK_DGRAM))
	{
		sd->so_error=EOPNOTSUPP;
		clear_flag(SOCK_SEM);
		return(EOPNOTSUPP);
	}
	
	if(sd->port > 0)
	{
		sd->so_error=EINVAL;
		clear_flag(SOCK_SEM);
		return(EINVAL);
	}
	
	sd->port=sa->sin_port;
	
	if(sd->port < 1)	/* Not assigned */
		sd->port=get_port_number();
		
	#ifdef iodebug
		Dftext("[bind to ");Dfnumber(sd->port);Dftext("]\r\n");
	#endif

	if(sd->type==SOCK_DGRAM)
	{/* UDP-Port already assigned? */
		sb=first_sock;
		while(sb)
		{
			if((sd != sb) && (sb->type==SOCK_DGRAM) && (sb->port == sa->sin_port))
			{
				sd->port=-1;
				sd->so_error=EADDRINUSE;
				clear_flag(SOCK_SEM);
				return(EADDRINUSE);
			}
			sb=sb->next;
		}
		err=x_udp_open(sd->port);	/* uses tmalloc, maybe free SOCK_SEM before? */
		if(err < 0)
			sd->port=-1;
		sd->so_error=err;
		clear_flag(SOCK_SEM);
		return(err);
	}

	sd->so_error=0;
	clear_flag(SOCK_SEM);
	return(E_OK);
}

int cdecl listen(int s, int backlog)
{
	sock_dscr	*sd;
	int				ierr, backmem;

	#ifdef iodebug
		Dftext("[listen on socket #");Dfnumber(s);Dftext("]\r\n");
	#endif
	if(backlog < 1) backlog=1;
	if(backlog > defaults.max_listen) backlog=defaults.max_listen;
	
	while(!set_flag(SOCK_SEM));
	
	sd=find_sock(s);
	
	if(sd==NULL)
	{
		clear_flag(SOCK_SEM);
		return(ENOTSOCK);
	}

	if(sd->type!=SOCK_STREAM)
	{
		sd->so_error=EOPNOTSUPP;
		clear_flag(SOCK_SEM);
		return(EOPNOTSUPP);
	}
	
	if((sd->tcp_handle > -1) || (sd->flags & SF_SHUTDOWN))
	{
		sd->so_error=EINVAL;
		clear_flag(SOCK_SEM);
		return(EINVAL);
	}
		
	sd->flags|=SF_PARENT;

	if(sd->port == -1)	/* Not yet assigned */
		sd->port=get_port_number();

	backmem=backlog;	
	do
	{	/* Open-port=-1, open_ip=0 */
		ierr=x_tcp_open(sd->port, -1, 0, sd->handle, &(sd->tcp_sig), defaults.user_timeout, defaults.precedence, defaults.security);
	}while((ierr >= 0) && (backlog-- >0 ));
	
	if(backlog==backmem)
	{/* No tcb's were created */
		#ifdef iodebug
			Dftext("[bad listen, e#");Dfnumber(ierr);Dftext("]\r\n");
		#endif
		sd->so_error=ierr;
		clear_flag(SOCK_SEM);
		return(ierr);
	}

	/* At least one was created */
	sd->so_error=E_OK;
	clear_flag(SOCK_SEM);
	return(E_OK);
}

int cdecl accept(int s, const void *addr, int *addrlen)
{
	sock_dscr	*sd, *sb;
	sockaddr_in	*sa=(sockaddr_in*)addr;
	int				tcp_handle, rval, cont;
	long			fs_flags;

	*addrlen=(int)sizeof(sockaddr_in);
	
	while(!set_flag(SOCK_SEM));
	
	sd=find_sock(s);
	
	if(sd==NULL)
	{
		clear_flag(SOCK_SEM);
		return(ENOTSOCK);
	}

	if(sd->type != SOCK_STREAM)
	{
		sd->so_error=EOPNOTSUPP;
		clear_flag(SOCK_SEM);
		return(EOPNOTSUPP);
	}
	
	if((sd->flags & SF_SHUTDOWN) || (!(sd->flags & SF_PARENT)))
	{
		sd->so_error=EINVAL;
		clear_flag(SOCK_SEM);
		return(EINVAL);
	}
		
	fs_flags=sd->file_status_flags;
	FD_SET(sd->handle, &blocking_calls);
	clear_flag(SOCK_SEM);
	
	cont=1;
	while(cont)
	{
		tcp_handle=x_find_assigned_tcb(sd->handle, sa);
		if(tcp_handle < 0)
		{/* No pending connections */
			if(fs_flags & O_NONBLOCK)
			{
				sd->so_error=EWOULDBLOCK;
				FD_CLR(sd->handle, &blocking_calls);
				return(EWOULDBLOCK);
			}
			else if(fs_flags & O_NDELAY)
			{
				sd->so_error=0;
				FD_CLR(sd->handle, &blocking_calls);
				return(EWOULDBLOCK);
			}
			
			if(aborting)
			{
				FD_CLR(sd->handle, &blocking_calls);
				return(ENETDOWN);
			}
			iwait(POLL_WAIT);
		}
		else cont=0;
	}
	/* Get back SOCK_SEM to make new socket */
	while(!set_flag(SOCK_SEM))
		if(aborting)
		{
			FD_CLR(sd->handle, &blocking_calls);
			return(ENETDOWN);
		}

	FD_CLR(sd->handle, &blocking_calls);

	/* Make a new socket */
	rval=get_sock_handle();
	if(rval < 0)
	{/* No handles left etc.. */
		clear_flag(SOCK_SEM);
		return(rval);
	}
	
	sb=new_sock();
	
	if(sb==NULL)
	{
		sd->so_error=ENSMEM;
		FD_CLR(rval, &assigned_sockets);
		clear_flag(SOCK_SEM);
		return(ENSMEM);
	}
	sb->next=NULL;
	sb->owner_pd=*act_pd;
	sb->handle=rval;
	sb->type=SOCK_STREAM;
	sb->flags=0;
	sb->port=sd->port;
	sb->tcp_handle=tcp_handle;
	sb->tcp_sig=0;
	sb->file_status_flags=sd->file_status_flags;
	sd->so_error=E_OK;
	clear_flag(SOCK_SEM);
	return(rval);
}

int cdecl connect(int s, const void *addr, int addrlen)
{
	sock_dscr	*sd;
	sockaddr_in	*sa=(sockaddr_in*)addr;
	long			fs_flags;
	tcb				mtcb;
	int				state, ierr, tcph;

	while(!set_flag(SOCK_SEM));
	
	sd=find_sock(s);
	
	if(sd==NULL)
	{
		clear_flag(SOCK_SEM);
		return(ENOTSOCK);
	}

	if(addrlen != sizeof(sockaddr_in))
	{
		sd->so_error=EINVAL;
		clear_flag(SOCK_SEM);
		return(EINVAL);
	}

	if(sd->flags & (SF_SHUTDOWN|SF_PARENT))	
	{
		sd->so_error=EINVAL;
		clear_flag(SOCK_SEM);
		return(EINVAL);
	}

	if(sd->type == SOCK_DGRAM)
	{
		if(sa == NULL)
		{/* Delete connection */
			sd->udp_dport=-1;
			sd->udp_dip=0;
		}
		else
		{
			sd->udp_dport=sa->sin_port;
			sd->udp_dip=sa->sin_addr;
		}
		sd->so_error=E_OK;
		clear_flag(SOCK_SEM);
		return(E_OK);
	}
	
	/* SOCK_STREAM */	
	if(sa == NULL)
	{
		sd->so_error=EINVAL;
		clear_flag(SOCK_SEM);
		return(EINVAL);
	}
	
	if(sd->tcp_handle > -1)
	{
		state=x_tcp_status(sd->tcp_handle, &mtcb);
		if(state < 0)
		{/* tcb was deleted, but must have been connected, 
				otherwise I wouldn't have a tcb-handle.
				Anyway, reconnection is not allowed. Use a new socket. */
			return(ECONNRESET);
		}
		
		if((mtcb.dst_ip==sa->sin_addr) && (mtcb.dst_port==sa->sin_port))
		{
			if((state==TCPS_SYNSENT) || (state==TCPS_SYNRCVD))
			{
				sd->so_error=EALREADY;
				clear_flag(SOCK_SEM);
				return(EALREADY);
			}
		}
		
		if((state!=TCPS_CLOSED)&&(state!=TCPS_LISTEN))
		{
			sd->so_error=EISCONN;
			clear_flag(SOCK_SEM);
			return(EISCONN);
		}
	}

	if(sd->port == -1)	/* Not yet assigned */
		sd->port=get_port_number();
	
	if(x_find_tcb_by_sock(sd->port, defaults.my_ip, sa->sin_port, sa->sin_addr) != NULL)
	{
		sd->so_error=EADDRINUSE;
		clear_flag(SOCK_SEM);
		return(EADDRINUSE);
	}
	
	fs_flags=sd->file_status_flags;
	tcph=ierr=sd->tcp_handle=x_tcp_open(sd->port, sa->sin_port, sa->sin_addr, 0, &(sd->tcp_sig), defaults.user_timeout, defaults.precedence, defaults.security);
	if(ierr < 0)
	{
		sd->so_error=ierr;
		clear_flag(SOCK_SEM);
		return(ierr);
	}
	
	if(fs_flags & (O_NDELAY|O_NONBLOCK))
	{
		sd->so_error=EINPROGRESS;
		clear_flag(SOCK_SEM);
		return(EINPROGRESS); /* NO ERROR! Remember: Non-blocking operation */
	}
	
	/* Blocking operation, wait for connection or closing */
	FD_SET(sd->handle, &blocking_calls);
	clear_flag(SOCK_SEM);
	while(1)
	{
		ierr=x_tcp_status(tcph, NULL);
		switch(ierr)
		{
			case ERROR: case EIHNDL:
			case TCPS_CLOSED:
				/* refused or timedout connection */
				if(sd->tcp_sig)
					sd->so_error=ECONNREFUSED;
				else
					sd->so_error=ETIMEDOUT;
				sd->tcp_handle=-1;
				FD_CLR(sd->handle, &blocking_calls);
				return(ETIMEDOUT); 
			case TCPS_ESTABLISHED:
				sd->so_error=0;
				FD_CLR(sd->handle, &blocking_calls);
				return(0);
			/* Due to simultaneous connect, the tcb might also pend in
				 SYNRCVD state, but tcp has also timeout for this */
		}
		if(aborting)
		{
			FD_CLR(sd->handle, &blocking_calls);
			return(ENETDOWN);
		}
		iwait(POLL_WAIT);
	}
}

int cdecl swrite(int s, const void *msg, int len)
{
	return(send(s, msg, len, 0));
}

int cdecl send(int s, const void *msg, int len, int flags)
{/* Only supported Flag is MSG_OOB and will be converted
    to URGENT on TCP-Level */
 	sockaddr_in	ad;
	sock_dscr		*sd;
	int					state, ierr;

	while(!set_flag(SOCK_SEM));
		
	sd=find_sock(s);

	if(sd==NULL)
	{
		clear_flag(SOCK_SEM);
		return(ENOTSOCK);
	}

	if(flags & (~MSG_OOB))
	{
		sd->so_error=EOPNOTSUPP;
		clear_flag(SOCK_SEM);
		return(EOPNOTSUPP);
	}

	if(sd->flags & SF_SHUTSEND)
	{
		sd->so_error=EPIPE;
		clear_flag(SOCK_SEM);
		return(EPIPE);
	}

	if(sd->type == SOCK_DGRAM)
	{
		if(sd->udp_dport == -1)
		{
			sd->so_error=EDESTADDRREQ;
			clear_flag(SOCK_SEM);
			return(EDESTADDRREQ);
		}
		ad.sin_port=sd->udp_dport;
		ad.sin_addr=sd->udp_dip;
		clear_flag(SOCK_SEM);
		return(sendto(s, msg, len, flags, &ad, (int)sizeof(sockaddr_in)));
	}
	
	/* SOCK_STREAM */
	if(sd->tcp_handle < 0)
	{
		sd->so_error=ENOTCONN;
		clear_flag(SOCK_SEM);
		return(ENOTCONN);
	}
	
	if(len < 0)
	{
		sd->so_error=EINVAL;
		clear_flag(SOCK_SEM);
		return(EINVAL);
	}

	state=x_tcp_status(sd->tcp_handle, NULL);
	if(state < 0)
	{/* tcb was deletet (probably due to timeout on connection) */
		sd->tcp_handle=-1;
		sd->so_error=ENOTCONN;
		clear_flag(SOCK_SEM);
		return(ENOTCONN);
	}
	
	switch(state)
	{
		case TCPS_LISTEN:
		case TCPS_CLOSED:
			sd->so_error=ENOTCONN;
			clear_flag(SOCK_SEM);
			return(ENOTCONN);
		
		case TCPS_SYNSENT:
		case TCPS_SYNRCVD:
		case TCPS_ESTABLISHED:
		case TCPS_CLOSEWAIT:
			if(flags & MSG_OOB) flags=1;
			else flags=0;
			ierr=x_tcp_send(sd->tcp_handle, msg, len, flags, -1);
			if(ierr < 0)
				sd->so_error=ierr;
			else
				sd->so_error=E_OK;
			clear_flag(SOCK_SEM);
			return(ierr);
		
		default:
		/* Connection closing */
			sd->so_error=EPIPE;
			clear_flag(SOCK_SEM);
			return(EPIPE);
	}
}

int cdecl sendto(int s, const void *msg, int len, int flags, void *to, int tolen)
{
	sockaddr_in	*ad=to;
	sock_dscr		*sd;
	int					ierr;


	while(!set_flag(SOCK_SEM));
		
	sd=find_sock(s);

	if(sd==NULL)
	{
		clear_flag(SOCK_SEM);
		return(ENOTSOCK);
	}

	if(flags & (~MSG_OOB))
	{
		sd->so_error=EOPNOTSUPP;
		clear_flag(SOCK_SEM);
		return(EOPNOTSUPP);
	}

	if(sd->type == SOCK_STREAM)
	{
		clear_flag(SOCK_SEM);
		return(send(s, msg, len, flags));
	}
	
	/* SOCK_DGRAM */
	
	if(tolen != (int)sizeof(sockaddr_in))
	{
		sd->so_error=EINVAL;
		clear_flag(SOCK_SEM);
		return(EINVAL);
	}
	
	if(sd->udp_dport != -1)
	{
		if((sd->udp_dport != ad->sin_port) || (sd->udp_dip != ad->sin_addr))
		{/* Wrong destination for connected socket */
			sd->so_error=EISCONN;
			clear_flag(SOCK_SEM);
			return(EISCONN);
		}
	}
	
	if(sd->port == -1)
	{
		sd->port=get_port_number();
		ierr=x_udp_open(sd->port);
		if(ierr < 0)
		{
			sd->so_error=ierr;
			clear_flag(SOCK_SEM);
			return(ierr);
		}
	}
		
	ierr=x_udp_send(sd->port, ad->sin_port, ad->sin_addr, msg, len);
	if(sd->so_error < 0)
		sd->so_error=ierr;
	else
		sd->so_error=E_OK;	
	clear_flag(SOCK_SEM);
	return(ierr);
}

long cdecl sread(int s, void *buf, long len)
{
	return(recv(s, buf, len, 0));
}

long cdecl recv(int s, void *buf, long len, int flags)
{/* Only Flag supported is MSG_PEEK */

	sock_dscr	*sd;
	int				dum, cont, tcph;
	long			ierr, fs_flags;
	tcb				mtcb;

	while(!set_flag(SOCK_SEM));

	sd=find_sock(s);
	
	if(sd==NULL)
	{
		clear_flag(SOCK_SEM);
		return(ENOTSOCK);
	}
	
	if(flags & (~MSG_PEEK))
	{
		sd->so_error=EOPNOTSUPP;
		clear_flag(SOCK_SEM);
		return(EOPNOTSUPP);
	}

	if(sd->type == SOCK_DGRAM)
	{
		clear_flag(SOCK_SEM);
		return(recvfrom(s, buf, len, flags, NULL, NULL));
	}
	
	/* SOCK_STREAM */
	if(sd->tcp_handle < 0)
	{
		sd->so_error=ENOTCONN;
		clear_flag(SOCK_SEM);
		return(ENOTCONN);
	}
	
	if(sd->flags & SF_SHUTRECV)
	{
		sd->so_error=E_OK;
		clear_flag(SOCK_SEM);
		return(0);	/* End-of-file condition */
	}
	
	ierr=x_tcp_status(sd->tcp_handle, &mtcb);
	if(ierr < 0)
	{/* tcb was deletet (probably due to timeout on connection) */
		sd->tcp_handle=-1;
		sd->so_error=ENOTCONN;
		clear_flag(SOCK_SEM);
		return(ENOTCONN);
	}

	switch((int)ierr)
	{
		case	TCPS_CLOSED:
		case	TCPS_LISTEN:
		case	TCPS_SYNSENT:
		case	TCPS_SYNRCVD:
			sd->so_error=ENOTCONN;
			clear_flag(SOCK_SEM);
			return(ENOTCONN);
		
		case 	TCPS_CLOSEWAIT:
		/* remote host has sent fin */
			if(mtcb.recv_buf_len > 0) break; /* Still data in rcv-buffer */
			sd->so_error=ECONNRESET;
			clear_flag(SOCK_SEM);
			return(ECONNRESET);

		/* The following occurs, if the user has only initiated a send-
		   shutdown and the remote host also closed the con */
		case TCPS_LASTACK:
		case TCPS_CLOSING:
		case TCPS_TIMEWAIT:
			sd->so_error=ESHUTDOWN;
			clear_flag(SOCK_SEM);
			return(ESHUTDOWN);
	}
	
	/* State is now CLOSEWAIT, ESTABLISHED or FINWAIT1/2 (=I closed conn) */
	tcph=sd->tcp_handle;
	fs_flags=sd->file_status_flags;
	FD_SET(sd->handle, &blocking_calls);
	clear_flag(SOCK_SEM);
	
	cont=1;
	while(cont)
	{
		ierr=x_tcp_recv(tcph, buf, len, &dum, flags);
		if(ierr < 0)
		{
			sd->so_error=(int)ierr;
			FD_CLR(sd->handle, &blocking_calls);
			return(ierr);
		}
		if(ierr == 0)
		{
			if(fs_flags & O_NONBLOCK)
			{
				sd->so_error=EWOULDBLOCK;
				FD_CLR(sd->handle, &blocking_calls);
				return(EWOULDBLOCK);
			}
			else if(fs_flags & O_NDELAY)
			{
				sd->so_error=0;
				FD_CLR(sd->handle, &blocking_calls);
				return(0);
			}
			
			if(aborting)
			{
				FD_CLR(sd->handle, &blocking_calls);
				return(ENETDOWN);
			}
			iwait(POLL_WAIT);
		}
		else cont=0;
	}
	sd->so_error=E_OK;
	FD_CLR(sd->handle, &blocking_calls);
	return(ierr);
}

long cdecl recvfrom(int s, void *buf, long len, int flags, void *from, int *fromlen)
{/* Only Flag supported is MSG_PEEK */

	sock_dscr		*sd;
	sockaddr_in	ad;
	int					ierr, dport, c, cont;
	long				fs_flags;
	ulong				dip;
	uchar				*src, *dst;


	while(!set_flag(SOCK_SEM));

	sd=find_sock(s);
	
	if(sd==NULL)
	{
		clear_flag(SOCK_SEM);
		return(ENOTSOCK);
	}

	if(flags & (~MSG_PEEK))
	{
		sd->so_error=EOPNOTSUPP;
		clear_flag(SOCK_SEM);
		return(EOPNOTSUPP);
	}

	if(sd->type == SOCK_STREAM)
	{
		clear_flag(SOCK_SEM);
		return(recv(s, buf, len, flags));
	}
	
	/* SOCK_DGRAM */
	if(sd->flags & SF_SHUTRECV)
	{
		sd->so_error=E_OK;
		clear_flag(SOCK_SEM);
		return(0);	/* End-of-file condition */
	}
	dport=sd->udp_dport;
	dip=sd->udp_dip;	
	fs_flags=sd->file_status_flags;
	FD_SET(sd->handle, &blocking_calls);
	clear_flag(SOCK_SEM);
	c=(int)sizeof(sockaddr_in);

	cont=1;

	while(cont)
	{
		ierr=x_udp_recv(sd->port, buf, (int)len, flags, &ad, &c);

		/* This should not happen since a UDP-socket should always
			 have a open (receiving) UPD-port and upd_recv() only
			 returns insuccesfull if the port is not opened for
			 receiving. */
		if(ierr < 0) 
		{
			sd->so_error=ierr;
			FD_CLR(sd->handle, &blocking_calls);
			return(ierr);
		}
		
		if(ierr == 0)
		{
			if(fs_flags & O_NONBLOCK)
			{
				sd->so_error=EWOULDBLOCK;
				FD_CLR(sd->handle, &blocking_calls);
				return(EWOULDBLOCK);
			}
			else if(fs_flags & O_NDELAY)
			{
				sd->so_error=0;
				FD_CLR(sd->handle, &blocking_calls);
				return(0);
			}
			if(aborting)
			{
				FD_CLR(sd->handle, &blocking_calls);
				return(ENETDOWN);
			}
			iwait(POLL_WAIT);
		}
		else cont=0;
	}
	
	/* Copy sender-data ? */
	if(from != NULL)
	{
		c=(int)sizeof(sockaddr_in);
		if(c > *fromlen) c=*fromlen;
		*fromlen=c;
		src=(uchar*)&ad; dst=from;
		while(c--)
			*dst++=*src++;
	}
	
	if(dport == -1) /* Socket is not connected */
	{
		sd->so_error=ierr;
		FD_CLR(sd->handle, &blocking_calls);
		return(ierr);
	}

	/* Socket is connected */
	if((dport != ad.sin_port)||(dip != ad.sin_addr))
	{
		sd->so_error=0;
		FD_CLR(sd->handle, &blocking_calls);
		return(0); /* Discard message */
	}

	sd->so_error=E_OK;
	FD_CLR(sd->handle, &blocking_calls);
	return(ierr);
}

int cdecl status(int s, void *mtcb)
{ /* intern function */
	sock_dscr	*sd;
	int				ierr;

	while(!set_flag(SOCK_SEM));
	
	sd=find_sock(s);

	if(sd==NULL)
	{
		clear_flag(SOCK_SEM);
		return(ENOTSOCK);
	}

	if(sd->type == SOCK_DGRAM)
	{
		sd->so_error=EOPNOTSUPP;
		clear_flag(SOCK_SEM);
		return(EOPNOTSUPP);
	}
	
	if(sd->tcp_handle < 0)
	{
		if(sd->flags & SF_PARENT)
		{
			if(sd->flags & SF_SHUTDOWN)
			{
				sd->so_error=TCPS_CLOSED;
				clear_flag(SOCK_SEM);
				return(TCPS_CLOSED);
			}
			sd->so_error=TCPS_LISTEN;
			clear_flag(SOCK_SEM);
			return(TCPS_LISTEN);
		}
		sd->so_error=TCPS_CLOSED;
		clear_flag(SOCK_SEM);
		return(TCPS_CLOSED);
	}
	
	ierr=x_tcp_status(sd->tcp_handle, mtcb);
	if(ierr < 0)
	{/* tcb was deletet (probably due to timeout on connection) */
		sd->tcp_handle=-1;
		sd->so_error=TCPS_CLOSED;
		clear_flag(SOCK_SEM);
		return(TCPS_CLOSED);
	}
	sd->so_error=ierr;
	clear_flag(SOCK_SEM);
	return(ierr);
}

int cdecl shutdown(int s, int how)
{
	sock_dscr	*sd;
	int				state;

	#ifdef iodebug
	Dftext("[shutdown #");Dfnumber(s);Dftext("]\r\n");
	#endif

	while(!set_flag(SOCK_SEM));
	
	sd=find_sock(s);

	if(sd==NULL)
	{
		clear_flag(SOCK_SEM);
		return(ENOTSOCK);
	}

	switch(how)
	{
		case 0:
			sd->flags|=SF_SHUTRECV;
		break;
		case 1:
			sd->flags|=SF_SHUTSEND;
		break;
		case 2:
			sd->flags|=SF_SHUTDOWN;
		break;
		default:
			sd->so_error=EINVAL;
			clear_flag(SOCK_SEM);
			return(EINVAL);
	}

	if(sd->type == SOCK_DGRAM)
	{
		if((sd->port > 0) && (sd->flags & SF_SHUTRECV))
			x_udp_close(sd->port);
		sd->so_error=0;
		clear_flag(SOCK_SEM);
		return(0);
	}
	
	/* SOCK_STREAM */
	
	if(sd->flags & SF_PARENT)
	{
#ifdef iodebug
Dftext("[Shutting Parent]\r\n");
#endif
		x_tcp_kill_childs(sd->handle);
		sd->so_error=0;
		clear_flag(SOCK_SEM);
		return(0);
	}

	if((sd->tcp_handle < 0) || (how==0))
	{
#ifdef iodebug
Dftext("[Shutting unconnected]\r\n");
#endif
		sd->so_error=0;
		clear_flag(SOCK_SEM);
		return(0);
	}
	
	state=x_tcp_status(sd->tcp_handle, NULL);
	if(state < 0)
	{
#ifdef iodebug
Dftext("[Shut error status:");Dfnumber(state);Dftext("]\r\n");
#endif
		sd->tcp_handle=-1;
		sd->so_error=0;
		clear_flag(SOCK_SEM);
		return(0);
	}
	
	switch(state)
	{
		case TCPS_CLOSED:
			sd->so_error=0;
			clear_flag(SOCK_SEM);
			return(0);
			
		case TCPS_LISTEN:
		case TCPS_SYNSENT:
		case TCPS_SYNRCVD:
		case TCPS_ESTABLISHED:
		case TCPS_CLOSEWAIT:
			sd->so_error=state=x_tcp_close(sd->tcp_handle);
#ifdef iodebug
Dftext("[Shut send: ");Dfnumber(sd->so_error);Dftext("]\r\n");
#endif
			clear_flag(SOCK_SEM);
			return(state);
			
		default:
			sd->so_error=ESHUTDOWN;
			clear_flag(SOCK_SEM);
			return(ESHUTDOWN);
	}
}

int cdecl sclose(int s)
{
	sock_dscr	*sd;
	int				state;

	#ifdef iodebug
	Dftext("[sclose #"); Dfnumber(s);Dftext("]\r\n");
	#endif

	while(!set_flag(SOCK_SEM));
	
	sd=find_sock(s);

	if(sd==NULL)
	{
		clear_flag(SOCK_SEM);
		return(ENOTSOCK);
	}

	if(sd->type == SOCK_DGRAM)
	{
		if(sd->port > 0)
			x_udp_close(sd->port);
		delete_sock(sd);
		sd->so_error=0;
		clear_flag(SOCK_SEM);
		return(0);
	}
	
	/* SOCK_STREAM */
	
	if(sd->flags & SF_PARENT)
	{
		x_tcp_kill_childs(sd->handle);
		delete_sock(sd);
		sd->so_error=0;
		clear_flag(SOCK_SEM);
		return(0);
	}

	if(sd->tcp_handle < 0)
	{
		delete_sock(sd);
		sd->so_error=0;
		clear_flag(SOCK_SEM);
		return(0);
	}
	
	state=x_tcp_status(sd->tcp_handle, NULL);
#ifdef iodebug
Dftext("[Sclose state:");Dfnumber(state);Dftext("]\r\n");
#endif	
	switch(state)
	{
		case TCPS_CLOSED:
			delete_sock(sd);
			sd->so_error=0;
			clear_flag(SOCK_SEM);
			return(0);
			
		case TCPS_LISTEN:
		case TCPS_SYNSENT:
		case TCPS_SYNRCVD:
		case TCPS_ESTABLISHED:
		case TCPS_CLOSEWAIT:
		/* Linger ? */
			if((sd->so_options & SO_LINGER) && (sd->l_onoff))
			{/* Linger is on */
				if(sd->l_linger)	/* Wait for gracefull closing */
				{
					x_tcp_close(sd->tcp_handle);
					FD_SET(sd->handle, &blocking_calls);
					clear_flag(SOCK_SEM);
					do
					{
						iwait(POLL_WAIT);
						state=x_tcp_status(sd->tcp_handle, NULL);
					}while((state!=ERROR)&&(state!=EIHNDL)&&(state!=TCPS_CLOSED));
					state=sd->handle; /* Memorize because of delete_sock */
					delete_sock(sd);
					FD_CLR(state, &blocking_calls);
					return(0);
				}
				else												/* Abort connection */
					x_tcp_abort(sd->tcp_handle);
			}
			else	/* Linger is off, close and return */
				x_tcp_close(sd->tcp_handle);
		/* Fall into default here */
		default:
			delete_sock(sd);
			clear_flag(SOCK_SEM);
			return(0);
	}
}

int cdecl getsockname(int s, void *addr, int *addrlen)
{
	sock_dscr	*sd;
	sockaddr_in	sa;

	while(!set_flag(SOCK_SEM));
	
	sd=find_sock(s);

	if(sd==NULL)
	{
		clear_flag(SOCK_SEM);
		return(ENOTSOCK);
	}

	if(sd->flags&SF_SHUTDOWN)
	{
		sd->so_error=EINVAL;
		clear_flag(SOCK_SEM);
		return(EINVAL);
	}

	sa.sin_family=AF_INET;
	sa.sin_port=sd->port;
	sa.sin_addr=defaults.my_ip;
	*(long*)(&(sa.sin_zero[0]))=0;
	*(long*)(&(sa.sin_zero[4]))=0;
	if(*addrlen >= sizeof(sockaddr_in))
	{
		*addrlen=(int)sizeof(sockaddr_in);
		*(sockaddr_in*)addr=sa;
	}
	else
		strncpy(addr, (char*)&sa, *addrlen);
	sd->so_error=E_OK;
	clear_flag(SOCK_SEM);
	return(E_OK);
}

int cdecl getpeername(int s, void *addr, int *addrlen)
{
	sock_dscr	*sd;
	sockaddr_in	sa;
	tcb mtcb;
	
	while(!set_flag(SOCK_SEM));
	
	sd=find_sock(s);

	if(sd==NULL)
	{
		clear_flag(SOCK_SEM);
		return(ENOTSOCK);
	}

	if(sd->flags&SF_SHUTDOWN)
	{
		sd->so_error=EINVAL;
		clear_flag(SOCK_SEM);
		return(EINVAL);
	}

	sa.sin_family=AF_INET;

	if(sd->type == SOCK_DGRAM)
	{
		if((sd->udp_dport <= 0) || (sd->udp_dip <=0))
		{
			sd->so_error=ENOTCONN;
			clear_flag(SOCK_SEM);
			return(ENOTCONN);
		}
		sa.sin_port=sd->udp_dport;
		sa.sin_addr=sd->udp_dip;
	}
	else
	{/* SOCK_STREAM */
		if(sd->tcp_handle < 0)
		{
			sd->so_error=ENOTCONN;
			clear_flag(SOCK_SEM);
			return(ENOTCONN);
		}
		
		switch(x_tcp_status(sd->tcp_handle, &mtcb))
		{
			case TCPS_SYNSENT:
			case TCPS_SYNRCVD:
				sd->so_error=EINPROGRESS;
				clear_flag(SOCK_SEM);
				return(EINPROGRESS);		

			case TCPS_ESTABLISHED:
			case TCPS_CLOSEWAIT:
				sa.sin_port=mtcb.dst_port;
				sa.sin_addr=mtcb.dst_ip;
			break;
			
			default:
				sd->so_error=ENOTCONN;
				clear_flag(SOCK_SEM);
				return(ENOTCONN);		
		}
	}

	*(long*)(&(sa.sin_zero[0]))=0;
	*(long*)(&(sa.sin_zero[4]))=0;
	if(*addrlen >= sizeof(sockaddr_in))
	{
		*addrlen=(int)sizeof(sockaddr_in);
		*(sockaddr_in*)addr=sa;
	}
	else
		strncpy(addr, (char*)&sa, *addrlen);
	sd->so_error=E_OK;
	clear_flag(SOCK_SEM);
	return(E_OK);
}

void sockets_abort(void)
{
	sock_dscr	*sd, *sb;
	int				cont,a;
	/* Wait for pending socket-calls to complete */
	while(!set_flag(SOCK_SEM));
	/* Wait for blocking calls to complete */
	aborting=1;
	do
	{
		cont=0;
		for(a=0; a < FD_SETSIZE; ++a)
			if(FD_ISSET(a, &blocking_calls))
				cont=1;
	}while(cont);
	
	sd=first_sock;
	/* free the sockets */
	sd=first_sock;
	while(sd)
	{
		sb=sd->next;
		ifree(sd);
		sd=sb;
	}
	first_sock=NULL;
	
	/* Clear other protocol buffers */
	x_tcp_all_abort();
	x_udp_all_abort();
	if(!(defaults.using_mac_os))
	{
		ip_abort();
		if(defaults.using_ppp)
			ppp_abort();
		else
			slip_abort();
	}
	port_number=-1;
	sock_handle_init=0;
	aborting=0;
	clear_flag(SOCK_SEM);
}
