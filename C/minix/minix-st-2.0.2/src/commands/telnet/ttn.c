/*
ttn.c
*/

#ifndef _POSIX_SOURCE
#define _POSIX_SOURCE 1
#endif

#include <sys/types.h>
#include <sys/ioctl.h>
#include <assert.h>
#include <errno.h>
#include <fcntl.h>
#include <termios.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <net/hton.h>
#include <net/netlib.h>
#include <net/gen/in.h>
#include <net/gen/inet.h>
#include <net/gen/netdb.h>
#include <net/gen/tcp.h>
#include <net/gen/tcp_io.h>
#include "ttn.h"

#if __STDC__
#define PROTOTYPE(func,args) func args
#else
#define PROTOTYPE(func,args) func()
#endif

PROTOTYPE (int main, (int argc, char *argv[]) );
static int do_read(int fd, char *buf, unsigned len);
static void screen(void);
static void keyboard (void);
static int process_opt (char *bp, int count);
static void do_option (int optsrt);
static void dont_option (int optsrt);
static void will_option (int optsrt);
static void wont_option (int optsrt);
static int writeall (int fd, char *buffer, int buf_size);
static int sb_termtype (char *sb, int count);

#if DEBUG
#define where() (fprintf(stderr, "%s %d:", __FILE__, __LINE__))
#endif

static char *prog_name;
static tcp_fd;
static char *term_env;

main(argc, argv)
int argc;
char *argv[];
{
	struct hostent *hostent;
	struct servent *servent;
	ipaddr_t host;
	tcpport_t port;
	int pid, ppid;
	nwio_tcpconf_t tcpconf;
	int result, count;
	nwio_tcpcl_t tcpconnopt;
	char buffer[1024];
	struct termios termios;
	char *tcp_device;

	prog_name= argv[0];
	if (argc <2 || argc>3)
	{
		fprintf(stderr, "Usage: %s host <port>\r\n", argv[0]);
		exit(1);
	}
	hostent= gethostbyname(argv[1]);
	if (!hostent)
	{
		host= inet_addr(argv[1]);
		if (host == -1)
		{
			fprintf(stderr, "%s: unknown host (%s)\r\n",
				argv[0], argv[1]);
			exit(1);
		}
	}
	else
		host= *(ipaddr_t *)(hostent->h_addr);

	if (argc < 3)
		port= htons(TCPPORT_TELNET);
	else
	{
		servent= getservbyname (argv[2], "tcp");
		if (!servent)
		{
			port= htons(strtol (argv[2], (char **)0, 0));
			if (!port)
			{
				fprintf(stderr, "%s: unknown port (%s)\r\n",
					argv[0], argv[2]);
				exit(1);
			}
		}
		else
			port= (tcpport_t)(servent->s_port);
	}

	printf("connecting to %s %u\r\n", inet_ntoa(host), ntohs(port));

	tcp_device= getenv("TCP_DEVICE");
	if (tcp_device == NULL)
		tcp_device= TCP_DEVICE;
	tcp_fd= open (tcp_device, O_RDWR);
	if (tcp_fd<0)
	{
		perror ("unable to open /dev/tcp");
		exit(1);
	}
	tcpconf.nwtc_flags= NWTC_LP_SEL | NWTC_SET_RA | NWTC_SET_RP;
	tcpconf.nwtc_remaddr= host;
	tcpconf.nwtc_remport= port;

	result= ioctl (tcp_fd, NWIOSTCPCONF, &tcpconf);
	if (result<0)
	{
		perror ("unable to NWIOSTCPCONF");
		exit(1);
	}

	tcpconnopt.nwtcl_flags= 0;

	do
	{
		result= ioctl (tcp_fd, NWIOTCPCONN, &tcpconnopt);
		if (result < 0 && errno == EAGAIN)
		{
			fprintf(stderr,"%s: got EAGAIN, sleeping(1s)\r\n",
				prog_name);
			sleep(1);
		}
	} while (result <0 && errno == EAGAIN);
	if (result<0)
	{
		perror ("unable to NWIOTCPCONN");
		exit(1);
	}
	printf("Connected\r\n");
	ppid= getpid();
	pid= fork();
	switch(pid)
	{
	case 0:
		keyboard();
#if DEBUG
fprintf(stderr, "killing %d with %d\r\n", ppid, SIGKILL);
#endif
		kill(ppid, SIGKILL);
		break;
	case -1:
		fprintf(stderr, "%s: fork failed: %s\r\n", argv[0],
			strerror(errno));
		exit(1);
		break;
	default:
		tcgetattr(0, &termios);
		screen();
#if DEBUG
fprintf(stderr, "killing %d with %d\r\n", pid, SIGKILL);
#endif
		kill(pid, SIGKILL);
		tcsetattr(0, TCSANOW, &termios);
		break;
	}
}

static int do_read(fd, buf, len)
int fd;
char *buf;
unsigned len;
{
#if __minix_vmd
	nwio_tcpopt_t tcpopt;
	int count;

	for (;;)
	{
		count= read (fd, buf, len);
		if (count <0)
		{
			if (errno == EURG || errno == ENOURG)
			{
				/* Toggle urgent mode. */
				tcpopt.nwto_flags= errno == EURG ?
					NWTO_RCV_URG : NWTO_RCV_NOTURG;
				if (ioctl(tcp_fd, NWIOSTCPOPT, &tcpopt) == -1)
				{
					return -1;
				}
				continue;
			}
			return -1;
		}
		return count;
	}
#else
	return read(fd, buf, len);
#endif
}

static void screen()
{
	char buffer[1024], *bp, *iacptr;
	int count, optsize;

	for (;;)
	{
		count= do_read (tcp_fd, buffer, sizeof(buffer));
#if DEBUG && 0
 { where(); fprintf(stderr, "read %d bytes\r\n", count); }
#endif
		if (count <0)
		{
			perror ("read");
			return;
		}
		if (!count)
			return;
		bp= buffer;
		do
		{
			iacptr= memchr (bp, IAC, count);
			if (!iacptr)
			{
				write(1, bp, count);
				count= 0;
			}
			if (iacptr && iacptr>bp)
			{
#if DEBUG 
 { where(); fprintf(stderr, "iacptr-bp= %d\r\n", iacptr-bp); }
#endif
				write(1, bp, iacptr-bp);
				count -= (iacptr-bp);
				bp= iacptr;
				continue;
			}
			if (iacptr)
			{
assert (iacptr == bp);
				optsize= process_opt(bp, count);
#if DEBUG && 0
 { where(); fprintf(stderr, "process_opt(...)= %d\r\n", optsize); }
#endif
				if (optsize<0)
					return;
assert (optsize);
				bp += optsize;
				count -= optsize;
			}
		} while (count);
	}
}

static void keyboard()
{
	nwio_tcpatt_t nwio_tcpatt;
	char buffer[1024];
	int result;
	int count;

	nwio_tcpatt.nwta_flags= 0;

	for (;;)
	{
		count= read (0, buffer, sizeof(buffer));
		if (count<0)
		{
			fprintf(stderr, "%s: read: %s\r\n", prog_name,
			strerror(errno));
			return;
		}
		if (!count)
			return;
#if DEBUG && 0
 { where(); fprintf(stderr, "writing %d bytes\r\n", count); }
#endif
		count= write(tcp_fd, buffer, count);
#if 0
		if (buffer[0] == '\r')
			write(tcp_fd, "\n", 1);
#endif
		if (count<0)
		{
			perror("write");
			return;
		}
		if (!count)
			return;
	}
}

#define next_char(var) \
	if (offset<count) { (var) = bp[offset++]; } \
	else if (do_read(tcp_fd, (char *)&(var), 1) <= 0) \
	{ perror ("read"); return -1; }

static int process_opt (char *bp, int count)
{
	unsigned char iac, command, optsrt, sb_command;
	int offset, result;	;
#if DEBUG && 0
 { where(); fprintf(stderr, "process_opt(bp= 0x%x, count= %d)\r\n",
	bp, count); }
#endif

	offset= 0;
assert (count);
	next_char(iac);
assert (iac == IAC);
	next_char(command);
	switch(command)
	{
	case IAC_NOP:
		break;
	case IAC_DataMark:
fprintf(stderr, "got a DataMark\r\n");
		break;
	case IAC_BRK:
fprintf(stderr, "got a BRK\r\n");
		break;
	case IAC_IP:
fprintf(stderr, "got a IP\r\n");
		break;
	case IAC_AO:
fprintf(stderr, "got a AO\r\n");
		break;
	case IAC_AYT:
fprintf(stderr, "got a AYT\r\n");
		break;
	case IAC_EC:
fprintf(stderr, "got a EC\r\n");
		break;
	case IAC_EL:
fprintf(stderr, "got a EL\r\n");
		break;
	case IAC_GA:
fprintf(stderr, "got a GA\r\n");
		break;
	case IAC_SB:
		next_char(sb_command);
		switch (sb_command)
		{
		case OPT_TERMTYPE:
#if DEBUG && 0
fprintf(stderr, "got SB TERMINAL-TYPE\r\n");
#endif
			result= sb_termtype(bp+offset, count-offset);
			if (result<0)
				return result;
			else
				return result+offset;
		default:
fprintf(stderr, "got an unknown SB (skiping)\r\n");
			for (;;)
			{
				next_char(iac);
				if (iac != IAC)
					continue;
				next_char(optsrt);
				if (optsrt == IAC)
					continue;
if (optsrt != IAC_SE)
	fprintf(stderr, "got IAC %d\r\n", optsrt);
				break;
			}
		}
		break;
	case IAC_WILL:
		next_char(optsrt);
		will_option(optsrt);
		break;
	case IAC_WONT:
		next_char(optsrt);
		wont_option(optsrt);
		break;
	case IAC_DO:
		next_char(optsrt);
		do_option(optsrt);
		break;
	case IAC_DONT:
		next_char(optsrt);
		dont_option(optsrt);
		break;
	case IAC:
fprintf(stderr, "got a IAC\r\n");
		break;
	default:
fprintf(stderr, "got unknown command (%d)\r\n", command);
	}
	return offset;
}

static void do_option (int optsrt)
{
	unsigned char reply[3], *rp;
	int count, result;

	switch (optsrt)
	{
	case OPT_TERMTYPE:
		if (WILL_terminal_type)
			return;
		if (!WILL_terminal_type_allowed)
		{
			reply[0]= IAC;
			reply[1]= IAC_WONT;
			reply[2]= optsrt;
		}
		else
		{
			WILL_terminal_type= TRUE;
			term_env= getenv("TERM");
			if (!term_env)
				term_env= "unknown";
			reply[0]= IAC;
			reply[1]= IAC_WILL;
			reply[2]= optsrt;
		}
		break;
	default:
#if DEBUG
 { where(); fprintf(stderr, "got a DO (%d)\r\n", optsrt); }
#endif
#if DEBUG
 { where(); fprintf(stderr, "WONT (%d)\r\n", optsrt); }
#endif
		reply[0]= IAC;
		reply[1]= IAC_WONT;
		reply[2]= optsrt;
		break;
	}
	result= writeall(tcp_fd, (char *)reply, 3);
	if (result<0)
		perror("write");
}

static void will_option (int optsrt)
{
	unsigned char reply[3], *rp;
	int count, result;

	switch (optsrt)
	{
	case OPT_ECHO:
		if (DO_echo)
			break;
		if (!DO_echo_allowed)
		{
			reply[0]= IAC;
			reply[1]= IAC_DONT;
			reply[2]= optsrt;
		}
		else
		{
			struct termios termios;
			tcgetattr(0, &termios);
			termios.c_iflag &= ~(ICRNL|IGNCR|INLCR|IXON|IXOFF);
			termios.c_oflag &= ~(OPOST);
			termios.c_lflag &= ~(ECHO|ECHONL|ICANON|IEXTEN|ISIG);
			tcsetattr(0, TCSANOW, &termios);
			DO_echo= TRUE;
			reply[0]= IAC;
			reply[1]= IAC_DO;
			reply[2]= optsrt;
		}
		result= writeall(tcp_fd, (char *)reply, 3);
		if (result<0)
			perror("write");
		break;
	case OPT_SUPP_GA:
		if (DO_suppress_go_ahead)
			break;
		if (!DO_suppress_go_ahead_allowed)
		{
			reply[0]= IAC;
			reply[1]= IAC_DONT;
			reply[2]= optsrt;
		}
		else
		{
			DO_suppress_go_ahead= TRUE;
			reply[0]= IAC;
			reply[1]= IAC_DO;
			reply[2]= optsrt;
		}
		result= writeall(tcp_fd, (char *)reply, 3);
		if (result<0)
			perror("write");
		break;
	default:
#if DEBUG
 { where(); fprintf(stderr, "got a WILL (%d)\r\n", optsrt); }
#endif
#if DEBUG
 { where(); fprintf(stderr, "DONT (%d)\r\n", optsrt); }
#endif
		reply[0]= IAC;
		reply[1]= IAC_DONT;
		reply[2]= optsrt;
		result= writeall(tcp_fd, (char *)reply, 3);
		if (result<0)
			perror("write");
		break;
	}
}

static int writeall (fd, buffer, buf_size)
int fd;
char *buffer;
int buf_size;
{
	int result;

	while (buf_size)
	{
		result= write (fd, buffer, buf_size);
		if (result <= 0)
			return -1;
assert (result <= buf_size);
		buffer += result;
		buf_size -= result;
	}
	return 0;
}

static void dont_option (int optsrt)
{
	unsigned char reply[3], *rp;
	int count, result;

	switch (optsrt)
	{
	default:
#if DEBUG
 { where(); fprintf(stderr, "got a DONT (%d)\r\n", optsrt); }
#endif
		break;
	}
}

static void wont_option (int optsrt)
{
	unsigned char reply[3], *rp;
	int count, result;

	switch (optsrt)
	{
	default:
#if DEBUG
 { where(); fprintf(stderr, "got a WONT (%d)\r\n", optsrt); }
#endif
		break;
	}
}

static int sb_termtype (char *bp, int count)
{
	unsigned char command, iac, optsrt;
	unsigned char buffer[4];
	int offset, result;

	offset= 0;
	next_char(command);
	if (command == TERMTYPE_SEND)
	{
		buffer[0]= IAC;
		buffer[1]= IAC_SB;
		buffer[2]= OPT_TERMTYPE;
		buffer[3]= TERMTYPE_IS;
		result= writeall(tcp_fd, (char *)buffer,4);
		if (result<0)
			return result;
		count= strlen(term_env);
		if (!count)
		{
			term_env= "unknown";
			count= strlen(term_env);
		}
		result= writeall(tcp_fd, term_env, count);
		if (result<0)
			return result;
		buffer[0]= IAC;
		buffer[1]= IAC_SE;
		result= writeall(tcp_fd, (char *)buffer,2);
		if (result<0)
			return result;

	}
	else
	{
#if DEBUG
 where();
#endif
		fprintf(stderr, "got an unknown command (skipping)\r\n");
	}
	for (;;)
	{
		next_char(iac);
		if (iac != IAC)
			continue;
		next_char(optsrt);
		if (optsrt == IAC)
			continue;
		if (optsrt != IAC_SE)
		{
#if DEBUG
 where();
#endif
			fprintf(stderr, "got IAC %d\r\n", optsrt);
		}
		break;
	}
	return offset;
}
