#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <sys/un.h>

#define SERVER	"/tmp/dgramd"
#define CLIENT	"/tmp/dgram"
#define OFFSET	((short)((struct sockaddr_un *)0)->sun_path)

int
main()
{
	int fd, r, i;
	char buf[21];
	struct sockaddr_un un;
	struct iovec iov[3];
	struct msghdr msg;

	unlink (CLIENT);
	
	fd = socket (AF_UNIX, SOCK_DGRAM, 0);
	if (fd < 0) {
		perror ("socket");
		return 0;
	}
	
	un.sun_family = AF_UNIX;
	strcpy (un.sun_path, CLIENT);

	r = bind (fd, (struct sockaddr *)&un, OFFSET + strlen (CLIENT));
	if (r < 0) {
		perror ("bind");
		return 0;
	}

	/* contact server */
	strcpy (un.sun_path, SERVER);
	r = sendto (fd, buf, 1, 0, (struct sockaddr *)&un,
		OFFSET + strlen (SERVER));
	if (r < 0) {
		perror ("sendto");
		return 0;
	}

	iov[0].iov_base = &buf[0];
	iov[0].iov_len = 7;
	iov[1].iov_base = &buf[7];
	iov[1].iov_len = 7;
	iov[2].iov_base = &buf[14];
	iov[2].iov_len = 6;
	msg.msg_name = 0;
	msg.msg_namelen = 0;
	msg.msg_iov = iov;
	msg.msg_iovlen = 3;
	msg.msg_accrights = 0;
	msg.msg_accrightslen = 0;
	
	for (;;) {
		long nread;
		
		r = ioctl (fd, FIONREAD, &nread);
		if (r < 0) {
			perror ("ioctl");
			return 0;
		}
		printf ("%ld bytes: ", nread);
		fflush (stdout);
		r = recvmsg (fd, &msg, 0);
		if (r < 0) {
			perror ("recvmsg");
			return 0;
		}
		buf[r] = '\0';
		puts (buf);
		fflush (stdout);
	}
	return 0;
}
