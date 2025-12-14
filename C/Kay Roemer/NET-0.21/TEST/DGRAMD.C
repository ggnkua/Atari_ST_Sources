#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/un.h>

#define SERVER	"/tmp/dgramd"
#define OFFSET	((short)((struct sockaddr_un *)0)->sun_path)

/*#define CONNECT*/

int
main()
{
	struct sockaddr_un sun;
	char buf[] = "Response from dgram server /tmp/dgram\n";
	struct iovec iov[2];
	struct msghdr msg;
	int r, fd;

	unlink (SERVER);
	
	fd = socket (AF_UNIX, SOCK_DGRAM, 0);
	if (fd < 0) {
		perror ("socket");
		return 0;
	}
	
	sun.sun_family = AF_UNIX;
	strcpy (sun.sun_path, SERVER);

	r = bind (fd, (struct sockaddr *)&sun, OFFSET + strlen (SERVER));
	if (r < 0) {
		perror ("bind");
		return 0;
	}
	iov[0].iov_base = &buf[0];
	iov[0].iov_len = 10;
	iov[1].iov_base = &buf[10];
	iov[1].iov_len = strlen (buf) - 10;
	msg.msg_name = 0;
	msg.msg_namelen = 0;
	msg.msg_iov = iov;
	msg.msg_iovlen = 2;
	msg.msg_accrights = 0;
	msg.msg_accrightslen = 0;
	
	for (;;) {
		char scratch[1];
		size_t addrlen = sizeof (sun);
		int i;
		
		r = recvfrom (fd, scratch, sizeof (scratch), 0,
			(struct sockaddr *)&sun, &addrlen);
		if (r < 0) {
			perror ("recvfrom");
			return 0;
		}
		if (addrlen <= OFFSET) continue;
#ifdef CONNECT
		r = connect (fd, (struct sockaddr *)&sun, addrlen);
		if (r < 0) {
			perror ("connect");
			return 0;
		}
#else
		msg.msg_name = &sun;
		msg.msg_namelen = addrlen;
#endif		
		for (i = 0; i < 500; ++i) {
			r = sendmsg (fd, &msg, 0);
			if (r < 0) {
				perror ("sendmsg");
				return 0;
			}
		}
	}
	return 0;
}
