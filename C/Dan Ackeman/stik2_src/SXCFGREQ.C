/* This routine handles configure requests from the provider. */
/* Does two things - determines if we can support all of the requests
   then acks or nacks appropriately.  This file also contains the supporting
	table functions */
#include "lattice.h"
#include <time.h>
#include <string.h>
#include <stdlib.h>
#include <stddef.h>
#include <stdio.h>
#include "krmalloc.h"
#include "globdefs.h"
#include "globdecl.h"
#include "ppp.h"
#include "ppp.p"
#include "display.h"	/* for disp_info */

extern VALIDATE_TBL *check_cfg[];
extern CONFIG config;
extern ULONG tx_accm[];
extern ULONG rx_accm[];
extern UWORD protocol_id[];
extern UBYTE max_options[];
extern BOOLEAN rx_acfc_on, tx_acfc_on;
extern BOOLEAN rx_pfc_on, tx_pfc_on;
ULONG new_tx_accm=DEFAULT_ACCM;
static void set_new_accm(void);
extern void (*prot_kicker)(void);

/************************** sxconfigure_request() ********************/
void sxconfigure_request(STATE_DATA *state, UBYTE *new_msg,
						UWORD protocol_offset)
{
    LCP_HEADER *rx_lcp_hptr, *tx_lcp_hptr;
	GPKT *tx_buffer;
    WORD len_count;
	UWORD opt_len;
    UBYTE *type; /* Type field of option */
	VALIDATE_TBL *validate_ftns;
	UBYTE num_options;
	int i;

	/* If we're in state 9, we need to send a CFG request */
	if (state->cur_state[protocol_offset] == S9)
	{
/*		send_cfg_req(state, (UBYTE *)NULL, protocol_offset);
	I've moved the above to after the step down dan May 20 - 2000 */


		/* If it's LCP, we've had the rug ripped out from under us */
		if (protocol_offset == LCP_OFFSET)
		{
			/* I've added the following May 20, 2000 - Dan */
			state->cur_state[protocol_offset] = S6;
			/* The above line wasn't there and my understanding is that it should be */

			state->cur_state[IPCP_OFFSET] = S6;
			state->cur_state[PAP_OFFSET] = S8;
			tx_accm[0] = DEFAULT_ACCM;
			rx_accm[0] = 0xffffffffL;
			rx_acfc_on = rx_pfc_on = FALSE;
			tx_acfc_on = tx_pfc_on = FALSE;
			new_tx_accm = DEFAULT_ACCM;
		}
	
		send_cfg_req(state, (UBYTE *)NULL, protocol_offset);
	}

    /* First, grab the message from the structure */
    rx_lcp_hptr = (LCP_HEADER *)new_msg;

    /* Record original length; decrement length as fields are checked */
    len_count = rx_lcp_hptr->length - (UWORD)sizeof(LCP_HEADER);

    /* Grab the first type field */
    type = (UBYTE *) (rx_lcp_hptr + 1);

	/* Grab the correct functions and the maximun number of options */
	validate_ftns = check_cfg[protocol_offset];
	num_options = max_options[protocol_offset];

    /* Now, loop through each field */
    while(len_count > 0)
    {
 
        /* Make sure the type is something we support */
        if ((*type > num_options) ||
			 (validate_ftns[*type].action == invalid_opt))
	  	{
         	/* Go through the rest of the message to get all rejects */

			/* I've made the following changes May 31, 2000 - Dan */
			
/*			if(protocol_offset != LCP_OFFSET)
			{*/
				send_cfg_reject(type, rx_lcp_hptr->identifier, len_count,
							protocol_offset);
/*			}
			else
			{
				send_cfg_nak(state, type, rx_lcp_hptr->identifier, len_count,
								protocol_offset);
			}
*/			
			if (state->cur_state[protocol_offset] != S7)
				state->cur_state[protocol_offset] = S6;

			if (config.reports == 1)
				disp_info("sxconfigure request returning snd_cfg_reject");

			return;
		}

		/* Validate the value - appropriate values set inside valid_req_ftns */
		if (((validate_ftns + (*type))->action)(state, type) != OK)
		{
			/* I've made the following changes May 31, 2000 - Dan */
			
/*			if(protocol_offset != LCP_OFFSET)
			{*/		
				send_cfg_nak(state, type, rx_lcp_hptr->identifier, len_count,
								protocol_offset);
/*			}
			else
			{
				send_cfg_reject(type, rx_lcp_hptr->identifier, len_count,
							protocol_offset);
			}
*/
			if (state->cur_state[protocol_offset] != S7)
				state->cur_state[protocol_offset] = S6;

			if (config.reports == 1)
				disp_info("sxconfigure request returning snd_cfg_nak");

			return;
		}

		/* Subtract the length of the option from the total length */
		opt_len =  *(type + 1);
		len_count -= opt_len;

		/* Grab the next option */
		type += opt_len;
	} /* while */

	/* If we make it here, all must have been OK */
    /* Grab a transmit buffer of appropriate size */
    tx_buffer = allocate_packet(rx_lcp_hptr->length);
	tx_buffer->ip_len = rx_lcp_hptr->length;
	tx_buffer->protocol = protocol_id[protocol_offset];

	/* Get a pointer to the head of the message to send */
    tx_lcp_hptr = (LCP_HEADER *)(tx_buffer->pip);

	/* Copy over everything */
	memcpy(tx_buffer->pip, new_msg, rx_lcp_hptr->length);

	/* Set the new message type */
	tx_lcp_hptr->code = CONFIGURE_ACK;

	/* Queue it up */
	output_packet(tx_buffer);

	/* Set the (new) state */
	if (state->cur_state[protocol_offset] == S7)
	{
		state->cur_state[protocol_offset] = S9;
		start_next_protocol(state, protocol_offset);
	}
	else if (state->cur_state[protocol_offset] != S9)
		state->cur_state[protocol_offset] = S8;

/* This below is the old code.  Everything starting at the else
	above to this note is experimental - Dan May 20, 2000
	
	IT won't fix AG but it does allow me to watch what is going on
	without it going fatal at end.
	
	else
		state->cur_state[protocol_offset] = S8;
*/

	if (config.reports == 1)
		disp_info("sxconfigure request returning end of routine");

} /* sxconfigure_request() */


/******************** invalid_opt() ************************/
/* Option we don't support */
ULONG invalid_opt(STATE_DATA *state, UBYTE *option_data)
{
	(void) option_data;
	(void) state;
	
	return FAIL;
} /* invalid_opt() */


/*************************** validate_mru() *******************/
/* Verify that they're MRU is OK, and use it */
ULONG validate_mru(STATE_DATA *state, UBYTE *option_data)
{
	MRU_OPT *rx_mru;
	(void) state;

	/* For now, accept whatever it is.  Just hard code our own internal */
	/* value to the default if the receiver indicates a larget MRU */
	rx_mru = (MRU_OPT *)option_data;

	/* Set our configuration value appropriately */
/*	config.mtu = (rx_mru->mru > DEFAULT_MRU) ? DEFAULT_MRU:rx_mru->mru;*/

	/* I'm experimenting here, just accept what they want, stik shouldnt
		care */
	config.mtu = rx_mru->mru;
	config.mss = config.mtu - 40;

	return OK;
} /* validate_mru() */



/*********************** validate_accm() *********************/
/* We can take about anything here */
ULONG validate_accm(STATE_DATA *state, UBYTE *option_data)
{
	ACCM_OPT *rx_accm_opt;
	(void) state;

	/* Just copy it over - doesn't matter much to us */
	rx_accm_opt = (ACCM_OPT *)option_data;
	new_tx_accm = rx_accm_opt->accm;
	prot_kicker = set_new_accm;

	return OK;
} /* validate_accm() */

/************************ set_new_accm() ***********************/
/* This sets the new ACCM -after- the ack has been sent (I didn't
   want to set it every time in the ppp_out() loop) */
void set_new_accm(void)
{
	tx_accm[0] = new_tx_accm;
	prot_kicker = ppp_kicker;
}


/************************** validate_magicnum() *****************/
/* Take about anything as long as it's not ours */
ULONG validate_magicnum(STATE_DATA *state, UBYTE *option_data)
{
	MAG_OPT *rx_magopt;

/*	disp_info("validate_magicnum");
*/
	/* Get a pointer to the received option */
	rx_magopt = (MAG_OPT *)option_data;

	/* Verify it's not our default or one we've sent */
	if ((rx_magopt->magic_num == DEFAULT_MAGNUM) ||
		 (rx_magopt->magic_num == state->req_magicnum))
	{
		if (config.reports == 1)
			disp_info("failing magic number");

		/* Pick a new value - make it random */
		rx_magopt->magic_num += rand();
		return FAIL;
	}
	return OK;
} /* validate_magicnum() */



/*************************** validate_ispip() **************************/
/* Let the ISP be what it wants.  We'll just record it */
ULONG validate_ispip(STATE_DATA *state, UBYTE *option_data)
{
	(void) state;
	
/*	disp_info("validate_ispip");
*/
	/* Copy into config */
	config.provider = ((IP_ADDR_OPT *)(option_data))->ip_address;
	return OK;
} /* validate_ispip() */

/*************************** validate_auth() **********************/
ULONG validate_auth(STATE_DATA *state, UBYTE *option_data)
{
	AUTH_PROT_OPT	*rx_auth = (AUTH_PROT_OPT *) option_data;

/*	disp_info("validate_auth");
*/
	if (config.reports == 1)
		disp_info("auth_prot = %x",rx_auth->auth_prot);

	if (rx_auth->auth_prot != PAP_PROTOCOL )
	{
		if (config.reports == 1)
			disp_info("failing on auth_prot ! PAP");

		return FAIL;
	}

	state->auth_prot = rx_auth->auth_prot;

	return OK;
} /* validate_auth() */


/********************* validate_pfc() ***************************/
/* Only allow protocol field compression if we've sent it also */
ULONG validate_pfc(STATE_DATA *state, UBYTE *option_data)
{
	(void) option_data;

/*	disp_info("validate_pfc");
*/
	/* Check if we set the bit in oldmain.c */
	if (!((state->send_opt[LCP_OFFSET]) & 
			(1 << PROTOCOL_FLD_COMPRESSION_ID)))
	{
		if (config.reports == 1)
			disp_info("failing on PROTOCOL_FLD_COMPRESSION_ID");
		return FAIL;
	}
	rx_pfc_on = TRUE;
	return OK;
} /* validate_pfc() */


/********************* validate_acfc() ***************************/
/* Only allow address and control compression if we've sent it also */
ULONG validate_acfc(STATE_DATA *state, UBYTE *option_data)
{
	(void) option_data;
	
/*	disp_info("validate_acfc");
*/	
	/* Check if we set the bit in oldmain.c */
	if (!((state->send_opt[LCP_OFFSET]) & 
			(1 << ADDR_AND_CTRL_FLD_COMP_ID)))
	{
		if (config.reports == 1)
			disp_info("Failing on ADDR_AND_CTRL_FLD_COMP_ID");

		return FAIL;
	}
	
	rx_acfc_on = TRUE;
	return OK;
} /* validate_acfc() */
