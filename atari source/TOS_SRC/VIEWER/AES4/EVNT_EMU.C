/* evnt_emu.c - AES evnt_emu() function
 *=======================================================================
 * 920630 kbad
 */
#include <aes4.h>
#include "_aes.h"

/* swap words */
long swapw(long);

#ifdef LATTICE
#pragma inline d0=swapw(d0) { "4840"; }
#else
#define swapw(l) ( ((ULONG)(l)>>16) | ((ULONG)(l)<<16) )
#endif

/* evnt_emu() - evnt_multi() using an EMU structure.
 *-----------------------------------------------------------------------
 * The caller only need fill in those fields which apply to the events
 * awaited.  Caller needn't swap the words of the e_time field:
 * the binding swaps it on the way in and unswaps it on the way out.
 */
UWORD
evnt_emu(EMU *ep)
{
	void *ii = apb[2];
	void *io = apb[3];
	long t = ep->time;
	apb[2] = &ep->flags;
	apb[3] = &ep->events;
	addr_in[0] = &ep->msg;
	ep->time = swapw(t);
	aes(EVNT_MULTI);
	ep->time = t;
	apb[2] = ii;
	apb[3] = io;
	return ep->events;
}
