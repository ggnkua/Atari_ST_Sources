#ifndef __SOCKET_H__
#define __SOCKET_H__

#ifndef INADDR_NONE

struct in_addr {
  unsigned long s_addr;
};

#define INADDR_NONE         ((unsigned long)0xffffffff)  /* 255.255.255.255 */
#define INADDR_LOOPBACK     ((unsigned long)0x7f000001)  /* 127.0.0.1 */

/* Definitions of the bits in an Internet address integer.

   On subnets, host and network parts are found according to
   the subnet mask, not these masks.  */

#define IN_CLASSA(a)        ((((unsigned long)(a)) & 0x80000000) == 0)
#define IN_CLASSA_NET       0xff000000
#define IN_CLASSA_NSHIFT    24
#define IN_CLASSA_HOST      (0xffffffff & ~IN_CLASSA_NET)
#define IN_CLASSA_MAX       128

#define IN_CLASSB(a)        ((((unsigned long)(a)) & 0xc0000000) == 0x80000000)
#define IN_CLASSB_NET       0xffff0000
#define IN_CLASSB_NSHIFT    16
#define IN_CLASSB_HOST      (0xffffffff & ~IN_CLASSB_NET)
#define IN_CLASSB_MAX       65536

#define IN_CLASSC(a)        ((((unsigned long)(a)) & 0xe0000000) == 0xc0000000)
#define IN_CLASSC_NET       0xffffff00
#define IN_CLASSC_NSHIFT    8
#define IN_CLASSC_HOST      (0xffffffff & ~IN_CLASSC_NET)

#define IN_CLASSD(a)        (((unsigned long)(a) & 0xf0000000) == 0xe0000000)
#define IN_CLASSD_NET       0xf0000000          /* These ones aren't really */
#define IN_CLASSD_NSHIFT    28                  /*   net and host fields, but */
#define IN_CLASSD_HOST      0x0fffffff          /*   routing needn't know. */
#define IN_MULTICAST(a)     IN_CLASSD(a)

#define IN_EXPERIMENTAL(a)  (((unsigned long)(a) & 0xf0000000) == 0xf0000000)
#define IN_BADCLASS(a)      (((unsigned long)(a) & 0xf0000000) == 0xf0000000)

#define IN_LOOPBACKNET      127                 /* official! */

#endif

/* functions to convert between host and network byte order (big endian) */
#ifndef ntohl
#define ntohl(x) (x)
#endif
#ifndef ntohs
#define ntohs(x) (x)
#endif
#ifndef htonl
#define htonl(x) (x)
#endif
#ifndef htons
#define htons(x) (x)
#endif

struct sockaddr_in {
  unsigned char sin_len;
  unsigned char sin_family;
  unsigned short sin_port;
  struct in_addr sin_addr;
  char sin_zero[8];
};

struct sockaddr {
  unsigned char sa_len;
  unsigned char sa_family;
  char sa_data[14];
};

#ifndef socklen_t
#define socklen_t int
#endif

#define SOCK_STREAM     1
#define SOCK_DGRAM      2
#define SOCK_RAW        3

/*
 * Option flags per-socket.
 */
#define SO_DEBUG  0x0001    /* turn on debugging info recording */
#define SO_ACCEPTCONN  0x0002    /* socket has had listen() */
#define SO_REUSEADDR  0x0004    /* allow local address reuse */
#define SO_KEEPALIVE  0x0008    /* keep connections alive */
#define SO_DONTROUTE  0x0010    /* just use interface addresses */
#define SO_BROADCAST  0x0020    /* permit sending of broadcast msgs */
#define SO_USELOOPBACK  0x0040    /* bypass hardware when possible */
#define SO_LINGER  0x0080    /* linger on close if data present */
#define SO_OOBINLINE  0x0100    /* leave received OOB data in line */
#define	SO_REUSEPORT	0x0200		/* allow local address & port reuse */

#define SO_DONTLINGER   (int)(~SO_LINGER)

/*
 * Additional options, not kept in so_options.
 */
#define SO_SNDBUF  0x1001    /* send buffer size */
#define SO_RCVBUF  0x1002    /* receive buffer size */
#define SO_SNDLOWAT  0x1003    /* send low-water mark */
#define SO_RCVLOWAT  0x1004    /* receive low-water mark */
#define SO_SNDTIMEO  0x1005    /* send timeout */
#define SO_RCVTIMEO  0x1006    /* receive timeout */
#define SO_ERROR  0x1007    /* get error status and clear */
#define SO_TYPE    0x1008    /* get socket type */

/*
 * Structure used for manipulating linger option.
 */
struct linger {
       int l_onoff;                /* option on/off */
       int l_linger;               /* linger time */
};

/*
 * Level number for (get/set)sockopt() to apply to socket itself.
 */
#define  SOL_SOCKET  0xfff    /* options for socket level */

#define AF_UNSPEC       0
#define AF_INET         2
#define PF_INET         AF_INET
#define PF_UNSPEC       AF_UNSPEC

#define IPPROTO_IP      0
#define IPPROTO_TCP     6
#define IPPROTO_UDP     17

#define INADDR_ANY      0
#define INADDR_BROADCAST 0xffffffff

/* Flags we can use with send and recv. */
#define MSG_DONTWAIT    0x40            /* Nonblocking i/o for this operation only */

/*
 * Options for level IPPROTO_IP
 */
#define IP_TOS       1
#define IP_TTL       2

#define IPTOS_TOS_MASK          0x1E
#define IPTOS_TOS(tos)          ((tos) & IPTOS_TOS_MASK)
#define IPTOS_LOWDELAY          0x10
#define IPTOS_THROUGHPUT        0x08
#define IPTOS_RELIABILITY       0x04
#define IPTOS_LOWCOST           0x02
#define IPTOS_MINCOST           IPTOS_LOWCOST

/*
 * Definitions for IP precedence (also in ip_tos) (hopefully unused)
 */
#define IPTOS_PREC_MASK                 0xe0
#define IPTOS_PREC(tos)                ((tos) & IPTOS_PREC_MASK)
#define IPTOS_PREC_NETCONTROL           0xe0
#define IPTOS_PREC_INTERNETCONTROL      0xc0
#define IPTOS_PREC_CRITIC_ECP           0xa0
#define IPTOS_PREC_FLASHOVERRIDE        0x80
#define IPTOS_PREC_FLASH                0x60
#define IPTOS_PREC_IMMEDIATE            0x40
#define IPTOS_PREC_PRIORITY             0x20
#define IPTOS_PREC_ROUTINE              0x00

/*
 * Commands for ioctl(),  taken from the BSD file fcntl.h.
 *
 *
 * Ioctl's have the command encoded in the lower word,
 * and the size of any in or out parameters in the upper
 * word.  The high 2 bits of the upper word are used
 * to encode the in/out status of the parameter; for now
 * we restrict parameters to at most 128 bytes.
 */
#if !defined(FIONREAD) || !defined(FIONBIO)
#define IOCPARM_MASK    0x7f            /* parameters must be < 128 bytes */
#define IOC_VOID        0x20000000      /* no parameters */
#define IOC_OUT         0x40000000      /* copy out parameters */
#define IOC_IN          0x80000000      /* copy in parameters */
#define IOC_INOUT       (IOC_IN|IOC_OUT)
                                        /* 0x20000000 distinguishes new &
                                           old ioctl's */
#define _IO(x,y)        (IOC_VOID|((x)<<8)|(y))

#define _IOR(x,y,t)     (IOC_OUT|(((long)sizeof(t)&IOCPARM_MASK)<<16)|((x)<<8)|(y))

#define _IOW(x,y,t)     (IOC_IN|(((long)sizeof(t)&IOCPARM_MASK)<<16)|((x)<<8)|(y))
#endif

#ifndef FIONREAD
#define FIONREAD    _IOR('f', 127, unsigned long) /* get # bytes to read */
#endif
#ifndef FIONBIO
#define FIONBIO     _IOW('f', 126, unsigned long) /* set/clear non-blocking i/o */
#endif

/* Socket I/O Controls */
#ifndef SIOCSHIWAT
#define SIOCSHIWAT  _IOW('s',  0, unsigned long)  /* set high watermark */
#define SIOCGHIWAT  _IOR('s',  1, unsigned long)  /* get high watermark */
#define SIOCSLOWAT  _IOW('s',  2, unsigned long)  /* set low watermark */
#define SIOCGLOWAT  _IOR('s',  3, unsigned long)  /* get low watermark */
#define SIOCATMARK  _IOR('s',  7, unsigned long)  /* at oob mark? */
#endif

#ifndef O_NONBLOCK
#define O_NONBLOCK    04000U
#endif

#ifndef FD_SET
  #undef  FD_SETSIZE
  #define FD_SETSIZE    16
  #define FD_SET(n, p)  ((p)->fd_bits[(n)/8] |=  (1 << ((n) & 7)))
  #define FD_CLR(n, p)  ((p)->fd_bits[(n)/8] &= ~(1 << ((n) & 7)))
  #define FD_ISSET(n,p) ((p)->fd_bits[(n)/8] &   (1 << ((n) & 7)))
  #define FD_ZERO(p)    memset((void*)(p),0,sizeof(*(p)))

  typedef struct fd_set {
          unsigned char fd_bits [(FD_SETSIZE+7)/8];
        } fd_set;

#if 1
  struct timeval {
    long    tv_sec;         /* seconds */
    long    tv_usec;        /* and microseconds */
  };
#endif

#endif /* FD_SET */

typedef struct socket_cookie
{
	long version; /* 0x0101 for example */
	long magic; /* 'SOCK' 0x534F434B */
	int (*socket)(int domain, int type, int protocol);
	int (*bind)(int s, struct sockaddr *name, socklen_t namelen);
	int (*listen)(int s, int backlog);
	int (*accept)(int s, struct sockaddr *addr, socklen_t *addrlen);
	int (*connect)(int s, struct sockaddr *name, socklen_t namelen);
	int (*write)(int s, void *dataptr, int size);
	int (*send)(int s, void *dataptr, int size, unsigned int flags);
	int (*sendto)(int s, void *dataptr, int size, unsigned int flags, struct sockaddr *to, socklen_t tolen);
	int (*read)(int s, void *mem, int len);
	int (*recv)(int s, void *mem, int len, unsigned int flags);
	int (*recvfrom)(int s, void *mem, int len, unsigned int flags, struct sockaddr *from, socklen_t *fromlen);
	int (*shutdown)(int s, int how);
	int (*close)(int s);
	int (*getsockname)(int s, struct sockaddr *name, socklen_t *namelen);
	int (*getpeername)(int s, struct sockaddr *name, socklen_t *namelen);
	int (*getsockopt)(int s, int level, int optname, void *optval, socklen_t *optlen);
	int (*setsockopt)(int s, int level, int optname, const void *optval, socklen_t optlen);
	int (*select)(int maxfdp1, fd_set *readset, fd_set *writeset, fd_set *exceptset, struct timeval *timeout);
	int (*ioctlsocket)(int s, long cmd, void *argp);
	void *(*gethostbyname)(const char *name);
	int (*geterrno)(void);
} SOCKET_COOKIE;

#define init_socket() \
do { \
	struct { \
		long cktag; \
		long ckvalue; \
	} *jar = (void *)Setexc(0x5A0 /4, (void (*)())-1); \
	psc = (SOCKET_COOKIE *)0; \
	while(jar->cktag) { \
		if(jar->cktag == 0x534F434B) { \
			psc = (SOCKET_COOKIE *)jar->ckvalue; \
			if(psc && (psc->magic != 0x534F434B)) \
				psc = (SOCKET_COOKIE *)0; \
			break; \
		} \
		jar++; \
	} \
} while(0)	

#define socket(domain, type, protocol) ((psc->socket)(domain, type, protocol))
#define bind(s, name, namelen) ((psc->bind)(s, name, namelen))
#define listen(s, backlog) ((psc->listen)(s, backlog))
#define accept(s, addr, addrlen) ((psc->accept)(s, addr, addrlen))
#define connect(s, name, namelen) ((psc->connect)(s, name, namelen))
#define swrite(s, dataptr, size) ((psc->write)(s, dataptr, size))
#define send(s, dataptr, size, flags) ((psc->send)(s, dataptr, size, flags))
#define sendto(s, dataptr, size, flags, to, tolen) ((psc->sendto)(s, dataptr, size, flags, to, tolen))
#define sread(s, mem, len) ((psc->read)(s, mem, len))
#define recv(s, mem, len, flags) ((psc->recv)(s, mem, len, flags))
#define recvfrom(s, mem, len, flags, from, fromlen) ((psc->recvfrom)(s, mem, len, flags, from, fromlen))
#define shutdown(s, how) ((psc->shutdown)(s, how))
#define sclose(s) ((psc->close)(s))
#define getsockname(s, name, namelen) ((psc->getsockname)(s, name, namelen))
#define getpeername(s, name, namelen) ((psc->getpeername)(s, name, namelen))
#define getsockopt(s, level, optname, optval, optlen) ((psc->getsockopt)(s, level, optname, optval, optlen))
#define setsockopt(s, level, optname, optval, optlen) ((psc->setsockopt)(s, level, optname, optval, optlen))
#define select(maxfdp1, readset, writeset, exceptset, timeout) ((psc->select)(maxfdp1, readset, writeset, exceptset, timeout))
#define sioctl(s, cmd, argp) ((psc->ioctlsocket)(s, cmd, argp))
#define gethostbyname(name) ((psc->gethostbyname)(name))
#define geterrno() ((psc->geterrno)())

#endif /* __SOCKET_H__ */
