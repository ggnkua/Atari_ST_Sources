/* This function handles illegal codes received */

#include "lattice.h"
#include <string.h>
#include "krmalloc.h"
#include "globdefs.h"
#include "globdecl.h"
#include "ppp.h"
#include "ppp.p"

extern UBYTE current_id;

void code_reject(UWORD protocol, GPKT *data)
{
	GPKT *reject;
	LCP_HEADER *lcp_hptr;

	/* Grab a packet to send */
	reject = allocate_packet(data->ip_len + (int16) sizeof(LCP_HEADER));
	reject->protocol = protocol;
	reject->ip_len = data->ip_len + (UWORD)sizeof(LCP_HEADER);

	/* Fill out the LCP header */
	lcp_hptr =  (LCP_HEADER *)(reject->pip);
    lcp_hptr->code = CODE_REJECT;
    lcp_hptr->identifier = GET_UNIQUE_ID;
    lcp_hptr->length = reject->ip_len;

	/* Copy in the body */
    memcpy(reject->pip+sizeof(LCP_HEADER), data->pip, data->ip_len);

    /* Send the message */
    output_packet(reject);
} /* event_reject() */
