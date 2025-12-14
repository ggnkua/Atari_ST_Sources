/*
 *	recv() emulation for MiNT-Net, (w) '93, kay roemer
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
recv (fd, buf, buflen, flags)
	int fd;
	void *buf;
	_SIZE_T buflen;
	int flags;
{
	struct recv_cmd cmd;
	int r;

	cmd.cmd =	RECV_CMD;
	cmd.buf =	buf;
	cmd.buflen =	buflen;
	cmd.flags =	flags;

#ifdef KERNEL
	r = f_cntl (fd, (long)&cmd, SOCKETCALL);
#else
	r = Fcntl (fd, (long)&cmd, SOCKETCALL);
	if (r < 0) {
		errno = -r;
		return -1;
	}
#endif
	return r;
}
