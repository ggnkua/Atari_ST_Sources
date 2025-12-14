#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/un.h>

#define SOCK_TYPE	SOCK_STREAM

#define OFFSET	((size_t)((struct sockaddr_un *)0)->sun_path)

static struct sockaddr_un
	sun1 = { AF_UNIX, "/tmp/name1" }, sun2;
	
int
main()
{
	int r, fd1, fd2, addrlen;

	fd1 = socket (PF_UNIX, SOCK_TYPE, 0);
	if (fd1 < 0) {
		perror ("socket");
		return 0;
	}
	fd2 = socket (PF_UNIX, SOCK_TYPE, 0);
	if (fd2 < 0) {
		perror ("socket");
		return 0;
	}

	r = bind (fd1, (struct sockaddr *)&sun1, OFFSET +
		strlen (sun1.sun_path));
	if (r < 0) {
		perror ("bind");
		return 0;
	}

#if SOCK_TYPE == SOCK_DGRAM
	r = connect (fd2, (struct sockaddr *)&sun1, OFFSET +
		strlen (sun1.sun_path));
	if (r < 0) {
		perror ("connect");
		return 0;
	}

	addrlen = sizeof (sun2);
	r = getpeername (fd2, (struct sockaddr *)&sun2, &addrlen);
	if (r < 0) {
		perror ("getpeername");
		return 0;
	}
	if (addrlen > OFFSET) {
		printf ("fd2 is connected to %s.\n", sun2.sun_path);
	} else {
		printf ("fd2's peer has not bound to any address\n");
	}
#endif
	
	addrlen = sizeof (sun2);
	r = getsockname (fd1, (struct sockaddr *)&sun2, &addrlen);
	if (r < 0) {
		perror ("getpeername");
		return 0;
	}
	if (addrlen > OFFSET) {
		printf ("fd1's local address is %s.\n", sun2.sun_path);
	} else {
		printf ("fd1 is not bound to any address\n");
	}
	
	unlink (sun1.sun_path);
	return 0;
}
