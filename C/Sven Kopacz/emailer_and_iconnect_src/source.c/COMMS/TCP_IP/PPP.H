#if !defined( __PPP__ )
#define __PPP__

/* PPP Protocols */
#define PPP_PROTO_LCP		0xC021u
#define PPP_PROTO_IPCP	0x8021u
#define PPP_PROTO_IP		0x21
#define PPP_PROTO_PAP		0xC023u

/* PPP states */
#define PPP_INITIAL		0
#define PPP_STARTING	1
#define PPP_CLOSED		2
#define PPP_STOPPED		3
#define PPP_CLOSING		4
#define PPP_STOPPING	5
#define PPP_REQ_SENT	6
#define PPP_ACK_RCVD	7
#define PPP_ACK_SENT	8
#define PPP_OPENED		9

/* PPP events */
#define PEV_LOW_UP			0		/* Lower Level is up */
#define PEV_LOW_DOWN		1		/* Lower Level is down */
#define PEV_ADMIN_OPEN	2		/* Administrative Open */
#define PEV_ADMIN_CLOSE	3		/* Administrative Close */
#define PEV_TIMEOUT_P		4		/* Timeout with counter > 0 */
#define PEV_TIMEOUT_N		5		/* Timeout with counter expired */
#define PEV_RCR_P				6		/* Recv Configure Request (good) */
#define PEV_RCR_N				7		/* Recv Configure Request (bad) */
#define PEV_RCA					8		/* Recv Configure Ack */
#define PEV_RCN					9		/* Recv Configure Nak/Rej */
#define PEV_RTR					10	/* Recv Terminate Request */
#define PEV_RTA					11	/* Recv Terminate Ack */
#define PEV_RUC					12	/* Recv Unknown Code */
#define PEV_RXJ_P				13	/* Recv Code Reject (permitted) or Protocol Reject */
#define PEV_RXJ_N				14	/* Recv Code Reject (fatal) or Protocol Reject */
#define PEV_RXR					15	/* Recv Echo Request or Echo Reply or Discard Request */

/* LCP Codes */
#define LCP_CONF_REQ		1
#define LCP_CONF_ACK		2
#define LCP_CONF_NACK		3
#define LCP_CONF_REJ		4
#define LCP_TERM_REQ		5
#define LCP_TERM_ACK		6
#define LCP_CODE_REJ		7
#define LCP_PROT_REJ		8
#define LCP_ECHO_REQ		9
#define LCP_ECHO_REP		10
#define LCP_DISC_REQ		11

/* PAP Codes */
#define PAP_AUTH_REQ		1
#define PAP_AUTH_ACK		2
#define PAP_AUTH_NACK		3

/* LCP Options */
#define LCPO_RESERVED		0
#define LCPO_MRU				1		/* Maximum Receive Unit */
#define LCPO_ACCM				2		/* Async Control Character Map */
#define LCPO_AUTH				3		/* Authentication Protocol */
#define LCPO_QUALITY		4		/* Quality Protocol */
#define LCPO_MAGIC			5		/* Magic Number */
#define LCPO_PROTO_COMP	7		/* Protocol Field Compression */
#define LCPO_ADDR_COMP	8		/* Adress- and Control-Field Compression */
#define LCPO_NUM_MODE 	11 	/* Numbered Mode */
#define LCPO_MULTI_MRRU	17	/* Multilink-MRRU */
#define LCPO_MULTI_SHEAD 18	/* Multilink short header */
#define LCPO_MULTI_END	19	/* Multiplexing endpoint discriminator */

#define LCPO_DEFAULTS ((1<<LCPO_MRU)|(1<<LCPO_ACCM)|(1<<LCPO_PROTO_COMP)|(1<<LCPO_ADDR_COMP))
#define MRU_DEFAULT		(defaults.rcv_wnd+80)				/* My max. Receive-Unit */
#define ACCM_DEFAULT  0x000a0000l	/* Host should escape these (XON/XOFF) */

/* IPCP Options */
#define IPCPO_IP_ADDRESSES		1
#define IPCPO_IP_COMPRESS			2
#define IPCPO_IP_ADDRESS			3
#define IPCPO_PRIMARY_DNS			129
#define IPCPO_PRIMARY_NBNS		130
#define IPCPO_SECONDARY_DNS		131
#define IPCPO_SECONDARY_NBNS	132


/* Restart-counter-types */
#define PPP_IRC_CONF	0
#define PPP_IRC_TERM	1


#define SBUF	4096	/* Default Size of Send-buffers (REQ/NAK/REJ) */
typedef struct
{
	int		state;					/* state of ppp-automaton */
	int		ppp_up;					/* Similar to state=PPP_OPENED */
	int		illegals;				/* statistics: number of illegal events during sign-up */

	int		hdlc_framing;		/* Framing on (1) or off(0) */
	
	long	restart_timer;
	int		restart_counter;
	int		failure_counter;

	int		act_options;	/* Actual option-choice in configuring */
	char	sent_id;			/* ID recently used for send conf_request etc. */
	int		padding;			/* If the compiler won't, I will */
	
	uchar	send_req[SBUF];	/* Acutal Request to send */
	uint	send_req_len;		/* Length of used buffer */
	uchar	*recv_req;			/* Received (term)request or echo buffer */
	uint	recv_req_len;		/* Length of received request buffer */

	uchar	nack_buf[SBUF];	/* Buffer containing unacceptable reqs (with code/id) */
	uint	nack_len;				/* Length of used buffer */
	uchar	rej_buf[SBUF];	/* Buffer containing unknown reqs (with code/id) */
	uint	rej_len;				/* Length of used buffer */
	uchar	crj_buf[SBUF];	/* Buffer containing unknown codes (with code/id) */
	uint	crj_len;				/* Length of used buffer */

	ulong	local_magic;	/* Local magic number */
	ulong	peers_magic;		/* Peer's magic number */

	unsigned long send_accm[8];			/* Asynchron Control Character Maps */
	unsigned long mem_send_accm;	
	unsigned long recv_accm[1];
	
	/*	Used in Null-framing only: */
	int		recv_state;		/*	0: Receiving new packet 
													For Config Protocols:
													1: Expecting type byte
													2: Expecting length byte
													3: Receiving information
													For IP Packets:
													1: Expecting Version/IHL
													11: Expecting Type of Service
													2: Expecting MSB Length
													22: Expecting LSB Length
													3: Receiving left header and data
											*/
	uint	recv_proto;		/* Protocol of incoming packet */
	uint	recv_len;			/* Length of incoming packet */
	uint	recv_left;		/* Bytes left to receive for completion */
	uint	recv_bufoffset;	/* Offset from buffer-start to information */
	
	int		use_proto_comp;	/* Protocol compression ok for peer 0/1 */
	int		use_addr_comp;	/* Address compression ok for peer 0/1 */

	ulong	lcp_echo_timer;
		
	/* IPCP values */
	int		ipcp_sent_id;
	int		ipcp_ack_sent;
	int		ipcp_ack_rcvd;
	int		ipcp_up;
	int		ipcp_use_address_req;	/* Use Option 3 in Conf-Req 0/1 */
	int		ipcp_use_dns_req;			/* Use Option 129 in Conf-Req 0/1 */
}PPP_VALS;


typedef struct	_ppp_buf
{
	struct _ppp_buf 	*next;
	uint							len;
	uchar							*buf;
}ppp_buf;

typedef struct
{
	char	code;
	char	identifier;
	uint	length;
}lcp_header;

/* ms to wait between buffers when pushing them on abort */
#define ABORT_FREQ 200
/* Maximum retries on one buffer */
#define ABORT_RETRY 5
/* If retries fail, delete all other buffers too? */
#define ABORT_IMMED 1


/* HDLC chars */
#define HDLC_ESC   	0x7d    /* escape char */
#define HDLC_FLAG    0x7e    /* frame start/end */
#define HDLC_TRANS   0x20    /* XOR with this to (un)esc char */
#define HDLC_ADDR    0xff    /* 'all station' HDLC address */
#define HDLC_CTRL    0x03    /* UI with P/F bit cleared */

/* Macros for dealing with asynch. character maps */
#define MAP_ZERO(m) (memset (m, 0, sizeof (m)))
#define MAP_SET(m,b)  ((m)[(unsigned char)(b) >> 5] |= 1L << ((b) & 0x1f))
#define MAP_CLR(m,b)  ((m)[(unsigned char)(b) >> 5] &= ~(1L << ((b) & 0x1f)))
#define MAP_ISSET(m,b)  ((m)[(unsigned char)(b) >> 5] & (1L << ((b) & 0x1f)))


/* Functions in ppp.c and ppp_acts.c */

void	ppp_init(void);
void	init_other_buffers(void);
void	init_request_buffer(int options, int mru);
void	ppp_timer_jobs(void);
void	ppp_in(uchar *buf, uint len);
void	ppp_hdlc_in(uchar *buf, uint len);
void	ppp_hdlc_process(uchar *buf, uint len);
void	ppp_nullframe_in(uchar *buf, uint len);
void	ppp_dispatch(uint protocol, uchar *buf, uint len);
void	ppp_lcp_process(uchar *buf, uint len);
int		check_request(void);
void	check_ack(void);
void	check_nack(void);
void	check_reject(void);
int		ppp_send(uint protocol, uchar *buf, uint len);
void	ppp_out(void);
void	ppp_abort(void);

void ppp_tlu(void); /* This layer up */
void ppp_tld(void);	/* This layer down */
void ppp_tls(void);	/* This layer started */
void ppp_tlf(void);	/* This layer finished */
void ppp_irc(int irc_type);	/* Initiate restart counter */
void ppp_zrc(void);	/* Zero restart counter */
void ppp_scr(void);	/* Send configure request */
void ppp_sca(void); /* Send configure acknowledged */
void ppp_scn(void);	/* Send configure not acknowledged or rejected */
void ppp_str(void);	/* Send terminate request */
void ppp_sta(void);	/* Send terminate acknowledge */
void ppp_scj(void);	/* Send code reject */
void ppp_spj(uint protocol, uchar *buf, uint len);	/* Send protocol reject */
void ppp_seq(void);	/* Send echo request */
void ppp_ser(void);	/* Send echo reply */
void ppp_automaton(int event);


#endif