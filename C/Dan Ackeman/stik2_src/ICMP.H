/*
 * ICMP.H  holds definitions for ICMP codes etc.
 *
 * Dan Ackerman February 1998
 */

#define ICMP_MINLEN		8	/* minimum size of an ICMP message */
#define ICMP_TSLEN		20	/* size of ICMP timestamp messages */
#define ICMP_MASKLEN	12	/* size of ICMP address mask messages */
#define ICMP_ADVLENMIN	26	/* minimum size of an ICMP error (advise) message
								(IP + ICMP + BADIP = 20 + 8 + 8 = 26) */


#define ENETUNREACH		0
#define EHOSTUNREACH	1

/* Probably better to do this with a union */

typedef struct icmp_redir {
    uint8   type;           /*  Icmp message type                           */
    uint8   code;           /*  Various meanings depending on Type          */
    uint16  sum;            /*  Checksum of the ICMP header and data        */
	uint32  newaddr;		/*  Redirected address 							*/
} ICMP_REDIR;


