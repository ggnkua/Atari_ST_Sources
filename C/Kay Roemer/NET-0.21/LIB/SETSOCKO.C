/*
 *	setsockopt() emulation for MiNT-Net, (w) '93, kay roemer
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
setsockopt (fd, level, optname, optval, optlen)
	int fd, level, optname;
	void *optval;
	_SIZE_T optlen;
{
	struct setsockopt_cmd cmd;
	int r;

	cmd.cmd =	SETSOCKOPT_CMD;
	cmd.level =	level;
	cmd.optname =	optname;
	cmd.optval =	optval;
	cmd.optlen =	optlen;

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
