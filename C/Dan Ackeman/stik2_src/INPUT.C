/*  input.c             (c) Steve Adam 1995         steve@netinfo.com.au
 *
 *      The input functions.
 *
 *  This module is essentially the heart of the program.  This is
 *  where packets from any protocol come for delivery to the user.
 *
 *  Packets are sent here from icmp_in(), tcp_in(), udp_in() after
 *  any initial processing by these functions.  Then they are placed
 *  in a queue for delivery to the user on request.  Simple.
 *
 *  Whenever the user calls for input from any of these sources,
 *  that function in turn calls a housekeep routine which, among
 *  other things, calls slip_in() and slip_out() to ensure a 
 *  continous data stream.  slip_in() is the ultimate source of all
 *  packets that come here.
 *
 *  I've yet to decide whether these functions should block, or
 *  return control to the user.  I think they should return
 *  control.   It's important, however, that the user application
 *  continue to poll for input.  Of course, if I write the
 *  applications, I can be sure of this.....
 *
 *  This implementation is simplified greatly by imperfect seperation
 *  between protocol layers (universal packets) and by only having
 *  one application level program running at a time.  This means that
 *  we (the application, at least) has a pretty good idea of what is
 *  likely to turn up, and we have a pretty good idea what we should
 *  throw away.  This requires some research and development, though.
 */

#include "lattice.h"
#include <stdio.h>
#include <string.h>
#include "krmalloc.h"
#include "globdefs.h"
#include "globdecl.h"
#include "resolve.h"	 /*for do_resolve */
#include "display.h"


/*  port_gen()  Generator a new client port for this host.
 *
 *      It sounds hard, but it's easy.  Simply increment our
 *  current port number, and return it.  This has the advantage
 *  that no two connections are ever made with the same client
 *  port.  The advantage is that in the case of lost connections,
 *  we'll never restart with the same port number, so we run
 *  absolutely *NO* risk of having an old packet interfere with
 *  out current session.  An added comlpexity is that if our
 *  end dies, we may do precisely that, so our port should be
 *  initialised with some random element.  See init_ports();
 */

static uint16 c_user_port;      /* Current User port value.         */

static uint16 port_gen(void)
{
    return (c_user_port++);
}

/*  init_ports()        Initialise the Current User Port value.
 *
 *  A sufficient choice would be 1024 + (time() & 0x03ff), yielding
 *  port values between 1024 and 2047.  time() returns seconds, which
 *  means that user would have to kill and re-establish a session
 *  with the same host within 1 second to risk old packet confusion.
 *  In addition, the mask of 0x3ff means a cycle time of 17 minutes
 *  in port allocation, by which time old packets can't possibly
 *  arrive.  (Upper bound of max ttl of 255 is 4.25 minutes)
 */

void init_ports(void)
{
    time_t t;   /* time_t is an unsigned long   */

    time(&t);

    c_user_port = 1024 + ((uint16)t & 0x3ff);
}

/*  housekeep()
 *
 *      Perform a set of regular activities required to keep
 *  the system working fluently.
 *
 *	do_resolve()		Do any required DNS resolving..
 *
 *  slip_out()          Ouput any data waiting in the output queue.
 *  tcp_timer()         Is the TCP retransmit timer function,
 *                      + Also calls tcp_output() for each connection
 *  frag_ttl_check()    Deletes reassembly queue packets if TTL has expired.
 *  slip_in()           Reads any serial data, and passes packets upward.
 */

void cdecl housekeep(void)
{
	/* This next line will need to be expanded for more ports */
	/*if (bdev == (DEV_LIST *)NULL)
		{
			return;
		}

	if (set_flag(FL_housekeep))
		{
			return;
		}*/
;
	
	/*do_resolve();*/

	/*clear_flag(FL_housekeep);*/
}

/* The ICMP input queue and functions */


/*
 *   STiNGs Internal IP packet representation.
 *
 * Only included so we can make the 2 sting apps that use this method
 * Run.  NOTE ICMP_x CALLS ARE NOT RECOMMENDED FOR USE
 */

typedef  struct ip_packet {
    IP_HDR    hdr;              /* Header of IP packet                      */
    void      *options;         /* Options data block                       */
    int16     opt_length;       /* Length of options data block             */
    void      *pkt_data;        /* IP packet data block                     */
    int16     pkt_length;       /* Length of IP packet data block           */
    uint32    timeout;          /* Timeout of packet life                   */
    uint32    ip_gateway;       /* Gateway for forwarding this packet       */
    void      *recvd;           /* Receiving port                           */
    struct ip_packet  *next;    /* Next IP packet in IP packet queue        */
 } IP_DGRAM;

/* icmp_listener must be true or ICMP packets are discarded. */
static int icmp_listener = FALSE;

/* Dummy function to hold ICMP listener routine */
int16 (* icmp_handler) (GPKT *);


int16 start_icmp_listen(void *handler, int16 install_code)
{

/*	HNDLR_SET        0          Set new handler if space             
	HNDLR_FORCE      1          Force new handler to be set          
	HNDLR_QUERY		 3			check handler installed to see if it's the one passed
*/

	/* First run HNDLR_QUERY calls */
	
	if (install_code == 3)
		{
			if (icmp_listener == FALSE) /* No handler in place */
				return(FALSE);

			if (icmp_handler == handler)
				return(TRUE);
			else
				return(FALSE);
		}

	icmp_handler = handler;

    icmp_listener = TRUE;
    
    return(TRUE);
}

int16 stop_icmp_listen(void)
{
    icmp_listener = FALSE;
    
    icmp_handler = NULL;
    
    return(TRUE);
}


static GPKT *icmp_queue = (GPKT *)NULL;

/*  q_icmp_reply()
 *
 *  Any ICMP reply is delivered here.
 *  All we have to do is queue it...
 *
 *  Changed this now passes the GPKT onto the appropriate 
 * handler.
 */

void q_icmp_reply(GPKT *p)
{
	/*IP_DGRAM sting;
	IP_HDR *ipheader;*/

	int16 handler_return;

	/*ipheader = (IP_HDR*)p->pip;*/

    /*GPKT *qptr = icmp_queue;*/

    p->next = (GPKT *)NULL;            /* Just in case     */

    if (icmp_listener == FALSE) 
    	{   
    		/* Discard packets if no listener   */
    	    /*delete_packet(p, EI_NOLISTEN); Don't delete it just send it back again */
    	    return;
    	}

/*  This code is being changed

   if (icmp_queue == (GPKT *)NULL) {    Queue empty  
        icmp_queue = p;
        return;
    }

    while (qptr != (GPKT *)NULL)         Find end of list 
        qptr = qptr->next;

    qptr->next = p;  
*/

/*	sting.hdr = *ipheader;           * Header of IP packet                      *
    sting.options = NULL;         * Options data block                       *
    sting.opt_length = 0;        Length of options data block             *
    sting.pkt_data = p->data;        * IP packet data block                     *
    sting.pkt_length = p->dlen;       * Length of IP packet data block           *
    sting.timeout = ipheader->ttl;          * Timeout of packet life                   *
    sting.ip_gateway = (uint32)NULL;       * Gateway for forwarding this packet       *
    sting.recvd = NULL;           * Receiving port                           *
    sting.next = (IP_DGRAM *)p->next;    * Next IP packet in IP packet queue        *
*/

	handler_return = icmp_handler(p);
	
	if (handler_return == FALSE)
		delete_packet((GPKT *)p, EI_ICMPTYPE);
}


GPKT *get_icmp(void)
{
    GPKT *next_packet;

    housekeep();

    if (icmp_queue == (GPKT *)NULL)
        return (GPKT *)NULL;

    next_packet = icmp_queue;

    icmp_queue = icmp_queue->next; /* Advance pointer (possibly to NULL)   */

    return next_packet;
}


/*      The   * * N E W * *  User interface setup for UDP & TCP
 *
 *      I've decided on a fairly conventional system for getting
 *  input from TCP and UDP.  `Connections' will be `open'ed and
 *  a `connection handle' (or error) returned.  This handle will
 *  be an index into an array of `connection stream' blocks.
 *  These blocks will contain information that will be matched
 *  with incoming packets to see if it belongs here.  If so,
 *  the data will be moved (not copied) to a data queue in the
 *  `connection stream' block.  Then when a client reads from
 *  that `connection handle' the data will be copied and/or returned.
 *
 *      Note that even though UDP is `connectionless' this method
 *  will still be correct.  The CSB holds the client port number
 *  which is really all that is used to match packets to CSB's.
 *  So any incoming UDP block headed for that port, will be
 *  considered part of that `connection'.
 *
 *      TCP *is* connection oriented, but the same mechanism will
 *  apply there too, though it might be worthwhile to match *all*
 *  the information applying to TCP connections.
 *
 *      UDP and TCP CSB's will be in the same array, and the same
 *  data delivery mechanism (to the client) will be used.
 */


CCB ctn[CNMAX];  /* Max number of connections at any time.   */
static int16 nextcn = 0;

int cn_count = 0;	/* count of open connections	*/

/*  CNopen()  Does part of the `open' work common to TCP and UDP.
 */

int16 CNopen(void)
{
    int16 x;

    /* Cycle through connection handles     */
    /* During the session.                  */

    for (x = nextcn; x < CNMAX; ++x) {
        if (ctn[x].protocol == 0) {      /* OK, found a free one!    */
            ctn[x].lport = port_gen();
            ctn[x].ndq = (NDB *)NULL;
            ctn[x].error = 0;
            ctn[x].inp_flags = 0x0;
            ctn[x].flags = 0x0;
            nextcn = x + 1;
			cn_count += 1;
            return (x);
        }
    }
    
    for (x = 0; x < nextcn; ++x) {
        if (ctn[x].protocol == 0) {      /* OK, found a free one!    */
            ctn[x].lport = port_gen();
            ctn[x].ndq = (NDB *)NULL;
            ctn[x].error = 0;
            ctn[x].inp_flags = 0x0;
            ctn[x].flags = 0x0;
            nextcn = x + 1;
			cn_count += 1;
            return (x);
        }
    }

    return (E_NOCCB);
}


CCB * cdecl CNgetinfo(int16 cn)
{
    if (cn < 0 || cn >= CNMAX || ctn[cn].protocol == 0)
        return ((CCB *)NULL);

    return (&ctn[cn]);
}

/* CNfree_NDB() Return a NDB to the system 
 * for external use
 *
 * We have 2 versions to avoid reiterancy between the interupt
 * and client applications
 */
 
void cdecl CNfree_NDB(int16 cn, NDB *p)
{
	(void) cn;

    if (p->ptr != (char *)NULL)
	{
        while(STiKfree(p->ptr) == E_LOCKED)
        	;
	}
	
    while(STiKfree((char *)p) == E_LOCKED)
    	;
}

/* intfree_NDB() Return a NDB to the system used internally
 */
 
void intfree_NDB(NDB *p)
{
    if (p->ptr != (char *)NULL)
	{
        while(STiKfree(p->ptr) == E_LOCKED)
        	;
     }

    while(STiKfree((char *)p) == E_LOCKED)
    	;
}

static void CNdel_NDB(int16 cn)	/* Delete the first ndb in the queue   */
{								/* Always and ONLY the first entry      */
    NDB *p;

    if((p = ctn[cn].ndq) == (NDB *)NULL)
        return;

    ctn[cn].ndq = p->next;  /* Advance ptr.  Possibly to a NULL     */

    if (p->ptr != (char *)NULL)
	{
        while(STiKfree(p->ptr) == E_LOCKED)
        	;
    }

    while(STiKfree((char *)p) == E_LOCKED)
    	;
}

void CNclose(int16 cn)
{
    while (ctn[cn].ndq != (NDB *)NULL)
        CNdel_NDB(cn);

    ctn[cn].protocol = 0;
    ctn[cn].lport = 0;
    ctn[cn].rport = 0;
    ctn[cn].tcb = (TCB *)0;

	if (cn == config.identdcn)
		config.identdcn = -1;

	cn_count -= 1;
}

void CNcloseall(void)
{
	int16 x;

	for (x = 0; x < CNMAX; ++x) {
		if (ctn[x].protocol == P_TCP)
			TCP_close(x, 0);
		else if (ctn[x].protocol == P_UDP)
			CNclose(x);
		else if (ctn[x].protocol == IPPROTO_RAW)
			RAW_close(x);
	}
}

/*  UDP_open()  Open a UDP session
 *
 *      Allocate a client port
 *      Find a free CCB and initialise it
 *      Return index of CCB to user.
 */

int16 cdecl UDP_open(uint32 rhost, int16 rport)
{
    int16 cn;

	if ((rhost != config.localhost)&&(rhost != (int32)NULL))
	{
	    if (carrier_detect() < 0)
    	    return (E_LOSTCARRIER);
	}
	
    cn = CNopen();

    if (cn >= 0) {
        ctn[cn].rhost = rhost;
        ctn[cn].rport = rport;
        ctn[cn].protocol = P_UDP;
        ctn[cn].lhost = config.client_ip;

		ctn[cn].ip.tos = 0;
		ctn[cn].ip.ttl = config.ttl;
    }

    return (cn);
}

int16 cdecl UDP_close(int16 cn)
{
    if (cn < 0 || cn >= CNMAX || ctn[cn].protocol != P_UDP)
        return (E_BADHANDLE);

    CNclose(cn);

    return (E_NORMAL);
}


/*  q_udp_in()  Any UDP packet is delivered here.
 *
 *      To deliver it, we need to find the CCB it is associated with
 *  or discard the packet if there isn't one.  Then make a new NDB
 *  and initialise it to point to the data in the incoming packet,
 *  then delete the packet.  (The data part of the packet is not
 *  deleted, but moved into the NDB)
 */

void q_udp_in(GPKT *p, UDP_HDR *udph)
{
    NDB *new, *q;
    int x;
	extern int16 int_DNS(NDB *pkt,UDP_HDR *udphd, uint32 d_ip);
	uint32 d_ip;
    IP_HDR *iph;

    for (x = 0; x < CNMAX; ++x) 
    {
        if (udph->dport == ctn[x].lport && ctn[x].protocol == P_UDP)
            break;
    }

    if (x >= CNMAX)
    {
		if (udph->dport == 53) /* This is a resolver call back to us */
		{
			/* Make an NDB and pass it off to the int resolver function */
		    new = (NDB *)STiKmalloc( (long)sizeof(NDB) );

		    if (new == (NDB *)NULL) 
		    {
		        delete_packet(p, EA_NOMEMORY);  /* Presumably we're out of memory   */
		        return;
		    }

		    iph = (IP_HDR *)p->pip;

			d_ip = iph->s_ip;

			{
				char *p=(char*)new; int i;
		
				for (i=0 ; i<sizeof(NDB) ; i++)
					*p++ = 0x00;
			}
			
		    new->ptr = p->fp;
		    p->fp = (char *)NULL;
		    new->ndata = p->data;
		    new->len = p->dlen;
		    new->next = (NDB *)NULL;
	
		    delete_packet(p, NU_QUEUEDOK);
		    
			int_DNS(new,udph,d_ip);
			
			return;
		}

        delete_packet(p, EU_NOPORT);    /* Failed to find the destination   */
        return;
    }


    /* OK, now we can queue the data in a new NDB  */
    new = (NDB *)STiKmalloc( (long)sizeof(NDB) );

    if (new == (NDB *)NULL) 
    {
        delete_packet(p, EA_NOMEMORY);  /* Presumably we're out of memory   */
        return;
    }

	{
		char *p=(char*)new; int i;
		
		for (i=0 ; i<sizeof(NDB) ; i++)
			*p++ = 0x00;
	}

    new->ptr = p->fp;
    p->fp = (char *)NULL;
    new->ndata = p->data;
    new->len = p->dlen;
    new->next = (NDB *)NULL;

    delete_packet(p, NU_QUEUEDOK);

    if (ctn[x].ndq == (NDB *)NULL) {   /* If queue empty   */
        ctn[x].ndq = new;               /* Point it to new data */
        return;
    }

    q = ctn[x].ndq;                     /* Else get ptr to start of list    */

    while (q->next != (void *)NULL)     /* Find end of list */
        q = q->next;

    q->next = new;                      /* And tack new data to the end     */
}

/* OK, now the pointers are all set up, so we only need some
 * functions for accessing the actual data, in a variety of ways...
 */

/*  CNbyte_count()  Count how many bytes are waiting in the queue
 *
 *      It's theoretically possible, though extremely unlikely,
 *  that there could be more than 65535 bytes waiting.  I'm
 *  going to pretend this won't happen, but the function will
 *  return a uint16.
 */

int16 cdecl CNbyte_count(int16 cn)
{
    NDB *p;
    uint16 count = 0;

    /* housekeep(); Removed by Dan */

    if (cn < 0 || cn >= CNMAX || ctn[cn].protocol == 0)
        return (E_BADHANDLE);

	if ((ctn[cn].rhost != config.localhost)&&(ctn[cn].rhost != (int32)NULL))
	{
	    if (carrier_detect() < 0)
	        ctn[cn].error = E_LOSTCARRIER;
	}

	if (ctn[cn].tcb && ctn[cn].tcb->state == TLISTEN)
		return (E_LISTEN);

    p = ctn[cn].ndq;

    while (p != (NDB *)NULL) {
        count += p->len;
        p = p->next;
    }

    if (ctn[cn].error && count == 0)
        return (ctn[cn].error);

	if (count > 32767)
		return(32767);
	
    return (count);
}

/*  CNget_NDB()    The easiest one.  Return the ptr to NDB structure
 */

NDB * cdecl CNget_NDB(int16 cn)
{
    NDB *rblk;

    if (cn < 0 || cn >= CNMAX || ctn[cn].protocol == 0)
        return (NDB *)NULL;

	if ((ctn[cn].rhost != config.localhost) &&
		(ctn[cn].rhost != config.client_ip))
	{
	    if (carrier_detect() < 0) 
	    {
			/* We've lost carrier 
			 *
			 * Next tests if it's a TCP connection if not CNclose
			 * if it is then close_self
			 */
	
		    if(ctn[cn].tcb == (TCB *)NULL)
				CNclose(cn);
		    else
	        	close_self(cn, ctn[cn].tcb);

        	return (NDB *)NULL;
	    }
	}

	if (ctn[cn].tcb && ctn[cn].tcb->state == TLISTEN)
		return ((NDB *)NULL);

    rblk = ctn[cn].ndq;

    if (rblk == (NDB *)NULL)
        return (NDB *)NULL;

    ctn[cn].ndq = rblk->next;   /* Remove block from input queue    */

	if (ctn[cn].tcb)
	{
		ctn[cn].tcb->rcv.wnd += rblk->len;

		/* Now we need to advertise a new window size */

        ctn[cn].tcb->send_ack = TRUE;
        tcp_output(cn);
	}
	
    return (rblk);
}


/*  CNget_char()    The next easiest.  Get a single char.
 *
 *      Not that this function must return an int16 so that a negative
 *  error code can be recognised as not a char.
 */

int16 cdecl CNget_char(int16 cn)
{
    NDB *p;
    int16 c;

    if (cn < 0 || cn >= CNMAX || ctn[cn].protocol == 0)
        return (E_BADHANDLE);

	if (ctn[cn].rhost != config.localhost)
	{
	    if (carrier_detect() < 0)
    	    ctn[cn].error = E_LOSTCARRIER;
	}
	
	if (ctn[cn].tcb && ctn[cn].tcb->state == TLISTEN)
		return (E_LISTEN);

    p = ctn[cn].ndq;

    if (p == (NDB *)NULL) {
        if (ctn[cn].error)
            return (ctn[cn].error);
        else
            return (E_NODATA);
    }

    c = *p->ndata++;

	/* This used to be after the following test  (--p->len...
		I moved it to make the readvertisement easier
		- Dan 2/1/2000
	*/
	
	if (ctn[cn].tcb)
		ctn[cn].tcb->rcv.wnd += 1;
	
    if (--p->len <= 0)
    {
    	/* Now we need to advertise a new window size */
    	/* here so that we save bandwidth */
    	
        CNdel_NDB(cn);
        
        ctn[cn].tcb->send_ack = TRUE;
        tcp_output(cn);
	}

    return (c & 0xff);
}

int16 cdecl CNget_block(int16 cn, char *blk, int16 blklen)
{
    NDB *p;
    int16 len;

    if (cn < 0 || cn >= CNMAX || ctn[cn].protocol == 0)
        return (E_BADHANDLE);

	if (ctn[cn].rhost != config.localhost)
	{
	    if (carrier_detect() < 0)
	        ctn[cn].error = E_LOSTCARRIER;
	}

	if (ctn[cn].tcb && ctn[cn].tcb->state == TLISTEN)
		return (E_LISTEN);

/*
    len = CNbyte_count(cn);

	old code I'm replacing - Baldrick 7/31/97
	
    if (len < blklen) 
	    {
	        if (len < 0)
	            return (len);
	        else
	            return (E_NODATA);
	    }
	    
	 I've ammended the byte_count test to handle the error returns
	 all at once.
*/

	if ((len = CNbyte_count(cn)) < 0)
		return (len);

	if (len < blklen)
		blklen = len;
	else
	    len = blklen;

    while (len > 0 && (p = ctn[cn].ndq) != (NDB *)NULL) 
   	{
   	    if (len > p->len) 
    	{
       		memcpy(blk, p->ndata, p->len);
       		len -= p->len;
       		blk = &blk[p->len];
       		CNdel_NDB(cn);
   		}
      	else {
       		memcpy(blk, p->ndata, len);
       		blk = &blk[p->len];
       		p->len -= len;
       		p->ndata = &p->ndata[len];
       		if (p->len <= 0)
       		    CNdel_NDB(cn);

			break;
   		}
   	}
    	
	if (ctn[cn].tcb)
	{
		ctn[cn].tcb->rcv.wnd += blklen;

		/* Now we need to advertise a new window size */

        ctn[cn].tcb->send_ack = TRUE;
        tcp_output(cn);
	}
	
    return (blklen);
}

/* This litle baby scans a block of memory for a search string 
 *
 * block 	= pointer to memory block to be scanned
 * search 	= string we are scanning for in 'block'
 * len 		= length of block we are to scan for 'search' in
 *
 * returns the location in memory of the first char after 'search'
 * or a NULL if 'search' is not found in the scanned area
 */

char *
memstr(void *block, char *search, size_t len)
{
	char *scan;
	size_t inter_len = 0;
	void *new_block;

	int done = 0;

	new_block = block;
	
	inter_len = len;

	do {
		if ((scan = memchr(new_block,(int)search[0],inter_len)) == NULL)
			return (NULL);
		else
			{
				if (memcmp(scan,search,strlen(search)) == 0)
					return((char *)scan + strlen(search));
				else
					{
						new_block = scan+1;
						inter_len = len - ((long) new_block - (long) block);
					}
			}
		} while (!done);
		
		return(NULL);
}

int16  
cdecl  CNgets (int16 cn, char *buffer, int16 len, char *delim)
{
	int16 datalen;   /* amount of data available for connection */
	char *left_over; /* pointer to left over data in block 		*/
	long length;	 /* length of data up to left_over in current
					  * NDB
					  */
	long left_len;	 /* length of left_over in current NDB		*/
    NDB *p;			 /* pointer to NDB we are processing 		*/
	int16 count = 0; /* Number of NDB's we've scanned			*/

	
	/* Initial normal connection processing */

    if (cn < 0 || cn >= CNMAX || ctn[cn].protocol == 0)
        return (E_BADHANDLE);

	if (ctn[cn].rhost != config.localhost)
	{
	    if (carrier_detect() < 0)
	        ctn[cn].error = E_LOSTCARRIER;
	}
	
	if (ctn[cn].tcb && ctn[cn].tcb->state == TLISTEN)
		return (E_LISTEN);

	/* Test for an error on the connection */

	if ((datalen = CNbyte_count(cn)) < 0)
		return (len);

	/* If there is no data on this connection pass this back 
	 *  No sense in processing it any farther
	 */
	 
	if (datalen == 0)
		return(E_NODATA);

    if ((p = ctn[cn].ndq) != (NDB *)NULL)
    	{
			while (TRUE)
		    	{
    	
		    		if ((left_over = memstr(p->ndata, delim, p->len)) != NULL)
		    			{
    						/* We've found it */

							/* Get size of the string in this packet */

							if ((long)left_over < ((long)p->ndata + (long)p->len))
								{
									left_len = ((long)p->ndata + (long)p->len) - (long)left_over;
										
									length = (long)p->len - left_len;

									datalen += (int16) length; /* same as above comment */
								}
							else
								{
									/* coincidence has it that the delim is at the end of this
									 * NDB
									 */
								
									left_len = 0;
									
									length = (long)p->len;
									
									datalen += p->len;
								}

							/* check to see if it exceedes the clients passed
							 * buffer size
							 */

							if (datalen > len)
								return(E_BIGBUF);

							/* see if it's in the first NDB */
							if(count == 0)
							{
								/* Yes it is, so it's simple to process */
									
    						    if (datalen == p->len) 
			   			    	{
									/* Special case - delim at end of NDB
									 * so copy NDB to buffer and delete the NDB
									 */

        				    		memcpy(buffer, p->ndata, p->len);
        						    		
    		    		    		CNdel_NDB(cn);
			    		   		}
				        		else 
			        			{
			        				/* Copy returned string to buffer */
			           				memcpy(buffer, p->ndata, datalen);

									/* reset the NDB infos */
											
		            				p->len -= datalen;
		            				p->ndata = &p->ndata[datalen];

									/* It doesn't look like this should ever occur */
		            				if (p->len <= 0)
		            				    CNdel_NDB(cn);
			        			}
							}
							else
								{
									/* No it's buried so we will need to loop until we 
									 * get all the data copied
									 */

									while (count > 0)
										{
											/* Set p to the connections first NDB */
											p = ctn[cn].ndq;							

											/* While count > 0 we copy all of the NDB into
											 * buffer
											 */
											 
        						    		memcpy(buffer, p->ndata, p->len);
    				    		    		CNdel_NDB(cn);
    				    		    		
    				    		    		/* Now we need to advertise a new window size */
    				    		    		/* If TCB */
										
											count--;
										}
										
									/* We are now on the last NDB
									 * reset p one last time
									 */
									 
									p = ctn[cn].ndq;

			        				/* Copy returned string to buffer 
			        				 * using the last NDB's portion of
			        				 * the returned string (ie. length)
			        				 */
		            				memcpy(buffer, p->ndata, length);

									/* reset the NDB infos */
									
		            				p->len -= (int16)length;
		            				p->ndata = &p->ndata[length];

									/* delete NDB if it's all gone */
		            				if (p->len <= 0)
		            				    CNdel_NDB(cn);
								}

							break;    			
    					}
    				else
    					{
    						/* We didn't find it, get next packet if available */
    						
    						if ((p = p->next) == (NDB *)NULL)
    							return(E_NODATA); /* delim didn't exist in the connections buffer */
				
							/* Increment count, we will need this if we find delim in a later NDB
							 * to be certain that all the data is copied to the buffer
							 */
							 
							count++;
							
							/* Increment datalen, since we don't want to overflow the clients
							 * buffer.
							 *
							 * Also test to see if the data is too large for the clients supplied
							 * buffer.
							 */
							 
							if ((datalen += p->len) > len)
								return(E_BIGBUF);
    					}

    			}
    	}
    	
	if (ctn[cn].tcb)
	{
		ctn[cn].tcb->rcv.wnd += datalen;

		/* Now we need to advertise a new window size */
        ctn[cn].tcb->send_ack = TRUE;
        tcp_output(cn);
	}

    return (len);

}


/*  TCP specific input functions    */

/*  CNget_cn()     Find the appropriate connection handle for a packet
 *
 *      This function delivers the TCB and returns either a
 *  connection handle, or an error code.  Use of this function
 *  simplifies q_tcp_in().  This function is specific to TCP.
 *
 *		Modified to handle LISTEN sockets..  A LISTEN socket has
 *	a rhost_ip of 0.0.0.0   So if the port matches, the protocol
 *	is P_TCP and the rhost_ip is 0L, then we have a packet in to
 *	the LISTEN socket.
 */

int16 CNget_cn(GPKT *p)
{
    int x;
    TCP_HDR *tcph = (TCP_HDR *)p->mp;
    IP_HDR *iph = (IP_HDR *)p->pip;

	/* if this is an identd packet and no identd connection open
		then open the identd connection */
		
	if (tcph->dport == 113)
	{		
		if (ctn[config.identdcn].tcb->state == TCLOSE_WAIT)
		{
			/*disp_info("identd closing\r\n");*/
			close_self(config.identdcn,ctn[config.identdcn].tcb);
		}
		
		if (config.identdcn == -1)
		{
			/* If we don't scan for remote closing, we inadvertantly 
			 * reopen the connection
			 */
			 
			if ((!tcph->f_fin)||(!tcph->f_rst))
			{
				config.identdcn = TCP_open(0L, 113, 0, 2000);
				x = config.identdcn;

				ctn[x].rport = tcph->sport;
				ctn[x].rhost = iph->s_ip;

				goto cachelastcn; /* Just cache it and return */
			}
		}

	}		
		
	if(tcph->dport == ctn[lastcn].lport)
	{
		/* chance it's the last connection */
			
		if (tcph->sport == ctn[lastcn].rport && iph->s_ip == ctn[lastcn].rhost)
			return(lastcn); /* it was the last connection */
	}

    for (x = 0; x < CNMAX; ++x) 
    {

		if (tcph->dport == ctn[x].lport) 
		{
       		if (tcph->sport == ctn[x].rport && iph->s_ip == ctn[x].rhost) 
   			{
				goto cachelastcn;						
			}
			else if ( ctn[x].protocol == P_TCP
				   && ctn[x].rhost == 0L
				   && ctn[x].tcb != (TCB *)NULL
				   && ctn[x].tcb->state == TLISTEN)
			{	/* OK!	*/

				ctn[x].rport = tcph->sport;
				ctn[x].rhost = iph->s_ip;

				goto cachelastcn;						
			}
		}
    }

nocon:
    return (E_NOCONNECTION);
    
cachelastcn:
	lastcn = x;
	return(x);
}

/*  CNlookup_cn() Lookup cn handle.  For ICMP messages to TCP processes
 */
int16 CNlookup_cn(int16 Sport, int16 Dport, int32 Dest_IP)
{
    int x;

    for (x = 0; x < CNMAX; ++x) {
        if ( Dport  == ctn[x].rport
          && Sport  == ctn[x].lport
          && Dest_IP == ctn[x].rhost) {

            return (x);
        }
    }
    return (E_NOCONNECTION);
}


/*  q_tcp_in()  Any (already verified) TCP packet is delivered here.
 *
 */

/*NEED TO MAKE THIS RETURN IF NO SPACE FOR THE PACKET. IE DON"T JUST WANT
TO DROP IT IF WE ARENT GOING TO SAVE IT*/

void q_tcp_in(int16 cn, GPKT *p)
{
    NDB *new, *q;

	/* If this is for the identd daemon then process it don't queue */
	if (cn == config.identdcn)
	{
		do_identd(p);
		return;
	}
											
    /* OK, now we can queue the data in a new NDB  */
    new = (NDB *)STiKmalloc( (long)sizeof(NDB) );

    if (new == (NDB *)NULL) {
        delete_packet(p, EA_NOMEMORY);  /* Presumably we're out of memory   */
        return;
    }


	{
		char *p=(char*)new; int i;
		
		for (i=0 ; i<sizeof(NDB) ; i++)
			*p++ = 0x00;
	}

    new->ptr = p->fp;
    p->fp = (char *)NULL;
    new->ndata = p->data;
    new->len = p->dlen;
    new->next = (NDB *)NULL;

    delete_packet(p, NT_QUEUEDOK);

    if (ctn[cn].ndq == (NDB *)NULL) {   /* If queue empty   */
        ctn[cn].ndq = new;               /* Point it to new data */
        return;
    }

    q = ctn[cn].ndq;                     /* Else get ptr to start of list    */

    while (q->next != (void *)NULL)     /* Find end of list */
        q = q->next;

    q->next = new;                      /* And tack new data to the end     */
}
