/*  ip.c                (c) Steve Adam 1995         steve@netinfo.com.au
 *
 *      This file contains ip and (minimal) icmp functions, as well
 *  as a function to initially create an output packet.
 *
 */
#include "lattice.h"
#include <stdio.h>
#include <string.h>
#include "krmalloc.h"
#include "globdefs.h"
#include "globdecl.h"
#include "display.h"

extern void udp_icmp(uint8 type, uint8 code, UDP_HDR *udph, uint32 naddr);

/*  Defragmentation Handling Routines.
 *  Now that I've had my first fragmented datagram (from a nameserver!)
 *  it's clear that I *will* need to handle this situation.  So, it's
 *  RFC815 to the rescue.  What follows is lifted from there...
 *
 *  Since I intend to systematically ignore IP options (if possible)
 *  the defrag procedure does exactly this... (Wish me luck!)
 *  However, it creates a maximum sized internet header in the
 *  assembled datagram, for the sake of the future.
 */

/*  First some defragging structures    */

/* These will be placed in the actual holes, per RFC815 */
typedef struct df_hole {    /* The `hole' list.  For a linked list  */
    uint16  first;          /* First octet of this hole             */
    uint16  last;           /* Last octet of this hole (len - 1)    */
    struct  df_hole *next;  /* Address of next hole                 */
} DF_HOLE;

typedef struct df_id {
    uint32 source;      /* Source IP        */
    uint32 dest;        /* Dest ID          */
    uint16 ident;       /* IP Identifier    */
    uint16 protocol;    /* IP protocol, really only 8 bits, but...  */
} DF_ID;

typedef struct defrag {
    GPKT    *dfp;       /* Pointer to the defrag space. */
    char    *data;      /* Pointer to the data after the header space   */
    DF_ID   uid;        /* Unique (hopefully) ID for this descripter    */
    DF_HOLE *hole1;     /* Index of start of hole linked list   */
    clock_t expire;     /* Set to a time when this packet should expire */
} DEFRAG;

static DEFRAG *fraglist[DFMAX];     /* Up to 20 refrags at a time   */

static void add_hole(DEFRAG *d, uint16 first, uint16 last)
{
    DF_HOLE *h, *nh;

    nh = (DF_HOLE *)&d->data[first];
    nh->first = first;
    nh->last = last;
    nh->next = (DF_HOLE *)NULL;

    if (d->hole1 == (DF_HOLE *)NULL) {
        d->hole1 = nh;
        return;
    }

    h = d->hole1;

    while (h->next)
        h = h->next;

    h->next = nh;
}

void remove_hole(DEFRAG *d, DF_HOLE *rh)
{
    DF_HOLE *h = d->hole1;

    if (d->hole1 == rh) {   /* Special case if first entry matches  */
        d->hole1 = rh->next;
        return;
    }

    while (h->next != rh)
        h = h->next;

    h->next = rh->next;
}

/*  new_frag()  * See RFC815 *
 *
 *      Does the packet reassembly work, and returns a packet to
 *  the caller if completed (After cleaning up, of course)
 */

GPKT *new_frag(GPKT *p, uint16 dfi, IP_HDR *iph)
{
    uint16 frfirst, frlast, frflags, frlen;
    char *frdata;
    DEFRAG *dp;
    DF_HOLE *dh;

    frdata = p->mp;
    frlen = p->mlen;
    frfirst = iph->ofst & 0x1fff;            /* Strip flags      */
    frfirst *= 8;                            /* Oops. Size * 8   */
    frlast = frfirst + frlen - 1;
    frflags = iph->ofst & FLAG_MF;           /* 0 = last frag    */

	if (config.df_bufsize < frlast + 61) {      /* dfb size exceeded */
        delete_packet(fraglist[dfi]->dfp, EI_DFBEXCEEDED);

        while(STiKfree((char *)fraglist[dfi]) == E_LOCKED)
        	;

        fraglist[dfi] = (DEFRAG *)NULL;
        delete_packet(p, NF_ADDFRAG);
		return ((GPKT *)NULL);
	}

    dp = fraglist[dfi];
    dp->expire = Sclock() + (time_t)CLK_TCK * (iph->ttl & 0xff);

    if (frflags == 0) { /* This is endmost fragment, so set packet length   */
        iph = (IP_HDR *)dp->dfp->pip;
        iph->len = dp->dfp->ip_len = frlast + 61;
        dp->dfp->mlen = frlast + 1;
    }

    dh = dp->hole1;

    while (dh) {  /* 0xffff is endlist value for links    */

        if ((frfirst > dh->last) || (frlast < dh->first)) { /* Steps 2,3    */
            dh = dh->next;
            continue;
        }

        remove_hole(dp, dh);

        /* On to step 5.  Data in dh is still valid, though */

        if (frfirst > dh->first)     /* Step 5, start of hole not changed    */
            add_hole(dp, dh->first, frfirst - 1);

        if (frlast < dh->last && frflags) {   /* Step 6   */
            add_hole(dp, frlast + 1, dh->last);
        }
        /* Step 7: continue with next descriptor    */
        dh = dh->next;
    }
    memcpy(&dp->data[frfirst], frdata, (size_t)frlen);  /* Copy the actual data */
    delete_packet(p, NF_ADDFRAG);

    if (dp->hole1 == (DF_HOLE *)NULL) { /* Reassembly complete! */
		/* First, get a smaller block */
		frdata = STiKmalloc((long)(dp->dfp->ip_len));

		/* Only copy it over if we can get a smaller packet */
		if (frdata)
		{
			/* Copy over into the new, smaller structure */
			memcpy(frdata, dp->dfp->pip, (long)(dp->dfp->ip_len));

			/* Free the larger block */
			while(STiKfree(dp->dfp->pip)==E_LOCKED)
				;

			/* Set up the pointers */
			dp->dfp->pip = dp->dfp->fp = frdata;
			dp->dfp->mp = &frdata[60];
		}

		/* Set the return pointer and free the defrag structure */
        p = dp->dfp;
        while(STiKfree((char *)dp) == E_LOCKED)
        	;
        	
        fraglist[dfi] = (DEFRAG *)NULL;

        return(p);  /* This should be a completed packet returned!! */
    }
    else {
        return ((GPKT *)NULL);
    }
}


/*  frag_ttl_check()
 *
 *      Check expiry time of reassembling packets.  Discard if overdue.
 */

void frag_ttl_check(void)
{
    int x;

	if (set_flag(FL_frag_ttl_check))
		{
			return;
		}


    for (x = 0; x < DFMAX; ++x) {
        if (fraglist[x] == (DEFRAG *)NULL)
            continue;

        if (fraglist[x]->expire > Sclock())
            continue;

        delete_packet(fraglist[x]->dfp, EI_TTLZERO);
        while(STiKfree((char *)fraglist[x])==E_LOCKED)
        	;
        fraglist[x] = (DEFRAG *)NULL;
    }
    
    	clear_flag(FL_frag_ttl_check);
}

static int initfrag(GPKT *p, DF_ID *nf)
{
    register int dx;
    register DEFRAG *d;
    register IP_HDR *iph;

    for (dx = 0; dx < DFMAX; ++dx) 
    { 
        /* Find a free FRAG descriptor  */
        if (fraglist[dx] == (DEFRAG *)NULL)
            break;
    }

    if (dx >= DFMAX) 
    {
        delete_packet(p, EF_LISTFULL);
        return (-1);
    }

    d = (DEFRAG *)STiKmalloc( (long)sizeof(DEFRAG) );
    
    if (d == (DEFRAG *)NULL) {
        delete_packet(p, EA_NOMEMORY);
        return (-1);
    }

    d->dfp = allocate_packet(config.df_bufsize);
    if (d->dfp == (GPKT *)NULL)
    {
        while(STiKfree((char *)d) == E_LOCKED)
        	;
        	
        delete_packet(p, EA_NOMEMORY);
        return (-1);
    }
    fraglist[dx] = d;   /* Right, we're on the way...   */

    /*  But now we need to put an internet header into the
     *  allocated block, and set some values.  For the sake
     *  of option processing (later) the defragged datagram
     *  will have a header size of 60 octets.
     *  Since no serious processing of the internet header
     *  is done after reassembly, we don't need to do much.
     */

    iph = (IP_HDR *)d->dfp->pip;
    *iph = *((IP_HDR *)p->pip); /* Copy the header from this fragment   */
    d->dfp->mp = &d->dfp->pip[60];
    d->data = d->dfp->mp;
    iph->ihl = 15;           /* Set IP header to max size    */
    d->dfp->pip[20] = 0;        /* Put an `end' in the options list */

    d->uid = *nf;               /* Set unique identifier        */

    add_hole(d, 0, config.df_bufsize - 61);

    return (dx);
}

static int matchfrag(DF_ID *nf)
{
    register int x;

    for (x = 0; x < DFMAX; ++x) {
        if (fraglist[x] != (DEFRAG *)NULL) {
            if (!memcmp(&fraglist[x]->uid, nf, sizeof(DF_ID)))
                return (x);
        }
    }
    return (-1);
}

/* frag_in()    IP calls this function when a fragment turns up
 *
 *      It returns a pointer to a reconstituted datagram or NULL
 */

static GPKT *frag_in(GPKT *p, IP_HDR *iph)
{
    DF_ID nf;           /* Unique info for the new fragment */
    register int dfi;   /* Index to defrag list             */

    nf.source = iph->s_ip;
    nf.dest = iph->d_ip;
    nf.protocol = iph->ptcl;
    nf.ident = iph->id;

    if ((dfi = matchfrag(&nf)) == -1) {
        dfi = initfrag(p, &nf);
    }
    if (dfi < 0)
        return (GPKT *)NULL;
    else
        return (new_frag(p, dfi, iph));
}

/*  oc_sum()    get one's compliment sum of data
 *
 *      This is exactly like calc_sum except that the value returned
 *  is just the sum, *NOT* the one's compliment of the sum.
 *  This is to be used to calculate the sum of a psuedo header
 *  prior to calling calc_sum().  The result of this function is
 *  passed to calc_sum() as an initial sum value.  This saves
 *  stuffing around making everything contiguous in memory
 *  prior to calling calc_sum().
 */

uint16 oc_sum(char *p, uint16 count)
{
    register int32 sum = 0L;
    register uint16 *addr = (uint16 *)p;

    if ((long)p % 2) {
        sum = *p;
        addr = (uint16 *)&p[1];
        count -= 1;
    }

    while (count > 1) {
        sum += *addr++;
        count -= 2;
    }

    if (count > 0)
        sum += (((uint16)(*(uint8 *)addr))<<8); /*(*(uint8 *)addr) << 8;*/

    while (sum >> 16)
        sum = (sum & 0xffff) + (sum >> 16);

    return ((uint16)sum & 0xffff);
}


/*  calc_checksum()
 *
 *      This is the checksum routine (Taken from RFC1071) used
 *  to perform all internet checksumming.  Apparently much time
 *  can be lost in internet hosts doing checksumming, but
 *  even on a 8mhz 68000, at 19200 baud it can't make too
 *  much difference on a point to point machine.
 *
 *  I have done some timings with this function, which takes
 *  1.8 milliseconds to checksum a single 512 byte block of text.
 *  Thus I calculated (roughly) that at a stretch, this function
 *  could calculate sums on all data in both directions at
 *  maximum throughput on a modem 74 times faster than mine.
 *  Let's see, that would be 1.42mbit/sec.  Very unlikely.
 *  Of course, there'd be no cycles left for anything else,
 *  but all the same, I don't feel I need to worry.....
 *
 *  Note that I've added an initial value for the checksum
 *  calculation.  This is so that a partial value from a
 *  Pseudo Header can be calculated first then passed to
 *  this function.  This saves the hassle of making the
 *  data contiguous with the pseudo header prior to
 *  calculating the checksum.  See oc_sum() above.
 */

uint16 calc_sum(char *p, uint16 initial, uint16 count)
{
    register int32 sum = initial;
    register uint16 *addr = (uint16 *)p;

    if ((long)p % 2) {
        sum = *p;
        addr = (uint16 *)&p[1];
        count -= 1;
    }

    while (count > 1) {
        sum += *addr++;
        count -= 2;
    }

    if (count > 0)
        sum += (((uint16)(*(uint8 *)addr))<<8); /* (*(uint8 *)addr) << 8;*/

    while (sum >> 16)
        sum = (sum & 0xffff) + (sum >> 16);


    return ((uint16) ~sum & 0xffff);
}


/*  ip_in()
 *
 *      This function is called by slip_in() whenever a complete
 *  packet turns up.  If it is unrecognisable or somehow invalid,
 *  then discard it silently.  If it can't be delivered, also
 *  discard it, but later we should add some ICMP for this.....
 *  The procedure is basically to do checksum checking, then
 *  distribute to the value in `protocol'.  While we're here,
 *  though, we set up some pointers in the GPKT structure that
 *  contains the packet.
 */ 
int pktfd = 0;
void ip_in(GPKT *np)
{
    int hlen;
    IP_HDR *iph;
	static void icmp_in(GPKT *, ICMP_HDR *);

    iph = (IP_HDR *)np->pip;	
	
    /* Update byte count statistics */
    if (iph->s_ip == config.provider)
        elog[CI_LOCALIN] += np->ip_len;
    else
        elog[CI_FOREIGNIN] += np->ip_len;

    if (iph->ver != IP_VERSION) {
        delete_packet(np, EI_VERSION);  /* This is how we `ignore' packets  */

		if (config.reports == 1)
			disp_info("Dropped packet! bad IP_VERSION  %d",iph->ver);
				
        return;                         /* It's easy, really....            */
    }

    hlen = iph->ihl * 4;              /* Number of octets in ip header    */


    if (calc_sum(np->pip, 0, hlen) != 0)  
	{
        delete_packet(np, EI_SUM);      /* Ooops.  header checksum failure  */
		
		if (config.reports == 1)
	        disp_info("Dropped packet! check sum failed");
			
        return;
    }


/*
    if (hlen > 20) {  Ignore ip options for the time being. Maybe forever..
        np->ip_optlen = hlen - 20;
        np->ip_opt = &np->pip[20];
    }
*/

    /*  Note we will need to fix this when router is included */
    
    if ((iph->d_ip != config.client_ip) && (iph->d_ip != config.localhost))
	{   /* Packet addressed to us?  */
	    if((unsigned char)(iph->d_ip >> 24) == 0xE0)
    		{
    			/*printf("Grabbed multicast\r\n");*/
    		}
 		else if ((unsigned char)(iph->d_ip >> 24) == 0)
 			{
 				/* INADDR_ANY */
 			}
    	else
    		{	
				/*printf(" d_ip %ld our ip %ld\r\n",iph->d_ip,config.client_ip);*/

    		    delete_packet(np, EI_ADDRESS);  /* Generate ICMP msg? LOG_IT        */
				
				if (config.reports == 1)
	    		    disp_info("Dropped packet! bad route");
		    		
    		    return;
    		 }
    }

    /*  Now set up some GPKT fields.
     */

    np->ip_len = iph->len;              /* Size of whole packet             */

    /* Set generic message values (Required for defrag) */

    np->mp = &np->pip[hlen];
    np->mlen = np->ip_len - hlen;

    /* Check for fragments to process */

    if (iph->ofst & ~FLAG_DF) {             /* Check for frag, but !FLAG_DF */
        elog[NI_FRAGMENT] += 1;
        if ((np = frag_in(np, iph)) == (GPKT *)NULL)
            return;

		/* Now we must reset iph since frag_in most likely copied the entire
			packet over to a new area of dynamic memory */
		iph = (IP_HDR *)np->pip;
    }
    
/*	if (pktfd <= 0)
		pktfd = Fcreate("pkt.log", 0);

    Fwrite(pktfd, 2L, &np->ip_len);
    Fwrite(pktfd, (long)np->ip_len, np->pip);
*/

    /* Now send it to the appropriate handler and update a field or two     */

    switch (iph->ptcl)
    {
    case IPPROTO_ICMP :	icmp_in(np, (ICMP_HDR *)np->mp);
						break;

    case IPPROTO_IGMP : ICMP_err_return(np, 3, 2);   /* IGMP unsupported at the moment, just avoids the alert*/
						break;

    case IPPROTO_UDP  :	udp_in(np, (UDP_HDR *)np->mp);
						break;

    case IPPROTO_TCP  :	tcp_in(np, (TCP_HDR *)np->mp);
						break;

	case IPPROTO_RAW  :	RAW_in(np);
						break;
						
    default     	  :	disp_info("Don't know protocol: %d",iph->ptcl);
        				ICMP_err_return(np, 3, 2);   /* And now it is (is what ????)   */
        				elog[EI_PROTOCOL] += 1;
        				return;
    }
    
    return;
}
 

/*  mkpacket()  Create a new GPKT packet
 *
 *      This function creates a packet and partially initialises
 *  it.  The parameters supply certain information that we insert
 *  into the header.  The object of having it created here is that
 *  IP then has control over the size of the IP header.  This isn't
 *  really important now, but might come in handy if we need to set
 *  IP options.
 */

GPKT *
mkpacket(uint32 dest, int16 msg_size, int16 protocol)
{
    GPKT *p;
    register IP_HDR *iph;
    uint16 tlen = (uint16)(msg_size + sizeof(IP_HDR));

    switch (protocol) {
    case P_ICMP :
    case P_TCP  :
    case P_UDP  :
    case IPPROTO_RAW:
        break;
    default     :
        elog[EI_SNDPROTO] += 1;
        return (GPKT *)NULL;
    }

    p = allocate_packet(tlen);
    if (p == (GPKT *)NULL)
        return (GPKT *)NULL;    /*  Couldn't allocate packet */

    iph = (IP_HDR *)p->pip;
    iph->ihl = (unsigned)sizeof(IP_HDR)/4;
    iph->ver = IP_VERSION;
    iph->ptcl = protocol;
    iph->len = tlen;
    iph->d_ip = dest;
    iph->s_ip = config.client_ip;

    p->ip_len = tlen;
    p->mp = (char *)&iph[1];

    return(p);
}    



/*  ip_send()       Send an IP packet
 *
 *      By the time we get here, we can assume that the packet has
 *  been fully created except for tos, ttl, and the IP header checksum.
 *  So, just do this and send the packet out.
 *
 *  Later other decisions/actions might need to be made here...
 *  (ie: option decisions)
 */

uint16 unique_id;   /* Initialised to random value in main.c at startup */

void ip_send(GPKT *p, struct ip_options *options, uint16 ff)
{
    IP_HDR *iph = (IP_HDR *)p->pip;

     iph->tos = options->tos;
    iph->ttl = options->ttl;
    iph->id = unique_id++;
    iph->ofst = ff;
	/*iph->optlen = 0;*/

    iph->sum = 0;
    iph->sum = calc_sum(p->pip, 0, (uint16)sizeof(IP_HDR));

    /* Update byte count statistics */
    if (iph->d_ip == config.provider)
        elog[CI_LOCALOUT] += p->ip_len;
    else
        elog[CI_FOREIGNOUT] += p->ip_len;

	/* Should we route this packet outbound? */

/*	if (iph->d_ip == config.localhost)*/

    if ((iph->d_ip == config.client_ip) || (iph->d_ip == config.localhost))
		{		
			ip_in(p);
			return;
		}
	else
	    output_packet(p);   /* Send to output queue */
}

/*  icmp_in()
 *
 *  Respond to incoming ICMP packets.
 *
 *  At the moment, just respond to echo requests and replies
 *  and discard everything else.
 *
 *  Heavely ammended by Dan Ackerman 2/14/98
 */

void icmp_in(GPKT *p, ICMP_HDR *icmph)
{
    IP_HDR *ip;
    TCP_HDR *tcp;
    UDP_HDR *udp;
	ICMP_REDIR *naddr;
	uint32 newaddr = 0L;
    int iphlen;
	static void ansping(GPKT *p, ICMP_HDR *icmph);

	/* Locate icmp structure in GPKT and check
	 * that it is not corrupted and of at least minimum length
	 */
	 
	if (p->ip_len < 8)
		{
			/* ICMP min length is 8 */

    	    delete_packet(p, EI_ICMPSUM);   /* This isn't correct but I don't feel like adding it right now and this will do  */
			return;		
		}

    if (calc_sum((char *)icmph, 0, p->mlen) != 0)
    	{  
    		/*swampy's quick fix */

    	    delete_packet(p, EI_ICMPSUM);   /* Ooops.  Checksum failure  */
			return;
	    }

    /* Count all (most) ICMP messages for the stat log */

    switch (icmph->type) {
    case 0  :
    	/* Echo Reply RFC 792*/
    
        elog[EI_ECHOREPLY] += 1;
        q_icmp_reply(p);
        break;

    case 3  :
    	/* Destination Unreachable RFC 792 */
    
        switch (icmph->code) {
            case ENETUNREACH  :
            	/* Net Unreachable */
                elog[EI_URNET] += 1;
                break;
            case EHOSTUNREACH :
            	/* Host Unreachable */
                elog[EI_URHOST] += 1;
                break;
            case 2  :
            	/* Protocol Unreachable */
                elog[EI_URPROTO] += 1;
                break;
            case 3  :
            	/* Port Unreachable */
                elog[EI_URPORT] += 1;
                break;
            case 4  :
            	/* Fragmentation Needed and Don't Fragment was Set */
            case 5  :
            	/* Source Route Failed */
            case 6  :
            	/* Destination Network Unknown */
            case 7  :
            	/* Destination Host Unknown */
            case 8  :
            	/* Source Host Isolated */
            case 9  :
            	/* Communication with Destination Network is			               Administratively Prohibited */
            case 10  :
            	/* Communication with Destination Host is			               Administratively Prohibited */
            case 11  :
            	/* Destination Network Unreachable for Type of Service */
            case 12  :
            	/* Destination Host Unreachable for Type of Service */
                break;
            default :
                ;
        }
        break;

    case 4  :
    	/* Source Quench RFC 792*/
        elog[EI_QUENCH] += 1;
        break;

	case 5  :
		/* Redirect RFC 792*/

		naddr = (ICMP_REDIR *)p->mp;

        switch (icmph->code) {
            case 0  :
            	/* Redirect Datagram for the Network (or subnet) */
            	break;

            case 1  :
            	/* Redirect Datagram for the Host */
            case 2  :
            	/* Redirect Datagram for the Type of Service and Network */ 
            case 3  :
            	/* Redirect Datagram for the Type of Service and Host */
            default:
				;
		}

		newaddr = naddr->newaddr;

		break;
	
	case 6  :
		/* Alternate Host address */

		switch(icmph->code){
			case 0  :
				/* Alternate Address for Host */
				break;
				
			default:
				;
		}
		break;
		
    case 8  :
    	/* Echo RFC 792*/
        elog[EI_ECHOREQUEST] += 1;
        ansping(p, icmph);
        return;
        
    case 9  :
    	/* Router Advertisement RFC 1256*/
    	break;
    	
    case 10 :
    	/* Router Selection RFC 1256 */
    	break;
    	
    case 11 :
    	/* Time Exceeded RFC 792 */
    	
        switch (icmph->code) {
            case 0  :
            	/* Time To Live exceeded in Transit */
                elog[EI_TTLTRANS] += 1;
                break;
            case 1  :
            	/* Fragment Reassembly Time Exceeded */
                elog[EI_TTLFRAG] += 1;
                break;
            default:
            	;
        }
        break;

    case 12 :
    	/* Parameter Problem RFC 792 */
    	
    	switch (icmph->code) {
    		case 0  :
    			/* Pointer indicates the error */
    			break;
    		
    		case 1  :
    			/* Missing a Required Option RFC 1108 */
    			break;
    			
    		case 2	:
    			/* Bad length */
    			break;
    			
    		default:
    		;
    	}  
        elog[EI_BADPARAM] += 1;
        break;
        
     case 13 :
     	/* Timestamp  RFC 792 */
     	break;
     	
     case 14 :
     	/* Timestamp Reply RFC 792 */
     	break;
     	
     case 15 :
     	/* Information Request RFC 792 */
     	break;
     	
     case 16 :
     	/* Information Reply RFC 792 */
     	break;
     	
     case 17 :
     	/* Address Mask Request RFC 950 */
     	break;
     	
     case 18 :
     	/* Address Mask Reply RFC 950 */
     	break;

     /* 19 Reserverd for Security */
     /*	20-29 Reserved for Robustness Experience */
     
     case 30 :
     	/* Traceroute  RFC 1393 */
     	break;
     	
     case 31 :
     	/* Datagram Conversion Error RFC 1475 */
     	break;
     	
     default:
     	;

    }

    ip = (IP_HDR *)&p->mp[sizeof(ICMP_HDR)];

    if (ip->ptcl == IPPROTO_TCP) {
        iphlen = ip->ihl * 4;        /* Number of octets in ip header    */
        tcp = (TCP_HDR *)&p->mp[sizeof(ICMP_HDR) + iphlen];

        tcp_icmp(ip->d_ip, icmph->type, icmph->code, tcp, newaddr);

        delete_packet(p, EI_TCPICMP);
        return;
    }
	else if (ip->ptcl == IPPROTO_UDP) 
		{
			iphlen = ip->ihl * 4;   /* Number of octets in ip header */
			udp = (UDP_HDR *)&p->mp[sizeof(ICMP_HDR) + iphlen];
		
			udp_icmp(icmph->type, icmph->code, udp, newaddr);

			delete_packet(p, EI_TCPICMP); /* Another bad mapping need to expand elog */
			return;
		}

RIP: /* If we get a code that's outside of normal ICMP goto RIP */
	RAW_in(p);
	
	return;

   /* delete_packet(p, EI_ICMPTYPE);           Unknown Type */
}


/*  ping()     send a ICMP echo request message
 *
 *      Create a packet and fill it with the appropriate data
 *  as specified by the user, then send it out.
 *
 *  return 0 if ping sent OK, otherwise -1 (Or another code? LOG_IT)
 */

int ping(uint32 host, int16 seq, int16 id, char *data, int16 dlen)
{
    register GPKT *pp;
    register ICMP_HDR *icmph;
    struct ip_options	opts;

    pp = mkpacket(host, (int16)(dlen + sizeof(ICMP_HDR)), (int16)P_ICMP);
    if (pp == (GPKT *)NULL)
        return (-1);

    icmph = (ICMP_HDR *)pp->mp;

    icmph->id = id;
    icmph->seq = seq;
    icmph->type = 8;
    icmph->code = 0;

    pp->data = (char *)&icmph[1];
    memcpy(pp->data, data, dlen);

    icmph->sum = 0;
    icmph->sum = calc_sum((char *)icmph, 0, (int16)(dlen + sizeof(ICMP_HDR)));

	opts.tos = 0;
	opts.ttl = config.ping_ttl;
	
    ip_send(pp, &opts, FLAG_DF);
    return (0);
}

/*  ansping()   Quick reply to a ping from a foreign host
 */

static void ansping(GPKT *p, ICMP_HDR *icmph)
{
    uint32 tmp;
    IP_HDR *iph = (IP_HDR *)p->pip;

    tmp = iph->d_ip;
    iph->d_ip = iph->s_ip;
    iph->s_ip = tmp;

	/* Dan removed the next line, he couldn't see any particular */
	/* instance where it would be useful and he wasn't certain */
	/* why Steve did it. It's possible that what he really wanted */
	/* to do was reduce the timer for the connection. */
    /*iph->ttl -= 1;*/           /* Lower TTL, what the hell.... */

    icmph->type = 0;
    icmph->sum = 0;

    icmph->sum = calc_sum((char *)icmph, 0, p->mlen);

    iph->sum = 0;   /* Zero sum before new calculation  */
    iph->sum = calc_sum(p->pip, 0, (int16)sizeof(IP_HDR));

	if ((iph->d_ip == config.localhost)||(iph->d_ip == config.client_ip))
		{		
			ip_in(p);
			return;
		}
	else
	    output_packet(p);
}

void ICMP_err_return(GPKT *p, int16 type, int16 code)
{
    uint32 tmp;
    int16 hlen, cplen;
    register IP_HDR *iph = (IP_HDR *)p->pip;
    register ICMP_HDR *icmph;
	struct ip_options	opts;

    hlen = iph->ihl * 4; /* Number of octets in ip header */
    cplen = hlen + 8;       /* 64 bits of original datagram */

    icmph = (ICMP_HDR *)&p->pip[hlen];
    memcpy((char *)&icmph[1], p->pip, cplen);

    icmph->type = type;
    icmph->code = code;
    icmph->sum = 0;
    icmph->id = 0;
    icmph->seq = 0;

    p->mlen = cplen + (int16)sizeof(ICMP_HDR);
    icmph->sum = calc_sum((char *)icmph, 0, p->mlen);

    p->ip_len = hlen + p->mlen;

    tmp = iph->d_ip;
    iph->d_ip = iph->s_ip;
    iph->s_ip = tmp;

    iph->ptcl = P_ICMP;
    iph->len = p->ip_len;

    if (hlen > sizeof(IP_HDR))
        memset(&iph[1], 0, hlen - sizeof(IP_HDR));

	opts.tos = 0;
	opts.ttl = config.ttl;
	
    ip_send(p, &opts, FLAG_DF);
}
