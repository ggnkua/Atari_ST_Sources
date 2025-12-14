/*
 *	socketpair() emulation for MiNT-Net, (w) '93, kay roemer.
 */

#ifdef KERNEL
#include "kerbind.h"
#else
#include <osbind.h>
#include <mintbind.h>
#endif
#include "file.h"
#include "sys/socket.h"
#include "mintsock.h"

#define SOCKDEV		"u:\\dev\\socket"

#ifndef KERNEL
extern int errno;
#endif

int
socketpair (domain, type, proto, fds)
	int domain, type, proto, fds[2];
{
	struct socketpair_cmd cmd;
	int sockfd1, sockfd2;

#ifdef KERNEL
	sockfd1 = f_open (SOCKDEV, O_RDWR);
	if (sockfd1 < 0) return sockfd1;
#else
	sockfd1 = Fopen (SOCKDEV, O_RDWR);
	if (sockfd1 < 0) {
		errno = -sockfd1;
		return -1;
	}
#endif
	cmd.cmd =	SOCKETPAIR_CMD;
	cmd.domain =	domain;
	cmd.type =	type;
	cmd.protocol =	proto;

#ifdef KERNEL
	sockfd2 = f_cntl (sockfd1, (long)&cmd, SOCKETCALL);
	if (sockfd2 < 0) {
		f_close (sockfd1);
		return sockfd2;
	}
#else
	sockfd2 = Fcntl (sockfd1, (long)&cmd, SOCKETCALL);
	if (sockfd2 < 0) {
		errno = -sockfd2;
		Fclose (sockfd1);
		return -1;
	}
#endif
	fds[0] = sockfd1;
	fds[1] = sockfd2;
	return 0;
}
