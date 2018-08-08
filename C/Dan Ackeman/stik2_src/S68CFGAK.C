/* This function handles a configuration ack for state 6 */
/* We verify the ack.  If anything is wrong with it, we just toss it and try
   again.  Contains the supporting table functions */
#include "lattice.h"
#include <time.h>
#include <stdio.h>
#include "globdefs.h"
#include "globdecl.h"
#include "stddef.h"
#include "ppp.h"
#include "ppp.p"

#include "display.h"

extern VALIDATE_TBL *verify_contents [];
extern UBYTE max_options[];
extern clock_t time_out_cnt;
extern ULONG rx_accm[];
extern CONFIG config;
extern BOOLEAN tx_pfc_on;
extern BOOLEAN tx_acfc_on;
extern UWORD neg_mru;

/********************* s68configure_ack() *******************************/
void s68configure_ack(STATE_DATA *state, UBYTE *new_msg, 
						UWORD protocol_offset)
{
	LCP_HEADER *rx_lcp_hptr;
	WORD len_count;
	UWORD opt_len;
	UBYTE *type;
	VALIDATE_TBL *verify_ftns;
	UBYTE max_num_options;

    /* First, grab the message from the structure */
    rx_lcp_hptr = (LCP_HEADER *)new_msg;

	if (config.reports == 1)
		disp_info("s68configure ack");


	/* Verify the ID */
	if (rx_lcp_hptr->identifier != state->identifier)
		return; /* Discard silently */

	/* Grab the correct verify function */
	verify_ftns = verify_contents[protocol_offset];
	max_num_options = max_options[protocol_offset];

    /* Record original length; decrement length as fields are checked */
    len_count = rx_lcp_hptr->length - (UWORD)sizeof(LCP_HEADER);

    /* Grab the first type field */
    type = (UBYTE *) (rx_lcp_hptr + 1);

    /* Now, loop through each field */
    while(len_count > 0)
	{
        /* Make sure the type is something we support */
        if ((*type > max_num_options) ||
			 ((verify_ftns[*type].action)(state, type) != OK))
	  	{
			/* If it's PAP, it doesn't matter - stupid non-LCP format */
			if (protocol_offset == PAP_OFFSET)
				break;
			else
			{
				if (config.reports == 1)
					disp_info("not pap in s68cfgak");

         		/* That's not what we asked for - discard it and wait for
               		time-out */
				return;
			}
		}

		/* Subtract the length of the option from the total length */
		opt_len =  *(type + 1);
		len_count -= opt_len;

		/* Grab the next option */
		type += opt_len;
	} /* while */

	/* If we get here, everything checked out */
	if (state->cur_state[protocol_offset] == S6)
	{
		state->cur_state[protocol_offset] = S7;
		time_out_cnt = Sclock();
	}
	else /* Must be all the way up */
	{
		state->cur_state[protocol_offset] = S9;
		start_next_protocol(state, protocol_offset);
	}

	if (config.reports == 1)
		disp_info("s68configure ack returning at end of routine");

} /* s68configure_ack() */


/***************************** verify_mru() *******************************/
/* Validates the MRU sent is the MRU received */
ULONG verify_mru(STATE_DATA *state, UBYTE *option_data)
{
	MRU_OPT *mru_ptr;

	/* Get a pointer to the received data */
	mru_ptr = (MRU_OPT *)option_data;

	/* Make sure what we sent was what we recieved. */
	if (mru_ptr->mru != state->req_mru)
		return FAIL;
		
	/* Record the MRU for allocation of packets */
	neg_mru = mru_ptr->mru;

	return OK;
}


/************************ verify_accm() **********************************/
/* Validates accm and copies it into the transmit map */
ULONG verify_accm(STATE_DATA *state, UBYTE *option_data)
{
	ACCM_OPT *rx_accm_ptr;

	/* Get a pointer to the data */
	rx_accm_ptr = (ACCM_OPT *)option_data;

	/* Verify it's what we sent */
	if (rx_accm_ptr->accm != state->req_accm)
		return FAIL;

	rx_accm[0] = rx_accm_ptr->accm;
	return OK;
} /* verify_accm() */



/***************************** verify_magicnum() ************************/
/* Verifies the magic number */
ULONG verify_magicnum(STATE_DATA *state, UBYTE *option_data)
{
	MAG_OPT *rx_mag;

	/* Get a pointer to the received option */
	rx_mag = (MAG_OPT *)option_data;

	/* Verify it */
	if (rx_mag->magic_num != state->req_magicnum)
		return FAIL;

	state->magic_number = rx_mag->magic_num;
	return OK;
} /* verify_magicnum() */


/************************* verify_ip_addr() **********************/
/* Just take whatever we received */
ULONG verify_ip_addr(STATE_DATA *state, UBYTE *option_data)
{
	IP_ADDR_OPT *address;

	/* Grab a pointer to the address */
	address = ((IP_ADDR_OPT *)option_data);

	/* Better be what we requested */
	if (state->req_local_ip != address->ip_address)
	{
		state->req_local_ip = address->ip_address = config.client_ip;
		return FAIL;
	}

	/* Must be OK - we've got our IP address */
	config.client_ip = address->ip_address;
	return OK;
} /* verify_ip_addr() */


/************************** generic_verify() **********************/
/* For protocols with no data fields in the ack (e.g. PAP) */
ULONG generic_verify(STATE_DATA *state, UBYTE *option_data)
{
	(void) state;
	(void) option_data;
	
	return OK;
} /* generic_verify() */


/************************ verify_pfc() ***************************/
/* Basically just turn on compression */
ULONG verify_pfc(STATE_DATA *state, UBYTE *option_data)
{
	(void) state;
	(void) option_data;
	
	tx_pfc_on = TRUE;
	return OK;
} /* verify_pfc() */


/************************ verify_acfc() ***************************/
/* Basically just turn on compression */
ULONG verify_acfc(STATE_DATA *state, UBYTE *option_data)
{
	(void) state;
	(void) option_data;
	
	tx_acfc_on = TRUE;
	return OK;
} /* verify_acfc() */
