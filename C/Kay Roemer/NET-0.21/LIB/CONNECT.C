/*
 *	connect() emulation for MiNT-Net, (w) '93, kay roemer.
 */

#ifdef KERNEL
#undef UNX2DOS
#include "kerbind.h"
#else
#include <mintbind.h>
#include <errno.h>
#endif
#include "sys/socket.h"
#include "mintsock.h"

#ifdef UNX2DOS
#include <string.h>
#include "sys/un.h"
#define UN_OFFSET	((short)((struct sockaddr_un *)0)->sun_path)
#endif

#ifndef KERNEL
extern int errno;
#endif

int
connect (fd, addr, addrlen)
	int fd;
	struct sockaddr *addr;
	_SIZE_T addrlen;
{
	struct connect_cmd cmd;
	int r;
#ifdef UNX2DOS
	struct sockaddr_un un;
	extern int _unx2dos (const char *, char *);

	if (addr && addr->sa_family == AF_UNIX) {
		struct sockaddr_un *unp = (struct sockaddr_un *)addr;

		if (addrlen <= UN_OFFSET || addrlen >= sizeof (un)) {
			errno = EINVAL;
			return -1;
		}

		un.sun_family = AF_UNIX;
		_unx2dos (unp->sun_path, un.sun_path);
		cmd.addr =	(struct sockaddr *)&un;
		cmd.addrlen =	UN_OFFSET + strlen (un.sun_path);
	} else {
#endif
		cmd.addr =	addr;
		cmd.addrlen = 	(short)addrlen;
#ifdef UNX2DOS
	}
#endif
	cmd.cmd =	CONNECT_CMD;
	
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
