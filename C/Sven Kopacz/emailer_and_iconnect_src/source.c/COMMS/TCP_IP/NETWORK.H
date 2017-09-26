#if  !defined( __NET__ )
#define __NET__
#include <tos.h>
#include <usis.h>
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
	ulong	my_ip;					/* My IP-Address */
	ulong peer_ip;				/* IP Address of peer, only used for IPCP */
	ulong name_server_ip;	/* DNS */

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
	int		snd_wnd;	/* TCP-Send-Window-Size (until answer from host arrives, also maximum snd_wnd (e.g. if host gives 32768))*/
	int		rcv_wnd;	/* TCP-Receive-Window-Size (since buffers are allocated dynamically, this is
 										 only used for incoming-TCP-segments check. Anyway connection might speed up with
 										 higher values for rcv_wnd) */

	byte	allow_precedence_raise;	/* Precedence might be raised, if incoming TCP-packet has higher precedence */ 										 
	
	/* IP-defaults */
	long	kill_ip_timer; /* Time (in Systicks) until an IP-Fragment
													will be deleted from the Receiving-queue */

	int		security;		/* Should be zero */
	int		precedence;	/* Is separate from TOS */
	byte	TOS;		/* IP-Type of Service (only lower Bits are used (=without precedence))*/
	int		TTL;		/* IP-Time to Live */
	int		MTU;		/* Maximum transmission unit */	
	
	/* PPP-defaults */
	int		ppp_warn_illegal;		/* Alert if illegal state occurs in startup? (0/1) */
	int		ppp_max_terminate;	/* Maximum term_req retransmission */
	int		ppp_max_configure;	/* Maximum conf_req retransmission */
	int		ppp_max_failure;		/* Maximum nak-transmission without ack */
	long	ppp_default_timer;	/* Time (in Systicks) between retransmissions */
	long	ppp_terminate_timer;/* Time (in Systicks) for proceeding from STOPPING to STOPPED */
	long	ppp_mru;						/* Max. receive unit */
	int		ppp_tls;						/* PPP started, send LOW_UP when DEV ready */
	int		ppp_suc;						/* ppp sign-up complete? */
	int		ppp_crj_sent;				/* code reject sent? */
	int		ppp_crj_recv;				/* code reject received? */
	int		ppp_prj_sent;				/* protocol reject received? */
	int		ppp_prj_recv;				/* protocol reject received? */
	int		ppp_auth_req;				/* authenticate request? */
	int		ppp_lqp_req;				/* link quality report request? */

	int		ppp_authenticate;		/* Host requested authentication 0/1 */
														/* Authentication complete=2 */
	int		ppp_auth_nak;				/* User/Pwd was not accepted */
	char	ppp_auth_user[80];
	char	ppp_auth_pass[80];

	int		ipcp_address_rej;
	int		ipcp_dns_rej;
		
	int		using_ppp;					/* PPP (1) or SLIP (0) used */
	
	int		using_mac_os;				/* Own Kernel or Mac-Kernel (via STIP) used */
	int		stip_mem_ok;				/* Stip-Link Init successfull (1) or not (0) */
	
	long	bytes_sent;
	long	bytes_rcvd;
	
	byte	disable_send_ahead;
	
	ONLINE_TIME	usis_time;			/* Wird von IConnect laufend aktualisiert */
	BYTE_EXCHANGE usis_bytes;		/* Kann aber nicht im IConnect-Speicher liegen,
																 weil der Pointer an Apps gereicht wird und
																 bei IConnect-Term ungÅltig wÅrde */
	
	int		ppp_lcp_echo_sec;		/* Echo interval in seconds */
}default_values;

typedef struct
{
	long	version;

	/* sockets */
	int		cdecl (*socket)(int af, int type, int protocol);
	int 	cdecl (*bind)(int s, const void *addr, int addrlen);
	int 	cdecl (*listen)(int s, int backlog);
	int 	cdecl (*accept)(int s, const void *addr, int *addrlen);
	int		cdecl (*connect)(int s, const void *addr, int addrlen);

	int 	cdecl (*write)(int s, const void *msg, int len);
	int		cdecl (*send)(int s, const void *msg, int len, int flags);
	int 	cdecl (*sendto)(int s, const void *msg, int len, int flags, void *to, int tolen);

	long 	cdecl (*read)(int s, void *buf, long len);
	long	cdecl (*recv)(int s, void *buf, long len, int flags);
	long 	cdecl (*recvfrom)(int s, void *buf, long len, int flags, void *from, int *fromlen);

	int 	cdecl (*select)(int nfds, fd_set	*readlist, fd_set *writelist, fd_set *exceptlist, timeval *TimeOut);
	int		cdecl (*status)(int s, void *mtcb); /* is (tcb*) */
	int		cdecl (*shutdown)(int s, int how);
	int		cdecl (*close)(int s);

	long	cdecl (*sfcntl)(int FileDescriptor, long Command, long Argument);
	int 	cdecl (*getsockopt)(int s, int level, int optname, void *optval, int *optlen);
	int 	cdecl (*setsockopt)(int s, int level, int optname, const void *optval, int *optlen);
	
	int 	cdecl (*getsockname)(int s, void *addr, int *addrlen);
	int 	cdecl (*getpeername)(int s, void *addr, int *addrlen);

	/* resolver */
	void 	cdecl (*res_init)(void);
	int 	cdecl (*res_query)(char *dname, int class, int type, uchar *answer, int anslen);
	int 	cdecl (*res_search)(char *dname, int class, int type, uchar *answer, int anslen);
	int 	cdecl (*res_mkquery)(int op, char *dname, int class, int type, char *data, int datalen, void *notused, char *buf, int buflen);
	int 	cdecl (*res_send)(char *msg, int msglen, char *answer, int anslen);
	int 	cdecl (*dn_expand)(uchar *msg, uchar *eomorig, uchar *comp_dn, uchar *exp_dn, int length);
	int 	cdecl (*dn_comp)(uchar *exp_dn, uchar *comp_dn, uchar **dnptrs, uchar **lastdnptr, int length);
	
	/* User setup information service */
	int		cdecl (*usis)(USIS_REQUEST *request);
}user_interface;

typedef struct
{
	user_interface usr;
	void	(*timer_jobs)(void);
	void	(*open_port)(int port_hdl);
	void	(*ppp_event)(int event);
	void	(*terminate)(void);
	void	(*close_port)(void);
	void *(*emalloc)(ulong len);
	void (*efree)(void *block);
	void (*etimer)(int ms);	
	BASPAG *server_pd;
	void	*_debug;
	int		(*stip_init)(void);
}sys_interface;

typedef struct
{
	default_values	*defs;
	user_interface	*user;
	sys_interface		*sys;
}cookie_struct;

void *tmalloc(ulong len);
extern void *imalloc(ulong len);
extern void ifree(void *block);
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
#define MEMSYS_SEM 7
#define PPP_SEM 8
#define RES_CACHE 9
#define IP_RAW_BUF 10
#define STIP_SYNC_TC 11
#define STIP_SYNC_UC 12
#define STIP_SYNC_DNR 13

extern void block_copy(uchar *idst, uchar *isrc, long ilen);

/* Utility to avoid typecasts into bytestream */
int		get_int(uchar *c);
uint	get_uint(uchar *c);
ulong	get_ulong(uchar *c);
void	set_int(char *p, int i);
void	uset_int(uchar *p, int i);

/* Utility for Debugging (in SYSTEM.C) */
extern int db_handle;	/* Handle of debug-File or -1 if closed */
extern void Dftext(char *text);
extern void Dfnumber(long number);
extern void Dfdump(uchar *buf, ulong len);

#endif