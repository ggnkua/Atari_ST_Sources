/*
 *	socket() emulation for MiNT-Net, (w) '93, kay roemer.
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
socket (domain, type, proto)
	int domain, type, proto;
{
	struct socket_cmd cmd;
	int sockfd, r;

#ifdef KERNEL
	sockfd = f_open (SOCKDEV, O_RDWR|O_GLOBAL);
	if (sockfd < 0) return sockfd;
#else
	sockfd = Fopen (SOCKDEV, O_RDWR);
	if (sockfd < 0) {
		errno = -sockfd;
		return -1;
	}
#endif
	cmd.cmd =	SOCKET_CMD;
	cmd.domain =	domain;
	cmd.type =	type;
	cmd.protocol =	proto;

#ifdef KERNEL
	r = f_cntl (sockfd, (long)&cmd, SOCKETCALL);
	if (r < 0) {
		f_close (sockfd);
		return r;
	}
#else
	r = Fcntl (sockfd, (long)&cmd, SOCKETCALL);
	if (r < 0) {
		errno = -r;
		Fclose (sockfd);
		return -1;
	}
#endif
	return sockfd;
}
