/*
 *	recvfrom() emulation for MiNT-Net, (w) '93, kay roemer
 */

#ifdef KERNEL
#undef UNX2DOS
#include "kerbind.h"
#else
#include <mintbind.h>
#endif
#include "sys/socket.h"
#include "mintsock.h"

#ifdef UNX2DOS
#include "sys/un.h"
#define UN_OFFSET	((short)((struct sockaddr_un *)0)->sun_path)
#endif

#ifndef KERNEL
extern int errno;
#endif

int
recvfrom (fd, buf, buflen, flags, addr, addrlen)
	int fd;
	void *buf;
	_SIZE_T buflen;
	int flags;
	struct sockaddr *addr;
	_SIZE_T *addrlen;
{
	struct recvfrom_cmd cmd;
	short addrlen16;
	int r;
#ifdef UNX2DOS
	_SIZE_T oaddrlen = addrlen ? *addrlen : 0;
#endif
	
	if (addrlen) addrlen16 = (short)*addrlen;
	
	cmd.cmd =	RECVFROM_CMD;
	cmd.buf =	buf;
	cmd.buflen =	buflen;
	cmd.flags =	flags;
	cmd.addr =	addr;
	cmd.addrlen =	&addrlen16;

#ifdef KERNEL
	r = f_cntl (fd, (long)&cmd, SOCKETCALL);
#else
	r = Fcntl (fd, (long)&cmd, SOCKETCALL);
#endif
	if (addrlen) *addrlen = addrlen16;
	
#ifdef UNX2DOS
	if (addr && addrlen && addr->sa_family == AF_UNIX && r >= 0) {
		struct sockaddr_un *unp = (struct sockaddr_un *)addr;
		char name[sizeof (unp->sun_path)];
		extern int _dos2unx (const char *, char *);
		extern int _sncpy (char *, const char *, _SIZE_T);
		
		if (addrlen16 > UN_OFFSET) {
			_dos2unx (unp->sun_path, name);
			*addrlen = UN_OFFSET + _sncpy (unp->sun_path, name,
				oaddrlen - UN_OFFSET);
		}
	}
#endif

#ifndef KERNEL
	if (r < 0) {
		errno = -r;
		return -1;
	}
#endif
	return r;
}
