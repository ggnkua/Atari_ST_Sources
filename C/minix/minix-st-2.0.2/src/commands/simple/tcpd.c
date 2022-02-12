/*
tcpd.c
*/

#include <sys/types.h>
#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <signal.h>
#include <minix/config.h>
#include <sys/ioctl.h>
#include <sys/wait.h>
#include <net/gen/in.h>
#include <net/gen/inet.h>
#include <net/gen/netdb.h>
#include <net/gen/tcp.h>
#include <net/gen/tcp_io.h>
#include <net/hton.h>

#if PARANOID
/* -DPARANOID: Log any and all connections.  Requires 8kw stack space. */
#include <time.h>
#include <net/gen/socket.h>
char LOG[] = "/usr/adm/authlog";
#endif

_PROTOTYPE (int main, (int argc, char *argv[]) );

int main(argc, argv)
int argc;
char *argv[];
{
	tcpport_t port;
	struct nwio_tcpcl tcplistenopt;
	struct nwio_tcpconf tcpconf;
	struct servent *servent;
	int result, child, sig;
	int tcp_fd, tmp, count;
	char *arg0, *program, **args;
	int debug= 0, err;
	struct sigaction sa;
#if PARANOID
	int log_fd;
#endif

	arg0= argv[0];
	if (argc > 1 && strcmp(argv[1], "-d") == 0)
	{
		debug= 1;
		argc--;
		argv++;
	}

	if (argc < 3)
	{
		fprintf(stderr,
			"Usage: %s [-d] port program [arg ...]\n", arg0);
		exit(1);
	}

	servent= getservbyname (argv[1], "tcp");
	if (!servent)
	{
		port= htons(strtol (argv[1], (char **)0, 0));
		if (!port)
		{
			fprintf(stderr, "%s: unknown port (%s)\n",
				arg0, argv[1]);
			exit(1);
		}
	}
	else
		port= (tcpport_t)(servent->s_port);

	if (!port)
	{
		fprintf(stderr, "wrong port number (==0)\n");
		exit(1);
	}

	if (debug)
	{
		fprintf (stderr, "%s: listening to port: %u\n",
			arg0, ntohs(port));
	}

	program= argv[2];
	args= argv+2;

	for (;;)
	{
		tcp_fd= open("/dev/tcp", O_RDWR);
		if (tcp_fd<0)
		{
			err= errno;
			perror("unable to open /dev/tcp");
			if (err == ENOENT || err == ENODEV || err == ENXIO)
				exit(1);
			sleep(10);
			continue;
		}

		tcpconf.nwtc_flags= NWTC_LP_SET | NWTC_UNSET_RA | NWTC_UNSET_RP;
		tcpconf.nwtc_locport= port;

		result= ioctl (tcp_fd, NWIOSTCPCONF, &tcpconf);
		if (result<0)
		{
			perror ("unable to NWIOSTCPCONF");
			exit(1);
		}

		tcplistenopt.nwtcl_flags= 0;

		while ((result= ioctl(tcp_fd, NWIOTCPLISTEN, &tcplistenopt))
									== -1)
		{
			if (errno != EAGAIN)
			{
				perror ("unable to NWIOTCPLISTEN");
			}
			else
			{
				if (debug)
				{
					fprintf(stderr,
					"%s: got EAGAIN sleeping 1 second\n",
					arg0);
				}
				sleep(1);
			}
		}

		if (debug)
		{
			result= ioctl (tcp_fd, NWIOGTCPCONF, &tcpconf);
			if (result<0)
			{
				perror ("unable to NWIOGTCPCONF");
				exit(1);
			}
			fprintf(stderr, "connection accepted from %s, %u",
				inet_ntoa(tcpconf.nwtc_remaddr),
				ntohs(tcpconf.nwtc_remport));
			fprintf(stderr," for %s, %u (%s)\n",
				inet_ntoa(tcpconf.nwtc_locaddr),
				ntohs(tcpconf.nwtc_locport), argv[1]);
		}

		child= fork();
		switch (child)
		{
		case -1:
			perror("fork");
			break;
		case 0:
			child= fork();
			if (child<0) perror("fork");
			if (child!=0) exit(0);
#if PARANOID
			if ((log_fd= open(LOG, O_WRONLY | O_APPEND)) != -1)
			{
				static char line[512];
				struct hostent *he;
				time_t t;
				struct tm *tm;
				char month[][4]= {
					"Jan", "Feb", "Mar", "Apr",
					"May", "Jun", "Jul", "Aug",
					"Sep", "Oct", "Nov", "Dec",
				};

				result= ioctl (tcp_fd, NWIOGTCPCONF, &tcpconf);
				if (result<0)
				{
					perror ("unable to NWIOGTCPCONF");
					exit(1);
				}

				time(&t);
				tm= localtime(&t);
				he= gethostbyaddr(
					(char *) &tcpconf.nwtc_remaddr,
					sizeof(tcpconf.nwtc_remaddr), AF_INET);
				sprintf(line,
			"%s %02d %02d:%02d:%02d tcpd: %s connection from %s\n",
					month[tm->tm_mon],
					tm->tm_mday,
					tm->tm_hour, tm->tm_min, tm->tm_sec,
					argv[1],
					he != NULL ? he->h_name :
					    inet_ntoa(tcpconf.nwtc_remaddr));
				(void) write(log_fd, line, strlen(line));
				close(log_fd);
				if (debug)
					(void) write(2, line, strlen(line));
			}
#endif
			sigemptyset(&sa.sa_mask);
			sa.sa_flags = 0;
			sa.sa_handler = SIG_DFL;
			for (sig = 1; sig <= _NSIG; sig++)
				sigaction(sig, &sa, NULL);
			dup2(tcp_fd, 0);
			dup2(tcp_fd, 1);
			close(tcp_fd);
			execv(program, args);
			printf("Unable to exec %s\n", program);
			fflush(stdout);
			_exit(1);
		default:
			close(tcp_fd);
			wait(&child);
			break;
		}
	}
}
