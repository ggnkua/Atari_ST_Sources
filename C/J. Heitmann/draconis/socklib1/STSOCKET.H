/* Socket types */
#define SOCK_STREAM     1
#define SOCK_DGRAM      2
#define SOCK_RAW        3

/* Address families */
#define AF_UNSPEC     0
#define AF_UNIX       1
#define AF_INET       2

/* Protocol families */
#define PF_UNSPEC     AF_UNSPEC
#define PF_UNIX       AF_UNIX
#define PF_INET       AF_INET

/* send/recv flags */
#define MSG_OOB       1
#define MSG_PEEK      2
#define MSG_DONTROUTE 4

/* IP protocols  */
#define IPPROTO_IP     0
#define IPPROTO_ICMP   1
#define IPPROTO_IGMP   2
#define IPPROTO_TCP    6
#define IPPROTO_UDP    17
#define IPPROTO_RAW    255

/* Socket options */
#define SOL_SOCKET			0xFFFF
#define SO_SETFL				83
#define SO_GETFL				84

/* Extended File Options */
#define SO_O_NONBLOCK	 			04000
/* Ioctl options */
#define SO_FIONBIO					126

/* Extended Error values */
#define	EAGAIN								 11	/* Do it again 								 */
#define	EPROTO								 71	/* Protocol error */
#define ENOTSOCK							 88	/* Not a valid socket 				 */
#define	EOPNOTSUPP						 95 /* Operation not supported     */
#define	EADDRINUSE						 98	/* address is already in use 	 */
#define ENOBUFS								105
#define EISCONN								106 /* socket is already connected */
#define	ENOTCONN							107	/* socket is not connected     */
#define	EALREADY							114	/* operation in progress 			 */
#define	EINPROGRESS						115	/* operation started					 */


/* Internet address. */
struct in_addr { unsigned long  s_addr; };

/* describe a socket address. */
struct sockaddr
              {
              unsigned short  sa_family;  /* address family, AF_xxx */
              char    sa_data[14];  /* 14 bytes of protocol address */
              };

struct sockaddr_in
              {
              short int           sin_family;     /* family   */
              unsigned short int  sin_port;       /* port     */
              struct in_addr      sin_addr;       /* Internet address */
              unsigned char pad[8];               /* make same size as sockaddr */
              };

struct iovec
            {
            void *iov_base;
            long iov_len;
            };

/* Message header */
struct msghdr
          {
          void    *msg_name;        /* socket name            */
          int     msg_namelen;      /* name length            */
          struct  iovec *msg_iov;   /* data blocks            */
          long    msg_iovlen;       /* number of data blocks  */
          void    *msg_accrights;   /* access rights          */
          long    msg_accrightslen; /* length of rights       */
          };

struct servent
          {
          char *s_name;
          char **s_aliases;
          int s_port;
          char *s_proto;
          };

struct hostent
          {
          char  *h_name;
          char  **h_aliases;
          int   h_addrtype;
          int   h_length;
          char  **h_addr_list;
          };

#define h_addr  h_addr_list[0]  /* address, for backward compatiblity */

#define FDSET_LONGS 8

typedef struct fd_set
            {
            unsigned long fds_bits[FDSET_LONGS];
            }fd_set;

#define NFDBITS           (8 * sizeof(unsigned long))
#define FD_SETSIZE        (FDSET_LONGS * NFDBITS)

#define FDELT(d)          ((d - 0x1001) / NFDBITS)
#define FDMASK(d)         (1L << ((d - 0x1001) % NFDBITS))
#define FD_SET(d,set)     ((set)->fds_bits[FDELT(d)]    |=  FDMASK(d))
#define FD_CLR(d, set)    ((set)->fds_bits[FDELT(d)]    &= ~FDMASK(d))
#define FD_ISSET(d, set)  ((set)->fds_bits[FDELT(d)]    &   FDMASK(d))
#define FD_ZERO(set)      memset(set, 0,sizeof(fd_set))

#define MAJOR_VERSION(a)	(a >> 16)
#define MINOR_VERSION(a)	(a & 0x7FFF)

struct timeval
        {
        long tv_sec;
        long tv_usec;
        };

#ifndef INTERCON
/* Prototypes */
int accept(int sfd, struct sockaddr *address, int *addrlen);
int bind(int sfd, struct sockaddr *address, int addrlen);
int connect(int sfd, struct sockaddr *in, int len);
int listen(int sfd, int backlog);
long recv(int sfd, void *buf, long len, unsigned flags);
long recvfrom(int sfd, void * buf, long len, unsigned flags, struct sockaddr_in *addr, int *addr_len);
int recvmsg(int sfd, struct msghdr *msg, unsigned int flags);
int select(int nfds, fd_set *readfds, fd_set *writefds, fd_set *exceptfds, struct timeval *timeout);
long send(int sfd, void *buf, long len, unsigned flags);
long sendto(int sfd, void *buf, long len, unsigned flags, struct sockaddr_in *addr, int addr_len);
int sendmsg(int sfd, struct msghdr *msg, unsigned int flags);
int shutdown(int sfd, int how);
int socket(int domain, int type, int protocol);
int getsockopt(int sfd, int level, int optname, char *optval, int *optlen);
int setsockopt(int sfd, int level, int optname, char *optval, int optlen);
long sockfcntl(int sfd, int cmd, long args);

unsigned long htonl(unsigned long hostlong);
unsigned short htons(unsigned short hostshort);
unsigned long ntohl(unsigned long netlong);
unsigned short ntohs(unsigned short netshort);

unsigned long inet_addr(char *cp);
unsigned long inet_network(char *cp);
char *inet_ntoa(struct in_addr in);
struct in_addr inet_makeaddr(int net, int lna);
int inet_lnaof(struct in_addr in);
int inet_netof(struct in_addr in);

struct servent *getservent(void);
struct servent *getservbyname(char *name, char *proto);
struct servent *getservbyport(int port, char *proto);
void setservent(int stayopen);
void endservent(void);

int close_socket(int sfd);
long read_socket(int sfd, void *buf, long len );
long seek_socket(int sfd, long offset, int whence);
long write_socket(int sfd, void *buf, long len );

int gethostname(char *name, int namelen);
int getsockname(int sfd, struct sockaddr *name, int *namelen);
int getpeername(int sfd, struct sockaddr *name, int *namelen);

long gethostid(void);
void sethostid(long hostid);
long gethostip(void);
void sethostip(long hostip);

struct hostent *gethostent(void);
struct hostent *gethostbyname(char *name);
struct hostent *gethostbyaddr(char *addr, int len, int type);
void sethostent(int stayopen);
void endhostent(void);

int async_gethostbyname(char *name);
struct hostent *async_queryname(void);
void async_discard(void);
void async_getconfig(int *retries, int *timeout_p_t);
void async_setconfig(int retries, int timeout_p_t);

void set_error_mode(int type);

int get_connected(void);
long get_dns(int no);
long get_libversion(void);
long get_tcpversion(void);

#ifndef UNCONNECTED
  void set_etcdir(char *new);
  char *get_etcdir(void);
#endif
#endif

