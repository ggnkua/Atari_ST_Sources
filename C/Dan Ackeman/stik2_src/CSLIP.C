/*
 *		CSLIP.C
 *
 *  	I've moved the current CSLIP code into here seperating it
 * from the normal SLIP code.
 *
 *	DA 2 - 22 - 97
 */

#include "lattice.h"
#include <stdio.h>      /* Included for NULL.  Might change that later...   */
#include <tos.h>
#include <string.h>
#include <stdlib.h>
#include "device.h"

#include "globdefs.h"
#include "globdecl.h"

extern DEV_LIST *bdev;

extern void	*memcpy (void *, const void *, unsigned long);
extern int	memcmp (const void *, const void *, unsigned long);
extern void    *memset( void *ptr, int val, size_t len );
/*extern void	*bzero (void *, unsigned long);*/

/* Bits in first octet of compressed packet */
#define NEW_C	0x40	/* flag bits for what changed in a packet */
#define NEW_I	0x20
#define NEW_S	0x08
#define NEW_A	0x04
#define NEW_W	0x02
#define NEW_U	0x01

#define TCP_PUSH_BIT 0x10

/* reserved, special-case values of above */
#define SPECIAL_I	(NEW_S|NEW_W|NEW_U)	  /* echoed interactive traffic */
#define SPECIAL_D	(NEW_S|NEW_A|NEW_W|NEW_U) /* unidirectional data */
#define SPECIALS_MASK	(NEW_S|NEW_A|NEW_W|NEW_U)


#define BCMP(p1,p2,n)		memcmp((p2), (p1), (uint32)(n))
#define BCOPY(p1,p2,n)		memcpy((p2), (p1), (uint32)(n))
#define ovbcopy(p1,p2,n)	memcpy((p2), (p1), (uint32)(n))

extern struct slip *myslip;
extern struct slcompress *comp;
extern struct cstate mytstate[MAX_STATES];
extern struct cstate myrstate[MAX_STATES];


octet
slc_type (b)
	GPKT *b;
{	
	octet c = *b->pip & 0xf0; 
	
	if (c == (IP_VERSION << 4))
			return TYPE_IP;
	if (c & 0x80)
		{
			return TYPE_COMPRESSED_TCP;
		}
	if (c == TYPE_UNCOMPRESSED_TCP)
		{
			return TYPE_UNCOMPRESSED_TCP;
		}

	return TYPE_ERROR;
}

/* This is just calc sum with out the initial value
    should save a fair amount of time */

uint16 chksum(char *p, uint16 count)
{
	register uint32 sum;
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




/* ENCODE encodes a number that is known to be non-zero.  ENCODEZ
 * checks for zero (since zero has to be encoded in the long, 3 byte
 * form).
 */
 
 #define ENCODE(n) \
{	if ((uint16)(n) > 255 || (uint16)(n) == 0) \
	{	*cp++ = 0; \
		*cp++ = (uint16)(n) >> 8; \
	} \
	*cp++ = (uint8)(n); \
}

 
 #define DECODEL(f) \
{	if (*cp) \
		(f) += (uint32)*cp++; \
	else \
	{	(f) += (int32)((int16)(((uint8)cp[1] << 8) | (uint8)cp[2])); \
		cp += 3; \
	} \
}

#define DECODES(f) \
{	if (*cp) \
		(f) += (uint16)*cp++; \
	else \
	{	(f) += (uint16)(((uint8)cp[1] << 8) | (uint8)cp[2]); \
		cp += 3; \
	} \
}

#define DECODEU(f) \
{	if (*cp == 0) \
		(f) = (uint16)*cp++; \
	else \
	{	(f) = (uint16)(((uint8)cp[1] << 8) | (uint8)cp[2]); \
		cp += 3; \
	} \
}

 
/*#define ENCODE(n) { \
	if ((int16)(n) >= 256) { \
		*cp++ = 0; \
		cp[1] = (n); \
		cp[0] = (n) >> 8; \
		cp += 2; \
	} else { \
		*cp++ = (n); \
	} \
}
#define ENCODEZ(n) { \
	if ((int16)(n) >= 256 || (int16)(n) == 0) { \
		*cp++ = 0; \
		cp[1] = (n); \
		cp[0] = (n) >> 8; \
		cp += 2; \
	} else { \
		*cp++ = (n); \
	} \
}

#define DECODEL(f) { \
	if (*cp == 0) {\
		(f) = (f + ((cp[1] << 8) | cp[2])); \
		cp += 3; \
	} else { \
		(f) = htonl(ntohl(f) + (uint32)*cp++); \
	} \
}

#define DECODES(f) { \
	if (*cp == 0) {\
		f = f + ((cp[1] << 8) | cp[2]); \
		cp += 3; \
	} else { \
		f = f + (uint16)*cp++; \
	} \
}

#define DECODEU(f) { \
	if (*cp == 0) {\
		(f) = (cp[1] << 8) | cp[2]; \
		cp += 3; \
	} else { \
		(f) = (uint16)*cp++; \
	} \
}
*/


/*
 *
 *  DECOMPRESSION ROUTINES
 *
 */


short
uncompress (b, slp)
	GPKT *b;
	struct slip *slp;
{
	octet type;

	type = slc_type(b);

	switch (type) {
	case TYPE_IP:
		/*printf("\r\nType IP\r\n");*/
		return 0;

	case TYPE_COMPRESSED_TCP:
		/*printf ("\r\nCompressed TCP\r\n");*/
		
		if (slp->flags & SLF_COMPRESS) {
			return !slc_uncompress (b, type, slp->comp);
		}
		break;

	case TYPE_UNCOMPRESSED_TCP:
		/*printf("\r\nuncompressed TCP\r\n");*/
		if (slp->flags & SLF_COMPRESS) {
			return !slc_uncompress (b, type, slp->comp);
		}
		if (slp->flags & SLF_AUTOCOMP &&
		    slc_uncompress (b, type, slp->comp)) {
			slp->flags |= SLF_COMPRESS;
			return 0;
		}
		break;
	}
	return 1;
}


unsigned char
slc_compress (b, comp, compress_cid)
	GPKT *b;
	struct slcompress *comp;
	long compress_cid;
{
	register struct cstate *cs = comp->last_cs->cs_next;
	register struct ip_header *ip = (struct ip_header *)b->pip;
	register uint32 hlen = ip->ihl;
	register TCP_HDR *oth;
	TCP_HDR *th;
	register uint32 deltaS, deltaA;
	register int16 changes = 0; /* int16 */
	unsigned char new_seq[16];
	unsigned char *cp = new_seq;


	/*
	 * Bail if this is an IP fragment or if the TCP packet isn't
	 * `compressible' (i.e., ACK isn't set or some other control bit is
	 * set).  (We assume that the caller has already made sure the
	 * packet is IP proto TCP). I fixed this it can be not TCP
	 */
	 
	/* Bail if this packet isn't TCP, or is an IP fragment */
	if(ip->ptcl != IPPROTO_TCP || ip->ofst != 0 || ip->ofst & ~FLAG_DF || b->ip_len < 40)
	{ 
		/* Send as regular IP */
		return TYPE_IP;
	}

	/* Extract TCP header */
	th = (TCP_HDR *)IP_DATA(b);
	
	/*  Bail if the TCP packet isn't `compressible' (i.e., ACK isn't set or
	 *  some other control bit is set).
	 */
	if(th->f_syn || th->f_fin || th->f_rst || th->f_ack != th->f_ack)
	{
		/* TCP connection stuff; send as regular IP */
		return TYPE_IP;
	}

	/*
	 * Packet is compressible -- we're going to send either a
	 * COMPRESSED_TCP or UNCOMPRESSED_TCP packet.  Either way we need
	 * to locate (or create) the connection state.  Special case the
	 * most recently used connection since it's most likely to be used
	 * again & we don't have to do any reordering if it's used.
	 */
	/*INCR (sls_packets);*/

	
	if (ip->s_ip != cs->cs_ip.s_ip ||
	    ip->d_ip != cs->cs_ip.d_ip ||
	   *(long *)th != ((long *)&cs->cs_ip)[cs->cs_ip.ihl]) {
		/*
		 * Wasn't the first -- search for it.
		 *
		 * States are kept in a circularly linked list with
		 * last_cs pointing to the end of the list.  The
		 * list is kept in lru order by moving a state to the
		 * head of the list whenever it is referenced.  Since
		 * the list is short and, empirically, the connection
		 * we want is almost always near the front, we locate
		 * states via linear search.  If we don't find a state
		 * for the datagram, the oldest state is (re-)used.
		 */

		struct cstate *lcs;
		struct cstate *lastcs = comp->last_cs;

		do {
			lcs = cs; 
			cs = cs->cs_next;
						
			/*INCR (sls_searches);*/

			if (ip->s_ip == cs->cs_ip.s_ip &&
			    ip->d_ip == cs->cs_ip.d_ip &&
			    *(long *)th == ((long *)&cs->cs_ip)[cs->cs_ip.ihl])
			    {
					goto found;
				}
		} while (cs != lastcs); 

		/*
		 * Didn't find it -- re-use oldest cstate.  Send an
		 * uncompressed packet that tells the other side what
		 * connection number we're using for this conversation.
		 * Note that since the state list is circular, the oldest
		 * state points to the newest and we only need to set
		 * last_cs to update the lru linkage.
		 */
		/*INCR (sls_misses);*/
		comp->last_cs = lcs;
		hlen += th->ofst; /* *4; */
		hlen <<= 2;
		goto uncompressed;

	found:
		/*
		 * Found it -- move to the front on the connection list.
		 */

		if (cs == lastcs)
			{
				comp->last_cs = lcs;
			}
		else 
			{
				lcs->cs_next = cs->cs_next;
				cs->cs_next = lastcs->cs_next;
				lastcs->cs_next = cs;
			}

	}

	/*
	 * Make sure that only what we expect to change changed. The first
	 * line of the `if' checks the IP protocol version, header length &
	 * type of service.  The 2nd line checks the "Don't fragment" bit.
	 * The 3rd line checks the time-to-live and protocol (the protocol
	 * check is unnecessary but costless).  The 4th line checks the TCP
	 * header length.  The 5th line checks IP options, if any.  The 6th
	 * line checks TCP options, if any.  If any of these things are
	 * different between the previous & current datagram, we send the
	 * current datagram `uncompressed'.
	 */
	oth = (TCP_HDR *)&((long *)&cs->cs_ip)[hlen];
	deltaS = hlen;
	hlen += th->ofst; /* *4; */
	hlen <<= 2;

	if (((unsigned short *)ip)[0] != ((unsigned short *)&cs->cs_ip)[0] ||
	    ((unsigned short *)ip)[3] != ((unsigned short *)&cs->cs_ip)[3] ||
	    ((unsigned short *)ip)[4] != ((unsigned short *)&cs->cs_ip)[4] ||
	    th->ofst != oth->ofst ||
	    (deltaS > 5 &&
	     BCMP(ip + 1, &cs->cs_ip + 1, (deltaS - 5) << 2)) ||
	    (th->ofst > 5 &&
	     BCMP(th + 1, oth + 1, (th->ofst - 5) << 2)))
		goto uncompressed;


	/*
	 * Figure out which of the changing fields changed.  The
	 * receiver expects changes in the order: urgent, window,
	 * ack, seq (the order minimizes the number of temporaries
	 * needed in this section of code).
	 */
	if (th->f_urg) {
		deltaS = th->urgent;
		ENCODE(deltaS); /* was ENCODEZ */
		changes |= NEW_U;
	} else if (th->urgent != oth->urgent) {
		/* argh! URG not set but urp changed -- a sensible
		 * implementation should never do this but RFC793
		 * doesn't prohibit the change so we have to deal
		 * with it. */
		 goto uncompressed;
	}

	if ((deltaS = (unsigned short)(th->window - oth->window))!=0L)
	{
		ENCODE(deltaS);
		changes |= NEW_W;
	}

	if ((deltaA = th->ack - oth->ack)!=0L)
	{
		if (deltaA > 0x0000ffffL)
			goto uncompressed;
		ENCODE(deltaA);
		changes |= NEW_A;
	}

	if ((deltaS = th->seq - oth->seq)!=0L) 
	{
		if (deltaS > 0x0000ffffL)
			goto uncompressed;
		ENCODE(deltaS);
		changes |= NEW_S;
	}

	switch(changes) {

	case 0:
		/*
		 * Nothing changed. If this packet contains data and the
		 * last one didn't, this is probably a data packet following
		 * an ack (normal on an interactive connection) and we send
		 * it compressed.  Otherwise it's probably a retransmit,
		 * retransmitted ack or window probe.  Send it uncompressed
		 * in case the other side missed the compressed version.
		 */

		if(ip->len != cs->cs_ip.len && cs->cs_ip.len == hlen)
			break;

		/*goto uncompressed;*/

		/* (fall through) */

	case SPECIAL_I:
	case SPECIAL_D:
		/*
		 * actual changes match one of our special case encodings --
		 * send packet uncompressed.
		 */
		goto uncompressed;

	case NEW_S|NEW_A:
		if (deltaS == deltaA &&
		    deltaS == cs->cs_ip.len - hlen) {
			/* special case for echoed terminal traffic */
			changes = SPECIAL_I;
			cp = new_seq;
		}
		break;

	case NEW_S:
		if (deltaS == cs->cs_ip.len - hlen) {
			/* special case for data xfer */
			changes = SPECIAL_D;
			cp = new_seq;
		}
		break;
	}

	deltaS = ip->id - cs->cs_ip.id;
	if (deltaS != 1) {
		ENCODE(deltaS);
		changes |= NEW_I;
	}
	if (th->f_psh)
		changes |= TCP_PUSH_BIT;
	/*
	 * Grab the cksum before we overwrite it below.  Then update our
	 * state with this packet's header.
	 */
	deltaA = th->sum;
	BCOPY(ip, &cs->cs_ip, hlen);

	/*
	 * We want to use the original packet as our compressed packet.
	 * (cp - new_seq) is the number of bytes we need for compressed
	 * sequence numbers.  In addition we need one byte for the change
	 * mask, one for the connection id and two for the tcp checksum.
	 * So, (cp - new_seq) + 4 bytes of header are needed.  hlen is how
	 * many bytes of the original packet to toss so subtract the two to
	 * get the new packet size.
	 */
	deltaS = cp - new_seq;
	cp = (unsigned char *)ip;
	if (compress_cid == 0 || comp->last_xmit != cs->cs_id) {
		comp->last_xmit = cs->cs_id;
		hlen -= deltaS + 4;
		cp += hlen;
		*cp++ = changes | NEW_C;
		*cp++ = cs->cs_id;
	} else {
		hlen -= deltaS + 3;
		cp += hlen;
		*cp++ = changes;
	}

	b->pip += hlen;  
	*cp++ = deltaA >> 8;
	*cp++ = deltaA;
	BCOPY(new_seq, cp, deltaS);
	/*INCR (sls_compressed);*/

	/*printf("before return compressed\r\n");*/
	return (TYPE_COMPRESSED_TCP);

	/*
	 * Update connection state cs & send uncompressed packet ('uncompressed'
	 * means a regular ip/tcp packet but with the 'conversation id' we hope
	 * to use on future compressed packets in the protocol field).
	 */
uncompressed:
	BCOPY(ip, &cs->cs_ip, hlen);
	ip->ptcl = cs->cs_id;
	comp->last_xmit = cs->cs_id;
		
	/*printf("before return uncompressed\r\n");*/
	return (TYPE_UNCOMPRESSED_TCP);
}

 
long
slc_uncompress (b, type, comp)
	GPKT *b;
	octet type;
	struct slcompress *comp;
{
	register	char	*cp;
	register	uint32	hlen;
	register	long	len;
	register	int		changes;
	TCP_HDR *th;
	struct cstate *cs;
	IP_HDR *ip;

/* URAn NB:	char *newbuf; this declaration is redundant with new block copy method */

	len = b->ip_len;

	switch (type) {

	case TYPE_UNCOMPRESSED_TCP:
		/*
		 *  Here we grab all the header info for later decompression
		 *  rstate stands for recieve state.
		 */

	    ip = (IP_HDR *)b->pip;

		if (len < 40 || ip->ptcl >= MAX_STATES)
			{
				goto bad;
			}

		/*
		 * clear out TYPE_UNCOMPRESSED_TCP
		 */

		ip->ver &= 0x4;
		
		comp->last_recv = ip->ptcl;
		
/* URAn NB:	cs = &comp->rstate[comp->last_recv];  BUG
 *		Pure_C complained about pointer conversion for the above,
 *		and it would result in an address of a pointer inside the
 * 		rstate array, rather than in one of the pointer values.
 */

		cs = (struct cstate *) &comp->rstate[comp->last_recv];  /* URAn: corrected */
		comp->flags &= ~SLF_TOSS;
		ip->ptcl = IPPROTO_TCP;
		hlen = ip->ihl;
		hlen += ((TCP_HDR *)&((long *)ip)[hlen])->ofst;
		hlen <<= 2;
		BCOPY(ip, &cs->cs_ip, hlen);
		cs->cs_ip.sum = 0;
		cs->cs_hlen = hlen;
		
		return (len);

	case TYPE_COMPRESSED_TCP:
		break;

	default:
		goto bad;
	}

	/* We've got a compressed packet. */
	/* INCR (sls_compressedin); */

	cp = b->pip;				/* dstart */ /* was fp experimenting now */
	changes = *cp++;

	if (changes & NEW_C) {
		/* Make sure the state index is in range, then grab the state.
		 * If we have a good state index, clear the 'discard' flag. */
		if (*cp >= MAX_STATES)
			{
				goto bad;
			}
		comp->flags &= ~SLF_TOSS;
		comp->last_recv = *cp++;
	} else {
		/* this packet has an implicit state index.  If we've
		 * had a line error since the last time we got an
		 * explicit state index, we have to toss the packet. */

		if (comp->flags & SLF_TOSS) {
			/*INCR (sls_tossed);*/
			return (0);
		}
	}

/* URAn NB:	cs = &comp->rstate[comp->last_recv];  BUG
 *		Pure_C complained about pointer conversion for the above,
 *		and it would result in an address of a pointer inside the
 * 		rstate array, rather than in one of the pointer values.
 */

	cs = (struct cstate *) &comp->rstate[comp->last_recv];  /* URAn: corrected */
	hlen = cs->cs_ip.ihl << 2;
	th = (TCP_HDR *)&((unsigned char *)&cs->cs_ip)[hlen];
	th->sum = (*cp << 8) | cp[1];
	cp += 2;

	if (changes & TCP_PUSH_BIT)
		th->f_psh = 1;
	else
		th->f_psh = 0;

	switch (changes & SPECIALS_MASK) {

	case SPECIAL_I:
		{
			uint32 i = cs->cs_ip.len - cs->cs_hlen;
			th->ack = th->ack + i;
			th->seq = th->seq + i;
		}
		break;

	case SPECIAL_D:
		th->seq = th->seq + cs->cs_ip.len
				   - cs->cs_hlen;
		break;

	default:
		if (changes & NEW_U)
		{	
			th->f_urg = 1;
			DECODEU(th->urgent); /*DECODEU*/
		} else
			th->f_urg = 0;
		if (changes & NEW_W)
			DECODES (th->window);
		if (changes & NEW_A)
			DECODEL (th->ack);
		if (changes & NEW_S)
			DECODEL (th->seq);
		break;
	}
	if (changes & NEW_I)
	{	
		DECODES (cs->cs_ip.id);
	}
	else
		cs->cs_ip.id = cs->cs_ip.id + 1;


	/*
	 * At this point, cp points to the first byte of data in the
	 * packet.  If we're not aligned on a 4-byte boundary, copy the
	 * data down so the ip & tcp headers will be aligned.  Then back up
	 * cp by the tcp/ip header length to make room for the reconstructed
	 * header (we assume the packet we were handed has enough space to
	 * prepend 128 bytes of header).  Adjust the length to account for
	 * the new header & fill in the IP total length.
	 */

	len -= (cp - (char *)b->pip); 	/* was fp */

	if (len < 0)
		{
		/* we must have dropped some characters (crc should detect
		 * this but the old slip framing won't) */
		goto bad;
		}

	/* OK it doesn't like adjusting the beginning of the packet 
		which is what we seem to be doing.  So lets try making space
		building it there and moving it back - worth a try */

/* URAn NB: I will use 'in-situ' transfers instead (memcpy supports overlap handling) */
/*          the extra buffer is thus not used any more, and I added some more tests   */
/*          for 'impossible' cases just to be safe (same as in asm version).          */

/*	if (cs->cs_hlen <= 0)  goto bad;
	if (cs->cs_hlen > 128) goto bad;

	len += cs->cs_hlen;
	cs->cs_ip.len = (int16)len;*/

/*	We must now move the packet data up in 'b' RAM to allow for the new header size
 *	so this move must start at the end and work downwards in RAM to handle overlap
 *	(memcpy supports this).  Then we must move the new cstate header into the room made.
 *	The data needed for both moves will be read before moving any, for overlap safety.
 *  (This may actually be unnecessary, but certainly can't do any harm.)
 */
/*	{	uint32	new_hlen = cs->cs_hlen;

		BCOPY((char *)(b->data), ((char *) b)+new_hlen, b->dlen);
		BCOPY((char *)&cs->cs_ip, (char *) b, new_hlen);
    }*/
    
   	if ((long)cp & 1) {
		if (len > 0)
			ovbcopy (cp, cp-1, len);
		--cp;
		/* --b->dend;*/
	}
	cp -= cs->cs_hlen;
	len += cs->cs_hlen;
	cs->cs_ip.len = (int16)len;
	BCOPY(&cs->cs_ip, cp, cs->cs_hlen);
	b->pip = cp;


	/* recompute the ip header checksum */
	/*((IP_HDR *)b)->sum = 0;*/
	 		 /*Zero sum before new calculation  */

    /*((IP_HDR *)cp)->sum = chksum(cp, (int16)hlen>>1);*/

    ((IP_HDR *)cp)->sum = 0;   /* Zero sum before new calculation  */
    ((IP_HDR *)cp)->sum = calc_sum(b->pip, 0, (int16)sizeof(IP_HDR));

	return (len);

bad:
	comp->flags |= SLF_TOSS;
	/*INCR (sls_errorin);*/
	return (0);
}

