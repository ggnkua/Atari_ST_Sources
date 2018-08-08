/* This module contains all TCP input/output/control routines.
 *
 * Inspired by Phil Karn, KA9Q
 */
#include "lattice.h"
#include <stdio.h>
#include <string.h>
#include "krmalloc.h"
#include "globdefs.h"
#include "globdecl.h"
#include "display.h"

extern CCB ctn[];  /* Max number of connections at any time.   */

/*#define PREC(x) (x&0x07)*/

static void tcp_reset(GPKT *);
static void add_reseq(TCB *, GPKT *);
static GPKT *get_reseq(TCB *);
static int trim(TCB *, GPKT *);
static int in_window();
static void update(int16, TCB *, GPKT *);
static void proc_syn(TCB *, GPKT *);


#define	RTTCACHE 16     /* # of TCP round-trip-time cache entries */

struct tcp_rtt Tcp_rtt[RTTCACHE];

#define	NULLRTT	(struct tcp_rtt *)0

/* Round trip timing cache routines.
 * These functions implement a very simple system for keeping track of
 * network performance for future use in new connections.
 * The emphasis here is on speed of update (rather than optimum cache hit
 * ratio) since rtt_add is called every time a TCP connection updates
 * its round trip estimate.
 */
void rtt_add(uint32 addr, int32 rtt)
{
    struct tcp_rtt *tp;
	int32 abserr;

	if(addr == 0)
		return;
	tp = &Tcp_rtt[(unsigned short)addr % RTTCACHE];
	if(tp->addr != addr){
		/* New entry */
		tp->addr = addr;
		tp->_srtt = rtt;
		tp->_mdev = 0;
	} else {
		/* Run our own SRTT and MDEV integrators, with rounding */
		abserr = (rtt > tp->_srtt) ? rtt - tp->_srtt : tp->_srtt - rtt;
		tp->_srtt = ((AGAIN-1)*tp->_srtt + rtt + (AGAIN/2)) >> LAGAIN;
		tp->_mdev = ((DGAIN-1)*tp->_mdev + abserr + (DGAIN/2)) >> LDGAIN;
	}
}

struct tcp_rtt *rtt_get(int32 addr)
{
	register struct tcp_rtt *tp;

	if(addr == 0)
		return NULLRTT;
	tp = &Tcp_rtt[(unsigned short)addr % RTTCACHE];
	if(tp->addr != addr)
		return NULLRTT;
	return tp;
}

/*  geniss()    Allocate an appropriate local initial sequence number
 *
 *      RFC793 recommends (demands?) initialisation using a clock that
 *  cycles every 4 microseconds.  I don't have such a clock, so I'll use
 *  the day time in seconds << 18.  2^18 = 262,144, which is close enough
 *  to multiplying by 250,000.
 *  Changed to Sclock() to avoid calling time() in interrupt
 */

static uint32 geniss(void)
{
    register uint32 x;

    x = ((uint32)Sclock() << 18);

    return(x - x % 10000);
}

/*  Return a wait time which is at least current time + interval
 */

clock_t set_time(clock_t interval)
{
    return (Sclock() + (interval/(1000L/CLK_TCK) + 1));
}


/* Sequence number comparisons
 * Return true if x is between low and high inclusive,
 * false otherwise
 */
int seq_within(int32 x, int32 low, int32 high)
{
        if(low <= high){
                if(low <= x && x <= high)
                        return 1;
        } else {
                if(low >= x && x >= high)
                        return 1;
        }
        return 0;
}

int seq_lt(int32 x, int32 y)
{
    return (long)(x-y) < 0;
}

int seq_gt(int32 x, int32 y)
{
    return (long)(x-y) > 0;
}

int seq_ge(int32 x, int32 y)
{
    return (long)(x-y) >= 0;
}

/* Close our TCB */
void close_self(int16 cn, TCB *tcb)
{
    GPKT *rp1;
    GPKT *rp;

    if(tcb == (TCB *)NULL)
        return;

    tcb->timer_e = (clock_t)0;

    /* Flush reassembly queue; nothing more can arrive */
    for (rp = tcb->pq;rp != GPNULL;rp = rp1) {
        rp1 = rp->next;
        delete_packet(rp, ET_PQDROP);
    }
    tcb->pq = GPNULL;
    tcb->state = TCLOSED;

    if (tcb->outq != (OUTQ *)NULL)      /* Kill output queue if any */
	{
        while(STiKfree((char *)tcb->outq) == E_LOCKED)
        	;
	}

    while(STiKfree((char *)ctn[cn].tcb) == E_LOCKED)
    	;
    	
    ctn[cn].tcb = (TCB *)NULL;
    CNclose(cn);
}

/* This function is called from IP
 */

void tcp_in(GPKT *p, TCP_HDR *tcph)
{
    TCB *tcb;						/* TCP Protocol control block       */
    IP_HDR *iph = (IP_HDR *)p->pip;	/* IP header ptr                    */
    int16 cn;						/* Connection Handle                */
    int16 hlen;						/* Length of TCP header             */
    uint16 sum;						/* checksum of packet */
    int16 delete = 0;
    PH ph;                          /* Pseudo-header for checksumming   */
    int16 acked = 0;				/* bytes acked */

    extern   void send_syn(TCB *);
    extern void obtrim(OUTQ *, int16);


    ph.s_ip = iph->s_ip;
    ph.d_ip = iph->d_ip;
    ph.ptcl = iph->ptcl;
    ph.len  = p->mlen;

	/*
	 * Do a checksum on the packet and see if it's bad
	 */

    sum = oc_sum((char *)&ph, (uint16)sizeof(PH));     /* Pseudo header sum    */

    if (calc_sum((char *)tcph, sum, p->mlen) != 0) /* this is swampy's hack */
    {
		/* Ooops.  Checksum failure  */
	     
     	delete = ET_TCPSUM;
     	goto drop;
    }

	/*
	 * Check that the TCP offset makes sense,
	 */
	 
    hlen = tcph->ofst * 4;         /* Calc header len  */

	if (hlen < 20) /* The minimum size of a TCP header */
	{
		delete = ET_TCPSUM;
		goto drop;
	}

    /* Find the connection handle and tcb pointer.
     *  Choose a response if no port/connection.
     *
     */

    if ((cn = CNget_cn(p)) == E_NOCONNECTION)
   	{
/*			disp_info("sip = %ld",ph.s_ip);
			disp_info("dip = %ld",ph.d_ip);
			disp_info("lport = %d",tcph->dport);
			disp_info("rport = %d",tcph->sport);
*/

		/* If the packet is a FIN or a RST on a previously closed connection ignore it,
		   if not log the bad packet */
		if((!tcph->f_fin)&&(!tcph->f_rst))
		{
           	elog[ET_NOCONNECT] += 1;
			goto dropwithreset;
		}
		else
			goto drop;
    }

    tcb = ctn[cn].tcb;

    p->data = &p->mp[hlen];     /* set generic data pointer to first char   */
    p->dlen = p->mlen - hlen;   /* after TCP header, and set the data size  */


    /* Do unsynchronized-state processing (p. 65-68) */
    switch (tcb->state) {
    case TCLOSED    :
    	goto dropwithreset;

    case TLISTEN    :
		if (tcph->f_rst)
		{
			if (config.reports == 1)
				disp_info("dropped in Listen -> f_rst");

			delete = ET_LISTEN;
			goto drop;
		}

		if(tcph->f_ack)
		{
			if (config.reports == 1)
				disp_info("ack in listen");

			goto dropwithreset;
		}

		if(!(tcph->f_syn))
		{
			if (config.reports == 1)
				disp_info("we dont have a syn in Listen");

			delete = ET_LISTEN;
			goto drop;
		}

		/* Stuff for later work
		 * Discard broadcase/multicase SYN
		 * ala RFC1122
		 */
		/* (Security check is bypassed) ????*/

		proc_syn(tcb,p);
		send_syn(tcb);

		tcb->state = TSYN_RECV;

		if(p->dlen != 0)
			goto trim_it;          /* Continue processing if there's more */

		if(tcph->f_fin)
			goto trim_it;          /* This one doesn't make much sense, but I'll
										leave it for now.  It's getting to late
										to make too many changes that I don't want to look up */
		
		tcp_output(cn);

        delete = NT_SYNRECV; 	/* This was ET_LISTEN - But that would confuse it as an error */
		goto drop;

    case TSYN_SENT  :
        if (tcph->f_ack) 
       	   	if (!seq_within((int32)tcph->ack,(int32)tcb->iss+1,(int32)tcb->snd.nxt)) 
				goto dropwithreset;

			if (tcph->f_rst) 
       		{  /* p 67 */
            	if (tcph->f_ack) 
            	{
               		/* The ack must be acceptable since we just checked it.
               		 * This is how the remote side refuses connect requests.
               		 */
	
			        ctn[cn].error = E_REFUSE;
	    	    }

		        delete = ET_RMRESET;
		        goto drop;
		    }

    	    /* (Security check skipped here) */
    	    /* Check incoming precedence; it must match if there's an ACK */

    	    /*if (tcph->f_ack && PREC(iph->tos) != PREC(tcb->tos)) 
				goto dropwithreset;
			*/
						
    	    if (tcph->f_syn)
    	   	{
				proc_syn(tcb, p);
    	        
        	    if (tcph->f_ack) 
       	    	{
               		/* Our SYN has been acked, otherwise the ACK
               		 * wouldn't have been valid.
               		 */
               		update(cn, tcb, p);
               		tcb->state = TESTABLISH;
           		}
            	else {
               		tcb->state = TSYN_RECV;
	            }
	
	       	    if(p->dlen != 0 || tcph->f_fin)
	           	    goto trim_it;          /* Continue processing if there's more */
	
	            tcp_output(cn);
	            delete = NT_SYNRECV;
	            goto drop;
	        }

           	/* Ignore if neither SYN or RST is set */
           	delete = ET_NOSYNRST;
	        goto drop;
	    }

    /* We reach this point directly in any synchronized state. Note that
     * if we fell through from LISTEN or SYN_SENT processing because of a
     * data-bearing SYN, window trimming and sequence testing "cannot fail".
     */


trim_it:

    /* Trim segment to fit receive window. */

	if (trim(tcb, p) == -1) 
   	{
		/* Segment is unacceptable */

	    if(!(tcph->f_rst))
	    {     /* NEVER answer RSTs */

	        /* In SYN_RECEIVED state, answer a retransmitted SYN 
	         * with a retransmitted SYN/ACK.
	         */

	        if(tcb->state == TSYN_RECV)
	            tcb->snd.ptr = tcb->snd.una;

	        tcb->send_ack = TRUE;
	        tcp_output(cn);
    	}
        
        return;
    }

    /* If segment isn't the next one expected, and there's data
     * or flags associated with it, put it on the resequencing
     * queue, ACK it and return.
     *
     * Processing the ACK in an out-of-sequence segment without
     * flags or data should be safe, however.
     */
    if(tcph->seq != tcb->rcv.nxt
     && (p->dlen != 0 || tcph->f_syn || tcph->f_fin))
	{
       	add_reseq(tcb, p);
       	tcb->send_ack = TRUE;
       	tcp_output(cn);
       	return;
	}

    /* This loop first processes the current segment, and then
     * repeats if it can process the resequencing queue.
     */
    for (;;) {
        /* We reach this point with an acceptable segment; all data and flags
         * are in the window, and the starting sequence number equals rcv.nxt
         * (p. 70)
         */
        if (tcph->f_rst) {
             ctn[cn].error = E_RRESET;

            delete_packet(p, ET_RMRESET);
            return;
        }

        /* (Security check skipped here) p. 71 */
        /* Check for precedence mismatch or erroneous extra SYN */

        if (PREC(iph->tos) != PREC(tcb->tos) || tcph->f_syn)
        	goto dropwithreset;

        /* Check ack field p. 72 */
        if (!(tcph->f_ack)) 
        {
			if (config.reports == 1)
				disp_info("No ACK!");

          	delete = ET_NOACK;
	        goto drop; /* All segments after synchronization must have ACK */
        }

        /* Process ACK */
        switch (tcb->state) {
        case TSYN_RECV  :
            if (seq_within((int32)tcph->ack,(int32)tcb->snd.una+1,(int32)tcb->snd.nxt)) {
                update(cn, tcb, p);
                tcb->state = TESTABLISH;
            } else 
            {
				if (config.reports == 1)
	            	disp_info("dropped in process ack");

				goto dropwithreset;
			}	
            break;
        case TESTABLISH :
        case TCLOSE_WAIT:
            update(cn, tcb, p);

            break;
        case TFIN_WAIT1 :   /* p. 73 */
            update(cn, tcb, p);
            if (tcb->sndcnt == 0) {
                /* Our FIN is acknowledged */
                tcb->state = TFIN_WAIT2;
            }
            break;
        case TFIN_WAIT2 :
            update(cn, tcb, p);
            break;
        case TCLOSING   :
            update(cn, tcb, p);
            if (tcb->sndcnt == 0) {
                /* Our FIN is acknowledged */
                tcb->state = TTIME_WAIT;
                tcb->timer_d = (clock_t)MSL2*1000L;
                tcb->timer_e = set_time(tcb->timer_d);
            }
            break;
        case TLAST_ACK:
            update(cn, tcb, p);
            if (tcb->sndcnt == 0) {
                /* Our FIN is acknowledged, close connection */
                close_self(cn, tcb);
                delete_packet(p, NT_CLOSING);
                return;
            }                       
            break;
        case TTIME_WAIT:
            tcb->timer_e = set_time(tcb->timer_d);
            break;
        }
        /* (URGent bit processing skipped here) */

        /* Process the segment text, if any, beginning at rcv.nxt (p. 74) */
        if (p->dlen != 0) {
            switch (tcb->state) {
            case TSYN_RECV  :
            case TESTABLISH :
            case TFIN_WAIT1 :
            case TFIN_WAIT2 :
                /* Place on receive queue */

                tcb->rcv.nxt += p->dlen;
                tcb->rcv.wnd -= p->dlen;

                tcb->send_ack = TRUE;

                q_tcp_in(cn, p);
                break;
            default         :
                /* Ignore segment text */
                delete = ET_NODATASTATE;
                break;
            }
        }
        else {
            delete = NT_PKTEMPTY;   /* Fool! Empty packets are now deleted!  */
        }
        /* process FIN bit (p 75) */
        if (tcph->f_fin) {
            tcb->send_ack = TRUE;   /* Always respond with an ACK	*/
			ctn[cn].error = E_EOF;	/* Flag remote EOF				*/

            switch (tcb->state) {
            case TSYN_RECV  :
            case TESTABLISH :
                tcb->rcv.nxt++;
                tcb->state = TCLOSE_WAIT;
              
                break;
            case TFIN_WAIT1 :
                tcb->rcv.nxt++;
                if (tcb->sndcnt == 0) {
                    /* Our FIN has been acked; bypass TCP_CLOSING state */
                    tcb->state = TTIME_WAIT;
                    tcb->timer_d = (clock_t)MSL2*1000L;
                    tcb->timer_e = set_time(tcb->timer_d);
                } else {
                    tcb->state = TCLOSING;
                }
                break;
            case TFIN_WAIT2 :
                tcb->rcv.nxt++;
                tcb->state = TTIME_WAIT;
                tcb->timer_d = (clock_t)MSL2*1000L;
                tcb->timer_e = set_time(tcb->timer_d);
                break;
            case TCLOSE_WAIT:
            case TCLOSING   :
            case TLAST_ACK  :
                break;          /* Ignore */
            case TTIME_WAIT :     /* p 76 */
                tcb->timer_e = set_time(tcb->timer_d);
                break;
            }
        }
        if (delete) {
            delete_packet(p, delete);
            p = (GPKT *)NULL;
            delete = 0;
        }

        /* Scan the resequencing queue, looking for a segment we can handle,
         * and freeing all those that are now obsolete.
         */
        while(tcb->pq != GPNULL
              && seq_ge(tcb->rcv.nxt,((TCP_HDR *)(tcb->pq->mp))->seq)) {
            p = get_reseq(tcb);
            if (trim(tcb, p) == 0)
           		goto gotone;
	                /* Segment is an old one; trim has freed it */
        }
        break;

gotone: iph = (IP_HDR *)p->pip;
        tcph = (TCP_HDR *)p->mp;
    }

    tcp_output(cn);        /* Send any necessary ack */

    if (delete)
        delete_packet(p, delete);

    return;

dropwithreset:
    tcp_reset(p);
    return;
    
drop:
	delete_packet(p, delete);
	return;
}

/* Process an incoming ICMP response */
/* dest;        Original IP datagram dest (i.e., them) 	*/
/* type,												*/
/* code;        ICMP error codes 						*/
/* tcph;        Pointer to First 8 bytes of TCP header	*/
/* naddr;		New address if one exists				*/

void
tcp_icmp(uint32 dest, uint8 type, uint8 code, TCP_HDR *tcph, uint32 naddr)
{
    int16 cn;

    /* Extract the socket info from the returned TCP header fragment
     * Note that since this is a datagram we sent, the source fields
     * refer to the local side.
     */
    if ((cn = CNlookup_cn(tcph->sport, tcph->dport, dest)) == E_NOCONNECTION)
        return; /* Unknown connection, ignore */

    /* Verify that the sequence number in the returned segment corresponds
     * to something currently unacknowledged. If not, it can safely
     * be ignored.
     */
    if(!seq_within((int32)tcph->seq,(int32)ctn[cn].tcb->snd.una,(int32)ctn[cn].tcb->snd.nxt))
        return;

    /* Destination Unreachable and Time Exceeded messages never kill a
     * connection; the info is merely saved for future reference.
     */
    switch ((uint8)type) 
    	{
		    case 3  :   /* Destination unreachable  */
		    	if ((ctn[cn].tcb->state == TESTABLISH) &&
		    		(code == ENETUNREACH || code == EHOSTUNREACH))
		    			{
		    				/* We've got an ICMP unreachable error on an open
		    						port so we ignore it as per 4.4BSD */
		    				return;
		    			}

		    case 11 :   /* Time exceeded            */
		        ctn[cn].tcb->type = type;
		        ctn[cn].tcb->code = code;
		        break;

		    case 4  :   /* Quench                   */
		        /* Source quench; cut the congestion window in half,
		         * but don't let it go below one packet
		         */
		        ctn[cn].tcb->cwind /= 2;
		        ctn[cn].tcb->cwind = max(ctn[cn].tcb->rmss,ctn[cn].tcb->cwind);
		        break;

        	case 5  :   /* Redirect					*/
        		/* I'm going to set the redirect here and not in ip_send */
        		ctn[cn].rhost = naddr;
        		break;
    	}
}


/* Send an acceptable reset (RST) response for this segment
 * The RST reply is composed in place on the input segment
 */
static void tcp_reset(GPKT *p)
{
    PH ph;
    int32 tmp;
    uint16 sum;
    IP_HDR *iph = (IP_HDR *)p->pip;
    TCP_HDR *tcph = (TCP_HDR *)p->mp;
    struct ip_options	opts;

    if(tcph->f_rst) 
    	{
    	    delete_packet(p, ET_RMRESET);
        
    	    return; /* Never send an RST in response to an RST */
   		}

    /* Compose the RST IP pseudo-header, swapping addresses */
    ph.s_ip = iph->d_ip;
    ph.d_ip = iph->s_ip;
    ph.ptcl = P_TCP;
    ph.len  = (uint16)sizeof(TCP_HDR);

    p->ip_len = iph->ihl * 4 + (int16)sizeof(TCP_HDR);
    iph->len = p->ip_len;
    tcph->ofst = 5;   /* Set TCP header len  */

    /* Swap port numbers and IP addresses */
    tmp = iph->s_ip;
    iph->s_ip = iph->d_ip;
    iph->d_ip = tmp;

    tmp = tcph->sport;
    tcph->sport = tcph->dport;
    tcph->dport = (int16)tmp;

    if (tcph->f_ack) {
        /* This reset is being sent to clear a half-open connection.
         * Set the sequence number of the RST to the incoming ACK
         * so it will be acceptable.
         */
        tcph->f_ack = FALSE;
        tcph->seq = tcph->ack;
        tcph->ack = 0;
    } else {
        /* We're rejecting a connect request (SYN) from TCP_LISTEN state
         * so we have to "acknowledge" their SYN.
         */
        tcph->f_ack = TRUE;
        tcph->ack = tcph->seq;
        tcph->seq = 0;
        if (tcph->f_syn)
            tcph->ack++;
    }
    /* Set remaining parts of packet */
    tcph->f_psh = FALSE;
    tcph->f_rst = TRUE;
    tcph->f_syn = FALSE;
    tcph->f_fin = FALSE;
    tcph->f_urg = FALSE;

    tcph->window = 0;
    tcph->urgent = 0;

    tcph->sum = 0;

    sum = oc_sum((char *)&ph, (uint16)sizeof(PH));
    sum = calc_sum((char *)tcph, sum, (uint16)sizeof(TCP_HDR));

    tcph->sum = sum;
    p->ip_len = (int16)(sizeof(IP_HDR) + sizeof(TCP_HDR));

    /* Ship it out */
    
    opts.tos = iph->tos;
    opts.ttl = iph->ttl;
    
    ip_send(p, &opts, FLAG_LF);
}

/* Process an incoming acknowledgement and window indication.
 * From page 72.
 */
 
static void update(int16 cn, TCB *tcb, GPKT *p)
{
    int16 acked;
    int16 expand;
    TCP_HDR *tcph = (TCP_HDR *)p->mp;
    extern void obtrim(OUTQ *, int16);

    acked = 0;
    if(seq_gt(tcph->ack,tcb->snd.nxt))
    {
        tcb->send_ack = TRUE;   /* Acks something not yet sent */
        return;
    }

    /* Decide if we need to do a window update.
     * This is always checked whenever a legal ACK is received,
     * even if it doesn't actually acknowledge anything,
     * because it might be a spontaneous window reopening.
     */
    if(seq_gt(tcph->seq, tcb->snd.wl1) || ((tcph->seq == tcb->snd.wl1) 
     && seq_ge(tcph->ack,tcb->snd.wl2))){
        /* If the window had been closed, crank back the
         * send pointer so we'll immediately resume transmission.
         * Otherwise we'd have to wait until the next probe.
         */
        if(tcb->snd.wnd == 0 && tcph->window != 0)
            tcb->snd.ptr = tcb->snd.una;
        tcb->snd.wnd = tcph->window;
        tcb->snd.wl1 = tcph->seq;
        tcb->snd.wl2 = tcph->ack;
    }
    /* See if anything new is being acknowledged */
    if(!seq_gt(tcph->ack,tcb->snd.una)){
        if(tcph->ack != tcb->snd.una) {
            return; /* Old ack, ignore */
        }

        if(p->dlen != 0 || tcph->f_syn || tcph->f_fin) {
            return; /* Nothing acked, but there is data */
        }

        /* Van Jacobson "fast recovery" code */
        if(++tcb->dupacks == TCPDUPACKS){
            /* We've had a burst of do-nothing acks, so
             * we almost certainly lost a packet.
             * Resend it now to avoid a timeout. (This is
             * Van Jacobson's 'quick recovery' algorithm.)
             */
            int32 ptrsave;

            /* Knock the threshold down just as though
             * this were a timeout, since we've had
             * network congestion.
             */
            tcb->ssthresh = tcb->cwind/2;
            tcb->ssthresh = max(tcb->ssthresh,tcb->rmss);

            /* Manipulate the machinery in tcp_output() to
             * retransmit just the missing packet
             */
            ptrsave = tcb->snd.ptr;
            tcb->snd.ptr = tcb->snd.una;
            tcb->cwind = tcb->rmss;
            tcp_output(cn);
            tcb->snd.ptr = ptrsave;

            /* "Inflate" the congestion window, pretending as
             * though the duplicate acks were normally acking
             * the packets beyond the one that was lost.
             */
            tcb->cwind = tcb->ssthresh + TCPDUPACKS*tcb->rmss;
        } else if(tcb->dupacks > TCPDUPACKS){
            /* Continue to inflate the congestion window
             * until the acks finally get "unstuck".
             */
            tcb->cwind += tcb->rmss;
        }
        return;
    }
    if(tcb->dupacks >= TCPDUPACKS && tcb->cwind > tcb->ssthresh){
        /* The acks have finally gotten "unstuck". So now we
         * can "deflate" the congestion window, i.e. take it
         * back down to where it would be after slow start
         * finishes.
         */
        tcb->cwind = tcb->ssthresh;
    }
    tcb->dupacks = 0;

    /* We're here, so the ACK must have actually acked something */
    
    acked = (int16)(tcph->ack - tcb->snd.una);
    
    /* Expand congestion window if not already at limit and if
     * this packet wasn't retransmitted
     */
    if(tcb->cwind < tcb->snd.wnd && !tcb->retran){
        if(tcb->cwind < tcb->ssthresh){
            /* Still doing slow start/CUTE, expand by amount acked */
            expand = min(acked,tcb->rmss);
        } else {
            /* Steady-state test of extra path capacity */
            expand = (int16)((long)tcb->rmss * tcb->rmss) / tcb->cwind;
        }
        /* Guard against arithmetic overflow */
        if(tcb->cwind + expand < tcb->cwind)
            expand = (int16) (MAXINT16 - tcb->cwind);

        /* Don't expand beyond the offered window */
        if(tcb->cwind + expand > tcb->snd.wnd)
            expand = tcb->snd.wnd - tcb->cwind;

        if(expand != 0)
            tcb->cwind += expand;
    }
    /* Round trip time estimation */
    if (tcb->rtt_run && seq_ge(tcph->ack,tcb->rttseq)) {
        /* A timed sequence number has been acked */
        tcb->rtt_run = 0;
        if (!(tcb->retran)) {
            clock_t rtt;    /* measured round trip time */
            clock_t abserr; /* abs(rtt - srtt) */

            /* This packet was sent only once and now
             * it's been acked, so process the round trip time
             */
            rtt = msclock() - tcb->rtt_time;

            abserr = (rtt > tcb->srtt) ? rtt - tcb->srtt : tcb->srtt - rtt;
            /* Run SRTT and MDEV integrators, with rounding */
            tcb->srtt = ((AGAIN-1)*tcb->srtt + rtt + (AGAIN/2)) >> LAGAIN;
            tcb->mdev = ((DGAIN-1)*tcb->mdev + abserr + (DGAIN/2)) >> LDGAIN;

            rtt_add(((IP_HDR *)p->pip)->s_ip, rtt);
            /* Reset the backoff level */
            tcb->backoff = 0;
        }
    }
    tcb->sndcnt -= acked;   /* Update virtual byte count on snd queue */
    tcb->snd.una = tcph->ack;

    /* If we're waiting for an ack of our SYN, note it and adjust count */
    if (!(tcb->synack)) {
        tcb->synack = 1;
        acked--;        /* One less byte to pull from real snd queue */
    }
    /* Remove acknowledged bytes from the send queue and update the
     * unacknowledged pointer. If a FIN is being acked,
     * pullup won't be able to remove it from the queue, but that
     * causes no harm.
     */

    obtrim(tcb->outq, acked);

    /* Stop retransmission timer, but restart it if there is still
     * unacknowledged data. If there is no more unacked data,
     * the transmitter has gone at least momentarily idle, so
     * record the time for the VJ restart-slowstart rule.
     */
    tcb->timer_e = (clock_t)0;
    if(tcb->snd.una != tcb->snd.nxt)
        tcb->timer_e = set_time(tcb->timer_d);
    else
        tcb->lastactive = msclock();

    /* If retransmissions have been occurring, make sure the
     * send pointer doesn't repeat ancient history
     */
    if (seq_lt(tcb->snd.ptr,tcb->snd.una))
        tcb->snd.ptr = tcb->snd.una;

    /* Clear the retransmission flag since the oldest
     * unacknowledged segment (the only one that is ever retransmitted)
     * has now been acked.
     */
    tcb->retran = 0;
}

/* Determine if the given sequence number is in our receiver window.
 * NB: must not be used when window is closed!
 */
static int in_window(TCB *tcb, int32 seq)
{
    return seq_within(seq,(int32)tcb->rcv.nxt,(int32)(tcb->rcv.nxt+tcb->rcv.wnd-1));
}

/* 
	Tcp options
	0 - End of option list
	1 - No Operation
	2 - Maximum Segment Size
	3 - Window Scale factor
	8 - Timestamp 
*/

static void process_tcp_opt(GPKT *p, TCB *tcb)
{
    uint16 len = 0;
    int16 uval;
    char *opt = &p->mp[sizeof(TCP_HDR)];
    int16 optlen = (((TCP_HDR *)p->mp)->ofst * 4) - (int16)sizeof(TCP_HDR);

    while(len < optlen && *opt != 0) {
        switch (*opt & 0xff) {

        case 2  :   /* The MSS option from remote.. */
            memcpy(&uval, &opt[2], 2);  /* Copy from possibly odd address   */
            len += opt[1] & 0xff;

            /* Make rmss the lesser of our receive mss, and their
             * max mss (Avoid packet fragmentation!)
             */
            tcb->rmss = min(tcb->rmss, uval);

			tcb->rmss = max(tcb->rmss,32); /* sanity check */
	
			/* store the maximum window from the remote side */
			tcb->max_sndwnd = max(tcb->rmss,tcb->max_sndwnd);
			tcb->max_sndwnd = max(tcb->max_sndwnd,uval);

            break;

		case 3 : /* Window scale option */
		case 8 : /* Timestamp option */
        default :   /* Ignore null option, or unknown option    */
            if (*opt == 0 || *opt == 1)
                len += 1;
            else
                len += opt[1] & 0xff;

            break;
        }
        opt = &opt[len];
    }
}

/* Process an incoming SYN */

static void proc_syn(TCB *tcb, GPKT *p)
{
    int16 mtu;
    struct tcp_rtt *tp;
    IP_HDR *iph = (IP_HDR *)p->pip;
    TCP_HDR *tcph = (TCP_HDR *)p->mp;

    tcb->send_ack = 1;   /* Always send a response */

    /* Note: It's not specified in RFC 793, but SND.WL1 and
     * SND.WND are initialized here since it's possible for the
     * window update routine in update() to fail depending on the
     * IRS if they are left unitialized.
     */
     
    /* Check incoming precedence and increase if higher */
    
    if(PREC(iph->tos) > PREC(tcb->tos))
        tcb->tos = iph->tos;

	tcb->irs = tcph->seq;

    tcb->rcv.nxt = tcb->irs + 1;    /* p 68  or 945 */
    tcb->snd.wl1 = tcb->irs;
    tcb->snd.wnd = tcph->window;

    process_tcp_opt(p, tcb);

    /* Check the MTU of the interface we'll use to reach this guy
     * and lower the MSS so that unnecessary fragmentation won't occur
     */
     
    if((mtu = config.mtu) != 0)
    	{
	        /* Allow space for the TCP and IP headers */
	        mtu -= (int16)(sizeof(IP_HDR) + sizeof(TCP_HDR));
	        tcb->cwind = tcb->rmss = min(mtu,tcb->rmss);
	    }

    /* See if there's round-trip time experience */
    if ((tp = rtt_get(iph->s_ip)) != NULLRTT) 
    	{
	        tcb->srtt = tp->_srtt;
	        tcb->mdev = tp->_mdev;
	    }
}

/* Generate an initial sequence number and put a SYN on the send queue */
void send_syn(TCB *tcb)
{
		/*disp_info("TCPIN: send_syn");*/
		tcb->synack = 0;
        tcb->iss = geniss();
        tcb->rttseq = tcb->snd.wl2 = tcb->snd.una = tcb->iss;
        tcb->snd.ptr = tcb->snd.nxt = tcb->rttseq;
        tcb->sndcnt++;
        tcb->send_ack = 1;
}

/* Add an entry to the resequencing queue in the proper place */

static void add_reseq(TCB *tcb, GPKT *p)
{
    register GPKT *rp1;
    register TCP_HDR *tcph = (TCP_HDR *)p->mp;

    /* Place on reassembly list sorting by starting seq number */
    rp1 = tcb->pq;
    if(rp1 == GPNULL || seq_lt(tcph->seq,((TCP_HDR *)rp1->mp)->seq)){
        /* Either the list is empty, or we're less than all other
         * entries; insert at beginning.
         */
        p->next = rp1;
        tcb->pq = p;
    } else {
        /* Find the last entry less than us */
        for (;;) {
            if (rp1->next == GPNULL
              || seq_lt(tcph->seq, ((TCP_HDR *)rp1->next->mp)->seq)) {
                /* We belong just after this one */
                p->next = rp1->next;
                rp1->next = p;
                break;
            }
            rp1 = rp1->next;
        }
    }
}

/* Fetch the first entry off the resequencing queue */
static GPKT *get_reseq(TCB *tcb)
{
    GPKT *rp;

    if((rp = tcb->pq) == GPNULL)
        return (GPNULL);

    tcb->pq = rp->next;

    return (rp);
}

/* Trim segment to fit window. Return 0 if OK, -1 if segment is
 * unacceptable.
 *
 *
 * NOTE:
 * This routine is from mars.  I did a couple of small changes to it
 * it probably should be heavily rewritten sometime.  
 * ie. It's doing more work than it needs to in some sections
 */
static int trim(TCB *tcb, GPKT *p)
{
    long dupcnt,excess;
    int16 len;              /* Segment length including flags */
    TCP_HDR *tcph = (TCP_HDR *)p->mp;

	unsigned long next;

    len = p->dlen;

    if (tcph->f_syn) 
    	len++;
/*    	{*/
        	/* SYN is before first data byte */
/*            tcph->f_syn = FALSE;
            tcph->seq++;
        }*/
        
    if(tcph->f_fin)
        len++;

    /* Acceptability tests */
    if(tcb->rcv.wnd == 0){
        /* Only in-order, zero-length segments are acceptable when
         * our window is closed.
         */
        if (tcph->seq == tcb->rcv.nxt && len == 0)
        {
            return 0;       /* Acceptable, no trimming needed */
        }
    } else if (tcph->seq == tcb->rcv.nxt) {
    	/* exact hit */
   		goto acceptable_trim;
    } else {
    
        /* Some part of the segment must be in the window */
        if(in_window(tcb, tcph->seq))
        {
        	/* Beginning is */
        	goto acceptable_trim;
        } 
        else if (len != 0) 
        {
            if (in_window(tcb,(int32)(tcph->seq+len-1)) || /* End is */
              seq_within((int32)tcb->rcv.nxt,(int32)tcph->seq,(int32)(tcph->seq+len-1))) 
           	{ 
           		/* Straddles end */
	       		goto acceptable_trim;
           	}
        }
    }

	/* Modem Freaking Out Bug comes in here 
		hopefully this is gone now.  It was in
		an IF test that got stuck for some
		odd reason */
	
/*   	disp_info("dup data");
    
    next = tcb->rcv.nxt;
    
    disp_info("seq %lu",tcph->seq);
    disp_info("nxt %lu",next);
    disp_info("len %lu",tcph->seq+len-1);*/
   
    delete_packet(p, ET_DUPDATA);
    return -1;

acceptable_trim:

    if ((dupcnt = tcb->rcv.nxt - tcph->seq) > 0) 
    {
        /* Trim off SYN if present */
        if (tcph->f_syn) {
            /* SYN is before first data byte */
            tcph->f_syn = FALSE;
            tcph->seq++;
            dupcnt--;
        }
        if (dupcnt > 0) {   /* This is a trim on the left.  */
            p->data = (char *)&p->data[dupcnt];
            p->dlen -= (int16)dupcnt;
            tcph->seq += dupcnt;
        }
    }
    if((excess = tcph->seq + p->dlen - (tcb->rcv.nxt + tcb->rcv.wnd)) > 0) {
        /* Trim right edge */
        p->dlen -= (int16)excess;
        tcph->f_fin = FALSE;
    }
    return 0;
}
