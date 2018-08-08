/* This handles events that don't make sense where we're at - we just 
	toss 'em for the moment */
#include "lattice.h"
#include "globdefs.h"
#include "ppp.h"
#include "ppp.p"

void dummy(STATE_DATA *state, UBYTE *new_msg, UWORD protocol_offset)
{
	(void) state;
	(void) new_msg;
	(void) protocol_offset;
}/* dummy() */