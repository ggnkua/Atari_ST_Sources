#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/time.h>
#include <sys/socket.h>
#include <sys/un.h>

#define SERVER	"/tmp/fort"
#define OFFSET	((short)((struct sockaddr_un *)0)->sun_path)

int
main (argc, argv)
	int argc;
	char *argv[];
{
	int fd, err, r;
	void *buf;
	long nbytes, bufsize;
	struct sockaddr_un un;

	if (argc != 2) {
		printf ("you must spezify the buffersize as the 1st arg\n");
		return 0;
	}
	bufsize = atol (argv[1]);
	buf = malloc (bufsize);
	if (!buf) {
		printf ("out of mem");
		return 0;
	}
	memset (buf, 'A', bufsize);
	
	fd = socket (AF_UNIX, SOCK_STREAM, 0);
	if (fd < 0) {
		perror ("socket");
		return 0;
	}
	un.sun_family = AF_UNIX;
	strcpy (un.sun_path, SERVER);

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

		client = accept (fd, NULL, NULL);
		if (client < 0) {
			perror ("accept");
			return 0;
		}
		for (nbytes = 0; nbytes < 500000l; nbytes += bufsize) {
			write (client, buf, bufsize);
		}
		close (client);
	}
	close (fd);
	return 0;
}
