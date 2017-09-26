#define iodebug
#define piodebug

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <tos.h>
#include <atarierr.h>
#include <sockerr.h>
#include <lowlevel.h>

#include "network.h"
#include "ppp.h"
#include "fcs.h"
#include "pap.h"
#include "ipcp.h"

#define ADD_BLOCK 2048
/* Max. tries when Fwrite(ser.port) returns 0 */
/*#define MAX_NULL_TRY 50*/
#define MAX_NULL_TRY 2

extern void timer_malloc(void);
extern void check_malloc(void);

extern default_values defaults;

void		ip_in(uchar	*buf, uint len);


uchar		*ppp_in_buf=NULL;
ppp_buf *ppp_out_buf=NULL;
uint		ppp_in_len=0;

PPP_VALS	ppp_vals;

/* ------------------------------- */
void ppp_init(void)
{
	int a;

	ppp_in_buf=NULL;
	ppp_out_buf=NULL;
	ppp_in_len=0;

	ppp_vals.state=PPP_INITIAL;
	ppp_vals.ppp_up=0;
	ppp_vals.illegals=0;
	ppp_vals.hdlc_framing=1;
	ppp_vals.failure_counter=defaults.ppp_max_failure;
	ppp_vals.act_options=LCPO_DEFAULTS;
	ppp_vals.sent_id=0;
	ppp_vals.local_magic=0;
	ppp_vals.peers_magic=0;
	ppp_vals.recv_state=0;
	ppp_vals.recv_proto=0;
	ppp_vals.recv_len=0;
	ppp_vals.recv_left=0;
	ppp_vals.recv_bufoffset=0;
	ppp_vals.use_proto_comp=0;
	ppp_vals.use_addr_comp=0;
	
	MAP_ZERO(ppp_vals.send_accm);
	MAP_ZERO(ppp_vals.recv_accm);
	for(a=0; a < 0x20; ++a)
	{
		MAP_SET(ppp_vals.send_accm, a);
		MAP_SET(ppp_vals.recv_accm, a);
	}
	MAP_SET(ppp_vals.send_accm, HDLC_FLAG);
	MAP_SET(ppp_vals.send_accm, HDLC_ESC);
	ppp_vals.mem_send_accm=ppp_vals.send_accm[0];
	
	init_request_buffer(LCPO_DEFAULTS, MRU_DEFAULT);
	init_other_buffers();

	ppp_vals.ipcp_sent_id=0;
	ppp_vals.ipcp_ack_sent=0;
	ppp_vals.ipcp_ack_rcvd=0;
	ppp_vals.ipcp_up=0;
	ppp_vals.ipcp_use_address_req=1;
	ppp_vals.ipcp_use_dns_req=1;
}
/* ------------------------------- */

void init_other_buffers(void)
{
	lcp_header 	*lcp;

	lcp=(lcp_header*)(ppp_vals.nack_buf);
	lcp->code=LCP_CONF_NACK;
	lcp=(lcp_header*)(ppp_vals.rej_buf);
	lcp->code=LCP_CONF_REJ;
	lcp=(lcp_header*)(ppp_vals.crj_buf);
	lcp->code=LCP_CODE_REJ;
}
/* ------------------------------- */
void init_request_buffer(int options, int mru)
{/* Make up default request */
	lcp_header *lcp=(lcp_header*)(ppp_vals.send_req);
	
	lcp->code=LCP_CONF_REQ;
	lcp->identifier=ppp_vals.sent_id; /* Will be overwritten by ppp_scr */
	lcp->length=4; /* LCP-Header */
	
	if(options & (1<<LCPO_MRU))
	{	/* MRU */
		ppp_vals.send_req[lcp->length]=LCPO_MRU;
		ppp_vals.send_req[lcp->length+1]=4;	/* Len */
		*(int*)(&(ppp_vals.send_req[lcp->length+2]))=mru;
		lcp->length+=4;
	}
	if(options & (1<<LCPO_ACCM))
	{	/* ACCM */
		ppp_vals.send_req[lcp->length]=LCPO_ACCM;
		ppp_vals.send_req[lcp->length+1]=6;	/* Len */
		*(ulong*)(&(ppp_vals.send_req[lcp->length+2]))=ACCM_DEFAULT;
		lcp->length+=6;
	}
	if(options & (1<<LCPO_PROTO_COMP))
	{	/* Protocol Field compression */
		ppp_vals.send_req[lcp->length]=LCPO_PROTO_COMP;
		ppp_vals.send_req[lcp->length+1]=2;	/* Len */
		lcp->length+=2;
	}
	if(options & (1<<LCPO_ADDR_COMP))
	{	/* Adress and Control field compression */
		ppp_vals.send_req[lcp->length]=LCPO_ADDR_COMP;
		ppp_vals.send_req[lcp->length+1]=2;
		lcp->length+=2;
	}
	ppp_vals.send_req_len=lcp->length;
}
/* ------------------------------- */
void ppp_in(uchar *buf, uint len)
{
	if(ppp_vals.hdlc_framing)
		ppp_hdlc_in(buf, len);
	else
		ppp_nullframe_in(buf, len);
}
/* ------------------------------- */
void ppp_hdlc_in(uchar *buf, uint len)
{/* Get incoming bytes in hdlc_framing, remove FLAG at Start/End
		and do unescapes  */
	uchar	c, *temp;

	static int	bufsiz, hdlc_esc=0;
		
	#ifdef iodebug 	
		Dftext("[PPP HDLC-unframing ");Dfnumber(len);Dftext(" incoming Bytes...");
	#endif

	if(!ppp_in_buf)
	{ 
		ppp_in_buf=imalloc(len+ADD_BLOCK);
		if(!ppp_in_buf) 
		{
			#ifdef iodebug
			if(db_handle > -1) Dftext("[PPP HDLC dropping, no mem]\r\n");
			#endif
			return;
		}
		bufsiz=len+ADD_BLOCK;
	}
	else
	{
		if(ppp_in_len+len > bufsiz)
		{
			temp=imalloc(ppp_in_len+len+ADD_BLOCK);
			if(!temp)
			{
				#ifdef iodebug
					if(db_handle > -1) Dftext("[PPP HDLC dropping, no mem]\r\n");
				#endif
				return;
			}
			block_copy(temp, ppp_in_buf, ppp_in_len);
			ifree(ppp_in_buf);
			ppp_in_buf=temp;
			bufsiz=ppp_in_len+len+ADD_BLOCK;
		}
	}


	while(len--)
	{
		c=ppp_in_buf[ppp_in_len++]=*buf++;
		switch(c)
		{
			case HDLC_ESC:	/* Next char must be xored with HDLC_TRANS */
				hdlc_esc=HDLC_TRANS;
				--ppp_in_len;
			break;
			
			case HDLC_FLAG:	/* Starts a new block */
				--ppp_in_len;
				if((ppp_in_len > 3) && (hdlc_esc==0))
					ppp_hdlc_process(ppp_in_buf, ppp_in_len);
				hdlc_esc=0;
				ifree(ppp_in_buf);
				if(len)
				{	ppp_in_buf=imalloc(len+ADD_BLOCK);
					bufsiz=len+ADD_BLOCK;					}
				else
					ppp_in_buf=NULL;
				ppp_in_len=0;
			break;
			
			default:
				if((c < 0x20) && (MAP_ISSET(ppp_vals.recv_accm, c)))
				{/* This one is flagged in ACCM, just ignore it */
					--ppp_in_len;
					hdlc_esc=0;	/* Just in case it was set */
				}
				else if(hdlc_esc)
				{
					ppp_in_buf[ppp_in_len-1]^=hdlc_esc;
					hdlc_esc=0;
				}
			break;
		}
	}
	#ifdef iodebug
		Dftext("done:]\r\n");
		Dfdump(ppp_in_buf, ppp_in_len);
	#endif
}
/* ------------------------------- */
void ppp_hdlc_process(uchar *buf, uint len)
{ /* Process a hdlc frame without HDLC_FLAG at start or end */
	uint protocol;
	#ifdef iodebug
	uint gfcs;
		Dftext("[PPP HDLC processor received these bytes:]\r\n");
		Dfdump(buf, len);
		Dftext("\r\n[PPP HDCL processing...");
	/* Check for FCS */
	if((gfcs=pppfcs16( PPPINITFCS16, buf, len)) != PPPGOODFCS16 )
	{
			Dftext("Dropframe - FCS failure]\r\n"); 
			Dftext("[FCS is: "); Dfdump((uchar*)&gfcs, 2); 
			Dftext(" should: "); gfcs=PPPGOODFCS16; Dfdump((uchar*)&gfcs, 2);
			Dftext("]\r\n");
  	return;
  }
		Dftext("FCS ok,");
	#else
	if(pppfcs16( PPPINITFCS16, buf, len) != PPPGOODFCS16 )
		return;	/* FCS failure */
	#endif
	
	len-=2;	/* Cut off FCS */

	/* Check for compressed address and control field */
	if((buf[0]==HDLC_ADDR) && (buf[1]==HDLC_CTRL))
	{/* Adress and control exist - ignore */
		#ifdef iodebug
			Dftext("No ");
		#endif
		buf+=2; len-=2;
	}
	#ifdef iodebug
		Dftext("Addr-comp,");
	#endif

	/* Get protocol, the LSB is odd */
	protocol=0;
	do
	{
		protocol<<=8;
		protocol+=*buf;
		--len;
	}	while(!(*buf++ & 1));
	
	/* Final validity check on length */
	if(len < 3)
	{
		#ifdef iodebug 
			Dftext("Dropframe - Length failure]\r\n"); 
		#endif
		return;
	}
	
	/* Process PPP-packet */
	#ifdef iodebug
		Dftext("ok, passing to dispatcher]\r\n");
	#endif
	ppp_dispatch(protocol, buf, len);
}
/* ------------------------------- */
void ppp_nullframe_in(uchar *buf, uint len)
{/* Detects LCP, ICMP and IP on Nullframe-Links */
	uchar	c, *temp;

	static int	bufsiz;
	
	#ifdef iodebug
		Dftext("[PPP Nullframe in]\r\n");
	#endif
		
	if(!ppp_in_buf)
	{ 
		ppp_in_buf=imalloc(len+ADD_BLOCK);
		if(!ppp_in_buf) return;
		bufsiz=len+ADD_BLOCK;
	}
	else
	{
		if(ppp_in_len+len > bufsiz)
		{
			temp=imalloc(ppp_in_len+len+ADD_BLOCK);
			if(!temp) return;
			block_copy(temp, ppp_in_buf, ppp_in_len);
			ifree(ppp_in_buf);
			ppp_in_buf=temp;
			bufsiz=ppp_in_len+len+ADD_BLOCK;
		}
	}

	#ifdef iodebug 	
		Dftext("[PPP processing ");	Dfnumber(len);	Dftext(" incoming Bytes]\r\n"); 
	#endif

	while(len--)
	{
		c=ppp_in_buf[ppp_in_len++]=*buf++;
		if(ppp_vals.recv_state==0)
		{
			/* Add lower byte to protocol */
			ppp_vals.recv_proto<<=8; 
			ppp_vals.recv_proto+=c;	
			++(ppp_vals.recv_bufoffset);
			if(c & 1)	/* signals end of protocol */
				ppp_vals.recv_state=1;
		}
		else
		{/* Byte belongs to packet */
			if(ppp_vals.recv_proto!=0x21)	/* Not IP->MUST BE Config Proto */
			{ 
				switch(ppp_vals.recv_state)
				{
					case 1:	/* Receiving type byte, ignore */
						ppp_vals.recv_state=2;
					break;
					case 2:	/* Receiving length byte, including type and length */
						ppp_vals.recv_len=c;
						ppp_vals.recv_left=c-2;
						ppp_vals.recv_state=3;
					break;
					case 3:
						--(ppp_vals.recv_left);
					break;
				}
			}
			else	/* Icoming IP Packet */
			{
				switch(ppp_vals.recv_state)
				{
					case 1:	/* Ignore Version/IHL */
						ppp_vals.recv_state=11;
					break;
					case 11:	/* Ignore Type of Service */
						ppp_vals.recv_state=2;
					break;
					case 2:		/* Get MSB Length */
						ppp_vals.recv_len=((uint)c)<<8; 
						ppp_vals.recv_state=22;
					break;
					case 22:	/* Get LSB Length */
						ppp_vals.recv_len+=c;
						ppp_vals.recv_left=ppp_vals.recv_len-4;
						ppp_vals.recv_state=3;
					break;
					case 3:
						--(ppp_vals.recv_left);
					break;
				}
			}
		}
		
		if((ppp_vals.recv_state==3) && (ppp_vals.recv_left==0))
		{	/* Packet complete */
			#ifdef iodebug 
				Dftext("[PPP passing ");	Dfnumber(ppp_vals.recv_len+2);	Dftext(" Bytes to dispatcher]\r\n"); 
			#endif
			ppp_dispatch(ppp_vals.recv_proto, ppp_in_buf+ppp_vals.recv_bufoffset, ppp_vals.recv_len);
			ppp_vals.recv_state=0;
			ppp_vals.recv_bufoffset=0;
			ifree(ppp_in_buf);
			if(len)
			{	ppp_in_buf=imalloc(len+ADD_BLOCK);
				bufsiz=len+ADD_BLOCK;
			}
			else
				ppp_in_buf=NULL;
			ppp_in_len=0;
		}
	}
}
/* ------------------------------- */
void ppp_dispatch(uint protocol, uchar *buf, uint len)
{/* Buf contains only the information (and padding), NOT the
		protocol. len contains the buffer-size, which might include
		the padding-bytes. If so, IP datagrams will be dropped due to
		illegal length */

	#ifdef iodebug
		Dftext("[PPP dispatcher called...");
	#endif
			
	switch(protocol)
	{
		case PPP_PROTO_LCP:
			#ifdef iodebug
				Dftext("passing to LCP]\r\n");
			#endif
			ppp_lcp_process(buf, len);
		break;
		case PPP_PROTO_IPCP:
			#ifdef iodebug
				Dftext("passing to IPCP]\r\n");
			#endif
			ipcp_process(buf, len);
		break;
		case PPP_PROTO_IP:
			if(ppp_vals.state == PPP_OPENED)
			{
				#ifdef iodebug
					Dftext("passing to IP]\r\n");
				#endif
				ip_in(buf, len);
			}
			#ifdef iodebug
			else Dftext("PPP not opened, incoming IP-packet dropped]\r\n");
			#endif
		break;
		case PPP_PROTO_PAP:
			#ifdef iodebug
				Dftext("passing to PAP]\r\n");
			#endif
			pap_process(buf, len);		
		break;
		default:	/* Unknown protocol, send reject */
			#ifdef iodebug
				Dftext("Dropping, unknown Protocol: ");
				Dfnumber(protocol); Dftext("\r\n");
				Dfdump(buf, len);
				Dftext("\r\n]\r\n");
			#endif
			ppp_spj(protocol, buf, len);
		break;
	}
}
/* ------------------------------- */
void ppp_lcp_process(uchar *buf, uint len)
{/* Check lcp and create event for automaton */
	int res;
	#ifdef iodebug 
		Dftext("[LCP in, code: ");	Dfnumber(buf[0]);	Dftext("]\r\n"); 
	#endif
	switch(buf[0])	/* Code */
	{
		case LCP_CONF_REQ:
			ppp_vals.recv_req=buf;
			ppp_vals.recv_req_len=len;
			if((res=check_request())==1)
				ppp_automaton(PEV_RCR_P);
			else if(res==0)				ppp_automaton(PEV_RCR_N);
			else	/* -1 = unknown code */
				ppp_automaton(PEV_RUC);
		break;
		case LCP_CONF_ACK:
			if(buf[1]!=ppp_vals.sent_id)
			{
				#ifdef iodebug
					Dftext("[LCP dropped-wrong ID. Sent: ");
					Dfnumber(ppp_vals.sent_id);
					Dftext(" Recvd: ");
					Dfnumber(buf[1]);
					Dftext("]\r\n");
				#endif
				break;
			}
			ppp_vals.recv_req=buf;
			ppp_vals.recv_req_len=len;
			check_ack();
			ppp_automaton(PEV_RCA);		break;
		case LCP_CONF_NACK:
			if(buf[1]!=ppp_vals.sent_id)	break;
			ppp_vals.recv_req=buf;
			ppp_vals.recv_req_len=len;
			check_nack();
			ppp_automaton(PEV_RCN);		break;
		case LCP_CONF_REJ:			if(buf[1]!=ppp_vals.sent_id)	break;
			ppp_vals.recv_req=buf;
			ppp_vals.recv_req_len=len;
			check_reject();
			ppp_automaton(PEV_RCN);		break;
		case LCP_TERM_REQ:
			ppp_vals.recv_req=buf;
			ppp_vals.recv_req_len=len;
			ppp_automaton(PEV_RTR);		break;
		case LCP_TERM_ACK:
			/* sent_id-check omitted, since it's not clear here if i sent 
				 a terminate request. And if so, where else should the ack
				 come from? I'm closing anyway, so just accept this ack */
			ppp_automaton(PEV_RTA);		break;
		case LCP_CODE_REJ:
			/* Since this implementation is only using default codes,
				 this is a fatal error! */
			defaults.ppp_crj_recv=1;
			ppp_automaton(PEV_RXJ_N);		break;
		case LCP_PROT_REJ:			/* Since this implementation is only using IP,
				 this is a fatal error! */
			defaults.ppp_prj_recv=1;
			ppp_automaton(PEV_RXJ_N);		break;
		case LCP_ECHO_REQ:
			ppp_vals.recv_req=buf;
			ppp_vals.recv_req_len=len;
			ppp_automaton(PEV_RXR);		break;
		case LCP_ECHO_REP:
			/* Discarding this reply seems like the best guess.	*/		break;
		case LCP_DISC_REQ:
			/* Discard-request. No problem. */		break;
		default:	/* Unknown code */
			ppp_vals.recv_req=buf;
			ppp_vals.recv_req_len=len;
			ppp_automaton(PEV_RUC);		break;
	}
}
/* ------------------------------- */
ulong ulswap(ulong val)
{/* Swap the BIT-order of val */
	ulong new, a;
	
	new=0;
	for(a=0; a < 32; ++a)
		if(val & (1<<a))
			new|=(1<<(31-a));

	return(new);
}
/* ------------------------------- */
int	check_request(void)
{/* Check the Conf-Req and return 1 if ok, else
		return 0 and make up nack or rej packet in ppp_vals or
		return -1 and make up code reject packet */
		
	uint				len, count=(uint)sizeof(lcp_header), 
							rej_count=(uint)sizeof(lcp_header), nack_count=(uint)sizeof(lcp_header),
							crj_count=(uint)sizeof(lcp_header),	copy;
	uchar				*opt_buf=ppp_vals.recv_req, id;
	lcp_header	*lcph=(lcp_header*)(ppp_vals.recv_req);
	int					res=1;

	#ifdef iodebug 
		Dftext("[PPP checking Conf-Req..."); 
	#endif
	
	id=lcph->identifier;
	len=lcph->length;
	while(count < len)
	{
		switch(opt_buf[count])
		{
			case LCPO_RESERVED:	/* Ignore */
				#ifdef iodebug 
					Dftext("0,"); 
				#endif
			break;
			case LCPO_MRU:	
				/* Pass peers MRU to IP */
				if(defaults.MTU > get_uint(&(opt_buf[count+2])))
					defaults.MTU=get_uint(&(opt_buf[count+2]))-40;	
				/* Pass to TCP */
				if(defaults.snd_wnd > defaults.MTU-40)
					defaults.snd_wnd=defaults.MTU-40;	/* conservative assumption / RFC 879 */
				
				#ifdef piodebug 
					Dftext("MRU "); Dfnumber(get_uint(&(opt_buf[count+2]))); Dftext("-ok,"); 
				#endif
			break;
			case LCPO_ACCM:	/* Accept */
				ppp_vals.mem_send_accm=ulswap(get_ulong(&(opt_buf[count+2])));
				#ifdef iodebug 
					Dftext("ACCM-ok,"); 
				#endif
			break;
			case LCPO_AUTH:	/* Accept or Nak (by protocol) */
				if(get_uint(&(opt_buf[count+2]))==PPP_PROTO_PAP)	/* Accept */
				{
					#ifdef iodebug 
						Dftext("AUTH-ok,"); 
					#endif
					defaults.ppp_authenticate=1;
					break;
				}
				/* Nak -> Send PAP-Request */
				/*copy=0;
					while(copy < opt_buf[count+1])
						ppp_vals.nack_buf[nack_count++]=opt_buf[count+copy++]; */
				ppp_vals.nack_buf[nack_count++]=3;	/* Auth-protocol */
				ppp_vals.nack_buf[nack_count++]=4;	/* len */
				ppp_vals.nack_buf[nack_count++]=0xc0;	/* c023=PAP */
				ppp_vals.nack_buf[nack_count++]=0x23;
				#ifdef iodebug 
					Dftext("AUTH-nak,"); 
				#endif
			break;
			case LCPO_QUALITY:	/* Reject */
				copy=0;
				while(copy < opt_buf[count+1])
					ppp_vals.rej_buf[rej_count++]=opt_buf[count+copy++];
				#ifdef iodebug 
					Dftext("QUAL-rej,"); 
				#endif
			break;
			case LCPO_MAGIC:	/* Reject */
				copy=0;
				while(copy < opt_buf[count+1])
					ppp_vals.rej_buf[rej_count++]=opt_buf[count+copy++];
				#ifdef iodebug 
					Dftext("MAGC-rej,"); 
				#endif
			break;
			case LCPO_PROTO_COMP:	/* Accept */
				ppp_vals.use_proto_comp=1;
				#ifdef iodebug 
					Dftext("PCMP-ok,"); 
				#endif
			break;
			case LCPO_ADDR_COMP:	/* Accept */
				ppp_vals.use_addr_comp=1;
				#ifdef iodebug 
					Dftext("ACMP-ok,"); 
				#endif
			break;
			case LCPO_NUM_MODE:			/* Reject */
			case LCPO_MULTI_MRRU:		/* Reject */
			case LCPO_MULTI_SHEAD:	/* Reject */
			case LCPO_MULTI_END:		/* Reject */
			case 23:							/* Workaround, unknown code */
				#ifdef iodebug 
					Dfnumber(opt_buf[count]); 
					Dftext("(UNUSED)-rej,");
				#endif
				copy=0;
				while(copy < opt_buf[count+1])
					ppp_vals.rej_buf[rej_count++]=opt_buf[count+copy++];
			break;
			default:
				/* Since this code-reject has never worked and	
					 replacing known but unused-code-replies with
					 configure-reject has always worked, we generally
					 use configure-reject now instead of code-reject
					 since it seems the better guess (although this is
					 not compliant with the ppp-rfc) */
				/* old code (code reject) */
				/*
				#ifdef iodebug
					Dfnumber(opt_buf[count]); Dftext("=");
				#endif
				copy=0;
				while(copy < opt_buf[count+1])
					ppp_vals.crj_buf[crj_count++]=opt_buf[count+copy++];
				#ifdef iodebug 
					Dftext("UCODE-crj,"); 
				#endif
				*/
				/* new code (configure reject) */
				#ifdef iodebug 
					Dfnumber(opt_buf[count]); 
					Dftext("(UNKNOWN)-rej,");
				#endif
				copy=0;
				while(copy < opt_buf[count+1])
					ppp_vals.rej_buf[rej_count++]=opt_buf[count+copy++];
			break;
		}
		count+=opt_buf[count+1];
	}

	if(crj_count > sizeof(lcp_header))
	{
		ppp_vals.nack_len=ppp_vals.rej_len=0;
		ppp_vals.crj_len=crj_count;
		((lcp_header*)(ppp_vals.crj_buf))->identifier=id;
		((lcp_header*)(ppp_vals.crj_buf))->length=crj_count;
		res=-1;
		#ifdef iodebug 
			Dftext("send crj,"); 
		#endif
	}
	else if(rej_count > sizeof(lcp_header))
	{
		ppp_vals.nack_len=ppp_vals.crj_len=0;
		ppp_vals.rej_len=rej_count;
		((lcp_header*)(ppp_vals.rej_buf))->identifier=id;
		((lcp_header*)(ppp_vals.rej_buf))->length=rej_count;
		res=0;
		#ifdef iodebug 
			Dftext("send rej,"); 
		#endif
	}
	else if(nack_count > sizeof(lcp_header))
	{
		ppp_vals.rej_len=ppp_vals.crj_len=0;
		ppp_vals.nack_len=nack_count;
		((lcp_header*)(ppp_vals.nack_buf))->identifier=id;
		((lcp_header*)(ppp_vals.nack_buf))->length=nack_count;
		res=0;
		#ifdef iodebug 
			Dftext("send nack,"); 
		#endif
	}
	#ifdef iodebug 
		Dftext("Done]\r\n"); 
	#endif
	return(res);
}
/* ------------------------------- */
void check_ack(void)
{/* Set acked parameters in ppp_vals */
	uint				len, count=(uint)sizeof(lcp_header);
	uchar				*opt_buf=ppp_vals.recv_req;
	lcp_header	*lcph=(lcp_header*)(ppp_vals.recv_req);
	
	#ifdef iodebug 
		Dftext("[PPP checking Conf-Ack..."); 
	#endif
	
	len=lcph->length;
	while(count < len)
	{
		switch(opt_buf[count])
		{
			case LCPO_RESERVED:	/* Ignore */
				#ifdef iodebug 
					Dftext("0,"); 
				#endif
			break;
			case LCPO_MRU:	/* Don't care about peers MRU */
				#ifdef iodebug 
					Dftext("MRU,"); 
				#endif
			break;
			case LCPO_ACCM:
				ppp_vals.recv_accm[0]=ulswap(get_ulong(&(opt_buf[count+2])));
				#ifdef iodebug 
					Dftext("ACCM,"); 
				#endif
			break;
			case LCPO_AUTH:	/* Hm... */
				#ifdef iodebug 
					Dftext("AUTH,"); 
				#endif
			break;
			case LCPO_QUALITY:	/* Hmmmm.... */
				#ifdef iodebug 
					Dftext("QUAL,"); 
				#endif
			break;
			case LCPO_MAGIC:	/* Err... */
				#ifdef iodebug 
					Dftext("MAGC,"); 
				#endif
			break;
			case LCPO_PROTO_COMP:	/* At last a good one! */
				/* ppp_vals.use_proto_comp=1; */ /* WRONG! An ACK means that the sender will now use compression! */
				#ifdef iodebug 
					Dftext("PCMP,"); 
				#endif
			break;
			case LCPO_ADDR_COMP:	/* Another one */
				/* ppp_vals.use_addr_comp=1; */ /* WRONG! An ACK means that the sender will now use compression! */
				#ifdef iodebug 
					Dftext("ACMP,"); 
				#endif
			break;
			default:	/* Should never get here */
				#ifdef iodebug 
					Dftext("UCODE,"); 
				#endif
			break;
		}
		count+=opt_buf[count+1];
	}
	#ifdef iodebug 
		Dftext("Done]\r\n"); 
	#endif
}
/* ------------------------------- */
void check_nack(void)
{/* Check nacked options and make up new request */
	uint				len, count=(uint)sizeof(lcp_header);
	uchar				*opt_buf=ppp_vals.recv_req;
	lcp_header	*lcph=(lcp_header*)(ppp_vals.recv_req);
	int					options, mru;
	
	#ifdef iodebug 
		Dftext("[PPP checking Conf-Nack..."); 
	#endif
	
	options=ppp_vals.act_options;
	mru=MRU_DEFAULT;
	
	len=lcph->length;
	while(count < len)
	{
		switch(opt_buf[count])
		{
			case LCPO_MRU:
				#ifdef iodebug 
					Dftext("MRU,"); 
				#endif
				mru=get_int(&(opt_buf[count+2]));
			break;
			case LCPO_ACCM:
				options&=(~(1<<LCPO_ACCM));
				#ifdef iodebug 
					Dftext("ACCM,"); 
				#endif
			break;
			case LCPO_PROTO_COMP:	/* Should arrive as rej, anyway remove from defaults */
				ppp_vals.use_proto_comp=0;
				options&=(~(1<<LCPO_PROTO_COMP));
				#ifdef iodebug 
					Dftext("PCMP,"); 
				#endif
			break;
			case LCPO_ADDR_COMP:	/* Should arrive as rej, anyway remove from defaults */
				ppp_vals.use_addr_comp=0;
				options&=(~(1<<LCPO_ADDR_COMP));
				#ifdef iodebug 
					Dftext("ACMP,"); 
				#endif
			break;
			default:	/* Just ignore it */
				#ifdef iodebug 
					Dfnumber(opt_buf[count]); Dftext(","); 
				#endif
			break;
		}
		count+=opt_buf[count+1];
	}
	ppp_vals.act_options=options;
	init_request_buffer(options, mru);
	#ifdef iodebug 
		Dftext("Done]\r\n"); 
	#endif
}
/* ------------------------------- */
void check_reject(void)
{/* Check rejected options and make up new request */
	uint				len, count=(uint)sizeof(lcp_header);
	uchar				*opt_buf=ppp_vals.recv_req;
	lcp_header	*lcph=(lcp_header*)(ppp_vals.recv_req);
	int					options, mru;
	
	#ifdef iodebug 
		Dftext("[PPP checking Conf-Rej..."); 
	#endif
	
	options=ppp_vals.act_options;
	mru=MRU_DEFAULT;
	
	len=lcph->length;
	while(count < len)
	{
		switch(opt_buf[count])
		{
			case LCPO_MRU:	/* Hm, peer shouldn't reject this.. */
				options&=(~(1<<LCPO_MRU));
				#ifdef iodebug 
					Dftext("MRU,"); 
				#endif
			break;
			case LCPO_ACCM:
				options&=(~(1<<LCPO_ACCM));
				#ifdef iodebug 
					Dftext("ACCM,"); 
				#endif
			break;
			case LCPO_PROTO_COMP:	/* Should arrive as rej, anyway remove from defaults */
				ppp_vals.use_proto_comp=0;
				options&=(~(1<<LCPO_PROTO_COMP));
				#ifdef iodebug 
					Dftext("PCMP,"); 
				#endif
			break;
			case LCPO_ADDR_COMP:	/* Should arrive as rej, anyway remove from defaults */
				ppp_vals.use_addr_comp=0;
				options&=(~(1<<LCPO_ADDR_COMP));
				#ifdef iodebug 
					Dftext("ACMP,"); 
				#endif
			break;
			default:	/* Just ignore it */
				#ifdef iodebug 
					Dfnumber(opt_buf[count]); Dftext(","); 
				#endif
			break;
		}
		count+=opt_buf[count+1];
	}
	ppp_vals.act_options=options;
	init_request_buffer(options, mru);
	#ifdef iodebug 
		Dftext("Done]\r\n"); 
	#endif
}
/* ------------------------------- */
void	ppp_sbuf_add_byte(uchar **sbuf, uint *len, uchar abyte, uint *fcs)
{/* Add byte <abyte> to <sbuf> escaping if neccessary 
		and correct <len>. Calculate new <fcs> if <fcs> != NULL */

	if(MAP_ISSET(ppp_vals.send_accm, abyte))
	{	
		**sbuf=HDLC_ESC;	*sbuf+=1;
		**sbuf=abyte ^ HDLC_TRANS; *sbuf+=1;
		*len+=2; }
	else
	{	
		**sbuf=abyte;	
		*sbuf+=1;
		*len+=1;	
	}
	
	if(fcs)	
		*fcs=pppfcs16(*fcs, &abyte, 1);
}

/* ------------------------------- */
int ppp_send(uint protocol, uchar *buf, uint len)
{/* Send buf of <protocol> on serial line via PPP
		Function will add PPP-protocol-header, escape all ACCM-chars,
		add FCS and hdlc-framing */
		
	ppp_buf **prev, *sb;
	uchar	*sbuf, *mbuf;
	uint	len2, blen=len, fcs;

	fcs=PPPINITFCS16;
	
	#ifdef iodebug	
		Dftext("[PPP sending]\r\n");
	#endif

	if(low_ready() != E_OK) 
	{
		#ifdef iodebug 
			Dftext("[PPP send dropping - port closed]\r\n"); 
		#endif
		return(ENETDOWN);
	}
	
	if((protocol!=PPP_PROTO_LCP) && (ppp_vals.state != PPP_OPENED))
	{
		#ifdef iodebug 
			Dftext("[PPP send dropping - PPP not up]\r\n"); 
		#endif
		return(ENETDOWN);
	}
	
	if((protocol==PPP_PROTO_IP) && (ppp_vals.ipcp_up!=1))
	{
		#ifdef iodebug 
			Dftext("[PPP send dropping - IPCP not up]\r\n"); 
		#endif
		return(ENETDOWN);
	}
	
	#ifdef iodebug	
		Dftext("[PPP send getting memory]\r\n"); 
	#endif
	/* Needed len worst case: 
		every char is escaped->len *2
		2 Bytes PPP-Protocol-Head  +2 escaped->+2
		5 Bytes hdlc Framing       +5 escaped->+5
		-----
		=len*2 +14
	*/
	mbuf=sbuf=tmalloc(len*2+14);
	if(!sbuf)
	{
		#ifdef iodebug	
			Dftext("[PPP send dropping - no memory]\r\n"); 
		#endif
		return(ENSMEM);
	}
	*sbuf++=HDLC_FLAG;
	len2=1;

	/* Address and Control-Field always on LCP, others only if
		 compression is turned off */
	if((protocol==PPP_PROTO_LCP) || (ppp_vals.use_addr_comp==0))
	{
		ppp_sbuf_add_byte(&sbuf, &len2, HDLC_ADDR, &fcs);
		ppp_sbuf_add_byte(&sbuf, &len2, HDLC_CTRL, &fcs);
	}
	
	/* PPP-Protocol always in 16 Bit on LCP, others only if
			compression is turned off or proto not compressible */
	if((protocol & 0xff00) || (protocol==PPP_PROTO_LCP) || (ppp_vals.use_proto_comp==0))
	{/* 16 Bit, copy in single bytes because of bus-error on 68000 */
		ppp_sbuf_add_byte(&sbuf, &len2, (uchar)(protocol>>8), &fcs);
		ppp_sbuf_add_byte(&sbuf, &len2, (uchar)(protocol & 0xff), &fcs);
	}
	else
	{/* 8 Bit*/
		ppp_sbuf_add_byte(&sbuf, &len2, (uchar)protocol, &fcs);
	}

	/* Calculate final fcs */
	fcs=pppfcs16(fcs, buf, len);
	
	/* Now copy escaping */		
	while(len--)
	{
		if(MAP_ISSET(ppp_vals.send_accm, *buf))
		{
			*sbuf++=HDLC_ESC;
			*sbuf++=*buf++ ^ HDLC_TRANS;
			len2+=2;
		}
		else
		{
			*sbuf++=*buf++;
			++len2;
		}
	}                  

	/* Add FCS (escaping) */
	fcs^=0xffff;																					/* Complement */
	ppp_sbuf_add_byte(&sbuf, &len2, (uchar)(fcs & 0xff), NULL);	/* Least first! */
	ppp_sbuf_add_byte(&sbuf, &len2, (uchar)(fcs>>8), NULL);
	
	/* Final Flag */
	*sbuf++=HDLC_FLAG;
	++len2;
	sbuf=mbuf;
	
	/* Cat to outgoing queue */
	while(!set_flag(PPP_SEM))
	{/* A user process could be waiting here or the kernel-server,
			if an incoming TCP-segment is answered immediately.
			Thus we have to perform the timer_malloc to prevent a
			deadlock.
			 */
			check_malloc();
	}
	
	prev=&ppp_out_buf;
	while(*prev)
		prev=&((*prev)->next);
	*prev=sb=(ppp_buf*)tmalloc(len2);
	if(sb==NULL)
	{
		#ifdef iodebug 
			Dftext("[PPP send dropping - no queue memory..."); 
		#endif
		clear_flag(PPP_SEM);
		ifree(mbuf);
		#ifdef iodebug 
			Dftext("ok]\r\n"); 
		#endif
		return(ENSMEM);
	}
	/* Fill buffer-data */
	sb->next=NULL;
	sb->len=len2;
	sb->buf=mbuf;
	clear_flag(PPP_SEM);
	return(blen);
}
/* ------------------------------- */
void ppp_out(void)
{/* Why is the output performed via a timed queue?
		Going from a users "send"-call to slip/ppp_out (via tcp_send
		and ip_send) would result in the user-process using the
		port_handle for output on the serial line. Since he didn't
		open it, he can not use it. */
		
/* Transmit first buffer from outgoing queue */
	uint	len;
	int		ioutlen, null_try=0;
	long	outlen;
	uchar	*buf;
	ppp_buf	*sb, *memo;
	
	if(ppp_out_buf==NULL)
		return;	/* Nothing to send */
	
	/* Something to send: Reset echo-timer (acts as keep-alive) */
	ppp_vals.lcp_echo_timer=defaults.ppp_lcp_echo_sec*defaults.clk_tck;
	
	#ifdef iodebug 
		Dftext("[PPP out starting..."); 
	#endif
	while(!set_flag(PPP_SEM)) timer_malloc();
	#ifdef iodebug	
		Dftext("ok]\r\n"); 
	#endif
	buf=ppp_out_buf->buf;
	len=ppp_out_buf->len;

	#ifdef iodebug	
		Dftext("[PPP-Output ");	Dfnumber(len);	Dftext(" Bytes..."); 
	#endif

	do
	{
		outlen=low_write(len, buf);
		ioutlen=(int)outlen;
		if(outlen==0)
		{
			timer_malloc();		/* Do something while waiting */
			++null_try;
			if(null_try >= MAX_NULL_TRY)
			{
				#ifdef iodebug 
					Dftext("0-write, aborting]\r\n"); 
				#endif
				clear_flag(PPP_SEM);
				return;
			}
		}
		if(outlen < 0)	/* Error on Fwrite, try again on next timer */
		{
			#ifdef iodebug 
				Dftext("error "); Dfnumber(outlen); Dftext("]\r\n"); 
			#endif
			clear_flag(PPP_SEM);
			return;
		}
		len-=ioutlen;
		buf+=ioutlen;
	}while(len > 0);

	#ifdef iodebug 
		Dftext("sent,"); 
	#endif
	
	/* All sent, delete buffer */
	buf=ppp_out_buf->buf;
	sb=ppp_out_buf->next;
	memo=ppp_out_buf;
	ppp_out_buf=sb;
	clear_flag(PPP_SEM);
	ifree(buf);
	ifree(memo);
	#ifdef iodebug 
		Dftext("ok]\r\n"); 
	#endif
}
/* ------------------------------- */
void ppp_timer_jobs(void)
{/* Poll serial Line */
	static	uchar	buf[1024];
	static	long	ierr;

	if(low_ready() != E_OK) return;

	/* Check timeout */
	if((ppp_vals.state==PPP_CLOSING)||(ppp_vals.state==PPP_STOPPING)||
		 (ppp_vals.state==PPP_REQ_SENT)||(ppp_vals.state==PPP_ACK_RCVD)||
		 (ppp_vals.state==PPP_ACK_SENT))
	{
		if(--ppp_vals.restart_timer <= 0)
		{
			#ifdef iodebug
				Dftext("[Timeout...");
			#endif
			ppp_vals.restart_timer=defaults.ppp_default_timer;
			if(--ppp_vals.restart_counter <= 0)
			{	
				#ifdef iodebug
				Dftext("TO-]\r\n");
				#endif
				ppp_automaton(PEV_TIMEOUT_N);	
			}
			else
			{	
				#ifdef iodebug
				Dftext("TO+]\r\n");
				#endif
				ppp_automaton(PEV_TIMEOUT_P);	
			}
		}
	}
	else if((ppp_vals.state==PPP_OPENED) && (ppp_vals.ipcp_up==0))
	{
		if(--ppp_vals.restart_timer <= 0)
		{
			ppp_vals.restart_timer=defaults.ppp_default_timer;
			if(--ppp_vals.restart_counter <= 0)
			{	
				if(defaults.ppp_authenticate==1)
					pap_conf_timeout();
				else
					ipcp_conf_timeout();	
			}
			else
			{	
				if(defaults.ppp_authenticate==1)
					pap_resend();
				else
					ipcp_resend();	
			}
		}
	}
	
	/* Connection up ? */
	if((ppp_vals.state==PPP_OPENED) && (ppp_vals.ipcp_up==1))	
	{
		if(--ppp_vals.lcp_echo_timer <= 0)
		{
			ppp_vals.lcp_echo_timer=defaults.ppp_lcp_echo_sec*defaults.clk_tck;
			ppp_seq();
		}
	}
	
	/* Send pending buffers */
	ppp_out();

	ierr=low_read(1024, buf);
	if(ierr <= 0) 
	{
		#ifdef iodebug	
		if(ierr<0)
		{	Dftext("[PPP error "); Dfnumber(ierr); Dftext(" reading from port]\r\n");}
		#endif
		return;
	}
		
	#ifdef piodebug 
		Dftext("[PPP read ");
		Dfnumber(ierr); 
		Dftext(" Bytes from port:]\r\n"); 
	#endif
		
	ppp_in(buf, (uint)ierr);

	/* Send pending buffers again, if automaton produced answer */
	ppp_out();

}
/* ------------------------------- */
void ppp_abort(void)
{
	/* Try to send all remaining buffers */
	/* Especially those TCP-reset that were initiated by
	   tcp_abort()! */
	int 			retry=0;
	ppp_buf 	old_first, *sb;

	ppp_str();	/* Send terminate request */
	
	while(ppp_out_buf != NULL)
	{
		old_first=*ppp_out_buf;
		ppp_out();
		iwait(ABORT_FREQ);
		if((ppp_out_buf) && (old_first.len==ppp_out_buf->len)&&(old_first.buf==ppp_out_buf->buf))
		{ /* Couldn't send, first buffer still same size */
			++retry;
			if(retry > ABORT_RETRY)
			{/* Must be something wrong with the port */
				immed_loop:
				if(ppp_out_buf != NULL)
				{/* Delete (all) pending send buffer(s) */
					if(ppp_out_buf->buf) ifree(ppp_out_buf->buf);
					sb=ppp_out_buf->next;
					ifree(ppp_out_buf);
					ppp_out_buf=sb;
					if(ABORT_IMMED) goto immed_loop;
				}
			}
		}
		else
			retry=0;
	}
	
	if(ppp_in_buf)
		ifree(ppp_in_buf);
	ppp_in_buf=NULL;
	ppp_in_len=0;
}