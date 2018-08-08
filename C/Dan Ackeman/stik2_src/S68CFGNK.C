/* This function handles receiving a Nack in states 6 and 8 */
/* Contains the functions used in the reject and re-negotiation */
/* tables. */
#include "lattice.h"
#include <time.h>
#include "globdefs.h"
#include "globdecl.h"
#include "ppp.h"
#include "ppp.p"

extern NEGOTIATE_TBL *negot_params[];
extern NEGOTIATE_TBL *rejected[];
extern UBYTE max_options[];
extern clock_t time_out_cnt;
extern CONFIG config;

void sxconfigure_nack(STATE_DATA *state, UBYTE *new_msg,
					UWORD protocol_offset)
{
	LCP_HEADER *lcp_rhptr; /* Received LCP header pointer */
	NEGOTIATE_TBL *handler_ftns;
	WORD len_count; /* Length of received message */
	UWORD opt_len; /* Option length */
	UBYTE *type; /* Option type */
	UBYTE num_options;

	/* Grab the message from the raw bytes */
	lcp_rhptr = (LCP_HEADER *)new_msg;

	/* Record the original length; decrement length as fields checked */
	len_count = lcp_rhptr->length - (UWORD)sizeof(LCP_HEADER);

	if (config.reports == 1)
		disp_info("sxconfigure_nack routine");


	/* Verify the identifier */
	if (lcp_rhptr->identifier != state->identifier)
		return;

	/* Grab the first type field */
	type = (UBYTE *)(lcp_rhptr + 1);

	/* Grab the reject or nak function */
	if (lcp_rhptr->code == CONFIGURE_NACK)
		handler_ftns = negot_params[protocol_offset];
	else
		handler_ftns = rejected[protocol_offset];

	/* Find the number of options */
	num_options = max_options[protocol_offset];

	/* Now loop through each field */
	while (len_count > 0)
	{
		/* Make sure it's something we can negotiate */
		if (*type <= num_options)
			/* Change the entries in state data */
			(handler_ftns[*type].action)(state, type, protocol_offset);

		/* Grab the next option */
		opt_len = *(type + 1);
		type += opt_len;

		/* Decrement the loop count */
		len_count -= opt_len;
	} /* while */

	/* Let's send the (hopefully) new request */
	send_cfg_req(state, (UBYTE *)NULL, protocol_offset);

	/* If we're in S9 or S7 and receive Nack, go back to state 6 */
	if ((state->cur_state[protocol_offset] == S9) || 
				(state->cur_state[protocol_offset] == S7))
		state->cur_state[protocol_offset] = S6;

	/* Reset the timer */
	time_out_cnt = Sclock();
	
	if (config.reports == 1)
		disp_info("sxconfigure nack returning at end of routine");

} /* sxconfigure_nack() */


/************************** no_neg() ************************************/
/* Handles the case where we received a Nak on something we shouldn't
	have sent */
void no_neg(STATE_DATA *state, UBYTE *option_data,
				UWORD protocol_offset)
{
	/* Let's just grab the type and clear the state
	 	data.  This will prevent the option from being sent */
	state->send_opt[protocol_offset] &= 
						(UWORD)((0xffff) ^ (1 << *option_data));
} /* no_neg() */



/************************* new_mru() ***********************************/
/* Handles a new MRU (no problem - why would they Nak?) */
void new_mru(STATE_DATA *state, UBYTE *option_data,
				UWORD protocol_offset)
{
	MRU_OPT *nakked_mru;
	(void) protocol_offset;

	/* Get a pointer to the nak'd data */
	nakked_mru = (MRU_OPT*)(option_data);

	/* Copy and record the new MRU - don't accept it if it's too large,
        though */
	state->req_mru = (nakked_mru->mru > DEFAULT_MRU) ? DEFAULT_MRU : 
									nakked_mru->mru;
	nakked_mru->mru = state->req_mru;
} /* new_mru() */



/*************************** new_accm() *****************************/
/* Didn't like our first one - try what we're given */
void new_accm(STATE_DATA *state, UBYTE *option_data,
				UWORD protocol_offset)
{
	(void) protocol_offset;
	
	/* Record the value and try again */
	state->req_accm = ((ACCM_OPT *)(option_data))->accm;
}



/*************************** new_magicnum() *****************************/
/* We'll take whatever magic number they give us - just record it */
void new_magicnum(STATE_DATA *state, UBYTE *option_data,
				UWORD protocol_offset)
{
	(void) protocol_offset;
	
	state->req_magicnum = ((MAG_OPT *)option_data)->magic_num;
} /* new_magicnum() */


/************************** new_ip() ***********************************/
/* Rejected our IP address - this is expected the first time */
void new_ip(STATE_DATA *state, UBYTE *option_data,
				UWORD protocol_offset)
{
	(void) protocol_offset;
	/* All we need to do is record the IP address that should be sent */
	state->req_local_ip = ((IP_ADDR_OPT *)(option_data))->ip_address;
} /* new_ip() */ 


/************************** reject_generic() ***************************/
/* Generic reject handler - just remove it from the send options */
void reject_generic(STATE_DATA *state, UBYTE *option_data,
				UWORD protocol_offset)
{
	state->send_opt[protocol_offset] &= 
						(UWORD)((0xffff) ^ (1 << *option_data));
} /* reject_generic() */



/************************** reject_mru() **********************************/
/* Strange thing to reject, but we can stick with the default....*/
void reject_mru(STATE_DATA *state, UBYTE *option_data,
				UWORD protocol_offset)
{
	(void) option_data;
	
	state->send_opt[protocol_offset] &= 
					(UWORD)((0xffff) ^ (1 << MAXIMUM_RECEIVE_UNIT_ID));
	config.mtu = DEFAULT_MRU;
	config.mss = config.mtu - 40;
} /* reject_mru() */


/*************************** reject_magicnum() ****************************/
/* Hmmm...  why would this happen?  Oh well, just zero ours out. */
void reject_magicnum(STATE_DATA *state, UBYTE *option_data,
				UWORD protocol_offset)
{
	(void) option_data;
	
	state->send_opt[protocol_offset] &= 
					(UWORD)((0xffff) ^ (1 << MAGIC_NUMBER_ID));
	state->magic_number = 0;
} /* reject_magicnum() */
