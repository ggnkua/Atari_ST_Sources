#define iodebug

#include "network.h"
#include "ppp.h"
#include "pap.h"
#include "ipcp.h"

extern PPP_VALS ppp_vals;
/* PPP-automaton and actions*/

extern default_values defaults;


void ppp_tlu(void) /* This layer up */
{ 
	ppp_vals.ppp_up=1;
	ppp_vals.send_accm[0]=ppp_vals.mem_send_accm;
		
	if(defaults.ppp_authenticate)
		pap_start();
	else
		ipcp_start();
}
/* ------------------------------- */
void ppp_tld(void)	/* This layer down */
{
	defaults.ppp_suc=0;
}
/* ------------------------------- */
void ppp_tls(void)	/* This layer started */
{
	defaults.ppp_tls=1;
}
/* ------------------------------- */
void ppp_tlf(void)	/* This layer finished */
{
	defaults.ppp_tls=0;
}
/* ------------------------------- */
void ppp_irc(int irc_type)	/* Initiate restart counter */
{
	ppp_vals.restart_timer=defaults.ppp_default_timer;
	switch(irc_type)
	{
		case PPP_IRC_CONF:
			ppp_vals.restart_counter=defaults.ppp_max_configure;
		break;
		case PPP_IRC_TERM:
			ppp_vals.restart_counter=defaults.ppp_max_terminate;
		break;
	}
}
/* ------------------------------- */
void ppp_zrc(void)	/* Zero restart counter */
{/* If peer initiates shutdown, use timer to proceed from
		state STOPPING to STOPPED */
	ppp_vals.restart_counter=0;
	ppp_vals.restart_timer=defaults.ppp_terminate_timer;
}
/* ------------------------------- */
void ppp_scr(void)	/* Send configure request */
{
	lcp_header *lcp=(lcp_header*)(ppp_vals.send_req);
	
	lcp->identifier=++ppp_vals.sent_id; 
	--ppp_vals.restart_counter;
	ppp_send(PPP_PROTO_LCP,ppp_vals.send_req, ppp_vals.send_req_len);
}
/* ------------------------------- */
void ppp_sca(void) /* Send configure acknowledged */
{
	ppp_vals.failure_counter=defaults.ppp_max_failure;
	ppp_vals.recv_req[0]=LCP_CONF_ACK;
	ppp_send(PPP_PROTO_LCP,ppp_vals.recv_req, ppp_vals.recv_req_len);
}
/* ------------------------------- */
void ppp_scn(void)	/* Send configure not acknowledged or rejected */
{
	if(--ppp_vals.failure_counter < 0)
	{/* Too many nacks without an ack in between */
		ppp_automaton(PEV_ADMIN_CLOSE);
		return;
	}
	if(ppp_vals.nack_len)
		ppp_send(PPP_PROTO_LCP,ppp_vals.nack_buf, ppp_vals.nack_len);
	else
		ppp_send(PPP_PROTO_LCP,ppp_vals.rej_buf, ppp_vals.rej_len);
}
/* ------------------------------- */
void ppp_str(void)	/* Send terminate request */
{
	lcp_header term_buf;
	
	term_buf.code=LCP_TERM_REQ;
	term_buf.identifier=++ppp_vals.sent_id;
	term_buf.length=4;
	--ppp_vals.restart_counter;
	ppp_send(PPP_PROTO_LCP,(uchar*)(&term_buf), (uint)sizeof(term_buf));
}
/* ------------------------------- */
void ppp_sta(void)	/* Send terminate acknowledge */
{
	ppp_vals.recv_req[0]=LCP_TERM_ACK;
	ppp_send(PPP_PROTO_LCP,ppp_vals.recv_req, ppp_vals.recv_req_len);
}
/* ------------------------------- */
void ppp_scj(void)	/* Send code reject */
{
	defaults.ppp_crj_sent=1;
	ppp_send(PPP_PROTO_LCP,ppp_vals.crj_buf, ppp_vals.crj_len);
}
/* ------------------------------- */
void ppp_spj(uint protocol, uchar *buf, uint len)	/* Send protocol reject */
{
	uint				a;
	uchar 			sbuf[SBUF+sizeof(lcp_header)+sizeof(uint)];
	lcp_header	*lcp=(lcp_header*)(&sbuf);
	
	defaults.ppp_prj_sent=1;
	lcp->code=LCP_PROT_REJ;
	lcp->identifier=++(ppp_vals.sent_id);
	lcp->length=len+(uint)sizeof(lcp_header)+(uint)sizeof(uint);
	*(uint*)(&(sbuf[4]))=protocol;
	a=len;
	if(a > SBUF) a=SBUF;
	while(a--)	sbuf[a+sizeof(lcp_header)+sizeof(uint)]=buf[a];
	ppp_send(PPP_PROTO_LCP,sbuf, len+(uint)sizeof(lcp_header)+(uint)sizeof(uint));
}
/* ------------------------------- */
void ppp_seq(void)	/* Send echo request */
{
	uchar 			sbuf[sizeof(lcp_header)+sizeof(ulong)];
	lcp_header	*lcp=(lcp_header*)(&sbuf);
	
	lcp->code=LCP_ECHO_REQ;
	lcp->identifier=++ppp_vals.sent_id;
	lcp->length=(uint)sizeof(lcp_header)+(uint)sizeof(ulong);
	*(ulong*)(&(sbuf[4]))=ppp_vals.local_magic;
	ppp_send(PPP_PROTO_LCP,sbuf, (uint)sizeof(lcp_header)+(uint)sizeof(ulong));
}
/* ------------------------------- */
void ppp_ser(void)	/* Send echo reply */
{
	uint				a;
	uchar 			sbuf[SBUF+sizeof(lcp_header)+sizeof(ulong)];
	lcp_header	*lcp=(lcp_header*)(&sbuf);
	
	lcp->code=LCP_ECHO_REP;
	lcp->identifier=ppp_vals.recv_req[1];
	lcp->length=ppp_vals.recv_req_len+(uint)sizeof(lcp_header)+(uint)sizeof(ulong);
	*(ulong*)(&(sbuf[4]))=ppp_vals.local_magic;
	a=ppp_vals.recv_req_len;
	if(a > SBUF) a=SBUF;
	while(a--)	sbuf[a+sizeof(lcp_header)+sizeof(ulong)]=ppp_vals.recv_req[a];
	ppp_send(PPP_PROTO_LCP,sbuf, ppp_vals.recv_req_len+(uint)sizeof(lcp_header)+(uint)sizeof(ulong));
}

/* ------------------------------- */
/* ------------------------------- */

void ppp_automaton(int event)
{/* Process ppp-event 
		see RFC 1661 page 12 ff for details */

	#ifdef iodebug 
		Dftext("[Entering PPP automaton, event: "); 
		Dfnumber(event); Dftext(", ");
		Dftext("state "); Dfnumber(ppp_vals.state); Dftext("..."); 
	#endif		
	switch(event)
	{
		case PEV_LOW_UP:
			if(ppp_vals.state==PPP_INITIAL)
				ppp_vals.state=PPP_CLOSED;
			else if(ppp_vals.state==PPP_STARTING)
			{
				ppp_irc(PPP_IRC_CONF);
				ppp_scr();
				ppp_vals.state=PPP_REQ_SENT;
			}
			else
				++ppp_vals.illegals;
		break;
		case PEV_LOW_DOWN:
			switch(ppp_vals.state)
			{
				case PPP_CLOSED:
				case PPP_CLOSING:	ppp_vals.state=PPP_INITIAL;	break;
				case PPP_STOPPED:	ppp_tls(); ppp_vals.state=PPP_STARTING; break;
				case PPP_STOPPING: case PPP_REQ_SENT:
				case PPP_ACK_RCVD: case PPP_ACK_SENT: 
					ppp_vals.state=PPP_STARTING; break;
				case PPP_OPENED: ppp_tld(); break;
				default: ++ppp_vals.illegals; break;
			}
		break;
		case PEV_ADMIN_OPEN:
			switch(ppp_vals.state)
			{
				case PPP_INITIAL:	ppp_tls(); ppp_vals.state=PPP_STARTING; break;
				case PPP_CLOSED:
					ppp_irc(PPP_IRC_CONF);
					ppp_scr();
					ppp_vals.state=PPP_REQ_SENT;
				break;
				case PPP_CLOSING:	ppp_vals.state=PPP_STOPPING;	break;
				/* All other events: Don't change state */
			}
		break;
		case PEV_ADMIN_CLOSE:
			switch(ppp_vals.state)
			{
				case PPP_STARTING: ppp_tlf(); ppp_vals.state=PPP_INITIAL; break;
				case PPP_STOPPED: ppp_vals.state=PPP_CLOSED; 	break;
				case PPP_STOPPING: ppp_vals.state=PPP_CLOSING; break;
				case PPP_OPENED:
					ppp_tld();	/* No break here! */
				case PPP_REQ_SENT: case PPP_ACK_RCVD:
				case PPP_ACK_SENT:
					ppp_irc(PPP_IRC_TERM);
					ppp_str();
					ppp_vals.state=PPP_CLOSING;
				break;
			}
		break;

		case PEV_TIMEOUT_P:
			switch(ppp_vals.state)
			{
				case PPP_CLOSING:	case PPP_STOPPING: ppp_str();	break;
				case PPP_REQ_SENT:	case PPP_ACK_RCVD:
					ppp_scr();
					ppp_vals.state=PPP_REQ_SENT;
				break;
				case PPP_ACK_SENT: ppp_scr();	break;
				default:	++ppp_vals.illegals;	break;
			}
		break;
		case PEV_TIMEOUT_N:
			switch(ppp_vals.state)
			{
				case PPP_CLOSING: ppp_tlf(); ppp_vals.state=PPP_CLOSED; break;
				case PPP_STOPPING: 	case PPP_REQ_SENT:
				case PPP_ACK_RCVD:	case PPP_ACK_SENT:
					ppp_tlf(); ppp_vals.state=PPP_STOPPED; break;
				default: ++ppp_vals.illegals; break;
			}
		break;

		case PEV_RCR_P:
			switch(ppp_vals.state)
			{
				case PPP_CLOSED: ppp_sta(); break;
				case PPP_STOPPED: 
					ppp_irc(PPP_IRC_CONF); ppp_scr(); ppp_sca();
					ppp_vals.state=PPP_ACK_SENT;
				break;
				case PPP_CLOSING:	case PPP_STOPPING: break;	/* Stay in state */
				case PPP_ACK_RCVD:
					ppp_sca(); ppp_vals.state=PPP_OPENED; ppp_tlu(); 
				break;
				case PPP_OPENED:	/* Open and Req ok->send ack and wait for IPCP */
					ppp_sca();
				break;
				/* Original: */
				/*	ppp_tld(); ppp_scr();	*/
					/* No break here! */
				case PPP_REQ_SENT: case PPP_ACK_SENT:
					ppp_sca(); ppp_vals.state=PPP_ACK_SENT;
				break;
				default: ++ppp_vals.illegals; break;
			}
		break;
		case PEV_RCR_N:
			switch(ppp_vals.state)
			{
				case PPP_CLOSED: ppp_sta(); break;
				case PPP_STOPPED:
					ppp_irc(PPP_IRC_CONF); ppp_scr(); ppp_scn();
					ppp_vals.state=PPP_REQ_SENT;
				break;
				case PPP_CLOSING: case PPP_STOPPING: break; /* Stay */
				case PPP_ACK_RCVD: ppp_scn(); break;
				case PPP_OPENED:
					ppp_tld(); ppp_scr();	/* No break here! */
				case PPP_REQ_SENT: case PPP_ACK_SENT:
					ppp_scn(); ppp_vals.state=PPP_REQ_SENT;
				break;
				default: ++ppp_vals.illegals; break;
			}
		break;
		case PEV_RCA:
			switch(ppp_vals.state)
			{
				case PPP_CLOSED: case PPP_STOPPED:	ppp_sta(); break;
				case PPP_CLOSING:	case PPP_STOPPING: break; /* Stay */
				case PPP_REQ_SENT: ppp_irc(PPP_IRC_CONF); ppp_vals.state=PPP_ACK_RCVD; break;
				case PPP_ACK_SENT: ppp_vals.state=PPP_OPENED; ppp_tlu(); break;
				case PPP_OPENED: ppp_tld(); /* No break here! */
				case PPP_ACK_RCVD: ppp_scr(); ppp_vals.state=PPP_REQ_SENT; break;
				default: ++ppp_vals.illegals; break;
			}
		break;
		case PEV_RCN:
			switch(ppp_vals.state)
			{
				case PPP_CLOSED: case PPP_STOPPED:	ppp_sta(); break;
				case PPP_CLOSING:	case PPP_STOPPING: break; /* Stay */
				case PPP_REQ_SENT: case PPP_ACK_SENT: 
					ppp_irc(PPP_IRC_CONF); ppp_scr(); break;
				case PPP_OPENED: ppp_tld(); /* No break here! */
				case PPP_ACK_RCVD: ppp_scr(); ppp_vals.state=PPP_REQ_SENT; break;
				default: ++ppp_vals.illegals; break;
			}
		break;

		case PEV_RTR:
			switch(ppp_vals.state)
			{
				case PPP_CLOSED: case PPP_STOPPED:	
				case PPP_CLOSING:	case PPP_STOPPING: 
					ppp_sta(); break;
				case PPP_REQ_SENT: case PPP_ACK_RCVD:
				case PPP_ACK_SENT:
					ppp_sta(); ppp_vals.state=PPP_REQ_SENT;	break;
				case PPP_OPENED:
					ppp_tld(); ppp_zrc(); ppp_sta();
					ppp_vals.state=PPP_STOPPING;
				break;
				default: ++ppp_vals.illegals; break;
			}
		break;
		case PEV_RTA:
			switch(ppp_vals.state)
			{
				case PPP_ACK_SENT: case PPP_REQ_SENT: 
				case PPP_CLOSED: case PPP_STOPPED: break;	/* Stay */
				case PPP_CLOSING: ppp_tlf(); ppp_vals.state=PPP_CLOSED;	break;
				case PPP_STOPPING: ppp_tlf(); ppp_vals.state=PPP_STOPPED; break;
				case PPP_OPENED: ppp_tld();	/* No break here! */
				case PPP_ACK_RCVD: ppp_vals.state=PPP_REQ_SENT;	break;
				default: ++ppp_vals.illegals; break;
			}
		break;

		case PEV_RUC:
			switch(ppp_vals.state)
			{
				case PPP_INITIAL: case PPP_STARTING:
					++ppp_vals.illegals; break;
				default: 
					ppp_scj();	break;
			}
		break;
		case PEV_RXJ_P:
			switch(ppp_vals.state)
			{
				case PPP_INITIAL: case PPP_STARTING:
					++ppp_vals.illegals; break;
				case PPP_ACK_RCVD:
					ppp_vals.state=PPP_REQ_SENT; break;
				/* All other states: Stay */
			}
		break;
		case PEV_RXJ_N:
			switch(ppp_vals.state)
			{
				case PPP_CLOSED:	case PPP_CLOSING:
					ppp_tlf(); ppp_vals.state=PPP_CLOSED; break;
				case PPP_STOPPED:	case PPP_STOPPING:
				case PPP_REQ_SENT: case PPP_ACK_RCVD:
				case PPP_ACK_SENT:
					ppp_tlf(); ppp_vals.state=PPP_STOPPED;
				break;
				case PPP_OPENED:
					ppp_tld(); ppp_irc(PPP_IRC_TERM); ppp_str();
					ppp_vals.state=PPP_STOPPING;
				break;
				default: ++ppp_vals.illegals; break;
			}
		break;

		case PEV_RXR:
			switch(ppp_vals.state)
			{
				case PPP_INITIAL: case PPP_STARTING:
					++ppp_vals.illegals; break;
				case PPP_OPENED:
					ppp_ser(); 	break;
				/* All other states: Stay */
			}
		break;
	}

	#ifdef iodebug 
		Dftext("leaving in state "); Dfnumber(ppp_vals.state); Dftext("]\r\n"); 
	#endif		
}
/* ------------------------------- */
