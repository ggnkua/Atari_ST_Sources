/* This function handles the reception of a PPP header.  Nothing in this */
/* needs to be save except the calculation of the FCS and the protocol */
#include <stdio.h>
#include "device.h"
#include "lattice.h"
#include "globdefs.h"
#include "globdecl.h"
#include "ppp.h"
#include "ppp.p"

/* Used to track reception of the header */
typedef enum {
    NO_HEADER = 0,
    ADDRESS_RECEIVED = 1,
    CONTROL_RECEIVED = 2,
    PROTOCOL_1_RECEIVED = 3,
    PROTOCOL_2_RECEIVED = 4
} H_PROG;

#define RESTART_HEADER *header_progress = NO_HEADER; *fcs = PPP_FCS_INIT
extern DEV_LIST *bdev;
extern ULONG rx_accm[];
extern UWORD fcstab[];

BOOLEAN rx_acfc_on = FALSE;
BOOLEAN rx_pfc_on = FALSE;

/* Local storage for the retval */
static UBYTE protocol[2];

/* Internal prototypes */
UBYTE receive_addr_ctrl(UBYTE newchar, UWORD *fcs, H_PROG *header_progress);
UBYTE receive_protocol(UBYTE newchar, UWORD *fcs, H_PROG *header_progress);

UWORD receive_ppp_hdr(UWORD *fcs)
{
    static H_PROG header_progress = NO_HEADER;  /* Header progress */
    static UBYTE esc_xor = 0;          /* Is the next guy escaped? */
    UBYTE newchar;

	/*printf("receive_ppp_hdr: entered\n");*/
    /* Only loop while there is something there and we've not received the
       fixed part of the header */
    while ((CharAvailable(bdev) != FALSE) && 
                (header_progress != PROTOCOL_2_RECEIVED))
    {
        /* Get the character */
        newchar = PortGetByte(bdev);

        /* Verify character validity */
        if ((newchar <= MAX_MASK) &&
                (MAP_ISSET(rx_accm, newchar)))
            continue;

        newchar ^= esc_xor;

		/* Call the appropriate function, depending on our header progress */
		if (header_progress < CONTROL_RECEIVED)
		{
			esc_xor = receive_addr_ctrl(newchar, fcs, &header_progress);
		}
		else
		{
			esc_xor = receive_protocol(newchar, fcs, &header_progress);
		}
    } /* while */

	/* See if we got anywhere */
	if (header_progress < PROTOCOL_2_RECEIVED)
	{
		return FALSE;
	}
	else /* Return the appropriate value */
    {
        header_progress = NO_HEADER;
        return (*((UWORD *)(protocol)));
    }
} /* recevie_ppp_hdr() */


/**************************** receive_addr_ctrl() *******************************/
/* This function receives the address and control section of the PPP header */
UBYTE receive_addr_ctrl(UBYTE newchar, UWORD *fcs, H_PROG *header_progress)
{

    /* Switch on the received character */
    switch (newchar)
    {
        case FLAG_ESC:
            /* Discard it, but set up the escape flag */
            return ACCM_MASK;

        case FLAG_END: /* Optional (may have already been received), may
                              send multiple */
            RESTART_HEADER;
            return 0;

        case ADDRESS: /* Address field */
            if (*header_progress == NO_HEADER)
            {
                *header_progress = ADDRESS_RECEIVED;
                UPDATE_FCS(*fcs, newchar);
            }
            else
            {
                RESTART_HEADER;
			}
			return 0;
			
        case CONTROL: /* Control field */
            if (*header_progress == ADDRESS_RECEIVED)
            {
                *header_progress = CONTROL_RECEIVED;
                UPDATE_FCS(*fcs, newchar);
            }
            else
            {
                RESTART_HEADER;
            }
            return 0;

        default: /* We may be compressing address/control fields */
			if ((rx_acfc_on == TRUE) && (*header_progress == NO_HEADER))
			{
				*header_progress = CONTROL_RECEIVED;
				(void)receive_protocol(newchar, fcs, header_progress);
			}
			else /* Shouldn't get this.  If we do, start over */
			{
                RESTART_HEADER;
			}
            return 0;
    } /* switch */
} /* receive_addr_ctrl() */



/************************ receive_protocol() ****************************/
/* Receives the protocol byte(s) */
UBYTE receive_protocol(UBYTE newchar, UWORD *fcs, H_PROG *header_progress)
{
    /* Switch on the received character */
    switch (newchar)
	{
        case FLAG_ESC:
            /* Discard it, but set up the escape flag */
            return ACCM_MASK;

        case FLAG_END: /* Bad news - exit and try again */
            RESTART_HEADER;
            return 0;

        default: /* Grab the protocol byte(s) */
			(*header_progress)++;

			/* See if we're compressing */
			if ((rx_pfc_on == TRUE) && (*header_progress == PROTOCOL_1_RECEIVED) &&
				(newchar & LAST_OCTET_BIT))
			{
				protocol[0] = 0;
				(*header_progress)++;
 			}
                
            protocol[*header_progress - PROTOCOL_1_RECEIVED] = newchar;
            UPDATE_FCS(*fcs, newchar);
            return 0;
    } /* switch */
} /* receive_protocol() */
