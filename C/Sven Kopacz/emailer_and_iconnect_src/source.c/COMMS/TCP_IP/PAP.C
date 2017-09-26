#define iodebug

#include <string.h>
#include "network.h"
#include "ppp.h"
#include "ipcp.h"
#include "pap.h"

extern PPP_VALS ppp_vals;
extern default_values defaults;

/* ------------------------------- */
void pap_start(void)
{
	init_pap_request_buffer();
	ppp_vals.restart_timer=defaults.ppp_default_timer;
	ppp_vals.restart_counter=defaults.ppp_max_configure;
	pap_ppp_scr();
}
/* ------------------------------- */
void pap_resend(void)
{
	init_pap_request_buffer();
	pap_ppp_scr();
}
/* ------------------------------- */
void pap_conf_timeout(void)
{
	#ifdef iodebug
		Dftext("[PAP timeout in configuring]\r\n");
	#endif
	ppp_automaton(PEV_ADMIN_CLOSE);
}
/* ------------------------------- */
void pap_ppp_scr(void)	/* Send configure request */
{
	lcp_header *lcp=(lcp_header*)(ppp_vals.send_req);
	
	lcp->identifier=++ppp_vals.sent_id; 
	--ppp_vals.restart_counter;
	ppp_send(PPP_PROTO_PAP,ppp_vals.send_req, ppp_vals.send_req_len);
}
/* ------------------------------- */
/* ------------------------------- */
void pap_process(uchar *buf, uint len)
{/* Process an incoming pap-packet */

	#ifdef iodebug 
		Dftext("[PAP in, code: ");	Dfnumber(buf[0]);	Dftext("]\r\n"); 
	#endif
	if(ppp_vals.state != PPP_OPENED)
	{
		#ifdef iodebug
			Dftext("[PAP dropping, PPP not up]\r\n");
		#endif
		return;
	}
	if(len < 2)
	{
		#ifdef iodebug
			Dftext("[PAP dropping, length failure]\r\n");
		#endif
		return;
	}
	
	switch(buf[0])	/* Code */
	{
		case PAP_AUTH_ACK:
			if(buf[1]!=ppp_vals.sent_id)
			{
				#ifdef iodebug
					Dftext("[PAP received wrong ID. Sent: ");
					Dfnumber(ppp_vals.sent_id);
					Dftext(" Recvd: ");
					Dfnumber(buf[1]);
					Dftext("..hhmmm..well, ACK is ACK]\r\n");
				#endif
				/* break; */ /* Hey, is that tolerant or what? */
			}
			defaults.ppp_authenticate=2;
			defaults.ppp_auth_nak=0;
			#ifdef iodebug
				Dftext("[PAP successfull, starting IPCP]\r\n");
			#endif
			ipcp_start();
		break;
		case PAP_AUTH_NACK:
			if(buf[1]!=ppp_vals.sent_id)
			{
				break;
			}
			defaults.ppp_auth_nak=1;
			#ifdef iodebug
				Dftext("[PAP NOT successfull, User/Pass not accepted]\r\n");
			#endif
		break;
		default:	/* Unknown code */
		#ifdef iodebug
			Dftext("[PAP dropping, unknown code]\r\n");
		#endif
		break;
	}
}
/* ------------------------------- */
/* ------------------------------- */
void	init_pap_request_buffer(void)
{
	lcp_header *lcp=(lcp_header*)(ppp_vals.send_req);

	#ifdef iodebug
		Dftext("[PAP setting up request, User: ");
		Dftext(defaults.ppp_auth_user);
		Dftext(", Pass: ");
		Dftext(defaults.ppp_auth_pass);
		Dftext("]\r\n");
	#endif
	
	lcp->code=PAP_AUTH_REQ;
	lcp->identifier=ppp_vals.sent_id; /* Will be overwritten by ppp_scr */
	lcp->length=4+1+(int)strlen(defaults.ppp_auth_user)+1+(int)strlen(defaults.ppp_auth_pass);
	 /* =LCP-Header+Stringlens+Strings */
	
	ppp_vals.send_req[4]=(uchar)strlen(defaults.ppp_auth_user);
	strcpy((char*)&(ppp_vals.send_req[5]), defaults.ppp_auth_user);
	ppp_vals.send_req[5+ppp_vals.send_req[4]]=(uchar)strlen(defaults.ppp_auth_pass);
	strcpy((char*)&(ppp_vals.send_req[6+ppp_vals.send_req[4]]), defaults.ppp_auth_pass);
	
	ppp_vals.send_req_len=lcp->length;
}
