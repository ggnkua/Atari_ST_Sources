/*
 * net/if_arp.h for MintNet, (w) 1994 Kay Roemer.
 */

#ifndef _NET_IF_ARP_H
#define _NET_IF_ARP_H

struct	arphdr {
	u_short	ar_hrd;		/* format of hardware address */
#define ARPHRD_ETHER 	1	/* ethernet hardware address */
	u_short	ar_pro;		/* format of protocol address */
	u_char	ar_hln;		/* length of hardware address */
	u_char	ar_pln;		/* length of protocol address */
	u_short	ar_op;		/* one of: */
#define	ARPOP_REQUEST	1	/* request to resolve address */
#define	ARPOP_REPLY	2	/* response to previous request */
/*
 * The remaining fields are variable in size,
 * according to the sizes above.
 */
/*	u_char	ar_sha[];	 sender hardware address */
/*	u_char	ar_spa[];	 sender protocol address */
/*	u_char	ar_tha[];	 target hardware address */
/*	u_char	ar_tpa[];	 target protocol address */
};

/* structure passed on SIOC?ARP ioctl's */
struct arpreq {
	struct sockaddr	arp_pa;		/* protocol address */
	struct sockaddr	arp_ha;		/* hardware address */
	short		arp_flags;	/* ATF_* flags */
};

#define ATF_PRCOM	0x01		/* pr address valid */
#define ATF_COM		0x02		/* hw address valid */
#define ATF_PERM	0x04		/* static entry */
#define ATF_PUBL	0x08		/* proxy entry */
#define ATF_USETRAILERS	0x10		/* not implemented */
#define ATF_NORARP	0x20		/* don't use for answering RARP req */

#endif
