/* This function passes in a close request to the state machine */

#include <stddef.h>
#include "lattice.h"
#include "globdefs.h"
#include "ppp.h"
#include "ppp.p"

void ppp_term()
{
	ppp_state_machine((UWORD)INTERNAL_PROTOCOL, LCP_CLOSE,  (GPKT *)NULL);
}
