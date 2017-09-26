#define iodebug

#include "network.h"
#include "ipcp.h"
#include "ppp.h"

extern PPP_VALS ppp_vals;
extern default_values defaults;

/* ------------------------------- */
void ipcp_start(void)
{
	init_ipcp_request_buffer();
	ppp_vals.restart_timer=defaults.ppp_default_timer;
	ppp_vals.restart_counter=defaults.ppp_max_configure;
	ipcp_ppp_scr();
}
/* ------------------------------- */
void ipcp_resend(void)
{
	init_ipcp_request_buffer();
	ipcp_ppp_scr();
}
/* ------------------------------- */
void ipcp_conf_timeout(void)
{
	#ifdef iodebug
		Dftext("[IPCP timeout in configuring]\r\n");
	#endif
	ppp_automaton(PEV_ADMIN_CLOSE);
}
/* ------------------------------- */
void ipcp_ppp_scr(void)	/* Send configure request */
{
	lcp_header *lcp=(lcp_header*)(ppp_vals.send_req);
	
	lcp->identifier=++ppp_vals.ipcp_sent_id; 
	--ppp_vals.restart_counter;
	ppp_send(PPP_PROTO_IPCP,ppp_vals.send_req, ppp_vals.send_req_len);
}
/* ------------------------------- */
void ipcp_ppp_sca(void) /* Send configure acknowledged */
{
	ppp_vals.failure_counter=defaults.ppp_max_failure;
	ppp_vals.recv_req[0]=LCP_CONF_ACK;
	ppp_send(PPP_PROTO_IPCP,ppp_vals.recv_req, ppp_vals.recv_req_len);
}
/* ------------------------------- */
void ipcp_ppp_scn(void)	/* Send configure not acknowledged or rejected */
{
	if(ppp_vals.nack_len)
		ppp_send(PPP_PROTO_IPCP,ppp_vals.nack_buf, ppp_vals.nack_len);
	else
		ppp_send(PPP_PROTO_IPCP,ppp_vals.rej_buf, ppp_vals.rej_len);
}
/* ------------------------------- */
void ipcp_ppp_scj(void)	/* Send code reject */
{
	defaults.ppp_crj_sent=1;
	ppp_send(PPP_PROTO_IPCP,ppp_vals.crj_buf, ppp_vals.crj_len);
}
/* ------------------------------- */
void ipcp_ppp_str(void)	/* Send terminate request */
{
	lcp_header term_buf;
	
	term_buf.code=LCP_TERM_REQ;
	term_buf.identifier=++ppp_vals.ipcp_sent_id;
	term_buf.length=4;
	--ppp_vals.restart_counter;
	ppp_send(PPP_PROTO_IPCP,(uchar*)(&term_buf), (uint)sizeof(term_buf));
}
/* ------------------------------- */
void ipcp_ppp_sta(void)	/* Send terminate acknowledge */
{
	ppp_vals.recv_req[0]=LCP_TERM_ACK;
	ppp_send(PPP_PROTO_IPCP,ppp_vals.recv_req, ppp_vals.recv_req_len);
}
/* ------------------------------- */
/* ------------------------------- */
void ipcp_process(uchar *buf, uint len)
{/* Process an incoming ipcp-packet */
	int res;
	
	#ifdef iodebug 
		Dftext("[IPCP in, code: ");	Dfnumber(buf[0]);	Dftext("]\r\n"); 
	#endif
	if(ppp_vals.state != PPP_OPENED)
	{
		#ifdef iodebug
			Dftext("[IPCP dropping, PPP not up]\r\n");
		#endif
		return;
	}
	
	switch(buf[0])	/* Code */
	{
		case LCP_CONF_REQ:
			ppp_vals.recv_req=buf;
			ppp_vals.recv_req_len=len;
			if((res=ipcp_check_request())==1)
			{
				ipcp_ppp_sca();	/* Send configure ack */
				ppp_vals.ipcp_ack_sent=1;
				if(ppp_vals.ipcp_ack_rcvd==1)
				{
					ppp_vals.ipcp_up=1;
					defaults.ppp_suc=1;
				}
			}
			else if(res==0)				ipcp_ppp_scn();	/* Send configure nack/rej */
			else	/* -1 = unknown code */
				ipcp_ppp_scj();
		break;
		case LCP_CONF_ACK:
			if(buf[1]!=ppp_vals.ipcp_sent_id)
			{
				#ifdef iodebug
					Dftext("[IPCP dropped-wrong ID. Sent: ");
					Dfnumber(ppp_vals.ipcp_sent_id);
					Dftext(" Recvd: ");
					Dfnumber(buf[1]);
					Dftext("]\r\n");
				#endif
				break;
			}
			ppp_vals.ipcp_ack_rcvd=1;
			if(ppp_vals.ipcp_ack_sent==1)
			{
				ppp_vals.ipcp_up=1;
				defaults.ppp_suc=1;
				ppp_vals.lcp_echo_timer=defaults.ppp_lcp_echo_sec*defaults.clk_tck;
				#ifdef iodebug
					Dftext("[IPCP happy]\r\n");
				#endif
			}
		break;
		case LCP_CONF_NACK:
			if(buf[1]!=ppp_vals.ipcp_sent_id)	break;
			ppp_vals.recv_req=buf;
			ppp_vals.recv_req_len=len;
			ipcp_check_nack();
			ipcp_ppp_scr();		break;
		case LCP_CONF_REJ:			if(buf[1]!=ppp_vals.ipcp_sent_id)	break;
			ppp_vals.recv_req=buf;
			ppp_vals.recv_req_len=len;
			ipcp_check_reject();
			ipcp_ppp_scr();		break;
		case LCP_TERM_REQ:
			ppp_vals.recv_req=buf;
			ppp_vals.recv_req_len=len;
			ipcp_ppp_sta();		break;
		case LCP_TERM_ACK:
			/* sent_id-check omitted, since it's not clear here if i sent 
				 a terminate request. And if so, where else should the ack
				 come from? I'm closing anyway, so just accept this ack */
			ppp_vals.ipcp_up=0;
			defaults.ppp_suc=0;		break;
		case LCP_CODE_REJ:
			/* Since this implementation is only using default codes,
				 this is a fatal error! */
			defaults.ppp_crj_recv=1;
			ppp_vals.ipcp_up=0;
			defaults.ppp_suc=0;
			ppp_automaton(PEV_RXJ_N);		break;
		default:	/* Unknown code */
			ppp_vals.recv_req=buf;
			ppp_vals.recv_req_len=len;
			ipcp_ppp_scj();		break;
	}
}
/* ------------------------------- */
/* ------------------------------- */
int	ipcp_check_request(void)
{/* Check the Conf-Req and return 1 if ok, else
		return 0 and make up rej packet in ppp_vals (no nack here) or
		return -1 and make up code reject packet */
		
	uint				len, count=(uint)sizeof(lcp_header), 
							rej_count=(uint)sizeof(lcp_header), 
							crj_count=(uint)sizeof(lcp_header),	copy;
	uchar				*opt_buf=ppp_vals.recv_req, id;
	lcp_header	*lcph=(lcp_header*)(ppp_vals.recv_req);
	int					res=1;

	#ifdef iodebug 
		Dftext("[IPCP checking Conf-Req..."); 
	#endif
	
	id=lcph->identifier;
	len=lcph->length;
	while(count < len)
	{
		switch(opt_buf[count])
		{
			case IPCPO_IP_ADDRESSES:	/* Very old server, eh? */
				#ifdef iodebug 
					Dftext("ADDRESSES-ok,"); 
				#endif
				/* Get IP addresses */
				defaults.my_ip=*(ulong*)(&(opt_buf[count+2+4]));
				defaults.peer_ip=*(ulong*)(&(opt_buf[count+2]));
			break;
			case IPCPO_IP_COMPRESS:	/* Reject */
				copy=0;
				while(copy < opt_buf[count+1])
					ppp_vals.rej_buf[rej_count++]=opt_buf[count+copy++];
				#ifdef iodebug 
					Dftext("COMPRESS-reject,"); 
				#endif
			break;
			case IPCPO_IP_ADDRESS:	/* Ok and store */
				#ifdef iodebug 
					Dftext("ADDRESS-ok,"); 
				#endif
				defaults.peer_ip=*(ulong*)(&(opt_buf[count+2]));
			break;
			case IPCPO_PRIMARY_DNS:	/* Hm, I should request it */
			/* Maybe the best guess is just to ack it */
				#ifdef iodebug 
					Dftext("PDNS-ok,"); 
				#endif
			break;

			case IPCPO_PRIMARY_NBNS:
			case IPCPO_SECONDARY_DNS:
			case IPCPO_SECONDARY_NBNS:
			/* Maybe the best guess is just to ack it */
				#ifdef iodebug 
					Dftext("OTHER DS-ok,"); 
				#endif
			break;
			default:
				copy=0;
				while(copy < opt_buf[count+1])
					ppp_vals.crj_buf[crj_count++]=opt_buf[count+copy++];
				#ifdef iodebug 
					Dftext("UCODE-crj,"); 
				#endif
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
	#ifdef iodebug 
		Dftext("Done]\r\n"); 
	#endif
	return(res);
}
/* ------------------------------- */
void ipcp_check_nack(void)
{/* Check nacked options and make up new request */
	uint				len, count=(uint)sizeof(lcp_header);
	uchar				*opt_buf=ppp_vals.recv_req;
	lcp_header	*lcph=(lcp_header*)(ppp_vals.recv_req);
	
	#ifdef iodebug 
		Dftext("[IPCP checking Conf-Nack..."); 
	#endif
	
	len=lcph->length;
	while(count < len)
	{
		switch(opt_buf[count])
		{
			case IPCPO_IP_ADDRESS:	/* This should give me my local address */
				#ifdef iodebug 
					Dftext("IP_ADDRESS,"); 
				#endif
				defaults.my_ip=*(ulong*)(&(opt_buf[count+2]));
			break;
			case IPCPO_PRIMARY_DNS:	/* This should give me the DNS address */
				#ifdef iodebug 
					Dftext("DNS,"); 
				#endif
				defaults.name_server_ip=*(ulong*)(&(opt_buf[count+2]));
			break;
			default:	/* Just ignore it */
				#ifdef iodebug 
					Dfnumber(opt_buf[count]); Dftext(","); 
				#endif
			break;
		}
		count+=opt_buf[count+1];
	}
	init_ipcp_request_buffer();
	#ifdef iodebug 
		Dftext("Done]\r\n"); 
	#endif
}
/* ------------------------------- */
void ipcp_check_reject(void)
{/* Check rejected options and make up new request */
	uint				len, count=(uint)sizeof(lcp_header);
	uchar				*opt_buf=ppp_vals.recv_req;
	lcp_header	*lcph=(lcp_header*)(ppp_vals.recv_req);
	
	#ifdef iodebug 
		Dftext("[IPCP checking Conf-Rej..."); 
	#endif
	
	len=lcph->length;
	while(count < len)
	{
		switch(opt_buf[count])
		{
			case IPCPO_IP_ADDRESSES:
				#ifdef iodebug 
					Dftext("IP_ADDRESS,"); 
				#endif
				ppp_vals.ipcp_use_address_req=-1;
				defaults.ipcp_address_rej=1;
			break;
			case IPCPO_IP_ADDRESS:	/* Damn, hopefully I got it from Option 1 or user gave it*/
				#ifdef iodebug 
					Dftext("IP_ADDRESS,"); 
				#endif
				ppp_vals.ipcp_use_address_req=0;
				defaults.ipcp_address_rej=1;
			break;
			case IPCPO_PRIMARY_DNS:	/* Hm...hopefully user gave it */
				#ifdef iodebug 
					Dftext("PRIMARY_DNS,"); 
				#endif
				ppp_vals.ipcp_use_dns_req=0;
				defaults.ipcp_dns_rej=1;
			break;
			default:	/* Just ignore it */
				#ifdef iodebug 
					Dfnumber(opt_buf[count]); Dftext(","); 
				#endif
			break;
		}
		count+=opt_buf[count+1];
	}
	init_ipcp_request_buffer();
	#ifdef iodebug 
		Dftext("Done]\r\n"); 
	#endif
}
/* ------------------------------- */
void	init_ipcp_request_buffer(void)
{
	lcp_header *lcp=(lcp_header*)(ppp_vals.send_req);
	
	lcp->code=LCP_CONF_REQ;
	lcp->identifier=ppp_vals.ipcp_sent_id; /* Will be overwritten by ipcp_scr */
	lcp->length=4; /* LCP-Header */
	
	if(ppp_vals.ipcp_use_address_req==1)
	{
		ppp_vals.send_req[lcp->length]=IPCPO_IP_ADDRESS;
		ppp_vals.send_req[lcp->length+1]=6;	/* Len */
		*(ulong*)(&(ppp_vals.send_req[lcp->length+2]))=defaults.my_ip;
		lcp->length+=6;
	}
	if(ppp_vals.ipcp_use_dns_req==1)
	{
		ppp_vals.send_req[lcp->length]=IPCPO_PRIMARY_DNS;
		ppp_vals.send_req[lcp->length+1]=6;	/* Len */
		*(ulong*)(&(ppp_vals.send_req[lcp->length+2]))=defaults.name_server_ip;
		lcp->length+=6;
	}
	
	if(ppp_vals.ipcp_use_address_req==0)
	{/* Use old style option IP Addresses */
		ppp_vals.send_req[lcp->length]=IPCPO_IP_ADDRESSES;
		ppp_vals.send_req[lcp->length+1]=10;	/* Len */
		*(ulong*)(&(ppp_vals.send_req[lcp->length+2]))=defaults.my_ip;
		*(ulong*)(&(ppp_vals.send_req[lcp->length+6]))=defaults.peer_ip;
		lcp->length+=10;
	}
	
	ppp_vals.send_req_len=lcp->length;
}
