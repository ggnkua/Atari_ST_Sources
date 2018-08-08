/*  packet.c    (c) Steve Adam 1995         steve@netinfo.com.au
 *
 *      Contains functions for allocating and deleting packets.
 *  A packet is a GPKT structure which includes a pointer to an
 *  allocated data buffer.  This is allocated at the same time.
 */
#include "lattice.h"
#include <stdio.h>      /* for NULL */
#include "krmalloc.h"
#include "globdefs.h"
#include "globdecl.h"
#include "ppp.h"

/*  Allocate a packet structure and the data buffer it points
 *  to.  This data buffer will be pkt_size bytes.
 */

#if MEMDEBUG
#undef STiKmalloc
#undef STiKfree
#undef allocate_packet
#undef delete_packet
GPKT *allocate_packet(uint16 pkt_size, const char *file, int line)
#else
GPKT *allocate_packet(uint16 pkt_size)
#endif
{
    GPKT *newpkt;
    char *newbuf;    

#if MEMDEBUG
    newpkt = (GPKT *)STiKmalloc( (long)sizeof(GPKT), file, line);
#else
    newpkt = (GPKT *)STiKmalloc( (long)sizeof(GPKT));
#endif

    if (newpkt == (GPKT *)NULL) 
   	{
        elog[NOT_CREATED] += 1; /* Increment creation failed count  */
        return (GPKT *)NULL;
    }

	{
		char *p=(char*)newpkt; int i;
		
		for (i=0 ; i<sizeof(GPKT) ; i++)
			*p++ = 0x00;
	}

#if MEMDEBUG
    newbuf = STiKmalloc((long)pkt_size, file, line+1);
#else
    newbuf = STiKmalloc((long)pkt_size);
#endif

    if (newbuf == (char *)NULL) 
	{
		elog[NOT_CREATED] += 1; /* Increment creation failed count  */

#if MEMDEBUG
        STiKfree((char *)newpkt, file, line+1);
#else
		while(STiKfree((char *)newpkt) == E_LOCKED)
			;
#endif

	    return (GPKT *)NULL;
	}

    newpkt->fp = newpkt->pip = newbuf;
	newpkt->protocol = IP_PROTOCOL;

    elog[TOT_CREATED] += 1; /* Increment our creation count     */

    return newpkt;
}


long elog[E_REASONS];

/*  delete_packet()     Delete a packet and it's buffer (if valid).
 *
 *  The second parameter is a reason code for packet deletion,
 *  and delete_packet() keeps a count of packets deleted, and why
 *  in the elog array.
 */

#ifdef MEMDEBUG
void delete_packet(GPKT *oldpkt, int reason, const char *file, int line)
#else
void delete_packet(GPKT *oldpkt, int reason)
#endif
{
    if (oldpkt == (GPKT *)NULL) /* This shouldn't happen, but.....  */
        return;

#if MEMDEBUG
    if (oldpkt->fp != NULL)
        STiKfree(oldpkt->fp, file, line);

    STiKfree((char *)oldpkt, file, line+1);
#else
    if (oldpkt->fp != NULL)
	{
        while(STiKfree(oldpkt->fp) == E_LOCKED)
        	;
	}
	
    while(STiKfree((char *)oldpkt) == E_LOCKED)
    	;
#endif

    elog[reason] += 1;          /* update delete statistics         */
    elog[TOT_DELETED] += 1;     /* update total deletion count      */
}
