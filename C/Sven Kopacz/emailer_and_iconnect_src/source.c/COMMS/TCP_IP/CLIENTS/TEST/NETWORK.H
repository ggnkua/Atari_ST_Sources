#if  !defined( __NET__ )
#define __NET__
#include <tos.h>
#include <netdb.h>
#include <types.h>

#if !defined( __UTYPES__ )
#define __UTYPES__
typedef	unsigned char uchar;
typedef	uchar					byte;
typedef	unsigned int	uint;
typedef	unsigned long ulong;
#endif

typedef struct
{
	/* System-defaults */
	ulong	my_ip;					/* My IP-Adress */
	ulong name_server_ip;

	long	clk_tck;	/* How many Timer-jobs per second? */
									/* NOT MORE THAN 20! */

	/* Socket-defaults */
	int		port_init;	/* First port to be assigned (rec. 1025) */
	int		port_max;		/* Last port to be assigned (rec. 5000) */
	int		max_listen;	/* Max. backlog in a listen-call */

	/* DNS-defaults */
	int		dns_timeout; /* Seconds until rentransmission of DNS-queries */
	int		dns_retry;	 /* Retransmissions before an error is returned */

	/* UDP-defaults */
	int		udp_count;	/* Max. number of UDP-sockets */
	
	/* TCP-defaults */
	int		user_timeout; /* Seconds until a TCP-Connection is deleted if data couldn't be
												transmitted */
	ulong	connection_timeout; /* Seconds until a tcb in SYNSENT-state will be aborted */
	int		snd_wnd;	/* TCP-Send-Window-Size (until answer from host arrives)*/
	int		rcv_wnd;	/* TCP-Receive-Window-Size (since buffers are allocated dynamically, this is
 										 only used for incoming-TCP-segments check) */

	byte	allow_precedence_raise;	/* Precedence might be raised, if incoming TCP-packet has higher precedence */ 										 
	
	/* IP-defaults */
	long	kill_ip_timer; /* Time (in Systicks) until an IP-Fragment
													will be deleted from the Receiving-queue */

	int		security;		/* Should be zero */
	int		precedence;	/* Is separate from TOS */
	byte	TOS;		/* IP-Type of Service (only lower Bits are used (=without precedence))*/
	int		TTL;		/* IP-Time to Live */
	
}default_values;

typedef struct
{
	long	version;

	/* sockets */
	int		(*socket)(int af, int type, int protocol);
	int 	(*bind)(int s, const void *addr, int addrlen);
	int 	(*listen)(int s, int backlog);
	int 	(*accept)(int s, const void *addr, int *addrlen);
	int		(*connect)(int s, const void *addr, int addrlen);

	int 	(*write)(int s, const void *msg, int len);
	int		(*send)(int s, const void *msg, int len, int flags);
	int 	(*sendto)(int s, const void *msg, int len, int flags, void *to, int tolen);

	long 	(*read)(int s, void *buf, long len);
	long	(*recv)(int s, void *buf, long len, int flags);
	long 	(*recvfrom)(int s, void *buf, long len, int flags, void *from, int *fromlen);

	int 	(*select)(int nfds, fd_set	*readlist, fd_set *writelist, fd_set *exceptlist, timeval *TimeOut);
	int		(*status)(int s, void *mtcb); /* is (tcb*) */
	int		(*shutdown)(int s, int how);
	int		(*close)(int s);

	long	(*sfcntl)(int FileDescriptor, long Command, long Argument);
	int 	(*getsockopt)(int s, int level, int optname, void *optval, int *optlen);
	int 	(*setsockopt)(int s, int level, int optname, const void *optval, int *optlen);
	
	int 	(*getsockname)(int s, void *addr, int *addrlen);
	int 	(*getpeername)(int s, void *addr, int *addrlen);

	/* resolver */
	void 	(*res_init)(void);
	int 	(*res_query)(char *dname, int class, int type, uchar *answer, int anslen);
	int 	(*res_search)(char *dname, int class, int type, uchar *answer, int anslen);
	int 	(*res_mkquery)(int op, char *dname, int class, int type, char *data, int datalen, void *notused, char *buf, int buflen);
	int 	(*res_send)(char *msg, int msglen, char *answer, int anslen);
	int 	(*dn_expand)(uchar *msg, uchar *eomorig, uchar *comp_dn, uchar *exp_dn, int length);
	int 	(*dn_comp)(uchar *exp_dn, uchar *comp_dn, uchar **dnptrs, uchar **lastdnptr, int length);
}user_interface;

typedef struct
{
	user_interface usr;
	void	(*timer_jobs)(void);
	void	(*open_port)(char *port_name);
	void	(*terminate)(void);
	void	(*close_port)(void);
	void *(*emalloc)(ulong len);
	void *(*erealloc)(void *block, ulong newlen);
	void (*efree)(void *block);
	void (*etimer)(int ms);	
	BASPAG *server_pd;
	void	*_debug;
}sys_interface;

typedef struct
{
	default_values	*defs;
	user_interface	*user;
	sys_interface		*sys;
}cookie_struct;

void *tmalloc(ulong len);
extern void *(*imalloc)(ulong len);
extern void *(*irealloc)(void *block, ulong newlen);
extern void (*ifree)(void *block);
extern void (*iwait)(int ms);


extern	int set_flag(int bit_nr);
extern	void	clear_flag(int bit_nr);
#define MEM_SEM 0
#define SLIP_SEM 1
#define TCP_SBUF_SEM 2
#define TCP_RBUF_SEM 3
#define TCP_TCB_SEM 4
#define SOCK_SEM 5
#define UDP_RBUF_SEM 6
#endif