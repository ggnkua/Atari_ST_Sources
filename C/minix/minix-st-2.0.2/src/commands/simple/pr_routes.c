/*
vmd/cmd/simple/pr_routes.c
*/

#include <sys/types.h>
#include <sys/ioctl.h>
#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <net/netlib.h>
#include <net/gen/in.h>
#include <net/gen/ip_io.h>
#include <net/gen/route.h>
#include <net/gen/netdb.h>
#include <net/gen/inet.h>

char *prog_name;
int all_devices;

static void print_header(void);
static void print_route(nwio_route_t *route);
static void usage(void);

int main(int argc, char *argv[])
{
	int nr_routes, i;
	nwio_route_t route;
	nwio_ipconf_t ip_conf;
	unsigned long ioctl_cmd;
	int ip_fd;
	int result;
	int c;
	char *ip_device;
	int a_flag, i_flag, o_flag;
	char *I_arg;

	prog_name= argv[0];

	a_flag= 0;
	i_flag= 0;
	o_flag= 0;
	I_arg= NULL;
	while ((c =getopt(argc, argv, "?aI:io")) != -1)
	{
		switch(c)
		{
		case '?':
			usage();
		case 'a':
			if (a_flag)
				usage();
			a_flag= 1;
			break;
		case 'I':
			if (I_arg)
				usage();
			I_arg= optarg;
			break;
		case 'i':
			if (i_flag || o_flag)
				usage();
			i_flag= 1;
			break;
		case 'o':
			if (i_flag || o_flag)
				usage();
			o_flag= 1;
			break;
		default:
			fprintf(stderr, "%s: getopt failed: '%c'\n",
				prog_name, c);
			exit(1);
		}
	}
	if (optind != argc)
		usage();

	ip_device= I_arg;
	all_devices= a_flag;

	if (i_flag)
		ioctl_cmd= NWIOGIPIROUTE;
	else
		ioctl_cmd= NWIOGIPOROUTE;

	if (ip_device == NULL)
		ip_device= getenv("IP_DEVICE");
	if (ip_device == NULL)
		ip_device= IP_DEVICE;
		
	ip_fd= open(ip_device, O_RDWR);
	if (ip_fd == -1)
	{
		fprintf(stderr, "%s: unable to open %s: %s\n", prog_name,
			ip_device, strerror(errno));
		exit(1);
	}

	result= ioctl(ip_fd, NWIOGIPCONF, &ip_conf);
	if (result == -1)
	{
		fprintf(stderr, "%s: unable to NWIOIPGCONF: %s\n",
			prog_name, strerror(errno));
		exit(1);
	}

	route.nwr_ent_no= 0;
	result= ioctl(ip_fd, ioctl_cmd, &route);
	if (result == -1)
	{
		fprintf(stderr, "%s: unable to NWIOGIPxROUTE: %s\n",
			prog_name, strerror(errno));
		exit(1);
	}
	print_header();
	nr_routes= route.nwr_ent_count;
	for (i= 0; i<nr_routes; i++)
	{
		route.nwr_ent_no= i;
		result= ioctl(ip_fd, ioctl_cmd, &route);
		if (result == -1)
		{
			fprintf(stderr, "%s: unable to NWIOGIPxROUTE: %s\n",
				prog_name, strerror(errno));
			exit(1);
		}
		if (all_devices || route.nwr_ifaddr == ip_conf.nwic_ipaddr)
			print_route(&route);
	}
	exit(0);
}

int ent_width= 5;
int if_width= 15;
int dest_width= 15;
int netmask_width= 15;
int gateway_width= 15;
int dist_width= 4;
int pref_width= 4;

static void print_header(void)
{
	printf("%*s ", ent_width, "ent #");
	printf("%*s ", dest_width, "dest");
	printf("%*s ", netmask_width, "netmask");
	printf("%*s ", gateway_width, "gateway");
	printf("%*s ", dist_width, "dist");
	printf("%*s ", pref_width, "pref");
	printf("%s", "flags");
	printf("\n");
	if (all_devices)
		printf("%*s %*s\n", ent_width, "", if_width, "if");
}


static void print_route(nwio_route_t *route)
{
	if (!(route->nwr_flags & NWRF_INUSE))
		return;

	printf("%*d ", ent_width, route->nwr_ent_no);
	printf("%*s ", dest_width, inet_ntoa(route->nwr_dest));
	printf("%*s ", netmask_width, inet_ntoa(route->nwr_netmask));
	printf("%*s ", gateway_width, inet_ntoa(route->nwr_gateway));
	printf("%*d ", dist_width, route->nwr_dist);
	printf("%*d", pref_width, route->nwr_pref);
	if (route->nwr_flags & NWRF_STATIC)
		printf(" static");
	if (route->nwr_flags & NWRF_UNREACHABLE)
		printf(" dead");
	printf("\n");
	if (all_devices)
	{
		printf("%*s %*s\n", ent_width, "", 
			if_width, inet_ntoa(route->nwr_ifaddr));
	}
}

static void usage(void)
{
	fprintf(stderr, "Usage: %s [-i|-o] [ -a ] [ -I <ip-device> ]\n",
		prog_name);
	exit(1);
}
