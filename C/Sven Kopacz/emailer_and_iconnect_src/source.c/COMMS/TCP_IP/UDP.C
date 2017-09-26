#define iodebug

#include <stdio.h>
#include <stdlib.h>
#include <atarierr.h>
#include <sockerr.h>
#include <in.h>
#include <time.h>

#include "network.h"
#include "socket.h"
#include "ip.h"
#include "udp.h"

uint calc_tcp_crc(void *buf, int bytes);

int	*udp_ports=NULL;
udp_rbuf	*first=NULL;

extern default_values defaults;

int udp_open(int port)
{/* Prepares UDP-Port number <port> to receive incoming data
    returns E_OK or any errors (ENSMEM, ENHNDL) */
    
  int	c=defaults.udp_count;
  if(udp_ports==NULL)
  {/* Init the port-array */
		udp_ports=(int*)tmalloc(c*sizeof(int));

		if(udp_ports==NULL)
			return(ENSMEM);
		while(c--)
			udp_ports[c]=-1;
		c=defaults.udp_count;
  }
   
  while(c--)
  {
  	if(udp_ports[c]==-1) /* Free port found */
  	{
  		udp_ports[c]=port;
  		return(E_OK);
  	}
  }
  
  return(ENHNDL);
}

int	udp_send(int src_port, int dst_port, ulong dst_ip, uchar *buf, int len)
{
	udp_crc_header	*uch;
	udp_header			*uph;
	uchar						*cbuf;
	int							blen=len, clen=len, ierr;
	uint						ip_len;
	
	if(len<=0) return(0);		/* 0 Bytes sent */

	ip_len=(uint)len+(uint)sizeof(udp_header);
	clen=(int)sizeof(udp_crc_header)+len;
	uch=(udp_crc_header*)tmalloc(clen);
	if(uch==NULL)
		return(ENSMEM);
	
	uch->src_ip=defaults.my_ip;
	uch->dst_ip=dst_ip;
	uch->zero=0;
	uch->protocol=17;
	uch->len=len+(int)sizeof(udp_header);

	uph=&(uch->uph);
	uph->src_port=src_port;
	uph->dst_port=dst_port;
	uph->len=len+(int)sizeof(udp_header);
	uph->crc=0;
	
	cbuf=((uchar*)uch)+sizeof(udp_crc_header);
	while(len--)
		*cbuf++=*buf++;
	
	uph->crc=calc_tcp_crc(uch, clen);
	
	ierr=ip_send(defaults.my_ip, uch->dst_ip, 17, defaults.TOS, defaults.TTL, (uchar*)uph, ip_len, (int)clock(), 0, NULL, 0);
	ifree(uch);
	if(ierr < 0)
		return(ierr);
	return(blen);
}

int	udp_in(uchar *buf, uint len, ip_header *iph)
{
	udp_header	luph, *uph=&luph;
	uchar				*data, *dbuf;
	int 				c, data_len, found;
	udp_rbuf		**prev, *act;

#ifdef iodebug
	Dftext("[UDP incoming process"); Dfnumber(len); Dftext(" bytes]\r\n");
#endif
	/* Copy UDP-header to local header to avoid typecast in bytestream */
	data_len=(int)sizeof(udp_header);
	data=buf;
	dbuf=(uchar*)uph;
	while(data_len--)
		*dbuf++=*data++;

	/* Split buf into udp_header and data */
	/* uph=(udp_header*)buf; */
	data=buf+sizeof(udp_header);
	data_len=len-(int)sizeof(udp_header);
	/* Destination Port open? */
	if(udp_ports==NULL)
	{
#ifdef iodebug
	Dftext("[UDP dropping-no ports open]\r\n");
#endif
		return(ERROR);
	}

	c=defaults.udp_count;
	found=0;
	while(c--)
	{
		if(udp_ports[c]==uph->dst_port)
		{
			found=1;
			break;
		}
	}
	if(found==0)
	{
#ifdef iodebug
	Dftext("[UDP dropping-dest port not open]\r\n");
#endif
		return(ERROR);
	}
	
	/* Ok, allocate a new receive-buffer */
	
	act=(udp_rbuf*)tmalloc(data_len+sizeof(udp_rbuf));
	if(act==NULL) return(ENSMEM);
	
	while(!set_flag(UDP_RBUF_SEM));
	prev=&first;
	while(*prev)
		prev=&((*prev)->next);
	
	*prev=act;
	act->next=NULL;
	
	act->dst_port=uph->dst_port;
	act->src_port=uph->src_port;
	act->src_ip=iph->src_ip;
	act->len=data_len;
	act->buf=dbuf=((uchar*)act)+sizeof(udp_rbuf);
	
	while(data_len--)
		*dbuf++=*data++;

	clear_flag(UDP_RBUF_SEM);
#ifdef iodebug
	Dftext("[UDP queued incoming data]\r\n");
#endif
	return(E_OK);
}

int udp_recv(int port, uchar *buf, int len, int peek, void *from, int *fromlen)
{
	/* <from> will be filled with the sender's data */
	/* fromlen indicates <from>-size on call and gives back len
	   of copied adress */
	/* if <port> isn't ready to receive any data, -1 is returned,
		 else the number of received bytes (which might of course be 0) */
		 
	udp_rbuf	*ubuf, *sbuf, **prev;
	int				clen, mlen;
	uchar			*cbuf, *dst;
	sockaddr_in	sad;

	int				c=defaults.udp_count, found;
  
  if(udp_ports==NULL)
  	return(-1);
  
  found=0;
  while(c--)
  {
  	if(udp_ports[c]==port) /* Port found */
  		found=1;
  }
  if(!found)
  {
		#ifdef iodebug
			Dftext("[UDP-recv port not open]\r\n");
		#endif
  	return(-1);
  }
  
	/* Check port for received data */
	while(!set_flag(UDP_RBUF_SEM));
	
	sbuf=first;
	ubuf=NULL;	
	while(sbuf)
	{
		if(sbuf->dst_port == port)
		{
			ubuf=sbuf;
			break;
		}
		sbuf=sbuf->next;
	}
	
	if(ubuf==NULL)
	{
		clear_flag(UDP_RBUF_SEM);
		#ifdef iodebug
			Dftext("[UDP-recv no data in port]\r\n");
		#endif
		return(0); /* 0 Bytes received */
	}
	
	/* Copy as many bytes as possible */
	clen=ubuf->len;
	if(len < clen) clen=len;
	mlen=clen;
	cbuf=ubuf->buf;
	while(clen--)
		*buf++=*cbuf++;

	sad.sin_port=ubuf->src_port;
	sad.sin_addr=ubuf->src_ip;
	
	/* if <peek> is not set, discard buffer */
	if(peek==0)
	{
		/* Uncat from Recv-queue */
		prev=&first;
		while(*prev != ubuf) prev=&((*prev)->next);
		*prev=(*prev)->next;
		/* Free it */
		/* (ubuf's data_buf must not be freed, since it wasn't allocated
				seperately but included in ubuf)
		*/
		ifree(ubuf);
	}
	

	/* Copy from? */
	if((from != NULL) && (fromlen != NULL))
	{
		dst=(uchar*)from;
		clen=(int)sizeof(sockaddr_in);
		if(*fromlen < clen) clen=*fromlen;
		*fromlen=clen;
		cbuf=(uchar*)&sad;
		while(clen--)
			*dst++=*cbuf++;
	}

	#ifdef iodebug
		Dftext("[UDP-recv data copied"); Dfnumber(mlen); Dftext("]\r\n");
	#endif
	
	clear_flag(UDP_RBUF_SEM);
	return(mlen);
}

int udp_status(int port)
{
	/* Returns -1 if data is not accepted on <port>
		 else number of pending bytes to receive 
		 (which might of course be zero)
	*/

	udp_rbuf	*ubuf, *sbuf;
	int				c=defaults.udp_count, found;
  
  if(udp_ports==NULL)
  	return(-1);
  
  found=0;
  while(c--)
  {
  	if(udp_ports[c]==port) /* Port found */
  		found=1;
  }
  if(!found)
  	return(-1);
  
	/* Check receiving buffers */
	while(!set_flag(UDP_RBUF_SEM));
	sbuf=first;
	ubuf=NULL;	
	while(sbuf)
	{
		if(sbuf->dst_port == port)
		{
			ubuf=sbuf;
			break;
		}
		sbuf=sbuf->next;
	}
	clear_flag(UDP_RBUF_SEM);
	
	if(ubuf==NULL)
		return(0); /* No pending data  */
	
	return(ubuf->len);
}

int udp_close(int port)
{
	udp_rbuf	*ubuf, **prev;
	int				c;
	
	/* Clear port from array */
	if(udp_ports==NULL)
		return(E_OK);

	c=defaults.udp_count;
	while(c--)
	{
		if(udp_ports[c]==port)
		{
			udp_ports[c]=-1;
			break;
		}
	}

	/* Delete pending recv-bufs */	
	while(!set_flag(UDP_RBUF_SEM));

_free_queue:
	prev=&first;
	ubuf=first;
	while(ubuf!=NULL)
	{
		if(ubuf->dst_port==port)
		{
			*prev=(*prev)->next;
			ifree(ubuf);
			goto _free_queue;
		}
		prev=&((*prev)->next);
		ubuf=ubuf->next;
	}

	clear_flag(UDP_RBUF_SEM);
	return(E_OK);
}

void udp_all_abort(void)
{	
	int c;
	
	if(udp_ports==NULL) return;
	
	c=defaults.udp_count;
	while(c--)
	{
		if(udp_ports[c] > -1)
			udp_close(udp_ports[c]);
	}
	
	ifree(udp_ports);
	udp_ports=NULL;
	first=NULL;
	return;
}