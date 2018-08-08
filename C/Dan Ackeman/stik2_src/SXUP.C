/* This function sends the initial message to the provider */
#include "lattice.h"
#include "globdefs.h"
#include "globdecl.h"
#include "ppp.h"
#include "ppp.p"

void sxup(STATE_DATA *state, UBYTE *new_msg, UWORD protocol_offset)
{
	/* Just send the message */
	send_cfg_req(state, new_msg, protocol_offset);

    /* Set the new state */
    state->cur_state[protocol_offset] = S6;
} /* sxup() */
