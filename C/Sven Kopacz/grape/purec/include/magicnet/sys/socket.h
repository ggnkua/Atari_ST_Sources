/*
 *	sys/socket.h for MiNT-Net, (w) '93, kay roemer.
 */

#ifndef _SYS_SOCKET_H
#define _SYS_SOCKET_H

#ifndef _COMPILER_H
#include <compiler.h>
#endif

#ifndef _SIZE_T
#define _SIZE_T		__SIZE_TYPEDEF__
typedef _SIZE_T size_t;
#endif

/* Socket types */
#define SOCK_STREAM	1
#define SOCK_DGRAM	2
#define SOCK_RAW	3
#define SOCK_RDM	4
#define SOCK_SEQPACKET	5

/* Protocol families */
#define PF_UNSPEC	0
#define PF_UNIX		1
#define PF_INET		2

/* Address families, same as above */
#define AF_UNSPEC	PF_UNSPEC
#define AF_UNIX		PF_UNIX
#define AF_INET		PF_INET
#define AF_LINK		200

/* Flags for send/recv */
#define MSG_OOB		0x0001
#define MSG_PEEK	0x0002
#define MSG_DONTROUTE	0x0004

/* Levels for use with [s|g]etsockopt call */
#define SOL_SOCKET	0xffff

/* Options for use with [s|g]etsockopt call */
#define SO_DEBUG	1
#define SO_REUSEADDR	2
#define SO_TYPE		3
#define SO_ERROR	4
#define SO_DONTROUTE	5
#define SO_BROADCAST	6
#define SO_SNDBUF	7
#define SO_RCVBUF	8
#define SO_KEEPALIVE	9
#define SO_OOBINLINE	10
#define SO_LINGER	11
#define SO_CHKSUM	40
#define SO_DROPCONN	41

/* Structure used for SO_LINGER */
struct linger {
	long	l_onoff;
	long	l_linger;
};

/* Generic socket address */
struct sockaddr {
	short	sa_family;
	char	sa_data[14];
};

/* Structure used for scatter/gather io */
struct iovec {
	void	*iov_base;
	_SIZE_T	iov_len;
};

/* Structure describing a message used with sendmsg/recvmsg */
struct msghdr {
	void		*msg_name;
	_SIZE_T		msg_namelen;
	struct iovec	*msg_iov;
	_SIZE_T		msg_iovlen;
	void		*msg_accrights;
	_SIZE_T		msg_accrightslen;
};

__EXTERN int	socket		__PROTO((int, int, int));
__EXTERN int	socketpair	__PROTO((int, int, int, int[2]));
__EXTERN int	bind		__PROTO((int, struct sockaddr *, _SIZE_T));
__EXTERN int	connect		__PROTO((int, struct sockaddr *, _SIZE_T));
__EXTERN int	accept		__PROTO((int, struct sockaddr *, _SIZE_T *)); 
__EXTERN int	listen		__PROTO((int, int));
__EXTERN int	getsockname	__PROTO((int, struct sockaddr *, _SIZE_T *));
__EXTERN int	getpeername	__PROTO((int, struct sockaddr *, _SIZE_T *));
__EXTERN int	send		__PROTO((int, void *, _SIZE_T, int));
__EXTERN int	recv		__PROTO((int, void *, _SIZE_T, int));
__EXTERN int	sendto		__PROTO((int, void *, _SIZE_T, int,
					struct sockaddr *, _SIZE_T));

__EXTERN int	recvfrom	__PROTO((int, void *, _SIZE_T, int,
					struct sockaddr *, _SIZE_T *));

__EXTERN int	sendmsg		__PROTO((int, struct msghdr *, int));
__EXTERN int	recvmsg		__PROTO((int, struct msghdr *, int));
__EXTERN int	getsockopt	__PROTO((int, int, int, void *, _SIZE_T *));
__EXTERN int	setsockopt	__PROTO((int, int, int, void *, _SIZE_T));
__EXTERN int	shutdown	__PROTO((int, int));

#endif /* _SYS_SOCKET_H */
