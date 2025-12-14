/*
 *	getsockopt() emulation for MiNT-Net, (w) '93, kay roemer
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
getsockopt (fd, level, optname, optval, optlen)
	int fd, level, optname;
	void *optval;
	_SIZE_T *optlen;
{
	struct getsockopt_cmd cmd;
	long optlen32;
	int r;

	if (optlen) optlen32 = *optlen;

	cmd.cmd =	GETSOCKOPT_CMD;
	cmd.level =	level;
	cmd.optname =	optname;
	cmd.optval =	optval;
	cmd.optlen =	&optlen32;

#ifdef KERNEL
	r = f_cntl (fd, (long)&cmd, SOCKETCALL);
#else
	r = Fcntl (fd, (long)&cmd, SOCKETCALL);
#endif
	if (optlen) *optlen = optlen32;
#ifdef KERNEL
	return r;
#else
	if (r < 0) {
		errno = -r;
		return -1;
	}
	return 0;
#endif
}
