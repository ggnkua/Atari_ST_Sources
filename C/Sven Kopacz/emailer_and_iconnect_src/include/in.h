#if  !defined( __IN__ )
#define __IN__

/* well-defined IP protocols */
#define IPPROTO_IP  0
#define IPPROTO_TCP 6
#define IPPROTO_UDP 17
/* not supported: */
#define IPPROTO_ICMP  1
#define IPPROTO_RAW 255
#define IPPROTO_MAX IPPROTO_RAW

#define IS_INET_PROTO(p) \	((p) == IPPROTO_ICMP || (p) == IPPROTO_TCP || (p) == IPPROTO_UDP)/* well-known IP ports */#define IPPORT_RESERVED		1024#define IPPORT_USERRESERVED	5000/* internet address */struct in_addr {	unsigned long s_addr;};/* definitions for classifying an internet address */#define	IN_CLASSA(a)		((((long)(a)) & 0x80000000ul) == 0)#define	IN_CLASSA_NET		0xff000000ul#define	IN_CLASSA_NSHIFT	24#define	IN_CLASSA_HOST		(0xfffffffful & ~IN_CLASSA_NET)#define	IN_CLASSA_MAX		128#define	IN_CLASSB(a)		((((long)(a)) & 0xc0000000ul) == 0x80000000ul)#define	IN_CLASSB_NET		0xffff0000ul#define	IN_CLASSB_NSHIFT	16#define	IN_CLASSB_HOST		(0xfffffffful & ~IN_CLASSB_NET)#define	IN_CLASSB_MAX		65536#define	IN_CLASSC(a)		((((long)(a)) & 0xe0000000ul) == 0xc0000000ul)#define	IN_CLASSC_NET		0xffffff00ul#define	IN_CLASSC_NSHIFT	8#define	IN_CLASSC_HOST		(0xfffffffful & ~IN_CLASSC_NET)#define	IN_CLASSD(a)		((((long)(a)) & 0xf0000000ul) == 0xe0000000ul)/* well-defined IP addresses */#define	INADDR_ANY		((unsigned long)0x00000000)#define	INADDR_BROADCAST	((unsigned long)0xfffffffful)#define	INADDR_NONE		((unsigned long)0xfffffffful)#define	INADDR_LOOPBACK		((unsigned long)0x7f000001ul)#define IN_LOOPBACKNET		127
/* Socket address, internet style */
typedef struct
{
	int						sin_family;
	int						sin_port;
	unsigned long	sin_addr;
	char					sin_zero[8];
}sockaddr_in;

/* options for use with [s|g]etsockopt' call at the IPPROTO_IP level */#define	IP_OPTIONS	1#define	IP_HDRINCL	2#define	IP_TOS		3#define	IP_TTL		4#define	IP_RECVOPTS	5#define	IP_RECVRETOPTS	6#define	IP_RECVDSTADDR	7#define	IP_RETOPTS	8/* structure for use with IP_OPTIONS and IP_RETOPTS */struct ip_opts {	struct in_addr	ip_dst;	char		ip_opts[40];};/* functions to convert between host and network byte order (big endian) */#define	ntohl(x)	(x)#define	ntohs(x)	(x)#define	htonl(x)	(x)#define	htons(x)	(x)
#endif