/*
hostaddr.c

Fetch an ip and/or ethernet address and print it on one line.

Created:	Jan 27, 1992 by Philip Homburg
*/

#include <sys/types.h>
#include <sys/ioctl.h>
#include <errno.h>
#include <fcntl.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <net/netlib.h>
#include <net/hton.h>
#include <net/gen/ether.h>
#include <net/gen/eth_io.h>
#include <net/gen/if_ether.h>
#include <net/gen/in.h>
#include <net/gen/inet.h>
#include <net/gen/ip_io.h>
#include <net/gen/netdb.h>
#include <net/gen/socket.h>
#include <net/gen/nameser.h>
#include <net/gen/resolv.h>

char *prog_name;

void main _ARGS(( int argc, char *argv[] ));
void usage _ARGS(( void ));
void dummy_handler _ARGS(( int sig ));

void main(argc, argv)
int argc;
char *argv[];
{
	int c;
	int first_print;
	int a_flag, e_flag, i_flag;
	char *E_arg, *I_arg;
	int do_ether, do_ip, do_asc_ip;
	char *eth_device, *ip_device;
	int eth_fd, ip_fd;
	int result;
	nwio_ethstat_t nwio_ethstat;
	nwio_ipconf_t nwio_ipconf;
	struct hostent *hostent;

	first_print= 1;
	prog_name= argv[0];

	a_flag= e_flag= i_flag= 0;
	E_arg= I_arg= NULL;

	while((c= getopt(argc, argv, "?aeE:iI:")) != -1)
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
		case 'e':
			if (e_flag)
				usage();
			e_flag= 1;
			break;
		case 'E':
			if (E_arg)
				usage();
			E_arg= optarg;
			break;
		case 'i':
			if (i_flag)
				usage();
			i_flag= 1;
			break;
		case 'I':
			if (I_arg)
				usage();
			I_arg= optarg;
			break;
		default:
			fprintf(stderr, "%s: getopt failure: '%c'\n",
				prog_name, c);
			exit(1);
		}
	}
	if(optind != argc)
		usage();

	do_ether= e_flag;
	if (E_arg)
		eth_device= E_arg;
	else
	{
		eth_device= getenv("ETH_DEVICE");
		if (!eth_device)
			eth_device= ETH_DEVICE;
	}

	do_ip= i_flag;
	do_asc_ip= a_flag;
	if (I_arg)
		ip_device= I_arg;
	else
	{
		ip_device= getenv("IP_DEVICE");
		if (!ip_device)
			ip_device= IP_DEVICE;
	}

	if (!do_ether && !do_ip && !do_asc_ip)
		do_ether= do_ip= do_asc_ip= 1;

	if (do_ether)
	{
		eth_fd= open(eth_device, O_RDWR);
		if (eth_fd == -1)
		{
			fprintf(stderr, "%s: unable to open '%s': %s\n",
				prog_name, eth_device, strerror(errno));
			exit(1);
		}
		result= ioctl(eth_fd, NWIOGETHSTAT, &nwio_ethstat);
		if (result == -1)
		{
			fprintf(stderr, 
			"%s: unable to fetch ethernet address: %s\n",
				prog_name, strerror(errno));
			exit(1);
		}
		printf("%s%s", first_print ? "" : " ",
					ether_ntoa(&nwio_ethstat.nwes_addr));
		first_print= 0;
	}
	if (do_ip || do_asc_ip)
	{
		ip_fd= open(ip_device, O_RDWR);
		if (ip_fd == -1)
		{
			fprintf(stderr, "%s: unable to open '%s': %s\n",
				prog_name, ip_device, strerror(errno));
			exit(1);
		}
		signal(SIGALRM, dummy_handler);
		alarm(25);
		result= ioctl(ip_fd, NWIOGIPCONF, &nwio_ipconf);
		if (result == -1)
		{
			fprintf(stderr, 
				"%s: unable to fetch IP address: %s\n",
				prog_name,
				errno == EINTR ? "Timeout" : strerror(errno));
			exit(1);
		}
		alarm(0);
	}
	if (do_ip)
	{
		printf("%s%s", first_print ? "" : " ",
					inet_ntoa(nwio_ipconf.nwic_ipaddr));
		first_print= 0;
	}
	if (do_asc_ip)
	{
		res_init();
		if ((ntohl(_res.nsaddr_list[0]) & 0x7F000000L) == 0x7F000000L
			&& _res.nscount == 1)
		{
			/* At boot time the name daemon is just starting up,
			 * so our first request may get lost.  A short retry
			 * timeout makes it less noticable.
			 */
			_res.retrans= 1;
			_res.retry= 5;
		}
		hostent= gethostbyaddr((char *)&nwio_ipconf.nwic_ipaddr,
			sizeof(nwio_ipconf.nwic_ipaddr), AF_INET);
		printf("%s%s", first_print ? "" : " ", hostent ?
			hostent->h_name : inet_ntoa(nwio_ipconf.nwic_ipaddr));
		first_print= 0;
	}
	printf("\n");
	exit(0);
}

void usage()
{
	fprintf(stderr, "Usage: %s -[eia] [-E <eth-device>] [-I <ip-device>]\n", 
								prog_name);
	exit(1);
}

void dummy_handler(sig)
int sig;
{
	/* Do nothing. */
}
