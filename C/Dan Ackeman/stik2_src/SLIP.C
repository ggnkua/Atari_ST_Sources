/*  slip.c  (c) Steve Adam 1995         steve@netinfo.com.au
 *
 *          Module contains functions for input/output
 *          of slip packets.  Slip conversions are performed
 *          here.  Note that both of these functions are
 *          interruptable.  That is, they do what work they
 *          can then return.  If called again later, they
 *          continue at the same point.
 *
 *          The output queue functions are also here.
 *
 *          Based on RFC1055
 */

#include "lattice.h"
#include <stdio.h>      /* Included for NULL.  Might change that later...   */
#include <tos.h>
#include <string.h>
#include <stdlib.h>
#include "device.h"
#include "krmalloc.h"
#include "globdefs.h"
#include "globdecl.h"
#include "ppp.h"
#include "ppp.p"
#include "display.h"


/* SLIP special character codes
 */
#define END             0300    /* indicates end of packet */
#define ESC             0333    /* indicates byte stuffing */
#define ESC_END         0334    /* ESC ESC_END means END data byte */
#define ESC_ESC         0335    /* ESC ESC_ESC means ESC data byte */

extern DEV_LIST *bdev;
extern struct slip *myslip;
extern struct slcompress *comp;
extern struct cstate mytstate[MAX_STATES];
extern struct cstate myrstate[MAX_STATES];


/*  slip_in()
 *
 *      Receives packet data from the serial port and adds it to
 *  the data buffer in the packet structure.  If no packet is
 *  currently allocated, then allocate one.  If no data is
 *  available from the serial port, then return, but REMEMBER
 *  where we're up to so we can continue later.  When a packet
 *  has been completely received, pass it to ip_in() for
 *  further processing.  We don't care what's in the packets,
 *  but if the length is less than an IP header, throw it away.
 *  Do SLIP special character processing in an interruptable way.
 *  (ie: We can return from this function in the middle of things..)
 */

void slip_in(void)
{
    static GPKT *inpkt = (GPKT *)NULL;  /* Packet being read            */
    static char *nextin = (char *)NULL; /* Pointer to next buffer octet */
    static uint16 buf_avail;            /* Max number of chars to read  */
    static uint16 bufsize = 0;          /* Current buffer size          */

    int newch;  /* New character read from serial port              */
    uint16 len; /* Length of packet received.  (Calculated later)   */
    char *mblk;

    if (inpkt == (GPKT *)NULL) 
    	{    /* No current packet, allocate one  */
    	    bufsize = buf_avail = config.mtu;
    	    inpkt = allocate_packet(bufsize + 68);

    	    if (inpkt == (GPKT *)NULL)  /* What, no memory? LOG_IT          */
    	        return;                 /* Try again later                  */

	        nextin = inpkt->pip;        /* Init pointer to start of buffer  */
	    }
    else 
    	{      /* Check to see if we've about to overflow our buffer   */
                /* If we are, then realloc() to a larger buffer.  This  */
                /* *will* force a copy, but "Be liberal etc."           */
                /* Hopefully this will never happen. (Yeah, right!)     */

	        if (buf_avail == 0) 
	        	{
		            buf_avail = config.mtu;            /* reset buf_avail      */
		            len = bufsize;                  /* Save old size        */
		            bufsize += buf_avail;           /* increase bufsize     */

		            /*mblk = STiKrealloc(inpkt->pip, (long)bufsize + 128);*/ /* was 68 */
					mblk = STiKmalloc( (long) bufsize + 128 );
					
		            if (mblk == (char *)NULL)
		                ;   /* Ooops, out of memory. LOG_IT and worry later...  */
		            else
		            {
		            	memcpy(mblk, inpkt->pip, (long)bufsize + 128);

		            	STiKfree(inpkt->pip);
		            		
		                inpkt->fp = inpkt->pip = mblk;
		            }

		            nextin = &inpkt->pip[len];  /* Reinit data pointer          */
		        }
	    }

    while (TRUE) {      /* Loop till no more data or packet complete    */
        if (CharAvailable(bdev) == FALSE)	/* ATARI: If no serial char waiting */
            	return;             /* then return.  Try again later        */

        newch = PortGetByte(bdev) & 0xff;/*  ATARI: get serial byte.  The */
                                        /* 0xff mask is just in case.   */
                                        
        switch(newch) 
            {
	            case ESC_END:
      				*nextin++ = (myslip->flags & SLF_ESC) ? END : newch;
					myslip->flags &= ~SLF_ESC;
	                --buf_avail;
	                continue;

	            case ESC_ESC:
	   				*nextin++ = (myslip->flags & SLF_ESC) ? ESC : newch;
					myslip->flags &= ~SLF_ESC;
	                --buf_avail;
	                continue;

	            /* If we fall through to default: then an inappropriate character
	             * followed the ESC character.  This an error condition. LOG_IT
	             * RFC1055 suggested copying the next character as is.  I don't
	             * have any better ideas so...  (Should we discard packet?)
	             */

		        case END:                       /* End of current packet            */
       			    len = (uint16)(nextin - inpkt->pip);  /* pkt length.                      */

					if (len)
						{
				            inpkt->ip_len = len;                /* Set packet length    */
	
   					        /* realloc should return same block if newsize < oldsize    */
					        /* so this operation should *NOT* force a memory copy       */
				            /* The extra 68 bytes is to allow a ICMP error packet to be */
	    			        /* constructed from this pkt if necessary.  68 bytes is the */
	    			        /* most such a packet would need (max ip header + 8 bytes)  */

	        			    inpkt->pip=inpkt->fp = STiKrealloc(inpkt->pip, (long)len + 128); /*was 68 */

							uncompress(inpkt, myslip);
									
							if (myslip->flags & SLF_TOSS)
								{
							        delete_packet(inpkt, EI_SUM);  /* This is how we `ignore' packets  */
							        return;
								}

							ip_in(inpkt);                   /* Pass the packet to IP    */
	
				            inpkt = (GPKT *)NULL;           /* Clear our `state'        */

					        bufsize = buf_avail = config.mtu;
					        inpkt = allocate_packet(bufsize + 68);
					        if (inpkt == (GPKT *)NULL)   /*What, no memory? LOG_IT          */
		    			        return;                  /*Try again later                  */

					        nextin = inpkt->pip;         /*Init pointer to start of buffer  */

							/*goto new_packet;*/
						   	return;						/* And give everyone else a go  */
	       				}
       				 break;

			        case ESC:       /* An escape character means skip to the next char  */
    			        /*esc_read = TRUE;             But set ESC state TRUE first...  */
						myslip->flags |= SLF_ESC;
			            break;

        			default:                /* Default case, just copy the char.        */
						myslip->flags &= ~SLF_ESC;
        			    *nextin++ = (char)newch;
        			    --buf_avail;
       				     break;
       			 }
        
        
/*new_packet:
;*/
    }

    /* This function should never exit here */
}


/*  output_packet()
 *
 *      This function adds a completely processed IP packet to
 *  an output queue.  The queue is just a chain of GPKT's.  They
 *  are chained using the `.pnout' pointer of GPKT.  NULL means
 *  end of list.  New packets are always added to the end of the
 *  list and and later dequeued (by get_outpacket()) from the front.
 *
 *      This function also calls slip_out().  This should always
 *  happen when a packet goes on the queue anyway.  slip_out()
 *  can still be called seperately from elsewhere, though.
 *
 *  We need semaphore protection for this.  With multiple APPs and
 *  a kicker running, there's ample opportunity for corruption.
 */

static GPKT *outqueue[NUM_OUTQ_FLAGS] =
	{		 (GPKT *)NULL,   /* Initial value must be NULL */
			 (GPKT *)NULL,
			 (GPKT *)NULL,
			 (GPKT *)NULL,
			 (GPKT *)NULL,
			 (GPKT *)NULL,
			 (GPKT *)NULL,
			 (GPKT *)NULL,
			 (GPKT *)NULL,
			 (GPKT *)NULL		};

void output_packet(GPKT *opkt)
{
    GPKT *endqueue, **cur_queue;
    int16 current_queue = FL_first_outq; /* Queue to put it in */

/*	extern int pktfd;
    if (pktfd <= 0)
		pktfd = Fcreate("pkt.log", 0);

    Fwrite(pktfd, 2L, &opkt->ip_len);
    Fwrite(pktfd, (long)opkt->ip_len, opkt->pip);
*/

    /* See if we should send this off-board or not */
	/* We need to change this below it's not right as stuff will
		not get here ever atm unless we are already online */

/*	This is handled in ip_send now

	if (opkt->protocol == IP_PROTOCOL)
	{
		* See if the IP address is the local address *
		if (((IP_HDR *)(opkt->pip))->d_ip == config.localhost)
		{
			ip_in(opkt);
			return;
		}
	}
*/	

    opkt->next = (GPKT *)NULL; /* It should have been NULL anyway but....  */

	/* Find a queue to put it in */
	while (( current_queue <= FL_last_outq ) &&
			(set_flag(current_queue)))
			current_queue++;

	/* See if we found one */
	if (current_queue > FL_last_outq)
	{
		disp_info("All %d output queues used\n",current_queue);
		delete_packet(opkt, EI_NOQUEUES);
		return;		/* Hope for a retry */
	}
	
	cur_queue = outqueue + (current_queue - FL_first_outq);
	
	if (*cur_queue == (GPKT *) NULL)
	{
		/* Queue was empty */
		*cur_queue = opkt;
	}
    else {
    	endqueue = *cur_queue;
        while (endqueue->next != (GPKT *)NULL) /* advance to end of chain   */
            endqueue = endqueue->next;

        endqueue->next = opkt;
    }

	clear_flag(current_queue);
    /*slip_out();*/
    /*ppp_out();*/			/* interrupt driven */
}


/*  get_outpacket()
 *
 *      Return the next packet from the output queue or NULL if none.
 *  If a packet is present, remove it from the queue before returning it.
 */

GPKT *get_outpacket(void)
{
    GPKT *next_packet, **cur_queue;
    int16 cur_flag;
    
    /* Check the other available queues */
    /* Find an unlocked queue */
    
    for (cur_flag = FL_first_outq ; cur_flag <= FL_last_outq; cur_flag++ )
    {
    	/* See if the queue is unlocked and has something */
    	if (!set_flag(cur_flag))
    	{
    		if (outqueue[cur_flag - FL_first_outq] != (GPKT *)NULL)
    		{
    			cur_queue = outqueue + (cur_flag - FL_first_outq);
    			break;
    		}
    		else
    		{
    			clear_flag(cur_flag);
    		}
    	}
    }
    
    /* See if we found one */
    if (cur_flag > FL_last_outq)
    {
    	return (GPKT *)NULL;
    }
    
    next_packet = *cur_queue;	

	/* Advance pointer (possibly to NULL) */
	*cur_queue = (*cur_queue)->next;

    /* Clear the semaphore */
    clear_flag(cur_flag);
    
    return next_packet;
}


/*  slip_out()
 *
 *      Sends a packet out the serial port, inserting SLIP
 *  special characters at the same time.  If no packet is
 *  currently being sent, get the next packet from the
 *  output queue.  If no packet is available, return.
 *  If the serial buffer can't accept any more characters,
 *  then return.  In this case, REMEMBER where we are up to
 *  so we can continue later.  When a packet has been
 *  completely sent, delete it.
 *
 *      When an ESC is sent this function *doesn't* assume that
 *  the serial buffer is available for just one more char.
 *  Therefore, the condition is noted for special action.
 */

static void ser_out(int c)
{
    PortSendByte(bdev, (char)c);
}


void slip_out(void)
{
    static GPKT *outpkt = (GPKT *)NULL; /* Packet being written             */
    static unsigned char *nextout = (unsigned char *)NULL;   /* next buffer octet    */
    static int esc_sent = FALSE;        /* Was ESC the last byte written    */
    static uint16 out_len;              /* number of chars to write         */

	extern int16 new_carrier_detect(void);	/* from oldmain.c */


	/* In case we have no carrier */
	if ( new_carrier_detect() < 0 )
		return;
	
new_out_packet:

    if (outpkt == (GPKT *)NULL) 
    	{       /* No packet being processed        */

    	    outpkt = get_outpacket();       /* So get one, if any               */

    	    if (outpkt == (GPKT *)NULL)
    	        return;                     /* If not, return;  Try later.      */

	        out_len = outpkt->ip_len;       /* Number of chars to send          */
	        nextout = (unsigned char *)outpkt->pip; /* Start of buffer to send          */
	        esc_sent = FALSE;               /* Make it a *real* init            */

			if (myslip->flags & SLF_COMPRESS &&
				    IP_PROTO (outpkt) == IPPROTO_TCP)
				{
					*outpkt->pip |= slc_compress(outpkt, myslip->comp, myslip->flags & SLF_COMPCID);

					nextout = (unsigned char *)outpkt->pip;
					out_len = outpkt->ip_len;
				}

	 										/* Send an initial end, per RFC1055 */
	        ser_out(END);               	/* But only if com buffer not full  */
	    }


    while (TRUE) 
    	{          /* Send chars until buffer full, or all sent    */
					/* The test for output buffer full might not be supported
					 *	by DEVICE.LIB  I'll have to check up on that...
					 */

	        if (out_len == 0) 
	        	{             /* Packet is completely sent        */

		            ser_out(END);               /* ATARI:So send an END             */
           
   			        delete_packet(outpkt, NS_SENT);
   			        outpkt = (GPKT *)NULL;      /* All done..*/

   					goto new_out_packet;
           			/*return;                      Like slip_in(), we return now    */
		        }   /* Possibly better for slip_out() to continue if more queued!   */

	        if (*nextout == ESC || *nextout == END) 
	        	{   /* A special case char  */
		            if (esc_sent) 
		            	{             /* But we ESC'd it last time around */
			                if (*nextout == ESC) 
			                	{
				                    ser_out(ESC_ESC);    /* ATARI: so send a ESC_ESC */
				                }
			                else 
			                	{
				                    ser_out(ESC_END);   /* ATARI: or send a ESC_END */
               					}

		                	esc_sent = FALSE;
		                	++nextout;
           			    	--out_len;
           				}
           			else 
           				{
			                ser_out(ESC);           /* ATARI: Send an ESC char  */
			                esc_sent = TRUE;
			            }
		        }
       		else 
       			{
		            ser_out(*nextout);  /* ATARI: Otherwise just send the char  */
		            ++nextout;
		            --out_len;
   			    }
	    }
    
    /* Like slip_in() this function never gets here.    */
}

