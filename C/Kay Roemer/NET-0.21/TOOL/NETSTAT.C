/*
 *	This is a simple netstat(8). Currently only the -f option with
 *	unix as argument is implemented.
 *
 *	(w) '93, Kay Roemer.
 */

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/un.h>
#include "socket.h"	/* these come from mint-net/include/ */
#include "net.h"

#define UNIX_DEVICE	"/dev/unix"

struct unix_info {
	short		proto;	 /* protcol numer, always 0 */
	short		flags;	 /* socket flags, SO_* */
	short		type;	 /* socket type, SOCK_DGRAM or SOCK_STREAM */
	short		state;	 /* socket state, SS_* */
	short		qlen;	 /* bytes in read buffer */
	short		addrlen; /* addrlen, 0 if no address */
	struct sockaddr_un addr; /* addr, only meaningful if addrlen > 0 */
};


char *
decode_state (state)
	short state;
{
	switch (state) {
	case SS_VIRGIN:
		return "VIRGIN";

	case SS_ISUNCONNECTED:
		return "UNCONNECTED";

	case SS_ISCONNECTING:
		return "CONNECTING";
			
	case SS_ISCONNECTED:
		return "CONNECTED";
			
	case SS_ISDISCONNECTING:
		return "DISCONNECTING";
		
	case SS_ISDISCONNECTED:
		return "DISCONNECTED";

	default:
		return "UNKNOWN";
	}
}

char *
decode_type (type)
	short type;
{
	switch (type) {
	case SOCK_DGRAM:
		return "DGRAM";
		
	case SOCK_STREAM:
		return "STREAM";
		
	case SOCK_RDM:
		return "RDM";
		
	case SOCK_SEQPACKET:
		return "SEQPACKET";
		
	case SOCK_RAW:
		return "RAW";
		
	default:
		return "UNKNOWN";
	}
}

char *
decode_flags (flags)
	short flags;
{
	static char strflags[20];

	strcpy (strflags, "");
	if (flags & SO_ACCEPTCON)
		strcat (strflags, "ACC ");
	if (flags & SO_CANTSNDMORE)
		strcat (strflags, "SND ");
	if (flags & SO_CANTRCVMORE)
		strcat (strflags, "RCV ");
	if (flags & SO_RCVATMARK)
		strcat (strflags, "MRK ");

	return strflags;
}

void
show_unix (void)
{
	struct unix_info info;
	char *proto;
	int fd, r;

	fd = open (UNIX_DEVICE, O_RDONLY);
	if (fd < 0) {
		perror ("netstat: open");
		return;
	}
	puts ("Unix domain communication endpoints:");
	puts ("Proto   Flags            Type      State         Recv-Q Address");
	for (;;) {
		r = read (fd, &info, sizeof (info));
		if (!r) return;
		if (r < 0) {
			perror ("netstat: read");
			return;
		}
		if (r != sizeof (info)) {
			printf ("netstat: could not read next unix info\n");
			return;
		}

		switch (info.proto) {
		case 0:
			proto = "unix";
			break;

		default:
			proto = "unknown";
			break;
		}

		printf ("%-7s %-16s %-9s %-13s %6u %s\n",
			proto,
			decode_flags (info.flags),
			decode_type (info.type),
			decode_state (info.state),
			info.qlen,
			info.addrlen ? info.addr.sun_path : "");
	}
	close (fd);
}

void
usage (void)
{
	puts ("Usage: netstat [options]");
	puts ("Options:");
	puts ("\t -f unix");
} 

int
main (argc, argv)
	int argc;
	char *argv[];
{
	short show_unix_opt = 1, show_usage_opt = 0;
	extern char *optarg;
	int c;

	while ((c = getopt (argc, argv, "f:")) != EOF) {
		switch (c) {
		case 'f':
			if (!strcmp (optarg, "unix")) {
				show_unix_opt = 1;
			} else {
				show_usage_opt = 1;
			}
			break;

		case '?':
			show_usage_opt = 1;
			break;
		}
	}
	if (show_usage_opt) {
		usage ();
		return 0;
	}
	if (show_unix_opt) {	
		show_unix ();
	}
	return 0;
}
