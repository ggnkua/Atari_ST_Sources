/* This is the driver for the state machine.  It figures out
   which functions to call depending on the current state and
   the event */
#include "lattice.h"
#include <time.h>
#include <stdio.h>
#include "krmalloc.h"
#include "globdefs.h"
#include "globdecl.h"
#include "ppp.h"
#include "ppp.p"
#include "display.h"

STATE_DATA state_info = {{S6, S6, S8},
						 0L, 
                         0,
                         0,
                         {DEFAULT_LCP_SENDOPT, DEFAULT_IPCP_SENDOPT, DEFAULT_PAP_SENDOPT},
                         DEFAULT_MRU,
						 DEFAULT_ACCM,
                         DEFAULT_MAGNUM,
                         0L};

UBYTE current_id=0; /* Used to get unique IDs */
clock_t time_out_cnt=0L;
extern SM_STATE lcp_machine[];
extern SM_STATE ipcp_machine[];
extern SM_STATE pap_machine[];

UWORD last_pkt_protocol = 0;
UBYTE last_pkt_code = 0;

extern void s9echoreq(STATE_DATA *, GPKT *);

static char debugOut[300];

void ppp_state_machine(UWORD protocol, UBYTE code, GPKT *inpkt)
{
    SM_EVENT *event_ptr;
    SM_STATE *state_ptr;
    UWORD protocol_offset;
	UBYTE *raw_data;
	UWORD dataCnt, dataOffset;

	if (config.reports == 1)
	{
		if (code != 9) 
		disp_info("LCP = %d, IPCP = %d, PAP = %d, pr = 0x%x, co = %d", state_info.cur_state[LCP_OFFSET],
			state_info.cur_state[IPCP_OFFSET],
			state_info.cur_state[PAP_OFFSET], protocol, code);
	}

	/* Save off values for report if requested */
	last_pkt_protocol = protocol;
	last_pkt_code = code;
	
    /* Switch on the protocol to grab the right state machine */
    switch(protocol)
    {
        case LCP_PROTOCOL:
            state_ptr = lcp_machine;
            protocol_offset = LCP_OFFSET;

			if (code == 9)
			{
				/* Echo Request special case */
					
				s9echoreq(&state_info,inpkt);
				return;
			}
			else
				raw_data = (UBYTE *) inpkt->pip;
            break;
        case PAP_PROTOCOL:
			state_ptr = pap_machine;
			protocol_offset = PAP_OFFSET;
			raw_data = (UBYTE *) inpkt->pip;
        	break;
        case IP_CTRL_PROTOCOL:
            /* See if we're allowed to receive these yet */
            if ( ((state_info.auth_prot != 0 ) &&
            	 (state_info.cur_state[PAP_OFFSET] != S9)) ||
            	 (state_info.cur_state[LCP_OFFSET] != S9) )
                goto sm_done;
            state_ptr = ipcp_machine;
            protocol_offset = IPCP_OFFSET;
			raw_data = (UBYTE *) inpkt->pip;
            break;
        case INTERNAL_PROTOCOL:
            /* See which state this is for */
            /* For internal events, always use the lcp_machine */
            state_ptr = lcp_machine;
            
            if (state_info.cur_state[LCP_OFFSET] != S9)
            {
                protocol_offset = LCP_OFFSET;
            }
            else if ((state_info.auth_prot != 0 ) &&
            		 (state_info.cur_state[PAP_OFFSET] != S9))
            {
            	protocol_offset = PAP_OFFSET;
            }
            else if (state_info.cur_state[IPCP_OFFSET] != S9)
            {
                protocol_offset = IPCP_OFFSET;
            }
            else
            {
                protocol_offset = LCP_OFFSET;
            }
			raw_data = (UBYTE *)NULL;
            break;
		
        default: /* What the -heck- is this??? */
			if (config.reports == 1)
	        	disp_info("reject packet protocol %d",protocol);
	        	
            protocol_reject(protocol, code, inpkt);
            goto sm_done;
    }

    /* Verify the code is okay and grab the right event */
    state_ptr += state_info.cur_state[protocol_offset];
    event_ptr = state_ptr->events;

#if 0
	if (raw_data)
	{
		/* The length had -better- match */
		for (dataCnt=0, dataOffset=0;
			(dataCnt<99) && (dataCnt<inpkt->ip_len);
			 dataCnt++)
		{
			dataOffset += sprintf(&debugOut[dataOffset], 
									" %02x", raw_data[dataCnt]);
		}
		disp_info(" Raw Data: %s", debugOut);
	}
	else
		disp_info(" No Data");
#endif
	
    /* Verify the code is in range */
    if (code >= state_ptr->num_events)
    {
        code_reject(protocol, inpkt);
        goto sm_done;
    }

    /* Must be valid - let's do it! */
    ((event_ptr + code)->action)(&state_info, raw_data, protocol_offset);

    /* Free the buffer if one was passed */
sm_done:    if (inpkt)
        delete_packet(inpkt, NI_PPPSM);
}


/* This should be somewhere else probably, but it's noted elsewhere
that it's here and here requires no extra overhead */

PPP_ST *
cdecl query_state(void)
{
	PPP_ST st_cur;
	PPP_ST *ret_val = (PPP_ST *)&st_cur;
	
	st_cur.lcp = (int16)(state_info.cur_state[LCP_OFFSET]);
	st_cur.ipcp = (int16)(state_info.cur_state[IPCP_OFFSET]);
	st_cur.pap = (int16)(state_info.cur_state[PAP_OFFSET]);
	st_cur.protocol = (UBYTE)last_pkt_protocol;
	st_cur.cmd = (UWORD)last_pkt_code;
	
	return(ret_val);
}