/* This function handles a close request from above (the dialer?) */
/* Only handled by LCP currently */
#include <time.h>
#include "lattice.h"
#include "krmalloc.h"
#include "globdefs.h"
#include "globdecl.h"
#include "ppp.h"
#include "ppp.p"

extern clock_t time_out_cnt;
extern UBYTE current_id;
extern UWORD protocol_id[];
extern CONFIG config;
extern BOOLEAN rx_pfc_on, tx_pfc_on;
extern BOOLEAN rx_acfc_on, tx_acfc_on;

void s9close(STATE_DATA *state, UBYTE *new_msg, UWORD protocol_offset)
{
	GPKT *term_req;
	LCP_HEADER *lcp_tptr;
	(void) new_msg;

	/* Get a buffer to transmit the terminate request */
	term_req = allocate_packet((UWORD) sizeof(LCP_HEADER));
	if (!term_req)
		return;

	term_req->ip_len = (UWORD) sizeof(LCP_HEADER);
	term_req->protocol = protocol_id[protocol_offset];

	/* Fill out the LCP header */
	lcp_tptr = (LCP_HEADER *)(term_req->pip);
	lcp_tptr->code = TERMINATE_REQUEST;
	lcp_tptr->identifier = GET_UNIQUE_ID;
	lcp_tptr->length = (UWORD) sizeof(LCP_HEADER);

	/* Send the terminate request */
	output_packet(term_req);

	/* Put us back into the starting state */
	state->cur_state[IPCP_OFFSET] = S6;
	state->cur_state[LCP_OFFSET] = S6;
	state->cur_state[PAP_OFFSET] = S8;

	/* Reset our data */
	state->magic_number = 0;
	state->auth_prot = 0;
	state->send_opt[IPCP_OFFSET] = DEFAULT_IPCP_SENDOPT;
	state->send_opt[LCP_OFFSET] = DEFAULT_LCP_SENDOPT;
	state->send_opt[PAP_OFFSET] = DEFAULT_PAP_SENDOPT;
	state->req_mru = DEFAULT_MRU;
	state->req_accm = 0;
	state->req_magicnum = DEFAULT_MAGNUM;
	state->req_local_ip = config.client_ip;

	/* Turn compression back on in case it was negotiated off */
	state->send_opt[LCP_OFFSET] |= 
			(1 << PROTOCOL_FLD_COMPRESSION_ID) |
			(1 << ADDR_AND_CTRL_FLD_COMP_ID);

	/* IP Compression added here when we support it
	state_info.send_opt[IPCP_OFFSET] |=
				(1 << IP_COMPRESSION_PROTOCOL); */

	/* Shut off compression */
	tx_acfc_on = rx_acfc_on = FALSE;
	tx_pfc_on = rx_pfc_on = FALSE;

	/* Reset the timer */
	time_out_cnt = 0;
} /* s9close() */
