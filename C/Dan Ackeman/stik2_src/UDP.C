/*  udp.c                (c) Steve Adam 1995         steve@netinfo.com.au
 *
 *      User Datagram Protocol routines.
 *
 *      UDP will be used by `opening' a kind of virtual connection.
 *  UDP_open() creates a Connection and returns a handle.  Any calls
 *  to UDP_send() send the data according to the address/port
 *  recorded in the CCB.
 */
#include "lattice.h"
#include <stdio.h>
#include <string.h>
#include "krmalloc.h"
#include "globdefs.h"
#include "globdecl.h"


extern CCB ctn[];  /* Connection Control Block list */

/*  udp_in()    This is where IP sends UDP packets
 *
 *      Basically just verify the checksum and pass it on
 *  to the input module.
 */

void udp_in(GPKT *p, UDP_HDR *udph)
{
    PH psh;
    uint16 sum = 0;
    IP_HDR *iph = (IP_HDR *)p->pip;

    if (udph->sum != 0) {        /* UDP has `don't care' option...       */
        psh.s_ip = iph->s_ip;
        psh.d_ip = iph->d_ip;
        psh.ptcl = iph->ptcl;
        psh.len = p->mlen;

        sum = oc_sum((char *)&psh, (uint16)sizeof(PH));     /* Pseudo header sum    */

        if (calc_sum((char *)udph, sum, p->mlen) != 0) {  /*swampy's quick fix */
            delete_packet(p, EU_UDPSUM);   /* Ooops.  Checksum failure  */
            return;
        }
    }

    /* Set pointers to UDP data before sending it to the queue  */
    p->data = (char *)&udph[1];
    p->dlen = p->mlen - (int16)sizeof(UDP_HDR);

    q_udp_in(p, udph);    /* Goes to the input module */
}


/*  udp_send()      Create and send a UDP packet
 *
 *      Well, like it says....
 */

int16 cdecl UDP_send(int16 cn, char *data, int16 dlen)
{
    GPKT *p;
    IP_HDR *iph;
    UDP_HDR *udph;
    struct ip_options opts;

    PH psh;
    uint16 sum = 0;

    if (ctn[cn].protocol != IPPROTO_UDP)
        return(E_BADHANDLE);

	if (ctn[cn].rhost != config.localhost)
	{
	    if (carrier_detect() < 0)
	        return (E_LOSTCARRIER);
	}
	
    p = mkpacket(ctn[cn].rhost, dlen + (int16)sizeof(UDP_HDR), (int16)P_UDP);
    if (p == (GPKT *)NULL)
        return (E_NOMEM);

	p->mlen = dlen + (int16)sizeof(UDP_HDR);

    iph = (IP_HDR *)p->pip;
    udph = (UDP_HDR *)p->mp;

    udph->sport = ctn[cn].lport;
    udph->dport = ctn[cn].rport;
    udph->length = p->mlen;
    udph->sum = 0;

    p->data = (char *)&udph[1];
    memcpy(p->data, data, dlen);

    psh.s_ip = iph->s_ip;
    psh.d_ip = iph->d_ip;
    psh.ptcl = iph->ptcl;
    psh.len = p->mlen;

    sum = oc_sum((char *)&psh, (uint16)sizeof(PH));
    sum = calc_sum((char *)p->mp, sum, p->mlen);
    if (sum == 0)
        sum = 0xffff;

    udph->sum = sum;

	/* Get connection's tos and ttl from CCB */
	
	opts.tos = ctn[cn].ip.tos;
	opts.ttl = ctn[cn].ip.ttl;

    ip_send(p, &opts, FLAG_LF);

    return (E_NORMAL);
}

void
udp_icmp(uint8 type, uint8 code, UDP_HDR *udph, uint32 naddr)
{
    int16 cn;

    for (cn = 0; cn < CNMAX; ++cn) 
   	{
   	    if (udph->dport == ctn[cn].lport && ctn[cn].protocol == IPPROTO_UDP)
   	        break;
   	}

    if (cn >= CNMAX) 
   	{
   	    /* Failed to find the destination   
   	     * so we will ignore it 
   	     */
    	     
   	    return;
   	}

    /* Destination Unreachable and Time Exceeded messages never kill a
     * connection; the info is merely saved for future reference.
     */
    switch ((uint8)type) 
    	{
		    case 3  :   /* Destination unreachable  */
				/* Errors really need to be expanded to handle bad protocols etc */
   				ctn[cn].error = E_UNREACHABLE;
   				break;

		    case 11 :   /* Time exceeded            */
				ctn[cn].error = E_TTLEXCEED;
		        break;

		    case 4  :   /* Quench                   */
				/* Basically ignore no use in UDP	*/
		        break;

        	case 5  :   /* Redirect					*/
        		/* I'm going to set the redirect here and not in ip_send */
        		ctn[cn].rhost = naddr;
        		break;
    	}
}

