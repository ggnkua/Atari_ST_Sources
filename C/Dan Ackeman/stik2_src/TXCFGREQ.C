/* This function (re-)sends the configuration message to the provider */
/* Supporting functions below */
#include <stdio.h>
#include <string.h>
#include "lattice.h"
#include "krmalloc.h"
#include "globdefs.h"
#include "globdecl.h"
#include "ppp.h"
#include "ppp.p"

#include "display.h"

extern UBYTE current_id;
extern CONFIG config;
extern BUILD_TBL *build_options[];
extern UWORD protocol_id[];
extern UBYTE max_options[];

extern void reset_userpass(void);

/************************** send_cfg_req() **********************************/
void send_cfg_req(STATE_DATA *state, UBYTE *new_msg, UWORD protocol_offset)
{
    GPKT *config_req; /* Body to send */
    UBYTE msg_len;    /* Length of the LCP message */
	ULONG add_len; 	/* How much to add to the body length */
    LCP_HEADER *lcp_head;  /* Some useful pointers */
	UBYTE option_count; /* Count the number of options handled */
	UWORD send_bits; /* Bit field indicating which options to send */
	UBYTE *body_ptr; /* Pointer to the body of the message */
	BUILD_TBL *build_ftns; /* Pointer to the correct build table */
	UBYTE num_options; /* The maximum options for a protocol */
	(void) new_msg;

    /* Initialize the message length counter */
    msg_len = sizeof(LCP_HEADER);

	/* Copy the send bits from the state data */
	send_bits = state->send_opt[protocol_offset];

    /* Get a body to fill in */
    config_req = allocate_packet(config.mtu);
	if (!config_req)
		return;

    config_req->protocol = protocol_id[protocol_offset];

    /* Fill in the LCP header */
    lcp_head = (LCP_HEADER *)(config_req->pip);
    lcp_head->code = CONFIGURE_REQUEST; /* or AUTHENTICATE_REQUEST */

	/* Get a unique ID */
	lcp_head->identifier = state->identifier = GET_UNIQUE_ID;

	/* Get a pointer to the body */
	body_ptr = (UBYTE *)(lcp_head + 1);

	/* Grab the correct verify function */
	build_ftns = build_options[protocol_offset];
	num_options = max_options[protocol_offset];

	/* Loop through the configuration options */
	for(option_count=0; option_count<=num_options; option_count++)
	{
		/* See if we need to send this option */
		if (send_bits & 1)
		{
			add_len = (build_ftns[option_count].action)(state, body_ptr);
			msg_len += add_len;
			body_ptr += add_len;
		}

		/* Go to the next field */
		send_bits >>= 1;
	} /* for */

	/* Set the message length */
	lcp_head->length = msg_len;
	config_req->ip_len = msg_len;

    /* Th- th- th- that's all, folks! */
    output_packet(config_req);
} /* send_cfg_req() */



/************************** invalid_build() **********************/
ULONG invalid_build(STATE_DATA *state, UBYTE *option)
{
	(void) state;
	(void) option;

	return 0;
}


/********************** build_mru() ********************/
ULONG build_mru(STATE_DATA *state, UBYTE *option)
{
	MRU_OPT *mru_ptr;

    /* Fill in the MRU length option */
    mru_ptr = (MRU_OPT *)option;
    mru_ptr->type = MAXIMUM_RECEIVE_UNIT_ID;
    mru_ptr->length = MRU_LENGTH;
    mru_ptr->mru = state->req_mru = config.mtu;

	return MRU_LENGTH;
} /* build_mru() */


/*************************** build_accm() *********************/
ULONG build_accm(STATE_DATA *state, UBYTE *option)
{
    ACCM_OPT *accm_ptr;

    /* Fill in the ACCM field */
    accm_ptr = (ACCM_OPT *)(option);
    accm_ptr->type = ASYNC_CONTROL_CHAR_MAP_ID;
    accm_ptr->length = ACCM_LENGTH;
    accm_ptr->accm = state->req_accm;

	return ACCM_LENGTH;
} /* build_accm() */



/****************************** build_magicnum() *************************/
ULONG build_magicnum(STATE_DATA *state, UBYTE *option)
{
    MAG_OPT *mag_ptr;

    /* Fill in the magic number field */
    mag_ptr = (MAG_OPT *)(option);
    mag_ptr->type = MAGIC_NUMBER_ID;
    mag_ptr->length = MAG_NUM_LEN;
    mag_ptr->magic_num = state->req_magicnum;

	return MAG_NUM_LEN;
} /* build_magicnum() */

/**************************** ip_address_txcfg() ************************/
/* Build an IP address request */
ULONG ip_address_txcfg(STATE_DATA *state, UBYTE *option)
{	
	IP_ADDR_OPT *address_ptr;

	/* Fill out the IP address fields */
	address_ptr = (IP_ADDR_OPT *)(option);
	address_ptr->type = IP_ADDRESS;
	address_ptr->length = IP_ADDRESS_LEN;

	if (state->req_local_ip)
		address_ptr->ip_address = state->req_local_ip;
	else
		address_ptr->ip_address = state->req_local_ip = config.client_ip;

	return IP_ADDRESS_LEN;
}

/*************************** pap_authreq() **********************/
/* Send a PAP authentication request */
ULONG pap_authreq(STATE_DATA *state, UBYTE *option)
{
	UBYTE i;
	ULONG plen = 2L;
	(void) state;

	reset_userpass();
	
	i = strlen(config.pap_id);
	*option = i;
	option++;
	strcpy((char *)option, config.pap_id);
	option += i;
	plen += i;

	i = strlen(config.password);
	*option = i;
	option++;
	strcpy((char *)option, config.password);
	plen += i;
	
	return plen;
} /* pap_authreq() */


/************************ build_pfc() ******************************/
/* Build a protocol field compression request */
ULONG build_pfc(STATE_DATA *state, UBYTE *option)
{
	COMPR_OPT *compression;
	(void) state;

	compression = (COMPR_OPT *)option;

	/* Very simple to set up */
	compression->type = PROTOCOL_FLD_COMPRESSION_ID;
	compression->length = PFC_LEN;

	return PFC_LEN;
} /* build_pfc() */


/******************** build_acfc() *********************************/
/* Build an address and control field compression request */
ULONG build_acfc(STATE_DATA *state, UBYTE *option)
{
	COMPR_OPT *compression;
	(void) state;

	compression = (COMPR_OPT *)option;

	/* Very simple to set up */
	compression->type = ADDR_AND_CTRL_FLD_COMP_ID;
	compression->length = ADD_CTRL_LEN;

	return ADD_CTRL_LEN;
} /* build_pfc() */
