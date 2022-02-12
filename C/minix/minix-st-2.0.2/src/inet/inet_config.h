/*
inet/inet_config.h

Created:	Nov 11, 1992 by Philip Homburg

Defines values for configurable parameters. The structure definitions for
configuration information are also here.

Copyright 1995 Philip Homburg
*/

#ifndef INET__INET_CONFIG_H
#define INET__INET_CONFIG_H

#define	ENABLE_ETH	0
#define ENABLE_ARP	0
#define ENABLE_IP	1
#define ENABLE_PSIP	1
#define ENABLE_TCP	1
#define ENABLE_UDP	1

#define ETH_PORT_NR	2	/* 2 ethernet devices */
#define ARP_PORT_NR	2
#define PSIP_PORT_NR	(2 * ENABLE_PSIP)
#define IP_PORT_NR	(ETH_PORT_NR + PSIP_PORT_NR)
#define TCP_PORT_NR	(ETH_PORT_NR + PSIP_PORT_NR)
#define UDP_PORT_NR	(ETH_PORT_NR + PSIP_PORT_NR)

struct eth_conf
{
	int ec_minor;		/* Which minor should be used for registering
				 * this device */
	int ec_port;		/* Port number for that task */
};
extern struct eth_conf eth_conf[];

struct arp_conf
{
	int ac_port;		/* ethernet port number */
};
extern struct arp_conf arp_conf[];

struct psip_conf
{
	int pc_minor;		/* Minor device to be used for registering
				 * this device */
};
extern struct psip_conf psip_conf[];

struct ip_conf
{
	int ic_minor;		/* Minor device to be used for registering
				 * this device */
	int ic_devtype;		/* underlying device type */
	int ic_port;		/* port of underlying device */
};
extern struct ip_conf ip_conf[];

struct tcp_conf
{
	int tc_minor;		/* Which minor should be used for registering
				 * this device */
	int tc_port;		/* IP port number */
};
extern struct tcp_conf tcp_conf[];

struct udp_conf
{
	int uc_minor;		/* Which minor should be used for registering
				 * this device */
	int uc_port;		/* IP port number */
};
extern struct udp_conf udp_conf[];

#endif /* INET__INET_CONFIG_H */

/*
 * $PchId: inet_config.h,v 1.5 1995/11/21 06:42:18 philip Exp $
 */
