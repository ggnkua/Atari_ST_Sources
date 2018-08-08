/* 
 * RAW IP routines
 *
 * version 	0.2 
 * date		august 1, 1997
 * author	Dan Ackerman (baldrick@zeus.netset.com)
 *
 * version .2 New
 *    - Fixed setting of options in RAW_send
 */

#include "lattice.h"
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include "krmalloc.h"
#include "display.h"
#include "globdefs.h"
#include "globdecl.h"

extern CCB ctn[];  /* Connection Control Block list */

/*  RAW_open()  Initiate an active RAW session with a remote port.
 *
 * rhost		Remote host IP address
 *
 */

int16 cdecl RAW_open(uint32 rhost)
{
    int16 cn;

    cn = CNopen();

    if (cn >= 0) {
        ctn[cn].rhost = rhost;
        ctn[cn].rport = 0;
        ctn[cn].protocol = IPPROTO_RAW;
        ctn[cn].lhost = config.client_ip;

		ctn[cn].ip.tos = 0;
		ctn[cn].ip.ttl = config.ttl;

       	ctn[cn].flags |= IN_ISCONNECTED;
    }

    return (cn);
}

/* RAW_close just needs the CCB ? */

int16 cdecl RAW_close(int16 cn)
{
    if (cn < 0 || cn >= CNMAX || ctn[cn].protocol != IPPROTO_RAW)
        return (E_BADHANDLE);

    CNclose(cn);

    return (E_NORMAL);
}

/* RAW_input
 *
 * This is called by the ip level ala TCP,UDP etc
 *
 */
void RAW_in(GPKT *pkt)
{
	uint32 src_addr;
    IP_HDR *iph = (IP_HDR *)pkt->pip;
    int x;
    int found_port = 0;
    NDB *new, *q;

	/* save source IP address */
	
	src_addr = iph->s_ip;

    for (x = 0; x < CNMAX; ++x) 
    	{
        	if (iph->d_ip == ctn[x].lhost &&
        		iph->s_ip == ctn[x].rhost && 
        		(ctn[x].protocol == IPPROTO_RAW ||
        		 ctn[x].protocol == IPPROTO_IP))
        		{
            		/* The connection found matches protocols
            		 * source ip address and
            		 * destination ip address
            		 * So we'll call it a match
            		 */

           		    /* OK, now we can queue the data in a new NDB  */

					new = (NDB *)STiKmalloc( (long)sizeof(NDB) );

				    if (new == (NDB *)NULL) 
			    	{
				        delete_packet(pkt, EA_NOMEMORY);  /* Presumably we're out of memory   */
				        return;
				    }

					new->ptr = (char *)STiKmalloc( (long)pkt->ip_len );

				    if (new == (NDB *)NULL) 
			    	{
				        delete_packet(pkt, EA_NOMEMORY);  /* Presumably we're out of memory   */
				        return;
				    }
					
				    memcpy(new->ptr, pkt->fp, pkt->ip_len);

				    new->ndata = pkt->pip;
				    new->len = pkt->ip_len;
				    new->next = (NDB *)NULL;
   
		    		/* If queue empty   */
				    if (ctn[x].ndq == (NDB *)NULL) 
			    	{
			    		/* Point it to new data */
	    			    ctn[x].ndq = new;
       					/*return; we don't return here due to the nature of RAW sockets*/
    				}
					else
					{
					    q = ctn[x].ndq;                     /* Else get ptr to start of list    */

					    while (q->next != (void *)NULL)     /* Find end of list */
					        q = q->next;

					    q->next = new;                      /* And tack new data to the end     */
					}

            		 /* Increment found port so that the 
            		  * delete is done with the proper flag for 
            		  * stats
            		  */
            		 
            		 found_port++;
            	}
    	}
    
    if (found_port == 0)
		{
	   		/* Failed to find the destination   */

            delete_packet(pkt, EU_NOPORT); 
            return;
        }
        
    delete_packet(pkt, NU_QUEUEDOK);
    return;
}

/* RAW_out
 * 
 * Called to send RAW packets
 *
 */

extern uint16 unique_id;   /* Initialised to random value in main.c at startup */


int16 cdecl RAW_out(int16 cn, void *data, int16 dlen, uint32 dest)
{
	struct ip_options opts;
    IP_HDR *iph;

    register GPKT *pp;

	/* Create a GPKT to put data in */

	pp = mkpacket(dest, dlen, (int16)IPPROTO_RAW);

    if (pp == (GPKT *)NULL)
	    return (-1);

	if (ctn[cn].inp_flags & IP_HDRINCL)
		{
			/* It's all set we just need to
			 * copy it to the GPKT 
			 */

			/*disp_info("IP_HDRINCL == 1");*/
			
			memcpy(pp->pip,data,dlen);

			/* Get ip header */

			iph = (IP_HDR *)pp->pip;

			if (iph->id == 0)
				iph->id = unique_id++;

		    /* Update byte count statistics */
		    if (iph->d_ip == config.provider)
		        elog[CI_LOCALOUT] += pp->ip_len;
		    else
		        elog[CI_FOREIGNOUT] += pp->ip_len;

			if (dest == config.localhost)
				ip_in(pp);
			else	
			    output_packet(pp);   /* Send to output queue */
		}
	else
		{
			/*disp_info("IP_HDRINCL == 0");*/

			/* The client didn't put a header on the data packet
			 * create a header
			 * and copy the data onto it
			 */

			iph = (IP_HDR *)pp->pip;
			
	        pp->mlen = dlen;
	        iph->len = pp->ip_len = pp->mlen + (int16)sizeof(IP_HDR);

	        /* Fill in fields of IP header */
	        iph->s_ip = ctn[cn].lhost;
	        iph->d_ip = dest;
	        iph->ptcl = IPPROTO_RAW;
	        iph->len  = pp->mlen;
	        
		    memcpy(pp->mp, data, dlen);

			/* setup options */

			opts.tos = ctn[cn].ip.tos; 
			opts.ttl = ctn[cn].ip.ttl;

		    ip_send(pp, &opts, FLAG_DF);		
		}

	return (E_NORMAL);
}