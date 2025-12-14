#ifndef _IF_H
#define _IF_H

#include "socket.h"

/* net interface flags */
#define IFF_UP		0x0001		/* if is up */
#define IFF_BROADCAST	0x0002		/* if supports broadcasting */
#define IFF_DEBUG	0x0004		/* if debugging is on */
#define IFF_LOOPBACK	0x0008		/* if is software loopback */
#define IFF_POINTOPOINT	0x0010		/* if for p2p connection */
#define IFF_NOTRAILERS	0x0020		/* if should not use trailer encaps. */
#define IFF_RUNNING	0x0040		/* if ressources are allocated */
#define IFF_NOARP	0x0080		/* if should not use arp */

#define IF_NAMSIZ	16		/* maximum if name len */

struct netif;

/* structure for holding address information, assumes internet style */
struct ifaddr {
	unsigned long	addr;		/* local address */
	union {
		unsigned long	broadaddr;	/* broadcast address */
		unsigned long	dstaddr;	/* point2point dst address */
	} ifu;
	struct netif	*ifp;		/* interface this belongs to */
	struct ifaddr	*next;		/* next ifaddr */

	short		family;		/* address family */
	unsigned long	net;		/* network id */
	unsigned long	netmask;	/* network mask */
	unsigned long	subnet;		/* subnet id */
	unsigned long	subnetmask;	/* subnet mask */
	unsigned long	net_broadaddr;	/* logical broadcast addr */
	unsigned short	flags;		/* flags */
};

/* structure describing a net interface */
struct netif {
	char		name[IF_NAMSIZ];/* interface name */
	short		unit;		/* interface unit */

	unsigned short	flags;		/* interface flags */
	unsigned long	metric;		/* routing metric */
	unsigned long	mtu;		/* maximum transmission unit */
	unsigned long	timer;		/* timeout delta in ms */
	struct ifaddr	*addrlist;	/* addresses for this interf. */
	void		*send_q;	/* send queue */
	
	long		(*open) (void);
	long		(*close) (void);
	long		(*output) (void);
	long		(*ioctl) (struct netif *, short, long);
	void		(*timeout) (long);

	void		*data;		/* extra data the if may want */
	
	unsigned long	in_packets;	/* # input packets */
	unsigned long	in_errors;	/* # input errors */
	unsigned long	out_packets;	/* # output packets */
	unsigned long	out_errors;	/* # output errors */
	unsigned long	collisions;	/* # collisions */

	struct netif	*next;		/* next interface */
};

/* argument structure for the SIOC* ioctl()'s on sockets */
struct ifreq {
	char	ifr_name[IF_NAMSIZ];		/* interface name */
	union {
		struct	sockaddr addr;		/* local address */
		struct	sockaddr dstaddr;	/* p2p dst address */
		struct	sockaddr broadaddr;	/* broadcast addr */
		struct	sockaddr netmask;	/* network mask */
		short	flags;			/* if flags, IFF_* */
		long	metric;			/* routing metric */
		long	mtu;			/* max transm. unit */
		void	*data;			/* other data */
	} ifru;
};

/* result structure for the SIOCGIFCONF socket ioctl() */
struct ifconf {
	int	len;				/* buffer len */
	union {
		void 		*buf;		/* the actual buffer */
		struct ifreq 	*req;		/* ifreq structure */
	} ifcu;
};

#endif /* _IF_H */
