/* 
 * ICMP routines
 *
 * version 	0.2 
 * date		august 2, 1997
 * author	Dan Ackerman (baldrick@zeus.netset.com)
 *
 */

#include "lattice.h"
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include "krmalloc.h"
#include "globdefs.h"
#include "globdecl.h"
#include "display.h"

extern CCB ctn[];  /* Connection Control Block list */

/************************************************************
 *															*
 *  First section STiNG implemented ICMP routines for 		*
 *		compatibility sake.  NOT RECOMMENDED FUNCTIONS		*
 ************************************************************
 */

/*
 *   STiNG Handler flag values for compat as much as feasible
 */

#define  HNDLR_SET        0         /* Set new handler if space             */
#define  HNDLR_FORCE      1         /* Force new handler to be set          */
#define  HNDLR_REMOVE     2         /* Remove handler entry                 */
#define  HNDLR_QUERY      3         /* Inquire about handler entry          */

typedef struct msg_data {
    uint8   ttl;            /*  Time to live                                */
    uint16  id;             /*  Packet identifier (For ping etc.)           */
    uint16  seq;            /*  Packet sequence (For ping etc.)             */
	uint16	extra1;			/*  extra uint16 number 1 - for later use		*/
	uint16  extra2;
	uint16  extra3;
  	char *	msg;			/*  message for ICMP send */
} MSG_DATA;


/*
 * ICMP_send - sends an ICMP packet 
 *
 * dest_host = the IP address of the destination machine
 * type 	 = the ICMP packet type 
 * code 	 = type dependent control code for ICMP 
 * data 	 = pointer to data which is to be used for completing the message
 * length	 = length of the data block in bytes
 *
 * Sting has following returns
 * Returns E_BADDNAME, E_PARAMETER, E_NOMEM or E_NORMAL.
 *
 * Ammended version .2 - Dan Ackerman (baldrick@zeus.netset.com)
 *
 * I've thrown out STiNG compat except by returns
 * To make this section STiNG compat would require rewritting alot
 * more of STiK than I would care to.
 * If we put the calls in for his structures then we will be forced
 * to put these on for our RAW routines.  Which I don't like the 
 * idea of.
 *
 * data now points to a msg_data structure
 *
 *  typedef struct msg_data {
 *      uint8   ttl;              Time to live                                
 *      uint16  id;               Packet identifier (For ping etc.)         
 *      uint16  seq;              Packet sequence (For ping etc.)           
 *		uint16	extra1;			  extra uint16 number 1 - for later use	
 *		uint16  extra2;
 *		uint16  extra3;
 *  	char *	msg;			  message for ICMP send 
 *  } MSG_DATA;
 *
 */

int16
cdecl  ICMP_send (uint32 dest_host, uint8 type, uint8 code, void *data, uint16 length)
{
    register GPKT *pp;
    register ICMP_HDR *icmph;
	MSG_DATA *pkt_data = (MSG_DATA *)data;
	struct ip_options opts;

	/* Should probably set alot more of this options structure
	 * I'm going to be bad at the moment and only set what I need
	 * So if you are going through and find this sorry - baldrick
	 */
	/*short		pri;		 priority 		*/
	opts.ttl = pkt_data->ttl;		/* Time to live 	*/	opts.tos = 0;		/* Type of Service 	*/
	/*unsigned 	hdrincl:1;	 header included? */   
    /*uint16  *buffer = (uint16 *)data;*/

	/* Normal check for carrier loss */

	if (dest_host != config.localhost)
	{
	    if (carrier_detect() < 0)
	       return (E_LOSTCARRIER);
	}
       
    /* make packet */
       
    pp = mkpacket(dest_host, (int16)(length + sizeof(ICMP_HDR)), (int16)P_ICMP);

    if (pp == (GPKT *)NULL)
        return (E_NOMEM);

    icmph = (ICMP_HDR *)pp->mp;

    icmph->id = pkt_data->id;
    icmph->seq = pkt_data->seq;
    icmph->type = type;
    icmph->code = code;

    pp->data = (char *)&icmph[1];
    memcpy(pp->data, pkt_data->msg, length);

    icmph->sum = 0;
    icmph->sum = calc_sum((char *)icmph, 0, (int16)(length + sizeof(ICMP_HDR)));

    ip_send(pp, &opts, FLAG_DF);

    return (E_NORMAL);
}

/* This routine places 'handler' into a dummy function holder,
 * STiK will then pass some ICMP errors to it.  Haven't really 
 * played with it yet so don't know what ones ;)
 *
 * install_code definitions are above
 */

int16
cdecl  ICMP_handler (void *handler, int16 install_code)
{
	if (install_code < 0 || install_code > 3)
		return(E_PARAMETER);

	if (install_code == HNDLR_REMOVE)
		return(stop_icmp_listen());

	return(start_icmp_listen(handler,install_code));
}

void
cdecl  ICMP_discard (GPKT *datagram)
{
	delete_packet((GPKT *)datagram, EI_ICMPTYPE);
}


