/*
inet/inet_config.c

Created:	Nov 11, 1992 by Philip Homburg

Give values for structures defined in inet_config.h

Copyright 1995 Philip Homburg
*/

#include "inet.h"
#include "generic/type.h"
#include "generic/buf.h"
#include "generic/eth.h"
#include "generic/event.h"
#include "generic/ip.h"
#include "generic/ip_int.h"
#include "generic/psip.h"
#include "generic/sr.h"

struct eth_conf eth_conf[]=
{
	/*	minor		port	*/
	{	ETH_DEV0,	0	},
	{	ETH_DEV1,	1	},
};
extern int ok[sizeof(eth_conf)/sizeof(eth_conf[0]) == ETH_PORT_NR ? 1 : -1];

struct arp_conf arp_conf[]=
{
	/*	port	*/
	{	ETH0	},
	{	ETH1	},
};
extern int ok[sizeof(arp_conf)/sizeof(arp_conf[0]) == ARP_PORT_NR ? 1 : -1];

struct psip_conf psip_conf[]=
{
	/*	minor		*/
#if ENABLE_PSIP
	{	PSIP_DEV0	},
	{	PSIP_DEV1	},
#endif /* ENABLE_PSIP */
};
extern int ok[sizeof(psip_conf)/sizeof(psip_conf[0]) == PSIP_PORT_NR ? 1 : -1];

struct ip_conf ip_conf[]=
{
	/*	minor		device type	device number	*/
	{	IP_DEV0,	IPDL_ETH,	ETH0		},
	{	IP_DEV1,	IPDL_ETH,	ETH1		},
#if ENABLE_PSIP
	{	IP_DEV2,	IPDL_PSIP,	PSIP0		},
	{	IP_DEV3,	IPDL_PSIP,	PSIP1		},
#endif
};
extern int ok[sizeof(ip_conf)/sizeof(ip_conf[0]) == IP_PORT_NR ? 1 : -1];

struct tcp_conf tcp_conf[]=
{
	/*	minor		port	*/
	{	TCP_DEV0,	IP0	},
	{	TCP_DEV1,	IP1	},
#if ENABLE_PSIP
	{	TCP_DEV2,	IP2	},
	{	TCP_DEV3,	IP3	},
#endif
};
extern int ok[sizeof(tcp_conf)/sizeof(tcp_conf[0]) == TCP_PORT_NR ? 1 : -1];

struct udp_conf udp_conf[]=
{
	/*	minor		port	*/
	{	UDP_DEV0,	IP0	},
	{	UDP_DEV1,	IP1	},
#if ENABLE_PSIP
	{	UDP_DEV2,	IP2	},
	{	UDP_DEV3,	IP3	},
#endif
};
extern int ok[sizeof(udp_conf)/sizeof(udp_conf[0]) == UDP_PORT_NR ? 1 : -1];

/*
 * $PchId: inet_config.c,v 1.5 1995/11/21 06:42:38 philip Exp $
 */
