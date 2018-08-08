/* This function does two things.  It first builds a reject header and
   attaches the rejected option.  It then checks for any other rejectable
   options */
#include "lattice.h"
#include <string.h>
#include "krmalloc.h"
#include "globdefs.h"
#include "globdecl.h"
#include "ppp.h"
#include "ppp.p"

#include "display.h"

extern VALIDATE_TBL *check_cfg[];
extern UWORD protocol_id[];
extern UBYTE max_options[];
extern CONFIG config;

void send_cfg_reject(UBYTE *option, UBYTE id, WORD len_left,
					UWORD protocol_offset)
{
	LCP_HEADER *tx_lcp_hptr;
	GPKT *tx_buffer;
	UWORD opt_len;
	UBYTE *rej_ptr;
	VALIDATE_TBL *check_functions;
	UBYTE num_options;

	int i;

	/* Grab a TX buffer of maximum length */
	tx_buffer = allocate_packet(config.mtu);
	if (!tx_buffer)
		return;

	tx_buffer->protocol = protocol_id[protocol_offset];

	/* Get a pointer to the head of the message */
	tx_lcp_hptr = (LCP_HEADER *)(tx_buffer->pip);

	/* Set up the header */
	tx_lcp_hptr->code = CONFIGURE_REJECT;
	tx_lcp_hptr->identifier = id;
	opt_len = *(option + 1);
	tx_lcp_hptr->length = opt_len + (UWORD) sizeof(LCP_HEADER);

	/* Copy over the option */
	rej_ptr = (UBYTE *)(tx_lcp_hptr + 1);
	memcpy(rej_ptr, option, opt_len);
	rej_ptr += opt_len;

	/* Subtract the option length */
	len_left -= opt_len;

	/* Grab the next option */
	option += opt_len;

	/* Get the right check functions and the number of options */
	check_functions = check_cfg[protocol_offset];
	num_options = max_options[protocol_offset];

	/* Loop through the remaining options */
	while (len_left > 0)
	{
		/* Get the option length */
		opt_len = *(option + 1);

	    /* Make sure the type is something we support */
        if ((*option > num_options) || 
				(check_functions[*option].action == invalid_opt))
		{
			/* Copy over in the next rejectable option */
			tx_lcp_hptr->length += opt_len;
			memcpy(rej_ptr, option, opt_len);
			rej_ptr += opt_len;
		}

		/* Update the length and the pointer */
		len_left -= opt_len;
		option += opt_len;
	} /* while */

	/* Send the reject after setting the length */
	tx_buffer->ip_len = tx_lcp_hptr->length;
	output_packet(tx_buffer);
} /* send_cfg_reject() */