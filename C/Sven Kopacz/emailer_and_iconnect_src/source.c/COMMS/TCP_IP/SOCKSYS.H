#if  !defined( __SOCKSYS__ )
#define __SOCKSYS__


typedef struct _sock_dscr
{
	struct	_sock_dscr *next;

	void		*owner_pd;			/* BASPAG of process who owns socket */
	
	int			handle;					/* socket handle */
	int			flags;					/* the following: */

	#define SF_PARENT 1			/* Socket is listen-parent */
	#define SF_SHUTRECV 2		/* Receive-Shutdown by user encountered */
	#define SF_SHUTSEND 4		/* Send-Shutdown by user encountered */
	#define SF_SHUTDOWN (SF_SHUTRECV|SF_SHUTSEND)
	
	int			type;						/* SOCK_STREAM, SOCK_DGRAM... */
	
	int			port;						/* local port if > 0 */
	
	int			tcp_handle;			/* For TCP connections */
	int			tcp_sig;				/* Signals reset on connection */
	
	int			udp_dport;			/* For connect() on DGRAM-sockets */
	ulong		udp_dip;
	
	long		file_status_flags;	/* sfcntl */
	long		so_options;					/* get/setsockopt */
	int			l_onoff;						/* linger onoff */
	int			l_linger;						/* linger value */
	
	int			so_error;						/* Last error */
}sock_dscr;


sock_dscr	*find_sock(int handle);

void sockets_abort(void);

#endif