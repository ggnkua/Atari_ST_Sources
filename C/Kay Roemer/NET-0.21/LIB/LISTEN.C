/*
 *	listen() emulation for MiNT-Net, (w) '93, kay roemer.
 */

#ifdef KERNEL
#include "kerbind.h"
#else
#include <mintbind.h>
#endif
#include "sys/socket.h"
#include "mintsock.h"

#ifndef KERNEL
extern int errno;
#endif

int
listen (fd, backlog)
	int fd, backlog;
{
	struct listen_cmd cmd;
	int r;

	cmd.cmd = 	LISTEN_CMD;
	cmd.backlog = 	backlog;

#ifndef KERNEL
	r = Fcntl (fd, (long)&cmd, SOCKETCALL);
	if (r < 0) {
		errno = -r;
		return -1;
	}
	return 0;
#else
	return f_cntl (fd, (long)&cmd, SOCKETCALL);
#endif
}
