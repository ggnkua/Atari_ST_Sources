/*#define debug*/
/*#define DEB*/
#define iodebug

#include <stdio.h>
#include <stdlib.h>
#include <atarierr.h>
#include <sockerr.h>
#include <time.h>

#include "network.h"
#include "ip.h"
#include "tcp.h"
#include "ppp.h"
#include "slip.h"

#ifdef MAX_BLOCKS
#undef MAX_BLOCKS
#define MAX_BLOCKS 2
#endif

/* Blocks added to receiving buffer */
#define ADD_RBLOCK 4096
/* Maximum block kept when buffer is read out by application */
/* Larger blocks will be freed */
#define KEEP_RBLOCK 16384

void timer_malloc(void);

extern default_values defaults;

/* Queue-buffers of low-level protocols. Used for checking
	 if there is space to send */
extern ppp_buf *ppp_out_buf;
extern slip_buf *out_buf;

tcb	*first_tcb=NULL;
int	tcb_handle=1;

uint eac(ulong sum)
{/* Do end-arround carry */
	uint csum;
	
	while((csum=(uint)((ulong)sum>>16)) != 0)
		sum=csum+(sum & 0xffffl);
	return((uint)(sum & 0xffffl));
}

uint calc_tcp_crc(void *buf, uint bytes)
{
/*
 * Generic checksum computation routine.
 * Returns the one's complement of the 16 bit one's complement sum over
 * the `bytes'/2 words starting at `buf'.
 * On odd bytes, a zero byte is padded
 */
	register uint		*ubuf, words;
	register ulong	csum=0;
	
	words=bytes/2;
	
	ubuf=(uint*)buf;
	
	while(words--)
		csum+=*ubuf++;
	
	if(bytes & 1) /* Odd: Calculate the last byte */
		csum+=*ubuf & 0xff00;
	
	return(~eac(csum) & 0xffff);
}

void init_tpch(tcp_crc_header *tp, tcb *mtcb)
{
	tp->src_ip=defaults.my_ip;
	tp->dst_ip=mtcb->dst_ip;
	tp->zero=0;
	tp->protocol=6;	/* protocol=TCP */
	tp->tcp_len=(int)sizeof(tcp_header);
	
	tp->tcph.src_port=mtcb->src_port;
	tp->tcph.dst_port=mtcb->dst_port;
	tp->tcph.seq_nr=mtcb->snd_next;
	tp->tcph.ack_nr=mtcb->rcv_next;
	tp->tcph.data_offset=(int)sizeof(tcp_header)/4;
	tp->tcph.reserved=0;
	
	tp->tcph.window=mtcb->rcv_wnd;
	tp->tcph.crc=0;
	tp->tcph.urg_pnt=0;
}

int tcp_send_syn(tcb *mtcb)
{
	tcp_crc_header tp;
	
	init_tpch(&tp, mtcb);
	tp.tcph.flags=SYN;
	tp.tcph.crc=calc_tcp_crc(&tp, (int)sizeof(tcp_crc_header));
	return(ip_send(defaults.my_ip, mtcb->dst_ip, 6, mtcb->TOS, mtcb->TTL, (uchar*)&(tp.tcph), (uint)sizeof(tcp_header), (int)clock(), 0, NULL, 0));
}

int tcp_send_reset(tcb *mtcb)
{
	tcp_crc_header tp;
	
	init_tpch(&tp, mtcb);
	tp.tcph.flags=RST|ACK;
	tp.tcph.crc=calc_tcp_crc(&tp, (int)sizeof(tcp_crc_header));
	return(ip_send(defaults.my_ip, mtcb->dst_ip, 6, mtcb->TOS, mtcb->TTL, (uchar*)&(tp.tcph), (uint)sizeof(tcp_header), (int)clock(), 0, NULL, 0));
}

void itcp_send_foreign_reset(int src_port, int dst_port, ulong dst_ip, ulong ack)
{
	tcp_crc_header tp;
	
	tp.src_ip=defaults.my_ip;
	tp.dst_ip=dst_ip;
	tp.zero=0;
	tp.protocol=6;	/* protocol=TCP */
	tp.tcp_len=(int)sizeof(tcp_header);
	
	tp.tcph.src_port=src_port;
	tp.tcph.dst_port=dst_port;
	tp.tcph.seq_nr=0;
	tp.tcph.ack_nr=ack;
	tp.tcph.data_offset=(int)sizeof(tcp_header)/4;
	tp.tcph.reserved=0;
	
	tp.tcph.window=0;
	tp.tcph.crc=0;
	tp.tcph.urg_pnt=0;
	tp.tcph.flags=RST;
	tp.tcph.crc=calc_tcp_crc(&tp, (int)sizeof(tcp_crc_header));
	ip_send(defaults.my_ip, dst_ip, 6, defaults.TOS, defaults.TTL, (uchar*)&(tp.tcph), (uint)sizeof(tcp_header), (int)clock(), 0, NULL, 0);
}

int tcp_send_fin(tcb *mtcb, ulong fsn)
{/* fsn=FIN's sequenze number */
	tcp_crc_header	tp;
	int							ierr;

	init_tpch(&tp, mtcb);
	tp.tcph.seq_nr=fsn;
	tp.tcph.flags=FIN|ACK;
	tp.tcph.crc=calc_tcp_crc(&tp, (int)sizeof(tcp_crc_header));
	ierr=ip_send(defaults.my_ip, mtcb->dst_ip, 6, mtcb->TOS, mtcb->TTL, (uchar*)&(tp.tcph), (uint)sizeof(tcp_header), (int)clock(), 0, NULL, 0);
	if(ierr < 0) return(ierr);
	if(mtcb->snd_next <= fsn)
		mtcb->snd_next=fsn+1;
	return(E_OK);
}

int itcp_send_head(tcb *mtcb, ulong seq, ulong ack, int ctl)
{
	tcp_crc_header tp;
	
	init_tpch(&tp, mtcb);
	tp.tcph.seq_nr=seq;
	tp.tcph.ack_nr=ack;
	tp.tcph.flags=ctl;
	tp.tcph.crc=calc_tcp_crc(&tp, (int)sizeof(tcp_crc_header));
	return(ip_send(defaults.my_ip, mtcb->dst_ip, 6, mtcb->TOS, mtcb->TTL, (uchar*)&(tp.tcph), (uint)sizeof(tcp_header), (int)clock(), 0, NULL, 0));
}

int	get_tcb_handle(void)
{
	return(tcb_handle++);
}

ulong	get_isn(void)
{/* Initial Sequence Number */
	return((ulong)clock());
}

tcb	*new_tcb(void)
{/* Cats a new TCB to the tcb list and returns the pointer. On
		insufficient memory, NULL is returned
		Note: The TCB isn't initialized at all!
  */
  
  tcb	**act=&first_tcb;
  
	/* Find the last pointer */
  while(*act != NULL)
  	act=&((*act)->next);
  
  *act=(tcb*)tmalloc(sizeof(tcb));
  (*act)->next=NULL;
	return(*act);	
}

void	delete_tcb(tcb *mtcb)
{/* Delete a TCB and it's send-buffers from the tcb-list */

  tcb	**prev=&first_tcb, *act=first_tcb;
  tcp_send_buffer	*tsb1, *tsb2;
  
	/* Find the matching pointer */
  while(act != NULL)
  {
  	if(act->handle==mtcb->handle)
  	{/* Found, now delete it */
	  	*prev=act->next;
  		tsb1=act->first;
  		while(tsb1)
  		{
  			tsb2=tsb1->next;
  			if((tsb1->buf) && (tsb1->len >0))
	  			ifree(tsb1->buf);
  			ifree(tsb1);
  			tsb1=tsb2;
  		}
  		if(act->recv_buf)
	  		ifree(act->recv_buf);
  		ifree(act);
  		return;
  	}
  	prev=&(act->next);
  	act=act->next;
  }
}

tcb *find_tcb_by_handle(int handle)
{/* Returns tcb-pointer on success, else NULL */
	tcb	*mtcb=first_tcb;
	
	while(mtcb != NULL)
	{
		if(mtcb->handle==handle)
			 break;

		mtcb=mtcb->next;
	}
	return(mtcb);
}

tcb *find_tcb_by_sock(int src_port, ulong src_ip, int dst_port, ulong dst_ip)
{/* Returns tcb-pointer on success, else NULL */
	tcb	*mtcb=first_tcb;
	
	while(mtcb != NULL)
	{
		if((mtcb->src_port==src_port) && (mtcb->src_ip==src_ip) &&
			 (mtcb->dst_port==dst_port) && (mtcb->dst_ip==dst_ip))
			break;

		mtcb=mtcb->next;
	}
	return(mtcb);
}

tcb *find_unassigned_tcb(int src_port, ulong src_ip)
{
	tcb	*mtcb=first_tcb;

	while(mtcb != NULL)
	{
		if((mtcb->src_port==src_port) && (mtcb->src_ip==src_ip) &&
			 (mtcb->dst_port==-1)) /* Not assigned listen-socket */
				break;

		mtcb=mtcb->next;
	}
	return(mtcb);
}

int	find_assigned_tcb(int parent, sockaddr_in *addr)
{/* Return tcp-handle of first assigned child or ERROR if none */
 /* parent=socket-handle given on passive tcp_open call */
 /* Assign the found tcb */
	tcb	*mtcb;
	
	while(!set_flag(TCP_TCB_SEM));
	
	mtcb=first_tcb;

	while(mtcb != NULL)
	{
		if((mtcb->parent_sock==parent) && 
			((mtcb->state==TCPS_ESTABLISHED)||
			 (mtcb->state==TCPS_CLOSEWAIT)))
		{
			mtcb->parent_sock=0;
			addr->sin_port=mtcb->dst_port;
			addr->sin_addr=mtcb->dst_ip;
			clear_flag(TCP_TCB_SEM);
			return(mtcb->handle);
		}

		mtcb=mtcb->next;
	}
	clear_flag(TCP_TCB_SEM);
	return(ERROR);
}

int	check_assigned_tcb(int parent)
{/* Return tcp-handle of first assigned child or ERROR if none */
 /* parent=socket-handle given on passive tcp_open call */
	tcb	*mtcb;
	
	while(!set_flag(TCP_TCB_SEM));
	
	mtcb=first_tcb;

	while(mtcb != NULL)
	{
		if((mtcb->parent_sock==parent) && 
			((mtcb->state==TCPS_ESTABLISHED)||
			 (mtcb->state==TCPS_CLOSEWAIT)))
		{
			clear_flag(TCP_TCB_SEM);
			return(mtcb->handle);
		}

		mtcb=mtcb->next;
	}
	clear_flag(TCP_TCB_SEM);
	return(ERROR);
}

void tcp_kill_childs(int parent)
{/* Deletes all unassigned tcb-childs of <parent>*/
  tcb	**prev, *act;

	while(!set_flag(TCP_TCB_SEM));

  prev=&first_tcb;
  act=first_tcb;

	while(act != NULL)
	{
		if((act->parent_sock==parent) && (act->dst_port==-1))
		{/* Unasigned->delete */
	  	*prev=act->next;
  		ifree(act);
  		act=*prev;
  	}
  	else
  	{
	  	prev=&(act->next);
  		act=act->next;
  	}
	}
	clear_flag(TCP_TCB_SEM);
}

int	tcp_open(int src_port, int dst_port, ulong dst_ip, int act_pas, int *tcp_sig, int user_timeout, byte precedence, int security)
{/* 
	act_pas: 0=Active,>0=Passive (handle of the parent-socket)
	tcp_sig: Integer to write con-reset signal at
	user_timeout: in seconds. Connection will be closed if tcp can't send
								a buffer within <user_timeout> seconds.
								For none-timeout set to -1
	precedence=precedence used in IP-Options
	sec_comp=Security/Compartment used in IP-Options
 */
	
	tcb	*mtcb;
	int	ierr, a;
		
	
	while(!set_flag(TCP_TCB_SEM));
		
	if(act_pas!=0) /* New Passive socket */
	{
		mtcb=NULL;
		dst_port=-1;
	}
	else
		mtcb=find_tcb_by_sock(src_port, defaults.my_ip, dst_port, dst_ip);
	if(mtcb!=NULL)
	{/* TCB allready exists, is it closed? */
		if(mtcb->state == TCPS_SYNSENT)
		{
			clear_flag(TCP_TCB_SEM);
			return(EINPROGRESS);
		}
		if(mtcb->state != TCPS_CLOSED)
		{
			clear_flag(TCP_TCB_SEM);
			return(EISCONN);
		}
	}
	else
	{
		mtcb=new_tcb();
		if(mtcb==NULL)
		{
			clear_flag(TCP_TCB_SEM);
			return(ENSMEM);
		}
		/* Init port/ip */
		mtcb->src_port=src_port;
		mtcb->src_ip=defaults.my_ip;
		mtcb->dst_port=dst_port;
		mtcb->dst_ip=dst_ip;
		
		mtcb->handle=get_tcb_handle();
	}

	/* Init tcb-data */
	mtcb->tcp_sig=tcp_sig;
	mtcb->parent_sock=act_pas;
	
	mtcb->precedence=precedence;
	mtcb->security=security;
	mtcb->TOS=defaults.TOS;
	mtcb->TTL=defaults.TTL;
	
	mtcb->close_timeout=((long)mtcb->TTL)*CLK_TCK;
	mtcb->close_timer=-1;
	mtcb->user_timeout=user_timeout*CLK_TCK;
	mtcb->retrans_timeout=clock(); /* Meassure time until answer arrives */

	mtcb->snd_buf_next_isn=mtcb->snd_una=mtcb->snd_next=mtcb->snd_isn=
		get_isn();
	mtcb->snd_wnd=defaults.snd_wnd;
	mtcb->first=NULL;
	if(defaults.disable_send_ahead)
		mtcb->trans_timer[0]=-1;
	else
		for(a=0; a < MAX_BLOCKS; ++a) mtcb->trans_timer[a]=-1;
	
	mtcb->rcv_wnd=defaults.rcv_wnd;
	mtcb->rcv_next=0;
	mtcb->recv_up=0;
	mtcb->recv_flags=0;
	mtcb->recv_isn=0;
	mtcb->rbuf_isn=0;
	mtcb->recv_buf_len=0;
	mtcb->recv_buf_siz=0;
	mtcb->recv_buf=NULL;
	
	if(act_pas==0)
	{/* Active socket->connect */
		mtcb->snd_buf_next_isn++;
		ierr=tcp_send_syn(mtcb);
		mtcb->snd_next++;
		if(ierr < 0)
		{
			clear_flag(TCP_TCB_SEM);
			delete_tcb(mtcb);
			return(ierr);
		}
		mtcb->state=TCPS_SYNSENT;
		mtcb->connection_timer=defaults.connection_timeout*CLK_TCK;
	}
	else
		mtcb->state=TCPS_LISTEN;

	clear_flag(TCP_TCB_SEM);
	return(mtcb->handle);
}

tcp_send_buffer	*new_send_buf(tcb	*mtcb, int len)
{/* Cat a new send_buffer to the queue in mtcb 
		and reserve <len> bytes in the buffer (if len > 0)
 */
	
	tcp_send_buffer	**tcpsb=&(mtcb->first), *mtcpsb;
	
	while(*tcpsb != NULL)
		tcpsb=&((*tcpsb)->next);
	
	mtcpsb=(tcp_send_buffer*)tmalloc(sizeof(tcp_send_buffer));
	if(mtcpsb == NULL)
		return(NULL);

	mtcpsb->next=NULL;
	if(len > 0)
	{
		mtcpsb->buf=(uchar*)tmalloc(len);
		if(mtcpsb->buf==NULL)
		{
			ifree(mtcpsb);
			return(NULL);
		}
	}
	else
		mtcpsb->buf=NULL;
	
	*tcpsb=mtcpsb;
	return(mtcpsb);
	
}

int queue_fin(tcb *mtcb)
{
	tcp_send_buffer *tb;

	while(!set_flag(TCP_SBUF_SEM));

	tb=new_send_buf(mtcb, 0);
	
	if(tb==NULL)
	{
		clear_flag(TCP_SBUF_SEM);
		return(ENSMEM);
	}
	
	tb->flags=0;
	tb->transmission_timer=0;
	tb->user_timer=mtcb->user_timeout;
	tb->bsn=mtcb->snd_buf_next_isn;
	++mtcb->snd_buf_next_isn;
	tb->len=-1; /* Indicates FIN */
	clear_flag(TCP_SBUF_SEM);
	return(E_OK);
}

long tcp_get_sendbufsize(int handle)
{
	tcb							*mtcb;
	tcp_send_buffer	*tcpsb;
	long						len=0;
	
	while(!set_flag(TCP_TCB_SEM));
	
	mtcb=find_tcb_by_handle(handle);
	if(mtcb == NULL)
	{
		clear_flag(TCP_TCB_SEM);
		return(0);
	}

	while(!set_flag(TCP_SBUF_SEM));

	tcpsb=mtcb->first;
	while(tcpsb)
	{
		if(tcpsb->len > 0) /* (-1 means FIN) */
		{
			if(tcpsb->bsn < mtcb->snd_una)
			{
				if(tcpsb->bsn+tcpsb->len > mtcb->snd_una)
					len+=tcpsb->len-(mtcb->snd_una-tcpsb->bsn);
				/* else buffer already sent */
			}
			else
				len+=tcpsb->len;
		}
		tcpsb=tcpsb->next;
	}
	clear_flag(TCP_SBUF_SEM);
	clear_flag(TCP_TCB_SEM);
	return(len);
}

int	tcp_send(int handle, uchar *buf, int len, int flags, int user_timeout)
{/*
	flags: #0=PUSH, #1=URGENT
	user_timeout: timeout in seconds(overrides timeout in tcp_open)
	  					 	if timeout=-1, user_timeout from open is used
 */
 
	tcb							*mtcb;
	tcp_send_buffer	*tcpsb;
	uchar						*dst;
	
	if(len==0) return(0);		/* 0 Bytes sent */

#ifdef DEB
Cconws("Out: TCB\r");
#endif
	while(!set_flag(TCP_TCB_SEM));
	
	mtcb=find_tcb_by_handle(handle);
	if(mtcb == NULL)
	{
		clear_flag(TCP_TCB_SEM);
		return(EIHNDL);
	}

	switch(mtcb->state)
	{
		case TCPS_LISTEN:
		case TCPS_CLOSED:
			clear_flag(TCP_TCB_SEM);
			return(ENOTCONN);
		
		case TCPS_SYNSENT:
		case TCPS_SYNRCVD:
		case TCPS_ESTABLISHED:
		case TCPS_CLOSEWAIT:
		/* Chain buf to send-queue, if no FIN is in */
			while(!set_flag(TCP_SBUF_SEM));

			tcpsb=mtcb->first;
			while(tcpsb)
			{
				if(tcpsb->len < 0) /* FIN found->user already closed connection */
				{
					clear_flag(TCP_SBUF_SEM);
					clear_flag(TCP_TCB_SEM);
					return(ESHUTDOWN);
				}
				tcpsb=tcpsb->next;
			}

			tcpsb=new_send_buf(mtcb, len);
			if(tcpsb==NULL)
			{
				clear_flag(TCP_SBUF_SEM);
				clear_flag(TCP_TCB_SEM);
				return(ENSMEM);
			}
			tcpsb->flags=flags;
			tcpsb->transmission_timer=0;	/* Send immediately */
			if(user_timeout < 0)
				tcpsb->user_timer=mtcb->user_timeout;
			else
				tcpsb->user_timer=user_timeout*CLK_TCK;
			tcpsb->bsn=mtcb->snd_buf_next_isn;
			mtcb->snd_buf_next_isn+=len;
			tcpsb->len=len;
			dst=tcpsb->buf;
			while(len--)
				*dst++=*buf++;
			clear_flag(TCP_SBUF_SEM);
			clear_flag(TCP_TCB_SEM);
			return(tcpsb->len);
		
		default:
		/* Connection closing */
			clear_flag(TCP_TCB_SEM);
			return(ESHUTDOWN);
	}
}

int	tcp_status(int handle, tcb *dtcb)
{/* Copies tcb to dtcb and returns status on success.
		if dtcb is set to NULL, only status is returned
    Else EIHNDL will be returned */
    
	tcb	*mtcb;
	
	while(!set_flag(TCP_TCB_SEM));
	
	mtcb=find_tcb_by_handle(handle);
	if(mtcb==NULL)
	{
		clear_flag(TCP_TCB_SEM);
		return(EIHNDL);
	}
	
	if(dtcb)
		*dtcb=*mtcb;
	clear_flag(TCP_TCB_SEM);
	return(mtcb->state);
}

int tcp_abort(int handle)
{
	int ierr;
	tcb	*mtcb;

	while(!set_flag(TCP_TCB_SEM));

	mtcb=find_tcb_by_handle(handle);
	if(mtcb==NULL)
	{
		clear_flag(TCP_TCB_SEM);
		return(EIHNDL);
	}
	
	switch(mtcb->state)
	{
		case TCPS_CLOSED:
			clear_flag(TCP_TCB_SEM);
			return(ENOTCONN);
		
		case TCPS_SYNRCVD:
		case TCPS_ESTABLISHED:
		case TCPS_FINWAIT1:
		case TCPS_FINWAIT2:
		case TCPS_CLOSEWAIT:
			ierr=tcp_send_reset(mtcb);
			if(ierr < 0)
			{
				clear_flag(TCP_TCB_SEM);
				return(ierr);
			}
			/* no break! */
		default:
			delete_tcb(mtcb);
			clear_flag(TCP_TCB_SEM);
			return(E_OK);
	}
}

long	tcp_recv(int handle, uchar *buf, ulong len, int *flags, int peek)
{/* The received flags (#0=PUSH, #1=URGENT) will be copied
		to <flags>.
		if <peek> is != 0, the bytes will stay in the buffer, thus beeing
		recopied on the next tcp_recv-call.
		The number of bytes copied to <buf> will be returned
 */
 	ulong	copy_len, cpl;
 	uchar	*src, *dst;
	tcb	*mtcb;
	
	while(!set_flag(TCP_TCB_SEM));
	
	mtcb=find_tcb_by_handle(handle);
	if(mtcb==NULL)
	{
		clear_flag(TCP_TCB_SEM);
		return(EIHNDL);
	}
	
	if(mtcb->state==TCPS_CLOSED)
	{
		clear_flag(TCP_TCB_SEM);
		return(ENOTCONN);
	}

	while(!set_flag(TCP_RBUF_SEM));
	
	if((mtcb->recv_buf==NULL)||(mtcb->recv_buf_len==0))
	{/* Nothing in receive buffer */
		clear_flag(TCP_RBUF_SEM);
		clear_flag(TCP_TCB_SEM);
		switch(mtcb->state)
		{
			case	TCPS_CLOSED:
			case	TCPS_LISTEN:
			case	TCPS_SYNSENT:
			case	TCPS_SYNRCVD:
				return(ENOTCONN);
			case 	TCPS_CLOSEWAIT:
				return(ECONNRESET);
			case 	TCPS_LASTACK:
			case 	TCPS_CLOSING:
			case 	TCPS_TIMEWAIT:
				return(ESHUTDOWN);
			default:		/* FINWAIT1/2 and ESTABLISHED */
				return(0);
		}
	}
	
	copy_len=len;
	if(mtcb->recv_buf_len < len) copy_len=mtcb->recv_buf_len;
	cpl=copy_len;
	src=mtcb->recv_buf;
	while(cpl--)
		*buf++=*src++;

#ifdef iodebug
if(db_handle > -1)
{
	Dftext("[TCP_RECV copied ");
	Dfnumber(copy_len);
	Dftext(" Bytes to agent-buffer.\r\nBytes left: ");
	Dfnumber(mtcb->recv_buf_len-copy_len);
	Dftext("]\r\n");
}
#endif

	*flags=mtcb->recv_flags;

	if(peek == 0)
	{/* Delete bytes from buffer */
		mtcb->recv_flags=0;
		mtcb->recv_buf_len-=copy_len;
		mtcb->rbuf_isn+=copy_len;
		if(mtcb->recv_buf_len==0) /* Buffer was completely copied */
		{
			if(mtcb->recv_buf_siz > KEEP_RBLOCK)
			{
				ifree(mtcb->recv_buf);
				mtcb->recv_buf=NULL;
				mtcb->recv_buf_siz=0;
			}
		}
		else
		{/* Replace read data by unread data in receiving buffer */
			cpl=mtcb->recv_buf_len;
			src=mtcb->recv_buf+copy_len;
			dst=mtcb->recv_buf;
			while(cpl--)
				*dst++=*src++;
		}
	}
	
	clear_flag(TCP_RBUF_SEM);
	clear_flag(TCP_TCB_SEM);
	return(copy_len);
}

int tcp_close(int handle)
{
	int	ierr;
	tcb	*mtcb;
	
	while(!set_flag(TCP_TCB_SEM));
	
	mtcb=find_tcb_by_handle(handle);
	if(mtcb==NULL)
	{
		clear_flag(TCP_TCB_SEM);
		return(EIHNDL);
	}
	
	switch(mtcb->state)
	{
		case TCPS_CLOSED:
			clear_flag(TCP_TCB_SEM);
			return(ENOTCONN);
			
		case TCPS_LISTEN:
		case TCPS_SYNSENT:
			delete_tcb(mtcb);
			clear_flag(TCP_TCB_SEM);
			return(E_OK);
			
		case TCPS_SYNRCVD:
			if((mtcb->first == NULL) && (mtcb->snd_next == mtcb->snd_una))
			{	/* No Transmission yet */
				ierr=tcp_send_fin(mtcb, mtcb->snd_next);
				if(ierr < 0)
				{
					clear_flag(TCP_TCB_SEM);
					return(ierr);
				}
				++mtcb->snd_buf_next_isn;
				mtcb->state=TCPS_FINWAIT1;
				clear_flag(TCP_TCB_SEM);
				return(E_OK);
			}
			/* else */
			clear_flag(TCP_TCB_SEM);
			return(queue_fin(mtcb));
			
		case TCPS_ESTABLISHED:
			ierr=queue_fin(mtcb);
			if(ierr < 0)
			{
				clear_flag(TCP_TCB_SEM);
				return(ierr);
			}
/*			mtcb->state=TCPS_FINWAIT1;*/
			clear_flag(TCP_TCB_SEM);
			return(E_OK);
			
		case TCPS_CLOSEWAIT:
			clear_flag(TCP_TCB_SEM);
			return(queue_fin(mtcb));
			
		default:
			clear_flag(TCP_TCB_SEM);
			return(EALREADY);
	}
}

int check_precedence(tcb *mtcb, ip_header *iph)
{/* Compare the precedence in iph with the on in mtcb */
 /* If ok, return E_OK, otherwise ERROR */
	byte	precedence;
	
	precedence=(iph->TOS)>>5;
	if(precedence != mtcb->precedence) 
		return(ERROR);

	return(E_OK);
}

int check_security(tcb *mtcb, ip_header *iph)
{/* Compare the security in iph with the on in mtcb */
 /* If ok or not stated, return E_OK, otherwise ERROR */
 
	uchar	*opts=(uchar*)(iph->options);
	uint		opt_bytes=((iph->version_IHL & 15)-5)*4; /* 20 octets standard-header followed by options */
	uint		ix=0;
	int		sec=-1;
	while(ix < opt_bytes)
	{
		switch(opts[ix] & 127)	/* Ignore "copied" bit */
		{
			case 0:	/* Options end */
				ix=opt_bytes;	/* Force quit */
			break;
			case 1: /* No Operation */
				++ix;
			break;
			case 2: /* Security */
				sec=get_int(&(opts[ix+2]));
				ix=opt_bytes;	/* Force quit */
			break;
			default:
				ix+=opts[ix+1];
			break;
		}
	}

	if(sec==-1) return(E_OK);	/* No security in iph */
	if(sec == mtcb->security) return(E_OK);
	
	return(ERROR);
}

void calc_conn_time(tcb *mtcb)
{/* Calculate Time needed for Connection, thus setting Retrans-Timeout */
	long	rtt, sent, now=clock(), min, max;
	
	min=1*CLK_TCK;
	max=60*CLK_TCK;
	
	sent=mtcb->retrans_timeout; /* The time was stored here on connection request */
	rtt=now-sent;
	rtt*=2;
	if(rtt < min) rtt=min;
	if(rtt > max) rtt=max;
	mtcb->retrans_timeout=rtt;
}

void clear_user_timers(tcb *mtcb)
{/* Clears all user-timers in transmission queue.
		Is called when the close-timer starts running
	*/
tcp_send_buffer	*tcbb=mtcb->first;

	while(tcbb)
	{
		tcbb->user_timer=-1;
		tcbb=tcbb->next;
	}
}

int	tcp_in(uchar *buf, uint len, ip_header *iph)
{
	tcp_header						ltcph;
	register tcp_header		*tcph=&ltcph;
	register uchar				*data, *dst;
	register tcb					*mtcb;
	register int					data_len, ierr, data_size;
	register uint				clen, head_len;

	/* Copy tcp-header to local header to avoid typecast in bytestream */
	data_len=(int)sizeof(tcp_header);
	data=buf;
	dst=(uchar*)tcph;
	while(data_len--)
		*dst++=*data++;

#ifdef iodebug
if(db_handle > -1)
{
tcph=(tcp_header*)buf;
Dftext("[TCP-IN:] SEQ=");
Dfnumber(tcph->seq_nr);
Dftext(", ACK=");
Dfnumber(tcph->ack_nr);
Dftext(", FLAGS=");
if(tcph->flags & URG) Dftext("URG,");
if(tcph->flags & ACK) Dftext("ACK,");
if(tcph->flags & PSH) Dftext("PSH,");
if(tcph->flags & RST) Dftext("RST,");
if(tcph->flags & SYN) Dftext("SYN,");
if(tcph->flags & FIN) Dftext("FIN,");
Dftext(" SRC-Port=");
Dfnumber(tcph->src_port);
Dftext(", DST-port=");
Dfnumber(tcph->dst_port);
}
#endif
		
	/* Faster Flag-access */
	#define FURG ((tcph->flags & URG) > 0)
	#define FACK ((tcph->flags & ACK) > 0)
	#define FPSH ((tcph->flags & PSH) > 0)
	#define FRST ((tcph->flags & RST) > 0)
	#define FSYN ((tcph->flags & SYN) > 0)
	#define FFIN ((tcph->flags & FIN) > 0)

	/* Split buf into tcp_header and data */
	/* tcph=(tcp_header*)buf; */
	head_len=tcph->data_offset*4;
	data=buf+head_len;
	data_size=data_len=len-head_len;
#ifdef iodebug
if(db_handle > -1)
{
	Dftext(", Data-size=");
	Dfnumber(data_size);
	Dftext(".\r\n");
}
#endif
	/* data_size is backup-info for FIN-processing:
		 if FIN-packet includes data, ACK-seq-nr must
		 be calculated by send-seq-nr+data+size+1.
		 If all data in TCP-packet was already received,
		 data_len will be set to 0, so a backup of data_len
		 is needed.
	*/

	/* Get TCB */
	while(!set_flag(TCP_TCB_SEM)) timer_malloc();
	/* (Swap src/dst, since this is an incoming segment!) */
	mtcb=find_tcb_by_sock(tcph->dst_port, iph->dst_ip, tcph->src_port, iph->src_ip);

	/* Maybe we have a Listen-socket for this? */
	if(mtcb==NULL)
		mtcb=find_unassigned_tcb(tcph->dst_port, iph->dst_ip);

	/* No, nothing */
	if(mtcb==NULL)
	{
#ifdef iodebug
if(db_handle > -1)
{
	Dftext("[TCP found no matching connected or listening port. Send RST]\r\n");
}
#endif
		itcp_send_foreign_reset(tcph->dst_port, tcph->src_port, iph->src_ip, tcph->ack_nr);
		clear_flag(TCP_TCB_SEM);
		return(EBADRQ); /* Bad request, no TBC */
	}
	
	/* Process TCP-packet */
	switch(mtcb->state)
	{
		case TCPS_CLOSED:
#ifdef iodebug
if(db_handle > -1)	Dftext("[TCP received in CLOSED state]\r\n");
#endif
			if(FRST)
			{
				clear_flag(TCP_TCB_SEM);
				return(0);
			}
			if(FACK)
			{
				ierr=itcp_send_head(mtcb, tcph->ack_nr, 0, RST);
				clear_flag(TCP_TCB_SEM);
				return(ierr);
			}
			else
			{
				ierr=itcp_send_head(mtcb, 0, tcph->seq_nr+data_len, RST|ACK);
				clear_flag(TCP_TCB_SEM);
				return(ierr);
			}

		case TCPS_LISTEN:
#ifdef iodebug
if(db_handle > -1)	Dftext("[TCP received in LISTEN state]\r\n");
#endif
			mtcb->dst_port=tcph->src_port;
			mtcb->dst_ip=iph->src_ip;
			if(FRST)
			{
				mtcb->dst_port=-1;
				clear_flag(TCP_TCB_SEM);
				return(0);
			}
			if(FACK)
			{
				ierr=itcp_send_head(mtcb, tcph->ack_nr, 0, RST);
				mtcb->dst_port=-1;
				clear_flag(TCP_TCB_SEM);
				return(ierr);
			}
			if(FSYN)
			{/* Someone is trying to connect to us... */
			 /* Check Security */
#ifdef iodebug
if(db_handle > -1)
Dftext("[TCP: Incoming CON Request in Listen mode.]\r\n");
#endif
				if(check_security(mtcb, iph) == ERROR)
				{/* Wrong security in iph->send reset */
					ierr=itcp_send_head(mtcb, tcph->ack_nr, 0, RST);
					mtcb->dst_port=-1;
					clear_flag(TCP_TCB_SEM);
				}
				/* Check precedence */
				if(((iph->TOS)>>5) > mtcb->precedence)
				{/* Incoming precedence is higher than mine */
					if(defaults.allow_precedence_raise==0) /* Sorry...*/
					{
						ierr=itcp_send_head(mtcb, 0, tcph->ack_nr, RST);
						mtcb->dst_port=-1;
						clear_flag(TCP_TCB_SEM);
						return(ierr);
					}
					else
						mtcb->precedence=(iph->TOS)>>5;
				}
				/* Looks good so far, we accept it and send a SYN*/
#ifdef iodebug
if(db_handle > -1)
Dftext("[TCP: accepted]\r\n");
#endif
				mtcb->rcv_next=tcph->seq_nr+1;
				mtcb->recv_isn=tcph->seq_nr;
				mtcb->snd_buf_next_isn++;
				ierr=itcp_send_head(mtcb, mtcb->snd_next, mtcb->rcv_next, SYN|ACK);
				mtcb->snd_next++;
#ifdef iodebug
if(db_handle > -1)
{
Dftext("[TCP-CON status]");
Dftext("send next: ");
Dfnumber(mtcb->snd_next);
Dftext(" send_next_buf_isn: ");
Dfnumber(mtcb->snd_buf_next_isn);
Dftext("\r\n");
}
#endif
				if(ierr < 0)
				{
					clear_flag(TCP_TCB_SEM);
					mtcb->dst_port=-1;
					return(ierr);
				}
				mtcb->state=TCPS_SYNRCVD;
				mtcb->connection_timer=defaults.connection_timeout*CLK_TCK;
				mtcb->retrans_timeout=clock(); /* Meassure time until answer arrives */
				clear_flag(TCP_TCB_SEM);
				return(0);
			}
			/* Anything else in LISTEN-state is ignored */
			clear_flag(TCP_TCB_SEM);
			return(0);
			
		case TCPS_SYNSENT:
#ifdef iodebug
if(db_handle > -1)	Dftext("[TCP received in SYNSENT state]\r\n");
#endif
			if(FACK)
			{/* ACK on connection? */
				if((tcph->ack_nr <= mtcb->snd_isn) || (tcph->ack_nr > mtcb->snd_next))
				{/* No, out of range */
#ifdef iodebug
if(db_handle > -1)	Dftext("[ACK is out of range, send RES]\r\n");
#endif
					if(! FRST)
					{/* If no incoming reset, send reset, else drop segment */
						ierr=itcp_send_head(mtcb, tcph->ack_nr, 0, RST);
						clear_flag(TCP_TCB_SEM);
						return(ierr);
					}
					clear_flag(TCP_TCB_SEM);
					return(0);
 				}
			}
			/* Ok, ACK is (if set) in range */
			if(FRST)
			{/* Connection refused? */
				if(FACK)	/* Yes, signal, close and delete */
				{
					if(mtcb->tcp_sig)
						*(mtcb->tcp_sig)=1;
					delete_tcb(mtcb);
				}
				/* and drop segment and return */
				clear_flag(TCP_TCB_SEM);
				return(0);
			}
			/* Now check security */
			if(check_security(mtcb, iph) == ERROR)
			{/* Wrong security in iph->send reset */
#ifdef iodebug
if(db_handle > -1)	Dftext("[Security check failed]\r\n");
#endif
				if(FACK)
				{
					ierr=itcp_send_head(mtcb, tcph->ack_nr, 0, RST);
					clear_flag(TCP_TCB_SEM);
					return(ierr);
				}
				else
				{
					ierr=itcp_send_head(mtcb, 0, tcph->seq_nr+data_len, RST|ACK);
					clear_flag(TCP_TCB_SEM);
					return(ierr);
				}
			}
			/* Security is fine */
			if(FACK)
			{
				if(check_precedence(mtcb, iph) == ERROR)
				{
#ifdef iodebug
if(db_handle > -1)	Dftext("[Precedence check failed - IGNORE]\r\n");
#endif
/*
We ignore the failed precedence, because a bug in T-Online causes
the reply paket of strato-servers to carry a higher precedence.
					ierr=itcp_send_head(mtcb, tcph->ack_nr, 0, RST);
					clear_flag(TCP_TCB_SEM);
					return(ierr);
*/
				}
			}
			if(((iph->TOS)>>5) > mtcb->precedence)
			{/* Incoming precedence is higher than mine */
				if(defaults.allow_precedence_raise==0) /* Sorry...*/
				{
					ierr=itcp_send_head(mtcb, 0, tcph->seq_nr+data_len, RST|ACK);
					clear_flag(TCP_TCB_SEM);
					return(ierr);
				}
				else
					mtcb->precedence=(iph->TOS)>>5;
			}
			/* Now check SYN */
			if(FSYN)
			{
				mtcb->rcv_next=tcph->seq_nr+1;
				mtcb->recv_isn=tcph->seq_nr;
				if(FACK)
					mtcb->snd_una=tcph->ack_nr;					
				if(mtcb->snd_una > mtcb->snd_isn)
				{/* Now we have a connection */
					mtcb->state=TCPS_ESTABLISHED;
					calc_conn_time(mtcb);
					ierr=itcp_send_head(mtcb, mtcb->snd_next, mtcb->rcv_next, ACK);
					if(ierr < 0)
					{
						clear_flag(TCP_TCB_SEM);
						return(ierr);
					}
					if(data_len > 0)
						goto _data_process_;	/* Nicht sch”n aber selten */
					clear_flag(TCP_TCB_SEM);
					return(0);
				}
				/* This is a connection request */
				mtcb->state=TCPS_SYNRCVD;
				mtcb->connection_timer=defaults.connection_timeout*CLK_TCK;
/* ??? mtcb->snd_buf_next_isn++; */
				ierr=itcp_send_head(mtcb, mtcb->snd_isn, mtcb->rcv_next, SYN|ACK);
				mtcb->retrans_timeout=clock();
/* ??? mtcb->snd_next++; */
        if(ierr < 0) 
				{
					clear_flag(TCP_TCB_SEM);
					return(ierr);
				}
			}
			clear_flag(TCP_TCB_SEM);
			return(0);
			
		default:
			/* Adjust data buffer to receive-window */
			if(tcph->seq_nr < mtcb->rcv_next)
			{
				data+=mtcb->rcv_next-tcph->seq_nr;
				data_len-=(int)((long)((long)mtcb->rcv_next-(long)tcph->seq_nr));
			}
			if(tcph->seq_nr+data_len > mtcb->rcv_next+mtcb->rcv_wnd)
				data_len=(int)((long)((long)mtcb->rcv_next+(long)mtcb->rcv_wnd-(long)tcph->seq_nr));
			if((tcph->seq_nr > mtcb->rcv_next) || (data_len < 0))
			{/* Doesn't fit the recv-window, unacceptable */
				if(! FRST)
				{
					ierr=itcp_send_head(mtcb, mtcb->snd_next, mtcb->rcv_next, ACK);
					clear_flag(TCP_TCB_SEM);
					return(ierr);
				}
				clear_flag(TCP_TCB_SEM);
				return(0);
			}
			
			if(FRST)
			{/* Connection-abort by remote host */
				if(mtcb->tcp_sig)
					*(mtcb->tcp_sig)=1;
				delete_tcb(mtcb);
				clear_flag(TCP_TCB_SEM);
				return(0);
			}

			if((mtcb->state==TCPS_SYNRCVD)||(mtcb->state==TCPS_ESTABLISHED))
			{
				if((check_security(mtcb, iph)==ERROR)||(check_precedence(mtcb, iph)==ERROR))
				{
					ierr=itcp_send_head(mtcb, mtcb->snd_next, tcph->seq_nr+data_len, RST|ACK);
					delete_tcb(mtcb);
					clear_flag(TCP_TCB_SEM);
					return(ierr);
				}
			}
			
			if(FSYN)
			{
				if(FACK)
					ierr=itcp_send_head(mtcb, tcph->ack_nr, 0, RST);
				else
					ierr=itcp_send_head(mtcb, mtcb->snd_next, tcph->seq_nr+data_len, RST|ACK);
				delete_tcb(mtcb);
				clear_flag(TCP_TCB_SEM);
				return(ierr);
			}
			
			if(!FACK)
			{
				clear_flag(TCP_TCB_SEM);
				return(0);
			}
			
			switch(mtcb->state)
			{
				case TCPS_SYNRCVD:	/* our SYN from listen is answered? */
					if((mtcb->snd_una <= tcph->ack_nr) && (tcph->ack_nr <= mtcb->snd_next))
					{ /* Yes */
						mtcb->state=TCPS_ESTABLISHED;
						calc_conn_time(mtcb);
					}
					else
					{/* No, reset */
						ierr=itcp_send_head(mtcb, tcph->ack_nr, 0, RST);
						clear_flag(TCP_TCB_SEM);
						return(ierr);
					}
				/* no break, we continue from SYNRCVD now in ESTABLISHED */							
				case TCPS_ESTABLISHED:
				case TCPS_CLOSEWAIT:
				case TCPS_FINWAIT1:
				case TCPS_CLOSING:
#ifdef iodebug
if(FFIN) {Dftext("[IN-FIN in state ");Dfnumber(mtcb->state);Dftext("]\r\n");}
#endif
					/* Update snd_una if ACK is in transmitted window */
					if((mtcb->snd_una < tcph->ack_nr) && (tcph->ack_nr <= mtcb->snd_next))
						mtcb->snd_una=tcph->ack_nr;
					else if(tcph->ack_nr > mtcb->snd_next)
					{/* else send a corrected ACK */
						ierr=itcp_send_head(mtcb, mtcb->snd_next, mtcb->rcv_next, ACK);
						clear_flag(TCP_TCB_SEM);
						return(ierr);
					}

					/* Update send_window */
					mtcb->snd_wnd=tcph->window;
					if(mtcb->snd_wnd==0) mtcb->snd_wnd=1; /* See RFC, Sending TCP must send at least Byte and retransmit frequently even if snd_wnd is 0 */
					/* Limit to user-setup */
					if(mtcb->snd_wnd > defaults.snd_wnd) mtcb->snd_wnd=defaults.snd_wnd;

					/* Check for FIN-ACKs */
					/* I sent FIN, is it ACKed? */
					if(mtcb->state == TCPS_FINWAIT1)
						if(mtcb->snd_next==tcph->ack_nr) /* Yes */
							mtcb->state=TCPS_FINWAIT2;
					/* Simultaneous FIN, his should be ACKed, mine also? */
					if(mtcb->state == TCPS_CLOSING)
						if(mtcb->snd_next==tcph->ack_nr)	/* Yes */
							mtcb->state=TCPS_TIMEWAIT;
#ifdef iodebug
if(FFIN) {Dftext("[IN-FIN out state ");Dfnumber(mtcb->state);Dftext("]\r\n");}
#endif
				break;
				
				case TCPS_LASTACK: /* Is my final FIN now ACKed? */
					if(mtcb->snd_next==tcph->ack_nr)
					{
						delete_tcb(mtcb);
						clear_flag(TCP_TCB_SEM);
						return(0);
					}
				break;
				
				case TCPS_TIMEWAIT:
				/* This incoming segment must be a retransmission of remote's FIN */
					if(mtcb->snd_next==tcph->ack_nr)
					{
						ierr=itcp_send_head(mtcb, mtcb->snd_next, mtcb->rcv_next, ACK);
						if(ierr < 0)
						{
							clear_flag(TCP_TCB_SEM);
							return(ierr);
						}
						mtcb->close_timer=mtcb->close_timeout;
					}
				break;
			}
		
_data_process_:
		
		if(FURG)
		{
			if((long)tcph->urg_pnt+tcph->seq_nr > mtcb->recv_up)
				mtcb->recv_up=(long)tcph->urg_pnt+tcph->seq_nr;
			while(!set_flag(TCP_RBUF_SEM)) timer_malloc();
			if(mtcb->recv_up >= mtcb->rbuf_isn+mtcb->recv_buf_len)
				mtcb->recv_flags|=2; /* Set URG-Flag */
			clear_flag(TCP_RBUF_SEM);
		}
		
		if((data_size > 0) &&		/* data_len could have been shrinked due to recv-window */
			 ((mtcb->state == TCPS_ESTABLISHED)||
			 (mtcb->state == TCPS_FINWAIT1)||
			 (mtcb->state == TCPS_FINWAIT2)))
		{
#ifdef iodebug
if(db_handle > -1)
{
Dftext("[TCP accepted ");
Dfnumber(data_len);
Dftext(" Bytes]\r\n");
}
#endif
			while(!set_flag(TCP_RBUF_SEM)) timer_malloc();
			if(FPSH)
			{	mtcb->recv_flags|=1; /* Set PSH-Flag */}
			if(mtcb->recv_buf==NULL)
			{/* New allocation */
				dst=imalloc(data_len+ADD_RBLOCK); 
				if(dst==NULL)
				{
					clear_flag(TCP_RBUF_SEM);
					clear_flag(TCP_TCB_SEM);
#ifdef iodebug
if(db_handle > -1)
	Dftext("[TCP aborted data due to memory failure]\r\n");
#endif
					return(ENSMEM);
				}
				mtcb->recv_buf_siz=data_len+ADD_RBLOCK;
				mtcb->recv_buf=dst;
			}
			else
			{	/* Re-allocation neccessary? */
				if(mtcb->recv_buf_siz < mtcb->recv_buf_len+data_len)
				{
					dst=imalloc(mtcb->recv_buf_siz+data_len+ADD_RBLOCK);
					if(dst==NULL)
					{
						clear_flag(TCP_RBUF_SEM);
						clear_flag(TCP_TCB_SEM);
#ifdef iodebug
if(db_handle > -1)
	Dftext("[TCP aborted data due to memory growth failure]\r\n");
#endif
						return(ENSMEM);
					}
					mtcb->recv_buf_siz+=data_len+ADD_RBLOCK;
					block_copy(dst, mtcb->recv_buf, mtcb->recv_buf_len);
					ifree(mtcb->recv_buf);
					mtcb->recv_buf=dst;
				}
				else
					dst=mtcb->recv_buf;
			}
#ifdef iodebug
if(db_handle > -1)
{
/*	Dftext("[Accepted data is the following ");*/
	Dftext("[Accepted data; ");
	Dfnumber(data_len);
	Dftext(" Bytes:]\r\n");
	Fwrite(db_handle, data_len, data);
	Dftext("\r\n[End Of TCP-Data]\r\n");
}
#endif

			dst+=mtcb->recv_buf_len;
			mtcb->recv_buf_len+=data_len;
			clen=data_len;
			while(clen--)
				*dst++=*data++;
			clear_flag(TCP_RBUF_SEM);
			mtcb->rcv_next=tcph->seq_nr+data_size;	/* "data_len" could have been adjusted, if seq_nr was lower than rcv_next */
			/* If transmission-queue is empty (or waiting for retransmission),
				 send separate ack, else ack will be sent with next transmission */
			if((mtcb->first==NULL) || (mtcb->first->bsn+mtcb->first->len <= mtcb->snd_next))
			{
				ierr=itcp_send_head(mtcb, mtcb->snd_next, mtcb->rcv_next, ACK);
				if(ierr < 0)
				{
					clear_flag(TCP_TCB_SEM);
					return(ierr);
				}
			}
		}

		if(FFIN)
		{
			if((mtcb->state==TCPS_CLOSED)||
				 (mtcb->state==TCPS_LISTEN)||
				 (mtcb->state==TCPS_SYNSENT))
			{
				#ifdef iodebug
					Dftext("[TCP-FIN 1]\r\n");
				#endif
				clear_flag(TCP_TCB_SEM);
				return(0);
			}
				
			mtcb->rcv_next=tcph->seq_nr+data_size+1;
			mtcb->recv_flags|=1; /* Set Push-Flag */
			ierr=itcp_send_head(mtcb, mtcb->snd_next, mtcb->rcv_next, ACK);
			if(ierr < 0)
			{
				clear_flag(TCP_TCB_SEM);
				return(ierr);
			}
			
			if((mtcb->state==TCPS_SYNRCVD)||(mtcb->state==TCPS_ESTABLISHED))
				mtcb->state=TCPS_CLOSEWAIT; /* Incoming FIN */
			else if(mtcb->state==TCPS_FINWAIT1)
			{
				if(tcph->ack_nr==mtcb->snd_next) /* My FIN as now ACKed */
				{/* And there's also a incoming FIN */
				 /* so FINWAIT2 isn't entered */
				 #ifdef iodebug
				 	Dftext("[TCP FIN 2]\r\n");
				 #endif
					mtcb->state=TCPS_TIMEWAIT;
					mtcb->close_timer=mtcb->close_timeout;
					clear_user_timers(mtcb); /* Other timers are turned off */
				}
				else	/* Both TCPs sending FIN at once */
				{
					#ifdef iodebug
						Dftext("[TCP FIN 3]\r\n");
					#endif
					mtcb->state=TCPS_CLOSING;
				}
			}
			else if(mtcb->state==TCPS_FINWAIT2)
			{
#ifdef iodebug
Dftext("[TCP FIN 4]\r\n");
#endif
				mtcb->state=TCPS_TIMEWAIT;
				mtcb->close_timer=mtcb->close_timeout;
				clear_user_timers(mtcb); /* Other timers are turned off */
			}
			else if(mtcb->state==TCPS_TIMEWAIT)
				mtcb->close_timer=mtcb->close_timeout;
		}

		break; /* End of default */
	}
	clear_flag(TCP_TCB_SEM);
	return(0);
}

void tcp_send_buffers(tcb *mtcb, long tim_sub)
{/* Send the first buffer in queue, that has a timer <= 0 */
	tcp_send_buffer *tb=mtcb->first;
	tcp_crc_header	*tp;
	uint						total_len, len, block;
	int							ierr=0, s_block, MaxBlocks;
	ulong						offset;
	long						aloop;
	uchar						*sbuf, *combuf;

	while(tb)
	{			
		if(tb->len == -1) /* Send FIN */
		{
			if(tb->transmission_timer > 0)
			{
				tb->transmission_timer-=tim_sub;
				return;
			}
			#ifdef iodebug
				Dftext("[TCP send fin]\r\n");
			#endif
			ierr=tcp_send_fin(mtcb, tb->bsn);
			if(ierr > -1)
			{
				tb->transmission_timer=mtcb->retrans_timeout;
				if(mtcb->state==TCPS_CLOSEWAIT)
					mtcb->state=TCPS_LASTACK;
				else if(mtcb->state==TCPS_ESTABLISHED)
					mtcb->state=TCPS_FINWAIT1;
			}
			return;
		}
		if(tb->bsn+tb->len > mtcb->snd_next) break;
		tb=tb->next;
	}
	if(tb==NULL) return;

	offset=mtcb->snd_next-tb->bsn;
	
	s_block=0; 
	if(defaults.disable_send_ahead)
		MaxBlocks=1;
	else
		MaxBlocks=MAX_BLOCKS;
	while((s_block < MaxBlocks) && (mtcb->trans_timer[s_block] > -1)) ++s_block;
	if(s_block == MaxBlocks) 
	{
		#ifdef iodebug
			Dftext("[TCP - timers checked]\r\n");
		#endif
		return;
	}

	#ifdef iodebug
		Dftext("[TCP sending with offset ");Dfnumber(offset);Dftext("]\r\n");
	#endif

	block=(int)sizeof(tcp_crc_header)+mtcb->snd_wnd;
	combuf=(uchar*)imalloc(block);
	if(combuf==NULL) return;

	tp=(tcp_crc_header*)combuf;
	init_tpch(tp, mtcb);
	aloop=1;
			
	while(s_block < MaxBlocks)
	{
		if( /*(aloop > 1) &&*/ (((defaults.using_ppp)&&(ppp_out_buf!=NULL)) ||
				((!defaults.using_ppp)&&(out_buf!=NULL))) ) break;
		#ifdef iodebug
			Dftext("[TCP send loop "); Dfnumber(aloop);Dftext("]\r\n");
		#endif
		combuf=(uchar*)tp+sizeof(tcp_crc_header);

		total_len=0;
		while(total_len < mtcb->snd_wnd)
		{
			sbuf=tb->buf+offset;
			if(tb->len-offset > mtcb->snd_wnd-total_len)
			{
#ifdef iodebug
	Dftext("[A]");
#endif
				len=mtcb->snd_wnd-total_len;
				offset+=len;
			}
			else
			{
#ifdef iodebug
	Dftext("[B]");
#endif
				len=(uint)(tb->len-offset);
				tb=tb->next; offset=0;
			}
#ifdef iodebug
	Dftext("[block: "); Dfnumber(len); Dftext("]");
#endif
			total_len+=len;	
			while(len--)
				*combuf++=*sbuf++;
#ifdef iodebug
	Dftext("[total: "); Dfnumber(total_len); Dftext("]");
#endif
			if(tb==NULL) break;
			if(tb->len==-1) break;
		}
		if(total_len==0) break;
		
		tp->tcp_len=(uint)sizeof(tcp_header)+total_len;
		tp->tcph.seq_nr=mtcb->snd_next;
		
		tp->tcph.crc=0;
		tp->tcph.flags=ACK;
		tp->tcph.crc=calc_tcp_crc(tp, tp->tcp_len+(uint)(sizeof(tcp_crc_header)-sizeof(tcp_header)));

#ifdef iodebug
	Dftext("\r\n");
#endif
		ierr=ip_send(defaults.my_ip, mtcb->dst_ip, 6, mtcb->TOS, mtcb->TTL, (uchar*)&(tp->tcph), (uint)tp->tcp_len, (int)clock(), 0, NULL, 0);

		if(ierr < 0)	break;

		mtcb->snd_next+=total_len;
		mtcb->snd_bll[s_block]=mtcb->snd_next-1;
		mtcb->trans_timer[s_block]=mtcb->retrans_timeout+aloop*(((long)(total_len) * CLK_TCK)/150); /* 1500 */

		++s_block;
		++aloop;
				
		if(tb==NULL) break;
		if(tb->len==-1) break;
	}
	ifree(tp);
}

int	check_trans_queue(tcb *mtcb, long tim_sub)
{/* Check the transmission-queue */
	tcp_send_buffer	*tb1, *tb2;
	int							len, num, a, MaxBlocks;

	if(defaults.disable_send_ahead)
		MaxBlocks=1;
	else
		MaxBlocks=MAX_BLOCKS;
		
	/* First, delete all sent buffers */
	tb1=mtcb->first;
	while(tb1)
	{
		if(tb1->len == -1) len=1;
		else len=tb1->len;
		
		if(tb1->bsn+len <= mtcb->snd_una)
		{/* This buffer is ACKed->delete */
			tb2=tb1->next;
			if(tb1->buf) ifree(tb1->buf);
			ifree(tb1);
			mtcb->first=tb1=tb2;
		}
		else
			break;	/* No sense in continuing, since the following buffers won't be acked either */
	}

	/* Remove acked blocks from retrans-array */
	for(num=0; num < MaxBlocks; ++num)
	{
		if((mtcb->trans_timer[num] > -1) && (mtcb->snd_bll[num] < mtcb->snd_una))
			mtcb->trans_timer[num]=-1;
	}
	/* Move used entries back over freed entries */
	num=0;
	while(num < MaxBlocks)
	{
		if(mtcb->trans_timer[num] > -1) break;
		++num;
	}
	if((num > 0) && (num < MaxBlocks))
	{
		a=0;
		while(num < MaxBlocks)
		{
			mtcb->trans_timer[a]=mtcb->trans_timer[num];
			mtcb->snd_bll[a++]=mtcb->snd_bll[num++];
		}
		while(a < MaxBlocks) mtcb->trans_timer[a++]=-1;
	}

	/* Check if resend timer has expired */
	num=0;
	if((mtcb->trans_timer[0] > -1) && (mtcb->trans_timer[0] <= tim_sub))
	{/* Prepare for resending whole blocks */
		mtcb->snd_next=mtcb->snd_una;
		for(a=0; a < MaxBlocks; ++a) mtcb->trans_timer[a]=-1;
	}
		
	/* Decrement timers */
	for(a=0; a < MaxBlocks; ++a)
		if(mtcb->trans_timer[a] > -1) mtcb->trans_timer[a]-=tim_sub;
		
	/* Send blocks */
	tcp_send_buffers(mtcb, tim_sub);
	

/*	
	/* Second, check if send-timer for first buffer has expired */
	tb1=mtcb->first;
	if(tb1)
	{
		/* Falls Sendepuffer leer ist, retrans-Timer auf Block-
				unabh„ngigen Wert runtersetzen */
		if( ((defaults.using_ppp)&&(ppp_out_buf==NULL)) ||
				((!defaults.using_ppp)&&(out_buf==NULL)) )
			if(tb1->transmission_timer > mtcb->retrans_timeout)
				tb1->transmission_timer=mtcb->retrans_timeout;
				
		tb1->transmission_timer-=tim_sub;
		if(tb1->transmission_timer <= 0)
		{/* Send the buffer and reset the timer */
			if(tcp_send_1buffer(mtcb, &num)>=0)
			{	
				tb1->transmission_timer=mtcb->retrans_timeout*num;
				tb1->transmission_timer+=(((long)(tb1->len) * CLK_TCK)/1500);	/* 1500 Bytes/sec. */
				#ifdef iodebug
					if(db_handle > -1){	Dftext("[Resetting transmission timer to ");Dfnumber(tb1->transmission_timer); Dftext("]\r\n");}
				#endif
			}
		}

/*  TERBO
		Resends much too late
*/
		/* Second, check if low-level-queue is empty and less than
				MaxBlocks are sent. If so,
				send next unsent block also */
		if(  ( ((defaults.using_ppp)&&(ppp_out_buf==NULL)) ||
				   ((!defaults.using_ppp)&&(out_buf==NULL)) )
				&& (mtcb->snd_next-mtcb->snd_una < MaxBlocks*mtcb->snd_wnd)
			)
		{
			tb1=mtcb->first;
			while(tb1 && (tb1->transmission_timer > 0)) 
			{
				tb1->transmission_timer-=tim_sub;
				tb1=tb1->next;
			}
			if(tb1) 
			{
				if(tcp_send_1buffer(mtcb, &num)>=0)
				{
				tb1->transmission_timer=mtcb->retrans_timeout*num;
				tb1->transmission_timer+=(((long)(tb1->len) * CLK_TCK)/1500);	/* 1500 Bytes/sec. */
/*					tb1->transmission_timer=mtcb->retrans_timeout;*/
					#ifdef iodebug
						if(db_handle > -1){	Dftext("[X-Resetting transmission timer to ");Dfnumber(tb1->transmission_timer); Dftext("]\r\n");}
					#endif
				}
			}
		}
*/

	/* Fourth, check if the user-timer has expired */
	tb1=mtcb->first;
	if(tb1)
	{
		if(tb1->user_timer < 0)
			return(E_OK);	/* User-timer not active */
		
		tb1->user_timer-=tim_sub;
		if(tb1->user_timer <= 0)
			return(ETIMEDOUT);
	}
	
	return(E_OK);
}

void tcp_timer_jobs(void)
{
	long	tim_sub, tries=0;
	tcb		*mtcb;
	int		ctq=0;
	
	tim_sub=CLK_TCK/defaults.clk_tck; /* Timer-Units to sub */

	/* Reason for limited Sema-tries: 
		 timer-routines start -> tmalloc done
		 <yield>
		 User-routine set's sema and goes into timer malloc
		 <yield>
		 timer continues -> tries to set sema
		 but sema won't be cleared until next timer turn
		 which will satisfy tmalloc.
		 
		 So while trying to get sema, timer_malloc is called
		 to satisfy any pending tmallocs. If even this should
		 fail (because user-routine is doing extensive work)
		 10 times, a retry will come with the next timer-jobs
		 
		 Other timer-routines (tcp_in) call timer_malloc() during
		 set_flag() indefinitely until they get the semaphore because
		 otherwise the incoming segment would be dropped
	*/

	do
	{
		ctq=set_flag(TCP_SBUF_SEM);
		if(!ctq) timer_malloc();
		++tries;
	}while((!ctq) && (tries < 10));

	if(!ctq) return; /* Try again later */

	ctq=0;tries=0; 
	do
	{
		ctq=set_flag(TCP_TCB_SEM);
		if(!ctq) timer_malloc();
		++tries;
	}while((!ctq) && (tries < 10));

	if(!ctq)
	{
		clear_flag(TCP_SBUF_SEM);
		return; /* Try again later */
	}

	mtcb=first_tcb;
	
	while(mtcb)
	{
		/* Check transmitter-queue */
		if( (mtcb->state==TCPS_ESTABLISHED)||
			  (mtcb->state==TCPS_FINWAIT1)||
			  (mtcb->state==TCPS_CLOSING)||
			  (mtcb->state==TCPS_CLOSEWAIT))
		{
			ctq=check_trans_queue(mtcb, tim_sub);
			if(ctq==ETIMEDOUT)
			{/* User-Timeout has expired */
				delete_tcb(mtcb);
				clear_flag(TCP_TCB_SEM);
				clear_flag(TCP_SBUF_SEM);
				return;
			}
		}

		/* Check Close-timeout */
		if(mtcb->close_timer > -1)
		{/* Timer is running */
			mtcb->close_timer-=tim_sub;
			if(mtcb->close_timer <= 0)
			{/* Close Connection */
				delete_tcb(mtcb);
				clear_flag(TCP_TCB_SEM);
				clear_flag(TCP_SBUF_SEM);
				return; /* Since mtcb now points to nirvana...*/
			}
		}
		
		/* Check Connection-Timeout */
		if(((mtcb->state == TCPS_SYNSENT) || (mtcb->state == TCPS_SYNRCVD))
			 && (mtcb->connection_timer > -1))
		{/* Timer is running */
			mtcb->connection_timer-=tim_sub;
			if(mtcb->connection_timer <= 0)
			{/* Close Connection */
				delete_tcb(mtcb);
				clear_flag(TCP_TCB_SEM);
				clear_flag(TCP_SBUF_SEM);
				return; /* Since mtcb now points to nirvana...*/
			}
		}
		
		mtcb=mtcb->next;
	}

	clear_flag(TCP_TCB_SEM);
	clear_flag(TCP_SBUF_SEM);
}

void tcp_all_abort(void)
{
	tcb	*mtcb=first_tcb, *btcb;

	while(mtcb)
	{
		btcb=mtcb->next;
		switch(mtcb->state)
		{
			case TCPS_SYNRCVD:
			case TCPS_ESTABLISHED:
			case TCPS_FINWAIT1:
			case TCPS_FINWAIT2:
			case TCPS_CLOSEWAIT:
				tcp_send_reset(mtcb);
			/* no break! */
			default:
				delete_tcb(mtcb);
			break;
		}
		mtcb=btcb;
	}
	first_tcb=NULL;
}
