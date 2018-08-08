/* This function simply returns you to state 6 - only used ATM in state 7 */
#include "lattice.h"
#include "globdefs.h"
#include "ppp.h"
#include "ppp.p"

void reset_to6(STATE_DATA *state, UBYTE *new_msg, UWORD protocol_offset)
{
	(void) new_msg;
	
	state->cur_state[protocol_offset] = S6;
}