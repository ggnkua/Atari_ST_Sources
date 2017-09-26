#if  !defined( __TCP__ )
#define __TCP__

#include <in.h>
#include "ip.h"

/*
 * TCP states.
 */
#define TCPS_CLOSED   0
#define TCPS_LISTEN   1
#define TCPS_SYNSENT    2
#define TCPS_SYNRCVD    3
#define TCPS_ESTABLISHED  4
#define TCPS_FINWAIT1   5
#define TCPS_FINWAIT2   6
#define TCPS_CLOSEWAIT    7
#define TCPS_LASTACK    8
#define TCPS_CLOSING    9
#define TCPS_TIMEWAIT   10


typedef struct
{
	int		src_port;
	int		dst_port;
	ulong	seq_nr;
	ulong	ack_nr;
	
	data_offset	:	4;
	reserved		:	6;
	flags				: 6;
/* Flag-Access */
#define	URG	32
#define	ACK 16
#define	PSH 8
#define	RST 4
#define	SYN 2
#define	FIN	1
	
	uint	window;
	int		crc;
	int		urg_pnt;
	ulong	options[0];
}tcp_header;

typedef struct
{
	ulong	src_ip;
	ulong	dst_ip;
	byte	zero;
	byte	protocol;
	uint	tcp_len;
	
	tcp_header	tcph;
}tcp_crc_header;

#if  !defined( __TCB__ )
#define __TCB__

/* Number of TCP-Blocks of send_window-size sent at once */
#define MAX_BLOCKS 5

typedef struct	_tcp_send_buffer
{
	struct _tcp_send_buffer	*next;
	int		flags;	/* #0=PUSH, #1=URGENT */
	long	transmission_timer;
	long	user_timer;
	ulong	bsn;	/* Seq-Nr. of first byte in buffer */
	int		len;	/* if -1, means: send FIN */
	uchar	*buf;
}tcp_send_buffer;

typedef struct	_tcb
{
	struct	_tcb	*next;
	
	int		state;				/* TCPS_* */
	int		handle;				/* TCP local handle */
	int		parent_sock;	/* handle of parent socket if listen tcb */
	int		*tcp_sig;			/* int to write at, if connection fails */
	int		src_port;			/* adresses */
	int		dst_port;
	ulong	src_ip;
	ulong	dst_ip;
	
	byte	precedence;		/* tcp parameters */
	int		security;
	byte	TOS;
	int		TTL;
	
	long	close_timeout;		/* value for close_timer when starting */
	long	close_timer;			/* running in TCPS_TIMEWAIT */
	long	connection_timer;	/* running in SYNSENT and SYNRCVD */
	long	user_timeout;			/* how long will a segment stay in the retransmission queue until deletion */
	long	retrans_timeout;	/* how long until retransmission if not ACKed */
	
	ulong	snd_isn;					/* my initial sequence number (sn) */
	ulong	snd_una;					/* highest unacknowledged sent byte */
	ulong	snd_next;					/* next sn to send */
	uint	snd_wnd;					/* size of send window */
	ulong	snd_buf_next_isn;	/* ISN for first byte of a new buffer */
	tcp_send_buffer	*first;	/* Pointer to first buffer to send */
	
	ulong	snd_bll[MAX_BLOCKS];
	long	trans_timer[MAX_BLOCKS];
	
	ulong	rcv_next;			/* next expected sn */
	uint	rcv_wnd;			/* size of rcv window */
	long	recv_up;			/* Received Urgent Pointer */
	int		recv_flags;		/* Received Flags, #0=Push, #1=Urgent */
	ulong	recv_isn;			/* Received ISN */
	ulong	rbuf_isn;			/* ISN of first byte in buffer */
	ulong	recv_buf_len;	/* Used Bytes in Receiving buffer */
	ulong	recv_buf_siz;	/* Size of Receiving buffer */
	uchar	*recv_buf;
}tcb;

#endif

int	tcp_open(int src_port, int dst_port, ulong dst_ip, int act_pas, int *tcp_sig, int user_timeout, byte precedence, int security);
int	tcp_send(int handle, uchar *buf, int len, int flags, int user_timeout);
long	tcp_recv(int handle, uchar *buf, ulong len, int *flags, int peek);
int	tcp_status(int handle, tcb *dtcb);
int tcp_close(int handle);
int tcp_abort(int handle);
int	tcp_in(uchar *buf, uint len, ip_header *iph);
void tcp_timer_jobs(void);
void tcp_all_abort(void);
long tcp_get_sendbufsize(int handle);
tcb *find_tcb_by_sock(int src_port, ulong src_ip, int dst_port, ulong dst_ip);
int	find_assigned_tcb(int parent, sockaddr_in *addr);
int check_assigned_tcb(int parent);
void tcp_kill_childs(int parent);
#endif
