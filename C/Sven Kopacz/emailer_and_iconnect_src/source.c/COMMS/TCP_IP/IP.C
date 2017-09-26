 #define iodebug

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <atarierr.h>
#include <sockerr.h>
#include <time.h>

#include "network.h"
#include "ip.h"

#ifdef iodebug
#include "tcp.h"
#endif

extern int		slip_send(uchar	*buf, uint len);
extern int		ppp_send(uint protocol, uchar *buf, uint len);
#define 			PPP_PROTO_IP		0x21

extern int		tcp_in(uchar *buf, uint len, ip_header *iph);
extern void		udp_in(uchar *buf, uint len, ip_header *iph);
extern uint		eac(ulong sum);

extern default_values defaults;

ip_buffer	*first_buf=NULL;
localhost_queue	*first_lhqueue=NULL;

int		store_raw=0;
uchar	*raw_buf=NULL;
long	raw_buf_len=0;

void ip_open_raw(void)
{
	store_raw=1;
}

void ip_close_raw(void)
{
	store_raw=0;
	if(raw_buf) ifree(raw_buf);
	raw_buf_len=0;
}

long	ip_read_raw(uchar *buf, long len)
{
	long cnt=len, copied;
	uchar	*fbuf=raw_buf;

	set_flag(IP_RAW_BUF);	
	if((raw_buf==NULL)||(raw_buf_len==0)) {clear_flag(IP_RAW_BUF);return(0);}
	if(raw_buf_len < len) cnt=raw_buf_len;
	raw_buf_len-=cnt;
	copied=cnt;
	while(cnt--)
		*buf++=*fbuf++;
	/* Copy remaining raw data to start of raw_buf */
	buf=raw_buf;
	while(cnt++ < raw_buf_len)
		*buf++=*fbuf++;
	if(raw_buf_len==0)	/* Buffer cleared */
		if(raw_buf) ifree(raw_buf);
	clear_flag(IP_RAW_BUF);
	return(copied);	
}

long ip_send_raw(ulong dst_ip, byte protocol, uchar *buf, uint len)
{
	return(ip_send(defaults.my_ip, dst_ip, protocol, 
							 defaults.TOS, defaults.TTL, buf, len, 
							 (int)clock(), 0, NULL, 0));
}

void ip_store_raw(uchar *buf, uint len)
{
	long newlen;
	uchar *newbuf;
	
	if(!store_raw)
	{
		#ifdef iodebug
			Dftext("[IP raw dropping, packet:]\r\n");
			Dfdump(buf, len);
			Dftext("[end of unknown packet.]\r\n");
		#endif
		return;
	}
	
	#ifdef iodebug
		Dftext("[IP storing raw]\r\n");
	#endif

	set_flag(IP_RAW_BUF);
	newlen=raw_buf_len+len;
	newbuf=imalloc(newlen);
	if(newbuf==NULL)
	{
		#ifdef iodebug
			Dftext("[IP raw - no memory]\r\n");
		#endif
		clear_flag(IP_RAW_BUF);
		return;
	}
	if(raw_buf_len) memcpy(newbuf, raw_buf, raw_buf_len);
	ifree(raw_buf); raw_buf=newbuf;
	newbuf+=raw_buf_len;
	memcpy(newbuf, buf, len);
	raw_buf_len=newlen;
	clear_flag(IP_RAW_BUF);
}

int lower_level_send(uchar *buf, uint len)
{
	if(defaults.using_ppp)
		return(ppp_send(PPP_PROTO_IP, buf, len));
	else
		return(slip_send(buf, len));
}

void copy_header(ip_buffer *ipb, ip_header *iph)
{/* Copy header to iph_0 of buffer */
	uchar	*src, *dst;
	uint	len;
	
	src=(uchar*)iph;
	dst=(uchar*)(ipb->iph_0);
	len=(iph->version_IHL & 15)*4;
	while(len--)
		*dst++=*src++;
}

int cat_data_to_buf(ip_buffer *ipb, uchar *dbuf, uint dlen, uint dstart)
{/* Returns ENSMEM on Memory failure, else actual buffersize */
	uint	must_len;
	uchar	*src_buf, *dst_buf, *abuf;
	
	must_len=dstart+dlen;
	if(ipb->buf == NULL)
	{
		abuf=(uchar*)imalloc(must_len);
		if(abuf==NULL) return(ENSMEM);
	}
	else if(ipb->len < must_len)
	{
		abuf=imalloc(must_len);
		if(abuf==NULL) return(ENSMEM);
		block_copy(abuf, ipb->buf, ipb->len);
		ifree(ipb->buf);
	}
		
	ipb->buf=abuf;
	ipb->len=must_len;
	ipb->received+=dlen;
	
	src_buf=dbuf;
	dst_buf=abuf+dstart;
	while(dlen--)
		*dst_buf++=*src_buf++;
	
	return(ipb->len);
}

uint calc_ip_crc(void *buf, int words)
{
/*
 * Generic checksum computation routine.
 * Returns the one's complement of the 16 bit one's complement sum over
 * the `words' words starting at `buf'.
 */
	register uint	 *ubuf, count;
	register ulong csum=0;
	
	count=(uint)words;	/* To get it as a register variable */
	ubuf=(uint*)buf;
	
	while(count--)
		csum+=*ubuf++;
	
	return(~eac(csum) & 0xffff);
}

int cat_to_incoming(ip_header *iph)
{/* Cat to queue of localhost blocks */
 /* We can't pass the blocks directly to ip_in, we do this in the
    timer jobs. why:
    ip_send is called from the applications context
    ip_in is called form IConnect-context, thus all memory allocating
    routines and all semaphore-using routines in ip_in and in the
    eventually called tcp_in and udp_in do not expect the application
    context and would use the wrong memory allocations/semaphores
  */
	localhost_queue **plhq=&first_lhqueue;
	localhost_queue *lhq;
	char *pointer, *p2;
	uint len=iph->total_len;
	
	while(*plhq!=NULL) plhq=&((*plhq)->next);
	lhq=*plhq=tmalloc(iph->total_len + sizeof(localhost_queue));
	if(*plhq==NULL) return(ENSMEM);

	#ifdef iodebug
		Dftext("[IP cat to localhost queue]\r\n");
	#endif
	lhq->next=NULL;
	pointer=(char*)lhq;
	pointer+=sizeof(localhost_queue);
	lhq->buf=(ip_header*)pointer;
	
	p2=(char*)iph;
	while(len--) *pointer++=*p2++;
	
	return(iph->total_len);
}

int frag_send(ip_header *iph)
{/* Send the IP-Datagram, fragmenting if necessary */
 /* Returns error or >= 0 */
 
	uint	head_len=(iph->version_IHL & IP_IHL)*4, offset, bsize;
	uint				buf_len;
	int				ierr;
	register uint		a, b, copied;
	register uchar	*dbuf, *sbuf;
	
	if((iph->dst_ip == defaults.my_ip) || (iph->dst_ip==INADDR_LOOPBACK))
	{/* Send to myself */
		#ifdef iodebug
			Dftext("[IP routing to localhost]\r\n");
		#endif
		return(cat_to_incoming(iph));
	}
	
	if(iph->total_len <= defaults.MTU)
	{
		return(lower_level_send((uchar*)iph, iph->total_len));
	}
		
	if(iph->flags_frag_off & IP_DF)
	{
		#ifdef iodebug
			Dftext("[IP returning EMSGSIZE]\r\n");
		#endif
		return(EMSGSIZE);	/* Don't fragment set, but > MTU */
	}

	#ifdef iodebug
		Dftext("[IP fragmenting]\r\n");
	#endif		
	/* Modify header to send first fragment */
	/* Calc offset (in units of 8 octets) */
	offset=(defaults.MTU-head_len)/8;
	bsize=offset*8;	/* Blocksize per fragment */
	buf_len=iph->total_len-head_len;
	iph->total_len=head_len+bsize;
	iph->flags_frag_off|=IP_MF;	/* More fragments */
	iph->crc=0;
	iph->crc=calc_ip_crc(iph, head_len/2);
	ierr=lower_level_send((uchar*)iph, iph->total_len);
	if(ierr < 0)
		return(ierr);
	
	/* Generate remaining fragments */
	/* Copy options (selective) */
	sbuf=dbuf=(uchar*)&(iph->options[0]);
	/* Bytes to check */
	a=head_len-5*4;	/* IP-Header=5*4 Bytes+Options */
	copied=0;
	while(a > 0)
	{
		if((sbuf[0]==0)||(sbuf[0]==1))
		{/* EOF and NOOP are not copied */
			++sbuf; --a; continue;
		}
		if(sbuf[0] & 128)	/* Copyflag is on */
		{
			b=sbuf[1];	/* Length of Option including type and length byte */
			while(b--)
			{
				--a;
				*dbuf++=*sbuf++;
				++copied;
			}
		}
		else							/* Copyflag is off */
		{
			a-=sbuf[1];	/* Length of option including type and length byte */
			sbuf+=sbuf[1];
		}
	}
	
	/* Pad options */
	if(copied)
		while(copied & 3)
			{*dbuf++=0; ++copied;}
			
	dbuf=((uchar*)iph)+head_len;	/* Memorize start of original Data-buffer */
	sbuf=dbuf+bsize;						/* Start of next block */
	/* Correct header */
	head_len=5+copied/4;
	iph->version_IHL&=(~IP_IHL);	/* Set IHL to zero */
	iph->version_IHL|=head_len;	/* Set length in 4*octets */
	head_len*=4;	/* Head_len now in bytes */
	
	/* Sub first fragment from buf_len */
	buf_len-=bsize;
	/* Start sending fragments */
	while(buf_len)
	{
		/* Bytes to copy */
		if(buf_len > bsize) a=bsize;
		else a=buf_len;
		buf_len-=a;
		iph->total_len=head_len+a;
		iph->flags_frag_off&=(~IP_FRAGOFF);	 /* Delete old offset */
		iph->flags_frag_off|=offset;
		offset+=(a/8);
		if(buf_len==0)
			iph->flags_frag_off&=(~IP_MF);	/* Last fragment */
		iph->crc=0;
		iph->crc=calc_ip_crc(iph, head_len/2);
		/* Get new destination buffer */
		dbuf=((uchar*)iph)+head_len;
		/* Copy a bytes */
		while(a--)
			*dbuf++=*sbuf++;
		ierr=lower_level_send((uchar*)iph, iph->total_len);
		if(ierr < 0)
			return(ierr);
	}
		
	return(0);
}

int	ip_send(ulong	src_ip, ulong	dst_ip, byte protocol, byte	TOS, byte TTL, uchar *buf, uint len, int id, int flags, ulong *options, uint opt_len)
{
	/* Note: opt_len is in bytes! */
	
	ip_header	*iph;
	uchar			*sbuf;
	uint			head_len, a, blen=len;
	int				ierr;

#ifdef iodebug
if(db_handle > -1)
{
if(protocol==6)
{
tcp_header *tcph=(tcp_header*)buf;
Dftext("[TCP-OUT via IP:] ");
Dftext("SRC-IP=");
Dfdump((uchar*)(&src_ip), 4);
Dftext(", DST-IP=");
Dfdump((uchar*)(&dst_ip), 4);
Dftext(", SEQ=");
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
Dftext(", SRC-Port=");
Dfnumber(tcph->src_port);
Dftext(", DST-port=");
Dfnumber(tcph->dst_port);
}
else
{
Dftext("[UDP-OUT via IP]");
}
Dftext(".\r\n");
}
#endif

	if(len==0) return(0);	/* Nothing to send */

	head_len=(uint)sizeof(ip_header)+opt_len;
	iph=(ip_header*)tmalloc(head_len+len+4);
	if(iph==NULL) return(ENSMEM);

	iph->version_IHL=(4<<4)+(head_len/4);
	iph->TOS=TOS;
	iph->total_len=head_len+len;
	iph->id=id;
	iph->flags_frag_off=((flags & 2)<<13)+0;
	iph->TTL=TTL;
	iph->protocol=protocol;
	iph->crc=0;
	iph->src_ip=src_ip;
	iph->dst_ip=dst_ip;

	for(a=0; a < (opt_len/4); ++a)
		iph->options[a]=options[a];
	
	iph->crc=calc_ip_crc(iph, head_len/2);

	/* Now copy data */
	sbuf=((uchar*)iph)+head_len;
	while(len--)
		*sbuf++=*buf++;
	
	ierr=frag_send(iph);
	ifree(iph);
	if(ierr < 0)
		return(ierr);
	return(blen);
}

ip_buffer	*find_buffer_by_prot(byte protocol)
{	/* Find the first buffer for <protocol> in the queue
		 if it doesn't exist, return NULL */
		 
	ip_buffer	*buf=first_buf;
	
	while(buf != NULL)
	{
		if(buf->iph_0->protocol==protocol)
			break;
		buf=buf->next;
	}
	return(buf);
}

ip_buffer	*find_buffer_by_id(ulong *bid)
{	/* Find the first buffer that matches <bid> in the queue
		 if it doesn't exist, return NULL */
		 
	ip_buffer	*buf=first_buf;
	
	while(buf != NULL)
	{
		if((buf->bid[0]==bid[0]) &&
				(buf->bid[1]==bid[1]) &&
				(buf->bid[2]==bid[2]) &&
				(buf->bid[3]==bid[3]))
			break;
		buf=buf->next;
	}
	return(buf);
}

ip_buffer	*new_buffer(ulong *bid)
{/* Cat a new buffer to the queue */
	ip_buffer	**act=&first_buf, *ipb;
	
	while(*act)
		act=&((*act)->next);

	ipb=*act=(ip_buffer*)tmalloc(sizeof(ip_buffer));
	
	ipb->next=NULL;
	ipb->bid[0]=bid[0]; ipb->bid[1]=bid[1]; ipb->bid[2]=bid[2]; ipb->bid[3]=bid[3];
	ipb->timer=defaults.kill_ip_timer;
	ipb->iph_0=NULL;
	ipb->to_receive=0;
	ipb->received=0;
	ipb->len=0;
	ipb->buf=NULL;
	return(ipb);
}

void uncat_ipb(ip_buffer *buf)
{/* Delete the Buffer buf from the queue */
	ip_buffer	**prev=&first_buf, *act=first_buf;
	
	while(act)
	{
		if(act == buf)
		{/* Buffer found */
		 /* Set precedors next to act-next */
			*prev=act->next;
		 /* Free all buffer memory */
		 	if(act->buf) ifree(act->buf);
			if(act->iph_0) ifree(act->iph_0);
			ifree(act);
			return;
		}
		prev=&(act->next);
		act=act->next;
	}
}

int	ip_recv(uchar	*buf, uint len, byte protocol, ip_header *iph)
{/* Note: iph must be big enough to carry all possible options! */
 /* If <buf> isn't big enough to carry the received data, nothing
 		is copied and the -length (negative) of the received data is returned 
 		instead */
 		
	uint	clen;
	uchar	*cbuf;
	int		buf_len;
	
	ip_buffer	*ipb;
	ipb=find_buffer_by_prot(protocol);
	if(ipb == NULL) return(0);
	
	if((ipb->to_receive!=ipb->received) || (ipb->to_receive < 1))
		return(0);
	
	if(ipb->len > len)
		return(-(ipb->len));
	
	/* Copy the buffer */
	clen=ipb->len; cbuf=ipb->buf;
	while(clen--)	
		*buf++=*cbuf++;
	buf_len=(int)ipb->len;
	
	/* Copy the header */
	clen=(ipb->iph_0->version_IHL & 15) * 4; cbuf=(uchar*)(ipb->iph_0);
	buf=(uchar*)iph;
	while(clen--)
		*buf++=*cbuf++;
		
	uncat_ipb(ipb);
	
	return(buf_len);
}

void ip_in(void *buf, uint len)
{/* Queue incoming ip-fragments */
	ulong	bid[4];
	uint	ocrc, crc, data_len, data_start, siz;
	ip_header	liph, *iph=&liph;
	ip_buffer	*ipb;
	uchar			*data_buf, *a, *b;
	int				adjust_len=0;
	
	#ifdef iodebug 
		Dftext("[IP incoming]\r\n"); 
	#endif
	/* Copy IP-Header to local struct to avoid typecast in bytestream */
	/* Note that options are NOT COPIED! */
	siz=(int)sizeof(ip_header); a=(uchar*)buf; b=(uchar*)iph;
	while(siz--)
		*b++=*a++;
		
	/* Check len to make sure it's an ip-fragment */
	/* Note: Some hosts send IP fragments with a wrong total-len info
	   The fragment is two bytes larger, this looks like some sort of
	   wrong padding, so we tolerate a fragement up to four bytes larger
	   or shorter */
	if(iph->total_len != len)
	{
		#ifdef iodebug 
			Dftext("[IP warning: wrong len, dif ");
			Dfnumber(iph->total_len);
		#endif
/* We accept anything now. Oh, and btw, T-Online sucks big time
		if((len >= iph->total_len-4) && (len <= iph->total_len+4))
		{
			#ifdef iodebug 
				Dftext(", tolerated (+/- 4 Bytes)]\r\n");
			#endif
*/
			Dftext(", tolerated]\r\n");
			adjust_len=1;
			/* This flag will remind us of doing this:
				iph->total_len=len;
				we don't do it now, because we have to calc the header-
				checksum first */
/*
		}
		else
		{
			#ifdef iodebug 
				Dftext(", ERROR-dropping, len is: ");
				Dfnumber(len); Dftext(", should: ");
				Dfnumber(iph->total_len);
				Dftext("]\r\n"); 
			#endif
			return;	/* Error, len in header doesn't match buffer len */
		}
*/

	}
	
	if(iph->dst_ip != defaults.my_ip)
	{
		#ifdef iodebug 
			if(iph->src_ip == defaults.my_ip)
				Dftext("[IP dropping, packet returned, head:]\r\n");
			else
				Dftext("[IP dropping, wrong destination IP, head:]\r\n");
			Dfdump(buf, sizeof(ip_header));
			Dftext("[IP dropped header end]\r\n");
		#endif
		return;	/* This is not for me */
	}

	/* Checksum */
	siz=(iph->version_IHL & 15) * 2;
	ocrc=iph->crc;
	iph->crc=0;
	crc=calc_ip_crc(iph, siz);
	if(crc != ocrc)
	{
		#ifdef iodebug 
			Dftext("[IP dropping, wrong crc]\r\n"); 
		#endif
		return;	/* Error, wrong checksum */
	}

	if(adjust_len) iph->total_len=len;
	
	bid[0]=iph->src_ip; bid[1]=iph->dst_ip;
	bid[2]=iph->id;	bid[3]=iph->protocol;
	
	ipb=find_buffer_by_id(bid);
	data_buf=(uchar*)buf+(iph->version_IHL & 15)*4;
	data_len=len-(iph->version_IHL & 15)*4;
	data_start=(iph->flags_frag_off & 4095)*8;
	
/*	if(((iph->flags_frag_off & IP_FRAGOFF)== 0) && (!((iph->flags_frag_off>>13)& 4)))*/
	if(((iph->flags_frag_off & IP_FRAGOFF)== 0) && (!(iph->flags_frag_off & IP_MF)))
	{/* Single fragment */
		#ifdef iodebug 
			Dftext("[IP single process]\r\n"); 
		#endif
		if(ipb) uncat_ipb(ipb); /* If IP-Id in buffer-queue, delete it */
		if(iph->protocol==6) /* TCP */
		{
			#ifdef iodebug 
				Dftext("[IP passing to TCP] SRC-IP=");
				Dfdump((uchar*)(&(iph->src_ip)), 4);
				Dftext("\r\n"); 
			#endif
			tcp_in(data_buf, data_len, iph);
		}
		else if(iph->protocol==17) /* UDP */
		{
			#ifdef iodebug 
				Dftext("[IP passing to UDP]\r\n"); 
			#endif
			udp_in(data_buf, data_len, iph);
		}
		/* All other protocols are discarded or stored in RAW-buffer */
		else
		{
			#ifdef iodebug
				Dftext("[IP single raw, protocol ");	Dfnumber(iph->protocol); Dftext(":]\r\n");
			#endif
			ip_store_raw(data_buf, data_len);
		}
		return;
	}
	
	/* Process none single-fragment */
	#ifdef iodebug 
		Dftext("[IP non-single process]\r\n"); 
	#endif
	if(ipb==NULL) ipb=new_buffer(bid);
	if((ipb==NULL)||(cat_data_to_buf(ipb, data_buf, data_len, data_start) < 0))
	{
		#ifdef iodebug 
			Dftext("[IP dropping, no queue memory]\r\n"); 
		#endif
		return; /* Error, No memory */
	}

	if((iph->flags_frag_off & IP_FRAGOFF) == 0)
	{/* First fragment->store header in ip_buffer */
		#ifdef iodebug 
			Dftext("[IP first frag found, storing header]\r\n"); 
		#endif
		ipb->iph_0=(ip_header*)imalloc((iph->version_IHL&15)*4);
		if(ipb->iph_0 == NULL) return; /* Error, No memory */
		copy_header(ipb, iph);
	}

/*	if(!((iph->flags_frag_off >> 13) & 4))*/	/* Last fragment->Calc bytes to receive */
	if(!(iph->flags_frag_off & IP_MF))	/* Last fragment->Calc bytes to receive */
		ipb->to_receive=data_start+data_len;
	
	if((ipb->to_receive > 0) && (ipb->received == ipb->to_receive))
	{/* All fragments received */
		ipb->iph_0->total_len=ipb->received+(ipb->iph_0->version_IHL&15)*4;
		if(ipb->iph_0->protocol==6) /* TCP */
		{
			#ifdef iodebug 
				Dftext("[IP allfrag passing to TCP]\r\n"); 
			#endif
			tcp_in(ipb->buf, ipb->len, ipb->iph_0);
		}
		else if(ipb->iph_0->protocol==17) /* UDP */
		{
			#ifdef iodebug 
				Dftext("[IP allfrag passing to UDP]\r\n"); 
			#endif
			udp_in(ipb->buf, ipb->len, ipb->iph_0);
		}
		else
		{
			#ifdef iodebug
				Dftext("[IP allfrag raw, protocol ");	Dfnumber(iph->protocol); Dftext(":]\r\n");
			#endif
			ip_store_raw(data_buf, data_len);
		}

		uncat_ipb(ipb);
	}
}

void ip_timer_jobs(void)
{
	long			tim_sub;
	ip_buffer	*ipb=first_buf;
	localhost_queue **plhq=&first_lhqueue, *done;
	
/* Delete segments from the incoming queue that have timed out */
	tim_sub=CLK_TCK/defaults.clk_tck; /* Timer-Units to sub */
	while(ipb)
	{
		if(ipb->timer > -1) /* Timer is active */
		{
			ipb->timer-=tim_sub;
			if(ipb->timer <= 0) /* Timer has expired */
			{
				uncat_ipb(ipb);
				return;	/* Since ipb now points to nirvana...*/
			}
		}
		ipb=ipb->next;
	}	

	/*	Check for localhost blocks and receive them */
	#ifdef iodebug
		Dftext("[IP checking localhost queue]\r\n");
	#endif
	while(*plhq!=NULL)
	{
		ip_in((*plhq)->buf, (*plhq)->buf->total_len);
		done=*plhq;
		*plhq=(*plhq)->next;
		ifree(done);
	}
}

void ip_abort(void)
{/* Free all buffers */
	ip_buffer	*ipb=first_buf, *ib;
	localhost_queue *lhq=first_lhqueue, *lhq2;

	while(ipb)
	{
		if(ipb->buf)
			ifree(ipb->buf);
		ib=ipb->next;
		ifree(ipb);
		ipb=ib;
	}
	first_buf=NULL;

	while(lhq)
	{
		lhq2=lhq->next;
		ifree(lhq);
		lhq=lhq2;
	}
	first_lhqueue=NULL;
	
	if(raw_buf) ifree(raw_buf);
	raw_buf=NULL;
	raw_buf_len=0;
	store_raw=0;
}