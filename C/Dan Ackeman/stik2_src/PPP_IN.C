/* PPP implementation for STiK - main input routine */
/* Based on RFC(s): 1549 */
#include "lattice.h"
#include <stdio.h>
#include "device.h"
#include "krmalloc.h"
#include "globdefs.h"
#include "globdecl.h"
#include "ppp.h"
#include "ppp.p"
#include "display.h"

static char *ppp_stat="xPPPSTAT";

#define ADD_CHAR(newguy)  *nextin++=newguy; --buf_avail

extern DEV_LIST *bdev;
extern UWORD fcstab[];
extern ULONG rx_accm[];

/****************************** ppp_in() **********************************/
void ppp_in(void)
{
    static GPKT *inpkt = GPNULL;            /* Current IP packet */
    static BYTE *nextin = (BYTE *)NULL;		/* Next character placement */
    static UWORD buf_avail = 0;             /* Amount of space left */
    static UBYTE esc_xor = 0;               /* Byte to XOR with */
    static UWORD bufsize = 0;               /* Current buffer size */
    static UWORD fcs = PPP_FCS_INIT;        /* Calculate the FCS on the fly */
    UBYTE newchar;                          /* Next character received */


	*ppp_stat='s';
	/* Check/set the semaphore */
	if (set_flag(FL_l1in))
	{
		disp_info("ppp_in: tried to reenter");
		return;
	}

    /* Loop until we have nothing else to receive or an error occurs */
    while (TRUE)
    {
        /* Get the next packet */
        if (getinpkt(&inpkt, &buf_avail, &nextin, &bufsize) != OK)
            goto ppp_in_done;
    
        /* Get the header */
        /*if (inpkt==GPNULL)
        {
        	disp_info("error in ppp_in() inpkt NULL\n");
        	return;
        }*/
        
        if (inpkt->protocol == 0)
        {
        	/*printf("ppp_in: inpkt->protocol = 0\n");*/
            /* Return if nothing there or something else wrong */
            if ((inpkt->protocol = receive_ppp_hdr(&fcs)) == FALSE)
            {
            	/*puts("ppp_in: receive_ppp_hdr returned FALSE, exit\n");*/
               	goto ppp_in_done;
			}
        }

        /*printf("after get header ");*/
    
        /* Now grab the body */
        /* Loop while there's something in the serial port and we have space */
        while ((CharAvailable(bdev) != FALSE) && buf_avail)
        {
	    	/*printf("ppp_in: inner while %d\n",mmj++);*/

            /* Get the next character */
            newchar = PortGetByte(bdev);
    
            /* Switch on the received character */
            switch (newchar)
            {
                case FLAG_END:
                    /* Handle the end of frame */
                    /* Check the FCS */
                    if (fcs == PPP_FCS_GOOD)
                    {
                        /* How big is it (strip off the FCS) */
                        inpkt->ip_len = (UWORD)(nextin - ((BYTE *)(inpkt->pip))) - 2;

                        /* Pass it up */
                        if (inpkt->protocol == IP_PROTOCOL)
                            ip_in(inpkt);
                        else /* Just pass it up to a common state machine */
                             /* The first byte of data is the type of msg */
                            ppp_state_machine(inpkt->protocol,
                                             inpkt->pip[0], inpkt);
                    }
                    else
                    {
                       delete_packet(inpkt, EI_SUM);
                    }

                    /* Now clean up - end of packet */
                    inpkt = (GPKT *)NULL;
                    fcs = PPP_FCS_INIT;
                    buf_avail = 0; /* This'll get us out of the loop */
                    break;

                case FLAG_ESC:
                    /* Discard this guy, but set up the escape flag */
                    esc_xor = ACCM_MASK;
                    break;

                default: /* Anything else must be a character or FCS */
                    /* Check the validity of the character */
                    if ((newchar > MAX_MASK ) ||
                            (!MAP_ISSET(rx_accm, newchar)))
                    {
                        newchar ^= esc_xor;
                        ADD_CHAR(newchar);
                        UPDATE_FCS(fcs, newchar);
                        esc_xor = 0;
                    }
					break;
            } /* switch */
        } /* while */

		/*printf("after inner while\n");*/

        /* Let's see why we exited */
/*        if (buf_avail)*/

		/* Dan made mod January 2000 */ 
		if (CharAvailable(bdev) == FALSE) 
        { /* Must not be any characters available */
			/*printf("ppp_in: exiting.. no chars\n");*/
            goto ppp_in_done;
        }
    } /* while - main loop */
    
ppp_in_done: clear_flag(FL_l1in);
	*ppp_stat='f';
} /* ppp_in() */
