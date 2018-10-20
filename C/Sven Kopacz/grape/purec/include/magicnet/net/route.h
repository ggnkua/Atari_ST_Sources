/*
 *	net/route.h for MintNet, (w) 1994, Kay Roemer.
 *
 *	Some RTF_* flags are missing. I used the 4.3 BSD rtentry
 *	structure and added an rt_metric field.
 */

#ifndef _NET_ROUTE_H
#define _NET_ROUTE_H

#ifndef _COMPILER_H
#include <compiler.h>
#endif

#include <net/if.h>

struct rtentry {
	unsigned long	rt_hash;	/* hash key */
	struct sockaddr	rt_dst;		/* key */
	struct sockaddr	rt_gateway;	/* value */
	short		rt_flags;	/* up/down?, host/net */
#define RTF_UP		0x0001
#define RTF_GATEWAY	0x0002
#define RTF_HOST	0x0004
#define RTF_REJECT	0x0008
#define RTF_STATIC	0x0010
#define RTF_DYNAMIC	0x0020
#define RTF_MODIFIED	0x0040
#define RTF_MASK	0x0080

	unsigned long	rt_metric;	/* distance metric */
	short		rt_refcnt;	/* # held references */
	unsigned long	rt_use;		/* raw # packets forwarded */
	struct ifnet	*rt_ifp;	/* interface to use */
};

#endif /* _NET_ROUTE_H */
