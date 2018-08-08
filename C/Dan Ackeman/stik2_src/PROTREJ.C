/* This function sends a protocol or code reject */
#include "lattice.h"
#include <string.h>
#include "krmalloc.h"
#include "globdefs.h"
#include "globdecl.h"
#include "ppp.h"
#include "ppp.p"

extern UBYTE current_id;

void protocol_reject(UWORD protocol, UBYTE code, GPKT *data)
{
    GPKT *reject;
    PROT_REJ_HEADER *prej_hptr;
	(void) code;

    /* Grab the packet up front */
    reject = allocate_packet(data->ip_len + (UWORD) sizeof(PROT_REJ_HEADER));
    reject->protocol = LCP_PROTOCOL; /* Always LCP */
    reject->ip_len = data->ip_len + (UWORD)sizeof(PROT_REJ_HEADER);

        /* Fill out the header */
    prej_hptr = (PROT_REJ_HEADER *)(reject->pip);
    prej_hptr->base_header.code = PROTOCOL_REJECT;
    prej_hptr->base_header.identifier = GET_UNIQUE_ID;
    prej_hptr->base_header.length = reject->ip_len;
    prej_hptr->rej_protocol = protocol;

    /* Copy in the body */
    memcpy(reject->pip+sizeof(PROT_REJ_HEADER), data->pip, data->ip_len);

    /* Send the message */
    output_packet(reject);
} /* protocol_reject() */
