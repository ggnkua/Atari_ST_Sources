/*  globdefs.h          (c) Steve Adam 1995         steve@netinfo.com.au
 *
 *  Various global definitions.
 *
 *  Should probably be first header included after the <standard> stuff
 *
 *  I decided to put the various header data structures in here too
 */
#ifndef _GLOBDEFS_H_
#define _GLOBDEFS_H_

#include <time.h>
#include "device.h"			/* for DEV_LIST */

#define TCP_DRIVER_VERSION	"02.00"

/*
 *  A sensible concession to portability and clarity.
 */

typedef char int8;
typedef unsigned char uint8, octet;
typedef int int16;
typedef unsigned int uint16;
typedef long int32;
typedef unsigned long uint32;

#include "ip.h"				/* for IP options struct */
#include "icmp.h"

/* These are not always defined anywhere else,
 *  In particular not in MWC standard headers.
 */

#ifndef TRUE
#define TRUE    1
#endif
#ifndef FALSE
#define FALSE   0
#endif

/* TCP defines */

#define MAXINT16    65535L
#define	MSL2        30  /* Guess at two maximum-segment lifetimes   */
#define	TWAIT_DEF   15  /* Default wait time for TTIME_WAIT state   */
#define	MIN_RTO   500L  /* Minimum timeout, milliseconds            */

#define MAX_STATES	16 	/* was 16 must be > 2 and < 256 */
#define MAX_HDR		128	/* XXX 4bsd-ism: should really be 128 */

/* IP defines */

#define IP_MAXOPT	40	/* Largest option field, bytes */

/* Fields in option type byte */
#define	OPT_COPIED	0x80	/* Copied-on-fragmentation flag */
#define	OPT_CLASS	0x60	/* Option class */
#define	OPT_NUMBER	0x1f	/* Option number */

/* IP option numbers */
#define	IP_EOL		0	/* End of options list */
#define	IP_NOOP		1	/* No Operation */
#define	IP_SECURITY	2	/* Security parameters */
#define	IP_LSROUTE	3	/* Loose Source Routing */
#define	IP_TIMESTAMP	4	/* Internet Timestamp */
#define	IP_RROUTE	7	/* Record Route */
#define	IP_STREAMID	8	/* Stream ID */
#define	IP_SSROUTE	9	/* Strict Source Routing */

/* Timestamp option flags */
#define	TS_ONLY		0	/* Time stamps only */
#define	TS_ADDRESS	1	/* Addresses + Time stamps */
#define	TS_PRESPEC	3	/* Prespecified addresses only */

/* Type-of-service bits */
#define	LOW_DELAY	0x10
#define	THROUGHPUT	0x08
#define	RELIABILITY	0x04

/* IP TOS fields */
#define	PREC(x)		(((x)>>5) & 0x7)
#define	DELAY		0x10
#define	THRUPUT		0x8
#define	RELIABLITY	0x4


/*  It is taken for granted that my C compiler creates these structures
 *  in exactly the order shown.  Other compilers *probably* do too.
 */

/* The minimum IP header
*/

typedef struct ip_header {
	unsigned ver : 4;		/*  Version                                     */
	unsigned ihl : 4;		/*  Internet Header Length                      */
	unsigned tos : 8;		/*  Type of Service                             */
    int16  len;            /*  Total length, 16 bits                       */
    uint16  id;             /*  Identification, 16 bits                     */
    int16  ofst;           /*  Fragment offset, 16 bits, includes Flags    */
    uint8   ttl;            /*  Time to live, 8 bits                        */
    uint8   ptcl;           /*  Protocol, 8 bits                            */
    uint16  sum;            /*  Header checksum, 16 bits                    */
    uint32  s_ip;           /*  Source Address, 32 bits                     */
    uint32  d_ip;           /*  Destination Address, 32 bits                */
   	/*char optlen;		 Length of options field, bytes */
	/*char options[IP_MAXOPT]; Options field */
} IP_HDR;

/* len and ofst used to be uint16 */

/*  IP version number.  */

#define IP_VERSION  4

#define	SLF_ESC		0x01		/* next char is escaped */
#define SLF_DROP	0x02		/* drop this packet */
#define SLF_LINKED	0x04		/* interface is linked to device */
#define SLF_COMPRESS	0x08		/* turn on VJ compression */
#define SLF_AUTOCOMP	0x10		/* enable comp. on TCP_UNCOMP. frame */
#define SLF_COMPCID	0x20		/* enable CID compression */
#define SLF_USRMASK	(SLF_COMPRESS|SLF_AUTOCOMP|SLF_COMPCID)

/*  Values for IP header Protocol field    */
#define P_ICMP   1
#define P_TCP    6
#define P_UDP   17

/* packet types */
#define TYPE_IP			0x40
#define TYPE_UNCOMPRESSED_TCP	0x70
#define TYPE_COMPRESSED_TCP	0x80
#define TYPE_ERROR		0x00

/* well-defined IP protocols */
#define IPPROTO_IP		0
#define IPPROTO_ICMP	1
#define	IPPROTO_IGMP	2
#define IPPROTO_TCP		6
#define IPPROTO_UDP		17
#define IPPROTO_RAW		255
#define IPPROTO_MAX		IPPROTO_RAW

#define IS_INET_PROTO(p) \
	((p) == IPPROTO_ICMP || (p) == IPPROTO_TCP || (p) == IPPROTO_UDP)

/* well-known IP ports */
#define IPPORT_RESERVED		1024
#define IPPORT_USERRESERVED	5000

/*  Fragment flags  (or'd with fragment field) */
#define FLAG_LF 0x0000
#define FLAG_DF 0x4000
#define FLAG_MF 0x2000

#define IP_PROTO(buf)	(((struct ip_header *)(buf)->pip)->ptcl)
#define IP_DATA(buf)	((buf)->pip + \
	((struct ip_header *)(buf)->pip)->ihl * sizeof (long))

/* flag values */
#define SLF_TOSS 1		/* tossing rcvd frames because of input err */


/*  ICMP Subheader structure.
 *
 *      Note that the Second half of the ICMP header has different
 *  meaning depending on circumstance.  I have labelled it as
 *  Identifier and Sequence because they are the only uses I
 *  intend to make of it.
 */

typedef struct icmp_header {
    uint8   type;           /*  Icmp message type                           */
    uint8   code;           /*  Various meanings depending on Type          */
    uint16  sum;            /*  Checksum of the ICMP header and data        */
    uint16  id;             /*  Packet identifier (For ping etc.)           */
    uint16  seq;            /*  Packet sequence (For ping etc.)             */
} ICMP_HDR;

typedef struct tcp_header {
    uint16  sport;          /* Source Port                      */
    uint16  dport;          /* Destination Port                 */
    uint32  seq;            /* Sequence Number                  */
    uint32  ack;            /* Acknowledge Number               */
	unsigned ofst : 4;		/* Offset to TCP data in longs		*/
	unsigned : 6;			/* Filler bits (reserved)			*/
	unsigned f_urg  : 1;	/* URG flag							*/
	unsigned f_ack  : 1;	/* ACK flag							*/
	unsigned f_psh  : 1;	/* PSH flag							*/
	unsigned f_rst  : 1;	/* RST flag							*/
	unsigned f_syn  : 1;	/* SYN flag							*/
	unsigned f_fin  : 1;	/* FIN flag							*/
    uint16  window;         /* Current Window Size              */
    uint16  sum;            /* Checksum Field                   */
    uint16  urgent;         /* Urgent Pointer                   */
} TCP_HDR;



typedef struct udp_header {
    uint16  sport;          /*  Udp Source Port             */
    uint16  dport;          /*  Udp Destination Port        */
    uint16  length;         /*  Udp header + data length    */
    uint16  sum;            /*  Checksum incl. pseudo hdr   */
} UDP_HDR;


/* Pseudo header for TCP and UDP checksum calculations      */

typedef struct pseudo_header {
    uint32  s_ip;                   /* Source IP address        */
    uint32  d_ip;                   /* Destination IP address   */
    uint16  ptcl;                   /* Protocol (P_UDP, P_TCP)  */
    uint16  len;                    /* Message + hdr size       */
} PH;


/* Generic Packet structure
 *  *Every* packet processed by this system will
 *  will reside in a GPKT structure.
 *  Some of the elements of this structure will be specific
 *  to particular parts of the code.  Other code will ignore
 *  them entirely.
 *
 *  If this changes, update initialiser packet in packet.c
 */

typedef struct gpkt {
    char    *fp;        /*  Pointer to start of packet for KRfree()         */
    char    *pip;       /*  Points to an IP pkt or NULL  (ie: base of pkt)  */
    char    *mp;        /*  Points to message. (ie: Following IP header)    */
    char    *data;      /*  Points actual data (ie: After all headers)      */
    int16   ip_len;     /*  Length of the IP packet.  (Including header)    */
    int16   mlen;       /*  Generic message contents size                   */
    int16   protocol;   /*  For PPP - LCP, IPCP, etc...                                         */
    int16   dlen;       /*  Size of data space that follows all headers.    */
    struct  gpkt *next; /*  Points to next gpkt in queue or NULL            */
} GPKT ;

#define GPNULL  (GPKT *)NULL


typedef struct output_queue {
    uint16 size;            /* Size of buffer               */
    uint16 cnt;             /* Count of bytes in buffer     */
    uint16 nw;              /* Next pos to write into buf   */
    uint16 nr;              /* Next pos to read from buf    */
    char   buf[0];          /* Ptr to the actual buffer     */
} OUTQ;

/*  The TCP TCB and related structures  */

/* remove all before tcp_tcb{ if remove new tcpout */

/* Tcp out flags defines */
#define TH_URG 		0x01	/* URG flag	- theurgent offset (th_urp) is valid */
#define TH_ACK		0x02	/* ACK flag	- the acknowledgement number (th_ack) is valid */
#define TH_PSH		0x04	/* PSH flag	- receiver should pass the data to app with no delay */
#define TH_RST		0x08	/* RST flag	- reset the connection */
#define TH_SYN		0x10	/* SYN flag	- sync seq. numbers (est. connection)*/
#define TH_FIN		0x20	/* FIN flag	- sender finished sending data*/

typedef struct tcp_tcb {
    GPKT    *pq;            /*  The pend queue (For incoming out of order)  */
    OUTQ    *outq;          /*  TCP output queue                            */
    uint16  rmss;           /*  Remote Max segment size.  Default 536       */
    uint16  tos;            /*  Type of service for this connection         */
    uint8   type;           /*  Type of ICMP error packet                   */
    uint8   code;           /*  Code of ICMP error packet                   */
    struct {
        uint32  una;        /*  Send unacknowledged                         */
        uint32  nxt;        /*  Send next                                   */
        uint32  ptr;        /*  pointer for send location*/
        uint32  wl1;        /*  Sequence number used for last window update */
        uint32  wl2;        /*  Ack number used for last window update      */
        uint16  wnd;        /*  Send Window                                 */
        uint16  up;         /*  Send Urgent Pointer                         */
    } snd;
    uint32  iss;            /*  Initial Send sequence number                */
    struct {
        uint32  nxt;        /*  Receive next                                */
        uint16  wnd;        /*  Receive window                              */
        uint16  up;         /*  Receive Urgent Pointer                      */
    } rcv;
    uint32  irs;            /*  Initial receive sequence number             */
    int16   backoff;        /*  Powers of two to multiply RTO by.           */
    uint16  prc;            /*  Precedence value.                           */
    int16   dupacks;        /*  Duplicate Ack count                         */
    int16   cwind;          /*  Congestion window                           */
    int16   ssthresh;       /*  Slow-start threshold                        */
    int32   rttseq;         /*  Sequence number being timed                 */
    int16   sndcnt;         /*  Number of unack'd seq numbers on send queue */
    int32   resent;         /*  Count of retransmitted bytes                */
    char    state;          /*  Current TCB state                           */
    char    send_ack;       /*  TRUE if an ACK is required to be sent       */
    						/* send_ack is also STeve's idea of force and thus
    						   is misleading */
    char    retran;         /*  Retransmission flag                         */
    char    rtt_run;        /*  Retransmit timer flag                       */
    char    synack;         /*  Our SYN has been acked                      */
    clock_t rtt_time;       /*  Stored clock values for RTT                 */
    clock_t srtt;           /*  Smoothed Round Trip Timer, in 200hz ticks   */
    clock_t mdev;           /*  RTT deviation.  From Phil Karn's KA9Q       */
    clock_t wt;             /*  Timer for TIME_WAIT state                   */
    clock_t lastactive;     /*  */
    clock_t timer_d;        /*  Timer Duration.                             */
    clock_t timer_e;        /*  Expiration.  RTT or TIME_WAIT time or zero  */

		/* If we remove the test tcpout kill all the rest to } TCB; */
    uint32 rcv_adv;			/*  Advertised window by other end				*/
    
    int16 rxt_cur;			/*  Current Retransmission Timout #TICKS		*/
    char force;				/* 1 if forcing out a byte (persist/OOB) 		*/

   	int16		flags;			/* misc flags */
#define TF_ACKNOW 		0x0001	/* send ACK immediately							*/
#define TF_DELACK		0x0002	/* send ACK, but try to delay it				*/
#define TF_NODELAY		0x0004	/* don't delay packets to coalesce (disable Nagle algorithm) */
#define TF_NOOPT		0x0008	/* don't use TCP options						*/
#define TF_SENTFIN		0x0010	/* have sent FIN								*/
#define TF_RCVD_SCALE	0x0020	/* set when other side send window scale option in SYN */
#define TF_RCVD_TSTMP	0x0040	/* set when other side sends timestamp option in SYN   */
#define TF_REQ_SCALE	0x0080	/* have/will request window scale optio in SYN	*/
#define TF_REQ_TSTMP	0x0100	/* have/will request timestamp option i SYN		*/

	char persist;			/* persist timer								*/
	char keep;				/* keepalive timer or connection establishment timer */

	uint16 max_sndwnd;		/* Biggest mss the other end has offered */
	uint8 snd_scale;
	uint8 rcv_scale;

	uint32 last_ack_sent;	/* sequence of # the last ack field */	

} TCB;

#define	TCPDUPACKS	3

#define AGAIN   8   /* From KA9Q..  Thanks Phil..   */
#define LAGAIN  3
#define DGAIN   4
#define LDGAIN  2

#ifndef LATTICE
#define abs(x)      (x>=0?x:-x)
#define min(x,y)    (x<=y?x:y)
#define max(x,y)    (x<y?y:x)
#endif

/* TCP connection states    */
#define TCLOSED     0   /* No connection.  Null, void, absent, .....        */
#define TLISTEN     1   /* Wait for remote request.  Not used here.         */
#define TSYN_SENT   2   /* Connect request sent.  Await matching request    */
#define TSYN_RECV   3   /* Wait for connection ACK.  (Listener only??)      */
#define TESTABLISH  4   /* Connection is established.  Handshake completed  */
#define TFIN_WAIT1  5   /* Await termination request or acknowledgement     */
#define TFIN_WAIT2  6   /* Await termination request.                       */
#define TCLOSE_WAIT 7   /* Await termination request from local user        */
#define TCLOSING    8   /* Await termination acknowledge from remote TCP    */
#define TLAST_ACK   9   /* Await acknowledgement of terminate request sent  */
#define TTIME_WAIT 10   /* Delay to ensure remote has received term' ACK    */

/* TCP and connection ERROR states. */
#define E_NORMAL        0   /* No error occured...                      */
#define E_OBUFFULL     -1   /* Output buffer is full                    */
#define E_NODATA       -2   /* No data available.                       */
#define E_EOF          -3   /* EOF from remote..						*/
#define E_RRESET       -4   /* RST received from remote.                */
#define E_UA           -5   /* RST.  Other end sent unacceptable pkt    */
#define E_NOMEM        -6   /* Something failed due to lack of memory   */
#define E_REFUSE       -7   /* Connection refused by remote             */
#define E_BADSYN       -8   /* A SYN was received in the window         */
#define E_BADHANDLE    -9   /* Bad connection handle used.              */
#define E_LISTEN       -10  /* The connection is in LISTEN state        */
#define E_NOCCB        -11  /* No free CCB's available                  */
#define E_NOCONNECTION -12  /* No connection matches this packet. (TCP) */
#define E_CONNECTFAIL  -13  /* Failure to connect to remote port. (TCP) */
#define E_BADCLOSE     -14  /* Invalid TCP_close() requested            */
#define E_USERTIMEOUT  -15  /* A user function timed out                */
#define E_CNTIMEOUT    -16  /* A the connection timed out               */
#define E_CANTRESOLVE  -17  /* Can't resolve the hostname               */
#define E_BADDNAME     -18  /* Domain name or Dotted Dec.  bad format   */
#define E_LOSTCARRIER  -19  /* The modem disconnected                   */
#define E_NOHOSTNAME   -20  /* Hostname does not exist                  */
#define E_DNSWORKLIMIT -21  /* Resolver Work limit reached              */
#define E_NONAMESERVER -22  /* No nameservers could be found for query  */
#define E_DNSBADFORMAT -23  /* Bad format of DS query                   */
#define E_UNREACHABLE  -24  /* Destination unreachable                  */
#define E_DNSNOADDR    -25  /* No address records exist for host        */
#define E_NOROUTINE	   -26	/* Routine is unavailable					*/
#define E_LOCKED	   -27	/* Locked by another application			*/
#define E_FRAGMENT	   -28	/* Error during fragmentation				*/
#define E_TTLEXCEED	   -29	/* Time to Live of an IP packet exceeded	*/
#define E_PARAMETER	   -30	/* Problem with a parameter					*/
#define E_BIGBUF	   -31	/* Input buffer is too small for data		*/
#define E_BADROUTINE   -32	/* A routine was called inappropriately for a connection */
#define E_DEFFERED	   -33  *- Result deferred.  Call back later */
#define E_LASTERROR     33	/* ABS of last error code in this list      */


/* Input queue structures   */

typedef struct ndb {   /*  Network Data Block.  For data delivery   */
    char        *ptr;       /* Pointer to base of block. (For free();)  */
    char        *ndata;     /* Pointer to next data to deliver          */
    uint16      len;        /* Length of remaining data.                */
    struct ndb  *next;      /* Next NDB in chain or NULL               */
} NDB;

typedef struct ccb {    /* Connection Control Block.    */
    uint16      protocol;   /* TCP or UDP or ... 0 means CCB not in use */
    uint16      lport;      /* TCP client port.  (ie: At this machine)  */
    uint16      rport;      /* TCP server port.  (ie: remote machine)   */
    uint32      rhost;      /* TCP server IP addr. (ie: remote machine) */
	uint32		lhost;		/* TCP client IP addr. (ie: At this machine)*/
    NDB         *ndq;       /* Start of stream data queue or NULL       */
    TCB         *tcb;       /* The TCB for a TCP connection only...     */
    int16       error;      /* Is the connection in error?              */

#define	IN_ISBOUND		0x0001		/* bind() was done on the socket */
#define	IN_HASPORT		IN_ISBOUND	/* socket has local port */
#define IN_ISCONNECTED	0x0002		/* socket is connected */
#define	IN_REUSE		0x0004		/* reuse local port numbers */
#define IN_KEEPALIVE	0x0008		/* keep tcp line open */
#define IN_OOBINLINE	0x0010		/* handle oob data inline */
#define	IN_CHECKSUM		0x0020		/* generate checksums */
#define IN_DONTROUTE	0x0040		/* don't route outgoing dgrams */
#define IN_BROADCAST	0x0080		/* toggle broadcast permission */
#define IN_LINGER		0x0100		/* lingering active */
#define IN_DEAD			0x0200		/* socket is dead (TCP timewait) */
	int16		flags;		/* misc flags */
	int16		inp_flags;	/* misc ip flags */
	IP_HDR		ip;			/* header prototype for TOS and TTL */
	char		ip_opts[40];/* IP per packet options */
} CCB;

/*
 * "state" data for each active tcp conversation on the wire.  This is
 * basically a copy of the entire IP/TCP header from the last packet
 * we saw from the conversation together with a small identifier
 * the transmit & receive ends of the line use to locate saved header.
 */
struct cstate {
	struct cstate *cs_next;	/* next most recently used cstate (xmit only) */
	unsigned short		cs_hlen;	/* size of hdr (receive only) */
	unsigned char		cs_id;		/* connection # associated with this state */
	unsigned char		cs_filler;
	union {
		char 	csu_hdr[MAX_HDR];
		struct ip_header csu_ip;	/* ip/tcp hdr from most recent packet */
	} slcs_u;
};
#define cs_ip	slcs_u.csu_ip
#define cs_hdr	slcs_u.csu_hdr


/*
 *  Serial line state - we need one per line 
 *
 */

typedef struct slcompress {
	struct cstate 	*last_cs; /*struct cstate	*last_cs;	 most recently used tstate */
	octet			last_recv;	/* last rcvd conn. id */
	octet			last_xmit;	/* last sent conn. id */
	short			flags; 		/* was unsigned - Dan */
	struct cstate	*tstate[MAX_STATES];	/* xmit connection states */
	struct cstate	*rstate[MAX_STATES];	/* receive connection states */
};

typedef struct slip {
	DEV_LIST *bdev; /* backlink to interface */
	short		flags;		/* misc flags */
#define	SLF_ESC		0x01		/* next char is escaped */
#define SLF_DROP	0x02		/* drop this packet */
#define SLF_LINKED	0x04		/* interface is linked to device */
#define SLF_COMPRESS	0x08		/* turn on VJ compression */
#define SLF_AUTOCOMP	0x10		/* enable comp. on TCP_UNCOMP. frame */
#define SLF_COMPCID	0x20		/* enable CID compression */
#define SLF_USRMASK	(SLF_COMPRESS|SLF_AUTOCOMP|SLF_COMPCID)

	struct slcompress *comp;	/* states for VJ compression */
};



#define CNMAX		100		/* Maximum connections at any time.			*/
#define DFMAX		20    	/* Max number of reassembly buffers.		*/


/*  The elog[] array is a total count of various things that
 *  happen during a session.  The counts are usually, but
 *  not necessarily errors.  For example, a count is kept
 *  of the total number of packets created, and another of
 *  the total number deleted.  If these don't match at the
 *  end of the program, then some have been left hanging
 *  hanging around somewhere.  This could have implications
 *  for memory usage (ie: wastage).
 */

#define NS_SENT          0  /* Packet sent normally             */
#define EI_VERSION       1  /* Bad IP version                   */
#define EI_SUM           2  /* IP header checksum failure       */
#define EI_ADDRESS       3  /* Not addressed to us              */
#define EI_PROTOCOL      4  /* Unsupported protocol             */
#define EI_ICMPTYPE      5  /* Unsupported ICMP message type    */
#define EI_ICMPSUM       6  /* ICMP Checksum failure            */
#define EI_SNDPROTO      7  /* Sending unknown protocol         */
#define NI_REPLYPING     8  /* Normal ping response discarded   */
#define EU_UDPSUM        9  /* UDP header checksum failure      */
#define EI_NOLISTEN     10  /* ICMP no ping listener            */
#define TOT_CREATED     11  /* Count of packets created         */
#define TOT_DELETED     12  /* Count of packets deleted         */
#define NI_FRAGMENT     13  /* Number of fragments received     */
#define EU_NOPORT       14  /* No active UDP port               */
#define NT_QUEUEDOK     15  /* TCP input packet queued OK       */
#define EF_LISTFULL     16  /* Refrag descriptor list full      */
#define EA_NOMEMORY     17  /* Block creation fail.  No memory? */
#define EI_URNET        18  /* ICMP in, net unreachable         */
#define NOT_CREATED     19  /* Couldn't create packet           */
#define NF_ADDFRAG      20  /* Fragment was copied OK           */
#define EI_URHOST       21  /* ICMP in, host unreachable        */
#define EI_TTLZERO      22  /* Packet discarded due to TTL = 0  */
#define NU_QUEUEDOK     23  /* UDP input packet queued OK       */
#define ET_TCPSUM       24  /* TCP header checksum failure      */
#define ET_NOCONNECT    25  /* No connection for packet         */
#define EI_URPROTO      26  /* ICMP in, protocol unreachable    */
#define NT_SYNRECV      27  /* A SYN has been received          */
#define NT_PKTEMPTY     28  /* A packet with no data received   */
#define EI_URPORT       29  /* ICMP in, port unreachable        */
#define NT_RETRANSMIT   30  /* TCP retransmissions              */
#define ET_PQDROP       31  /* Closing, Pending packet dropped  */
#define CI_LOCALIN      32  /* Bytes in from provider           */
#define CI_LOCALOUT     33  /* Bytes out to provider            */
#define ET_LISTEN       34  /* Listen state (not possible!)     */
#define ET_RMRESET      35  /* Remote RESET the connection      */
#define CI_FOREIGNIN    36  /* Bytes in from other hosts        */
#define ET_NOSYNRST     37  /* Unsynch'd pkt has no SYN or RST  */
#define CI_FOREIGNOUT   38  /* Bytes out to other hosts         */
#define ET_NOACK        39  /* Packet has no ACK                */
#define ET_NODATASTATE  40  /* Data ignored due to TCP state    */
#define ET_DUPDATA      41  /* Duplicate data discarded         */
#define EI_TCPICMP      42  /* A tcp icmp message was delivered */
#define NT_CLOSING      43  /* Session is closing. Fin acked    */
#define EI_TTLTRANS     44  /* TTL exceeded in transit          */
#define EI_TTLFRAG      45  /* Frag TTL reassembled             */
#define EI_BADPARAM     46  /* Parameter problem                */
#define EI_QUENCH       47  /* Source quench message received   */
#define EI_ECHOREQUEST  48  /* Echo Request received            */
#define EI_ECHOREPLY    49  /* Echo reply received              */
#define EI_DFBEXCEEDED  50  /* Defrag buffer size exceeded      */
#define NI_PPPSM        51  /* Regular discard by the PPP SM        */
#define EI_SMDISCARD    52  /* PPP SM didn't need it                        */
#define EI_MTUEXCEEDED  53  /* Exceeded default MTU - no mem    */
#define	EI_NOQUEUES	54		/* Output queues all in use			*/
#define E_REASONS   55      /* Size of elog array               */


/*  The global configuration data structure.  Contains *ALL*
 *  relevant configurable values.  Defined in config.c
 */

typedef struct config {
    uint32  client_ip;          /*  IP address of client (local) machine    */
    uint32  provider;           /*  IP address of provider, or 0L           */
    uint16  ttl;                /*  Default TTL for normal packets          */
    uint16  ping_ttl;           /*  Default TTL for `ping'ing               */
    uint16  mtu;                /*  Default MTU (Maximum Transmission Unit) */
    uint16  mss;                /*  Default MSS (Maximum Segment Size)      */
    uint16  df_bufsize;         /*  Size of defragmentation buffer to use   */
    uint16  rcv_window;         /*  TCP receive window                      */
    uint16  def_rtt;            /*  Initial RTT time in ms                  */
    int16   time_wait_time;     /*  How long to wait in `TIME_WAIT' state   */
    int16   unreach_resp;       /*  Response to unreachable local ports     */
    int32   cn_time;            /*  Time connection was made                */
    int16   cd_valid;           /*  Is Modem CD a valid signal??            */
   	int16	line_protocol;		/*  What type of connection is this			*/
	void (*old_vec)(void);		/*  Old vector address 						*/
	struct slip *slp;			/*  Slip structure for happiness 			*/
	char *cv[101];				/*  Space for extra config variables 		*/
	int16	reports;			/*  Print problems to screen				*/
    int16   max_num_ports;      /* Maximum number of ports supported        */
    uint32  received_data;      /* Counter for data being received          */
    uint32  sent_data;          /* Counter for data being sent              */
	char	*username;			/*  Username */
	char	*password;			/*  Password */
	int16	identdcn;			/* connection for identd services	*/
	uint32	localhost;			/* Local Host IP address */
	int16	slice;				/* Number of time slices we run once in */
	char 	*pap_id;			/* id for PAP */
} CONFIG;

/* Line protocol defines */

#define LP_SLIP			0
#define LP_CSLIP		1
#define LP_PPP			2

/* Screen control defines, for functions in skio.c    */
#define SCRE_BOLD       1
#define SCRE_LIGHT      2
#define SCRE_ITALIC     4
#define SCRE_UNDERLINE  8
#define SCRE_OUTLINE   16
#define SCRE_SHADOW    32
#define SCRE_REVERSE  256   /* This is NOT a VDI attribute  */


/* Unreachable port responses   */
#define UP_IGNORE   0   /* Ignore the incoming packet (delete it)   */
#define UP_RESET    1   /* Send a TCP RST segment                   */
#define UP_ICMP     2   /* Send an ICMP message (The `Right' thing) */

#define	RTTCACHE 16     /* # of TCP round-trip-time cache entries */

struct tcp_rtt {
    uint32  addr;       /* Destination IP address */
    clock_t _srtt;      /* Most recent SRTT */
    clock_t _mdev;      /* Most recent mean deviation */
};

extern struct tcp_rtt Tcp_rtt[RTTCACHE];

/* FLagbox Flag definitions	*/
#define FL_do_resolve 	0
#define FL_housekeep 1
#define FL_l1in 2
#define FL_l1out 3
#define FL_tcp_timer 4
#define FL_frag_ttl_check 5
#define	FL_first_outq 6
#define FL_last_outq 15
#define	FL_malloc 16
#define NUM_OUTQ_FLAGS 10


/* A few things from STiNG for Compatibility */

/*--------------------------------------------------------------------------*/
/*	TCP information block.													*/
/*--------------------------------------------------------------------------*/
typedef struct tcpib
{	uint32	request;	/* 32 bit flags requesting various info (following)	*/
	uint16	state;		/* current TCP state 								*/
	uint32	unacked;	/* unacked outgoing sequence length (incl SYN/FIN)	*/
	uint32	srtt;		/* smoothed round trip time of this connection		*/
}	TCPIB;

#define	TCPI_state		0x00000001L	/* request current TCP state			*/
#define	TCPI_unacked	0x00000002L	/* request length of unacked sequence	*/
#define	TCPI_srtt		0x00000004L	/* request smoothed round trip time		*/
#define	TCPI_defer		0x00000008L	/* request switch to DEFER mode			*/

#define TCPI_bits		4			/* The number of bits which are defined	*/
#define	TCPI_mask		0x0000000FL	/* current sum of defined request bits	*/
/*--------------------------------------------------------------------------*/
/* NB: A TCP_info request using undefined bits will result in E_PARAMETER.	*/
/*     else the return value will be TCPI_bits, so user knows what we have.	*/
/*     Future additions will use rising bits in sequence, and additions to	*/
/*     the TCPIB struct will always be made at its previous end.			*/
/*--------------------------------------------------------------------------*/
/* !!! By TCP_info with TCPI_defer, connection is switched to 'DEFER' mode.	*/
/*     This means that all situations where internal looping would occur	*/
/*     will instead lead to exit to the caller with return value E_DEFERRED	*/
/*     Using this mode constitutes agreement to always check for that new	*/
/*     error code, which is only used for connections using DEFER mode.		*/
/*--------------------------------------------------------------------------*/

/*--------------------------------------------------------------------------*/
/*	Buffer for inquiring port names.										*/
/*--------------------------------------------------------------------------*/
typedef	struct	pnta
{	uint32	opaque;			/* Kernel internal data			*/
	int16	name_len;		/* Length of port name buffer	*/
	char	*port_name;		/* Buffer address				*/
}	PNTA;

/*--------------------------------------------------------------------------*/
/*	Command opcodes for cntrl_port().										*/
/*--------------------------------------------------------------------------*/
#define	CTL_KERN_FIRST_PORT		(('K' << 8) | 'F')   /* Kernel            */
#define	CTL_KERN_NEXT_PORT		(('K' << 8) | 'N')   /* Kernel            */
#define	CTL_KERN_FIND_PORT		(('K' << 8) | 'G')   /* Kernel            */

#define	CTL_GENERIC_SET_IP		(('G' << 8) | 'H')   /* Kernel, all ports */
#define	CTL_GENERIC_GET_IP		(('G' << 8) | 'I')   /* Kernel, all ports */
#define	CTL_GENERIC_SET_MASK	(('G' << 8) | 'L')   /* Kernel, all ports */
#define	CTL_GENERIC_GET_MASK	(('G' << 8) | 'M')   /* Kernel, all ports */
#define	CTL_GENERIC_SET_MTU		(('G' << 8) | 'N')   /* Kernel, all ports */
#define	CTL_GENERIC_GET_MTU		(('G' << 8) | 'O')   /* Kernel, all ports */
#define	CTL_GENERIC_GET_MMTU	(('G' << 8) | 'P')   /* Kernel, all ports */
#define	CTL_GENERIC_GET_TYPE	(('G' << 8) | 'T')   /* Kernel, all ports */
#define	CTL_GENERIC_GET_STAT	(('G' << 8) | 'S')   /* Kernel, all ports */
#define	CTL_GENERIC_CLR_STAT	(('G' << 8) | 'C')   /* Kernel, all ports */

#define	CTL_SERIAL_SET_PRTCL	(('S' << 8) | 'P')   /* Serial Driver     */
#define	CTL_SERIAL_GET_PRTCL	(('S' << 8) | 'Q')   /* Serial Driver     */
#define	CTL_SERIAL_SET_LOGBUFF	('S' << 8 | 'L')     /* Serial Driver     */
#define	CTL_SERIAL_SET_LOGGING	('S' << 8 | 'F')     /* Serial Driver     */
#define	CTL_SERIAL_SET_AUTH		(('S' << 8) | 'A')   /* Serial Driver     */
#define	CTL_SERIAL_SET_PAP		(('S' << 8) | 'B')   /* Serial Driver     */
#define	CTL_SERIAL_INQ_STATE	(('S' << 8) | 'S')   /* Serial Driver     */

#define	CTL_ETHER_SET_MAC		(('E' << 8) | 'M')   /* EtherNet          */
#define	CTL_ETHER_GET_MAC		(('E' << 8) | 'N')   /* EtherNet          */
#define	CTL_ETHER_INQ_SUPPTYPE	(('E' << 8) | 'Q')   /* EtherNet          */
#define	CTL_ETHER_SET_TYPE		(('E' << 8) | 'T')   /* EtherNet          */
#define	CTL_ETHER_GET_TYPE		(('E' << 8) | 'U')   /* EtherNet          */

#define	CTL_MASQUE_SET_PORT		(('M' << 8) | 'P')   /* Masquerade        */
#define	CTL_MASQUE_GET_PORT		(('M' << 8) | 'Q')   /* Masquerade        */
#define	CTL_MASQUE_SET_MASKIP	(('M' << 8) | 'M')   /* Masquerade        */
#define	CTL_MASQUE_GET_MASKIP	(('M' << 8) | 'N')   /* Masquerade        */
#define	CTL_MASQUE_GET_REALIP	(('M' << 8) | 'R')   /* Masquerade        */


/* Structure for query_state information
 *
 * int16 lcp state
 * int16 IPCP state
 * int16 PAP state
 * uint32 Last packet protocol
 * uchar  last packet command
 */
 
typedef struct ppp_structure {
    int16  lcp;        /* Current LCP state    */
    int16  ipcp;       /* Current IPCP state   */
    int16  pap;        /* Current PAP state    */
    unsigned int protocol;   /* Last packet protocol */
    unsigned char cmd; /* Last packet command  */
} PPP_ST;


/* Also declared here for convenience...    */
extern CONFIG config;
extern int16 bios_port, io_port;	/* bios_port is for DTR and CD	*/
extern long elog[E_REASONS];
extern char cdir[100];	/* Config directory	*/
extern struct slip *myslip;
extern struct slcompress *comp;
extern struct cstate mytstate[MAX_STATES];
extern struct cstate myrstate[MAX_STATES];
extern int port_open;
extern int inint;
extern int16 lastcn;
extern DEV_LIST *bdev_list;

#endif /* _GLOBDEFS_H_ */
