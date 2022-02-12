/*
ifconfig.c
*/

#include <sys/types.h>
#include <assert.h>
#include <errno.h>
#include <fcntl.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <net/gen/in.h>
#include <net/gen/ip_io.h>
#include <net/gen/inet.h>

#if __STDC__
#define PROTO(x,y) x y
#else
#define PROTO(x,y) x()
#endif

static PROTO (void usage, (void) );
static PROTO (void set_hostaddr, (int ip_fd, char *host_s, int ins) );
static PROTO (void set_netmask, (int ip_fd, char *net_s, int ins) );
static PROTO (int check_ipaddrset, (int ip_fd) );
static PROTO (int check_netmaskset, (int ip_fd) );
static PROTO (int get_ipconf, (int ip_fd,
	struct nwio_ipconf *ref_ipconf) );
static PROTO (void sig_hand, (int signal) );
PROTO (int main, (int argc, char *argv[]) );

#define DEV_IP "/dev/ip"
#define GET_IPCONF_TO 10
char *prog_name;

main(argc, argv)
int argc;
char *argv[];
{
	char *device_s, *hostaddr_s, *netmask_s, **arg_s;
	int ins;
	int c, ip_fd;
	struct nwio_ipconf ipconf;
	int i_flag, v_flag;
	char *d_arg, *h_arg, *n_arg;

	prog_name= argv[0];

	d_arg= NULL;
	h_arg= NULL;
	n_arg= NULL;
	i_flag= 0;
	v_flag= 0;
	while ((c= getopt(argc, argv, "?I:h:n:iv")) != -1)
	{
		switch(c)
		{
		case '?':
			usage();
		case 'I':
			if (d_arg)
				usage();
			d_arg= optarg;
			break;
		case 'h':
			if (h_arg)
				usage();
			h_arg= optarg;
			break;
		case 'n':
			if (n_arg)
				usage();
			n_arg= optarg;
			break;
		case 'i':
			if (i_flag)
				usage();
			i_flag= 1;
			break;
		case 'v':
			if (v_flag)
				usage();
			v_flag= 1;
			break;
		default:
			fprintf(stderr, "%s: getopt failed: '%c'\n", 
				prog_name, c);
			exit(1);
		}
	}
	if (h_arg == NULL && n_arg == NULL) v_flag= 1;

	if (optind != argc)
		usage();

	device_s= d_arg;
	if (device_s == NULL)
		device_s= getenv("IP_DEVICE");
	if (device_s == NULL)
		device_s= DEV_IP;

	hostaddr_s= h_arg;
	netmask_s= n_arg;
	ins= i_flag;

	ip_fd= open (device_s, O_RDWR);
	if (ip_fd<0)
	{
		fprintf(stderr, "%s: unable to open '%s': %s\n", 
			prog_name, device_s, strerror(errno));
		exit(1);
	}

	if (hostaddr_s)
		set_hostaddr(ip_fd, hostaddr_s, ins);

	if (netmask_s)
		set_netmask (ip_fd, netmask_s, ins);

	if (v_flag) {
		if (!get_ipconf(ip_fd, &ipconf))
		{
			fprintf(stderr, "host address not set\n");
			exit(1);
		}
		puts(inet_ntoa(ipconf.nwic_ipaddr));
		if (ipconf.nwic_flags & NWIC_NETMASK_SET)
			puts(inet_ntoa(ipconf.nwic_netmask));
	}
	exit(0);
}

static void set_hostaddr (ip_fd, hostaddr_s, ins)
int ip_fd;
char *hostaddr_s;
int ins;
{
	ipaddr_t ipaddr;
	struct nwio_ipconf ipconf;
	int result;

	ipaddr= inet_addr (hostaddr_s);
	if (ipaddr == (ipaddr_t)(-1))
	{
		fprintf(stderr, "%s: invalid host address (%s)\n",
			prog_name, hostaddr_s);
		exit(1);
	}
	if (ins && check_ipaddrset(ip_fd))
		return;

	ipconf.nwic_flags= NWIC_IPADDR_SET;
	ipconf.nwic_ipaddr= ipaddr;

	result= ioctl(ip_fd, NWIOSIPCONF, &ipconf);
	if (result<0)
	{
		perror("unable to ioctl(.., NWIOSIPCONF, ..)");
		exit(1);
	}
}

static int check_ipaddrset (ip_fd)
int ip_fd;
{
	struct nwio_ipconf ipconf;

	if (!get_ipconf(ip_fd, &ipconf))
		return 0;

assert (ipconf.nwic_flags & NWIC_IPADDR_SET);

	return 1;
}

static int get_ipconf (ip_fd, ref_ipaddr)
int ip_fd;
struct nwio_ipconf *ref_ipaddr;
{
	void PROTO ((*old_sighand), (int) );
	int old_alarm;
	int error, result;

	old_sighand= signal (SIGALRM, sig_hand);
	old_alarm= alarm (GET_IPCONF_TO);

	result= ioctl (ip_fd, NWIOGIPCONF, ref_ipaddr);
	error= errno;

	alarm(0);
	signal(SIGALRM, old_sighand);
	alarm(old_alarm);

	if (result <0 && error != EINTR)
	{
		errno= error;
		perror ("ioctl (.., NWIOGIPCONF, ..)");
		exit(1);
	}
	return result>=0;
}

static void sig_hand(signal)
int signal;
{
	/* No nothing, just cause an EINTR */
}

static void usage()
{
	fprintf(stderr,
		"Usage: %s [-I ip-device] [-h ipaddr] [-n netmask] [-iv]\n",
		prog_name);
	exit(1);
}

static void set_netmask (ip_fd, netmask_s, ins)
int ip_fd;
char *netmask_s;
int ins;
{
	ipaddr_t netmask;
	struct nwio_ipconf ipconf;
	int result;

	netmask= inet_addr (netmask_s);
	if (netmask == (ipaddr_t)(-1))
	{
		fprintf(stderr, "%s: invalid netmask (%s)\n",
			prog_name, netmask_s);
		exit(1);
	}
	if (ins && check_netmaskset(ip_fd))
		return;

	ipconf.nwic_flags= NWIC_NETMASK_SET;
	ipconf.nwic_netmask= netmask;

	result= ioctl(ip_fd, NWIOSIPCONF, &ipconf);
	if (result<0)
	{
		perror("unable to ioctl(.., NWIOSIPCONF, ..)");
		exit(1);
	}
}

static int check_netmaskset (ip_fd)
int ip_fd;
{
	struct nwio_ipconf ipconf;

	if (!get_ipconf(ip_fd, &ipconf))
	{
		fprintf(stderr, "unable to determine whether netmask set or not, please set host addr first\n");
		exit(1);
	}

	return (ipconf.nwic_flags & NWIC_NETMASK_SET);
}
