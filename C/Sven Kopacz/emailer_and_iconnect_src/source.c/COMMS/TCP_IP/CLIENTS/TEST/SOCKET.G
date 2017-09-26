#if  !defined( __SOCKET__ )
#define __SOCKET__


typedef struct _sock_dscr
{
	struct	_sock_dscr *next;

	int			handle;
	int			flags;

	#define SF_PARENT 1			/* Socket is listen-parent */
	#define SF_SHUTRECV 2		/* Receive-Shutdown by user encountered */
	#define SF_SHUTSEND 4		/* Send-Shutdown by user encountered */
	#define SF_SHUTDOWN (SF_SHUTRECV|SF_SHUTSEND)
	
	int			type;		/* Stream, Dgram, Raw */
	
	int			port;
	int			tcp_handle;
	
	int			udp_dport;	/* For connect() on DGRAM-sockets */
	ulong		udp_dip;
}sock_dscr;

typedef struct
{
	int		sin_family;
	int		sin_port;
	ulong	sin_addr;
	char	sin_zero[8];
}sockaddr_in;

/* socket types */
enum so_type {
  SOCK_STREAM = 1,
  SOCK_DGRAM,
  SOCK_RAW,
  SOCK_RDM,
  SOCK_SEQPACKET
};

/* protocol families */
#define PF_UNSPEC 0
#define PF_UNIX   1
#define PF_INET   2

/* address families, same as above */
#define AF_UNSPEC PF_UNSPEC
#define AF_UNIX   PF_UNIX
#define AF_INET   PF_INET
#define AF_LINK   200

/* well-defined IP protocols */
#define IPPROTO_IP  0
#define IPPROTO_ICMP  1
#define IPPROTO_TCP 6
#define IPPROTO_UDP 17
#define IPPROTO_RAW 255
#define IPPROTO_MAX IPPROTO_RAW

/* flags for send and recv */
#define MSG_OOB   1
#define MSG_PEEK  2
#define MSG_DONTROUTE 4


int socket(int af, int type, int protocol);
int bind(int s, const void *addr, int addrlen);
int listen(int s, int backlog);
int accept(int s, const void *addr, int *addrlen);
int connect(int s, const void *addr, int addrlen);

int swrite(int s, const void *msg, int len);
int send(int s, const void *msg, int len, int flags);
int sendto(int s, const void *msg, int len, int flags, void *to, int tolen);

long sread(int s, void *buf, long len);
long recv(int s, void *buf, long len, int flags);
long recvfrom(int s, void *buf, long len, int flags, void *from, int *fromlen);

int	status(int s, void *mtcb);
int shutdown(int s, int how);
int sclose(int s);
void sockets_abort(void);

#endif