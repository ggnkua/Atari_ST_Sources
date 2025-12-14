#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/un.h>

#define OFFSET ((short)((struct sockaddr_un *)0)->sun_path)

#if 0
#define FD_SETSIZE           32
#define FD_ZERO(fds)      (*(fds) = 0)
#define FD_SET(fd, fds)   (*(fds) |= (fd_set)1 << (fd))
#define FD_CLR(fd, fds)   (*(fds) &= ~((fd_set)1 << (fd)))
#define FD_ISSET(fd, fds) (*(fds) & ((fd_set)1 << (fd)))

typedef long fd_set;

int select (int, fd_set *, fd_set *, fd_set *, struct timeval *);
#endif

#define NONBLOCK

int
main()
{
	int fd, err, r;
	struct sockaddr_un un;

	fd = socket (AF_UNIX, SOCK_STREAM, 0);
	if (fd < 0) {
		perror ("socket");
		return 0;
	}

#ifdef NONBLOCK
	r = fcntl (fd, F_GETFL, 0);
	if (r < 0) {
		perror ("fcntl");
		return 0;
	}
	r |= O_NDELAY;
	r = fcntl (fd, F_SETFL, r);
	if (r < 0) {
		perror ("fcntl");
		return 0;
	}
#endif /* NONBLOCK */

	un.sun_family = AF_UNIX;
	strcpy (un.sun_path, "/tmp/fort");

	err = bind (fd, (struct sockaddr *)&un, OFFSET+strlen (un.sun_path));
	if (err < 0) {
		perror ("bind");
		close (fd);
		return 0;
	}
	err = listen (fd, 2);
	if (err < 0) {
		perror ("listen");
		close (fd);
		return 0;
	}	
	while (1) {
		int client, i;
		char message1[] = "When the ";
		char message2[] = "world is ";
		char message3[] = "running down...\n";
		struct msghdr msg;
		struct iovec iov[3];
		
#ifdef NONBLOCK
		fd_set sel;

		FD_ZERO(&sel);
		FD_SET(fd, &sel);

		while (!select (32, &sel, NULL, NULL, NULL))
			FD_SET(fd, &sel);
#endif		
		client = accept (fd, NULL, NULL);
		if (client < 0) {
			perror ("accept");
			return 0;
		}
		iov[0].iov_base = message1;
		iov[0].iov_len  = strlen (message1);
		iov[1].iov_base = message2;
		iov[1].iov_len  = strlen (message2);
		iov[2].iov_base = message3;
		iov[2].iov_len  = strlen (message3);
		msg.msg_name = 0;
		msg.msg_namelen = 0;
		msg.msg_iov = iov;
		msg.msg_iovlen = 3;
		msg.msg_accrights = 0;
		msg.msg_accrightslen = 0;
		for (i=0; i<1000; ++i) {
			long size = iov[0].iov_len + iov[1].iov_len +
				iov[2].iov_len;
			if (size != sendmsg (client, &msg, 0)) {
				perror ("sendmsg");
				break;
			}
		}
		close (client);
	}
	close (fd);
	return 0;
}
