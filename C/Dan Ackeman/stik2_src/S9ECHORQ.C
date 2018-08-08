/* This function simply echos the received packet.  The only change is in
	the code field.  Currently only used by LCP */
#include "lattice.h"
#include <string.h>
#include "krmalloc.h"
#include "globdefs.h"
#include "globdecl.h"
#include "ppp.h"
#include "ppp.p"

#include "display.h"

extern UWORD protocol_id[];

void s9echoreq(STATE_DATA *state, GPKT *pkt)
{
	LCP_HEADER *rx_lcp_hptr;
	MAG_OPT *magic_num_ptr;

	/* Get a pointer to the received message */
	rx_lcp_hptr = (LCP_HEADER *)(pkt->pip);

	/* Change the type */
	rx_lcp_hptr->code = ECHO_REPLY;
	
	/* Put in our magic number */
	magic_num_ptr = (MAG_OPT *)(rx_lcp_hptr + 1);
	magic_num_ptr->magic_num = state->magic_number;

	/* Send it */
	output_packet(pkt);
}

void s9echo_request(STATE_DATA *state, UBYTE *new_msg, UWORD protocol_offset)
{
	LCP_HEADER *tx_lcp_hptr, *rx_lcp_hptr;
	GPKT *echo_buffer;
	MAG_OPT *magic_num_ptr;

	/* Get a pointer to the received message */
	rx_lcp_hptr = (LCP_HEADER *)new_msg;

	/* Allocate a packet */
	echo_buffer = allocate_packet(rx_lcp_hptr->length);

	if (!echo_buffer)
	{
		disp_info("allocate packet failed in s9echo_request");
		return;
	}
		
	echo_buffer->ip_len = rx_lcp_hptr->length;
	echo_buffer->protocol = (int16)protocol_id[protocol_offset];

	/* Get a pointer to the packet body */
	tx_lcp_hptr = (LCP_HEADER *)(echo_buffer->pip);

	/* Copy over the received to the transmit */
	memcpy((UBYTE *)tx_lcp_hptr, rx_lcp_hptr, rx_lcp_hptr->length);

	/* Change the type */
	tx_lcp_hptr->code = ECHO_REPLY;

	/* Put in our magic number */
	magic_num_ptr = (MAG_OPT *)(tx_lcp_hptr + 1);
	magic_num_ptr->magic_num = state->magic_number;

	/* Send it */
	output_packet(echo_buffer);
} /* s9echo_request() */