/*
 *	shutdown() emulation for MiNT-Net, (w) '93, kay roemer.
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
shutdown (fd, how)
	int fd, how;
{
	struct shutdown_cmd cmd;
	int r;
	
	cmd.cmd = SHUTDOWN_CMD;
	cmd.how = how;

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
