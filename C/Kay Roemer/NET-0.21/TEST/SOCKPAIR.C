#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <sys/types.h>
#include <sys/wait.h>

/* Note that for datagram sockets the output will consist of 500 dots,
 * 'cuz cat reads stdin byte-wise, thus dropping the rest of the message.
 */
#define SOCK_TYPE	SOCK_DGRAM
/*
#define SOCK_TYPE	SOCK_STREAM
*/

int
main()
{
	int fd[2], r, i;
	char *mess = "... you make the best of whats still around\n";
	pid_t child_pid;
	
	r = socketpair (AF_UNIX, SOCK_TYPE, 0, fd);
	if (r < 0) {
		perror ("socketpair");
		return 0;
	}
	child_pid = fork();
	if (!child_pid) {
		r = dup2 (fd[1], 0);
		if (r < 0) {
			perror ("dup2");
			return 0;
		}
		execlp ("cat", "cat", NULL);
		puts ("execlp: failed");
		return 0;
	}
	close (fd[1]);
	for (i = 0; i < 500; ++i) {
		r = write (fd[0], mess, strlen (mess));
		if (r < 0) {
			perror ("write");
			return 0;
		}
	}
	waitpid (child_pid, &r, 0);
	close (fd[0]);
	return 0;
}
