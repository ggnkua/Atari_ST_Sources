/* TCP output segment processing
 *
 *  Also contains the TCP output queueing functions.
 *
 */
#include "lattice.h"
#include <stdio.h>
#include <string.h>
#include <ctype.h>

#include "globdefs.h"
#include "globdecl.h"
#include "krmalloc.h"

#include "display.h"

extern CCB ctn[];  /* Connection Control Block list */

extern int seq_lt(int32 x, int32 y);

int16 cdecl CNkick(int16 cn)
{
    if (cn < 0 || cn >= CNMAX || ctn[cn].tcb == (TCB *)NULL
      || ctn[cn].protocol != P_TCP)
        return (E_BADHANDLE);

	if (ctn[cn].tcb->state == TLISTEN)
		return (E_LISTEN);

	if (ctn[cn].rhost != config.localhost)
	{
	    if (carrier_detect() < 0)
    	    ctn[cn].error = E_LOSTCARRIER;
	}
	
    if (ctn[cn].tcb->timer_e == 0) 
    {
        ctn[cn].tcb->send_ack = TRUE;
        tcp_output(cn);
    }
    else 
    {
        ctn[cn].tcb->timer_e = Sclock();
        ctn[cn].tcb->backoff = 0;
    }
    
    return (E_NORMAL);
}


static void cpy_ascii_tcp(char *os, char *s, int l)
{
    while (l) {
        if (isprint(*s) || isspace(*s))
            *os++ = *s++;
        else
            break;

        l -= 1;
    }
    *os = '\0';
}

char os[512];

void tcp_timer(void)
{
    register TCB *tcb;
    register int16 cn;

	if (set_flag(FL_tcp_timer))
		return;

    for (cn = 0; cn < CNMAX; ++cn) 
    {
        if (ctn[cn].protocol != P_TCP)
            continue;
        tcb = ctn[cn].tcb;

		if (tcb->state == TLISTEN)
			continue;

		if (ctn[cn].error == E_EOF)
		{
			/* If it's the internal ident con close it */		 
			if (cn == config.identdcn)
			{
				close_self(cn,tcb);
				continue;
			}
		}
		
        if (tcb->timer_e == 0 || tcb->timer_e > Sclock())
            continue;

        tcb->timer_e = (clock_t)0;

        switch (tcb->state) 
       	{
	        case TTIME_WAIT:        /* 2MSL timer has expired */
	            close_self(cn, tcb);
	            break;
#if 0
			case TCLOSED:			 /*The connection is dead, shouldn't be called but... */
				/*disp_info("TCLOSED cn = %d",cn);*/
				if (ctn[cn].lport == 113) /* Identd is closed from remote */
					close_self(cn, tcb);
				/*disp_info("lport = %d",ctn[cn].lport);*/
				break;
#endif
	        default:                    /* Retransmission timer has expired */
				/* Ok this probably shouldn't be here, but
				 * for the moment it is
				 */
				
				if(ctn[cn].rhost == 0)
				{
					/*close_self(cn,tcb); * We shouldn't have a retransmit on a non existant connection **/
					/* OK there is some problem where a connection can be closed
					   and reopened quickly.  Stik then thinks the second connection is the first
					   as far as the timers are concerned */

					disp_info("rhost = 0");
					break;
				}
					
	            elog[NT_RETRANSMIT] += 1;
    	        tcb->retran = 1;  /* Indicate > 1  transmission */
       		    tcb->backoff++;
           		tcb->snd.ptr = tcb->snd.una;

	            /* Reduce slowstart threshold to half current window */
	            tcb->ssthresh = tcb->cwind / 2;
	            tcb->ssthresh = max(tcb->ssthresh,tcb->rmss);

	            /* Shrink congestion window to 1 packet */
	            tcb->cwind = tcb->rmss;
	            tcp_output(cn);
	            break;
        }
    }

	clear_flag(FL_tcp_timer);
}


/* TCP_send()   Puts data onto the send queue.
 *	cn     Connection Handle
 *	data   The data to send
 *  len    Number of bytes to send
 */

int16 cdecl TCP_send(int16 cn, char *data, int16 len)
{
    register OUTQ *oq = ctn[cn].tcb->outq;
    register uint16 copied = 0;
	int16 output_return = 0;

	if (ctn[cn].rhost != config.localhost)
	{
	    if (carrier_detect() < 0) 
	    {
        	ctn[cn].error = E_LOSTCARRIER;
        	return (E_LOSTCARRIER);
    	}
	}
	
    if (cn < 0 || cn >= CNMAX || ctn[cn].protocol != P_TCP)
        return(E_BADHANDLE);

	if (ctn[cn].tcb->state == TLISTEN)
		return (E_LISTEN);

    if (oq->size - oq->cnt < len)
        return (E_OBUFFULL);        /* No space for this request    */

    if (oq->nw < oq->nr)
    {
		memcpy(&oq->buf[oq->nw], data, len);
		oq->nw += len;
		oq->cnt += len;
		ctn[cn].tcb->sndcnt += len;
    }
    else
    {
		copied = min(oq->size - oq->nw, len);
		memcpy(&oq->buf[oq->nw], data, copied);
		len -= copied;
		ctn[cn].tcb->sndcnt += copied;

		oq->cnt += copied;

        if (len == 0)
		{
			oq->nw += copied;
		}
        else
        {
			memcpy(oq->buf, &data[copied], len);
			oq->cnt += len;
			oq->nw = len;
			ctn[cn].tcb->sndcnt += len;
		}
	}
	
    if (oq->nw == oq->size)
        oq->nw = 0;

	if((output_return = tcp_output(cn))<0)
		return (output_return);

    return (E_NORMAL);
}


/*  TCP_ack_wait()  Pause until all data acknowledged,
 *                  else for the given number of milliseconds.
 *
 *                  This is a hack untill I redesign.
 */

int16 cdecl TCP_ack_wait(int16 cn, int16 ms)
{
    clock_t to = Sclock() + (clock_t)ms / 5;

    if (cn < 0 || cn >= CNMAX || ctn[cn].protocol != P_TCP)
        return (E_BADHANDLE);

	if (ctn[cn].rhost != config.localhost)
	{
		if (carrier_detect() < 0) {
        	ctn[cn].error = E_LOSTCARRIER;
        	return (E_LOSTCARRIER);
    	}
	}
	
    do {    /* Do it at least once! */
        housekeep(); 
        if (ctn[cn].tcb->outq->cnt == 0)
            return (E_NORMAL);
    } while (to > Sclock());

    return (E_NORMAL);
}


/*  TCP_open()  Initiate an active TCP session with a remote port.
 *
 *      Changed!  TCP_open() now takes the remote host in dotted
 *  decimal format, and calles resolve to convert it.
 *
 * rhost		Remote host IP address
 * rport;
 * tos;
 * obsize;		Size of the output buffer for this connection
 *
 * *NOTE*	If rhost is specified as 0L, then this connection
 *			is opened as a LISTEN socket.
 */

int16 cdecl
TCP_open(uint32 rhost, int16 rport, int16 tos, uint16 obsize)
{
    TCB *tcb;
    int16    cn;
    struct   tcp_rtt *tp;
    extern   void send_syn(TCB *);

	if ((rhost != config.localhost)&&(rhost != (int32)NULL))
	{
	    if (carrier_detect() < 0)
    	    return (E_LOSTCARRIER);
	}
	
    cn = CNopen();
    if (cn < 0)
        return (cn);

    ctn[cn].rhost = rhost;
    ctn[cn].rport = rport;
    ctn[cn].lhost = config.client_ip;
    ctn[cn].protocol = P_TCP;

	if(tos == 0)
	{
		/* we are scanning here for old clients that didn't
			set their TOS values properly due to Steve's original
			documentation - Dan 3/14/99 */
				
		if ((rport == 23)||(rport == 21))
			tos = LOW_DELAY;
		else
			tos = THROUGHPUT;
	}
		
	ctn[cn].ip.tos = tos;
	ctn[cn].ip.ttl = config.ttl;

    tcb = ctn[cn].tcb = (TCB *)STiKmalloc( (unsigned long)sizeof(TCB) );

    if (tcb == (TCB *)NULL)
	{
		ctn[cn].protocol = 0;
		ctn[cn].tcb = (TCB *)0;
		return (E_NOMEM);
	}

	/*{
		char *p=(char*)tcb; int i;
		
		for (i=0 ; i<sizeof(TCB) ; i++)
			*p++ = 0x00;
	}*/

    tcb->outq = (OUTQ *)STiKmalloc((unsigned long)sizeof(OUTQ) + (unsigned long) obsize);
    
    if (tcb->outq == (OUTQ *)NULL) {
		while(STiKfree( (char *)tcb ) == E_LOCKED)
			;
        ctn[cn].protocol = 0;
        ctn[cn].tcb = (TCB *)0;
        return (E_NOMEM);
    }
	tcb->pq = GPNULL;
    tcb->outq->size = obsize;
    tcb->outq->cnt  = 0;
    tcb->outq->nw   = 0;
    tcb->outq->nr   = 0;

    tcb->state = TCLOSED;

    /* tcb->cwind = tcb->rmss = config.mss; This is the old code,
    											I've replaced it with the code below */
    
	tcb->rmss = config.mss;
	tcb->cwind = (int16)(65535L); /* window scaling will amend this */

    tcb->ssthresh = (int16)(65535L);
    if ((tp = rtt_get(rhost)) != (struct tcp_rtt *)NULL) {
        tcb->srtt = tp->_srtt;
        tcb->mdev = tp->_mdev;
    } else {
        tcb->srtt = 0; /*config.def_rtt;  maybe 0 dan 4/28/99 */
        tcb->mdev = (clock_t) 0;
    }

    /* Initialize timer intervals */
    /* tcb->timer_d = tcb->srtt; this is the original code, I replace it with the one below Dan 5/3/99 */
    tcb->timer_d = (clock_t)MSL2*1000L;

    /*tcb->rcv.wnd = config.rcv_window;*/
	tcb->rcv.wnd = (int16)(65535L); /* An experiment in the max should probably be min(65k,STikFreemem)*/
	
    tcb->max_sndwnd = tcb->snd.wnd = 1;   /* Allow space for sending a SYN */
	tcb->sndcnt = 0;
	tcb->resent = 0L;
	tcb->backoff = 0;
    tcb->tos = tos;

	if (rhost == (int32)NULL) {	/* Opening LISTEN socket	*/
		tcb->state = TLISTEN;
		ctn[cn].rport = 0;
		if (rport != 0)
			ctn[cn].lport = rport;
	}
	else {
    	/* Send SYN, go into TCP_SYN_SENT state */
    	send_syn(tcb);
    	tcb->state = TSYN_SENT;
    	tcp_output(cn);
	}
    return (cn);
}

static int16 TCP_wait_close(int16 cn, int16 timeout)
{
    clock_t tend = (clock_t)Sclock() + timeout * CLK_TCK;

	if (ctn[cn].rhost != config.localhost)
	{
	    if (carrier_detect() < 0) {
    	    close_self(cn, ctn[cn].tcb);
    	    return (E_LOSTCARRIER);
    	}
	}
	
	do {
        if (ctn[cn].protocol == 0
          || ctn[cn].tcb == (TCB *)NULL)
            return (E_BADHANDLE);

        if (ctn[cn].error < E_NODATA) {
            close_self(cn, ctn[cn].tcb);
            return (ctn[cn].error);
		}

		if (ctn[cn].tcb->type == 3) {
            close_self(cn, ctn[cn].tcb);
			return (E_UNREACHABLE);
		}

		(*yield)();

    } while (tend > Sclock());

    close_self(cn, ctn[cn].tcb);

    return (E_USERTIMEOUT);
}

int16 cdecl TCP_close(int16 cn, int16 timeout)
{
    if (cn < 0 || cn >= CNMAX || ctn[cn].protocol != P_TCP)
        return (E_BADHANDLE);

    switch(ctn[cn].tcb->state)
    	{
		    case TCLOSED    :
		        return 0;   /* Unlikely.  Almost impossible, actually */
		    case TLISTEN    :
		    case TSYN_SENT  :
		        close_self(cn, ctn[cn].tcb);
		        break;
		    case TSYN_RECV  :
		    case TESTABLISH :
		        ctn[cn].tcb->sndcnt++;
		        ctn[cn].tcb->snd.nxt++;
		        ctn[cn].tcb->state = TFIN_WAIT1;
		        tcp_output(cn);
		        break;
		    case TCLOSE_WAIT:
		        ctn[cn].tcb->sndcnt++;
    		    ctn[cn].tcb->snd.nxt++;
		        ctn[cn].tcb->state = TLAST_ACK;
		        tcp_output(cn);
		        break;
		    case TFIN_WAIT1:
		    case TFIN_WAIT2:
		    case TCLOSING:
		    case TLAST_ACK:
		    case TTIME_WAIT:
		        break;          /* We'll just do the wait bit...    */
	    }
    return (TCP_wait_close(cn, timeout));
}


int16 cdecl TCP_wait_state(int16 cn, int16 state, int16 timeout)
{
    clock_t tend = (clock_t)Sclock() + timeout * CLK_TCK;

    if (cn < 0 || cn >= CNMAX || ctn[cn].protocol != P_TCP)
        return (E_BADHANDLE);

	if (ctn[cn].rhost != config.localhost)
	{
	    if (carrier_detect() < 0) {
	        ctn[cn].error = E_LOSTCARRIER;
	        return (E_LOSTCARRIER);
		}
	}

/*	
    while (tend > Sclock()) {
        if (ctn[cn].error < E_NODATA)
            return (ctn[cn].error);

        if (ctn[cn].tcb->state == state)
            return (E_NORMAL);

#if 0
		 historic - do not use 

        if (Bconstat(CON)) {
            if ((char)Bconin(CON) == (char)0x1b)
            	return (E_USERTIMEOUT);
        }
#endif

		if (state == TESTABLISH && ctn[cn].tcb->type == 3) {
            ctn[cn].error = E_UNREACHABLE;
			return (E_UNREACHABLE);
		}

		(*yield)();

       / housekeep(); /
    }
    return (E_USERTIMEOUT);*/
    return(E_NORMAL);
}


/* get_qdata()  get `dlen' bytes from the output queue starting at `offset'
 *              and put them into the GPKT packet.
 *              Return the number of bytes copied.
 */
static int16
get_qdata(GPKT *p, OUTQ *oq, int16 offset, int16 dsize)
{
    int16 copied = 0;

    if (offset > oq->cnt) { /* No such data available   */
        p->dlen = 0;
        return (0);
    }

    if (offset + dsize > oq->cnt)
        dsize = oq->cnt - offset;

    if (dsize <= 0) {       /* Nothing really asked for..   */
        p->dlen = 0;
        return (0);
    }

    if (oq->nr < oq->nw) {
        memcpy(p->data, &oq->buf[offset + oq->nr], dsize);
        copied = dsize;
    }
    else {
        if (offset < oq->size - oq->nr) {
            copied = min(oq->size - (oq->nr + offset), dsize);
            memcpy(p->data, &oq->buf[offset + oq->nr], copied);
            dsize -= copied;

            if (dsize > 0) {
                memcpy(&p->data[copied], oq->buf, dsize);
                copied += dsize;
            }
        }
        else {
            offset = offset - (oq->size - oq->nr);
            memcpy(p->data, &oq->buf[offset], dsize);
            copied = dsize;
        }
    }
    p->dlen = copied;
    return (copied);
}


/* Remove `acked' bytes from the output queue
 */

void obtrim(OUTQ *oq, int16 acked)
{
    if (oq->size - oq->nr > acked)
        oq->nr += acked;
    else
        oq->nr = acked - (oq->size - oq->nr);

    oq->cnt -= acked;
}


/* Backoff function - the subject of much research */
int32 backoff(int n)
{
    if(n > 31)
        n = 31; /* Prevent truncation to zero */

    return 1L << n; /* Binary exponential back off */
}

/* Send a segment on the specified connection. One gets sent only
 * if there is data to be sent or if "force" is non zero
 */
int16 tcp_output(int16 cn)
{
    PH ph;           /* Pseudo-header for checksum calcs */
    int16 len;       /* Size of current segment being sent,
                      * including SYN and FIN flags */
    int16 dsize;     /* Size of segment less SYN and FIN */
    				 /* used mainly in amount of data we are
    				    getting and it some checks */
    int16 usable;    /* Usable window */
    int16 sent;      /* Sequence count (incl SYN/FIN) already
                      * in the pipe but not yet acked */
    int32 rto;       /* Retransmit timeout setting */

    TCB *tcb = ctn[cn].tcb;
    TCP_HDR *tcph;
    IP_HDR *iph;
	struct ip_options opts;
	int idle = FALSE;
    int16 offset;

    GPKT *p;

	extern int seq_gt(int32, int32);

	/* I've added the disp_info call to see if this next test
		ever happens.  I don't think it should, and if it does
		then there's probably a problem - DA 12/21/98*/

    if(tcb == (TCB *)NULL)
   	{
   		if (carrier_detect() < 0) /* Connection was forced closed externally */
   			return(E_LOSTCARRIER); /* This is an ok error for this case */
   		else
		{
			/* This is just to catch if it ever happens
				incorrectly. ie a packet getting routed here
				that shouldn't be here */
    					
/*    		disp_info("No TCB in tcp_output\r\n");*/
	        return(E_BADROUTINE);
	    }
	}
		
    /*
    	Since carrier detect doesn't really do much, I'm
    	removing it for the moment.  Possibly some later check
    	to see if the interface is working would be a good idea
    	to save processing
    
    	Since the modifications to carrier detect I've put it
    	back in.  Should avoid problems when the stack is shut
    	down externally - DA 12/26/98 */

	if (ctn[cn].rhost != config.localhost)
	{    
	    if (carrier_detect() < 0) 
    	{
	       	 close_self(cn, ctn[cn].tcb);
	       	 return(E_LOSTCARRIER);
		}
	}
	

	/* I believe the following lines take place at a higher
		level in BSD */
		
    if ((tcb->state == TLISTEN)||(tcb->state == TCLOSED))
   		return(0); /* Don't send anything */
    	
again:
    for (;;) {
        /* Compute data already in flight */

        sent = (int16)(tcb->snd.ptr - tcb->snd.una);

        /* If transmitter has been idle for more than a RTT,
         * take the congestion window back down to one packet.
         */
        if(tcb->timer_e < Sclock()
        	 && (msclock() - tcb->lastactive) > tcb->srtt)
   	 	{
       		tcb->cwind = tcb->rmss;
       		idle = TRUE;
       	}

        /* Compute usable send window as minimum of offered
         * and congestion windows, minus data already in flight.
         * Be careful that the window hasn't shrunk --
         * these are unsigned vars.
         */
        usable = min(tcb->snd.wnd,tcb->cwind);

        if(usable > sent)
            usable -= sent; /* Most common case */
        else if(usable == 0 && sent == 0)
            usable = 1;     /* Closed window probe */
        else
            usable = 0;     /* Window closed or shrunken */

        /* Compute size of segment we *could* send. This is the
         * smallest of the usable window, the mss, or the amount
         * we have on hand. (I don't like optimistic windows)
         */
        len = min(tcb->sndcnt - sent, usable);
        len = min(len,tcb->rmss);

        /* Now we decide if we actually want to send it.
         * Apply John Nagle's "single outstanding segment" rule.
         * If data is already in the pipeline, don't send
         * more unless it is MSS-sized or the very last packet.
         */
		
		if (tcb->tos != LOW_DELAY)
		{
	       if(sent != 0 && len < tcb->rmss
	         && !(tcb->state == TFIN_WAIT1 && len == tcb->sndcnt - sent)) 
			{
				len = 0;
			}
		}
		else
		{
		    if(sent != 0 && len != tcb->rmss
		        && !(tcb->state == TFIN_WAIT1 && len == tcb->sndcnt - sent)) 
		   	{
		   	   len = 0;
	        }
	    }

		/* I'm attempting to replace this old version of John Nagles 
			rule with sender silly window avoidance as per BSD */
		
/*		if (len)
			{
				if (len == tcb->rmss)
					goto send;
				if ((idle && (tcb->tos == LOW_DELAY)) &&
				 len + sent >= tcb->outq->cnt) * Should have a test for TF_NODELAY *
					goto send;
				if (tcb->send_ack)
					goto send;
				if (len >= tcb->max_sndwnd / 2)
					goto send;
				if (seq_lt(tcb->snd.ptr,tcb->snd.una)) * tcb->snd.nxt, tcb->snd.max)) this is a bastardasation of the code should be second section *
					goto send;
			}
*/
		/*
		 * If we are sending an ack go right to send and
		 * avoid any more useless tests
		 */

		if(tcb->send_ack)
			goto send;

        /* Unless the tcp syndata option is on, inhibit data until
         * our SYN has been acked. This ought to be OK, but some
         * old TCPs have problems with data piggybacked on SYNs.
         */
        if(!tcb->synack)    
       	{
       		/* There was a test for SYNDATA here that was basically
       		 * send data piggy backed on a SYN if a variable was set
       		 * since we don't have that variable I killed it.  i've
       		 * made this note just so that we remember it was here
       		 * in case something of this type is ever hacked in here
       		 */
        		  
            if(tcb->snd.ptr == tcb->iss)
               	len = min(1,len);   /* Send only SYN */
            else
   	            len = 0;      /* Don't send anything */
       	}
        	
        if(len == 0) 
       	{
       	    /*break;*/          /* No need to send anything */
       	    return(0);			/* so we are going to return to avoid silly window */
       	}

send:        	
        tcb->send_ack = 0;   /* Only one forced segment! */

	 	/* Quick case to avoid tests if we know for certain that we want
		 * to send something out
		 */
        p = mkpacket(ctn[cn].rhost, tcb->rmss + (int16)sizeof(TCP_HDR), (int16)P_TCP);

		/* If memory allocation failed log it and return */
        if (p == (GPKT *)NULL)
        {
            elog[EA_NOMEMORY] += 1;
            return(E_NOMEM);
        }
        	
        iph = (IP_HDR *)p->pip;
        tcph = (TCP_HDR *)p->mp;

        memset(p->mp, '\0', sizeof(TCP_HDR));

        tcph->sport = ctn[cn].lport;
        tcph->dport = ctn[cn].rport;

        if(tcb->state != TSYN_SENT)
        	tcph->f_ack = TRUE;

        dsize = len;

		/* I don't like how this is done, we need something better 
			we are basically wondering whether the state is
			TSYN_SENT || TSYN_RECV (ie. opening a connection. */

        if ( (!tcb->synack) && (tcb->snd.ptr == tcb->iss) )
        {
            tcph->f_syn = TRUE;
            dsize--;        /* SYN isn't really in snd queue */
            /* Also send MSS */
            ((char *)&tcph[1])[0] = 2;
            ((char *)&tcph[1])[1] = 4;
            ((int *)&tcph[1])[1] = config.mss;

            p->mlen = (int16)sizeof(TCP_HDR) + 4;
            tcph->ofst = p->mlen / 4;
            p->data = (char *)&((long *)&tcph[1])[1];
            p->dlen = 0;
        }
        else {
            p->mlen = (int16)sizeof(TCP_HDR);
            tcph->ofst = p->mlen / 4;

            p->data = (char *)&tcph[1];
            p->dlen = 0;
        }

        tcph->seq = tcb->snd.ptr;
        tcph->ack = tcb->rcv.nxt;
        tcph->window = tcb->rcv.wnd;
        tcph->urgent = 0;

        /* Now try to extract some data from the send queue. Since
         * SYN and FIN occupy sequence space and are reflected in
         * sndcnt but don't actually sit in the send queue, dup_p
         * will return one less than dsize if a FIN needs to be sent.
         */
        if (dsize != 0) {

            /* SYN doesn't actually take up space on the sndq,
             * so take it out of the sent count
             */
            offset = sent;
            if(!tcb->synack && sent != 0)
                offset--;

			/* get the data off the send queue. */

            if (get_qdata(p, tcb->outq, offset, dsize) != dsize) 
           	{
           	    /* We ran past the end of the send queue;
           	     * send a FIN
           	     */
           	    tcph->f_fin = TRUE;
           	    dsize--;
           	}
        }

        /* If the entire send queue will now be in the pipe, set the
         * push flag
         */
        if(dsize != 0 && sent + len == tcb->sndcnt)
            tcph->f_psh = TRUE;

        /* If this transmission includes previously transmitted data,
         * snd.nxt will already be past snd.ptr. In this case,
         * compute the amount of retransmitted data and keep score
         */
        if(tcb->snd.ptr < tcb->snd.nxt)
            tcb->resent += min(tcb->snd.nxt - tcb->snd.ptr,len);

        tcb->snd.ptr += len;
        /* If this is the first transmission of a range of sequence
         * numbers, record it so we'll accept acknowledgments
         * for it later
         */
        if(seq_gt(tcb->snd.ptr,tcb->snd.nxt))
            tcb->snd.nxt = tcb->snd.ptr;

        p->mlen += p->dlen;
        iph->len = p->ip_len = p->mlen + (int16)sizeof(IP_HDR);
        tcph->sum = 0;

        /* Fill in fields of pseudo IP header */
        ph.s_ip = ctn[cn].lhost;
        ph.d_ip = ctn[cn].rhost;
        ph.ptcl = P_TCP;
        ph.len  = p->mlen;

		/* Generate the checksum for the TCP packet */

        tcph->sum =
        	calc_sum(p->mp, oc_sum((char *)&ph, (uint16)sizeof(PH)), p->mlen);


        /* If we're sending some data or flags, start retransmission
         * and round trip timers if they aren't already running.
         */
        if(len != 0)
       	{
           	/* Set round trip timer. */
           	rto = backoff(tcb->backoff) * (4 * tcb->mdev + tcb->srtt);
           	tcb->timer_d = max(MIN_RTO, rto);

           	if(!tcb->timer_e) /* timer_e is retransmission timer in this case */
               	tcb->timer_e = set_time(tcb->timer_d);

            /* If round trip timer isn't running, start it */
   	        if(!tcb->rtt_run)
        	{
           		tcb->rtt_run = 1;
           		tcb->rtt_time = msclock();
           		tcb->rttseq = tcb->snd.ptr;
       		}
       	}
        
		opts.tos = ctn[cn].ip.tos;
		opts.ttl = ctn[cn].ip.ttl;

        ip_send(p, &opts, FLAG_LF);
    }

    return (0);
    /* skipping loop for now */
}
