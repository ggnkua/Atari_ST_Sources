/* This function checks for PPP time-outs */
#include "lattice.h"
#include <time.h>
#include <stddef.h>
#include <stdio.h>		/* sprintf */
#include "globdefs.h"
#include "globdecl.h"
#include "ppp.h"
#include "ppp.p"
#include "display.h"

extern clock_t time_out_cnt;
extern STATE_DATA state_info;

void ppp_kicker(void)
{
	clock_t cur_time;

	/* First see if we even need to mess with the timer at all */
	if ((state_info.cur_state[LCP_OFFSET] == S9) &&
		 (state_info.cur_state[IPCP_OFFSET] == S9))
	{
		return;
	}

	/* See if we need to send something */
	cur_time = Sclock();
	/*disp_info("cur_time = %lx toc = %lx c-toc = %lx\n\r",(long)cur_time,time_out_cnt,(long)(cur_time-time_out_cnt));*/

	if ((cur_time - time_out_cnt) >= (STATE_TIMEOUT * CLK_TCK))
	{
		ppp_state_machine((UWORD)INTERNAL_PROTOCOL, (UBYTE)RESTART_TIMER, (GPKT *)NULL);
		time_out_cnt = cur_time;
	}
}