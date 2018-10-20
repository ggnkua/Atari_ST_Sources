#if  !defined( __SOCKET__ )
#define __SOCKET__



/* socket types */
enum so_type {
  SOCK_STREAM = 1,
  SOCK_DGRAM,
/* not supported: */
  SOCK_RAW,
  SOCK_RDM,
  SOCK_SEQPACKET
};

/* Option flags per-socket. */
#define SO_DEBUG				0x0001
#define SO_ACCEPTCONN 	0x0002
#define SO_REUSEADDR		0x0004
#define SO_KEEPALIVE		0x0008
#define SO_DONTROUTE		0x0010
#define SO_BROADCAST		0x0020
#define SO_USELOOPBACK	0x0040
#define SO_LINGER				0x0080
#define SO_OOBINLINE		0x0100

/* Additonal options, not kept in so_options */
#define SO_SNDBUF				0x1001
#define SO_RCVBUF				0x1002
#define SO_SNDLOWAT			0x1003
#define SO_RCVLOWAT			0x1004
#define SO_SNDTIMEO			0x1005
#define SO_RCVTIMEO			0x1006
#define SO_ERROR				0x1007
#define SO_TYPE					0x1008
#define SO_SND_COPYAVOID	0x1009
#define SO_RCV_COPYAVOID	0x100a

/* Structure used for manupulating linger option */
typedef struct	
{
	int	l_onoff;
	int	l_linger;
}linger;

/* Level number to apply socket itself */
#define SOL_SOCKET	((int)0xffff)

/* protocol families */
#define PF_UNSPEC 0
#define PF_UNIX   1
#define PF_INET   2

/* address families, same as above */
#define AF_UNSPEC PF_UNSPEC
#define AF_UNIX   PF_UNIX
#define AF_INET   PF_INET
/* not supported: */
#define AF_LINK   200

/* flags for send and recv */
#define MSG_OOB   1
#define MSG_PEEK  2
/* not supported: */
#define MSG_DONTROUTE 4


extern int cdecl socket(int af, int type, int protocol);
extern int cdecl bind(int s, const void *addr, int addrlen);
extern int cdecl listen(int s, int backlog);
extern int cdecl accept(int s, const void *addr, int *addrlen);
extern int cdecl connect(int s, const void *addr, int addrlen);

extern int cdecl swrite(int s, const void *msg, int len);
extern int cdecl send(int s, const void *msg, int len, int flags);
extern int cdecl sendto(int s, const void *msg, int len, int flags, void *to, int tolen);

extern long cdecl sread(int s, void *buf, long len);
extern long cdecl recv(int s, void *buf, long len, int flags);
extern long cdecl recvfrom(int s, void *buf, long len, int flags, void *from, int *fromlen);

extern int cdecl shutdown(int s, int how);
extern int cdecl sclose(int s);

extern int cdecl getsockname(int s, void *addr, int *addrlen);
extern int cdecl getpeername(int s, void *addr, int *addrlen);

extern int cdecl getsockopt(int s, int level, int optname, void *optval, int *optlen);
extern int cdecl setsockopt(int s, int level, int optname, const void *optval, int *optlen);

/* Unoffical call to get TCB Information */
extern int	cdecl status(int s, void *mtcb);

#endif