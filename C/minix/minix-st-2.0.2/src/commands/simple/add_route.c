/*
add_route.c

Created August 7, 1991 by Philip Homburg
*/

#ifndef _POSIX2_SOURCE
#define _POSIX2_SOURCE	1
#endif

#include <sys/types.h>
#include <sys/ioctl.h>
#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <net/hton.h>
#include <net/netlib.h>
#include <net/gen/netdb.h>
#include <net/gen/in.h>
#include <net/gen/inet.h>
#include <net/gen/route.h>
#include <net/gen/ip_io.h>

char *prog_name;

void main _ARGS(( int argc, char *argv[] ));
void usage _ARGS(( void ));

void main(argc, argv)
int argc;
char *argv[];
{
	struct hostent *hostent;
	struct netent *netent;
	ipaddr_t gateway, destination, netmask;
	u8_t high_byte;
	nwio_route_t route;
	int ip_fd, itab;
	int r;
	int metric;
	char *check;
	char *ip_device;
	char *netmask_str, *metric_str, *destination_str, *gateway_str;
	int c;
	char *d_arg, *g_arg, *m_arg, *n_arg, *I_arg;
	int i_flag, o_flag, v_flag;

	prog_name= argv[0];

	i_flag= 0;
	o_flag= 0;
	v_flag= 0;
	g_arg= NULL;
	d_arg= NULL;
	m_arg= NULL;
	n_arg= NULL;
	I_arg= NULL;
	while ((c= getopt(argc, argv, "iovg:d:m:n:I:?")) != -1)
	{
		switch(c)
		{
		case 'i':
			if (i_flag)
				usage();
			i_flag= 1;
			break;
		case 'o':
			if (o_flag)
				usage();
			o_flag= 1;
			break;
		case 'v':
			if (v_flag)
				usage();
			v_flag= 1;
			break;
		case 'g':
			if (g_arg)
				usage();
			g_arg= optarg;
			break;
		case 'd':
			if (d_arg)
				usage();
			d_arg= optarg;
			break;
		case 'm':
			if (m_arg)
				usage();
			m_arg= optarg;
			break;
		case 'n':
			if (n_arg)
				usage();
			n_arg= optarg;
			break;
		case 'I':
			if (I_arg)
				usage();
			I_arg= optarg;
			break;
		case '?':
			usage();
		default:
			fprintf(stderr, "%s: getopt failed\n", prog_name);
			exit(1);
		}
	}
	if (optind != argc)
		usage();
	if (i_flag && o_flag)
		usage();
	itab= i_flag;

	if (i_flag)
	{
		if (g_arg == NULL || d_arg == NULL || m_arg == NULL)
			usage();
	}
	else
	{
		if (g_arg == NULL || (d_arg == NULL && n_arg != NULL) ||
			m_arg != NULL)
		{
			usage();
		}
	}
		
	gateway_str= g_arg;
	destination_str= d_arg;
	metric_str= m_arg;
	netmask_str= n_arg;
	ip_device= I_arg;

	hostent= gethostbyname(gateway_str);
	if (!hostent)
	{
		fprintf(stderr, "%s: unknown host '%s'\n", prog_name,
								gateway_str);
		exit(1);
	}
	gateway= *(ipaddr_t *)(hostent->h_addr);

	destination= 0;
	netmask= 0;

	if (destination_str)
	{
		if ((netent= getnetbyname(destination_str)) != NULL)
			destination= netent->n_net;
		else if ((hostent= gethostbyname(destination_str)) != NULL)
			destination= *(ipaddr_t *)(hostent->h_addr);
		else
		{
			fprintf(stderr, "%s: unknown network/host '%s'\n",
				prog_name, destination_str);
			exit(1);
		}
		high_byte= *(u8_t *)&destination;
		if (!(high_byte & 0x80))	/* class A or 0 */
		{
			if (destination)
				netmask= HTONL(0xff000000);
		}
		else if (!(high_byte & 0x40))	/* class B */
		{
			netmask= HTONL(0xffff0000);
		}
		else if (!(high_byte & 0x20))	/* class C */
		{
			netmask= HTONL(0xffffff00);
		}
		else				/* class D is multicast ... */
		{
			fprintf(stderr, "%s: warning martian address '%s'\n",
				prog_name, inet_ntoa(destination));
			netmask= HTONL(0xffffffff);
		}
		if (destination & ~netmask)
		{
			/* host route */
			netmask= HTONL(0xffffffff);
		}
	}

	if (netmask_str)
	{
		if (inet_aton(netmask_str, &netmask) == 0)
		{
			fprintf(stderr, "%s: illegal netmask'%s'\n", prog_name,
				netmask_str);
			exit(1);
		}
	}

	if (metric_str)
	{
		metric= strtol(metric_str, &check, 0);
		if (check[0] != '\0' || metric < 1)
		{
			fprintf(stderr, "%s: illegal metric %s\n",
				prog_name, metric_str);
		}
	}
	else
		metric= 1;
		
	if (!ip_device)
		ip_device= getenv("IP_DEVICE");
	if (!ip_device)
		ip_device= IP_DEVICE;

	ip_fd= open(ip_device, O_RDWR);
	if (ip_fd == -1)
	{
		fprintf(stderr, "%s: unable to open('%s'): %s\n",
			prog_name, ip_device, strerror(errno));
		exit(1);
	}

	if (v_flag)
	{
		printf("adding %s route to %s ", itab ? "input" : "output",
			inet_ntoa(destination));
		printf("with netmask %s ", inet_ntoa(netmask));
		printf("using gateway %s", inet_ntoa(gateway));
		if (itab)
			printf(" at distance %d", metric);
		printf("\n");
	}

	route.nwr_dest= destination;
	route.nwr_netmask= netmask;
	route.nwr_gateway= gateway;
	route.nwr_dist= metric;
	route.nwr_flags= NWRF_STATIC;

	if (itab)
		r= ioctl(ip_fd, NWIOSIPIROUTE, &route);
	else
		r= ioctl(ip_fd, NWIOSIPOROUTE, &route);
	if (r == -1)
	{
		fprintf(stderr, "%s: NWIOSIPxROUTE: %s\n",
			prog_name, strerror(errno));
		exit(1);
	}
	exit(0);
}

void usage()
{
	fprintf(stderr, "Usage: %s\n", prog_name);
	fprintf(stderr,
"\t[-o] -g <gw> [-d <dst> [-n <netmask> ]] [-m metric] [-I <ipdev>] [-v]\n");
	fprintf(stderr,
"\t-i -g <gw> -d <dst> -m metric [-n <netmask>] [-I <ipdev>] [-v]\n");
	exit(1);
}
