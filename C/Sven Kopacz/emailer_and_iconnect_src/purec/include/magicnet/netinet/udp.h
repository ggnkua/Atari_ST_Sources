/*
 *	netinet/udp.h for MintNet, (w) '94, Kay Roemer.
 */

#ifndef _NETINET_UDP_H
#define _NETINET_UDP_H

#ifndef _COMPILER_H
#include <compiler.h>
#endif

struct udphdr {
	unsigned short	uh_sport;	/* source port */
	unsigned short	uh_dport;	/* destination port */
	unsigned short	uh_ulen;	/* datagram length */
	unsigned short	uh_sum;		/* checksum */
};

#endif /* _NETINET_UDP_H */
