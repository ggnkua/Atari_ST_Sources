/* This module determines which protocol should be started next */
#include <stddef.h>
#include "lattice.h"
#include "globdefs.h"
#include "globdecl.h"
#include "ppp.h"
#include "ppp.p"

extern clock_t time_out_cnt;
extern SM_STATE lcp_machine[]; /* Use lcp_machine for internal events */

void start_next_protocol(STATE_DATA *state, UWORD protocol_offset)
{
    UBYTE cur_state;

	/* Current protocols: LCP -> PAP -> IPCP */
	switch (protocol_offset)
	{
		case LCP_OFFSET:
			if (state->auth_prot != 0)
				protocol_offset = PAP_OFFSET;
			else
				protocol_offset = IPCP_OFFSET;
			break;

		case PAP_OFFSET:
			protocol_offset = IPCP_OFFSET;
			break;

		case IPCP_OFFSET:
			time_out_cnt = 0;
			return;

		default:
			return; /* Shouldn't get here */
	}

	cur_state = state->cur_state[protocol_offset];
	(lcp_machine[cur_state].events->action)(state, (UBYTE *)NULL, protocol_offset);

	time_out_cnt = Sclock();
}