/* Layer 1 output for STiK */
/* Based on RFC(s): 1549 */
/* Assume this is called from SLIP's output_packet() */
#include "lattice.h"
#include <stdio.h>
#include "device.h"
#include "krmalloc.h"
#include "globdefs.h"
#include "globdecl.h"
#include "ppp.h"
#include "ppp.p"
#include "display.h"

extern DEV_LIST *bdev;
extern ULONG tx_accm[];
extern UWORD fcstab[];

/* Globals to tell us to use compression */
BOOLEAN tx_pfc_on = FALSE;
BOOLEAN tx_acfc_on = FALSE;

/* Internal prototypes */
void send_ppp_tail(UWORD fcs);
void send_ppp_head(UWORD protocol, UWORD *fcs);

#define    ser_out(c)	PortSendByte(bdev, (char)c)

#define OUTCHAR(outchar)  if (MAP_ISSET(tx_accm, outchar)) {\
                              ser_out(FLAG_ESC); outchar ^= ACCM_MASK;}\
                           ser_out(outchar)
void ppp_out(void)
{
    GPKT *outpkt = NULL;
    UWORD out_len;
    UBYTE *nextout = (UBYTE *)NULL;
    UWORD fcs = PPP_FCS_INIT;
    UBYTE c;

	extern int16 new_carrier_detect(void);	/* from oldmain.c */

	/* Set the semaphore flag */
	if (set_flag(FL_l1out))
		return;

	/* In case we have no carrier */
	if ( new_carrier_detect() < 0 )
		goto ppp_out_done;
			
    /* Do this until we have nothing else to send */
    while ((outpkt = get_outpacket()) != (GPKT *)NULL)
    {
        /* Get the number of characters to send */
        out_len = outpkt->ip_len;

        /* Get the first character to send */
        nextout = (UBYTE *)outpkt->pip;

        /* Send the PPP header first */
        send_ppp_head(outpkt->protocol, &fcs);

        /* Loop until there's nothing left to send */
        while (out_len > 0)
        {
            /* Grab a local variable */
            c = *nextout;
 
            /* Update the FCS before we potentially escape it */
            UPDATE_FCS(fcs, c);

            /* See if we need to escape this character */
            OUTCHAR(c);

            /* Change pointers/counters */
            nextout++;
            out_len--;
        }

        send_ppp_tail(fcs);
        fcs = PPP_FCS_INIT;				/* added 1/3/97 */
        delete_packet(outpkt, NS_SENT);
    } /* while */
    
ppp_out_done:
	clear_flag(FL_l1out);
    
} /* ppp_out() */


/*********************** send_ppp_head() **************************/
static void send_ppp_head(UWORD protocol, UWORD *fcs)
{
	UBYTE c;

    /* Now send the closing/start of next frame flag */
    ser_out(FLAG_END);

	/* Only send address/control if compression is off */
	/* or if we're sending LCP, IPCP, etc */
	if ( (protocol != IP_PROTOCOL) || (tx_acfc_on == FALSE) )
	{
		/* Send the address */
		c = ADDRESS;
    	UPDATE_FCS(*fcs, c);
    	OUTCHAR(c);

		/* The control info */
		c = CONTROL;
    	UPDATE_FCS(*fcs, c);
    	OUTCHAR(c);
	}

	/* The upper byte of the protocol */
	c = (protocol >> 8) & 0xff;

	/* If the upper byte is zero, don't send it if we're compressing protocols */
	if (c || ( (protocol != IP_PROTOCOL) || (tx_pfc_on == FALSE)))
	{
    	UPDATE_FCS(*fcs, c);
    	OUTCHAR(c);
	}

	/* The lower byte of the protocol */
	c = protocol & 0xff;
    UPDATE_FCS(*fcs, c);
    OUTCHAR(c);
} /* send_ppp_head() */




/*********************** send_ppp_tail() **************************/
static void send_ppp_tail(UWORD fcs)
{
	UBYTE next_out;

    /* Now send the end - invert the fcs */
    fcs ^= 0xffff;
	next_out = fcs & 0xff;
	OUTCHAR(next_out);
	next_out = (fcs >> 8) & 0xff;
	OUTCHAR(next_out);

    /* Now send the closing/start of next frame flag */
    ser_out(FLAG_END);
} /* send_ppp_tail() */