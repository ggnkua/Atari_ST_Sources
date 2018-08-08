/* This function handles all terminate requests received - restarts
	negotiation */
#include "lattice.h"
#include <string.h>
#include <time.h>
#include "krmalloc.h"
#include "globdefs.h"
#include "globdecl.h"
#include "ppp.h"
#include "ppp.p"

extern clock_t time_out_cnt;
extern UWORD protocol_id[];

void sxterminate_request(STATE_DATA *state, UBYTE *new_msg,
						UWORD protocol_offset)
{
	LCP_HEADER *lcp_thptr, *rx_lcp_ptr;
	GPKT *term_ack;

	/* Get a pointer to the received message */
	rx_lcp_ptr = (LCP_HEADER *)new_msg;

	/* Get a buffer to transmit it */
	term_ack = allocate_packet(rx_lcp_ptr->length);
	if (!term_ack)
		return;

	term_ack->ip_len = (int16) sizeof(LCP_HEADER);
	term_ack->protocol = protocol_id[protocol_offset];

	/* Fill out the LCP header */
	lcp_thptr = (LCP_HEADER *)(term_ack->pip);
	memcpy((UBYTE *)lcp_thptr, new_msg, rx_lcp_ptr->length);
	lcp_thptr->code = TERMINATE_ACK;
	lcp_thptr->length = (int16) sizeof(LCP_HEADER);

	/* Send the message */
	output_packet(term_ack);
	
	/* Reset the timer if needed */
	if (state->cur_state[protocol_offset] == S9)
		time_out_cnt = 0;

	/* Go to starting state */
	state->cur_state[LCP_OFFSET] = S6;
	state->cur_state[IPCP_OFFSET] = S6;
	state->cur_state[PAP_OFFSET] = S8;
} /* sxterminate_request() */
