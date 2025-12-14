/*
 *	recvmsg() emulation for MiNT-Net, (w) '93, kay roemer
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
recvmsg (fd, msg, flags)
	int fd;
	struct msghdr *msg;
	int flags;
{
	struct recvmsg_cmd cmd;
	int r;
#ifdef UNX2DOS
	struct sockaddr_un *unp = (struct sockaddr_un *)msg->msg_name;
	_SIZE_T oaddrlen = msg->msg_namelen;
#endif

	cmd.cmd = RECVMSG_CMD;
	cmd.msg = msg;
	cmd.flags = flags;

#ifdef KERNEL
	r = f_cntl (fd, (long)&cmd, SOCKETCALL);
#else
	r = Fcntl (fd, (long)&cmd, SOCKETCALL);
#endif
	
#ifdef UNX2DOS
	if (unp && unp->sun_family == AF_UNIX && r >= 0) {
		char name[sizeof (unp->sun_path)];
		extern int _dos2unx (const char *, char *);
		extern int _sncpy (char *, const char *, _SIZE_T);
		
		if (msg->msg_namelen > UN_OFFSET) {
			_dos2unx (unp->sun_path, name);
			msg->msg_namelen = UN_OFFSET + _sncpy (unp->sun_path,
				name, oaddrlen - UN_OFFSET);
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
